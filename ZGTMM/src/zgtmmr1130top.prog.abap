*&---------------------------------------------------------------------*
*& Include          ZGTMMR4390TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*

TYPES:
  BEGIN OF TY_LIST,
    MATNR      TYPE MARA-MATNR,
    MAKTX      TYPE MAKT-MAKTX,
    LIFNR      TYPE MSLB-LIFNR,
    LIFNR_T TYPE LFA1-NAME1,
    EKORG     TYPE ZGTMMT1040-EKORG,
    ESOKZ     TYPE ZGTMMT1040-ESOKZ,
    DATAB      TYPE ZGTMMT1040-DATAB,
    DATBI        TYPE ZGTMMT1040-DATBI,
    WERKS      TYPE T001W-WERKS,
    NAME1      TYPE T001W-NAME1,
    CDATE      TYPE ZGTMMT1040-CDATE,
    PTYPE       TYPE ZGTMMT1040-PTYPE,
    CU_QT      TYPE ZGTMMT1040-CU_QT,
    CU_PRC    TYPE ZGTMMT1040-CU_PRC,
    CU_SUM   TYPE ZGTMMT1040-CU_SUM,
    AL_QT       TYPE ZGTMMT1040-AL_QT,
    AL_PRC     TYPE ZGTMMT1040-AL_PRC,
    AL_SUM    TYPE ZGTMMT1040-AL_SUM,
    CUTAPE_QT  TYPE ZGTMMT1040-CUTAPE_QT,
    CUTAPE_PRC TYPE ZGTMMT1040-CUTAPE_PRC,
    CUTAPE_SUM  TYPE ZGTMMT1040-CUTAPE_SUM,
    RQ_RAW_SUM  TYPE ZGTMMT1040-RQ_RAW_SUM,
    COMPOUND1_QT  TYPE ZGTMMT1040-COMPOUND1_QT,
    COMPOUND1_PRC  TYPE ZGTMMT1040-COMPOUND1_QT,
    COMPOUND1_SUM  TYPE ZGTMMT1040-COMPOUND1_SUM,
    COMPOUND2_QT  TYPE ZGTMMT1040-COMPOUND2_QT,
    COMPOUND2_PRC  TYPE ZGTMMT1040-COMPOUND2_PRC,
    COMPOUND2_SUM  TYPE ZGTMMT1040-COMPOUND2_SUM,
    MAT_COST  TYPE ZGTMMT1040-MAT_COST,
    PAK_COST  TYPE ZGTMMT1040-PAK_COST,
    MFG_COST  TYPE ZGTMMT1040-MFG_COST,
    PRE_FEE  TYPE ZGTMMT1040-PRE_FEE,
    OTHERS  TYPE ZGTMMT1040-OTHERS ,
    PEINH  TYPE ZGTMMT1040-PEINH ,
    MEINS  TYPE ZGTMMT1040-MEINS ,
    WAERS  TYPE ZGTMMT1040-WAERS,
    LMEDATE  TYPE ZGTMMT1040-LMEDATE,
    LMEPRICE TYPE ZGTMMT1040-LMEPRICE,
    LWAERS  TYPE ZGTMMT1040-LWAERS,
  END OF TY_LIST.

*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*

DATA:
  GT_LIST TYPE STANDARD TABLE OF TY_LIST.

DATA:
  GV_MATNR TYPE MARA-MATNR,
  GV_WERKS TYPE MARC-WERKS,
  GV_CDATE TYPE MARD-ERSDA,
*  GV_CHARG TYPE MCH1-CHARG,
*  GV_SOBKZ TYPE MSLB-SOBKZ,
  GV_LIFNR TYPE LFA1-LIFNR,
*  GV_PSPNR TYPE PRPS-PSPNR,
*  GV_KUNNR TYPE KNA1-KUNNR,
  GV_VBELN TYPE VBAK-VBELN.


DATA:
  GT_ECOMM  TYPE STANDARD TABLE OF SY-UCOMM,
  GV_OKCODE TYPE SY-UCOMM.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS:
  GC_A TYPE C LENGTH 1 VALUE 'A',
  GC_C TYPE C LENGTH 1 VALUE 'C',
  GC_E TYPE C LENGTH 1 VALUE 'E',
  GC_S TYPE C LENGTH 1 VALUE 'S',
  GC_LGORT TYPE C LENGTH 4 VALUE '3497'.

*----------------------------------------------------------------------*
* ALV
*----------------------------------------------------------------------*
DATA:
  GO_GRID  TYPE REF TO CL_GUI_ALV_GRID,
  GO_CONT  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
  GV_ASAVE TYPE CHAR01 VALUE 'A',
  GS_LAYO  TYPE LVC_S_LAYO,
  GS_VARI  TYPE DISVARIANT,
  GT_FCAT  TYPE LVC_T_FCAT,
  GT_SORT  TYPE LVC_T_SORT,
  GT_EXCL  TYPE UI_FUNCTIONS.

*----------------------------------------------------------------------*
* Screen - 1000
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-S01.

*  PARAMETERS :
*    P_BUKRS TYPE T001-BUKRS OBLIGATORY MEMORY ID BUK.

  SELECT-OPTIONS:
    S_WERKS FOR GV_WERKS MEMORY ID WRK,
    S_DATE    FOR GV_CDATE,
    S_MATNR FOR GV_MATNR,
    S_LIFNR FOR GV_LIFNR.

SELECTION-SCREEN END   OF BLOCK B01.
