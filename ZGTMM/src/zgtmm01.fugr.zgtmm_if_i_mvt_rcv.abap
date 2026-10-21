FUNCTION ZGTMM_IF_I_MVT_RCV.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR4
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_TAB STRUCTURE  ZGTMMSIF0015
*"      OT_TAB STRUCTURE  ZGTMMSIF0016
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_MVT_RCV
*& 프로그램 명 : 기타 이동 처리 정보 수신
*& 개요   : 기타 이동 처리 정보 수신용 RFC (From 지중MES)
*& 생성일 : 2024.11.13
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  : 2025.06.10
*& 수정자  : ZGSIDEV03
*& 수정개요: 구미 물자 창고 WMS 도입
*&---------------------------------------------------------------------*

  GV_SYSTEM_ID = I_SYSTEM_ID.
  PERFORM SET_COM_LOG USING 'S' 'MM00011' ' ' ' '.

  CLEAR : GT_I15[], GT_I16[].

  GT_I15[] = IT_TAB[].
  SORT GT_I15 BY IFNUM.

  PERFORM SET_911X_LOG.

  "제품 이동
  PERFORM RUN_MVT_RCV.

  OT_TAB[] = GT_I16[].

  PERFORM RTN_RST_MSG TABLES GT_I16.

  PERFORM SET_EAI_MSG USING GV_ZSTAT CHANGING ZO_RESULT
                                              ZO_MESSAGE.
* Export Parameter : 고정값
* ZO_RESULT  = '00'.
* ZO_MESSAGE = '전송 데이터 처리 성공'.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Form SET_911X_LOG
*&---------------------------------------------------------------------*
FORM SET_911X_LOG.

  DATA : LV_SEQ TYPE I.


  "수신 Data Log Table 저장

  CLEAR : GT_9110[], GT_9111[].

  LOOP AT GT_I15.
    GT_I15-MBLNR = |{ GT_I15-MBLNR ALPHA = IN }|.
    GT_I15-KONTO = |{ GT_I15-KONTO ALPHA = IN }|.
    GT_I15-KOSTL = |{ GT_I15-KOSTL ALPHA = IN }|.
    GT_I15-AUFNR = |{ GT_I15-AUFNR ALPHA = IN }|.
    GT_I15-KDAUF = |{ GT_I15-KDAUF ALPHA = IN }|.
    GT_I15-LIFNR = |{ GT_I15-LIFNR ALPHA = IN }|.
    GT_I15-KUNNR = |{ GT_I15-KUNNR ALPHA = IN }|.
    GT_I15-EBELN = |{ GT_I15-EBELN ALPHA = IN }|.

    PERFORM CONVERT_MATN1_INPUT USING GT_I15-MATNR.
    PERFORM CONVERT_MATN1_INPUT USING GT_I15-UMMAT.

    MODIFY GT_I15 TRANSPORTING MBLNR KONTO KOSTL AUFNR KDAUF
                               LIFNR KUNNR EBELN MATNR UMMAT.

*   CLEAR : GT_9110.
*   MOVE-CORRESPONDING GT_I15 TO GT_9110.
*   GT_9110-ZIFKEY = GT_9000-ZIFKEY.
*
*   APPEND GT_9110.
  ENDLOOP.

  GT_9110[] = VALUE #( FOR LS_I15 IN GT_I15
                       ( VALUE #( BASE CORRESPONDING #( LS_I15 )
                                  ZIFKEY = GT_9000-ZIFKEY ) ) ).

  MODIFY ZGTMMT9110 FROM TABLE GT_9110.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_MVT_RCV
*&---------------------------------------------------------------------*
FORM RUN_MVT_RCV.

  DATA : LV_GUBUN(1). "--> 전선/비전선 구분자

  LOOP AT GT_I15.
    MOVE-CORRESPONDING GT_I15 TO GS_I15.

    CASE GS_I15-FLAG.
      WHEN ' '.
        AT NEW IFNUM.
          CLEAR : GS_MHDR,   GS_MCOD,   GS_MHDRT,
                  GT_MITM[], GT_MSRN[], GT_RTN[].

          PERFORM SET_MVT_GMCD.
          PERFORM SET_MVT_HEAD.
        ENDAT.

        IF GS_I15-TAGNR IS NOT INITIAL.
