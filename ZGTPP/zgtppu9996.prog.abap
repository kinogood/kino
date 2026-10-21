*&---------------------------------------------------------------------*
*& Report ZGTPPU9996
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGTPPU9996 LINE-COUNT 0 LINE-SIZE 80
       NO STANDARD PAGE HEADING.
*-----------------------------------------------------------------------
* BDC Data Upload by Recording
*-----------------------------------------------------------------------
*  |*            ; comment
*  |*FIELDNAME   ; field name
*  |*Description ;
*  |STARTDATA    ; data start
*  |
*  |
*  |ENDDATA      ; data end
*-----------------------------------------------------------------------
TABLES: APQI,
        TSTCT,
        DFIES,
        X031L,
        T100.
*
DATA: BDC_PARAMS LIKE CTU_PARAMS.
DATA: DYNFLOW  LIKE BDCDATA OCCURS 0 WITH HEADER LINE.
DATA: SAV_DF   LIKE BDCDATA OCCURS 0 WITH HEADER LINE.
DATA: BDC_DATA LIKE BDCDATA OCCURS 0 WITH HEADER LINE.
DATA: PRG_DYN(50), ICODE(30).
*
DATA: UPLOAD(12)    VALUE '<Processing>',
      TESTING(14)   VALUE '<Test Display>',
      TESTONE(10)   VALUE '<Test One>',
      SESSION(17)   VALUE '<Process Session>',
      MAKETEMP(15)  VALUE '<Make Template>',
      CLIP(7)       VALUE '<Paste>'.
*
DATA: BEGIN OF ALPHA,
        X1 TYPE HEXTYP VALUE 65,
        X2 TYPE HEXTYP VALUE 32,
      END   OF ALPHA.
DATA  READTYPE.
DATA  F_TEST.    "ok_code for test
DATA: DYN_TABIX LIKE SY-TABIX,
      DYN_ORDER LIKE SY-TABIX.
* function code for test
DATA: BEGIN OF MOD_FCODE OCCURS 10,
        F_TEST,
        TABIX LIKE SY-TABIX,
      END   OF MOD_FCODE.
*
DATA: BEGIN OF FTEXT OCCURS 10,
        OUTPUTLEN LIKE DFIES-OUTPUTLEN,
        SCRTEXT_S(14),
        SCRTEXT_M(24),
        SCRTEXT_L LIKE DFIES-SCRTEXT_L,
        LINENO(4),
        TABIX LIKE SY-TABIX,
      END   OF FTEXT.
*
DATA: BEGIN OF FNAM OCCURS 10,
        FNAM LIKE BDCDATA-FNAM,
        ORDER LIKE SY-TABIX,
      END   OF FNAM.
*
DATA: BEGIN OF FORD OCCURS 10,
        FNAM  LIKE BDCDATA-FNAM,
        ORDER LIKE SY-TABIX,
      END   OF FORD.
*
DATA: NODATA VALUE '/'.
DATA: MESSTAB LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.
DATA: L_MSTRING(512).
DATA  CCODE(2).
DATA  TRAN_SUBRC TYPE SY-SUBRC.
DATA: FILENAME     LIKE RLGRAP-FILENAME,
      FILETYPE     LIKE RLGRAP-FILETYPE VALUE 'ASC',
      ACT_FILENAME LIKE RLGRAP-FILENAME,
      FILESIZE TYPE I.
* Recording
SELECTION-SCREEN BEGIN OF BLOCK RECO0 WITH FRAME TITLE T_RECO0.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) T_GRPID.
PARAMETERS:   P_GRPID LIKE APQI-GROUPID.
PARAMETERS:   P_MANDT LIKE APQI-MANDANT OBLIGATORY DEFAULT SY-MANDT.
SELECTION-SCREEN END   OF LINE.
* Created on
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) T_CREDT.
PARAMETERS: P_CREDT LIKE APQI-CREDATE.
SELECTION-SCREEN END   OF LINE.
* Created by
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) T_CREUR.
PARAMETERS: P_CREUR LIKE APQI-CREATOR.
SELECTION-SCREEN END   OF LINE.
*
SELECTION-SCREEN ULINE.
*
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) T_RFILE.
PARAMETERS: P_RFILE(128) MEMORY ID DLP.
SELECTION-SCREEN END   OF LINE.
*
SELECTION-SCREEN END   OF BLOCK RECO0.
*
SELECTION-SCREEN BEGIN OF BLOCK FSRC0 WITH FRAME TITLE T_FSCR0.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS P_FRPC RADIOBUTTON GROUP FSRC.
SELECTION-SCREEN COMMENT  3(15) T_FRPC.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS P_FRSR RADIOBUTTON GROUP FSRC.
SELECTION-SCREEN COMMENT 3(15) T_FRSR.
SELECTION-SCREEN END   OF LINE.
*
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) T_FNAME.
PARAMETERS: P_FNAME LIKE RLGRAP-FILENAME
*                         DEFAULT 'C:\SAPWorkdir\MAT.TXT'
                         MEMORY ID DLF.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: X_DEFLT  AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN COMMENT 3(70) T_DEFLT.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) T_NULTXT.
PARAMETERS: X_NULIND   DEFAULT '!'.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK FSRC0.
*
SELECTION-SCREEN BEGIN OF BLOCK SESS0 WITH FRAME TITLE T_SESS0.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: X_TRAN RADIOBUTTON GROUP BTYP.
SELECTION-SCREEN COMMENT 3(20) T_TRAN.
SELECTION-SCREEN END   OF LINE.
*
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) T_DMODE.
PARAMETERS: DMODE LIKE CTU_PARAMS-DISMODE DEFAULT 'N'.
SELECTION-SCREEN END   OF LINE.
*
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) T_UMODE.
PARAMETERS: UMODE LIKE CTU_PARAMS-UPDMODE DEFAULT 'S'.
SELECTION-SCREEN END   OF LINE.
*
SELECTION-SCREEN ULINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: X_SES RADIOBUTTON GROUP BTYP.
SELECTION-SCREEN COMMENT 3(20) T_SES.
SELECTION-SCREEN END   OF LINE.
PARAMETERS: BDCGROUP(12).
PARAMETERS: USERNAME LIKE SY-UNAME DEFAULT SY-UNAME OBLIGATORY.
SELECTION-SCREEN END   OF BLOCK SESS0.
PARAMETERS: CONDENS AS CHECKBOX DEFAULT 'X'.
*
DATA: BEGIN OF XDAT OCCURS 0,
        DAT(1024),
      END   OF XDAT.
*
RANGES: R_GRPID FOR APQI-GROUPID,
        R_CREDT FOR APQI-CREDATE,
        R_CREUR FOR APQI-CREATOR.
*
DATA: APQITAB LIKE APQI OCCURS 0 WITH HEADER LINE,
      RECORDING_TYPE LIKE APQI-DATATYP VALUE '%BDC'.
