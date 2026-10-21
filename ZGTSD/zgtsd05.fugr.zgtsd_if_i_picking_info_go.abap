FUNCTION zgtsd_if_i_picking_info_go.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(SYSTEM_ID) TYPE  CHAR04 OPTIONAL
*"     VALUE(P_STAMP) TYPE  TZNTSTMPL OPTIONAL
*"     VALUE(P_MODE) TYPE  MODE OPTIONAL
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE2
*"  TABLES
*"      IT_ITAB_H STRUCTURE  ZGTSDSIF0020 OPTIONAL
*"      IT_ITAB_I STRUCTURE  ZGTSDSIF0021 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*​
*& 모듈        : SD
*& 프로그램 ID : ZGTSD_IF_I_PICKING_INFO_GO
*& 프로그램 명 : [GT_GO] 피킹/출고전기/출고취소 수신
*& 개요   :
*& 생성일 : 2026.04.03.​
*& 생성자 : ZGODEV05
*&---------------------------------------------------------------------*​
*& 외부 호출 프로그램 개요   :
*& 타 시스템 인터페이스 개요 : ​
*&---------------------------------------------------------------------*​
*& 프로그램 수정이력​
*&---------------------------------------------------------------------*​
*& 수정일  :​
*& 수정자  :​
*& 수정개요: Copy ZGTSD_IF_I_PICKING_INFO
*&---------------------------------------------------------------------*

*___ STATUS
  CLEAR : gv_error, gv_message.
  GET TIME STAMP FIELD gv_stamp.
  gv_erdat = sy-datum.
  gv_erzet = sy-uzeit.
  IF p_mode IS INITIAL.
    gv_mode = 'N'.
  ELSE.
    gv_mode = p_mode.
  ENDIF.

*___ LOG SAVE
  PERFORM save_log_go         TABLES it_itab_h
                                     it_itab_i
                              USING  'S'
                                     system_id
                                     p_stamp.

*___ DATA CHECK.
  PERFORM data_check_go       TABLES it_itab_h
                                     it_itab_i.

*___ DATA PROCESSING.
  PERFORM data_processing_go  TABLES it_itab_h
                                     it_itab_i.

*___ LOG SAVE
  PERFORM save_log_go         TABLES it_itab_h
                                     it_itab_i
                              USING  'E'
                                     system_id
                                     p_stamp.

*___ RESULT RETURN
  zo_result = gv_result.
  zo_message = gv_message.

**

ENDFUNCTION.
