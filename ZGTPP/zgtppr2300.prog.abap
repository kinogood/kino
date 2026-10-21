*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2300
*& 프로그램 명 : [GT] 반제품 생산계획(전주 광) GAON 2026.04.07 by ZGSIDEV07
*& 개요   : 전주 광 사업부의 반제품 튜빙, 컬러링 공정의 생산 계획을 수립하는 프로그램
*              조장구성을 통해 수립된 피복, 집합 공정 계획 중 최초 공정 집합을 기준으로
*              하위 튜빙 생산 수량을 확정하고 다음 하위 공정 컬러링 조장을 확정
*              확정된 조장으로 계획 수립 월 단위 계획 오더를 생성하고 후속 프로세스인
*              일정 및 설비 확정 시 생산 오더로 전환됨
*& 생성일 : 2026.04.07
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
REPORT ZGTPPR2300 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR2300TOP.
INCLUDE ZGTPPR2300S01.
INCLUDE ZGTPPR2300C01.
INCLUDE ZGTPPR2300F01.
INCLUDE ZGTPPR2300O01.
INCLUDE ZGTPPR2300I01.


AT SELECTION-SCREEN OUTPUT.
  PERFORM SET_SELECTION_PERIOD.
  PERFORM GET_PARAMETER_DESCRIPTION.
  PERFORM MODIFY_FIRST_SCREEN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_AUFNR-LOW.
  PERFORM F4_ORDNO USING 'S_AUFNR-LOW'.

START-OF-SELECTION.
  PERFORM AUTHORITY_CHECKING_PROC.
  PERFORM GET_INIT.
  PERFORM GET_PROC.
  PERFORM PROC_DISP.
