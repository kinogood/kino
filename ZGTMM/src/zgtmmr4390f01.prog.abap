*&---------------------------------------------------------------------*
*& Include          ZGTMMR4390F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH .

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'BUKRS' FIELD P_BUKRS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E172 WITH P_BUKRS. "회사코드[&] 작업권한을 확인하세요.

  IF S_WERKS[] IS NOT INITIAL.
      LOOP AT S_WERKS INTO DATA(LS_WERKS).
        AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                     ID 'WERKS' FIELD LS_WERKS-LOW.

        CHECK SY-SUBRC <> 0.

        SET CURSOR FIELD 'S_WERKS-LOW'.
        MESSAGE E106 WITH S_WERKS-LOW. "플랜트 [&] 작업권한을 확인하세요.
      ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_START_OF_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_START_OF_SELECTION .

  "재고 데이터 조회
  PERFORM F_GET_STOCK_LIST.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_END_OF_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_END_OF_SELECTION .

  "데이터가 없으면 메세지 처리
  IF GT_LIST[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CALL SCREEN 100.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_STOCK_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_STOCK_LIST .

  "초기화
  CLEAR GT_LIST[].

  SELECT
    V1~MATNR,
    MT~MAKTX,
    V1~WERKS,
    TW~NAME1,
    V1~LGORT,
    TL~LGOBE,
    V1~CHARG,
    V1~SOBKZ,
    V1~LIFNR,
    LF~NAME1 AS LIFNR_TEXT,
    V1~PSPNR,
    PS~POST1,
    V1~KUNNR,
    KN~NAME1 AS KUNNR_TEXT,
    V1~VBELN,
    V1~POSNR,
    V1~VBELN_OR,
    V1~POSNR_OR,
    V1~MEINS,
    V1~LABST,
    V1~INSME,
    V1~SPEME,
    CASE WHEN V1~LGORT = @GC_LGORT THEN MC~LIFNR
              ELSE '---'  END AS B_LIFNR,
    CASE WHEN V1~LGORT = @GC_LGORT THEN BP~NAME1
              ELSE '---'  END AS B_LIFNR_TEXT
    FROM ZGTMM_CV_GET_STOCKLIST AS V1
                  INNER JOIN
              T001W AS TW ON V1~WERKS EQ TW~WERKS
                  INNER JOIN
              T001K AS TK ON TW~BWKEY EQ TK~BWKEY
                  LEFT OUTER JOIN
              MAKT AS MT ON V1~MATNR EQ MT~MATNR
                                AND MT~SPRAS EQ @SY-LANGU
                  LEFT OUTER JOIN
              T001L AS TL ON V1~WERKS EQ TL~WERKS
                               AND V1~LGORT EQ TL~LGORT
                  LEFT OUTER JOIN
              LFA1 AS LF ON V1~LIFNR EQ LF~LIFNR
                  LEFT OUTER JOIN
              KNA1 AS KN ON V1~KUNNR EQ KN~KUNNR
                  LEFT OUTER JOIN
              PRPS AS PS ON V1~PSPNR EQ PS~PSPNR
                  LEFT OUTER JOIN
              MCH1 AS MC ON V1~MATNR  EQ MC~MATNR
                                AND V1~CHARG EQ MC~CHARG
              LEFT OUTER JOIN
              LFA1 AS BP ON MC~LIFNR  EQ BP~LIFNR
    WHERE TK~BUKRS EQ @P_BUKRS
    AND V1~WERKS IN @S_WERKS
    AND V1~LGORT IN @S_LGORT
    AND V1~MATNR IN @S_MATNR
    AND V1~CHARG IN @S_CHARG
    AND V1~SOBKZ IN @S_SOBKZ
    AND V1~LIFNR IN @S_LIFNR
    AND V1~KUNNR IN @S_KUNNR
    AND V1~PSPNR IN @S_PSPNR
    AND V1~VBELN IN @S_VBELN
    ORDER BY V1~MATNR, V1~WERKS, V1~LGORT, V1~CHARG
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_REFRESH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_REFRESH .

  "재고 데이터 조회
  PERFORM F_GET_STOCK_LIST.

ENDFORM.
