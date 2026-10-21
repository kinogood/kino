*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTSDR1300
*&  프로그램 명  : Order Tracking
*&  개요       : 가온전선_Order Tracking
*&              ZSDR0200 COPY 생성
*&  생성일      : 2026.06.18
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
REPORT ZGTSDR1300  NO STANDARD PAGE HEADING
                              LINE-SIZE 164
                              MESSAGE-ID ZSD1.


INCLUDE ZGTSDR1300TOP.
INCLUDE ZGTSDR1300C01.
INCLUDE ZGTSDR1300SEL.
INCLUDE ZGTSDR1300F01.


*-----------------------------------------------------------------------
* INITIALIZATION
*-----------------------------------------------------------------------
INITIALIZATION.
  PERFORM INITIALIZATION.

*-----------------------------------------------------------------------
* AT SELECTION-SCREEN OUTPUT
*-----------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
  PERFORM SELECTION_SCREEN_OUTPUT.

*-----------------------------------------------------------------------
* AT SELECTION-SCREEN ON VALUE-REQUEST
*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM VALUE_REQUEST_VARI.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_AUART-LOW.
  PERFORM VALUE_REQUEST_AUART USING 'SO_AUART-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_AUART-HIGH.
  PERFORM VALUE_REQUEST_AUART USING 'SO_AUART-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_VKBUR-LOW.
  PERFORM F4_VKBUR USING 'SO_VKBUR-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_VKBUR-HIGH.
  PERFORM F4_VKBUR USING 'SO_VKBUR-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_VKGRP-LOW.
  PERFORM F4_VKGRP USING 'SO_VKGRP-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_VKGRP-HIGH.
  PERFORM F4_VKGRP USING 'SO_VKGRP-HIGH'.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN.                                             *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM SELECTION_SCREEN.


*--------------------------------------------------------------------*
*   START OF SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM MAIN.


*----------------------------------------------------------------------*
*     END-OF-SELECTION                                                 *
*----------------------------------------------------------------------*
END-OF-SELECTION.
  PERFORM DISPLAY.
