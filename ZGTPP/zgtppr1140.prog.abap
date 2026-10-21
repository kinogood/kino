*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR1140
*& 프로그램 명 : [GT] 대체 BOM 생성 GAON 2026.04.23 by ZGSIDEV07
*& 개요   :
*    1) 표준설계서 기반으로 Tandem 공정에 대한 대체 BOM(90)을 생성하는 기능 구현(+생산버전 생성)
*    2) 절연 배합에 대한 대체 BOM(02)을 생성하는 기능 구현(+생산버전 생성)"
*& 생성일 : 2026.04.23
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
REPORT ZGTPPR1140  MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR1140TOP.
INCLUDE ZGTPPR1140S01.
INCLUDE ZGTPPR1140C01.
INCLUDE ZGTPPR1140I01.
INCLUDE ZGTPPR1140O01.
INCLUDE ZGTPPR1140F01.

INITIALIZATION.
  PERFORM INITIALIZATION.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.

START-OF-SELECTION.
  PERFORM AUTHORITY_CHECKING_PROC.
  PERFORM INPUT_CHECK.
  PERFORM GET_DATA.
  PERFORM PROC_DISP.
