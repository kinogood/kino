*&---------------------------------------------------------------------*
*& Include          ZGTMMI6020O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module PBO_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE PBO_0100 OUTPUT.

  IF GR_DOCK IS NOT BOUND.
    SET PF-STATUS '0100'.
    SET TITLEBAR  '0100'.

    PERFORM SET_OBJ.
    PERFORM SET_EXCL.

    PERFORM SET_LAYO  USING GS_HLAYO 'H'.
    PERFORM SET_FCAT TABLES GT_HFCAT GT_HDR
                      USING 'GT_HDR' 'H'.
    PERFORM SET_EVNT  USING GR_HGRID 'GR_HGRID'.
    PERFORM SET_DISP TABLES GT_HFCAT GT_HDR
                      USING GR_HGRID
                            GS_HLAYO 'H'.

    PERFORM SET_LAYO  USING GS_ILAYO 'I'.
    PERFORM SET_FCAT TABLES GT_IFCAT GT_ITM
                      USING 'GT_ITM' 'I'.
    PERFORM SET_EVNT  USING GR_IGRID 'GR_IGRID'.
    PERFORM SET_DISP TABLES GT_IFCAT GT_ITM
                      USING GR_IGRID
                            GS_ILAYO 'I'.

    PERFORM SET_LAYO  USING GS_CLAYO 'C'.
    PERFORM SET_FCAT TABLES GT_CFCAT GT_CMP
                      USING 'GT_CMP' 'C'.
    PERFORM SET_EVNT  USING GR_CGRID 'GR_CGRID'.
    PERFORM SET_DISP TABLES GT_CFCAT GT_CMP
                      USING GR_CGRID
                            GS_CLAYO 'C'.
  ELSE.
*   CHECK GV_REF = GC_X.
*   PERFORM REFRESH_GRID USING GR_HGRID
*                              GS_HLAYO.
  ENDIF.

ENDMODULE.
