*&---------------------------------------------------------------------*
*& Include          ZGTMMR4340TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF TY_DISP,
    WERKS      TYPE EKPO-WERKS,
    WERKS_TEXT TYPE T001W-NAME1,
    LIFNR	     TYPE EKKO-LIFNR,
    LIFNR_TEXT TYPE LFA1-NAME1,
    EBELN	     TYPE EKPO-EBELN,
    EBELP	     TYPE EKPO-EBELP,
    MATNR	     TYPE EKPO-MATNR,
    TXZ01      TYPE EKPO-TXZ01,
    IDNRK	     TYPE ZGTMMT9450-IDNRK,
    MAKTX	     TYPE MAKT-MAKTX,
    CHARG	     TYPE ZGTMMT9450-CHARG,
    MENGE	     TYPE ZGTMMT9450-MENGE,
    MEINS      TYPE ZGTMMT9450-MEINS,
    ERNAM      TYPE ZGTMMT9450-ERNAM,
    ERDAT	     TYPE ZGTMMT9450-ERDAT,
    ZSTYLE     TYPE LVC_T_STYL,
  END OF TY_DISP,
  BEGIN OF TY_CREA,
    WERKS      TYPE EKPO-WERKS,
    WERKS_TEXT TYPE T001W-NAME1,
    LIFNR	     TYPE EKKO-LIFNR,
    LIFNR_TEXT TYPE LFA1-NAME1,
    IDNRK	     TYPE ZGTMMT9450-IDNRK,
    MAKTX	     TYPE MAKT-MAKTX,
    CHARG	     TYPE ZGTMMT9450-CHARG,
    MENGE	     TYPE ZGTMMT9450-MENGE,
    MEINS      TYPE ZGTMMT9450-MEINS,
    EBELN	     TYPE EKPO-EBELN,
    EBELP	     TYPE EKPO-EBELP,
    MATNR	     TYPE EKPO-MATNR,
    TXZ01      TYPE EKPO-TXZ01,
  END OF TY_CREA.

*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*

DATA:
  GT_CREA TYPE STANDARD TABLE OF TY_CREA, "ALV fcat 용도
  GT_LIST TYPE STANDARD TABLE OF TY_DISP.

DATA:
  GV_MATNR TYPE MARA-MATNR,
  GV_CHARG TYPE MCH1-CHARG,
  GV_LIFNR TYPE MSEG-LIFNR,
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
  GC_E TYPE C LENGTH 1 VALUE 'E',
  GC_S TYPE C LENGTH 1 VALUE 'S'.

CONSTANTS:
  GC_1 TYPE C LENGTH 1 VALUE '1'.

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
    P_BUKRS TYPE T001-BUKRS OBLIGATORY MEMORY ID BUK,
    P_WERKS TYPE T001W-WERKS OBLIGATORY MEMORY ID WRK.

  SELECT-OPTIONS:
    S_LIFNR FOR GV_LIFNR,
    S_MATNR FOR GV_MATNR,
    S_CHARG FOR GV_CHARG,
    S_EBELN FOR GV_EBELN.

SELECTION-SCREEN END   OF BLOCK B01.

SELECTION-SCREEN BEGIN OF BLOCK B02 WITH FRAME TITLE TEXT-S02.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : P_DISP RADIOBUTTON GROUP GR1
                             USER-COMMAND EXE.
    SELECTION-SCREEN COMMENT (15) TEXT-R01 FOR FIELD P_DISP.

    SELECTION-SCREEN POSITION 32.
    PARAMETERS : P_CREA RADIOBUTTON GROUP GR1
                             DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (15) TEXT-R02 FOR FIELD P_CREA.
  SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN END   OF BLOCK B02.
