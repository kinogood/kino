*&---------------------------------------------------------------------*
*& Include          ZGTPPR2290O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS '0100'.
  SET TITLEBAR  '0100'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE create_alv_0100 OUTPUT.

  IF go_grid_0100 IS NOT BOUND.
    PERFORM set_object_grid_0100.
    PERFORM event_handler_register USING go_grid_0100.
    PERFORM set_layout_grid_0100.
    PERFORM set_fieldcat_grid_0100.
    PERFORM exclude_of_toolbar_grid_0100.
    PERFORM call_grid_0100_display.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0220 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0220 OUTPUT.

  SET PF-STATUS '220'.
  SET TITLEBAR '220'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0220 OUTPUT
*&---------------------------------------------------------------------*
MODULE create_alv_0220 OUTPUT.

  IF go_grid_0220 IS NOT BOUND.
    PERFORM set_object_grid_0220.
    PERFORM event_handler_register USING go_grid_0220.
    PERFORM set_layout_grid_0220.
    PERFORM set_fieldcat_grid_0220.
    PERFORM exclude_of_toolbar_grid_0220.
    PERFORM call_grid_0220_display.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0222 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0222 OUTPUT.

  SET PF-STATUS '222'.
  SET TITLEBAR '222'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.

  SET PF-STATUS '300'.
  SET TITLEBAR '300'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0301 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0301 OUTPUT.

  SET PF-STATUS '300'.
  SET TITLEBAR '301'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0400 OUTPUT.

  SET PF-STATUS '400'.
  SET TITLEBAR '400'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0400 OUTPUT
*&---------------------------------------------------------------------*
MODULE create_alv_0400 OUTPUT.

  IF go_grid_0400 IS NOT BOUND.
    PERFORM set_object_grid_0400.
    PERFORM event_handler_register USING go_grid_0400.
    PERFORM set_layout_grid_0400.
    PERFORM set_fieldcat_grid_0400.
    PERFORM exclude_of_toolbar_grid_0400.
    PERFORM call_grid_0400_display.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0500 OUTPUT.

  gt_exclude = COND #( WHEN gs_thead-tdobject EQ 'VBBK' THEN VALUE #( ( 'APPLY' ) ) ).

  SET PF-STATUS '500' EXCLUDING gt_exclude.
  SET TITLEBAR  '500' WITH gv_title.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_INIT_CONSTROL_0500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_init_constrol_0500 OUTPUT.

  IF gr_textedit IS NOT BOUND.
    gr_textedit = NEW #( parent = NEW cl_gui_docking_container( parent    = cl_gui_container=>screen1
                                                                lifetime  = cl_gui_control=>lifetime_dynpro
                                                                side      = cl_gui_docking_container=>dock_at_left
                                                                repid     = sy-repid
                                                                dynnr     = sy-dynnr
                                                                extension = 662 )
                         wordwrap_mode     = cl_gui_textedit=>wordwrap_at_fixed_position
                         wordwrap_position = gc_line_length
                         wordwrap_to_linebreak_mode = cl_gui_textedit=>true ).

    gr_textedit->set_font_fixed( gr_textedit->true ).
    gr_textedit->set_toolbar_mode( gr_textedit->false ).
    gr_textedit->set_statusbar_mode( gr_textedit->false ).
    gr_textedit->set_text_as_r3table( gt_ltext ).

    IF gs_thead-tdobject EQ 'VBBK'.
      gr_textedit->set_readonly_mode( gr_textedit->true ).
    ENDIF.
  ENDIF.

ENDMODULE.
