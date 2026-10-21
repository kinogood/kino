FUNCTION zgtpp_link_info_update .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_WERKS) TYPE  WERKS_D
*"     REFERENCE(I_UPD_TYPE) TYPE  ZGTEUPD_TYPE
*"     REFERENCE(I_UPDRQ) TYPE  ZGTPPT3360-UPDRQ OPTIONAL
*"  TABLES
*"      IT_ITEM STRUCTURE  ZGTPPSIF0044
*"      OT_RETURN STRUCTURE  ZGTPPSIF0045 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_LINK_INFO_UPDATE
*& 프로그램 명 : [GT] Link 정보 업데이트 처리
*& 개요   :
*& 생성일 : 2026.02.02
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

  PERFORM set_import_para_link_info USING i_werks i_upd_type i_updrq.

*// Inport Parameter 점검.
  PERFORM check_parameters_link_info_upd TABLES it_item ot_return.

  IF line_exists( ot_return[ chk_stat = zgtpp_if_const=>gc_result-error ] ).
    RETURN.
  ENDIF.

*// Link Info Update.
  PERFORM link_info_update TABLES it_item ot_return.

ENDFUNCTION.
