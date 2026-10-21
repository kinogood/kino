*----------------------------------------------------------------------*
***INCLUDE LZGTMM06F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_COM_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_COM_LOG USING PV_TYPE
                       PV_ZIFNO
                       PV_ZSTAT
                       PV_MESSAGE.

  CASE PV_TYPE.
    WHEN 'S'. "Start
      CLEAR : GT_9000, GT_9000[].

      GET TIME STAMP FIELD GT_9000-ZIFKEY.

      GT_9000-ZIFNO     = PV_ZIFNO.
      GT_9000-SYSTEM_ID = GV_SYSTEM_ID.
      GT_9000-IFDAT     = SY-DATLO.
      GT_9000-IFTIM     = SY-TIMLO.
      GT_9000-IFNAM     = SY-UNAME.

      MODIFY ZGTMMT9000 FROM GT_9000.

    WHEN 'E'. "End
      UPDATE ZGTMMT9000 SET ZSTAT       = PV_ZSTAT
                            MESSAGE     = PV_MESSAGE
                            ERDAT       = SY-DATUM
                            ERDAT_LOCAL = SY-DATLO
                            ERTIM       = SY-UZEIT
                            ERTIM_LOCAL = SY-TIMLO
                            ERNAM       = SY-UNAME
                      WHERE ZIFNO       = GT_9000-ZIFNO
                        AND ZIFKEY      = GT_9000-ZIFKEY
                        AND SYSTEM_ID   = GT_9000-SYSTEM_ID.

  ENDCASE.

  CHECK SY-SUBRC = 0.
  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_MATN1_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_I25_MATNR
*&---------------------------------------------------------------------*
FORM CONVERT_MATN1_INPUT USING PV_MATNR.

  CHECK PV_MATNR IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT        = PV_MATNR
    IMPORTING
      OUTPUT       = PV_MATNR
    EXCEPTIONS
      LENGTH_ERROR = 1
      OTHERS       = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_GOODSMVT_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_GOODSMVT_CREATE.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = GS_MHDR
      GOODSMVT_CODE    = GS_MCOD
    IMPORTING
      GOODSMVT_HEADRET = GS_MHDRT
*     MATERIALDOCUMENT = GS_MHDRT-MAT_DOC
*     MATDOCUMENTYEAR  = GS_MHDRT-DOC_YEAR
    TABLES
      GOODSMVT_ITEM    = GT_MITM
      RETURN           = GT_RTN
    EXCEPTIONS
      OTHERS           = 4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_COMMIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_COMMIT.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_ROLLBACK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_ROLLBACK.

  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONVERSION_INPUT.
*- CONVERSION_EXIT_ALPHA_INPUT.
  LOOP AT GT_ITAB.
    PERFORM CONVERSION_DATA_INPUT.

    MODIFY GT_ITAB INDEX SY-TABIX
    TRANSPORTING UMMAT AUFNR LIFNR KUNNR KDAUF KONTO KOSTL EBELN MATNR
                 EBELP ZEILE RSNUM RSPOS.
*    TRANSPORTING UMMAT AUFNR LIFNR KUNNR KDAUF KOSTL EBELN MATNR.
    CLEAR : GT_ITAB.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_DATA_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONVERSION_DATA_INPUT.
*- CONVERSION_EXIT_ALPHA
  PERFORM CONVERSION_ALPHA_INPUT CHANGING GT_ITAB-UMMAT.
  PERFORM CONVERSION_ALPHA_INPUT CHANGING GT_ITAB-AUFNR.
  PERFORM CONVERSION_ALPHA_INPUT CHANGING GT_ITAB-LIFNR.
  PERFORM CONVERSION_ALPHA_INPUT CHANGING GT_ITAB-KUNNR.
  PERFORM CONVERSION_ALPHA_INPUT CHANGING GT_ITAB-KDAUF.
  PERFORM CONVERSION_ALPHA_INPUT CHANGING GT_ITAB-KONTO.
  PERFORM CONVERSION_ALPHA_INPUT CHANGING GT_ITAB-KOSTL.
  PERFORM CONVERSION_ALPHA_INPUT CHANGING GT_ITAB-EBELN.
  PERFORM CONVERSION_ALPHA_INPUT CHANGING GT_ITAB-EBELP.
  PERFORM CONVERSION_ALPHA_INPUT CHANGING GT_ITAB-ZEILE.
  PERFORM CONVERSION_ALPHA_INPUT CHANGING GT_ITAB-RSNUM.
  PERFORM CONVERSION_ALPHA_INPUT CHANGING GT_ITAB-RSPOS.
  PERFORM CONVERSION_EXIT_MATN1  CHANGING GT_ITAB-MATNR.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONVERSION_OUTPUT.
  LOOP AT GT_OTAB.
    PERFORM CONVERSION_ALPHA_OUTPUT CHANGING GT_OTAB-MBLNR.
    MODIFY GT_OTAB.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_ALPHA_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_OTAB_MBLNR
*&---------------------------------------------------------------------*
FORM CONVERSION_ALPHA_OUTPUT CHANGING PV_VALUE.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = PV_VALUE
    IMPORTING
      OUTPUT = PV_VALUE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_ALPHA_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_ITAB_UMMAT
*&---------------------------------------------------------------------*
FORM CONVERSION_ALPHA_INPUT CHANGING V_PAR.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = V_PAR
    IMPORTING
      OUTPUT = V_PAR.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_EXIT_MATN1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_ITAB_MATNR
*&---------------------------------------------------------------------*
FORM CONVERSION_EXIT_MATN1 CHANGING PV_MATNR.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT        = PV_MATNR
    IMPORTING
      OUTPUT       = PV_MATNR
    EXCEPTIONS
      LENGTH_ERROR = 1
      OTHERS       = 2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_GOODSMVT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_IFKEY
*&      --> ZO_RESULT
*&      --> ZO_MESSAGE
*&---------------------------------------------------------------------*
FORM BAPI_GOODSMVT.

