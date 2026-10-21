*&---------------------------------------------------------------------*
*&  Include           ZNFR2510O01
*&---------------------------------------------------------------------*

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


  IF GRF_CONTAINER_H IS INITIAL.

*   Create Object.
    PERFORM CREATE_OBJECT.

*   Tool-Bar
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE_H.

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

    GS_STBL_H-ROW = 'X'.
    GS_STBL_H-COL = 'X'.

    CALL METHOD GRF_GRID_H->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = ' '
        IS_STABLE      = GS_STBL_H.     "화면 라인 Refresh

  ENDIF.

  IF GT_ROWS_H[] IS NOT INITIAL.
    CALL METHOD GRF_GRID_H->SET_SELECTED_ROWS
      EXPORTING
        IT_INDEX_ROWS = GT_ROWS_H.
  ENDIF.

  IF GT_COLS_H[] IS NOT INITIAL.
    CALL METHOD GRF_GRID_H->SET_SELECTED_COLUMNS
      EXPORTING
        IT_COL_TABLE = GT_COLS_H.
  ENDIF.

ENDMODULE.                 " CREATE_ALV_1100  OUTPUT
