FUNCTION ZGTMM_IF_I_GR_RCV.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR4
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_HEAD STRUCTURE  ZGTMMSIF0012
*"      IT_ITEM STRUCTURE  ZGTMMSIF0014
*"      OT_HEAD STRUCTURE  ZGTMMSIF0018
*"      OT_ITEM STRUCTURE  ZGTMMSIF0020 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_GR_RCV
*& 프로그램 명 : 구매 입고 처리 정보 수신
*& 개요   : 구매 입고 처리 정보 수신용 RFC (From 지중MES)
*& 생성일 : 2024.11.12
*& 생성자 : ZGSIDEV03
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  : 2025.06.10
*& 수정자  : ZGSIDEV03
*& 수정개요: 구미 물자 창고 WMS 도입
*&---------------------------------------------------------------------*

  GV_SYSTEM_ID = I_SYSTEM_ID.
  PERFORM SET_COM_LOG USING 'S' 'MM00009' ' ' ' '.

  CLEAR : GT_I12[], GT_I14[], GT_I18[], GT_I20[].

  GT_I12[] = IT_HEAD[].
  GT_I14[] = IT_ITEM[].
  SORT GT_I12 BY VBELN.
  SORT GT_I14 BY VBELN POSNR EBELN EBELP.

  PERFORM SET_909X_LOG.

  "입고 처리
  PERFORM RUN_GR_RCV.


* [S] CHM2608-00082 - EAI 세션중단 시, 중복입고처리 방지(1305 WERKS 한정)  (2026.08.06 / 박우진)
  IF GT_DUPLICATE[] IS NOT INITIAL.   "1305 Plant Duplicate 전용
    LOOP AT GT_DUPLICATE INTO GS_DUPLICATE.
      APPEND CORRESPONDING #( GS_DUPLICATE ) TO GT_I18[].
    ENDLOOP.
  ENDIF.
* [E] CHM2608-00082 - EAI 세션중단 시, 중복입고처리 방지(1305 WERKS 한정)  (2026.08.06 / 박우진)

  OT_HEAD[] = GT_I18[].
  OT_ITEM[] = GT_I20[]. "추가(SJM 25.06.10)

  " Return Message Formation.
  PERFORM RTN_RST_MSG TABLES GT_I18.

  PERFORM SET_EAI_MSG USING GV_ZSTAT CHANGING ZO_RESULT
                                              ZO_MESSAGE.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Form SET_909X_LOG
*&---------------------------------------------------------------------*
FORM SET_909X_LOG.

  DATA : LV_SEQ TYPE I.


  "수신 Data Log Table 저장

  CLEAR : GT_9090[], GT_9091[], GT_9092[].

  LOOP AT GT_I12.
    GT_I12-VBELN = |{ GT_I12-VBELN ALPHA = IN }|.
    GT_I12-LIFNR = |{ GT_I12-LIFNR ALPHA = IN }|.
    MODIFY GT_I12 TRANSPORTING VBELN LIFNR.

    CLEAR : GT_9090.
    MOVE-CORRESPONDING GT_I12 TO GT_9090.
    GT_9090-ZIFKEY = GT_9000-ZIFKEY.

    APPEND GT_9090.
  ENDLOOP.

  LOOP AT GT_I14.
    GT_I14-VBELN = |{ GT_I14-VBELN ALPHA = IN }|.
    GT_I14-EBELN = |{ GT_I14-EBELN ALPHA = IN }|.
    PERFORM CONVERT_MATN1_INPUT USING GT_I14-MATNR.
    MODIFY GT_I14 TRANSPORTING VBELN EBELN MATNR.

    LV_SEQ += 1.

    CLEAR : GT_9091.
    MOVE-CORRESPONDING GT_I14 TO GT_9091.
    GT_9091-ZIFKEY = GT_9000-ZIFKEY.
    GT_9091-SEQNO     = LV_SEQ.
    CONDENSE GT_9091-SEQNO.

    APPEND GT_9091.
  ENDLOOP.

  MODIFY ZGTMMT9091 FROM TABLE GT_9091.  "GR Item Info
  MODIFY ZGTMMT9090 FROM TABLE GT_9090.  "GR Header Info

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_GR_RCV
*&---------------------------------------------------------------------*
FORM RUN_GR_RCV.

  CLEAR: GT_DUPLICATE.

  LOOP AT GT_I12.
    "Header
    PERFORM SET_CGR_HEAD. "FILL_GR_BAPI_HEADER.

    "Item
    CLEAR : GV_LINEID, GT_T20[].
    READ TABLE GT_I14 WITH KEY VBELN = GT_I12-VBELN
                               BINARY SEARCH.

    IF SY-SUBRC = 0.
      LOOP AT GT_I14 FROM SY-TABIX.
        IF GT_I14-VBELN <> GT_I12-VBELN.
          EXIT.
        ENDIF.