*  DATA : LV_END(1).
*  DATA : LV_NEW(1).
*  DATA : LV_GUBUN(1). "--> 전선/비전선 구분자
*  DATA : BEGIN OF LT_MSEG OCCURS 0,
*           MBLNR LIKE MSEG-MBLNR,
*           MJAHR LIKE MSEG-MJAHR,
*           ZEILE LIKE MSEG-ZEILE,
*           EBELN LIKE MSEG-EBELN,
*           EBELP LIKE MSEG-EBELP,
*           RSNUM LIKE MSEG-RSNUM,
*           RSPOS LIKE MSEG-RSPOS,
*         END OF LT_MSEG.
*
*  DATA : LV_PSPNR     LIKE RKPF-PS_PSP_PNR, " WBS 신규 추가
*         LV_PRCTR     LIKE PRPS-PRCTR,      " WBS 신규 추가
*         LV_PARBU     LIKE RKPF-PARBU,      " WBS 신규 추가
*         LV_PARGB     LIKE RKPF-PARGB,      " WBS 신규 추가
*         LV_FUNC_AREA LIKE PRPS-FUNC_AREA,  " WBS 신규 추가
*         LV_SAKNR     LIKE RESB-SAKNR,      " WBS 신규 추가
*         LV_AUFNR     LIKE RESB-AUFNR,
*         LV_LGPRO     LIKE MARC-LGPRO,
*         LV_LGFSB     LIKE MARC-LGFSB,
*         LV_BESKZ     LIKE MARC-BESKZ,
*         LV_KOSTL     LIKE RKPF-KOSTL,
*         LV_NPLNR     LIKE RKPF-NPLNR,
*         LV_LGORT     LIKE RESB-LGORT.
*
*  CLEAR : LT_MSEG, LT_MSEG[].
*
*  SORT GT_ITAB BY IFNUM IFSEQ.
*  LOOP AT GT_ITAB.
*
*    IF GT_ITAB-FLAG = ' '.
*
*      AT NEW IFNUM.
*        LV_NEW = 'X'.
*      ENDAT.
*
*      IF LV_NEW = 'X'.
*        CLEAR : GT_ITEM_140, GT_ITEM_140[], GW_HEAD_140, GT_RET_140[],
*                GT_RET_140, GW_CODE_140, GW_HEADRET.
*        CLEAR LV_NEW.
*      ENDIF.
*
*      AT END OF IFNUM.
*        LV_END = 'X'.
*      ENDAT.
*
**- MES 사용 이동 유형 (911,912,917,543,544)
**- 기타입출고(MB1C) GM_Code 05: Other goods receipt
*      IF GT_ITAB-BWART = '511' OR GT_ITAB-BWART = '512' OR
*         GT_ITAB-BWART = '531' OR GT_ITAB-BWART = '532' OR
*         GT_ITAB-BWART = 'Z21' OR GT_ITAB-BWART = 'Z22'.
*        GW_CODE_140-GM_CODE    = '05'.             "Other goods receipt
**- 기타입출고(MB1A) GM_Code 03: Goods issue
*      ELSEIF GT_ITAB-BWART = '931' OR GT_ITAB-BWART = '932' OR
*             GT_ITAB-BWART = '933' OR GT_ITAB-BWART = '934' OR
*             GT_ITAB-BWART = '935' OR GT_ITAB-BWART = '936' OR
*             GT_ITAB-BWART = '937' OR GT_ITAB-BWART = '938' OR
*             GT_ITAB-BWART = '939' OR GT_ITAB-BWART = '940' OR
*             GT_ITAB-BWART = '943' OR GT_ITAB-BWART = '944'.
*        GW_CODE_140-GM_CODE    = '03'.               " Goods issue
*      ELSEIF GT_ITAB-BWART = '544' OR GT_ITAB-BWART = '543' OR
*             GT_ITAB-BWART = '121'.
*        GW_CODE_140-GM_CODE    = '07'.
**--> KIT 공정 WBS 출고 추가
*      ELSEIF GT_ITAB-BWART = '221' OR GT_ITAB-BWART = '222' OR
*             GT_ITAB-BWART = '201' OR GT_ITAB-BWART = '202' OR
*             GT_ITAB-BWART = 'Z63' OR GT_ITAB-BWART = 'Z64' OR
*             GT_ITAB-BWART = 'Z81' OR GT_ITAB-BWART = 'Z82' OR
*             GT_ITAB-BWART = '291' OR GT_ITAB-BWART = '292' OR
*             GT_ITAB-BWART = 'Z71' OR GT_ITAB-BWART = 'Z72' OR
*             GT_ITAB-BWART = '281' OR GT_ITAB-BWART = '282'.
*
*        GW_CODE_140-GM_CODE    = '03'.
**<-- KIT 공정 WBS 출고 추가
**- 자재이동(MB1B) GM_Code 04: Transfer posting
*      ELSE.
*        GW_CODE_140-GM_CODE    = '04'.               " Transfer posting
*      ENDIF.
*
*      GW_HEAD_140-PSTNG_DATE = GT_ITAB-BUDAT.    " 전표 생성일
*      GW_HEAD_140-DOC_DATE   = GT_ITAB-BLDAT.    " 전표 증빙일
*      GW_HEAD_140-HEADER_TXT = GT_ITAB-BKTXT.    " 전표 헤더 텍스트
*      GT_ITEM_140-MATERIAL   = GT_ITAB-MATNR.    " 자재번호
*      GT_ITEM_140-PLANT      = GT_ITAB-WERKS.    " 플랜트
*      GT_ITEM_140-STGE_LOC   = GT_ITAB-LGORT.    " 저장위치
*      GT_ITEM_140-BATCH      = GT_ITAB-CHARG.    " 출고플랜트 배치
*      GT_ITEM_140-MOVE_TYPE  = GT_ITAB-BWART.    " 이동유형
*      GT_ITEM_140-ENTRY_QNT  = GT_ITAB-ERFMG.    " 소요량
*      GT_ITEM_140-ENTRY_UOM  = GT_ITAB-ERFME.    " 입력단위
*      GT_ITEM_140-MOVE_PLANT = GT_ITAB-R_WERKS.  " 이동할플랜트
*      GT_ITEM_140-MOVE_STLOC = GT_ITAB-R_LGORT.  " 이동할 저장위치
*
**--> I/F 받은 UMCHA 있더라도 입고 플랜트 마스터 확인 후 반영 - 20250327
**      GT_ITEM_140-MOVE_BATCH = GT_ITAB140-UMCHA.    " 입고플랜트 배치
*      IF GT_ITAB-UMCHA IS NOT INITIAL.
*        SELECT SINGLE MANDT
*          INTO SY-MANDT
*          FROM MARC
*         WHERE WERKS = GT_ITAB-R_WERKS
*           AND MATNR = GT_ITAB-MATNR
*           AND XCHPF = 'X'.
*
*        IF SY-SUBRC = '0'.
*          GT_ITEM_140-MOVE_BATCH = GT_ITAB-UMCHA.
*        ENDIF.
*      ENDIF.
**<-- I/F 받은 UMCHA 있더라도 입고 플랜트 마스터 확인 후 반영 - 20250327
*
*      GT_ITEM_140-VENDOR     = GT_ITAB-LIFNR .   " 구매처
*      GT_ITEM_140-CUSTOMER   = GT_ITAB-KUNNR .   " 고객번호
*      GT_ITEM_140-SALES_ORD  = GT_ITAB-KDAUF .   " 판매오더번호
*      GT_ITEM_140-VAL_SALES_ORD  = GT_ITAB-KDAUF .   " 판매오더번호
*      GT_ITEM_140-S_ORD_ITEM = GT_ITAB-KDPOS .   " 판매오더 품목번호
*      GT_ITEM_140-VAL_S_ORD_ITEM = GT_ITAB-KDPOS .   " 판매오더 품목번호
*      GT_ITEM_140-ITEM_TEXT  = GT_ITAB-SGTXT.    " 품목텍스트
*      GT_ITEM_140-GL_ACCOUNT = GT_ITAB-KONTO.    " G/L계정
*      GT_ITEM_140-COSTCENTER = GT_ITAB-KOSTL.    " 코스트센터
*      GT_ITEM_140-WBS_ELEM   = GT_ITAB-PS_POSID. " 작업분석구조요소
**      GT_ITEM_140-MOVE_MAT   = GT_ITAB140-UMMAT.    " 입고/출고 자재
*      GT_ITEM_140-PO_NUMBER  = GT_ITAB-EBELN.
*      GT_ITEM_140-PO_ITEM    = GT_ITAB-EBELP.
*      GT_ITEM_140-RESERV_NO  = GT_ITAB-RSNUM.
*      GT_ITEM_140-RES_ITEM   = GT_ITAB-RSPOS.
*
*      IF GT_ITEM_140-STGE_LOC IS INITIAL.
*        SELECT SINGLE LGORT
*          INTO GT_ITEM_140-STGE_LOC
*          FROM RESB
*         WHERE RSNUM = GT_ITAB-RSNUM
*           AND RSPOS = GT_ITAB-RSPOS.
*      ENDIF.
*
*      IF GT_ITAB-RSNUM IS NOT INITIAL.
*        SELECT SINGLE RSART SAKNR
*          INTO (GT_ITEM_140-RES_TYPE, GT_ITEM_140-GL_ACCOUNT)
*          FROM RESB
*         WHERE RSNUM = GT_ITAB-RSNUM
*           AND RSPOS = GT_ITAB-RSPOS.
*      ENDIF.
*      IF GT_ITAB-BWART = '309' OR GT_ITAB-BWART = '310'.
*        GT_ITEM_140-MOVE_MAT = GT_ITAB-UMMAT. " MTOM 시에만 필요
*      ENDIF.
*      IF GT_ITAB-BWART = '121'.
*        GT_ITEM_140-SPEC_STOCK = '1'.
*        GT_ITEM_140-MVT_IND   = 'O'.
*        GT_ITEM_140-LINE_ID   = '000001'.
*
*        SELECT SINGLE MBLNR MJAHR ZEILE
*          INTO (GT_ITEM_140-REF_DOC,GT_ITEM_140-REF_DOC_YR,
*                GT_ITEM_140-REF_DOC_IT)
*          FROM MSEG
*         WHERE EBELN = GT_ITAB-EBELN
*           AND EBELP = GT_ITAB-EBELP
*           AND BWART = '101'
*           AND CHARG = GT_ITAB-CHARG.
*
*      ELSEIF GT_ITAB-BWART = '543' OR GT_ITAB-BWART = '544'.
*        GT_ITEM_140-SPEC_STOCK = 'O'.
*        GT_ITEM_140-MVT_IND   = 'W'.
*        GT_ITEM_140-LINE_ID   = '000002'.
*        GT_ITEM_140-PARENT_ID = '000001'.
*        GT_ITEM_140-LINE_DEPTH = '01'.
*
*        IF GT_ITAB-BWART = '544'.
*          SELECT SINGLE MBLNR MJAHR ZEILE
*            INTO (GT_ITEM_140-REF_DOC,GT_ITEM_140-REF_DOC_YR,
*                  GT_ITEM_140-REF_DOC_IT)
*            FROM MSEG
*           WHERE EBELN = GT_ITAB-EBELN
*             AND EBELP = GT_ITAB-EBELP
*             AND BWART = '543'
*             AND CHARG = GT_ITAB-CHARG.
*        ENDIF.
*
*      ELSEIF GT_ITAB-BWART = '311' OR GT_ITAB-BWART = '312'.
*        IF GT_ITAB-KDAUF IS NOT INITIAL.
*          GT_ITEM_140-SPEC_STOCK = 'E'.
*        ENDIF.
*
**--> KIT 공정 WBS 출고 추가
*      ELSEIF GT_ITAB-BWART = '221' OR GT_ITAB-BWART = '222'.
*
*        CLEAR : LV_PSPNR, LV_PRCTR, LV_PARBU, LV_PARGB, LV_FUNC_AREA.
*
*        SELECT  SINGLE
*                A~PS_PSP_PNR B~PRCTR A~PARBU A~PARGB B~FUNC_AREA
*          INTO  (LV_PSPNR, LV_PRCTR, LV_PARBU, LV_PARGB, LV_FUNC_AREA)
*          FROM  RKPF AS A
*                INNER JOIN PRPS AS B
*                  ON A~PS_PSP_PNR = B~PSPNR
*         WHERE  A~RSNUM = GT_ITAB-RSNUM.
*
*        CALL FUNCTION 'CONVERSION_EXIT_KONPR_OUTPUT'
*          EXPORTING
*            INPUT  = LV_PSPNR
*          IMPORTING
*            OUTPUT = GT_ITEM_140-WBS_ELEM.
*
*        GT_ITEM_140-VAL_WBS_ELEM = GT_ITEM_140-WBS_ELEM.
*        GT_ITEM_140-PROFIT_CTR = LV_PRCTR.
*        GT_ITEM_140-PAR_COMPCO = LV_PARBU.
*        GT_ITEM_140-TR_PART_BA = LV_PARGB.
*        GT_ITEM_140-FUNC_AREA = LV_FUNC_AREA.
*
*        IF GT_ITEM_140-STGE_LOC IS INITIAL.
*          CLEAR : LV_LGPRO, LV_LGFSB, LV_BESKZ.
*
*          SELECT  SINGLE
*                  A~LGPRO A~LGFSB A~BESKZ
*            INTO  (LV_LGPRO, LV_LGFSB, LV_BESKZ)
*            FROM  MARC AS A
*           WHERE  A~MATNR = GT_ITAB-MATNR
*             AND  A~WERKS = GT_ITAB-WERKS.
*
*          IF LV_BESKZ = 'E'.
*            GT_ITEM_140-STGE_LOC = LV_LGPRO.
*          ELSEIF LV_BESKZ = 'F'.
*            GT_ITEM_140-STGE_LOC = LV_LGFSB.
*          ELSE.
*            GT_ITEM_140-STGE_LOC = '3320'.
*          ENDIF.
*        ENDIF.
**<-- KIT 공정 WBS 출고 추가
**--> 이동유형 추가 - 20250206
*
*      ELSEIF GT_ITAB-BWART = 'Z81' OR GT_ITAB-BWART = 'Z82'.
*        IF GT_ITEM_140-STGE_LOC IS INITIAL.
*          CLEAR : LV_LGPRO, LV_LGFSB, LV_BESKZ.
*
*          SELECT  SINGLE
*                  A~LGPRO A~LGFSB A~BESKZ
*            INTO  (LV_LGPRO, LV_LGFSB, LV_BESKZ)
*            FROM  MARC AS A
*           WHERE  A~MATNR = GT_ITAB-MATNR
*             AND  A~WERKS = GT_ITAB-WERKS.
*
*          IF LV_BESKZ = 'E'.
*            GT_ITEM_140-STGE_LOC = LV_LGPRO.
*          ELSEIF LV_BESKZ = 'F'.
*            GT_ITEM_140-STGE_LOC = LV_LGFSB.
*          ELSE.
*            GT_ITEM_140-STGE_LOC = '3320'.
*          ENDIF.
*        ENDIF.
*
*      ELSEIF GT_ITAB-BWART = 'Z63' OR GT_ITAB-BWART = 'Z64' OR
*             GT_ITAB-BWART = '291' OR GT_ITAB-BWART = '292'.
*
*        CLEAR : LV_AUFNR.
*        CLEAR : LV_LGPRO, LV_LGFSB, LV_BESKZ.
*
*        SELECT  SINGLE
*                A~AUFNR C~LGPRO C~LGFSB C~BESKZ
*          INTO  (LV_AUFNR, LV_LGPRO, LV_LGFSB, LV_BESKZ)
*          FROM  RESB AS A
*                INNER JOIN MARC AS C
*                  ON A~MATNR = C~MATNR
*                  AND A~WERKS = C~WERKS
*         WHERE  A~RSNUM = GT_ITAB-RSNUM
*           AND  A~RSPOS = GT_ITAB-RSPOS.
*
*        GT_ITEM_140-ORDERID = LV_AUFNR.
*
*        IF GT_ITEM_140-STGE_LOC IS INITIAL.
*          IF LV_BESKZ = 'E'.
*            GT_ITEM_140-STGE_LOC = LV_LGPRO.
*          ELSEIF LV_BESKZ = 'F'.
*            GT_ITEM_140-STGE_LOC = LV_LGFSB.
*          ELSE.
*            GT_ITEM_140-STGE_LOC = '3320'.
*          ENDIF.
*        ENDIF.
*      ELSEIF GT_ITAB-BWART = '201' OR GT_ITAB-BWART = '202' OR
*             GT_ITAB-BWART = 'Z71' OR GT_ITAB-BWART = 'Z72'.
*
*        CLEAR : LV_PARBU, LV_PARGB, LV_KOSTL.
*
*        SELECT  SINGLE
*                A~KOSTL A~PARBU A~PARGB
*          INTO  (LV_KOSTL, LV_PARBU, LV_PARGB)
*          FROM  RKPF AS A
*         WHERE  A~RSNUM = GT_ITAB-RSNUM.
*
*        GT_ITEM_140-COSTCENTER = LV_KOSTL.
*        GT_ITEM_140-PAR_COMPCO = LV_PARBU.
*        GT_ITEM_140-TR_PART_BA = LV_PARGB.
*
*        IF GT_ITEM_140-STGE_LOC IS INITIAL.
*          CLEAR : LV_LGPRO, LV_LGFSB, LV_BESKZ.
*
*          SELECT  SINGLE
*                  A~LGPRO A~LGFSB A~BESKZ
*            INTO  (LV_LGPRO, LV_LGFSB, LV_BESKZ)
*            FROM  MARC AS A
*           WHERE  A~MATNR = GT_ITAB-MATNR
*             AND  A~WERKS = GT_ITAB-WERKS.
*
*          IF LV_BESKZ = 'E'.
*            GT_ITEM_140-STGE_LOC = LV_LGPRO.
*          ELSEIF LV_BESKZ = 'F'.
*            GT_ITEM_140-STGE_LOC = LV_LGFSB.
*          ELSE.
*            GT_ITEM_140-STGE_LOC = '3320'.
*          ENDIF.
*        ENDIF.
*      ELSEIF GT_ITAB-BWART = '281' OR GT_ITAB-BWART = '282'.
*
*        CLEAR : LV_NPLNR.
*
*        SELECT  SINGLE
*                A~NPLNR
*          INTO  (LV_NPLNR)
*          FROM  RKPF AS A
*         WHERE  A~RSNUM = GT_ITAB-RSNUM.
*
*        GT_ITEM_140-NETWORK = LV_NPLNR.
*
*        IF GT_ITEM_140-STGE_LOC IS INITIAL.
*          CLEAR : LV_LGPRO, LV_LGFSB, LV_BESKZ.
*
*          SELECT  SINGLE
*                  A~LGPRO A~LGFSB A~BESKZ
*            INTO  (LV_LGPRO, LV_LGFSB, LV_BESKZ)
*            FROM  MARC AS A
*           WHERE  A~MATNR = GT_ITAB-MATNR
*             AND  A~WERKS = GT_ITAB-WERKS.
*
*          IF LV_BESKZ = 'E'.
*            GT_ITEM_140-STGE_LOC = LV_LGPRO.
*          ELSEIF LV_BESKZ = 'F'.
*            GT_ITEM_140-STGE_LOC = LV_LGFSB.
*          ELSE.
*            GT_ITEM_140-STGE_LOC = '3320'.
*          ENDIF.
*        ENDIF.
*
*      ENDIF.
**<-- 이동유형 추가 - 20250206
*
*      APPEND : GT_ITEM_140.
*
*      IF LV_END = 'X'.
*
*        CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
*          EXPORTING
*            GOODSMVT_HEADER  = GW_HEAD_140
*            GOODSMVT_CODE    = GW_CODE_140
*          IMPORTING
*            GOODSMVT_HEADRET = GW_HEADRET
*          TABLES
*            GOODSMVT_ITEM    = GT_ITEM_140
*            RETURN           = GT_RET_140.
*
*        IF GT_RET_140[] IS INITIAL.
*
*          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*            EXPORTING
*              WAIT = 'X'.
*
**--> 자재문서 ITEM 반영
*          CLEAR : LT_MSEG, LT_MSEG[].
*          SELECT  MBLNR MJAHR ZEILE EBELN EBELP RSNUM RSPOS
*            INTO CORRESPONDING FIELDS OF TABLE LT_MSEG
*            FROM  MSEG
*           WHERE  MBLNR = GW_HEADRET-MAT_DOC
*             AND  MJAHR = GW_HEADRET-DOC_YEAR.
*
*          LOOP AT LT_MSEG.
*            IF GT_ITAB-RSNUM IS INITIAL AND GT_ITAB-EBELN IS INITIAL.
*            ELSEIF GT_ITAB-RSNUM IS NOT INITIAL AND GT_ITAB-EBELN IS INITIAL.
*              READ TABLE LT_MSEG WITH KEY RSNUM = GT_ITAB-RSNUM
*                                          RSPOS = GT_ITAB-RSPOS
*                                 BINARY SEARCH.
*              IF SY-SUBRC = 0.
*                GT_ITAB-ZEILE = LT_MSEG-ZEILE.
*              ENDIF.
*            ELSEIF GT_ITAB-RSNUM IS INITIAL AND GT_ITAB-EBELN IS NOT INITIAL.
*              READ TABLE LT_MSEG WITH KEY EBELN = GT_ITAB-EBELN
*                                          EBELP = GT_ITAB-EBELP
*                                 BINARY SEARCH.
*              IF SY-SUBRC = 0.
*                GT_ITAB-ZEILE = LT_MSEG-ZEILE.
*              ENDIF.
*            ENDIF.
*          ENDLOOP.
**<-- 자재문서 ITEM 반영
*
*          GT_ITAB-MBLNR    = GW_HEADRET-MAT_DOC.  "자재문서번호
*          GT_ITAB-MJAHR    = GW_HEADRET-DOC_YEAR. "자재 전표 연도
*          GT_ITAB-ZRESULT  = '00'. " SUCCESS
*          GT_ITAB-ZMESSAGE = 'GI Success'.
*          MODIFY GT_ITAB.
*          MOVE-CORRESPONDING GT_ITAB TO GT_OTAB.
*          APPEND GT_OTAB.
*
*          MODIFY ZGTMMT9200 FROM TABLE GT_ITAB.
*          IF SY-SUBRC = 0.
*            COMMIT WORK.
*          ENDIF.
*          CLEAR GT_OTAB.
*
**--> 꼬리표 반영 - ZPPR0039 참조
*          IF GT_ITAB-TAGNR IS NOT INITIAL.
*            IF GT_ITAB-RSNUM IS INITIAL AND GT_ITAB-EBELN IS NOT INITIAL. " 사내거래
*              UPDATE ZPPT0019
*                SET: MBLNR   =  GW_HEADRET-MAT_DOC
*                     MJAHR   =  GW_HEADRET-DOC_YEAR
*                     MBLNR_F = 'X'
*               WHERE EBELN   =  GT_ITAB-EBELN
*                 AND EBELP   =  GT_ITAB-EBELP
*                 AND PLUMI   = '2' " 출고
*                 AND TAGNR   =  GT_ITAB-TAGNR.
*
*              CLEAR : LV_GUBUN.
*              SELECT SINGLE B~GUBUN
*                INTO LV_GUBUN
*                FROM MARC AS A
*                     INNER JOIN ZPPT0134 AS B
*                      ON A~WERKS = B~WERKS
*                      AND A~DISPO = B~DISPO
*               WHERE B~WERKS = GT_ITAB-WERKS
*                 AND A~MATNR = GT_ITAB-MATNR.
*
*              IF SY-SUBRC = 0.
*                CASE LV_GUBUN. " 전선/비전선 구분
*                  WHEN 'C'. " 전선
*                    PERFORM UPDATE_ZPPT0001_GI USING GT_ITAB-TAGNR
*                                                    'Y'.
*                  WHEN 'B'. " 비전선
*                    PERFORM UPDATE_ZPPT0211_GI USING GT_ITAB-TAGNR
*                                                    'Y'.
*                ENDCASE.
*              ENDIF.
*
*            ELSEIF GT_ITAB-RSNUM IS NOT INITIAL AND GT_ITAB-EBELN IS INITIAL. " 예약출고
*            ENDIF.
*          ENDIF.
**<-- 꼬리표 반영 - ZPPR0039 참조
*
*        ELSE. "수행 실패 시
**          ROLLBACK WORK.
*          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*
*          GT_ITAB-ZRESULT  = '01'. " FAIE
*          GT_ITAB-ZMESSAGE = GT_RET_140-MESSAGE.
*          MODIFY GT_ITAB.
*          MOVE-CORRESPONDING GT_ITAB TO GT_OTAB.
*          APPEND GT_OTAB.
*
*          MODIFY ZGTMMT9200 FROM TABLE GT_ITAB.
*          IF SY-SUBRC = 0.
*            COMMIT WORK.
*          ENDIF.
*
*          CLEAR GT_OTAB.
*
*        ENDIF.
*        CLEAR LV_END.
*      ENDIF.
*
*      "--> 취소
*    ELSEIF GT_ITAB-FLAG = 'D'.
*
*      CLEAR : GW_HEAD_140_2, GW_HEADRET_CANC, GT_RET2_140,
*              GW_MATDOCITEM.
*      GW_HEAD_140_2-MAT_DOC    = GT_ITAB-MBLNR.
*      GW_HEAD_140_2-DOC_YEAR   = GT_ITAB-MJAHR.
*      GW_HEAD_140_2-PSTNG_DATE = GT_ITAB-BUDAT.
*
*      GW_MATDOCITEM-MATDOC_ITEM = GT_ITAB-ZEILE.
*      APPEND : GW_MATDOCITEM.
*
*      CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
*        EXPORTING
*          MATERIALDOCUMENT    = GW_HEAD_140_2-MAT_DOC
*          MATDOCUMENTYEAR     = GW_HEAD_140_2-DOC_YEAR
*          GOODSMVT_PSTNG_DATE = GW_HEAD_140_2-PSTNG_DATE
*        IMPORTING
*          GOODSMVT_HEADRET    = GW_HEADRET_CANC
*        TABLES
*          RETURN              = GT_RET2_140
*          GOODSMVT_MATDOCITEM = GW_MATDOCITEM.
*
*      IF GT_RET2_140 IS INITIAL.
*        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*          EXPORTING
*            WAIT = 'X'.
*
**--> 자재문서 ITEM 반영
*        SELECT  SINGLE ZEILE
*          INTO  GT_ITAB-ZEILE_C
*          FROM  MSEG
*         WHERE  MBLNR = GW_HEADRET_CANC-MAT_DOC
*           AND  MJAHR = GW_HEADRET_CANC-DOC_YEAR
*           AND  SMBLN = GT_ITAB-MBLNR
*           AND  SJAHR = GT_ITAB-MJAHR
*           AND  SMBLP = GT_ITAB-ZEILE.
**<-- 자재문서 ITEM 반영
*
*        GT_ITAB-MBLNR_C   = GW_HEADRET_CANC-MAT_DOC.
*        GT_ITAB-MJAHR_C   = GW_HEADRET_CANC-DOC_YEAR.
*        GT_ITAB-ZRESULT   = '00'. " SUCCESS
*        GT_ITAB-ZMESSAGE  = 'GI Cancel Success'.
*        MODIFY GT_ITAB.
*        MOVE-CORRESPONDING GT_ITAB TO GT_OTAB.
*        APPEND GT_OTAB.
*
*        MODIFY ZGTMMT9200 FROM TABLE GT_ITAB.
*        IF SY-SUBRC = 0.
*          COMMIT WORK.
*        ENDIF.
*
*        CLEAR GT_OTAB.
*
**--> 꼬리표 반영 - ZPPR0039 참조
*        IF GT_ITAB-TAGNR IS NOT INITIAL.
*          IF GT_ITAB-RSNUM IS INITIAL AND GT_ITAB-EBELN IS NOT INITIAL. " 사내거래
*            CLEAR : LV_GUBUN.
*            CLEAR : ZPPT0134.
*            SELECT SINGLE A~GUBUN INTO LV_GUBUN
*                     FROM ZPPT0134 AS A
*                          INNER JOIN MARC AS B
*                            ON A~WERKS = B~WERKS
*                            AND A~DISPO = B~DISPO
*                    WHERE A~WERKS = GT_ITAB-WERKS
*                      AND B~MATNR = GT_ITAB-MATNR.
*
*            IF SY-SUBRC = 0.
*
*              SELECT *
*                FROM ZPPT0019
*               WHERE EBELN  =  GT_ITAB-EBELN
*                 AND EBELP  =  GT_ITAB-EBELP
*                 AND PLUMI  = '2'
*                 AND MBLNR  =  GT_ITAB-MBLNR
*                 AND MJAHR  =  GT_ITAB-MJAHR.
*
*                CASE LV_GUBUN.
*                  WHEN 'C'.  "전선
*                    PERFORM UPDATE_ZPPT0001_GI USING ZPPT0019-TAGNR
*                                                    'N'.
*                  WHEN 'B'.  "비전선
*                    PERFORM UPDATE_ZPPT0211_GI USING ZPPT0019-TAGNR
*                                                    'N'.
*                ENDCASE.
*
*                UPDATE ZPPT0019 SET: MBLNR   = ' '
*                                     MJAHR   = ' '
*                                     MBLNR_F = ' '
*                              WHERE  EBELN   =  GT_ITAB-EBELN
*                                AND  EBELP   =  GT_ITAB-EBELP
*                                AND  PLUMI   = '2'
*                                AND  TAGNR   =  ZPPT0019-TAGNR.
*
*              ENDSELECT.
*            ENDIF.
*          ENDIF.
*        ENDIF.
**<-- 꼬리표 반영 - ZPPR0039 참조
*
*      ELSE.
*        ROLLBACK WORK.
*        GT_ITAB-ZRESULT  = '01'. " FAIL
*        GT_ITAB-ZMESSAGE = GT_RET2_140-MESSAGE.
*        MODIFY GT_ITAB.
*        MOVE-CORRESPONDING GT_ITAB TO GT_OTAB.
*        APPEND GT_OTAB.
*
*        MODIFY ZGTMMT9200 FROM TABLE GT_ITAB.
*        IF SY-SUBRC = 0.
*          COMMIT WORK.
*        ENDIF.
*        CLEAR GT_OTAB.
*      ENDIF.
*    ENDIF.
*    CLEAR : GT_ITAB.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_ZPPT0001_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_ITAB_TAGNR
*&      --> P_
*&---------------------------------------------------------------------*
FORM UPDATE_ZPPT0211_GI  USING PV_TAGNR
                               PV_GIFLG.

  DATA: LV_RESWK_G LIKE  ZPPT0134-GUBUN,
        LV_WERKS_G LIKE  ZPPT0134-GUBUN.

