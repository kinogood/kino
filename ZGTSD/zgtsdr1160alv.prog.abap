*&---------------------------------------------------------------------*
*& Include          ZGTSDR1160ALV
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INIT_CONTROLS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_controls .
  IF go_grid IS NOT INITIAL.
    CALL METHOD go_grid->free.
  ENDIF.
  IF go_gcon1 IS NOT INITIAL.
    CALL METHOD go_gcon1->free.
  ENDIF.
  IF go_gcon2 IS NOT INITIAL.
    CALL METHOD go_gcon2->free.
  ENDIF.
  IF go_ccon IS NOT INITIAL.
    CALL METHOD go_ccon->free.
  ENDIF.
  CLEAR: go_grid,go_ccon,go_gcon1,go_gcon2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_ALV_GRID
*&---------------------------------------------------------------------*
FORM refresh_alv  USING   pc_grid
                         TYPE REF TO cl_gui_alv_grid.
  DATA: ls_stable TYPE lvc_s_stbl.
  ls_stable-row = 'X'.
  ls_stable-col = 'X'.
  IF pc_grid IS NOT INITIAL.
    CALL METHOD pc_grid->refresh_table_display
      EXPORTING
        is_stable = ls_stable.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_changed_data USING pc_grid
                         TYPE REF TO cl_gui_alv_grid.
  DATA lv_valid TYPE char01.

  CALL METHOD pc_grid->check_changed_data
    IMPORTING
      e_valid = lv_valid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_selected_rows USING pc_grid
                               TYPE REF TO cl_gui_alv_grid.
  CLEAR: gt_rows[],gs_rows.
  CALL METHOD pc_grid->get_selected_rows
    IMPORTING
      et_index_rows = gt_rows.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_CONTROLS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_controls .
  IF go_ccon IS INITIAL.

    PERFORM create_container USING go_ccon 'CONT0100'.

    PERFORM create_alv_0100 USING go_ccon
                                  go_grid.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_CONTAINER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_CCON
*&      --> P_
*&---------------------------------------------------------------------*
FORM create_container  USING    po_ccon TYPE REF TO
                                 cl_gui_custom_container
                                p_cont.

  CREATE OBJECT po_ccon
    EXPORTING
      container_name = p_cont.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_CCON
*&      --> GO_GRID
*&---------------------------------------------------------------------*
FORM create_alv_0100  USING  po_ccon TYPE REF TO
                                 cl_gui_custom_container
                               po_grid TYPE REF TO
                                 cl_gui_alv_grid.

  CREATE OBJECT po_grid
    EXPORTING
      i_parent = po_ccon.
*      I_APPL_EVENTS = 'X'.

* Set Variant
  PERFORM set_variant_0100.

* SET LAYOUT
  PERFORM set_layout_0100.

* SET SORT
  PERFORM set_sort_0100.

* SET FIELDCAT
  PERFORM set_fieldcat_0100.

* Set Event Handler
  PERFORM set_event_handler_0100 USING go_grid.

* EXCLUDING TOOLBAR
  CLEAR: gt_exclude[].
  PERFORM exclude_tb_functions_0100 USING 'GT_EXCLUDE'.

* CELL ATTRIBUTES
  PERFORM cell_attributes_0100.

* ALV GRID
  PERFORM display_alv_0100.

* F4
  PERFORM set_f4_0100.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_variant_0100 .
  CLEAR : gs_variant.

  gs_variant-report   = sy-repid.
  gs_variant-username = sy-uname.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_0100 .
  CLEAR: gs_layout.
  gs_layout-zebra        = gc_x.
*  GS_LAYOUT-EDIT         = GC_X.
*  GS_LAYOUT-CWIDTH_OPT   = GC_X.
  gs_layout-sel_mode     = 'D'.      "선택모드
  gs_layout-smalltitle   = gc_x.
*  GS_LAYOUT-GRID_TITLE   = GV_GRID_TITLE.

*  GS_LAYOUT-NO_ROWMARK   = GC_X.      "선택버튼제거.
  gs_layout-stylefname   = 'CELLTAB'.
*  GS_LAYOUT-CTAB_FNAME   = 'CELLCOL'.
*  GS_LAYOUT-INFO_FNAME = 'LINECOL'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_sort_0100 .
  DATA: lv_spos  TYPE slis_spos.
  CLEAR: gt_sort[].

