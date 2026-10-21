*&---------------------------------------------------------------------*
*& Include          ZGTMMR4130C01
*&---------------------------------------------------------------------*
************************************************************************
* LOCAL CLASSES: Definition
************************************************************************
CLASS LCL_ALV_GRID DEFINITION INHERITING FROM CL_GUI_ALV_GRID.

  PUBLIC SECTION.
    CLASS-DATA F_ALV  TYPE C.
    METHODS: SET_OPTIMIZE_ALL_COLS,
      SET_CURSOR IMPORTING ROW TYPE I
                           COL TYPE I,
      SET_FIXED_COLUMN,
      SET_ROW_RESIZE.

ENDCLASS.                    "LCL_ALV_GRID DEFINITION
*---------------------------------------------------------------------*
*       CLASS LCL_ALV_GRID IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS LCL_ALV_GRID IMPLEMENTATION.

  METHOD SET_OPTIMIZE_ALL_COLS.
    CALL METHOD ME->OPTIMIZE_ALL_COLS
      EXPORTING
        INCLUDE_HEADER = 1.
  ENDMETHOD.                    "SET_OPTIMIZE_ALL_COLS

  METHOD SET_CURSOR.
    CALL METHOD ME->SET_CURRENT_CELL_BASE
      EXPORTING
        ROW = ROW
        COL = COL.
  ENDMETHOD.                    "SET_CURSOR

  METHOD SET_FIXED_COLUMN.
    CALL METHOD ME->SET_FIXED_COLS
      EXPORTING
        COLS = 5.
  ENDMETHOD.                    "SET_FIXED_COLUMN

  METHOD SET_ROW_RESIZE.
    CALL METHOD ME->SET_RESIZE_ROWS
      EXPORTING
        ENABLE = 1.
  ENDMETHOD.                    "SET_ROW_RESIZE

ENDCLASS.                    "LCL_ALV_GRID IMPLEMENTATION
*---------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER DEFINITION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.
  PUBLIC SECTION.
    METHODS : HANDLE_TOOLBAR
      FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT E_INTERACTIVE.

    METHODS : HANDLE_USER_COMMAND
      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM.

    METHODS : HANDLE_AFTER_USER_COMMAND
      FOR EVENT AFTER_USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM .

    METHODS : HANDLE_DATA_CHANGED
      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING ER_DATA_CHANGED E_ONF4.

    METHODS : HANDLE_DATA_CHANGED_FINISHED
      FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED
                ET_GOOD_CELLS.

    METHODS : HANDLE_HOTSPOT_CLICK
      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID
                E_COLUMN_ID.

    METHODS : HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW
                E_COLUMN.

    METHODS : HANDLE_BUTTON_CLICK
      FOR EVENT BUTTON_CLICK OF CL_GUI_ALV_GRID
      IMPORTING ES_COL_ID
                ES_ROW_NO.

    METHODS : HANDLE_ONF4
      FOR EVENT ONF4 OF CL_GUI_ALV_GRID
      IMPORTING E_FIELDNAME
                E_FIELDVALUE
                ES_ROW_NO
                ER_EVENT_DATA
                ET_BAD_CELLS
                E_DISPLAY.

ENDCLASS.  "(LCL_EVENT_RECEIVER DEFINITION)

****************************************************************
* LOCAL CLASSES: Implementation
****************************************************************
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

*& ToolBar 버튼생성
  METHOD HANDLE_TOOLBAR.
    PERFORM TOOLBAR_PROS  USING E_OBJECT E_INTERACTIVE.
  ENDMETHOD.                    "handle_toolbar

*& ToolBar에 생성된 버튼(Function)들에 대해서 처리
  METHOD HANDLE_USER_COMMAND.
    PERFORM USER_COMMAND_PROS USING E_UCOMM.
  ENDMETHOD.                    "handle_user_command

*& Event 처리후
  METHOD HANDLE_AFTER_USER_COMMAND.
    PERFORM AFTER_USER_COMMAND USING E_UCOMM.
  ENDMETHOD.                    "HANDLE_AFTER_USER_COMMAND

