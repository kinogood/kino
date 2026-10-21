*&---------------------------------------------------------------------*
*&  Include           MZQM0020F03
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LIEFERUNG_LESEN
*&---------------------------------------------------------------------*
*       textt test
*----------------------------------------------------------------------*
FORM LIEFERUNG_LESEN USING VALUE(P_VBELN)  LIKE RQM01-LS_VBELN
                           VALUE(P_POSNR)  LIKE RQM01-LS_POSNR
                  CHANGING VALUE(P_VBDKL)  LIKE VBDKL
                           VALUE(P_VBDPL)  LIKE VBDPL.
* local variable
  DATA: VBCO3 TYPE  VBCO3.
  DATA: BEGIN OF L_VBDPL_TAB OCCURS 01.
          INCLUDE STRUCTURE VBDPL.
  DATA: END OF L_VBDPL_TAB.

  VBCO3-VBELN = P_VBELN.
  IF NOT P_POSNR IS INITIAL.
    VBCO3-POSNR = P_POSNR.
  ELSE.
    MESSAGE W025(QM).
  ENDIF.


  CALL FUNCTION 'RV_DELIVERY_PRINT_VIEW'
    EXPORTING
      COMWA = VBCO3
    IMPORTING
      KOPF  = P_VBDKL
    TABLES
      POS   = L_VBDPL_TAB.

  IF P_VBDKL-VBELN IS INITIAL.
    MESSAGE E023(QM) WITH P_VBELN.
  ENDIF.

  IF NOT P_POSNR IS INITIAL.
    LOOP AT L_VBDPL_TAB WHERE POSNR = P_POSNR.
      EXIT.
    ENDLOOP.
    IF SY-SUBRC IS INITIAL.
      P_VBDPL = L_VBDPL_TAB.
    ELSE.
      MESSAGE E022(QM) WITH P_VBELN P_POSNR.
    ENDIF.
  ENDIF.

* 영업그룹
  SELECT SINGLE VKGRP
           INTO RQM01-VKGRP
           FROM LIPS
          WHERE VBELN = P_VBELN
            AND POSNR = P_POSNR.

ENDFORM.                               " LIEFERUNG_LESEN
*&---------------------------------------------------------------------*
*&      Form  GET_VBELN
*&---------------------------------------------------------------------*
*       납품오더리스트
*----------------------------------------------------------------------*
FORM GET_VBELN .

  DATA: LV_CNT TYPE I,
        LV_LFIMG TYPE LIPS-LFIMG,
        LV_INDEX TYPE SY-TABIX.
  CHECK GS_311-KDAUF IS NOT INITIAL.
*  CHECK GS_311-KDPOS IS NOT INITIAL.

* SD 문서: 납품: 품목 데이터
  SELECT * FROM LIPS
           INTO CORRESPONDING FIELDS OF TABLE GT_VBELN
          WHERE VGBEL EQ GS_311-KDAUF
            AND LFIMG NE SPACE.         "수량없는 항목 제외

*  LOOP AT GT_VBELN.
**   SD 문서: 납품 헤더데이타
*    SELECT SINGLE * FROM LIKP
*                    INTO CORRESPONDING FIELDS OF GS_VBELN
*                   WHERE VBELN EQ GT_VBELN-VBELN
*                     AND LFART NE 'LF1'
*                     AND LFART NE 'LF2'
*                     AND LFART NE 'LF3'
*                     AND LFART NE 'LF'.
*    IF SY-SUBRC EQ 0.
*      GT_VBELN-KUNAG     = GS_VBELN-KUNAG.
*      GT_VBELN-WADAT_IST = GS_VBELN-WADAT_IST.
*      GT_VBELN-LFART     = GS_VBELN-LFART.
*      GT_VBELN-LFDAT     = GS_VBELN-LFDAT.
*      MODIFY GT_VBELN.
*    ENDIF.
*
*    CLEAR: GT_VBELN.
*  ENDLOOP.

* 1건 이상이면 팝업창을 열어서 선택하도록 한다.
  DESCRIBE TABLE GT_VBELN LINES LV_CNT.
  IF LV_CNT > 1.
    CALL SCREEN '0312' STARTING AT 10  8
                       ENDING AT 100  20.
  ELSE.
    READ TABLE GT_VBELN INDEX 1.
    CHECK SY-SUBRC EQ 0.
    GS_311-VBELN = GT_VBELN-VBELN.
    GS_311-POSNR = GT_VBELN-POSNR.
    GS_311-CHARG = GT_VBELN-CHARG.
    GS_311-GELIM = GT_VBELN-LFIMG.
    GS_311-MGEIN = GT_VBELN-MEINS.
    GS_101-MATNR = GT_VBELN-MATNR.
    GS_311-KDPOS = GT_VBELN-VGPOS.
    PERFORM GET_MATNR_DESC USING GS_101-MATNR
                                 GS_101-MAKTX.
  ENDIF.

* 단위 및 제품군을 읽어온다.
  PERFORM GET_SPART USING    GS_101-MATNR
                    CHANGING GS_311-SPGCD      "제품군
                             GS_311-MGEIN.     "단위

* 제품군 내역을 읽어온다.
  PERFORM GET_SPGCD_DESC USING    GS_311-SPGCD
                         CHANGING GS_311-SPGCDT.

ENDFORM.                    " GET_VBELN
*&---------------------------------------------------------------------*
*&      Form  GET_PO
*&---------------------------------------------------------------------*
*       PO번호 리스트
*----------------------------------------------------------------------*
FORM GET_PO .

  CHECK GS_311-KDAUF IS NOT INITIAL.
  CHECK GS_311-KDPOS IS NOT INITIAL.

  SELECT SINGLE BSTKD BSTDK
           INTO (GS_311-FERTAUFNR, GS_311-BSTDK)
           FROM VBKD
          WHERE VBELN EQ GS_311-KDAUF.

ENDFORM.                    " GET_PO
*&---------------------------------------------------------------------*
*&      Form  GET_TAGNR
*&---------------------------------------------------------------------*
*       꼬리표 번호리스트
*----------------------------------------------------------------------*
FORM GET_TAGNR .

  DATA: LV_CNT   TYPE I,
        LV_MTART LIKE MARA-MTART.
  CHECK GS_311-KDAUF IS NOT INITIAL.
  CHECK GS_311-KDPOS IS NOT INITIAL.
  CHECK GT_VBELN     IS NOT INITIAL.

  CLEAR: GT_TAGNR, GT_TAGNR[].

  SELECT COUNT(*) FROM MARA
                 WHERE MATNR EQ GT_VBELN-MATNR
                   AND DPCBT EQ 'A'.
  IF SY-SUBRC EQ 0.
    MESSAGE S001 WITH '팩터배치는 꼬리표조회가 불가능합니다.'.
  ENDIF.

* 전선/부품 구분
  SELECT SINGLE MTART
           FROM MARA
           INTO LV_MTART
          WHERE MATNR EQ GT_VBELN-MATNR.

  IF LV_MTART+0(2) EQ 'MC'. "전선
    SELECT * FROM ZPPT0001
             APPENDING CORRESPONDING FIELDS OF TABLE GT_TAGNR
            WHERE CHARG EQ GT_VBELN-CHARG
              AND MATNR EQ GT_VBELN-MATNR
              AND WERKS EQ GT_VBELN-WERKS_M.
  ELSE.
    SELECT TAGNR2 AS TAGNR MATNR CHARG WERKS
           FROM ZPPT0203
           APPENDING CORRESPONDING FIELDS OF TABLE GT_TAGNR
          WHERE CHARG EQ GT_VBELN-CHARG
            AND MATNR EQ GT_VBELN-MATNR
            AND WERKS EQ GT_VBELN-WERKS_M.
  ENDIF.

* 납품오더/품목으로 조회해도 됨 문제가 생기면 바꿀것
  LOOP AT GT_TAGNR.
    SELECT SINGLE * FROM ZQMT0107
                   WHERE WERKS EQ GT_TAGNR-WERKS_M
                     AND MATNR EQ GT_TAGNR-MATNR
                     AND CHARG EQ GT_TAGNR-CHARG.
    IF SY-SUBRC EQ 0.
      GT_TAGNR-DRUM   = ZQMT0107-DRUM.
      GT_TAGNR-SERIAL = ZQMT0107-SERIAL.
      MODIFY GT_TAGNR.
    ENDIF.
    CLEAR: GT_TAGNR.
  ENDLOOP.

  DESCRIBE TABLE GT_TAGNR LINES LV_CNT.
  IF LV_CNT > 1.
    CALL SCREEN '0313' STARTING AT 10  8
                       ENDING AT 100  20.
  ELSE.
    READ TABLE GT_TAGNR INDEX 1.
    GS_311-TAGNR  = GT_TAGNR-TAGNR.
    GS_311-DRUM   = GT_TAGNR-DRUM.
    GS_311-SERIAL = GT_TAGNR-SERIAL.
  ENDIF.

ENDFORM.                    " GET_TAGNR
*&---------------------------------------------------------------------*
*&      Form  GET_MCNO
*&---------------------------------------------------------------------*
*       기계번호
*----------------------------------------------------------------------*
FORM GET_MCNO .

  CHECK GS_311-KDAUF IS NOT INITIAL.
  CHECK GS_311-KDPOS IS NOT INITIAL.

  SELECT SINGLE EQUNR
           FROM EQBS
           INTO GS_311-MCNO
          WHERE KDAUF EQ GS_311-KDAUF
            AND KDPOS EQ GS_311-KDPOS.

ENDFORM.                    " GET_MCNO
*&---------------------------------------------------------------------*
*&      Form  GET_GS_DISPLAY
*&---------------------------------------------------------------------*
*       선택한 납품오더를 가져온다.
*----------------------------------------------------------------------*
FORM GET_GS_DISPLAY .

  DATA: LT_ROW_NO TYPE LVC_T_ROID,
        LS_ROW_NO TYPE LVC_S_ROID,
        LV_CNT TYPE I.
  CLEAR: LT_ROW_NO, LT_ROW_NO[].

  CALL METHOD G_GRID_312->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_NO.

  DESCRIBE TABLE LT_ROW_NO LINES LV_CNT.
  IF LV_CNT EQ 0.
    MESSAGE E001 WITH '선택한 행이 없습니다.'.
    EXIT.
  ENDIF.

  LOOP AT LT_ROW_NO INTO LS_ROW_NO.
*   판매오더로 등록시(멀티선택가능)
    IF GV_MULTI_INPUT EQ 'X'.
      CLEAR GS_320.
      READ TABLE GT_320 INTO GS_320 INDEX LS_ROW_NO-ROW_ID.
      GS_MTBLN-KDAUF   = GS_320-VGBEL.   "판매오더번호
      GS_MTBLN-VBELN   = GS_320-VBELN.   "납품오더
      GS_MTBLN-POSNR   = GS_320-POSNR.   "납품오더 품목
      GS_MTBLN-CHARG   = GS_320-CHARG.   "배치번호
      GS_MTBLN-GELIM   = GS_320-LFIMG.   "납품수량
      GS_MTBLN-MGEIN   = GS_320-MEINS.   "단위
      GS_MTBLN-KDPOS   = GS_320-VGPOS.   "판매오더품목
      GS_MTBLN-MATNR   = GS_320-MATNR.   "자재번호
      GS_MTBLN-MAKTX   = GS_320-MAKTX.   "자재내역
      GS_MTBLN-WERKS_M = GS_320-WERKS.   "플랜트
      GS_MTBLN-WERKST  = GS_320-WERKT.   "플랜트내역
      APPEND GS_MTBLN TO GT_MTBLN.
    ELSE.
      CLEAR GT_VBELN.
      READ TABLE GT_VBELN INDEX LS_ROW_NO-ROW_ID.
    ENDIF.
    CLEAR: LS_ROW_NO, GS_MTBLN.
  ENDLOOP.

ENDFORM.                    " GET_GS_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  FILL_FIELD_CATEGORY_POPU
*&---------------------------------------------------------------------*
*       field catalog 설정
*----------------------------------------------------------------------*
FORM FILL_FIELD_CATEGORY_POPU  USING    VALUE(P_TABLE)
                               CHANGING PT_FIELDCAT TYPE LVC_T_FCAT.
  CLEAR: PT_FIELDCAT, PT_FIELDCAT[].

  CALL FUNCTION 'Z_QM_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM              = SY-REPID
      I_TABLE                = P_TABLE
      I_BYPASSING_BUFFER     = 'X'
      I_CLIENT_NEVER_DISPLAY = 'X'
    CHANGING
      GT_FIELDCAT            = PT_FIELDCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  IF SY-SUBRC NE 0.
    MESSAGE A001 WITH 'Field Catalog를 찾을 수 없습니다.'.
  ENDIF.

ENDFORM.                    " FILL_FIELD_CATEGORY_POPU
*&---------------------------------------------------------------------*
*&      Form  PRO_LAYOUT_POPU
*&---------------------------------------------------------------------*
*       alv layout 설정
*----------------------------------------------------------------------*
FORM PRO_LAYOUT_POPU  USING    P_LAYOCAT TYPE LVC_S_LAYO.

  P_LAYOCAT-CWIDTH_OPT = 'X'.
  P_LAYOCAT-SEL_MODE = 'A'.
  P_LAYOCAT-SMALLTITLE = 'X'.

ENDFORM.                    " PRO_LAYOUT_POPU
*&---------------------------------------------------------------------*
*&      Form  GET_CHOSE_TANGR
*&---------------------------------------------------------------------*
*       선택한 꼬리표번호를 가져온다.
*----------------------------------------------------------------------*
FORM GET_CHOSE_TANGR .

  DATA: LT_ROW_NO TYPE LVC_T_ROID,
        LS_ROW_NO TYPE LVC_S_ROID,
        LV_CNT TYPE I.
  CLEAR: LT_ROW_NO, LT_ROW_NO.

  CALL METHOD G_GRID_313->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_NO.

  DESCRIBE TABLE LT_ROW_NO LINES LV_CNT.
  IF LV_CNT EQ 0.
    MESSAGE E001 WITH '선택한 행이 없습니다.'.
    EXIT.
  ENDIF.

  LOOP AT LT_ROW_NO INTO LS_ROW_NO.
    CLEAR: GT_TAGNR.
    READ TABLE GT_TAGNR INDEX LS_ROW_NO-ROW_ID.
  ENDLOOP.

ENDFORM.                    " GET_CHOSE_TANGR
*&---------------------------------------------------------------------*
*&      Form  EXE_CACL
*&---------------------------------------------------------------------*
*       취소
*----------------------------------------------------------------------*
FORM EXE_CACL .

  CASE SY-DYNNR.
    WHEN '0311' OR '0315'.  "불만제품 등록
      CLEAR: GS_311.

    WHEN '0316'.
      CLEAR: GS_316.

    WHEN '0312'.  "납품오더 리스트
      PERFORM OBJ_DESTROY CHANGING G_CUSTOM_C312
                                   G_GRID_312.

    WHEN '0313'.  "꼬리표번호 리스트
      PERFORM OBJ_DESTROY CHANGING G_CUSTOM_C313
                                   G_GRID_313.

    WHEN '0320' OR '0322'.  "판매오더로 불량제품 등록
      CLEAR: GS_102-KDAUF,   GS_102-VBELN,
             GV_MULTI_INPUT, GS_311.

  ENDCASE.


  LEAVE TO SCREEN 0.

ENDFORM.                    " EXE_CACL
*&---------------------------------------------------------------------*
*&      Form  OBJ_DESTROY
*&---------------------------------------------------------------------*
*       ALV object clear
*----------------------------------------------------------------------*
FORM OBJ_DESTROY  CHANGING P_CUSTOM TYPE REF TO CL_GUI_CUSTOM_CONTAINER
                           P_GRID   TYPE REF TO CL_GUI_ALV_GRID.

  CALL METHOD P_CUSTOM->FREE.
  CLEAR: P_CUSTOM, P_GRID.

ENDFORM.                    " OBJ_DESTROY
*&---------------------------------------------------------------------*
*&      Form  LIEFERUNG_TO_QMEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM LIEFERUNG_TO_QMEL USING VALUE(P_VBDKL) LIKE VBDKL
                             VALUE(P_VBDPL) LIKE VBDPL
                    CHANGING       P_RQM01  LIKE RQM01.

  P_RQM01-KUNUM  = P_VBDKL-KUNAG.
  P_RQM01-BSTNK  = P_VBDPL-BSTKD.
  P_RQM01-BSTDK  = P_VBDKL-BSTDK.
  P_RQM01-VKORG  = P_VBDKL-VKORG.
  P_RQM01-VTWEG  = P_VBDPL-VTWEG.
  P_RQM01-SPART  = P_VBDPL-SPART.
  P_RQM01-VKBUR  = P_VBDPL-VKBUR.
  P_RQM01-KDMAT  = P_VBDPL-IDNKD.
  P_RQM01-MATNR  = P_VBDPL-MATNR.
  P_RQM01-MAWERK = P_VBDPL-WERKS.
  P_RQM01-CHARG  = P_VBDPL-CHARG.

* check
  IF NOT P_VBDPL-MATNR IS INITIAL.
    PERFORM MATERIAL_CHECK USING P_VBDPL-MATNR.
  ENDIF.

  IF NOT P_VBDPL-MATNR IS INITIAL AND
     NOT P_VBDPL-WERKS IS INITIAL.
    PERFORM MATERIAL_WERK_CHECK USING P_VBDPL-MATNR
                                      P_VBDPL-WERKS.
  ENDIF.

* Charge
  IF NOT P_RQM01-CHARG IS INITIAL.
    SELECT SINGLE * INTO MCHA
                    FROM MCHA
                   WHERE MATNR EQ P_RQM01-MATNR
                     AND WERKS EQ P_RQM01-MAWERK
                     AND CHARG EQ P_RQM01-CHARG.
    IF SY-SUBRC EQ 0.
      P_RQM01-LICHN = MCHA-LICHA.
    ENDIF.
    P_RQM01-LGORTCHAR = P_VBDPL-LGORT.
  ELSE.
    P_RQM01-LGORTVORG = P_VBDPL-LGORT.
  ENDIF.

  IF P_VBDPL-LFIMG > 0.
    P_RQM01-RKMNG = P_VBDPL-LFIMG.
    P_RQM01-BZMNG = P_VBDPL-LFIMG.
  ELSE.
    IF P_VBDPL-KCMENG > 0.
      P_RQM01-RKMNG = P_VBDPL-KCMENG.
      P_RQM01-BZMNG = P_VBDPL-KCMENG.
    ENDIF.
  ENDIF.

  IF NOT P_VBDPL-VRKME IS INITIAL.
    P_RQM01-MGEIN = P_VBDPL-VRKME.
  ELSEIF NOT P_RQM01-RKMNG IS INITIAL.
    P_RQM01-MGEIN = P_VBDPL-MEINS.
  ENDIF.

  P_RQM01-LS_KDAUF = P_VBDPL-VBELN_VAUF.
  P_RQM01-LS_KDPOS = P_VBDPL-POSNR_VAUF.

ENDFORM.                               " LIEFERUNG_TO_QMEL
*&---------------------------------------------------------------------*
*&      Form  MATERIAL_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MATERIAL_CHECK USING  VALUE(P_MATNR).

* local variable
  DATA: LS_MTCOM LIKE MTCOM,
        LS_MTCOR LIKE MTCOR.
  DATA: BEGIN OF L_DUMMY_TAB OCCURS 0,
        DUMMY(1),
        END   OF L_DUMMY_TAB.

  CHECK NOT P_MATNR IS INITIAL.

  LS_MTCOM-KENNG = 'MARA '.
  LS_MTCOM-MATNR = P_MATNR.

  CALL FUNCTION 'MATERIAL_READ'
    EXPORTING
      SCHLUESSEL           = LS_MTCOM
    IMPORTING
      RETURN               = LS_MTCOR
    TABLES
      SEQMAT01             = L_DUMMY_TAB
    EXCEPTIONS
      ACCOUNT_NOT_FOUND    = 01
      BATCH_NOT_FOUND      = 02
      FORECAST_NOT_FOUND   = 03
      LOCK_ON_ACCOUNT      = 04
      LOCK_ON_MATERIAL     = 05
      LOCK_ON_PLANT        = 06
      LOCK_ON_SALES        = 07
      LOCK_ON_SLOC         = 08
      LOCK_SYSTEM_ERROR    = 09
      MATERIAL_NOT_FOUND   = 10
      PLANT_NOT_FOUND      = 11
      SALES_NOT_FOUND      = 12
      SLOC_NOT_FOUND       = 13
      SLOCNUMBER_NOT_FOUND = 14
      SLOCTYPE_NOT_FOUND   = 15
      TEXT_NOT_FOUND       = 16
      UNIT_NOT_FOUND       = 17.

  CASE SY-SUBRC.
    WHEN 10.
      MESSAGE E005(QM) WITH P_MATNR.
  ENDCASE.

  IF NOT LS_MTCOR-LVORM IS INITIAL.
    MESSAGE W008(M3).
  ENDIF.

ENDFORM.                               " MATERIAL_CHECK
*&---------------------------------------------------------------------*
*&      Form  MATERIAL_WERK_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MATERIAL_WERK_CHECK USING VALUE(P_MATNR)
                               VALUE(P_WERK).

* local variable
  DATA: LS_MTCOM LIKE  MTCOM.
  DATA: BEGIN OF L_DUMMY_TAB OCCURS 0,
          DUMMY(1),
        END OF L_DUMMY_TAB.

  CHECK ( NOT P_MATNR IS INITIAL AND NOT P_WERK IS INITIAL ).

  LS_MTCOM-KENNG = 'MARC '.
  LS_MTCOM-MATNR = P_MATNR.
  LS_MTCOM-WERKS = P_WERK.

  CALL FUNCTION 'MATERIAL_READ'
    EXPORTING
      SCHLUESSEL           = LS_MTCOM
    TABLES
      SEQMAT01             = L_DUMMY_TAB
    EXCEPTIONS
      ACCOUNT_NOT_FOUND    = 01
      BATCH_NOT_FOUND      = 02
      FORECAST_NOT_FOUND   = 03
      LOCK_ON_ACCOUNT      = 04
      LOCK_ON_MATERIAL     = 05
      LOCK_ON_PLANT        = 06
      LOCK_ON_SALES        = 07
      LOCK_ON_SLOC         = 08
      LOCK_SYSTEM_ERROR    = 09
      MATERIAL_NOT_FOUND   = 10
      PLANT_NOT_FOUND      = 11
      SALES_NOT_FOUND      = 12
      SLOC_NOT_FOUND       = 13
      SLOCNUMBER_NOT_FOUND = 14
      SLOCTYPE_NOT_FOUND   = 15
      TEXT_NOT_FOUND       = 16
      UNIT_NOT_FOUND       = 17.

  CASE SY-SUBRC.
    WHEN  11.
      MESSAGE E004(QM) WITH P_MATNR
                            P_WERK.
    WHEN  10.
      MESSAGE E005(QM) WITH P_MATNR.
  ENDCASE.

ENDFORM.                               " MATERIAL_WERK_CHECK
*&---------------------------------------------------------------------*
*&      Form  GET_CHOSE_PO
*&---------------------------------------------------------------------*
*       선택된 PO를 가져온다.
*----------------------------------------------------------------------*
FORM GET_CHOSE_PO .

* local variable
  DATA: LT_ROW_NO TYPE LVC_T_ROID,
        LS_ROW_NO TYPE LVC_S_ROID.
  CLEAR: LT_ROW_NO, LT_ROW_NO.

  CALL METHOD G_GRID_314->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_NO.

  DESCRIBE TABLE LT_ROW_NO LINES G_LINES.
  IF G_LINES EQ 0.
    MESSAGE E001 WITH '선택한 행이 없습니다.'.
    EXIT.
  ENDIF.

  LOOP AT LT_ROW_NO INTO LS_ROW_NO.
    CLEAR GT_PO.
    READ TABLE GT_PO INDEX LS_ROW_NO-ROW_ID.
  ENDLOOP.

ENDFORM.                    " GET_CHOSE_PO
*&---------------------------------------------------------------------*
*&      Form  GET_CHARG
*&---------------------------------------------------------------------*
*       배치번호
*----------------------------------------------------------------------*
FORM GET_CHARG .

  SELECT SINGLE CHARG
           FROM ZPPT0001
           INTO GS_311-CHARG
          WHERE TAGNR EQ GS_311-TAGNR.

ENDFORM.                    " GET_CHARG
*&---------------------------------------------------------------------*
*&      Form  GET_DMNO
*&---------------------------------------------------------------------*
*       드럼번호
*----------------------------------------------------------------------*
FORM GET_DMNO .

  CHECK GS_311-DRUM IS INITIAL.

  SELECT SINGLE DRUM SERIAL
           FROM ZQMT0107
           INTO (GS_311-DRUM, GS_311-SERIAL)
          WHERE TAGNR EQ GS_311-TAGNR
            AND CHARG EQ GS_311-CHARG.

ENDFORM.                    " GET_DMNO
*&---------------------------------------------------------------------*
*&      Form  GET_VBELN_CHARG
*&---------------------------------------------------------------------*
*       납품오더리스트
*----------------------------------------------------------------------*
FORM GET_VBELN_CHARG .

