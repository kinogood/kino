*&---------------------------------------------------------------------*
*& Include          ZGTSDR1040ALV
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form create_grid
*&---------------------------------------------------------------------*
FORM create_grid
     USING  pi_screen
            po_main_dock  TYPE REF TO cl_gui_docking_container.

**
  CASE pi_screen.
    WHEN '100'.
      PERFORM create_main_screen_alv   USING  pi_screen
                                              po_main_dock.
  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_main_screen_alv
*&---------------------------------------------------------------------*
FORM create_main_screen_alv
     USING  pi_screen
            po_main_dock  TYPE REF TO cl_gui_docking_container.

**
  IF po_main_dock IS INITIAL.
*   1. Create container.
    PERFORM create_dock_container   USING  po_main_dock.

*   2. Split Container.
    PERFORM split_container_grid    USING  po_main_dock
                                           go_split
                                           go_cont_t
                                           go_cont_h
                                           go_cont_i
                                           go_grid_top
                                           go_grid_h
                                           go_grid_i.

*   3. Set ALV attributes - Header.
    PERFORM make_alv_attributes     USING  pi_screen
                                           'H'
                                           go_grid_h
                                           gt_fcat_h
                                           gt_toolbar_h
                                           gt_sort_h
                                           gs_layout_h
                                           gs_variant_h.

*   4. Set ALV attributes - Item.
    PERFORM make_alv_attributes     USING  pi_screen
                                           'I'
                                           go_grid_i
                                           gt_fcat_i
                                           gt_toolbar_i
                                           gt_sort_i
                                           gs_layout_i
                                           gs_variant_i.

  ELSE.
    PERFORM refresh_alv             USING: go_grid_h,
                                           go_grid_i.
    PERFORM set_split_cont_height   USING  go_split.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_dock_container
*&---------------------------------------------------------------------*
FORM create_dock_container  USING  po_container
                                   TYPE REF TO cl_gui_docking_container.

**
  CREATE OBJECT po_container
    EXPORTING
      parent                      = cl_gui_container=>default_screen
      repid                       = sy-repid
      dynnr                       = sy-dynnr
      side                        = cl_gui_docking_container=>dock_at_top
      extension                   = 3000
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form split_container_grid
*&---------------------------------------------------------------------*
FORM split_container_grid
     USING    po_main_dock  TYPE REF TO cl_gui_docking_container
              po_split      TYPE REF TO cl_gui_splitter_container
              po_cont_t     TYPE REF TO cl_gui_container
              po_cont_h     TYPE REF TO cl_gui_container
              po_cont_i     TYPE REF TO cl_gui_container
              po_grid_top   TYPE REF TO cl_gui_alv_grid
              po_grid_h     TYPE REF TO cl_gui_alv_grid
              po_grid_i     TYPE REF TO cl_gui_alv_grid.

**
* Split.
  CREATE OBJECT po_split
    EXPORTING
      parent  = po_main_dock
      rows    = 3
      columns = 1.

* Set Container Top.
  CALL METHOD po_split->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = po_cont_t.

* Set Container Header.
  CALL METHOD po_split->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = po_cont_h.

* Set Container Item.
  CALL METHOD po_split->get_container
    EXPORTING
      row       = 3
      column    = 1
    RECEIVING
      container = po_cont_i.

* Top of page
  CREATE OBJECT go_docid
    EXPORTING
      style = 'ALV_GRID'.

* Set Grid Header.
  CREATE OBJECT po_grid_h
    EXPORTING
      i_parent = po_cont_h.

* Set Grid Item.
  CREATE OBJECT po_grid_i
    EXPORTING
      i_parent = po_cont_i.

  PERFORM set_split_cont_height   USING  po_split.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_split_cont_height
*&---------------------------------------------------------------------*
FORM set_split_cont_height  USING  po_split
                                    TYPE REF TO cl_gui_splitter_container.

**
  CHECK: po_split IS NOT INITIAL.

* Top of Page
  CALL METHOD po_split->set_row_height
    EXPORTING
      id     = 1
      height = 10.

* Header Container
  IF gt_item[] IS INITIAL.
    CALL METHOD po_split->set_row_height
      EXPORTING
        id     = 2
        height = 90.
  ELSE.
    CALL METHOD po_split->set_row_height
      EXPORTING
        id     = 2
        height = 40.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_alv_attributes
*&---------------------------------------------------------------------*
FORM make_alv_attributes  USING    pi_screen
                                   pi_type
                                   po_grid     TYPE REF TO cl_gui_alv_grid
                                   pt_fcat     TYPE lvc_t_fcat
                                   pt_toolbar  TYPE ui_functions
                                   pt_sort     TYPE lvc_t_sort
                                   ps_layout   TYPE lvc_s_layo
                                   ps_variant  TYPE disvariant.

**
* 1. Set Layout
  PERFORM set_alv_layout         USING  pi_screen
                                        pi_type
                                        ps_layout.
* 2. Set variant.
  PERFORM set_variant            USING  pi_screen
                                        pi_type
                                        ps_variant.
* 3. Set Sort.
  PERFORM set_sort_field         USING  pi_screen
                                        pi_type
                                        pt_sort.
* 4. Set Toolbar excluding.
  PERFORM set_excluding_toolbar  USING  pi_screen
                                        pi_type
                                        pt_toolbar.
* 5. Set Fieldcatalog.
  PERFORM set_fieldcatalog       USING  pi_screen
                                        pi_type
                                        pt_fcat.

* 6. Set Event.
  PERFORM set_event              USING  pi_screen
                                        pi_type
                                        po_grid.
