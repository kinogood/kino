*&---------------------------------------------------------------------*
*&  Include           ZGTPPR1120I01                                      *
*&---------------------------------------------------------------------*
*&      Module  exit_0100  INPUT
*&---------------------------------------------------------------------*
MODULE exit_0100 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " exit_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  DATA: l_valid TYPE c.

  gv_okcode = ok_code.
  CLEAR: ok_code.
  CASE gv_okcode.
    WHEN 'TEST'.
      gw_bdcparams-dismode = 'A'.
  ENDCASE.

ENDMODULE.                 " user_command_0100  INPUT
