*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR4130
*& 프로그램 명 : [GT] 재고실사 결과 점검
*& 개요   : 재고실사 결과를 조회하고, Lot별 이력을 점검하는 기능
*& 생성일 : 2026.09.09
*& 생성자 : ZGODEV03
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGTPPR4130 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR4130TOP.
INCLUDE ZGTPPR4130S01.
INCLUDE ZGTPPR4130C01.
INCLUDE ZGTPPR4130H01.
INCLUDE ZGTPPR4130I01.
INCLUDE ZGTPPR4130O01.
INCLUDE ZGTPPR4130F01.

INITIALIZATION.
  PERFORM SET_SCREEN_VALUE.

AT SELECTION-SCREEN.
  PERFORM AUTHORITY_CHECKING_PROC.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.

START-OF-SELECTION.
  PERFORM INPUT_CHECK.
  PERFORM GET_DATA.

  IF GT_DATA[] IS INITIAL.
    MESSAGE S001 DISPLAY LIKE GC_W.
    LEAVE TO LIST-PROCESSING.
  ELSE.
    CLEAR: GV_DBCNT.
    GV_DBCNT = LINES( GT_DATA ).
    CONDENSE GV_DBCNT.

    CALL SCREEN 0100.
  ENDIF.
