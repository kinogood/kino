*&---------------------------------------------------------------------*
*& Include          ZGTPPR2130C01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* CLASS LCL_EVENT_HANDLER DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.
  PUBLIC SECTION.
    METHODS HANDLE_TOOLBAR
      FOR EVENT TOOLBAR        OF CL_GUI_ALV_GRID
      IMPORTING SENDER
                E_OBJECT
                E_INTERACTIVE.

    METHODS HANDLE_USER_COMMAND
      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING SENDER
                E_UCOMM.

    METHODS HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING SENDER
                E_ROW
                E_COLUMN.

ENDCLASS. "(LCL_EVENT_RECEIVER DEFINITION)
*----------------------------------------------------------------------*
* CLASS LCL_EVENT_HANDLER IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

*-- ToolBar
  METHOD HANDLE_TOOLBAR.
    PERFORM TOOLBAR_PROS USING SENDER
                               E_OBJECT
                               E_INTERACTIVE.
  ENDMETHOD. " toolbar
*-- user_command
  METHOD HANDLE_USER_COMMAND.
    PERFORM USER_COMMAND_PROS USING SENDER
                                    E_UCOMM.
  ENDMETHOD. " user_command

*-- Double Click
  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM DOUBLE_CLICK USING SENDER
                               E_ROW
                               E_COLUMN.
  ENDMETHOD. " double_click

ENDCLASS. "lcl_event_handler IMPLEMENTATION
