*&---------------------------------------------------------------------*
*&  Include           MZQM0696CLS
*&---------------------------------------------------------------------*
* Tables
TABLES : ICON.    " 아이콘테이블
INCLUDE <ICON>.

* Types
TYPE-POOLS : SLIS.

* Constants
CONSTANTS : GC_STATUS_SET       TYPE SLIS_FORMNAME VALUE 'PF_STATUS_SET',
            GC_USER_COMMAND     TYPE SLIS_FORMNAME VALUE 'USER_COMMAND',
            GC_TOP_OF_PAGE      TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE',
            GC_TOP_OF_LIST      TYPE SLIS_FORMNAME VALUE 'TOP_OF_LIST',
            GC_END_OF_LIST      TYPE SLIS_FORMNAME VALUE 'END_OF_LIST',
            GC_DATA_CHANGED     TYPE SLIS_FORMNAME VALUE 'DATA_CHANGED',
            GC_HTML_TOP_OF_PAGE
                            TYPE SLIS_FORMNAME VALUE 'HTML_TOP_OF_PAGE',
            GC_PRT_TOP_OF_PAGE
                            TYPE SLIS_FORMNAME VALUE 'PRT_TOP_OF_PAGE'.

* Global Variable
DATA : GV_SAVE,
       GV_TABIX                 LIKE SY-TABIX,
       GV_FLD_NAME(30),
       GV_EXIT_CAUSED_BY_CALLER,
       GV_REPID                 TYPE SY-REPID,
       GV_DYNNR                 TYPE SY-DYNNR,
       GV_PROGRAM_NAME          LIKE SY-REPID,
       GV_INCLNAME              LIKE TRDIR-NAME,
       GV_EXTENSION             TYPE I.

* Structures
DATA : GS_LAYOUT              TYPE SLIS_LAYOUT_ALV,
       GS_EXIT_CAUSED_BY_USER TYPE SLIS_EXIT_BY_USER,
       GS_FIELDCAT            TYPE SLIS_FIELDCAT_ALV,
       GS_SORT                TYPE SLIS_SORTINFO_ALV,
       GS_KEYINFO             TYPE SLIS_KEYINFO_ALV,
       GS_VARIANT             TYPE DISVARIANT,
       GS_SCROLL              TYPE SLIS_LIST_SCROLL,
       GS_LISTHEADER          TYPE SLIS_LISTHEADER,
       GS_DETAIL_FUNC         LIKE DD02L-TABNAME.

DATA : GS_LVC_LAYO  TYPE LVC_S_LAYO,             " Layout
       GS_LVC_LAYO2 TYPE LVC_S_LAYO.             " Layout

DATA : GS_LVC_FCAT  TYPE LVC_S_FCAT,             " Fieldcatalog
       GS_LVC_FCAT2 TYPE LVC_S_FCAT.             " Fieldcatalog
* Internal tables
DATA : GT_EVENTS     TYPE SLIS_T_EVENT,
       GT_LISTHEADER TYPE SLIS_T_LISTHEADER,
       GT_FIELDCAT   TYPE SLIS_T_FIELDCAT_ALV,
       GT_SORT       TYPE SLIS_T_SORTINFO_ALV WITH HEADER LINE,
       GT_EXIT       TYPE SLIS_EVENT_EXIT OCCURS 0,
       GT_PRINT      TYPE SLIS_PRINT_ALV.

DATA : GT_UI_FUNCTIONS  TYPE UI_FUNCTIONS,           " ToolBar
       GT_UI_FUNCTIONS2 TYPE UI_FUNCTIONS.           " ToolBar

DATA : GT_LVC_SORT  TYPE LVC_T_SORT WITH HEADER LINE, " Sort
       GT_LVC_SORT2 TYPE LVC_T_SORT WITH HEADER LINE. " Sort

DATA : GT_LVC_FCAT  TYPE LVC_T_FCAT,             " Fieldcatalog
       GT_LVC_FCAT2 TYPE LVC_T_FCAT.             " Fieldcatalog

