*----------------------------------------------------------------------*
***INCLUDE ZNFR2100O01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  CLEAR   : GT_EXCL.
  REFRESH : GT_EXCL.

  IF GV_SAVE = 'X'.
    GT_EXCL-FCODE = 'SAVE'.  APPEND GT_EXCL.
  ENDIF.

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
*&      Module  SET_SCREEN_ATTRIBUTE_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_SCREEN_ATTRIBUTE_0100 OUTPUT.

  IF GV_SAVE = 'X'.
    LOOP AT SCREEN.
      SCREEN-INPUT = 0.

      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " SET_SCREEN_ATTRIBUTE_0100  OUTPUT
