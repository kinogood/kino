*&---------------------------------------------------------------------*
*& Include          ZGTLER1140F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
FORM initialization .

**
* 거래명세서일자
  IF s_ivdate[] IS INITIAL.
    s_ivdate[] = VALUE #( ( sign = 'I'  option = 'BT'
                            low = sy-datum  high = sy-datum ) ).
  ENDIF.

* [LE] 통문유형 코드
  _clear: gt_0007.
  SELECT *  INTO TABLE @gt_0007
    FROM zlet0007.

  IF gt_0007[] IS NOT INITIAL.
    SORT: gt_0007 BY iv_type.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form authority_check
*&---------------------------------------------------------------------*
FORM authority_check .

  DATA: lv_subrc LIKE sy-subrc,
        lv_type  TYPE char1.

**
  CLEAR: lv_subrc, lv_type.
  lv_type = '5'.
  CALL FUNCTION 'ZGTLE_AUTHORIZATION_CHECK'
    EXPORTING
      i_bzarea = p_bzarea
      i_type   = lv_type
    IMPORTING
      e_subrc  = lv_subrc.

  IF lv_subrc <> 0.
*   사업장 & 에 대한 권한이 없읍니다
    MESSAGE e016 WITH p_bzarea.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form popup_to_confirm
*&---------------------------------------------------------------------*
FORM popup_to_confirm  USING    pi_title
                                pi_text1
                                pi_text2
                       CHANGING pe_answer.

**
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      textline1 = pi_text1
      textline2 = pi_text2
      titel     = pi_title
    IMPORTING
      answer    = pe_answer.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ip_check
*&---------------------------------------------------------------------*
FORM ip_check .

*IP체크해서 등록된 사용
*유지보수 뷰(테이블)에 해당 통문 사업장을 등록된 IP가 있고
*사용여부 Y가 있는 경우 해당 사업장에 대하여 해당 IP만
*통문확정 가능하도록 제한
*(해당사업장으로 등록된 IP가 없는경우 전체 허용)

  DATA: lv_uname LIKE sy-uname,
        lv_ip    LIKE zbc0002t-zip,
        lv_ip1   LIKE zbc0002t-zip,
        lv_c,
        lv_len   TYPE i.

**
  SELECT SINGLE mandt  INTO @DATA(lv_mandt)
    FROM zlet0150  WHERE bzarea EQ @p_bzarea.

  IF sy-subrc = 0.

    CLEAR: lv_ip.
    CALL FUNCTION 'Z_BC_IPADDRESS'
      IMPORTING
        ip = lv_ip.

    CONDENSE lv_ip.
    lv_len = strlen( lv_ip ).

    DO lv_len TIMES.
      IF lv_ip+sy-index(1) NA '0123456789.'.
        CLEAR : lv_ip+sy-index(1).
      ENDIF.
    ENDDO.
    CONDENSE lv_ip NO-GAPS.

    CLEAR: lv_mandt.
    SELECT SINGLE mandt INTO @lv_mandt
      FROM zlet0150  WHERE bzarea EQ @p_bzarea
                       AND zip    EQ @lv_ip
                       AND zuse   EQ 'X'.
    IF sy-subrc <> 0.
*     &1 은 통문사용권한이 없습니다.
      MESSAGE e000 WITH sy-uname TEXT-e01.
    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form screen_1000
*&---------------------------------------------------------------------*
FORM screen_1000 .

**
  LOOP AT SCREEN.
    IF r_com = 'X'.
      IF screen-name = 'S_OUDAT-LOW' OR
         screen-name = 'S_OUDAT-HIGH'.
        screen-input = 0.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form value_request
*&---------------------------------------------------------------------*
FORM value_request  USING    p_value.

* 통문유형 List Box
  TYPE-POOLS vrm.

  DATA: lt_values  TYPE vrm_values WITH HEADER LINE.
*  DATA: lt_values  TYPE TABLE OF vrm_values .

  DATA: lv_vrmid    TYPE vrm_id,
        lv_seq(2)   TYPE c,
        lv_seq_n(2) TYPE n,
        lv_type(30) TYPE c.

**
  _clear: lt_values.
  CLEAR: lv_vrmid, p_gubun1, lv_seq, lv_seq_n, lv_type.

  lv_vrmid = 'P_GUBUN1'.

  lt_values[] = VALUE #( FOR ls_0007 IN gt_0007
                         ( key  = ls_0007-iv_type
                           text = ls_0007-iv_type_nm ) ).

  CHECK: lt_values[] IS NOT INITIAL.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = lv_vrmid
      values          = lt_values[]
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_process
*&---------------------------------------------------------------------*
FORM start_process .

**
  CLEAR: gv_error, gv_iv_type.
  gv_iv_type = p_gubun1.

  PERFORM mm_pp_les_common_process.

  PERFORM tong_moon_data_select.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form mm_pp_les_common_process
*&---------------------------------------------------------------------*
FORM mm_pp_les_common_process .

**
  CHECK: gv_error IS INITIAL.

* 통문유형 SETTING
  _clear: s_ivtyp.
  s_ivtyp[] = VALUE #( ( sign = 'I'  option = 'EQ'  low = p_gubun1 ) ).

* 거래명세서 발행된 DATA중 조건에 해당하는 DATA를 발췌한다.
* 통문증이 삭제되었으면 발췌하지 않는다.
* 거래명세서가 취소된 Data는 미발췌.
* 통문확정/취소 진행한다.
  _clear: gt_tab, gt_out.

  SELECT a~truck_no, a~out_yn, a~iv_type, a~iv_date, a~driver_nm, a~driver_telno,
         a~kunnr,    a~kunnr1, a~umwrk,   a~pernr,   a~ename,
         a~orgeh,    a~orgtx,  a~werks,   a~reqst,   a~rsnum AS rsnum,
         b~iv_no,    b~vbeln,  b~posnr,   b~lfimg,   b~tknum,
         b~maktx,    b~dmbtr,  b~mblnr,   b~zeile,   b~mjahr,
         b~matnr,    b~mtr_unit, b~asset_nm, b~asset_spec, b~asset_etc,
         b~asset_no, b~lgort,  b~gdlgrp,     b~charg AS charg_e,
         c~wbsta

    FROM zlet0005 AS a  INNER JOIN zlet0006 AS b
                        ON a~iv_no = b~iv_no
                        INNER JOIN lips AS c
                        ON b~vbeln EQ c~vbeln
                        AND b~posnr EQ c~posnr
   WHERE a~iv_no        IN @s_ivno
     AND a~bzarea       EQ @p_bzarea
     AND a~iv_type      IN @s_ivtyp
     AND a~iv_cancel_yn NE 'X'
     AND b~tknum        IN @s_tknum
     AND a~iv_date      IN @s_ivdate
    INTO CORRESPONDING FIELDS OF TABLE @gt_tab.

  IF r_com = 'X'.                    "통문확정
    DELETE gt_tab WHERE out_yn = 'X'.
  ELSE.                              "통문취소
    DELETE gt_tab WHERE out_yn = ' '.
  ENDIF.

*-선적문서
  IF GT_TAB[] IS NOT INITIAL.
    DATA(LT_TEMP) = GT_TAB[].
    DELETE LT_TEMP WHERE NOT TKNUM IS INITIAL.
    IF LT_TEMP[] IS NOT INITIAL.
      SELECT A~VBELN, A~TKNUM,
             B~SHTYP, B~EXTI1, B~EXTI2, B~TPBEZ
        FROM VTTP AS A INNER JOIN VTTK AS B
                       ON A~TKNUM = B~TKNUM
         FOR ALL ENTRIES IN @LT_TEMP
       WHERE A~VBELN EQ @LT_TEMP-VBELN
         AND B~SHTYP NE 'Z103'            "해상선적
        INTO TABLE @DATA(LT_VTTP).
      SORT LT_VTTP BY VBELN TKNUM.
    ENDIF.
  ENDIF.

* 통문 미통문 현황 리스트(ZLE0023T) 대상 조회시 헤드 테이블(ZLET0005)의
* REQST 필드값이 X 만 대상으로 기타통문증 발행(ZLE0017T)에서 요청
* 삭제하는 경우 거래명세서 발행여부 필드값삭제 하지 안도록 함
  LOOP AT gt_tab  ASSIGNING FIELD-SYMBOL(<lfs_tab>).

    IF ( <lfs_tab>-iv_type+0(1) = 'E' OR <lfs_tab>-iv_type+0(1) = 'C' )
       AND <lfs_tab>-reqst NE 'X'.
      DELETE gt_tab INDEX sy-tabix.
      CONTINUE.

    ENDIF.

    IF <lfs_tab>-iv_type = 'E12'.
      CONCATENATE <lfs_tab>-maktx <lfs_tab>-charg_e
             INTO <lfs_tab>-maktx SEPARATED BY '-'.
    ENDIF.

    "선적번호
    IF <LFS_TAB>-TKNUM IS INITIAL AND <LFS_TAB>-VBELN IS NOT INITIAL.
      DATA(LS_VTTP) = VALUE #( LT_VTTP[ VBELN = <LFS_TAB>-VBELN ] OPTIONAL ).
      IF LS_VTTP IS NOT INITIAL.
        <LFS_TAB>-TKNUM = LS_VTTP-TKNUM.
        <LFS_TAB>-driver_nm     = LS_VTTP-EXTI2.
        <LFS_TAB>-driver_telno  = LS_VTTP-TPBEZ.
        <LFS_TAB>-truck_no      = LS_VTTP-EXTI1.
      ENDIF.
    ENDIF.

    CLEAR:LS_VTTP.
  ENDLOOP.


  DESCRIBE TABLE gt_tab LINES sy-tfill.
  IF sy-tfill = 0.
*   '조건에 맞는 DATA가 없습니다'.
    MESSAGE s018  DISPLAY LIKE 'E'.
    gv_error = 'X'.
*    IF sy-dynnr = '1000'.
*      STOP.
*    ELSE.
*      LEAVE TO SCREEN 0.
*    ENDIF.

  ENDIF.

**

  FREE:LT_VTTP,LS_VTTP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form tong_moon_data_select
*&---------------------------------------------------------------------*
FORM tong_moon_data_select .

**
  CHECK: gv_error IS INITIAL.

  _clear: gt_out.
  DATA(ls_0007) = VALUE #( gt_0007[ iv_type = p_gubun1 ] OPTIONAL ).
  IF ls_0007 IS NOT INITIAL.
*  IF sy-subrc = 0.
    CASE ls_0007-data.
      WHEN 'SD'.
        PERFORM sd_tong_moon_data_select.

      WHEN 'MM'.
        PERFORM mm_tong_moon_data_select.

      WHEN 'FI'.
        PERFORM mm_ect_tong_moon_data_select.

      WHEN OTHERS.
*       통문유형의 데이터 선택 구분을 확인하십시오.
        MESSAGE s000  WITH TEXT-e02  DISPLAY LIKE 'E'.
        gv_error = 'X'.

    ENDCASE.

    IF gv_error IS INITIAL.
      DESCRIBE TABLE gt_out LINES sy-tfill.
      IF sy-tfill = 0.
*     조건에 맞는 DATA가 없습니다.
        MESSAGE s018  DISPLAY LIKE 'E'.
        gv_error = 'X'.

      ENDIF.

    ENDIF.

  ELSE.

*   통문유형을 확인하십시오.
    MESSAGE s004 WITH TEXT-e03  DISPLAY LIKE 'E'.
    gv_error = 'X'.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form sd_tong_moon_data_select
