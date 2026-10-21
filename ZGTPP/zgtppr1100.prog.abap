*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR1100
*& 프로그램 명 : [GT] 자재마스터 확장(MRP,작업일정뷰)
*& 개요   : 자재마스터의 기설정한 고정값들을 불러와서 추가/수정 후
*&          MRP,작업일정 뷰를 플랜트 확장하는 기능(저장위치 확장 포함)
*& 생성일 : 2025.12.15
*& 생성자 : ZGODEV03
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGTPPR1100 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR1100TOP.
INCLUDE ZGTPPR1100S01.
INCLUDE ZGTPPR1100C01.
INCLUDE ZGTPPR1100H01.
INCLUDE ZGTPPR1100I01.
INCLUDE ZGTPPR1100O01.
INCLUDE ZGTPPR1100F01.

INITIALIZATION.
  PERFORM SET_BUTTON.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM F4_FILENAME CHANGING P_FILE.

AT SELECTION-SCREEN.
  CASE SY-UCOMM.
    WHEN 'FC01'.
      IF P_R5 EQ GC_X AND P_R4 EQ GC_X.
        PERFORM MAKE_EXCEL.
      ELSEIF P_R6 EQ GC_X.
        PERFORM SET_COMP_SCRAP.
      ENDIF.
  ENDCASE.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.

START-OF-SELECTION.
  PERFORM AUTHORITY_CHECKING_PROC.
  PERFORM INPUT_CHECK.
  PERFORM GET_DATA.

  CHECK GV_ERROR EQ SPACE.

  IF P_R5 EQ GC_X.
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

  ELSEIF P_R6 EQ GC_X.
    IF P_R1 EQ GC_X OR P_R2 EQ GC_X.
      IF GT_DATA_RM[] IS INITIAL.
        MESSAGE S001 DISPLAY LIKE GC_W.
        LEAVE TO LIST-PROCESSING.
      ELSE.
        CLEAR: GV_DBCNT.
        GV_DBCNT = LINES( GT_DATA_RM ).
        CONDENSE GV_DBCNT.
        MESSAGE S002 WITH GV_DBCNT.

        CALL SCREEN 0100.
      ENDIF.
    ELSEIF P_R7 EQ GC_X.
      IF GT_DATA_UPDATE[] IS INITIAL.
        MESSAGE S001 DISPLAY LIKE GC_W.
        LEAVE TO LIST-PROCESSING.
      ELSE.
        CLEAR: GV_DBCNT.
        GV_DBCNT = LINES( GT_DATA_UPDATE ).
        CONDENSE GV_DBCNT.
        MESSAGE S002 WITH GV_DBCNT.

        CALL SCREEN 0100.
      ENDIF.
    ENDIF.
  ENDIF.
