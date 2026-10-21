*&---------------------------------------------------------------------*
*& Include          ZGTSDR0011F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form initialization .
  p_vdatu = sy-datlo.
  p_vkorg = '1000'.
  p_spart = '40'.

  clear gv_web.
  call function 'GUI_IS_ITS'
    importing
      return = gv_web.
endform.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form modify_screen .
  loop at screen.

    case screen-group1.
      when 'M1'.
        screen-required = 2.
      when 'UPL'.
        screen-required = 2.
    endcase.

    modify screen.
  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form check_input_data .


  clear gv_error.

  "기본 필수입력 필드 체크
  if p_vkorg is initial.
    message s007 with text-s01 display like gc_e.
    gv_error = zgtsd_x.
    return.
  endif.

  select single * from tvko where vkorg = p_vkorg.
  if sy-subrc <> 0.
    message s001 with text-s01 text-e02 display like gc_e.
    gv_error = zgtsd_x.
    return.
  endif.

  if p_auart is initial.
    message s007 with text-s02 display like gc_e.
    gv_error = zgtsd_x.
    return.
  else.
    select single mandt into sy-mandt from tvak where auart = p_auart.
    if sy-subrc <> 0.
      message s001 with text-s02 text-e02 display like gc_e.
      gv_error = zgtsd_x.
      return.
    endif.

    if p_auart = 'TA' or p_auart = 'ZEXE'.
    else.
      message s117 display like gc_e.
      gv_error = zgtsd_x.
      return.
    endif.
  endif.

  if p_vdatu is initial.
    message s007 with text-s03 display like gc_e.
    gv_error = zgtsd_x.
    return.
  endif.

  if p_vtweg is initial.
    message s007 with text-s04 display like gc_e.
    gv_error = zgtsd_x.
    return.
  else.
    select single mandt into sy-mandt from tvtw where vtweg = p_vtweg.
    if sy-subrc <> 0.
      message s001 with text-s04 text-e02 display like gc_e.
      gv_error = zgtsd_x.
      return.
    endif.
  endif.

  if p_kunag is initial.
    message s007 with text-s05 display like gc_e.
    gv_error = zgtsd_x.
    return.
  endif.

  if p_spart is initial.
    message s007 with text-s06 display like gc_e.
    gv_error = zgtsd_x.
    return.
  else.
    select single mandt into sy-mandt from tspa where spart = p_spart.
    if sy-subrc <> 0.
      message s001 with text-s06 text-e02 display like gc_e.
      gv_error = zgtsd_x.
      return.
    endif.
  endif.

  "-- 영업조직구조 체크
  perform check_tvta.
  if sy-subrc <> 0.
    gv_error = zgtsd_x.
    return.
  endif.


  if p_kunwe is initial.
    message s007 with text-s07 display like gc_e.
    gv_error = zgtsd_x.
    return.
  endif.

  if p_vkbur is initial.
    message s007 with text-s08 display like gc_e.
    gv_error = zgtsd_x.
    return.
  else.
    select single mandt into sy-mandt from tvbur where vkbur = p_vkbur.
    if sy-subrc <> 0.
      message s001 with text-s08 text-e02 display like gc_e.
      gv_error = zgtsd_x.
      return.
    endif.
  endif.

  if p_kunrg is initial.
    message s007 with text-s09 display like gc_e.
    gv_error = zgtsd_x.
    return.
  endif.

  if p_vkgrp is initial.
    message s007 with text-s10 display like gc_e.
    gv_error = zgtsd_x.
    return.
  else.
    select single mandt into sy-mandt from tvkgr where vkgrp = p_vkgrp.
    if sy-subrc <> 0.
      message s001 with text-s10 text-e02 display like gc_e.
      gv_error = zgtsd_x.
      return.
    endif.
  endif.

  if p_bstkd is initial.
    message s007 with text-s11 display like gc_e.
    gv_error = zgtsd_x.
    return.
  endif.

  "-- 영업조직구조 영업팀 체크
  perform check_tvta.
  perform check_tvkbz.
  if sy-subrc <> 0.
    gv_error = zgtsd_x.
    return.
  endif.

  "-- 영업팀/영업그룹 체크
  perform check_tvbvk.
  if sy-subrc <> 0.
    gv_error = zgtsd_x.
    return.
  endif.

  "-- 판매처 체크
  perform check_kunnr_bukrs using text-s05 p_kunag.
  perform check_kunnr_knvv  using text-s05 p_kunag.
  if sy-subrc <> 0.
    gv_error = zgtsd_x.
    return.
  endif.

  "-- 지급처 체크
  perform check_kunnr_bukrs using text-s09 p_kunrg.
  perform check_kunnr_knvv  using text-s09 p_kunrg.
  if sy-subrc <> 0.
    gv_error = zgtsd_x.
    return.
  endif.

  "-- 납품처 체크
  perform check_kunnr_knvv  using text-s07 p_kunwe.
  if sy-subrc <> 0.
    gv_error = zgtsd_x.
    return.
  endif.

  "-- 납품요청일 과거 입력 확인
  if p_vdatu < sy-datlo.
    message s123 display like gc_e.
    gv_error = zgtsd_x.
    return.
  endif.

  if p_fname is initial.
    gv_error = zgtsd_x.
    message s007 with %_p_fname_%_app_%-text display like gc_e.
    leave list-processing.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form authority_check .

*  "권한 체크
*  ZGTSD_CL_COMMON=>AUTHORITY_CHECK( EXPORTING IV_OBJECT     = 'VKO'
*                                              IV_AUTH_FIELD = CONV XUFIELD( |VKORG| )
*                                              IV_AUTH_VAL   = CONV XUVAL( P_VKORG )
*                                    IMPORTING EV_MTYPE      = DATA(LV_MTYPE)
*                                              EV_MSGTX      = DATA(LV_MSGTX) ).
*  IF LV_MTYPE = GC_E.
*    MESSAGE S001(00) WITH LV_MSGTX DISPLAY LIKE GC_E.
*    LEAVE LIST-PROCESSING.
*  ENDIF.

endform.
*&---------------------------------------------------------------------*
*& Form DATA_UPLOAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form data_upload.

  clear gv_error. __cle : gt_s0100, gt_s0101, gt_excel.

*특정쉬트 특정 컬럼만 읽는다.
*  perform get_file_data.
  if gv_web is not initial.
    perform get_file_data_web.
  else.
    perform get_file_data_new.
  endif.

  perform check_batch_data.
  check gv_error is initial.

  perform make_data.
  check gv_error is initial.

  perform data_check.

**********************************************************************
  "데이타 건수 메시지 출력
  if gt_s0100 is not initial.
    message s009 with |{ lines( gt_s0100 ) number = user }|. "& 건 검색되었습니다.
  else.
    message s010.                                           "조회할 데이타가 없습니다.
    gv_error = gc_x.                                        "데이타 없으면 출력 X
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form INIT_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GO_CON
*&      <-- GO_GRID
*&---------------------------------------------------------------------*
form init_alv_0100  changing po_dcon type ref to cl_gui_docking_container
                             po_grid type ref to cl_gui_alv_grid.

  "Create Main Container
  perform create_doc_container changing po_dcon.

  "Split
  go_split = new #( parent = po_dcon rows = 2  columns = 1 ).

*  go_con_top       = go_split->get_container( row = 1 column = 1 ).
  data(lo_con_top) = go_split->get_container( row = 1 column = 1 ).
  data(lo_con_btt) = go_split->get_container( row = 2 column = 1 ).

  go_split->set_row_height( id = 1 height = 30 ).
*  go_split->set_row_height( id = 2 height = 30 ).

  "Create Object
  go_docu = new #( style = 'ALV_GRID' ).  "Top-Of-Page

  perform create_alv using    lo_con_top
                     changing po_grid.

  perform create_alv using    lo_con_btt
                     changing go_grid2.

endform.
*&---------------------------------------------------------------------*
*&      Form  CREATE_DOC_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form create_doc_container changing po_dcon type ref to cl_gui_docking_container.

  create object po_dcon
    exporting
      parent                      = cl_gui_container=>default_screen
      repid                       = sy-repid
      dynnr                       = sy-dynnr
      side                        = cl_gui_docking_container=>dock_at_top
      extension                   = 3000
    exceptions
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      others                      = 6.

endform.
*&---------------------------------------------------------------------*
*&      Form  CREATE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form create_alv changing po_con
                         po_grid type ref to cl_gui_alv_grid.

  create object po_grid
    exporting
      i_parent          = po_con
    exceptions
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      others            = 5.

endform.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form set_attributes_0100 .

  "Layout 지정
  perform set_grid_layout using 'X' space zgtsd_d.

  "Field Catalog
  perform set_fieldcatalog.

  "Toolbar 제외
  perform exclude_toolbar tables gt_toolbar.

  "Event Handler 등록
  perform create_event_receiver using go_grid.

  "F4 필드 등록
  perform register_f4_fields.

  "SORT
  perform set_alv_sort changing gt_sort.
  perform set_alv_sort changing gt_sort2.

  "Top-Of-Page Event 등록
