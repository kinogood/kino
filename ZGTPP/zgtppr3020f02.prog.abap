*&---------------------------------------------------------------------*
*&  Include           ZPPR0025F02                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<TABLE>  text
*      -->P_CL_GUI_ALV_GRID=>MC_FC_LOC_UND  text
*----------------------------------------------------------------------*
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   PT_TABLE
                                 USING    PV_VALUE.

  DATA: LV_EXCLUDE TYPE UI_FUNC.

  LV_EXCLUDE = PV_VALUE.
*& 결과적으로 GT_EXCLUDE에 제거할 버튼 저장
  APPEND LV_EXCLUDE TO PT_TABLE.

ENDFORM.                    " add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*&      Form  control_style
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--PT_STYL  text
*----------------------------------------------------------------------*
FORM CONTROL_STYLE CHANGING PT_STYL TYPE LVC_T_STYL.

  DATA : LS_STYL TYPE LVC_S_STYL,
         LV_MODE TYPE RAW4.
  DATA : LS_FIELDCAT   TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT_0100  INTO LS_FIELDCAT.
    LS_STYL-FIELDNAME = LS_FIELDCAT-FIELDNAME.

    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'AUFNR' OR 'MATNR' OR 'KDAUF' OR 'QMCNT'.
        LS_STYL-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                         CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        LS_STYL-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK.
        INSERT LS_STYL INTO TABLE PT_STYL.

      WHEN 'BUTTON' OR 'STOCK' OR 'ETC' OR 'BUTTON2'.
        LS_STYL-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
        INSERT LS_STYL   INTO TABLE PT_STYL.

      WHEN  OTHERS.
        LS_STYL-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
        LS_STYL-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
        INSERT LS_STYL   INTO TABLE PT_STYL.

    ENDCASE.

  ENDLOOP.

ENDFORM.                    " control_style
*&---------------------------------------------------------------------*
*&      Form  control_color
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--PT_SCOL  text
*----------------------------------------------------------------------*
FORM CONTROL_COLOR  CHANGING PT_SCOL TYPE LVC_T_SCOL.

  DATA : LS_STYL TYPE LVC_S_STYL,
         LS_SCOL TYPE LVC_S_SCOL,
         LV_MODE TYPE RAW4.
  DATA : LV_PSMNG LIKE GT_AFKO-PSMNG.

  DATA : LS_FIELDCAT TYPE LVC_S_FCAT.

  CLEAR LV_PSMNG.
  IF GT_AFKO-POSNR = '0001'.
    LOOP AT GT_AFKO_S WHERE AUFNR = GT_AFKO-AUFNR.
      LV_PSMNG = LV_PSMNG + GT_AFKO_S-PSMNG.
    ENDLOOP.
  ENDIF.

  LOOP AT GT_FIELDCAT_0100 INTO LS_FIELDCAT.
    LS_SCOL-FNAME = LS_FIELDCAT-FIELDNAME.
    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'PROCD' OR 'SEQNO' OR 'ARBPL' OR 'AUFNR' OR 'POSNR' OR 'KTEXT'.
        LS_SCOL-COLOR-COL = 1.
        LS_SCOL-COLOR-INT = 1.

*      WHEN 'CLRTX'.
*
*        IF gt_afko-clrtx IS NOT INITIAL.
*          ls_scol-color-col = 1.
*          ls_scol-color-int = 1.
*        ENDIF.
*- Start 2025.01.07
      WHEN 'DELAY' OR 'DEL_TIME' OR 'EXCLUD_GUID'.
        LS_SCOL-COLOR-COL = 3.
        LS_SCOL-COLOR-INT = 0.

      WHEN 'CGMENGE' OR 'BADMENGE' OR 'ENDMENGE'.
        LS_SCOL-COLOR-COL = 5.
        LS_SCOL-COLOR-INT = 0.

      WHEN 'YEAPT' OR 'CGT' OR 'BADT' OR 'ENDT' OR 'TIMEM'.
        LS_SCOL-COLOR-COL = 6.
        LS_SCOL-COLOR-INT = 0.
*- End 2024.01.07
*- Start 2025.01.20
      WHEN 'WEMNG'.
        IF GT_AFKO-POSNR = '0001'
          AND GT_AFKO-WEMNG > LV_PSMNG.
          LS_SCOL-COLOR-COL = 6.
          LS_SCOL-COLOR-INT = 0.
          LS_SCOL-COLOR-INV = 1.
          GT_AFKO-AUFNR_E = 'X'.
          GT_AFKO-IPGO = 'X'.
        ENDIF.
      WHEN 'LMNGA'.
        IF GT_AFKO-POSNR = '0001'
          AND GT_AFKO-LMNGA > LV_PSMNG.
          LS_SCOL-COLOR-COL = 6.
          LS_SCOL-COLOR-INT = 0.
          LS_SCOL-COLOR-INV = 1.
          GT_AFKO-AUFNR_E = 'X'.
          GT_AFKO-SILJEOK = 'X'.
        ENDIF.
*- End 2025.01.20
      WHEN  OTHERS.
        LS_SCOL-COLOR-COL = 2.
        LS_SCOL-COLOR-INT = 0.

    ENDCASE.

    INSERT LS_SCOL INTO TABLE PT_SCOL.
    CLEAR LS_SCOL.

  ENDLOOP.

ENDFORM.                    " control_color
*&---------------------------------------------------------------------*
*&      Form  event_handler_register
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.
*& Edit  이벤트 등록
* IF MC_EVT_MODIFY  -> 바로 수정됨.
  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  IF PO_GRID NE GO_GRID_0102.
*& Event Handler 등록
    CREATE OBJECT GO_EVENT_HANDLER.

    SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR
            FOR PO_GRID.
    SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND
            FOR PO_GRID.
    SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED
            FOR PO_GRID.
    SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED_FINISHED
            FOR PO_GRID.
    SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK
            FOR PO_GRID.
    SET HANDLER GO_EVENT_HANDLER->HANDLE_AFTER_USER_COMMAND
            FOR PO_GRID.
    SET HANDLER GO_EVENT_HANDLER->HANDLE_BUTTON_CLICK
            FOR PO_GRID.
    SET HANDLER GO_EVENT_HANDLER->HANDLE_ONF4
            FOR PO_GRID.

    SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE
            FOR PO_GRID.

    SET HANDLER GO_EVENT_HANDLER->HANDLE_CONTEXT_MENU
            FOR PO_GRID.

  ENDIF.

ENDFORM.                    " event_handler_register
*&---------------------------------------------------------------------*
*&      Form  toolbar_proc
*&---------------------------------------------------------------------*
FORM TOOLBAR_PROC USING R_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                        R_INTERACTIVE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

  MOVE   3                  TO  LS_TOOLBAR-BUTN_TYPE.
  APPEND LS_TOOLBAR         TO  R_OBJECT->MT_TOOLBAR.

  CLEAR LS_TOOLBAR.
  MOVE 'REFRESH'            TO  LS_TOOLBAR-FUNCTION.
  MOVE  ICON_REFRESH        TO  LS_TOOLBAR-ICON.
  MOVE TEXT-075           TO  LS_TOOLBAR-QUICKINFO.
*&  MOVE '최신표시'           TO  ls_toolbar-text.
  MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
  APPEND LS_TOOLBAR         TO  R_OBJECT->MT_TOOLBAR.

*  CLEAR ls_toolbar.
*  MOVE 'INFO'            TO  ls_toolbar-function.
*  MOVE  icon_system_extended_help TO  ls_toolbar-icon.
*  MOVE '범례'           TO  ls_toolbar-quickinfo.
**&  MOVE '최신표시'           TO  ls_toolbar-text.
*  MOVE ' '                  TO  ls_toolbar-disabled.
*  APPEND ls_toolbar         TO  r_object->mt_toolbar.

  MOVE   3                  TO  LS_TOOLBAR-BUTN_TYPE.
  APPEND LS_TOOLBAR         TO  R_OBJECT->MT_TOOLBAR.

