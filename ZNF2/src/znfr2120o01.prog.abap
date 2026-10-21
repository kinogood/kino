*----------------------------------------------------------------------*
***INCLUDE ZNFR2120O01 .
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
*&      Module  CREATE_ALV_GRID  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_ALV_GRID OUTPUT.

  IF GC_CUSTOM_CONTAINER IS INITIAL.
    CREATE OBJECT GC_CUSTOM_CONTAINER
        EXPORTING
            CONTAINER_NAME = GC_CONTAINER_NAME.

    CREATE OBJECT GC_ALV_GRID
        EXPORTING
            I_PARENT      = GC_CUSTOM_CONTAINER
            I_APPL_EVENTS = 'X'.

    PERFORM SET_GRID_LAYO.

    PERFORM SET_GRID_FCAT.

*___색상 삽입 및 셀 속성 제어
    PERFORM SET_CELL_ATTRIBUTE.

*___필요한 function만 삽입
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.

*___Edit Event 및  Event Handler 등록
    PERFORM EVENT_HANDLER_REGISTER.

*___F4 Help Field 등록
    PERFORM SET_F4HELP_FIELD.

*___화면 Display
    PERFORM SET_TABLE_FOR_FIRST_DISPLAY.
  ELSE.
    PERFORM SET_CELL_ATTRIBUTE.

    GS_SCROLL-ROW = 'X'.
    GS_SCROLL-COL = 'X'.

    CALL METHOD GC_ALV_GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = ' '
        IS_STABLE      = GS_SCROLL.     "화면 라인 Refresh
  ENDIF.

  PERFORM SET_SELECTED_ROWS.

ENDMODULE.                 " CREATE_ALV_GRID  OUTPUT
