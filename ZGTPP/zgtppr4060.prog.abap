*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR4060
*& 프로그램 명 : [BD] 생산오더 자재투입 배부 처리
*& 개요   : 포장재 및 정산자재 대상으로 생산오더에 투입 처리하는 기능
*& 생성일 : 2025.05.15
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
REPORT ZGTPPR4060 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR4060TOP.
INCLUDE ZGTPPR4060S01.
INCLUDE ZGTPPR4060C01.
INCLUDE ZGTPPR4060H01.
INCLUDE ZGTPPR4060I01.
INCLUDE ZGTPPR4060O01.
INCLUDE ZGTPPR4060F01.

INITIALIZATION.
  PERFORM SET_SCREEN_VALUE.
  PERFORM SET_BUTTON.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM F4_FILENAME CHANGING P_FILE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_SPMON.
  PERFORM F4_SPMON CHANGING P_SPMON.

AT SELECTION-SCREEN.
  PERFORM AUTHORITY_CHECKING_PROC.
  CASE SY-UCOMM.
    WHEN 'FC01'.
      PERFORM MAKE_EXCEL.
  ENDCASE.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.

START-OF-SELECTION.
  PERFORM CHK_COCKPIT.
  PERFORM INPUT_CHECK.
  PERFORM GET_DATA.
  PERFORM MODIFY_DATA.

  IF P_R1 EQ GC_X.
    IF P_RP EQ GC_X.
      IF GT_PDATA[] IS INITIAL.
        MESSAGE S001 DISPLAY LIKE GC_W.
        LEAVE TO LIST-PROCESSING.
      ELSE.
        CALL SCREEN 0100.
      ENDIF.
    ELSEIF P_RC EQ GC_X.
      IF GT_CDATA[] IS INITIAL.
        MESSAGE S001 DISPLAY LIKE GC_W.
        LEAVE TO LIST-PROCESSING.
      ELSE.
        CALL SCREEN 0100.
      ENDIF.
    ENDIF.

  ELSEIF P_R2 EQ GC_X.
    IF P_RP EQ GC_X.
      IF GT_REVDATA[] IS INITIAL.
        MESSAGE S001 DISPLAY LIKE GC_W.
        LEAVE TO LIST-PROCESSING.
      ELSE.
        CALL SCREEN 0100.
      ENDIF.
    ELSEIF P_RC EQ GC_X.
      IF GT_CREVDATA[] IS INITIAL.
        MESSAGE S001 DISPLAY LIKE GC_W.
        LEAVE TO LIST-PROCESSING.
      ELSE.
        CALL SCREEN 0100.
      ENDIF.
    ENDIF.

  ENDIF.