*& 공급플랜트---전선;비전선 구분...
  CLEAR  ZPPT0134.
  SELECT SINGLE A~GUBUN INTO LV_RESWK_G
           FROM ZPPT0134 AS A
                INNER JOIN MARC AS B
                  ON A~WERKS = B~WERKS
                  AND A~DISPO = B~DISPO
          WHERE A~WERKS = GT_ITAB-WERKS
            AND B~MATNR = GT_ITAB-MATNR.

*& 수요플랜트---전선;비전선 구분...
  CLEAR  ZPPT0134.
  SELECT SINGLE A~GUBUN INTO LV_WERKS_G
           FROM ZPPT0134 AS A
                INNER JOIN MARC AS B
                  ON A~WERKS = B~WERKS
                  AND A~DISPO = B~DISPO
          WHERE A~WERKS = GT_ITAB-R_WERKS
            AND B~MATNR = GT_ITAB-MATNR.
  CASE PV_GIFLG.
    WHEN 'Y'.
      IF LV_RESWK_G = 'B' AND LV_WERKS_G = 'C'.
*& 전선 꼬리표 생성...
        CLEAR  ZPPT0211.
        SELECT SINGLE * FROM ZPPT0211
                       WHERE WERKS = GT_ITAB-WERKS
                         AND TAGNR = PV_TAGNR.
        IF SY-SUBRC = 0.
          MOVE-CORRESPONDING ZPPT0211 TO ZPPT0001.
          ZPPT0001-WERKS  =  GT_ITAB-R_WERKS.
          ZPPT0001-MGVRG  =  ZPPT0211-TAGQTY.
          ZPPT0001-REMAIN =  ZPPT0211-CURQTY.
          ZPPT0001-GRFLG  = 'N'.
          ZPPT0001-GIFLG  = 'N'.
          INSERT ZPPT0001.
        ENDIF.


      ELSE.

