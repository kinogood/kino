*&---------------------------------------------------------------------*
*&  Include           ZOTCR1310CLS
*&---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       CLASS lcl_eventhandler DEFINITION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
class lcl_eventhandler definition.

**--- detail grid2 제어용 class

  public section.
    class-methods:
      handle_double_click for event double_click of cl_gui_alv_grid
        importing
          e_row
          e_column
          es_row_no
          sender,  " sending control, i.e. ALV grid that raised event

      toolbar            for event toolbar       of cl_gui_alv_grid
        importing e_object
                  e_interactive,

      add_row,

      user_command       for event user_command  of cl_gui_alv_grid
        importing e_ucomm
                  sender.

    class-methods:
      handle_hotspot_click for event hotspot_click of cl_gui_alv_grid
        importing
          e_row_id
          e_column_id
          sender.  " sending control, i.e. ALV grid that raised event


endclass.                    "lcl_eventhandler DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_eventhandler IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
class lcl_eventhandler implementation.

**--- detail grid2 제어용 class

  method toolbar.
    perform grid2_event_toolbar using e_object
                                      e_interactive.
  endmethod.                    "toolbar

  method user_command.
    perform grid2_event_ucomm using e_ucomm.
  endmethod.                    "user_command


  method handle_double_click.

**    data ls_main like gt_main.
**
***   Distinguish according to sending grid instance
**    case sender.
**      when go_grid2.
**        read table gt_main into ls_main index e_row-index.
**        check ( ls_main-matnr is not initial ).
**
**        call method go_grid2->set_current_cell_via_id
**          exporting
***           IS_ROW_ID =
***           IS_COLUMN_ID =
**            is_row_no = es_row_no.
**
***         Triggers PAI of the dynpro with the specified ok-code
***        CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE( 'MATNR' ).
**        set parameter id 'MAT' field ls_main-matnr.
**        call transaction 'MM03' and skip first screen.
**
***      WHEN GO_GRID2.
***
***      WHEN GO_GRID3.
**
**      when others.
**        return.
**    endcase.


  endmethod.                    "handle_double_click


* HOTSPOT
  method handle_hotspot_click.

    data : ls_detail like  gt_detail,
           l_vstel   type  vstel,
           l_ledat   type  datum.

    data: l_rc              type c.

    clear: ls_detail.

    case sender.

      when go_grid2.

        check e_row_id co ' 0123456789'.  " leaf를 선택한 경우만 필요함

        case e_column_id.
          when 'VBELN_VA'.
            read table gt_detail into ls_detail index e_row_id.
            check ( ls_detail-vbeln_va is not initial ).
            set parameter id 'AUN' field ls_detail-vbeln_va.
            call transaction 'VA03' and skip first screen.  " SO 조회

          when 'VBELN_VL'.
            read table gt_detail into ls_detail index e_row_id.
            check ( ls_detail-vbeln_vl is not initial ).
            set parameter id 'VL' field ls_detail-vbeln_vl.
            call transaction 'VL03N' and skip first screen.  " DO 조회

          when 'VBELN_VF'.
            read table gt_detail into ls_detail index e_row_id.
            check ( ls_detail-vbeln_vf is not initial ).
            set parameter id 'VF' field ls_detail-vbeln_vf.
            call transaction 'VF03' and skip first screen.  " BILLING 조회

          when others.
        endcase.

      when others.
        return.
    endcase.


  endmethod.                    "handle_hotspot_click

  method add_row.
    data ls_stable type lvc_s_stbl.

    "✅ 1) 현재 편집중인 값이 있다면 반영
    go_grid2->check_changed_data( ).

    "✅ 2) 내부테이블에 신규 라인 추가
    append initial line to gt_detail. "<<< 여기를 본인 ALV ITAB으로 변경하세요

    "✅ 3) refresh (스크롤/커서 유지)
    ls_stable-row = abap_true.
    ls_stable-col = abap_true.

    go_grid2->refresh_table_display(
      exporting
        is_stable      = ls_stable
        i_soft_refresh = abap_true ).

    "✅ (선택) 추가된 마지막 행으로 커서 이동하고 싶으면:
    data lv_lines type i.

    "==== 추가: 마지막 행으로 커서 이동 ====
    describe table gt_detail lines lv_lines.

    go_grid2->set_current_cell_via_id(
      exporting
        is_row_id    = value lvc_s_row( index = lv_lines )
        is_column_id = value lvc_s_col( fieldname = 'EDATU' )  "첫 입력 컬럼 지정
    ).

    "입력 가능 상태 보장
    go_grid2->set_ready_for_input( 1 ).


  endmethod.

