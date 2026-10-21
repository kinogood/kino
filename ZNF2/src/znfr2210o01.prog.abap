*----------------------------------------------------------------------*
***INCLUDE ZNFR2210O01 .
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
*&      Module  CREATE_ALV_GRID_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_ALV_GRID_0200 OUTPUT.

  IF GC_CUSTOM_CONTAINER2 IS INITIAL.
    CREATE OBJECT GC_CUSTOM_CONTAINER2
        EXPORTING
            CONTAINER_NAME = GC_CONTAINER_NAME2.

    CREATE OBJECT GC_ALV_GRID2
        EXPORTING
            I_PARENT      = GC_CUSTOM_CONTAINER2
            I_APPL_EVENTS = 'X'.

    PERFORM SET_GRID_LAYO.

    PERFORM SET_GRID_FCAT_2.

*___필요한 function만 삽입
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.

*___Edit Event 및  Event Handler 등록
    PERFORM EVENT_HANDLER_REGISTER_2.

*___화면 Display
    PERFORM SET_TABLE_FOR_FIRST_DISPLAY_2.
  ELSE.
    GS_SCROLL-ROW = 'X'.
    GS_SCROLL-COL = 'X'.

    CALL METHOD GC_ALV_GRID2->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = ' '
        IS_STABLE      = GS_SCROLL.     "화면 라인 Refresh
  ENDIF.

  PERFORM SET_SELECTED_ROWS_2.

ENDMODULE.                 " CREATE_ALV_GRID_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.

  SET PF-STATUS '0300'.
  SET TITLEBAR  '300'.

ENDMODULE.                 " STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_TC1_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_TC1_LINES OUTPUT.

  DESCRIBE TABLE GT_1020N LINES TC1-LINES.

  IF TC1-TOP_LINE > TC1-LINES.
    TC1-TOP_LINE = TC1-LINES.
  ENDIF.

ENDMODULE.                 " SET_TC1_LINES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MOVE_ITAB_TO_TC1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MOVE_ITAB_TO_TC1 OUTPUT.

  GV_LOOPC = SY-LOOPC.

  READ TABLE GT_1020N INDEX TC1-CURRENT_LINE.
  IF SY-SUBRC <> 0.
    CLEAR : GT_1020N.

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
    IF SCREEN-GROUP1 = 'GR1' AND GT_1020N-MITYP = 'S'.
      SCREEN-INPUT = 0.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " SET_SCREEN_ATTRIBUTE_TC1  OUTPUT
