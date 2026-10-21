*&---------------------------------------------------------------------*
*& Include          ZGTSDR2010ALV
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INIT_CONTROLS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_CONTROLS_0100 .
  IF GO_GRID IS NOT INITIAL.
    CALL METHOD GO_GRID->FREE.
  ENDIF.
  IF GO_GCON1 IS NOT INITIAL.
    CALL METHOD GO_GCON1->FREE.
  ENDIF.
  IF GO_GCON2 IS NOT INITIAL.
    CALL METHOD GO_GCON2->FREE.
  ENDIF.
  IF GO_CCON IS NOT INITIAL.
    CALL METHOD GO_CCON->FREE.
  ENDIF.
  CLEAR: GO_GRID,GO_CCON,GO_GCON1,GO_GCON2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_ALV_GRID
*&---------------------------------------------------------------------*
FORM REFRESH_ALV  USING   PC_GRID
                         TYPE REF TO CL_GUI_ALV_GRID.
  DATA: LS_STABLE TYPE LVC_S_STBL.
  LS_STABLE-ROW = 'X'.
  LS_STABLE-COL = 'X'.
  IF PC_GRID IS NOT INITIAL.
    CALL METHOD PC_GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = LS_STABLE.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_CHANGED_DATA USING PC_GRID
                         TYPE REF TO CL_GUI_ALV_GRID.
  DATA LV_VALID TYPE CHAR01.

  CALL METHOD PC_GRID->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_VALID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_CONTROLS_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ALV_CONTROLS_0100 .
  IF GO_CCON IS INITIAL.
    PERFORM CREATE_CONTAINER_0100 USING GO_CCON 'CONT0100'.

    PERFORM SET_ALV_HEADER_0100.

    PERFORM CREATE_ALV_0100 USING GO_GCON2
                                  GO_GRID.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_CONTAINER_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_CCON
*&      --> P_
*&---------------------------------------------------------------------*
FORM CREATE_CONTAINER_0100  USING   PO_CCON TYPE REF TO
                                         CL_GUI_CUSTOM_CONTAINER
                                    P_CONT.

  CREATE OBJECT PO_CCON
    EXPORTING
      CONTAINER_NAME = P_CONT.

*-- Create Splitter
  CREATE OBJECT GO_SPLITTER
    EXPORTING
      PARENT  = PO_CCON
      ROWS    = 2
      COLUMNS = 1.

*-- Get top container as header
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_GCON1.

*-- Get bottom container as ALV grid
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_GCON2.

*-- Set height for header container
  CALL METHOD GO_SPLITTER->SET_ROW_MODE
    EXPORTING
      MODE = GO_SPLITTER->MODE_ABSOLUTE.


  CALL METHOD GO_SPLITTER->SET_ROW_HEIGHT
    EXPORTING
      ID     = 1
      HEIGHT = 70.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_HEADER_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ALV_HEADER_0100 .
  DATA: LO_TABLE TYPE REF TO CL_DD_TABLE_ELEMENT.
  DATA : LO_DOCU    TYPE REF TO CL_DD_DOCUMENT,
         LV_CONTENT TYPE STRING.
  DATA:  LV_STRING  TYPE STRING.
  DATA: LV_TEXT1(255),
        LV_TEXT2(255).
  DATA: LV_N        TYPE I.

*  DATA: LT_DATA TYPE TABLE OF ZSDS0240,
*        LS_DATA TYPE ZSDS0240.
  DATA: LV_STYLE TYPE SDYDO_ATTRIBUTE VALUE 'ALV_GRID',
        LV_ALIGN TYPE SDYDO_ATTRIBUTE VALUE 'left'.
  DATA: LV_COLCNT    TYPE I,
        LV_CURCOL    TYPE I,
        LV_GAP       TYPE I    VALUE '5',
        LV_LINES     TYPE I,
        LV_EXTENSION TYPE I,
        LV_DEFLEN    TYPE I,
        LV_BIGFONT   TYPE I,
        LV_CKWEB     TYPE C,
        LV_COLNO     TYPE I   VALUE '10',
        LV_CNTNO     TYPE P DECIMALS 2,
        LV_FONTSIZE  TYPE SDYDO_ATTRIBUTE.
  DATA: LO_TITLE1 TYPE REF TO CL_DD_AREA,
        LO_COLN1  TYPE REF TO CL_DD_AREA,
        LO_TEXT1  TYPE REF TO CL_DD_AREA,
        LO_TITLE2 TYPE REF TO CL_DD_AREA,
        LO_COLN2  TYPE REF TO CL_DD_AREA,
        LO_TEXT2  TYPE REF TO CL_DD_AREA,
        LO_TITLE3 TYPE REF TO CL_DD_AREA,
        LO_COLN3  TYPE REF TO CL_DD_AREA,
        LO_TEXT3  TYPE REF TO CL_DD_AREA,
        LO_TITLE4 TYPE REF TO CL_DD_AREA,
        LO_COLN4  TYPE REF TO CL_DD_AREA,
        LO_TEXT4  TYPE REF TO CL_DD_AREA,
        LO_TITLE5 TYPE REF TO CL_DD_AREA,
        LO_COLN5  TYPE REF TO CL_DD_AREA,
        LO_TEXT5  TYPE REF TO CL_DD_AREA,
        LO_TITLE6 TYPE REF TO CL_DD_AREA,
        LO_COLN6  TYPE REF TO CL_DD_AREA,
        LO_TEXT6  TYPE REF TO CL_DD_AREA,
        LO_TITLE7 TYPE REF TO CL_DD_AREA,
        LO_COLN7  TYPE REF TO CL_DD_AREA,
        LO_TEXT7  TYPE REF TO CL_DD_AREA,
        LO_TITLE8 TYPE REF TO CL_DD_AREA,
        LO_COLN8  TYPE REF TO CL_DD_AREA,
        LO_TEXT8  TYPE REF TO CL_DD_AREA,
        LO_TITLE9 TYPE REF TO CL_DD_AREA,
        LO_COLN9  TYPE REF TO CL_DD_AREA,
        LO_TEXT9  TYPE REF TO CL_DD_AREA,
        LO_TITLE10 TYPE REF TO CL_DD_AREA,
        LO_COLN10  TYPE REF TO CL_DD_AREA,
        LO_TEXT10  TYPE REF TO CL_DD_AREA.



  DATA: BEGIN OF LT_ALVTITLE OCCURS 0,
          TITLE TYPE CHAR35,
          COLN  TYPE CHAR35,
          TEXT  TYPE CHAR35,
        END OF LT_ALVTITLE.

  DATA: BEGIN OF LS_DATA,
          CODE01 TYPE CHAR255,
          COLN01 TYPE CHAR255,
          TEXT01 TYPE CHAR255,

          CODE02 TYPE CHAR255,
          COLN02 TYPE CHAR255,
          TEXT02 TYPE CHAR255,

          CODE03 TYPE CHAR255,
          COLN03 TYPE CHAR255,
          TEXT03 TYPE CHAR255,

          CODE04 TYPE CHAR255,
          COLN04 TYPE CHAR255,
          TEXT04 TYPE CHAR255,

          CODE05 TYPE CHAR255,
          COLN05 TYPE CHAR255,
          TEXT05 TYPE CHAR255,

          CODE06 TYPE CHAR255,
          COLN06 TYPE CHAR255,
          TEXT06 TYPE CHAR255,

          CODE07 TYPE CHAR255,
          COLN07 TYPE CHAR255,
          TEXT07 TYPE CHAR255,

          CODE08 TYPE CHAR255,
          COLN08 TYPE CHAR255,
          TEXT08 TYPE CHAR255,

          CODE09 TYPE CHAR255,
          COLN09 TYPE CHAR255,
          TEXT09 TYPE CHAR255,

          CODE10 TYPE CHAR255,
          COLN10 TYPE CHAR255,
          TEXT10 TYPE CHAR255,
        END OF LS_DATA.
  DATA: LT_DATA LIKE TABLE OF LS_DATA.
  FIELD-SYMBOLS: <LFS_TITLE> TYPE REF TO CL_DD_AREA,
                 <LFS_TEXT>  TYPE REF TO CL_DD_AREA,
                 <LFS_COLN>  TYPE REF TO CL_DD_AREA.

  CHECK GO_GCON1 IS NOT INITIAL.
  CLEAR: LS_DATA.
  LS_DATA-CODE01 = 'DBS'.
  LS_DATA-COLN01 = ':'.
  LS_DATA-TEXT01 = TEXT-T01.

  LS_DATA-CODE02 = 'GIC'.
  LS_DATA-COLN02 = ':'.
  LS_DATA-TEXT02 = TEXT-T02.


  LS_DATA-CODE03 = 'HDB'.
  LS_DATA-COLN03 = ':'.
  LS_DATA-TEXT03 = TEXT-T03.

  LS_DATA-CODE04 = 'BLD'.
  LS_DATA-COLN04 = ':'.
  LS_DATA-TEXT04 = TEXT-T04.
