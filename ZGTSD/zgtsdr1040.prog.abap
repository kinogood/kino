*&---------------------------------------------------------------------*
*& Report ZGTSDR1040
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*​
*& 모듈        : SD.
*& 프로그램 ID : ZGTSDR1040
*& 프로그램 명 : [GT] 소재 OEM/직판 매출 정산.
*& 개요   :
*& 생성일 : 2026.04.01.​
*& 생성자 : ZGODEV05.
*&---------------------------------------------------------------------*​
*& 외부 호출 프로그램 개요   :
*& 타 시스템 인터페이스 개요 : ​
*&---------------------------------------------------------------------*​
*& 프로그램 수정이력​
*&---------------------------------------------------------------------*​
*& 수정일  :​ 2026.04.01.
*& 수정자  :​ ZGODEV05.
*& 수정개요: Create.
*&---------------------------------------------------------------------*

REPORT zgtsdr1040  MESSAGE-ID zgtsd01.

INCLUDE zgtsdr1040c01.
INCLUDE zgtsdr1040top.    " Top.
INCLUDE zgtsdr1040alv.
INCLUDE zgtsdr1040sel.    " Selection-Screen.
INCLUDE zgtsdr1040f01.
INCLUDE zgtsdr1040o01.
INCLUDE zgtsdr1040i01.


*&---------------------------------------------------------------------*
*& INITIALIZATION.
*&---------------------------------------------------------------------*
INITIALIZATION.
  PERFORM initialization.

*&---------------------------------------------------------------------*
*& AT SELECTION-SCREEN.
*&---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON s_spmon.
*  PERFORM at_user_command.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT.
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM modify_screen_1000.

*&---------------------------------------------------------------------*
*& AT SELECTION-SCREEN ON VALUE-REQUEST.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_spmon-low.
  PERFORM f4_spmon  CHANGING s_spmon-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_vkbur-low.
  PERFORM f4_vkbur  CHANGING s_vkbur-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_vkgrp-low.
  PERFORM f4_vkgrp  CHANGING s_vkgrp-low.

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
