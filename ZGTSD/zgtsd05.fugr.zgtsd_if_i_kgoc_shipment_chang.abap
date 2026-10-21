FUNCTION zgtsd_if_i_kgoc_shipment_chang.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTETARGET
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_DATA STRUCTURE  ZGTSDSIF2140 OPTIONAL
*"      ET_RESULT STRUCTURE  ZGTSDSIF2141 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*​
*& 모듈        : SD
*& 프로그램 ID : ZGTSD_IF_I_KGOC_SHIPMENT_CHANG
*& 프로그램 명 : [GO] One Pick 상차계획 정보 입력 (Shipment 변경)
*& 개요   :
*& 생성일 : 2026.03.06.​
*& 생성자 : ZGODEV05
*&---------------------------------------------------------------------*​
*& 외부 호출 프로그램 개요   :
*& 타 시스템 인터페이스 개요 : ​
*&---------------------------------------------------------------------*​
*& 프로그램 수정이력​
*&---------------------------------------------------------------------*​
*& 수정일  :​
*& 수정자  :​
*& 수정개요:
*&---------------------------------------------------------------------*

  DATA: ls_info TYPE zgtsdt9000.

  CONSTANTS: lc_fname  TYPE rs38l_fnam  VALUE 'ZGTSD_IF_I_KGOC_SHIPMENT_CHANG'.

**
  CLEAR: ls_info,
         zo_result, zo_message.
  cls: et_result.

* 1) IF log info.
  PERFORM shipment_chg_if_log_info_go         TABLES   it_data
                                                       et_result
                                              USING    'X'
                                                       ls_info
                                                       i_system_id
                                                       lc_fname
                                              CHANGING zo_result
                                                       zo_message.

* 2) Shipment Change
  PERFORM shipment_data_change_go             TABLES   it_data
                                                       et_result
                                              CHANGING zo_result
                                                       zo_message.

* 1) Result log save
  PERFORM shipment_chg_if_log_info_go         TABLES   it_data
                                                       et_result
                                              USING    ' '
                                                       ls_info
                                                       i_system_id
                                                       lc_fname
                                              CHANGING zo_result
                                                       zo_message.

**

ENDFUNCTION.