*  APPEND LS_DATA TO LT_DATA.
*
*  CLEAR: LS_DATA.
  LS_DATA-CODE05 = 'QT0'.
  LS_DATA-COLN05 = ':'.
  LS_DATA-TEXT05 = TEXT-T05.

  LS_DATA-CODE06 = 'WTU'.
  LS_DATA-COLN06 = ':'.
  LS_DATA-TEXT06 = TEXT-T06.

  CLEAR:LS_DATA-CODE07,
        LS_DATA-COLN07,
        LS_DATA-TEXT07.

  CLEAR:LS_DATA-CODE08,
        LS_DATA-COLN08,
        LS_DATA-TEXT08.
  APPEND LS_DATA TO LT_DATA.

  CLEAR: LS_DATA.
  LS_DATA-CODE01 = 'SGI'.
  LS_DATA-COLN01 = ':'.
  LS_DATA-TEXT01 = TEXT-T07.

  LS_DATA-CODE02 = 'SMV'.
  LS_DATA-COLN02 = ':'.
  LS_DATA-TEXT02 = TEXT-T08.

  LS_DATA-CODE03 = 'NDC'.
  LS_DATA-COLN03 = ':'.
  LS_DATA-TEXT03 = TEXT-T09.

  LS_DATA-CODE04 = 'BLC'.
  LS_DATA-COLN04 = ':'.
  LS_DATA-TEXT04 = TEXT-T10.


  LS_DATA-CODE05 = 'FGI'.
  LS_DATA-COLN05 = ':'.
  LS_DATA-TEXT05 = TEXT-T11.

  LS_DATA-CODE06 = 'FBL'.
  LS_DATA-COLN06 = ':'.
  LS_DATA-TEXT06 = TEXT-T12.


  CLEAR:LS_DATA-CODE07,
        LS_DATA-COLN07,
        LS_DATA-TEXT07.

  CLEAR:LS_DATA-CODE08,
        LS_DATA-COLN08,
        LS_DATA-TEXT08.
  APPEND LS_DATA TO LT_DATA.



*  CLEAR: LS_DATA.
*  LS_DATA-CODE01 = 'DBS'.
*  LS_DATA-COLN01 = ':'.
*  LS_DATA-TEXT01 = TEXT-T01.
*
*  LS_DATA-CODE02 = 'GIC'.
*  LS_DATA-COLN02 = ':'.
*  LS_DATA-TEXT02 = TEXT-T02.
*
*
*  LS_DATA-CODE03 = 'HDB'.
*  LS_DATA-COLN03 = ':'.
*  LS_DATA-TEXT03 = TEXT-T03.
*
*  LS_DATA-CODE04 = 'BLD'.
*  LS_DATA-COLN04 = ':'.
*  LS_DATA-TEXT04 = TEXT-T04.
*  APPEND LS_DATA TO LT_DATA.
*
*  CLEAR: LS_DATA.
*  LS_DATA-CODE01 = 'QT0'.
*  LS_DATA-COLN01 = ':'.
*  LS_DATA-TEXT01 = TEXT-T05.
*
*  LS_DATA-CODE02 = 'WTU'.
*  LS_DATA-COLN02 = ':'.
*  LS_DATA-TEXT02 = TEXT-T06.
*
*
*  LS_DATA-CODE03 = 'SGI'.
*  LS_DATA-COLN03 = ':'.
*  LS_DATA-TEXT03 = TEXT-T07.
*
*  LS_DATA-CODE04 = 'SMV'.
*  LS_DATA-COLN04 = ':'.
*  LS_DATA-TEXT04 = TEXT-T08.
*  APPEND LS_DATA TO LT_DATA.
*
*  CLEAR: LS_DATA.
*  LS_DATA-CODE01 = 'NDC'.
*  LS_DATA-COLN01 = ':'.
*  LS_DATA-TEXT01 = TEXT-T09.
*
*  LS_DATA-CODE02 = 'BLC'.
*  LS_DATA-COLN02 = ':'.
*  LS_DATA-TEXT02 = TEXT-T10.
*
*
*  LS_DATA-CODE03 = 'FGI'.
*  LS_DATA-COLN03 = ':'.
*  LS_DATA-TEXT03 = TEXT-T11.
*
*  LS_DATA-CODE04 = 'FBL'.
*  LS_DATA-COLN04 = ':'.
*  LS_DATA-TEXT04 = TEXT-T12.
*  APPEND LS_DATA TO LT_DATA.
*
*  CLEAR: LS_DATA.
*  CLEAR:LS_DATA-CODE05,
*        LS_DATA-COLN05,
*        LS_DATA-TEXT05.
*  APPEND LS_DATA TO LT_DATA.
*
*  CLEAR: LS_DATA.
*  CLEAR:LS_DATA-CODE06,
*        LS_DATA-COLN06,
*        LS_DATA-TEXT06.
*  APPEND LS_DATA TO LT_DATA.



  CALL FUNCTION 'WEBGUI_CHECK'
    IMPORTING
      WEBGUI_ACTIVE = LV_CKWEB.

  IF LV_CKWEB IS INITIAL.
    LV_DEFLEN = 10.
  ELSE.
    LV_DEFLEN = 4.
  ENDIF.
  LV_DEFLEN = LV_DEFLEN * 2.




  LV_CNTNO = LINES( LT_DATA ) / LV_COLNO.
  LV_LINES = CEIL( LV_CNTNO ).
  LV_EXTENSION = ( LV_LINES * LV_DEFLEN ) + 5.

  LV_COLCNT = LV_COLNO * 2.

  LV_FONTSIZE = CL_DD_AREA=>SMALL.

  CREATE OBJECT LO_DOCU
    EXPORTING
      STYLE = LV_STYLE.

  CALL METHOD LO_DOCU->INITIALIZE_DOCUMENT.

  CALL METHOD LO_DOCU->ADD_TABLE
    EXPORTING
      NO_OF_COLUMNS = LV_COLCNT
      BORDER        = '0'
    IMPORTING
      TABLE         = LO_TABLE.

  "SET COLUMN
  DO LV_COLNO TIMES.
    CLEAR LT_ALVTITLE.
    LT_ALVTITLE-TITLE = |LO_TITLE{ SY-INDEX }|.
    LT_ALVTITLE-COLN  = |LO_COLN{ SY-INDEX }|.
    LT_ALVTITLE-TEXT  = |LO_TEXT{ SY-INDEX }|.

    APPEND LT_ALVTITLE.
    IF <LFS_TITLE> IS ASSIGNED. UNASSIGN <LFS_TITLE>.ENDIF.
    IF <LFS_TEXT> IS ASSIGNED. UNASSIGN <LFS_TEXT>.ENDIF.
    IF <LFS_COLN> IS ASSIGNED. UNASSIGN <LFS_COLN>.ENDIF.
    ASSIGN (LT_ALVTITLE-TITLE) TO <LFS_TITLE>.
    ASSIGN (LT_ALVTITLE-TEXT)  TO <LFS_TEXT>.
    ASSIGN (LT_ALVTITLE-COLN)  TO <LFS_COLN>.

    "TITLE
    CALL METHOD LO_TABLE->ADD_COLUMN
      IMPORTING
        COLUMN = <LFS_TITLE>.
    ADD 1 TO LV_CURCOL.
    CALL METHOD LO_TABLE->SET_COLUMN_STYLE
      EXPORTING
        COL_NO       = LV_CURCOL
        SAP_ALIGN    = LV_ALIGN
        SAP_FONTSIZE = LV_FONTSIZE.

    ":
    CALL METHOD LO_TABLE->ADD_COLUMN
      IMPORTING
        COLUMN = <LFS_COLN>.
    ADD 1 TO LV_CURCOL.
    CALL METHOD LO_TABLE->SET_COLUMN_STYLE
      EXPORTING
        COL_NO       = LV_CURCOL
        SAP_ALIGN    = LV_ALIGN
        SAP_FONTSIZE = LV_FONTSIZE.

    "DESRIPTION
    CALL METHOD LO_TABLE->ADD_COLUMN
      IMPORTING
        COLUMN = <LFS_TEXT>.
    ADD 1 TO LV_CURCOL.
    CALL METHOD LO_TABLE->SET_COLUMN_STYLE
      EXPORTING
        COL_NO       = LV_CURCOL
        SAP_ALIGN    = LV_ALIGN
        SAP_FONTSIZE = LV_FONTSIZE.


  ENDDO.

  CLEAR LV_CURCOL.

  LOOP AT LT_DATA INTO LS_DATA.
    ADD 1 TO LV_CURCOL.
    READ TABLE LT_ALVTITLE INDEX LV_CURCOL.
    CHECK SY-SUBRC EQ 0.
    IF <LFS_TITLE> IS ASSIGNED. UNASSIGN <LFS_TITLE>.ENDIF.
    IF <LFS_TEXT> IS ASSIGNED. UNASSIGN <LFS_TEXT>.ENDIF.
    IF <LFS_COLN> IS ASSIGNED. UNASSIGN <LFS_COLN>.ENDIF.
    ASSIGN (LT_ALVTITLE-TITLE) TO <LFS_TITLE>.
    ASSIGN (LT_ALVTITLE-COLN)  TO <LFS_COLN>.
    ASSIGN (LT_ALVTITLE-TEXT)  TO <LFS_TEXT>.

    CALL METHOD <LFS_TITLE>->ADD_TEXT
      EXPORTING
        TEXT         = LS_DATA-CODE01
        SAP_EMPHASIS = 'Strong'.
    .
*    CALL METHOD <LFS_TITLE>->ADD_GAP
*      EXPORTING
*        WIDTH = LV_GAP.
    CALL METHOD <LFS_COLN>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-COLN01.

    CALL METHOD <LFS_TEXT>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-TEXT01.

    CALL METHOD <LFS_TEXT>->ADD_GAP
      EXPORTING
        WIDTH = LV_GAP.


    ADD 1 TO LV_CURCOL.
    READ TABLE LT_ALVTITLE INDEX LV_CURCOL.
    CHECK SY-SUBRC EQ 0.
    IF <LFS_TITLE> IS ASSIGNED. UNASSIGN <LFS_TITLE>.ENDIF.
    IF <LFS_TEXT> IS ASSIGNED. UNASSIGN <LFS_TEXT>.ENDIF.
    IF <LFS_COLN> IS ASSIGNED. UNASSIGN <LFS_COLN>.ENDIF.
    ASSIGN (LT_ALVTITLE-TITLE) TO <LFS_TITLE>.
    ASSIGN (LT_ALVTITLE-COLN)  TO <LFS_COLN>.
    ASSIGN (LT_ALVTITLE-TEXT)  TO <LFS_TEXT>.

    CALL METHOD <LFS_TITLE>->ADD_TEXT
      EXPORTING
        TEXT         = LS_DATA-CODE02
        SAP_EMPHASIS = 'Strong'.
    .

