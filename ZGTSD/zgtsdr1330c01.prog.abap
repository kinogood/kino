*&---------------------------------------------------------------------*
*& Include          ZGTSDR1300C01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  TYPES                                                               *
*----------------------------------------------------------------------*
type-pools : slis.

*----------------------------------------------------------------------*
*  DATA                                                                *
*----------------------------------------------------------------------*
**     Internal Table
data : g_events_t           type slis_t_event,
       g_list_top_of_page_t type slis_t_listheader,
       g_fieldcat_t         type slis_t_fieldcat_alv,
       g_fieldcat_t2        type lvc_t_fcat,
       g_field_t            type slis_t_fieldcat_alv with header line,
       g_sort_t             type slis_t_sortinfo_alv.

**     구조
data : g_layout_s              type slis_layout_alv,
       g_exit_caused_by_user_s type slis_exit_by_user,
       g_variant_s             type disvariant,
       g_fieldcat_s            type slis_fieldcat_alv,
       g_sort_s                type slis_sortinfo_alv.

**     일반변수
data : g_exit_caused_by_caller type c,
       g_save                  type c,
       g_repid                 type sy-repid,
       g_program               like sy-repid,
       g_pos                   like sy-cucol.

** Layout관련
* The variables 'def_layout' and 'spec_layout' are set during
* interactions on the selection screen.
* 'gs_variant' finally holds the chosen layout.
data : def_layout  type disvariant,     " default layout
       default     type c value ' ',
       spec_layout type disvariant,     " specific layout
       gs_variant  type disvariant.     " finally chosen layout

data : g_layout type disvariant,
       g_exit   type c.  "is set if the user has aborted a layout popup

*----------------------------------------------------------------------*
*  CONSTANTS:                                                          *
*----------------------------------------------------------------------*
constants : c_status_set   type slis_formname value 'PF_STATUS_SET',
            c_user_command type slis_formname value 'USER_COMMAND',
            c_top_of_page  type slis_formname value 'TOP_OF_PAGE',
            c_top_of_list  type slis_formname value 'TOP_OF_LIST',
            c_end_of_list  type slis_formname value 'END_OF_LIST'.

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
**    perform handle_top_of_page using e_dyndoc_id sender.
  endmethod.

  method handle_hotspot_click.
**    perform handle_hotspot_click using e_column_id es_row_no sender.
  endmethod.

  method handle_dbl_click.
    perform handle_dbl_click using e_row e_column.
  endmethod.

  method handle_data_changed.
**    perform handle_data_changed using er_data_changed sender.
  endmethod.

  method handle_data_changed_finished.
**    perform handle_data_changed_finished using e_modified et_good_cells sender.
  endmethod.

  method handle_toolbar.
**    perform handle_toolbar using e_object sender.
  endmethod.

  method handle_user_command.

    "Check Changed Data
**    perform check_changed_data using go_grid zgtsd_x.
**    check gv_error is initial.

    case e_ucomm.
*      when 'PACK'.      "PACKING LIST
*        perform get_packing_list.
*      when 'HIST'.      "등록이력
*        perform get_history.
      when 'REF'.       "새로고침
**        perform data_query using 'X'.
**        perform set_color.
**        perform refresh_table_display using go_grid ''.
    endcase.

  endmethod.

  method handle_on_f4.
**    perform handle_on_f4 using e_fieldname
**                               e_fieldvalue
**                               es_row_no
**                               er_event_data
**                               e_display
**                               sender.
  endmethod.

endclass.
