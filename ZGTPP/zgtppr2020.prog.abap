*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2020
*& 프로그램 명 : [GT] 상세작업일정관리 2024.12.17 by ZGSIDEV07
*& 개요   : 조장표에서 생성된 생산 오더를 공정 상황에 맞게 작업장 및 작업 스케줄을 조정하고
*              수립된 일정을 확인하는 프로그램
*               MTS 오더를 생성하고 작업 스케줄을 수립할 수 있는 기능과
*               일정을 Shift 할 수 있는 기능 포함"
*& 생성일 : 2024.12.17
*& 생성자 : ZGSIDEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 2026.07.22 zlsgpp5 SRM2607-09012 재생산오더(RP01) 생성 기능 추가.
*&---------------------------------------------------------------------*

REPORT zgtppr2020 MESSAGE-ID zgtpp00.

INCLUDE zgtppr2020top.
INCLUDE zgtppr2020s01.
INCLUDE zgtppr2020c01.
INCLUDE zgtppr2020o01.
INCLUDE zgtppr2020i01.
INCLUDE zgtppr2020f01.

INITIALIZATION.
  PERFORM set_button.

AT SELECTION-SCREEN OUTPUT.
  PERFORM set_selection_period.
  PERFORM get_parameter_description.
  PERFORM modify_first_screen.

AT SELECTION-SCREEN.
  CASE sy-ucomm.
    WHEN 'FC01'.
      PERFORM call_maintain_view.
  ENDCASE.

START-OF-SELECTION.
  PERFORM authority_checking_proc.
  PERFORM input_check.
  PERFORM get_data.
  PERFORM call_screen.
