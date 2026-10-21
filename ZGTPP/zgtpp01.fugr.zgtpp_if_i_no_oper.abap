FUNCTION ZGTPP_IF_I_NO_OPER.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MODE) TYPE  CHAR02
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_OPER STRUCTURE  ZGTPPSIF0024
*"      OT_RESULT STRUCTURE  ZGTPPSIF0025
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_NO_OPER
*& 프로그램 명 : [GT] 비가동 실적 MES 수신[ERP <- 지중/부스닥트 MES]
*& 개요   :
*& 생성일 : 2024.12.02
*& 생성자 : ZGSIDEV08
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
* SYSTEM ID에 따라 처리 함수를 달리 호출
  IF I_SYSTEM_ID = 'KPCM' OR "지중 MES
     I_SYSTEM_ID = 'KSCM' OR "소재 MOM SRM2510-04825
     I_SYSTEM_ID = 'KFCM'.   "한미소 MOM 260902

    CALL FUNCTION 'ZGTPP_IF_I_CABLE_NO_OPER'
      EXPORTING
        I_MODE      = I_MODE
        I_SYSTEM_ID = I_SYSTEM_ID
      IMPORTING
        ZO_RESULT   = ZO_RESULT
        ZO_MESSAGE  = ZO_MESSAGE
      TABLES
        IT_OPER     = IT_OPER
        OT_RESULT   = OT_RESULT.

  ELSEIF I_SYSTEM_ID = 'KBDM'. "부스닥트 MES

*    CALL FUNCTION 'ZGTPP_IF_I_BD_NO_OPER'.

  ENDIF.




ENDFUNCTION.