* local variable
  DATA: LV_CNT TYPE I.
  CHECK GS_311-CHARG IS NOT INITIAL.

  SELECT A~VBELN A~POSNR A~WERKS A~MATNR A~CHARG B~KUNAG A~VGBEL
         A~VGPOS A~LFIMG B~WADAT_IST B~LFART A~MEINS
    FROM LIPS AS A
    JOIN LIKP AS B
      ON A~VBELN EQ B~VBELN
    INTO CORRESPONDING FIELDS OF TABLE GT_VBELN
   WHERE A~CHARG EQ GS_311-CHARG
     AND A~MATNR EQ GS_101-MATNR
     AND A~WERKS EQ GS_101-WERKS_M
     AND LFART NE 'LR1'
     AND LFART NE 'LR2'
     AND LFART NE 'LR3'
     AND LFART NE 'LR'.

  IF GS_311-KDAUF IS NOT INITIAL.
    DELETE GT_VBELN WHERE VGBEL <> GS_311-KDAUF.
  ENDIF.

  DESCRIBE TABLE GT_VBELN LINES LV_CNT.
  IF LV_CNT > 1.
    CALL SCREEN '0312' STARTING AT 10  8
                       ENDING AT 100  20.
  ELSE.
    READ TABLE GT_VBELN INDEX 1.
    CHECK SY-SUBRC EQ 0.
    GS_311-VBELN = GT_VBELN-VBELN.
    GS_311-POSNR = GT_VBELN-POSNR.
    GS_311-CHARG = GT_VBELN-CHARG.
    GS_311-GELIM = GT_VBELN-LFIMG.
    GS_311-MGEIN = GT_VBELN-MEINS.
  ENDIF.

ENDFORM.                    " GET_VBELN_CHARG
*&---------------------------------------------------------------------*
*&      Form  GET_KDAUF_CHARG
*&---------------------------------------------------------------------*
*       판매오더리스트
*----------------------------------------------------------------------*
FORM GET_KDAUF_CHARG .

* local variable
  DATA: LV_VGBEL TYPE LIPS-VGBEL,
        LV_VGPOS TYPE LIPS-VGPOS.
  CHECK GS_311-VBELN IS NOT INITIAL.

  CASE SY-DYNNR.
*   불만제품 등록
    WHEN '0311'.
      SELECT SINGLE VGBEL VGPOS
               FROM LIPS
               INTO (LV_VGBEL, LV_VGPOS)
              WHERE VBELN EQ GS_311-VBELN
                AND POSNR EQ GS_311-POSNR.
      IF SY-SUBRC EQ 0.
        GS_311-KDAUF = LV_VGBEL.
        GS_311-KDPOS = LV_VGPOS.
      ENDIF.

*   배치등록 (판매오더번호가 고정되어 있음)
    WHEN '0315'.
      SELECT SINGLE VGBEL VGPOS
               FROM LIPS
               INTO (LV_VGBEL, LV_VGPOS)
              WHERE VBELN EQ GS_311-VBELN
                AND POSNR EQ GS_311-POSNR
                AND VGBEL EQ GS_311-KDAUF. "판매오더번호
      IF SY-SUBRC EQ 0.
        GS_311-KDPOS = LV_VGPOS.
      ENDIF.
  ENDCASE.

ENDFORM.                    " GET_KDAUF_CHARG
*&---------------------------------------------------------------------*
*&      Form  GET_TAGNR_FOR_CHARG
*&---------------------------------------------------------------------*
*       꼬리표 번호리스트
*----------------------------------------------------------------------*
FORM GET_TAGNR_FOR_CHARG .

  SELECT SINGLE TAGNR
           FROM ZPPT0001
           INTO GS_311-TAGNR
          WHERE CHARG EQ GS_311-CHARG
            AND MATNR EQ GS_101-MATNR
            AND WERKS EQ GS_101-WERKS_M.

ENDFORM.                    " GET_TAGNR_FOR_CHARG
*&---------------------------------------------------------------------*
*&      Form  ADD_TABLECONTROL_0310
*&---------------------------------------------------------------------*
*       불만제품 추가
*----------------------------------------------------------------------*
FORM ADD_TABLECONTROL_0310 .

* local variable
  DATA: LV_COUNT(3),
        LV_TEXT(70).

* 판매오더로 등록(멀티입력)
  IF GV_MULTI_INPUT EQ 'X'.
    LOOP AT GT_MTBLN INTO GS_MTBLN.
      PERFORM SET_TBCON_DATA.
*      PERFORM set_tbcon_header_multi.  "헤더
*      PERFORM set_tbcon_list_multi.    "배치
*      CLEAR: gs_mtbln.
    ENDLOOP.

    DESCRIBE TABLE GT_MTBLN LINES LV_COUNT.
    CONDENSE LV_COUNT NO-GAPS.
    CONCATENATE '총' LV_COUNT '건의 데이터가 등록되었습니다.'
           INTO LV_TEXT SEPARATED BY SPACE.
    PERFORM SHOW_MSG_BOX USING 'I' LV_TEXT.
* 멀티입력 아닌경우
  ELSE.
    PERFORM SET_TBCON_HEADER.  "헤더
    PERFORM SET_TBCON_LIST.    "배치
  ENDIF.

  PERFORM SET_DISPLAY_BATCH_DATA.

ENDFORM.                    " ADD_TABLECONTROL_0310
*&---------------------------------------------------------------------*
*&      Form  SET_TBCON_HEADER
*&---------------------------------------------------------------------*
*       불만제품 내역 추가 - 헤더
*----------------------------------------------------------------------*
FORM SET_TBCON_HEADER .

* local variable
  DATA: LS_TMP LIKE GT_100,
        LT_TMP LIKE TABLE OF LS_TMP.

  CLEAR GT_100.

  GT_100-RCEPNO    = GS_100-RCEPNO.     "접수번호
  GT_100-MATNR     = GS_101-MATNR.      "자재번호
  GT_100-MAKTX     = GS_101-MAKTX.      "자재내역
  GT_100-WERKS_M   = GS_101-WERKS_M.    "자재플랜트
  GT_100-SPGCD     = GS_311-SPGCD.      "제품군
  GT_100-MGEIN     = GS_311-MGEIN.      "단위
  GT_100-VRKME     = GS_311-MGEIN.      "불만확정수량단위
  GT_100-KDAUF     = GS_311-KDAUF.      "판매 오더 번호
  GT_100-FERTAUFNR = GS_311-FERTAUFNR.  "고객구매오더번호
  GT_100-BSTDK     = GS_311-BSTDK.      "고객구매오더일
  GT_100-ERNAM     = SY-UNAME.          "생성자
  GT_100-ERDAT     = SY-DATUM.          "생성일
  GT_100-ERZET     = SY-UZEIT.          "시간
  GT_100-KZLOESCH  = ''.                "데이타레코드삭제

* 동일한 내역이 이미 존재한다면 append하지 않는다.
  LT_TMP = GT_100[].
  READ TABLE LT_TMP INTO LS_TMP WITH KEY WERKS_M = GT_100-WERKS_M
                                         MATNR   = GT_100-MATNR
                                         KDAUF   = GT_100-KDAUF.
  IF SY-SUBRC NE 0.
*   현재 등록된 테이블컨트롤의 자재번호 max값을 구한다.
    SORT LT_TMP BY ZMATSEQ DESCENDING.
    READ TABLE LT_TMP INTO LS_TMP INDEX 1.

*   자재seq = table max + 1
    GT_100-ZMATSEQ = LS_TMP-ZMATSEQ + 1.  "자재Seq

*   신규추가된 라인의 라이오버튼을 활성화
    PERFORM OFF_RADIO_BUTTON_0310.
    GT_100-MARK = 'X'.

    APPEND GT_100.

  ELSE.
    GT_100-ZMATSEQ = LS_TMP-ZMATSEQ.      "자재Seq

  ENDIF.

ENDFORM.                    " SET_TBCON_HEADER
*&---------------------------------------------------------------------*
*&      Form  SET_TBCON_LIST
*&---------------------------------------------------------------------*
*       불만제품 내역 추가 - 리스트
*----------------------------------------------------------------------*
FORM SET_TBCON_LIST .

* local variable
  DATA: LS_TMP LIKE GT_110,
        LT_TMP LIKE TABLE OF LS_TMP.

  CLEAR: GT_110, GT_110[], GT_110A.

* 배치의 헤더를 설정한다.
  GS_101-ZMATSEQ  = GT_100-ZMATSEQ.    "자재Seq
  GS_101-MATNR    = GT_100-MATNR.      "자재번호
  GS_101-MAKTX    = GT_100-MAKTX.      "자재내역
  GS_101-KDAUF    = GS_311-KDAUF.      "판매오더
  GS_101-KZLOESCH = ''.                "삭제플래그

* gt_110a 에서 일치하는 데이터를 먼저 가져온다.
  LOOP AT GT_110A WHERE RCEPNO  EQ GT_100-RCEPNO    "접수번호
                    AND ZMATSEQ EQ GT_100-ZMATSEQ.  "자재Seq
    GT_110 = GT_110A.
    APPEND GT_110.
    CLEAR: GT_110, GT_110A.
  ENDLOOP.

* 신규로 입력된 데이터를 설정한다.
  GT_110-RCEPNO    = GT_100-RCEPNO.     "접수번호
  GT_110-ZMATSEQ   = GT_100-ZMATSEQ.    "자재Seq
  GT_110-KDPOS     = GS_311-KDPOS.      "판매오더 품목
  GT_110-VBELN     = GS_311-VBELN.      "납품오더
  GT_110-POSNR     = GS_311-POSNR.      "납품오더 품목
  GT_110-TAGNR     = GS_311-TAGNR.      "꼬리표번호
  GT_110-DRUM      = GS_311-DRUM.       "드럼번호
  GT_110-SERIAL    = GS_311-SERIAL.     "일련번호
  GT_110-MCNO      = GS_311-MCNO.       "기계번호
  GT_110-CHARG     = GS_311-CHARG.      "배치 번호
  GT_110-GELIM     = GS_311-GELIM.      "납품 수량
  GT_110-MGEIN1    = GS_311-MGEIN.      "단위
  GT_110-MGEIN     = GS_311-MGEIN.      "단위
  GT_110-VRKME     = GS_311-MGEIN.      "불만확정수량단위
  GT_110-ERNAM     = SY-UNAME.          "생성자
  GT_110-ERDAT     = SY-DATUM.          "생성일
  GT_110-ERZET     = SY-UZEIT.          "시간
  GT_110-KZLOESCH  = ''.                "데이타레코드삭제

* 현재 등록된 테이블컨트롤의 배치번호 max값을 구한다.
  LT_TMP = GT_110[].
  SORT LT_TMP BY ZCHASEQ DESCENDING.
  READ TABLE LT_TMP INTO LS_TMP INDEX 1.

* 배치seq = table max + 1
  GT_110-ZCHASEQ = LS_TMP-ZCHASEQ + 1.  "배치Seq

  APPEND GT_110.

* 같은 내용을 gt_110a 에도 append한다.
  APPEND GT_110 TO GT_110A.

* 불량내역엔 데이터가 들어가지 않으므로 clear
  CLEAR: GT_120, GT_120[].

ENDFORM.                    " SET_TBCON_LIST
*&---------------------------------------------------------------------*
*&      Form  OFF_RADIO_BUTTON_0310
*&---------------------------------------------------------------------*
*       0310 화면 테이블컨트롤의 라디오버튼을 모두 clear한다.
*----------------------------------------------------------------------*
FORM OFF_RADIO_BUTTON_0310 .

* local variable
  DATA: LV_TMP LIKE GT_100.

  CLEAR: LV_TMP.
  MODIFY GT_100 FROM LV_TMP TRANSPORTING MARK
               WHERE MARK NE ''.

ENDFORM.                    " OFF_RADIO_BUTTON_0310
*&---------------------------------------------------------------------*
*&      Form  GET_TC_100_ADD1
*&---------------------------------------------------------------------*
*       불만제품 배치 추가
*----------------------------------------------------------------------*
FORM GET_TC_100_ADD1 .

  IF GS_101-KDAUF IS INITIAL.
    PERFORM SHOW_MSG_BOX USING 'E' TEXT-E01.
    REJECT.
  ELSEIF GS_101-KZLOESCH EQ 'X'.
    PERFORM SHOW_MSG_BOX USING 'E' TEXT-E09.
    REJECT.
  ELSE.
    CALL SCREEN '0315' STARTING AT 10 2
                       ENDING AT 108 8.
  ENDIF.

ENDFORM.                    " GET_TC_100_ADD1
*&---------------------------------------------------------------------*
*&      Form  SHOW_MSG_BOX
*&---------------------------------------------------------------------*
*       메시지박스
*----------------------------------------------------------------------*
FORM SHOW_MSG_BOX  USING    P_TYPE
                            P_TEXT.

  CALL FUNCTION 'WS_MSG'
    EXPORTING
      MSG_TYPE = P_TYPE
      TEXT     = P_TEXT
      TITL     = SY-TITLE.

ENDFORM.                    " SHOW_MSG_BOX
*&---------------------------------------------------------------------*
*&      Form  GET_TC_100_DELETE
*&---------------------------------------------------------------------*
*       불만제품 삭제
*----------------------------------------------------------------------*
FORM GET_TC_100_DELETE .

* local variable
  DATA: LV_INDEX TYPE SY-TABIX.

  $$POPUP_TO_CONFIRM_STEP '선택된 불만제품 정보를 삭제하시겠습니까?.'
                          ' '  '삭제'.
  CHECK GV_ANSWER = 'J'.

* 라디오 버튼이 체크된 항목을 읽어온다.
  CLEAR: GT_100.
  READ TABLE GT_100 WITH KEY MARK = 'X'.
  LV_INDEX = SY-TABIX.

* check
  SELECT SINGLE * FROM ZQMT0014S
                 WHERE STATUS <> '3'
    AND RCEPNO = GV_RCEPNO
    AND MATNR = GT_100-MATNR.
  IF SY-SUBRC = 0.
    MESSAGE E002 WITH TEXT-E02 TEXT-E03.
  ENDIF.

  SELECT COUNT(*)
    FROM ZQMT0015Q AS A INNER JOIN ZQMT0011M AS B
    ON A~RCEPNO  = B~RCEPNO
    AND A~ZMATSEQ = B~ZMATSEQ
    WHERE A~RCEPNO = GV_RCEPNO
 AND B~MATNR = GT_100-MATNR
    AND STATUS <> '3'.

  IF SY-SUBRC = 0.
    MESSAGE E002 WITH TEXT-E02 TEXT-E03.
  ENDIF.

* 고객불만 테이블 확인
  SELECT SINGLE * FROM ZQMT0011M
                 WHERE RCEPNO  EQ GT_100-RCEPNO
                   AND ZMATSEQ EQ GT_100-ZMATSEQ.

* 해당 내용이 테이블에 존재하면 삭제플래그에 X만 update
  IF SY-SUBRC EQ 0.
*   고객불만 삭제처리
    GT_100-KZLOESCH = 'X'.
    GT_100-AENAM = SY-UNAME.
    GT_100-AEDAT = SY-DATUM.
    GT_100-AEZET = SY-UZEIT.
    MODIFY GT_100 INDEX LV_INDEX
                  TRANSPORTING KZLOESCH AENAM AEDAT AEZET.
*   고객불만(배치) 삭제처리
    GS_101-KZLOESCH = 'X'.
    GT_110-KZLOESCH = 'X'.
    GT_110-AENAM = SY-UNAME.
    GT_110-AEDAT = SY-DATUM.
    GT_110-AEZET = SY-UZEIT.
    MODIFY GT_110  TRANSPORTING KZLOESCH AENAM AEDAT AEZET
                   WHERE RCEPNO  EQ GT_100-RCEPNO    "접수번호
                     AND ZMATSEQ EQ GT_100-ZMATSEQ.  "자재Seq
    MODIFY GT_110A FROM GT_110
                   TRANSPORTING KZLOESCH AENAM AEDAT AEZET
                   WHERE RCEPNO  EQ GT_100-RCEPNO    "접수번호
                     AND ZMATSEQ EQ GT_100-ZMATSEQ.  "자재Seq
* 해당 내용이 테이블에 없을경우 테이블컨트롤에서 데이터 삭제
  ELSE.
    CLEAR: GS_101.
    DELETE GT_100  INDEX LV_INDEX.
    DELETE GT_110  WHERE RCEPNO EQ GT_100-RCEPNO     "접수번호
                     AND ZMATSEQ EQ GT_100-ZMATSEQ.  "자재Seq
    DELETE GT_110A WHERE RCEPNO EQ GT_100-RCEPNO     "접수번호
                     AND ZMATSEQ EQ GT_100-ZMATSEQ.  "자재Seq
  ENDIF.

ENDFORM.                    " GET_TC_100_DELETE
*&---------------------------------------------------------------------*
*&      Form  GET_TC_100_DELETE1
*&---------------------------------------------------------------------*
*       불만제품(배치) 삭제
*----------------------------------------------------------------------*
FORM GET_TC_100_DELETE1 .

  $$POPUP_TO_CONFIRM_STEP
      '선택된 불만제품 정보를 삭제하시겠습니까?.'
      ' '  '삭제'.
  CHECK GV_ANSWER = 'J'.

* 라디오 버튼이 체크된 항목을 읽어온다.
  CLEAR: GT_110.
  LOOP AT GT_110 WHERE MARK EQ 'X'.

*   고객불만(배치) 테이블 확인
    SELECT SINGLE * FROM ZQMT0011B
                   WHERE RCEPNO  EQ GT_110-RCEPNO
                     AND ZMATSEQ EQ GT_110-ZMATSEQ
                     AND ZCHASEQ EQ GT_110-ZCHASEQ.
*   해당 내용이 테이블에 존재하면 삭제플래그에 X만 update
    IF SY-SUBRC EQ 0.
*     고객불만(배치) 삭제처리
      GT_110-KZLOESCH = 'X'.
      GT_110-AENAM = SY-UNAME.
      GT_110-AEDAT = SY-DATUM.
      GT_110-AEZET = SY-UZEIT.
      MODIFY GT_110  TRANSPORTING KZLOESCH AENAM AEDAT AEZET
                     WHERE RCEPNO  EQ GT_110-RCEPNO    "접수번호
                       AND ZMATSEQ EQ GT_110-ZMATSEQ   "자재Seq
                       AND ZCHASEQ EQ GT_110-ZCHASEQ.  "배치Seq
      MODIFY GT_110A FROM GT_110
                     TRANSPORTING KZLOESCH AENAM AEDAT AEZET
                     WHERE RCEPNO  EQ GT_110-RCEPNO    "접수번호
                       AND ZMATSEQ EQ GT_110-ZMATSEQ   "자재Seq
                       AND ZCHASEQ EQ GT_110-ZCHASEQ.  "배치Seq
* 해당 내용이 테이블에 없을경우 테이블컨트롤에서 데이터 삭제
    ELSE.
      DELETE GT_110  WHERE RCEPNO  EQ GT_110-RCEPNO     "접수번호
                       AND ZMATSEQ EQ GT_110-ZMATSEQ   "자재Seq
                       AND ZCHASEQ EQ GT_110-ZCHASEQ.  "배치Seq
      DELETE GT_110A WHERE RCEPNO  EQ GT_110-RCEPNO     "접수번호
                       AND ZMATSEQ EQ GT_110-ZMATSEQ   "자재Seq
                       AND ZCHASEQ EQ GT_110-ZCHASEQ.  "배치Seq
    ENDIF.

    CLEAR: GT_110.
  ENDLOOP.

* 불만수량 재계산
  PERFORM SET_CHARGE_COUNT.

ENDFORM.                    " GET_TC_100_DELETE1
*&---------------------------------------------------------------------*
*&      Form  SET_CHARGE_COUNT
*&---------------------------------------------------------------------*
*       불만수량 계산
*----------------------------------------------------------------------*
FORM SET_CHARGE_COUNT .

  CLEAR: GT_100, GT_110.

* gt_110의 sum값을 gt_100에 넣어준다. (삭제건 제외하고 계산)
  LOOP AT GT_110 WHERE KZLOESCH NE 'X'.

    GT_100-RKMNG  = GT_100-RKMNG  + GT_110-RKMNG.   "불만제기수량
    GT_100-KWMENG = GT_100-KWMENG + GT_110-KWMENG.  "불만확정수량
    CLEAR: GT_110.
  ENDLOOP.

* gt_100의 수량을 update한다.
  READ TABLE GT_110 INDEX 1.
  MODIFY GT_100 TRANSPORTING RKMNG KWMENG
                WHERE RCEPNO  EQ GT_110-RCEPNO
                  AND ZMATSEQ EQ GT_110-ZMATSEQ.

ENDFORM.                    " SET_CHARGE_COUNT
*&---------------------------------------------------------------------*
*&      Form  TC_100_DELETE_CANC1
*&---------------------------------------------------------------------*
*       불만제품(배치) 삭제취소
*----------------------------------------------------------------------*
FORM TC_100_DELETE_CANC1 .

  $$POPUP_TO_CONFIRM_STEP '삭제된 불만제품 정보를 복원하시겠습니까?'
                          ' '  '삭제취소'.
  CHECK GV_ANSWER = 'J'.

  CLEAR: GT_110.
  LOOP AT GT_110 WHERE MARK EQ 'X'.

    GT_110-KZLOESCH = ''.
    GT_110-AENAM = SY-UNAME.
    GT_110-AEDAT = SY-DATUM.
    GT_110-AEZET = SY-UZEIT.
    MODIFY GT_110  TRANSPORTING KZLOESCH AENAM AEDAT AEZET
                   WHERE RCEPNO  EQ GT_110-RCEPNO    "접수번호
                     AND ZMATSEQ EQ GT_110-ZMATSEQ   "자재Seq
                     AND ZCHASEQ EQ GT_110-ZCHASEQ.  "배치Seq
    MODIFY GT_110A FROM GT_110
                   TRANSPORTING KZLOESCH AENAM AEDAT AEZET
                   WHERE RCEPNO  EQ GT_110-RCEPNO    "접수번호
                     AND ZMATSEQ EQ GT_110-ZMATSEQ   "자재Seq
                     AND ZCHASEQ EQ GT_110-ZCHASEQ.  "배치Seq
    CLEAR: GT_110.
  ENDLOOP.

* 불만수량 재계산
  PERFORM SET_CHARGE_COUNT.

ENDFORM.                    " TC_100_DELETE_CANC1
*&---------------------------------------------------------------------*
*&      Form  INSERT_CUSTOM_CLAIM_0320
*&---------------------------------------------------------------------*
*       자재/불량정보 데이터 저장 (screen 0100 SAVE시 호출)
*----------------------------------------------------------------------*
FORM INSERT_CUSTOM_CLAIM_0320 .

* local variable
  DATA: LS_ZQMT0011B TYPE ZQMT0011B,   "고객불만(불만배치)
        LT_ZQMT0011B LIKE TABLE OF LS_ZQMT0011B,
        LS_ZQMT0011M TYPE ZQMT0011M,   "고객불만(자재)
        LT_ZQMT0011M LIKE TABLE OF LS_ZQMT0011M,
        LS_ZQMT0012N TYPE ZQMT0012N,   "고객불만(불만유형)
        LT_ZQMT0012N LIKE TABLE OF LS_ZQMT0012N.

* 저장할 데이터 없으면 skip
  CHECK NOT GT_100[] IS INITIAL.

* 고객불만(자재) 처리
  CLEAR: GT_100, LS_ZQMT0011M, LT_ZQMT0011M.

  LOOP AT GT_100.
    PERFORM TRANS_DATA_UPDAT USING 'ZQMT0011M'.

    MOVE-CORRESPONDING GT_100 TO LS_ZQMT0011M.
*   불만집계 / 불만주의는 저장하지 않음.
    CLEAR: LS_ZQMT0011M-MATCT,    "불만집계
           LS_ZQMT0011M-KUNCT.    "불만주의

    APPEND LS_ZQMT0011M TO LT_ZQMT0011M.
    CLEAR: GT_100, LS_ZQMT0011M.
  ENDLOOP.

* 고객불만(불만배치) 처리
  CLEAR: GT_110A, LS_ZQMT0011B, LT_ZQMT0011B.

  LOOP AT GT_110A.
    PERFORM TRANS_DATA_UPDAT USING 'ZQMT0011B'.

    MOVE-CORRESPONDING GT_110A TO LS_ZQMT0011B.

    APPEND LS_ZQMT0011B TO LT_ZQMT0011B.
    CLEAR: GT_110A, LS_ZQMT0011B.
  ENDLOOP.

* 고객불만(불만유형) 처리
  CLEAR: GT_120A, LS_ZQMT0012N, LT_ZQMT0012N.

  LOOP AT GT_120A.
    PERFORM TRANS_DATA_UPDAT USING 'ZQMT0012N'.

    MOVE-CORRESPONDING GT_120A TO LS_ZQMT0012N.

    LS_ZQMT0012N-BUKRS = GV_BUKRS.

    IF  LS_ZQMT0012N-ZMATSEQ IS INITIAL.
      LS_ZQMT0012N-ZMATSEQ  = 1.
    ENDIF.

    APPEND LS_ZQMT0012N TO LT_ZQMT0012N.
    CLEAR: GT_120A, LS_ZQMT0012N.
  ENDLOOP.

  MODIFY ZQMT0011M FROM TABLE LT_ZQMT0011M.
  MODIFY ZQMT0011B FROM TABLE LT_ZQMT0011B.
  MODIFY ZQMT0012N FROM TABLE LT_ZQMT0012N.

  IF SY-SUBRC = 0.
    CLEAR: GT_100_OLD[],  GT_110_OLD[],  GT_120_OLD[].
    GT_100_OLD[] = GT_100[].
    GT_110_OLD[] = GT_110A[].
    GT_120_OLD[] = GT_120A[].
    GV_SAVE_Y = 'X'.
  ELSE.
    CLEAR GV_SAVE_Y.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.                    " INSERT_CUSTOM_CLAIM_0320
