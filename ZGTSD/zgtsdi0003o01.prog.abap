*&---------------------------------------------------------------------*
*& Include          ZGTSDI0001O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  __CLE : GT_FCODE.
  CASE GC_X.
    WHEN RB_DISP.
      APPEND 'SEND' TO GT_FCODE.
    WHEN RB_SEND.
      APPEND 'R_SEND' TO GT_FCODE.
  ENDCASE.
  SET PF-STATUS '0100' EXCLUDING GT_FCODE.
  SET TITLEBAR '0100' WITH TEXT-T01 ."SY-TITLE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_OBJECT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_OBJECT OUTPUT.

  CHECK GO_CON IS NOT BOUND.

  "Create Object
  PERFORM INIT_ALV_0100 CHANGING GO_CON
                                 GO_GRID.

  "Alv 구성
  PERFORM SET_ATTRIBUTES_0100.

ENDMODULE.
