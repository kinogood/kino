*----------------------------------------------------------------------*
***INCLUDE LZGTSD05F07.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form data_validation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_VBELN
*&      --> I_POSNR
*&      --> I_ZPJNO
*&      <-- ES_RETURN
*&---------------------------------------------------------------------*
FORM data_validation  USING    pi_vbeln
                               pi_posnr
                               ps_login  TYPE zsds_log_0000_go
                      CHANGING ps_return TYPE zsds_log_0001_go.

** D365 ID 입력 확인
  IF ps_login-ename IS INITIAL.
* D365 ID가 입력되지 않았습니다.
    PERFORM set_return_msg_go  USING: 'E' TEXT-e36  CHANGING ps_return.
    EXIT.
  ENDIF.

** 영업조직 입력 확인
  IF ps_login-vkorg IS INITIAL.
* Login 정보에 영업조직(VKORG)이 입력되지 않았습니다.
    PERFORM set_return_msg_go  USING: 'E' TEXT-e38  CHANGING ps_return.
    EXIT.
  ENDIF.

** 판매오더&Item 입력 확인
  IF pi_vbeln IS INITIAL.
* 판매오더가 입력되지 않았습니다.
    PERFORM set_return_msg_go  USING: 'E' TEXT-e37  CHANGING ps_return.
    EXIT.

  ELSE.
    SELECT SINGLE @abap_true INTO @DATA(lv_flg)
      FROM vbak
     WHERE vbeln EQ @pi_vbeln.

    IF lv_flg NE abap_true.
* 존재하지 않는 판매오더입니다.
      PERFORM set_return_msg_go  USING: 'E' TEXT-e40  CHANGING ps_return.
      EXIT.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_return_msg_go
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> TEXT_E01
*&      <-- PS_RETURN
*&---------------------------------------------------------------------*
FORM set_return_msg_go  USING    pi_mtype
                                 pi_message
                        CHANGING ps_return  TYPE zsds_log_0001_go.

**
  CHECK: ps_return-mtype IS INITIAL.

  ps_return = VALUE #( mtype   = pi_mtype
                       message = pi_message ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_so_change_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ET_RESULT
*&      --> I_VBELN
*&      --> I_POSNR
*&      <-- ES_RETURN
*&---------------------------------------------------------------------*
FORM get_so_change_log  TABLES   pt_result   STRUCTURE zgtsdsif2200
                                 pt_result_c STRUCTURE zgtsdsif2210
                        USING    pi_vbeln
                                 pi_posnr
                                 ps_login    TYPE zsds_log_0000
                        CHANGING ps_return   TYPE zsds_log_0001_go.

**

**-- =======================================================================
**-- [1] 판매오더 변경이력 조회 (Standard Pgm: RVSCD100 )
**-- =======================================================================
  PERFORM get_change_log    TABLES   pt_result
                            USING    pi_vbeln
                                  pi_posnr
                            CHANGING ps_return.


**-- =======================================================================
**-- [2] 변경이력 후속 처리
**-- =======================================================================
  PERFORM modify_change_log TABLES   pt_result
                                     pt_result_c
                            USING    pi_vbeln
                                     pi_posnr
                                     ps_login
                            CHANGING ps_return.


**-- =======================================================================
**-- [3] 조회 결과 메세지 처리
**-- =======================================================================
  IF pt_result[] IS NOT INITIAL OR pt_result_c[] IS NOT INITIAL.

    PERFORM modify_result_data TABLES pt_result
                                      pt_result_c.

*   조회 성공
    PERFORM set_return_msg_go  USING: 'S' TEXT-s03  CHANGING ps_return.
  ELSE.
*   변경내역이 없습니다.
    PERFORM set_return_msg_go  USING: 'E' TEXT-e39  CHANGING ps_return.
    EXIT.
  ENDIF.