endclass.                    "lcl_eventhandler IMPLEMENTATION


*##################################################################

* §3. Define a (local) class for event handling
class lcl_toolbar_event_receiver definition.

**--- TREE ALV 제어용 class

  public section.
* §4. Define an event handler method to react to fired function codes
*     of the toolbar.                   .
    methods: on_function_selected
      for event function_selected of cl_gui_toolbar
      importing fcode.


    methods handle_node_double_click
      for event node_double_click of cl_gui_alv_tree
      importing node_key
                sender.

    methods handle_item_double_click
      for event item_double_click of cl_gui_alv_tree
      importing node_key
                fieldname.

    methods handle_link_click
      for event link_click        of cl_gui_alv_tree
      importing node_key
                fieldname.


endclass.

*---------------------------------------------------------------------*
*       CLASS lcl_toolbar_event_receiver IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
class lcl_toolbar_event_receiver implementation.
*
**--- TREE ALV 제어용 class

  method on_function_selected.
    data: lt_selected_nodes type lvc_t_nkey,
          l_selected_node   type lvc_nkey,
          l_rc              type c.

    data: l_selected_nkey  type lvc_nkey,
          l_selected_fname type lvc_fname.

    case fcode.
      when 'REFR'.  " refresh
        perform refresh_data_from_cbo.
**      when 'CRTE'.  " 주문생성
    endcase.

  endmethod.

  method handle_node_double_click.
    data: lt_children type lvc_t_nkey.
*first check if the node is a leaf, i.e. can not be expanded

    call method sender->get_children
      exporting
        i_node_key  = node_key
      importing
        et_children = lt_children.

    if not lt_children is initial.

      call method sender->expand_node
        exporting
          i_node_key    = node_key
          i_level_count = 2.
    endif.

*    CALL METHOD G_ALV_TREE->COLUMN_OPTIMIZE.

  endmethod.


  method handle_item_double_click.

    gv_nkey = node_key.
    perform get_item_detail using node_key c_so.
    perform display_sub_grid.

  endmethod.

  method handle_link_click.

    case fieldname.
      when 'SALE_AMT'.
        gv_nkey = node_key.
        perform get_item_detail using node_key  c_so.
      when 'SALE_AMT_KRW'.
        gv_nkey = node_key.
        perform get_item_detail using node_key  c_do.
    endcase.

    perform display_sub_grid.

  endmethod.

endclass.


******************************************************************
class lcl_event_handler_200 definition.
  public section.
    methods:
      on_toolbar for event toolbar of cl_gui_alv_grid
        importing e_object e_interactive,
      on_user_command for event user_command of cl_gui_alv_grid
        importing e_ucomm.
    methods handle_data_changed
      for event data_changed of cl_gui_alv_grid
      importing er_data_changed.
endclass.

class lcl_event_handler_200 implementation.
  " 1. 툴바에 버튼 추가
  method on_toolbar.
    data: ls_button type stb_button.

    ls_button-function = 'ADD_ROW'.
    ls_button-icon     = icon_insert_row.
    ls_button-text     = '행추가'.
    append ls_button to e_object->mt_toolbar.

    ls_button-function = 'DEL_ROW'.
    ls_button-icon     = icon_delete_row.
    ls_button-text     = '행삭제'.
    append ls_button to e_object->mt_toolbar.
  endmethod.

  " 2. 버튼 클릭 시 로직 처리
  method on_user_command.

    field-symbols: <fs_list> like line of gt_list_200.
    data : ls_026 type zsdt_d365_026.
    data : ls_style type lvc_s_styl.

    "--- DO가 있어도 출하되기 전까지는 분할할 수 있다.
    "--- DO가 출하되면 삭제불가

    case e_ucomm.
      when 'ADD_ROW'.

        data ls_stable type lvc_s_stbl.

        "현재 편집중인 값이 있다면 반영
        go_grid_200->check_changed_data( ).

