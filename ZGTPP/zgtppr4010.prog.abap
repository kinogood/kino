*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR4010
*& 프로그램 명 : [BD] 제번간 이전전기
*& 개요   : 고객 변경, 프로젝트 변경 등의 사유로 특정 제번의 재고를
*&          다른 제번 혹은 플랜트 재고로 이전전기하는 기능임
*&          (이전전기 처리 결과를 조회하는 기능 포함)
*& 생성일 : 2025.01.02
*& 생성자 : ZGSIDEV08
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 2025.09.16 이정익  SRM2509-06700  제번간 전기시 from/to 배치번호 수정
*& 2025.10.16 이정익  SRM2510-03431  제번간 이전전기시 취소 판매오더 제외
*& 2026.02.04  이정익  SRM2602-01100  제번간 이전전기시 from 재고 일괄 처리 수정
*&---------------------------------------------------------------------*
REPORT ZGTPPR4010 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR4010TOP.
INCLUDE ZGTPPR4010S01.
INCLUDE ZGTPPR4010C01.
INCLUDE ZGTPPR4010H01.
INCLUDE ZGTPPR4010I01.
INCLUDE ZGTPPR4010O01.
INCLUDE ZGTPPR4010F01.

INITIALIZATION.
  PERFORM SET_SCREEN_VALUE.

AT SELECTION-SCREEN.
  PERFORM AUTHORITY_CHECKING_PROC.

AT SELECTION-SCREEN OUTPUT.
  PERFORM GET_PARAMETER_DESCRIPTION.
  PERFORM MODIFY_FIRST_SCREEN.

AT SELECTION-SCREEN ON P_TBSTNK.
  CHECK P_TBSTNK IS NOT INITIAL.
  PERFORM GET_FBSTNK USING P_TBSTNK.

*- 레이아웃 탐색도움말
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_LAYO.
  PERFORM SELECT_ALV_VARIANT CHANGING P_LAYO.

START-OF-SELECTION.
  PERFORM INPUT_CHECK.
  PERFORM GET_DATA.
  PERFORM SET_DATA.
  PERFORM MODIFY_DATA.

  IF P_R1 EQ GC_X.
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
  ELSEIF P_R2 EQ GC_X.
    IF GT_REVDATA[] IS INITIAL.
      MESSAGE S001 DISPLAY LIKE GC_W.
      LEAVE TO LIST-PROCESSING.
    ELSE.
      CLEAR: GV_DBCNT.
      GV_DBCNT = LINES( GT_REVDATA ).
      CONDENSE GV_DBCNT.
      MESSAGE S002 WITH GV_DBCNT.

      CALL SCREEN 0100.
    ENDIF.
  ENDIF.