* 7. Alv display
  PERFORM alv_first_display      USING  pi_screen
                                        pi_type
                                        po_grid
                                        pt_fcat
                                        pt_toolbar
                                        pt_sort
                                        ps_layout
                                        ps_variant .

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_alv_layout
*&---------------------------------------------------------------------*
FORM set_alv_layout  USING    pi_screen
                              pi_type
                              ps_layout  TYPE lvc_s_layo.

**
  CLEAR ps_layout.
  CASE pi_screen.
    WHEN '100'.
      ps_layout = VALUE #( sel_mode   = 'B'
                           zebra      = 'X'
                           no_rowmark = 'X'
*                           cwidth_opt = 'X'
                           ctab_fname = 'COLOR_TAB'
                           stylefname = 'STYLE_TAB' ).

    WHEN '200'.
      ps_layout = VALUE #( sel_mode   = 'B'
                           zebra      = 'X'
                           no_rowmark = 'X'
                           cwidth_opt = 'X' ).

    WHEN OTHERS.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_variant
*&---------------------------------------------------------------------*
FORM set_variant  USING    pi_screen
                           pi_type
                           ps_variant  TYPE disvariant.

**
  CLEAR: ps_variant.
  ps_variant-report  = sy-repid.
*
  CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
    EXPORTING
      i_save        = 'A'
    CHANGING
      cs_variant    = ps_variant
    EXCEPTIONS
      wrong_input   = 1
      not_found     = 2
      program_error = 3
      OTHERS        = 4.

  IF sy-subrc <> 0.
    CLEAR ps_variant-variant.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_sort_field
*&---------------------------------------------------------------------*
FORM set_sort_field  USING    pi_screen
                              pi_type
                              pt_sort    TYPE lvc_t_sort.

**
  _clear: pt_sort.
  CASE pi_screen.
    WHEN '100'.
      IF pi_type = 'I'.
        PERFORM set_sort_field_dtl   USING: pt_sort '1' 'ZPJNO'  ' ' ' ' 'X'.
        PERFORM set_sort_field_dtl   USING: pt_sort '1' 'FLD_06' ' ' ' ' ''.
      ENDIF.

    WHEN '200'.
      IF pi_type = '2'.
        PERFORM set_sort_field_dtl   USING: pt_sort '1' 'VBELN'     'X' ' ' ' ',
                                            pt_sort '1' 'POSNR'     'X' ' ' ' ',
                                            pt_sort '1' 'DO_VBELN'  'X' ' ' ' ',
                                            pt_sort '1' 'DO_POSNR'  'X' ' ' ' '.
      ENDIF.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_sort_field_dtl
*&---------------------------------------------------------------------*
FORM set_sort_field_dtl  USING   pt_sort TYPE lvc_t_sort
                                 pi_spos
                                 pi_fldname
                                 pi_up
                                 pi_down
                                 pi_subtot.

**
  APPEND VALUE #( spos      = pi_spos
                  fieldname = pi_fldname
                  up        = pi_up
                  down      = pi_down
                  subtot    = pi_subtot ) TO pt_sort.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_excluding_toolbar
*&---------------------------------------------------------------------*
FORM set_excluding_toolbar  USING    pi_screen
                                     pi_type
                                     pt_exclude  TYPE ui_functions.
**
  _clear: pt_exclude.

  APPEND: cl_gui_alv_grid=>mc_fc_loc_undo            TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_data_save           TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_loc_copy            TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_loc_copy_row        TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_loc_cut             TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_loc_delete_row      TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_loc_insert_row      TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_loc_move_row        TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_loc_append_row      TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_loc_paste           TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_loc_paste_new_row   TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_refresh             TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_check               TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_print               TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_views               TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_graph               TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_detail              TO pt_exclude,
          cl_gui_alv_grid=>mc_fc_info                TO pt_exclude.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_fieldcatalog
*&---------------------------------------------------------------------*
FORM set_fieldcatalog  USING    pi_screen
                                pi_type
                                pt_fcat    TYPE lvc_t_fcat.

**
  CASE pi_screen.
    WHEN '100'.
      IF     pi_type = 'H'.
        PERFORM get_field_catalog         USING    gt_head[]
                                          CHANGING pt_fcat.
        PERFORM maintain_fieldcatalog     USING    pt_fcat
                                                   pi_type.

      ELSEIF pi_type = 'I'.
        PERFORM get_field_catalog         USING    gt_item[]
                                          CHANGING pt_fcat.
        PERFORM maintain_fieldcatalog     USING    pt_fcat
                                                   pi_type.
      ENDIF.

    WHEN '200'.
      PERFORM get_field_catalog           USING    gt_do_info[]
                                          CHANGING pt_fcat.
      PERFORM maintain_fieldcatalog       USING    pt_fcat
                                                   pi_type.

    WHEN OTHERS.
  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_field_catalog
*&---------------------------------------------------------------------*
FORM get_field_catalog  USING    pt_table     TYPE table
                        CHANGING pt_fieldcat  TYPE lvc_t_fcat.

**
  _clear: pt_fieldcat.
  pt_fieldcat = zgtsd_cl_common=>get_field_catalog( it_table = pt_table ).

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form maintain_fieldcatalog
*&---------------------------------------------------------------------*
FORM maintain_fieldcatalog    USING    pt_fcat    TYPE lvc_t_fcat
                                       pi_type.

**
  CHECK: pt_fcat[] IS NOT INITIAL.

  DATA(lv_edit) = 'X'.

  MODIFY pt_fcat  FROM VALUE #( tech = 'X' )
                  TRANSPORTING tech
                  WHERE fieldname NE space.

  CLEAR: gv_pos.
  IF     pi_type = 'H'.    " Header.
    PERFORM set_fieldcat_info
