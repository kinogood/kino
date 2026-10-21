*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form add_exclude_toolbar_button
*&---------------------------------------------------------------------*
FORM add_exclude_toolbar_button TABLES pt_table USING pv_value.

  DATA: lv_exclude TYPE ui_func.

  lv_exclude = pv_value.
*& 결과적으로 GT_EXCLUDE에 제거할 버튼 저장
  APPEND lv_exclude TO pt_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_field_catalogs
*&---------------------------------------------------------------------*
FORM fill_field_catalogs TABLES pt_fieldcat TYPE lvc_t_fcat
                          USING  pv_gub
                                 pv_fname
                                 pv_value.
*& 'S' -> Structure에 필드 속성 값 Setting을 Start 시점
*& 'E' -> Structure의 내용을 필드 카타로그 테이블에 저장 시점
  IF pv_gub = 'S'.
    CLEAR gs_fieldcat.
  ENDIF.
*& 출력될 Field 속성을 정의해서 필드 카타로그 테이블에 저장
  DATA lv_fname(40).
  FIELD-SYMBOLS <fs_field> TYPE any.

  CONCATENATE 'GS_FIELDCAT-' pv_fname INTO lv_fname.

  ASSIGN (lv_fname) TO <fs_field>.
  <fs_field> = pv_value.

  IF pv_gub = 'E'.
    APPEND gs_fieldcat TO pt_fieldcat.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form toolbar_proc
*&---------------------------------------------------------------------*
FORM toolbar_proc USING ps_object TYPE REF TO cl_alv_event_toolbar_set
                                  pv_interactive.

  DATA : ls_toolbar  TYPE stb_button.

  MOVE   3             TO  ls_toolbar-butn_type.
  APPEND ls_toolbar TO  ps_object->mt_toolbar.

  CLEAR ls_toolbar.
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
FORM user_command_proc USING pv_ucomm.

*  CASE r_ucomm.
*    WHEN ''.
*  ENDCASE.

*  PERFORM refresh_grid_display .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form after_user_command
*&---------------------------------------------------------------------*
FORM after_user_command USING pv_ucomm.

*  CASE pv_ucomm.
*    WHEN '&REFRESH'.
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed
*&---------------------------------------------------------------------*
FORM data_changed USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                       pv_onf4 TYPE char1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hotspot_click
*&---------------------------------------------------------------------*
FORM hotspot_click USING pv_row_id     TYPE lvc_s_row
                                     pv_column_id TYPE lvc_s_col.

  CASE pv_column_id-fieldname.

    WHEN 'MATNR'. "품목코드

      IF p_r1 = 'X'.

        CLEAR gs_disp.
        READ TABLE gt_disp INTO gs_disp INDEX pv_row_id-index.

        SET PARAMETER ID 'MAT' FIELD gs_disp-matnr.

      ELSE.

        CLEAR gs_disp2.
        READ TABLE gt_disp2 INTO gs_disp2 INDEX pv_row_id-index.

        SET PARAMETER ID 'MAT' FIELD gs_disp2-matnr.

      ENDIF.

      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
FORM double_click USING pv_row pv_column.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form button_click
*&---------------------------------------------------------------------*
FORM button_click USING ps_col_id  TYPE  lvc_s_col
                                 ps_row_no  TYPE  lvc_s_roid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form onf4_proc
*&---------------------------------------------------------------------*
FORM onf4_proc USING pv_fieldname   TYPE lvc_fname
                                 pv_fieldvalue  TYPE lvc_value
                                 ps_row_no     TYPE lvc_s_roid
                                 pr_event_data TYPE REF TO cl_alv_event_data
                                 pt_bad_cells  TYPE lvc_t_modi
                                 pv_display     TYPE char01.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0100
*&---------------------------------------------------------------------*
FORM set_object_grid_0100 .

  CREATE OBJECT go_docking_container
    EXPORTING
      repid                       = sy-repid
      dynnr                       = sy-dynnr
      extension                   = 10000
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5.
*화면 분할
  CREATE OBJECT go_splitter
    EXPORTING
      parent  = go_docking_container
      rows    = 1
      columns = 1.
* top 컨테이너
  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_contain_0100.
** bottom 컨테이너
*  CALL METHOD GO_SPLITTER->GET_CONTAINER
*    EXPORTING
*      ROW       = 2
*      COLUMN    = 1
*    RECEIVING
*      CONTAINER = GO_CONTAIN_0101.

  CREATE OBJECT go_grid_0100
    EXPORTING
      i_parent      = go_contain_0100
      i_appl_events = abap_true.