*    CALL METHOD <LFS_TITLE>->ADD_GAP
*      EXPORTING
*        WIDTH = LV_GAP.
    CALL METHOD <LFS_COLN>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-COLN02.

    CALL METHOD <LFS_TEXT>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-TEXT02.

    CALL METHOD <LFS_TEXT>->ADD_GAP
      EXPORTING
        WIDTH = LV_GAP.


    ADD 1 TO LV_CURCOL.
    READ TABLE LT_ALVTITLE INDEX LV_CURCOL.
    CHECK SY-SUBRC EQ 0.
    IF <LFS_TITLE> IS ASSIGNED. UNASSIGN <LFS_TITLE>.ENDIF.
    IF <LFS_TEXT> IS ASSIGNED. UNASSIGN <LFS_TEXT>.ENDIF.
    IF <LFS_COLN> IS ASSIGNED. UNASSIGN <LFS_COLN>.ENDIF.
    ASSIGN (LT_ALVTITLE-TITLE) TO <LFS_TITLE>.
    ASSIGN (LT_ALVTITLE-COLN)  TO <LFS_COLN>.
    ASSIGN (LT_ALVTITLE-TEXT)  TO <LFS_TEXT>.

    CALL METHOD <LFS_TITLE>->ADD_TEXT
      EXPORTING
        TEXT         = LS_DATA-CODE03
        SAP_EMPHASIS = 'Strong'.
    .

    CALL METHOD <LFS_COLN>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-COLN03.

    CALL METHOD <LFS_TEXT>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-TEXT03.

    CALL METHOD <LFS_TEXT>->ADD_GAP
      EXPORTING
        WIDTH = LV_GAP.

    ADD 1 TO LV_CURCOL.
    READ TABLE LT_ALVTITLE INDEX LV_CURCOL.
    CHECK SY-SUBRC EQ 0.
    IF <LFS_TITLE> IS ASSIGNED. UNASSIGN <LFS_TITLE>.ENDIF.
    IF <LFS_TEXT> IS ASSIGNED. UNASSIGN <LFS_TEXT>.ENDIF.
    IF <LFS_COLN> IS ASSIGNED. UNASSIGN <LFS_COLN>.ENDIF.
    ASSIGN (LT_ALVTITLE-TITLE) TO <LFS_TITLE>.
    ASSIGN (LT_ALVTITLE-COLN)  TO <LFS_COLN>.
    ASSIGN (LT_ALVTITLE-TEXT)  TO <LFS_TEXT>.

    CALL METHOD <LFS_TITLE>->ADD_TEXT
      EXPORTING
        TEXT         = LS_DATA-CODE04
        SAP_EMPHASIS = 'Strong'.
    .

*    CALL METHOD <LFS_TITLE>->ADD_GAP
*      EXPORTING
*        WIDTH = LV_GAP.
    CALL METHOD <LFS_COLN>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-COLN04.

    CALL METHOD <LFS_TEXT>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-TEXT04.

    CALL METHOD <LFS_TEXT>->ADD_GAP
      EXPORTING
        WIDTH = LV_GAP.

    ADD 1 TO LV_CURCOL.
    READ TABLE LT_ALVTITLE INDEX LV_CURCOL.
    CHECK SY-SUBRC EQ 0.
    IF <LFS_TITLE> IS ASSIGNED. UNASSIGN <LFS_TITLE>.ENDIF.
    IF <LFS_TEXT> IS ASSIGNED. UNASSIGN <LFS_TEXT>.ENDIF.
    IF <LFS_COLN> IS ASSIGNED. UNASSIGN <LFS_COLN>.ENDIF.
    ASSIGN (LT_ALVTITLE-TITLE) TO <LFS_TITLE>.
    ASSIGN (LT_ALVTITLE-COLN)  TO <LFS_COLN>.
    ASSIGN (LT_ALVTITLE-TEXT)  TO <LFS_TEXT>.

    CALL METHOD <LFS_TITLE>->ADD_TEXT
      EXPORTING
        TEXT         = LS_DATA-CODE05
        SAP_EMPHASIS = 'Strong'.
    .

*    CALL METHOD <LFS_TITLE>->ADD_GAP
*      EXPORTING
*        WIDTH = LV_GAP.
    CALL METHOD <LFS_COLN>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-COLN05.

    CALL METHOD <LFS_TEXT>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-TEXT05.

    CALL METHOD <LFS_TEXT>->ADD_GAP
      EXPORTING
        WIDTH = LV_GAP.

    ADD 1 TO LV_CURCOL.
    READ TABLE LT_ALVTITLE INDEX LV_CURCOL.
    CHECK SY-SUBRC EQ 0.
    IF <LFS_TITLE> IS ASSIGNED. UNASSIGN <LFS_TITLE>.ENDIF.
    IF <LFS_TEXT> IS ASSIGNED. UNASSIGN <LFS_TEXT>.ENDIF.
    IF <LFS_COLN> IS ASSIGNED. UNASSIGN <LFS_COLN>.ENDIF.
    ASSIGN (LT_ALVTITLE-TITLE) TO <LFS_TITLE>.
    ASSIGN (LT_ALVTITLE-COLN)  TO <LFS_COLN>.
    ASSIGN (LT_ALVTITLE-TEXT)  TO <LFS_TEXT>.

    CALL METHOD <LFS_TITLE>->ADD_TEXT
      EXPORTING
        TEXT         = LS_DATA-CODE06
        SAP_EMPHASIS = 'Strong'.
    .

*    CALL METHOD <LFS_TITLE>->ADD_GAP
*      EXPORTING
*        WIDTH = LV_GAP.
    CALL METHOD <LFS_COLN>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-COLN06.

    CALL METHOD <LFS_TEXT>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-TEXT06.

    CALL METHOD <LFS_TEXT>->ADD_GAP
      EXPORTING
        WIDTH = LV_GAP.


    ADD 1 TO LV_CURCOL.
    READ TABLE LT_ALVTITLE INDEX LV_CURCOL.
    CHECK SY-SUBRC EQ 0.
    IF <LFS_TITLE> IS ASSIGNED. UNASSIGN <LFS_TITLE>.ENDIF.
    IF <LFS_TEXT> IS ASSIGNED. UNASSIGN <LFS_TEXT>.ENDIF.
    IF <LFS_COLN> IS ASSIGNED. UNASSIGN <LFS_COLN>.ENDIF.
    ASSIGN (LT_ALVTITLE-TITLE) TO <LFS_TITLE>.
    ASSIGN (LT_ALVTITLE-COLN)  TO <LFS_COLN>.
    ASSIGN (LT_ALVTITLE-TEXT)  TO <LFS_TEXT>.

    CALL METHOD <LFS_TITLE>->ADD_TEXT
      EXPORTING
        TEXT         = LS_DATA-CODE07
        SAP_EMPHASIS = 'Strong'.
    .

*    CALL METHOD <LFS_TITLE>->ADD_GAP
*      EXPORTING
*        WIDTH = LV_GAP.
    CALL METHOD <LFS_COLN>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-COLN07.

    CALL METHOD <LFS_TEXT>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-TEXT07.

    CALL METHOD <LFS_TEXT>->ADD_GAP
      EXPORTING
        WIDTH = LV_GAP.

    ADD 1 TO LV_CURCOL.
    READ TABLE LT_ALVTITLE INDEX LV_CURCOL.
    CHECK SY-SUBRC EQ 0.
    IF <LFS_TITLE> IS ASSIGNED. UNASSIGN <LFS_TITLE>.ENDIF.
    IF <LFS_TEXT> IS ASSIGNED. UNASSIGN <LFS_TEXT>.ENDIF.
    IF <LFS_COLN> IS ASSIGNED. UNASSIGN <LFS_COLN>.ENDIF.
    ASSIGN (LT_ALVTITLE-TITLE) TO <LFS_TITLE>.
    ASSIGN (LT_ALVTITLE-COLN)  TO <LFS_COLN>.
    ASSIGN (LT_ALVTITLE-TEXT)  TO <LFS_TEXT>.

    CALL METHOD <LFS_TITLE>->ADD_TEXT
      EXPORTING
        TEXT         = LS_DATA-CODE08
        SAP_EMPHASIS = 'Strong'.
    .

*    CALL METHOD <LFS_TITLE>->ADD_GAP
*      EXPORTING
*        WIDTH = LV_GAP.
    CALL METHOD <LFS_COLN>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-COLN08.

    CALL METHOD <LFS_TEXT>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-TEXT08.

    CALL METHOD <LFS_TEXT>->ADD_GAP
      EXPORTING
        WIDTH = LV_GAP.

    ADD 1 TO LV_CURCOL.
    READ TABLE LT_ALVTITLE INDEX LV_CURCOL.
    CHECK SY-SUBRC EQ 0.
    IF <LFS_TITLE> IS ASSIGNED. UNASSIGN <LFS_TITLE>.ENDIF.
    IF <LFS_TEXT> IS ASSIGNED. UNASSIGN <LFS_TEXT>.ENDIF.
    IF <LFS_COLN> IS ASSIGNED. UNASSIGN <LFS_COLN>.ENDIF.
    ASSIGN (LT_ALVTITLE-TITLE) TO <LFS_TITLE>.
    ASSIGN (LT_ALVTITLE-COLN)  TO <LFS_COLN>.
    ASSIGN (LT_ALVTITLE-TEXT)  TO <LFS_TEXT>.

    CALL METHOD <LFS_TITLE>->ADD_TEXT
      EXPORTING
        TEXT         = LS_DATA-CODE09
        SAP_EMPHASIS = 'Strong'.
    .

