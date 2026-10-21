*&---------------------------------------------------------------------*
*& Include          ZGTPPR2070F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_parameter_description
*&---------------------------------------------------------------------*
FORM get_parameter_description .
* SPG
  IF NOT p_spgcd IS INITIAL.
    CLEAR zppt0107.
    SELECT SINGLE descr INTO p_descr
             FROM zppt0107
            WHERE spgcd EQ p_spgcd.
  ELSE.
    CLEAR p_descr.
  ENDIF.

* 플랜트명
  IF NOT p_werks IS INITIAL.
    CLEAR t001w.
    SELECT SINGLE name1 INTO p_name1
             FROM t001w
            WHERE werks EQ p_werks.
  ELSE.
    CLEAR p_name1.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_first_screen
*&---------------------------------------------------------------------*
FORM modify_first_screen .

  LOOP AT SCREEN.
    IF screen-group1 = 'M1'.
      screen-input = 0.
      screen-intensified = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_button
*&---------------------------------------------------------------------*
FORM set_button .

  CHECK p_call IS INITIAL.

  CLEAR gv_dyntxt.
  gv_dyntxt-icon_id = icon_table_settings.
  gv_dyntxt-icon_text = gv_dyntxt-text = TEXT-004.
  gv_dyntxt-quickinfo = TEXT-004.
  sscrfields-functxt_01 = gv_dyntxt.

  CLEAR gv_dyntxt.
  gv_dyntxt-icon_id = icon_table_settings.
  gv_dyntxt-icon_text = gv_dyntxt-text = TEXT-022.
  gv_dyntxt-quickinfo = TEXT-022.
  sscrfields-functxt_02 = gv_dyntxt.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_maintain_view
*&---------------------------------------------------------------------*
FORM call_maintain_view USING pv_gubun.

  DATA : lv_view_name TYPE dd02v-tabname.

  CASE pv_gubun.
    WHEN '1'.
      lv_view_name = 'ZGTPPT2110'.
    WHEN '2'.
      lv_view_name = 'ZGTPPT2121'.
  ENDCASE.

  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action                       = 'U'
*     CORR_NUMBER                  = '          '
*     GENERATE_MAINT_TOOL_IF_MISSING       = ' '
*     SHOW_SELECTION_POPUP         = ' '
      view_name                    = lv_view_name
*     NO_WARNING_FOR_CLIENTINDEP   = ' '
*     RFC_DESTINATION_FOR_UPGRADE  = ' '
*     CLIENT_FOR_UPGRADE           = ' '
*     VARIANT_FOR_SELECTION        = ' '
      complex_selconds_used        = 'X'
*     CHECK_DDIC_MAINFLAG          = ' '
*     SUPPRESS_WA_POPUP            = ' '
*   TABLES
*     DBA_SELLIST                  =
*     EXCL_CUA_FUNCT               =
    EXCEPTIONS
      client_reference             = 1
      foreign_lock                 = 2
      invalid_action               = 3
      no_clientindependent_auth    = 4
      no_database_function         = 5
      no_editor_function           = 6
      no_show_auth                 = 7
      no_tvdir_entry               = 8
      no_upd_auth                  = 9
      only_show_allowed            = 10
      system_failure               = 11
      unknown_field_in_dba_sellist = 12
      view_not_found               = 13
      maintenance_prohibited       = 14
      OTHERS                       = 15.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form authority_checking_proc
*&---------------------------------------------------------------------*
FORM authority_checking_proc .
*& 플랜트에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
  ID 'WERKS'  FIELD p_werks.

  IF sy-subrc <> 0.
    "플랜트[P_WERKS] 작업권한을 확인하세요.
    MESSAGE e006 WITH TEXT-005 p_werks TEXT-006.

  ELSE.
*& MRP관리자에 대한 권한체크
    AUTHORITY-CHECK OBJECT 'ZPP_SPGCD'
    ID 'WERKS'  FIELD p_werks
    ID 'SPGCD'  FIELD p_spgcd.

    IF sy-subrc <> 0.

      MESSAGE e006 WITH TEXT-007 p_spgcd TEXT-006.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data .

*- 설비 Capa. 구성 관련 필요 데이터 취합
  PERFORM get_data_basic_data.

*- ALV용 동적 테이블 구성
  PERFORM create_dynamic_alv_table.

  PERFORM make_disp_data.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_basic_data
*&---------------------------------------------------------------------*
FORM get_data_basic_data .

  DATA : BEGIN OF ls_matnr,
           matnr LIKE zgtppt2080-matnr,
         END OF ls_matnr.
  DATA : lt_matnr LIKE TABLE OF ls_matnr.

  DATA : BEGIN OF ls_link_idnrk,
           matnh   TYPE matnr,
           matnh_f TYPE matnr,
         END OF ls_link_idnrk.
  DATA : lt_link_idnrk LIKE TABLE OF ls_link_idnrk.
  DATA : lv_tabix TYPE i.


  CLEAR : gs_2080, gt_2080, gs_2120, gt_2120, gs_char, gt_char,
          gs_1010, gt_1010, gs_2110, gt_2110, gs_data, gt_data.

* 월간 계획 대상으로 선정된 판매 계획 확인
  SELECT * INTO CORRESPONDING FIELDS OF TABLE @gt_2080
    FROM zgtppt2080
   WHERE werks  EQ @p_werks
     AND spgcd  EQ @p_spgcd
     AND spec   IN @s_spec
     AND matnr  IN @s_matnf
     AND delfl  NE 'X'.

  SORT gt_2080 BY spec matnr.
  DELETE ADJACENT DUPLICATES FROM gt_2080 COMPARING spec matnr.

