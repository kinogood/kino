************************************************************************
* Title         :  ZTER6910F01                                         *
*                                                                      *
* Description   : T/T 미정리 리스트 관리용 Sub Routine Include         *
*                                                                      *
* Creation Date : 2003/03/12                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p1001_initialization .

*> program id setting
  g_repid = sy-repid.

  SET TITLEBAR 'T1000'.

*> global mode setting
  CASE sy-tcode.
    WHEN   c_create_d.      g_mode = 'C'.   ">생성.
    WHEN   c_create.        g_mode = 'C'.   ">생성.
    WHEN   c_create_a.      g_mode = 'C'.   ">Amend.
    WHEN   c_change.        g_mode = 'M'.   ">변경.
    WHEN   c_display.       g_mode = 'S'.   ">조회.
    WHEN   c_delete.        g_mode = 'D'.   ">삭제.
    WHEN   c_acceptance.    g_mode = 'A'.   ">접수.
    WHEN   c_apply.         g_mode = 'Y'.   ">신청.
    WHEN   c_open.          g_mode = 'O'.   ">개설.
    WHEN   c_post.          g_mode = 'P'.   ">전기.
    WHEN   c_reverse.       g_mode = 'R'.   ">취소(전기).
*     WHEN   c_reverse1.      g_mode = 'E'.   ">역분개.
    WHEN   c_close.         g_mode = 'G'.   ">취소.
    WHEN   OTHERS.          g_mode = '0'.   ">구상.
  ENDCASE.

ENDFORM.                    " p1001_initialization
*&---------------------------------------------------------------------*
*&      Form  p1101_check_input_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p1101_check_input_value .

* Company code
  SELECT bukrs INTO (g_bukrs)
               FROM t001 UP TO 1 ROWS
               WHERE bukrs IN s_bukrs.
  ENDSELECT.
  IF sy-subrc <> 0.
    PERFORM get_ftext(rddfie00) USING 'T001' 'BUKRS' sy-langu
                                CHANGING dfies g_subrc.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE e348(m7) WITH dfies-scrtext_m.
  ENDIF.

ENDFORM.                    " p1101_check_input_value
*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p2000_data_selections .

  RANGES: lr_apvyn  FOR  ztitig04-apvyn  OCCURS 1.
*
*  DATA: BEGIN OF lt_ztstig3  OCCURS 10,
*        epart TYPE ztsepart,
*        namet TYPE ztsnamet,
*        END   OF lt_ztstig3.

*> PROGRESS Display.
  g_linen    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

  lr_apvyn-sign   =  'I'.
  lr_apvyn-option =  'EQ'.

  CASE 'X'.
    WHEN p_step1. "미승인내역
      lr_apvyn-low    =  'A'.  APPEND lr_apvyn.
    WHEN p_step2. "승인내역
      lr_apvyn-low    =  'B'.  APPEND lr_apvyn.
    WHEN p_step3. "전체
      REFRESH: lr_apvyn.
  ENDCASE.

*> 수취인 계좌내역.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE it_tab
    FROM ztitig04
   WHERE bukrs  IN  s_bukrs
     AND lifnr  IN  s_lifnr
     AND waers  IN  s_waers
     AND apvyn  IN  lr_apvyn.

  LOOP AT it_tab.
    g_tabix = sy-tabix.
    CASE it_tab-apvyn.
      WHEN 'A'.
        it_tab-icon = icon_red_light.
      WHEN 'B'.
        it_tab-icon = icon_green_light.
    ENDCASE.
    MODIFY it_tab INDEX g_tabix.
  ENDLOOP.

*> 데이타가 존재하지 않을 경우.
  DESCRIBE TABLE it_tab LINES g_line.
  IF g_line EQ 0.
    MESSAGE s902.   EXIT.
  ENDIF.

ENDFORM.                    " p2000_data_selections
*&---------------------------------------------------------------------*
*&      Form  create_and_init_controls_2000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_and_init_controls_2000 .

  IF g_custom_container IS INITIAL.
*   create a custom container control for our alv control
    CREATE OBJECT g_custom_container
        EXPORTING
            container_name = 'CUSTOMER_CONTAINER_2000'.

*   Create an Instance of ALV Control
    CREATE OBJECT g_grid
          EXPORTING i_parent      = g_custom_container.

    CALL METHOD g_grid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_g
        is_variant           = gs_variante
        it_toolbar_excluding = it_exclude
        is_print             = gs_print_g
        i_save               = 'A'   " 전체가능유형.
*                                       'U'   " 특정사용자전용.
*                                       'X'   " 광역 전용.
*                                       ' '   " 저장안함.
*                 i_default            = 'X'   " 레이아웃 사전셋팅 허용.
*  LAYOUT   Standard   BCALV_GRID_09  참조.
*  is_variant 레이아웃선택/변경/저장/관리 enable
      CHANGING
        it_sort             = it_sort_g
        it_filter           = it_filter_g
        it_fieldcatalog     = it_fieldcat_g[]
        it_outtab           = it_tab[].

    CALL METHOD cl_gui_control=>set_focus
      EXPORTING
        control = g_grid.

* set editable cells to ready for input
    CALL METHOD g_grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.

*?.Optionally register ENTER to raise event DATA_CHANGED.
*   (Per default the user may check data by using the check icon).
    CALL METHOD g_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.

    CREATE OBJECT event_receiver.

    SET HANDLER :
          event_receiver->handle_toolbar               FOR g_grid,
          event_receiver->handle_data_changed          FOR g_grid,
          event_receiver->handle_data_changed_finished FOR g_grid,
          event_receiver->handle_double_click          FOR g_grid,
          event_receiver->handle_hotspot_click         FOR g_grid,
          event_receiver->handle_user_command          FOR g_grid.

*>.Call method 'set_toolbar_interactive' to raise event TOOLBAR.
    CALL METHOD g_grid->set_toolbar_interactive.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*// TITLE 지정
    PERFORM p3800_set_title_text.
** JS전선 회사코드 2007/04 KSH --------------------------------------
  ENDIF.

ENDFORM.                    " create_and_init_controls_2000
*&---------------------------------------------------------------------*
*&      Form  handle_toolbar
*&---------------------------------------------------------------------*
FORM handle_toolbar USING r_object TYPE REF TO cl_alv_event_toolbar_set
                          r_interactive.
*0    Button (normal)
*1    Menu and default button
*2    Menu
*3    Separator
*4    Radio button
*5    Checkbox
*6    Menu entry

  DATA: ls_toolbar  TYPE stb_button.

*  IF p_step1 EQ 'X'.
* append a separator to normal toolbar
  CLEAR  ls_toolbar.
  MOVE 3                    TO ls_toolbar-butn_type.
  APPEND ls_toolbar         TO r_object->mt_toolbar.
*
  IF p_step1 EQ 'X'.
    CLEAR ls_toolbar.
    MOVE 0                    TO ls_toolbar-butn_type.
    MOVE 'ZTITINS'            TO ls_toolbar-function.
    MOVE icon_create          TO ls_toolbar-icon.
    MOVE '신규 등록...'       TO ls_toolbar-quickinfo.
    MOVE ' '                  TO ls_toolbar-text.
    MOVE space                TO ls_toolbar-disabled.
    APPEND ls_toolbar         TO r_object->mt_toolbar.
  ENDIF.

  IF p_step1 EQ 'X' OR
     p_step2 EQ 'X'.
    CLEAR  ls_toolbar.
    MOVE 0                    TO ls_toolbar-butn_type.
    MOVE 'ZTITUPDATE'         TO ls_toolbar-function.
    MOVE icon_change          TO ls_toolbar-icon.
    MOVE '변경...'            TO ls_toolbar-quickinfo.
    MOVE ' '                  TO ls_toolbar-text.
    MOVE space                TO ls_toolbar-disabled.
    APPEND ls_toolbar         TO r_object->mt_toolbar.

  ENDIF.

  CLEAR  ls_toolbar.
  MOVE 0                    TO ls_toolbar-butn_type.
  MOVE 'ZTITDISPLAY'        TO ls_toolbar-function.
  MOVE icon_display         TO ls_toolbar-icon.
  MOVE '조회...'            TO ls_toolbar-quickinfo.
  MOVE ' '                  TO ls_toolbar-text.
  MOVE space                TO ls_toolbar-disabled.
  APPEND ls_toolbar         TO r_object->mt_toolbar.

  CLEAR  ls_toolbar.
  MOVE 0                    TO ls_toolbar-butn_type.
  MOVE 'ZTITDEL'            TO ls_toolbar-function.
  MOVE icon_delete          TO ls_toolbar-icon.
  MOVE '삭제...'            TO ls_toolbar-quickinfo.
  MOVE ' '                  TO ls_toolbar-text.
  MOVE space                TO ls_toolbar-disabled.
  APPEND ls_toolbar         TO r_object->mt_toolbar.

  IF p_step1 EQ 'X' AND
     sy-tcode EQ 'ZTIT010'.
* append an icon to 게시.
    CLEAR ls_toolbar.
    MOVE 0                    TO ls_toolbar-butn_type.
    MOVE 'ZTITSEND'           TO ls_toolbar-function.
    MOVE icon_financing       TO ls_toolbar-icon.
    MOVE ' 승인'              TO ls_toolbar-quickinfo.
    MOVE ' 승인'              TO ls_toolbar-text.
    MOVE space                TO ls_toolbar-disabled.
    APPEND ls_toolbar         TO r_object->mt_toolbar.
  ENDIF.

  IF p_step2 EQ 'X' AND
     sy-tcode EQ 'ZTIT010'.
    CLEAR ls_toolbar.
    MOVE 0                    TO ls_toolbar-butn_type.
    MOVE 'ZTITUNDO'           TO ls_toolbar-function.
    MOVE icon_system_undo     TO ls_toolbar-icon.
    MOVE ' 승인 취소'         TO ls_toolbar-quickinfo.
    MOVE ' 승인 취소'         TO ls_toolbar-text.
    MOVE space                TO ls_toolbar-disabled.
    APPEND ls_toolbar         TO r_object->mt_toolbar.
  ENDIF.

