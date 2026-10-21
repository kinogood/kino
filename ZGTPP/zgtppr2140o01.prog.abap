*&---------------------------------------------------------------------*
*& Include          ZGTPPR2140O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  IF SY-TCODE = 'ZGTPPR2350'.
    SET PF-STATUS '0100' EXCLUDING 'DEL'.
    SET TITLEBAR '0101'.
  ELSE.
    SET PF-STATUS '0100'.
    SET TITLEBAR '0100'.
  ENDIF.
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
    PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0100.
    PERFORM CALL_GRID_0100_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  IF SY-TCODE = 'ZGTPPR2350' OR GV_CHK_CONFIRM_6600_GO = ABAP_TRUE.
    SET PF-STATUS '0200' EXCLUDING 'NEW_ROT'.
  ELSE.
    SET PF-STATUS '0200'.
  ENDIF.

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
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0200.
    PERFORM SET_LAYOUT_GRID_0200.
    PERFORM SET_FIELDCAT_GRID_0200.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0200.
    PERFORM CALL_GRID_0200_DISPLAY.
  ENDIF.

  IF GO_GRID_0201 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0201.
    PERFORM SET_LAYOUT_GRID_0201.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0201.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0201.
    PERFORM RESIZING_FIELDCAT_GRID_0201.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0201.
    PERFORM SET_SORTTAB_GRID_0201.
    PERFORM CALL_GRID_0201_DISPLAY.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0220 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0220 OUTPUT.
  SET PF-STATUS '220'.
  IF   GV_DISP_SET IS NOT INITIAL.
    SET TITLEBAR '221'.
  ELSE.
    SET TITLEBAR '220'.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0220 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0220 OUTPUT.
  IF GO_GRID_0220 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0220.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0220.
    PERFORM SET_LAYOUT_GRID_0220.
    PERFORM SET_FIELDCAT_GRID_0220.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0220.
    PERFORM CALL_GRID_0220_DISPLAY.
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
*& Module CREATE_ALV_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0300 OUTPUT.
  IF GO_GRID_0300 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0300.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0300.
    PERFORM SET_LAYOUT_GRID_0300.
    PERFORM SET_FIELDCAT_GRID_0300.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0300.
    PERFORM CALL_GRID_0300_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0250 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0250 OUTPUT.
  SET PF-STATUS '0250'.
  SET TITLEBAR '0250'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SCREEN_SET_0250 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SCREEN_SET_0250 OUTPUT.
  LOOP AT SCREEN.
    IF GV_CHK_ALL IS NOT INITIAL.
      IF SCREEN-GROUP1 = 'AAA'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

  ENDLOOP.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0210 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0210 OUTPUT.
  SET PF-STATUS '0210'.
  SET TITLEBAR '0210'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0230 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0230 OUTPUT.
  SET PF-STATUS '230'.
  SET TITLEBAR '230'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0230 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0230 OUTPUT.
  IF GO_GRID_0230 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0230.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0230.
    PERFORM SET_LAYOUT_GRID_0230.
    PERFORM SET_FIELDCAT_GRID_0230.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0230.
    PERFORM CALL_GRID_0230_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0400 OUTPUT.
  SET PF-STATUS '0400'.
  SET TITLEBAR '0400'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0400 OUTPUT.
  IF GO_GRID_0400 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0400.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0400.
    PERFORM SET_LAYOUT_GRID_0400.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0400.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0400.
    PERFORM CALL_GRID_0400_DISPLAY.



    PERFORM SET_LAYOUT_GRID_0401.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0401.
    PERFORM SET_FIELDCAT_GRID_0401.
    PERFORM SET_SORTTAB_GRID_0401.
    PERFORM CALL_GRID_0401_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0240 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0240 OUTPUT.
  SET PF-STATUS '0240'.
  SET TITLEBAR '0240'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0240 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0240 OUTPUT.
  IF GO_GRID_0240 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0240.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0240.
    PERFORM SET_LAYOUT_GRID_0240.
    PERFORM SET_FIELDCAT_GRID_0240.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0240.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0240.
    PERFORM CALL_GRID_0240_DISPLAY.
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
*& Module STATUS_0600 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0600 OUTPUT.
  SET PF-STATUS '0600'.
  SET TITLEBAR '0600'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_TEXT_EDIT_0600 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_TEXT_EDIT_0600 OUTPUT.
  IF GO_TEXT_600 IS NOT BOUND.
    PERFORM SET_OBJECT_GO_TEXT_600.
    PERFORM SET_GO_TEXT_600.
  ENDIF.
ENDMODULE.
