*&---------------------------------------------------------------------*
*& Include          ZGTMMR9010C01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS LCL_EVT_RECEIVER DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER DEFINITION FINAL.

  PUBLIC SECTION.
    METHODS HANDLE_HOTSPOT_CLICK
      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID
                E_COLUMN_ID
                ES_ROW_NO
                SENDER.

ENDCLASS. "LCL_EVT_RECEIVER DEFINITION

*&---------------------------------------------------------------------*
*&      CLASS LCL_EVT_RECEIVER IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER IMPLEMENTATION.

  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM F_HOTSPOT_CLICK USING ES_ROW_NO-ROW_ID
                                E_COLUMN_ID
                                SENDER.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

ENDCLASS. "LCL_RECIVR IMPLEMENTATION

DATA GO_EVENT TYPE REF TO LCL_EVT_RECEIVER.
