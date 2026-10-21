*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2360
*& 프로그램 명 : [GT] 주문 할당 후 판매오더 정보 갱신 GAON 2026.08.25 by ZGSIDEV07
*& 개요   : 주문 할당 후 판매오더 정보 갱신/재처리/조회하는 기능
*& 생성일 : 2026.08.25
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
REPORT ZGTPPR2360 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR2360TOP.
INCLUDE ZGTPPR2360S01.
INCLUDE ZGTPPR2360C01.
INCLUDE ZGTPPR2360I01.
INCLUDE ZGTPPR2360O01.
INCLUDE ZGTPPR2360F01.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.


START-OF-SELECTION.
  PERFORM CHK_VALIDATION.
  PERFORM GET_PROC.
  PERFORM PROC.
