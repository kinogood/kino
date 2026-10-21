*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR1100O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODULE SET_STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_STATUS_0100 OUTPUT.

  SET PF-STATUS '0100'.

  DATA LV_TEXT(20).
  LV_TEXT = COND #( WHEN SY-DYNNR = '0100'  THEN TEXT-T01
                                 WHEN SY-DYNNR = '0200' THEN TEXT-T02  ELSE TEXT-T03 ).
  SET TITLEBAR '0100' WITH LV_TEXT.

ENDMODULE.
*&---------------------------------------------------------------------*
*& MODULE SET_ALV_GRID_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_ALV_GRID_0100 OUTPUT.

  IF GCL_GRID IS NOT BOUND.
    PERFORM CREATE_ALV.

  ELSE.
    PERFORM REFRESH_TABLE USING GCL_GRID SPACE.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& MODULE SET_ALV_GRID_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_ALV_GRID_0300 OUTPUT.

  IF GCL_GRID_BOM IS NOT BOUND.
    PERFORM CREATE_ALV.

  ELSE.
    PERFORM REFRESH_TABLE USING GCL_GRID_BOM SPACE.

  ENDIF.

ENDMODULE.
