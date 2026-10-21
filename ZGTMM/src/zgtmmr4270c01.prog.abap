*&---------------------------------------------------------------------*
*& Include          ZGTMMR4270C01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       CLASS LCL_EVT_RECEIVER_100_T DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_100_T DEFINITION FINAL.

  PUBLIC SECTION.
    METHODS HANDLE_HOTSPOT_CLICK
      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID
                E_COLUMN_ID
                ES_ROW_NO
                SENDER.

    METHODS HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW
                E_COLUMN
                ES_ROW_NO.

    METHODS HANDLE_TOOLBAR
      FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT
                E_INTERACTIVE
                SENDER.

    METHODS HANDLE_USER_COMMAND
      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM.

    METHODS HANDLE_DATA_CHANGED_FINISHED
      FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED
                ET_GOOD_CELLS.

ENDCLASS. "LCL_EVT_RECEIVER_100_T DEFINITION

*&---------------------------------------------------------------------*
*&      CLASS LCL_EVT_RECEIVER_100_T IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_100_T IMPLEMENTATION.

  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM F_HOTSPOT_CLICK_100_T USING ES_ROW_NO-ROW_ID
                                E_COLUMN_ID
                                SENDER.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM F_DOUBLE_CLICK_100_T USING ES_ROW_NO-ROW_ID.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  METHOD HANDLE_TOOLBAR.
    PERFORM F_TOOLBAR_100_T USING E_OBJECT.
  ENDMETHOD.                    "HANDLE_TOOLBAR

  METHOD HANDLE_USER_COMMAND.
    PERFORM F_USER_COMMAND_100_T USING E_UCOMM.

  ENDMETHOD.                    "HANDLE_USER_COMMAND

  METHOD HANDLE_DATA_CHANGED_FINISHED.

    PERFORM F_DATA_CHANGED_FIN_100_T USING E_MODIFIED
                                        ET_GOOD_CELLS.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED


ENDCLASS. "LCL_EVT_RECEIVER_100_T IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS LCL_EVT_RECEIVER_100_M DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_100_M DEFINITION FINAL.

  PUBLIC SECTION.
    METHODS HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW
                E_COLUMN
                ES_ROW_NO.

    METHODS HANDLE_TOOLBAR
      FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT
                E_INTERACTIVE
                SENDER.

    METHODS HANDLE_USER_COMMAND
      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM.

    METHODS HANDLE_DATA_CHANGED_FINISHED
      FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED
                ET_GOOD_CELLS.

ENDCLASS. "LCL_EVT_RECEIVER_100_M DEFINITION

*&---------------------------------------------------------------------*
*&      CLASS LCL_EVT_RECEIVER_100_M IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_100_M IMPLEMENTATION.

  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM F_DOUBLE_CLICK_100_M USING ES_ROW_NO-ROW_ID.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  METHOD HANDLE_TOOLBAR.
    PERFORM F_TOOLBAR_100_M USING E_OBJECT.
  ENDMETHOD.                    "HANDLE_TOOLBAR

  METHOD HANDLE_USER_COMMAND.
    PERFORM F_USER_COMMAND_100_M USING E_UCOMM.

  ENDMETHOD.                    "HANDLE_USER_COMMAND

  METHOD HANDLE_DATA_CHANGED_FINISHED.

    PERFORM F_DATA_CHANGED_FIN_100_M USING E_MODIFIED
                                        ET_GOOD_CELLS.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED


ENDCLASS. "LCL_EVT_RECEIVER_100_M IMPLEMENTATION


*----------------------------------------------------------------------*
*       CLASS LCL_EVT_RECEIVER_100_B DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_100_B DEFINITION FINAL.

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

ENDCLASS. "LCL_EVT_RECEIVER_100_B DEFINITION

*&---------------------------------------------------------------------*
*&      CLASS LCL_EVT_RECEIVER_100_B IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_100_B IMPLEMENTATION.

  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM F_HOTSPOT_CLICK_100_B USING ES_ROW_NO-ROW_ID
                                E_COLUMN_ID
                                SENDER.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  METHOD HANDLE_DATA_CHANGED_FINISHED.

    PERFORM F_DATA_CHANGED_FIN_100_B USING E_MODIFIED
                                        ET_GOOD_CELLS.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED


ENDCLASS. "LCL_EVT_RECEIVER_100_B IMPLEMENTATION




*----------------------------------------------------------------------*
*       CLASS LCL_EVT_RECEIVER_200_M DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_200_M DEFINITION FINAL.

  PUBLIC SECTION.
    METHODS HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW
                E_COLUMN
                ES_ROW_NO.

ENDCLASS. "LCL_EVT_RECEIVER_200_M DEFINITION

*&---------------------------------------------------------------------*
*&      CLASS LCL_EVT_RECEIVER_200_M IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_200_M IMPLEMENTATION.

  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM F_DOUBLE_CLICK_200_M USING ES_ROW_NO-ROW_ID.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

ENDCLASS. "LCL_EVT_RECEIVER_200_M IMPLEMENTATION


DATA:
  GCL_EVENT_100_T TYPE REF TO LCL_EVT_RECEIVER_100_T,
  GCL_EVENT_100_M TYPE REF TO LCL_EVT_RECEIVER_100_M,
  GCL_EVENT_100_B TYPE REF TO LCL_EVT_RECEIVER_100_B,
  GCL_EVENT_200_M TYPE REF TO LCL_EVT_RECEIVER_200_M.