*        if gs_200-gidat is not initial.
*          message '출하된 DO는 수정 불가합니다.' type 'S' display like 'E'.
*          exit.
*        endif.

        "내부테이블에 신규 라인 추가
        append initial line to gt_list_200 assigning <fs_list>. " 빈 라인 추가
        <fs_list>-vrkme = gs_200-vrkme.

        ls_style-style     = cl_gui_alv_grid=>mc_style_enabled. " 활성화

        ls_style-fieldname = 'BLDAT'.
        insert ls_style into table <fs_list>-field_style.
        ls_style-fieldname = 'PLQTY'.
        insert ls_style into table <fs_list>-field_style.
        ls_style-fieldname = 'REMARK'.
        insert ls_style into table <fs_list>-field_style.

        "refresh (스크롤/커서 유지)
        ls_stable-row = abap_true.
        ls_stable-col = abap_true.

        go_grid_200->refresh_table_display(
          exporting
            is_stable      = ls_stable
            i_soft_refresh = abap_true ).

        "입력 가능 상태 보장
        go_grid_200->set_ready_for_input( 1 ).

        " 화면 갱신
        go_grid_200->refresh_table_display( ).

        "(선택) 추가된 마지막 행으로 커서 이동하고 싶으면:
        data lv_lines type i.

        "==== 추가: 마지막 행으로 커서 이동 ====
        describe table gt_list_200 lines lv_lines.

        go_grid_200->set_current_cell_via_id(
          exporting
            is_row_id    = value lvc_s_row( index = lv_lines )
            is_column_id = value lvc_s_col( fieldname = 'BLDAT' )  "첫 입력 컬럼 지정
        ).


      when 'DEL_ROW'.
        data: lt_rows type lvc_t_row,
              ls_row  type lvc_s_row.

        " 선택된 행 가져오기
        call method go_grid_200->get_selected_rows
          importing
            et_index_rows = lt_rows.

        if lt_rows is initial.
          message '삭제할 행을 선택하세요.' type 'S' display like 'E'.
          return.
        endif.

        " 인덱스 뒤에서부터 삭제 (데이터 정렬 유지)
        sort lt_rows by index descending.
        loop at lt_rows into ls_row.
          read table gt_list_200 index ls_row-index assigning field-symbol(<fs>).
          if sy-subrc = 0.
            "-- SAVE했을 경우에만 반영함 ,, 여기선 seqno를 결정할 수 없음
*            move-corresponding <fs> to ls_026.
*            append ls_026 to gt_026_del.
            delete gt_list_200 index ls_row-index.
          endif.
        endloop.
        " 화면 갱신
        go_grid_200->refresh_table_display( ).

    endcase.


  endmethod.

  method handle_data_changed.
    data: ls_mod_cell  type lvc_s_modi,
          lv_bldat     type datum,
          lv_date      type datum,
          lv_msg1(200) type c,
          lv_unitprice type zsdt_d365_027-unitprice_krw,
          lv_quantity  type zsdt_d365_027-quantity,
          lv_vrkme     type vrkme.

    loop at er_data_changed->mt_mod_cells into ls_mod_cell.
      case ls_mod_cell-fieldname.
        when 'BLDAT'. " 매출일
          " 입력된 값 가져오기
          call method er_data_changed->get_cell_value
            exporting
              i_row_id    = ls_mod_cell-row_id
              i_fieldname = ls_mod_cell-fieldname
            importing
              e_value     = lv_bldat.

          if lv_bldat is initial.
            call method er_data_changed->add_protocol_entry
              exporting
                i_msgid     = '00'
                i_msgno     = '001'
                i_msgty     = 'E'
                i_msgv1     = '매출일은 필수로 입력해야 합니다.'
                i_fieldname = ls_mod_cell-fieldname
                i_row_id    = ls_mod_cell-row_id.
          else.
            lv_date = gv_bdate(6) && '01'.
            lv_msg1 = `매출일은 ` && gv_bdate(6) && '월 1일 이후만 입력 가능합니다.'.
            if lv_bldat < lv_date.
              call method er_data_changed->add_protocol_entry
                exporting
                  i_msgid     = '00'
                  i_msgno     = '001'
                  i_msgty     = 'E'
                  i_msgv1     = lv_msg1
                  i_fieldname = ls_mod_cell-fieldname
                  i_row_id    = ls_mod_cell-row_id.
            endif.
          endif.
      endcase.
    endloop.

    if er_data_changed->mt_protocol is not initial.
      er_data_changed->display_protocol( ).
    endif.

  endmethod.