**  perform set_top_of_page_event.

  "ALV Grid Display
  perform set_table_for_first_display using go_grid
                                            gt_s0100
                                            gt_fcat
                                            gt_sort.

  "ALV Grid Display
  perform set_table_for_first_display using go_grid2
                                            gt_s0101
                                            gt_fcat2
                                            gt_sort2.

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

  "Get Field Catalog
  perform get_field_catalog using gt_s0100 changing gt_fcat.
  perform get_field_catalog using gt_s0101 changing gt_fcat2.

  "Set Field Catalog
  perform set_fieldcatalog_main.

  perform set_fieldcatalog_item.

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
*& Form SET_FIELDCATALOG_MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_fieldcatalog_main .


  sort gt_fcat by fieldname.

  perform reset_field_catalog tables gt_fcat using :

    'S' 'FIELDNAME'   'STATU',
    ' ' 'COLTEXT'     text-f01,
    ' ' 'ICON'        'X',
    ' ' 'OUTPUTLEN'   '10',
    'E' 'KEY'         'X',

    'S' 'FIELDNAME'   'AUART',
    ' ' 'COLTEXT'     text-f03,
    'E' 'OUTPUTLEN'   '20',

    'S' 'FIELDNAME'   'VKORG',
    ' ' 'COLTEXT'     text-f04,
    'E' 'OUTPUTLEN'   '20',

    'S' 'FIELDNAME'   'VTWEG',
    ' ' 'COLTEXT'     text-f05,
    'E' 'OUTPUTLEN'   '20',

    'S' 'FIELDNAME'   'SPART',
    ' ' 'COLTEXT'     text-f06,
    'E' 'OUTPUTLEN'   '20',

    'S' 'FIELDNAME'   'VKBUR',
    ' ' 'COLTEXT'     text-f07,
    'E' 'OUTPUTLEN'   '20',

    'S' 'FIELDNAME'   'VKGRP',
    ' ' 'COLTEXT'     text-f08,
    'E' 'OUTPUTLEN'   '20',

    'S' 'FIELDNAME'   'KUNAG',
    ' ' 'COLTEXT'     text-f09,
    'E' 'OUTPUTLEN'   '20',

    'S' 'FIELDNAME'   'KUNWE',
    ' ' 'COLTEXT'     text-f10,
    'E' 'OUTPUTLEN'   '10',

    'S' 'FIELDNAME'   'KUNRG',
    ' ' 'COLTEXT'     text-f11,
    'E' 'OUTPUTLEN'   '10',

    'S' 'FIELDNAME'   'BSTNK',
    ' ' 'COLTEXT'     text-f12,
    'E' 'OUTPUTLEN'   '10',

    'S' 'FIELDNAME'   'VDATU',
    ' ' 'COLTEXT'     text-f13,
    'E' 'OUTPUTLEN'   '10',

    'S' 'FIELDNAME'   'POSNR',
    ' ' 'COLTEXT'     text-f14,
    'E' 'OUTPUTLEN'   '10',

    'S' 'FIELDNAME'   'MATNR',
    ' ' 'COLTEXT'     text-f15,
    'E' 'OUTPUTLEN'   '10',

    'S' 'FIELDNAME'   'MAKTX',
    ' ' 'COLTEXT'     text-f19,
    'E' 'OUTPUTLEN'   '10',

    'S' 'FIELDNAME'   'JOJAN',
    ' ' 'COLTEXT'     '조장',
    ' ' 'QFIELDNAME'  'VRKME',
    'E' 'OUTPUTLEN'   '10',

    'S' 'FIELDNAME'   'JOJAN_CNT',
    ' ' 'COLTEXT'     '조장수',
    'E' 'OUTPUTLEN'   '10',

    'S' 'FIELDNAME'   'KWMENG',
    ' ' 'COLTEXT'     text-f16,
    ' ' 'QFIELDNAME'  'VRKME',
    'E' 'OUTPUTLEN'   '10',

    'S' 'FIELDNAME'   'VRKME',
    ' ' 'COLTEXT'     text-f17,
    'E' 'OUTPUTLEN'   '10',

    'S' 'FIELDNAME'   'VBELN',
    ' ' 'COLTEXT'     text-f18,
    'E' 'OUTPUTLEN'   '10',

    'S' 'FIELDNAME'   'MSG',
    ' ' 'COLTEXT'     text-f02,
    'E' 'OUTPUTLEN'   '10'.

endform.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_fieldcatalog_item .


  sort gt_fcat2 by fieldname.

  perform reset_field_catalog tables gt_fcat2 using :

    'S' 'FIELDNAME'   'POSNR',
    ' ' 'COLTEXT'     text-f14,
    ' ' 'OUTPUTLEN'   '10',
    'E' 'KEY'         'X',

    'S' 'FIELDNAME'   'MATNR',
    ' ' 'COLTEXT'     text-f15,
    ' ' 'OUTPUTLEN'   '10',
    'E' 'KEY'         'X',

    'S' 'FIELDNAME'   'MAKTX',
    ' ' 'COLTEXT'     text-f19,
    'E' 'OUTPUTLEN'   '10',

    'S' 'FIELDNAME'   'KWMENG',
    ' ' 'COLTEXT'     text-f16,
    ' ' 'DO_SUM'      'X',
    ' ' 'QFIELDNAME'  'VRKME',
    'E' 'OUTPUTLEN'   '10',

    'S' 'FIELDNAME'   'VRKME',
    ' ' 'COLTEXT'     text-f17,
    'E' 'OUTPUTLEN'   '10',

    'S' 'FIELDNAME'   'CHARG',
    ' ' 'COLTEXT'     text-f20,
    'E' 'OUTPUTLEN'   '10'.


endform.
*&---------------------------------------------------------------------*
*& Form RESET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form reset_field_catalog tables pt_fcat type lvc_t_fcat
                         using  pv_flag
                                pv_fname
                                pv_value.

  statics : ls_fcat   type lvc_s_fcat,
            lv_colpos type lvc_colpos,
            lv_tabix  type sytabix.

  if pv_flag = zgtsd_s.  "Start
    clear ls_fcat.
    read table pt_fcat into ls_fcat with key fieldname = pv_value binary search.
    check sy-subrc = 0.
    lv_tabix = sy-tabix.

    lv_colpos = lv_colpos + 1.

    ls_fcat-tech    = space.
    ls_fcat-col_pos = lv_colpos.
  endif.

  case pv_fname.
    when 'COLTEXT'.   "Text
      ls_fcat-coltext  = pv_value.
      ls_fcat-reptext  = pv_value.
      ls_fcat-seltext  = pv_value.
      ls_fcat-tooltip  = pv_value.
    when others.
      assign component pv_fname of structure ls_fcat to field-symbol(<lv_value>).
      check sy-subrc = 0.
      <lv_value> = pv_value.
  endcase.

  if pv_flag = zgtsd_e.  "End
    modify pt_fcat from ls_fcat index lv_tabix.
  endif.

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

  case po_sender.
    when go_grid.
      set handler : lo_event->handle_top_of_page for po_sender.
  endcase.

  set handler : lo_event->handle_hotspot_click         for po_sender,
                lo_event->handle_dbl_click             for po_sender.
*                LO_EVENT->HANDLE_TOOLBAR               FOR PO_SENDER,
*                LO_EVENT->HANDLE_USER_COMMAND          FOR PO_SENDER,
*                LO_EVENT->HANDLE_ON_F4                 FOR PO_SENDER.
*               LO_EVENT->HANDLE_DATA_CHANGED          FOR PO_SENDER,
*               LO_EVENT->HANDLE_DATA_CHANGED_FINISHED FOR PO_SENDER.

*  "Data Changed Event
*  PO_SENDER->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
*  PO_SENDER->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

*  "Set Ready for Input
*  GO_GRID->SET_READY_FOR_INPUT( SWITCH #( GV_EDIT WHEN ZGTSD_X THEN 1 ELSE 0 ) ).

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
*& Form SET_TOP_OF_PAGE_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form set_top_of_page_event .

  check go_docu is bound.

  go_docu->initialize_document( background_color = cl_dd_area=>col_textarea ).

  call method go_grid->list_processing_events(
      i_event_name = slis_ev_top_of_page
      i_dyndoc_id  = go_docu ).

endform.
*&---------------------------------------------------------------------*
*& Form SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form set_table_for_first_display using po_sender type ref to cl_gui_alv_grid
                                       pt_data type table
                                       pt_fcat type lvc_t_fcat
                                       pt_sort type lvc_t_sort.
  data : lv_handl type slis_handl.

  "레이아웃 Variant 구분자
  perform set_variant_handle using po_sender changing lv_handl.

  delete gt_fcat where tech = zgtsd_x. "불필요한 필드 제외

  "Formatted Output Table is Sent to Control
  call method po_sender->set_table_for_first_display
    exporting
      is_layout            = gs_layout
      is_variant           = value #( report = sy-repid
                                      handle = lv_handl )
      i_save               = zgtsd_a
      it_toolbar_excluding = gt_toolbar
    changing
      it_fieldcatalog      = pt_fcat[]
      it_sort              = pt_sort[]
      it_outtab            = pt_data[].

endform.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_HANDLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form set_variant_handle using po_sender type ref to cl_gui_alv_grid
                         changing pv_handl.

  clear pv_handl.
  case po_sender.
    when go_grid. "Main
      pv_handl = 1.
    when others.

  endcase.

endform.
*&---------------------------------------------------------------------*
*& Form HANDLE_DBL_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
form handle_dbl_click  using    pv_row     type lvc_s_row
                                pv_column  type lvc_s_col.

  check pv_row-rowtype eq space.
  read table gt_s0100 into gs_s0100 index pv_row-index.
  check sy-subrc = 0 .

  case pv_column.
    when 'KUNAG'.
      check gs_s0100-kunag is not initial.
      set parameter id: 'KUN' field   gs_s0100-kunag.
      set parameter id: 'VKO' field   gs_s0100-vkorg.
      set parameter id: 'VTW' field   gs_s0100-vtweg.
      set parameter id: 'SPA' field   gs_s0100-spart.
      call transaction  'VD03' and skip first screen.

    when 'KUNWE'.
      check gs_s0100-kunwe is not initial.
      set parameter id: 'KUN' field   gs_s0100-kunwe.
      set parameter id: 'VKO' field   gs_s0100-vkorg.
      set parameter id: 'VTW' field   gs_s0100-vtweg.
      set parameter id: 'SPA' field   gs_s0100-spart.
      call transaction  'VD03' and skip first screen.

    when 'KUNRG'.
      check gs_s0100-kunrg is not initial.
      set parameter id: 'KUN' field   gs_s0100-kunrg.
      set parameter id: 'VKO' field   gs_s0100-vkorg.
      set parameter id: 'VTW' field   gs_s0100-vtweg.
      set parameter id: 'SPA' field   gs_s0100-spart.
      call transaction  'VD03' and skip first screen.

    when 'VBELN'.
      check gs_s0100-vbeln is not initial.
      set parameter id: 'AUN' field   gs_s0100-vbeln.
      call transaction  'VA03' and skip first screen.
    when others.
  endcase.

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

  case pt_sort.
    when gt_sort.
      perform set_sort_field using: pt_sort 'POSNR' gc_x '' '',
                                    pt_sort 'MATNR' gc_x '' ''.
    when gt_sort2.

      perform set_sort_field using: pt_sort 'POSNR' gc_x '' 'X',
                                    pt_sort 'MATNR' gc_x '' '',
                                    pt_sort 'CHARG' gc_x '' ''.
  endcase.