*
DATA: INDATA(1024) OCCURS 0 WITH HEADER LINE.
*
DATA: LEN TYPE I,
      N   TYPE I,
      O   TYPE I,
     SEQ  TYPE I,
     DAT(128),
     CH.
*
DATA: BEGIN OF TAB,
*         t TYPE x VALUE '09',
         T TYPE C,
      END   OF TAB.
*
DATA: BDC_VALUE(128) OCCURS 0 WITH HEADER LINE,
      BDC_INDEX      TYPE I,
      BDC_COUNT      TYPE I.
DATA  TRANCODE LIKE TSTC-TCODE.
DATA: FIELDNAME,
      START,
      END,
      DATA.
*
DATA: H LIKE D020S,
      F LIKE D021S OCCURS 0 WITH HEADER LINE,
      E LIKE D022S OCCURS 0 WITH HEADER LINE,
      M LIKE D023S OCCURS 0 WITH HEADER LINE.
*
DATA: BEGIN OF DYNP,
        PROG LIKE D020S-PROG,
        DNUM LIKE D020S-DNUM,
      END OF DYNP.
*
DATA: P_EXCEL, P_TAB.
TABLES: SSCRFIELDS.
DATA: G_FNAME LIKE RLGRAP-FILENAME,
      G_MASK(20)   VALUE ',*.*,*.*.',
      G_MODE_OPEN  VALUE 'O',
      G_TITLE(30)  VALUE 'FileUploadDialog'.
*
* for excel
TYPE-POOLS: OLE2.
*
DATA: XL_ROW    TYPE I,
      XL_COLUMN TYPE I.
DATA: E_FONT(20) VALUE '굴림',
      E_SIZE TYPE I VALUE 12.
DATA: E_SHEET_NO   TYPE I VALUE 1,
      E_SHEET_NAME(20) VALUE 'TEST',
      XL_TITLE(100).
*
* Automation EXCEL
DATA: EXCEL TYPE OLE2_OBJECT, BOOKS  TYPE OLE2_OBJECT,
      BOOK  TYPE OLE2_OBJECT, SHEETS TYPE OLE2_OBJECT,
      SHEET TYPE OLE2_OBJECT, CELLS  TYPE OLE2_OBJECT,
      CELL  TYPE OLE2_OBJECT, APPL   TYPE OLE2_OBJECT,
      FONT  TYPE OLE2_OBJECT.
*
AT SELECTION-SCREEN OUTPUT.
*
  GET PARAMETER ID 'DLP' FIELD P_RFILE.
  GET PARAMETER ID 'DLF' FIELD P_FNAME.
*
INITIALIZATION.
*
*  bdcgroup = 'ZBDCGROUP'.
  USERNAME = SY-UNAME.
  T_DMODE  = 'Run mode'.
  T_UMODE  = 'Update mode'.
  T_TRAN   = 'Call transaction'.
  T_SES    = 'Generate session'.
  T_GRPID  = 'Recording'.
  T_CREDT  = 'Created on'.
  T_CREUR  = 'Created by'.
  T_FRPC   = 'From PC'.
  T_FRSR   = 'From Server'.
  T_FNAME  = 'Path: file name of the BDC data'.
  T_FSCR0  = 'BDC data'.
  T_RECO0  = 'Selection for Recording'.
  T_SESS0  = 'Processing type'.
  T_DEFLT  = 'Default Value - Use no space RECORDING field value'.
  T_NULTXT = 'Null indicator'.
  T_RFILE  = 'External recording file'.
*
  GET PARAMETER ID 'DLP' FIELD P_RFILE.
  GET PARAMETER ID 'DLF' FIELD P_FNAME.
*
START-OF-SELECTION.
*
  DATA: L_TAB(10), L_CHAR_TAB(10).
*
  MOVE '\X\09' TO L_TAB.
*
  CALL FUNCTION 'STPU1_HEX_TO_CHAR'
    EXPORTING
      HEX_STRING  = L_TAB
    IMPORTING
      CHAR_STRING = L_CHAR_TAB.
*
  MOVE L_CHAR_TAB TO TAB.
*
  IF P_GRPID IS INITIAL AND
     P_RFILE IS INITIAL.
    MESSAGE S208(00) WITH
       'Enter the Recording name or Ext.Recording file name'.
    EXIT.
  ENDIF.
*
  IF X_SES = 'X' AND BDCGROUP IS INITIAL.
    MESSAGE S208(00) WITH 'Enter the BDCGROUP Name'.
    LEAVE LIST-PROCESSING.
  ENDIF.
*
  IF NOT P_GRPID IS INITIAL.
    PERFORM SET_SELECT_OPTIONS.
    SELECT * FROM APQI INTO TABLE APQITAB
             WHERE GROUPID  IN R_GRPID
               AND CREDATE  IN R_CREDT
               AND DATATYP  = RECORDING_TYPE
               AND MANDANT  = P_MANDT
               AND CREATOR  IN R_CREUR
             ORDER BY CREDATE DESCENDING CRETIME DESCENDING.
  ENDIF.
  IF NOT P_RFILE IS INITIAL AND SY-DBCNT = 0.
    PERFORM UPLOAD_THE_RECORDING.
  ENDIF.
*
  DESCRIBE TABLE APQITAB LINES SY-TFILL.
  IF SY-TFILL = 0.
    MESSAGE S208(00) WITH 'Not found recording !'.
    EXIT.
  ENDIF.
*
  FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
*
  LOOP AT APQITAB.
    WRITE: /1 SY-VLINE,
             (6) APQITAB-MANDANT,  SY-VLINE,
            (12) APQITAB-GROUPID,  SY-VLINE,
            (10) APQITAB-CREDATE,  SY-VLINE,
             (8) APQITAB-CRETIME,  SY-VLINE,
            (12) APQITAB-CREATOR,  SY-VLINE,
             (5) APQITAB-TRANSCNT, SY-VLINE,
             (5) APQITAB-MSGCNT,   SY-VLINE.
    APQI = APQITAB.
    HIDE: APQI-GROUPID, APQI-QID, APQI-MANDANT, APQITAB.
  ENDLOOP.
  ULINE.
  CLEAR APQITAB.
*
*
TOP-OF-PAGE.
*
  FORMAT COLOR COL_HEADING.
  ULINE.
  WRITE: /1 SY-VLINE,
           (6) 'Client',     SY-VLINE,
          (12) 'Recording',  SY-VLINE,
          (10) 'Date',       SY-VLINE,
           (8) 'Time',       SY-VLINE,
          (12) 'Created by', SY-VLINE,
           (5) 'Trans',      SY-VLINE,
           (5) 'Scrn',       SY-VLINE.
  ULINE.
*
AT LINE-SELECTION.
*
  IF SY-LSIND = 1.
    CHECK NOT APQI-GROUPID IS INITIAL.
    CLEAR ICODE.
    PERFORM PUT_SCREEN_TEMPLATE.
    CLEAR ICODE.
  ELSEIF SY-LSIND = 2.
    CLEAR ICODE.
    GET CURSOR FIELD ICODE.
