*&---------------------------------------------------------------------*
*& Include          ZGTMMR4914O01
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
    SET TITLEBAR  '0100'.

    PERFORM SET_OBJ.
    PERFORM SET_EXCL.

    PERFORM SET_LAYO  USING GS_HLAYO 'H'.
    PERFORM SET_FCAT TABLES GT_HFCAT <GT_HLIST>
                      USING GV_HNAME 'H'.
    PERFORM SET_EVNT  USING GR_HGRID 'GR_HGRID'.
    PERFORM SET_DISP TABLES GT_HFCAT <GT_HLIST>
                      USING GR_HGRID
                            GS_HLAYO 'H'.

    PERFORM SET_LAYO  USING GS_ILAYO 'I'.
    PERFORM SET_FCAT TABLES GT_IFCAT <GT_ILIST>
                      USING GV_INAME 'I'.
    PERFORM SET_EVNT  USING GR_IGRID 'GR_IGRID'.
    PERFORM SET_DISP TABLES GT_IFCAT <GT_ILIST>
                      USING GR_IGRID
                            GS_ILAYO 'I'.
  ELSE.
    CHECK GV_REF = GC_X.
    PERFORM REFRESH_GRID USING GR_HGRID
                               GS_HLAYO.
  ENDIF.

ENDMODULE.