*&---------------------------------------------------------------------*
FORM sd_tong_moon_data_select .

**
  CHECK: gv_error IS INITIAL,
         gt_tab[] IS NOT INITIAL.

* Truck number Check.
  DATA(lt_data) = gt_tab[].
  IF p_trno IS NOT INITIAL.
    DELETE lt_data WHERE truck_no NE p_trno.
  ENDIF.

* Make Out tab.
  IF lt_data[] IS NOT INITIAL.

    PERFORM get_delivery_data  TABLES  lt_data
                                       gt_likp
                                       gt_lips
                                       gt_lips_uecha
                                       gt_uecha_cnt.

    PERFORM make_sd_out_data   TABLES  lt_data.

  ENDIF.

*  DESCRIBE TABLE gt_out LINES sy-tfill.
*  IF sy-tfill = 0.
**   '조건에 맞는 DATA가 없습니다'.
*    MESSAGE s018  DISPLAY LIKE 'E'.
*    gv_error = 'X'.
**    IF sy-dynnr = '1000'.
**      STOP.
**    ELSE.
**      LEAVE TO SCREEN 0.
**    ENDIF.
*  ENDIF.

**
  FREE: lt_data,
        gt_likp, gt_uecha_cnt, gt_lips, gt_lips_uecha.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_delivery_data
*&---------------------------------------------------------------------*
FORM get_delivery_data  TABLES   pt_data       STRUCTURE gt_tab
                                 pt_likp       STRUCTURE gt_likp
                                 pt_lips       STRUCTURE gt_lips
                                 pt_lips_uecha STRUCTURE gt_lips_uecha
                                 pt_uecha_cnt  STRUCTURE gt_uecha_cnt.

**
  CHECK: pt_data[] IS NOT INITIAL.

  DATA(lt_itab) = pt_data[].

  _clear: pt_likp, pt_lips, pt_lips_uecha, pt_uecha_cnt.

* Get LIKP.
  SELECT b~*
    FROM @lt_itab AS a  INNER JOIN likp AS b
                        ON a~vbeln = b~vbeln
   WHERE b~wadat IN @s_wadat
    INTO CORRESPONDING FIELDS OF TABLE @pt_likp.

* Get Qty / Count
  SELECT b~vbeln,
         b~uecha, COUNT( * ) AS charg_cnt,
                  SUM( b~lfimg ) AS lfimg
    FROM @lt_itab AS a  INNER JOIN lips AS b
                        ON  a~vbeln = b~vbeln
                        AND a~posnr = b~uecha
    GROUP BY b~vbeln, b~uecha
    INTO CORRESPONDING FIELDS OF TABLE @pt_uecha_cnt.

* Get LIPS.
  SELECT b~* , c~auart
    FROM @lt_itab AS a  INNER JOIN lips AS b
                        ON  a~vbeln = b~vbeln
                        AND a~posnr = b~posnr
                        INNER JOIN vbak AS c
                        ON  c~vbeln = b~vgbel
    INTO CORRESPONDING FIELDS OF TABLE @pt_lips.

* Get LIPS with UECHA.
  SELECT b~*, c~auart
    FROM @lt_itab AS a  INNER JOIN lips AS b
                        ON  b~vbeln = a~vbeln
                        AND b~uecha = a~posnr
                        INNER JOIN vbak AS c
                        ON  c~vbeln = b~vgbel
    INTO CORRESPONDING FIELDS OF TABLE @pt_lips_uecha.

**
  FREE: lt_itab.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_sd_out_data
*&---------------------------------------------------------------------*
FORM make_sd_out_data  TABLES   pt_data       STRUCTURE gt_tab.

  DATA: lv_lfimg       LIKE lips-lfimg,
        lv_charg_cnt   TYPE i,
        lv_continue(1),

        ls_likp        LIKE likp,
        ls_lips        LIKE lips.

**
  CHECK: pt_data[] IS NOT INITIAL.

  SORT: gt_likp       BY vbeln,
        gt_uecha_cnt  BY vbeln uecha,
        gt_lips       BY vbeln posnr,
        gt_lips_uecha BY vbeln uecha.

  LOOP AT pt_data  INTO DATA(ls_data).

    CLEAR: lv_lfimg, lv_charg_cnt, lv_continue,
           ls_likp,  ls_lips.

    PERFORM check_delivery_data    USING    ls_data
                                   CHANGING lv_lfimg
                                            lv_charg_cnt
                                            ls_likp
                                            ls_lips
                                            lv_continue.

    IF lv_continue IS NOT INITIAL.
      CONTINUE.
    ELSE.
      ls_data-charg_cnt = lv_charg_cnt.
    ENDIF.

**  Move Data
    CLEAR: gs_out.
    gs_out = CORRESPONDING #( ls_data ).

    IF gs_out-out_yn = 'X'.
      gs_out-out_yn = 'Y'.
    ELSE.
      gs_out-out_yn = 'N'.
    ENDIF.
    gs_out-gjosa     = ls_data-lfimg.
    gs_out-matnr     = ls_lips-matnr.
    gs_out-vrkme     = ls_lips-vrkme.
    gs_out-vgbel     = ls_lips-vgbel.
    gs_out-vgpos     = ls_lips-vgpos.
    gs_out-arktx     = ls_lips-arktx.
*    gs_out-wadat     = ls_likp-wadat_ist.
    gs_out-wadat     = ls_likp-wadat.
    gs_out-lfimg     = lv_lfimg.

*   통문유형 표기
    IF gs_out-iv_type = 'A01'.
      gs_out-iv_tdes = '제상품매출'.
    ELSEIF gs_out-iv_type = 'A02'.
      gs_out-iv_tdes = '사업장간이동'.
    ENDIF.

*   납품처
    PERFORM get_kunnr_desc_vbpa  USING    ls_likp-vbeln
                                 CHANGING gs_out-name1.

*   조장, 조장수, 색상, 포장, 포장재유형
    PERFORM atnam_data_search    USING    ls_data-matnr
                                          ls_lips-charg
                                          lv_lfimg
                                          ls_data-charg_cnt
                                          ls_data-vbeln
                                          ls_data-posnr
                                 CHANGING gs_out-jojan
                                          gs_out-packg
                                          gs_out-packc
                                          gs_out-color
                                          gs_out-jojsu.
    IF gs_out-jojan > 0.

      IF ls_lips-meins <> ls_lips-vrkme.
*       기본단위와 판매단위 상이할때
        gs_out-jojan = gs_out-jojan * ls_lips-umvkn / ls_lips-umvkz.
      ENDIF.

    ENDIF.

*   자재명
    PERFORM get_matnr_desc       USING    gs_out-packg
                                          ' '
                                 CHANGING gs_out-packg_t.

*   조장 미존재
*    IF gs_out-jojan IS INITIAL.
*    ELSE.
*      gs_out-jojsu = ls_data-lfimg / gs_out-jojan.
*    ENDIF.

*   차량번호, 운송기사, 운전자전화번호
    IF NOT gs_out-tknum IS INITIAL.

      PERFORM set_driver_info      USING     gs_out-tknum
                                   CHANGING  gs_out-truck_no
                                             gs_out-driver_nm
                                             gs_out-driver_telno
                                             gs_out-tdlnr
                                             gs_out-tdlnr_t.

    ENDIF.

    APPEND: gs_out TO gt_out.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_delivery_data
*&---------------------------------------------------------------------*
FORM check_delivery_data  USING    ps_data       LIKE gt_tab
                          CHANGING pe_lfimg
                                   pe_charg_cnt
                                   ps_likp       LIKE likp
                                   ps_lips       LIKE lips
                                   pe_continue.

**
  CHECK: ps_data IS NOT INITIAL.

* 해당되는 출고일에 납품된 문서를 기준
* -> 출고여부와 관계없이 데이터 추출
  DATA(ls_likp) = VALUE #( gt_likp[ vbeln = ps_data-vbeln ] OPTIONAL ).
  IF ls_likp IS NOT INITIAL AND
     ls_likp-wadat IN s_wadat.

*     Check lifmg, count.
    DATA(ls_uecha_cnt) = VALUE #( gt_uecha_cnt[ vbeln = ps_data-vbeln
                                                uecha = ps_data-posnr ] OPTIONAL ).
    IF ls_uecha_cnt IS NOT INITIAL.
      pe_lfimg     = ls_uecha_cnt-lfimg.
      pe_charg_cnt = ls_uecha_cnt-charg_cnt.

*      IF pe_charg_cnt IS NOT INITIAL.
*        pe_charg_cnt = pe_charg_cnt + 1.
*      ENDIF.

    ENDIF.

*     Check LIPS
    DATA(ls_lips) = VALUE #( gt_lips[ vbeln = ps_data-vbeln
                                      posnr = ps_data-posnr ] OPTIONAL ).
    IF ls_lips IS NOT INITIAL .

      IF ls_lips-charg IS NOT INITIAL.
        pe_charg_cnt = 1.
        pe_lfimg     = ls_lips-lfimg.

      ELSE.
        DATA(lv_rechk) = 'X'.
      ENDIF.

    ELSE.
      lv_rechk = 'X'.
    ENDIF.

    IF lv_rechk = 'X'.
      DATA(ls_lips_uecha) = VALUE #( gt_lips_uecha[ vbeln = ps_data-vbeln
                                                    uecha = ps_data-posnr ] OPTIONAL ).
      IF ls_lips_uecha IS NOT INITIAL.
*      IF sy-subrc = 0.
        ls_lips = ls_lips_uecha.
      ENDIF.
    ENDIF.

*   통문 미확정 대상 삭제
    IF ls_likp-vsart <> '09'   AND    "직납품
       ls_likp-vbtyp <> 'T'    AND    "반품입고
       ls_likp-vstel <> '9100' AND    "대구물류정
       ls_lips-auart <> 'ZBC2' AND    "직송판매
       ls_lips-auart <> 'KE'   AND    "VMI 창고매출
       ls_lips-auart <> 'Z3RD' AND    "삼각무역
       ls_lips-auart <> 'ZORT'.    "전수배출고 060626추가 기계PJT요청

*     기계용 예외처리 TABLE사용. 해당하는 출하지점은 대상제외.
      SELECT SINGLE desc1  INTO @DATA(ls_desc1)
        FROM zsd0114t  WHERE zgubun  = 'E'
                         AND spart   = '71'
                         AND auart   = @ls_likp-vstel
                         AND zuse_yn = 'Y'.

      IF sy-subrc = 0.
        pe_continue = 'X'.
      ENDIF.

*     통문확정시 확정 미대상 삭제
      IF pe_continue IS INITIAL AND
         r_com = 'X'.
        IF ls_likp-zout = 'X'.
          pe_continue = 'X'.
        ENDIF.

      ENDIF.

    ELSE.
      pe_continue = 'X'.
    ENDIF.

    IF pe_continue IS INITIAL.
      ps_likp = CORRESPONDING #( ls_likp ).
      ps_lips = CORRESPONDING #( ls_lips ).
    ENDIF.

  ENDIF.

**
  FREE: ls_likp, ls_uecha_cnt,
        ls_lips, ls_lips_uecha.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_kunnr_desc_vbpa
*&---------------------------------------------------------------------*
FORM get_kunnr_desc_vbpa  USING    pi_vbeln
                          CHANGING pe_name1.

