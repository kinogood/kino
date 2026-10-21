*&---------------------------------------------------------------------*
*& Include          ZGTMMR4381O01
*&---------------------------------------------------------------------*
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
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS '0200'.
  SET TITLEBAR '0200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0201 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0201 OUTPUT.
  SET PF-STATUS '0201'.
  SET TITLEBAR '0201'.
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
