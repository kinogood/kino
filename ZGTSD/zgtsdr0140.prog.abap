*********************************************************************
*  Module/Submodule :      SD
*  TYPE             :      물품매도확약서(Offer List/구매승인요청서)
*  P/G              :      Report
*  GAP-ID           :      SD033
*  Author           :      SDC06
*  Date             :      2025.04.14
************************************************************************
*                        MODIFICATION LOG
*----------------------------------------------------------------------*
* Date.      Author.  CSR #            Description.
*----------------------------------------------------------------------*
************************************************************************
REPORT ZGTSDR0140 NO STANDARD PAGE HEADING
                                 LINE-SIZE 300
                                 MESSAGE-ID ZSD1.

*-------------------------------------------------------------------*
*   INCLUDE (ALV COMMON MODULE)
*-------------------------------------------------------------------*
INCLUDE Z_SD_COMM_ALV.      " ALV DATA DEFINITION

INCLUDE ZGTSDR0140TOP.
INCLUDE ZGTSDR0140F02.
INCLUDE ZGTSDR0140F01.

*-------------------------------------------------------------------*
*   INITIALIZATION                                                  *
*-------------------------------------------------------------------*
INITIALIZATION.
  PERFORM INITIALIZATION.

*-------------------------------------------------------------------*
*   AT SELECTION SCREEN : Input Check & Message output
*-------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
** Layout관련
  PERFORM SET_DEFAULT_LAYOUT.
* Radio button click시 필드 활성/비활성
  PERFORM SCREEN_FIELD_CHANG.

** 레이아웃관련 F4.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM VALUE_REQUEST_VARI.

*-------------------------------------------------------------------*
*   AT SELECTION-SCREEN.
*-------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM CHECK_LAYOUT.

*-------------------------------------------------------------------*
*   START-OF-SELECTION                                              *
*-------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM CHECK_PARAM.
  PERFORM QUERY_DATA.

*-------------------------------------------------------------------*
*   END-OF-SELECTION                                                *
*-------------------------------------------------------------------*
END-OF-SELECTION.

** Layout관련
  CLEAR GS_VARIANT.
  MOVE-CORRESPONDING SPEC_LAYOUT TO GS_VARIANT.
**

  PERFORM  ALV_WRITE_RTN.
