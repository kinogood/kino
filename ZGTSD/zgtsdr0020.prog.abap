*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSDR0020
*& 프로그램 명 : 거래명세서 발행
*& 개요   :  ZPBR0020 을 복사하여 현행 거래명세서 로직 추가
*& 생성일 : 2025.02.11
*& 생성자 : 신영철
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*& SRM2510-06313 / ZLSGSD2 / 직납 출하정보 MES 전송 추가
*&---------------------------------------------------------------------*
REPORT zgtsdr0020 NO STANDARD PAGE HEADING MESSAGE-ID zppb1.

*-----------------------------------------------------------------------
*-- Include
*-----------------------------------------------------------------------
INCLUDE zgtsdr0020_top.
INCLUDE zgtsdr0020_c01.
INCLUDE zgtsdr0020_o01.
INCLUDE zgtsdr0020_i01.
INCLUDE zgtsdr0020_f01.

*-----------------------------------------------------------------------
*-- Initialization
*-----------------------------------------------------------------------
INITIALIZATION.
  PERFORM initialization.

*-----------------------------------------------------------------------
*-- At Selection-Screen
*-----------------------------------------------------------------------
AT SELECTION-SCREEN.
  PERFORM sel_pai.
  PERFORM get_bzarea.
  PERFORM check_input USING p_bzarea.
** 권한CHECK
  PERFORM authority_check.

*-----------------------------------------------------------------------
*-- At Selection-Screen Output
*-----------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
* Radio button click시 필드 활성/비활성
  PERFORM screen_field_chang.

*-----------------------------------------------------------------------
*-- Start-Of-Selection
*-----------------------------------------------------------------------
START-OF-SELECTION.
  CLEAR : gv_exit.
  PERFORM get_bzarea.
  CHECK gv_exit = ' '.
  PERFORM check_gt_pgm.
  PERFORM selection .
  DESCRIBE TABLE gt_qlist LINES gv_lin.
  IF gv_lin > 0.
    CALL SCREEN 200.
  ELSE.
    MESSAGE s000 WITH '조건에 맞는 DATA가 없습니다'.
  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  check_input
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BZAREA  text
*----------------------------------------------------------------------*
FORM check_input  USING    p_area.

  SELECT SINGLE mandt INTO sy-mandt FROM zlet0033
    WHERE bzarea = p_area.
  IF sy-subrc <> 0.
    MESSAGE e000 WITH '존재하지 않는 사업장입니다'.
  ENDIF.

ENDFORM.                    " check_input
*&---------------------------------------------------------------------*
*&      Form  screen_field_chang
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM screen_field_chang .

  LOOP AT SCREEN.
    IF r_vbeln = 'X'.
      IF screen-name = 'S_TKNUM-LOW' OR
         screen-name = 'S_TKNUM-HIGH'.
        screen-input = 0.
      ENDIF.
    ENDIF.

    IF r01 = 'X'.
      IF screen-name = 'S_IV_NO-LOW' OR
         screen-name = 'S_IV_NO-HIGH' OR
         screen-name = 'S_DATE-LOW' OR
         screen-name = 'S_DATE-HIGH'.
        screen-input = 0.
      ENDIF.
    ENDIF.

    IF r_sto = 'X'.
      x_vbeln = 'X'.
    ELSE.
      x_vbeln = space.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    " screen_field_chang
*&---------------------------------------------------------------------*
*&      Form  selection
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM selection .

  DATA : lt_list TYPE gty_t_list.

*/ LIKP-ZOUT = 'X'   "통문확정없이 빌링 가능
*  LIKP-ZOUT = 'Y'   "통문확정

*/ Ranges Setting
  PERFORM setting_ranges TABLES r_lfart r_vstel
                         USING  p_bzarea.

  IF r_vbeln = 'X'.  "납품문서 기준
    IF r01 = 'X'.     "신규발행
      PERFORM get_data_vbeln "TABLES gt_list.
                                    CHANGING lt_list.
    ELSE.
      PERFORM get_data_vbeln_1 "TABLES gt_list.
                                    CHANGING lt_list.
    ENDIF.
  ELSE.              "선적문서 기준
    IF r01 = 'X'.     "신규발행
      PERFORM get_data_tknum "TABLES gt_list.
                                    CHANGING lt_list.
    ELSE.
      PERFORM get_data_tknum_1 "TABLES gt_list.
                                    CHANGING lt_list.
    ENDIF.
  ENDIF.

*클래스가 FT_BD_GENERAL_001, FT_BD_PH_BOX_001 인지 읽어오기.

*  PERFORM get_class.
*/
  PERFORM data_modify               TABLES "gt_list
                                             gt_qlist
                                    USING    lt_list.

*/
  SORT gt_qlist.

ENDFORM.                    " selection
*&---------------------------------------------------------------------*
*&      Form  setting_ranges
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM setting_ranges TABLES r_lfart LIKE r_lfart[]
                           r_vstel LIKE r_vstel[]
*                           r_werks LIKE r_werks[]
*                           r_lgort LIKE r_lgort[]
                    USING  p_bzarea.

*/ 납품유형
  CLEAR: r_lfart[], r_lfart.
  IF r_so = 'X'.
    PERFORM get_ranges_lfart TABLES r_lfart
                             USING: 'LF',  'LF2', 'LF4', 'LF5', 'LF6',
                                    'LF7', 'LF8', 'LF9', 'LF10',
                                    'LR',  'LR1', 'LR2', 'LR3'.
  ELSEIF r_sto = 'X'.
    PERFORM get_ranges_lfart TABLES r_lfart
                             USING: 'NL'.
  ELSE.
    PERFORM get_ranges_lfart TABLES r_lfart
                             USING: 'LF',  'LF2', 'LF4', 'LF5', 'LF6',
                                    'LF7', 'LF8', 'LF9', 'LF10',
                                    'LR',  'LR1', 'LR2', 'LR3','NL'.

  ENDIF.

*/ 사업장별 출하지점
  CLEAR: r_vstel[], r_vstel.
  SELECT * FROM zlet0033 WHERE bzarea = p_bzarea.
    r_vstel-sign   = 'I'.
    r_vstel-option = 'EQ'.
    r_vstel-low    = zlet0033-vstel.
    APPEND r_vstel.
  ENDSELECT.

*/ 통문대상포함
  CLEAR: r_outyn[], r_outyn.
  IF p_out = 'X'.

  ELSE.
    r_outyn-sign    = 'I'.
    r_outyn-option  = 'NE'.
    r_outyn-low     = 'Y'.
    APPEND r_outyn.
  ENDIF.

**/ HU 사용
*  CLEAR: r_werks[], r_werks, r_lgort[], r_lgort.
*  SELECT * FROM t001l WHERE xhupf = 'X'.
*    r_werks-sign   = 'I'.
*    r_werks-option = 'EQ'.
*    r_werks-low    = t001l-werks.
*    COLLECT r_werks.  CLEAR: r_werks.
*
*    r_lgort-sign   = 'I'.
*    r_lgort-option = 'EQ'.
*    r_lgort-low    = t001l-lgort.
*    COLLECT r_lgort.  CLEAR: r_lgort.
*  ENDSELECT.


ENDFORM.                    " setting_ranges
*&---------------------------------------------------------------------*
*&      Form  get_ranges_lfart
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0102   text
*----------------------------------------------------------------------*
FORM get_ranges_lfart TABLES   r_lfart LIKE r_lfart[]
                      USING    p_lfart.

  r_lfart-sign   = 'I'.
  r_lfart-option = 'EQ'.
  r_lfart-low    = p_lfart.
  APPEND r_lfart.

ENDFORM.                    " get_ranges_lfart
*&---------------------------------------------------------------------*
*&      Form  DATA_MODIFY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_modify TABLES pt_qlist LIKE gt_qlist[]
                 USING  pt_list  TYPE gty_t_list.

  DATA : lv_ph_chk,   "자재 클래스 체크 FT_BD_GENERAL_001,
         lv_length_c(30),
         lv_length_so_c(30),
         lv_packc(20),                                    "포장재유형
         lv_packg           LIKE  mara-matnr,             "포장재
         lv_factor          TYPE i,
         lv_list_packc      TYPE i,
         lv_charg_cnt       TYPE i,
         lv_arktx           LIKE vbap-arktx.

  DATA : lt_qlist LIKE TABLE OF gt_qlist WITH HEADER LINE.

  CLEAR : lv_ph_chk,
          lt_qlist[], lt_qlist.

*-- 견적품명 정보 Select
  WITH +key_info AS ( SELECT a~vbeln, a~posnr, b~vgbel, b~vgpos
                       FROM @pt_list AS a INNER JOIN lips AS b
                                             ON a~vbeln EQ b~vbeln
                                            AND a~posnr EQ b~posnr
                      GROUP BY a~vbeln, a~posnr, b~vgbel, b~vgpos )

    SELECT b~vbeln,  b~posnr,  a~qcode,  a~qname
      FROM zgtsdt0066 AS a INNER JOIN +key_info AS b
                              ON a~vbeln EQ b~vgbel
                             AND a~posnr EQ b~vgpos

     ORDER BY b~vbeln, b~posnr

      INTO TABLE @DATA(lt_0066).

  LOOP AT pt_list INTO DATA(ls_list).
    CLEAR lt_qlist.

    lt_qlist = CORRESPONDING #( ls_list ).

    READ TABLE lt_0066 WITH KEY vbeln = ls_list-vbeln
                                posnr = ls_list-posnr
                       INTO DATA(ls_0066).
    IF sy-subrc EQ 0.
* 견적품명(A/B/C/D)    PD_BD_PROD_NAME(desc)
      lt_qlist-prod_cd = ls_0066-qcode.
      lt_qlist-prod    = ls_0066-qname.
    ENDIF.

    IF lt_qlist-lfart = 'NL'.
      lt_qlist-iv_type = 'A02'.

      DATA: pv_ebeln LIKE ekpo-ebeln.
      DATA: pv_ebelp LIKE ekpo-ebelp.

      DATA: ls_return TYPE bapiret2_t.
      DATA: lt_char   LIKE e1cuval OCCURS 0 WITH HEADER LINE.
      DATA: pv_length LIKE zppt0001-mgvrg.

      REFRESH: lt_char.
      CLEAR  : lt_char, ls_return, pv_length.

      pv_ebeln = lt_qlist-vgbel.
      pv_ebelp = lt_qlist-vgpos.

      CALL FUNCTION 'ZMM_EKPO_SPEC_GET'
        EXPORTING
          ebeln                        = pv_ebeln
          ebelp                        = pv_ebelp
        IMPORTING
          et_return                    = ls_return
        TABLES
          t_e1cuval                    = lt_char
        EXCEPTIONS
          instance_not_found           = 1
          internal_error               = 2
          instance_is_a_classification = 3
          OTHERS                       = 4.

      IF NOT lt_char[] IS INITIAL.
* 조장
        READ TABLE lt_char WITH KEY charc = 'SAP_MILLCA_LENGTH'.
        IF sy-subrc = 0.
          PERFORM char_fltp_conversion USING lt_char-value
                                    CHANGING pv_length.
          lt_qlist-length_so = pv_length.
        ENDIF.

* 제품구분(D)         PD_BD_PRODUCT_ID
        READ TABLE lt_char WITH KEY charc = 'PD_NBD_CM_PROD_ID'.
        IF sy-subrc = 0.
          lt_qlist-prdid = lt_char-value.
        ENDIF.

** 견적품명(A/B/C/D)    PD_BD_PROD_NAME(desc)
*        READ TABLE lt_char WITH KEY charc = 'PD_NBD_BSW_PROD_CD'.
*        IF sy-subrc = 0.
*          lt_qlist-prod_cd = lt_char-value.
*          lt_qlist-prod = lt_char-value_txt.
*
*        ENDIF.

* 전압(D)      PD_BD_VOLTAGE(desc)
        READ TABLE lt_char WITH KEY charc = 'PD_NBD_CM_VOL'.
        IF sy-subrc = 0.
          lt_qlist-volt = lt_char-value_txt.
        ENDIF.

* 상(C/D)      PD_BD_WIRE_CNT
        READ TABLE lt_char WITH KEY charc = 'PD_NBD_CM_PC'.
        IF sy-subrc = 0.
          lt_qlist-wire = lt_char-value.
          lt_qlist-wire_desc = lt_char-value_txt.
        ENDIF.

* 접지구분(D)  PD_BD_GROUND_TYPE
        READ TABLE lt_char WITH KEY charc = 'PD_NBD_CM_GT'.
        IF sy-subrc = 0.
          lt_qlist-gnd = lt_char-value_txt.
        ENDIF.

* 용량(C/D)    PD_BD_AMPHERE(desc)
        READ TABLE lt_char WITH KEY charc = 'PD_NBD_CM_AMP'.
        IF sy-subrc = 0.
          lt_qlist-amp = lt_char-value_txt.
        ENDIF.

* 도체재질(D)  PD_BD_COND_MTRL(desc)
        READ TABLE lt_char WITH KEY charc = 'PD_NBD_BSP_CM'.
        IF sy-subrc = 0.
          lt_qlist-cond = lt_char-value_txt.
        ENDIF.

* 덕트재질(D)  PD_BD_DUCT_MTRL_EST(desc)
        READ TABLE lt_char WITH KEY charc = 'PD_NBD_CM_ED'.
        IF sy-subrc = 0.
          lt_qlist-duct = lt_char-value_txt.
        ENDIF.

* IP등급(D)    PD_BD_IP_GRADE
        READ TABLE lt_char WITH KEY charc = 'PD_NBD_CM_IP_GRD'.
        IF sy-subrc = 0.
          lt_qlist-ipdeg = lt_char-value.
          lt_qlist-ipdeg_name = lt_char-value_txt.
        ENDIF.

* 메인차단기극수(A/B)   PD_BD_POLE_CNT(desc)
        READ TABLE lt_char WITH KEY charc = 'PD_BD_POLE_CNT'.
        IF sy-subrc = 0.
          lt_qlist-pole = lt_char-value_txt.
        ENDIF.

* 메인차단기모델(A/B)   PD_BD_BREAKER_MODEL(desc)
        READ TABLE lt_char WITH KEY charc = 'PD_BD_BREAKER_MODEL'.
        IF sy-subrc = 0.
          lt_qlist-brea = lt_char-value_txt.
        ENDIF.

* 메인프레임용량(A/B)   PD_BD_AMPHERE_FRAME(desc)
        READ TABLE lt_char WITH KEY charc = 'PD_BD_AMPHERE_FRAME'.
        IF sy-subrc = 0.
          lt_qlist-frame = lt_char-value_txt.
        ENDIF.


* 메인트립용량(A/B)     PD_BD_AMPHERE_TRIP(desc)
        READ TABLE lt_char WITH KEY charc = 'PD_BD_AMPHERE_TRIP'.
        IF sy-subrc = 0.
          lt_qlist-trip = lt_char-value_txt.
        ENDIF.

* 서브프레임용량(B) PD_BD_AMPHERE_FRAME_SUB(desc)
        READ TABLE lt_char WITH KEY charc = 'PD_BD_AMPHERE_FRAME_SUB'.
        IF sy-subrc = 0.
          lt_qlist-frame_sub = lt_char-value_txt.
        ENDIF.

* 서브차단기극수(B) PD_BD_POLE_CNT_SUB(desc)
        READ TABLE lt_char WITH KEY charc = 'PD_BD_POLE_CNT_SUB'.
        IF sy-subrc = 0.
          lt_qlist-pole_sub = lt_char-value_txt.
        ENDIF.

* 서브차단기모델(B) PD_BD_BREAKER_MODEL_SUB(desc)
        READ TABLE lt_char WITH KEY charc = 'PD_BD_BREAKER_MODEL_SUB'.
        IF sy-subrc = 0.
          lt_qlist-brea_sub = lt_char-value_txt.
        ENDIF.

* 서브트립용량(B)   PD_BD_AMPHERE_TRIP_SUB(desc)
        READ TABLE lt_char WITH KEY charc = 'PD_BD_AMPHERE_TRIP_SUB'.
        IF sy-subrc = 0.
          lt_qlist-trip_sub = lt_char-value_txt.
        ENDIF.

* 회로수(B)         PD_BD_CIRCUIT_CNT(desc)
        READ TABLE lt_char WITH KEY charc = 'PD_BD_CIRCUIT_CNT'.
        IF sy-subrc = 0.
          lt_qlist-circuit = lt_char-value_txt.
        ENDIF.

* 회로당차단기수(B) PD_BD_CIRCUIT_PER_MCCB(desc)
        READ TABLE lt_char WITH KEY charc = 'PD_BD_CIRCUIT_PER_MCCB'.
        IF sy-subrc = 0.
          lt_qlist-circuit_per = lt_char-value_txt.
        ENDIF.

* N상구분(C/D)       PD_BD_N_WIRE_TYPE
        READ TABLE lt_char WITH KEY charc = 'PD_NBD_CM_NT'.
        IF sy-subrc = 0.
          lt_qlist-wire_type = lt_char-value.
        ENDIF.
      ENDIF.

    ELSE.
      lt_qlist-iv_type = 'A01'.
