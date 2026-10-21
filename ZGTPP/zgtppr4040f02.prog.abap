*&---------------------------------------------------------------------*
*& Include          ZGTPPR4040F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_object_grid_0100
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0100 .

  CREATE OBJECT GO_DOCKING_CONTAINER
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
*화면 분할
  CREATE OBJECT GO_SPLITTER
    EXPORTING
      PARENT  = GO_DOCKING_CONTAINER
      ROWS    = 2
      COLUMNS = 1.

  GO_SPLITTER->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    35 ).             " Height
* top 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0100.
* bottom 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0101.

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_handler_register
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.
* CREATE OBJECT go_events.
  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.
*// Event Handler ##
  SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR      FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK FOR PO_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0100
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .

  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0100-SMALLTITLE = ABAP_TRUE.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.
  GS_LAYOUT_0100-STYLEFNAME = 'CELLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0100
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR4040TOP'
      I_INTERNAL_TABNAME     = 'GS_DISP'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_DISP
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ICON'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '상태'(f01).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '자재 코드'(f02).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '자재 내역'(f03).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'CHARG'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '배치 번호'(f04).
        <LS_FCAT>-JUST = 'C'.
        IF P_BWD = ABAP_TRUE.
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDIF.
      WHEN 'LGORT'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '저장위치'(f05).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'BTEXT'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '재고 유형'(f06).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MEINS'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '단위'(f07).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'JEGO'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '재고 수량'(f08).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'SILSA'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '실사 수량'(f09).
        <LS_FCAT>-JUST = 'R'.
        IF P_BWD = ABAP_TRUE.
          <LS_FCAT>-EDIT = ABAP_TRUE.
        ENDIF.
      WHEN 'CHAI'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '차이량'(f10).
        <LS_FCAT>-JUST = 'R'.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_cell_attribute_grid_0100
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0100 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

*  LOOP AT gt_header ASSIGNING FIELD-SYMBOL(<ls_header>).
*    REFRESH lt_celltab.
*    IF gv_dis_mode = 'D'.
*    ELSE.
*      LOOP AT gt_fieldcat_0100 INTO DATA(ls_fcat).
*        IF <ls_header>-chk_chg = 'N'. " 라인추가시 변경불가필드 세팅
*          CASE ls_fcat-fieldname.
*            WHEN 'STATUS'.
*              CONTINUE.
*          ENDCASE.
*        ELSE. " 변경불가필드 세팅
*          CASE <ls_header>-status.
*            WHEN icon_led_yellow.
*              CASE ls_fcat-fieldname.
*                WHEN 'STATUS'.
*                  CONTINUE.
*              ENDCASE.
*            WHEN icon_led_green.
*              CASE ls_fcat-fieldname.
*                WHEN 'STATUS' OR 'MODULE_KIND' OR 'CODEGRP' OR 'FLDNR'.
*                  CONTINUE.
*              ENDCASE.
*          ENDCASE.
*
*        ENDIF.
*        CLEAR ls_celltab.
*        __set_cell_attribute ls_fcat-fieldname cl_gui_alv_grid=>mc_style_enabled.
*        INSERT ls_celltab INTO TABLE lt_celltab.
*      ENDLOOP.
*    ENDIF.
*    <ls_header>-celltab = lt_celltab.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_of_toolbar_grid_0100
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0100 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0100
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
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
*& Form add_exclude_toolbar_button
*&---------------------------------------------------------------------*
FORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES P_TABLE USING P_VALUE.

  DATA: L_EXCLUDE TYPE UI_FUNC.

  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_grid_0100_display
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .

  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
    CHANGING
      IT_OUTTAB            = GT_DISP
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.
* 인풋이벤트 추가
  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK USING P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                        P_ROW TYPE LVC_S_ROW
                        P_COLUMN TYPE LVC_S_COL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed
