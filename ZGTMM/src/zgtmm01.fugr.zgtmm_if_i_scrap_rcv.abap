FUNCTION ZGTMM_IF_I_SCRAP_RCV.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MODE) TYPE  CHAR2 OPTIONAL
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR4
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_TAB STRUCTURE  ZGTMMSIF0078 OPTIONAL
*"      OT_TAB STRUCTURE  ZGTMMSIF0079 OPTIONAL
*"----------------------------------------------------------------------
* 모듈/서브모듈 : MM/Interface
* Type          : Interface
* Frequency     : 중
* Description   : 소재 MOM SCRAP 처리
*-----------------------------------------------------------------------
*                        MODIFICATION LOG
*-----------------------------------------------------------------------
*   DATE              AUTHORS        DESCRIPTION
* ----------------------------------------------------------------------
* 2025.12.17          ZLSGMM3        최초 작성
*-----------------------------------------------------------------------
* 해저 MES I/F Z_PP_IF_I_SM_SCRAP_P15 참조하여 생성

  GV_SYSTEM_ID = I_SYSTEM_ID.
  DATA : LT_ZGTMMT9250 TYPE TABLE OF ZGTMMSIF0078.

  CLEAR : LT_ZGTMMT9250, GS_ZGTMMT9250, GT_ZGTMMT9250, GT_ZGTMMT9250_RESULT.
  CLEAR : GV_MBLNR_O, GV_MBLNR_I,GV_MBLNR_Z.
  CLEAR : GV_MBLNR_OC, GV_MBLNR_IC, GV_MBLNR_ZC.

  LT_ZGTMMT9250[] = IT_TAB[].
  GT_ZGTMMT9250 = CORRESPONDING #( LT_ZGTMMT9250 ).


* ----------------------------------------------------------------------
* 전선/한국미래소재 프로세스 분기 26.09.19
*-----------------------------------------------------------------------

  CASE GV_SYSTEM_ID.
    WHEN 'KFCM'.
      DATA(LV_MODE) = I_MODE.
      PERFORM PROCESS_KFCM USING LV_MODE.

    WHEN OTHERS.
      LOOP AT GT_ZGTMMT9250 INTO GS_ZGTMMT9250.

        CLEAR : GV_MBLNR_O, GV_MBLNR_I, GV_MBLNR_Z.
        CLEAR : GV_ERROR.

        PERFORM CONVERSION_INPUT_ZGTMMT9250.

        GS_ZGTMMT9250-ZFLAG = I_MODE.


*-Scrap 처리
        IF GS_ZGTMMT9250-ZFLAG = 'P'.

*- 수신 데이터 정합성 체크
          PERFORM CHECK_ZGTMMT9250_DATA.
          IF GV_ERROR = 'X'.
            CLEAR GS_ZGTMMT9250.
            CONTINUE.
          ENDIF.

*- Scrap 처리 필요 데이터 발췌
          PERFORM GET_SCRAP_DATA.
          IF GV_ERROR = 'X'.
            CLEAR GS_ZGTMMT9250.
            CONTINUE.
          ENDIF.

*- CO 오더생성
          PERFORM CRE_CO_ORDER.
          IF GV_ERROR = 'X'.
            CLEAR GS_ZGTMMT9250.
            CONTINUE.
          ENDIF.

*--> 소재 MOM 309 MTM 처리 추가
          IF GV_SYSTEM_ID = 'KSCM'.
            PERFORM CREATE_309_SCR.
            IF GV_ERROR = 'X'.
              CLEAR GS_ZGTMMT9250.
              CONTINUE.
            ENDIF.
          ENDIF.
*<-- 소재 MOM 309 MTM 처리 추가

*- Scrap 취소
        ELSE.
          CLEAR : GV_MBLNR_OC, GV_MBLNR_IC, GV_MBLNR_ZC.

*- 수신 데이터 정합성 체크
          PERFORM CHECK_ZGTMMT9250_DATA.
          IF GV_ERROR = 'X'.
            CLEAR GS_ZGTMMT9250.
            CONTINUE.
          ENDIF.

*--> 소재 MOM 309 MTM 취소 추가
          IF GV_SYSTEM_ID = 'KSCM'.
            CLEAR : GV_MBLNR_MC.
            PERFORM CANCEL_309_SCR.
            IF GV_ERROR = 'X'.
              CLEAR GS_ZGTMMT9250.
              CONTINUE.
            ELSE.
              WAIT UP TO 1 SECONDS.
            ENDIF.
          ENDIF.
*<-- 소재 MOM 309 MTM 취소 추가

*- Scrap 처리된 자재문서 취소
          PERFORM CANC_MBLNR.
          IF GV_ERROR = 'X'.
            CLEAR GS_ZGTMMT9250.
            CONTINUE.
          ENDIF.
        ENDIF.
        CLEAR GS_ZGTMMT9250.
      ENDLOOP.

  ENDCASE.


*- RFC 결과 리턴
  PERFORM CONVERSION_OUTPUT_ZGTMMT9250.

  PERFORM RESULT_ZGTMMT9250_DATA USING ZO_RESULT
                                       ZO_MESSAGE.

  OT_TAB[] = GT_ZGTMMT9250_RESULT[].


ENDFUNCTION.
