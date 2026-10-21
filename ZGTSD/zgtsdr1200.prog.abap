*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTSDR1200
*&  프로그램 명  : 부서별 담보현황
*&  개요       : 가온전선_부서별 담보현황
*&  생성일      : 2026.03.09
*&  생성자      : ZGODEV01
*&---------------------------------------------------------------------*
*& 외부호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*----------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
REPORT ZGTSDR1200 MESSAGE-ID ZGTSD01.

INCLUDE ZGTSDR1200TOP.
INCLUDE ZGTSDR1200C01.
INCLUDE ZGTSDR1200SEL.
INCLUDE ZGTSDR1200ALV.
INCLUDE ZGTSDR1200O01.
INCLUDE ZGTSDR1200I01.
INCLUDE ZGTSDR1200F01.

*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM INITIALIZATION.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN.                                             *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM SELECTION_SCREEN.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN OUTPUT.                                      *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM SELECTION_SCREEN_OUTPUT.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKBUR-LOW.
  PERFORM F4_VKBUR USING 'S_VKBUR-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-LOW.
  PERFORM F4_VKGRP USING 'S_VKGRP-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_CUMON.
  PERFORM F4_SPMON USING P_CUMON.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_BFMON.
  PERFORM F4_SPMON USING P_BFMON.

*----------------------------------------------------------------------*
*     START-OF-SELECTION                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM MAIN.


*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.
  PERFORM DISPLAY.
