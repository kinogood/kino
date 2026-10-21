*----------------------------------------------------------------------*
***INCLUDE ZNFR2220O01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  SET PF-STATUS '0100'.
  SET TITLEBAR  '100'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CREATE_ALV_GRID_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_ALV_GRID_0100 OUTPUT.

  IF GC_CUSTOM_CONTAINER1 IS INITIAL.
    CREATE OBJECT GC_CUSTOM_CONTAINER1
        EXPORTING
            CONTAINER_NAME = GC_CONTAINER_NAME1.

    CREATE OBJECT GC_ALV_GRID1
        EXPORTING
            I_PARENT      = GC_CUSTOM_CONTAINER1
            I_APPL_EVENTS = 'X'.

    PERFORM SET_GRID_LAYO.

    PERFORM SET_GRID_FCAT_1.

*___필요한 function만 삽입
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.

*___Edit Event 및  Event Handler 등록
    PERFORM EVENT_HANDLER_REGISTER_1.

*___화면 Display
    PERFORM SET_TABLE_FOR_FIRST_DISPLAY_1.
  ELSE.
    GS_SCROLL-ROW = 'X'.
    GS_SCROLL-COL = 'X'.

    CALL METHOD GC_ALV_GRID1->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = ' '
        IS_STABLE      = GS_SCROLL.     "화면 라인 Refresh
  ENDIF.

  PERFORM SET_SELECTED_ROWS_1.

ENDMODULE.                 " CREATE_ALV_GRID_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.

  SET PF-STATUS '0200'.
  SET TITLEBAR  '200'.

ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR OUTPUT.

  SET CURSOR FIELD GV_CURSOR LINE GV_CURLIN.

ENDMODULE.                 " SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_TC1_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_TC1_LINES OUTPUT.

  DESCRIBE TABLE GT_TRAN LINES TC1-LINES.

ENDMODULE.                 " SET_TC1_LINES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MOVE_ITAB_TO_TC1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MOVE_ITAB_TO_TC1 OUTPUT.

  READ TABLE GT_TRAN INDEX TC1-CURRENT_LINE.
  IF SY-SUBRC <> 0.
    CLEAR : GT_TRAN.

    EXIT FROM STEP-LOOP.
  ENDIF.

ENDMODULE.                 " MOVE_ITAB_TO_TC1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTRIBUTE_TC1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_SCREEN_ATTRIBUTE_TC1 OUTPUT.

  LOOP AT SCREEN.
    IF GT_TRAN-MITYP = 'S' AND SCREEN-GROUP1 = 'GR1'.
      SCREEN-INPUT = 0.
    ENDIF.

    IF GT_TRAN-NCIND = 'N'.
      SCREEN-INPUT = 0.

      IF SCREEN-NAME = 'GT_TRAN-ZEPRO'.
        SCREEN-INVISIBLE = 1.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " SET_SCREEN_ATTRIBUTE_TC1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.

  IF SY-DYNNR = '0110'.
    SET PF-STATUS '0300'.
    SET TITLEBAR  '300' WITH '일괄입력'.
  ELSE.
    SET PF-STATUS '0300' EXCLUDING 'CONT'.
    SET TITLEBAR  '300' WITH '상세 데이터'.
  ENDIF.

  GV_CHK1 = 'X'.
  GV_CHK2 = 'X'.
  GV_CHK3 = 'X'.
  GV_CHK4 = 'X'.
  GV_CHK5 = 'X'.
  GV_CHK6 = 'X'.
  GV_CHK7 = 'X'.
  GV_CHK8 = 'X'.

ENDMODULE.                 " STATUS_0300  OUTPUT
