*&---------------------------------------------------------------------*
*& Include          ZGTMMR2011C01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS LCL_EVT_RECEIVER_100 DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_100 DEFINITION FINAL.

  PUBLIC SECTION.
    METHODS HANDLE_HOTSPOT_CLICK
      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID
                E_COLUMN_ID
                ES_ROW_NO
                SENDER.

ENDCLASS. "LCL_EVT_RECEIVER_100 DEFINITION

*&---------------------------------------------------------------------*
*&      CLASS LCL_EVT_RECEIVER_100 IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_100 IMPLEMENTATION.

  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM F_HOTSPOT_CLICK_100 USING ES_ROW_NO-ROW_ID
                                E_COLUMN_ID
                                SENDER.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

ENDCLASS. "LCL_EVT_RECEIVER_100 IMPLEMENTATION

DATA GO_EVENT_100 TYPE REF TO LCL_EVT_RECEIVER_100.