endform.
*&---------------------------------------------------------------------*
*& Form SET_SORT_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_SORT
*&      --> P_
*&      --> GC_X
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
form set_sort_field  using pt_sort type lvc_t_sort
                           pv_fldname
                           pv_up
                           pv_down
                           pv_subtot.

  append value #( spos      = lines( pt_sort ) + 1
                  fieldname = pv_fldname
                  up        = pv_up
                  down      = pv_down
                  subtot    = pv_subtot ) to pt_sort.
endform.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form handle_top_of_page using po_docu type ref to cl_dd_document
                                  po_sender.
  data : lv_text type sdydo_text_element,
         lv_str  type string.

  check po_sender = go_grid "Main
    and po_docu is bound.

  "Set Column Width
  po_docu->add_table( exporting no_of_columns = 3 border = '0' importing table = data(lo_table) ).

  lo_table->add_column( exporting width = '20%' importing column = data(lo_col_key) ).
  lo_table->add_column( exporting width = '3%' importing column = data(lo_col_sep) ).
  lo_table->add_column( exporting width = '77%' importing column = data(lo_col_val) ).
  lo_table->new_row( ).

  "Set Column Style
  lo_table->set_column_style( col_no = 1 sap_emphasis = cl_dd_document=>strong sap_align = 'LEFT' ).
  lo_table->set_column_style( col_no = 3 sap_emphasis = cl_dd_document=>medium sap_align = 'LEFT' ).

  "Add Text
  perform add_text_common using lo_col_key lo_col_sep lo_col_val lo_table
                                zgtsd_p %_p_vkorg_%_app_%-text p_vkorg.

  lv_str = p_auart.
  perform add_text_common using lo_col_key lo_col_sep lo_col_val lo_table
                                zgtsd_p text-s02 lv_str.

  lv_str = p_vdatu.
  perform add_text_common using lo_col_key lo_col_sep lo_col_val lo_table
                                zgtsd_p text-s03 lv_str.

  perform add_text_common using lo_col_key lo_col_sep lo_col_val lo_table
                              zgtsd_p text-s04 p_vtweg.

  lv_str = p_kunag.
  perform add_text_common using lo_col_key lo_col_sep lo_col_val lo_table
                              zgtsd_p text-s05 lv_str.

  perform add_text_common using lo_col_key lo_col_sep lo_col_val lo_table
                              zgtsd_p text-s06 p_spart.

  lv_str = p_kunwe.
  perform add_text_common using lo_col_key lo_col_sep lo_col_val lo_table
                              zgtsd_p text-s07 lv_str.

  perform add_text_common using lo_col_key lo_col_sep lo_col_val lo_table
                              zgtsd_p text-s08 p_vkbur.

  lv_str = p_kunrg.
  perform add_text_common using lo_col_key lo_col_sep lo_col_val lo_table
                              zgtsd_p text-s09 lv_str.

  perform add_text_common using lo_col_key lo_col_sep lo_col_val lo_table
                              zgtsd_p text-s10 p_vkgrp.

  perform add_text_common using lo_col_key lo_col_sep lo_col_val lo_table
                              zgtsd_p text-s11 p_bstkd.
  "Display Document
  po_docu->merge_document( ).
  po_docu->display_document( exporting
                               reuse_control      = zgtsd_x
                               parent             = go_con_top
                             exceptions
                               html_display_error = 1 ).

endform.
*&---------------------------------------------------------------------*
*& Form ADD_TEXT_COMMON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form add_text_common using po_col_key type ref to cl_dd_area
                               po_col_sep type ref to cl_dd_area
                               po_col_val type ref to cl_dd_area
                               po_table   type ref to cl_dd_table_element
                               pv_flag
                               pv_key
                               pv_value.
  field-symbols : <lt_selopt> type table.
  data lv_text type char255.
  data lv_str  type char20.
  case pv_flag.
    when zgtsd_p. "Parameter
      check pv_value is not initial.
      case pv_key.
        when text-s05 or text-s07 or text-s09.
          __alpha_ou pv_value pv_value.
        when text-s02.
          call function 'CONVERSION_EXIT_AUART_OUTPUT'
            exporting
              input  = pv_value
            importing
              output = pv_value.
        when text-s03.
          write pv_value to lv_str using edit mask '____.__.__'. pv_value = lv_str.
      endcase.
      lv_text = conv sdydo_text_element( pv_value ).
    when zgtsd_s. "Select-Option
      assign (pv_value) to <lt_selopt>.
      check sy-subrc = 0.

      check lines( <lt_selopt> ) => 1.

      assign component 'LOW' of structure <lt_selopt>[ 1 ] to field-symbol(<lv_low>).
      check sy-subrc = 0.
      assign component 'HIGH' of structure <lt_selopt>[ 1 ] to field-symbol(<lv_high>).
      check sy-subrc = 0.

      if <lv_high> is initial.
        lv_text = <lv_low>.
      elseif <lv_low> is initial.
        lv_text = `~ ` &&  <lv_low>.
      else.
        lv_text = <lv_low> && ` ~ ` &&  <lv_high>.
      endif.
  endcase.

  po_col_key->add_text( text = conv sdydo_text_element( pv_key ) ).
  po_col_sep->add_text( text = conv sdydo_text_element( zgtsd_colon ) ).
  po_col_val->add_text( text = lv_text ).

  po_table->new_row( ).

endform.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form handle_hotspot_click using ps_column type lvc_s_col
                                ps_row_no type lvc_s_roid
                                po_sender.

  check po_sender = go_grid. "Main

  case ps_column-fieldname.

    when 'MATNR'. "자산번호

      read table gt_s0100 into data(ls_main) index ps_row_no-row_id.
      check sy-subrc = 0.

  endcase.

endform.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form handle_data_changed using po_data_changed type ref to
                                 cl_alv_changed_data_protocol
                                 po_sender.

  check po_sender = go_grid.  "Main

  data(lt_mod_cells) = po_data_changed->mt_good_cells.
  sort lt_mod_cells by row_id fieldname.

  refresh gt_chg.

  loop at lt_mod_cells into data(ls_mod_temp).

    data(ls_mod_cells) = ls_mod_temp.

    at new row_id.
      read table gt_s0100 into data(ls_main) index ls_mod_cells-row_id.
      check sy-subrc = 0.
    endat.

    "체크사항 점검 및 Set Value
    perform check_value_in_datachd using    po_data_changed
                                            ls_mod_cells
                                   changing ls_main.

    at end of row_id.
      "변경상태 Update
      perform update_statu using    po_data_changed
                                    ls_mod_cells
                           changing ls_main-statu
                                    ls_main-modi.
      modify gt_s0100 from ls_main index ls_mod_cells-row_id.
      append corresponding #( ls_main ) to gt_chg.
    endat.

  endloop.

  "Display Protocol
  po_data_changed->display_protocol( ).

endform.
*&---------------------------------------------------------------------*
*& Form CHECK_VALUE_IN_DATACHD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form check_value_in_datachd using po_data_changed type ref to
                                      cl_alv_changed_data_protocol
                                      ps_mod_cells type lvc_s_modi
                            changing ps_data structure gs_s0100.

  case ps_mod_cells-fieldname.

    when others.
      assign component ps_mod_cells-fieldname of structure ps_data to field-symbol(<lv_value>).
      check sy-subrc = 0.
      <lv_value> = ps_mod_cells-value.
  endcase.

endform.
*&---------------------------------------------------------------------*
*& Form CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form check_changed_data using po_grid type ref to cl_gui_alv_grid
                              pv_ck.

  clear gv_error.
  check po_grid is bound.

  po_grid->check_changed_data( importing e_valid = data(lv_valid) ).

  if pv_ck = zgtsd_x and lv_valid is initial.
    gv_error = zgtsd_x. "오류 Flag
    message s029 display like zgtsd_e. "오류 내역이 존재합니다.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form UPDATE_STATU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form update_statu using po_data_changed type ref to
                            cl_alv_changed_data_protocol
                            ps_mod_cells type lvc_s_modi
                   changing pv_statu
                            pv_modi.

  pv_modi  = zgtsd_x.     "변경 Flag
  pv_statu = icon_change. "변경 Icon

  perform modify_cell using po_data_changed
                            ps_mod_cells-row_id
                            ps_mod_cells-tabix
                            'STATU'
                            pv_statu.

endform.
*&---------------------------------------------------------------------*
*& Form GET_CELL_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form get_cell_value using po_data_changed type ref to
                              cl_alv_changed_data_protocol
                              pv_row_id
                              pv_fieldname
                     changing pv_value.

  clear pv_value.
  po_data_changed->get_cell_value( exporting
                                     i_row_id    = pv_row_id
                                     i_fieldname = pv_fieldname
                                   importing
                                     e_value     = pv_value ).

