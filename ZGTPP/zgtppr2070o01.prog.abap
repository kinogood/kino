*&---------------------------------------------------------------------*
*& Include          ZGTPPR2070O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE create_alv_0100 OUTPUT.

  IF go_grid_0100 IS NOT BOUND.

    PERFORM set_object_grid_0100.
    PERFORM event_handler_register USING go_grid_0100.
    PERFORM set_layout_grid_0100.
    PERFORM set_cell_attribute_grid_0100.
    PERFORM exclude_of_toolbar_grid_0100.
    PERFORM set_sorttab_grid_0100.
    PERFORM set_f4_field_grid_0100.
    PERFORM call_grid_0100_display.

  ENDIF.

ENDMODULE.