*  CLEAR ls_toolbar.
*  MOVE 0                    TO ls_toolbar-butn_type.
*  MOVE 'ZTETCDOC'           TO ls_toolbar-function.
*  MOVE icon_copy_object     TO ls_toolbar-icon.
*  MOVE '변경이력...'        TO ls_toolbar-quickinfo.
*  MOVE ' 변경이력'          TO ls_toolbar-text.
*  MOVE space                TO ls_toolbar-disabled.
*  APPEND ls_toolbar         TO r_object->mt_toolbar.

ENDFORM.                    " handle_toolbar

*&--------------------------------------------------------------------*
*&      Form  handle_data_changed
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->ER_DATA_CHAtext
*---------------------------------------------------------------------*
FORM  handle_data_changed  USING er_data_changed
                           TYPE REF TO cl_alv_changed_data_protocol.
  DATA : ls_mod_cells TYPE lvc_s_modi,
         ls_cells     TYPE lvc_s_modi.

  LOOP AT er_data_changed->mt_good_cells INTO ls_mod_cells.
    CASE ls_mod_cells-fieldname.
      WHEN 'WRBTR' OR 'HWAER'.     ">금액.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    "handle_data_changed
*&---------------------------------------------------------------------*
*&      Form  handle_data_changed_finished
*&---------------------------------------------------------------------*
FORM  handle_data_changed_finished   USING p_modified.
*                                           p_sender.

  DATA lt_rows     TYPE lvc_t_row.
  DATA l_row_id    TYPE lvc_s_row.
  DATA l_col_id    TYPE lvc_s_col.
  DATA ls_stable   TYPE lvc_s_stbl.
  DATA l_control   TYPE REF TO cl_gui_control.
  DATA l_row_no    TYPE lvc_s_roid.
  DATA lt_roid     TYPE lvc_t_roid.
  DATA l_row       TYPE i.
  DATA l_col       TYPE i.
  DATA l_end_pos   TYPE i.
  DATA l_start_pos TYPE i.

  CHECK NOT p_modified IS INITIAL.

* keep in mind selected rows
  REFRESH lt_rows.
  CALL METHOD g_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_rows.

  IF lt_rows[] IS INITIAL.
    CALL METHOD g_grid->get_focus
      IMPORTING
        control           = l_control
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3.
* Flush now to avoid a system_pointer_pending dump.
    CALL METHOD cl_gui_cfw=>flush.
    IF sy-subrc = 0 AND
       l_control = g_grid.
      CALL METHOD g_grid->get_current_cell
        IMPORTING
          es_row_no = l_row_no
          es_row_id = l_row_id
          es_col_id = l_col_id
          e_row     = l_row
          e_col     = l_col.

* Flush now to avoid a system_pointer_pending dump.
      CALL METHOD cl_gui_cfw=>flush.
    ENDIF.
  ENDIF.

  CALL METHOD g_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

  IF lt_rows[] IS INITIAL.
    CALL METHOD g_grid->set_focus
      EXPORTING
        control = l_control.
* Flush now to avoid a system_pointer_pending dump.
    CALL METHOD cl_gui_cfw=>flush.

    IF sy-subrc  = 0       AND
       l_control = g_grid.

      l_start_pos = 1.
      l_end_pos   = 1.

      APPEND l_row_no TO lt_roid.

      CALL METHOD g_grid->set_selected_rows
        EXPORTING
*          IT_INDEX_ROWS            =
          it_row_no                = lt_roid
*          IS_KEEP_OTHER_SELECTIONS =
          .

* Flush now to avoid a system_pointer_pending dump.
      CALL METHOD cl_gui_cfw=>flush.
    ENDIF.
  ELSE.
* reset selected rows
    CALL METHOD g_grid->set_selected_rows
      EXPORTING
        it_index_rows = lt_rows.
  ENDIF.
*   flush
  CALL METHOD cl_gui_cfw=>flush.

ENDFORM.                    "handle_data_changed_finished

*&---------------------------------------------------------------------*
*&      Form  handle_double_click
*&---------------------------------------------------------------------*
FORM handle_double_click  USING  p_row p_column.

  DATA: l_datatype    LIKE dd01v-datatype.

  CALL FUNCTION 'Z_TI_NUMBER_CHECK'
    EXPORTING
      string_in  = p_row
    IMPORTING
      string_out = p_row
      htype      = l_datatype.

  CHECK l_datatype EQ 'NUMC'.

*  READ TABLE it_list INTO gs_list INDEX p_row.
*  IF sy-subrc EQ 0.
*
*    CASE p_column.
*      WHEN 'ICSNO' OR 'ICSSQ'.
*        PERFORM display_cs_document(ztir0000)
*                                           USING gs_list-icsno
*                                                 gs_list-bukrs.
*      WHEN 'BELNR'.
*        PERFORM display_liv_document(ztir9000)
*                                             USING gs_list-belnr
*                                                   gs_list-gjahr
*                                                   gs_list-bukrs.
*      WHEN OTHERS.
*        PERFORM display_import_document(ztir0000)
*                                           USING gs_list-reqno
*                                                 gs_list-amdsq
*                                                 '00000'.
*    ENDCASE.
*  ELSE.
*    MESSAGE s903.
*  ENDIF.

ENDFORM.                    "handle_double_click
*&---------------------------------------------------------------------*
*&      Form  handle_hotspot_click
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING e_row_id    TYPE lvc_s_row
                                 e_column_id TYPE lvc_s_col.

*  READ TABLE it_list INTO gs_list INDEX e_row_id-index.
*  IF sy-subrc NE 0.
*    MESSAGE s903.   EXIT.
*  ENDIF.
*
*  CASE e_column_id-fieldname.
*    WHEN 'REQNO' OR 'OPNNO'.
*      PERFORM  display_import_document(ztir0000)
*                                      USING gs_list-reqno
*                                            gs_list-amdsq
*                                            space.
*    WHEN 'PSPNR'.
*      PERFORM  display_project_master(ztir0000)
*                                      USING gs_list-pspnr.
*    WHEN OTHERS.
*  ENDCASE.
*
ENDFORM.                    "_hotspot_click
*&---------------------------------------------------------------------*
*&      Form  handle_user_command_grid
*&---------------------------------------------------------------------*
FORM handle_user_command_grid USING r_ucomm.

  DATA: l_valid      TYPE c,
        lt_row_no    TYPE lvc_t_roid WITH HEADER LINE.
  DATA: l_subrc      LIKE sy-subrc,
        l_text_amout(20),
        l_answer     TYPE c.
  DATA: l_objektid   LIKE cdhdr-objectid.

  CLEAR g_count.

  IF r_ucomm EQ 'ZTITDISPLAY' OR
     r_ucomm EQ 'ZTITCOPY'    OR
     r_ucomm EQ 'ZTITDEL'     OR
     r_ucomm EQ 'ZTITSEND'    OR
     r_ucomm EQ 'ZTITUNDO'    OR
     r_ucomm EQ 'ZTITUPDATE'  OR
     r_ucomm EQ 'ZTITCDOC'.
    PERFORM  get_selected_row  TABLES lt_row_no.
  ELSE.
    g_count = 1.
  ENDIF.
*
  CHECK g_count GT 0.
*
  CASE r_ucomm.
*>---------------------------------------------------------------------
*> UPLOAD.
*>---------------------------------------------------------------------
*    WHEN 'ZTITUPLOAD'.
**> EXCEL UPLOAD FILE
*      PERFORM  get_file_upload.
**> 검색조건에 해당하는 데이타를 Select.
*      PERFORM  p2000_data_selections.
**> Fields 속성 정의.
*      PERFORM  p3800_field_attribute_change.
**> Refresh ALV Grid controls.
*      PERFORM  p9000_refresh_display.

*>---------------------------------------------------------------------
*> 변경.
*>---------------------------------------------------------------------
    WHEN 'ZTITUPDATE' OR 'ZTITDISPLAY'.
      IF g_count GT 1.
        MESSAGE s909.  EXIT.
      ENDIF.
      READ TABLE lt_row_no INDEX 1.
      IF sy-subrc EQ 0.
        READ TABLE it_tab INDEX lt_row_no-row_id.
        g_tabix = sy-tabix.
        IF sy-subrc NE 0.
          MESSAGE e909.
          EXIT.
        ENDIF.
        MOVE-CORRESPONDING: it_tab TO ztitig04,
                            it_tab TO ztisig04.
        SELECT SINGLE name1
          INTO g_lifnrnm
          FROM lfa1
         WHERE lifnr EQ ztisig04-lifnr .

        SELECT SINGLE landx50
          INTO g_landx
          FROM t005t
         WHERE land1 EQ ztisig04-tbbao
           AND spras EQ 'E'.

        select single landx50
          into g_landy
          from t005t
         where land1 eq ztisig04-tibao
           and spras eq 'E'.

      ENDIF.

*> 추가 생성용.
      IF r_ucomm EQ 'ZTITUPDATE'.
        g_mode = 'M'.
      ELSE.
        g_mode = 'S'.
      ENDIF.
      PERFORM  create_sub_routine.
*

*>---------------------------------------------------------------------
*> 신규입력.
*>---------------------------------------------------------------------
    WHEN 'ZTITINS'.
*> Setting Default Value
      PERFORM  set_create_defalut_value.
*> 추가 생성용.
      PERFORM  create_sub_routine.

*>---------------------------------------------------------------------
*> 복사.
*>---------------------------------------------------------------------
*    WHEN 'ZTITCOPY'.
*      IF g_count GT 1.
*        MESSAGE s927.  EXIT.
*      ENDIF.
*      LOOP AT lt_row_no.
*        IF lt_row_no-row_id GT 0.
*
*          READ TABLE it_tab INDEX lt_row_no-row_id.
*          IF sy-subrc NE 0.
*            MESSAGE e909.
*            EXIT.
*          ENDIF.
*          g_tabix = sy-tabix.
**> Setting Default Value(Copy용)
*          PERFORM  set_copy_defalut_value.
**> 추가 생성용.
*          PERFORM  create_sub_routine.
*        ENDIF.
*      ENDLOOP.
*>---------------------------------------------------------------------
*> 승인.
*>---------------------------------------------------------------------
    WHEN 'ZTITSEND'.
      PERFORM  business_by_process      TABLES lt_row_no
                                        USING  'B'.

