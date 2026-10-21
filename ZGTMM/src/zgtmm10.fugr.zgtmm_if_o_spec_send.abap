FUNCTION ZGTMM_IF_O_SPEC_SEND.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_MATNR STRUCTURE  ZGTMMS1019
*"      OT_SPEC STRUCTURE  ZGTMMS1018
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_O_SPEC_SEND
*& 프로그램 명 :  외주시방서 SPEC 코드 조회(GPRO→SAP)
*& 개요   : 수신된 조회 조건에 맞는 외주시방서 SPEC 코드를 리턴하는 FUNCTION
*& 생성일 : 2026.06.15
*& 생성자 : ZGODEV04
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  DATA:
    LT_SPEC TYPE TABLE OF ZGTEDSIF0041.  "FM TABLE


*--전송 데이터 누락여부 확인
  IF I_SYSTEM_ID IS INITIAL OR I_BUKRS IS INITIAL OR IT_MATNR[] IS INITIAL.
    ZO_RESULT    = GC_02.
    ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
    RETURN.
  ENDIF.

*--필수 값 정합성 체크
*회사코드
  SELECT SINGLE BUKRS
    FROM T001
    WHERE BUKRS = @I_BUKRS
    INTO @DATA(LV_CHK1).

  IF LV_CHK1 IS INITIAL.
    ZO_RESULT    = GC_02.
    ZO_MESSAGE = TEXT-E14.  "유효하지 않은 회사코드입니다.
    RETURN.
  ENDIF.

*--DATA HANDLING
  LT_SPEC = CORRESPONDING #( IT_MATNR[] ).

  LOOP AT LT_SPEC ASSIGNING FIELD-SYMBOL(<LS_SPEC>).
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT  = <LS_SPEC>-MATNR
      IMPORTING
        OUTPUT = <LS_SPEC>-MATNR.
  ENDLOOP.

*--설계서 FM 호출
  CALL FUNCTION 'ZGTED_SEND_OEM_SPEC'
    TABLES
      OT_SPEC = LT_SPEC.                " [GT] 가온전선 외주시방서 Spec 코드 회신용 구조체

  LOOP AT LT_SPEC ASSIGNING <LS_SPEC>.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = <LS_SPEC>-MATNR
      IMPORTING
        OUTPUT = <LS_SPEC>-MATNR.
  ENDLOOP.

*--EXPORT 구성
  OT_SPEC[] = CORRESPONDING #( LT_SPEC MAPPING MAPKEY = FILENAME ).

  IF OT_SPEC[] IS INITIAL.
    ZO_RESULT    = GC_02.
    ZO_MESSAGE = TEXT-E12.
  ELSE.
    ZO_RESULT    = GC_00.
    ZO_MESSAGE = TEXT-M30.
  ENDIF.

ENDFUNCTION.
