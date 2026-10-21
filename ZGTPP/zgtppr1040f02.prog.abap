*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030F02
*&---------------------------------------------------------------------*
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
*& Form fill_field_catalogs
*&---------------------------------------------------------------------*
FORM FILL_FIELD_CATALOGS TABLES PT_FIELDCAT TYPE LVC_T_FCAT
                          USING  PV_GUB
                                 PV_FNAME
                                 PV_VALUE.
*& 'S' -> Structure에 필드 속성 값 Setting을 Start 시점
*& 'E' -> Structure의 내용을 필드 카타로그 테이블에 저장 시점
  IF PV_GUB = 'S'.
    CLEAR GS_FIELDCAT.
  ENDIF.
*& 출력될 Field 속성을 정의해서 필드 카타로그 테이블에 저장
  DATA LV_FNAME(40).
  FIELD-SYMBOLS <FS_FIELD> TYPE ANY.

  CONCATENATE 'GS_FIELDCAT-' PV_FNAME INTO LV_FNAME.

  ASSIGN (LV_FNAME) TO <FS_FIELD>.
  <FS_FIELD> = PV_VALUE.

  IF PV_GUB = 'E'.
    APPEND GS_FIELDCAT TO PT_FIELDCAT.
  ENDIF.

ENDFORM.
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

    WHEN 'AUFNR'. "생산 오더

      IF P_R1 = 'X'. "생산오더별
        CLEAR GS_DISP.
        READ TABLE GT_DISP1 INTO GS_DISP INDEX PV_ROW_ID-INDEX.
        SET PARAMETER ID 'ANR' FIELD GS_DISP-AUFNR.
        CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
      ELSEIF P_R2 = 'X'. "모품목별
        CLEAR GS_DISP.
        READ TABLE GT_DISP2 INTO GS_DISP INDEX PV_ROW_ID-INDEX.
        SET PARAMETER ID 'ANR' FIELD GS_DISP-AUFNR.
        CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
      ELSEIF P_R3 = 'X'. "자품목별
        CLEAR GS_DISP.
        READ TABLE GT_DISP3 INTO GS_DISP INDEX PV_ROW_ID-INDEX.
        SET PARAMETER ID 'ANR' FIELD GS_DISP-AUFNR.
        CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
      ENDIF.


*      IF p_r1 = 'X'.
*
*        CLEAR gs_disp.
*        READ TABLE gt_disp INTO gs_disp INDEX pv_row_id-index.
*
*        SET PARAMETER ID 'MAT' FIELD gs_disp-matnr.
*
*      ELSE.
*
*        CLEAR gs_disp2.
*        READ TABLE gt_disp2 INTO gs_disp2 INDEX pv_row_id-index.
*
*        SET PARAMETER ID 'MAT' FIELD gs_disp2-matnr.
*
*      ENDIF.
*
*      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.

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
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0100-ZEBRA = ABAP_TRUE.
*  GS_LAYOUT_0100-NO_ROWMOVE = ABAP_TRUE.
  GS_LAYOUT_0100-SMALLTITLE = 'X'.             "작은타이틀.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.
  GS_LAYOUT_0100-STYLEFNAME = 'CELLTAB'.       "셀스타일
  GS_LAYOUT_0100-CTAB_FNAME = 'CELLSCOL'.    "셀색상
*  ps_layocat-edit       = 'E'.
*  gs_layout_0100-no_rowmark = ' '.           "선택버튼 비활성




