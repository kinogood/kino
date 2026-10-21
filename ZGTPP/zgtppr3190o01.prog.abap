*&---------------------------------------------------------------------*
*& Include          ZGTPPR3190O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  CLEAR: GT_UCOMM, GT_UCOMM[].

  SET TITLEBAR '0100'.

  CASE SY-TCODE.
    WHEN 'ZGTPPR3190'.
      APPEND 'TRS_B' TO GT_UCOMM.
      APPEND 'TRS_BC' TO GT_UCOMM.
    WHEN OTHERS.

  ENDCASE.
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
    PERFORM SET_VARIANT_GRID_0100.
    PERFORM SET_FIELDCAT_GRID_0100.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0100.
    PERFORM CALL_GRID_0100_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  CLEAR: GT_UCOMM2, GT_UCOMM2[], GV_TITLE.

  CASE GV_OK_CODE.
    WHEN 'TRS_B'.
      APPEND 'TRANS_C' TO GT_UCOMM2.
      GV_TITLE = '보류재고 처리'.
    WHEN 'TRS_BC'.
      APPEND 'TRANS' TO GT_UCOMM2.
      GV_TITLE = '보류재고 취소'.
  ENDCASE.

  SET PF-STATUS '0200' EXCLUDING GT_UCOMM2.
  SET TITLEBAR '0200' WITH GV_TITLE.
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
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0400 OUTPUT.
  SET PF-STATUS '0400'.
  SET TITLEBAR '0400'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0400 OUTPUT.
  IF GO_GRID_0400 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0400.
    PERFORM SET_LAYOUT_GRID_0400.
    PERFORM SET_FIELDCAT_GRID_0400.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0400.
    PERFORM CALL_GRID_0400_DISPLAY.
  ENDIF.
ENDMODULE.
