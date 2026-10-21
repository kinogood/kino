*&---------------------------------------------------------------------*
*& Include          ZGTPPR3010C01
*&---------------------------------------------------------------------*
************************************************************************
* LOCAL CLASSES: Definition
************************************************************************
CLASS lcl_alv_grid DEFINITION INHERITING FROM cl_gui_alv_grid.

  PUBLIC SECTION.
    CLASS-DATA f_alv  TYPE c.
    METHODS: set_optimize_all_cols,
      set_cursor IMPORTING row TYPE i
                           col TYPE i,
      set_fixed_column,
      set_row_resize.

ENDCLASS.                    "LCL_ALV_GRID DEFINITION
*---------------------------------------------------------------------*
*       CLASS LCL_ALV_GRID IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_alv_grid IMPLEMENTATION.

  METHOD set_optimize_all_cols.
    CALL METHOD me->optimize_all_cols
      EXPORTING
        include_header = 1.
  ENDMETHOD.                    "SET_OPTIMIZE_ALL_COLS

  METHOD set_cursor.
    CALL METHOD me->set_current_cell_base
      EXPORTING
        row = row
        col = col.
  ENDMETHOD.                    "SET_CURSOR

  METHOD set_fixed_column.
    CALL METHOD me->set_fixed_cols
      EXPORTING
        cols = 5.
  ENDMETHOD.                    "SET_FIXED_COLUMN

  METHOD set_row_resize.
    CALL METHOD me->set_resize_rows
      EXPORTING
        enable = 1.
  ENDMETHOD.                    "SET_ROW_RESIZE

ENDCLASS.                    "LCL_ALV_GRID IMPLEMENTATION
*---------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER DEFINITION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS : handle_toolbar
      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object e_interactive.

    METHODS : handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.

    METHODS : handle_after_user_command
      FOR EVENT after_user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm .

    METHODS : handle_data_changed
      FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed e_onf4.

    METHODS : handle_data_changed_finished
      FOR EVENT data_changed_finished OF cl_gui_alv_grid
      IMPORTING e_modified
                et_good_cells.

    METHODS : handle_hotspot_click
      FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING e_row_id
                e_column_id.

    METHODS : handle_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row
                e_column.

    METHODS : handle_button_click
      FOR EVENT button_click OF cl_gui_alv_grid
      IMPORTING es_col_id
                es_row_no.

    METHODS : handle_onf4
      FOR EVENT onf4 OF cl_gui_alv_grid
      IMPORTING e_fieldname
                e_fieldvalue
                es_row_no
                er_event_data
                et_bad_cells
                e_display.

ENDCLASS.  "(LCL_EVENT_RECEIVER DEFINITION)
****************************************************************
* LOCAL CLASSES: Implementation
****************************************************************
CLASS lcl_event_handler IMPLEMENTATION.

*& ToolBar 버튼생성
  METHOD handle_toolbar.
    PERFORM toolbar_proc  USING e_object e_interactive.
  ENDMETHOD.                    "handle_toolbar
*& ToolBar에 생성된 버튼(Function)들에 대해서 처리
  METHOD handle_user_command.
    PERFORM user_command_proc USING e_ucomm.
  ENDMETHOD.                    "handle_user_command
*& Event 처리후
  METHOD handle_after_user_command.
    PERFORM after_user_command USING e_ucomm.
  ENDMETHOD.                    "HANDLE_AFTER_USER_COMMAND
*& Data change할때
  METHOD handle_data_changed.
    PERFORM data_changed  USING er_data_changed
                                e_onf4.
  ENDMETHOD.                    "handle_data_changed
*& Data change한 후
  METHOD handle_data_changed_finished.
*    PERFORM data_changed_finished USING e_modified
*                                        et_good_cells.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED
*& Hotspot click
  METHOD handle_hotspot_click.
    PERFORM hotspot_click USING e_row_id e_column_id.
  ENDMETHOD.                    "handle_hotspot_click
*& Double Click
  METHOD handle_double_click.
    PERFORM double_click  USING e_row e_column.
  ENDMETHOD.    "handle_double_click
*& Button Click
  METHOD handle_button_click.
    PERFORM button_click  USING es_col_id es_row_no.
  ENDMETHOD.    "handle_button_click
*& F4 도움말 처리
  METHOD handle_onf4.
    PERFORM  onf4_proc USING e_fieldname   e_fieldvalue
                             es_row_no     er_event_data
                             et_bad_cells  e_display.

  ENDMETHOD.                    "handle_on_entered

ENDCLASS. "LCL_EVENT_RECEIVER IMPLEMENTATION
*&---------------------------------------------------------------------*
*& Form create_and_init_controls
*&---------------------------------------------------------------------*
*& ALV 셋팅
*&---------------------------------------------------------------------*
FORM create_and_init_controls .

  IF go_grid_0100 IS NOT BOUND.

    PERFORM set_object_grid_0100.
*& Edit Event 및  Event Handler 등록
    PERFORM event_handler_register USING go_grid_0100.
*& GRID 속성 지정(Display): Display시 옵션 지정
    PERFORM set_layout_grid_0100.
*& 출력할 필드 속성을 정의
    PERFORM set_fieldcat_grid_0100.

    PERFORM set_cell_attribute_grid_0100.

    PERFORM exclude_of_toolbar_grid_0100.

    PERFORM call_grid_0100_display.

  ENDIF.

ENDFORM.