*  CLEAR gs_layout_0100.
*  gs_layout_0100-cwidth_opt = abap_true.
*  gs_layout_0100-no_rowins = abap_true.
**  GS_LAYOUT_0100-NO_ROWMOVE = ABAP_TRUE.
*  gs_layout_0100-smalltitle = abap_true.
*  gs_layout_0100-sel_mode   = 'D'.
*  gs_layout_0100-stylefname = 'CELLTAB'.
*  gs_layout_0100-ctab_fname   = 'CELLCOL'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0100
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .

  IF P_R1 = 'X'. "생산오더별

    PERFORM SET_FIELDCAT_FOR_RL.

  ELSEIF P_R2 = 'X'.  " 모품목별

    PERFORM SET_FIELDCAT_FOR_R2.

  ELSEIF P_R3 = 'X'.   " 자품목별

    PERFORM SET_FIELDCAT_FOR_R3.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_FOR_SEND
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_FOR_RL .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR1040TOP'
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
    CLEAR <LS_FCAT>-KEY.
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'WERKS '.
        <LS_FCAT>-COLTEXT = TEXT-F01. "플랜트
        <LS_FCAT>-COL_POS = '1'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'AUFNR'.
        <LS_FCAT>-COLTEXT = TEXT-F02.  "생산오더
        <LS_FCAT>-COL_POS = '2'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-HOTSPOT = 'X'.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'ZORDSTAT'.
        <LS_FCAT>-COLTEXT = TEXT-F03.  "오더상태
        <LS_FCAT>-COL_POS = '3'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'.
      WHEN 'ZPJNO'.
        <LS_FCAT>-COLTEXT = TEXT-F27.  "프로젝트번호
        <LS_FCAT>-COL_POS = '4'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'ZPTXT'.
        <LS_FCAT>-COLTEXT = TEXT-F28.   "프로젝트내역
        <LS_FCAT>-COL_POS = '5'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'.
      WHEN 'BSTNK'.
        <LS_FCAT>-COLTEXT = TEXT-F29.  "제조지시번호
        <LS_FCAT>-COL_POS = '6'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'ZJOB_NAME'.
        <LS_FCAT>-COLTEXT = TEXT-F30.   "제조지시내역
        <LS_FCAT>-COL_POS = '7'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'.
      WHEN 'GONG_CD'.
        <LS_FCAT>-COLTEXT = TEXT-F36.   "공정
        <LS_FCAT>-COL_POS = '8'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'ARBPL'.
        <LS_FCAT>-COLTEXT = TEXT-F37.   "작업장
        <LS_FCAT>-COL_POS = '9'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'KTEXT'.
        <LS_FCAT>-COLTEXT = TEXT-F38.   "작업장내역
        <LS_FCAT>-COL_POS = '10'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'.
      WHEN 'PMATN'.
        <LS_FCAT>-COLTEXT = TEXT-F04.  "모품목코드
        <LS_FCAT>-COL_POS = '11'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'PMAKTX'.
        <LS_FCAT>-COLTEXT = TEXT-F05.   "모품목내역
        <LS_FCAT>-COL_POS = '12'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'.
      WHEN 'MATKL'.
        <LS_FCAT>-COLTEXT = '모품목 자재그룹'.
        <LS_FCAT>-COL_POS = '13'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'DISPO'.
        <LS_FCAT>-COLTEXT = TEXT-F32.   "MRP 관리자
        <LS_FCAT>-COL_POS = '14'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'GAMNG'.
        <LS_FCAT>-COLTEXT = TEXT-F06.   "생산오더수량
        <LS_FCAT>-COL_POS = '15'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'WEMNG'.
        <LS_FCAT>-COLTEXT = TEXT-F07.  "생산입고수량
        <LS_FCAT>-COL_POS = '16'.
        <LS_FCAT>-NO_OUT = ' '.
*        <ls_fcat>-hotspot = 'X'.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'GMEIN'.
        <LS_FCAT>-COLTEXT = TEXT-F08.  "생산단위
        <LS_FCAT>-COL_POS = '17'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'KGW_CU_GR'.
        <LS_FCAT>-COLTEXT = TEXT-F39.  "입고CU량
        <LS_FCAT>-COL_POS = '18'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'KGW_AL_GR'.
        <LS_FCAT>-COLTEXT = TEXT-F40.  "입고AL량
        <LS_FCAT>-COL_POS = '19'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'BME_GR'.
        <LS_FCAT>-COLTEXT = TEXT-F41.  "중량단위
        <LS_FCAT>-COL_POS = '20'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'CMATN'.
        <LS_FCAT>-COLTEXT = TEXT-F09.   "자품목코드
        <LS_FCAT>-COL_POS = '21'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'CMAKTX'.
        <LS_FCAT>-COLTEXT = TEXT-F10.   "자품목내역
        <LS_FCAT>-COL_POS = '22'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'.
      WHEN 'BDMNG'.
        <LS_FCAT>-COLTEXT = TEXT-F11. "소요량(생산오더수량 기준)
        <LS_FCAT>-COL_POS = '23'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'ZCUMNG'.
        <LS_FCAT>-COLTEXT = TEXT-F12.  "소요량(생산입고수량 기준)
        <LS_FCAT>-COL_POS = '24'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'ZSTAT'.
        <LS_FCAT>-COLTEXT = TEXT-F31.  "백로그 존재여부
        <LS_FCAT>-COL_POS = '25'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'MENGE'.
        <LS_FCAT>-COLTEXT = TEXT-F13.  "생산투입수량
        <LS_FCAT>-COL_POS = '26'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-COLTEXT = TEXT-F14.   "출고단위
        <LS_FCAT>-COL_POS = '27'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'ZCLASS'.
        <LS_FCAT>-COLTEXT = TEXT-F15.  "투입상태
        <LS_FCAT>-COL_POS = '28'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'ZQTYDIF'.
        <LS_FCAT>-COLTEXT = TEXT-F16.  "차이수량
        <LS_FCAT>-COL_POS = '29'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'ZGIRATE'.
        <LS_FCAT>-COLTEXT = TEXT-F17.  "투입율(%)
        <LS_FCAT>-COL_POS = '30'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'ZGIRATE_D'.
        <LS_FCAT>-COLTEXT = TEXT-F17.  "투입율(%)
        <LS_FCAT>-COL_POS = '31'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'KGW_CU_GI'.
        <LS_FCAT>-COLTEXT = TEXT-F42.  "투입CU량
        <LS_FCAT>-COL_POS = '32'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'KGW_AL_GI'.
        <LS_FCAT>-COLTEXT = TEXT-F43.  "투입AL량
        <LS_FCAT>-COL_POS = '33'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'BME_GI'.
        <LS_FCAT>-COLTEXT = TEXT-F41.  "중량단위
        <LS_FCAT>-COL_POS = '34'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'STPRS'.
        <LS_FCAT>-COLTEXT = TEXT-F33.  "표준가
        <LS_FCAT>-COL_POS = '35'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'ZAMTDIF'.
        <LS_FCAT>-COLTEXT = TEXT-F34.  "차이금액
        <LS_FCAT>-COL_POS = '36'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'WAERS'.
        <LS_FCAT>-COLTEXT = TEXT-F35.  "통화키
        <LS_FCAT>-COL_POS = '37'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
*U01
      WHEN 'ID'.
        <LS_FCAT>-COLTEXT = '처리상태'.
        <LS_FCAT>-COL_POS = '38'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = 'X'.
      WHEN 'RTMSG'.
        <LS_FCAT>-COLTEXT = '처리결과'.
        <LS_FCAT>-COL_POS = '39'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'.
      WHEN 'STATS_SUGI'.
        <LS_FCAT>-COLTEXT = '수기투입여부'.
        <LS_FCAT>-COL_POS = '40'.
        <LS_FCAT>-JUST      = 'C'.
        <LS_FCAT>-ICON      = 'X'.
      WHEN 'CHK_INSPECTION'.
        <LS_FCAT>-COLTEXT = '점검완료여부'.
        <LS_FCAT>-COL_POS = '900'.
        <LS_FCAT>-JUST      = 'C'.

*U01
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.

*U01
    IF S_WERKS-LOW NE '1306'.
      IF <LS_FCAT>-FIELDNAME = 'ID' OR
         <LS_FCAT>-FIELDNAME = 'RTMSG'.
        <LS_FCAT>-NO_OUT = 'X'.
      ENDIF.
    ENDIF.
