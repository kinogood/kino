*&---------------------------------------------------------------------*
*& Include          ZGTPPR2180C01
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

    METHODS HANDLE_DATA_CHANGED
      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING SENDER
                ER_DATA_CHANGED
                E_ONF4
                E_UCOMM.

    METHODS HANDLE_HOTSPOT
      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING SENDER
                E_ROW_ID
                E_COLUMN_ID.

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

*-- Hotspot Click
  METHOD HANDLE_HOTSPOT.
    PERFORM HOTSPOT_CLICK USING SENDER
                               E_ROW_ID
                               E_COLUMN_ID.
  ENDMETHOD. " double_click

*-- Data change
  METHOD HANDLE_DATA_CHANGED.
    PERFORM DATA_CHANGED USING SENDER
                               ER_DATA_CHANGED
                               E_ONF4
                               E_UCOMM.

  ENDMETHOD. " data_changed

ENDCLASS. "lcl_event_handler IMPLEMENTATION
