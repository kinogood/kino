FUNCTION zgtpp_if_i_mat_req_from_prod.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"     VALUE(IS_HEADER)   TYPE  ZGTPPSIF0051
*"  EXPORTING
*"     VALUE(ZO_RESULT)  TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ITEM STRUCTURE  ZGTPPSIF0052
*"      OT_RESULT STRUCTURE  ZGTPPSIF0053 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_MAT_REQ_FROM_PROD
*& 프로그램 명 : [GT] 자재 요청 정보 수신
*& 개요   : MES에서 입력된 자재 요청 결과를 ERP에 수신 받아 테이블에
*           저장 후 예약(Reservation)을 생성하는 기능
*& 생성일 : 2026.02.27
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

*// 수신데이터 점검 및 저장.
  TRY.
      PERFORM check_para_mat_req USING i_system_id is_header zo_result zo_message it_item[].
      PERFORM save_mat_req_from_prod.

    CATCH lcx_exception INTO DATA(lr_exception).
      zo_result  = zgtpp_if_const=>gc_if_rec_result-eai_error.
      zo_message = lr_exception->get_text( ).
      RETURN.
  ENDTRY.

*// Reservation 생성/변경/삭제 처리.
  CASE is_header-zreq_mode.
    WHEN 'N'. "// 생성.
      PERFORM create_reservation TABLES ot_result[].

    WHEN 'C'. "// 변경.
      PERFORM change_reservation TABLES ot_result[].

    WHEN 'D'. "// 삭제.
      PERFORM delete_reservation TABLES ot_result[].
  ENDCASE.

ENDFUNCTION.
