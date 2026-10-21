FUNCTION zgtpp_if_i_stock_transfer.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MODE) TYPE  CHAR02
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_TR STRUCTURE  ZGTPPSIF0056
*"      OT_RESULT STRUCTURE  ZGTPPSIF0057 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_STOCK_TRANSFER
*& 프로그램 명 : [GT] 재고 이전전기 수신
*& 개요   : MES에서 입력된 재고 이전전기(신선 잔권 처리 등) 정보를
*           ERP에 수신 받아 테이블에 저장 후 재고 이동 처리를 수행하는 기능
*          (창고간, 배치간 이전전기)
*& 생성일 : 2026.03.16
*& 생성자 : ZGODEV06
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

  TRY.
*// 수신데이터 점검 및 저장.
      PERFORM check_para_stock_transfer USING i_mode    i_system_id
                                              zo_result zo_message
                                              it_tr[]   ot_result[].

      PERFORM save_stock_transfer.

    CATCH lcx_exception INTO DATA(lr_exception).
      zo_result  = zgtpp_if_const=>gc_if_rec_result-eai_error.
      zo_message = lr_exception->get_text( ).
      RETURN.
  ENDTRY.

*// 모드(P:이전전기처리, C: 이전전기취소)에 따른 분기.
  CASE i_mode.
    WHEN 'P'. "// 이전전기처리.
      PERFORM processing_stock_transfer USING ot_result[].

    WHEN 'C'. "// 이전전기취소.
      PERFORM canceling_stock_transfer USING ot_result[].
  ENDCASE.

ENDFUNCTION.
