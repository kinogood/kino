*&---------------------------------------------------------------------*
*& Include          ZGTPPR3010F02
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
*& Form build_sort_field
*&---------------------------------------------------------------------*
FORM build_sort_field .

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
    WHEN 'MATNR'. "자재코드

      CLEAR gs_disp.
      READ TABLE gt_disp INTO gs_disp INDEX pv_row_id-index.

      SET PARAMETER ID 'MAT' FIELD gs_disp-matnr.
      SET PARAMETER ID 'WRK' FIELD p_werks.
      SET PARAMETER ID 'LAG' FIELD gs_disp-lgort.

      CALL TRANSACTION 'MMBE'.

    WHEN 'PMATNR'. "품목코드

      CLEAR gs_disp.
      READ TABLE gt_disp INTO gs_disp INDEX pv_row_id-index.

      SET PARAMETER ID 'MAT' FIELD gs_disp-pmatnr.

      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.

    WHEN 'AUFNR'. "생산오더

      CLEAR gs_disp.
      READ TABLE gt_disp INTO gs_disp INDEX pv_row_id-index.

      SET PARAMETER ID 'ANR' FIELD gs_disp-aufnr.

      CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

    WHEN 'ERFMG' OR 'ERFMG_E'.

      CLEAR : gs_popup, gt_popup.
      IF p_work EQ 'X'.

        READ TABLE gt_disp INTO gs_disp INDEX pv_row_id-index.
        IF gs_disp-gubun EQ TEXT-007.

          SELECT a~weblnr, a~weblpos, a~seqno, a~matnr, b~maktx, a~werks, a~lgort,
                       a~erfmg, a~erfme, a~charg, a~tagnr, a~zup_tagnr, a~budat, a~mblnr,
                       a~mjahr, a~crdat, a~crtim, a~crnam
              INTO CORRESPONDING FIELDS OF TABLE @gt_popup
              FROM zgtppt3101 AS a INNER JOIN makt AS b
                   ON        a~matnr  EQ b~matnr
                   AND      b~spras EQ @sy-langu
                   WHERE a~weblnr   EQ @gs_disp-weblnr
                        AND a~weblpos EQ @gs_disp-weblpos
                        AND a~cancelled EQ @space.

          IF gt_popup[] IS NOT INITIAL.

            SORT gt_popup BY weblnr weblpos seqno.
            CALL SCREEN 0200 STARTING AT 2 2 ENDING AT 150 20.

          ENDIF.

        ENDIF.

      ENDIF.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
FORM double_click USING pv_row pv_column.
** 재처리 내역 조회시에만 상세 투입 정보 POPUP
*  CLEAR : gs_popup, gt_popup.
*  IF p_work EQ 'X'.
*
*    READ TABLE gt_disp INTO gs_disp INDEX pv_row.
*    IF gs_disp-gubun EQ TEXT-007.
*
*      CASE pv_column.
*        WHEN 'ERFMG' OR 'ERFMG_E'.
*
*          SELECT a~weblnr, a~weblpos, a~seqno, a~matnr, b~maktx, a~werks, a~lgort,
*                       a~erfmg, a~erfme, a~charg, a~tagnr, a~zup_tagnr, a~budat, a~mblnr,
*                       a~mjahr, a~crdat, a~crtim, a~crnam
*              INTO CORRESPONDING FIELDS OF TABLE @gt_popup
*              FROM zgtppt3101 AS a INNER JOIN makt AS b
*                   ON        a~matnr  EQ b~matnr
*                   AND      b~spras EQ @sy-langu
*                   WHERE a~weblnr   EQ @gs_disp-weblnr
*                        AND a~weblpos EQ @gs_disp-weblpos.
*
*          IF gt_popup[] IS NOT INITIAL.
*
*            SORT gt_popup BY weblnr weblpos seqno.
*            CALL SCREEN 0200 STARTING AT 2 2 ENDING AT 150 20.
*
*          ENDIF.
*
*      ENDCASE.
*
*    ENDIF.
*
*  ENDIF.

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
*& Form set_layout_grid_0100
*&---------------------------------------------------------------------*
FORM set_layout_grid_0100 .
*& General display options
  CLEAR gs_layout_0100.
  gs_layout_0100-cwidth_opt = 'X'.
  gs_layout_0100-sel_mode   = 'D'.
