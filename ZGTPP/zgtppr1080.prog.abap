*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR1080
*& 프로그램 명 : [GT] 작업장 등록/변경
*& 개요   : 작업장 정보를 엑셀을 통해 대량 업로드하여 생성/변경 처리함
*& 생성일 : 2025.12.02
*& 생성자 : ZGODEV03
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGTPPR1080 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR1080TOP.
INCLUDE ZGTPPR1080S01.
INCLUDE ZGTPPR1080I01.
INCLUDE ZGTPPR1080O01.
INCLUDE ZGTPPR1080F01.

INITIALIZATION.
  PERFORM SET_BUTTON.
  PERFORM SET_MODE.

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
  PERFORM INPUT_CHECK.
  PERFORM EXCEL_UPLOAD.
  PERFORM MODIFY_DATA.

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
