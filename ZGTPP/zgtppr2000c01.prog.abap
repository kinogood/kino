*&---------------------------------------------------------------------*
*& Include          ZGTPPR2000C01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* CLASS LCL_EVENT_HANDLER DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS handle_toolbar
      FOR EVENT toolbar        OF cl_gui_alv_grid
      IMPORTING sender
                e_object
                e_interactive.

    METHODS handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING sender
                e_ucomm.

    METHODS handle_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING sender
                e_row
                e_column.

ENDCLASS. "(LCL_EVENT_RECEIVER DEFINITION)
*----------------------------------------------------------------------*
* CLASS LCL_EVENT_HANDLER IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

*-- ToolBar
  METHOD handle_toolbar.
    PERFORM toolbar_pros USING sender
                               e_object
                               e_interactive.
  ENDMETHOD. " toolbar
*-- user_command
  METHOD handle_user_command.
    PERFORM user_command_pros USING sender
                                    e_ucomm.
  ENDMETHOD. " user_command

*-- Double Click
  METHOD handle_double_click.
    PERFORM double_click USING sender
                               e_row
                               e_column.
  ENDMETHOD. " double_click

ENDCLASS. "lcl_event_handler IMPLEMENTATION
