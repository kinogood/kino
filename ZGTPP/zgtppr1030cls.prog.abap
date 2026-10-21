*&---------------------------------------------------------------------*
*&  Include           ZGTPPR1030CLS
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*     lcl_alv_grid DEFINITION
*---------------------------------------------------------------------*
CLASS lcl_alv_grid DEFINITION INHERITING FROM cl_gui_alv_grid.
  PUBLIC SECTION.
    METHODS: set_optimize_all_cols,
             set_cursor IMPORTING row  TYPE i
                                  col  TYPE i,
             set_fixed_column,
             set_row_resize.
ENDCLASS.                    "LCL_ALV_GRID DEFINITION

*---------------------------------------------------------------------*
*       CLASS LCL_ALV_GRID IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_alv_grid IMPLEMENTATION.
  METHOD set_optimize_all_cols.
    CALL METHOD me->optimize_all_cols
         EXPORTING
              include_header    = 1.
  ENDMETHOD.                    " SET_OPTIMIZE_ALL_COLS
*
  METHOD set_cursor.
    CALL METHOD me->set_current_cell_base
         EXPORTING
              row      = row
              col      = col.
  ENDMETHOD.                    " SET_CURSOR
*
  METHOD set_fixed_column.
    CALL METHOD me->set_fixed_cols
         EXPORTING
              cols     = 3.
  ENDMETHOD.                    " SET_FIXED_COLUMN
*
  METHOD set_row_resize.
    CALL METHOD me->set_resize_rows
         EXPORTING
              enable   = 1.
  ENDMETHOD.                    " SET_ROW_RESIZE
ENDCLASS.                    " LCL_ALV_GRID IMPLEMENTATION

*---------------------------------------------------------------------*
*       CLASS lcl_event_receiver DEFINITION
*---------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS:
*& 값의 변경여부를 체크하고 변경된 값을 화면에 반영한다.
      handle_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
             IMPORTING
                  er_data_changed,
*& 툴바를 추가한다.
      handle_toolbar1     FOR EVENT toolbar      OF cl_gui_alv_grid
             IMPORTING
                  e_object
                  e_interactive,
*& 툴바를 추가한다.
      handle_toolbar2     FOR EVENT toolbar      OF cl_gui_alv_grid
             IMPORTING
                  e_object
                  e_interactive,
*& 버튼을 누르면 각각 작업을 수행한다.
      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
             IMPORTING
                  e_ucomm.

  PRIVATE SECTION.
    DATA: error_in_data     TYPE c.

    METHODS: check_changed_field_100
      IMPORTING
           ps_modified      TYPE lvc_s_modi
           pr_data_changed  TYPE REF TO cl_alv_changed_data_protocol.

    METHODS: check_changed_field_200
      IMPORTING
           ps_modified      TYPE lvc_s_modi
           pr_data_changed  TYPE REF TO cl_alv_changed_data_protocol.
ENDCLASS.

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

      IF sy-dynnr = '0100'.
         CALL METHOD check_changed_field_100
              EXPORTING
                   ps_modified     = ls_modified
                   pr_data_changed = er_data_changed.
      ELSE.
         CALL METHOD check_changed_field_200
              EXPORTING
                   ps_modified     = ls_modified
                   pr_data_changed = er_data_changed.
      ENDIF.
    ENDLOOP.

    IF error_in_data = 'X'.
       CALL METHOD er_data_changed->display_protocol.
    ENDIF.
  ENDMETHOD.
*
  METHOD handle_toolbar1.
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
    ls_toolbar-function = 'DETAIL'.
    ls_toolbar-icon = '@16@'.
    ls_toolbar-text = '상세조회'.
    ls_toolbar-quickinfo = '상세조회 및 처리'.
    APPEND ls_toolbar TO e_object->mt_toolbar.
  ENDMETHOD.
*
  METHOD handle_toolbar2.
    DATA: ls_toolbar   TYPE stb_button.

    CLEAR: ls_toolbar.
    ls_toolbar-butn_type = '3'.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR: ls_toolbar.
    ls_toolbar-function = 'SEL200'.
    ls_toolbar-icon = '@4B@'.
    ls_toolbar-text = space.
    ls_toolbar-quickinfo = '전체선택'.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR: ls_toolbar.
    ls_toolbar-function = 'PSE200'.
    ls_toolbar-icon = '@4C@'.
    ls_toolbar-text = space.
    ls_toolbar-quickinfo = '부분선택'.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR: ls_toolbar.
    ls_toolbar-function = 'DES200'.
    ls_toolbar-icon = '@4D@'.
    ls_toolbar-text = space.
    ls_toolbar-quickinfo = '전체취소'.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR: ls_toolbar.
    ls_toolbar-function = 'SIMUL'.
    ls_toolbar-icon = '@K4@'.
    ls_toolbar-text = '시뮬레이션'.
    ls_toolbar-quickinfo = '시뮬레이션'.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR: ls_toolbar.
    ls_toolbar-butn_type = '3'.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR: ls_toolbar.
    ls_toolbar-function = 'SAVE'.
    ls_toolbar-icon = '@K4@'.
    ls_toolbar-text = 'BOM L/C생성'.
    ls_toolbar-quickinfo = 'BOM L/C 생성'.
    APPEND ls_toolbar TO e_object->mt_toolbar.
  ENDMETHOD.
