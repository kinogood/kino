*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR4382TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* TYPE POOLS
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  TABLES
*----------------------------------------------------------------------*
TABLES :
  MARC, EKKO, MATDOC, T001L, T156,
  SSCRFIELDS.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
*=> GTY + _ + XXXXX.XXX
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF TY_T001,
    BUKRS TYPE T001-BUKRS,
    BUTXT TYPE T001-BUTXT,
  END OF TY_T001,
  BEGIN OF TY_T001L,
    WERKS TYPE T001W-WERKS,
    LGORT TYPE T001L-LGORT,
    LGOBE TYPE T001L-LGOBE,
  END OF TY_T001L,
  BEGIN OF TY_T001W,
    WERKS TYPE T001W-WERKS,
    NAME1 TYPE T001W-NAME1,
  END OF TY_T001W,
  BEGIN OF TY_T024E,
    EKORG TYPE T024E-EKORG,
    EKOTX TYPE T024E-EKOTX,
  END OF TY_T024E,
  BEGIN OF TY_T024,
    EKGRP TYPE T024-EKGRP,
    EKNAM TYPE T024-EKNAM,
  END OF TY_T024,
    BEGIN OF TY_CSKS,
      KOSTL TYPE CSKS-KOSTL,
      KTEXT TYPE CSKT-KTEXT,
  END OF TY_CSKS,
  BEGIN OF TY_SKA1,
    SAKTO TYPE SKA1-SAKNR,
    TXT20  TYPE SKAT-TXT20,
  END OF TY_SKA1,
  BEGIN OF TY_AUFK,
    AUFNR TYPE AUFK-AUFNR,
    AUFNR_N TYPE AUFK-KTEXT,
  END OF TY_AUFK.

TYPES:
  BEGIN OF TY_LIST,
    STATUS  TYPE ICON_NAME,
    WERKS   TYPE ZGTMM_CV_GET_STOCKLIST-WERKS,
    NAME1   TYPE T001W-NAME1,
    LGORT   TYPE ZGTMM_CV_GET_STOCKLIST-LGORT,
    LGOBE   TYPE T001L-LGOBE,
    BWART   TYPE MATDOC-BWART,
    BTEXT   TYPE MATDOC-BKTXT,
    MATNR   TYPE ZGTMM_CV_GET_STOCKLIST-MATNR,
    MAKTX   TYPE MAKT-MAKTX,
    CHARG   TYPE ZGTMM_CV_GET_STOCKLIST-CHARG,
    TAGNR   TYPE ZPPT0001-TAGNR,
    LABST   TYPE ZGTMM_CV_GET_STOCKLIST-LABST,
    MEINS   TYPE ZGTMM_CV_GET_STOCKLIST-MEINS,
    MENGE   TYPE MENGE_D,
    KOSTL    TYPE CSKS-KOSTL,
    KTEXT    TYPE CSKT-KTEXT,
    SAKTO    TYPE SKA1-SAKNR,
    TXT20     TYPE SKAT-TXT20,
    AUFNR    TYPE AUFK-AUFNR,
    AUFNR_N TYPE AUFK-KTEXT,
    MBLNR   TYPE MATDOC-MBLNR,
    MESSAGE TYPE BAPIRET2-MESSAGE,
    STYLE   TYPE LVC_T_STYL,
  END OF TY_LIST,

  BEGIN OF TY_DISP,
    STATUS TYPE ICON_NAME,
    SMBLN  TYPE MATDOC-MBLNR,
    MBLNR  TYPE MATDOC-MBLNR,
    ZEILE  TYPE MATDOC-ZEILE,
    BUDAT  TYPE MATDOC-BUDAT,
    BWART  TYPE MATDOC-BWART,
    BTEXT  TYPE MATDOC-BKTXT, "BTEXT,
    WERKS  TYPE MATDOC-WERKS,
    LGORT  TYPE MATDOC-LGORT,
    MATNR  TYPE MATDOC-MATNR,
    MAKTX  TYPE MAKT-MAKTX,
    ERFMG  TYPE MATDOC-ERFMG,
    ERFME  TYPE MATDOC-ERFME,
    BKTXT  TYPE MATDOC-BKTXT,
    KOSTL    TYPE CSKS-KOSTL,
    KTEXT    TYPE CSKT-KTEXT,
    SAKTO    TYPE SKA1-SAKNR,
    TXT20     TYPE SKAT-TXT20,
    AUFNR    TYPE AUFK-AUFNR,
    AUFNR_N TYPE AUFK-KTEXT,
    USNAM  TYPE MATDOC-USNAM,
  END OF TY_DISP,

  BEGIN OF TY_ZPPT1010,
    MODULE_KIND TYPE ZGTPPT1010-MODULE_KIND,
    CODEGRP TYPE ZGTPPT1010-CODEGRP,
    CODEID TYPE ZGTPPT1010-CODEID,
    FLD_01 TYPE ZGTPPT1010-FLD_01,
    FLD_02 TYPE ZGTPPT1010-FLD_02,
    FLD_03 TYPE ZGTPPT1010-FLD_03,
    FLD_04 TYPE ZGTPPT1010-FLD_04,
    FLD_05 TYPE ZGTPPT1010-FLD_05,
  END OF TY_ZPPT1010.