*  ps_layocat-edit       = 'E'.
  gs_layout_0100-no_rowmark = ' '.           "선택버튼 비활성
  gs_layout_0100-stylefname = 'CELLTAB'.
  gs_layout_0100-ctab_fname   = 'CELLCOL'.
*&  ps_layocat-smalltitle = 'X'.           "작은타이틀.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0100
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0100 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR3010TOP'
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
        <ls_fcat>-just      = 'C'. "상태
      WHEN 'MESSAGE'.
        <ls_fcat>-coltext = TEXT-f02.
        <ls_fcat>-col_pos = '2'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'. "오류 메시지
      WHEN 'BACKGROUND'.
        <ls_fcat>-coltext = TEXT-f03.
        <ls_fcat>-col_pos = '3'.
        IF p_work NE 'X'.
          <ls_fcat>-no_out = 'X'.
        ELSE.
          <ls_fcat>-no_out = ' '.
        ENDIF.
        <ls_fcat>-just      = 'C'. "자동 처리
      WHEN 'GUBUN'.
        <ls_fcat>-coltext = TEXT-f44.
        <ls_fcat>-col_pos = '4'.
*        IF p_work NE 'X'.
*          <ls_fcat>-no_out = 'X'.
*        ELSE.
        <ls_fcat>-no_out = ' '.
