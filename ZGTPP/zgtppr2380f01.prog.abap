*&---------------------------------------------------------------------*
*& Include          ZGTPPR2380F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC .

  DATA : LV_TYPE TYPE ZO_RESULT.
  DATA : LV_MESSAGE TYPE ZO_MESSAGE.
  DATA : LV_STRING(100).

  IF S_MATNR[] IS INITIAL. " 전체삭제
    CALL FUNCTION 'ZGTPP_DRUM_NO_INIT'
      EXPORTING
        IV_GUBUN   = 'A'
      IMPORTING
        EV_TYPE    = LV_TYPE
        EV_MESSAGE = LV_MESSAGE.

    CASE LV_TYPE.
      WHEN '00'.
        WRITE : '성공 -', LV_MESSAGE.
      WHEN OTHERS.
        WRITE : '실패 -', LV_MESSAGE.
    ENDCASE.

  ELSE.
    SELECT * FROM ZGTPPT2500
      INTO TABLE @DATA(LT_2500)
     WHERE WERKS = @P_WERKS
       AND MATNR IN @S_MATNR.
    IF SY-SUBRC EQ 0.
      LOOP AT LT_2500 INTO DATA(LS_2500).
        CLEAR : LV_TYPE, LV_MESSAGE.

        CALL FUNCTION 'ZGTPP_DRUM_NO_INIT'
          EXPORTING
            IV_GUBUN   = 'S'
            IV_WERKS   = P_WERKS
            IV_MATNR   = LS_2500-MATNR
          IMPORTING
            EV_TYPE    = LV_TYPE
            EV_MESSAGE = LV_MESSAGE.

        CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
          EXPORTING
            INPUT  = LS_2500-MATNR
          IMPORTING
            OUTPUT = LS_2500-MATNR.

        CLEAR LV_STRING.
        LV_STRING = | { P_WERKS } 플랜트 { LS_2500-MATNR }({ LS_2500-DRUM_NO }) - { LV_MESSAGE } |.
        WRITE : / LV_STRING.
      ENDLOOP.
    ELSE.
      MESSAGE S006 WITH '드럼넘버 초기화 대상 자재가 없습니다.'(m01).
      RETURN.
    ENDIF.

  ENDIF.

ENDFORM.