*                Fcat / Fieldname / Text / Key / Just / Edit / SUM / Color
            USING: pt_fcat  'CHK'           '선택'           'X' 'C' 'X' ' ' ' ',
                   pt_fcat  'SAVE'          '정산 Data'      'X' 'C' ' ' ' ' ' ',
                   pt_fcat  'STAT'          '정산상태'       'X' 'C' ' ' ' ' ' ',
                   pt_fcat  'KUNAG'         '판매처'         'X' 'C' ' ' ' ' ' ',
                   pt_fcat  'CUSTOMERNAME'  '판매처명'       'X' 'L' ' ' ' ' ' ',
                   pt_fcat  'MATNR'         '자재코드'       ' ' 'C' ' ' ' ' ' ',
                   pt_fcat  'ARKTX'         '자재내역'       ' ' 'L' ' ' ' ' ' ',
                   pt_fcat  'SPMON'         '매출월'         ' ' 'C' ' ' ' ' ' ',
                   pt_fcat  'CUR_LFIMG'     '당월출고실적'   ' ' 'R' ' ' ' ' ' ',
                   pt_fcat  'LFIMG'         '판매량'         ' ' 'R' ' ' ' ' ' ',
                   pt_fcat  'VRKME'         '단위'           ' ' 'C' ' ' ' ' ' ',
                   pt_fcat  'NETWR'         '공급가액'       ' ' 'R' ' ' ' ' ' ',
                   pt_fcat  'MWSBP'         '부가세액'       ' ' 'R' ' ' ' ' ' ',
                   pt_fcat  'WAERK'         '통화'           ' ' 'C' ' ' ' ' ' ',

                   pt_fcat  'OEMN_GRQTY'   'OEM 일반입고량'      ' ' 'R' ' ' ' ' ' ',
                   pt_fcat  'OEML_GRQTY'   'OEM 로컬입고량'      ' ' 'R' ' ' ' ' ' ',

                   pt_fcat  'OEMGR_QTY'     'OEM입고량'      ' ' 'R' ' ' ' ' 'C500',
                   pt_fcat  'DRS_QTY'       '직판수량'       ' ' 'R' ' ' ' ' 'C500',
                   pt_fcat  'ADJ_AVG_NETPR' '정산 평균단가'  ' ' 'R' ' ' ' ' 'C300',
                   pt_fcat  'ADJ_AVG_NETWR' '정산 공급가액'  ' ' 'R' ' ' ' ' 'C300',
                   pt_fcat  'ADJ_AVG_MWSBP' '정산 부가세액'  ' ' 'R' ' ' ' ' 'C300',
                   pt_fcat  'DIFF_NETWR'    '공급가액 차액'  ' ' 'R' ' ' ' ' 'C100',
                   pt_fcat  'DIFF_MWSBP'    '부가세액 차액'  ' ' 'R' ' ' ' ' 'C100',
                   pt_fcat  'MESSAGE'       'Message'        ' ' 'L' ' ' ' ' ' '.

  ELSEIF pi_type = 'I'.    " Item.
    PERFORM set_fieldcat_info
*                Fcat / Fieldname / Text / Key / Just / Edit / SUM / Color
            USING: pt_fcat  'SAVE'          '정산 Data'      'X' 'C' ' ' ' ' ' ',
*                   pt_fcat  'STAT'          '정산상태'       'X' 'C' ' ' ' ',
                   pt_fcat  'ZPJNO'         '프로젝트'       'X' 'L' ' ' ' ' ' ',
                   pt_fcat  'ZPTXT'         '프로젝트명'     'X' 'L' ' ' ' ' ' ',
                   pt_fcat  'ZSEGLEV2T'     '세그먼트'       'X' 'L' ' ' ' ' ' ',
                   pt_fcat  'SPMON'         '매출정산월'     'X' 'C' ' ' ' ' ' ',
                   pt_fcat  'FKIMG'         '정산 수량'      'X' 'R' 'X' 'X' ' ',
                   pt_fcat  'VRKME'         '단위'           ' ' 'C' ' ' ' ' ' ',
                   pt_fcat  'KONDMT'        '가공비 유형'    ' ' 'L' ' ' ' ' ' ',
                   pt_fcat  'KBETR'         '가공비'         ' ' 'R' ' ' ' ' ' ',
                   pt_fcat  'NFPRICE'       '월 평균 동가'   ' ' 'R' ' ' ' ' ' ',
                   pt_fcat  'NETPR'         '정산 단가'      ' ' 'R' ' ' ' ' ' ',
                   pt_fcat  'NETWR'         '공급가액'       ' ' 'R' ' ' 'X' ' ',
                   pt_fcat  'MWSBP'         '부가세액'       ' ' 'R' ' ' 'X' ' ',
                   pt_fcat  'WAERK'         '통화'           ' ' 'C' ' ' ' ' ' ',
                   pt_fcat  'VBELN'         '판매오더'       ' ' 'C' ' ' ' ' ' ',
                   pt_fcat  'POSNR'         '품목번호'       ' ' 'R' ' ' ' ' ' ',
                   pt_fcat  'DO_VBELN'      '납품오더'       ' ' 'C' ' ' ' ' ' ',
                   pt_fcat  'DO_POSNR'      '납품오더품목'   ' ' 'R' ' ' ' ' ' ',
                   pt_fcat  'MBLNR'         'GI No'          ' ' 'C' ' ' ' ' ' ',
                   pt_fcat  'BL_VBELN'      'Billing'        ' ' 'C' ' ' ' ' ' ',
                   pt_fcat  'BL_POSNR'      'Billing품번'    ' ' 'R' ' ' ' ' ' ',
                   pt_fcat  'MESSAGE'       'Message'        ' ' 'L' ' ' ' ' ' ',
                   pt_fcat  'FLD_06'        '순서'           ' ' 'C' ' ' ' ' ' '.

  ELSEIF pi_type = '2'.    " Screen 200

    PERFORM set_fieldcat_info
