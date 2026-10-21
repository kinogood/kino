*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2280
*& 프로그램 명 : [GT] 상세작업일정수립(전주) GAON 2026.03.30 by ZGSIDEV07
*& 개요   : 조장표에서 생성된 생산 오더를 공정 상황에 맞게 작업장 및 작업 스케줄을 조정하고
*              수립된 일정을 확인하는 프로그램
*              추가 공정 작업이 필요한 경우 수작업 MTS 오더 및
*               시작업 오더를 생성하는 기능을 포함함
*& 생성일 : 2026.03.30
*& 생성자 : ZGSIDEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 2026.10.07  ZGODEV06  일정 취소시 드럼 정보 변경되므로 드럼 재지정 호출하여 재처리 추가
*&---------------------------------------------------------------------*
REPORT ZGTPPR2280 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR2280TOP.
INCLUDE ZGTPPR2280S01.
INCLUDE ZGTPPR2280C01.
INCLUDE ZGTPPR2280O01.
INCLUDE ZGTPPR2280I01.
INCLUDE ZGTPPR2280F01.

INITIALIZATION.
  PERFORM INIT_SCREEN.

AT SELECTION-SCREEN OUTPUT.
  PERFORM SET_SELECTION_PERIOD.
  PERFORM GET_PARAMETER_DESCRIPTION.
  PERFORM MODIFY_FIRST_SCREEN.

AT SELECTION-SCREEN ON  P_WEEK.
  PERFORM VALIDATION_OF_WEEK.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_WEEK.
  PERFORM F4_WEEK USING 'P_WEEK'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_GONGCD.
  PERFORM F4_GONG_CD USING 'P_GONGCD'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_GONGCD-LOW.
  PERFORM F4_GONG_CD USING 'S_GONGCD-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_GONGCD-HIGH.
  PERFORM F4_GONG_CD USING 'S_GONGCD-HIGH'.

START-OF-SELECTION.
  PERFORM AUTHORITY_CHECKING_PROC.
  PERFORM INPUT_CHECK.
  PERFORM GET_DATA.
  PERFORM CALL_SCREEN.
