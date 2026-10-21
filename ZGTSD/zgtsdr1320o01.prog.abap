*----------------------------------------------------------------------*
***INCLUDE ZGTSDR1320O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module status_0100 output.
  set pf-status '100' excluding gt_fcode.
*  data(lv_lines) = lines( gt_list[] ).
*  data(lv_text) = '(' && lv_lines && ' lines)'.
*  set titlebar 'T100' with lv_text. "sy-title.
  set titlebar 'T100'.
endmodule.
*&---------------------------------------------------------------------*
*& Module INIT_OBJECT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module init_object output.

  check go_con is not bound.
  "Create Object
  perform init_alv_0100 changing go_con
                                 go_grid.

  "Alv 구성
  perform set_attributes_0100.

endmodule.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0100 input.

  clear : gv_saveok.

  gv_saveok = gv_okcode.
  clear gv_okcode.

  case gv_saveok.
*    WHEN 'APPLY'.
*      PERFORM ALL_APPLY.
    when 'SAVE'.
*      perform save_process.
  endcase.

endmodule.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form set_attributes_0100 .

  "Layout 지정
  perform set_grid_layout using 'X' '' zgtsd_d.
*  gs_layout-no_rowmark = 'X'.
*  gs_layout-ctab_fname = 'CELLC'.

  "Field Catalog
  perform set_fieldcatalog.

  "Toolbar 제외
  perform exclude_toolbar tables gt_toolbar.

  "Event Handler 등록
  perform create_event_receiver using go_grid.

  "F4 필드 등록
**  perform register_f4_fields.

  "SORT
  perform set_alv_sort changing gt_sort.

  "Top-Of-Page Event 등록
*  PERFORM SET_TOP_OF_PAGE_EVENT.

  perform set_color.

  "ALV Grid Display
  perform set_table_for_first_display using go_grid
                                            gt_list[].

endform.
*&---------------------------------------------------------------------*
*& Form SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form set_grid_layout using pv_cwopt
                           pv_stylefname
                           pv_sel_mode.

  clear gs_layout.
  gs_layout = value #( sel_mode   = pv_sel_mode
                       zebra      = zgtsd_x
                       cwidth_opt = pv_cwopt
                       stylefname = pv_stylefname ).

endform.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form set_fieldcatalog .

  refresh: g_field_t, g_fieldcat_t2.

  data: lt_dfies type standard table of dfies,
        ls_dfies type dfies.

  call function 'DDIF_FIELDINFO_GET'
    exporting
      tabname   = 'ZGTSDS1110'
      langu     = sy-langu
    tables
      dfies_tab = lt_dfies
    exceptions
      others    = 1.

  call function 'LVC_FIELDCATALOG_MERGE'
    exporting
      i_structure_name       = 'ZGTSDS1110'
    changing
      ct_fieldcat            = g_fieldcat_t2
    exceptions
      inconsistent_interface = 1
      program_error          = 2
      others                 = 3.

  data: lv_last_field type i.

  read table g_fieldcat_t2 transporting no fields
                           with key fieldname = 'ERDAT'.
  if sy-subrc = 0.
    lv_last_field = sy-tabix.
  else.
    lv_last_field = 92.
  endif.

  loop at g_fieldcat_t2 assigning field-symbol(<fd>).

    clear gs_fcat.

    move-corresponding <fd> to gs_fcat.
    gs_fcat-no_out = ''.
    gs_fcat-tech   = ''.

    if sy-tabix > lv_last_field. " ERDAT 이후는 화면에서 숨김
      gs_fcat-no_out = 'X'.
      gs_fcat-tech   = 'X'.
    endif.

    case <fd>-fieldname.
      when 'SHIPTO' or 'SHIPTO_NM' or 'VBELN' or 'POSNR'.
        gs_fcat-key       = 'X'.
      when 'SHIPTO_ADDR'.
        gs_fcat-reptext   = '납품처 주소'.
        gs_fcat-scrtext_l = '납품처 주소'.
        gs_fcat-scrtext_m = '납품처 주소'.
        gs_fcat-scrtext_s = '납품처 주소'.
      when 'POQTY'.
        gs_fcat-reptext   = '발주 잔량'.
        gs_fcat-scrtext_l = '발주 잔량'.
        gs_fcat-scrtext_m = '발주 잔량'.
        gs_fcat-scrtext_s = '발주 잔량'.
      when 'KUNNR'.
        gs_fcat-reptext   = '거래처'.
        gs_fcat-scrtext_l = '거래처'.
        gs_fcat-scrtext_m = '거래처'.
        gs_fcat-scrtext_s = '거래처'.
      when 'KUNNR_NM'.
        gs_fcat-reptext   = '거래처명'.
        gs_fcat-scrtext_l = '거래처명'.
        gs_fcat-scrtext_m = '거래처명'.
        gs_fcat-scrtext_s = '거래처명'.
      when 'OEMREL'.
        gs_fcat-reptext   = 'OEM 주문'.
        gs_fcat-scrtext_l = 'OEM 주문'.
        gs_fcat-scrtext_m = 'OEM 주문'.
        gs_fcat-scrtext_s = 'OEM 주문'.
      when 'SHIPTO_ADDR2' or 'IN_QTY_SUM' or 'IN_FACTOR_SUM'.
        gs_fcat-no_out = 'X'.
        gs_fcat-tech   = 'X'.
      when others.
        if <fd>-reptext is initial.
          read table lt_dfies into ls_dfies with key fieldname = <fd>-fieldname.
          if sy-subrc = 0.
            gs_fcat-seltext = ls_dfies-fieldtext.
            gs_fcat-reptext = ls_dfies-fieldtext.
            gs_fcat-scrtext_l = ls_dfies-fieldtext.
            gs_fcat-scrtext_m = ls_dfies-fieldtext.
            gs_fcat-scrtext_s = ls_dfies-fieldtext.
          endif.
        endif.
    endcase.

    append gs_fcat to gt_fcat.
  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form GET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form get_field_catalog using pt_table type table
                    changing pt_fcat type lvc_t_fcat.

  refresh pt_fcat.

  pt_fcat = zgtsd_cl_common=>get_field_catalog( it_table = pt_table
                                                iv_cells = zgtsd_x
                                                iv_cellc = zgtsd_x ).

