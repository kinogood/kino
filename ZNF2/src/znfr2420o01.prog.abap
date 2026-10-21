*&---------------------------------------------------------------------*
*&  Include           ZNFR2420O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  CLEAR   : GT_EXCL.
  REFRESH : GT_EXCL.

  IF GV_TRTYP = 'A'.
    GT_EXCL-FCODE = 'CHCK'.  APPEND GT_EXCL.
  ELSE.
    GT_EXCL-FCODE = 'DISP'.  APPEND GT_EXCL.
  ENDIF.

  SET PF-STATUS '0100' EXCLUDING GT_EXCL.
  SET TITLEBAR  '100'  WITH GV_TITLE.

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

*___색상 삽입 및 셀 속성 제어
    PERFORM SET_CELL_ATTRIBUTE.

*___필요한 function만 삽입
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.

*___Edit Event 및  Event Handler 등록
    PERFORM EVENT_HANDLER_REGISTER_1.

*___화면 Display
    PERFORM SET_TABLE_FOR_FIRST_DISPLAY_1.
  ELSE.
*___색상 삽입 및 셀 속성 제어
    PERFORM SET_CELL_ATTRIBUTE.

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

  CLEAR   : GT_EXCL.
  REFRESH : GT_EXCL.

  IF GV_TRTYP = 'V'.
    GT_EXCL-FCODE = 'CFMC'.  APPEND GT_EXCL.
  ELSE.
    GT_EXCL-FCODE = 'CNFM'.  APPEND GT_EXCL.
    GT_EXCL-FCODE = 'APLY'.  APPEND GT_EXCL.
  ENDIF.

  SET PF-STATUS '0200' EXCLUDING GT_EXCL.
  SET TITLEBAR  '100'  WITH GV_TITLE.

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

*___색상 삽입 및 셀 속성 제어
    PERFORM SET_CELL_ATTRIBUTE_2.

*___필요한 function만 삽입
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.

*___Edit Event 및  Event Handler 등록
    PERFORM EVENT_HANDLER_REGISTER_2.

*___화면 Display
    PERFORM SET_TABLE_FOR_FIRST_DISPLAY_2.
  ELSE.
*___색상 삽입 및 셀 속성 제어
    PERFORM SET_CELL_ATTRIBUTE_2.

    GS_SCROLL-ROW = 'X'.
    GS_SCROLL-COL = 'X'.

    CALL METHOD GC_ALV_GRID2->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = ' '
        IS_STABLE      = GS_SCROLL.     "화면 라인 Refresh
  ENDIF.

ENDMODULE.                 " CREATE_ALV_GRID_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTRIBUTE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_SCREEN_ATTRIBUTE OUTPUT.

  IF GV_TRTYP = 'A'.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'GR1'.
        SCREEN-INPUT     = 0.
*        SCREEN-INVISIBLE = 1.

        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " SET_SCREEN_ATTRIBUTE  OUTPUT
