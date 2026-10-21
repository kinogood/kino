*&---------------------------------------------------------------------*
*& Include          ZGTPPR2060F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_SELECTION_PERIOD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_selection_period .

* 판매계획 수립월 - 디폴드값 현재월 - 3개월 ~ 현재월
  CHECK s_spmon[] IS INITIAL AND s_spmon IS INITIAL.

  s_spmon-sign = 'I'.
  s_spmon-option = 'EQ'.
*
*  CALL FUNCTION '/BEV4/PLPS__ADD_MONTH_TO_DATE'
*    EXPORTING
*      MONTHS  = '-3'
*      OLDDATE = SY-DATUM
*    IMPORTING
*      NEWDATE = GV_CHK_DATE.
*  S_SPMON-LOW = GV_CHK_DATE+0(6).

*  CALL FUNCTION '/BEV4/PLPS__ADD_MONTH_TO_DATE'
*    EXPORTING
*      MONTHS  = '3'
*      OLDDATE = SY-DATUM
*    IMPORTING
*      NEWDATE = GV_CHK_DATE.
  s_spmon-low = sy-datum+0(6).
  s_spmon-high = sy-datum+0(6).

  APPEND s_spmon.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PARAMETER_DESCRIPTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_parameter_description .

* SPG
  IF NOT p_spgcd IS INITIAL.
    SELECT SINGLE descr INTO p_descr
             FROM zppt0107
            WHERE spgcd EQ p_spgcd.
  ELSE.
    CLEAR p_descr.
  ENDIF.

* 플랜트명
  IF NOT p_werks IS INITIAL.
    SELECT SINGLE name1 INTO p_name1
             FROM t001w
            WHERE werks EQ p_werks.
  ELSE.
    CLEAR p_name1.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIRST_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_first_screen .

  LOOP AT SCREEN.
    IF screen-group1 = 'M1'.
      screen-input = 0.
      screen-intensified = 1.
      MODIFY SCREEN.
    ENDIF.
    IF screen-group1 = 'M2'.
      screen-input = 0.
      screen-intensified = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form TOOLBAR_PROS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM toolbar_pros  USING  po_sender
                          po_object TYPE REF TO cl_alv_event_toolbar_set
                          r_interactive.

* 2026.01.27.zlsgpp5.CHM2601-00657.자재코드 연결 툴바 추가.
  CASE po_sender.
    WHEN go_grid_0100.
      PERFORM set_toolbar TABLES po_object->mt_toolbar
                          USING: 'CREATE'   icon_create      '신규대상 생성' '신규대상 생성' 0,
                                 'APPEND'   icon_create_text '기존대상 추가' '기존대상 추가' 0,
                                 'SIMILAR'  icon_wf_link     '(유사)자재코드 연결' '자재코드 연결' 0.
    WHEN go_grid_0200.
      PERFORM set_toolbar TABLES po_object->mt_toolbar
                          USING: 'DELETE'   icon_delete '판매계획 제외' '판매계획 제외' 0,
                                 'SAVE'     icon_set_state '수정사항 저장' '수정사항 저장' 0.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> PO_OBJECT_>MT_TOOLBAR
*&---------------------------------------------------------------------*
FORM set_toolbar  TABLES  pt_toolbar STRUCTURE stb_button
               USING    pv_function
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
*& Form USER_COMMAND_PROS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM user_command_pros  USING    po_sender  TYPE REF TO cl_gui_alv_grid
                                 pv_ucomm.

* 2026.01.27.zlsgpp5.CHM2601-00657.(유사)자재코드 연결 툴바 추가.
  CASE po_sender.
    WHEN go_grid_0100.
      CASE pv_ucomm.
        WHEN 'CREATE'.
          PERFORM create_mp_datas.
        WHEN 'APPEND'.
          PERFORM append_mp_data.
        WHEN 'SIMILAR'.
          PERFORM get_similar_matnr.
      ENDCASE.
    WHEN go_grid_0200.
      CASE pv_ucomm.
        WHEN 'DELETE'.
          PERFORM delete_mp_datas.
        WHEN 'SAVE'.
          PERFORM save_mp_datas.
      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> ER_DATA_CHANGED
*&      --> E_ONF4
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM data_changed  USING    p_sender  TYPE REF TO cl_gui_alv_grid
                                po_data_changed TYPE REF TO
                                          cl_alv_changed_data_protocol
                                pe_onf4
                                pe_ucomm.

  DATA: ls_mod_cells TYPE lvc_s_modi.
  DATA : lv_meins TYPE meins.
  DATA : lv_sul TYPE zesul_no.
  DATA : lv_fieldname TYPE fieldname.
  DATA : lv_chk_err.

  DEFINE __set_err_msg.
    lv_chk_err = abap_true.
    po_data_changed->add_protocol_entry(
        i_msgid     = 'ZGTPP00'                 " Message ID
        i_msgty     = 'E'                 " Message Type
        i_msgno     =  '03'                " Message No.
        i_msgv1     =  &1                " Message Variable1
        i_fieldname =  &2                " Field Name
        i_row_id    =  ls_mod_cells-row_id ).                " RowID
  END-OF-DEFINITION.

  DEFINE __modi_cell.
    po_data_changed->modify_cell(
      i_row_id     = &1                 " Row ID
      i_fieldname = &2                 " Field Name
      i_value       = &3 ).               " Value
  END-OF-DEFINITION.

  CASE p_sender.
    WHEN go_grid_0200.
      LOOP AT po_data_changed->mt_good_cells INTO ls_mod_cells.
        CASE ls_mod_cells-fieldname.
          WHEN 'MATNR'.
            CLEAR : lv_meins, lv_sul.
            PERFORM chk_matnr_available USING ls_mod_cells-value CHANGING lv_meins lv_sul lv_chk_err.
            IF lv_chk_err IS NOT INITIAL.
              __set_err_msg '유효하지 않은 완제품 코드입니다.'(e04) 'MATNR'.
              CONTINUE.
            ENDIF.

            gv_chk_edit = abap_true.
            __modi_cell ls_mod_cells-row_id 'CHECK' icon_change.

            READ TABLE <gt_main_disp_200> ASSIGNING FIELD-SYMBOL(<ls_main>) INDEX ls_mod_cells-row_id.

            IF lv_meins IS NOT INITIAL.
              ASSIGN COMPONENT 'MEINS' OF STRUCTURE <ls_main> TO FIELD-SYMBOL(<lv_meins>).
              IF lv_meins NE <lv_meins>.
                __modi_cell ls_mod_cells-row_id 'MEINS' lv_meins.

                LOOP AT gt_spmon INTO gs_spmon.
* 판매 계획 단위수량 적용하여 수량 컨버젼
                  CLEAR lv_fieldname.
                  lv_fieldname = gs_spmon-spmon && '_SO'.
                  ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main> TO FIELD-SYMBOL(<lv_so_unit>).
                  IF <lv_so_unit> NE 0.
                    PERFORM translate_unit_quantity USING <lv_meins> lv_meins <lv_so_unit> CHANGING <lv_so_unit>.
                    __modi_cell ls_mod_cells-row_id lv_fieldname <lv_so_unit>.
                  ENDIF.

* 생산 계획 단위수량 적용하여 수량 컨버젼
                  CLEAR lv_fieldname.
                  lv_fieldname = gs_spmon-spmon && '_PO'.
                  ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main> TO FIELD-SYMBOL(<lv_po_unit>).
                  IF <lv_po_unit> NE 0.
                    __modi_cell ls_mod_cells-row_id lv_fieldname <lv_po_unit>.
                  ENDIF.
                ENDLOOP.
              ENDIF.
            ENDIF.

            IF lv_sul IS NOT INITIAL.
              __modi_cell ls_mod_cells-row_id 'SUL_NO' lv_sul.
            ENDIF.
          WHEN 'ALENR'.
            gv_chk_edit = abap_true.
            __modi_cell ls_mod_cells-row_id 'CHECK' icon_change.

        ENDCASE.
      ENDLOOP.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM double_click  USING    p_sender TYPE REF TO cl_gui_alv_grid
                            p_row TYPE lvc_s_row
                            p_column TYPE lvc_s_col.

  CASE p_sender.
    WHEN go_grid_0100.
      CASE p_column-fieldname.
        WHEN 'STAT_T'.
          READ TABLE gt_main INTO DATA(ls_main) INDEX p_row-index.
          IF ls_main-stat_t EQ '조장구성'.
            SET PARAMETER ID 'WRK' FIELD p_werks.
            SET PARAMETER ID 'ZSPG' FIELD p_spgcd.
            SET PARAMETER ID 'AUN' FIELD ls_main-vbeln.

            CALL TRANSACTION 'ZGTPPR2050'AND SKIP FIRST SCREEN.

            SET PARAMETER ID 'AUN' FIELD space.

          ENDIF.
        WHEN 'VBELN' OR 'POSNR'.
          READ TABLE gt_main INTO ls_main INDEX p_row-index.
          IF ls_main-vbeln IS NOT INITIAL.
            SET PARAMETER ID 'AUN' FIELD ls_main-vbeln.
            CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

            SET PARAMETER ID 'AUN' FIELD space.
          ENDIF.
      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM alv_top_of_page  USING    po_sender TYPE REF TO cl_gui_alv_grid
                               pv_dyndoc_id  TYPE REF TO  cl_dd_document.

  CASE po_sender.
    WHEN go_grid_0100.
      PERFORM set_title_0100 CHANGING pv_dyndoc_id.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECKING_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM authority_checking_proc .

*& 플랜트에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
  ID 'WERKS'  FIELD p_werks.

  IF sy-subrc <> 0.
    "플랜트[P_WERKS] 작업권한을 확인하세요.
    MESSAGE e006 WITH TEXT-m01 p_werks TEXT-m03.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_process.
  PERFORM set_init_week_ranges.
* main screen(판매계획)
  PERFORM get_main_data USING 'S'.
*  Detail(월간생산계획 대상)
  PERFORM set_ranges_spmon.
  PERFORM make_disp_table_200.
  PERFORM get_main_200 TABLES gt_2080.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM disp_process .

  CALL SCREEN '0100'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
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
      rows    = 3
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

  CALL METHOD go_splitter_0100->get_container
    EXPORTING
      row       = 3
      column    = 1
    RECEIVING
      container = go_contain_0200.

  PERFORM set_screeen_expend USING 'D'.

  CREATE OBJECT go_grid_0100
    EXPORTING
      i_parent      = go_contain_0100
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM event_handler_register  USING    po_grid TYPE REF TO cl_gui_alv_grid.

  IF go_event_handler IS NOT BOUND.
    CREATE OBJECT go_event_handler.
  ENDIF.

*// Event Handler ##
  CASE po_grid.
    WHEN go_grid_0100.
      SET HANDLER go_event_handler->handle_top_of_page          FOR po_grid.
      SET HANDLER go_event_handler->handle_toolbar               FOR po_grid.
      SET HANDLER go_event_handler->handle_user_command          FOR po_grid.
      SET HANDLER go_event_handler->handle_double_click          FOR po_grid.
    WHEN go_grid_0200.
      SET HANDLER go_event_handler->handle_toolbar               FOR po_grid.
      SET HANDLER go_event_handler->handle_user_command          FOR po_grid.
      SET HANDLER go_event_handler->handle_data_changed          FOR po_grid.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_grid_0100 .

  CLEAR gs_layout_0100.
  gs_layout_0100-cwidth_opt = abap_true.
  gs_layout_0100-no_rowins = abap_true.
  gs_layout_0100-stylefname = 'CELLTAB'.
  gs_layout_0100-no_rowmark  = abap_true.
  gs_layout_0100-sel_mode  = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_cell_attribute_grid_0100 .

  DATA : lt_celltab TYPE lvc_t_styl.
  DATA : ls_celltab TYPE lvc_s_styl.
  FIELD-SYMBOLS <lt_celltab> TYPE any.

  LOOP AT gt_main ASSIGNING FIELD-SYMBOL(<ls_data>).
    REFRESH lt_celltab.

    CASE <ls_data>-stat_t.
      WHEN '대상선정'.
        CLEAR ls_celltab.
        ls_celltab-fieldname = 'STAT_T'.
        ls_celltab-style = alv_style_color_positive.
        INSERT ls_celltab INTO TABLE lt_celltab.
      WHEN '조장구성'.
        CLEAR ls_celltab.
        ls_celltab-fieldname = 'STAT_T'.
        ls_celltab-style = alv_style_color_total.
        INSERT ls_celltab INTO TABLE lt_celltab.
*      WHEN OTHERS. "2026.01.27.zlsgpp5.주석처리.
*        CONTINUE.  "2026.01.27.zlsgpp5.주석처리.
    ENDCASE.

    "/s 2026.01.27.zlsgpp5.CHM2601-00657.자재코드 필드 색 설정.
    CASE <ls_data>-matnr_color.
      WHEN 'G'. "green.
        CLEAR ls_celltab.
        ls_celltab-fieldname = 'MATNR'.
        ls_celltab-style = alv_style_color_positive.
        INSERT ls_celltab INTO TABLE lt_celltab.
      WHEN 'Y'. "yellow
        CLEAR ls_celltab.
        ls_celltab-fieldname = 'MATNR'.
        ls_celltab-style = alv_style_color_total.
        INSERT ls_celltab INTO TABLE lt_celltab.
    ENDCASE.

    CHECK lt_celltab[] IS NOT INITIAL.
    "/e 2026.01.27.zlsgpp5.CHM2601-00657.자재코드 필드 색 설정.

    IF <lt_celltab> IS ASSIGNED. UNASSIGN <lt_celltab>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <ls_data> TO <lt_celltab>.
    IF <lt_celltab> IS ASSIGNED.
      <lt_celltab> = lt_celltab.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
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
                cl_gui_alv_grid=>mc_fc_loc_paste_new_row,
                cl_gui_alv_grid=>mc_fc_refresh.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*-----------------------------------------------------------------------
**
FORM add_exclude_toolbar_button  TABLES   p_table
                                 USING    p_value.
  DATA: l_exclude TYPE ui_func.
  l_exclude = p_value.
  APPEND l_exclude TO p_table.
ENDFORM.                    " add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_sorttab_grid_0100 .

* ALV소트 사용 안함.
*  PERFORM SET_SORT_TAB TABLES GT_SORT_0100
*                                  USING : 1 'BASEMONTH'  'X' '' '',
*                                             2 'ITEMNAME'  'X' '' '',
*                                             3 'ZPJNO'  'X' '' ''.

*  SORT GT_MAIN BY BASEMONTH ITEMNAME ZPJNO VBELN POSNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_sort_tab
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SORT_0100
*&      --> P_1
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_sort_tab  TABLES   pt_sorttab STRUCTURE lvc_s_sort
                   USING    pv_pos
                               pv_fieldname
                               pv_up
                               pv_down
                               pv_subtot.

  DATA : ls_sort TYPE lvc_s_sort.
  ls_sort-spos = pv_pos.
  ls_sort-fieldname = pv_fieldname.
  ls_sort-up = pv_up.
  ls_sort-down = pv_down.
  ls_sort-subtot =  pv_subtot.
  APPEND ls_sort TO pt_sorttab.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0100_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0100_display .

  CALL METHOD go_grid_0100->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0100
      it_toolbar_excluding = gt_exclude_0100
    CHANGING
      it_outtab            = gt_main
*     IT_SORT              = GT_SORT_0100
      it_fieldcatalog      = gt_fieldcat_0100.

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
*& Form SET_TITLE_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PV_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM set_title_0100  CHANGING pv_dyndoc_id  TYPE REF TO  cl_dd_document.

  DATA : lv_text(255) TYPE c.
  DATA : lv_name1 TYPE t001w-name1.
  DATA : lv_descr TYPE zppt0107-descr.
  DATA : lv_bgn_spmon TYPE char10.
  DATA : lv_end_spmon TYPE char10.