*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT_DATA_0311
*&---------------------------------------------------------------------*
*       0311 screen 입력값 점검
*----------------------------------------------------------------------*
FORM CHECK_INPUT_DATA_0311 .

* 필수입력값 점검 (자재코드)
  IF GS_101-MATNR IS INITIAL.
    PERFORM SHOW_MSG_BOX USING 'E' TEXT-E04.
    REJECT.
  ENDIF.

* 필수입력값 점검 (플랜트)
  IF GS_101-WERKS_M IS INITIAL.
    PERFORM SHOW_MSG_BOX USING 'E' TEXT-E05.
    REJECT.
  ENDIF.

** 필수입력값 점검 (판매오더)
*  IF GS_311-KDAUF IS INITIAL.
*    PERFORM SHOW_MSG_BOX USING 'E' TEXT-E06.
*    REJECT.
*  ENDIF.
*
** 필수입력값 점검 (판매오더 품목)
*  IF GS_311-KDPOS IS INITIAL.
*    PERFORM SHOW_MSG_BOX USING 'E' TEXT-E07.
*    REJECT.
*  ENDIF.
*
** 필수입력값 점검 (납품오더)
*  IF GS_311-VBELN IS INITIAL.
*    PERFORM SHOW_MSG_BOX USING 'E' TEXT-E20.
*    REJECT.
*  ENDIF.
*
** 필수입력값 점검 (납품오더 품목)
*  IF GS_311-POSNR IS INITIAL.
*    PERFORM SHOW_MSG_BOX USING 'E' TEXT-E21.
*    REJECT.
*  ENDIF.

* 데이터 정합성 점검
* 자재번호와 플랜트는 초기화면 기본값으로 입력되는 경우가 있어
* ON REQUEST로 걸러내지 못할 수 있음.
  PERFORM CHECK_MATNR_WERKS USING GS_101-MATNR
                                  GS_101-WERKS_M
                                  'POPU'.

ENDFORM.                    " CHECK_INPUT_DATA_0311
*&---------------------------------------------------------------------*
*&      Form  CHECK_MATNR_WERKS
*&---------------------------------------------------------------------*
*       자재번호와 플랜트의 정합성 확인
*----------------------------------------------------------------------*
FORM CHECK_MATNR_WERKS  USING    P_MATNR
                                 P_WERKS
                                 P_TYPE.

  SELECT SINGLE MATNR
    INTO P_MATNR
    FROM MARC
   WHERE MATNR = P_MATNR
     AND WERKS = P_WERKS.

  IF SY-SUBRC NE 0.
    CASE P_TYPE.
      WHEN 'ERRM'.   "error message
        MESSAGE E001 WITH TEXT-E08.
      WHEN 'POPU'.   "popup message
        PERFORM SHOW_MSG_BOX USING 'E' TEXT-E08.
        REJECT.
    ENDCASE.
  ENDIF.

ENDFORM.                    " CHECK_MATNR_WERKS
*&---------------------------------------------------------------------*
*&      Form  TC_100_DELETE_CANC
*&---------------------------------------------------------------------*
*       삭제취소
*----------------------------------------------------------------------*
FORM TC_100_DELETE_CANC .

* local variable
  DATA: LV_INDEX TYPE SY-TABIX.

  $$POPUP_TO_CONFIRM_STEP '삭제된 불만제품 정보를 복원하시겠습니까?'
                          ' '  '삭제취소'.
  CHECK GV_ANSWER = 'J'.

* 라디오 버튼이 체크된 항목을 읽어온다.
  CLEAR: GT_100.
  READ TABLE GT_100 WITH KEY MARK = 'X'.
  LV_INDEX = SY-TABIX.

* 고객불만 삭제복원
  GT_100-KZLOESCH = ''.
  GT_100-AENAM = SY-UNAME.
  GT_100-AEDAT = SY-DATUM.
  GT_100-AEZET = SY-UZEIT.
  MODIFY GT_100 INDEX LV_INDEX
                TRANSPORTING KZLOESCH AENAM AEDAT AEZET.
* 고객불만(배치) 삭제복원
  GS_101-KZLOESCH = ''.
  GT_110-KZLOESCH = ''.
  GT_110-AENAM = SY-UNAME.
  GT_110-AEDAT = SY-DATUM.
  GT_110-AEZET = SY-UZEIT.
  MODIFY GT_110  TRANSPORTING KZLOESCH AENAM AEDAT AEZET
                 WHERE RCEPNO  EQ GT_100-RCEPNO    "접수번호
                   AND ZMATSEQ EQ GT_100-ZMATSEQ.  "자재Seq
  MODIFY GT_110A FROM GT_110
                 TRANSPORTING KZLOESCH AENAM AEDAT AEZET
                 WHERE RCEPNO  EQ GT_100-RCEPNO    "접수번호
                   AND ZMATSEQ EQ GT_100-ZMATSEQ.  "자재Seq

ENDFORM.                    " TC_100_DELETE_CANC
*&---------------------------------------------------------------------*
*&      Form  GET_TC_100_UPD
*&---------------------------------------------------------------------*
*       판매오더로 등록
*----------------------------------------------------------------------*
FORM GET_TC_100_UPD .

  CALL SCREEN '0320' STARTING AT 10 2
                     ENDING AT 56 8.

ENDFORM.                    " GET_TC_100_UPD
*&---------------------------------------------------------------------*
*&      Form  CHECK_MATNR_KDAUF
*&---------------------------------------------------------------------*
*       자재번호와 판매오더의 정합성 확인
*----------------------------------------------------------------------*
FORM CHECK_MATNR_KDAUF  USING    P_MATNR
                                 P_KDAUF
                                 P_KDPOS.
* local variable
  DATA: LV_VBELN TYPE VBAP-VBELN.

  SELECT SINGLE VBELN FROM VBAP
                      INTO LV_VBELN
                     WHERE VBELN EQ P_KDAUF    "index pk
                       AND POSNR EQ P_KDPOS    "index pk
                       AND MATNR EQ P_MATNR.
  IF SY-SUBRC NE 0.
    MESSAGE E001 WITH TEXT-E10.
  ENDIF.

ENDFORM.                    " CHECK_MATNR_KDAUF
*&---------------------------------------------------------------------*
*&      Form  IS_FIRST_CALL_0310
*&---------------------------------------------------------------------*
*       310 화면 최초 호출 시
*----------------------------------------------------------------------*
FORM IS_FIRST_CALL_0310 .

  GV_ISFIRST = 'X'.

* gt_110은 이전 화면에서 old테이블과 비교하기 위해 이미 읽어왔음.
  CLEAR: GT_110, GT_110[], GT_120, GT_120[].
  READ TABLE GT_100 INDEX 1.

  IF SY-SUBRC EQ 0.
*   라디오버튼 선택
    GT_100-MARK = 'X'.
    MODIFY GT_100 INDEX 1 TRANSPORTING MARK.

*   선택된 항목을 기준으로 배치 정보를 보여준다.
    CLEAR: GT_110, GT_110A.
    LOOP AT GT_110A WHERE RCEPNO  EQ GT_100-RCEPNO
                      AND ZMATSEQ EQ GT_100-ZMATSEQ.
      GT_110 = GT_110A.
      APPEND GT_110.
      CLEAR: GT_110, GT_110A.
    ENDLOOP.

    CLEAR: GT_120, GT_120A.
    LOOP AT GT_120A WHERE RCEPNO  EQ GT_100-RCEPNO
                      AND ZMATSEQ EQ GT_100-ZMATSEQ.
      GT_120 = GT_120A.
      APPEND GT_120.
      CLEAR: GT_120, GT_120A.
    ENDLOOP.

*   선택된 항목을 기준으로 배치 헤더 정보를 보여준다.
    GS_101-ZMATSEQ  = GT_100-ZMATSEQ.          "번호
    GS_101-MATNR    = GT_100-MATNR.            "자재번호
    GS_101-MAKTX    = GT_100-MAKTX.            "자재내역
    GS_101-KDAUF    = GT_100-KDAUF.            "판매오더
    GS_101-WERKS_M  = GT_100-WERKS_M.          "자재플랜트
    PERFORM GET_WERKST USING    GS_101-WERKS_M
                       CHANGING GS_101-WERKST. "플랜트명
    GS_101-KZLOESCH = GT_100-KZLOESCH.         "삭제
  ENDIF.

ENDFORM.                    " IS_FIRST_CALL_0310
*&---------------------------------------------------------------------*
*&      Form  GET_LIST
*&---------------------------------------------------------------------*
*       판매오더로 불량제품 등록
*----------------------------------------------------------------------*
FORM GET_LIST .

* local variable
  DATA: LV_KUNNR TYPE KUNNR,
        LV_VBELN TYPE VBELN,
        LV_VGBEL TYPE VGBEL,
        LV_COUNT TYPE I.

  CLEAR: GS_MTBLN, GT_MTBLN.

* 필수입력데이터 점검
  IF GS_102-KDAUF IS INITIAL AND
     GS_102-VBELN IS INITIAL.
    PERFORM SHOW_MSG_BOX USING 'E' TEXT-E14.
    REJECT.
  ENDIF.

* 1. 판매오더 / 납품문서 번호를 가져온다.
*    판매오더, 판매오더품목, 납품오더, 납품오더품목, 자재번호, 플랜트,
*    배치번호, 납품수량, 단위
  PERFORM GET_LIST_STEP_01.

* 2. PO번호 / 기계번호 / 제품군 / 단위를 가져온다.
  PERFORM GET_LIST_STEP_02.

* 3. 꼬리표번호 / 드럼번호를 가져온다.
  PERFORM GET_LIST_STEP_03.

* 4. ALV 선택화면 호출
*  DESCRIBE TABLE gt_mtbln LINES lv_count.
*  CHECK NOT lv_count IS INITIAL.
*  CALL SCREEN '0323' STARTING AT 10 2
*                     ENDING AT 100 10.

* 5. 4번에서 선택된 데이터를 테이블컨트롤로 보낸다.
*  IF ok_save EQ 'OKAY'.
  PERFORM ADD_TABLECONTROL_0310.
  PERFORM EXE_CACL.
*  ENDIF.

ENDFORM.                    " GET_LIST
*&---------------------------------------------------------------------*
*&      Form  GET_TC_100_ADD2
*&---------------------------------------------------------------------*
*       불만제품 불량 추가
*----------------------------------------------------------------------*
FORM GET_TC_100_ADD2 .

* 주석처리 2011.11.18 김성준 - by 김병준
*    PERFORM SHOW_MSG_BOX USING 'E' TEXT-E01.
*    REJECT.
  IF GS_101-KZLOESCH EQ 'X'.
    PERFORM SHOW_MSG_BOX USING 'E' TEXT-E09.
    REJECT.
  ELSE.
    CALL SCREEN '0316' STARTING AT 10 2
                       ENDING AT 108 8.
  ENDIF.






*  IF GS_101-KDAUF IS INITIAL.
** 주석처리 2011.11.18 김성준 - by 김병준
**    PERFORM SHOW_MSG_BOX USING 'E' TEXT-E01.
**    REJECT.
*  ELSEIF GS_101-KZLOESCH EQ 'X'.
*    PERFORM SHOW_MSG_BOX USING 'E' TEXT-E09.
*    REJECT.
*  ELSE.
*    CALL SCREEN '0316' STARTING AT 10 2
*                       ENDING AT 108 8.
*  ENDIF.

ENDFORM.                    " GET_TC_100_ADD2
*&---------------------------------------------------------------------*
*&      Form  GET_CODE_SEARCH
*&---------------------------------------------------------------------*
*       불량 / 위치코드 검색
*----------------------------------------------------------------------*
FORM GET_CODE_SEARCH  USING    VALUE(P_TYPE)
                      CHANGING P_GROUP     "그룹
                               P_CODE      "코드
                               P_TEXT      "내역
                               P_CATALOG   "카탈로그
                               P_VERSION.  "버전
* local variable
  DATA: LV_TYPE TYPE QPGR-KATALOGART,
        LS_GRPTAB TYPE QPK1CODEGRP,
        LT_GRPTAB LIKE TABLE OF LS_GRPTAB,
        LS_PIKTAB TYPE QPK1CD,
        LT_PIKTAB LIKE TABLE OF LS_PIKTAB.
  CLEAR: P_GROUP, P_CODE, P_TEXT.

* Catalog type
  CASE P_TYPE.
    WHEN 'FLS'. LV_TYPE = '9'.   "불량코드검색
    WHEN 'OTS'. LV_TYPE = 'E'.   "위치코드검색
  ENDCASE.

* filter
  LS_GRPTAB = '*'.
  APPEND LS_GRPTAB TO LT_GRPTAB.

* catalog function.
  CALL FUNCTION 'QPK1_GP_CODE_SELECTION'
    EXPORTING
      I_KATALOGART           = LV_TYPE
      I_CODE                 = '*'
      I_SPRACHE              = SY-LANGU
      I_PICKUP_MODE          = 'X'
    TABLES
      T_QPK1CDTAB            = LT_PIKTAB
      T_CODEGRPTAB           = LT_GRPTAB
    EXCEPTIONS
      NO_MATCH_IN_RANGE      = 1
      NO_USER_SELECTION      = 2
      NO_AUTHORIZATION       = 3
      NO_SELECTION_SPECIFIED = 4
      OBJECT_LOCKED          = 5
      LOCK_ERROR             = 6
      OBJECT_MISSING         = 7
      OTHERS                 = 8.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* 결과값 리턴
  READ TABLE LT_PIKTAB INTO LS_PIKTAB INDEX 1.
  P_GROUP   = LS_PIKTAB-CODEGRUPPE.  "그룹
  P_CODE    = LS_PIKTAB-CODE.        "코드
  P_CATALOG = LV_TYPE.               "카탈로그
  P_VERSION = LS_PIKTAB-VERSION.     "버전
  CONCATENATE LS_PIKTAB-KURZTEXTGR '-' LS_PIKTAB-KURZTEXTCD
         INTO P_TEXT SEPARATED BY SPACE.

ENDFORM.                    " GET_CODE_SEARCH
*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT_DATA_0316
*&---------------------------------------------------------------------*
*       0316 screen 입력값 점검
*----------------------------------------------------------------------*
FORM CHECK_INPUT_DATA_0316 .

* 필수입력값 점검 (불량코드)
  IF GS_316-FTGRP IS INITIAL OR
     GS_316-FLTTP IS INITIAL OR
     GS_316-FTTXT IS INITIAL.
    PERFORM SHOW_MSG_BOX USING 'E' TEXT-E15.
    REJECT.
  ENDIF.

* 필수입력값 점검 (불량정보내역)
  IF GS_316-TEXT IS INITIAL.
    PERFORM SHOW_MSG_BOX USING 'E' TEXT-E17.
    REJECT.
  ENDIF.

ENDFORM.                    " CHECK_INPUT_DATA_0316
*&---------------------------------------------------------------------*
*&      Form  ADD_TABLECONTROL_0316
*&---------------------------------------------------------------------*
*       불만제품 추가
*----------------------------------------------------------------------*
FORM ADD_TABLECONTROL_0316 .

* local variable
  DATA: LS_TMP LIKE GT_120,
        LT_TMP LIKE TABLE OF LS_TMP.

  CLEAR: GT_120, GT_120[], GT_120A.

* gt_120a 에서 일치하는 데이터를 먼저 가져온다.
  LOOP AT GT_120A WHERE RCEPNO  EQ GT_100-RCEPNO    "접수번호
                    AND ZMATSEQ EQ GS_101-ZMATSEQ.  "자재Seq
    GT_120 = GT_120A.
    APPEND GT_120.
    CLEAR: GT_120, GT_120A.
  ENDLOOP.

* 신규로 입력된 데이터를 설정한다.
  GT_120-BUKRS   = GS_316-BUKRS.    "회사 코드
  GT_120-RCEPNO  = GS_100-RCEPNO.   "접수번호
  GT_120-ZMATSEQ = GS_101-ZMATSEQ.  "자재Seq
  GT_120-DFLG    = ''.              "삭제지시자
    if gs_316-ftgrp is not initial.
    gs_316-ftkat = '9'.
    gs_316-flver = '000001'.
  endif.
  GT_120-FTKAT   = GS_316-FTKAT.    "결함유형카타로그
  GT_120-FTGRP   = GS_316-FTGRP.    "결함유형코드그룹
  GT_120-FLTTP   = GS_316-FLTTP.    "결함유형코드
  GT_120-FLVER   = GS_316-FLVER.    "결함유형코드버전
  if gs_316-otrgrp is not initial.
    gs_316-otkat = 'E'.
    gs_316-otver = '000001'.
  endif.
  GT_120-OTKAT   = GS_316-OTKAT.    "위치카타로그
  GT_120-OTRGRP  = GS_316-OTRGRP.   "위치코드그룹
  GT_120-OTEIL   = GS_316-OTEIL.    "위치코드
  GT_120-OTVER   = GS_316-OTVER.    "위치코드버젼
  GT_120-TEXT    = GS_316-TEXT.     "불량정보 텍스트
  GT_120-ERNAM   = SY-UNAME.        "생성자
  GT_120-ERDAT   = SY-DATUM.        "생성일
  GT_120-ERZET   = SY-UZEIT.        "시간

* 현재 등록된 테이블컨트롤의 배치번호 max값을 구한다.
  LT_TMP = GT_120[].
  SORT LT_TMP BY ZBADSEQ DESCENDING.
  READ TABLE LT_TMP INTO LS_TMP INDEX 1.

* 불량seq = table max + 1
  GT_120-ZBADSEQ = LS_TMP-ZBADSEQ + 1.  "불량Seq

  APPEND GT_120.

* 같은 내용을 gt_120a 에도 append한다.
  APPEND GT_120 TO GT_120A.

ENDFORM.                    " ADD_TABLECONTROL_0316
*&---------------------------------------------------------------------*
*&      Form  GET_TC_100_DELETE2
*&---------------------------------------------------------------------*
*       불만제품(불량) 삭제
*----------------------------------------------------------------------*
FORM GET_TC_100_DELETE2 .

  $$POPUP_TO_CONFIRM_STEP
      '선택된 불량정보를 삭제하시겠습니까?.'
      ' '  '삭제'.
  CHECK GV_ANSWER = 'J'.

* 라디오 버튼이 체크된 항목을 읽어온다.
  CLEAR: GT_120.
  LOOP AT GT_120 WHERE MARK EQ 'X'.

*   고객불만(배치) 테이블 확인
    SELECT SINGLE * FROM ZQMT0012N
                   WHERE BUKRS   EQ GT_120-BUKRS
                     AND RCEPNO  EQ GT_120-RCEPNO
                     AND ZMATSEQ EQ GT_120-ZMATSEQ
                     AND ZBADSEQ EQ GT_120-ZBADSEQ.
*   해당 내용이 테이블에 존재하면 삭제플래그에 X만 update
    IF SY-SUBRC EQ 0.
*     고객불만(배치) 삭제처리
      GT_120-DFLG  = 'X'.
      GT_120-AENAM = SY-UNAME.
      GT_120-AEDAT = SY-DATUM.
      GT_120-AEZET = SY-UZEIT.
      MODIFY GT_120  TRANSPORTING DFLG AENAM AEDAT AEZET
                     WHERE BUKRS   EQ GT_120-BUKRS
                       AND RCEPNO  EQ GT_120-RCEPNO    "접수번호
                       AND ZMATSEQ EQ GT_120-ZMATSEQ   "자재Seq
                       AND ZBADSEQ EQ GT_120-ZBADSEQ.  "불량Seq
      MODIFY GT_120A FROM GT_120
                     TRANSPORTING DFLG AENAM AEDAT AEZET
                     WHERE BUKRS   EQ GT_120-BUKRS
                       AND RCEPNO  EQ GT_120-RCEPNO    "접수번호
                       AND ZMATSEQ EQ GT_120-ZMATSEQ   "자재Seq
                       AND ZBADSEQ EQ GT_120-ZBADSEQ.  "불량Seq
* 해당 내용이 테이블에 없을경우 테이블컨트롤에서 데이터 삭제
    ELSE.
      DELETE GT_120  WHERE BUKRS   EQ GT_120-BUKRS
                       AND RCEPNO  EQ GT_120-RCEPNO    "접수번호
                       AND ZMATSEQ EQ GT_120-ZMATSEQ   "자재Seq
                       AND ZBADSEQ EQ GT_120-ZBADSEQ.  "불량Seq
      DELETE GT_120A WHERE BUKRS   EQ GT_120-BUKRS
                       AND RCEPNO  EQ GT_120-RCEPNO    "접수번호
                       AND ZMATSEQ EQ GT_120-ZMATSEQ   "자재Seq
                       AND ZBADSEQ EQ GT_120-ZBADSEQ.  "불량Seq
    ENDIF.

    CLEAR: GT_120.
  ENDLOOP.

ENDFORM.                    " GET_TC_100_DELETE2
*&---------------------------------------------------------------------*
*&      Form  TC_100_DELETE_CANC2
*&---------------------------------------------------------------------*
*       삭제취소
*----------------------------------------------------------------------*
FORM TC_100_DELETE_CANC2 .

  $$POPUP_TO_CONFIRM_STEP '삭제된 불량정보를 복원하시겠습니까?'
                          ' '  '삭제취소'.
  CHECK GV_ANSWER = 'J'.

  CLEAR: GT_120.
  LOOP AT GT_120 WHERE MARK EQ 'X'.

    GT_120-DFLG  = ''.
    GT_120-AENAM = SY-UNAME.
    GT_120-AEDAT = SY-DATUM.
    GT_120-AEZET = SY-UZEIT.
    MODIFY GT_120  TRANSPORTING DFLG AENAM AEDAT AEZET
                   WHERE BUKRS   EQ GT_120-BUKRS
                     AND RCEPNO  EQ GT_120-RCEPNO    "접수번호
                     AND ZMATSEQ EQ GT_120-ZMATSEQ   "자재Seq
                     AND ZBADSEQ EQ GT_120-ZBADSEQ.  "불량Seq
    MODIFY GT_120A FROM GT_120
                   TRANSPORTING DFLG AENAM AEDAT AEZET
                   WHERE BUKRS   EQ GT_120-BUKRS
                     AND RCEPNO  EQ GT_120-RCEPNO    "접수번호
                     AND ZMATSEQ EQ GT_120-ZMATSEQ   "자재Seq
                     AND ZBADSEQ EQ GT_120-ZBADSEQ.  "불량Seq
    CLEAR: GT_120.
  ENDLOOP.

ENDFORM.                    " TC_100_DELETE_CANC2
*&---------------------------------------------------------------------*
*&      Form  GET_QPCT_DATA
*&---------------------------------------------------------------------*
*       결함유형 / 위치정보를 읽는다.
*----------------------------------------------------------------------*
FORM GET_QPCT_DATA  USING    P_KATALOGART
                             P_CODEGRUPPE
                             P_CODE
                             P_VERSION
                    CHANGING P_KURZTEXT.

  CLEAR: P_KURZTEXT.
  SELECT SINGLE KURZTEXT FROM QPCT
                         INTO P_KURZTEXT
                        WHERE KATALOGART EQ P_KATALOGART  "카탈로그
                          AND CODEGRUPPE EQ P_CODEGRUPPE  "코드 그룹
                          AND CODE       EQ P_CODE        "코드
                          AND SPRACHE    EQ SY-LANGU      "언어 키
                          AND VERSION    EQ P_VERSION.    "버전 번호

ENDFORM.                    " GET_QPCT_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_LIST_STEP_01
*&---------------------------------------------------------------------*
*       1. 판매오더 / 납품문서 번호를 가져온다.
*----------------------------------------------------------------------*
FORM GET_LIST_STEP_01 .

* local variable
  DATA: LV_COUNT TYPE I.

* 판매오더 번호 입력시
  IF NOT GS_102-KDAUF IS INITIAL.
    PERFORM GET_LIST_STEP_01_L.  "납품오더 리스트
*    PERFORM GET_LIST_STEP_01_B.  "판매오더 품목 / 자재번호 리스트
  ENDIF.

* 납품문서 번호 입력시
  IF NOT GS_102-VBELN IS INITIAL.
    PERFORM GET_LIST_STEP_01_V.  "판매오더 리스트
*    PERFORM GET_LIST_STEP_01_B.  "판매오더 품목 / 자재번호 리스트
  ENDIF.

* 판매오더, 판매오더품목, 납품오더, 납품오더 품목이 없는경우 삭제
  DELETE GT_MTBLN WHERE KDAUF EQ SPACE     "판매오더번호
                     OR KDPOS EQ SPACE     "판매오더 품목
                     OR VBELN EQ SPACE     "납품오더
                     OR POSNR EQ SPACE.    "납품오더 품목
  IF GT_MTBLN[] IS INITIAL.
    PERFORM SHOW_MSG_BOX USING 'E' TEXT-E22.
    REJECT.
  ENDIF.

ENDFORM.                    " GET_LIST_STEP_01
*&---------------------------------------------------------------------*
*&      Form  GET_LIST_STEP_01_B
*&---------------------------------------------------------------------*
*       판매오더 품목 리스트
*----------------------------------------------------------------------*
FORM GET_LIST_STEP_01_B .

  DATA: LV_CNT TYPE I.

* 영업문서: 품목데이타
  SELECT A~VBELN A~POSNR A~WERKS A~MATNR B~MAKTX
         FROM VBAP AS A
         JOIN MAKT AS B
           ON B~MATNR EQ A~MATNR
          AND B~SPRAS EQ SY-LANGU
         INTO TABLE GT_0321
        WHERE A~VBELN EQ GS_102-KDAUF.

