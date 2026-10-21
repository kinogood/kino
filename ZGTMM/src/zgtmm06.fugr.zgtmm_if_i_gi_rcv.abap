FUNCTION ZGTMM_IF_I_GI_RCV .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR4
*"     VALUE(I_ZTYPE) TYPE  CHAR1
*"     VALUE(I_DATE) TYPE  DATS
*"     VALUE(I_ZTEXT) TYPE  CHAR25
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      LT_ITAB STRUCTURE  ZGTMMT9200
*"      LT_OTAB STRUCTURE  ZGTMMSIF0075
*"----------------------------------------------------------------------
*& 생성일자: 2025.08.09                                                *
*& 생성내용: 신규 생성                                                 *
*& 생 성 자: ZLSGMM3                                                   *
*&---------------------------------------------------------------------*

*-----------------------------------------------------------------------
*                        MODIFICATION LOG
*-----------------------------------------------------------------------
*   DATE              AUTHORS        DESCRIPTION
* ----------------------------------------------------------------------
*  2025.08.09         ZLSGMM3       구미공장 WMS 사내거래 출고 수신
*-----------------------------------------------------------------------
  GV_ZTYPE = I_ZTYPE.
  GV_DATE = I_DATE.
  GV_ZTEXT = I_ZTEXT.

  DATA : LV_STAMP   LIKE TZONREF-TSTAMPL,
         LV_IFKEY   TYPE C LENGTH 23,
         LV_RESULT  TYPE ZO_RESULT,
         LV_RET     TYPE ZIFE_IFRET,
         LV_MESSAGE TYPE TEXT100.
  DATA : LV_GUBUN(1). "--> 전선/비전선 구분자

  DATA : LV_COUNT_S(10),
         LV_COUNT_E(10),
         LV_MSG_S       TYPE TEXT100,
         LV_MSG_E       TYPE TEXT100.

  CLEAR : GT_ITAB, GT_ITAB[], GT_OTAB, GT_OTAB[].

  IF GV_ZTYPE = 'R'.
    LV_RESULT  = GC_01. " Fail
    LV_MESSAGE = 'I_ZTYPE=R impossible.'.
    ZO_RESULT  = LV_RESULT.
    ZO_MESSAGE = LV_MESSAGE.
    EXIT.
  ENDIF.

*  PERFORM SAVE_IF_LOG_DETAIL_H USING LV_IFKEY.
*--> I/F 수신 이력 저장
  SORT LT_ITAB BY IFNUM IFSEQ.
  LOOP AT LT_ITAB.
    MOVE-CORRESPONDING LT_ITAB TO GT_ITAB.
    MOVE : SY-UNAME TO GT_ITAB-CRE_NAM.
    MOVE : SY-DATUM TO GT_ITAB-CRE_DAT.
    MOVE : SY-UZEIT TO GT_ITAB-CRE_ZET.
    MOVE : GV_ZTYPE TO GT_ITAB-ZTYPE.
    IF GV_ZTYPE = 'P'.
      GT_ITAB-BWART = '351'.
    ENDIF.
    APPEND GT_ITAB.
    CLEAR GT_ITAB.
  ENDLOOP.
  MODIFY ZGTMMT9200 FROM TABLE GT_ITAB.
  IF SY-SUBRC = 0.
    COMMIT WORK AND WAIT.
  ENDIF.
*<-- I/F 수신 이력 저장

*- Conversion_exit_alpha_input.
  PERFORM CONVERSION_INPUT.

  "--> BAPI
  IF GV_ZTYPE = 'P'. "--> 사내거래 출고
    PERFORM BAPI_GOODSMVT_P.
  ELSEIF GV_ZTYPE = 'R'. "--> 예약 출고
