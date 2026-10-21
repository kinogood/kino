*&---------------------------------------------------------------------*
*&  Include           ZNFR2250O01
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
*&      Module  CREATE_ALV_1100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_ALV_1100 OUTPUT.


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

ENDMODULE.                 " CREATE_ALV_1100  OUTPUT

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

  IF GRF_CONTAINER_P IS INITIAL.

*   Create Object.
    PERFORM CREATE_OBJECT.

*   Tool-Bar
    IF SY-DYNNR EQ 1100.
      PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.
    ELSE.
      PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE_P.
    ENDIF.

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
    GV_CNT = LINES( GT_DISTRIBUTE[] ).
    MESSAGE S368(00) WITH GV_CNT '건이 조회되었습니다.'.
  ELSE.

*   Set Cell Attribute
    PERFORM SET_CELL_ATTRIBUTE.

    GS_STBL_P-ROW = 'X'.
    GS_STBL_P-COL = 'X'.

    CALL METHOD GRF_GRID_P->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = ' '
        IS_STABLE      = GS_STBL.     "화면 라인 Refresh

  ENDIF.

  IF GT_ROWS_P[] IS NOT INITIAL.
    CALL METHOD GRF_GRID_P->SET_SELECTED_ROWS
      EXPORTING
        IT_INDEX_ROWS = GT_ROWS_P.
  ENDIF.

  IF GT_COLS_P[] IS NOT INITIAL.
    CALL METHOD GRF_GRID_P->SET_SELECTED_COLUMNS
      EXPORTING
        IT_COL_TABLE = GT_COLS_P.
  ENDIF.

ENDMODULE.                 " CREATE_ALV_1200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_SCREEN OUTPUT.

*  =========================================
*  SCREEN-INVISIBLE = 0.
*  SCREEN-INVISIBLE = 1.  <== Hidden
*  =========================================
*  SCREEN-INPUT = 0.      <== Editable
*  SCREEN-INPUT = 1.
*  =========================================

* 저장후 버튼 비활성화
  IF GV_SAVED EQ 'X'.
    LOOP AT SCREEN.

      IF SCREEN-GROUP1 EQ 'GR1'.
*      SCREEN-INPUT = 0.
        SCREEN-INVISIBLE = 1.
      ENDIF.


      IF SCREEN-NAME EQ 'BTN_SAVE'.
*      SCREEN-INPUT = 0.
        SCREEN-INVISIBLE = 1.
      ENDIF.

      IF SCREEN-NAME EQ 'BTN_INS'.
*      SCREEN-INPUT = 0.
        SCREEN-INVISIBLE = 1.
      ENDIF.

      IF SCREEN-NAME EQ 'BTN_DEL'.
*      SCREEN-INPUT = 0.
        SCREEN-INVISIBLE = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

ENDMODULE.                 " MODIFY_SCREEN  OUTPUT