*U01

  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_cell_attribute_grid_0100
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0100 .

  DATA : LT_CELLCOL TYPE LVC_T_SCOL.
  DATA : LS_CELLCOL TYPE LVC_S_SCOL.
  DATA : LS_COL  TYPE LVC_S_COLO. "색상이 임시 저장될 구조체

  IF P_R1 = 'X'. "생산오더별
    LOOP AT GT_DISP1 INTO GS_DISP.
      REFRESH LT_CELLCOL.

      CASE GS_DISP-ZCLASS.
        WHEN '적정투입' .

        WHEN '과소투입'.
          LS_CELLCOL-FNAME = 'ZCLASS'.
          LS_CELLCOL-COLOR-COL = '3'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

          LS_CELLCOL-FNAME = 'ZQTYDIF'.
          LS_CELLCOL-COLOR-COL = '3'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

          LS_CELLCOL-FNAME = 'ZGIRATE'.
          LS_CELLCOL-COLOR-COL = '3'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

          LS_CELLCOL-FNAME = 'ZGIRATE_D'.
          LS_CELLCOL-COLOR-COL = '3'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.
        WHEN '과다투입'.
          LS_CELLCOL-FNAME = 'ZCLASS'.
          LS_CELLCOL-COLOR-COL = '6'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

          LS_CELLCOL-FNAME = 'ZQTYDIF'.
          LS_CELLCOL-COLOR-COL = '6'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

          LS_CELLCOL-FNAME = 'ZGIRATE'.
          LS_CELLCOL-COLOR-COL = '6'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

          LS_CELLCOL-FNAME = 'ZGIRATE_D'.
          LS_CELLCOL-COLOR-COL = '6'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.
      ENDCASE.

      INSERT LINES OF LT_CELLCOL INTO TABLE GS_DISP-CELLSCOL.

      MODIFY GT_DISP1 FROM GS_DISP.

    ENDLOOP.

  ELSEIF P_R2 = 'X'. "모품목별
    LOOP AT GT_DISP2 INTO GS_DISP.
      REFRESH LT_CELLCOL.

      CASE GS_DISP-ZCLASS.
        WHEN '적정투입' .

        WHEN '과소투입'.
          LS_CELLCOL-FNAME = 'ZCLASS'.
          LS_CELLCOL-COLOR-COL = '3'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

          LS_CELLCOL-FNAME = 'ZQTYDIF'.
          LS_CELLCOL-COLOR-COL = '3'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

          LS_CELLCOL-FNAME = 'ZGIRATE'.
          LS_CELLCOL-COLOR-COL = '3'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

          LS_CELLCOL-FNAME = 'ZGIRATE_D'.
          LS_CELLCOL-COLOR-COL = '3'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.
        WHEN '과다투입'.
          LS_CELLCOL-FNAME = 'ZCLASS'.
          LS_CELLCOL-COLOR-COL = '6'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

          LS_CELLCOL-FNAME = 'ZQTYDIF'.
          LS_CELLCOL-COLOR-COL = '6'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

          LS_CELLCOL-FNAME = 'ZGIRATE'.
          LS_CELLCOL-COLOR-COL = '6'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

          LS_CELLCOL-FNAME = 'ZGIRATE_D'.
          LS_CELLCOL-COLOR-COL = '6'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.
      ENDCASE.

      INSERT LINES OF LT_CELLCOL INTO TABLE GS_DISP-CELLSCOL.

      MODIFY GT_DISP2 FROM GS_DISP.

    ENDLOOP.
  ELSEIF P_R3 = 'X'. "자품목별
    LOOP AT GT_DISP3 INTO GS_DISP.
      REFRESH LT_CELLCOL.

      CASE GS_DISP-ZCLASS.
        WHEN '적정투입' .

        WHEN '과소투입'.
          LS_CELLCOL-FNAME = 'ZCLASS'.
          LS_CELLCOL-COLOR-COL = '3'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

          LS_CELLCOL-FNAME = 'ZQTYDIF'.
          LS_CELLCOL-COLOR-COL = '3'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

          LS_CELLCOL-FNAME = 'ZGIRATE'.
          LS_CELLCOL-COLOR-COL = '3'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

          LS_CELLCOL-FNAME = 'ZGIRATE_D'.
          LS_CELLCOL-COLOR-COL = '3'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.
        WHEN '과다투입'.
          LS_CELLCOL-FNAME = 'ZCLASS'.
          LS_CELLCOL-COLOR-COL = '6'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

          LS_CELLCOL-FNAME = 'ZQTYDIF'.
          LS_CELLCOL-COLOR-COL = '6'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

          LS_CELLCOL-FNAME = 'ZGIRATE'.
          LS_CELLCOL-COLOR-COL = '6'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.

          LS_CELLCOL-FNAME = 'ZGIRATE_D'.
          LS_CELLCOL-COLOR-COL = '6'.
          LS_CELLCOL-COLOR-INT = '0'.
          LS_CELLCOL-COLOR-INV = '0'.
          LS_CELLCOL-NOKEYCOL  = ' '.
          INSERT LS_CELLCOL INTO TABLE LT_CELLCOL.
      ENDCASE.

      INSERT LINES OF LT_CELLCOL INTO TABLE GS_DISP-CELLSCOL.

      MODIFY GT_DISP3 FROM GS_DISP.

    ENDLOOP.
  ENDIF.
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
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
*                cl_gui_alv_grid=>mc_fc_refresh.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_grid_0100_display
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .

  IF P_LAYO IS NOT INITIAL.
    ALV_VARIANT-VARIANT = P_LAYO.
  ENDIF.
  ALV_VARIANT-REPORT = SY-REPID.

  IF P_R1 = 'X'. "생산오더별

    CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYOUT_0100
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
        IS_VARIANT           = ALV_VARIANT  " 선택, 메뉴 display
        I_SAVE               = 'U' "'X'
      CHANGING
        IT_OUTTAB            = GT_DISP1
        IT_FIELDCATALOG      = GT_FIELDCAT_0100.

  ELSEIF P_R2 = 'X'. "모품목별.

    CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYOUT_0100
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
        IS_VARIANT           = ALV_VARIANT  " 선택 메뉴 display
        I_SAVE               = 'U'
      CHANGING
        IT_OUTTAB            = GT_DISP2
        IT_FIELDCATALOG      = GT_FIELDCAT_0100.

  ELSEIF P_R3 = 'X'. "자품목별.

    CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYOUT_0100
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
        IS_VARIANT           = ALV_VARIANT  " 선택 메뉴 display
        I_SAVE               = 'U'
      CHANGING
        IT_OUTTAB            = GT_DISP3
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
*&---------------------------------------------------------------------*
*& Form set_fieldcat_for_r2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_FOR_R2 .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR1040TOP'
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
    CLEAR <LS_FCAT>-KEY.
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'WERKS '.
        <LS_FCAT>-COLTEXT = TEXT-F01. "플랜트
        <LS_FCAT>-COL_POS = '1'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'AUFNR'.
        <LS_FCAT>-COLTEXT = TEXT-F02.  "생산오더
        <LS_FCAT>-COL_POS = '2'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-HOTSPOT = 'X'.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'ZORDSTAT'.
        <LS_FCAT>-COLTEXT = TEXT-F03.  "오더상태
        <LS_FCAT>-COL_POS = '3'.
        <LS_FCAT>-NO_OUT  = 'X'.
        <LS_FCAT>-JUST    = 'L'.
      WHEN 'ZPJNO'.
        <LS_FCAT>-COLTEXT = TEXT-F27.  "프로젝트번호
        <LS_FCAT>-COL_POS = '4'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'ZPTXT'.
        <LS_FCAT>-COLTEXT = TEXT-F28.   "프로젝트내역
        <LS_FCAT>-COL_POS = '5'.
        <LS_FCAT>-NO_OUT  = 'X'.
        <LS_FCAT>-JUST    = 'L'.
      WHEN 'BSTNK'.
        <LS_FCAT>-COLTEXT = TEXT-F29.  "제조지시번호
        <LS_FCAT>-COL_POS = '6'.
        <LS_FCAT>-NO_OUT  = 'X'.
        <LS_FCAT>-JUST    = 'C'.
      WHEN 'ZJOB_NAME'.
        <LS_FCAT>-COLTEXT = TEXT-F30.   "제조지시내역
        <LS_FCAT>-COL_POS = '7'.
        <LS_FCAT>-NO_OUT  = 'X'.
        <LS_FCAT>-JUST    = 'L'.
      WHEN 'PMATN'.
        <LS_FCAT>-COLTEXT = TEXT-F04.  "모품목코드
        <LS_FCAT>-COL_POS = '8'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'PMAKTX'.
        <LS_FCAT>-COLTEXT = TEXT-F05.   "모품목내역
        <LS_FCAT>-COL_POS = '9'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'.
      WHEN 'MATKL'.
        <LS_FCAT>-COLTEXT = '모품목 자재그룹'.
        <LS_FCAT>-COL_POS = '10'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'DISPO'.
        <LS_FCAT>-COLTEXT = TEXT-F32.   "MRP 관리자
        <LS_FCAT>-COL_POS = '11'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'GAMNG'.
        <LS_FCAT>-COLTEXT = TEXT-F06.   "생산오더수량
        <LS_FCAT>-COL_POS = '12'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'WEMNG'.
        <LS_FCAT>-COLTEXT = TEXT-F07.  "생산입고수량
        <LS_FCAT>-COL_POS = '13'.
        <LS_FCAT>-NO_OUT = ' '.