*& 출고이전전기의 경우, 공급플랜트의 꼬리표 정보를 참조하여,
*&                      수요플랜트의 꼬리표 정보를 생성...
        CLEAR  ZPPT0211.
        SELECT SINGLE * FROM ZPPT0211
                       WHERE WERKS = GT_ITAB-WERKS
                         AND TAGNR = PV_TAGNR.
        IF SY-SUBRC = 0.
          ZPPT0211-WERKS =  GT_ITAB-R_WERKS.
          ZPPT0211-RUECK  =  ' '.
          ZPPT0211-GRFLG = 'N'.
          ZPPT0211-GIFLG = 'N'.
          ZPPT0211-STOKZ  = 'X'.
          INSERT ZPPT0211.
        ENDIF.
      ENDIF.

*& 공급플랜트의 출고 플래그를 'Y'로 설정한다.
      UPDATE ZPPT0211 SET: GIFLG   = 'Y'
                           MBLNR   = GW_HEADRET-MAT_DOC
                           GRINDAT = SY-DATUM
                           GRINTIM = SY-UZEIT
                           GRINNAM = SY-UNAME
                    WHERE  WERKS   = GT_ITAB-WERKS
                      AND  TAGNR   = PV_TAGNR.

    WHEN 'N'.
      IF LV_RESWK_G = 'B' AND LV_WERKS_G = 'C'.