*>---------------------------------------------------------------------
*> 승인취소.
*>---------------------------------------------------------------------
    WHEN 'ZTITUNDO'.
      PERFORM  business_by_process      TABLES lt_row_no
                                        USING  'A'.

*>---------------------------------------------------------------------
*> 변경이력.
*>---------------------------------------------------------------------
    WHEN 'ZTITCDOC'.
      IF g_count GT 1.
        MESSAGE s909.  EXIT.
      ENDIF.
      LOOP AT lt_row_no.
        IF lt_row_no-row_id GT 0.

          READ TABLE it_tab INDEX lt_row_no-row_id.
          IF sy-subrc NE 0.
            MESSAGE e909.
            EXIT.
          ENDIF.
          MOVE-CORRESPONDING it_tab TO ztitig04.
          l_objektid = ztitig04(22).
          PERFORM display_change_document USING 'ZTEUSCHDOC'
                                                l_objektid.
        ENDIF.
      ENDLOOP.

*>---------------------------------------------------------------------
*> 삭제.
*>---------------------------------------------------------------------
    WHEN 'ZTITDEL'.
      PERFORM  business_by_process      TABLES lt_row_no
                                        USING  'D'.
  ENDCASE.

ENDFORM.                    "handle_user_command_grid
*&---------------------------------------------------------------------*
*&      Form  p3000_field_category_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p3000_field_category_build .

  DATA ls_fcat TYPE lvc_s_fcat.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZTISIG04'
      i_client_never_display = 'X'
    CHANGING
      ct_fieldcat            = it_fieldcat_g[].

  LOOP AT it_fieldcat_g INTO gs_fieldcat_g.
    CLEAR: gs_fieldcat_g-key.

    CASE gs_fieldcat_g-fieldname.
      WHEN 'ICON'.
        gs_fieldcat_g-key       = 'X'.
        gs_fieldcat_g-coltext   = '상태'.
        gs_fieldcat_g-scrtext_l = gs_fieldcat_g-coltext.
        gs_fieldcat_g-scrtext_m = gs_fieldcat_g-coltext.
        gs_fieldcat_g-scrtext_s = gs_fieldcat_g-coltext.
        gs_fieldcat_g-outputlen = 4.
        gs_fieldcat_g-icon      = 'X'.
        gs_fieldcat_g-col_pos   = 1.
      WHEN 'WAERS'.
        gs_fieldcat_g-col_pos   = 6.
      WHEN 'APVYN' OR 'FLAG' OR 'TBBCD'.
        gs_fieldcat_g-no_out    = 'X'.
      WHEN 'LIFNR'.
        gs_fieldcat_g-outputlen = 10.
*        gs_fieldcat_g-no_out = 'X'.
        gs_fieldcat_g-col_pos   = 9.
      WHEN 'CNAM'.
        gs_fieldcat_g-col_pos   = 15.
      WHEN 'CDAT'.
        gs_fieldcat_g-col_pos   = 16.
      WHEN 'CTME'.
        gs_fieldcat_g-col_pos   = 17.
      WHEN 'UNAM'.
        gs_fieldcat_g-col_pos   = 18.
      WHEN 'UDAT'.
        gs_fieldcat_g-col_pos   = 19.
      WHEN 'UTME'.
        gs_fieldcat_g-col_pos   = 20.
      WHEN 'UNAME'.
        gs_fieldcat_g-coltext   = '자금팀장승인'.
      WHEN OTHERS.
        gs_fieldcat_g-outputlen = 10.
*        gs_fieldcat_g-no_out = 'X'.
    ENDCASE.
    MODIFY it_fieldcat_g FROM gs_fieldcat_g.
  ENDLOOP.

ENDFORM.                    " p3000_field_category_build

*&---------------------------------------------------------------------*
*&      Form  P3210_exclude_table_build
*&---------------------------------------------------------------------*
FORM p3210_exclude_table_build USING p_tabname.

*  툴바의 버튼중 나타내지 않을 버튼을 지정한다.
  FIELD-SYMBOLS : <table> TYPE ui_functions.

  DATA : ls_exclude   TYPE ui_func.
  DATA : l_table_name LIKE feld-name.

  CONCATENATE p_tabname '[]' INTO  l_table_name.
  ASSIGN     (l_table_name)    TO <table>.

  PERFORM append_exclude_functions
        TABLES <table>
*        USING : cl_gui_alv_grid=>mc_fc_excl_all. " ** 툴바 모두제거 **
         USING : cl_gui_alv_grid=>mc_fc_loc_undo, " 실행취소
*                cl_gui_alv_grid=>mc_fc_auf,      " 소계확장 &AUF
*                cl_gui_alv_grid=>mc_fc_average,  " &AVERAGE
*                cl_gui_alv_grid=>mc_fc_back_classic,
*                cl_gui_alv_grid=>mc_fc_call_abc, " &ABC
*                cl_gui_alv_grid=>mc_fc_call_chain,
*                cl_gui_alv_grid=>mc_fc_call_crbatch,
*                cl_gui_alv_grid=>mc_fc_call_crweb,
*                cl_gui_alv_grid=>mc_fc_call_lineitems,
*                cl_gui_alv_grid=>mc_fc_call_master_data,
*                cl_gui_alv_grid=>mc_fc_call_more,
*                cl_gui_alv_grid=>mc_fc_call_report,
*                cl_gui_alv_grid=>mc_fc_call_xint,
*                cl_gui_alv_grid=>mc_fc_call_xxl,
*                cl_gui_alv_grid=>mc_fc_col_invisible,
*                cl_gui_alv_grid=>mc_fc_col_optimize,
*                cl_gui_alv_grid=>mc_fc_current_variant,
*                cl_gui_alv_grid=>mc_fc_data_save,
*                cl_gui_alv_grid=>mc_fc_delete_filter,
*                cl_gui_alv_grid=>mc_fc_deselect_all,
*                cl_gui_alv_grid=>mc_fc_detail,
*                cl_gui_alv_grid=>mc_fc_expcrdata,
*                cl_gui_alv_grid=>mc_fc_expcrdesig,
*                cl_gui_alv_grid=>mc_fc_expcrtempl,
*                cl_gui_alv_grid=>mc_fc_expmdb,
*                cl_gui_alv_grid=>mc_fc_extend,
*                cl_gui_alv_grid=>mc_fc_f4,
*                cl_gui_alv_grid=>mc_fc_filter,
*                cl_gui_alv_grid=>mc_fc_find,
*                cl_gui_alv_grid=>mc_fc_fix_columns,
*                cl_gui_alv_grid=>mc_fc_graph,
*                cl_gui_alv_grid=>mc_fc_help,
*                cl_gui_alv_grid=>mc_fc_info,
*                cl_gui_alv_grid=>mc_fc_load_variant,
                cl_gui_alv_grid=>mc_fc_loc_copy,          " 행 카피.
                cl_gui_alv_grid=>mc_fc_html,
                cl_gui_alv_grid=>mc_fc_loc_copy_row,      " 행 카피.
                cl_gui_alv_grid=>mc_fc_loc_cut,           " 가위.
                cl_gui_alv_grid=>mc_fc_loc_delete_row,    " 행삭제.
                cl_gui_alv_grid=>mc_fc_loc_insert_row,    " 행삽입.
                cl_gui_alv_grid=>mc_fc_loc_move_row,
                cl_gui_alv_grid=>mc_fc_loc_append_row,    " 라인생성.
                cl_gui_alv_grid=>mc_fc_loc_paste,         " 겹쳐쓰기.
                cl_gui_alv_grid=>mc_fc_loc_paste_new_row, " 겹쳐쓰기.
*                cl_gui_alv_grid=>mc_fc_maintain_variant,
*                cl_gui_alv_grid=>mc_fc_maximum,
*                cl_gui_alv_grid=>mc_fc_minimum,
*                cl_gui_alv_grid=>mc_fc_pc_file,
*                cl_gui_alv_grid=>mc_fc_print,
*                cl_gui_alv_grid=>mc_fc_print_back,
*                cl_gui_alv_grid=>mc_fc_print_prev,
                cl_gui_alv_grid=>mc_fc_help,
                cl_gui_alv_grid=>mc_fc_graph,
                cl_gui_alv_grid=>mc_fc_info,
                cl_gui_alv_grid=>mc_fc_refresh.
*                cl_gui_alv_grid=>mc_fc_reprep,
*                cl_gui_alv_grid=>mc_fc_save_variant,
*                cl_gui_alv_grid=>mc_fc_select_all,
*                cl_gui_alv_grid=>mc_fc_send,
*                cl_gui_alv_grid=>mc_fc_separator,
*                cl_gui_alv_grid=>mc_fc_sort,
*                cl_gui_alv_grid=>mc_fc_sort_asc,
*                cl_gui_alv_grid=>mc_fc_sort_dsc,
*                cl_gui_alv_grid=>mc_fc_subtot,
*                cl_gui_alv_grid=>mc_fc_sum,
*                cl_gui_alv_grid=>mc_fc_to_office,
*                cl_gui_alv_grid=>mc_fc_to_rep_tree,
*                cl_gui_alv_grid=>mc_fc_unfix_columns,
*                cl_gui_alv_grid=>mc_fc_views,
*                cl_gui_alv_grid=>mc_fc_view_crystal,
*                cl_gui_alv_grid=>mc_fc_view_excel,
*                cl_gui_alv_grid=>mc_fc_view_grid,
*                cl_gui_alv_grid=>mc_fc_word_processor.

ENDFORM.                    " P3210_exclude_table_build
*&---------------------------------------------------------------------*
*&      Form  P3500_sort_table_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p3500_sort_table_build .

