*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTSDR1270
*&  프로그램 명  : 로컬지급처 판매처에 지정
*&  개요       : 가온전선_로컬지급처를 판매처에 지정
*&  생성일      : 2026.05.14
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
REPORT ZGTSDR1270 MESSAGE-ID ZGTSD01.

INCLUDE ZGTSDR1270TOP.
INCLUDE ZGTSDR1270C01.
INCLUDE ZGTSDR1270SEL.
INCLUDE ZGTSDR1270ALV.
INCLUDE ZGTSDR1270O01.
INCLUDE ZGTSDR1270I01.
INCLUDE ZGTSDR1270F01.

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

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KUNN2-LOW.
  PERFORM F4_KUNNR USING S_KUNN2-LOW 'S_KUNN2-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KUNN2-HIGH.
  PERFORM F4_KUNNR USING S_KUNN2-HIGH 'S_KUNN2-HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KUNNR-LOW.
  PERFORM F4_KUNNR USING S_KUNNR-LOW 'S_KUNNR-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KUNNR-HIGH.
  PERFORM F4_KUNNR USING S_KUNNR-HIGH 'S_KUNNR-HIGH'.

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