*
    IF ICODE = 'UPLOAD' OR ICODE = 'TESTING' OR ICODE = 'TESTONE'.
      PERFORM UPLOAD_DATA.
      DESCRIBE TABLE INDATA LINES SY-TFILL.
      IF SY-TFILL > 0.
        PERFORM MAKE_BDC_DATA.
      ENDIF.
    ELSEIF ICODE = 'SESSION'.
      PERFORM PROCESS_SESSION.
    ELSEIF ICODE = 'MAKETEMP'.
      PERFORM MAKE_TEMPLATE_IN_EXCEL.
*      PERFORM save_recording.
    ELSEIF ICODE = 'CLIP'.
      PERFORM PASTE_FROM_CLIP.
      DESCRIBE TABLE INDATA LINES SY-TFILL.
      MOVE 'UPLOAD' TO ICODE.
      IF SY-TFILL > 0.
        PERFORM MAKE_BDC_DATA.
      ENDIF.
    ENDIF.
  ENDIF.
*
*&---------------------------------------------------------------------*
*&      Form  put_screen_template
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PUT_SCREEN_TEMPLATE.
*
  DATA: L_ALPHA(2), L_HEX(10), L_X1(4), L_X2(4), L_CHAR(10).
*
  REFRESH: FTEXT, FNAM.
  CLEAR FNAM.
  CLEAR DYN_ORDER.
*
  ALPHA-X1 = 65.
  ALPHA-X2 = 32.
*
  IF ICODE IS INITIAL AND NOT P_GRPID IS INITIAL.
    CALL FUNCTION 'BDC_OBJECT_READ'
      EXPORTING
        QUEUE_ID  = APQI-QID
        DATATYPE  = RECORDING_TYPE
*       TRANS     = apqi-TRANS
      TABLES
        DYNPROTAB = DYNFLOW
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 99.
    IF SY-SUBRC <> 0.
      MESSAGE S208(00) WITH 'Cannot get the Recoreing info.'.
      EXIT.
    ENDIF.
  ENDIF.
*
  NEW-PAGE LINE-SIZE 120.
*
  WRITE : /1  UPLOAD  COLOR 5 HOTSPOT.
  IF X_TRAN = 'X'.
    WRITE: TESTONE    COLOR 5 HOTSPOT.
  ENDIF.
  WRITE: TESTING      COLOR 5 HOTSPOT.
  WRITE: CLIP         COLOR 5 HOTSPOT QUICKINFO 'From Clipboard'.
  WRITE: MAKETEMP     COLOR 5 HOTSPOT.
*
  ULINE.
  FORMAT COLOR COL_HEADING INTENSIFIED OFF.
* Recording Name
  WRITE AT : /1(SY-LINSZ) 'Recording   :',
             15  APQI-GROUPID.
*
  ULINE.
*
  LOOP AT DYNFLOW.
    DYN_TABIX = SY-TABIX.
*   tcode line
    IF DYNFLOW-DYNBEGIN = 'T'.         " Tcode
      TSTCT-TCODE = DYNFLOW-FNAM.
      TRANCODE    = TSTCT-TCODE.
      SELECT SINGLE * FROM TSTCT WHERE SPRSL = SY-LANGU
                                   AND TCODE = TSTCT-TCODE.
      FORMAT COLOR COL_KEY.
      WRITE AT : /1(SY-LINSZ) 'Transaction :'.
      WRITE:     15 TSTCT-TCODE,
                    TSTCT-TTEXT.
      ULINE.
*   start screen
    ELSEIF DYNFLOW-DYNBEGIN = 'X'.
      PRG_DYN    = DYNP-PROG = DYNFLOW-PROGRAM.
      PRG_DYN+41 = DYNP-DNUM = DYNFLOW-DYNPRO.
      IMPORT DYNPRO H F E M ID DYNP.
      CONDENSE PRG_DYN.
      FORMAT COLOR COL_GROUP.
      WRITE AT : /1(SY-LINSZ) SPACE,
              6 PRG_DYN.
    ELSE.
      IF DYNFLOW-FNAM(4) NE 'BDC_' OR
         DYNFLOW-FNAM = 'BDC_OKCODE'.
*       NOT use default and have value
*       Increase Column order
        IF DYNFLOW-FNAM NE 'BDC_OKCODE'.
          IF NOT ( X_DEFLT = 'X' AND DYNFLOW-FVAL NE SPACE ).
            IF ALPHA-X2 = 32.
              ALPHA-X1 = ALPHA-X1 + 1.
              IF ALPHA-X1 > 90.
                IF ALPHA-X2 = 32.
                  ALPHA-X1 = ALPHA-X2 = 65.
                ENDIF.
              ENDIF.
            ELSE.
              ALPHA-X2 = ALPHA-X2 + 1.
              IF ALPHA-X2 > 90.
                ALPHA-X1 = ALPHA-X1 + 1.
                ALPHA-X2 = 65.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
*
        CLEAR DFIES-FIELDTEXT.
        IF DYNFLOW-FNAM = 'BDC_OKCODE'.
          DFIES-FIELDTEXT = 'F_CODE'.
          FORMAT COLOR COL_GROUP.
        ELSE.
          FORMAT COLOR COL_NORMAL.
          PERFORM GET_FIELDNAME.
        ENDIF.
*
        WRITE: ALPHA-X1 TO L_X1,
               ALPHA-X2 TO L_X2.
        CONCATENATE '\X\' L_X1
                    '\X\' L_X2 INTO L_HEX.

        CALL FUNCTION 'STPU1_HEX_TO_CHAR'
          EXPORTING
            HEX_STRING  = L_HEX
          IMPORTING
            CHAR_STRING = L_CHAR.
*
        MOVE L_CHAR TO L_ALPHA.
*
        WRITE: /6 DYNFLOW-FNAM(25) COLOR COL_POSITIVE,
               31 DFIES-FIELDTEXT(30).
        IF DYNFLOW-FNAM = 'BDC_OKCODE'.
          DATA: LEN TYPE I, POS TYPE I.
        ELSEIF ( X_DEFLT = 'X' AND DYNFLOW-FVAL NE SPACE ).
          WRITE 61(5) '.'.
        ELSE.
          WRITE:61(5) L_ALPHA COLOR COL_TOTAL.
          ADD 1 TO FNAM-ORDER.
          MOVE DYNFLOW-FNAM  TO FNAM-FNAM.
          APPEND FNAM.
        ENDIF.
*
        IF ICODE = 'TESTING'.
          READ TABLE SAV_DF INDEX DYN_TABIX.
          DYNFLOW-FVAL = SAV_DF-FVAL.
        ENDIF.
*
        IF DYNFLOW-FNAM = 'BDC_OKCODE'.
          WRITE: 66 DYNFLOW-FVAL.
*          len = STRLEN( dynflow-fval ).
          LEN = 6.
          POS = 66 + LEN + 1.
          WRITE AT POS(1) F_TEST
            QUICKINFO 'Test Function'
            INPUT COLOR COL_NEGATIVE.
        ELSE.
          WRITE: 66 DYNFLOW-FVAL.
        ENDIF.
        HIDE: DYN_TABIX.
