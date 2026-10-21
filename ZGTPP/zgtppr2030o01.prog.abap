*&---------------------------------------------------------------------*
*& Include          ZGTPPR2030O01
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
