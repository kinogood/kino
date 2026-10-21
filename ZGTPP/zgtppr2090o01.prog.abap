*&---------------------------------------------------------------------*
*& Include          ZGTPPR2090O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0100 OUTPUT.
  IF GO_GRID_0100 IS NOT BOUND.
* 원본화면
    PERFORM SET_OBJECT_GRID_0100.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0100.
    PERFORM SET_LAYOUT_GRID_0100.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0100.
    PERFORM SET_SORTTAB_GRID_0100.
    PERFORM CALL_GRID_0100_DISPLAY.

* 비교화면
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0101.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0101.
    PERFORM CALL_GRID_0101_DISPLAY.
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100' WITH GV_TITLE.
ENDMODULE.
