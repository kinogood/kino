*&---------------------------------------------------------------------*
*& Include          ZGTPPR4090I01
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

    WHEN gc_fcode-save.                  "// 계근 실적 저장.
      PERFORM user_command_save.

    WHEN gc_fcode-delete.                "// 계근 실적 취소.
      PERFORM user_command_delete.

    WHEN gc_fcode-display.               "// 전체 조회.
      PERFORM user_command_display.

    WHEN gc_fcode-detail.                "// 계근 상세 실적.
      PERFORM user_command_detail.

    WHEN gc_fcode-disp_scrat.            "// 환산율 조회.
      PERFORM user_command_disp_scrat	.

    WHEN gc_fcode-fixed_col.             "// 고정 컬럼 설정.
      PERFORM user_command_fixed_col.
  ENDCASE.

  CLEAR gv_okcode.

ENDMODULE.
