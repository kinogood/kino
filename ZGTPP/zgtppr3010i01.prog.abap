*&---------------------------------------------------------------------*
*& Include          ZGTPPR3010I01
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
    WHEN 'RESTORE'. "백로그 삭제 취소
      PERFORM restore_backlog_data.
    WHEN 'REFRESH'. "REFRESH
* 데이터 갱신
      PERFORM get_data.
* REFRESH DISPLAY
      CALL METHOD go_grid_0100->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'
          is_stable      = gv_stable.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE gv_ok_code3.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CALL METHOD go_contain_0200->free.
      FREE : go_contain_0200, go_grid_0200.
      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_200  INPUT
*&---------------------------------------------------------------------*
MODULE exit_command_200 INPUT.

  CASE gv_ok_code3.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CALL METHOD go_contain_0200->free.
      FREE : go_contain_0200, go_grid_0200.
      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
