*&---------------------------------------------------------------------*
*& Include          ZGTMMR4911O01
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

    IF P_ILOG = GC_X.
       PERFORM SET_OBJ_IF.
    ELSE.
       PERFORM SET_OBJ.
    ENDIF.

    PERFORM SET_EXCL.

    IF P_ILOG = GC_X.
     PERFORM SET_LAYO  USING GS_LLAYO 'L'.
     PERFORM SET_ALV_FIELDCAT  USING 'L'.
     PERFORM SET_EVNT  USING GR_LGRID 'GR_LGRID'.
     PERFORM SET_DISP TABLES GT_LFCAT GT_LOG
                                     USING GR_LGRID  GS_LLAYO 'L'.
    ENDIF.

    PERFORM SET_LAYO  USING GS_HLAYO 'H'.
    PERFORM SET_ALV_FIELDCAT  USING 'H'.
    PERFORM SET_EVNT  USING GR_HGRID 'GR_HGRID'.
    IF P_SEND = GC_X.
      PERFORM SET_DISP TABLES GT_HFCAT GT_PCHG
                                     USING GR_HGRID  GS_HLAYO 'H'.
    ELSE.
      PERFORM SET_DISP TABLES GT_HFCAT GT_HEAD
                                     USING GR_HGRID  GS_HLAYO 'H'.
    ENDIF.

    PERFORM SET_LAYO  USING GS_ILAYO 'I'.
    PERFORM SET_ALV_FIELDCAT  USING 'I'.
    PERFORM SET_EVNT  USING GR_IGRID 'GR_IGRID'.
    PERFORM SET_DISP TABLES GT_IFCAT GT_ITEM
                                   USING GR_IGRID GS_ILAYO 'I'.

    PERFORM SET_LAYO  USING GS_TLAYO 'T'.
    PERFORM SET_ALV_FIELDCAT  USING 'T'.
    PERFORM SET_EVNT  USING GR_TGRID 'GR_TGRID'.
    PERFORM SET_DISP TABLES GT_TFCAT GT_CHAR
                                   USING GR_TGRID GS_TLAYO 'T'.

    PERFORM SET_LAYO  USING GS_FLAYO 'F'.
    PERFORM SET_ALV_FIELDCAT  USING 'F'.
    PERFORM SET_EVNT  USING GR_FGRID 'GR_FGRID'.
    PERFORM SET_DISP TABLES GT_FFCAT GT_BOM
                                   USING   GR_FGRID GS_FLAYO 'F'.

  ELSE.
    CHECK GV_REF = GC_X.

    IF P_ILOG = GC_X.
       PERFORM REFRESH_GRID USING GR_LGRID GS_LLAYO.
    ENDIF.
    PERFORM REFRESH_GRID USING GR_HGRID GS_HLAYO.
    PERFORM REFRESH_GRID USING GR_IGRID GS_ILAYO.
    PERFORM REFRESH_GRID USING GR_TGRID GS_TLAYO.
    PERFORM REFRESH_GRID USING GR_FGRID GS_FLAYO.
  ENDIF.

ENDMODULE.
