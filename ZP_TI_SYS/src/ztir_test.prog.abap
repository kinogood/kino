report ZTIR_TEST message-id ok.

TABLES: MARA, MARC, MAST, T001W, MARD.

DATA: FTREL  LIKE CSDATA-XFELD    VALUE SPACE,
      ALTVO  LIKE CSDATA-XFELD    VALUE SPACE,
      AUMGB  LIKE CSDATA-XFELD    VALUE SPACE,
      AUMNG  LIKE STKO-BMENG      VALUE 0,
      AUSKZ  LIKE CSDATA-XFELD    VALUE SPACE,
      AMIND  LIKE CSDATA-XFELD    VALUE SPACE,
      BAGRP  LIKE MARA-MATNR      VALUE SPACE,
      BEIKZ  LIKE STPO-BEIKZ      VALUE SPACE,
      BESSL  LIKE CSDATA-XFELD    VALUE SPACE,
      BGIXO  LIKE CSDATA-XFELD    VALUE SPACE,
      BREMS  LIKE CSDATA-XFELD    VALUE SPACE,
      CAPID  LIKE TC04-CAPID      VALUE 'PP01',
      COSPR  LIKE CSDATA-XFELD    VALUE SPACE,
      CUOBJ  LIKE MARC-CUOBJ      VALUE 0000000000000,
      CUOLS  LIKE CSDATA-XFELD    VALUE SPACE,
      DELNL  LIKE CSDATA-XFELD    VALUE SPACE,
      EHNDL  LIKE CSDATA-XFELD    VALUE SPACE,
      ERSKZ  LIKE STPO-ERSKZ      VALUE SPACE,
      ERSSL  LIKE CSDATA-XFELD    VALUE SPACE,
      FBSTP  LIKE CSDATA-XFELD    VALUE SPACE,
      MKTLS  LIKE CSDATA-XFELD    VALUE 'X',
      MDMPS  LIKE CSDATA-XFELD    VALUE SPACE,
      MKMAT  LIKE CSDATA-XFELD    VALUE SPACE,
      MMAPS  LIKE CSDATA-XFELD    VALUE SPACE,
      POSTP  LIKE STPO-POSTP      VALUE SPACE,
      RNDKZ  LIKE CSDATA-XFELD    VALUE '1',             "SPACE,
      RVREL  LIKE STPO-RVREL      VALUE SPACE,
      SANFR  LIKE STPO-SANFE      VALUE SPACE,
      SANIN  LIKE STPO-SANIN      VALUE SPACE,
      SANKA  LIKE STPO-SANKA      VALUE SPACE,
      SANKO  LIKE STPO-SANKO      VALUE SPACE,
      SANVS  LIKE STPO-SANVS      VALUE SPACE,
      SCHGT  LIKE STPO-SCHGT      VALUE SPACE,
      STKKZ  LIKE STPO-STKKZ      VALUE SPACE,
      MDNOT  LIKE CSDATA-XFELD    VALUE SPACE,
      PANOT  LIKE CSDATA-XFELD    VALUE SPACE,
      VERID  LIKE MKAL-VERID      VALUE SPACE,
      DSTST  LIKE CSDATA-XFELD.

DATA: BEGIN OF STB OCCURS 0.
        INCLUDE STRUCTURE STPOX.
DATA: END OF   STB.

DATA: BEGIN OF STB1 OCCURS 0.
        INCLUDE STRUCTURE STPOX.
DATA: END OF   STB1.

DATA: BEGIN OF MATCAT OCCURS 0.
        INCLUDE STRUCTURE CSCMAT.
DATA: END OF   MATCAT.

DATA: BEGIN OF TOPMAT OCCURS 0.
        INCLUDE STRUCTURE CSTMAT.
DATA: END OF   TOPMAT.

DATA: COL_SW(1)     TYPE C,
      LEVEL_NO(2)   TYPE P,
      LEVEL(10)     TYPE C,
      LEVEL_CHAR(4) TYPE C,
      ALT_ITEM(5)   TYPE C,
      PAGE          TYPE P,
      T_LINE        TYPE I,
      L_LINE        TYPE I,
      S_LINE        TYPE I,
      P_LINE        TYPE I,
      RATEQTY LIKE MARD-LABST,
      P_STOCK LIKE MARD-LABST,
      W_STOCK LIKE MARD-LABST,
      T_STOCK LIKE MARD-LABST,
      MATNR LIKE MARA-MATNR.

DATA: BEGIN OF I_BOM3 OCCURS 0,
        MATNR LIKE MARA-MATNR,
      END OF I_BOM3.

