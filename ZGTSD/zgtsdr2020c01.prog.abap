*&---------------------------------------------------------------------*
*& Include          ZGTSDR2020C01
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION DEFERRED.
*CLASS LCL_EVENT_HANDLER2 DEFINITION DEFERRED.
*CLASS LCL_EVENT_HANDLER_ALV DEFINITION DEFERRED.

TYPE-POOLS: SLIS.

DATA: GRID1    TYPE REF TO CL_GUI_ALV_GRID,
      GRID2    TYPE REF TO CL_GUI_ALV_GRID,
      GRID3    TYPE REF TO CL_GUI_ALV_GRID,
      GRID4    TYPE REF TO CL_GUI_ALV_GRID,
      GRID5    TYPE REF TO CL_GUI_ALV_GRID,
      GRID6    TYPE REF TO CL_GUI_ALV_GRID,

      GO_GRID  TYPE REF TO CL_GUI_ALV_GRID,
      GO_GRID1 TYPE REF TO CL_GUI_ALV_GRID,
      GO_GRID2 TYPE REF TO CL_GUI_ALV_GRID,
      GO_GRID3 TYPE REF TO CL_GUI_ALV_GRID,
      GO_GRID4 TYPE REF TO CL_GUI_ALV_GRID,
      GO_GRID5 TYPE REF TO CL_GUI_ALV_GRID,

      GO_CCON1 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_CCON2 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_CCON3 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_CCON4 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_CCON5 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_CCON  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,

      GO_DCON1 TYPE REF TO CL_GUI_DOCKING_CONTAINER,
      GO_DCON2 TYPE REF TO CL_GUI_DOCKING_CONTAINER,
      GO_DCON3 TYPE REF TO CL_GUI_DOCKING_CONTAINER,
      GO_DCON4 TYPE REF TO CL_GUI_DOCKING_CONTAINER,
      GO_DCON5 TYPE REF TO CL_GUI_DOCKING_CONTAINER,
      GO_DCON  TYPE REF TO CL_GUI_DOCKING_CONTAINER,

      GO_GCON1 TYPE REF TO CL_GUI_CONTAINER,
      GO_GCON2 TYPE REF TO CL_GUI_CONTAINER,
      GO_GCON3 TYPE REF TO CL_GUI_CONTAINER,
      GO_GCON4 TYPE REF TO CL_GUI_CONTAINER,
      GO_GCON5 TYPE REF TO CL_GUI_CONTAINER,
      GO_GCON6 TYPE REF TO CL_GUI_CONTAINER.

DATA: GO_ALV_TITLE1 TYPE REF TO CL_DD_DOCUMENT,
      GO_ALV_TITLE2 TYPE REF TO CL_DD_DOCUMENT,
      GO_ALV_TITLE3 TYPE REF TO CL_DD_DOCUMENT,
      GO_ALV_TITLE4 TYPE REF TO CL_DD_DOCUMENT,
      GO_ALV_TITLE  TYPE REF TO CL_DD_DOCUMENT.
DATA: GO_HTML       TYPE REF TO CL_GUI_HTML_VIEWER.

DATA: GO_SPLITTER1 TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
      GO_SPLITTER2 TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
      GO_SPLITTER3 TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
      GO_SPLITTER4 TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
      GO_SPLITTER  TYPE REF TO CL_GUI_SPLITTER_CONTAINER.
*      GO_EVENT_RECEIVER TYPE REF TO LCL_EVENT_RECEIVER.

DATA: GO_TREE   TYPE REF TO CL_GUI_COLUMN_TREE.

