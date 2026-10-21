*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR3070
*& 프로그램 명 : [BD] 생산오더 생성 및 조회/변경
*& 개요   : 제조지시 데이터를 기반으로 생산오더를 생성하고,
*&          생성 결과 조회 및 변경, 생산오더 삭제을  수행하는 기능
*& 생성일 : 2025.01.10
*& 생성자 : ZGSIDEV08
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 2025.10.17  이정익  SRM2510-03432 조회된 제번에 대해서 잠금 기능 추가
*&---------------------------------------------------------------------*
REPORT ZGTPPR3070 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR3070TOP.
INCLUDE ZGTPPR3070S01.
INCLUDE ZGTPPR3070C01.
INCLUDE ZGTPPR3070H01.
INCLUDE ZGTPPR3070I01.
INCLUDE ZGTPPR3070O01.
INCLUDE ZGTPPR3070F01.

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
  PERFORM GET_DATA.
  PERFORM MODIFY_DATA.
  PERFORM SET_LOCK USING 'X'.    "SRM2510-03432 제번별 Lock 추가


  IF P_R1 EQ GC_X.
    IF GT_CTOP[] IS INITIAL.
      MESSAGE S001 DISPLAY LIKE GC_W.
      LEAVE TO LIST-PROCESSING.
    ELSE.
      CALL SCREEN 0100.
    ENDIF.
  ELSEIF P_R2 EQ GC_X.
    IF GT_STOP[] IS INITIAL.
      MESSAGE S001 DISPLAY LIKE GC_W.
      LEAVE TO LIST-PROCESSING.
    ELSE.
      CALL SCREEN 0100.
    ENDIF.
  ENDIF.
