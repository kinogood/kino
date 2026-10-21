*&---------------------------------------------------------------------*
*& Include          ZGTMMR1120O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module STATUS_0900 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0900 OUTPUT.

  CLEAR GT_ECOMM[].
  SET PF-STATUS '0900' EXCLUDING GT_ECOMM.
  SET TITLEBAR '0900 '.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0900 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0900 OUTPUT.

  IF GO_CONT_900 IS INITIAL.
    PERFORM F_CREATE_ALV_OBJECT_900.
    PERFORM F_SET_EXCL_900.
    PERFORM F_SET_LAYO_900.
    PERFORM F_SET_VARI_900.
    PERFORM F_SET_FCAT_900.
    PERFORM F_SET_ALV_EVENT_900.
    PERFORM F_DISPLAY_ALV_900.
  ELSE.


    PERFORM F_SET_FCAT_RESET_900.
    PERFORM F_REFRESH_ALV USING GO_GRID_900_T.
    PERFORM F_REFRESH_ALV USING GO_GRID_900_B.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100'.
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
    PERFORM F_DISPLAY_ALV_100.
  ELSE.
    PERFORM F_REFRESH_ALV USING GO_GRID_100_T.
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
*& Module SET_CURSOR_102 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_CURSOR_102 OUTPUT.
  SET CURSOR FIELD GS_SCR_102-CURSOR.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0103 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0103 OUTPUT.
  SET PF-STATUS '0103'.
  SET TITLEBAR '0103'.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.

  CLEAR GT_ECOMM[].
  IF GV_MNG NE ABAP_TRUE.
    GT_ECOMM = VALUE #( ( 'CONV' ) ( 'MMODI' ) ( 'MEXPA' ) ).
  ELSEIF GV_EDIT EQ SPACE.
    GT_ECOMM = VALUE #( ( 'MMODI' ) ( 'MEXPA' ) ).
  ENDIF.

  SET PF-STATUS '0200' EXCLUDING GT_ECOMM.
  SET TITLEBAR '0200'.

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
    PERFORM F_DISPLAY_ALV_200.
  ELSE.
    PERFORM F_REFRESH_ALV USING GO_GRID_200.
  ENDIF.


ENDMODULE.
