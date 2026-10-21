*&---------------------------------------------------------------------*
*& Include          ZGTPPR2220O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0100 OUTPUT.

  IF GO_GRID_0100 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0100.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0100.
    PERFORM SET_LAYOUT_GRID_0100.
    PERFORM SET_FIELDCAT_GRID_0100.
    PERFORM SET_SORTTAB_GRID_0100.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0100.
    PERFORM CALL_GRID_0100_DISPLAY.
  ENDIF.

  IF GO_GRID_0101 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0101.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0101.
    PERFORM SET_LAYOUT_GRID_0101.
    PERFORM SET_FIELDCAT_GRID_0101.
    PERFORM SET_SORTTAB_GRID_0101.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0101.
    PERFORM CALL_GRID_0101_DISPLAY.
  ENDIF.


  IF GO_GRID_0102 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0102.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0102.
    PERFORM SET_LAYOUT_GRID_0102.
    PERFORM SET_FIELDCAT_GRID_0102.
    PERFORM SET_SORTTAB_GRID_0102.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0102.
    PERFORM CALL_GRID_0102_DISPLAY.
  ENDIF.

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
*&      Module  CHECK_ARBPL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_ARBPL INPUT.

  IF GS_HERDER_200-ARBPL2 IS INITIAL.
    CLEAR GS_HERDER_200-KTEXT2.
    RETURN.
  ENDIF.

  READ TABLE GT_F4_ARBPL INTO GS_F4_ARBPL WITH KEY GS_HERDER_200-ARBPL2.
  IF SY-SUBRC EQ 0.
    SELECT SINGLE B~KTEXT
      FROM CRHD AS A
      INNER JOIN CRTX AS B ON B~OBJTY = A~OBJTY
                          AND B~OBJID = A~OBJID
      INTO GS_HERDER_200-KTEXT2
     WHERE A~OBJTY = 'A'
       AND A~ARBPL EQ GS_HERDER_200-ARBPL2
       AND B~SPRAS = SY-LANGU.
  ENDIF.

ENDMODULE.
