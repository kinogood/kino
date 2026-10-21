*&---------------------------------------------------------------------*
*& Include          ZGTPPR2120O01
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


    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0101.
    PERFORM SET_LAYOUT_GRID_0101.
    PERFORM SET_FIELDCAT_0101.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0101.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0101.
    PERFORM SET_SORTTAB_GRID_0101.
    PERFORM CALL_GRID_0101_DISPLAY.


  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

*// Event Handler ##
  CASE PO_GRID.
    WHEN GO_GRID_0100.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_HOTSPOT          FOR PO_GRID.
    WHEN GO_GRID_0101.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .

  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
*  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0100-STYLEFNAME = 'XYZSTYLEZYX'.
  GS_LAYOUT_0100-NO_ROWMARK  = ABAP_TRUE.
  GS_LAYOUT_0100-SEL_MODE  = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0100 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : BEGIN OF LS_COLOR,
           WERKS TYPE WERKS_D,
           COLOR TYPE LVC_STYLE,
         END OF LS_COLOR.
  DATA : LT_COLOR LIKE TABLE OF LS_COLOR.
  DATA : LV_SEQ TYPE I.

  LOOP AT GT_MAIN INTO GS_MAIN.
    CLEAR LS_COLOR.
    LS_COLOR-WERKS = GS_MAIN-WERKS.
    COLLECT LS_COLOR INTO LT_COLOR.
  ENDLOOP.
  LOOP AT LT_COLOR ASSIGNING FIELD-SYMBOL(<LS_COLOR>).
    ADD 1 TO LV_SEQ.
    IF LV_SEQ = 2.
      CLEAR LV_SEQ.
    ENDIF.
    CASE LV_SEQ.
      WHEN 0.
        <LS_COLOR>-COLOR = ALV_STYLE_COLOR_INT_KEY.
      WHEN 1.
        <LS_COLOR>-COLOR = ALV_STYLE_COLOR_KEY.
    ENDCASE.

  ENDLOOP.

  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.
  FIELD-SYMBOLS <LV_VALUE> TYPE ANY.

  LOOP AT <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_DATA>).
    CLEAR GS_MAIN.
    MOVE-CORRESPONDING <LS_DATA> TO GS_MAIN.
    READ TABLE LT_COLOR INTO LS_COLOR WITH KEY WERKS = GS_MAIN-WERKS.

    REFRESH LT_CELLTAB.
* 키필드 색상지정
    LOOP AT GT_FIELDCAT_0100 INTO DATA(LS_FCAT).
      CASE LS_FCAT-FIELDNAME.
        WHEN 'MATNR' OR 'MAKTX' OR 'ATWRT' OR 'WERKS' OR 'MEINS' OR 'OVERDUE' OR 'DETAIL'.
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.

          LS_CELLTAB-STYLE = LS_COLOR-COLOR.

*          IF  LS_FCAT-FIELDNAME = 'DETAIL'.
*            LS_CELLTAB-STYLE = LS_COLOR-COLOR + ALV_STYLE_SINGLE_CLK_EVENT.
*          ELSE.
*            LS_CELLTAB-STYLE = LS_COLOR-COLOR.
*          ENDIF.

          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
      ENDCASE.

      IF GV_CHK_EDIT_101 = ABAP_TRUE OR GV_CHK_DETAIL = ABAP_TRUE.
        LOOP AT GT_SPMON INTO GS_SPMON.
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = GS_SPMON-FIELDNAME_A.
          LS_CELLTAB-STYLE = ALV_STYLE_DISABLED.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
        ENDLOOP.
      ELSE.
        LOOP AT GT_SPMON INTO GS_SPMON.
          IF GS_SPMON-TODATE < SY-DATUM.
            CLEAR LS_CELLTAB.
            LS_CELLTAB-FIELDNAME = GS_SPMON-FIELDNAME_A.
            LS_CELLTAB-STYLE = ALV_STYLE_DISABLED.
            INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
          ELSE.
            IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
            ASSIGN COMPONENT GS_SPMON-FIELDNAME_A_CHK OF STRUCTURE <LS_DATA> TO <LV_VALUE>.
            CASE <LV_VALUE>.
              WHEN 'C'.
                CLEAR LS_CELLTAB.
                LS_CELLTAB-FIELDNAME = GS_SPMON-FIELDNAME_A.
                LS_CELLTAB-STYLE = ALV_STYLE_DISABLED + ALV_STYLE_COLOR_BACKGROUND.
                INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
              WHEN 'X'.
                CLEAR LS_CELLTAB.
                LS_CELLTAB-FIELDNAME = GS_SPMON-FIELDNAME_A.
                LS_CELLTAB-STYLE = ALV_STYLE_DISABLED + ALV_STYLE_COLOR_INT_POSITIVE.
                INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
            ENDCASE.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDLOOP.

    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'XYZSTYLEZYX' OF STRUCTURE <LS_DATA> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0100 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0100
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_DESELECT_ALL,
                CL_GUI_ALV_GRID=>MC_FC_DETAIL,
                CL_GUI_ALV_GRID=>MC_FC_SELECT_ALL,
                CL_GUI_ALV_GRID=>MC_FC_DELETE_FILTER,
                CL_GUI_ALV_GRID=>MC_FC_FILTER,
                CL_GUI_ALV_GRID=>MC_FC_SORT_ASC,
                CL_GUI_ALV_GRID=>MC_FC_SORT_DSC,
                CL_GUI_ALV_GRID=>MC_FC_SUBTOT,
                CL_GUI_ALV_GRID=>MC_FC_SUM,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FG_SORT,
                CL_GUI_ALV_GRID=>MC_MB_SUM,
*                CL_GUI_ALV_GRID=>MC_MB_VARIANT,
                CL_GUI_ALV_GRID=>MC_MB_VIEW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.

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
*& Form SET_SORTTAB_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0100 .

  PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                                  USING : 1 'WERKS'  'X' '' '',
                                             2 'MATNR'  'X' '' '',
                                             2 'MAKTX'  'X' '' '',
                                             3 'SEQ_ATWRT'  'X' '' '',
                                             4 'ATWRT'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_sort_tab
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SORT_0100
*&      --> P_1
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SORT_TAB  TABLES   PT_SORTTAB STRUCTURE LVC_S_SORT
                   USING    PV_POS
                               PV_FIELDNAME
                               PV_UP
                               PV_DOWN
                               PV_SUBTOT.

  DATA : LS_SORT TYPE LVC_S_SORT.
  LS_SORT-SPOS = PV_POS.
  LS_SORT-FIELDNAME = PV_FIELDNAME.
  LS_SORT-UP = PV_UP.
  LS_SORT-DOWN = PV_DOWN.
  LS_SORT-SUBTOT =  PV_SUBTOT.
  APPEND LS_SORT TO PT_SORTTAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0100_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .

  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
    CHANGING
      IT_OUTTAB            = <GT_MAIN_DISP_100>
      IT_SORT              = GT_SORT_0100
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

  IF GO_DD_DOCU_0100 IS BOUND.
    CALL METHOD GO_DD_DOCU_0100->INITIALIZE_DOCUMENT.
  ELSE.
    CREATE OBJECT GO_DD_DOCU_0100
      EXPORTING
        STYLE = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD GO_GRID_0100->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DD_DOCU_0100.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
