*&---------------------------------------------------------------------*
*&  Include           ZNFR2510O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_1200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1200 OUTPUT.
  SET PF-STATUS '1200'.
  SET TITLEBAR  '1200C'.
ENDMODULE.                 " STATUS_1200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CREATE_ALV_1200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_ALV_1200 OUTPUT.

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
    MESSAGE S368(00) WITH GV_H_CNT '건이 조회되었습니다.'.

  ELSE.

*   Set Cell Attribute
    PERFORM SET_CELL_ATTRIBUTE.

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

ENDMODULE.                 " CREATE_ALV_1200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_1210  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1210 OUTPUT.
  SET PF-STATUS '1210'.
  SET TITLEBAR  '1210'.
ENDMODULE.                 " STATUS_1210  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_PERNR_NO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_PERNR_NO OUTPUT.
  CLEAR: GV_PERNR, GV_ENAME, GV_PASSWD.

* 개인아이디 추출
  IF GV_PERNR IS INITIAL AND LINES( GT_PERNR ) EQ 1.
    GV_PERNR = GT_PERNR-PERNR.
  ENDIF.

  IF GV_PERNR IS NOT INITIAL.
*   사번 존재여부
    SELECT SINGLE ENAME INTO GV_ENAME
      FROM PA0001
     WHERE PERNR EQ GV_PERNR
       AND ENDDA GE SY-DATLO
       AND BEGDA LE SY-DATLO.
    IF SY-SUBRC NE 0.
      MESSAGE E003 WITH '결재자 사번이 존재하지 않습니다.'.
    ENDIF.

*   사번의 권한 점검
    CLEAR : ZNFT1090.
    SELECT SINGLE * FROM ZNFT1090
     WHERE CONGB EQ '5'
       AND CONSQ EQ 3
       AND PERNR EQ GV_PERNR
       AND LVORM NE 'X'.
    IF SY-SUBRC NE 0.
      MESSAGE E003
        WITH '결재자 사번이 권한 마스터에 존재하지 않습니다.'.
    ENDIF.
  ELSE.

*   공용아이디인경우 사번란에 사번을 DEFAULT로 뿌려주지 않는다.
    IF GT_PERNR[] IS NOT INITIAL.

*     공용ID가 1개인경우만 화면에 뿌려준다
      IF LINES( GT_PERNR ) EQ 1.
        READ TABLE GT_PERNR INDEX 1.
        IF SY-SUBRC EQ 0.
          GV_PERNR = GT_PERNR-PERNR.
        ENDIF.
      ELSE.
        CLEAR GV_PERNR.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " GET_PERNR_NO  OUTPUT
