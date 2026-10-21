*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMMR4121
*& 프로그램 명 : 외주 재고 초과 불출 이력
*& 개요   : 외주 재고 현황 조회 - 초과 불출 이력 조회 Report(일자별)
*& 생성일 : 2024.12.31
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
REPORT ZGTMMR4121 NO STANDARD PAGE HEADING MESSAGE-ID ZGTMM01.


INCLUDE ZGTMMR4121TOP.
INCLUDE ZGTMMR4121C01.
INCLUDE ZGTMMR4121O01.
INCLUDE ZGTMMR4121I01.
INCLUDE ZGTMMR4121F01.


*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM SET_INIT.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
* PERFORM MODIFY_SCREEN.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM CHECK_COND.
* PERFORM CHECK_AUTH.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_WERKS-LOW.
  PERFORM F4_WERKS USING 'S_WERKS-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_WERKS-HIGH.
  PERFORM F4_WERKS USING 'S_WERKS-HIGH'.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
*  PERFORM GET_DATA.

*--> [CHM2603-00086] 초과불출 메일링
  "--> TEST
*  IF SY-UNAME = 'ZLSGMM3'.
*    SY-BATCH = 'X'.
*  ENDIF.
  "<-- TEST

  IF SY-BATCH IS INITIAL.
    PERFORM GET_DATA.
    CHECK GV_CNT IS NOT INITIAL.
    CALL SCREEN 100.
  ELSE.
    PERFORM SEND_DATA.
  ENDIF.
*<-- [CHM2603-00086] 초과불출 메일링
