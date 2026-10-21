*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR4120
*& 프로그램 명 : [GT] WIP 오더관리 GAON 2026.08.28 by ZGSIDEV07
*& 개요   : 월 마감 시 WIP 생산 오더를 확인하고 실적을 이월하는 프로그램
*& 생성일 : 2026.08.28
*& 생성자 : ZGSIDEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 2026.10.02 ZGSIDEV07  해당월 처리대상 없을시 실적재처리시 오더 상태 'W' -> 'P' 변경
*&---------------------------------------------------------------------*
REPORT ZGTPPR4120  MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR4120TOP.
INCLUDE ZGTPPR4120S01.
INCLUDE ZGTPPR4120C01.
INCLUDE ZGTPPR4120F01.
INCLUDE ZGTPPR4120O01.
INCLUDE ZGTPPR4120I01.

AT SELECTION-SCREEN OUTPUT.
  PERFORM GET_PARAMETER_DESCRIPTION.
  PERFORM MODIFY_FIRST_SCREEN.

START-OF-SELECTION.
  PERFORM INPUT_CHECK.
  PERFORM AUTHORITY_CHECKING_PROC.
  PERFORM PROC_GET_DATA.
  PERFORM PROC_DISP.