*&---------------------------------------------------------------------*
          "한국미래소재(KFCM)의 경우 꼬리표 사용안함 - [s]
*&---------------------------------------------------------------------*
*          SELECT SINGLE MANDT
*            FROM ZPPT0001 INTO SY-MANDT
*           WHERE WERKS = GS_I15-WERKS
*             AND TAGNR = GS_I15-TAGNR.
*
*          IF SY-SUBRC <> 0.
*            PERFORM RTN_MVT_RCV USING 'E' '꼬리표 정보가 없습니다.'(M07).
*            CONTINUE.
*          ENDIF.
          CASE GV_SYSTEM_ID.
            WHEN 'KFCM'.

            WHEN OTHERS.
              SELECT SINGLE MANDT
                FROM ZPPT0001 INTO SY-MANDT
               WHERE WERKS = GS_I15-WERKS
                 AND TAGNR = GS_I15-TAGNR.

              IF SY-SUBRC <> 0.
                PERFORM RTN_MVT_RCV USING 'E' '꼬리표 정보가 없습니다.'(M07).
                CONTINUE.
              ENDIF.
          ENDCASE.
*&---------------------------------------------------------------------*
           "한국미래소재(KFCM)의 경우 꼬리표 사용안함 - [e]
*&---------------------------------------------------------------------*
        ENDIF.

        PERFORM SET_MVT_ITEM.

        AT END OF IFNUM.
          PERFORM BAPI_GOODSMVT_CREATE.

          IF GS_MHDRT IS NOT INITIAL.

*&---------------------------------------------------------------------*
          "한국미래소재(KFCM)의 경우 꼬리표 사용안함 - [s]
*&---------------------------------------------------------------------*
*            UPDATE ZPPT0001 SET LGORT = GS_I15-R_LGORT
*                          WHERE WERKS = GS_I15-WERKS
*                            AND TAGNR = GS_I15-TAGNR.
            CASE GV_SYSTEM_ID.
              WHEN 'KFCM'.

              WHEN OTHERS.
                UPDATE ZPPT0001 SET LGORT = GS_I15-R_LGORT
                              WHERE WERKS = GS_I15-WERKS
                                AND TAGNR = GS_I15-TAGNR.
            ENDCASE.

*&---------------------------------------------------------------------*
          "한국미래소재(KFCM)의 경우 꼬리표 사용안함 - [e]
*&---------------------------------------------------------------------*

            PERFORM BAPI_COMMIT.
            PERFORM RTN_MVT_RCV USING 'SN' '재고이전 성공'(M08).

*--> 소재 MOM 사내거래출고 꼬리표 반영
            IF GV_SYSTEM_ID = 'KSCM'.
              IF GS_I15-BWART = '351'.
                LOOP AT GT_I15 WHERE IFNUM = GS_I15-IFNUM.
                  IF GT_I15-TAGNR IS NOT INITIAL.
                    PERFORM MODIFY_ZPPT0019_SCR.

                    CLEAR : LV_GUBUN.
                    SELECT SINGLE B~GUBUN
                      INTO LV_GUBUN
                      FROM MARC AS A
                           INNER JOIN ZPPT0134 AS B
                            ON A~WERKS = B~WERKS
                            AND A~DISPO = B~DISPO
                     WHERE B~WERKS = GT_I15-WERKS
                       AND A~MATNR = GT_I15-MATNR.

                    IF SY-SUBRC = 0.
                      CASE LV_GUBUN.
                        WHEN 'C'. "--> 전선
                          PERFORM UPDATE_ZPPT0001_GI USING  GT_I15-MATNR
                                                            GT_I15-WERKS
                                                            GT_I15-R_WERKS
                                                            GT_I15-TAGNR
                                                            GT_I15-EBELN
                                                            'Y'.
                        WHEN 'B'. "--> 비전선
                          PERFORM UPDATE_ZPPT0211_GI USING  GT_I15-MATNR
                                                            GT_I15-WERKS
                                                            GT_I15-R_WERKS
                                                            GT_I15-TAGNR
                                                            GT_I15-EBELN
                                                            'Y'.
                      ENDCASE.
                    ENDIF.
                  ENDIF.
                ENDLOOP.
              ENDIF.
            ENDIF.
