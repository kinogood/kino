*&---------------------------------------------------------------------*
*& Include          ZGTSDR0010O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  __CLE : GT_FCODE.
*  CASE GC_X.
*    WHEN RB_DISP.
*      APPEND 'SEND' TO GT_FCODE.
*    WHEN RB_SEND.
*      APPEND 'R_SEND' TO GT_FCODE.
*  ENDCASE.
  SET PF-STATUS '0100' EXCLUDING GT_FCODE.
  SET TITLEBAR '0100' WITH TEXT-T01 ."SY-TITLE.

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
      IF GO_CON2 IS NOT BOUND.

        "Create Object
        PERFORM INIT_ALV_0100 CHANGING GO_CON2
                                       GO_GRID2.
        PERFORM SET_ATTRIBUTES_0200.
      ELSE.
        PERFORM REFRESH_TABLE_DISPLAY USING GO_GRID2 SPACE.
      ENDIF.
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
*&---------------------------------------------------------------------*
*& Module STATUS_0101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0101 OUTPUT.
  SET PF-STATUS '0101'.
  SET TITLEBAR '0100' WITH GS_S0101-TEXT '일괄 입력'.
ENDMODULE.
