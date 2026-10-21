*&---------------------------------------------------------------------*
*& Include          ZGTPPR1120CLS
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*     lcl_alv_grid DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_alv_grid DEFINITION INHERITING FROM cl_gui_alv_grid.
  PUBLIC SECTION.
    METHODS: set_optimize_all_cols,
             set_cursor IMPORTING row  TYPE i
                                  col  TYPE i,
             set_fixed_column,
             set_row_resize.
ENDCLASS.                    "LCL_ALV_GRID DEFINITION

*----------------------------------------------------------------------*
*       CLASS LCL_ALV_GRID IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_alv_grid IMPLEMENTATION.
  METHOD set_optimize_all_cols.
    CALL METHOD me->optimize_all_cols
      EXPORTING
        include_header = 1.
  ENDMETHOD.                    " SET_OPTIMIZE_ALL_COLS
*
  METHOD set_cursor.
    CALL METHOD me->set_current_cell_base
      EXPORTING
        row = row
        col = col.
  ENDMETHOD.                    " SET_CURSOR
*
  METHOD set_fixed_column.
    CALL METHOD me->set_fixed_cols
      EXPORTING
        cols = 3.
  ENDMETHOD.                    " SET_FIXED_COLUMN
*
  METHOD set_row_resize.
    CALL METHOD me->set_resize_rows
      EXPORTING
        enable = 1.
  ENDMETHOD.                    " SET_ROW_RESIZE
ENDCLASS.                    " LCL_ALV_GRID IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS:
*& 값의 변경여부를 체크하고 변경된 값을 화면에 반영한다.
      handle_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
             IMPORTING
                  er_data_changed,
*& 툴바를 추가한다.
      handle_toolbar      FOR EVENT toolbar      OF cl_gui_alv_grid
             IMPORTING
                  e_object
                  e_interactive,
*& 버튼을 누르면 각각 작업을 수행한다.
      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
             IMPORTING
                  e_ucomm.

  PRIVATE SECTION.
    DATA: error_in_data     TYPE c.

    METHODS: check_changed_field
      IMPORTING
           ps_modified      TYPE lvc_s_modi
           pr_data_changed  TYPE REF TO cl_alv_changed_data_protocol.
ENDCLASS.                    "lcl_event_receiver DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_event_receiver IMPLEMENTATION.
  METHOD handle_data_changed.
    DATA: ls_modified          TYPE lvc_s_modi.

    CLEAR: error_in_data.

    LOOP AT er_data_changed->mt_good_cells INTO ls_modified.
      CLEAR: gv_errflag.

*&    값이 변경되었으면
      gv_fieldname = ls_modified-fieldname.

      CALL METHOD check_changed_field
        EXPORTING
          ps_modified     = ls_modified
          pr_data_changed = er_data_changed.
    ENDLOOP.

    IF error_in_data = 'X'.
      CALL METHOD er_data_changed->display_protocol.
    ENDIF.
  ENDMETHOD.                    "handle_data_changed
*
  METHOD handle_toolbar.
    DATA: ls_toolbar   TYPE stb_button.

    CLEAR: ls_toolbar.
    ls_toolbar-butn_type = '3'.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR: ls_toolbar.
    ls_toolbar-function = 'SELALL'.
    ls_toolbar-icon = '@4B@'.
    ls_toolbar-text = space.
    ls_toolbar-quickinfo = '전체선택'.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR: ls_toolbar.
    ls_toolbar-function = 'DESALL'.
    ls_toolbar-icon = '@4D@'.
    ls_toolbar-text = space.
    ls_toolbar-quickinfo = '전체취소'.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR: ls_toolbar.
    ls_toolbar-butn_type = '3'.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR: ls_toolbar.
    ls_toolbar-function = 'SIMUL'.
    ls_toolbar-icon = '@K4@'.
    ls_toolbar-text = '시뮬레이션'.
    ls_toolbar-quickinfo = '시뮬레이션'.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    IF gp_new = 'X'.
      CLEAR: ls_toolbar.
      ls_toolbar-butn_type = '3'.
      APPEND ls_toolbar TO e_object->mt_toolbar.

      CLEAR: ls_toolbar.
      ls_toolbar-function = 'SAVE'.
      ls_toolbar-icon = '@K4@'.
      ls_toolbar-text = '라우팅 생성'.
      ls_toolbar-quickinfo = '라우팅 생성'.
      APPEND ls_toolbar TO e_object->mt_toolbar.
    ELSEIF gp_ext = 'X'.
      CLEAR: ls_toolbar.
      ls_toolbar-butn_type = '3'.
      APPEND ls_toolbar TO e_object->mt_toolbar.

      CLEAR: ls_toolbar.
      ls_toolbar-function = 'MODIFY'.
      ls_toolbar-icon = '@0Z@'.
      ls_toolbar-text = '라우팅 수정'.
      ls_toolbar-quickinfo = '라우팅 수정'.
      APPEND ls_toolbar TO e_object->mt_toolbar.

      CLEAR: ls_toolbar.
      ls_toolbar-butn_type = '3'.
      APPEND ls_toolbar TO e_object->mt_toolbar.

      CLEAR: ls_toolbar.
      ls_toolbar-function = 'DELETE'.
      ls_toolbar-icon = '@18@'.
      ls_toolbar-text = '라우팅 삭제'.
      ls_toolbar-quickinfo = '라우팅 삭제'.
      APPEND ls_toolbar TO e_object->mt_toolbar.

      CLEAR: ls_toolbar.
      ls_toolbar-butn_type = '3'.
      APPEND ls_toolbar TO e_object->mt_toolbar.

      CLEAR: ls_toolbar.
      ls_toolbar-function = 'C_DEL'.
      ls_toolbar-icon = '@11@'.
      ls_toolbar-text = '완전삭제'.
      ls_toolbar-quickinfo = '라우팅 완전삭제'.
      APPEND ls_toolbar TO e_object->mt_toolbar.
    ENDIF.

    IF gp_seq IS NOT INITIAL.
      CLEAR: ls_toolbar.
      ls_toolbar-function = 'SEQ'.
      ls_toolbar-icon = '@K4@'.
      ls_toolbar-text = '순서추가'.
      ls_toolbar-quickinfo = '순서추가'.
      APPEND ls_toolbar TO e_object->mt_toolbar.
    ENDIF.

  ENDMETHOD.                    "handle_toolbar
