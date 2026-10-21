FUNCTION zgtpp_if_i_prod_gi.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MODE) TYPE  CHAR02
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ISSUE STRUCTURE  ZGTPPSIF0017
*"      OT_RESULT STRUCTURE  ZGTPPSIF0016
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_PROD_GI
*& 프로그램 명 : [GT] 생산오더 자재투입[ERP <- 지중/부스닥트 MES]
*& 개요   :
*& 생성일 : 2024.11.26
*& 생성자 : ZGSIDEV06
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : 지중/부스닥트 MES
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*

*// SYSTEM ID에 따라 처리 함수를 달리 호출
  IF i_system_id = 'KPCM' OR  "지중 MES
     i_system_id = 'KSCM' OR  "소재 MOM SRM2510-04825
     i_system_id = 'KFCM'.    "한미소 MOM 20260902

    CALL FUNCTION 'ZGTPP_IF_I_CABLE_PROD_GI'
      EXPORTING
        i_mode      = i_mode
        i_system_id = i_system_id
      IMPORTING
        zo_result   = zo_result
        zo_message  = zo_message
      TABLES
        it_issue    = it_issue
        ot_result   = ot_result.

  ELSEIF i_system_id = 'KBDM'. "부스닥트 MES

    CALL FUNCTION 'ZGTPP_IF_I_BD_PROD_GI'
      EXPORTING
        i_mode      = i_mode
        i_system_id = i_system_id
      IMPORTING
        zo_result   = zo_result
        zo_message  = zo_message
      TABLES
        it_issue    = it_issue
        ot_result   = ot_result.

  ELSEIF i_system_id = 'KGPM' OR   "// 가온전선 MES.
         i_system_id = 'KGOM'.

    CALL FUNCTION 'ZGTPP_IF_I_GAON_PROD_GI'
      EXPORTING
        i_mode      = i_mode
        i_system_id = i_system_id
      IMPORTING
        zo_result   = zo_result
        zo_message  = zo_message
      TABLES
        it_issue    = it_issue
        ot_result   = ot_result.
  ENDIF.

ENDFUNCTION.