*
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " put_screen_template
*&---------------------------------------------------------------------*
*&      Form  upload_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD_DATA.
*
  IF P_FRPC = 'X'.
    PERFORM CALL_OPEN_DIALOG.
    IF SY-SUBRC = 0.
      PERFORM SET_EXTENSION.
      IF P_EXCEL = 'X'.
        PERFORM UPLOAD_EXCEL.
      ELSEIF P_TAB = 'X'.
        PERFORM WS_UPLOAD.
      ENDIF.
    ENDIF.
  ELSE.
    DATA: OPEN_MSG(80).
    OPEN DATASET P_FNAME FOR INPUT IN TEXT MODE
                         ENCODING DEFAULT MESSAGE OPEN_MSG.
    IF SY-SUBRC NE 0.
      MESSAGE S453(00) WITH 'Data Open error :' OPEN_MSG.
      EXIT.
    ENDIF.
*
    MESSAGE S453(00) WITH 'Reading...' SPACE.
    DO.
      READ DATASET P_FNAME INTO INDATA.
      IF SY-SUBRC NE 0. EXIT. ENDIF.
      APPEND INDATA.
    ENDDO.
    CLOSE DATASET P_FNAME.
  ENDIF.
*
  SET PARAMETER ID 'DLF' FIELD P_FNAME.
*
ENDFORM.                               " upload_data
*&---------------------------------------------------------------------*
*&      Form  make_bdc_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_BDC_DATA.
*
  PERFORM READ_INPUT_VALUE_FROM_LIST.
*
  CLEAR BDC_COUNT.
  CLEAR:START, END, DATA, FIELDNAME.
*
  IF ICODE = 'UPLOAD' OR ICODE = 'TESTONE' OR ICODE = 'CLIP'.
    NEW-PAGE LINE-SIZE 255.
  ENDIF.
*
  LOOP AT INDATA.
    IF INDATA(1) = '*'.                "comment row
      CONTINUE.
    ENDIF.
*
    IF INDATA(9) = 'STARTDATA'.        "data start row
      START = 'X'.
      DATA  = 'X'.
      IF FIELDNAME = SPACE.
        FORD[] = FNAM[].
      ENDIF.
      CLEAR FIELDNAME.
    ENDIF.
*
    IF INDATA(7) = 'ENDDATA'.          "data finished row
      END = 'X'.
    ENDIF.
*
    IF INDATA(9) = 'FIELDNAME'.
      FIELDNAME = 'X'.
    ENDIF.
*
    CHECK DATA      = 'X' OR
          FIELDNAME = 'X'.
*
    LEN = STRLEN( INDATA ).
    CLEAR: N,O,SEQ,DAT.
    REFRESH BDC_VALUE.
    DO.
      IF N => LEN.
        EXIT.
      ENDIF.
*
      CH = INDATA+N(1).
      IF CH = TAB.
        SEQ = SEQ + 1.
        PERFORM MOVE_BDC.
        ADD 1 TO N.
        CLEAR: O, DAT.
      ELSE.
        DAT+O(1) = INDATA+N(1).
        ADD 1 TO: O, N.
      ENDIF.
    ENDDO.
*
    SEQ = SEQ + 1.
    PERFORM MOVE_BDC.
    CLEAR DAT.
*
    IF DATA = 'X'.
      PERFORM APPEND_TO_BDC.
    ENDIF.
*
    IF END = 'X' OR
      ( ( ICODE NE 'UPLOAD' AND ICODE NE 'CLIP' )
        AND ( START = 'X' ) ).
      EXIT.
    ENDIF.
  ENDLOOP.
*
  PERFORM CLOSE_BDC_GROUP.
*
  IF START IS INITIAL.
    WRITE: / 'ERROR :' COLOR COL_NEGATIVE,
             'I Can''t found the ''STARTDATA'' tag.'.
  ENDIF.
*
  IF SY-SUBRC = 0.
    IF ( ICODE = 'UPLOAD' OR
         ICODE = 'CLIP' ) AND X_SES = 'X'.
      WRITE: / SESSION COLOR 5 HOTSPOT.
      ULINE.
      WRITE: / 'BDC session created.',
             / SY-ULINE,
             / 'BDC session :', BDCGROUP,
             / 'BDC Count   :', BDC_COUNT.
    ELSEIF ICODE = 'TESTING'.
      PERFORM PUT_SCREEN_TEMPLATE.
      SY-LSIND = SY-LSIND - 1.
    ENDIF.
  ENDIF.
*
  REFRESH INDATA.
*
ENDFORM.                               " make_bdc_data
*&---------------------------------------------------------------------*
*&      Form  move_bdc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MOVE_BDC.
*
  CLEAR FORD.
*
  CHECK SEQ > 1.
  IF DATA = 'X'.  "DATA line
    BDC_VALUE = DAT.
    IF CONDENS = 'X'.
      CONDENSE BDC_VALUE.
    ENDIF.
    APPEND BDC_VALUE.
  ELSEIF FIELDNAME = 'X'.
    BDC_VALUE = DAT.
    CONDENSE BDC_VALUE.
    READ TABLE FNAM WITH KEY FNAM = BDC_VALUE.
    IF SY-SUBRC = 0.
      FORD-ORDER = FNAM-ORDER.
      FORD-FNAM  = FNAM-FNAM.
      APPEND FORD.
*      MODIFY fnam INDEX sy-tabix TRANSPORTING order.
    ELSE.
      FORD-FNAM  = BDC_VALUE.
      FORD-ORDER = SEQ - 1.
      APPEND FORD.
    ENDIF.
  ENDIF.
ENDFORM.                               " move_bdc
*&---------------------------------------------------------------------*
*&      Form  append_to_bdc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM APPEND_TO_BDC.
*
  CLEAR: BDC_VALUE, BDC_INDEX.
  REFRESH BDC_DATA.
*
  LOOP AT DYNFLOW.
*
    MOVE SY-TABIX TO DYN_TABIX.
*
    IF DYNFLOW-DYNBEGIN = 'T'.
      CONTINUE.
    ENDIF.
*
    BDC_DATA = DYNFLOW.
    IF BDC_DATA-DYNBEGIN = 'X' OR     "Start of Screen
       BDC_DATA-FNAM(4)  = 'BDC_'.    "BDC_... fields
*     delete okcode for test
      READ TABLE MOD_FCODE WITH KEY TABIX = DYN_TABIX.
      IF SY-SUBRC = 0 AND MOD_FCODE-F_TEST = NODATA.
        MOVE '/N' TO BDC_DATA-FVAL.
      ENDIF.
*
      APPEND BDC_DATA.
      CONTINUE.
    ENDIF.
*
    IF X_DEFLT = 'X' AND NOT BDC_DATA-FVAL IS INITIAL.
      APPEND BDC_DATA.
      CONTINUE.
    ENDIF.
