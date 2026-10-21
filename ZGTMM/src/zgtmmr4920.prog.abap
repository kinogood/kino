*&---------------------------------------------------------------------*
*& 모듈        : MM
*& 프로그램 ID : ZGTMMR4920
*& 프로그램 명 : 배차/계근 정보 전송관리
*& 개요   : 배차/계근 정보 전송관리(To 소재MOM)
*& 생성일 : 2025.11.07
*& 생성자 : ZLSGMM3
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
REPORT ZGTMMR4920 NO STANDARD PAGE HEADING MESSAGE-ID ZGTMM01.


INCLUDE ZGTMMR4920TOP.
*INCLUDE ZGTMMR4915TOP.
INCLUDE ZGTMMR4920C01.
*INCLUDE ZGTMMR4915C01.
INCLUDE ZGTMMR4920O01.
*INCLUDE ZGTMMR4915O01.
INCLUDE ZGTMMR4920I01.
*INCLUDE ZGTMMR4915I01.
INCLUDE ZGTMMR4920F01.
*INCLUDE ZGTMMR4915F01.


*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM SET_INIT.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SCREEN.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
* PERFORM CHECK_AUTH.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_IFSYT.
  PERFORM F4_IFSYT USING 'P_IFSYT'.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM CHECK_COND.
  PERFORM GET_DATA.

  CHECK GV_CNT IS NOT INITIAL.

  IF P_BAT = GC_X.
    PERFORM SEND_DATA USING ' '.
  ELSE.
    CALL SCREEN 100.
  ENDIF.
