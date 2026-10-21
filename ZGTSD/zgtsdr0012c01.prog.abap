*&---------------------------------------------------------------------*
*& Include          ZGTSDR0012C01
*&---------------------------------------------------------------------*

class lcl_event_receiver definition.
  public section.
    methods:
      handle_data_changed
        for event data_changed of cl_gui_alv_grid
        importing er_data_changed e_onf4 e_onf4_before e_onf4_after e_ucomm.
    methods:
      handle_hotspot_click for event hotspot_click of cl_gui_alv_grid
        importing
          e_row_id
          e_column_id
          sender.  " sending control, i.e. ALV grid that raised event

endclass.                    "lcl_event_receiver DEFINITION

class lcl_event_receiver implementation.
  method handle_data_changed.
    data: ls_mod_cells type lvc_s_modi.

    loop at er_data_changed->mt_good_cells into ls_mod_cells.
      read table gt_alv into gs_alv index ls_mod_cells-row_id.
      if sy-subrc = 0.
        "데이터 변경 Flag
        gs_alv-modi = 'X'.
        modify gt_alv from gs_alv index ls_mod_cells-row_id.
      endif.
    endloop.
  endmethod.                    "handle_data_changed

* HOTSPOT
  method handle_hotspot_click.

    data : l_vstel   type  vstel,
           l_ledat   type  datum.

    data: l_rc              type c.

    case sender.

      when go_grid.

        check e_row_id co ' 0123456789'.  " leaf를 선택한 경우만 필요함

        case e_column_id.
          when 'VBELN'.
            read table gt_alv into gs_alv index e_row_id.
            check ( gs_alv-vbeln is not initial ).
            set parameter id 'AUN' field gs_alv-vbeln.
            call transaction 'VA03' and skip first screen.  " SO 조회

          when others.
        endcase.

      when others.
        return.
    endcase.


  endmethod.                    "handle_hotspot_click

endclass.                    "lcl_event_receiver IMPLEMENTATION
