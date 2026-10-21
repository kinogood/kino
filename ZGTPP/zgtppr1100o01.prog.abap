*&---------------------------------------------------------------------*
*& Include          ZGTPPR1100O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  DATA: LV_TITLE TYPE SY-TITLE.

  LV_TITLE = SY-TITLE.

  CLEAR: GT_UCOMM, GT_UCOMM[].

  IF P_R5 EQ GC_X.
    APPEND 'UPDATE' TO GT_UCOMM.
  ELSEIF P_R6 EQ GC_X.
    IF P_R1 EQ GC_X OR P_R2 EQ GC_X.
      APPEND 'UPDATE' TO GT_UCOMM.
    ELSEIF P_R7 EQ GC_X.
      APPEND 'EXEC' TO GT_UCOMM.
    ENDIF.
  ENDIF.

  SET TITLEBAR '0100' WITH LV_TITLE.
  SET PF-STATUS '0100' EXCLUDING GT_UCOMM.
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
*    PERFORM SET_VARIANT_GRID_0100.
    PERFORM SET_FIELDCAT_GRID_0100.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0100.
    PERFORM SET_EVENT_GRID_0100 USING GO_GRID_0100.
    PERFORM CALL_GRID_0100_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET TITLEBAR '0200'.
  SET PF-STATUS '0200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0200 OUTPUT.
  IF GO_GRID_0200 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0200.
    PERFORM SET_LAYOUT_GRID_0200.
    PERFORM SET_FIELDCAT_GRID_0200.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0200.
    PERFORM SET_EVENT_GRID_0100 USING GO_GRID_0200.
    PERFORM CALL_GRID_0200_DISPLAY.
  ENDIF.
ENDMODULE.