RANGES: A_LGORT  FOR MSEG-LGORT,
        P_LGORT  FOR MSEG-LGORT.

PARAMETERS: WERKS LIKE MAST-WERKS OBLIGATORY MEMORY ID WRK.
SELECT-OPTIONS: MATNR1 FOR MAST-MATNR OBLIGATORY MEMORY ID MAT
                                      MATCHCODE OBJECT MAT1.
PARAMETERS: STLAL LIKE MAST-STLAL OBLIGATORY,
            STLAN LIKE MAST-STLAN.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK SEL WITH FRAME TITLE TEXT-001.
*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN POSITION 2.
*PARAMETERS: R_1 RADIOBUTTON GROUP RG1.
*SELECTION-SCREEN COMMENT  4(20) TEXT-002 FOR FIELD R_1.
*SELECTION-SCREEN POSITION 31.
*PARAMETERS: R_2 RADIOBUTTON GROUP RG1.
*SELECTION-SCREEN COMMENT 33(20) TEXT-003 FOR FIELD R_2.
*SELECTION-SCREEN END   OF LINE.
PARAMETERS: VALID LIKE SY-DATUM OBLIGATORY,
            BMENG LIKE STKO-BMENG.
SELECTION-SCREEN END OF BLOCK SEL.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-004.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 3.
PARAMETERS: R1 RADIOBUTTON GROUP A.
SELECTION-SCREEN COMMENT  6(15) TEXT-005.
SELECTION-SCREEN POSITION 25.
PARAMETERS: R2 RADIOBUTTON GROUP A DEFAULT 'X'.
SELECTION-SCREEN COMMENT 28(15) TEXT-006.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK B2.
SELECTION-SCREEN BEGIN OF BLOCK B3 WITH FRAME TITLE TEXT-007.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 3.
PARAMETERS: R3 RADIOBUTTON GROUP B DEFAULT 'X'.
SELECTION-SCREEN COMMENT  6(15) TEXT-008.
SELECTION-SCREEN POSITION 25.
PARAMETERS: R4 RADIOBUTTON GROUP B.
SELECTION-SCREEN COMMENT 28(15) TEXT-009.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK B3.

INITIALIZATION.
  MOVE SY-DATUM TO VALID.
  STLAL = '01'.

AT SELECTION-SCREEN ON WERKS.
  PERFORM CHECK_PLANT.

AT SELECTION-SCREEN.
  IF STLAN =  ' '.
    SELECT SINGLE * FROM MAST WHERE WERKS = WERKS
                                AND MATNR IN MATNR1
                                AND STLAL = STLAL.
  ELSE.
    SELECT SINGLE * FROM MAST WHERE WERKS = WERKS
                                AND MATNR IN MATNR1
                                AND STLAL = STLAL
                                AND STLAN = STLAN.
  ENDIF.
  IF SY-SUBRC <> 0.
    MESSAGE E412 WITH MATNR1 'has No BOM in Plant' WERKS.
  ENDIF.

START-OF-SELECTION.
**-------------------------------------------------------*
*  PERFORM RECORD_USAGE IN PROGRAM ZSCOMP01
*                       USING SY-CPROG.
**-------------------------------------------------------*
*
  PERFORM GET_LGORT_DATA.

*  IF R_2 = 'X'.
*    EHNDL = '1'.                  " 대치자재 적용율 (Strategy '1')
*  ENDIF.
  REFRESH I_BOM3.     CLEAR I_BOM3.
  SELECT MATNR INTO CORRESPONDING FIELDS OF TABLE I_BOM3
               FROM marc
               WHERE MATNR IN MATNR1
                 AND WERKS = WERKS.