*&---------------------------------------------------------------------*
FORM DATA_CHANGED USING P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                        PO_DATA_CHANGED TYPE REF TO
                                        CL_ALV_CHANGED_DATA_PROTOCOL
                        PE_ONF4 TYPE CHAR1
                        PE_UCOMM.

  DATA : LS_MOD_CELLS TYPE LVC_S_MODI,
         LS_CELLS     TYPE LVC_S_MODI.

  DATA : LV_ERFMG  LIKE MSEG-ERFMG.
  DATA : LV_CHK_ERR.
  DATA : LV_MENGE TYPE MSEG-MENGE.
  DATA : LV_MENGE2 TYPE MSEG-MENGE.
  DATA : LV_VALUE TYPE LVC_S_MODI-VALUE.

  DEFINE __MODI_CELL.
    PO_DATA_CHANGED->MODIFY_CELL(
      I_ROW_ID     = &1                 " Row ID
      I_FIELDNAME = &2                 " Field Name
      I_VALUE       = &3 ).               " Value
  END-OF-DEFINITION.

  DEFINE __SET_ERR_MSG.
    lv_chk_err = abap_true.
    po_data_changed->add_protocol_entry(
        i_msgid     = 'ZGTPP00'                 " Message ID
        i_msgty     = 'E'                 " Message Type
        i_msgno     =  '03'                " Message No.
        i_msgv1     =  &1                " Message Variable1
        i_fieldname =  &2                " Field Name
        i_row_id    =  ls_mod_cells-row_id ).                " RowID
  END-OF-DEFINITION.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      LOOP AT PO_DATA_CHANGED->MT_MOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'SILSA'.
            NEW ZGTPP_CL_CONV( )->CONVERT_STRING_TO_QTY( EXPORTING IV_INPUT  = CONV #( LS_MOD_CELLS-VALUE )
                                               IMPORTING EV_OUTPUT = LV_MENGE ).
            IF LV_MENGE = 0.
              __MODI_CELL LS_MOD_CELLS-ROW_ID 'CHAI' LV_MENGE.
              __MODI_CELL LS_MOD_CELLS-ROW_ID 'ICON' ICON_LED_INACTIVE.
            ELSE.
              CLEAR LV_MENGE2.
              READ TABLE GT_DISP INTO DATA(LS_DISP) INDEX LS_MOD_CELLS-ROW_ID.
              LV_MENGE2 = LV_MENGE - LS_DISP-JEGO.
              IF LV_MENGE2 < 0.
                __SET_ERR_MSG '선택 옵션은 투입 취소만 가능합니다.' LS_MOD_CELLS-FIELDNAME.
              ELSE.
                __MODI_CELL LS_MOD_CELLS-ROW_ID 'CHAI' LV_MENGE2.
                __MODI_CELL LS_MOD_CELLS-ROW_ID 'ICON' ICON_LED_GREEN.
              ENDIF.
            ENDIF.
        ENDCASE.
      ENDLOOP.
    WHEN GO_GRID_0101.

      LOOP AT PO_DATA_CHANGED->MT_MOD_CELLS INTO LS_MOD_CELLS.

        IF LS_MOD_CELLS-VALUE IS NOT INITIAL.

          CLEAR GS_DISP2.
          READ TABLE GT_DISP2 INTO GS_DISP2 INDEX LS_MOD_CELLS-ROW_ID.

          CASE LS_MOD_CELLS-FIELDNAME.

            WHEN 'ERFMG5'. "조정량

              REPLACE ALL OCCURRENCES OF ',' IN LS_MOD_CELLS-VALUE WITH ''.
              CONDENSE LS_MOD_CELLS-VALUE NO-GAPS.
              GS_DISP2-ERFMG5 = LS_MOD_CELLS-VALUE. "입력값 반영

              CALL METHOD PO_DATA_CHANGED->MODIFY_CELL
                EXPORTING
                  I_ROW_ID    = LS_MOD_CELLS-ROW_ID
                  I_FIELDNAME = 'ERFMG5'
                  I_VALUE     = GS_DISP2-ERFMG5.

            WHEN  OTHERS.

          ENDCASE.
* 음수 : 투입량 초과 또는 동일 시 에러 표시.
          LV_ERFMG = GS_DISP2-ERFMG5.
          IF LV_ERFMG < 0.
            LV_ERFMG = LV_ERFMG * -1.
            IF GS_DISP2-ERFMG2 =< LV_ERFMG.
              GS_DISP2-ICON = ICON_LED_RED.
            ELSE.
              GS_DISP2-ICON = ICON_LED_INACTIVE.
            ENDIF.