* 플랜트
  SELECT SINGLE name1 INTO lv_name1
           FROM t001w
          WHERE werks EQ p_werks.

  CONCATENATE '플랜트 :' p_werks ', ' lv_name1 INTO lv_text SEPARATED BY space.

  "텍스트 추가
  CALL METHOD pv_dyndoc_id->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = '20'.

  CALL METHOD pv_dyndoc_id->new_line.

*-제품군
  CLEAR lv_text.

  IF p_spgcd IS NOT INITIAL.
    SELECT SINGLE descr INTO lv_descr
             FROM zppt0107
            WHERE spgcd EQ p_spgcd.
  ENDIF.

  CONCATENATE 'SPG :' p_spgcd ', ' lv_descr INTO lv_text SEPARATED BY space.

  "텍스트 추가
  CALL METHOD pv_dyndoc_id->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = '20'.

  CALL METHOD pv_dyndoc_id->new_line.

*-판매계획월
  CLEAR lv_text.
  READ TABLE s_spmon INDEX 1.
  lv_bgn_spmon = s_spmon-low+0(4) && '.' && s_spmon-low+4(2).
  lv_end_spmon = s_spmon-high+0(4) && '.' && s_spmon-high+4(2).

  CONCATENATE '판매계획 수립월 :' lv_bgn_spmon '~' lv_end_spmon INTO lv_text SEPARATED BY space.

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
*& Form SET_FIELDCAT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0100 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR2060TOP'
      i_internal_tabname     = 'GS_MAIN'
    CHANGING
      ct_fieldcat            = lt_fcat_slis
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  REFRESH gt_fieldcat_0100.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat_slis
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0100[]
    TABLES
      it_data         = gt_main
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE gt_fieldcat_0100 TRANSPORTING NO FIELDS WITH KEY fieldname = 'STAT_T'.
  IF sy-subrc NE 0.
    APPEND INITIAL LINE TO gt_fieldcat_0100 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    <ls_fcat>-fieldname = 'STAT_T'.
    <ls_fcat>-reptext = '상태'(f01).
    <ls_fcat>-col_pos = 1.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-dd_outlen = '10'.
    <ls_fcat>-just = 'C'.
    <ls_fcat>-key = abap_true.
  ENDIF.

  LOOP AT gt_fieldcat_0100 ASSIGNING <ls_fcat>.
    CLEAR <ls_fcat>-key.
    CASE   <ls_fcat>-fieldname.
      WHEN 'DPID' OR 'CYCLTYPE' OR 'VKBUR' OR 'PLTYPE'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'STAT_T'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '상태'(f01).
        <ls_fcat>-just = 'C'.
      WHEN 'BASEMONTH'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매계획월'(f02).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'C'.
      WHEN 'ITEMNAME'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '규격'(f03).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'L'.
      WHEN 'ZPJNO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '프로젝트 No.'(f04).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'C'.
      WHEN 'ZPTXT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '프로젝트 내역'(f22).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'L'.
      WHEN 'KUNNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매처코드'(f05).
        <ls_fcat>-just = 'C'.
      WHEN 'NAME1'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매처명'(f06).
        <ls_fcat>-just = 'L'.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '완제품 코드'(f07).
        <ls_fcat>-just = 'C'.
      WHEN 'SUL_NO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '설계번호'(f08).
        <ls_fcat>-just = 'C'.
      WHEN 'VRKME'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매단위'(f09).
        <ls_fcat>-just = 'C'.
      WHEN 'QUANTITY_DP'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매수량'(f10).
        <ls_fcat>-just = 'R'.
        <ls_fcat>-qfieldname = 'VRKME'.
      WHEN 'MEINS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '생산단위'(f11).
        <ls_fcat>-just = 'C'.
      WHEN 'MENGE'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '생산수량'(f13).
        <ls_fcat>-no_out = abap_true.
        <ls_fcat>-just = 'R'.
        <ls_fcat>-qfieldname = 'MEINS'.
      WHEN 'MENGE2'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '환산수량'(f12).
        <ls_fcat>-just = 'R'.
        <ls_fcat>-qfieldname = 'VRKME'.
      WHEN 'OPPSTATUS'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'DDTEXT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '영업기회상태'(f14).
        <ls_fcat>-just = 'C'.
      WHEN 'DPTYPE'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '유형'(f15).
        <ls_fcat>-just = 'C'.
      WHEN 'SPART'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '제품군'(f16).
        <ls_fcat>-just = 'C'.
      WHEN 'VBELN'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매오더'(f17).
        <ls_fcat>-just = 'C'.
      WHEN 'POSNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '오더품목'(f18).
        <ls_fcat>-just = 'C'.
      WHEN 'BUNAME'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '팀명'(f19).
        <ls_fcat>-just = 'L'.
      WHEN 'PERNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '담당자'(f20).
        <ls_fcat>-just = 'C'.
      WHEN 'MATNR_COLOR'. "2026.01.27.zlsgpp5.add.
        <ls_fcat>-tech = 'X'.
    ENDCASE.

    IF <ls_fcat>-fieldname CP 'ATTR*'. "2026.01.27.zlsgpp5.add.
      <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = |속성{ <ls_fcat>-fieldname+4(2) }|.
      <ls_fcat>-just = 'C'.
      <ls_fcat>-no_out = 'X'.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_MP_DATAS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_mp_datas .

  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : lt_main LIKE TABLE OF gs_main.
  DATA : lt_main_sorted LIKE TABLE OF gs_main.
  DATA : lv_num(4) TYPE n.
  DATA : lv_chk_plnid TYPE zgtppt2080-plnid.
  DATA : lt_save_2080 TYPE TABLE OF zgtppt2080.
  DATA : lt_save_2080_tot TYPE TABLE OF zgtppt2080.
  DATA : BEGIN OF ls_chk_matnr,
           basemonth TYPE spmon,
           matnr     TYPE matnr,
           sul_no    TYPE zgtppt2080-sul_no,
           meins     TYPE meins,
         END OF ls_chk_matnr.

  IF gv_chk_edit IS NOT INITIAL.
    CLEAR gv_answer.
    PERFORM popup_to_confirm_step USING 'N'
      ' '
      '수정중인 완제품코드가 초기화 됩니다. 계속 진행 하시겠습니까?'
      '작업확인'.
    IF gv_answer NE 'J'.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  go_grid_0100->get_selected_cells_id(
      IMPORTING
       et_cells = lt_cells ).                " Cell IDs

  DELETE lt_cells WHERE row_id = 0.

  IF lt_cells[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '선택된 Cell이 없습니다.'(e01).
    RETURN.
  ENDIF.

  SORT lt_cells BY row_id.
  DELETE ADJACENT DUPLICATES FROM lt_cells COMPARING row_id.

  LOOP AT lt_cells INTO DATA(ls_cells).
    READ TABLE gt_main INTO gs_main INDEX ls_cells-row_id.
    IF gs_main-stat_t IS INITIAL.
      APPEND gs_main TO lt_main.
    ENDIF.
  ENDLOOP.

*___2026.01.29.zlsgpp5.CHM2601-00657.합계된 경우 사용자가 품목 선택.
  PERFORM call_screen_0400 CHANGING lt_main.


  IF lt_main[] IS INITIAL.
    MESSAGE s005 DISPLAY LIKE 'E' WITH  '신규 월간 생산 계획 대상으로'
                                        '선정될 판매계획이 선택되지 않았습니다.'.
    RETURN.
  ENDIF.

  CLEAR gv_answer.
  PERFORM popup_to_confirm_step USING 'N'
    ' '
    '월간생산계획 생성합니다. 계속 진행 하시겠습니까?'
    '생성확인'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  lt_main_sorted[] = lt_main[].
  SORT lt_main_sorted BY cycltype vkbur itemname zpjno.
  DELETE ADJACENT DUPLICATES FROM lt_main_sorted COMPARING cycltype vkbur itemname zpjno.

  LOOP AT lt_main_sorted INTO DATA(ls_main_sorted).

* 월간 생산 계획 ID 채번
    CLEAR lv_num.
    lv_chk_plnid = 'MP' && p_spgcd && sy-datum+2(4) && '%'.
    SELECT SINGLE MAX( plnid ) AS plnid
      FROM zgtppt2080
      WHERE werks = @p_werks
        AND spgcd = @p_spgcd
        AND plnid LIKE @lv_chk_plnid
      GROUP BY werks, spgcd
      INTO @DATA(lv_plnid).
    IF sy-subrc EQ 0.
      lv_num = lv_plnid+8(4) + 1.
    ELSE.
      lv_num = 1.
    ENDIF.

    CLEAR ls_chk_matnr.
    LOOP AT lt_main INTO DATA(ls_main) WHERE cycltype = ls_main_sorted-cycltype
                                         AND vkbur = ls_main_sorted-vkbur
                                         AND itemname = ls_main_sorted-itemname
                                         AND zpjno = ls_main_sorted-zpjno.
      APPEND INITIAL LINE TO lt_save_2080 ASSIGNING FIELD-SYMBOL(<ls_save_2080>).
      <ls_save_2080>-plnid = lv_chk_plnid+0(8) && lv_num.
      <ls_save_2080>-werks = p_werks.
      <ls_save_2080>-spgcd = p_spgcd.
      <ls_save_2080>-pltype = ls_main-pltype.
      <ls_save_2080>-vkbur = ls_main-vkbur.
      <ls_save_2080>-cycltype = ls_main-cycltype.
      <ls_save_2080>-spec = ls_main-itemname.
      <ls_save_2080>-zpjno = ls_main-zpjno.
      <ls_save_2080>-vbeln = ls_main-vbeln.
      <ls_save_2080>-posnr = ls_main-posnr.
      <ls_save_2080>-pltype = ls_main-pltype.
      <ls_save_2080>-matnr = ls_main-matnr.
      <ls_save_2080>-sul_no = ls_main-sul_no.
      <ls_save_2080>-meins = ls_main-meins.
      IF ls_chk_matnr-basemonth < ls_main-basemonth.
        ls_chk_matnr-basemonth =  ls_main-basemonth.
        IF ls_chk_matnr-matnr IS INITIAL.
          ls_chk_matnr-matnr = ls_main-matnr.
          ls_chk_matnr-meins = ls_main-meins.
          ls_chk_matnr-sul_no = ls_main-sul_no.
        ELSE.
          IF ls_main-matnr IS NOT INITIAL.
            ls_chk_matnr-matnr = ls_main-matnr.
            ls_chk_matnr-meins = ls_main-meins.
            ls_chk_matnr-sul_no = ls_main-sul_no.
          ENDIF.
        ENDIF.
      ELSEIF ls_chk_matnr-basemonth = ls_main-basemonth.
        IF ls_chk_matnr-matnr IS INITIAL.
          ls_chk_matnr-matnr = ls_main-matnr.
          ls_chk_matnr-meins = ls_main-meins.
          ls_chk_matnr-sul_no = ls_main-sul_no.
        ENDIF.
      ENDIF.

    ENDLOOP.

    IF ls_chk_matnr-matnr IS NOT INITIAL.
      LOOP AT lt_save_2080 ASSIGNING <ls_save_2080>.
        <ls_save_2080>-matnr = ls_chk_matnr-matnr.
        <ls_save_2080>-meins = ls_chk_matnr-meins.
        <ls_save_2080>-sul_no = ls_chk_matnr-sul_no.
      ENDLOOP.
    ENDIF.

    IF lt_save_2080 IS NOT INITIAL.
      MODIFY zgtppt2080 FROM TABLE lt_save_2080.
      IF sy-subrc EQ 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
      ENDIF.
    ENDIF.

    PERFORM check_and_set_capa TABLES lt_save_2080.

    REFRESH lt_save_2080.

  ENDLOOP.

  PERFORM refresh_0100.


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
*& Form APPEND_MP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM append_mp_data .

  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : lt_main LIKE TABLE OF gs_main.
  DATA : lt_main_sorted LIKE TABLE OF gs_main.
  DATA : lt_save_2080 TYPE TABLE OF zgtppt2080.

  DATA : lt_row TYPE lvc_t_row.
  DATA : ls_row TYPE lvc_s_row.

  DATA : lv_chk_tabix TYPE i.

  DATA : lt_main_data TYPE REF TO data.
  DATA : ls_main_select TYPE REF TO data.
  FIELD-SYMBOLS : <lt_main> TYPE table.
  FIELD-SYMBOLS : <lv_cycltype> TYPE any.
  FIELD-SYMBOLS : <lv_vkbur> TYPE any.
  FIELD-SYMBOLS : <lv_itemname> TYPE any.
  FIELD-SYMBOLS : <lv_zpjno> TYPE any.
  FIELD-SYMBOLS : <lv_plnid> TYPE any.
  FIELD-SYMBOLS : <ls_main_select> TYPE any.

  CREATE DATA lt_main_data LIKE <gt_main_disp_200>.
  ASSIGN lt_main_data->* TO <lt_main>.

  CREATE DATA ls_main_select LIKE LINE OF <gt_main_disp_200>.
  ASSIGN ls_main_select->* TO <ls_main_select>.

  IF gv_chk_edit IS NOT INITIAL.
    CLEAR gv_answer.
    PERFORM popup_to_confirm_step USING 'N'
      ' '
      '수정중인 완제품코드가 초기화 됩니다. 계속 진행 하시겠습니까?'
      '작업확인'.
    IF gv_answer NE 'J'.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  go_grid_0100->get_selected_cells_id(
      IMPORTING
       et_cells = lt_cells ).                " Cell IDs

  DELETE lt_cells WHERE row_id = 0.

  IF lt_cells[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '선택된 Cell이 없습니다.'(e01).
    RETURN.
  ENDIF.

  SORT lt_cells BY row_id.
  DELETE ADJACENT DUPLICATES FROM lt_cells COMPARING row_id.

  LOOP AT lt_cells INTO DATA(ls_cells).
    READ TABLE gt_main INTO gs_main INDEX ls_cells-row_id.
    IF gs_main-stat_t IS INITIAL.
      APPEND gs_main TO lt_main.
    ENDIF.
  ENDLOOP.


*___2026.01.29.zlsgpp5.CHM2601-00657.합계된 경우 사용자가 품목 선택.
  PERFORM call_screen_0400 CHANGING lt_main.


* 어팬드 위한 정합성 체크
* 1. 기존에 생산계획에 올라오지 않은 판매계획건이 존재하는지 여부
* 2. 선택된 판매계획이 동일한 규격 및 프로젝트 No. 인지 확인
* 3. 선택된 판매계획의 규격 및 프로젝트 No.에 해당하는
*     기존 월간 생산 계획 대상이 여러 건인 경우 포함할
*     기존 대상이 선택 되어야 함
* 1)
  IF lt_main[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '추가 가능한 판매계획이 없습니다.'.
    RETURN.
  ENDIF.

* 2)
  lt_main_sorted[] = lt_main.
  SORT lt_main_sorted BY itemname zpjno.
  DELETE ADJACENT DUPLICATES FROM lt_main_sorted COMPARING itemname zpjno.

  IF 1 < lines( lt_main_sorted ).
    MESSAGE s005 DISPLAY LIKE 'E' WITH '기존 대상 추가는 판매계획 별 동일한 규격' '및 프로젝트 No. 만 선택할 수 있습니다.'.
    RETURN.
  ENDIF.

* 3)
  READ TABLE lt_main_sorted INTO DATA(ls_main_sorted) INDEX 1.

  CLEAR lv_chk_tabix.
  LOOP AT <gt_main_disp_200> ASSIGNING FIELD-SYMBOL(<ls_main>).