* [S] CHM2608-00082  (2026.08.06 / 박우진)
* EAI 세션중단 시, 중복입고처리 방지(1305 WERKS 한정)
        IF GT_I14-WERKS EQ '1305' AND GT_I14-LOTNO IS NOT INITIAL.
          CLEAR: GS_DUPLICATE.

          SELECT A~MBLNR, A~MJAHR
            FROM       MSEG       AS A
            INNER JOIN ZGTMMT9091 AS B
              ON  A~EBELN = B~EBELN
              AND A~EBELP = B~EBELP
              AND A~WERKS = B~WERKS
              AND A~MATNR = B~MATNR
              AND A~SGTXT = B~LOTNO
           WHERE B~EBELN = @GT_I14-EBELN
             AND B~EBELP = @GT_I14-EBELP
             AND B~WERKS = @GT_I14-WERKS
             AND B~MATNR = @GT_I14-MATNR
             AND B~LOTNO = @GT_I14-LOTNO
           ORDER BY A~MJAHR DESCENDING, A~MBLNR DESCENDING
            INTO TABLE @DATA(LT_DUP)
            UP TO 1 ROWS.

          IF LT_DUP IS NOT INITIAL.
            GS_DUPLICATE-MBLNR = LT_DUP[ 1 ]-MBLNR.
            GS_DUPLICATE-MJAHR = LT_DUP[ 1 ]-MJAHR.
            GS_DUPLICATE-ZRESULT = GC_S.
          ENDIF.

          IF SY-SUBRC EQ 0.
            GS_DUPLICATE-ZRESULT = GC_S.
            GS_DUPLICATE-MESSAGE = 'Duplicate Attempt notified'.
            APPEND GS_DUPLICATE TO GT_DUPLICATE.
            CONTINUE.
          ENDIF.

        ENDIF.
* [E] CHM2608-00082- EAI 세션중단 시, 중복입고처리 방지(1305 WERKS 한정)  (2026.08.06 / 박우진)

        GV_LINEID += 1.
        PERFORM SET_GR_ITEM. "FILL_GR_BAPI_ITEM.
        PERFORM SET_XGR_LOT TABLES GT_T20 "추가(SJM 25.06.10).
                             USING GT_I14
                                   GV_LINEID.

        "배치 및 특성업데이트
        IF GT_I14-CHARG IS NOT INITIAL.
          PERFORM CREATE_CGR_BATCH USING GT_I14. "INPUT_BATCH_ALLOCATION USING PV_ERROR 'X'.
        ENDIF.
      ENDLOOP.
    ENDIF.

    CHECK GT_MITM[] IS NOT INITIAL.     "박우진 추가(2026.08.06).
    PERFORM GOODSMVT_CGR_RCV TABLES GT_9092
                             USING 'N'.
  ENDLOOP.

  CHECK GT_9092[] IS NOT INITIAL.
  MODIFY ZGTMMT9092 FROM TABLE GT_9092.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GR_ITEM
