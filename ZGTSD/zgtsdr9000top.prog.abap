*&---------------------------------------------------------------------*
*& Include          ZGTSDR0030TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES : VBAK, VBAP, CDHDR.

*----------------------------------------------------------------------*
* Class
*----------------------------------------------------------------------*
CLASS : LCL_EVENT_RECEIVER DEFINITION DEFERRED.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS : GC_E TYPE CHAR1 VALUE 'E',
            GC_X TYPE CHAR1 VALUE 'X'.

CONSTANTS : GC_CRLF TYPE C VALUE CL_BCS_CONVERT=>GC_CRLF,
            GC_TAB  TYPE C VALUE CL_BCS_CONVERT=>GC_TAB.


*----------------------------------------------------------------------*
* VARIABLE
*----------------------------------------------------------------------*
DATA : GV_SAVEOK LIKE SY-UCOMM,
       GV_OKCODE LIKE SY-UCOMM,
       GV_ERROR  TYPE CHAR1,
       GV_ANSWER TYPE CHAR1.

*----------------------------------------------------------------------*
* TYPE & STRUCTURE & INTERNAL TABLE
*----------------------------------------------------------------------*
DATA : GT_FCODE   TYPE TABLE OF SY-UCOMM,
       GT_CELLTAB TYPE LVC_T_STYL.

"ALV Default Fields
TYPES : BEGIN OF TY_S_ALVDEF,
          STATU TYPE ICON_D,     "신규/변경/삭제 상태 ICON
          INSRT TYPE CHAR1,      "신규 여부 Flag : 'X' or ' '
          MODI  TYPE CHAR1,      "변경 여부 Flag : 'X' or ' '
          CELLS TYPE LVC_T_STYL, "Cell Style
          CELLC TYPE LVC_T_STYL, "Cell Color
        END OF TY_S_ALVDEF.

TYPES : BEGIN OF TY_S_CHG,
          VKORG TYPE VKORG,
          MATNR TYPE MATNR,
        END OF TY_S_CHG,
        TY_T_CHG TYPE TABLE OF TY_S_CHG
                   WITH NON-UNIQUE SORTED KEY KEY_MODE
                   COMPONENTS VKORG.

DATA  : BEGIN OF GS_S0100,
          ICON    TYPE CHAR10,

          BSTNK   TYPE BSTNK,

          VKBUR   TYPE VKBUR,
          VKGRP   TYPE VKGRP,
          KUNNR   TYPE KUNNR,
          MATNR   TYPE MATNR,
          ZDRUM   TYPE VBAP-ZDRUM,
          STDAT   TYPE VBAP-STDAT,
          ARKTX   TYPE ARKTX,
          WERKS   TYPE WERKS_D,
          KWMENG  TYPE KWMENG,
          VRKME   TYPE VRKME,
          KBETR   TYPE KBETR,
          NETWR   TYPE NETWR,
          WAERK   TYPE WAERK,
          BSTKD_E TYPE BSTKD_E,
          VBELV   TYPE VBELV,
          POSNV   TYPE POSNV,

          MSGPOP  TYPE RS_T_MSG.
          INCLUDE  TYPE ZGTSDT9062.
          INCLUDE  TYPE TY_S_ALVDEF. "ALV Default Fields
DATA : END OF GS_S0100.
DATA : GT_S0100 LIKE TABLE OF GS_S0100.


DATA : GS_PARAM  TYPE CTU_PARAMS,
       GT_BDCTAB TYPE TABLE OF BDCDATA WITH HEADER LINE,
       GT_MSG    TYPE TABLE OF BDCMSGCOLL WITH HEADER LINE.

DATA : GS_HEADER_IN   TYPE BAPISDHD1,
       GS_HEADER_INX  TYPE BAPISDHD1X,
       GT_ITEMS_IN    TYPE CRMT_BAPISDITM_T,
       GT_ITEMS_INX   TYPE CRMT_BAPISDITMX_T,
       GT_PARTNERS    TYPE ZBAPIPARNR_TAB,
       GT_SCH_IN      TYPE ZISI_BAPISCHDL_TT,
       GT_SCH_INX     TYPE OIJ_BAPISCHDLX_T,
       GT_COND_IN     TYPE CRMT_BAPICOND_T,
       GT_COND_INX    TYPE CRMT_BAPICONDX_T,
       GT_EXTENSIONIN LIKE  BAPIPAREX OCCURS 0,
       GT_CFGS_REF    LIKE BAPICUCFG  OCCURS 0,
       GT_CFGS_INST   LIKE BAPICUINS  OCCURS 0,
       GT_CFGS_PART   LIKE BAPICUPRT  OCCURS 0,
       GT_CFGS_VAL    LIKE BAPICUVAL  OCCURS 0,
       GT_RETURN      LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE,
       GV_VBELN       TYPE VBELN_VA.

DATA : GS_BAPE_VBAP   TYPE BAPE_VBAP,
       GS_BAPE_VBAPX  TYPE BAPE_VBAPX,
       GS_BAPE_VBAK   TYPE BAPE_VBAK,
       GS_BAPE_VBAKX  TYPE BAPE_VBAKX,
       GS_EXTENSIONIN TYPE BAPIPAREX.

"화면 변경 정보
DATA : GT_CHG   TYPE TY_T_CHG.

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



*DATA : GO_EVNT TYPE REF TO LCL_ALV_EVENT_HANDLER. "EVENT
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

DEFINE _CUNIT.
  CASE &1.
    WHEN 'I'.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          INPUT                = &2
          LANGUAGE             = SY-LANGU
        IMPORTING
          OUTPUT               = &2
        EXCEPTIONS
          UNIT_NOT_FOUND       = 1
          OTHERS               = 2.

    WHEN 'O'.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          INPUT                = &2
          LANGUAGE             = SY-LANGU
        IMPORTING
          OUTPUT               = &2
        EXCEPTIONS
          UNIT_NOT_FOUND       = 1
          OTHERS               = 2.
  ENDCASE.
END-OF-DEFINITION.

DEFINE PARVW_INPUT.
  CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
END-OF-DEFINITION.
