*&---------------------------------------------------------------------*
*& Include          ZGTPPR2060C01
*&---------------------------------------------------------------------*
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

    METHODS HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING SENDER
                E_ROW
                E_COLUMN.

    METHODS HANDLE_TOP_OF_PAGE
      FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID
      IMPORTING SENDER
                E_DYNDOC_ID.

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

*-- Data change
  METHOD HANDLE_DATA_CHANGED.
    PERFORM DATA_CHANGED USING SENDER
                               ER_DATA_CHANGED
                               E_ONF4
                               E_UCOMM.

  ENDMETHOD. " data_changed

*-- Double Click
  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM DOUBLE_CLICK USING SENDER
                               E_ROW
                               E_COLUMN.
  ENDMETHOD. " double_click

  METHOD HANDLE_TOP_OF_PAGE.
    PERFORM ALV_TOP_OF_PAGE USING SENDER E_DYNDOC_ID.
  ENDMETHOD.

ENDCLASS. "lcl_event_handler IMPLEMENTATION