*&---------------------------------------------------------------------*
FORM SET_GR_ITEM.

  CLEAR : GT_MITM.

  GT_MITM-MATERIAL   = GT_I14-MATNR. "자재
  GT_MITM-PLANT      = GT_I14-WERKS. "플랜트
  GT_MITM-STGE_LOC   = GT_I14-LGORT. "저장위치
  GT_MITM-PO_NUMBER  = GT_I14-EBELN. "구매오더
  GT_MITM-PO_ITEM    = GT_I14-EBELP. "품목번호
  GT_MITM-MVT_IND    = 'B'.          "Delivery에 대한 자재이동
  GT_MITM-MOVE_TYPE  = '101'.        "이동유형
  GT_MITM-BATCH      = GT_I14-CHARG. "입고배치
  GT_MITM-ENTRY_QNT  = GT_I14-LFIMG. "입고수량
  GT_MITM-ENTRY_UOM  = GT_I14-MEINS. "단위
  GT_MITM-ITEM_TEXT  = GT_I14-LOTNO. "MES LOT No
  GT_MITM-LINE_ID    = GV_LINEID.    "고유식별ID
  GT_MITM-PARENT_ID  = '000000'.     "상위ID
  GT_MITM-VENDRBATCH = GT_I14-TAGNR. "꼬리표 번호
  GT_MITM-PROD_DATE  = GT_I14-HSDAT. "제조일

  IF GT_I14-VBELN <> GT_I14-EBELN.
    GT_MITM-DELIV_NUMB           = GT_I14-VBELN. "납품문서번호
    GT_MITM-DELIV_NUMB_TO_SEARCH = GT_I14-VBELN. "납품문서번호
    GT_MITM-DELIV_ITEM           = GT_I14-POSNR. "납품문서 품목
    GT_MITM-DELIV_ITEM_TO_SEARCH = GT_I14-POSNR. "납품문서 품목
  ENDIF.

  APPEND GT_MITM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_ZPPT0001_GR
*&---------------------------------------------------------------------*
FORM MODIFY_ZPPT0001_GR.

  DATA : LV_CHECK,
         GV_AUFNR    LIKE ZPPT0001-AUFNR,
         GS_ZPPT0001 LIKE ZPPT0001.
  CLEAR: LV_CHECK, GV_AUFNR, GS_ZPPT0001.

  DATA : LS_MSEG    TYPE MSEG.

  DATA(LT_ITEM) = GT_I14[].

  SELECT B~VBELN,
         B~POSNR,
         B~VGBEL AS EBELN,
         B~VGPOS AS EBELP,
         B~MATNR,
         C~LFIMG,
         C~MEINS,
         B~LICHN,
         C~CHARG,
         C~LGORT,
         B~WERKS,
         A~LIFNR,
         A~LFDAT,
         B~UECHA,
         C~TAGNR
    FROM LIKP AS A INNER JOIN LIPS AS B
      ON A~VBELN = B~VBELN
   INNER JOIN @LT_ITEM AS C
      ON B~VBELN = C~VBELN
     AND B~POSNR = C~POSNR
   WHERE B~PSTYV = 'ELN'
     AND B~WERKS = '1302' "'1404' "확인!
     AND B~XCHPF = 'X'
     AND A~VBELN = @GT_I12-VBELN
     AND C~CHARG IS NOT INITIAL
    INTO TABLE @DATA(LT_DELIV).

  IF SY-SUBRC <> 0.
    SELECT A~VBELN,
           A~POSNR,
           A~EBELN,
           A~EBELP,
           A~MATNR,
           C~LFIMG,
           A~MEINS,
           A~LICHN,
           C~CHARG,
           C~LGORT,
           A~WERKS,
           A~LIFNR,
           A~LFDAT,
           A~POSNR AS UECHA,
           C~TAGNR
      FROM ZMMTI26 AS A INNER JOIN EKPO AS B
        ON A~EBELN = B~EBELN
       AND A~EBELP = B~EBELP
     INNER JOIN @LT_ITEM AS C
        ON A~VBELN = C~VBELN
       AND A~POSNR = C~POSNR
     WHERE B~WERKS = '1302' "'1404' "확인!
       AND A~VBELN = @GT_I12-VBELN
       AND C~CHARG IS NOT INITIAL
      INTO CORRESPONDING FIELDS OF TABLE @LT_DELIV.
  ENDIF.

