*&---------------------------------------------------------------------*
*& Include          ZGTPPR3000F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form toolbar_proc
*&---------------------------------------------------------------------*
FORM toolbar_proc USING po_sender
                        ps_object TYPE REF TO cl_alv_event_toolbar_set
                                              pv_interactive.

  DATA : ls_toolbar  TYPE stb_button.

  CASE po_sender.
    WHEN go_grid_0302.
      CASE abap_true.

          MOVE   3             TO  ls_toolbar-butn_type.
          APPEND ls_toolbar TO  ps_object->mt_toolbar.

          CLEAR ls_toolbar.
          MOVE 'UNASSIGN'       TO  ls_toolbar-function.
          MOVE icon_system_undo TO  ls_toolbar-icon.
          MOVE TEXT-035         TO  ls_toolbar-quickinfo.
          MOVE ' '              TO  ls_toolbar-disabled.
          MOVE TEXT-035         TO  ls_toolbar-text.
          APPEND ls_toolbar     TO  ps_object->mt_toolbar.

      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_proc
*&---------------------------------------------------------------------*
FORM user_command_proc USING po_sender TYPE REF TO cl_gui_alv_grid
                             pv_ucomm.

  DATA : lv_matnr LIKE mara-matnr.

  CASE po_sender.
    WHEN go_grid_0302.
      CASE pv_ucomm.
        WHEN 'UNASSIGN'.

          CLEAR : gt_row_no, gt_row_no[], gv_error.
          CALL METHOD po_sender->get_selected_rows
            IMPORTING
              et_row_no = gt_row_no[].

          CLEAR: gv_cnt.
          DESCRIBE TABLE gt_row_no LINES gv_cnt.
* 선택 라인 없으면 오류 메시지 출력
          IF gv_cnt = 0.
            MESSAGE s000 WITH TEXT-m01 DISPLAY LIKE 'E'.
          ELSEIF gv_cnt > 1.
            MESSAGE s000 WITH TEXT-m24 DISPLAY LIKE 'E'.
          ENDIF.

          CHECK gv_cnt = 1.
* CALL FUNCTION - POPUP_TO_CONFIRM_STEP
          CLEAR: gv_answer.
          CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
            EXPORTING
              titel     = TEXT-t14
              textline1 = TEXT-t15
              textline2 = ''
            IMPORTING
              answer    = gv_answer.
          CHECK gv_answer = 'J'.

          LOOP AT gt_row_no.

            CLEAR gs_302.
            READ TABLE gt_302 INTO gs_302 INDEX gt_row_no-row_id.

            IF gs_302 IS NOT INITIAL.

              CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
                EXPORTING
                  input  = gs_302-matnr_fr
                IMPORTING
                  output = lv_matnr.

              CLEAR gs_disp.
              READ TABLE gt_disp INTO gs_disp
                                 WITH KEY weblnr  = gs_302-weblnr
                                          weblpos = gs_302-weblpos.
              IF gs_disp IS NOT INITIAL.

                gv_tabix = sy-tabix.
* 백로그 자재 원복
                IF gs_disp-gubun = TEXT-008.

                  UPDATE affw SET   matnr   = lv_matnr
                              WHERE weblnr  = gs_disp-weblnr
                                AND weblpos = gs_disp-weblpos.
* 실투입 자재 원복
                ELSEIF gs_disp-gubun = TEXT-009.

                  UPDATE zgtppt3100 SET   matnr      = lv_matnr
                                    WHERE weblnr     = gs_disp-weblnr
                                      AND weblpos    = gs_disp-weblpos
                                      AND zserno     = gs_disp-zserno
                                      AND zsystem_id = gs_disp-zsystem_id.

                ENDIF.
* 제대로 처리되었으면 ALV 리스트에도 반영 및 DB COMMIT WORK.
                IF sy-subrc = 0.
* 대체 자재 수행 후 ZGTPPT3270에 업데이트
                  CLEAR gs_3270.
                  gs_3270-weblnr   = gs_302-weblnr.
                  gs_3270-weblpos  = gs_302-weblpos.
                  SELECT SINGLE MAX( seqno ) INTO @DATA(lv_seqno) FROM zgtppt3270
                                             WHERE weblnr  = @gs_302-weblnr
                                               AND weblpos = @gs_302-weblpos.
                  gs_3270-seqno    = lv_seqno + 1.
                  gs_3270-type     = 'M'.
                  gs_3270-matnr_fr = gs_disp-matnr.
                  gs_3270-matnr_to = lv_matnr.
                  gs_3270-werks    = p_werks.
                  gs_3270-lgort_fr = gs_disp-lgort.
                  gs_3270-erfmg_fr = gs_disp-erfmg.
                  gs_3270-erfme    = gs_disp-erfme.
                  gs_3270-budat_fr = gs_disp-budat.
                  gs_3270-chdat    = gs_3270-crdat    = sy-datum.
                  gs_3270-chtim    = gs_3270-crtim    = sy-uzeit.
                  gs_3270-chnam    = gs_3270-crnam    = sy-uname.
                  MODIFY zgtppt3270 FROM gs_3270.
                  IF sy-subrc = 0.

                    COMMIT WORK.
                    WAIT UP TO '0.5' SECONDS.
                    MESSAGE s003 WITH TEXT-m27.

                    gs_disp-matnr = lv_matnr.
                    gs_disp-maktx = zgtpp_cl_common=>get_maktx(
                                       iv_matnr = gs_disp-matnr ).
                    gs_disp-matkl = zgtpp_cl_common=>get_matkl(
                                       iv_matnr = gs_disp-matnr ).
                    MODIFY gt_disp FROM gs_disp INDEX gv_tabix.

                  ELSE.
                    MESSAGE s003 WITH TEXT-m29 DISPLAY LIKE 'E'.
                    ROLLBACK WORK.
                  ENDIF.
* 실패시 ROLLBACK
                ELSE.
                  MESSAGE s003 WITH TEXT-m28 DISPLAY LIKE 'E'.
                  ROLLBACK WORK.
                ENDIF.

              ENDIF.

            ENDIF.

          ENDLOOP.
* REFRESH DISPLAY
          CALL METHOD go_grid_0100->refresh_table_display
            EXPORTING
              i_soft_refresh = 'X'
              is_stable      = gv_stable.

          LEAVE TO SCREEN 0.

      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_grid_display
*&---------------------------------------------------------------------*
*& 화면 갱신
*&---------------------------------------------------------------------*
FORM refresh_grid_display .

  gs_scroll-row = 'X'.
  gs_scroll-col = 'X'.

  CALL METHOD go_grid_0100->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = gs_scroll.     "현재 그대로 입력한 refresh

ENDFORM.
*&---------------------------------------------------------------------*
*& Form after_user_command
*&---------------------------------------------------------------------*
FORM after_user_command USING pv_ucomm.

  CASE pv_ucomm.
    WHEN '&REFRESH'.
      PERFORM get_data.
* REFRESH DISPLAY
      CALL METHOD go_grid_0100->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'
          is_stable      = gv_stable.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed
