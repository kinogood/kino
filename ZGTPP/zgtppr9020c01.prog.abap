*&---------------------------------------------------------------------*
*& Include          ZGTPPR9020C01
*&---------------------------------------------------------------------*
*& CLASS Reference 정의
class: lcl_event_handler      definition deferred,
       lcl_alv_grid           definition deferred.

*& ALV Global Field

data : alv_variant   like disvariant,
       alv_repid     like sy-repid.

* ALV Attribute
data : gt_exclude    type ui_functions,    "Tool Bar Button저장
       gs_fieldcat   type lvc_s_fcat,      "필드 속성 Set
       gt_fieldcat   type lvc_t_fcat,      "필드 속성 저장
       gt_f4         type lvc_t_f4,
       gs_f4         type lvc_s_f4,                         "F4 필드
       gs_layocat    type lvc_s_layo,      "Grid 속성 저장(Display)
       gt_sort       type lvc_t_sort,
       gs_sort       type lvc_s_sort,

       gs_scroll     type lvc_s_stbl.

data : gv_repid      like sy-repid,
       gv_title      type lvc_title,
       gv_container  type scrfname value 'CC_CONTAINER_0100'.

data : gt_scol       type lvc_t_scol with header line,
       gs_colo       type lvc_s_colo.

*& Drop-Down List Box List.
data : gt_dropdown   type lvc_t_drop,
       gs_dropdown   type lvc_s_drop.

data : gcl_custom_container   type ref to cl_gui_custom_container,
       gcl_grid           type ref to lcl_alv_grid,
       gcl_event_handler  type ref to lcl_event_handler.


************************************************************************
* LOCAL CLASSES: Definition
************************************************************************
class lcl_alv_grid definition inheriting from cl_gui_alv_grid.

  public section.
    class-data f_alv  type c.
    methods: set_optimize_all_cols,
             set_cursor importing row  type i
                                  col  type i,
             set_fixed_column,
             set_row_resize.

endclass.                    "LCL_ALV_GRID DEFINITION
*---------------------------------------------------------------------*
*       CLASS LCL_ALV_GRID IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
class lcl_alv_grid implementation.

  method set_optimize_all_cols.
    call method me->optimize_all_cols
      exporting
        include_header = 1.
  endmethod.                    "SET_OPTIMIZE_ALL_COLS

  method set_cursor.
    call method me->set_current_cell_base
      exporting
        row = row
        col = col.
  endmethod.                    "SET_CURSOR

  method set_fixed_column.
    call method me->set_fixed_cols
      exporting
        cols = 5.
  endmethod.                    "SET_FIXED_COLUMN

  method set_row_resize.
    call method me->set_resize_rows
      exporting
        enable = 1.
  endmethod.                    "SET_ROW_RESIZE

endclass.                    "LCL_ALV_GRID IMPLEMENTATION
*---------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER DEFINITION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
class lcl_event_handler definition.
  public section.
    methods : handle_toolbar
                 for event toolbar of cl_gui_alv_grid
                 importing e_object e_interactive.

    methods : handle_user_command
                 for event user_command of cl_gui_alv_grid
                 importing e_ucomm.

    methods : handle_after_user_command
                 for event after_user_command of cl_gui_alv_grid
                 importing  e_ucomm .

    methods : handle_data_changed
                 for event data_changed of cl_gui_alv_grid
                 importing er_data_changed e_onf4.

    methods : handle_data_changed_finished
                 for event data_changed_finished of cl_gui_alv_grid
                 importing e_modified
                           et_good_cells.

    methods : handle_hotspot_click
                 for event hotspot_click of cl_gui_alv_grid
                 importing e_row_id
                           e_column_id.

    methods : handle_double_click
                 for event double_click of cl_gui_alv_grid
                 importing e_row
                           e_column.

    methods : handle_button_click
                 for event button_click of cl_gui_alv_grid
                 importing es_col_id
                           es_row_no.

    methods : handle_onf4
                 for event onf4 of cl_gui_alv_grid
                 importing e_fieldname
                           e_fieldvalue
                           es_row_no
                           er_event_data
                           et_bad_cells
                           e_display.

    methods : handle_top_of_page
                 for event print_top_of_page of cl_gui_alv_grid.

endclass.  "(LCL_EVENT_RECEIVER DEFINITION)

****************************************************************
* LOCAL CLASSES: Implementation
****************************************************************
class lcl_event_handler implementation.

*& ToolBar 버튼생성
  method handle_toolbar.
*    perform toolbar_proc  using e_object e_interactive.
  endmethod.                    "handle_toolbar

*& ToolBar에 생성된 버튼(Function)들에 대해서 처리
  method handle_user_command.
*    perform user_command_proc using e_ucomm.
  endmethod.                    "handle_user_command

*& Event 처리후
  method handle_after_user_command.
*    perform after_user_command using e_ucomm.
  endmethod.                    "HANDLE_AFTER_USER_COMMAND

*& Data change할때
  method handle_data_changed.
*    perform data_changed  using er_data_changed
*                                e_onf4.
  endmethod.                    "handle_data_changed

*& Data change한 후
  method handle_data_changed_finished.
*    perform data_changed_finished using e_modified
*                                        et_good_cells.
  endmethod.                    "HANDLE_DATA_CHANGED_FINISHED

*& Hotspot click
  method handle_hotspot_click.
*    perform hotspot_click using e_row_id e_column_id.
  endmethod.                    "handle_hotspot_click

*& Double Click
  method handle_double_click.
*    perform double_click  using e_row e_column.
  endmethod.    "handle_double_click

*& Button Click
  method handle_button_click.
*    perform button_click  using es_col_id es_row_no.
  endmethod.    "handle_button_click

*& F4 도움말 처리
  method handle_onf4.
*    perform  onf4_proc using e_fieldname   e_fieldvalue
*                             es_row_no     er_event_data
*                             et_bad_cells  e_display.
  endmethod.                    "handle_on_entered

*& TOP_OF_PAGE
  method handle_top_of_page.
*    perform top_of_page using sy-title
*                              sy-linsz.
  endmethod.                    "handle_top_of_page
endclass. "LCL_EVENT_RECEIVER IMPLEMENTATION
