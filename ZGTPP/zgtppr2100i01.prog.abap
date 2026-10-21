*&---------------------------------------------------------------------*
*& Include          ZGTPPR2100I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CLEAR gv_ok_code.
  gv_ok_code = sy-ucomm.

  CASE gv_ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      go_splitter_0100->free( ).
      CALL METHOD go_docking_0100->free.
      FREE : go_docking_0100, go_splitter_0100, go_dd_docu_0100,
             go_grid_0100.
      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
