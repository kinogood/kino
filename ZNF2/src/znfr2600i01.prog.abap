*----------------------------------------------------------------------*
***INCLUDE ZNFR2600I01 .
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

      IF SY-DYNNR = '0200'.
        IF NOT GC_CUSTOM_CONTAINER2 IS INITIAL.
          CALL METHOD GC_ALV_TREE->FREE.
          CALL METHOD GC_CUSTOM_CONTAINER2->FREE.
          FREE GC_ALV_TREE.
          FREE GC_CUSTOM_CONTAINER2.
        ENDIF.
      ENDIF.

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
    WHEN 'DISP1'.    "연결이력조회
      PERFORM DISPLAY_ASSIGN_HISTORY.

    WHEN 'DISP2'.    "변경이력조회
      PERFORM DISPLAY_CHANGE_HISTORY.

    WHEN 'RFSH'.     "Refresh
      PERFORM GET_FUTURES_DATA.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF SY-DYNNR = '0200'.
        IF NOT GC_CUSTOM_CONTAINER2 IS INITIAL.
          CALL METHOD GC_ALV_TREE->FREE.
          CALL METHOD GC_CUSTOM_CONTAINER2->FREE.
          FREE GC_ALV_TREE.
          FREE GC_CUSTOM_CONTAINER2.
        ENDIF.
      ENDIF.

      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

ENDMODULE.
