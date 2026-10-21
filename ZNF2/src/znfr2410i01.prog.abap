*&---------------------------------------------------------------------*
*&  Include           ZNFR2410I01
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
    WHEN 'CHCK'.          "점검
      PERFORM CHECK_SELECTED_DATA.

    WHEN 'DISP'.          "조회
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
    WHEN 'CNFM'.          "생성
*      CALL METHOD GC_ALV_GRID2->CHECK_CHANGED_DATA.

      PERFORM CREATE_NETTING_DATA.

    WHEN 'CFMC'.          "생성취소
      PERFORM CANCEL_NETTING_DATA.

    WHEN 'APLY'.          "기준가적용
      PERFORM APPLY_BASE_PRICE.

*    WHEN 'RFSH'.          "Refresh
*      PERFORM GET_DETAIL_DATA.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