**

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_change_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_RESULT
*&---------------------------------------------------------------------*
FORM modify_change_log  TABLES   pt_result   STRUCTURE zgtsdsif2200
                                 pt_result_c STRUCTURE zgtsdsif2210
                        USING    pi_vbeln
                                 pi_posnr
                                 ps_login    TYPE zsds_log_0000
                        CHANGING ps_return   TYPE zsds_log_0001_go.

  DATA: lv_vkorg   LIKE zgtppt1010-fld_01.

**

**-- =======================================================================
**-- [0] 변경이력 조회대상 필드 추출
**-- =======================================================================
  CLEAR: lv_vkorg.
  lv_vkorg = ps_login-vkorg.

  SELECT fld_01, fld_02, fld_04, fld_06
    FROM zgtppt1010
   WHERE module_kind EQ 'SD'
     AND codegrp     EQ '6008'
     AND fld_01      EQ @lv_vkorg
     AND fld_08      EQ 'Y'
    INTO TABLE @gt_mst.
  SORT gt_mst BY fld_01  "Sales Org.
                 fld_02  "Table
                 fld_04  "Field
                 fld_06. "Cond.type

**-- =======================================================================
**-- [1] 변경이력 조회대상으로 설정하지 않은 Table, Field 삭제
**-- =======================================================================
  LOOP AT pt_result ASSIGNING FIELD-SYMBOL(<lfs_data>).

    READ TABLE gt_mst ASSIGNING FIELD-SYMBOL(<lfs_mst>)
                      WITH KEY fld_02 = <lfs_data>-tabname
                               fld_04 = <lfs_data>-fname
                               fld_06 = <lfs_data>-kschl
                      BINARY SEARCH.

    IF sy-subrc NE 0.
      DELETE pt_result.
    ENDIF.

  ENDLOOP.


**-- =======================================================================
**-- [2] Header, Item 변경이력 조회 결과 처리
**--  pi_posnr EQ space: Header 및 전체 Item 변경이력 조회
**-- pi_posnr NE space: Header 및 특정 Item 변경이력 조회
**-- =======================================================================

***  1. Header 변경이력 가공
  PERFORM modify_header_change_log TABLES pt_result
                                          pt_result_c
                                   USING  pi_vbeln
                                          pi_posnr.

***  2. Item 변경이력 가공
  PERFORM modify_item_change_log TABLES pt_result
                                        pt_result_c
                                 USING  pi_vbeln
                                        pi_posnr.
**



ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_header_change_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_RESULT
*&---------------------------------------------------------------------*
FORM modify_header_change_log  TABLES   pt_result   STRUCTURE zgtsdsif2200
                                        pt_result_c STRUCTURE zgtsdsif2210
                                USING   pi_vbeln
                                        pi_posnr.

  DATA: lv_adrnr_o TYPE adrc-addrnumber,
        lv_adrnr_n TYPE adrc-addrnumber.

**-- =======================================================================
**-- [1-1] 납품처 주소지 변경이력 처리
**-- (ADRNR 변경이력 대신 실제 주소지 변경이력으로 교체)
**-- =======================================================================

* 1-1-1)  Addressnumber 변경 전/후 값 추출
  DATA(lt_data) = pt_result[].

  CLEAR: lv_adrnr_o, lv_adrnr_n.
  SELECT SINGLE a~f_old, a~f_new
    FROM @lt_data AS a
   WHERE a~tabname EQ 'VBPA'
     AND a~fname   EQ 'ADRNR'
     AND a~parvw   EQ 'WE'
    INTO ( @lv_adrnr_o, @lv_adrnr_n ).

  IF lv_adrnr_o IS NOT INITIAL OR lv_adrnr_n IS NOT INITIAL.
* 1-1-2)  Addressnumber Alpha Conversion
    lv_adrnr_o = |{ lv_adrnr_o ALPHA = IN }|.
    lv_adrnr_n = |{ lv_adrnr_n ALPHA = IN }|.

