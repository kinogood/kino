*&---------------------------------------------------------------------*
*& Include          ZGTSDR1190ALV
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
      HEIGHT = 90.

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
        LV_COLNO     TYPE I   VALUE '4',
        LV_CNTNO     TYPE P DECIMALS 2,
        LV_FONTSIZE  TYPE SDYDO_ATTRIBUTE.
  DATA: LO_TITLE1 TYPE REF TO CL_DD_AREA,
        LO_COLN1  TYPE REF TO CL_DD_AREA,
        LO_CODE1  TYPE REF TO CL_DD_AREA,
        LO_GAP1   TYPE REF TO CL_DD_AREA,
        LO_TEXT1  TYPE REF TO CL_DD_AREA,
        LO_TITLE2 TYPE REF TO CL_DD_AREA,
        LO_COLN2  TYPE REF TO CL_DD_AREA,
        LO_CODE2  TYPE REF TO CL_DD_AREA,
        LO_GAP2   TYPE REF TO CL_DD_AREA,
        LO_TEXT2  TYPE REF TO CL_DD_AREA,
        LO_TITLE3 TYPE REF TO CL_DD_AREA,
        LO_COLN3  TYPE REF TO CL_DD_AREA,
        LO_CODE3  TYPE REF TO CL_DD_AREA,
        LO_GAP3   TYPE REF TO CL_DD_AREA,
        LO_TEXT3  TYPE REF TO CL_DD_AREA,
        LO_TITLE4 TYPE REF TO CL_DD_AREA,
        LO_COLN4  TYPE REF TO CL_DD_AREA,
        LO_CODE4  TYPE REF TO CL_DD_AREA,
        LO_GAP4   TYPE REF TO CL_DD_AREA,
        LO_TEXT4  TYPE REF TO CL_DD_AREA,
        LO_TITLE5 TYPE REF TO CL_DD_AREA,
        LO_COLN5  TYPE REF TO CL_DD_AREA,
        LO_CODE5  TYPE REF TO CL_DD_AREA,
        LO_GAP5   TYPE REF TO CL_DD_AREA,
        LO_TEXT5  TYPE REF TO CL_DD_AREA.



  DATA: BEGIN OF LT_ALVTITLE OCCURS 0,
          TITLE TYPE CHAR35,
          COLN  TYPE CHAR35,
          CODE  TYPE CHAR35,
          GAP   TYPE CHAR35,
          TEXT  TYPE CHAR35,
        END OF LT_ALVTITLE.

  DATA: BEGIN OF LS_DATA,
          TITLE TYPE CHAR255,
          COLN  TYPE CHAR255,
          CODE  TYPE CHAR255,
          GAP   TYPE CHAR255,
          TEXT  TYPE CHAR255,
        END OF LS_DATA.
  DATA: LT_DATA LIKE TABLE OF LS_DATA.
  FIELD-SYMBOLS: <LFS_TITLE> TYPE REF TO CL_DD_AREA,
                 <LFS_CODE>  TYPE REF TO CL_DD_AREA,
                 <LFS_TEXT>  TYPE REF TO CL_DD_AREA,
                 <LFS_GAP>   TYPE REF TO CL_DD_AREA,
                 <LFS_COLN>  TYPE REF TO CL_DD_AREA.

  CHECK GO_GCON1 IS NOT INITIAL.



  CLEAR: LS_DATA.
  LS_DATA-TITLE = TEXT-005.
  LS_DATA-CODE  = VALUE #( S_VKORG[ 1 ]-LOW OPTIONAL ).
  SELECT SINGLE VTEXT
    INTO LS_DATA-TEXT
    FROM TVKOT
   WHERE VKORG IN S_VKORG
     AND SPRAS EQ SY-LANGU.
  APPEND LS_DATA TO LT_DATA.

  CLEAR: LS_DATA.
  LS_DATA-TITLE = TEXT-006.
  IF S_VKBUR[] IS INITIAL.
    LS_DATA-CODE  = TEXT-002.
    LS_DATA-TEXT  = TEXT-002.
  ELSE.
    DATA(LT_TEMP) = GT_LIST[].
    SORT LT_TEMP BY VKBUR.
    DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VKBUR.
    IF LT_TEMP[] IS NOT INITIAL.
      SELECT VKBUR, BEZEI
        FROM TVKBT
         FOR ALL ENTRIES IN @LT_TEMP
       WHERE VKBUR EQ @LT_TEMP-VKBUR
         AND SPRAS EQ @SY-LANGU
        INTO TABLE @DATA(LT_VKBUR).

    ENDIF.
    LOOP AT LT_VKBUR INTO DATA(LS_VKBUR).
      IF LS_DATA-CODE IS NOT INITIAL.
        LS_DATA-CODE = |{ LS_DATA-CODE }/{ LS_VKBUR-VKBUR }|.
      ELSE.
        LS_DATA-CODE = LS_VKBUR-VKBUR.
      ENDIF.

      IF LS_DATA-TEXT IS NOT INITIAL.
        LS_DATA-TEXT = |{ LS_DATA-TEXT }/{ LS_VKBUR-BEZEI }|.
      ELSE.
        LS_DATA-TEXT = LS_VKBUR-BEZEI.
      ENDIF.
    ENDLOOP.

  ENDIF.
  APPEND LS_DATA TO LT_DATA.

  CLEAR: LS_DATA.
  LS_DATA-TITLE = TEXT-007.
  IF S_VKGRP[] IS INITIAL.
    LS_DATA-CODE  = TEXT-002.
    LS_DATA-TEXT  = TEXT-002.
  ELSE.
    CLEAR LT_TEMP[].
    LT_TEMP[] = GT_LIST[].
    SORT LT_TEMP BY VKGRP.
    DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VKGRP.
    IF LT_TEMP[] IS NOT INITIAL.
      SELECT VKGRP, BEZEI
        FROM TVGRT
         FOR ALL ENTRIES IN @LT_TEMP
       WHERE VKGRP EQ @LT_TEMP-VKGRP
         AND SPRAS EQ @SY-LANGU
        INTO TABLE @DATA(LT_VKGRP).

    ENDIF.
    LOOP AT LT_VKGRP INTO DATA(LS_VKGRP).
      IF LS_DATA-CODE IS NOT INITIAL.
        LS_DATA-CODE = |{ LS_DATA-CODE }/{ LS_VKGRP-VKGRP }|.
      ELSE.
        LS_DATA-CODE = LS_VKGRP-VKGRP.
      ENDIF.

      IF LS_DATA-TEXT IS NOT INITIAL.
        LS_DATA-TEXT = |{ LS_DATA-TEXT }/{ LS_VKGRP-BEZEI }|.
      ELSE.
        LS_DATA-TEXT = LS_VKGRP-BEZEI.
      ENDIF.
    ENDLOOP.

  ENDIF.
  APPEND LS_DATA TO LT_DATA.

  CLEAR: LS_DATA.
  LS_DATA-TITLE = TEXT-008.
  WRITE: P_SPMON TO LS_DATA-CODE USING EDIT MASK '____.__'.
  APPEND LS_DATA TO LT_DATA.


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
    LT_ALVTITLE-TITLE   = |LO_TITLE{ SY-INDEX }|.
    LT_ALVTITLE-COLN    = |LO_COLN{ SY-INDEX }|.
    LT_ALVTITLE-CODE    = |LO_CODE{ SY-INDEX }|.
    LT_ALVTITLE-TEXT    = |LO_TEXT{ SY-INDEX }|.
    LT_ALVTITLE-GAP    = |LO_GAP{ SY-INDEX }|.
    APPEND LT_ALVTITLE.

    IF <LFS_TITLE> IS ASSIGNED. UNASSIGN <LFS_TITLE>.ENDIF.
    IF <LFS_CODE> IS ASSIGNED. UNASSIGN <LFS_CODE>.ENDIF.
    IF <LFS_TEXT> IS ASSIGNED. UNASSIGN <LFS_TEXT>.ENDIF.
    IF <LFS_COLN>  IS ASSIGNED. UNASSIGN <LFS_COLN>.ENDIF.
    IF <LFS_GAP>  IS ASSIGNED. UNASSIGN <LFS_GAP>.ENDIF.
    ASSIGN (LT_ALVTITLE-TITLE) TO <LFS_TITLE>.
    ASSIGN (LT_ALVTITLE-TEXT) TO <LFS_TEXT>.
    ASSIGN (LT_ALVTITLE-CODE) TO <LFS_CODE>.
    ASSIGN (LT_ALVTITLE-COLN)  TO <LFS_COLN>.
    ASSIGN (LT_ALVTITLE-GAP)  TO <LFS_GAP>.

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

    CALL METHOD LO_TABLE->ADD_COLUMN
      IMPORTING
        COLUMN = <LFS_CODE>.
    ADD 1 TO LV_CURCOL.
    CALL METHOD LO_TABLE->SET_COLUMN_STYLE
      EXPORTING
        COL_NO       = LV_CURCOL
        SAP_ALIGN    = LV_ALIGN
        SAP_FONTSIZE = LV_FONTSIZE.

    CALL METHOD LO_TABLE->ADD_COLUMN
      IMPORTING
        COLUMN = <LFS_GAP>.
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
    IF <LFS_CODE> IS ASSIGNED. UNASSIGN <LFS_CODE>.ENDIF.
    IF <LFS_GAP> IS ASSIGNED. UNASSIGN <LFS_GAP>.ENDIF.
    ASSIGN (LT_ALVTITLE-TITLE) TO <LFS_TITLE>.
    ASSIGN (LT_ALVTITLE-COLN)  TO <LFS_COLN>.
    ASSIGN (LT_ALVTITLE-TEXT)  TO <LFS_TEXT>.
    ASSIGN (LT_ALVTITLE-CODE)  TO <LFS_CODE>.
    ASSIGN (LT_ALVTITLE-GAP)  TO <LFS_GAP>.


    CALL METHOD <LFS_TITLE>->ADD_TEXT
      EXPORTING
        TEXT         = LS_DATA-TITLE
        SAP_EMPHASIS = 'Strong'.
    .
    CALL METHOD <LFS_TITLE>->ADD_GAP
      EXPORTING
        WIDTH = LV_GAP.

    CALL METHOD <LFS_COLN>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-COLN.

    CALL METHOD <LFS_COLN>->ADD_GAP
      EXPORTING
        WIDTH = LV_GAP.

    CALL METHOD <LFS_CODE>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-CODE.

    CALL METHOD <LFS_CODE>->ADD_GAP
      EXPORTING
        WIDTH = LV_GAP.

    CALL METHOD <LFS_GAP>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-GAP.

    CALL METHOD <LFS_GAP>->ADD_GAP
      EXPORTING
        WIDTH = LV_GAP.

    CALL METHOD <LFS_TEXT>->ADD_TEXT
      EXPORTING
        TEXT = LS_DATA-TEXT.


