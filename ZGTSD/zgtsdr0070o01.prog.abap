*----------------------------------------------------------------------*
***INCLUDE ZGTSDR0070O01
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  CREATE_ALV_GRID  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module create_alv_grid output.

  if go_docking is initial.
    perform create_container.
    perform create_tree.
    perform create_grid.
    perform set_event_handle.
    perform display_grid.

    " 당월 데이터가 있으면 default로 보여준다.
    if gv_nkey_m0 is not initial.
      perform get_item_detail using gv_nkey_m0  c_so.
      perform set_selected_node_m0.
    endif.

  endif.

  perform display_sub_grid.

  call method g_alv_tree->column_optimize.

endmodule.                 " CREATE_ALV_GRID  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0100 output.


  data: lt_exclude type table of sy-ucomm,
        ls_exclude type sy-ucomm.

  clear lt_exclude.

  "-- 전체조회시에는 저장하면 안됨
  if p_pernr = '99999999' or p_pernr is initial.
*    ls_exclude = 'ZNEW'.
*    append ls_exclude to lt_exclude.
    ls_exclude = 'SAVE'.
    append ls_exclude to lt_exclude.
  endif.

  set pf-status 'STATUS_0100' excluding lt_exclude.


  if gv_read_new = 'X'.
    set titlebar 'T100' with '최신 주문 진행 현황을 반영한 '.
  else.
    data lv_txt(100).
*    lv_txt = gv_max_week && '주차 판매계획에서 조회한 '.
    lv_txt = '최종 저장된 매출추정 현황에서 조회한'.
    set titlebar 'T100' with lv_txt.
  endif.


endmodule.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module status_0200 output.
  set pf-status 'STATUS_0200'.
  set titlebar 'T200'.
endmodule.
*&---------------------------------------------------------------------*
*& Module MODIFY_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module modify_0200 output.


endmodule.
*&---------------------------------------------------------------------*
*& Module CREATE_EDITOR OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module create_editor output.

  if g_editor is initial.

*   create control container
    create object g_editor_container
      exporting
        container_name              = 'TEXTEDITOR1'
      exceptions
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.
    if sy-subrc ne 0.
*      add your handling
    endif.

*    G_MYCONTAINER = 'TEXTEDITOR1'.

*   create calls constructor, which initializes, creats and links
*   TextEdit Control
    create object g_editor
      exporting
        parent                     = g_editor_container
        wordwrap_mode              =
*             cl_gui_textedit=>wordwrap_off
                                     cl_gui_textedit=>wordwrap_at_fixed_position
*             cl_gui_textedit=>WORDWRAP_AT_WINDOWBORDER
        wordwrap_position          = line_length
        wordwrap_to_linebreak_mode = cl_gui_textedit=>true.

*   to handle different containers
*    G_CONTAINER_LINKED = 1.

    call method g_editor->set_toolbar_mode
      exporting
        toolbar_mode = cl_gui_textedit=>false.

  endif.


  call method g_editor->set_text_as_r3table
    exporting
      table = g_mytable.

  refresh g_mytable.  " to initialize table upon OK_CODE 'BACK' at PAI


endmodule.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module status_0300 output.
  set pf-status 'STATUS_0300'.
  set titlebar 'T300'.
endmodule.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_GRID_200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module create_alv_grid_200 output.

  if go_container_200 is initial.
    " Container 생성
    create object go_container_200
      exporting
        container_name = 'GC200_ALV'.

    " ALV Grid 생성
    create object go_grid_200
      exporting
        i_parent = go_container_200.

    " 레이아웃 설정
    gs_layout_200-sel_mode = 'A'.
    gs_layout_200-zebra    = 'X'.
    gs_layout_200-col_opt    = abap_true.