*
    ADD 1 TO BDC_INDEX.
    READ TABLE FORD INDEX BDC_INDEX.
    IF SY-SUBRC = 0.
      READ TABLE BDC_VALUE INDEX FORD-ORDER.
      IF SY-SUBRC NE 0.
        CLEAR BDC_VALUE.
      ENDIF.
    ENDIF.
    IF BDC_VALUE = '!'.                " null field
      CONTINUE.
    ENDIF.
*
    BDC_DATA-FVAL = BDC_VALUE.
    APPEND BDC_DATA.
  ENDLOOP.
*
  IF ICODE = 'TESTING'.
    CLEAR BDC_INDEX.
    REFRESH SAV_DF.
    CLEAR SAV_DF.
    LOOP AT DYNFLOW INTO SAV_DF.
      IF SAV_DF-DYNBEGIN = 'T'.
        APPEND SAV_DF.
        CONTINUE.
      ENDIF.
*
      IF SAV_DF-DYNBEGIN = 'X' OR
         SAV_DF-FNAM(4)  = 'BDC_'.
        APPEND SAV_DF.
        CONTINUE.
      ENDIF.
*
      IF X_DEFLT = 'X' AND NOT SAV_DF-FVAL IS INITIAL.
        APPEND SAV_DF.
        CONTINUE.
      ENDIF.
*
      ADD 1 TO BDC_INDEX.
      READ TABLE FORD INDEX BDC_INDEX.
      IF SY-SUBRC = 0.
        READ TABLE BDC_VALUE INDEX FORD-ORDER.
        IF SY-SUBRC NE 0.
          BDC_VALUE = '!!'.
        ENDIF.
      ELSE.
        BDC_VALUE = '!!'.
      ENDIF.
      IF BDC_VALUE = X_NULIND OR       " null field
         BDC_VALUE = '!!'.
        SAV_DF-FVAL = '<Null>'.
        APPEND SAV_DF.
        CLEAR SAV_DF.
        CONTINUE.
      ENDIF.
      SAV_DF-FVAL = BDC_VALUE.
      APPEND SAV_DF.
    ENDLOOP.
  ENDIF.
*
  ADD 1 TO BDC_COUNT.
*
  IF BDC_COUNT = 1 AND ICODE = 'UPLOAD'.
    PERFORM OPEN_BDC_GROUP.
  ENDIF.
*
  IF X_SES = 'X'.
    IF ICODE = 'UPLOAD' OR ICODE = 'CLIP'.
      PERFORM BDC_INSERT.
    ENDIF.
  ELSEIF ICODE = 'TESTONE' OR ICODE = 'UPLOAD'
                           OR ICODE = 'CLIP'.
    CCODE(1) = TAB.
    TRANSLATE INDATA USING CCODE.
    FORMAT COLOR COL_KEY INTENSIFIED OFF.
    WRITE: /(5) BDC_COUNT , INDATA(120).
*   call transaction
    PERFORM CALL_TRANSACTION.
  ENDIF.
ENDFORM.                               " append_to_bdc
*&---------------------------------------------------------------------*
*&      Form  open_bdc_group
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM OPEN_BDC_GROUP.
*
  CHECK X_SES = 'X'.
*
  CALL FUNCTION 'BDC_OPEN_GROUP'
    EXPORTING
      CLIENT              = SY-MANDT
      GROUP               = BDCGROUP
      USER                = USERNAME
      KEEP                = 'X'
    EXCEPTIONS
      CLIENT_INVALID      = 1
      DESTINATION_INVALID = 2
      GROUP_INVALID       = 3
      GROUP_IS_LOCKED     = 4
      HOLDDATE_INVALID    = 5
      INTERNAL_ERROR      = 6
      QUEUE_ERROR         = 7
      RUNNING             = 8
      SYSTEM_LOCK_ERROR   = 9
      USER_INVALID        = 10
      OTHERS              = 11.
*
  IF SY-SUBRC NE 0.
    MESSAGE E435(00) WITH 'BDC GROUP Open Error !'.
  ENDIF.
*
ENDFORM.                               " open_bdc_group
*&---------------------------------------------------------------------*
*&      Form  close_bdc_group
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CLOSE_BDC_GROUP.
*
  CHECK X_SES = 'X'.
  CHECK ICODE = 'UPLOAD' OR ICODE = 'CLIP'.
  CALL FUNCTION 'BDC_CLOSE_GROUP'
    EXCEPTIONS
      NOT_OPEN    = 1
      QUEUE_ERROR = 2
      OTHERS      = 3.
*
ENDFORM.                               " close_bdc_group
*&---------------------------------------------------------------------*
*&      Form  set_select_options
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SELECT_OPTIONS.
*
  IF P_GRPID CP '*'.
    R_GRPID-OPTION = 'CP'.
    R_GRPID-SIGN = 'I'.
    R_GRPID-LOW = P_GRPID.
    APPEND R_GRPID.
  ELSEIF P_GRPID NE SPACE.
    R_GRPID-OPTION = 'EQ'.
    R_GRPID-SIGN = 'I'.
    R_GRPID-LOW = P_GRPID.
    APPEND R_GRPID.
  ENDIF.
*
  IF NOT P_CREDT IS INITIAL.
    R_CREDT-OPTION = 'EQ'.
    R_CREDT-SIGN = 'I'.
    R_CREDT-LOW = P_CREDT.
    APPEND R_CREDT.
  ENDIF.
*
  IF NOT P_CREUR IS INITIAL.
    R_CREUR-OPTION = 'EQ'.
    R_CREUR-SIGN = 'I'.
    R_CREUR-LOW = P_CREUR.
    APPEND R_CREUR.
  ENDIF.
ENDFORM.                               " set_select_options
*&---------------------------------------------------------------------*
*&      Form  PROCESS_SESSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_SESSION.
*
  SET PARAMETER ID 'MPN' FIELD BDCGROUP.
*
  CALL TRANSACTION 'SM35' AND SKIP FIRST SCREEN.

ENDFORM.                               " PROCESS_SESSION
*&---------------------------------------------------------------------*
*&      Form  GET_FIELDNAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FIELDNAME.
*
  DATA: T_LINE_NR(4).
*
  CLEAR FTEXT.
*
  F-ITYP = '2'.
  F-FNAM = DYNFLOW-FNAM.
  READ TABLE F WITH KEY FNAM = F-FNAM
                        ITYP = F-ITYP.
*
*  IF sy-subrc = 0 AND f-stxt NE space.
*    dfies-fieldtext = f-stxt.
*    EXIT.
*  ENDIF.
*
  IF DYNFLOW-FNAM CA '-'.
    X031L-TABNAME   = DYNFLOW-FNAM(SY-FDPOS).
    SY-FDPOS = SY-FDPOS + 1.
    X031L-FIELDNAME = DYNFLOW-FNAM+SY-FDPOS.
  ELSE.
    CLEAR SY-FDPOS.
    CLEAR X031L-FIELDNAME.
    X031L-FIELDNAME = DYNFLOW-FNAM+SY-FDPOS.
  ENDIF.
