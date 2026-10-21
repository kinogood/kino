*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR3010C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      CLASS ALV
*&---------------------------------------------------------------------*
DATA :
       GCL_DOCKING  TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GCL_CUSTOM   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GCL_SPLIT    TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       GCL_CON_TOP  TYPE REF TO CL_GUI_CONTAINER,            "TOP
       GCL_CON_BODY TYPE REF TO CL_GUI_CONTAINER,           "BODY
       GCL_CL_DD    TYPE REF TO CL_DD_DOCUMENT,                "HTML
       GCL_GRID        TYPE REF TO CL_GUI_ALV_GRID,
       GCL_GRID_300  TYPE REF TO CL_GUI_ALV_GRID,
       GT_FCAT        TYPE LVC_T_FCAT,
       GT_FCAT_300 TYPE LVC_T_FCAT,
       GS_LAYOUT    TYPE LVC_S_LAYO,
       GT_SORT      TYPE LVC_T_SORT,
       GT_EXCLUD    TYPE UI_FUNCTIONS,
       GT_ROWS      TYPE LVC_T_ROW,
       GS_ROW        TYPE LVC_S_ROW.



**----------------------------------------------------------------------*
**       CLASS LCL_EVT_RECEIVER3 DEFINITION DEFERRED
**----------------------------------------------------------------------*
** CLASS관련 선언
** DEFINETION
*CLASS LCL_EVENTS_HIST DEFINITION.
*  PUBLIC SECTION.
*    METHODS: LCL_HOTSPOT_CLICK
*      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
*      IMPORTING E_ROW_ID E_COLUMN_ID ES_ROW_NO.
*ENDCLASS.                    "LCL_EVENTS_HIST DEFINITION
*
** IMPLEMETATION
*CLASS LCL_EVENTS_HIST IMPLEMENTATION.
*  METHOD LCL_HOTSPOT_CLICK.
*    PERFORM LCL_HOTSPOT_CLICK_HIST USING E_ROW_ID E_COLUMN_ID ES_ROW_NO.
*  ENDMETHOD.                    "HOTSPOT_CLICK
*ENDCLASS.                    "LCL_EVENTS_HIST IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS LCL_EVT_RECEIVER DEFINITION
*----------------------------------------------------------------------*
CLASS : LCL_EVT_RECEIVER DEFINITION DEFERRED.
DATA : GCL_EVENT      TYPE REF TO LCL_EVT_RECEIVER.

CLASS LCL_EVT_RECEIVER DEFINITION FINAL.

  PUBLIC SECTION.
    METHODS HANDLE_TOP_OF_PAGE
      FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID
      IMPORTING E_DYNDOC_ID.

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

    METHODS HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW
                E_COLUMN
                ES_ROW_NO.

    METHODS  HANDLE_ON_F4
      FOR EVENT ONF4 OF CL_GUI_ALV_GRID
      IMPORTING E_FIELDNAME
                E_FIELDVALUE
                ES_ROW_NO
                ER_EVENT_DATA
                ET_BAD_CELLS
                E_DISPLAY.

    " CHECK ALV ERROR
    DATA : MV_ERROR_IN_DATA TYPE C.

ENDCLASS.
*&---------------------------------------------------------------------*
*&      CLASS LCL_EVT_RECEIVER IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS LCL_EVT_RECEIVER IMPLEMENTATION.
  METHOD HANDLE_TOP_OF_PAGE.

*    PERFORM TOP_OF_PAGE USING E_DYNDOC_ID.

  ENDMETHOD.                    "HANDLE_TOP_OF_PAGE

  METHOD HANDLE_TOOLBAR.
    PERFORM TOOLBAR USING E_OBJECT
                                             SENDER.
  ENDMETHOD.                    "HANDLE_TOOLBAR

  METHOD HANDLE_USER_COMMAND.
    PERFORM USER_COMMAND USING E_UCOMM.

  ENDMETHOD.                    "HANDLE_USER_COMMAND

  METHOD HANDLE_DATA_CHANGED.
    PERFORM DATA_CHANGED USING ER_DATA_CHANGED
                               SENDER.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED

  METHOD HANDLE_DATA_CHANGED_FINISHED.

    PERFORM DATA_CHANGED_FINISHED USING E_MODIFIED
                                        ET_GOOD_CELLS
                                        SENDER.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED

  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM HOTSPOT_CLICK USING E_ROW_ID
                                E_COLUMN_ID
                                SENDER.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  METHOD HANDLE_DOUBLE_CLICK.

*    PERFORM DOUBLE_CLICK USING E_ROW
*                               E_COLUMN
*                               ES_ROW_NO.

  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK

  METHOD HANDLE_ON_F4.

    PERFORM ON_F4 USING E_FIELDNAME
                        E_FIELDVALUE
                        ES_ROW_NO
                        ER_EVENT_DATA
                        ET_BAD_CELLS
                        E_DISPLAY.

  ENDMETHOD.                    "HANDLE_ON_F4
ENDCLASS. "LCL_RECIVR IMPLEMENTATION