*
  METHOD handle_user_command.
    DATA: lt_rows       TYPE lvc_t_row.

    CASE e_ucomm.
      WHEN 'SELALL'.                         " 전체선택
        LOOP AT gt_data  INTO gw_data
                        WHERE chk = space.
          gw_data-chk = 'X'.
          MODIFY gt_data FROM gw_data INDEX sy-tabix.
        ENDLOOP.

        CALL METHOD gs_grid1->refresh_table_display
             EXPORTING
                  i_soft_refresh = 'X'
                  is_stable      = gv_scroll. " 현재 refresh

        CALL METHOD gs_grid1->set_optimize_all_cols.
      WHEN 'DESALL'.                        " 전체해제
        LOOP AT gt_data  INTO gw_data
                        WHERE chk = 'X'.
          gw_data-chk = space.
          MODIFY gt_data FROM gw_data INDEX sy-tabix.
        ENDLOOP.

        CALL METHOD gs_grid1->refresh_table_display
             EXPORTING
                  i_soft_refresh = 'X'
                  is_stable      = gv_scroll. " 현재 refresh

        CALL METHOD gs_grid1->set_optimize_all_cols.
      WHEN 'SEL200'.                       " 전체선택(0200)
        LOOP AT gt_tail  INTO gw_tail
                        WHERE chk = space.
          gw_tail-chk = 'X'.
          MODIFY gt_tail FROM gw_tail INDEX sy-tabix.
        ENDLOOP.

        CALL METHOD gs_grid2->refresh_table_display
             EXPORTING
                  i_soft_refresh = 'X'
                  is_stable      = gv_scroll. " 현재 refresh

        CALL METHOD gs_grid2->set_optimize_all_cols.
      WHEN 'PSE200'.                        " 부분선택(0200)
        LOOP AT gt_tail  INTO gw_tail
                        WHERE chk    = space
                          AND dpcbt <> 'C'.
          gw_tail-chk = 'X'.
          MODIFY gt_tail FROM gw_tail INDEX sy-tabix.
        ENDLOOP.

        CALL METHOD gs_grid2->refresh_table_display
             EXPORTING
                  i_soft_refresh = 'X'
                  is_stable      = gv_scroll. " 현재 refresh

        CALL METHOD gs_grid2->set_optimize_all_cols.
      WHEN 'DES200'.                       " 전체해제(0200)
        LOOP AT gt_tail  INTO gw_tail
                        WHERE chk = 'X'.
          gw_tail-chk = space.
          MODIFY gt_tail FROM gw_tail INDEX sy-tabix.
        ENDLOOP.

        CALL METHOD gs_grid2->refresh_table_display
             EXPORTING
                  i_soft_refresh = 'X'
                  is_stable      = gv_scroll. " 현재 refresh

        CALL METHOD gs_grid2->set_optimize_all_cols.
      WHEN 'DETAIL'.                 " 상세조회
        PERFORM read_data_for_detail.
        PERFORM set_cell_attributes_200.

        IF gt_tail[] IS INITIAL.
           MESSAGE s001 WITH '상세조회할 자료가 없습니다.'.
           RETURN.
        ENDIF.

        IF NOT gs_contain_200 IS INITIAL.
           CALL METHOD gs_grid2->refresh_table_display
                EXPORTING
                     i_soft_refresh = 'X'
                     is_stable      = gv_scroll. " 현재 refresh
        ENDIF.

        CALL SCREEN '0200'.
      WHEN 'SIMUL'.                       " 시뮬레이션
        PERFORM simulation_bom_scrap.
        PERFORM set_cell_attributes_200.

        CALL METHOD gs_grid2->refresh_table_display
             EXPORTING
                  i_soft_refresh = 'X'
                  is_stable      = gv_scroll. " 현재 refresh

        CALL METHOD gs_grid2->set_optimize_all_cols.
      WHEN 'SAVE'.                     " Save버튼 선택시
        PERFORM bom_modify_by_bdc.
        PERFORM set_cell_attributes_200.

        CALL METHOD gs_grid2->refresh_table_display
             EXPORTING
                  i_soft_refresh = 'X'
                  is_stable      = gv_scroll. " 현재 refresh

        CALL METHOD gs_grid2->set_optimize_all_cols.
    ENDCASE.
  ENDMETHOD.                           "handle_user_command
*
  METHOD check_changed_field_100.
    DATA: lv_tabix            TYPE i,
          lv_datum            TYPE sy-datum,
          lv_fldname          TYPE char30,
          lv_fldvalue         TYPE char30,
          ls_modified         TYPE lvc_s_modi.

    FIELD-SYMBOLS: <value>    TYPE ANY,
                   <field>    TYPE ANY.

    CLEAR: gw_data.

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

    MODIFY gt_data  FROM gw_data INDEX ps_modified-row_id
                          TRANSPORTING (gv_fieldname).
  ENDMETHOD.                           " check_changed_field_100
*
  METHOD check_changed_field_200.
    DATA: lv_tabix            TYPE i,
          lv_datum            TYPE sy-datum,
          lv_fldname          TYPE char30,
          lv_fldvalue         TYPE char30,
          ls_modified         TYPE lvc_s_modi.

    FIELD-SYMBOLS: <value>    TYPE ANY,
                   <field>    TYPE ANY.

    CLEAR: gw_tail.

    CONCATENATE 'GW_TAIL-' gv_fieldname  INTO lv_fldname.
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

    MODIFY gt_tail  FROM gw_tail INDEX ps_modified-row_id
                          TRANSPORTING (gv_fieldname).
  ENDMETHOD.                           " check_changed_field_200
ENDCLASS.
