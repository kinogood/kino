FUNCTION ZGTPP_IF_I_GAON_PROD_GI.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MODE) TYPE  CHAR02
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ISSUE STRUCTURE  ZGTPPSIF0017
*"      OT_RESULT STRUCTURE  ZGTPPSIF0016
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_GAON_PROD_GI
*& 프로그램 명 : [GT] [가온전선 MES] 생산오더 출고처리
*& 개요   :
*& 생성일 : 2026.02.26
*& 생성자 : ZGODEV06
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : 가온전선 MES
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
* No      DATE      AUTHORS              DESCRIPTION                   *
* ---  ----------  ---------  -----------------------------------------*
*      2026.02.26  ZGODEV06   함수 ZGTPP_IF_I_CABLE_PROD_GI 복사 생성
* GO01 2026.06.30  ZGODEV03   플랜트 6500 & 꼬리표 잔량 2m 이하 이면
*                             전체수량 투입
*                             플랜트 6500, 6600 & Factor 배치의 경우
*                             개별조장길이(기본단위)를 0으로 대입
*                             Fiber 추가
* GO02 2026.08.29  ZGODEV03   WIP 상태 오더의 validation 추가
* GO03 2026.09.10  ZGODEV03   전기일 설정 추가
*&---------------------------------------------------------------------*
  DATA : LV_ERROR.

  CLEAR : GT_ISSUE, OT_RESULT, OT_RESULT[], GS_GI_KEYS, GT_GI_KEYS,
          GT_GI_RESULT[], GS_BATCH, GT_BATCH, GV_SUC,
          LV_ERROR.

  DATA(LT_ISSUE) = IT_ISSUE[].
  GT_ISSUE = CORRESPONDING #( LT_ISSUE ).

*- GO03 가온구분 설정
  PERFORM IS_SYSTEM_ID_GAON USING I_SYSTEM_ID GV_GAON.
*- GO03 가온구분 설정

*- 자재 투입 : P. 자재 투입 재처리 : R. 자재 투입 취소 : C, 대체투입 :  A.
  IF IT_ISSUE[] IS NOT INITIAL.
    IF I_MODE = 'P' OR I_MODE = 'R' OR I_MODE = 'A'.
      LOOP AT GT_ISSUE INTO DATA(LS_ISSUE).
        CLEAR LV_ERROR.
        LS_ISSUE-I_MODE = I_MODE.

*- Conversion_Input.
        PERFORM CONVERSION_INPUT USING LS_ISSUE I_MODE.

*- 수신데이터 정합성 체크
* 공통 체크 항목
        PERFORM CHECK_COMMON_ISSUE USING LS_ISSUE LV_ERROR I_MODE.

        IF LV_ERROR = 'X'.
          PERFORM SAVE_LOG_ZGTPPT3070 USING LS_ISSUE I_SYSTEM_ID I_MODE.
          CONTINUE.
        ENDIF.

* 자재 투입 체크 항목
        PERFORM CHECK_INPUT_ISSUE USING LS_ISSUE LV_ERROR I_SYSTEM_ID I_MODE.

        IF LV_ERROR = 'X' OR LV_ERROR = 'E'.
          IF I_MODE = 'P' OR I_MODE = 'A'.
            PERFORM SAVE_LOG_ZGTPPT3070 USING LS_ISSUE I_SYSTEM_ID I_MODE.
          ELSEIF I_MODE = 'R'.
            PERFORM SAVE_LOG_ZGTPPT3070 USING LS_ISSUE I_SYSTEM_ID I_MODE.
            IF LV_ERROR = 'X'.
              PERFORM SAVE_LOG_ZGTPPT3100 USING LS_ISSUE I_SYSTEM_ID I_MODE.
            ENDIF.
          ENDIF.
          CONTINUE.
        ENDIF.

*- 투입 처리
        PERFORM BAPI_GOODSMVT_CREATE USING LS_ISSUE I_SYSTEM_ID I_MODE.
      ENDLOOP.

*- [GO01] 20260629 Fiber 원자재 투입 : F
    ELSEIF I_MODE = 'F'.
      LOOP AT GT_ISSUE INTO LS_ISSUE.

        CHECK LS_ISSUE-WERKS EQ '6600'.

        CLEAR LV_ERROR.
        LS_ISSUE-I_MODE = I_MODE.

*- Conversion_Input.
        PERFORM CONVERSION_INPUT USING LS_ISSUE I_MODE.

*- 수신데이터 정합성 체크
* 공통 체크 항목
        PERFORM CHECK_COMMON_ISSUE USING LS_ISSUE LV_ERROR I_MODE.

        IF LV_ERROR = 'X'.
          PERFORM SAVE_LOG_ZGTPPT3070_F USING LS_ISSUE I_SYSTEM_ID I_MODE.
          CONTINUE.
        ENDIF.

