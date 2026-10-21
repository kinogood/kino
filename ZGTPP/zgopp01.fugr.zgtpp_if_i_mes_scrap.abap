FUNCTION ZGTPP_IF_I_MES_SCRAP.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MODE) TYPE  CHAR02
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ITEM STRUCTURE  ZGTPPSIF0067
*"      OT_RESULT STRUCTURE  ZGTPPSIF0068 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_MES_SCRAP
*& 프로그램 명 : [GT] MES 연계 스크랩 처리
*& 개요   : MES에서 수신받은 "잔량, 예압, 절단, 재고실사, 불량선별"
*&          기반으로, 스크랩 처리하여 MES에 리턴 전송한다
*&          1) 잔량 : 투입된 Lot의 생산오더 N건에 스크랩 배부 처리한다
*&          2) 예압 : 예압 발생한 Lot의 생산오더 1건에 스크랩 처리한다
*&          3) 절단 : 절단으로 발생한 스크랩을 CO오더로 처리한다
*&                    단, GO의 경우 937 처리만 한다.
*& 생성일 : 2026.05.07
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
*// 수신데이터 점검 및 저장.
      PERFORM CHECK_PARA_SCRAP USING I_MODE    I_SYSTEM_ID
                                     ZO_RESULT ZO_MESSAGE
                                     IT_ITEM[] OT_RESULT[].

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      ZO_RESULT  = ZGTPP_IF_CONST=>GC_IF_REC_RESULT-EAI_ERROR.
      ZO_MESSAGE = LR_EXCEPTION->GET_TEXT( ).
      RETURN.
  ENDTRY.

**// 모드(R:잔량, P:예압, T:절단, A:재고실사, S:불량선별,
**        C/TC/AC/SC:취소)에 따른 분기.
  CASE I_MODE.
    WHEN 'R' OR 'P'.   "// R:잔량, P:예압
      PERFORM PROCESSING_SCRAP USING I_MODE OT_RESULT[].

    WHEN 'A'.          "// A:재고실사
      PERFORM PROCESSING_SCRAP_A USING I_MODE OT_RESULT[].

    WHEN 'T' OR 'S'.   "// T:절단, S:불량선별
      PERFORM PROCESSING_SCRAP_T USING I_MODE OT_RESULT[].

    WHEN 'C'.          "// 취소(잔량, 예압)
      PERFORM CANCELING_SCRAP USING I_MODE OT_RESULT[].

    WHEN 'AC'.         "// 취소(재고실사)
      PERFORM CANCELING_SCRAP_AC USING I_MODE OT_RESULT[].

    WHEN 'TC' OR 'SC'. "// 취소(절단/불량선별)
      PERFORM CANCELING_SCRAP_TC USING I_MODE OT_RESULT[].
  ENDCASE.


ENDFUNCTION.
