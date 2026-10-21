*&---------------------------------------------------------------------*
*& Include          ZSDR0950E01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* ALV
*----------------------------------------------------------------------*
*- ALV COMMON
TYPE-POOLS : KKBLO.
DATA : GS_STBL      TYPE LVC_S_STBL,
       GT_SFIELDCAT TYPE KKBLO_T_FIELDCAT,
       GS_EXCLUDING TYPE LINE OF UI_FUNCTIONS,
       GT_EXCLUDING TYPE UI_FUNCTIONS.

*- ALV1
CLASS: LCL_EVENT_RECEIVER DEFINITION DEFERRED.

DATA : EVENT_RECEIVER      TYPE REF TO LCL_EVENT_RECEIVER.
DATA : GRID                TYPE REF TO CL_GUI_ALV_GRID,
       G_CUSTOM_CONTAINER  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       G_DOCKING_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       G_SPLITTER          TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       G_CONTAINER         TYPE REF TO CL_GUI_CONTAINER,
       G_CON               TYPE SCRFNAME VALUE 'ALV1',

       LCL_PARENT_HTML     TYPE REF TO CL_GUI_CONTAINER,
       LCL_PARENT_GRID     TYPE REF TO CL_GUI_CONTAINER,
       LCL_DYNDOC_ID       TYPE REF TO CL_DD_DOCUMENT.

DATA : GS_LAYOUT   TYPE LVC_S_LAYO,
       GT_FIELDCAT TYPE LVC_T_FCAT,
       GS_FIELDCAT TYPE LVC_S_FCAT,
       GT_SORT     TYPE LVC_T_SORT,
       GS_SORT     TYPE LVC_S_SORT,
       GS_VARIANT  TYPE DISVARIANT,
       GT_EXCLUDE  TYPE UI_FUNCTIONS,
       GT_STYL     TYPE LVC_T_STYL,
       GS_STYL     TYPE LVC_S_STYL.

*- ALV2
CLASS: LCL_EVENT_RECEIVER2 DEFINITION DEFERRED.
DATA : EVENT_RECEIVER2      TYPE REF TO LCL_EVENT_RECEIVER2.
DATA : GRID2                TYPE REF TO CL_GUI_ALV_GRID,
       G_CUSTOM_CONTAINER2  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       G_DOCKING_CONTAINER2 TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       G_CONTAINER2         TYPE REF TO CL_GUI_CONTAINER,
       G_CON2               TYPE SCRFNAME VALUE 'ALV2',
*{ SRM2404-03220 - s Long text 추가
       G_CUSTOM_CONTAINER3  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       G_EDITOR             TYPE REF TO CL_GUI_TEXTEDIT.
*} SRM2404-03220 - e

DATA : GS_LAYOUT2   TYPE LVC_S_LAYO,
       GT_FIELDCAT2 TYPE LVC_T_FCAT,
       GS_FIELDCAT2 TYPE LVC_S_FCAT,
       GT_SORT2     TYPE LVC_T_SORT,
       GS_SORT2     TYPE LVC_S_SORT,
       GS_VARIANT2  TYPE DISVARIANT,
       GT_EXCLUDE2  TYPE UI_FUNCTIONS.

*----------------------------------------------------------------------*
*       CLASS lcl_application DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER DEFINITION.

  PUBLIC SECTION.
    DATA: L_NEXT_NODE_KEY TYPE I.

    CLASS-METHODS:
      CATCH_DBL
        FOR EVENT NODE_DOUBLE_CLICK OF CL_GUI_SIMPLE_TREE
        IMPORTING NODE_KEY,

      HANDLE_TOP_OF_PAGE
        FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID
        IMPORTING E_DYNDOC_ID,

      HANDLE_DOUBLE_CLICK
        FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
        IMPORTING E_ROW E_COLUMN ES_ROW_NO,

      HANDLE_TOOLBAR
        FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
        IMPORTING E_OBJECT E_INTERACTIVE,

      HANDLE_USER_COMMAND
        FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
        IMPORTING E_UCOMM,

      HANDLE_DATA_CHANGED
        FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
        IMPORTING ER_DATA_CHANGED SENDER
                  E_ONF4
                  E_ONF4_BEFORE
                  E_ONF4_AFTER,

      HANDLE_ONF4
        FOR EVENT ONF4 OF CL_GUI_ALV_GRID
        IMPORTING SENDER
                  E_FIELDNAME
                  E_FIELDVALUE
                  ES_ROW_NO
                  ER_EVENT_DATA
                  ET_BAD_CELLS
                  E_DISPLAY.

ENDCLASS.                    "lcl_application DEFINITION
*----------------------------------------------------------------------*
*       CLASS lcl_application IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.
  METHOD CATCH_DBL.
*    PERFORM HANDLE_NODE_DOUBLE_CLICK USING NODE_KEY.
  ENDMETHOD.                    "HANDLE_NODE_DOUBLE_CLICK

  METHOD HANDLE_TOP_OF_PAGE.
*    PERFORM HANDLE_TOP_OF_PAGE USING LCL_DYNDOC_ID.
  ENDMETHOD.                    "handle_top_of_page
*
  METHOD HANDLE_DOUBLE_CLICK.
*    PERFORM handle_double_click USING e_row e_column es_row_no.
  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK

  METHOD HANDLE_TOOLBAR.
    PERFORM SET_TOOLBAR USING E_OBJECT.
  ENDMETHOD.                    "HANDLE_TOOLBAR

  METHOD HANDLE_USER_COMMAND.
    PERFORM HANDLE_USER_COMMAND USING E_UCOMM.
  ENDMETHOD.                    "HANDLE_USER_COMMAND

  METHOD HANDLE_DATA_CHANGED.
     PERFORM HANDLE_DATA_CHANGED USING ER_DATA_CHANGED.

  ENDMETHOD.                    "handle_data_changed

  METHOD HANDLE_ONF4.
*    CHECK ER_EVENT_DATA->M_EVENT_HANDLED = ''.
*    PERFORM ON_F4 USING E_FIELDNAME
*                        E_FIELDVALUE
*                        ES_ROW_NO
*                        ER_EVENT_DATA
*                        E_DISPLAY.

*    ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.
  ENDMETHOD.                    "HANDLE_ONF4

ENDCLASS.                    "lcl_application IMPLEMENTATION
*---------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVER2 DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER2 DEFINITION.
  PUBLIC SECTION.
    METHODS :
      HANDLE_DOUBLE_CLICK
        FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
        IMPORTING E_ROW E_COLUMN ES_ROW_NO.
ENDCLASS. "lcl_event_receiver DEFINITION
*---------------------------------------------------------------------*
*       CLASS lcl_event_receiver2 IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER2 IMPLEMENTATION.
  METHOD HANDLE_DOUBLE_CLICK.
*    PERFORM HANDLE_DOUBLE_CLICK2 USING E_ROW E_COLUMN ES_ROW_NO.
  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK
ENDCLASS. "lcl_event_receiver IMPLEMENTATION