**
  CHECK: pi_vbeln IS NOT INITIAL.

  SELECT SINGLE b~name1  INTO @pe_name1
    FROM vbpa AS a  INNER JOIN adrc AS b
                    ON a~adrnr = b~addrnumber
   WHERE a~vbeln EQ @pi_vbeln
     AND a~posnr EQ '000000'
     AND a~parvw EQ 'WE'.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form atnam_data_search
*&---------------------------------------------------------------------*
FORM atnam_data_search  USING    pi_matnr
                                 pi_charg
                                 pi_lfimg
                                 pi_charg_cnt
                                 pi_vbeln
                                 pi_posnr
                        CHANGING pe_jojan
                                 pe_packg
                                 pe_packc
                                 pe_color
                                 pe_jojsu.

  DATA: lv_value(13)  TYPE p DECIMALS 3,
        lv_objek      LIKE kssk-objek,  "TYPE OBJNUM,
        lv_objno      LIKE inob-cuobj,  "TYPE CUOBJ,
        lv_objek_ausp LIKE ausp-objek,  "TYPE OBJNUM.

        ls_mckey      LIKE mch1_key,

        lr_atnam      LIKE RANGE OF cabn-atnam.

**
  CHECK: gv_error IS INITIAL.

  _clear: lr_atnam.
  lr_atnam[] = VALUE #( ( sign = 'I'  option = 'EQ'
                                      low = gc_length )        "조장
                        ( sign = 'I'  option = 'EQ'
                                      low = gc_factor )        "조장수
                        ( sign = 'I'  option = 'EQ'
                                      low = gc_packaging )     "포장재
                        ( sign = 'I'  option = 'EQ'
                                      low = gc_packaging_cat ) "포장재유형
                        ( sign = 'I'  option = 'EQ'
                                      low = gc_color ) ).      "색상

  SELECT DISTINCT atinn, atnam INTO TABLE @DATA(lt_atinn)
    FROM cabn  WHERE atnam IN @lr_atnam.

  CLEAR: lv_objek, lv_objno, ls_mckey,
         lv_objek_ausp.
  ls_mckey = VALUE #( matnr = pi_matnr
                      charg = pi_charg ).
  lv_objek = ls_mckey.

  CALL FUNCTION 'CUOB_GET_NUMBER'
    EXPORTING
      class_type       = '023'
      object_id        = lv_objek
      table            = 'MCH1'
    IMPORTING
      object_number    = lv_objno
    EXCEPTIONS
      lock_problem     = 1
      object_not_found = 2
      OTHERS           = 3.

  IF sy-subrc = 0.

    lv_objek_ausp = lv_objno.

    SELECT * INTO TABLE @DATA(lt_ausp)
      FROM ausp  FOR ALL ENTRIES IN @lt_atinn
     WHERE objek = @lv_objek_ausp
       AND atinn = @lt_atinn-atinn
       AND klart = '023'.

    IF sy-subrc = 0.

      LOOP AT lt_atinn  INTO DATA(ls_atinn).

        DATA(ls_ausp) = VALUE #( lt_ausp[ atinn = ls_atinn-atinn ] OPTIONAL ).

*       조장
        CASE ls_atinn-atnam.
          WHEN gc_length .        "조장
            IF ls_ausp-atflv > 0.
              lv_value = ls_ausp-atflv.
              pe_jojan = lv_value.
            ENDIF.

          WHEN gc_factor .        "조장수
          WHEN gc_packaging .     "포장재
            pe_packg = ls_ausp-atwrt.

          WHEN gc_packaging_cat . "포장재유형
            pe_packc = ls_ausp-atwrt.

          WHEN gc_color .         "색상
            pe_color = ls_ausp-atwrt.

        ENDCASE.

      ENDLOOP.

    ENDIF.

  ENDIF.

* 싱글유닛 배치는 납품수량이 조장
  SELECT SINGLE xpcbt  INTO @DATA(lv_xpcbt)
    FROM mch1  WHERE matnr EQ @pi_matnr
                 AND charg EQ @pi_charg.

  IF lv_xpcbt = 'X'.

    IF NOT pi_charg_cnt IS INITIAL.
      pe_jojan = pi_lfimg / pi_charg_cnt.
    ENDIF.

  ENDIF.

  SELECT SINGLE length, factor
    FROM zgtsd_cv_get_dlvqty_factor
   WHERE vbeln EQ @pi_vbeln
     AND posnr EQ @pi_posnr
  INTO ( @pe_jojan, @pe_jojsu ).

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_matnr_desc
*&---------------------------------------------------------------------*
FORM get_matnr_desc  USING    pi_matnr
                              pi_spras
                     CHANGING pe_maktx.

  DATA: lv_spras  LIKE makt-spras.

**
  CHECK: pi_matnr IS NOT INITIAL.

  IF pi_spras IS NOT INITIAL.
    lv_spras = pi_spras.
  ELSE.
    lv_spras = sy-langu.
  ENDIF.

  SELECT SINGLE maktx  INTO @pe_maktx
    FROM makt  WHERE matnr = @pi_matnr
                 AND spras = @lv_spras.    "sy-langu.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_driver_info
*&---------------------------------------------------------------------*
FORM set_driver_info  USING    pi_tknum
                      CHANGING pe_truck_no
                               pe_driver_nm
                               pe_driver_telno
                               pe_tdlnr
                               pe_tdlnr_t.

**
  SELECT SINGLE tdlnr, exti1, exti2, tpbez
    INTO @DATA(ls_vttk)
    FROM vttk  WHERE tknum EQ @pi_tknum.

  IF ls_vttk IS NOT INITIAL.

    SELECT SINGLE name1  INTO @pe_tdlnr_t
      FROM lfa1  WHERE lifnr EQ @ls_vttk-tdlnr.

    pe_tdlnr = ls_vttk-tdlnr.

    IF pe_truck_no IS INITIAL.
      pe_truck_no = ls_vttk-exti1.
    ENDIF.

    IF pe_driver_nm IS INITIAL.
      pe_driver_nm = ls_vttk-exti2.
    ENDIF.

    IF pe_driver_telno IS INITIAL.
      pe_driver_telno = ls_vttk-tpbez.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form mm_tong_moon_data_select
*&---------------------------------------------------------------------*
FORM mm_tong_moon_data_select .

**
  CHECK: gv_error IS INITIAL,
         gt_tab[] IS NOT INITIAL.

* Truck number Check.
  DATA(lt_data) = gt_tab[].
  IF p_trno IS NOT INITIAL.
    DELETE lt_data WHERE truck_no NE p_trno.
  ENDIF.

  LOOP AT lt_data  INTO DATA(ls_data).

    CLEAR: gs_out.
    gs_out = CORRESPONDING #( ls_data ).

*   통문 유/무 필드 변경
    IF gs_out-out_yn = 'X'.           "통문확정
      gs_out-out_yn = 'Y'.
    ELSE.
      gs_out-out_yn = 'N'.            "통문취소
    ENDIF.

    IF p_gubun1 = 'D01' OR p_gubun1 = 'D02'.
      PERFORM get_matnr_desc_0019    USING    gs_out-matnr
                                     CHANGING gs_out-maktx.

    ELSE.
      PERFORM get_matnr_desc         USING    gs_out-matnr
                                              '3'
                                     CHANGING gs_out-maktx.

    ENDIF.

*   이동유형별 Description
    PERFORM get_tong_moon_type_desc  USING    gt_out-iv_type
                                     CHANGING gt_out-iv_tdes.

*   Y91이동유형일때 이동사유가 0001(현장직납)일 경우 통문대상에서 제외
    IF gs_out-iv_type = 'B11'.
      SELECT SINGLE mandt  INTO @DATA(lv_mandt)
        FROM mseg  WHERE mblnr EQ @gs_out-mblnr
                     AND mjahr EQ @gs_out-mjahr
                     AND zeile EQ @gs_out-zeile
                     AND ablad EQ '직납'.
      IF sy-subrc NE 0.
        APPEND gs_out TO gt_out.
      ENDIF.

    ELSE.
      APPEND gs_out TO gt_out.

    ENDIF.

  ENDLOOP.
*
*  DESCRIBE TABLE gt_out LINES sy-tfill.
*  IF sy-tfill = 0.
*    MESSAGE s005(zle1) WITH '조건에 맞는 DATA가 없습니다'.
*    IF sy-dynnr = '1000'.
*      STOP.
*    ELSE.
*      LEAVE TO SCREEN 0.
*    ENDIF.
*  ENDIF.
*
**
  FREE: lt_data.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_matnr_desc_0019
*&---------------------------------------------------------------------*
FORM get_matnr_desc_0019  USING    pi_matnr
                          CHANGING pe_maktx.

**
  CHECK: pi_matnr IS NOT INITIAL.

  SELECT SINGLE maktx INTO @pe_maktx
    FROM zmmt0019  WHERE matnr EQ @pi_matnr.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_tong_moon_type_desc
*&---------------------------------------------------------------------*
FORM get_tong_moon_type_desc  USING    pi_iv_type
                              CHANGING pe_iv_desc.

**
  CHECK: pi_iv_type IS NOT INITIAL.

  IF gt_0007[] IS NOT INITIAL.
    pe_iv_desc = VALUE #( gt_0007[ iv_type = pi_iv_type ]-iv_type_nm  OPTIONAL ).

  ELSE.
    SELECT SINGLE iv_type_nm  INTO @pe_iv_desc
      FROM zlet0007  WHERE iv_type EQ @pi_iv_type.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form mm_ect_tong_moon_data_select
*&---------------------------------------------------------------------*
FORM mm_ect_tong_moon_data_select .

**
  CHECK: gv_error IS INITIAL,
         gt_tab[] IS NOT INITIAL.

* Truck number Check.
  DATA(lt_data) = gt_tab[].
  IF p_trno IS NOT INITIAL.
    DELETE lt_data WHERE truck_no NE p_trno.
  ENDIF.

  LOOP AT lt_data  INTO DATA(ls_data).

    IF ls_data-iv_type+0(1) = 'E' AND ls_data-reqst = ' '.
      CONTINUE.
    ENDIF.

    CLEAR: gs_out.
    gs_out = CORRESPONDING #( ls_data ).

*   통문 유/무 필드 변경
    IF gs_out-out_yn = 'X'.           "통문확정
      gs_out-out_yn = 'Y'.
    ELSE.
      gs_out-out_yn = 'N'.            "통문취소
    ENDIF.

*   구매처
    PERFORM get_name_field           USING    'LFA1'
                                              ls_data-kunnr
                                     CHANGING gs_out-kunnr
                                              gs_out-name1.

*   납품처
    PERFORM get_name_field           USING    'KNA1'
                                              ls_data-kunnr1
                                     CHANGING gs_out-kunnr
                                              gs_out-name1.

*   사내소비 plant
    PERFORM get_name_field           USING    'T001W'
                                              ls_data-umwrk
                                     CHANGING gs_out-kunnr
                                              gs_out-name1.

*   PLANT 명
    PERFORM get_plant_desc           USING    ls_data-werks
                                     CHANGING gs_out-werks_t.

*   이동유형별 Description
    PERFORM get_tong_moon_type_desc  USING    gt_out-iv_type
                                     CHANGING gt_out-iv_tdes.

    APPEND gs_out TO gt_out.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_name_field
*&---------------------------------------------------------------------*
FORM get_name_field  USING    pi_type
                              pi_value
                     CHANGING pe_kunnr
                              pe_name1.

  DATA: lv_lifnr TYPE lifnr,
        lv_kunnr TYPE kunnr,
        lv_werks TYPE werks_d.

