*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2080
*& 프로그램 명 : [GT] 월간계획(생산계획수립) 2025.04.29 by ZGSIDEV07
*& 개요   : 월간 수립할 판매 계획을 대상으로 월간 생산 계획을 시뮬레이션하고
*               버전별 확인을 통해 월간 생산 계획을 확정하는 프로그램
*               확정된 월간 생산 계획으로 공정별 월 물량을 계산하고 수립한 공정의
*               월 생산 수량에 대한 소요 자재 수량을 등록함
*& 생성일 : 2025.04.29
*& 생성자 : ZGSIDEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 2026.03.23  이정익  SRM2603-10362  판매계획 조회시 CDS view 조회 로직 변경
*& 2026.03.27  이정익  SRM2603-13210  FT 단위는 M로 환산 처리
*& 2026.05.26  zlsgpp5 CHM2605-00421  설비capa를 완제품으로 데이터가
*                                     없을시 BOM 반제품을 찾아서 조회.
*&---------------------------------------------------------------------*
REPORT zgtppr2080 MESSAGE-ID zgtpp00.

INCLUDE zgtppr2080top.
INCLUDE zgtppr2080s01.
INCLUDE zgtppr2080c01.
INCLUDE zgtppr2080f01.
INCLUDE zgtppr2080o01.
INCLUDE zgtppr2080i01.

INITIALIZATION.

AT SELECTION-SCREEN OUTPUT.
  PERFORM modify_first_screen.
  PERFORM get_parameter_description.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_simno.
  PERFORM f4_simno USING 'P_SIMNO'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_simvr.
  PERFORM f4_simno USING 'P_SIMVR'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_arbpl-low.
  PERFORM f4_arbpl USING 'S_ARBPL-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_arbpl-high.
  PERFORM f4_arbpl USING 'S_ARBPL-HIGH'.

START-OF-SELECTION.
  PERFORM authority_checking_proc.
  PERFORM check_obligatory_field.
  PERFORM get_proc.
  PERFORM disp_process.
