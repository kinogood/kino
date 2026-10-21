*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR4030
*& 프로그램 명 : [BD] 생산오더 실적현황 2025.02.17 by ZGSIDEV07
*& 개요   : 시리얼별, 생산오더별, 공정별, 제조지시별로
*              생산실적(Confirmation) 및 생산입고(GR) 현황을 조회하는 기능임
*& 생성일 : 2025.02.17
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
REPORT ZGTPPR4030 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR4030TOP.
INCLUDE ZGTPPR4030S01.
INCLUDE ZGTPPR4030C01.
INCLUDE ZGTPPR4030O01.
INCLUDE ZGTPPR4030I01.
INCLUDE ZGTPPR4030F01.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_FIRST_SCREEN.

*- 레이아웃 탐색도움말
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_LAY.
  PERFORM SELECT_ALV_VARIANT CHANGING P_LAY.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_GONG-LOW.
  PERFORM F4_GONG_CD USING S_GONG-LOW.

START-OF-SELECTION.
  PERFORM CHK_COCKPIT.
  PERFORM AUTHORITY_CHECKING_PROC.
  PERFORM GET_PROC.
  PERFORM PROC_DISP.