*  DATA(LT_UECHA) = LT_DELIV.
*  SORT LT_UECHA BY VBELN UECHA.
*  DELETE ADJACENT DUPLICATES FROM LT_UECHA COMPARING VBELN UECHA.
*
*
*  IF LV_CHECK = 'X' AND PV_BDC = 'X'.
*    CLEAR : GT_BDCDATA, GT_BDCDATA[], GT_MESSAGE, GT_MESSAGE[].
*
*    PERFORM BDC_INPUT USING :
*    'SAPMV50A' '4104' 'X' 'LIKP-VBELN' GT_I12-VBELN,
*    '        ' '    ' ' ' 'BDC_OKCODE' '=ENT2',
*
*    'SAPMV50A' '1000' 'X' 'BDC_OKCODE' '=POPO_T'.
*
*    LOOP AT LT_UECHA INTO DATA(LS_UECHA).
*      PERFORM BDC_INPUT USING :
*      'SAPMV50A' '0111' 'X' 'RV50A-POSNR' LS_UECHA-UECHA,
*      '        ' '    ' ' ' 'BDC_OKCODE'  '=WEIT',
*
*      'SAPMV50A' '1000' 'X' 'BDC_OKCODE' '=MKAL_T',
*
*      'SAPMV50A' '1000' 'X' 'BDC_OKCODE' '=CHSP_T'.
*
*      LOOP AT LT_DELIV INTO DATA(LS_DELIV) WHERE UECHA = LS_UECHA-UECHA.
*        PERFORM BDC_INPUT USING :
*        'SAPMV50A' '3000' 'X' 'BDC_OKCODE' '=POPO_T',
*
*        'SAPMV50A' '0111' 'X' 'RV50A-POSNR' LS_DELIV-POSNR,
*        '        ' '    ' ' ' 'BDC_OKCODE'  '=WEIT',
*
*        'SAPMV50A' '3000' 'X' 'LIPS-CHARG(01)' LS_DELIV-CHARG,
*        '        ' '    ' ' ' 'BDC_OKCODE'     '/00'.
*      ENDLOOP.
*
*      PERFORM BDC_INPUT USING :
*      'SAPMV50A' '3000' 'X' 'BDC_OKCODE' '=BACK_T'.
*    ENDLOOP.
*
*    PERFORM BDC_INPUT USING :
*    'SAPMV50A' '1000' 'X' 'BDC_OKCODE' '=SICH_T'.
*
*    PERFORM FILL_CTU_PARAMS USING 'N'.
*    CALL TRANSACTION 'VL32N' USING GT_BDCDATA
*                             OPTIONS FROM GS_PARAMS
*                             MESSAGES INTO GT_MESSAGE.
*  ENDIF.


  LOOP AT LT_DELIV INTO DATA(LS_DELIV) WHERE TAGNR IS NOT INITIAL.
    CLEAR : GV_AUFNR, GS_MSEG.
    GV_AUFNR = |{ LS_DELIV-EBELN ALPHA = IN }|.

    PERFORM GET_DISPO USING LS_DELIV-WERKS
                            LS_DELIV-MATNR.

    "저장위치 누락 방지
    IF LS_DELIV-LGORT IS INITIAL.
      SELECT SINGLE LGORT
        FROM LIPS INTO LS_DELIV-LGORT
       WHERE VBELN = LS_DELIV-VBELN
         AND POSNR = LS_DELIV-POSNR.
    ENDIF.

    "단위환산 정보(자재전표로 가져오기)
    IF LS_DELIV-CHARG IS INITIAL.
      SELECT SINGLE MENGE MEINS
        FROM MSEG
        INTO CORRESPONDING FIELDS OF GS_MSEG
       WHERE MBLNR = GS_MHDRT-MAT_DOC
         AND MJAHR = GS_MHDRT-DOC_YEAR
         AND EBELN = LS_DELIV-EBELN
         AND EBELP = LS_DELIV-EBELP.
    ELSE.
      SELECT SINGLE MENGE MEINS
        FROM MSEG
        INTO CORRESPONDING FIELDS OF GS_MSEG
       WHERE MBLNR = GS_MHDRT-MAT_DOC
         AND MJAHR = GS_MHDRT-DOC_YEAR
         AND EBELN = LS_DELIV-EBELN
         AND EBELP = LS_DELIV-EBELP
         AND CHARG = LS_DELIV-CHARG.
    ENDIF.

    SELECT SINGLE MANDT
      FROM ZPPT0001 INTO @SY-MANDT
     WHERE WERKS = @LS_DELIV-WERKS
       AND AUFNR = @GV_AUFNR
       AND TAGNR = @LS_DELIV-LICHN.

    IF SY-SUBRC = 0.
      UPDATE ZPPT0001 SET MGVRG  = GS_MSEG-MENGE
                          REMAIN = GS_MSEG-MENGE
                          LGORT  = LS_DELIV-LGORT
                          MBLNR  = GS_MHDRT-MAT_DOC
                          CHARG  = LS_DELIV-CHARG
                          GRFLG  = 'Y'
                    WHERE WERKS  = LS_DELIV-WERKS
                      AND AUFNR  = GV_AUFNR
                      AND TAGNR  = LS_DELIV-LICHN.

      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.

      PERFORM MODIFY_ZPPT0019.

    ELSE.
      CLEAR : GS_ZPPT0001.

      GS_ZPPT0001-WERKS = LS_DELIV-WERKS.
      GS_ZPPT0001-AUFNR = GV_AUFNR.
      GS_ZPPT0001-TAGNR = LS_DELIV-TAGNR.
      GS_ZPPT0001-RUECK = LS_DELIV-VBELN.
      GS_ZPPT0001-RMZHL = LS_DELIV-POSNR.
      GS_ZPPT0001-POSNR = LS_DELIV-EBELP.
      GS_ZPPT0001-CHARG = LS_DELIV-CHARG.
      GS_ZPPT0001-MATNR = LS_DELIV-MATNR.
      GS_ZPPT0001-MBLNR = GS_MHDRT-MAT_DOC.
      GS_ZPPT0001-MGVRG = GS_MSEG-MENGE.
      GS_ZPPT0001-REMAIN = GS_MSEG-MENGE.
      GS_ZPPT0001-LGORT  = LS_DELIV-LGORT.
      GS_ZPPT0001-MEINS  = GS_MSEG-MEINS.
      GS_ZPPT0001-SPGCD  = GV_DISPO+0(2).
      GS_ZPPT0001-FOSTCNT = '1'.
      GS_ZPPT0001-OUTFLG  = 'X'.
      GS_ZPPT0001-GIFLG   = 'N'.
      GS_ZPPT0001-GRFLG   = 'Y'.
      GS_ZPPT0001-INSPFLG = 'OK'.
      GS_ZPPT0001-WKDAT   = SY-DATUM.
      GS_ZPPT0001-GRINDAT = SY-DATUM.
      GS_ZPPT0001-GRINTIM = SY-UZEIT.
      GS_ZPPT0001-GRINNAM = SY-UNAME.

      MODIFY ZPPT0001 FROM GS_ZPPT0001.

      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.

      PERFORM MODIFY_ZPPT0019.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_ZPPT0019
