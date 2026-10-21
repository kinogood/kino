*&---------------------------------------------------------------------*
*& Include          MZGTSDR1230C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&       Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.

  PUBLIC SECTION.

    METHODS : HANDLE_NODE_DOUBLE_CLICK FOR EVENT NODE_DOUBLE_CLICK
                                              OF CL_GUI_SIMPLE_TREE
                                       IMPORTING NODE_KEY.

    METHODS : HANDLE_SELECTION_CHANGED FOR EVENT SELECTION_CHANGED
                                              OF CL_GUI_SIMPLE_TREE
                                       IMPORTING NODE_KEY.

    METHODS : HANDLE_NODE_CM_REQUEST
                FOR EVENT NODE_CONTEXT_MENU_REQUEST
                 OF CL_GUI_SIMPLE_TREE IMPORTING NODE_KEY
                                                 MENU.
    METHODS : HANDLE_NODE_CM_SEL
                FOR EVENT NODE_CONTEXT_MENU_SELECT
                 OF CL_GUI_SIMPLE_TREE IMPORTING NODE_KEY
                                                 FCODE.

ENDCLASS.               "LCL_EVENT_HANDLER
*---------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER_1 DEFINITION
*---------------------------------------------------------------------*
*  이벤트 등록해준걸 버튼 추가
*---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER_1 DEFINITION.

  PUBLIC SECTION.
* 이벤트 등록해준걸 버튼 추가
    METHODS: HANDLE_TOOLBAR
                FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
                IMPORTING E_OBJECT E_INTERACTIVE.

    METHODS: HANDLE_TOOLBAR_1
                FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
                IMPORTING E_OBJECT E_INTERACTIVE.

    METHODS: HANDLE_TOOLBAR_6
                FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
                IMPORTING E_OBJECT E_INTERACTIVE.

    METHODS: HANDLE_TOOLBAR_15
                FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
                IMPORTING E_OBJECT E_INTERACTIVE.

    METHODS: HANDLE_TOOLBAR_16
                FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
                IMPORTING E_OBJECT E_INTERACTIVE.

* 이벤트 등록해준걸 버튼에 해당하는 이벤트 추가.
    METHODS: HANDLE_USER_COMMAND
                FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
                IMPORTING E_UCOMM.

    METHODS: HANDLE_USER_COMMAND_1
                FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
                IMPORTING E_UCOMM.

    METHODS: HANDLE_USER_COMMAND_6
                FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
                IMPORTING E_UCOMM.

    METHODS: HANDLE_USER_COMMAND_15
                FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
                IMPORTING E_UCOMM.

    METHODS: HANDLE_USER_COMMAND_16
                FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
                IMPORTING E_UCOMM.

    METHODS: HANDLE_HOTSPOT_CLICK_1
                FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
                IMPORTING E_ROW_ID
                          E_COLUMN_ID.

    METHODS: HANDLE_HOTSPOT_CLICK_15
                FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
                IMPORTING E_ROW_ID
                          E_COLUMN_ID.

    METHODS: HANDLE_HOTSPOT_CLICK_16
                FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
                IMPORTING E_ROW_ID
                          E_COLUMN_ID.

    METHODS: HANDLE_HOTSPOT_CLICK_2
                FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
                IMPORTING E_ROW_ID
                          E_COLUMN_ID.

    METHODS: HANDLE_HOTSPOT_CLICK_3
                FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
                IMPORTING E_ROW_ID
                          E_COLUMN_ID.

    METHODS: HANDLE_HOTSPOT_CLICK_7
                FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
                IMPORTING E_ROW_ID
                          E_COLUMN_ID.

    METHODS: HANDLE_USER_COMMAND_5
                FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
                IMPORTING E_UCOMM.
* 이벤트 등록해준걸 버튼 추가
    METHODS: HANDLE_TOOLBAR101
                FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
                IMPORTING E_OBJECT E_INTERACTIVE.
* 이벤트 등록해준걸 버튼에 해당하는 이벤트 추가.
    METHODS: HANDLE_USER_COMMAND101
                FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
                IMPORTING E_UCOMM.