*<-- 소재 MOM 사내거래출고 꼬리표 반영

          ELSE. "수행 실패 시
            PERFORM BAPI_ROLLBACK.

            READ TABLE GT_RTN WITH KEY TYPE = 'E'.
            PERFORM RTN_MVT_RCV USING 'EN' GT_RTN-MESSAGE.
          ENDIF.
        ENDAT.

      WHEN 'D'.
        PERFORM BAPI_GOODSMVT_CANCEL USING GS_I15-MBLNR
                                           GS_I15-MJAHR
                                           GS_I15-BUDAT.

        IF GS_MHDRT IS NOT INITIAL.
          PERFORM BAPI_COMMIT.
          PERFORM RTN_MVT_RCV USING 'SC' '재고이전 취소 성공'(M09).
*--> 소재 MOM 사내거래출고 꼬리표 반영
          IF GV_SYSTEM_ID = 'KSCM'.
            IF GS_I15-BWART = '351'.
              PERFORM MODIFY_ZPPT0001_GIREV USING GS_I15-MBLNR
                                                  GS_I15-MJAHR.
            ENDIF.
          ENDIF.
*<-- 소재 MOM 사내거래출고 꼬리표 반영
        ELSE.
          PERFORM BAPI_ROLLBACK.

          READ TABLE GT_RTN WITH KEY TYPE = 'E'.
          PERFORM RTN_MVT_RCV USING 'EC' GT_RTN-MESSAGE.
        ENDIF.

    ENDCASE.
  ENDLOOP.

  CHECK GT_9111[] IS NOT INITIAL.
  MODIFY ZGTMMT9111 FROM TABLE GT_9111.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RTN_MVT_RCV
*&---------------------------------------------------------------------*
FORM RTN_MVT_RCV USING PV_RST
                       PV_MSG.

  CLEAR : GT_I16, GT_9111.

  CASE PV_RST.
    WHEN 'SN'.
      GT_I16-MBLNR   = GS_MHDRT-MAT_DOC.  "자재문서번호
      GT_I16-MJAHR   = GS_MHDRT-DOC_YEAR. "자재전표연도

    WHEN 'SC'.
      GT_I16-MBLNR   = GS_I15-MBLNR.
      GT_I16-MJAHR   = GS_I15-MJAHR.
      GT_I16-MBLNR_C = GS_MHDRT-MAT_DOC.
      GT_I16-MJAHR_C = GS_MHDRT-DOC_YEAR.

    WHEN 'EN'.


    WHEN 'EC'.
      GT_I16-MBLNR   = GS_I15-MBLNR.
      GT_I16-MJAHR   = GS_I15-MJAHR.

  ENDCASE.

  GT_I16-IFNUM   = GS_I15-IFNUM.
  GT_I16-ZRESULT = PV_RST+0(1).
  GT_I16-MESSAGE = PV_MSG.
  GT_I16-TAGNR   = GS_I15-TAGNR. "확인?

  "Log table
  MOVE-CORRESPONDING GT_I16 TO GT_9111.
  GT_9111-ZIFKEY = GT_9000-ZIFKEY.

  GT_I16-MBLNR   = |{ GT_I16-MBLNR   ALPHA = OUT }|.
  GT_I16-MBLNR_C = |{ GT_I16-MBLNR_C ALPHA = OUT }|.

  APPEND : GT_I16, GT_9111.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MVT_GMCD
