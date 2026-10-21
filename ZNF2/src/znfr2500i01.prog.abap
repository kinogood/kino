*&---------------------------------------------------------------------*
*&  Include           ZNFR2500I01
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

  CLEAR : GV_CODE, GV_ERROR.
  GV_CODE = OK_CODE.
  CLEAR : OK_CODE.

  CASE GV_CODE.
    WHEN 'INSERT'.
      PERFORM DATA_ADD_ROW.
    WHEN 'SAVE'.
      PERFORM DATA_CHECK USING GV_ERROR.
      CHECK GV_ERROR NE 'X'.
      PERFORM POPUP_TO_CONFIRM USING '확인'
                                     '저장하시겠습니까?'
                                     '1'
                                     GV_ANSWER.
      CHECK GV_ANSWER EQ 1.
      PERFORM DATA_SAVE_ZNFT1090 USING GV_ERROR.
      IF GV_ERROR NE 'X'.
        PERFORM DATA_SELECT_ZNFT1090.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1100  INPUT
