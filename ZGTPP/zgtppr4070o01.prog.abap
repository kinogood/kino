*&---------------------------------------------------------------------*
*& Include          ZGTPPR4070O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  CLEAR: GT_UCOMM, GT_UCOMM[].

  CASE ABAP_TRUE.
    WHEN P_R1.  "당월실적취소
      APPEND 'REGR' TO GT_UCOMM.
      APPEND 'RETM' TO GT_UCOMM.
      APPEND 'REGI' TO GT_UCOMM.
      SET TITLEBAR '0100'.
    WHEN P_R2.  "차월실적재처리
      APPEND 'CANGR' TO GT_UCOMM.
      APPEND 'CANTM' TO GT_UCOMM.
      APPEND 'CANGI' TO GT_UCOMM.
      SET TITLEBAR '0101'.
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
    PERFORM SET_EVENT_GRID_0100 USING GO_GRID_0100.
    PERFORM CALL_GRID_0100_DISPLAY.
  ENDIF.
ENDMODULE.
