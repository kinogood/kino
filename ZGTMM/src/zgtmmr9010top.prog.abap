*&---------------------------------------------------------------------*
*& Include          ZGTMMR9010TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF TY_LIST,
    BLDAT   TYPE MATDOC-BLDAT,
    BUDAT   TYPE MATDOC-BUDAT,
    SOBKZ   TYPE MATDOC-SOBKZ,
    LIFNR   TYPE MATDOC-LIFNR,
    WERKS   TYPE MATDOC-WERKS,
    LGORT   TYPE MATDOC-LGORT,
    MATNR   TYPE MATDOC-MATNR,
    CHARG   TYPE MATDOC-CHARG,
    ERFMG   TYPE MATDOC-ERFMG,
    ERFME   TYPE MATDOC-ERFME,
    AMT     TYPE STRING, "MATDOC-DMBTR,
    VBELN   TYPE MATDOC-KDAUF,
    VBELP   TYPE MATDOC-KDPOS,
    MBLNR   TYPE MATDOC-MBLNR,
    STATUS  TYPE  C LENGTH 4,
    MESSAGE TYPE BAPI_MSG,
*    WAERS   TYPE WAERS,
    ZCOLOR  TYPE LVC_T_SCOL,
  END OF TY_LIST,
  BEGIN OF TY_XLS,
    BLDAT TYPE STRING,
    BUDAT TYPE STRING,
    SOBKZ TYPE STRING,
    LIFNR TYPE STRING,
    WERKS TYPE STRING,
    LGORT TYPE STRING,
    MATNR TYPE STRING,
    CHARG TYPE STRING,
    ERFMG TYPE STRING,
    ERFME TYPE STRING,
    AMT   TYPE STRING,
    VBELN TYPE STRING,
    VBELP TYPE STRING,
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
  GT_ECOMM  TYPE STANDARD TABLE OF SY-UCOMM,
  GV_OKCODE TYPE SY-UCOMM.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS:
  GC_1 TYPE C LENGTH 1 VALUE '1',
  GC_A TYPE C LENGTH 1 VALUE 'A',
  GC_B TYPE C LENGTH 1 VALUE 'B',
  GC_C TYPE C LENGTH 1 VALUE 'C',
  GC_D TYPE C LENGTH 1 VALUE 'D',
  GC_E TYPE C LENGTH 1 VALUE 'E',
  GC_K TYPE C LENGTH 1 VALUE 'K',
  GC_O TYPE C LENGTH 1 VALUE 'O',
  GC_R TYPE C LENGTH 1 VALUE 'R',
  GC_S TYPE C LENGTH 1 VALUE 'S',
  GC_I TYPE C LENGTH 1 VALUE 'I',
  GC_U TYPE C LENGTH 1 VALUE 'U',
  GC_V TYPE C LENGTH 1 VALUE 'V'.

CONSTANTS:
  GC_05  TYPE C LENGTH 2 VALUE '05',
  GC_561 TYPE BWART VALUE '561'.

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

  PARAMETERS:
    P_FILE TYPE RLGRAP-FILENAME OBLIGATORY,
    P_TEST TYPE BAPI2017_GM_GEN-TESTRUN DEFAULT ABAP_TRUE.

SELECTION-SCREEN END   OF BLOCK B01.

SELECTION-SCREEN BEGIN OF BLOCK B02 WITH FRAME TITLE TEXT-S02.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT (60) TEXT-W01.
  SELECTION-SCREEN END   OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT (60) TEXT-W02.
  SELECTION-SCREEN END   OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT (60) TEXT-W03.
  SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN END   OF BLOCK B02.
