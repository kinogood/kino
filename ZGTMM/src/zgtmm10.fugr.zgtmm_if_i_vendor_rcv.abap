FUNCTION ZGTMM_IF_I_VENDOR_RCV.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_TYPE) TYPE  CHAR1
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"     VALUE(E_TYPE) TYPE  CHAR1
*"     VALUE(E_BUKRS) TYPE  BUKRS
*"     VALUE(E_LIFNR) TYPE  LIFNR
*"     VALUE(E_GVENDOR) TYPE  LIFNR
*"  TABLES
*"      IT_TAB STRUCTURE  ZGTMMS1010
*"      IT_TAB2 STRUCTURE  ZGTMMS1017 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_VENDOR_RCV
*& 프로그램 명 :  공급업체 정보 수신(G-SRM->SAP)
*& 개요   : 공급업체 정보 수신(G-SRM->SAP) 후 BP 마스터 생성/변경
*& 생성일 : 2026.01.19
*& 생성자 : ZGODEV07
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

  "초기화
  CLEAR:
    ZO_RESULT,
    ZO_MESSAGE,
    E_TYPE,
    E_BUKRS,
    E_LIFNR.

  E_TYPE = I_TYPE.
  E_BUKRS = I_BUKRS.

  "필수 값이 누락 되었습니다.
  IF I_SYSTEM_ID EQ SPACE OR I_BUKRS EQ SPACE
    OR IT_TAB[] IS INITIAL.
    ZO_RESULT = GC_02.
    ZO_MESSAGE = TEXT-E01.
    EXIT.
  ENDIF.

  IF I_TYPE NE GC_C AND I_TYPE NE GC_U.
    ZO_RESULT = GC_02.
    ZO_MESSAGE = TEXT-E01.
    EXIT.
  ENDIF.

  DATA:
    LS_LOG      TYPE ZGTMMT9000,
    LS_LOG_DATA TYPE ZGTMMT9270,
    LT_LOG_DATA2 TYPE TABLE OF ZGTMMT9271.

  "무조건 한줄 씩 들어옴
  DATA LS_DATA TYPE ZGTMMS1010.
  READ TABLE IT_TAB INTO LS_DATA INDEX 1.

  E_GVENDOR =  LS_DATA-GVENDOR.
  LS_DATA-AKONT = |{ LS_DATA-AKONT ALPHA = IN }|.
  LS_DATA-LIFNR = |{ LS_DATA-LIFNR ALPHA = IN }|.
  LS_DATA-KUNNR = |{ LS_DATA-KUNNR ALPHA = IN }|.   "공급업체-고객 Mapping 값 추가

*1-2) IT_TAB 데이터 중 SAP 표준 마스터에 존재하지 않는 값이 있는 경우 다음값 Return 후 종료
*	유효성 점검 대상
  PERFORM F_CHECK_VALUES_VENDOR_RCV USING I_BUKRS I_TYPE LS_DATA CHANGING E_LIFNR ZO_RESULT ZO_MESSAGE.
  CHECK ZO_RESULT NE GC_02.

*1-3) IT_TAB2 데이터 중 SAP 표준 마스터에 존재하지 않는 값이 있는 경우 다음값 Return 후 종료
*	유효성 점검 대상
  PERFORM F_CHECK_VALUES_VENDOR_RCV2 TABLES IT_TAB2  USING I_BUKRS CHANGING ZO_RESULT ZO_MESSAGE.
  CHECK ZO_RESULT NE GC_02.

*  3) 전송 정보 저장(1차 Log 등록)
  PERFORM ZGTMM_IF_I_VENDOR_RCV_LOG TABLES IT_TAB2 LT_LOG_DATA2
  USING GC_1 I_SYSTEM_ID I_BUKRS I_TYPE LS_DATA
  CHANGING LS_LOG LS_LOG_DATA.

  "데이터 설정
  DATA LT_DATA TYPE CVIS_EI_EXTERN_T.
  PERFORM F_SET_VALUES_VENDER_RCV TABLES IT_TAB2 USING I_BUKRS I_TYPE LS_DATA CHANGING LT_DATA.

*  3-2-3) CL_MD_BP_MAINTAIN 호출
  DATA LT_RET TYPE BAPIRETCT.
  CL_MD_BP_MAINTAIN=>MAINTAIN(
    EXPORTING
        I_DATA = LT_DATA
*        I_TEST_RUN = ABAP_TRUE
        IMPORTING
          E_RETURN = DATA(LT_RES)
  ).

  IF LT_RES[] IS NOT INITIAL.
    READ TABLE LT_RES ASSIGNING FIELD-SYMBOL(<LT_MSG>) INDEX 1.
    READ TABLE <LT_MSG>-OBJECT_MSG[] ASSIGNING FIELD-SYMBOL(<LS_MSG_E>) WITH KEY TYPE = GC_E.
    IF SY-SUBRC EQ 0.
      ZO_RESULT = GC_02.
      ZO_MESSAGE = <LS_MSG_E>-MESSAGE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.
      READ TABLE <LT_MSG>-OBJECT_MSG[] ASSIGNING FIELD-SYMBOL(<LS_MSG_A>) WITH KEY TYPE = GC_A.
      IF SY-SUBRC EQ 0.
        ZO_RESULT = GC_02.
        ZO_MESSAGE = <LS_MSG_A>-MESSAGE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ELSE.
        ZO_RESULT = GC_00.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.

*C인 경우 SAP 처리 결과 값 리턴
        IF I_TYPE EQ GC_C.
          SELECT SINGLE VENDOR
            FROM CVI_VEND_LINK
           WHERE PARTNER_GUID EQ @<LT_MSG>-OBJECT_KEY
            INTO @E_LIFNR.
          ZO_MESSAGE = TEXT-M10. "공급업체 생성 완료

        ELSEIF I_TYPE EQ GC_U.

          E_LIFNR = LS_DATA-LIFNR.
          ZO_MESSAGE = TEXT-M11. "공급업체 변경 완료
        ENDIF.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = E_LIFNR
          IMPORTING
            OUTPUT = E_LIFNR.

      ENDIF.
    ENDIF.
  ELSE.
    IF I_TYPE EQ GC_C.
      ZO_RESULT = GC_02.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.
      "변경 시 메세지 나오지 않는 경우 있음..!?
      ZO_RESULT = GC_00.
*      CL_MD_BP_MAINTAIN=>SAVE_AND_COMMIT( ).
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.
      E_LIFNR = LS_DATA-LIFNR.
      ZO_MESSAGE = TEXT-M11. "공급업체 변경 완료
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = E_LIFNR
        IMPORTING
          OUTPUT = E_LIFNR.
    ENDIF.
  ENDIF.

*  3) 전송 정보 저장(2차 Log 등록)
  LS_LOG-MESSAGE = ZO_MESSAGE.
  LS_LOG-ZSTAT = COND #( WHEN ZO_RESULT EQ GC_00 THEN GC_S ELSE GC_E ).
  LS_LOG_DATA-LIFNR = E_LIFNR.

  PERFORM ZGTMM_IF_I_VENDOR_RCV_LOG TABLES IT_TAB2 LT_LOG_DATA2
  USING GC_2 I_SYSTEM_ID I_BUKRS I_TYPE LS_DATA
  CHANGING LS_LOG LS_LOG_DATA.

ENDFUNCTION.