*  CLEAR GS_SORT.
*  LV_SPOS = LV_SPOS + 1.
*  GS_SORT-SPOS = LV_SPOS.
*  GS_SORT-FIELDNAME = 'CRDAT'.
*  GS_SORT-DOWN = GC_X.
*  APPEND GS_SORT TO GT_SORT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_0100 .
  CLEAR: gt_fieldcat[].

  PERFORM create_fieldcat USING 'GT_LIST'
                                gt_fieldcat.

  PERFORM modify_fieldcat_0100 USING gt_fieldcat.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GT_FIELDCAT
*&---------------------------------------------------------------------*
FORM create_fieldcat  USING    p_tabname
                               pt_fieldcat TYPE lvc_t_fcat.
  DATA : lt_fcat TYPE slis_t_fieldcat_alv WITH HEADER LINE.
  DATA : lv_internal_tabname TYPE  slis_tabname,
         lv_structure_name   LIKE  dd02l-tabname,
         lv_inclname         LIKE  trdir-name.

  DATA : lv_table TYPE feld-name.
  FIELD-SYMBOLS <fs_table> TYPE STANDARD TABLE.

  CONCATENATE p_tabname '[]' INTO lv_table.
  ASSIGN (lv_table) TO <fs_table>.

  CLEAR : lv_internal_tabname, lv_inclname.
  lv_internal_tabname = p_tabname.      " 인터널 데이블
  lv_inclname         = |{ sy-repid }TOP|.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name     = sy-repid
      i_internal_tabname = lv_internal_tabname
      i_inclname         = lv_inclname
      i_bypassing_buffer = 'X'
*     I_STRUCTURE_NAME   = I_INTERNAL_TABNAME
    CHANGING
      ct_fieldcat        = lt_fcat[].

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat[]
    IMPORTING
      et_fieldcat_lvc = pt_fieldcat[]
    TABLES
      it_data         = <fs_table>.

  CALL FUNCTION 'LVC_FIELDCAT_COMPLETE'
    EXPORTING
      i_refresh_buffer = 'X'
    CHANGING
      ct_fieldcat      = pt_fieldcat.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIELDCAT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FIELDCAT
*&---------------------------------------------------------------------*
FORM modify_fieldcat_0100  USING   pt_fieldcat TYPE lvc_t_fcat.

  LOOP AT pt_fieldcat INTO gs_fieldcat.
    CASE gs_fieldcat-fieldname.
      WHEN 'STAT'.
        gs_fieldcat-key  = gc_x.
        gs_fieldcat-icon = gc_x.
        gs_fieldcat-just = gc_c.
        gs_fieldcat-outputlen = 3.
        PERFORM set_text USING TEXT-h01.

      WHEN 'ZSEQ'.
        gs_fieldcat-key  = gc_x.
        gs_fieldcat-outputlen = 4.
        PERFORM set_text USING TEXT-h02.
      WHEN 'ZZLABEL_TYPE'.
*        GS_FIELDCAT-EDIT      = GC_X.
        gs_fieldcat-just      = gc_c.
        gs_fieldcat-valexi    = '!'.
        CLEAR gs_fieldcat-rollname.
        gs_fieldcat-outputlen = 5.
        PERFORM set_text USING TEXT-h03.
      WHEN 'ZZLABEL_PRTQT'.
*        GS_FIELDCAT-EDIT      = GC_X.
        gs_fieldcat-just      = gc_c.
        gs_fieldcat-outputlen = 5.
        PERFORM set_text USING TEXT-h04.
      WHEN 'ZZLABEL_TITLE1'.
*        GS_FIELDCAT-EDIT      = GC_X.
        gs_fieldcat-outputlen = 25.
        PERFORM set_text USING TEXT-h05.
      WHEN 'ZZLABEL_TITLE2'.
*        GS_FIELDCAT-EDIT      = GC_X.
        gs_fieldcat-outputlen = 25.
        PERFORM set_text USING TEXT-h06.
      WHEN 'ZZLABEL_TITLE3'.
*        GS_FIELDCAT-EDIT      = GC_X.
        gs_fieldcat-outputlen = 25.
        PERFORM set_text USING TEXT-h07.
      WHEN 'ZZLABEL_TITLE4'.
