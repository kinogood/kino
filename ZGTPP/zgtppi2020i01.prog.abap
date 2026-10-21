*&---------------------------------------------------------------------*
*& Include          ZGTPPI2020I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CALL METHOD go_contain_0100->free.
      CLEAR : go_contain_0100, go_grid_0100.
      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.
    WHEN 'REFRESH'.
      PERFORM get_proc.
      PERFORM refresh_grid USING go_grid_0100.
    WHEN 'EXEC' OR 'REDO'.
      PERFORM send_data.
  ENDCASE.

ENDMODULE.
