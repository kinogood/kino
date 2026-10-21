*&---------------------------------------------------------------------*
*&  Include           MZGTPPR1020O01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module STATUS_0100 output.
  SET PF-STATUS 'MENU100'.
  SET TITLEBAR 'T100'.
endmodule.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module STATUS_0200 output.
  SET PF-STATUS 'MENU200'.
  SET TITLEBAR 'T200'.

  DESCRIBE TABLE gt_data LINES tc_200-lines.

endmodule.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_field  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module set_cursor_field output.
SET CURSOR FIELD gv_field LINE gv_lilli.
endmodule.                 " set_cursor_field  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  read_tc_200_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module read_tc_200_data output.

DATA: lt_cols            LIKE gt_cols  OCCURS 0 WITH HEADER LINE.

  CLEAR gt_data.
  READ TABLE gt_data INDEX tc_200-current_line.
  DESCRIBE TABLE gt_data LINES gv_cnt.

  CLEAR: gv_idx, lt_cols[].

  lt_cols[] = tc_200-cols[].

  LOOP AT SCREEN.

         IF gt_data-flag  = space.
            IF screen-group2 = 'INP'.
               screen-input = '1'.
               MODIFY SCREEN.
            ENDIF.
         ELSE.
            IF screen-group1 = 'INP'.
               screen-input = '1'.
               MODIFY SCREEN.
            ENDIF.
         ENDIF.

  ENDLOOP.

  tc_200-cols[] = lt_cols[].

endmodule.                 " read_tc_200_data  OUTPUT