*&---------------------------------------------------------------------*
FORM data_changed USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                       pv_onf4 TYPE char1.

  DATA: lt_delta_cells   TYPE lvc_t_modi,
        ls_delta_cells   TYPE lvc_s_modi,
        ls_modified      TYPE char01,
        ls_frontend_only TYPE char01.

  DATA : ls_mod_cells TYPE lvc_s_modi,
         ls_cells     TYPE lvc_s_modi.

  DATA : lv_lgort LIKE t001l-lgort.

  LOOP AT pr_data_changed->mt_mod_cells INTO ls_mod_cells.

    IF ls_mod_cells-value IS NOT INITIAL.

      CLEAR gs_disp.
      READ TABLE gt_disp INTO gs_disp INDEX ls_mod_cells-row_id.
* 탐색도움말에서 선택하지 않고 수기로 입력할 수 있음.
      IF gv_erfmg IS INITIAL.
        gv_erfmg = gs_disp-erfmg.
      ENDIF.

      CASE ls_mod_cells-fieldname.
*- Start 2025.05.12
        WHEN 'BUDAT'.
          REPLACE ALL OCCURRENCES OF '.' IN ls_mod_cells-value WITH ''.
          CONDENSE ls_mod_cells-value NO-GAPS.
          gs_disp-budat  = ls_mod_cells-value.

          CALL METHOD pr_data_changed->modify_cell
            EXPORTING
              i_row_id    = ls_mod_cells-row_id
              i_fieldname = 'BUDAT'
              i_value     = gs_disp-budat.
*- End 2025.05.12
        WHEN 'DEL_REASON'. "삭제 사유 코드

          CLEAR gs_zgtppt1010.
          READ TABLE gt_zgtppt1010 INTO gs_zgtppt1010
                                              WITH KEY fld_02 = ls_mod_cells-value."삭제 사유 내역

          IF gs_zgtppt1010 IS NOT INITIAL.

            gs_disp-del_reason  = ls_mod_cells-value.
            gs_disp-reason_text = gs_zgtppt1010-fld_03.

            CALL METHOD pr_data_changed->modify_cell
              EXPORTING
                i_row_id    = ls_mod_cells-row_id
                i_fieldname = 'DEL_REASON'
                i_value     = gs_disp-del_reason.

            CALL METHOD pr_data_changed->modify_cell
              EXPORTING
                i_row_id    = ls_mod_cells-row_id
                i_fieldname = 'REASON_TEXT'
                i_value     = gs_disp-reason_text.

          ELSE.

            PERFORM data_input_error USING pr_data_changed
                                       ls_mod_cells
                                       'E'
                                       TEXT-e01
                                       ls_mod_cells-fieldname.

          ENDIF.

        WHEN 'DETAILS'. "상세 내역

          gs_disp-details = ls_mod_cells-value.

          CALL METHOD pr_data_changed->modify_cell
            EXPORTING
              i_row_id    = ls_mod_cells-row_id
              i_fieldname = 'DETAILS'
              i_value     = gs_disp-details.

        WHEN 'LGORT'. "저장위치

          CLEAR lv_lgort.
          SELECT SINGLE lgort INTO lv_lgort FROM t001l
                                          WHERE werks EQ gs_disp-werks
                                              AND lgort   EQ ls_mod_cells-value.

          IF lv_lgort IS NOT INITIAL.

            gs_disp-lgort  = lv_lgort.

            CALL METHOD pr_data_changed->modify_cell
              EXPORTING
                i_row_id    = ls_mod_cells-row_id
                i_fieldname = 'LGORT'
                i_value     = gs_disp-lgort.

          ELSE.

            PERFORM data_input_error USING pr_data_changed
                                       ls_mod_cells
                                       'E'
                                       TEXT-e02
                                       ls_mod_cells-fieldname.

          ENDIF.

        WHEN 'BWART'. "배치번호

          gs_disp-bwart = ls_mod_cells-value.

          CALL METHOD pr_data_changed->modify_cell
            EXPORTING
              i_row_id    = ls_mod_cells-row_id
              i_fieldname = 'BWART'
              i_value     = gs_disp-bwart.

        WHEN 'ERFMG'. "투입수량

          REPLACE ALL OCCURRENCES OF ',' IN ls_mod_cells-value WITH ''.
          CONDENSE ls_mod_cells-value NO-GAPS.
          gs_disp-erfmg = ls_mod_cells-value.

          CALL METHOD pr_data_changed->modify_cell
            EXPORTING
              i_row_id    = ls_mod_cells-row_id
              i_fieldname = 'ERFMG'
              i_value     = gs_disp-erfmg.

        WHEN 'BUDAT'. "전기일자

          gs_disp-budat = ls_mod_cells-value.

          CALL METHOD pr_data_changed->modify_cell
            EXPORTING
              i_row_id    = ls_mod_cells-row_id
              i_fieldname = 'BUDAT'
              i_value     = gs_disp-budat.

        WHEN  OTHERS.

      ENDCASE.
* 오류 수량 < 투입 완료 수량 + 투입 수량 이면 메시지 출력
* 실투입 오류의 경우, 에러 팝업으로 출력하고 투입 수량은 원복.
      IF ( gs_disp-gimng < ( gs_disp-enmng + gs_disp-erfmg ) )
       AND gs_disp-gubun = TEXT-009.
** 백로그는 워닝 팝업으로 출력. 투입 수량은 변경된 값 그대로 유지.
*        IF gs_disp-gubun = TEXT-008.
*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*            EXPORTING
*              input  = gs_disp-weblpos
*            IMPORTING
*              output = gs_disp-weblpos.
*          MESSAGE i010 DISPLAY LIKE 'W' WITH gs_disp-weblnr gs_disp-weblpos.
** 실투입 오류의 경우, 에러 팝업으로 출력하고 투입 수량은 원복.
*        ELSEIF gs_disp-gubun = TEXT-009.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = gs_disp-weblpos
          IMPORTING
            output = gs_disp-weblpos.

        gs_disp-erfmg = gv_erfmg.
        CALL METHOD pr_data_changed->modify_cell
          EXPORTING
            i_row_id    = ls_mod_cells-row_id
            i_fieldname = 'ERFMG'
            i_value     = gs_disp-erfmg.
        MESSAGE i010 DISPLAY LIKE 'E' WITH gs_disp-weblnr gs_disp-weblpos.
*      ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_input_error
*&---------------------------------------------------------------------*
FORM data_input_error USING pr_data_changed TYPE REF TO
                                         cl_alv_changed_data_protocol
                                         ps_mod_cells    TYPE lvc_s_modi
                                         pv_msgty
                                         pv_msgv1
                                         pv_fieldname.
