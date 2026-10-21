*&---------------------------------------------------------------------*
*& Include          ZGTSDR0012F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*&---------------------------------------------------------------------*
form initialization.
  __cle s_erdat.

  data : lv_date type datum.

  call function 'RP_CALC_DATE_IN_INTERVAL'
    exporting
      date      = sy-datum
      days      = '0'
      months    = '3'
      signum    = '-'
      years     = '0'
    importing
      calc_date = lv_date.

  lv_date = lv_date(6) && '01'.

  s_erdat-sign   = 'I'.
  s_erdat-option = 'BT'.
  s_erdat-low    = lv_date.
  s_erdat-high   = sy-datum.
  append s_erdat.
endform.

*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN
*&---------------------------------------------------------------------*
form modify_screen.

endform.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
form get_data.
  __cle gt_alv.

  select * into corresponding fields of table gt_alv
    from zgtsdt0011
   where vbeln in s_vbeln
     and posnr in s_posnr
     and charg in s_charg
     and erdat in s_erdat.

  sort gt_alv by vbeln posnr charg.

  if gt_alv[] is not initial.
    data: lt_vbap_unit type table of vbap.
    select vbeln posnr vrkme
      into corresponding fields of table lt_vbap_unit
      from vbap
       for all entries in gt_alv
     where vbeln = gt_alv-vbeln
       and posnr = gt_alv-posnr.
    sort lt_vbap_unit by vbeln posnr.
  endif.

  " EDITABLE 처리를 위해 CELL STYLE 지정 및 단위 매핑
  loop at gt_alv into gs_alv.
    read table lt_vbap_unit into data(ls_vbap_unit)
                            with key vbeln = gs_alv-vbeln
                                     posnr = gs_alv-posnr
                                     binary search.
    if sy-subrc = 0.
      gs_alv-vrkme = ls_vbap_unit-vrkme.
    endif.

    perform set_cell_style using: gs_alv-cells 'MATNR',
                                  gs_alv-cells 'CHARG',
                                  gs_alv-cells 'KWMENG'.
    modify gt_alv from gs_alv.
  endloop.

endform.

*&---------------------------------------------------------------------*
*&      Form  SET_CELL_STYLE
*&---------------------------------------------------------------------*
form set_cell_style using pt_cells type lvc_t_styl
                          pv_field.
  data: ls_cells type lvc_s_styl.
  ls_cells-fieldname = pv_field.
  ls_cells-style     = cl_gui_alv_grid=>mc_style_enabled.
  insert ls_cells into table pt_cells.
endform.

*&---------------------------------------------------------------------*
*&      Form  SET_LAYOUT
*&---------------------------------------------------------------------*
form set_layout.
  clear gs_layout.
  gs_layout-zebra      = 'X'.
  gs_layout-sel_mode   = 'A'.
  gs_layout-cwidth_opt = 'X'.
  gs_layout-stylefname = 'CELLS'.
endform.

*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT
*&---------------------------------------------------------------------*
form set_fieldcat.
  __cle gt_fcat.

  perform add_fcat using:
    'VBELN'    'ZGTSDT0011' 'VBELN'  '' '' text-f01 'X',
    'POSNR'    'ZGTSDT0011' 'POSNR'  '' '' text-f02 '',
    'SEQNO'    'ZGTSDT0011' 'SEQNO'  '' '' text-f06 '',
    'MATNR'    'ZGTSDT0011' 'MATNR'  'X' '' text-f03 '',
    'CHARG'    'ZGTSDT0011' 'CHARG'  'X' '' text-f04 '',
    'KWMENG'   'ZGTSDT0011' 'KWMENG' 'X' '' text-f05 '',
    'VRKME'    'VBAP'       'VRKME'  '' '' '' '',
    'ERNAM'    'ZGTSDT0011' 'ERNAM'    '' '' '' '',
    'ERDAT'    'ZGTSDT0011' 'ERDAT'    '' '' '' '',
    'ERZEIT'   'ZGTSDT0011' 'ERZEIT'   '' '' '' '',
    'ERDATLO'  'ZGTSDT0011' 'ERDATLO'  '' '' '' '',
    'ERTIMLO'  'ZGTSDT0011' 'ERTIMLO'  '' '' '' '',
    'ERTCODE'  'ZGTSDT0011' 'ERTCODE'  '' '' 'Tcode' '',
    'EREMPNO'  'ZGTSDT0011' 'EREMPNO'  '' '' '' '',
    'AENAM'    'ZGTSDT0011' 'AENAM'    '' '' '' '',
    'AEDAT'    'ZGTSDT0011' 'AEDAT'    '' '' '' '',
    'AEZEIT'   'ZGTSDT0011' 'AEZEIT'   '' '' '' '',
    'AEDATLO'  'ZGTSDT0011' 'AEDATLO'  '' '' '' '',
    'AETIMLO'  'ZGTSDT0011' 'AETIMLO'  '' '' '' '',
    'AETCODE'  'ZGTSDT0011' 'AETCODE'  '' '' 'Tcode' '',
    'AEEMPNO'  'ZGTSDT0011' 'AEEMPNO'  '' '' '사원번호' ''.

