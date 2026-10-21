FUNCTION ZGTSD_IF_O_SALESORDER_INFO.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      OT_TAB_H STRUCTURE  ZGTSDSIF0002
*"      OT_TAB_I STRUCTURE  ZGTSDSIF0003
*"      OT_TAB_C STRUCTURE  ZGTSDSIF0004
*"      OT_TAB_P STRUCTURE  ZGTSDSIF0005
*"      OT_TAB_D STRUCTURE  ZGTSDSIF0095 OPTIONAL
*"  EXCEPTIONS
*"      SYSTEM_FAILURE
*"      COMMUNICATION_FAILURE
*"      ILLEGALNAME
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSD_IF_O_DELIVERYORDER_INFO
*& 프로그램 명 : [GT] S/O 정보 [ERP -> 지중MES]
*& 개요   :
*& 생성일 : 2024.11.28
*& 생성자 : ZGSIDEV05
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : 지중MES]
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*




ENDFUNCTION.
