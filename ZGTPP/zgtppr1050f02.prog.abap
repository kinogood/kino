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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_proc
*&---------------------------------------------------------------------*
FORM user_command_proc USING pv_ucomm.

*  CASE r_ucomm.
*    WHEN ''.
*  ENDCASE.

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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hotspot_click
*&---------------------------------------------------------------------*
FORM hotspot_click USING pv_row_id     TYPE lvc_s_row
                                     pv_column_id TYPE lvc_s_col.

  CASE pv_column_id-fieldname.

    WHEN 'AUFNR'. "생산 오더

*
*        CLEAR gs_disp.
*        READ TABLE gt_disp INTO gs_disp INDEX pv_row_id-index.
*        SET PARAMETER ID 'ANR' FIELD gs_disp-aufnr.
*        CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
*

  ENDCASE.

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
FORM onf4_proc USING pv_fieldname   TYPE lvc_fname
                                 pv_fieldvalue  TYPE lvc_value
                                 ps_row_no     TYPE lvc_s_roid
                                 pr_event_data TYPE REF TO cl_alv_event_data
                                 pt_bad_cells  TYPE lvc_t_modi
                                 pv_display     TYPE char01.

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
      rows    = 1
      columns = 1.
* top 컨테이너
  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_contain_0100.
** bottom 컨테이너
*  CALL METHOD GO_SPLITTER->GET_CONTAINER
*    EXPORTING
*      ROW       = 2
*      COLUMN    = 1
*    RECEIVING
*      CONTAINER = GO_CONTAIN_0101.

  CREATE OBJECT go_grid_0100
    EXPORTING
      i_parent      = go_contain_0100
      i_appl_events = abap_true.

*  CREATE OBJECT go_grid_0101
*    EXPORTING
*      i_parent      = go_contain_0101
*      i_appl_events = abap_true.

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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0100
*&---------------------------------------------------------------------*
FORM set_layout_grid_0100 .
*& General display options
  CLEAR gs_layout_0100.
  gs_layout_0100-cwidth_opt = 'X'.
  gs_layout_0100-no_rowins = abap_true.
*  GS_LAYOUT_0100-NO_ROWMOVE = ABAP_TRUE.
  gs_layout_0100-smalltitle = 'X'.             "작은타이틀.
  gs_layout_0100-sel_mode   = 'D'.
  gs_layout_0100-stylefname = 'CELLTAB'.       "셀스타일
  gs_layout_0100-ctab_fname = 'CELLSCOL'.    "셀색상
*  ps_layocat-edit       = 'E'.
*  gs_layout_0100-no_rowmark = ' '.           "선택버튼 비활성


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
      i_inclname             = 'ZGTPPR1050TOP'
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
      WHEN 'ZSTAT'.
        <ls_fcat>-coltext = TEXT-f01. "처리상태
        <ls_fcat>-col_pos = '1'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'.
      WHEN 'ZMESSAGE'.
        <ls_fcat>-coltext = TEXT-f02.  "메시지
        <ls_fcat>-col_pos = '2'.
        <ls_fcat>-no_out = ' '.
*        <ls_fcat>-hotspot = 'X'.
        <ls_fcat>-just      = 'L'.
      WHEN 'MATNR'.
        <ls_fcat>-coltext = TEXT-f03.  "품목코드
        <ls_fcat>-col_pos = '3'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'.
      WHEN 'MAKTX'.
        <ls_fcat>-coltext = TEXT-f04.  "품목내역
        <ls_fcat>-col_pos = '4'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'.
      WHEN 'WERKS'.
        <ls_fcat>-coltext = TEXT-f05.   "플렌트
        <ls_fcat>-col_pos = '5'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'.
      WHEN 'NAME1'.
        <ls_fcat>-coltext = TEXT-f06.   "플렌트내역
        <ls_fcat>-col_pos = '6'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'.

      WHEN 'BESKZ'.
        <ls_fcat>-coltext = TEXT-f27.  "조달유형
        <ls_fcat>-col_pos = '7'.
        <ls_fcat>-no_out = ' '.
*        <ls_fcat>-hotspot = 'X'.
        <ls_fcat>-just      = 'C'.
      WHEN 'SOBSL'.
        <ls_fcat>-coltext = TEXT-f28.  "특별조달
        <ls_fcat>-col_pos = '8'.
        <ls_fcat>-no_out = ' '.
*        <ls_fcat>-hotspot = 'X'.
        <ls_fcat>-just      = 'C'.


      WHEN 'VERID'.
        <ls_fcat>-coltext = TEXT-f07.  "생산버전
        <ls_fcat>-col_pos = '9'.
        <ls_fcat>-no_out = ' '.