*   견적과 프로젝트 번호 비교하여 동일대상 건수 확인
    IF <lv_itemname> IS ASSIGNED. UNASSIGN <lv_itemname>. ENDIF.
    ASSIGN COMPONENT 'ITEMNAME' OF STRUCTURE <ls_main> TO <lv_itemname>.
    IF <lv_zpjno> IS ASSIGNED. UNASSIGN <lv_zpjno>. ENDIF.
    ASSIGN COMPONENT 'ZPJNO' OF STRUCTURE <ls_main> TO <lv_zpjno>.
    IF <lv_itemname> = ls_main_sorted-itemname AND
      <lv_zpjno> = ls_main_sorted-zpjno.
      ADD 1 TO lv_chk_tabix.
      IF lv_chk_tabix = 1.
        MOVE <ls_main> TO <ls_main_select>.
      ENDIF.
    ENDIF.
  ENDLOOP.

* 선택된 월간 생산 계획이 있는지 확인
  CALL METHOD go_grid_0200->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

  DELETE lt_row WHERE index = 0. " 서브토탈 제외

  IF lv_chk_tabix = 0.
    MESSAGE s005 DISPLAY LIKE 'E' WITH '판매 계획과 동일한 규격 및 프로젝트 No.인 월간 생산계획이 없습니다.'.
    RETURN.
  ELSEIF lv_chk_tabix = 1.
    IF lt_row[] IS INITIAL. " 선택 대상이 없을 경우 ok

    ELSEIF 1 = lines( lt_row ). "선택 대상이 한건 존재할 경우 정합성 체크
      READ TABLE lt_row INTO ls_row INDEX 1.
      READ TABLE <gt_main_disp_200> ASSIGNING <ls_main> INDEX ls_row-index.
*    동일한 규격 및 프로젝트 No.인지 확인
      IF <lv_itemname> IS ASSIGNED. UNASSIGN <lv_itemname>. ENDIF.
      ASSIGN COMPONENT 'ITEMNAME' OF STRUCTURE <ls_main> TO <lv_itemname>.
      IF <lv_zpjno> IS ASSIGNED. UNASSIGN <lv_zpjno>. ENDIF.
      ASSIGN COMPONENT 'ZPJNO' OF STRUCTURE <ls_main> TO <lv_zpjno>.
      IF NOT ( <lv_itemname> = ls_main_sorted-itemname AND
                <lv_zpjno> = ls_main_sorted-zpjno ).
        MESSAGE s005 DISPLAY LIKE 'E' WITH '기존 대상 추가는 판매계획 별 동일한 규격' '및 프로젝트 No. 만 선택할 수 있습니다.'.
        RETURN.
      ENDIF.
    ELSE. " 선택된 대상이 여러건일 경우 에러
      MESSAGE s005 DISPLAY LIKE 'E' WITH '기존 대상 추가는 한건만 선택가능합니다.'.
      RETURN.
    ENDIF.
  ELSE.
    IF lt_row[] IS INITIAL. " 선택 대상이 없을 경우 에러
      MESSAGE s005 DISPLAY LIKE 'E' WITH '신규 월간 생산 계획 대상으로 선정될' '판매계획이 선택되지 않았습니다.'.
      RETURN.
    ELSEIF 1 = lines( lt_row ). "선택 대상이 한건 존재할 경우 정합성 체크
      READ TABLE lt_row INTO ls_row INDEX 1.
      READ TABLE <gt_main_disp_200> ASSIGNING <ls_main> INDEX ls_row-index.
*    동일한 규격 및 프로젝트 No.인지 확인
      IF <lv_itemname> IS ASSIGNED. UNASSIGN <lv_itemname>. ENDIF.
      ASSIGN COMPONENT 'ITEMNAME' OF STRUCTURE <ls_main> TO <lv_itemname>.
      IF <lv_zpjno> IS ASSIGNED. UNASSIGN <lv_zpjno>. ENDIF.
      ASSIGN COMPONENT 'ZPJNO' OF STRUCTURE <ls_main> TO <lv_zpjno>.
      IF <lv_itemname> = ls_main_sorted-itemname AND
          <lv_zpjno> = ls_main_sorted-zpjno.
        CLEAR <ls_main_select>.
        MOVE <ls_main> TO <ls_main_select>.
      ELSE.
        MESSAGE s005 DISPLAY LIKE 'E' WITH '기존 대상 추가는 판매계획 별 동일한 규격' '및 프로젝트 No. 만 선택할 수 있습니다.'.
        RETURN.
      ENDIF.
    ELSE. " 선택된 대상이 여러건일 경우 에러
      MESSAGE s005 DISPLAY LIKE 'E' WITH '기존 대상 추가는 한건만 선택가능합니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  CLEAR gv_answer.
  PERFORM popup_to_confirm_step USING 'N'
    ' '
    '월간생산계획 생성합니다. 계속 진행 하시겠습니까?'
    '생성확인'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

*    선택된 라인의 월간 생산 계획 ID 사용
  IF <lv_plnid> IS ASSIGNED. UNASSIGN <lv_plnid>. ENDIF.
  ASSIGN COMPONENT 'PLNID' OF STRUCTURE <ls_main_select> TO <lv_plnid>.

  READ TABLE gt_2080 INTO DATA(ls_2080) WITH KEY plnid = <lv_plnid>.

  LOOP AT lt_main INTO DATA(ls_main).
    APPEND INITIAL LINE TO lt_save_2080 ASSIGNING FIELD-SYMBOL(<ls_save_2080>).

    <ls_save_2080>-plnid = <lv_plnid>.
    <ls_save_2080>-werks = p_werks.
    <ls_save_2080>-spgcd = p_spgcd.
    <ls_save_2080>-pltype = ls_main-pltype.
    <ls_save_2080>-vkbur = ls_main-vkbur.
    <ls_save_2080>-cycltype = ls_main-cycltype.
    <ls_save_2080>-spec = ls_main-itemname.
    <ls_save_2080>-zpjno = ls_main-zpjno.
    <ls_save_2080>-vbeln = ls_main-vbeln.
    <ls_save_2080>-posnr = ls_main-posnr.
    <ls_save_2080>-pltype = ls_main-pltype.
    <ls_save_2080>-matnr = ls_main-matnr.
    <ls_save_2080>-sul_no = ls_main-sul_no.
    <ls_save_2080>-meins = ls_main-meins.
*   자재, 설번, 단위는 기존에 저장된 데이터 사용
    <ls_save_2080>-matnr = ls_2080-matnr.
    <ls_save_2080>-sul_no = ls_2080-sul_no.
    <ls_save_2080>-meins = ls_2080-meins.

  ENDLOOP.

  IF lt_save_2080 IS NOT INITIAL.
    MODIFY zgtppt2080 FROM TABLE lt_save_2080.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.

  PERFORM check_and_set_capa TABLES lt_save_2080.

  PERFORM refresh_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MAIN_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SAVE_2080_TOT
*&---------------------------------------------------------------------*
FORM get_main_200  TABLES    pt_2080 STRUCTURE zgtppt2080.

  DATA : lt_sort_2080 TYPE TABLE OF zgtppt2080.
  DATA : BEGIN OF ls_chk_matnr,
           matnr TYPE zsdt_d365_021-matnr,
         END OF ls_chk_matnr.
  DATA : lt_chk_matnr LIKE TABLE OF ls_chk_matnr.
  DATA : lt_2100 TYPE TABLE OF zgtppt2100.

  DATA : BEGIN OF ls_chk_spart,
           spart TYPE zgtppt1010-fld_02,
         END OF ls_chk_spart.
  DATA : lt_chk_spart LIKE TABLE OF ls_chk_spart.
  DATA : ls_disp_200 LIKE gs_main_200.
  DATA : lv_fieldname TYPE fieldname.
  DATA : lv_chk_find_sales.
  DATA : lv_chk_find_sales_line.
  DATA : lv_tabix TYPE i.
  FIELD-SYMBOLS <lv_field> TYPE any.
  DATA : lv_menge TYPE mseg-menge.
  DATA : lv_num(3) TYPE n.
  DATA : lv_zpjno TYPE zsd0106t-zpjno.

  lv_num = 1 + 0.

  CLEAR  gv_chk_edit.

  lt_sort_2080[] = pt_2080[].
  SORT lt_sort_2080 BY plnid.
  DELETE ADJACENT DUPLICATES FROM lt_sort_2080 COMPARING plnid.
  IF lt_sort_2080[] IS NOT INITIAL.
    SELECT pltype, cycltype, vkbur, spec AS itemname, zpjno, kunnr, basemonth,
                matnr, quantity_dp, vrkme, vbeln, posnr, spart, zptxt,
                name1
       FROM zgtcvsalesplan
        FOR ALL ENTRIES IN @lt_sort_2080
      WHERE cycltype = @lt_sort_2080-cycltype
        AND vkbur = @lt_sort_2080-vkbur
        AND spec = @lt_sort_2080-spec
        AND zpjno = @lt_sort_2080-zpjno
*        AND VBELN = @LT_SORT_2080-VBELN
*        AND POSNR = @LT_SORT_2080-POSNR
        INTO TABLE @DATA(lt_data).

    SELECT DISTINCT b~*
      FROM @lt_sort_2080 AS a
      INNER JOIN zgtppt2100 AS b ON b~plnid = a~plnid
     WHERE b~werks = @p_werks
         AND b~spgcd = @p_spgcd
         AND b~gong_seq = @lv_num
      INTO TABLE @lt_2100.
  ENDIF.
* 아래화면 날짜 구성에 대한 동적 적용을 위한 로직
*&---------------------------------------------------------------------*
  DATA(lt_data_chk) = lt_data.
  SORT lt_data_chk BY basemonth.
  DELETE ADJACENT DUPLICATES FROM lt_data_chk COMPARING basemonth.
  REFRESH gt_range_spmon[].
  IF lt_data_chk[] IS NOT INITIAL.
    APPEND INITIAL LINE TO gt_range_spmon ASSIGNING FIELD-SYMBOL(<ls_spmon>).
    <ls_spmon>-sign = 'I'.
    <ls_spmon>-option = 'BT'.

*  디스플레이 시작월 세팅
    READ TABLE lt_data_chk INTO DATA(ls_data_chk) INDEX 1.
    <ls_spmon>-low = ls_data_chk-basemonth.
*  디스플레이 마지막월 세팅
    lv_tabix = lines( lt_data_chk ).
    READ TABLE lt_data_chk INTO ls_data_chk INDEX lv_tabix.
    <ls_spmon>-high = ls_data_chk-basemonth.
  ENDIF.
*&---------------------------------------------------------------------*

* 자재코드로 생산 단위, 설계번호 조회
  lt_chk_matnr = VALUE  #( FOR lw_data IN lt_data WHERE ( matnr IS NOT INITIAL )
                                      ( matnr = lw_data-matnr ) ).
  IF lt_chk_matnr IS NOT INITIAL.
    SELECT matnr, meins
      FROM mara
        FOR ALL ENTRIES IN @lt_chk_matnr
      WHERE matnr = @lt_chk_matnr-matnr
       INTO TABLE @DATA(lt_mara_mein).
    SORT lt_mara_mein BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_mara_mein COMPARING matnr.
  ENDIF.

* 재조코드 없을시 공통코드 정보에서 생산단위 추출
  lt_chk_spart = VALUE  #( FOR lw_data IN lt_data WHERE ( spart IS INITIAL )
                                      ( spart = lw_data-spart ) ).
  IF lt_chk_spart[] IS NOT INITIAL.
    SELECT fld_02 AS spart, fld_03 AS meins
      FROM zgtppt1010
        FOR ALL ENTRIES IN @lt_chk_spart
      WHERE module_kind = 'PP'
      AND codegrp = '2050'
      AND fld_01 = @p_werks
      AND fld_02 = @lt_chk_spart-spart
     INTO TABLE @DATA(lt_1010_meins).
  ENDIF.




  SORT pt_2080 BY plnid.
  REFRESH <gt_main_disp_200>.
  LOOP AT lt_sort_2080 INTO DATA(ls_sort_2080).
    CLEAR ls_disp_200.
    ls_disp_200-plnid = ls_sort_2080-plnid.
    ls_disp_200-itemname = ls_sort_2080-spec.
    ls_disp_200-zpjno = ls_sort_2080-zpjno.
    ls_disp_200-matnr = ls_sort_2080-matnr.
    ls_disp_200-sul_no = ls_sort_2080-sul_no.
    ls_disp_200-meins = ls_sort_2080-meins.
    ls_disp_200-alenr = ls_sort_2080-alenr.
    CLEAR lv_chk_find_sales.
    APPEND INITIAL LINE TO <gt_main_disp_200> ASSIGNING FIELD-SYMBOL(<ls_main_disp_200>).

    CLEAR lv_tabix.
    LOOP AT pt_2080 WHERE plnid = ls_sort_2080-plnid.
      CLEAR lv_chk_find_sales_line.
      ADD 1 TO lv_tabix.
      READ TABLE lt_data INTO DATA(ls_data) WITH KEY cycltype = pt_2080-cycltype
                                                                              vkbur = pt_2080-vkbur
                                                                              itemname = pt_2080-spec
                                                                              zpjno = pt_2080-zpjno
                                                                              vbeln = pt_2080-vbeln
                                                                              posnr = pt_2080-posnr.
      IF sy-subrc EQ 0 AND ls_data-pltype = 'DP'.
        READ TABLE lt_data INTO DATA(ls_chk_data) WITH KEY cycltype = pt_2080-cycltype
                                                                                       vkbur = pt_2080-vkbur
                                                                                       itemname = pt_2080-spec
                                                                                       zpjno = pt_2080-zpjno
                                                                                       vbeln = pt_2080-vbeln
                                                                                       posnr = pt_2080-posnr
                                                                                       pltype = 'SP'.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING ls_chk_data TO ls_data.
        ENDIF.

      ELSEIF sy-subrc NE 0.
        READ TABLE lt_data INTO ls_data WITH KEY cycltype = pt_2080-cycltype
                                                                        vkbur = pt_2080-vkbur
                                                                        itemname = pt_2080-spec
                                                                        zpjno = pt_2080-zpjno.
        lv_chk_find_sales = abap_true.
        lv_chk_find_sales_line = abap_true.
      ENDIF.

      IF lv_tabix = 1.

        IF ls_data-matnr NE ls_disp_200-matnr.
          DATA(lv_chk_matnr) = abap_true.
        ENDIF.

        ls_disp_200-kunnr = ls_data-kunnr.
        ls_disp_200-name1 = ls_data-name1.
* 프로젝트내역 추가
        IF ls_data-zptxt IS INITIAL AND ls_data-zpjno IS NOT INITIAL.
          TRY.
              CLEAR lv_zpjno.

              lv_zpjno = ls_data-zpjno && '%'.


              SELECT SINGLE zptxt FROM zsd0106t
                INTO ls_disp_200-zptxt
                WHERE zpjno LIKE lv_zpjno
                  AND spart = ls_data-spart.

            CATCH cx_root.
          ENDTRY.
        ELSE.
          ls_disp_200-zptxt = ls_data-zptxt.
        ENDIF.

        MOVE-CORRESPONDING ls_disp_200 TO <ls_main_disp_200> .
*        생산 단위 기준으로 보여줘야 하므로
        CLEAR lv_fieldname.
        lv_fieldname = 'MEINS'.
        IF <lv_field> IS ASSIGNED. UNASSIGN <lv_field>. ENDIF.
        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main_disp_200> TO <lv_field>.
        <lv_field> = pt_2080-meins.
      ENDIF.

      IF ls_data-vrkme IS INITIAL.
        READ TABLE lt_1010_meins INTO DATA(ls_1010_meins) WITH KEY spart = ls_data-spart.
        IF sy-subrc EQ 0.
          ls_data-vrkme = ls_1010_meins-meins.
        ENDIF.
      ENDIF.