ENDFORM.                    " toolbar_proc
*&---------------------------------------------------------------------*
*&      Form  user_command_proc
*&---------------------------------------------------------------------*
FORM USER_COMMAND_PROC USING R_UCOMM.

  CASE R_UCOMM.
    WHEN 'REFRESH'.
*      PERFORM select_proc.
*      PERFORM additional_info_proc.

      PERFORM INITIAL_PROC.
*- Start 2024.10.16 RESB에서 투입정보를 가져오기 위해 오더번호만 취합
      CLEAR : GT_ORDER, GT_ORDER[], GT_RESB2, GT_RESB2[], GT_AFRU, GT_AFRU[],
                  GT_AFPO, GT_AFPO[].
*- End 2024.10.16
*- Start 2025.02.20 작업시작일자 조회 조건 존재 시 최대적중수 CLEAR 할 것
      IF S_PAYOFF[] IS NOT INITIAL.
        CLEAR P_DBCNT.
      ENDIF.

      IF S_STATUS-LOW = ' '.
        PERFORM SELECT_PROC.  "ALL
      ELSEIF S_STATUS-LOW = 'A'.
        PERFORM SELECT_PROC1.  "작업지시전...
      ELSE.
        PERFORM SELECT_PROC2.  "작업대기..오더종료
      ENDIF.
*- Start 2024.10.16 신규 필드 상태값 체크를 위한 데이터 취합
      PERFORM GET_DATA_NEW_FIELD.
*- End 2024.10.16
      PERFORM ADDITIONAL_INFO_PROC.

    WHEN  OTHERS.

  ENDCASE.

ENDFORM.                    " user_command_proc
*&---------------------------------------------------------------------*
*&      Form  after_user_command
*&---------------------------------------------------------------------*
FORM AFTER_USER_COMMAND  USING    E_UCOMM.
  CASE E_UCOMM.
    WHEN 'REFRESH'.
      PERFORM REFRESH_GT_AFKO_DISPLAY.
    WHEN  OTHERS.
  ENDCASE.
ENDFORM.                    " after_user_command
*&---------------------------------------------------------------------*
*&      Form  data_changed
FORM DATA_CHANGED USING RR_DATA_CHANGED
                               TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                        E_ONF4 TYPE CHAR1.

  DATA: LT_DELTA_CELLS   TYPE LVC_T_MODI,
        LS_DELTA_CELLS   TYPE LVC_S_MODI,
        LS_MODIFIED      TYPE CHAR01,
        LS_FRONTEND_ONLY TYPE CHAR01,
        FNAME(20).

  DATA : LS_MOD_CELLS TYPE LVC_S_MODI,
         LS_CELLS     TYPE LVC_S_MODI,
         LS_LIPS      LIKE GT_AFKO.

  TYPES S_DATA           LIKE GT_AFKO OCCURS 0 .
  FIELD-SYMBOLS : <DATA> TYPE S_DATA.

*  LOOP AT rr_data_changed->mt_good_cells INTO ls_mod_cells.
*    READ TABLE GT_AFKO INDEX ls_mod_cells-row_id.
*
*    CASE ls_mod_cells-fieldname.
*      WHEN 'BSTMG'.   "오더수량
*        IF GT_AFKO-menge < ls_mod_cells-value.
*          PERFORM data_input_error USING rr_data_changed
*                                         ls_mod_cells
*                                        'E'
*                 '납품수량을 초과하였습니다...'
*                                         ls_mod_cells-fieldname.
*        ENDIF.
*      WHEN  OTHERS.
*    ENDCASE.
*  ENDLOOP.

ENDFORM.                    " data_changed
*&---------------------------------------------------------------------*
*&      Form  data_changed_finished
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_MODIFIED  text
*      -->P_ET_GOOD_CELLS  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED  USING    E_MODIFIED    TYPE CHAR01
                                     ET_GOOD_CELLS TYPE LVC_T_MODI.

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI.
  DATA: LT_LIPS      LIKE GT_AFKO OCCURS 0 WITH HEADER LINE.

  IF E_MODIFIED = 'X'.
    CLEAR: GV_TITLE.

*    PERFORM set_cell_attribute_grid_0100.
    GV_TITLE = TEXT-076."생산오더 릴리즈(기타)

*&    CALL METHOD gcl_grid->set_gridtitle
*&      EXPORTING
*&        i_gridtitle = gv_title.

    GS_SCROLL-ROW = 'X'.
    GS_SCROLL-COL = 'X'.

    CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = 'X'
        IS_STABLE      = GS_SCROLL.     "현재 그대로 입력한 refresh

  ENDIF.

ENDFORM.                    " data_changed_finished
*&---------------------------------------------------------------------*
*&      Form  hotspot_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM HOTSPOT_CLICK  USING P_ROW_ID P_COLUMN_ID.
ENDFORM.                    " hotspot_click
*&---------------------------------------------------------------------*
*&      Form  double_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW  text
*      -->P_E_COLUMN  text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING    E_ROW
                            E_COLUMN.

  DATA : BEGIN OF LT_OBJECTX OCCURS 10.
           INCLUDE STRUCTURE IOPICK.
  DATA : END   OF LT_OBJECTX.

  READ TABLE GT_AFKO INDEX E_ROW.
  CASE E_COLUMN.
    WHEN 'AUFNR'.
*[U01] 가온전선 추가
      IF SY-TCODE EQ 'ZGTPPR3020G'.
        READ TABLE GT_AFKO INDEX E_ROW.

        CHECK GT_AFKO-AUFNR IS NOT INITIAL.

        SET PARAMETER ID 'ANR' FIELD GT_AFKO-AUFNR.
        CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

      ELSE.
*[U01] 가온전선 추가
        DATA: LF_PRGRM(1)  TYPE C  VALUE 'X'.   "프로그램 호출시 플래그

        READ TABLE GT_AFKO INDEX E_ROW.

        SET PARAMETER ID 'WRK' FIELD P_PWERK.
        SET PARAMETER ID 'ANR' FIELD GT_AFKO-AUFNR.
        SET PARAMETER ID 'VGN' FIELD GT_AFKO-VORNR.
        SET PARAMETER ID 'KMH' FIELD LF_PRGRM.
        CALL TRANSACTION 'ZPPM0021'  AND SKIP FIRST SCREEN.

*&      SET PARAMETER ID 'ANR' FIELD gt_afko-aufnr.
*&      CALL TRANSACTION 'CO03'  AND SKIP FIRST SCREEN.
      ENDIF.  "[U01] 가온전선 추가

    WHEN 'MATNR'.
      REFRESH: LT_OBJECTX.   CLEAR LT_OBJECTX.
      MOVE 'PLAF-MATNR'         TO LT_OBJECTX-NAME.
      MOVE  GT_AFKO-MATNR       TO LT_OBJECTX-VALUE.
      APPEND LT_OBJECTX.

      MOVE 'PLAF-PLWRK'         TO LT_OBJECTX-NAME.
      MOVE  P_PWERK             TO LT_OBJECTX-VALUE.
      APPEND LT_OBJECTX.

      MOVE '%D'                 TO LT_OBJECTX-NAME.
      MOVE 'D'                  TO LT_OBJECTX-VALUE.
      APPEND LT_OBJECTX.

      CALL FUNCTION 'MASTER_DATA'
        EXPORTING
          PROGRAM          = 'SAPLM61O'
          DATENFELD        = 'PLAF-MATNR'
        TABLES
          IOBJECT          = LT_OBJECTX
        EXCEPTIONS
          OBJECT_NOT_FOUND = 1
          FIELD_IS_INITIAL = 2
          OTHERS           = 3.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY
                          NUMBER SY-MSGNO
                            WITH SY-MSGV1 SY-MSGV2
                                 SY-MSGV3 SY-MSGV4.
      ENDIF.

    WHEN 'KDAUF'.
      SET PARAMETER ID 'AUN' FIELD GT_AFKO-KDAUF.
      CALL TRANSACTION 'VA03'  AND SKIP FIRST SCREEN.

    WHEN 'QMCNT'.
      IF GT_AFKO-QMCNT IS NOT INITIAL.

        PERFORM MOVE_TO_GT_NUM.
        CHECK G_ERROR NE 'X'.
        PERFORM WRITE_GT_NR USING 'TOTAL'.
      ENDIF.
    WHEN 'GISTAT'. " 20260725 가온전선 추가사항
      IF SY-TCODE = 'ZGTPPR3021G' OR SY-TCODE = 'ZGTPPR3020G'.
        PERFORM CALL_ZGTPPR1040.
      ENDIF.

    WHEN  OTHERS.
  ENDCASE.

