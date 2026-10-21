*&---------------------------------------------------------------------*
*& 모듈    : MM
*& 프로그램: ZGTMMR1150 (OEM 정산대상 자재 인포레코드 종료일 연장)
*& 목적    : OEM 입고 정산 대상(ZGTMMR5030) 자재의 인포레코드(PB00) 중
*&           정산월 안에 종료되어 정산기준일에 유효하지 않은 건을 찾아
*&           종료일을 정산기준일(월 말일)까지 연장한다.
*&           → ZGTMMR1100(OEM 단가관리)에서 누락되던 자재가 조회되도록 보정
*& 대상    : ZGTMM_CV_GET_PO_GR_BYMON (입고수량 > 0, 정산월·플랜트·구매그룹)
*&           의 LIFNR/MATNR/EKORG/WERKS 와 ZGTMM_CV_GET_INFOPRICE (ESOKZ='0')
*& 판정    : V 유효        - 정산기준일에 유효한 단가 있음 (연장 불필요)
*&           E 연장대상    - 최종 단가가 정산월 안에 종료 (정산기준일까지 연장)
*&           B 월이전종료  - 최종 단가가 정산월 이전에 종료 (자동 연장 안 함, 확인 필요)
*&           N 단가없음    - 인포레코드/PB00 조건 없음 (신규 생성 필요)
*&           D 삭제건      - 인포레코드 삭제 플래그 (연장 안 함)
*&           M 대상외      - 자재유형이 MCFE/MCHA/HAWA 아님 (ZGTMMR1100 대상 아님)
*& 처리    : 테스트(기본) = 조회만. 해제 시 E 건만 ME_INFORECORD_MAINTAIN 으로
*&           DATAB 는 유지, DATBI 만 변경 (ZGTMMR1050 변경 로직과 동일 방식), 건별 COMMIT
*& 주의    : 단가·ZFR1/ZFR2 조건은 기존 값을 그대로 다시 넘긴다.
*&           운영 반영 전 개발/품질에서 1건 테스트 후 ME13 으로 구간 확인할 것.
*& 생성일  : 2026.10.01
*&---------------------------------------------------------------------*
REPORT zgtmmr1150 NO STANDARD PAGE HEADING MESSAGE-ID zgtmm01.

TYPES: BEGIN OF ty_out,
         icon      TYPE icon_d,
         stat      TYPE c LENGTH 1,
         stat_t    TYPE c LENGTH 14,
         lifnr     TYPE lifnr,
         lifnr_n   TYPE name1_gp,
         matnr     TYPE matnr,
         matnr_n   TYPE maktx,
         ekorg     TYPE ekorg,
         werks     TYPE werks_d,
         ebeln     TYPE ebeln,
         ebelp     TYPE ebelp,
         infnr     TYPE infnr,
         gr_qty    TYPE p LENGTH 13 DECIMALS 3,
         datab     TYPE datab,
         datbi     TYPE datbi,
         new_datbi TYPE datbi,
         kbetr     TYPE kbetr_kond,
         konwa     TYPE konwa,
         message   TYPE c LENGTH 200,
       END OF ty_out.

* 정산 대상 자재 (입고 정산 대상 조회 기준)
TYPES: BEGIN OF ty_tgt,
         lifnr  TYPE lifnr,
         matnr  TYPE matnr,
         ekorg  TYPE ekorg,
         werks  TYPE werks_d,
         ebeln  TYPE ebeln,
         ebelp  TYPE ebelp,
         gr_qty TYPE p LENGTH 13 DECIMALS 3,
       END OF ty_tgt.

* 인포레코드 단가 구간
TYPES: BEGIN OF ty_ip,
         lifnr       TYPE lifnr,
         matnr       TYPE matnr,
         ekorg       TYPE ekorg,
         werks       TYPE werks_d,
         datab       TYPE datab,
         datbi       TYPE datbi,
         infnr       TYPE infnr,
         lifnr_n     TYPE name1_gp,
         matnr_n     TYPE maktx,
         mtart       TYPE mtart,
         eina_loekz  TYPE loekz,
         eine_loekz  TYPE loekz,
         kbetr_i     TYPE kbetr_kond,
         konwa_i     TYPE konwa,
         kpein_i     TYPE kpein,
         kmein_i     TYPE kmein,
         zfr1_i      TYPE kbetr_kond,
         zfr1_unit_i TYPE konwa,
         zfr2_i      TYPE kbetr_kond,
         zfr2_unit_i TYPE konwa,
       END OF ty_ip.

