*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2150
*& 프로그램 명 : [GT] 신선작업지시 GAON 2026.01.26 by ZGSIDEV07
*& 개요   :  조장구성표를 기준으로 제선 공정의 신선재와 외장재의 작업지시를 진행하는 프로그램
*               조장 구성 진행 후 연선의 실제 소요량으로 신선 작업 지시 진행
*               소선경 정보를 활용하여 연입률로 작업 지시 수량을 계산함
*& 생성일 : 2026.01.26
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
REPORT ZGTPPR2150  MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR2150TOP.
INCLUDE ZGTPPR2150S01.
INCLUDE ZGTPPR2150C01.
INCLUDE ZGTPPR2150F01.
INCLUDE ZGTPPR2150O01.
INCLUDE ZGTPPR2150I01.

INITIALIZATION.
  PERFORM SET_BUTTON.

AT SELECTION-SCREEN OUTPUT.
  PERFORM GET_PARAMETER_DESCRIPTION.
  PERFORM MODIFY_FIRST_SCREEN.

AT SELECTION-SCREEN.
  CASE SY-UCOMM.
    WHEN 'FC01'.
      PERFORM CALL_MAINTAIN_VIEW.
  ENDCASE.

START-OF-SELECTION.
  PERFORM AUTHORITY_CHECKING_PROC.
  PERFORM GET_PROC.
  CALL SCREEN 0100.