*                Fcat / Fieldname / Text / Key / Just / Edit / SUM / Color
            USING: pt_fcat  'ZPJNO'         '프로젝트'       'X' 'L' ' ' ' ' ' ',
                   pt_fcat  'ZPTXT'         '프로젝트명'     'X' 'L' ' ' ' ' ' ',
                   pt_fcat  'KUNAG'         '판매처'         'X' 'C' ' ' ' ' ' ',
                   pt_fcat  'CUSTOMERNAME'  '판매처명'       'X' 'L' ' ' ' ' ' ',
                   pt_fcat  'MATNR'         '자재코드'       ' ' 'C' ' ' ' ' ' ',
                   pt_fcat  'ARKTX'         '자재내역'       ' ' 'L' ' ' ' ' ' ',
                   pt_fcat  'VBELN'         '판매오더'       ' ' 'C' ' ' ' ' ' ',
                   pt_fcat  'POSNR'         '품목번호'       ' ' 'R' ' ' ' ' ' ',
                   pt_fcat  'DO_VBELN'      '납품오더'       ' ' 'C' ' ' ' ' ' ',
                   pt_fcat  'DO_POSNR'      '납품오더품목'   ' ' 'R' ' ' ' ' ' ',
                   pt_fcat  'LFIMG'         '출고량'         ' ' 'R' ' ' 'X' ' ',
                   pt_fcat  'VRKME'         '단위'           ' ' 'C' ' ' ' ' ' ',
                   pt_fcat  'WADAT_IST'     '출고일자'       ' ' 'C' ' ' ' ' ' ' .

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_fieldcat_info
*&---------------------------------------------------------------------*
FORM set_fieldcat_info  USING    pt_fcat  TYPE lvc_t_fcat
                                 pi_fname
                                 pi_text
                                 pi_key
                                 pi_just
                                 pi_edit
                                 pi_sum
                                 pi_color.

**
  READ TABLE pt_fcat  ASSIGNING FIELD-SYMBOL(<lfs_fcat>)
                      WITH KEY fieldname = pi_fname.

  IF <lfs_fcat> IS ASSIGNED.

    CLEAR: <lfs_fcat>-tech.

    gv_pos = gv_pos + 1.
    <lfs_fcat>-col_pos = gv_pos.
    <lfs_fcat>-key     = pi_key.
    <lfs_fcat>-just    = pi_just.
    <lfs_fcat>-edit    = pi_edit.
    <lfs_fcat>-coltext = pi_text.

    IF pi_color IS NOT INITIAL.
      <lfs_fcat>-emphasize = pi_color.
    ENDIF.

    IF pi_sum IS NOT INITIAL.
      <lfs_fcat>-do_sum = 'X'.
    ENDIF.

    IF pi_fname EQ 'FLD_06'.
      <lfs_fcat>-no_out = 'X'.
    ENDIF.

    IF pi_fname EQ 'MESSAGE'.
      <lfs_fcat>-outputlen = 30.
      CLEAR: <lfs_fcat>-col_opt.
    ELSE.
      <lfs_fcat>-col_opt = 'X'.
    ENDIF.

    <lfs_fcat>-scrtext_s = <lfs_fcat>-scrtext_m =
    <lfs_fcat>-scrtext_l = <lfs_fcat>-reptext = <lfs_fcat>-coltext.

    IF     pi_fname = 'CHK'.
      <lfs_fcat>-checkbox = 'X'.

    ELSEIF pi_fname = 'SAVE' OR
           pi_fname = 'STAT'.
      <lfs_fcat>-icon     = 'X'.
*
    ELSEIF pi_fname = 'KBETR'. " 가공비
      <lfs_fcat>-decimals_o  = 0.
      <lfs_fcat>-decimals    = 0.
      CLEAR: <lfs_fcat>-ref_field, <lfs_fcat>-ref_table.

    ELSEIF pi_fname = 'VBELN'    OR    " 판매오더
           pi_fname = 'DO_VBELN' OR    " 납품오더
           pi_fname = 'MBLNR'    OR    " GI No
           pi_fname = 'BL_VBELN' .     " Billing
      <lfs_fcat>-hotspot = 'X'.
      <lfs_fcat>-outputlen = 10.
      CLEAR: <lfs_fcat>-col_opt.

    ENDIF.

  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_event
*&---------------------------------------------------------------------*
FORM set_event  USING    pi_screen
                         pi_type
                         po_grid     TYPE REF TO cl_gui_alv_grid.

**
  CALL METHOD po_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

* Event Handler
  CREATE OBJECT go_event_handler.

  IF     pi_type = 'H'.

    SET HANDLER: go_event_handler->top_of_page          FOR po_grid,
                 go_event_handler->handle_double_click  FOR po_grid.

    CALL METHOD go_docid->initialize_document
      EXPORTING
        background_color = cl_dd_area=>col_textarea.

    CALL METHOD po_grid->list_processing_events
      EXPORTING
        i_event_name = 'TOP_OF_PAGE'
        i_dyndoc_id  = go_docid.

  ELSEIF pi_type = 'I'.
    SET HANDLER: go_event_handler->handle_toolbar       FOR po_grid,
                 go_event_handler->handle_user_command  FOR po_grid,
                 go_event_handler->handle_hotspot_click FOR po_grid.

  ELSEIF pi_type = '2'.
    SET HANDLER: go_event_handler->handle_hotspot_click_200  FOR po_grid.
  ENDIF.

  CALL METHOD po_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.                " Ready for Input Status

  SET HANDLER: go_event_handler->handle_data_changed  FOR po_grid,
               go_event_handler->handle_data_changed_finished FOR po_grid.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form alv_first_display