*    CHECK LV_CURCOL = LV_COLNO.
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

  PERFORM CREATE_FIELDCAT USING 'GT_LIST'
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
      WHEN 'SEL'.
        CLEAR:GS_FIELDCAT-KEY.
*        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-CHECKBOX = GC_X.
        GS_FIELDCAT-EDIT     = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H01.

      WHEN 'STAT'.
        CLEAR:GS_FIELDCAT-KEY.
*        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H02.

      WHEN 'VKBUR'.
        CLEAR:GS_FIELDCAT-KEY.
*        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H03.
      WHEN 'VKBUR_TX'.
*        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H04.
      WHEN 'VKGRP'.
        CLEAR:GS_FIELDCAT-KEY.
*        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 5.
        PERFORM SET_TEXT USING TEXT-H05.
      WHEN 'VKGRP_TX'.
*        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H06.
      WHEN 'CRITER'.
        CLEAR:GS_FIELDCAT-KEY.
*        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 8.
        PERFORM SET_TEXT USING TEXT-H07.
      WHEN 'PARTNER'.
        CLEAR:GS_FIELDCAT-KEY.
*        GS_FIELDCAT-KEY      = GC_X.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H08.
      WHEN 'KUNNR'.
        CLEAR:GS_FIELDCAT-KEY.
        GS_FIELDCAT-OUTPUTLEN = 10.
        PERFORM SET_TEXT USING TEXT-H09.
      WHEN 'KUNNR_TX'.
        GS_FIELDCAT-OUTPUTLEN = 15.
        PERFORM SET_TEXT USING TEXT-H10.
      WHEN 'DATEFR'.
        GS_FIELDCAT-OUTPUTLEN = 12.
        PERFORM SET_TEXT USING TEXT-H11.
      WHEN 'DATETO'.
        GS_FIELDCAT-OUTPUTLEN = 12.
        PERFORM SET_TEXT USING TEXT-H12.
      WHEN 'XFELD'.
        GS_FIELDCAT-CHECKBOX = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 4.
        PERFORM SET_TEXT USING TEXT-H13.