* 반제품 생산 계획 확인 : 동일 규격의 반제품은 설비(작업장)별 동일
  IF gt_2080[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE @gt_2120
      FROM zgtppt2120
       FOR ALL ENTRIES IN @gt_2080
     WHERE werks  EQ @gt_2080-werks
       AND spgcd  EQ @gt_2080-spgcd
       AND spec   EQ @gt_2080-spec
       AND idnrk  IN @s_matnh
       AND zstate IN @s_zstat.
  ENDIF.
  SORT gt_2120 BY spec cptype.

  LOOP AT gt_2080 INTO gs_2080.

    CLEAR : gs_data, gs_2120.
    gs_data-spec  = gs_2080-spec. "규격

    IF gs_2080-matnr IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          input        = gs_2080-matnr
        IMPORTING
          output       = gs_data-matnf
        EXCEPTIONS
          length_error = 1
          OTHERS       = 2. "완제품 코드
    ENDIF.

    CLEAR gs_2120.
    READ TABLE gt_2120 INTO gs_2120 WITH KEY spec  = gs_2080-spec
                                             matnr = gs_2080-matnr.
    IF gs_2120 IS NOT INITIAL.
      "사용자가 확인한 상태가 있는 규격이고, 외부 호출이면 PASS
      IF p_call IS NOT INITIAL AND gs_2120-zstate = 'U'.
        CONTINUE.
      ENDIF.

      gs_data-matnh = gs_2120-idnrk."반제품 코드

      "반제품 기준 완제품 코드
      IF gs_data-matnh IS NOT INITIAL AND gs_data-matnf IS INITIAL.
*      IF GS_DATA-MATNH IS NOT INITIAL .
        READ TABLE lt_link_idnrk  INTO ls_link_idnrk
                                  WITH KEY matnh = gs_data-matnh
                                  BINARY SEARCH.
        IF sy-subrc EQ 0.
          gs_data-matnh_f = ls_link_idnrk-matnh_f.
        ELSE.
          lv_tabix = sy-tabix.
          PERFORM get_fert_from_halb_matnr USING    gs_data-matnh
                                           CHANGING gs_data-matnh_f.

          CLEAR ls_link_idnrk.
          ls_link_idnrk-matnh = gs_data-matnh.
          ls_link_idnrk-matnh_f = gs_data-matnh_f.
          INSERT ls_link_idnrk INTO lt_link_idnrk INDEX lv_tabix.
        ENDIF.
      ELSEIF gs_data-matnf IS NOT INITIAL.
        gs_data-matnh_f = gs_data-matnf.

      ENDIF.

      "반제품 코드 없으면 상태값 에러 표시
      IF gs_data-matnh IS INITIAL.
        gs_data-icon = icon_led_red.
      ELSE.
        "상태값 업데이트
        IF gs_2120-zstate = 'I'.
          gs_data-icon = icon_led_yellow.
        ELSEIF gs_2120-zstate = 'U'.
          gs_data-icon = icon_led_green.
        ENDIF.
        "연속 생산일
        CLEAR gs_2120.
        READ TABLE gt_2120 INTO gs_2120 WITH KEY spec   = gs_data-spec
                                                 idnrk  = gs_data-matnh
                                                 cptype = '01'.
        IF gs_2120 IS NOT INITIAL.
          gs_data-vgwrt1 = gs_2120-vgwrt.
        ENDIF.
        "교체 소요일
        CLEAR gs_2120.
        READ TABLE gt_2120 INTO gs_2120 WITH KEY spec   = gs_data-spec
                                                 idnrk  = gs_data-matnh
                                                 cptype = '02'.
        IF gs_2120 IS NOT INITIAL.
          gs_data-vgwrt2 = gs_2120-vgwrt.
        ENDIF.
      ENDIF.
    ELSE.
      gs_data-icon = icon_led_red.

      "/s 2026.02.02.zlsgpp5.CHM2601-00657.절연 반제품 자재코드 미생성
      "   항목에 대해서 완제품 자재코드 존재 시 반제품 코드 자동 탐색
      "   및 설정 기능 추가
      PERFORM find_ins_matnh  USING gs_data-matnf
                              CHANGING gs_data-matnh.
      "/e 2026.02.02.zlsgpp5.CHM2601-00657
      "/s 2026.05.26.zlsgpp5.CHM2605-00421.반제품으로 필드 데이터 조회.
      gs_data-matnh_f = gs_data-matnf.

      CLEAR gs_2120.
      READ TABLE gt_2120 INTO gs_2120 WITH KEY spec  = gs_data-spec
                                               idnrk = gs_data-matnh.
      IF gs_2120 IS NOT INITIAL.
        "반제품 코드 없으면 상태값 에러 표시
        IF gs_data-matnh IS INITIAL.
          gs_data-icon = icon_led_red.
        ELSE.
          "상태값 업데이트
          IF gs_2120-zstate = 'I'.
            gs_data-icon = icon_led_yellow.
          ELSEIF gs_2120-zstate = 'U'.
            gs_data-icon = icon_led_green.
          ENDIF.
        ENDIF.

        "연속 생산일
        CLEAR gs_2120.
        READ TABLE gt_2120 INTO gs_2120 WITH KEY spec   = gs_data-spec
                                                 idnrk  = gs_data-matnh
                                                 cptype = '01'.
        IF gs_2120 IS NOT INITIAL.
          gs_data-vgwrt1 = gs_2120-vgwrt.
        ENDIF.

        "교체 소요일
        CLEAR gs_2120.
        READ TABLE gt_2120 INTO gs_2120 WITH KEY spec   = gs_data-spec
                                                 idnrk  = gs_data-matnh
                                                 cptype = '02'.
        IF gs_2120 IS NOT INITIAL.
          gs_data-vgwrt2 = gs_2120-vgwrt.
        ENDIF.
      ENDIF.
      "/e 2026.05.26.zlsgpp5.CHM2605-00421.
    ENDIF.

    gs_data-zstate = gs_2120-zstate. "확인 상태
    APPEND gs_data TO gt_data.

    "속성 정보를 취합하기 위해 취합
    ls_matnr-matnr = gs_data-matnh_f.
    APPEND ls_matnr TO lt_matnr.
    ls_matnr-matnr = gs_data-matnh.
    APPEND ls_matnr TO lt_matnr.

  ENDLOOP.

  DELETE lt_matnr WHERE matnr EQ space.
  SORT lt_matnr BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_matnr COMPARING matnr.

* 속성 정보는 완제품 기준
  IF lt_matnr[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE @gt_char
      FROM zgtcvmstval
      FOR ALL ENTRIES IN @lt_matnr
      WHERE werks EQ @p_werks
        AND matnr EQ @lt_matnr-matnr.
  ENDIF.

* 자재 속성 확인용 필드
  SELECT * INTO CORRESPONDING FIELDS OF TABLE @gt_1010
    FROM zgtppt1010
    WHERE module_kind EQ 'PP'
      AND codegrp     EQ '2060'
      AND fld_01      EQ @p_werks
      AND fld_02      EQ @p_spgcd.
  SORT gt_1010 BY fld_03.

* 설비(작업장) 선속 정보는 반제품 기준
  SELECT a~werks, a~spgcd, a~gong_cd, a~arbpl, b~objid,
         a~seq, c~ktext
    INTO CORRESPONDING FIELDS OF TABLE @gt_2110
    FROM zgtppt2110 AS a
    LEFT OUTER JOIN crhd AS b ON  a~arbpl EQ b~arbpl
                              AND b~objty EQ 'A'
                              AND b~werks EQ @p_werks
    INNER JOIN crtx AS c      ON  b~objty EQ c~objty
                              AND b~objid EQ c~objid
                              AND c~spras EQ @sy-langu
   WHERE a~werks   EQ @p_werks
     AND a~spgcd   EQ @p_spgcd.
  SORT gt_2110 BY gong_cd seq.

* 반제품 공정 반영
  LOOP AT gt_data INTO gs_data.

    gv_tabix = sy-tabix.

    IF gs_data-matnh IS NOT INITIAL.
      PERFORM get_pdcaprocname USING gs_data-matnh.
    ENDIF.

    MODIFY gt_data FROM gs_data INDEX gv_tabix.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_dynamic_alv_table
*&---------------------------------------------------------------------*
FORM create_dynamic_alv_table .

  PERFORM set_disp_table.

  PERFORM create_dynamic_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_disp_table
*&---------------------------------------------------------------------*
FORM set_disp_table .

  DATA : lt_fcat TYPE slis_t_fieldcat_alv.
  DATA : lv_col_pos  TYPE i,
         lv_col_pos2 TYPE i.
  DATA : lv_text(100),
         lv_ktext(40).
  DATA : ls_dfies_tab	LIKE dfies,
         lt_dfies_tab	LIKE TABLE OF	dfies.
  DATA : lv_tabname	  TYPE ddobjname,
         lv_fieldname	TYPE dfies-fieldname.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name     = sy-repid
      i_internal_tabname = 'GS_DATA'
      i_inclname         = 'ZGTPPR2070TOP'
      i_bypassing_buffer = 'X'
    CHANGING
      ct_fieldcat        = lt_fcat.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0100[]
    TABLES
      it_data         = gt_data.
* 자재 특성 필드 카탈로그 정의
  lv_col_pos = 100.
  LOOP AT gt_1010 INTO gs_1010.

    CLEAR : ls_dfies_tab, lt_dfies_tab, lv_tabname, lv_fieldname.
    lv_tabname   = gs_1010-fld_05.
    lv_fieldname = gs_1010-fld_06.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = lv_tabname
        fieldname      = lv_fieldname
      TABLES
        dfies_tab      = lt_dfies_tab
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.

    IF sy-subrc = 0.

      CLEAR ls_dfies_tab.
      READ TABLE lt_dfies_tab INTO ls_dfies_tab INDEX 1.

      APPEND INITIAL LINE TO gt_fieldcat_0100
                             ASSIGNING FIELD-SYMBOL(<ls_fcat>).
      ADD 1 TO lv_col_pos.
      <ls_fcat>-col_pos   = lv_col_pos.
      <ls_fcat>-fieldname = gs_1010-fld_06.
      <ls_fcat>-reptext   = <ls_fcat>-coltext   = <ls_fcat>-tooltip
                          = gs_1010-fld_04.
      <ls_fcat>-datatype  = ls_dfies_tab-datatype.
      <ls_fcat>-dd_outlen = ls_dfies_tab-outputlen.
      IF ls_dfies_tab-datatype = 'DEC' OR ls_dfies_tab-datatype = 'QUAN'.
        IF ls_dfies_tab-outputlen > 16.
          <ls_fcat>-dd_outlen = '16'.
        ENDIF.
        <ls_fcat>-decimals  = '3'.
      ENDIF.
      <ls_fcat>-just = 'C'.

    ENDIF.

  ENDLOOP.
* 설비 선속 및 일 생산량 필드 카탈로그 정의
  lv_col_pos  = 300.
  lv_col_pos2 = 400.

  LOOP AT gt_2110 INTO gs_2110.
* 설비 선속
    lv_ktext = gs_2110-ktext && TEXT-014.
    APPEND INITIAL LINE TO gt_fieldcat_0100 ASSIGNING <ls_fcat>.
    ADD 1 TO lv_col_pos.
    <ls_fcat>-col_pos   = lv_col_pos.
    <ls_fcat>-fieldname = gs_2110-arbpl.
    <ls_fcat>-reptext   = <ls_fcat>-coltext   = <ls_fcat>-tooltip
                        = lv_ktext.
    <ls_fcat>-just      = 'R'.
    <ls_fcat>-datatype  = 'QUAN'.
    <ls_fcat>-dd_outlen = '9'.
    <ls_fcat>-decimals  = '3'.
    <ls_fcat>-edit      = abap_true.
** 월간 계획이 수립되지 않은 설비는 NO_OUT 처리
*    CLEAR gs_2110.
*    READ TABLE gt_2110 INTO gs_2110 WITH KEY arbpl = gs_crhd-arbpl.
*    IF sy-subrc <> 0.
*      <ls_fcat>-no_out = 'X'.
*    ELSE.
*      CLEAR <ls_fcat>-no_out.
*    ENDIF.
* 설비 일 생산량
    lv_ktext = gs_2110-ktext && TEXT-015.
    APPEND INITIAL LINE TO gt_fieldcat_0100 ASSIGNING <ls_fcat>.
    ADD 1 TO lv_col_pos2.
    <ls_fcat>-col_pos   = lv_col_pos2.
    <ls_fcat>-fieldname = gs_2110-arbpl && '2'.
    <ls_fcat>-reptext   = <ls_fcat>-coltext   = <ls_fcat>-tooltip
                        = lv_ktext.
    <ls_fcat>-just      = 'R'.
    <ls_fcat>-datatype  = 'QUAN'.
    <ls_fcat>-dd_outlen = '9'.
    <ls_fcat>-decimals  = '3'.
** 월간 계획이 수립되지 않은 설비는 NO_OUT 처리
*    CLEAR gs_2110.
*    READ TABLE gt_2110 INTO gs_2110 WITH KEY arbpl = gs_crhd-arbpl.
*    IF sy-subrc <> 0.
*      <ls_fcat>-no_out = 'X'.
*    ELSE.
*      CLEAR <ls_fcat>-no_out.
*    ENDIF.

  ENDLOOP.
* 기본 필드 카탈로그 정의
  LOOP AT gt_fieldcat_0100 ASSIGNING <ls_fcat>.
    CLEAR <ls_fcat>-key.
    CASE <ls_fcat>-fieldname.
      WHEN 'ICON'. "상태
        <ls_fcat>-col_pos = 1.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip
                          = TEXT-f01.
        <ls_fcat>-just = 'C'.
        <ls_fcat>-icon = abap_true.
        <ls_fcat>-key = abap_true.
      WHEN 'SPEC'. "규격
        <ls_fcat>-col_pos = 2.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip
                          = TEXT-f02.
        <ls_fcat>-just = 'L'.
        <ls_fcat>-key = abap_true.
      WHEN 'MATNF'. "완제품 코드
        <ls_fcat>-col_pos = 3.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip
                          = TEXT-f03.
        <ls_fcat>-just = 'C'.
        <ls_fcat>-key = abap_true.
      WHEN 'MATNH'. "반제품 코드
        CLEAR : <ls_fcat>-ref_table, <ls_fcat>-ref_field.
        <ls_fcat>-col_pos = 4.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip
                          = TEXT-f04.
        <ls_fcat>-just = 'C'.
        <ls_fcat>-edit = abap_true.
        <ls_fcat>-f4availabl = abap_true.
        <ls_fcat>-no_zero = abap_true.
      WHEN 'PDCAPROCNAME'. "반제품 공정
        <ls_fcat>-col_pos = 5.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip
                          = TEXT-f05.
        <ls_fcat>-just = 'C'.
      WHEN 'VGWRT1'. "연속 생산일
        CLEAR : <ls_fcat>-ref_table, <ls_fcat>-ref_field.
        <ls_fcat>-col_pos = 201.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip
                          = TEXT-f06.
        <ls_fcat>-just = 'R'.
        <ls_fcat>-edit = abap_true.
        <ls_fcat>-dd_outlen = '9'.
        <ls_fcat>-decimals  = '1'.
      WHEN 'VGWRT2'. "교체 소요일
        CLEAR : <ls_fcat>-ref_table, <ls_fcat>-ref_field.
        <ls_fcat>-col_pos = 202.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip
                          = TEXT-f07.
        <ls_fcat>-just = 'R'.
        <ls_fcat>-edit = abap_true.
        <ls_fcat>-dd_outlen = '9'.
        <ls_fcat>-decimals  = '1'.
      WHEN 'VGE02'. "선속 단위
        <ls_fcat>-col_pos = 203.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip
                          = TEXT-f08.
        <ls_fcat>-just = 'C'.
      WHEN 'ZSTATE' OR "확인 상태
         'MATNH_F'. "반제품 기준 완제품 코드
        <ls_fcat>-no_out = 'X'.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form toolbar_pros
*&---------------------------------------------------------------------*
FORM toolbar_pros USING po_sender
                        po_object TYPE REF TO cl_alv_event_toolbar_set
                        r_interactive.

  CASE po_sender.
    WHEN go_grid_0100.
      CASE abap_true.

          PERFORM set_toolbar TABLES po_object->mt_toolbar
            USING : 'CAL' icon_execute_object TEXT-008 TEXT-008 0.

          IF p_werks = '1302' AND p_spgcd = 'PC'.
            PERFORM set_toolbar TABLES po_object->mt_toolbar
              USING : 'CAL_DAYLINE' icon_execute_object TEXT-009 TEXT-009 0.
          ENDIF.
      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TOOLBAR
*&---------------------------------------------------------------------*
FORM set_toolbar TABLES pt_toolbar STRUCTURE stb_button
                  USING pv_function
                        pv_icon
                        pv_text
                        pv_quickinfo
                        pv_butn_type.

  DATA : ls_toolbar  TYPE stb_button.

  CLEAR ls_toolbar.
  ls_toolbar-function  = pv_function.
  ls_toolbar-icon      = pv_icon.
  IF pv_text IS NOT INITIAL.
    CONCATENATE ' '  pv_text ' '  INTO ls_toolbar-text SEPARATED BY space.
  ENDIF.
  ls_toolbar-quickinfo = pv_quickinfo.
  ls_toolbar-butn_type = pv_butn_type.
  APPEND ls_toolbar TO pt_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_pros
*&---------------------------------------------------------------------*
FORM user_command_pros USING po_sender TYPE REF TO cl_gui_alv_grid
                             pv_ucomm.

  CASE po_sender.
    WHEN go_grid_0100.
      CASE pv_ucomm.
        WHEN 'CAL'. " 설비 Capa. 계산
          PERFORM proc_calculation_capa USING po_sender.
        WHEN 'CAL_DAYLINE'. "설비 선속 계산
          PERFORM proc_calc_prd_speed USING po_sender.
      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_calculation_capa
*&---------------------------------------------------------------------*
FORM proc_calculation_capa USING po_sender TYPE REF TO cl_gui_alv_grid.
* 툴바 유저 커맨드로 실행할 경우 DATA CHANGED 태우지 않음.
  CLEAR : gv_user_command, gt_row_no, gt_row_no[].
*  gv_user_command = abap_true.

  CALL METHOD po_sender->get_selected_rows
    IMPORTING
      et_row_no = gt_row_no[].

  DELETE gt_row_no WHERE row_id = 0. " 서브토탈 제외

  CLEAR : gv_cnt, gv_error.
  DESCRIBE TABLE gt_row_no LINES gv_cnt.
  IF gv_cnt = 0.
    MESSAGE s000 WITH TEXT-m01 DISPLAY LIKE 'E'.
    gv_error = 'X'.
  ENDIF.

  CHECK gv_error IS INITIAL.

  <gt_main_disp_100_2> = <gt_main_disp_100>.
  REFRESH : <gt_main_disp_100>.
  SORT gt_row_no BY row_id DESCENDING.

  LOOP AT gt_row_no.

    READ TABLE <gt_main_disp_100_2> ASSIGNING <gs_main>
                                        INDEX gt_row_no-row_id.
    IF sy-subrc = 0.

      gv_tabix = gt_row_no-row_id.
      PERFORM common_logic_calculate_capa.

    ENDIF.

  ENDLOOP.
* 미 선택 라인은 다시 메인 동적 ALV에 반영
  LOOP AT <gt_main_disp_100_2> ASSIGNING <gs_main>.
    APPEND <gs_main> TO <gt_main_disp_100>.
  ENDLOOP.
  REFRESH : <gt_main_disp_100_2>.

  gv_columns = 'SPEC'.

  SPLIT gv_columns AT `,` INTO TABLE DATA(lt_column_tab).
  DATA(lt_order) = VALUE abap_sortorder_tab(
                  FOR wa IN lt_column_tab
                 ( name = condense( to_upper( wa ) ) ) ).

  TRY.
      SORT <gt_main_disp_100> BY (lt_order).
    CATCH cx_sy_dyn_table_ill_comp_val.

  ENDTRY.
* 변경된 ALV 값을 내부 ALV 정보에 반영하고 REFRESH하기 위해 임의 커맨드 부여
  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
    EXPORTING
      functioncode           = 'SETCHECK' " Function code
    EXCEPTIONS
      function_not_supported = 1 " Not supported on this front end platform
      OTHERS                 = 2.

  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed
*&---------------------------------------------------------------------*
FORM data_changed USING p_sender  TYPE REF TO cl_gui_alv_grid
                        po_data_changed TYPE REF TO
                        cl_alv_changed_data_protocol
                        pe_onf4
                        pe_ucomm.

  DATA : ls_mod_cells TYPE lvc_s_modi.
  DATA : lv_matnr   TYPE matnr,
         lv_matnr_f TYPE matnr.
  DATA : lv_icon(4),
         lv_error.

  DEFINE __set_err_msg.
    po_data_changed->add_protocol_entry(
        i_msgid     = 'ZGTPP00'                 " Message ID
        i_msgty     = 'E'                 " Message Type
        i_msgno     =  '006'                " Message No.
        i_msgv1     =  &1                " Message Variable1
        i_msgv2     =  &2                " Message Variable2
        i_msgv3     =  &3                " Message Variable3
        i_fieldname =  &4                " Field Name
        i_row_id    =  ls_mod_cells-row_id ).                " RowID
  END-OF-DEFINITION.

  DEFINE __modi_cell.
    po_data_changed->modify_cell(
      i_row_id     = &1                 " Row ID
      i_fieldname = &2                 " Field Name
      i_value       = &3 ).               " Value
  END-OF-DEFINITION.
* "설비 Capa. 계산' 후 Data Changed 타는 경우 이미 앞서 로직에서
* 선속 및 일 생산량을 계산했으므로 패스.
  IF gv_user_command IS NOT INITIAL.

    CLEAR gv_user_command.

  ELSE.

    LOOP AT po_data_changed->mt_good_cells INTO ls_mod_cells.

      READ TABLE <gt_main_disp_100> ASSIGNING <gs_main>
                                        INDEX ls_mod_cells-row_id.

      CASE p_sender.
        WHEN  go_grid_0100.
          CASE ls_mod_cells-fieldname.
            WHEN 'MATNH'. "반제품 코드

              CLEAR : lv_matnr, lv_matnr_f, lv_icon, gv_spec.

              IF ls_mod_cells-value IS INITIAL.
* 반제품 코드 Clear시 이하 필드 전부 Clear
                PERFORM clear_dynamic_field USING po_data_changed ls_mod_cells.
                CONTINUE.

              ELSE.
*- 입력 반제품 코드 정상 여부 체크
                PERFORM check_input_halb_matnr USING    ls_mod_cells-value
                                                        po_data_changed
                                                        ls_mod_cells-row_id
                                               CHANGING lv_error lv_matnr.

                IF lv_error IS INITIAL.
*- 입력 반제품 기준 완제품 정보 취합하되 없을 경우 진행 불가 처리
                  __assign_field2 'MATNH_F'.
                  PERFORM get_fert_from_halb_matnr USING    lv_matnr
                                                   CHANGING lv_matnr_f.

                  IF lv_matnr_f IS INITIAL.

                    lv_icon = icon_led_red.
                    __modi_cell ls_mod_cells-row_id 'ICON' lv_icon.
* 반제품 코드 Clear시 이하 필드 전부 Clear
* 반제품 코드 clear
                    __assign_field 'MATNH'.
                    CLEAR <gv_field>.
                    __modi_cell ls_mod_cells-row_id 'MATNH' <gv_field>.
                    PERFORM clear_dynamic_field USING po_data_changed ls_mod_cells.

                    MESSAGE i000 WITH TEXT-018 TEXT-011 TEXT-016 lv_matnr.
                    CONTINUE.

                  ELSE.

                    <gv_field2> = lv_matnr_f.
                    __modi_cell ls_mod_cells-row_id 'MATNH_F' lv_matnr_f.

                  ENDIF.

                  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
                    EXPORTING
                      input        = <gv_field2>
                    IMPORTING
                      output       = lv_matnr_f
                    EXCEPTIONS
                      length_error = 1
                      OTHERS       = 2.
*- 입력 반제품 코드가 정상일 경우 설비 능력 관리 데이터 업데이트
                  PERFORM update_changed_halb_matnr USING lv_matnr
                                                          lv_matnr_f
                                                          po_data_changed
                                                          ls_mod_cells-row_id.
* 반제품, 반제품 기준 완제품 코드 둘 다 존재시 상태값 초록색 업데이트
                  IF lv_matnr IS NOT INITIAL AND lv_matnr_f IS NOT INITIAL.
                    lv_icon = icon_led_green.
                    __modi_cell ls_mod_cells-row_id 'ICON' lv_icon.
                  ENDIF.

                ENDIF.

              ENDIF.

            WHEN 'VGWRT1'. "연속 생산일

            WHEN 'VGWRT2'. "교체 소요일
* 선속 정보 변경했을 시에만 해당 CASE 문 탐.
            WHEN OTHERS.

              CLEAR gs_2110.
              READ TABLE gt_2110 INTO gs_2110
                                 WITH KEY werks = p_werks
                                          spgcd = p_spgcd
                                          arbpl = ls_mod_cells-fieldname.

              IF gs_2110 IS NOT INITIAL.

                CLEAR : gv_fieldname2.
                gv_fieldname2 = ls_mod_cells-fieldname && '2'.
                __assign_field 'VGE02'. "선속 단위
                __assign_field2 ls_mod_cells-fieldname. "설비 선속
                __assign_field3 gv_fieldname2.          "설비 일 생산량

                IF <gv_field3> IS ASSIGNED.

                  IF <gv_field> = 'H'.
                    <gv_field3> = ls_mod_cells-value * 24.
                  ELSEIF <gv_field> = 'MIN'.
                    <gv_field3> = ls_mod_cells-value * 1440.
                  ENDIF.

                  __modi_cell ls_mod_cells-row_id gv_fieldname2 <gv_field3>.

                ENDIF.

              ENDIF.

          ENDCASE.

        WHEN OTHERS.

      ENDCASE.

    ENDLOOP.
* 에러 발생했을 경우 메시지 출력 후 프로세스 중단하도록 함.
    IF lv_error IS NOT INITIAL.
      po_data_changed->display_protocol( ).
    ENDIF.

  ENDIF.
* 변경된 ALV 값을 내부 ALV 정보에 반영하고 REFRESH하기 위해 임의 커맨드 부여
  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
    EXPORTING
      functioncode           = 'SETCHECK' " Function code
    EXCEPTIONS
      function_not_supported = 1 " Not supported on this front end platform
      OTHERS                 = 2.

  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
FORM double_click USING p_sender TYPE REF TO cl_gui_alv_grid
                        p_row TYPE lvc_s_row
                        p_column TYPE lvc_s_col.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form alv_top_of_page
*&---------------------------------------------------------------------*
FORM alv_top_of_page USING po_sender TYPE REF TO cl_gui_alv_grid
                           pv_dyndoc_id TYPE REF TO cl_dd_document.

  CASE po_sender.
    WHEN go_grid_0100.
      PERFORM set_title_0100 CHANGING pv_dyndoc_id.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_0100
*&---------------------------------------------------------------------*
FORM set_title_0100 CHANGING pv_dyndoc_id TYPE REF TO cl_dd_document.

  DATA : lv_text(255) TYPE c.
  DATA : lv_name1 TYPE t001w-name1,
         lv_descr TYPE zppt0107-descr.
* 플랜트명
  IF p_werks IS NOT INITIAL.
    SELECT SINGLE name1
      FROM t001w
     WHERE werks EQ @p_werks
      INTO @lv_name1.
  ENDIF.

  CONCATENATE TEXT-012 p_werks ', ' lv_name1 INTO lv_text
  SEPARATED BY space.
  "텍스트 추가
  CALL METHOD pv_dyndoc_id->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = '20'.

  CALL METHOD pv_dyndoc_id->new_line.

  IF p_spgcd IS NOT INITIAL.
    SELECT SINGLE descr INTO lv_descr
             FROM zppt0107
            WHERE spgcd EQ p_spgcd.
  ENDIF.

  CONCATENATE TEXT-013 p_spgcd ', ' lv_descr INTO lv_text
  SEPARATED BY space.
  "텍스트 추가
  CALL METHOD pv_dyndoc_id->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = '20'.

  CALL METHOD pv_dyndoc_id->new_line.
  "위쪽에 추가한 텍스트 출력
  CALL METHOD go_dd_docu_0100->display_document
    EXPORTING
      parent = go_contain_top_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_dynamic_table
*&---------------------------------------------------------------------*
FORM create_dynamic_table .

  FREE : gt_main_disp_100, gt_main_disp_100_2.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      i_style_table             = abap_true
      it_fieldcatalog           = gt_fieldcat_0100
    IMPORTING
      ep_table                  = gt_main_disp_100
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.

  IF sy-subrc <> 0.
    MESSAGE s005 DISPLAY LIKE 'E' WITH TEXT-e01 TEXT-e02.
    LEAVE LIST-PROCESSING.
  ELSE.
    ASSIGN gt_main_disp_100->* TO <gt_main_disp_100>.

    CALL METHOD cl_alv_table_create=>create_dynamic_table
      EXPORTING
        i_style_table             = abap_true
        it_fieldcatalog           = gt_fieldcat_0100
      IMPORTING
        ep_table                  = gt_main_disp_100_2
      EXCEPTIONS
        generate_subpool_dir_full = 1
        OTHERS                    = 2.
    IF sy-subrc <> 0.
      MESSAGE s005 DISPLAY LIKE 'E' WITH TEXT-e01 TEXT-e02.
      LEAVE LIST-PROCESSING.
    ENDIF.

    ASSIGN gt_main_disp_100_2->* TO <gt_main_disp_100_2>.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_disp_data
*&---------------------------------------------------------------------*
FORM make_disp_data .

  DATA : ls_data TYPE REF TO data.
  DATA : lt_data TYPE REF TO data.

  REFRESH <gt_main_disp_100>.

  CREATE DATA ls_data LIKE LINE OF <gt_main_disp_100>.
  ASSIGN ls_data->* TO <gs_line>.
  CREATE DATA lt_data LIKE <gt_main_disp_100>.
  ASSIGN lt_data->* TO <gt_line>.

  LOOP AT gt_data INTO gs_data.

    CLEAR : <gs_line>, <gt_line>.
* 고정 필드 값 반영
    APPEND INITIAL LINE TO <gt_line> ASSIGNING <gs_main>.
    MOVE-CORRESPONDING gs_data TO <gs_line>.
    MOVE-CORRESPONDING <gs_line> TO <gs_main>.
* 속성 값 반영
    IF gs_data-matnh_f IS NOT INITIAL.

      CLEAR gs_char.
      READ TABLE gt_char INTO gs_char WITH KEY werks = p_werks
                                               matnr = gs_data-matnh_f.

      LOOP AT gt_1010 INTO gs_1010.

        CLEAR : gv_fieldname, gv_fieldname2.
        gv_fieldname  = gs_1010-fld_06.
        gv_fieldname2 = 'GS_CHAR-' && gs_1010-fld_06.
        __assign_field  gv_fieldname.
        __assign_field7 gv_fieldname2.
        <gv_field> = <gv_field7>.

      ENDLOOP.

    ENDIF.
* 선속 및 일 생산량 반영
    LOOP AT gt_2110 INTO gs_2110.

      CLEAR gs_2120.
      READ TABLE gt_2120 INTO gs_2120
                         WITH KEY werks  = p_werks
                                  spgcd  = p_spgcd
                                  spec   = gs_data-spec
                                  idnrk  = gs_data-matnh
                                  cptype = '03'
                                  arbpl  = gs_2110-arbpl.

      IF gs_2120 IS NOT INITIAL.

        CLEAR : gv_fieldname, gv_fieldname2.
        gv_fieldname  = gs_2110-arbpl.
        gv_fieldname2 = gs_2110-arbpl && '2'.
        __assign_field3 gv_fieldname.
        __assign_field4 gv_fieldname2.
        __assign_field5 'VGE02'.

        <gv_field3>  = gs_2120-vgwrt.
        <gv_field5>  = gs_2120-vgweh.
        IF gs_2120-vgweh = 'H'.
          <gv_field4> = gs_2120-vgwrt * 24.
        ELSEIF gs_2120-vgweh = 'MIN'.
          <gv_field4> = gs_2120-vgwrt * 1440.
        ENDIF.

      ENDIF.

    ENDLOOP.

    APPEND LINES OF <gt_line> TO <gt_main_disp_100>.

  ENDLOOP.

  gv_columns = 'SPEC'.

  SPLIT gv_columns AT `,` INTO TABLE DATA(lt_column_tab).
  DATA(lt_order) = VALUE abap_sortorder_tab(
                  FOR wa IN lt_column_tab
                 ( name = condense( to_upper( wa ) ) ) ).

  TRY.
      SORT <gt_main_disp_100> BY (lt_order).
    CATCH cx_sy_dyn_table_ill_comp_val.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_fert_from_halb_matnr
*&---------------------------------------------------------------------*
FORM get_fert_from_halb_matnr USING    pv_matnh
                              CHANGING pv_matnf.

  FIELD-SYMBOLS <lfs_data> TYPE STANDARD TABLE.
  DATA : l_data   TYPE REF TO data,
         ls_bom   TYPE stpov_alv,
         lv_mtart LIKE mara-mtart.

  cl_salv_bs_runtime_info=>set( display  = abap_false
                                metadata = abap_false
                                data     = abap_true ).

  UNASSIGN <lfs_data>.

  SUBMIT rcs15001 WITH pm_idnrk = pv_matnh
                  WITH pm_werks = p_werks
                  WITH pm_mehrs = 'X'
                  AND RETURN.

  TRY.
      cl_salv_bs_runtime_info=>get_data_ref( IMPORTING
      r_data = l_data ).
      ASSIGN l_data->* TO <lfs_data>.
    CATCH cx_salv_bs_sc_runtime_info.
  ENDTRY.

  IF <lfs_data> IS ASSIGNED.

    CLEAR ls_bom.
    LOOP AT <lfs_data> INTO ls_bom.

      CLEAR lv_mtart.
      SELECT SINGLE mtart
        INTO lv_mtart
        FROM mara
       WHERE matnr EQ ls_bom-matnr
         AND mtart EQ 'MCFE'.

      IF lv_mtart IS NOT INITIAL.
        pv_matnf = ls_bom-matnr.
        EXIT.
      ENDIF.

    ENDLOOP.

  ENDIF.

  cl_salv_bs_runtime_info=>clear_all( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_pdcaprocname
*&---------------------------------------------------------------------*
FORM get_pdcaprocname USING pv_matnr.

  CLEAR gs_char.
  READ TABLE gt_char INTO gs_char WITH KEY werks = p_werks
                                           matnr = pv_matnr.
  IF gs_char IS NOT INITIAL.
    gs_data-pdcaprocname = gs_char-pdcaprocname.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_display
*&---------------------------------------------------------------------*
FORM proc_display .

  IF <gt_main_disp_100> IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE s001 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0100
*&---------------------------------------------------------------------*
FORM set_object_grid_0100 .

  CREATE OBJECT go_docking_0100
    EXPORTING
      repid                       = sy-repid
      dynnr                       = sy-dynnr
      extension                   = 10000
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5.
*화면 분할
  CREATE OBJECT go_splitter_0100
    EXPORTING
      parent  = go_docking_0100
      rows    = 2
      columns = 1.

  go_splitter_0100->set_row_height(
    EXPORTING
      id                =    1              " Row ID
      height            =    10 ).             " Height
* top 컨테이너
  CALL METHOD go_splitter_0100->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_contain_top_0100.
* bottom 컨테이너
  CALL METHOD go_splitter_0100->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_contain_0100.

  CREATE OBJECT go_grid_0100
    EXPORTING
      i_parent      = go_contain_0100
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_handler_register
*&---------------------------------------------------------------------*
FORM event_handler_register USING po_grid TYPE REF TO cl_gui_alv_grid.

  IF go_event_handler IS NOT BOUND.
    CREATE OBJECT go_event_handler.
  ENDIF.
*// Event Handler ##
  CASE po_grid.
    WHEN go_grid_0100.
      SET HANDLER go_event_handler->handle_top_of_page  FOR po_grid.
      SET HANDLER go_event_handler->handle_toolbar      FOR po_grid.
      SET HANDLER go_event_handler->handle_user_command FOR po_grid.
      SET HANDLER go_event_handler->handle_double_click FOR po_grid.
      SET HANDLER go_event_handler->handle_data_changed FOR po_grid.
      SET HANDLER go_event_handler->handle_onf4         FOR po_grid.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0100
*&---------------------------------------------------------------------*
FORM set_layout_grid_0100 .

  CLEAR gs_layout_0100.
  gs_layout_0100-cwidth_opt = abap_true.
  gs_layout_0100-no_rowins = abap_true.
  gs_layout_0100-stylefname = 'XYZSTYLEZYX'.
  gs_layout_0100-sel_mode   = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_cell_attribute_grid_0100
*&---------------------------------------------------------------------*
FORM set_cell_attribute_grid_0100 .

* 2026.02.02.zlsgpp5.CHM2601-00657 절연 반제품 자재코드 미생성 항목에 대해서
*   완제품 자재코드 존지 시 반제품 코드 자동 탐색 및 설정 기능 추가
  DATA : lt_celltab TYPE lvc_t_styl.
  DATA : ls_celltab TYPE lvc_s_styl.
  FIELD-SYMBOLS <lt_celltab> TYPE any.

  LOOP AT <gt_main_disp_100> ASSIGNING <gs_main>.

    ASSIGN COMPONENT 'ICON' OF STRUCTURE <gs_main> TO FIELD-SYMBOL(<icon>).
    ASSIGN COMPONENT 'MATNH' OF STRUCTURE <gs_main> TO FIELD-SYMBOL(<matnh>).

    IF <icon> EQ icon_led_red AND <matnh> IS NOT INITIAL.

      REFRESH lt_celltab.
      CLEAR ls_celltab.
      ls_celltab-fieldname = 'MATNH'.
      ls_celltab-style = alv_style_color_total.
      INSERT ls_celltab INTO TABLE lt_celltab.

      CHECK lt_celltab[] IS NOT INITIAL.

      IF <lt_celltab> IS ASSIGNED. UNASSIGN <lt_celltab>. ENDIF.
      ASSIGN COMPONENT gs_layout_0100-stylefname OF STRUCTURE <gs_main> TO <lt_celltab>.
      IF <lt_celltab> IS ASSIGNED.
        <lt_celltab> = lt_celltab.
      ENDIF.

    ENDIF.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_of_toolbar_grid_0100
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0100 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0100
        USING : cl_gui_alv_grid=>mc_fc_loc_undo,
                cl_gui_alv_grid=>mc_fc_auf,
                cl_gui_alv_grid=>mc_fc_check,
                cl_gui_alv_grid=>mc_fc_loc_paste,
                cl_gui_alv_grid=>mc_fc_loc_copy,
                cl_gui_alv_grid=>mc_fc_average,
                cl_gui_alv_grid=>mc_fc_graph,
                cl_gui_alv_grid=>mc_fc_info,
                cl_gui_alv_grid=>mc_fc_loc_copy_row,
                cl_gui_alv_grid=>mc_fc_loc_cut,
                cl_gui_alv_grid=>mc_fc_loc_delete_row,
                cl_gui_alv_grid=>mc_fc_loc_insert_row,
                cl_gui_alv_grid=>mc_fc_loc_append_row,
                cl_gui_alv_grid=>mc_fc_loc_paste,
                cl_gui_alv_grid=>mc_fc_loc_paste_new_row.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_exclude_toolbar_button
*&---------------------------------------------------------------------*
FORM add_exclude_toolbar_button TABLES p_table
                                 USING p_value.

  DATA: l_exclude TYPE ui_func.

  l_exclude = p_value.
  APPEND l_exclude TO p_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_sorttab_grid_0100
*&---------------------------------------------------------------------*
FORM set_sorttab_grid_0100 .

  REFRESH gt_sort_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_grid_0100_display
*&---------------------------------------------------------------------*
FORM call_grid_0100_display .

  CALL METHOD go_grid_0100->set_table_for_first_display
    EXPORTING
      is_layout                     = gs_layout_0100
      it_toolbar_excluding          = gt_exclude_0100
    CHANGING
      it_outtab                     = <gt_main_disp_100>
*     it_sort                       = gt_sort_0100
      it_fieldcatalog               = gt_fieldcat_0100
    EXCEPTIONS
      invalid_parameter_combination = 1                " Wrong Parameter
      program_error                 = 2                " Program Errors
      too_many_lines                = 3                " Too many Rows in Ready for Input Grid
      OTHERS                        = 4.
  IF sy-subrc <> 0.
    BREAK-POINT.
  ENDIF.

*& Edit  이벤트 등록
  go_grid_0100->set_ready_for_input( 1 ).
* IF MC_EVT_MODIFY  -> 바로 수정됨.
  CALL METHOD go_grid_0100->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD go_grid_0100->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  IF go_dd_docu_0100 IS BOUND.
    CALL METHOD go_dd_docu_0100->initialize_document.
  ELSE.
    CREATE OBJECT go_dd_docu_0100
      EXPORTING
        style = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD go_grid_0100->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE'
      i_dyndoc_id  = go_dd_docu_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_halb_matnr
*&---------------------------------------------------------------------*
FORM check_input_halb_matnr  USING    pv_value
                                      po_data_changed TYPE REF TO
                                      cl_alv_changed_data_protocol
                                      pv_row_id
                             CHANGING pv_error pv_matnr.

  DEFINE __set_err_msg.
    po_data_changed->add_protocol_entry(
        i_msgid     = 'ZGTPP00'                 " Message ID
        i_msgty     = 'E'                 " Message Type
        i_msgno     =  '006'                " Message No.
        i_msgv1     =  &1                " Message Variable1
        i_msgv2     =  &2                " Message Variable2
        i_msgv3     =  &3                " Message Variable3
        i_fieldname =  &4                " Field Name
        i_row_id    =  pv_row_id ).                " RowID
  END-OF-DEFINITION.
* 유효한 입력인지 확인
  CLEAR pv_matnr.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input        = pv_value
    IMPORTING
      output       = pv_matnr
    EXCEPTIONS
      length_error = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
    __set_err_msg : TEXT-010 TEXT-011 TEXT-016 'MATNH'.
    pv_error = abap_true.
    EXIT.
  ENDIF.
* 존재하는 반제품 코드인지 확인
  SELECT SINGLE matnr FROM mara
    INTO @DATA(lv_matnr_chk)
    WHERE matnr = @pv_matnr.

  IF sy-subrc NE 0.
    pv_error = abap_true.
    __set_err_msg : TEXT-010 TEXT-011 TEXT-016 'MATNH'.
    EXIT.
  ENDIF.
* 삭제여부 확인
  SELECT SINGLE mandt INTO @sy-mandt FROM zgtcvmstval
                      WHERE werks  EQ @p_werks
                        AND matnr  EQ @pv_matnr
                        AND lvormc EQ @space
                        AND lvormp EQ @space.

  IF sy-subrc <> 0.
    pv_error = abap_true.
    __set_err_msg : TEXT-017 TEXT-011 TEXT-012 'MATNH'.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_changed_halb_matnr
*&---------------------------------------------------------------------*
FORM update_changed_halb_matnr USING pv_matnr
                                     pv_matnr_f
                                     po_data_changed TYPE REF TO
                                     cl_alv_changed_data_protocol
                                     pv_row_id.

  DATA : lv_oprday LIKE zgtppt2130-oprday.

  DEFINE __modi_cell.
    po_data_changed->modify_cell(
      i_row_id     = &1                 " Row ID
      i_fieldname = &2                 " Field Name
      i_value       = &3 ).               " Value
  END-OF-DEFINITION.
*- 반제품, 반제품 기준 완제품 코드 및 속성 정보 + 반제품 공정 갱신
  __modi_cell pv_row_id 'MATNH' pv_matnr.
  __modi_cell pv_row_id 'MATNH_F' pv_matnr_f.
* 자재 속성 정보 Get
  CLEAR : gt_char, gr_matnr, gr_matnr[], gt_2120, gv_spec.

  __range_set pv_matnr. __range_set pv_matnr_f.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE @gt_char
           FROM zgtcvmstval
           WHERE werks EQ @p_werks
             AND matnr IN @gr_matnr.
* 반제품 공정 반영
  CLEAR : gs_char.
  READ TABLE gt_char INTO gs_char WITH KEY werks = p_werks
                                           matnr = pv_matnr.

  IF gs_char IS NOT INITIAL.
    __modi_cell pv_row_id 'PDCAPROCNAME' gs_char-pdcaprocname.
  ENDIF.
* 반제품 기준 완제품 속성 반영
  CLEAR gs_char.
  READ TABLE gt_char INTO gs_char WITH KEY werks = p_werks
                                           matnr = pv_matnr_f.

  LOOP AT gt_1010 INTO gs_1010.

    CLEAR gv_fieldname.
    gv_fieldname = 'GS_CHAR-' && gs_1010-fld_06.
    __assign_field7 gv_fieldname.
    gv_fieldname2 = gs_1010-fld_06.
    __modi_cell pv_row_id gv_fieldname2 <gv_field7>.

  ENDLOOP.

  __assign_field2 'SPEC'.
  gv_spec = <gv_field2>.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE @gt_2120
  FROM zgtppt2120
  WHERE werks EQ @p_werks
    AND spgcd EQ @p_spgcd
    AND spec  EQ @gv_spec.

  LOOP AT gt_2110 INTO gs_2110.

    CLEAR : gv_fieldname, gv_fieldname.
    gv_fieldname  = gs_2110-arbpl.
    gv_fieldname2 = gs_2110-arbpl && '2'.
    __assign_field6 gv_fieldname.
    __assign_field8 gv_fieldname2.
    __assign_field9 'VGE02'.

    CLEAR gs_2120.
    READ TABLE gt_2120 INTO gs_2120
                       WITH KEY werks  = p_werks
                                spgcd  = p_spgcd
                                spec   = gv_spec
                                idnrk  = pv_matnr
                                cptype = '03'
                                arbpl  = gs_2110-arbpl.

    IF gs_2120 IS NOT INITIAL.

      <gv_field6>  = gs_2120-vgwrt.
      IF gs_2120-vgweh = 'H'.
        <gv_field8> = gs_2120-vgwrt * 24.
      ELSEIF gs_2120-vgweh = 'MIN'.
        <gv_field8> = gs_2120-vgwrt * 1440.
      ENDIF.
      <gv_field9> = gs_2120-vgweh.

      __modi_cell pv_row_id gv_fieldname <gv_field6>. "선속
      __modi_cell pv_row_id gv_fieldname2 <gv_field8>. "일 생산량
      __modi_cell pv_row_id 'VGE02' <gv_field9>. "선속 단위
* 저장되어있지 않으면 공정에서 정보 취합해서 반영
    ELSE.

      __assign_field 'ICON'.

      PERFORM get_seonsok_from_routing USING pv_matnr gs_2110-arbpl.

      __modi_cell pv_row_id gv_fieldname <gv_field6>. "선속
      __modi_cell pv_row_id gv_fieldname2 <gv_field8>. "일 생산량
      __modi_cell pv_row_id 'VGE02' <gv_field9>. "선속 단위

    ENDIF.

  ENDLOOP.
* 연속 생산일 확인
  __assign_field8 'VGWRT1'.

  IF <gv_field8> IS INITIAL.

    CLEAR lv_oprday.
    SELECT SINGLE oprday INTO @lv_oprday
                    FROM zgtppt2130
                    WHERE werks EQ @p_werks
                      AND spgcd EQ @p_spgcd
                      AND datuv <= @sy-datum
                      AND datub >= @sy-datum
                      AND optype = '01'.

    <gv_field8> = lv_oprday.

  ENDIF.
* 교체 소요일 확인
  __assign_field8 'VGWRT2'.

  IF <gv_field8> IS INITIAL.

    CLEAR lv_oprday.
    SELECT SINGLE oprday INTO @lv_oprday
                    FROM zgtppt2130
                    WHERE werks EQ @p_werks
                      AND spgcd EQ @p_spgcd
                      AND datuv <= @sy-datum
                      AND datub >= @sy-datum
                      AND optype = '02'.

    <gv_field8> = lv_oprday.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form onf4_proc
*&---------------------------------------------------------------------*
FORM onf4_proc USING pv_fieldname  TYPE lvc_fname
                     pv_fieldvalue TYPE lvc_value
                     ps_row_no     TYPE lvc_s_roid
                     pr_event_data TYPE REF TO cl_alv_event_data
                     pt_bad_cells  TYPE lvc_t_modi
                     pv_display    TYPE char01.

  FIELD-SYMBOLS : <fs_modi> TYPE lvc_t_modi.
  FIELD-SYMBOLS : <lt_data> TYPE table.
  FIELD-SYMBOLS : <lv_value> TYPE any.

  DATA : ls_modi  TYPE lvc_s_modi,
         lv_value TYPE string.
  DATA : BEGIN OF lt_matnr OCCURS 0,
           matnr        LIKE marc-matnr,
           maktx        LIKE makt-maktx,
           pdcaprocname LIKE zgtcvmstval-pdcaprocname,
         END OF lt_matnr.
  DATA : lv_tabix LIKE sy-tabix.
  DATA : lt_return_tab TYPE TABLE OF ddshretval,
         ls_return_tab LIKE LINE OF lt_return_tab,
         lt_dselc      LIKE dselc OCCURS 0 WITH HEADER LINE.

  READ TABLE <gt_main_disp_100> ASSIGNING <gs_main>
                                    INDEX ps_row_no-row_id.

  CASE pv_fieldname.
    WHEN 'MATNH'.

      SELECT DISTINCT a~matnr, c~maktx, a~pdcaprocname
        INTO CORRESPONDING FIELDS OF TABLE @gt_char
        FROM zgtcvmstval AS a LEFT OUTER JOIN zgtppt2110 AS b
          ON a~pdcaproccode EQ b~gong_cd
          LEFT OUTER JOIN makt AS c
          ON a~matnr  EQ c~matnr
          AND c~spras EQ @sy-langu
          WHERE a~werks  EQ @p_werks
            AND a~lvormc EQ @space
            AND a~lvormp EQ @space
            AND b~spgcd  EQ @p_spgcd
            AND a~mtart  EQ 'MCHF'.

      IF gt_char[] IS NOT INITIAL.

        CLEAR : lt_matnr, lt_matnr[].

        LOOP AT gt_char INTO gs_char.

          lt_matnr-matnr = gs_char-matnr.
          lt_matnr-maktx = gs_char-maktx.
          lt_matnr-pdcaprocname = gs_char-pdcaprocname.
          APPEND lt_matnr.
          CLEAR lt_matnr.

        ENDLOOP.

        SORT lt_matnr BY matnr.

        REFRESH : lt_return_tab, lt_dselc.
        CLEAR : lt_return_tab, lt_dselc.

        lt_dselc-fldname = 'F0001'.
        lt_dselc-dyfldname = 'MATNR'.
        APPEND lt_dselc.

        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
          EXPORTING
            retfield        = pv_fieldname
*           DYNPPROG        = SY-CPROG "현재 프로그램명->ZTER0010
*           DYNPNR          = SY-DYNNR "현재 화면번호->0100
            dynprofield     = 'MATNH'  "F4누른 필드->DEPT_CD
            value_org       = 'S'     "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
            window_title    = '반제품 코드 조회' "Search Help 타이틀
            display         = 'F'
          TABLES
            value_tab       = lt_matnr "리스트용 인터널 테이블
            return_tab      = lt_return_tab "F4에서 선택한 값이 들어옴
            dynpfld_mapping = lt_dselc
          EXCEPTIONS
            parameter_error = 1
            no_values_found = 2
            OTHERS          = 3.

        CLEAR ls_return_tab.
        READ TABLE lt_return_tab INTO ls_return_tab WITH KEY retfield = 'MATNR'.
        IF ls_return_tab IS NOT INITIAL.
          pv_fieldvalue = ls_return_tab-fieldval.   "F4에서 선택한 값을 다시 넣어줌
        ENDIF.

        CHECK NOT pv_fieldvalue IS INITIAL.

        ASSIGN pr_event_data->m_data->* TO <fs_modi>. "DATA CHANGED 이벤트 태우기 위함
        ls_modi-row_id    = ps_row_no-row_id.
        ls_modi-fieldname = pv_fieldname.
        ls_modi-value     = pv_fieldvalue.
        APPEND ls_modi TO <fs_modi>.

      ELSE.

        __assign_field3 'ICON'.
        <gv_field3> = icon_led_red.

      ENDIF.

  ENDCASE.

  pr_event_data->m_event_handled = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form calculation_capa_data
*&---------------------------------------------------------------------*
FORM calculation_capa_data .

  DATA : lv_oprday LIKE zgtppt2130-oprday.

  IF <gv_field> NE icon_led_red.
* 우선, 반제품 별 설비 정보를 취합하고, 필요에 따라 동적으로 재배열
    PERFORM get_seonsok_from_routing USING <gv_field3> space.
* 반제품 기준 완제품 속성
    CLEAR gs_char.
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF @gs_char
             FROM zgtcvmstval
             WHERE werks EQ @p_werks
               AND matnr EQ @<gv_field4>.

    LOOP AT gt_1010 INTO gs_1010.

      CLEAR : gv_fieldname, gv_fieldname2.
      gv_fieldname  = gs_1010-fld_06.
      gv_fieldname2 = 'GS_CHAR-' && gs_1010-fld_06.
      __assign_field8 gv_fieldname.
      __assign_field7 gv_fieldname2.
      <gv_field8> = <gv_field7>.

    ENDLOOP.
* 반제품 공정
    __assign_field8 'PDCAPROCNAME'.
    SELECT SINGLE pdcaprocname INTO @<gv_field8> FROM zgtcvmstval
                                WHERE werks EQ @p_werks
                                  AND matnr EQ @<gv_field3>.
* 연속 생산일 확인
    __assign_field8 'VGWRT1'.

    IF <gv_field8> IS INITIAL.

      CLEAR lv_oprday.
      SELECT SINGLE oprday INTO @lv_oprday
                      FROM zgtppt2130
                      WHERE werks EQ @p_werks
                        AND spgcd EQ @p_spgcd
                        AND datuv <= @sy-datum
                        AND datub >= @sy-datum
                        AND optype = '01'.

      <gv_field8> = lv_oprday.

    ENDIF.
* 교체 소요일 확인
    __assign_field8 'VGWRT2'.

    IF <gv_field8> IS INITIAL.

      CLEAR lv_oprday.
      SELECT SINGLE oprday INTO @lv_oprday
                      FROM zgtppt2130
                      WHERE werks EQ @p_werks
                        AND spgcd EQ @p_spgcd
                        AND datuv <= @sy-datum
                        AND datub >= @sy-datum
                        AND optype = '02'.

      <gv_field8> = lv_oprday.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_halb_matnr_from_BOM
*&---------------------------------------------------------------------*
FORM get_halb_matnr_from_bom .

  CLEAR : gs_stb, gt_stb, gs_matcat, gt_matcat, gs_char, gt_char,
          gs_mat, gt_mat.

  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      capid                 = 'PP01'
      datuv                 = sy-datum
      mehrs                 = 'X'
      mtnrv                 = gv_matnr
      werks                 = p_werks
    TABLES
      stb                   = gt_stb
      matcat                = gt_matcat
    EXCEPTIONS
      alt_not_found         = 1
      call_invalid          = 2
      material_not_found    = 3
      missing_authorization = 4
      no_bom_found          = 5
      no_plant_data         = 6
      no_suitable_bom_found = 7
      conversion_error      = 8
      OTHERS                = 9.

  LOOP AT gt_matcat INTO gs_matcat.
* 해당되지 않는 자재는 제외하여 Dump 방지
    SELECT SINGLE a~mandt INTO @sy-mandt
                        FROM mara AS a INNER JOIN marc AS b
                          ON a~matnr EQ b~matnr
                        WHERE a~matnr EQ @gs_matcat-matnr
                          AND a~mtart EQ 'MCHF'
                          AND b~werks EQ @p_werks
                          AND b~lvorm EQ @space.

    IF sy-subrc = 0.

      CLEAR gs_mat.
      gs_mat-matnr = gs_matcat-matnr.
      APPEND gs_mat TO gt_mat.

    ENDIF.

  ENDLOOP.

  SORT gt_mat BY matnr.
  DELETE ADJACENT DUPLICATES FROM gt_mat COMPARING matnr.
* 월간 수립 작업장 관리에 등록된 공정 반제품만 추출
* 표준 BOM에서 반제품 찾을 수 없는 경우 상태값 에러 표시 - DATA CHANGED에서
  IF gt_mat[] IS NOT INITIAL.

    SELECT DISTINCT a~matnr, c~maktx, a~pdcaprocname
      INTO CORRESPONDING FIELDS OF TABLE @gt_char
      FROM zgtcvmstval AS a LEFT OUTER JOIN zgtppt2110 AS b
        ON a~pdcaproccode EQ b~gong_cd
        LEFT OUTER JOIN makt AS c
        ON a~matnr  EQ c~matnr
        AND c~spras EQ @sy-langu
        FOR ALL ENTRIES IN @gt_mat
        WHERE a~werks  EQ @p_werks
          AND a~matnr  EQ @gt_mat-matnr
          AND a~lvormc EQ @space
          AND a~lvormp EQ @space
          AND b~spgcd  EQ @p_spgcd.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ARBPL_CAPA
*&---------------------------------------------------------------------*
FORM save_arbpl_capa .

  DATA : lv_ok.

  CLEAR  : gt_row_no, gt_row_no[].

  CALL METHOD go_grid_0100->get_selected_rows
    IMPORTING
      et_row_no = gt_row_no[].

  CLEAR: gv_cnt.
  DESCRIBE TABLE gt_row_no LINES gv_cnt.
* 선택 라인 없으면 오류 메시지 출력
  IF gv_cnt = 0.
    MESSAGE s000 WITH TEXT-m01 DISPLAY LIKE 'E'.
  ENDIF.

  CHECK gv_cnt > 0.
* CALL FUNCTION - POPUP_TO_CONFIRM_STEP
  CLEAR: gv_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      titel     = TEXT-t02
      textline1 = TEXT-t03
      textline2 = ''
    IMPORTING
      answer    = gv_answer.
  CHECK gv_answer = 'J'.
* 상태 값 : 에러 건 선택 여부 확인
  CLEAR gv_error.
  LOOP AT gt_row_no.

    IF <gs_main> IS ASSIGNED. UNASSIGN <gs_main>. ENDIF.
    READ TABLE <gt_main_disp_100> ASSIGNING <gs_main>
                                  INDEX gt_row_no-row_id.
    IF sy-subrc = 0.

      __assign_field 'ICON'.

      IF <gv_field> EQ icon_led_red.

        gv_error = 'X'.
        MESSAGE s000 WITH TEXT-m02 DISPLAY LIKE 'E'.
        EXIT.

      ENDIF.

    ENDIF.

  ENDLOOP.

  CHECK gv_error IS INITIAL.

  CLEAR : gt_2120_s.
  LOOP AT gt_row_no.

    IF <gs_main> IS ASSIGNED. UNASSIGN <gs_main>. ENDIF.
    READ TABLE <gt_main_disp_100> ASSIGNING <gs_main>
                                  INDEX gt_row_no-row_id.

    IF sy-subrc = 0.
* 기존 SPEC 및 반제품 코드 기준으로 데이터 존재시 삭제 후 업데이트
      PERFORM delete_old_data_zgtppt2120.

      PERFORM merge_save_data.
* 연속 생산일
      __assign_field6 'VGWRT1'.
      PERFORM append_2120_yeonsok_change USING <gv_field6> '01'.
* 교체 소요일
      __assign_field6 'VGWRT2'.
      PERFORM append_2120_yeonsok_change USING <gv_field6> '02'.

    ENDIF.

  ENDLOOP.

  CLEAR lv_ok.
  IF gt_2120_s IS NOT INITIAL.

    MODIFY zgtppt2120 FROM TABLE gt_2120_s.
    IF sy-subrc = 0.
      lv_ok = 'X'.
      MESSAGE s000 WITH TEXT-m03.
      COMMIT WORK.
    ELSE.
      MESSAGE s000 WITH TEXT-m04 DISPLAY LIKE 'E'.
      ROLLBACK WORK.
    ENDIF.

  ENDIF.
* 저장 여부에 따라 상태값 업데이트
  LOOP AT gt_row_no.

    IF <gs_main> IS ASSIGNED. UNASSIGN <gs_main>. ENDIF.
    READ TABLE <gt_main_disp_100> ASSIGNING <gs_main>
                                  INDEX gt_row_no-row_id.

    IF sy-subrc = 0.

      __assign_field6 'ICON'.

      IF lv_ok = abap_true.
        <gv_field6> = icon_led_green.
      ELSE.
        <gv_field6> = icon_led_red.
      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form merge_save_data
*&---------------------------------------------------------------------*
FORM merge_save_data .

  __assign_field  'SPEC'."규격
  __assign_field2 'MATNH'."반제품 코드
  __assign_field4 'MATNF'."판매계획 완제품 코드
  __assign_field5 'VGE02'."선속 단위
* 선속
  LOOP AT gt_2110 INTO gs_2110.

    __assign_field3 gs_2110-arbpl."설비 선속

    CLEAR gs_2120.
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF @gs_2120
                    FROM zgtppt2120
                    WHERE werks  EQ @p_werks
                      AND spgcd  EQ @p_spgcd
                      AND spec   EQ @<gv_field>
                      AND idnrk  EQ @<gv_field2>
                      AND cptype EQ '03'
                      AND arbpl  EQ @gs_2110-arbpl.

    IF gs_2120 IS INITIAL.

      gs_2120-werks  = p_werks.
      gs_2120-spgcd  = p_spgcd.
      gs_2120-spec   = <gv_field>.
      gs_2120-idnrk  = <gv_field2>.
      gs_2120-cptype = '03'.
      gs_2120-arbpl  = gs_2110-arbpl.
      gs_2120-vgwrt  = <gv_field3>.
      gs_2120-vgweh  = <gv_field5>.
      gs_2120-matnr  = <gv_field4>. "값이 없으면 빈 값으로 저장
      IF p_call IS INITIAL.
        gs_2120-zstate = 'U'.
      ELSE.
        gs_2120-zstate = 'I'.
      ENDIF.
      gs_2120-erdat  = sy-datum.
      gs_2120-ernam  = sy-uname.

    ELSE.

      gs_2120-vgwrt  = <gv_field3>.
      gs_2120-vgweh  = <gv_field5>.
      gs_2120-matnr  = <gv_field4>. "값이 없으면 빈 값으로 저장
      IF p_call IS INITIAL.
        gs_2120-zstate = 'U'.
      ELSE.
        gs_2120-zstate = 'I'.
      ENDIF.
      gs_2120-aedat  = sy-datum.
      gs_2120-aenam  = sy-uname.

    ENDIF.

    APPEND gs_2120 TO gt_2120_s.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_zgtppt2120
*&---------------------------------------------------------------------*
FORM save_zgtppt2120 .
* 선속
  CLEAR : gt_2120_s.
  LOOP AT  <gt_main_disp_100> ASSIGNING <gs_main>.
* 기존 SPEC 및 반제품 코드 기준으로 데이터 존재시 삭제 후 업데이트
    PERFORM delete_old_data_zgtppt2120.

    PERFORM merge_save_data.

  ENDLOOP.
* 연속 생산일
  __assign_field5 'VGWRT1'.
  PERFORM append_2120_yeonsok_change USING <gv_field5> '01'.
* 교체 소요일
  __assign_field5 'VGWRT2'.
  PERFORM append_2120_yeonsok_change USING <gv_field5> '02'.

  IF gt_2120_s IS NOT INITIAL.

    MODIFY zgtppt2120 FROM TABLE gt_2120_s.
    IF sy-subrc = 0.
*      WRITE :/ TEXT-m03.
      COMMIT WORK.
    ELSE.
*      WRITE :/ TEXT-m04.
      ROLLBACK WORK.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_2120_yeonsok_change
*&---------------------------------------------------------------------*
FORM append_2120_yeonsok_change USING pv_field5
                                      pv_cptype.
  CLEAR gs_2120.
  SELECT SINGLE * INTO CORRESPONDING FIELDS OF @gs_2120
                  FROM zgtppt2120
                  WHERE werks  EQ @p_werks
                    AND spgcd  EQ @p_spgcd
                    AND spec   EQ @<gv_field>
                    AND idnrk  EQ @<gv_field2>
                    AND cptype EQ @pv_cptype.

  IF gs_2120 IS INITIAL.

    gs_2120-werks  = p_werks.
    gs_2120-spgcd  = p_spgcd.
    gs_2120-spec   = <gv_field>.
    gs_2120-idnrk  = <gv_field2>.
    gs_2120-cptype = pv_cptype.
    gs_2120-vgwrt  = pv_field5.
    gs_2120-matnr  = <gv_field4>.
    IF p_call IS INITIAL.
      gs_2120-zstate = 'U'.
    ELSE.
      gs_2120-zstate = 'I'.
    ENDIF.
    gs_2120-erdat  = sy-datum.
    gs_2120-ernam  = sy-uname.

  ELSE.

    gs_2120-vgwrt  = pv_field5.
    gs_2120-matnr  = <gv_field4>.
    IF p_call IS INITIAL.
      gs_2120-zstate = 'U'.
    ELSE.
      gs_2120-zstate = 'I'.
    ENDIF.
    gs_2120-aedat  = sy-datum.
    gs_2120-aenam  = sy-uname.

  ENDIF.

  APPEND gs_2120 TO gt_2120_s.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_seonsok_from_routing
*&---------------------------------------------------------------------*
FORM get_seonsok_from_routing USING pv_matnr pv_arbpl.

  DATA : lv_tabix LIKE sy-tabix.

  CLEAR : gs_mapl, gs_opr_tab, gt_opr_tab.
  SELECT SINGLE * INTO CORRESPONDING FIELDS OF @gs_mapl
                  FROM mapl
                  WHERE werks EQ @p_werks
                    AND matnr EQ @pv_matnr
                    AND plnty EQ 'N'.
* 라우팅을 찾을 수 없는 경우 상태값 에러 표시
*  IF gt_opr_tab[] IS INITIAL.
  IF gs_mapl IS INITIAL.
    <gv_field> = icon_led_red.
  ELSE.

    CALL FUNCTION 'CARO_ROUTING_READ'
      EXPORTING
        plnty        = 'N'
        plnnr        = gs_mapl-plnnr
        plnal        = gs_mapl-plnal
*       plnal        = '01'
        werks        = p_werks
      TABLES
        opr_tab      = gt_opr_tab
      EXCEPTIONS
        not_found    = 1
        ref_not_exp  = 2
        not_valid    = 3
        no_authority = 4
        OTHERS       = 5.

  ENDIF.

  LOOP AT gt_2110 INTO gs_2110.

    lv_tabix = sy-tabix.
* 해당 PERFORM문은 DATA CHANGED 이벤트와 같이 공유하고 있음.
* 아래 변수에 값이 있다는 건 DATA CHANGED 이벤트에서 설비 건별로
* LOOP 돌고 있음을 의미하므로 해당 설비에 대해서만 데이터 취합.
    IF pv_arbpl IS NOT INITIAL AND
      pv_arbpl NE gs_2110-arbpl.
      CONTINUE.
    ENDIF.

    CLEAR : gv_out, gs_opr_tab, gv_fieldname, gv_fieldname2.
    gv_fieldname  = gs_2110-arbpl.
    gv_fieldname2 = gs_2110-arbpl && '2'.
* 선속, 일 생산량 반영
    __assign_field6 gv_fieldname.
    __assign_field8 gv_fieldname2.
    __assign_field9 'VGE02'.

    READ TABLE gt_opr_tab INTO gs_opr_tab
                          WITH KEY werks = p_werks
                                   arbid = gs_2110-objid.

    IF gs_opr_tab IS NOT INITIAL.

      CLEAR gv_vgwrt.
      IF gs_opr_tab-vgw02 IS NOT INITIAL AND
        gs_opr_tab-bmsch IS NOT INITIAL.
        gv_vgwrt = gs_opr_tab-bmsch / gs_opr_tab-vgw02.
*        gv_vgwrt = gs_opr_tab-vgw02 / gs_opr_tab-bmsch.
      ENDIF.

      <gv_field6> = gv_vgwrt. "선속
      IF gs_opr_tab-vge02 = 'MIN'.
        <gv_field8> = gv_vgwrt * 1440.
      ELSEIF gs_opr_tab-vge02 = 'H'.
        <gv_field8> = gv_vgwrt * 24.
      ENDIF. "일 생산량
      <gv_field9> = gs_opr_tab-vge02. "선속 단위

    ELSE.
* 공정에 없는 작업장이면 선속, 일생산량 필드 CLEAR
      CLEAR : <gv_field6>, <gv_field8>.

    ENDIF.

  ENDLOOP.

  IF p_call IS INITIAL.

    go_grid_0100->set_frontend_fieldcatalog(
                  it_fieldcatalog = gt_fieldcat_0100 ).

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_f4_field_grid_0100
*&---------------------------------------------------------------------*
FORM set_f4_field_grid_0100 .

  DATA: lt_f4 TYPE lvc_t_f4 WITH HEADER LINE.

  CLEAR lt_f4.
  lt_f4-fieldname  = 'MATNH'.
  lt_f4-register   = 'X'.
  lt_f4-getbefore  = ' '.
  lt_f4-chngeafter = ' '.
  INSERT TABLE lt_f4.
*& ONF4 이벤트 등록
  CALL METHOD go_grid_0100->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_grid
*&---------------------------------------------------------------------*
FORM refresh_grid USING po_grid TYPE REF TO cl_gui_alv_grid..

  DATA: ls_scroll   TYPE lvc_s_stbl.

  ls_scroll-row = 'X'.
  ls_scroll-col = 'X'.
* 변경된 ALV 필드 정보를 반영할 때 LAYOUT도 같이 반영해줄 것
* DATA CHANGED에 'REFRESH_TABLE_DISPLAY' 명령어 줘도 반영안됨
* 유저 커맨드에 'DATA_CHANGED'에 임의로 추가한 명령어를 반영할 것
* EX) ZGTPPR2070F01 746 ~ 754 -> ZGTPPR2070I01 26 ~ 28
  po_grid->set_frontend_layout( is_layout = gs_layout_0100 ).

  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      is_stable = ls_scroll.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form common_logic_calculate_capa
*&---------------------------------------------------------------------*
FORM common_logic_calculate_capa .

  __assign_field  'ICON'."상태값
  __assign_field2 'MATNF'."판매 계획 완제품 코드
  __assign_field3 'MATNH'."반제품 코드
  __assign_field4 'MATNH_F'."반제품 기준 완제품 코드
* 반제품 코드, 판매 계획 완제품 코드 둘 다 없는 경우 상태값 에러 표시
  IF <gv_field2> IS INITIAL AND <gv_field3> IS INITIAL.

    <gv_field> = icon_led_red.
    APPEND <gs_main> TO <gt_main_disp_100>.

  ELSE.
* 반제품 코드가 없는 경우 판매 계획 완제품 BOM을 통해 취합
* 복수로 조회될 경우 전부 추가.
    CLEAR gs_char.
    IF <gv_field3> IS INITIAL.
* 판매계획 완제품 유/무 확인
      CLEAR gv_matnr.
      gv_matnr = <gv_field2>.
      PERFORM check_matnr_exist.
      IF sy-subrc <> 0. " 없는 자재면 에러
        <gv_field> = icon_led_red.
        APPEND <gs_main> TO <gt_main_disp_100>.
      ELSE.
        CLEAR gv_matnr.
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            input        = <gv_field2>
          IMPORTING
            output       = gv_matnr
          EXCEPTIONS
            length_error = 1
            OTHERS       = 2.
        <gv_field4> = gv_matnr.

        PERFORM get_halb_matnr_from_bom.
* 표준 BOM에서 반제품이 없으면 상태값 에러 표시 후 선택 라인 데이터 다시 반영
        IF gt_char[] IS INITIAL.

          <gv_field> = icon_led_red.
          APPEND <gs_main> TO <gt_main_disp_100>.

        ELSE.
* 반제품이 여러 건일 경우 전부 반영
          LOOP AT gt_char INTO gs_char.

            <gv_field3> = gs_char-matnr.
            <gv_field> = icon_led_green.
            PERFORM calculation_capa_data.
            APPEND <gs_main> TO <gt_main_disp_100>.

          ENDLOOP.

        ENDIF.

      ENDIF.
* 입력된 건은 그대로 반영 : 자재 유/무는 Data Changed에서 했으므로 패스
    ELSE.
* 반제품 기준 완제품 코드가 비었을 경우 가져올 것
      IF <gv_field4> IS INITIAL.
        PERFORM get_fert_from_halb_matnr USING    <gv_field3>
                                         CHANGING <gv_field4>.
      ENDIF.

      <gv_field> = icon_led_green.
      PERFORM calculation_capa_data.
      APPEND <gs_main> TO <gt_main_disp_100>.

    ENDIF.

  ENDIF.
* 처리한 라인은 제외
  gv_icon = <gv_field>.
  DELETE <gt_main_disp_100_2> INDEX gv_tabix.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form clear_dynamic_field
*&---------------------------------------------------------------------*
FORM clear_dynamic_field USING po_data_changed TYPE REF TO
                               cl_alv_changed_data_protocol
                               ps_mod_cells TYPE lvc_s_modi.

  DATA : lv_icon(4).

  DEFINE __modi_cell.
    po_data_changed->modify_cell(
      i_row_id     = &1                 " Row ID
      i_fieldname = &2                 " Field Name
      i_value       = &3 ).               " Value
  END-OF-DEFINITION.
* 상태값 업데이트
  __assign_field 'ICON'.
  <gv_field> = icon_led_red.
  __modi_cell ps_mod_cells-row_id 'ICON' <gv_field>.
* 반제품 기준 완제품 코드 Clear
  __assign_field 'MATNH_F'.
  CLEAR <gv_field>.
  __modi_cell ps_mod_cells-row_id 'MATNH_F' <gv_field>.
* 반제품 공정 Clear
  __assign_field 'PDCAPROCNAME'.
  CLEAR <gv_field>.
  __modi_cell ps_mod_cells-row_id 'PDCAPROCNAME' <gv_field>.
* 연속 생산일 Clear
  __assign_field 'VGWRT1'.
  CLEAR <gv_field>.
  __modi_cell ps_mod_cells-row_id 'VGWRT1' <gv_field>.
* 교체 소요일 Clear
  __assign_field 'VGWRT2'.
  CLEAR <gv_field>.
  __modi_cell ps_mod_cells-row_id 'VGWRT2' <gv_field>.
* 반제품 기준 완제품 속성 Clear
  LOOP AT gt_1010 INTO gs_1010.

    CLEAR gv_fieldname.
    gv_fieldname = gs_1010-fld_06.
    __assign_field6 gv_fieldname.
    CLEAR <gv_field6>.
    __modi_cell ps_mod_cells-row_id gv_fieldname <gv_field6>.

  ENDLOOP.
* 반제품 선속 및 일 생산량 Clear
  LOOP AT gt_2110 INTO gs_2110.

    CLEAR : gv_fieldname, gv_fieldname.
    gv_fieldname  = gs_2110-arbpl.
    gv_fieldname2 = gs_2110-arbpl && '2'.
    __assign_field3 gv_fieldname.
    __assign_field4 gv_fieldname2.
    __assign_field5 'VGE02'.
    CLEAR : <gv_field3>, <gv_field4>, <gv_field5>.
    __modi_cell ps_mod_cells-row_id gv_fieldname <gv_field3>. "선속
    __modi_cell ps_mod_cells-row_id gv_fieldname2 <gv_field4>. "일 생산량
    __modi_cell ps_mod_cells-row_id 'VGE02' <gv_field5>. "선속 단위

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_matnr_exist
*&---------------------------------------------------------------------*
FORM check_matnr_exist.

  SELECT SINGLE mandt INTO @sy-mandt FROM marc
                    WHERE werks EQ @p_werks
                      AND matnr EQ @gv_matnr
                      AND lvorm EQ @space.

  IF sy-subrc <> 0.
    <gv_field> = icon_led_red.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_OLD_DATA_ZGTPPT2120
*&---------------------------------------------------------------------*
FORM delete_old_data_zgtppt2120 .

  __assign_field  'SPEC'."규격
  __assign_field2 'MATNH'."판매계획 완제품 코드

  SELECT SINGLE mandt INTO @sy-mandt FROM zgtppt2120
                      WHERE werks EQ @p_werks
                        AND spgcd EQ @p_spgcd
                        AND spec  EQ @<gv_field>
                        AND idnrk EQ @<gv_field2>.

  IF sy-subrc = 0.
    DELETE FROM zgtppt2120
           WHERE werks EQ @p_werks
             AND spgcd EQ @p_spgcd
             AND spec  EQ @<gv_field>
             AND idnrk EQ @<gv_field2>.

    COMMIT WORK.
    WAIT UP TO '0.5' SECONDS.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CALC_PRD_SPEED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_SENDER
*&---------------------------------------------------------------------*
FORM proc_calc_prd_speed  USING    po_sender TYPE REF TO cl_gui_alv_grid.

  DATA : lt_rows TYPE lvc_t_row.
  DATA : lv_fieldname TYPE fieldname.

  DATA : BEGIN OF ls_constans,
           arbpl        TYPE arbpl,
           chk_zvolt    TYPE zgtppt2121-zvolt,
           chk_zconsize TYPE zgtppt2121-zconsize,
         END OF ls_constans.

  DATA : BEGIN OF ls_idnrk,
           idnrk      TYPE idnrk,
           zvolt      TYPE zgtppt2121-zvolt,
           zconsize   TYPE zgtppt2121-zconsize,
           mngko      TYPE cs_e_mngko,
           t_constans LIKE TABLE OF ls_constans,
         END OF ls_idnrk.
  DATA : lt_idnrk LIKE TABLE OF ls_idnrk.
  DATA : lv_tabix TYPE i.
  DATA : lv_volt_str TYPE string.
  DATA : lv_size_str TYPE string.
  DATA : lv_lineexist.

  FIELD-SYMBOLS <lv_idnrk> TYPE any.
  FIELD-SYMBOLS : <lv_volt> TYPE any.
  FIELD-SYMBOLS : <lv_size> TYPE any.
  FIELD-SYMBOLS : <lv_value> TYPE any.


  po_sender->get_selected_rows(
    IMPORTING
      et_index_rows = lt_rows ).                 " Indexes of Selected Rows

  DELETE lt_rows WHERE index = 0.

* 해당 라인의 유효성 체크 - 반제품 확인, 전압 및 도체 SIze 존재여부
  LOOP AT lt_rows INTO DATA(ls_rows).

    READ TABLE <gt_main_disp_100> ASSIGNING FIELD-SYMBOL(<ls_main>) INDEX ls_rows-index.

*  반제품 확인
    IF <lv_idnrk> IS ASSIGNED. UNASSIGN <lv_idnrk>. ENDIF.
    ASSIGN COMPONENT 'MATNH' OF STRUCTURE <ls_main> TO <lv_idnrk>.
    IF <lv_idnrk> IS ASSIGNED AND <lv_idnrk> IS NOT INITIAL. " 값이 존재 하지 않으면 오류처리
    ELSE.
      MESSAGE s006 DISPLAY LIKE 'E' WITH '반제품이 입력되지 않은 내역이 있습니다.'.
      RETURN.
    ENDIF.

    CLEAR ls_idnrk.
    READ TABLE lt_idnrk INTO ls_idnrk WITH KEY idnrk = <lv_idnrk> BINARY SEARCH.
    IF sy-subrc EQ 0.
      CONTINUE.
    ELSE.
      CLEAR lv_tabix.
      lv_tabix = sy-tabix.

* 원자재 표준 BOM 중 자재 내역이 "XLPE" 의 투입 수량 확인
      PERFORM chek_get_mngko USING <lv_idnrk> CHANGING ls_idnrk-mngko.
      IF ls_idnrk-mngko = 0. " 해당 표준수량 미존재시 오류처리
        MESSAGE s006 DISPLAY LIKE 'E' WITH '반제품 (' <lv_idnrk> ') 투입 자재를 확인 할 수 없습니다.'.
        RETURN.
      ENDIF.

      ls_idnrk-idnrk = <lv_idnrk>.

*  전압및 도체 사이즈
*  전압
      READ TABLE gt_1010 INTO DATA(ls_1010) WITH KEY fld_04 = '전압'.
      IF sy-subrc EQ 0.
        CLEAR lv_fieldname.
        lv_fieldname = ls_1010-fld_06.
        IF <lv_volt> IS ASSIGNED. UNASSIGN <lv_volt>. ENDIF.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main> TO <lv_volt>.
        IF <lv_volt> IS ASSIGNED AND <lv_volt> IS NOT INITIAL. " 값이 존재 하지 않으면 오류처리
        ELSE.
          MESSAGE s006 DISPLAY LIKE 'E' WITH '전압 및 도체 Size 정보를 찾을 수 없는 내역이 있습니다.'.
          RETURN.
        ENDIF.
      ELSE.
        MESSAGE s006 DISPLAY LIKE 'E' WITH '전압 및 도체 Size 정보를 찾을 수 없는 내역이 있습니다.'.
        RETURN.
      ENDIF.

      CLEAR lv_volt_str.
      lv_volt_str = <lv_volt>.
      REPLACE ALL OCCURRENCES OF REGEX '[^[:digit:]]' IN lv_volt_str WITH space.
      CONDENSE lv_volt_str.
      ls_idnrk-zvolt = lv_volt_str.
      PERFORM conversion_alpha CHANGING ls_idnrk-zvolt.

*  도체사이즈
      READ TABLE gt_1010 INTO ls_1010 WITH KEY fld_04 = '도체Size'.
      IF sy-subrc EQ 0.
        CLEAR lv_fieldname.
        lv_fieldname = ls_1010-fld_06.
        IF <lv_size> IS ASSIGNED. UNASSIGN <lv_size>. ENDIF.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main> TO <lv_size>.
        IF <lv_size> IS ASSIGNED AND <lv_size> IS NOT INITIAL. " 값이 존재 하지 않으면 오류처리
        ELSE.
          MESSAGE s006 DISPLAY LIKE 'E' WITH '전압 및 도체 Size 정보를 찾을 수 없는 내역이 있습니다.'.
          RETURN.
        ENDIF.
      ELSE.
        MESSAGE s006 DISPLAY LIKE 'E' WITH '전압 및 도체 Size 정보를 찾을 수 없는 내역이 있습니다.'.
        RETURN.
      ENDIF.

      CLEAR lv_size_str.
      lv_size_str = <lv_size>.
      REPLACE ALL OCCURRENCES OF REGEX '[^[:digit:]]' IN lv_size_str WITH space.

      CONDENSE lv_size_str.
      ls_idnrk-zconsize = lv_size_str.
      PERFORM conversion_alpha CHANGING ls_idnrk-zconsize.

      INSERT ls_idnrk INTO lt_idnrk INDEX lv_tabix.
    ENDIF.
  ENDLOOP.

* 선속 계산 진행
  CLEAR gv_answer.
  PERFORM popup_to_confirm_step USING 'N'
    ' '
    '설비 선속 계산 진행합니다. 작업 하시겠습니까?'
    '설비 선속 계산'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
    RETURN.
  ENDIF.

*   선속 계산을 위해 선속 상수테이블에서 데이터 추출
  DATA : lt_2121 TYPE TABLE OF zgtppt2121. " 선속 마스터 테이블
  DATA : lt_2121_tmp TYPE TABLE OF zgtppt2121.
  DATA : ls_2121_tmp1 TYPE zgtppt2121.
  DATA : ls_2121_tmp2 TYPE zgtppt2121.
  DATA : lv_dif TYPE zgtppt2121-zconst.
  DATA : lv_dif2 TYPE zgtppt2121-zconst.

  SELECT * FROM zgtppt2121 INTO TABLE lt_2121
    WHERE werks = p_werks
       AND gong_cd = 'INS'.

  LOOP AT lt_2121 ASSIGNING FIELD-SYMBOL(<ls_chk_2121>).
*     전압과 사이즈 필드 공백제거, 캐릭터 소트를 위한 알파컨버전 적용
    CONDENSE : <ls_chk_2121>-zvolt, <ls_chk_2121>-zconsize.
    PERFORM conversion_alpha CHANGING <ls_chk_2121>-zvolt.
    PERFORM conversion_alpha CHANGING <ls_chk_2121>-zconsize.
  ENDLOOP.

  SORT lt_2121 BY arbpl zconstc zvolt zconsize.

* 해당 반제품의 설비 선속계산 상수 구하기
  LOOP AT lt_idnrk ASSIGNING FIELD-SYMBOL(<ls_idnrk>).
    LOOP AT gt_2110 INTO gs_2110.
      CLEAR ls_constans.
      ls_constans-arbpl = gs_2110-arbpl.

* 전압기준 상수 찾기
      REFRESH lt_2121_tmp.
      lt_2121_tmp = VALUE #( FOR lw_2121 IN lt_2121 WHERE ( zconstc = '1'
                                                                               AND   arbpl = gs_2110-arbpl )
                                                 ( CORRESPONDING #( lw_2121 ) ) ).

      SORT lt_2121_tmp BY zvolt.
      DELETE ADJACENT DUPLICATES FROM lt_2121_tmp COMPARING zvolt.

      READ TABLE lt_2121_tmp TRANSPORTING NO FIELDS WITH KEY zvolt = <ls_idnrk>-zvolt BINARY SEARCH.
      IF sy-subrc EQ 0.
        ls_constans-chk_zvolt = <ls_idnrk>-zvolt.
      ELSE.
        CLEAR lv_tabix.
        lv_tabix = sy-tabix - 1.
*      현재 적용된 라인 조회
        CLEAR lv_lineexist.
        IF lv_tabix EQ 0.
          lv_lineexist = abap_true.
        ENDIF.
        CLEAR ls_2121_tmp1.
        READ TABLE lt_2121_tmp INTO ls_2121_tmp1 INDEX lv_tabix.

*      다음 라인 조회
        ADD 1 TO lv_tabix.
        CLEAR ls_2121_tmp2.
        READ TABLE lt_2121_tmp INTO ls_2121_tmp2 INDEX lv_tabix.
        IF sy-subrc NE 0.
          ls_constans-chk_zvolt = ls_2121_tmp1-zvolt.
        ELSE.
          CLEAR : lv_dif, lv_dif2.
          lv_dif = <ls_idnrk>-zvolt - ls_2121_tmp1-zvolt.
          lv_dif2 = ls_2121_tmp2-zvolt - <ls_idnrk>-zvolt .
          IF lv_lineexist = abap_true.
            ls_constans-chk_zvolt = ls_2121_tmp2-zvolt.
          ELSE.
            IF lv_dif < lv_dif2.
              ls_constans-chk_zvolt = ls_2121_tmp1-zvolt.
            ELSE.
              ls_constans-chk_zvolt = ls_2121_tmp2-zvolt.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

* 도체SIZE 기준 상수 찾기
      REFRESH lt_2121_tmp.
      lt_2121_tmp = VALUE #( FOR lw_2121 IN lt_2121 WHERE ( zconstc = '1'
                                                                               AND   arbpl = gs_2110-arbpl
                                                                               AND    zvolt = ls_constans-chk_zvolt )
                                                 ( CORRESPONDING #( lw_2121 ) ) ).

      SORT lt_2121_tmp BY zconsize.
      DELETE ADJACENT DUPLICATES FROM lt_2121_tmp COMPARING zconsize.

      READ TABLE lt_2121_tmp TRANSPORTING NO FIELDS WITH KEY zconsize = <ls_idnrk>-zconsize BINARY SEARCH.
      IF sy-subrc EQ 0.
        ls_constans-chk_zconsize = <ls_idnrk>-zconsize.
      ELSE.
        CLEAR lv_tabix.
        lv_tabix = sy-tabix - 1.

        CLEAR lv_lineexist.
        IF lv_tabix EQ 0.
          lv_lineexist = abap_true.
        ENDIF.
*      현재 적용된 라인 조회
        CLEAR ls_2121_tmp1.
        READ TABLE lt_2121_tmp INTO ls_2121_tmp1 INDEX lv_tabix.
*      다음 라인 조회
        ADD 1 TO lv_tabix.
        CLEAR ls_2121_tmp2.
        READ TABLE lt_2121_tmp INTO ls_2121_tmp2 INDEX lv_tabix.
        IF sy-subrc NE 0.
          ls_constans-chk_zconsize = ls_2121_tmp1-zconsize.
        ELSE.
          CLEAR : lv_dif, lv_dif2.
          lv_dif = <ls_idnrk>-zconsize - ls_2121_tmp1-zconsize.
          lv_dif2 = ls_2121_tmp2-zconsize - <ls_idnrk>-zconsize .
          IF lv_lineexist = abap_true.
            ls_constans-chk_zconsize = ls_2121_tmp2-zconsize.
          ELSE.
            IF lv_dif < lv_dif2.
              ls_constans-chk_zconsize = ls_2121_tmp1-zconsize.
            ELSE.
              ls_constans-chk_zconsize = ls_2121_tmp2-zconsize.
            ENDIF.
          ENDIF.
        ENDIF.

      ENDIF.

*      IF LS_CONSTANS-CHK_ZVOLT IS NOT INITIAL AND
*        LS_CONSTANS-CHK_ZCONSIZE IS NOT INITIAL. " 전압과 도체 사이즈 컨스턴스가 존재할시에만 어팬드
      APPEND ls_constans TO <ls_idnrk>-t_constans.
*      ENDIF.
    ENDLOOP.

  ENDLOOP.

  DATA : lv_zconst01 TYPE zgtppt2121-zconst. " 토출량 변수
  DATA : lv_zconst02 TYPE zgtppt2121-zconst. " 보정값 변수
  DATA : lv_zconst03 TYPE zgtppt2121-zconst.  " 배율 변수
  DATA : lv_zconst04 TYPE zgtppt2121-zconst.  " 선속 변수

  LOOP AT lt_rows INTO ls_rows.
    READ TABLE <gt_main_disp_100> ASSIGNING <ls_main> INDEX ls_rows-index.

*  반제품 조회
    IF <lv_idnrk> IS ASSIGNED. UNASSIGN <lv_idnrk>. ENDIF.
    ASSIGN COMPONENT 'MATNH' OF STRUCTURE <ls_main> TO <lv_idnrk>.
    IF <lv_idnrk> IS ASSIGNED AND <lv_idnrk> IS NOT INITIAL. " 값이 존재 하지 않으면 오류처리
      CLEAR ls_idnrk.
      READ TABLE lt_idnrk INTO ls_idnrk WITH KEY idnrk = <lv_idnrk> BINARY SEARCH.
      IF sy-subrc EQ 0.
        LOOP AT ls_idnrk-t_constans INTO ls_constans. " 설비별로 선속 진행하여 각각 필드에 어팬드
          CLEAR : lv_zconst01, lv_zconst02, lv_zconst03.
          REFRESH lt_2121_tmp.
          lt_2121_tmp = VALUE #( FOR lw_2121 IN lt_2121 WHERE ( arbpl = ls_constans-arbpl
                                                                                    AND  zvolt = ls_constans-chk_zvolt
                                                                                    AND  zconsize = ls_constans-chk_zconsize )
                                           ( CORRESPONDING #( lw_2121 ) ) ).
* 토출량 가져오기
          READ TABLE lt_2121_tmp INTO DATA(ls_2121_tmp) WITH KEY zconstc = '1'.
          IF sy-subrc EQ 0.
            lv_zconst01 = ls_2121_tmp-zconst / 60.
          ENDIF.

* 보정값 가져오기
          READ TABLE lt_2121_tmp INTO ls_2121_tmp WITH KEY zconstc = '2'.
          IF sy-subrc EQ 0.
            lv_zconst02 = ls_2121_tmp-zconst.
          ENDIF.

* 배율 가져오기
          READ TABLE lt_2121_tmp INTO ls_2121_tmp WITH KEY zconstc = '3'.
          IF sy-subrc EQ 0.
            lv_zconst03 = ls_2121_tmp-zconst.
          ELSE.
            lv_zconst03 = 1.
          ENDIF.

* 선속 계산 - 선속 계산 식 : 분당토출량 / (절연 원자재 투입량 / 보정값) * 배율
          CLEAR lv_zconst04.
          IF lv_zconst02 NE 0.
            lv_zconst04 = lv_zconst01 / ( ls_idnrk-mngko / lv_zconst02 ) * lv_zconst03.
          ELSE.
            lv_zconst04 = 0.
          ENDIF.

* 소수점 3
** 소숫점 반올림
*          CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
*            EXPORTING
*              I_RTYPE     = ' '
*              I_RUNIT     = '0.001'
*              I_VALUE     = LV_ZCONST04
*            IMPORTING
*              E_VALUE_RND = LV_ZCONST04.

* 저장.
*        선속
          CLEAR lv_fieldname.
          lv_fieldname = ls_constans-arbpl.
          IF <lv_value> IS ASSIGNED. UNASSIGN <lv_value>. ENDIF.
          ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main> TO <lv_value>.
          IF <lv_value> IS ASSIGNED.
            <lv_value> = lv_zconst04.
          ENDIF.

*        일생산량
          CLEAR lv_fieldname.
          lv_fieldname = ls_constans-arbpl && '2'.
          IF <lv_value> IS ASSIGNED. UNASSIGN <lv_value>. ENDIF.
          ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main> TO <lv_value>.
          IF <lv_value> IS ASSIGNED.
            <lv_value> = lv_zconst04 * 1440.
          ENDIF.

        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDLOOP.

  PERFORM refresh_grid USING po_sender.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHEK_GET_MNGKO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LV_IDNRK>
*&      <-- LS_IDNRK_MNGKO
*&---------------------------------------------------------------------*
FORM chek_get_mngko  USING    pv_idnrk TYPE idnrk
                     CHANGING pv_mngko TYPE cs_e_mngko.

  DATA : lt_stb TYPE TABLE OF stpox.
  DATA : lv_menge TYPE ekpo-menge.
  DATA : lv_meins TYPE meins.

  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      capid                 = 'PP01'
      datuv                 = sy-datum
*     EMENG                 = LV_EMENG
      mtnrv                 = pv_idnrk " 자재
      werks                 = p_werks " 플랜트
      mmory                 = '0'
    TABLES
      stb                   = lt_stb
    EXCEPTIONS
      alt_not_found         = 1
      call_invalid          = 2
      material_not_found    = 3
      missing_authorization = 4
      no_bom_found          = 5
      no_plant_data         = 6
      no_suitable_bom_found = 7
      conversion_error      = 8
      OTHERS                = 9.

  CLEAR pv_mngko.
  LOOP AT lt_stb INTO DATA(ls_stb).
    SELECT SINGLE a~matnr
     FROM mara AS a
     INNER JOIN t134  AS b ON b~mtart = a~mtart
     INNER JOIN makt AS c ON c~matnr = a~matnr
     WHERE a~matnr = @ls_stb-idnrk
        AND b~mtref   IN ( 'ROH', 'VERP' )  " 완제품 반제품만 공정대상
        AND c~maktx LIKE '%XLPE%'
        INTO @DATA(lv_matnr).

    IF sy-subrc EQ 0 AND lv_matnr IS NOT INITIAL.
      CLEAR lv_menge.
      CLEAR lv_meins.
      lv_menge = ls_stb-mngko.
      lv_meins = 'KG'.
      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          i_matnr              = ls_stb-idnrk    " <-- 해당 자재코드
          i_in_me              = ls_stb-meins  "<-- 현 수량의 단위
          i_out_me             = lv_meins " <-- 변경되어질 수량의 단위
          i_menge              = lv_menge " <-- 현 수량 변수
        IMPORTING
          e_menge              = lv_menge " <-- 변경되어질 수량변수
        EXCEPTIONS
          error_in_application = 1
          error                = 2
          OTHERS               = 3.

* 소숫점 반올림
      CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
        EXPORTING
          i_rtype     = ' '
          i_runit     = 1
          i_value     = lv_menge
        IMPORTING
          e_value_rnd = lv_menge.

      ADD lv_menge TO pv_mngko.

    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm_step
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM popup_to_confirm_step  USING lp_opt
                                  lp_text1
                                  lp_text2
                                  lp_title.
  CLEAR gv_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption  = lp_opt
      textline1      = lp_text1
      textline2      = lp_text2
      titel          = lp_title
      cancel_display = ''
    IMPORTING
      answer         = gv_answer.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_ALPHA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_CHK_2121>_ZVOLT
*&---------------------------------------------------------------------*
FORM conversion_alpha  CHANGING pv_value.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = pv_value
    IMPORTING
      output = pv_value.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form find_ins_matnh
*&---------------------------------------------------------------------*
* 2026.02.02.zlsgpp5.CHM2601-00657.절연 반제품 자재코드 미생성 항목에
*   대해서 완제품 자재코드 존재 시 반제품코드 자동탐색 및 설정 기능추가.
*&---------------------------------------------------------------------*
FORM find_ins_matnh  USING    iv_matnf
                     CHANGING ov_matnh.

*___완제품 자재코드가 존재시.
  CHECK iv_matnf IS NOT INITIAL.

*___BOM 전개.
  DATA: ls_cstmat TYPE cstmat,
        lt_stb    TYPE TABLE OF stpox.

  CLEAR: ls_cstmat, lt_stb.
  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      capid                 = 'PP01'
      datuv                 = sy-datum
      mehrs                 = 'X' "Multilevel Explosion
      mtnrv                 = iv_matnf
      stlan                 = '1'
      werks                 = p_werks
    IMPORTING
      topmat                = ls_cstmat
    TABLES
      stb                   = lt_stb[]
    EXCEPTIONS
      alt_not_found         = 1
      call_invalid          = 2
      material_not_found    = 3
      missing_authorization = 4
      no_bom_found          = 5
      no_plant_data         = 6
      no_suitable_bom_found = 7
      conversion_error      = 8
      OTHERS                = 9.
  IF sy-subrc <> 0.
    "Implement suitable error handling here
  ENDIF.

  "*___속성이 절연 건만 남김.
  SORT lt_stb.
  LOOP AT lt_stb ASSIGNING FIELD-SYMBOL(<lt_stb>).
    SELECT SINGLE objek INTO @DATA(lv_objek)
      FROM ausp
     WHERE objek = @<lt_stb>-idnrk
       AND atinn = @c_pd_ca_proc_gr
       AND klart = '001'
       AND atwrt = 'INS'.
    IF sy-subrc NE 0.
      CLEAR: <lt_stb>-idnrk.
    ENDIF.
  ENDLOOP.
  DELETE lt_stb WHERE idnrk EQ space.

  "___상위레벨이고 순서가 마지막인 절연 반제품 찾기.
  SORT lt_stb BY  stufe
                  wegxx DESCENDING.

  IF lt_stb[] IS NOT INITIAL.
    READ TABLE lt_stb ASSIGNING <lt_stb> INDEX 1.
    IF sy-subrc EQ 0.
      ov_matnh = <lt_stb>-idnrk.
    ENDIF.
  ENDIF.

ENDFORM.