DATA: FIELDCAT     TYPE LVC_S_FCAT OCCURS 0 WITH HEADER LINE,
      GT_FIELDCAT  TYPE LVC_T_FCAT,
      GT_FIELDCAT1 TYPE LVC_T_FCAT,
      GT_FIELDCAT2 TYPE LVC_T_FCAT,
      GT_FIELDCAT3 TYPE LVC_T_FCAT,
      GT_FIELDCAT4 TYPE LVC_T_FCAT,
      GT_FIELDCAT5 TYPE LVC_T_FCAT,
      GS_FIELDCAT  TYPE LVC_S_FCAT,
      GT_SORT      TYPE LVC_T_SORT WITH HEADER LINE,
      GT_SORT1     TYPE LVC_T_SORT WITH HEADER LINE,
      GT_SORT2     TYPE LVC_T_SORT WITH HEADER LINE,
      GT_SORT3     TYPE LVC_T_SORT WITH HEADER LINE,
      GT_SORT4     TYPE LVC_T_SORT WITH HEADER LINE,
      GT_SORT5     TYPE LVC_T_SORT WITH HEADER LINE,
      GS_SORT      TYPE LVC_S_SORT,
      GT_FILTER    TYPE LVC_T_FILT,
      GS_FILTER    TYPE LVC_S_FILT,
      GT_ALV_F4    TYPE LVC_T_F4,
      GS_ALV_F4    TYPE LVC_S_F4,
      GT_F4        TYPE LVC_T_F4,
      GS_F4        TYPE LVC_S_F4,
      GS_LAYOUT    TYPE LVC_S_LAYO,
      GS_LAYOUT1   TYPE LVC_S_LAYO,
      GS_LAYOUT2   TYPE LVC_S_LAYO,
      GS_LAYOUT3   TYPE LVC_S_LAYO,
      GS_LAYOUT4   TYPE LVC_S_LAYO,
      GS_LAYOUT5   TYPE LVC_S_LAYO,
      GS_VARIANT   TYPE DISVARIANT,
      GS_VARIANT1  TYPE DISVARIANT,
      GS_VARIANT2  TYPE DISVARIANT,
      GS_VARIANT3  TYPE DISVARIANT,
      GS_VARIANT4  TYPE DISVARIANT,
      GS_VARIANT5  TYPE DISVARIANT,
      GV_COL_POS   TYPE I.

DATA: GT_COLOR TYPE LVC_T_SCOL,
      GS_COLOR TYPE LVC_S_SCOL,
      GS_COL   TYPE LVC_S_COLO.

DATA: GT_EXCLUDE  TYPE UI_FUNCTIONS,
      GT_EXCLUDE1 TYPE UI_FUNCTIONS,
      GT_EXCLUDE2 TYPE UI_FUNCTIONS,
      GT_EXCLUDE3 TYPE UI_FUNCTIONS,
      GT_EXCLUDE4 TYPE UI_FUNCTIONS,
      GT_EXCLUDE5 TYPE UI_FUNCTIONS.

DATA: BEGIN OF GT_EXCLU1 OCCURS 0,
        FCODE LIKE SY-UCOMM,
      END OF GT_EXCLU1.

DATA: BEGIN OF GT_EXCLU2 OCCURS 0,
        FCODE LIKE SY-UCOMM,
      END OF GT_EXCLU2.

DATA: GT_INDEX_ROWS TYPE LVC_T_ROW,
      GT_ROWS       TYPE LVC_T_ROW,
      GT_ROW_NO     TYPE LVC_T_ROID,
      GS_INDEX_ROWS TYPE LVC_S_ROW,
      GS_ROWS       TYPE LVC_S_ROW,
      GS_ROW_NO     TYPE LVC_S_ROID.

TYPES: BEGIN OF TY_ROW,
         ROW    TYPE I,
         VALUE  TYPE C,
         COL    TYPE I,
         ROW_ID TYPE LVC_S_ROW,
         COL_ID TYPE LVC_S_COL,
         ROW_NO TYPE LVC_S_ROID,
       END OF TY_ROW.

TYPES: BEGIN OF TY_SCROLL,
         ROW_INFO TYPE LVC_S_ROW,
         COL_INFO TYPE LVC_S_COL,
         ROW_NO   TYPE LVC_S_ROID,
       END OF TY_SCROLL.

DATA: GS_V_ROW    TYPE TY_ROW,
      GS_V_SCROLL TYPE TY_SCROLL.

DATA: GT_FIELDS TYPE TABLE OF HELP_VALUE WITH HEADER LINE.

DATA: GV_SVALUE LIKE HELP_INFO-FLDVALUE,
      GV_SFIELD LIKE HELP_INFO-FIELDNAME.

*DATA: GV_REPID        LIKE SY-REPID.
DATA: GV_CPROG        LIKE SY-CPROG,
      GS_VARIANTE     LIKE DISVARIANT,
      GS_DEF_VARIANT  LIKE DISVARIANT,
      GV_VARIANT_EXIT TYPE C.