ENDFORM.                    " double_click
*&---------------------------------------------------------------------*
*&      Form  button_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ES_COL_ID  text
*      -->P_ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM BUTTON_CLICK  USING    PS_COL_ID  TYPE  LVC_S_COL
                            PS_ROW_NO  TYPE  LVC_S_ROID.

*& 2007.09.13
*& 재고상태가 녹색일때만 버튼 사용 가능

  IF PS_COL_ID = 'STOCK'.

    READ TABLE GT_AFKO INDEX PS_ROW_NO-ROW_ID.

    IF GT_AFKO-STOCK EQ '@5B@'.

      PERFORM EVENT_BUTTON_CLICK USING PS_COL_ID
                                       PS_ROW_NO.
    ENDIF.

  ELSEIF PS_COL_ID = 'ETC'.

    READ TABLE GT_AFKO INDEX PS_ROW_NO-ROW_ID.

    IF GT_AFKO-ETC  EQ '@5D@'.

      PERFORM EVENT_BUTTON_CLICK USING PS_COL_ID
                                      PS_ROW_NO.

    ENDIF.

  ELSE.
    PERFORM EVENT_BUTTON_CLICK USING PS_COL_ID
                                     PS_ROW_NO.

  ENDIF.


ENDFORM.                    " button_click
*&---------------------------------------------------------------------*
*&      Form  onf4_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_FIELDNAME  text
*      -->P_E_FIELDVALUE  text
*      -->P_ES_ROW_NO  text
*      -->P_ER_EVENT_DATA  text
*      -->P_ET_BAD_CELLS  text
*      -->P_E_DISPLAY  text
*----------------------------------------------------------------------*
FORM ONF4_PROC  USING   PV_FIELDNAME  TYPE LVC_FNAME
                        PV_FIELDVALUE TYPE LVC_VALUE
                        PS_ROW_NO     TYPE LVC_S_ROID
                        PR_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                        PT_BAD_CELLS  TYPE LVC_T_MODI
                        PV_DISPLAY    TYPE CHAR01.

  FIELD-SYMBOLS <MODI>                TYPE LVC_T_MODI.
  DATA: LS_MODI  TYPE LVC_S_MODI,
        LV_VALUE TYPE STRING.

ENDFORM.                                                    " onf4_proc
*&---------------------------------------------------------------------*
*&      Form  data_input_error
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RR_DATA_CHANGED  text
*      -->P_LS_MOD_CELLS  text
*      -->P_1462   text
*      -->P_1463   text
*      -->P_LS_MOD_CELLS_FIELDNAME  text
*----------------------------------------------------------------------*
FORM DATA_INPUT_ERROR USING RR_DATA_CHANGED TYPE REF TO
                                         CL_ALV_CHANGED_DATA_PROTOCOL
                            PS_MOD_CELLS    TYPE LVC_S_MODI
                            PV_MSGTY
                            PV_MSGV1
                            PV_FIELDNAME.
* Error Message Display
  CALL METHOD RR_DATA_CHANGED->ADD_PROTOCOL_ENTRY
    EXPORTING
      I_MSGID     = '0K'
      I_MSGNO     = '000'
      I_MSGTY     = PV_MSGTY
      I_MSGV1     = PV_MSGV1
      I_MSGV2     = ''
      I_MSGV3     = ''
      I_FIELDNAME = PV_FIELDNAME
      I_ROW_ID    = PS_MOD_CELLS-ROW_ID.

ENDFORM.                    " data_input_error
*&---------------------------------------------------------------------*
*&      Form  refresh_grid_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_GRID_DISPLAY .
  CLEAR: GV_TITLE.

*  PERFORM set_cell_attribute_grid_0100.

  GV_TITLE = TEXT-077."생산오더 릴리즈(UTP)

*&  CALL METHOD gcl_grid->set_gridtitle
*&    EXPORTING
*&      i_gridtitle = gv_title.

  GS_SCROLL-ROW = 'X'.
  GS_SCROLL-COL = 'X'.

  CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = GS_SCROLL.     "현재 그대로 입력한 refresh

ENDFORM.                    " refresh_grid_display
*&---------------------------------------------------------------------*
*&      Form  event_button_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PS_COL_ID  text
*      -->P_PS_ROW_NO  text
*----------------------------------------------------------------------*
FORM EVENT_BUTTON_CLICK  USING    PS_COL_ID  TYPE  LVC_S_COL
                                  PS_ROW_NO  TYPE  LVC_S_ROID.

  CLEAR : GT_AFKO, GS_ACT, GT_ACT.
  READ TABLE GT_AFKO INDEX PS_ROW_NO-ROW_ID.
  SELECT * INTO TABLE @DATA(LT_AFRU)
                 FROM AFRU
                 WHERE AUFNR EQ @GT_AFKO-AUFNR
                      AND STOKZ EQ @SPACE
                      AND STZHL EQ '00000000'.

  LOOP AT LT_AFRU INTO DATA(LS_AFRU).

    CLEAR GS_ACT.
    READ TABLE GT_ACT INTO GS_ACT
                                    WITH KEY AUFNR = LS_AFRU-AUFNR
                                                   GRUND = LS_AFRU-GRUND.
    IF GS_ACT IS INITIAL.
* 오더
      GS_ACT-AUFNR = LS_AFRU-AUFNR.
* Activity
      GS_ACT-GRUND = LS_AFRU-GRUND.
* Activity 유형
      IF LS_AFRU-GRUND EQ SPACE. "양품
        GS_ACT-ACTIVITY = TEXT-025.
      ELSEIF LS_AFRU-GRUND EQ 'CH01' "예압
        OR LS_AFRU-GRUND EQ 'CH02' "Start 여장
        OR LS_AFRU-GRUND EQ 'CH03' "End 여장
        OR LS_AFRU-GRUND EQ 'RW01'. "수리 작업
        SELECT SINGLE GRDTX INTO GS_ACT-ACTIVITY FROM TRUGT
                                              WHERE SPRAS EQ SY-LANGU
                                                   AND WERKS EQ P_PWERK
                                                   AND GRUND EQ LS_AFRU-GRUND.
      ELSE.
        CONTINUE.
      ENDIF.
*실적수량
      IF LS_AFRU-GRUND EQ 'RW01'. "수리 작업
        GS_ACT-MENGE = LS_AFRU-XMNGA.
      ELSE.
        GS_ACT-MENGE = LS_AFRU-LMNGA.
      ENDIF.
* 수량단위
      GS_ACT-MEINS = LS_AFRU-GMEIN.
* 준비시간
      GS_ACT-ISM01 = LS_AFRU-ISM01.
