*&---------------------------------------------------------------------*
*& Include          ZGTSDR0012I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.
  CLEAR : GV_SAVEOK.

  GV_SAVEOK = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_SAVEOK.
    WHEN 'EXIT' OR 'CANC' OR 'CANL' OR 'BACK'.
      CASE SY-DYNNR.
        WHEN '0100'.
*          PERFORM FREE_OBJECT.

        WHEN '0200'.

      ENDCASE.

      LEAVE TO SCREEN 0.

  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  GV_SAVEOK = GV_OKCODE.
  CLEAR GV_OKCODE.

  "변경된 데이터 반영(Handle Data Changed 이벤트 호출)
  CALL METHOD GO_GRID->CHECK_CHANGED_DATA.

  CASE GV_SAVEOK.
    WHEN 'BACK' OR 'CANC' OR 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      PERFORM DATA_SAVE.
  ENDCASE.

ENDMODULE.
