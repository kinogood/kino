*&---------------------------------------------------------------------*
*&  Include           MZNF0010O01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  status_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS '0100'.
  SET TITLEBAR  '0100'.

ENDMODULE.                 " status_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  init_set  OUTPUT
*&---------------------------------------------------------------------*
MODULE init_set OUTPUT.

  DATA: lt_return   LIKE casdayattr OCCURS 0 WITH HEADER LINE,
        lt_znft0001 LIKE znft0001 OCCURS 0 WITH HEADER LINE.

  CLEAR : lt_return.
  REFRESH : lt_return.

  lt_znft0001-indat = sy-datum.

  IF znft0001-indat IS INITIAL.

*.. 휴일을 제외한 날짜로 지정하는 Function 코드
*   한달을 기준으로 하므로 최대 30번을 시행하도록 한다
    DO 30 TIMES.
      lt_znft0001-indat = lt_znft0001-indat - 1.

      CALL FUNCTION 'DAY_ATTRIBUTES_GET'
        EXPORTING
          factory_calendar = 'L3'
          holiday_calendar = 'LS'
          date_from        = lt_znft0001-indat
          date_to          = lt_znft0001-indat
          language         = sy-langu
        TABLES
          day_attributes   = lt_return
*     EXCEPTIONS
*         factory_calendar_not_found       = 1
*         holiday_calendar_not_found       = 2
*         date_has_invalid_format          = 3
*         date_inconsistency               = 4
*         OTHERS           = 5
        .
      READ TABLE lt_return INDEX 1.
      IF lt_return-holiday NE 'X'.              "휴일이 아닐경우 날짜를 보여주고 구문 나감
        znft0001-indat = lt_znft0001-indat.
        EXIT.
      ENDIF.
    ENDDO.
  ENDIF.

  IF hrvcost-mode = ' '.
    hrvcost-mode = 'E'.
  ENDIF.

  gv_cu1_o_cash_waers = 'USD'.
  gv_cu1_c_cash_waers = 'USD'.
  gv_cu1_c_3m_waers   = 'USD'.
  gv_cu1_spread_waers = 'USD'.
  gv_cu1_meins        = 'TON'.
  gv_cu1_c_6m_waers   = 'USD'.

  gv_cu2_c_cash_waers = 'USD'.
  gv_cu3_c_cash_waers = 'USD'.
  gv_cu2_meins        = 'TON'.

  IF gv_cu2_shfe_logic1 = 0.
    gv_cu2_shfe_logic1  = '1.2'.
  ENDIF.

  IF gv_cu2_shfe_logic2 = 0.
    gv_cu2_shfe_logic2  = '8.00'.
  ENDIF.

  gv_al1_o_cash_waers = 'USD'.
  gv_al1_c_cash_waers = 'USD'.
  gv_al1_c_3m_waers   = 'USD'.
  gv_al1_spread_waers = 'USD'.
  gv_al1_meins        = 'TON'.
  gv_al1_c_6m_waers   = 'USD'.

  gv_pb1_o_cash_waers = 'USD'.
  gv_pb1_c_cash_waers = 'USD'.
  gv_pb1_c_3m_waers   = 'USD'.
  gv_pb1_spread_waers = 'USD'.
  gv_pb1_meins        = 'TON'.
  gv_pb1_c_6m_waers   = 'USD'.

  gv_ni1_o_cash_waers = 'USD'.
  gv_ni1_c_cash_waers = 'USD'.
  gv_ni1_c_3m_waers   = 'USD'.
  gv_ni1_spread_waers = 'USD'.

  gv_sn1_o_cash_waers = 'USD'.
  gv_sn1_c_cash_waers = 'USD'.

  gv_pe1_o_cash_waers = 'USD'.
  gv_pe1_c_cash_waers = 'USD'.

*일부 필드 숨김
  LOOP AT SCREEN.

    IF screen-group1 = 'NA'.
      screen-active = '0'.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " init_set  OUTPUT
