*&---------------------------------------------------------------------*
*& Include          ZGTPPR4100I01
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
    WHEN gc_fcode-back OR gc_fcode-exit. "// Back, Exit.
      PERFORM user_command_exit.

    WHEN gc_fcode-post.                  "// 재고실사 차이 전기.
      PERFORM user_command_post.

    WHEN gc_fcode-scrap.                 "// 스크랩 처리.
      PERFORM user_command_scrap.

    WHEN gc_fcode-cncl_post.             "// 차이 전기 취소.
      PERFORM user_command_cncl_post.

    WHEN gc_fcode-CNCL_SCRAP.            "// 스크랩 처리 취소.
      PERFORM user_command_cncl_scrap.
  ENDCASE.

  CLEAR gv_okcode.

ENDMODULE.
