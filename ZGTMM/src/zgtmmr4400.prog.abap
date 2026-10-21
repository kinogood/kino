*&--------------------------------------------------------*
*& 모듈           : MM                                                                              *
*& 프로그램 ID : ZGTMMR4400                                                                 *
*& 프로그램 명 : [MM] 직송 접수 관리                                                  *
*& 개요          : 가온전선_OEM 직송의뢰를 확인하고 각 부서 별 처리 가능한 프로그램
*& 생성일       : 2026.01.22                                                                     *
*& 생성자      : ZGODEV04                                                                      *
*&--------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A                                                            *
*& 타 시스템 인터페이스 개요 : N/A                                                           *
*&-------------------------------------------------------*
*& 프로그램 수정이력
*&-------------------------------------------------------*
*&     수정일             수정자             수정개요
*& ----------   ---------  ---------------------------------*
*&
*&-------------------------------------------------------*
REPORT ZGTMMR4400 MESSAGE-ID ZGTMM01.

*&-------------------------------------------------------*
*&    INCLUDE.
*&-------------------------------------------------------*
INCLUDE ZGTMMR4400TOP.    " GLOBAL DATA
INCLUDE ZGTMMR4400C01.     " ALV CLASS
INCLUDE ZGTMMR4400O01.     " PBO-MODULES
INCLUDE ZGTMMR4400I01.       " PAI-MODULES
INCLUDE ZGTMMR4400F01.     " FORM-ROUTINES


*&---------------------------------------------------------------------*
*&    INITIALIZATION.
*&---------------------------------------------------------------------*
INITIALIZATION.
   PERFORM INITIALIZATION.

*&---------------------------------------------------------------------*
*&    AT SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM SELECTION_SCREEN_OUTPUT.

AT SELECTION-SCREEN.
  PERFORM SELECTION_SCREEN.
"권한 체크
  PERFORM CHECK_AUTH .

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKBUR-LOW.
  PERFORM F4_VKBUR.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKBUR-HIGH.
  PERFORM F4_VKBUR.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-LOW.
  PERFORM F4_VKGRP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-HIGH.
  PERFORM F4_VKGRP.


*&---------------------------------------------------------------------*
*&    START-OF-SELECTION.
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM INPUT_VALIDATION.      "INPUT DATA VALIDATION CHECK
  CHECK GV_ERR IS INITIAL.

  PERFORM GET_DATA.

*&---------------------------------------------------------------------*
*&    END-OF-SELECTION.
*&---------------------------------------------------------------------*
END-OF-SELECTION.

  CHECK GV_ERR IS INITIAL.
  CASE GC_X.
    WHEN RB_RCV.  "의뢰접수
       CALL SCREEN 100.

    WHEN RB_MNG ."의뢰관리
       CALL SCREEN 300.

    WHEN RB_GR.  "입고처리
       CALL SCREEN 400.

    WHEN OTHERS.
  ENDCASE.
*  CALL SCREEN 100.