* Error Message Display
  CALL METHOD pr_data_changed->add_protocol_entry
    EXPORTING
      i_msgid     = 'ZGTPP00'
      i_msgno     = '003'
      i_msgty     = pv_msgty
      i_msgv1     = pv_msgv1
      i_msgv2     = ''
      i_msgv3     = ''
      i_fieldname = pv_fieldname
      i_row_id    = ps_mod_cells-row_id.

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

  FIELD-SYMBOLS <fs_modi> TYPE lvc_t_modi.
  DATA: ls_modi  TYPE lvc_s_modi,
        lv_value TYPE string.

  CLEAR : gv_erfmg, gs_disp.
  READ TABLE gt_disp INTO gs_disp INDEX ps_row_no-row_id.
  CHECK sy-subrc = 0.

  CASE pv_fieldname.
    WHEN 'DEL_REASON'.

      PERFORM  search_help_for_del_reason
      CHANGING gs_disp-del_reason gs_disp-reason_text.

      IF NOT gs_disp IS INITIAL AND
             pv_display IS INITIAL.

        ASSIGN pr_event_data->m_data->* TO <fs_modi>.
        ls_modi-row_id    = ps_row_no-row_id.
        ls_modi-fieldname = pv_fieldname.
        ls_modi-value     = gs_disp-del_reason.
        APPEND ls_modi TO <fs_modi>.

        MODIFY gt_disp FROM gs_disp INDEX ps_row_no-row_id.

      ENDIF.

    WHEN 'LGORT'.

      PERFORM  search_help_for_lgort
      CHANGING gs_disp-lgort.

      IF NOT gs_disp IS INITIAL AND
             pv_display IS INITIAL.

        ASSIGN pr_event_data->m_data->* TO <fs_modi>.
        ls_modi-row_id    = ps_row_no-row_id.
        ls_modi-fieldname = pv_fieldname.
        ls_modi-value     = gs_disp-lgort.
        APPEND ls_modi TO <fs_modi>.

        MODIFY gt_disp FROM gs_disp INDEX ps_row_no-row_id.

      ENDIF.

    WHEN 'ERFMG' OR 'CHARG' OR 'TAGNR'.
* 오류 메시지 떴을 때 수량 원복을 위해 변경 전 투입 수량 담아둠
      gv_erfmg = gs_disp-erfmg.
      PERFORM search_help_for_erfmg.

      IF NOT gs_disp IS INITIAL AND
             pv_display IS INITIAL.

        IF gs_disp-erfmg IS NOT INITIAL.

          ASSIGN pr_event_data->m_data->* TO <fs_modi>.
          ls_modi-row_id    = ps_row_no-row_id.
          ls_modi-fieldname = 'ERFMG'.
          ls_modi-value     = gs_disp-erfmg.
          APPEND ls_modi TO <fs_modi>.

        ENDIF.

        IF gs_disp-lgort IS NOT INITIAL.

          ASSIGN pr_event_data->m_data->* TO <fs_modi>.
          ls_modi-row_id    = ps_row_no-row_id.
          ls_modi-fieldname = 'LGORT'.
          ls_modi-value     = gs_disp-lgort.
          APPEND ls_modi TO <fs_modi>.

        ENDIF.

        IF gs_disp-charg IS NOT INITIAL.

          ASSIGN pr_event_data->m_data->* TO <fs_modi>.
          ls_modi-row_id    = ps_row_no-row_id.
          ls_modi-fieldname = 'CHARG'.
          ls_modi-value     = gs_disp-charg.
          APPEND ls_modi TO <fs_modi>.

        ENDIF.

        IF gs_disp-tagnr IS NOT INITIAL.

          ASSIGN pr_event_data->m_data->* TO <fs_modi>.
          ls_modi-row_id    = ps_row_no-row_id.
          ls_modi-fieldname = 'TAGNR'.
          ls_modi-value     = gs_disp-tagnr.
          APPEND ls_modi TO <fs_modi>.

        ENDIF.

        MODIFY gt_disp FROM gs_disp INDEX ps_row_no-row_id.

      ENDIF.

  ENDCASE.

  pr_event_data->m_event_handled = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form search_help_for_del_reason
*&---------------------------------------------------------------------*
FORM search_help_for_del_reason CHANGING pv_del_reason pv_reason_text.

  DATA: lv_tabix     LIKE sy-tabix.

  CLEAR : gt_field, gt_field[], gs_selectfield, gs_select_value.

  gt_field-tabname  = 'ZGTPPT1010'.
  gt_field-fieldname = 'FLD_02'. "삭제 사유 코드
  gt_field-selectflag = 'X'.
  APPEND gt_field. CLEAR gt_field.

*& 아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  gt_field-tabname     = 'ZGTPPT1010'.
  gt_field-fieldname   = 'FLD_03'. "삭제 사유 코드 내역
  gt_field-selectflag  = ' '.
  APPEND gt_field. CLEAR gt_field.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      titel                        = TEXT-t05
      selectfield                  = gs_selectfield
    IMPORTING
      ind                          = lv_tabix
      select_value                 = gs_select_value
    TABLES
      fields                       = gt_field
      full_table                   = gt_1010
    EXCEPTIONS
      full_table_empty             = 1
      no_tablestructure_given      = 2
      no_tablefields_in_dictionary = 3
      more_then_one_selectfield    = 4
      no_selectfield               = 5
      OTHERS                       = 6.

  CHECK NOT lv_tabix IS INITIAL.
  READ TABLE gt_1010 INTO gs_1010 INDEX lv_tabix.
  IF sy-subrc = 0.
    pv_del_reason  = gs_1010-fld_02.
    pv_reason_text = gs_1010-fld_03.
  ENDIF.

ENDFORM.
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
*& Form event_handler_register
*&---------------------------------------------------------------------*
FORM event_handler_register USING po_grid TYPE REF TO cl_gui_alv_grid.

  DATA: lt_f4 TYPE lvc_t_f4 WITH HEADER LINE.

  CLEAR lt_f4.
  lt_f4-fieldname  = 'DEL_REASON'.
  lt_f4-register   = 'X'.
  lt_f4-getbefore  = 'X'.
  lt_f4-chngeafter = space.
  INSERT TABLE lt_f4.

  CLEAR lt_f4.
  lt_f4-fieldname  = 'LGORT'.
  lt_f4-register   = 'X'.
  lt_f4-getbefore  = 'X'.
  lt_f4-chngeafter = space.
  INSERT TABLE lt_f4.

  CLEAR lt_f4.
  lt_f4-fieldname  = 'CHARG'.
  lt_f4-register   = 'X'.
  lt_f4-getbefore  = 'X'.
  lt_f4-chngeafter = space.
  INSERT TABLE lt_f4.

  CLEAR lt_f4.
  lt_f4-fieldname  = 'TAGNR'.
  lt_f4-register   = 'X'.
  lt_f4-getbefore  = 'X'.
  lt_f4-chngeafter = space.
  INSERT TABLE lt_f4.

  CLEAR lt_f4.
  lt_f4-fieldname  = 'ERFMG'.
  lt_f4-register   = 'X'.
  lt_f4-getbefore  = 'X'.
  lt_f4-chngeafter = space.
  INSERT TABLE lt_f4.
*& ONF4 이벤트 등록
  CALL METHOD po_grid->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4[].
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
*& Form search_help_for_lgort
*&---------------------------------------------------------------------*
FORM search_help_for_lgort CHANGING pv_lgort.

  DATA : lv_tabix     LIKE sy-tabix.

  CLEAR : gt_field, gt_field[], gs_selectfield, gs_select_value.
