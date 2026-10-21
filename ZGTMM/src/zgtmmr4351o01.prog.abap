*&---------------------------------------------------------------------*
*& Include          ZGTMMR4351O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  CLEAR: GT_ECOMM.

  CASE ABAP_TRUE.
    WHEN P_SEND. "전송
      GT_ECOMM = VALUE #( ( 'RESEND' ) ).
      SET TITLEBAR '0100'.
    WHEN P_ILOG. "조회/재전송
      GT_ECOMM = VALUE #( ( 'SEND' ) ).
      SET TITLEBAR '0100'.
  ENDCASE.

  SET PF-STATUS '0100' EXCLUDING GT_ECOMM.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0100 OUTPUT.
  IF GO_CONT IS INITIAL.
    PERFORM F_CREATE_ALV_OBJECT.
    PERFORM F_SET_EXCL.
    PERFORM F_SET_LAYO.
    PERFORM F_SET_VARI.
    PERFORM F_SET_FCAT.
    PERFORM F_SET_ALV_EVENT.
    PERFORM F_SET_ALV_SORT.
    PERFORM F_DISPLAY_ALV.
  ENDIF.

  PERFORM F_REFRESH_ALV USING GO_GRID.

ENDMODULE.
