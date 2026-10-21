*&---------------------------------------------------------------------*
*&  Include           ZNFR2613I01
*&---------------------------------------------------------------------*
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
*
*  CLEAR : GV_CODE.
*  GV_CODE = OK_CODE.
*  CLEAR : OK_CODE.
*
*    PERFORM GET_SELECTED_ROWS.
*
*  CASE GV_CODE.
*    WHEN 'POST' OR 'EXIT'  .    "전표생성
*      PERFORM CALL_SCREEN_0300.
*    WHEN 'CANE'.
*      PERFORM CALL_SCREEN_0200.
*
*    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*      LEAVE TO SCREEN 0.
*    WHEN OTHERS.
*  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.

  SET PF-STATUS '0200'.
  SET TITLEBAR  '100'.

ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.

  SET PF-STATUS '0300'.
  SET TITLEBAR  '300'.

ENDMODULE.                 " STATUS_0300  OUTPUT
