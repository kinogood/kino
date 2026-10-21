*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTSDR9064
*&  프로그램 명  : 적송 피킹처리 Migration
*&  개요       : 가온전선_적송 피킹처리 Migration
*&              => ZGTLER1120 COPY
*&  생성일      : 2026.06.02
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
REPORT  ZGTSDR9064 NO STANDARD PAGE HEADING  MESSAGE-ID ZLE1.

INCLUDE ZGTSDR9064TOP.
*INCLUDE ZGTLER1120TOP.
INCLUDE ZGTSDR9064SEL.
*INCLUDE ZGTLER1120SEL.
INCLUDE ZGTSDR9064O01.
*INCLUDE ZGTLER1120O01.
INCLUDE ZGTSDR9064I01.
*INCLUDE ZGTLER1120I01.
INCLUDE ZGTSDR9064F01.
*INCLUDE ZGTLER1120F01.
INCLUDE ZGTSDR9064F02.
*INCLUDE ZGTLER1120F02.


*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM INITIALIZATION.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN.                                             *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  "권한CHECK
  PERFORM AUTHORITY_CHECK.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN OUTPUT.                                      *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM GET_FIELD_TEXT .
  PERFORM SELECTION_SCREEN_MODIFY.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VSTEL-LOW.
  PERFORM F4_VSTEL USING 'S_VSTEL-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_LGORT-LOW.
  PERFORM F4_LGORT USING 'S_LGORT-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VTWEG-LOW.
  PERFORM F4_VTWEG USING 'S_VTWEG-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_SPART-LOW.
  PERFORM F4_SPART USING 'S_SPART-LOW'.


*----------------------------------------------------------------------*
*     START-OF-SELECTION                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  CLEAR: GT_LIKP[], GT_LIKP, R_VBELN[], R_VBELN.
  PERFORM DATA_QUERY TABLES GT_LIKP R_VBELN.
  IF GT_LIKP[] IS INITIAL.
    MESSAGE S000 WITH '해당하는 데이타가 존재하지 않습니다'.
  ELSE.
    CALL SCREEN 100.
  ENDIF.