* 주문특성
*{ 자체개선 44157 - 변경
      REFRESH: gt_char1.
      PERFORM get_characteristic_table(zler0001) TABLES gt_char1
                                                  USING lt_qlist-vgbel
                                                        lt_qlist-vgpos.
      IF NOT gt_char1[] IS INITIAL.
        PERFORM get_char_value_desc.

** 조장
        READ TABLE gt_char1 WITH KEY atnam = 'SAP_LENGTH_VKRME'.
        IF sy-subrc = 0.
          lt_qlist-length_so = gt_char1-atwtb.
        ENDIF.

* 제품구분(D)         PD_BD_PRODUCT_ID
        READ TABLE gt_char1 WITH KEY atnam = 'PD_NBD_CM_PROD_ID'.
        IF sy-subrc = 0.
          lt_qlist-prdid = gt_char1-atwtb.
        ENDIF.

** 견적품명(A/B/C/D)    PD_BD_PROD_NAME(desc)
*        READ TABLE gt_char1 WITH KEY atnam = 'PD_NBD_BSW_PROD_CD'.
*        IF sy-subrc = 0.
*          lt_qlist-prod_cd = gt_char1-atwrt.
*          lt_qlist-prod    = gt_char1-atwtb.
*        ENDIF.

* 전압(D)      PD_BD_VOLTAGE(desc)
        READ TABLE gt_char1 WITH KEY atnam = 'PD_NBD_CM_VOL'.
        IF sy-subrc = 0.
          lt_qlist-volt = gt_char1-atwtb.
        ENDIF.

* 상(C/D)      PD_BD_WIRE_CNT
        READ TABLE gt_char1 WITH KEY atnam = 'PD_NBD_CM_PC'.
        IF sy-subrc = 0.
          lt_qlist-wire      = gt_char1-atwrt.
          lt_qlist-wire_desc = gt_char1-atwtb.

        ENDIF.

* 접지구분(D)  PD_BD_GROUND_TYPE
        READ TABLE gt_char1 WITH KEY atnam = 'PD_NBD_CM_GT'.
        IF sy-subrc = 0.
          lt_qlist-gnd =   gt_char1-atwtb.
        ENDIF.

* 용량(C/D)    PD_BD_AMPHERE(desc)
        READ TABLE gt_char1 WITH KEY atnam = 'PD_NBD_CM_AMP'.
        IF sy-subrc = 0.
          lt_qlist-amp = gt_char1-atwtb.
        ENDIF.

* 도체재질(D)  PD_BD_COND_MTRL(desc)
        READ TABLE gt_char1 WITH KEY atnam = 'PD_NBD_BSP_CM'.
        IF sy-subrc = 0.
          lt_qlist-cond = gt_char1-atwtb.
        ENDIF.

* 덕트재질(D)  PD_BD_DUCT_MTRL_EST(desc)
        READ TABLE gt_char1 WITH KEY atnam = 'PD_NBD_CM_ED'.
        IF sy-subrc = 0.
          lt_qlist-duct = gt_char1-atwtb.
        ENDIF.

* IP등급(D)    PD_BD_IP_GRADE
        READ TABLE gt_char1 WITH KEY atnam = 'PD_NBD_CM_IP_GRD'.
        IF sy-subrc = 0.
          lt_qlist-ipdeg      = gt_char1-atwtb.
          lt_qlist-ipdeg_name = gt_char1-atwtb.
        ENDIF.

* 메인차단기극수(A/B)   PD_BD_POLE_CNT(desc)
        READ TABLE gt_char1 WITH KEY atnam = 'PD_BD_POLE_CNT'.
        IF sy-subrc = 0.
          lt_qlist-pole = gt_char1-atwtb..
        ENDIF.

* 메인차단기모델(A/B)   PD_BD_BREAKER_MODEL(desc)
        READ TABLE gt_char1 WITH KEY atnam = 'PD_BD_BREAKER_MODEL'.
        IF sy-subrc = 0.
          lt_qlist-brea = gt_char1-atwtb..
        ENDIF.

* 메인프레임용량(A/B)   PD_BD_AMPHERE_FRAME(desc)
        READ TABLE gt_char1 WITH KEY atnam = 'PD_BD_AMPHERE_FRAME'.
        IF sy-subrc = 0.
          lt_qlist-frame = gt_char1-atwtb.
        ENDIF.


* 메인트립용량(A/B)     PD_BD_AMPHERE_TRIP(desc)
        READ TABLE gt_char1 WITH KEY atnam = 'PD_BD_AMPHERE_TRIP'.
        IF sy-subrc = 0.
          lt_qlist-trip = gt_char1-atwtb.
        ENDIF.

* 서브프레임용량(B) PD_BD_AMPHERE_FRAME_SUB(desc)
        READ TABLE gt_char1 WITH KEY atnam = 'PD_BD_AMPHERE_FRAME_SUB'.
        IF sy-subrc = 0.
          lt_qlist-frame_sub = gt_char1-atwtb.
        ENDIF.

* 서브차단기극수(B) PD_BD_POLE_CNT_SUB(desc)
        READ TABLE gt_char1 WITH KEY atnam = 'PD_BD_POLE_CNT_SUB'.
        IF sy-subrc = 0.
          lt_qlist-pole_sub = gt_char1-atwtb.
        ENDIF.

* 서브차단기모델(B) PD_BD_BREAKER_MODEL_SUB(desc)
        READ TABLE gt_char1 WITH KEY atnam = 'PD_BD_BREAKER_MODEL_SUB'.
        IF sy-subrc = 0.
          lt_qlist-brea_sub = gt_char1-atwtb.
        ENDIF.

* 서브트립용량(B)   PD_BD_AMPHERE_TRIP_SUB(desc)
        READ TABLE gt_char1 WITH KEY atnam = 'PD_BD_AMPHERE_TRIP_SUB'.
        IF sy-subrc = 0.
          lt_qlist-trip_sub = gt_char1-atwtb.
        ENDIF.

* 회로수(B)         PD_BD_CIRCUIT_CNT(desc)
        READ TABLE gt_char1 WITH KEY atnam = 'PD_BD_CIRCUIT_CNT'.
        IF sy-subrc = 0.
          lt_qlist-circuit = gt_char1-atwtb.
        ENDIF.

* 회로당차단기수(B) PD_BD_CIRCUIT_PER_MCCB(desc)
        READ TABLE gt_char1 WITH KEY atnam = 'PD_BD_CIRCUIT_PER_MCCB'.
        IF sy-subrc = 0.
          lt_qlist-circuit_per = gt_char1-atwtb.
        ENDIF.

* N상구분(C/D)       PD_BD_N_WIRE_TYPE
        READ TABLE gt_char1 WITH KEY atnam = 'PD_NBD_CM_NT'.
        IF sy-subrc = 0.
          lt_qlist-wire_type = gt_char1-atwrt.
        ENDIF.
      ENDIF.

    ENDIF.

    IF lt_qlist-prod_cd EQ '30' OR
       lt_qlist-prod_cd EQ '31' .
      lt_qlist-gp_flag = 'A'.
      lv_ph_chk = 'A'.

    ELSEIF lt_qlist-prod_cd EQ '20' OR
           lt_qlist-prod_cd EQ '21' OR
           lt_qlist-prod_cd EQ '22' OR
           lt_qlist-prod_cd EQ '23' OR
           lt_qlist-prod_cd EQ'24' .
      lt_qlist-gp_flag = 'B'.
      lv_ph_chk = 'B'.

    ELSEIF lt_qlist-prod_cd EQ '62'.
      lt_qlist-gp_flag = 'C'.
      lv_ph_chk = 'C'.

    ELSEIF lt_qlist-prod_cd EQ '60' OR
           lt_qlist-prod_cd EQ '61' OR
           lt_qlist-prod_cd EQ '63' OR
           lt_qlist-prod_cd EQ '64' OR
           lt_qlist-prod_cd EQ '65' OR
           lt_qlist-prod_cd EQ '66' OR
           lt_qlist-prod_cd EQ '67' OR
           lt_qlist-prod_cd EQ '68' OR
           lt_qlist-prod_cd EQ '69' OR
           lt_qlist-prod_cd EQ '32' OR
           lt_qlist-prod_cd EQ '84' .
      lt_qlist-gp_flag = 'E'.
      lv_ph_chk = 'E'.

    ELSEIF lt_qlist-prod_cd IS INITIAL.
      lt_qlist-gp_flag = 'F'.
      lv_ph_chk = 'F'.

    ELSE.
      lt_qlist-gp_flag = 'D'.
      lv_ph_chk = 'D'.
    ENDIF.

    DATA: lv_lfimg LIKE lips-lfimg.
    DATA: lv_lfimg_1 LIKE lips-lfimg.

    CLEAR: lv_lfimg, lv_lfimg_1.
    SELECT COUNT( * ) SUM( lfimg )
      INTO  (lv_charg_cnt, lv_lfimg)
      FROM lips
     WHERE vbeln = lt_qlist-vbeln
       AND uecha = lt_qlist-posnr .

    IF NOT lt_qlist-charg IS INITIAL.
      lv_charg_cnt = lv_charg_cnt + 1.
    ELSE.
      SELECT SINGLE charg INTO lt_qlist-charg
        FROM lips
       WHERE vbeln = lt_qlist-vbeln
         AND uecha = lt_qlist-posnr.
    ENDIF.
    lt_qlist-lfimg = lt_qlist-lfimg + lv_lfimg.

*/ 배치특성
    PERFORM get_batch_characteristic
              USING lt_qlist-matnr
                       lt_qlist-charg
         CHANGING lt_qlist-length
                       lv_packg
                       lv_packc.
* 싱글 유닛배치는 납품수량이 조장
    CLEAR mch1.
    SELECT SINGLE xpcbt INTO mch1-xpcbt FROM mch1
                       WHERE matnr EQ lt_qlist-matnr
                         AND charg EQ lt_qlist-charg.
    IF mch1-xpcbt = 'X'.
      IF NOT lv_charg_cnt IS INITIAL.
        lt_qlist-length = lt_qlist-lfimg / lv_charg_cnt.
      ENDIF.
    ENDIF.

    IF lt_qlist-length > 0.
      IF lt_qlist-meins <> lt_qlist-vrkme.
*       기본단위와 판매단위가 상이할때
        lt_qlist-length = lt_qlist-length * lt_qlist-umvkn
                          / lt_qlist-umvkz.
      ENDIF.
    ENDIF.

    lv_length_c = lt_qlist-length.
    CONDENSE lv_length_c.

    lv_length_so_c = lt_qlist-length_so.
    CONDENSE lv_length_so_c.

    IF NOT lt_qlist-length IS INITIAL.
      lv_list_packc = lt_qlist-lfimg / lt_qlist-length.
    ENDIF.

    IF lv_length_c <> lv_length_so_c.
      lt_qlist-diff = 'X'.
      CLEAR : lv_factor.
      IF NOT lt_qlist-length IS INITIAL.
        lv_factor = lt_qlist-lfimg / lt_qlist-length.
        lv_list_packc = lv_factor.
*        CONDENSE lv_list_packc.
      ENDIF.
    ENDIF.

    IF mch1-xpcbt <> 'X'.  "MKJANG
      lv_lfimg_1 = lv_list_packc * lt_qlist-length.
* FACTOR BATCH 중 LIPS한건 불러온게 마침 주문조장과 같아버렸을때.
      IF lv_lfimg_1 <> lv_lfimg.
        lt_qlist-diff = 'X'.
      ENDIF.
    ENDIF.

*/ 납품처
    DATA: lv_adrnr  LIKE vbpa-adrnr.
    SELECT SINGLE adrnr INTO lv_adrnr FROM vbpa
      WHERE vbeln = lt_qlist-vbeln
        AND posnr = '000000'
        AND parvw = 'WE'.
    SELECT SINGLE name1 INTO lt_qlist-kunnr_t FROM adrc
      WHERE addrnumber = lv_adrnr.

* [START] CSR NO : C20070706_94350

*/ 판매처
    DATA: lv_adrnr1  LIKE vbpa-adrnr.
    SELECT SINGLE adrnr INTO lv_adrnr1 FROM vbpa
      WHERE vbeln = lt_qlist-vbeln
        AND posnr = '000000'
        AND parvw = 'SP'.
    SELECT SINGLE name1 INTO lt_qlist-kunag_t FROM adrc
      WHERE addrnumber = lv_adrnr1.

* [END]   CSR NO : C20070706_94350

*/ 운송대행업체
    IF NOT lt_qlist-tdlnr IS INITIAL.
      SELECT SINGLE name1 INTO lt_qlist-tdlnr_t FROM lfa1
        WHERE lifnr = lt_qlist-tdlnr.
    ENDIF.

    lt_qlist-icon = gv_nr.
    APPEND lt_qlist.

  ENDLOOP.

*-- 판매오더 견적품 Mapping 정보 추가 구성 2025.02.11 - Start
  PERFORM get_so_mapping_data       TABLES   lt_qlist
                                             pt_qlist.

  IF p_bzarea = '5000' AND r_tknum = 'X'.
    SORT pt_qlist BY vbeln posnr vgbel vgpos.
    DELETE ADJACENT DUPLICATES FROM pt_qlist
                               COMPARING vbeln posnr vgbel vgpos.
  ENDIF.

*-- 판매오더 견적품 Mapping 정보 추가 구성 2025.02.11 - End

* CSR번호: C2006080801000000252 다중배차시 거래명세서 발행수정
* 수정일 : 20060808 수정자: Koo Bon-Chan
*  IF p_bzarea = '5000' AND r_tknum = 'X'.
*    SORT pt_list BY vbeln posnr.
*    DELETE ADJACENT DUPLICATES FROM pt_list COMPARING vbeln posnr.
*  ENDIF.
* 수정완료


ENDFORM.                    " DATA_MODIFY
*&---------------------------------------------------------------------*
*&      Module  status_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

*  DATA: s_func(20) OCCURS 0 WITH HEADER LINE.
*
*  IF r01 = 'X' .
*    s_func = 'REVERSE'.
*    APPEND s_func.
*    SET TITLEBAR 'R01'.
*  ENDIF.
*
*  IF r02 = 'X' .
*    s_func = 'REVERSE'.
*    APPEND s_func.
*    SET TITLEBAR 'R02'.
*  ENDIF.
*
*  IF r03 = 'X'.
*    s_func = 'PREVIEW'.
*    APPEND s_func.
*    s_func = 'PRINT'.
*    APPEND s_func.
*
*    SET TITLEBAR 'R03'.
*  ENDIF.
*
*  SET PF-STATUS '100' EXCLUDING s_func.

ENDMODULE.                 " status_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  init  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init OUTPUT.

*  IF r03 = 'X' OR r_tknum = 'X'.
*    LOOP AT SCREEN .
*      IF screen-name = 'WA-DRIVER_NM' OR
*         screen-name = 'WA-TRUCK_NO'  OR
*         screen-name = 'WA-DRIVER_TELNO' .
*        screen-input = 0.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

*  DESCRIBE TABLE gt_list LINES tc01-lines.
*
*  CLEAR: ok_code.

ENDMODULE.                 " init  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_100 OUTPUT.

  DATA: wa_cols  LIKE LINE OF tc01-cols.

*/ 신규발행일때, 거래명세서 번호 INACTIVE
  IF r01 = 'X'.
    LOOP AT tc01-cols INTO wa_cols
      WHERE screen-name = 'GT_LIST-IV_NO'.
      wa_cols-invisible = '1'.
      MODIFY tc01-cols FROM wa_cols INDEX sy-tabix.
    ENDLOOP.
  ENDIF.

*/ 납품문서 기준일때,
*  선적번호, 차량번호 INACTIVE
  IF r_vbeln = 'X'.
    LOOP AT tc01-cols INTO wa_cols
      WHERE ( screen-name = 'GT_LIST-TKNUM' OR
              screen-name = 'GT_LIST-EXTI1' ).
      wa_cols-invisible = '1'.
      MODIFY tc01-cols FROM wa_cols INDEX sy-tabix.
    ENDLOOP.
  ENDIF.


ENDMODULE.                 " PBO_100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE ok_code.
    WHEN 'CHK'.
      PERFORM mark_chk_tknum.

    WHEN 'PREVIEW'.   "미리보기
      CLEAR: gv_print.
      PERFORM preview.

    WHEN 'PRINT'.     "발행
      PERFORM pop_up_confirm(zler0004)
           USING '< 거래명세서 발행여부확인 >'
                 '발행하시겠습니까?'
         CHANGING lv_return.
      CHECK lv_return = 'J'.
      CLEAR lv_return.

      gv_print = 'X'.
      PERFORM iv_print.

    WHEN 'REVERSE'.   "거래명세서 취소
      PERFORM cancel_iv.

    WHEN 'ASEL'.
      PERFORM all_select USING 'A'.

    WHEN 'DSEL'.
      PERFORM all_select USING 'D'.

    WHEN 'ASORT' OR 'DSORT'.
      PERFORM sort .

    WHEN 'REFR'.
      PERFORM selection .

*___미부착부품 리스트 관리 - Start 2006.06.13
    WHEN 'ACSR'.
      PERFORM call_zler0600.
*___미부착부품 리스트 관리 - End   2006.06.13
  ENDCASE.

ENDMODULE.                 " user_command_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_command  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR '%EX' OR 'RW'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " exit_command  INPUT
*&---------------------------------------------------------------------*
*&      Form  GET_BATCH_CHARACTERISTIC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_LIST_MATNR  text
*      -->P_PT_LIST_CHARG  text
*      <--P_PT_LIST_LENGTH  text
*      <--P_PT_LIST_PACKG  text
*      <--P_PT_LIST_PACKC  text
*----------------------------------------------------------------------*
FORM get_batch_characteristic  USING    p_matnr
                                        p_charg
                               CHANGING p_length
                                        p_packg
                                        p_packc.

  DATA: BEGIN OF lt_atinn OCCURS 0,
          atinn TYPE atinn,
          atnam TYPE atnam,
        END   OF lt_atinn.
  DATA: l_objek TYPE objnum,
        l_objno TYPE cuobj,
        objek   TYPE objnum.
  DATA: lt_ausp LIKE ausp OCCURS 0 WITH HEADER LINE.

  DATA: lv_value(13) TYPE p DECIMALS 3.

  SELECT DISTINCT atinn atnam INTO TABLE lt_atinn
  FROM   cabn
  WHERE  atnam = ba_length         "조장
     OR  atnam = ba_factor         "조장수
     OR  atnam = ba_packaging      "포장재
     OR  atnam = ba_packaging_cat  "포장재유형
     OR  atnam = ba_color.         "색상

  CLEAR: l_objek.
  CONCATENATE p_matnr p_charg INTO l_objek.

  CALL FUNCTION 'CUOB_GET_NUMBER'
    EXPORTING
      class_type       = '023'
*-> CCM 2023.04.13 오바다 - CUOBN사용
      object_id        = CONV cuobn( l_objek )
*<- CCM 2023.04.13 오바다
      table            = 'MCH1'
    IMPORTING
      object_number    = l_objno
    EXCEPTIONS
      lock_problem     = 1
      object_not_found = 2
      OTHERS           = 3.

  IF sy-subrc = 0.
    objek = l_objno.
    CLEAR: lt_ausp, lt_ausp[].
    SELECT * INTO TABLE lt_ausp
    FROM   ausp
     FOR ALL ENTRIES IN lt_atinn
    WHERE  objek = objek
      AND  atinn = lt_atinn-atinn
      AND  klart = '023'.

    IF sy-subrc = 0.
      LOOP AT lt_atinn.
* 조장
        IF lt_atinn-atnam = ba_length.
          CLEAR lt_ausp.
          READ TABLE lt_ausp WITH KEY atinn = lt_atinn-atinn.

          IF lt_ausp-atflv > 0.
            lv_value = lt_ausp-atflv.
            p_length = lv_value.
          ENDIF.
* 포장재
        ELSEIF lt_atinn-atnam = ba_packaging.
          CLEAR lt_ausp.
          READ TABLE lt_ausp WITH KEY atinn = lt_atinn-atinn.
          p_packg = lt_ausp-atwrt.
* 포장재 유형
        ELSEIF lt_atinn-atnam = ba_packaging_cat.
          CLEAR lt_ausp.
          READ TABLE lt_ausp WITH KEY atinn = lt_atinn-atinn.
          p_packc = lt_ausp-atwrt.
**       색상
*        elseif lt_atinn-atnam = ba_color.
*          clear lt_ausp.
*          read table lt_ausp with key atinn = lt_atinn-atinn.
*          p_color = lt_ausp-atwrt.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_BATCH_CHARACTERISTIC
*&---------------------------------------------------------------------*
*&      Form  MARK_CHK_TKNUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mark_chk_tknum .

  i_cursor_line = tc01-current_line + i_cursor_line - 1.
  READ TABLE gt_qlist INDEX i_cursor_line.

* 선적문서 중 출고전기가 안된건이 포함되어 있고,
* 동일한 출하지점이면, 메세지...
  IF r03 <> 'X'. " 취소일때는 체크하지 않는다.
    DATA: lv_cnt TYPE i.

*-> CCM : 2023.04.18 ZITCS4HDEV01 - VBUK -> LIKP로 수정
    SELECT SINGLE u~mandt INTO sy-mandt
      FROM vttp AS p
      INNER JOIN likp AS u
        ON p~vbeln = u~vbeln
     WHERE p~tknum = gt_qlist-tknum
       AND u~wbstk <> 'C'.
*<-
    IF sy-subrc = 0.
*-> CCM : 2023.04.18 ZITCS4HDEV01 - VBUK 삭제
      SELECT COUNT( DISTINCT k~vstel ) INTO lv_cnt
        FROM vttp AS p
        INNER JOIN likp AS k
          ON p~vbeln = k~vbeln
       WHERE p~tknum = gt_qlist-tknum.
*<-
      IF lv_cnt = 1.
        MESSAGE i023.  LEAVE SCREEN.
      ENDIF.
    ENDIF.
  ENDIF.
  IF gt_qlist-chk = ' '.
    gt_qlist-chk = 'X'.
  ELSE.
    gt_qlist-chk = ' '.
  ENDIF.

  IF r02 = 'X' OR r03 = 'X'.
    MODIFY gt_qlist TRANSPORTING chk WHERE iv_no = gt_qlist-iv_no.
  ELSE.
*/ 신규발행
    IF r_tknum = 'X'.  "선적문서기준
      MODIFY gt_qlist TRANSPORTING chk WHERE tknum = gt_qlist-tknum.
    ELSE.
      MODIFY gt_qlist TRANSPORTING chk WHERE vbeln = gt_qlist-vbeln.
    ENDIF.
  ENDIF.


ENDFORM.                    " MARK_CHK_TKNUM


*&---------------------------------------------------------------------*
*&      Form  MARK_CHK_TKNUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mark_chk_row USING  i_cursor_line TYPE i.

  READ TABLE gt_qlist INDEX i_cursor_line.
*
*  SELECT SINGLE mandt INTO sy-mandt FROM zlet0005
*   WHERE iv_no = gt_list-iv_no
*     AND out_yn = 'X'.
**    CHECK sy-subrc <> 0.
*  IF sy-subrc = 0.
*    MESSAGE i000 WITH '통문확정 취소후 발행취소하세요.'.
*    LEAVE SCREEN.
*  ENDIF.

* 선적문서 중 출고전기가 안된건이 포함되어 있고,
* 동일한 출하지점이면, 메세지...
  IF r03 <> 'X'. " 취소일때는 체크하지 않는다.
    DATA: lv_cnt TYPE i.

*-> CCM : 2023.04.18 ZITCS4HDEV01 - VBUK -> LIKP로 수정
*    SELECT SINGLE U~MANDT INTO SY-MANDT
*      FROM VTTP AS P
*      INNER JOIN VBUK AS U
*        ON P~VBELN = U~VBELN
*     WHERE P~TKNUM = GT_LIST-TKNUM
*       AND U~WBSTK <> 'C'.
    SELECT SINGLE u~mandt INTO sy-mandt
      FROM vttp AS p
      INNER JOIN likp AS u
        ON p~vbeln = u~vbeln
     WHERE p~tknum = gt_qlist-tknum
       AND u~wbstk <> 'C'.
*<-
    IF sy-subrc = 0.
*-> CCM : 2023.04.18 ZITCS4HDEV01 - VBUK삭제
*      SELECT COUNT( DISTINCT K~VSTEL ) INTO LV_CNT
*        FROM VTTP AS P
*        INNER JOIN VBUK AS U
*          ON P~VBELN = U~VBELN
*        INNER JOIN LIKP AS K
*          ON U~VBELN = K~VBELN
*       WHERE P~TKNUM = GT_LIST-TKNUM.
      SELECT COUNT( DISTINCT k~vstel ) INTO lv_cnt
        FROM vttp AS p
        INNER JOIN likp AS k
          ON p~vbeln = k~vbeln
       WHERE p~tknum = gt_qlist-tknum.
*<-
      IF lv_cnt = 1.
        MESSAGE i023.  LEAVE SCREEN.
      ENDIF.
    ENDIF.
  ENDIF.
  IF gt_qlist-chk = ' '.
    gt_qlist-chk = 'X'.
    gt_qlist-icon = gv_ok.
  ELSE.
    gt_qlist-chk = ' '.
    gt_qlist-icon = gv_nr.
  ENDIF.

  IF r02 = 'X' OR r03 = 'X'.
    MODIFY gt_qlist TRANSPORTING chk  icon
                    WHERE iv_no = gt_qlist-iv_no.
  ELSE.
*/ 신규발행
    IF r_tknum = 'X'.  "선적문서기준
      MODIFY gt_qlist TRANSPORTING chk icon
                      WHERE tknum = gt_qlist-tknum.
    ELSE.
      MODIFY gt_qlist TRANSPORTING chk icon
                      WHERE vbeln = gt_qlist-vbeln.
    ENDIF.
  ENDIF.


ENDFORM.                    " MARK_CHK_TKNUM
*&---------------------------------------------------------------------*
*&      Module  set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor OUTPUT.

  SET CURSOR FIELD g_cursor_field LINE i_cursor_line.

ENDMODULE.                 " set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor INPUT.

  CLEAR: g_cursor_field, i_cursor_line.
  GET CURSOR FIELD g_cursor_field LINE i_cursor_line.

ENDMODULE.                 " get_cursor  INPUT
*&---------------------------------------------------------------------*
*&      Form  preview
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM preview .

  CALL SCREEN 300.

ENDFORM.                    " preview
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.

  SET PF-STATUS '300'.
*  SET TITLEBAR 'xxx'.

  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.

*/ 납품처가 다르면, 다른 페이지에 찍는다.
  PERFORM iv_print.


ENDMODULE.                 " STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  iv_print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM iv_print .
  DATA : lv_docno(30),
         lv_ivno    LIKE zlet0005-iv_no.

*{ 2014031100034 스크랩 출하시 계산서 발행 후 가능토록 제어
  DATA: lv_flag.

  CLEAR : lv_flag.
*} 2014031100034

*/ DATA MOVE
  REFRESH: gt_prnt, gt_vl.
  CLEAR  : gt_prnt, gt_vl.
  REFRESH: lv_sm01, lv_sm02, lv_sm03, otf.
  CLEAR  : lv_sm01, lv_sm02, lv_sm03, otf.

  LOOP AT gt_qlist WHERE chk = 'X'.
*___납품문서/품목, 선적문서로 발생한 거래명세서가 존재하면 에러
    IF r01 = 'X'.           "신규발행시
      SELECT SINGLE a~iv_no
        INTO lv_ivno
        FROM zlet0006 AS a
       INNER JOIN zlet0005 AS b
          ON a~iv_no = b~iv_no
       WHERE a~vbeln        =  gt_qlist-vbeln
         AND a~posnr        =  gt_qlist-posnr
         AND a~tknum        =  gt_qlist-tknum
         AND b~iv_cancel_yn <> 'X'.

      IF sy-subrc = 0.
        CONCATENATE gt_qlist-vbeln '-' gt_qlist-posnr '/' gt_qlist-tknum
               INTO lv_docno.

        MESSAGE e398(00) WITH '납품문서-품목/선적문서' lv_docno
                          '로 거래명세서가 이미 발행되었습니다.'
                          '점검 후 발행하시기 바랍니다.'.
      ENDIF.
    ENDIF.

*{ 2014031100034 스크랩 출하시 계산서 발행 후 가능토록 제어
    PERFORM check_billing_status USING lv_flag.
    IF lv_flag IS NOT INITIAL.
      EXIT.
    ENDIF.
*} 2014031100034

    MOVE-CORRESPONDING gt_qlist  TO gt_prnt.
    APPEND gt_prnt.
  ENDLOOP.

*{ 2014031100034 스크랩 출하시 계산서 발행 후 가능토록 제어
  CHECK lv_flag IS INITIAL.
*} 2014031100034

  REFRESH: gt_item, izlet0005, izlet0006.
  CLEAR  : gt_item, izlet0005, izlet0006.

  SORT gt_prnt.
*/ 납품처별로 발행한다.
  LOOP AT gt_prnt.
    gt_vl-vbeln = gt_prnt-vbeln.
    COLLECT gt_vl.

    MOVE-CORRESPONDING gt_prnt  TO gt_item.
    APPEND gt_item.

    CLEAR: gv_flag, gv_iv_no.
    AT END OF kunnr_t.
      gv_flag = 'X'.
    ENDAT.

* [START] CSR NO : C20070706_94350

*/ 판매처별로 발행한다.
    AT END OF kunag_t.
      gv_flag = 'X'.
    ENDAT.

* [END]   CSR NO : C20070706_94350

    IF gv_flag = 'X'.
      REFRESH: lv_sm01, lv_sm02, lv_sm03.
      CLEAR  : lv_sm01, lv_sm02, lv_sm03.

      IF gv_print = 'X'.
        IF r01 = 'X'.
*/ 거래명세서 번호 채번: 신규발행/SY-UCOMM:'PRINT'
          PERFORM invoice_no_create USING 'ZLE001' '05'
                                 CHANGING gv_iv_no.
        ELSE.
          gv_iv_no = gt_prnt-iv_no.
        ENDIF.
      ELSE.       "미리보기
        IF r01 = 'X'.
        ELSE.
          gv_iv_no = gt_prnt-iv_no.
        ENDIF.
      ENDIF.

*/ SAVE PREPARE
* 헤더 테이블
      PERFORM prepare_header_data.
* 아이템 테이블
      PERFORM prepare_item_data.

*/ GET MAIN   DATA
      PERFORM get_main_data.

*___미부착부품 리스트 관리 - Start 2006.06.13
      PERFORM prepare_accessory_data.
*___미부착부품 리스트 관리 - Start 2006.06.13

*/ GET HEADER DATA
      PERFORM get_header_data.

*/ GET MIDDLE DATA
      PERFORM get_middle_data.

**/ GET MAIN   DATA
*     PERFORM get_main_data.

*/ SMARTFORM SET
      PERFORM smart_form_setting.

      REFRESH: gt_vl.  CLEAR: gt_vl.
      REFRESH: gt_item. CLEAR: gt_item.

    ENDIF.

  ENDLOOP.

  PERFORM smart_form_finall_write.

ENDFORM.                    " iv_print
*&---------------------------------------------------------------------*
*&      Form  invoice_no_create
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1130   text
*      -->P_1131   text
*      <--P_LV_IVNO  text
*----------------------------------------------------------------------*
FORM invoice_no_create  USING p_objt p_range
                     CHANGING p_number.

* I/V NO 를 Unique 하게 생성한다.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = p_range
      object      = p_objt
    IMPORTING
      number      = p_number.


ENDFORM.                    " invoice_no_create
*&---------------------------------------------------------------------*
*&      Form  GET_HEADER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_header_data .

  DATA: lv_adrnr  LIKE vbpa-adrnr.
  DATA: lv_postal     LIKE adrc-post_code1,
        lv_city1      LIKE adrc-city1,
        lv_street     LIKE adrc-street,
        lv_extension2 LIKE adrc-extension2,
        lv_tel_number LIKE adrc-tel_number,
        lv_mobile_tel LIKE adr2-tel_number,
        lv_adres(100),
*___미부착부품 리스트 관리 - Start 2006.06.13
        lv_cnt03      TYPE i,
        lv_cnt04      TYPE i.
*___미부착부품 리스트 관리 - End   2006.06.13

  DATA: mok TYPE i,
        nam TYPE i.

  REFRESH: lv_sm01.   CLEAR: lv_sm01.

* Page total 값
*  DESCRIBE TABLE gt_item LINES sy-tfill.
*___미부착부품 리스트 관리 변경 - Start 2006.06.13
  CLEAR : lv_cnt03, lv_cnt04.

  DESCRIBE TABLE lv_sm03 LINES lv_cnt03.
  DESCRIBE TABLE lv_sm04 LINES lv_cnt04.

  lv_cnt03 = lv_cnt03 + lv_cnt04.
  mok = lv_cnt03 DIV 10.
  nam = lv_cnt03 MOD 10.

*  DESCRIBE TABLE lv_sm03 LINES sy-tfill.
*  mok = sy-tfill DIV 10.
*  nam = sy-tfill MOD 10.
*___미부착부품 리스트 관리 변경 - End   2006.06.13
  IF NOT nam IS INITIAL.
    lv_sm01-totnt = mok + 1.
  ELSE.
    lv_sm01-totnt = mok.
  ENDIF.
  CONDENSE lv_sm01-totnt.

* 회사주소
*{ 2014031100058 거래명세서의 공급자란 회사명/주소 정보 수정
  SELECT SINGLE address
    INTO lv_sm01-wname
    FROM zlet0121 AS a
   INNER JOIN t001k AS b
      ON a~bukrs   = b~bukrs
   WHERE b~bwkey   = gt_prnt-werks
     AND a~zbzarea = p_bzarea.

  IF sy-subrc <> 0.
    SELECT SINGLE address
      INTO lv_sm01-wname
      FROM zlet0121
     WHERE zbzarea = p_bzarea.
  ENDIF.

*  CLEAR: t001w.
*  SELECT SINGLE * FROM t001w WHERE werks = gt_prnt-werks.
*  CONCATENATE t001w-ort01 t001w-stras
*     INTO lv_sm01-wname SEPARATED BY space.

* 회사명
*{ 2014030700032 거래명세서의 공급자란 대표자 정보 수정 요청
  SELECT SINGLE repres
                kr_butxt
    INTO (lv_sm01-ceonm, lv_sm01-compa)
    FROM zlet0122
   WHERE werks  = gt_prnt-werks.


  IF lv_sm01-ceonm IS INITIAL AND sy-subrc <> 0.
    SELECT SINGLE a~repres
                  a~kr_butxt
      INTO (lv_sm01-ceonm, lv_sm01-compa)
      FROM zlet0120 AS a
     INNER JOIN t001k AS b
        ON a~bukrs  = b~bukrs
     WHERE b~bwkey  = gt_prnt-werks
       AND a~zmodul = 'LE'.
  ENDIF.

  CONCATENATE '대표이사' lv_sm01-ceonm
         INTO lv_sm01-ceonm SEPARATED BY space.

*  IF gt_prnt-werks+0(1) = '2'.
*    lv_sm01-compa = 'JS전선(주)'.
*    lv_sm01-ceonm = '대표이사 황순철'.
*  ELSE.
*    lv_sm01-compa = 'LS전선(주)'.
*    lv_sm01-ceonm = '대표이사 구자열'.
*  ENDIF.
*} 2014030700032
*} 2014031100058

* 전화번호
  CLEAR: zlet0034.
  SELECT SINGLE * FROM zlet0034 WHERE werks = gt_prnt-werks.
  lv_sm01-cotel = zlet0034-telno.

* 상호
  SELECT SINGLE name1 INTO lv_sm01-gname FROM kna1
    WHERE kunnr = gt_prnt-kunag.

* 납품처주소
  CLEAR: lv_adrnr, lv_postal, lv_city1,lv_mobile_tel,
         lv_street, lv_adres, lv_extension2, lv_tel_number.

  SELECT SINGLE adrnr INTO lv_adrnr
     FROM vbpa
    WHERE vbeln = gt_prnt-vbeln
      AND posnr = '000000'
      AND parvw = 'WE'.
  SELECT SINGLE name1 post_code1 city1 street extension2
       tel_number
     INTO (lv_sm01-rname, lv_postal,
           lv_city1, lv_street, lv_extension2, lv_tel_number)
     FROM adrc
    WHERE addrnumber = lv_adrnr.

  SELECT SINGLE tel_number
     INTO lv_mobile_tel
     FROM adr2
    WHERE addrnumber = lv_adrnr
      AND r3_user    = '3'.

  CONCATENATE lv_postal lv_city1 lv_street INTO lv_adres
     SEPARATED BY space.

  lv_sm01-raddr = lv_adres.
* 인수자: 제품수령인+전화번호 + (휴대전화 추가mkjang)
  CONCATENATE lv_extension2 lv_tel_number 'HP:' lv_mobile_tel
         INTO lv_sm01-ruser
     SEPARATED BY space.

* 통문유형
  IF gt_prnt-iv_type = 'NL'.
    lv_sm01-ivtyp = 'A02 사업장간 이동'.
  ELSE.
    IF gt_prnt-vsart = '09'.
      lv_sm01-ivtyp = 'A01 제상품매출-직납'.
    ELSE.
      lv_sm01-ivtyp = 'A01 제상품매출'.
    ENDIF.
  ENDIF.

* 거래명세서 출력일자
  IF r01 = 'X'.
    CONCATENATE sy-datum+0(4) '년' sy-datum+4(2) '월' sy-datum+6(2) '일'
                INTO lv_sm01-ivdat.

  ELSE.
    CONCATENATE gt_prnt-iv_date+0(4) '년' gt_prnt-iv_date+4(2)
                '월' gt_prnt-iv_date+6(2) '일'
                INTO lv_sm01-ivdat.
  ENDIF.

* 거래명세서 출력일자
  CONCATENATE sy-datum+0(4) '년' sy-datum+4(2) '월' sy-datum+6(2)
              '일' sy-uzeit+0(2) ':' sy-uzeit+2(2)
              INTO lv_sm01-ptdat.

* 통문번호
  lv_sm01-ivnum = gv_iv_no.

  APPEND lv_sm01.

ENDFORM.                    " GET_HEADER_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_MIDDLE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_middle_data .

  REFRESH: lv_sm02.  CLEAR lv_sm02.

  CLEAR: vttk.
  SELECT SINGLE * FROM vttk WHERE tknum = gt_prnt-tknum.
* 선적번호
  lv_sm02-tknum = vttk-tknum.

*  CONCATENATE vttk-text1 vttk-text2 vttk-text3
*     INTO lv_sm02-ltext SEPARATED BY space.

* 운임톤수
  SELECT SINGLE bezei INTO lv_sm02-sdabw FROM tvsakt
    WHERE spras = sy-langu
      AND sdabw = vttk-sdabw.

* 운송대행업체
  SELECT SINGLE name1 INTO lv_sm02-tdlnr FROM lfa1
                     WHERE lifnr = vttk-tdlnr.


  IF r02 = 'X'.
    SELECT SINGLE * FROM zlet0005 WHERE iv_no = gv_iv_no.
    wa-truck_no = zlet0005-truck_no.
    wa-driver_nm = zlet0005-driver_nm.
    wa-driver_telno = zlet0005-driver_telno.
  ENDIF.

* 차량번호
  IF wa-truck_no IS INITIAL.
    lv_sm02-exti1 = vttk-exti1.
  ELSE.
    lv_sm02-exti1 = wa-truck_no.
  ENDIF.

* 운전기사명
  CLEAR: gv_driver, gv_telno.
  IF wa-driver_nm IS INITIAL.
    gv_driver = vttk-exti2.
  ELSE.
    gv_driver = wa-driver_nm.
  ENDIF.

* 운전기사 전화번호
  IF wa-driver_telno IS INITIAL.
    gv_telno = vttk-tpbez.
  ELSE.
    gv_telno = wa-driver_telno.
  ENDIF.

  CONCATENATE gv_driver '(' gv_telno ')' INTO lv_sm02-exti2.

* 영업그룹
  SELECT SINGLE bezei INTO lv_sm02-vkgrp FROM tvgrt
                     WHERE spras = sy-langu
                       AND vkgrp = gt_prnt-vkgrp.

* 영업팀
  SELECT SINGLE bezei INTO lv_sm02-vkbur FROM tvkbt
                     WHERE spras = sy-langu
                       AND vkbur = gt_prnt-vkbur.

* 선적유형
  SELECT SINGLE bezei INTO lv_sm02-bezei FROM tvtkt
                     WHERE spras = sy-langu
                       AND shtyp = vttk-shtyp.

* 서비스레벨
  IF vttk-bfart <> ' '.
    IF vttk-bfart = '1'.
      lv_sm02-bfart = '일반'.
    ELSEIF vttk-bfart = '2'.
      lv_sm02-bfart = '반입조건'.
    ELSEIF vttk-bfart = '3'.
      lv_sm02-bfart = '왕복조건'.
    ELSE.
      lv_sm02-bfart = '긴급배송'.
    ENDIF.
  ENDIF.

* 컨테이너 아이디
  lv_sm02-signi = vttk-signi.

* 070109 Bon-Chan Koo
* 선적 텍스트의 운송업자오더의 텍스트 내역을 거래명세서의
* 특기사항으로 발행 처리함(변상일 과장님 요청)
  DATA  : ls_thead    LIKE thead.
  DATA  : lt_long     TYPE tline OCCURS 0 WITH HEADER LINE.
  DATA  : lv_docno    LIKE  thead-tdname.

  lv_docno = vttk-tknum.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = '0001'
      language                = sy-langu
      name                    = lv_docno
      object                  = 'VTTK'
    IMPORTING
      header                  = ls_thead
    TABLES
      lines                   = lt_long
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  IF sy-subrc = 0.
    LOOP AT lt_long.
      lv_sm02-ltext = lt_long-tdline.
    ENDLOOP.
  ENDIF.

* 070109 수정완료

  APPEND lv_sm02.


ENDFORM.                    " GET_MIDDLE_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_MAIN_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_main_data .

  REFRESH: gt_rprt. CLEAR: gt_rprt.

*/ 제품별 합계
  IF g01 = 'X'.
    LOOP AT gt_item.
      PERFORM data_move_g01.
      COLLECT gt_rprt. CLEAR: gt_rprt.
    ENDLOOP.
  ENDIF.

*/ 조장별 합계
  IF g02 = 'X'.
    CLEAR gt_item.

    LOOP AT gt_item.
      MOVE gt_item-gp_flag TO gt_rprt-gp_flag.
****[START] C20091118_62117
****DELETED LINES***************************
*      IF gt_rprt-gp_flag = 'G'.
*        MOVE gt_item-prdid TO gt_rprt-prdid.
*        MOVE gt_item-prod TO  gt_rprt-prod.
*        MOVE gt_item-volt TO  gt_rprt-volt.
*        MOVE gt_item-wire TO  gt_rprt-wire.
*        MOVE gt_item-gnd TO   gt_rprt-gnd.
*        MOVE gt_item-amp TO   gt_rprt-amp.
*        MOVE gt_item-cond TO  gt_rprt-cond.
*        MOVE gt_item-duct TO  gt_rprt-duct.
*        MOVE gt_item-ipdeg TO gt_rprt-ipdeg.
*      ELSEIF  gt_rprt-gp_flag = 'P'.
*        MOVE gt_item-prod  TO gt_rprt-prod.
*        MOVE gt_item-pole  TO gt_rprt-pole.
*        MOVE gt_item-wire  TO gt_rprt-wire.
*        MOVE gt_item-brea  TO gt_rprt-brea.
*        MOVE gt_item-frame TO gt_rprt-frame.
*        MOVE gt_item-trip  TO gt_rprt-trip.
*      ELSEIF  gt_rprt-gp_flag = 'N'.
*        MOVE gt_item-prod  TO gt_rprt-prod.
*      ENDIF.
****DELETED LINES***************************
****[END] C20091118_62117


****[START] C20091118_62117
****CREATED LINES***************************
      IF gt_rprt-gp_flag = 'A'.
        MOVE gt_item-prod_cd TO gt_rprt-prod_cd.
        MOVE gt_item-prod TO gt_rprt-prod.
        MOVE gt_item-brea TO gt_rprt-brea.
        MOVE gt_item-pole TO gt_rprt-pole.
        MOVE gt_item-frame TO gt_rprt-frame.
        MOVE gt_item-trip TO gt_rprt-trip.

      ELSEIF gt_rprt-gp_flag = 'B'.
        MOVE gt_item-prod_cd TO gt_rprt-prod_cd.
        MOVE gt_item-prod  TO gt_rprt-prod.
        MOVE gt_item-pole  TO gt_rprt-pole.
        MOVE gt_item-brea  TO gt_rprt-brea.
        MOVE gt_item-frame  TO gt_rprt-frame.
        MOVE gt_item-trip   TO gt_rprt-trip.
        MOVE gt_item-pole_sub  TO gt_rprt-pole_sub .
        MOVE gt_item-brea_sub  TO gt_rprt-brea_sub .
        MOVE gt_item-frame_sub TO gt_rprt-frame_sub.
        MOVE gt_item-trip_sub  TO gt_rprt-trip_sub.
        MOVE gt_item-circuit   TO gt_rprt-circuit.
        MOVE gt_item-circuit_per  TO gt_rprt-circuit_per.

      ELSEIF gt_rprt-gp_flag = 'C'.

** 선식 계산.[gt_vbap-wire_combine "선식]:내수만 존재
        MOVE gt_item-prod_cd TO gt_rprt-prod_cd.
        MOVE gt_item-prod TO gt_rprt-prod.
        MOVE gt_item-wire TO gt_rprt-wire.
        MOVE gt_item-wire_desc TO gt_rprt-wire_desc.
        MOVE gt_item-wire_type TO gt_rprt-wire_type.
        MOVE gt_item-amp  TO gt_rprt-amp.

      ELSEIF gt_rprt-gp_flag = 'D'.
        MOVE gt_item-prod_cd TO gt_rprt-prod_cd.
        MOVE gt_item-prdid TO gt_rprt-prdid.
        MOVE gt_item-gnd   TO gt_rprt-gnd .
        MOVE gt_item-ipdeg TO gt_rprt-ipdeg.
        MOVE gt_item-volt  TO gt_rprt-volt .
        MOVE gt_item-prod  TO gt_rprt-prod.
        MOVE gt_item-wire_desc TO gt_rprt-wire_desc.
        MOVE gt_item-wire  TO gt_rprt-wire.
        MOVE gt_item-wire_type TO gt_rprt-wire_type.
        MOVE gt_item-amp   TO gt_rprt-amp .
        MOVE gt_item-cond  TO gt_rprt-cond .
        MOVE gt_item-duct  TO gt_rprt-duct .
        MOVE gt_item-ipdeg_name TO gt_rprt-ipdeg_name .

      ELSEIF gt_rprt-gp_flag = 'E'
        OR gt_rprt-gp_flag = 'F'.

*        MOVE gt_item-arktx TO gt_rprt-arktx.
        MOVE gt_item-qname_prnt TO gt_rprt-arktx.
      ENDIF.
****CREATED LINES***************************
****[END] C20091118_62117

      MOVE gt_item-qqty  TO gt_rprt-qqty.
      MOVE gt_item-qunit TO gt_rprt-qunit.


      SELECT SINGLE empst FROM vbkd INTO gt_item-empst
      WHERE  vbeln = gt_item-vgbel  "'5110006229'
      AND    posnr = gt_item-vgpos.                         "'10'.

      IF gt_item-diff = ' '.
        PERFORM data_move_g02.
        COLLECT gt_rprt. CLEAR: gt_rprt.
      ELSE.
*        SELECT * FROM lips WHERE vbeln = gt_item-vbeln
*                             AND uecha = gt_item-posnr.
*          PERFORM data_move_g02_1.
*          COLLECT gt_rprt. CLEAR: gt_rprt.
*        ENDSELECT.
*        IF sy-subrc <> 0.
        PERFORM data_move_g02.
        COLLECT gt_rprt. CLEAR: gt_rprt.
*        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

*/ 포장재별 합계
*  IF g03 = 'X'.
*    LOOP AT gt_item.
*      PERFORM data_move_g03.
*      COLLECT gt_rprt. CLEAR: gt_rprt.
*    ENDLOOP.
*  ENDIF.

*/ 배치별 합계
  IF g04 = 'X'.
    LOOP AT gt_item.
      PERFORM data_move_g04.
*      COLLECT gt_rprt.
    ENDLOOP.
  ENDIF.

  CLEAR: lv_sum.
  LOOP AT gt_rprt.
    lv_sm03-vbeln = gt_rprt-vgbel.
*    lv_sm03-posnr = gt_rprt-vgpos.
*    lv_sm03-maktx = gt_rprt-arktx.

*    lv_sm03-lfimg = gt_rprt-lfimg.
*    lv_sm03-vrkme = gt_rprt-vrkme.

    lv_sm03-lfimg = gt_rprt-qqty.
    lv_sm03-vrkme = gt_rprt-qunit.

*    lv_sm03-assnm = gt_rprt-empst.

*    ADD gt_rprt-factor  TO lv_sum.

    PERFORM get_color.
    IF g02 = 'X'.
*      lv_sm03-maktx = lv_sm03-maktx+0(32).
      PERFORM get_ponum.
    ENDIF.

* [START] CSR NO : C20070703_90974
* 20070710 Bon-Chan Koo
* 발행시 납품문서 기준으로 출력 체크하여
* 배치특성별 조장 합계 선택하는 경우 PO번호에 "주문번호-품목" 출력
* 출하지점 J* 또는 사업장 J*인 건에 대하여 적용
    IF s_vstel-low+0(1) = 'J' AND x_vbeln = 'X'.
      DATA  : lv_vbeln LIKE vbap-vbeln,
              lv_posnr LIKE vbap-posnr.

      CLEAR : lv_sm03-ponum.

      SELECT SINGLE vbelv posnv
      INTO   (lv_vbeln, lv_posnr)
      FROM   vbfa
      WHERE  vbeln = gt_rprt-vgbel
      AND    posnn = gt_rprt-vgpos.

      SHIFT  lv_posnr  LEFT  DELETING  LEADING  '0'.

      CONCATENATE lv_vbeln
                  '/'
                  lv_posnr
                INTO  lv_sm03-ponum.
      CLEAR : lv_vbeln, lv_posnr.
    ENDIF.
* [END]   CSR NO : C20070703_90974

*
** 20061207 Bon-Chan Koo
*    IF s_vstel-low = '7100' OR
*       s_vstel-low = '7200' OR
*       s_vstel-low = '7300'.
*
*      DATA : l_matnr1 LIKE mara-matnr.
*      DATA : l_matnr2 LIKE mara-matnr.
*
*      SELECT SINGLE matnr
*      INTO   l_matnr1
*      FROM   vbap
*      WHERE  vbeln = gt_rprt-vgbel
*      AND    posnr = gt_rprt-vgpos.
*
*      SELECT SINGLE bismt
*      INTO   l_matnr2
*      FROM   mara
*      WHERE  matnr = l_matnr1.
*
*      CONCATENATE l_matnr1+10 ' - ' l_matnr2 INTO lv_sm03-mtext.
*    ENDIF.
** 수정완료

    COLLECT  lv_sm03.
  ENDLOOP.

  SORT lv_sm03 BY vbeln.

*  DATA: BEGIN OF lt_lips OCCURS 0.
*          INCLUDE STRUCTURE lips.
*  DATA: END OF lt_lips.
*
*  CHECK NOT gt_vl[] IS INITIAL.
**/ select ~ lips
*  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_lips
*    FROM lips
*     FOR ALL ENTRIES IN gt_vl
*   WHERE vbeln = gt_vl-vbeln.
*
**/ 발행조건별 데이타 취합.
*  REFRESH: gt_rprt. CLEAR: gt_rprt.
*
*  IF g02 = 'X'.      "조장별 합계 발행
*    LOOP AT lt_lips.
*      gt_rprt-vgbel  = lt_lips-vgbel.
*      gt_rprt-vgpos  = lt_lips-vgpos.
*      gt_rprt-arktx  = lt_lips-arktx.
*      gt_rprt-length = gt_prnt-length.
*      gt_rprt-lfimg  = lt_lips-lfimg.
*      gt_rprt-vrkme  = lt_lips-vrkme.
*      APPEND gt_rprt.
*    ENDLOOP.
*  ENDIF.

ENDFORM.                    " GET_MAIN_DATA
*&---------------------------------------------------------------------*
*&      Form  smart_form_setting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM smart_form_setting .

  DATA: rtab  LIKE kunnr_ran  OCCURS 0 WITH HEADER LINE.
  DATA: ssfcrespd TYPE ssfcrespd,
        ssfcrescl TYPE ssfcrescl,
        ssfcresop TYPE ssfcresop.

  DATA: lv_formname(30).

*  IF g01 = 'X'  AND gt_prnt-iv_type = 'A01'.  "제상품
*    lv_formname = 'Z_LE_TRADE_DOCUMENT_B2'.
*  ELSEIF g02 = 'X'  AND gt_prnt-iv_type = 'A01'
**     AND GT_PRNT-VSTEL = '1400'.
*     AND ( gt_prnt-vstel = '1400' OR
*           gt_prnt-vstel = 'J100').
*    lv_formname = 'Z_LE_TRADE_DOCUMENT_B4'.
*  ELSEIF g02 = 'X'  AND gt_prnt-iv_type = 'A01'.
*    lv_formname = 'Z_LE_TRADE_DOCUMENT_B3'.
*  ELSE.
*    lv_formname = 'Z_LE_TRADE_DOCUMENT_B1'.
*  ENDIF.

  lv_formname = 'Z_LE_TRADE_DOCUMENT_B4'.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lv_formname
    IMPORTING
      fm_name            = func_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  control_parameters-getotf = 'X'.
  control_parameters-no_dialog = 'X'.
** control_parameters-no_close = 'X'.
** control_parameters-getotf = 'X'.
*  CONTROL_PARAMETERS-PREVIEW = 'X'.
*  OUTPUT_OPTIONS-TDDEST = 'ZP01'.
** OUTPUT_OPTIONS-TDPRINTER = 'ZP01'.
*
*  OUTPUT_OPTIONS-TDIMMED = 'X'.
*  OUTPUT_OPTIONS-TDDELETE = 'X'.

  CLEAR: lv_sum_lfimg, lv_unit.
  LOOP AT gt_item.
    IF gt_item-lfart CS 'LR'.  "반품
      gt_item-lfimg     = gt_item-lfimg * -1.
    ELSE.
      gt_item-lfimg     = gt_item-lfimg.
    ENDIF.

*    ADD  gt_item-lfimg   TO lv_sum_lfimg.
*    ADD  gt_item-factor  TO lv_sum.
    ADD  gt_item-qqty   TO lv_sum_lfimg.

    MOVE gt_item-vrkme   TO lv_unit.
  ENDLOOP.

  CLEAR ssfcrescl.

*___미부착부품 리스트 관리 변경 - Start 2006.06.13
  CALL FUNCTION func_name
    EXPORTING
      control_parameters   = control_parameters
      output_options       = output_options
      user_settings        = ' '
      lv_sum               = lv_sum
      lv_sum_lfimg         = lv_sum_lfimg
      lv_unit              = lv_unit
      lv_sm01              = lv_sm01
      lv_sm02              = lv_sm02
    IMPORTING
      document_output_info = ssfcrespd
      job_output_info      = ssfcrescl
      job_output_options   = ssfcresop
    TABLES
      lv_sm03              = lv_sm03
      lv_sm04              = lv_sm04
    EXCEPTIONS
      formatting_error     = 1
      internal_error       = 2
      send_error           = 3
      user_canceled        = 4
      OTHERS               = 5.

*  CALL FUNCTION func_name
*    EXPORTING
*      control_parameters   = control_parameters
*      output_options       = output_options
*      user_settings        = ' '
*      lv_sum               = lv_sum
*      lv_sum_lfimg         = lv_sum_lfimg
*      lv_unit              = lv_unit
*      lv_sm01              = lv_sm01
*      lv_sm02              = lv_sm02
*    IMPORTING
*      document_output_info = ssfcrespd
*      job_output_info      = ssfcrescl
*      job_output_options   = ssfcresop
*    TABLES
*      lv_sm03              = lv_sm03
*    EXCEPTIONS
*      formatting_error     = 1
*      internal_error       = 2
*      send_error           = 3
*      user_canceled        = 4
*      OTHERS               = 5.
*___미부착부품 리스트 관리 변경 - End   2006.06.13

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  INSERT LINES OF ssfcrescl-otfdata INTO TABLE otf.

ENDFORM.                    " smart_form_setting
*&---------------------------------------------------------------------*
*&      Form  smart_form_finall_write
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM smart_form_finall_write .

  DATA: ssfpp                TYPE ssfpp,
        arc_params           TYPE arc_params,
        spool_job_attributes LIKE rspoattr OCCURS 0 WITH HEADER LINE.

  DATA : ls_06 LIKE izlet0006.
  DATA : lv_vsart LIKE likp-vsart.

  ssfpp-tddevice        = 'PRINTER'.
  ssfpp-tdpreview       = 'X'.
  ssfpp-tdpageform      = 'DINA4'.
  ssfpp-tdpages         = '00002'.
  ssfpp-tddriver        = 'SWIN'.
  ssfpp-tdotftype       = 'OTFSWIN'.
  ssfpp-tdforms         = '00001'.
  ssfpp-tdprogram       = 'SAPLSTXBE'.
  IF sy-ucomm = 'PREVIEW'.          "미리보기
    ssfpp-tdnoprint       = 'X'.
    CLEAR: ssfpp-tdscreen, ssfpp-tdscdriver.
  ELSE.                                  "출력
    ssfpp-tdscreen          = 'WN32'.
    ssfpp-tdscdriver        = 'WN32'.
    CLEAR: ssfpp-tdnoprint.
  ENDIF.
  ssfpp-tdarmod         = '1'.
  ssfpp-tddataset       = 'SMART'.
  ssfpp-tdsuffix1       = 'ZP01'.
  ssfpp-tdsuffix2       = sy-uname.
  ssfpp-tddest          = 'ZP01'.
  ssfpp-tdprinter       = 'KPSAPWIN'.
  ssfpp-tdimmed         = 'X'.
  ssfpp-tddelete        = 'X'.
  ssfpp-tdlifetime      = '8'.
  IF wa-print_cnt = 0.
    ssfpp-tdcopies      = '001'.
  ELSEIF wa-print_cnt = 999.
    ssfpp-tdcopies      = '000'.
    ssfpp-tdimmed         = ''.
    ssfpp-tddelete        = ''.
  ELSE.
    ssfpp-tdcopies      = wa-print_cnt.
  ENDIF.

  spool_job_attributes-param    = 'S_COPYMETH'.
  spool_job_attributes-value    = 'COLLATE'.
  APPEND spool_job_attributes.

  IF sy-ucomm = 'PREVIEW'.
*   미리보기 Function
    CALL FUNCTION 'SSFDISPLAY_OTF'
      EXPORTING
        display_parameters = ssfpp
        archive_params     = arc_params
        spoolattr          = spool_job_attributes[]
      IMPORTING
        result             = ssfpp
      TABLES
        otf                = otf
      EXCEPTIONS
        error              = 1.
  ELSE.
*   출력 Function
    CALL FUNCTION 'SSFCOMP_OTF_OUTPUT'
      EXPORTING
        input_params   = ssfpp
        archive_params = arc_params
        otf_data       = otf[]
        bmnopri        = ''
      IMPORTING
        output_params  = ssfpp
      EXCEPTIONS
        error          = 1.

    IF sy-subrc = 0.
*//  < 출력성공 시 DB에 저장 > //
      IF r01 = 'X'.

        LOOP AT izlet0005.
          DELETE FROM zlet0005 WHERE iv_no = izlet0005-iv_no.
          COMMIT WORK.
          DELETE FROM zlet0006 WHERE iv_no = izlet0005-iv_no.
          COMMIT WORK.
        ENDLOOP.

        INSERT zlet0005 FROM TABLE izlet0005.
        COMMIT WORK.
        INSERT zlet0006 FROM TABLE izlet0006.
        COMMIT WORK.

*{ SRM2510-06313
*// 데이터 저장 후 출하정보 BMES 전송
        IF r_vbeln = 'X'.
          LOOP AT izlet0005.
            CLEAR : ls_06, lv_vsart.
            READ TABLE izlet0006
             WITH KEY iv_no = izlet0005-iv_no INTO ls_06.
            CHECK sy-subrc = 0.

            SELECT SINGLE vsart
              INTO lv_vsart
              FROM likp
              WHERE vbeln = ls_06-vbeln.
            CHECK lv_vsart = '09'. " 직납일 경우에만 전송
            PERFORM call_bis_if_function(zler0014) USING 'C'
                                               Izlet0005-iv_no
                                               Izlet0005-werks
                                               sy-datum
                                               sy-uzeit.
          ENDLOOP.
        ENDIF.
*} SRM2510-06313


*___통문유형 'A01'인 경우 거래명세서 발행 후 납품헤더 Update
        LOOP AT izlet0006.
          READ TABLE izlet0005 WITH KEY iv_no = izlet0006-iv_no.
          IF sy-subrc = 0.
            PERFORM update_likp(zler0012) USING izlet0005-iv_type
                                                izlet0006-vbeln.
          ENDIF.
        ENDLOOP.
      ENDIF.

      MESSAGE s005(zle1) WITH gv_iv_no '-> 거래명세서 발행되었습니다'.

      DELETE gt_qlist WHERE chk = 'X'.
    ELSE.
      MESSAGE i005(zle1) WITH '거래명세서 발행실패 다시 시도하세요!'.
    ENDIF.
  ENDIF.

ENDFORM.                    " smart_form_finall_write
*&---------------------------------------------------------------------*
*&      Form  all_select
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0880   text
*----------------------------------------------------------------------*
FORM all_select  USING    p_xx.

  CASE p_xx.
    WHEN 'A'.
      gt_qlist-chk = 'X'.
      MODIFY gt_qlist TRANSPORTING chk WHERE chk = ' '.

    WHEN 'D'.
      gt_qlist-chk = ' '.
      MODIFY gt_qlist TRANSPORTING chk WHERE chk = 'X'.

  ENDCASE.

ENDFORM.                    " all_select
*&---------------------------------------------------------------------*
*&      Form  sort
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sort .

  DATA: lv_field(30), lv_list(10).

  lv_list   = g_cursor_field+0(7).

  IF lv_list = 'GT_QLIST'.
    lv_field = g_cursor_field+8(11).
    IF sy-ucomm = 'ASORT'.
      SORT gt_qlist BY (lv_field) ASCENDING.
    ELSE.
      SORT gt_qlist BY (lv_field) DESCENDING.
    ENDIF.
  ENDIF.

ENDFORM.                    " sort
*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM initialization .

  CONCATENATE icon_write_file '사업장/출하지점 등록'
                          INTO sscrfields-functxt_01 .

  t1 = '통문유형/발행기준'.
  t2 = '선택조건'.
  t3 = '영업데이타'.
*  t4 = '발행조건'.

  s_wadat-sign   = 'I'.
  s_wadat-option = 'EQ'.
  s_wadat-low    = sy-datum.
  s_wadat-high   = sy-datum.
  APPEND s_wadat.

ENDFORM.                    " INITIALIZATION
*&---------------------------------------------------------------------*
*&      Form  PREPARE_HEADER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_header_data .

  CLEAR: vttk.
  SELECT SINGLE * FROM vttk WHERE tknum = gt_prnt-tknum.

* 거래명세서번호
  izlet0005-iv_no          =  gv_iv_no.
* 거래명세서 통문유형
* 통문유형
  IF gt_prnt-iv_type = 'NL'.
    izlet0005-iv_type = 'A02'.
  ELSE.
    izlet0005-iv_type = 'A01'.
  ENDIF.

* 사업장
  izlet0005-bzarea         = p_bzarea.
* 거래명세서 발행일자
  izlet0005-iv_date        = sy-datum.
* 거래명세서 발행여부
  izlet0005-iv_print_yn    = 'X'.
  izlet0005-print_cnt      = 1.

* 차량번호
  IF wa-truck_no IS INITIAL.
    izlet0005-truck_no = vttk-exti1.
  ELSE.
    izlet0005-truck_no = wa-truck_no.
  ENDIF.

* 운전기사명
  IF wa-driver_nm IS INITIAL.
    izlet0005-driver_nm = vttk-exti2.
  ELSE.
    izlet0005-driver_nm = wa-driver_nm.
  ENDIF.

* 운전기사 전화번호
  IF wa-driver_telno IS INITIAL.
    izlet0005-driver_telno = vttk-tpbez.
  ELSE.
    izlet0005-driver_telno = wa-driver_telno.
  ENDIF.

  izlet0005-create_user_id = sy-uname.
  izlet0005-create_date    = sy-datum.
  izlet0005-create_time    = sy-uzeit.
  izlet0005-werks          = gt_prnt-werks.
  izlet0005-kunnr          = gt_prnt-kunnr.
  APPEND izlet0005. CLEAR: izlet0005.

ENDFORM.                    " PREPARE_HEADER_DATA
*&---------------------------------------------------------------------*
*&      Form  PREPARE_ITEM_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_item_data .

*-- 통관 Item 저장정보 추가된 견적품 관련 Item 항목 저장정보 에서 제외
  DATA : lt_item LIKE TABLE OF gt_qlist WITH EMPTY KEY,

         lv_seq  TYPE i.

  CLEAR lv_seq.

  lt_item[] = CORRESPONDING #( gt_item[] ).

  SORT : lt_item BY vbeln posnr.

  DELETE ADJACENT DUPLICATES FROM lt_item COMPARING vbeln posnr.

  LOOP AT lt_item INTO DATA(ls_item).
    READ TABLE gt_item WITH KEY vbeln = ls_item-vbeln
                                posnr = ls_item-posnr.
    CHECK sy-subrc EQ 0.

    ADD 1 TO lv_seq.

    izlet0006-iv_no    = gv_iv_no.
    izlet0006-iv_seq   = lv_seq.
    izlet0006-vbeln    = gt_item-vbeln.
    izlet0006-posnr    = gt_item-posnr.
    izlet0006-matnr    = gt_item-matnr.
    izlet0006-tknum    = gt_item-tknum.
    izlet0006-sdabw    = gt_item-sdabw.
    izlet0006-maktx    = gt_item-arktx.
    izlet0006-lfimg    = gt_item-lfimg.
    izlet0006-mtr_unit = gt_item-vrkme.

    APPEND izlet0006.    CLEAR izlet0006.

  ENDLOOP.

*  DATA: lv_seq   TYPE i.
*  CLEAR: lv_seq.
*  LOOP AT gt_item.
*    lv_seq = lv_seq + 1.
*    izlet0006-iv_no    = gv_iv_no.
*    izlet0006-iv_seq   = lv_seq.
*    izlet0006-vbeln    = gt_item-vbeln.
*    izlet0006-posnr    = gt_item-posnr.
*    izlet0006-matnr    = gt_item-matnr.
*    izlet0006-tknum    = gt_item-tknum.
*    izlet0006-sdabw    = gt_item-sdabw.
*    izlet0006-maktx    = gt_item-arktx.
*    izlet0006-lfimg    = gt_item-lfimg.
*    izlet0006-mtr_unit = gt_item-vrkme.
*    APPEND izlet0006.    CLEAR izlet0006.
*  ENDLOOP.

ENDFORM.                    " PREPARE_ITEM_DATA
*&---------------------------------------------------------------------*
*&      Form  CANCEL_IV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cancel_iv .

  DATA : ls_06 LIKE izlet0006.
  DATA : lv_vsart LIKE likp-vsart.

  DATA : lv_CHANGE.
  LOOP AT gt_qlist WHERE chk = 'X'.
    SELECT SINGLE *
      FROM zlet0005
     WHERE iv_no = gt_qlist-iv_no
       AND out_yn = 'X'.

    IF sy-subrc = 0.
      MESSAGE i000 WITH '통문확정 취소후 발행취소하세요.'.
      LEAVE SCREEN.
    ENDIF.
  ENDLOOP.

*/
  PERFORM pop_up_confirm(zler0004) USING '< 거래명세서취소여부확인 >'
                                        '취소하시겠습니까?'
                                CHANGING gv_return.
  CHECK gv_return = 'J'.
  CLEAR gv_return.

  DATA: BEGIN OF lt_iv OCCURS 0,
          iv_no LIKE zlet0005-iv_no,
        END OF lt_iv.

  LOOP AT gt_qlist WHERE chk = 'X'.
    lt_iv-iv_no = gt_qlist-iv_no.
    COLLECT lt_iv. CLEAR: lt_iv.
  ENDLOOP.

  SORT lt_iv.
  LOOP AT lt_iv.
    CLEAR : lv_CHANGE.
    AT NEW iv_no.
      lv_CHANGE = 'X'.
    ENDAT.


    UPDATE zlet0005 SET: iv_cancel_yn = 'X'
                         change_date  = sy-datum
                         change_time  = sy-uzeit
          WHERE iv_no = lt_iv-iv_no.
    COMMIT WORK.

    DELETE gt_qlist WHERE iv_no = lt_iv-iv_no.

*{ SRM2510-06313
*// 데이터 취소후 출하정보 BMES 전송
    IF lv_change = 'X' AND  r_vbeln = 'X'..
      CLEAR : ls_06, lv_vsart.

      SELECT SINGLE *
        INTO ls_06
        FROM zlet0006
        WHERE iv_no = lt_iv-iv_no.
      CHECK sy-subrc = 0 .

      SELECT SINGLE vsart
        INTO lv_vsart
        FROM likp
        WHERE vbeln = ls_06-vbeln.
      CHECK lv_vsart = '09'. " 직납일 경우에만 전송

      PERFORM call_bis_if_function(zler0014) USING 'R'
                                         lt_iv-iv_no
                                         '1306'
                                         sy-datum
                                         sy-uzeit.
    ENDIF.
    CLEAR : lv_CHANGE.
*} SRM2510-06313

  ENDLOOP.

  MESSAGE s000 WITH '거래명세서 발행취소하였습니다'.



ENDFORM.                    " CANCEL_IV
*&---------------------------------------------------------------------*
*&      Form  convert_meins
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_SM03_MATNR  text
*      -->P_1931   text
*      -->P_1932   text
*      <--P_GV_MENGE  text
*----------------------------------------------------------------------*
FORM convert_meins  USING    p_matnr
                             p_in
                             p_out
                    CHANGING p_menge.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      i_matnr              = p_matnr
      i_in_me              = p_in
      i_out_me             = p_out
      i_menge              = '1'
    IMPORTING
      e_menge              = p_menge
    EXCEPTIONS
      error_in_application = 1
      error                = 2
      OTHERS               = 3.


ENDFORM.                    " convert_meins
*&---------------------------------------------------------------------*
*&      Form  get_data_tknum_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIST  text
*----------------------------------------------------------------------*
FORM get_data_tknum_1  "TABLES   pt_list LIKE gt_list[].
                       CHANGING pt_list TYPE gty_t_list.

  CLEAR : pt_list.

  "-> CCM : 2023.04.18 ZITCS4HDEV06 - VBUK -> LIKP로 수정
*  SELECT k~tknum k~exti2 k~exti1 k~tpbez k~shtyp k~tdlnr k~sdabw
*         x~kunnr x~wadat_ist x~route x~lfart x~vsart
*         x~vbtyp x~vstel x~kunag
*         y~vbeln y~posnr y~werks y~matnr y~arktx y~lfimg y~vrkme
*         y~charg y~meins y~vgbel y~vgpos y~umvkz y~umvkn
*         y~vkbur y~vkgrp y~vtweg
*         h~iv_no h~iv_date
*    INTO CORRESPONDING FIELDS OF TABLE pt_list
*    FROM vttk AS k
*      INNER JOIN vttp AS p
*         ON k~tknum = p~tknum
*      INNER JOIN likp AS x
*         ON p~vbeln = x~vbeln
*      INNER JOIN vbuk AS u
*         ON x~vbeln = u~vbeln
*      INNER JOIN lips AS y
*         ON x~vbeln = y~vbeln
*      INNER JOIN zlet0006 AS i
*         ON y~vbeln = i~vbeln
*        AND y~posnr = i~posnr
*        AND k~tknum = i~tknum
*      INNER JOIN zlet0005 AS h
*         ON i~iv_no = h~iv_no
*     WHERE k~tknum IN s_tknum
*       AND k~shtyp NOT IN ('Z002', 'Z009', 'Z103')          ", 'Z007')
*       AND p~vbeln IN s_vbeln
*       AND x~lfart IN r_lfart
*       AND x~vstel IN s_vstel
*       AND x~vstel IN r_vstel
*       AND x~wadat_ist IN s_wadat
*       AND x~kunnr IN s_kunnr
*       AND x~ernam IN s_ernam
*       AND x~route IN s_route
*       AND x~route NOT IN ('01-001', '02-001')
*       AND x~zout  IN r_outyn  "<> 'Y'
*       AND y~vkbur IN s_vkbur
*       AND y~vkgrp IN s_vkgrp
*       AND y~vtweg IN s_vtweg
*       AND u~wbstk = 'C'
*       AND y~uecha = '000000'
*       AND h~iv_print_yn  = 'X'   "거래명세서 발행여부
*       AND h~iv_cancel_yn = ' '   "거래명세서 취소여부
*       AND h~iv_date IN s_date
*       AND h~iv_no   IN s_iv_no
*       AND h~bzarea  = p_bzarea "통문헤더 사업장 조건 추가
*       AND x~vsart IN s_vsart.  "출하유형 조건 추가 07.02.05


*  SELECT k~tknum k~exti2 k~exti1 k~tpbez k~shtyp k~tdlnr k~sdabw
*         x~kunnr x~wadat_ist x~route x~lfart x~vsart
*         x~vbtyp x~vstel x~kunag
*         y~vbeln y~posnr y~werks y~matnr y~arktx y~lfimg y~vrkme
*         y~charg y~meins y~vgbel y~vgpos y~umvkz y~umvkn
*         y~vkbur y~vkgrp y~vtweg
*         h~iv_no h~iv_date
*    INTO CORRESPONDING FIELDS OF TABLE pt_list
*    FROM vttk AS k
*      INNER JOIN vttp AS p
*         ON k~tknum = p~tknum
*      INNER JOIN likp AS x
*         ON p~vbeln = x~vbeln
*      INNER JOIN lips AS y
*         ON x~vbeln = y~vbeln
*      INNER JOIN zlet0006 AS i
*         ON y~vbeln = i~vbeln
*        AND y~posnr = i~posnr
*        AND k~tknum = i~tknum
*      INNER JOIN zlet0005 AS h
*         ON i~iv_no = h~iv_no
*     WHERE k~tknum IN s_tknum
*       AND k~shtyp NOT IN ('Z002', 'Z009', 'Z103')          ", 'Z007')
*       AND p~vbeln IN s_vbeln
*       AND x~lfart IN r_lfart
*       AND x~vstel IN s_vstel
*       AND x~vstel IN r_vstel
*       AND x~wadat_ist IN s_wadat
*       AND x~kunnr IN s_kunnr
*       AND x~ernam IN s_ernam
*       AND x~route IN s_route
*       AND x~route NOT IN ('01-001', '02-001')
*       AND x~zout  IN r_outyn  "<> 'Y'
*       AND y~vkbur IN s_vkbur
*       AND y~vkgrp IN s_vkgrp
*       AND y~vtweg IN s_vtweg
*       AND x~wbstk = 'C'
*       AND y~uecha = '000000'
*       AND h~iv_print_yn  = 'X'   "거래명세서 발행여부
*       AND h~iv_cancel_yn = ' '   "거래명세서 취소여부
*       AND h~iv_date IN s_date
*       AND h~iv_no   IN s_iv_no
*       AND h~bzarea  = p_bzarea "통문헤더 사업장 조건 추가
*       AND x~vsart IN s_vsart.  "출하유형 조건 추가 07.02.05

  SELECT k~tknum, k~exti2, k~exti1, k~tpbez, k~shtyp, k~tdlnr, k~sdabw,
         x~kunnr, x~wadat_ist, x~route, x~lfart, x~vsart,
         x~vbtyp, x~vstel, x~kunag,
         y~vbeln, y~posnr, y~werks, y~matnr, y~arktx, y~lfimg, y~vrkme,
         y~charg, y~meins, y~vgbel, y~vgpos, y~umvkz, y~umvkn,
         y~vkbur, y~vkgrp, y~vtweg,
         h~iv_no, h~iv_date

    FROM vttk AS k INNER JOIN vttp AS p
                      ON k~tknum EQ p~tknum

                   INNER JOIN likp AS x
                      ON p~vbeln EQ x~vbeln

                   INNER JOIN lips AS y
                      ON x~vbeln EQ y~vbeln

                   INNER JOIN zlet0006 AS i
                      ON y~vbeln EQ i~vbeln
                     AND y~posnr EQ i~posnr
                     AND k~tknum EQ i~tknum

                   INNER JOIN zlet0005 AS h
                      ON i~iv_no EQ h~iv_no

     WHERE k~tknum        IN @s_tknum
       AND k~shtyp        NOT IN ('Z002', 'Z009', 'Z103')
       AND p~vbeln        IN @s_vbeln
       AND x~lfart        IN @r_lfart
       AND x~vstel        IN @s_vstel
       AND x~vstel        IN @r_vstel
       AND x~wadat_ist    IN @s_wadat
       AND x~kunnr        IN @s_kunnr
       AND x~ernam        IN @s_ernam
       AND x~route        IN @s_route
       AND x~route        NOT IN ('01-001', '02-001')
       AND x~zout         IN @r_outyn  "<> 'Y'
       AND y~vkbur        IN @s_vkbur
       AND y~vkgrp        IN @s_vkgrp
       AND y~vtweg        IN @s_vtweg
       AND x~wbstk        EQ 'C'
       AND y~uecha        EQ '000000'
       AND h~iv_print_yn  EQ 'X'   "거래명세서 발행여부
       AND h~iv_cancel_yn EQ ' '   "거래명세서 취소여부
       AND h~iv_date      IN @s_date
       AND h~iv_no        IN @s_iv_no
       AND h~bzarea       EQ @p_bzarea "통문헤더 사업장 조건 추가
       AND x~vsart        IN @s_vsart  "출하유형 조건 추가 07.02.05

      INTO CORRESPONDING FIELDS OF TABLE @pt_list.

ENDFORM.                    " get_data_tknum_1
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_VBELN_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIST  text
*----------------------------------------------------------------------*
FORM get_data_vbeln_1  "TABLES   pt_list LIKE gt_list[].
                       CHANGING pt_list TYPE gty_t_list.

  CLEAR pt_list.

  "-> CCM : 2023.04.18 ZITCS4HDEV06 - VBUK -> LIKP로 수정

*  SELECT "k~tknum k~exti2 k~exti1 k~tpbez k~shtyp k~tdlnr k~sdabw
*         x~kunnr x~wadat_ist x~route x~lfart x~vsart
*         x~vbtyp x~vstel x~kunag
*         y~vbeln y~posnr y~werks y~matnr y~arktx y~lfimg y~vrkme
*         y~charg y~meins y~vgbel y~vgpos y~umvkz y~umvkn
*         y~vkbur y~vkgrp y~vtweg
*         h~iv_no h~iv_date
*    INTO CORRESPONDING FIELDS OF TABLE pt_list
*    FROM likp AS x
*      INNER JOIN vbuk AS u
*         ON x~vbeln = u~vbeln
*      INNER JOIN lips AS y
*         ON x~vbeln = y~vbeln
*      INNER JOIN zlet0006 AS i
*         ON x~vbeln = i~vbeln
*        AND y~posnr = i~posnr
*      INNER JOIN zlet0005 AS h
*         ON i~iv_no = h~iv_no
*     WHERE x~vbeln IN s_vbeln
*       AND x~lfart IN r_lfart
*       AND x~vstel IN s_vstel
*       AND x~vstel IN r_vstel
*       AND x~wadat_ist IN s_wadat
*       AND x~kunnr IN s_kunnr
*       AND x~ernam IN s_ernam
*       AND x~route IN s_route
*       AND x~route NOT IN ('01-001', '02-001')
*       AND x~zout  IN r_outyn  "<> 'Y'
*       AND y~vkbur IN s_vkbur
*       AND y~vkgrp IN s_vkgrp
*       AND y~vtweg IN s_vtweg
*       AND u~wbstk = 'C'
*       AND y~uecha = '000000'
*       AND h~iv_print_yn  = 'X'   "거래명세서 발행여부
*       AND h~iv_cancel_yn = ' '   "거래명세서 취소여부
*       AND h~iv_date IN s_date
*       AND h~iv_no   IN s_iv_no
*       AND h~bzarea  = p_bzarea "통문헤더 사업장 조건 추가
*       AND x~vsart IN s_vsart.  "출하유형 조건 추가 07.02.05
*  SELECT "k~tknum k~exti2 k~exti1 k~tpbez k~shtyp k~tdlnr k~sdabw
*         x~kunnr x~wadat_ist x~route x~lfart x~vsart
*         x~vbtyp x~vstel x~kunag
*         y~vbeln y~posnr y~werks y~matnr y~arktx y~lfimg y~vrkme
*         y~charg y~meins y~vgbel y~vgpos y~umvkz y~umvkn
*         y~vkbur y~vkgrp y~vtweg
*         h~iv_no h~iv_date
*    INTO CORRESPONDING FIELDS OF TABLE pt_list
*    FROM likp AS x
*      INNER JOIN lips AS y
*         ON x~vbeln = y~vbeln
*      INNER JOIN zlet0006 AS i
*         ON x~vbeln = i~vbeln
*        AND y~posnr = i~posnr
*      INNER JOIN zlet0005 AS h
*         ON i~iv_no = h~iv_no
*     WHERE x~vbeln IN s_vbeln
*       AND x~lfart IN r_lfart
*       AND x~vstel IN s_vstel
*       AND x~vstel IN r_vstel
*       AND x~wadat_ist IN s_wadat
*       AND x~kunnr IN s_kunnr
*       AND x~ernam IN s_ernam
*       AND x~route IN s_route
*       AND x~route NOT IN ('01-001', '02-001')
*       AND x~zout  IN r_outyn  "<> 'Y'
*       AND y~vkbur IN s_vkbur
*       AND y~vkgrp IN s_vkgrp
*       AND y~vtweg IN s_vtweg
*       AND x~wbstk = 'C'
*       AND y~uecha = '000000'
*       AND h~iv_print_yn  = 'X'   "거래명세서 발행여부
*       AND h~iv_cancel_yn = ' '   "거래명세서 취소여부
*       AND h~iv_date IN s_date
*       AND h~iv_no   IN s_iv_no
*       AND h~bzarea  = p_bzarea "통문헤더 사업장 조건 추가
*       AND x~vsart IN s_vsart.  "출하유형 조건 추가 07.02.05
*<-

*{ 자체개선 45811 - 추가
*___선적문서번호가 있으면 대상에서 제외
*  DELETE pt_list WHERE tknum IS NOT INITIAL.
*} 자체개선 45811 - 추가

  SELECT x~kunnr, x~wadat_ist, x~route, x~lfart, x~vsart,
         x~vbtyp, x~vstel, x~kunag,
         y~vbeln, y~posnr, y~werks, y~matnr, y~arktx, y~lfimg, y~vrkme,
         y~charg, y~meins, y~vgbel, y~vgpos, y~umvkz, y~umvkn,
         y~vkbur, y~vkgrp, y~vtweg,
         h~iv_no, h~iv_date

    FROM likp AS x INNER JOIN lips AS y
                      ON x~vbeln EQ y~vbeln

                   INNER JOIN zlet0006 AS i
                      ON x~vbeln EQ i~vbeln
                     AND y~posnr EQ i~posnr

                   INNER JOIN zlet0005 AS h
                      ON i~iv_no EQ h~iv_no

     WHERE x~vbeln        IN @s_vbeln
       AND x~lfart        IN @r_lfart
       AND x~vstel        IN @s_vstel
       AND x~vstel        IN @r_vstel
       AND x~wadat_ist    IN @s_wadat
       AND x~kunnr        IN @s_kunnr
       AND x~ernam        IN @s_ernam
       AND x~route        IN @s_route
       AND x~route        NOT IN ('01-001', '02-001')
       AND x~zout         IN @r_outyn  "<> 'Y'
       AND y~vkbur        IN @s_vkbur
       AND y~vkgrp        IN @s_vkgrp
       AND y~vtweg        IN @s_vtweg
       AND x~wbstk        EQ 'C'
       AND y~uecha        EQ '000000'
       AND h~iv_print_yn  EQ 'X'   "거래명세서 발행여부
       AND h~iv_cancel_yn EQ ' '   "거래명세서 취소여부
       AND h~iv_date      IN @s_date
       AND h~iv_no        IN @s_iv_no
       AND h~bzarea       EQ @p_bzarea "통문헤더 사업장 조건 추가
       AND x~vsart        IN @s_vsart  "출하유형 조건 추가 07.02.05

     INTO CORRESPONDING FIELDS OF TABLE @pt_list.

ENDFORM.                    " GET_DATA_VBELN_1
*&---------------------------------------------------------------------*
*&      Form  GET_COLOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_color .

****[START]C20091118_62117**********
****DELETED LINES***************************
*  IF gt_rprt-gp_flag = 'G'.
*    CONCATENATE gt_rprt-prdid
*                        gt_rprt-prod
*                        gt_rprt-volt
*                        gt_rprt-wire
*                        gt_rprt-gnd
*                        gt_rprt-amp
*                        gt_rprt-cond
*                        gt_rprt-duct
*                        gt_rprt-ipdeg
*    INTO lv_sm03-color SEPARATED BY space.
*  ELSEIF   gt_rprt-gp_flag = 'P'.
*    CONCATENATE gt_rprt-prod
*                         gt_rprt-pole
*                         gt_rprt-wire
*                         gt_rprt-brea
*                         gt_rprt-frame
*                         gt_rprt-trip
*   INTO lv_sm03-color SEPARATED BY space.
*  ELSEIF   gt_rprt-gp_flag = 'N'.
*    lv_sm03-color =  gt_rprt-prod.
*  ENDIF.
****DELETED LINES***************************
****[END]C20091118_62117**********


****[START]C20091118_62117**********
****CREATED LINES***************************
  DATA: ll_kdkg4 LIKE vbkd-kdkg4.

  DATA : lv_prdid TYPE c LENGTH 30.
  CLEAR : lv_prdid .

  IF gt_rprt-gp_flag = 'A'.
    CONCATENATE gt_rprt-prod "견적품명
                ' '
                gt_rprt-brea "메인차단기모델
                ' '
                '('
                gt_rprt-pole "메인차단기극수
                ' '
                gt_rprt-frame "메인프렘임용량
                '/'
                gt_rprt-trip "메인트립용량
                ')'
           INTO lv_sm03-color SEPARATED BY space.

  ELSEIF gt_rprt-gp_flag = 'B'.
    CONCATENATE gt_rprt-prod "견적품명
                ' '
                gt_rprt-pole "메인차단기극수
                ' '
                gt_rprt-brea "메인차단기모델
                ' '
                gt_rprt-frame "메인프레임용량
                '/'
                gt_rprt-trip  "메인트립용량
                '('
                gt_rprt-pole_sub "서브차단기극수
                ' '
                gt_rprt-brea_sub "서브차단기모델
                ' '
                gt_rprt-frame_sub "서브프레임용량
                '/'
                gt_rprt-trip_sub  "서브트립용량
                'x'
                gt_rprt-circuit  "회로수
                'x'
                gt_rprt-circuit_per  "회로당차단기수
                ')'
          INTO lv_sm03-color SEPARATED BY space.

  ELSEIF gt_rprt-gp_flag = 'C'.

** 선식 계산.[gt_vbap-wire_combine "선식]:내수만 존재
    CLEAR: ll_kdkg4.
    SELECT SINGLE kdkg4
      INTO ll_kdkg4
      FROM vbkd
     WHERE vbeln = gt_rprt-vgbel.

    IF ll_kdkg4 = '4E'.
      SELECT SINGLE overseas
      INTO gt_rprt-wire_combine
      FROM zsdt3000
     WHERE wire      = gt_rprt-wire
       AND wire_type = gt_rprt-wire_type.
    ELSE.
      SELECT SINGLE domestic
        INTO gt_rprt-wire_combine
        FROM zsdt3000
       WHERE wire      = gt_rprt-wire
         AND wire_type = gt_rprt-wire_type.

    ENDIF.

    IF gt_rprt-wire_type IS INITIAL.

      CONCATENATE gt_rprt-prod "견적품명
                  ' '
                  gt_rprt-wire_desc "상
                  ' '
                  gt_rprt-amp  "용량
            INTO lv_sm03-color SEPARATED BY space.
    ELSE.

      CONCATENATE gt_rprt-prod "견적품명
                  ' '
                  gt_rprt-wire_combine "선식
                  ' '
                  gt_rprt-amp  "용량
            INTO lv_sm03-color SEPARATED BY space.

    ENDIF.

  ELSEIF gt_rprt-gp_flag = 'D'.
** 선식 계산.[gt_vbap-wire_combine "선식]:내수만 존재
    CLEAR: ll_kdkg4.
    SELECT SINGLE kdkg4
      INTO ll_kdkg4
      FROM vbkd
     WHERE vbeln = gt_rprt-vgbel.

    IF ll_kdkg4 = '4E'.
      SELECT SINGLE overseas
      INTO gt_rprt-wire_combine
      FROM zsdt3000
     WHERE wire      = gt_rprt-wire
       AND wire_type = gt_rprt-wire_type.
    ELSE.
      SELECT SINGLE domestic
        INTO gt_rprt-wire_combine
        FROM zsdt3000
       WHERE wire      = gt_rprt-wire
         AND wire_type = gt_rprt-wire_type.

    ENDIF.

*{ 기능개선 234981
    IF gt_rprt-prdid = '절연형(외주)'.
      lv_prdid = '절연형'.
    ELSEIF gt_rprt-prdid = '내화형(외주)'.
      lv_prdid = '내화형'.
    ELSE.
      lv_prdid = gt_rprt-prdid.
    ENDIF.
* 기능개선 234981}

    IF gt_rprt-wire_type IS INITIAL.

      CONCATENATE lv_prdid     "제품구분
                  gt_rprt-gnd       "접지구분
                  gt_rprt-ipdeg     "IP등급
                  ' '
                  gt_rprt-volt      "전압
                  ' '
                  gt_rprt-prod      "견적품명
                  '('
                  gt_rprt-wire_desc "상
                  ' '
                  gt_rprt-amp       "용량
                  ' '
                  gt_rprt-cond      "도체재질(D)
                  '-'
                  gt_rprt-duct      "덕트재질(D)
                  ')'
                  ' '
                  gt_rprt-ipdeg_name     "IP등급명
            INTO lv_sm03-color SEPARATED BY space.
    ELSE.
      CONCATENATE lv_prdid  "제품구분
                 gt_rprt-gnd   "접지구분
                 gt_rprt-ipdeg     "IP등급
                 ' '
                 gt_rprt-volt      "전압
                 ' '
                 gt_rprt-prod "견적품명
                 '('
                 gt_rprt-wire_combine "선식
                 ' '
                 gt_rprt-amp  "용량
                 ' '
                 gt_rprt-cond  "도체재질(D)
                 '-'
                 gt_rprt-duct  "덕트재질(D)
                 ')'
                 ' '
                 gt_rprt-ipdeg_name     "IP등급명
           INTO lv_sm03-color SEPARATED BY space.

    ENDIF.
  ELSEIF gt_rprt-gp_flag = 'E'
     OR  gt_rprt-gp_flag = 'F'.

    lv_sm03-color = gt_rprt-arktx.
  ENDIF.
****CREATED LINES***************************
****[END]C20091118_62117**********

ENDFORM.                    " GET_COLOR
*&---------------------------------------------------------------------*
*&      Form  GET_LENGTH_FACTOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_length_factor .

*  IF gt_rprt-vstel = '1500' OR   "안양 권선
*     gt_rprt-vstel = '3200'.     "구미 권선
** MW(권선): MAGNET WIRE
**    PERFORM get_mw_bobin_count.
**
**    lv_factor = lv_charg_cnt_sum.
**    CONDENSE lv_factor.
**    lv_sm03-mtext = lv_factor.
*  ELSE.
**    lv_factor = gt_rprt-factor.
**    CONDENSE lv_factor.
**    ADD lv_factor  TO lv_sum.
*
*    IF gt_rprt-lfart = 'NL'.
**      CONCATENATE gt_rprt-length_c 'X' lv_factor '-' gt_rprt-vbeln
*INTO
**        lv_sm03-mtext SEPARATED BY space.
*
*    ELSE.
**      CONCATENATE gt_rprt-length_c 'X' lv_factor INTO
**        lv_sm03-mtext SEPARATED BY space.
*    ENDIF.
*  ENDIF.

ENDFORM.                    " GET_LENGTH_FACTOR
*&---------------------------------------------------------------------*
*&      Form  GET_PONUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_ponum .

  SELECT SINGLE bstkd INTO lv_sm03-ponum
         FROM vbkd WHERE vbeln = gt_rprt-vgbel.
*         gt_item-vgbel."gt_rprt-vgbel.

  lv_sm03-ponum = lv_sm03-ponum+0(27).


ENDFORM.                    " GET_PONUM
*&---------------------------------------------------------------------*
*&      Form  DATA_MOVE_G02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_move_g02 .

  gt_rprt-vstel     = gt_item-vstel.
  IF x_vbeln = 'X'.  "발행시 납품문서기준으로 발행됨.
    gt_rprt-vgbel     = gt_item-vbeln.
    gt_rprt-vgpos     = gt_item-posnr.
  ELSE.
    gt_rprt-vgbel     = gt_item-vgbel.
    gt_rprt-vgpos     = gt_item-vgpos.
  ENDIF.
  gt_rprt-lfart     = gt_item-lfart.
  gt_rprt-vbeln     = gt_item-vbeln.
  gt_rprt-arktx     = gt_item-qname_prnt.
  IF gt_item-lfart CS 'LR'.  "반품
    gt_rprt-lfimg     = gt_item-lfimg * -1.
  ELSE.
    gt_rprt-lfimg     = gt_item-lfimg.
  ENDIF.
  gt_rprt-vrkme     = gt_item-vrkme.
*  gt_rprt-length_c  = gt_item-length_c.
*  gt_rprt-factor    = gt_item-factor.
*  gt_rprt-base      = gt_item-base.
*  gt_rprt-detail    = gt_item-detail.
*  gt_rprt-stripe    = gt_item-stripe.
*  gt_rprt-stripe_no = gt_item-stripe_no.
*  gt_rprt-iden      = gt_item-iden.

  gt_rprt-empst     = gt_item-empst+0(20).  "by song

ENDFORM.                    " DATA_MOVE_G02
*&---------------------------------------------------------------------*
*&      Form  data_move_g01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_move_g01 .

  gt_rprt-vstel     = gt_item-vstel.
  IF x_vbeln = 'X'.  "발행시 납품문서기준으로 발행됨.
    gt_rprt-vgbel     = gt_item-vbeln.
  ELSE.
    gt_rprt-vgbel     = gt_item-vgbel.
  ENDIF.
*  gt_rprt-vgpos     = gt_item-vgpos.
  gt_rprt-arktx     = gt_item-qname_prnt.
  IF gt_item-lfart CS 'LR'.  "반품
    gt_rprt-lfimg     = gt_item-lfimg * -1.
  ELSE.
    gt_rprt-lfimg     = gt_item-lfimg.
  ENDIF.
  gt_rprt-vrkme     = gt_item-vrkme.
*  gt_rprt-length_c  = gt_item-length_c.
*  gt_rprt-factor    = gt_item-factor.
*  gt_rprt-base      = gt_item-base.
*  gt_rprt-detail    = gt_item-detail.
*  gt_rprt-stripe    = gt_item-stripe.
*  gt_rprt-stripe_no = gt_item-stripe_no.
*  gt_rprt-iden      = gt_item-iden.

ENDFORM.                    " data_move_g01
*&---------------------------------------------------------------------*
*&      Form  data_move_g03
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_move_g03 .

  gt_rprt-vstel     = gt_item-vstel.
  IF x_vbeln = 'X'.  "발행시 납품문서기준으로 발행됨.
    gt_rprt-vgbel     = gt_item-vbeln.
    gt_rprt-vgpos     = gt_item-posnr.
  ELSE.
    gt_rprt-vgbel     = gt_item-vgbel.
    gt_rprt-vgpos     = gt_item-vgpos.
  ENDIF.
  gt_rprt-arktx     = gt_item-arktx.
  IF gt_item-lfart CS 'LR'.  "반품
    gt_rprt-lfimg     = gt_item-lfimg * -1.
  ELSE.
    gt_rprt-lfimg     = gt_item-lfimg.
  ENDIF.
  gt_rprt-vrkme     = gt_item-vrkme.
*  gt_rprt-packg     = gt_item-packg.
*  gt_rprt-packg_t   = gt_item-packg_t.
*  gt_rprt-length_c  = gt_item-length_c.
*  gt_rprt-factor    = gt_item-factor.
*  gt_rprt-base      = gt_item-base.
*  gt_rprt-detail    = gt_item-detail.
*  gt_rprt-stripe    = gt_item-stripe.
*  gt_rprt-stripe_no = gt_item-stripe_no.
*  gt_rprt-iden      = gt_item-iden.
  gt_rprt-empst     = gt_item-empst. "by song

ENDFORM.                    " data_move_g03
*&---------------------------------------------------------------------*
*&      Form  data_move_g04
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_move_g04 .

  SELECT * FROM lips WHERE vbeln = gt_item-vbeln
                       AND uecha = gt_item-posnr.
    gt_rprt-vstel     = gt_item-vstel.
    IF x_vbeln = 'X'.  "발행시 납품문서기준으로 발행됨.
      gt_rprt-vgbel     = gt_item-vbeln.
      gt_rprt-vgpos     = gt_item-posnr.
    ELSE.
      gt_rprt-vgbel     = gt_item-vgbel.
      gt_rprt-vgpos     = gt_item-vgpos.
    ENDIF.
    gt_rprt-arktx     = gt_item-qname_prnt.
    IF gt_item-lfart CS 'LR'.  "반품
      gt_rprt-lfimg     = lips-lfimg * -1.
    ELSE.
      gt_rprt-lfimg     = lips-lfimg.
    ENDIF.
    gt_rprt-vrkme     = gt_item-vrkme.
    gt_rprt-charg     = lips-charg.
*  gt_rprt-length_c  = gt_item-length_c.
*  gt_rprt-factor    = gt_item-factor.
*    gt_rprt-base      = gt_item-base.
*    gt_rprt-detail    = gt_item-detail.
*    gt_rprt-stripe    = gt_item-stripe.
*    gt_rprt-stripe_no = gt_item-stripe_no.
*    gt_rprt-iden      = gt_item-iden.
    gt_rprt-empst     = gt_item-empst. "by song

    COLLECT gt_rprt. CLEAR: gt_rprt.
  ENDSELECT.
  IF sy-subrc <> 0.
    gt_rprt-vstel     = gt_item-vstel.
    IF x_vbeln = 'X'.  "발행시 납품문서기준으로 발행됨.
      gt_rprt-vgbel     = gt_item-vbeln.
      gt_rprt-vgpos     = gt_item-posnr.
    ELSE.
      gt_rprt-vgbel     = gt_item-vgbel.
      gt_rprt-vgpos     = gt_item-vgpos.
    ENDIF.
    gt_rprt-arktx     = gt_item-qname_prnt.
    IF gt_item-lfart CS 'LR'.  "반품
      gt_rprt-lfimg     = gt_item-lfimg * -1.
    ELSE.
      gt_rprt-lfimg     = gt_item-lfimg.
    ENDIF.
    gt_rprt-vrkme     = gt_item-vrkme.
    gt_rprt-charg     = gt_item-charg.
*  gt_rprt-length_c  = gt_item-length_c.
*  gt_rprt-factor    = gt_item-factor.
*    gt_rprt-base      = gt_item-base.
*    gt_rprt-detail    = gt_item-detail.
*    gt_rprt-stripe    = gt_item-stripe.
*    gt_rprt-stripe_no = gt_item-stripe_no.
*    gt_rprt-iden      = gt_item-iden.

    COLLECT gt_rprt. CLEAR: gt_rprt.
  ENDIF.


ENDFORM.                    " data_move_g04

*&---------------------------------------------------------------------*
*&      Form  get_PACKG_T_G03
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_packg_t_g03 .

  IF gt_rprt-vstel = '1500' OR   "안양 권선
     gt_rprt-vstel = '3200'.     "구미 권선
** MW(권선): MAGNET WIRE 보빈수 구하기
*    PERFORM get_mw_bobin_count.
*
*    lv_factor = lv_charg_cnt_sum.
*    CONDENSE lv_factor.
*
*    CONCATENATE gt_rprt-packg_t '보빈수' lv_factor
*                   INTO lv_sm03-mtext SEPARATED BY space.

  ELSE.
*    lv_sm03-mtext = gt_rprt-packg_t.
  ENDIF.

ENDFORM.                    " get_PACKG_T_G03
*&---------------------------------------------------------------------*
*&      Form  GET_MW_BOBIN_COUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_mw_bobin_count .

*  REFRESH: lt_vl. CLEAR: lt_vl.
*  CLEAR : lv_charg_cnt, lv_charg_cnt_sum.
*
*  LOOP AT gt_list WHERE vgbel =  gt_rprt-vgbel
*                    AND vgpos =  gt_rprt-vgpos.
*    lt_vl-vbeln = gt_list-vbeln.
*    lt_vl-posnr = gt_list-posnr.
*    COLLECT lt_vl.  CLEAR: lt_vl.
*  ENDLOOP.
*
*  LOOP AT lt_vl.
*    SELECT COUNT( DISTINCT charg ) INTO lv_charg_cnt
*      FROM lips
*     WHERE vbeln = lt_vl-vbeln
*       AND uecha = lt_vl-posnr
*       AND charg <> ' '.
*    IF sy-subrc <> 0.
*      lv_charg_cnt = 1.
*    ENDIF.
*
*    ADD lv_charg_cnt  TO lv_charg_cnt_sum.
*  ENDLOOP.

ENDFORM.                    " GET_MW_BOBIN_COUNT
*&---------------------------------------------------------------------*
*&      Form  data_move_g02_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_move_g02_1 .

  DATA: lv_mod          TYPE i,
        lv_div          TYPE i,
        lv_packc(20),                     "포장재유형
        lv_packg        LIKE  mara-matnr,       "포장재
        lv_length_c(30),
        lv_factor       TYPE i.

  PERFORM get_batch_characteristic
          USING lips-matnr lips-charg
       CHANGING gt_item-length lv_packg lv_packc.

  IF NOT gt_item-length IS INITIAL.

    lv_mod = lips-lfimg MOD gt_item-length.
    lv_div = lips-lfimg DIV gt_item-length.

    CLEAR mch1.
    SELECT SINGLE xpcbt INTO mch1-xpcbt FROM mch1
                       WHERE matnr EQ lips-matnr
                         AND charg EQ lips-charg.

    IF lv_mod = 0.
      IF mch1-xpcbt = 'X'.  "6230002349 조장오류 때문에 수정 MKJ
        lv_length_c  = lips-lfimg.
      ELSE.
        lv_length_c  = gt_item-length.
      ENDIF.
      lv_factor    = lv_div.
    ELSE.
      lv_length_c  = lips-lfimg.
      lv_factor    = 1   .
    ENDIF.
  ENDIF.

  gt_rprt-vstel     = gt_item-vstel.

  IF x_vbeln = 'X'.  "발행시 납품문서기준으로 발행됨.
    gt_rprt-vgbel     = gt_item-vbeln.
    gt_rprt-vgpos     = gt_item-posnr.
  ELSE.
    gt_rprt-vgbel     = gt_item-vgbel.
    gt_rprt-vgpos     = gt_item-vgpos.
  ENDIF.

  gt_rprt-lfart     = gt_item-lfart.
  gt_rprt-vbeln     = gt_item-vbeln.

  gt_rprt-arktx     = gt_item-arktx.
  IF gt_item-lfart CS 'LR'.  "반품
    gt_rprt-lfimg     = lips-lfimg * -1.
  ELSE.
    gt_rprt-lfimg     = lips-lfimg.
  ENDIF.
  gt_rprt-vrkme     = gt_item-vrkme.
*  gt_rprt-length_c  = lips-lfimg.
*  gt_rprt-factor    = 1.  "gt_item-factor.
*  gt_rprt-base      = gt_item-base.
*  gt_rprt-detail    = gt_item-detail.
*  gt_rprt-stripe    = gt_item-stripe.
*  gt_rprt-stripe_no = gt_item-stripe_no.
*  gt_rprt-iden      = gt_item-iden.

  gt_rprt-empst     = gt_item-empst+0(20). "by song

ENDFORM.                    " data_move_g02_1
*&---------------------------------------------------------------------*
*&      Form  char_fltp_conversion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_CHAR_VALUE  text
*      <--P_PV_LENGTH  text
*----------------------------------------------------------------------*
FORM char_fltp_conversion  USING    pv_value_s
                           CHANGING pv_value_p.

  DATA: lv_fltp     LIKE rscvp-valu1,
        lv_pack(16) TYPE p DECIMALS 3.

  CALL FUNCTION 'CHAR_FLTP_CONVERSION'
    EXPORTING
      string          = pv_value_s
    IMPORTING
      flstr           = lv_fltp
*&      ivalu           = x_ival
    EXCEPTIONS
      string_not_fltp = 1.

  pv_value_p = lv_fltp.


ENDFORM.                    " char_fltp_conversion
*&---------------------------------------------------------------------*
*&      Form  call_zler0600
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_zler0600 .
  RANGES : lr_erdat FOR likp-erdat,
           lr_vstel FOR likp-vstel,
           lr_vbeln FOR likp-vbeln.

  DATA : lv_erdat LIKE likp-erdat,
         lv_vstel LIKE likp-vstel.

  CLEAR   : lr_erdat, lr_vstel, lr_vbeln.
  REFRESH : lr_erdat, lr_vstel, lr_vbeln.

  LOOP AT gt_qlist WHERE chk = 'X'.
    CLEAR : lv_erdat, lv_vstel.

    SELECT SINGLE erdat vstel
      INTO (lv_erdat, lv_vstel)
      FROM likp
     WHERE vbeln = gt_qlist-vbeln.

    IF sy-subrc = 0.
      lr_erdat-sign   = 'I'.
      lr_erdat-option = 'EQ'.
      lr_erdat-low    = lv_erdat.
      APPEND lr_erdat.

      lr_vstel-sign   = 'I'.
      lr_vstel-option = 'EQ'.
      lr_vstel-low    = lv_vstel.
      APPEND lr_vstel.

      lr_vbeln-sign   = 'I'.
      lr_vbeln-option = 'EQ'.
      lr_vbeln-low    = gt_qlist-vbeln.
      APPEND lr_vbeln.
    ENDIF.
  ENDLOOP.

  IF sy-subrc = 0.
*    SUBMIT zler0600 VIA SELECTION-SCREEN AND RETURN
    SUBMIT zler0600 AND RETURN
      WITH s_erdat IN lr_erdat
      WITH s_vstel IN lr_vstel
      WITH s_vbeln IN lr_vbeln.
  ELSE.
    MESSAGE i001 WITH '선택된 라인이 없습니다.'.
  ENDIF.

ENDFORM.                    " call_zler0600
*&---------------------------------------------------------------------*
*&      Form  prepare_accessory_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_accessory_data .
  DATA : lt_zlet0600 LIKE zlet0600 OCCURS 0 WITH HEADER LINE.

  CLEAR   : lt_zlet0600, lv_sm04.
  REFRESH : lt_zlet0600, lv_sm04.

  CHECK x_acsr = 'X'.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lt_zlet0600
    FROM zlet0600
     FOR ALL ENTRIES IN gt_item
   WHERE vbeln = gt_item-vbeln.
*   WHERE vbeln = gt_prnt-vbeln.

  IF sy-subrc = 0.
    LOOP AT lt_zlet0600.
      CLEAR : lv_sm04.

      IF sy-tabix = 1.
        lv_sm04-vbeln = 'ACCESSORY'.
      ENDIF.

      lv_sm04-maktx = lt_zlet0600-maktx.
      lv_sm04-lfimg = lt_zlet0600-lfimg.
      lv_sm04-vrkme = lt_zlet0600-meins.

      APPEND lv_sm04.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " prepare_accessory_data
*&---------------------------------------------------------------------*
*&      Form  authority_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM authority_check .
  DATA: gt_tvst  LIKE tvst OCCURS 0 WITH HEADER LINE,
        gt_tspa  LIKE tspa OCCURS 0 WITH HEADER LINE,
        lv_subrc LIKE sy-subrc.

  CLEAR : lv_subrc.
  CALL FUNCTION 'Z_LE_AUTHORIZATION_CHECK'
    EXPORTING
      i_bzarea = p_bzarea
      i_type   = '5'
    IMPORTING
      e_subrc  = lv_subrc.

  IF lv_subrc <> 0.
    MESSAGE e002 WITH '사업장에 대한 권한이 없읍니다'
                      p_bzarea.
  ENDIF.

  SELECT *
    INTO TABLE gt_tvst
    FROM tvst
   WHERE vstel IN s_vstel.

  LOOP  AT  gt_tvst.
    CLEAR : lv_subrc.
    CALL FUNCTION 'Z_LE_AUTHORIZATION_CHECK'
      EXPORTING
        i_vstel = gt_tvst-vstel
        i_type  = '3'
      IMPORTING
        e_subrc = lv_subrc.

    IF lv_subrc <> 0.
      MESSAGE e002 WITH '출하지점에 대한 권한이 없읍니다'
                        gt_tvst-vstel.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " authority_check


*&---------------------------------------------------------------------*
*&      Form  SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM selected_rows .
*  CLEAR :  gv_valid,
*           gt_row_no, gt_row_no[].
*
*  PERFORM get_selected_rows TABLES gt_row_no  "선택 ROW 찾기
*                          CHANGING gv_valid.
*
*  IF gv_valid = 'X'.
*
*    LOOP AT gt_row_no.
*      READ TABLE gt_list INDEX gt_row_no-row_id.
*      IF sy-subrc = 0.
*        gt_list-chk = 'X'.
*        MODIFY gt_list INDEX sy-tabix
*                             TRANSPORTING chk.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*ENDFORM.                    " SELECTED_ROWS


*&--------------------------------------------------------------------*
*&      Form  GET_SELECTED_ROWS
*&--------------------------------------------------------------------*
*       선택 되어진 ROWS들을 돌려준다.
*---------------------------------------------------------------------*
FORM get_selected_rows   TABLES lt_row_no STRUCTURE lvc_s_roid
                       CHANGING lv_valid TYPE c.

*  REFRESH : gt_modify.

  CALL METHOD gc_alv_grid->check_changed_data
    IMPORTING
      e_valid = lv_valid.

  CHECK lv_valid EQ 'X'.
  CALL METHOD gc_alv_grid->get_selected_rows
    IMPORTING
      et_row_no = lt_row_no[].

  READ TABLE lt_row_no INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.
    MESSAGE s001 WITH 'Data Select First..'.
  ENDIF.

ENDFORM.                    "GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  GET_CLASS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_class .

*  DATA lt_class LIKE gt_class OCCURS 0 WITH HEADER LINE.
*  DATA lv_matnr(18).
*
*  CLEAR : gt_class, gt_class[].
*
*  LOOP AT gt_list.
*    CLEAR lt_class.
*    PERFORM conversion_exit_alpha_input(zcof0010)
*                                  USING gt_list-matnr
*                               CHANGING lv_matnr.
*    lt_class-objek = lv_matnr.
*    APPEND lt_class.
*  ENDLOOP.
*
*  IF lt_class[] IS NOT INITIAL.
*    SORT lt_class BY objek.
*    DELETE ADJACENT DUPLICATES FROM lt_class COMPARING objek.
*
*    SELECT a~objek b~class
*         INTO TABLE gt_class
*       FROM kssk AS a JOIN klah AS b
*          ON a~klart = b~klart
*         AND a~clint = b~clint
*         FOR ALL ENTRIES IN lt_class
*     WHERE a~objek = lt_class-objek
*          AND a~klart = '001'.
*
*    IF sy-subrc = 0.
*      SORT gt_class BY objek.
*    ENDIF.
*  ENDIF.

ENDFORM.                    " GET_CLASS
*&---------------------------------------------------------------------*
*&      Form  SEL_PAI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sel_pai .
* 명령 코드 초기화
  CLEAR save_ok.
  save_ok = sy-ucomm.
  CLEAR sy-ucomm.

  CASE save_ok .
    WHEN 'FC01'.
      CALL TRANSACTION 'ZPBT0018'.

  ENDCASE.
ENDFORM.                    " SEL_PAI
*&---------------------------------------------------------------------*
*&      Form  GET_BZAREA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_bzarea .

  CLEAR : gt_bzarea, gt_bzarea[].

  SELECT bzarea vstel
    INTO TABLE gt_bzarea
    FROM zpbt0018.

  IF sy-subrc = 0.
    CLEAR : s_vstel, s_vstel[], p_bzarea.

    READ TABLE gt_bzarea INDEX 1.
    IF sy-subrc = 0.
      p_bzarea = gt_bzarea-bzarea.
    ENDIF.

    LOOP AT gt_bzarea WHERE bzarea = p_bzarea.
      CONCATENATE 'IEQ' gt_bzarea-vstel INTO s_vstel.
      APPEND s_vstel.
    ENDLOOP.

    gv_exit = ' '.
  ELSE.
    MESSAGE s000 WITH
    '부스닥트 사업장/출하지점을 먼저설정하세요.(ZPBT0018)'.
    gv_exit = 'X'.
  ENDIF.


ENDFORM.                    " GET_BZAREA
*&---------------------------------------------------------------------*
*&      Form  CHECK_BILLING_STATUS
*&---------------------------------------------------------------------*
*       2014031100034 스크랩 출하시 계산서 발행 후 가능토록 제어       *
*----------------------------------------------------------------------*
FORM check_billing_status USING pv_flag.
  DATA: BEGIN OF lt_vbrp OCCURS 0,
          vbeln LIKE vbrp-vbeln,
          posnr LIKE vbrp-posnr,
        END   OF lt_vbrp.

  DATA: lv_fksta LIKE vbup-fksta,
        lv_fkimg LIKE zfit0023-fkimg,
        lv_vrkme LIKE zfit0023-vrkme,
        lv_total LIKE zfit0023-fkimg.

  CLEAR : pv_flag.

*___스크랩 자재여부
  SELECT SINGLE a~matnr
    INTO gt_qlist-matnr
    FROM zsdt0420 AS a
   INNER JOIN likp AS b
      ON a~bukrs = b~vkorg
   WHERE b~vbeln = gt_qlist-vbeln
     AND a~matnr = gt_qlist-matnr
     AND lvorm = ' '.

  CHECK sy-subrc = 0.

*___납품문서 품목 상태
  CLEAR : lv_fksta.

*->CCM : ZITCS4HDEV01 2023.04.18 - VBUP ->LIPS로 수정
*  SELECT SINGLE FKSTA
*    INTO LV_FKSTA
*    FROM VBUP
*   WHERE VBELN = GT_LIST-VBELN
*     AND POSNR = GT_LIST-POSNR.
  SELECT SINGLE fksta
    INTO lv_fksta
    FROM lips
   WHERE vbeln = gt_qlist-vbeln
     AND posnr = gt_qlist-posnr.
*<-

  IF lv_fksta <> 'C'.
    pv_flag = 'X'.

    MESSAGE s398(00) DISPLAY LIKE 'E'
       WITH '스크랩 자재는 계산서 발행(승인) 후'
            '출력 가능합니다.'
            gt_qlist-vbeln gt_qlist-posnr.

    EXIT.
  ENDIF.

*___납품문서에 해당하는 빌링문서
  CLEAR   : lt_vbrp, lv_total.
  REFRESH : lt_vbrp.

  SELECT a~vbeln
         a~posnr
    INTO TABLE lt_vbrp
    FROM vbrp AS a
   INNER JOIN vbrk AS b
      ON a~vbeln = b~vbeln
   WHERE a~vgbel = gt_qlist-vbeln
     AND a~vgpos = gt_qlist-posnr
     AND b~sfakn = ' '
     AND b~fksto = ' '.

  LOOP AT lt_vbrp.
    CLEAR : lv_fkimg, lv_vrkme.

    SELECT a~fkimg
           a~vrkme
      INTO (lv_fkimg, lv_vrkme)
      FROM zfit0023 AS a
     INNER JOIN zfit0022 AS b
        ON a~bukrs = b~bukrs
       AND a~gjahr = b~gjahr
       AND a~monat = b~monat
       AND a~bupla = b~bupla
       AND a~bilnr = b~bilnr
     WHERE a~vbeln = lt_vbrp-vbeln
       AND a~posnr = lt_vbrp-posnr
       AND b~accsign =  'Y'
       AND b~isscnt  <> '000'
       AND b~isstyp NOT IN ('J', 'S', 'C').
*___단위에 따른 수량환산
      PERFORM convert_material_unit(zler0012) USING gt_qlist-matnr
                                                    lv_vrkme
                                                    gt_qlist-vrkme
                                                    lv_fkimg.

      lv_total = lv_total + lv_fkimg.
    ENDSELECT.
  ENDLOOP.

  IF gt_qlist-lfimg > lv_total.
    pv_flag = 'X'.

    MESSAGE s398(00) DISPLAY LIKE 'E'
       WITH '스크랩 자재는 계산서 발행(승인) 후'
            '출력 가능합니다.'
            gt_qlist-vbeln gt_qlist-posnr.
  ENDIF.

ENDFORM.                    " CHECK_BILLING_STATUS
*&---------------------------------------------------------------------*
*&      Form  GET_CHAR_VALUE_DESC
*&---------------------------------------------------------------------*
*       자체개선 44157 - 추가
*----------------------------------------------------------------------*
FORM get_char_value_desc .
  DATA: lv_atinn    LIKE cawn-atinn.

  LOOP AT gt_char1.
    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING
        input  = gt_char1-atnam
      IMPORTING
        output = lv_atinn.

    SELECT SINGLE b~atwtb
      INTO gt_char1-atwtb
      FROM cawn AS a
     INNER JOIN cawnt AS b
        ON a~atinn = b~atinn
       AND a~atzhl = b~atzhl
       AND b~spras = sy-langu
     WHERE a~atinn = lv_atinn
       AND a~atwrt = gt_char1-atwrt.

    MODIFY gt_char1.
  ENDLOOP.

ENDFORM.                    " GET_CHAR_VALUE_DESC
