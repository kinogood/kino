*&---------------------------------------------------------------------*
*& Include          ZGTSDR1290I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.
  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.

  CASE SAVE_OK.
    WHEN 'BACK' OR 'CANC' OR 'EXIT'.
      PERFORM INIT_CONTROLS_0100.
      LEAVE TO SCREEN 0.


    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.

  CASE SAVE_OK.
    WHEN 'ZCHG'. "점검규칙 변경
      PERFORM MAINTAIN_BP_CHECK_RULE.

    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
