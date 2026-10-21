*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMMR6400
*& 프로그램 명 : [BD] 발주그룹 공급업체 지정
*& 개요   : 제조지시 별 자재그룹에 대한 고정 공급업체 지정(For Pgm.ZGTMMR6200)
*& 생성일 : 2025.02.21
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
REPORT ZGTMMR6400 NO STANDARD PAGE HEADING MESSAGE-ID ZGTMM01.


INCLUDE ZGTMMR6400TOP.
INCLUDE ZGTMMR6400C01.
INCLUDE ZGTMMR6400O01.
INCLUDE ZGTMMR6400I01.
INCLUDE ZGTMMR6400F01.


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

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM CHECK_COND.
  PERFORM CHECK_AUTH.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_SMTGRP.
  PERFORM F4_MTGRP USING 'P_SMTGRP'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_EMTGRP.
  PERFORM F4_MTGRP USING 'P_EMTGRP'.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  CHECK GV_ERR IS INITIAL.
  PERFORM GET_KEY.
  PERFORM GET_DATA.

  IF P_DISP = GC_X.
    CHECK GV_CNT IS NOT INITIAL.
  ENDIF.
  CALL SCREEN 100.
