*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2180
*& 프로그램 명 : [GT] 인쇄 롤라 관리 GAON 2026.05.21 by ZGSIDEV07
*& 개요   : 인쇄 롤라에 대한 제작 문구 및 요청을 기록/관리하는 기능
*& 생성일 : 2026.05.21
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
REPORT ZGTPPR2180 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR2180TOP.
INCLUDE ZGTPPR2180S01.
INCLUDE ZGTPPR2180C01.
INCLUDE ZGTPPR2180F01.
INCLUDE ZGTPPR2180O01.
INCLUDE ZGTPPR2180I01.


INITIALIZATION.
  PERFORM SET_INIT_SELECTION_PERIOD.
  PERFORM SET_BUTTON.

AT SELECTION-SCREEN.
  CASE SY-UCOMM.
    WHEN 'FC01'.
      PERFORM CALL_MAINTAIN_VIEW.
  ENDCASE.

START-OF-SELECTION.
  PERFORM AUTHORITY_CHECKING_PROC.
  PERFORM GET_PROC.
  PERFORM PROC_DISP.