*& 전선 꼬리표 삭제...
        DELETE FROM ZPPT0001 WHERE WERKS = GT_ITAB-R_WERKS
                               AND TAGNR = PV_TAGNR.
      ELSE.
*& 출고전기 취소의 경우, 수요플랜트의 꼬리표정보를 삭제...
        DELETE FROM ZPPT0211 WHERE WERKS = GT_ITAB-R_WERKS
                               AND TAGNR = PV_TAGNR.
      ENDIF.

*& 공급플랜트의 출고 플래그를 'N'로 설정한다.
      UPDATE ZPPT0211 SET: GIFLG   = 'N'
                           MBLNR   = ' '
                           GRINDAT = SY-DATUM
                           GRINTIM = SY-UZEIT
                           GRINNAM = SY-UNAME
                    WHERE  WERKS   = GT_ITAB-WERKS
                      AND  TAGNR   = PV_TAGNR.

    WHEN  OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_ZPPT0001_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_ITAB_TAGNR
*&      --> P_
*&---------------------------------------------------------------------*
FORM UPDATE_ZPPT0001_GI  USING PV_TAGNR
                               PV_GIFLG.
  DATA: LV_RESWK_G LIKE  ZPPT0134-GUBUN,
        LV_WERKS_G LIKE  ZPPT0134-GUBUN,
        LV_DISPO   LIKE  MARC-DISPO,
        LV_DISPO_R LIKE  MARC-DISPO,
        LV_AUFNR   LIKE  ZPPT0001-AUFNR.

  " 공급플랜트---전선;비전선 구분...
  CLEAR  ZPPT0134.
  SELECT SINGLE A~GUBUN INTO LV_RESWK_G
           FROM ZPPT0134 AS A
                INNER JOIN MARC AS B
                  ON A~WERKS = B~WERKS
                  AND A~DISPO = B~DISPO
          WHERE A~WERKS = GT_ITAB-WERKS
            AND B~MATNR = GT_ITAB-MATNR.

  " 수요플랜트---전선;비전선 구분...
  CLEAR  ZPPT0134.
  SELECT SINGLE A~GUBUN INTO LV_WERKS_G
           FROM ZPPT0134 AS A
                INNER JOIN MARC AS B
                  ON A~WERKS = B~WERKS
                  AND A~DISPO = B~DISPO
          WHERE A~WERKS = GT_ITAB-R_WERKS
            AND B~MATNR = GT_ITAB-MATNR.

  CASE PV_GIFLG.
    WHEN 'Y'.
      IF LV_RESWK_G = 'C' AND LV_WERKS_G = 'B'.