* Field Symbols
FIELD-SYMBOLS : <FS_FIELD>.

* Drop-Down List Box 관련 ----------------------------------------------
DATA : GT_LVC_DROP TYPE LVC_T_DROP,
       GS_LVC_DROP TYPE LVC_S_DROP.


* Column Color 관련 ----------------------------------------------------
DATA : GT_COLOR TYPE LVC_T_SCOL WITH HEADER LINE,
       GS_COLOR TYPE LVC_S_COLO.


* 선택된 ROW 관련 ------------------------------------------------------
DATA : GT_ROWS   TYPE LVC_T_ROW,
       GS_ROWS   TYPE LVC_S_ROW,
       GV_FUN(1) VALUE 'D'.

* F4 Possible Entry ----------------------------------------------------
* Structures
DATA : GS_F4_VALUE TYPE SEAHLPRES,
       GS_F4_FIELD TYPE DFIES,
       GS_F4       TYPE DDSHRETVAL,
       GS_LVC_MODI TYPE LVC_S_MODI,
       GS_LVC_F4   TYPE LVC_S_F4.

* Internal tables
DATA : GT_F4_VALUES TYPE TABLE OF SEAHLPRES,
       GT_F4_FIELDS TYPE TABLE OF DFIES,
       GT_LVC_F4    TYPE LVC_T_F4.

* Possible Entry Header TEXT
DATA : BEGIN OF GT_FIELD_TAB OCCURS 0.
         INCLUDE STRUCTURE DFIES.
DATA : END OF GT_FIELD_TAB.

* Field Symbols
FIELD-SYMBOLS : <FS_F4TAB> TYPE LVC_T_MODI.


************************************************************************
* The Declaration of Variables
************************************************************************
* Control관련 데이타 선언
CLASS : LCL_DEF_RECEIVER     DEFINITION DEFERRED,
        LCL_DEF_GRID         DEFINITION DEFERRED.

* Reference to custom container: neccessary to bind ALV Control
DATA : LCL_MYCONTAINER    TYPE SCRFNAME VALUE 'W_CONTAINER',
       LCL_CONTAINER      TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       LCL_GRID           TYPE REF TO LCL_DEF_GRID,
       LCL_TOOLBAR        TYPE REF TO CL_GUI_TOOLBAR,
       LCL_EVENT_RECEIVER TYPE REF TO LCL_DEF_RECEIVER.

DATA : G_DOCKCONTAINER1 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA : G_PARENT_GRID TYPE REF TO CL_GUI_CONTAINER,
       G_PARENT_HTML TYPE REF TO CL_GUI_CONTAINER,
       G_HTML        TYPE REF TO CL_GUI_HTML_VIEWER,
       G_DOCUMENT    TYPE REF TO CL_DD_DOCUMENT,
       G_SPLITTER    TYPE REF TO CL_GUI_SPLITTER_CONTAINER.
************************************************************************
* LOCAL CLASSES: Definition
************************************************************************
* 클래스 정의
CLASS LCL_DEF_RECEIVER DEFINITION.

  PUBLIC SECTION.
    METHODS : HANDLE_TOOLBAR
      FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT
                E_INTERACTIVE.
    METHODS : HANDLE_USER_COMMAND
      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM.

    METHODS : HANDLE_DATA_CHANGED
      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING ER_DATA_CHANGED.

    METHODS : HANDLE_DATA_CHANGED_FINISHED
      FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED ET_GOOD_CELLS.

    METHODS : HANDLE_HOTSPOT_CLICK
      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID
                E_COLUMN_ID.

    METHODS : HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW
                E_COLUMN
                ES_ROW_NO.

    METHODS: HANDLE_ON_F4 FOR EVENT ONF4 OF CL_GUI_ALV_GRID
      IMPORTING SENDER
                E_FIELDNAME
                E_FIELDVALUE
                ES_ROW_NO
                ER_EVENT_DATA
                ET_BAD_CELLS
                E_DISPLAY.

    METHODS : HANDLE_TOP_OF_PAGE
      FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID
      IMPORTING E_DYNDOC_ID.