* 판매 수량 세팅 월별 섬 - 생산단위 기준으로 수량 컨버전 필요
      CLEAR lv_fieldname.
      lv_fieldname = ls_data-basemonth && '_SO'.
      IF <lv_field> IS ASSIGNED. UNASSIGN <lv_field>. ENDIF.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main_disp_200> TO <lv_field>.

*    판매단위와 생산단위가 틀리다면 환산적용
      IF ls_data-vrkme NE pt_2080-meins.
        CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
          EXPORTING
            input                = ls_data-quantity_dp
            unit_in              = ls_data-vrkme
            unit_out             = pt_2080-meins
          IMPORTING
            output               = lv_menge
          EXCEPTIONS
            conversion_not_found = 1
            division_by_zero     = 2
            input_invalid        = 3
            output_invalid       = 4
            overflow             = 5
            type_invalid         = 6
            units_missing        = 7
            unit_in_not_found    = 8
            unit_out_not_found   = 9
            OTHERS               = 10.
        IF sy-subrc <> 0.
        ENDIF.
      ELSE.
        lv_menge = ls_data-quantity_dp.
      ENDIF.

      IF lv_chk_find_sales_line IS INITIAL.
        <lv_field> = <lv_field> + lv_menge.
      ENDIF.

    ENDLOOP.

    LOOP AT lt_2100 INTO DATA(ls_2100) WHERE plnid = ls_sort_2080-plnid.
      CLEAR lv_fieldname.
      lv_fieldname = ls_2100-zspmon && '_PO'.
      IF <lv_field> IS ASSIGNED. UNASSIGN <lv_field>. ENDIF.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main_disp_200> TO <lv_field>.
      <lv_field> = <lv_field> + ls_2100-menge.
    ENDLOOP.

    IF lv_chk_matnr IS NOT INITIAL.
      CLEAR lv_fieldname.
      lv_fieldname = 'CHECK2'.
      IF <lv_field> IS ASSIGNED. UNASSIGN <lv_field>. ENDIF.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main_disp_200> TO <lv_field>.
      <lv_field> = icon_led_yellow.
    ENDIF.
    CLEAR lv_chk_matnr.

    IF lv_chk_find_sales IS NOT INITIAL.
      CLEAR lv_fieldname.
      lv_fieldname = 'CHECK2'.
      IF <lv_field> IS ASSIGNED. UNASSIGN <lv_field>. ENDIF.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main_disp_200> TO <lv_field>.
      <lv_field> = icon_led_red.
    ENDIF.

  ENDLOOP.

* 판매계획상 수량과
  LOOP AT <gt_main_disp_200> ASSIGNING <ls_main_disp_200>.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DISP_TABLE_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SAVE_2080_TOT
*&---------------------------------------------------------------------*
FORM make_disp_table_200.

  DATA : lt_fcat TYPE slis_t_fieldcat_alv.
  DATA : lv_col_pos TYPE i.
  DATA : lv_date TYPE sy-datum.
  DATA : lv_text(100).

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name     = sy-repid
      i_internal_tabname = 'GS_MAIN_200'
      i_inclname         = 'ZGTPPR2060TOP'
      i_bypassing_buffer = 'X'
    CHANGING
      ct_fieldcat        = lt_fcat.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0200[]
    TABLES
      it_data         = gt_main_200.

  SORT gt_spmon.

  lv_col_pos = 100.
  LOOP AT gt_spmon INTO gs_spmon.
    APPEND INITIAL LINE TO gt_fieldcat_0200 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    ADD 1 TO lv_col_pos.
    <ls_fcat>-col_pos = lv_col_pos.
    <ls_fcat>-fieldname = gs_spmon-spmon && '_SO'.
    <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = gs_spmon-spmon && '(판매)'.
    <ls_fcat>-ref_table = 'MSEG'.
    <ls_fcat>-ref_field = 'MENGE'.
    <ls_fcat>-qfieldname = 'MEINS'.
    <ls_fcat>-outputlen = 12.
    <ls_fcat>-just = 'R'.


    APPEND INITIAL LINE TO gt_fieldcat_0200 ASSIGNING <ls_fcat>.
    ADD 1 TO lv_col_pos.
    <ls_fcat>-col_pos = lv_col_pos.
    <ls_fcat>-fieldname = gs_spmon-spmon && '_PO'.
    <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = gs_spmon-spmon && '(생산)'.
    <ls_fcat>-ref_table = 'MSEG'.
    <ls_fcat>-ref_field = 'MENGE'.
    <ls_fcat>-qfieldname = 'MEINS'.
    <ls_fcat>-outputlen = 12.
    <ls_fcat>-just = 'R'.

  ENDLOOP.

* 필드명 서술
  LOOP AT gt_fieldcat_0200 ASSIGNING <ls_fcat>.
    CLEAR <ls_fcat>-key.
    CASE <ls_fcat>-fieldname.
      WHEN 'PLNID'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'ITEMNAME'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '규격'(f03).
        <ls_fcat>-just = 'L'.
        <ls_fcat>-key = abap_true.
      WHEN 'ZPJNO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '프로젝트 No.'(f04).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-key = abap_true.
      WHEN 'ZPTXT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '프로젝트 내역'(f22).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'L'.
      WHEN 'KUNNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매처코드'(f05).
        <ls_fcat>-just = 'C'.
      WHEN 'NAME1'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매처명'(f06).
        <ls_fcat>-just = 'L'.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '완제품 코드'(f07).
        <ls_fcat>-just = 'C'.
      WHEN 'CHECK'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '　'.
        <ls_fcat>-just = 'C'.
      WHEN 'CHECK2'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '　'.
        <ls_fcat>-just = 'C'.
      WHEN 'SUL_NO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '설계번호'(f08).
        <ls_fcat>-just = 'C'.
      WHEN 'MEINS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '생산단위'(f11).
        <ls_fcat>-just = 'C'.
      WHEN 'ALENR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '여장율'(f21).
        <ls_fcat>-just = 'R'.
    ENDCASE.
  ENDLOOP.

  SORT gt_fieldcat_0200 BY col_pos.

  FREE gt_main_disp_200.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      i_style_table             = abap_true
      it_fieldcatalog           = gt_fieldcat_0200
    IMPORTING
      ep_table                  = gt_main_disp_200
    EXCEPTIONS
      generate_subpool_dir_full = 1                " At Most 36 Subroutine Pools Can Be Generated Temporarily
      OTHERS                    = 2.
  IF sy-subrc <> 0.
    MESSAGE s005 DISPLAY LIKE 'E' WITH 'At Most 36 Subroutine Pools' 'Can Be Generated Temporarily'.
    LEAVE LIST-PROCESSING..
  ENDIF.

  ASSIGN gt_main_disp_200->* TO <gt_main_disp_200>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RANGES_SPMON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SAVE_2080_TOT
*&---------------------------------------------------------------------*
FORM set_ranges_spmon.

  DATA : lv_min_spmon TYPE spmon.
  DATA : lv_max_spmon TYPE spmon.
  DATA : lv_spmon TYPE spmon.
  DATA : lv_idx TYPE i.
  DATA : lv_yyyy(4) TYPE n.
  DATA : lv_mm(2) TYPE n.

* 판매계획 월도
  SORT gt_chk_basemonth BY basemonth.
  DELETE ADJACENT DUPLICATES FROM  gt_chk_basemonth COMPARING basemonth.

  SORT gt_chk_basemonth BY basemonth.
  READ TABLE gt_chk_basemonth INTO DATA(ls_basemonth) INDEX 1.
  lv_min_spmon = ls_basemonth-basemonth.

  lv_idx = lines( gt_chk_basemonth ).
  READ TABLE gt_chk_basemonth INTO ls_basemonth INDEX lv_idx.
  lv_max_spmon = ls_basemonth-basemonth.

  SELECT SINGLE MIN( c~pldat ) AS begin_dt, MAX( c~pldat ) AS end_dt
    FROM @gt_2080 AS a
    INNER JOIN zgtppt2090 AS b ON b~plnid = a~plnid
    INNER JOIN zgtppt2091 AS c ON c~simno = b~simno
                                          AND c~simvr = b~simvr
   WHERE b~werks = @p_werks
      AND b~spgcd = @p_spgcd
      AND b~plcnf = @abap_true
     INTO ( @DATA(lv_begin_dt), @DATA(lv_end_dt) ).

  IF sy-subrc EQ 0 AND ( lv_begin_dt IS NOT INITIAL AND lv_end_dt IS NOT INITIAL ).

    IF lv_min_spmon > lv_begin_dt+0(6).
      lv_min_spmon = lv_begin_dt+0(6).
    ENDIF.

    IF lv_max_spmon < lv_end_dt+0(6).
      lv_max_spmon = lv_end_dt+0(6).
    ENDIF.

  ENDIF.

  REFRESH gt_spmon.
  lv_spmon = lv_min_spmon.
  DO.
    gs_spmon-spmon = lv_spmon.
    APPEND gs_spmon TO gt_spmon.

    IF lv_spmon = lv_max_spmon.
      EXIT.
    ELSE.
      IF lv_spmon+4(2) = '12'.
        lv_yyyy = lv_spmon+0(4) + 1.
        lv_spmon = lv_yyyy && '01'.

      ELSE.
        ADD 1 TO lv_spmon.
      ENDIF.
    ENDIF.

  ENDDO.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_0100 .

  PERFORM get_main_data USING 'I'.
  PERFORM get_main_200 TABLES gt_2080.

  PERFORM refresh_grid USING go_grid_0100.
  PERFORM refresh_grid USING go_grid_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM refresh_grid  USING    po_grid TYPE REF TO cl_gui_alv_grid..

  DATA: ls_scroll   TYPE lvc_s_stbl.

  ls_scroll-row = 'X'.
  ls_scroll-col = 'X'.

  CASE po_grid.
    WHEN go_grid_0100.
      PERFORM set_cell_attribute_grid_0100.
    WHEN go_grid_0200.
      PERFORM set_layout_grid_0200.
      PERFORM set_cell_attribute_grid_0200 .
      PERFORM set_disp_fieldcat_grid_0200.
      go_grid_0200->set_frontend_layout( is_layout = gs_layout_0200 ).
      go_grid_0200->set_frontend_fieldcatalog( it_fieldcatalog = gt_fieldcat_0200 ).

  ENDCASE.

  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      is_stable = ls_scroll.

  CASE po_grid.
    WHEN go_grid_0200.
      go_grid_0200->set_ready_for_input( 1 ).
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0200 .

  PERFORM set_screeen_expend USING 'D'.

  CREATE OBJECT go_grid_0200
    EXPORTING
      i_parent      = go_contain_0200
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_screeen_expend
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_screeen_expend  USING  pv_mode.
  CASE pv_mode.
    WHEN 'I'. " 초기화면
* 초기 아래화면 없을시 보여주지 않는다
      go_splitter_0100->set_row_height(
          EXPORTING
            id                =    2              " Row ID
            height            =    90 ).             " Height

      go_splitter_0100->set_row_height(
          EXPORTING
            id                =    3              " Row ID
            height            =    0 ).             " Height
    WHEN 'D'." Detail 화면 추가
      go_splitter_0100->set_row_height(
          EXPORTING
            id                =    2              " Row ID
            height            =   55 ).             " Height

      go_splitter_0100->set_row_height(
          EXPORTING
            id                =    3              " Row ID
            height            =   35  ).             " Height
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_grid_0200 .

  CLEAR gs_layout_0200.
*  IF <GT_MAIN_DISP_200> IS NOT INITIAL.
  gs_layout_0200-cwidth_opt = abap_true.
*  ENDIF.
  gs_layout_0200-sel_mode = 'D'.
  gs_layout_0200-stylefname = 'XYZSTYLEZYX'.
  gs_layout_0200-smalltitle = 'X'.
  gs_layout_0200-grid_title = '월간생산계획 대상'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0200 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0200
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
                cl_gui_alv_grid=>mc_fc_loc_paste_new_row,
                cl_gui_alv_grid=>mc_fc_refresh.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_sorttab_grid_0200 .

  PERFORM set_sort_tab TABLES gt_sort_0200
                                  USING : 1 'ITEMNAME'  'X' '' '',
                                             2 'ZPJNO'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0200_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0200_display .

  CALL METHOD go_grid_0200->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0200
      it_toolbar_excluding = gt_exclude_0200
    CHANGING
      it_outtab            = <gt_main_disp_200>
      it_sort              = gt_sort_0200
      it_fieldcatalog      = gt_fieldcat_0200.

  PERFORM refresh_grid USING go_grid_0200.

* 인풋이벤트 추가
  CALL METHOD go_grid_0200->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD go_grid_0200->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_cell_attribute_grid_0200 .

  DATA : lt_celltab TYPE lvc_t_styl.
  DATA : ls_celltab TYPE lvc_s_styl.
  FIELD-SYMBOLS <lt_celltab> TYPE any.

  LOOP AT <gt_main_disp_200> ASSIGNING FIELD-SYMBOL(<ls_data>).
    REFRESH lt_celltab.
* 키색정의(에디트 모드라 반영이 안됨)
    CLEAR ls_celltab.
    ls_celltab-fieldname = 'ITEMNAME'.
    ls_celltab-style = alv_style_color_int_key.
    INSERT ls_celltab INTO TABLE lt_celltab.

    CLEAR ls_celltab.
    ls_celltab-fieldname = 'ZPJNO'.
    ls_celltab-style = alv_style_color_int_key.
    INSERT ls_celltab INTO TABLE lt_celltab.

    CLEAR ls_celltab.
    ls_celltab-fieldname = 'ZPTXT'.
    ls_celltab-style = alv_style_color_int_key.
    INSERT ls_celltab INTO TABLE lt_celltab.

    CLEAR ls_celltab.
    ls_celltab-fieldname = 'MATNR'.
    ls_celltab-style = alv_style_enabled.
    INSERT ls_celltab INTO TABLE lt_celltab.

    CLEAR ls_celltab.
    ls_celltab-fieldname = 'ALENR'.
    ls_celltab-style = alv_style_enabled.
    INSERT ls_celltab INTO TABLE lt_celltab.

    IF <lt_celltab> IS ASSIGNED. UNASSIGN <lt_celltab>. ENDIF.
    ASSIGN COMPONENT 'XYZSTYLEZYX' OF STRUCTURE <ls_data> TO <lt_celltab>.
    IF <lt_celltab> IS ASSIGNED.
      <lt_celltab> = lt_celltab.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_main_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM get_main_data  USING  pv_mode.

  DATA : BEGIN OF ls_chk_2080,
           cycltype TYPE zsdt_d365_021-cycltype,
           vkbur    TYPE zsdt_d365_021-vkbur,
           itemname TYPE zsdt_d365_021-itemname,
           zpjno    TYPE zsdt_d365_021-zpjno,
         END OF ls_chk_2080.
  DATA : lt_chk_2080 LIKE TABLE OF ls_chk_2080.

  DATA : lt_spmon TYPE RANGE OF zsdt_d365_021-week.

  DATA : BEGIN OF ls_chk_matnr,
           matnr TYPE zsdt_d365_021-matnr,
           spart TYPE zsdt_d365_021-spart,
         END OF ls_chk_matnr.
  DATA : lt_chk_matnr LIKE TABLE OF ls_chk_matnr.

  DATA : BEGIN OF ls_chk_spart,
           spart TYPE zgtppt1010-fld_02,
         END OF ls_chk_spart.
  DATA : lt_chk_spart LIKE TABLE OF ls_chk_spart.

  DATA : lv_zpjno TYPE zsd0106t-zpjno.

  RANGES : lr_dpid FOR zsdt_d365_021-dpid.

  IF  pv_mode = 'S'.
    CLEAR gv_chk_edit.
    REFRESH gt_chk_2080.
  ENDIF.

  MOVE-CORRESPONDING s_spmon[] TO lt_spmon.

