*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2110
*& 프로그램 명 : [소재] 생산계획 현황판 2025.08.14 by ZGSIDEV07
*& 개요   : 소재 사업부의 월간 판매계획 및 사내 이체 물량을 확인하고 재고를
*              감안한 생산 계획을 수립하는 프로그램
*& 생성일 : 2025.08.14
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
REPORT ZGTPPR2110 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR2110TOP.
INCLUDE ZGTPPR2110S01.
INCLUDE ZGTPPR2110C01.
INCLUDE ZGTPPR2110F01.
INCLUDE ZGTPPR2110O01.
INCLUDE ZGTPPR2110I01.

INITIALIZATION.
  PERFORM INITIALIZATION.
  PERFORM SET_BUTTON.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.
  PERFORM GET_PARAMETER_DESCRIPTION.

AT SELECTION-SCREEN ON  P_WERKS.
  PERFORM VALIDATION_OF_WERKS.

AT SELECTION-SCREEN ON  S_DATE.
  PERFORM VALIDATION_OF_PERIOD.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_WERKS.
  PERFORM F4_WERKS USING 'P_WERKS'.


AT SELECTION-SCREEN.
  CASE SY-UCOMM.
    WHEN 'FC01' OR 'FC02'.
      PERFORM CALL_MAINTAIN_VIEW.
  ENDCASE.

START-OF-SELECTION.
  PERFORM AUTHORITY_CHECKING_PROC.
  PERFORM GET_PROC.
  PERFORM DISP_PROC.
