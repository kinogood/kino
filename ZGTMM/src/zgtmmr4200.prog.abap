*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMMR4200
*& 프로그램 명 : Leadtime 모니터링
*& 개요   : Leadtime 현황 조회
*& 생성일 : 2024.12.04
*& 생성자 : ZGSIDEV03
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
REPORT ZGTMMR4200 NO STANDARD PAGE HEADING MESSAGE-ID ZGTMM01.


INCLUDE ZGTMMR4200TOP.
INCLUDE ZGTMMR4200C01.
INCLUDE ZGTMMR4200O01.
INCLUDE ZGTMMR4200I01.
INCLUDE ZGTMMR4200F01.


*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM SET_INIT.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
* PERFORM MODIFY_SCREEN.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM CHECK_COND.
* PERFORM CHECK_AUTH.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_WERKS-LOW.
  PERFORM F4_WERKS USING 'S_WERKS-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_WERKS-HIGH.
  PERFORM F4_WERKS USING 'S_WERKS-HIGH'.


*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM GET_DATA.

  CHECK GV_CNT IS NOT INITIAL.
  CALL SCREEN 100.
