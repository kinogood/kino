*&---------------------------------------------------------------------*
*&  Include           ZNFR2420I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CASE OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR : OK_CODE.

      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  SAVE_OK_CODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SAVE_OK_CODE INPUT.

  OK_SAVE = OK_CODE.

  CLEAR : OK_CODE.

ENDMODULE.                 " SAVE_OK_CODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  PERFORM GET_SELECTED_ROWS_1.

  CASE OK_SAVE.
    WHEN 'CHCK' OR 'DISP'.    "점검/조회
      PERFORM DISPLAY_SELECTED_DATA.

    WHEN 'ASEL' OR 'DSEL'.
      PERFORM SELECT_ALL.

    WHEN 'RFSH'.          "Refresh
      PERFORM GET_SETTLEMENT_DATA.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CALL METHOD GC_ALV_GRID2->CHECK_CHANGED_DATA.

  CASE OK_SAVE.
    WHEN 'CNFM'.          "확정
      PERFORM CREATE_FUTURES_PROFIT_DATA.

    WHEN 'CFMC'.          "확정취소
      PERFORM CANCEL_FUTURES_PROFIT_DATA.

    WHEN 'APLY'.          "조정수수료배부
      PERFORM APPLY_CHARGE_DISTRIBUTION.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
