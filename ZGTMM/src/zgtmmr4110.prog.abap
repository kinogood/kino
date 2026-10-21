*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMMR4110
*& 프로그램 명 : 외주 재고 불출 관리
*& 개요   : 외주 재고 불출 관리 - 반출처리, 반출처리 결과조회, 승인관리, 품의상태 조회
*& 생성일 : 2024.10.21
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  : 2026.01.05
*& 수정자 : ZGODEV04
*& 수정개요: 가온전선_사급자재 출고를 위한 구분 로직 추가(한도예외업체체크로직)
*& 수정일  : 2026.04.10
*& 수정자 : ZGODEV04
*& 수정개요: 가온전선_통문증 발급 프로그램 호출 분개
*&---------------------------------------------------------------------*
REPORT ZGTMMR4110 NO STANDARD PAGE HEADING MESSAGE-ID ZGTMM01.


INCLUDE ZGTMMR4110TOP.
INCLUDE ZGTMMR4110C01.
INCLUDE ZGTMMR4110O01.
INCLUDE ZGTMMR4110I01.
INCLUDE ZGTMMR4110F01.


*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM SET_INIT.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SCREEN.

  PERFORM PBO_0300.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM CHECK_ACTV.
  PERFORM CHECK_AUTH.

  PERFORM PAI_1000.
  PERFORM PAI_0300.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_WERKS.
  PERFORM F4_WERKS.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_LGORT.
  PERFORM F4_LGORT.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_LIFNR-LOW.
* PERFORM F4_LIFNR USING 'S_LIFNR-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FPATH.
  PERFORM F4_FPATH.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM CHECK_MAND_COND.
  CHECK GV_ERR IS INITIAL.

  PERFORM GET_DATA.
  CHECK GV_CNT IS NOT INITIAL.

  IF P_GOP = GC_X.
    CALL SCREEN 100.
  ELSE.
    CALL SCREEN 110.
  ENDIF.
