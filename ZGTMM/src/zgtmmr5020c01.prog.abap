*&---------------------------------------------------------------------*
*& Include          ZGTMMR5020C01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       CLASS LCL_EVT_RECEIVER DEFINITION
*----------------------------------------------------------------------*
CLASS : LCL_EVT_RECEIVER DEFINITION DEFERRED.
DATA : GCL_EVENT      TYPE REF TO LCL_EVT_RECEIVER.

CLASS LCL_EVT_RECEIVER DEFINITION FINAL.

  PUBLIC SECTION.

    METHODS HANDLE_TOOLBAR
      FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT
                E_INTERACTIVE
                SENDER.

    METHODS HANDLE_USER_COMMAND
      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM.

    METHODS HANDLE_DATA_CHANGED
      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING ER_DATA_CHANGED
                       E_ONF4_AFTER
                       SENDER.

    METHODS HANDLE_DATA_CHANGED_FINISHED
      FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED
                ET_GOOD_CELLS
                SENDER.

    METHODS HANDLE_HOTSPOT_CLICK
      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID
                E_COLUMN_ID
                SENDER.

    DATA : MV_ERROR_IN_DATA TYPE C.

ENDCLASS.
*&---------------------------------------------------------------------*
*&      CLASS LCL_EVT_RECEIVER IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER IMPLEMENTATION.
  METHOD HANDLE_TOOLBAR.
*    PERFORM TOOLBAR USING E_OBJECT
*                                             SENDER.
  ENDMETHOD.                    "HANDLE_TOOLBAR

  METHOD HANDLE_USER_COMMAND.
*    PERFORM USER_COMMAND USING E_UCOMM.

  ENDMETHOD.                    "HANDLE_USER_COMMAND

  METHOD HANDLE_DATA_CHANGED.
*    PERFORM DATA_CHANGED USING ER_DATA_CHANGED
*                                                       E_ONF4_AFTER
*                                                       SENDER.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED

  METHOD HANDLE_DATA_CHANGED_FINISHED.

*    PERFORM DATA_CHANGED_FINISHED USING E_MODIFIED
*                                        ET_GOOD_CELLS
*                                        SENDER.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED

  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM HOTSPOT_CLICK USING E_ROW_ID
                                E_COLUMN_ID
                                SENDER.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  ENDCLASS. "LCL_RECIVR IMPLEMENTATION
