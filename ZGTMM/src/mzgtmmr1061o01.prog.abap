*&---------------------------------------------------------------------*
*&  Include           MZNF0020O01                                      *
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

  IF znft0002-inmon IS INITIAL.
    znft0002-inmon = sy-datum.
  ENDIF.

  IF hrvcost-mode = ' '.
    hrvcost-mode = 'E'.
  ENDIF.

  gv_cu1_o_cash_waers = 'USD'.
  gv_cu3_o_cash_waers = 'KRW'.
  gv_al1_o_cash_waers = 'USD'.
  gv_al2_o_cash_waers = 'KRW'.
  gv_pb1_o_cash_waers = 'USD'.
  gv_sn1_o_cash_waers = 'USD'.
  gv_ni1_o_cash_waers = 'USD'.
  gv_pe1_o_cash_waers = 'USD'.

*일부 필드 숨김
  LOOP AT SCREEN.

    IF SCREEN-GROUP1 = 'NA'.
      SCREEN-ACTIVE = '0'.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.


ENDMODULE.                 " init_set  OUTPUT