*    METHODS: HANDLE_AFTER_USER_COMMAND
*                FOR EVENT AFTER_USER_COMMAND OF CL_GUI_ALV_GRID
*                IMPORTING  E_UCOMM .
*
    METHODS: HANDLE_DATA_CHANGED_1
                FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
                IMPORTING ER_DATA_CHANGED .

    METHODS: HANDLE_DATA_CHANGED_2
                FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
                IMPORTING ER_DATA_CHANGED .

    METHODS: HANDLE_DATA_CHANGED_3
                FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
                IMPORTING ER_DATA_CHANGED .

    METHODS: HANDLE_DATA_CHANGED_5
                FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
                IMPORTING ER_DATA_CHANGED .

    METHODS: HANDLE_DATA_CHANGED_7
                FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
                IMPORTING ER_DATA_CHANGED .

    METHODS: HANDLE_DATA_CHANGED_15
                FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
                IMPORTING ER_DATA_CHANGED .

    METHODS: HANDLE_DATA_CHANGED_16
                FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
                IMPORTING ER_DATA_CHANGED .

    METHODS: HANDLE_DATA_CHANGED_910
                FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
                IMPORTING ER_DATA_CHANGED .

    METHODS: HANDLE_DATA_CHANGED_960
                FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
                IMPORTING ER_DATA_CHANGED .

    METHODS: HANDLE_DATA_CHANGED_FINISHED_1
            FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
                IMPORTING E_MODIFIED ET_GOOD_CELLS.

    METHODS: HANDLE_DATA_CHANGED_FINISHED_5
            FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
                IMPORTING E_MODIFIED ET_GOOD_CELLS.

    METHODS: HANDLE_DATA_CHANGED_FINISHED16
            FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
                IMPORTING E_MODIFIED ET_GOOD_CELLS.

    METHODS: HANDLE_DATA_CHANGED_1022
                FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
                IMPORTING ER_DATA_CHANGED .

    METHODS: HANDLE_HOTSPOT_CLICK_5
                FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
                IMPORTING E_ROW_ID
                          E_COLUMN_ID.

    METHODS: HANDLE_HOTSPOT_CLICK_6
                FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
                IMPORTING E_ROW_ID
                          E_COLUMN_ID.

    METHODS: HANDLE_HOTSPOT_CLICK_910
                FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
                IMPORTING E_ROW_ID
                          E_COLUMN_ID.

    METHODS: HANDLE_HOTSPOT_CLICK_1210
                FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
                IMPORTING E_ROW_ID
                          E_COLUMN_ID.
*
    METHODS: HANDLE_DOUBLE_CLICK
                FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
                IMPORTING E_ROW
                          E_COLUMN.

    METHODS: HANDLE_ONF4_1 FOR EVENT ONF4 OF CL_GUI_ALV_GRID
                IMPORTING SENDER
                          E_FIELDNAME
                          E_FIELDVALUE
                          ES_ROW_NO
                          ER_EVENT_DATA
                          ET_BAD_CELLS
                          E_DISPLAY.

    METHODS: HANDLE_ONF4_15 FOR EVENT ONF4 OF CL_GUI_ALV_GRID
                IMPORTING SENDER
                          E_FIELDNAME
                          E_FIELDVALUE
                          ES_ROW_NO
                          ER_EVENT_DATA
                          ET_BAD_CELLS
                          E_DISPLAY.

    METHODS: HANDLE_ONF4_16 FOR EVENT ONF4 OF CL_GUI_ALV_GRID
                IMPORTING SENDER
                          E_FIELDNAME
                          E_FIELDVALUE
                          ES_ROW_NO
                          ER_EVENT_DATA
                          ET_BAD_CELLS
                          E_DISPLAY.

ENDCLASS.  "(LCL_EVENT_HANDLER DEFINITION)

