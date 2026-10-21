*&---------------------------------------------------------------------*
*& Include ZGTMMR6210TOP
*&---------------------------------------------------------------------*

TABLES : S012, EKKO, ZGTMMT6100.


DATA : GT_RTAB LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF GT_DATA OCCURS 0,
         EKORG   LIKE EKKO-EKORG,         "구매조직
         WERKS   LIKE EKPO-WERKS,         "플랜트
         ZMTGRPT LIKE ZGTMMT6100-ZMTGRPT, "발주그룹 내역
         WAERS   LIKE EKKO-WAERS,         "통화
         MEINS   LIKE EKPO-MEINS,         "OUn
         LIFNR   LIKE EKKO-LIFNR,         "공급업체
         YMONTH  TYPE SPMON,

         BSTMG   LIKE EKPO-MENGE,
         BWERT   LIKE EKPO-NETWR,

         ZMTGRP  LIKE ZGTMMT6100-ZMTGRP,  "발주그룹
         NAME1   LIKE LFA1-NAME1,         "공급업체명
       END   OF GT_DATA.

DATA : GS_DATA LIKE GT_DATA.

DATA : BEGIN OF GT_LIST OCCURS 0,
         EKORG     LIKE EKKO-EKORG,         "구매조직
         WERKS     LIKE EKPO-WERKS,         "플랜트
         ZMTGRP    LIKE ZGTMMT6100-ZMTGRP,  "발주그룹
         ZMTGRPT   LIKE ZGTMMT6100-ZMTGRPT, "발주그룹 내역
         LIFNR     LIKE EKKO-LIFNR,         "공급업체
         NAME1     LIKE LFA1-NAME1,         "공급업체명
         WAERS     LIKE EKKO-WAERS,         "통화
         MEINS     LIKE EKPO-MEINS,         "OUn
         BSTMG_S   LIKE AUBF-MENGE,         "물량 합
         BSTMG_P   LIKE T169K-DPROZ,        "물량(%)
         BWERT_S   LIKE AUBF-EKWRT,         "금액 합
         BWERT_P   LIKE T169K-DPROZ,        "금액(%)
         CSORT(75),                         "Sort 기준
       END   OF GT_LIST.


RANGES : GR_SPMON FOR S012-SPMON.

DATA : GV_DUR TYPE NUMC2.

DATA : GV_CDATE LIKE SY-DATLO.

DATA : GV_FSQ TYPE LVC_FNAME,
       GV_FPQ TYPE LVC_FNAME,
       GV_FSA TYPE LVC_FNAME,
       GV_FPA TYPE LVC_FNAME.

FIELD-SYMBOLS : <GS_LIST>,
                <GT_LIST> TYPE STANDARD TABLE,
                <GT_LSUM> TYPE STANDARD TABLE.

DATA : GV_CNT TYPE I.

DATA : GV_OKCODE LIKE SY-UCOMM.

DATA : GV_SP,
       GV_S,
       GV_P.


CONSTANTS : GC_A(1)       VALUE 'A',
            GC_C(1)       VALUE 'C',
            GC_D(1)       VALUE 'D',
            GC_E(1)       VALUE 'E',
            GC_I(1)       VALUE 'I',
            GC_S(1)       VALUE 'S',
            GC_X(1)       VALUE 'X',
            GC_EQ(2)      VALUE 'EQ',
            GC_C300(4)    VALUE 'C300',
            GC_C500(4)    VALUE 'C500',
            GC_EKORG(5)   VALUE 'EKORG',
            GC_WERKS(5)   VALUE 'WERKS',
            GC_WAERS(5)   VALUE 'WAERS',
            GC_MEINS(5)   VALUE 'MEINS',
            GC_ZMTGRPT(7) VALUE 'ZMTGRPT'.


DEFINE _CALC_DATE.
  CLEAR : GV_CDATE.
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      DATE      = &1
      DAYS      = &2
      MONTHS    = &3
      SIGNUM    = &4
      YEARS     = &5
    IMPORTING
      CALC_DATE = GV_CDATE.
END-OF-DEFINITION.


*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK BK1 WITH FRAME TITLE TEXT-S01.
  PARAMETERS     : P_EKORG LIKE EKKO-EKORG OBLIGATORY MEMORY ID EKO,
                   P_WERKS LIKE EKPO-WERKS OBLIGATORY MEMORY ID WRK.
  SELECT-OPTIONS : S_SPMON  FOR S012-SPMON OBLIGATORY NO-EXTENSION,
                   S_LIFNR  FOR EKKO-LIFNR,
                   S_MTGRP  FOR ZGTMMT6100-ZMTGRP.
SELECTION-SCREEN END   OF BLOCK BK1.