* 조회 기준으로 메인 데이터 추출(월도 기준)
* 2026.01.27.zlsgpp5.attr01~10 add.
  SELECT  a~pltype, a~cycltype, a~vkbur, a~week, a~basemonth, a~spec AS itemname, a~zpjno, a~zptxt,
          a~kunnr, a~name1, a~matnr, a~vrkme, a~quantity_dp, a~oppstatus, d~ddtext,
          a~dptype, a~spart, a~vbeln, a~posnr, a~businessunitidname AS buname, a~pernr,
          a~attr01, a~attr02, a~attr03, a~attr04, a~attr05,
          a~attr06, a~attr07, a~attr08, a~attr09, a~attr10,
          ' ' AS matnr_color
    FROM zgtcvsalesplan AS a
      INNER JOIN zppt0107 AS e  ON e~spart = a~spart
      LEFT JOIN dd07t AS d      ON d~domname = 'ZDOPPSTAT'
                                AND d~domvalue_l = a~oppstatus
   WHERE a~cycltype = 'M'
     AND a~week   IN @lt_spmon
     AND a~kunnr  IN @s_kunnr
     AND a~zpjno  IN @s_zpjno
     AND a~spec   IN @s_item
     AND a~vbeln  IN @s_vbeln
     AND a~quantity_dp > 0
     AND e~werks = @p_werks
     AND e~spgcd = @p_spgcd
     AND a~spart  IN @s_spart        "SRM2602-06064
    INTO TABLE @DATA(lt_data).

* 조회 기준으로 메인 데이터 추출(주차 기준)
* 2026.01.27.zlsgpp5.attr01~10 add.
  SELECT  a~pltype, a~cycltype, a~vkbur, a~week, a~basemonth, a~spec AS itemname, a~zpjno, a~zptxt,
          a~kunnr, a~name1, a~matnr, a~vrkme, a~quantity_dp, a~oppstatus, d~ddtext,
          a~dptype, a~spart, a~vbeln, a~posnr, a~businessunitidname AS buname, a~pernr,
          a~attr01, a~attr02, a~attr03, a~attr04, a~attr05,
          a~attr06, a~attr07, a~attr08, a~attr09, a~attr10,
          ' ' AS matnr_color
    FROM zgtcvsalesplan AS a
      INNER JOIN zppt0107 AS e  ON e~spart = a~spart
      LEFT JOIN dd07t AS d      ON d~domname = 'ZDOPPSTAT'
                                AND d~domvalue_l = a~oppstatus
   WHERE a~cycltype = 'W'
     AND a~week   IN @gt_week
     AND a~kunnr  IN @s_kunnr
     AND a~zpjno  IN @s_zpjno
     AND a~spec   IN @s_item
     AND a~vbeln  IN @s_vbeln
     AND a~quantity_dp > 0
     AND e~werks = @p_werks
     AND e~spgcd = @p_spgcd
     AND a~spart  IN @s_spart      "SRM2602-06064
     INTO TABLE @DATA(lt_data2).
  IF lt_data2[] IS NOT INITIAL.
    APPEND LINES OF lt_data2 TO lt_data.
    REFRESH lt_data2.
  ENDIF.

* 조회기준으로 생산예정일자 세팅
  gt_chk_basemonth = VALUE  #( FOR lw_data IN lt_data WHERE ( basemonth IS NOT INITIAL )
                                     ( basemonth = lw_data-basemonth ) ).

* 기 등록된 월간 생산계획 추출(CYCLTYPE, VKBUR,ITEMNAME,ZPJNO) 기준
  lt_chk_2080 = VALUE  #( FOR lw_data IN lt_data WHERE ( cycltype IS NOT INITIAL )
                                    ( cycltype = lw_data-cycltype
                                      vkbur = lw_data-vkbur
                                      itemname = lw_data-itemname
                                      zpjno = lw_data-zpjno ) ).

  SORT lt_chk_2080 BY cycltype vkbur itemname zpjno.
  DELETE ADJACENT DUPLICATES FROM lt_chk_2080 COMPARING cycltype vkbur itemname zpjno.

* 월간 생산계획 조회
  IF lt_chk_2080[] IS NOT INITIAL.
    REFRESH gt_2080.
    SELECT a~* INTO CORRESPONDING FIELDS OF TABLE @gt_2080
      FROM zgtppt2080 AS a
       FOR ALL ENTRIES IN @lt_chk_2080
     WHERE plnid IN ( SELECT DISTINCT plnid
                               FROM zgtppt2080 AS b
                               WHERE b~cycltype = @lt_chk_2080-cycltype
                                     AND b~vkbur = @lt_chk_2080-vkbur
                                     AND b~spec = @lt_chk_2080-itemname
                                     AND b~zpjno = @lt_chk_2080-zpjno  )
        AND delfl <> @abap_true.
  ENDIF.


*___2026.01.27.zlsgpp5.CHM2601-00657.새로고칠 경우 자재코드 연결 유지.
  LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<data>).
    CHECK <data>-matnr IS INITIAL.  "자재코드가 없는 건

    READ TABLE gt_similar ASSIGNING FIELD-SYMBOL(<similar>)
                          WITH KEY basemonth = <data>-basemonth
                                   itemname = <data>-itemname
                                   zpjno = <data>-zpjno
                                   attr01 = <data>-attr01
                                   attr02 = <data>-attr02
                                   attr03 = <data>-attr03
                                   attr04 = <data>-attr04
                                   attr05 = <data>-attr05
                                   attr06 = <data>-attr06
                                   attr07 = <data>-attr07
                                   attr08 = <data>-attr08.
    IF sy-subrc EQ 0.
      <data>-matnr = <similar>-matnr.
      <data>-matnr_color = c_yellow.
    ENDIF.
  ENDLOOP.


* 자재코드로 생산 단위, 설계번호 조회
  lt_chk_matnr = VALUE  #( FOR lw_data IN lt_data WHERE ( matnr IS NOT INITIAL )
                                      ( matnr = lw_data-matnr
                                        spart = lw_data-spart ) ).

  LOOP AT lt_chk_matnr ASSIGNING FIELD-SYMBOL(<ls_chk_matnr>).
*   조회대상건중 알파 컨버전 전용된건들 알파컨버전 제거
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = <ls_chk_matnr>-matnr
      IMPORTING
        output = <ls_chk_matnr>-matnr.
* MATN1 컨버젼 적용
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input        = <ls_chk_matnr>-matnr
      IMPORTING
        output       = <ls_chk_matnr>-matnr
      EXCEPTIONS
        length_error = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
    ENDIF.
  ENDLOOP.

  SORT lt_chk_matnr BY matnr spart.
  DELETE ADJACENT DUPLICATES FROM lt_chk_matnr COMPARING matnr spart.

  IF lt_chk_matnr[] IS NOT INITIAL.
*   설계번호 조회(설계 마스터 확인)
    SELECT new_matnr AS matnr, spart, sul_no
      FROM zedt1000
       FOR ALL ENTRIES IN @lt_chk_matnr
      WHERE spart = @lt_chk_matnr-spart
         AND new_matnr = @lt_chk_matnr-matnr
         AND werks = @p_werks
         AND sul_level = 'FT'
         AND status = 'Z'
        INTO TABLE @DATA(lt_sul_1000).

    SORT lt_sul_1000 BY matnr spart.
    DELETE ADJACENT DUPLICATES FROM lt_sul_1000 COMPARING matnr spart.

*   설계번호 조회(견적설계 확인)
    SELECT a~matnr, a~sul_no
       FROM zgtedt9020 AS a
        FOR ALL ENTRIES IN @lt_chk_matnr
      WHERE a~matnr = @lt_chk_matnr-matnr
         AND a~werks = @p_werks
         AND a~zifkey = ( SELECT MAX( zifkey ) AS zifkey
                                    FROM zgtedt9020 AS b
                                  WHERE b~matnr = a~matnr
                                      AND b~werks = a~werks )
        INTO TABLE @DATA(lt_sul_9020).

    SORT lt_sul_9020 BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_sul_9020 COMPARING matnr.

    SELECT matnr, meins
      FROM mara
        FOR ALL ENTRIES IN @lt_chk_matnr
      WHERE matnr = @lt_chk_matnr-matnr
       INTO TABLE @DATA(lt_mara_mein).
    SORT lt_mara_mein BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_mara_mein COMPARING matnr.

    SELECT a~matnr, a~mtart, b~mtref
      FROM mara AS a
      INNER JOIN t134 AS b ON b~mtart = a~mtart
        FOR ALL ENTRIES IN @lt_chk_matnr
      WHERE a~matnr = @lt_chk_matnr-matnr
       INTO TABLE @DATA(lt_mara_mtart).

    SORT lt_mara_mtart BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_mara_mtart COMPARING matnr.

  ENDIF.

* 자조코드 없을시 공통코드 정보에서 생산단위 추출
  lt_chk_spart = VALUE  #( FOR lw_data IN lt_data WHERE ( spart IS NOT INITIAL )
                                      ( spart = lw_data-spart ) ).
  IF lt_chk_spart[] IS NOT INITIAL.
    SELECT fld_02 AS spart, fld_03 AS meins
      FROM zgtppt1010
        FOR ALL ENTRIES IN @lt_chk_spart
      WHERE module_kind = 'PP'
      AND codegrp = '2050'
      AND fld_01 = @p_werks
      AND fld_02 = @lt_chk_spart-spart
     INTO TABLE @DATA(lt_1010_meins).
  ENDIF.

  REFRESH gt_main.

  LOOP AT lt_data INTO DATA(ls_data).
    IF ls_data-pltype = 'DP'.
      READ TABLE lt_data  INTO DATA(ls_data2)
                          WITH KEY  cycltype = ls_data-cycltype
                                    vkbur = ls_data-vkbur
                                    itemname = ls_data-itemname
                                    zpjno = ls_data-zpjno
                                    vbeln = ls_data-vbeln
                                    posnr = ls_data-posnr
                                    pltype = 'SP'.
      IF sy-subrc EQ 0.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF ls_data-matnr IS NOT INITIAL.
      READ TABLE lt_mara_mtart  INTO DATA(ls_mara_mtart)
                                WITH KEY matnr = ls_data-matnr
                                BINARY SEARCH.
      IF sy-subrc EQ 0 AND ls_mara_mtart-mtref EQ 'HAWA'.
        CONTINUE.
      ENDIF.
    ENDIF.

    APPEND INITIAL LINE TO gt_main ASSIGNING FIELD-SYMBOL(<ls_main>).
    DATA(lv_tabix) = sy-tabix.

    IF ls_data-zptxt IS INITIAL AND ls_data-zpjno IS NOT INITIAL.
      TRY.
          CLEAR lv_zpjno.

          lv_zpjno = ls_data-zpjno && '%'.


          SELECT SINGLE zptxt FROM zsd0106t
            INTO ls_data-zptxt
            WHERE zpjno LIKE lv_zpjno
              AND spart = ls_data-spart.

        CATCH cx_root.
      ENDTRY.

    ENDIF.

    MOVE-CORRESPONDING ls_data TO <ls_main>.

*  설계번호 구하기
    READ TABLE lt_sul_1000  INTO DATA(ls_sul_1000)
                            WITH KEY matnr = ls_data-matnr
                                     spart = ls_data-spart.
    IF sy-subrc EQ 0. " 설계 마스터에서 조회
      <ls_main>-sul_no = ls_sul_1000-sul_no.
    ELSE. " 코드 테이블에서 조회
      READ TABLE lt_sul_9020  INTO DATA(ls_sul_9020)
                              WITH KEY matnr = ls_data-matnr.
      IF sy-subrc EQ 0.
        <ls_main>-sul_no = ls_sul_9020-sul_no.
      ENDIF.
    ENDIF.

*  생산 단위 구하기
    READ TABLE lt_mara_mein INTO DATA(ls_mara_mein)
                            WITH KEY matnr = ls_data-matnr.
    IF sy-subrc EQ 0.
      <ls_main>-meins = ls_mara_mein-meins.
    ELSE.
      READ TABLE lt_1010_meins  INTO DATA(ls_1010_meins)
                                WITH KEY spart = ls_data-spart.
      IF sy-subrc EQ 0.
        <ls_main>-meins = ls_1010_meins-meins.
      ENDIF.
    ENDIF.

    IF <ls_main>-vrkme IS INITIAL.
      READ TABLE lt_1010_meins  INTO ls_1010_meins
                                WITH KEY spart = ls_data-spart.
      IF sy-subrc EQ 0.
        <ls_main>-vrkme = ls_1010_meins-meins.
      ENDIF.
    ENDIF.

    <ls_main>-menge = <ls_main>-quantity_dp.

*    판매단위와 생산단위가 틀리다면 환산적용
    IF <ls_main>-meins IS NOT INITIAL AND
      <ls_main>-vrkme NE <ls_main>-meins.
      PERFORM translate_unit_quantity USING <ls_main>-vrkme <ls_main>-meins <ls_main>-menge
                                      CHANGING <ls_main>-menge2.
    ENDIF.

    IF <ls_main>-meins IS INITIAL.
      <ls_main>-meins = <ls_main>-vrkme.
    ENDIF.

    IF <ls_main>-menge2 IS INITIAL.
      <ls_main>-menge2 = <ls_main>-menge.
    ENDIF.

    READ TABLE gt_2080  INTO DATA(ls_2080)
                        WITH KEY  cycltype = ls_data-cycltype
                                  vkbur = ls_data-vkbur
                                  spec = ls_data-itemname
                                  zpjno = ls_data-zpjno
                                  vbeln = ls_data-vbeln
                                  posnr = ls_data-posnr.
    IF sy-subrc EQ 0.
      IF <ls_main>-vbeln IS NOT INITIAL.
        SELECT SINGLE dmord
          FROM zgtppt2010
         WHERE dmord = @<ls_main>-vbeln
           AND dmline = @<ls_main>-posnr
           AND dmordty = 'SO'
          INTO @DATA(lv_ordno).
        IF sy-subrc EQ 0.
          <ls_main>-stat_t = '조장구성'.
        ELSE.
          <ls_main>-stat_t = '대상선정'.
        ENDIF.
      ELSE.
        <ls_main>-stat_t = '대상선정'.
      ENDIF.
    ENDIF.

    IF pv_mode = 'S'.
      IF p_splan = abap_true AND p_dplan = abap_false.
        IF <ls_main>-stat_t IS NOT INITIAL.
          DELETE gt_main INDEX lv_tabix.
        ENDIF.
      ELSEIF p_splan = abap_false AND p_dplan = abap_true.
        IF <ls_main>-stat_t IS INITIAL.
          DELETE gt_main INDEX lv_tabix.
        ENDIF.
      ENDIF.
    ELSE.
      IF p_splan = abap_true AND p_dplan = abap_false.
        IF <ls_main>-stat_t IS NOT INITIAL.
          READ TABLE gt_chk_2080  TRANSPORTING NO FIELDS
                                  WITH KEY  cycltype = ls_data-cycltype
                                            vkbur = ls_data-vkbur
                                            itemname = ls_data-itemname
                                            zpjno = ls_data-zpjno
                                            vbeln = ls_data-vbeln
                                            posnr = ls_data-posnr.
          IF sy-subrc NE 0.
            DELETE gt_main INDEX lv_tabix.
          ENDIF.
        ENDIF.
      ELSEIF p_splan = abap_false AND p_dplan = abap_true.
        IF <ls_main>-stat_t IS INITIAL.
          READ TABLE gt_chk_2080  TRANSPORTING NO FIELDS
                                  WITH KEY  cycltype = ls_data-cycltype
                                            vkbur = ls_data-vkbur
                                            itemname = ls_data-itemname
                                            zpjno = ls_data-zpjno
                                            vbeln = ls_data-vbeln
                                            posnr = ls_data-posnr.
          IF sy-subrc EQ 0.
            CONTINUE.
          ELSE.
            DELETE gt_main INDEX lv_tabix.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF pv_mode EQ 'S'.
    LOOP AT gt_main INTO gs_main.
      CLEAR gs_chk_2080.
      gs_chk_2080-cycltype = ls_data-cycltype.
      gs_chk_2080-vkbur = ls_data-vkbur .
      gs_chk_2080-itemname = ls_data-itemname.
      gs_chk_2080-zpjno = ls_data-zpjno.
      gs_chk_2080-vbeln = ls_data-vbeln.
      gs_chk_2080-posnr = ls_data-posnr.
      COLLECT gs_chk_2080 INTO gt_chk_2080.
    ENDLOOP.
  ENDIF.


