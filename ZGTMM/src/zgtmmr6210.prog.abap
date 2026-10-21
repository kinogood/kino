*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMMR6210
*& 프로그램 명 : [BD] 공급업체 발주비율 조회
*& 개요   : 구매 제조지시에 의해 생성된 구매오더에 대해 발주그룹별로 공급업체 비율을 조회
*& 생성일 : 2025.03.05
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
REPORT ZGTMMR6210 NO STANDARD PAGE HEADING MESSAGE-ID ZGTMM01.


INCLUDE ZGTMMR6210TOP.
INCLUDE ZGTMMR6210C01.
INCLUDE ZGTMMR6210O01.
INCLUDE ZGTMMR6210I01.
INCLUDE ZGTMMR6210F01.


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
  PERFORM CHECK_AUTH.
  PERFORM CHECK_COND.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_SPMON-LOW.
  PERFORM F4_SPMON USING S_SPMON-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_SPMON-HIGH.
  PERFORM F4_SPMON USING S_SPMON-HIGH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_MTGRP-LOW.
  PERFORM F4_MTGRP USING 'S_MTGRP-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_MTGRP-HIGH.
  PERFORM F4_MTGRP USING 'S_MTGRP-HIGH'.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM SET_FCAT.
  PERFORM MAKE_ITAB.
  PERFORM GET_DATA.

  CHECK GV_CNT IS NOT INITIAL.
  CALL SCREEN 100.