DATA: GO_ALV_EVT TYPE REF TO CL_GUI_EVENT,
      GO_ALV_OBJ TYPE REF TO CL_GUI_ALV_GRID,
      GO_GUI_OBJ TYPE REF TO CL_GUI_CONTROL.

DATA: GV_GRID_TITLE  TYPE LVC_TITLE,
      GV_GRID_TITLE1 TYPE LVC_TITLE,
      GV_GRID_TITLE2 TYPE LVC_TITLE,
      GV_GRID_TITLE3 TYPE LVC_TITLE.

DATA: GO_EVENT_RECEIVER  TYPE REF TO LCL_EVENT_HANDLER.
*      GO_EVENT_RECEIVER2 TYPE REF TO LCL_EVENT_HANDLER2.

DATA: GT_NODE      TYPE STANDARD TABLE OF TREEV_NODE,
      GT_NODE_ITEM TYPE STANDARD TABLE OF MTREEITM,
      GS_NODE      TYPE TREEV_NODE,
      GS_NODE_ITEM TYPE MTREEITM.


*----------------------------------------------------------------------*
* CLASS LCL_EVENT_RECEIVER DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.

  PUBLIC SECTION.

    METHODS: HANDLE_DATA_CHANGED
      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING ER_DATA_CHANGED
                E_ONF4_AFTER
                SENDER.

    METHODS: HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW
                E_COLUMN
                ES_ROW_NO
                SENDER.

    METHODS: HANDLE_HOTSPOT_CLICK
      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID
                E_COLUMN_ID
                SENDER.

    METHODS: HANDLE_TOOLBAR
      FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT
                E_INTERACTIVE
                SENDER.

    METHODS: HANDLE_USER_COMMAND
      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM
                SENDER.

    METHODS: HANDLE_ONF4
      FOR EVENT ONF4 OF CL_GUI_ALV_GRID
      IMPORTING E_FIELDNAME
                E_FIELDVALUE
                ES_ROW_NO
                ER_EVENT_DATA
                ET_BAD_CELLS
                E_DISPLAY
                SENDER.

    METHODS: HANDLE_TOP_OF_PAGE
      FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID
      IMPORTING E_DYNDOC_ID
                SENDER.

    METHODS: HANDLE_MENU_BUTTON
      FOR EVENT MENU_BUTTON OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT
                E_UCOMM
                SENDER.

    METHODS: HANDLE_CHANGED_FINISHED
      FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED
                ET_GOOD_CELLS
                SENDER.

  PRIVATE SECTION.

ENDCLASS.                    "LCL_EVENT_HANDLER_ALV DEFINITION

