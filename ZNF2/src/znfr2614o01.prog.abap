*&---------------------------------------------------------------------*
*&  Include           ZNFR2613O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_1100  OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_1100 OUTPUT.

  CLEAR   : GT_EXCL.
  REFRESH : GT_EXCL.

* 생성대상 : 역분개 제외 / 생성완료 : 전표생성 제외 / 조회 : 전표생성·역분개 제외
  IF P_R01 = 'X'.
    GT_EXCL-FCODE = 'CANE'.  APPEND GT_EXCL.
  ELSEIF P_R02 = 'X'.
    GT_EXCL-FCODE = 'POST'.  APPEND GT_EXCL.
  ELSEIF P_R03 = 'X'.
    GT_EXCL-FCODE = 'POST'.  APPEND GT_EXCL.
    GT_EXCL-FCODE = 'CANE'.  APPEND GT_EXCL.
  ENDIF.

  SET PF-STATUS '1100' EXCLUDING GT_EXCL.
  SET TITLEBAR  '1100' WITH P_ENDMM.

ENDMODULE.                 " STATUS_1100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  CREATE_ALV  OUTPUT
*&---------------------------------------------------------------------*
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

ENDMODULE.                 " CREATE_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT  (역분개 팝업)
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.

  SET PF-STATUS '0200'.
  SET TITLEBAR  '200'.

ENDMODULE.                 " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT  (전표생성 팝업)
*&---------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.

  SET PF-STATUS '0300'.
  SET TITLEBAR  '300'.

ENDMODULE.                 " STATUS_0300  OUTPUT