*& 비전선 꼬리표 생성...
        CLEAR  ZPPT0001.
        SELECT SINGLE *
          FROM ZPPT0001
         WHERE WERKS = GT_ITAB-WERKS
           AND TAGNR = PV_TAGNR.
        IF SY-SUBRC = 0.
          MOVE-CORRESPONDING ZPPT0001 TO ZPPT0211.
          ZPPT0211-WERKS   =  GT_ITAB-R_WERKS.
          ZPPT0211-TAGQTY  =  ZPPT0001-MGVRG.
          ZPPT0211-CURQTY  =  ZPPT0001-REMAIN.
          ZPPT0211-FINEQTY = ZPPT0001-REMAIN.
          ZPPT0211-GRFLG  = 'N'.
          ZPPT0211-GIFLG  = 'N'.
          INSERT ZPPT0211.
        ENDIF.

      ELSE.
*& 출고이전전기의 경우, 공급플랜트의 꼬리표 정보를 참조하여,
*&                      수요플랜트의 꼬리표 정보를 생성...
        CLEAR  ZPPT0001.
        SELECT SINGLE *
          FROM ZPPT0001
         WHERE WERKS = GT_ITAB-WERKS
           AND TAGNR = PV_TAGNR.
        IF SY-SUBRC = 0.
          CLEAR : LV_AUFNR.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = GT_ITAB-EBELN
            IMPORTING
              OUTPUT = LV_AUFNR.

          ZPPT0001-WERKS =  GT_ITAB-R_WERKS.
          ZPPT0001-AUFNR =  LV_AUFNR.
          ZPPT0001-GRFLG = 'N'.
          ZPPT0001-GIFLG = 'N'.
          INSERT ZPPT0001.
        ENDIF.

      ENDIF.

*& 공급플랜트의 출고 플래그를 'Y'로 설정한다.
      UPDATE ZPPT0001
      SET:   GIFLG   = 'Y'
             MBLNR   = GW_HEADRET-MAT_DOC
             GRINDAT = SY-DATUM
             GRINTIM = SY-UZEIT
             GRINNAM = SY-UNAME
      WHERE  WERKS   = GT_ITAB-WERKS
        AND  TAGNR   = PV_TAGNR.

    WHEN 'N'.
      IF LV_RESWK_G = 'C' AND LV_WERKS_G = 'B'.
*& 비전선 꼬리표 삭제...
        DELETE
        FROM   ZPPT0211
        WHERE  WERKS = GT_ITAB-R_WERKS
        AND    TAGNR = PV_TAGNR.
      ELSE.
*& 출고전기 취소의 경우, 수요플랜트의 꼬리표정보를 삭제...
        DELETE
        FROM    ZPPT0001
        WHERE   WERKS = GT_ITAB-R_WERKS
        AND     TAGNR = PV_TAGNR.
      ENDIF.