**----------------------------------------------------------------------*
** CLASS LCL_EVENT_RECEIVER DEFINITION
**----------------------------------------------------------------------*
*CLASS LCL_EVENT_HANDLER2 DEFINITION.
*
*  PUBLIC SECTION.
*
*    METHODS: HANDLE_DATA_CHANGED
*      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
*      IMPORTING ER_DATA_CHANGED
*                E_ONF4_AFTER
*                SENDER.
*
*    METHODS: HANDLE_DOUBLE_CLICK
*      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
*      IMPORTING E_ROW
*                E_COLUMN
*                ES_ROW_NO
*                SENDER.
*
*    METHODS: HANDLE_HOTSPOT_CLICK
*      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
*      IMPORTING E_ROW_ID
*                E_COLUMN_ID
*                SENDER.
*
*    METHODS: HANDLE_TOOLBAR
*      FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
*      IMPORTING E_OBJECT
*                E_INTERACTIVE
*                SENDER.
*
*    METHODS: HANDLE_USER_COMMAND
*      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
*      IMPORTING E_UCOMM
*                SENDER.
*
*    METHODS: HANDLE_ONF4
*      FOR EVENT ONF4 OF CL_GUI_ALV_GRID
*      IMPORTING E_FIELDNAME
*                E_FIELDVALUE
*                ES_ROW_NO
*                ER_EVENT_DATA
*                ET_BAD_CELLS
*                E_DISPLAY
*                SENDER.
*
*    METHODS: HANDLE_TOP_OF_PAGE
*      FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID
*      IMPORTING E_DYNDOC_ID
*                SENDER.
*
*    METHODS: HANDLE_MENU_BUTTON
*      FOR EVENT MENU_BUTTON OF CL_GUI_ALV_GRID
*      IMPORTING E_OBJECT
*                E_UCOMM
*                SENDER.
*
*    METHODS: HANDLE_CHANGED_FINISHED
*      FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
*      IMPORTING E_MODIFIED
*                ET_GOOD_CELLS
*                SENDER.
*
*  PRIVATE SECTION.
*
*ENDCLASS.                    "LCL_EVENT_HANDLER_ALV DEFINITION
*----------------------------------------------------------------------*
* CLASS LCL_EVENT_RECEIVER IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

  METHOD HANDLE_DATA_CHANGED.
    PERFORM ALV_DATA_CHANGED USING ER_DATA_CHANGED
                                   E_ONF4_AFTER
                                   SENDER.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED

  METHOD HANDLE_CHANGED_FINISHED.
    PERFORM ALV_CHANGED_FINISHED USING E_MODIFIED
                                       ET_GOOD_CELLS
                                       SENDER.
  ENDMETHOD.                    "HANDLE_CHANGED_FINISHED

  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM ALV_DOUBLE_CLICK USING E_ROW
                                   E_COLUMN
                                   ES_ROW_NO
                                   SENDER.
  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK

  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM ALV_HOTSPOT_CLICK USING E_ROW_ID
                                    E_COLUMN_ID
                                    SENDER.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  METHOD HANDLE_TOOLBAR.
    PERFORM ALV_TOOLBAR USING E_OBJECT
                              E_INTERACTIVE
                              SENDER.
  ENDMETHOD.                    "HANDLE_TOOLBAR

  METHOD HANDLE_USER_COMMAND.
    PERFORM ALV_USER_COMMAND USING E_UCOMM
                                   SENDER.
  ENDMETHOD.                    "HANDLE_USER_COMMAND

  METHOD HANDLE_ONF4.
*    PERFORM ALV_ONF4 USING E_FIELDNAME
*                           E_FIELDVALUE
*                           ES_ROW_NO
*                           ER_EVENT_DATA
*                           ET_BAD_CELLS
*                           E_DISPLAY
*                           SENDER.


  ENDMETHOD.                    "HANDLE_ONF4

  METHOD HANDLE_TOP_OF_PAGE.
*    PERFORM ALV_TOP_OF_PAGE USING E_DYNDOC_ID
*                                  SENDER.
  ENDMETHOD.                    "HANDLE_TOP_OF_PAGE

  METHOD HANDLE_MENU_BUTTON.
*    PERFORM ALV_MENU_BUTTON USING E_OBJECT
*                                  E_UCOMM
*                                  SENDER.
  ENDMETHOD.                    "HANDLE_MENU_BUTTON



ENDCLASS.                    "LCL_EVENT_HANDLER_ALV IMPLEMENTATION

