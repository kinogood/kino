FUNCTION zgtpp_if_i_wo_create.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MODE) TYPE  CHAR02
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ORDER STRUCTURE  ZGTPPSIF0054
*"      OT_RESULT STRUCTURE  ZGTPPSIF0055 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_WO_CREATE
*& 프로그램 명 : [GT] 생산오더 생성 요청
*& 개요   : MES에서 수신받은 I/F "작업지시 생성 요청" 데이터를 기반으로,
*           ERP의 생산오더를 생성 혹은 삭제 처리하여 MES에 리턴 전송한다
*& 생성일 : 2026.03.09
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
      PERFORM check_para_wo_create USING i_mode i_system_id zo_result zo_message
                                         it_order[] ot_result[].

*// 수신데이터 저장.
      PERFORM save_wo_create.

    CATCH lcx_exception INTO DATA(lr_exception).
      zo_result  = COND #( WHEN lr_exception->get_text( ) IS NOT INITIAL THEN zgtpp_if_const=>gc_if_rec_result-eai_error ).
      zo_message = lr_exception->get_text( ).
      RETURN.
  ENDTRY.

  CHECK ot_result[] IS INITIAL.

*// 처리 모드(C: 생성, D: 삭제)에 따른 분기.
  CASE i_mode.
    WHEN 'C'. "// 생성.
      PERFORM create_work_order USING ot_result[].

    WHEN 'D'. "// 삭제.
      PERFORM delete_work_order USING ot_result[].
  ENDCASE.

ENDFUNCTION.