endclass.


******************************************************************
class lcl_event_handler_300 definition.
  public section.
    methods:
      on_f4 for event onf4 of cl_gui_alv_grid
        importing
          e_fieldname
          e_fieldvalue
          es_row_no
          er_event_data
          et_bad_cells
          e_display,
      on_toolbar for event toolbar of cl_gui_alv_grid
        importing e_object e_interactive,
      on_user_command for event user_command of cl_gui_alv_grid
        importing e_ucomm.
    methods handle_data_changed
      for event data_changed of cl_gui_alv_grid
      importing er_data_changed.
endclass.

class lcl_event_handler_300 implementation.

  method on_f4.
    data: lv_select_uom type t006-msehi.
    data: ls_modi       type lvc_s_modi.
    data: lv_month  type  kmonth,
          lv_return type  syst_subrc.
    data: ls_stbl type lvc_s_stbl.


    call function 'POPUP_TO_SELECT_MONTH'
      exporting
        actual_month               = gv_bdate(6)
*       FACTORY_CALENDAR           = ' '
*       HOLIDAY_CALENDAR           = ' '
        language                   = sy-langu
        start_column               = 90
        start_row                  = 9
      importing
        selected_month             = lv_month
        return_code                = lv_return
      exceptions
        factory_calendar_not_found = 1
        holiday_calendar_not_found = 2
        month_not_found            = 3
        others                     = 4.
    if sy-subrc <> 0.
* Implement suitable error handling here
    endif.

    if sy-subrc = 0 and lv_month is not initial.
      " 2. 선택된 값을 ALV의 변경 이벤트 데이터에 할당
      if lv_month >= gv_bdate(6) and lv_month+4(2) between '01' and '12'.

        ls_modi-row_id    = es_row_no-row_id.
        ls_modi-fieldname = e_fieldname.
        ls_modi-value     = lv_month.

        read table gt_list_300 assigning field-symbol(<fs_list>) index es_row_no-row_id.
        if sy-subrc = 0.
          <fs_list>-spmon = lv_month.
        endif.

        ls_stbl-row = 'X'. ls_stbl-col = 'X'.
        go_grid_300->refresh_table_display( is_stable = ls_stbl ).

      else.
        message s003 with `매출월은 ` gv_bdate(6) '월 이후만 입력 가능합니다.' display like 'E'.
      endif.

    endif.

    " 3. 표준 서치헬프가 중복으로 뜨지 않도록 설정
    er_event_data->m_event_handled = 'X'.

  endmethod.

  " 1. 툴바에 버튼 추가
  method on_toolbar.
    data: ls_button type stb_button.

    ls_button-function = 'ADD_ROW'.
    ls_button-icon     = icon_insert_row.
    ls_button-text     = '행추가'.
    append ls_button to e_object->mt_toolbar.

    ls_button-function = 'DEL_ROW'.
    ls_button-icon     = icon_delete_row.
    ls_button-text     = '행삭제'.
    append ls_button to e_object->mt_toolbar.
  endmethod.

  " 2. 버튼 클릭 시 로직 처리
  method on_user_command.

    field-symbols: <fs_list> like line of gt_list_300.
    data : ls_027 type zsdt_d365_027.
    data : ls_style type lvc_s_styl.

    case e_ucomm.
      when 'ADD_ROW'.

        data ls_stable type lvc_s_stbl.

        "현재 편집중인 값이 있다면 반영
        go_grid_300->check_changed_data( ).

        "내부테이블에 신규 라인 추가
        append initial line to gt_list_300 assigning <fs_list>. " 빈 라인 추가
        <fs_list>-vkbur     = p_vkbur.
        <fs_list>-pernr     = p_pernr.
        <fs_list>-spmon     = sy-datum(6).
        <fs_list>-waers_krw = 'KRW'.
        <fs_list>-zptxt     = '(프로젝트 없음)'.

        ls_style-style     = cl_gui_alv_grid=>mc_style_enabled. " 활성화

        ls_style-fieldname = 'SPMON'.
        insert ls_style into table <fs_list>-field_style.
        ls_style-fieldname = 'KUNNR'.
        insert ls_style into table <fs_list>-field_style.
        ls_style-fieldname = 'PRODH'.
        insert ls_style into table <fs_list>-field_style.
        ls_style-fieldname = 'MATNR'.
        insert ls_style into table <fs_list>-field_style.
        ls_style-fieldname = 'ZPJNO'.
        insert ls_style into table <fs_list>-field_style.
