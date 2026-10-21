*&---------------------------------------------------------------------*
*& Include          ZGTLER1110O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  PERFORM SET_EXCLUDE.
  SET PF-STATUS '0100' EXCLUDING GT_EXCL.
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
*&      Module  SET_SCREEN_ATTRIBUTE_0200  OUTPUT
*&---------------------------------------------------------------------*
*       기능개선 157326 - 추가
*----------------------------------------------------------------------*
MODULE SET_SCREEN_ATTRIBUTE_0200 OUTPUT.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'G11' AND GS_DELV-ARIND <> 'X'.
      SCREEN-INPUT = 0.
    ENDIF.

    IF SCREEN-GROUP2 = 'G21' AND
     ( GT_MAIN-KDKG4 = '4E'  OR GT_MAIN-KDKG4 = '4S' ).
      SCREEN-REQUIRED = 0.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " SET_SCREEN_ATTRIBUTE_0200  OUTPUT
*&---------------------------------------------------------------------*
*& Module STATUS_0900 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0900 OUTPUT.
  SET PF-STATUS '0900'.
  SET TITLEBAR '0900'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_CONTROLS_0900 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_CONTROLS_0900 OUTPUT.
  IF GC_CUSTOM_CONTAINER2 IS INITIAL.
    CREATE OBJECT GC_CUSTOM_CONTAINER2
      EXPORTING
        CONTAINER_NAME = 'CONT0900'.

    CREATE OBJECT GC_ALV_GRID2
      EXPORTING
        I_PARENT      = GC_CUSTOM_CONTAINER2.
*        I_APPL_EVENTS = 'X'.

    PERFORM SET_GRID_LAYO_0900.

    PERFORM SET_GRID_FCAT_0900.

*___색상 삽입 및 셀 속성 제어
    PERFORM SET_CELL_ATTRIBUTE_0900.

*___필요한 function만 삽입
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.

*___Edit Event 및  Event Handler 등록
    PERFORM EVENT_HANDLER_REGISTER_0900.

*___SORT
    PERFORM SET_GRID_SORT_0900.

*___화면 Display
    PERFORM ALV_DISPLAY_0900.
  ENDIF.
ENDMODULE.