*  CREATE OBJECT go_grid_0101
*    EXPORTING
*      i_parent      = go_contain_0101
*      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_handler_register
*&---------------------------------------------------------------------*
FORM event_handler_register USING po_grid TYPE REF TO cl_gui_alv_grid.
*& Edit  이벤트 등록
* IF MC_EVT_MODIFY  -> 바로 수정됨.
  CALL METHOD po_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.
*& Event Handler 등록
  CREATE OBJECT go_event_handler.

  SET HANDLER go_event_handler->handle_toolbar
          FOR po_grid.
  SET HANDLER go_event_handler->handle_user_command
          FOR po_grid.
  SET HANDLER go_event_handler->handle_data_changed
          FOR po_grid.
  SET HANDLER go_event_handler->handle_data_changed_finished
          FOR po_grid.
  SET HANDLER go_event_handler->handle_hotspot_click
          FOR po_grid.
  SET HANDLER go_event_handler->handle_double_click
          FOR po_grid.
  SET HANDLER go_event_handler->handle_after_user_command
          FOR po_grid.
  SET HANDLER go_event_handler->handle_button_click
          FOR po_grid.
  SET HANDLER go_event_handler->handle_onf4
          FOR po_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0100
*&---------------------------------------------------------------------*
FORM set_layout_grid_0100 .
*& General display options
  CLEAR gs_layout_0100.
  gs_layout_0100-cwidth_opt = 'X'.
  gs_layout_0100-sel_mode   = 'D'.
*  ps_layocat-edit       = 'E'.
  gs_layout_0100-no_rowmark = ' '.           "선택버튼 비활성
*  ps_layocat-stylefname = 'T_STYL'.      "셀스타일
*  ps_layocat-ctab_fname = 'T_SCOL'.      "셀색상
*&  ps_layocat-smalltitle = 'X'.           "작은타이틀.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0100
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0100 .

  IF p_r1 = 'X'. "전송

    PERFORM set_fieldcat_for_send.

  ELSE.

    PERFORM set_fieldcat_for_resend.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_FOR_SEND