*        <ls_fcat>-hotspot = 'X'.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'GMEIN'.
        <LS_FCAT>-COLTEXT = TEXT-F08.  "생산단위
        <LS_FCAT>-COL_POS = '14'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'CMATN'.
        <LS_FCAT>-COLTEXT = TEXT-F09.   "자품목코드
        <LS_FCAT>-COL_POS = '15'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'CMAKTX'.
        <LS_FCAT>-COLTEXT = TEXT-F10.   "자품목내역
        <LS_FCAT>-COL_POS = '16'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'.
      WHEN 'BDMNG'.
        <LS_FCAT>-COLTEXT = TEXT-F11. "소요량(생산오더수량 기준)
        <LS_FCAT>-COL_POS = '17'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'ZCUMNG'.
        <LS_FCAT>-COLTEXT = TEXT-F12.  "소요량(생산입고수량 기준)
        <LS_FCAT>-COL_POS = '18'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'ZSTAT'.
        <LS_FCAT>-COLTEXT = TEXT-F31.  "백로그 존재여부
        <LS_FCAT>-COL_POS = '19'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'MENGE'.
        <LS_FCAT>-COLTEXT = TEXT-F13.  "생산투입수량
        <LS_FCAT>-COL_POS = '20'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-COLTEXT = TEXT-F14.   "출고단위
        <LS_FCAT>-COL_POS = '21'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'ZCLASS'.
        <LS_FCAT>-COLTEXT = TEXT-F15.  "투입상태
        <LS_FCAT>-COL_POS = '22'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'ZQTYDIF'.
        <LS_FCAT>-COLTEXT = TEXT-F16.  "차이수량
        <LS_FCAT>-COL_POS = '23'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'ZGIRATE'.
        <LS_FCAT>-COLTEXT = TEXT-F17.  "투입율(%)
        <LS_FCAT>-COL_POS = '24'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'ZGIRATE_D'.
        <LS_FCAT>-COLTEXT = TEXT-F17.  "투입율(%)
        <LS_FCAT>-COL_POS = '25'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'STPRS'.
        <LS_FCAT>-COLTEXT = TEXT-F33.  "표준가
        <LS_FCAT>-COL_POS = '26'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'ZAMTDIF'.
        <LS_FCAT>-COLTEXT = TEXT-F34.  "차이금액
        <LS_FCAT>-COL_POS = '27'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'WAERS'.
        <LS_FCAT>-COLTEXT = TEXT-F35.  "통화키
        <LS_FCAT>-COL_POS = '28'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_for_r3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_FOR_R3 .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR1040TOP'
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
    CLEAR <LS_FCAT>-KEY.
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'WERKS '.
        <LS_FCAT>-COLTEXT = TEXT-F01. "플랜트
        <LS_FCAT>-COL_POS = '1'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'AUFNR'.
        <LS_FCAT>-COLTEXT = TEXT-F02.  "생산오더
        <LS_FCAT>-COL_POS = '2'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-HOTSPOT = 'X'.
        <LS_FCAT>-JUST      = 'C'.


      WHEN 'ZORDSTAT'.
        <LS_FCAT>-COLTEXT = TEXT-F03.  "오더상태
        <LS_FCAT>-COL_POS = '3'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-JUST      = 'L'.
      WHEN 'ZPJNO'.
        <LS_FCAT>-COLTEXT = TEXT-F27.  "프로젝트번호
        <LS_FCAT>-COL_POS = '4'.
        <LS_FCAT>-NO_OUT  = 'X'.
        <LS_FCAT>-JUST    = 'C'.
      WHEN 'ZPTXT'.
        <LS_FCAT>-COLTEXT = TEXT-F28.   "프로젝트내역
        <LS_FCAT>-COL_POS = '5'.
        <LS_FCAT>-NO_OUT  = 'X'.
        <LS_FCAT>-JUST    = 'L'.
      WHEN 'BSTNK'.
        <LS_FCAT>-COLTEXT = TEXT-F29.  "제조지시번호
        <LS_FCAT>-COL_POS = '6'.
        <LS_FCAT>-NO_OUT  = 'X'.
        <LS_FCAT>-JUST    = 'C'.
      WHEN 'ZJOB_NAME'.
        <LS_FCAT>-COLTEXT = TEXT-F30.   "제조지시내역
        <LS_FCAT>-COL_POS = '7'.
        <LS_FCAT>-NO_OUT  = 'X'.
        <LS_FCAT>-JUST    = 'L'.

      WHEN 'PMATN'.
        <LS_FCAT>-COLTEXT = TEXT-F04.  "모품목코드
        <LS_FCAT>-COL_POS = '8'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'PMAKTX'.
        <LS_FCAT>-COLTEXT = TEXT-F05.   "모품목내역
        <LS_FCAT>-COL_POS = '9'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-JUST      = 'L'.
