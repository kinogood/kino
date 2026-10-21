*&---------------------------------------------------------------------*
*& Include ZGTMMR4916TOP
*&---------------------------------------------------------------------*

TABLES : EINE, EINA.


RANGES : GR_GR1 FOR SCREEN-GROUP1,
         GR_SNM FOR SCREEN-NAME.


DATA : BEGIN OF GT_IFNO OCCURS 0,
         KEY  LIKE ZGTPPT1010-FLD_01,
         TEXT LIKE ZGTPPT1010-FLD_02,
       END   OF GT_IFNO.

DATA : BEGIN OF GS_MST,
         TYPE LIKE ZGTPPT1010-FLD_03,
         PROG LIKE ZGTPPT1010-FLD_04,
         VIEW LIKE ZGTPPT1010-FLD_05,
       END   OF GS_MST.

DATA : GT_F062 TYPE TABLE OF ZGTMMSIF0062 WITH HEADER LINE,
       GT_ELOG TYPE TABLE OF ZGTMMT6010   WITH HEADER LINE.

DATA : GS_9000 TYPE ZGTMMT9000,
       GT_6010 TYPE TABLE OF ZGTMMT6010 WITH HEADER LINE.

DATA : GV_ZIFKEY LIKE ZGTMMT9000-ZIFKEY.

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


CONSTANTS : GC_A(1)                        VALUE 'A',
            GC_C(1)                        VALUE 'C',
            GC_D(1)                        VALUE 'D',
            GC_E(1)                        VALUE 'E',
            GC_I(1)                        VALUE 'I',
            GC_M(1)                        VALUE 'M',
            GC_S(1)                        VALUE 'S',
            GC_X(1)                        VALUE 'X',
            GC_1(1)                        VALUE '1',
            GC_BT(2)                       VALUE 'BT',
            GC_EQ(2)                       VALUE 'EQ',
            GC_MM(2)                       VALUE 'MM',
            GC_PP(2)                       VALUE 'PP',
            GC_02(2)                       VALUE '02',
            GC_DIS(3)                      VALUE 'DIS',
            GC_SND(3)                      VALUE 'SND',
            GC_PB00(4)                     VALUE 'PB00',
            GC_KBDM(4)                     VALUE 'KBDM',
            GC_0010(4)                     VALUE '0010',
            GC_1306(4)                     VALUE '1306',
            GC_1100(4)                     VALUE '1100',
            GC_MM00061(7)                  VALUE 'MM00061',
            GC_P_IFSYT(7)                  VALUE 'P_IFSYT',
            GC_S_ERDAT-LOW(11)             VALUE 'S_ERDAT-LOW',
            GC_S_IFDAT-LOW(11)             VALUE 'S_IFDAT-LOW',
            GC_ZGTMM_CV_INFO_CHNG_HIST(24) VALUE 'ZGTMM_CV_INFO_CHNG_HIST'.


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
  PARAMETERS     : P_IFSYT TYPE ZGTE_FLDVAL            "I/F 시스템
                                AS LISTBOX VISIBLE LENGTH 17 MODIF ID M1.
  SELECT-OPTIONS : S_IFDAT  FOR SY-DATLO MODIF ID DIS. "I/F Date
  SELECT-OPTIONS : S_EKORG  FOR EINE-EKORG,            "구매조직
                   S_WERKS  FOR EINE-WERKS,            "플랜트
                   S_LIFNR  FOR EINA-LIFNR,            "공급업체
                   S_MATKL  FOR EINA-MATKL,            "자재그룹
                   S_MATNR  FOR EINA-MATNR,            "자재
                   S_INFNR  FOR EINA-INFNR,            "정보 레코드
                   S_ESOKZ  FOR EINE-ESOKZ,            "정보 범주
                   S_ERDAT  FOR SY-DATLO." MODIF ID SND. "생성/변경일
SELECTION-SCREEN END   OF BLOCK BK2.

SELECTION-SCREEN BEGIN OF BLOCK BK3 WITH FRAME TITLE TEXT-S03.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT (20) TEXT-S03 MODIF ID M2.
    SELECTION-SCREEN POSITION 33.
    PARAMETERS: P_ALL RADIOBUTTON GROUP GR3   DEFAULT 'X' MODIF ID M2.
    SELECTION-SCREEN COMMENT (12) TEXT-S04 FOR FIELD P_ALL MODIF ID M2.

    SELECTION-SCREEN POSITION 52.
    PARAMETERS: P_SU RADIOBUTTON GROUP GR3 MODIF ID M2.
    SELECTION-SCREEN COMMENT (12) TEXT-S05 FOR FIELD P_SU MODIF ID M2.

    SELECTION-SCREEN POSITION 72.
    PARAMETERS: P_FA RADIOBUTTON GROUP GR3 MODIF ID M2.
    SELECTION-SCREEN COMMENT (12) TEXT-S06 FOR FIELD P_FA MODIF ID M2.

  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END   OF BLOCK BK3.