**
  CHECK: pi_value IS NOT INITIAL.

  CASE pi_type.
    WHEN 'LFA1'.
      CLEAR: lv_lifnr.
      lv_lifnr = pi_value.

      SELECT SINGLE name1  INTO @pe_name1
        FROM lfa1  WHERE lifnr EQ @lv_lifnr.

      pe_kunnr = pi_value.

    WHEN 'KNA1'.
      CLEAR: lv_kunnr.
      lv_kunnr = pi_value.

      SELECT SINGLE name1  INTO @pe_name1
        FROM kna1  WHERE kunnr EQ @lv_kunnr.

      pe_kunnr = pi_value.

    WHEN 'T001W'.
      CLEAR: lv_werks.
      lv_werks = pi_value.

      SELECT SINGLE name1  INTO @pe_name1
        FROM t001w  WHERE werks EQ @lv_werks.

      pe_kunnr = pi_value.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_plant_desc
*&---------------------------------------------------------------------*
FORM get_plant_desc  USING    pi_werks
                     CHANGING pe_name1.

**
  CHECK: pi_werks IS NOT INITIAL.

  SELECT SINGLE name1  INTO @pe_name1
    FROM t001w  WHERE werks EQ @pi_werks.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form end_process
*&---------------------------------------------------------------------*
FORM end_process .

**
  CHECK: gv_error IS INITIAL.

  CLEAR: gv_out_date.
  gv_out_date = sy-datum.

  DESCRIBE TABLE gt_out LINES gv_tot_cnt.
  IF gv_tot_cnt > 0.
    CALL SCREEN 100.

  ELSE.
*   해당하는 자료가 없습니다.
    MESSAGE s000 WITH TEXT-e04  DISPLAY LIKE 'E'.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form data_changed_finished
*&---------------------------------------------------------------------*
FORM data_changed_finished  USING  pt_good_cells  TYPE lvc_t_modi
                                   po_sender.

**
  DATA(ls_good_cells) = VALUE #( pt_good_cells[ 1 ]  OPTIONAL ).

  DATA(ls_out) = VALUE #( gt_out[ ls_good_cells-row_id ]  OPTIONAL ).

  IF ls_good_cells-fieldname = 'CHK'.

    PERFORM get_grid_control .

    IF r_cnc = 'X'.
*     BILLING 완료되면 선적취소 할 수 없음.
      PERFORM message_spread   USING  ls_out-iv_no.

    ENDIF.

    PERFORM change_data_from_inside_grid  USING  po_sender.

  ENDIF.

**

* Old

** 헤더별 선택 제어
*    DATA : ls_good_cells LIKE LINE OF et_good_cells.
*    DATA : is_gt LIKE gt_out.
*    CLEAR: gt_out-alv_col[].
*
*    READ TABLE et_good_cells INTO ls_good_cells INDEX 1.
*    gv_index = ls_good_cells-row_id.
*    READ TABLE  gt_out  INTO is_gt INDEX gv_index.
*    gv_iv_no = is_gt-iv_no.
*
**   GRID1 속성
*    IF ls_good_cells-fieldname = 'CHK'.
*      PERFORM get_grid1_control.
**        IF SY-DYNNR = '0200'.
*      IF r_cnc = 'X'.
**         BILLING 완료되면 선적취소 할 수 없음.
*        PERFORM message_spread.
*      ENDIF.
*      PERFORM change_data_from_inside_grid1.
**       CALL METHOD grid1->refresh_table_display.
*    ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_grid_control
*&---------------------------------------------------------------------*
FORM get_grid_control .

  DATA: lv_mark(1).

**
  DATA(lt_tab) = gt_out[].
  SORT: lt_tab BY iv_no.
  DELETE lt_tab WHERE chk NE 'X'.
  DELETE ADJACENT DUPLICATES FROM lt_tab COMPARING iv_no.

  CHECK: lt_tab[] IS NOT INITIAL.

  LOOP AT lt_tab  INTO DATA(ls_tab).

    AT NEW iv_no.
      DATA(ls_line) = VALUE #( gt_out[ iv_no = ls_tab-iv_no
                                       chk   = ' '
                                       fg    = 'X' ]  OPTIONAL ).
*      IF sy-subrc = 0.
      IF ls_line IS NOT INITIAL.
        DATA(lv_chk) = 'X'.
      ELSE.
        CLEAR: lv_chk.
      ENDIF.
    ENDAT.

    CLEAR: lv_mark.
    IF lv_chk IS NOT INITIAL.
      CLEAR: lv_mark.
    ELSE.
      lv_mark = 'X'.
    ENDIF.

    MODIFY gt_out  FROM VALUE #( chk = lv_mark
                                 fg  = lv_mark )
                        TRANSPORTING chk fg
                   WHERE iv_no = ls_tab-iv_no.

  ENDLOOP.

**
  FREE: lt_tab.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form message_spread
*&---------------------------------------------------------------------*
FORM message_spread  USING    pi_iv_no.

  DATA: lt_msg_tab LIKE zles009 OCCURS 0 WITH HEADER LINE,
        ls_msg_tab LIKE zles009,

        BEGIN OF lt_err OCCURS 0,
          iv_no LIKE zlet0005-iv_no,
          vbeln LIKE lips-vbeln,
          posnr LIKE lips-posnr,
        END OF lt_err,
        ls_err LIKE lt_err.

**
  DATA(lt_data) = gt_out[].
  DELETE lt_data  WHERE iv_no NE pi_iv_no
                    AND chk   NE 'X'.

  CHECK: lt_data[] IS NOT INITIAL.

  SELECT vbeln, fkstk  INTO TABLE @DATA(lt_likp)
    FROM likp  FOR ALL ENTRIES IN @lt_data
   WHERE vbeln EQ @lt_data-vbeln
     AND fkstk EQ 'C'.

  _clear: lt_err.
  LOOP AT lt_data  INTO DATA(ls_data).

    DATA(ls_likp) = VALUE #( lt_likp[ vbeln = ls_data-vbeln ]  OPTIONAL ).

    IF ls_likp IS NOT INITIAL.
*    IF sy-subrc = 0.
      CLEAR: ls_err.
      MOVE-CORRESPONDING ls_data TO ls_err .
      APPEND ls_err TO lt_err.

      DATA(lv_bkfg) = 'X'.
    ENDIF.

  ENDLOOP.

  IF lv_bkfg IS NOT INITIAL.
    MODIFY gt_out  FROM VALUE #( chk = ' ' )
                        TRANSPORTING chk
                   WHERE iv_no = pi_iv_no.
  ENDIF.

  DESCRIBE TABLE lt_err LINES sy-tfill.
  IF sy-tfill > 0.

    _clear: lt_msg_tab.
    LOOP AT lt_err  INTO ls_err.

      CLEAR: ls_msg_tab.
      ls_msg_tab-msgtx = |IVNO: |  && ls_err-iv_no  &&
                         |납품문서: |  && ls_err-vbeln  &&
                         |항번: |  && ls_err-posnr  &&
                         |은 빌링완료 되어 통문취소 불가.|.
*      CONCATENATE 'IVNO: ' lv_err-iv_no '납품문서: ' lv_err-vbeln
*                   '항번: ' lv_err-posnr
*                  '은 빌링완료 되어 통문취소 불가'
*                  INTO lv_msg_tab-msgtx.

      APPEND ls_msg_tab  TO lt_msg_tab.

    ENDLOOP.

    IF lt_msg_tab[] IS NOT INITIAL.
      CALL FUNCTION 'Z_LE_POPUP_TO_ERROR_MESSAGE'
        TABLES
          msg_tab = lt_msg_tab.
    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form change_data_from_inside_grid
*&---------------------------------------------------------------------*
FORM change_data_from_inside_grid  USING    po_sender
                                            TYPE REF TO cl_gui_alv_grid.

**
  CLEAR: gv_chk_cnt.
  gv_chk_cnt = REDUCE i( INIT x = 0  FOR ls_out IN gt_out
                         WHERE ( chk = 'X' )
                         NEXT x = x + 1 ).

  PERFORM refresh_alv             USING  po_sender.

**

* Old
*  CLEAR: p_chk_cnt.
*  LOOP AT gt_out WHERE chk = 'X'.
*    ADD 1  TO p_chk_cnt.
*  ENDLOOP.
*
*  CALL METHOD grid1->refresh_table_display
*    EXPORTING
*      i_soft_refresh = 'X'
*      is_stable      = l_scroll.     "현재 그대로 입력한 refresh
*
*  LEAVE TO SCREEN 100.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form data_changed
*&---------------------------------------------------------------------*
FORM data_changed  USING    pr_data_changed
                            TYPE REF TO cl_alv_changed_data_protocol.

  DATA : ls_mod_cells TYPE lvc_s_modi,
         ls_cells     TYPE lvc_s_modi.

**
  LOOP AT pr_data_changed->mt_good_cells INTO ls_mod_cells.
*    CASE LS_MOD_CELLS-FIELDNAME.
*
*    ENDCASE.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form import_driver_info
*&---------------------------------------------------------------------*
FORM import_driver_info .

**
* Selected Line
  PERFORM check_selected_rows    USING    gv_save_cd
                                 CHANGING gv_error.

* Car/Driver Info
  PERFORM check_line_car_info    CHANGING gv_error
                                          gs_car_info.

  CHECK: gv_error IS INITIAL.
  CALL SCREEN 0300  STARTING AT  10  5.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_selected_rows
*&---------------------------------------------------------------------*
FORM check_selected_rows  USING    pi_ucomm
                          CHANGING pe_error.

**
  DATA(lv_cnt) = REDUCE i( INIT x = 0  FOR ls_out IN gt_out
                         WHERE ( chk = 'X' )
                         NEXT x = x + 1 ).

  IF lv_cnt IS INITIAL.
*   선택된 라인이 없습니다.
    MESSAGE s000  WITH TEXT-e05 DISPLAY LIKE 'E'.
    pe_error = 'X'.
  ELSE.

    IF pi_ucomm = 'GI'.    " 출고지시

      DATA(lt_out) = gt_out[].
      DELETE lt_out WHERE chk NE 'X'.
      SORT: lt_out BY tknum.
      DELETE ADJACENT DUPLICATES FROM lt_out COMPARING tknum.

      DATA(lv_line) = lines( lt_out[] ).

      IF lv_line > 1.
*       하나의 선적문서만 선택할 수 있습니다.
        MESSAGE s000  WITH TEXT-e12  DISPLAY LIKE 'E'.
        pe_error = 'X'.
      ENDIF.
    ENDIF.

  ENDIF.

**
  FREE: lt_out.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_line_car_info
*&---------------------------------------------------------------------*
FORM check_line_car_info  CHANGING pe_error
                                   ps_car_info  LIKE gs_car_info.

**
  CHECK: gv_error IS INITIAL.

  CLEAR: ps_car_info, gs_car_temp.

  DATA(lt_data) = gt_out[].
  DELETE: lt_data  WHERE chk NE 'X',
          lt_data  WHERE truck_no     IS INITIAL
                     AND driver_nm    IS INITIAL
                     AND driver_telno IS INITIAL.

  CHECK: lt_data[] IS NOT INITIAL.

  DATA(ls_data) = VALUE #( lt_data[ 1 ]  OPTIONAL ).
  IF ls_data IS NOT INITIAL.
    ps_car_info-truck_no     = ls_data-truck_no.
    ps_car_info-driver_nm    = ls_data-driver_nm.
    ps_car_info-driver_telno = ls_data-driver_telno.
  ENDIF.

  IF ps_car_info IS NOT INITIAL.
    gs_car_temp = ps_car_info.
  ENDIF.

