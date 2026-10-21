*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR4050
*& 프로그램 명 : [BD] 구매오더별 생산투입 이력
*& 개요   : 구매오더의 제번 기준으로 입고된 원자재 수량과
*&          생산오더의 제번 기준으로 투입된 원자재 수량을 매칭하는 기능
*& 생성일 : 2025.05.12
*& 생성자 : ZGSIDEV08
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
REPORT ZGTPPR4050 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR4050TOP.
INCLUDE ZGTPPR4050S01.
INCLUDE ZGTPPR4050C01.
INCLUDE ZGTPPR4050H01.
INCLUDE ZGTPPR4050I01.
INCLUDE ZGTPPR4050O01.
INCLUDE ZGTPPR4050F01.

INITIALIZATION.
  PERFORM SET_SCREEN_VALUE.

AT SELECTION-SCREEN.
  PERFORM AUTHORITY_CHECKING_PROC.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.

START-OF-SELECTION.
  PERFORM INPUT_CHECK.
  PERFORM GET_DATA.
  PERFORM SET_DATA.
  PERFORM MODIFY_DATA.

  IF GT_DATA[] IS INITIAL.
    MESSAGE S001 DISPLAY LIKE GC_W.
    LEAVE TO LIST-PROCESSING.
  ELSE.
    CALL SCREEN 0100.
  ENDIF.
