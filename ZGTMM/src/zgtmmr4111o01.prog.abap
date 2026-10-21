*&---------------------------------------------------------------------*
*& Include          ZGTMMR4111O01
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
    PERFORM SET_LAYO.
    PERFORM SET_F4   USING GR_HGRID 'GR_HGRID'.
    PERFORM SET_EVNT USING GR_HGRID 'GR_HGRID'.

    CASE 'X'.
      WHEN P_ORP.
        PERFORM SET_FCAT_DISP TABLES GT_HFCAT
                                     GT_HORP
                               USING GR_HGRID
                                     'GT_HORP'.

      WHEN P_ORD.
        PERFORM SET_FCAT_DISP TABLES GT_HFCAT
                                     GT_HORD
                               USING GR_HGRID
                                     'GT_HORD'.

        PERFORM SET_FCAT_DISP TABLES GT_IFCAT
                                     GT_IORD
                               USING GR_IGRID
                                     'GT_IORD'.

    ENDCASE.

  ELSE.
    CHECK GV_REF = GC_X.
    PERFORM REFRESH_GRID USING GR_HGRID.

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

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module MODIFY_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE MODIFY_SCREEN OUTPUT.

  CLEAR : GS_XOSR-TXT01.

  CASE GV_XOSR.
    WHEN 'P'. "환입
      GS_XOSR-TXT01 = '환입처리 하시겠습니까?'(P01).

    WHEN 'C'. "환입취소
      GS_XOSR-TXT01 = '환입 취소 하시겠습니까?'(P02).

      LOOP AT SCREEN.
        IF SCREEN-GROUP1 = GC_RMK.
          SCREEN-ACTIVE = GC_0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

  ENDCASE.

ENDMODULE.