**
  FREE: lt_data.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_new_car_info
*&---------------------------------------------------------------------*
FORM set_new_car_info .

**
  CHECK: gv_error IS INITIAL.

  CLEAR: gv_answer.
  IF     gs_car_info IS INITIAL .
    PERFORM popup_to_confirm     USING    '배차정보 입력'
                                          '배차정보가 입력되지 않았습니다.'
                                          '진행 하시겠습니까?'
                                 CHANGING gv_answer.

  ELSEIF gs_car_info-truck_no     IS INITIAL OR
         gs_car_info-driver_nm    IS INITIAL OR
         gs_car_info-driver_telno IS INITIAL.
    PERFORM popup_to_confirm     USING    '배차정보 입력'
                                          '누락된 배차정보가 있습니다.'
                                          '진행 하시겠습니까?'
                                 CHANGING gv_answer.

  ELSEIF gs_car_temp EQ gs_car_info.

    PERFORM popup_to_confirm     USING    '배차정보 입력'
                                          '배차정보가 변경되지 않았습니다.'
                                          '적용 하시겠습니까?'
                                 CHANGING gv_answer.
  ELSE.
    gv_answer = 'J'.
  ENDIF.

  IF gv_answer EQ 'J'.
    LOOP AT gt_out  ASSIGNING FIELD-SYMBOL(<lfs_wa>)
                    WHERE chk = 'X'.

      <lfs_wa>-truck_no     = gs_car_info-truck_no.
      <lfs_wa>-driver_nm    = gs_car_info-driver_nm.
      <lfs_wa>-driver_telno = gs_car_info-driver_telno.

    ENDLOOP.

  ELSE.
    gv_error = 'X'.
*   작업이 취소되었습니다.
    MESSAGE s050 .

  ENDIF.

  LEAVE TO SCREEN 0.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form tong_moon_check
*&---------------------------------------------------------------------*
FORM tong_moon_check .

**
  CHECK: gv_error IS INITIAL.

  _clear: gt_confirm.
* Selected Line
  PERFORM check_selected_rows      USING    gv_save_cd
                                   CHANGING gv_error.

* Check Dirver Info
  PERFORM check_select_line_data   USING    gv_save_cd
                                   CHANGING gv_error.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_select_line_data
*&---------------------------------------------------------------------*
FORM check_select_line_data  USING    pi_ucomm
                             CHANGING pe_error.

**
  CHECK: pe_error  IS INITIAL.

  DATA(lt_data) = gt_out[].
  DELETE lt_data WHERE chk NE 'X'.

  LOOP AT lt_data  INTO DATA(ls_data).

    CASE pi_ucomm.
      WHEN 'COM'.    " 통문확정.
*       Passing Check
        PERFORM check_passing_gate       USING    'F'
                                                  ls_data
                                         CHANGING pe_error.

*       Driver Info Check ( with TKNUM )
        PERFORM check_driver_for_tknum   USING    ls_data-tknum
                                                  ls_data-driver_nm
                                                  ls_data-driver_telno
                                                  ls_data-truck_no
                                         CHANGING pe_error.
      WHEN 'CANC'.    " 통문취소.
*       Passing Check
        PERFORM check_passing_gate       USING    'C'
                                                  ls_data
                                         CHANGING pe_error.
*       반입수량 Check.
        PERFORM check_already_inimg      USING    ls_data-iv_no
                                         CHANGING pe_error.

    ENDCASE.

    IF pe_error IS NOT INITIAL.
      EXIT.
    ELSE.
      APPEND ls_data TO gt_confirm.

    ENDIF.

  ENDLOOP.

  IF pe_error IS INITIAL.
    DESCRIBE TABLE gt_confirm LINES sy-tfill.
    IF sy-tfill = 0.
      pe_error = 'X'.
*     처리할 데이타를 선택 하세요.
      MESSAGE s004  DISPLAY LIKE 'E'.

    ENDIF.

  ENDIF.

**
  FREE: lt_data.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_passing_gate
*&---------------------------------------------------------------------*
FORM check_passing_gate  USING    pi_ind
                                  ps_data    LIKE gs_out
                         CHANGING pe_error.

**
  CHECK: pe_error IS INITIAL.

* 해당 납품문서 Lock 점검
  PERFORM check_lock_obj_evvblke    USING    ps_data-vbeln
                                    CHANGING pe_error.

  IF pe_error IS INITIAL.
    SELECT SINGLE out_yn  INTO @DATA(lv_outyn)
      FROM zlet0005  WHERE iv_no = @ps_data-iv_no.

    IF pi_ind = 'F'.   "통문확정
      IF lv_outyn IS NOT INITIAL.
        pe_error = 'X'.

*       통문번호 &1 은(는) 이미 통문확정 처리되었습니다.
        MESSAGE s000  WITH TEXT-e08 ps_data-iv_no TEXT-e06
                      DISPLAY LIKE 'E'.

      ENDIF.
    ELSE.              "통문확정취소
      IF lv_outyn IS INITIAL.
        pe_error = 'X'.

*       통문번호 &1 은(는) 이미 통문확정 취소 처리되었습니다.
        MESSAGE s000  WITH TEXT-e08 ps_data-iv_no TEXT-e07
                      DISPLAY LIKE 'E'.

      ENDIF.
    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_lock_obj_evvblke
*&---------------------------------------------------------------------*
FORM check_lock_obj_evvblke  USING    pi_vbeln
                             CHANGING pe_error.

**
  CHECK: pi_vbeln IS NOT INITIAL.

  CALL FUNCTION 'ENQUEUE_EVVBLKE'
    EXPORTING
      vbeln          = pi_vbeln
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

  IF sy-subrc = 0.
    CALL FUNCTION 'DEQUEUE_EVVBLKE'
      EXPORTING
        vbeln = pi_vbeln.
  ELSE.
    pe_error = 'X'.

    DATA(lv_msgv1) = sy-msgv1.

*   이 납품 &1은(는) 현재 다른 사용자 &2에 의해 처리되고 있습니다.
    MESSAGE s046(vl) WITH pi_vbeln lv_msgv1  DISPLAY LIKE 'E'.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_driver_for_tknum
*&---------------------------------------------------------------------*
FORM check_driver_for_tknum  USING    pi_tknum
                                      pi_driver_nm
                                      pi_driver_telno
                                      pi_truck_no
                             CHANGING pe_error.

**
  CHECK: pe_error IS INITIAL.
*         pi_tknum IS NOT INITIAL.

  IF pi_driver_nm    IS INITIAL OR
     pi_driver_telno IS INITIAL OR
     pi_truck_no     IS INITIAL.
    pe_error = 'X'.
*   차량번호/운송기사/운전자전화번호를 입력하세요.
    MESSAGE s000 WITH TEXT-e09  DISPLAY LIKE 'E'.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form tong_moon_confirm
*&---------------------------------------------------------------------*
FORM tong_moon_confirm .

**
  CHECK: gv_error     IS INITIAL,
         gt_confirm[] IS NOT INITIAL.

  CLEAR: gv_answer.
  PERFORM popup_to_confirm          USING    '< 통문확정여부확인 >'
                                             '확정하시겠습니까?'
                                             ' '
                                    CHANGING gv_answer.

  CHECK: gv_answer = 'J'.

  PERFORM start_tong_moon_confirm   CHANGING gv_error.

  PERFORM tong_moon_confirm_result  USING    gv_save_cd
                                    CHANGING gv_error.

  PERFORM refresh_line_count        USING    gv_error.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_tong_moon_confirm
*&---------------------------------------------------------------------*
FORM start_tong_moon_confirm  CHANGING pe_error.

  DATA: lv_fg(1),
        lv_seq         TYPE i,
        lv_com(1),
        lv_msg(100),
        lv_continue(1).

**
  CHECK: pe_error IS INITIAL.

* 거래명세서 취소여부 확인.
  SELECT iv_no  INTO TABLE @DATA(lt_canc)
    FROM zlet0005  FOR ALL ENTRIES IN @gt_confirm
   WHERE iv_no        EQ @gt_confirm-iv_no
     AND iv_cancel_yn EQ 'X'.
  IF lt_canc[] IS NOT INITIAL.
    SORT: lt_canc BY iv_no.
  ENDIF.

  _clear: gt_stab, gt_etab.
  SORT: gt_confirm BY iv_no.

  CLEAR: lv_seq, lv_com.
  LOOP AT gt_confirm  INTO DATA(ls_conf) .

    CLEAR: lv_continue.

* 거래명세서 취소여부
    DATA(ls_canc) = VALUE #( lt_canc[ iv_no = ls_conf-iv_no ]  OPTIONAL ).

    IF ls_canc IS NOT INITIAL.
*    IF sy-subrc = 0.

      CLEAR: lv_msg.
*     '-> 거래명세서 발행 취소하여 통문 확정할 수 없습니다'
      lv_msg = ls_conf-iv_no && TEXT-e10.

      PERFORM set_result_tab    USING  'E'
                                       ls_conf-iv_no
                                       lv_msg.
      lv_continue = 'X'.

    ENDIF.

    IF lv_continue IS NOT INITIAL.
      CONTINUE.
    ENDIF.

    CLEAR: lv_fg.
    AT END OF iv_no.
      lv_fg = 'X'.
    ENDAT.

    IF lv_fg = 'X'.
      lv_seq = lv_seq + 1.

*     선적문서가 있을때 통문확정시 선적완료한다.
      PERFORM check_tknum_and_confirm    USING    gv_save_cd
                                                  ls_conf-iv_no
                                                  ls_conf-tknum
                                         CHANGING lv_msg
                                                  lv_continue.
*      IF lv_continue IS NOT INITIAL.
*        CONTINUE.
*      ENDIF.

      IF lv_continue IS INITIAL.
        lv_com = 'X'.
      ENDIF.

*     납품 Header Update
      PERFORM update_likp_proc           USING    gv_save_cd
                                                  ls_conf-iv_no
                                         CHANGING lv_msg
                                                  lv_continue.

*     통문확정 Process.
      PERFORM tong_moon_confirm_proc     USING    gv_save_cd
                                                  ls_conf
                                         CHANGING lv_msg
                                                  lv_continue.

      IF lv_continue IS NOT INITIAL.
        CONTINUE.
      ELSE.
        PERFORM set_result_tab           USING    'S'
                                                  ls_conf-iv_no
                                                  ' '.
*       Send MES.
        PERFORM send_mes_with_iv_no      USING    ls_conf-iv_no
                                         CHANGING pe_error.
      ENDIF.

    ENDIF.

  ENDLOOP.

**
  FREE: lt_canc.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_result_tab
*&---------------------------------------------------------------------*
FORM set_result_tab  USING    pi_type
                              pi_iv_no
                              pi_msg.

  DATA: ls_stab LIKE gt_stab,
        ls_etab LIKE gt_etab.

**
  CASE pi_type.
    WHEN 'S'.
      CLEAR: ls_stab.
      ls_stab = VALUE #( iv_no = pi_iv_no ).
      COLLECT: ls_stab  INTO gt_stab.

    WHEN 'E'.
      CLEAR: ls_etab.
      ls_etab = VALUE #( iv_no = pi_iv_no
                          mstxt = pi_msg ).
      COLLECT: ls_etab  INTO gt_etab.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_tknum_and_confirm
*&---------------------------------------------------------------------*
FORM check_tknum_and_confirm  USING    pi_ucomm
                                       pi_iv_no
                                       pi_tknum
                              CHANGING pe_msg
                                       pe_error.

  DATA: lv_chk_tknum(1).