*___2026.01.27.zlsgpp5.CHM2601-00657. 정렬 조건 stat_t 추가.
*  SORT gt_main BY basemonth itemname zpjno vbeln posnr.
  SORT gt_main BY basemonth itemname zpjno vbeln stat_t posnr.


*/s 2026.01.27.zlsgpp5.CHM2601-00657.

  "*___오더품목번호를 유지하기 위해 별도 itab 보관.
  gt_main_org[] = gt_main[].

  "*___오더품목 이외 자재코드까지 동일할 경우, 판매수량/환산수량을 합계.
  LOOP AT gt_main ASSIGNING <ls_main>.
    CHECK <ls_main>-vbeln IS NOT INITIAL.

    AT NEW matnr.
      ASSIGN <ls_main> TO FIELD-SYMBOL(<first>).
      CONTINUE.
    ENDAT.

    IF <first>-vbeln EQ <ls_main>-vbeln.
      DATA(ls_first) = <first>.
      DATA(ls_current) = <ls_main>.

      CLEAR: ls_first-quantity_dp, ls_first-menge, ls_first-menge2, ls_first-posnr.
      CLEAR: ls_current-quantity_dp, ls_current-menge, ls_current-menge2, ls_current-posnr.

      IF ls_first EQ ls_current.
        CLEAR: <first>-posnr.
        <first>-quantity_dp  = <first>-quantity_dp + <ls_main>-quantity_dp.
        <first>-menge        = <first>-menge + <ls_main>-menge.
        <first>-menge2       = <first>-menge2 + <ls_main>-menge2.

        <ls_main>-vbeln = 'DELETE'.
      ENDIF.
    ENDIF.
  ENDLOOP.
  DELETE gt_main WHERE vbeln EQ 'DELETE'.

  "*___자재코드가 있는 경우 --> 녹색
  LOOP AT gt_main ASSIGNING <ls_main>.
    IF <ls_main>-matnr IS NOT INITIAL AND
       <ls_main>-matnr_color IS INITIAL.
      <ls_main>-matnr_color = c_green.
    ENDIF.
  ENDLOOP.

  "*___자재코드 공란 항목을 ALV 상위에 배치
  DATA(lt_main) = gt_main[].
  DELETE gt_main WHERE matnr_color EQ c_green.
  DELETE lt_main WHERE matnr_color NE c_green.
  APPEND LINES OF lt_main TO gt_main.

*/e 2026.01.27.zlsgpp5.CHM2601-00657.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_MP_DATAS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_mp_datas .

  DATA : lt_row TYPE lvc_t_row.
  DATA : ls_row TYPE lvc_s_row.

  DATA : BEGIN OF ls_chk_2080,
           plnid TYPE zgtppt2080-plnid,
         END OF ls_chk_2080.
  DATA : lt_chk_2080 LIKE TABLE OF ls_chk_2080.

  DATA : lv_zpjno TYPE zsd0106t-zpjno.

  IF gv_chk_edit IS NOT INITIAL.
    CLEAR gv_answer.
    PERFORM popup_to_confirm_step USING 'N'
      ' '
      '수정중인 완제품코드가 초기화 됩니다. 계속 진행 하시겠습니까?'
      '작업확인'.
    IF gv_answer NE 'J'.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  CALL METHOD go_grid_0200->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

  DELETE lt_row WHERE index = 0. " 서브토탈 제외

  IF lt_row[] IS INITIAL.
    MESSAGE s005 DISPLAY LIKE 'E' WITH '선택된 라인이 없습니다.'(e02).
  ENDIF.

  LOOP AT lt_row INTO ls_row.
    READ TABLE <gt_main_disp_200> ASSIGNING FIELD-SYMBOL(<ls_main>) INDEX ls_row-index.
    CLEAR ls_chk_2080.
    MOVE-CORRESPONDING <ls_main> TO ls_chk_2080.
    COLLECT ls_chk_2080 INTO lt_chk_2080.
  ENDLOOP.

  IF lt_chk_2080[] IS NOT INITIAL.
    SELECT DISTINCT *
      FROM zgtppt2080
       FOR ALL ENTRIES IN @lt_chk_2080
      WHERE plnid = @lt_chk_2080-plnid
        AND delfl = ' '
        INTO TABLE @DATA(lt_2080).

    SELECT DISTINCT *
      FROM zgtppt2090
       FOR ALL ENTRIES IN @lt_chk_2080
      WHERE plnid = @lt_chk_2080-plnid
        AND delfl = ' '
        INTO TABLE @DATA(lt_2090).
  ENDIF.

  SORT lt_2080 BY cycltype vkbur spec zpjno vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM lt_2080 COMPARING cycltype vkbur spec zpjno vbeln posnr.
  IF lt_2080[] IS NOT INITIAL.
    SELECT a~pltype, a~cycltype, a~vkbur, a~week, a~basemonth, a~spec AS itemname, a~zpjno, a~zptxt,
               a~kunnr, a~name1, a~matnr, a~vrkme, a~quantity_dp, a~oppstatus, b~ddtext,
               a~dptype, a~spart, a~vbeln, a~posnr, a~businessunitidname AS buname, a~pernr
        FROM zgtcvsalesplan AS a
        LEFT JOIN dd07t AS b
                                ON b~domname = 'ZDOPPSTAT'
                               AND b~domvalue_l = a~oppstatus
        FOR ALL ENTRIES IN @lt_2080
       WHERE a~cycltype = @lt_2080-cycltype
          AND a~vkbur = @lt_2080-vkbur
          AND a~spec = @lt_2080-spec
          AND a~zpjno = @lt_2080-zpjno
          AND a~vbeln = @lt_2080-vbeln
          AND a~posnr = @lt_2080-posnr
         INTO TABLE @DATA(lt_item).
  ENDIF.


  DATA(lt_chk_sales) = lt_2080.
  SORT lt_chk_sales BY cycltype vkbur spec zpjno.
  DELETE ADJACENT DUPLICATES FROM lt_chk_sales COMPARING cycltype vkbur spec zpjno.

  IF lt_chk_sales[] IS NOT INITIAL.
    SELECT a~pltype, a~cycltype, a~vkbur, a~week, a~basemonth, a~spec AS itemname, a~zpjno, a~zptxt,
               a~kunnr, a~name1, a~matnr, a~vrkme, a~quantity_dp, a~oppstatus, b~ddtext,
               a~dptype, a~spart, a~vbeln, a~posnr, a~businessunitidname AS buname, a~pernr
        FROM zgtcvsalesplan AS a
        LEFT JOIN dd07t AS b
                                ON b~domname = 'ZDOPPSTAT'
                               AND b~domvalue_l = a~oppstatus
        FOR ALL ENTRIES IN @lt_chk_sales
       WHERE a~cycltype = @lt_chk_sales-cycltype
          AND a~vkbur = @lt_chk_sales-vkbur
          AND a~spec = @lt_chk_sales-spec
          AND a~zpjno = @lt_chk_sales-zpjno
         INTO TABLE @DATA(lt_chk_item).
  ENDIF.

  CHECK lt_item[] IS NOT INITIAL.

  SORT lt_item BY cycltype vkbur itemname zpjno vbeln posnr.
  REFRESH gt_main_300.

  LOOP AT lt_2080 INTO DATA(ls_2080).
    APPEND INITIAL LINE TO gt_main_300 ASSIGNING FIELD-SYMBOL(<ls_main_300>).

    READ TABLE lt_chk_item INTO DATA(ls_item) WITH KEY cycltype = ls_2080-cycltype
                                                                                 vkbur = ls_2080-vkbur
                                                                                 itemname = ls_2080-spec
                                                                                 zpjno = ls_2080-zpjno
                                                                                 vbeln = ls_2080-vbeln
                                                                                 posnr = ls_2080-posnr.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING ls_item TO <ls_main_300>.
      <ls_main_300>-plnid = ls_2080-plnid.
      <ls_main_300>-chk_sales = abap_true.
    ELSE.
      READ TABLE lt_item INTO ls_item WITH KEY cycltype = ls_2080-cycltype
                                                                    vkbur = ls_2080-vkbur
                                                                    itemname = ls_2080-spec
                                                                    zpjno = ls_2080-zpjno
                                                                    vbeln = ls_2080-vbeln
                                                                    posnr = ls_2080-posnr.
      MOVE-CORRESPONDING ls_item TO <ls_main_300>.
      <ls_main_300>-plnid = ls_2080-plnid.
      <ls_main_300>-chk_sales = abap_true.

    ENDIF.

* 프로젝트내역 추가
    IF ls_item-zptxt IS INITIAL AND ls_item-zpjno IS NOT INITIAL.
      TRY.
          CLEAR lv_zpjno.
          lv_zpjno = ls_item-zpjno && '%'.

          SELECT SINGLE zptxt FROM zsd0106t
            INTO <ls_main_300>-zptxt
            WHERE zpjno LIKE lv_zpjno
              AND spart = ls_item-spart.

        CATCH cx_root.
      ENDTRY.
    ELSE.
      <ls_main_300>-zptxt = ls_item-zptxt.
    ENDIF.

    READ TABLE lt_2090 INTO DATA(ls_2090) WITH KEY plnid = <ls_main_300>-plnid.
    IF sy-subrc EQ 0.
      <ls_main_300>-chk_simul = abap_true.
    ENDIF.

  ENDLOOP.

  CLEAR gv_chk_del_ok.
  CALL SCREEN 300 STARTING AT 5 5 ENDING AT 140 25.

  IF gv_chk_del_ok IS NOT INITIAL.
    PERFORM refresh_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_INIT_WEEK_RANGES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_init_week_ranges .

  DATA : lv_bgn_date TYPE sy-datum..
  DATA : lv_end_date TYPE sy-datum..

  REFRESH gt_week.
  APPEND INITIAL LINE TO gt_week ASSIGNING FIELD-SYMBOL(<ls_week>).
  <ls_week>-sign = 'I'.
  <ls_week>-option = 'BT'.

  lv_bgn_date = s_spmon-low && '01'.
  lv_end_date = s_spmon-high && '01'.
  PERFORM get_last_day_of_month CHANGING lv_end_date.

  PERFORM get_week_from_date USING lv_bgn_date CHANGING <ls_week>-low.
  PERFORM get_week_from_date USING lv_end_date CHANGING <ls_week>-high.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LAST_DAY_OF_MONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_END_DATE
*&---------------------------------------------------------------------*
FORM get_last_day_of_month  CHANGING pv_date TYPE sy-datum.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = pv_date
    IMPORTING
      last_day_of_month = pv_date
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  .
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_WEEK_FROM_DATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_END_DATE
*&      <-- <LS_WEEK>_HIGH
*&---------------------------------------------------------------------*
FORM get_week_from_date  USING    pv_date TYPE scal-date
                                      CHANGING    pv_week TYPE char07.

  DATA : lv_week TYPE scal-week.
  CALL FUNCTION 'DATE_GET_WEEK'
    EXPORTING
      date         = pv_date
    IMPORTING
      week         = lv_week
    EXCEPTIONS
      date_invalid = 1
      OTHERS       = 2.

  IF sy-subrc <> 0.
    RETURN.
  ELSE.
    pv_week = lv_week+0(4) && lv_week+4(2).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0300 .

  CREATE OBJECT go_docking_0300
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

  CREATE OBJECT go_grid_0300
    EXPORTING
      i_parent      = go_docking_0300
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_grid_0300 .

  CLEAR gs_layout_0300.
  gs_layout_0300-cwidth_opt = abap_true.
  gs_layout_0300-sel_mode   = 'D'.
  gs_layout_0300-stylefname = 'CELLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0300 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR2060TOP'
      i_internal_tabname     = 'GS_MAIN_300'
    CHANGING
      ct_fieldcat            = lt_fcat_slis
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  REFRESH gt_fieldcat_0300.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat_slis
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0300[]
    TABLES
      it_data         = gt_main_300
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE gt_fieldcat_0300 ASSIGNING FIELD-SYMBOL(<ls_fcat>) WITH KEY fieldname = 'CHK_SALES'.
  IF sy-subrc NE 0.
    APPEND INITIAL LINE TO gt_fieldcat_0300 ASSIGNING <ls_fcat>.
    <ls_fcat>-fieldname = 'CHK_SALES'.
    <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매계획'.
    <ls_fcat>-col_pos = 30.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-outputlen = '1'.
    <ls_fcat>-checkbox = abap_true.
    <ls_fcat>-just = 'C'.
  ENDIF.

  READ TABLE gt_fieldcat_0300 ASSIGNING <ls_fcat> WITH KEY fieldname = 'CHK_SIMUL'.
  IF sy-subrc NE 0.
    APPEND INITIAL LINE TO gt_fieldcat_0300 ASSIGNING <ls_fcat>.
    <ls_fcat>-fieldname = 'CHK_SIMUL'.
    <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '생산시뮬레이션'.
    <ls_fcat>-col_pos = 31.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-outputlen = '1'.
    <ls_fcat>-checkbox = abap_true.
    <ls_fcat>-just = 'C'.
  ENDIF.

  LOOP AT gt_fieldcat_0300 ASSIGNING <ls_fcat>.
    CLEAR <ls_fcat>-key.
    CASE   <ls_fcat>-fieldname.
      WHEN 'PLNID' OR 'CYCLTYPE' OR 'VKBUR' OR 'PLTYPE'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'BASEMONTH'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매계획월'(f02).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'C'.
      WHEN 'ITEMNAME'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '규격'(f03).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'L'.
      WHEN 'ZPJNO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '프로젝트 No.'(f04).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'C'.
      WHEN 'ZPTXT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '프로젝트 내역'(f22).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'L'.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '완제품 코드'(f07).
        <ls_fcat>-just = 'C'.
      WHEN 'VRKME'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매단위'(f09).
        <ls_fcat>-just = 'C'.
      WHEN 'QUANTITY_DP'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매수량'(f10).
        <ls_fcat>-just = 'R'.
        <ls_fcat>-qfieldname = 'VRKME'.
      WHEN 'DDTEXT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '영업기회상태'(f14).
        <ls_fcat>-just = 'C'.
      WHEN 'DPTYPE'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '유형'(f15).
        <ls_fcat>-just = 'C'.
      WHEN 'VBELN'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매오더'(f17).
        <ls_fcat>-just = 'C'.
      WHEN 'POSNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '오더품목'(f18).
        <ls_fcat>-just = 'C'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0300 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0300
        USING : cl_gui_alv_grid=>mc_fc_excl_all.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0300_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0300_display .

  CALL METHOD go_grid_0300->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0300
      it_toolbar_excluding = gt_exclude_0300
    CHANGING
      it_outtab            = gt_main_300
      it_fieldcatalog      = gt_fieldcat_0300.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0400