*
  CLEAR T_LINE_NR.
  IF X031L-FIELDNAME CA '('.
    T_LINE_NR = X031L-FIELDNAME+SY-FDPOS.
    X031L-FIELDNAME = X031L-FIELDNAME(SY-FDPOS).
  ENDIF.
*
  READTYPE = 'X'.
  CLEAR DFIES.
*
  DO.
    CALL 'C_DD_READ_FIELD'
         ID 'TYPE'      FIELD READTYPE
         ID 'TABNAME'   FIELD X031L-TABNAME
         ID 'FIELDNAME' FIELD X031L-FIELDNAME
         ID 'LANGUAGE'  FIELD SY-LANGU.
    IF SY-SUBRC = 0. EXIT. ENDIF.
    IF READTYPE = SPACE. EXIT. ENDIF.
    CLEAR READTYPE.
  ENDDO.
*
  MOVE DFIES-OUTPUTLEN TO FTEXT-OUTPUTLEN.
  MOVE DFIES-SCRTEXT_S TO FTEXT-SCRTEXT_S.
  MOVE DFIES-SCRTEXT_M TO FTEXT-SCRTEXT_M.
  MOVE DFIES-SCRTEXT_L TO FTEXT-SCRTEXT_L.
  MOVE DYN_TABIX       TO FTEXT-TABIX.
  MOVE T_LINE_NR       TO FTEXT-LINENO.
  APPEND FTEXT.
*
ENDFORM.                               " GET_FIELDNAME
*&---------------------------------------------------------------------*
*&      Form  BDC_INSERT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BDC_INSERT.
*
  CALL FUNCTION 'BDC_INSERT'
    EXPORTING
      TCODE          = TRANCODE
    TABLES
      DYNPROTAB      = BDC_DATA
    EXCEPTIONS
      INTERNAL_ERROR = 1
      NOT_OPEN       = 2
      QUEUE_ERROR    = 3
      TCODE_INVALID  = 4
      OTHERS         = 5.
*
  IF SY-SUBRC NE 0.
    MESSAGE E435(00) WITH 'BDC INSERT Error !'.
  ENDIF.
ENDFORM.                               " BDC_INSERT
*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_TRANSACTION.
*
  DATA: W_DMODE LIKE CTU_PARAMS-DISMODE VALUE 'A'.
*
  IF ICODE = 'UPLOAD'.
    W_DMODE = DMODE.
  ENDIF.
*
  REFRESH MESSTAB.
*
  BDC_PARAMS-DISMODE  = W_DMODE.
  BDC_PARAMS-UPDMODE  = UMODE.
  BDC_PARAMS-CATTMODE = SPACE.
  BDC_PARAMS-DEFSIZE  = 'X'.
  BDC_PARAMS-RACOMMIT = SPACE.
  BDC_PARAMS-NOBINPT  = SPACE.
  BDC_PARAMS-NOBIEND  = SPACE.
*
  CALL TRANSACTION TRANCODE USING BDC_DATA
                     OPTIONS    FROM BDC_PARAMS
*                   MODE     w_dmode
*                   UPDATE   umode
                   MESSAGES INTO MESSTAB.
*
  TRAN_SUBRC = SY-SUBRC.
*
  PERFORM WRITE_MESSAGE TABLES MESSTAB.
*
ENDFORM.                               " CALL_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  WRITE_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MESSTAB  text
*----------------------------------------------------------------------*
FORM WRITE_MESSAGE TABLES   P_MESSTAB STRUCTURE MESSTAB.
*
  DATA: MSG_TYPE(10).
*
  LOOP AT P_MESSTAB.
    SELECT SINGLE * FROM T100 WHERE SPRSL = P_MESSTAB-MSGSPRA
                              AND   ARBGB = P_MESSTAB-MSGID
                              AND   MSGNR = P_MESSTAB-MSGNR.
    CASE P_MESSTAB-MSGTYP.
      WHEN 'E'.
        FORMAT COLOR COL_NEGATIVE  INTENSIFIED OFF.
        MOVE '<EEEEE>' TO MSG_TYPE.
      WHEN 'W'.
        FORMAT COLOR COL_TOTAL     INTENSIFIED ON.
        MOVE '<WWWWW>' TO MSG_TYPE.
      WHEN 'S'.
        FORMAT COLOR COL_POSITIVE  INTENSIFIED OFF.
        MOVE '<SSSSS>' TO MSG_TYPE.
      WHEN 'I'.
        FORMAT COLOR COL_NORMAL    INTENSIFIED OFF.
        MOVE '<IIIII>' TO MSG_TYPE.
      WHEN 'A'.
        FORMAT COLOR COL_GROUP     INTENSIFIED ON.
        MOVE '<AAAAA>' TO MSG_TYPE.
        IF P_MESSTAB-MSGNR = '359' AND
           P_MESSTAB-MSGID = '00'.
          CONTINUE.
        ENDIF.
      WHEN 'X'.
        FORMAT COLOR COL_GROUP     INTENSIFIED ON.
        MOVE '<XXXXX>' TO MSG_TYPE.
      WHEN OTHERS.
        FORMAT COLOR COL_BACKGROUND INTENSIFIED ON.
        MOVE '<?????>' TO MSG_TYPE.
    ENDCASE.
*
    IF SY-SUBRC = 0.
      L_MSTRING = T100-TEXT.
      IF L_MSTRING CS '&1'.
        REPLACE '&1' WITH P_MESSTAB-MSGV1 INTO L_MSTRING.
        REPLACE '&2' WITH P_MESSTAB-MSGV2 INTO L_MSTRING.
        REPLACE '&3' WITH P_MESSTAB-MSGV3 INTO L_MSTRING.
        REPLACE '&4' WITH P_MESSTAB-MSGV4 INTO L_MSTRING.
      ELSE.
        REPLACE '&' WITH P_MESSTAB-MSGV1 INTO L_MSTRING.
        REPLACE '&' WITH P_MESSTAB-MSGV2 INTO L_MSTRING.
        REPLACE '&' WITH P_MESSTAB-MSGV3 INTO L_MSTRING.
        REPLACE '&' WITH P_MESSTAB-MSGV4 INTO L_MSTRING.
      ENDIF.
      CONDENSE L_MSTRING.
      WRITE: /11 MSG_TYPE, P_MESSTAB-MSGID(4),
                           P_MESSTAB-MSGNR, L_MSTRING(120).
    ELSE.
      WRITE: /11 MSG_TYPE, P_MESSTAB-MSGID(4),
                           P_MESSTAB-MSGNR.
    ENDIF.
  ENDLOOP.
  IF TRAN_SUBRC NE 0.
    IF F_TEST IS INITIAL.
      FORMAT COLOR COL_NEGATIVE  INTENSIFIED OFF.
      WRITE: /11 'TRAN_SUBRC:', TRAN_SUBRC.
    ELSE.
      FORMAT COLOR COL_TOTAL  INTENSIFIED OFF.
      WRITE: /11 '<TESTMODE>:', TRAN_SUBRC.
    ENDIF.
  ENDIF.