* 1건 이상이면 팝업창을 열어서 선택하도록 한다.
  DESCRIBE TABLE GT_0321 LINES LV_CNT.
  IF LV_CNT > 1.
    CALL SCREEN '0321' STARTING AT 10  8
                       ENDING AT 100  20.
  ELSE.
    READ TABLE GT_0321 INDEX 1.
    GS_311-KDPOS   = GT_0321-POSNR.   "판매 문서 품목
    GS_101-MATNR   = GT_0321-MATNR.   "자재 번호
    GS_101-WERKS_M = GT_0321-WERKS_M. "플랜트
    GS_101-MAKTX   = GT_0321-MAKTX.   "자재 내역
  ENDIF.

* 판매오더로 등록(다중선택)
  IF GV_MULTI_INPUT EQ 'X'.
    GS_MTBLN-KDPOS   = GT_0321-POSNR.   "판매 문서 품목
    GS_MTBLN-MATNR   = GT_0321-MATNR.   "자재 번호
    GS_MTBLN-WERKS_M = GT_0321-WERKS_M. "자재플랜트
    GS_MTBLN-MAKTX   = GT_0321-MAKTX.   "자재 내역
    MODIFY GT_MTBLN FROM GS_MTBLN
                    TRANSPORTING KDPOS MATNR WERKS_M MAKTX
                    WHERE KDAUF NE SPACE.
  ENDIF.

ENDFORM.                    " GET_LIST_STEP_01_B
*&---------------------------------------------------------------------*
*&      Form  GET_LIST_STEP_01_L
*&---------------------------------------------------------------------*
*       납품오더 리스트를 가져온다.
*----------------------------------------------------------------------*
FORM GET_LIST_STEP_01_L .

  DATA: LV_CNT   TYPE I,
        LV_LFIMG TYPE LIPS-LFIMG,
        LV_INDEX TYPE SY-TABIX.
  CHECK GS_102-KDAUF IS NOT INITIAL.

* SD 문서: 납품: 품목 데이터
  CLEAR: GS_320, GT_320.
  SELECT * FROM LIPS
           INTO CORRESPONDING FIELDS OF TABLE GT_320
          WHERE VGBEL EQ GS_102-KDAUF
            AND LFIMG NE SPACE.         "수량없는 항목 제외

* 수량 계산
*  CLEAR: GS_320.
*  LOOP AT GT_320 INTO GS_320.
*    LV_INDEX = SY-TABIX.
*    SELECT SUM( LFIMG ) FROM LIPS
*                        INTO LV_LFIMG
*                       WHERE VBELN EQ GS_320-VBELN
*                         AND UECHA EQ GS_320-POSNR.
*    GS_320-LFIMG = GS_320-LFIMG + LV_LFIMG.
*    MODIFY GT_320 FROM GS_320 INDEX LV_INDEX.
*    CLEAR: GS_320.
*  ENDLOOP.

* 자재내역 / 플랜트내역
  LOOP AT GT_320 INTO GS_320.
    LV_INDEX = SY-TABIX.
    PERFORM GET_MATNR_DESC  USING    GS_320-MATNR
                                     GS_320-MAKTX.
    PERFORM GET_WERKST  USING    GS_320-WERKS
                        CHANGING GS_320-WERKT.
    MODIFY GT_320 FROM GS_320 INDEX LV_INDEX
                              TRANSPORTING MAKTX WERKT.
    CLEAR: GS_320.
  ENDLOOP.

* 1건 이상이면 팝업창을 열어서 선택하도록 한다.
  DESCRIBE TABLE GT_320 LINES LV_CNT.
  IF LV_CNT > 1.
    CALL SCREEN '0312' STARTING AT 10  8
                       ENDING AT 100  20.
    IF OK_SAVE EQ 'CACL'.
      REJECT.
    ENDIF.
  ELSE.
    READ TABLE GT_320 INTO GS_320 INDEX 1.
    CHECK SY-SUBRC EQ 0.
    GS_MTBLN-KDAUF   = GS_320-VGBEL.   "판매오더번호
    GS_MTBLN-VBELN   = GS_320-VBELN.   "납품오더번호
    GS_MTBLN-POSNR   = GS_320-POSNR.   "납품오더품목
    GS_MTBLN-CHARG   = GS_320-CHARG.   "배치번호
    GS_MTBLN-GELIM   = GS_320-LFIMG.   "납품수량
    GS_MTBLN-MGEIN   = GS_320-MEINS.   "단위
    GS_MTBLN-KDPOS   = GS_320-VGPOS.   "판매오더품목
    GS_MTBLN-MATNR   = GS_320-MATNR.   "자재번호
    GS_MTBLN-MAKTX   = GS_320-MAKTX.   "자재내역
    GS_MTBLN-WERKS_M = GS_320-WERKS.   "플랜트
    GS_MTBLN-WERKST  = GS_320-WERKT.   "플랜트내역
    APPEND GS_MTBLN TO GT_MTBLN.
  ENDIF.

ENDFORM.                    " GET_LIST_STEP_01_L
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_0321
*&---------------------------------------------------------------------*
*       선택된 데이터를 가져온다.
*----------------------------------------------------------------------*
FORM GET_DATA_0321 .

* local variable
  DATA: LT_ROW_NO TYPE LVC_T_ROID,
        LS_ROW_NO TYPE LVC_S_ROID.
  CLEAR: LT_ROW_NO, LT_ROW_NO.

  CALL METHOD G_GRID_321->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_NO.

  DESCRIBE TABLE LT_ROW_NO LINES G_LINES.
  IF G_LINES EQ 0.
    MESSAGE E001 WITH '선택한 행이 없습니다.'.
    EXIT.
  ENDIF.

  LOOP AT LT_ROW_NO INTO LS_ROW_NO.
    CLEAR GT_0321.
    READ TABLE GT_0321 INDEX LS_ROW_NO-ROW_ID.
  ENDLOOP.

ENDFORM.                    " GET_DATA_0321
*&---------------------------------------------------------------------*
*&      Form  GET_LIST_STEP_01_V
*&---------------------------------------------------------------------*
*       판매오더 리스트를 가져온다.
*----------------------------------------------------------------------*
FORM GET_LIST_STEP_01_V .

  DATA: LV_CNT TYPE I,
        LV_LFIMG TYPE LIPS-LFIMG,
        LV_INDEX TYPE SY-TABIX.
  CHECK GS_102-VBELN IS NOT INITIAL.

* SD 문서: 납품: 품목 데이터
  CLEAR: GS_320, GT_320.
  SELECT * FROM LIPS
           INTO CORRESPONDING FIELDS OF TABLE GT_320
          WHERE VBELN EQ GS_102-VBELN
            AND LFIMG NE SPACE.         "수량없는 항목 제외

** 수량 계산
*  CLEAR: GS_320.
*  LOOP AT GT_320 INTO GS_320.
*    LV_INDEX = SY-TABIX.
*    SELECT SUM( LFIMG ) FROM LIPS
*                        INTO LV_LFIMG
*                       WHERE VBELN EQ GS_320-VBELN
*                         AND UECHA EQ GS_320-POSNR.
*    GS_320-LFIMG = GS_320-LFIMG + LV_LFIMG.
*    MODIFY GT_320 FROM GS_320 INDEX LV_INDEX.
*    CLEAR: GS_320.
*  ENDLOOP.

* 자재내역 / 플랜트내역
  LOOP AT GT_320 INTO GS_320.
    LV_INDEX = SY-TABIX.
    PERFORM GET_MATNR_DESC  USING    GS_320-MATNR
                                     GS_320-MAKTX.
    PERFORM GET_WERKST  USING    GS_320-WERKS
                        CHANGING GS_320-WERKT.
    MODIFY GT_320 FROM GS_320 INDEX LV_INDEX
                              TRANSPORTING MAKTX WERKT.
    CLEAR: GS_320.
  ENDLOOP.

* 1건 이상이면 팝업창을 열어서 선택하도록 한다.
  DESCRIBE TABLE GT_320 LINES LV_CNT.
  IF LV_CNT > 1.
    CALL SCREEN '0312' STARTING AT 10  8
                       ENDING AT 100  20.
    IF OK_SAVE EQ 'CACL'.
      REJECT.
    ENDIF.
  ELSE.
    READ TABLE GT_VBELN INDEX 1.
    CHECK SY-SUBRC EQ 0.
    GS_MTBLN-KDAUF   = GS_320-VGBEL.   "판매오더번호
    GS_MTBLN-VBELN   = GS_320-VBELN.   "납품오더번호
    GS_MTBLN-POSNR   = GS_320-POSNR.   "납품오더품목
    GS_MTBLN-CHARG   = GS_320-CHARG.   "배치번호
    GS_MTBLN-GELIM   = GS_320-LFIMG.   "납품수량
    GS_MTBLN-MGEIN   = GS_320-MEINS.   "단위
    GS_MTBLN-KDPOS   = GS_320-VGPOS.   "판매오더품목
    GS_MTBLN-MATNR   = GS_320-MATNR.   "자재번호
    GS_MTBLN-MAKTX   = GS_320-MAKTX.   "자재내역
    GS_MTBLN-WERKS_M = GS_320-WERKS.   "플랜트
    GS_MTBLN-WERKST  = GS_320-WERKT.   "플랜트내역
    APPEND GS_MTBLN TO GT_MTBLN.
  ENDIF.

ENDFORM.                    " GET_LIST_STEP_01_V
*&---------------------------------------------------------------------*
*&      Form  GET_LIST_STEP_02
*&---------------------------------------------------------------------*
*       PO번호 / 기계번호 / 제품군 / 단위를 가져온다.
*----------------------------------------------------------------------*
FORM GET_LIST_STEP_02 .

  LOOP AT GT_MTBLN INTO GS_MTBLN.
    CHECK GS_MTBLN-KDAUF IS NOT INITIAL.
    CHECK GS_MTBLN-KDPOS IS NOT INITIAL.

*   PO번호
    SELECT SINGLE BSTKD BSTDK
             INTO (GS_MTBLN-FERTAUFNR, GS_MTBLN-BSTDK)
             FROM VBKD
            WHERE VBELN EQ GS_MTBLN-KDAUF.

*   기계번호
    SELECT SINGLE EQUNR
             FROM EQBS
             INTO GS_MTBLN-MCNO
            WHERE KDAUF EQ GS_MTBLN-KDAUF
              AND KDPOS EQ GS_MTBLN-KDPOS.

*   제품군 / 단위
    SELECT SINGLE MEINS SPART
             FROM MARA
             INTO (GS_MTBLN-MGEIN, GS_MTBLN-SPGCD)
            WHERE MATNR EQ GS_MTBLN-MATNR.

*   제품군 내역
    PERFORM GET_SPGCD_DESC  USING    GS_MTBLN-SPGCD
                            CHANGING GS_MTBLN-SPGCDT.

    MODIFY GT_MTBLN FROM GS_MTBLN.
  ENDLOOP.

ENDFORM.                    " GET_LIST_STEP_02
*&---------------------------------------------------------------------*
*&      Form  GET_LIST_STEP_03
*&---------------------------------------------------------------------*
*       꼬리표번호 / 드럼번호를 가져온다.
*----------------------------------------------------------------------*
FORM GET_LIST_STEP_03 .

  DATA: LV_CNT   TYPE I,
        LV_MTART LIKE MARA-MTART.

  LOOP AT GT_MTBLN INTO GS_MTBLN.
    CHECK GS_MTBLN-KDAUF IS NOT INITIAL.
    CHECK GS_MTBLN-KDPOS IS NOT INITIAL.

    CLEAR: GT_TAGNR, GT_TAGNR[].

*  전선/부품 구분
    SELECT SINGLE MTART
             FROM MARA
             INTO LV_MTART
            WHERE MATNR EQ GS_MTBLN-MATNR.

    IF LV_MTART+0(2) EQ 'MC'. "전선
      SELECT * FROM ZPPT0001
               APPENDING CORRESPONDING FIELDS OF TABLE GT_TAGNR
              WHERE CHARG EQ GS_MTBLN-CHARG
                AND MATNR EQ GS_MTBLN-MATNR.
    ELSE.
      SELECT TAGNR2 AS TAGNR MATNR CHARG WERKS
             FROM ZPPT0203
             APPENDING CORRESPONDING FIELDS OF TABLE GT_TAGNR
            WHERE CHARG EQ GS_MTBLN-CHARG
              AND MATNR EQ GS_MTBLN-MATNR.
    ENDIF.

*  납품오더/품목으로 조회해도 됨 문제가 생기면 바꿀것
    LOOP AT GT_TAGNR.
      SELECT SINGLE * FROM ZQMT0107
                     WHERE WERKS EQ GS_MTBLN-WERKS_M
                       AND MATNR EQ GS_MTBLN-MATNR
                       AND CHARG EQ GS_MTBLN-CHARG.
      IF SY-SUBRC EQ 0.
        GT_TAGNR-DRUM   = ZQMT0107-DRUM.
        GT_TAGNR-SERIAL = ZQMT0107-SERIAL.
        MODIFY GT_TAGNR.
      ENDIF.
      CLEAR: GT_TAGNR.
    ENDLOOP.

    DESCRIBE TABLE GT_TAGNR LINES LV_CNT.
    IF LV_CNT > 1.
      CALL SCREEN '0313' STARTING AT 10  8
                         ENDING AT 100  20.
    ELSE.
      READ TABLE GT_TAGNR INDEX 1.
      GS_311-TAGNR  = GT_TAGNR-TAGNR.
      GS_311-DRUM   = GT_TAGNR-DRUM.
      GS_311-SERIAL = GT_TAGNR-SERIAL.
    ENDIF.

*  modify
    GS_MTBLN-TAGNR  = GT_TAGNR-TAGNR.
    GS_MTBLN-DRUM   = GT_TAGNR-DRUM.
    GS_MTBLN-SERIAL = GT_TAGNR-SERIAL.

    MODIFY GT_MTBLN FROM GS_MTBLN.
  ENDLOOP.

ENDFORM.                    " GET_LIST_STEP_03
*&---------------------------------------------------------------------*
*&      Form  SET_TBCON_HEADER_MULTI
*&---------------------------------------------------------------------*
*       불만제품 내역 추가 - 헤더(멀티입력)
*----------------------------------------------------------------------*
FORM SET_TBCON_HEADER_MULTI .

* local variable
  DATA: LS_TMP LIKE GT_100,
        LT_TMP LIKE TABLE OF LS_TMP.

  GT_100-RCEPNO    = GS_100-RCEPNO.       "접수번호
  GT_100-MATNR     = GS_MTBLN-MATNR.      "자재번호
  GT_100-MAKTX     = GS_MTBLN-MAKTX.      "자재내역
  GT_100-WERKS_M   = GS_MTBLN-WERKS_M.    "자재플랜트
  GT_100-SPGCD     = GS_MTBLN-SPGCD.      "제품군
  GT_100-MGEIN     = GS_MTBLN-MGEIN.      "단위
  GT_100-VRKME     = GS_MTBLN-MGEIN.      "불만확정수량단위
  GT_100-KDAUF     = GS_MTBLN-KDAUF.      "판매 오더 번호
  GT_100-FERTAUFNR = GS_MTBLN-FERTAUFNR.  "고객구매오더번호
  GT_100-BSTDK     = GS_MTBLN-BSTDK.      "고객구매오더일
  GT_100-ERNAM     = SY-UNAME.            "생성자
  GT_100-ERDAT     = SY-DATUM.            "생성일
  GT_100-ERZET     = SY-UZEIT.            "시간
  GT_100-KZLOESCH  = ''.                  "데이타레코드삭제

* 동일한 내역이 이미 존재한다면 append하지 않는다.
  LT_TMP = GT_100[].
  READ TABLE LT_TMP INTO LS_TMP WITH KEY WERKS_M = GT_100-WERKS_M
                                         MATNR   = GT_100-MATNR
                                         KDAUF   = GT_100-KDAUF.
  IF SY-SUBRC NE 0.
*   현재 등록된 테이블컨트롤의 자재번호 max값을 구한다.
    SORT LT_TMP BY ZMATSEQ DESCENDING.
    READ TABLE LT_TMP INTO LS_TMP INDEX 1.

*   자재seq = table max + 1
    GT_100-ZMATSEQ = LS_TMP-ZMATSEQ + 1.  "자재Seq

*   신규추가된 라인의 라이오버튼을 활성화
    PERFORM OFF_RADIO_BUTTON_0310.
    GT_100-MARK = 'X'.

    APPEND GT_100.

  ELSE.
    GT_100-ZMATSEQ = LS_TMP-ZMATSEQ.      "자재Seq
  ENDIF.

ENDFORM.                    " SET_TBCON_HEADER_MULTI
*&---------------------------------------------------------------------*
*&      Form  SET_TBCON_LIST_MULTI
*&---------------------------------------------------------------------*
*       불만제품 내역 추가 - 리스트(멀티입력)
*----------------------------------------------------------------------*
FORM SET_TBCON_LIST_MULTI .

* local variable
  DATA: LS_TMP LIKE GT_110,
        LT_TMP LIKE TABLE OF LS_TMP.

  CLEAR: GT_110, GT_110[], GT_110A.

* 배치의 헤더를 설정한다.
  GS_101-ZMATSEQ  = GT_100-ZMATSEQ.      "자재Seq
  GS_101-MATNR    = GS_MTBLN-MATNR.      "자재번호
  GS_101-MAKTX    = GS_MTBLN-MAKTX.      "자재내역
  GS_101-KDAUF    = GS_MTBLN-KDAUF.      "판매오더
  GS_101-KZLOESCH = ''.                  "삭제플래그
  GS_101-WERKS_M  = GS_MTBLN-WERKS_M.
  GS_101-WERKST   = GS_MTBLN-WERKST.

* gt_110a 에서 일치하는 데이터를 먼저 가져온다.
  LOOP AT GT_110A WHERE RCEPNO  EQ GT_100-RCEPNO    "접수번호
                    AND ZMATSEQ EQ GT_100-ZMATSEQ.  "자재Seq
    GT_110 = GT_110A.
    APPEND GT_110.
    CLEAR: GT_110, GT_110A.
  ENDLOOP.

* 신규로 입력된 데이터를 설정한다.
  GT_110-RCEPNO    = GT_100-RCEPNO.       "접수번호
  GT_110-ZMATSEQ   = GT_100-ZMATSEQ.      "자재Seq
  GT_110-KDPOS     = GS_MTBLN-KDPOS.      "판매오더 품목
  GT_110-VBELN     = GS_MTBLN-VBELN.      "납품오더
  GT_110-POSNR     = GS_MTBLN-POSNR.      "납품오더 품목
  GT_110-TAGNR     = GS_MTBLN-TAGNR.      "꼬리표번호
  GT_110-DRUM      = GS_MTBLN-DRUM.       "드럼번호
  GT_110-SERIAL    = GS_MTBLN-SERIAL.     "일련번호
  GT_110-MCNO      = GS_MTBLN-MCNO.       "기계번호
  GT_110-CHARG     = GS_MTBLN-CHARG.      "배치 번호
  GT_110-GELIM     = GS_MTBLN-GELIM.      "납품 수량
  GT_110-MGEIN1    = GS_MTBLN-MGEIN.      "단위
  GT_110-MGEIN     = GS_MTBLN-MGEIN.      "단위
  GT_110-VRKME     = GS_MTBLN-MGEIN.      "불만확정수량단위
  GT_110-ERNAM     = SY-UNAME.            "생성자
  GT_110-ERDAT     = SY-DATUM.            "생성일
  GT_110-ERZET     = SY-UZEIT.            "시간
  GT_110-KZLOESCH  = ''.                  "데이타레코드삭제

* 현재 등록된 테이블컨트롤의 배치번호 max값을 구한다.
  LT_TMP = GT_110[].
  SORT LT_TMP BY ZCHASEQ DESCENDING.
  READ TABLE LT_TMP INTO LS_TMP INDEX 1.

* 배치seq = table max + 1
  GT_110-ZCHASEQ = LS_TMP-ZCHASEQ + 1.  "배치Seq

  APPEND GT_110.

* 같은 내용을 gt_110a 에도 append한다.
  APPEND GT_110 TO GT_110A.

* 불량내역엔 데이터가 들어가지 않으므로 clear
  CLEAR: GT_120, GT_120[].

ENDFORM.                    " SET_TBCON_LIST_MULTI
*&---------------------------------------------------------------------*
*&      Form  GET_AMOUNT_A
*&---------------------------------------------------------------------*
*       물류손실금액을 읽어온다.
*----------------------------------------------------------------------*
*FORM GET_AMOUNT_A .
*
** 반품금액 / 반품폐기비 / 반품폐기비(외부) / 잡손실폐기비
** 클레임출고비 / 반품검사비 / 반품운반비
*  SELECT SUM( RFAMT ) SUM( RTAMT ) SUM( RTAMT2 ) SUM( GBAMT )
*         SUM( CLAMT ) SUM( IPCST ) SUM( MVCST )
*    FROM ZQMT0011M
*    INTO (S_710-RFAMT, S_710-RTAMT, S_710-RTAMT2, S_710-GBAMT,
*          S_710-CLAMT, S_710-IPCST, S_710-MVCST)
*   WHERE RCEPNO EQ GS_100-RCEPNO.
*
*ENDFORM.                    " GET_AMOUNT_A
*&---------------------------------------------------------------------*
*&      Form  GET_AMOUNT_b
*&---------------------------------------------------------------------*
*       CS비용을 읽어온다.
*----------------------------------------------------------------------*
*FORM GET_AMOUNT_B .
*
** CS인건비 / CS외주비 / CS부품비
*  SELECT SINGLE CSACT CSOUT CSPAT
*    FROM ZQMT0011H
*    INTO (S_710-CSACT, S_710-CSOUT, S_710-CSPAT)
*   WHERE RCEPNO EQ GS_100-RCEPNO.
*
*ENDFORM.                    " GET_AMOUNT_b
*&---------------------------------------------------------------------*
*&      Form  GET_AMOUNT_C
*&---------------------------------------------------------------------*
*       AS손실금액을 읽어온다.
*----------------------------------------------------------------------*
*FORM GET_AMOUNT_C .
*
** local variable
*  DATA: BEGIN OF LS_AMOUNT,
*          ZFNAME(2),
*          AMOUNT TYPE Z_WOGXXX,
*        END OF LS_AMOUNT,
*        LT_AMOUNT LIKE TABLE OF LS_AMOUNT,
*        LS_SUM LIKE LS_AMOUNT,
*        LT_SUM LIKE TABLE OF LS_SUM.
*  DATA: LV_BUKRS TYPE BUKRS,
*        LV_FIELD(20),
*        LV_INDEX(2) TYPE N.
*  FIELD-SYMBOLS: <LFS> TYPE ANY.
*
** 회사코드를 읽어온다.
*  PERFORM GET_BUKRS  USING    GS_101-WERKS_M
*                     CHANGING LV_BUKRS.
*  CHECK NOT LV_BUKRS IS INITIAL.
*
** 금액을 읽어온다.
*  SELECT B~FNAME A~WOGBTR
*    INTO TABLE LT_AMOUNT
*    FROM ZQMT0016F AS A
*   INNER JOIN ZQMT0017  AS B
*      ON A~BUKRS  EQ B~BUKRS
*     AND A~GJAHR  EQ B~GJAHR
*     AND A~HKONT  EQ B~HKONT
*   WHERE A~BUKRS  EQ LV_BUKRS            "회사코드
*     AND A~GJAHR  EQ GS_100-RCEPDT(4)    "회계연도
*     AND A~DFLG   EQ SPACE
*     AND A~RCEPNO EQ GS_100-RCEPNO.       "접수번호
**     AND b~cflg   EQ space.
*
** 금액의 누계를 구한다.
*  LOOP AT LT_AMOUNT INTO LS_AMOUNT.
*    LS_SUM = LS_AMOUNT.
*    COLLECT LS_SUM INTO LT_SUM.
*    CLEAR: LS_AMOUNT, LS_SUM.
*  ENDLOOP.
*
** 금액을 화면필드에 넣어준다.
*  LOOP AT LT_SUM INTO LS_SUM.
*    LV_INDEX = LS_SUM-ZFNAME.
*    CONCATENATE 'S_710-BEAMT' LV_INDEX INTO LV_FIELD.
*    ASSIGN (LV_FIELD) TO <LFS>.
*    <LFS> = LS_SUM-AMOUNT * 100.
*    CLEAR: LS_SUM, LV_FIELD.
*  ENDLOOP.
*
*ENDFORM.                    " GET_AMOUNT_C
*&---------------------------------------------------------------------*
*&      Form  GET_AMOUNT_S
*&---------------------------------------------------------------------*
*       총손실금액을 구한다.
*----------------------------------------------------------------------*
*FORM GET_AMOUNT_S .
*
** local variable
*  DATA: LV_VPRSV TYPE CKMLCR-VPRSV,
*        LV_COST TYPE MBEW-STPRS,
*        LV_PEINH TYPE MBEW-PEINH,
*        LV_RKMNG TYPE ZQMT0011M-RKMNG,
*        LV_ETAMT TYPE ZQMT0011H-ETAMT.
*
** 추정금액
*  SELECT SINGLE ETAMT
*           FROM ZQMT0011H
*           INTO LV_ETAMT
*          WHERE RCEPNO EQ GS_100-RCEPNO.    "접수번호
** 추정금액을 직접 입력하지 않았으면 읽어온 값을 넣어준다.
*  IF S_710-ETAMT IS INITIAL.
*    S_710-ETAMT = LV_ETAMT.
*  ENDIF.
*
*  IF S_710-ETAMT  IS INITIAL AND
*     GS_100-DSTGR EQ '110'.        "불만사유 : 품질불량
*
*    IF GS_100-RCEPDT(6) EQ SY-DATUM(6).
*      LV_VPRSV = 'S'.
*    ELSE.
*      LV_VPRSV = 'V'.
*    ENDIF.
*
*    SELECT SINGLE B~STPRS A~PEINH
*             INTO (LV_COST, LV_PEINH)
*             FROM MBEW   AS A
*             JOIN CKMLCR AS B
*               ON A~KALN1 EQ B~KALNR
*            WHERE A~MATNR EQ GS_100-MATNR
*              AND A~BWKEY EQ GS_100-WERKS_H
*              AND B~BDATJ EQ GS_100-RCEPDT+0(4)
*              AND B~POPER EQ GS_100-RCEPDT+4(2)
*              AND B~CURTP EQ '10'
*              AND B~VPRSV EQ LV_VPRSV.
*
**   불만제기수량
*    SELECT SUM( RKMNG ) FROM ZQMT0011M
*                        INTO LV_RKMNG
*                       WHERE RCEPNO   EQ GS_100-RCEPNO
*                         AND KZLOESCH EQ SPACE.
*
*    S_710-ETAMT = LV_COST * LV_RKMNG / LV_PEINH * 100.
*  ENDIF.
*
** 총손실금액
*  S_710-LSCST = S_710-RTAMT       "반품폐기비
*              + S_710-RTAMT2      "반품폐기비(외부)
*              + S_710-GBAMT       "잡손실폐기비
*              + S_710-CLAMT       "클레임출고비
*              + S_710-CSACT       "CS 인건비
*              + S_710-CSOUT       "CS 외주비
*              + S_710-CSPAT       "CS 부품비
*              + S_710-BEAMT01     "손실보상비
*              + S_710-BEAMT02     "지체상환금
*              + S_710-BEAMT03     "A/S 지원비
*              + S_710-BEAMT04     "하자보수비
*              + S_710-BEAMT05     "분석검사비
*              + S_710-BEAMT06     "Warranty 비
*              + S_710-BEAMT07.    "CS 자재등구입비
*
*ENDFORM.                    " GET_AMOUNT_S
*&---------------------------------------------------------------------*
*&      Form  SUBMIT_ZQMR0820
*&---------------------------------------------------------------------*
*       ZQMR0820화면 호출
*----------------------------------------------------------------------*
FORM SUBMIT_ZQMR0820 .

