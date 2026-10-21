*&---------------------------------------------------------------------*
*& Include          ZGTLER1150I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
MODULE exit_0100 INPUT.

**
  gv_save_cd = gv_okcode.
  CLEAR: gv_okcode.

  CASE gv_save_cd.
    WHEN 'EXIT' OR 'CANC'.
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

    WHEN 'REFRESH'.    " Refresh
      PERFORM data_refresh.

    WHEN 'PRINT' OR      " 발행.
         'PREVIEW'.      " 미리보기.
      PERFORM doc_print_exc               USING  gv_save_cd.

    WHEN 'REVERSE'.    " 출력취소
      PERFORM print_cancel_exc            USING  gv_save_cd.

    WHEN 'DOWN'.       " Picking List Download.
      PERFORM picking_list_download       USING  gv_save_cd.

  ENDCASE.

**

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_0200  INPUT
*&---------------------------------------------------------------------*
MODULE exit_0200 INPUT.

**
  gv_save_cd2 = gv_okcode2.
  CLEAR: gv_okcode2.

  CASE gv_save_cd2.
    WHEN 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

**

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

**
  gv_save_cd2 = gv_okcode2.
  CLEAR: gv_okcode2.

  CLEAR: gv_error.
  CASE gv_save_cd2.
    WHEN 'BACK' OR 'CANC2' OR 'EXIT2'.
      LEAVE TO SCREEN 0.

    WHEN 'CONFIRM'.
      PERFORM check_input_copies.
      IF gv_answer = 'J'.
        LEAVE TO SCREEN 0.
      ENDIF.

  ENDCASE.

**

ENDMODULE.
