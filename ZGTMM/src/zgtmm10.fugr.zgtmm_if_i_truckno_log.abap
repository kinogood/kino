FUNCTION ZGTMM_IF_I_TRUCKNO_LOG.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_TRUCKNO) TYPE  CHAR12 OPTIONAL
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      OT_TRUCK STRUCTURE  ZGTMMS4518
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_TRUCKNO_LOG
*& 프로그램 명 : 직송 운송차량 번호 조회
*& 개요   : G-SRM(전자구매시스템)으로 직송 운송 차량 정보를 조회하여 return하는 RFC 개발
*& 생성일 : 2026.02.12
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


 DATA : LV_COND TYPE STRING.
 DATA: LR_TRUCKNO TYPE RANGE OF ZGTMM_CV_GET_DD_TRUCKNO-TRUCKNO,
           LS_TRUCKNO LIKE LINE OF LR_TRUCKNO.

*
*--필수 입력 값 체크
  IF I_SYSTEM_ID IS INITIAL OR I_BUKRS IS INITIAL.

     ZO_RESULT    = '02'.
     ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
     RETURN.
  ENDIF.

  LV_COND = | BUKRS = '{ I_BUKRS }' |.

  IF I_TRUCKNO IS NOT INITIAL.
   CLEAR ls_TRUCKNO.
   LS_TRUCKNO-sign   = 'I'.
   LS_TRUCKNO-option = 'CP'.
   LS_TRUCKNO-low    =  |*{ I_TRUCKNO }*|.
   APPEND LS_TRUCKNO  TO  LR_TRUCKNO.

  LV_COND &&= | AND TRUCKNO IN @LR_TRUCKNO |.
  ENDIF.

*차량  정보 가져오기
  SELECT FROM ZGTMM_CV_GET_DD_TRUCKNO
       FIELDS *
       WHERE (LV_COND)
            INTO TABLE @DATA(LT_INFO).

   IF LT_INFO[] IS INITIAL.
     ZO_RESULT    = GC_00.
     ZO_MESSAGE = '조건에 맞는 정보가 없습니다.'(E12).

  ELSE.
*     LOOP AT  LT_INFO ASSIGNING FIELD-SYMBOL(<FS>).
*     ENDLOOP.

     OT_truck[] = CORRESPONDING #( LT_INFO[] ).

     ZO_RESULT    = GC_00.
     ZO_MESSAGE = '차량 정보가 조회되었습니다.'(M25).
  ENDIF.

ENDFUNCTION.
