*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSDR9007
*& 프로그램 명 : [GT] 보관품 S/O PA 세그먼트 갱신
*& 개요   : 가온전선 보관품 S/O PA 세그먼트 갱신 BDC
*& 생성일 : 2026.09.03
*& 생성자 : ZGODEV03
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램                수정이력
*&---------------------------------------------------------------------*
*& 2026.09.03  ZGODEV03    INIT.
*&---------------------------------------------------------------------*
REPORT ZGTSDR9007 MESSAGE-ID ZGTSD01.

INCLUDE ZGTSDR9007TOP.
INCLUDE ZGTSDR9007S01.
INCLUDE ZGTSDR9007I01.
INCLUDE ZGTSDR9007O01.
INCLUDE ZGTSDR9007F01.

START-OF-SELECTION.
  PERFORM GET_DATA.

  IF GT_DATA[] IS INITIAL.
    MESSAGE S018 DISPLAY LIKE GC_W.
    LEAVE TO LIST-PROCESSING.
  ELSE.
    IF P_BATCH EQ GC_X.
      PERFORM BATCH_EXEC.
    ELSE.
      CALL SCREEN 0100.
    ENDIF.
  ENDIF.
