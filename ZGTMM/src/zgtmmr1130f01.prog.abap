*&---------------------------------------------------------------------*
*& Include          ZGTMMR4390F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM INITIALIZATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

"수신일
  IF S_DATE[] IS INITIAL.
    S_DATE[] = VALUE #( ( SIGN = 'I' OPTION = 'BT' LOW = SY-DATLO - 30  HIGH = SY-DATLO ) ).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH .

*  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
*               ID 'BUKRS' FIELD P_BUKRS.
*
*  CHECK SY-SUBRC <> 0.
*
*  SET CURSOR FIELD 'P_BUKRS'.
*  MESSAGE E172 WITH P_BUKRS. "회사코드[&] 작업권한을 확인하세요.

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

  "단가데이터 조회
  PERFORM F_GET_PRICE_LIST .

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
*& Form F_GET_PRICE_LIST .
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_PRICE_LIST .

  DATA : LV_MAT18 TYPE MATNR18.
  "초기화
  CLEAR GT_LIST[].

  SELECT
    V1~*,
*    MT~MATNR AS MT_MATNR,
*    MT~MAKTX AS MAKTX,
    TW~NAME1,
    LF~NAME1 AS LIFNR_T

    FROM ZGTMMT1040 AS V1
                  INNER JOIN
              T001W AS TW ON V1~WERKS EQ TW~WERKS
*                  LEFT OUTER JOIN
*              MAKT AS MT ON V1~MATNR EQ MT~MATNR
*                                AND MT~SPRAS EQ @SY-LANGU
                  LEFT OUTER JOIN
              LFA1 AS LF ON V1~LIFNR EQ LF~LIFNR

    WHERE  V1~WERKS IN @S_WERKS
    AND V1~CDATE IN @S_DATE
    AND V1~MATNR IN @S_MATNR
    AND V1~LIFNR IN @S_LIFNR
    ORDER BY V1~MATNR, V1~WERKS
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

*>S.2026.08.11_ZGTMMT1040-MATNR이 ALPHA OUT상태로 저장되어 자재내역을 못가져옴.
*ALPHA IN 한 형태로 변경하여 자재내역 가져오는 로직 추가. (위 조인에서는 주석..MAKT)
   CHECK GT_LIST[] IS NOT INITIAL.

   LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
*ZGTMMT1040
    CLEAR LV_MAT18.
    LV_MAT18 = |{ <LS_LIST>-MATNR  ALPHA = IN }|.
    <LS_LIST>-MATNR = LV_MAT18.

    SELECT SINGLE MAKTX
    FROM MAKT
    WHERE MATNR = @<LS_LIST>-MATNR
      AND SPRAS = @SY-LANGU
    INTO @<LS_LIST>-MAKTX.

  ENDLOOP.
*<E.2026.08.11_ZGODEV04

  SORT GT_LIST BY MATNR LIFNR .

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

  "단가 데이터 조회
  PERFORM F_GET_PRICE_LIST .

ENDFORM.
