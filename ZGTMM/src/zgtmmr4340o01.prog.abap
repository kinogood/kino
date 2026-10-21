*&---------------------------------------------------------------------*
*& Include          ZGTMMR4340O01
*&---------------------------------------------------------------------*

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
