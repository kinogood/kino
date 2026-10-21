*&---------------------------------------------------------------------*
*& Include          ZGTMMR1040C01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS LCL_EVT_RECEIVER_100 DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_100 DEFINITION FINAL.

  PUBLIC SECTION.
    METHODS HANDLE_TOOLBAR
      FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT
                E_INTERACTIVE
                SENDER.

    METHODS HANDLE_USER_COMMAND
      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM.

*    METHODS HANDLE_DATA_CHANGED
*      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
*      IMPORTING ER_DATA_CHANGED
*                E_ONF4
*                E_ONF4_BEFORE
*                E_ONF4_AFTER
*                E_UCOMM.

    METHODS HANDLE_DATA_CHANGED_FINISHED
      FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED
                ET_GOOD_CELLS.

ENDCLASS.
*&---------------------------------------------------------------------*
*&      CLASS LCL_EVT_RECEIVER_100 IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_100 IMPLEMENTATION.

  METHOD HANDLE_TOOLBAR.
    PERFORM F_TOOLBAR_100 USING E_OBJECT
                                             SENDER.
  ENDMETHOD.                    "HANDLE_TOOLBAR

  METHOD HANDLE_USER_COMMAND.
    PERFORM F_USER_COMMAND_100 USING E_UCOMM.

  ENDMETHOD.                    "HANDLE_USER_COMMAND

*  METHOD HANDLE_DATA_CHANGED.
*    PERFORM F_DATA_CHANGED_100 USING ER_DATA_CHANGED
*                               E_ONF4_AFTER.

*  ENDMETHOD.                    "HANDLE_DATA_CHANGED

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
    METHODS HANDLE_TOOLBAR
      FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT
                E_INTERACTIVE
                SENDER.

    METHODS HANDLE_USER_COMMAND
      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM.

*    METHODS HANDLE_DATA_CHANGED
*      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
*      IMPORTING ER_DATA_CHANGED
*                E_ONF4
*                E_ONF4_BEFORE
*                E_ONF4_AFTER
*                E_UCOMM.

    METHODS HANDLE_DATA_CHANGED_FINISHED
      FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED
                ET_GOOD_CELLS.

ENDCLASS.

*&---------------------------------------------------------------------*
*&      CLASS LCL_EVT_RECEIVER_200 IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER_200 IMPLEMENTATION.

  METHOD HANDLE_TOOLBAR.
    PERFORM F_TOOLBAR_200 USING E_OBJECT
                                             SENDER.
  ENDMETHOD.                    "HANDLE_TOOLBAR

  METHOD HANDLE_USER_COMMAND.
    PERFORM F_USER_COMMAND_200 USING E_UCOMM.

  ENDMETHOD.                    "HANDLE_USER_COMMAND

*  METHOD HANDLE_DATA_CHANGED.
*    PERFORM F_DATA_CHANGED_200 USING ER_DATA_CHANGED
*                               E_ONF4_AFTER.

*  ENDMETHOD.                    "HANDLE_DATA_CHANGED

  METHOD HANDLE_DATA_CHANGED_FINISHED.

    PERFORM F_DATA_CHANGED_FIN_200 USING E_MODIFIED
                                        ET_GOOD_CELLS.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED

ENDCLASS. "LCL_EVT_RECEIVER_200 IMPLEMENTATION

DATA :
  GCL_EVENT_100 TYPE REF TO LCL_EVT_RECEIVER_100,
  GCL_EVENT_200 TYPE REF TO LCL_EVT_RECEIVER_200.
