FUNCTION ZGTPP_IF_I_CUT_PROD_RESULT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MODE) TYPE  CHAR02
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"     VALUE(IS_CUT_HEADER) TYPE  ZGTPPSIF0046
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_CUT_ITEM STRUCTURE  ZGTPPSIF0047 OPTIONAL
*"      OT_CUT_RESULT STRUCTURE  ZGTPPSIF0048 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_CUT_PROD_RESULT
*& 프로그램 명 : [GT] 절단 실적 정보 수신
*& 개요   : MES에서 입력된 절단 처리 결과를 ERP에 수신 받아
*          테이블에 저장 후 절단 실적(MILL_CUT)을 처리하는 기능
*& 생성일 : 2026.02.13
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
  DATA LS_ZGTPPT3380 TYPE ZGTPPT3380.

  TRY.
*// Step 1: 수신데이터 점검.
      PERFORM CHECK_PARA_CUT_PROD_RESULT USING IT_CUT_ITEM[] OT_CUT_RESULT[]
                                               IS_CUT_HEADER I_MODE I_SYSTEM_ID
                                               ZO_RESULT ZO_MESSAGE.

*// Step 2: 수신데이터 저장.
      PERFORM SAVE_CUT_PROD_RESULT USING LS_ZGTPPT3380 IT_CUT_ITEM[] IS_CUT_HEADER
                                         I_MODE I_SYSTEM_ID ZO_RESULT ZO_MESSAGE.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      ZO_RESULT  = ZGTPP_IF_CONST=>GC_IF_REC_RESULT-EAI_ERROR.
      ZO_MESSAGE = LR_EXCEPTION->GET_TEXT( ).
      RETURN.
  ENDTRY.

*// Step 3: 절단실적처리 및 절단실적취소
  CASE I_MODE.
    WHEN 'P'. "// 절단실적처리.
      PERFORM PROCESSING_CUTTING_RESULTS USING LS_ZGTPPT3380 IT_CUT_ITEM[] OT_CUT_RESULT[].

    WHEN 'C'. "// 절단실적취소.
      PERFORM CANCELING_CUTTING_RESULTS USING LS_ZGTPPT3380 IT_CUT_ITEM[] OT_CUT_RESULT[].

    WHEN 'T'. "// 절단실적임시저장
      PERFORM SAVE_CUTTING_DATA USING LS_ZGTPPT3380 IT_CUT_ITEM[] OT_CUT_RESULT[].
  ENDCASE.

ENDFUNCTION.
