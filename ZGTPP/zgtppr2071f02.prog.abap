*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form add_exclude_toolbar_button
*&---------------------------------------------------------------------*
FORM add_exclude_toolbar_button TABLES pt_table USING pv_value.

  DATA: lv_exclude TYPE ui_func.

  lv_exclude = pv_value.
*& 결과적으로 GT_EXCLUDE에 제거할 버튼 저장
  APPEND lv_exclude TO pt_table.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_field_catalogs
*&---------------------------------------------------------------------*
FORM fill_field_catalogs TABLES pt_fieldcat TYPE lvc_t_fcat
                          USING  pv_gub
                                 pv_fname
                                 pv_value.
*& 'S' -> Structure에 필드 속성 값 Setting을 Start 시점
*& 'E' -> Structure의 내용을 필드 카타로그 테이블에 저장 시점
  IF pv_gub = 'S'.
    CLEAR gs_fieldcat.
  ENDIF.
*& 출력될 Field 속성을 정의해서 필드 카타로그 테이블에 저장
  DATA lv_fname(40).
  FIELD-SYMBOLS <fs_field> TYPE any.

  CONCATENATE 'GS_FIELDCAT-' pv_fname INTO lv_fname.

  ASSIGN (lv_fname) TO <fs_field>.
  <fs_field> = pv_value.

  IF pv_gub = 'E'.
    APPEND gs_fieldcat TO pt_fieldcat.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form toolbar_proc
*&---------------------------------------------------------------------*
FORM toolbar_proc USING ps_object TYPE REF TO cl_alv_event_toolbar_set
                                  pv_interactive.

  DATA : ls_toolbar  TYPE stb_button.

  MOVE   3             TO  ls_toolbar-butn_type.
  APPEND ls_toolbar TO  ps_object->mt_toolbar.

  CLEAR ls_toolbar.
**  MOVE 'SELA'               TO  ls_toolbar-function.
**  MOVE icon_select_all      TO  ls_toolbar-icon.
**  MOVE '전체선택'           TO  ls_toolbar-quickinfo.
**&  MOVE '전체선택'           TO  ls_toolbar-text.
*  MOVE ' '                  TO  ls_toolbar-disabled.
*  APPEND ls_toolbar         TO  r_object->mt_toolbar.
*
**&  MOVE   3                  TO  ls_toolbar-butn_type.
**&  APPEND ls_toolbar         TO  r_object->mt_toolbar.
*
*  CLEAR ls_toolbar.
*  MOVE 'DSEL'               TO  ls_toolbar-function.
*  MOVE icon_deselect_all    TO  ls_toolbar-icon.
*  MOVE '전체해제'           TO  ls_toolbar-quickinfo.
**&  MOVE '전체해제'           TO  ls_toolbar-text.
*  MOVE ' '                  TO  ls_toolbar-disabled.
*  APPEND ls_toolbar         TO  r_object->mt_toolbar.

  PERFORM SET_TOOLBAR TABLES ps_object->MT_TOOLBAR
                       USING : '' '' '' '' '3',            "구분자
                                  'ADD' ICON_CREATE '' TEXT-T01 0 ,
                                  'DEL' ICON_DELETE '' TEXT-T02 0,
                                  'COP' ICON_SYSTEM_COPY '' TEXT-T03 0.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_proc
*&---------------------------------------------------------------------*
FORM user_command_proc USING PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                             pv_ucomm.

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LT_DELTAB_2130 TYPE TABLE OF ZGTPPT2130.
  DATA : LV_CHK_ITEM_EXIST.
  DATA : LV_INDEX TYPE SY-TABIX.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      CASE PV_UCOMM.

        WHEN 'ADD'.
          GV_CHK_CHANGE = ABAP_TRUE.
          APPEND INITIAL LINE TO GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP>).
          <LS_DISP>-STATUS = ICON_CREATE.
          <LS_DISP>-STATUS_VAL = 'INS'.
          <LS_DISP>-CHK_CHG = 'N'.

        WHEN 'DEL'.
          CALL METHOD PO_SENDER->GET_SELECTED_ROWS
            IMPORTING
              ET_INDEX_ROWS = LT_ROW.