*& Data change할때
  METHOD HANDLE_DATA_CHANGED.
    PERFORM DATA_CHANGED  USING ER_DATA_CHANGED
                                E_ONF4.
  ENDMETHOD.                    "handle_data_changed

*& Data change한 후
  METHOD HANDLE_DATA_CHANGED_FINISHED.
    PERFORM DATA_CHANGED_FINISHED USING E_MODIFIED
                                        ET_GOOD_CELLS.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED

*& Hotspot click
  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM HOTSPOT_CLICK USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "handle_hotspot_click

*& Double Click
  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM DOUBLE_CLICK  USING E_ROW E_COLUMN.
  ENDMETHOD.    "handle_double_click

*& Button Click
  METHOD HANDLE_BUTTON_CLICK.
    PERFORM BUTTON_CLICK  USING ES_COL_ID ES_ROW_NO.
  ENDMETHOD.    "handle_button_click

*& F4 도움말 처리
  METHOD HANDLE_ONF4.
    PERFORM  ONF4_PROC USING E_FIELDNAME   E_FIELDVALUE
                             ES_ROW_NO     ER_EVENT_DATA
                             ET_BAD_CELLS  E_DISPLAY.

  ENDMETHOD.                    "handle_on_entered

ENDCLASS. "LCL_EVENT_RECEIVER IMPLEMENTATION

*---------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER_L DEFINITION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER_L DEFINITION.
  PUBLIC SECTION.
    METHODS : HANDLE_TOOLBAR
      FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT E_INTERACTIVE.

    METHODS : HANDLE_USER_COMMAND
      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM.

    METHODS : HANDLE_AFTER_USER_COMMAND
      FOR EVENT AFTER_USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM .

    METHODS : HANDLE_DATA_CHANGED
      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING ER_DATA_CHANGED E_ONF4.

    METHODS : HANDLE_DATA_CHANGED_FINISHED
      FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED
                ET_GOOD_CELLS.

    METHODS : HANDLE_HOTSPOT_CLICK
      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID
                E_COLUMN_ID.

    METHODS : HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW
                E_COLUMN.

    METHODS : HANDLE_BUTTON_CLICK
      FOR EVENT BUTTON_CLICK OF CL_GUI_ALV_GRID
      IMPORTING ES_COL_ID
                ES_ROW_NO.

    METHODS : HANDLE_ONF4
      FOR EVENT ONF4 OF CL_GUI_ALV_GRID
      IMPORTING E_FIELDNAME
                E_FIELDVALUE
                ES_ROW_NO
                ER_EVENT_DATA
                ET_BAD_CELLS
                E_DISPLAY.

ENDCLASS.  "(LCL_EVENT_RECEIVER_L DEFINITION)

****************************************************************
* LOCAL CLASSES: Implementation
****************************************************************
CLASS LCL_EVENT_HANDLER_L IMPLEMENTATION.

*& ToolBar 버튼생성
  METHOD HANDLE_TOOLBAR.
    PERFORM TOOLBAR_PROS_L  USING E_OBJECT E_INTERACTIVE.
  ENDMETHOD.                    "handle_toolbar

*& ToolBar에 생성된 버튼(Function)들에 대해서 처리
  METHOD HANDLE_USER_COMMAND.
    PERFORM USER_COMMAND_PROS_L USING E_UCOMM.
  ENDMETHOD.                    "handle_user_command

*& Event 처리후
  METHOD HANDLE_AFTER_USER_COMMAND.
    PERFORM AFTER_USER_COMMAND_L USING E_UCOMM.
  ENDMETHOD.                    "HANDLE_AFTER_USER_COMMAND

*& Data change할때
  METHOD HANDLE_DATA_CHANGED.
    PERFORM DATA_CHANGED_L  USING ER_DATA_CHANGED
                                  E_ONF4.
  ENDMETHOD.                    "handle_data_changed