* local variable
  DATA: LV_CURSOR(20),
        LV_FIELD(20).
  FIELD-SYMBOLS: <LFS>.

  GET CURSOR FIELD LV_CURSOR.
  ASSIGN COMPONENT LV_CURSOR+6 OF STRUCTURE S_810 TO <LFS>.

* 반품폐기비(외부) 더블클릭
  IF NOT <LFS> IS INITIAL.
    CASE LV_CURSOR.
      WHEN 'S_810-RTAMT'.     "반품폐기비
        PERFORM GET_MSEG_LIST.
        PERFORM CALL_PROGRAM USING 'A'.

      WHEN 'S_810-RTAMT2'.    "반품폐기비(외부)
        PERFORM GET_MSEG_LIST.
        PERFORM CALL_PROGRAM USING 'B'.
    ENDCASE.
  ENDIF.

ENDFORM.                    " SUBMIT_ZQMR0820
*&---------------------------------------------------------------------*
*&      Form  GET_MSEG_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_MSEG_LIST .

* local variable
  DATA: BEGIN OF LS_VBELN,
          VBELN TYPE ZQMT0720-VBELN,
          POSNR TYPE ZQMT0720-POSNR,
        END OF LS_VBELN,
        LT_VBELN LIKE TABLE OF LS_VBELN.

* local variable
  DATA: LS_210 LIKE LINE OF GT_210.
  CLEAR: S_810.

* 선택한 항목을 가져온다.
  READ TABLE GT_210 INTO LS_210 WITH KEY MARK = 'X'.
  CHECK SY-SUBRC EQ 0.

* 판매오더번호 및 품목을 읽어온다.
  SELECT A~KDAUF B~KDPOS
         INTO TABLE LT_VBELN
         FROM ZQMT0011M AS A
         JOIN ZQMT0011B AS B
           ON A~RCEPNO  EQ B~RCEPNO
          AND A~ZMATSEQ EQ B~ZMATSEQ
        WHERE A~RCEPNO  EQ LS_210-RCEPNO.

* 자재내역을 읽어온다.
  CLEAR: GT_MBLNR.
  SELECT A~MBLNR A~MJAHR A~MATNR A~CHARG
         A~WERKS A~BWART A~DMBTR A~QCODE1
         INTO CORRESPONDING FIELDS OF TABLE GT_MBLNR
         FROM ZQMT0718 AS A
         JOIN ZQMT0720 AS B
           ON A~MATNR EQ B~MATNR
          AND A~CHARG EQ B~CHARG
          AND A~WERKS EQ B~WERKS
          FOR ALL ENTRIES IN LT_VBELN
        WHERE B~VBELN EQ LT_VBELN-VBELN
          AND B~POSNR EQ LT_VBELN-POSNR
          AND ( A~QCODE1 EQ 'CG009' OR A~QCODE1 EQ 'CG014' )
          AND B~REV_FLAG NE 'X'
          AND B~NO_TRACE NE 'X'
          AND A~SCR_RET EQ 'X'.

ENDFORM.                    " GET_MSEG_LIST
*&---------------------------------------------------------------------*
*&      Form  CALL_PROGRAM
*&---------------------------------------------------------------------*
*       프로그램 호출
*----------------------------------------------------------------------*
FORM CALL_PROGRAM  USING    VALUE(P_REPORT).

* local variable
  DATA: LV_BUKRS TYPE BUKRS,
        LT_SELTAB TYPE TABLE OF RSPARAMS WITH HEADER LINE.

  CLEAR: GT_MBLNR.
  LOOP AT GT_MBLNR.

    IF SY-TABIX EQ '1'.
      PERFORM GET_BUKRS USING    GT_MBLNR-WERKS_M
                        CHANGING LV_BUKRS.
      CLEAR: LT_SELTAB.
      LT_SELTAB-SELNAME = 'P_KOKRS'.
      LT_SELTAB-LOW     = LV_BUKRS.
      APPEND LT_SELTAB.

      CASE P_REPORT.
        WHEN 'A'.
          CLEAR: LT_SELTAB.
          LT_SELTAB-SELNAME = 'S_QCODE1'.
          LT_SELTAB-KIND    = 'S'.
          LT_SELTAB-SIGN    = 'I'.
          LT_SELTAB-OPTION  = 'EQ'.
          LT_SELTAB-LOW     = 'CG009'.
          APPEND LT_SELTAB.
        WHEN 'B'.
          CLEAR LT_SELTAB.
          LT_SELTAB-SELNAME = 'S_QCODE1'.
          LT_SELTAB-KIND    = 'S'.
          LT_SELTAB-SIGN    = 'I'.
          LT_SELTAB-OPTION  = 'EQ'.
          LT_SELTAB-LOW     = 'CG014'.
          APPEND LT_SELTAB.
      ENDCASE.
    ENDIF.

    CLEAR LT_SELTAB.
    LT_SELTAB-SELNAME = 'S_MATNR'.
    LT_SELTAB-KIND    = 'S'.
    LT_SELTAB-SIGN    = 'I'.
    LT_SELTAB-OPTION  = 'EQ'.
    LT_SELTAB-LOW     = GT_MBLNR-MATNR.
    APPEND LT_SELTAB.

    CLEAR LT_SELTAB.
    LT_SELTAB-SELNAME = 'S_CHARG'.
    LT_SELTAB-KIND    = 'S'.
    LT_SELTAB-SIGN    = 'I'.
    LT_SELTAB-OPTION  = 'EQ'.
    LT_SELTAB-LOW     = GT_MBLNR-CHARG.
    APPEND LT_SELTAB.

    CLEAR LT_SELTAB.
    LT_SELTAB-SELNAME = 'S_WERKS'.
    LT_SELTAB-KIND    = 'S'.
    LT_SELTAB-SIGN    = 'I'.
    LT_SELTAB-OPTION  = 'EQ'.
    LT_SELTAB-LOW     = GT_MBLNR-WERKS_M.
    APPEND LT_SELTAB.
    CLEAR: GT_MBLNR.
  ENDLOOP.

  SORT LT_SELTAB.
  DELETE ADJACENT DUPLICATES FROM LT_SELTAB.

  SUBMIT ZQMR0820 USER SY-UNAME
                  WITH SELECTION-TABLE LT_SELTAB
                  AND RETURN.

ENDFORM.                    " CALL_PROGRAM
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_ZQMT0016F
*&---------------------------------------------------------------------*
*       ZQMT0016F 테이블의 데이터를 읽어온다.
*----------------------------------------------------------------------*
FORM GET_DATA_ZQMT0016F .
* C20111123_03752 :전표관련 수정요청, 비용코드가 없는 경우 제외
  CLEAR: GS_ZQMT0016F, GT_ZQMT0016F.
  SELECT * FROM ZQMT0016F
           INTO TABLE GT_ZQMT0016F
          WHERE RCEPNO EQ GS_100-RCEPNO
              AND ( QCODE1 <> '' AND QCODE1 IS NOT NULL ) .
*            AND dflg   EQ space.

  LOOP AT   GT_ZQMT0016F INTO GS_ZQMT0016F.

*& 2014.05.27, ZLSGQM, 기능개선_19639 반영시작   >> START
    SELECT SINGLE BSTAT
      FROM ZFIT0066
      INTO GS_ZQMT0016F-BSTAT
      WHERE BUKRS = GS_ZQMT0016F-BUKRS
      AND BELNR = GS_ZQMT0016F-BELNR
      AND GJAHR = GS_ZQMT0016F-GJAHR.
*& 2014.05.27, ZLSGQM, 기능개선_19639 반영끝   >> END

    IF GS_ZQMT0016F-SHKZG = 'H'.
      GS_ZQMT0016F-WOGBTR = GS_ZQMT0016F-WOGBTR * -1.
    ENDIF.
    MODIFY GT_ZQMT0016F  FROM GS_ZQMT0016F.
    CLEAR : GS_ZQMT0016F.
  ENDLOOP.

ENDFORM.                    " GET_DATA_ZQMT0016F
*&---------------------------------------------------------------------*
*&      Form  MODIFY_FIELDCAT_910
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MODIFY_FIELDCAT_910  CHANGING PT_FIELDCAT TYPE LVC_T_FCAT.

* local variable
  DATA: LS_FCAT TYPE LVC_S_FCAT.

  LOOP AT PT_FIELDCAT INTO LS_FCAT .
    CASE  LS_FCAT-FIELDNAME.
      WHEN  'MANDT'.
        DELETE PT_FIELDCAT .
      WHEN  'ZCHK' .
        LS_FCAT-COL_POS    =  1.
        LS_FCAT-CHECKBOX   = 'X'.
*        IF GV_TRTYP        = 'V'.
        LS_FCAT-EDIT     = 'X'.
*        ELSE.
*          LS_FCAT-EDIT     = ' '.
*        ENDIF.
        LS_FCAT-FIX_COLUMN = 'X'.
        LS_FCAT-KEY        = 'X'.
        LS_FCAT-COLTEXT    = '선택'.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.

*& 2014.05.27, ZLSGQM, 기능개선_19639 반영시작   >> START
      WHEN 'BSTAT'.
        IF GS_100-WERKS_H+0(1) = '1'.
          LS_FCAT-COL_POS    =  3.
          LS_FCAT-COLTEXT    =  '전표상태'.
          LS_FCAT-KEY        = ' '.
          MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.
        ENDIF.
*& 2014.05.27, ZLSGQM, 기능개선_19639 반영끝   >> END

      WHEN  'LIGHTS' .
        LS_FCAT-COL_POS    =  2.
        LS_FCAT-COLTEXT    = '모니터'.
        LS_FCAT-KEY        = ' '.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.
      WHEN  'STATUST' .
        LS_FCAT-COL_POS    =  4.
        LS_FCAT-COLTEXT    = '상태'.
        LS_FCAT-KEY        = ' '.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.
      WHEN 'BELNR'.
        LS_FCAT-HOTSPOT    =  'X'.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.
      WHEN 'VBELN'.
        LS_FCAT-HOTSPOT    =  'X'.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.
      WHEN 'LVBELN'.
        LS_FCAT-HOTSPOT    =  'X'.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.
      WHEN 'PRUEFLOS'.
        LS_FCAT-HOTSPOT    =  'X'.
        MODIFY PT_FIELDCAT FROM LS_FCAT INDEX SY-TABIX.

      WHEN OTHERS.
    ENDCASE.
    CLEAR: LS_FCAT.
  ENDLOOP.

ENDFORM.                    " MODIFY_FIELDCAT_910
*&---------------------------------------------------------------------*
*&      Form  EXE_910_POSTING
*&---------------------------------------------------------------------*
*       전표생성
*----------------------------------------------------------------------*
FORM EXE_910_POSTING .

* local variable
  DATA: LV_CFLG,
        LV_BUKRS TYPE BUKRS.

  PERFORM GET_BUKRS USING GS_100-WERKS_H
                    CHANGING LV_BUKRS.

  SELECT SINGLE HKONT CFLG
           INTO (S_910-HKONT, LV_CFLG)
           FROM ZQMT0017
          WHERE BUKRS  EQ LV_BUKRS
            AND QCODE1 EQ S_910-BELART.

  IF LV_CFLG NE 'X'.
    MESSAGE S001  WITH '고객불만에서 생성할 수 없는 전표계정입니다.'.
    EXIT.
  ENDIF.

  IF S_910-HKONT IS INITIAL.
    MESSAGE S001 WITH '전표계정을 선택하세요.'.
    EXIT.
  ELSE.

    CLEAR : ZQMS301-NEWKO2.
    CALL SCREEN '0930' STARTING AT 10  5
                       ENDING AT 100  19.
    PERFORM UPDATE_BA_SCREEN.

  ENDIF.

ENDFORM.                    " EXE_910_POSTING
*&---------------------------------------------------------------------*
*&      Form  EXE_910_ADD
*&---------------------------------------------------------------------*
*       전표추가
*----------------------------------------------------------------------*
FORM EXE_910_ADD .

  CALL SCREEN '0920' STARTING AT 15  8  ENDING AT 62  16.
  PERFORM UPDATE_BA_SCREEN.

ENDFORM.                    " EXE_910_ADD



*&---------------------------------------------------------------------*
*&      Form  EXE_910_REVERSE
*&---------------------------------------------------------------------*
*       전표역분개
*----------------------------------------------------------------------*
FORM EXE_910_REVERSE .

* local variable
  DATA: LV_CFLG,
        LV_RETURN(3).

  DATA : LV_BSTAT LIKE ZFIT0066-BSTAT. "기능개선_19639

  CLEAR: GS_ZQMT0016F.
  READ TABLE GT_ZQMT0016F INTO GS_ZQMT0016F WITH KEY ZCHK = 'X'.

* check
  IF GS_ZQMT0016F-BELNR IS INITIAL.
    MESSAGE S001  WITH '전표리스트를 선택하세요.'.
    EXIT.
  ENDIF.

  SELECT SINGLE CFLG FROM ZQMT0017
                     INTO LV_CFLG
                    WHERE BUKRS  EQ GS_ZQMT0016F-BUKRS
                      AND GJAHR  EQ GS_ZQMT0016F-GJAHR
                      AND QCODE1 EQ GS_ZQMT0016F-QCODE1
                      AND HKONT  EQ GS_ZQMT0016F-HKONT.
  IF LV_CFLG NE 'X'.
    PERFORM  F_POPUP_TO_CONFIRM2 USING '전표 역분개'
'선택하신 전표는 역분개 되지 않고, 본 고객불만에서 삭제만 됩니다' &
'계속진행하시겠습니까?'
                                           '예'
                                           '아니오'
                                           'YES'
                                           'NO'
                                 CHANGING  LV_RETURN
                                           G_910_FORM_FLG.

    IF LV_RETURN EQ 'YES'.
      DELETE FROM ZQMT0016F
            WHERE BUKRS EQ GS_ZQMT0016F-BUKRS
              AND BELNR EQ GS_ZQMT0016F-BELNR
              AND GJAHR EQ GS_ZQMT0016F-GJAHR
              AND BUZEI EQ GS_ZQMT0016F-BUZEI.
      IF SY-SUBRC EQ 0.
        COMMIT WORK.
        MESSAGE S001  WITH '성공적으로 취소하였습니다.'.
      ENDIF.
*      EXIT.
    ENDIF.
*  C20120315_70622 : 일반전표인경우만 전표역분개 처리
  ELSE.

    IF GS_ZQMT0016F-DFLG EQ 'X'.
      MESSAGE S001  WITH '이미 역분개 되었습니다.'.
      EXIT.
    ENDIF.

*& 2014.06.12, ZLSGQM, 기능개선_19639 반영시작   >> START
*화면에 보이는 전표상태와 ZFIT0066의 전표상태가 다를 경우
    IF GS_ZQMT0016F-BUKRS = '6000'.

      SELECT SINGLE BSTAT
        FROM ZFIT0066
        INTO LV_BSTAT
        WHERE BUKRS = GS_ZQMT0016F-BUKRS
        AND BELNR = GS_ZQMT0016F-BELNR
        AND GJAHR = GS_ZQMT0016F-GJAHR.

      IF GS_ZQMT0016F-BSTAT <> LV_BSTAT.
        MESSAGE S002 WITH
        '확정전표로 전기되었습니다.' 'LSG QM담당자에게 문의하십시오'.
        EXIT.
      ENDIF.

      IF GS_ZQMT0016F-BSTAT = ''.
        MESSAGE S002 WITH
        '확정전표로 전기되었습니다.' 'LSG QM담당자에게 문의하십시오'.
        EXIT.
      ENDIF.
    ENDIF.
*& 2014.06.12, ZLSGQM, 기능개선_19639 반영시작   >> START

    S_940-BELNR = GS_ZQMT0016F-BELNR.
    S_940-GJAHR = GS_ZQMT0016F-GJAHR.
    S_940-BUKRS = GS_ZQMT0016F-BUKRS.
    CALL SCREEN '0940' STARTING AT 15  8  ENDING AT 62  16.
  ENDIF.

  PERFORM UPDATE_BA_SCREEN_DE.
*  C20120315_70622 : END
ENDFORM.                    " EXE_910_REVERSE
*&---------------------------------------------------------------------*
*&      Form  BDC_GLPOST_CREATE
*&---------------------------------------------------------------------*
*       클레임 전표 생성 BDC (F-02)
*----------------------------------------------------------------------*
FORM BDC_GLPOST_CREATE  USING    VALUE(P_RCEPNO).

  DATA: LV_WRBTR(16),
        LV_WAERK     TYPE VBAK-WAERK,
        LS_EXCH_RATE TYPE BAPI1093_0,
        LV_FLG,
        LS_RETURN    TYPE BAPIRET1,
        LV_DEC       TYPE TCURX-CURRDEC,
        LV_RFAMT     TYPE ZQRFAMT,
        L_TCODE      LIKE SY-TCODE,
        LV_BELNR     TYPE BKPF-BELNR.

  CLEAR   : GT_BDC, MESSTAB.
  REFRESH : GT_BDC, MESSTAB.

* check
*->[가온전선]--------------------CHG S
  IF ZQMS301-BUPLA(1) NE '6'.
    MESSAGE I001 WITH '편철사업장은 6로 시작하는 것만 가능합니다.'.
    G_930_FORM_FLG = 'X'.
  ENDIF.


*  IF ZQMS301-BUKRS EQ '6000' AND ZQMS301-BUPLA(1) NE '1'.
*    MESSAGE I001 WITH '편철사업장은 1로 시작하는 것만 가능합니다.'.
*    G_930_FORM_FLG = 'X'.
*  ENDIF.
*
*  IF ZQMS301-BUKRS EQ '2000' AND ZQMS301-BUPLA(1) NE '2'.
*    MESSAGE I001 WITH '편철사업장은 2로 시작하는 것만 가능합니다.'.
*    G_930_FORM_FLG = 'X'.
*  ENDIF.
*
*  IF ZQMS301-BUKRS EQ '3000' AND ZQMS301-BUPLA(1) NE '3'.
*    MESSAGE I001 WITH '편철사업장은 3로 시작하는 것만 가능합니다.'.
*    G_930_FORM_FLG = 'X'.
*  ENDIF.
*-<[가온전선]--------------------CHG E

  CHECK G_930_FORM_FLG EQ ''.

* 금액
  LV_WAERK = ZQMS301-WAERS.
  IF LV_WAERK IS NOT INITIAL.
    SELECT SINGLE CURRDEC
             INTO LV_DEC
             FROM TCURX
            WHERE CURRKEY EQ LV_WAERK.
    IF SY-SUBRC EQ 0.
      IF LV_DEC > 0.
        LV_WRBTR = ZQMS301-WRBTR * ( 100 / 10 ** LV_DEC ) .
      ELSE.
        LV_WRBTR = ZQMS301-WRBTR * 100.
      ENDIF.
    ELSE.
      LV_WRBTR = ZQMS301-WRBTR.
    ENDIF.
  ENDIF.
  WRITE LV_WRBTR TO LV_WRBTR CURRENCY LV_WAERK.

* 손익센터
  SELECT SINGLE PRCTR INTO ZQMS301-PRCTR
                      FROM CSKS
                     WHERE KOKRS EQ ZQMS301-BUKRS
                       AND KOSTL EQ ZQMS301-KOSTL.


* BDC setting
  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMF05A'          '0100',
          ' '  'BDC_OKCODE'        '/00',
          ' '  'BKPF-BLDAT'        ZQMS301-BLDAT,
          ' '  'BKPF-BLART'        ZQMS301-BLART,
          ' '  'BKPF-BUKRS'        ZQMS301-BUKRS,
          ' '  'BKPF-BUDAT'        ZQMS301-BUDAT,
          ' '  'BKPF-MONAT'        ZQMS301-MONAT,
          ' '  'BKPF-WAERS'        ZQMS301-WAERS,
          ' '  'BKPF-BKTXT'        ZQMS301-BKTXT,
          ' '  'RF05A-NEWBS'       ZQMS301-NEWBS2,
          ' '  'RF05A-NEWKO'       ZQMS301-NEWKO2.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMF05A'          '0302',
          ' '  'BDC_OKCODE'        '/00',
          ' '  'BSEG-WRBTR'        LV_WRBTR,        "금액
          ' '  'BKPF-XMWST'        'X',             "세금계산
          ' '  'BSEG-MWSKZ'        ZQMS301-MWSKZ,   "세금코드
          ' '  'BSEG-BUPLA'        ZQMS301-BUPLA,   "사업장
          ' '  'BSEG-GSBER'        ZQMS301-GSBER,   "사업영역
          ' '  'RF05A-NEWBS'       ZQMS301-NEWBS1,
          ' '  'RF05A-NEWKO'       ZQMS301-NEWKO1,
          ' '  'BSEG-SGTXT'        ZQMS301-BKTXT.  "아이템text

  IF GV_EMPFK IS NOT INITIAL.
    PERFORM STORE_BDCDATA   USING:
          ' '  'BSEG-EMPFB'         GV_EMPFK.        "대체수취인
  ENDIF.

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMF05A'          '0300',
          ' '  'BDC_OKCODE'        '=COBL_XERGO',
          ' '  'BSEG-WRBTR'        LV_WRBTR,        "금액
          ' '  'BSEG-MWSKZ'        ZQMS301-MWSKZ,   "세금코드
          ' '  'BSEG-SGTXT'        ZQMS301-BKTXT.  "아이템text

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPLKEAK'          '0400',
          ' '  'BDC_OKCODE'        '=WEIT',
          ' '  'RKEAK-FIELD(02)'   ZQMS301-KUNUM,  "고객
          ' '  'RKEAK-FIELD(03)'   ZQMS301-WERKS,  "플랜트
          ' '  'RKEAK-FIELD(04)'   ZQMS301-MATNR,  "제품번호
          ' '  'RKEAK-FIELD(05)'   GS_100-SPGCD,  "제품군
          ' '  'RKEAK-FIELD(06)'   ZQMS301-PRCTR,  "손익센터
          ' '  'RKEAK-FIELD(07)'   ZQMS301-KOSTL,  "코스트센터
          ' '  'RKEAK-FIELD(08)'   ZQMS301-BUKRS,
                                   "ZQMS301-KUNUM,  "영업조직
          ' '  'RKEAK-FIELD(09)'   GS_100-VTWEG,  "유통경로
          ' '  'RKEAK-FIELD(10)'   GS_100-VKBUR,  "영업팀
          ' '  'RKEAK-FIELD(11)'   GS_100-VKGRP.  "영업그룹

  PERFORM STORE_BDCDATA   USING:
          'X'  'SAPMF05A'          '0300',
          ' '  'BDC_OKCODE'        '=BU'.

*->[가온전선]--------------------CHG S
  "FI 유효성점검 'ZGGBR000 => UF112  FM 'ZFI_CHECK_QMCOST_ROL'에서 IMPORT
  L_TCODE = 'ZGTSDR1250' .
