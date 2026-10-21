*&---------------------------------------------------------------------*
*& Include ZGTMMR4913TOP
*&---------------------------------------------------------------------*

TABLES : T001W, EKKO, ZGTMMT9040.


RANGES : GR_GR1   FOR SCREEN-GROUP1,
         GR_SNM   FOR SCREEN-NAME.
*        GR_ICCNO FOR ZGTMMT9040-ICCNO.


DATA : BEGIN OF GT_IFNO OCCURS 0,
         KEY  LIKE ZGTPPT1010-FLD_01,
         TEXT LIKE ZGTPPT1010-FLD_02,
       END   OF GT_IFNO.

DATA : BEGIN OF GS_MST,
         TYPE LIKE ZGTPPT1010-FLD_03,
         PROG LIKE ZGTPPT1010-FLD_04,
         VIEW LIKE ZGTPPT1010-FLD_05,
       END   OF GS_MST.

DATA : GT_CCHG TYPE ZGTMM_CV_CHANGEDCU OCCURS 0 WITH HEADER LINE.

DATA : GT_F006 LIKE ZGTMMSIF0006 OCCURS 0 WITH HEADER LINE,
       GT_CLOG LIKE ZGTMMT9040   OCCURS 0 WITH HEADER LINE.

DATA : GS_9000 LIKE ZGTMMT9000,
       GT_9040 LIKE ZGTMMT9040 OCCURS 0 WITH HEADER LINE.

*--> [CHM2510-00260]소재 MOM I/F 신규 필드 반영
DATA : BEGIN OF GS_DEL,
         ICCNO LIKE ZTITCRP-ICCNO,
         ICCSQ LIKE ZTITCRP-ICCSQ,
         ICCIT LIKE ZTITCRP-ICCIT,
         CHANGENR LIKE CDHDR-CHANGENR,
         USERNAME LIKE CDHDR-USERNAME,
         UDATE LIKE CDHDR-UDATE,
         UTIME LIKE CDHDR-UTIME,
       END   OF GS_DEL.
DATA : GT_DEL LIKE TABLE OF GS_DEL.
DATA : GS_CCHG LIKE LINE OF GT_CCHG.
*--> [CHM2510-00260]소재 MOM I/F 신규 필드 반영

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
            GC_MM00004(7)             VALUE 'MM00004',
            GC_P_BUKRS(7)             VALUE 'P_BUKRS',
            GC_P_IFSYT(7)             VALUE 'P_IFSYT',
            GC_S_EKORG-LOW(11)        VALUE 'S_EKORG-LOW',
            GC_S_ERDAT-LOW(11)        VALUE 'S_ERDAT-LOW',
            GC_S_IFDAT-LOW(11)        VALUE 'S_IFDAT-LOW',
            GC_S_WERKS-LOW(11)        VALUE 'S_WERKS-LOW',
            GC_ZGTMM_CV_CHANGEDCU(18) VALUE 'ZGTMM_CV_CHANGEDCU'.


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
  PARAMETERS     : P_IFSYT TYPE ZGTE_FLDVAL               "I/F 시스템
                                AS LISTBOX VISIBLE LENGTH 17.
  SELECT-OPTIONS : S_IFDAT  FOR SY-DATLO    MODIF ID DIS. "I/F Date
  PARAMETERS     : P_BUKRS LIKE T001-BUKRS.               "회사코드
  SELECT-OPTIONS : S_EKORG  FOR EKKO-EKORG  MODIF ID SND, "구매조직
                   S_WERKS  FOR T001W-WERKS MODIF ID SND, "플랜트
                   S_ICCNO  FOR ZGTMMT9040-ICCNO,         "통관 관리번호
                   S_ERDAT  FOR SY-DATLO    MODIF ID SND. "생성/변경일
SELECTION-SCREEN END   OF BLOCK BK2.

SELECTION-SCREEN BEGIN OF BLOCK BK3 WITH FRAME TITLE TEXT-S03.
  PARAMETERS : P_BAT AS CHECKBOX MODIF ID SND,
               P_FNL AS CHECKBOX MODIF ID DIS,
               P_FRC AS CHECKBOX.
SELECTION-SCREEN END   OF BLOCK BK3.
