*&---------------------------------------------------------------------*
*& Include          ZGTSDR0030O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  __CLE : GT_FCODE.
  CASE ZGTSD_X.
    WHEN RB_BT1.
      SET TITLEBAR '0100' WITH TEXT-T01.

    WHEN OTHERS.
      SET TITLEBAR '0100' WITH TEXT-T02.
      append 'SAVE' to GT_FCODE.
  ENDCASE.

  SET PF-STATUS '0100' EXCLUDING GT_FCODE.


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
