*&---------------------------------------------------------------------*
*& Include          ZGTPPR2060I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CLEAR gv_ok_code.
  gv_ok_code = sy-ucomm.

  CASE gv_ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF gv_chk_edit IS NOT INITIAL.
        CLEAR gv_answer.
        PERFORM popup_to_confirm_step USING 'N'
          ' '
          '수정중인 작업이 있습니다. 종료 하시겠습니까?'
          '종료확인'.
        IF gv_answer NE 'J'.
          MESSAGE s003 DISPLAY LIKE 'E' WITH '종료 취소 되었습니다.'.
          RETURN.
        ENDIF.
      ENDIF.

*     종료
      CALL METHOD go_docking_0100->free.

      FREE : go_docking_0100, go_splitter_0100.
      FREE : go_contain_0100, go_contain_0200, go_contain_top_0100.
      FREE : go_grid_0100, go_grid_0200.
      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.
  ENDCASE.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  CLEAR gv_ok_code3.
  gv_ok_code3 = sy-ucomm.

  CASE gv_ok_code3.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      CALL METHOD go_docking_0300->free.

      FREE : go_docking_0300, go_grid_0300.
      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      PERFORM delete_dp.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*& 2026.01.30.zlsgpp5.create. CHM2601-00657
*----------------------------------------------------------------------*
MODULE user_command_0400 INPUT.

  CLEAR gv_ok_code4.
  gv_ok_code4 = sy-ucomm.

  CASE gv_ok_code4.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      "2026.01.26.zlsgpp5.반환할 itab 데이터 없애기.
      CLEAR: gt_main_400[].

*     종료
      CALL METHOD go_docking_0400->free.

      FREE : go_docking_0400, go_grid_0400.
      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.

    WHEN 'CONFIRM'.
      PERFORM confirm_screen_400.

  ENDCASE.

ENDMODULE.
