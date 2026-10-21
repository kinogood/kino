*&---------------------------------------------------------------------*
*& Include          ZGTPPR2160I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  PERFORM USER_COMMAND_EXIT.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_100 INPUT.

  CASE GV_OKCODE.
    WHEN GC_FCODE-BACK OR GC_FCODE-EXIT. "// Back, Exit.
      PERFORM USER_COMMAND_EXIT.

    WHEN GC_FCODE-FIXED_COL.             "// 고정 컬럼 설정.
      PERFORM USER_COMMAND_FIXED_COL.
  ENDCASE.

  CLEAR GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_200 INPUT.

  CASE GV_OKCODE.
    WHEN GC_FCODE-BACK OR GC_FCODE-EXIT. "// Back, Exit.
      PERFORM USER_COMMAND_EXIT.

    WHEN GC_FCODE-SAVE.                  "// 저장.
      PERFORM USER_COMMAND_SAVE.
  ENDCASE.

  CLEAR GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.
  CLEAR GV_OKCODE2.
  GV_OKCODE2 = SY-UCOMM.
  CLEAR SY-UCOMM.
  CASE GV_OKCODE2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR : GV_XC.
      LEAVE TO SCREEN 0.
    WHEN 'CHG'.
      IF GV_XC EQ 'X' OR GV_XC EQ 'C' OR GV_XC EQ SPACE.
        LEAVE TO SCREEN 0.
      ELSE.
        MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-E32.
      ENDIF.
  ENDCASE.
ENDMODULE.