* 조정량이 비어있으면 에러 표시
          ELSEIF GS_DISP2-ERFMG5 = 0.
            GS_DISP2-ICON = ICON_LED_RED.
          ELSE.
            GS_DISP2-ICON = ICON_LED_INACTIVE.
          ENDIF.

          CALL METHOD PO_DATA_CHANGED->MODIFY_CELL
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = 'ICON'
              I_VALUE     = GS_DISP2-ICON.

        ENDIF.

      ENDLOOP.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_pros
*&---------------------------------------------------------------------*
FORM USER_COMMAND_PROS USING PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                             PV_UCOMM.

  CASE PV_UCOMM.
    WHEN 'EXEC'."차이량 배부

      CLEAR : GS_ROW, GT_ROW.
      CALL METHOD PO_SENDER->GET_SELECTED_ROWS
        IMPORTING
          ET_INDEX_ROWS = GT_ROW.
* 선택한 차이량 배부 대상 라인 상태 점검 후 이상 없으면 실사 자재 취합
      PERFORM SELECT_LINE_CHECK.

      CHECK GT_SILSA[] IS NOT INITIAL.
* 투입 데이터 취합
      PERFORM GET_DATA_FROM_MSEG.
* 생산오더조정 데이터 취합
      PERFORM COLLEC_PROD_ORDER_ADJUSTMENT.
* 가중치(%), 계산 투입량, 조정량 계산
      PERFORM CALCULATE_FINAL_DATA.

      SORT GT_DISP2 BY AUFNR.

      IF GT_DISP2[] IS INITIAL.
        MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E03.
      ENDIF.

      PERFORM REFRESH_GRID_0101.

    WHEN 'EXEC2'. "생산 오더 투입량 조정

      CLEAR : GS_ROW, GT_ROW.
      CALL METHOD PO_SENDER->GET_SELECTED_ROWS
        IMPORTING
          ET_INDEX_ROWS = GT_ROW.

      DELETE GT_ROW WHERE INDEX IS INITIAL.
* 실사차 조정 건 선택( 오류건 포함 선택 시 에러 메시지 )
      PERFORM SELECT_LINE_CHECK2.

      CHECK GV_EXIT IS INITIAL.

      PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
        ' '
        '생산 오더 투입량 조정을 진행하시겠습니까?'(m03)
        '작업확인'(006).

      IF GV_ANSWER = 'J'.
* 오더별 실사차 차이 조정 자재 문서 생성
        IF P_BWD = ABAP_TRUE.
          PERFORM ADJUST_GI_PROD_ORDER_BWD.
        ELSE.
          IF P_WERKS+0(1) = '6' AND P_ALL = ABAP_TRUE.
            PERFORM ADJUST_GI_PROD_ORDER_GAON.
          ELSE.
            PERFORM ADJUST_GI_PROD_ORDER.
          ENDIF.
        ENDIF.

      ENDIF.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form toolbar_pros
*&---------------------------------------------------------------------*
FORM TOOLBAR_PROS USING PO_SENDER
                        PO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                        R_INTERACTIVE.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.

      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
        USING : 'EXEC' ICON_MASS_CHANGE TEXT-B01 TEXT-B01 0.

    WHEN GO_GRID_0101.

      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
        USING : 'EXEC2' ICON_EXECUTE_OBJECT TEXT-B02 TEXT-B02 0.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TOOLBAR
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR TABLES PT_TOOLBAR STRUCTURE STB_BUTTON
                  USING PV_FUNCTION
                        PV_ICON
                        PV_TEXT
                        PV_QUICKINFO
                        PV_BUTN_TYPE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION  = PV_FUNCTION.
  LS_TOOLBAR-ICON      = PV_ICON.
  LS_TOOLBAR-TEXT      = PV_TEXT.
  LS_TOOLBAR-QUICKINFO = PV_QUICKINFO.
  LS_TOOLBAR-BUTN_TYPE = PV_BUTN_TYPE.
  APPEND LS_TOOLBAR TO PT_TOOLBAR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID_0101