*& 아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  gt_field-tabname  = 'T001L'.
  gt_field-fieldname = 'LGORT'. "저장위치
  gt_field-selectflag = 'X'.
  APPEND gt_field. CLEAR gt_field.

  gt_field-tabname     = 'T001L'.
  gt_field-fieldname   = 'LGOBE'. "저장위치 내역
  gt_field-selectflag  = ' '.
  APPEND gt_field. CLEAR gt_field.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      titel                        = TEXT-t05
      selectfield                  = gs_selectfield
    IMPORTING
      ind                          = lv_tabix
      select_value                 = gs_select_value
    TABLES
      fields                       = gt_field
      full_table                   = gt_t001l
    EXCEPTIONS
      full_table_empty             = 1
      no_tablestructure_given      = 2
      no_tablefields_in_dictionary = 3
      more_then_one_selectfield    = 4
      no_selectfield               = 5
      OTHERS                       = 6.

  CHECK NOT lv_tabix IS INITIAL.
  pv_lgort = gs_select_value.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0100
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

  CLEAR gs_layout_0100.
  gs_layout_0100-cwidth_opt = abap_true.
  gs_layout_0100-no_rowins = abap_true.
*  GS_LAYOUT_0100-NO_ROWMOVE = ABAP_TRUE.
  gs_layout_0100-smalltitle = abap_true.
  gs_layout_0100-sel_mode   = 'D'.
  gs_layout_0100-stylefname = 'CELLTAB'.
  gs_layout_0100-ctab_fname   = 'CELLCOL'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0100
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0100 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR3000TOP'
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
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "상태
      WHEN 'MESSAGE'.
        <ls_fcat>-coltext = TEXT-f02.
        <ls_fcat>-col_pos = '2'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'L'. "오류 메시지
      WHEN 'GUBUN'.
        <ls_fcat>-coltext = TEXT-f41.
        <ls_fcat>-col_pos = '3'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "오류 유형
      WHEN 'WERKS'.
        <ls_fcat>-coltext = TEXT-f03.
        <ls_fcat>-col_pos = '4'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "플랜트
      WHEN 'NAME1'.
        <ls_fcat>-coltext = TEXT-f04.
        <ls_fcat>-col_pos = '5'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'L'. "내역
      WHEN 'DISPO'.
        <ls_fcat>-coltext = TEXT-f05.
        <ls_fcat>-col_pos = '6'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "MRP관리자
      WHEN 'DSNAM'.
        <ls_fcat>-coltext = TEXT-f06.
        <ls_fcat>-col_pos = '7'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "내역
      WHEN 'WEBLNR'.
        <ls_fcat>-coltext = TEXT-f07.
        <ls_fcat>-col_pos = '8'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "백로그 문서 번호
      WHEN 'WEBLPOS'.
        <ls_fcat>-coltext = TEXT-f08.
        <ls_fcat>-col_pos = '9'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "백로그 문서 아이템
      WHEN 'DEL_REASON'.
        <ls_fcat>-coltext    = TEXT-f09.
        <ls_fcat>-col_pos    = '10'.
        <ls_fcat>-no_out     = ' '.
        <ls_fcat>-just       = 'C'.
        <ls_fcat>-edit       = 'X'.
        <ls_fcat>-f4availabl = 'X'."삭제 사유 코드
      WHEN 'REASON_TEXT'.
        <ls_fcat>-coltext = TEXT-f10.
        <ls_fcat>-col_pos = '11'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'L'. "삭제 사유 내역
      WHEN 'DETAILS'.
        <ls_fcat>-coltext   = TEXT-f11.
        <ls_fcat>-col_pos   = '12'.
        <ls_fcat>-no_out    = ' '.
        <ls_fcat>-just      = 'L'.
        <ls_fcat>-edit      = 'X'.
        <ls_fcat>-lowercase = 'X'. "상세 내역
      WHEN 'ERSDA'.
        <ls_fcat>-coltext = TEXT-f12.
        <ls_fcat>-col_pos = '13'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "오류일자
      WHEN 'ERZET'.
        <ls_fcat>-coltext = TEXT-f13.
        <ls_fcat>-col_pos = '14'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "오류시간
      WHEN 'ERNAM'.
        <ls_fcat>-coltext = TEXT-f14.
        <ls_fcat>-col_pos = '15'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "생성자
      WHEN 'ENAME'.
        <ls_fcat>-coltext = TEXT-f15.
        <ls_fcat>-col_pos = '16'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'L'. "성명
      WHEN 'LAEDA'.
        <ls_fcat>-coltext = TEXT-f16.
        <ls_fcat>-col_pos = '17'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "최종변경일자
      WHEN 'AENAM'.
        <ls_fcat>-coltext = TEXT-f17.
        <ls_fcat>-col_pos = '18'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "변경자
      WHEN 'CNAME'.
        <ls_fcat>-coltext = TEXT-f18.
        <ls_fcat>-col_pos = '19'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'L'. "성명
      WHEN 'MATNR'.
        <ls_fcat>-coltext = TEXT-f19.
        <ls_fcat>-col_pos = '20'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'.
        <ls_fcat>-hotspot = 'X'. "자재코드
      WHEN 'MAKTX'.
        <ls_fcat>-coltext = TEXT-f20.
        <ls_fcat>-col_pos = '21'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'L'. "자재내역
      WHEN 'MATKL'.
        <ls_fcat>-coltext = TEXT-f21.
        <ls_fcat>-col_pos = '22'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "자재그룹
      WHEN 'WGBEZ60'.
        <ls_fcat>-coltext = TEXT-f22.
        <ls_fcat>-col_pos = '23'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'L'. "자재그룹내역
      WHEN 'LGORT'.
        <ls_fcat>-coltext    = TEXT-f23.
        <ls_fcat>-col_pos    = '24'.
        <ls_fcat>-no_out     = ' '.
        <ls_fcat>-just       = 'C'.
        <ls_fcat>-edit       = 'X'.
        <ls_fcat>-f4availabl = 'X'."저장위치
      WHEN 'CHARG'.
        <ls_fcat>-coltext    = TEXT-f24.
        <ls_fcat>-col_pos    = '25'.
        <ls_fcat>-no_out     = ' '.
        <ls_fcat>-just       = 'C'.
        <ls_fcat>-edit       = 'X'.
        <ls_fcat>-f4availabl = 'X'. "배치번호
      WHEN 'TAGNR'.
        <ls_fcat>-coltext    = TEXT-f38.
        <ls_fcat>-col_pos    = '26'.
        <ls_fcat>-no_out     = ' '.
        <ls_fcat>-just       = 'C'.
        <ls_fcat>-edit       = 'X'.
        <ls_fcat>-f4availabl = 'X'. "꼬리표 번호
      WHEN 'BWART'.
        <ls_fcat>-coltext = TEXT-f25.
        <ls_fcat>-col_pos = '27'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "이동유형
      WHEN 'GIMNG'.
        <ls_fcat>-coltext    = TEXT-f39.
        <ls_fcat>-col_pos    = '28'.
        <ls_fcat>-no_out     = ' '.
        <ls_fcat>-just       = 'R'.
        <ls_fcat>-qfieldname = 'ERFME'.
        <ls_fcat>-ref_field  = 'ERFMG'.
        <ls_fcat>-ref_table  = 'AFFW'. "오류 수량
      WHEN 'ENMNG'.
        <ls_fcat>-coltext    = TEXT-f40.
        <ls_fcat>-col_pos    = '29'.
        <ls_fcat>-no_out     = ' '.
        <ls_fcat>-just       = 'R'.
        <ls_fcat>-qfieldname = 'ERFME'.
        <ls_fcat>-ref_field  = 'ERFMG'.
        <ls_fcat>-ref_table  = 'AFFW'. "투입 완료 수량
      WHEN 'ERFMG'.
        <ls_fcat>-coltext    = TEXT-f26.
        <ls_fcat>-col_pos    = '30'.
        <ls_fcat>-no_out     = ' '.
        <ls_fcat>-just       = 'R'.
        <ls_fcat>-edit       = 'X'.
        <ls_fcat>-qfieldname = 'ERFME'.
        <ls_fcat>-ref_field  = 'ERFMG'.
        <ls_fcat>-ref_table  = 'AFFW'.
        <ls_fcat>-f4availabl = 'X'. "투입수량
      WHEN 'ERFME'.
        <ls_fcat>-coltext = TEXT-f27.
        <ls_fcat>-col_pos = '31'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "투입단위
      WHEN 'BUDAT'.
        <ls_fcat>-coltext    = TEXT-f37.
        <ls_fcat>-col_pos    = '32'.
        <ls_fcat>-no_out     = ' '.
        <ls_fcat>-just       = 'C'.
        <ls_fcat>-edit       = 'X'.
        <ls_fcat>-f4availabl = 'X'.
        <ls_fcat>-ref_field  = 'DATUM'.
        <ls_fcat>-ref_table  = 'SYST'. "전기일자
      WHEN 'AUFNR'.
        <ls_fcat>-coltext = TEXT-f28.
        <ls_fcat>-col_pos = '33'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'.
        <ls_fcat>-hotspot = 'X'. "생산오더번호
      WHEN 'PMATNR'.
        <ls_fcat>-coltext = TEXT-f29.
        <ls_fcat>-col_pos = '34'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'.
        <ls_fcat>-hotspot = 'X'. "품목코드
      WHEN 'MAKTX2'.
        <ls_fcat>-coltext = TEXT-f30.
        <ls_fcat>-col_pos = '35'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'L'. "품목명
      WHEN 'RSNUM'.
        <ls_fcat>-coltext = TEXT-f31.
        <ls_fcat>-col_pos = '36'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "예약번호
      WHEN 'RSPOS'.
        <ls_fcat>-coltext = TEXT-f32.
        <ls_fcat>-col_pos = '37'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "예약아이템
      WHEN 'RUECK'.
        <ls_fcat>-coltext = TEXT-f33.
        <ls_fcat>-col_pos = '38'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "확정번호
      WHEN 'RMZHL'.
        <ls_fcat>-coltext = TEXT-f34.
        <ls_fcat>-col_pos = '39'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "확정카운터
      WHEN 'MSGID'.
        <ls_fcat>-coltext = TEXT-f35.
        <ls_fcat>-col_pos = '40'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "메시지ID
      WHEN 'MSGNO'.
        <ls_fcat>-coltext = TEXT-f36.
        <ls_fcat>-col_pos = '41'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'. "메시지번호
      WHEN 'STPRS'.
        <ls_fcat>-coltext    = TEXT-f65.  "표준가
        <ls_fcat>-col_pos    = '42'.
        <ls_fcat>-no_out     = ' '.
        <ls_fcat>-just       = 'R'.
        <ls_fcat>-cfieldname = 'WAERS'.
      WHEN 'MONEY'.
        <ls_fcat>-coltext    = TEXT-f66.  "백로그 금액
        <ls_fcat>-col_pos    = '43'.
        <ls_fcat>-no_out     = ' '.
        <ls_fcat>-just       = 'R'.
        <ls_fcat>-cfieldname = 'WAERS'.
      WHEN 'WAERS'.
        <ls_fcat>-coltext = TEXT-f67.  "통화키
        <ls_fcat>-col_pos = '44'.
        <ls_fcat>-no_out  = ' '.
        <ls_fcat>-just    = 'C'.
