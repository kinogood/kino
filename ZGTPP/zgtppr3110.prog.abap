*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR3110
*& 프로그램 명 : [GT] KIT 구성비교 2025.03.12 by ZGSIDEV07
*& 개요   : KIT 생산 오더 구성품, 표준 BOM, KIT 작업표준을 비교하여
*              포장 구성의 정합성을 확인하는 프로그램
*& 생성일 : 2025.03.12
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
REPORT ZGTPPR3110 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR3110TOP.
INCLUDE ZGTPPR3110S01.
INCLUDE ZGTPPR3110C01.
INCLUDE ZGTPPR3110F01.
INCLUDE ZGTPPR3110O01.
INCLUDE ZGTPPR3110I01.

AT SELECTION-SCREEN OUTPUT.
  PERFORM GET_PARAMETER_DESCRIPTION.
  PERFORM MODIFY_FIRST_SCREEN.

START-OF-SELECTION.
  PERFORM CHK_AUTH.
  PERFORM GET_PROC.
  PERFORM PROC_DISP.
