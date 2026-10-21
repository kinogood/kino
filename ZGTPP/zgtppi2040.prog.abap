*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPI2040
*& 프로그램 명 : [GT] 신선작업지시서 송신 GAON 2026.06.26 by ZGSIDEV07
*& 개요   :  조장 구성표에 연계된 연선과 연선 Cage별 투입 신선 연결 정보를 전송하는 I/F 프로그램
*                - 신선 작업을 위한 소선 정보도 같이 전송하여 현장 신선 작업 지시서를 출력 할 수 있도록 함
*& 생성일 : 2026.06.26
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
REPORT ZGTPPI2040   MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPI2040TOP.
INCLUDE ZGTPPI2040S01.
INCLUDE ZGTPPI2040C01.
INCLUDE ZGTPPI2040F01.
INCLUDE ZGTPPI2040O01.
INCLUDE ZGTPPI2040I01.

INITIALIZATION.
  PERFORM INITIALIZATION.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_TARGET.
  PERFORM F4_TARGET USING 'P_TARGET'.

START-OF-SELECTION.
  PERFORM GET_PROC.
  PERFORM PROCESSING.
