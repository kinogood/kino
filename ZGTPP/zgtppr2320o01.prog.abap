*&---------------------------------------------------------------------*
*& Include          ZGTPPR2320O01
*&---------------------------------------------------------------------*
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
    PERFORM SET_DROPDOWN_GRID_0200.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0200.
    PERFORM CALL_GRID_0200_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0200 .

  CREATE OBJECT GO_CONTAIN_0200
    EXPORTING
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 10000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.

  CREATE OBJECT GO_GRID_0200
    EXPORTING
      I_PARENT      = GO_CONTAIN_0200
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0200
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
      CASE GV_ZTYPE.
        WHEN 'A'.
          SET HANDLER GO_EVENT_HANDLER->HANDLE_ON_F4        FOR PO_GRID.
      ENDCASE.
    WHEN GO_GRID_0200.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
    WHEN GO_GRID_0300.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_ON_F4        FOR PO_GRID.
    WHEN GO_GRID_0400.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED_FINISHED  FOR PO_GRID.
      CASE GV_ZTYPE.
        WHEN 'B'.
          SET HANDLER GO_EVENT_HANDLER->HANDLE_ON_F4        FOR PO_GRID.
      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0200 .

  DATA : LV_TEXT1 TYPE CHAR100.
  DATA : LV_TEXT2 TYPE CHAR100.

  CLEAR GS_LAYOUT_0200.
  GS_LAYOUT_0200-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0200-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0200-SEL_MODE   = 'D'.
  GS_LAYOUT_0200-STYLEFNAME   = 'CELLTAB'.
  GS_LAYOUT_0200-SMALLTITLE = 'X'.
  CLEAR LV_TEXT1.
  CONCATENATE '플랜트 :' P_WERKS GV_NAME1 INTO LV_TEXT1 SEPARATED BY SPACE.
  LV_TEXT1 = LV_TEXT1 && ','.

  CLEAR LV_TEXT2.
  CONCATENATE 'SPG :' P_SPGCD GV_DESCR INTO LV_TEXT2 SEPARATED BY SPACE.

  CONCATENATE LV_TEXT1 LV_TEXT2 INTO GS_LAYOUT_0200-GRID_TITLE SEPARATED BY SPACE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0200 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2320TOP'
      I_INTERNAL_TABNAME     = 'GS_MAINTAIN'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0200.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0200[]
    TABLES
      IT_DATA         = GT_MAINTAIN
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0200 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'STATUS'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.

    <LS_FCAT>-FIELDNAME = 'STATUS'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 12.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.

  ENDIF.


  LOOP AT GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'CPROG' OR 'SEQNO'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'(F01).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트 내역'(F02).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'SPGCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SPG'(F03).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'DESCR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SPG 내역'(F04).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'MAIL_TYPE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수신 구분'(F05).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-DRDN_HNDL = '1'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'NAME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '성명'(F06).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'DEPT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '부서'(F07).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'MAIL_ADDR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '이메일 주소'(F08).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'ACTIVE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '활성여부'(F09).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-CHECKBOX = 'X'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0200 .

  REFRESH GT_EXCLUDE_0200.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0200
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*-----------------------------------------------------------------------
**
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.
  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.
ENDFORM.                    " add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0200_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0200_DISPLAY .

  CALL METHOD GO_GRID_0200->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0200
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0200
    CHANGING
      IT_OUTTAB            = GT_MAINTAIN
      IT_FIELDCATALOG      = GT_FIELDCAT_0200.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0200->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0200->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DROPDOWN_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DROPDOWN_GRID_0200 .

  DATA: LT_DRAL TYPE LVC_T_DRAL,                            "#EC NEEDED
        LS_DRAL TYPE LVC_S_DRAL.                            "#EC NEEDED

  LS_DRAL-HANDLE = '1'.
  LS_DRAL-INT_VALUE = '수신'.
  LS_DRAL-VALUE = 'TO'.

  APPEND LS_DRAL TO LT_DRAL.

  LS_DRAL-HANDLE = '1'.
  LS_DRAL-INT_VALUE = '참조'.
  LS_DRAL-VALUE = 'CC'.
  APPEND LS_DRAL TO LT_DRAL.

  GO_GRID_0200->SET_DROP_DOWN_TABLE(
    IT_DROP_DOWN_ALIAS = LT_DRAL ).


ENDFORM.
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
    PERFORM SET_F4_FIELD_GRID_0300.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0300 .
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0300.
    PERFORM CALL_GRID_0300_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'.
  CASE GV_ZTYPE.
    WHEN 'A'.
      SET TITLEBAR '0100' WITH 'MTS'.
    WHEN 'B'.
      SET TITLEBAR '0100' WITH '구다이스'.
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
    PERFORM SET_F4_FIELD_GRID_0100.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0100 .
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0100.
    PERFORM CALL_GRID_0100_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0400 OUTPUT.
  SET PF-STATUS '0400'.
  CASE GV_ZTYPE.
    WHEN 'A'.
      SET TITLEBAR '0400' WITH 'MTS'.
    WHEN 'B'.
      SET TITLEBAR '0400' WITH '구다이스'.
  ENDCASE.
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
    PERFORM SET_F4_FIELD_GRID_0400.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0400.
    PERFORM CALL_GRID_0400_DISPLAY.
  ENDIF.
ENDMODULE.
