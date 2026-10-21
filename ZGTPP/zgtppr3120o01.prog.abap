*&---------------------------------------------------------------------*
*& Include          ZGTPPR3120O01
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
    PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0100.
    PERFORM SET_SORTTAB_GRID_0100.
    PERFORM CALL_GRID_0100_DISPLAY.
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
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0200.
    PERFORM SET_LAYOUT_GRID_0200.
    PERFORM SET_FIELDCAT_GRID_0200.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0200.
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
    PERFORM SET_FIELDCAT_GRID_0400.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0400.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0400.
    PERFORM CALL_GRID_0400_DISPLAY.
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0500 OUTPUT.
  SET PF-STATUS '0500'.

  CASE GV_MODE.
    WHEN 'X'. " PO생성 모드
      GV_TEXT_0500 = TEXT-T04.
    WHEN OTHERS. " PO전환모드
      GV_TEXT_0500 = TEXT-T05.
  ENDCASE.
  SET TITLEBAR '0500' WITH GV_TEXT_0500.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_SCREEN_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_SCREEN_0400 OUTPUT.

  LOOP AT SCREEN.

    CASE GS_REQ_DISP-CHECK.
      WHEN ' '.
        IF SCREEN-GROUP1 = 'BB'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN ABAP_TRUE.
        IF SCREEN-GROUP1 = 'AA'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.

  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_SCREEN_0500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_SCREEN_0500 OUTPUT.

  LOOP AT SCREEN.

    CASE ABAP_TRUE.
      WHEN GS_ORD_DISP-BSART_NB.
        IF SCREEN-GROUP1 = 'BB'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN GS_ORD_DISP-BSART_UB.
        IF SCREEN-GROUP1 = 'AA'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.

  ENDLOOP.

ENDMODULE.
