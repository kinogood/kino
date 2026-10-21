*&---------------------------------------------------------------------*
*& Include          ZGTPPI4090I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  PERFORM user_command_exit.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_100 INPUT.

  CASE gv_okcode.
    WHEN gc_fcode-back OR gc_fcode-exit.    "// Back, Exit.
      PERFORM user_command_exit.

    WHEN gc_fcode-send OR gc_fcode-resend.  "// 전송 or 재전송.
      PERFORM user_command_send.

    WHEN gc_fcode-detail.                   "// 상세조회.
      PERFORM user_command_detail.
  ENDCASE.

  CLEAR gv_okcode.

ENDMODULE.
