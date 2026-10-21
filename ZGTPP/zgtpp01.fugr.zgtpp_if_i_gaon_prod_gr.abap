FUNCTION ZGTPP_IF_I_GAON_PROD_GR.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MODE) TYPE  CHAR02
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_GR STRUCTURE  ZGTPPSIF0022
*"      OT_RESULT STRUCTURE  ZGTPPSIF0023
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_GAON_PROD_GR
*& 프로그램 명 : [GT] [가온전선 MES] 생산오더 입고처리
*& 개요   :
*& 생성일 : 2026.02.24
*& 생성자 : ZGODEV06
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : 가온전선 MES
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
* No      DATE      AUTHORS              DESCRIPTION                   *
* ---  ----------  ---------  -----------------------------------------*
*      2026.02.24  ZGODEV06   함수 ZGTPP_IF_I_CABLE_PROD_GR 복사 생성
* GO01 2026.08.29  ZGODEV03   WIP 상태 오더의 validation 추가
* GO02 2026.09.10  ZGODEV03   전기일 설정 추가
*&---------------------------------------------------------------------*
  DATA LT_TAB TYPE TABLE OF ZGTPPSIF0022.
  DATA LV_ERROR.
  DATA LV_MESSAGE(220).

  CLEAR : LT_TAB, LV_ERROR, GS_TAB, GT_TAB, GT_TAB_RESULT, OT_RESULT, OT_RESULT[].

  LT_TAB[] = IT_GR[].
  GT_TAB = CORRESPONDING #( LT_TAB ).

*- GO02 가온구분 설정
  PERFORM IS_SYSTEM_ID_GAON USING I_SYSTEM_ID GV_GAON.
*- GO02 가온구분 설정

*- 입고
  IF I_MODE = 'P'.
    LOOP AT GT_TAB INTO GS_TAB.
      CLEAR LV_ERROR.
      GS_TAB-I_MODE = 'P'.

*- Conversion_Input
      PERFORM CONVERSION_INPUT_TAB.

*- 공통 체크 항목
      PERFORM CHECK_COMMON_TAB  USING LV_ERROR.

      IF LV_ERROR = 'X'.
        LV_MESSAGE = VALUE #( GT_TAB_RESULT[ ZSERNO = GS_TAB-ZSERNO ]-ZERP_MESSAGE OPTIONAL ).
        PERFORM SAVE_LOG_ZGTPPT3110 USING 'E' LV_MESSAGE '' '' I_SYSTEM_ID.
        CLEAR GS_TAB.
        CONTINUE.
      ENDIF.

*- 입고처리
      PERFORM BAPI_GOODSMVT_CREATE_TAB USING I_SYSTEM_ID.

      CLEAR GS_TAB.
    ENDLOOP.
*- 입고 취소
  ELSEIF I_MODE = 'C'.

    LOOP AT GT_TAB INTO GS_TAB.
      CLEAR LV_ERROR.
      GS_TAB-I_MODE = 'C'.

*- Conversion_Input
      PERFORM CONVERSION_INPUT_TAB.

*- 공통 체크 항목
      PERFORM CHECK_COMMON_TAB  USING LV_ERROR.

      IF LV_ERROR = 'X'.
        LV_MESSAGE = VALUE #( GT_TAB_RESULT[ ZSERNO = GS_TAB-ZSERNO ]-ZERP_MESSAGE OPTIONAL ).
        PERFORM SAVE_LOG_ZGTPPT3110 USING 'E' LV_MESSAGE '' '' I_SYSTEM_ID.
        CLEAR GS_TAB.
        CONTINUE.
      ENDIF.

*- 입고 취소 처리
      PERFORM BAPI_GOODSMVT_CANCEL_TAB USING I_SYSTEM_ID.

      CLEAR GS_TAB.
    ENDLOOP.
  ENDIF.

*- RFC 펑션 결과 리턴
  PERFORM CONVERSION_OUTPUT_TAB_RESULT.

  PERFORM RESULT_TAB_DATA USING ZO_RESULT ZO_MESSAGE.

  OT_RESULT[] = GT_TAB_RESULT[].

*- ZO_RESULT, ZO_MESSAGE 업데이트
  IF GT_GR_KEYS[] IS NOT INITIAL.
    LOOP AT GT_GR_KEYS INTO GS_GR_KEYS.
      UPDATE ZGTPPT3110 SET ZSTAT      = ZO_RESULT
                            ZMESSAGE   = ZO_MESSAGE
                      WHERE ZIFKEY     = GS_GR_KEYS-ZIFKEY
                        AND ZSYSTEM_ID = GS_GR_KEYS-ZSYSTEM_ID
                        AND ZSERNO     = GS_GR_KEYS-ZSERNO
                        AND WERKS      = GS_GR_KEYS-WERKS
                        AND AUFNR      = GS_GR_KEYS-AUFNR
                        AND POSNR      = GS_GR_KEYS-POSNR.
    ENDLOOP.

    COMMIT WORK.
  ENDIF.

ENDFUNCTION.
