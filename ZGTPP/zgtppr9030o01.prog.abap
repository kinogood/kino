*&---------------------------------------------------------------------*
*& Include          ZGTMMR9010O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  DATA LV_TEXT(20).
  CLEAR GT_ECOMM.

  IF P_DIS = ABAP_TRUE.
    GT_ECOMM = VALUE #( ( 'UPLO' ) ).
    LV_TEXT = TEXT-R02. "결과조회
  ELSEIF P_UP = ABAP_TRUE.
    GT_ECOMM = VALUE #( ( 'REVE' ) ).
    LV_TEXT = TEXT-R01. "재고업로드
  ENDIF.

  SET PF-STATUS '0100' EXCLUDING GT_ECOMM.
  SET TITLEBAR '0100' WITH LV_TEXT.

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
