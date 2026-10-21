*&---------------------------------------------------------------------*
*& Include          ZGTMMR4200O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module PBO_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE PBO_0100 OUTPUT.

  SET PF-STATUS '0100'.
  SET TITLEBAR  '0100'.

  IF GR_DOCK IS INITIAL.
    PERFORM SET_OBJ.
    PERFORM SET_EXCL.
    PERFORM SET_LAYO.
    PERFORM SET_FCAT.
*   PERFORM SET_EVNT.
    PERFORM SET_DISP.
* ELSE.
*   PERFORM REFRESH_GRID.
  ENDIF.

ENDMODULE.