*  CLEAR gs_sort_g.
*  gs_sort_g-spos      = '02'.
*  gs_sort_g-fieldname = 'EXPCD'.
*  gs_sort_g-up        = 'X'.
*  gs_sort_g-subtot    = 'X'.
**  gs_sort_g-LEVEL     =  1.
**  gs_sort_g-GROUP     = 'X'.
*  APPEND gs_sort_g TO it_sort_g.
*
ENDFORM.                    " P3500_sort_table_build
*&---------------------------------------------------------------------*
*&      Form  append_exclude_functions
*&---------------------------------------------------------------------*
FORM append_exclude_functions  TABLES p_table
                               USING  p_value.

  DATA : ls_exclude TYPE ui_func.
  ls_exclude = p_value.
  APPEND ls_exclude TO p_table.

ENDFORM.                    " append_exclude_functions
*&---------------------------------------------------------------------*
*&      Form  p3700_layout_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p3700_layout_build .

** General display options
*  gs_layout_g-cwidth_opt = 'X'.
  gs_layout_g-smalltitle = 'X'.
  gs_layout_g-box_fname  = 'FLAG'.
* ICON.
*      gs_layout_g-excp_fname = g_lights_name.

** Grid customizing
* Title between grid control and toolbar(70자 이내)
* GS_LAYOUT_G-grid_title = '프로그램 LIST'.

** Column headers are hidden
* GS_LAYOUT_G-no_headers = 'X'.

** Columns are displayed without horizontal grid lines
* GS_LAYOUT_G-no_hgridln = 'X'.
*
** Cells are not merged when a column is sorted
* GS_LAYOUT_G-no_merging = ' '.

* the button at the beginning of a row is hidden in selection modes
* cell selection ( SEL_MODE = 'D' ) and column/row selection
* ( SEL_MODE = 'A' ).
*  gs_layout_g-no_rowmark = 'A'. "(or 'X')

* Selection modes for SEL_MODE
* 'A' : Column and row selection
* 'B' : Simple selection, list box
* 'C' : Multiple selection, list box
* 'D' : Cell selection
  gs_layout_g-sel_mode = 'C'.
* If this field is set, the toolbar is hidden.
* GS_LAYOUT_G-no_toolbar = 'X'.

* columns are displayed without vertical grid lines
* GS_LAYOUT_G-no_vgridln = 'X'.

* In case of PRINT_END_OF_PAGE, you must set 'reservelns' to
* the number of reserved lines at the end of a page.
* reserve two lines for the PRINT_END_OF_PAGE event
* p_print-reservelns = 2.

* Standard(BCALV_EDIT_01)에서는 다음과 같이 했다.
* Set status of all cells to editable using the layout structure.
* 옵션에 안보이던데... 어째껀 수정모드로 바꾸는 중요한 옵션이다.
*  IF g_mode = c_display.
*    GS_LAYOUT_G-edit = ' '.
*  ELSEIF g_mode = c_edit.
*    GS_LAYOUT_G-edit = 'X'.
*  ENDIF.

* Provide the fieldname of the celltab field by using field
* STYLEFNAME of the layout structure.

  gs_layout_g-stylefname = 'CELLTAB'.

* 합을 제일 윗라인에 DISPLAY
*  gs_layout_g-totals_bef = 'X'.

ENDFORM.                    " p3700_layout_build
*&---------------------------------------------------------------------*
*&      Form  p3800_field_attribute_change
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p3800_field_attribute_change .

* 각 셀의 특성 제어
  DATA : lt_celltab TYPE lvc_t_styl,
         l_index    TYPE i,
         p_mode(01).

  LOOP AT it_tab.
    l_index = sy-tabix.
**> 게시가능.
*    IF p_step1 EQ 'X'.
*      p_mode = 'W'.
*    ELSE.
*      p_mode = 'O'.
*    ENDIF.
    p_mode = 'O'.

    REFRESH lt_celltab.

    PERFORM p3810_fill_celltab USING    p_mode
                               CHANGING lt_celltab.

    CLEAR it_tab-celltab.
    INSERT LINES OF lt_celltab  INTO TABLE it_tab-celltab.
    MODIFY it_tab INDEX l_index.
  ENDLOOP.

ENDFORM.                    " p3800_field_attribute_change
*&---------------------------------------------------------------------*
*&      Form  P3810_fill_celltab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p3810_fill_celltab  USING    p_mode
                        CHANGING pt_celltab TYPE lvc_t_styl.

  DATA : ls_celltab TYPE lvc_s_styl,
         l_mode     TYPE raw4.

  DATA : BEGIN OF l_fieldcat,
           row_pos(04),
           col_pos(04),
           fieldname(30),
         END OF l_fieldcat.

  LOOP AT it_fieldcat_g INTO gs_fieldcat_g.
    ls_celltab-fieldname = gs_fieldcat_g-fieldname.

    IF gs_fieldcat_g-fieldname = 'WAERS' OR
       gs_fieldcat_g-fieldname = 'LIFNR' OR
       gs_fieldcat_g-fieldname = 'TBBCD' OR
       gs_fieldcat_g-fieldname = 'TBBNM' OR
       gs_fieldcat_g-fieldname = 'TBBBR' OR
       gs_fieldcat_g-fieldname = 'TBBAN' OR
       gs_fieldcat_g-fieldname = 'TBBAD2' OR
       gs_fieldcat_g-fieldname = 'TBBAD3'.

      IF p_mode EQ 'W'.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
        INSERT ls_celltab INTO TABLE pt_celltab.
      ELSE.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
        INSERT ls_celltab INTO TABLE pt_celltab.
      ENDIF.
    ELSE.
      ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
      INSERT ls_celltab INTO TABLE pt_celltab.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " P3810_fill_celltab
*&---------------------------------------------------------------------*
*&      Form  p9000_refresh_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p9000_refresh_display .

*  CALL METHOD g_grid->get_frontend_layout
*    IMPORTING
*      es_layout = gs_layout_g.
*
*  CALL METHOD cl_gui_cfw=>flush.
*
*  CALL METHOD g_grid->set_frontend_layout
*    EXPORTING
*      is_layout = gs_layout_g.
*
*  CALL METHOD g_grid->set_frontend_fieldcatalog
*    EXPORTING
*      it_fieldcatalog = it_fieldcat_g.

*  gs_stable-row = 'X'.
*  gs_stable-col = 'X'.
*
  CALL METHOD g_grid->refresh_table_display.
*    EXPORTING
*      is_stable = gs_stable.
*
*  CALL METHOD cl_gui_cfw=>flush.

ENDFORM.                    " p9000_refresh_display
*&---------------------------------------------------------------------*
*&      Form  set_create_defalut_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_create_defalut_value .

  g_mode = 'C'.
  CLEAR: ztisig04.
  MOVE: sy-uname TO ztisig04-cnam,
        sy-datlo TO ztisig04-cdat,
        sy-timlo TO ztisig04-ctme.
  MOVE: sy-uname TO ztisig04-unam,
        sy-datlo TO ztisig04-udat,
        sy-timlo TO ztisig04-utme.
  MOVE: 'A'      TO ztisig04-apvyn,
        g_bukrs  TO ztisig04-bukrs.

  IF NOT ztisig04-bukrs IS INITIAL.
    SELECT SINGLE *
      FROM t001
     WHERE bukrs EQ ztisig04-bukrs.
  ENDIF.

ENDFORM.                    " set_create_defalut_value
*&---------------------------------------------------------------------*
*&      Form  save_database_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM save_database_table .

  DATA : l_docno           TYPE  ztedocno.
  DATA : l_objectid        LIKE cdhdr-objectid.

  DATA : BEGIN OF lt_cdtxt OCCURS 0.
          INCLUDE STRUCTURE cdtxt.
  DATA:  END   OF lt_cdtxt.


  CASE g_mode.
    WHEN 'C'.

      CLEAR: it_tab.
      MOVE: sy-uname TO ztisig04-cnam,
            sy-datlo TO ztisig04-cdat,
            sy-timlo TO ztisig04-ctme.
      MOVE: sy-uname TO ztisig04-unam,
            sy-datlo TO ztisig04-udat,
            sy-timlo TO ztisig04-utme.
      MOVE-CORRESPONDING ztisig04 TO it_tab.
      MOVE: sy-mandt             TO it_tab-mandt.
      CASE it_tab-apvyn.
        WHEN 'A'.
          it_tab-icon = icon_red_light.
        WHEN 'B'.
          it_tab-icon = icon_green_light.
      ENDCASE.
      APPEND it_tab.

      MOVE-CORRESPONDING it_tab  TO ztisig04.
      INSERT ztitig04 FROM ztisig04.

    WHEN 'M'.
      READ TABLE it_tab  WITH KEY bukrs = ztisig04-bukrs
                                  lifnr = ztisig04-lifnr
                                  waers = ztisig04-waers.

      IF sy-subrc EQ 0.
        g_tabix = sy-tabix.
        MOVE-CORRESPONDING ztisig04 TO it_tab.
        CASE it_tab-apvyn.
          WHEN 'A'.
            it_tab-icon = icon_red_light.
          WHEN 'B'.
            it_tab-icon = icon_green_light.
        ENDCASE.
        MODIFY it_tab INDEX g_tabix.

        MOVE-CORRESPONDING it_tab  TO ztitig04.
        MOVE: sy-uname TO ztitig04-unam,
              sy-datlo TO ztitig04-udat,
              sy-timlo TO ztitig04-utme.
        MODIFY ztitig04 FROM ztitig04.

