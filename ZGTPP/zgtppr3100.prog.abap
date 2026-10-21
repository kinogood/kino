*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR3100
*& 프로그램 명 : [BD] 외주 전환 처리
*& 개요   : 제조지시 데이터를 기반으로 자작 공정을 외주 공정으로
*&          전환 처리하는 기능임
*& 생성일 : 2025.02.17
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
REPORT ZGTPPR3100 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR3100TOP.
INCLUDE ZGTPPR3100S01.
INCLUDE ZGTPPR3100C01.
INCLUDE ZGTPPR3100H01.
INCLUDE ZGTPPR3100I01.
INCLUDE ZGTPPR3100O01.
INCLUDE ZGTPPR3100F01.

INITIALIZATION.
  PERFORM SET_SCREEN_VALUE.

AT SELECTION-SCREEN.
  PERFORM AUTHORITY_CHECKING_PROC.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.

*- 레이아웃 탐색도움말
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_LAYO.
  PERFORM SELECT_ALV_VARIANT CHANGING P_LAYO.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_GONG-LOW.
  PERFORM F4_GONG_CD USING S_GONG-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_GONG-HIGH.
  PERFORM F4_GONG_CD USING S_GONG-HIGH.

START-OF-SELECTION.
  PERFORM INIT_DATA.
  PERFORM GET_DATA.
  PERFORM MODIFY_DATA.

  IF GT_DATA[] IS INITIAL.
    MESSAGE S001 DISPLAY LIKE GC_W.
    LEAVE TO LIST-PROCESSING.
  ELSE.
    CALL SCREEN 0100.
  ENDIF.