*    CALL METHOD <LFS_TITLE>->ADD_GAP
*      EXPORTING
*        WIDTH = LV_GAP.
    CALL METHOD <LFS_COLN>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-COLN09.

    CALL METHOD <LFS_TEXT>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-TEXT09.

    CALL METHOD <LFS_TEXT>->ADD_GAP
      EXPORTING
        WIDTH = LV_GAP.

    ADD 1 TO LV_CURCOL.
    READ TABLE LT_ALVTITLE INDEX LV_CURCOL.
    CHECK SY-SUBRC EQ 0.
    IF <LFS_TITLE> IS ASSIGNED. UNASSIGN <LFS_TITLE>.ENDIF.
    IF <LFS_TEXT> IS ASSIGNED. UNASSIGN <LFS_TEXT>.ENDIF.
    IF <LFS_COLN> IS ASSIGNED. UNASSIGN <LFS_COLN>.ENDIF.
    ASSIGN (LT_ALVTITLE-TITLE) TO <LFS_TITLE>.
    ASSIGN (LT_ALVTITLE-COLN)  TO <LFS_COLN>.
    ASSIGN (LT_ALVTITLE-TEXT)  TO <LFS_TEXT>.

    CALL METHOD <LFS_TITLE>->ADD_TEXT
      EXPORTING
        TEXT         = LS_DATA-CODE10
        SAP_EMPHASIS = 'Strong'.
    .