*        l_objectid = ztetusk(13).
*
*        call function 'ZTEUSCHDOC_WRITE_DOCUMENT'
*          exporting
*            objectid                      = l_objectid
*            tcode                         = sy-tcode
*            utime                         = sy-timlo
*            udate                         = sy-datlo
*            username                      = sy-uname
**             PLANNED_CHANGE_NUMBER         = ' '
*            object_change_indicator       = 'U'
**             PLANNED_OR_REAL_CHANGES       = ' '
**             NO_CHANGE_POINTERS            = ' '
*            upd_icdtxt_zteuschdoc         = 'U'
*            n_ztetusk                     = ztetusk
*            o_ztetusk                     = *ztetusk
*            upd_ztetusk                   = 'U'
*          tables
*            icdtxt_zteuschdoc             = lt_cdtxt.


        CALL FUNCTION 'DEQUEUE_EZ_ZTITIG04'
          EXPORTING
            mode_ztitig04 = 'X'
            mandt         = sy-mandt
            bukrs         = ztitig04-bukrs
            lifnr         = ztitig04-lifnr
            waers         = ztitig04-waers
            x_bukrs       = ' '
            x_lifnr       = ' '
            x_waers       = ' '
            _scope        = '3'
            _synchron     = ' '
            _collect      = ' '.

      ENDIF.

  ENDCASE.

ENDFORM.                    " save_database_table
*&---------------------------------------------------------------------*
*&      Form  get_selected_row
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_selected_row  TABLES   pt_row_no TYPE lvc_t_roid.

  DATA: l_valid TYPE c.

  CALL METHOD g_grid->check_changed_data
    IMPORTING
      e_valid = l_valid.

  IF l_valid EQ 'X'.
    CALL METHOD g_grid->get_selected_rows
      IMPORTING
        et_row_no = pt_row_no[].

    IF pt_row_no[] IS INITIAL.
      MESSAGE s909.
      EXIT.
    ENDIF.

    CLEAR gs_list-flag.
    MODIFY it_tab TRANSPORTING flag WHERE flag = 'X'.

    LOOP AT pt_row_no.
      IF pt_row_no-row_id GT 0.
        READ TABLE it_tab INDEX pt_row_no-row_id.
        IF sy-subrc EQ 0.
          ADD 1 TO g_count.
          IF it_tab-flag NE 'X'.
            it_tab-flag = 'X'.
          ENDIF.
          MODIFY it_tab INDEX pt_row_no-row_id.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF g_count EQ 0.
    MESSAGE s909.
  ENDIF.

ENDFORM.                    " get_selected_row
*&---------------------------------------------------------------------*
*&      Form  set_copy_defalut_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_copy_defalut_value .

  g_mode = 'C'.
*  CLEAR: ztesusk,
*         t001,
*         ztstig3.
*
*  MOVE-CORRESPONDING it_tab TO ztesusk.
*
*  MOVE: sy-uname TO ztesusk-cnam,
*        sy-datlo TO ztesusk-cdat,
*        sy-timlo TO ztesusk-ctme.
*  MOVE: sy-uname TO ztesusk-unam,
*        sy-datlo TO ztesusk-udat,
*        sy-timlo TO ztesusk-utme.
*  MOVE: 'A'      TO ztesusk-setpg,
*        'M'      TO ztesusk-inpmd,
*        sy-datlo TO ztesusk-melda.
*
*  CLEAR: ztesusk-iusno, ztesusk-acidt, ztesusk-sofbt,
*         ztesusk-kunnr,
**         ztesusk-vkorg,
**         ztesusk-vtweg,
**         ztesusk-spart,
*         ztesusk-setty, ztesusk-cadno.
*
*  IF NOT ztesusk-bukrs IS INITIAL.
*    SELECT SINGLE *
*      FROM t001
*     WHERE bukrs EQ ztesusk-bukrs.
*  ENDIF.
*
*  IF NOT ztesusk-epart IS INITIAL.
*    SELECT SINGLE namet
*      INTO ztesusk-namet
*      FROM ztstig3
*     WHERE parti  EQ  'B'
*       AND epart  EQ  ztesusk-epart.
*  ENDIF.

ENDFORM.                    " set_copy_defalut_value
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_CONFIRM_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM popup_to_confirm_message  USING  p_mode
                                      p_answer.

  DATA: cancel_display.
*>------------------------------------------------------
*> MESSAGE POPUP용.
*>------------------------------------------------------
  DATA: BEGIN OF pop,
        titel      LIKE spop-titel,
        diagnose1  LIKE spop-diagnose1,
        diagnose2  LIKE spop-diagnose2,
        diagnose3  LIKE spop-diagnose3,
        textline1  LIKE spop-textline1,
        textline2  LIKE spop-textline2,
        textline3  LIKE spop-textline3,
        option1    LIKE spop-varoption1,
        option2    LIKE spop-varoption2,
        default,             "defaultoption fuer Confirm_step
        answer,
  END OF pop.

  CLEAR: cancel_display, p_answer.

  CASE p_mode.
    WHEN 'D'.
      MOVE: '선택한 데이타가 삭제됩니다.'         TO pop-diagnose1,
            '삭제작업을 진행하시겠습니까?'        TO pop-textline1,
            '삭제 확인'                           TO pop-titel.

    WHEN 'B'.
      MOVE: '선택한 데이타가 승인됩니다.'         TO pop-diagnose1,
            '승인작업을 진행하시겠습니까?'        TO pop-textline1,
            '승인 확인'                           TO pop-titel.
    WHEN 'A'.
      MOVE: '선택한 데이타가 승인취소됩니다.'     TO pop-diagnose1,
            '승인취소 작업을 진행하시겠습니까?'   TO pop-textline1,
            '승인취소 확인'                       TO pop-titel.
  ENDCASE.

  CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
         EXPORTING
*             DEFAULTOPTION = 'Y'
              diagnosetext1 = pop-diagnose1
*             DIAGNOSETEXT2 = POP-DIAGNOSE2
*             DIAGNOSETEXT3 = ' '
              textline1      = pop-textline1
*              TEXTLINE2      = POP-TEXTLINE2
              titel          = pop-titel
*             START_COLUMN   = 25
*             START_ROW      = 6
              cancel_display = cancel_display
         IMPORTING
              answer        = pop-answer
         EXCEPTIONS
              OTHERS        = 1.

  p_answer = pop-answer.
  IF p_answer EQ 'N'.
    MESSAGE s900.
  ENDIF.

ENDFORM.                    " POPUP_TO_CONFIRM_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  set_status_field_update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_status_field_update  TABLES  pt_row_no TYPE lvc_t_roid
                              USING   p_mode.

  DATA : l_if_null         TYPE REF TO if_message_obj_mm.
  DATA : l_biz(09)         TYPE c.
  DATA : l_objectid        LIKE cdhdr-objectid.
  DATA : l_count           TYPE i.
  DATA : l_ddtext          LIKE dd07v-ddtext.

  DATA : BEGIN OF lt_ztitig04 OCCURS 0.
          INCLUDE STRUCTURE ztitig04.
  DATA:  END   OF lt_ztitig04.

  DATA : BEGIN OF lt_ztitig04_o OCCURS 0.
          INCLUDE STRUCTURE ztitig04.
  DATA:  END   OF lt_ztitig04_o.

  DATA : BEGIN OF lt_cdtxt OCCURS 0.
          INCLUDE STRUCTURE cdtxt.
  DATA:  END   OF lt_cdtxt.

* preparations
  CALL METHOD cl_message_handler_mm=>get_handler
    IMPORTING
      ex_handler = g_message_handler.

  CALL METHOD g_message_handler->set_config_for_mepo( ).
  CALL METHOD g_message_handler->remove_all( ).
  CALL METHOD g_message_handler->cleanup( ).

  LOOP AT pt_row_no.
    IF pt_row_no-row_id GT 0.

      READ TABLE it_tab INDEX pt_row_no-row_id.
      IF sy-subrc NE 0.
        MESSAGE s909.
        PERFORM set_return_message_fill USING 'E'.
        CONTINUE.
      ENDIF.

      CASE p_mode.
        WHEN 'D'.
          IF it_tab-apvyn EQ 'B'.
*> 문서상태 Fixed value read.
*            PERFORM  ddic_domain_value_text_read(ztir0000)
*                                      USING 'ZTIAPVYN'
*                                             sy-langu
*                                             it_tab-apvyn
*                                             l_ddtext
*                                             'S'.
            MESSAGE s999 WITH '승인내역입니다.' .
*            MESSAGE s930 WITH it_tab-iusno l_ddtext.
            PERFORM set_return_message_fill USING 'E'.
            CONTINUE.
          ENDIF.
        WHEN 'A'.
          IF it_tab-apvyn NE 'B'.
*> 문서상태 Fixed value read.
            PERFORM  ddic_domain_value_text_read(ztir0000)
                                      USING 'ZTIAPVYN'
                                             sy-langu
                                             it_tab-apvyn
                                             l_ddtext
                                             'S'.
*            MESSAGE s930 WITH it_tab-iusno l_ddtext.
            PERFORM set_return_message_fill USING 'E'.
            CONTINUE.
          ENDIF.
        WHEN 'B'.
          IF it_tab-apvyn NE 'A'.
*> 문서상태 Fixed value read.
            PERFORM  ddic_domain_value_text_read(ztir0000)
                                      USING 'ZTIAPVYN'
                                             sy-langu
                                             it_tab-apvyn
                                             l_ddtext
                                             'S'.
*            MESSAGE s930 WITH it_tab-iusno l_ddtext.
            PERFORM set_return_message_fill USING 'E'.
            CONTINUE.
          ENDIF.
        "자금팀, 회계팀 승인 권한 체크
       SELECT SINGLE gubun
                INTO @DATA(lv_gubun)
                FROM ztrtf68
               WHERE bukrs IN @s_bukrs
                 AND uname EQ @sy-uname.
        IF sy-subrc NE 0.
            MESSAGE s999 WITH '자금팀장 및 회계팀 이외 사용할 수 없습니다.' .
            PERFORM set_return_message_fill USING 'E'.
            CONTINUE.
        ELSEIF lv_gubun EQ 'T' AND it_tab-uname IS NOT INITIAL.
            MESSAGE s999 WITH '승인 내역입니다.' .
            PERFORM set_return_message_fill USING 'E'.
            CONTINUE.
         ELSEIF lv_gubun EQ 'F'.
           IF it_tab-uname IS INITIAL.
            MESSAGE s999 WITH '자금팀장 승인이 완료되지 않았습니다.' .
            PERFORM set_return_message_fill USING 'E'.
            CONTINUE.
           ENDIF.
        ENDIF.
      ENDCASE.

      CALL FUNCTION 'ENQUEUE_EZ_ZTITIG04'
       EXPORTING
         mode_ztitig04        = 'X'
         mandt                = sy-mandt
         bukrs                = it_tab-bukrs
         lifnr                = it_tab-lifnr
         waers                = it_tab-waers
