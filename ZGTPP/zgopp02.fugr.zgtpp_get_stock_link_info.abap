FUNCTION zgtpp_get_stock_link_info .
*"--------------------------------------------------------------------
*"*"로컬인터페이스:
*"  IMPORTING
*"     REFERENCE(I_WERKS) TYPE  WERKS_D
*"     REFERENCE(I_LGORT) TYPE  LGORT_D
*"     REFERENCE(IT_MATNR) TYPE  RANGE_T_MATNR
*"     VALUE(I_CHARG) TYPE  CHARG_D OPTIONAL
*"     VALUE(I_VBELN) TYPE  VBELN_VA OPTIONAL
*"     VALUE(I_POSNR) TYPE  POSNR_VA OPTIONAL
*"  TABLES
*"      OT_LINK_DETAIL STRUCTURE  ZGTPPS1005 OPTIONAL
*"      OT_LINK_STOCK STRUCTURE  ZGTPPS1006 OPTIONAL
*"--------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_GET_STOCK_LINK_INFO
*& 프로그램 명 : [GT] 주문 할당 정보 조회
*& 개요   :
*& 생성일 : 2026.01.14
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
  DATA ls_import TYPE ty_s_import_para.

  IF i_werks IS INITIAL OR i_lgort IS INITIAL.
    RETURN.
  ENDIF.

*// Import Parameter 설정.
  PERFORM set_import_parameter USING i_werks i_lgort it_matnr
                                     i_charg i_vbeln i_posnr ls_import.

*// 주문할당 정보.
  PERFORM get_order_allocation USING ot_link_detail[] ls_import.

*// 재고.
  PERFORM get_material_stock USING ot_link_stock[] ot_link_detail[] ls_import.

ENDFUNCTION.