*    CALL METHOD <LFS_TITLE>->ADD_GAP
*      EXPORTING
*        WIDTH = LV_GAP.
    CALL METHOD <LFS_COLN>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-COLN10.

    CALL METHOD <LFS_TEXT>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-TEXT10.

    CALL METHOD <LFS_TEXT>->ADD_GAP
      EXPORTING
        WIDTH = LV_GAP.



    CHECK LV_CURCOL = LV_COLNO.
    CLEAR LV_CURCOL.
    CALL METHOD LO_TABLE->NEW_ROW.
  ENDLOOP.

  LO_DOCU->MERGE_DOCUMENT( ).
  LO_DOCU->DISPLAY_DOCUMENT( PARENT = GO_GCON1 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GCON2
*&      --> GO_GRID
*&---------------------------------------------------------------------*
FORM CREATE_ALV_0100  USING    PO_GCON TYPE REF TO
                                 CL_GUI_CONTAINER
                               PO_GRID TYPE REF TO
                                 CL_GUI_ALV_GRID.

  CREATE OBJECT PO_GRID
    EXPORTING
      I_PARENT      = PO_GCON
      I_APPL_EVENTS = 'X'.

* Set Variant
  PERFORM SET_VARIANT_0100.

* SET LAYOUT
  PERFORM SET_LAYOUT_0100.

* SET SORT
  PERFORM SET_SORT_0100.

* SET FIELDCAT
  PERFORM SET_FIELDCAT_0100.

* Set Event Handler
  PERFORM SET_EVENT_HANDLER_0100 USING GO_GRID.

* EXCLUDING TOOLBAR
  CLEAR: GT_EXCLUDE[].
  PERFORM EXCLUDE_TB_FUNCTIONS_0100 USING 'GT_EXCLUDE'.

* CELL ATTRIBUTES
  PERFORM CELL_ATTRIBUTES_0100.

* ALV GRID
  PERFORM DISPLAY_ALV_0100.

* F4
  PERFORM SET_F4_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_VARIANT_0100 .
  CLEAR : GS_VARIANT.

  GS_VARIANT-REPORT   = SY-REPID.
  GS_VARIANT-USERNAME = SY-UNAME.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_0100 .
  CLEAR: GS_LAYOUT.
  GS_LAYOUT-ZEBRA        = GC_X.
*  GS_LAYOUT-EDIT         = GC_X.
*  GS_LAYOUT-CWIDTH_OPT   = GC_X.
  GS_LAYOUT-SEL_MODE     = 'D'.      "선택모드
  GS_LAYOUT-SMALLTITLE   = GC_X.
*  GS_LAYOUT-GRID_TITLE   = GV_GRID_TITLE.

*  GS_LAYOUT-NO_ROWMARK   = GC_X.      "선택버튼제거.
  GS_LAYOUT-STYLEFNAME   = 'CELLTAB'.
*  GS_LAYOUT-CTAB_FNAME   = 'CELLCOL'.
*  GS_LAYOUT-INFO_FNAME = 'LINECOL'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORT_0100 .
  DATA: LV_SPOS  TYPE SLIS_SPOS.
  CLEAR: GT_SORT[].

*  CLEAR GS_SORT.
*  LV_SPOS = LV_SPOS + 1.
*  GS_SORT-SPOS = LV_SPOS.
*  GS_SORT-FIELDNAME = 'CRDAT'.
*  GS_SORT-DOWN = GC_X.
*  APPEND GS_SORT TO GT_SORT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_0100 .
  CLEAR: GT_FIELDCAT[].

  PERFORM CREATE_FIELDCAT USING 'GT_0100'
                                GT_FIELDCAT.

  PERFORM MODIFY_FIELDCAT_0100 USING GT_FIELDCAT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GT_FIELDCAT
*&---------------------------------------------------------------------*
FORM CREATE_FIELDCAT  USING    P_TABNAME
                               PT_FIELDCAT TYPE LVC_T_FCAT.
  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE.
  DATA : LV_INTERNAL_TABNAME TYPE  SLIS_TABNAME,
         LV_STRUCTURE_NAME   LIKE  DD02L-TABNAME,
         LV_INCLNAME         LIKE  TRDIR-NAME.

  DATA : LV_TABLE TYPE FELD-NAME.
  FIELD-SYMBOLS <FS_TABLE> TYPE STANDARD TABLE.

  CONCATENATE P_TABNAME '[]' INTO LV_TABLE.
  ASSIGN (LV_TABLE) TO <FS_TABLE>.

  CLEAR : LV_INTERNAL_TABNAME, LV_INCLNAME.
  LV_INTERNAL_TABNAME = P_TABNAME.      " 인터널 데이블
  LV_INCLNAME         = |{ SY-REPID }TOP|.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = LV_INTERNAL_TABNAME
      I_INCLNAME         = LV_INCLNAME
      I_BYPASSING_BUFFER = 'X'
*     I_STRUCTURE_NAME   = I_INTERNAL_TABNAME
    CHANGING
      CT_FIELDCAT        = LT_FCAT[].

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT[]
    IMPORTING
      ET_FIELDCAT_LVC = PT_FIELDCAT[]
    TABLES
      IT_DATA         = <FS_TABLE>.

  CALL FUNCTION 'LVC_FIELDCAT_COMPLETE'
    EXPORTING
      I_REFRESH_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT      = PT_FIELDCAT.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIELDCAT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FIELDCAT
*&---------------------------------------------------------------------*
FORM MODIFY_FIELDCAT_0100  USING   PT_FIELDCAT TYPE LVC_T_FCAT.

  LOOP AT PT_FIELDCAT INTO GS_FIELDCAT.
    CASE GS_FIELDCAT-FIELDNAME.
      WHEN 'STAT'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H43.
      WHEN 'SEL'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-CHECKBOX = GC_X.
        GS_FIELDCAT-EDIT     = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H01.
      WHEN 'ST_FINAL'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H02.
      WHEN 'BUTN'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        PERFORM SET_TEXT USING TEXT-H03.
        GS_FIELDCAT-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
        GS_FIELDCAT-OUTPUTLEN = 6.
      WHEN 'ST_STSH'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 6.
        PERFORM SET_TEXT USING TEXT-H04.
      WHEN 'ST_DBS'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        GS_FIELDCAT-EMPHASIZE = 'C500'.
        PERFORM SET_TEXT USING TEXT-H06.
      WHEN 'ST_GIC'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H07.
      WHEN 'ST_HDB'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H08.
      WHEN 'ST_BLD'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H09.
      WHEN 'ST_QT0'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H10.
      WHEN 'ST_WTU'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H11.
      WHEN 'ST_SGI'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H12.
      WHEN 'ST_SMV'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H13.
      WHEN 'ST_NDC'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H14.
      WHEN 'ST_BLC'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H15.
      WHEN 'ST_FGI'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H16.
      WHEN 'ST_FBL'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H17.
      WHEN 'VBELN_VA'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 11.
        PERFORM SET_TEXT USING TEXT-H97.
      WHEN 'VBELN_VL'.
        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 11.
        PERFORM SET_TEXT USING TEXT-H18.
      WHEN 'KUNWE'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H19.
      WHEN 'KUNWE_NM'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H20.
      WHEN 'WADAT'.
        GS_FIELDCAT-OUTPUTLEN = 11.
        PERFORM SET_TEXT USING TEXT-H21.
      WHEN 'WADAT_IST'.
        GS_FIELDCAT-OUTPUTLEN = 11.
        PERFORM SET_TEXT USING TEXT-H22.
      WHEN 'NETWR_INI'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        GS_FIELDCAT-EMPHASIZE = 'C310'.
        PERFORM SET_TEXT USING TEXT-H23.
      WHEN 'NETWR_DW'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        GS_FIELDCAT-EMPHASIZE = 'C310'.
        PERFORM SET_TEXT USING TEXT-H24.
      WHEN 'NETWR_JS'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        GS_FIELDCAT-EMPHASIZE = 'C310'.
        PERFORM SET_TEXT USING TEXT-H25.
      WHEN 'WAERK'.
        GS_FIELDCAT-OUTPUTLEN = 4.
        PERFORM SET_TEXT USING TEXT-H26.
      WHEN 'KUNNR'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H27.
      WHEN 'KUNNR_NM'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H28.
      WHEN 'LFART'.
        GS_FIELDCAT-OUTPUTLEN = 8.
        PERFORM SET_TEXT USING TEXT-H29.
      WHEN 'AUART'.
        GS_FIELDCAT-OUTPUTLEN = 4.
        PERFORM SET_TEXT USING TEXT-H30.
      WHEN 'BSTNK'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H31.
      WHEN 'VSTEL'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H32.
      WHEN 'VSTEL_NM'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H33.
      WHEN 'VKORG'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H34.
      WHEN 'VTWEG'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H35.
      WHEN 'SPART'.
        GS_FIELDCAT-OUTPUTLEN = 4.
        PERFORM SET_TEXT USING TEXT-H36.
      WHEN 'VKBUR'.
        GS_FIELDCAT-OUTPUTLEN = 4.
        PERFORM SET_TEXT USING TEXT-H37.
      WHEN 'VKBUR_NM'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H38.
      WHEN 'VKGRP'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H39.
      WHEN 'VKGRP_NM'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H40.
      WHEN 'TKNUM'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H41.
      WHEN 'MESSAGE'.
        GS_FIELDCAT-OUTPUTLEN = 100.
        PERFORM SET_TEXT USING TEXT-H42.

      WHEN OTHERS.
        GS_FIELDCAT-NO_OUT = GC_X.
    ENDCASE.
    MODIFY PT_FIELDCAT FROM GS_FIELDCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TEXT_H00
*&---------------------------------------------------------------------*
FORM SET_TEXT  USING    P_TEXT.
  GS_FIELDCAT-SCRTEXT_S =
  GS_FIELDCAT-SCRTEXT_M =
  GS_FIELDCAT-SCRTEXT_L =
  GS_FIELDCAT-COLTEXT   =
  GS_FIELDCAT-SELTEXT   =
  GS_FIELDCAT-TOOLTIP   = P_TEXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_HANDLER_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID
*&---------------------------------------------------------------------*
FORM SET_EVENT_HANDLER_0100  USING  PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_RECEIVER IS INITIAL.
    CREATE OBJECT GO_EVENT_RECEIVER.
  ENDIF.

*  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
*    EXPORTING
*      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.
*
  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.


  SET HANDLER GO_EVENT_RECEIVER->HANDLE_DATA_CHANGED     FOR PO_GRID .
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_CHANGED_FINISHED FOR PO_GRID.
*  SET HANDLER GO_EVENT_RECEIVER->HANDLE_SUBTOTAL_TEXT    FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_DOUBLE_CLICK     FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK    FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_TOOLBAR          FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_USER_COMMAND     FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_ONF4             FOR PO_GRID.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_BUTTON_CLICK     FOR PO_GRID.
*  SET HANDLER GO_EVENT_RECEIVER->HANDLE_TOP_OF_PAGE   FOR PA_GRID.

*  IF GV_EDIT IS NOT INITIAL.
  CALL METHOD PO_GRID->SET_READY_FOR_INPUT
    EXPORTING
      I_READY_FOR_INPUT = 1.
*
*  ELSE.
*    CALL METHOD PO_GRID->SET_READY_FOR_INPUT
*      EXPORTING
*        I_READY_FOR_INPUT = 0.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTIONS_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS_0100  USING    P_TABNAME.
*  툴바의 버튼중 나타내지 않을 버튼을 지정한다.
  FIELD-SYMBOLS : <TABLE> TYPE UI_FUNCTIONS.

  DATA : LS_EXCLUDE   TYPE UI_FUNC.
  DATA : L_TABLE_NAME LIKE FELD-NAME.

  CONCATENATE P_TABNAME '[]' INTO  L_TABLE_NAME.
  ASSIGN     (L_TABLE_NAME)    TO <TABLE>.

  PERFORM APPEND_EXCLUDE_FUNCTIONS
        TABLES <TABLE>
*        USING : cl_gui_alv_grid=>mc_fc_excl_all. " ** 툴바 모두제거 **
         USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO, " 실행취소 &LOCAL&UNDO
*                cl_gui_alv_grid=>mc_fc_auf,      " 소계확장 &AUF
*                cl_gui_alv_grid=>mc_fc_average,  " &AVERAGE
*                cl_gui_alv_grid=>mc_fc_back_classic,
*                cl_gui_alv_grid=>mc_fc_call_abc, " &ABC
*                cl_gui_alv_grid=>mc_fc_call_chain,
*                cl_gui_alv_grid=>mc_fc_call_crbatch,
*                cl_gui_alv_grid=>mc_fc_call_crweb,
*                cl_gui_alv_grid=>mc_fc_call_lineitems,
*                cl_gui_alv_grid=>mc_fc_call_master_data,
*                cl_gui_alv_grid=>mc_fc_call_more,
*                cl_gui_alv_grid=>mc_fc_call_report,
*                cl_gui_alv_grid=>mc_fc_call_xint,
*                cl_gui_alv_grid=>mc_fc_call_xxl,
*                cl_gui_alv_grid=>mc_fc_col_invisible,
*                cl_gui_alv_grid=>mc_fc_col_optimize,
*                cl_gui_alv_grid=>mc_fc_current_variant,
*                cl_gui_alv_grid=>mc_fc_data_save,
*                cl_gui_alv_grid=>mc_fc_delete_filter,
*                cl_gui_alv_grid=>mc_fc_deselect_all,
*                cl_gui_alv_grid=>mc_fc_detail,
*                cl_gui_alv_grid=>mc_fc_expcrdata,
*                cl_gui_alv_grid=>mc_fc_expcrdesig,
*                cl_gui_alv_grid=>mc_fc_expcrtempl,
*                cl_gui_alv_grid=>mc_fc_expmdb,
*                cl_gui_alv_grid=>mc_fc_extend,
*                cl_gui_alv_grid=>mc_fc_f4,
*                cl_gui_alv_grid=>mc_fc_filter,
*                cl_gui_alv_grid=>mc_fc_find,
*                cl_gui_alv_grid=>mc_fc_fix_columns,
*                cl_gui_alv_grid=>mc_fc_graph,
*                cl_gui_alv_grid=>mc_fc_help,
*                cl_gui_alv_grid=>mc_fc_info,
*                cl_gui_alv_grid=>mc_fc_load_variant,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,          " 행 카피.
                CL_GUI_ALV_GRID=>MC_FC_HTML,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,      " 행 카피.
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,           " 가위.
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,    " 행삭제.
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,    " 행삽입.
                CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,    " 라인생성.
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,         " 겹쳐쓰기.
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW, " 겹쳐쓰기.
*                cl_gui_alv_grid=>mc_fc_maintain_variant,
*                cl_gui_alv_grid=>mc_fc_maximum,
*                cl_gui_alv_grid=>mc_fc_minimum,
*                cl_gui_alv_grid=>mc_fc_pc_file,
*                cl_gui_alv_grid=>mc_fc_print,
*                cl_gui_alv_grid=>mc_fc_print_back,
*                cl_gui_alv_grid=>mc_fc_print_prev,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.
*                cl_gui_alv_grid=>mc_fc_reprep,
*                cl_gui_alv_grid=>mc_fc_save_variant,
*                cl_gui_alv_grid=>mc_fc_select_all,
*                cl_gui_alv_grid=>mc_fc_send,
*                cl_gui_alv_grid=>mc_fc_separator,
*                CL_GUI_ALV_GRID=>MC_FC_SORT,
*                CL_GUI_ALV_GRID=>MC_FC_SORT_ASC,
*                CL_GUI_ALV_GRID=>MC_FC_SORT_DSC.
*                CL_GUI_ALV_GRID=>MC_FC_SUBTOT,
*                CL_GUI_ALV_GRID=>MC_FC_SUM
*                cl_gui_alv_grid=>mc_fc_to_office,
*                cl_gui_alv_grid=>mc_fc_to_rep_tree,
*                cl_gui_alv_grid=>mc_fc_unfix_columns,
*                cl_gui_alv_grid=>mc_fc_views,
*                cl_gui_alv_grid=>mc_fc_view_crystal,
*                cl_gui_alv_grid=>mc_fc_view_excel,
*                cl_gui_alv_grid=>mc_fc_view_grid,
*                cl_gui_alv_grid=>mc_fc_word_processor.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_EXCLUDE_FUNCTIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <TABLE>
*&      --> CL_GUI_ALV_GRID=>MC_FC_LOC_UND
*&---------------------------------------------------------------------*
FORM APPEND_EXCLUDE_FUNCTIONS  TABLES P_TABLE
                                USING P_VALUE.
  DATA : LS_EXCLUDE TYPE UI_FUNC.
  LS_EXCLUDE = P_VALUE.
  APPEND LS_EXCLUDE TO P_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_0100 .
  CALL METHOD GO_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IS_VARIANT           = GS_VARIANT
      I_SAVE               = 'A'
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE[]
      I_BYPASSING_BUFFER   = 'X'
    CHANGING
      IT_OUTTAB            = GT_0100[]
      IT_FIELDCATALOG      = GT_FIELDCAT[]
      IT_SORT              = GT_SORT[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_F4_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_F4_0100 .
** F4 FIELD 등록.
** 주의할점-필드명을 ABC순으로 기술하여야 함
*  CLEAR:GT_F4[].
*
*  CLEAR GS_F4.
*  GS_F4-FIELDNAME = 'ZTERM'.
*  GS_F4-REGISTER  = GC_X.
*  APPEND GS_F4 TO GT_F4.
*
*  CALL METHOD GO_GRID->REGISTER_F4_FOR_FIELDS
*    EXPORTING
*      IT_F4 = GT_F4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CELL_ATTRIBUTES_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CELL_ATTRIBUTES_0100 .
*  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>).
*    PERFORM SET_ATTRIBUTES_LINE CHANGING <FS_LIST>.
*  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_CONTROLS_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ALV_CONTROLS_0200 .
  IF GO_CCON2 IS INITIAL.
* CONTAINER/SPLITTER
    PERFORM SET_CUSTOM_CONTAINER    USING 'CONT0200'
                                          2 1 2000
                                 CHANGING GO_CCON2 GO_SPLITTER2.

    PERFORM SET_ALV_CONTAINER    USING GO_SPLITTER2 1 1
                                   CHANGING GO_GCON1.

    PERFORM SET_ALV_CONTAINER    USING GO_SPLITTER2 2 1
                                     CHANGING GO_GCON2.

    PERFORM SET_ALV_GRID USING GO_SPLITTER2 1 1 50 1000
                            GO_GCON1
                    CHANGING GO_GRID1.

    PERFORM SET_ALV_GRID USING GO_SPLITTER2 2 1 50 1000
                            GO_GCON2
                    CHANGING GO_GRID2.

    PERFORM CREATE_ALV_0200.
  ENDIF.

  CALL METHOD CL_GUI_CFW=>FLUSH.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CUSTOM_CONTAINER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_1
*&      --> P_2
*&      --> P_2000
*&      <-- GO_CCON2
*&      <-- GO_SPLITTER2
*&---------------------------------------------------------------------*
FORM SET_CUSTOM_CONTAINER  USING    P_CON_NAME
                                P_ROWS
                                P_COLUMNS
                                P_EXTENSION
                          CHANGING P_CUSTOM TYPE REF TO CL_GUI_CUSTOM_CONTAINER
                                   PC_SPLITTER TYPE REF TO CL_GUI_SPLITTER_CONTAINER.

  CHECK P_CUSTOM IS INITIAL.
  CREATE OBJECT P_CUSTOM
    EXPORTING
      CONTAINER_NAME = P_CON_NAME.

  CREATE OBJECT PC_SPLITTER
    EXPORTING
      PARENT            = P_CUSTOM
      ROWS              = P_ROWS
      COLUMNS           = P_COLUMNS
    EXCEPTIONS
      CNTL_ERROR        = 1
      CNTL_SYSTEM_ERROR = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_CONTAINER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_SPLITTER2
*&      --> P_1
*&      --> P_1
*&      <-- GO_GCON1
*&---------------------------------------------------------------------*
FORM SET_ALV_CONTAINER  USING    PC_SPLITTER TYPE REF TO CL_GUI_SPLITTER_CONTAINER
                                 P_ROWS
                                 P_COLUMNS
                            CHANGING PC_CONTAINER TYPE REF TO CL_GUI_CONTAINER.
  CALL METHOD PC_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = P_ROWS
      COLUMN    = P_COLUMNS
    RECEIVING
      CONTAINER = PC_CONTAINER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_SPLITTER2
*&      --> P_1
*&      --> P_1
*&      --> P_50
*&      --> P_1000
*&      --> GO_GCON1
*&      <-- GO_GRID1
*&---------------------------------------------------------------------*
FORM SET_ALV_GRID  USING    PC_SPLITTER TYPE REF TO CL_GUI_SPLITTER_CONTAINER
                     P_ROWS
                     P_COLUMNS
                     P_HEIGHT
                     P_WIDTH
                     PC_CONTAINER TYPE REF TO CL_GUI_CONTAINER
              CHANGING PC_GRID TYPE REF TO CL_GUI_ALV_GRID.

  CALL METHOD PC_SPLITTER->SET_ROW_SASH
    EXPORTING
      ID    = P_ROWS
      TYPE  = 1
      VALUE = 1.

  CALL METHOD PC_SPLITTER->SET_ROW_HEIGHT
    EXPORTING
      ID     = P_ROWS
      HEIGHT = P_HEIGHT.
  "## ##
  CALL METHOD PC_SPLITTER->SET_COLUMN_WIDTH
    EXPORTING
      ID    = P_ROWS
      WIDTH = P_WIDTH.

  CREATE OBJECT PC_GRID
    EXPORTING
      I_PARENT = PC_CONTAINER
      I_APPL_EVENTS = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ALV_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_ALV_0200 .
  PERFORM CREATE_ALV_0200_TOP USING GO_GRID1.
  PERFORM CREATE_ALV_0200_BOT USING GO_GRID2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ALV_0200_TOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID1
*&---------------------------------------------------------------------*
FORM CREATE_ALV_0200_TOP  USING   PC_GRID TYPE REF TO CL_GUI_ALV_GRID.
* Set Variant
  PERFORM SET_VARIANT_0200 USING PC_GRID.
* SET LAYOUT
  PERFORM SET_LAYOUT_0200 USING PC_GRID.
* SET SORT
  PERFORM SET_SORT_0200 USING PC_GRID.
* SET FIELDCAT
  PERFORM SET_FIELDCAT_0200 USING PC_GRID.
* Set Event Handler
  PERFORM SET_EVENT_HANDLER_0100 USING PC_GRID.
* EXCLUDING TOOLBAR
  CLEAR: GT_EXCLUDE1[].
  PERFORM EXCLUDE_TB_FUNCTIONS_0200 USING PC_GRID.

* CELL ATTRIBUTES
* PERFORM CELL_ATTRIBUTES_0100.
* ALV GRID
  PERFORM DISPLAY_ALV_0200 USING PC_GRID.
*
** F4
* PERFORM SET_F4_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PC_GRID
*&---------------------------------------------------------------------*
FORM SET_VARIANT_0200  USING   PC_GRID
                             TYPE REF TO CL_GUI_ALV_GRID.
  CLEAR: GS_VARIANT1,GS_VARIANT2.
  CASE PC_GRID.
    WHEN GO_GRID1.
      GS_VARIANT1-REPORT = SY-REPID.
      GS_VARIANT1-HANDLE = 2.
      GS_VARIANT1-USERNAME = SY-UNAME.

    WHEN GO_GRID2.
      GS_VARIANT2-REPORT = SY-REPID.
      GS_VARIANT2-HANDLE = 3.
      GS_VARIANT2-USERNAME = SY-UNAME.


  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PC_GRID
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_0200  USING  PC_GRID TYPE REF TO CL_GUI_ALV_GRID.

  CLEAR: GS_LAYOUT1, GS_LAYOUT2.
  CASE PC_GRID.
    WHEN GO_GRID1.
      GS_LAYOUT1-ZEBRA = GC_X.
      GS_LAYOUT1-SEL_MODE = 'D'. "선택모드
      GS_LAYOUT1-SMALLTITLE = GC_X.
*      GS_LAYOUT1-GRID_TITLE = GV_GRID_TITLE1.

*      GS_LAYOUT1-CWIDTH_OPT = GC_X.
      GS_LAYOUT1-NO_ROWMARK = GC_X. "선택버튼제거.
      GS_LAYOUT1-STYLEFNAME = 'CELLTAB'.
*GS_LAYOUT1-CTAB_FNAME = 'CELLCOL'
*GS_LAYOUT1-INFO_FNAME = 'LINECOL'.


    WHEN GO_GRID2.
      GS_LAYOUT2-ZEBRA = GC_X.
*      GS_LAYOUT2-CWIDTH_OPT = GC_X.
      GS_LAYOUT2-SEL_MODE = 'D'. "선택모드
      GS_LAYOUT2-SMALLTITLE = GC_X.
*      GS_LAYOUT2-GRID_TITLE = GV_GRID_TITLE2.
*      GS_LAYOUT2-NO_TOOLBAR = GC_X.
      GS_LAYOUT2-NO_ROWMARK = GC_X. "선택버튼제거.
      GS_LAYOUT2-STYLEFNAME = 'CELLTAB'.
* GS_LAYOUT2-CTAB_FNAME = 'CELLCOL'.
* GS_LAYOUT2-INFO_FNAME = 'LINECOL'.

*
*
*
*

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PC_GRID
*&---------------------------------------------------------------------*
FORM SET_SORT_0200  USING PC_GRID TYPE REF TO CL_GUI_ALV_GRID.
  DATA: LV_SPOS TYPE SLIS_SPOS.
  CLEAR: GT_SORT1[], GT_SORT2[].
  CASE PC_GRID.
    WHEN GO_GRID1.

* CLEAR GS_SORT.
* LV_SPOS = LV_SPOS + 1.
* GS_SORT-FIELDNAME = 'PRODALLOCCHARC01'.
*GS_SORT-SPOS = LV_SPOS.
*GS_SORT-UP = GC_X.
*APPEND GS_SORT TO GT_SORT

    WHEN GO_GRID2.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PC_GRID
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_0200  USING  PC_GRID
                               TYPE REF TO CL_GUI_ALV_GRID.
  CLEAR: GT_FIELDCAT1[],GT_FIELDCAT2[].
  CASE PC_GRID.
    WHEN GO_GRID1.
      PERFORM CREATE_FIELDCAT USING 'GT_0200'
                                    GT_FIELDCAT1.
      PERFORM MODIFY_FIELDCAT_0200 USING PC_GRID GT_FIELDCAT1.

    WHEN GO_GRID2.
      PERFORM CREATE_FIELDCAT USING 'GT_0210'
                                    GT_FIELDCAT2.
      PERFORM MODIFY_FIELDCAT_0200 USING PC_GRID GT_FIELDCAT2.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIELDCAT_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PC_GRID
*&      --> GT_FIELDCAT1
*&---------------------------------------------------------------------*
FORM MODIFY_FIELDCAT_0200  USING PC_GRID
                                  TYPE REF TO CL_GUI_ALV_GRID
                                PT_FIELDCAT TYPE LVC_T_FCAT.
  CASE PC_GRID.

    WHEN GO_GRID1.
      LOOP AT PT_FIELDCAT INTO GS_FIELDCAT..
        CASE GS_FIELDCAT-FIELDNAME.
          WHEN 'SEL'.
            GS_FIELDCAT-CHECKBOX = GC_X.
            GS_FIELDCAT-EDIT     = GC_X.
            GS_FIELDCAT-JUST = GC_C.
            GS_FIELDCAT-OUTPUTLEN = 3.
            PERFORM SET_TEXT USING TEXT-H61.
          WHEN 'ST_STSI'.
            GS_FIELDCAT-ICON = GC_X.
            GS_FIELDCAT-JUST = GC_C.
            GS_FIELDCAT-OUTPUTLEN = 8.
            PERFORM SET_TEXT USING TEXT-H62.
          WHEN 'POSNR'.
            GS_FIELDCAT-OUTPUTLEN = 5.
            PERFORM SET_TEXT USING TEXT-H63.
          WHEN 'MATNR'.
            GS_FIELDCAT-OUTPUTLEN = 12.
            PERFORM SET_TEXT USING TEXT-H64.
          WHEN 'LFIMG'.
            GS_FIELDCAT-QFIELDNAME = 'VRKME'.
            GS_FIELDCAT-OUTPUTLEN = 10.
            PERFORM SET_TEXT USING TEXT-H65.
          WHEN 'LENGTH_JS'.
            GS_FIELDCAT-OUTPUTLEN = 10.
            GS_FIELDCAT-QFIELDNAME = 'VRKME'.
            PERFORM SET_TEXT USING TEXT-H66.
          WHEN 'FACTOR_I'.
            GS_FIELDCAT-OUTPUTLEN = 7.
            PERFORM SET_TEXT USING TEXT-H67.
          WHEN 'LFIMG_M'.
            GS_FIELDCAT-QFIELDNAME = 'VRKME'.
            GS_FIELDCAT-OUTPUTLEN = 10.
            PERFORM SET_TEXT USING TEXT-H68.
          WHEN 'FACTOR_M'.
            GS_FIELDCAT-OUTPUTLEN = 10.
            PERFORM SET_TEXT USING TEXT-H69.
          WHEN 'LFIMG_JS'.
            GS_FIELDCAT-QFIELDNAME = 'VRKME'.
            GS_FIELDCAT-OUTPUTLEN = 10.
            PERFORM SET_TEXT USING TEXT-H70.
          WHEN 'FACTOR_JS'.
            GS_FIELDCAT-OUTPUTLEN = 7.
            PERFORM SET_TEXT USING TEXT-H71.
          WHEN 'NETWR_INI'.
            GS_FIELDCAT-OUTPUTLEN = 10.
            GS_FIELDCAT-CFIELDNAME = 'WAERK'.
            GS_FIELDCAT-EMPHASIZE  = 'C310'.
            GS_FIELDCAT-DO_SUM     = GC_X.
            PERFORM SET_TEXT USING TEXT-H72.
          WHEN 'NETWR_DW'.
            GS_FIELDCAT-OUTPUTLEN = 10.
            GS_FIELDCAT-CFIELDNAME = 'WAERK'.
            GS_FIELDCAT-EMPHASIZE  = 'C310'.
            GS_FIELDCAT-DO_SUM     = GC_X.
            PERFORM SET_TEXT USING TEXT-H73.
          WHEN 'NETWR_JS'.
            GS_FIELDCAT-OUTPUTLEN = 10.
            GS_FIELDCAT-CFIELDNAME = 'WAERK'.
            GS_FIELDCAT-EMPHASIZE  = 'C310'.
            GS_FIELDCAT-DO_SUM     = GC_X.
            PERFORM SET_TEXT USING TEXT-H74.
          WHEN 'WAERK'.
            GS_FIELDCAT-OUTPUTLEN = 4.
            PERFORM SET_TEXT USING TEXT-H75.
          WHEN 'LGORT'.
            GS_FIELDCAT-OUTPUTLEN = 5.
            PERFORM SET_TEXT USING TEXT-H76.
          WHEN 'LGOBE'.
            GS_FIELDCAT-OUTPUTLEN = 15.
            PERFORM SET_TEXT USING TEXT-H77.
          WHEN 'VGBEL'.
            GS_FIELDCAT-OUTPUTLEN = 11.
            PERFORM SET_TEXT USING TEXT-H78.
          WHEN 'VGPOS'.
            GS_FIELDCAT-OUTPUTLEN = 6.
            PERFORM SET_TEXT USING TEXT-H79.

          WHEN OTHERS.
            GS_FIELDCAT-NO_OUT = GC_X.
        ENDCASE.
        MODIFY PT_FIELDCAT FROM GS_FIELDCAT.
      ENDLOOP.

    WHEN GO_GRID2.
      LOOP AT PT_FIELDCAT INTO GS_FIELDCAT.
        CASE GS_FIELDCAT-FIELDNAME.
          WHEN 'ST_STSD'.
            GS_FIELDCAT-ICON = GC_X.
            GS_FIELDCAT-JUST = GC_C.
            GS_FIELDCAT-OUTPUTLEN = 3.
            PERFORM SET_TEXT USING TEXT-H96.
          WHEN 'POSNR'.
            GS_FIELDCAT-OUTPUTLEN = 8.
            PERFORM SET_TEXT USING TEXT-H81.
          WHEN 'POSNR_B'.
            GS_FIELDCAT-OUTPUTLEN = 8.
            PERFORM SET_TEXT USING TEXT-H82.
          WHEN 'MATNR'.
            GS_FIELDCAT-OUTPUTLEN = 12.
            PERFORM SET_TEXT USING TEXT-H83.
          WHEN 'CHARG'.
            GS_FIELDCAT-OUTPUTLEN = 12.
            PERFORM SET_TEXT USING TEXT-H84.
          WHEN 'VRKME'.
            GS_FIELDCAT-OUTPUTLEN = 4.
            PERFORM SET_TEXT USING TEXT-H85.
          WHEN 'LFIMG'.
            GS_FIELDCAT-OUTPUTLEN = 10.
            PERFORM SET_TEXT USING TEXT-H86.
          WHEN 'LENGTH_JS'.
            GS_FIELDCAT-OUTPUTLEN = 10.
            GS_FIELDCAT-QFIELDNAME = 'VRKME'.
            PERFORM SET_TEXT USING TEXT-H87.
          WHEN 'FACTOR_I'.
            GS_FIELDCAT-OUTPUTLEN = 7.
            PERFORM SET_TEXT USING TEXT-H88.
          WHEN 'FACTOR_M'.
            GS_FIELDCAT-OUTPUTLEN = 7.
            PERFORM SET_TEXT USING TEXT-H89.
          WHEN 'LFIMG_M'.
            GS_FIELDCAT-OUTPUTLEN = 10.
            PERFORM SET_TEXT USING TEXT-H90.
          WHEN 'NETPR'.
            GS_FIELDCAT-OUTPUTLEN = 8.
            GS_FIELDCAT-CFIELDNAME = 'WAERK'.
            PERFORM SET_TEXT USING TEXT-H91.
          WHEN 'NETWR_DW'.
            GS_FIELDCAT-OUTPUTLEN = 10.
            GS_FIELDCAT-CFIELDNAME = 'WAERK'.
            PERFORM SET_TEXT USING TEXT-H92.
          WHEN 'FACTOR_JS'.
            GS_FIELDCAT-OUTPUTLEN = 8.
            PERFORM SET_TEXT USING TEXT-H93.
          WHEN 'LFIMG_JS'.
            GS_FIELDCAT-OUTPUTLEN = 8.
            GS_FIELDCAT-QFIELDNAME = 'VRKME'.
            PERFORM SET_TEXT USING TEXT-H94.
          WHEN 'NETWR_JS'.
            GS_FIELDCAT-OUTPUTLEN = 10.
            GS_FIELDCAT-CFIELDNAME = 'WAERK'.
            PERFORM SET_TEXT USING TEXT-H95.
          WHEN OTHERS.
            GS_FIELDCAT-NO_OUT = GC_X.
        ENDCASE.
        MODIFY PT_FIELDCAT FROM GS_FIELDCAT.
      ENDLOOP.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTIONS_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PC_GRID
*&---------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS_0200  USING  PC_GRID
                                      TYPE REF TO CL_GUI_ALV_GRID.
  CASE PC_GRID.
    WHEN GO_GRID1.
      PERFORM EXCLUDE_TB_FUNCTIONS_0100 USING 'GT_EXCLUDE1'.
    WHEN GO_GRID2.
      PERFORM EXCLUDE_TB_FUNCTIONS_0100 USING 'GT_EXCLUDE2'.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PC_GRID
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_0200  USING  PC_GRID
TYPE REF TO CL_GUI_ALV_GRID.
  CASE PC_GRID.
    WHEN GO_GRID1.
      CALL METHOD PC_GRID->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_LAYOUT            = GS_LAYOUT1
          IS_VARIANT           = GS_VARIANT1
          I_SAVE               = 'A'
          IT_TOOLBAR_EXCLUDING = GT_EXCLUDE1[]
          I_BYPASSING_BUFFER   = 'X'
        CHANGING
          IT_OUTTAB            = GT_0200[]
          IT_FIELDCATALOG      = GT_FIELDCAT1[]
          IT_SORT              = GT_SORT1[].

    WHEN GO_GRID2.
      CALL METHOD PC_GRID->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_LAYOUT            = GS_LAYOUT2
          IS_VARIANT           = GS_VARIANT2
          I_SAVE               = 'A'
          IT_TOOLBAR_EXCLUDING = GT_EXCLUDE2[]
          I_BYPASSING_BUFFER   = 'X'
        CHANGING
          IT_OUTTAB            = GT_0210[]
          IT_FIELDCATALOG      = GT_FIELDCAT2[]
          IT_SORT              = GT_SORT2[].


  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_CONTROLS_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_CONTROLS_0200 .
  IF GO_GRID1 IS NOT INITIAL.
    CALL METHOD GO_GRID1->FREE.
    CLEAR GO_GRID1.
  ENDIF.
  IF GO_GRID2 IS NOT INITIAL.
    CALL METHOD GO_GRID2->FREE.
    CLEAR GO_GRID2.
  ENDIF.
  IF GO_GCON1 IS NOT INITIAL.
    CALL METHOD GO_GCON1->FREE.
    CLEAR GO_GCON1.
  ENDIF.
  IF GO_GCON2 IS NOT INITIAL.
    CALL METHOD GO_GCON2->FREE.
    CLEAR GO_GCON2.
  ENDIF.
  IF GO_SPLITTER2 IS NOT INITIAL.
    CALL METHOD GO_SPLITTER2->FREE.
    CLEAR GO_SPLITTER2.
  ENDIF.
  IF GO_CCON2 IS NOT INITIAL.
    CALL METHOD GO_CCON2->FREE.
    CLEAR:GO_CCON2.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ALV_0200_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID2
*&---------------------------------------------------------------------*
FORM CREATE_ALV_0200_BOT  USING  PC_GRID TYPE REF TO CL_GUI_ALV_GRID.
* Set Variant
  PERFORM SET_VARIANT_0200 USING PC_GRID.
* SET LAYOUT
  PERFORM SET_LAYOUT_0200 USING PC_GRID.
* SET SORT
  PERFORM SET_SORT_0200 USING PC_GRID.
* SET FIELDCAT
  PERFORM SET_FIELDCAT_0200 USING PC_GRID.
* Set Event Handler
  PERFORM SET_EVENT_HANDLER_0100 USING PC_GRID.
* EXCLUDING TOOLBAR
  CLEAR: GT_EXCLUDE1[].
  PERFORM EXCLUDE_TB_FUNCTIONS_0200 USING PC_GRID.

* CELL ATTRIBUTES
  PERFORM CELL_ATTRIBUTES_0210.


* ALV GRID
  PERFORM DISPLAY_ALV_0200 USING PC_GRID.
*
** F4
* PERFORM SET_F4_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CELL_ATTRIBUTES_0210
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CELL_ATTRIBUTES_0210 .
  LOOP AT GT_0210 ASSIGNING FIELD-SYMBOL(<FS_0210>).
    PERFORM SET_ATTRIBUTES_LINE_0210 CHANGING <FS_0210>.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0900 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0900 OUTPUT.
  SET PF-STATUS 'S0900' EXCLUDING GT_EXCLU.
  SET TITLEBAR 'T0900' WITH GV_TITLE3.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form INIT_CONTROLS_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_CONTROLS_0900 .
  IF GO_GRID3 IS NOT INITIAL.
    CALL METHOD GO_GRID3->FREE.
    CLEAR GO_GRID3.
  ENDIF.
  IF GO_CCON3 IS NOT INITIAL.
    CALL METHOD GO_CCON3->FREE.
    CLEAR:GO_CCON3.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_CONTROLS_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ALV_CONTROLS_0900 .
  IF GO_CCON3 IS INITIAL.
    PERFORM CREATE_CONTAINER_0900 USING GO_CCON3 'CONT0900'.

    PERFORM CREATE_ALV_0900 USING GO_CCON3
                                  GO_GRID3.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ALV_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_CCON3
*&      --> GO_GRID3
*&---------------------------------------------------------------------*
FORM CREATE_ALV_0900  USING    PO_CCON TYPE REF TO
                                 CL_GUI_CUSTOM_CONTAINER
                               PO_GRID TYPE REF TO
                                 CL_GUI_ALV_GRID.

  CREATE OBJECT PO_GRID
    EXPORTING
      I_PARENT = PO_CCON.
*      I_APPL_EVENTS = 'X'.

* Set Variant
  PERFORM SET_VARIANT_0900.

* SET LAYOUT
  PERFORM SET_LAYOUT_0900.

* SET SORT
  PERFORM SET_SORT_0900.

* SET FIELDCAT
  PERFORM SET_FIELDCAT_0900.

* Set Event Handler
  PERFORM SET_EVENT_HANDLER_0100 USING PO_GRID.

* EXCLUDING TOOLBAR
  CLEAR: GT_EXCLUDE3[].
  PERFORM EXCLUDE_TB_FUNCTIONS_0100 USING 'GT_EXCLUDE3'.

* CELL ATTRIBUTES
*  PERFORM CELL_ATTRIBUTES_0900.

* ALV GRID
  PERFORM DISPLAY_ALV_0900.

* F4
*  PERFORM SET_F4_0900.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_VARIANT_0900 .
  CLEAR : GS_VARIANT3.

  GS_VARIANT3-REPORT   = SY-REPID.
  GS_VARIANT3-HANDLE   = 9.
  GS_VARIANT3-USERNAME = SY-UNAME.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_0900 .
  CLEAR: GS_LAYOUT3.
  GS_LAYOUT3-ZEBRA        = GC_X.
*  GS_LAYOUT3-EDIT         = GC_X.
*  GS_LAYOUT3-CWIDTH_OPT   = GC_X.
  GS_LAYOUT3-SEL_MODE     = 'D'.      "선택모드
  GS_LAYOUT3-SMALLTITLE   = GC_X.
*  GS_LAYOUT3-GRID_TITLE   = GV_GRID_TITLE.

*  GS_LAYOUT3-NO_ROWMARK   = GC_X.      "선택버튼제거.
*  GS_LAYOUT3-STYLEFNAME   = 'CELLTAB'.
*  GS_LAYOUT3-CTAB_FNAME   = 'CELLCOL'.
*  GS_LAYOUT3-INFO_FNAME = 'LINECOL'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORT_0900 .
  DATA: LV_SPOS  TYPE SLIS_SPOS.
  CLEAR: GT_SORT3[].

*  CLEAR GS_SORT.
*  LV_SPOS = LV_SPOS + 1.
*  GS_SORT-SPOS = LV_SPOS.
*  GS_SORT-FIELDNAME = 'CRDAT'.
*  GS_SORT-DOWN = GC_X.
*  APPEND GS_SORT3 TO GT_SORT3.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_0900 .
  CLEAR: GT_FIELDCAT3[].

  PERFORM CREATE_FIELDCAT USING 'GT_0900'
                                GT_FIELDCAT3.

  PERFORM MODIFY_FIELDCAT_0900 USING GT_FIELDCAT3.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIELDCAT_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_FIELDCAT3
*&---------------------------------------------------------------------*
FORM MODIFY_FIELDCAT_0900  USING    PT_FIELDCAT TYPE LVC_T_FCAT.

  LOOP AT PT_FIELDCAT INTO GS_FIELDCAT.
    CASE GS_FIELDCAT-FIELDNAME.
      WHEN 'LFART'.
        GS_FIELDCAT-OUTPUTLEN = 7.
        PERFORM SET_TEXT USING TEXT-L01.
      WHEN 'LFART_NM'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-L02.
      WHEN 'VBELN_VL'.
        CLEAR GS_FIELDCAT-KEY.
        GS_FIELDCAT-OUTPUTLEN = 11.
        PERFORM SET_TEXT USING TEXT-L03.
      WHEN 'VBELN_VA'.
        CLEAR GS_FIELDCAT-KEY.
        GS_FIELDCAT-OUTPUTLEN = 11.
        PERFORM SET_TEXT USING TEXT-L04.
      WHEN 'KUNNR'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-L05.
      WHEN 'KUNNR_NM'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-L06.
      WHEN 'WADAT_IST'.
        GS_FIELDCAT-OUTPUTLEN = 12.
        PERFORM SET_TEXT USING TEXT-L07.
      WHEN 'NETWR'.
        GS_FIELDCAT-OUTPUTLEN = 12.
        PERFORM SET_TEXT USING TEXT-L08.
      WHEN 'WAERK'.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-L09.
      WHEN 'KUNWE'.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-L10.
      WHEN 'KUNWE_NM'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-L11.

      WHEN OTHERS.
        GS_FIELDCAT-NO_OUT = GC_X.
    ENDCASE.
    MODIFY PT_FIELDCAT FROM GS_FIELDCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_0900 .
  CALL METHOD GO_GRID3->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT3
      IS_VARIANT           = GS_VARIANT3
      I_SAVE               = 'A'
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE3[]
      I_BYPASSING_BUFFER   = 'X'
    CHANGING
      IT_OUTTAB            = GT_0900[]
      IT_FIELDCATALOG      = GT_FIELDCAT3[]
      IT_SORT              = GT_SORT3[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_CONTAINER_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_CCON3
*&      --> P_
*&---------------------------------------------------------------------*
FORM CREATE_CONTAINER_0900  USING    PO_CCON TYPE REF TO
                                         CL_GUI_CUSTOM_CONTAINER
                                    P_CONT.

  CREATE OBJECT PO_CCON
    EXPORTING
      CONTAINER_NAME = P_CONT.

ENDFORM.