*- Start 2025.06.10
      WHEN 'BSTNK'.
        <ls_fcat>-coltext = TEXT-f68.  "제조지시번호
        <ls_fcat>-col_pos = '45'.
        IF p_werks = '1306'.
          <ls_fcat>-no_out  = ' '.
        ELSE.
          <ls_fcat>-no_out  = 'X'.
        ENDIF.
        <ls_fcat>-just    = 'C'.
*- End 2025.06.10
      WHEN OTHERS.
        <ls_fcat>-no_out = abap_true.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_cell_attribute_grid_0100
*&---------------------------------------------------------------------*
FORM set_cell_attribute_grid_0100 .

* 셀 컬러부여
  DATA : lt_coltab TYPE lvc_t_scol.
  DATA : ls_coltab TYPE lvc_s_scol.

  DATA : lt_celltab TYPE lvc_t_styl.
  DATA : ls_celltab TYPE lvc_s_styl.

  LOOP AT gt_disp ASSIGNING FIELD-SYMBOL(<ls_disp>).

    REFRESH lt_coltab.
    REFRESH lt_celltab.

    LOOP AT gt_fieldcat_0100 INTO DATA(ls_fieldcat).
      CASE ls_fieldcat-fieldname.
        WHEN 'CHARG'.
          CASE <ls_disp>-xchar.
            WHEN 'X'.
              CLEAR ls_celltab.
              ls_celltab-fieldname = 'CHARG'.
              ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
              INSERT ls_celltab INTO TABLE lt_celltab.
              CLEAR ls_celltab.
              ls_celltab-fieldname = 'TAGNR'.
              ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
              INSERT ls_celltab INTO TABLE lt_celltab.
            WHEN OTHERS.
              CLEAR ls_celltab.
              ls_celltab-fieldname = 'CHARG'.
              ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
              INSERT ls_celltab INTO TABLE lt_celltab.
              CLEAR ls_celltab.
              ls_celltab-fieldname = 'TAGNR'.
              ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
              INSERT ls_celltab INTO TABLE lt_celltab.
          ENDCASE.

        WHEN 'DEL_REASON' OR 'REASON_TEXT' OR 'DETAILS'.
          IF <ls_disp>-gubun = TEXT-008.
            CLEAR ls_celltab.
            ls_celltab-fieldname = ls_fieldcat-fieldname.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
            INSERT ls_celltab INTO TABLE lt_celltab.
          ELSE.
            CLEAR ls_celltab.
            ls_celltab-fieldname = ls_fieldcat-fieldname.
            ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
            INSERT ls_celltab INTO TABLE lt_celltab.
          ENDIF.

        WHEN 'GUBUN'.
          CLEAR ls_coltab.
          ls_coltab-fname = ls_fieldcat-fieldname.
          ls_coltab-color-col = '5'.
          ls_coltab-color-int = '1'.
          ls_coltab-nokeycol  = ' '.
          INSERT ls_coltab INTO TABLE lt_coltab.

        WHEN 'WEBLNR' OR 'WEBLPOS'.
          CLEAR ls_coltab.
          ls_coltab-fname = ls_fieldcat-fieldname.
          ls_coltab-color-col = '4'.
          ls_coltab-color-int = '1'.
          ls_coltab-nokeycol  = ' '.
          INSERT ls_coltab INTO TABLE lt_coltab.

      ENDCASE.
    ENDLOOP.

    <ls_disp>-cellcol = lt_coltab.
    <ls_disp>-celltab = lt_celltab.

  ENDLOOP.

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
                cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