CONSTANTS: gc_x TYPE c LENGTH 1 VALUE 'X',
           gc_e TYPE c LENGTH 1 VALUE 'E'.

DATA: gt_out TYPE STANDARD TABLE OF ty_out,
      gv_err TYPE abap_bool.

*----------------------------------------------------------------------*
* 선택화면
*----------------------------------------------------------------------*
DATA: gv_lifnr TYPE lifnr.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(28) c_bukrs FOR FIELD p_bukrs.
    PARAMETERS p_bukrs TYPE t001-bukrs OBLIGATORY DEFAULT '6000'.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(28) c_werks FOR FIELD p_werks.
    PARAMETERS p_werks TYPE t001w-werks OBLIGATORY.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(28) c_ekgrp FOR FIELD p_ekgrp.
    PARAMETERS p_ekgrp TYPE t024-ekgrp OBLIGATORY.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(28) c_perio FOR FIELD p_period.
    PARAMETERS p_period TYPE j_7ls990-spmon OBLIGATORY.
  SELECTION-SCREEN END OF LINE.
  SELECT-OPTIONS s_lifnr FOR gv_lifnr.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(28) c_end FOR FIELD p_end.
    PARAMETERS p_end TYPE sy-datum.            " 공백 = 정산월 말일
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(28) c_all FOR FIELD p_all.
    PARAMETERS p_all AS CHECKBOX.              " 유효(V) 건도 표시
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(28) c_test FOR FIELD p_test.
    PARAMETERS p_test AS CHECKBOX DEFAULT 'X'. " 테스트(조회만)
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b2.

*----------------------------------------------------------------------*
INITIALIZATION.
  c_bukrs = '회사코드'.
  c_werks = '플랜트'.
  c_ekgrp = '구매그룹'.
  c_perio = '정산월'.
  c_end   = '연장 종료일(공백=월말)'.
  c_all   = '유효 건도 표시'.
  c_test  = '테스트(조회만)'.

* 정산월 기본값 = 전월
  DATA: lv_first TYPE sy-datum,
        lv_prev  TYPE sy-datum.
  lv_first = sy-datum.
  lv_first+6(2) = '01'.
  lv_prev = lv_first - 1.
  p_period = lv_prev(6).

AT SELECTION-SCREEN.
  IF p_end IS NOT INITIAL AND p_end(6) <> p_period.
    MESSAGE '연장 종료일은 정산월 안의 날짜여야 합니다.' TYPE 'E'.
  ENDIF.

START-OF-SELECTION.
  PERFORM get_data.
  CHECK gv_err IS INITIAL.

  IF p_test IS INITIAL.
    PERFORM extend_infor.
  ENDIF.

  PERFORM show_alv.

*&---------------------------------------------------------------------*
*& FORM GET_DATA
*&---------------------------------------------------------------------*
FORM get_data.

  DATA: lt_tgt  TYPE STANDARD TABLE OF ty_tgt,
        lt_ip   TYPE SORTED TABLE OF ty_ip
                WITH NON-UNIQUE KEY lifnr matnr ekorg werks datab,
        ls_last TYPE ty_ip,
        ls_out  TYPE ty_out.

  CLEAR: gt_out, gv_err.

* 정산월 1일 / 말일(연장 종료일)
  DATA(lv_from) = CONV sy-datum( p_period && '01' ).
  DATA(lv_end)  = p_end.
  IF lv_end IS INITIAL.
    lv_end = lv_from + 31.
    lv_end+6(2) = '01'.
    lv_end = lv_end - 1.
  ENDIF.

* 1. 정산 대상 자재 (ZGTMMR5030 조회 기준)
  SELECT lifnr, matnr, ekorg, werks, ebeln, ebelp, SUM( matgr ) AS gr_qty
    FROM zgtmm_cv_get_po_gr_bymon
    WHERE bukrs = @p_bukrs
      AND werks = @p_werks
      AND ekgrp = @p_ekgrp
      AND spmon = @p_period
      AND lifnr IN @s_lifnr
      AND matgr > 0
    GROUP BY lifnr, matnr, ekorg, werks, ebeln, ebelp
    INTO CORRESPONDING FIELDS OF TABLE @lt_tgt.

  IF lt_tgt IS INITIAL.
    MESSAGE '정산 대상 입고 데이터가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    gv_err = abap_true.
    RETURN.
  ENDIF.

