*&---------------------------------------------------------------------*
*& Include          ZGTPPR4080C01
*&---------------------------------------------------------------------*
* CLASS zcl_event_receiver DEFINITION
CLASS ZCL_EVENT_RECIEVER DEFINITION.

  PUBLIC SECTION.

    METHODS HDL_BUTTON_CLICK
      FOR EVENT BUTTON_CLICK OF CL_GUI_ALV_GRID
      IMPORTING SENDER ES_COL_ID ES_ROW_NO.

ENDCLASS.                    "ZCL_EVENT_RECEIVER DEFINITION
* CLASS zcl_event_receiver IMPLEMENTATION
CLASS ZCL_EVENT_RECIEVER IMPLEMENTATION.

  METHOD HDL_BUTTON_CLICK.
    PERFORM HDL_BUTTON_CLICK USING SENDER
                                   ES_COL_ID ES_ROW_NO.
  ENDMETHOD.                    "HDL_BUTTON_CLICK

ENDCLASS.                    "ZCL_EVENT_RECEIVER IMPLEMENTATION
