*&--------------------------------------------------------*
*& 모듈           : MM                                                                              *
*& 프로그램 ID : ZGTMMR5000                                                                *
*& 프로그램 명 : [MM] 송장 일괄 처리
*& 개요          :가온전선_송장 처리 대상을 일괄 조회/처리할 수 있는 프로그램
*& 생성일       : 2026.03.18                                                                    *
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
REPORT ZGTMMR5000 MESSAGE-ID ZGTMM01.

*&-------------------------------------------------------*
*&    INCLUDE.
*&-------------------------------------------------------*
INCLUDE ZGTMMR5000TOP.    " GLOBAL DATA
INCLUDE ZGTMMR5000C01.    " ALV CLASS
INCLUDE ZGTMMR5000O01.   " PBO-MODULES
INCLUDE ZGTMMR5000I01.    " PAI-MODULES
INCLUDE ZGTMMR5000F01.  " FORM-ROUTINES


*&---------------------------------------------------------------------*
*&    INITIALIZATION.
*&---------------------------------------------------------------------*
INITIALIZATION.
  PERFORM INITIALIZATION. "초기값 세팅

*&---------------------------------------------------------------------*
*&    AT SELECTION-SCREEN.
*&---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
*  PERFORM F4_FOR_VARIANT USING P_VARI.

AT SELECTION-SCREEN OUTPUT.
  PERFORM SELECTION_SCREEN_OUTPUT. "스크린 PBO

AT SELECTION-SCREEN.


*&---------------------------------------------------------------------*
*&    START-OF-SELECTION.
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM CHECK_AUTH.
  PERFORM INPUT_VALIDATION.      "INPUT DATA VALIDATION CHECK
  CHECK GV_ERR IS INITIAL.

*  PERFORM CHECK_AUTH USING P_BUKRS. "권한 체크
   PERFORM GET_DATA.

*&---------------------------------------------------------------------*
*&    END-OF-SELECTION.
*&---------------------------------------------------------------------*
END-OF-SELECTION.

  CHECK GV_ERR IS INITIAL.
  IF P_INV = GC_X.
    CALL SCREEN 100.
  ELSEIF P_DIS = GC_X.
    CALL SCREEN 300.
  ENDIF.
