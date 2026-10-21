*&---------------------------------------------------------------------*
*& Include          ZGTPPR2060O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv_0100 OUTPUT.
  IF go_grid_0100 IS NOT BOUND.
    PERFORM set_object_grid_0100.
    PERFORM event_handler_register USING go_grid_0100.
    PERFORM set_layout_grid_0100.
    PERFORM set_fieldcat_grid_0100.
    PERFORM set_cell_attribute_grid_0100.
    PERFORM exclude_of_toolbar_grid_0100.
    PERFORM set_sorttab_grid_0100.
    PERFORM call_grid_0100_display.
  ENDIF.

  IF go_grid_0200 IS NOT BOUND.
    PERFORM set_object_grid_0200.
    PERFORM event_handler_register USING go_grid_0200.
    PERFORM set_layout_grid_0200.
    PERFORM set_disp_fieldcat_grid_0200.
    PERFORM exclude_of_toolbar_grid_0200.
    PERFORM set_cell_attribute_grid_0200 .
    PERFORM set_sorttab_grid_0200.
    PERFORM call_grid_0200_display.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET PF-STATUS '0300'.
  SET TITLEBAR '0300'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv_0300 OUTPUT.

  IF go_grid_0300 IS NOT BOUND.
    PERFORM set_object_grid_0300.
    PERFORM set_layout_grid_0300.
    PERFORM set_fieldcat_grid_0300.
    PERFORM set_cell_attribute_grid_0300.
    PERFORM exclude_of_toolbar_grid_0300.
    PERFORM call_grid_0300_display.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*& 2026.01.30.zlsgpp5.create. CHM2601-00657
*&---------------------------------------------------------------------*
MODULE status_0400 OUTPUT.
  SET PF-STATUS '0400'.
  SET TITLEBAR '0400'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0400 OUTPUT
*&---------------------------------------------------------------------*
*& 2026.01.30.zlsgpp5.create. CHM2601-00657
*&---------------------------------------------------------------------*
MODULE create_alv_0400 OUTPUT.

  IF go_grid_0400 IS NOT BOUND.
    PERFORM set_object_grid_0400.
    PERFORM set_layout_grid_0400.
    PERFORM set_fieldcat_grid_0400.
    PERFORM set_cell_attribute_grid_0400.
    PERFORM exclude_of_toolbar_grid_0400.
    PERFORM call_grid_0400_display.
  ENDIF.

ENDMODULE.
