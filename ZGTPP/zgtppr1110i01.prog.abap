*&---------------------------------------------------------------------*
*& Include          ZGTPPR1110I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.
  CASE GV_OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      PERFORM CLS_OBJT_RTN.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE GV_OK_CODE.
    WHEN 'PVERCRE'.
      PERFORM PROCESS_PVERCRE. "생산버전 등록
    WHEN 'PVERDEL'.
      PERFORM PROCESS_PVERDEL. "생산버전 삭제
  ENDCASE.

ENDMODULE.
