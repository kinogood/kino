FUNCTION ZGTMM_IF_I_POCONFIRM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_EKORG) TYPE  EKORG
*"     VALUE(I_EBELN) TYPE  EBELN
*"     VALUE(I_ZCONFIRM) TYPE  ZGTE_POCONF
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_POCONFIRM
*& 프로그램 명 :  구매 오더 확정/반려 정보 수신(G-SRM->SAP)
*& 개요   : G-SRM(전자구매시스템)에서 전송된 구매 오더 확정/반려 정보를 업데이트 하는
*&           INTERFACE 용 FUNCTION 개발 RFC (From G-SRM)
*& 생성일 : 2025.12.22
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

*--전송 데이터 누락여부 확인
  IF I_SYSTEM_ID IS INITIAL OR I_BUKRS IS INITIAL OR I_EKORG IS INITIAL OR
     I_EBELN IS INITIAL OR I_ZCONFIRM IS INITIAL .

      ZO_RESULT    = GC_02.
      ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
      RETURN.

  ENDIF.

*--전송 정보 저장(1차 Log 등록)
  CLEAR: GS_MSG, GS_9240, GV_SYSTEM_ID, GT_9231, GT_9232.

  GV_SYSTEM_ID = I_SYSTEM_ID.

  GS_9240 = VALUE #( EKORG        = I_EKORG
                                  EBELN        = I_EBELN
                                  ZCONFIRM   = I_ZCONFIRM  ).

  PERFORM SET_COM_LOG  USING 'S' 'MM00025' '' '' CHANGING GS_9000.
  PERFORM SET_92XX_LOG  USING 'PO' GS_9240 GS_9000.

*--PO 확정/반려 여부 업데이트
*법인 별 로직 분개_현재는 가온 구매조직 '1400'만 구현
 CASE I_EKORG.

*가온전선 구매조직(1400)
 	WHEN '1400'.
*PO CONFIRMATION UPDATE
     PERFORM SET_CONFIRM USING I_ZCONFIRM GS_9240.

*그 외..
 	WHEN OTHERS.

 ENDCASE.

*EXPORT 구성
 IF GS_RETURN IS INITIAL. "성공

    ZO_RESULT    = GC_00."NUMBER 00
    ZO_MESSAGE =  COND #( WHEN I_ZCONFIRM = GC_C "확정
                                            THEN '구매오더 접수 정보 반영 되었습니다.'(M04)
                                            ELSE '접수 해제 되었습니다.'(M06) ). "반려

 ELSE. "에러

    ZO_RESULT    = GC_02. "02
    ZO_MESSAGE = GS_RETURN-MESSAGE .
 ENDIF.


ENDFUNCTION.
