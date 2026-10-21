FUNCTION ZGTMM_IF_I_RFQSTATUS.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_PR STRUCTURE  ZGTMMS1008
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_RFQSTATUS
*& 프로그램 명 :  PR 견적 진행 상태 등록(G-SRM->SAP)
*& 개요   : G-SRM에서 견적진행 중 구매요청을 수정 못하도록 상태 수신 받는 RFC
*& 생성일 : 2026.01.28
*& 생성자 : ZGODEV04
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : G-SRM -> EAI -> SAP
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  DATA : LT_2000 LIKE TABLE OF ZGTMMT2000,
             LV_MSG TYPE STRING.

  CLEAR : ZO_RESULT, ZO_MESSAGE.

*--전송 데이터 누락여부 확인
  IF I_SYSTEM_ID IS INITIAL OR I_BUKRS IS INITIAL.

      ZO_RESULT    = GC_02.
      ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
      RETURN.

  ENDIF.

  IF IT_PR[] IS INITIAL.

       ZO_RESULT    = GC_02.
       ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
       RETURN.

  ELSE.
*--DATA SAVE_ZGTMMT2000
       LT_2000 = VALUE #( BASE LT_2000
                                      FOR WA IN IT_PR
                                      ( VALUE #( BASE CORRESPONDING #( WA )
                                         ERDAT = SY-DATUM
                                         ERDAT_LOCAL = SY-DATLO
                                         ERTIM = SY-UZEIT
                                         ERTIM_LOCAL = SY-TIMLO
                                         ERNAM = SY-UNAME ) ) ).

       DELETE ADJACENT DUPLICATES FROM LT_2000 COMPARING BANFN BNFPO.
       MODIFY ZGTMMT2000 FROM TABLE LT_2000.

*--EXPORT 구성
       IF SY-SUBRC = 0.
          COMMIT WORK AND WAIT .
          ZO_RESULT    = GC_00."NUMBER 00
          ZO_MESSAGE = '견적 진행 상태가 등록되었습니다..'(M13) .

       ELSE.
          ZO_RESULT    = GC_02. "02
          ZO_MESSAGE = '견적 진행 상태 등록 중 오류가 발생했습니다.'(M14) .
       ENDIF.

  ENDIF.

ENDFUNCTION.
