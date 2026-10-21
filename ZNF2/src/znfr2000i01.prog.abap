*&---------------------------------------------------------------------*
*&  Include           ZNFR2000I01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CASE SY-UCOMM..
    WHEN 'EXIT'.
      PERFORM DEQUEUE_ZNFT1000_T.
      LEAVE PROGRAM.
    WHEN 'BACK' OR 'CANC'.
      PERFORM DEQUEUE_ZNFT1000_T.
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

  CASE GV_CODE.
    WHEN 'MODI'.
      PERFORM CALL_TRANSACTION_ZNF2M2002.
    WHEN 'DELE'.
      PERFORM DATA_DELETE.
      PERFORM DATA_RELOAD.
      PERFORM DEQUEUE_ZNFT1000_T.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1100  INPUT