*        ls_style-fieldname = 'UNITPRICE_KRW'.
*        insert ls_style into table <fs_list>-field_style.
*        ls_style-fieldname = 'VRKME'.
*        insert ls_style into table <fs_list>-field_style.
*        ls_style-fieldname = 'QUANTITY'.
*        insert ls_style into table <fs_list>-field_style.
        ls_style-fieldname = 'AMOUNT_KRW'.
        insert ls_style into table <fs_list>-field_style.
        ls_style-fieldname = 'MARGINALPROFIT_PER'.
        insert ls_style into table <fs_list>-field_style.
        ls_style-fieldname = 'REMARK'.
        insert ls_style into table <fs_list>-field_style.

        "refresh (스크롤/커서 유지)
        ls_stable-row = abap_true.
        ls_stable-col = abap_true.

        go_grid_300->refresh_table_display(
          exporting
            is_stable      = ls_stable
            i_soft_refresh = abap_true ).

        "(선택) 추가된 마지막 행으로 커서 이동하고 싶으면:
        data lv_lines type i.


        go_grid_300->set_ready_for_input( 1 ).
        " 화면 갱신
        go_grid_300->refresh_table_display( ).

        "==== 추가: 마지막 행으로 커서 이동 , 화면 갱신후 이동 ====
        cl_gui_cfw=>flush( ).

        describe table gt_list_300 lines lv_lines.
        go_grid_300->set_current_cell_via_id(
          exporting
            is_row_id    = value lvc_s_row( index = lv_lines )
            is_column_id = value lvc_s_col( fieldname = 'SPMON' )  "첫 입력 컬럼 지정
        ).

      when 'DEL_ROW'.
        data: lt_rows type lvc_t_row,
              ls_row  type lvc_s_row.

        " 선택된 행 가져오기
        call method go_grid_300->get_selected_rows
          importing
            et_index_rows = lt_rows.

        if lt_rows is initial.
          message '삭제할 행을 선택하세요.' type 'S' display like 'E'.
          return.
        endif.

        " 인덱스 뒤에서부터 삭제 (데이터 정렬 유지)
        sort lt_rows by index descending.
        loop at lt_rows into ls_row.
          read table gt_list_300 index ls_row-index assigning field-symbol(<fs>).
          if sy-subrc = 0.
            move-corresponding <fs> to ls_027.
            "-- DB삭제건은 조회한 내용에서만 삭제 가능함
            "-- 조회조건에서 벗어나는 건은 화면에서만 삭제가능함
            read table gt_027_chk transporting no fields
                                  with key vkbur = p_vkbur
                                           pernr = p_pernr
                                           spmon = ls_027-spmon
                                           kunnr = ls_027-kunnr
                                           zpjno = ls_027-zpjno
                                           prodh = ls_027-prodh
                                           matnr = ls_027-matnr.
            if sy-subrc = 0.
              append ls_027 to gt_027_del. ""<--- db에서 삭제할 내용
            endif.
          endif.

          delete gt_list_300 index ls_row-index.
        endloop.

        " 화면 갱신
        go_grid_300->refresh_table_display( ).

    endcase.



  endmethod.

  method handle_data_changed.
    data: ls_mod_cell  type lvc_s_modi,
          lv_fkdat     type datum,
          lv_spmon     type spmon,
          lv_date      type datum,
          lv_matnr     type matnr,
          lv_maktx     type maktx,
          lv_meins     type meins,
          lv_kunnr     type kunnr,
          lv_name1     type ad_name1,
          lv_zpjno     type zpjno,
          lv_prodh     type prodh_d,
          lv_prodh_nm  type text40,
          lv_unitprice type zsdt_d365_027-unitprice_krw,
          lv_quantity  type zsdt_d365_027-quantity,
          lv_vrkme     type vrkme,
          lv_amount    type zsdt_d365_027-amount_krw,
          lv_mprf_rate type zsdt_d365_027-marginalprofit_per,
          lv_mprf_amt  type zsdt_d365_027-marginalprofit_krw,
          lv_zptxt     type zsd0106t-zptxt,
          lv_msg1(200) type c,
          lv_msg       type char200.

    loop at er_data_changed->mt_mod_cells into ls_mod_cell.
      case ls_mod_cell-fieldname.
        when 'SPMON'. " 매출월
          " 입력된 값 가져오기
          call method er_data_changed->get_cell_value
            exporting
              i_row_id    = ls_mod_cell-row_id
              i_fieldname = ls_mod_cell-fieldname
            importing
              e_value     = lv_spmon.

          if lv_spmon is initial.
            call method er_data_changed->add_protocol_entry
              exporting
                i_msgid     = '00'
                i_msgno     = '001'
                i_msgty     = 'E'
                i_msgv1     = '매출월은 필수로 입력해야 합니다.'
                i_fieldname = ls_mod_cell-fieldname
                i_row_id    = ls_mod_cell-row_id.
          else.
            lv_msg1 = `매출월은 ` && gv_bdate(6) && '월 이후만 입력 가능합니다.'.
            if lv_spmon < gv_bdate(6).
              call method er_data_changed->add_protocol_entry
                exporting
                  i_msgid     = '00'
                  i_msgno     = '001'
                  i_msgty     = 'E'
                  i_msgv1     = lv_msg1
                  i_fieldname = ls_mod_cell-fieldname
                  i_row_id    = ls_mod_cell-row_id.
            elseif not lv_spmon+4(2) between '01' and '12'.
              call method er_data_changed->add_protocol_entry
                exporting
                  i_msgid     = '00'
                  i_msgno     = '001'
                  i_msgty     = 'E'
                  i_msgv1     = '매출월은 01 에서 12까지만 입력 가능합니다.'
                  i_fieldname = ls_mod_cell-fieldname
                  i_row_id    = ls_mod_cell-row_id.
            endif.
          endif.
        when 'MATNR'. " 자재코드 필드가 변경되었다면
          " 입력된 값 가져오기
          call method er_data_changed->get_cell_value
            exporting
              i_row_id    = ls_mod_cell-row_id
              i_fieldname = ls_mod_cell-fieldname
            importing
              e_value     = lv_matnr.

          " 자재명(MAKTX) 조회
          perform get_matnr_text  using    lv_matnr
                                  changing lv_maktx.
