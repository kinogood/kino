*&---------------------------------------------------------------------*
*&  Include           ZNFR2670O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_1100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1100 OUTPUT.
  SET PF-STATUS '1100'.
  SET TITLEBAR  '1100'.
ENDMODULE.                 " STATUS_1100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  CREATE_ALV  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_ALV OUTPUT.


  IF GRF_CONTAINER_T IS INITIAL.

*   Create Object.
    PERFORM CREATE_OBJECT.

*   Tool-Bar
    PERFORM EXCLUDE_TB_FUNCTIONS_T CHANGING GT_EXCLUDE_T.
    PERFORM EXCLUDE_TB_FUNCTIONS_B CHANGING GT_EXCLUDE_B.

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

  ELSE.

*   ==================================================================
    GS_STBL_T-ROW = 'X'.
    GS_STBL_T-COL = 'X'.

    CALL METHOD GRF_GRID_T->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = ' '
        IS_STABLE      = GS_STBL_T.     "화면 라인 Refresh

**   검색결과
*    CLEAR GV_CNT.
*    IF GT_OUTTAB_T IS NOT INITIAL.
*      GV_CNT = LINES( GT_OUTTAB_T ).
*      MESSAGE S368(00) WITH GV_CNT '건이 조회되었습니다.'.
*    ENDIF.

*   ==================================================================
    GS_STBL_B-ROW = 'X'.
    GS_STBL_B-COL = 'X'.

    CALL METHOD GRF_GRID_B->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = ' '
        IS_STABLE      = GS_STBL_B.     "화면 라인 Refresh

**   검색결과
*    CLEAR GV_CNT.
*    IF GT_OUTTAB_B IS NOT INITIAL.
*      GV_CNT = LINES( GT_OUTTAB_B ).
*      MESSAGE S368(00) WITH GV_CNT '건이 조회되었습니다.'.
*    ENDIF.

  ENDIF.

  IF GT_ROWS_T[] IS NOT INITIAL.
    CALL METHOD GRF_GRID_T->SET_SELECTED_ROWS
      EXPORTING
        IT_INDEX_ROWS = GT_ROWS_T.
  ENDIF.

  IF GT_COLS_T[] IS NOT INITIAL.
    CALL METHOD GRF_GRID_T->SET_SELECTED_COLUMNS
      EXPORTING
        IT_COL_TABLE = GT_COLS_T.
  ENDIF.

  IF GT_ROWS_B[] IS NOT INITIAL.
    CALL METHOD GRF_GRID_B->SET_SELECTED_ROWS
      EXPORTING
        IT_INDEX_ROWS = GT_ROWS_B.
  ENDIF.

  IF GT_COLS_B[] IS NOT INITIAL.
    CALL METHOD GRF_GRID_B->SET_SELECTED_COLUMNS
      EXPORTING
        IT_COL_TABLE = GT_COLS_B.
  ENDIF.

ENDMODULE.                 " CREATE_ALV  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_1200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1200 OUTPUT.
  SET PF-STATUS '1200'.
  SET TITLEBAR  '1200'.
ENDMODULE.                 " STATUS_1200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CREATE_ALV_1200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_ALV_1200 OUTPUT.

  IF GRF_CONTAINER_F IS INITIAL.

*   Create Object.
    PERFORM CREATE_OBJECT_F.

*   Tool-Bar
    PERFORM EXCLUDE_TB_FUNCTIONS_F CHANGING GT_EXCLUDE_F.

*   Set Layout
    PERFORM SET_GRID_LAYOUT_F.

*   Set Sort
    PERFORM SET_GRID_SORT_F.

*   Set FieldCatalog
    PERFORM SET_GRID_FIELDCATALOG_F.

*   Set Cell Attribute
    PERFORM SET_CELL_ATTRIBUTE.

*   Set Event Handler Register
    PERFORM SET_EVENT_HANDLER_F.

*   Set F4 Help Register
    PERFORM SET_F4_HELP_REGISTER_F.

*   ALV Display
    PERFORM SET_TABLE_FOR_FIRST_DISPLAY_F.

  ELSE.

    GS_STBL_F-ROW = 'X'.
    GS_STBL_F-COL = 'X'.

    CALL METHOD GRF_GRID_F->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = ' '
        IS_STABLE      = GS_STBL_F.     "화면 라인 Refresh

  ENDIF.

  IF GT_ROWS_F[] IS NOT INITIAL.
    CALL METHOD GRF_GRID_F->SET_SELECTED_ROWS
      EXPORTING
        IT_INDEX_ROWS = GT_ROWS_F.
  ENDIF.

  IF GT_COLS_F[] IS NOT INITIAL.
    CALL METHOD GRF_GRID_F->SET_SELECTED_COLUMNS
      EXPORTING
        IT_COL_TABLE = GT_COLS_F.
  ENDIF.

ENDMODULE.                 " CREATE_ALV_1200  OUTPUT