endform.
*&---------------------------------------------------------------------*
*& Form ADD_PROTOCOL_ENTRY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form add_protocol_entry using po_data_changed type ref to
                                cl_alv_changed_data_protocol
                                pv_msgid
                                pv_msgno
                                pv_msgv1
                                pv_msgv2
                                pv_fieldname
                                pv_row_id.

  data : lt_data type table of lvc_s_msg1
                 with non-unique sorted key key_mode
                 components msgid msgno msgv1 msgv2 fieldname row_id.

  lt_data = po_data_changed->mt_protocol.  "기존 동일 오류 제외

  check not line_exists( lt_data[ key key_mode components msgid     = pv_msgid
                                                          msgno     = pv_msgno
                                                          msgv1     = pv_msgv1
                                                          msgv2     = pv_msgv2
                                                          fieldname = pv_fieldname
                                                          row_id    = pv_row_id ] ).

  po_data_changed->add_protocol_entry(
      exporting
        i_msgid     = pv_msgid
        i_msgno     = pv_msgno
        i_msgty     = zgtsd_e
        i_msgv1     = pv_msgv1
        i_msgv2     = pv_msgv2
        i_fieldname = pv_fieldname
        i_row_id    = pv_row_id ).

endform.
*&---------------------------------------------------------------------*
*& Form MODIFY_CELL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form modify_cell using po_data_changed type ref to
                         cl_alv_changed_data_protocol
                         pv_row_id
                         pv_tabix
                         pv_fieldname
                         pv_value.

  po_data_changed->modify_cell( i_row_id    = pv_row_id
                                i_tabix     = pv_tabix
                                i_fieldname = pv_fieldname
                                i_value     = pv_value ).

endform.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form handle_data_changed_finished using pv_modified
                                            pt_good_cells type lvc_t_modi
                                            po_sender.

  check pv_modified = zgtsd_x
    and po_sender   = go_grid
    and gt_chg is not initial.

*  변경사항 반영
  perform update_edit_fields using gt_chg.

  "Refresh Grid
  perform refresh_table_display using po_sender space.

endform.
*&---------------------------------------------------------------------*
*& Form UPDATE_EDIT_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form update_edit_fields using pt_chg type ty_t_chg.

*  "Set 수정 필드
*  DELETE ADJACENT DUPLICATES FROM PT_CHG USING KEY KEY_MODE COMPARING PSPID.
*
*  LOOP AT PT_CHG INTO DATA(LS_CHG).
*
*    DATA(LS_DATA) = VALUE #( GT_MAIN[ KEY KEY_STUFE
*                               COMPONENTS PSPID = LS_CHG-PSPID
*                                          STUFE = 1 ] OPTIONAL ).
*    CHECK LS_DATA-PSPID IS NOT INITIAL.
*
*    LOOP AT GT_MAIN ASSIGNING FIELD-SYMBOL(<LS_MAIN>) USING KEY KEY_MODE
*                     WHERE PSPID = LS_DATA-PSPID.
*      <LS_MAIN>-Z_IV_PUR       = LS_DATA-Z_IV_PUR.       "자산 매각
*      <LS_MAIN>-Z_IV_ANLKL     = LS_DATA-Z_IV_ANLKL.     "자산 클래스
*      <LS_MAIN>-Z_IV_ANLKL_TXT = LS_DATA-Z_IV_ANLKL_TXT. "자산 클래스 명
*      <LS_MAIN>-Z_KSTAR        = LS_DATA-Z_KSTAR.        "원가요소
*      <LS_MAIN>-Z_KSTAR_TXT    = LS_DATA-Z_KSTAR_TXT.    "원가요소 명
*    ENDLOOP.
*  ENDLOOP.

endform.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form handle_toolbar using po_object type ref to cl_alv_event_toolbar_set
                              po_sender.
  define _add_toolbar.
    LS_TOOLBAR = VALUE #( FUNCTION   = &1
                          ICON       = &2
                          QUICKINFO  = &3
                          TEXT       = &4
                          BUTN_TYPE  = &5 ).

    CASE &6.
      WHEN ZGTSD_A. "Append
        APPEND LS_TOOLBAR TO PO_OBJECT->MT_TOOLBAR.
      WHEN ZGTSD_I. "Insert
        INSERT LS_TOOLBAR INTO PO_OBJECT->MT_TOOLBAR INDEX 1.
    ENDCASE.
  end-of-definition.

  data : ls_toolbar type stb_button.

*  CHECK GV_EDIT = ZGTSD_X.     "수정가능 상태
*
*  CASE PO_SENDER.
*    WHEN GO_GRID. "Main
*      _ADD_TOOLBAR SPACE                SPACE            SPACE    SPACE    3 ZPS01_A.
*      _ADD_TOOLBAR ZPS01_UCOMM-AUC_SETL ICON_GENERATE    TEXT-009 TEXT-009 0 ZPS01_A. "AUC 정산규칙(F) 생성
*  ENDCASE.

endform.
*&---------------------------------------------------------------------*
*& Form REFRESH_TABLE_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form refresh_table_display using po_grid type ref to cl_gui_alv_grid
                                  pv_soft_refresh.

  check po_grid is bound.

  call method po_grid->refresh_table_display
    exporting
      is_stable      = conv #( 'XX' )
      i_soft_refresh = pv_soft_refresh
    exceptions
      finished       = 1
      others         = 2.

endform.
*&---------------------------------------------------------------------*
*& Form HANDLE_ON_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form handle_on_f4 using pv_fieldname type lvc_fname
                            pv_fieldvalue  type lvc_value
                            ps_row_no      type lvc_s_roid
                            po_event_data  type ref to cl_alv_event_data
                            pv_display     type char01
                            po_sender.
  data : lv_value type lvc_value.
  field-symbols : <lt_data> type table.

*  CHECK PO_SENDER = GO_GRID. "Main
*
*  PO_EVENT_DATA->M_EVENT_HANDLED = ZPS01_X.
*
*  CASE PV_FIELDNAME.
*    WHEN ZPS01_FNAME-Z_IV_ANLKL.  "자산 클래스
*
*      PERFORM F4_CODE_MASTER USING    ZPS01_ROLLNAME-ZE_IV_ANLKL
*                                      ZPS01_CODE-PSAC02
*                                      PV_DISPLAY
*                             CHANGING LV_VALUE.
*
*    WHEN OTHERS.
*      RETURN.
*  ENDCASE.
*
*  CHECK LV_VALUE IS NOT INITIAL.
*
*  ASSIGN PO_EVENT_DATA->M_DATA->* TO <LT_DATA>.
*  CHECK SY-SUBRC = 0.
*
*  APPEND VALUE LVC_S_MODI( FIELDNAME = PV_FIELDNAME
*                           ROW_ID    = PS_ROW_NO-ROW_ID
*                           VALUE     = LV_VALUE ) TO <LT_DATA>.

endform.
*&---------------------------------------------------------------------*
*& Form FREE_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form free_object .
* Field Catalog
  clear: gt_fcat[].

* Grid Clear
  call method: go_grid->free.

  clear: go_grid.

* Container Clear
  call method: go_con->free,
               go_split->free,
               go_con_top->free.

  clear: go_con, go_split, go_con_top.
endform.
*&---------------------------------------------------------------------*
*& Form GET_FILE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_file_data .

  data: lo_new_line type ref to data,
        lo_stru_ref type ref to cl_abap_structdescr,
        lo_tab_ref  type ref to cl_abap_tabledescr.

  data: lv_start_col  type int4,
        lv_start_row  type int4 value '2',
        lv_end_col    type int4 value '256',
        lv_end_row    type int4 value '262144',             "'131072',
        lv_fld_col    type i,
        lt_execl_line type kcde_sender,
        lv_sheet_no   type int1,
        lv_separator  type c.

  data : lt_file_table type filetable,
         lv_rc         type i,
         lt_data_tab   type solix_tab.

  data : begin of ls_line_col,
           field(1024),
         end of ls_line_col,
         lt_excel_col like table of ls_line_col.

  field-symbols <lft_xls> type standard table.

*   Header line 수
  lv_start_row = 1. "Header Line + 1

*   시작 Column
  lv_start_col = 0.

*   종료 행
  clear lv_end_row.
  lv_sheet_no = 2.

*   Column 수
  lo_tab_ref  ?= cl_abap_typedescr=>describe_by_data( gt_excel ).
  lo_stru_ref ?= lo_tab_ref->get_table_line_type( ).
  lv_end_col = lines( lo_stru_ref->components ).

  create data lo_new_line like line of gt_excel.
  assign lo_new_line->* to field-symbol(<ls_work>).

  "파일 업로드
  cl_gui_frontend_services=>gui_upload(
    exporting
      filename                = conv #( p_fname )
      filetype                = 'BIN'    " File Type (ASCII, Binary)
    importing
      filelength              = data(lv_length)
    changing
      data_tab                = lt_data_tab
    exceptions
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      others                  = 19
  ).
  if sy-subrc <> 0.
    message id sy-msgid type zgtsd_i number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
               display like zgtsd_e.
    gv_error = zgtsd_x.  exit.
  endif.

  try.
      data(lv_xstring) = cl_bcs_convert=>solix_to_xstring( lt_data_tab ).
      data(lo_excel_ref) = new cl_fdt_xl_spreadsheet( document_name = conv #( p_fname )
                                                      xdocument     = lv_xstring ) .

      "GET LIST OF WORKSHEETS
      lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
        importing
          worksheet_names = data(lt_worksheets) ).

    catch cx_root into data(lo_err).
      message i000 with '엑셀파일 읽는중 오류가 발생했습니다.' display like zgtsd_e.
      gv_error = 'X'. exit.
  endtry .

  check lt_worksheets is not initial.

  try.
      data(lo_data_ref) = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
                                               worksheet_name = lt_worksheets[ lv_sheet_no ] ).
    catch cx_root into lo_err.
      message i000 with '엑셀파일 읽는중 오류가 발생했습니다.' display like zgtsd_e.
      gv_error = 'X'. exit.
  endtry.

  assign lo_data_ref->* to <lft_xls>.
  data(lt_dfies) = cl_salv_ddic=>get_by_data( <lft_xls> ).
  data lv_col_num type i.
  data(lt_comp) = lo_stru_ref->get_components( ).

  loop at <lft_xls> assigning field-symbol(<lfs_xls>).
    clear lv_fld_col.
    if sy-tabix <= lv_start_row.
      continue.
    endif.

    clear <ls_work>.
    loop at lt_dfies into data(ls_dfies).

      assign component ls_dfies-fieldname of structure <lfs_xls> to field-symbol(<lfv_xls>).
      check sy-subrc = 0.

      zgtsd_cl_common=>conv_column_to_i( exporting iv_fld = ls_dfies-fieldname
                                          changing ev_col_num = lv_col_num ).

*특정 컬럼값만 읽어서 사용..3번째(수량) 20번째(배치번호)
      check  lv_col_num = 3 or lv_col_num = 20.
      add 1 to lv_fld_col.

      assign component lv_fld_col of structure <ls_work> to field-symbol(<lfv_itab>).
      check sy-subrc = 0.
      data(lv_name) = lt_comp[ lv_fld_col ]-name.   " ← 필드 이름

      if <lfv_xls> is assigned and <lfv_itab> is assigned.
        describe field <lfv_itab> type data(lv_type).

        case lv_type.

          when zgtsd_d. " DATE.
            zgtsd_cl_common=>conv_date_input( changing cv_input = <lfv_xls> ).
            <lfv_itab> = <lfv_xls>.

          when zgtsd_t. " TIME
            zgtsd_cl_common=>conv_time_input( changing cv_input = <lfv_xls> ).
            <lfv_itab> = <lfv_xls>.

          when zgtsd_i  or zgtsd_p or zgtsd_n or 'b' or 's'. " 숫자인 경우..
            zgtsd_cl_common=>conv_curr_input( changing   cv_input    = <lfv_xls>
                                            exceptions not_numeric = 1 ).
            if sy-subrc eq 0.
              <lfv_itab> = <lfv_xls>.
            else.
              assign component 'ERR_MSG' of structure <ls_work> to field-symbol(<lv_msg>).
              if sy-subrc eq 0.
*                <LFV_ITAB> = <LFV_XLS>.
                message s041 with <lfv_xls> into <lv_msg>.
              endif.
            endif.

          when zgtsd_x. "RAW
            <lfv_itab> = <lfv_xls>.

          when 'g'.
            if <lfv_xls> is initial.
              clear <lfv_itab>.

            else.
              if <lfv_itab> is initial.
                if <lfv_xls>(1) eq gc_quota. "'"'.
                  <lfv_xls>(1) = space.
                endif.
                data(lv_len) = strlen( <lfv_xls> ).
                lv_len = lv_len - 1.
                if <lfv_xls>+lv_len(1) eq gc_quota.
                  <lfv_xls>+lv_len(1) = space.
                endif.
                condense <lfv_xls>.
                <lfv_itab> = <lfv_xls>.
              endif.
            endif.

          when others.
            if <lfv_xls> is initial.
              case lv_name.
                when 'ERR_MSG'.
                when others.
                  clear <lfv_itab>.
              endcase.

            else.
              if <lfv_itab> is initial.
                shift <lfv_xls> left deleting leading space.
                write <lfv_xls> to <lfv_itab> left-justified.
              endif.
            endif.
        endcase.

      endif.

    endloop.

    check <ls_work> is not initial.
    append <ls_work> to gt_excel.
  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form MAKE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form make_data .

  data : lv_posnr type posnr_va.

*: MCH1 테이블에서 배치번호(CHARG) 기준으로 자재코드(MATNR)을 찾는다.
  with +charg as ( select matnr, a~charg, a~kwmeng
                     from @gt_excel as a inner join mch1 as b
                       on a~charg = b~charg
                    where b~lvorm = @space )
       select a~matnr, a~charg, a~kwmeng,
              case d~vrkme
                   when ' ' then b~meins "MVKE-VRKME (존재하지 않을 경우 MARA-MEINS)
                   else d~vrkme
              end as vrkme,
              maktx, d~vtweg, e~werks
         from +charg as a inner join mara as b
           on a~matnr = b~matnr
         left outer join makt as c
           on b~matnr = c~matnr
          and c~spras = @sy-langu
         left outer join mvke as d
           on b~matnr = d~matnr
          and d~vkorg = @p_vkorg
          and d~vtweg = @p_vtweg
         left outer join marc as e
           on b~matnr = e~matnr
          and e~werks = '1401'
         into table @data(lt_updat).


  "-- 자재마스터 영업조직 정보 확인
  read table lt_updat assigning field-symbol(<updat>) with key vtweg = ''.
  if sy-subrc = 0.
    _matnr_o <updat>-matnr <updat>-matnr.
    message s128 with <updat>-charg <updat>-matnr display like gc_e.
    gv_error = zgtsd_x.
    exit.
  endif.

  "-- 자재마스터 플랜트 정보 확인
  read table lt_updat assigning <updat> with key werks = ''.
  if sy-subrc = 0.
    _matnr_o <updat>-matnr <updat>-matnr.
    message s129 with <updat>-charg <updat>-matnr display like gc_e.
    gv_error = zgtsd_x.
    exit.
  endif.


  sort lt_updat by matnr kwmeng charg.


*4)-2 동일 자재코드, 동일 수량 기준으로 품목번호 채번(LT_CHARG)
  loop at lt_updat into data(ls_gr) group by ( matnr  = ls_gr-matnr
                                               kwmeng = ls_gr-kwmeng ).
    add 10 to lv_posnr.
    loop at group ls_gr into data(ls_item).
      clear gs_s0101.
      move-corresponding ls_item to gs_s0101.
      gs_s0101-posnr = lv_posnr.
      append gs_s0101 to gt_s0101.
    endloop.

  endloop.

*4)-3 동일 자재코드, 동일 수량 기준 합산하여 품목정보 인터널 테이블 생성(LT_ITEM)
  loop at gt_s0101 into gs_s0101 group by ( posnr = gs_s0101-posnr ).

    clear gs_s0100.
    move-corresponding gs_s0101 to gs_s0100.
    gs_s0100-vkorg  = p_vkorg.
    gs_s0100-vtweg  = p_vtweg.
    gs_s0100-spart  = p_spart.
    gs_s0100-vkbur  = p_vkbur.
    gs_s0100-vkgrp  = p_vkgrp.
    gs_s0100-auart  = p_auart.
    gs_s0100-kunag  = p_kunag.
    gs_s0100-kunwe  = p_kunwe.
    gs_s0100-kunrg  = p_kunrg.
    gs_s0100-bstnk  = p_bstkd.
    gs_s0100-vdatu  = p_vdatu.
    gs_s0100-jojan  = reduce #( init lv_qty type kwmeng
                                 for ls_qty in gt_s0101 using key k_key
                                where ( posnr = gs_s0101-posnr  )
                                   next lv_qty = ls_qty-kwmeng ).

    gs_s0100-jojan_cnt = reduce #( init lv_cnt type i
                              for ls_qty in gt_s0101 using key k_key
                            where ( posnr = gs_s0101-posnr  )
                             next lv_cnt = lv_cnt + 1 ).

    gs_s0100-kwmeng = reduce #( init lv_qty type kwmeng
                                 for ls_qty in gt_s0101 using key k_key
                               where ( posnr = gs_s0101-posnr  )
                                next lv_qty = lv_qty + ls_qty-kwmeng ).

    append gs_s0100 to gt_s0100.

  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form DATA_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form data_check .

  loop at gt_s0100 into gs_s0100.
    gs_s0100-statu = icon_led_yellow.
    modify gt_s0100 from gs_s0100.
  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form CREATE_SO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form create_so_bdc .

  clear : gs_header_in, gs_header_inx, gv_error, gv_vbeln.

  __cle : gt_items_in, gt_items_inx, gt_partners,
          gt_schdl_in, gt_schdl_inx, gt_cond_in,
          gt_cond_inx, gt_paddr, gt_extens, gt_ref,
          gt_inst, gt_part, gt_val, gt_return.

  data(lt_tmp) = gt_s0100[].
  delete lt_tmp where statu = icon_led_yellow.
  if lt_tmp[] is not initial.
    message s000 with text-e01 display like zgtsd_e.
    exit.
  endif.

**********************************************************************
  clear gv_answer.
  gv_answer = zgtsd_cl_common=>popup_to_comfirm( iv_ucomm = space
                                                 iv_messa = text-m01 ).
  check gv_answer = zgtsd_j.
**********************************************************************

* BDC 준비
  clear : bdctab, bdctab[], g_msg_t, g_msg_t[].
  data : lv_idx(2) type n,
         lv_fname1 type string,
         lv_fname2 type string,
         lv_fname3 type string,
         lv_fname4 type string,
         lv_matnr  type matnr,
         lv_jojan  type string,
         lv_jojanc type string,
         lv_date   type char10.

  read table gt_s0100 into gs_s0100 index 1.
  lv_date = |{ p_vdatu date = user }|.

  perform dynpro using :
    'X'  'SAPMV45A'          '0101',
    ' '  'BDC_CURSOR'        'VBAK-AUART',
    ' '  'BDC_OKCODE'        '=ENT2',
    ' '  'VBAK-AUART'        p_auart,
    ' '  'VBAK-VKORG'        p_vkorg,
    ' '  'VBAK-VTWEG'        p_vtweg,
    ' '  'VBAK-SPART'        p_spart,
    ' '  'VBAK-VKBUR'        p_vkbur,
    ' '  'VBAK-VKGRP'        p_vkgrp.

  perform dynpro using :
    'X'  'SAPMV45A'          '4001',
    ' '  'BDC_OKCODE'        '/00',
    ' '  'VBKD-BSTKD'        p_bstkd,
    ' '  'KUAGV-KUNNR'       p_kunag,
    ' '  'RV45A-KETDAT'      lv_date.

  loop at gt_s0100 into gs_s0100.
    lv_idx = sy-tabix.

    clear lv_matnr.
    call function 'CONVERSION_EXIT_MATN1_INPUT'
      exporting
        input  = gs_s0100-matnr
      importing
        output = lv_matnr.

    lv_jojanc = |{ gs_s0100-jojan_cnt }|.
    condense lv_jojanc.
    lv_jojan = |{ gs_s0100-jojan }|.
    condense lv_jojan.

    data: lv_kwmeng type string.
    lv_kwmeng = |{ gs_s0100-kwmeng }|.
    condense lv_kwmeng.

    lv_fname1 = |RV45A-MABNR({ lv_idx })|.
    lv_fname2 = |RV45A-KWMENG({ lv_idx })|.
    lv_fname3 = |RV45A-MWERT01({ lv_idx })|.
    lv_fname4 = |RV45A-MWERT02({ lv_idx })|.

    perform dynpro using :
      ' '  lv_fname1 lv_matnr,
      ' '  lv_fname2 lv_kwmeng,
      ' '  lv_fname3 lv_jojan,
      ' '  lv_fname4 lv_jojanc.
  endloop.

  perform dynpro using :
    'X'  'SAPMV45A'          '4001',
    ' '  'BDC_OKCODE'        '=SICH',
    ' '  'VBKD-BSTKD'        p_bstkd,
    ' '  'KUAGV-KUNNR'       p_kunag,
    ' '  'KUWEV-KUNNR'       p_kunwe,
    ' '  'RV45A-KETDAT'      lv_date.

  ctu_params-dismode  = 'N'.
  ctu_params-updmode  = 'S'.
  ctu_params-racommit = 'X'.

  call transaction 'VA01' using bdctab
                          options from ctu_params
                          messages into g_msg_t.

  if sy-subrc = 0.
    read table g_msg_t with key msgtyp = 'S' msgid = 'V1' msgnr = '311'.
    if sy-subrc = 0.
      gv_vbeln = g_msg_t-msgv2.
    endif.

    perform save_charg_data.

    clear gs_s0100.
    gs_s0100-statu = icon_led_green.
    modify gt_s0100 from gs_s0100 transporting statu where statu = icon_led_yellow.

    read table gt_s0100 into gs_s0100 index 1.
    gs_s0100-vbeln = gv_vbeln.
    gs_s0100-msg = |판매오더 | && gv_vbeln && |가 생성 되었습니다.|.
    modify gt_s0100 from gs_s0100 index 1.
  else.
    clear gs_s0100.
    gs_s0100-statu = icon_led_red.
    modify gt_s0100 from gs_s0100 transporting statu where statu = icon_led_yellow.

    read table gt_s0100 into gs_s0100 index 1.
    read table g_msg_t with key msgtyp = 'E'.
    if sy-subrc = 0.
      gs_s0100-msg = |BDC 에러: | && g_msg_t-msgv1 && g_msg_t-msgv2 && g_msg_t-msgv3 && g_msg_t-msgv4.
    else.
      gs_s0100-msg = |판매오더 생성 실패 했습니다.|.
    endif.
    modify gt_s0100 from gs_s0100 index 1.
  endif.

  message s000 with '처리 되었습니다.'.
  perform refresh_table_display using go_grid space.

endform.
*&---------------------------------------------------------------------*
*& Form SET_ORDER_HEADER_IN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_order_header_in .

  gs_header_in-doc_type   = gs_s0100-auart. "Sales Document Type
  gs_header_in-sales_org  = gs_s0100-vkorg. "Sales Organization
  gs_header_in-distr_chan = gs_s0100-vtweg. "Distribution Channel
  gs_header_in-division   = gs_s0100-spart. "Division
  gs_header_in-sales_grp  = gs_s0100-vkgrp. "Sales Group
  gs_header_in-sales_off  = gs_s0100-vkbur. "Sales Office
  gs_header_in-purch_no_c = gs_s0100-bstnk. "영업오더의PO번호(PURCH_NO_C)
  gs_header_in-req_date_h = gs_s0100-vdatu. "납품요청일
*  gs_header_in-purch_date = gs_s0100-vdatu. "PO일자
*  gs_header_in-doc_date   = sy-datum. "'증빙일
*  gs_header_in-created_by = sy-uname. "생성자

*  CALL FUNCTION 'CONVERSION_EXIT_AUART_OUTPUT'
*    EXPORTING
*      INPUT  = GS_HEADER_IN-DOC_TYPE
*    IMPORTING
*      OUTPUT = GS_HEADER_IN-DOC_TYPE.

*  gs_header_in-price_date = gs_s0100-vdatu. "가격결정일
*  gs_header_in-incoterms1 = '102'. "GS_S0100-INCO1. "인코텀스
*  gs_header_in-pmnttrms   = 'C090'. "GS_S0100-ZTERM.    "지급조건(코드)
*  gs_header_in-currency   = 'KRW'. "GS_S0100-WAERK.
*  GS_HEADER_IN-WBS_ELEM   = GS_S0100-WBS_ELEM. "작업 분석 구조 요소(WBS 요소)

**********************************************************************
*INX  .
**********************************************************************

  gs_header_inx-updateflag = 'I'.
  gs_header_inx-doc_type   = 'X'.
  gs_header_inx-sales_org  = 'X'.
  gs_header_inx-distr_chan = 'X'.
  gs_header_inx-division   = 'X'.
  gs_header_inx-sales_grp  = 'X'.
  gs_header_inx-sales_off  = 'X'.
  gs_header_inx-purch_no_c = 'X'.
  gs_header_inx-req_date_h = 'X'.

*  gs_header_inx-purch_date = 'X'.
*  gs_header_inx-doc_date = 'X'.

*  gs_header_inx-price_date  = 'X'.
*  gs_header_inx-incoterms1  = 'X'.
*  gs_header_inx-pmnttrms  = 'X'.
*  gs_header_inx-currency = 'X'.
*  GS_HEADER_INX-WBS_ELEM = 'X'.

endform.
*&---------------------------------------------------------------------*
*& Form SET_ORDER_ITEMS_IN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_order_items_in .

  data : ls_order_in  type bapisditm,
         ls_order_inx type bapisditmx,
         lv_matnr     type matnr.

  loop at gt_s0100 into gs_s0100.

    clear : ls_order_in.
    ls_order_in-itm_number = gs_s0100-posnr.

    if gs_s0100-matnr is not initial.
      clear lv_matnr.
      call function 'CONVERSION_EXIT_MATN1_INPUT'
        exporting
          input  = gs_s0100-matnr
        importing
          output = lv_matnr.
    endif.

    ls_order_in-material   = lv_matnr.
*    ls_order_in-plant      = '1401'.
    ls_order_in-target_qty = gs_s0100-kwmeng.
    ls_order_in-target_qu  = gs_s0100-vrkme.
    ls_order_in-sales_unit = gs_s0100-vrkme.
*    ls_order_in-short_text = lv_matnr.
    ls_order_in-po_itm_no  = gs_s0100-posnr.
*    ls_order_in-rec_point  = '4300'.
    append ls_order_in to gt_items_in.

*---- index 추가
    clear ls_order_inx.
    ls_order_inx-itm_number = gs_s0100-posnr.
*    ls_order_inx-plant      = abap_on.
    ls_order_inx-material   = abap_on.
    ls_order_inx-target_qty = abap_on.
    ls_order_inx-target_qu  = abap_on.
    ls_order_inx-sales_unit = abap_on.
*    ls_order_inx-short_text = abap_on.
    ls_order_inx-po_itm_no  = abap_on.
*    ls_order_inx-rec_point  = abap_on.
    append ls_order_inx to gt_items_inx.

  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form SET_ORDER_PARTNERS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_order_partners .

*판매처
  append value #(  partn_role = 'AG'
                   partn_numb = gs_s0100-kunag ) to gt_partners.

*납품처
  append value #(  partn_role = 'WE'
                   partn_numb = gs_s0100-kunwe ) to gt_partners.

*지급처
  append value #(  partn_role = 'RG'
                   partn_numb = gs_s0100-kunrg ) to gt_partners.

endform.
*&---------------------------------------------------------------------*
*& Form SET_ORDER_SCHEDULES_IN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_order_schedules_in .

  data : ls_schld_in  type bapischdl,
         ls_schld_inx type bapischdlx.

  loop at gt_s0100 into gs_s0100.

    clear : ls_schld_in.
    ls_schld_in-itm_number = gs_s0100-posnr.
    ls_schld_in-sched_line = 1.
    ls_schld_in-req_date   = gs_s0100-vdatu.
    ls_schld_in-req_qty    = gs_s0100-kwmeng.
    append ls_schld_in to gt_schdl_in.

*---- index 추가
    clear ls_schld_inx.
    ls_schld_inx-itm_number = gs_s0100-posnr.
    ls_schld_inx-sched_line = abap_on.
    ls_schld_inx-req_date   = abap_on.
    ls_schld_inx-req_qty    = abap_on.
    append ls_schld_inx to gt_schdl_inx.

  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form SET_BAPI_BAPICUVAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_bapi_bapicuval .

  data : lv_config   type bapicurefm-config_id,
         lv_instance type bapicurefm-inst_id,
         lv_matnr    type matnr,
         lv_stdpd    type marc-stdpd.

  loop at gt_s0100 into gs_s0100.

    lv_config   = lv_config + 1.
    lv_instance = 1.

    clear lv_matnr.
    _matnr_i gs_s0100-matnr lv_matnr.

    clear lv_stdpd.
    select single stdpd into lv_stdpd
      from marc
     where matnr = lv_matnr
       and werks = '1401'.

    condense lv_stdpd.
    check lv_stdpd is not initial.

    append value #( posex     = gs_s0100-posnr
                    config_id = lv_config
                    root_id   = lv_instance
                    sce       = space
                    kbname    = lv_stdpd
                    kbversion = '001' ) to gt_ref.

