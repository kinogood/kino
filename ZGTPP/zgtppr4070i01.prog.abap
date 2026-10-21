*&---------------------------------------------------------------------*
*& Include          ZGTPPR4070I01
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
    WHEN 'CANGR'.
      PERFORM PROCESS_CANGR.    "생산입고취소
    WHEN 'CANTM'.
      PERFORM PROCESS_CANTM.    "시간투입취소
    WHEN 'CANGI'.
      PERFORM PROCESS_CANGI.    "자재투입취소
    WHEN 'REGR'.
      PERFORM PROCESS_REGR.     "생산입고재처리
    WHEN 'RETM'.
      PERFORM PROCESS_RETM.     "시간투입재처리
    WHEN 'REGI'.
      PERFORM PROCESS_REGI.     "자재투입재처리
  ENDCASE.
ENDMODULE.