* 2. 대상 자재의 인포레코드 단가 구간 (PB00, 일반구매)
  SELECT lifnr, matnr, ekorg, werks, datab, datbi, infnr, lifnr_n, matnr_n,
         mtart, eina_loekz, eine_loekz, kbetr_i, konwa_i, kpein_i, kmein_i,
         zfr1_i, zfr1_unit_i, zfr2_i, zfr2_unit_i
    FROM zgtmm_cv_get_infoprice
    FOR ALL ENTRIES IN @lt_tgt
    WHERE lifnr = @lt_tgt-lifnr
      AND matnr = @lt_tgt-matnr
      AND ekorg = @lt_tgt-ekorg
      AND werks = @lt_tgt-werks
      AND esokz = '0'
    INTO CORRESPONDING FIELDS OF TABLE @lt_ip.

* 3. 판정
  LOOP AT lt_tgt ASSIGNING FIELD-SYMBOL(<ls_tgt>).

    CLEAR: ls_out, ls_last.
    DATA(lv_cover) = abap_false.
    DATA(lv_del)   = abap_false.
    DATA(lv_type)  = abap_false.
    DATA(lv_found) = abap_false.

    ls_out-lifnr  = <ls_tgt>-lifnr.
    ls_out-matnr  = <ls_tgt>-matnr.
    ls_out-ekorg  = <ls_tgt>-ekorg.
    ls_out-werks  = <ls_tgt>-werks.
    ls_out-ebeln  = <ls_tgt>-ebeln.
    ls_out-ebelp  = <ls_tgt>-ebelp.
    ls_out-gr_qty = <ls_tgt>-gr_qty.

    LOOP AT lt_ip ASSIGNING FIELD-SYMBOL(<ls_ip>)
         WHERE lifnr = <ls_tgt>-lifnr
           AND matnr = <ls_tgt>-matnr
           AND ekorg = <ls_tgt>-ekorg
           AND werks = <ls_tgt>-werks.

      ls_out-lifnr_n = <ls_ip>-lifnr_n.
      ls_out-matnr_n = <ls_ip>-matnr_n.
      ls_out-infnr   = <ls_ip>-infnr.

      IF <ls_ip>-mtart <> 'MCFE' AND <ls_ip>-mtart <> 'MCHA' AND <ls_ip>-mtart <> 'HAWA'.
        lv_type = abap_true.
        CONTINUE.
      ENDIF.

      IF <ls_ip>-eina_loekz IS NOT INITIAL OR <ls_ip>-eine_loekz IS NOT INITIAL.
        lv_del = abap_true.
        CONTINUE.
      ENDIF.

      lv_found = abap_true.

      IF <ls_ip>-datab <= lv_end AND <ls_ip>-datbi >= lv_end.
        lv_cover = abap_true.
      ENDIF.

*     정산기준일 이전에 끝난 구간 중 종료일이 가장 늦은 것 = 연장 후보
      IF <ls_ip>-datbi < lv_end AND <ls_ip>-datbi > ls_last-datbi.
        ls_last = <ls_ip>.
      ENDIF.
    ENDLOOP.

    CASE abap_true.
      WHEN lv_cover.
        ls_out-stat = 'V'.
        ls_out-stat_t = '유효'.
        ls_out-icon = icon_led_green.
      WHEN lv_found.
        IF ls_last-datbi >= lv_from.
          ls_out-stat   = 'E'.
          ls_out-stat_t = '연장대상'.
          ls_out-icon   = icon_led_yellow.
        ELSE.
          ls_out-stat   = 'B'.
          ls_out-stat_t = '월이전 종료'.
          ls_out-icon   = icon_led_red.
          ls_out-message = '정산월 이전에 종료된 단가입니다. 인포레코드 확인 필요'.
        ENDIF.
        ls_out-datab     = ls_last-datab.
        ls_out-datbi     = ls_last-datbi.
        ls_out-kbetr     = ls_last-kbetr_i.
        ls_out-konwa     = ls_last-konwa_i.
        ls_out-infnr     = ls_last-infnr.
        IF ls_out-stat = 'E'.
          ls_out-new_datbi = lv_end.
        ENDIF.
      WHEN lv_del.
        ls_out-stat = 'D'.
        ls_out-stat_t = '삭제건'.
        ls_out-icon = icon_led_red.
        ls_out-message = '인포레코드 삭제 플래그 - 연장하지 않음'.
      WHEN lv_type.
        ls_out-stat = 'M'.
        ls_out-stat_t = '대상외'.
        ls_out-icon = icon_led_inactive.
        ls_out-message = '자재유형이 MCFE/MCHA/HAWA 가 아님 - ZGTMMR1100 대상 아님'.
      WHEN OTHERS.
        ls_out-stat = 'N'.
        ls_out-stat_t = '단가없음'.
        ls_out-icon = icon_led_red.
        PERFORM diagnose_none USING <ls_tgt> lv_end CHANGING ls_out-message ls_out-infnr.
    ENDCASE.

    IF ls_out-stat = 'V' AND p_all IS INITIAL.
      CONTINUE.
    ENDIF.

    APPEND ls_out TO gt_out.
  ENDLOOP.

  SORT gt_out BY stat lifnr matnr ebeln ebelp.

  IF gt_out IS INITIAL.
    MESSAGE '연장이 필요한 자재가 없습니다. (모두 정산기준일에 유효)' TYPE 'S'.
    gv_err = abap_true.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM EXTEND_INFOR
