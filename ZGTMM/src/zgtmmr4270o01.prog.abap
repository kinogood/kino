*&---------------------------------------------------------------------*
*& Include          ZGTMMR4270O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  "조회용 T-code는 수정 불가능
  IF SY-TCODE NE 'ZGTMMR4270'.
    GT_ECOMM = VALUE #( ( 'CONV' ) ).
  ENDIF.
  SET PF-STATUS '0100' EXCLUDING GT_ECOMM.
  SET TITLEBAR '0100 '.

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
*    PERFORM F_SET_ALV_SORT_100.
    PERFORM F_DISPLAY_ALV_100.
  ELSE.
    PERFORM F_REFRESH_ALV USING GO_GRID_100_T.
    PERFORM F_REFRESH_ALV USING GO_GRID_100_M.
    PERFORM F_REFRESH_ALV USING GO_GRID_100_B.
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
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.

  "조회용 T-code는 수정 불가능
  CLEAR GT_ECOMM[].
  IF SY-TCODE NE 'ZGTMMR4270'.
    GT_ECOMM = VALUE #( ( 'CONV' ) ( 'SAVE' ) ( 'BSAVE' ) ).
  ELSEIF GV_EDIT EQ SPACE.
    GT_ECOMM = VALUE #( ( 'SAVE' ) ( 'BSAVE' ) ).
  ENDIF.

  SET PF-STATUS '0200' EXCLUDING GT_ECOMM.
  SET TITLEBAR '0200 '.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0200 OUTPUT.

  IF GO_CONT_200 IS INITIAL.
    PERFORM F_CREATE_ALV_OBJECT_200.
    PERFORM F_SET_EXCL_200.
    PERFORM F_SET_LAYO_200.
    PERFORM F_SET_VARI_200.
    PERFORM F_SET_FCAT_200.
    PERFORM F_SET_ALV_EVENT_200.
*    PERFORM F_SET_ALV_SORT_200.
    PERFORM F_DISPLAY_ALV_200.
  ELSE.
    PERFORM F_REFRESH_ALV USING GO_GRID_200_T.
    PERFORM F_REFRESH_ALV USING GO_GRID_200_M.
    PERFORM F_REFRESH_ALV USING GO_GRID_200_B.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.

  SET PF-STATUS '0300'.
  SET TITLEBAR '0300'.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0300 OUTPUT.

  IF GO_CONT_300 IS INITIAL.
    PERFORM F_CREATE_ALV_OBJECT_300.
    PERFORM F_SET_EXCL_300.
    PERFORM F_SET_LAYO_300.
    PERFORM F_SET_VARI_300.
    PERFORM F_SET_FCAT_300.
*    PERFORM F_SET_ALV_EVENT_300.
*    PERFORM F_SET_ALV_SORT_300.
    PERFORM F_DISPLAY_ALV_300.
  ELSE.
    PERFORM F_REFRESH_ALV USING GO_GRID_300.
  ENDIF.

ENDMODULE.
