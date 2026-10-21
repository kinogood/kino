*----------------------------------------------------------------------*
***INCLUDE ZNFR2200O01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  SET PF-STATUS '0100'.
  SET TITLEBAR  '100'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MOVE_ITAB_TO_TC1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MOVE_ITAB_TO_TC1 OUTPUT.

  READ TABLE GT_MAIN INDEX TC1-CURRENT_LINE.
  IF SY-SUBRC <> 0.
    CLEAR : GT_MAIN.

    EXIT FROM STEP-LOOP.
  ENDIF.

ENDMODULE.                 " MOVE_ITAB_TO_TC1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTRIBUTE_TC1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_SCREEN_ATTRIBUTE_TC1 OUTPUT.

  LOOP AT SCREEN.
    IF GT_MAIN-ZFLAG = 'Y'.
      IF SCREEN-GROUP1 = 'GR1' OR SCREEN-NAME = 'GT_MAIN-CHECK'.
        SCREEN-INPUT = 0.

      ENDIF.
    ELSE.
      IF SCREEN-GROUP2 = 'GR2' AND GT_MAIN-MITYP = 'S'.
        SCREEN-INPUT = 0.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " SET_SCREEN_ATTRIBUTE_TC1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_TC1_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_TC1_LINES OUTPUT.

  DESCRIBE TABLE GT_MAIN LINES TC1-LINES.

ENDMODULE.                 " SET_TC1_LINES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR OUTPUT.

  SET CURSOR FIELD GV_CURSOR LINE GV_CURLIN.

ENDMODULE.                 " SET_CURSOR  OUTPUT
