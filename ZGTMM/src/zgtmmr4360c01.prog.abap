*&---------------------------------------------------------------------*
*& Include          ZGTMMR4320C01
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

    METHODS HANDLE_DATA_CHANGED_FINISHED
      FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED
                ET_GOOD_CELLS.

    METHODS HANDLE_DATA_CHANGED
      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING ER_DATA_CHANGED.

    METHODS HANDLE_ON_F4
      FOR EVENT ONF4 OF CL_GUI_ALV_GRID
      IMPORTING E_FIELDNAME
                E_FIELDVALUE
                ES_ROW_NO
                ER_EVENT_DATA
                ET_BAD_CELLS
                E_DISPLAY.

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

  METHOD HANDLE_DATA_CHANGED_FINISHED.
    PERFORM F_DATA_CHANGED_FIN USING E_MODIFIED
                                        ET_GOOD_CELLS.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED

  METHOD HANDLE_DATA_CHANGED.
    PERFORM F_DATA_CHANGED USING ER_DATA_CHANGED.

  ENDMETHOD.

  METHOD HANDLE_ON_F4.
    PERFORM F_ON_F4 USING E_FIELDNAME
                        E_FIELDVALUE
                        ES_ROW_NO
                        ER_EVENT_DATA
                        ET_BAD_CELLS
                        E_DISPLAY.

  ENDMETHOD.


ENDCLASS. "LCL_RECIVR IMPLEMENTATION

DATA GO_EVENT TYPE REF TO LCL_EVT_RECEIVER.