* 기계시간
      GS_ACT-ISM02 = LS_AFRU-ISM02.
* 노무시간
      GS_ACT-ISM06 = LS_AFRU-ISM06.
* 시간단위
      GS_ACT-TIMEM = LS_AFRU-ILE02.
* 설비
      GS_ACT-ARBPL = GT_AFKO-ARBPL.

      APPEND GS_ACT TO GT_ACT.

    ELSE.
*실적수량
      IF LS_AFRU-GRUND EQ 'RW01'. "수리 작업
        GS_ACT-MENGE = GS_ACT-MENGE + LS_AFRU-XMNGA.
      ELSE.
        GS_ACT-MENGE = GS_ACT-MENGE + LS_AFRU-LMNGA.
      ENDIF.
* 준비시간
      GS_ACT-ISM01 = GS_ACT-ISM01 + LS_AFRU-ISM01.
* 기계시간
      GS_ACT-ISM02 = GS_ACT-ISM02 + LS_AFRU-ISM02.
* 노무시간
      GS_ACT-ISM06 = GS_ACT-ISM06 + LS_AFRU-ISM06.

      MODIFY GT_ACT FROM GS_ACT INDEX SY-TABIX.

    ENDIF.

  ENDLOOP.

  SORT GT_ACT BY AUFNR GRUND.
*& 2007.09.13
*& 재고상태 버튼 선택시 재고창 생성
  IF PS_COL_ID = 'BUTTON'.
    PERFORM CALL_SCREEN_900 USING 'GRID'.
*& 2025.01.20
  ELSEIF PS_COL_ID = 'BUTTON2'.
    PERFORM CALL_SCREEN_900 USING 'GRID2'.
  ELSEIF PS_COL_ID = 'STOCK'.

*& 선택한 생산오더의 재고를 gt_stock에 저장
    CLEAR: GT_STOCK.    REFRESH : GT_STOCK.

    PERFORM GET_AUFNR_STOCK USING GT_AFKO-AUFNR.
    PERFORM CALL_SCREEN_900 USING 'STOCK'.

*& 2009.12.04 CSR : C20091202_70500
  ELSEIF PS_COL_ID = 'ETC'.
    PERFORM CALL_SCREEN_900 USING 'ETC'.
  ENDIF.

ENDFORM.                    " event_button_click
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
      ROWS    = 1
      COLUMNS = 1.
* top 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0100.
** bottom 컨테이너
*  CALL METHOD GO_SPLITTER->GET_CONTAINER
*    EXPORTING
*      ROW       = 2
*      COLUMN    = 1
*    RECEIVING
*      CONTAINER = GO_CONTAIN_0101.

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.

*  CREATE OBJECT go_grid_0101
*    EXPORTING
*      i_parent      = go_contain_0101
*      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0100
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .
*& General display options.
  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-CWIDTH_OPT = 'X'.
*&  gs_layout_0100-zebra      = 'X'.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.
*&  gs_layout_0100-edit       = 'E'.
*&  gs_layout_0100-no_rowmark = 'X'.           "선택버튼 비활성
  GS_LAYOUT_0100-STYLEFNAME = 'T_STYL'.      "셀스타일
  GS_LAYOUT_0100-CTAB_FNAME = 'T_SCOL'.      "셀색상
*&  gs_layout_0100-smalltitle = 'X'.           "작은타이틀.

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
*& Form call_grid_0100_display
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .

*[U02]
  IF P_LAYO IS NOT INITIAL.
    ALV_VARIANT-VARIANT = P_LAYO.
  ENDIF.
  ALV_VARIANT-REPORT = SY-REPID.
  ALV_VARIANT-USERNAME = SY-UNAME.
