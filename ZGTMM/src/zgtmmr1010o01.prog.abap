*&---------------------------------------------------------------------*
*& Include          ZGTMMR1010O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module PBO_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE PBO_0100 OUTPUT.

  IF GR_DOCK IS NOT BOUND.
    PERFORM SET_GUI.

    SET PF-STATUS '0100'.
    SET TITLEBAR  '0100' WITH GV_TITLE.

    PERFORM SET_OBJ.
    PERFORM SET_EXCL.
    PERFORM SET_LAYO.
    PERFORM SET_EVNT.

    CASE 'X'.
      WHEN P_ABL.
        PERFORM SET_FCAT_DISP TABLES GT_ABL
                               USING 'GT_ABL'.
      WHEN P_ABS.
        PERFORM SET_FCAT_DISP TABLES GT_ABS
                               USING 'GT_ABS'.
    ENDCASE.

  ELSE.
    CHECK GV_REF = GC_X.
    PERFORM REFRESH_GRID.

  ENDIF.

ENDMODULE.