*&---------------------------------------------------------------------*
FORM MODIFY_ZPPT0019.

  DATA : LT_ZPPT0019 LIKE TABLE OF ZPPT0019.


  READ TABLE GT_I14 WITH KEY VBELN = GT_I12-VBELN
                             BINARY SEARCH.

  CHECK SY-SUBRC = 0.

  LOOP AT GT_I14 FROM SY-TABIX.
    IF GT_I14-VBELN <> GT_I12-VBELN.
      EXIT.
    ENDIF.

    "사내이체의 경우에 꼬리표 로직 적용
    SELECT SINGLE BSART INTO @DATA(LV_BSART)
      FROM EKKO
     WHERE EBELN = @GT_I14-EBELN
       AND BSART = 'UB'.

    IF SY-SUBRC = 0.
      SELECT SINGLE MANDT INTO @SY-MANDT
        FROM ZPPT0019
       WHERE EBELN = @GT_I14-EBELN
         AND EBELP = @GT_I14-EBELP
         AND PLUMI = '1'
         AND TAGNR = @GT_I14-TAGNR.

      IF SY-SUBRC = 0.
        UPDATE ZPPT0019 SET MBLNR   = GS_MHDRT-MAT_DOC
                            MJAHR   = GS_MHDRT-DOC_YEAR
                            MBLNR_F = 'X'
                      WHERE EBELN   = GT_I14-EBELN
                        AND EBELP   = GT_I14-EBELP
                        AND PLUMI   = '1'
                        AND TAGNR   = GT_I14-TAGNR.

      ELSE.
        SELECT SINGLE RESWK
          FROM EKKO INTO @DATA(LV_RESWK)
         WHERE EBELN = @GT_I14-EBELN.

        "구매오더 수량 발췌
        SELECT SINGLE MENGE
          FROM EKPO INTO @DATA(LV_MENGE)
         WHERE EBELN = @GT_I14-EBELN
           AND EBELP = @GT_I14-EBELP.

        LT_ZPPT0019 = VALUE #( BASE LT_ZPPT0019
                               ( EBELN   = GT_I14-EBELN
                                 EBELP   = GT_I14-EBELP
                                 PLUMI   = '1'
                                 TAGNR   = GT_I14-TAGNR
                                 WERKS   = GT_I14-WERKS
                                 RESWK   = LV_RESWK
                                 MATNR   = GT_I14-MATNR
                                 LGORT   = GT_I14-LGORT
                                 BSTMG   = LV_MENGE
                                 ENMNG   = GT_I14-LFIMG
                                 MEINS   = GT_I14-MEINS
                                 CHARG   = GT_I14-CHARG
                                 MBLNR   = GS_MHDRT-MAT_DOC
                                 MJAHR   = GS_MHDRT-DOC_YEAR
                                 MBLNR_F = 'X'
                                 ERDAT   = SY-DATUM
                                 ERTIM   = SY-UZEIT
                                 ERNAM   = SY-UNAME ) ).

      ENDIF.

      UPDATE ZPPT0001 SET GRFLG = 'Y'
                          CHARG = GT_I14-CHARG
                          LGORT = GT_I14-LGORT
                          MBLNR = GS_MHDRT-MAT_DOC
                    WHERE WERKS = GT_I14-WERKS
                      AND TAGNR = GT_I14-TAGNR.
    ENDIF.
  ENDLOOP.

  IF LT_ZPPT0019 IS NOT INITIAL.
    MODIFY ZPPT0019 FROM TABLE LT_ZPPT0019.
  ENDIF.

  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_ZPPT0001_GR_SCR