TYPES :
  TY_T_LIST TYPE STANDARD TABLE OF TY_LIST,
  TY_T_DISP TYPE STANDARD TABLE OF TY_DISP.

*----------------------------------------------------------------------*
* GLOBAL VARIABLE
*----------------------------------------------------------------------*
* => GV + '_' XX.XXX
*----------------------------------------------------------------------*
DATA :
  GV_OKCODE       TYPE SY-UCOMM,
  GV_OKCODE_SAVE  TYPE SY-UCOMM,
  GV_OKCODE_SAVE2 TYPE SY-UCOMM,
  GV_UCOMM        TYPE SY-UCOMM,
  GV_ANSWER,
  GV_QUES(50),
  GV_REASON(25),
  GV_ERR,
  GV_BAPI.

DATA :
  GV_BUDAT TYPE BUDAT.

*----------------------------------------------------------------------*
* GLOBAL STRUCTURE
*----------------------------------------------------------------------*
* => GS + '_' XX.XXX
*----------------------------------------------------------------------*
DATA : GS_LIST TYPE TY_LIST,
           GS_DISP TYPE TY_DISP.

DATA :  GS_RETURN LIKE BAPIRET2,
            GS_BWART TYPE VRM_VALUE.

*----------------------------------------------------------------------*
* GLOBAL INTERNAL TABLE                                                *
*----------------------------------------------------------------------*
* => GT_ + XXX...XX                                                    *
*----------------------------------------------------------------------*
DATA :
  GT_LIST TYPE STANDARD TABLE OF TY_LIST,
  GT_DISP TYPE STANDARD TABLE OF TY_DISP,
  GT_ZGTPPT1010 TYPE STANDARD TABLE OF TY_ZPPT1010.

DATA:
  GT_T001  TYPE SORTED TABLE OF TY_T001 WITH UNIQUE KEY BUKRS,
  GT_T001L TYPE SORTED TABLE OF TY_T001L WITH UNIQUE KEY WERKS LGORT,
  GT_T001W TYPE SORTED TABLE OF TY_T001W WITH UNIQUE KEY WERKS,
  GT_T024E TYPE SORTED TABLE OF TY_T024E WITH UNIQUE KEY EKORG,
  GT_T024  TYPE SORTED TABLE OF TY_T024 WITH UNIQUE KEY EKGRP.

DATA :
  GT_CSKS TYPE TABLE OF TY_CSKS,
  GT_SKA1 TYPE TABLE OF TY_SKA1,
  GT_AUFK TYPE TABLE OF TY_AUFK.

DATA: GT_BWART TYPE TABLE  OF VRM_VALUE,
          GT_DD07V TYPE TABLE OF DD07V.

