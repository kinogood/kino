*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR9010
*& 프로그램 명 : [BD] 재고 변환(제품, 반제품)
*& 개요   : 기말 재고 기준으로 To-Be 판매오더, 품목, 배치번호로
*&          재고를 변환하는 기능임
*& 생성일 : 2025.03.28
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
REPORT ZGTPPR9010 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR9010TOP.
INCLUDE ZGTPPR9010S01.
INCLUDE ZGTPPR9010C01.
INCLUDE ZGTPPR9010H01.
INCLUDE ZGTPPR9010I01.
INCLUDE ZGTPPR9010O01.
INCLUDE ZGTPPR9010F01.

AT SELECTION-SCREEN.
  PERFORM AUTHORITY_CHECKING_PROC.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.

START-OF-SELECTION.
  PERFORM GET_DATA.
  PERFORM MODIFY_DATA.

  IF P_R1 EQ GC_X.   "재고정보저장
    IF GT_STOCK[] IS INITIAL.
      MESSAGE S001 DISPLAY LIKE GC_W.
      LEAVE TO LIST-PROCESSING.
    ELSE.
      CLEAR: GV_DBCNT.
      GV_DBCNT = LINES( GT_STOCK ).
      CONDENSE GV_DBCNT.
      MESSAGE S002 WITH GV_DBCNT.

      CALL SCREEN 0100.
    ENDIF.
  ELSEIF P_R2 EQ GC_X.   "재고변환처리
    IF GT_TRANS[] IS INITIAL.
      MESSAGE S001 DISPLAY LIKE GC_W.
      LEAVE TO LIST-PROCESSING.
    ELSE.
      CLEAR: GV_DBCNT.
      GV_DBCNT = LINES( GT_TRANS ).
      CONDENSE GV_DBCNT.
      MESSAGE S002 WITH GV_DBCNT.

      CALL SCREEN 0100.
    ENDIF.
  ELSEIF P_R3 EQ GC_X.   "재고변환결과조회/취소
    IF GT_TRANS_C[] IS INITIAL.
      MESSAGE S001 DISPLAY LIKE GC_W.
      LEAVE TO LIST-PROCESSING.
    ELSE.
      CLEAR: GV_DBCNT.
      GV_DBCNT = LINES( GT_TRANS_C ).
      CONDENSE GV_DBCNT.
      MESSAGE S002 WITH GV_DBCNT.

      CALL SCREEN 0100.
    ENDIF.
  ENDIF.
