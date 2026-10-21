*&---------------------------------------------------------------------*
*& Include          ZGTPPR2150O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  CASE ABAP_TRUE.
    WHEN P_RAD01 OR P_RAD02.
      SET PF-STATUS '0100'.
      IF GV_CHK_GAGONG = ABAP_TRUE.
        SET TITLEBAR '0101'.
      ELSE.
        SET TITLEBAR '0100'.
      ENDIF.
*    WHEN P_RAD02.
    WHEN P_RAD03.
      SET PF-STATUS '0102'.
      SET TITLEBAR '0102'.
  ENDCASE.
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
  SET PF-STATUS '0200'.
  SET TITLEBAR '0200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0200 OUTPUT.

  IF GO_GRID_0101 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0101.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0101.
    PERFORM SET_LAYOUT_GRID_0101.
    PERFORM SET_FIELDCAT_GRID_0101.
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


  IF GO_GRID_0103 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0103.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0103.
    PERFORM SET_LAYOUT_GRID_0103.
    PERFORM SET_FIELDCAT_GRID_0103.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0103.
    PERFORM SET_SORTTAB_GRID_0103.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0103.
    PERFORM CALL_GRID_0103_DISPLAY.
  ENDIF.

  IF GV_CHK_EXCUTE_103 = ABAP_TRUE.
    IF GO_GRID_0104 IS NOT BOUND.
      PERFORM SET_OBJECT_GRID_0104.
      PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0104.
      PERFORM SET_LAYOUT_GRID_0104.
      PERFORM SET_CELL_ATTRIBUTE_GRID_0104.
      PERFORM SET_SORTTAB_GRID_0104.
      PERFORM EXCLUDE_OF_TOOLBAR_GRID_0104.
      PERFORM CALL_GRID_0104_DISPLAY.
    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SCREEN_200_INIT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SCREEN_200_INIT OUTPUT.

  LOOP AT SCREEN.
    IF GV_CHK_EXCUTE_103 IS INITIAL.
      IF SCREEN-GROUP1 = 'BB'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSE.
      IF SCREEN-GROUP1 = 'BB'.
        SCREEN-ACTIVE = 1.
        MODIFY SCREEN.
      ENDIF.

