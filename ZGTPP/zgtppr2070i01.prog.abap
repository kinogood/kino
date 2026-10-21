*&---------------------------------------------------------------------*
*& Include          ZGTPPR2070I01
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

    WHEN 'REGIST'. "설비 Capa. 등록

      PERFORM save_arbpl_capa.

      PERFORM refresh_grid USING go_grid_0100.

    WHEN 'SETCHECK'. "값이 변경되었을 시 체크를 위한 유저 커맨드

      PERFORM refresh_grid USING go_grid_0100.

    WHEN 'ZGTPPR2071'."설비 가동일 관리

      SUBMIT zgtppr2071 WITH p_werks EQ p_werks
                        WITH p_spgcd EQ p_spgcd
                        VIA SELECTION-SCREEN
                        AND RETURN.

    WHEN 'REFRESH'.

      PERFORM get_data.

      go_splitter_0100->free( ).
      CALL METHOD go_docking_0100->free.
      FREE : go_docking_0100, go_splitter_0100, go_dd_docu_0100,
             go_grid_0100.
      CALL METHOD cl_gui_cfw=>flush.

  ENDCASE.

ENDMODULE.
