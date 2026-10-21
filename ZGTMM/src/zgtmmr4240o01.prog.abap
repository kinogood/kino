*&---------------------------------------------------------------------*
*& Include          ZGTMMR4240O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module PBO_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE PBO_0100 OUTPUT.

  IF GR_DOCK IS INITIAL.
    SET PF-STATUS '0100'.
    SET TITLEBAR  '0100'.

    PERFORM SET_OBJ.
    PERFORM SET_EXCL.
    PERFORM SET_LAYO.
    PERFORM SET_FCAT.
    PERFORM SET_SORT.
    PERFORM SET_EVNT.
    PERFORM SET_DISP.
  ELSE.
    CHECK GV_REF = GC_X.
    PERFORM REFRESH_GRID.
  ENDIF.

ENDMODULE.
