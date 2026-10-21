*&---------------------------------------------------------------------*
*& Include          ZGTMMR1070F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form F_START_OF_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_START_OF_SELECTION .

* DATA SELECT
  PERFORM F_GET_DATA_USER.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GET_DATA_USER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DATA_USER .

  CLEAR: GT_USER[].

  SELECT
    Z1~BUKRS,
    T1~BUTXT,
    Z1~WERKS,
    TW~NAME1,
    Z1~APPUSER,
    Z1~BNAME,
    PA~ENAME,
    Z1~ERDAT,
    Z1~ERTIM,
    Z1~ERNAM,
    Z1~AEDAT,
    Z1~AETIM,
    Z1~AENAM

    FROM ZGTMMT1022 AS Z1
    LEFT OUTER JOIN T001 AS T1 ON Z1~BUKRS EQ T1~BUKRS
    LEFT OUTER JOIN T001W AS TW ON Z1~WERKS EQ TW~WERKS
    LEFT OUTER JOIN ZZPA0001 AS PA ON Z1~APPUSER EQ PA~PERNR
    WHERE Z1~BUKRS EQ @P_BUKRS
    AND Z1~WERKS EQ @P_WERKS
*    AND Z1~APPUSER IN @S_APPU
    AND PA~ENDDA EQ '99991231'
    INTO CORRESPONDING FIELDS OF TABLE @GT_USER.


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

  CALL SCREEN 100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_MAKE_DATA_USER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_USER>
*&---------------------------------------------------------------------*
FORM F_MAKE_DATA_USER  CHANGING PS_USER TYPE TY_USER.

  " 회사명
  SELECT SINGLE BUTXT
    FROM T001
    WHERE BUKRS EQ @PS_USER-BUKRS
    INTO @DATA(LV_BUTXT).

  " 플랜트명
  SELECT SINGLE NAME1
    FROM T001W
    WHERE WERKS EQ @PS_USER-WERKS
    INTO @DATA(LV_NAME1).

  PS_USER-BUTXT = LV_BUTXT.
  PS_USER-NAME1 = LV_NAME1.

ENDFORM.
