*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTSDR9004
*&  프로그램 명  : SO 품목 소요량 유형 변경(Mig)
*&  개요       : 가온전선_SO 품목 소요량 유형 변경
*&  생성일      : 2026.07.06
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
REPORT ZGTSDR9005 MESSAGE-ID ZGTSD01.

INCLUDE ZGTSDR9005TOP.
*INCLUDE ZGTSDR9004TOP.
*INCLUDE ZGTSDR9002TOP.
INCLUDE ZGTSDR9005C01.
*INCLUDE ZGTSDR9004C01.
*INCLUDE ZGTSDR9002C01.
INCLUDE ZGTSDR9005SEL.
*INCLUDE ZGTSDR9004SEL.
*INCLUDE ZGTSDR9002SEL.
INCLUDE ZGTSDR9005ALV.
*INCLUDE ZGTSDR9004ALV.
*INCLUDE ZGTSDR9002ALV.
INCLUDE ZGTSDR9005O01.
*INCLUDE ZGTSDR9004O01.
*INCLUDE ZGTSDR9002O01.
INCLUDE ZGTSDR9005I01.
*INCLUDE ZGTSDR9004I01.
*INCLUDE ZGTSDR9002I01.
INCLUDE ZGTSDR9005F01.
*INCLUDE ZGTSDR9004F01.
*INCLUDE ZGTSDR9002F01.

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


AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM F4_FILENAME CHANGING P_FILE.

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
