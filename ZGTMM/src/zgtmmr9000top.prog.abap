*&---------------------------------------------------------------------*
*& Include          ZGTMMR1040TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF TY_LIST,
    LIFNR   TYPE LFA1-LIFNR,
    EKORG   TYPE LFM1-EKORG,
    WAERS   TYPE LFM1-WAERS,
    ZTERM   TYPE LFM1-ZTERM,
    INCO1   TYPE LFM1-INCO1,
    VERKF   TYPE LFM1-VERKF,
    TELF1   TYPE LFM1-TELF1,
    WEBRE	  TYPE LFM1-WEBRE,
    KALSK	  TYPE LFM1-KALSK,
    KZAUT	  TYPE LFM1-KZAUT,
    MEPRF	  TYPE LFM1-MEPRF,
    STATUS  TYPE  C LENGTH 4,
    MESSAGE TYPE BAPI_MSG,
    ERDAT   TYPE LFM1-ERDAT,
    ERNAM   TYPE LFM1-ERNAM,
  END OF TY_LIST,
  BEGIN OF TY_XLS,
    LIFNR TYPE STRING,
    EKORG TYPE STRING,
    WAERS TYPE STRING,
    ZTERM TYPE STRING,
    INCO1 TYPE STRING,
    VERKF TYPE STRING,
    TELF1 TYPE STRING,
    WEBRE TYPE STRING,
    KALSK TYPE STRING,
    KZAUT TYPE STRING,
    MEPRF TYPE STRING,
  END OF TY_XLS.

TYPES:
  TY_T_XLS  TYPE STANDARD TABLE OF TY_XLS,
  TY_T_LIST TYPE STANDARD TABLE OF TY_LIST.

*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*

DATA:
  GT_LIST   TYPE STANDARD TABLE OF TY_LIST.

DATA:
  GV_EKORG TYPE LFM1-EKORG,
  GV_LIFNR TYPE LFM1-LIFNR.

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
  GC_I TYPE C LENGTH 1 VALUE 'I',
  GC_U TYPE C LENGTH 1 VALUE 'U'.

*----------------------------------------------------------------------*
* ALV
*----------------------------------------------------------------------*
DATA:
  GO_GRID  TYPE REF TO CL_GUI_ALV_GRID,
  GO_CONT  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
  GV_ASAVE TYPE CHAR01 VALUE GC_A,
  GS_LAYO  TYPE LVC_S_LAYO,
  GS_VARI  TYPE DISVARIANT,
  GT_FCAT  TYPE LVC_T_FCAT,
  GT_SORT  TYPE LVC_T_SORT,
  GT_EXCL  TYPE UI_FUNCTIONS.

*----------------------------------------------------------------------*
* Screen - 1000
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-S01.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : P_CREA RADIOBUTTON GROUP GR1
                             USER-COMMAND EXE DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (10) TEXT-R01 FOR FIELD P_CREA.

    SELECTION-SCREEN POSITION 15.
    PARAMETERS : P_DISP RADIOBUTTON GROUP GR1.
    SELECTION-SCREEN COMMENT (10) TEXT-R02 FOR FIELD P_DISP.
  SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN END   OF BLOCK B01.

SELECTION-SCREEN BEGIN OF BLOCK B02 WITH FRAME TITLE TEXT-S02.

  PARAMETERS:
    P_FILE TYPE RLGRAP-FILENAME MODIF ID FIL.

  SELECT-OPTIONS:
    S_EKORG FOR GV_EKORG MODIF ID EKO,
    S_LIFNR FOR GV_LIFNR MODIF ID LIF.

SELECTION-SCREEN END   OF BLOCK B02.
