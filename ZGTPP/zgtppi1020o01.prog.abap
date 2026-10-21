*&---------------------------------------------------------------------*
*& Include          ZGTPPI1020O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  CASE abap_true.
    WHEN p_send.
      SET PF-STATUS '0100' EXCLUDING 'RESEND'.
      SET TITLEBAR '0100'.
    WHEN p_disp.
      SET PF-STATUS '0100' EXCLUDING 'SEND'.
      SET TITLEBAR '0101'.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv_0100 OUTPUT.
  IF go_grid_0100 IS NOT BOUND.
    PERFORM set_object_grid_0100.
    PERFORM set_layout_grid_0100.
    PERFORM set_fieldcat_grid_0100.
    PERFORM exclude_of_toolbar_grid_0100.
    PERFORM call_grid_0100_display.
  ENDIF.
ENDMODULE.