*&---------------------------------------------------------------------*
FORM alv_first_display  USING  pi_screen
                               pi_type
                               po_grid     TYPE REF TO cl_gui_alv_grid
                               pt_fcat     TYPE lvc_t_fcat
                               pt_toolbar  TYPE ui_functions
                               pt_sort     TYPE lvc_t_sort
                               ps_layout   TYPE lvc_s_layo
                               ps_variant  TYPE disvariant.

**
  CHECK: pt_fcat[] IS NOT INITIAL.

  CASE pi_screen.
    WHEN '100'.
      IF     pi_type = 'H'.
        CALL METHOD po_grid->set_table_for_first_display
          EXPORTING
            is_layout            = ps_layout
            it_toolbar_excluding = pt_toolbar
            i_save               = 'A'
            is_variant           = ps_variant
          CHANGING
            it_outtab            = gt_head[]
            it_fieldcatalog      = pt_fcat[]
            it_sort              = pt_sort[].

      ELSEIF pi_type = 'I'.
        CALL METHOD po_grid->set_table_for_first_display
          EXPORTING
            is_layout            = ps_layout
            it_toolbar_excluding = pt_toolbar
            i_save               = 'A'
            is_variant           = ps_variant
          CHANGING
            it_outtab            = gt_item[]
            it_fieldcatalog      = pt_fcat[]
            it_sort              = pt_sort[].

      ENDIF.

    WHEN '200'.
      CALL METHOD po_grid->set_table_for_first_display
        EXPORTING
          is_layout            = ps_layout
          it_toolbar_excluding = pt_toolbar
          i_save               = 'A'
          is_variant           = ps_variant
        CHANGING
          it_outtab            = gt_do_info[]
          it_fieldcatalog      = pt_fcat[]
          it_sort              = pt_sort[].

    WHEN OTHERS.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form refresh_alv
*&---------------------------------------------------------------------*
FORM refresh_alv  USING    po_grid   TYPE REF TO cl_gui_alv_grid.

  DATA: ls_scroll           TYPE lvc_s_stbl.

**
  CLEAR: ls_scroll.
  ls_scroll-row = 'X'.
  ls_scroll-col = 'X'.

  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      i_soft_refresh = ' '
      is_stable      = ls_scroll.     "화면 라인 Refresh

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_top_of_page
*&---------------------------------------------------------------------*
FORM make_top_of_page  USING    po_document  TYPE REF TO cl_dd_document.

  DATA: lv_text      TYPE sdydo_text_element,
        lv_price(20),
        lv_def(10).

**
  CLEAR: lv_text.
* 매출정산 월
  lv_text = |{ TEXT-002 }| && | { ':' } | &&
            |{ gv_spmon+0(4) }| && |{ '.' }| && |{ gv_spmon+4(2) }|.

* Add Text : Header
  CALL METHOD po_document->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = cl_dd_area=>large
      sap_emphasis = cl_dd_area=>strong.

  CALL METHOD po_document->new_line( ).

  CLEAR: lv_text, lv_price, lv_def.
  WRITE: gs_nfprice-price  TO lv_price CURRENCY 'KRW',
         gs_nfprice-defper TO lv_def   UNIT 'KG'.

* 평균 동가
  lv_text = |{ TEXT-003 }| && | { ':' } | &&
            |{ lv_price }| && | { 'KRW' }| && | { '/' } | &&
            |{ lv_def }| && | { 'KG' }|.

  CALL METHOD po_document->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = cl_dd_area=>large
      sap_emphasis = cl_dd_area=>strong.

* Display
  CALL METHOD po_document->display_document
    EXPORTING
      reuse_control = 'X'
      parent        = go_cont_t.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form data_changed
*&---------------------------------------------------------------------*
FORM data_changed  USING    pr_data_changed
                            TYPE REF TO cl_alv_changed_data_protocol
                            pi_sender.

  DATA : ls_mod_cells  TYPE lvc_s_modi,
         ls_cells      TYPE lvc_s_modi,

         lv_fkimg      TYPE fkimg,
         lv_oeml_grqty TYPE zgteoemgr_qty,
         lv_oemn_grqty TYPE zgteoemgr_qty,

         lv_err(1),
         lv_msg(100).

