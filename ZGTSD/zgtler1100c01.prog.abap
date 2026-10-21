*&---------------------------------------------------------------------*
*&  Include           ZLER0401CLS
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER DEFINITION
*----------------------------------------------------------------------*
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
                 IMPORTING ER_DATA_CHANGED E_ONF4 E_UCOMM.

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

    METHODS : HANDLE_DOUBLE_CLICK1
                 FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
                 IMPORTING E_ROW
                           E_COLUMN.

    METHODS : HANDLE_ONF4 FOR EVENT ONF4 OF CL_GUI_ALV_GRID
                  IMPORTING SENDER
                            E_FIELDNAME
                            E_FIELDVALUE
                            ES_ROW_NO
                            ER_EVENT_DATA
                            ET_BAD_CELLS
                            E_DISPLAY.

ENDCLASS.  "(LCL_EVENT_RECEIVER DEFINITION)

*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

*-- ToolBar 버튼생성
  METHOD HANDLE_TOOLBAR.
*    PERFORM TOOLBAR_PROS  USING E_OBJECT E_INTERACTIVE.
  ENDMETHOD.                    "handle_toolbar

*-- ToolBar에 생성된 버튼(Function)들에 대해서 처리
  METHOD HANDLE_USER_COMMAND.
*    PERFORM USER_COMMAND_PROS USING E_UCOMM.
  ENDMETHOD.                    "handle_user_command

*-- Event 처리후
  METHOD HANDLE_AFTER_USER_COMMAND.
*    perform after_user_command using e_ucomm.
  ENDMETHOD.                    "HANDLE_AFTER_USER_COMMAND

*-- Data change할때
  METHOD HANDLE_DATA_CHANGED.
    PERFORM DATA_CHANGED  USING ER_DATA_CHANGED E_ONF4 E_UCOMM.
  ENDMETHOD.                    "handle_data_changed

*-- Data change한 후
  METHOD HANDLE_DATA_CHANGED_FINISHED.
    PERFORM DATA_CHANGED_FINISHED USING E_MODIFIED
                                        ET_GOOD_CELLS.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED

*-- Hotspot click
  METHOD HANDLE_HOTSPOT_CLICK.
*    PERFORM HOTSPOT_CLICK USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "handle_hotspot_click

*-- Double Click
  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM DOUBLE_CLICK  USING '1' E_ROW E_COLUMN.
  ENDMETHOD.    "handle_double_click

  METHOD HANDLE_DOUBLE_CLICK1.
    PERFORM DOUBLE_CLICK  USING '2' E_ROW E_COLUMN.
  ENDMETHOD.    "handle_double_click1

*-- On help f4 - Search Help
  METHOD HANDLE_ONF4.
*    perform on_f4 using sender
*                        e_fieldname
*                        e_fieldvalue
*                        es_row_no
*                        er_event_data
*                        et_bad_cells
*                        e_display.
  ENDMETHOD.                    "HANDLE_ONF4

ENDCLASS. "LCL_EVENT_RECEIVER IMPLEMENTATION