*&---------------------------------------------------------------------*
*& 2026.01.30.zlsgpp5.create. CHM2601-00657
*&---------------------------------------------------------------------*
FORM set_object_grid_0400 .

  CREATE OBJECT go_docking_0400
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

  CREATE OBJECT go_grid_0400
    EXPORTING
      i_parent      = go_docking_0400
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0400
*&---------------------------------------------------------------------*
*& 2026.01.30.zlsgpp5.create. CHM2601-00657
*&---------------------------------------------------------------------*
FORM set_layout_grid_0400 .

  CLEAR gs_layout_0400.
  gs_layout_0400-cwidth_opt = 'A'.
  gs_layout_0400-sel_mode   = 'D'.
  gs_layout_0400-stylefname = 'CELLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0400
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0400 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR2060TOP'
      i_internal_tabname     = 'GS_MAIN'
    CHANGING
      ct_fieldcat            = lt_fcat_slis
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  REFRESH gt_fieldcat_0400.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat_slis
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0400[]
    TABLES
      it_data         = gt_main_400
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT gt_fieldcat_0400 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CLEAR <ls_fcat>-key.
    CASE   <ls_fcat>-fieldname.
      WHEN 'DPID' OR 'CYCLTYPE' OR 'VKBUR' OR 'PLTYPE'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'STAT_T'.
        <ls_fcat>-coltext = '상태'(f01).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'BASEMONTH'.
        <ls_fcat>-coltext = '판매계획월'(f02).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'C'.
      WHEN 'ITEMNAME'.
        <ls_fcat>-coltext = '규격'(f03).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'L'.
      WHEN 'ZPJNO'.
        <ls_fcat>-coltext = '프로젝트 No.'(f04).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'C'.
      WHEN 'ZPTXT'.
        <ls_fcat>-coltext = '프로젝트 내역'(f22).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'L'.
      WHEN 'KUNNR'.
        <ls_fcat>-coltext = '판매처코드'(f05).
        <ls_fcat>-just = 'C'.
      WHEN 'NAME1'.
        <ls_fcat>-coltext = '판매처명'(f06).
        <ls_fcat>-just = 'L'.
      WHEN 'MATNR'.
        <ls_fcat>-coltext = '완제품 코드'(f07).
        <ls_fcat>-just = 'C'.
      WHEN 'SUL_NO'.
        <ls_fcat>-coltext = '설계번호'(f08).
        <ls_fcat>-just = 'C'.
      WHEN 'VRKME'.
        <ls_fcat>-coltext = '판매단위'(f09).
        <ls_fcat>-just = 'C'.
      WHEN 'QUANTITY_DP'.
        <ls_fcat>-coltext = '판매수량'(f10).
        <ls_fcat>-just = 'R'.
        <ls_fcat>-qfieldname = 'VRKME'.
      WHEN 'MEINS'.
        <ls_fcat>-coltext = '생산단위'(f11).
        <ls_fcat>-just = 'C'.
      WHEN 'MENGE'.
        <ls_fcat>-coltext = '생산수량'(f13).
        <ls_fcat>-no_out = abap_true.
        <ls_fcat>-just = 'R'.
        <ls_fcat>-qfieldname = 'MEINS'.
      WHEN 'MENGE2'.
        <ls_fcat>-coltext = '환산수량'(f12).
        <ls_fcat>-just = 'R'.
        <ls_fcat>-qfieldname = 'VRKME'.
      WHEN 'OPPSTATUS'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'DDTEXT'.
        <ls_fcat>-coltext = '영업기회상태'(f14).
        <ls_fcat>-just = 'C'.
      WHEN 'DPTYPE'.
        <ls_fcat>-coltext = '유형'(f15).
        <ls_fcat>-just = 'C'.
      WHEN 'SPART'.
        <ls_fcat>-coltext = '제품군'(f16).
        <ls_fcat>-just = 'C'.
      WHEN 'VBELN'.
        <ls_fcat>-coltext = '판매오더'(f17).
        <ls_fcat>-just = 'C'.
      WHEN 'POSNR'.
        <ls_fcat>-coltext = '오더품목'(f18).
        <ls_fcat>-just = 'C'.
      WHEN 'BUNAME'.
        <ls_fcat>-coltext = '팀명'(f19).
        <ls_fcat>-just = 'L'.
      WHEN 'PERNR'.
        <ls_fcat>-coltext = '담당자'(f20).
        <ls_fcat>-just = 'C'.
      WHEN 'MATNR_COLOR'. "2026.01.27.zlsgpp5.add.
        <ls_fcat>-tech = 'X'.
    ENDCASE.

    IF <ls_fcat>-fieldname CP 'ATTR*'. "2026.01.27.zlsgpp5.add.
      <ls_fcat>-coltext = |속성{ <ls_fcat>-fieldname+4(2) }|.
      <ls_fcat>-just = 'C'.
      <ls_fcat>-no_out = 'X'.
    ENDIF.

    <ls_fcat>-reptext = <ls_fcat>-tooltip = <ls_fcat>-coltext.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0400
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0400.

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0400
        USING : cl_gui_alv_grid=>mc_fc_excl_all.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0400_DISPLAY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
FORM call_grid_0400_display.

  CALL METHOD go_grid_0400->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0400
      it_toolbar_excluding = gt_exclude_0400
    CHANGING
      it_outtab            = gt_main_400
      it_fieldcatalog      = gt_fieldcat_0400.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_DP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_dp .

  DATA : lt_row TYPE lvc_t_row.
  DATA : ls_row TYPE lvc_s_row.
  DATA : ls_del_2080 TYPE zgtppt2080.
  DATA : lt_del_2080 TYPE TABLE OF zgtppt2080.
  DATA : BEGIN OF ls_chk_plnid,
           plnid TYPE zgtppt2080-plnid,
         END OF ls_chk_plnid.
  DATA : lt_chk_plnid LIKE TABLE OF ls_chk_plnid.

  CALL METHOD go_grid_0300->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

  DELETE lt_row WHERE index = 0. " 서브토탈 제외

  IF lt_row[] IS INITIAL.
    MESSAGE s005 DISPLAY LIKE 'E' WITH '선택된 라인이 없습니다.'(e02).
    RETURN.
  ENDIF.



  LOOP AT lt_row INTO ls_row.
    READ TABLE gt_main_300 ASSIGNING FIELD-SYMBOL(<ls_main>) INDEX ls_row-index.
    IF <ls_main>-chk_sales = abap_true AND <ls_main>-chk_simul = abap_true.
      MESSAGE s005 DISPLAY LIKE 'E' WITH '시뮬레이션에 등록된 판매계획건은 삭제할 수 없습니다.'.
      RETURN.
    ENDIF.

    CLEAR ls_chk_plnid.
    ls_chk_plnid-plnid = <ls_main>-plnid.
    COLLECT ls_chk_plnid INTO lt_chk_plnid.
  ENDLOOP.

  IF lt_chk_plnid[] IS NOT INITIAL.
    SELECT * FROM zgtppt2080
       FOR ALL ENTRIES IN @lt_chk_plnid
     WHERE plnid = @lt_chk_plnid-plnid
       INTO TABLE @DATA(lt_2080).

    SELECT * FROM zgtppt2090
       FOR ALL ENTRIES IN @lt_chk_plnid
     WHERE plnid = @lt_chk_plnid-plnid
       INTO TABLE @DATA(lt_2090).
    SORT lt_2090 BY plnid.
    DELETE ADJACENT DUPLICATES FROM lt_2090 COMPARING plnid.
  ENDIF.

  LOOP AT lt_row INTO ls_row.
    READ TABLE gt_main_300 ASSIGNING <ls_main> INDEX ls_row-index.
    DELETE lt_2080 WHERE werks = p_werks
         AND spgcd = p_spgcd
         AND plnid = <ls_main>-plnid
         AND cycltype = <ls_main>-cycltype
         AND vkbur = <ls_main>-vkbur
         AND spec = <ls_main>-itemname
         AND zpjno = <ls_main>-zpjno
         AND vbeln = <ls_main>-vbeln
         AND posnr = <ls_main>-posnr.
  ENDLOOP.

  LOOP AT lt_2090 INTO DATA(ls_2090).
    READ TABLE lt_2080 TRANSPORTING NO FIELDS WITH KEY plnid = ls_2090-plnid.
    IF sy-subrc NE 0. " 시뮬레이션 수립건중 plnID 전부 삭제되면 안됨 해당건에 추가 어팬드로 작업하기 위해 한건은 반드시 남겨두어야 한다.
      MESSAGE s005 DISPLAY LIKE 'E' WITH '생산 시뮬레이션에 등록된 이전 판매계획은 완전히 삭제할 수 없습니다.'.
    ENDIF.
  ENDLOOP.


  LOOP AT lt_row INTO ls_row.
    READ TABLE gt_main_300 ASSIGNING <ls_main> INDEX ls_row-index.

    SELECT SINGLE * FROM zgtppt2080
        INTO ls_del_2080
      WHERE werks = p_werks
         AND spgcd = p_spgcd
         AND plnid = <ls_main>-plnid
         AND cycltype = <ls_main>-cycltype
         AND vkbur = <ls_main>-vkbur
         AND spec = <ls_main>-itemname
         AND zpjno = <ls_main>-zpjno
         AND vbeln = <ls_main>-vbeln
         AND posnr = <ls_main>-posnr.

    IF sy-subrc EQ 0.
      ls_del_2080-delfl = abap_true.
      APPEND ls_del_2080 TO lt_del_2080.
    ENDIF.

  ENDLOOP.

  IF lt_del_2080[] IS NOT INITIAL.
    MODIFY zgtppt2080 FROM TABLE lt_del_2080.
    IF sy-subrc EQ 0.
      gv_chk_del_ok = abap_true.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.

*  삭제완료 후 종료
*     종료
  CALL METHOD go_docking_0300->free.

  FREE : go_docking_0300, go_grid_0300.
  CALL METHOD cl_gui_cfw=>flush.
  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_MATNR_AVAILABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MOD_CELLS_VALUE
*&      <-- LV_MEINS
*&      <-- LV_SUL
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM chk_matnr_available  USING    pv_value
                          CHANGING pv_meins TYPE meins
                                        pv_sul TYPE zesul_no
                                        pv_chk_err.

  DATA : lv_matnr TYPE matnr.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = pv_value
    IMPORTING
      output = lv_matnr.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input        = lv_matnr
    IMPORTING
      output       = lv_matnr
    EXCEPTIONS
      length_error = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  SELECT SINGLE a~matnr, a~meins, a~spart
      FROM mara AS a
      INNER JOIN t134 AS b ON b~mtart = a~mtart
      INNER JOIN marc AS c ON c~matnr = a~matnr
    WHERE a~matnr = @lv_matnr
      AND b~mtref = 'FERT' " 완제품만 조회
      AND c~werks = @p_werks
      INTO @DATA(ls_chk_matnr).

  IF sy-subrc EQ 0.
    pv_meins = ls_chk_matnr-meins.

    SELECT new_matnr AS matnr, spart, sul_no
      FROM zedt1000
      WHERE spart = @ls_chk_matnr-spart
         AND new_matnr = @lv_matnr
         AND werks = @p_werks
         AND sul_level = 'FT'
         AND status = 'Z'
        INTO TABLE @DATA(lt_sul_1000).
    IF sy-subrc EQ 0.
      READ TABLE lt_sul_1000 INTO DATA(ls_sul_1000) INDEX 1.
      pv_sul = ls_sul_1000-sul_no.
    ELSE.
      SELECT a~matnr, a~sul_no
         FROM zgtedt9020 AS a
        WHERE a~matnr = @lv_matnr
           AND a~werks = @p_werks
           AND a~zifkey = ( SELECT MAX( zifkey ) AS zifkey
                                      FROM zgtedt9020 AS b
                                    WHERE b~matnr = a~matnr
                                        AND b~werks = a~werks )
          INTO TABLE @DATA(lt_sul_9020).

      IF sy-subrc EQ 0.
        READ TABLE lt_sul_9020 INTO DATA(ls_sul_9020) INDEX 1.
        pv_sul = ls_sul_9020-sul_no.
      ENDIF.
    ENDIF.

  ELSE.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form TRANSLATE_UNIT_QUANTITY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LV_MEINS>
*&      --> LV_MEINS
*&      --> <LV_SO_UNIT>
*&      <-- <LV_SO_UNIT>
*&---------------------------------------------------------------------*
FORM translate_unit_quantity  USING    pv_unit_in TYPE t006-msehi
                                                            pv_unit_out TYPE t006-msehi
                                                            pv_input
                                           CHANGING    pv_output.

  CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
    EXPORTING
      input                = pv_input
      unit_in              = pv_unit_in
      unit_out             = pv_unit_out
    IMPORTING
      output               = pv_output
    EXCEPTIONS
      conversion_not_found = 1
      division_by_zero     = 2
      input_invalid        = 3
      output_invalid       = 4
      overflow             = 5
      type_invalid         = 6
      units_missing        = 7
      unit_in_not_found    = 8
      unit_out_not_found   = 9
      OTHERS               = 10.
  IF sy-subrc <> 0.
  ENDIF.

  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
    EXPORTING
      i_rtype     = '+'
      i_runit     = 1
      i_value     = pv_output
    IMPORTING
      e_value_rnd = pv_output.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_MP_DATAS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_mp_datas .

  DATA : lt_save_2080 TYPE TABLE OF zgtppt2080.

  CHECK gv_chk_edit IS NOT INITIAL.

  LOOP AT <gt_main_disp_200> ASSIGNING FIELD-SYMBOL(<ls_main>).

    ASSIGN COMPONENT 'CHECK' OF STRUCTURE <ls_main> TO FIELD-SYMBOL(<lv_check>).
    IF <lv_check> IS NOT INITIAL.

      ASSIGN COMPONENT 'PLNID' OF STRUCTURE <ls_main> TO FIELD-SYMBOL(<lv_plnid>).

      SELECT * FROM zgtppt2080
        INTO TABLE @DATA(lt_2080)
       WHERE plnid = @<lv_plnid>.
      IF sy-subrc EQ 0.
        LOOP AT lt_2080 ASSIGNING FIELD-SYMBOL(<ls_2080>).
          ASSIGN COMPONENT 'MATNR' OF STRUCTURE <ls_main> TO FIELD-SYMBOL(<lv_matnr>).
          <ls_2080>-matnr = <lv_matnr>.
          ASSIGN COMPONENT 'SUL_NO' OF STRUCTURE <ls_main> TO FIELD-SYMBOL(<lv_sul_no>).
          <ls_2080>-sul_no = <lv_sul_no>.
          ASSIGN COMPONENT 'MEINS' OF STRUCTURE <ls_main> TO FIELD-SYMBOL(<lv_meins>).
          <ls_2080>-meins = <lv_meins>.
          ASSIGN COMPONENT 'ALENR' OF STRUCTURE <ls_main> TO FIELD-SYMBOL(<lv_alenr>).
          <ls_2080>-alenr = <lv_alenr>.

        ENDLOOP.
        APPEND LINES OF lt_2080 TO lt_save_2080.
      ENDIF.

    ENDIF.

  ENDLOOP.

  CHECK lt_save_2080[] IS NOT INITIAL.

  CLEAR gv_answer.
  PERFORM popup_to_confirm_step USING 'N'
    ' '
    '수정사항 저장합니다. 계속 진행 하시겠습니까?'
    '변경확인'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  MODIFY zgtppt2080 FROM TABLE lt_save_2080.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '변경중 오류가 발생했습니다..'.
    RETURN.
  ENDIF.

  PERFORM check_and_set_capa TABLES lt_save_2080.

  PERFORM refresh_0100.
  MESSAGE s003 WITH '변경 완료되었습니다..'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP_FIELDCAT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_disp_fieldcat_grid_0200 .

  DATA : lv_fieldname_so TYPE fieldname.
  DATA : lv_fieldname_po TYPE fieldname.

  LOOP AT gt_spmon INTO gs_spmon.

    lv_fieldname_so = gs_spmon-spmon && '_SO'.
    lv_fieldname_po = gs_spmon-spmon && '_PO'.

    READ TABLE gt_fieldcat_0200 ASSIGNING FIELD-SYMBOL(<ls_fcat_so>) WITH KEY fieldname = lv_fieldname_so.
    READ TABLE gt_fieldcat_0200 ASSIGNING FIELD-SYMBOL(<ls_fcat_po>) WITH KEY fieldname = lv_fieldname_po.

    IF gt_range_spmon[] IS NOT INITIAL.

      IF gs_spmon-spmon IN gt_range_spmon.
        CLEAR <ls_fcat_so>-no_out .
        CLEAR <ls_fcat_po>-no_out .
      ELSE.
        <ls_fcat_so>-no_out = abap_true.
        <ls_fcat_po>-no_out = abap_true.
      ENDIF.
    ELSE.
      <ls_fcat_so>-no_out = abap_true.
      <ls_fcat_po>-no_out = abap_true.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_AND_SET_CAPA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SAVE_2080