*        GS_FIELDCAT-EDIT      = GC_X.
        gs_fieldcat-outputlen = 25.
        PERFORM set_text USING TEXT-h08.
      WHEN 'ZPULL_EYE'.
        gs_fieldcat-checkbox  = gc_x.
        gs_fieldcat-just      = gc_c.
        gs_fieldcat-outputlen = 3.
        PERFORM set_text USING TEXT-h10.
      WHEN 'LVORM'.
        gs_fieldcat-checkbox  = gc_x.
        gs_fieldcat-just      = gc_c.
        gs_fieldcat-outputlen = 3.
        PERFORM set_text USING TEXT-h09.
      WHEN OTHERS.
        gs_fieldcat-no_out = gc_x.
    ENDCASE.
    MODIFY pt_fieldcat FROM gs_fieldcat.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TEXT_H00
*&---------------------------------------------------------------------*
FORM set_text  USING    p_text.
  gs_fieldcat-scrtext_s =
  gs_fieldcat-scrtext_m =
  gs_fieldcat-scrtext_l =
  gs_fieldcat-coltext   =
  gs_fieldcat-seltext   =
  gs_fieldcat-tooltip   = p_text.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_HANDLER_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID
*&---------------------------------------------------------------------*
FORM set_event_handler_0100  USING  po_grid TYPE REF TO cl_gui_alv_grid.

  CREATE OBJECT go_event_receiver.

  CALL METHOD po_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD po_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.


  SET HANDLER go_event_receiver->handle_data_changed     FOR po_grid .
  SET HANDLER go_event_receiver->handle_changed_finished FOR po_grid.
*  SET HANDLER GO_EVENT_RECEIVER->HANDLE_SUBTOTAL_TEXT    FOR PO_GRID.
  SET HANDLER go_event_receiver->handle_double_click     FOR po_grid.
  SET HANDLER go_event_receiver->handle_hotspot_click    FOR po_grid.
  SET HANDLER go_event_receiver->handle_toolbar          FOR po_grid.
  SET HANDLER go_event_receiver->handle_user_command     FOR po_grid.
  SET HANDLER go_event_receiver->handle_onf4             FOR po_grid.
*  SET HANDLER GO_EVENT_RECEIVER->HANDLE_TOP_OF_PAGE   FOR PA_GRID.

  IF gv_edit IS NOT INITIAL.
    CALL METHOD po_grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.

  ELSE.
    CALL METHOD po_grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTIONS_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM exclude_tb_functions_0100  USING    p_tabname.
*  툴바의 버튼중 나타내지 않을 버튼을 지정한다.
  FIELD-SYMBOLS : <table> TYPE ui_functions.

  DATA : ls_exclude   TYPE ui_func.
  DATA : l_table_name LIKE feld-name.

  CONCATENATE p_tabname '[]' INTO  l_table_name.
  ASSIGN     (l_table_name)    TO <table>.

  PERFORM append_exclude_functions
        TABLES <table>
*        USING : cl_gui_alv_grid=>mc_fc_excl_all. " ** 툴바 모두제거 **
         USING : cl_gui_alv_grid=>mc_fc_loc_undo, " 실행취소 &LOCAL&UNDO
                cl_gui_alv_grid=>mc_fc_auf,      " 소계확장 &AUF
                cl_gui_alv_grid=>mc_fc_average,  " &AVERAGE
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
                cl_gui_alv_grid=>mc_fc_maximum,
                cl_gui_alv_grid=>mc_fc_minimum,
*                cl_gui_alv_grid=>mc_fc_pc_file,
*                cl_gui_alv_grid=>mc_fc_print,
*                cl_gui_alv_grid=>mc_fc_print_back,
*                cl_gui_alv_grid=>mc_fc_print_prev,
                cl_gui_alv_grid=>mc_fc_refresh,
*                cl_gui_alv_grid=>mc_fc_reprep,
*                cl_gui_alv_grid=>mc_fc_save_variant,
*                cl_gui_alv_grid=>mc_fc_select_all,
*                cl_gui_alv_grid=>mc_fc_send,
*                cl_gui_alv_grid=>mc_fc_separator,
*                CL_GUI_ALV_GRID=>MC_FC_SORT,
                cl_gui_alv_grid=>mc_fc_sort_asc,
                cl_gui_alv_grid=>mc_fc_sort_dsc,
                cl_gui_alv_grid=>mc_fc_subtot,
                cl_gui_alv_grid=>mc_fc_sum.