*                 AND LVORM = ' '
*                 AND MTART <> 'PROD'.
  LOOP AT I_BOM3.
    MATNR = I_BOM3-MATNR.
    CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
         EXPORTING
              ALTVO                 = ALTVO  "NULL
              AUFSW                 = ' '
              AUSKZ                 = AUSKZ  "NULL
              BAGRP                 = BAGRP  "NULL
              BEIKZ                 = BEIKZ  "NULL
              BESSL                 = BESSL  "NULL
              BREMS                 = BREMS  "NULL
              CAPID                 = CAPID  "PP01
              DATUV                 = VALID  "날짜
              EHNDL                 = EHNDL
              EMENG                 = BMENG  "0.000
              ERSKZ                 = ERSKZ                 "
              ERSSL                 = ERSSL                 "
              MBWLS                 = ' '
              MTNRV                 = MATNR  "CTNM12AL
              MEHRS                 = 'X'                   "
              MMORY                 = '1'
              POSTP                 = POSTP                 "
              SANKO                 = SANKO                 "
              SANFR                 = SANFR
              SANKA                 = SANKA
              SANIN                 = SANIN
              SANVS                 = SANVS
              RNDKZ                 = RNDKZ
              RVREL                 = RVREL
              SCHGT                 = SCHGT
              STKKZ                 = STKKZ
              STLAL                 = STLAL                 "01
              STLAN                 = STLAN
              WERKS                 = WERKS  "1101
         IMPORTING
              TOPMAT                = TOPMAT
              DSTST                 = DSTST
         TABLES
              STB                   = STB
              MATCAT                = MATCAT
         EXCEPTIONS
              MATERIAL_NOT_FOUND    = 4
              NO_PLANT_DATA         = 8
              NO_BOM_FOUND          = 12
              NO_SUITABLE_BOM_FOUND = 16
              ALT_NOT_FOUND         = 24
              MISSING_AUTHORIZATION = 28.
    CASE SY-SUBRC.
      WHEN 4.   MESSAGE S315(AT) WITH 'Material Not found'.      EXIT.
      WHEN 8.   MESSAGE S315(AT) WITH 'No plant Data!'.          EXIT.
      WHEN 12.  MESSAGE S315(AT) WITH 'No_BOM_found!'.           EXIT.
      WHEN 16.  MESSAGE S315(AT) WITH 'No suitable BOM_found!'.  EXIT.
      WHEN 24.  MESSAGE S315(AT) WITH 'Alt not found!'.          EXIT.
      WHEN 28.  MESSAGE S315(AT) WITH 'Missing authorization!'.  EXIT.
    ENDCASE.
    IF R1 = 'X'.
      NEW-PAGE LINE-SIZE 214 LINE-COUNT 65.
    ENDIF.
    SORT STB BY INDEX ALPRF ASCENDING. "descending.
    LOOP AT STB.
      CLEAR: MARC-BESKZ, MARC-LGFSB, ALT_ITEM.
      SELECT SINGLE BESKZ SOBSL LGFSB FROM MARC
               INTO (MARC-BESKZ, MARC-SOBSL, MARC-LGFSB)
                              WHERE WERKS = WERKS
                                AND MATNR = STB-IDNRK.
      IF R1 = 'X'.
        PERFORM GET_STOCK.
      ENDIF.
      IF R4 = 'X'.
        CHECK STB-MTART = 'HALB'.
      ENDIF.

      IF COL_SW = 'X'.
        FORMAT COLOR COL_NORMAL INTENSIFIED ON.
        COL_SW = ' '.
      ELSE.
        FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
        COL_SW = 'X'.
      ENDIF.
      PERFORM LEVEL.
*    CLEAR: ALT_ITEM.
*    IF STB-ALPOS = 'X' AND STB-ALPRF > '01'.
*      PERFORM ALT_ITEM.
*    ENDIF.

*      IF SY-TABIX = 1.
*        WRITE:/01 '12345678901234567890123456789012345678901234567890',
*                  '2345678901234567890123456789012345678901234567890',
*                  '23456789012345678901234567'.
*      ENDIF.

      WRITE:/01 LEVEL.                 "STB-STUFE.
      IF STB-ALPGR NE SPACE.
        WRITE:12 STB-ALPST,            " Strategy
                 STB-EWAHR,
                 STB-ALPGR,
                 STB-ALPRF.
      ELSE.
        WRITE:  ALT_ITEM.              "STB-ALPGR, STB-ALPRF,
      ENDIF.
      IF R1 = 'X'.
        IF STB-MNGKO > T_STOCK.
          FORMAT COLOR 3 INTENSIFIED ON.
        ENDIF.
      ENDIF.
      WRITE:24 STB-POSNR,
               STB-IDNRK,
            44 STB-OJTXP+0(40),
               STB-MNGKO.
      IF STB-ALPGR NE SPACE.
        CLEAR: RATEQTY.
        IF STB-ALPST = '1'.
          RATEQTY = STB-MNGKO * STB-EWAHR / 100.
        ELSE.
          IF STB-ALPRF = '01'.
            RATEQTY = STB-MNGKO * STB-EWAHR / 100.
          ELSE.
            RATEQTY = 0.
          ENDIF.
        ENDIF.
        WRITE: RATEQTY.
      ELSE.
        WRITE: STB-MNGKO.
      ENDIF.
      WRITE:   STB-MEINS,
               STB-POSTP,
           130 STB-MTART,
           137 MARC-BESKZ, MARC-SOBSL,
               STB-LGORT,
               STB-SANKA,
               STB-AUSCH.
      IF R1 = 'X'.
        WRITE:  W_STOCK,               " (WIP) stock
                P_STOCK,               " Warehouse stock
                T_STOCK.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

