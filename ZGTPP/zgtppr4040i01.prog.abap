*&---------------------------------------------------------------------*
*& Include          ZGTPPR4040I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.

  CASE gv_ok_code.
    WHEN 'BACK' OR 'CANC'.
      CALL METHOD go_docking_container->free.
      CLEAR : go_docking_container, go_grid_0100, go_grid_0101.
      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_ok_code.
    WHEN 'REFRESH'.

      PERFORM popup_to_confirm_step USING 'N'
        ' '
        '실사 수량 데이터를 갱신합니다. Refresh 진행하시겠습니까?'(m01)
        '작업확인'(006).

      IF gv_answer = 'J'.

        PERFORM get_data.

        CLEAR : gs_disp2, gt_disp2.

        PERFORM refresh_display_all_alv.

      ELSE.

        MESSAGE s000 WITH 'Refresh 취소 되었습니다.'(m02).
        RETURN.

      ENDIF.

  ENDCASE.

ENDMODULE.