*      WHEN 'DISPO'.
*        <ls_fcat>-coltext = TEXT-f32.   "MRP 관리자
*        <ls_fcat>-col_pos = '10'.
*        <ls_fcat>-no_out = ' '.
*        <ls_fcat>-just      = 'C'.
      WHEN 'GAMNG'.
        <LS_FCAT>-COLTEXT = TEXT-F06.   "생산오더수량
        <LS_FCAT>-COL_POS = '11'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'WEMNG'.
        <LS_FCAT>-COLTEXT = TEXT-F07.  "생산입고수량
        <LS_FCAT>-COL_POS = '12'.
        <LS_FCAT>-NO_OUT = 'X'.
*        <ls_fcat>-hotspot = 'X'.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'GMEIN'.
        <LS_FCAT>-COLTEXT = TEXT-F08.  "생산단위
        <LS_FCAT>-COL_POS = '13'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'CMATN'.
        <LS_FCAT>-COLTEXT = TEXT-F09.   "자품목코드
        <LS_FCAT>-COL_POS = '14'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'CMAKTX'.
        <LS_FCAT>-COLTEXT = TEXT-F10.   "자품목내역
        <LS_FCAT>-COL_POS = '15'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'L'.
      WHEN 'BDMNG'.
        <LS_FCAT>-COLTEXT = TEXT-F11. "소요량(생산오더수량 기준)
        <LS_FCAT>-COL_POS = '16'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'ZCUMNG'.
        <LS_FCAT>-COLTEXT = TEXT-F12.  "소요량(생산입고수량 기준)
        <LS_FCAT>-COL_POS = '17'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'ZSTAT'.
        <LS_FCAT>-COLTEXT = TEXT-F31.  "백로그 존재여부
        <LS_FCAT>-COL_POS = '18'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'MENGE'.
        <LS_FCAT>-COLTEXT = TEXT-F13.  "생산투입수량
        <LS_FCAT>-COL_POS = '19'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-COLTEXT = TEXT-F14.   "출고단위
        <LS_FCAT>-COL_POS = '20'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'ZCLASS'.
        <LS_FCAT>-COLTEXT = TEXT-F15.  "투입상태
        <LS_FCAT>-COL_POS = '21'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.
      WHEN 'ZQTYDIF'.
        <LS_FCAT>-COLTEXT = TEXT-F16.  "차이수량
        <LS_FCAT>-COL_POS = '22'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'ZGIRATE'.
        <LS_FCAT>-COLTEXT = TEXT-F17.  "투입율(%)
        <LS_FCAT>-COL_POS = '23'.
        <LS_FCAT>-NO_OUT = 'X'.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'ZGIRATE_D'.
        <LS_FCAT>-COLTEXT = TEXT-F17.  "투입율(%)
        <LS_FCAT>-COL_POS = '24'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'STPRS'.
        <LS_FCAT>-COLTEXT = TEXT-F33.  "표준가
        <LS_FCAT>-COL_POS = '25'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'ZAMTDIF'.
        <LS_FCAT>-COLTEXT = TEXT-F34.  "차이금액
        <LS_FCAT>-COL_POS = '26'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
        <LS_FCAT>-JUST      = 'R'.
      WHEN 'WAERS'.
        <LS_FCAT>-COLTEXT = TEXT-F35.  "통화키
        <LS_FCAT>-COL_POS = '27'.
        <LS_FCAT>-NO_OUT = ' '.
        <LS_FCAT>-JUST      = 'C'.

      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.

  ENDLOOP.
ENDFORM.
