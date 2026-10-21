FUNCTION ZGTMM_IF_O_LME_PRICE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(IS_D365_LOGIN) TYPE  ZSDS_LOG_0000
*"  EXPORTING
*"     VALUE(ES_RETURN) TYPE  ZSDS_LOG_0001
*"  TABLES
*"      OT_DATA STRUCTURE  ZGTMMS4520
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_O_LME_PRICE
*& 프로그램 명 : 비철 시세 조회 (SAP -> Sales Outlook)
*& 개요   : Sales Outlook에서 비철 시세 정보를 조회하는 RFC 생성
*& 생성일 : 2026.08.13
*& 생성자 : ZGODEV04
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
*Sales Outlook 공용 로그용
  INCLUDE ZSDC0000.
  DATA : LV_WHERE TYPE STRING,
         LT_TRUCK LIKE TABLE OF ZGTMMS4512.

*--필수 입력 값 체크
  IF IS_D365_LOGIN IS INITIAL OR I_BUKRS IS INITIAL.
*Sales Outlook 공용 로그 저장
    PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.
    ES_RETURN = VALUE #( MTYPE = 'E'
                                         MESSAGE = '필수 입력값이 누락 되었습니다.'(M01) ).
    RETURN.
  ENDIF.


*--DATA 조회
  SELECT FROM ZGTMM_CV_GET_LMC_DAILY_CAL_MAX
    FIELDS *
    WHERE BUKRS = @I_BUKRS
        INTO TABLE @DATA(LT_DATA).

**--> 26.09 월기준 추가 - 조회기준월(ZGTMM_CV_GET_LMC_DAILY_CAL_MAX 기준의 월)
  SELECT FROM @LT_DATA AS Z INNER JOIN ZGTMM_CV_GET_LMC_MONTHLY_CAL AS A
                                        ON SUBSTRING( Z~CDATE, 1, 6 ) EQ A~CMON
    FIELDS
            A~EXRATE_TTS,
            A~EXRATE_TTM,
            A~CU_CASH   ,
            A~CU_WAERS  ,
            A~CU_LMC    ,
            A~CU_KWAERS ,
            A~AL_CASH   ,
            A~AL_WAERS  ,
            A~AL_LMC    ,
            A~AL_KWAERS ,
            A~PB_CASH   ,
            A~PB_WAERS  ,
            Z~CDATE
    WHERE A~BUKRS EQ @I_BUKRS
    INTO TABLE @DATA(LT_DATA_M).
**--< 26.09 월기준 추가


*--RESULT
  CLEAR OT_DATA.
  DATA : LV_AMOUNT(20) TYPE C,
         LV_CURR       TYPE NETPR.

  IF LT_DATA IS INITIAL.
    ES_RETURN = VALUE #( MTYPE = 'S'
                         MESSAGE = '해당 조건에 맞는 데이터가 없습니다..'(M02) ).

  ELSE.
*금액필드_원화표기 변환
    LOOP AT LT_DATA ASSIGNING FIELD-SYMBOL(<DATA>).
      CLEAR LV_CURR.
      PERFORM CONVERT_CURRENCY  USING <DATA>-LMC_CU CHANGING LV_CURR.
      <DATA>-LMC_CU = LV_CURR.

      CLEAR LV_CURR.
      PERFORM CONVERT_CURRENCY  USING <DATA>-LMC_AL CHANGING LV_CURR.
      <DATA>-LMC_AL = LV_CURR.
    ENDLOOP.

    OT_DATA[]  = CORRESPONDING #( LT_DATA[] ).
    MODIFY OT_DATA FROM VALUE #( ZGBN = 'D' ) TRANSPORTING ZGBN WHERE ZGBN IS INITIAL.

    ES_RETURN = VALUE #( MTYPE = 'S'
                                         MESSAGE = '조회에 성공 했습니다..'(M03) ).
  ENDIF.

**--> 26.09 월기준 추가
  DATA LT_O_DATA LIKE TABLE OF ZGTMMS4520.
*  DATA(LT_O_DATA) = CONV ZGTMMS4520( '' ).
  IF LT_DATA_M[] IS INITIAL.
    ES_RETURN = VALUE #( MTYPE = 'S'
                         MESSAGE = '해당 조건에 맞는 데이터가 없습니다..'(M02) ).

  ELSE.
*금액필드_원화표기 변환
    LOOP AT LT_DATA_M ASSIGNING FIELD-SYMBOL(<DATA_M>).
      DATA(LS_O_DATA) = VALUE ZGTMMS4520(
                                          CDATE       = <DATA_M>-CDATE
                                          TTS         = <DATA_M>-EXRATE_TTS
                                          TTM         = <DATA_M>-EXRATE_TTM
                                          LME_CU      = <DATA_M>-CU_CASH
                                          UWAERS_CU   = <DATA_M>-CU_WAERS
                                          LMC_CU      = <DATA_M>-CU_LMC
                                          KWAERS_CU   = <DATA_M>-CU_KWAERS
                                          LME_AL     =  <DATA_M>-AL_CASH
                                          UWAERS_AL  =  <DATA_M>-AL_WAERS
                                          LMC_AL      = <DATA_M>-AL_LMC
                                          KWAERS_AL   = <DATA_M>-AL_KWAERS
                                          LME_PB      = <DATA_M>-PB_CASH
                                          UWAERS_PB   = <DATA_M>-PB_WAERS
                                          ZGBN        = 'M'
                                          ).

      CLEAR LV_CURR.
      PERFORM CONVERT_CURRENCY  USING LS_O_DATA-LMC_CU CHANGING LV_CURR.
      LS_O_DATA-LMC_CU = LV_CURR.

      CLEAR LV_CURR.
      PERFORM CONVERT_CURRENCY  USING LS_O_DATA-LMC_AL CHANGING LV_CURR.
      LS_O_DATA-LMC_AL = LV_CURR.

      APPEND LS_O_DATA TO LT_O_DATA. CLEAR LS_O_DATA.
    ENDLOOP.

    OT_DATA[]  = CORRESPONDING #( BASE ( OT_DATA[] ) LT_O_DATA[] ).

    ES_RETURN = VALUE #( MTYPE = 'S'
                                         MESSAGE = '조회에 성공 했습니다..'(M03) ).
  ENDIF.



*Sales Outlook 공용 로그 저장
  PERFORM SAVE_LOG(ZCMR0004) TABLES GT_ILOG USING GS_HLOG ES_RETURN.

ENDFUNCTION.