*          perform get_matnr_meins using    lv_matnr
*                                  changing lv_meins.

          if sy-subrc <> 0 and lv_matnr is not initial.
            call method er_data_changed->add_protocol_entry
              exporting
                i_msgid     = '00'
                i_msgno     = '001'
                i_msgty     = 'E'
                i_msgv1     = '존재하지 않는 자재입니다.'
                i_fieldname = ls_mod_cell-fieldname
                i_row_id    = ls_mod_cell-row_id.
          else.

            " 변경된 값을 그리드에 다시 세팅
            call method er_data_changed->modify_cell
              exporting
                i_row_id    = ls_mod_cell-row_id
                i_fieldname = 'MATNR_NM'
                i_value     = lv_maktx.

            call method er_data_changed->get_cell_value
              exporting
                i_row_id    = ls_mod_cell-row_id
                i_fieldname = 'PRODH'
              importing
                e_value     = lv_prodh.

            "-- 자재코드외 제품계층구조의 데이터를 체크한다.
            perform check_matnr_prodh  using    lv_matnr
                                                lv_prodh
                                       changing lv_msg.
            if lv_msg is not initial.
              call method er_data_changed->add_protocol_entry
                exporting
                  i_msgid     = '00'
                  i_msgno     = '001'
                  i_msgty     = 'E'
                  i_msgv1     = lv_msg
                  i_fieldname = ls_mod_cell-fieldname
                  i_row_id    = ls_mod_cell-row_id.
            endif.
          endif.

        when 'KUNNR'. " 고객코드 필드가 변경되었다면
          " 입력된 값 가져오기
          call method er_data_changed->get_cell_value
            exporting
              i_row_id    = ls_mod_cell-row_id
              i_fieldname = ls_mod_cell-fieldname
            importing
              e_value     = lv_kunnr.

          if lv_kunnr is initial.
            call method er_data_changed->add_protocol_entry
              exporting
                i_msgid     = '00'
                i_msgno     = '001'
                i_msgty     = 'E'
                i_msgv1     = '판매처는 필수로 입력해야 합니다.'
                i_fieldname = ls_mod_cell-fieldname
                i_row_id    = ls_mod_cell-row_id.
          else.

            " 고객명 조회
            perform get_kunnr_name  using    lv_kunnr
                                    changing lv_name1.

            if sy-subrc <> 0.
              call method er_data_changed->add_protocol_entry
                exporting
                  i_msgid     = '00'
                  i_msgno     = '001'
                  i_msgty     = 'E'
                  i_msgv1     = '존재하지 않는 판매처입니다.'
                  i_fieldname = ls_mod_cell-fieldname
                  i_row_id    = ls_mod_cell-row_id.
            else.
              " 변경된 값을 그리드에 다시 세팅
              call method er_data_changed->modify_cell
                exporting
                  i_row_id    = ls_mod_cell-row_id
                  i_fieldname = 'KUNNR_NM'
                  i_value     = lv_name1.
            endif.
          endif.

        when 'ZPJNO'. " 프로젝트 필드가 변경되었다면
          " 입력된 값 가져오기
          call method er_data_changed->get_cell_value
            exporting
              i_row_id    = ls_mod_cell-row_id
              i_fieldname = ls_mod_cell-fieldname
            importing
              e_value     = lv_zpjno.

          " 프로젝트명 조회
          perform get_zpjno_name  using    lv_zpjno
                                  changing lv_zptxt.

          if sy-subrc <> 0.
            call method er_data_changed->add_protocol_entry
              exporting
                i_msgid     = '00'
                i_msgno     = '001'
                i_msgty     = 'E'
                i_msgv1     = '존재하지 않는 프로젝트입니다.'
                i_fieldname = ls_mod_cell-fieldname
                i_row_id    = ls_mod_cell-row_id.
          else.
            " 변경된 값을 그리드에 다시 세팅
            call method er_data_changed->modify_cell
              exporting
                i_row_id    = ls_mod_cell-row_id
                i_fieldname = 'ZPJNO'
                i_value     = lv_zpjno.

            " 변경된 값을 그리드에 다시 세팅
            call method er_data_changed->modify_cell
              exporting
                i_row_id    = ls_mod_cell-row_id
                i_fieldname = 'ZPTXT'
                i_value     = lv_zptxt.
          endif.

        when 'PRODH'. " 제품계층구조
          " 입력된 값 가져오기
          call method er_data_changed->get_cell_value
            exporting
              i_row_id    = ls_mod_cell-row_id
              i_fieldname = ls_mod_cell-fieldname
            importing
              e_value     = lv_prodh.

          if lv_prodh is initial.
