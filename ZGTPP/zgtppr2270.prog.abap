*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2270
*& 프로그램 명 : [GT] 랜 표준조장 구성 GAON 2026.03.13 by ZGSIDEV07
*& 개요   : 전주 공장 랜 조장 구성을 진행 하고 생산 계획을 수립하는 프로그램
*              시판과 수출 및 특수 스펙을 구분하여 관리 함
*              시판의 경우 매월 지정된 수량의 공정별 시판 계획을 월 마감 시점에 수립하고
*              이전 월의 계획을 정리
*              수출 및 특수 스펙은 주문 수량을 기준으로 공정별 조장 구성을 수행하여
*              생산 계획을 수립하며 조장 구성 시 공정의 표준 조장이 고려됨
*& 생성일 : 2026.03.13
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
REPORT ZGTPPR2270 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR2270TOP.
INCLUDE ZGTPPR2270S01.
INCLUDE ZGTPPR2270C01.
INCLUDE ZGTPPR2270F01.
INCLUDE ZGTPPR2270O01.
INCLUDE ZGTPPR2270I01.

INITIALIZATION.
  PERFORM SET_BUTTON.

AT SELECTION-SCREEN OUTPUT.
  PERFORM SET_SELECTION_PERIOD.
  PERFORM GET_PARAMETER_DESCRIPTION.
  PERFORM MODIFY_FIRST_SCREEN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_AUFNR-LOW.
  PERFORM F4_ORDNO USING 'S_AUFNR-LOW'.

AT SELECTION-SCREEN.
  CASE SY-UCOMM.
    WHEN 'FC01'.
      PERFORM CALL_MAINTAIN_VIEW.
  ENDCASE.

START-OF-SELECTION.
  PERFORM CHK_VALIDATION.
  PERFORM AUTHORITY_CHECKING_PROC.
  PERFORM GET_PROC.
  PERFORM PROC_DISP.
