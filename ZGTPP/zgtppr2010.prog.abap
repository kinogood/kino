*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2010
*& 프로그램 명 : [GT] 조장 구성표 관리 2024.10.29 by ZGSIDEV07
*& 개요   : 조장구성표 번호에 대한 공정별 조장 구성을 진행하는 프로그램
*              조장 길이 계산을 통한 소요량 계산을 진행하고 생성된 오더간의
*              연결 관계를 관리함
*              초기 생성된 개별 길이 오더들의 여장을 수정할 수 있는 기능,
*              복조장 관리, 생산 오더의 수정 기능 등의 Cable 생산 계획을
*               수립 할 수 있도록 구성된 프로그램
*& 생성일 : 2024.10.29
*& 생성자 : ZGSIDEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 2026.04.14 zlsgpp5 CHM2604-00315 시작업오더(PL01) 추가.
*& 2026.04.15 zlsgpp5 CHM2604-00316 복조장 및 Pegging 제한 해제.
*& 2026.07.28.zlsgpp5 SRM2607-10582 고정 스크랩(각길이) 수정기능 추가.
*&---------------------------------------------------------------------*
REPORT zgtppr2010  MESSAGE-ID zgtpp00.

INCLUDE zgtppr2010top.
INCLUDE zgtppr2010s01.
INCLUDE zgtppr2010c01.
INCLUDE zgtppr2010o01.
INCLUDE zgtppr2010i01.
INCLUDE zgtppr2010f01.

INITIALIZATION.
  PERFORM set_init_title.

AT SELECTION-SCREEN OUTPUT.
  PERFORM get_parameter_description.
  PERFORM modify_first_screen.

START-OF-SELECTION.
  PERFORM authority_checking_proc.
  PERFORM get_proc.
  CALL SCREEN 0100.