ENDFORM.                               " WRITE_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  SAVE_RECORDING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_RECORDING.
*
*  APPEND apgitab TO xdat.
*
*  LOOP AT dynflow.
*    xdat = dynflow. APPEND xdat.
*  ENDLOOP.
*
*  CALL FUNCTION 'DOWNLOAD'
*    EXPORTING
*      filename     = filename
*      filetype     = filetype
*    IMPORTING
*      act_filename = act_filename
*      filesize     = filesize
*    TABLES
*      data_tab     = xdat.
*
*  IF filesize > 0.
*    MESSAGE i208(00) WITH 'Donwload finished.'.
*  ENDIF.
  MESSAGE I208(00) WITH 'Not Supported.'.
ENDFORM.                               " SAVE_RECORDING
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_THE_RECORDING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD_THE_RECORDING.
*
  MESSAGE I398(00) WITH 'Not Supported.'.
*
  EXIT.
*
  FILENAME = P_RFILE.
*
  CALL FUNCTION 'WS_UPLOAD'
    EXPORTING
      FILENAME         = FILENAME
      FILETYPE         = 'ASC'
    IMPORTING
      FILELENGTH       = FILESIZE
    TABLES
      DATA_TAB         = XDAT
    EXCEPTIONS
      FILE_OPEN_ERROR  = 1
      FILE_WRITE_ERROR = 2.
*
  IF FILESIZE = 0.
    CALL FUNCTION 'UPLOAD'
      EXPORTING
        FILENAME     = FILENAME
        FILETYPE     = FILETYPE
      IMPORTING
        ACT_FILENAME = ACT_FILENAME
        FILESIZE     = FILESIZE
      TABLES
        DATA_TAB     = XDAT.
  ENDIF.
  P_RFILE = ACT_FILENAME.
  SET PARAMETER ID 'DLP' FIELD P_RFILE.
*
*  IF filesize > 0.
*    LOOP AT xdat.
*      IF sy-tabix = 1.
*        apqitab = xdat.
*        IF apqitab-datatyp = '%BDC'.
*          APPEND apqitab.
*        ENDIF.
*        CONTINUE.
*      ENDIF.
*      dynflow = xdat.    APPEND dynflow.
*    ENDLOOP.
*    CLEAR p_grpid.
*  ENDIF.
*  REFRESH xdat.
ENDFORM.                               " UPLOAD_THE_RECORDING
*----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  call_open_dialog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_OPEN_DIALOG .
*
  IF P_FNAME <> SPACE.
    MOVE P_FNAME TO G_FNAME.
    SET PARAMETER ID 'GR9' FIELD G_FNAME. "Upload path
  ELSE.

  ENDIF.
*
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_FILENAME     = G_FNAME
      MASK             = G_MASK
      MODE             = G_MODE_OPEN
      TITLE            = G_TITLE
    IMPORTING
      FILENAME         = G_FNAME
    EXCEPTIONS
      INV_WINSYS       = 01
      NO_BATCH         = 02
      SELECTION_CANCEL = 03
      SELECTION_ERROR  = 04.
*
  IF SY-SUBRC = 0 AND G_FNAME <> SPACE.
    P_FNAME = G_FNAME.
    SET PARAMETER ID 'GR9' FIELD G_FNAME. "Upload path
  ELSE.
  ENDIF.
*
ENDFORM.                    " call_open_dialog
*&---------------------------------------------------------------------*
*&      Form  set_extension
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_EXTENSION .
  DATA: L_LEN TYPE I,
        L_PF_FILE LIKE DRAW-FILEP,
        L_EXT(30).

  L_PF_FILE = P_FNAME.

  CALL FUNCTION 'CV120_SPLIT_FILE'
    EXPORTING
      PF_FILE          = L_PF_FILE
    IMPORTING
*     PFX_FILE         =
*     PFX_EXTENSION    = L_EXTENSION
      PFX_DOTEXTENSION = L_EXT.

  TRANSLATE L_EXT TO UPPER CASE.

  IF L_EXT = '.TXT'.
    CLEAR P_EXCEL.
    MOVE 'X' TO P_TAB.
  ELSEIF L_EXT = '.XLS' OR
         L_EXT = '.XLSX'.
    CLEAR P_TAB.
    MOVE 'X' TO P_EXCEL.
  ELSE.
    CLEAR: P_EXCEL, P_TAB.
  ENDIF.

*  L_LEN = STRLEN( P_FNAME ).
*  IF L_LEN > 4.
*    L_LEN = L_LEN - 4.
*    EXT = P_FNAME+L_LEN(4).
*    TRANSLATE EXT TO UPPER CASE.
*    IF EXT = '.TXT'.
*      CLEAR P_EXCEL.
*      MOVE 'X' TO P_TAB.
*    ELSEIF EXT = '.XLS' OR
*           EXT = '.XLSX'.
*      CLEAR P_TAB.
*      MOVE 'X' TO P_EXCEL.
*    ELSE.
*      CLEAR: P_EXCEL, P_TAB.
*    ENDIF.
*  ENDIF.
*
ENDFORM.                    " set_extension
*&---------------------------------------------------------------------*
*&      Form  WS_UPLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM WS_UPLOAD .
*
  DATA: ACT_FILENAME LIKE RLGRAP-FILENAME,
        F_LEN TYPE I.
*
  REFRESH INDATA.
*
  CALL FUNCTION 'WS_UPLOAD'
    EXPORTING
      FILENAME                = P_FNAME
      FILETYPE                = 'ASC'
    IMPORTING
      FILELENGTH              = F_LEN
    TABLES
      DATA_TAB                = INDATA
    EXCEPTIONS
      CONVERSION_ERROR        = 1
      INVALID_TABLE_WIDTH     = 2
      INVALID_TYPE            = 3
      NO_BATCH                = 4
      GUI_REFUSE_FILETRANSFER = 5
      UNKNOWN_ERROR           = 6
      OTHERS                  = 7.
*
  IF SY-SUBRC NE 0.
    MESSAGE I398(00) WITH 'Data Open error'.
  ENDIF.
ENDFORM.                    " WS_UPLOAD
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_EXCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD_EXCEL .
*
  DATA : EXDAT LIKE ALSMEX_TABLINE OCCURS 0 WITH HEADER LINE.
  DATA : E_SRT_COL   TYPE I VALUE 1,
         E_SRT_ROW   TYPE I VALUE 1,
         E_END_COL   TYPE I VALUE 26,
         E_END_ROW   TYPE I VALUE 65536.
*
* UPLOAD EXCEL FILE
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME                = P_FNAME
      I_BEGIN_COL             = E_SRT_COL
      I_BEGIN_ROW             = E_SRT_ROW
      I_END_COL               = E_END_COL
      I_END_ROW               = E_END_ROW
    TABLES
      INTERN                  = EXDAT
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2.
*
  IF SY-SUBRC <> 0.
    MESSAGE I398(00) WITH 'Data Upload Error !'.
  ENDIF.