*      IF GS_HEADER_200-ARBPL2 IS NOT INITIAL.
*        IF SCREEN-GROUP2 = 'CC'.
*          SCREEN-INPUT = 0.
*          MODIFY SCREEN.
*        ENDIF.
*      ELSE.
*        IF SCREEN-GROUP2 = 'CC'.
*          SCREEN-INPUT = 1.
*          MODIFY SCREEN.
*        ENDIF.
*      ENDIF.

    ENDIF.
  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0201 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0201 OUTPUT.
  SET PF-STATUS '0201'.
  SET TITLEBAR '0201'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0201 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0201 OUTPUT.
  IF GO_GRID_0201 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0201.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0201.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0201.
    PERFORM SET_SORTTAB_GRID_0201.
    PERFORM SET_FIELDCAT_GRID_0201.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0201.
    PERFORM CALL_GRID_0201_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_TEXT_EDIT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_TEXT_EDIT OUTPUT.
  IF GO_TEXT_300 IS NOT BOUND.
    PERFORM SET_OBJECT_GO_TEXT_300.
    PERFORM SET_GO_TEXT_300.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_1100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_1100 OUTPUT.
  SET PF-STATUS '1100'.
  SET TITLEBAR '1100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_1100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_1100 OUTPUT.

  IF GO_GRID_1100 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_1100.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_1100.
    PERFORM SET_LAYOUT_GRID_1100.
    PERFORM SET_FIELDCAT_GRID_1100.
    PERFORM SET_SORTTAB_GRID_1100.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_1100.
    PERFORM CALL_GRID_1100_DISPLAY.
  ENDIF.


  IF GO_GRID_1101 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_1101.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_1101.
    PERFORM SET_LAYOUT_GRID_1101.
    PERFORM SET_FIELDCAT_GRID_1101.
    PERFORM SET_SORTTAB_GRID_1101.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_1101.
    PERFORM CALL_GRID_1101_DISPLAY.
  ENDIF.

  IF GO_GRID_1102 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_1102.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_1102.
    PERFORM SET_LAYOUT_GRID_1102.
    PERFORM SET_FIELDCAT_GRID_1102.
    PERFORM SET_CELL_ATTRIBUTE_GRID_1102.
    PERFORM SET_SORTTAB_GRID_1102.
    PERFORM SET_DROPDOWN_GRID_1102.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_1102.
    PERFORM CALL_GRID_1102_DISPLAY.
  ENDIF.

  IF GO_GRID_1103 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_1103.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_1103.
    PERFORM SET_LAYOUT_GRID_1103.
    PERFORM SET_SORTTAB_GRID_1103.
    PERFORM SET_CELL_ATTRIBUTE_GRID_1103.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_1103.
    PERFORM CALL_GRID_1103_DISPLAY.
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
  IF GO_GRID_0401 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0401.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0401.
    PERFORM SET_LAYOUT_GRID_0401.
    PERFORM SET_FIELDCAT_GRID_0401.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0401.
    PERFORM CALL_GRID_0401_DISPLAY.
  ENDIF.


  IF GO_GRID_0402 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0402.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0402.
    PERFORM SET_LAYOUT_GRID_0402.
    PERFORM SET_FIELDCAT_GRID_0402.
    PERFORM SET_SORTTAB_GRID_0402.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0402.
    PERFORM CALL_GRID_0402_DISPLAY.
  ENDIF.


  IF GO_GRID_0403 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0403.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0403.
    PERFORM SET_LAYOUT_GRID_0403.
    PERFORM SET_FIELDCAT_GRID_0403.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0403.
    PERFORM SET_SORTTAB_GRID_0403.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0403.
    PERFORM CALL_GRID_0403_DISPLAY.
  ENDIF.

  IF GO_GRID_0404 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0404.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0404.
    PERFORM SET_LAYOUT_GRID_0404.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0404.
    PERFORM SET_SORTTAB_GRID_0404.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0404.
    PERFORM CALL_GRID_0404_DISPLAY.
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
    PERFORM SET_CELL_ATTRIBUTE_GRID_0500.
    PERFORM SET_SORTTAB_GRID_0500.
    PERFORM SET_FIELDCAT_GRID_0500.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0500.
    PERFORM CALL_GRID_0500_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_1200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_1200 OUTPUT.
  SET PF-STATUS '1200'.
  SET TITLEBAR '1200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_1200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_1200 OUTPUT.
  PERFORM SET_OBJECT_GRID_1200.
  PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_1200.
  PERFORM SET_CELL_ATTRIBUTE_GRID_1200.
  PERFORM SET_SORTTAB_GRID_1200.
  PERFORM SET_FIELDCAT_GRID_1200.
  PERFORM EXCLUDE_OF_TOOLBAR_GRID_1200.
  PERFORM CALL_GRID_1200_DISPLAY.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_1300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_1300 OUTPUT.
  SET PF-STATUS '1300'.
  SET TITLEBAR '1300'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_1300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_1300 OUTPUT.
  IF GO_GRID_1300 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_1300.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_1300.
    PERFORM SET_LAYOUT_GRID_1300.
    PERFORM SET_FIELDCAT_GRID_1300.
    PERFORM SET_CELL_ATTRIBUTE_GRID_1300.
    PERFORM SET_F4_FIELD_GRID_1300.
    PERFORM SET_SORTTAB_GRID_1300.
    PERFORM CALL_GRID_1300_DISPLAY.
  ENDIF.


  IF GO_GRID_1301 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_1301.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_1301.
    PERFORM SET_LAYOUT_GRID_1301.
    PERFORM SET_FIELDCAT_GRID_1301.
    PERFORM SET_SORTTAB_GRID_1301.
    PERFORM CALL_GRID_1301_DISPLAY.
  ENDIF.
*
  IF GO_GRID_1302 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_1302.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_1302.
    PERFORM SET_LAYOUT_GRID_1302.
    PERFORM SET_FIELDCAT_GRID_1302.
    PERFORM SET_CELL_ATTRIBUTE_GRID_1302.
    PERFORM SET_SORTTAB_GRID_1302.
    PERFORM CALL_GRID_1302_DISPLAY.
  ENDIF.

ENDMODULE.
