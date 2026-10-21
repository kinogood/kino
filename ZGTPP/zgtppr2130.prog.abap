*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2130
*& 프로그램 명 : [GT] 조장 구성표 생성 GAON 2025.12.01 by ZGSIDEV07
*& 개요   : 소요량(판매오더)에 대한 개별 조장을 구성하고 그룹핑하여 한번에 생산할 대상을 선정하는 프로그램
*              조회 조건에 해당하는 판매 오더 수량에서 생산 계획 및 생산 오더로 생성된 수량을
*              차감하여 부족량을 계산하여 부족량이 있는 판매 오더에 대해 조장 구성표 번호를
*              생성하거나 또는 기존 번호에 포함하는 프로그램
*& 생성일 : 2025.12.01
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
REPORT ZGTPPR2130  MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR2130TOP.
INCLUDE ZGTPPR2130S01.
INCLUDE ZGTPPR2130C01.
INCLUDE ZGTPPR2130F01.
INCLUDE ZGTPPR2130O01.
INCLUDE ZGTPPR2130I01.

AT SELECTION-SCREEN OUTPUT.
  PERFORM SET_SELECTION_PERIOD.
  PERFORM GET_PARAMETER_DESCRIPTION.
  PERFORM MODIFY_FIRST_SCREEN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_AUFNR-LOW.
  PERFORM F4_ORDNO USING 'S_AUFNR-LOW'.


START-OF-SELECTION.
  PERFORM CHK_VALIDATION.
  PERFORM GET_PROC.
  CALL SCREEN 0100.
