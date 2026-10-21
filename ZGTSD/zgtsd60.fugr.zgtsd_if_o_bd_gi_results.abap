FUNCTION zgtsd_if_o_bd_gi_results.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTETARGET
*"     VALUE(IS_GI) LIKE  ZGTSDSIF0082 STRUCTURE  ZGTSDSIF0082
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      OT_VEKP STRUCTURE  ZGTSDSIF0083 OPTIONAL
*"      OT_VEPO STRUCTURE  ZGTSDSIF0104 OPTIONAL
*"  EXCEPTIONS
*"      SYSTEM_FAILURE
*"      COMMUNICATION_FAILURE
*"      ILLEGALNAME
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSD_IF_O_BD_GI_RESULTS
*& 프로그램 명 : [BD] 제상품 출하정보 Interface
*& 개요   :
*& 생성일 : 2025.02.26
*& 생성자 : ZGSISD04
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


ENDFUNCTION.
