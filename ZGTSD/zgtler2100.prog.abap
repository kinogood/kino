*&---------------------------------------------------------------------*
*& Report ZGTLER2100
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*​
*& 모듈        : SD.
*& 프로그램 ID : ZGTLER2100.
*& 프로그램 명 : [GO] 보관 입고 처리
*& 개요   :
*& 생성일 : 2026.02.25.​
*& 생성자 : ZGODEV05.
*&---------------------------------------------------------------------*​
*& 외부 호출 프로그램 개요   :
*& 타 시스템 인터페이스 개요 : ​
*&---------------------------------------------------------------------*​
*& 프로그램 수정이력​
*&---------------------------------------------------------------------*​
*& 수정일  :​ 2026.02.25.
*& 수정자  :​ ZGODEV05.
*& 수정개요: Create. ( copy ZLER0022 ).
*&---------------------------------------------------------------------*

REPORT zgtler2100  MESSAGE-ID zgtsd01.

*INCLUDE zler_alv.
INCLUDE zler0001top.

INCLUDE zgtler2100c01.
INCLUDE zgtler2100top.    " Top.
INCLUDE zgtler2100sel.    " Selection-Screen.
INCLUDE zgtler2100alv.
INCLUDE zgtler2100f01.
INCLUDE zgtler2100o01.
INCLUDE zgtler2100i01.


*&---------------------------------------------------------------------*
*& INITIALIZATION.
*&---------------------------------------------------------------------*
INITIALIZATION.
  PERFORM initialization.

*&---------------------------------------------------------------------*
*& AT SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
* 권한CHECK
  PERFORM authority_check.

*&---------------------------------------------------------------------*
*& AT SELECTION-SCREEN OUTPUT.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM modify_screen_1000.

*&---------------------------------------------------------------------*
*& AT SELECTION-SCREEN ON VALUE-REQUEST.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR  s_werks-low.
  PERFORM f4_werks  CHANGING s_werks-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR  s_werks-high.
  PERFORM f4_werks  CHANGING s_werks-high.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR  s_vstel-low.
  PERFORM f4_vstel  CHANGING s_vstel-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR  s_vstel-high.
  PERFORM f4_vstel  CHANGING s_vstel-high.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION.
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM start_process.

*&---------------------------------------------------------------------*
*& END-OF-SELECTION.
*&---------------------------------------------------------------------*
END-OF-SELECTION.
  PERFORM end_process.