*
ENDFORM.                    " UPLOAD_EXCEL
*&---------------------------------------------------------------------*
*&      Form  paste_from_clip
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PASTE_FROM_CLIP .
*
  DATA: FILE_TABLE TYPE FILETABLE,
        RC TYPE I,
        FILEDAT TYPE STRING.
  DATA: FILE_TABLE_CLIP TYPE STANDARD TABLE OF FILE_TABLE.
*
  DATA: BEGIN OF FILE_TAB OCCURS 1,
      ZEILE(500) TYPE C,
      END OF FILE_TAB.
*
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>CLIPBOARD_IMPORT
    IMPORTING
      DATA                 = FILE_TABLE_CLIP
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      NOT_SUPPORTED_BY_GUI = 3
      OTHERS               = 4.
  IF SY-SUBRC = 3.
    MESSAGE E888(DB). EXIT.
  ELSEIF SY-SUBRC <> 0.
    MESSAGE E889(DB). EXIT.
  ENDIF.

  INDATA[] = FILE_TABLE_CLIP[].
*
ENDFORM.                    " paste_from_clip
*&---------------------------------------------------------------------*
*&      Form  read_input_value_from_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_INPUT_VALUE_FROM_LIST .
*
  REFRESH MOD_FCODE.
*
  DO.
    CLEAR: F_TEST, DYN_TABIX.
    READ LINE SY-INDEX FIELD VALUE F_TEST DYN_TABIX.
    IF SY-SUBRC NE 0.
      EXIT.
    ENDIF.
    IF F_TEST = NODATA.
      MOVE F_TEST    TO MOD_FCODE-F_TEST.
      MOVE DYN_TABIX TO MOD_FCODE-TABIX.
      APPEND MOD_FCODE.
    ENDIF.
  ENDDO.
*
  CLEAR F_TEST.
  DESCRIBE TABLE MOD_FCODE LINES SY-TFILL.
  IF SY-TFILL > 0.
    MOVE 'X' TO F_TEST.
  ENDIF.
ENDFORM.                    " read_input_value_from_list
*&---------------------------------------------------------------------*
*&      Form  make_template_in_excel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_TEMPLATE_IN_EXCEL .
*
  CREATE OBJECT EXCEL 'EXCEL.APPLICATION'.
*
  CALL METHOD OF
      EXCEL
      'APPLICATION' = APPL.
  SET PROPERTY OF APPL 'STANDARDFONT' = E_FONT.
  SET PROPERTY OF APPL 'STANDARDFONTSIZE' = E_SIZE.
*
  CALL METHOD OF
      EXCEL
      'WORKBOOKS' = BOOKS.
  CALL METHOD OF BOOKS 'ADD' = BOOK.  "ADD, OPEN
*
  CALL METHOD OF
      BOOK
      'sheets' = SHEETS.
  CALL METHOD OF
      SHEETS
      'item' = SHEET
    EXPORTING
      #1     = 1.
  CALL METHOD OF
      SHEET
      'Activate'.
*
  CALL METHOD OF
      SHEET
      'cells' = CELLS.
*
  LOOP AT DYNFLOW.
*
    MOVE SY-TABIX TO DYN_TABIX.
*
    IF DYNFLOW-DYNBEGIN = 'T'.         " Tcode
*     Write Header Title to Excel
      MOVE DYNFLOW-FNAM TO E_SHEET_NAME.
      SET PROPERTY OF SHEET 'NAME' = E_SHEET_NAME. " Name of Sheet

      CONCATENATE '*' TSTCT-TTEXT '(TCODE:' TRANCODE ')/'
                  'Recording:' APQI-GROUPID
                  '(' X_DEFLT ')' INTO XL_TITLE.
*
      PERFORM XL_PUT_TO_CELL USING 1 1 XL_TITLE.
      PERFORM XL_PUT_TO_CELL USING 2 1 '*Text:'.
      PERFORM XL_PUT_TO_CELL USING 3 1 'FIELDNAME'.
*
      PERFORM XL_PUT_TO_CELL USING 4  1 'STARTDATA'.
      PERFORM XL_PUT_TO_CELL USING 24 1 'ENDDATA'.
      XL_ROW = 2.
      XL_COLUMN = 1.
    ELSEIF DYNFLOW-DYNBEGIN = SPACE.
*      e_size = 9.
*      SET PROPERTY OF sheet 'STANDARDFONTSIZE' = e_size.
      IF DYNFLOW-FNAM(4) NE 'BDC_'.
        IF NOT ( X_DEFLT = 'X' AND DYNFLOW-FVAL NE SPACE ).
          ADD 1 TO XL_COLUMN.
*
          READ TABLE FTEXT WITH KEY TABIX = DYN_TABIX.
          IF SY-SUBRC = 0.
            IF FTEXT-LINENO NE SPACE.
              CONCATENATE FTEXT-SCRTEXT_M FTEXT-LINENO INTO
FTEXT-SCRTEXT_M.
            ENDIF.
            PERFORM XL_PUT_TO_CELL USING XL_ROW XL_COLUMN
FTEXT-SCRTEXT_M.
          ENDIF.
*
          XL_ROW = XL_ROW + 1.
          PERFORM XL_PUT_TO_CELL USING XL_ROW XL_COLUMN DYNFLOW-FNAM.
*
          XL_ROW = XL_ROW + 1.
          IF DYNFLOW-FVAL NE SPACE.
            PERFORM XL_PUT_TO_CELL USING XL_ROW XL_COLUMN DYNFLOW-FVAL.
          ENDIF.
          XL_ROW = XL_ROW - 2.

        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
*
  SET PROPERTY OF EXCEL 'VISIBLE' = 1.
*
  FREE OBJECT CELLS.
  FREE OBJECT SHEET.
  FREE OBJECT SHEETS.
  FREE OBJECT BOOK.
  FREE OBJECT BOOKS.
  FREE OBJECT APPL.
  FREE OBJECT EXCEL.
*
ENDFORM.                    " make_template_in_excel
*
FORM XL_PUT_TO_CELL USING ROW COL VALUE.
* here you get the CELL object
  CALL METHOD OF
      CELLS
      'ITEM' = CELL
    EXPORTING
      #1     = ROW
      #2     = COL.
* here you use the CELL object
  SET PROPERTY OF CELL 'VALUE' = VALUE. " write VALUE to the excel cell
  GET PROPERTY OF CELL 'FONT'  = FONT.
*
  IF ROW = 1.
    SET PROPERTY OF FONT 'BOLD' = 1.
    SET PROPERTY OF FONT 'SIZE' = 14.
  ELSE.
    SET PROPERTY OF FONT 'BOLD' = 0.
    SET PROPERTY OF FONT 'SIZE' = 9.
  ENDIF.
*
  FREE OBJECT CELL.
  FREE OBJECT FONT.
*
ENDFORM.                    "FILL_CELL
