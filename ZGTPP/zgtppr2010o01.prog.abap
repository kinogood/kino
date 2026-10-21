*&---------------------------------------------------------------------*
*& Include          ZGTPPR2010O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  IF sy-tcode = 'ZGTPPR2050'.
    SET PF-STATUS '0100' EXCLUDING 'DEL'.
    SET TITLEBAR '0101'.
  ELSE.
    SET PF-STATUS '0100'.
    SET TITLEBAR '0100'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  IF sy-tcode = 'ZGTPPR2050'.
    SET PF-STATUS '0200' EXCLUDING 'NEW_ROT'.
  ELSE.
    SET PF-STATUS '0200'.
  ENDIF.

  SET TITLEBAR '0200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv_0200 OUTPUT.

  IF go_grid_0200 IS NOT BOUND.
    PERFORM set_object_grid_0200.
    PERFORM event_handler_register USING go_grid_0200.
    PERFORM set_layout_grid_0200.
    PERFORM set_fieldcat_grid_0200.
    PERFORM exclude_of_toolbar_grid_0200.
    PERFORM call_grid_0200_display.
  ENDIF.

  IF go_grid_0201 IS NOT BOUND.
    PERFORM set_object_grid_0201.
    PERFORM set_layout_grid_0201.
    PERFORM event_handler_register USING go_grid_0201.
    PERFORM exclude_of_toolbar_grid_0201.
    PERFORM resizing_fieldcat_grid_0201.
    PERFORM set_cell_attribute_grid_0201.
    PERFORM set_sorttab_grid_0201.
    PERFORM call_grid_0201_display.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0210 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0210 OUTPUT.
  SET PF-STATUS '210'.
  SET TITLEBAR '210'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0220 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0220 OUTPUT.
  SET PF-STATUS '220'.
  IF   gv_disp_set IS NOT INITIAL.
    SET TITLEBAR '221'.
  ELSE.
    SET TITLEBAR '220'.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0260 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0260 OUTPUT.
  SET PF-STATUS '0260'.
  SET TITLEBAR '0260'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0220 OUTPUT
*&---------------------------------------------------------------------*
*&
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
*& Module STATUS_0230 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0230 OUTPUT.
  SET PF-STATUS '230'.
  SET TITLEBAR '230'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0230 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv_0230 OUTPUT.
  IF go_grid_0230 IS NOT BOUND.
    PERFORM set_object_grid_0230.
    PERFORM event_handler_register USING go_grid_0230.
    PERFORM set_layout_grid_0230.
    PERFORM set_fieldcat_grid_0230.
    PERFORM exclude_of_toolbar_grid_0230.
    PERFORM call_grid_0230_display.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0240 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv_0240 OUTPUT.

  IF go_grid_0240 IS NOT BOUND.
    PERFORM set_object_grid_0240.
    PERFORM event_handler_register USING go_grid_0240.
    PERFORM set_layout_grid_0240.
    PERFORM set_fieldcat_grid_0240.
    PERFORM set_cell_attribute_grid_0240.
    PERFORM exclude_of_toolbar_grid_0240.
    PERFORM call_grid_0240_display.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0250 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0250 OUTPUT.
  SET PF-STATUS '0250'.
  SET TITLEBAR '0250'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SCREEN_SET_0250 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE screen_set_0250 OUTPUT.

  LOOP AT SCREEN.
    IF gv_chk_all IS NOT INITIAL.
      IF screen-group1 = 'AAA'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDMODULE.
