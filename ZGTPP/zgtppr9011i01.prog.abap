*&---------------------------------------------------------------------*
*& Include          ZGTPPR9011I01
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
    WHEN 'STKCONF'.
      PERFORM PROCESS_STKCONF.          "재고확정
    WHEN 'BATCHCRE'.
      PERFORM PROCESS_BATCHCRE.         "배치번호생성
    WHEN 'TRAORDCRE'.
      PERFORM PROCESS_TRAORDCRE.        "변환생산오더생성
    WHEN 'OMATGI'.
      PERFORM PROCESS_OMATGI.           "기존자재투입처리
    WHEN 'NMATGR'.
      PERFORM PROCESS_NMATGR.           "신규자재입고처리
    WHEN 'NMATGRCAN'.
      PERFORM PROCESS_NMATGRCAN.        "신규자재입고취소
    WHEN 'OMATGICAN'.
      PERFORM PROCESS_OMATGICAN.        "기존자재투입취소
    WHEN 'TRAORDDEL'.
      PERFORM PROCESS_TRAORDDEL.        "변환생산오더삭제설정
    WHEN 'STKCONFCAN'.
      PERFORM PROCESS_STKCONFCAN.       "재고확정취소
  ENDCASE.
ENDMODULE.
