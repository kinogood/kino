*&---------------------------------------------------------------------*
*& Include          ZGTPPR2290C01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* CLASS LCL_EVENT_HANDLER DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.

  PUBLIC SECTION.
    METHODS handle_toolbar
      FOR EVENT toolbar        OF cl_gui_alv_grid
      IMPORTING sender e_object e_interactive.

    METHODS handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING sender e_ucomm.

    METHODS handle_hotspot_click
      FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING sender e_row_id e_column_id es_row_no.

    METHODS handle_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING sender e_row e_column.

    METHODS handle_data_changed
      FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed e_onf4.

    METHODS handle_onf4
      FOR EVENT onf4 OF cl_gui_alv_grid
      IMPORTING e_fieldname e_fieldvalue es_row_no er_event_data et_bad_cells e_display.

ENDCLASS. "(LCL_EVENT_RECEIVER DEFINITION)
*----------------------------------------------------------------------*
* CLASS LCL_EVENT_HANDLER IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.
*-- ToolBar
  METHOD handle_toolbar.
    PERFORM toolbar_pros USING sender e_object e_interactive.
  ENDMETHOD. " toolbar
*-- user_command
  METHOD handle_user_command.
    PERFORM user_command_pros USING sender e_ucomm.
  ENDMETHOD. " user_command

  METHOD handle_hotspot_click.
    PERFORM hotspot_click USING sender e_row_id e_column_id es_row_no.
  ENDMETHOD. " user_command

*-- Double Click
  METHOD handle_double_click.
    PERFORM double_click USING sender e_row e_column.
  ENDMETHOD. " double_click
*& Data change
  METHOD handle_data_changed.
    PERFORM data_changed  USING er_data_changed e_onf4.
  ENDMETHOD.                    "handle_data_changed
*& F4 도움말 처리
  METHOD handle_onf4.
    PERFORM  onf4_proc USING e_fieldname   e_fieldvalue
                             es_row_no     er_event_data
                             et_bad_cells  e_display.

  ENDMETHOD.                    "handle_on_entered
ENDCLASS. "lcl_event_handler IMPLEMENTATION

CLASS lcx_exception DEFINITION INHERITING FROM cx_static_check.
  PUBLIC SECTION.
    INTERFACES if_t100_dyn_msg.
ENDCLASS.
