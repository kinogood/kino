*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR1060
*& 프로그램 명 : [BD] 표준 Routing 생성/변경
*& 개요   : MES로부터 수신 받은 품목별 표준작업시간을 기반으로
*&          표준 라우팅을 생성/변경하는 기능임
*& 생성일 : 2024.12.11
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
REPORT ZGTPPR1060 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR1060TOP.
INCLUDE ZGTPPR1060S01.
INCLUDE ZGTPPR1060C01.
INCLUDE ZGTPPR1060I01.
INCLUDE ZGTPPR1060O01.
INCLUDE ZGTPPR1060F01.

AT SELECTION-SCREEN.
  PERFORM AUTHORITY_CHECKING_PROC.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.

START-OF-SELECTION.
  PERFORM GET_DATA.
  PERFORM MODIFY_DATA.

  IF GT_DATA[] IS INITIAL.
    MESSAGE S001 DISPLAY LIKE GC_W.
    LEAVE TO LIST-PROCESSING.
  ELSE.
    IF P_EXEC EQ GC_X.       "라우팅 생성/변경
      IF P_BATCH EQ GC_X.
        PERFORM BATCH_EXEC_ROUTING.
      ELSE.
        CLEAR: GV_DBCNT.
        GV_DBCNT = LINES( GT_DATA ).
        CONDENSE GV_DBCNT.
        MESSAGE S002 WITH GV_DBCNT.

        CALL SCREEN 0100.
      ENDIF.

    ELSE.    "히스토리 조회
      CLEAR: GV_DBCNT.
      GV_DBCNT = LINES( GT_DATA ).
      CONDENSE GV_DBCNT.
      MESSAGE S002 WITH GV_DBCNT.

      CALL SCREEN 0100.
    ENDIF.
  ENDIF.
