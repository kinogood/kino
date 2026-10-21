*&---------------------------------------------------------------------*
*&  Include           ZNFR2450O01
*&---------------------------------------------------------------------*
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

*   Edit Event 및  Event Handler 등록
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
  SET TITLEBAR  '100'.

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

    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.

*   Edit Event 및  Event Handler 등록
    PERFORM EVENT_HANDLER_REGISTER_2.

*   화면 display
    PERFORM SET_TABLE_FOR_FIRST_DISPLAY_2.
  ELSE.
    GS_SCROLL-ROW = 'X'.
    GS_SCROLL-COL = 'X'.

    CALL METHOD GC_ALV_GRID2->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = ' '
        IS_STABLE      = GS_SCROLL.     "화면 라인 Refresh
  ENDIF.

ENDMODULE.                 " CREATE_ALV_GRID_0200  OUTPUT
