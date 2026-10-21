FUNCTION zgtpp_if_i_prod_bom_ch.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(SYSTEM_ID) TYPE  CHAR4
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ORDER_BOM STRUCTURE  ZGTPPSIF0033 OPTIONAL
*"      OT_RESULT STRUCTURE  ZGTPPSIF0034 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_PROD_BOM_CH
*& 프로그램 명 : [GT] 생산오더 대체자재변경 수신
*& 개요   :
*& 생성일 : 2025.04.23
*& 생성자 : ZGSIDEV04
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : MOM에서 생산오더 작업일정 수립,
*&                            릴리즈 시점에 대체자재 변경할때 수행한다.
*&                           대체자재 변경은 MOM에서 I/F 받은
*&                           기준으로 BDC 처리한다
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*

*// SYSTEM ID에 따라 처리 함수를 달리 호출

  IF system_id EQ 'KPCM' OR "// 지중 MES
     system_id EQ 'KSCM' OR "// 소재 MOM SRM2510-04825
     system_id EQ 'KFCM' .  "한미소 MOM 260902

    CALL FUNCTION 'ZGTPP_IF_I_CABLE_PROD_BOM_CH'
      EXPORTING
        system_id    = system_id
      IMPORTING
        zo_result    = zo_result
        zo_message   = zo_message
      TABLES
        it_order_bom = it_order_bom
        ot_result    = ot_result.

  ELSEIF system_id EQ 'KGPM' OR  "// 가온전선.
         system_id EQ 'KGOM'.

    CALL FUNCTION 'ZGTPP_IF_I_GAON_PROD_BOM_CH'
      EXPORTING
        system_id    = system_id
      IMPORTING
        zo_result    = zo_result
        zo_message   = zo_message
      TABLES
        it_order_bom = it_order_bom
        ot_result    = ot_result.
  ENDIF.

ENDFUNCTION.
