*&---------------------------------------------------------------------*
*& Include          ZGTPPR3000O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS 'STATUS_100'.
  SET TITLEBAR 'TITLE_100'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_INSTANCE_CONTROLS OUTPUT
*&---------------------------------------------------------------------*
MODULE create_instance_controls OUTPUT.

  PERFORM create_and_init_controls.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  SET PF-STATUS '0200'.
  SET TITLEBAR '0200'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.

  SET PF-STATUS '0300'.
  SET TITLEBAR '0300'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0102 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0102 OUTPUT.

  SET PF-STATUS '102'.
  SET TITLEBAR '102'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0102 OUTPUT
*&---------------------------------------------------------------------*
MODULE create_alv_0102 OUTPUT.

  IF go_grid_0102 IS NOT BOUND.
    PERFORM set_object_grid_0102.
    PERFORM event_handler_register_0102 USING go_grid_0102.
    PERFORM set_layout_grid_0102.
    PERFORM set_fieldcat_grid_0102.
    PERFORM exclude_of_toolbar_grid_0102.
    PERFORM call_grid_0102_display.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0302 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0302 OUTPUT.

  SET PF-STATUS '302'.
  SET TITLEBAR '302'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0302 OUTPUT
*&---------------------------------------------------------------------*
MODULE create_alv_0302 OUTPUT.

  IF go_grid_0302 IS NOT BOUND.
    PERFORM set_object_grid_0302.
    PERFORM event_handler_register_0302 USING go_grid_0302.
    PERFORM set_layout_grid_0302.
    PERFORM set_fieldcat_grid_0302.
    PERFORM exclude_of_toolbar_grid_0302.
    PERFORM call_grid_0302_display.
  ENDIF.

ENDMODULE.