*& Data change한 후
  METHOD HANDLE_DATA_CHANGED_FINISHED.
    PERFORM DATA_CHANGED_FINISHED_L USING E_MODIFIED
                                          ET_GOOD_CELLS.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED

*& Hotspot click
  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM HOTSPOT_CLICK_L USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "handle_hotspot_click

*& Double Click
  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM DOUBLE_CLICK_L  USING E_ROW E_COLUMN.
  ENDMETHOD.    "handle_double_click

*& Button Click
  METHOD HANDLE_BUTTON_CLICK.
    PERFORM BUTTON_CLICK_L  USING ES_COL_ID ES_ROW_NO.
  ENDMETHOD.    "handle_button_click

*& F4 도움말 처리
  METHOD HANDLE_ONF4.
    PERFORM ONF4_PROC_L USING E_FIELDNAME   E_FIELDVALUE
                              ES_ROW_NO     ER_EVENT_DATA
                              ET_BAD_CELLS  E_DISPLAY.

  ENDMETHOD.                    "handle_on_entered

ENDCLASS. "LCL_EVENT_RECEIVER_L IMPLEMENTATION

*---------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER_W1 DEFINITION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER_W1 DEFINITION.
  PUBLIC SECTION.
    METHODS : HANDLE_TOOLBAR
      FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT E_INTERACTIVE.

    METHODS : HANDLE_USER_COMMAND
      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM.

    METHODS : HANDLE_AFTER_USER_COMMAND
      FOR EVENT AFTER_USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM .

    METHODS : HANDLE_DATA_CHANGED
      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING ER_DATA_CHANGED E_ONF4.

    METHODS : HANDLE_DATA_CHANGED_FINISHED
      FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED
                ET_GOOD_CELLS.

    METHODS : HANDLE_HOTSPOT_CLICK
      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID
                E_COLUMN_ID.

    METHODS : HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW
                E_COLUMN.

    METHODS : HANDLE_BUTTON_CLICK
      FOR EVENT BUTTON_CLICK OF CL_GUI_ALV_GRID
      IMPORTING ES_COL_ID
                ES_ROW_NO.

ENDCLASS.  "(LCL_EVENT_RECEIVER_W1 DEFINITION)

****************************************************************
* LOCAL CLASSES: Implementation
****************************************************************
CLASS LCL_EVENT_HANDLER_W1 IMPLEMENTATION.

*& ToolBar 버튼생성
  METHOD HANDLE_TOOLBAR.
    PERFORM TOOLBAR_PROS_W1  USING E_OBJECT E_INTERACTIVE.
  ENDMETHOD.                    "handle_toolbar

*& ToolBar에 생성된 버튼(Function)들에 대해서 처리
  METHOD HANDLE_USER_COMMAND.
    PERFORM USER_COMMAND_PROS_W1 USING E_UCOMM.
  ENDMETHOD.                    "handle_user_command

*& Event 처리후
  METHOD HANDLE_AFTER_USER_COMMAND.
    PERFORM AFTER_USER_COMMAND_W1 USING E_UCOMM.
  ENDMETHOD.                    "HANDLE_AFTER_USER_COMMAND

*& Data change할때
  METHOD HANDLE_DATA_CHANGED.
    PERFORM DATA_CHANGED_W1  USING ER_DATA_CHANGED
                                E_ONF4.
  ENDMETHOD.                    "handle_data_changed

*& Data change한 후
  METHOD HANDLE_DATA_CHANGED_FINISHED.
    PERFORM DATA_CHANGED_FINISHED_W1 USING E_MODIFIED
                                        ET_GOOD_CELLS.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED

*& Hotspot click
  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM HOTSPOT_CLICK_W1 USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "handle_hotspot_click

*& Double Click
  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM DOUBLE_CLICK_W1  USING E_ROW E_COLUMN.
  ENDMETHOD.    "handle_double_click

