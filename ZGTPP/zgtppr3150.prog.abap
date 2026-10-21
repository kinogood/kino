*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR3150
*& 프로그램 명 : [GT] 배관 생산오더 및 생산실적 관리
*& 개요   : 배관에 대한 생산오더 및 생산실적을 관리하는 기능
*& 생성일 : 2025.12.04
*& 생성자 : ZGODEV03
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGTPPR3150 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR3150TOP.
INCLUDE ZGTPPR3150S01.
INCLUDE ZGTPPR3150C01.
INCLUDE ZGTPPR3150H01.
INCLUDE ZGTPPR3150I01.
INCLUDE ZGTPPR3150O01.
INCLUDE ZGTPPR3150F01.

INITIALIZATION.
  PERFORM SET_SCREEN_VALUE.
  PERFORM SET_BUTTON.

AT SELECTION-SCREEN.
  PERFORM AUTHORITY_CHECKING_PROC.
  CASE SY-UCOMM.
    WHEN 'FC01'.
      PERFORM CALL_ZGTPPT3320.  "배관품목관리
  ENDCASE.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.

*- 레이아웃 탐색도움말
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_LAYO.
  PERFORM SELECT_ALV_VARIANT CHANGING P_LAYO.

START-OF-SELECTION.
  PERFORM INPUT_CHECK.
  PERFORM GET_DATA.
  PERFORM MODIFY_DATA.

  IF GT_PROC[] IS INITIAL.
    MESSAGE S001 DISPLAY LIKE GC_W.
    LEAVE TO LIST-PROCESSING.
  ELSE.
    CALL SCREEN 0100.
  ENDIF.
