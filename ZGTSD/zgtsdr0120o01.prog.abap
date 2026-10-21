*&---------------------------------------------------------------------*
*& Include          ZGTSDR0120O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  __CLE : GT_FCODE.

  IF  PA_CHK2  =  'X'.

    APPEND 'VF01'  TO GT_FCODE.
    APPEND 'BDC'   TO GT_FCODE.
    APPEND 'BDC2'  TO GT_FCODE.
    APPEND 'BDC4'  TO GT_FCODE.
    APPEND 'ZDISP' TO GT_FCODE.
    APPEND 'ZEDIT' TO GT_FCODE.

  ELSE.

    IF G_FDIS IS INITIAL.
      APPEND 'ZEDIT' TO GT_FCODE.
      APPEND 'BDC'   TO GT_FCODE.
      APPEND 'BDC2'  TO GT_FCODE.
      APPEND 'BDC4'  TO GT_FCODE.
      "APPEND 'VF01'  TO GT_FCODE.
*      APPEND 'ESTI'  TO GT_FCODE.
    ELSE.
      APPEND 'ZDISP' TO GT_FCODE.
      APPEND 'POD_C' TO GT_FCODE.
    ENDIF.

  ENDIF.
  APPEND 'F_ALL'  TO GT_FCODE.
  APPEND 'F_SAL'  TO GT_FCODE.

  IF PA_SPART = '60'.
    APPEND 'VA02'  TO GT_FCODE.
  ENDIF.

  IF P_LOCK IS NOT INITIAL.
    APPEND 'ZTAX' TO GT_FCODE.
    APPEND 'ZAMT' TO GT_FCODE.
    APPEND 'BDC'   TO GT_FCODE.
    APPEND 'BDC2'  TO GT_FCODE.
    APPEND 'BDC4'  TO GT_FCODE.
    APPEND 'VF01'  TO GT_FCODE.
    APPEND 'ESTI'  TO GT_FCODE.
    APPEND 'ZDISP' TO GT_FCODE.
    APPEND 'POD_C' TO GT_FCODE.
  ENDIF.

  SET PF-STATUS '0100' EXCLUDING GT_FCODE.
  SET TITLEBAR '0100'. "SY-TITLE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_OBJECT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_OBJECT OUTPUT.

  CASE SY-DYNNR.
    WHEN 0100.
      CHECK GO_CON IS NOT BOUND.
      "Create Object
      PERFORM INIT_ALV_0100 CHANGING GO_CON
                                     GO_GRID.

      "Alv 구성
      PERFORM SET_ATTRIBUTES_0100.

    WHEN 0200.
      CHECK GO_CON2 IS NOT BOUND.

      "Create Object
      PERFORM INIT_ALV_0100 CHANGING GO_CON2
                                     GO_GRID2.
      PERFORM SET_ATTRIBUTES_0200.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS '0200'.
  SET TITLEBAR '0200'.
ENDMODULE.
