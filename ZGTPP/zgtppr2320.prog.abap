*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2320
*& 프로그램 명 : [GT] MTS 생산오더 관리 GAON 2026.06.08 by ZGSIDEV07
*& 개요   : (군포) 재고 보충 MTS 생산지시 기능 구현
*               + 일별 자동 생산지시 내역을 메일링
*               전주 9DIES 기능 추가(매일 Full capa로 생성)
*& 생성일 : 2026.06.08
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
REPORT ZGTPPR2320 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR2320TOP.
INCLUDE ZGTPPR2320S01.
INCLUDE ZGTPPR2320C01.
INCLUDE ZGTPPR2320F01.
INCLUDE ZGTPPR2320O01.
INCLUDE ZGTPPR2320I01.


INITIALIZATION.
  PERFORM SET_BUTTON.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.

AT SELECTION-SCREEN.
  CASE SY-UCOMM.
    WHEN 'FC01'.
      PERFORM CALL_MAINTAIN_VIEW_01.
    WHEN 'FC02'.
      PERFORM CALL_MAINTAIN_VIEW_02.
  ENDCASE.

START-OF-SELECTION.
  PERFORM AUTHORITY_CHECKING_PROC.
  PERFORM GET_PROC.
  PERFORM PROC_DISPLAY.
