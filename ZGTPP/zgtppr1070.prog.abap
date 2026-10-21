*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR1070
*& 프로그램 명 : [BD] 생산버전 등록
*& 개요   : 품목코드의 조달유형 및 특별조달을 감안하여
*&          기생성된 BOM, 라우팅을 기반으로 생산버전을 생성하는 기능
*& 생성일 : 2025.03.06
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
REPORT ZGTPPR1070 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR1070TOP.
INCLUDE ZGTPPR1070S01.
INCLUDE ZGTPPR1070C01.
INCLUDE ZGTPPR1070I01.
INCLUDE ZGTPPR1070O01.
INCLUDE ZGTPPR1070F01.

INITIALIZATION.
  PERFORM SET_SCREEN_VALUE.

AT SELECTION-SCREEN.
  PERFORM AUTHORITY_CHECKING_PROC.

START-OF-SELECTION.
  PERFORM GET_DATA.
  PERFORM MODIFY_DATA.

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