*& 공급플랜트의 출고 플래그를 'N'로 설정한다.
      UPDATE ZPPT0001
      SET:   GIFLG   = 'N'
             MBLNR   = ' '
             GRINDAT = SY-DATUM
             GRINTIM = SY-UZEIT
             GRINNAM = SY-UNAME
      WHERE  WERKS   = GT_ITAB-WERKS
        AND  TAGNR   = PV_TAGNR.

    WHEN  OTHERS.

  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_GOODSMVT_P
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_GOODSMVT_P.
  DATA : LV_END(1).
  DATA : LV_NEW(1).
  DATA : LV_BUDAT TYPE BUDAT.

  DATA : BEGIN OF LT_MSEG OCCURS 0,
           MBLNR LIKE MSEG-MBLNR,
           MJAHR LIKE MSEG-MJAHR,
           ZEILE LIKE MSEG-ZEILE,
           EBELN LIKE MSEG-EBELN,
           EBELP LIKE MSEG-EBELP,
           RSNUM LIKE MSEG-RSNUM,
           RSPOS LIKE MSEG-RSPOS,
           CHARG LIKE MSEG-CHARG,
         END OF LT_MSEG.

  DATA : LV_PSPNR     LIKE RKPF-PS_PSP_PNR, " WBS 신규 추가
         LV_PRCTR     LIKE PRPS-PRCTR,      " WBS 신규 추가
         LV_PARBU     LIKE RKPF-PARBU,      " WBS 신규 추가
         LV_PARGB     LIKE RKPF-PARGB,      " WBS 신규 추가
         LV_FUNC_AREA LIKE PRPS-FUNC_AREA,  " WBS 신규 추가
         LV_SAKNR     LIKE RESB-SAKNR,      " WBS 신규 추가
         LV_AUFNR     LIKE RESB-AUFNR,
         LV_LGPRO     LIKE MARC-LGPRO,
         LV_LGFSB     LIKE MARC-LGFSB,
         LV_BESKZ     LIKE MARC-BESKZ,
         LV_KOSTL     LIKE RKPF-KOSTL,
         LV_NPLNR     LIKE RKPF-NPLNR,
         LV_LGORT     LIKE RESB-LGORT.

  SORT GT_ITAB BY IFNUM IFSEQ.
  LOOP AT GT_ITAB.

*    AT NEW IFNUM.
*      LV_NEW = 'X'.
*    ENDAT.
*
*    IF LV_NEW = 'X'.
*      CLEAR : GT_ITEM_140, GT_ITEM_140[],
*              GW_HEAD_140, GW_CODE_140, GW_HEADRET,
*              GT_RET_140, GT_RET_140[].
*
*      CLEAR LV_NEW.
*    ENDIF.

    AT END OF IFNUM.
      LV_END = 'X'.
    ENDAT.

    GW_CODE_140-GM_CODE = '04'.

    GW_HEAD_140-PSTNG_DATE = GV_DATE.
    GW_HEAD_140-DOC_DATE   = GV_DATE.
    GW_HEAD_140-HEADER_TXT = GV_ZTEXT.

    GT_ITEM_140-MOVE_TYPE  = GT_ITAB-BWART.
    GT_ITEM_140-MATERIAL   = GT_ITAB-MATNR.    " 자재번호
    GT_ITEM_140-PLANT      = GT_ITAB-WERKS.    " 플랜트
    GT_ITEM_140-STGE_LOC   = GT_ITAB-LGORT.    " 저장위치
    GT_ITEM_140-BATCH      = GT_ITAB-CHARG.    " 출고플랜트 배치
    GT_ITEM_140-ENTRY_QNT  = GT_ITAB-ERFMG.    " 소요량
    GT_ITEM_140-ENTRY_UOM  = GT_ITAB-ERFME.    " 입력단위
    GT_ITEM_140-MOVE_PLANT = GT_ITAB-R_WERKS.  " 이동할플랜트
    GT_ITEM_140-MOVE_STLOC = GT_ITAB-R_LGORT.  " 이동할 저장위치

*--> I/F 받은 UMCHA 있더라도 입고 플랜트 마스터 확인 후 반영 - 20250327
*      GT_ITEM_140-MOVE_BATCH = GT_ITAB140-UMCHA.    " 입고플랜트 배치
    IF GT_ITAB-UMCHA IS NOT INITIAL.
      SELECT SINGLE MANDT
        INTO SY-MANDT
        FROM MARC
       WHERE WERKS = GT_ITAB-R_WERKS
         AND MATNR = GT_ITAB-MATNR
         AND XCHPF = 'X'.

      IF SY-SUBRC = 0.
        GT_ITEM_140-MOVE_BATCH = GT_ITAB-UMCHA.
      ENDIF.
    ENDIF.
*<-- I/F 받은 UMCHA 있더라도 입고 플랜트 마스터 확인 후 반영 - 20250327

    GT_ITEM_140-VENDOR     = GT_ITAB-LIFNR .   " 구매처
    GT_ITEM_140-CUSTOMER   = GT_ITAB-KUNNR .   " 고객번호
    GT_ITEM_140-SALES_ORD  = GT_ITAB-KDAUF .   " 판매오더번호
    GT_ITEM_140-VAL_SALES_ORD  = GT_ITAB-KDAUF .   " 판매오더번호
    GT_ITEM_140-S_ORD_ITEM = GT_ITAB-KDPOS .   " 판매오더 품목번호
    GT_ITEM_140-VAL_S_ORD_ITEM = GT_ITAB-KDPOS .   " 판매오더 품목번호
    GT_ITEM_140-ITEM_TEXT  = GT_ITAB-SGTXT.    " 품목텍스트
    GT_ITEM_140-GL_ACCOUNT = GT_ITAB-KONTO.    " G/L계정
    GT_ITEM_140-COSTCENTER = GT_ITAB-KOSTL.    " 코스트센터
    GT_ITEM_140-WBS_ELEM   = GT_ITAB-PS_POSID. " 작업분석구조요소
    IF GT_ITAB-BWART = '309' OR GT_ITAB-BWART = '310'.
      GT_ITEM_140-MOVE_MAT = GT_ITAB-UMMAT. " MTOM 시에만 필요
    ENDIF.
    GT_ITEM_140-PO_NUMBER  = GT_ITAB-EBELN.
    GT_ITEM_140-PO_ITEM    = GT_ITAB-EBELP.

    APPEND : GT_ITEM_140.
    CLEAR : GT_ITEM_140.

    GT_OTAB-IFNUM = GT_ITAB-IFNUM.
    GT_OTAB-IFSEQ = GT_ITAB-IFSEQ.
    GT_OTAB-EBELN = GT_ITAB-EBELN.
    GT_OTAB-EBELP = GT_ITAB-EBELP.
    GT_OTAB-CHARG = GT_ITAB-CHARG.
    APPEND GT_OTAB.

    IF LV_END = 'X'.
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          GOODSMVT_HEADER  = GW_HEAD_140
          GOODSMVT_CODE    = GW_CODE_140
        IMPORTING
          GOODSMVT_HEADRET = GW_HEADRET
        TABLES
          GOODSMVT_ITEM    = GT_ITEM_140
          RETURN           = GT_RET_140.

      IF GT_RET_140[] IS INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.

        CLEAR : LT_MSEG, LT_MSEG[].
        SELECT  MBLNR MJAHR ZEILE EBELN EBELP CHARG
          INTO CORRESPONDING FIELDS OF TABLE LT_MSEG
          FROM  MSEG
         WHERE  MBLNR = GW_HEADRET-MAT_DOC
           AND  MJAHR = GW_HEADRET-DOC_YEAR
           AND  XAUTO = ' '.

        LOOP AT GT_OTAB.
          READ TABLE LT_MSEG WITH KEY EBELN = GT_OTAB-EBELN
                                      EBELP = GT_OTAB-EBELP
                                      CHARG = GT_OTAB-CHARG.
          IF SY-SUBRC = 0.
            GT_OTAB-ZRESULT = '00'.
            GT_OTAB-ZMESSAGE = 'GI Success'.
            GT_OTAB-MBLNR = LT_MSEG-MBLNR.
            GT_OTAB-MJAHR = LT_MSEG-MJAHR.
            GT_OTAB-ZEILE = LT_MSEG-ZEILE.
            MODIFY GT_OTAB TRANSPORTING ZRESULT ZMESSAGE
                                        MBLNR MJAHR ZEILE.
          ENDIF.
        ENDLOOP.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        LOOP AT GT_OTAB.
          IF GT_OTAB-IFNUM = GT_ITAB-IFNUM.
            GT_OTAB-ZRESULT = '02'.
            GT_OTAB-ZMESSAGE = GT_RET_140-MESSAGE.
            MODIFY GT_OTAB TRANSPORTING ZRESULT ZMESSAGE.
          ENDIF.
        ENDLOOP.
      ENDIF.
      CLEAR LV_END.
      CLEAR : GT_ITEM_140, GT_ITEM_140[],
              GW_HEAD_140, GW_CODE_140, GW_HEADRET,
              GT_RET_140, GT_RET_140[].
    ENDIF.
    CLEAR : GT_OTAB.
    CLEAR : GT_ITAB.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_GOODSMVT_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_GOODSMVT_C.

  DATA : LV_END(1).
  DATA : LV_NEW(1).
  DATA : LV_BUDAT TYPE BUDAT.
  DATA : LV_TABIX TYPE SY-TABIX.
  DATA : LV_MBLNR TYPE MBLNR.

  DATA : BEGIN OF LT_MSEG_C OCCURS 0,
           MBLNR LIKE MSEG-MBLNR,
           MJAHR LIKE MSEG-MJAHR,
           ZEILE LIKE MSEG-ZEILE,
           SMBLN LIKE MSEG-SMBLN,
           SJAHR LIKE MSEG-SJAHR,
           SMBLP LIKE MSEG-SMBLP,
         END OF LT_MSEG_C.

  SORT GT_ITAB BY IFNUM MBLNR MJAHR ZEILE.
  LOOP AT GT_ITAB.

