*&---------------------------------------------------------------------*
*& Include          ZGTMMR4381I01
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

    WHEN 'BRFRS'. "새로고침
      CLEAR GV_OKCODE.
      PERFORM F_REFRESH_100.

    WHEN 'BOK'. "재고 조정 처리
      CLEAR GV_OKCODE.
      PERFORM F_GOODSMVT.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0101 INPUT.

  CASE GV_OKCODE.
    WHEN 'BOK1'.
      GS_SCR_101-ZCHK = ABAP_TRUE.
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

    WHEN 'BRFRS'. "새로고침
      CLEAR GV_OKCODE.
      PERFORM F_REFRESH_200.

    WHEN 'BCAN'. "재고 조정 취소처리
      CLEAR GV_OKCODE.
      PERFORM F_GOODSMVT_CANCEL.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0201  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0201 INPUT.

  CASE GV_OKCODE.
    WHEN 'BOK1'.
      GS_SCR_201-ZCHK = ABAP_TRUE.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
