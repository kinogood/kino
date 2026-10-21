*&---------------------------------------------------------------------*
*&  Include           ZNFR2250I01
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

  CLEAR : OK_SAVE, GV_ERROR.
  OK_SAVE = OK_CODE.
  CLEAR : OK_CODE.

  CASE OK_SAVE.
    WHEN 'DISTR'.
      PERFORM DATA_CHECK_DISTRIBUTE USING GV_ERROR.
      CHECK GV_ERROR NE 'X'.
      PERFORM DATA_DISTRIBUTE.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1200 INPUT.

  CLEAR GV_ERROR.

  CASE GV_FCODE.
    WHEN 'SAVE'.
      PERFORM DATA_CHECK_DISTRIBUTE_POPUP USING GV_ERROR.
      CHECK GV_ERROR NE 'X'.
      PERFORM POPUP_TO_CONFIRM USING '확인'
                                     '저장하시겠습니까?'
                                     '1'
                                     GV_ANSWER.
      CHECK GV_ANSWER EQ 1.
      PERFORM DATA_SAVE_DISTRIBUTE.
      PERFORM GET_FUTURES_DATA.
      LEAVE TO SCREEN 0.
    WHEN 'CAN'.
      CLEAR GV_SAVED.
      LEAVE TO SCREEN 0.
    WHEN 'INS'.
      PERFORM DATA_ADD_ROW.
    WHEN 'DEL'.
      PERFORM DATA_DEL_ROW.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1200  INPUT
