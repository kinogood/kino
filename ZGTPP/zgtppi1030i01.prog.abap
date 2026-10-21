*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE exit_command INPUT.

  gv_ok_code2 = gv_ok_code.
  CLEAR: gv_ok_code.

  CASE gv_ok_code2.
    WHEN 'BACK' OR 'CANC'.
      PERFORM exit_program.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  gv_ok_code2 = gv_ok_code.
  CLEAR: gv_ok_code.

  CASE gv_ok_code2.
    WHEN 'SEND' OR "전송
            'RESEND'. "재처리
      PERFORM send_data.
    WHEN 'REFRESH'. "REFRESH
* 데이터 갱신
      PERFORM get_data.
  ENDCASE.
* REFRESH DISPLAY
  CALL METHOD go_grid_0100->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = gv_stable.

ENDMODULE.
