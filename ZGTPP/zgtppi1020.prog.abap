*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPI1020
*& 프로그램 명 : [GT] 라우팅 정보 송신 2024.10.25 by ZGSIDEV07
*& 개요   : Routing 정보를 MES 시스템으로 송신하는 기능
*& 생성일 : 2024.10.25
*& 생성자 : ZGSIDEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*  NO     DATE       AUTHORS              DESCRIPTION
*----------------------------------------------------------------------*
* U01  2026.06.12  ZGODEV03    가온전선 MES(KGPM)이고
*                              작업장이 건조(DRY)일 경우
*                              USR06 건조가동시간을 VGW02에 대입 추가
*&---------------------------------------------------------------------*
REPORT zgtppi1020 MESSAGE-ID zgtpp00.

INCLUDE zgtppi1020top.
INCLUDE zgtppi1020s01.
INCLUDE zgtppi1020c01.
INCLUDE zgtppi1020i01.
INCLUDE zgtppi1020o01.
INCLUDE zgtppi1020f01.

AT SELECTION-SCREEN OUTPUT.
  PERFORM modify_first_screen.

START-OF-SELECTION.
  PERFORM get_proc.
  PERFORM processing.
