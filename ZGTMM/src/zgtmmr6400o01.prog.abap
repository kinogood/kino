*&---------------------------------------------------------------------*
*& Include          ZGTMMR6400O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module PBO_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE PBO_0100 OUTPUT.

  IF GR_DOCK IS INITIAL.
    PERFORM SET_GUI.

    SET PF-STATUS '0100' EXCLUDING GT_EXCD.
    SET TITLEBAR  '0100'.

    PERFORM SET_OBJ.
    PERFORM SET_EXCL.
    PERFORM SET_LAYO.
*   PERFORM SET_F4.
    PERFORM SET_DROP.
    PERFORM SET_FCAT.
    PERFORM SET_EVNT.
    PERFORM SET_DISP.
  ELSE.
    CHECK GV_REF = GC_X.
    PERFORM REFRESH_GRID.
  ENDIF.

ENDMODULE.
