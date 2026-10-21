*&---------------------------------------------------------------------*
*&  Include           ZGTSDR0070I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0100 input.

  case gd_okcode.
    when 'ZOPEN'.
      perform tree_open_close.
    when 'ZNEW'.
      perform get_new_data_from_vbak.
    when 'REFR'.
      perform refresh_data_from_cbo.
    when 'SAVE'.
      perform save_plan_data.
    when others.
  endcase.

  clear: gd_okcode.

endmodule.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module exit_command input.

  data : l_confirm type c.

  l_confirm = 'J'.

  case sy-ucomm.
    when 'BACK'.
      perform check_updated_data  changing l_confirm.
      if l_confirm = 'J'.
        call method g_alv_tree->free.
        leave to screen 0.
      endif.
    when 'EXIT'.
      perform check_updated_data  changing l_confirm.
      if l_confirm = 'J'.
        call method g_alv_tree->free.
        leave to screen 0.
      endif.
    when 'CANC'.
      perform check_updated_data  changing l_confirm.
      if l_confirm = 'J'.
        call method g_alv_tree->free.
        leave to screen 0.
      endif.
  endcase.


endmodule.                 " EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0200 input.

  data lv_msg  type char200.
  DATA lv_valid TYPE C.

  case gd_200okcode.
    when 'ZSAVE2'.
      "편집 중 값 반영
      call method go_grid_200->check_changed_data
        importing
          e_valid = lv_valid.

      if lv_valid is initial.
        " 에러가 존재함 (add_protocol_entry가 실행됨)
        message '입력 데이터에 오류가 있습니다.' type 'E'.

      else.

        perform update_process changing lv_msg.

        if lv_msg is not initial.
          message s001 with lv_msg display like 'E'.
        else.
          "-- tree, main, detail에 반영한다.
          perform update_main_detail_data_200.

          call method g_alv_tree->free.
          clear: g_alv_tree.

          perform create_tree .

          perform get_item_detail using gv_nkey  c_so.
          perform display_sub_grid.
          refresh gt_list_200.
          leave to screen 0.
        endif.
      endif.
    when 'ZCLOSE2' or 'CANC'.
      refresh gt_list_200.
      leave to screen 0.
    when others.
  endcase.

  clear: gd_200okcode.

endmodule.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0300 input.

  case gd_300okcode.
    when 'ZSAVE3'.
      "편집 중 값 반영
      call method go_grid_300->check_changed_data
        importing
          e_valid = lv_valid.

      if lv_valid is initial.
        " 에러가 존재함 (add_protocol_entry가 실행됨)
        message '입력 데이터에 오류가 있습니다.' type 'E'.

      else.

        perform save_wish_data  changing lv_msg.

        if lv_msg is not initial.
          message s001 with lv_msg display like 'E'.
        else.
          "-- tree, main, detail에 반영한다.
          perform modify_main_list_fr_300.

          call method g_alv_tree->free.
          clear: g_alv_tree.

          perform create_tree .

          perform get_item_detail using gv_nkey  c_so.
          perform display_sub_grid.
          refresh gt_list_300.
          leave to screen 0.
        endif.

      endif.

    when 'ZCLOSE3' or 'CANC'.
      refresh gt_list_300.
      leave to screen 0.
    when others.
  endcase.

  clear: gd_300okcode.

endmodule.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0400 input.

  case gd_400okcode.
    when 'ZSAVE4'.

      perform save_wish_data  changing lv_msg.

      if lv_msg is not initial.
        message s001 with lv_msg display like 'E'.
      else.
        "-- tree, main, detail에 반영한다.
        perform modify_main_list_fr_300.

        call method g_alv_tree->free.
        clear: g_alv_tree.

        perform create_tree .

        perform get_item_detail using gv_nkey  c_so.
        perform display_sub_grid.
        refresh gt_list_300.
        leave to screen 0.
      endif.
    when 'ZCLOSE4' or 'CANC'.
      leave to screen 0.
    when others.
  endcase.

  clear: gd_400okcode.

endmodule.