*  L_TCODE = 'ZQM2R0696' .
*-<[가온전선]--------------------CHG E
  EXPORT L_TCODE TO MEMORY ID 'BDC_CALLER'.

  PERFORM BDC_TRANSACTION  USING     'F-02'
                                     G_DIMODE
                           CHANGING  G_SUBRC.

  READ TABLE MESSTAB WITH KEY MSGTYP = 'S' MSGNR = '312'.

  IF SY-SUBRC EQ 0.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = SY-MSGV1
      IMPORTING
        OUTPUT = LV_BELNR.
    COMMIT WORK.
    MESSAGE S003  WITH '전표번호' LV_BELNR '을(를) 생성하였습니다'.
  ELSE.
    DESCRIBE TABLE MESSTAB.
    READ TABLE MESSTAB INDEX SY-TFILL.
    IF SY-SUBRC EQ 0.
      MESSAGE ID MESSTAB-MSGID TYPE 'S' NUMBER MESSTAB-MSGNR.
    ENDIF.
    EXIT.
  ENDIF.

  IF LV_BELNR IS NOT INITIAL.
    PERFORM UPDATE_BA USING ZQMS301-BUKRS
                            LV_BELNR
                            ZQMS301-BUDAT+0(4)
                            ZQMS301-CPERNR
                            ZQMS301-CPERNRT
                            ZQMS301-CNAM
                            ZQMS301-CNAMT.

    PERFORM GET_BA_LIST .
    PERFORM REFRESH_GRID_930.
  ENDIF.

ENDFORM.                    " BDC_GLPOST_CREATE
*&---------------------------------------------------------------------*
*&      Form  BDC_GLPOST_CREATE
*&---------------------------------------------------------------------*
*       클레임 전표 생성 BDC (F-02)
*----------------------------------------------------------------------*
FORM BDC_GLPOST_CREATE_NEW  TABLES  PT_BBKPF STRUCTURE BBKPF
                                    PT_BBSEG STRUCTURE BBSEG
                             USING    VALUE(P_RCEPNO).

  DATA: LV_WRBTR(16),
        LV_WAERK     TYPE VBAK-WAERK,
        LS_EXCH_RATE TYPE BAPI1093_0,
        LV_FLG,
        LS_RETURN    TYPE BAPIRET1,
        LV_DEC       TYPE TCURX-CURRDEC,
        LV_RFAMT     TYPE ZQRFAMT,
        L_TCODE      LIKE SY-TCODE,
        LV_BELNR     TYPE BKPF-BELNR,
        LV_MSG(100).

  CLEAR   : GT_BDC, MESSTAB.
  REFRESH : GT_BDC, MESSTAB.

* check
*->[가온전선]--------------------CHG S
  IF ZQMS301-BUPLA(1) NE '6'.
    MESSAGE I001 WITH '편철사업장은 6로 시작하는 것만 가능합니다.'.
    G_930_FORM_FLG = 'X'.
  ENDIF.


*  IF ZQMS301-BUKRS EQ '6000' AND ZQMS301-BUPLA(1) NE '1'.
*    MESSAGE I001 WITH '편철사업장은 1로 시작하는 것만 가능합니다.'.
*    G_930_FORM_FLG = 'X'.
*  ENDIF.
*
*  IF ZQMS301-BUKRS EQ '2000' AND ZQMS301-BUPLA(1) NE '2'.
*    MESSAGE I001 WITH '편철사업장은 2로 시작하는 것만 가능합니다.'.
*    G_930_FORM_FLG = 'X'.
*  ENDIF.
*
*  IF ZQMS301-BUKRS EQ '3000' AND ZQMS301-BUPLA(1) NE '3'.
*    MESSAGE I001 WITH '편철사업장은 3로 시작하는 것만 가능합니다.'.
*    G_930_FORM_FLG = 'X'.
*  ENDIF.
*-<[가온전선]--------------------CHG E

  CHECK G_930_FORM_FLG EQ ''.

* 금액
  LV_WAERK = ZQMS301-WAERS.
  IF LV_WAERK IS NOT INITIAL.
    SELECT SINGLE CURRDEC
             INTO LV_DEC
             FROM TCURX
            WHERE CURRKEY EQ LV_WAERK.
    IF SY-SUBRC EQ 0.
      IF LV_DEC > 0.
        LV_WRBTR = ZQMS301-WRBTR * ( 100 / 10 ** LV_DEC ) .
      ELSE.
        LV_WRBTR = ZQMS301-WRBTR * 100.
      ENDIF.
    ELSE.
      LV_WRBTR = ZQMS301-WRBTR.
    ENDIF.
  ENDIF.
  WRITE LV_WRBTR TO LV_WRBTR CURRENCY LV_WAERK.

* 손익센터
  SELECT SINGLE PRCTR INTO ZQMS301-PRCTR
                      FROM CSKS
                     WHERE KOKRS EQ ZQMS301-BUKRS
                       AND KOSTL EQ ZQMS301-KOSTL.


  CLEAR: PT_BBKPF[], PT_BBKPF, PT_BBSEG[], PT_BBSEG.

* 전표헤더정보
  PT_BBKPF-TCODE = 'FB01'.
  PT_BBKPF-BLDAT = ZQMS301-BLDAT .
  PT_BBKPF-BLART = ZQMS301-BLART .
  PT_BBKPF-BUKRS = ZQMS301-BUKRS .
  PT_BBKPF-BUDAT = ZQMS301-BUDAT .
  PT_BBKPF-MONAT = ZQMS301-MONAT .
  PT_BBKPF-WAERS = ZQMS301-WAERS .
  PT_BBKPF-BKTXT = ZQMS301-BKTXT .
  PT_BBKPF-XMWST = 'X'.             "세금계산
  APPEND PT_BBKPF.

* 라인아이템 1
  PT_BBSEG-NEWBS = ZQMS301-NEWBS2.
  PT_BBSEG-NEWKO = ZQMS301-NEWKO2.
  PT_BBSEG-WRBTR = LV_WRBTR.         "금액
  PT_BBSEG-MWSKZ = ZQMS301-MWSKZ.    "세금코드
  PT_BBSEG-BUPLA = ZQMS301-BUPLA.    "사업장
  PT_BBSEG-GSBER = ZQMS301-GSBER.    "사업영역
  PT_BBSEG-SGTXT = ZQMS301-BKTXT.    "아이템text
  IF GV_EMPFK IS NOT INITIAL.
    PT_BBSEG-EMPFB = GV_EMPFK.       "대체수취인
  ENDIF.
  APPEND PT_BBSEG. CLEAR PT_BBSEG.

* 라인아이템 2
  PT_BBSEG-NEWBS = ZQMS301-NEWBS1.
  PT_BBSEG-NEWKO = ZQMS301-NEWKO1.
  PT_BBSEG-WRBTR = LV_WRBTR.         "금액
  PT_BBSEG-MWSKZ = ZQMS301-MWSKZ.    "세금코드
  PT_BBSEG-SGTXT = ZQMS301-BKTXT.    "아이템text

  PT_BBSEG-RKE_BUKRS      = ZQMS301-BUKRS .
  PT_BBSEG-RKE_KNDNR      = ZQMS301-KUNUM .  "고객
  PT_BBSEG-RKE_WERKS      = ZQMS301-WERKS .  "플랜트
  PT_BBSEG-RKE_ARTNR      = ZQMS301-MATNR .  "제품번호
  PT_BBSEG-RKE_SPART      = GS_100-SPGCD  .  "제품군
  PT_BBSEG-RKE_PRCTR      = ZQMS301-PRCTR .  "손익센터
  PT_BBSEG-RKE_COPA_KOSTL = ZQMS301-KOSTL .  "코스트센터
  PT_BBSEG-RKE_VKORG      = ZQMS301-BUKRS .  "영업조직
  PT_BBSEG-RKE_VTWEG      = GS_100-VTWEG  .  "유통경로
  PT_BBSEG-RKE_KMVKBU     = GS_100-VKBUR  .  "영업팀
*  PT_BBSEG-RKE_VKGRP      = GS_100-VKGRP.   "영업그룹
  PT_BBSEG-RKE_KMVKGR     = GS_100-VKGRP  .  "영업그룹
  APPEND PT_BBSEG. CLEAR PT_BBSEG.

*->[가온전선]--------------------CHG S
  "FI 유효성점검 'ZGGBR000 => UF112  FM 'ZFI_CHECK_QMCOST_ROL'에서 IMPORT
  L_TCODE = 'ZGTSDR1250' .
*  L_TCODE = 'ZQM2R0696' .
*-<[가온전선]--------------------CHG E
  EXPORT L_TCODE TO MEMORY ID 'BDC_CALLER'.

* 전표생성 펑션 Call
  CLEAR: LV_BELNR, LV_MSG.
  CALL FUNCTION 'ZFI_DOCUMENT_POSTING'
    EXPORTING
      I_BDC_MODE  = G_DIMODE
      I_MESSAGE   = ''
    IMPORTING
      E_BELNR     = LV_BELNR
      E_RESULTMSG = LV_MSG
    TABLES
      T_BBKPF     = PT_BBKPF
      T_BBSEG     = PT_BBSEG.

  IF NOT LV_BELNR IS INITIAL.
    MESSAGE S003  WITH '전표번호' LV_BELNR '을(를) 생성하였습니다'.
  ELSE.
    MESSAGE S001 WITH LV_MSG.
    EXIT.
  ENDIF.

  IF LV_BELNR IS NOT INITIAL.
    PERFORM UPDATE_BA USING ZQMS301-BUKRS
                            LV_BELNR
                            ZQMS301-BUDAT+0(4)
                            ZQMS301-CPERNR
                            ZQMS301-CPERNRT
                            ZQMS301-CNAM
                            ZQMS301-CNAMT.

    PERFORM GET_BA_LIST .
    PERFORM REFRESH_GRID_930.
  ENDIF.

ENDFORM.                    " BDC_GLPOST_CREATE_NEW
*&---------------------------------------------------------------------*
*&      Form  UPDATE_BA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPDATE_BA USING VALUE(P_BUKRS)
                     VALUE(P_BELNR)
                     VALUE(P_GJAHR)
                     VALUE(P_CPERNR)
                     VALUE(P_CPERNRT)
                     VALUE(P_CNAM)
                     VALUE(P_CNAMT).
* local variable
  DATA: LV_PAOBJNR LIKE BSEG-PAOBJNR,
        LV_PASUBNR LIKE BSEG-PASUBNR,
        LV_TNAME(15),
        LV_INDEX TYPE SY-TABIX.

  CLEAR: GS_BADATA, GT_BADATA.
  SELECT BUKRS BELNR GJAHR BUZEI KOART SHKZG
         HKONT GSBER DMBTR AS WOGBTR SGTXT KOSTL
         INTO CORRESPONDING FIELDS OF TABLE GT_BADATA
         FROM BSEG
        WHERE BUKRS EQ P_BUKRS
          AND BELNR EQ P_BELNR
          AND GJAHR EQ P_GJAHR
          AND KOART EQ 'S' .


* 공사 재작업비 인경우
  IF SY-SUBRC <> 0 AND G_BUKRS =  '6000'.
    PERFORM SELECT_GONSA_REWORK.
  ELSE.
* 일반 전표인 경우
    LOOP AT GT_BADATA INTO GS_BADATA.
      LV_INDEX = SY-TABIX.

*   고객계정
      SELECT SINGLE LIFNR
               INTO GS_BADATA-LIFNR
               FROM BSEG
              WHERE BUKRS EQ P_BUKRS
                AND BELNR EQ P_BELNR
                AND GJAHR EQ P_GJAHR
                AND LIFNR NE SPACE .

      SELECT SINGLE NAME1
               INTO GS_BADATA-LIFNRT
               FROM LFA1
              WHERE LIFNR EQ GS_BADATA-LIFNR.

      SELECT SINGLE WAERS
               INTO GS_BADATA-WAERS
               FROM T001
              WHERE BUKRS EQ GS_BADATA-BUKRS.

      SELECT SINGLE BLART BKTXT BUDAT CPUDT AEDAT
               INTO (GS_BADATA-BLART, GS_BADATA-BKTXT, GS_BADATA-BUDAT,
                     GS_BADATA-ERDAT, GS_BADATA-AEDAT)
               FROM BKPF
              WHERE BUKRS EQ GS_BADATA-BUKRS
                AND BELNR EQ GS_BADATA-BELNR
                AND GJAHR EQ GS_BADATA-GJAHR.

      GS_BADATA-RCEPNO = GS_100-RCEPNO.
      GS_BADATA-CPERNR = P_CPERNR.
      IF P_CPERNRT IS INITIAL.
        PERFORM GET_USRID USING P_CPERNR
                       CHANGING P_CPERNRT
                                P_CNAM
                                P_CNAMT.
      ENDIF.

      GS_BADATA-CPERNRT = P_CPERNRT.
      GS_BADATA-CNAM    = P_CNAM.
      GS_BADATA-CNAMT   = P_CNAMT.

*   코스트센터
      SELECT SINGLE PAOBJNR  PASUBNR
               INTO (LV_PAOBJNR, LV_PASUBNR)
               FROM BSEG
              WHERE BUKRS EQ GS_BADATA-BUKRS
                AND BELNR EQ GS_BADATA-BELNR
                AND BUZEI EQ GS_BADATA-BUZEI
                AND GJAHR EQ GS_BADATA-GJAHR.

      CONCATENATE 'CE4' GS_BADATA-BUKRS '_ACCT' INTO LV_TNAME.

      SELECT SINGLE COPA_KOSTL
               INTO GS_BADATA-KOSTL
               FROM (LV_TNAME)
              WHERE AKTBO   EQ 'X'
                AND PAOBJNR EQ LV_PAOBJNR
                AND PASUBNR EQ LV_PASUBNR.

*   품질비용 코드
      SELECT SINGLE QCODE1 INTO GS_BADATA-QCODE1
               FROM ZQMT0017
              WHERE BUKRS EQ GS_BADATA-BUKRS
                AND GJAHR EQ GS_BADATA-GJAHR
                AND HKONT EQ GS_BADATA-HKONT.

      SELECT SINGLE QCODE_TXT INTO GS_BADATA-QCODE_TXT
               FROM ZQMT0700
              WHERE KOKRS  EQ GS_BADATA-BUKRS
                AND QCODE1 EQ GS_BADATA-QCODE1.

      MODIFY GT_BADATA FROM GS_BADATA INDEX LV_INDEX.
      CLEAR: GS_BADATA.
    ENDLOOP.

  ENDIF.


  MODIFY ZQMT0016F FROM TABLE GT_BADATA.
  IF SY-SUBRC EQ 0.
    MESSAGE S001 WITH '전표를 정상적으로 저장하였습니다.'.
  ELSE.
    G_ERROR_FLG = 'X'.
  ENDIF.

ENDFORM.                    " UPDATE_BA


*&---------------------------------------------------------------------*
*&      Form  UPDATE_BA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPDATE_18M USING VALUE(S_950) LIKE S_950.

  DATA : LS_18M TYPE ZQMT0018M.


  MOVE-CORRESPONDING S_950 TO LS_18M.

  SELECT SINGLE BWART INTO LS_18M-BWART
     FROM MATDOC
    WHERE GJAHR = S_950-GJAHR
    AND MBLNR = S_950-MBLNR.

  LS_18M-RCEPNO = GV_RCEPNO.

  IF SY-SUBRC <> 0.
    MESSAGE E001 WITH '존재하지 않는 자재문서 입니다.'.
    EXIT.

  ENDIF.

  SELECT SINGLE QCODE1 INTO LS_18M-QCODE1
    FROM ZQMT0717
    WHERE KOKRS = S_950-BUKRS
    AND GJAHR = S_950-GJAHR
    AND BWART = LS_18M-BWART.
  IF SY-SUBRC NE 0.
    LS_18M-QCODE1 = 'CG009'.
  ENDIF.



  MODIFY ZQMT0018M FROM LS_18M.
  IF SY-SUBRC EQ 0.
    MESSAGE S001 WITH '자재문서를 정상적으로 저장하였습니다.'.
  ELSE.
    G_ERROR_FLG = 'X'.
  ENDIF.

ENDFORM.                    " UPDATE_BA

*&---------------------------------------------------------------------*
*&      Form  GET_bA_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_BA_LIST.

  CLEAR: GT_ZQMT0016F, GS_ZQMT0016F, GT_ZQMT0016F[].
  SELECT * FROM ZQMT0016F
           INTO CORRESPONDING FIELDS OF TABLE GT_ZQMT0016F
          WHERE RCEPNO EQ GS_100-RCEPNO.
*            AND dflg   EQ space.
*& 2014.05.29, ZLSGQM, 기능개선_19639 반영시작   >> START
  LOOP AT   GT_ZQMT0016F INTO GS_ZQMT0016F.
    IF GS_ZQMT0016F-BUKRS = '6000'.

      SELECT SINGLE BSTAT
        FROM ZFIT0066
        INTO GS_ZQMT0016F-BSTAT
        WHERE BUKRS = GS_ZQMT0016F-BUKRS
        AND BELNR = GS_ZQMT0016F-BELNR
        AND GJAHR = GS_ZQMT0016F-GJAHR.
      MODIFY GT_ZQMT0016F  FROM GS_ZQMT0016F.
      CLEAR : GS_ZQMT0016F.
    ENDIF.
  ENDLOOP.
*& 2014.05.29, ZLSGQM, 기능개선_19639 반영끝   >> END
ENDFORM.                    " GET_bA_LIST
*&---------------------------------------------------------------------*
*&      Form  REFRESH_GRID_930
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM REFRESH_GRID_930 .
  DATA : L_LVC_S_ROW LIKE LVC_S_ROW.



  CHECK NOT G_GRID_910 IS INITIAL.

  CALL METHOD G_GRID_910->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYOUT910.

  GS_SCROLL-ROW = 'X'. "기능개선_19639
  GS_SCROLL-COL = 'X'. "기능개선_19639

  CALL METHOD G_GRID_910->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = ' '
      IS_STABLE      = GS_SCROLL. "기능개선_19639

* C20120525_15658 커서위치는 체크 박스 위치로 고정
  READ TABLE GT_ZQMT0016F INTO GS_ZQMT0016F WITH KEY ZCHK = 'X'.
  IF SY-SUBRC = 0.
    L_LVC_S_ROW-INDEX = SY-TABIX.
  ENDIF .
  CALL METHOD G_GRID_910->SET_CURRENT_CELL_VIA_ID
    EXPORTING
      IS_ROW_ID = L_LVC_S_ROW.
* C20120525_15658 : END

  CALL METHOD CL_GUI_CFW=>FLUSH.
ENDFORM.                    " REFRESH_GRID_930

*&---------------------------------------------------------------------*
*&      Form  REFRESH_GRID_930
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM REFRESH_GRID_960 .

  CHECK NOT G_GRID_960 IS INITIAL.

  CALL METHOD G_GRID_960->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYOUT960.

  CALL METHOD G_GRID_960->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = ' '.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.                    " REFRESH_GRID_930
*&---------------------------------------------------------------------*
*&      Form  UPDATE_BA_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPDATE_BA_SCREEN .


  PERFORM FI_COST.
  PERFORM GET_BA_LIST .


  PERFORM REFRESH_GRID_930.

ENDFORM.                    " UPDATE_BA_SCREEN

*----------------------------------------------------------------------*
*&      Form  UPDATE_BA_SCREEN
*----------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPDATE_BA_SCREEN_DE .

  PERFORM  GET_DATA_ZQMT0016F.
  PERFORM REFRESH_GRID_930.

ENDFORM.                    " UPDATE_BA_SCREEN_DE
*&                                                                     *
*&---------------------------------------------------------------------*
*&      Form  FI_COST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FI_COST .

* local variable
  DATA: LV_SNAME(10),
        LV_NUM TYPE NUMC2.
  FIELD-SYMBOLS: <LFS> TYPE ANY.

  CLEAR: S_910-BEAMT01, S_910-BEAMT02, S_910-BEAMT03, S_910-BEAMT04,
         S_910-BEAMT05, S_910-BEAMT06, S_910-BEAMT07, S_910-BEAMT08,
         S_910-BEAMT09, S_910-BEAMT10.

  PERFORM GET_BA_LIST .
  CHECK NOT GT_ZQMT0016F IS INITIAL.

  LOOP AT GT_ZQMT0016F INTO GS_ZQMT0016F WHERE DFLG NE 'X'.
    CLEAR: LV_NUM.
    S_910-WAERS = GS_ZQMT0016F-WAERS.

*   비용은 CURR인데 ZQMT0011테이블인 DEC 타입이어서 100을 곱함
    GS_ZQMT0016F-WOGBTR = GS_ZQMT0016F-WOGBTR * 100.

    SELECT SINGLE FNAME FROM ZQMT0017
                        INTO LV_NUM
                       WHERE BUKRS  EQ GS_ZQMT0016F-BUKRS
                         AND GJAHR  EQ GS_ZQMT0016F-GJAHR
                         AND QCODE1 EQ GS_ZQMT0016F-QCODE1
                         AND HKONT  EQ GS_ZQMT0016F-HKONT.
    CHECK LV_NUM NE SPACE.
    CONCATENATE 'BEAMT' LV_NUM INTO LV_SNAME.

    ASSIGN COMPONENT LV_SNAME OF STRUCTURE S_910 TO <LFS>.

*   차/대변 금액 누적
    CASE GS_ZQMT0016F-SHKZG.
      WHEN 'S'.    "차변
        <LFS> = <LFS> +  GS_ZQMT0016F-WOGBTR.
      WHEN 'H'.    "대변
        <LFS> = <LFS> - GS_ZQMT0016F-WOGBTR.
    ENDCASE.
    CLEAR: GS_ZQMT0016F.
  ENDLOOP.

ENDFORM.                    " FI_COST
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER_910
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_910 .

* class 선언
  CREATE OBJECT G_EVENT_910.

* Edit  이벤트 등록
  CALL METHOD G_GRID_910->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  CALL METHOD G_GRID_910->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

* DATA_CHANGED event
  SET HANDLER G_EVENT_910->HANDLE_DATA_CHANGED_910 FOR G_GRID_910.
  SET HANDLER G_EVENT_910->HANDLE_HOTSPOT_CLICK_910 FOR G_GRID_910.

ENDFORM.                    " EVENT_HANDLER_REGISTER_910
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED_910
*&---------------------------------------------------------------------*
*       data change event
*----------------------------------------------------------------------*
FORM DATA_CHANGED_910  USING    ER_DATA_CHANGED
                            TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.
* local variable
  DATA: LS_MOD_CELLS  TYPE LVC_S_MODI,
        LS_CELLS      TYPE LVC_S_MODI,
        LS_FIELDCAT   TYPE LVC_S_FCAT,
        LV_INDEX TYPE SY-TABIX.

  CLEAR: GS_ZQMT0016F.
  LOOP AT ER_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
  ENDLOOP.

  LOOP AT GT_ZQMT0016F INTO GS_ZQMT0016F.
    LV_INDEX = SY-TABIX.
    IF LS_MOD_CELLS-ROW_ID NE LV_INDEX.
      GS_ZQMT0016F-ZCHK = SPACE.
    ELSE.
      GS_ZQMT0016F-ZCHK = 'X'.
    ENDIF.

    MODIFY GT_ZQMT0016F FROM GS_ZQMT0016F INDEX LV_INDEX.
  ENDLOOP.


  PERFORM REFRESH_GRID_930.

ENDFORM.                    " DATA_CHANGED_910
*&---------------------------------------------------------------------*
*&      Form  f_popup_to_confirm2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0662   text
*      -->P_0663   text
*      -->P_0664   text
*      -->P_0665   text
*      -->P_0666   text
*      -->P_0667   text
*      <--P_GS_RFUND_AUART  text
*      <--P_G_1105_FORM_FLG  text
*----------------------------------------------------------------------*
FORM F_POPUP_TO_CONFIRM2  USING   VALUE(P_TITLEBAR)
                                  VALUE(P_TEXT_QUESTION)
                                  VALUE(P_TEXT1)
                                  VALUE(P_TEXT2)
                                  VALUE(P_INFO1)
                                  VALUE(P_INFO2)
                        CHANGING  VALUE(P_AUART)
                                  VALUE(P_FLG).

  DATA: L_TEXT_BUTTON_1(20),
        L_TEXT_BUTTON_2(20),
        L_INFO_BUTTON_1(20),
        L_INFO_BUTTON_2(20),
        L_FLG(1).

  CLEAR: P_FLG.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = P_TITLEBAR
      TEXT_QUESTION         = P_TEXT_QUESTION
      TEXT_BUTTON_1         = P_TEXT1
      TEXT_BUTTON_2         = P_TEXT2
      DISPLAY_CANCEL_BUTTON = 'X'
      IV_QUICKINFO_BUTTON_1 = P_INFO1
      IV_QUICKINFO_BUTTON_2 = P_INFO2
    IMPORTING
      ANSWER                = L_FLG
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1.

  IF  SY-SUBRC  EQ  0.
    IF  L_FLG  EQ  '1'.
      P_AUART  =  P_INFO1.
    ELSEIF  L_FLG  EQ  '2'.
      P_AUART  =  P_INFO2.
    ELSE.
      P_FLG    =  'X'.
    ENDIF.
  ELSE.
    P_FLG      =  'X'.
  ENDIF.

ENDFORM.                    " F_POPUP_TO_CONFIRM2
*&---------------------------------------------------------------------*
*&      Form  EXE_940_REVERSE
*&---------------------------------------------------------------------*
*       역분개
*----------------------------------------------------------------------*
FORM EXE_940_REVERSE .

  CLEAR   : GT_BDC, MESSTAB.
  REFRESH : GT_BDC, MESSTAB.

*& 2014.05.29, ZLSGQM, 기능개선_19639 반영시작   >> START
  IF S_940-CPERNRT = ''.
    MESSAGE S004 WITH '작성자 입력 후 ENTER를 누르세요.'.
  ELSE.
