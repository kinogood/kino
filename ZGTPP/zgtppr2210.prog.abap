*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2210
*& 프로그램 명 : [GT] RCCP 데이터 산출
*& 개요   : 확정된 물량 기준으로 소요시간을 계산하는 기능
*& - 작업지시 확정 분 + 영업수주 확정 분 + 수기 등록/제외 분(RCCP 수기 등록)
*& - 산출 버전 관리 수행
*& - 산출 대상별 소요시간 계산
*& 생성일 : 2026.07.18
*& 생성자 : ZGODEV03
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGTPPR2210 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR2210TOP.
INCLUDE ZGTPPR2210S01.
INCLUDE ZGTPPR2210C01.
INCLUDE ZGTPPR2210H01.
INCLUDE ZGTPPR2210I01.
INCLUDE ZGTPPR2210O01.
INCLUDE ZGTPPR2210F01.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.

START-OF-SELECTION.
  PERFORM INPUT_CHECK.
  PERFORM GET_DATA.

  IF GT_TOP[] IS INITIAL.
    MESSAGE S001 DISPLAY LIKE GC_W.
    LEAVE TO LIST-PROCESSING.
  ELSE.
    CALL SCREEN 0100.
  ENDIF.