* 자재 투입 체크 항목
        PERFORM CHECK_INPUT_ISSUE_F USING LS_ISSUE LV_ERROR I_SYSTEM_ID I_MODE.

        IF LV_ERROR = 'X' OR LV_ERROR = 'E'.
          PERFORM SAVE_LOG_ZGTPPT3070_F USING LS_ISSUE I_SYSTEM_ID I_MODE.
          CONTINUE.
        ENDIF.

*- 투입 처리
        PERFORM BAPI_GOODSMVT_CREATE_F USING LS_ISSUE I_SYSTEM_ID I_MODE.
      ENDLOOP.
*- [GO01]

*- 자재 투입 취소 : C. 자재 투입 재처리 취소 : RC
    ELSEIF I_MODE = 'C' OR I_MODE = 'RC'.
      LOOP AT GT_ISSUE INTO LS_ISSUE.
        CLEAR LV_ERROR.
        LS_ISSUE-I_MODE = I_MODE.
*- Conversion_Input
        PERFORM CONVERSION_INPUT USING LS_ISSUE I_MODE.
*- 수신데이터 정합성 체크
* 공통 체크 항목
        PERFORM CHECK_COMMON_ISSUE  USING LS_ISSUE LV_ERROR I_MODE.
        IF LV_ERROR = 'X'.
          PERFORM SAVE_LOG_ZGTPPT3070 USING LS_ISSUE I_SYSTEM_ID I_MODE.
          CONTINUE.
        ENDIF.
*- 투입 취소 체크 항목
        PERFORM CHECK_CANCEL_ISSUE USING LS_ISSUE LV_ERROR.
        IF LV_ERROR = 'X'.
          PERFORM SAVE_LOG_ZGTPPT3070 USING LS_ISSUE I_SYSTEM_ID I_MODE.
          CONTINUE.
        ENDIF.
*- 투입 취소 처리
        PERFORM BAPI_GOODSMVT_CANCEL USING LS_ISSUE I_SYSTEM_ID I_MODE.
      ENDLOOP.

*- [GO01] 20260629 Fiber 원자재 투입 취소: FC
    ELSEIF I_MODE = 'FC'.
      LOOP AT GT_ISSUE INTO LS_ISSUE.

        CHECK LS_ISSUE-WERKS EQ '6600'.

        CLEAR LV_ERROR.
        LS_ISSUE-I_MODE = I_MODE.

*- Conversion_Input.
        PERFORM CONVERSION_INPUT USING LS_ISSUE I_MODE.

*- 수신데이터 정합성 체크
* 공통 체크 항목
        PERFORM CHECK_COMMON_ISSUE USING LS_ISSUE LV_ERROR I_MODE.

        IF LV_ERROR = 'X'.
          PERFORM SAVE_LOG_ZGTPPT3070_F USING LS_ISSUE I_SYSTEM_ID I_MODE.
          CONTINUE.
        ENDIF.

*- 투입 취소 체크 항목
        PERFORM CHECK_CANCEL_ISSUE_FC USING LS_ISSUE LV_ERROR.

        IF LV_ERROR = 'X'.
          PERFORM SAVE_LOG_ZGTPPT3070_F USING LS_ISSUE I_SYSTEM_ID I_MODE.
          CONTINUE.
        ENDIF.
*- 투입 취소 처리
        PERFORM BAPI_GOODSMVT_CANCEL_FC USING LS_ISSUE I_SYSTEM_ID I_MODE.
      ENDLOOP.
*- [GO01]
    ENDIF.

*- RFC 펑션 결과 리턴
    PERFORM CONVERSION_OUTPUT_GT_GI_RESULT.

    PERFORM RESULT_GI_DATA USING ZO_RESULT ZO_MESSAGE.

    OT_RESULT[] = GT_GI_RESULT[].

*- ZO_RESULT, ZO_MESSAGE 업데이트
    IF GT_GI_KEYS[] IS NOT INITIAL.
      LOOP AT GT_GI_KEYS INTO GS_GI_KEYS.
        UPDATE ZGTPPT3070 SET ZSTAT      = ZO_RESULT
                              ZMESSAGE   = ZO_MESSAGE
                        WHERE ZIFKEY     = GS_GI_KEYS-ZIFKEY
                          AND ZSYSTEM_ID = GS_GI_KEYS-ZSYSTEM_ID
                          AND ZSERNO     = GS_GI_KEYS-ZSERNO
                          AND WERKS      = GS_GI_KEYS-WERKS
                          AND RSNUM      = GS_GI_KEYS-RSNUM
                          AND RSPOS      = GS_GI_KEYS-RSPOS.
      ENDLOOP.

      COMMIT WORK.
    ENDIF.
  ENDIF.

ENDFUNCTION.
