*&---------------------------------------------------------------------*
*& Include          ZGTSDI0001TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES : EORD.

*----------------------------------------------------------------------*
* Class
*----------------------------------------------------------------------*
CLASS : LCL_EVENT_RECEIVER DEFINITION DEFERRED.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS : GC_E     TYPE CHAR1 VALUE 'E',
            GC_X     TYPE CHAR1 VALUE 'X',
            GC_WERKS TYPE WERKS_D VALUE '1306'.

CONSTANTS : GC_CRLF TYPE C VALUE CL_BCS_CONVERT=>GC_CRLF,
            GC_TAB  TYPE C VALUE CL_BCS_CONVERT=>GC_TAB.


*----------------------------------------------------------------------*
* VARIABLE
*----------------------------------------------------------------------*
DATA : GV_SAVEOK LIKE SY-UCOMM,
       GV_OKCODE LIKE SY-UCOMM,
       GV_EDIT   TYPE CHAR1,
       GV_ERROR  TYPE CHAR1,
*      GV_TAR    TYPE ZGTETARGET,
       GV_ANSWER TYPE CHAR1.

*----------------------------------------------------------------------*
* TYPE & STRUCTURE & INTERNAL TABLE
*----------------------------------------------------------------------*
DATA : GT_FCODE   TYPE TABLE OF SY-UCOMM,
       GT_CELLTAB TYPE LVC_T_STYL.

"ALV Default Fields
TYPES : BEGIN OF TY_S_ALVDEF,
          STATU TYPE ICON_D,     "신규/변경/삭제 상태 ICON
          MSG   TYPE TEXT100,
          INSRT TYPE CHAR1,      "신규 여부 Flag : 'X' or ' '
          MODI  TYPE CHAR1,      "변경 여부 Flag : 'X' or ' '
          SEL   TYPE CHAR1,
          CELLS TYPE LVC_T_STYL, "Cell Style
          CELLC TYPE LVC_T_STYL, "Cell Color
        END OF TY_S_ALVDEF.

TYPES : BEGIN OF TY_S_CHG,
          WERKS TYPE WERKS_D,
          MATNR TYPE MATNR,
          ZEORD TYPE DZEORD,
        END OF TY_S_CHG,
        TY_T_CHG TYPE TABLE OF TY_S_CHG
                   WITH NON-UNIQUE SORTED KEY KEY_MODE
                   COMPONENTS WERKS MATNR ZEORD.

DATA  : BEGIN OF GS_S0100,
          NAME1 TYPE LFA1-NAME1,
          MAKTX TYPE MAKTX.
          INCLUDE    TYPE EORD.
          INCLUDE    TYPE TY_S_ALVDEF. "ALV Default Fields
DATA : END OF GS_S0100.
DATA : GT_S0100 LIKE TABLE OF GS_S0100.

"화면 변경 정보
DATA : GT_CHG   TYPE TY_T_CHG.

RANGES : GR_MATNR FOR EORD-MATNR,
         GR_LIFNR FOR EORD-LIFNR.
*----------------------------------------------------------------------*
*  ALV GRID.
*----------------------------------------------------------------------*

DATA : GT_TOOLBAR TYPE UI_FUNCTIONS.
DATA : GO_CON     TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_GRID    TYPE REF TO CL_GUI_ALV_GRID,
       GT_FCAT    TYPE LVC_T_FCAT,
       GS_FCAT    TYPE LVC_S_FCAT,
       GT_SORT    TYPE LVC_T_SORT,   " ALV Sort
       GS_LAYOUT  TYPE LVC_S_LAYO,
       GO_SPLIT   TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       GO_CON_TOP TYPE REF TO CL_GUI_CONTAINER,
       GO_DOCU    TYPE REF TO CL_DD_DOCUMENT.


DATA : GS_VARIANT TYPE DISVARIANT.
DATA : GS_STBL TYPE LVC_S_STBL.

DATA : GT_ROW TYPE LVC_T_ROW WITH HEADER LINE,
       GS_ROW LIKE GT_ROW.

*----------------------------------------------------------------------*
* DEFINE
*----------------------------------------------------------------------*
DEFINE __CLE.
  CLEAR: &1, &1[].
END-OF-DEFINITION.

DEFINE __RNG.
  &1-SIGN   = &2.
  &1-OPTION = &3.
  &1-LOW    = &4.
  &1-HIGH    = &5.
  APPEND &1. CLEAR &1.
END-OF-DEFINITION.

DEFINE __ALPHA_IN.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
END-OF-DEFINITION.

DEFINE __ALPHA_OU.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
END-OF-DEFINITION.

DEFINE __GET_ROWS.
  __CLE : &2.
  CHECK &1 IS BOUND.
  CALL METHOD &1->GET_SELECTED_ROWS
     IMPORTING
       ET_INDEX_ROWS = &2[].

  DELETE &2 WHERE ROWTYPE IS NOT INITIAL.

  CHECK &3 IS NOT INITIAL.


END-OF-DEFINITION.
