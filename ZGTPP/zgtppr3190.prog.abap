*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR3190
*& 프로그램 명 : [GT] 꼬리표 재고 조회 GAON
*& 개요   : 플랜트, 배치, 판매오더, 공급업체 재고를 꼬리표 정보와 함께 조회함
*& 생성일 : 2026.06.25
*& 생성자 : ZGODEV03
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGTPPR3190 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR3190TOP.
INCLUDE ZGTPPR3190S01.
INCLUDE ZGTPPR3190C01.
INCLUDE ZGTPPR3190H01.
INCLUDE ZGTPPR3190I01.
INCLUDE ZGTPPR3190O01.
INCLUDE ZGTPPR3190F01.

*- 레이아웃 탐색도움말
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_LAYO.
  PERFORM SELECT_ALV_VARIANT CHANGING P_LAYO.

START-OF-SELECTION.
  PERFORM GET_DATA.
  PERFORM MODIFY_DATA.

  IF GT_DISP[] IS INITIAL.
    MESSAGE S001 DISPLAY LIKE GC_W.
    LEAVE TO LIST-PROCESSING.
  ELSE.
    CALL SCREEN 0100.
  ENDIF.
