*&---------------------------------------------------------------------*
*& Include          ZGTPPR4060O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  CASE ABAP_TRUE.
    WHEN P_R1.
      IF P_RP EQ GC_X.
        SET TITLEBAR '0100'.  "생산오더 투입: 포장재 투입
      ELSEIF P_RC EQ GC_X.
        SET TITLEBAR '0101'.  "생산오더 투입: 정산자재 투입
      ENDIF.
    WHEN P_R2.
      SET TITLEBAR '0200'.    "투입 결과 조회/취소
  ENDCASE.
  SET PF-STATUS '0100'.
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
