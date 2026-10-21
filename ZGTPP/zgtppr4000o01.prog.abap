*&---------------------------------------------------------------------*
*& Include          ZGTPPR4000O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  CLEAR: GT_UCOMM, GT_UCOMM[].

  CASE ABAP_TRUE.
    WHEN P_R1.  "생산 오더 마감
      APPEND 'FORDDEL' TO GT_UCOMM.
      APPEND 'ORDDLVCAN' TO GT_UCOMM.
      SET TITLEBAR '0100'.
    WHEN P_R2.  "생산 오더 마감 취소
      APPEND 'ORDDLV' TO GT_UCOMM.
      APPEND 'FORDCRE' TO GT_UCOMM.
      APPEND 'ITEMCHK' TO GT_UCOMM.
      SET TITLEBAR '0101'.
    WHEN P_R3. "생산오더현황
      APPEND 'FORDDEL' TO GT_UCOMM.
      APPEND 'ORDDLVCAN' TO GT_UCOMM.
      APPEND 'ORDDLV' TO GT_UCOMM.
      APPEND 'FORDCRE' TO GT_UCOMM.
      APPEND 'ITEMCHK' TO GT_UCOMM.
      SET TITLEBAR '0102'.
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
