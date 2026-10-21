*&---------------------------------------------------------------------*
*&  Include           ZNFR2650O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_1100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1100 OUTPUT.

  IF P_R01 EQ 'X'.
    IF GV_TCODE EQ 'ZNF2R2650A'.
      SET PF-STATUS '1100A'.
      SET TITLEBAR  '1100A'.
    ELSE.
      SET PF-STATUS '1100B'.
      SET TITLEBAR  '1100B'.
    ENDIF.
  ELSE.
    SET PF-STATUS '1200'.
    IF GV_TCODE EQ 'ZNF2R2650A'.
      SET TITLEBAR  '1200A'.
    ELSE.
      SET TITLEBAR  '1200B'.
    ENDIF.
  ENDIF.

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
    IF P_R01 EQ 'X'.
      GV_CNT = LINES( GT_OUTTAB ).
      MESSAGE S368(00) WITH GV_CNT '건이 조회되었습니다.'.
    ELSE.
      GV_CNT = LINES( GT_OUTTAB_LIST ).
      MESSAGE S368(00) WITH GV_CNT '건이 조회되었습니다.'.
    ENDIF.
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