*        <ls_fcat>-hotspot = 'X'.
        <ls_fcat>-just      = 'C'.
      WHEN 'TEXT1'.
        <ls_fcat>-coltext = TEXT-f08.  "생산버젼내역
        <ls_fcat>-col_pos = '10'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'.
      WHEN 'ADATU'.
        <ls_fcat>-coltext = TEXT-f09.   "효력시작일
        <ls_fcat>-col_pos = '11'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'.
      WHEN 'BDATU'.
        <ls_fcat>-coltext = TEXT-f10.   "효력종료일
        <ls_fcat>-col_pos = '12'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'.
      WHEN 'STLAN'.
        <ls_fcat>-coltext = TEXT-f11. "BOM 용도
        <ls_fcat>-col_pos = '13'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'.
      WHEN 'STLAL'.
        <ls_fcat>-coltext = TEXT-f12.  "대체 BOM
        <ls_fcat>-col_pos = '14'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'.
      WHEN 'STLST'.
        <ls_fcat>-coltext = TEXT-f13.  " BOM  상태
        <ls_fcat>-col_pos = '15'.
        <ls_fcat>-no_out = 'X'.
        <ls_fcat>-just      = 'C'.
      WHEN 'PLNNR'.
        <ls_fcat>-coltext = TEXT-f14.   "그룹번호
        <ls_fcat>-col_pos = '16'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'.
      WHEN 'PLNTY'.
        <ls_fcat>-coltext = TEXT-f15.  "테스트 리스트 유형
        <ls_fcat>-col_pos = '17'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'.
      WHEN 'ALNAL'.
        <ls_fcat>-coltext = TEXT-f16.  "그룹카운터
        <ls_fcat>-col_pos = '18'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'.
      WHEN 'PRFG_S'.
        <ls_fcat>-coltext = TEXT-f17.  "BOM 점검
        <ls_fcat>-col_pos = '19'.
        <ls_fcat>-no_out = 'X'.
        <ls_fcat>-just      = 'C'.
      WHEN 'PRFG_S_ICON'.
        <ls_fcat>-coltext = TEXT-f17.  "BOM 점검 ICON
        <ls_fcat>-col_pos = '20'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'.
      WHEN 'PRFG_F'.
        <ls_fcat>-coltext = TEXT-f18.  "라우팅 점검
        <ls_fcat>-col_pos = '21'.
        <ls_fcat>-no_out = 'X'.
        <ls_fcat>-just      = 'C'.
      WHEN 'PRFG_F_ICON'.
        <ls_fcat>-coltext = TEXT-f18.  "라우팅 점검 ICON
        <ls_fcat>-col_pos = '22'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'.
      WHEN 'PRDAT'.
        <ls_fcat>-coltext = TEXT-f19.  "최종 점검 일자
        <ls_fcat>-col_pos = '23'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'.

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


    LOOP AT gt_disp1 INTO gs_disp.
      REFRESH lt_cellcol.

*      IF gs_disp-zclass <>  '적정투입'.
*        ls_cellcol-fname = 'ZCLASS'.
*        ls_cellcol-color-col = '6'.
*        ls_cellcol-color-int = '0'.
*        ls_cellcol-color-inv = '0'.
*        ls_cellcol-nokeycol  = ' '.
*        INSERT ls_cellcol INTO TABLE lt_cellcol.
*
*        ls_cellcol-fname = 'ZQTYDIF'.
*        ls_cellcol-color-col = '6'.
*        ls_cellcol-color-int = '0'.
*        ls_cellcol-color-inv = '0'.
*        ls_cellcol-nokeycol  = ' '.
*        INSERT ls_cellcol INTO TABLE lt_cellcol.
*
*        ls_cellcol-fname = 'ZGIRATE'.
*        ls_cellcol-color-col = '6'.
*        ls_cellcol-color-int = '0'.
*        ls_cellcol-color-inv = '0'.
*        ls_cellcol-nokeycol  = ' '.
*        INSERT ls_cellcol INTO TABLE lt_cellcol.
*
*        ls_cellcol-fname = 'ZGIRATE_D'.
*        ls_cellcol-color-col = '6'.
*        ls_cellcol-color-int = '0'.
*        ls_cellcol-color-inv = '0'.
*        ls_cellcol-nokeycol  = ' '.
*        INSERT ls_cellcol INTO TABLE lt_cellcol.
*
*        INSERT LINES OF lt_cellcol INTO TABLE gs_disp-cellScol.
*
*        MODIFY gt_disp1 FROM gs_disp.
*      ENDIF.

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
*                cl_gui_alv_grid=>mc_fc_refresh.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_grid_0100_display
*&---------------------------------------------------------------------*
FORM call_grid_0100_display .

  IF p_layo IS NOT INITIAL.
    alv_variant-variant = p_layo.
  ENDIF.
  alv_variant-report = sy-repid.

    CALL METHOD go_grid_0100->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_0100
        it_toolbar_excluding = gt_exclude_0100
        is_variant           = alv_variant  " 선택, 메뉴 display
        i_save               = 'X'
      CHANGING
        it_outtab            = gt_disp
        it_fieldcatalog      = gt_fieldcat_0100.



* 인풋이벤트 추가
  CALL METHOD go_grid_0100->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD go_grid_0100->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.
