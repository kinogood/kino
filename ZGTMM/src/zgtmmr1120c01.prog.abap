*&---------------------------------------------------------------------*
*& Include          ZGTMMR1120C01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       CLASS LCL_EVT_RECEIVER_900_T DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_900_T DEFINITION FINAL.

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

    METHODS HANDLE_ON_F4
      FOR EVENT ONF4 OF CL_GUI_ALV_GRID
      IMPORTING E_FIELDNAME
                E_FIELDVALUE
                ES_ROW_NO
                ER_EVENT_DATA
                ET_BAD_CELLS
                E_DISPLAY.

ENDCLASS. "LCL_EVT_RECEIVER_900_T DEFINITION

*&---------------------------------------------------------------------*
*&      CLASS LCL_EVT_RECEIVER_900_T IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_900_T IMPLEMENTATION.

  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM F_DOUBLE_CLICK_900_T USING ES_ROW_NO-ROW_ID.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  METHOD HANDLE_TOOLBAR.
    PERFORM F_TOOLBAR_900_T USING E_OBJECT.
  ENDMETHOD.                    "HANDLE_TOOLBAR

  METHOD HANDLE_USER_COMMAND.
    PERFORM F_USER_COMMAND_900_T USING E_UCOMM.

  ENDMETHOD.                    "HANDLE_USER_COMMAND

  METHOD HANDLE_DATA_CHANGED_FINISHED.

    PERFORM F_DATA_CHANGED_FIN_900_T USING E_MODIFIED
                                        ET_GOOD_CELLS.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED

  METHOD HANDLE_ON_F4.

    PERFORM F_ON_F4_900_T USING E_FIELDNAME
                        E_FIELDVALUE
                        ES_ROW_NO
                        ER_EVENT_DATA
                        ET_BAD_CELLS
                        E_DISPLAY.

  ENDMETHOD.                    "HANDLE_ON_F4

ENDCLASS. "LCL_EVT_RECEIVER_900_T IMPLEMENTATION


*----------------------------------------------------------------------*
*       CLASS LCL_EVT_RECEIVER_900_B DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_900_B DEFINITION FINAL.

  PUBLIC SECTION.
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

ENDCLASS. "LCL_EVT_RECEIVER_900_B DEFINITION

*&---------------------------------------------------------------------*
*&      CLASS LCL_EVT_RECEIVER_900_B IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_900_B IMPLEMENTATION.

  METHOD HANDLE_TOOLBAR.
    PERFORM F_TOOLBAR_900_T USING E_OBJECT.
  ENDMETHOD.                    "HANDLE_TOOLBAR

  METHOD HANDLE_USER_COMMAND.
    PERFORM F_USER_COMMAND_900_B USING E_UCOMM.

  ENDMETHOD.                    "HANDLE_USER_COMMAND

  METHOD HANDLE_DATA_CHANGED_FINISHED.

    PERFORM F_DATA_CHANGED_FIN_900_B USING E_MODIFIED
                                        ET_GOOD_CELLS.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED


ENDCLASS. "LCL_EVT_RECEIVER_900_B IMPLEMENTATION


*----------------------------------------------------------------------*
*       CLASS LCL_EVT_RECEIVER_100_T DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_100_T DEFINITION FINAL.

  PUBLIC SECTION.
    METHODS HANDLE_DATA_CHANGED
      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING ER_DATA_CHANGED
                E_ONF4
                E_ONF4_BEFORE
                E_ONF4_AFTER
                E_UCOMM.

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

  METHOD HANDLE_DATA_CHANGED.
    PERFORM F_DATA_CHANGED_100_T USING ER_DATA_CHANGED
                               E_ONF4_AFTER.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED

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
*       CLASS LCL_EVT_RECEIVER_100_B DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_100_B DEFINITION FINAL.

  PUBLIC SECTION.
    METHODS HANDLE_TOOLBAR
      FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT
                E_INTERACTIVE
                SENDER.

    METHODS HANDLE_USER_COMMAND
      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM.

ENDCLASS. "LCL_EVT_RECEIVER_100_B DEFINITION

*&---------------------------------------------------------------------*
*&      CLASS LCL_EVT_RECEIVER_100_B IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_100_B IMPLEMENTATION.

  METHOD HANDLE_TOOLBAR.
    PERFORM F_TOOLBAR_100_B USING E_OBJECT.
  ENDMETHOD.                    "HANDLE_TOOLBAR

  METHOD HANDLE_USER_COMMAND.
    PERFORM F_USER_COMMAND_100_B USING E_UCOMM.

  ENDMETHOD.                    "HANDLE_USER_COMMAND

ENDCLASS. "LCL_EVT_RECEIVER_100_B IMPLEMENTATION



*----------------------------------------------------------------------*
*       CLASS LCL_EVT_RECEIVER_200 DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_200 DEFINITION FINAL.

  PUBLIC SECTION.
    METHODS HANDLE_DATA_CHANGED_FINISHED
      FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED
                ET_GOOD_CELLS.


ENDCLASS. "LCL_EVT_RECEIVER_200 DEFINITION

*&---------------------------------------------------------------------*
*&      CLASS LCL_EVT_RECEIVER_200 IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_200 IMPLEMENTATION.

  METHOD HANDLE_DATA_CHANGED_FINISHED.

    PERFORM F_DATA_CHANGED_FIN_200 USING E_MODIFIED
                                        ET_GOOD_CELLS.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED


ENDCLASS. "LCL_EVT_RECEIVER_200 IMPLEMENTATION


DATA:
  GCL_EVENT_100_T TYPE REF TO LCL_EVT_RECEIVER_100_T,
  GCL_EVENT_100_B TYPE REF TO LCL_EVT_RECEIVER_100_B,
  GCL_EVENT_200   TYPE REF TO LCL_EVT_RECEIVER_200,
  GCL_EVENT_900_T TYPE REF TO LCL_EVT_RECEIVER_900_T,
  GCL_EVENT_900_B TYPE REF TO LCL_EVT_RECEIVER_900_B.
