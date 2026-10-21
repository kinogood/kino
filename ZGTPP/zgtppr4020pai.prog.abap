*----------------------------------------------------------------------*
***INCLUDE ZGTPPR4020PAI .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE  EXIT_0100 INPUT.

  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.

  CASE SAVE_OK.
    WHEN 'BACK'.
      CLEAR SAVE_OK.

      PERFORM INIT_CNTROLS_OBJECT.

      SET SCREEN 0.
      LEAVE SCREEN.

    WHEN 'EXIT' OR 'CANC'.
      CLEAR SAVE_OK.

      PERFORM INIT_CNTROLS_OBJECT.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.                 " EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  DATA: LV_ANSWER(1).

  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.

  CASE SAVE_OK.
    WHEN 'ZPOST'.   "재고실사차이 전기
      CLEAR: SAVE_OK, LV_ANSWER.
*-----POPUP
      PERFORM CALL_POPUP_FUNC USING TEXT-007
                                    TEXT-008
                                    ' '
                              CHANGING LV_ANSWER.
      IF LV_ANSWER = 'J'.
        PERFORM PHYSICAL_INVENTORY_POST.
      ENDIF.
    WHEN 'ZREVS'.   "전기 문서 취소
      CLEAR: SAVE_OK, LV_ANSWER.
*-----POPUP
      PERFORM CALL_POPUP_FUNC USING TEXT-009
                                    TEXT-010
                                    ' '
                              CHANGING LV_ANSWER.
      IF LV_ANSWER = 'J'.
        PERFORM REVERSE_POST.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
