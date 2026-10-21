*&---------------------------------------------------------------------*
*& Include          ZGTPPR3100I01
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
    WHEN 'ORDDEL'.
      PERFORM PROCESS_ORDDEL.      "생산오더삭제설정
    WHEN 'EXPRCCRE'.
      PERFORM PROCESS_EXPRCCRE.    "외주전환
    WHEN 'BUSEXPRCCRE'.
      PERFORM PROCESS_BUSEXPRCCRE. "도체가공 전체 외주 전환
    WHEN 'EXPRCCAN'.
      PERFORM PROCESS_EXPRCCAN.    "외주전환취소
  ENDCASE.
ENDMODULE.
