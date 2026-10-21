*&---------------------------------------------------------------------*
*& Include          ZGTSDI0001I01
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
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CLEAR : GV_SAVEOK.

  GV_SAVEOK = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_SAVEOK.
    WHEN 'SAVE'.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CLEAR : GV_SAVEOK.

  GV_SAVEOK = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_SAVEOK.
    WHEN 'ZOKAY'.
      IF GS_S0200-ZERDAT IS INITIAL.
        MESSAGE S007 WITH '인수예정일자' DISPLAY LIKE 'E'. EXIT.
      ENDIF.

      IF GS_S0200-ZCONF IS INITIAL.
        MESSAGE S007 WITH '인수협의내용' DISPLAY LIKE 'E'. EXIT.
      ENDIF.

      GS_S0200-CONFIRM = 'X'.
      LEAVE TO SCREEN 0.
    WHEN 'ZCLOSE'.
      CLEAR GS_S0200.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
