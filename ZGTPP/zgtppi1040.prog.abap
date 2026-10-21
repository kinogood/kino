*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPI1040
*& 프로그램 명 : [GT] 코드마스터(Key Data) 송신 2025.12.08 by ZGSIDEV07
*& 개요   : ERP 내에서 관리되는 코드 마스터(e.g. ERP 플랜트, ERP 저장위치 등)를 MES에 전송하는 기능
*& 생성일 : 2025.12.08
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
REPORT ZGTPPI1040 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPI1040TOP.
INCLUDE ZGTPPI1040S01.
INCLUDE ZGTPPI1040C01.
INCLUDE ZGTPPI1040I01.
INCLUDE ZGTPPI1040O01.
INCLUDE ZGTPPI1040F01.

INITIALIZATION.
  PERFORM INITIALIZATION.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_TARGET.
  PERFORM F4_TARGET USING 'P_TARGET'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_OBGTY-LOW.
  PERFORM F4_OBJCT_TYPE USING 'S_OBGTY-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_OBGTY-HIGH.
  PERFORM F4_OBJCT_TYPE USING 'S_OBGTY-HIGH'.

START-OF-SELECTION.
  PERFORM CHK_VALIDATION_P_TARGET.
  PERFORM CHK_VALIDATION_S_OBGTY.
  PERFORM GET_PROC.
  PERFORM PROCESSING.