*[S] 안정화  GW20260903003
      WHEN 'XCRITICAL'.
        CLEAR:GS_FIELDCAT-KEY.
        GS_FIELDCAT-OUTPUTLEN = 10.
        GS_FIELDCAT-JUST = GC_C.        .
        PERFORM SET_TEXT USING TEXT-H16.
*[E] 안정화  GW20260903003
      WHEN 'STAT2'.
        GS_FIELDCAT-ICON = GC_X.
        GS_FIELDCAT-JUST = GC_C.
        GS_FIELDCAT-OUTPUTLEN = 3.
        PERFORM SET_TEXT USING TEXT-H15.
      WHEN 'MESSAGE'.
        GS_FIELDCAT-OUTPUTLEN = 40.
        PERFORM SET_TEXT USING TEXT-H14.

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

  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

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
*  SET HANDLER GO_EVENT_RECEIVER->HANDLE_BUTTON_CLICK     FOR PO_GRID.
*  SET HANDLER GO_EVENT_RECEIVER->HANDLE_TOP_OF_PAGE   FOR PA_GRID.

  IF GV_EDIT IS NOT INITIAL.
    CALL METHOD PO_GRID->SET_READY_FOR_INPUT
      EXPORTING
        I_READY_FOR_INPUT = 1.

  ELSE.
    CALL METHOD PO_GRID->SET_READY_FOR_INPUT
      EXPORTING
        I_READY_FOR_INPUT = 0.
  ENDIF.

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
      IT_OUTTAB            = GT_LIST[]
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
