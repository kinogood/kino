FUNCTION ZGTSD_EXITCONT_PRICE_CALC.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_NETPR) TYPE  NETWR_AP OPTIONAL
*"     REFERENCE(I_AMT) TYPE  NETWR_AP OPTIONAL
*"     REFERENCE(I_QTY) TYPE  KWMENG OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_NETPR) TYPE  NETWR_AP
*"     REFERENCE(E_DIFF) TYPE  NETWR_AP
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSD_EXITCONT_PRICE
*& 프로그램 명 :
*& 개요   : "수주보고와 Sales Order 판가 다를시 User Exit 실행을
*            제외하기 위한 Function
*& 생성일 : 2025.04.30
*& 생성자 : ZGSIDEV05
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : SalesOutlook
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
  CLEAR E_NETPR.
  TRY.

      IF I_AMT NE 0.
        E_DIFF = ABS( I_NETPR - I_AMT ) / I_AMT * 100.
      ENDIF.

      IF I_QTY NE 0.
        E_NETPR = I_AMT / I_QTY.
      ENDIF.

    CATCH CX_ROOT INTO DATA(LO_ERR).
  ENDTRY.

ENDFUNCTION.