*
  METHOD handle_user_command.
    DATA: lt_rows       TYPE lvc_t_row.
    CASE e_ucomm.
      WHEN 'SELALL'.
        LOOP AT gt_data  INTO gw_data
                        WHERE chk    = space
                          AND plnal <= 1
                          AND plnfl  = 0
                          AND vornr <= 10
                          AND flag  <> 'ERROR'.
          gw_data-chk = 'X'.
          MODIFY gt_data FROM gw_data INDEX sy-tabix.
        ENDLOOP.

        CALL METHOD gs_grid->refresh_table_display
          EXPORTING
            i_soft_refresh = 'X'
            is_stable      = gs_scroll. " 현재 refresh

        CALL METHOD gs_grid->set_optimize_all_cols.
      WHEN 'DESALL'.
        LOOP AT gt_data  INTO gw_data
                        WHERE chk = 'X'.
          gw_data-chk = space.
          MODIFY gt_data FROM gw_data INDEX sy-tabix.
        ENDLOOP.

        CALL METHOD gs_grid->refresh_table_display
          EXPORTING
            i_soft_refresh = 'X'
            is_stable      = gs_scroll. " 현재 refresh

        CALL METHOD gs_grid->set_optimize_all_cols.
      WHEN 'SIMUL'.
        PERFORM simulation_suitable_stdtm.
        PERFORM set_cell_attributes.

        CALL METHOD gs_grid->refresh_table_display
          EXPORTING
            i_soft_refresh = 'X'
            is_stable      = gs_scroll. " 현재 refresh

        CALL METHOD gs_grid->set_optimize_all_cols.

*& 2008.04.18
*& 순서추가
      WHEN 'SEQ'.                      " 순서추가 선택시
        PERFORM prepare_routing_add.
        PERFORM set_cell_attributes.

        CALL METHOD gs_grid->refresh_table_display
          EXPORTING
            i_soft_refresh = 'X'
            is_stable      = gs_scroll. " 현재 refresh

        CALL METHOD gs_grid->set_optimize_all_cols.

      WHEN 'SAVE'.                     " Save버튼 선택시
        PERFORM prepare_routing_create.
        PERFORM set_cell_attributes.

        CALL METHOD gs_grid->refresh_table_display
          EXPORTING
            i_soft_refresh = 'X'
            is_stable      = gs_scroll. " 현재 refresh

        CALL METHOD gs_grid->set_optimize_all_cols.
      WHEN 'MODIFY'.                  " 수정버튼 선택시
        PERFORM prepare_routing_modify.
        PERFORM set_cell_attributes.

        CALL METHOD gs_grid->refresh_table_display
          EXPORTING
            i_soft_refresh = 'X'
            is_stable      = gs_scroll. " 현재 refresh

        CALL METHOD gs_grid->set_optimize_all_cols.
      WHEN 'DELETE' OR 'C_DEL'.
        IF e_ucomm = 'DELETE'.
          PERFORM delete_group_count_by_ca01  USING space.
        ELSE.
          PERFORM delete_group_count_by_ca01  USING 'X'.
        ENDIF.

        PERFORM set_cell_attributes.

        CALL METHOD gs_grid->refresh_table_display
          EXPORTING
            i_soft_refresh = 'X'
            is_stable      = gs_scroll. " 현재 refresh

        CALL METHOD gs_grid->set_optimize_all_cols.
    ENDCASE.
  ENDMETHOD.                           "handle_user_command
*
  METHOD check_changed_field.
    DATA: lv_tabix            TYPE i,
          lv_datum            TYPE sy-datum,
          lv_fldname          TYPE char30,
          lv_fldvalue         TYPE char30,
          ls_modified         TYPE lvc_s_modi.

    FIELD-SYMBOLS: <value>    TYPE ANY,
                   <field>    TYPE ANY.

*    CLEAR: gw_data.

    CONCATENATE 'GW_DATA-' gv_fieldname  INTO lv_fldname.
    lv_fldvalue = gv_fieldname.

    ASSIGN: (lv_fldname)   TO <field>,
            lv_fldvalue    TO <value>.

    READ TABLE pr_data_changed->mt_good_cells INTO ls_modified
                                WITH KEY row_id = ps_modified-row_id
                                      fieldname = gv_fieldname.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.

    CALL METHOD pr_data_changed->get_cell_value
      EXPORTING
        i_row_id    = ps_modified-row_id
        i_fieldname = ps_modified-fieldname
      IMPORTING
        e_value     = <value>.

    <field> = <value>.

    IF gv_fieldname <> 'CHK'.
      gw_data-modify = 'X'.
    ENDIF.

    MODIFY gt_data  FROM gw_data INDEX ps_modified-row_id
                          TRANSPORTING (gv_fieldname)
                                        modify
                                        flag.
  ENDMETHOD.                           " check_changed_field
ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION
