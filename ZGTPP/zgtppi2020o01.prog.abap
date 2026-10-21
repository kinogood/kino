*&---------------------------------------------------------------------*
*& Include          ZGTPPI2020O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  DATA: lt_exclude TYPE TABLE OF sy-ucomm WITH HEADER LINE.

  IF ra_send EQ abap_true.
    APPEND 'REDO' TO lt_exclude.
  ELSEIF ra_redo EQ abap_true AND ra_red EQ abap_true.
    APPEND 'EXEC' TO lt_exclude.
  ELSE.
    APPEND 'REDO' TO lt_exclude.
    APPEND 'EXEC' TO lt_exclude.
  ENDIF.

  SET PF-STATUS '0100' EXCLUDING lt_exclude.
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
*    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0100.
    PERFORM set_layout_grid_0100.
    PERFORM set_fieldcat_grid_0100.
*    PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
    PERFORM exclude_of_toolbar_grid_0100.
    PERFORM call_grid_0100_display.
  ENDIF.

ENDMODULE.