**----------------------------------------------------------------------*
** CLASS LCL_EVENT_RECEIVER IMPLEMENTATION
**----------------------------------------------------------------------*
*CLASS LCL_EVENT_HANDLER2 IMPLEMENTATION.
*
*  METHOD HANDLE_DATA_CHANGED.
*    PERFORM ALV_DATA_CHANGED USING ER_DATA_CHANGED
*                                   E_ONF4_AFTER
*                                   SENDER.
*  ENDMETHOD.                    "HANDLE_DATA_CHANGED
*
*  METHOD HANDLE_CHANGED_FINISHED.
*    PERFORM ALV_CHANGED_FINISHED USING E_MODIFIED
*                                       ET_GOOD_CELLS
*                                       SENDER.
*  ENDMETHOD.                    "HANDLE_CHANGED_FINISHED
*
*  METHOD HANDLE_DOUBLE_CLICK.
*    PERFORM ALV_DOUBLE_CLICK USING E_ROW
*                                   E_COLUMN
*                                   ES_ROW_NO
*                                   SENDER.
*  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK
*
*  METHOD HANDLE_HOTSPOT_CLICK.
*    PERFORM ALV_HOTSPOT_CLICK USING E_ROW_ID
*                                    E_COLUMN_ID
*                                    SENDER.
*  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK
*
*  METHOD HANDLE_TOOLBAR.
*    PERFORM ALV_TOOLBAR USING E_OBJECT
*                              E_INTERACTIVE
*                              SENDER.
*  ENDMETHOD.                    "HANDLE_TOOLBAR
*
*  METHOD HANDLE_USER_COMMAND.
*    PERFORM ALV_USER_COMMAND USING E_UCOMM
*                                   SENDER.
*  ENDMETHOD.                    "HANDLE_USER_COMMAND
*
*  METHOD HANDLE_ONF4.
**    PERFORM ALV_ONF4 USING E_FIELDNAME
**                           E_FIELDVALUE
**                           ES_ROW_NO
**                           ER_EVENT_DATA
**                           ET_BAD_CELLS
**                           E_DISPLAY
**                           SENDER.
*
*
*  ENDMETHOD.                    "HANDLE_ONF4
*
*  METHOD HANDLE_TOP_OF_PAGE.
**    PERFORM ALV_TOP_OF_PAGE USING E_DYNDOC_ID
**                                  SENDER.
*  ENDMETHOD.                    "HANDLE_TOP_OF_PAGE
*
*  METHOD HANDLE_MENU_BUTTON.
**    PERFORM ALV_MENU_BUTTON USING E_OBJECT
**                                  E_UCOMM
**                                  SENDER.
*  ENDMETHOD.                    "HANDLE_MENU_BUTTON
*
*
*
*ENDCLASS.                    "LCL_EVENT_HANDLER_ALV IMPLEMENTATION

*&---------------------------------------------------------------------*
*& Form ALV_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> E_ONF4_AFTER
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM ALV_DATA_CHANGED  USING    PO_DATA_CHANGED TYPE REF TO
                                          CL_ALV_CHANGED_DATA_PROTOCOL
                                PE_ONF4_AFTER
                                PV_SENDER.

  FIELD-SYMBOLS:<FS_VALUE> TYPE ANY.

  CASE PV_SENDER.

    WHEN GO_GRID1.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).
        IF <FS_VALUE> IS ASSIGNED. UNASSIGN <FS_VALUE>.ENDIF.
        ASSIGN COMPONENT LS_MOD_CELLS-FIELDNAME OF STRUCTURE GS_LIST TO <FS_VALUE>.
        CHECK SY-SUBRC EQ 0.

        CALL METHOD PO_DATA_CHANGED->GET_CELL_VALUE
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
          IMPORTING
            E_VALUE     = <FS_VALUE>.

        CALL METHOD PO_DATA_CHANGED->MODIFY_CELL
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
            I_VALUE     = <FS_VALUE>.
      ENDLOOP.

    WHEN GO_GRID2.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        IF <FS_VALUE> IS ASSIGNED. UNASSIGN <FS_VALUE>.ENDIF.
        ASSIGN COMPONENT LS_MOD_CELLS-FIELDNAME OF STRUCTURE GS_SPLIT TO <FS_VALUE>.
        CHECK SY-SUBRC EQ 0.

        CALL METHOD PO_DATA_CHANGED->GET_CELL_VALUE
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
          IMPORTING
            E_VALUE     = <FS_VALUE>.

        CALL METHOD PO_DATA_CHANGED->MODIFY_CELL
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
            I_VALUE     = <FS_VALUE>.
      ENDLOOP.

    WHEN GO_GRID3.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.

        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'FACTOR_B'.  "매출조장수