*[U02]
*- I_SAVE
*-'':레이아웃 조회만
*-'X':사용자고유 사용불가
*-'U':사용자고유만 사용가능
*-'A':모두사용가능
  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
      IS_VARIANT           = ALV_VARIANT  " 선택 메뉴 display
      I_SAVE               = 'A'   " 전체가능유형.
      I_BYPASSING_BUFFER   = ABAP_TRUE
    CHANGING
      IT_OUTTAB            = GT_AFKO[]
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
*& Form set_fieldcat_grid_0100
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LV_COL_POS TYPE I.

  CLEAR GT_FIELDCAT_0100[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3020TOP'
      I_INTERNAL_TABNAME     = 'GT_AFKO'
      I_BYPASSING_BUFFER     = ABAP_TRUE
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
      IT_DATA         = GT_AFKO
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'EXCLUD_GUID'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'EXCLUD_GUID'.
    <LS_FCAT>-COLTEXT = TEXT-F83.
    <LS_FCAT>-COL_POS = '25'.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST      = 'C'. "비고
  ENDIF.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-NO_OUT.
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'BUTTON'.
        <LS_FCAT>-COLTEXT = TEXT-F08.
        <LS_FCAT>-COL_POS = '1'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-KEY = 'X'.
        <LS_FCAT>-JUST      = 'C'. "비고
      WHEN 'PROCD'.
        <LS_FCAT>-COLTEXT = TEXT-F09.
        <LS_FCAT>-COL_POS = '2'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-KEY = 'X'.
        <LS_FCAT>-JUST      = 'C'. "공정
      WHEN 'SEQNO'.
        <LS_FCAT>-COLTEXT = TEXT-F10.
        <LS_FCAT>-COL_POS = '3'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-KEY = 'X'.
        <LS_FCAT>-JUST      = 'C'. "순위
      WHEN 'ARBPL'.
        <LS_FCAT>-COLTEXT = TEXT-F11.
        <LS_FCAT>-COL_POS = '4'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-KEY = 'X'.
        <LS_FCAT>-JUST      = 'C'. "설비
      WHEN 'KTEXT'.
*[U01] 가온전선 추가
        IF SY-TCODE EQ 'ZGTPPR3020G' OR SY-TCODE EQ 'ZGTPPR3021G'.
          <LS_FCAT>-COLTEXT = TEXT-F84.
          <LS_FCAT>-COL_POS = '5'.
          <LS_FCAT>-NO_OUT = ' '.
          <LS_FCAT>-KEY = 'X'.
          <LS_FCAT>-JUST      = 'L'. "설비내역
        ENDIF.
*[U01] 가온전선 추가
      WHEN 'AUFNR'.
        <LS_FCAT>-COLTEXT = TEXT-F12.
        <LS_FCAT>-COL_POS = '6'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-KEY = 'X'.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-JUST      = 'C'. "생산오더
      WHEN 'POSNR'.
        <LS_FCAT>-COLTEXT = TEXT-F49.
        <LS_FCAT>-COL_POS = '7'.
        IF C_CHECK EQ 'X'.
          <LS_FCAT>-NO_OUT = 'X'.
        ELSE.
          <LS_FCAT>-NO_OUT = ' '.
        ENDIF.
        <LS_FCAT>-KEY = 'X'.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-JUST      = 'C'. "품목 번호
      WHEN 'STTXT'.
        <LS_FCAT>-COLTEXT = TEXT-F13.
        <LS_FCAT>-COL_POS = '8'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "작업상태
*- Start 2025.03.14
      WHEN 'CLOSE'.
        <LS_FCAT>-COLTEXT = TEXT-F70.
        <LS_FCAT>-COL_POS = '9'.
*        IF c_check EQ 'X'.
        <LS_FCAT>-NO_OUT = ' '.
*        ELSE.
*          <ls_fcat>-no_out = 'X'.
*        ENDIF.
        <LS_FCAT>-JUST      = 'C'. "오더종료여부
*- End 2025.03.14
      WHEN 'MAKTX'.
        <LS_FCAT>-COLTEXT = TEXT-F14.
        <LS_FCAT>-COL_POS = '10'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "품명규격
      WHEN 'MATNR'.
        <LS_FCAT>-COLTEXT = TEXT-F15.
        <LS_FCAT>-COL_POS = '11'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-CONVEXIT = 'MATN1'.
        <LS_FCAT>-JUST      = 'C'. "자재코드
      WHEN 'AMEIN'.
        <LS_FCAT>-COLTEXT = TEXT-F16.
        <LS_FCAT>-COL_POS = '12'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "단위
      WHEN 'PSMNG'.
        <LS_FCAT>-COLTEXT = TEXT-F17.
        <LS_FCAT>-COL_POS = '13'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-DECIMALS_O = '1'.
        <LS_FCAT>-JUST      = 'R'. "총수량
      WHEN 'LENGTH'.
        <LS_FCAT>-COLTEXT = TEXT-F18.
        <LS_FCAT>-COL_POS = '14'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-JUST      = 'R'. "조장
      WHEN 'FACTOR'.
        <LS_FCAT>-COLTEXT = TEXT-F19.
        <LS_FCAT>-COL_POS = '15'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-JUST      = 'R'. "조장수
      WHEN 'BUTTON2'.
        <LS_FCAT>-COLTEXT = TEXT-F57.
        <LS_FCAT>-COL_POS = '16'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "작업 일보
      WHEN 'GRSTAT'.
        <LS_FCAT>-COLTEXT = TEXT-F03.
        <LS_FCAT>-COL_POS = '17'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "입고 상태
      WHEN 'WEMNG'."'IGMNG'.
        <LS_FCAT>-COLTEXT = TEXT-F21.
        <LS_FCAT>-COL_POS = '18'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-DECIMALS_O = '1'.
        <LS_FCAT>-JUST      = 'R'. "총 입고수량
      WHEN 'CFSTAT'.
        <LS_FCAT>-COLTEXT = TEXT-F02.
        <LS_FCAT>-COL_POS = '19'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "실적 상태
      WHEN 'LMNGA'.
        <LS_FCAT>-COLTEXT = TEXT-F20.
        <LS_FCAT>-COL_POS = '20'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-DECIMALS_O = '1'.
        <LS_FCAT>-QFIELDNAME = 'AMEIN'.
        <LS_FCAT>-JUST      = 'R'. "총 실적수량
*- Start 2025.03.25
      WHEN 'ZPER'.
        <LS_FCAT>-COLTEXT = TEXT-F71.
        <LS_FCAT>-COL_POS = '21'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "생산 실적 처리 현황(%)
      WHEN 'GISTAT'.
        <LS_FCAT>-COLTEXT = TEXT-F01.
        <LS_FCAT>-COL_POS = '22'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "투입 상태
      WHEN 'DELAY'.
        <LS_FCAT>-COLTEXT = TEXT-F06.
        <LS_FCAT>-COL_POS = '23'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "지연 구분
      WHEN 'DEL_TIME'.
        <LS_FCAT>-COLTEXT = TEXT-F07.
        <LS_FCAT>-COL_POS = '24'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "지연 시간
      WHEN 'EXCLUD_GUID'.
      WHEN 'CGMENGE'.
        <LS_FCAT>-COLTEXT = TEXT-F04.
        <LS_FCAT>-COL_POS = '26'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-DECIMALS_O = '1'.
        <LS_FCAT>-JUST      = 'R'. "Start 여장 수량
      WHEN 'BADMENGE'.
        <LS_FCAT>-COLTEXT = TEXT-F05.
        <LS_FCAT>-COL_POS = '27'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-DECIMALS_O = '1'.
        <LS_FCAT>-JUST      = 'R'. "수리 작업 수량
      WHEN 'ENDMENGE'.
        <LS_FCAT>-COLTEXT = TEXT-F50.
        <LS_FCAT>-COL_POS = '28'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-DECIMALS_O = '1'.
        <LS_FCAT>-JUST      = 'R'. "End 여장 수량
      WHEN 'YEAPT'.
        <LS_FCAT>-COLTEXT = TEXT-F51.
        <LS_FCAT>-COL_POS = '29'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-JUST      = 'R'. "예압 시간
      WHEN 'CGT'.
        <LS_FCAT>-COLTEXT = TEXT-F52.
        <LS_FCAT>-COL_POS = '30'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-JUST      = 'R'. "Start 여장 작업 시간
      WHEN 'BADT'.
        <LS_FCAT>-COLTEXT = TEXT-F53.
        <LS_FCAT>-COL_POS = '31'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-JUST      = 'R'. "수리 작업 시간
      WHEN 'ENDT'.
        <LS_FCAT>-COLTEXT = TEXT-F54.
        <LS_FCAT>-COL_POS = '32'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-JUST      = 'R'. "End 여장 작업 시간
      WHEN 'TIMEM'.
        <LS_FCAT>-COLTEXT = TEXT-F55.
        <LS_FCAT>-COL_POS = '33'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-JUST      = 'C'. "시간 단위
      WHEN 'TB_PRINT_APP'.
        <LS_FCAT>-COLTEXT = TEXT-F22.
        <LS_FCAT>-COL_POS = '34'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "튜브인쇄사양
      WHEN 'NAME1'.
        <LS_FCAT>-COLTEXT = TEXT-F23.
        <LS_FCAT>-COL_POS = '35'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "납선명
      WHEN 'GLTRS'.
        <LS_FCAT>-COLTEXT = TEXT-F24.
        <LS_FCAT>-COL_POS = '36'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-JUST      = 'C'. "작업종료일
      WHEN 'ARBPL_C'.
        <LS_FCAT>-COLTEXT = TEXT-F25.
        <LS_FCAT>-COL_POS = '37'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "상세설비
      WHEN 'GLUZS'.
        <LS_FCAT>-COLTEXT = TEXT-F26.
        <LS_FCAT>-COL_POS = '38'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-JUST      = 'C'. "종료시간
      WHEN 'BUDAT'.
        <LS_FCAT>-COLTEXT = TEXT-F69.
        <LS_FCAT>-COL_POS = '39'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "입고일자
      WHEN 'WORK_SD'.
        <LS_FCAT>-COLTEXT = TEXT-F59.
        <LS_FCAT>-COL_POS = '40'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "작업시작일(실제)
      WHEN 'WORK_ST'.
        <LS_FCAT>-COLTEXT = TEXT-F29.
        <LS_FCAT>-COL_POS = '41'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "시작시간(실제)
      WHEN 'WORK_ED'.
        <LS_FCAT>-COLTEXT = TEXT-F24.
        <LS_FCAT>-COL_POS = '42'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "작업종료일(실제)
      WHEN 'WORK_ET'.
        <LS_FCAT>-COLTEXT = TEXT-F26.
        <LS_FCAT>-COL_POS = '43'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "종료시간(실제)
      WHEN 'GSTRS'.
        <LS_FCAT>-COLTEXT = TEXT-F28.
        <LS_FCAT>-COL_POS = '44'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "오더계획시작일자
      WHEN 'FTRMI'.
        <LS_FCAT>-COLTEXT = TEXT-F27.
        <LS_FCAT>-COL_POS = '45'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "릴리즈 일자
      WHEN 'GSUZS'.
        <LS_FCAT>-COLTEXT = TEXT-F29.
        <LS_FCAT>-COL_POS = '46'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-JUST      = 'C'. "시작시간
      WHEN 'STOCK'.
        <LS_FCAT>-COLTEXT = TEXT-F30.
        <LS_FCAT>-COL_POS = '47'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "재고상태
      WHEN 'APRIO_T'.
        <LS_FCAT>-COLTEXT = TEXT-F31.
        <LS_FCAT>-COL_POS = '48'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "세부유형
      WHEN 'CFPRI'.
        <LS_FCAT>-COLTEXT = TEXT-F32.
        <LS_FCAT>-COL_POS = '49'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "상세우선순위
      WHEN 'CLRTX'.
        <LS_FCAT>-COLTEXT = TEXT-F33.
        <LS_FCAT>-COL_POS = '50'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "색상내역
      WHEN 'CLRTX1'.
        <LS_FCAT>-COLTEXT = TEXT-F34.
        <LS_FCAT>-COL_POS = '51'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "색상내역
      WHEN 'DAUAT'.
        <LS_FCAT>-COLTEXT = TEXT-F35.
        <LS_FCAT>-COL_POS = '52'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "유형
      WHEN 'EXFLG'.
        <LS_FCAT>-COLTEXT = TEXT-F36.
        <LS_FCAT>-COL_POS = '53'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "외주공정여부
      WHEN 'JISIR'.
        <LS_FCAT>-COLTEXT = TEXT-F37.
        <LS_FCAT>-COL_POS = '54'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "절단지시유무
      WHEN 'KDAUF'.
        <LS_FCAT>-COLTEXT = TEXT-F38.
        <LS_FCAT>-COL_POS = '55'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-JUST      = 'C'. "판매오더
      WHEN 'KDPOS'.
        <LS_FCAT>-COLTEXT = TEXT-F39.
        <LS_FCAT>-COL_POS = '56'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-JUST      = 'C'. "품목
      WHEN 'KUNNR'.
        <LS_FCAT>-COLTEXT = TEXT-F40.
        <LS_FCAT>-COL_POS = '57'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-JUST      = 'C'. "품목
      WHEN 'OUTDIA'.
        <LS_FCAT>-COLTEXT = TEXT-F41.
        <LS_FCAT>-COL_POS = '58'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-NO_ZERO = 'X'.
        <LS_FCAT>-JUST      = 'C'. "공정외경
      WHEN 'TB_BOBIN'.
        <LS_FCAT>-COLTEXT = TEXT-F42.
        <LS_FCAT>-COL_POS = '59'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "보빈인쇄사양
      WHEN 'TB_BOX_MARKING'.
        <LS_FCAT>-COLTEXT = TEXT-F43.
        <LS_FCAT>-COL_POS = '60'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "박스인쇄사양
      WHEN 'VORNR'.
        <LS_FCAT>-COLTEXT = TEXT-F44.
        <LS_FCAT>-COL_POS = '61'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "소공정
      WHEN 'ZZCOLOR_BASE'.
        <LS_FCAT>-COLTEXT = TEXT-F45.
        <LS_FCAT>-COL_POS = '62'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "색상BASE
      WHEN 'ZZCOLOR_STRIPE'.
        <LS_FCAT>-COLTEXT = TEXT-F46.
        <LS_FCAT>-COL_POS = '63'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "색상STRIPE
      WHEN 'ZZIDEN_CODE'.
        <LS_FCAT>-COLTEXT = TEXT-F47.
        <LS_FCAT>-COL_POS = '64'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "절연선심식별
      WHEN 'ZZMAKTX80'.
        <LS_FCAT>-COLTEXT = TEXT-F48.
        <LS_FCAT>-COL_POS = '65'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "전체품명
*- End 2025.03.25
*- Start 2025.04.16
      WHEN 'GRPNR'.
        <LS_FCAT>-COLTEXT = TEXT-F72.
        <LS_FCAT>-COL_POS = '66'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "조장 구성표
      WHEN 'DMORD'.
        <LS_FCAT>-COLTEXT = TEXT-F73.
        <LS_FCAT>-COL_POS = '67'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "패깅 오더
      WHEN 'DMLINE'.
        <LS_FCAT>-COLTEXT = TEXT-F74.
        <LS_FCAT>-COL_POS = '68'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "패깅 오더 품목
      WHEN 'ZPJNO'.
        <LS_FCAT>-COLTEXT = TEXT-F75.
        <LS_FCAT>-COL_POS = '69'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "PJT 번호
      WHEN 'ZPTXT'.
        <LS_FCAT>-COLTEXT = TEXT-F76.
        <LS_FCAT>-COL_POS = '70'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "PJT 내역
      WHEN 'INLENGTH'.
        <LS_FCAT>-COLTEXT = TEXT-F77.
        <LS_FCAT>-COL_POS = '71'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "기본 조장
      WHEN 'INFACTOR'.
        <LS_FCAT>-COLTEXT = TEXT-F78.
        <LS_FCAT>-COL_POS = '72'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "기본 조장 수
      WHEN 'QLENGTH'.
        <LS_FCAT>-COLTEXT = TEXT-F79.
        <LS_FCAT>-COL_POS = '73'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "검사 여장
      WHEN 'CLENGTH'.
        <LS_FCAT>-COLTEXT = TEXT-F80.
        <LS_FCAT>-COL_POS = '74'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "연결 여장
      WHEN 'ADLENGTH'.
        <LS_FCAT>-COLTEXT = TEXT-F81.
        <LS_FCAT>-COL_POS = '75'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "추가 여장
      WHEN 'ADTYPE'.
        <LS_FCAT>-COLTEXT = TEXT-F82.
        <LS_FCAT>-COL_POS = '76'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "추가 여장 유형
*- End 2025.04.16

*- Start 2026.08.24
      WHEN 'NES01'.
        <LS_FCAT>-NO_OUT = 'X'.
      WHEN 'NES_T01'.
        <LS_FCAT>-COLTEXT = TEXT-F85.
        <LS_FCAT>-COL_POS = '200'.
        <LS_FCAT>-JUST      = 'L'.
      WHEN 'KGW01'.
        <LS_FCAT>-COLTEXT = TEXT-F86.
        <LS_FCAT>-COL_POS = '201'.
        <LS_FCAT>-JUST      = 'R'.
        <LS_FCAT>-QFIELDNAME      = 'BME01'.
        <LS_FCAT>-NO_ZERO      = ABAP_TRUE.

      WHEN 'BME01'.
        <LS_FCAT>-COLTEXT = TEXT-F87.
        <LS_FCAT>-COL_POS = '202'.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'NES02'.
        <LS_FCAT>-NO_OUT = 'X'.
      WHEN 'NES_T02'.
        <LS_FCAT>-COLTEXT = TEXT-F88.
        <LS_FCAT>-COL_POS = '203'.
        <LS_FCAT>-JUST      = 'L'.
      WHEN 'KGW02'.
        <LS_FCAT>-COLTEXT = TEXT-F89.
        <LS_FCAT>-COL_POS = '204'.
        <LS_FCAT>-JUST      = 'R'.
        <LS_FCAT>-QFIELDNAME      = 'BME02'.
        <LS_FCAT>-NO_ZERO      = ABAP_TRUE.
      WHEN 'BME02'.
        <LS_FCAT>-COLTEXT = TEXT-F90.
        <LS_FCAT>-COL_POS = '205'.
        <LS_FCAT>-JUST      = 'C'.
*- End 2026.08.24

      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.

*[U01] 가온전선 추가
    IF SY-TCODE EQ 'ZGTPPR3020G' OR SY-TCODE EQ 'ZGTPPR3021G'.
      IF <LS_FCAT>-FIELDNAME = 'LENGTH' OR <LS_FCAT>-FIELDNAME = 'FACTOR' OR
         <LS_FCAT>-FIELDNAME = 'CGMENGE' OR <LS_FCAT>-FIELDNAME = 'BADMENGE' OR
         <LS_FCAT>-FIELDNAME = 'ENDMENGE' OR <LS_FCAT>-FIELDNAME = 'YEAPT' OR
         <LS_FCAT>-FIELDNAME = 'CGT' OR <LS_FCAT>-FIELDNAME = 'BADT' OR
         <LS_FCAT>-FIELDNAME = 'ENDT' OR <LS_FCAT>-FIELDNAME = 'TIMEM' OR
         <LS_FCAT>-FIELDNAME = 'ARBPL_C' OR <LS_FCAT>-FIELDNAME = 'EXFLG' OR
         <LS_FCAT>-FIELDNAME = 'APRIO_T' OR <LS_FCAT>-FIELDNAME = 'CFPRI' OR
         <LS_FCAT>-FIELDNAME = 'CLRTX1' OR <LS_FCAT>-FIELDNAME = 'JISIR' OR
         <LS_FCAT>-FIELDNAME = 'ZZCOLOR_STRIPE' OR <LS_FCAT>-FIELDNAME = 'ZZIDEN_CODE'.

        <LS_FCAT>-NO_OUT = 'X'.

      ENDIF.
    ENDIF.
*[U01] 가온전선 추가
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0102
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0102 .

  CREATE OBJECT GO_CONTAIN_0102
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

  CREATE OBJECT GO_GRID_0102
    EXPORTING
      I_PARENT      = GO_CONTAIN_0102
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0102
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0102 .

  CLEAR GS_LAYOUT_0102.
*  gs_layout_0220-cwidth_opt = abap_true.
  GS_LAYOUT_0102-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0102-SEL_MODE   = 'A'.
  GS_LAYOUT_0102-SMALLTITLE = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0102
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0102 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.

  IF GV_OKCODE = 'TECO'.

    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        I_PROGRAM_NAME         = SY-REPID
        I_INCLNAME             = 'ZGTPPR3020TOP'
        I_INTERNAL_TABNAME     = 'GS_INFO2'
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
        ET_FIELDCAT_LVC = GT_FIELDCAT_0102[]
      TABLES
        IT_DATA         = GT_INFO
      EXCEPTIONS
        OTHERS          = 1.

    LOOP AT GT_FIELDCAT_0102 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
      CASE   <LS_FCAT>-FIELDNAME.
        WHEN 'AUFNR'.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "생산오더
          <LS_FCAT>-JUST = 'C'.
        WHEN 'ICON'.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F58. "상태
          <LS_FCAT>-JUST = 'C'.
        WHEN 'TEXT'.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F56. "메시지
          <LS_FCAT>-JUST = 'L'.
      ENDCASE.
    ENDLOOP.

  ELSE.

    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        I_PROGRAM_NAME         = SY-REPID
        I_INCLNAME             = 'ZGTPPR3020TOP'
        I_INTERNAL_TABNAME     = 'GS_INFO'
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
        ET_FIELDCAT_LVC = GT_FIELDCAT_0102[]
      TABLES
        IT_DATA         = GT_INFO
      EXCEPTIONS
        OTHERS          = 1.

    LOOP AT GT_FIELDCAT_0102 ASSIGNING FIELD-SYMBOL(<LS_FCAT2>).
      CASE   <LS_FCAT2>-FIELDNAME.
        WHEN 'TEXT'.
          <LS_FCAT2>-REPTEXT = <LS_FCAT2>-COLTEXT = <LS_FCAT2>-TOOLTIP = TEXT-F56. "메시지
          <LS_FCAT2>-JUST = 'L'.
      ENDCASE.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_of_toolbar_grid_0102
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0102 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0102
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
*& Form call_grid_0102_display
*&---------------------------------------------------------------------*
FORM CALL_GRID_0102_DISPLAY .

  IF GV_OKCODE = 'TECO'.

    CALL METHOD GO_GRID_0102->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYOUT_0102
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0102
      CHANGING
        IT_OUTTAB            = GT_INFO2
        IT_FIELDCATALOG      = GT_FIELDCAT_0102.

  ELSE.

    CALL METHOD GO_GRID_0102->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYOUT_0102
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0102
      CHANGING
        IT_OUTTAB            = GT_INFO
        IT_FIELDCATALOG      = GT_FIELDCAT_0102.

  ENDIF.
* 인풋이벤트 추가
  CALL METHOD GO_GRID_0102->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0102->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0904
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0904 .

  CREATE OBJECT GO_CONTAIN_DOCKING_0904
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
  CREATE OBJECT GO_SPLITTER_0904
    EXPORTING
      PARENT  = GO_CONTAIN_DOCKING_0904
      ROWS    = 2
      COLUMNS = 1.

  GO_SPLITTER_0904->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    55 ).             " Height

  CALL METHOD GO_SPLITTER_0904->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0904.

  CALL METHOD GO_SPLITTER_0904->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0904_1.

  CREATE OBJECT GO_GRID_0904
    EXPORTING
      I_PARENT      = GO_CONTAIN_0904
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0904
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0904 .

  CLEAR GS_LAYOUT_0904.
  GS_LAYOUT_0904-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0904-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0904-SEL_MODE   = 'D'.
  GS_LAYOUT_0904-NO_ROWMARK   = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0904
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0904 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3020TOP'
      I_INTERNAL_TABNAME     = 'GS_ACT'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0904.