*          딜리트시 역순으로 정렬
          SORT LT_ROW BY INDEX DESCENDING.
          IF LT_ROW[] IS INITIAL.
            MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E01.
            RETURN.
          ENDIF.
*         라인삭제시 기존데이터 삭제여부 확인후 팝업처리
          LOOP AT LT_ROW INTO LS_ROW.
            READ TABLE GT_DISP INTO GS_DISP INDEX LS_ROW-INDEX.
            GS_DISP-STATUS = ICON_DELETE.
            GS_DISP-STATUS_VAL = 'DEL'.
            MODIFY GT_DISP INDEX LS_ROW-INDEX FROM GS_DISP .
          ENDLOOP.

        WHEN 'COP'.
          CALL METHOD PO_SENDER->GET_SELECTED_ROWS
            IMPORTING
              ET_INDEX_ROWS = LT_ROW.
*          딜리트시 역순으로 정렬
          SORT LT_ROW BY INDEX DESCENDING.
          IF LT_ROW[] IS INITIAL.
            MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E01.
            RETURN.
          ENDIF.
          DATA(LV_TABIX) = SY-TABIX.
          CLEAR: LV_INDEX.
          LV_INDEX = LINES( GT_DISP ).
          LOOP AT  lt_row INTO  ls_row.
           CLEAR GS_DISP.
           READ TABLE GT_DISP INTO GS_DISP INDEX LS_ROW-INDEX.
           LV_INDEX += 1.
           GS_DISP-STATUS = ICON_SYSTEM_COPY.
           GS_DISP-STATUS_VAL = 'COP'.
           GS_DISP-ARBPL  = ''.
           GS_DISP-KTEXT  = ''.
           INSERT GS_DISP INTO GT_DISP INDEX LV_INDEX.
          ENDLOOP.

      ENDCASE.
*        화면 리프레쉬
      PERFORM REFRESH_GRID USING GO_GRID_0100.


  ENDCASE.

*  PERFORM refresh_grid_display .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form after_user_command
*&---------------------------------------------------------------------*
FORM after_user_command USING pv_ucomm.

*  CASE pv_ucomm.
*    WHEN '&REFRESH'.
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed
*&---------------------------------------------------------------------*
FORM data_changed USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                       pv_onf4 TYPE char1.

  DATA: lt_delta_cells   TYPE lvc_t_modi,
        ls_delta_cells   TYPE lvc_s_modi,
        ls_modified      TYPE char01,
        ls_frontend_only TYPE char01.

  DATA : ls_mod_cells TYPE lvc_s_modi,
         ls_cells     TYPE lvc_s_modi.


  LOOP AT PR_DATA_CHANGED->MT_MOD_CELLS INTO LS_MOD_CELLS.

      READ TABLE GT_DISP INTO GS_DISP INDEX LS_MOD_CELLS-ROW_ID.
      IF GS_DISP-status = ''.
        GS_DISP-STATUS = ICON_CHANGE.
        GS_DISP-STATUS_VAL  = 'CHA'.
        MODIFY GT_DISP INDEX LS_MOD_CELLS-ROW_ID FROM GS_DISP .
      ENDIF.
  ENDLOOP.

* 화면 리프레쉬
  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hotspot_click
*&---------------------------------------------------------------------*
FORM hotspot_click USING pv_row_id     TYPE lvc_s_row
                                     pv_column_id TYPE lvc_s_col.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
FORM double_click USING pv_row pv_column.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form button_click
*&---------------------------------------------------------------------*
FORM button_click USING ps_col_id  TYPE  lvc_s_col
                                 ps_row_no  TYPE  lvc_s_roid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form onf4_proc
