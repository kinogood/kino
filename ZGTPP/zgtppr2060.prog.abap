*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2060
*& 프로그램 명 : [GT] 월간계획(판매계획선정) 2025.04.17 by ZGSIDEV07
*& 개요   : 월간 생산 계획(절연)을 수립하기 위한 판매계획 대상을 선정하고
*              판매 계획 추진 상태에 따라 미흡한 정보를 사용자(계획자)가 입력하여
*              생산 계획 수립을 준비하는 프로그램
*& 생성일 : 2025.04.17
*& 생성자 : ZGSIDEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
* 2026.02.02  zlsgpp5   CHM2601-00657 지중 생산계획관련 기능개선 요청 件
* 2026.02.12  이정익     SRM2602-06064  판매계획 조회조건에 제품군 추가
*&---------------------------------------------------------------------*
REPORT zgtppr2060 MESSAGE-ID zgtpp00.

INCLUDE zgtppr2060top.
INCLUDE zgtppr2060s01.
INCLUDE zgtppr2060c01.
INCLUDE zgtppr2060f01.
INCLUDE zgtppr2060o01.
INCLUDE zgtppr2060i01.

AT SELECTION-SCREEN OUTPUT.
  PERFORM set_selection_period.
  PERFORM get_parameter_description.
  PERFORM modify_first_screen.

START-OF-SELECTION.
  PERFORM authority_checking_proc.
  PERFORM get_process.
  PERFORM disp_process.
