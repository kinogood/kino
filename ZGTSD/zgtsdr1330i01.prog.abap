*----------------------------------------------------------------------*
***INCLUDE ZGTSDR1320I01.
*----------------------------------------------------------------------*
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

      endcase.

      leave to screen 0.

  endcase.
endmodule.
