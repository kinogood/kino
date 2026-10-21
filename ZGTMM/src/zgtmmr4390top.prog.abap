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
    WERKS      TYPE T001W-WERKS,
    NAME1      TYPE T001W-NAME1,
    LGORT      TYPE T001L-LGORT,
    LGOBE      TYPE T001L-LGOBE,
    CHARG      TYPE MCH1-CHARG,
    SOBKZ      TYPE MSLB-SOBKZ,
    LIFNR      TYPE MSLB-LIFNR,
    LIFNR_TEXT TYPE LFA1-NAME1,
    PSPNR      TYPE MSPR-PSPNR,
    POST1      TYPE PRPS-POST1,
    KUNNR      TYPE MSKU-KUNNR,
    KUNNR_TEXT TYPE KNA1-NAME1,
    VBELN      TYPE MSKA-VBELN,
    POSNR      TYPE MSKA-POSNR,
    MEINS      TYPE MARA-MEINS,
    LABST      TYPE MARD-LABST,
    INSME      TYPE MARD-INSME,
    SPEME      TYPE MARD-SPEME,
    B_LIFNR      TYPE MSLB-LIFNR,
    B_LIFNR_TEXT TYPE LFA1-NAME1,
    VBELN_OR     TYPE VBAP-VGBEL,
    POSNR_OR     TYPE VBAP-VGPOS,
  END OF TY_LIST.


*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*

DATA:
  GT_LIST TYPE STANDARD TABLE OF TY_LIST.

DATA:
  GV_MATNR TYPE MARA-MATNR,
  GV_WERKS TYPE MARC-WERKS,
  GV_LGORT TYPE MARD-LGORT,
  GV_CHARG TYPE MCH1-CHARG,
  GV_SOBKZ TYPE MSLB-SOBKZ,
  GV_LIFNR TYPE LFA1-LIFNR,
  GV_PSPNR TYPE PRPS-PSPNR,
  GV_KUNNR TYPE KNA1-KUNNR,
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

  PARAMETERS :
    P_BUKRS TYPE T001-BUKRS OBLIGATORY MEMORY ID BUK.

  SELECT-OPTIONS:
    S_WERKS FOR GV_WERKS MEMORY ID WRK,
    S_LGORT FOR GV_LGORT,
    S_MATNR FOR GV_MATNR,
    S_CHARG FOR GV_CHARG,
    S_SOBKZ FOR GV_SOBKZ,
    S_LIFNR FOR GV_LIFNR,
    S_KUNNR FOR GV_KUNNR,
    S_PSPNR FOR GV_PSPNR,
    S_VBELN FOR GV_VBELN.

SELECTION-SCREEN END   OF BLOCK B01.