*& Button Click
  METHOD HANDLE_BUTTON_CLICK.
    PERFORM BUTTON_CLICK_W1  USING ES_COL_ID ES_ROW_NO.
  ENDMETHOD.    "handle_button_click


ENDCLASS. "LCL_EVENT_RECEIVER_W1 IMPLEMENTATION

*---------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER_W2 DEFINITION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER_W2 DEFINITION.
  PUBLIC SECTION.
    METHODS : HANDLE_TOOLBAR
      FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT E_INTERACTIVE.

    METHODS : HANDLE_USER_COMMAND
      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM.

    METHODS : HANDLE_AFTER_USER_COMMAND
      FOR EVENT AFTER_USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM .

    METHODS : HANDLE_DATA_CHANGED
      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING ER_DATA_CHANGED E_ONF4.

    METHODS : HANDLE_DATA_CHANGED_FINISHED
      FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED
                ET_GOOD_CELLS.

    METHODS : HANDLE_HOTSPOT_CLICK
      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID
                E_COLUMN_ID.

    METHODS : HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW
                E_COLUMN.

    METHODS : HANDLE_BUTTON_CLICK
      FOR EVENT BUTTON_CLICK OF CL_GUI_ALV_GRID
      IMPORTING ES_COL_ID
                ES_ROW_NO.

    METHODS : HANDLE_ONF4
      FOR EVENT ONF4 OF CL_GUI_ALV_GRID
      IMPORTING E_FIELDNAME
                E_FIELDVALUE
                ES_ROW_NO
                ER_EVENT_DATA
                ET_BAD_CELLS
                E_DISPLAY.

ENDCLASS.  "(LCL_EVENT_RECEIVER_W2 DEFINITION)

****************************************************************
* LOCAL CLASSES: Implementation
****************************************************************
CLASS LCL_EVENT_HANDLER_W2 IMPLEMENTATION.

*& ToolBar 버튼생성
  METHOD HANDLE_TOOLBAR.
    PERFORM TOOLBAR_PROS_W2  USING E_OBJECT E_INTERACTIVE.
  ENDMETHOD.                    "handle_toolbar

*& ToolBar에 생성된 버튼(Function)들에 대해서 처리
  METHOD HANDLE_USER_COMMAND.
    PERFORM USER_COMMAND_PROS_W2 USING E_UCOMM.
  ENDMETHOD.                    "handle_user_command

*& Event 처리후
  METHOD HANDLE_AFTER_USER_COMMAND.
    PERFORM AFTER_USER_COMMAND_W2 USING E_UCOMM.
  ENDMETHOD.                    "HANDLE_AFTER_USER_COMMAND

*& Data change할때
  METHOD HANDLE_DATA_CHANGED.
    PERFORM DATA_CHANGED_W2  USING ER_DATA_CHANGED
                                E_ONF4.
  ENDMETHOD.                    "handle_data_changed

*& Data change한 후
  METHOD HANDLE_DATA_CHANGED_FINISHED.
    PERFORM DATA_CHANGED_FINISHED_W2 USING E_MODIFIED
                                        ET_GOOD_CELLS.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED

*& Hotspot click
  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM HOTSPOT_CLICK_W2 USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "handle_hotspot_click

*& Double Click
  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM DOUBLE_CLICK_W2  USING E_ROW E_COLUMN.
  ENDMETHOD.    "handle_double_click

*& Button Click
  METHOD HANDLE_BUTTON_CLICK.
    PERFORM BUTTON_CLICK_W2  USING ES_COL_ID ES_ROW_NO.
  ENDMETHOD.    "handle_button_click

*& F4 도움말 처리
  METHOD HANDLE_ONF4.
    PERFORM ONF4_PROC_W2 USING E_FIELDNAME   E_FIELDVALUE
                              ES_ROW_NO     ER_EVENT_DATA
                              ET_BAD_CELLS  E_DISPLAY.

  ENDMETHOD.                    "handle_on_entered


ENDCLASS. "LCL_EVENT_RECEIVER_W2 IMPLEMENTATION