* 1-1-3)  변경 전/후 실제 주소지 정보 추출
    SELECT SINGLE
           concat( a~city1, a~street ) AS old_addr
      FROM adrc AS a
     WHERE a~addrnumber = @lv_adrnr_o
      INTO @DATA(lv_old_adr).

    SELECT SINGLE
           concat( a~city1, a~street ) AS new_addr
      FROM adrc AS a
     WHERE a~addrnumber = @lv_adrnr_n
      INTO @DATA(lv_new_adr).

* 1-1-4)  Addressnumber 변경 이력을 실제 주소지 변경정보로 교체
    IF sy-subrc EQ 0.
      READ TABLE pt_result ASSIGNING FIELD-SYMBOL(<lfs_adr>)
                             WITH KEY tabname = 'VBPA'
                                      fname   = 'ADRNR'
                                      parvw   = 'WE'.

      IF sy-subrc EQ 0.
        <lfs_adr>-f_old = lv_old_adr.
        <lfs_adr>-f_new = lv_new_adr.
      ENDIF.
    ENDIF.
  ENDIF.

**

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_item_change_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_RESULT
*&---------------------------------------------------------------------*
FORM modify_item_change_log  TABLES  pt_result   STRUCTURE zgtsdsif2200
                                     pt_result_c STRUCTURE zgtsdsif2210
                             USING   pi_vbeln
                                     pi_posnr.

  DATA: "lv_cuobj      TYPE cu_instance,

    lt_result_c TYPE STANDARD TABLE OF zgtsdsif2210,
    ls_result_c LIKE LINE OF lt_result_c,

    lt_outab    TYPE STANDARD TABLE OF mecdgrid,

    lt_result   TYPE STANDARD TABLE OF zgtsdsif2200,
    ls_result   LIKE LINE OF lt_result.

  DATA: ls_change_rec TYPE cuab_change_rec,
        lt_cdhdr      TYPE cuab_tab_cdhdr,
        lt_pos_conf   TYPE cuab_tab_pos_conf.

**

**-- =======================================================================
**-- [2-0] 아이템 변경정보 처리
**-- =======================================================================

* 2-0-1)  Item 출하요청일 변경이력 첫라인만 유지 -> Schedule Line 첫번째 행만 유지
  DELETE pt_result WHERE tabname EQ 'VBEP'
*                     AND fname   EQ 'EDATU'
                     AND etenr   NE '0001'.


**-- =======================================================================
**-- [2-1] 구매요청 변경정보
**-- =======================================================================

* 2-1-0) 구매요청 번호 추출
  SELECT a~vbeln, a~posnr, a~banfn, a~bnfpo
    FROM vbep AS a
   WHERE a~vbeln EQ @pi_vbeln
     AND a~etenr EQ '0001'
     AND a~banfn NE @abap_false
   INTO TABLE @DATA(lt_preq).

  SORT lt_preq BY vbeln posnr banfn bnfpo.

* 2-1-0-1) Item 단건 조회 시
  IF pi_posnr NE '000000'.
    DELETE lt_preq WHERE posnr NE pi_posnr.
  ENDIF.


  IF lt_preq[] IS NOT INITIAL.
* 2-1-1) 구매요청 변경내역 조회
    LOOP AT lt_preq ASSIGNING FIELD-SYMBOL(<lfs_preq>).

      CLEAR: lt_outab[].
      CALL FUNCTION 'ME_CHANGEDOC_SELECT'
        EXPORTING
          i_document_category = 'B'
          i_document_number   = <lfs_preq>-banfn
          i_document_item     = <lfs_preq>-bnfpo
        IMPORTING
          e_outtab            = lt_outab.

      IF lt_outab[] IS NOT INITIAL.
        CLEAR lt_result[].
        lt_result[] = CORRESPONDING #( lt_outab[] MAPPING indtext = ftext ).

* 2-1-2) Code Master 기준 변경이력 조회대상 정리
        LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_pr>).

          READ TABLE gt_mst ASSIGNING FIELD-SYMBOL(<lfs_code>)
                            WITH KEY fld_02 = <lfs_pr>-tabname
                                     fld_04 = <lfs_pr>-fname
                            BINARY SEARCH.

          IF sy-subrc NE 0.
            DELETE lt_result.
          ENDIF.

        ENDLOOP.