*&---------------------------------------------------------------------*
FORM SET_MVT_GMCD.

  "MES 사용 이동 유형 (911,912,917,543,544)

  "기타입출고(MB1C) GM_Code 05: Other goods receipt
  IF GS_I15-BWART = '511' OR GS_I15-BWART = '512'
  OR GS_I15-BWART = '531' OR GS_I15-BWART = '532'
  OR GS_I15-BWART = 'Z21' OR GS_I15-BWART = 'Z22'.
    GS_MCOD-GM_CODE = '05'. "Other goods receipt

    "기타입출고(MB1A) GM_Code 03: Goods issue
  ELSEIF GS_I15-BWART = '931' OR GS_I15-BWART = '932'
      OR GS_I15-BWART = '933' OR GS_I15-BWART = '934'
      OR GS_I15-BWART = '935' OR GS_I15-BWART = '936'
      OR GS_I15-BWART = '937' OR GS_I15-BWART = '938'
      OR GS_I15-BWART = '939' OR GS_I15-BWART = '940'
      OR GS_I15-BWART = '943' OR GS_I15-BWART = '944'
      OR GS_I15-BWART = 'Z71' OR GS_I15-BWART = 'Z72'
      OR GS_I15-BWART = 'Z81' OR GS_I15-BWART = 'Z82'
*(S)구미 물자 창고 WMS 도입(SJM 25.06.10)
      OR GS_I15-BWART = '201' OR GS_I15-BWART = 'Z95' OR GS_I15-BWART = 'Z96'
*(E)구미 물자 창고 WMS 도입(SJM 25.06.10)
*--> 소재 MOM 이동유형 추가
      OR GS_I15-BWART = '951' OR GS_I15-BWART = '953'.
*<-- 소재 MOM 이동유형 추가
    GS_MCOD-GM_CODE = '03'. "Goods issue

  ELSEIF GS_I15-BWART = '544' OR GS_I15-BWART = '543'
      OR GS_I15-BWART = '121'.
    GS_MCOD-GM_CODE = '07'. "Subsequent adjustment with regard to a subcontract order

    "자재이동(MB1B) GM_Code 04: Transfer posting
  ELSE.
    GS_MCOD-GM_CODE = '04'. "Transfer posting
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MVT_HEAD
*&---------------------------------------------------------------------*
FORM SET_MVT_HEAD.

  GS_MHDR-PSTNG_DATE = GS_I15-BUDAT. "전표 생성일
  GS_MHDR-DOC_DATE   = GS_I15-BLDAT. "전표 증빙일
  GS_MHDR-HEADER_TXT = GS_I15-BKTXT. "전표 헤더 텍스트

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MVT_ITEM
*&---------------------------------------------------------------------*
FORM SET_MVT_ITEM.

  CLEAR : GT_MITM.

  GT_MITM-MATERIAL       = GS_I15-MATNR.    "자재번호
  GT_MITM-PLANT          = GS_I15-WERKS.    "플랜트
  GT_MITM-STGE_LOC       = GS_I15-LGORT.    "저장위치
  GT_MITM-BATCH          = GS_I15-CHARG.    "배치
  GT_MITM-MOVE_TYPE      = GS_I15-BWART.    "이동유형
  GT_MITM-ENTRY_QNT      = GS_I15-ERFMG.    "소요량
  GT_MITM-ENTRY_UOM      = GS_I15-ERFME.    "입력단위
  GT_MITM-MOVE_PLANT     = GS_I15-R_WERKS.  "이동할 플랜트
  GT_MITM-MOVE_STLOC     = GS_I15-R_LGORT.  "이동할 저장위치
  GT_MITM-MOVE_BATCH     = GS_I15-UMCHA.    "입고/출고 배치
  GT_MITM-VENDOR         = GS_I15-LIFNR.    "구매처
  GT_MITM-CUSTOMER       = GS_I15-KUNNR.    "고객번호
  GT_MITM-SALES_ORD      = GS_I15-KDAUF.    "판매오더번호
  GT_MITM-VAL_SALES_ORD  = GS_I15-KDAUF.    "판매오더번호
  GT_MITM-S_ORD_ITEM     = GS_I15-KDPOS.    "판매오더 품목번호
  GT_MITM-VAL_S_ORD_ITEM = GS_I15-KDPOS.    "판매오더 품목번호
  GT_MITM-ITEM_TEXT      = GS_I15-SGTXT.    "품목텍스트
  GT_MITM-GL_ACCOUNT     = GS_I15-KONTO.    "G/L계정
  GT_MITM-COSTCENTER     = GS_I15-KOSTL.    "코스트센터
  GT_MITM-WBS_ELEM       = GS_I15-PS_POSID. "작업분석구조요소
  GT_MITM-MOVE_MAT       = GS_I15-UMMAT.    "입고/출고 자재
  GT_MITM-PO_NUMBER      = GS_I15-EBELN.
  GT_MITM-PO_ITEM        = GS_I15-EBELP.

  CASE GS_I15-BWART.
    WHEN '121'.
      GT_MITM-SPEC_STOCK = '1'.
      GT_MITM-MVT_IND    = 'O'.
      GT_MITM-LINE_ID    = '000001'.

      PERFORM GET_MVT_MSEG USING '101'.

    WHEN '543' OR '544'.
      GT_MITM-SPEC_STOCK = 'O'.
      GT_MITM-MVT_IND    = 'W'.
      GT_MITM-LINE_ID    = '000002'.
      GT_MITM-PARENT_ID  = '000001'.
      GT_MITM-LINE_DEPTH = '01'.

      IF GS_I15-BWART = '544'.
        PERFORM GET_MVT_MSEG USING '543'.
      ENDIF.

    WHEN '311' OR '312'.
      IF GS_I15-KDAUF IS NOT INITIAL.
        GT_MITM-SPEC_STOCK = 'E'.
      ENDIF.

