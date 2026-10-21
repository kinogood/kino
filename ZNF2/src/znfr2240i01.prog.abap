*----------------------------------------------------------------------*
***INCLUDE ZNFR2230I01 .
*----------------------------------------------------------------------*
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

  PERFORM GET_SELECTED_ROWS.

  CASE OK_SAVE.
    WHEN 'SAVE'.     "저장
      PERFORM SAVE_FUTURES_TRADE USING 'S'.

    WHEN 'REQT'.     "결재요청
      PERFORM SAVE_FUTURES_TRADE USING 'R'.

    WHEN 'RFSH'.     "Refresh
      LOOP AT GT_MAIN WHERE CHECK = 'X'.
        CLEAR : GT_MAIN-CHECK.

        IF GT_MAIN-NCIND = 'N'.
          PERFORM ENQUEUE_DEQUEUE_ZNFT1020.
        ELSE.
          PERFORM ENQUEUE_DEQUEUE_ZNFT1030.
        ENDIF.
      ENDLOOP.

      PERFORM GET_FUTURES_DATA.

    WHEN 'ASEL' OR 'DSEL'.
      PERFORM SELECT_ALL.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
