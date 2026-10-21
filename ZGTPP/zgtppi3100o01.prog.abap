*&---------------------------------------------------------------------*
*& Include          ZGTPPI3100O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  CLEAR: GT_UCOMM, GT_UCOMM[].

  CASE ABAP_TRUE.
    WHEN P_SEND. "전송
      APPEND 'RESEND' TO GT_UCOMM.
      SET TITLEBAR '0100'.
    WHEN P_DISP. "조회/재처리
      APPEND 'SEND' TO GT_UCOMM.
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
    PERFORM CALL_GRID_0100_DISPLAY.
  ENDIF.
ENDMODULE.
