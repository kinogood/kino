FUNCTION zgtpp_if_i_qc_usage_decsion.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MODE) TYPE  CHAR02
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ITEM STRUCTURE  ZGTPPSIF0061
*"      OT_RESULT STRUCTURE  ZGTPPSIF0062 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_QC_USAGE_DECSION
*& 프로그램 명 : [GT] 품질검사 합부 판정
*& 개요   : MES에서 수신받은 "재고-품질검사 합/부판정" 기반으로,
*&          ERP의 재고 가용창고/부적합 창고 이동 및
*&          검사여장 스크랩 처리하여 MES에 리턴 전송한다
*& 생성일 : 2026.04.13
*& 생성자 : ZGODEV03
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
      PERFORM check_para_qc_usage_decsion USING i_mode    i_system_id
                                                zo_result zo_message
                                                it_item[] ot_result[].

    CATCH lcx_exception INTO DATA(lr_exception).
      zo_result  = zgtpp_if_const=>gc_if_rec_result-eai_error.
      zo_message = lr_exception->get_text( ).
      RETURN.
  ENDTRY.

*// 모드(P/R/N :품질검사합부처리, C: 품질검사합부처리취소)에 따른 분기.
  CASE i_mode.
    WHEN 'P' OR 'R' OR 'N'. "// 품질검사 합부 처리
      PERFORM processing_qc_usage_decsion USING i_mode ot_result[].

    WHEN 'C'.        "// 품질검사 합부 취소 처리.
      PERFORM canceling_qc_usage_decsion USING i_mode ot_result[].
  ENDCASE.

ENDFUNCTION.
