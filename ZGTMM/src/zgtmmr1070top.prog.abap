*&---------------------------------------------------------------------*
*& Include ZGTMMR1070TOP                            - Report ZGTMMR1070
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF TY_USER,
*    STATUS  TYPE C LENGTH 4,
    BUKRS   TYPE ZGTMMT1022-BUKRS,    "회사코드
    BUTXT   TYPE T001-BUTXT,    "회사명
    WERKS   TYPE ZGTMMT1022-WERKS,    "플랜트
    NAME1   TYPE T001W-NAME1,   "플랜트명
    APPUSER TYPE PERSNO,    "사번
    BNAME   TYPE XUBNAME,   " SAP ID -> 숨김처리
    ENAME   TYPE ZZPA0001-ENAME,        "성명

    ERDAT   TYPE ZGTMMT1022-ERDAT,
    ERTIM   TYPE ZGTMMT1022-ERTIM,
    ERNAM   TYPE ZGTMMT1022-ERNAM,
    AEDAT   TYPE ZGTMMT1022-AEDAT,
    AETIM   TYPE ZGTMMT1022-AETIM,
    AENAM   TYPE ZGTMMT1022-AENAM,

    ZSTYLE  TYPE LVC_T_STYL,
  END OF TY_USER,
  TY_T_USER TYPE STANDARD TABLE OF TY_USER.


*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*
DATA:
  GV_APPU TYPE ZGTMMT1022-APPUSER.

DATA:
  GV_ERROR  TYPE C LENGTH 1,
*  GV_EDIT   TYPE C LENGTH 1,
  GT_ECOMM  TYPE STANDARD TABLE OF SY-UCOMM,
  GV_OKCODE TYPE SY-UCOMM.

DATA:
  GT_USER TYPE STANDARD TABLE OF TY_USER,
  GS_USER TYPE TY_USER.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS:
  GC_A(1)    VALUE 'A',
  GC_C(1)    VALUE 'C',
  GC_X(1)    VALUE 'X',
  GC_Y(1)    VALUE 'Y',
  GC_S(1)    VALUE 'S',
  GC_E(1)    VALUE 'E',

  GC_1(1)    VALUE 1,
  GC_01(2)   VALUE '01',

  GC_C300(4) VALUE 'C300',  "YELLOW
  GC_C400(4) VALUE 'C400',  "BLUE
  GC_C500(4) VALUE 'C500',  "GREEN
  GC_C600(4) VALUE 'C600',  "RED
  GC_C700(4) VALUE 'C700'.  "ORANGE


*----------------------------------------------------------------------*
* ALV
*----------------------------------------------------------------------*
DATA:
  GO_CONT_100  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
*  GO_CONT_100  TYPE REF TO CL_GUI_DOCKING_CONTAINER,
  GO_GRID_100  TYPE REF TO CL_GUI_ALV_GRID,
  GV_ASAVE_100 TYPE CHAR01 VALUE GC_A,
  GS_LAYO_100  TYPE LVC_S_LAYO,
  GS_VARI_100  TYPE DISVARIANT,
  GT_FCAT_100  TYPE LVC_T_FCAT,
  GT_SORT_100  TYPE LVC_T_SORT,
  GT_EXCL_100  TYPE UI_FUNCTIONS.

*----------------------------------------------------------------------*
* SCREEN - 1000
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-S01.

  PARAMETERS:
    P_BUKRS TYPE ZGTMMT1022-BUKRS OBLIGATORY MEMORY ID BUK,
    P_WERKS TYPE WERKS_D OBLIGATORY MEMORY ID WRK.

*  SELECT-OPTIONS:
*    S_APPU FOR GV_APPU.

SELECTION-SCREEN END   OF BLOCK B01.
