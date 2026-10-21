*&---------------------------------------------------------------------*
*& Include          ZGTMMR3010I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.

  GV_OKCODE_SAVE = GV_OKCODE.
  CLEAR GV_OKCODE.
*
*  PERFORM POPUP_TO_CONFIRM_STEP USING ZGTFI_N
*                                      TEXT-M04
*                                      ''
*                                      TEXT-T01.
*  CHECK GV_ANSWER = ZGTFI_J.

  CASE GV_OKCODE_SAVE.

    WHEN 'BACK' OR 'CANC'.
       PERFORM RELEASE_ALV.
       LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      PERFORM RELEASE_ALV.
      LEAVE PROGRAM.

  ENDCASE.

ENDMODULE.