*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0904[]
    TABLES
      IT_DATA         = GT_ACT
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0904 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F60. "오더
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ACTIVITY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F61. "Activity 유형
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F62. "실적수량
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F63. "수량단위
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ISM01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F64. "준비시간
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ISM02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F65. "기계시간
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ISM06'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F66. "노무시간
        <LS_FCAT>-JUST = 'C'.
      WHEN 'TIMEM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F67. "시간단위
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ARBPL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F68. "설비
        <LS_FCAT>-JUST = 'C'.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = 'X'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0904
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0904 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

*  LOOP AT GT_ACT ASSIGNING FIELD-SYMBOL(<LS_ACT>).
*    REFRESH LT_CELLTAB.
*
*    LOOP AT GT_FIELDCAT_0904 INTO DATA(LS_FIELDCAT).
*      CASE LS_FIELDCAT-FIELDNAME.
*        WHEN 'AUFNR'.
**       key 색깔지정
*          CLEAR LS_CELLTAB.
*          LS_CELLTAB-FIELDNAME = LS_FIELDCAT-FIELDNAME.
*          LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_KEY.
*          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
*      ENDCASE.
*    ENDLOOP.
*    <LS_ACT>-CELLTAB = LT_CELLTAB.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0904
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0904 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0904
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
*& Form CALL_GRID_0904_DISPLAY
*&---------------------------------------------------------------------*
FORM CALL_GRID_0904_DISPLAY .

  CALL METHOD GO_GRID_0904->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0904
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0904
    CHANGING
      IT_OUTTAB            = GT_ACT
      IT_FIELDCATALOG      = GT_FIELDCAT_0904.
