*&---------------------------------------------------------------------*
*& Include          ZGTLER1140I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
MODULE exit_0100 INPUT.

**
  gv_save_cd = gv_okcode.
  CLEAR: gv_okcode.

  CASE gv_save_cd.
    WHEN 'BACK' OR '%EX' OR 'RW'.
      LEAVE TO SCREEN 0.

  ENDCASE.

**

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

**
  gv_save_cd = gv_okcode.
  CLEAR: gv_okcode.

  CLEAR: gv_error.
  CASE gv_save_cd.
*   통문확정
    WHEN 'COM'.
      PERFORM tong_moon_check.
      PERFORM tong_moon_confirm.

*   배차정보 입력
    WHEN 'DRIVER'.
      PERFORM import_driver_info .

*   출고지시 - 2026.07.28 Add
    WHEN 'GI'.
      PERFORM sunmit_gi_program.

*   통문취소
    WHEN 'CANC'.
      PERFORM tong_moon_check.
      PERFORM tong_moon_cancel.

*   Select Option
    WHEN 'ASEL' OR 'DSEL'.
      PERFORM all_de_select_chk   USING  gv_save_cd.

*   Refresh
    WHEN 'REFR'.
      PERFORM start_process .

  ENDCASE.

**

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_0300  INPUT
*&---------------------------------------------------------------------*
MODULE exit_0300 INPUT.

**
  gv_save_cd3 = gv_okcode3.
  CLEAR: gv_okcode3.

  CASE gv_save_cd3.
    WHEN 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

**

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

**
  gv_save_cd3 = gv_okcode3.
  CLEAR: gv_okcode3.

  CASE gv_save_cd3.
    WHEN 'BACK' OR 'CLOSE'.
      LEAVE TO SCREEN 0.

    WHEN 'SET'.    " 배차정보 입력
      PERFORM set_new_car_info  .

  ENDCASE.

**

ENDMODULE.
