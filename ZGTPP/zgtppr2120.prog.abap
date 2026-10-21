*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2120
*& 프로그램 명 : [소재] 월간 사내이체 요청 2025.09.12 by ZGSIDEV07
*& 개요   :
*& 생성일 : 2025.09.12
*& 생성자 : ZGSIDEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
REPORT ZGTPPR2120  MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR2120TOP.
INCLUDE ZGTPPR2120S01.
INCLUDE ZGTPPR2120C01.
INCLUDE ZGTPPR2120F01.
INCLUDE ZGTPPR2120O01.
INCLUDE ZGTPPR2120I01.

INITIALIZATION.
  PERFORM INITIALIZATION.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.
  PERFORM GET_PARAMETER_DESCRIPTION.

AT SELECTION-SCREEN ON  P_WERKS.
  PERFORM VALIDATION_OF_WERKS.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_WERKS.
  PERFORM F4_WERKS USING 'P_WERKS'.

START-OF-SELECTION.
  PERFORM AUTHORITY_CHECKING_PROC.
  PERFORM GET_PROC.
  PERFORM DISP_PROC.