*&---------------------------------------------------------------------*
FORM set_fieldcat_for_send .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPI1030TOP'
      i_internal_tabname     = 'GS_DISP'
    CHANGING
      ct_fieldcat            = lt_fcat_slis
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat_slis
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0100[]
    TABLES
      it_data         = gt_disp
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT gt_fieldcat_0100 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE <ls_fcat>-fieldname.
      WHEN 'ICON'.
        <ls_fcat>-coltext = TEXT-f01.
        <ls_fcat>-col_pos = '1'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "전송 상태
      WHEN 'ZMESSAGE'.
        <ls_fcat>-coltext = TEXT-f02.
        <ls_fcat>-col_pos = '2'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'. "결과 메시지
      WHEN 'ZSYSTEM_ID'.
        <ls_fcat>-coltext = TEXT-f03.
        <ls_fcat>-col_pos = '3'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "수신 시스템
      WHEN 'ZSYSTEM_ID_DESC'.
        <ls_fcat>-coltext = TEXT-f04.
        <ls_fcat>-col_pos = '4'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'. "시스템 내역
      WHEN 'WERKS'.
        <ls_fcat>-coltext = TEXT-f05.
        <ls_fcat>-col_pos = '5'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "플랜트
      WHEN 'NAME1'.
        <ls_fcat>-coltext = TEXT-f06.
        <ls_fcat>-col_pos = '6'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'. "플랜트 내역
      WHEN 'MATNR'.
        <ls_fcat>-coltext = TEXT-f07.
        <ls_fcat>-col_pos = '7'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-hotspot = 'X'.
        <ls_fcat>-just      = 'C'. "자재 코드
      WHEN 'MAKTX'.
        <ls_fcat>-coltext = TEXT-f08.
        <ls_fcat>-col_pos = '8'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'. "자재 내역
      WHEN 'VERID'.
        <ls_fcat>-coltext = TEXT-f09.
        <ls_fcat>-col_pos = '9'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "Product Version
      WHEN 'TEXT1'.
        <ls_fcat>-coltext = TEXT-f10.
        <ls_fcat>-col_pos = '10'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'."Version Description
      WHEN 'ANDAT'.
        <ls_fcat>-coltext = TEXT-f11.
        <ls_fcat>-col_pos = '11'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "생성일
      WHEN 'AEDAT'.
        <ls_fcat>-coltext = TEXT-f12.
        <ls_fcat>-col_pos = '12'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'."변경일
      WHEN 'ADATU'.
        <ls_fcat>-coltext = TEXT-f13.
        <ls_fcat>-col_pos = '13'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "생산버전 효력발생일
      WHEN 'BDATU'.
        <ls_fcat>-coltext = TEXT-f14.
        <ls_fcat>-col_pos = '14'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "실행시간종료:생산버젼
      WHEN 'PLNNR'.
        <ls_fcat>-coltext = TEXT-f15.
        <ls_fcat>-col_pos = '15'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "직무리스트 그룹 키
      WHEN 'ALNAL'.
        <ls_fcat>-coltext = TEXT-f16.
        <ls_fcat>-col_pos = '16'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "Routing Group Counter
      WHEN 'STLAL'.
        <ls_fcat>-coltext = TEXT-f17.
        <ls_fcat>-col_pos = '17'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "대체 BOM No.
      WHEN 'MDV01'.
        <ls_fcat>-coltext = TEXT-f18.
        <ls_fcat>-col_pos = '18'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "작업장
      WHEN 'ALORT'.
        <ls_fcat>-coltext = TEXT-f19.
        <ls_fcat>-col_pos = '19'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "입고 저장위치
      WHEN 'ELPRO'.
        <ls_fcat>-coltext = TEXT-f20.
        <ls_fcat>-col_pos = '20'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "출고 저장위치
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_for_resend
*&---------------------------------------------------------------------*
FORM set_fieldcat_for_resend .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPI1030TOP'
      i_internal_tabname     = 'GS_DISP2'
    CHANGING
      ct_fieldcat            = lt_fcat_slis
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat_slis
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0100[]
    TABLES
      it_data         = gt_disp2
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT gt_fieldcat_0100 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE <ls_fcat>-fieldname.
      WHEN 'ZIFKEY'.
        <ls_fcat>-coltext = TEXT-f21.
        <ls_fcat>-col_pos = '1'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "인터페이스 키
      WHEN 'ZSEQNO'.
        <ls_fcat>-coltext = TEXT-f22.
        <ls_fcat>-col_pos = '2'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "순번
      WHEN 'ZSTAT'.
        <ls_fcat>-coltext = TEXT-f23.
        <ls_fcat>-col_pos = '3'.
        <ls_fcat>-no_out = 'X'.
        <ls_fcat>-just      = 'C'. "전송 결과
      WHEN 'ICON'.
        <ls_fcat>-coltext = TEXT-f23.
        <ls_fcat>-col_pos = '4'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "전송 결과
      WHEN 'ZMESSAGE'.
        <ls_fcat>-coltext = TEXT-f02.
        <ls_fcat>-col_pos = '5'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'. "결과 메시지
      WHEN 'ZSYSTEM_ID'.
        <ls_fcat>-coltext = TEXT-f03.
        <ls_fcat>-col_pos = '6'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "수신 시스템
      WHEN 'ZSYSTEM_ID_DESC'.
        <ls_fcat>-coltext = TEXT-f04.
        <ls_fcat>-col_pos = '7'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'. "시스템 내역
      WHEN 'WERKS'.
        <ls_fcat>-coltext = TEXT-f05.
        <ls_fcat>-col_pos = '8'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "플랜트
      WHEN 'NAME1'.
        <ls_fcat>-coltext = TEXT-f06.
        <ls_fcat>-col_pos = '9'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'. "플랜트 내역
      WHEN 'MATNR'.
        <ls_fcat>-coltext = TEXT-f07.
        <ls_fcat>-col_pos = '10'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-hotspot = 'X'.
        <ls_fcat>-just      = 'C'. "자재 코드
      WHEN 'MAKTX'.
        <ls_fcat>-coltext = TEXT-f08.
        <ls_fcat>-col_pos = '11'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'. "자재 내역
      WHEN 'VERID'.
        <ls_fcat>-coltext = TEXT-f09.
        <ls_fcat>-col_pos = '12'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "Product Version
      WHEN 'TEXT1'.
        <ls_fcat>-coltext = TEXT-f10.
        <ls_fcat>-col_pos = '13'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'."Version Description
      WHEN 'ANDAT'.
        <ls_fcat>-coltext = TEXT-f11.
        <ls_fcat>-col_pos = '14'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "생성일
      WHEN 'AEDAT'.
        <ls_fcat>-coltext = TEXT-f12.
        <ls_fcat>-col_pos = '15'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'."변경일
      WHEN 'ADATU'.
        <ls_fcat>-coltext = TEXT-f13.
        <ls_fcat>-col_pos = '16'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "생산버전 효력발생일
      WHEN 'BDATU'.
        <ls_fcat>-coltext = TEXT-f14.
        <ls_fcat>-col_pos = '17'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "실행시간종료:생산버젼
      WHEN 'PLNNR'.
        <ls_fcat>-coltext = TEXT-f15.
        <ls_fcat>-col_pos = '18'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "직무리스트 그룹 키
      WHEN 'ALNAL'.
        <ls_fcat>-coltext = TEXT-f16.
        <ls_fcat>-col_pos = '19'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "Routing Group Counter
      WHEN 'STLAL'.
        <ls_fcat>-coltext = TEXT-f17.
        <ls_fcat>-col_pos = '20'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "대체 BOM No.
      WHEN 'MDV01'.
        <ls_fcat>-coltext = TEXT-f18.
        <ls_fcat>-col_pos = '21'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "작업장
      WHEN 'ALORT'.
        <ls_fcat>-coltext = TEXT-f19.
        <ls_fcat>-col_pos = '22'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "입고 저장위치
      WHEN 'ELPRO'.
        <ls_fcat>-coltext = TEXT-f20.
        <ls_fcat>-col_pos = '23'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "출고 저장위치
      WHEN 'IFDAT'.
        <ls_fcat>-coltext = TEXT-f24.
        <ls_fcat>-col_pos = '24'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "전송일자
      WHEN 'IFTIM'.
        <ls_fcat>-coltext = TEXT-f25.
        <ls_fcat>-col_pos = '25'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "전송시간
      WHEN 'IFNAM'.
        <ls_fcat>-coltext = TEXT-f26.
        <ls_fcat>-col_pos = '26'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "전송자
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_cell_attribute_grid_0100
*&---------------------------------------------------------------------*
FORM set_cell_attribute_grid_0100 .

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
FORM exclude_of_toolbar_grid_0100 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0100
        USING : cl_gui_alv_grid=>mc_fc_loc_undo,
                cl_gui_alv_grid=>mc_fc_auf,
                cl_gui_alv_grid=>mc_fc_check,
                cl_gui_alv_grid=>mc_fc_loc_paste,
                cl_gui_alv_grid=>mc_fc_loc_copy,
                cl_gui_alv_grid=>mc_fc_average,
                cl_gui_alv_grid=>mc_fc_graph,
                cl_gui_alv_grid=>mc_fc_info,
                cl_gui_alv_grid=>mc_fc_loc_copy_row,
                cl_gui_alv_grid=>mc_fc_loc_cut,
                cl_gui_alv_grid=>mc_fc_loc_delete_row,
                cl_gui_alv_grid=>mc_fc_loc_insert_row,
                cl_gui_alv_grid=>mc_fc_loc_append_row,
                cl_gui_alv_grid=>mc_fc_loc_paste,
                cl_gui_alv_grid=>mc_fc_loc_paste_new_row,
                cl_gui_alv_grid=>mc_fc_refresh.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_grid_0100_display
*&---------------------------------------------------------------------*
FORM call_grid_0100_display .

  alv_variant-report = sy-repid.
*- I_SAVE
*-'':레이아웃 조회만
*-'X':사용자고유 사용불가
*-'U':사용자고유만 사용가능
*-'A':모두사용가능
  IF p_r1 = 'X'. "전송

    CALL METHOD go_grid_0100->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_0100
        it_toolbar_excluding = gt_exclude_0100
        is_variant           = alv_variant  " 선택 메뉴 display
        i_save               = 'A'
      CHANGING
        it_outtab            = gt_disp
        it_fieldcatalog      = gt_fieldcat_0100.

  ELSE.

    CALL METHOD go_grid_0100->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_0100
        it_toolbar_excluding = gt_exclude_0100
        is_variant           = alv_variant  " 선택 메뉴 display
        i_save               = 'A'
      CHANGING
        it_outtab            = gt_disp2
        it_fieldcatalog      = gt_fieldcat_0100.

  ENDIF.
* 인풋이벤트 추가
  CALL METHOD go_grid_0100->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD go_grid_0100->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.
