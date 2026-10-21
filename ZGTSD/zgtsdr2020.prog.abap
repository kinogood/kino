*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTSDR2020
*&  프로그램 명  : 적송 매출처리
*&  개요       : 가온전선_적송된 물량에 대해 출고 및 매출처리
*&  생성일      : 2026.03.25
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
REPORT ZGTSDR2020 MESSAGE-ID ZGTSD01.

INCLUDE ZGTSDR2020TOP.
INCLUDE ZGTSDR2020C01.
INCLUDE ZGTSDR2020SEL.
INCLUDE ZGTSDR2020ALV.
INCLUDE ZGTSDR2020O01.
INCLUDE ZGTSDR2020I01.
INCLUDE ZGTSDR2020F01.
INCLUDE ZGTSDR2020F02.


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

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_SPART-LOW.
  PERFORM F4_SPART USING 'S_SPART-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKBUR-LOW.
  PERFORM F4_VKBUR USING 'S_VKBUR-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-LOW.
  PERFORM F4_VKGRP USING 'S_VKGRP-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KUNNR-LOW.
  PERFORM F4_KUNNR USING S_KUNNR-LOW 'S_KUNNR-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KUNAG-LOW.
  PERFORM F4_KUNNR USING S_KUNAG-LOW 'S_KUNAG-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VSTEL-LOW.
  PERFORM F4_VSTEL USING 'S_VSTEL-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_LGORT-LOW.
  PERFORM F4_LGORT USING 'S_LGORT-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_SPMON.
  PERFORM F4_SPMON USING P_SPMON.

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
