*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR3140
*& 프로그램 명 : [GT] Batch_GT IF Log 삭제 2025.08.11 by ZGSIDEV07
*& 개요   : 코드 마스터에 정의된 IF Log Table의 보관 주기 값을 확인하여 삭제 처리한다
*              헤더, 아이템, 디테일 구조의 Log Table의 경우 헤더 데이터의 키 값 기준으로
*              아이템, 디테일 데이터 모두 삭제한다.
*& 생성일 : 2025.08.11
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
REPORT ZGTPPR3140  MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR3140TOP.
INCLUDE ZGTPPR3140S01.
INCLUDE ZGTPPR3140C01.
INCLUDE ZGTPPR3140O01.
INCLUDE ZGTPPR3140I01.
INCLUDE ZGTPPR3140F01.

INITIALIZATION.
  PERFORM INITIALIZATION.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.
  PERFORM GET_PARAMETER_DESCRIPTION.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_KIND.
  PERFORM F4_MODULE_KIND USING 'P_KIND'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_CODE_G.
  PERFORM F4_MODULE_KIND USING 'P_CODE_G'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_IFLIST-LOW.
  PERFORM F4_IF_LIST USING 'S_IFLIST-LOW'.

START-OF-SELECTION.
  PERFORM MAIN_PROC.
