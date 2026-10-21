*&---------------------------------------------------------------------*
*&  Include           ZNFR2613O01
*&---------------------------------------------------------------------*
MODULE STATUS_1100 OUTPUT.

  SET PF-STATUS '1100'.
  SET TITLEBAR  '1100'.

GT_EXCL-FCODE = 'CANE'.  APPEND GT_EXCL.
GT_EXCL-FCODE = 'POST'.  APPEND GT_EXCL.

  SET PF-STATUS '1100' EXCLUDING GT_EXCL.

ENDMODULE.                 " STATUS_1100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  CREATE_ALV  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_ALV OUTPUT.

  IF GRF_CONTAINER IS INITIAL.

*   Create Object.
    PERFORM CREATE_OBJECT.

*   Tool-Bar
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.

*   Set Layout
    PERFORM SET_GRID_LAYOUT.

*   Set Sort
    PERFORM SET_GRID_SORT.

*   Set FieldCatalog
    PERFORM SET_GRID_FIELDCATALOG.

*   Set Cell Attribute
    PERFORM SET_CELL_ATTRIBUTE.

*   Set Event Handler Register
    PERFORM SET_EVENT_HANDLER.

*   Set F4 Help Register
    PERFORM SET_F4_HELP_REGISTER.

*   ALV Display
    PERFORM SET_TABLE_FOR_FIRST_DISPLAY.

*   검색결과
    GV_CNT = LINES( GT_OUTTAB[] ).
    MESSAGE S368(00) WITH GV_CNT '건이 조회되었습니다.'.
  ELSE.

    GS_STBL-ROW = 'X'.
    GS_STBL-COL = 'X'.

    CALL METHOD GRF_GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = ' '
        IS_STABLE      = GS_STBL.     "화면 라인 Refresh

  ENDIF.

  IF GT_ROWS[] IS NOT INITIAL.
    CALL METHOD GRF_GRID->SET_SELECTED_ROWS
      EXPORTING
        IT_INDEX_ROWS = GT_ROWS.
  ENDIF.

  IF GT_COLS[] IS NOT INITIAL.
    CALL METHOD GRF_GRID->SET_SELECTED_COLUMNS
      EXPORTING
        IT_COL_TABLE = GT_COLS.
  ENDIF.

ENDMODULE.                 " CREATE_ALV  OUTPUT
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
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE OK_SAVE.
    WHEN 'REVS'.    "전표역분개
      PERFORM REVERSE_FI_DOC.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  CASE OK_SAVE..
    WHEN 'CONT'.    "전표생성

      IF GV_RATIO IS INITIAL.
        MESSAGE '비율을 입력해 주세요.'
        TYPE 'S' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      PERFORM CREATE_FI_DOC.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT
