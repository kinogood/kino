*&---------------------------------------------------------------------*
*& Include          ZGTMMR2020O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  DATA: LV_TEXT TYPE C LENGTH 10.

  CLEAR:
    GT_ECOMM[],
    LV_TEXT.

  CASE ABAP_TRUE.
    WHEN P_NEW.
      LV_TEXT = TEXT-T01.
      GT_ECOMM = VALUE #( ( 'BCAN' ) ( 'BPRINT' ) ( 'BED' ) ).
    WHEN P_DISP.
      LV_TEXT = TEXT-T02.
      GT_ECOMM = VALUE #( ( 'BOK' ) ( 'BPRINT' ) ( 'BED' ) ).
    WHEN P_PRINT.
      LV_TEXT = TEXT-T03.
      GT_ECOMM = VALUE #( ( 'BOK' ) ( 'BCAN' ) ).
  ENDCASE.

  SET PF-STATUS '0100' EXCLUDING GT_ECOMM.
  SET TITLEBAR '0100' WITH LV_TEXT.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0100 OUTPUT.
  IF GO_CONT_100 IS INITIAL.
    PERFORM F_CREATE_ALV_OBJECT_100.
    PERFORM F_SET_EXCL_100.
    PERFORM F_SET_LAYO_100.
    PERFORM F_SET_VARI_100.
    PERFORM F_SET_FCAT_100.
    PERFORM F_SET_ALV_EVENT_100.
**    PERFORM F_SET_ALV_SORT_100.
    PERFORM F_DISPLAY_ALV_100.
  ELSE.
    PERFORM F_REFRESH_ALV USING GO_GRID_100.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0101 OUTPUT.
  SET PF-STATUS '0101'.
  SET TITLEBAR '0101'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0102 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0102 OUTPUT.
  SET PF-STATUS '0102'.
  SET TITLEBAR '0102'.
ENDMODULE.
