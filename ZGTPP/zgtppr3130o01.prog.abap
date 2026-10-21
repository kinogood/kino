*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  CLEAR : GT_UCOMM, GT_UCOMM[].

  APPEND 'RESEND' TO GT_UCOMM.
  APPEND 'SEND' TO GT_UCOMM.
  SET TITLEBAR 'TITLE_100_1' .

  SET PF-STATUS 'STATUS_100' EXCLUDING GT_UCOMM.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_INSTANCE_CONTROLS OUTPUT
*&---------------------------------------------------------------------*
MODULE CREATE_INSTANCE_CONTROLS OUTPUT.

  PERFORM CREATE_AND_INIT_CONTROLS.

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
*& Module CREATE_ALV_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0400 OUTPUT.
  IF GO_GRID_0400 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0400.
    PERFORM EVENT_HANDLER_REGISTER_0400 USING GO_GRID_0400.
    PERFORM SET_LAYOUT_GRID_0400.
    PERFORM SET_FIELDCAT_GRID_0400.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0400.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0400.
    PERFORM CALL_GRID_0400_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0220 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0220 OUTPUT.
  SET PF-STATUS '0220'.
  SET TITLEBAR '0220'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0220 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0220 OUTPUT.

  IF GO_GRID_0220 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0220.
    PERFORM EVENT_HANDLER_REGISTER_0220 USING GO_GRID_0220.
    PERFORM SET_LAYOUT_GRID_0220.
    PERFORM SET_FIELDCAT_GRID_0220.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0220.
    PERFORM CALL_GRID_0220_DISPLAY.
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
*& Module STATUS_0230 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0230 OUTPUT.
  SET PF-STATUS '0230'.
  SET TITLEBAR '0230'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0230 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0230 OUTPUT.

  IF GO_GRID_0230 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0230.
    PERFORM EVENT_HANDLER_REGISTER_0230 USING GO_GRID_0230.
    PERFORM SET_LAYOUT_GRID_0230.
    PERFORM SET_FIELDCAT_GRID_0230.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0230.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0230.
    PERFORM CALL_GRID_0230_DISPLAY.
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
*& Module STATUS_0260 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0260 OUTPUT.
  SET PF-STATUS '0260'.
  SET TITLEBAR '0260'.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0260 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0260 OUTPUT.
  IF GO_GRID_0260 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0260.
    PERFORM EVENT_HANDLER_REGISTER_0260 USING GO_GRID_0260.
    PERFORM SET_LAYOUT_GRID_0260.
    PERFORM SET_FIELDCAT_GRID_0260.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0260.
    PERFORM CALL_GRID_0260_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0270 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0270 OUTPUT.
  SET PF-STATUS '0270'.
  SET TITLEBAR '0270'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0270 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0270 OUTPUT.
  IF GO_GRID_0270 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0270.
    PERFORM EVENT_HANDLER_REGISTER_0270 USING GO_GRID_0270.
    PERFORM SET_LAYOUT_GRID_0270.
    PERFORM SET_FIELDCAT_GRID_0270.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0270.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0270.
    PERFORM CALL_GRID_0270_DISPLAY.
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
    PERFORM EVENT_HANDLER_REGISTER_500.
    PERFORM SET_LAYOUT_GRID_0500.
    PERFORM SET_FIELDCAT_GRID_0500.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0500.
    PERFORM CALL_GRID_0500_DISPLAY.
  ENDIF.
ENDMODULE.
