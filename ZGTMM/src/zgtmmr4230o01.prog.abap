*&---------------------------------------------------------------------*
*& Include          ZGTMMR4230O01
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
    PERFORM SET_SORT.
*   PERFORM SET_EVNT.

    CASE 'X'.
      WHEN P_WEEK.
        PERFORM SET_FCAT_DISP TABLES GT_WSTK
                               USING 'GT_WSTK'.
      WHEN P_DAY.
        PERFORM SET_FCAT_DISP TABLES GT_DSTK
                               USING 'GT_DSTK'.
    ENDCASE.
  ELSE.
    CHECK GV_REF = GC_X.
    PERFORM REFRESH_GRID.
  ENDIF.

ENDMODULE.
