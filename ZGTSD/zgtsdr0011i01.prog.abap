*&---------------------------------------------------------------------*
*& Include          ZGTSDR0011F01
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
    when 'SO_CRT'.
      perform create_so.
  endcase.

endmodule.
