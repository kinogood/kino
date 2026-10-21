*&---------------------------------------------------------------------*
*& Include          ZNFR2700_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  GV_OKCODE = SY-UCOMM.
  CASE GV_OKCODE.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0 .

    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

  CLEAR GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  GV_OKCODE = SY-UCOMM.
  CASE GV_OKCODE.
    WHEN 'FC_CANC' OR 'CANC'.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
  ENDCASE.

  CLEAR: GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  GV_OKCODE = SY-UCOMM.
  CASE GV_OKCODE.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      LEAVE PROGRAM .
  ENDCASE.

  CLEAR: GV_OKCODE.

ENDMODULE.