*&---------------------------------------------------------------------*
*& 연장대상(E) 건의 PB00 종료일을 NEW_DATBI 로 변경 (건별 COMMIT)
*&---------------------------------------------------------------------*
FORM extend_infor.

  DATA: lv_cnt TYPE i.

  LOOP AT gt_out TRANSPORTING NO FIELDS WHERE stat = 'E'.
    lv_cnt = lv_cnt + 1.
  ENDLOOP.
  IF lv_cnt = 0.
    MESSAGE '연장대상(E) 건이 없습니다.' TYPE 'S'.
    RETURN.
  ENDIF.

  DATA lv_answer TYPE c LENGTH 1.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'OEM 인포레코드 종료일 연장'
      text_question         = |연장대상 { lv_cnt }건의 인포레코드 종료일을 변경합니다. 진행하시겠습니까?|
      text_button_1         = '예'
      text_button_2         = '아니오'
      default_button        = '2'
      display_cancel_button = ''
    IMPORTING
      answer                = lv_answer.
  IF lv_answer <> '1'.
    MESSAGE '취소되었습니다.' TYPE 'S'.
    LOOP AT gt_out ASSIGNING FIELD-SYMBOL(<ls_cancel>) WHERE stat = 'E'.
      <ls_cancel>-message = '사용자 취소'.
    ENDLOOP.
    RETURN.
  ENDIF.

  LOOP AT gt_out ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE stat = 'E'.

*   기존 단가 구간 재조회 (ZFR1/ZFR2 등 연장 시 같이 넘길 값)
    SELECT SINGLE kbetr_i, konwa_i, kpein_i, kmein_i,
                  zfr1_i, zfr1_unit_i, zfr2_i, zfr2_unit_i
      FROM zgtmm_cv_get_infoprice
      WHERE lifnr = @<ls_out>-lifnr
        AND matnr = @<ls_out>-matnr
        AND ekorg = @<ls_out>-ekorg
        AND werks = @<ls_out>-werks
        AND esokz = '0'
        AND datab = @<ls_out>-datab
        AND datbi = @<ls_out>-datbi
      INTO @DATA(ls_cond).
    IF sy-subrc <> 0.
      <ls_out>-icon    = icon_led_red.
      <ls_out>-message = '기존 단가 구간을 다시 읽지 못했습니다.'.
      CONTINUE.
    ENDIF.

    DATA: ls_eina  TYPE mewieina,
          ls_eeina TYPE mewieina,
          ls_einax TYPE mewieinax,
          ls_eine  TYPE mewieine,
          ls_eeine TYPE mewieine,
          ls_einex TYPE mewieinex,
          lt_val   TYPE STANDARD TABLE OF mewivalidity,
          lt_con   TYPE STANDARD TABLE OF mewicondition,
          lt_rtn   TYPE STANDARD TABLE OF bapireturn,
          lv_amt_i TYPE matdoc-dmbtr,
          lv_amt_e TYPE bapicurr-bapicurr.

    CLEAR: ls_eina, ls_eeina, ls_einax, ls_eine, ls_eeine, ls_einex,
           lt_val, lt_con, lt_rtn.

    ls_eina  = VALUE #( info_rec = <ls_out>-infnr
                        material = <ls_out>-matnr
                        vendor   = <ls_out>-lifnr ).
    ls_einax = VALUE #( info_rec = gc_x
                        material = gc_x
                        vendor   = gc_x ).
    ls_eine  = VALUE #( purch_org = <ls_out>-ekorg
                        plant     = <ls_out>-werks
                        info_type = '0' ).
    ls_einex = VALUE #( purch_org = gc_x
                        plant     = gc_x
                        info_type = gc_x ).

