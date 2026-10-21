*&---------------------------------------------------------------------*
*& Include          ZGTSDR1030ALV
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_field_catalog
*&---------------------------------------------------------------------*
FORM get_field_catalog  USING    pt_table     TYPE table
                        CHANGING pt_fieldcat  TYPE lvc_t_fcat.

**
  _clear: pt_fieldcat.
  pt_fieldcat = zgtsd_cl_common=>get_field_catalog( it_table = pt_table ).
*                                                    iv_cells = 'X'
*                                                    iv_cellc = 'X' ).

**

ENDFORM.

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
                                           go_cont_m
                                           go_grid_top
                                           go_grid.

*   3. Set ALV attributes - Header.
    PERFORM make_alv_attributes     USING  pi_screen
                                           go_grid
                                           gt_fcat
                                           gt_toolbar
                                           gt_sort
                                           gs_layout
                                           gs_variant.

  ELSE.
    PERFORM refresh_alv             USING: go_grid.

  ENDIF.

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
              po_cont_m     TYPE REF TO cl_gui_container
              po_grid_top   TYPE REF TO cl_gui_alv_grid
              po_grid       TYPE REF TO cl_gui_alv_grid.

**
* Split.
  CREATE OBJECT po_split
    EXPORTING
      parent  = po_main_dock
      rows    = 2
      columns = 1.

* Set Container 1.
  CALL METHOD po_split->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = po_cont_t.

* Set Container 2.
  CALL METHOD po_split->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = po_cont_m.

* Set Grid 1.
*  CREATE OBJECT po_grid_top
*    EXPORTING
*      i_parent = po_cont_t.

* Set Grid 2.
  CREATE OBJECT po_grid
    EXPORTING
      i_parent = po_cont_m.

* Top of page
  CREATE OBJECT go_docid
    EXPORTING
      style = 'ALV_GRID'.

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

  CALL METHOD po_split->set_row_height
    EXPORTING
      id     = 2
      height = 80.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_alv_attributes
*&---------------------------------------------------------------------*
FORM make_alv_attributes  USING    pi_screen
                                   po_grid     TYPE REF TO cl_gui_alv_grid
                                   pt_fcat     TYPE lvc_t_fcat
                                   pt_toolbar  TYPE ui_functions
                                   pt_sort     TYPE lvc_t_sort
                                   ps_layout   TYPE lvc_s_layo
                                   ps_variant  TYPE disvariant.

**
* 1. Set Layout
  PERFORM set_alv_layout         USING  pi_screen
                                        ps_layout.

* 2. Set Sort.
  PERFORM set_sort_field         USING  pi_screen
                                        pt_sort.

* 3. Set Toolbar excluding.
  PERFORM set_excluding_toolbar  USING  pi_screen
                                        pt_toolbar.

* 4. Set Fieldcatalog.
*  --> Dynamic Fieldcat.

* 5. Set Event.
  PERFORM set_event              USING  pi_screen
                                        po_grid.

* 6. Set variant.
  PERFORM set_variant            USING  pi_screen
                                        ps_variant.

* 7. Alv display
  PERFORM alv_first_display      USING  pi_screen
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
                              ps_layout  TYPE lvc_s_layo.

**
  CLEAR ps_layout.
  CASE pi_screen.
    WHEN '100'.
      ps_layout = VALUE #( sel_mode   = 'B'
                           zebra      = 'X' ).
*                           cwidth_opt = 'X' ).
*                           no_rowmark = 'X'
*                           ctab_fname = 'COLOR' ).

    WHEN OTHERS.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_sort_field
*&---------------------------------------------------------------------*
FORM set_sort_field  USING    pi_screen
                              pt_sort    TYPE lvc_t_sort.

**
  _clear: pt_sort.
*  PERFORM set_sort_field_dtl   USING: pt_sort 'VBELN' 'X' '' ''.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_sort_field_dtl
*&---------------------------------------------------------------------*
FORM set_sort_field_dtl  USING   pt_sort TYPE lvc_t_sort
                                 pi_fldname
                                 pi_up
                                 pi_down
                                 pi_subtot.

