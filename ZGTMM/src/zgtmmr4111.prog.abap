*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMMR4111
*& 프로그램 명 : 외주 재고 환입 관리
*& 개요   : 외주 재고 환입 관리
*& 생성일 : 2025.02.03
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
REPORT ZGTMMR4111 NO STANDARD PAGE HEADING MESSAGE-ID ZGTMM01.


INCLUDE ZGTMMR4111TOP.
INCLUDE ZGTMMR4111C01.
INCLUDE ZGTMMR4111O01.
INCLUDE ZGTMMR4111I01.
INCLUDE ZGTMMR4111F01.


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
  PERFORM CHECK_ACTV.
  PERFORM CHECK_AUTH.

  PERFORM PAI_1000.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_WERKS.
  PERFORM F4_WERKS.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_LGORT.
  PERFORM F4_LGORT.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM CHECK_MAND_COND.
  CHECK GV_ERR IS INITIAL.

  PERFORM GET_DATA.
  CHECK GV_CNT IS NOT INITIAL.

  CALL SCREEN 100.