*    gs_layout_200-cwidth_opt = 'A'.  "ABAP_TRUE.
*    gs_layout_200-edit     = 'X'.
    gs_layout_200-stylefname = 'FIELD_STYLE'. " 인터널 테이블에 추가한 필드명

    append cl_gui_alv_grid=>mc_fc_loc_append_row to gt_excl_func_200.
    append cl_gui_alv_grid=>mc_fc_loc_copy to gt_excl_func_200.
    append cl_gui_alv_grid=>mc_fc_loc_copy_row to gt_excl_func_200.
    append cl_gui_alv_grid=>mc_fc_loc_cut to gt_excl_func_200.
    append cl_gui_alv_grid=>mc_fc_loc_delete_row to gt_excl_func_200.
    append cl_gui_alv_grid=>mc_fc_loc_insert_row to gt_excl_func_200.
    append cl_gui_alv_grid=>mc_fc_loc_move_row to gt_excl_func_200.
    append cl_gui_alv_grid=>mc_fc_loc_paste to gt_excl_func_200.
    append cl_gui_alv_grid=>mc_fc_loc_paste_new_row to gt_excl_func_200.

    perform set_fieldcat_200  using 'zgtsds0043'
                                     gt_list_200[]
                                     gt_fcat_200[].

    " 이벤트 핸들러 등록
    create object go_handler_200.
    set handler go_handler_200->on_toolbar      for go_grid_200.
    set handler go_handler_200->on_user_command for go_grid_200.
    set handler go_handler_200->handle_data_changed for go_grid_200.

    " ALV 표시
    call method go_grid_200->set_table_for_first_display
      exporting
        is_layout            = gs_layout_200
        it_toolbar_excluding = gt_excl_func_200
      changing
        it_outtab            = gt_list_200[]
        it_fieldcatalog      = gt_fcat_200[].

    call method go_grid_200->register_edit_event
      exporting
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

    go_grid_200->set_ready_for_input( 1 ).

  else.
    call method go_grid_200->refresh_table_display.
  endif.

endmodule.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_GRID_300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module create_alv_grid_300 output.

  if go_container_300 is initial.
    " Container 생성
    create object go_container_300
      exporting
        container_name = 'GC300_ALV'.

    " ALV Grid 생성
    create object go_grid_300
      exporting
        i_parent = go_container_300.

    " 레이아웃 설정
    gs_layout_300-sel_mode = 'A'.
    gs_layout_300-zebra    = 'X'.
    gs_layout_300-col_opt    = abap_true.
    gs_layout_300-cwidth_opt = 'A'.  "ABAP_TRUE.
*    gs_layout_300-edit     = 'X'.
    gs_layout_300-stylefname = 'FIELD_STYLE'. " 인터널 테이블에 추가한 필드명

    append cl_gui_alv_grid=>mc_fc_loc_append_row to gt_excl_func_300.
    append cl_gui_alv_grid=>mc_fc_loc_copy to gt_excl_func_300.
    append cl_gui_alv_grid=>mc_fc_loc_copy_row to gt_excl_func_300.
    append cl_gui_alv_grid=>mc_fc_loc_cut to gt_excl_func_300.
    append cl_gui_alv_grid=>mc_fc_loc_delete_row to gt_excl_func_300.
    append cl_gui_alv_grid=>mc_fc_loc_insert_row to gt_excl_func_300.
    append cl_gui_alv_grid=>mc_fc_loc_move_row to gt_excl_func_300.
    append cl_gui_alv_grid=>mc_fc_loc_paste to gt_excl_func_300.
    append cl_gui_alv_grid=>mc_fc_loc_paste_new_row to gt_excl_func_300.

    perform set_fieldcat_300  using 'zgtsds0044'
                                     gt_list_300[]
                                     gt_fcat_300[].

    " 이벤트 핸들러 등록
    create object go_handler_300.
    set handler go_handler_300->on_toolbar      for go_grid_300.
    set handler go_handler_300->on_user_command for go_grid_300.
    set handler go_handler_300->handle_data_changed for go_grid_300.
    set handler go_handler_300->on_f4               for go_grid_300.

    " ALV 표시
    call method go_grid_300->set_table_for_first_display
      exporting
        is_layout            = gs_layout_300
        it_toolbar_excluding = gt_excl_func_300
      changing
        it_outtab            = gt_list_300[]
        it_fieldcatalog      = gt_fcat_300[].

    clear gs_f4.
    gs_f4-fieldname  = 'SPMON'.   " F4 팝업을 띄울 필드명
    gs_f4-register   = 'X'.       " F4 이벤트 활성화
    gs_f4-getbefore  = 'X'.       " 팝업 띄우기 전 셀의 기존 값 가져오기
    gs_f4-chngeafter = 'X'.       " 팝업에서 선택한 값 적용하기
    append gs_f4 to gt_f4.

    " ALV 그리드에 F4 대상 필드 등록
    call method go_grid_300->register_f4_for_fields
      exporting
        it_f4 = gt_f4.

    call method go_grid_300->register_edit_event
      exporting
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

    go_grid_300->set_ready_for_input( 1 ).

  else.
    call method go_grid_300->refresh_table_display.
  endif.

endmodule.
*&---------------------------------------------------------------------*
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module status_0400 output.
  set pf-status 'STATUS_0400'.
  set titlebar 'T400'.
endmodule.