************************************************************************
* LOCAL CLASSES: Implementation
************************************************************************
*&---------------------------------------------------------------------*
*&       Class (Implementation)  LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

  METHOD HANDLE_NODE_DOUBLE_CLICK.
    PERFORM SET_SUBSCREEN USING NODE_KEY.  "TEXT.
  ENDMETHOD.   "HANDLE_NODE_DOUBLE_CLICK

  METHOD HANDLE_SELECTION_CHANGED.
    PERFORM SET_SUBSCREEN USING NODE_KEY.  "TEXT.
  ENDMETHOD.   "HANDLE_SELECTION_CHANGED

  METHOD HANDLE_NODE_CM_REQUEST.

*    CALL METHOD MENU->CLEAR.
*
*    CALL METHOD MENU->ADD_FUNCTION
*      EXPORTING
*        FCODE = 'LIST'
*        TEXT  = '조회하기'.

  ENDMETHOD.                    "HANDLE_NODE_CM_REQUEST

  METHOD HANDLE_NODE_CM_SEL.

*    CLEAR : GV_CHECK1, GV_CHECK.

*    CASE FCODE.

*      WHEN 'LIST'.
*         PERFORM GET_DATA_PALIST USING NODE_KEY.
*     ENDCASE.

*    OK_CODE = 'ENTR'.

  ENDMETHOD.                    "HANDLE_NODE_CM_SEL


ENDCLASS.               "LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&       Class (Implementation)  LCL_EVENT_HANDLER1
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER_1 IMPLEMENTATION.

*-- ToolBar 버튼생성
  METHOD HANDLE_TOOLBAR.
    PERFORM TOOLBAR_PROS  USING E_OBJECT E_INTERACTIVE.
  ENDMETHOD.                    "handle_toolbar

  METHOD HANDLE_TOOLBAR_1.
*    PERFORM TOOLBAR_PROS_1  USING E_OBJECT E_INTERACTIVE.
  ENDMETHOD.                    "handle_toolbar

  METHOD HANDLE_TOOLBAR_6.
    PERFORM TOOLBAR_PROS_6  USING E_OBJECT E_INTERACTIVE.
  ENDMETHOD.                    "handle_toolbar

*-- ToolBar 버튼생성
  METHOD HANDLE_TOOLBAR_15.
*    PERFORM TOOLBAR_PROS_15  USING E_OBJECT E_INTERACTIVE.
  ENDMETHOD.                    "handle_toolbar

*-- ToolBar 버튼생성
  METHOD HANDLE_TOOLBAR_16.
*    PERFORM TOOLBAR_PROS_16  USING E_OBJECT E_INTERACTIVE.
  ENDMETHOD.                    "HANDLE_TOOLBAR_16

*-- ToolBar에 생성된 버튼(Function)들에 대해서 처리
  METHOD HANDLE_USER_COMMAND.
*    PERFORM user_command_pros USING e_ucomm.
  ENDMETHOD.                    "handle_user_command

*-- ToolBar에 생성된 버튼(Function)들에 대해서 처리
  METHOD HANDLE_USER_COMMAND_1.
*    PERFORM USER_COMMAND_PROS_1 USING E_UCOMM.
  ENDMETHOD.                    "handle_user_command

*-- ToolBar에 생성된 버튼(Function)들에 대해서 처리
  METHOD HANDLE_USER_COMMAND_6.
    PERFORM USER_COMMAND_PROS_6 USING E_UCOMM.
  ENDMETHOD.                    "handle_user_command

*-- ToolBar에 생성된 버튼(Function)들에 대해서 처리
  METHOD HANDLE_USER_COMMAND_15.
*    PERFORM USER_COMMAND_PROS_15 USING E_UCOMM.
  ENDMETHOD.                    "handle_user_command

*-- ToolBar에 생성된 버튼(Function)들에 대해서 처리
  METHOD HANDLE_USER_COMMAND_16.
*    PERFORM USER_COMMAND_PROS_16 USING E_UCOMM.
  ENDMETHOD.                    "HANDLE_USER_COMMAND_16

  METHOD HANDLE_USER_COMMAND_5.
*    PERFORM user_command_pros_5 USING E_UCOMM.
  ENDMETHOD.                    "handle_user_command
*-- ToolBar 버튼생성
  METHOD HANDLE_TOOLBAR101.