DATA : GT_RETURN LIKE TABLE OF BAPIRET2,
           GT_EX         TYPE STANDARD TABLE OF SY-UCOMM.

DATA :
  GT_MTXT TYPE BCSY_TEXT,
  GS_MTXT TYPE SOLI.

*----------------------------------------------------------------------*
* GLOBAL RANGE                                                         *
*----------------------------------------------------------------------*
* => GR_ + XXX.XX                                                      *
*----------------------------------------------------------------------*



*----------------------------------------------------------------------*
* GLOBAL FIELD SYMBOLS                                                 *
*----------------------------------------------------------------------*
* => <FS_XXX...XX>, EX)<FS_ITAB>, <FS_WA>, <FS_NN>                     *
*----------------------------------------------------------------------*


*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS :
  GC_A(1)  VALUE 'A',
  GC_C(1)  VALUE 'C',
  GC_D(1)  VALUE 'D',
  GC_E(1)  VALUE 'E',
  GC_F(1)  VALUE 'F',
  GC_H(1)  VALUE 'H',
  GC_I(1)  VALUE 'I',
  GC_J(1)  VALUE 'J',
  GC_K(1)  VALUE 'K',
  GC_L(1)  VALUE 'L',
  GC_M(1)  VALUE 'M',
  GC_N(1)  VALUE 'N',
  GC_O(1)  VALUE 'O',
  GC_P(1)  VALUE 'P',
  GC_R(1)  VALUE 'R',
  GC_S(1)  VALUE 'S',
  GC_X(1)  VALUE 'X',
  GC_0(1)  VALUE '0',
  GC_1(1)  VALUE '1',
  GC_3(1)  VALUE '3',
  GC_BT(2) VALUE 'BT',
  GC_EQ(2) VALUE 'EQ',
  GC_CL(2) VALUE 'CL',
  GC_PR(2) VALUE 'PR',
  GC_MM(2) VALUE 'MM'.

CONSTANTS :
  GC_KSRM(4)      VALUE 'KSRM',
  GC_0850(4)        VALUE '0850',
  GC_TAXKR(5)     VALUE 'TAXKR',
  GC_ZGRSTATUS(9) VALUE 'ZGRSTATUS',
  GC_ZIVSTATUS(9) VALUE 'ZIVSTATUS'.

CONSTANTS:
  GC_ZGTMMR1050 TYPE W3OBJID VALUE 'ZGTMMR1050'.

*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
DEFINE _SET_RANGES.

  &1-LOW = &2.
  &1-HIGH = &3.
  &1-OPTION = &4.
  &1-SIGN = &5.
  APPEND &1.

END-OF-DEFINITION.

*----------------------------------------------------------------------*
* SELECTION SCREEN
*----------------------------------------------------------------------*
* SELECTION OPTION => SO_XX...X
* PARAMETER        => PA_XX...X
* CHECKBOX         => CB_XX...X
* RADIO BUTTON     => RB_XX...X
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
  PARAMETERS P_BUKRS TYPE T024E-BUKRS OBLIGATORY.
  PARAMETERS P_WERKS TYPE MATDOC-WERKS OBLIGATORY. "플랜트

  SELECT-OPTIONS : S_LGORT FOR T001L-LGORT.
  PARAMETERS :       P_BWART TYPE T156-BWART AS LISTBOX VISIBLE LENGTH 20.
  SELECT-OPTIONS : S_MATNR FOR MARC-MATNR,"자재코드
                                S_BUDAT FOR MATDOC-BUDAT MODIF ID DIS.
SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-003.
  SELECTION-SCREEN BEGIN OF LINE.
*폐기처리
    PARAMETERS P_SCRP RADIOBUTTON GROUP RB1 DEFAULT 'X' USER-COMMAND UC01.
    SELECTION-SCREEN COMMENT (15) TEXT-C01 FOR FIELD P_SCRP.
*처리결과조회
    PARAMETERS P_DISP RADIOBUTTON GROUP RB1.
    SELECTION-SCREEN COMMENT (15) TEXT-C02 FOR FIELD P_DISP.

  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK B2.
