*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPI3100
*& 프로그램 명 : [GT] 입고 자재문서 정보 전송
*& 개요   :
*& 생성일 : 2026.07.27
*& 생성자 : ZGODEV03
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGTPPI3100 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPI3100TOP.
INCLUDE ZGTPPI3100S01.
INCLUDE ZGTPPI3100I01.
INCLUDE ZGTPPI3100O01.
INCLUDE ZGTPPI3100F01.

INITIALIZATION.
  PERFORM SET_SCREEN_VALUE.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_TARGET.
  PERFORM F4_TARGET USING 'P_TARGET'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_LAYO.
  PERFORM SELECT_ALV_VARIANT CHANGING P_LAYO.

*AT SELECTION-SCREEN.
*  PERFORM AUTHORITY_CHECKING_PROC.

START-OF-SELECTION.
  PERFORM INPUT_CHECK.
  PERFORM GET_PROC.

  IF P_SEND EQ GC_X.
    IF P_BATCH EQ GC_X.
      PERFORM BATCH_EXEC.
    ELSE.
      IF GT_DATA[] IS INITIAL.
        MESSAGE S001 DISPLAY LIKE GC_W.
        LEAVE TO LIST-PROCESSING.
      ELSE.
        CLEAR: GV_DBCNT.
        GV_DBCNT = LINES( GT_DATA ).
        CONDENSE GV_DBCNT.
        MESSAGE S002 WITH GV_DBCNT.

        CALL SCREEN 0100.
      ENDIF.
    ENDIF.

  ELSEIF P_DISP EQ GC_X.
    IF GT_DATA[] IS INITIAL.
      MESSAGE S001 DISPLAY LIKE GC_W.
      LEAVE TO LIST-PROCESSING.
    ELSE.
      CLEAR: GV_DBCNT.
      GV_DBCNT = LINES( GT_DATA ).
      CONDENSE GV_DBCNT.
      MESSAGE S002 WITH GV_DBCNT.

      CALL SCREEN 0100.

    ENDIF.
  ENDIF.