**
  CASE pi_sender.

    WHEN go_grid_h.
      LOOP AT pr_data_changed->mt_good_cells INTO ls_mod_cells.
        CASE ls_mod_cells-fieldname.
          WHEN 'OEMN_GRQTY'.
            CLEAR lv_oemn_grqty.
            lv_oemn_grqty = ls_mod_cells-value.
            CLEAR gs_head.
            gs_head = VALUE #( gt_head[ ls_mod_cells-row_id ]  OPTIONAL ).
            IF gs_head IS NOT INITIAL.
              IF ( gs_head-oeml_grqty + lv_oemn_grqty ) > gs_head-lfimg.
                lv_msg = TEXT-e37.
                PERFORM err_protocol_entry  USING  pr_data_changed
                                                   ls_mod_cells-fieldname
                                                   ls_mod_cells-row_id
                                                   lv_msg.

              ENDIF.
            ENDIF.
          WHEN 'OEML_GRQTY'.
            CLEAR lv_oeml_grqty.
            lv_oeml_grqty = ls_mod_cells-value.
            CLEAR gs_head.
            gs_head = VALUE #( gt_head[ ls_mod_cells-row_id ]  OPTIONAL ).
            IF gs_head IS NOT INITIAL.
              IF ( gs_head-oemn_grqty + lv_oeml_grqty ) > gs_head-lfimg.
                lv_msg = TEXT-e37.
                PERFORM err_protocol_entry  USING  pr_data_changed
                                                   ls_mod_cells-fieldname
                                                   ls_mod_cells-row_id
                                                   lv_msg.

              ENDIF.
            ENDIF.

        ENDCASE.
      ENDLOOP.

    WHEN go_grid_i.
      LOOP AT pr_data_changed->mt_good_cells INTO ls_mod_cells.
        CASE ls_mod_cells-fieldname.
          WHEN 'FKIMG'.
            CLEAR: lv_fkimg.
            lv_fkimg = ls_mod_cells-value.

            DATA(ls_chg) = VALUE #( gt_item[ ls_mod_cells-row_id ]  OPTIONAL ).

            IF ls_chg IS NOT INITIAL.

              CLEAR: lv_err.
              PERFORM check_input_fkimg    USING    ls_chg-zseglev2
                                                    ls_chg-kondm
                                                    lv_fkimg
                                                    ls_mod_cells
                                           CHANGING lv_err.

              CLEAR: lv_msg.
              IF lv_err IS NOT INITIAL.

                IF     ls_chg-zseglev2 = 'S002'.
*             당월 OEM 입고량을 초과할 수 없습니다.
                  lv_msg = TEXT-e09.
                ELSEIF ls_chg-zseglev2 = 'S001'.
*             당월 직판 수량을 초과할 수 없습니다.
                  lv_msg = TEXT-e08.
                ENDIF.
                PERFORM err_protocol_entry  USING  pr_data_changed
                                                   ls_mod_cells-fieldname
                                                   ls_mod_cells-row_id
                                                   lv_msg.
              ELSE.
                DATA(lv_entr) = 'X'.
              ENDIF.

            ENDIF.

        ENDCASE.
      ENDLOOP.
      IF lv_entr IS NOT INITIAL.
        gv_change = 'X'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'ENTER'.
      ENDIF.
  ENDCASE.



**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form err_protocol_entry
*&---------------------------------------------------------------------*
FORM err_protocol_entry  USING    pr_data_changed
                                  TYPE REF TO cl_alv_changed_data_protocol
                                  pi_fieldname
                                  pi_index
                                  pi_msg.

**
  CALL METHOD pr_data_changed->add_protocol_entry
    EXPORTING
      i_msgid     = 'ZGTSD01'
      i_msgno     = '000'
      i_msgty     = 'E'
      i_msgv1     = pi_msg
*     i_msgv2     =
*     i_msgv3     =
*     i_msgv4     =
      i_fieldname = pi_fieldname
      i_row_id    = pi_index.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form handle_toolbar
*&---------------------------------------------------------------------*
FORM handle_toolbar  USING    po_object
                              TYPE REF TO cl_alv_event_toolbar_set.

  DATA: ls_toolbar TYPE stb_button.

**
* 구분 Line
  CLEAR ls_toolbar.
  ls_toolbar-butn_type = '3'.
  APPEND ls_toolbar TO po_object->mt_toolbar.

* 정산 Data 저장.
  IF gv_disp IS INITIAL.
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'SAVE'.
    ls_toolbar-icon      = icon_system_save.
    ls_toolbar-text      = '정산Data 저장'.
    ls_toolbar-butn_type = '0'.
    ls_toolbar-quickinfo = '정산Data 저장'.
    ls_toolbar-checked   = space.
    APPEND ls_toolbar TO po_object->mt_toolbar.
  ENDIF.

*  CLEAR ls_toolbar.
*  ls_toolbar-function  = 'CANCEL'.
*  ls_toolbar-icon      = icon_cancel.
*  ls_toolbar-text      = '정산Data 저장취소'.
*  ls_toolbar-butn_type = '0'.
*  ls_toolbar-quickinfo = '정산Data 저장취소'.
*  ls_toolbar-checked   = space.
*  APPEND ls_toolbar TO po_object->mt_toolbar.

  CLEAR ls_toolbar.
  ls_toolbar-function  = 'ZINIT'.
  ls_toolbar-icon      = icon_system_undo.
  ls_toolbar-text      = '리스트 Clear'.
  ls_toolbar-butn_type = '0'.
  ls_toolbar-quickinfo = '리스트 Clear'.
  ls_toolbar-checked   = space.
  APPEND ls_toolbar TO po_object->mt_toolbar.

  IF gv_disp IS INITIAL.

    DATA(lv_chk) = VALUE #( gt_item[ save = icon_led_green ]  OPTIONAL ).
    IF lv_chk      IS NOT INITIAL.
      DATA(ls_head) = VALUE #( gt_head[ chk = 'X' kunag = lv_chk-kunag
                                        matnr = lv_chk-matnr ] OPTIONAL ).
      IF ls_head-prereconsta EQ 'C' AND
         ls_head-reconsta EQ space.
        CLEAR ls_toolbar.
        ls_toolbar-function  = 'CHANGE'.
        ls_toolbar-icon      = icon_change.
        ls_toolbar-text      = '정산 저장Data 변경'.
        ls_toolbar-butn_type = '0'.
        ls_toolbar-quickinfo = '정산 저장Data 변경'.
        ls_toolbar-checked   = space.
        APPEND ls_toolbar TO po_object->mt_toolbar.

      ENDIF.

    ENDIF.

  ENDIF.