**********************************************************************

    append value #( config_id   = lv_config
                    inst_id     = lv_instance
                    obj_type    = 'MARA'
                    class_type  = '300'
                    obj_key     = lv_stdpd ) to gt_inst.

**********************************************************************

    append value #( config_id   = lv_config
                    inst_id     = lv_instance
                    charc       = 'SAP_LENGTH_VKRME'
                    value       = |{ gs_s0100-jojan number = raw }| ) to gt_val.

    append value #( config_id   = lv_config
                    inst_id     = lv_instance
                    charc       = 'SAP_MILLCA_FACTOR'
                    value       = |{ gs_s0100-jojan_cnt number = raw }| ) to gt_val.

    append value #( config_id   = lv_config
                    inst_id     = lv_instance
                    charc       = 'PD_AA_WITNESS_INSPECTION'
                    value       = |무| ) to gt_val.

**********************************************************************

  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form SAVE_CHARG_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form save_charg_data .

  data : lt_0011 like table of zgtsdt0011 with header line.
  data : lv_seqno like zgtsdt0011-seqno.

  sort gt_s0101 by posnr matnr kwmeng charg.

  loop at gt_s0101 into gs_s0101.

    at new posnr.
      lv_seqno = 0.
    endat.

    add 1 to lv_seqno.

    move-corresponding gs_s0101 to lt_0011.
    lt_0011-vbeln = gv_vbeln.
    lt_0011-seqno = lv_seqno.
    zgtsd_cl_common=>set_timestamp( exporting iv_gubun = zgtsd_c
                                     changing cs_timestamp = lt_0011-timestamp ).
    append lt_0011. clear lt_0011.

  endloop.

  if lt_0011[] is not initial.
    modify zgtsdt0011 from table lt_0011.
    if sy-subrc = 0.
      commit work.
    endif.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form get_file_data_new
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_file_data_new .

  types : truxs_t_text_data(4096) type c occurs 0.

  data : lv_data  type truxs_t_text_data,
         lv_file1 like rlgrap-filename,
         lv_file2 type string.
  data : lv_string type string.

  data: begin of l_file_t occurs 0,
          fld01(20),
          fld02(20),
          fld03(20),
          fld04(20),
          fld05(20),
          fld06(20),
          fld07(20),
          fld08(20),
          fld09(20),
          fld10(20),
          fld11(20),
          fld12(20),
          fld13(20),
          fld14(20),
          fld15(20),
          fld16(20),
          fld17(20),
          fld18(20),
          fld19(20),
          fld20(20),
          fld21(20),
          fld22(20),
          fld23(20),
          fld24(20),
          fld25(20),
          fld26(20),
          fld27(20),
        end of l_file_t.

  clear : l_file_t,  l_file_t[].


  lv_file1 = p_fname.

  call function 'ZCOMM_UPLOAD_EXCEL'
    exporting
      i_filename   = lv_file1
      i_headerline = '1'
    importing
      e_message    = lv_string
    tables
      t_tab        = l_file_t.


  if  sy-subrc  ne  0.

    message e001 with 'File not open.'.
    gv_error = 'X'.
    exit.

  endif.

  "-- 3과 20 컬럼만 사용함
  loop at l_file_t.
    gs_excel-kwmeng = l_file_t-fld03.
    gs_excel-charg  = l_file_t-fld20.
    append gs_excel to gt_excel.
  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form check_batch_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form check_batch_data .

  data : begin of lt_excel occurs 0,
           charg type charg_d,
           cnt   type i,
         end of lt_excel.

  check gt_excel[] is not initial.

  "-- 수량(KWMENG)에 값이 1개라도 없으면, Error
  read table gt_excel into gs_excel with key kwmeng = 0.
  if sy-subrc = 0.
    message s126 with sy-tabix display like gc_e. "수량(=길이) 정보가 없습니다
    gv_error = zgtsd_x.
    exit.
  endif.

  "-- 배치번호(CHARG)에 값이 1개라도 없으면, Error
  read table gt_excel into gs_excel with key charg = ''.
  if sy-subrc = 0.
    message s127 with sy-tabix display like gc_e. "배치 정보가 없습니다.
    gv_error = zgtsd_x.
    exit.
  endif.

  "-- 배치번호(CHARG)가 1개라도 중복으로 입력되면 Error
  select a~charg, count(*) as cnt
    from @gt_excel as a
   group by a~charg
    into corresponding fields of table @lt_excel.

  delete lt_excel where cnt = 1.

  if lines( lt_excel ) > 0.
    read table lt_excel index 1.
    message s124 with lt_excel-charg display like gc_e. "배치 &1가 중복으로 입력되었습니다.
    gv_error = zgtsd_x.
    exit.
  endif.

  "-- 자재코드(MATNR)를 1개라도 찾지 못하면 Error
  select charg
    from @gt_excel as a
   where not exists ( select mandt
                        from mch1
                       where charg = a~charg
                         and lvorm = @space )
   into table @data(lt_err_charg).

  read table lt_err_charg into data(ls_err) index 1.
  if sy-subrc = 0.
    message s125 with ls_err-charg display like gc_e. "배치 &1 대한 자재코드가 없습니다. 마스터를 확인하시기 바랍니다.
    gv_error = zgtsd_x.
    exit.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form CHECK_VKORG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form check_vkorg .
  if p_vkorg is not initial.
    select single mandt into sy-mandt from tvko where vkorg = p_vkorg.
    if sy-subrc <> 0.
      message e001 with text-s01 text-e02.
    endif.
    select single * from tvko where vkorg = p_vkorg.
*    perform check_tvta.
*    perform check_tvkbz.
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form CHECK_AUART
*&---------------------------------------------------------------------*
form check_auart .
  if p_auart is not initial.
    select single mandt into sy-mandt from tvak where auart = p_auart.
    if sy-subrc <> 0.
      message e001 with text-s02 text-e02.
    else.
      if p_auart = 'TA' or p_auart = 'ZEXE'.
      else.
        message e117.
      endif.
    endif.
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form CHECK_VTWEG
*&---------------------------------------------------------------------*
form check_vtweg .
  if p_vtweg is not initial.
    select single mandt into sy-mandt from tvtw where vtweg = p_vtweg.
    if sy-subrc <> 0.
      message e001 with text-s04 text-e02.
    endif.
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form CHECK_KUNAG
*&---------------------------------------------------------------------*
form check_kunag .
  if p_kunag is not initial.
    select single mandt into sy-mandt from kna1 where kunnr = p_kunag.
    if sy-subrc <> 0.
      message e001 with text-s05 text-e02.
    endif.
*    perform check_kunnr_bukrs using text-s05 p_kunag.
*    perform check_kunnr_knvv  using text-s05 p_kunag.
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form CHECK_SPART
*&---------------------------------------------------------------------*
form check_spart .
  if p_spart is not initial.
    select single mandt into sy-mandt from tspa where spart = p_spart.
    if sy-subrc <> 0.
      message e001 with text-s06 text-e02.
    endif.
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form CHECK_KUNWE
*&---------------------------------------------------------------------*
form check_kunwe .
  check sy-subrc = 0.
  if p_kunwe is not initial.
    select single mandt into sy-mandt from kna1 where kunnr = p_kunwe.
    if sy-subrc <> 0.
      message e001 with text-s07 text-e02.
    endif.
*    perform check_kunnr_knvv  using text-s07 p_kunwe.
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form CHECK_VKBUR
*&---------------------------------------------------------------------*
form check_vkbur .
  if p_vkbur is not initial.
    select single mandt into sy-mandt from tvbur where vkbur = p_vkbur.
    if sy-subrc <> 0.
      message e001 with text-s08 text-e02.
    endif.
*    perform check_tvbvk.
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form CHECK_KUNRG
*&---------------------------------------------------------------------*
form check_kunrg .
  if p_kunrg is not initial.
    select single mandt into sy-mandt from kna1 where kunnr = p_kunrg.
    if sy-subrc <> 0.
      message e001 with text-s09 text-e02.
    endif.
*    perform check_kunnr_bukrs using text-s09 p_kunrg.
*    perform check_kunnr_knvv  using text-s09 p_kunrg.
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form CHECK_VKGRP
*&---------------------------------------------------------------------*
form check_vkgrp .
  if p_vkgrp is not initial.
    select single mandt into sy-mandt from tvkgr where vkgrp = p_vkgrp.
    if sy-subrc <> 0.
      message e001 with text-s10 text-e02.
    endif.
