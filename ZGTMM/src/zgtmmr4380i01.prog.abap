*&---------------------------------------------------------------------*
*& Include          ZGTMMR4380I01
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
      PERFORM F_REFRESH_100.

    WHEN 'BCONF'. "재고실사 차이 확정
      CLEAR GV_OKCODE.
      PERFORM F_BCONF.

    WHEN 'BCANC'. "재고실사 차이 확정취소
      CLEAR GV_OKCODE.
      PERFORM F_BCANC.

    WHEN 'BAPPV'. "승인요청
      CLEAR GV_OKCODE.
      PERFORM F_BAPPV.

  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CASE GV_OKCODE.
    WHEN 'RFRS'. "새로고침
      CLEAR GV_OKCODE.
      PERFORM F_REFRESH_200.

    WHEN 'ACONF'. "재고실사 차이 확정
      CLEAR GV_OKCODE.
      PERFORM F_ACONF.

    WHEN 'ACANC'. "재고실사 차이 확정취소
      CLEAR GV_OKCODE.
      PERFORM F_ACANC.


  ENDCASE.

ENDMODULE.
