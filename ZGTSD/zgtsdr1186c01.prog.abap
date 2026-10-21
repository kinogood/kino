*&---------------------------------------------------------------------*
*& Include          ZGTSDR1186C01
*&---------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION DEFERRED.
DATA: g_event_receiver   TYPE REF TO lcl_event_receiver.
*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    DATA: ucomm TYPE sy-ucomm.
    METHODS handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm sender.

    METHODS handle_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row e_column es_row_no.

    METHODS handle_before_user_command
      FOR EVENT before_user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.

    METHODS handle_toolbar
      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object e_interactive.

ENDCLASS.                    "lcl_event_receiver DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_receiver IMPLEMENTATION.
  METHOD handle_before_user_command.
    PERFORM before_user_command USING e_ucomm.
  ENDMETHOD.                    "handle_before_user_command

  METHOD handle_user_command.
    CASE e_ucomm.
      WHEN 'TRAN'.
        PERFORM get_selected_rows.

        PERFORM transfer_data.

        CALL METHOD g_grid_head->refresh_table_display
          EXPORTING
            i_soft_refresh = 'X'.

      WHEN 'ITEM'.

        PERFORM get_selected_rows.

        PERFORM get_selected_item.

        CALL METHOD g_grid_item->refresh_table_display
          EXPORTING
            i_soft_refresh = 'X'.

      WHEN 'VBRK'.

        PERFORM get_selected_rows.

        PERFORM disp_zsdt0022_data.

      WHEN 'REFR'.
        PERFORM refresh_data.

        CALL METHOD g_grid_head->refresh_table_display
          EXPORTING
            i_soft_refresh = 'X'.
        CALL METHOD g_grid_item->refresh_table_display
          EXPORTING
            i_soft_refresh = 'X'.
    ENDCASE.

  ENDMETHOD.                    "handle_user_command

  METHOD handle_double_click.

    PERFORM double_click USING e_row
                               e_column
                               es_row_no.

  ENDMETHOD.                    "handle_double_click

  METHOD handle_toolbar.
    CLEAR gs_toolbar.
    MOVE 3 TO gs_toolbar-butn_type.
    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    MOVE 'REFR'         TO gs_toolbar-function.
    MOVE '@42@'         TO gs_toolbar-icon.
    MOVE '새로고침'     TO gs_toolbar-quickinfo.
    MOVE ' '            TO gs_toolbar-text.
    MOVE 0 TO gs_toolbar-butn_type.
    MOVE space TO gs_toolbar-disabled.
    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    MOVE 3 TO gs_toolbar-butn_type.
    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    MOVE 'TRAN'         TO gs_toolbar-function.
    MOVE ' '            TO gs_toolbar-icon.
    MOVE '수작업전송'   TO gs_toolbar-quickinfo.
    MOVE '수작업전송'   TO gs_toolbar-text.
    MOVE 0 TO gs_toolbar-butn_type.
    MOVE space TO gs_toolbar-disabled.
    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    MOVE 'ITEM'         TO gs_toolbar-function.
    MOVE ' '            TO gs_toolbar-icon.
    MOVE '품목조회'   TO gs_toolbar-quickinfo.
    MOVE '품목조회'   TO gs_toolbar-text.
    MOVE 0 TO gs_toolbar-butn_type.
    MOVE space TO gs_toolbar-disabled.
    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    MOVE 'VBRK'       TO gs_toolbar-function.
    MOVE ' '          TO gs_toolbar-icon.
    MOVE '전송대상조회'   TO gs_toolbar-quickinfo.
    MOVE '전송대상조회'   TO gs_toolbar-text.
    MOVE 0 TO gs_toolbar-butn_type.
    MOVE space TO gs_toolbar-disabled.
    APPEND gs_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.                    "handle_toolbar
ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION
