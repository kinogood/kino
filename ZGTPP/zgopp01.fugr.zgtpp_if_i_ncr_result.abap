FUNCTION zgtpp_if_i_ncr_result.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_QM_NCR STRUCTURE  ZGTPPSIF0066
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_NCR_RESULT
*& 프로그램 명 : [GT] NCR 정보 수신
*& 개요   : MES에서 입력된 NCR 정보를 ERP에 수신 받아 테이블에 저장하는 기능
*& 생성일 : 2026.05.07
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
*// 수신데이터 점검.
      PERFORM check_para_ncr_result USING i_system_id zo_result zo_message
                                          it_qm_ncr[].

*// 수신데이터 저장.
      PERFORM save_ncr_result.

    CATCH lcx_exception INTO DATA(lr_exception).
      zo_result  = zgtpp_if_const=>gc_if_rec_result-eai_error.
      zo_message = lr_exception->get_text( ).
  ENDTRY.

ENDFUNCTION.
