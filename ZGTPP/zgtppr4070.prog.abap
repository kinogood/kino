*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR4070
*& 프로그램 명 : [BD] 도체가공 실적 마감
*& 개요   : 월말 기준 미완료된 도체가공 생산오더에 대해
*&          당월 생산실적(생산입고, 생산확정, 자재투입)을 취소하고,
*&          차월 생산실적으로 재처리하는 기능
*& 생성일 : 2025.05.27
*& 생성자 : ZGSIDEV08
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 2025.11.04   이정익     도체 실적 취소후 로그테이블 상태값 업데이트 처리
*&---------------------------------------------------------------------*
REPORT ZGTPPR4070 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR4070TOP.
INCLUDE ZGTPPR4070S01.
INCLUDE ZGTPPR4070C01.
INCLUDE ZGTPPR4070H01.
INCLUDE ZGTPPR4070I01.
INCLUDE ZGTPPR4070O01.
INCLUDE ZGTPPR4070F01.

INITIALIZATION.
  PERFORM SET_SCREEN_VALUE.

AT SELECTION-SCREEN.
  PERFORM AUTHORITY_CHECKING_PROC.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.

*- 레이아웃 탐색도움말
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_LAYO.
  PERFORM SELECT_ALV_VARIANT CHANGING P_LAYO.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_SPMON.
  PERFORM F4_SPMON CHANGING P_SPMON.

START-OF-SELECTION.
  PERFORM CHK_COCKPIT.
  PERFORM INIT_DATA.
  PERFORM GET_DATA.

  IF GT_DATA[] IS INITIAL.
    MESSAGE S001 DISPLAY LIKE GC_W.
    LEAVE TO LIST-PROCESSING.
  ELSE.
    CALL SCREEN 0100.
  ENDIF.