*   유효기간: 시작일 유지, 종료일만 연장
    APPEND VALUE #( valid_from = <ls_out>-datab
                    valid_to   = <ls_out>-new_datbi ) TO lt_val.

*   PB00 금액 (내부 → 외부 통화형식)
    lv_amt_i = ls_cond-kbetr_i.
    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
      EXPORTING
        currency        = ls_cond-konwa_i
        amount_internal = lv_amt_i
      IMPORTING
        amount_external = lv_amt_e.

    APPEND VALUE #( cond_count = '01'
                    cond_type  = 'PB00'
                    cond_value = lv_amt_e
                    currency   = ls_cond-konwa_i
                    cond_p_unt = ls_cond-kpein_i
                    cond_unit  = ls_cond-kmein_i ) TO lt_con.

*   ZFR1/ZFR2 조건은 ZGTMMR1050 과 같은 방식으로 기존 값 유지
    IF ls_cond-zfr1_i IS NOT INITIAL.
      APPEND VALUE #( cond_count = '02'
                      cond_type  = 'ZFR1'
                      cond_value = ls_cond-zfr1_i
                      currency   = ls_cond-zfr1_unit_i ) TO lt_con.
    ENDIF.
    IF ls_cond-zfr2_i IS NOT INITIAL.
      APPEND VALUE #( cond_count = '03'
                      cond_type  = 'ZFR2'
                      cond_value = ls_cond-zfr2_i
                      currency   = ls_cond-zfr2_unit_i ) TO lt_con.
    ENDIF.

    CALL FUNCTION 'ME_INFORECORD_MAINTAIN'
      EXPORTING
        i_eina        = ls_eina
        i_einax       = ls_einax
        i_eine        = ls_eine
        i_einex       = ls_einex
      IMPORTING
        e_eina        = ls_eeina
        e_eine        = ls_eeine
      TABLES
        cond_validity = lt_val
        condition     = lt_con
        return        = lt_rtn.

    IF line_exists( lt_rtn[ type = gc_e ] ) OR ls_eeina-info_rec IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      <ls_out>-icon    = icon_led_red.
      <ls_out>-stat_t  = '실패'.
      READ TABLE lt_rtn INTO DATA(ls_rtn) WITH KEY type = gc_e.
      <ls_out>-message = COND #( WHEN sy-subrc = 0 THEN ls_rtn-message
                                 ELSE '인포레코드 번호가 반환되지 않았습니다.' ).
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = gc_x.
      <ls_out>-icon    = icon_led_green.
      <ls_out>-stat_t  = '연장완료'.
      <ls_out>-datbi   = <ls_out>-new_datbi.
      <ls_out>-message = '종료일을 연장했습니다.'.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SHOW_ALV
