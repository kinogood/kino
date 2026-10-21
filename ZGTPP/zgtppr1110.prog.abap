*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR1110
*& 프로그램 명 : [GT] 생산버전 등록(가온전선)
*& 개요   : BOM 및 라우팅 정보를 기반으로 생산버전을 제안/생성하는 기능
*& 생성일 : 2025.12.19
*& 생성자 : ZGODEV03
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGTPPR1110 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR1110TOP.
INCLUDE ZGTPPR1110S01.
INCLUDE ZGTPPR1110C01.
INCLUDE ZGTPPR1110H01.
INCLUDE ZGTPPR1110I01.
INCLUDE ZGTPPR1110O01.
INCLUDE ZGTPPR1110F01.

INITIALIZATION.
  PERFORM SET_SCREEN_VALUE.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.

AT SELECTION-SCREEN.
  PERFORM AUTHORITY_CHECKING_PROC.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_SPGCD.
  PERFORM F4_SPGCD USING 'P_SPGCD'.

START-OF-SELECTION.
  PERFORM INPUT_CHECK.
  PERFORM GET_DATA.

  IF GT_DATA[] IS INITIAL.
    MESSAGE S001 DISPLAY LIKE GC_W.
    LEAVE TO LIST-PROCESSING.
  ELSE.
    IF P_BATCH EQ GC_X.
      PERFORM BATCH_EXEC.
    ELSE.
      CALL SCREEN 0100.
    ENDIF.
  ENDIF.
