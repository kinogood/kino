*&---------------------------------------------------------------------*
*& Include          ZGTPPR3150I01
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
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE GV_OK_CODE.
    WHEN 'ORDCRE'.
      PERFORM PROCESS_ORDCRE.         "생산오더생성
    WHEN 'ORDDEL'.
      PERFORM PROCESS_ORDDEL.         "생산오더삭제설정
    WHEN 'MATGIGR'.
      PERFORM PROCESS_MATGIGRCF.      "배관실적처리(투입/입고/확정)
    WHEN 'MATGIGRC'.
      PERFORM PROCESS_MATGIGRCFC.     "배관실적취소(확정/입고/투입)
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND_0200 INPUT.
  CASE GV_OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      PERFORM CLS_OBJT_RTN_0200.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CASE GV_OK_CODE.
    WHEN 'ZSAVE'.
      PERFORM PROCESS_ZSAVE.         "ZGTPPT3320 저장
    WHEN 'ADDLINE'.
      PERFORM PROCESS_ADDLINE.       "라인추가
    WHEN 'DELLINE'.
      PERFORM PROCESS_DELLINE.       "라인삭제
    WHEN 'PSTDCRE'.
      PERFORM PROCESS_PSTDCRE.       "생산 기준정보 생성
  ENDCASE.
ENDMODULE.
