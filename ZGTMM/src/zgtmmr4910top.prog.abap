*&---------------------------------------------------------------------*
*& Include ZGTMMR4910TOP
*&---------------------------------------------------------------------*

TABLES : LFA1.


RANGES : GR_GR1   FOR SCREEN-GROUP1,
         GR_LIFNR FOR LFA1-LIFNR.

DATA : GV_REQ.

DATA : BEGIN OF GT_IFNO OCCURS 0,
         KEY  LIKE ZGTPPT1010-FLD_01,
         TEXT LIKE ZGTPPT1010-FLD_02,
       END   OF GT_IFNO.

DATA : BEGIN OF GS_MST,
         TYPE LIKE ZGTPPT1010-FLD_03,
         PROG LIKE ZGTPPT1010-FLD_04,
         VIEW LIKE ZGTPPT1010-FLD_05,
       END   OF GS_MST.

DATA : GT_VCHG TYPE ZGTMM_CV_CHANGEDVD OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF GS_ADR6,
         ADRNR     TYPE ADR6-ADDRNUMBER,
         SMTP_ADDR TYPE ADR6-SMTP_ADDR,
       END   OF GS_ADR6.
DATA : GT_ADR6 LIKE GS_ADR6 OCCURS 0 WITH HEADER LINE.
*DATA: GT_ADR6 LIKE SORTED TABLE OF GS_ADR6
*              WITH UNIQUE KEY ADRNR.

DATA : GT_F001 LIKE ZGTMMSIF0001 OCCURS 0 WITH HEADER LINE.

DATA : GS_9000 LIKE ZGTMMT9000,
       GT_9010 LIKE ZGTMMT9010 OCCURS 0 WITH HEADER LINE.


DATA : GV_ERR,
       GV_ANS,
       GV_MSG(100),
       GV_CNT TYPE I.

DATA : GV_TNAME TYPE TABNAME.

DATA : GV_OKCODE LIKE SY-UCOMM.

DATA : GV_SEND(10),
       GV_REF.


FIELD-SYMBOLS : <GS_LIST>,
                <GT_LIST> TYPE STANDARD TABLE.


CONSTANTS : GC_A(1)                   VALUE 'A',
            GC_D(1)                   VALUE 'D',
            GC_E(1)                   VALUE 'E',
            GC_I(1)                   VALUE 'I',
            GC_S(1)                   VALUE 'S',
            GC_X(1)                   VALUE 'X',
            GC_1(1)                   VALUE '1',
            GC_BT(2)                  VALUE 'BT',
            GC_EQ(2)                  VALUE 'EQ',
            GC_MM(2)                  VALUE 'MM',
            GC_PP(2)                  VALUE 'PP',
            GC_02(2)                  VALUE '02',
            GC_DIS(3)                 VALUE 'DIS',
            GC_SND(3)                 VALUE 'SND',
            GC_0010(4)                VALUE '0010',
            GC_MM00001(7)             VALUE 'MM00001',
            GC_ZGTMM_CV_CHANGEDVD(18) VALUE 'ZGTMM_CV_CHANGEDVD'.


*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BK1 WITH FRAME TITLE TEXT-S01.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : P_ILOG RADIOBUTTON GROUP GR1
                             USER-COMMAND EXE DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (15) TEXT-R01 FOR FIELD P_ILOG.

    SELECTION-SCREEN POSITION 32.
    PARAMETERS : P_SEND RADIOBUTTON GROUP GR1.
    SELECTION-SCREEN COMMENT (15) TEXT-R02 FOR FIELD P_SEND.
  SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK BK1.

SELECTION-SCREEN BEGIN OF BLOCK BK2 WITH FRAME TITLE TEXT-S02.
  PARAMETERS     : P_IFSYT TYPE ZGTE_FLDVAL              "I/F 시스템
                                AS LISTBOX VISIBLE LENGTH 17.
  SELECT-OPTIONS : S_IFDAT  FOR SY-DATLO   MODIF ID DIS. "I/F Date
  PARAMETERS     : P_EKORG LIKE EKKO-EKORG MODIF ID SND. "구매조직
  SELECT-OPTIONS : S_LIFNR  FOR LFA1-LIFNR,              "공급업체
                   S_ERDAT  FOR SY-DATLO   MODIF ID SND. "생성/변경일
SELECTION-SCREEN END   OF BLOCK BK2.

SELECTION-SCREEN BEGIN OF BLOCK BK3 WITH FRAME TITLE TEXT-S03.
  PARAMETERS : P_BAT AS CHECKBOX MODIF ID SND,
               P_FNL AS CHECKBOX MODIF ID DIS,
               P_FRC AS CHECKBOX. "MODIF ID SND.
SELECTION-SCREEN END   OF BLOCK BK3.