*& 2014.05.29, ZLSGQM, 기능개선_19639 반영끝   >> END

    PERFORM  BDC_REVERSE_ENTRIES  USING  GS_100-RCEPNO
                                         S_940-BELNR
                                         S_940-BUKRS
                                         GS_ZQMT0016F-BUDAT
                                  CHANGING S_940-RBELNR.

    UPDATE ZQMT0016F SET DFLG  = 'X'
                         AEDAT = SY-DATUM
                   WHERE BUKRS EQ S_940-BUKRS
                     AND BELNR EQ S_940-BELNR
                     AND GJAHR EQ S_940-GJAHR.
    IF SY-SUBRC EQ 0.
      COMMIT WORK.
    ENDIF.

    PERFORM UPDATE_BA USING S_940-BUKRS
                            S_940-RBELNR
                            S_940-GJAHR
                            S_940-CPERNR
                            S_940-CPERNRT
                            S_940-CNAM
                            S_940-CNAMT.
    UPDATE ZQMT0016F SET DFLG = 'X'
                   WHERE BUKRS EQ S_940-BUKRS
                     AND BELNR EQ S_940-RBELNR
                     AND GJAHR EQ S_940-GJAHR.
    IF SY-SUBRC EQ 0.
      COMMIT WORK.
    ENDIF.

    CLEAR: S_940-BELNR, GS_ZQMT0016F-BELNR.
    PERFORM FI_COST. "기능개선_19639
    PERFORM GET_BA_LIST .
    PERFORM REFRESH_GRID_930.

    LEAVE TO SCREEN 0.

  ENDIF. "기능개선_19639

ENDFORM.                    " EXE_940_REVERSE
*&---------------------------------------------------------------------*
*&      Form  BDC_REVERSE_ENTRIES
*&---------------------------------------------------------------------*
*       G/L 계정 전기 취소 BDC (FB08)
*----------------------------------------------------------------------*
FORM BDC_REVERSE_ENTRIES  USING  VALUE(P_RCEPNO)
                                 VALUE(P_BELNR)
                                 VALUE(P_BUKRS)
                                 VALUE(P_BUDAT)
                           CHANGING P_RBELNR TYPE BELNR_D.

  PERFORM STORE_BDCDATA   USING:
          'X'    'SAPMF05A'           '0105',
          ' '    'BDC_OKCODE'         '=BU',
          ' '    'RF05A-BELNS'        P_BELNR,
          ' '    'BKPF-BUKRS'         P_BUKRS,
          ' '    'RF05A-GJAHS'        P_BUDAT+0(4),
          ' '    'UF05A-STGRD'        '01'.

  PERFORM BDC_TRANSACTION  USING     'FB08'
                                     'N'
                           CHANGING  G_SUBRC.

  READ    TABLE MESSTAB  WITH KEY MSGTYP = 'S' MSGNR = '312'.

  IF  SY-SUBRC  EQ  0.
    MESSAGE S004  WITH P_BELNR  '의 역분개 전표번호는'
                     MESSTAB-MSGV1  '입니다'.
  ELSE.
    DESCRIBE  TABLE MESSTAB.
    READ    TABLE MESSTAB  INDEX  SY-TFILL.
    IF  SY-SUBRC  EQ  0.
      MESSAGE  ID MESSTAB-MSGID TYPE 'S' NUMBER MESSTAB-MSGNR.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = MESSTAB-MSGV1
    IMPORTING
      OUTPUT = P_RBELNR.

ENDFORM.                    " BDC_REVERSE_ENTRIES
*&---------------------------------------------------------------------*
*&      Form  HOTSPOT_CLICK_910
*&---------------------------------------------------------------------*
*       전표번호 클릭
*----------------------------------------------------------------------*
FORM HOTSPOT_CLICK_910  USING    E_ROW_ID    TYPE LVC_S_ROW
                                 E_COLUMN_ID TYPE LVC_S_COL.
* check
  IF E_ROW_ID-ROWTYPE NE SPACE.
    MESSAGE S009.
    EXIT.
  ENDIF.

  CLEAR: GS_ZQMT0016F.
  CASE E_COLUMN_ID-FIELDNAME.
*   전표번호
    WHEN 'BELNR'.
      READ TABLE GT_ZQMT0016F INTO GS_ZQMT0016F INDEX E_ROW_ID.
      IF GS_ZQMT0016F-BELNR IS INITIAL.
        MESSAGE S001 WITH '전표를 선택하세요'..
        EXIT.
      ENDIF.

      SET PARAMETER ID 'BLN' FIELD GS_ZQMT0016F-BELNR.
      SET PARAMETER ID 'BUK' FIELD GS_ZQMT0016F-BUKRS.
      SET PARAMETER ID 'GJR' FIELD GS_ZQMT0016F-GJAHR.

      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
  ENDCASE.

ENDFORM.                    " HOTSPOT_CLICK_910
*&---------------------------------------------------------------------*
*&      Form  EXE_940_ADD
*&---------------------------------------------------------------------*
*       전표추가
*----------------------------------------------------------------------*
FORM EXE_940_ADD .

* local variable
  DATA: LV_ERROR.

  PERFORM CHECK_BELNR CHANGING LV_ERROR.
  CHECK LV_ERROR NE 'X'.

  PERFORM UPDATE_BA USING S_940-BUKRS
                          S_940-BELNR
                          S_940-GJAHR
                          S_940-CPERNR
                          S_940-CPERNRT
                          S_940-CNAM
                          S_940-CNAMT.
  LEAVE TO SCREEN 0.

ENDFORM.                    " EXE_940_ADD

*&---------------------------------------------------------------------*
*&      Form  EXE_940_ADD
*&---------------------------------------------------------------------*
*       문서추가
*----------------------------------------------------------------------*
FORM EXE_950_ADD .

* local variable
  DATA: LV_ERROR.

  PERFORM UPDATE_18M USING S_950.
  LEAVE TO SCREEN 0.

ENDFORM.                    " EXE_950_ADD

*&---------------------------------------------------------------------*
*&      Form  CHECK_BELNR
*&---------------------------------------------------------------------*
*       전표확인
*----------------------------------------------------------------------*
FORM CHECK_BELNR CHANGING P_ERROR.

* local variable
  DATA: LT_HKONT LIKE BSEG-HKONT OCCURS 0 WITH HEADER LINE.

* check 1
  SELECT COUNT(*) FROM ZQMT0016F
                 WHERE BUKRS EQ S_940-BUKRS
                   AND BELNR EQ S_940-BELNR
                   AND GJAHR EQ S_940-GJAHR.
  IF SY-SUBRC EQ 0.
    MESSAGE I003 WITH '입력하신 전표는 이미 고객불만' GS_100-RCEPNO
    '번에 입력된 전표 입니다.'.
    P_ERROR = 'X'.
    EXIT.
  ENDIF.

* check 2
  SELECT COUNT(*) FROM BKPF
                 WHERE BUKRS EQ S_940-BUKRS
                   AND BELNR EQ S_940-BELNR
                   AND GJAHR EQ S_940-GJAHR.
  IF SY-SUBRC NE 0.
    MESSAGE I001 WITH '입력하신 전표는 존재하지 않습니다'.
    P_ERROR = 'X'.
    EXIT.
  ENDIF.

* check 3
  SELECT HKONT FROM BSEG
               INTO TABLE LT_HKONT
              WHERE BUKRS EQ S_940-BUKRS
                AND BELNR EQ S_940-BELNR
                AND GJAHR EQ S_940-GJAHR.
  P_ERROR = 'X'.

  LOOP AT LT_HKONT.
    SELECT COUNT(*) FROM ZQMT0017
                   WHERE BUKRS EQ S_940-BUKRS
                     AND GJAHR EQ S_940-GJAHR
                     AND HKONT EQ LT_HKONT.
    IF SY-SUBRC EQ 0.
      CLEAR: P_ERROR.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF P_ERROR EQ 'X'.
    MESSAGE S001  WITH '고객불만에서 추가할 수 없는 전표계정입니다.'.
    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_BELNR
*&---------------------------------------------------------------------*
*&      Form  SET_FIELD_DETAIL
*&---------------------------------------------------------------------*
*       ALV column setting
*----------------------------------------------------------------------*
FORM SET_FIELD_DETAIL   USING    P_SCREEN
                        CHANGING PT_FC TYPE LVC_T_FCAT.

  CLEAR: PT_FC.

* fieldname / text / key / sum / color / curr
  CASE P_SCREEN.
    WHEN '0323'.
      PERFORM SET_FIELDCAT USING:
             PT_FC  'KDAUF'     '판매오더번호'    ' '  ' '  ' '  ' ',
             PT_FC  'KDPOS'     '판매오더 품목'   ' '  ' '  ' '  ' ',
             PT_FC  'VBELN'     '납품오더'        ' '  ' '  ' '  ' ',
             PT_FC  'POSNR'     '납품오더 품목'   ' '  ' '  ' '  ' ',
             PT_FC  'FERTAUFNR' '생산오더'        ' '  ' '  ' '  ' ',
             PT_FC  'BSTDK'     '고객 구매오더일' ' '  ' '  ' '  ' ',
             PT_FC  'TAGNR'     '꼬리표번호'      ' '  ' '  ' '  ' ',
             PT_FC  'DRUM'      '드럼번호'        ' '  ' '  ' '  ' ',
             PT_FC  'SERIAL'    '일련번호'        ' '  ' '  ' '  ' ',
             PT_FC  'MCNO'      '기계번호'        ' '  ' '  ' '  ' ',
             PT_FC  'CHARG'     '배치번호'        ' '  ' '  ' '  ' ',
             PT_FC  'GELIM'     '납품수량'        ' '  ' '  ' '  ' ',
             PT_FC  'MGEIN'     '단위'            ' '  ' '  ' '  ' ',
             PT_FC  'SPGCD'     '제품군'          ' '  ' '  ' '  ' ',
             PT_FC  'SPGCDT'    '제품군내역'      ' '  ' '  ' '  ' ',
             PT_FC  'WERKS_M'   '플랜트'          ' '  ' '  ' '  ' ',
             PT_FC  'WERKST'    '플랜트명'        ' '  ' '  ' '  ' ',
             PT_FC  'MATNR'     '자재번호'        ' '  ' '  ' '  ' ',
             PT_FC  'MAKTX '    '자재명'          ' '  ' '  ' '  ' '.
  ENDCASE.

ENDFORM.                    " SET_FIELD_DETAIL
*&---------------------------------------------------------------------*
*&      Form  set_fieldcat
*&---------------------------------------------------------------------*
*       Field catalog itab에 append
*----------------------------------------------------------------------*
FORM SET_FIELDCAT USING    PT_FC  TYPE LVC_T_FCAT
                           P_FIELDNAME
                           P_REPTEXT
                           P_KEY
                           P_SUM
                           P_COLOR
                           P_CURR.
* local variable
  DATA: LS_FIELDCAT TYPE LVC_S_FCAT.

  CLEAR: LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME  = P_FIELDNAME.
  LS_FIELDCAT-REPTEXT    = P_REPTEXT.
  LS_FIELDCAT-KEY        = P_KEY.
  LS_FIELDCAT-DO_SUM     = P_SUM.
  LS_FIELDCAT-EMPHASIZE  = P_COLOR.
  LS_FIELDCAT-CURRENCY   = P_CURR.
  LS_FIELDCAT-DECIMALS_O = 0.
  APPEND LS_FIELDCAT TO PT_FC.

ENDFORM.                    " set_fieldcat
*&---------------------------------------------------------------------*
*&      Form  GET_0323_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_0323_DISPLAY .

* local variable
  DATA: LS_TMP LIKE GS_MTBLN,
        LT_TMP LIKE TABLE OF LS_TMP.
  DATA: LT_ROW_NO TYPE LVC_T_ROID,
        LS_ROW_NO TYPE LVC_S_ROID,
        LV_CNT TYPE I.
  CLEAR: LT_ROW_NO, LT_ROW_NO[].

  CALL METHOD G_GRID_323->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_NO.

  DESCRIBE TABLE LT_ROW_NO LINES LV_CNT.
  IF LV_CNT EQ 0.
    MESSAGE E001 WITH '선택한 행이 없습니다.'.
    EXIT.
  ENDIF.

* 선택된 내역을 temp itab으로 옮긴다.
  CLEAR: GS_MTBLN, LS_TMP, LT_TMP.
  LOOP AT LT_ROW_NO INTO LS_ROW_NO.
    READ TABLE GT_MTBLN INTO GS_MTBLN INDEX LS_ROW_NO-ROW_ID.
    IF SY-SUBRC EQ 0.
      LS_TMP = GS_MTBLN.
      APPEND LS_TMP TO LT_TMP.
    ENDIF.
    CLEAR: GS_MTBLN, LS_TMP.
  ENDLOOP.

* temp itab의 내용을 gt_mtbln itab으로 옮긴다.
  CLEAR: GT_MTBLN, GS_MTBLN.
  GT_MTBLN = LT_TMP.

ENDFORM.                    " GET_0323_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  GET_COUNT_MATCT
*&---------------------------------------------------------------------*
*       불만집계의 누적값을 구한다.
*       유효한(삭제제외) '자재-플랜트' 정보 중 중복을 제외한
*       접수번호(삭제제외)의 수
*----------------------------------------------------------------------*
FORM GET_COUNT_MATCT  USING    P_WERKS
                               P_MATNR
                               P_RCEPNO
                               P_ZMATSEQ
                      CHANGING P_MATCT.
* local variable
  DATA: BEGIN OF GS_011M,
          RCEPNO TYPE ZQMT0011M-RCEPNO,     "접수번호
          WERKS_M TYPE ZQMT0011M-WERKS_M,   "자재플랜트
          MATNR TYPE ZQMT0011M-MATNR,       "자재 번호
        END OF GS_011M,
        GT_011M LIKE TABLE OF GS_011M.

  CLEAR: P_MATCT.

* 플랜트,자재번호 로 데이터를 모두 읽어온다. (삭제제외)
  SELECT A~RCEPNO A~WERKS_M A~MATNR
         FROM ZQMT0011M AS A
         JOIN ZQMT0011H AS B
           ON A~RCEPNO EQ B~RCEPNO
         INTO TABLE GT_011M
        WHERE A~WERKS_M  EQ P_WERKS    "플랜트
          AND A~MATNR    EQ P_MATNR    "자재번호
          AND A~KZLOESCH EQ SPACE      "삭제제외
          AND B~KZLOESCH EQ SPACE.     "삭제제외

* 접수번호 중복은 삭제한다.
  SORT GT_011M BY RCEPNO.
  DELETE ADJACENT DUPLICATES FROM GT_011M COMPARING RCEPNO.

* 누적건수를 구한다.
  DESCRIBE TABLE GT_011M LINES P_MATCT.

* 현재데이터가 테이블에 존재하지 않으면 아직 저장된것이 아니므로
* 결과값에 +1을 해준다.
  SELECT SINGLE * FROM ZQMT0011M
                 WHERE RCEPNO  EQ P_RCEPNO
                   AND ZMATSEQ EQ P_ZMATSEQ.
  IF SY-SUBRC NE 0.
    P_MATCT = P_MATCT + 1.
  ENDIF.

ENDFORM.                    " GET_COUNT_MATCT
*&---------------------------------------------------------------------*
*&      Form  GET_COUNT_KUNCT
*&---------------------------------------------------------------------*
*       불만주의의 누적값을 구한다.
*       유효한 '고객-자재-플랜트' 정보 중 중복을 제외한
*       접수번호(삭제제외)의 수
*----------------------------------------------------------------------*
FORM GET_COUNT_KUNCT  USING    P_KUNUM
                               P_WERKS
                               P_MATNR
                               P_RCEPNO
                               P_ZMATSEQ
                      CHANGING P_KUNCT.
* local variable
  DATA: BEGIN OF LS_011M,
          RCEPNO TYPE ZQMT0011M-RCEPNO,     "접수번호
          WERKS_M TYPE ZQMT0011M-WERKS_M,   "자재플랜트
          MATNR TYPE ZQMT0011M-MATNR,       "자재 번호
        END OF LS_011M,
        LT_011M LIKE TABLE OF LS_011M.

  CLEAR: P_KUNCT.

* 고객, 플랜트,자재번호 로 데이터를 모두 읽어온다. (삭제제외)
  SELECT A~RCEPNO A~WERKS_M A~MATNR
         FROM ZQMT0011M AS A
         JOIN ZQMT0011H AS B
           ON A~RCEPNO EQ B~RCEPNO
         INTO TABLE LT_011M
        WHERE A~WERKS_M  EQ P_WERKS    "플랜트
          AND A~MATNR    EQ P_MATNR    "자재번호
          AND A~KZLOESCH EQ SPACE      "삭제제외
          AND B~KUNUM    EQ P_KUNUM    "고객
          AND B~KZLOESCH EQ SPACE.     "삭제제외

* 접수번호 중복은 삭제한다.
  SORT LT_011M BY RCEPNO.
  DELETE ADJACENT DUPLICATES FROM LT_011M COMPARING RCEPNO.

* 누적건수를 구한다.
  DESCRIBE TABLE LT_011M LINES P_KUNCT.

* 현재데이터가 테이블에 존재하지 않으면 아직 저장된것이 아니므로
* 결과값에 +1을 해준다.
  SELECT SINGLE * FROM ZQMT0011M
                 WHERE RCEPNO  EQ P_RCEPNO
                   AND ZMATSEQ EQ P_ZMATSEQ.
  IF SY-SUBRC NE 0.
    P_KUNCT = P_KUNCT + 1.
  ENDIF.

ENDFORM.                    " GET_COUNT_KUNCT
*&---------------------------------------------------------------------*
*&      Form  GET_COUNT_REDCT
*&---------------------------------------------------------------------*
*       불만재발 누적값을 구한다.
*       유효한 '고객-불량유형(코드그룹/코드)' 정보 중 중복을 제외한
*       접수번호(삭제제외)의 수
*----------------------------------------------------------------------*
FORM GET_COUNT_REDCT  USING    P_KUNUM      "고객
                               P_FTGRP      "코드그룹
                               P_FLTTP      "코드
                               P_RCEPNO     "접수번호
                               P_ZMATSEQ    "자재Seq
                               P_ZBADSEQ    "불량Seq
                               P_WERKS      "플랜트
                      CHANGING P_REDCT.     "불만재발

* local variable
  DATA: BEGIN OF LS_012N,
          RCEPNO TYPE ZQMT0012N-RCEPNO,
        END OF LS_012N,
        LT_012N LIKE TABLE OF LS_012N.
  DATA: LV_BUKRS TYPE BUKRS.

  CLEAR: P_REDCT.
* 회사코드를 구한다.
  PERFORM GET_BUKRS USING    P_WERKS
                    CHANGING LV_BUKRS.

* 고객, 그룹, 코드 로 데이터를 모두 읽어온다. (삭제제외)
  SELECT A~RCEPNO
         FROM ZQMT0012N AS A
         JOIN ZQMT0011H AS B
           ON A~RCEPNO EQ B~RCEPNO
         INTO TABLE LT_012N
        WHERE A~BUKRS    EQ LV_BUKRS    "회사코드
          AND A~FTGRP    EQ P_FTGRP     "결함유형코드그룹
          AND A~FLTTP    EQ P_FLTTP     "결함유형코드
          AND A~DFLG     EQ SPACE       "삭제제외
          AND B~KUNUM    EQ P_KUNUM     "고객
          AND B~KZLOESCH EQ SPACE.      "삭제제외

* 접수번호 중복은 삭제한다.
  SORT LT_012N BY RCEPNO.
  DELETE ADJACENT DUPLICATES FROM LT_012N COMPARING RCEPNO.

* 누적건수를 구한다.
  DESCRIBE TABLE LT_012N LINES P_REDCT.

* 현재데이터가 테이블에 존재하지 않으면 아직 저장된것이 아니므로
* 결과값에 +1을 해준다.
  SELECT SINGLE * FROM ZQMT0012N
                 WHERE BUKRS   EQ LV_BUKRS    "회사코드
                   AND RCEPNO  EQ P_RCEPNO    "접수번호
                   AND ZMATSEQ EQ P_ZMATSEQ   "자재Seq
                   AND ZBADSEQ EQ P_ZBADSEQ.  "불량Seq
  IF SY-SUBRC NE 0.
    P_REDCT = P_REDCT + 1.
  ENDIF.

ENDFORM.                    " GET_COUNT_REDCT
*&---------------------------------------------------------------------*
*&      Form  EXE_RECOM_COST_ALL
*&---------------------------------------------------------------------*
*       비용재계산
*----------------------------------------------------------------------*
FORM EXE_RECOM_COST_ALL .

  CALL FUNCTION 'Z_QM_RECOM_COST'
    EXPORTING
      I_RCEPNO = GS_100-RCEPNO        "접수번호
      I_WERKS  = GS_100-WERKS_H.      "자재플랜트

  PERFORM REFRESH_TABLE_DATA.

ENDFORM.                    " EXE_RECOM_COST_ALL
*&---------------------------------------------------------------------*
*&      Form  INSERT_CUSTOM_CLAIM_0800
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INSERT_CUSTOM_CLAIM_0800 .

* 추정손실금액 저장
  IF G_BUKRS <> '6000'.
    CHECK NOT S_710-ETAMT IS INITIAL.
  ENDIF.

  UPDATE ZQMT0011H SET ETAMT = S_710-ETAMT
                 WHERE RCEPNO EQ GS_100-RCEPNO.

ENDFORM.                    " INSERT_CUSTOM_CLAIM_0800
*&---------------------------------------------------------------------*
*&      Form  SET_TBCON_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_TBCON_DATA .
  DATA: LV_ZMATSEQ  LIKE ZQMT0011M-ZMATSEQ,
        LV_ZCHASEQ  LIKE ZQMT0011B-ZCHASEQ.

  CLEAR : LV_ZMATSEQ.

  LOOP AT GT_100.
    IF GT_100-ZMATSEQ > LV_ZMATSEQ.
      LV_ZMATSEQ = GT_100-ZMATSEQ.
    ENDIF.
  ENDLOOP.

  READ TABLE GT_100 WITH KEY WERKS_M = GS_MTBLN-WERKS_M
                             MATNR   = GS_MTBLN-MATNR
                             KDAUF   = GS_MTBLN-KDAUF.
  IF SY-SUBRC = 0.
    PERFORM OFF_RADIO_BUTTON_0310.
    GT_100-MARK = 'X'.
    MODIFY GT_100 INDEX SY-TABIX.

    CLEAR : LV_ZCHASEQ.

    LOOP AT GT_110A WHERE RCEPNO  = GT_100-RCEPNO
                      AND ZMATSEQ = GT_100-ZMATSEQ.
      IF GT_110A-ZCHASEQ > LV_ZCHASEQ.
        LV_ZCHASEQ = GT_110A-ZCHASEQ.
      ENDIF.
    ENDLOOP.

    READ TABLE GT_110A WITH KEY KDPOS  = GS_MTBLN-KDPOS
                                VBELN  = GS_MTBLN-VBELN
                                POSNR  = GS_MTBLN-POSNR
                                TAGNR  = GS_MTBLN-TAGNR
                                DRUM   = GS_MTBLN-DRUM
                                SERIAL = GS_MTBLN-SERIAL
                                MCNO   = GS_MTBLN-MCNO
                                CHARG  = GS_MTBLN-CHARG.
    IF SY-SUBRC <> 0.
      GT_110A-ZCHASEQ   = LV_ZCHASEQ + 1.
      GT_110A-RCEPNO    = GT_100-RCEPNO.       "접수번호
      GT_110A-ZMATSEQ   = GT_100-ZMATSEQ.      "자재Seq
      GT_110A-KDPOS     = GS_MTBLN-KDPOS.      "판매오더 품목
      GT_110A-VBELN     = GS_MTBLN-VBELN.      "납품오더
      GT_110A-POSNR     = GS_MTBLN-POSNR.      "납품오더 품목
      GT_110A-TAGNR     = GS_MTBLN-TAGNR.      "꼬리표번호
      GT_110A-DRUM      = GS_MTBLN-DRUM.       "드럼번호
      GT_110A-SERIAL    = GS_MTBLN-SERIAL.     "일련번호
      GT_110A-MCNO      = GS_MTBLN-MCNO.       "기계번호
      GT_110A-CHARG     = GS_MTBLN-CHARG.      "배치 번호
      GT_110A-GELIM     = GS_MTBLN-GELIM.      "납품 수량
      GT_110A-MGEIN1    = GS_MTBLN-MGEIN.      "단위
      GT_110A-MGEIN     = GS_MTBLN-MGEIN.      "단위
      GT_110A-VRKME     = GS_MTBLN-MGEIN.      "불만확정수량단위
      GT_110A-ERNAM     = SY-UNAME.            "생성자
      GT_110A-ERDAT     = SY-DATUM.            "생성일
      GT_110A-ERZET     = SY-UZEIT.            "시간
      GT_110A-KZLOESCH  = ''.                  "데이타레코드삭제
* C20120417_91448 : 고객불만 추가 정보 조회
      GT_110A-KDPOS     = GS_MTBLN-KDPOS.      "품목번호 추가
      APPEND GT_110A.
    ENDIF.
  ELSE.