*         X_BUKRS              = ' '
*         X_LIFNR              = ' '
*         X_WAERS              = ' '
*         _SCOPE               = '2'
*         _WAIT                = ' '
*         _COLLECT             = ' '
       EXCEPTIONS
         foreign_lock         = 1
         system_failure       = 2
         OTHERS               = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        PERFORM set_return_message_fill USING 'E'.
        CONTINUE.
      ENDIF.

      MOVE-CORRESPONDING it_tab TO lt_ztitig04_o.
      APPEND lt_ztitig04_o.

      IF lv_gubun EQ 'T'. "자금팀장.
        MOVE: sy-uname TO it_tab-uname.

      ELSE. "회계팀
        MOVE: p_mode    TO it_tab-apvyn,
              sy-uname  TO it_tab-unam,
              sy-datlo  TO it_tab-udat,
              sy-timlo  TO it_tab-utme.
        IF p_mode EQ 'B'.
          MOVE: sy-uname  TO it_tab-apvun,
                sy-datlo  TO it_tab-apvdt,
                sy-timlo  TO it_tab-apvtm.
        ENDIF.
        IF p_mode EQ 'A'.
          CLEAR : it_tab-apvun,
                  it_tab-apvdt,
                  it_tab-apvtm.
        ENDIF.

      ENDIF.

      MODIFY it_tab INDEX pt_row_no-row_id.
      MOVE-CORRESPONDING it_tab TO lt_ztitig04.
      APPEND lt_ztitig04.
      ADD 1 TO l_count.
    ENDIF.
  ENDLOOP.

  IF l_count GT 0.
*>
    SET UPDATE TASK LOCAL.
    IF p_mode EQ 'D'.
      DELETE ztitig04 FROM TABLE lt_ztitig04.
    ELSE.
      MODIFY ztitig04 FROM TABLE lt_ztitig04.
    ENDIF.
    IF sy-subrc EQ 0.
      COMMIT WORK.
      CASE p_mode.
        WHEN 'D'.
          l_biz = '삭제 처리'.
        WHEN 'A'.
          l_biz = '승인 취소'.
        WHEN 'B'.
          l_biz = '승인 처리'.
      ENDCASE.
      MESSAGE s690 WITH l_count l_biz.
      PERFORM set_return_message_fill USING 'S'.
    ELSE.
      ROLLBACK WORK.
      MESSAGE s912.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

    LOOP AT lt_ztitig04.
      CALL FUNCTION 'DEQUEUE_EZ_ZTITIG04'
       EXPORTING
         mode_ztitig04       = 'X'
         mandt               = sy-mandt
         bukrs               = lt_ztitig04-bukrs
         lifnr               = lt_ztitig04-lifnr
         waers               = lt_ztitig04-waers
*          X_BUKRS             = ' '
*          X_LIFNR             = ' '
*          X_WAERS             = ' '
*          _SCOPE              = '3'
*          _SYNCHRON           = ' '
*          _COLLECT            = ' '
                .
*      IF p_mode NE 'D'.
*        READ TABLE lt_ztitig04_o WITH KEY bukrs = lt_ztitig04-bukrs.
*        IF sy-subrc EQ 0.
*
*          l_objectid = lt_ztitig04(13).

*          CALL FUNCTION 'ZTEUSCHDOC_WRITE_DOCUMENT'
*            EXPORTING
*              objectid                      = l_objectid
*              tcode                         = sy-tcode
*              utime                         = sy-timlo
*              udate                         = sy-datlo
*              username                      = sy-uname
**             PLANNED_CHANGE_NUMBER         = ' '
*              object_change_indicator       = 'U'
**             PLANNED_OR_REAL_CHANGES       = ' '
**             NO_CHANGE_POINTERS            = ' '
*              upd_icdtxt_zteuschdoc         = 'U'
*              n_ztetusk                     = lt_ztetusk
*              o_ztetusk                     = lt_ztetusk_o
*              upd_ztetusk                   = 'U'
*            TABLES
*              icdtxt_zteuschdoc             = lt_cdtxt.
*        ENDIF.
*      ENDIF.
    ENDLOOP.
  ENDIF.

*> 오류정보가 존재시 메시지 상자 POPUP.
  g_line = g_message_handler->get_severity_bo(
                          im_business_obj          = l_if_null
                          im_include_child_objects = 'X' ).

  IF g_line GT 0.
    CALL METHOD g_message_handler->show( im_popup = 'X'
      im_amodal = ' ' ).
  ENDIF.

*> 검색조건에 해당하는 데이타를 Select.
  PERFORM  p2000_data_selections.
*> Fields 속성 정의.
  PERFORM  p3800_field_attribute_change.
*> Refresh ALV Grid controls.
  PERFORM  p9000_refresh_display.

ENDFORM.                    " set_status_field_update
*&---------------------------------------------------------------------*
*&      Form  set_return_message_fill
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2116   text
*----------------------------------------------------------------------*
FORM set_return_message_fill  USING p_msgty.

*> build message
  zte_message p_msgty sy-msgid sy-msgno
              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

ENDFORM.                    " set_return_message_fill
*&---------------------------------------------------------------------*
*&      Form  business_by_process
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM business_by_process  TABLES   pt_row_no TYPE lvc_t_roid
                          USING    p_mode.

  DATA: l_answer TYPE c.

  PERFORM  popup_to_confirm_message USING p_mode
                                          l_answer.
  CHECK l_answer EQ 'J'.

  IF g_bukrs EQ '1000'. "전선
    PERFORM  set_status_field_update  TABLES  pt_row_no
                                      USING   p_mode.
  ELSE.
    PERFORM  set_status_field_update2 TABLES  pt_row_no
                                      USING   p_mode.
  ENDIF.
ENDFORM.                    " business_by_process
*&---------------------------------------------------------------------*
*&      Form  create_sub_routine
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_sub_routine .

  IF g_mode EQ 'M'.
    SELECT SINGLE *
      INTO *ztitig04
      FROM ztitig04
     WHERE bukrs EQ ztitig04-bukrs
       AND lifnr EQ ztitig04-lifnr
       AND waers EQ ztitig04-waers.

    IF sy-tcode EQ 'ZTIT011' AND
       *ztitig04-apvyn EQ 'B'.
      MESSAGE s999 WITH '선택건은 승인상태이다.'.
      EXIT.
    ENDIF.

    ztitig04 = *ztitig04.
    MOVE-CORRESPONDING *ztitig04 TO ztisig04.

    CALL FUNCTION 'ENQUEUE_EZ_ZTITIG04'
     EXPORTING
       mode_ztitig04        = 'X'
       mandt                = sy-mandt
       bukrs                = ztisig04-bukrs
       lifnr                = ztisig04-lifnr
       waers                = ztisig04-waers
*       X_BUKRS              = ' '
*       X_LIFNR              = ' '
*       X_WAERS              = ' '
*       _SCOPE               = '2'
*       _WAIT                = ' '
*       _COLLECT             = ' '
     EXCEPTIONS
       foreign_lock         = 1
       system_failure       = 2
       OTHERS               = 3
              .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.

*> Screen Call
  CALL SCREEN 3000 STARTING AT 1 4.

  IF ok_code EQ 'BU'.
*> Table 저장.
    PERFORM  save_database_table.
    IF g_mode EQ 'C' OR
       g_mode EQ 'M'.
*> 검색조건에 해당하는 데이타를 Select.
      PERFORM  p2000_data_selections.
*> Fields 속성 정의.
      PERFORM  p3800_field_attribute_change.
*> Refresh ALV Grid controls.
      PERFORM  p9000_refresh_display.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_ZTITIG04'
      EXPORTING
        mode_ztitig04 = 'X'
        mandt         = sy-mandt
        bukrs         = ztitig04-bukrs
        lifnr         = ztitig04-lifnr
        waers         = ztitig04-waers
        x_bukrs       = ' '
        x_lifnr       = ' '
        x_waers       = ' '
        _scope        = '3'
        _synchron     = ' '
        _collect      = ' '.

    MESSAGE s900.
  ENDIF.

ENDFORM.                    " create_sub_routine
*&---------------------------------------------------------------------*
*&      Form  display_change_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_change_document  USING  p_objekt   LIKE cdhdr-objectclas
                                     p_objektid LIKE cdhdr-objectid.

  SUBMIT  rcs00120 WITH  objekt   =   p_objekt
                   WITH  objektid =   p_objektid
                   AND   RETURN.

ENDFORM.                    " display_change_document
*&---------------------------------------------------------------------*
*&      Form  GET_FILE_UPLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_file_upload .

  DATA: lt_files           LIKE sdokpath OCCURS 0 WITH HEADER LINE,
        l_extension        LIKE sdokpropty-value,
        l_upload           LIKE rlgrap-filename,
        l_rc               TYPE i,
        l_is_existing      TYPE c,
        l_filter(5)        TYPE c,
        l_start_select(10) TYPE c,
        l_not_allowed      LIKE iwparams-flag,
        l_txtmsg(100)      TYPE c,
        l_subrc            LIKE sy-subrc,
        l_format           LIKE sdokpropty-value,
        l_count            TYPE i.

  DATA:lt_excl LIKE ztisexcel OCCURS 0 WITH HEADER LINE.

  FIELD-SYMBOLS <fs>.

  CLEAR: g_line.

* Im Haupverzeichnis Suche beginnen falls Win Frontend
  l_start_select = 'C:\'.
  PERFORM isexisting
    USING    l_start_select
    CHANGING l_is_existing.

  IF l_is_existing = space.
    CLEAR l_start_select.
  ENDIF.

* FIler versorgen falls Endung bekannt.
  CONCATENATE '*.' 'XLS' INTO l_filter.
  l_extension = 'XLS'.