*&---------------------------------------------------------------------*
FORM show_alv.

  DATA lo_alv TYPE REF TO cl_salv_table.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_alv
                              CHANGING  t_table      = gt_out ).

      lo_alv->get_functions( )->set_all( abap_true ).
      lo_alv->get_display_settings( )->set_list_header(
        COND #( WHEN p_test = abap_true
                THEN |OEM 인포레코드 종료일 연장 - 테스트 ({ p_period })|
                ELSE |OEM 인포레코드 종료일 연장 - 실행 ({ p_period })| ) ).

      DATA(lo_cols) = lo_alv->get_columns( ).
      lo_cols->set_optimize( abap_true ).

      DATA: lt_names TYPE STANDARD TABLE OF lvc_fname.
      lt_names = VALUE #( ( 'ICON' ) ( 'STAT_T' ) ( 'LIFNR_N' ) ( 'MATNR_N' ) ( 'EBELN' ) ( 'EBELP' ) ( 'INFNR' )
                          ( 'GR_QTY' ) ( 'DATAB' ) ( 'DATBI' ) ( 'NEW_DATBI' )
                          ( 'KBETR' ) ( 'MESSAGE' ) ).
      DATA(lt_text) = VALUE string_table( ( `상태` ) ( `판정` ) ( `공급업체명` ) ( `자재명` ) ( `구매오더` ) ( `품목` ) ( `인포레코드` )
                                          ( `입고수량` ) ( `시작일` ) ( `종료일` ) ( `연장종료일` )
                                          ( `단가` ) ( `메시지` ) ).
      LOOP AT lt_names INTO DATA(lv_name).
        DATA(lv_txt) = lt_text[ sy-tabix ].
        DATA(lo_col) = lo_cols->get_column( lv_name ).
        lo_col->set_short_text( CONV #( lv_txt ) ).
        lo_col->set_medium_text( CONV #( lv_txt ) ).
        lo_col->set_long_text( CONV #( lv_txt ) ).
      ENDLOOP.

      lo_cols->get_column( 'STAT' )->set_visible( abap_false ).

      lo_alv->display( ).

    CATCH cx_salv_error INTO DATA(lx_salv).
      MESSAGE lx_salv->get_text( ) TYPE 'E'.
  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DIAGNOSE_NONE
*&---------------------------------------------------------------------*
*& 단가없음(N) 원인 구분: EINA → EINE(구매조직/플랜트) → A017 PB00 순으로 확인
*&---------------------------------------------------------------------*
FORM diagnose_none USING    ps_tgt TYPE ty_tgt
                            pv_end TYPE sy-datum
                   CHANGING pv_msg   TYPE ty_out-message
                            pv_infnr TYPE ty_out-infnr.

  CLEAR: pv_msg, pv_infnr.

  SELECT infnr FROM eina
    WHERE lifnr = @ps_tgt-lifnr
      AND matnr = @ps_tgt-matnr
    INTO TABLE @DATA(lt_infnr).
  IF sy-subrc <> 0.
    pv_msg = '인포레코드(공급업체+자재) 없음 - 신규 생성 필요'.
    RETURN.
  ENDIF.

  SELECT infnr, esokz, loekz FROM eine
    FOR ALL ENTRIES IN @lt_infnr
    WHERE infnr = @lt_infnr-infnr
      AND ekorg = @ps_tgt-ekorg
      AND werks = @ps_tgt-werks
    INTO TABLE @DATA(lt_eine).
  IF sy-subrc <> 0.
*   구매조직 단위(플랜트 공백) EINE 만 있는 인포레코드인지 확인 (ZGTMMR1140 일괄 생성 대상)
    SELECT infnr FROM eine
      FOR ALL ENTRIES IN @lt_infnr
      WHERE infnr = @lt_infnr-infnr
        AND ekorg = @ps_tgt-ekorg
        AND werks = @space
      INTO TABLE @DATA(lt_org).
    IF sy-subrc = 0.
      DATA(lv_org_infnr) = lt_org[ 1 ]-infnr.
      pv_infnr = lv_org_infnr.
      pv_msg = |인포레코드 { lv_org_infnr }: 구매조직 { ps_tgt-ekorg } 단위(플랜트 공백)만 있음 - 플랜트 { ps_tgt-werks } 데이터 생성 필요(ZGTMMR1140)|.
    ELSE.
      pv_infnr = lt_infnr[ 1 ]-infnr.
      pv_msg = |인포레코드 { lt_infnr[ 1 ]-infnr }는 있으나 구매조직 { ps_tgt-ekorg } 데이터 없음|.
    ENDIF.
    RETURN.
  ENDIF.

  pv_infnr = lt_eine[ 1 ]-infnr.
  DATA(lv_esokz) = VALUE #( lt_eine[ 1 ]-esokz OPTIONAL ).
  IF NOT line_exists( lt_eine[ esokz = '0' ] ).
    pv_msg = |인포레코드 유형이 { lv_esokz } 입니다 (ZGTMMR1100은 유형 0만 대상)|.
    RETURN.
  ENDIF.

  SELECT SINGLE datab, datbi FROM a017
    WHERE kappl = 'M' AND kschl = 'PB00'
      AND lifnr = @ps_tgt-lifnr
      AND matnr = @ps_tgt-matnr
      AND ekorg = @ps_tgt-ekorg
      AND werks = @ps_tgt-werks
      AND esokz = '0'
    INTO @DATA(ls_a017).
  IF sy-subrc <> 0.
    pv_msg = |인포레코드 { lt_eine[ esokz = '0' ]-infnr } 에 플랜트 { ps_tgt-werks } PB00 단가조건 없음 - 단가 생성 필요|.
    RETURN.
  ENDIF.

  pv_infnr = lt_eine[ esokz = '0' ]-infnr.
  pv_msg = |PB00 구간은 있으나 조건(KONH/KONP) 삭제 또는 마스터(LFM1/MAKT 등) 누락 가능 ({ ls_a017-datab DATE = ISO } ~ { ls_a017-datbi DATE = ISO })|.

ENDFORM.
