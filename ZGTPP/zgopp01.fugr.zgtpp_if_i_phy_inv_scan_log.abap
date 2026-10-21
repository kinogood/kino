FUNCTION ZGTPP_IF_I_PHY_INV_SCAN_LOG.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_SCAN STRUCTURE  ZGTPPSIF0073 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_PHY_INV_SCAN_LOG
*& 프로그램 명 : [GT] 재고실사 PDA SCAN 로그 수신
*& 개요   : PDA SCAN 정보를 수신 받아 테이블에 저장하는 기능
*& 생성일 : 2026.09.07
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
*// 수신데이터 점검.
      PERFORM CHECK_PARA_PHY_INV_SCAN_LOG TABLES IT_SCAN[]
                                           USING I_SYSTEM_ID ZO_RESULT ZO_MESSAGE.

*// 수신데이터 저장.
      PERFORM SAVE_PHY_INV_SCAN_LOG.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      ZO_RESULT  = ZGTPP_IF_CONST=>GC_IF_REC_RESULT-EAI_ERROR.
      ZO_MESSAGE = LR_EXCEPTION->GET_TEXT( ).
      RETURN.
  ENDTRY.

ENDFUNCTION.