*&---------------------------------------------------------------------*
FORM onf4_proc USING PV_FNAME
                       PV_FVAL
                       PS_ROID  TYPE LVC_S_ROID
                       PO_EVENT TYPE REF TO CL_ALV_EVENT_DATA
                       PT_BCELL TYPE LVC_T_MODI
                       PV_DISPLAY.


  DATA: LS_MODI TYPE LVC_S_MODI.

  FIELD-SYMBOLS: <LT_MODI> TYPE LVC_T_MODI.

  PO_EVENT->M_EVENT_HANDLED = ABAP_ON.

  READ TABLE GT_DISP INTO DATA(LS_DISP) INDEX PS_ROID-ROW_ID.

  CHECK SY-SUBRC = 0.

  CASE PV_FNAME.
    WHEN 'ARBPL'.
      PERFORM F4_ARBPL USING PS_ROID-ROW_ID
                       CHANGING LS_DISP.

    WHEN 'OPTYPE'.
      PERFORM F4_OPTYPE USING PS_ROID-ROW_ID
                       CHANGING LS_DISP.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0100
*&---------------------------------------------------------------------*
FORM set_object_grid_0100 .

  CREATE OBJECT go_docking_container
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
  CREATE OBJECT go_splitter
    EXPORTING
      parent  = go_docking_container
      rows    = 2
      columns = 1.

  GO_SPLITTER->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    10 ).             " Height

* top 컨테이너
  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = GO_CONTAIN_TOP_0100.
** bottom 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = go_contain_0100.

  CREATE OBJECT go_grid_0100
    EXPORTING
      i_parent      = go_contain_0100
      i_appl_events = abap_true.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_handler_register
*&---------------------------------------------------------------------*
FORM event_handler_register USING po_grid TYPE REF TO cl_gui_alv_grid.
*& Edit  이벤트 등록
* IF MC_EVT_MODIFY  -> 바로 수정됨.
  CALL METHOD po_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.
*& Event Handler 등록
  CREATE OBJECT go_event_handler.

  SET HANDLER go_event_handler->handle_toolbar
          FOR po_grid.
  SET HANDLER go_event_handler->handle_user_command
          FOR po_grid.
  SET HANDLER go_event_handler->handle_data_changed
          FOR po_grid.
  SET HANDLER go_event_handler->handle_data_changed_finished
          FOR po_grid.
  SET HANDLER go_event_handler->handle_hotspot_click
          FOR po_grid.
  SET HANDLER go_event_handler->handle_double_click
          FOR po_grid.
  SET HANDLER go_event_handler->handle_after_user_command
          FOR po_grid.
  SET HANDLER go_event_handler->handle_button_click
          FOR po_grid.
  SET HANDLER go_event_handler->handle_onf4
          FOR po_grid.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE
          FOR PO_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0100
*&---------------------------------------------------------------------*
FORM set_layout_grid_0100 .
*& GENERAL DISPLAY OPTIONS
  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-CWIDTH_OPT = 'X'.
*  GS_LAYOUT_0100-EDIT      = 'X'.
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
*  GS_LAYOUT_0100-NO_ROWMOVE = ABAP_TRUE.
  GS_LAYOUT_0100-SMALLTITLE = 'X'.             "작은타이틀.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.
  GS_LAYOUT_0100-STYLEFNAME = 'CELLTAB'.       "셀스타일
  GS_LAYOUT_0100-CTAB_FNAME = 'CELLSCOL'.    "셀색상
*  PS_LAYOCAT-EDIT       = 'E'.
*  GS_LAYOUT_0100-NO_ROWMARK = ' '.           "선택버튼 비활성

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0100
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0100 .

    PERFORM set_fieldcat_for_rl.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_FOR_SEND
