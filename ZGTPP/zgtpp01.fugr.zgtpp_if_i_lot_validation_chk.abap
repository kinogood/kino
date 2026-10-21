FUNCTION zgtpp_if_i_lot_validation_chk .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ITEM STRUCTURE  ZGTPPSIF0042
*"      OT_RETURN STRUCTURE  ZGTPPSIF0043 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_LOT_VALIDATION_CHK
*& 프로그램 명 : [GT] 출하 LOT 점검 및 리턴
*& 개요   :
*& 생성일 : 2026.01.30
*& 생성자 : ZGODEV06
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 :
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
  DATA lv_werks TYPE t001w-werks.

  TRY.
      PERFORM check_parameter_lot_validation TABLES it_item     ot_return
                                              USING i_system_id lv_werks.

      PERFORM lot_validation_check TABLES ot_return USING lv_werks.

    CATCH lcx_exception INTO DATA(lr_exception).
      zo_result  = zgtpp_if_const=>gc_result-error.
      zo_message = lr_exception->get_text( ).
      RETURN.
  ENDTRY.

  zo_result  = zgtpp_if_const=>gc_result-success.
  zo_message = TEXT-s31.

ENDFUNCTION.
