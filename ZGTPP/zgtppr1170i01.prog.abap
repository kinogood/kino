*&---------------------------------------------------------------------*
*&  Include           ZGTPPR1170I01                                    *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  exit_0100  INPUT
*&---------------------------------------------------------------------*
MODULE exit_0100 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " exit_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  exit_0200  INPUT
*&---------------------------------------------------------------------*
MODULE exit_0200 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " exit_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE ok_code.
    WHEN 'TEST'.
      gw_bdcparams-dismode = 'A'.
  ENDCASE.
ENDMODULE.                 " user_command_0200  INPUT
