*&---------------------------------------------------------------------*
*&  Include           ZLER0012BI01                                     *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai INPUT.

*  PERFORM selected_rows .

  CASE save_ok.
    WHEN 'BACK' OR 'RW'.
*  빠뜨리면 S_AUART 에 RM01 빠진채로 INIT됨
*         free memory.
      SET SCREEN 0.
    WHEN '%EX'.           LEAVE PROGRAM.

    WHEN 'CHK'.
      PERFORM mark_chk_tknum.

    WHEN 'PREVIEW'.   "미리보기
      CLEAR: gv_print.
      PERFORM preview.

    WHEN 'PRINT'.     "발행
      PERFORM pop_up_confirm(zler0004)
           USING '< 거래명세서 발행여부확인 >'
                 '발행하시겠습니까?'
         CHANGING lv_return.
      CHECK lv_return = 'J'.
      CLEAR lv_return.

      gv_print = 'X'.
      PERFORM iv_print.

    WHEN 'REVERSE'.   "거래명세서 취소
      PERFORM cancel_iv.

    WHEN 'ASEL'.
      PERFORM all_select USING 'A'.

    WHEN 'DSEL'.
      PERFORM all_select USING 'D'.

    WHEN 'ASORT' OR 'DSORT'.
      PERFORM sort .

    WHEN 'REFR'.
      PERFORM selection .

*___미부착부품 리스트 관리 - Start 2006.06.13
    WHEN 'ACSR'.
      PERFORM call_zler0600.
*___미부착부품 리스트 관리 - End   2006.06.13
  ENDCASE.

ENDMODULE.                 " PAI  INPUT

*&---------------------------------------------------------------------*
*&      Module  SAVE_OK_CODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE save_ok_code INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
ENDMODULE.                 " SAVE_OK_CODE  INPUT
