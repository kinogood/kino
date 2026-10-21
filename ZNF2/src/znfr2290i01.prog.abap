*&---------------------------------------------------------------------*
*&  Include           ZNFR2290I01
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
    WHEN 'SAVE'.
      PERFORM CHECK_SAVE_DATA USING GV_ERROR.
      CHECK GV_ERROR IS INITIAL.
      PERFORM POPUP_TO_CONFIRM USING '확인'
                                     '데이터를 저장하시겠습니까?'
                                     '1'
                                     GV_ANSWER.
      CHECK GV_ANSWER EQ '1'.
      PERFORM DATA_SAVE.
    WHEN 'ASEL' OR 'DSEL'.
      PERFORM SELECT_ALL.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1100  INPUT
