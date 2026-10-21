*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2090
*& 프로그램 명 : [GT] 월간계획(생산계획비교) 2025.06.16 by ZGSIDEV07
*& 개요   : 수립된 월간 생산 계획 시뮬레이션 번호를 버전별로 비교할 수 있는 프로그램
*               일별 및 월별 단위로 수립된 월간계획을 비교할 수 있음
*& 생성일 : 2025.06.16
*& 생성자 : ZGSIDEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  수정자   수정개요
*&---------------------------------------------------------------------*
REPORT zgtppr2090  MESSAGE-ID zgtpp00.

INCLUDE zgtppr2090top.
INCLUDE zgtppr2090s01.
INCLUDE zgtppr2090c01.
INCLUDE zgtppr2090f01.
INCLUDE zgtppr2090o01.
INCLUDE zgtppr2090i01.

INITIALIZATION.
  PERFORM init_screen.

AT SELECTION-SCREEN OUTPUT.
  PERFORM modify_first_screen.
  PERFORM get_parameter_description.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_simno.
  PERFORM f4_simno USING 'P_SIMNO'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_simvr.
  PERFORM f4_simno USING 'P_SIMVR'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_simno2.
  PERFORM f4_simno2 USING 'P_SIMNO2'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_simvr2.
  PERFORM f4_simno2 USING 'P_SIMVR2'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_arbpl-low.
  PERFORM f4_arbpl USING 'S_ARBPL-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_arbpl-high.
  PERFORM f4_arbpl USING 'S_ARBPL-HIGH'.

START-OF-SELECTION.
  PERFORM authority_checking_proc.
  PERFORM check_obligatory_field.
  PERFORM get_proc.
  PERFORM disp_process.