* 2-1-3) 판매오더,아이템 번호 입력
        IF lt_result[] IS NOT INITIAL.
          CLEAR ls_result.

          ls_result-vbeln = <lfs_preq>-vbeln.
          ls_result-posnr = <lfs_preq>-posnr.

          MODIFY lt_result FROM ls_result TRANSPORTING vbeln posnr
                                          WHERE vbeln EQ abap_false.

* 2-1-4) 구매요청변경이력 추가
          APPEND LINES OF lt_result TO pt_result.
          CLEAR lt_result[].
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDIF.


**-- =======================================================================
**-- [2-2] Characteristic 변경 정보
**-- =======================================================================

* 2-2-1) Item의 Instance 번호 추출
  SELECT a~vbeln, a~posnr, a~cuobj
    FROM vbap AS a INNER JOIN ibin AS b
                    ON a~cuobj EQ b~instance
   WHERE a~vbeln EQ @pi_vbeln
     AND a~cuobj NE @abap_false
   INTO TABLE @DATA(lt_cuobj).

  SORT lt_cuobj BY vbeln posnr cuobj.

* 2-2-1-1) Item 단건 조회 시
  IF pi_posnr NE '000000'.
    DELETE lt_cuobj WHERE posnr NE pi_posnr.
  ENDIF.

* 2-2-2) Characteristic 변경이력 조회
  IF lt_cuobj[] IS NOT INITIAL.

    LOOP AT lt_cuobj ASSIGNING FIELD-SYMBOL(<lfs_cuobj>).

      CLEAR: lt_cdhdr[], lt_pos_conf[].

      ls_change_rec-no_display = abap_true.
      CALL FUNCTION 'CUAB_DISPLAY_CD_CONFIGURATION'
        EXPORTING
*         i_instance     = lv_cuobj
          i_instance     = <lfs_cuobj>-cuobj
          i_change_rec   = ls_change_rec
          i_key_date     = sy-datum
          i_new_alv      = abap_true
        IMPORTING
          e_tab_cdhdr    = lt_cdhdr
          e_tab_pos_conf = lt_pos_conf
        EXCEPTIONS
          no_data        = 1
          internal_error = 2
          OTHERS         = 3.

      IF sy-subrc EQ 0.
        SORT: lt_cdhdr BY changenr.

* 2-2-3) 변경이력 Header, item 정보 Join ( CDHDR + CDPOS )
        lt_result_c = VALUE #( BASE lt_result_c
                               FOR ls_conf IN lt_pos_conf

                               LET ls_cdhdr = VALUE #( lt_cdhdr[ changenr = ls_conf-changenr ] OPTIONAL )

                               IN ( CORRESPONDING #( BASE ( CORRESPONDING #( ls_conf ) ) ls_cdhdr ) )
                                       ).

* 2-2-4) Code Master 기준 변경이력 조회대상 정리
        LOOP AT lt_result_c ASSIGNING FIELD-SYMBOL(<lfs_char>).

          READ TABLE gt_mst ASSIGNING FIELD-SYMBOL(<lfs_config>)
                            WITH KEY  fld_02 = 'ZZZZ'
                                      fld_04 = <lfs_char>-atnam
                            BINARY SEARCH.

          IF sy-subrc NE 0.
            DELETE lt_result_C.
          ENDIF.

        ENDLOOP.

* 2-2-5) 판매오더, 아이템 번호 입력
        IF lt_result_c[] IS NOT INITIAL.
          CLEAR ls_result_c.

          ls_result_c-vbeln = <lfs_cuobj>-vbeln.
          ls_result_c-posnr = <lfs_cuobj>-posnr.

          MODIFY lt_result_c FROM ls_result_c TRANSPORTING vbeln posnr
                                              WHERE vbeln EQ abap_false.

          APPEND LINES OF lt_result_c TO pt_result_c.
          CLEAR: lt_result_c[].

        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDIF.

