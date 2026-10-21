*&---------------------------------------------------------------------*
*& Include          ZGTPPR2280O01
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
    PERFORM SET_SORTTAB_GRID_0100.
    PERFORM CALL_GRID_0100_DISPLAY.
  ENDIF.

*  IF GO_GRID_0101_TOP IS NOT BOUND.
*    PERFORM SET_OBJECT_GRID_0101_TOP.
*    PERFORM SET_LAYOUT_GRID_0101_TOP.
*    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0101_TOP.
*    PERFORM SET_FIELDCAT_GRID_0101_TOP.
*    PERFORM EXCLUDE_OF_TOOLBAR_0101_TOP.
*    PERFORM CALL_GRID_0101_DISPLAY_TOP.
*  ENDIF.

  IF GO_GRID_0101 IS NOT BOUND.
    PERFORM SET_FIELDCAT_GRID_0101_TOP.
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
*& Form SET_OBJECT_GRID_0101_TOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0101_TOP .

* 그리드 적용
  CREATE OBJECT GO_GRID_0101_TOP
    EXPORTING
      I_PARENT      = GO_CONTAIN_0101_TOP
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0101_TOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0101_TOP .

  CLEAR GS_LAYOUT_0101_TOP.
  GS_LAYOUT_0101_TOP-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0101_TOP-NO_ROWMARK = ABAP_TRUE.
  GS_LAYOUT_0101_TOP-SEL_MODE   = 'D'.
  GS_LAYOUT_0101_TOP-NO_HEADERS = 'X'.
*  GS_LAYOUT_0101_TOP-NO_TOOLBAR = 'X'.
  GS_LAYOUT_0101_TOP-STYLEFNAME = 'CELLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0101_TOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0101_TOP .

  REFRESH GT_FIELDCAT_0101_TOP.

  APPEND INITIAL LINE TO GT_FIELDCAT_0101_TOP ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
  <LS_FCAT>-FIELDNAME = 'MON'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
  <LS_FCAT>-COL_POS = 1.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.
  <LS_FCAT>-JUST = 'C'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0101_TOP ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'TUE'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
  <LS_FCAT>-COL_POS = 2.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.
  <LS_FCAT>-JUST = 'C'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0101_TOP ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'WED'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
  <LS_FCAT>-COL_POS = 3.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.
  <LS_FCAT>-JUST = 'C'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0101_TOP ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'THU'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
  <LS_FCAT>-COL_POS = 4.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.
  <LS_FCAT>-JUST = 'C'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0101_TOP ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'FRI'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
  <LS_FCAT>-COL_POS = 5.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.
  <LS_FCAT>-JUST = 'C'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0101_TOP ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'SAT'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
  <LS_FCAT>-COL_POS = 6.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.
  <LS_FCAT>-JUST = 'C'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0101_TOP ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'SUN'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
  <LS_FCAT>-COL_POS = 7.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.
  <LS_FCAT>-JUST = 'C'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0101_DISPLAY_TOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0101_DISPLAY_TOP .

  CALL METHOD GO_GRID_0101_TOP->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0101_TOP
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0101_TOP
    CHANGING
      IT_OUTTAB            = GT_WEEK_DISP_EMPTY
      IT_FIELDCATALOG      = GT_FIELDCAT_0101_TOP.

ENDFORM.
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
  IF GO_CONTAIN_0500 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0500.
    PERFORM SET_LAYOUT_GRID_0500.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0500.
    PERFORM SET_FIELDCAT_GRID_0500.
    PERFORM SET_SORTTAB_GRID_0500.
    PERFORM CALL_GRID_0500_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_SCREEN_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_SCREEN_0400 OUTPUT.

  LOOP AT SCREEN.
    CASE SCREEN-GROUP1.
      WHEN 'U01'.
        IF GV_CHK_GO_JOJANG = ABAP_TRUE OR GV_CHK_GO_HALF = ABAP_TRUE OR
          ( P_WERKS = '6600' AND P_SPGCD = 'GL' AND P_GONGCD = 'REW' ).
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.

      WHEN 'U02'.
        IF NOT ( GV_CHK_GO_JOJANG = ABAP_TRUE OR GV_CHK_GO_HALF = ABAP_TRUE OR
                  ( P_WERKS = '6600' AND P_SPGCD = 'GL' AND P_GONGCD = 'REW' ) ).
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.

    ENDCASE.
  ENDLOOP.

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
*& Module SCREEN_INIT_600 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SCREEN_INIT_600 OUTPUT.
  LOOP AT SCREEN.
    IF P_WERKS = '6600' AND P_SPGCD = 'GL'.
      IF SCREEN-GROUP1 = 'GL'.
        SCREEN-ACTIVE = 1.
        MODIFY SCREEN.
      ENDIF.
    ELSE.
      IF SCREEN-GROUP1 = 'GL'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.

    ENDIF.

  ENDLOOP.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0700 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0700 OUTPUT.
  SET PF-STATUS '0700'.
  SET TITLEBAR '0700'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_TEXT_EDIT_0700 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_TEXT_EDIT_0700 OUTPUT.
  IF GO_TEXT_700 IS NOT BOUND.
    PERFORM SET_OBJECT_GO_TEXT_700.
    PERFORM SET_GO_TEXT_700.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_GO_TEXT_700
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GO_TEXT_700 .

  GO_TEXT_700->SET_TOOLBAR_MODE( EXPORTING TOOLBAR_MODE = 0 ).

  GO_TEXT_700->SET_STATUSBAR_MODE( EXPORTING STATUSBAR_MODE = 0 ).

  GO_TEXT_700->SET_READONLY_MODE( EXPORTING READONLY_MODE = 0 ).

  GO_TEXT_700->SET_TEXT_AS_R3TABLE( EXPORTING TABLE = GT_TEXT ).

  CALL METHOD CL_GUI_CFW=>FLUSH
    EXCEPTIONS
      OTHERS = 1.

ENDFORM.