*            call method er_data_changed->add_protocol_entry
*              exporting
*                i_msgid     = '00'
*                i_msgno     = '001'
*                i_msgty     = 'E'
*                i_msgv1     = '제품계층구조는 필수로 입력해야 합니다.'
*                i_fieldname = ls_mod_cell-fieldname
*                i_row_id    = ls_mod_cell-row_id.

            clear lv_prodh_nm.

            call method er_data_changed->modify_cell
              exporting
                i_row_id    = ls_mod_cell-row_id
                i_fieldname = 'PRODH_NM'
                i_value     = lv_prodh_nm.
          else.

            " 제품계층구조 레벨 체크
            if strlen( lv_prodh ) between 14 and 18.
              call method er_data_changed->get_cell_value
                exporting
                  i_row_id    = ls_mod_cell-row_id
                  i_fieldname = 'MATNR'
                importing
                  e_value     = lv_matnr.
              "-- 자재코드외 제품계층구조의 데이터를 체크한다.
              perform check_matnr_prodh  using    lv_matnr
                                                  lv_prodh
                                         changing lv_msg.
              if lv_msg is not initial.
                call method er_data_changed->add_protocol_entry
                  exporting
                    i_msgid     = '00'
                    i_msgno     = '001'
                    i_msgty     = 'E'
                    i_msgv1     = lv_msg
                    i_fieldname = ls_mod_cell-fieldname
                    i_row_id    = ls_mod_cell-row_id.
              endif.
            else.
              call method er_data_changed->add_protocol_entry
                exporting
                  i_msgid     = '00'
                  i_msgno     = '001'
                  i_msgty     = 'E'
                  i_msgv1     = '4레벨 또는 5레벨만 입력가능합니다.'
                  i_fieldname = ls_mod_cell-fieldname
                  i_row_id    = ls_mod_cell-row_id.
            endif.

            " 제품계층구조명 조회
            perform get_prodh_name  using    lv_prodh
                                    changing lv_prodh_nm.

            if lv_prodh_nm is initial or sy-subrc <> 0.
              call method er_data_changed->add_protocol_entry
                exporting
                  i_msgid     = '00'
                  i_msgno     = '001'
                  i_msgty     = 'E'
                  i_msgv1     = '존재하지 않는 제품계층구조입니다.'
                  i_fieldname = ls_mod_cell-fieldname
                  i_row_id    = ls_mod_cell-row_id.
            else.
              " 변경된 값을 그리드에 다시 세팅
              call method er_data_changed->modify_cell
                exporting
                  i_row_id    = ls_mod_cell-row_id
                  i_fieldname = 'PRODH_NM'
                  i_value     = lv_prodh_nm.
            endif.
          endif.

        when 'AMOUNT_KRW'. " 매출금액
          " 입력된 값 가져오기
          call method er_data_changed->get_cell_value
            exporting
              i_row_id    = ls_mod_cell-row_id
              i_fieldname = ls_mod_cell-fieldname
            importing
              e_value     = lv_amount.

          if lv_amount = 0.
            call method er_data_changed->add_protocol_entry
              exporting
                i_msgid     = '00'
                i_msgno     = '001'
                i_msgty     = 'E'
                i_msgv1     = '매출액(KRW)은 필수로 입력해야 합니다.'
                i_fieldname = ls_mod_cell-fieldname
                i_row_id    = ls_mod_cell-row_id.
          else.
            " 변경된 값을 그리드에 다시 세팅
            call method er_data_changed->modify_cell
              exporting
                i_row_id    = ls_mod_cell-row_id
                i_fieldname = 'AMOUNT_KRW'
                i_value     = lv_amount.

            call method er_data_changed->get_cell_value
              exporting
                i_row_id    = ls_mod_cell-row_id
                i_fieldname = 'MARGINALPROFIT_PER'
              importing
                e_value     = lv_mprf_rate.
            if sy-subrc = 0.
              lv_mprf_amt = lv_amount * lv_mprf_rate / 100.

              " 한계이익(\)을 그리드에 다시 세팅
              call method er_data_changed->modify_cell
                exporting
                  i_row_id    = ls_mod_cell-row_id
                  i_fieldname = 'MARGINALPROFIT_KRW'
                  i_value     = lv_mprf_amt.
            endif.
          endif.

        when 'MARGINALPROFIT_PER'. " 한계이익률 입력시
          " 입력된 값 가져오기
          call method er_data_changed->get_cell_value
            exporting
              i_row_id    = ls_mod_cell-row_id
              i_fieldname = ls_mod_cell-fieldname
            importing
              e_value     = lv_mprf_rate.

          if lv_mprf_rate = 0.
            call method er_data_changed->add_protocol_entry
              exporting
                i_msgid     = '00'
                i_msgno     = '001'
                i_msgty     = 'E'
                i_msgv1     = '한계이익률(%)은 필수로 입력해야 합니다.'
                i_fieldname = ls_mod_cell-fieldname
                i_row_id    = ls_mod_cell-row_id.
          else.

            call method er_data_changed->get_cell_value
              exporting
                i_row_id    = ls_mod_cell-row_id
                i_fieldname = 'AMOUNT_KRW'
              importing
                e_value     = lv_amount.
            if sy-subrc = 0.
              lv_mprf_amt = lv_amount * lv_mprf_rate / 100.

              " 한계이익(\)을 그리드에 다시 세팅
              call method er_data_changed->modify_cell
                exporting
                  i_row_id    = ls_mod_cell-row_id
                  i_fieldname = 'MARGINALPROFIT_KRW'
                  i_value     = lv_mprf_amt.
            endif.

          endif.
      endcase.

    endloop.

    if er_data_changed->mt_protocol is not initial.
      er_data_changed->display_protocol( ).
    endif.

  endmethod.


endclass.
