*&---------------------------------------------------------------------*
*& Include          ZGTMMR4320I01
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
    WHEN 'RFRS'."새로고침
      CLEAR GV_OKCODE.
      PERFORM F_REFRESH.

    WHEN 'POST'. "이전처리
      CLEAR GV_OKCODE.
      PERFORM F_POST.

    WHEN 'REVE'. "이전취소
      CLEAR GV_OKCODE.
      PERFORM F_REVERSE.

    WHEN 'XCHPF'. "재고조회
      CLEAR GV_OKCODE.
      PERFORM F_XCHPF_POP.

  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE GV_OKCODE.
    WHEN 'CONF'."확인
      CLEAR GV_OKCODE.
      PERFORM F_SET_ERFMG.

  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.
  CASE GV_OKCODE.
    WHEN 'BOK'.
      CLEAR GV_OKCODE.
      GS_SCR-ZOK = ABAP_TRUE.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0400 INPUT.

  CASE GV_OKCODE.
    WHEN 'RFRS'."새로고침
      CLEAR GV_OKCODE.
      PERFORM F_REFRESH.

    WHEN 'POST'. "이전처리
      CLEAR GV_OKCODE.
      PERFORM F_POST_MANUAL.

    WHEN 'REVE'. "이전취소
      CLEAR GV_OKCODE.
      PERFORM F_REVERSE_MANUAL.

    WHEN 'IVCA'. "통문증 취소
      CLEAR GV_OKCODE.
      PERFORM F_IV_CANCEL.

    WHEN 'IVCR'. "통문증 생성
      CLEAR GV_OKCODE.
      PERFORM F_IV_CREATE.

  ENDCASE.

ENDMODULE.
