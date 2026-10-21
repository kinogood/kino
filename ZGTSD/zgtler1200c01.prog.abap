
*&---------------------------------------------------------------------*
*&  Include           ZLER1200_C01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER DEFINITION
*----------------------------------------------------------------------*
class lcl_event_handler definition.

  public section.
    methods : handle_toolbar_1
                 for event toolbar of cl_gui_alv_grid
                 importing e_object e_interactive sender.

    methods : handle_toolbar_2
                 for event toolbar of cl_gui_alv_grid
                 importing e_object e_interactive sender.

    methods : handle_toolbar_3
                 for event toolbar of cl_gui_alv_grid
                 importing e_object e_interactive sender.

    methods : handle_toolbar_4
                 for event toolbar of cl_gui_alv_grid
                 importing e_object e_interactive sender.

    methods : handle_user_command
                 for event user_command of cl_gui_alv_grid
                 importing e_ucomm sender.

    methods : handle_after_user_command
                 for event after_user_command of cl_gui_alv_grid
                 importing e_ucomm .

    methods : handle_data_changed
                 for event data_changed of cl_gui_alv_grid
                 importing er_data_changed e_onf4 e_ucomm SENDER.

    methods : handle_data_changed_finished
                 for event data_changed_finished of cl_gui_alv_grid
                 importing e_modified
                           et_good_cells sender.

    methods : handle_hotspot_click
                 for event hotspot_click of cl_gui_alv_grid
                 importing e_row_id
                           e_column_id.

    methods : handle_double_click1
                 for event double_click of cl_gui_alv_grid
                 importing e_row
                           e_column
                           SENDER.

    methods : handle_onf4 for event onf4 of cl_gui_alv_grid
                  importing sender
                            e_fieldname
                            e_fieldvalue
                            es_row_no
                            er_event_data
                            et_bad_cells
                            e_display.

    METHODS : handle_button_click
                 FOR EVENT button_click OF cl_gui_alv_grid
                 IMPORTING es_col_id
                           es_row_no.

    METHODS:  HANDLE_TOP_OF_PAGE
                 FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID
                 IMPORTING E_DYNDOC_ID sender.

endclass.  "(LCL_EVENT_RECEIVER DEFINITION)

*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER IMPLEMENTATION
*----------------------------------------------------------------------*
class lcl_event_handler implementation.

*-- ToolBar 버튼생성
  method handle_toolbar_1.
    perform toolbar_pros  using e_object e_interactive sender.
  endmethod.                    "handle_toolbar

  method handle_toolbar_2.
    perform toolbar_pros  using e_object e_interactive sender.
  endmethod.                    "handle_toolbar

  method handle_toolbar_3.
    perform toolbar_pros  using e_object e_interactive sender.
  endmethod.                    "handle_toolbar

  method handle_toolbar_4.
    perform toolbar_pros  using e_object e_interactive sender.
  endmethod.                    "handle_toolbar

*-- ToolBar에 생성된 버튼(Function)들에 대해서 처리
  method handle_user_command.
    perform user_command_pros using e_ucomm sender.
  endmethod.                    "handle_user_command

*-- Event 처리후
  method handle_after_user_command.
*    perform after_user_command using e_ucomm.
  endmethod.                    "HANDLE_AFTER_USER_COMMAND

*-- Data change할때
  method handle_data_changed.
    perform data_changed  using er_data_changed e_onf4 e_ucomm SENDER.
  endmethod.                    "handle_data_changed

*-- Data change한 후
  method handle_data_changed_finished.
    perform data_changed_finished using e_modified
                                        et_good_cells SENDER.
  endmethod.                    "HANDLE_DATA_CHANGED_FINISHED

*-- Hotspot click
  method handle_hotspot_click.
    perform hotspot_click using e_row_id e_column_id.
  endmethod.                    "handle_hotspot_click

*-- Double Click
  method handle_double_click1.
    perform double_click  using e_row e_column sender.
  endmethod.    "handle_double_click1

*-- On help f4 - Search Help
  method handle_onf4.
*    perform on_f4 using sender
*                        e_fieldname
*                        e_fieldvalue
*                        es_row_no
*                        er_event_data
*                        et_bad_cells
*                        e_display.
  endmethod.                    "HANDLE_ONF4

  METHOD HANDLE_TOP_OF_PAGE.
    PERFORM event_top_of_page USING e_dyndoc_id sender.
  ENDMETHOD.                   "top_of_page

  method HANDLE_BUTTON_CLICK.
    perform BUTTON_CLICK using ES_COL_ID ES_ROW_NO.

  endmethod.                    "handle_button_click

endclass. "LCL_EVENT_RECEIVER IMPLEMENTATION
