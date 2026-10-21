*&---------------------------------------------------------------------*
*& Include          ZGTSDR0010I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module exit input.
  clear : gv_saveok.

  gv_saveok = gv_okcode.
  clear gv_okcode.

  case gv_saveok.
    when 'EXIT' or 'CANC' or 'CANL' or 'BACK'.
      case sy-dynnr.
        when '0100'.
*          PERFORM FREE_OBJECT.

        when '0200'.

      endcase.

      leave to screen 0.

  endcase.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0100 input.

  clear : gv_saveok.

  gv_saveok = gv_okcode.
  clear gv_okcode.

  case gv_saveok.
*    WHEN 'APPLY'.
*      PERFORM ALL_APPLY.
    when 'SAVE'.
      perform save_process.
  endcase.

endmodule.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0200 input.
  clear : gv_saveok.

  gv_saveok = gv_okcode.
  clear gv_okcode.

  case gv_saveok.
    when 'CLOSE'.
      leave to screen 0.
  endcase.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0101 input.

  clear : gv_saveok.
  gv_saveok = gv_okcode.
  clear gv_okcode.

  case gv_saveok.
    when 'APP'. "'APPL_PP' or 'APPL_QM' or 'APPL_LE' or 'APPL_LO'.

      if gs_s0101-date is initial.
        message s007 with gs_s0101-text display like zgtsd_e.
        exit.
      endif.

      perform check_multi_data.
      check gv_error is initial.

**********************************************************************
*      CLEAR GV_ANSWER.
*      GV_ANSWER = ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE
*                                                     IV_MESSA = TEXT-M02 ).
*      CHECK GV_ANSWER = ZGTSD_J.
**********************************************************************

      loop at gt_s0100 into gs_s0100 where itsel = 'X'.

        case gv_apply_mode.
          when 'PP'. gs_s0100-ppdat = gs_s0101-date.
          when 'QM'. gs_s0100-qmdat = gs_s0101-date.
          when 'LE'. gs_s0100-ledat = gs_s0101-date.
          when 'LO'. gs_s0100-lodat = gs_s0101-date.
        endcase.

        modify gt_s0100 from gs_s0100.
      endloop.

      perform refresh_table_display using go_grid space.
      message s000 with '일괄 적용 되었습니다.'.
      leave to screen 0.

    when 'CLOSE'.
      leave to screen 0.
  endcase.

endmodule.
