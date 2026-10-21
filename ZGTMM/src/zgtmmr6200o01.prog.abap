*&---------------------------------------------------------------------*
*& Include          ZGTMMR6200O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module PBO_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE PBO_0100 OUTPUT.

  IF GR_DOCK IS NOT BOUND.
    PERFORM SET_GUI.

    SET PF-STATUS '0100' EXCLUDING GT_EXCD.
    SET TITLEBAR  '0100' WITH GV_TITLE.

    PERFORM SET_OBJ.
    PERFORM SET_EXCL.

    PERFORM SET_LAYO USING GS_HLAYO 'H'.
    PERFORM SET_F4   USING GR_HGRID 'GR_HGRID'.
    PERFORM SET_EVNT USING GR_HGRID 'GR_HGRID'.

    CASE 'X'.
      WHEN P_BAN.
        PERFORM SET_FCAT_DISP TABLES GT_HFCAT
                                     GT_HBAN
                               USING GR_HGRID
                                     GS_HLAYO 'GT_HBAN'.

      WHEN P_BES.
        PERFORM SET_FCAT_DISP TABLES GT_HFCAT
                                     GT_HBES
                               USING GR_HGRID
                                     GS_HLAYO 'GT_HBES'.

        PERFORM SET_LAYO USING GS_ILAYO 'I'.
        PERFORM SET_EVNT USING GR_IGRID 'GR_IGRID'.

        PERFORM SET_FCAT_DISP TABLES GT_IFCAT
                                     GT_IBES
                               USING GR_IGRID
                                     GS_ILAYO 'GT_IBES'.

    ENDCASE.

  ELSE.
    CHECK GV_REF = GC_X.
    PERFORM REFRESH_GRID USING GR_HGRID
                               GS_HLAYO.

    "Transaction 발생 후 Lock이 풀리는 현상 발생(PSJ 25.06.16)
    CHECK GV_LCK IS INITIAL.
    PERFORM SET_LOCK USING ' '.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module PBO_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE PBO_0200 OUTPUT.

  SET PF-STATUS '0200'.
  SET TITLEBAR  '0200'.

  IF GR_RCUST IS NOT BOUND.
    PERFORM SET_OBJ.

    PERFORM SET_EXCL.
    PERFORM SET_LAYO USING GS_RLAYO 'R'.
    PERFORM SET_EVNT USING GR_RGRID 'GR_RGRID'.

    PERFORM SET_FCAT_DISP TABLES GT_RFCAT
                                 GT_RDPM
                           USING GR_RGRID
                                 GS_RLAYO 'GT_RDPM'.
  ELSE.
    CHECK GV_REF = GC_X.
    PERFORM REFRESH_GRID USING GR_RGRID
                               GS_RLAYO.
  ENDIF.

ENDMODULE.