**
  CHECK: pi_tknum IS NOT INITIAL,
         pe_error IS INITIAL.

  SELECT SINGLE sttrg   INTO @DATA(lv_sttrg)
    FROM vttk  WHERE tknum EQ @pi_tknum.

  CLEAR: lv_chk_tknum.
  CASE pi_ucomm.
    WHEN 'COM'.     " 통문확정.
      IF lv_sttrg >= 1 AND lv_sttrg <= 4.
        lv_chk_tknum = 'X'.
      ENDIF.

    WHEN 'CANC'.    " 통문취소
      IF lv_sttrg >= 5. "선적완료까지 진행분
        lv_chk_tknum = 'X'.
      ENDIF.

  ENDCASE.

  IF lv_chk_tknum IS NOT INITIAL.
*   선적 BDC.
    CLEAR: pe_msg.
    PERFORM vt02n_bdc     USING    pi_tknum
                                   gv_out_date
                          CHANGING pe_msg.

    IF pe_msg IS NOT INITIAL.

      IF     pi_ucomm = 'COM'.     " 통문확정.
        pe_msg = pi_iv_no && '(통문확정실패)' && pe_msg.
      ELSEIF pi_ucomm = 'CANC'.    " 통문취소
        pe_msg = pi_iv_no && '(통문취소실패)' && pe_msg.
      ENDIF.

      PERFORM set_result_tab    USING  'E'
                                       pi_iv_no
                                       pe_msg.
      pe_error = 'X'.

    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form vt02n_bdc
*&---------------------------------------------------------------------*
FORM vt02n_bdc  USING    pi_tknum
                         pi_out_date
                CHANGING pe_msg.

**
  CHECK: pi_tknum IS NOT INITIAL.

  _clear: gt_bdcdata.
  PERFORM dynpro USING:
          'X' 'SAPMV56A'          '1011',
          ' ' 'VTTK-TKNUM'        pi_tknum,
          ' ' 'BDC_OKCODE'        '=MM_TKAL'.

*  PERFORM DYNPRO USING:
*          'X' 'SAPMV56A'          '1020',
*          ' ' 'BDC_OKCODE'        '=MM_ST05',
*          ' ' 'VTTK-UZABF'        SY-UZEIT.

  PERFORM dynpro USING:
          'X' 'SAPMV56A'          '1020',
          ' ' 'BDC_OKCODE'        '=MM_ST05',
          ' ' 'VTTK-DTABF'        pi_out_date.

*  PERFORM DYNPRO USING:
*          'X' 'SAPMV56A'          '1020',
*          ' ' 'BDC_OKCODE'        '=MM_ST05',
*          ' ' 'VTTK-UZABF'        SY-UZEIT.

  PERFORM dynpro USING:
          'X' 'SAPMV56A'          '1020',
          ' ' 'BDC_OKCODE'        '=MM_SICH'.
*          ' ' 'VTTK-DTABF'        P_OUT_DATE.



  CALL TRANSACTION 'VT02N' USING  gt_bdcdata
                           MODE  gv_bdcmode  UPDATE 'S'.

  IF sy-msgty = 'S' AND sy-msgid = 'VW' AND sy-msgno = '006'.
  ELSE.
    PERFORM  build_message_text(zler0022) USING
    sy-msgid sy-msgno sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 pe_msg.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form dynpro
*&---------------------------------------------------------------------*
FORM dynpro  USING    pi_dynbegin
                      pi_name
                      pi_value.

  DATA: ls_bdcdata  LIKE bdcdata.

**
  CLEAR: ls_bdcdata.

  IF pi_dynbegin = 'X'.
    MOVE:  'X'      TO  ls_bdcdata-dynbegin,
           pi_name  TO  ls_bdcdata-program,
           pi_value TO  ls_bdcdata-dynpro.
  ELSE.
    MOVE:  pi_name  TO  ls_bdcdata-fnam,
           pi_value TO  ls_bdcdata-fval.
  ENDIF.

  APPEND ls_bdcdata  TO gt_bdcdata.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form update_likp_proc
*&---------------------------------------------------------------------*
FORM update_likp_proc  USING    pi_ucomm
                                pi_iv_no
                       CHANGING pe_msg
                                pe_error.

  DATA: lv_zout     LIKE likp-zout.

**
  CHECK:      pe_error IS INITIAL,
  p_gubun1(1) = 'A'.

  CLEAR: lv_zout.
  IF     pi_ucomm = 'COM'.     " 통문확정.
    lv_zout      = 'Y'.
    DATA(lv_msg) = '-> 통문확정실패(납품DATA저장)'.

  ELSEIF pi_ucomm = 'CANC'.    " 통문취소
    CLEAR: lv_zout.
    lv_msg = '-> 통문취소실패(납품DATA저장)'.

  ENDIF.

  UPDATE likp SET zout = lv_zout
            WHERE vbeln IN ( SELECT vbeln
                               FROM zlet0006
                              WHERE iv_no = pi_iv_no ).
  IF sy-subrc <> 0.

    CLEAR: pe_msg.
*    pe_msg = pi_iv_no && '-> 통문확정실패(납품DATA저장)' && pe_msg.
    pe_msg = pi_iv_no && lv_msg && pe_msg.

    PERFORM set_result_tab    USING  'E'
                                     pi_iv_no
                                     pe_msg.
    pe_error = 'X'.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form tong_moon_confirm_proc
*&---------------------------------------------------------------------*
FORM tong_moon_confirm_proc  USING    pi_ucomm
                                      ps_conf     LIKE gt_confirm
                             CHANGING pe_msg
                                      pe_error.

  DATA: lv_doc  LIKE bapi2017_gm_head_ret-mat_doc.

**
  CHECK: pe_error IS INITIAL.

* Check 통문헤더 Table
  SELECT SINGLE *  INTO @DATA(ls_0005)
    FROM zlet0005  WHERE iv_no  EQ @ps_conf-iv_no
                     AND out_yn EQ ' '.

  IF ls_0005 IS NOT INITIAL.

*   E13유형은 자재예약을 이용하여 확정시 창고 이동전기 처리
    CLEAR: lv_doc.
    PERFORM call_bapi_goodmvt_create    USING    ps_conf-rsnum
                                        CHANGING lv_doc
                                                 pe_msg
                                                 pe_error.
    IF pe_error IS NOT INITIAL.

      pe_msg = ps_conf-iv_no && pe_msg .
      PERFORM set_result_tab    USING  'E'
                                       ps_conf-iv_no
                                       pe_msg.
    ELSE.
      UPDATE zlet0006 SET mblnr = lv_doc
                          mjahr = gv_out_date+0(4)
      WHERE iv_no = ps_conf-iv_no.

    ENDIF.

  ENDIF.

* 선적문서 Update ( 운전자, 전화번호, 차량번호 )
  PERFORM update_shipment_car_info       USING    pi_ucomm
                                                  ps_conf
                                         CHANGING pe_msg
                                                  pe_error.

* Modify 통문헤더 Table.
  PERFORM update_tong_moon_header_tab    USING    pi_ucomm
                                                  ls_0005
                                                  ps_conf
                                         CHANGING pe_msg
                                                  pe_error.
**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form call_bapi_goodmvt_create
*&---------------------------------------------------------------------*
FORM call_bapi_goodmvt_create  USING    pi_rsnum
                               CHANGING pe_doc
                                        pe_msg
                                        pe_error.

  DATA: lv_line    LIKE bapi2017_gm_item_create-line_id,

        ls_header  LIKE bapi2017_gm_head_01,
        ls_headret LIKE bapi2017_gm_head_ret,
        ls_code    LIKE bapi2017_gm_code,
        ls_item    LIKE bapi2017_gm_item_create,
        lt_item    LIKE bapi2017_gm_item_create OCCURS 0  WITH HEADER LINE,
        lt_retmsg  LIKE bapiret2 OCCURS 0 WITH HEADER LINE.

**
  CHECK: pe_error IS INITIAL,
         pi_rsnum IS NOT INITIAL.

  SELECT *  INTO TABLE @DATA(lt_resb)
    FROM resb  WHERE rsnum EQ @pi_rsnum.

  CHECK: lt_resb[] IS NOT INITIAL.

  CLEAR: ls_header, ls_code.
*___전기일/증빙일/텍스트
  ls_header-pstng_date   = gv_out_date.
  ls_header-doc_date     = gv_out_date.
  ls_header-header_txt   = sy-tcode.

*___자재이동 트랜잭션 지정
  ls_code-gm_code        = '04'.      "대체전기(MB1B) - T158G

*___자재이동 정보
  _clear: lt_item.
  CLEAR: lv_line.
  LOOP AT lt_resb  INTO DATA(ls_resb).

    lv_line = lv_line + 1.

    CLEAR: ls_item.
    ls_item =  VALUE #( material     = ls_resb-matnr
                        plant        = ls_resb-werks
                        stge_loc     = ls_resb-lgort
                        batch        = ls_resb-charg
                        move_type    = '311'
                        entry_qnt    = ls_resb-bdmng
                        entry_uom    = ls_resb-meins

                        move_mat     = ls_resb-matnr
                        move_plant   = ls_resb-umwrk
                        move_stloc   = ls_resb-umlgo
                        move_batch   = ls_resb-charg
                        spec_stock   = ls_resb-sobkz

                        reserv_no    = ls_resb-rsnum
                        res_item     = ls_resb-rspos

                        line_id      = lv_line
                      ) .

    IF ls_resb-kdauf IS NOT INITIAL.
      ls_item = VALUE #( BASE ls_item
                         val_sales_ord  = ls_resb-kdauf
                         val_s_ord_item = ls_resb-kdpos
                         sales_ord      = ls_resb-kdauf
                         s_ord_item     = ls_resb-kdpos
                       ).
    ENDIF.

    APPEND  ls_item  TO lt_item.

  ENDLOOP.

*___자재이동 BAPI CALL
  _clear: lt_retmsg.
  CLEAR: ls_headret.
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_header
      goodsmvt_code    = ls_code
    IMPORTING
      goodsmvt_headret = ls_headret
    TABLES
      goodsmvt_item    = lt_item
      return           = lt_retmsg.

  IF ls_headret-mat_doc IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    DATA(ls_retmsg) = VALUE #( lt_retmsg[ type = 'S' ]  OPTIONAL ).
*    READ TABLE gt_retmsg WITH KEY type = 'S'.

    pe_doc = ls_headret-mat_doc.

  ELSE.
    pe_error = 'X'.

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CLEAR: ls_retmsg.
    ls_retmsg = VALUE #( lt_retmsg[ type = 'X' ]  OPTIONAL ).

    IF ls_retmsg IS INITIAL.

      ls_retmsg = VALUE #( lt_retmsg[ type = 'A' ]  OPTIONAL ).

      IF ls_retmsg IS INITIAL.
        ls_retmsg = VALUE #( lt_retmsg[ type = 'E' ]  OPTIONAL ).

        IF ls_retmsg IS INITIAL.
          ls_retmsg = VALUE #( lt_retmsg[ type = 'I' ]  OPTIONAL ).

          IF ls_retmsg IS INITIAL.
            ls_retmsg = VALUE #( lt_retmsg[ type = 'W' ]  OPTIONAL ).

            IF ls_retmsg IS INITIAL.
              ls_retmsg = VALUE #( lt_retmsg[ 1 ]  OPTIONAL ).

            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.

  pe_msg = ls_retmsg-message.

