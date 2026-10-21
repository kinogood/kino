*&---------------------------------------------------------------------*
*& Include          ZGTMMR4381C01
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

*    METHODS HANDLE_TOOLBAR
*      FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
*      IMPORTING E_OBJECT
*                E_INTERACTIVE
*                SENDER.
*
*    METHODS HANDLE_USER_COMMAND
*      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
*      IMPORTING E_UCOMM.

    METHODS HANDLE_DATA_CHANGED_FINISHED
      FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED
                ET_GOOD_CELLS.

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

*  METHOD HANDLE_TOOLBAR.
*    PERFORM F_TOOLBAR_100 USING E_OBJECT.
*  ENDMETHOD.                    "HANDLE_TOOLBAR
*
*  METHOD HANDLE_USER_COMMAND.
*    PERFORM F_USER_COMMAND_100 USING E_UCOMM.
*
*  ENDMETHOD.                    "HANDLE_USER_COMMAND

  METHOD HANDLE_DATA_CHANGED_FINISHED.

    PERFORM F_DATA_CHANGED_FIN_100 USING E_MODIFIED
                                        ET_GOOD_CELLS.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED


ENDCLASS. "LCL_EVT_RECEIVER_100 IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS LCL_EVT_RECEIVER_200 DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_200 DEFINITION FINAL.

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

ENDCLASS. "LCL_EVT_RECEIVER_200 DEFINITION

*&---------------------------------------------------------------------*
*&      CLASS LCL_EVT_RECEIVER_200 IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_200 IMPLEMENTATION.

  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM F_HOTSPOT_CLICK_200 USING ES_ROW_NO-ROW_ID
                                E_COLUMN_ID
                                SENDER.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  METHOD HANDLE_DATA_CHANGED_FINISHED.

    PERFORM F_DATA_CHANGED_FIN_200 USING E_MODIFIED
                                        ET_GOOD_CELLS.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED
ENDCLASS. "LCL_EVT_RECEIVER_100 IMPLEMENTATION

DATA:
  GCL_EVENT_100 TYPE REF TO LCL_EVT_RECEIVER_100,
  GCL_EVENT_200 TYPE REF TO LCL_EVT_RECEIVER_200.
