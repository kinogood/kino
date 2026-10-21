*&---------------------------------------------------------------------*
*& Include          ZGTMMR4351TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF TY_FIBER,
*I/F 정보
    ZIFNO      TYPE ZGTMMT9000-ZIFNO,
    SYSTEM_ID  TYPE ZGTMMT9000-SYSTEM_ID,
    SYSTEM_TXT TYPE ZGTPPT1010-FLD_02,
    ZIFKEY     TYPE ZGTMMT9000-ZIFKEY,
    ZSTAT      TYPE ZGTMMT9000-ZSTAT,
    MESSAGE    TYPE ZGTMMT9000-MESSAGE,
    IFNAM      TYPE ZGTMMT9000-IFNAM,
*FIBER입고 정보
    WERKS      LIKE ZGTMMT9460-WERKS,     "플랜트
    VLABELNO   LIKE ZGTMMT9460-VLABELNO,  "라벨번호
    EBELN      LIKE ZGTMMT9460-EBELN,     "구매오더
    EBELP      LIKE ZGTMMT9460-EBELP,     "구매오더품목
    BUDAT      LIKE ZGTMMT9460-BUDAT,     "입고일자
    MATNR      LIKE ZGTMMT9460-MATNR,     "자재
    TXZ01      LIKE EKPO-TXZ01,           "자재내역
    MENGE      LIKE ZGTMMT9460-MENGE,     "수량
    MEINS      LIKE ZGTMMT9460-MEINS,     "단위
    LANCHAR    LIKE ZGTMMT9460-LANCHAR,   "광특성
    LIFNR      LIKE EKKO-LIFNR,           "공급업체
    AEDAT    LIKE ZGTMMT9460-AEDAT, "26.07.08추가
    AEDAT_LOCAL LIKE ZGTMMT9460-AEDAT_LOCAL, "26.07.08추가
    AENAM LIKE ZGTMMT9460-AENAM, "26.07.08추가
    AETIM    LIKE ZGTMMT9460-AETIM, "26.07.08추가
    AETIM_LOCAL LIKE ZGTMMT9460-AETIM_LOCAL, "26.07.08추가
  END OF TY_FIBER.

TYPES:
  BEGIN OF TY_SYS,
    SYSTEM_ID TYPE ZGTMMT9000-SYSTEM_ID,
  END OF TY_SYS,
  BEGIN OF TY_SUC,
    SYSTEM_ID TYPE ZGTMMT9000-SYSTEM_ID,
    VLABELNO  LIKE ZGTMMT9466-VLABELNO,
  END OF TY_SUC.

TYPES:
  BEGIN OF TY_DATA.
    INCLUDE TYPE ZGTMMS4008.
TYPES:
    AEDAT TYPE ZGTMMT9460-AEDAT, "26.07.08추가
    AEDAT_LOCAL LIKE ZGTMMT9460-AEDAT_LOCAL, "26.07.08추가
    AETIM    LIKE ZGTMMT9460-AETIM, "26.07.08추가
    AETIM_LOCAL LIKE ZGTMMT9460-AETIM_LOCAL, "26.07.08추가
    AENAM LIKE ZGTMMT9460-AENAM, "26.07.08추가
  END OF TY_DATA.

TYPES:
  TY_T_DATA TYPE STANDARD TABLE OF TY_DATA,
  TY_T_SYS  TYPE STANDARD TABLE OF TY_SYS,
  TY_T_SUC  TYPE SORTED TABLE OF TY_SUC WITH UNIQUE KEY SYSTEM_ID VLABELNO.

*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*

DATA:
  GT_FIBER TYPE STANDARD TABLE OF TY_FIBER,
  GT_9460 TYPE STANDARD TABLE OF ZGTMMT9460.

DATA:
  GV_WERKS TYPE T001W-WERKS,
  GV_MATNR TYPE MARA-MATNR,
  GV_BUDAT TYPE MKPF-BUDAT,
  GV_EBELN TYPE EKKO-EBELN.

DATA:
  GT_ECOMM  TYPE STANDARD TABLE OF SY-UCOMM,
  GV_OKCODE TYPE SY-UCOMM.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS:
  GC_A TYPE C LENGTH 1 VALUE 'A',
  GC_C TYPE C LENGTH 1 VALUE 'C',
  GC_D TYPE C LENGTH 1 VALUE 'D',
  GC_E TYPE C LENGTH 1 VALUE 'E',
  GC_S TYPE C LENGTH 1 VALUE 'S',
  GC_H TYPE C LENGTH 1 VALUE 'H'.

CONSTANTS:
  GC_1       TYPE C LENGTH 1 VALUE '1',
  GC_00      TYPE C LENGTH 2 VALUE '00',
  GC_02      TYPE C LENGTH 2 VALUE '02',
  GC_PP      TYPE C LENGTH 2 VALUE 'PP',
  GC_0010    TYPE C LENGTH 4 VALUE '0010',
  GC_MM00065 TYPE ZGTEIFNO   VALUE 'MM00065'.

CONSTANTS:
  GC_MAX TYPE INT4 VALUE 100. "전송 시 최대 데이터 라인 수

*----------------------------------------------------------------------*
* ALV
*----------------------------------------------------------------------*
DATA:
  GO_GRID  TYPE REF TO CL_GUI_ALV_GRID,
  GO_CONT  TYPE REF TO CL_GUI_DOCKING_CONTAINER,
  GV_ASAVE TYPE CHAR01 VALUE 'A',
  GS_LAYO  TYPE LVC_S_LAYO,
  GS_VARI  TYPE DISVARIANT,
  GT_FCAT  TYPE LVC_T_FCAT,
  GT_SORT  TYPE LVC_T_SORT,
  GT_EXCL  TYPE UI_FUNCTIONS.