* 인풋이벤트 추가
  CALL METHOD GO_GRID_0904->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0904->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_text_control_0904_1
*&---------------------------------------------------------------------*
FORM INIT_TEXT_CONTROL_0904_1 .

  IF GO_CONTAIN_0904_1 IS BOUND.

    LV_TEXTEDIT_WRAPPOS = 132.

    IF GS_EDITOR2 IS INITIAL.
      CREATE OBJECT GS_EDITOR2
        EXPORTING
          PARENT                 = GO_CONTAIN_0904_1                         " Parent Container
        EXCEPTIONS
          ERROR_CNTL_CREATE      = 1                        " Error while performing creation of TextEdit control!
          ERROR_CNTL_INIT        = 2                        " Error while initializing TextEdit control!
          ERROR_CNTL_LINK        = 3                        " Error while linking TextEdit control!
          ERROR_DP_CREATE        = 4                        " Error while creating DataProvider control!
          GUI_TYPE_NOT_SUPPORTED = 5                        " This type of GUI is not supported!
          OTHERS                 = 6.
      IF SY-SUBRC <> 0.

      ENDIF.

    ENDIF.                               " Editor is initial
* set display mode
    CALL METHOD GS_EDITOR2->SET_READONLY_MODE
      EXPORTING
        READONLY_MODE          = 1             " read-only mode; eq 0: OFF ; ne 0: ON
      EXCEPTIONS
        ERROR_CNTL_CALL_METHOD = 1                " Error while setting read-only mode!
        INVALID_PARAMETER      = 2                " INVALID_PARAMETER
        OTHERS                 = 3.

    IF SY-SUBRC <> 0.

    ENDIF.
