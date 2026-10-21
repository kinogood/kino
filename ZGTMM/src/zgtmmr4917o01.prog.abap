*&---------------------------------------------------------------------*
*& Include          ZGTMMR4917O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module PBO_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE PBO_0100 OUTPUT.

  IF GR_DOCK IS INITIAL.
    PERFORM SET_GUI.

    SET PF-STATUS '0100'.
    SET TITLEBAR  '0100'.

    PERFORM SET_OBJ   USING GR_DOCK
                            GR_GRID.
    PERFORM SET_EXCL.
    PERFORM SET_LAYO  USING GS_LAYO.
    PERFORM SET_FCAT TABLES GT_FCAT.
    PERFORM SET_EVNT  USING GR_GRID.
    PERFORM SET_DISP TABLES GT_FCAT
                      USING GR_GRID
                            GS_LAYO.
  ELSE.
    CHECK GV_REF = GC_X.
    PERFORM REFRESH_GRID USING GR_GRID
                               GS_LAYO.
  ENDIF.

ENDMODULE.
