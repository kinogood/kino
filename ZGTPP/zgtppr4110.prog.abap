*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR4110
*& 프로그램 명 : [GT] 팩터배치 개별조장 특성업데이트 GAON 2026.08.06 by ZGSIDEV07
*& 개요   : 랜 완제품 팩터배치 특성 Update Program
*& 생성일 : 2026.08.06
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
REPORT ZGTPPR4110 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR4110TOP.
INCLUDE ZGTPPR4110S01.
INCLUDE ZGTPPR4110F01.

AT SELECTION-SCREEN OUTPUT.
  PERFORM GET_PARAMETER_DESCRIPTION.
  PERFORM MODIFY_FIRST_SCREEN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_GONGCD-LOW.
  PERFORM F4_GONG_CD USING 'S_GONGCD-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_GONGCD-HIGH.
  PERFORM F4_GONG_CD USING 'S_GONGCD-HIGH'.

START-OF-SELECTION.
  PERFORM GET_PROC.
  PERFORM PROC_DISP.