* set wordWrap behavior
    CALL METHOD GS_EDITOR2->SET_WORDWRAP_BEHAVIOR
      EXPORTING
        WORDWRAP_MODE              = C_TEXTEDIT_CONTROL=>WORDWRAP_AT_FIXED_POSITION
        WORDWRAP_POSITION          = LV_TEXTEDIT_WRAPPOS
        WORDWRAP_TO_LINEBREAK_MODE = C_TEXTEDIT_CONTROL=>TRUE
      EXCEPTIONS
        OTHERS                     = 1.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_control_text_0904_1
*&---------------------------------------------------------------------*
FORM SET_CONTROL_TEXT_0904_1 .

  CONCATENATE GT_AFKO-WERKS GT_AFKO-MATKL+1(2) GT_AFKO-MATNR INTO LV_TDNAME.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID        = 'Z01'     "품목 텍스트 ID
      LANGUAGE  = SY-LANGU
      NAME      = LV_TDNAME
      OBJECT    = 'ZPP_MAT'    "자재코드 특기사항 오브젝트
    TABLES
      LINES     = LT_TLINES
    EXCEPTIONS
      NOT_FOUND = 01.

  CLEAR : WA_TEXT, GT_TEXT.
  LOOP AT LT_TLINES.
    WA_TEXT-LINE = LT_TLINES-TDLINE.
    APPEND WA_TEXT TO GT_TEXT.
  ENDLOOP.

  SELECT REG_FMSG, REG_SMSG
      INTO CORRESPONDING FIELDS OF TABLE @LT_3180
      FROM ZGTPPT3180
      WHERE WERKS EQ @GT_AFKO-WERKS
           AND AUFNR EQ @GT_AFKO-AUFNR
           AND POSNR EQ @GT_AFKO-POSNR
           AND ZIFKEY EQ ( SELECT MAX( ZIFKEY ) FROM ZGTPPT3180
                                                   WHERE WERKS EQ @GT_AFKO-WERKS
                                                        AND AUFNR EQ @GT_AFKO-AUFNR
                                                        AND POSNR EQ @GT_AFKO-POSNR ).

  IF LT_3180[] IS NOT INITIAL.

    LOOP AT LT_3180 INTO LS_3180.
      WA_TEXT-LINE = LS_3180-REG_FMSG.
      APPEND WA_TEXT TO GT_TEXT.
      WA_TEXT-LINE = LS_3180-REG_SMSG.
      APPEND WA_TEXT TO GT_TEXT.
    ENDLOOP.

  ENDIF.
* send table to control
  CALL METHOD GS_EDITOR2->SET_TEXT_AS_R3TABLE
    EXPORTING
      TABLE = GT_TEXT[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form control_flush
*&---------------------------------------------------------------------*
FORM CONTROL_FLUSH .

  CALL FUNCTION 'CONTROL_FLUSH'
    EXCEPTIONS
      CNTL_SYSTEM_ERROR = 1
      CNTL_ERROR        = 2
      OTHERS            = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form context_menu
*&---------------------------------------------------------------------*
FORM CONTEXT_MENU USING P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                        P_OBJECT TYPE REF TO CL_CTMENU.

  DATA : LT_STD_FCODES TYPE UI_FUNCTIONS,
         LT_OWN_FCODES TYPE UI_FUNCTIONS.
*   define local data
  DATA : LT_COLUMNS	TYPE LVC_T_COL,
         LS_ROW_ID  TYPE LVC_S_ROW,
         LS_COL_ID  TYPE LVC_S_COL,
         LS_ROW_NO  TYPE LVC_S_ROID.

  P_SENDER->GET_CURRENT_CELL(
   IMPORTING
     ES_ROW_ID = LS_ROW_ID
     ES_COL_ID = LS_COL_ID
     ES_ROW_NO = LS_ROW_NO ).

  IF LS_ROW_ID IS NOT INITIAL.

    P_OBJECT->CLEAR( ).
    READ TABLE GT_AFKO INTO DATA(LS_AFKO) INDEX LS_ROW_ID-INDEX.
    IF LS_COL_ID-FIELDNAME = 'GRSTAT'. "입고 상태

      IF LS_AFKO-GRSTAT EQ ICON_LED_GREEN.
        PERFORM SHOW_TOOLTIP USING TEXT-I18 TEXT-I19 P_OBJECT.
      ELSEIF LS_AFKO-GRSTAT EQ ICON_LED_YELLOW.
        PERFORM SHOW_TOOLTIP USING TEXT-I20 TEXT-I21 P_OBJECT.
      ELSEIF LS_AFKO-GRSTAT EQ ICON_LED_RED.
        PERFORM SHOW_TOOLTIP USING TEXT-I22 TEXT-I23 P_OBJECT.
      ENDIF.

    ELSEIF LS_COL_ID-FIELDNAME = 'CFSTAT'. "실적 상태

      IF LS_AFKO-CFSTAT EQ ICON_LED_GREEN.
        PERFORM SHOW_TOOLTIP USING TEXT-I24 SPACE P_OBJECT.
      ELSEIF LS_AFKO-CFSTAT EQ ICON_LED_YELLOW.
        PERFORM SHOW_TOOLTIP USING TEXT-I25 SPACE P_OBJECT.
      ELSEIF LS_AFKO-CFSTAT EQ ICON_LED_RED.
        PERFORM SHOW_TOOLTIP USING TEXT-I26 SPACE P_OBJECT.
      ENDIF.

    ELSEIF LS_COL_ID-FIELDNAME = 'GISTAT'. "투입 상태

      IF LS_AFKO-GISTAT EQ ICON_LED_GREEN.
        PERFORM SHOW_TOOLTIP USING TEXT-I27 SPACE P_OBJECT.
      ELSEIF LS_AFKO-GISTAT EQ ICON_LED_YELLOW.
        PERFORM SHOW_TOOLTIP USING TEXT-I28 TEXT-I29 P_OBJECT.
      ELSEIF LS_AFKO-GISTAT EQ ICON_LED_RED.
        PERFORM SHOW_TOOLTIP USING TEXT-I30 TEXT-I31 P_OBJECT.
      ENDIF.

    ENDIF.

    CALL METHOD P_OBJECT->SHOW_FUNCTIONS
      EXPORTING
        FCODES = LT_OWN_FCODES.

    CALL METHOD CL_GUI_CFW=>FLUSH.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form show_TOOLTIP
*&---------------------------------------------------------------------*
FORM SHOW_TOOLTIP USING PV_TEXT PV_TEXT2 P_OBJECT TYPE REF TO CL_CTMENU.

  DATA : LV_TEXT TYPE GUI_TEXT.

  IF PV_TEXT IS NOT INITIAL.

    LV_TEXT = PV_TEXT.
    CALL METHOD P_OBJECT->ADD_FUNCTION
      EXPORTING
        FCODE = 'A1'
        TEXT  = LV_TEXT.

  ENDIF.

  IF PV_TEXT2 IS NOT INITIAL.

    LV_TEXT = PV_TEXT2.
    CALL METHOD P_OBJECT->ADD_FUNCTION
      EXPORTING
        FCODE = 'A2'
        TEXT  = LV_TEXT.

  ENDIF.

ENDFORM.