*&---------------------------------------------------------------------*
FORM REFRESH_GRID_0101 .

  IF GO_GRID_0101 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0101.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0101.
    PERFORM SET_LAYOUT_GRID_0101.
    PERFORM SET_FIELDCAT_GRID_0101.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0101.
    PERFORM CALL_GRID_0101_DISPLAY.
  ELSE.
    PERFORM REFRESH_GRID USING GO_GRID_0101.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_grid
*&---------------------------------------------------------------------*
FORM REFRESH_GRID USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  PERFORM SET_LAYOUT_GRID_0101.
  PERFORM SET_FIELDCAT_GRID_0101.

  CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYOUT_0101.                 " Layout

  CALL METHOD PO_GRID->SET_FRONTEND_FIELDCATALOG
    EXPORTING
      IT_FIELDCATALOG = GT_FIELDCAT_0101.                 " Field Catalog

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0101
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0101 .
* bottom 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0101.

  CREATE OBJECT GO_GRID_0101
    EXPORTING
      I_PARENT      = GO_CONTAIN_0101
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0101
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0101 .

  CLEAR GS_LAYOUT_0101.
  GS_LAYOUT_0101-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0101-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0101-SMALLTITLE = ABAP_TRUE.
  GS_LAYOUT_0101-SEL_MODE   = 'D'.
  GS_LAYOUT_0101-STYLEFNAME = 'CELLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0101
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0101 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR4040TOP'
      I_INTERNAL_TABNAME     = 'GS_DISP2'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0101.
*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0101[]
    TABLES
      IT_DATA         = GT_DISP2
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0101 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ICON'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '상태'(f01).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'WERKS'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '플랜트'(f11).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PDCAPROCCODE'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '공정 코드'(f12).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ARBPL'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '설비 코드'(f13).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'AUFNR'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '생산 오더'(f17).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '생산(반)제품'(f14).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '내역'(f15).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'MENGE1'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '입고량'(f16).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS1'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '입고 단위'(f18).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR2'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '투입 자재'(f19).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX2'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '내역'(f15).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'CHARG2'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '투입 배치'(f20).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'LGORT2'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '투입 저장위치'(f21).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ERFMG2'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '투입량'(f22).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'ERFME2'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '투입 단위'(f23).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MENGE3'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '가중치(%)'(f24).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MENGE4'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '계산 투입량'(f25).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'LGORT5'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '조정 저장위치'(f29).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'CHARG5'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '조정 배치'(f28).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ERFMG5'.
        CLEAR : <LS_FCAT>-REF_FIELD, <LS_FCAT>-REF_TABLE.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '조정량'(f26).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-DECIMALS = 3.
        <LS_FCAT>-QFIELDNAME = 'ERFME2'.
      WHEN 'MESSAGE'.
        <LS_FCAT>-SCRTEXT_S = <LS_FCAT>-SCRTEXT_M = <LS_FCAT>-SCRTEXT_L =
        <LS_FCAT>-REPTEXT = '처리 결과'(f27).
        <LS_FCAT>-JUST = 'L'.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_of_toolbar_grid_0101
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0101 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0101
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
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
*& Form call_grid_0101_display
*&---------------------------------------------------------------------*
FORM CALL_GRID_0101_DISPLAY .

  CALL METHOD GO_GRID_0101->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0101
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0101
    CHANGING
      IT_OUTTAB            = GT_DISP2
      IT_FIELDCATALOG      = GT_FIELDCAT_0101.
* 인풋이벤트 추가
  CALL METHOD GO_GRID_0101->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0101->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_display_all_alv
*&---------------------------------------------------------------------*
FORM REFRESH_DISPLAY_ALL_ALV .

  CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = GS_SCROLL.

  PERFORM REFRESH_GRID USING GO_GRID_0101.

*  CALL METHOD go_grid_0101->refresh_table_display
*    EXPORTING
*      i_soft_refresh = 'X'
*      is_stable      = gs_scroll.

ENDFORM.