TOP-OF-PAGE.
  PERFORM TITLE_WRITE.
*&---------------------------------------------------------------------*
*&      Form  LEVEL
*&---------------------------------------------------------------------*
FORM LEVEL.
  LEVEL_NO = STB-STUFE - 1.
  LEVEL_CHAR = STB-STUFE.
  CONDENSE LEVEL_CHAR.
  CLEAR LEVEL.
  IF LEVEL_NO >= 9.
    LEVEL = '........'.
  ELSE.
    DO LEVEL_NO TIMES.
      CONCATENATE '.'  LEVEL INTO LEVEL.
    ENDDO.
  ENDIF.
  CONCATENATE LEVEL LEVEL_CHAR INTO LEVEL.
ENDFORM.                               " LEVEL
*&---------------------------------------------------------------------*
*&      Form  ALT_ITEM
*&---------------------------------------------------------------------*
FORM ALT_ITEM.
  STB-ALPRF =  STB-ALPRF - 1.
  ALT_ITEM = 'R'.
  ALT_ITEM+1(1) = STB-ALPRF+1(1).
ENDFORM.                               " ALT_ITEM
*&---------------------------------------------------------------------*
*&      Form  CHECK_MATERIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_MATERIAL.
  CHECK MATNR1-LOW NE SPACE.
  SELECT SINGLE * FROM MARC WHERE MATNR = MATNR1-LOW
                              AND WERKS = WERKS.
  IF SY-SUBRC <> 0.
    MESSAGE E411 WITH MATNR1-LOW 'is not Maintained in Plant' WERKS.
  ENDIF.
  CHECK MATNR1-HIGH NE SPACE.
  SELECT SINGLE * FROM MARC WHERE MATNR = MATNR1-HIGH
                              AND WERKS = WERKS.
  IF SY-SUBRC <> 0.
    MESSAGE E411 WITH MATNR1-HIGH 'is not Maintained in Plant' WERKS.
  ENDIF.
ENDFORM.                               " CHECK_MATERIAL
*&---------------------------------------------------------------------*
*&      Form  CHECK_PLANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_PLANT.
  SELECT SINGLE * FROM T001W WHERE WERKS = WERKS.
  IF SY-SUBRC <> 0.
    MESSAGE E008 WITH '# Plant code is invalid'.
  ENDIF.

ENDFORM.                               " CHECK_PLANT

*&---------------------------------------------------------------------*
*&      Form  GET_STOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_STOCK.
  CLEAR: P_STOCK, W_STOCK, T_STOCK.
  LOOP AT A_LGORT.
    CLEAR: MARD.
    SELECT SINGLE LABST FROM MARD INTO MARD-LABST
*  select sum( labst ) from mard into p_stock
                        WHERE MATNR = STB-IDNRK
                          AND WERKS = WERKS
                          AND LGORT = A_LGORT-LOW.
    P_STOCK = P_STOCK + MARD-LABST.
  ENDLOOP.

  LOOP AT P_LGORT.
    CLEAR: MARD.
    SELECT SINGLE LABST FROM MARD INTO MARD-LABST
*   select sum( labst ) from mard into p_stock
                        WHERE MATNR = STB-IDNRK
                          AND WERKS = WERKS
                          AND LGORT = P_LGORT-LOW.
    W_STOCK = W_STOCK + MARD-LABST.
  ENDLOOP.

  T_STOCK = P_STOCK + W_STOCK.

ENDFORM.                               " GET_STOCK

*&---------------------------------------------------------------------*
*&      Form  TITLE_WRITE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM TITLE_WRITE.
DATA : NAME(30) TYPE C,
       TEXT(20) TYPE C.