*___자재 Seq. 추가
    CLEAR : GT_100.

    GT_100-ZMATSEQ   = LV_ZMATSEQ + 1.
    GT_100-RCEPNO    = GS_100-RCEPNO.       "접수번호
    GT_100-MATNR     = GS_MTBLN-MATNR.      "자재번호
    GT_100-MAKTX     = GS_MTBLN-MAKTX.      "자재내역
    GT_100-WERKS_M   = GS_MTBLN-WERKS_M.    "자재플랜트
    GT_100-SPGCD     = GS_MTBLN-SPGCD.      "제품군
    GT_100-MGEIN     = GS_MTBLN-MGEIN.      "단위
    GT_100-VRKME     = GS_MTBLN-MGEIN.      "불만확정수량단위
    GT_100-KDAUF     = GS_MTBLN-KDAUF.      "판매 오더 번호
    GT_100-FERTAUFNR = GS_MTBLN-FERTAUFNR.  "고객구매오더번호
    GT_100-BSTDK     = GS_MTBLN-BSTDK.      "고객구매오더일
    GT_100-ERNAM     = SY-UNAME.            "생성자
    GT_100-ERDAT     = SY-DATUM.            "생성일
    GT_100-ERZET     = SY-UZEIT.            "시간
    GT_100-KZLOESCH  = ''.                  "데이타레코드삭제
* C20120417_91448 : 고객불만 추가 정보 조회
    GT_100-KDPOS     = GS_MTBLN-KDPOS.      "품목번호 추가
    PERFORM OFF_RADIO_BUTTON_0310.
    GT_100-MARK = 'X'.

    APPEND GT_100.

*___배치 추가
    CLEAR : GT_110A.

    GT_110A-ZCHASEQ   = '1'.
    GT_110A-RCEPNO    = GT_100-RCEPNO.       "접수번호
    GT_110A-ZMATSEQ   = GT_100-ZMATSEQ.      "자재Seq
    GT_110A-KDPOS     = GS_MTBLN-KDPOS.      "판매오더 품목
    GT_110A-VBELN     = GS_MTBLN-VBELN.      "납품오더
    GT_110A-POSNR     = GS_MTBLN-POSNR.      "납품오더 품목
    GT_110A-TAGNR     = GS_MTBLN-TAGNR.      "꼬리표번호
    GT_110A-DRUM      = GS_MTBLN-DRUM.       "드럼번호
    GT_110A-SERIAL    = GS_MTBLN-SERIAL.     "일련번호
    GT_110A-MCNO      = GS_MTBLN-MCNO.       "기계번호
    GT_110A-CHARG     = GS_MTBLN-CHARG.      "배치 번호
    GT_110A-GELIM     = GS_MTBLN-GELIM.      "납품 수량
    GT_110A-MGEIN1    = GS_MTBLN-MGEIN.      "단위
    GT_110A-MGEIN     = GS_MTBLN-MGEIN.      "단위
    GT_110A-VRKME     = GS_MTBLN-MGEIN.      "불만확정수량단위
    GT_110A-ERNAM     = SY-UNAME.            "생성자
    GT_110A-ERDAT     = SY-DATUM.            "생성일
    GT_110A-ERZET     = SY-UZEIT.            "시간
    GT_110A-KZLOESCH  = ''.                  "데이타레코드삭제
* C20120417_91448 : 고객불만 추가 정보 조회
    GT_110A-KDPOS     = GS_MTBLN-KDPOS.      "품목번호 추가
    APPEND GT_110A.
  ENDIF.

ENDFORM.                    " SET_TBCON_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_DISPLAY_BATCH_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DISPLAY_BATCH_DATA .

  CLEAR   : GT_110.
  REFRESH : GT_110.

  READ TABLE GT_100 WITH KEY MARK = 'X'.
  IF SY-SUBRC = 0.
    LOOP AT GT_110A WHERE RCEPNO = GT_100-RCEPNO
                      AND ZMATSEQ = GT_100-ZMATSEQ.
      MOVE-CORRESPONDING GT_110A TO GT_110.

      APPEND GT_110.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " SET_DISPLAY_BATCH_DATA
*&---------------------------------------------------------------------*
*&      Form  CHECK_FLTTP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_FLTTP  USING    PV_FTGRP
                           PV_FLTTP
                           PV_TEXT.

  CLEAR : PV_TEXT.

  CHECK PV_FTGRP IS NOT INITIAL AND
        PV_FLTTP IS NOT INITIAL.

  SELECT SINGLE B~KURZTEXT
    INTO PV_TEXT
    FROM QPCD AS A
   INNER JOIN QPCT AS B
      ON A~KATALOGART = B~KATALOGART
     AND A~CODEGRUPPE = B~CODEGRUPPE
     AND A~CODE       = B~CODE
     AND B~SPRACHE    = SY-LANGU
     AND A~VERSION    = B~VERSION
   WHERE A~KATALOGART = '5'
     AND A~CODEGRUPPE = PV_FTGRP
     AND A~CODE       = PV_FLTTP.

  IF SY-SUBRC <> 0.
    MESSAGE E001 WITH '원인그룹/코드를 점검하십시오'.
  ENDIF.

ENDFORM.                    " CHECK_FLTTP
*&---------------------------------------------------------------------*
*&      Form  HOTSPOT_CLICK_1210
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM HOTSPOT_CLICK_1210  USING    E_ROW_ID    TYPE LVC_S_ROW
                                  E_COLUMN_ID TYPE LVC_S_COL.
* check
  IF E_ROW_ID-ROWTYPE NE SPACE.
    MESSAGE S009.
    EXIT.
  ENDIF.

  CASE E_COLUMN_ID-FIELDNAME.
*   판매오더
    WHEN 'KDAUF'.
      READ TABLE GT_280 INDEX E_ROW_ID.
      IF GT_280-KDAUF IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD GT_280-KDAUF.

        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.

ENDFORM.                    " HOTSPOT_CLICK_1210
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED_960
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_960 USING    ER_DATA_CHANGED
                            TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.
* local variable
  DATA : LS_MOD_CELLS  TYPE LVC_S_MODI,
        LS_CELLS      TYPE LVC_S_MODI,
        LS_FIELDCAT   TYPE LVC_S_FCAT,
        LV_INDEX TYPE SY-TABIX.

  CLEAR: GS_ZQMT0018M.
  LOOP AT ER_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.

    CASE LS_MOD_CELLS-FIELDNAME.
      WHEN 'MBLNR'.    "자재문서인 경우 체크 로직
        IF LS_MOD_CELLS-VALUE <> ''.
          PERFORM CHECK_MBLNR  USING LS_MOD_CELLS.
          PERFORM REFRESH_GRID_960.
        ENDIF.
      WHEN 'CPERNR'.    "자재문서인 경우 체크 로직
        IF LS_MOD_CELLS-VALUE <> ''.
          PERFORM CHECK_CPERNR  USING LS_MOD_CELLS.
          PERFORM REFRESH_GRID_960.
        ENDIF.
      WHEN OTHERS.

    ENDCASE.

  ENDLOOP.


ENDFORM.                    " DATA_CHANGED_960
*&---------------------------------------------------------------------*
*&      Form  CHECK_MBLNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_MOD_CELLS  text
*----------------------------------------------------------------------*
FORM CHECK_MBLNR  USING   P_LS_MODI TYPE LVC_S_MODI.
  DATA : LS_18M TYPE ZQMT0018M.

  READ TABLE GT_ZQMT0018M INTO LS_18M INDEX  P_LS_MODI-ROW_ID.

  SELECT SINGLE BWART  GJAHR BUKRS
     INTO (LS_18M-BWART , LS_18M-GJAHR, LS_18M-BUKRS)
   FROM MATDOC
  WHERE MBLNR = P_LS_MODI-VALUE.

  LS_18M-RCEPNO = GV_RCEPNO.

  IF SY-SUBRC <> 0.
    MESSAGE E001   WITH '존재하지 않는 자재문서 입니다.'.

    EXIT.
  ENDIF.

  SELECT SINGLE QCODE1 INTO LS_18M-QCODE1
    FROM ZQMT0717
    WHERE KOKRS = LS_18M-BUKRS
    AND GJAHR = LS_18M-GJAHR
    AND BWART = LS_18M-BWART.
  IF SY-SUBRC NE 0.
    LS_18M-QCODE1 = 'CG009'.
  ENDIF.

  MODIFY GT_ZQMT0018M FROM  LS_18M INDEX P_LS_MODI-ROW_ID.

ENDFORM.                    " CHECK_MBLNR
*&---------------------------------------------------------------------*
*&      Form  CHECK_CPERNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_MOD_CELLS  text
*----------------------------------------------------------------------*
FORM CHECK_CPERNR  USING    P_LS_MODI TYPE LVC_S_MODI.
  DATA : L_ZZ_ESSGB LIKE zpa0105-ZZ_ESSGB.
  DATA : LS_18M TYPE ZQMT0018M.
  DATA : L_USREID LIKE zpa0105-USRID.
  DATA : P_PERNRIDT LIKE ZQMT0011H-CORDIT.
  DATA : P_PERNRID  LIKE ZQMT0011H-CORDI.

  READ TABLE GT_ZQMT0018M INTO LS_18M INDEX  P_LS_MODI-ROW_ID.

  PERFORM GET_USRID USING    P_LS_MODI-VALUE  " LS_18M-cpernr
                    CHANGING LS_18M-CPERNRT
                             LS_18M-CNAM
                             LS_18M-CNAMT.


  MODIFY GT_ZQMT0018M FROM  LS_18M INDEX P_LS_MODI-ROW_ID.

ENDFORM.                    " CHECK_CPERNR
*&---------------------------------------------------------------------*
*&      Form  SELECT_GONSA_REWORK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_GONSA_REWORK .

ENDFORM.                    " SELECT_GONSA_REWORK
*&---------------------------------------------------------------------*
*&      Form  EXE_940_REVERSE1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXE_940_REVERSE1 .

  CLEAR   : GT_BDC, MESSTAB.
  REFRESH : GT_BDC, MESSTAB.

  IF S_940-CPERNRT = ''.
    MESSAGE S004 WITH '작성자 입력 후 ENTER를 누르세요.'.
  ELSE.

    PERFORM  BDC_REVERSE_ENTRIES1  USING  GS_100-RCEPNO
                                         S_940-BELNR
                                         S_940-BUKRS
                                         GS_ZQMT0016F-BUDAT.

    PERFORM UPDATE_ZQMT0016F USING S_940-CPERNR
                                   S_940-CPERNRT
                                   S_940-CNAM
                                   S_940-CNAMT..

    UPDATE ZQMT0016F SET DFLG  = 'X'
                         AEDAT = SY-DATUM
                         WOGBTR = '0'
                         CPERNR = S_940-CPERNR
                         CPERNRT = S_940-CPERNRT
                         CNAM = S_940-CNAM
                         CNAMT = S_940-CNAMT
                   WHERE BUKRS EQ S_940-BUKRS
                     AND BELNR EQ S_940-BELNR
                     AND GJAHR EQ S_940-GJAHR.

    IF SY-SUBRC EQ 0.
      COMMIT WORK.
    ENDIF.

    UPDATE ZFIT0066 SET BSTAT = 'Z' "삭제
                   WHERE BUKRS EQ S_940-BUKRS
                     AND BELNR EQ S_940-BELNR
                     AND GJAHR EQ S_940-GJAHR.

    IF SY-SUBRC EQ 0.
      COMMIT WORK.
    ENDIF.

    CLEAR: S_940-BELNR, GS_ZQMT0016F-BELNR.
    PERFORM FI_COST.
    PERFORM GET_BA_LIST .
    PERFORM REFRESH_GRID_930.

    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " EXE_940_REVERSE1
*&---------------------------------------------------------------------*
*&      Form  BDC_REVERSE_ENTRIES1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_100_RCEPNO  text
*      -->P_S_940_BELNR  text
*      -->P_S_940_BUKRS  text
*      -->P_GS_ZQMT0016F_BUDAT  text
*      <--P_S_940_RBELNR  text
*----------------------------------------------------------------------*
FORM BDC_REVERSE_ENTRIES1  USING    VALUE(P_RCEPNO)
                                 VALUE(P_BELNR)
                                 VALUE(P_BUKRS)
                                 VALUE(P_BUDAT).

  PERFORM STORE_BDCDATA USING  :
  'X'    'SAPMF05V'           '0100',
  ' '    'BDC_OKCODE'         '/00',
  ' '    'RF05V-BUKRS'        P_BUKRS,
  ' '    'RF05V-BELNR'        P_BELNR,
  ' '    'RF05V-GJAHR'        P_BUDAT+0(4),

  'X'    'SAPLF040'           '0700',
  ' '    'BDC_OKCODE'         '=BL',

  'X'    'SAPLSPO1'           '0200',
  ' '    'BDC_OKCODE'         '=YES'.

*  PERFORM BDC_TRANSACTION  USING     'FBV0'
*                                     'A'
*                           CHANGING  G_SUBRC.

  DATA: L_DIMODE  LIKE CTU_PARAMS-DISMODE VALUE 'E',  "A, E, N
        L_UPDATE  LIKE CTU_PARAMS-UPDMODE VALUE 'S'.  "S, A, L

  CALL TRANSACTION 'FBV0' USING GT_BDC
                            MODE   L_DIMODE
                            UPDATE L_UPDATE
                   MESSAGES INTO MESSTAB.



  IF SY-SUBRC EQ 0.
    MESSAGE S004 WITH '임시전표' P_BELNR '는 삭제되었습니다.' .
  ENDIF.

ENDFORM.                    " BDC_REVERSE_ENTRIES1
*&---------------------------------------------------------------------*
*&      Form  UPDATE_BA1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZQMS301_BUKRS  text
*      -->P_LV_BELNR  text
*      -->P_ZQMS301_BUDAT+0(4)  text
*      -->P_ZQMS301_CPERNR  text
*      -->P_ZQMS301_CPERNRT  text
*      -->P_ZQMS301_CNAM  text
*      -->P_ZQMS301_CNAMT  text
*----------------------------------------------------------------------*
FORM UPDATE_BA1 USING VALUE(P_BUKRS)
                     VALUE(P_BELNR)
                     VALUE(P_GJAHR)
                     VALUE(P_CPERNR)
                     VALUE(P_CPERNRT)
                     VALUE(P_CNAM)
                     VALUE(P_CNAMT).
* local variable
  DATA: LV_PAOBJNR LIKE BSEG-PAOBJNR,
        LV_PASUBNR LIKE BSEG-PASUBNR,
        LV_TNAME(15),
        LV_INDEX TYPE SY-TABIX.

*--{기능개선_43380 - 추가
  DATA : LV_WAERS LIKE BKPF-WAERS,
         LV_KURSF LIKE BKPF-KURSF.
*--}기능개선_43880
  CLEAR: GS_BADATA, GT_BADATA.


  SELECT BUKRS BELNR GJAHR BUZEI KOART SHKZG
         GSBER SGTXT KOSTL
         INTO CORRESPONDING FIELDS OF TABLE GT_BADATA
         FROM VBSEGS
        WHERE BUKRS EQ P_BUKRS
          AND BELNR EQ P_BELNR
          AND GJAHR EQ P_GJAHR
          AND KOART EQ 'S'
          AND BZKEY EQ '1'. "기능개선_49298 추가

* 공사 재작업비 인경우
  IF SY-SUBRC <> 0 AND G_BUKRS =  '6000'.
    PERFORM SELECT_GONSA_REWORK.
  ELSE.
* 일반 전표인 경우
    LOOP AT GT_BADATA INTO GS_BADATA.
      LV_INDEX = SY-TABIX.
      GS_BADATA-HKONT = ZQMS301-NEWKO1.

*   고객계정
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = ZQMS301-NEWKO2
        IMPORTING
          OUTPUT = ZQMS301-NEWKO2.

      GS_BADATA-LIFNR = ZQMS301-NEWKO2.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = GS_BADATA-LIFNR
        IMPORTING
          OUTPUT = GS_BADATA-LIFNR.

      SELECT SINGLE NAME1
               INTO GS_BADATA-LIFNRT
               FROM LFA1
              WHERE LIFNR EQ GS_BADATA-LIFNR.

      SELECT SINGLE WAERS
               INTO GS_BADATA-WAERS
               FROM T001
              WHERE BUKRS EQ GS_BADATA-BUKRS.

      SELECT SINGLE BLART BKTXT BUDAT CPUDT AEDAT
               INTO (GS_BADATA-BLART, GS_BADATA-BKTXT, GS_BADATA-BUDAT,
                     GS_BADATA-ERDAT, GS_BADATA-AEDAT)
               FROM BKPF
              WHERE BUKRS EQ GS_BADATA-BUKRS
                AND BELNR EQ GS_BADATA-BELNR
                AND GJAHR EQ GS_BADATA-GJAHR.

      GS_BADATA-RCEPNO = GS_100-RCEPNO.
      GS_BADATA-CPERNR = P_CPERNR.
      IF P_CPERNRT IS INITIAL.
        PERFORM GET_USRID USING P_CPERNR
                       CHANGING P_CPERNRT
                                P_CNAM
                                P_CNAMT.
      ENDIF.

      GS_BADATA-CPERNRT = P_CPERNRT.
      GS_BADATA-CNAM    = P_CNAM.
      GS_BADATA-CNAMT   = P_CNAMT.

*   코스트센터
      SELECT SINGLE PAOBJNR  PASUBNR
               INTO (LV_PAOBJNR, LV_PASUBNR)
               FROM VBSEGS
              WHERE BUKRS EQ GS_BADATA-BUKRS
                AND BELNR EQ GS_BADATA-BELNR
                AND BUZEI EQ GS_BADATA-BUZEI
                AND GJAHR EQ GS_BADATA-GJAHR.

      CONCATENATE 'CE4' GS_BADATA-BUKRS '_ACCT' INTO LV_TNAME.

      SELECT SINGLE COPA_KOSTL
               INTO GS_BADATA-KOSTL
               FROM (LV_TNAME)
              WHERE AKTBO   EQ 'X'
                AND PAOBJNR EQ LV_PAOBJNR
                AND PASUBNR EQ LV_PASUBNR.

*   품질비용 코드
      SELECT SINGLE QCODE1 INTO GS_BADATA-QCODE1
               FROM ZQMT0017
              WHERE BUKRS EQ GS_BADATA-BUKRS
                AND GJAHR EQ GS_BADATA-GJAHR
                AND HKONT EQ GS_BADATA-HKONT.

      SELECT SINGLE QCODE_TXT INTO GS_BADATA-QCODE_TXT
               FROM ZQMT0700
              WHERE KOKRS  EQ GS_BADATA-BUKRS
                AND QCODE1 EQ GS_BADATA-QCODE1.

*   ZFIT0066 공급가액

      SELECT SINGLE ZZWRBTR
               FROM ZFIT0066
               INTO GS_BADATA-WOGBTR
              WHERE BUKRS = GS_BADATA-BUKRS
                AND BELNR = GS_BADATA-BELNR
                AND GJAHR = GS_BADATA-GJAHR.

*--{기능개선_43380 - 추가
      SELECT SINGLE WAERS KURSF
               FROM BKPF
               INTO (LV_WAERS, LV_KURSF)
              WHERE BUKRS = GS_BADATA-BUKRS
                AND BELNR = GS_BADATA-BELNR
                AND GJAHR = GS_BADATA-GJAHR.

      IF LV_WAERS <> 'KRW'.
        IF LV_WAERS = 'AED' OR LV_WAERS = 'AUD' OR LV_WAERS = 'CNY' OR
           LV_WAERS = 'EUR' OR LV_WAERS = 'GBP' OR LV_WAERS = 'HKD' OR
           LV_WAERS = 'NZD' OR LV_WAERS = 'USD' OR LV_WAERS = 'SAR'
*{[기능개선 CHM2101-00026 ] /100에 엔화 추가
           OR LV_WAERS = 'JPY'
*}[기능개선 CHM2101-00026] 2021.01.06 kmj A.C
*{[기능개선 CHM2110-00697 ] /100에 인도루피(INR)추가
           OR LV_WAERS = 'INR'
*}[기능개선 CHM2110-00697] 2021.01.29 kmj A.C
           OR LV_WAERS = 'NOK'."SRM2504-12993 노르웨이 NOK 추가

"SRM2504-12993 기능개선_96425
          GS_BADATA-WOGBTR = GS_BADATA-WOGBTR * LV_KURSF / 100.
        ELSE.
          GS_BADATA-WOGBTR = GS_BADATA-WOGBTR * LV_KURSF.

        ENDIF.
*        GS_BADATA-WOGBTR = GS_BADATA-WOGBTR * LV_KURSF.
      ENDIF.
*--}기능개선_43880

      MODIFY GT_BADATA FROM GS_BADATA INDEX LV_INDEX.
      CLEAR: GS_BADATA.
    ENDLOOP.

  ENDIF.


  MODIFY ZQMT0016F FROM TABLE GT_BADATA.
  IF SY-SUBRC EQ 0.
    MESSAGE S004 WITH '임시전표' P_BELNR '를 정상적으로 저장하였습니다.'.
  ELSE.
    G_ERROR_FLG = 'X'.
  ENDIF.

ENDFORM.                    " UPDATE_BA1


*&---------------------------------------------------------------------*
*&      Form  UPDATE_ZQMT0016F
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_S_940_CPERNR  text
*      -->P_S_940_CPERNRT  text
*      -->P_S_940_CNAM  text
*      -->P_S_940_CNAMT  text
*----------------------------------------------------------------------*
FORM UPDATE_ZQMT0016F  USING VALUE(P_CPERNR)
                              VALUE(P_CPERNRT)
                              VALUE(P_CNAM)
                              VALUE(P_CNAMT).

  IF P_CPERNRT IS INITIAL.
    PERFORM GET_USRID USING P_CPERNR
                   CHANGING P_CPERNRT
                            P_CNAM
                            P_CNAMT.
  ENDIF.

ENDFORM.                    " UPDATE_ZQMT0016F
*&---------------------------------------------------------------------*
*&      Form  UPDATE_ZFIT0066
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_ZFIT0066 .








ENDFORM.                    " UPDATE_ZFIT0066
*&---------------------------------------------------------------------*
*&      Form  CHECK_WERKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_100_WERKS_H  text
*----------------------------------------------------------------------*
FORM CHECK_WERKS  USING    P_WERKS.

  DATA : LV_BUKRS TYPE T001-BUKRS.

*->[가온전선]--------------------CHG S
  SELECT SINGLE B~BUKRS
    FROM T001W AS A INNER JOIN T001K AS B
                    ON A~BWKEY = B~BWKEY
   WHERE A~WERKS EQ @P_WERKS
     AND B~BUKRS EQ @G_BUKRS
    INTO @LV_BUKRS.
  IF SY-SUBRC NE 0.
    MESSAGE E003 WITH TEXT-M01.
  ENDIF.
*-<[가온전선]--------------------CHG E

*  GET PARAMETER ID 'BUK' FIELD LV_BUKRS.
*
*  IF LV_BUKRS = '6000'.
*
*    IF P_WERKS+0(1) = '3'.
*      MESSAGE E003 WITH 'LS전선 플랜트만 선택하세요'.
*    ENDIF.
*
*  ELSEIF LV_BUKRS = '3000'.
*
*    IF P_WERKS+0(1) = '1'.
*      MESSAGE E003 WITH 'LS엠트론 플랜트만 선택하세요'.
*    ENDIF.
*
*  ENDIF.
ENDFORM.                    " CHECK_WERKS
*&---------------------------------------------------------------------*
*&      Form  GET_GT_110_COPY_MNG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_GT_110_COPY_MNG .

  CLEAR: GT_110.
  LOOP AT GT_110.

    GT_110-AENAM = SY-UNAME.
    GT_110-AEDAT = SY-DATUM.
    GT_110-AEZET = SY-UZEIT.
    GT_110-RKMNG = GT_110-GELIM.

    MODIFY GT_110  TRANSPORTING AENAM AEDAT AEZET RKMNG
                   WHERE RCEPNO  EQ GT_110-RCEPNO    "접수번호
                     AND ZMATSEQ EQ GT_110-ZMATSEQ   "자재Seq
                     AND ZCHASEQ EQ GT_110-ZCHASEQ.  "배치Seq
    MODIFY GT_110A FROM GT_110
                   TRANSPORTING AENAM AEDAT AEZET RKMNG
                   WHERE RCEPNO  EQ GT_110-RCEPNO    "접수번호
                     AND ZMATSEQ EQ GT_110-ZMATSEQ   "자재Seq
                     AND ZCHASEQ EQ GT_110-ZCHASEQ.  "배치Seq
    CLEAR: GT_110.
  ENDLOOP.

* 불만수량 재계산
  PERFORM SET_CHARGE_COUNT.

ENDFORM.                    " GET_GT_110_COPY_MNG
*&---------------------------------------------------------------------*
*&      Form  GET_GT_110_COPY_CANC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_GT_110_COPY_CANC .

  CLEAR: GT_110.
  LOOP AT GT_110.

    GT_110-AENAM = SY-UNAME.
    GT_110-AEDAT = SY-DATUM.
    GT_110-AEZET = SY-UZEIT.
    GT_110-RKMNG = ' '.

    MODIFY GT_110  TRANSPORTING AENAM AEDAT AEZET RKMNG
                   WHERE RCEPNO  EQ GT_110-RCEPNO    "접수번호
                     AND ZMATSEQ EQ GT_110-ZMATSEQ   "자재Seq
                     AND ZCHASEQ EQ GT_110-ZCHASEQ.  "배치Seq
    MODIFY GT_110A FROM GT_110
                   TRANSPORTING AENAM AEDAT AEZET RKMNG
                   WHERE RCEPNO  EQ GT_110-RCEPNO    "접수번호
                     AND ZMATSEQ EQ GT_110-ZMATSEQ   "자재Seq
                     AND ZCHASEQ EQ GT_110-ZCHASEQ.  "배치Seq
    CLEAR: GT_110.
  ENDLOOP.

* 불만수량 재계산
  PERFORM SET_CHARGE_COUNT.
ENDFORM.                    " GET_GT_110_COPY_CANC