*        ENDIF.
        <ls_fcat>-just      = 'C'. "오류 유형
      WHEN 'WERKS'.
        <ls_fcat>-coltext = TEXT-f04.
        <ls_fcat>-col_pos = '5'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "플랜트
      WHEN 'NAME1'.
        <ls_fcat>-coltext = TEXT-f05.
        <ls_fcat>-col_pos = '6'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'. "내역
      WHEN 'DISPO'.
        <ls_fcat>-coltext = TEXT-f06.
        <ls_fcat>-col_pos = '7'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "MRP관리자
      WHEN 'DSNAM'.
        <ls_fcat>-coltext = TEXT-f07.
        <ls_fcat>-col_pos = '8'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "내역
      WHEN 'WEBLNR'.
        <ls_fcat>-coltext = TEXT-f08.
        <ls_fcat>-col_pos = '9'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "백로그 문서 번호
      WHEN 'WEBLPOS'.
        <ls_fcat>-coltext = TEXT-f09.
        <ls_fcat>-col_pos = '10'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "백로그 문서 아이템
      WHEN 'DEL_REASON'.
        <ls_fcat>-coltext = TEXT-f10.
        <ls_fcat>-col_pos = '11'.
        IF p_del EQ 'X'.
          <ls_fcat>-no_out = ' '.
        ELSE.
          <ls_fcat>-no_out = 'X'.
        ENDIF.
        <ls_fcat>-just      = 'C'."삭제 사유 코드
      WHEN 'REASON_TEXT'.
        <ls_fcat>-coltext = TEXT-f11.
        <ls_fcat>-col_pos = '12'.
        IF p_del EQ 'X'.
          <ls_fcat>-no_out = ' '.
        ELSE.
          <ls_fcat>-no_out = 'X'.
        ENDIF.
        <ls_fcat>-just      = 'L'. "삭제 사유 내역
      WHEN 'DETAILS'.
        <ls_fcat>-coltext = TEXT-f12.
        <ls_fcat>-col_pos = '13'.
        IF p_del EQ 'X'.
          <ls_fcat>-no_out = ' '.
        ELSE.
          <ls_fcat>-no_out = 'X'.
        ENDIF.
        <ls_fcat>-just      = 'L'."상세 내역
      WHEN 'ERSDA'.
        <ls_fcat>-coltext = TEXT-f13.
        <ls_fcat>-col_pos = '14'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "오류일자
      WHEN 'ERZET'.
        <ls_fcat>-coltext = TEXT-f14.
        <ls_fcat>-col_pos = '15'.
        <ls_fcat>-just      = 'C'. "오류시간
      WHEN 'ERNAM'.
        <ls_fcat>-coltext = TEXT-f15.
        <ls_fcat>-col_pos = '16'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "생성자
      WHEN 'ENAME'.
        <ls_fcat>-coltext = TEXT-f16.
        <ls_fcat>-col_pos = '17'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'. "성명
      WHEN 'LAEDA'.
        <ls_fcat>-coltext = TEXT-f17.
        <ls_fcat>-col_pos = '18'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "최종변경일자
      WHEN 'AENAM'.
        <ls_fcat>-coltext = TEXT-f18.
        <ls_fcat>-col_pos = '19'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "변경자
      WHEN 'CNAME'.
        <ls_fcat>-coltext = TEXT-f19.
        <ls_fcat>-col_pos = '20'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'. "성명
      WHEN 'MATNR'.
        <ls_fcat>-coltext = TEXT-f20.
        <ls_fcat>-col_pos = '21'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'.
        <ls_fcat>-hotspot = 'X'. "자재코드
      WHEN 'MAKTX'.
        <ls_fcat>-coltext = TEXT-f21.
        <ls_fcat>-col_pos = '22'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'. "자재내역
      WHEN 'MATKL'.
        <ls_fcat>-coltext = TEXT-f22.
        <ls_fcat>-col_pos = '23'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "자재그룹
      WHEN 'WGBEZ60'.
        <ls_fcat>-coltext = TEXT-f23.
        <ls_fcat>-col_pos = '24'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'. "자재그룹내역
      WHEN 'LGORT'.
        <ls_fcat>-coltext = TEXT-f24.
        <ls_fcat>-col_pos = '25'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'."저장위치
      WHEN 'CHARG'.
        <ls_fcat>-coltext = TEXT-f25.
        <ls_fcat>-col_pos = '26'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "배치번호
      WHEN 'BWART'.
        <ls_fcat>-coltext = TEXT-f26.
        <ls_fcat>-col_pos = '27'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "이동유형
      WHEN 'ERFMG_E'.
        <ls_fcat>-coltext = TEXT-f43.
        <ls_fcat>-col_pos = '28'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'R'.
        <ls_fcat>-qfieldname = 'ERFME'.
        <ls_fcat>-ref_field = 'ERFMG'.
        <ls_fcat>-ref_table = 'AFFW'.
        <ls_fcat>-hotspot = abap_true."투입오류수량
      WHEN 'ERFMG'.
        <ls_fcat>-coltext = TEXT-f27.
        <ls_fcat>-col_pos = '29'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'R'.
        <ls_fcat>-qfieldname = 'ERFME'.
        <ls_fcat>-ref_field = 'ERFMG'.
        <ls_fcat>-ref_table = 'AFFW'.
        <ls_fcat>-hotspot = abap_true."투입완료수량
      WHEN 'ERFME'.
        <ls_fcat>-coltext = TEXT-f28.
        <ls_fcat>-col_pos = '30'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "투입단위
      WHEN 'AUFNR'.
        <ls_fcat>-coltext = TEXT-f29.
        <ls_fcat>-col_pos = '31'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'.
        <ls_fcat>-hotspot = 'X'. "생산오더번호
      WHEN 'PMATNR'.
        <ls_fcat>-coltext = TEXT-f30.
        <ls_fcat>-col_pos = '32'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'.
        <ls_fcat>-hotspot = 'X'. "품목코드
      WHEN 'MAKTX2'.
        <ls_fcat>-coltext = TEXT-f31.
        <ls_fcat>-col_pos = '33'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'L'. "품목명
      WHEN 'RSNUM'.
        <ls_fcat>-coltext = TEXT-f32.
        <ls_fcat>-col_pos = '34'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "예약번호
      WHEN 'RSPOS'.
        <ls_fcat>-coltext = TEXT-f33.
        <ls_fcat>-col_pos = '35'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "예약아이템
      WHEN 'RUECK'.
        <ls_fcat>-coltext = TEXT-f34.
        <ls_fcat>-col_pos = '36'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "확정번호
      WHEN 'RMZHL'.
        <ls_fcat>-coltext = TEXT-f35.
        <ls_fcat>-col_pos = '37'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "확정카운터
      WHEN 'MSGID'.
        <ls_fcat>-coltext = TEXT-f36.
        <ls_fcat>-col_pos = '38'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "메시지ID
      WHEN 'MSGNO'.
        <ls_fcat>-coltext = TEXT-f37.
        <ls_fcat>-col_pos = '39'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "메시지번호
      WHEN 'BUDAT'.
        <ls_fcat>-coltext = TEXT-f38.
        <ls_fcat>-col_pos = '40'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "전기일자
      WHEN 'CRDAT'.
        IF p_work = 'X'.
          <ls_fcat>-coltext = TEXT-f55. "재처리일자
        ELSE.
          <ls_fcat>-coltext = TEXT-f39. "삭제일자
        ENDIF.
        <ls_fcat>-col_pos = '41'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'.
      WHEN 'CRTIM'.
        IF p_work = 'X'.
          <ls_fcat>-coltext = TEXT-f56. "재처리시간
        ELSE.
          <ls_fcat>-coltext = TEXT-f40. "삭제시간
        ENDIF.
        <ls_fcat>-col_pos = '42'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'.
      WHEN 'CRNAM'.
        IF p_work = 'X'.
          <ls_fcat>-coltext = TEXT-f57. "재처리자
        ELSE.
          <ls_fcat>-coltext = TEXT-f41. "삭제자
        ENDIF.
        <ls_fcat>-col_pos = '43'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'.
      WHEN 'DNAME'.
        <ls_fcat>-coltext = TEXT-f42.
        <ls_fcat>-col_pos = '44'.
        <ls_fcat>-no_out = ' '.
        <ls_fcat>-just      = 'C'. "성명
      WHEN OTHERS.
        <ls_fcat>-no_out = abap_true.
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
*  SET HANDLER go_event_handler->handle_double_click
*          FOR po_grid.
  SET HANDLER go_event_handler->handle_after_user_command
          FOR po_grid.
  SET HANDLER go_event_handler->handle_button_click
          FOR po_grid.
  SET HANDLER go_event_handler->handle_onf4
          FOR po_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_grid_0100_display
