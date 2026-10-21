*********************************************************************
*  Module/Submodule :      SD
*  TYPE             :      영업부서 마감처리 상세조회
*  P/G              :      Report
*  Author           :
*  GAP-ID           :
*  Date             :      2025.04.01
*********************************************************************
*                        MODIFICATION LOG
*--------------------------------------------------------------------
*  Date.           Author.        description.
*--------------------------------------------------------------------
*  2025.04.01                  INITIAL RELEASE
* 2025.10.16 ZLSGSD2 CHM2510-00065 부가세 추가 리프레시 기능추가
*********************************************************************

*********************************************************************
REPORT ZGTSDR1082 NO STANDARD PAGE HEADING
                  LINE-SIZE 300 MESSAGE-ID ZSD1.

*-------------------------------------------------------------------*
*   INCLUDE (ALV COMMON MODULE)
*-------------------------------------------------------------------*
INCLUDE Z_SD_COMM_ALV.      " ALV DATA DEFINITION

INCLUDE ZGTSDR1082TOP. " Global Data
INCLUDE ZGTSDR1082SEL. " Selection-Screen
INCLUDE ZGTSDR1082F01. " FORM-Routines

*-------------------------------------------------------------------*
*   SELECTION SCREEN                                                *
*-------------------------------------------------------------------*

*-------------------------------------------------------------------*
*   INITIALIZATION                                                  *
*-------------------------------------------------------------------*
INITIALIZATION.

  IMPORT G_ITAB_T FROM MEMORY ID 'ZGTSD07'.
  IMPORT G_IMODE  FROM MEMORY ID 'ZGTSD071'.
  IMPORT G_P_SPART FROM MEMORY ID 'ZGTSD072'.
  IMPORT G_FKDAT_HIGH  FROM MEMORY ID 'ZGTSD073'.
  IMPORT G_FKDAT_LOW  FROM MEMORY ID 'ZGTSD074'.
  IMPORT G_P_VKORG FROM MEMORY ID 'ZGTSD1075'.

*-------------------------------------------------------------------*
*   AT SELECTION SCREEN : Input Check & Message output
*-------------------------------------------------------------------*
AT SELECTION-SCREEN.

*-------------------------------------------------------------------*
*   START-OF-SELECTION                                              *
*-------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM MODI_DATA.


*-------------------------------------------------------------------*
*   END-OF-SELECTION                                                *
*-------------------------------------------------------------------*
END-OF-SELECTION.

  PERFORM  ALV_WRITE_RTN.