*  CALL FUNCTION 'Z_FIND_USER_NAME'
*       IMPORTING
*            NAME   = NAME
*            TEXT   = TEXT
*       EXCEPTIONS
*            OTHERS = 1.

  T_LINE = SY-LINSZ / 2 - 2.
  L_LINE = SY-LINSZ / 2 - 4.
  S_LINE = SY-LINSZ - 27.
  P_LINE = SY-LINSZ - 21.
  WRITE:/01 ' '.
  WRITE AT T_LINE ' Multi-Level BOM '  COLOR COL_HEADING.

  WRITE :/ '대외비(이면지 사용불가)',
           128 '발행자 : ', NAME(10), TEXT(20).
  WRITE:/   'Material :' INTENSIFIED ON,
            TOPMAT-MATNR INTENSIFIED OFF.
  WRITE AT S_LINE 'Alternative BOM' INTENSIFIED ON.
  WRITE:    TOPMAT-STLAL INTENSIFIED OFF,
        /12 TOPMAT-MAKTX INTENSIFIED OFF.
  WRITE AT S_LINE 'Valid' INTENSIFIED ON.
  WRITE AT P_LINE TOPMAT-DATUV INTENSIFIED OFF.
  WRITE:/   'Required Qty' INTENSIFIED ON,
            TOPMAT-EMENG INTENSIFIED OFF.
  WRITE AT S_LINE 'Page :' INTENSIFIED ON.
  WRITE:    SY-PAGNO INTENSIFIED OFF,
        /   'Base     Qty' INTENSIFIED ON,
            TOPMAT-BMENG INTENSIFIED OFF.
  WRITE AT S_LINE 'Date :' INTENSIFIED ON.
  WRITE:  SY-DATUM INTENSIFIED OFF, SY-UZEIT INTENSIFIED OFF.
  ULINE.
  FORMAT COLOR COL_HEADING INTENSIFIED ON.
  WRITE:/01 'Level no.',
         14 'Rate',
         24 'Item',
            'Component',
         44 'Description',
         94 'Quantity',
        108 'Rate Quantity',
        123 'Un',
            'ICt',
            'Type',
        136 'Prc',
        140 'I/LO',
        147 'CR',
        150 'Loss'.

  IF R1 = 'X'.
    WRITE:158 'Sloc(WIP) stock',
          177 'Warehouse stock',
          200 'Total stock',     214 ' '.
   WRITE:/07 'Strategy',
          18 'Alt.Group',
          27 ' ',
         214 ' '.
  else.
   WRITE:/07 'Strategy',
          18 'Alt.Group',
          27 ' ',
         153 ' '.
  endif.
  ULINE.

ENDFORM.                               " TITLE_WRITE
*&---------------------------------------------------------------------*
*&      Form  GET_LGORT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LGORT_DATA.
*  원창 창고
*  CLEAR ZF002.
*  SELECT ZZCD_KEY INTO ZF002-ZZCD_KEY FROM ZF002
*                                      WHERE ZZCD_TYPE  = 'MM00'
*                                        AND ZZBIG_CODE = WERKS
*                                        AND ZZMDL_CODE = '1'
*                                        AND ZZSML_CODE NE '해외'.
*    A_LGORT-SIGN   = 'I'.
*    A_LGORT-OPTION = 'EQ'.
*    A_LGORT-LOW    = ZF002-ZZCD_KEY.
*    APPEND A_LGORT.
*  ENDSELECT.

*  CLEAR ZM039.
*  SELECT LGORT INTO ZM039-LGORT FROM ZM039
*                                      WHERE WERKS = WERKS
*                                        AND ZLGGUBUN = '1'
*                                        AND ZLGCKD NE 'CKD'.
*    A_LGORT-SIGN   = 'I'.
*    A_LGORT-OPTION = 'EQ'.
*    A_LGORT-LOW    = ZM039-LGORT.
*    APPEND A_LGORT.
*  ENDSELECT.
*
*  현장 창고

*  CLEAR ZF002.
*  SELECT ZZCD_KEY INTO ZF002-ZZCD_KEY FROM ZF002
*                                      WHERE ZZCD_TYPE  = 'MM00'
*                                        AND ZZBIG_CODE = WERKS
*                                        AND ZZMDL_CODE = '2'
*                                        AND ZZSML_CODE NE '해외'.
*    P_LGORT-SIGN   = 'I'.
*    P_LGORT-OPTION = 'EQ'.
*    P_LGORT-LOW    = ZF002-ZZCD_KEY.
*    APPEND P_LGORT.
*  ENDSELECT.

*  CLEAR ZM039.
*  SELECT LGORT INTO ZM039-LGORT FROM ZM039
*                                      WHERE WERKS = WERKS
*                                        AND ZLGGUBUN = '2'
*                                        AND ZLGCKD NE 'CKD'.
*    A_LGORT-SIGN   = 'I'.
*    A_LGORT-OPTION = 'EQ'.
*    A_LGORT-LOW    = ZM039-LGORT.
*    APPEND A_LGORT.
*  ENDSELECT.
*
ENDFORM.                               " GET_LGORT_DATA