*  DATA(LV_CHK) = VALUE #( GT_ITEM[ SAVE = ICON_LED_GREEN ]  OPTIONAL ).
*  IF LV_CHK      IS NOT INITIAL AND
*     GV_SAVE_CHG IS INITIAL.
*
*    CLEAR LS_TOOLBAR.
*    LS_TOOLBAR-FUNCTION  = 'CHANGE'.
*    LS_TOOLBAR-ICON      = ICON_CHANGE.
*    LS_TOOLBAR-TEXT      = '정산 저장Data 변경'.
*    LS_TOOLBAR-BUTN_TYPE = '0'.
*    LS_TOOLBAR-QUICKINFO = '정산 저장Data 변경'.
*    LS_TOOLBAR-CHECKED   = SPACE.
*    APPEND LS_TOOLBAR TO PO_OBJECT->MT_TOOLBAR.
*
*  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form handle_user_command
*&---------------------------------------------------------------------*
FORM handle_user_command  USING    pi_ucomm.

**
  CHECK: pi_ucomm IS NOT INITIAL.



  CLEAR: gv_error.
  CASE pi_ucomm.
    WHEN 'SAVE' .      " 정산Data 저장
*         'CANCEL'.      " 정산Data 저장취소
      PERFORM handle_data_from_db       USING  pi_ucomm.

*     Refresh.
      PERFORM get_data.

    WHEN 'CHANGE'.      " 정산 저장Data 변경
      PERFORM check_before_save_or_cancel  USING  pi_ucomm.
      PERFORM item_edit_field_change       USING  pi_ucomm.
      gv_save_chg = 'X'.

    WHEN 'ZINIT'. "ITEM LIST CLEAR
      CLEAR: gv_change,gv_change_h.
      CLEAR gt_item[].
      LOOP AT gt_head INTO gs_head.
        DATA(lv_index) = sy-tabix.
        CLEAR:gs_head-chk.
        CLEAR:gs_head-style_tab[].
        PERFORM set_alv_style_color  USING    'H'.
        MODIFY gt_head FROM gs_head INDEX lv_index.
      ENDLOOP.


  ENDCASE.

  CALL METHOD cl_gui_cfw=>set_new_ok_code
    EXPORTING
      new_code = 'ENTER'.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form handle_double_click_event
*&---------------------------------------------------------------------*
FORM handle_double_click_event  USING    ps_row     TYPE lvc_s_row
                                         ps_column  TYPE lvc_s_col.

**
  CHECK: ps_row IS NOT INITIAL.

  READ TABLE gt_head  INTO DATA(ls_head)
                      WITH KEY chk = 'X'.
  IF sy-subrc = 0.

    IF sy-tabix NE ps_row-index.
      DATA(lv_ask) = 'X'.
    ELSE.

      IF gt_item[] IS NOT INITIAL.
        DATA(lv_nochg) = 'X'.
      ELSE.
        CLEAR: lv_nochg.
      ENDIF.

    ENDIF.

  ENDIF.

* 이미 선택된 라인이 있을때.
  CLEAR: gv_answer.
  IF lv_ask IS NOT INITIAL.
    PERFORM popup_to_confirm    USING    'CONFIRM'
                                         '이미 매출정산중인 거래처가 있습니다. 변경하시겠습니까?'
                                         '(저장되지 않은 Data는 삭제됩니다.)'
                                CHANGING gv_answer.
    IF gv_answer NE 'J'.
      lv_nochg = 'X'.
    ELSE.
      CLEAR: lv_nochg.
      MODIFY gt_head: FROM VALUE #( chk = ' ' )
                      TRANSPORTING chk
                      WHERE chk = 'X'.
    ENDIF.

  ENDIF.

  CHECK: lv_nochg IS INITIAL.

  CLEAR: gs_head.
  gs_head = VALUE #( gt_head[ ps_row-index ]  OPTIONAL ).

  IF gs_head IS NOT INITIAL.

    MODIFY gt_head: FROM VALUE #( chk = 'X' )
                    INDEX ps_row-index
                    TRANSPORTING chk.

    CALL METHOD cl_gui_cfw=>set_new_ok_code
      EXPORTING
        new_code = 'DETAIL'.    " 매출정산 Detail.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form handle_hotspot_click_event
*&---------------------------------------------------------------------*
FORM handle_hotspot_click_event  USING    pi_screen
                                          ps_row     TYPE lvc_s_row
                                          ps_column  TYPE lvc_s_col
                                          ps_row_no  TYPE lvc_s_roid.

**
  CHECK: ps_row IS NOT INITIAL.

  IF     pi_screen = '100'.
    DATA(ls_item) = VALUE #( gt_item[ ps_row-index ]  OPTIONAL ).
    DATA(lv_vbeln)    = ls_item-vbeln.
    DATA(lv_do_vbeln) = ls_item-do_vbeln.

  ELSEIF pi_screen = '200'.
    CLEAR: lv_vbeln, lv_do_vbeln.
    DATA(ls_do) = VALUE #( gt_do_info[ ps_row-index ]  OPTIONAL ).
    lv_vbeln    = ls_do-vbeln.
    lv_do_vbeln = ls_do-do_vbeln.

  ENDIF.

  CASE ps_column-fieldname.
    WHEN 'VBELN'.       " Sales Order
      IF lv_vbeln IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD lv_vbeln.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'DO_VBELN'.    " Delivery
      IF lv_do_vbeln IS NOT INITIAL.
        SET PARAMETER ID 'VL' FIELD lv_do_vbeln.
        CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'MBLNR'.       " Good Issue
      IF ls_item-mblnr IS NOT INITIAL.
        PERFORM call_migo_dialog   USING  ls_item-mblnr.
      ENDIF.

    WHEN 'BL_VBELN'.    " Billing
      IF ls_item-bl_vbeln IS NOT INITIAL.
        SET PARAMETER ID 'VF' FIELD ls_item-bl_vbeln.
        CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
      ENDIF.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_custom_cont
