*&---------------------------------------------------------------------*
*& Include          ZGTMMR4122O01
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

    PERFORM SET_EXCL TABLES GT_HEXCL
                      USING 'H'.
    PERFORM SET_LAYO  USING GS_HLAYO 'H'.
    PERFORM SET_FCAT TABLES GT_HFCAT
                            GT_HLIST
                      USING 'GT_HLIST'.
    PERFORM SET_EVNT  USING GR_HGRID 'GR_HGRID'.
    PERFORM SET_DISP TABLES GT_HEXCL
                            GT_HFCAT
                            GT_HLIST
                      USING GR_HGRID
                            GS_HLAYO 'H'.

    PERFORM SET_EXCL TABLES GT_IEXCL
                      USING 'I'.
    PERFORM SET_LAYO  USING GS_ILAYO 'I'.
    PERFORM SET_FCAT TABLES GT_IFCAT
                            GT_ILIST
                      USING 'GT_ILIST'.
    PERFORM SET_EVNT  USING GR_IGRID 'GR_IGRID'.
    PERFORM SET_DISP TABLES GT_IEXCL
                            GT_IFCAT
                            GT_ILIST
                      USING GR_IGRID
                            GS_ILAYO 'I'.
* ELSE.
*   PERFORM REFRESH_GRID USING GR_HGRID
*                              GS_HLAYO.
  ENDIF.

ENDMODULE.