endform.

*&---------------------------------------------------------------------*
*&      Form  SET_EXCLUDE
*&---------------------------------------------------------------------*
form set_exclude.
  clear gt_exclude.
  append cl_gui_alv_grid=>mc_fc_loc_insert_row to gt_exclude. "추가
  append cl_gui_alv_grid=>mc_fc_loc_delete_row to gt_exclude. "삭제
  append cl_gui_alv_grid=>mc_fc_loc_append_row to gt_exclude. "생성
  append cl_gui_alv_grid=>mc_fc_loc_copy_row   to gt_exclude. "복사

  append cl_gui_alv_grid=>mc_fc_loc_cut           to gt_exclude.
  append cl_gui_alv_grid=>mc_fc_loc_copy          to gt_exclude.
  append cl_gui_alv_grid=>mc_fc_loc_paste         to gt_exclude.
  append cl_gui_alv_grid=>mc_fc_loc_paste_new_row to gt_exclude.
  append cl_gui_alv_grid=>mc_fc_loc_undo          to gt_exclude.
endform.

*&---------------------------------------------------------------------*
*&      Form  ADD_FCAT
*&---------------------------------------------------------------------*
form add_fcat using pv_field pv_ref_tab pv_ref_field
                    pv_edit pv_key pv_text p_hotspot.
  clear gs_fcat.
  gs_fcat-fieldname = pv_field.
  gs_fcat-ref_table = pv_ref_tab.
  gs_fcat-ref_field = pv_ref_field.
  gs_fcat-edit      = pv_edit.
  gs_fcat-key       = pv_key.
  if pv_text is not initial.
    gs_fcat-coltext = gs_fcat-scrtext_l =
    gs_fcat-scrtext_m = gs_fcat-scrtext_s = pv_text.
  endif.
  gs_fcat-hotspot   = p_hotspot.
  append gs_fcat to gt_fcat.
endform.

*&---------------------------------------------------------------------*
*&      Form  REGISTER_EVENT
*&---------------------------------------------------------------------*
form register_event.
  create object go_event_receiver.
  set handler go_event_receiver->handle_data_changed for go_grid.
  set handler go_event_receiver->handle_hotspot_click for go_grid.
  call method go_grid->register_edit_event
    exporting
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.
endform.

