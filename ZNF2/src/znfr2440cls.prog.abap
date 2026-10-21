*&---------------------------------------------------------------------*
*&  Include           ZNFR2440CLS
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

    METHODS : HANDLE_DATA_CHANGED_FINISHED_1
                 FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
                 IMPORTING E_MODIFIED
                           ET_GOOD_CELLS.

    METHODS : HANDLE_DATA_CHANGED_FINISHED_2
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
*    perform data_changed  using er_data_changed e_onf4 e_ucomm.
  ENDMETHOD.                    "handle_data_changed

*-- Data change한 후
  METHOD HANDLE_DATA_CHANGED_FINISHED_1.
    PERFORM DATA_CHANGED_FINISHED USING '1'
                                        E_MODIFIED
                                        ET_GOOD_CELLS.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED_1

  METHOD HANDLE_DATA_CHANGED_FINISHED_2.
    PERFORM DATA_CHANGED_FINISHED USING '2'
                                        E_MODIFIED
                                        ET_GOOD_CELLS.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED_1

*-- Hotspot click
  METHOD HANDLE_HOTSPOT_CLICK.
*    perform hotspot_click using e_row_id e_column_id.
  ENDMETHOD.                    "handle_hotspot_click

*-- Double Click
  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM DOUBLE_CLICK  USING E_ROW E_COLUMN.
  ENDMETHOD.    "handle_double_click

*-- On help f4 - Search Help
  METHOD HANDLE_ONF4.
*    PERFORM ON_F4 USING SENDER
*                        E_FIELDNAME
*                        E_FIELDVALUE
*                        ES_ROW_NO
*                        ER_EVENT_DATA
*                        ET_BAD_CELLS
*                        E_DISPLAY.
  ENDMETHOD.                    "HANDLE_ONF4

ENDCLASS. "LCL_EVENT_RECEIVER IMPLEMENTATION
