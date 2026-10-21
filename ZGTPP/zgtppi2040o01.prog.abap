*&---------------------------------------------------------------------*
*& Include          ZGTPPI2040O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  IF P_SEND = ABAP_TRUE.
    SET PF-STATUS '0100'.
    SET TITLEBAR '0100'.
  ELSE.
    SET PF-STATUS '0101'.
    SET TITLEBAR '0101'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0100 OUTPUT.
  IF GO_GRID_0100 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0100.
    PERFORM SET_LAYOUT_GRID_0100.
    PERFORM SET_FIELDCAT_GRID_0100.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0100.
    PERFORM SET_SORTTAB_GRID_0100.
    PERFORM CALL_GRID_0100_DISPLAY.
  ENDIF.

  IF GO_GRID_0101 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0101.
    PERFORM SET_LAYOUT_GRID_0101.
    PERFORM SET_FIELDCAT_GRID_0101.
    PERFORM EXCLUDE_OF_TOOLBAR_0101.
    PERFORM SET_SORTTAB_GRID_0101.
    PERFORM CALL_GRID_0101_DISPLAY.
  ENDIF.

  IF GO_GRID_0102 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0102.
    PERFORM SET_LAYOUT_GRID_0102.
    PERFORM SET_FIELDCAT_GRID_0102.
    PERFORM EXCLUDE_OF_TOOLBAR_0102.
    PERFORM SET_SORTTAB_GRID_0102.
    PERFORM CALL_GRID_0102_DISPLAY.
  ENDIF.
ENDMODULE.