*&---------------------------------------------------------------------*
FORM MODIFY_ZPPT0001_GR_SCR.

  DATA : LV_CHECK,
         GV_AUFNR    LIKE ZPPT0001-AUFNR,
         GS_ZPPT0001 LIKE ZPPT0001.
  CLEAR: LV_CHECK, GV_AUFNR, GS_ZPPT0001.

  DATA : LS_MSEG    TYPE MSEG.

  DATA(LT_ITEM) = GT_I14[].

  DATA : BEGIN OF LT_DELIV OCCURS 0,
           VBELN LIKE LIPS-VBELN,
           POSNR LIKE LIPS-POSNR,
           EBELN LIKE LIPS-VGBEL,
           EBELP LIKE LIPS-VGPOS,
           MATNR LIKE LIPS-MATNR,
           LFIMG LIKE ZGTMMSIF0014-LFIMG,
           MEINS LIKE ZGTMMSIF0014-MEINS,
           LICHN LIKE LIPS-LICHN, " XX
           CHARG LIKE ZGTMMSIF0014-CHARG,
           LGORT LIKE ZGTMMSIF0014-LGORT,
           WERKS LIKE LIPS-WERKS,
           LIFNR LIKE LIKP-LIFNR, " XX
           LFDAT LIKE LIKP-LFDAT, " XX
           UECHA LIKE LIPS-UECHA, " XX
           TAGNR LIKE ZGTMMSIF0014-TAGNR,
         END   OF LT_DELIV.

*  SELECT B~VBELN,
*         B~POSNR,
*         B~VGBEL AS EBELN,
*         B~VGPOS AS EBELP,
*         B~MATNR,
*         C~LFIMG,
*         C~MEINS,
*         B~LICHN,
*         C~CHARG,
*         C~LGORT,
*         B~WERKS,
*         A~LIFNR,
*         A~LFDAT,
*         B~UECHA,
*         C~TAGNR
*    FROM LIKP AS A INNER JOIN LIPS AS B
*      ON A~VBELN = B~VBELN
*   INNER JOIN @LT_ITEM AS C
*      ON B~VBELN = C~VBELN
*     AND B~POSNR = C~POSNR
*   WHERE B~PSTYV = 'ELN'
*     AND B~WERKS = '1305'
*     AND B~XCHPF = 'X'
*     AND A~VBELN = @GT_I12-VBELN
*     AND C~CHARG IS NOT INITIAL
*    INTO CORRESPONDING FIELDS OF TABLE @LT_DELIV.

  LOOP AT GT_I14.
    MOVE-CORRESPONDING GT_I14 TO LT_DELIV.
    APPEND LT_DELIV.
  ENDLOOP.

  LOOP AT LT_DELIV INTO DATA(LS_DELIV) WHERE TAGNR IS NOT INITIAL.
    CLEAR : GV_AUFNR, GS_MSEG.
    GV_AUFNR = |{ LS_DELIV-EBELN ALPHA = IN }|.

    PERFORM GET_DISPO USING LS_DELIV-WERKS
                            LS_DELIV-MATNR.

    "저장위치 누락 방지
    IF LS_DELIV-LGORT IS INITIAL.
      IF LS_DELIV-VBELN IS NOT INITIAL.
        SELECT SINGLE LGORT
          FROM LIPS INTO LS_DELIV-LGORT
         WHERE VBELN = LS_DELIV-VBELN
           AND POSNR = LS_DELIV-POSNR.
      ELSE.
        SELECT SINGLE LGORT
          FROM EKPO INTO LS_DELIV-LGORT
         WHERE EBELN = LS_DELIV-EBELN
           AND EBELP = LS_DELIV-EBELP.
      ENDIF.
    ENDIF.

    "단위환산 정보(자재전표로 가져오기)
    IF LS_DELIV-CHARG IS INITIAL.
      SELECT SINGLE MENGE MEINS
        FROM MSEG
        INTO CORRESPONDING FIELDS OF GS_MSEG
       WHERE MBLNR = GS_MHDRT-MAT_DOC
         AND MJAHR = GS_MHDRT-DOC_YEAR
         AND EBELN = LS_DELIV-EBELN
         AND EBELP = LS_DELIV-EBELP.
    ELSE.
      SELECT SINGLE MENGE MEINS
        FROM MSEG
        INTO CORRESPONDING FIELDS OF GS_MSEG
       WHERE MBLNR = GS_MHDRT-MAT_DOC
         AND MJAHR = GS_MHDRT-DOC_YEAR
         AND EBELN = LS_DELIV-EBELN
         AND EBELP = LS_DELIV-EBELP
         AND CHARG = LS_DELIV-CHARG.
    ENDIF.

    SELECT SINGLE MANDT
      FROM ZPPT0001 INTO @SY-MANDT
     WHERE WERKS = @LS_DELIV-WERKS
       AND AUFNR = @GV_AUFNR