*    PERFORM toolbar_pros101  USING e_object e_interactive.
  ENDMETHOD.                    "handle_toolbar

*-- ToolBar에 생성된 버튼(Function)들에 대해서 처리
  METHOD HANDLE_USER_COMMAND101.
*    PERFORM user_command_pros101 USING e_ucomm.
  ENDMETHOD.                    "handle_user_command
*  METHOD HANDLE_AFTER_USER_COMMAND.
*    PERFORM AFTER_USER_COMMAND USING E_UCOMM.
*  ENDMETHOD.                    "HANDLE_AFTER_USER_COMMAND
*
  METHOD HANDLE_DATA_CHANGED_1.
    PERFORM DATA_CHANGED_1  USING ER_DATA_CHANGED.
  ENDMETHOD.                    "handle_data_changed
  METHOD HANDLE_DATA_CHANGED_2.
    PERFORM DATA_CHANGED_2  USING ER_DATA_CHANGED.
  ENDMETHOD.                    "handle_data_changed

  METHOD HANDLE_DATA_CHANGED_15.
*    PERFORM DATA_CHANGED_15  USING ER_DATA_CHANGED.
  ENDMETHOD.                    "handle_data_changed

  METHOD HANDLE_DATA_CHANGED_16.
    PERFORM DATA_CHANGED_16  USING ER_DATA_CHANGED.
  ENDMETHOD.                    "handle_data_changed

  METHOD HANDLE_DATA_CHANGED_5.
    PERFORM DATA_CHANGED_5  USING ER_DATA_CHANGED.
  ENDMETHOD.                    "handle_data_changed_5

  METHOD HANDLE_DATA_CHANGED_7.
    PERFORM DATA_CHANGED_7  USING ER_DATA_CHANGED.
  ENDMETHOD.                    "handle_data_changed_5

  METHOD HANDLE_DATA_CHANGED_910.
    PERFORM DATA_CHANGED_910  USING ER_DATA_CHANGED.
  ENDMETHOD.                    "handle_data_changed_910

    METHOD HANDLE_DATA_CHANGED_960.
    PERFORM DATA_CHANGED_960  USING ER_DATA_CHANGED.
  ENDMETHOD.                    "handle_data_changed_910

  METHOD HANDLE_DATA_CHANGED_3.
    PERFORM DATA_CHANGED3  USING ER_DATA_CHANGED.
  ENDMETHOD.                    "handle_data_changed
  METHOD HANDLE_DATA_CHANGED_FINISHED_1.
*    PERFORM  pro_data_changed_finished_1 USING et_good_cells e_modified.
  ENDMETHOD.                    "handle_data_changed_finished

  METHOD HANDLE_DATA_CHANGED_FINISHED_5.
*    PERFORM  pro_data_changed_finished_5 USING et_good_cells e_modified.
  ENDMETHOD.                    "handle_data_changed_finished

  METHOD HANDLE_DATA_CHANGED_FINISHED16.
*    PERFORM  pro_data_changed_finished_16 USING et_good_cells e_modified.
  ENDMETHOD.                    "handle_data_changed_finished

  METHOD HANDLE_DATA_CHANGED_1022.
*    PERFORM data_changed  USING er_data_changed.
  ENDMETHOD.                    "handle_data_changed

  METHOD HANDLE_HOTSPOT_CLICK_1.
    PERFORM HOTSPOT_CLICK_1 USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK_1

  METHOD HANDLE_HOTSPOT_CLICK_15.
*    PERFORM HOTSPOT_CLICK_15 USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK_15

  METHOD HANDLE_HOTSPOT_CLICK_16.
*    PERFORM HOTSPOT_CLICK_15 USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK_15

  METHOD HANDLE_HOTSPOT_CLICK_2.