**
  FREE: lt_resb, lt_item, lt_retmsg.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form update_shipment_car_info
*&---------------------------------------------------------------------*
FORM update_shipment_car_info  USING    pi_ucomm
                                        ps_conf    LIKE gt_confirm
                               CHANGING pe_msg
                                        pe_error.

  DATA: ls_header       LIKE bapishipmentheader,
        ls_headerx      LIKE bapishipmentheaderaction,
        lt_return       TYPE TABLE OF bapiret2,

        lv_flag         TYPE char1,
        lv_driver_nm    LIKE zlet0005-driver_nm,    " 운전자명
        lv_driver_telno LIKE zlet0005-driver_telno, " 운전자전화번호
        lv_truck_no     LIKE zlet0005-truck_no.     " 차량번호

**
  CHECK: pe_error       IS INITIAL,
         ps_conf-tknum  IS NOT INITIAL.    " 선적번호

* 운전자 정보 Set.
  CLEAR: lv_flag, lv_driver_nm, lv_driver_telno, lv_truck_no .
  IF     pi_ucomm = 'COM'.     " 통문확정.
    lv_flag         = 'C'.
    lv_driver_nm    = ps_conf-driver_nm.    " 운전자명
    lv_driver_telno = ps_conf-driver_telno. " 운전자전화번호
    lv_truck_no     = ps_conf-truck_no.     " 차량번호

  ELSEIF pi_ucomm = 'CANC'.    " 통문취소
    lv_flag         = 'D'.
    CLEAR: lv_driver_nm, lv_driver_telno, lv_truck_no.

  ENDIF.


* Set Header
  CLEAR: ls_header, ls_headerx.
  ls_header = VALUE #( shipment_num  = ps_conf-tknum
                       external_id_1 = lv_truck_no     " 차량번호
                       external_id_2 = lv_driver_nm    " 운전자명
                       description   = lv_driver_telno " 운전자전화번호
                     ).
  ls_headerx = VALUE #( external_id_1 = lv_flag " 차량번호
                        external_id_2 = lv_flag " 운전자명
                        description   = lv_flag " 운전자전화번호
                      ).

  _clear: lt_return.
  CALL FUNCTION 'BAPI_SHIPMENT_CHANGE'
    EXPORTING
      headerdata       = ls_header
      headerdataaction = ls_headerx
    TABLES
      return           = lt_return.

  DATA(ls_return) = VALUE #( lt_return[ type = 'S' ]  OPTIONAL ).

  IF ls_return IS NOT INITIAL.
*  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

  ELSE.
    pe_error = 'X'.

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    pe_msg = VALUE #( lt_return[ type = 'E' ]-message  OPTIONAL ).

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form update_tong_moon_header_tab
*&---------------------------------------------------------------------*
FORM update_tong_moon_header_tab  USING    pi_ucomm
                                           ps_0005    LIKE zlet0005
                                           ps_conf    LIKE gt_confirm
                                  CHANGING pe_msg
                                           pe_error.

  DATA: lv_out_yn(1),
        lv_driver_nm    LIKE zlet0005-driver_nm,    " 운전자명
        lv_driver_telno LIKE zlet0005-driver_telno, " 운전자전화번호
        lv_truck_no     LIKE zlet0005-truck_no,     " 차량번호
        lv_out_date     LIKE sy-datum,
        lv_out_time     LIKE sy-uzeit,
        lv_out_id       LIKE sy-uname,
        lv_canc_date    LIKE sy-datum,
        lv_canc_time    LIKE sy-uzeit,
        lv_canc_id      LIKE sy-uname.

**
  CHECK: pe_error IS INITIAL,
         ps_0005  IS NOT INITIAL.

  CLEAR: lv_out_yn,
         lv_driver_nm, lv_driver_telno, lv_truck_no,
         lv_out_date, lv_out_time, lv_out_id,
         lv_canc_date, lv_canc_time, lv_canc_id.
  IF     pi_ucomm = 'COM'.     " 통문확정.
    lv_out_yn       = 'X'.

    lv_driver_nm    = ps_conf-driver_nm.    " 운전자명
    lv_driver_telno = ps_conf-driver_telno. " 운전자전화번호
    lv_truck_no     = ps_conf-truck_no.     " 차량번호

    lv_out_date     = gv_out_date.
    lv_out_time     = sy-uzeit.
    lv_out_id       = sy-uname.

  ELSEIF pi_ucomm = 'CANC'.    " 통문취소
*   통문 취소시, 운전자 정보 Clear.
    CLEAR: lv_out_yn,
           lv_driver_nm, lv_driver_telno, lv_truck_no.

    lv_canc_date = sy-datum.
    lv_canc_time = sy-uzeit.
    lv_canc_id   = sy-uname.

  ENDIF.

* 통문확정 정보 입력
  ps_0005 = VALUE #( BASE ps_0005
                     out_yn         = lv_out_yn     "통문여부
                     out_date       = lv_out_date   "통문확정일
                     out_time       = lv_out_time   "통문확정시간
                     out_confirm_id = lv_out_id     "통문확정자 ID
*                    통문확정시 취소 이력이 있으면 Clear 한다.
                     out_cancel_id  = lv_canc_id    "통문취소자 ID
                     cancel_date    = lv_canc_date  "통문취소일
                     cancel_time    = lv_canc_time  "통문취소시간
*                    변경이력
                     change_date    = sy-datum      "변경날자
                     change_time    = sy-uzeit      "변경시간.
**                   Add.
                     driver_nm      = lv_driver_nm    " 운전자명
                     driver_telno   = lv_driver_telno " 운전자전화번호
                     truck_no       = lv_truck_no     " 차량번호
                   ).

  MODIFY zlet0005  FROM ps_0005.
  IF sy-subrc <> 0.

    IF     pi_ucomm = 'COM'.     " 통문확정.
      pe_msg = ps_0005-iv_no && '-> 통문확정실패(DATA저장)' .

    ELSEIF pi_ucomm = 'CANC'.    " 통문취소
      pe_msg = ps_0005-iv_no && '-> 통문취소실패(DATA저장)' .

    ENDIF.

    PERFORM set_result_tab    USING  'E'
                                     ps_0005-iv_no
                                     pe_msg.

    pe_error = 'X'.

  ENDIF.

**

ENDFORM.
*&---------------------------------------------------------------------*
*& Form tong_moon_confirm_result
*&---------------------------------------------------------------------*
FORM tong_moon_confirm_result   USING    pi_ucomm
                                CHANGING pe_error.

  DATA: lt_msg_tab TYPE TABLE OF zles009,
        lv_out_yn  LIKE zlet0005-out_yn.

**
  _clear: lt_msg_tab.

  DESCRIBE TABLE gt_etab  LINES sy-tfill.
  IF sy-tfill > 0.
    lt_msg_tab[] = VALUE #( BASE lt_msg_tab
                            FOR ls_etab  IN gt_etab
                            ( msgtx = ls_etab-mstxt )
                          ).
  ENDIF.
*
  CLEAR: lv_out_yn.
  IF     pi_ucomm = 'COM'.     " 통문확정.
    DATA(lv_msg) = '--> 통문 확정되었습니다'.
    lv_out_yn = 'X'.

  ELSEIF pi_ucomm = 'CANC'.    " 통문취소
    lv_msg = '--> 통문 취소되었습니다'.

  ENDIF.

  CLEAR: sy-tfill.
  DESCRIBE TABLE gt_stab  LINES sy-tfill.
  IF sy-tfill > 0.
    lt_msg_tab[] = VALUE #( BASE lt_msg_tab
                            FOR ls_stab  IN gt_stab
                            ( msgtx = ls_stab-iv_no &&  lv_msg )
                          ).
*    CLEAR: lv_out_yn.

  ENDIF.

  CALL FUNCTION 'Z_LE_POPUP_TO_ERROR_MESSAGE'
    TABLES
      msg_tab = lt_msg_tab.
*
  LOOP AT gt_out  INTO gs_out  WHERE chk = 'X'.

    DATA(lv_index) = sy-tabix.

    SELECT SINGLE *  INTO @DATA(ls_0005)
      FROM zlet0005 WHERE iv_no  EQ @gs_out-iv_no
                      AND out_yn EQ @lv_out_yn.    " 'X'.
    IF sy-subrc = 0.
      DELETE gt_out INDEX lv_index.    " sy-tabix.
      CONTINUE.
    ENDIF.

    CLEAR: ls_0005.
    IF pi_ucomm = 'COM'.     " 통문확정.
      SELECT SINGLE *  INTO @ls_0005
        FROM zlet0005 WHERE iv_no        EQ @gs_out-iv_no
                        AND iv_cancel_yn EQ 'X'.
      IF sy-subrc = 0.
        DELETE gt_out INDEX  lv_index.    " sy-tabix.
        CONTINUE.
      ENDIF.

    ENDIF.

  ENDLOOP.

**
  FREE: lt_msg_tab.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_already_inimg
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_already_inimg  USING    pi_iv_no
                          CHANGING pe_error.

**
  CHECK: pe_error IS INITIAL.

  SELECT SUM( inimg ) INTO @DATA(lv_inimg)
    FROM zlet0008  WHERE iv_no EQ @pi_iv_no.

  IF lv_inimg > 0.
*   반입수량이 존재합니다.확인하세요!
    MESSAGE s000 WITH  TEXT-e11  DISPLAY LIKE 'I'.

    pe_error = 'X'.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form tong_moon_cancel
*&---------------------------------------------------------------------*
FORM tong_moon_cancel .

**
  CHECK: gv_error     IS INITIAL,
         gt_confirm[] IS NOT INITIAL.

  CLEAR: gv_answer.
  PERFORM popup_to_confirm          USING    '< 통문취소여부확인 >'
                                             '취소하시겠습니까?'
                                             ' '
                                    CHANGING gv_answer.

  CHECK: gv_answer = 'J'.

  PERFORM start_tong_moon_cancel    CHANGING gv_error.

  PERFORM tong_moon_confirm_result  USING    gv_save_cd
                                    CHANGING gv_error.

  PERFORM refresh_line_count        USING    gv_error.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_tong_moon_cancel
*&---------------------------------------------------------------------*
FORM start_tong_moon_cancel  CHANGING pe_error.

  DATA: lv_fg(1),
        lv_seq         TYPE i,
        lv_com(1),
        lv_msg(100),
        lv_continue(1).

**
  CHECK: pe_error IS INITIAL.

  _clear: gt_stab, gt_etab.

  SORT: gt_confirm BY iv_no.

  CLEAR: lv_seq, lv_com.
  LOOP AT gt_confirm  INTO DATA(ls_canc) .

    CLEAR: lv_msg, lv_continue.

    CLEAR: lv_fg.
    AT END OF iv_no.
      lv_fg = 'X'.
    ENDAT.

    IF lv_fg = 'X'.
      lv_seq = lv_seq + 1.

*     선적문서 존재시 통문취소 하면 선적완료 취소한다.
      PERFORM check_tknum_and_confirm    USING    gv_save_cd
                                                  ls_canc-iv_no
                                                  ls_canc-tknum
                                         CHANGING lv_msg
                                                  lv_continue.

*     납품 Header Update
      PERFORM update_likp_proc           USING    gv_save_cd
                                                  ls_canc-iv_no
                                         CHANGING lv_msg
                                                  lv_continue.

