*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR1130
*& 프로그램 명 : [GT] 공정 보빈 마스터 관리
*& 개요   : 공정 보빈 데이터 관리
*& 생성일 : 2025.12.22
*& 생성자 : ZGODEV03
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGTPPR1130 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR1130TOP.
INCLUDE ZGTPPR1130S01.
INCLUDE ZGTPPR1130C01.
INCLUDE ZGTPPR1130H01.
INCLUDE ZGTPPR1130I01.
INCLUDE ZGTPPR1130O01.
INCLUDE ZGTPPR1130F01.

AT SELECTION-SCREEN.
  PERFORM AUTHORITY_CHECKING_PROC.

START-OF-SELECTION.
  PERFORM GET_PROC.

  CLEAR: GV_DBCNT.
  GV_DBCNT = LINES( GT_DATA ).
  CONDENSE GV_DBCNT.
  MESSAGE S002 WITH GV_DBCNT.

  CALL SCREEN 0100.