*    PERFORM BAPI_GOODSMVT.
  ELSEIF GV_ZTYPE = 'C'. "--> 취소
    PERFORM BAPI_GOODSMVT_C.
  ENDIF.

  SORT GT_ITAB BY IFNUM IFSEQ.
  SORT GT_OTAB BY IFNUM IFSEQ.
  "--> 결과 UPDATE + 사내거래 꼬리표 처리
  LOOP AT GT_ITAB.
    READ TABLE GT_OTAB WITH KEY IFNUM = GT_ITAB-IFNUM
                                IFSEQ = GT_ITAB-IFSEQ
                       BINARY SEARCH.
    IF SY-SUBRC = 0.
      GT_ITAB-ZRESULT = GT_OTAB-ZRESULT.
      GT_ITAB-ZMESSAGE = GT_OTAB-ZMESSAGE.
      GT_ITAB-EBELN = GT_OTAB-EBELN.
      GT_ITAB-EBELP = GT_OTAB-EBELP.
      GT_ITAB-MBLNR = GT_OTAB-MBLNR.
      GT_ITAB-MJAHR = GT_OTAB-MJAHR.
      GT_ITAB-ZEILE = GT_OTAB-ZEILE.
      GT_ITAB-MBLNR_C = GT_OTAB-MBLNR_C.
      GT_ITAB-MJAHR_C = GT_OTAB-MJAHR_C.
      GT_ITAB-ZEILE_C = GT_OTAB-ZEILE_C.
      MODIFY GT_ITAB TRANSPORTING ZRESULT ZMESSAGE
                                  EBELN EBELP
                                  MBLNR MJAHR ZEILE
                                  MBLNR_C MJAHR_C ZEILE_C.
    ENDIF.
    "--> 사내거래 처리 성공했을 시 꼬리표 처리
    "--> 취소 시에도 WMS로부터 꼬리표 받아야 함
    IF GT_ITAB-ZMESSAGE = '00'.
      IF GT_ITAB-TAGNR IS NOT INITIAL.
        "--> 사내거래 경우에만 EBELN 존재
        IF GT_ITAB-EBELN IS NOT INITIAL.
          IF GT_ITAB-ZTYPE = 'P'. "--> 정상 처리

            SELECT COUNT(*)
              FROM ZPPT0019
             WHERE EBELN   =  GT_ITAB-EBELN
               AND EBELP   =  GT_ITAB-EBELP
               AND PLUMI   = '2' "-->출고
               AND TAGNR   =  GT_ITAB-TAGNR.

            IF SY-DBCNT > 0.
              UPDATE ZPPT0019
                 SET MBLNR   =  GW_HEADRET-MAT_DOC
                     MJAHR   =  GW_HEADRET-DOC_YEAR
                     MBLNR_F = 'X'
               WHERE EBELN   =  GT_ITAB-EBELN
                 AND EBELP   =  GT_ITAB-EBELP
                 AND PLUMI   = '2' "-->출고
                 AND TAGNR   =  GT_ITAB-TAGNR.
            ELSE.
              CLEAR : ZPPT0019.
              MOVE-CORRESPONDING GT_ITAB TO ZPPT0019.
              ZPPT0019-PLUMI      = '2'.
              ZPPT0019-RESWK      = GT_ITAB-R_WERKS.
              ZPPT0019-ENMNG      = GT_ITAB-ERFMG.
              ZPPT0019-MEINS      = GT_ITAB-ERFME.
              ZPPT0019-MBLNR      = GW_HEADRET-MAT_DOC.
              ZPPT0019-MJAHR      = GW_HEADRET-DOC_YEAR.
              ZPPT0019-MBLNR_F    = 'X'.
              ZPPT0019-ERDAT      = SY-DATLO.
              ZPPT0019-ERTIM      = SY-TIMLO.
              ZPPT0019-ERNAM      = SY-UNAME.

              SELECT SINGLE MENGE
                INTO ZPPT0019-BSTMG
                FROM EKPO
               WHERE EBELN = GT_ITAB-EBELN
                 AND EBELP = GT_ITAB-EBELP.

              INSERT ZPPT0019.
            ENDIF.
            COMMIT WORK AND WAIT.

            CLEAR : LV_GUBUN.
            SELECT SINGLE B~GUBUN
              INTO LV_GUBUN
              FROM MARC AS A
                   INNER JOIN ZPPT0134 AS B
                    ON A~WERKS = B~WERKS
                    AND A~DISPO = B~DISPO
             WHERE B~WERKS = GT_ITAB-WERKS
               AND A~MATNR = GT_ITAB-MATNR.

            IF SY-SUBRC = 0.
              CASE LV_GUBUN.
                WHEN 'C'. "--> 전선
                  PERFORM UPDATE_ZPPT0001_GI USING GT_ITAB-TAGNR
                                                   'Y'.
                WHEN 'B'. "--> 비전선
                  PERFORM UPDATE_ZPPT0211_GI USING GT_ITAB-TAGNR
                                                   'Y'.
              ENDCASE.
            ENDIF.

          ELSEIF GT_ITAB-ZTYPE = 'C'. "--> 취소

            CLEAR : LV_GUBUN.
            CLEAR : ZPPT0134.
            SELECT SINGLE A~GUBUN
              INTO LV_GUBUN
              FROM ZPPT0134 AS A
                   INNER JOIN MARC AS B
                    ON A~WERKS = B~WERKS
                    AND A~DISPO = B~DISPO
             WHERE A~WERKS = GT_ITAB-WERKS
               AND B~MATNR = GT_ITAB-MATNR.

            IF SY-SUBRC = 0.
              SELECT *
                FROM ZPPT0019
               WHERE EBELN  =  GT_ITAB-EBELN
                 AND EBELP  =  GT_ITAB-EBELP
                 AND PLUMI  = '2'
                 AND MBLNR  =  GT_ITAB-MBLNR
                 AND MJAHR  =  GT_ITAB-MJAHR.

                CASE LV_GUBUN.
                  WHEN 'C'.  "전선
                    PERFORM UPDATE_ZPPT0001_GI USING ZPPT0019-TAGNR
                                                     'N'.
                  WHEN 'B'.  "비전선
                    PERFORM UPDATE_ZPPT0211_GI USING ZPPT0019-TAGNR
                                                     'N'.
                ENDCASE.

                UPDATE ZPPT0019
                   SET MBLNR   = ' '
                       MJAHR   = ' '
                       MBLNR_F = ' '
                WHERE  EBELN   =  GT_ITAB-EBELN
                  AND  EBELP   =  GT_ITAB-EBELP
                  AND  PLUMI   = '2'
                  AND  TAGNR   =  ZPPT0019-TAGNR.
              ENDSELECT.
            ENDIF.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  MODIFY ZGTMMT9200 FROM TABLE GT_ITAB.
  IF SY-SUBRC = 0.
    COMMIT WORK AND WAIT.
  ENDIF.