*     통문취소 Process.
      PERFORM tong_moon_cancel_proc      USING    gv_save_cd
                                                  ls_canc
                                         CHANGING lv_msg
                                                  lv_continue.

      IF lv_continue IS NOT INITIAL.
        CONTINUE.
      ELSE.
        PERFORM set_result_tab    USING  'S'
                                         ls_canc-iv_no
                                         ' '.
      ENDIF.

    ENDIF.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form tong_moon_cancel_proc
*&---------------------------------------------------------------------*
FORM tong_moon_cancel_proc  USING    pi_ucomm
                                     ps_canc       LIKE gt_confirm
                            CHANGING pe_msg
                                     pe_error.

**
  CHECK: pe_error IS INITIAL.

* Check 통문헤더 Table
  SELECT SINGLE *  INTO @DATA(ls_0005)
    FROM zlet0005  WHERE iv_no  EQ @ps_canc-iv_no
                     AND out_yn EQ 'X'.

  IF ls_0005 IS NOT INITIAL.

*   E13유형은 자재예약을 이용하여 확정시 창고 이동전기 처리
    PERFORM call_bapi_goodmvt_cancel    USING    ps_canc-mblnr
                                                 ps_canc-mjahr
                                        CHANGING pe_msg
                                                 pe_error.

    IF pe_error IS NOT INITIAL.

      pe_msg = ps_canc-iv_no && pe_msg .
      PERFORM set_result_tab    USING  'E'
                                       ps_canc-iv_no
                                       pe_msg.
    ELSE.
      UPDATE zlet0006 SET mblnr = ' '
                          mjahr = ' '
      WHERE iv_no = ps_canc-iv_no.

    ENDIF.

*   선적문서 Update ( 운전자, 전화번호, 차량번호 )
    PERFORM update_shipment_car_info       USING    pi_ucomm
                                                    ps_canc
                                           CHANGING pe_msg
                                                    pe_error.

*   Modify 통문헤더 Table.
    PERFORM update_tong_moon_header_tab    USING    pi_ucomm
                                                    ls_0005
                                                    ps_canc
                                           CHANGING pe_msg
                                                    pe_error.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form call_bapi_goodmvt_cancel
*&---------------------------------------------------------------------*
FORM call_bapi_goodmvt_cancel  USING    pi_mblnr
                                        pi_mjahr
                               CHANGING pe_msg
                                        pe_error.

  DATA: ls_head LIKE bapi2017_gm_head_02,
        ls_hret LIKE bapi2017_gm_head_ret,
        lt_ret2 LIKE bapiret2 OCCURS 0 WITH HEADER LINE.

**
  CHECK: pe_error IS INITIAL,
         pi_mblnr IS NOT INITIAL,
         pi_mjahr IS NOT INITIAL.

  CLEAR: ls_head.
  ls_head-mat_doc    = pi_mblnr.
  ls_head-doc_year   = pi_mjahr.
  ls_head-pstng_date = gv_out_date.

  CLEAR: ls_hret.
  _clear: lt_ret2.
  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      materialdocument    = ls_head-mat_doc
      matdocumentyear     = ls_head-doc_year
      goodsmvt_pstng_date = ls_head-pstng_date
    IMPORTING
      goodsmvt_headret    = ls_hret
    TABLES
      return              = lt_ret2.

  IF ls_hret-mat_doc IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    DATA(ls_ret2) = VALUE #( lt_ret2[ type = 'S' ]  OPTIONAL ).

  ELSE.
    pe_error = 'X'.

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CLEAR: ls_ret2.
    ls_ret2 = VALUE #( lt_ret2[ type = 'A' ]  OPTIONAL ).
    IF ls_ret2 IS INITIAL.

      CLEAR: ls_ret2.
      ls_ret2 = VALUE #( lt_ret2[ type = 'E' ]  OPTIONAL ).
      IF ls_ret2 IS INITIAL.

        CLEAR: ls_ret2.
        ls_ret2 = VALUE #( lt_ret2[ type = 'W' ]  OPTIONAL ).
        IF ls_ret2 IS INITIAL.

          CLEAR: ls_ret2.
          ls_ret2 = VALUE #( lt_ret2[ type = 'I' ]  OPTIONAL ).
          IF ls_ret2 IS INITIAL.
            CLEAR: ls_ret2.
            ls_ret2 = VALUE #( lt_ret2[ 1 ]  OPTIONAL ).
          ENDIF.

        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  pe_msg = ls_ret2-message.

**
  FREE: lt_ret2.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form all_de_select_chk
*&---------------------------------------------------------------------*
FORM all_de_select_chk    USING   pi_ucomm.

**
  LOOP AT gt_out  ASSIGNING FIELD-SYMBOL(<lfs_wa>).

    CASE pi_ucomm.
      WHEN 'ASEL'.
        <lfs_wa>-chk = 'X'.
        <lfs_wa>-fg  = 'X'.

      WHEN 'DSEL'.
        <lfs_wa>-chk = ' '.
        <lfs_wa>-fg  = ' '.

    ENDCASE.

  ENDLOOP.

  IF     pi_ucomm = 'ASEL'.
    gv_chk_cnt = gv_tot_cnt.

  ELSEIF pi_ucomm = 'DSEL'.
    CLEAR: gv_chk_cnt.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form refresh_line_count
*&---------------------------------------------------------------------*
FORM refresh_line_count  USING    pi_error.

**
  CHECK: pi_error IS INITIAL.

  CLEAR: gv_tot_cnt, gv_chk_cnt.

  DESCRIBE TABLE gt_out LINES gv_tot_cnt.

  gv_chk_cnt = REDUCE i( INIT x = 0  FOR ls_out IN gt_out
                         WHERE ( chk = 'X' )
                         NEXT x = x + 1 ).

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form send_mes_with_iv_no
*&---------------------------------------------------------------------*
FORM send_mes_with_iv_no  USING    pi_iv_no
                          CHANGING pe_error.

  DATA: lv_jobname      LIKE tbtcjob-jobname,
        lv_jobname_head LIKE tbtcjob-jobname,
        lv_jobcount     LIKE tbtcjob-jobcount,

        lv_target       LIKE zgtppt1010-fld_01,
        lv_go(1),
        lv_gp(1),
        lv_gc(1).

  RANGES: lr_ivno  FOR zlet0005-iv_no,
          lr_erdat FOR vbak-erdat .

**
  CHECK: pi_iv_no IS NOT INITIAL.

  SELECT SINGLE *  INTO @DATA(ls_0005)
    FROM zlet0005  WHERE iv_no EQ @pi_iv_no.

  CHECK ls_0005-iv_type EQ 'A01'.

  CLEAR: lv_target.
  lv_target = 'KGOC'.

  CLEAR: lv_jobname_head, lv_gp, lv_go, lv_gc.
  IF lv_target IS NOT INITIAL.

    lv_jobname_head = |{ '[SD]C_' }| && |{ lv_target }| && |{ '_명세서(' }|.

    CLEAR: lv_gp, lv_go.
    lv_gc = 'X'.

  ENDIF.

  IF lv_target IS NOT INITIAL.

    CLEAR: lv_jobname, lv_jobcount.
    lv_jobname = |{ lv_jobname_head }| && |{ pi_iv_no }| && |{ ')' }|.

    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = lv_jobname
        jobclass         = 'A'
      IMPORTING
        jobcount         = lv_jobcount
      EXCEPTIONS
        cant_create_job  = 1
        invalid_job_data = 2
        jobname_missing  = 3
        OTHERS           = 4.

    _clear: lr_ivno, lr_erdat.
    lr_ivno[]  = VALUE #( ( sign = 'I' option = 'EQ' low = pi_iv_no ) ).
    lr_erdat[] = VALUE #( ( sign = 'I' option = 'BT' low  = ls_0005-iv_date
                                                     high = ls_0005-iv_date ) ).
*
    SUBMIT zgtsdi0005 VIA JOB lv_jobname  NUMBER lv_jobcount
                      AND RETURN
                      WITH s_ivno  IN lr_ivno
                      WITH s_erdat IN lr_erdat
                      WITH rb_send EQ 'X'
                      WITH rb_10   EQ ' '
                      WITH rb_t1   EQ ' '
                      WITH rb_gp   EQ lv_gp
                      WITH rb_go   EQ lv_go
                      WITH rb_gc   EQ lv_gc
                      WITH p_call  EQ 'X'.

    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobcount             = lv_jobcount
        jobname              = lv_jobname
        strtimmed            = 'X'
      EXCEPTIONS
        cant_start_immediate = 1
        invalid_startdate    = 2
        jobname_missing      = 3
        job_close_failed     = 4
        job_nosteps          = 5
        job_notex            = 6
        lock_failed          = 7
        OTHERS               = 8.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form sunmit_gi_program
*&---------------------------------------------------------------------*
FORM sunmit_gi_program .

**
* Selected Line
  PERFORM check_selected_rows       USING    gv_save_cd
                                    CHANGING gv_error.

  PERFORM submit_program_gi_stat    CHANGING gv_error.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form submit_program_gi_stat
*&---------------------------------------------------------------------*
FORM submit_program_gi_stat  CHANGING pe_error.

  DATA: lr_erdat TYPE RANGE OF likp-erdat,
        lr_vstel TYPE RANGE OF likp-vstel,
        lr_lgort TYPE RANGE OF lips-lgort,
        lr_tknum TYPE RANGE OF vttk-tknum,

        lv_date  TYPE sy-datum.

**
  CHECK: gv_error IS INITIAL.

  DATA(lt_out) = gt_out[].
  DELETE lt_out WHERE chk NE 'X'.
  SORT: lt_out BY tknum.
  DELETE ADJACENT DUPLICATES FROM lt_out COMPARING tknum.

  DATA(ls_out) = VALUE #( lt_out[ chk = 'X' ]  OPTIONAL ).
  IF ls_out IS NOT INITIAL.

    _clear: lr_erdat, lr_vstel, lr_lgort, lr_tknum.
*   납품생성일
    IF ls_out-iv_date IS NOT INITIAL.
      CLEAR: lv_date.
      CALL FUNCTION 'LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = ls_out-iv_date
        IMPORTING
          last_day_of_month = lv_date
        EXCEPTIONS
          day_in_no_date    = 1
          OTHERS            = 2.

      lr_erdat[] = VALUE #( ( sign = 'I'  option = 'BT'
                              low  = |{ ls_out-iv_date+0(6) }| && |{ '01' }|
                              high = lv_date ) ).
    ENDIF.

*   출하지점.
    IF ls_out-vbeln IS NOT INITIAL.
      SELECT SINGLE vstel
        FROM likp  WHERE vbeln EQ @ls_out-vbeln
        INTO @DATA(lv_vstel).

      IF lv_vstel IS NOT INITIAL.
        lr_vstel = VALUE #( ( sign = 'I'  option = 'EQ'  low = lv_vstel ) ).
      ENDIF.
    ENDIF.

*   저장위치
    lr_lgort = VALUE #( ( sign = 'I'  option = 'EQ' low = '3410' )
                        ( sign = 'I'  option = 'EQ' low = '3420' )
                        ( sign = 'I'  option = 'EQ' low = '3430' ) ).

*   선적문서
    lr_tknum = VALUE #( ( sign = 'I'  option = 'EQ'  low = ls_out-tknum ) ).

    SUBMIT zgtler1120 AND RETURN
                      WITH s_erdat IN lr_erdat
                      WITH s_vstel IN lr_vstel
                      WITH s_lgort IN lr_lgort
                      WITH s_tknum IN lr_tknum
                      WITH p_new   EQ 'X'.

  ENDIF.

**
  FREE: lt_out.

ENDFORM.