*&---------------------------------------------------------------------*
FORM create_custom_cont
     USING  pi_screen
            po_main_cont  TYPE REF TO cl_gui_custom_container.

**
  CASE pi_screen.
    WHEN '200'.
      PERFORM create_custom_cont_alv   USING  pi_screen
                                              po_main_cont.
  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_custom_cont_alv
*&---------------------------------------------------------------------*
FORM create_custom_cont_alv
     USING  pi_screen
            po_main_cont  TYPE REF TO cl_gui_custom_container.

**
  IF po_main_cont IS INITIAL.
*   1. Create container.
    PERFORM create_custom_container   USING  po_main_cont
                                             pi_screen.

*   2. Set Grid.
    PERFORM create_custom_grid        USING  po_main_cont
                                             go_grid_200.

*   3. Set ALV attributes.
    PERFORM make_alv_attributes     USING  pi_screen
                                           '2'
                                           go_grid_200
                                           gt_fcat_200
                                           gt_toolbar_200
                                           gt_sort_200
                                           gs_layout_200
                                           gs_variant_200.

  ELSE.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_custom_container
*&---------------------------------------------------------------------*
FORM create_custom_container  USING  po_container
                                     TYPE REF TO cl_gui_custom_container
                                     pi_screen.

  DATA: lv_sname TYPE scrfname.

**
  CLEAR: lv_sname.
  IF     pi_screen = '200'.
    lv_sname = 'CC01'.
  ENDIF.

  CREATE OBJECT po_container
    EXPORTING
      container_name = lv_sname.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_custom_grid
*&---------------------------------------------------------------------*
FORM create_custom_grid  USING  po_container
                                TYPE REF TO cl_gui_custom_container
                                po_grid
                                TYPE REF TO cl_gui_alv_grid.

**
  CREATE OBJECT po_grid
    EXPORTING
      i_parent          = po_container
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.

**

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_finished
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ET_GOOD_CELLS
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM data_changed_finished  USING    pv_modified TYPE char01
                                     pt_good_cells TYPE lvc_t_modi
                                    pv_sender.

  DATA: lt_modi TYPE lvc_t_modi.
  DATA: ls_modi TYPE lvc_s_modi.

  DATA: lv_adj_avg_netpr LIKE zgtsdt1040-adj_avg_netpr,
        lv_adj_avg_netwr LIKE zgtsdt1040-adj_avg_netwr,
        lv_adj_avg_mwsbp LIKE zgtsdt1040-adj_avg_mwsbp.


  CHECK pv_modified IS NOT INITIAL.

  CASE pv_sender.
    WHEN go_grid_h.
      lt_modi[] = pt_good_cells[].
      SORT lt_modi BY row_id.
      DELETE ADJACENT DUPLICATES FROM lt_modi COMPARING row_id.
      ls_modi = VALUE #( lt_modi[ 1 ] OPTIONAL ).
      CHECK ls_modi IS NOT INITIAL.

      LOOP AT lt_modi INTO ls_modi.
        READ TABLE gt_head ASSIGNING FIELD-SYMBOL(<lfs_wa>) INDEX ls_modi-row_id.
        IF sy-subrc EQ 0.

          "OEM입고량
          <lfs_wa>-oemgr_sumqty = <lfs_wa>-oemn_grqty + <lfs_wa>-oeml_grqty.
          <lfs_wa>-oemgr_qty    = <lfs_wa>-oemgr_sumqty.
          "직판수량
          <lfs_wa>-drs_qty      = <lfs_wa>-lfimg - <lfs_wa>-oemgr_qty.

          "ITEM 재구축
          DELETE gt_item_tmp WHERE spmon = <lfs_wa>-spmon
                               AND vkorg = <lfs_wa>-vkorg
                               AND vkbur = <lfs_wa>-vkbur
                               AND vkgrp = <lfs_wa>-vkgrp
                               AND kunag = <lfs_wa>-kunag
                               AND matnr = <lfs_wa>-matnr.

          CLEAR: lv_adj_avg_netpr, lv_adj_avg_netwr, lv_adj_avg_mwsbp.

*   가공비 유형별 라인 생성.
          READ TABLE gt_kondm  INTO DATA(ls_kondm)
                               WITH KEY kunnr = <lfs_wa>-kunag
                                        matnr = <lfs_wa>-matnr
                               BINARY SEARCH.
          IF sy-subrc = 0.
            LOOP AT gt_kondm INTO ls_kondm  FROM sy-tabix.
              IF ls_kondm-kunnr = <lfs_wa>-kunag AND
                 ls_kondm-matnr = <lfs_wa>-matnr.

*               Make Line item.
                CLEAR: gs_item.
                PERFORM modify_line_item     USING    <lfs_wa>
                                                      ls_kondm
                                             CHANGING gs_item.

                IF <lfs_wa>-reconsta IS NOT INITIAL.
                  gs_item-noedit = 'X'.
                ENDIF.

                if gv_disp is NOT INITIAL.
                  gs_item-noedit = 'X'.
                endif.

*               Set ALV Field Style / Color
                PERFORM set_alv_style_color  USING    'I'.

                IF gs_item-fkimg <> 0.
                  lv_adj_avg_netpr = lv_adj_avg_netpr + gs_item-netpr.
                  lv_adj_avg_netwr = lv_adj_avg_netwr + gs_item-netwr.
                  lv_adj_avg_mwsbp = lv_adj_avg_mwsbp + gs_item-mwsbp.
                ENDIF.

                APPEND gs_item TO gt_item_tmp.

              ELSE.
                EXIT.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDLOOP.

      PERFORM refresh_alv             USING: go_grid_h.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
