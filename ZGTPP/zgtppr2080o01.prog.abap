*&---------------------------------------------------------------------*
*& Include          ZGTPPR2080O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS '0200'.
  SET TITLEBAR '0200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0200 OUTPUT.
  IF GO_GRID_0200 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0200.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0200.
    PERFORM SET_LAYOUT_GRID_0200.
    PERFORM SET_FIELDCAT_GRID_0200.
    PERFORM SET_DROP_DOWN_GRID_0200.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0200.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0200.
    PERFORM CALL_GRID_0200_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.
  SET PF-STATUS '0300'.
  SET TITLEBAR '0300'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0300 OUTPUT.

  IF GO_GRID_0300 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0300.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0300.
    PERFORM SET_LAYOUT_GRID_0300.
    PERFORM SET_FIELDCAT_GRID_0300.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0300.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0300.
    PERFORM CALL_GRID_0300_DISPLAY.
  ENDIF.

ENDMODULE.
