*&---------------------------------------------------------------------*
*& Include          ZGTPPI1010F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form toolbar_proc
*&---------------------------------------------------------------------*
FORM TOOLBAR_PROC USING PS_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                                  PV_INTERACTIVE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

  MOVE   3             TO  LS_TOOLBAR-BUTN_TYPE.
  APPEND LS_TOOLBAR TO  PS_OBJECT->MT_TOOLBAR.

  CLEAR LS_TOOLBAR.
**  MOVE 'SELA'               TO  ls_toolbar-function.
**  MOVE icon_select_all      TO  ls_toolbar-icon.
**  MOVE '전체선택'           TO  ls_toolbar-quickinfo.
**&  MOVE '전체선택'           TO  ls_toolbar-text.
*  MOVE ' '                  TO  ls_toolbar-disabled.
*  APPEND ls_toolbar         TO  r_object->mt_toolbar.
*
**&  MOVE   3                  TO  ls_toolbar-butn_type.
**&  APPEND ls_toolbar         TO  r_object->mt_toolbar.
*
*  CLEAR ls_toolbar.
*  MOVE 'DSEL'               TO  ls_toolbar-function.
*  MOVE icon_deselect_all    TO  ls_toolbar-icon.
*  MOVE '전체해제'           TO  ls_toolbar-quickinfo.
**&  MOVE '전체해제'           TO  ls_toolbar-text.
*  MOVE ' '                  TO  ls_toolbar-disabled.
*  APPEND ls_toolbar         TO  r_object->mt_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_proc
*&---------------------------------------------------------------------*
FORM USER_COMMAND_PROC USING PV_UCOMM.

*  CASE r_ucomm.
*    WHEN ''.
*  ENDCASE.

*  PERFORM refresh_grid_display .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form after_user_command
*&---------------------------------------------------------------------*
FORM AFTER_USER_COMMAND USING PV_UCOMM.

*  CASE pv_ucomm.
*    WHEN '&REFRESH'.
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed
*&---------------------------------------------------------------------*
FORM DATA_CHANGED USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                       PV_ONF4 TYPE CHAR1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hotspot_click
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK USING PV_ROW_ID     TYPE LVC_S_ROW
                                     PV_COLUMN_ID TYPE LVC_S_COL.

  CASE PV_COLUMN_ID-FIELDNAME.

    WHEN 'ARBPL'. "작업장

      IF P_R1 = 'X'.

        CLEAR GS_DISP.
        READ TABLE GT_DISP INTO GS_DISP INDEX PV_ROW_ID-INDEX.

        SET PARAMETER ID 'WRK' FIELD GS_DISP-WERKS.
        SET PARAMETER ID 'AGR' FIELD GS_DISP-ARBPL.

      ELSE.

        CLEAR GS_DISP2.
        READ TABLE GT_DISP2 INTO GS_DISP2 INDEX PV_ROW_ID-INDEX.

        SET PARAMETER ID 'WRK' FIELD GS_DISP2-WERKS.
        SET PARAMETER ID 'AGR' FIELD GS_DISP2-ARBPL.

      ENDIF.

      CALL TRANSACTION 'CR03' AND SKIP FIRST SCREEN.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK USING PV_ROW PV_COLUMN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form button_click
*&---------------------------------------------------------------------*
FORM BUTTON_CLICK USING PS_COL_ID  TYPE  LVC_S_COL
                                 PS_ROW_NO  TYPE  LVC_S_ROID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form onf4_proc
*&---------------------------------------------------------------------*
FORM ONF4_PROC USING PV_FIELDNAME   TYPE LVC_FNAME
                                 PV_FIELDVALUE  TYPE LVC_VALUE
                                 PS_ROW_NO     TYPE LVC_S_ROID
                                 PR_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                                 PT_BAD_CELLS  TYPE LVC_T_MODI
                                 PV_DISPLAY     TYPE CHAR01.

