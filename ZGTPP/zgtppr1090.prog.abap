*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR1090
*& 프로그램 명 : [GT] 자재마스터 고정값 설정(MRP,작업일정뷰)
*& 개요   : 자재마스터 고정값 정보를 엑셀을 통해 대량 업로드하거나
*&          ALV 화면을 통해 추가/변경하는 기능
*& 생성일 : 2025.12.12
*& 생성자 : ZGODEV03
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGTPPR1090 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR1090TOP.
INCLUDE ZGTPPR1090S01.
INCLUDE ZGTPPR1090C01.
INCLUDE ZGTPPR1090H01.
INCLUDE ZGTPPR1090I01.
INCLUDE ZGTPPR1090O01.
INCLUDE ZGTPPR1090F01.

INITIALIZATION.
  PERFORM SET_BUTTON.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM F4_FILENAME CHANGING P_FILE.

AT SELECTION-SCREEN.
  CASE SY-UCOMM.
    WHEN 'FC01'.
      PERFORM MAKE_EXCEL.
  ENDCASE.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.

START-OF-SELECTION.
  PERFORM AUTHORITY_CHECKING_PROC.
  PERFORM INPUT_CHECK.
  PERFORM GET_DATA.

  CHECK GV_ERROR EQ SPACE.

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
