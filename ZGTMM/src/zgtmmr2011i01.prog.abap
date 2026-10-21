*&---------------------------------------------------------------------*
*& Include          ZGTMMR2011I01
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
    WHEN 'RFRS'. "새로고침
      CLEAR GV_OKCODE.
      PERFORM F_REFRESH.

    WHEN 'CONF'. "구매요청 승인
      CLEAR GV_OKCODE.
      PERFORM F_PR_RELEASE.

    WHEN 'REJE'. "구매요청 반려
      CLEAR GV_OKCODE.
      PERFORM F_PR_REJECT.

  ENDCASE.

ENDMODULE.