ENDFORM.
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
*& Form event_handler_register
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.
*& Edit  이벤트 등록
* IF MC_EVT_MODIFY  -> 바로 수정됨.
  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.
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
  SET HANDLER GO_EVENT_HANDLER->HANDLE_HOTSPOT_CLICK
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_AFTER_USER_COMMAND
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_BUTTON_CLICK
          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_ONF4
          FOR PO_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0100
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .
*& General display options
  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-CWIDTH_OPT = 'X'.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.
*  ps_layocat-edit       = 'E'.
  GS_LAYOUT_0100-NO_ROWMARK = ' '.           "선택버튼 비활성
*  ps_layocat-stylefname = 'T_STYL'.      "셀스타일
*  ps_layocat-ctab_fname = 'T_SCOL'.      "셀색상
*&  ps_layocat-smalltitle = 'X'.           "작은타이틀.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0100
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .

  IF P_R1 = 'X'. "전송

    PERFORM SET_FIELDCAT_FOR_SEND.

  ELSE.

    PERFORM SET_FIELDCAT_FOR_RESEND.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_FOR_SEND
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_FOR_SEND .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPI1010TOP'
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
        <LS_FCAT>-COLTEXT = TEXT-F01.
        <LS_FCAT>-COL_POS = '1'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "전송 상태
      WHEN 'ZMESSAGE'.
        <LS_FCAT>-COLTEXT = TEXT-F02.
        <LS_FCAT>-COL_POS = '2'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "결과 메시지
      WHEN 'ZSYSTEM_ID'.
        <LS_FCAT>-COLTEXT = TEXT-F03.
        <LS_FCAT>-COL_POS = '3'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "수신 시스템
      WHEN 'ZSYSTEM_ID_DESC'.
        <LS_FCAT>-COLTEXT = TEXT-F04.
        <LS_FCAT>-COL_POS = '4'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "시스템 내역
      WHEN 'WERKS'.
        <LS_FCAT>-COLTEXT = TEXT-F05.
        <LS_FCAT>-COL_POS = '5'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "플랜트
      WHEN 'ARBPL'.
        <LS_FCAT>-COLTEXT = TEXT-F06.
        <LS_FCAT>-COL_POS = '6'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-HOTSPOT = 'X'.
        <LS_FCAT>-JUST      = 'C'. "작업장 코드
      WHEN 'KTEXT'.
        <LS_FCAT>-COLTEXT = TEXT-F07.
        <LS_FCAT>-COL_POS = '7'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "작업장 내역
      WHEN 'VERWE'.
        <LS_FCAT>-COLTEXT = TEXT-F08.
        <LS_FCAT>-COL_POS = '8'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "작업장 범주
      WHEN 'ZZTEXT1'.
        <LS_FCAT>-COLTEXT = TEXT-F09.
        <LS_FCAT>-COL_POS = '9'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'."작업장 범주 내역
      WHEN 'VERAN'.
        <LS_FCAT>-COLTEXT = TEXT-F10.
        <LS_FCAT>-COL_POS = '10'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "책임자
      WHEN 'ZZTEXT2'.
        <LS_FCAT>-COLTEXT = TEXT-F11.
        <LS_FCAT>-COL_POS = '11'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'."책임자 내역
      WHEN 'KOTSL'.
        <LS_FCAT>-COLTEXT = TEXT-F12.
        <LS_FCAT>-COL_POS = '12'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "코스트센터
      WHEN 'LVORM'.
        <LS_FCAT>-COLTEXT = TEXT-F13.
        <LS_FCAT>-COL_POS = '13'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "삭제플래그
      WHEN 'BEGDA'.
        <LS_FCAT>-COLTEXT = TEXT-F14.
        <LS_FCAT>-COL_POS = '14'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "시작일
      WHEN 'AEDAT_GRND'.
        <LS_FCAT>-COLTEXT = TEXT-F15.
        <LS_FCAT>-COL_POS = '15'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "변경일
      WHEN 'GONG_CD'.
        CLEAR <LS_FCAT>-KEY.
        CASE ABAP_TRUE.
          WHEN P_R11 OR P_R12.
          WHEN OTHERS.
            <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDCASE.
      WHEN 'GONG_NM'.
        CASE ABAP_TRUE.
          WHEN P_R11 OR P_R12.
          WHEN OTHERS.
            <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDCASE.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_FOR_RESEND
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_FOR_RESEND .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPI1010TOP'
      I_INTERNAL_TABNAME     = 'GS_DISP2'
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
      IT_DATA         = GT_DISP2
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ZIFKEY'.
        <LS_FCAT>-COLTEXT = TEXT-F16.
        <LS_FCAT>-COL_POS = '1'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "인터페이스 키
      WHEN 'ZSTAT'.
        <LS_FCAT>-COLTEXT = TEXT-F18.
        <LS_FCAT>-COL_POS = '3'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-JUST      = 'C'. "전송 결과
      WHEN 'ICON'.
        <LS_FCAT>-COLTEXT = TEXT-F18.
        <LS_FCAT>-COL_POS = '4'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "전송 결과
      WHEN 'ZMESSAGE'.
        <LS_FCAT>-COLTEXT = TEXT-F02.
        <LS_FCAT>-COL_POS = '5'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "결과 메시지
      WHEN 'ZSYSTEM_ID'.
        <LS_FCAT>-COLTEXT = TEXT-F03.
        <LS_FCAT>-COL_POS = '6'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "수신 시스템
      WHEN 'ZSYSTEM_ID_DESC'.
        <LS_FCAT>-COLTEXT = TEXT-F04.
        <LS_FCAT>-COL_POS = '7'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "시스템 내역
      WHEN 'WERKS'.
        <LS_FCAT>-COLTEXT = TEXT-F05.
        <LS_FCAT>-COL_POS = '8'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "플랜트
      WHEN 'ARBPL'.
        <LS_FCAT>-COLTEXT = TEXT-F06.
        <LS_FCAT>-COL_POS = '9'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-HOTSPOT = 'X'.
        <LS_FCAT>-JUST      = 'C'. "작업장 코드
      WHEN 'KTEXT'.
        <LS_FCAT>-COLTEXT = TEXT-F07.
        <LS_FCAT>-COL_POS = '10'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'. "작업장 내역
      WHEN 'VERWE'.
        <LS_FCAT>-COLTEXT = TEXT-F08.
        <LS_FCAT>-COL_POS = '11'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "작업장 범주
      WHEN 'ZZTEXT1'.
        <LS_FCAT>-COLTEXT = TEXT-F09.
        <LS_FCAT>-COL_POS = '12'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'."작업장 범주 내역
      WHEN 'VERAN'.
        <LS_FCAT>-COLTEXT = TEXT-F10.
        <LS_FCAT>-COL_POS = '13'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "책임자
      WHEN 'ZZTEXT2'.
        <LS_FCAT>-COLTEXT = TEXT-F11.
        <LS_FCAT>-COL_POS = '14'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'."책임자 내역
      WHEN 'KOTSL'.
        <LS_FCAT>-COLTEXT = TEXT-F12.
        <LS_FCAT>-COL_POS = '15'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "코스트센터
      WHEN 'LVORM'.
        <LS_FCAT>-COLTEXT = TEXT-F13.
        <LS_FCAT>-COL_POS = '16'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "삭제플래그
      WHEN 'BEGDA'.
        <LS_FCAT>-COLTEXT = TEXT-F14.
        <LS_FCAT>-COL_POS = '17'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "시작일
      WHEN 'AEDAT_GRND'.
        <LS_FCAT>-COLTEXT = TEXT-F15.
        <LS_FCAT>-COL_POS = '18'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "변경일
      WHEN 'IFDAT'.
        <LS_FCAT>-COLTEXT = TEXT-F19.
        <LS_FCAT>-COL_POS = '19'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "전송일자
      WHEN 'IFTIM'.
        <LS_FCAT>-COLTEXT = TEXT-F20.
        <LS_FCAT>-COL_POS = '20'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "전송시간
      WHEN 'IFNAM'.
        <LS_FCAT>-COLTEXT = TEXT-F21.
        <LS_FCAT>-COL_POS = '21'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'. "전송자
      WHEN 'GONG_CD'.
        CLEAR <LS_FCAT>-KEY.
        CASE ABAP_TRUE.
          WHEN P_R11 OR P_R12.
          WHEN OTHERS.
            <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDCASE.
      WHEN 'GONG_NM'.
        CASE ABAP_TRUE.
          WHEN P_R11 OR P_R12.
          WHEN OTHERS.
            <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDCASE.

    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_cell_attribute_grid_0100
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0100 .

