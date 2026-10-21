*&---------------------------------------------------------------------*
*&  Include           ZNFR2470_I01
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

  PERFORM GET_SELECTED_ROWS.

  CASE GV_CODE.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1100  INPUT
