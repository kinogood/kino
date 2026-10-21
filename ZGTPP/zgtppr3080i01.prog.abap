*&---------------------------------------------------------------------*
*& Include          ZGTPPR3080I01
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

  CASE gv_okcode.
    WHEN 'REFRESH'.         " Refresh 수행
*-- 조회조건 기준 Select 수행
      PERFORM select_main_data          CHANGING gv_eflg.

      PERFORM clear_alv_info.
  ENDCASE.

ENDMODULE.