*       AND TAGNR = @LS_DELIV-LICHN.
       AND TAGNR = @LS_DELIV-TAGNR.

    IF SY-SUBRC = 0.
      UPDATE ZPPT0001 SET MGVRG  = GS_MSEG-MENGE
                          REMAIN = GS_MSEG-MENGE
                          LGORT  = LS_DELIV-LGORT
                          MBLNR  = GS_MHDRT-MAT_DOC
                          CHARG  = LS_DELIV-CHARG
                          GRFLG  = 'Y'
                    WHERE WERKS  = LS_DELIV-WERKS
                      AND AUFNR  = GV_AUFNR
                      AND TAGNR  = LS_DELIV-TAGNR.

      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.

      PERFORM MODIFY_ZPPT0019.

    ELSE.
      CLEAR : GS_ZPPT0001.

      GS_ZPPT0001-WERKS = LS_DELIV-WERKS.
      GS_ZPPT0001-AUFNR = GV_AUFNR.
      GS_ZPPT0001-TAGNR = LS_DELIV-TAGNR.
      GS_ZPPT0001-RUECK = LS_DELIV-VBELN.
      GS_ZPPT0001-RMZHL = LS_DELIV-POSNR.
      GS_ZPPT0001-POSNR = LS_DELIV-EBELP.
      GS_ZPPT0001-CHARG = LS_DELIV-CHARG.
      GS_ZPPT0001-MATNR = LS_DELIV-MATNR.
      GS_ZPPT0001-MBLNR = GS_MHDRT-MAT_DOC.
      GS_ZPPT0001-MGVRG = GS_MSEG-MENGE.
      GS_ZPPT0001-REMAIN = GS_MSEG-MENGE.
      GS_ZPPT0001-LGORT  = LS_DELIV-LGORT.
      GS_ZPPT0001-MEINS  = GS_MSEG-MEINS.
      GS_ZPPT0001-SPGCD  = GV_DISPO+0(2).
      GS_ZPPT0001-FOSTCNT = '1'.
      GS_ZPPT0001-OUTFLG  = 'X'.
      GS_ZPPT0001-GIFLG   = 'N'.
      GS_ZPPT0001-GRFLG   = 'Y'.
      GS_ZPPT0001-INSPFLG = 'OK'.
      GS_ZPPT0001-WKDAT   = SY-DATUM.
      GS_ZPPT0001-GRINDAT = SY-DATUM.
      GS_ZPPT0001-GRINTIM = SY-UZEIT.
      GS_ZPPT0001-GRINNAM = SY-UNAME.

      MODIFY ZPPT0001 FROM GS_ZPPT0001.

      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.

      PERFORM MODIFY_ZPPT0019.
    ENDIF.
  ENDLOOP.

ENDFORM.