*&---------------------------------------------------------------------*
*&      Form  DATA_SAVE
*&---------------------------------------------------------------------*
form data_save.
  data: lt_index_rows type lvc_t_row,
        ls_index_row  type lvc_s_row.
  data: lv_answer type c.
  data: ls_zgtsdt0011 type zgtsdt0011.
  data: lv_msg       type string,
        lv_vbeln_str type string,
        lv_posnr_str type string.

  "선택된 ROW 가져오기
  call method go_grid->get_selected_rows
    importing
      et_index_rows = lt_index_rows.

  if lt_index_rows[] is initial.
    message s000 with '선택된 데이터가 없습니다.'.
    exit.
  endif.

  call function 'POPUP_TO_CONFIRM'
    exporting
      titlebar              = '저장'
      text_question         = '저장하겠습니까?'
      text_button_1         = '예'
      text_button_2         = '아니오'
      display_cancel_button = ' '
    importing
      answer                = lv_answer
    exceptions
      text_not_found        = 1
      others                = 2.

  if lv_answer <> '1'.
    exit.
  endif.

  " Validation & Save Logic 준비
  types: begin of ty_keys,
           vbeln type vbap-vbeln,
           posnr type vbap-posnr,
         end of ty_keys.
  data: lt_keys type table of ty_keys,
        ls_keys type ty_keys.
  data: lt_db_table type table of zgtsdt0011.
  data: lt_vbap type table of vbap,
        ls_vbap type vbap.
  data: lt_save     type table of zgtsdt0011.


  clear gv_error.

  loop at lt_index_rows into ls_index_row.
    read table gt_alv into gs_alv index ls_index_row-index.
    if sy-subrc = 0.
      perform check_validate.  " 라인별 체크
    endif.
    if gv_error = zgtsd_x.
      exit.
    endif.
  endloop.

  if gv_error = zgtsd_x.
    exit.
  endif.


  " 1. 관련 VBELN & POSNR 추출
  loop at lt_index_rows into ls_index_row.
    read table gt_alv into gs_alv index ls_index_row-index.
    if sy-subrc = 0.
      clear ls_keys.
      ls_keys-vbeln = gs_alv-vbeln.
      ls_keys-posnr = gs_alv-posnr.
      append ls_keys to lt_keys.
    endif.
  endloop.
  sort lt_keys by vbeln posnr.
  delete adjacent duplicates from lt_keys comparing vbeln posnr.

  " 2. 해당 KEY들에 대한 전체 이력(DB 기준) 조회 (화면에 안보이는 데이터까지 합산 위함)
  if lt_keys[] is not initial.
    select * into table lt_db_table
      from zgtsdt0011
       for all entries in lt_keys
     where vbeln = lt_keys-vbeln
       and posnr = lt_keys-posnr.

    " VBAP 데이터 조회
    select vbeln posnr matnr kwmeng
      into corresponding fields of table lt_vbap
      from vbap
       for all entries in lt_keys
     where vbeln = lt_keys-vbeln
       and posnr = lt_keys-posnr.
  endif.

  " 3. 선택한 라인의 변경 내용을 가상의 전체 이력(LT_DB_TABLE)에 반영
  field-symbols: <ls_db> type zgtsdt0011.
  loop at lt_index_rows into ls_index_row.
    read table gt_alv into gs_alv index ls_index_row-index.
    if sy-subrc = 0.
      " DB 내에서 수정 전 데이터 조회
      read table lt_db_table assigning <ls_db>
           with key vbeln = gs_alv-vbeln posnr = gs_alv-posnr seqno = gs_alv-seqno.  "charg = gs_alv-charg.
      if sy-subrc = 0.
        <ls_db>-charg = gs_alv-charg.
        <ls_db>-matnr  = gs_alv-matnr.
        <ls_db>-kwmeng = gs_alv-kwmeng.
      else.
        " DB에 없는 새로운 행인 경우 추가 : 현재는 ALV에서 기능이 없지만 추후 필요시 행추가(SEQNO+1) 검토
        clear ls_zgtsdt0011.
        move-corresponding gs_alv to ls_zgtsdt0011.
        append ls_zgtsdt0011 to lt_db_table.
      endif.

      " 저장을 위해 Save 테이블에 생성(업데이트) 정보 추가
      clear ls_zgtsdt0011.
      move-corresponding gs_alv to ls_zgtsdt0011.

      if ls_zgtsdt0011-erdat is initial.
        zgtsd_cl_common=>set_timestamp( exporting iv_gubun = zgtsd_c
                                   changing cs_timestamp = ls_zgtsdt0011 ).
      else.
        zgtsd_cl_common=>set_timestamp( exporting iv_gubun = zgtsd_u
                                   changing cs_timestamp = ls_zgtsdt0011 ).
      endif.

      append ls_zgtsdt0011 to lt_save.
    endif.
  endloop.

  " 4. 합계 검증 진행
  data: lv_sum_kwmeng type kwmeng,
        lv_matnr_chk  type matnr,
        lv_first      type char1.

  loop at lt_keys into ls_keys.
    clear: lv_sum_kwmeng, lv_matnr_chk.
    lv_first = 'X'.

    " 해당 KEY의 통합된 데이터(DB 원본 + 화면의 수정본) 스캔
    loop at lt_db_table assigning <ls_db> where vbeln = ls_keys-vbeln
                                             and posnr = ls_keys-posnr.
      if lv_first = 'X'.
        lv_matnr_chk = <ls_db>-matnr.
        lv_first = ' '.
      else.
        if lv_matnr_chk <> <ls_db>-matnr.
          " 동일 항번 내에서 자재번호가 다를 경우를 막음
          lv_matnr_chk = 'ERROR_MATERIAL_MISMATCH'.
        endif.
      endif.
      lv_sum_kwmeng = lv_sum_kwmeng + <ls_db>-kwmeng.
    endloop.

    " VBAP와 최종 비교
    read table lt_vbap into ls_vbap with key vbeln = ls_keys-vbeln posnr = ls_keys-posnr.
    if sy-subrc = 0.
      if lv_matnr_chk <> ls_vbap-matnr or lv_sum_kwmeng <> ls_vbap-kwmeng.
        lv_vbeln_str = ls_keys-vbeln.
        lv_posnr_str = ls_keys-posnr.
        shift lv_vbeln_str left deleting leading '0'.
        shift lv_posnr_str left deleting leading '0'.
        concatenate '주문번호 ' lv_vbeln_str ' / 주문항번 ' lv_posnr_str
                    '에 있는 정보(자재 또는 수량)와 불일치하여 저장 불가합니다.'
               into lv_msg.
        message lv_msg type 'E' display like 'I'.
        exit.
      endif.
    else.
      "VBAP 존재 안 함
      lv_vbeln_str = ls_keys-vbeln.
      lv_posnr_str = ls_keys-posnr.
      shift lv_vbeln_str left deleting leading '0'.
      shift lv_posnr_str left deleting leading '0'.
      concatenate '주문번호 ' lv_vbeln_str ' / 주문항번 ' lv_posnr_str
                  '에 있는 정보(자재 또는 수량)와 불일치하여 저장 불가합니다.'
             into lv_msg.
      message lv_msg type 'E' display like 'I'.
      exit.
    endif.
  endloop.

  " 5. 검증 통과 완료 시 Save 테이블 반영
  modify zgtsdt0011 from table lt_save.
  if sy-subrc = 0.
    commit work.
    message s000 with '정상적으로 저장되었습니다.'.

    "그리드 데이터 갱신
    loop at lt_index_rows into ls_index_row.
      read table gt_alv into gs_alv index ls_index_row-index.
      if sy-subrc = 0.
        if gs_alv-erdat is initial.
          zgtsd_cl_common=>set_timestamp( exporting iv_gubun = zgtsd_c
                                     changing cs_timestamp = gs_alv ).
        else.
          zgtsd_cl_common=>set_timestamp( exporting iv_gubun = zgtsd_u
                                     changing cs_timestamp = gs_alv ).
        endif.
        modify gt_alv from gs_alv index ls_index_row-index.
      endif.
    endloop.

    gs_stbl-row = 'X'. gs_stbl-col = 'X'.
    call method go_grid->refresh_table_display
      exporting
        is_stable = gs_stbl.
  else.
    rollback work.
    message e000 with '저장 중 오류가 발생했습니다.'.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form check_validate
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form check_validate .

  if gs_alv-matnr is initial.
    message s133 with sy-tabix display like 'E'. "자재코드 정보가 없습니다
    gv_error = zgtsd_x.
    exit.
  endif.

  "-- 수량(KWMENG)에 값이 1개라도 없으면, Error
  if gs_alv-kwmeng = 0.
    message s126 with sy-tabix display like 'E'. "수량(=길이) 정보가 없습니다
    gv_error = zgtsd_x.
    exit.
  endif.

  "-- 배치번호(CHARG)에 값이 1개라도 없으면, Error
  if gs_alv-charg is initial.
    message s127 with sy-tabix display like 'E'. "배치 정보가 없습니다.
    gv_error = zgtsd_x.
    exit.
  endif.

  "-- 동일한 주문번호 내에, 배치번호(CHARG)가 1개라도 중복으로 입력되면, Error
  data: lv_dup_cnt type i.
  data: lt_0011 like zgtsdt0011 occurs 0 with header line.

  clear lv_dup_cnt.

  select * into table lt_0011
    from zgtsdt0011
   where vbeln = gs_alv-vbeln.

  loop at lt_0011.
    read table gt_alv into data(ls_dat) with key vbeln = lt_0011-vbeln
                                                 posnr = lt_0011-posnr
                                                 seqno = lt_0011-seqno.
    if sy-subrc = 0.
      move-corresponding ls_dat to lt_0011.
      modify lt_0011.
    endif.
  endloop.

  loop at lt_0011 transporting no fields where vbeln = gs_alv-vbeln
                                            and charg = gs_alv-charg.
    lv_dup_cnt = lv_dup_cnt + 1.
  endloop.


  if lv_dup_cnt > 1.
    message s124 with gs_alv-charg display like 'E'.
    gv_error = zgtsd_x.
    exit.
  endif.


  "-- 자재마스터 MCH1 테이블 확인
  select single mandt into sy-mandt
    from mch1
   where matnr = gs_alv-matnr
     and charg = gs_alv-charg
     and lvorm = space.
  if sy-subrc <> 0.
    message s132 with gs_alv-matnr gs_alv-charg display like 'E'.
    gv_error = zgtsd_x.
    exit.
  endif.

  "-- 자재마스터 영업조직 정보 확인
  select single a~mandt into sy-mandt
    from mvke as a inner join vbak as b on a~vkorg = b~vkorg
                                       and a~vtweg = b~vtweg
   where a~matnr = gs_alv-matnr
     and b~vbeln = gs_alv-vbeln.
  if sy-subrc <> 0.
    message s130 with gs_alv-matnr display like 'E'.
    gv_error = zgtsd_x.
    exit.
  endif.

  "-- 자재마스터 플랜트 정보 확인
  select single mandt into sy-mandt
    from marc
   where matnr = gs_alv-matnr
     and werks = '1401'.
  if sy-subrc <> 0.
    message s131 with gs_alv-matnr display like 'E'.
    gv_error = zgtsd_x.
    exit.
  endif.


endform.
