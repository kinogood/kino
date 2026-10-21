*&---------------------------------------------------------------------*
*&  Include           ZNFR2101O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_1100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1100 OUTPUT.

*.Button Setting
  IF GV_COMPLETE_REQ EQ 'Y'.        "(요청후)
    SET PF-STATUS '1102'.
  ELSEIF GV_COMPLETE_SAVE EQ 'Y'.   "(저장후)
    SET PF-STATUS '1101'.
  ELSE.                             "(저장전)
    SET PF-STATUS '1100'.
  ENDIF.

  SET TITLEBAR  '1100'.

ENDMODULE.                 " STATUS_1100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_1200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1200 OUTPUT.

  SET PF-STATUS '1200'.
  SET TITLEBAR  '1200'.

ENDMODULE.                 " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  CREATE_ALV  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_ALV OUTPUT.

  IF GRF_CONTAINER IS INITIAL.

*   Create Object : GRF_CONTAINER
    CREATE OBJECT GRF_CONTAINER
      EXPORTING
        CONTAINER_NAME = GRF_CONTAINER_NAME.

*   Create Object : GRF_GRID
    CREATE OBJECT GRF_GRID
      EXPORTING
        I_PARENT      = GRF_CONTAINER
        I_APPL_EVENTS = 'X'.

*   Tool-Bar
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.

*   Set Layout
    PERFORM SET_GRID_LAYOUT.

*   Set Sort
    PERFORM SET_GRID_SORT.

*   Set FieldCatalog
    PERFORM SET_GRID_FIELDCATALOG.

*   Set Event Handler Register
    PERFORM SET_EVENT_HANDLER.

*   Set F4 Help Register
    PERFORM SET_F4_HELP_REGISTER.

*   ALV Display
    PERFORM SET_TABLE_FOR_FIRST_DISPLAY.

*   Upload 내역 메시지 출력
    GV_CNT = LINES( GT_OUTTAB[] ).
    MESSAGE S003 WITH '만기이동요청 ' GV_CNT '건이 Upload 되었습니다.'.

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
