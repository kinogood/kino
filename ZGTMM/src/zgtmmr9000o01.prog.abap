*&---------------------------------------------------------------------*
*& Include          ZGTMMR1040O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  CLEAR GT_ECOMM[].
  IF P_DISP EQ ABAP_TRUE.
    GT_ECOMM = VALUE #( ( 'CREA' ) ).
  ENDIF.

  SET PF-STATUS '0100' EXCLUDING GT_ECOMM..
  SET TITLEBAR '0100 '.

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
  ELSE.
    PERFORM F_REFRESH_ALV USING GO_GRID.
  ENDIF.

ENDMODULE.