*            PERFORM DATA_CHANGED_FACTOR_B USING PO_DATA_CHANGED LS_MOD_CELLS.

          WHEN OTHERS.
            IF <FS_VALUE> IS ASSIGNED. UNASSIGN <FS_VALUE>.ENDIF.
            ASSIGN COMPONENT LS_MOD_CELLS-FIELDNAME OF STRUCTURE GS_ITEM TO <FS_VALUE>.
            CHECK SY-SUBRC EQ 0.

            CALL METHOD PO_DATA_CHANGED->GET_CELL_VALUE
              EXPORTING
                I_ROW_ID    = LS_MOD_CELLS-ROW_ID
                I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
              IMPORTING
                E_VALUE     = <FS_VALUE>.

            CALL METHOD PO_DATA_CHANGED->MODIFY_CELL
              EXPORTING
                I_ROW_ID    = LS_MOD_CELLS-ROW_ID
                I_FIELDNAME = LS_MOD_CELLS-FIELDNAME
                I_VALUE     = <FS_VALUE>.
        ENDCASE.


      ENDLOOP.

    WHEN OTHERS.
  ENDCASE.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM ALV_CHANGED_FINISHED  USING    PV_MODIFIED TYPE CHAR01
                                    PT_GOOD_CELLS TYPE LVC_T_MODI
                                    PV_SENDER.

  DATA: LT_MODI TYPE LVC_T_MODI.
  DATA: LS_MODI TYPE LVC_S_MODI.

  CHECK PV_MODIFIED IS NOT INITIAL.

  CASE PV_SENDER.

    WHEN GO_GRID1.
      PERFORM ALV_CHANGE_FINISHED_0100_TOP USING PT_GOOD_CELLS.

    WHEN GO_GRID2.
      PERFORM ALV_CHANGE_FINISHED_0100_BOT USING PT_GOOD_CELLS.

    WHEN GO_GRID3.
      PERFORM ALV_CHANGE_FINISHED_0200_ITEM USING PT_GOOD_CELLS.

    WHEN OTHERS.

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM ALV_TOOLBAR  USING    PE_OBJECT
                                TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                           PE_INTERACTIVE
                           PV_SENDER.
  DATA: LS_TOOLBAR TYPE STB_BUTTON.

  CASE PV_SENDER.
    WHEN GO_GRID1.

      IF GV_DISP IS INITIAL.
        CLEAR LS_TOOLBAR.
        LS_TOOLBAR-BUTN_TYPE = '3'.
        LS_TOOLBAR-DISABLED = SPACE.
        APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

        CLEAR LS_TOOLBAR.
        LS_TOOLBAR-FUNCTION  = 'ZCR10'.
        LS_TOOLBAR-ICON      = ICON_GENERATE.
        LS_TOOLBAR-BUTN_TYPE = '0'.
        LS_TOOLBAR-DISABLED  = SPACE.
        LS_TOOLBAR-TEXT      = TEXT-005.
        LS_TOOLBAR-QUICKINFO = TEXT-005.
        LS_TOOLBAR-CHECKED   = SPACE.
        APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

        CLEAR LS_TOOLBAR.
        LS_TOOLBAR-BUTN_TYPE = '3'.
        LS_TOOLBAR-DISABLED = SPACE.
        APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

        CLEAR LS_TOOLBAR.
        LS_TOOLBAR-FUNCTION  = 'ZRE10'.
        LS_TOOLBAR-ICON      = ICON_SYSTEM_UNDO.
        LS_TOOLBAR-BUTN_TYPE = '0'.
        LS_TOOLBAR-DISABLED  = SPACE.
        LS_TOOLBAR-TEXT      = TEXT-006.
        LS_TOOLBAR-QUICKINFO = TEXT-006.
        LS_TOOLBAR-CHECKED   = SPACE.
        APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

      ENDIF.

    WHEN GO_GRID2.

      IF GV_DISP IS INITIAL.

        CLEAR LS_TOOLBAR.
        LS_TOOLBAR-BUTN_TYPE = '3'.
        LS_TOOLBAR-DISABLED = SPACE.
        APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

        CLEAR LS_TOOLBAR.
        LS_TOOLBAR-FUNCTION  = 'ZCR20'.
        LS_TOOLBAR-ICON      = ICON_GENERATE.
        LS_TOOLBAR-BUTN_TYPE = '0'.
        LS_TOOLBAR-DISABLED  = SPACE.
        LS_TOOLBAR-TEXT      = TEXT-005.
        LS_TOOLBAR-QUICKINFO = TEXT-005.
        LS_TOOLBAR-CHECKED   = SPACE.
        APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

        CLEAR LS_TOOLBAR.
        LS_TOOLBAR-BUTN_TYPE = '3'.
        LS_TOOLBAR-DISABLED = SPACE.
        APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

        CLEAR LS_TOOLBAR.
        LS_TOOLBAR-FUNCTION  = 'ZRE20'.
        LS_TOOLBAR-ICON      = ICON_SYSTEM_UNDO.
        LS_TOOLBAR-BUTN_TYPE = '0'.
        LS_TOOLBAR-DISABLED  = SPACE.
        LS_TOOLBAR-TEXT      = TEXT-006.
        LS_TOOLBAR-QUICKINFO = TEXT-006.
        LS_TOOLBAR-CHECKED   = SPACE.
        APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

        CLEAR LS_TOOLBAR.
        LS_TOOLBAR-BUTN_TYPE = '3'.
        LS_TOOLBAR-DISABLED = SPACE.
        APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

        CLEAR LS_TOOLBAR.
        LS_TOOLBAR-FUNCTION = 'ZSELA'.
        LS_TOOLBAR-ICON     = ICON_SELECT_ALL.
        LS_TOOLBAR-BUTN_TYPE = '0'.
        LS_TOOLBAR-DISABLED = SPACE.
