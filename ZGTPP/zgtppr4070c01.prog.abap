*&---------------------------------------------------------------------*
*& Include          ZGTPPR4070C01
*&---------------------------------------------------------------------*
* CLASS zcl_event_receiver DEFINITION
CLASS ZCL_EVENT_RECIEVER DEFINITION.

  PUBLIC SECTION.

    METHODS HDL_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING SENDER E_ROW E_COLUMN.

ENDCLASS.                    "ZCL_EVENT_RECEIVER DEFINITION
* CLASS zcl_event_receiver IMPLEMENTATION
CLASS ZCL_EVENT_RECIEVER IMPLEMENTATION.

  METHOD HDL_DOUBLE_CLICK.
    PERFORM HDL_DOUBLE_CLICK USING SENDER
                                   E_ROW
                                   E_COLUMN.
  ENDMETHOD.                    "HDL_DOUBLE_CLICK

ENDCLASS.                    "ZCL_EVENT_RECEIVER IMPLEMENTATION