endform.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*----------------------------------------------------------------------*
form exclude_toolbar tables pt_exclude type ui_functions.

  refresh pt_exclude.

  append : cl_gui_alv_grid=>mc_fc_loc_undo            to pt_exclude,
           cl_gui_alv_grid=>mc_fc_data_save           to pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_copy            to pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_copy_row        to pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_cut             to pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_delete_row      to pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_insert_row      to pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_move_row        to pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_append_row      to pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_paste           to pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_paste_new_row   to pt_exclude,
           cl_gui_alv_grid=>mc_fc_refresh             to pt_exclude,
           cl_gui_alv_grid=>mc_fc_check               to pt_exclude,
           cl_gui_alv_grid=>mc_fc_print               to pt_exclude,
           cl_gui_alv_grid=>mc_fc_views               to pt_exclude,
           cl_gui_alv_grid=>mc_fc_graph               to pt_exclude,
           cl_gui_alv_grid=>mc_fc_info                to pt_exclude.

endform.
*&---------------------------------------------------------------------*
*& Form CREATE_EVENT_RECEIVER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form create_event_receiver using po_sender type ref to cl_gui_alv_grid.

  "Create Event
  data(lo_event) = new lcl_event_receiver( ).

*  CASE PO_SENDER.
*    WHEN GO_GRID.
**      SET HANDLER : LO_EVENT->HANDLE_TOP_OF_PAGE FOR PO_SENDER.
*  ENDCASE.

  set handler : lo_event->handle_hotspot_click         for po_sender,
                lo_event->handle_data_changed          for po_sender,
                lo_event->handle_toolbar               for po_sender,
                lo_event->handle_user_command          for po_sender,
                lo_event->handle_dbl_click             for po_sender,
*                LO_EVENT->HANDLE_ON_F4                 FOR PO_SENDER.
                lo_event->handle_data_changed_finished for po_sender.

  "Data Changed Event
  po_sender->register_edit_event( cl_gui_alv_grid=>mc_evt_modified ).
  po_sender->register_edit_event( cl_gui_alv_grid=>mc_evt_enter ).

  "Set Ready for Input
  go_grid->set_ready_for_input( switch #( gv_edit when zgtsd_x then 1 else 0 ) ).

endform.
*&---------------------------------------------------------------------*
*& Form REGISTER_F4_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form register_f4_fields .

  data : lt_f4   type lvc_t_f4,
         lt_fcat type table of lvc_s_fcat
                 with non-unique sorted key key_mode
                 components f4availabl fieldname.

  lt_fcat = gt_fcat.
  loop at lt_fcat into data(ls_fcat) using key key_mode
                  where f4availabl = zgtsd_x.
    lt_f4 = value #( base lt_f4 ( fieldname  = ls_fcat-fieldname
                                  register   = zgtsd_x
                                  chngeafter = zgtsd_x ) ).
  endloop.

  go_grid->register_f4_for_fields( exporting it_f4 = lt_f4 ).

endform.
*&---------------------------------------------------------------------*
*& Form SET_ALV_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_SORT
*&---------------------------------------------------------------------*
form set_alv_sort  changing pt_sort type lvc_t_sort.

  clear : pt_sort[].

*  PERFORM SET_SORT_FIELD USING: PT_SORT 'KUNNR' GC_X '' '',
*                                PT_SORT 'AEDAT' GC_X '' '',
*                                PT_SORT 'AEZET' GC_X '' ''.

endform.
*&---------------------------------------------------------------------*
*& Form SET_COLOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_color .

*  data : lt_color type lvc_t_scol.
*
*  loop at gt_list into gs_s0100.
*    __cle : lt_color, gs_s0100-cellc.
*    perform fill_color  changing lt_color.
*    insert lines of lt_color into table gs_s0100-cellc.
*    modify gt_s0100 from gs_s0100.
*  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form set_table_for_first_display using po_sender type ref to cl_gui_alv_grid
                                       pt_data type table.
  data : lv_handl type slis_handl.

  perform set_variant_handle using po_sender changing lv_handl.
  gs_variant-report = sy-cprog.
  gs_variant-handle = lv_handl.


**  delete gt_fcat where tech = zgtsd_x. "불필요한 필드 제외

  "Formatted Output Table is Sent to Control
  call method po_sender->set_table_for_first_display
    exporting
      is_layout            = gs_layout
      is_variant           = gs_variant " VALUE #( REPORT = SY-REPID
    " HANDLE               = LV_HANDL )
      i_save               = zgtsd_a
      it_toolbar_excluding = gt_toolbar
    changing
      it_fieldcatalog      = gt_fcat
      it_sort              = gt_sort[]
      it_outtab            = pt_data[].

endform.