* LS TOOLBAR-TEXT  = TEXT-B10.
        LS_TOOLBAR-QUICKINFO = SPACE.
        LS_TOOLBAR-CHECKED   = SPACE.
        APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

        CLEAR LS_TOOLBAR.
        LS_TOOLBAR-BUTN_TYPE = '3'.
        LS_TOOLBAR-DISABLED = SPACE.
        APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.

        CLEAR LS_TOOLBAR.
        LS_TOOLBAR-FUNCTION = 'ZDSEL'.
        LS_TOOLBAR-ICON     = ICON_DESELECT_ALL.
        LS_TOOLBAR-BUTN_TYPE = '0'.
        LS_TOOLBAR-DISABLED = SPACE.
* LS TOOLBAR-TEXT  = TEXT-B10.
        LS_TOOLBAR-QUICKINFO = SPACE.
        LS_TOOLBAR-CHECKED   = SPACE.
        APPEND LS_TOOLBAR TO PE_OBJECT->MT_TOOLBAR.
      ENDIF.
  ENDCASE.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_USER_COMMAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM ALV_USER_COMMAND  USING    PV_UCOMM
                                PV_SENDER.

  CASE PV_SENDER.
    WHEN GO_GRID1. "화면 0100 - TOP
      CASE PV_UCOMM.
        WHEN 'ZCR10'. "매출처리
          PERFORM PROC_BILLING_JS_RUN_0100_TOP.

        WHEN 'ZRE10'. "매출취소
          PERFORM PROC_BILLING_JS_CANC_0100_TOP.

      ENDCASE.

    WHEN GO_GRID2. "화면 0100 - BOTTOM
      CASE PV_UCOMM.
        WHEN 'ZCR20'. "매출처리
          PERFORM PROC_BILLING_JS_RUN_0100_BOT.

        WHEN 'ZRE20'. "매출취소
          PERFORM PROC_BILLING_JS_CANC_0100_BOT.

        WHEN 'ZSELA'. "전체선택
          PERFORM SELECT_ALL_0100_BOT.

        WHEN 'ZDSEL'. "전체해제
          PERFORM DESELECT_ALL_0100_BOT.

        WHEN OTHERS.

      ENDCASE.

  ENDCASE.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&      --> ES_ROW_NO
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM ALV_DOUBLE_CLICK  USING    PS_E_ROW  TYPE LVC_S_ROW
                                PS_E_COLUMN TYPE LVC_S_COL
                                PS_ES_ROW_NO TYPE LVC_S_ROID
                                PV_SENDER.

  CASE PV_SENDER.
    WHEN GO_GRID1.
      PERFORM ALV_DOUBLE_CLICK_0100_H USING PS_E_ROW PS_E_COLUMN.


    WHEN GO_GRID2.
      PERFORM ALV_DOUBLE_CLICK_0100_I USING PS_E_ROW PS_E_COLUMN.

    WHEN OTHERS.



  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM ALV_HOTSPOT_CLICK  USING   PS_E_ROW  TYPE LVC_S_ROW
                                PS_E_COLUMN TYPE LVC_S_COL
                                 PV_SENDER.

  CASE PV_SENDER.
    WHEN GO_GRID1.
      PERFORM ALV_HOTSPOT_CLICK_0100_H USING PS_E_ROW PS_E_COLUMN.


    WHEN GO_GRID2.

    WHEN OTHERS.



  ENDCASE.

ENDFORM.