* Dateiauswahl auf dem Frontend mit Multiselektion
  CALL FUNCTION 'TMP_GUI_FILE_OPEN_DIALOG'
      EXPORTING
           window_title      = '게시내역 업로드용 파일 선택'
           default_extension = l_extension
           default_filename  = l_filter
*           FILE_FILTER       = h_filter
           init_directory    = l_start_select
           multiselection    = ' '
      IMPORTING
           rc                = l_rc
       TABLES
            file_table       = lt_files
      EXCEPTIONS
           cntl_error        = 1
           OTHERS            = 2.

  IF sy-subrc <> 0.
    EXIT.
  ELSEIF l_rc < 0.
    MESSAGE s900.
    EXIT.
  ENDIF.

  READ TABLE lt_files INDEX 1.
  IF sy-subrc EQ 0.
*> PROGRESS Display.
    g_linen    = 30.
    g_out_text = 'Excel 파일을 읽는 중입니다 %99999%%'.
    REPLACE '%99999%' WITH g_linen INTO g_out_text.
    PERFORM show_progress_bar USING g_out_text g_linen.

    l_upload = lt_files-pathname.
    CALL FUNCTION 'Z_TS_KCD_EXCEL_OLE_TO_INT_CONV'
      EXPORTING
        filename                = l_upload
        i_begin_col             = 1
        i_begin_row             = 1
        i_end_col               = 50
        i_end_row               = 65536
      TABLES
        intern                  = lt_excl
      EXCEPTIONS
        inconsistent_parameters = 1
        upload_ole              = 2
        OTHERS                  = 3.

    DESCRIBE TABLE lt_excl LINES g_line.
    IF g_line EQ 0.
      MESSAGE s997
          WITH 'Upload된 파일' l_upload '에 데이터가 없습니다.'.
      EXIT.
    ENDIF.

    CLEAR: gt_upload_list[], gt_upload_title.
    SORT lt_excl BY row col.

    LOOP AT lt_excl.
      CLEAR: l_subrc.
      IF lt_excl-row = 1.
        CONTINUE.
*        IF p_header EQ 'X'.
*          l_subrc = 4.
*      ASSIGN COMPONENT lt_excl-col OF STRUCTURE gt_download TO <fs>.
*        ELSE.
*          ASSIGN COMPONENT lt_excl-col OF STRUCTURE
*                           gt_upload_list  TO <fs>.
*          l_subrc = sy-subrc.
*        ENDIF.
      ELSE.
       ASSIGN COMPONENT lt_excl-col OF STRUCTURE gt_upload_list TO <fs>.
        l_subrc = sy-subrc.
      ENDIF.
*    IF l_subrc EQ 0.
      <fs> = lt_excl-value.
*    ENDIF.
*> Row의 마지막일 경우.
      AT END OF row.
        IF lt_excl-row = 1.
*          IF p_header NE 'X'.
*            APPEND gt_upload_list.   CLEAR gt_upload_list.
*          ELSE.
*            APPEND gt_download.  CLEAR gt_download.
*          ENDIF.
          CONTINUE.
        ELSE.
          APPEND gt_upload_list.   CLEAR gt_upload_list.
        ENDIF.
      ENDAT.
    ENDLOOP.
  ELSE.
    MESSAGE s932.  EXIT.
  ENDIF.

  DESCRIBE TABLE gt_upload_list LINES g_line.
  IF g_line EQ 0.
    MESSAGE s997
        WITH 'Upload된 파일' l_upload '에 데이터가 없습니다.'.
    EXIT.
  ENDIF.


*  PERFORM create_dynamic_table USING 'ZTETUSK'
*                                            g_subrc.
*
  PERFORM move_upload_data_to_int_tab.


ENDFORM.                    " GET_FILE_UPLOAD

*&---------------------------------------------------------------------*
*&      Form  ISEXISTING
*&---------------------------------------------------------------------*
FORM isexisting USING    p_fullpath TYPE  c
                CHANGING p_isexisting TYPE c.

  CALL FUNCTION 'TMP_GUI_GET_FILE_EXIST'
    EXPORTING
      fname          = p_fullpath
    IMPORTING
      exist          = p_isexisting
    EXCEPTIONS
      fileinfo_error = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
    p_isexisting = space.
  ENDIF.
ENDFORM.                    " ISEXISTING
*&---------------------------------------------------------------------*
*&      Form  show_progress_bar
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM show_progress_bar  USING    text
                                 perc.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = perc
      text       = text.

ENDFORM.                    " show_progress_bar
*&---------------------------------------------------------------------*
*&      Form  create_dynamic_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_dynamic_table USING    p_tabname
                                   p_subrc.

  DATA: lp_table        TYPE REF TO data.
  DATA: e_style_fname   TYPE lvc_fname.
  DATA: i_style_table   TYPE c.
  DATA: lt_fieldcat     TYPE lvc_t_fcat.
  DATA: it_fieldcat     TYPE lvc_t_fcat.
  DATA: fc              TYPE slis_t_fieldcat_alv.
  DATA: fcs             TYPE slis_fieldcat_alv.

*> Create field catagory table
  FREE: it_fieldcat.
  CLEAR: it_fieldcat.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = p_tabname
      i_client_never_display = ' '
    CHANGING
      ct_fieldcat            = it_fieldcat[].

*>Adjust ALV field category
*>Internal table에 존재하지 않는 필드.
  CLEAR: fc.  FREE : fc.

  LOOP AT it_fieldcat INTO gs_fieldcat_g.
    MOVE-CORRESPONDING  gs_fieldcat_g TO fcs.
    MOVE: gs_fieldcat_g-fieldname     TO fcs-ref_fieldname,
          p_tabname                   TO fcs-ref_tabname.
    CLEAR: fcs-key.
    fcs-no_out = 'X'.
    APPEND fcs TO fc.
  ENDLOOP.

*create_dynamic_table
  CLEAR lp_table.
  UNASSIGN <gt_table>.
  CALL METHOD z_ts_cl_alv_table_create=>create_dynamic_table_grid
    EXPORTING
      it_fieldcatalog = fc
*      i_style_table   = i_style_table
    IMPORTING
      ep_table        = lp_table.

  ASSIGN lp_table->* TO <gt_table>.
  p_subrc = sy-subrc.

ENDFORM.                    " create_dynamic_table
*&---------------------------------------------------------------------*
*&      Form  MOVE_UPLOAD_DATA_TO_INT_TAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM move_upload_data_to_int_tab .

  DATA: l_docno   TYPE  ztedocno.
  DATA: l_waers   LIKE  tcurc-waers,
        l_amount  LIKE  bapicurx-bapicurx.

  FIELD-SYMBOLS: <gs_table>.
  FIELD-SYMBOLS: <l_iusno>.
  FIELD-SYMBOLS: <l_field>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.
  FIELD-SYMBOLS: <l_field3>.

  DATA: lt_ztetusk LIKE ztetusk OCCURS 0 WITH HEADER LINE.

  g_linen    = 70.
  g_out_text = '데이타를 점검 중입니다 %99999%%'.
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar USING g_out_text g_linen.


  LOOP AT gt_upload_list.
    CLEAR: lt_ztetusk.
*> 입금액.
    PERFORM set_write_no_mask(zter0000) USING gt_upload_list-uebtr.
    MOVE-CORRESPONDING gt_upload_list TO lt_ztetusk.
    l_waers  = lt_ztetusk-waers.
    l_amount = lt_ztetusk-uebtr.

    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERN_9'
      EXPORTING
        currency             = l_waers
        amount_external      = l_amount
        max_number_of_digits = 19
      IMPORTING
        amount_internal      = lt_ztetusk-uebtr.

*> 날짜 변환.
    PERFORM  convert_date_to_internal USING : gt_upload_list-melda,
                                              gt_upload_list-sdidt.

    MOVE: gt_upload_list-sdidt TO lt_ztetusk-sdidt,
          gt_upload_list-melda TO lt_ztetusk-melda.

    CALL FUNCTION 'Z_TE_GET_NUMBER_NEXT'
      EXPORTING
        im_docty = 'US'
      IMPORTING
        ex_docno = l_docno
      EXCEPTIONS
        not_type = 1
        OTHERS   = 2.
    IF sy-subrc <> 0.
      MESSAGE ID   sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING update_error.
    ENDIF.

    MOVE: sy-mandt       TO lt_ztetusk-mandt,
          l_docno        TO lt_ztetusk-iusno,
          g_bukrs        TO lt_ztetusk-bukrs,
          'A'            TO lt_ztetusk-setpg,
          'F'            TO lt_ztetusk-inpmd,
          sy-uname       TO lt_ztetusk-cnam,
          sy-datlo       TO lt_ztetusk-cdat,
          sy-timlo       TO lt_ztetusk-ctme,
          sy-uname       TO lt_ztetusk-unam,
          sy-datlo       TO lt_ztetusk-udat,
          sy-timlo       TO lt_ztetusk-utme.

    APPEND lt_ztetusk.

  ENDLOOP.

  g_linen    = 100.
  g_out_text = '데이타를 반영 중입니다 %99999%%'.
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar USING g_out_text g_linen.

  SET UPDATE TASK LOCAL.
  MODIFY ztetusk FROM TABLE lt_ztetusk.
  IF sy-subrc EQ 0.
    MESSAGE s690 WITH g_line '업로드'.
    COMMIT WORK.
  ELSE.
    MESSAGE e692.
    ROLLBACK WORK.
  ENDIF.

*  REFRESH : <gt_table>.
*
*  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <gs_table>.
*
*  ASSIGN COMPONENT 'IUSNO' OF STRUCTURE <gs_table> TO <l_IUSNO>
*
*  LOOP AT gt_upload_list.
*    CLEAR: <GS_TABLE>.
*    MOVE-CORRESPONDING GT_UPLOAD_LIST TO <GS_TABLE>.
*
*
*    APPEND <gs_table> TO <gt_table> .
*  ENDLOOP.


