*&---------------------------------------------------------------------*
*& Include          ZGTSDR1260I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
MODULE exit_0100 INPUT.

**
  gv_save_cd = gv_okcode.
  CLEAR: gv_okcode.

  CASE gv_save_cd.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
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
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.

    WHEN 'ALL' OR 'DALL'.
      PERFORM select_deselect_all   USING  gv_save_cd.

    WHEN 'UPLOAD'.    " 영업뷰 업로드
      PERFORM update_bp_sales_view  USING  gv_save_cd.

  ENDCASE.

ENDMODULE.
