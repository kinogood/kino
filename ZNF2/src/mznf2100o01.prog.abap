*&---------------------------------------------------------------------*
*&  Include           MZNF2100O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  CASE SY-TCODE.
    WHEN GC_TCODE1.
      GV_TRTYP = 'H'.
      GV_TITLE = '생성'.

    WHEN GC_TCODE2.
      GV_TRTYP = 'A'.
      GV_TITLE = '변경'.

    WHEN GC_TCODE3.
      GV_TRTYP = 'V'.
      GV_TITLE = '조회'.

  ENDCASE.

  SET PF-STATUS '0100'.
  SET TITLEBAR  '100' WITH GV_TITLE.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.

  CLEAR   : GT_EXCL.
  REFRESH : GT_EXCL.

  CASE GV_TRTYP.
    WHEN 'H'.     "생성
      GV_TITLE = '생성'.

      GT_EXCL-FCODE = 'DELE'.  APPEND GT_EXCL.
      GT_EXCL-FCODE = 'HIST'.  APPEND GT_EXCL.

    WHEN 'A'.     "변경
      GV_TITLE = '변경'.

    WHEN 'V'.     "조회
      GV_TITLE = '조회'.

      GT_EXCL-FCODE = 'SAVE'.  APPEND GT_EXCL.
      GT_EXCL-FCODE = 'REQT'.  APPEND GT_EXCL.
      GT_EXCL-FCODE = 'DELE'.  APPEND GT_EXCL.

  ENDCASE.

  SET PF-STATUS '0200' EXCLUDING GT_EXCL.
  SET TITLEBAR  '100'  WITH GV_TITLE.

ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MOVE_ITAB_TO_TC1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MOVE_ITAB_TO_TC1 OUTPUT.

  READ TABLE GT_1011 INDEX TC1-CURRENT_LINE.
  IF SY-SUBRC <> 0.
    CLEAR : GT_1011.
  ENDIF.

ENDMODULE.                 " MOVE_ITAB_TO_TC1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_TC1_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_TC1_LINES OUTPUT.

  DESCRIBE TABLE GT_1011 LINES TC1-LINES.

  IF TC1-TOP_LINE > TC1-LINES.
    TC1-TOP_LINE = TC1-LINES.
  ENDIF.

ENDMODULE.                 " SET_TC1_LINES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTRIBUTE_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_SCREEN_ATTRIBUTE_0200 OUTPUT.

  LOOP AT SCREEN.
    IF GV_TRTYP = 'H'.
      IF SCREEN-GROUP2 = 'GR2'.
        SCREEN-INVISIBLE = 1.
      ENDIF.
    ENDIF.

    IF GV_TRTYP = 'V'.
      IF SCREEN-GROUP1 = 'GR1'.
        SCREEN-INPUT = 0.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

  IF GV_TRTYP = 'H'.
    LOOP AT TC1-COLS INTO GS_COLS.
      IF GS_COLS-SCREEN-GROUP4 = 'GR4' .
        GS_COLS-SCREEN-INPUT = '0'.
        GS_COLS-INVISIBLE    = '1'.
      ENDIF.
      MODIFY TC1-COLS INDEX SY-TABIX FROM GS_COLS.
    ENDLOOP .
  ENDIF.

ENDMODULE.                 " SET_SCREEN_ATTRIBUTE_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTRIBUTE_TC1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_SCREEN_ATTRIBUTE_TC1 OUTPUT.

  LOOP AT SCREEN.
    IF GV_TRTYP = 'V' AND SCREEN-GROUP1 = 'GR1'.
      SCREEN-INPUT = 0.
    ENDIF.

*    IF ( GV_RQTYP <> '4' AND GV_RQTYP <> '5' ) AND
*       SCREEN-GROUP3 = 'GR3'.
*      SCREEN-INPUT = 0.
*    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " SET_SCREEN_ATTRIBUTE_TC1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.

  SET PF-STATUS '0300'.
  SET TITLEBAR  '300'.

ENDMODULE.                 " STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR OUTPUT.

  SET CURSOR FIELD GV_CURSOR LINE GV_CURLIN.

ENDMODULE.                 " SET_CURSOR  OUTPUT