*--> 소재 MOM 이동유형 추가
**** 신규 RFC로 처리
*    WHEN '951' OR '953'.
*      GT_MITM-ORDERID = GS_I15-AUFNR.
*      SELECT SINGLE PRCTR
*        INTO GT_MITM-PROFIT_CTR
*        FROM COAS
*       WHERE AUFNR = GS_I15-AUFNR.
*<-- 소재 MOM 이동유형 추가

  ENDCASE.

  APPEND GT_MITM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MVT_MSEG
*&---------------------------------------------------------------------*
FORM GET_MVT_MSEG USING PV_BWART.

  SELECT SINGLE MBLNR MJAHR ZEILE
    FROM MSEG
    INTO (GT_MITM-REF_DOC,
          GT_MITM-REF_DOC_YR,
          GT_MITM-REF_DOC_IT)
   WHERE EBELN = GS_I15-EBELN
     AND EBELP = GS_I15-EBELP
     AND BWART = PV_BWART
     AND CHARG = GS_I15-CHARG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MVT_MSEG
*&---------------------------------------------------------------------*
FORM MODIFY_ZPPT0019_SCR.

  SELECT COUNT(*)
    FROM ZPPT0019
   WHERE EBELN   =  GT_I15-EBELN
     AND EBELP   =  GT_I15-EBELP
     AND PLUMI   = '2' "-->출고
     AND TAGNR   =  GT_I15-TAGNR.

  IF SY-DBCNT > 0.
    UPDATE ZPPT0019
       SET MBLNR   =  GS_MHDRT-MAT_DOC
           MJAHR   =  GS_MHDRT-DOC_YEAR
           MBLNR_F = 'X'
     WHERE EBELN   =  GT_I15-EBELN
       AND EBELP   =  GT_I15-EBELP
       AND PLUMI   = '2' "-->출고
       AND TAGNR   =  GT_I15-TAGNR.
  ELSE.
    CLEAR : ZPPT0019.
    MOVE-CORRESPONDING GT_I15 TO ZPPT0019.
    ZPPT0019-PLUMI      = '2'.
    ZPPT0019-RESWK      = GT_I15-R_WERKS.
    ZPPT0019-ENMNG      = GT_I15-ERFMG.
    ZPPT0019-MEINS      = GT_I15-ERFME.
    ZPPT0019-MBLNR      = GS_MHDRT-MAT_DOC.
    ZPPT0019-MJAHR      = GS_MHDRT-DOC_YEAR.
    ZPPT0019-MBLNR_F    = 'X'.
    ZPPT0019-ERDAT      = SY-DATLO.
    ZPPT0019-ERTIM      = SY-TIMLO.
    ZPPT0019-ERNAM      = SY-UNAME.

    SELECT SINGLE MENGE
      INTO ZPPT0019-BSTMG
      FROM EKPO
     WHERE EBELN = GT_I15-EBELN
       AND EBELP = GT_I15-EBELP.

    INSERT ZPPT0019.
  ENDIF.
  COMMIT WORK AND WAIT.

ENDFORM.