ENDFORM.                    " MOVE_UPLOAD_DATA_TO_INT_TAB
*&---------------------------------------------------------------------*
*&      Form  CONVERT_DATE_TO_INTERNAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM convert_date_to_internal  USING    p_date.

*  BREAK-POINT.

  PERFORM    set_change_symbol(zter0000)    USING p_date  '.' ' '.
  PERFORM    set_change_symbol(zter0000)    USING p_date  '-' ' '.
  PERFORM    set_change_symbol(zter0000)    USING p_date  '/' ' '.
  CONDENSE   p_date    NO-GAPS.

  CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
    EXPORTING
      date_external            = p_date
    IMPORTING
      date_internal            = p_date
    EXCEPTIONS
      date_external_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " CONVERT_DATE_TO_INTERNAL
*&---------------------------------------------------------------------*
*&      Form  p3800_set_title_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p3800_set_title_text .

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: l_butxt LIKE t001-butxt,
        l_title TYPE lvc_title.
  CLEAR: l_butxt, l_title.
  SELECT SINGLE butxt FROM t001
                      INTO l_butxt
                     WHERE bukrs EQ s_bukrs-low.

  CONCATENATE '회사코드:' s_bukrs-low l_butxt
         INTO l_title SEPARATED BY space.

  CALL METHOD g_grid->set_gridtitle
    EXPORTING
      i_gridtitle = l_title.
** JS전선 회사코드 2007/04 KSH --------------------------------------

ENDFORM.                    " p3800_set_title_text
*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_screen .
  LOOP AT SCREEN.
    IF sy-tcode EQ 'ZTIT011'.
      CASE screen-group1.
        WHEN 'G1'.
          screen-input     = '0'.
          screen-invisible = '1'.
      ENDCASE.
    ELSE.
      CASE screen-group1.
        WHEN 'G1'.
          screen-input     = '1'.
          screen-invisible = '0'.
      ENDCASE.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    " MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& Form set_status_field_update2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ROW_NO
*&      --> P_MODE
*&---------------------------------------------------------------------*
FORM set_status_field_update2  TABLES  pt_row_no TYPE lvc_t_roid
                              USING   p_mode.

  DATA : l_if_null         TYPE REF TO if_message_obj_mm.
  DATA : l_biz(09)         TYPE c.
  DATA : l_objectid        LIKE cdhdr-objectid.
  DATA : l_count           TYPE i.
  DATA : l_ddtext          LIKE dd07v-ddtext.

  DATA : BEGIN OF lt_ztitig04 OCCURS 0.
          INCLUDE STRUCTURE ztitig04.
  DATA:  END   OF lt_ztitig04.

  DATA : BEGIN OF lt_ztitig04_o OCCURS 0.
          INCLUDE STRUCTURE ztitig04.
  DATA:  END   OF lt_ztitig04_o.

  DATA : BEGIN OF lt_cdtxt OCCURS 0.
          INCLUDE STRUCTURE cdtxt.
  DATA:  END   OF lt_cdtxt.

* preparations
  CALL METHOD cl_message_handler_mm=>get_handler
    IMPORTING
      ex_handler = g_message_handler.

  CALL METHOD g_message_handler->set_config_for_mepo( ).
  CALL METHOD g_message_handler->remove_all( ).
  CALL METHOD g_message_handler->cleanup( ).

  LOOP AT pt_row_no.
    IF pt_row_no-row_id GT 0.

      READ TABLE it_tab INDEX pt_row_no-row_id.
      IF sy-subrc NE 0.
        MESSAGE s909.
        PERFORM set_return_message_fill USING 'E'.
        CONTINUE.
      ENDIF.

      CASE p_mode.
        WHEN 'D'.
          IF it_tab-apvyn EQ 'B'.
*> 문서상태 Fixed value read.
*            PERFORM  ddic_domain_value_text_read(ztir0000)
*                                      USING 'ZTIAPVYN'
*                                             sy-langu
*                                             it_tab-apvyn
*                                             l_ddtext
*                                             'S'.
            MESSAGE s999 WITH '승인내역입니다.' .
*            MESSAGE s930 WITH it_tab-iusno l_ddtext.
            PERFORM set_return_message_fill USING 'E'.
            CONTINUE.
          ENDIF.
        WHEN 'A'.
          IF it_tab-apvyn NE 'B'.
*> 문서상태 Fixed value read.
            PERFORM  ddic_domain_value_text_read(ztir0000)
                                      USING 'ZTIAPVYN'
                                             sy-langu
                                             it_tab-apvyn
                                             l_ddtext
                                             'S'.
*            MESSAGE s930 WITH it_tab-iusno l_ddtext.
            PERFORM set_return_message_fill USING 'E'.
            CONTINUE.
          ENDIF.
        WHEN 'B'.
          IF it_tab-apvyn NE 'A'.
*> 문서상태 Fixed value read.
            PERFORM  ddic_domain_value_text_read(ztir0000)
                                      USING 'ZTIAPVYN'
                                             sy-langu
                                             it_tab-apvyn
                                             l_ddtext
                                             'S'.
*            MESSAGE s930 WITH it_tab-iusno l_ddtext.
            PERFORM set_return_message_fill USING 'E'.
            CONTINUE.
          ENDIF.
      ENDCASE.

      CALL FUNCTION 'ENQUEUE_EZ_ZTITIG04'
       EXPORTING
         mode_ztitig04        = 'X'
         mandt                = sy-mandt
         bukrs                = it_tab-bukrs
         lifnr                = it_tab-lifnr
         waers                = it_tab-waers
*         X_BUKRS              = ' '
*         X_LIFNR              = ' '
*         X_WAERS              = ' '
*         _SCOPE               = '2'
*         _WAIT                = ' '
*         _COLLECT             = ' '
       EXCEPTIONS
         foreign_lock         = 1
         system_failure       = 2
         OTHERS               = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        PERFORM set_return_message_fill USING 'E'.
        CONTINUE.
      ENDIF.

      MOVE-CORRESPONDING it_tab TO lt_ztitig04_o.
      APPEND lt_ztitig04_o.

      MOVE: p_mode    TO it_tab-apvyn,
            sy-uname  TO it_tab-unam,
            sy-datlo  TO it_tab-udat,
            sy-timlo  TO it_tab-utme.
      IF p_mode EQ 'B'.
        MOVE: sy-uname  TO it_tab-apvun,
              sy-datlo  TO it_tab-apvdt,
              sy-timlo  TO it_tab-apvtm.
      ENDIF.
      IF p_mode EQ 'A'.
        CLEAR : it_tab-apvun,
                it_tab-apvdt,
                it_tab-apvtm.
      ENDIF.
      MODIFY it_tab INDEX pt_row_no-row_id.
      MOVE-CORRESPONDING it_tab TO lt_ztitig04.
      APPEND lt_ztitig04.
      ADD 1 TO l_count.
    ENDIF.
  ENDLOOP.

  IF l_count GT 0.
*>
    SET UPDATE TASK LOCAL.
    IF p_mode EQ 'D'.
      DELETE ztitig04 FROM TABLE lt_ztitig04.
    ELSE.
      MODIFY ztitig04 FROM TABLE lt_ztitig04.
    ENDIF.
    IF sy-subrc EQ 0.
      COMMIT WORK.
      CASE p_mode.
        WHEN 'D'.
          l_biz = '삭제 처리'.
        WHEN 'A'.
          l_biz = '승인 취소'.
        WHEN 'B'.
          l_biz = '승인 처리'.
      ENDCASE.
      MESSAGE s690 WITH l_count l_biz.
      PERFORM set_return_message_fill USING 'S'.
    ELSE.
      ROLLBACK WORK.
      MESSAGE s912.
      PERFORM set_return_message_fill USING 'E'.
    ENDIF.

    LOOP AT lt_ztitig04.
      CALL FUNCTION 'DEQUEUE_EZ_ZTITIG04'
       EXPORTING
         mode_ztitig04       = 'X'
         mandt               = sy-mandt
         bukrs               = lt_ztitig04-bukrs
         lifnr               = lt_ztitig04-lifnr
         waers               = lt_ztitig04-waers
*          X_BUKRS             = ' '
*          X_LIFNR             = ' '
*          X_WAERS             = ' '
*          _SCOPE              = '3'
*          _SYNCHRON           = ' '
*          _COLLECT            = ' '
                .
*      IF p_mode NE 'D'.
*        READ TABLE lt_ztitig04_o WITH KEY bukrs = lt_ztitig04-bukrs.
*        IF sy-subrc EQ 0.
*
*          l_objectid = lt_ztitig04(13).

*          CALL FUNCTION 'ZTEUSCHDOC_WRITE_DOCUMENT'
*            EXPORTING
*              objectid                      = l_objectid
*              tcode                         = sy-tcode
*              utime                         = sy-timlo
*              udate                         = sy-datlo
*              username                      = sy-uname
**             PLANNED_CHANGE_NUMBER         = ' '
*              object_change_indicator       = 'U'
**             PLANNED_OR_REAL_CHANGES       = ' '
**             NO_CHANGE_POINTERS            = ' '
*              upd_icdtxt_zteuschdoc         = 'U'
*              n_ztetusk                     = lt_ztetusk
*              o_ztetusk                     = lt_ztetusk_o
*              upd_ztetusk                   = 'U'
*            TABLES
*              icdtxt_zteuschdoc             = lt_cdtxt.
*        ENDIF.
*      ENDIF.
    ENDLOOP.
  ENDIF.

*> 오류정보가 존재시 메시지 상자 POPUP.
  g_line = g_message_handler->get_severity_bo(
                          im_business_obj          = l_if_null
                          im_include_child_objects = 'X' ).

  IF g_line GT 0.
    CALL METHOD g_message_handler->show( im_popup = 'X'
      im_amodal = ' ' ).
  ENDIF.

*> 검색조건에 해당하는 데이타를 Select.
  PERFORM  p2000_data_selections.
*> Fields 속성 정의.
  PERFORM  p3800_field_attribute_change.
*> Refresh ALV Grid controls.
  PERFORM  p9000_refresh_display.

ENDFORM.