*&---------------------------------------------------------------------*
FORM check_and_set_capa  TABLES   pt_save_2080 STRUCTURE zgtppt2080.

  DATA : lt_2080 TYPE TABLE OF zgtppt2080.

  lt_2080 = pt_save_2080[].
  SORT lt_2080 BY werks spgcd spec matnr.
  DELETE ADJACENT DUPLICATES FROM lt_2080 COMPARING werks spgcd spec matnr.

  IF lt_2080[] IS NOT INITIAL.
    SELECT * FROM zgtppt2120
      INTO TABLE @DATA(lt_2120)
      FOR ALL ENTRIES IN @lt_2080
     WHERE werks = @lt_2080-werks
        AND spgcd = @lt_2080-spgcd
        AND spec = @lt_2080-spec
        AND matnr = @lt_2080-matnr.
  ENDIF.

  SORT lt_2120 BY werks spgcd spec matnr.

*  데이터 점검후 배치 수행
  LOOP AT lt_2080 INTO DATA(ls_2080).
    READ TABLE lt_2120 TRANSPORTING NO FIELDS WITH KEY werks = ls_2080-werks
                                                      spgcd = ls_2080-spgcd
                                                      spec = ls_2080-spec
                                                      matnr = ls_2080-matnr
                                                      BINARY SEARCH.
    IF sy-subrc NE 0.
      PERFORM proc_backgroundjob USING ls_2080.
*    실행후 메시지 결과는 반영 안함
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_BACKGROUNDJOB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_2080
*&---------------------------------------------------------------------*
FORM proc_backgroundjob  USING    ps_2080 TYPE zgtppt2080.

  DATA : lv_jobname  LIKE tbtcjob-jobname,
         lv_jobcount LIKE tbtcjob-jobcount.

  DATA : lt_joblist TYPE TABLE OF tbtcjob.
  RANGES : lr_spec FOR zgtppt2080-spec,
             lr_matnr FOR zgtppt2080-matnr.

  DO.
*  백 그라운드 가용 잡 2개 (세팅에 따라 바뀔수 있음)
    CALL FUNCTION 'BP_FIND_JOBS_WITH_PROGRAM'
      EXPORTING
        abap_program_name             = 'ZGTPPR2070'
        status                        = 'R'
      TABLES
        joblist                       = lt_joblist
      EXCEPTIONS
        no_jobs_found                 = 1
        program_specification_missing = 2
        invalid_dialog_type           = 3
        job_find_canceled             = 4
        OTHERS                        = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    IF lines( lt_joblist ) > 1.
      WAIT UP TO 1 SECONDS.
    ELSE.
      EXIT.
    ENDIF.
  ENDDO.

*  백그라운드 수행
* 호출값 세팅
* 스팩
  APPEND INITIAL LINE TO lr_spec ASSIGNING FIELD-SYMBOL(<ls_spec>).
  <ls_spec>-sign = 'I'.
  <ls_spec>-option = 'EQ'.
  <ls_spec>-low = ps_2080-spec.

* 완제품코드
  IF ps_2080-matnr IS INITIAL.
  ELSE.
    APPEND INITIAL LINE TO lr_matnr ASSIGNING FIELD-SYMBOL(<ls_matnr>).
    <ls_matnr>-sign = 'I'.
    <ls_matnr>-option = 'EQ'.
    <ls_matnr>-low = ps_2080-matnr.
  ENDIF.

  lv_jobname = 'CALCULATE_CAPA'.


*  CALL FUNCTION 'JOB_OPEN'
*    EXPORTING
*      JOBNAME          = LV_JOBNAME
*    IMPORTING
*      JOBCOUNT         = LV_JOBCOUNT
*    EXCEPTIONS
*      CANT_CREATE_JOB  = 1
*      INVALID_JOB_DATA = 2
*      JOBNAME_MISSING  = 3
*      OTHERS           = 4.

  SET PARAMETER ID 'WRK' FIELD ps_2080-werks.

  SUBMIT zgtppr2070 "VIA JOB LV_JOBNAME
                   "NUMBER LV_JOBCOUNT
                  AND RETURN
                  WITH p_werks = ps_2080-werks
                  WITH p_spgcd = ps_2080-spgcd
                  WITH s_spec IN lr_spec
                  WITH s_matnf IN lr_matnr
                  WITH p_call = 'X'.


*  CALL FUNCTION 'JOB_CLOSE'
*    EXPORTING
*      JOBCOUNT             = LV_JOBCOUNT
*      JOBNAME              = LV_JOBNAME
*      STRTIMMED            = 'X'
*    EXCEPTIONS
*      CANT_START_IMMEDIATE = 1
*      INVALID_STARTDATE    = 2
*      JOBNAME_MISSING      = 3
*      JOB_CLOSE_FAILED     = 4
*      JOB_NOSTEPS          = 5
*      JOB_NOTEX            = 6
*      LOCK_FAILED          = 7
*      OTHERS               = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_cell_attribute_grid_0300 .

  DATA : lt_celltab TYPE lvc_t_styl.
  DATA : ls_celltab TYPE lvc_s_styl.
  FIELD-SYMBOLS <lt_celltab> TYPE any.

  LOOP AT gt_main_300 ASSIGNING FIELD-SYMBOL(<ls_data>).
    REFRESH lt_celltab.
*    IF <LS_DATA>-STATUS IS NOT INITIAL.
*
*      LOOP AT GT_FIELDCAT_0300 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
*        CLEAR LS_CELLTAB.
*        LS_CELLTAB-FIELDNAME = <LS_FCAT>-FIELDNAME.
*        LS_CELLTAB-STYLE = ALV_STYLE_COLOR_TOTAL.
*        INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
*      ENDLOOP.
*
*    ENDIF.

    IF <lt_celltab> IS ASSIGNED. UNASSIGN <lt_celltab>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <ls_data> TO <lt_celltab>.
    IF <lt_celltab> IS ASSIGNED.
      <lt_celltab> = lt_celltab.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0400
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
FORM set_cell_attribute_grid_0400 .

  DATA : lt_celltab TYPE lvc_t_styl.
  DATA : ls_celltab TYPE lvc_s_styl.
  FIELD-SYMBOLS <lt_celltab> TYPE any.

  LOOP AT gt_main ASSIGNING FIELD-SYMBOL(<ls_data>).
    REFRESH lt_celltab.

    CASE <ls_data>-stat_t.
      WHEN '대상선정'.
        CLEAR ls_celltab.
        ls_celltab-fieldname = 'STAT_T'.
        ls_celltab-style = alv_style_color_positive.
        INSERT ls_celltab INTO TABLE lt_celltab.
      WHEN '조장구성'.
        CLEAR ls_celltab.
        ls_celltab-fieldname = 'STAT_T'.
        ls_celltab-style = alv_style_color_total.
        INSERT ls_celltab INTO TABLE lt_celltab.
*      WHEN OTHERS. "2026.01.27.zlsgpp5.주석처리.
*        CONTINUE.  "2026.01.27.zlsgpp5.주석처리.
    ENDCASE.

    "/s 2026.01.27.zlsgpp5.CHM2601-00657.자재코드 필드 색 설정.
    CASE <ls_data>-matnr_color.
      WHEN 'G'. "green.
        CLEAR ls_celltab.
        ls_celltab-fieldname = 'MATNR'.
        ls_celltab-style = alv_style_color_positive.
        INSERT ls_celltab INTO TABLE lt_celltab.
      WHEN 'Y'. "yellow
        CLEAR ls_celltab.
        ls_celltab-fieldname = 'MATNR'.
        ls_celltab-style = alv_style_color_total.
        INSERT ls_celltab INTO TABLE lt_celltab.
    ENDCASE.

    CHECK lt_celltab[] IS NOT INITIAL.
    "/e 2026.01.27.zlsgpp5.CHM2601-00657.자재코드 필드 색 설정.

    IF <lt_celltab> IS ASSIGNED. UNASSIGN <lt_celltab>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <ls_data> TO <lt_celltab>.
    IF <lt_celltab> IS ASSIGNED.
      <lt_celltab> = lt_celltab.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_similar_matnr
*&---------------------------------------------------------------------*
*& 자재코드 연결.
*&---------------------------------------------------------------------*
*& 2026.01.27.zlsgpp5.CHM2601-00657.
*&---------------------------------------------------------------------*
FORM get_similar_matnr .

  DATA: lt_cells  TYPE lvc_t_ceno,
        lv_bukrs  LIKE ckiwerk-bukrs,
        ls_attr   TYPE zpls_attr,
        lv_retrun TYPE char1,
        lv_msg    TYPE char50,
        lv_matnr  TYPE matnr,
        lt_attr   LIKE TABLE OF zpls_matnr_attr.

*___셀 선택 확인.
  go_grid_0100->get_selected_cells_id(
     IMPORTING
      et_cells = lt_cells ).                " Cell IDs

  DELETE lt_cells WHERE row_id = 0.

  IF lt_cells[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '선택된 Cell이 없습니다.'(e01).
    RETURN.
  ENDIF.

  SORT lt_cells BY row_id.
  DELETE ADJACENT DUPLICATES FROM lt_cells COMPARING row_id.


*___Get Bukrs and BWkey from Plant
  CLEAR: lv_bukrs.
  CALL FUNCTION 'DETERMIN_BWKEY_BUKRS_FOR_PLANT'
    EXPORTING
      werk  = p_werks
    IMPORTING
      bukrs = lv_bukrs.


*___자재코드 연결
  LOOP AT lt_cells INTO DATA(ls_cells).

    CLEAR: ls_attr, lv_retrun, lv_msg, lv_matnr.

    READ TABLE gt_main  ASSIGNING FIELD-SYMBOL(<gt_main>)
                        INDEX ls_cells-row_id.
    CHECK sy-subrc EQ 0.

    "자재코드가 없는 건만 진행.
    CHECK <gt_main>-matnr IS INITIAL.

    "속성 값이 모두 없으면 자재코드 연결하지 않음.
    IF <gt_main>-attr01 IS INITIAL AND
       <gt_main>-attr02 IS INITIAL AND
       <gt_main>-attr03 IS INITIAL AND
       <gt_main>-attr04 IS INITIAL AND
       <gt_main>-attr05 IS INITIAL AND
       <gt_main>-attr06 IS INITIAL AND
       <gt_main>-attr07 IS INITIAL AND
       <gt_main>-attr08 IS INITIAL.
      CONTINUE.
    ENDIF.

    "속성 값
    MOVE-CORRESPONDING <gt_main> TO ls_attr.

    CALL FUNCTION 'Z_PLS_GET_SIMILAR_MATNR_V2'
      EXPORTING
        i_bukrs  = lv_bukrs
        i_group  = '1130'   "1130 : 지중
        is_attr  = ls_attr
      IMPORTING
        e_retrun = lv_retrun
        e_msg    = lv_msg
        e_matnr  = lv_matnr
      TABLES
        et_attr  = lt_attr.

    IF lv_matnr IS NOT INITIAL.
      <gt_main>-matnr = lv_matnr.
      <gt_main>-matnr_color = c_yellow.
      DATA(lv_message) = |연결 완료되었습니다.|.

      "자재코드 연결된 건은 별도 itab에 보관.
      APPEND <gt_main> TO gt_similar.
    ENDIF.
  ENDLOOP.

  IF lv_message IS INITIAL.
    MESSAGE s005 DISPLAY LIKE 'W' WITH '처리할 대상이 없습니다.'.
    RETURN.
  ELSE.
    MESSAGE s005 WITH lv_message.
  ENDIF.


*___refresh alv.
  PERFORM refresh_0100.
*  PERFORM refresh_grid USING go_grid_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_posnr_data
*&---------------------------------------------------------------------*
*& 2026.01.29.zlsgpp5.CHM2601-00657.
*&  - 합계 건은 품목번호별 데이터를 가져와서 별도 itab으로 분리 보관.
*&---------------------------------------------------------------------*
FORM get_posnr_data  CHANGING pt_main LIKE gt_main
                              pt_400  LIKE gt_main.

  CLEAR: pt_400.
  LOOP AT pt_main ASSIGNING FIELD-SYMBOL(<main>).
    CHECK <main>-vbeln IS NOT INITIAL AND
          <main>-posnr IS INITIAL.

    LOOP AT gt_main_org INTO DATA(ls_org)
                        WHERE cycltype = <main>-cycltype
                          AND vkbur = <main>-vkbur
                          AND itemname = <main>-itemname
                          AND zpjno = <main>-zpjno
                          AND matnr = <main>-matnr
                          AND vbeln = <main>-vbeln.
      CHECK ls_org-stat_t IS INITIAL. "선정된 건 제외.
      APPEND ls_org TO pt_400.
    ENDLOOP.

    <main>-vbeln = c_delete.
  ENDLOOP.
  DELETE pt_main WHERE vbeln EQ c_delete.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_screen_0400
*&---------------------------------------------------------------------*
*& 2026.01.29.zlsgpp5.CHM2601-00657.합계된 경우 사용자가 품목 선택.
*&---------------------------------------------------------------------*
FORM call_screen_0400  CHANGING pt_main LIKE gt_main.

  "데이터가 없으면 종료.
  CHECK pt_main[] IS NOT INITIAL.

  "합계 건은 품목번호 데이터를 가져와서 별도 itab으로 분리 보관.
  PERFORM get_posnr_data CHANGING pt_main gt_main_400.

  "합계된 건은 사용자가 화면에서 품목 선택.
  IF gt_main_400[] IS NOT INITIAL.
    CALL SCREEN 400 STARTING AT 5 5 ENDING AT 180 30.
  ENDIF.

  "사용자가 선택한 라인만 대상.
  IF gt_main_400[] IS NOT INITIAL.
    APPEND LINES OF gt_main_400[] TO pt_main.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm_screen_400
*&---------------------------------------------------------------------*
*& 2026.01.29.zlsgpp5.CHM2601-00657.합계된 경우 사용자가 품목 선택.
*&---------------------------------------------------------------------*
FORM confirm_screen_400 .

  "사용자가 선택한 건을 추가.
  DATA: lt_row TYPE lvc_t_row,
        ls_row TYPE lvc_s_row.
  DATA: lt_main LIKE TABLE OF gs_main.

  "선택한 라인
  CALL METHOD go_grid_0400->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

  DELETE lt_row WHERE index = 0.

*  IF lt_row[] IS INITIAL.
*    MESSAGE s005 DISPLAY LIKE 'E' WITH '선택된 라인이 없습니다.'(e02).
*  ENDIF.

  "itab 담기
  CLEAR: lt_main.
  LOOP AT lt_row INTO ls_row.
    READ TABLE gt_main_400 ASSIGNING FIELD-SYMBOL(<main>) INDEX ls_row-index.
    IF sy-subrc EQ 0.
      APPEND <main> TO lt_main.
    ENDIF.
  ENDLOOP.
  gt_main_400[] = lt_main[].

  "종료
  CALL METHOD go_docking_0400->free.

  FREE : go_docking_0400, go_grid_0400.
  CALL METHOD cl_gui_cfw=>flush.
  LEAVE TO SCREEN 0.

ENDFORM.