*                cl_gui_alv_grid=>mc_fc_refresh.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0100_DISPLAY
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
*& Form search_help_for_erfmg
*&---------------------------------------------------------------------*
FORM search_help_for_erfmg .

  DATA : lv_xchpf LIKE marc-xchpf.
  DATA : BEGIN OF ls_tagnr,
           werks  LIKE zppt0001-werks,
           matnr  LIKE zppt0001-matnr,
           lgort  LIKE zppt0001-lgort,
           charg  LIKE zppt0001-charg,
           tagnr  LIKE zppt0001-tagnr,
           remain TYPE zgteremain,
           clabs  TYPE zgteclabs,
           meins  TYPE zppt0001-meins,
         END OF ls_tagnr.
  DATA : lt_tagnr LIKE TABLE OF ls_tagnr.
  DATA : lv_tabix LIKE sy-tabix.
  DATA : lv_matnr LIKE mara-matnr.

  REFRESH : gt_rtntab, gt_dselc.
  CLEAR : gt_rtntab, gt_dselc, gs_marc2, lv_xchpf.
* 자재마스터의 배치 관리 지시자 추출
  READ TABLE gt_marc2 INTO gs_marc2
                                     WITH KEY werks = gs_disp-werks
                                                    matnr = gs_disp-matnr.
  IF gs_marc2 IS NOT INITIAL.
    lv_xchpf = gs_marc2-xchpf.
  ENDIF.
* 배치미관리 대상(XCHPF = ' ')이면 MARD를 추출하여 F4 구성
  IF lv_xchpf IS INITIAL.

    IF gs_disp-lgort IS NOT INITIAL.

      SELECT a~matnr, a~werks, a~lgort, a~labst, b~meins
          INTO TABLE @DATA(lt_mard)
          FROM mard AS a INNER JOIN mara AS b
              ON a~matnr EQ b~matnr
          WHERE a~werks EQ @gs_disp-werks
               AND a~matnr EQ @gs_disp-matnr
               AND a~lgort EQ @gs_disp-lgort
               AND a~labst > 0.

    ELSE.

      SELECT a~matnr, a~werks, a~lgort, a~labst, b~meins
          INTO CORRESPONDING FIELDS OF TABLE @lt_mard
          FROM mard AS a INNER JOIN mara AS b
              ON a~matnr EQ b~matnr
          WHERE a~werks EQ @gs_disp-werks
               AND a~matnr EQ @gs_disp-matnr
               AND a~labst > 0.

    ENDIF.
* 만약, 투입 단위와 재고 단위가 다를 경우 투입 단위에 맞춰 환산
    READ TABLE lt_mard INTO DATA(ls_mard) INDEX 1.
    IF ls_mard-meins <> gs_disp-erfme.
      LOOP AT lt_mard INTO ls_mard.

        lv_tabix = sy-tabix.

        CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
          EXPORTING
            i_matnr  = gs_disp-matnr
            i_in_me  = ls_mard-meins
            i_out_me = gs_disp-erfme
            i_menge  = ls_mard-labst
          IMPORTING
            e_menge  = ls_mard-labst.
        ls_mard-meins = gs_disp-erfme.

        MODIFY lt_mard FROM ls_mard INDEX lv_tabix.
        CLEAR ls_mard.

      ENDLOOP.

    ENDIF.

    IF lt_mard[] IS INITIAL.

      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          input  = gs_disp-matnr
        IMPORTING
          output = lv_matnr.

      MESSAGE s012 DISPLAY LIKE 'E' WITH gs_disp-werks lv_matnr gs_disp-lgort.

    ELSE.

      gt_dselc-fldname = 'F0003'.
      gt_dselc-dyfldname = 'LGORT'.
      APPEND gt_dselc.

      gt_dselc-fldname = 'F0004'.
      gt_dselc-dyfldname = 'LABST'.
      APPEND gt_dselc.

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield        = 'LABST'
          dynpprog        = sy-cprog
          dynpnr          = sy-dynnr
          window_title    = TEXT-030 "투입 수량 선택
          value_org       = 'S'
        TABLES
          value_tab       = lt_mard
          return_tab      = gt_rtntab
          dynpfld_mapping = gt_dselc
        EXCEPTIONS
          parameter_error = 1
          no_values_found = 2
          OTHERS          = 3.
* 저장 위치
      CLEAR gt_rtntab.
      READ TABLE gt_rtntab WITH KEY retfield = 'LGORT'.
      IF sy-subrc = 0.
        gs_disp-lgort = gt_rtntab-fieldval.
      ENDIF.
* 투입 수량
      CLEAR gt_rtntab.
      READ TABLE gt_rtntab WITH KEY retfield = 'LABST'.
      IF sy-subrc = 0.
        REPLACE ALL OCCURRENCES OF ',' IN gt_rtntab-fieldval WITH ''.
        CONDENSE gt_rtntab-fieldval NO-GAPS.
        gs_disp-erfmg = gt_rtntab-fieldval.
      ENDIF.

    ENDIF.
* 배치관리 대상(XCHPF = 'X')이면 MCHB -> ZPPT0001을 추출
  ELSE.

    IF gs_disp-lgort IS NOT INITIAL.

      SELECT a~werks, a~matnr, a~lgort, a~charg, a~clabs, b~meins
          INTO TABLE @DATA(lt_mchb)
          FROM mchb AS a INNER JOIN mara AS b
              ON a~matnr EQ b~matnr
          WHERE a~werks EQ @gs_disp-werks
               AND a~matnr EQ @gs_disp-matnr
               AND a~lgort   EQ @gs_disp-lgort
               AND a~clabs > 0.

    ELSE.

      SELECT a~werks, a~matnr, a~lgort, a~charg, a~clabs, b~meins
          INTO CORRESPONDING FIELDS OF TABLE @lt_mchb
          FROM mchb AS a INNER JOIN mara AS b
              ON a~matnr EQ b~matnr
          WHERE a~werks EQ @gs_disp-werks
               AND a~matnr EQ @gs_disp-matnr
               AND a~clabs > 0.

    ENDIF.

    IF lt_mchb[] IS NOT INITIAL.

      SELECT werks, matnr, lgort, charg, tagnr, remain, meins
       INTO CORRESPONDING FIELDS OF TABLE @lt_tagnr
       FROM zppt0001
       FOR ALL ENTRIES IN @lt_mchb
       WHERE werks     EQ @lt_mchb-werks
            AND matnr     EQ @lt_mchb-matnr
            AND lgort       EQ @lt_mchb-lgort
            AND charg     EQ @lt_mchb-charg
            AND scrapyn EQ @space " 스크랩 처리상태가 아니고
            AND shift        EQ @space " 교대조 꼬리표가 아닌 것
            AND inspflg    EQ 'OK'
            AND grflg       EQ 'Y'          " 입고된 것 만
            AND giflg        EQ 'N'
            AND remain  > 0.
