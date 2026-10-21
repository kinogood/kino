*&---------------------------------------------------------------------*
*& Include          ZGTPPR2260O01
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
    PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0100.
    PERFORM CALL_GRID_0100_DISPLAY.
  ENDIF.

  IF GO_GRID_0101_TOP IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0101_TOP.
    PERFORM SET_LAYOUT_GRID_0101_TOP.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0101_TOP.
    PERFORM SET_FIELDCAT_GRID_0101_TOP.
    PERFORM EXCLUDE_OF_TOOL_GRID_0101_TOP.
*    PERFORM SET_CELL_ATTR_GRID_0101_TOP.
    PERFORM CALL_GRID_0101_DISPLAY_TOP.
  ENDIF.

  IF GO_GRID_0101 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0101.
    PERFORM SET_LAYOUT_GRID_0101.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0101.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0101.
    PERFORM SET_FIELDCAT_GRID_0101.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0101.
    PERFORM SET_SORTTAB_GRID_0101.
    PERFORM CALL_GRID_0101_DISPLAY.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0400 OUTPUT.
  SET PF-STATUS '0400'.
  CASE GV_CREATE_COMMAND.
    WHEN 'CRT_ORDER1'.
      SET TITLEBAR '0400'.
    WHEN 'CRT_ORDER2'.
      SET TITLEBAR '0401'.
    WHEN 'CRT_ORDER3'.
      SET TITLEBAR '0402'.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_TEXT_EDIT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_TEXT_EDIT OUTPUT.
  IF GO_TEXT_400 IS NOT BOUND.
    PERFORM SET_OBJECT_GO_TEXT_400.
    PERFORM SET_GO_TEXT_400.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0440 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0440 OUTPUT.
  SET PF-STATUS '0440'.
  SET TITLEBAR '0440'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0440 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0440 OUTPUT.
  IF GO_GRID_0440 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0440.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0440.
    PERFORM SET_LAYOUT_GRID_0440.
    PERFORM SET_FIELDCAT_GRID_0440.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0440.
    PERFORM CALL_GRID_0440_DISPLAY.
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
*& Module CREATE_ALV_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0200 OUTPUT.

  IF GO_GRID_0200 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0200.
    PERFORM SET_LAYOUT_GRID_0200.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0200.
    PERFORM SET_SORTTAB_GRID_0200.
    PERFORM CALL_GRID_0200_DISPLAY.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.
  SET PF-STATUS '0300'.
  SET TITLEBAR '0300'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_TEXT_EDIT_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_TEXT_EDIT_0300 OUTPUT.
  IF GO_TEXT_300 IS NOT BOUND.
    PERFORM SET_OBJECT_GO_TEXT_300.
    PERFORM SET_GO_TEXT_300.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0500 OUTPUT.
  SET PF-STATUS '0500'.
  SET TITLEBAR '0500'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0500 OUTPUT.
  IF GO_GRID_0500 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0500.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0500.
    PERFORM SET_LAYOUT_GRID_0500.
    PERFORM SET_FIELDCAT_GRID_0500.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0500.
    PERFORM CALL_GRID_0500_DISPLAY.
  ENDIF.
ENDMODULE.
