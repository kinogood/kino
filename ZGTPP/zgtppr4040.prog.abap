*&---------------------------------------------------------------------*
*& 모듈           : PP
*& 프로그램 ID : ZGTPPR4040
*& 프로그램 명 : [GT] 원재료(배치관리) 실사차 조정
*& 개요   : 배치 관리 투입 원재료 대상 월 마감 실사에서 발생한 차이
*&          수량을 마감월 오더 투입 수량을 조정을 통해 수량 보정하는
*&          프로그램
*& 생성일 : 2025.04.08
*& 생성자 : ZGSIDEV06
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
REPORT ZGTPPR4040 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR4040TOP. "Global 변수, 테이블 및 ALV 변수

INCLUDE ZGTPPR4040S01. " 조회 조건 관련

INCLUDE ZGTPPR4040O01. "PBO

INCLUDE ZGTPPR4040C01. "ALV 관련 로직

INCLUDE ZGTPPR4040F01. "일반 로직 PERFORM 문

INCLUDE ZGTPPR4040F02. "ALV 관련 PERFORM 문

INCLUDE ZGTPPR4040I01. "PAI
*-----------------------------------------------------------------------
*-- Initialization.
*-----------------------------------------------------------------------
INITIALIZATION.

  P_MONTH = SY-DATUM+0(6).
  P_BUDAT = SY-DATUM.
  PERFORM GET_LAST_DAY_OF_MONTH CHANGING P_BUDAT.

*-----------------------------------------------------------------------
*-- At Selection-Screen Output
*-----------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.

  PERFORM GET_PARAMETER_DESCRIPTION.
  PERFORM MODIFY_FIRST_SCREEN.
  PERFORM SET_BUDAT.

*-----------------------------------------------------------------------
*-- At Selection-Screen On Value-Request for Field
*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_MONTH.

  PERFORM F4_POPUP_TO_SELECT_MONTH.
*-----------------------------------------------------------------------
*-- At Selection-Screen
*-----------------------------------------------------------------------
AT SELECTION-SCREEN.

  PERFORM AUTHORITY_CHECKING_PROC.

*-----------------------------------------------------------------------
*-- Start-Of-Selection
*-----------------------------------------------------------------------
START-OF-SELECTION.

  PERFORM GET_INIT_AND_LAST_DATE.

  PERFORM GET_DATA.

*-----------------------------------------------------------------------
*-- End-Of-Selection
*-----------------------------------------------------------------------
END-OF-SELECTION.

  IF GT_DISP[] IS NOT INITIAL.

    CALL SCREEN 100.

  ELSE.

    MESSAGE S001.

  ENDIF.