* 배치 재고 중 꼬리표 정보가 없는 건도 탐색 도움말 리스트에 추가
      LOOP AT lt_mchb INTO DATA(ls_mchb).

        READ TABLE lt_tagnr INTO ls_tagnr
                                         WITH KEY werks = ls_mchb-werks
                                                         matnr  = ls_mchb-matnr
                                                         lgort   = ls_mchb-lgort
                                                         charg = ls_mchb-charg.

        IF sy-subrc <> 0.
          ls_tagnr-werks = ls_mchb-werks.
          ls_tagnr-matnr = ls_mchb-matnr.
          ls_tagnr-lgort = ls_mchb-lgort.
          ls_tagnr-charg = ls_mchb-charg.
          ls_tagnr-clabs = ls_mchb-clabs.
          ls_tagnr-meins   = ls_mchb-meins.
          APPEND ls_tagnr TO lt_tagnr.
          CLEAR ls_tagnr.
        ELSE.
          ls_tagnr-clabs = ls_mchb-clabs.
          MODIFY lt_tagnr FROM ls_tagnr INDEX sy-tabix.
          CLEAR ls_tagnr.
        ENDIF.

      ENDLOOP.
* 만약, 투입 단위와 재고 단위가 다를 경우 투입 단위에 맞춰 환산
      CLEAR ls_tagnr.
      READ TABLE lt_tagnr INTO ls_tagnr INDEX 1.
      IF ls_tagnr-meins <> gs_disp-erfme.

        LOOP AT lt_tagnr INTO ls_tagnr.

          lv_tabix = sy-tabix.

          IF ls_tagnr-remain NE 0.
            CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
              EXPORTING
                i_matnr  = gs_disp-matnr
                i_in_me  = ls_tagnr-meins
                i_out_me = gs_disp-erfme
                i_menge  = ls_tagnr-remain
              IMPORTING
                e_menge  = ls_tagnr-remain.
          ENDIF.
          IF ls_tagnr-clabs NE 0.
            CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
              EXPORTING
                i_matnr  = gs_disp-matnr
                i_in_me  = ls_tagnr-meins
                i_out_me = gs_disp-erfme
                i_menge  = ls_tagnr-clabs
              IMPORTING
                e_menge  = ls_tagnr-clabs.
          ENDIF.
          ls_tagnr-meins = gs_disp-erfme.

          MODIFY lt_tagnr FROM ls_tagnr INDEX lv_tabix.
          CLEAR ls_tagnr.

        ENDLOOP.

      ENDIF.

      gt_dselc-fldname = 'F0003'.
      gt_dselc-dyfldname = 'LGORT'.
      APPEND gt_dselc.

      gt_dselc-fldname = 'F0004'.
      gt_dselc-dyfldname = 'CHARG'.
      APPEND gt_dselc.

      gt_dselc-fldname = 'F0005'.
      gt_dselc-dyfldname = 'TAGNR'.
      APPEND gt_dselc.

      gt_dselc-fldname = 'F0007'.
      gt_dselc-dyfldname = 'CLABS'.
      APPEND gt_dselc.

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield        = 'REMAIN'
          dynpprog        = sy-cprog
          dynpnr          = sy-dynnr
          window_title    = TEXT-030 "투입 수량 선택
          value_org       = 'S'
        TABLES
          value_tab       = lt_tagnr
          return_tab      = gt_rtntab
          dynpfld_mapping = gt_dselc
        EXCEPTIONS
          parameter_error = 1
          no_values_found = 2
          OTHERS          = 3.
* 저장 위치
      CLEAR gt_rtntab.
      READ TABLE gt_rtntab WITH KEY retfield = 'LGORT'.
      IF sy-subrc = 0.
        gs_disp-lgort = gt_rtntab-fieldval.
      ENDIF.
* 배치 번호
      CLEAR gt_rtntab.
      READ TABLE gt_rtntab WITH KEY retfield = 'CHARG'.
      IF sy-subrc = 0.
        gs_disp-charg = gt_rtntab-fieldval.
      ENDIF.
* 꼬리표 번호
      CLEAR gt_rtntab.
      READ TABLE gt_rtntab WITH KEY retfield = 'TAGNR'.
      IF sy-subrc = 0.
        gs_disp-tagnr = gt_rtntab-fieldval.
      ENDIF.
* 재고량
      CLEAR gt_rtntab.
      READ TABLE gt_rtntab WITH KEY retfield = 'CLABS'.
      IF sy-subrc = 0.
        REPLACE ALL OCCURRENCES OF ',' IN gt_rtntab-fieldval WITH ''.
        CONDENSE gt_rtntab-fieldval NO-GAPS.
        gs_disp-erfmg = gt_rtntab-fieldval.
      ENDIF.

    ELSE.

      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          input  = gs_disp-matnr
        IMPORTING
          output = lv_matnr.

      MESSAGE s012 DISPLAY LIKE 'E' WITH gs_disp-werks lv_matnr gs_disp-lgort.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0102
*&---------------------------------------------------------------------*
FORM set_object_grid_0102 .

  CREATE OBJECT go_contain_0102
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

  CREATE OBJECT go_grid_0102
    EXPORTING
      i_parent      = go_contain_0102
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_handler_register_0102
*&---------------------------------------------------------------------*
FORM event_handler_register_0102 USING po_grid TYPE REF TO cl_gui_alv_grid.
*& Edit  이벤트 등록
* IF MC_EVT_MODIFY  -> 바로 수정됨.
  CALL METHOD po_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  IF po_grid NE go_grid_0102.
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
    SET HANDLER go_event_handler->handle_double_click
            FOR po_grid.
    SET HANDLER go_event_handler->handle_after_user_command
            FOR po_grid.
    SET HANDLER go_event_handler->handle_button_click
            FOR po_grid.
    SET HANDLER go_event_handler->handle_onf4
            FOR po_grid.

    SET HANDLER go_event_handler->handle_top_of_page
            FOR po_grid.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0102