*    PERFORM HOTSPOT_CLICK_5 USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "handle_hotspot_click

  METHOD HANDLE_HOTSPOT_CLICK_3.
    PERFORM HOTSPOT_CLICK_3 USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "handle_hotspot_click

  METHOD HANDLE_HOTSPOT_CLICK_5.
    PERFORM HOTSPOT_CLICK_5 USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "handle_hotspot_click
  METHOD HANDLE_HOTSPOT_CLICK_6.
    PERFORM HOTSPOT_CLICK_6 USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "handle_hotspot_click
  METHOD HANDLE_HOTSPOT_CLICK_7.
    PERFORM HOTSPOT_CLICK_7 USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "handle_hotspot_click

  METHOD HANDLE_HOTSPOT_CLICK_910.
    PERFORM HOTSPOT_CLICK_910 USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK_910

  METHOD HANDLE_HOTSPOT_CLICK_1210.
    PERFORM HOTSPOT_CLICK_1210 USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK_910
*
  METHOD HANDLE_DOUBLE_CLICK.
*    PERFORM double_click  USING e_row e_column.
  ENDMETHOD.    "handle_double_click

  METHOD HANDLE_ONF4_1.
*    PERFORM ON_F4_1 USING SENDER
*                        E_FIELDNAME
*                        E_FIELDVALUE
*                        ES_ROW_NO
*                        ER_EVENT_DATA
*                        ET_BAD_CELLS
*                        E_DISPLAY.
  ENDMETHOD.    "handle_double_click

  METHOD HANDLE_ONF4_15.
*    PERFORM ON_F4_15 USING SENDER
*                        E_FIELDNAME
*                        E_FIELDVALUE
*                        ES_ROW_NO
*                        ER_EVENT_DATA
*                        ET_BAD_CELLS
*                        E_DISPLAY.
  ENDMETHOD.    "handle_double_click

  METHOD HANDLE_ONF4_16.
*    PERFORM ON_F4_16 USING SENDER
*                        E_FIELDNAME
*                        E_FIELDVALUE
*                        ES_ROW_NO
*                        ER_EVENT_DATA
*                        ET_BAD_CELLS
*                        E_DISPLAY.
  ENDMETHOD.    "handle_double_click

ENDCLASS. "LCL_EVENT_HANDLER_1 IMPLEMENTATION
*---------------------------------------------------------------------*
*       CLASS lcl_def_grid1 DEFINITION
*---------------------------------------------------------------------*
CLASS LCL_DEF_GRID DEFINITION INHERITING FROM CL_GUI_ALV_GRID.

  PUBLIC SECTION.
    METHODS : U_SET_FIXED_ROWS,
              U_SET_RESIZE_COLS,
              U_SCROLL_TO_BOTTOM,
              U_SET_OPTIMIZE,
              U_SET_CURRENT_CELL_BASE
                  IMPORTING
                      ROW TYPE I
                      COL TYPE I.

ENDCLASS.                    "lcl_def_grid DEFINITION
*---------------------------------------------------------------------*
*       CLASS lcl_def_grid IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS LCL_DEF_GRID IMPLEMENTATION.

  METHOD  U_SET_FIXED_ROWS.
    CALL METHOD ME->SET_FIXED_ROWS
      EXPORTING
        ROWS = 1.
  ENDMETHOD.                    " U_SET_FIXED_ROWS

  METHOD  U_SET_RESIZE_COLS.
    CALL METHOD ME->SET_RESIZE_COLS
      EXPORTING
        ENABLE = 1.   " NO
  ENDMETHOD.                    " U_SET_RESIZE_COLS

  METHOD  U_SCROLL_TO_BOTTOM.
    CALL METHOD ME->SCROLL_TO_BOTTOM.
  ENDMETHOD.                    " U_SCROLL_TO_BOTTOM

  METHOD  U_SET_CURRENT_CELL_BASE.
    CALL METHOD ME->SET_CURRENT_CELL_BASE
      EXPORTING
        ROW = ROW
        COL = COL.
  ENDMETHOD.                    " U_SET_CURRENT_CELL_BASE

  METHOD U_SET_OPTIMIZE.
    CALL METHOD ME->OPTIMIZE_ALL_COLS
      EXPORTING
        INCLUDE_HEADER = 1.
  ENDMETHOD.                    " U_set_optimize

ENDCLASS.                    " lcl_def_grid IMPLEMENTATION
