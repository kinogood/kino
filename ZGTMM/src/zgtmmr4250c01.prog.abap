*&---------------------------------------------------------------------*
*& Include          ZGTMMR4250C01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION INHERITING FROM CL_GUI_OBJECT.

  PUBLIC SECTION.

    DATA : GV_OTEXT(30).

    METHODS : CONSTRUCTOR
      IMPORTING E_OBJECT_TEXT TYPE C.

    METHODS : HANDLE_TOP_OF_PAGE
      FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID
      IMPORTING E_DYNDOC_ID.

    METHODS : HANDLE_TOOLBAR
      FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT E_INTERACTIVE.

    METHODS : HANDLE_USER_COMMAND
      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM.

    METHODS : HANDLE_DATA_CHANGED
      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING ER_DATA_CHANGED E_ONF4. "E_UCOMM.

    METHODS : HANDLE_DATA_CHANGED_FINISHED
      FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED ET_GOOD_CELLS.

    METHODS : HANDLE_ONF4 FOR EVENT ONF4 OF CL_GUI_ALV_GRID
      IMPORTING SENDER
                E_FIELDNAME
                E_FIELDVALUE
                ES_ROW_NO
                ER_EVENT_DATA
                ET_BAD_CELLS
                E_DISPLAY.

    METHODS: HANDLE_BUTTON_CLICK
      FOR EVENT BUTTON_CLICK OF CL_GUI_ALV_GRID
      IMPORTING ES_COL_ID
                ES_ROW_NO.

    METHODS : HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW
                E_COLUMN
                ES_ROW_NO.

    METHODS : HANDLE_HOTSPOT_CLICK
      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID E_COLUMN_ID ES_ROW_NO.

    METHODS : HANDLE_CONTEXT_MENU
      FOR EVENT CONTEXT_MENU_REQUEST OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT.

ENDCLASS.

*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

  METHOD CONSTRUCTOR.
    CALL METHOD SUPER->CONSTRUCTOR.
    GV_OTEXT = E_OBJECT_TEXT.
  ENDMETHOD.

*----------------------------------------------------------------------*
* METHOD HANDLE_TOP_OF_PAGE
*----------------------------------------------------------------------*
  METHOD HANDLE_TOP_OF_PAGE.

  ENDMETHOD.

*----------------------------------------------------------------------*
* METHOD HANDLE_TOOLBAR
*----------------------------------------------------------------------*
  METHOD HANDLE_TOOLBAR.
*   PERFORM HANDLE_TOOLBAR USING E_OBJECT
*                                GV_OTEXT.
  ENDMETHOD.

*----------------------------------------------------------------------*
* METHOD HANDLE_USER_COMMAND
*----------------------------------------------------------------------*
  METHOD HANDLE_USER_COMMAND.
*   PERFORM HANDLE_USER_COMMAND USING E_UCOMM
*                                     GV_OTEXT.
  ENDMETHOD.

*----------------------------------------------------------------------*
* METHOD HANDLE_DATA_CHANGED
*----------------------------------------------------------------------*
  METHOD HANDLE_DATA_CHANGED.
*   PERFORM HANDLE_DATA_CHANGED USING ER_DATA_CHANGED
*                                     GV_OTEXT.
  ENDMETHOD.

*----------------------------------------------------------------------*
* METHOD HANDLE_DATA_CHANGED_FINISHED
*----------------------------------------------------------------------*
  METHOD HANDLE_DATA_CHANGED_FINISHED.
    PERFORM HANDLE_DATA_CHANGED_FINISHED USING E_MODIFIED
                                               ET_GOOD_CELLS
                                               GV_OTEXT.
  ENDMETHOD.

*----------------------------------------------------------------------*
* METHOD HANDLE_ONF4
*----------------------------------------------------------------------*
  METHOD HANDLE_ONF4.
*   PERFORM HANDLE_ONF4 USING E_FIELDNAME
*                             E_FIELDVALUE
*                             ES_ROW_NO
*                             ER_EVENT_DATA
*                             ET_BAD_CELLS
*                             E_DISPLAY
*                             GV_OTEXT.
  ENDMETHOD.

*----------------------------------------------------------------------*
* METHOD HANDLE_BUTTON_CLICK
*----------------------------------------------------------------------*
  METHOD HANDLE_BUTTON_CLICK.
  ENDMETHOD.

*----------------------------------------------------------------------*
* METHOD HANDLE_DOUBLE_CLICK
*----------------------------------------------------------------------*
  METHOD HANDLE_DOUBLE_CLICK.
*   PERFORM HANDLE_DOUBLE_CLICK USING E_ROW
*                                     E_COLUMN
*                                     ES_ROW_NO
*                                     GV_OTEXT.
  ENDMETHOD.

*----------------------------------------------------------------------*
* METHOD HANDLE_HOTSPOT_CLICK
*----------------------------------------------------------------------*
  METHOD HANDLE_HOTSPOT_CLICK.
*   PERFORM HANDLE_HOTSPOT_CLICK USING E_ROW_ID
*                                      E_COLUMN_ID
*                                      ES_ROW_NO
*                                      GV_OTEXT.
  ENDMETHOD.

  METHOD HANDLE_CONTEXT_MENU.
    CALL METHOD E_OBJECT->CLEAR.
  ENDMETHOD.

ENDCLASS.


DATA : GR_DOCK TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GR_GRID TYPE REF TO CL_GUI_ALV_GRID.

DATA : GT_EXCL TYPE UI_FUNCTIONS.

DATA : GS_LAYO TYPE LVC_S_LAYO,
       GS_VARI TYPE DISVARIANT.

DATA : GS_MODI TYPE LVC_S_MODI.

DATA : GT_FCAT TYPE LVC_T_FCAT,
       GS_FCAT TYPE LVC_S_FCAT.

DATA : GR_EVENTS TYPE REF TO LCL_EVENT_HANDLER.
