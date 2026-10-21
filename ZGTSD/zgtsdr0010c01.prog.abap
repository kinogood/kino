*&---------------------------------------------------------------------*
*& Include          ZGTSDR0010C01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* CLASS LCL_EVENT_RECEIVER DEFINITION
*----------------------------------------------------------------------*
class lcl_event_receiver definition.

  public section.

    methods : handle_top_of_page
      for event top_of_page of cl_gui_alv_grid
      importing e_dyndoc_id sender.

    methods : handle_hotspot_click
      for event hotspot_click of cl_gui_alv_grid
      importing e_row_id e_column_id es_row_no sender.

    methods : handle_dbl_click
      for event double_click of cl_gui_alv_grid
      importing e_row e_column es_row_no.


    methods : handle_data_changed
      for event data_changed of cl_gui_alv_grid
      importing er_data_changed sender.

    methods : handle_data_changed_finished
      for event data_changed_finished of cl_gui_alv_grid
      importing e_modified et_good_cells sender.

    methods : handle_toolbar
      for event toolbar of cl_gui_alv_grid
      importing e_object sender.

    methods : handle_user_command
      for event user_command of cl_gui_alv_grid
      importing e_ucomm sender.

    methods : handle_on_f4
      for event onf4 of cl_gui_alv_grid
      importing e_fieldname   e_fieldvalue es_row_no
                er_event_data e_display sender.

endclass.

*----------------------------------------------------------------------*
* CLASS LCL_EVENT_RECEIVER IMPLEMENTATION
*----------------------------------------------------------------------*
class lcl_event_receiver implementation.

  method handle_top_of_page.
    perform handle_top_of_page using e_dyndoc_id sender.
  endmethod.

  method handle_hotspot_click.
    perform handle_hotspot_click using e_column_id es_row_no sender.
  endmethod.

  method handle_dbl_click.
    perform handle_dbl_click using e_row e_column.
  endmethod.

  method handle_data_changed.
    perform handle_data_changed using er_data_changed sender.
  endmethod.

  method handle_data_changed_finished.
    perform handle_data_changed_finished using e_modified et_good_cells sender.
  endmethod.

  method handle_toolbar.
    perform handle_toolbar using e_object sender.
  endmethod.

  method handle_user_command.

    "Check Changed Data
    perform check_changed_data using go_grid zgtsd_x.
    check gv_error is initial.

    case e_ucomm.
      when 'PACK'.      "PACKING LIST
        perform get_packing_list.
      when 'HIST'.      "등록이력
        perform get_history.
*      WHEN 'APPL'.      "일괄등록
*        PERFORM ALL_APPLY.
      when 'APPL_PP'.  gv_apply_mode = 'PP'.  perform all_apply.
      when 'APPL_QM'.  gv_apply_mode = 'QM'.  perform all_apply.
      when 'APPL_LE'.  gv_apply_mode = 'LE'.  perform all_apply.
      when 'APPL_LO'.  gv_apply_mode = 'LO'.  perform all_apply.
      when 'REF'.       "새로고침
        perform data_query using 'X'.
        perform set_color.
        perform refresh_table_display using go_grid ''.
    endcase.

  endmethod.

  method handle_on_f4.
    perform handle_on_f4 using e_fieldname
                               e_fieldvalue
                               es_row_no
                               er_event_data
                               e_display
                               sender.
  endmethod.

endclass.
