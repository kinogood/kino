*&---------------------------------------------------------------------*
*& Include          ZGTPPI1040O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  DATA : LT_EXCLUDING TYPE TABLE OF SY-UCOMM.

  CASE ABAP_TRUE.
    WHEN P_SEND.
      SET PF-STATUS '0100' EXCLUDING 'RESEND'.
      SET TITLEBAR '0100'.
    WHEN P_DISP.
      LT_EXCLUDING = VALUE #(
        ( 'RESEND' )
        (  'SEND' ) ).

      SET PF-STATUS '0100' EXCLUDING LT_EXCLUDING.
      SET TITLEBAR '0101'.
  ENDCASE.
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
    PERFORM CALL_GRID_0100_DISPLAY.
  ENDIF.
ENDMODULE.
