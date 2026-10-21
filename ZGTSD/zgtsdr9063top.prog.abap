*&---------------------------------------------------------------------*
*& Include          ZGTSDR9063TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES : VBAK, VBAP.

*----------------------------------------------------------------------*
* Class
*----------------------------------------------------------------------*
*CLASS : LCL_EVENT_RECEIVER DEFINITION DEFERRED.

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

          MSGPOP  TYPE RS_T_MSG,
        END OF GS_S0100.
DATA : GT_S0100   LIKE TABLE OF GS_S0100,
       GS_MESSAGE TYPE ZSDS_LOG_0001.
*----------------------------------------------------------------------*
*  ALV GRID.
*----------------------------------------------------------------------*

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