*    AT NEW IFNUM.
*      LV_NEW = 'X'.
*    ENDAT.
*
*    IF LV_NEW = 'X'.
*      CLEAR : GW_HEAD_140_2, GW_HEADRET_CANC,
*              GT_RET2_140, GT_RET2_140[],
*              GW_MATDOCITEM, GW_MATDOCITEM[].
*
*      CLEAR : LV_NEW.
*    ENDIF.

    AT END OF : IFNUM.
      LV_END = 'X'.
    ENDAT.

    GW_HEAD_140_2-MAT_DOC    = GT_ITAB-MBLNR.
    GW_HEAD_140_2-DOC_YEAR   = GT_ITAB-MJAHR.
    GW_HEAD_140_2-HEADER_TXT  = GV_ZTEXT.

    CLEAR : LV_BUDAT.
    SELECT SINGLE BUDAT
      INTO LV_BUDAT
      FROM MKPF
     WHERE MBLNR = GT_ITAB-MBLNR
       AND MJAHR = GT_ITAB-MJAHR.

    GW_HEAD_140_2-PSTNG_DATE = LV_BUDAT.

    GW_MATDOCITEM-MATDOC_ITEM = GT_ITAB-ZEILE.
    APPEND : GW_MATDOCITEM.

    SELECT SINGLE EBELN EBELP
      INTO (GT_ITAB-EBELN, GT_ITAB-EBELP)
      FROM MSEG
     WHERE MBLNR = GT_ITAB-MBLNR
       AND MJAHR = GT_ITAB-MJAHR
       AND ZEILE = GT_ITAB-ZEILE.

    GT_OTAB-IFNUM = GT_ITAB-IFNUM.
    GT_OTAB-IFSEQ = GT_ITAB-IFSEQ.
    GT_OTAB-EBELN = GT_ITAB-EBELN.
    GT_OTAB-EBELP = GT_ITAB-EBELP.
    GT_OTAB-MBLNR = GT_ITAB-MBLNR.
    GT_OTAB-MJAHR = GT_ITAB-MJAHR.
    GT_OTAB-ZEILE = GT_ITAB-ZEILE.
    GT_OTAB-CHARG = GT_ITAB-CHARG.
    APPEND GT_OTAB.

*--> 문서번호 바뀔 시 LV_END 체크
    IF LV_END IS INITIAL.
      CLEAR : LV_TABIX, LV_MBLNR.
      LV_MBLNR = GT_ITAB-MBLNR.
      LV_TABIX = SY-TABIX + 1.
      READ TABLE GT_ITAB INDEX LV_TABIX.
      IF SY-SUBRC = 0.
        IF GT_ITAB-MBLNR <> LV_MBLNR.
          LV_END = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.
*<-- 문서번호 바뀔 시 LV_END 체크

    IF LV_END = 'X'.
      CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
        EXPORTING
          MATERIALDOCUMENT    = GW_HEAD_140_2-MAT_DOC
          MATDOCUMENTYEAR     = GW_HEAD_140_2-DOC_YEAR
          GOODSMVT_PSTNG_DATE = GW_HEAD_140_2-PSTNG_DATE
        IMPORTING
          GOODSMVT_HEADRET    = GW_HEADRET_CANC
        TABLES
          RETURN              = GT_RET2_140
          GOODSMVT_MATDOCITEM = GW_MATDOCITEM.

      IF GT_RET2_140[] IS INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.

        CLEAR : LT_MSEG_C, LT_MSEG_C[].
        SELECT  MBLNR MJAHR ZEILE SMBLN SJAHR SMBLP
          INTO CORRESPONDING FIELDS OF TABLE LT_MSEG_C
          FROM  MSEG
         WHERE  MBLNR = GW_HEADRET_CANC-MAT_DOC
           AND  MJAHR = GW_HEADRET_CANC-DOC_YEAR
           AND  SMBLN = GW_HEAD_140_2-MAT_DOC
           AND  SJAHR = GW_HEAD_140_2-DOC_YEAR
           AND  XAUTO = ' '.

        LOOP AT GT_OTAB.
          READ TABLE LT_MSEG_C WITH KEY SMBLN = GT_OTAB-MBLNR
                                        SJAHR = GT_OTAB-MJAHR
                                        SMBLP = GT_OTAB-ZEILE.
          IF SY-SUBRC = 0.
            GT_OTAB-ZRESULT = '00'.
            GT_OTAB-ZMESSAGE = 'GI Cancel Success'.
            GT_OTAB-MBLNR_C = LT_MSEG_C-MBLNR.
            GT_OTAB-MJAHR_C = LT_MSEG_C-MJAHR.
            GT_OTAB-ZEILE_C = LT_MSEG_C-ZEILE.
            MODIFY GT_OTAB TRANSPORTING ZRESULT ZMESSAGE
                                        MBLNR_C MJAHR_C ZEILE_C.
          ENDIF.
        ENDLOOP.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        LOOP AT GT_OTAB.
          IF GT_OTAB-IFNUM = GT_ITAB-IFNUM AND
             GT_OTAB-MJAHR = GT_ITAB-MJAHR AND
             GT_OTAB-MBLNR = GT_ITAB-MBLNR.
            GT_OTAB-ZRESULT = '02'.
            GT_OTAB-ZMESSAGE = GT_RET2_140-MESSAGE.
            MODIFY GT_OTAB TRANSPORTING ZRESULT ZMESSAGE.
          ENDIF.
        ENDLOOP.
      ENDIF.
      CLEAR : LV_END.
      CLEAR : GW_HEAD_140_2, GW_HEADRET_CANC,
              GT_RET2_140, GT_RET2_140[],
              GW_MATDOCITEM, GW_MATDOCITEM[].
    ENDIF.
    CLEAR : GT_OTAB.
    CLEAR : GT_ITAB.
  ENDLOOP.
ENDFORM.
