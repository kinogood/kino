*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2340
*& 프로그램 명 : [GT] 제품 OM-SM 전환 GAON 2026.07.10 by ZGSIDEV07
*& 개요   : 제품/반제품의 판매주문 대상으로 OM<-->SM 간 전환을 수행하는 기능
*& 생성일 : 2026.07.10
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
REPORT ZGTPPR2340 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR2340TOP.
INCLUDE ZGTPPR2340S01.
INCLUDE ZGTPPR2340C01.
INCLUDE ZGTPPR2340F01.
INCLUDE ZGTPPR2340O01.
INCLUDE ZGTPPR2340I01.

INITIALIZATION.
  PERFORM SET_INIT.

START-OF-SELECTION.
  PERFORM AUTHORITY_CHECKING_PROC.
  PERFORM GET_PROC.
  PERFORM PROC_DISP.