*  DATA : LT_CELLTAB TYPE LVC_T_STYL.
*  DATA : LS_CELLTAB TYPE LVC_S_STYL.
*  LOOP AT GT_HEADER ASSIGNING FIELD-SYMBOL(<LS_HEADER>).
*    REFRESH LT_CELLTAB.
*    IF GV_DIS_MODE = 'D'.
*    ELSE.
*      LOOP AT GT_FIELDCAT_0100 INTO DATA(LS_FCAT).
*        IF <LS_HEADER>-CHK_CHG = 'N'. " 라인추가시 변경불가필드 세팅
*          CASE LS_FCAT-FIELDNAME.
*            WHEN 'STATUS'.
*              CONTINUE.
*          ENDCASE.
*        ELSE. " 변경불가필드 세팅
*          CASE <LS_HEADER>-STATUS.
*            WHEN ICON_LED_YELLOW.
*              CASE LS_FCAT-FIELDNAME.
*                WHEN 'STATUS'.
*                  CONTINUE.
*              ENDCASE.
*            WHEN ICON_LED_GREEN.
*              CASE LS_FCAT-FIELDNAME.
*                WHEN 'STATUS' OR 'MODULE_KIND' OR 'CODEGRP' OR 'FLDNR'.
*                  CONTINUE.
*              ENDCASE.
*          ENDCASE.
*
*        ENDIF.
*        CLEAR LS_CELLTAB.
*        __SET_CELL_ATTRIBUTE LS_FCAT-FIELDNAME CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*        INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
*      ENDLOOP.
*    ENDIF.
*    <LS_HEADER>-CELLTAB = LT_CELLTAB.
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
FORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES PT_TABLE USING PV_VALUE.

  DATA: LV_EXCLUDE TYPE UI_FUNC.

  LV_EXCLUDE = PV_VALUE.
*& 결과적으로 GT_EXCLUDE에 제거할 버튼 저장
  APPEND LV_EXCLUDE TO PT_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_grid_0100_display
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .

  ALV_VARIANT-REPORT = SY-REPID.
*- I_SAVE
*-'':레이아웃 조회만
*-'X':사용자고유 사용불가
*-'U':사용자고유만 사용가능
*-'A':모두사용가능
  IF P_R1 = 'X'. "전송

    CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYOUT_0100
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
        IS_VARIANT           = ALV_VARIANT  " 선택 메뉴 display
        I_SAVE               = 'A'
      CHANGING
        IT_OUTTAB            = GT_DISP
        IT_FIELDCATALOG      = GT_FIELDCAT_0100.

  ELSE.

    CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYOUT_0100
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
        IS_VARIANT           = ALV_VARIANT  " 선택 메뉴 display
        I_SAVE               = 'A'
      CHANGING
        IT_OUTTAB            = GT_DISP2
        IT_FIELDCATALOG      = GT_FIELDCAT_0100.

  ENDIF.
* 인풋이벤트 추가
  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
