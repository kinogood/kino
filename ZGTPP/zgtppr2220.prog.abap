*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2220
*& 프로그램 명 : [GT] RCCP 작업장별 LOAD 분석 GAON 2026.08.26 by ZGSIDEV07
*& 개요   : 작번 기준으로 설비 변경 후 품목별/작업장별 소요일수 재계산 및 분석 기능
* - 투입일자 및 완료일자를 분 단위로 계산하여 표기
* - 절연 이후 단 데이터 산출 확정 후 연선 RCCP 데이터 산출 수행
* - 그룹화 및 오버랩 설정 후 분석 및 Load Balancing 수행
*& 생성일 : 2026.08.26
*& 생성자 : ZGSIDEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
REPORT ZGTPPR2220 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR2220TOP.
INCLUDE ZGTPPR2220S01.
INCLUDE ZGTPPR2220C01.
INCLUDE ZGTPPR2220F01.
INCLUDE ZGTPPR2220O01.
INCLUDE ZGTPPR2220I01.

AT SELECTION-SCREEN OUTPUT.
  PERFORM GET_PARAMETER_DESCRIPTION.
  PERFORM MODIFY_FIRST_SCREEN.

START-OF-SELECTION.
  PERFORM AUTHORITY_CHECKING_PROC.
  PERFORM GET_PROC.
  PERFORM PROC_DISP.
