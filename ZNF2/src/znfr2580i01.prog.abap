*&---------------------------------------------------------------------*
*&  Include           ZNFR2580I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CASE SY-UCOMM..
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1100 INPUT.

  CLEAR : GV_CODE.
  GV_CODE = OK_CODE.
  CLEAR : OK_CODE.

  PERFORM GET_SELECTED_COLS.

  CASE GV_CODE.
    WHEN 'OKAY'.
      PERFORM DATA_CHECK_SELECTED USING GV_ERROR.
      CHECK GV_ERROR IS INITIAL.
      PERFORM POPUP_TO_CONFIRM USING '확인'
                                     '데이터를 최종확인하시겠습니까?'
                                     '1'
                                     GV_ANSWER.
      IF GV_ANSWER = '1'.
        PERFORM DATA_OKAY.
        PERFORM DATA_RELOAD.
      ELSE.
        MESSAGE S007.
      ENDIF.

    WHEN 'ASEL' OR 'DSEL'.
      PERFORM SELECT_ALL.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1100  INPUT
