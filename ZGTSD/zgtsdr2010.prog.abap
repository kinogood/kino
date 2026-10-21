*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTSDR2010
*&  프로그램 명  : 적송처리
*&  개요       : 당월 출고 취소를 위한 적송 대상리스트 조회 및 처리
*&  생성일      : 2025.12.23
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
REPORT ZGTSDR2010 MESSAGE-ID ZGTSD01.

INCLUDE ZGTSDR2010TOP.
INCLUDE ZGTSDR2010C01.
INCLUDE ZGTSDR2010SEL.
INCLUDE ZGTSDR2010ALV.
INCLUDE ZGTSDR2010O01.
INCLUDE ZGTSDR2010I01.
INCLUDE ZGTSDR2010F01.
INCLUDE ZGTSDR2010F02.


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

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VKGRP-LOW.
  PERFORM F4_VKGRP USING 'S_VKGRP-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KUNNR-LOW.
  PERFORM F4_KUNNR USING S_KUNNR-LOW 'S_KUNNR-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KUNWE-LOW.
  PERFORM F4_KUNNR USING S_KUNWE-LOW 'S_KUNWE-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VSTEL-LOW.
  PERFORM F4_VSTEL USING 'S_VSTEL-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_LGORT-LOW.
  PERFORM F4_LGORT USING 'S_LGORT-LOW'.



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
