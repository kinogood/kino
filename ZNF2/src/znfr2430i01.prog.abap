*&---------------------------------------------------------------------*
*&  Include           ZNFR2430I01
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

  CASE OK_SAVE.
    WHEN 'CNFM'.          "저장
      PERFORM CREATE_EXCHANGE_RATE.

    WHEN 'CFMC'.          "취소
      PERFORM CANCEL_EXCHANGE_RATE.

    WHEN 'APLY'.          "환율반영
      PERFORM APPLY_EXCHANGE_RATE.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4HELP_DATUM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_DATUM INPUT.

  PERFORM F4HELP_DATUM.

ENDMODULE.                 " F4HELP_DATUM  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_EXCHANGE_RATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_EXCHANGE_RATE INPUT.

  PERFORM GET_EXCHANGE_RATE.

ENDMODULE.                 " GET_EXCHANGE_RATE  INPUT