ENDCLASS.  " lcl_def_receiver
************************************************************************
* LOCAL CLASSES: Implementation
************************************************************************
* 클래스 구현
CLASS LCL_DEF_RECEIVER IMPLEMENTATION.

  METHOD HANDLE_TOOLBAR.
*    PERFORM toolbar_part2 USING e_object e_interactive.
  ENDMETHOD.                    "handle_toolbar

  METHOD HANDLE_USER_COMMAND.
*    PERFORM USER_COMMAND_PART USING E_UCOMM.
  ENDMETHOD.                    "handle_user_command

  METHOD HANDLE_DATA_CHANGED.
*    PERFORM DATA_CHANGED USING ER_DATA_CHANGED.
  ENDMETHOD.                    "handle_data_changed

  METHOD HANDLE_DATA_CHANGED_FINISHED.
*    PERFORM DATA_CHANGED_FINISHED USING ET_GOOD_CELLS[].
  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED

  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM HOTSPOT_CLICK USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "handle_hotspot_click

  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM DOUBLE_CLICK USING E_ROW E_COLUMN ES_ROW_NO.
  ENDMETHOD.                    "handle_double_click

  METHOD HANDLE_ON_F4.
*    PERFORM ON_F4 USING E_FIELDNAME
*                        E_FIELDVALUE
*                        ES_ROW_NO
*                        ER_EVENT_DATA
*                        ET_BAD_CELLS
*                        E_DISPLAY.
  ENDMETHOD.                    "handle_on_f4

  METHOD HANDLE_TOP_OF_PAGE.
*    PERFORM event_top_of_page USING e_dyndoc_id.
  ENDMETHOD.                    "HANDLE_TOP_OF_PAGE

ENDCLASS.  " lcl_def_receiver
*---------------------------------------------------------------------*
*       CLASS lcl_def_grid1 DEFINITION
*---------------------------------------------------------------------*
CLASS LCL_DEF_GRID DEFINITION INHERITING FROM CL_GUI_ALV_GRID.

  PUBLIC SECTION.
    METHODS : U_SET_FIXED_ROWS,
              U_SET_RESIZE_COLS,
              U_SCROLL_TO_BOTTOM,
              U_SET_OPTIMIZE,
              U_SET_CURRENT_CELL_BASE
        IMPORTING
          ROW TYPE I
          COL TYPE I.

ENDCLASS.                    "lcl_def_grid DEFINITION
*---------------------------------------------------------------------*
*       CLASS lcl_def_grid IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS LCL_DEF_GRID IMPLEMENTATION.

  METHOD  U_SET_FIXED_ROWS.
    CALL METHOD ME->SET_FIXED_ROWS
      EXPORTING
        ROWS = 1.
  ENDMETHOD.                    " U_SET_FIXED_ROWS

  METHOD  U_SET_RESIZE_COLS.
    CALL METHOD ME->SET_RESIZE_COLS
      EXPORTING
        ENABLE = 1.   " NO
  ENDMETHOD.                    " U_SET_RESIZE_COLS

  METHOD  U_SCROLL_TO_BOTTOM.
    CALL METHOD ME->SCROLL_TO_BOTTOM.
  ENDMETHOD.                    " U_SCROLL_TO_BOTTOM

  METHOD  U_SET_CURRENT_CELL_BASE.
    CALL METHOD ME->SET_CURRENT_CELL_BASE
      EXPORTING
        ROW = ROW
        COL = COL.
  ENDMETHOD.                    " U_SET_CURRENT_CELL_BASE

  METHOD U_SET_OPTIMIZE.
    CALL METHOD ME->OPTIMIZE_ALL_COLS
      EXPORTING
        INCLUDE_HEADER = 1.
  ENDMETHOD.                    " U_set_optimize

ENDCLASS.                    " lcl_def_grid IMPLEMENTATION