*&---------------------------------------------------------------------*
FORM set_layout_grid_0102 .

  CLEAR gs_layout_0102.
  gs_layout_0102-cwidth_opt = abap_true.
  gs_layout_0102-no_rowins = abap_true.
  gs_layout_0102-sel_mode   = 'A'.
  gs_layout_0102-smalltitle = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0102
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0102 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR3000TOP'
      i_internal_tabname     = 'GS_RESULT'
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
      et_fieldcat_lvc = gt_fieldcat_0102[]
    TABLES
      it_data         = gt_result
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT gt_fieldcat_0102 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE   <ls_fcat>-fieldname.
      WHEN 'ICON'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f42. "재처리 상태
        <ls_fcat>-just = 'C'.
      WHEN 'MESSAGE'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f53. "처리 결과
        <ls_fcat>-just = 'L'.
*      WHEN 'ICON2'.
*        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f43. "배치 업데이트 상태
*        <ls_fcat>-just = 'C'.
      WHEN 'GUBUN'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f44. "오류 유형
        <ls_fcat>-just = 'C'.
      WHEN 'WEBLNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f45. "백로그 번호
        <ls_fcat>-just = 'C'.
      WHEN 'WEBLPOS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f46. "백로그 아이템
        <ls_fcat>-just = 'C'.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f47. "자재코드
        <ls_fcat>-just = 'C'.
      WHEN 'MAKTX'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f48. "자재내역
        <ls_fcat>-just = 'L'.
      WHEN 'WERKS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f49. "플랜트
        <ls_fcat>-just = 'C'.
      WHEN 'LGORT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f50. "저장위치
        <ls_fcat>-just = 'C'.
      WHEN 'CHARG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f51. "배치번호
        <ls_fcat>-just = 'C'.
      WHEN 'ERFMG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f52. "수량
        <ls_fcat>-just = 'R'.
      WHEN 'ERFME'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f54. "단위
        <ls_fcat>-just = 'C'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_of_toolbar_grid_0102
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0102 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0102
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
*& Form call_grid_0102_display
*&---------------------------------------------------------------------*
FORM call_grid_0102_display .

  CALL METHOD go_grid_0102->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0102
      it_toolbar_excluding = gt_exclude_0102
    CHANGING
      it_outtab            = gt_result
      it_fieldcatalog      = gt_fieldcat_0102.
* 인풋이벤트 추가
  CALL METHOD go_grid_0102->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD go_grid_0102->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form top_of_page
*&---------------------------------------------------------------------*
FORM top_of_page USING    p_title
                           p_linsz.

  DATA: lv_len LIKE    sy-linsz,
        lv_col LIKE    sy-linsz,
        lv_txt LIKE    sy-prtxt.

*& 제목 출력...
  lv_len = strlen( p_title ).
  lv_col = ( p_linsz - lv_len ) / 2.

  PRINT-CONTROL FUNCTION 'SABLD'.
  PRINT-CONTROL FUNCTION 'SAULN'.
  WRITE AT /lv_col(lv_len) p_title.
  PRINT-CONTROL FUNCTION 'SAOFF'.

*& 출력일시 출력...
  WRITE: TEXT-031            TO lv_txt(10),
          sy-datum+0(4)      TO lv_txt+11(4),
         '/'                 TO lv_txt+15(1),
          sy-datum+4(2)      TO lv_txt+16(2),
         '/'                 TO lv_txt+18(1),
          sy-datum+6(2)      TO lv_txt+19(2),
          sy-uzeit+0(2)      TO lv_txt+22(2),
         ':'                 TO lv_txt+24(1),
          sy-uzeit+2(2)      TO lv_txt+25(2),
         ':'                 TO lv_txt+27(1),
          sy-uzeit+4(2)      TO lv_txt+28(2).

  lv_len = strlen( lv_txt ).
  lv_col = p_linsz - lv_len - 2.
  WRITE AT /lv_col(lv_len) lv_txt.

*& 페이지번호 출력...
  CLEAR lv_txt.
  WRITE: TEXT-032            TO lv_txt(10),
          sy-pagno           TO lv_txt+11(5),
         '/'                 TO lv_txt+17(1),
         '*****'             TO lv_txt+19(5).

  WRITE AT /lv_col(lv_len) lv_txt.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0302
*&---------------------------------------------------------------------*
FORM set_object_grid_0302 .

  CREATE OBJECT go_contain_0302
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

  CREATE OBJECT go_grid_0302
    EXPORTING
      i_parent      = go_contain_0302
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_handler_register_0302
*&---------------------------------------------------------------------*
FORM event_handler_register_0302 USING po_grid TYPE REF TO cl_gui_alv_grid.
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

  IF po_grid NE go_grid_0302.

    SET HANDLER go_event_handler->handle_data_changed
            FOR po_grid.
    SET HANDLER go_event_handler->handle_data_changed_finished
            FOR po_grid.
    SET HANDLER go_event_handler->handle_double_click
            FOR po_grid.
    SET HANDLER go_event_handler->handle_after_user_command
            FOR po_grid.
    SET HANDLER go_event_handler->handle_button_click
            FOR po_grid.
    SET HANDLER go_event_handler->handle_onf4
            FOR po_grid.

    SET HANDLER go_event_handler->handle_top_of_page
            FOR po_grid.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0302
*&---------------------------------------------------------------------*
FORM set_layout_grid_0302 .

  CLEAR gs_layout_0302.
  gs_layout_0302-cwidth_opt = abap_true.
  gs_layout_0302-no_rowins = abap_true.
  gs_layout_0302-sel_mode   = 'A'.
  gs_layout_0302-smalltitle = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0302
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0302 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR3000TOP'
      i_internal_tabname     = 'GS_302'
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
      et_fieldcat_lvc = gt_fieldcat_0302[]
    TABLES
      it_data         = gt_302
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT gt_fieldcat_0302 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE   <ls_fcat>-fieldname.
      WHEN 'WEBLNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f55. "백로그 문서 번호
        <ls_fcat>-just = 'C'.
      WHEN 'WEBLPOS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f56. "백로그 문서 아이템
        <ls_fcat>-just = 'C'.
      WHEN 'SEQNO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f57. "순번
        <ls_fcat>-just = 'C'.
      WHEN 'MATNR_FR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f58. "기존 자재코드
        <ls_fcat>-just = 'C'.
      WHEN 'MAKTX'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f59. "기존 자재내역
        <ls_fcat>-just = 'L'.
      WHEN 'MATNR_TO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f60. "변경 자재코드
        <ls_fcat>-just = 'C'.
      WHEN 'MAKTX2'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f61. "변경 자재내역
        <ls_fcat>-just = 'L'.
      WHEN 'CRDAT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f62. "변경일자
        <ls_fcat>-just = 'C'.
      WHEN 'CRTIM'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f63. "변경시간
        <ls_fcat>-just = 'C'.
      WHEN 'CRNAM'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f64. "변경자
        <ls_fcat>-just = 'C'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_of_toolbar_grid_0302
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0302 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0302
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
*& Form call_grid_0302_display
*&---------------------------------------------------------------------*
FORM call_grid_0302_display .

  CALL METHOD go_grid_0302->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0302
      it_toolbar_excluding = gt_exclude_0302
    CHANGING
      it_outtab            = gt_302
      it_fieldcatalog      = gt_fieldcat_0302.
* 인풋이벤트 추가
  CALL METHOD go_grid_0302->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD go_grid_0302->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.
