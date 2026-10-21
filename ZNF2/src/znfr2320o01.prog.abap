*----------------------------------------------------------------------*
***INCLUDE ZNFR2120O01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  SCREEN_0100 OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCREEN_0100  OUTPUT.

  DATA: BEGIN OF GT_EXCL OCCURS 0,
          FCODE LIKE SY-UCOMM,
        END   OF GT_EXCL.

  CLEAR : GT_EXCL[].

  IF RB_2 = 'X'. ">>툴바 추가
    GT_EXCL-FCODE = 'SAVE'.  APPEND GT_EXCL.
  ENDIF.

  SET PF-STATUS '0100' EXCLUDING GT_EXCL.

* [S] New HPC 라디오버튼 추가 / 박우진 2026.09.16
*  IF RB_2 = 'X'.
*    RB_2 = 'X'.
*  ELSE.
*    RB_1 = 'X'.
*  ENDIF.

*  박우진 추가 (2026.09.16)
  IF RB_1 = 'X'.    ">>Radio Control
    RB_1 = 'X'.     "Old HPC
  ELSEIF RB_2 = 'X'.
    RB_2 = 'X'.     "Market Carry
  ELSEIF RB_3 = 'X'.
    RB_3 = 'X'.     "New HPC
  ENDIF.
* [E] New HPC 라디오버튼 추가 / 박우진 2026.09.16


ENDMODULE.                 " SET_VALUE

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

  DATA: GL_ROW    TYPE I,
        GL_VALUE  TYPE C,
        GL_COL    TYPE I,
        GL_ROW_ID TYPE LVC_S_ROW,
        GL_COL_ID TYPE LVC_S_COL,
        GL_ROW_NO TYPE LVC_S_ROID.

  IF GC_CUSTOM_CONTAINER IS INITIAL.
    CREATE OBJECT GC_CUSTOM_CONTAINER
      EXPORTING
        CONTAINER_NAME = GC_CONTAINER_NAME.

    CREATE OBJECT GC_ALV_GRID
      EXPORTING
        I_PARENT      = GC_CUSTOM_CONTAINER
        I_APPL_EVENTS = 'X'.

    PERFORM SET_GRID_LAYO.

    "OLD HPC: Fieldcat 처리>>
    IF RB_1 EQ 'X'.   ">>Fieldcat 제어
      PERFORM SET_GRID_FCAT.

      "New HPC 및 Market Carry: Fieldcat 처리>>
    ELSE.
      PERFORM SET_GRID_FCAT_C.
    ENDIF.

*___색상 삽입 및 셀 속성 제어
    PERFORM SET_CELL_ATTRIBUTE.

*___필요한 function만 삽입
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.

*___Edit Event 및  Event Handler 등록
    PERFORM EVENT_HANDLER_REGISTER.

*___화면 Display
    PERFORM SET_TABLE_FOR_FIRST_DISPLAY.
  ELSE.

    IF RB_1 EQ 'X'.   ">>Fieldcat 제어
      PERFORM SET_GRID_FCAT.
    ELSE.
      PERFORM SET_GRID_FCAT_C.
    ENDIF.


    CALL METHOD GC_ALV_GRID->GET_CURRENT_CELL
      IMPORTING
        ES_ROW_ID = GL_ROW_ID
        ES_COL_ID = GL_COL_ID
        ES_ROW_NO = GL_ROW_NO.

    PERFORM SET_CELL_ATTRIBUTE.

    GS_SCROLL-ROW = 'X'.
    GS_SCROLL-COL = 'X'.

    CALL METHOD GC_ALV_GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = ' '
        IS_STABLE      = GS_SCROLL.     "화면 라인 Refresh

*___화면 Display
    PERFORM SET_TABLE_FOR_FIRST_DISPLAY.


    CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
      EXPORTING
        CONTROL = GC_ALV_GRID.

    CALL METHOD GC_ALV_GRID->SET_CURRENT_CELL_VIA_ID
      EXPORTING
        IS_ROW_ID    = GL_ROW_ID
        IS_COLUMN_ID = GL_COL_ID
        IS_ROW_NO    = GL_ROW_NO.

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
*&      Module  CONTROL_RADIO  INPUT
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
MODULE CONTROL_RADIO INPUT.

" 박우진 추가 (20260917)
  CASE SY-UCOMM.
    WHEN 'RB1'.
      RB_1 = 'X'.  CLEAR: RB_2, RB_3.
      OK_CODE = 'RB'.
    WHEN 'RB3'.
      RB_3 = 'X'.  CLEAR: RB_1, RB_2.
      OK_CODE = 'RB'.
    WHEN 'RB2'.
      RB_2 = 'X'.  CLEAR: RB_1, RB_3.
      OK_CODE = 'RB'.
  ENDCASE.

  CASE OK_CODE.
    WHEN 'RB'.
      " 기존 라디오 전환 로직 (필드카탈로그 재설정, 재조회 등)
  ENDCASE.

ENDMODULE.
