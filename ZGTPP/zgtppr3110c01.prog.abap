*&---------------------------------------------------------------------*
*& Include          ZGTPPR3110C01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* CLASS LCL_EVENT_HANDLER DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.
  PUBLIC SECTION.
    METHODS HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING SENDER
                E_ROW
                E_COLUMN.

    METHODS HANDLE_DATA_CHANGED
      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING SENDER
                ER_DATA_CHANGED
                E_ONF4
                E_UCOMM.

ENDCLASS. "(LCL_EVENT_RECEIVER DEFINITION)
*----------------------------------------------------------------------*
* CLASS LCL_EVENT_HANDLER IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

*-- Double Click
  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM DOUBLE_CLICK USING SENDER
                               E_ROW
                               E_COLUMN.
  ENDMETHOD. " double_click

*-- Data change
  METHOD HANDLE_DATA_CHANGED.
    PERFORM DATA_CHANGED USING SENDER
                               ER_DATA_CHANGED
                               E_ONF4
                               E_UCOMM.

  ENDMETHOD. " data_changed

ENDCLASS. "lcl_event_handler IMPLEMENTATION