*&---------------------------------------------------------------------*
FORM call_grid_0100_display .

  IF p_layo IS NOT INITIAL.
    alv_variant-variant = p_layo.
  ENDIF.
  alv_variant-report = sy-repid.
*- I_SAVE
*-'':레이아웃 조회만
*-'X':사용자고유 사용불가
*-'U':사용자고유만 사용가능
*-'A':모두사용가능
  CALL METHOD go_grid_0100->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0100
      it_toolbar_excluding = gt_exclude_0100
      is_variant           = alv_variant  " 선택 메뉴 display
      i_save               = 'A'
    CHANGING
      it_outtab            = gt_disp
      it_fieldcatalog      = gt_fieldcat_0100.

* 인풋이벤트 추가
  CALL METHOD go_grid_0100->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD go_grid_0100->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0200
*&---------------------------------------------------------------------*
FORM set_object_grid_0200 .

  CREATE OBJECT go_contain_0200
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

  CREATE OBJECT go_grid_0200
    EXPORTING
      i_parent      = go_contain_0200
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_handler_register2
*&---------------------------------------------------------------------*
FORM event_handler_register2 USING po_grid TYPE REF TO cl_gui_alv_grid.
*& Edit  이벤트 등록
* IF MC_EVT_MODIFY  -> 바로 수정됨.
  CALL METHOD po_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.
