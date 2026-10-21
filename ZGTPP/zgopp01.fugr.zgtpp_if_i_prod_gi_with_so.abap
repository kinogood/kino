FUNCTION zgtpp_if_i_prod_gi_with_so.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MODE) TYPE  CHAR02
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ISSUE STRUCTURE  ZGTPPSIF0049
*"      OT_RESULT STRUCTURE  ZGTPPSIF0050 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_PROD_GI_WITH_SO
*& 프로그램 명 : [GT] SO 참조 자재투입 수신
*& 개요   : MES에서 입력된 SO 참조 자재투입 정보를 ERP에 수신 받아
*          테이블에 저장 후 자재투입을 처리하는 기능
*& 생성일 : 2026.02.23
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
      PERFORM check_para_prod_gi_result USING i_mode i_system_id zo_result zo_message
                                              it_issue[] ot_result[].

      PERFORM save_prod_gi_result.

    CATCH lcx_exception INTO DATA(lr_exception).
      zo_result  = zgtpp_if_const=>gc_if_rec_result-eai_error.
      zo_message = lr_exception->get_text( ).
      RETURN.
  ENDTRY.

*// 모드(P: 투입처리, C: 투입취소)에 따른 분기.
  CASE i_mode.
    WHEN 'P'. "// 투입처리.
      PERFORM processing_prod_gi_results USING ot_result[].

    WHEN 'C'. "// 투입취소.
      PERFORM canceling_prod_gi_results USING ot_result[].
  ENDCASE.

ENDFUNCTION.
