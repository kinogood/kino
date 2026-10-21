*&---------------------------------------------------------------------*
*& Include          ZGTSDR0060I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*  Screen 0100 Exit User-Command 수행
*----------------------------------------------------------------------*
MODULE exit_command_0100 INPUT.

  CASE gv_okcode.
    WHEN 'BACK' OR 'CANC'.
      PERFORM clear_alv_info.

      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      PERFORM clear_alv_info.

      LEAVE PROGRAM.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*  Screen 0100 User-Command 수행
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CALL METHOD go_grid_head->check_changed_data.

  CASE gv_okcode.
    WHEN 'CRTE'.         " 시작업생산요청 생성
      PERFORM crte_quot_crte.

  ENDCASE.


ENDMODULE.