*&---------------------------------------------------------------------*
FORM set_fieldcat_for_rl .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR2071TOP'
      i_internal_tabname     = 'GS_DISP'
    CHANGING
      ct_fieldcat            = lt_fcat_slis
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat_slis
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0100[]
    TABLES
      it_data         = gt_disp
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT gt_fieldcat_0100 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE <ls_fcat>-fieldname.
      WHEN 'STATUS'.
        <ls_fcat>-coltext = TEXT-f01. "상태
        <ls_fcat>-col_pos = '1'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-edit   = ''.
        <ls_fcat>-just      = 'C'.
      WHEN 'ARBPL'.
        <ls_fcat>-coltext = TEXT-f03.  "설비(작업장)
        <ls_fcat>-col_pos = '2'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-edit   = 'X'.
        <ls_fcat>-just      = 'C'.
        <ls_fcat>-f4availabl = 'X'.
      WHEN 'KTEXT'.
        <ls_fcat>-coltext = TEXT-f04.  "설비(작업장)명
        <ls_fcat>-col_pos = '3'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-edit   = ''.
        <ls_fcat>-just      = 'L'.
      WHEN 'DATUV'.
        <ls_fcat>-coltext = TEXT-f05.   "효력시작일
        <ls_fcat>-col_pos = '4'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-edit   = 'X'.
        <ls_fcat>-just      = 'C'.
      WHEN 'DATUB'.
        <ls_fcat>-coltext = TEXT-f06.  "효력종료일
        <ls_fcat>-col_pos = '5'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-edit   = 'X'.
        <ls_fcat>-just      = 'C'.
      WHEN 'OPTYPE'.
        <ls_fcat>-coltext = TEXT-f07.   "가동유형
        <ls_fcat>-col_pos = '6'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-edit   = 'X'.
        <ls_fcat>-just      = 'C'.
        <ls_fcat>-f4availabl = 'X'.

      WHEN 'OPTYPET'.
        <ls_fcat>-coltext = TEXT-f08.   "가동유형내역
        <ls_fcat>-col_pos = '7'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-edit   = ''.
        <ls_fcat>-just      = 'L'.

      WHEN 'OPRDAY'.
        <ls_fcat>-coltext = TEXT-f09.  "소요일
        <ls_fcat>-col_pos = '8'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-edit   = 'X'.
        <ls_fcat>-just      = 'C'.
      WHEN 'NOPNM'.
        <ls_fcat>-coltext = TEXT-f11.   "비가동내역
        <ls_fcat>-col_pos = '9'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-edit   = 'X'.
        <ls_fcat>-just      = 'L'.

      WHEN OTHERS.
        <ls_fcat>-no_out = abap_true.
    ENDCASE.

  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_cell_attribute_grid_0100
*&---------------------------------------------------------------------*
FORM set_cell_attribute_grid_0100 .

  DATA : lt_cellcol TYPE lvc_t_scol.
  DATA : ls_cellcol TYPE lvc_s_scol.
  DATA : ls_col  TYPE lvc_s_colo. "색상이 임시 저장될 구조체

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
*                cl_gui_alv_grid=>mc_fc_refresh.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_grid_0100_display
*&---------------------------------------------------------------------*
FORM call_grid_0100_display .

*  IF p_layo IS NOT INITIAL.
*    alv_variant-variant = p_layo.
*  ENDIF.
  alv_variant-report = sy-repid.


  CALL METHOD go_grid_0100->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0100
      it_toolbar_excluding = gt_exclude_0100
      is_variant           = alv_variant  " 선택, 메뉴 display
      i_save               = 'U'"'X'
    CHANGING
      it_outtab            = gt_disp
      it_fieldcatalog      = gt_fieldcat_0100.

  IF GO_DD_DOCU_0100 IS BOUND.
    CALL METHOD GO_DD_DOCU_0100->INITIALIZE_DOCUMENT.
  ELSE.
    CREATE OBJECT GO_DD_DOCU_0100
      EXPORTING
        STYLE = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD GO_GRID_0100->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DD_DOCU_0100.


** 인풋이벤트 추가
*  CALL METHOD go_grid_0100->register_edit_event
*    EXPORTING
*      i_event_id = cl_gui_alv_grid=>mc_evt_enter.
*
*  CALL METHOD go_grid_0100->register_edit_event
*    EXPORTING
*      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.