**
  APPEND VALUE #( spos      = lines( pt_sort ) + 1
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
*& Form set_event
*&---------------------------------------------------------------------*
FORM set_event  USING    pi_screen
                         po_grid     TYPE REF TO cl_gui_alv_grid.

**
  CALL METHOD po_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

* Event Handler
  CREATE OBJECT go_event_handler.

  SET HANDLER go_event_handler->top_of_page          FOR po_grid.

  SET HANDLER go_event_handler->handle_data_changed  FOR po_grid.

  CALL METHOD po_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.                " Ready for Input Status

  CALL METHOD go_docid->initialize_document
    EXPORTING
      background_color = cl_dd_area=>col_textarea.

  CALL METHOD po_grid->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE'
      i_dyndoc_id  = go_docid.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_variant
*&---------------------------------------------------------------------*
FORM set_variant  USING    pi_screen
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
*& Form alv_first_display
*&---------------------------------------------------------------------*
FORM alv_first_display  USING  pi_screen
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
      CALL METHOD po_grid->set_table_for_first_display
        EXPORTING
          is_layout            = ps_layout
          it_toolbar_excluding = pt_toolbar
          i_save               = 'A'
          is_variant           = ps_variant
        CHANGING
          it_outtab            = <gt_list>[]
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

  DATA: ls_scroll  TYPE lvc_s_stbl.

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

  DATA: lv_text  TYPE sdydo_text_element.

**
  CHECK: gt_base[] IS NOT INITIAL.

* Heading
  CLEAR: lv_text.
  lv_text = |{ gs_head-spmon+0(4) }| && |{ '년' } | &&
            |{ gs_head-spmon+4(2) }| && |{ '월 단가' }|.

* Add Text : Header
  CALL METHOD po_document->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = cl_dd_area=>large
      sap_emphasis = cl_dd_area=>strong.

  CALL METHOD po_document->new_line( ).

  CLEAR: lv_text.
  SELECT SINGLE bezei
    FROM tvkbt  WHERE vkbur EQ @gs_head-vkbur
                  AND spras EQ @sy-langu
    INTO @DATA(lv_bezei).

  lv_text = |{ gs_head-vkbur }| && | { lv_bezei }|.

  CALL METHOD po_document->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = cl_dd_area=>medium.

  CALL METHOD po_document->new_line( ).
  CALL METHOD po_document->new_line( ).

* 전기동 고시가.
  CLEAR: lv_text.
  lv_text = '전기동 고시가'.
  CALL METHOD po_document->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = cl_dd_area=>large
      sap_emphasis = cl_dd_area=>strong.

  CALL METHOD po_document->new_line( ).

  CLEAR: lv_text.
  lv_text = |{ '기준 월:' }| &&
            | { gs_head-spmon+0(4) }| && '.' && |{ gs_head-spmon+4(2) }|.

  CALL METHOD po_document->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = cl_dd_area=>medium.

  CALL METHOD po_document->new_line( ).

  CLEAR: lv_text.
  DATA(lv_price)  = |{ gs_head-price CURRENCY = gs_head-defcurr NUMBER = USER }|.
  DATA(lv_defper) = |{ gs_head-defper NUMBER = USER }|.

  lv_text = |{ '금액:' }| && | { lv_price }| && | { gs_head-defcurr }| &&
            | { '/' } | && |{ lv_defper }| && | { gs_head-defuom }|.

  CALL METHOD po_document->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = cl_dd_area=>medium.

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
                            TYPE REF TO cl_alv_changed_data_protocol.

  DATA : ls_mod_cells TYPE lvc_s_modi,
         ls_cells     TYPE lvc_s_modi.

**
  LOOP AT pr_data_changed->mt_good_cells INTO ls_mod_cells.
*    CASE LS_MOD_CELLS-FIELDNAME.
*
*    ENDCASE.
  ENDLOOP.

**

ENDFORM.
