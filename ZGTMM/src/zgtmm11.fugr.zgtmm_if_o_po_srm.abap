FUNCTION ZGTMM_IF_O_PO_SRM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      OT_EKKO STRUCTURE  ZGTMMS1003
*"      OT_EKPO STRUCTURE  ZGTMMS1004
*"      OT_BOM STRUCTURE  ZGTMMS1005
*"      OT_CHAR STRUCTURE  ZGTMMS1006
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_O_PO_SRM
*& 프로그램 명 :  구매 오더 정보 전송(SAP -> G-SRM)
*& 개요   : SAP에서 생성된 구매 오더 G-SRM(전자구매시스템)으로 전송하는 RFC
*& 생성일 : 2026.01.05
*& 생성자 : ZGODEV04
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*





ENDFUNCTION.