*    perform check_tvbvk.
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form check_tvta
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form check_tvta .
  "-- 영업조직구조 체크
  check sy-subrc = 0.

  if p_vkorg is not initial and
     p_vtweg is not initial and
     p_spart is not initial.
    select single mandt into sy-mandt
      from tvta
     where vkorg = p_vkorg
       and vtweg = p_vtweg
       and spart = p_spart.
    if sy-subrc <> 0.
      message s118 with p_vkorg p_vtweg p_spart display like gc_e.
    endif.
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form check_tvkbz
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form check_tvkbz .
  "-- 영업조직구조 영업팀 체크
  check sy-subrc = 0.

  if p_vkorg is not initial and
     p_vtweg is not initial and
     p_spart is not initial and
     p_vkbur is not initial.
    select single mandt into sy-mandt
      from tvkbz
     where vkorg = p_vkorg
       and vtweg = p_vtweg
       and spart = p_spart
       and vkbur = p_vkbur.
    if sy-subrc <> 0.
      message s119 with p_vkorg p_vtweg p_spart p_vkbur display like gc_e.
    endif.
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form check_TVBVK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form check_tvbvk .
  "-- 영업팀/영업그룹 체크
  if p_vkbur is not initial and
     p_vkgrp is not initial.
    select single mandt into sy-mandt
      from tvbvk
     where vkbur = p_vkbur
       and vkgrp = p_vkgrp.
    if sy-subrc <> 0.
      message s120 with p_vkbur p_vkgrp display like gc_e.
    endif.
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form check_kunag_bukrs
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form check_kunag_bukrs .
  "-- 판매처 체크
  select single mandt into sy-mandt
    from knb1
   where kunnr = p_kunag
     and bukrs = tvko-bukrs.
  if sy-subrc <> 0.
    message s121 with text-s05 p_kunag display like gc_e.
    gv_error = zgtsd_x.
    return.
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form check_KUNNR_bukrs
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TEXT_S05
*&      --> P_KUNAG
*&---------------------------------------------------------------------*
form check_kunnr_bukrs  using    pv_text
                                 pv_kunnr.
  check sy-subrc = 0.

  if pv_kunnr is not initial.
    select single mandt into sy-mandt
      from knb1
     where kunnr = pv_kunnr
       and bukrs = tvko-bukrs.
    if sy-subrc <> 0.
      message s121 with pv_text pv_kunnr display like gc_e.
    endif.
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form check_kunnr_knvv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TEXT_S05
*&      --> P_KUNAG
*&---------------------------------------------------------------------*
form check_kunnr_knvv  using    pv_text
                                pv_kunnr.
  check sy-subrc = 0.

  if pv_kunnr is not initial and
     p_vkorg is not initial and
     p_vtweg is not initial and
     p_spart is not initial.
    select single mandt into sy-mandt
      from knvv
     where kunnr = pv_kunnr
       and vkorg = p_vkorg
       and vtweg = p_vtweg
       and spart = p_spart.
    if sy-subrc <> 0.
      message s122 with pv_text pv_kunnr display like gc_e.
    endif.
  endif.
endform.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form create_so
*&---------------------------------------------------------------------*
form create_so .

  clear : gs_header_in, gs_header_inx, gv_error, gv_vbeln.

  __cle : gt_items_in, gt_items_inx, gt_partners,
          gt_schdl_in, gt_schdl_inx, gt_cond_in,
          gt_cond_inx, gt_paddr, gt_extens, gt_ref,
          gt_inst, gt_part, gt_val, gt_return.

  data(lt_tmp) = gt_s0100[].
  delete lt_tmp where statu = icon_led_yellow.
  if lt_tmp[] is not initial.
    message s000 with text-e01 display like zgtsd_e.
    exit.
  endif.

**********************************************************************
  clear gv_answer.
  gv_answer = zgtsd_cl_common=>popup_to_comfirm( iv_ucomm = space
                                                 iv_messa = text-m01 ).
  check gv_answer = zgtsd_j.
**********************************************************************

*HEADER
  perform set_order_header_in.

*ITEM
  perform set_order_items_in.

*PARTNER
  perform set_order_partners.

*SCHEDULES
  perform set_order_schedules_in.

*EXTENSIONIN : 조장수 입력시 반드시 필요함
  perform set_extensionin.

*  "Characteristics
  perform set_bapi_bapicuval.

**********************************************************************
**********************************************************************
  call function 'BAPI_SALESORDER_CREATEFROMDAT2'
    exporting
      order_header_in     = gs_header_in
      order_header_inx    = gs_header_inx
    importing
      salesdocument       = gv_vbeln
    tables
      return              = gt_return
      order_items_in      = gt_items_in
      order_items_inx     = gt_items_inx
      order_partners      = gt_partners
      order_schedules_in  = gt_schdl_in
      order_schedules_inx = gt_schdl_inx
*     ORDER_CONDITIONS_IN = GT_COND_IN
*     ORDER_CONDITIONS_INX = GT_COND_INX
      order_cfgs_ref      = gt_ref
      order_cfgs_inst     = gt_inst
      order_cfgs_part_of  = gt_part
      order_cfgs_value    = gt_val
      extensionin         = gt_extens "이부분이 없으면 조장수입력이 안됨
*     PARTNERADDRESSES    = GT_PADDR.
    .

  if gv_vbeln is initial.

    call function 'BAPI_TRANSACTION_ROLLBACK'.

    clear gs_s0100.
    gs_s0100-statu = icon_led_red.
    modify gt_s0100 from gs_s0100 transporting statu where statu = icon_led_yellow.

    read table gt_s0100 into gs_s0100 index 1.

    read table gt_return with key type = 'E'.
    if sy-subrc = 0.
      gs_s0100-msg = gt_return-message. "|판매오더 생성 실패 했습니다.|.
    else.
      read table gt_return with key type = 'A'.
      if sy-subrc = 0.
        gs_s0100-msg = gt_return-message. "|판매오더 생성 실패 했습니다.|.
      else.
        gs_s0100-msg = |판매오더 생성 실패 했습니다.|.
      endif.
    endif.

    modify gt_s0100 from gs_s0100 transporting statu msg where vbeln <> 'all'.

  else.

    call function 'BAPI_TRANSACTION_COMMIT'
      exporting
        wait = 'X'.

**********************************************************************
*   6)-2 배치정보 판매오더 번호 업데이트하여 CBO Table 저장
    perform save_charg_data.
**********************************************************************


    clear gs_s0100.
    gs_s0100-statu = icon_led_green.
    modify gt_s0100 from gs_s0100 transporting statu where statu = icon_led_yellow.

    read table gt_s0100 into gs_s0100 index 1.
    gs_s0100-vbeln = gv_vbeln.
    gs_s0100-msg = |판매오더| && gv_vbeln && |가 생성 되었습니다.|.
    modify gt_s0100 from gs_s0100 transporting vbeln msg where vbeln <> 'all'.

  endif.

  message s000 with '처리 되었습니다.'.
  perform refresh_table_display using go_grid space.

endform.

*&---------------------------------------------------------------------*
*&      Form  dynpro
*&---------------------------------------------------------------------*
form dynpro using dynbegin fnam fval.

  clear bdctab.

  if  dynbegin  =  'X'.

    bdctab-dynbegin  =  'X'.
    bdctab-program   =  fnam.
    bdctab-dynpro    =  fval.
    append bdctab.

  else.

    bdctab-fnam      =  fnam.
    bdctab-fval      =  fval.
    append bdctab.

  endif.

endform.                    " dynpro
*&---------------------------------------------------------------------*
*& Form set_extensionin
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_extensionin .

  "for bapi extension
  data : gs_bape_vbap   type bape_vbap,
         gs_bape_vbapx  type bape_vbapx,
         gs_bape_vbak   type bape_vbak,
         gs_bape_vbakx  type bape_vbakx,
         gs_extensionin type bapiparex.
  data: lv_zpjno type zpjno.

  "for exttenstion fields
*  gs_bape_vbak-conno        = ''.
*  gs_bape_vbak-zpjno        = ''.
  gs_bape_vbak-zcstat       = 'N'.
*  gs_bape_vbak-zelosrt      = ''.
  gs_extensionin-structure  = 'BAPE_VBAK'.
  gs_extensionin-valuepart1 = gs_bape_vbak.
  append gs_extensionin to gt_extens.

*  gs_bape_vbakx-conno       = 'X'.
*  gs_bape_vbakx-zpjno       = 'X'.
  gs_bape_vbakx-zcstat      = 'X'.
*  gs_bape_vbakx-zelosrt     = 'X'.
  gs_extensionin-structure  = 'BAPE_VBAKX'.
  gs_extensionin-valuepart1 = gs_bape_vbakx.
  append gs_extensionin to gt_extens.


  "-- VBAP-AFNAM, KONNR, KTPNR 를 사용하는 방법
  "-- MV45AFZB FORM USEREXIT_MOVE_FIELD_TO_ME_REQ. 에 추가로직 필요
  loop at gt_s0100 into gs_s0100.
    gs_bape_vbap-posnr        = gs_s0100-posnr.
*    gs_bape_vbap-afnam        = ''. "pt_item-afnam.
*    gs_bape_vbap-konnr        = ''. "pt_item-konnr.
*    gs_bape_vbap-ktpnr        = ''. "pt_item-ktpnr.
    gs_extensionin-structure  = 'BAPE_VBAP'.
    gs_extensionin-valuepart1 = gs_bape_vbap.
    append gs_extensionin to gt_extens.

    gs_bape_vbapx-posnr       = gs_s0100-posnr.
*    gs_bape_vbapx-afnam       = 'X'.
*    gs_bape_vbapx-konnr       = 'X'.
*    gs_bape_vbapx-ktpnr       = 'X'.
    gs_extensionin-structure  = 'BAPE_VBAPX'.
    gs_extensionin-valuepart1 = gs_bape_vbapx.
    append gs_extensionin to gt_extens.
  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form get_file_data_web
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_file_data_web .

  data: begin of l_file_s,
          fld01(20),
          fld02(20),
          fld03(20),
          fld04     type p decimals 3,
          fld05     type p decimals 3,
          fld06     type p decimals 3,
          fld07     type p decimals 3,
          fld08     type p decimals 3,
          fld09     type i,
          fld10     type p decimals 3,
          fld11     type p decimals 3,
          fld12     type i,
          fld13     type p decimals 3,
          fld14     type i,
          fld15     type p decimals 3,
          fld16     type p decimals 3,
          fld17     type p decimals 3,
          fld18     type i,
          fld19(20),
          fld20(20),
          fld21     type i,
          fld22     type i,
          fld23     type p decimals 3,
          fld24     type p decimals 3,
          fld25     type p decimals 3,
*          fld26(20),
*          fld27(20),
        end of l_file_s.
  data : l_file_t like table of l_file_s.

  clear : l_file_t,  l_file_t[].


  zgtsd_cl_common=>excel_web_upload( exporting iv_filename  = p_fname
                                               iv_uppercase = space
                                     importing et_table     = l_file_t ).

  "-- 3과 20 컬럼만 사용함
  loop at l_file_t into l_file_s.
    gs_excel-kwmeng = l_file_s-fld03.
    gs_excel-charg  = l_file_s-fld20.
    append gs_excel to gt_excel.
  endloop.

endform.