*  PERFORM CONVERSION_OUTPUT.
  LT_OTAB[] = GT_OTAB[].

*- 처리 결과 MESSAGE 가공
  IF LT_OTAB[] IS NOT INITIAL.
    LOOP AT LT_OTAB.
      IF LT_OTAB-ZRESULT = GC_00. " SUCCESS
        LV_COUNT_S = LV_COUNT_S + 1.
      ELSEIF LT_OTAB-ZRESULT = GC_02. " FAIL
        LV_COUNT_E = LV_COUNT_E + 1.
      ENDIF.
    ENDLOOP.
    LV_MSG_S  = LV_COUNT_S.
    CONDENSE LV_MSG_S.

    LV_MSG_E = LV_COUNT_E.
    CONDENSE LV_MSG_E.

    IF LV_COUNT_S IS NOT INITIAL AND LV_COUNT_E IS INITIAL.
      LV_RESULT = GC_00. " SUCCESS
      CONCATENATE LV_MSG_S ' rows Success' INTO LV_MESSAGE.
    ELSEIF LV_COUNT_S IS INITIAL AND LV_COUNT_E IS NOT INITIAL.
      LV_RESULT = GC_02. " FAIL
      CONCATENATE LV_MSG_E ' rows Fail' INTO LV_MESSAGE.
    ELSE.
      LV_RESULT = GC_02. " FAIL
      CONCATENATE LV_MSG_S ' rows Success & ' LV_MSG_E ' rows Fail'
             INTO LV_MESSAGE SEPARATED BY SPACE.
    ENDIF.

    ZO_RESULT  = LV_RESULT.
    ZO_MESSAGE = LV_MESSAGE.
  ELSE.
    LV_RESULT  = GC_01. " Fail
    LV_MESSAGE = 'Transaction error'.
    ZO_RESULT  = LV_RESULT.
    ZO_MESSAGE = LV_MESSAGE.
  ENDIF.

ENDFUNCTION.
