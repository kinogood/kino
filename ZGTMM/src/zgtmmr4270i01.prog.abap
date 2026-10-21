*&---------------------------------------------------------------------*
*& Include          ZGTMMR4270I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.

  CASE GV_OKCODE.
    WHEN 'CANC' OR 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE GV_OKCODE.
    WHEN 'CONV'. "조회/수정 전환
      CLEAR GV_OKCODE.
      PERFORM F_CONV_100.

    WHEN 'RFRS'. "새로고침
      CLEAR GV_OKCODE.
      PERFORM F_REFRESH_100.

  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0101 INPUT.

  CASE GV_OKCODE.
    WHEN 'BOK'.
      GS_SCR-ZOK = ABAP_TRUE.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE GV_OKCODE.
    WHEN 'CONV'. "조회/수정 전환
      CLEAR GV_OKCODE.
      PERFORM F_CONV_200.

    WHEN 'BSAVE' OR 'SAVE'. "저장
      CLEAR GV_OKCODE.
      PERFORM F_SAVE_200.
  ENDCASE.

ENDMODULE.