*                cl_gui_alv_grid=>mc_fc_to_office,
*                cl_gui_alv_grid=>mc_fc_to_rep_tree,
*                cl_gui_alv_grid=>mc_fc_unfix_columns,
*                cl_gui_alv_grid=>mc_fc_views,
*                cl_gui_alv_grid=>mc_fc_view_crystal,
*                cl_gui_alv_grid=>mc_fc_view_excel,
*                cl_gui_alv_grid=>mc_fc_view_grid,
*                cl_gui_alv_grid=>mc_fc_word_processor.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_EXCLUDE_FUNCTIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <TABLE>
*&      --> CL_GUI_ALV_GRID=>MC_FC_LOC_UND
*&---------------------------------------------------------------------*
FORM append_exclude_functions  TABLES p_table
                                USING p_value.
  DATA : ls_exclude TYPE ui_func.
  ls_exclude = p_value.
  APPEND ls_exclude TO p_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv_0100 .
  CALL METHOD go_grid->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout
      is_variant           = gs_variant
      i_save               = 'A'
      it_toolbar_excluding = gt_exclude[]
      i_bypassing_buffer   = 'X'
    CHANGING
      it_outtab            = gt_list[]
      it_fieldcatalog      = gt_fieldcat[]
      it_sort              = gt_sort[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_F4_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_f4_0100 .
* F4 FIELD 등록.
* 주의할점-필드명을 ABC순으로 기술하여야 함
  CLEAR:gt_f4[].

  CLEAR gs_f4.
  gs_f4-fieldname = 'ZTERM'.
  gs_f4-register  = gc_x.
  APPEND gs_f4 TO gt_f4.

  CALL METHOD go_grid->register_f4_for_fields
    EXPORTING
      it_f4 = gt_f4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CELL_ATTRIBUTES_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM cell_attributes_0100 .
  LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<fs_list>).
    PERFORM set_attributes_line CHANGING <fs_list>.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_LINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM set_attributes_line  CHANGING ps_list LIKE gs_list.
  DATA : lt_celltab TYPE lvc_t_styl.
  DATA : ls_celltab TYPE lvc_s_styl.

  CLEAR ps_list-celltab[].

  LOOP AT gt_fieldcat INTO DATA(ls_fcat).
    CLEAR:ls_celltab.
    ls_celltab-fieldname = ls_fcat-fieldname.
    CASE ls_fcat-fieldname.
      WHEN 'ZZLABEL_TYPE'.
*        IF PS_LIST-LVORM IS NOT INITIAL.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
*        ELSE.
*          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*        ENDIF.

      WHEN 'ZZLABEL_PRTQT'.
*        IF PS_LIST-LVORM IS NOT INITIAL.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
*        ELSE.
*          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*        ENDIF.

      WHEN 'ZZLABEL_TITLE1'.
*        IF PS_LIST-LVORM IS NOT INITIAL.
*          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*        ELSE.
        CASE gs_head-zzlabel_type.
          WHEN gc_1.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
          WHEN gc_2.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
          WHEN gc_3.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
          WHEN gc_4.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
          WHEN OTHERS.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
        ENDCASE.
*        ENDIF.

      WHEN 'ZZLABEL_TITLE2'.
*        IF PS_LIST-LVORM IS NOT INITIAL.
*          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*        ELSE.
        CASE gs_head-zzlabel_type.
          WHEN gc_2.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
          WHEN gc_3.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
          WHEN gc_4.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
          WHEN OTHERS.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
        ENDCASE.
*        ENDIF.

      WHEN 'ZZLABEL_TITLE3'.
*        IF PS_LIST-LVORM IS NOT INITIAL.
*          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*        ELSE.
        CASE gs_head-zzlabel_type.
          WHEN gc_3.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
          WHEN gc_4.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
          WHEN OTHERS.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
        ENDCASE.
*        ENDIF.

      WHEN 'ZZLABEL_TITLE4'.
*        IF PS_LIST-LVORM IS NOT INITIAL.
*          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*        ELSE.
        CASE gs_head-zzlabel_type.
          WHEN gc_4.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
          WHEN OTHERS.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
        ENDCASE.
*        ENDIF.

      WHEN 'ZPULL_EYE'.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.

      WHEN OTHERS.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.

    ENDCASE.
    INSERT ls_celltab INTO TABLE lt_celltab.
  ENDLOOP.
  INSERT LINES OF lt_celltab INTO TABLE ps_list-celltab.
ENDFORM.