**
  FREE: lt_outab, lt_result, lt_result_c,
        lt_cdhdr, lt_pos_conf.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_result_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_RESULT
*&      --> PT_RESULT_C
*&---------------------------------------------------------------------*
FORM modify_result_data  TABLES   pt_result   STRUCTURE zgtsdsif2200
                                  pt_result_c STRUCTURE zgtsdsif2210.

**

* 판매오더 변경 처리자 이름 추출
  DATA(lt_result_tmp) = pt_result[].
  SELECT DISTINCT b~userid, b~name
    FROM @lt_result_tmp AS a
    INNER JOIN zgtmm_cv_getusername_g AS b
    ON a~username EQ b~userid
  INTO TABLE @DATA(lt_user).
  SORT lt_user BY userid name.


* 판매오더 헤더/아이템 변경이력 처리자 이름 입력
  LOOP AT pt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).
    CONDENSE: <lfs_result>-f_old, <lfs_result>-f_new.

    READ TABLE lt_user WITH KEY userid = <lfs_result>-username
                       ASSIGNING FIELD-SYMBOL(<lfs_user>)
                       BINARY SEARCH.

    IF sy-subrc EQ 0.
      <lfs_result>-name = <lfs_user>-name.
    ENDIF.
  ENDLOOP.


* 판매오더 특성 변경이력 처리자 이름 입력
  LOOP AT pt_result_c ASSIGNING FIELD-SYMBOL(<lfs_result_c>).
    READ TABLE lt_user WITH KEY userid = <lfs_result>-username
                       ASSIGNING FIELD-SYMBOL(<lfs_user_c>)
                       BINARY SEARCH.

    IF sy-subrc EQ 0.
      <lfs_result_c>-name = <lfs_user_c>-name.
    ENDIF.
  ENDLOOP.

  SORT: pt_result   BY vbeln posnr udate utime tabname fname ,
        pt_result_c BY vbeln posnr udate utime atnam.

**

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_change_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_RESULT
*&      --> PI_VBELN
*&      --> PI_POSNR
*&      <-- PS_RETURN
*&---------------------------------------------------------------------*
FORM get_change_log  TABLES   pt_result STRUCTURE zgtsdsif2200
                     USING    pi_vbeln
                              pi_posnr
                     CHANGING ps_return TYPE zsds_log_0001_go.


  DATA: lr_pay_data   TYPE REF TO data.

  FIELD-SYMBOLS: <lt_alv_data> TYPE ANY TABLE.

**


**  1-1) alv Memory Capture 활성화 (화면 출력 억제 및 메모리 보존)
  cl_salv_bs_runtime_info=>set(
    EXPORTING display  = abap_false                                             " 화면 출력 금지
              metadata = abap_false                                             " 메타데이터 캡처 제외
              data     = abap_true                                              " 실제 데이터 캡처 활성화
              ).

** 1-2) 대상 프로그램 호출 (submit)

  SUBMIT rvscd100 WITH vbeln = pi_vbeln
                  WITH posnr = pi_posnr
                  AND RETURN.


** 1-3) 캡처된 alv 데이터 참조 및 할당
  TRY.
      " 메모리에 보존된 ALV 데이터 레퍼런스 가져오기
      cl_salv_bs_runtime_info=>get_data_ref(
        IMPORTING r_data = lr_pay_data
      ).

      ASSIGN lr_pay_data->* TO <lt_alv_data>.

      IF <lt_alv_data> IS ASSIGNED.
        pt_result[] = CORRESPONDING #( <lt_alv_data> ).
      ENDIF.

    CATCH cx_salv_bs_sc_runtime_info.
*      ps_return-mtype = 'E'.
*      ps_return-message  = '변경이력 ALV 데이터 캡처에 실패했습니다.'.
  ENDTRY.


**-- 1-4) alv Memory Capture 초기화 (타 프로그램 영향 방지)
  cl_salv_bs_runtime_info=>clear_all( ).

ENDFORM.