*& Event Handler 등록
  CREATE OBJECT go_event_handler.

*  SET HANDLER go_event_handler->handle_toolbar
*          FOR po_grid.
*  SET HANDLER go_event_handler->handle_user_command
*          FOR po_grid.
*  SET HANDLER go_event_handler->handle_data_changed
*          FOR po_grid.
*  SET HANDLER go_event_handler->handle_data_changed_finished
*          FOR po_grid.
  SET HANDLER go_event_handler->handle_hotspot_click
          FOR po_grid.
  SET HANDLER go_event_handler->handle_double_click
          FOR po_grid.
*  SET HANDLER go_event_handler->handle_after_user_command
*          FOR po_grid.
*  SET HANDLER go_event_handler->handle_button_click
*          FOR po_grid.
*  SET HANDLER go_event_handler->handle_onf4
*          FOR po_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0200
*&---------------------------------------------------------------------*
FORM set_layout_grid_0200 .

  CLEAR gs_layout_0200.
*  gs_layout_0220-cwidth_opt = abap_true.
  gs_layout_0200-no_rowins = abap_true.
  gs_layout_0200-sel_mode   = 'A'.
  gs_layout_0200-smalltitle = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0200
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0200 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR3010TOP'
      i_internal_tabname     = 'GS_POPUP'
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
      et_fieldcat_lvc = gt_fieldcat_0200[]
    TABLES
      it_data         = gt_popup
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT gt_fieldcat_0200 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE   <ls_fcat>-fieldname.
      WHEN 'WEBLNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f45. "실투입 오류 문서
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_opt = abap_true.
        <ls_fcat>-key = abap_true.
      WHEN 'WEBLPOS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f46. "오류 문서 아이템
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_opt = abap_true.
        <ls_fcat>-key = abap_true.
      WHEN 'SEQNO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f47. "순번
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_opt = abap_true.
        <ls_fcat>-key = abap_true.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f20. "자재코드
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_opt = abap_true.
      WHEN 'MAKTX'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f21. "자재내역
        <ls_fcat>-just = 'L'.
        <ls_fcat>-outputlen = '24'.
      WHEN 'WERKS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f04. "플랜트
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_opt = abap_true.
      WHEN 'LGORT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f24. "저장위치
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_opt = abap_true.
      WHEN 'ERFMG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f27. "투입완료수량
        <ls_fcat>-qfieldname = 'ERFME'.
        <ls_fcat>-just = 'R'.
        <ls_fcat>-col_opt = abap_true.
      WHEN 'ERFME'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f28. "투입단위
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_opt = abap_true.
      WHEN 'CHARG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f25. "배치번호
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_opt = abap_true.
      WHEN 'TAGNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f48. "꼬리표번호
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_opt = abap_true.
      WHEN 'ZUP_TAGNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f49. "모코드 투입 꼬리표
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_opt = abap_true.
      WHEN 'BUDAT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f38. "전기일자
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_opt = abap_true.
      WHEN 'MBLNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f50. "자재 문서 번호
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_opt = abap_true.
      WHEN 'MJAHR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f51. "자재 문서 연도
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_opt = abap_true.
      WHEN 'CRDAT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f52. "처리일자
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_opt = abap_true.
      WHEN 'CRTIM'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f53. "처리시간
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_opt = abap_true.
      WHEN 'CRNAM'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f54. "처리자
        <ls_fcat>-just = 'C'.
        <ls_fcat>-col_opt = abap_true.

    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_of_toolbar_grid_0200
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0200 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0200
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
*& Form call_grid_0200_display
*&---------------------------------------------------------------------*
FORM call_grid_0200_display .

  CALL METHOD go_grid_0200->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0200
      it_toolbar_excluding = gt_exclude_0200
    CHANGING
      it_outtab            = gt_popup
      it_fieldcatalog      = gt_fieldcat_0200.

ENDFORM.
