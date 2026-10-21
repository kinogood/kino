
*&---------------------------------------------------------------------*
*&      Form  SET_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_init .

  " 첫 번째 버튼 (FC01)
  clear sscrfields-functxt_01.
  sscrfields-functxt_01 = 'PA 손익계산서 (피복선)'.

  " 아이콘을 넣고 싶은 경우 (ICON_INFORMATION 등의 상수 사용)
  " CALL FUNCTION 'ICON_CREATE' 구문으로 아이콘+텍스트 조합 가능


  "-- Default로 030 테이블의 데이터를 가져온다.
  gv_read_new = ''.

  "-- 사원번호
  if strlen( sy-uname ) = 8.
    if sy-uname(8) co '0123456789'.
      p_pernr = sy-uname.
    endif.
  endif.

  "-- 주문생성일
  perform set_init_erdat.

  get parameter id 'VKB' field p_vkbur.
  perform set_vkbur_text.

  get parameter id 'PER' field p_pernr.
  perform set_pernr_text.

endform.                    " SET_INIT
*&---------------------------------------------------------------------*
*&      Form  GET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_FCAT  text
*      -->P_GT_MAIN_TABNAME  text
*----------------------------------------------------------------------*
form get_field_catalog  using    pv_tabname
                                 pv_tabkey
                        changing pv_whcond
                                 pv_key_len.


  data : lv_tabnm  like dd02l-tabname.
  data : lt_fcat   type lvc_t_fcat.
  data : ls_fcat   type lvc_s_fcat.
  data : lv_start  type i.
  data : lv_whcond type string.


  lv_tabnm = pv_tabname.

  call function 'LVC_FIELDCATALOG_MERGE'
    exporting
      i_bypassing_buffer     = ' '
      i_buffer_active        = 'X'
      i_structure_name       = lv_tabnm
    changing
      ct_fieldcat            = lt_fcat
    exceptions
      inconsistent_interface = 1
      program_error          = 2
      others                 = 3.

  delete lt_fcat where fieldname = 'MANDT'.

  " TABLE별 KEY condition을 만듬
  clear lv_whcond.
  lv_start = 3.

  " KEY의 데이터로 조회할 쿼리 작성
  loop at lt_fcat into ls_fcat where key = 'X'.

    if lv_whcond is not initial.
      concatenate lv_whcond 'AND' into lv_whcond separated by space.
    endif.

    concatenate lv_whcond ls_fcat-fieldname
           into lv_whcond separated by space.

    concatenate lv_whcond ' EQ ' ' ''' pv_tabkey+lv_start(ls_fcat-intlen) ''''
           into lv_whcond.

    lv_start = lv_start + ls_fcat-intlen.

  endloop.

  pv_whcond  = lv_whcond.
  pv_key_len = lv_start.

endform.                    " GET_FIELD_CATALOG

*&---------------------------------------------------------------------*
*&      Form  CREATE_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form create_container .

* Create docking container
  create object go_docking
    exporting
      parent = cl_gui_container=>screen0
      ratio  = 90
    exceptions
      others = 6.
  if sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

  call method go_docking->set_extension
    exporting
      extension  = 99999  " full-screen size !!!
    exceptions
      cntl_error = 1
      others     = 2.

* Create splitter container
  create object go_splitter
    exporting
      parent            = go_docking
      rows              = 1
      columns           = 2
*     NO_AUTODEF_PROGID_DYNNR =
*     NAME              =
    exceptions
      cntl_error        = 1
      cntl_system_error = 2
      others            = 3.
  if sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.


* Get cell container
  call method go_splitter->get_container
    exporting
      row       = 1
      column    = 1
    receiving
      container = go_cell_left.

  call method go_splitter->get_container
    exporting
      row       = 1
      column    = 2
    receiving
      container = go_cell_right.

  call method go_splitter->set_column_width
    exporting
      id    = 1
      width = gc_open_width.  "40

  gv_tree_on = gc_open.

*  CALL METHOD GO_SPLITTER->SET_ROW_HEIGHT
*    EXPORTING
*      ID     = 1
*      HEIGHT = 30.

endform.                    " CREATE_CONTAINER
*&---------------------------------------------------------------------*
*&      Form  CREATE_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form create_grid .

  create object go_grid2
    exporting
      i_parent = go_cell_right
    exceptions
      others   = 5.

  if sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.


endform.                    " CREATE_GRID
*&---------------------------------------------------------------------*
*&      Form  SET_EVENT_HANDLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_event_handle .


* Set event handler
**  SET HANDLER: LCL_EVENTHANDLER=>HANDLE_DOUBLE_CLICK FOR GO_GRID1.
  set handler: lcl_eventhandler=>handle_double_click  for go_grid2,
               lcl_eventhandler=>toolbar              for go_grid2,
               lcl_eventhandler=>handle_hotspot_click for go_grid2,
               lcl_eventhandler=>user_command         for go_grid2.

endform.                    " SET_EVENT_HANDLE
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form display_grid .


  perform change_toolbar_alv2 .


  clear gs_layout.
  gs_layout-zebra      = abap_true.
  gs_layout-sel_mode   = 'D'.
  gs_layout-col_opt    = abap_true.
  gs_layout-cwidth_opt = 'A'.  "ABAP_TRUE.
  gs_layout-no_rowmark = ''.
*  gs_layout-box_fname  = 'ZSEL'.

  perform set_fieldcateglog using 'zgtsds0042'
                                   gt_detail[]
                                   gt_fcat_detail[].

  data: lw_sort type lvc_s_sort. "SLIS_SORTINFO_ALV.
  data: gt_sort type lvc_t_sort.


  gs_variant-report = sy-repid.
  if  p_alv is not initial.
    gs_variant-variant = p_alv.
  endif.


* Display data
  call method go_grid2->set_table_for_first_display
    exporting
      i_structure_name     = 'GT_DETAIL'
      i_save               = 'A'
**      I_BYPASSING_BUFFER = 'X'
      is_layout            = gs_layout
      is_variant           = gs_variant
      i_default            = 'X'
      it_toolbar_excluding = gt_excl_func
    changing
      it_outtab            = gt_detail[]
      it_fieldcatalog      = gt_fcat_detail
      it_sort              = gt_sort
    exceptions
      others               = 4.

  call method go_grid2->set_drop_down_table
    exporting
      it_drop_down_alias = gt_dbltype.

* Link the docking container to the target dynpro
  call method go_docking->link
    exporting
      repid  = syst-repid
      dynnr  = '0100'
*     CONTAINER                   =
    exceptions
      others = 4.
  if sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

**-- 수정용
**  go_grid2->set_ready_for_input( 1 ).

endform.                    " DISPLAY_GRID
*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCATEGLOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2437   text
*      -->P_GT_OUTTAB[]  text
*----------------------------------------------------------------------*
form set_fieldcateglog using value(pv_intrnname)
                             pt_table type standard table
                             pt_fcat  type lvc_t_fcat.

  field-symbols: <lfs_fieldcat> type lvc_s_fcat.
  data : ls_fcat                type lvc_s_fcat.

  data: gr_structdescr type ref to cl_abap_structdescr,
        gt_components  type abap_component_tab,
        gs_components  type abap_componentdescr.


  call function 'LVC_FIELDCATALOG_MERGE'
    exporting
      i_structure_name       = pv_intrnname
    changing
      ct_fieldcat            = pt_fcat
    exceptions
      inconsistent_interface = 1
      program_error          = 2
      others                 = 3.


  data lv_pos  type i.

  lv_pos = 0.
  loop at pt_fcat assigning <lfs_fieldcat>.

    case <lfs_fieldcat>-fieldname.
      when 'MATNR'.         .
        <lfs_fieldcat>-outputlen = '10'.
*        <lfs_fieldcat>-edit = abap_true.
      when 'KUNNR'           .
        <lfs_fieldcat>-coltext   = '판매처'.
        <lfs_fieldcat>-scrtext_l = '판매처'.
        <lfs_fieldcat>-scrtext_m = '판매처'.
        <lfs_fieldcat>-scrtext_s = '판매처'.
      when 'KUNNR_NM'           .
        <lfs_fieldcat>-outputlen = '25'.
        <lfs_fieldcat>-coltext   = '판매처명'.
        <lfs_fieldcat>-scrtext_l = '판매처명'.
        <lfs_fieldcat>-scrtext_m = '판매처명'.
        <lfs_fieldcat>-scrtext_s = '판매처명'.
      when 'ZPJNO'           .
        <lfs_fieldcat>-coltext   = '프로젝트'.
        <lfs_fieldcat>-scrtext_l = '프로젝트'.
        <lfs_fieldcat>-scrtext_m = '프로젝트'.
        <lfs_fieldcat>-scrtext_s = '프로젝트'.
      when 'ZPTXT'           .
        <lfs_fieldcat>-coltext   = '프로젝트명'.
        <lfs_fieldcat>-scrtext_l = '프로젝트명'.
        <lfs_fieldcat>-scrtext_m = '프로젝트명'.
        <lfs_fieldcat>-scrtext_s = '프로젝트명'.
      when 'VBELN_VA'           .
        <lfs_fieldcat>-just      = 'C'.
        <lfs_fieldcat>-hotspot   = 'X'.
        <lfs_fieldcat>-coltext   =
        <lfs_fieldcat>-scrtext_s =
        <lfs_fieldcat>-scrtext_m =
        <lfs_fieldcat>-scrtext_l = '주문번호'.
      when 'POSNR_VA'           .
        <lfs_fieldcat>-coltext   =
        <lfs_fieldcat>-scrtext_s =
        <lfs_fieldcat>-scrtext_m =
        <lfs_fieldcat>-scrtext_l = '주문항번'.
      when 'PRODH'           .
        <lfs_fieldcat>-coltext   = '제품계층구조'.
        <lfs_fieldcat>-scrtext_l = '제품계층구조'.
        <lfs_fieldcat>-scrtext_m = '제품계층구조'.
        <lfs_fieldcat>-scrtext_s = '제품계층구조'.
      when 'PRODH_NM'           .
        <lfs_fieldcat>-outputlen = '20'.
        <lfs_fieldcat>-coltext   = '제품계층구조명'.
        <lfs_fieldcat>-scrtext_l = '제품계층구조명'.
        <lfs_fieldcat>-scrtext_m = '제품계층구조명'.
        <lfs_fieldcat>-scrtext_s = '제품계층구조명'.
      when 'ARKTX'           .
        <lfs_fieldcat>-coltext   =
        <lfs_fieldcat>-scrtext_s =
        <lfs_fieldcat>-scrtext_m =
        <lfs_fieldcat>-scrtext_l = '자재명'.
      when 'KWMENG' .
*        <lfs_fieldcat>-do_sum    = 'X'.
        <lfs_fieldcat>-outputlen = '15'.
        <lfs_fieldcat>-coltext   = '주문수량'.
        <lfs_fieldcat>-scrtext_l = '주문수량'.
        <lfs_fieldcat>-scrtext_m = '주문수량'.
        <lfs_fieldcat>-scrtext_s = '주문수량'.
      when 'NETPR' .
        <lfs_fieldcat>-outputlen = '10'.
      when 'JOJANG_UOM'           .
        <lfs_fieldcat>-outputlen = '10'.
        <lfs_fieldcat>-coltext   =
        <lfs_fieldcat>-scrtext_l =
        <lfs_fieldcat>-scrtext_m =
        <lfs_fieldcat>-scrtext_s = '조장(판매단위)'.
      when 'JOJANG_QTY'           .
        <lfs_fieldcat>-outputlen = '10'.
        <lfs_fieldcat>-coltext   =
        <lfs_fieldcat>-scrtext_l =
        <lfs_fieldcat>-scrtext_m =
        <lfs_fieldcat>-scrtext_s = '조장수'.
      when 'ERDAT_VL'      .
        <lfs_fieldcat>-coltext   = '납품생성일'.
        <lfs_fieldcat>-scrtext_l = '납품생성일'.
        <lfs_fieldcat>-scrtext_m = '납품생성일'.
        <lfs_fieldcat>-scrtext_s = '납품생성일'.
      when 'LFIMG'.
        <lfs_fieldcat>-outputlen = '15'.
      when 'EDATU'      .
        <lfs_fieldcat>-coltext   = '납품요청일'.
        <lfs_fieldcat>-scrtext_l = '납품요청일'.
        <lfs_fieldcat>-scrtext_m = '납품요청일'.
        <lfs_fieldcat>-scrtext_s = '납품요청일'.
      when 'WAERK'      .
        <lfs_fieldcat>-coltext   = '거래통화'.
        <lfs_fieldcat>-scrtext_l = '거래통화'.
        <lfs_fieldcat>-scrtext_m = '거래통화'.
        <lfs_fieldcat>-scrtext_s = '거래통화'.
      when 'VBELN_VL'      .
        <lfs_fieldcat>-just      = 'C'.
        <lfs_fieldcat>-hotspot   = 'X'.
        <lfs_fieldcat>-coltext   = '납품번호'.
        <lfs_fieldcat>-scrtext_l = '납품번호'.
        <lfs_fieldcat>-scrtext_m = '납품번호'.
        <lfs_fieldcat>-scrtext_s = '납품번호'.
      when 'POSNR_VL'      .
        <lfs_fieldcat>-coltext   = '납품항번'.
        <lfs_fieldcat>-scrtext_l = '납품항번'.
        <lfs_fieldcat>-scrtext_m = '납품항번'.
        <lfs_fieldcat>-scrtext_s = '납품항번'.
      when 'VBELN_VF'      .
        <lfs_fieldcat>-just      = 'C'.
        <lfs_fieldcat>-hotspot   = 'X'.
        <lfs_fieldcat>-coltext   = '청구번호'.
        <lfs_fieldcat>-scrtext_l = '청구번호'.
        <lfs_fieldcat>-scrtext_m = '청구번호'.
        <lfs_fieldcat>-scrtext_s = '청구번호'.
      when 'POSNR_VF'      .
        <lfs_fieldcat>-coltext   = '청구항번'.
        <lfs_fieldcat>-scrtext_l = '청구항번'.
        <lfs_fieldcat>-scrtext_m = '청구항번'.
        <lfs_fieldcat>-scrtext_s = '청구항번'.
      when 'NETWR_SO'      .
        <lfs_fieldcat>-outputlen = '15'.
        <lfs_fieldcat>-coltext   = '주문액(거래통화)'.
        <lfs_fieldcat>-scrtext_l = '주문액(거래통화)'.
        <lfs_fieldcat>-scrtext_m = '주문액(거래통화)'.
        <lfs_fieldcat>-scrtext_s = '주문액(거래통화)'.
      when 'PERNR'      .
        <lfs_fieldcat>-outputlen = '10'.
        <lfs_fieldcat>-coltext   = '영업사원'.
        <lfs_fieldcat>-scrtext_l = '영업사원'.
        <lfs_fieldcat>-scrtext_m = '영업사원'.
        <lfs_fieldcat>-scrtext_s = '영업사원'.
      when 'PERNR_NM'      .
        <lfs_fieldcat>-outputlen = '10'.
        <lfs_fieldcat>-coltext   = '영업사원명'.
        <lfs_fieldcat>-scrtext_l = '영업사원명'.
        <lfs_fieldcat>-scrtext_m = '영업사원명'.
        <lfs_fieldcat>-scrtext_s = '영업사원명'.
*      when 'BLTYPE' .
*        <lfs_fieldcat>-outputlen = '6'.
*        <lfs_fieldcat>-coltext   = '유형'.
*        <lfs_fieldcat>-scrtext_l = '유형'.
*        <lfs_fieldcat>-scrtext_m = '유형'.
*        <lfs_fieldcat>-scrtext_s = '유형'.
      when 'BLTYPE_NM'.
        <lfs_fieldcat>-outputlen = '6'.
        <lfs_fieldcat>-drdn_hndl  = '1'. " 드롭다운 핸들 할당
        <lfs_fieldcat>-drdn_alias = 'X'. " 도메인 텍스트를 보여주라는 플래그
        <lfs_fieldcat>-coltext   = '유형'.
        <lfs_fieldcat>-scrtext_l = '유형'.
        <lfs_fieldcat>-scrtext_m = '유형'.
        <lfs_fieldcat>-scrtext_s = '유형'.
      when 'WADAT' .
        <lfs_fieldcat>-coltext   = '계획출고일'.
        <lfs_fieldcat>-scrtext_l = '계획출고일'.
        <lfs_fieldcat>-scrtext_m = '계획출고일'.
        <lfs_fieldcat>-scrtext_s = '계획출고일'.
      when 'GIDAT' .
        <lfs_fieldcat>-coltext   = '출고일'.
        <lfs_fieldcat>-scrtext_l = '출고일'.
        <lfs_fieldcat>-scrtext_m = '출고일'.
        <lfs_fieldcat>-scrtext_s = '출고일'.
      when 'SALE_DATE' .
        <lfs_fieldcat>-coltext   = '매출일'.
        <lfs_fieldcat>-scrtext_l = '매출일'.
        <lfs_fieldcat>-scrtext_m = '매출일'.
        <lfs_fieldcat>-scrtext_s = '매출일'.
      when 'SALE_QTY' .
        <lfs_fieldcat>-coltext   = '매출수량'.
        <lfs_fieldcat>-scrtext_l = '매출수량'.
        <lfs_fieldcat>-scrtext_m = '매출수량'.
        <lfs_fieldcat>-scrtext_s = '매출수량'.
      when 'SALE_AMT' .
        <lfs_fieldcat>-outputlen = '15'.
        <lfs_fieldcat>-coltext   = '매출액(거래통화)'.
        <lfs_fieldcat>-scrtext_l = '매출액(거래통화)'.
        <lfs_fieldcat>-scrtext_m = '매출액(거래통화)'.
        <lfs_fieldcat>-scrtext_s = '매출액(거래통화)'.
      when 'SALE_AMT_KRW' .
        <lfs_fieldcat>-outputlen = '15'.
        <lfs_fieldcat>-coltext   = '매출액(\)'.
        <lfs_fieldcat>-scrtext_l = '매출액(\)'.
        <lfs_fieldcat>-scrtext_m = '매출액(\)'.
        <lfs_fieldcat>-scrtext_s = '매출액(\)'.
      when 'MARGINALPROFIT_PER' .
        <lfs_fieldcat>-outputlen = '6'.
        <lfs_fieldcat>-col_pos   = '37'.
        <lfs_fieldcat>-coltext   = '한익률(%)'. "'한계이익률(%)'.
        <lfs_fieldcat>-scrtext_l = '한계이익률(%)'.
        <lfs_fieldcat>-scrtext_m = '한익률(%)'.
        <lfs_fieldcat>-scrtext_s = '한익률(%)'.
      when 'MARGINALPROFIT_KRW' .
        <lfs_fieldcat>-outputlen = '15'.
        <lfs_fieldcat>-col_pos   = '36'.
        <lfs_fieldcat>-coltext   = '한익(\)'.   "한계이익(KRW)'.
        <lfs_fieldcat>-scrtext_l = '한계이익(KRW)'.
        <lfs_fieldcat>-scrtext_m = '한익(\)'.
        <lfs_fieldcat>-scrtext_s = '한익(\)'.
      when 'REMARK'.
        <lfs_fieldcat>-outputlen = '20'.
      when 'MARGINALPROFIT_PER_R' .
        <lfs_fieldcat>-outputlen = '6'.
        <lfs_fieldcat>-col_pos   = '40'.
        <lfs_fieldcat>-coltext   = '한익률(%)_R'. "한계이익률(%)_R'.
        <lfs_fieldcat>-scrtext_l = '한계이익률(%)_R'.
        <lfs_fieldcat>-scrtext_m = '한익률(%)_R'.
        <lfs_fieldcat>-scrtext_s = '한익률(%)_R'.
      when 'MARGINALPROFIT_KRW_R' .
        <lfs_fieldcat>-outputlen = '15'.
        <lfs_fieldcat>-col_pos   = '39'.
        <lfs_fieldcat>-coltext   = '한익(\)_R'.  "한계이익(KRW)_R'.
        <lfs_fieldcat>-scrtext_l = '한계이익(KRW)_R'.
        <lfs_fieldcat>-scrtext_m = '한익(\)_R'.
        <lfs_fieldcat>-scrtext_s = '한익(\)_R'.
      when 'SALESPROFIT_PER_R' .
        <lfs_fieldcat>-outputlen = '6'.
        <lfs_fieldcat>-col_pos   = '42'.
        <lfs_fieldcat>-coltext   = '영익률(%)_R'. "영업이익률(%)_R'.
        <lfs_fieldcat>-scrtext_l = '영업이익률(%)_R'.
        <lfs_fieldcat>-scrtext_m = '영익률(%)_R'.
        <lfs_fieldcat>-scrtext_s = '영익률(%)_R'.
      when 'SALESPROFIT_KRW_R' .
        <lfs_fieldcat>-outputlen = '15'.
        <lfs_fieldcat>-col_pos   = '41'.
        <lfs_fieldcat>-coltext   = '영익(\)_R'. "영업이익(KRW)_R'.
        <lfs_fieldcat>-scrtext_l = '영업이익(KRW)_R'.
        <lfs_fieldcat>-scrtext_m = '영익(\)_R'.
        <lfs_fieldcat>-scrtext_s = '영익(\)_R'.
*      when 'OPEN_QTY'.
*        <lfs_fieldcat>-no_out    = 'X'.
*        <lfs_fieldcat>-coltext   = 'Open Qty'.
*        <lfs_fieldcat>-scrtext_l = 'Open Qty'.
*        <lfs_fieldcat>-scrtext_m = 'Open Qty'.
*        <lfs_fieldcat>-scrtext_s = 'Open Qty'.
*      when 'PLQTY'.
*        <lfs_fieldcat>-no_out    = 'X'.
*        <lfs_fieldcat>-coltext   = 'PLQTY'.
*        <lfs_fieldcat>-scrtext_l = 'PLQTY'.
*        <lfs_fieldcat>-scrtext_m = 'PLQTY'.
*        <lfs_fieldcat>-scrtext_s = 'PLQTY'.
*      when 'LIFNR'.
*        <lfs_fieldcat>-no_out    = 'X'.
**        <lfs_fieldcat>-coltext   = '영업사원'.
**        <lfs_fieldcat>-scrtext_l = '영업사원'.
**        <lfs_fieldcat>-scrtext_m = '영업사원'.
**        <lfs_fieldcat>-scrtext_s = '영업사원'.
      when 'BLTYPE' or 'SPMON' or 'MAKTX' or 'FKDAT' or 'KEYFD' or 'LIFNR' or
            'GUBUN' or 'WAERS_KRW' or 'OPEN_AMT' or 'BLDAT' or 'OPEN_QTY' or
            'PLQTY' or 'VKGRP' or 'VTWEG' or 'SPART' or 'LAND1' . " 화면에서 제외
        <lfs_fieldcat>-tech      = 'X'.
      when others.
    endcase.

  endloop.

endform.                    " SET_FIELDCATEGLOG
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_SUB_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form display_sub_grid .

**  call method go_grid2->refresh_table_display.

  data: lt_fcat_front type lvc_t_fcat,
        ls_stable     type lvc_s_stbl.

  call method go_grid2->get_frontend_fieldcatalog
    importing
      et_fieldcatalog = lt_fcat_front.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

  call method go_grid2->refresh_table_display
    exporting
      is_stable = ls_stable
    exceptions
      finished  = 1
      others    = 2.

  cl_gui_cfw=>flush( ).

  call method cl_gui_control=>set_focus
    exporting
      control = go_grid2.

endform.                    " DISPLAY_SUB_GRID

*&---------------------------------------------------------------------*
*& Form GET_MASTER_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_master_data .



endform.



*&---------------------------------------------------------------------*
*& Form GET_COMP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_data .

  data : lt_main like zgtsds0042 occurs 0 with header line.
  data : lt_so type ty_so_tab.

  clear: lt_so,    lt_so[],
         lt_main,  lt_main[].


  perform set_init_and_clear.

  check gv_err = ''.

  if gv_read_new = 'X'.
    "-- 영업오더기준 매출추정 데이터
    perform get_sales_order   tables gt_sales.

    perform get_sap_tab_data  tables gt_sales  "SO, DO, BL을 가져온다.
                                     gt_so
                                     gt_do
                                     gt_bl
                                     gt_026.

    perform split_and_move_new tables gt_so    "-- 분할용 으로 split
                                      gt_do
                                      "gt_021
                                      gt_026
                                      lt_main.

    perform make_main_data      tables lt_main  "-- 부분출하를 BL로 분할해줌
                                       gt_bl.
    perform delete_old_bl_data  tables lt_main. "-- 전월까지 bl된것은 제외

    perform update_status_type  tables lt_main "-- 환율/매출 결정후 status 결정
                                       gt_021
                                       gt_026.

    perform get_d365_27_data    tables gt_027.  "-- 의지치 가져오기
    perform add_027_to_main     tables gt_027   "-- 의지치 추가
                                       lt_main.

  else.
    "-- 판매계획기준 매출추정 데이터에서 ZSDT_D365_030 테이블기준 매출추정 데이터로 변경함

*    perform get_d365_21_data  tables gt_sales
*                                     gt_021.

    perform get_d365_30_data  tables gt_sales
                                     gt_030.

    perform get_sap_tab_data  tables gt_sales  "SO, DO, BL을 가져온다.
                                     gt_so
                                     gt_do
                                     gt_bl
                                     gt_026.

*    perform make_main_from_21 tables gt_so    "-- 21의 데이터를 그대로 보여줌
*                                     gt_do
*                                     gt_bl
*                                     gt_021
*                                     gt_026
*                                     lt_main.

    perform make_main_from_30 tables gt_so    "-- 30의 데이터를 그대로 보여줌
                                     gt_do
                                     gt_bl
                                     gt_030
                                     gt_026
                                     lt_main.

    perform get_d365_27_data    tables gt_027.  "-- 의지치 가져오기

  endif.


  perform add_profit_data     tables lt_main. "-- 한계이익률과 금액을 추가함

  perform add_text_to_main    tables lt_main. "-- text정보 추가

  gt_main[] = lt_main[].

  "----- Tree 구성 데이터
  perform get_plan_data . "Tree 구성용 데이터


endform.

*&---------------------------------------------------------------------*
*& Form F4_RULEKEY_DIALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_P_RULEK1  text
*&---------------------------------------------------------------------*
form f4_pernr_dialog  using    p_text
                       changing p_pernr.

  data: lt_return type table of ddshretval,
        ls_return type ddshretval.

  " Search Help(ZLE_PERNR)를 띄우고 사용자가 선택한 값을 가져옴
  call function 'F4IF_FIELD_VALUE_REQUEST'
    exporting
      tabname           = 'ZZPA0001'
      fieldname         = 'PERNR'
      searchhelp        = 'ZSD_PERNR'
    tables
      return_tab        = lt_return
    exceptions
      field_not_found   = 1
      no_help_for_field = 2
      inconsistent_help = 3
      no_values_found   = 4
      others            = 5.

  " 사용자가 팝업에서 값을 선택했다면 (취소하지 않았다면)
  if sy-subrc = 0 and lt_return[] is not initial.

    read table lt_return into ls_return index 1.
    p_pernr = ls_return-fieldval.

    " 강제 엔터
    call function 'SAPGUI_SET_FUNCTIONCODE'
      exporting
        functioncode = '='.

  endif.

endform.

*&---------------------------------------------------------------------*
*& Form GET_PLAN_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_plan_data .

  data: lt_waerk type waerk occurs 0 with header line.
  data : begin of lt_plan occurs 0,      "계획 수량
           vkbur like vbak-vkbur.
           include structure zgtsds0041.
  data : end of lt_plan.

  clear: gt_plan[], gt_plan_sum[], gt_plan_tot[].

  "-- key와 sort field를 채워준다.
  loop at gt_main into gs_main.
    gs_main-keyfd = sy-tabix.

*    case gs_main-bltype.             "-- sort용 필드
*      when 'A'. gs_main-bltype_nm = 'A 의지치'.
*      when 'B'. gs_main-bltype_nm = 'B 매출'.
*      when 'C'. gs_main-bltype_nm = 'C 미출하'.
*      when 'D'. gs_main-bltype_nm = 'D 출하진행'.
*      when 'E'. gs_main-bltype_nm = 'E 출고'.
*      when 'F'. gs_main-bltype_nm = 'F 분할-미출하'.
*      when 'G'. gs_main-bltype_nm = 'G 분할-출하진행'.
*      when 'H'. gs_main-bltype_nm = 'H 분할-출고'.
*    endcase.

    read table gt_dbltype into gs_dbltype with key int_value = gs_main-bltype.
    if sy-subrc = 0.
      gs_main-bltype_nm = gs_dbltype-value.
    endif.

    modify gt_main from gs_main.
  endloop.


  "-- tree용 데이터를 생성한다.
  loop at gt_main into gs_main.

    clear: gt_plan.

    gt_plan-vkbur     = p_vkbur.
    gt_plan-pernr     = p_pernr.

    gt_plan-spmon     = gs_main-spmon.
    gt_plan-kunnr     = gs_main-kunnr.
    gt_plan-kunnr_nm  = gs_main-kunnr_nm.
    gt_plan-zpjno     = gs_main-zpjno.
    gt_plan-zptxt     = gs_main-zptxt.
    gt_plan-waerk_tx  = gs_main-waerk.

    gt_plan-waerk        = gs_main-waerk.
    gt_plan-sale_amt     = gs_main-sale_amt.
    gt_plan-sale_amt_krw = gs_main-sale_amt_krw.
    gt_plan-waers_krw    = gs_main-waers_krw.

    gt_plan-marginalprofit_krw_r = gs_main-marginalprofit_krw_r.
    gt_plan-salesprofit_krw_r    = gs_main-salesprofit_krw_r.

    collect gt_plan.

  endloop.

  lt_plan[] = gt_plan[].

  " 담당자/월/고객/프로젝트/통화별 금액을 계산한다.
  " TREE에서 보여줄 금액은 여기서 계산한다. 자동 sum 기능 사용못함
  loop at gt_plan.

    " 통화별 합계
    clear gt_plan_sum.
    move-corresponding gt_plan to gt_plan_sum.
    gt_plan_sum-level = '5'.
    collect gt_plan_sum.


    " 프로젝트별 합계
    clear gt_plan_sum.
    move-corresponding gt_plan to gt_plan_sum.
    gt_plan_sum-level = '4'.
    gt_plan_sum-waerk_tx = ''.

    "-- 통화가 2건 이상일 경우 이후 상위레벨의 합계금액은 없음
    clear lt_waerk[].
    loop at lt_plan where vkbur = gt_plan-vkbur
                      and pernr = gt_plan-pernr
                      and spmon = gt_plan-spmon
                      and kunnr = gt_plan-kunnr
                      and zpjno = gt_plan-zpjno.
      lt_waerk = lt_plan-waerk.
      collect lt_waerk.
    endloop.
    if lines( lt_waerk ) >= 2.
      gt_plan_sum-sale_amt = 0.
      gt_plan_sum-waerk    = ''.
      gt_plan_sum-waerk_tx = ''.
    endif.

    collect gt_plan_sum.


    " 고객별 합계
    gt_plan_sum-level = '3'.
    gt_plan_sum-zpjno = ''.
    gt_plan_sum-zptxt = ''.

    "-- 통화가 2건 이상일 경우 이후 상위레벨의 합계금액은 없음
    if lines( lt_waerk ) < 2.
      clear lt_waerk[].
      loop at lt_plan where vkbur = gt_plan-vkbur
                        and pernr = gt_plan-pernr
                        and spmon = gt_plan-spmon
                        and kunnr = gt_plan-kunnr.
*                      and zpjno = gt_plan-zpjno.
        lt_waerk = lt_plan-waerk.
        collect lt_waerk.
      endloop.
    endif.
    if lines( lt_waerk ) >= 2.
      gt_plan_sum-sale_amt = 0.
      gt_plan_sum-waerk    = ''.
      gt_plan_sum-waerk_tx = ''.
    endif.

    collect gt_plan_sum.

    " 월별 합계
    gt_plan_sum-level = '2'.
    gt_plan_sum-kunnr = ''.
    gt_plan_sum-kunnr_nm = ''.

    "-- 통화가 2건 이상일 경우 이후 상위레벨의 합계금액은 없음
    if lines( lt_waerk ) < 2.
      clear lt_waerk[].
      loop at lt_plan where vkbur = gt_plan-vkbur
                        and pernr = gt_plan-pernr
                        and spmon = gt_plan-spmon.
*                        and kunnr = gt_plan-kunnr.
*                      and zpjno = gt_plan-zpjno.
        lt_waerk = lt_plan-waerk.
        collect lt_waerk.
      endloop.
    endif.
    if lines( lt_waerk ) >= 2.
      gt_plan_sum-sale_amt = 0.
      gt_plan_sum-waerk    = ''.
      gt_plan_sum-waerk_tx = ''.
    endif.

    collect gt_plan_sum.


    " 담당자 합계
    gt_plan_sum-level = '1'.
    gt_plan_sum-spmon = ''.
    collect gt_plan_sum.


    "*************************************
    "*   total용 집게데이터
    "*************************************

    clear gt_plan_tot.
    gt_plan_tot-spmon        = 'TOTAL'.
    gt_plan_tot-level        = 2.
    gt_plan_tot-sale_amt     = gt_plan-sale_amt.
    gt_plan_tot-sale_amt_krw = gt_plan-sale_amt_krw.
    gt_plan_tot-waerk        = gt_plan-waerk.
    gt_plan_tot-waers_krw    = gt_plan-waers_krw.
    gt_plan_tot-marginalprofit_krw_r = gt_plan-marginalprofit_krw_r.
    gt_plan_tot-salesprofit_krw_r    = gt_plan-salesprofit_krw_r.

    "-- 통화가 2건 이상일 경우 거래통화 합계금액은 없음
    clear lt_waerk[].
    loop at lt_plan.
      lt_waerk = lt_plan-waerk.
      collect lt_waerk.
    endloop.
    if lines( lt_waerk ) >= 2.
      gt_plan_tot-sale_amt = 0.
      gt_plan_tot-waerk    = ''.
      gt_plan_tot-waerk_tx = ''.
    endif.

    collect gt_plan_tot.  "-- 2 레벨


    clear gt_plan_tot.
    gt_plan_tot-spmon        = 'TOTAL'.
    gt_plan_tot-level        = 3.
    gt_plan_tot-waerk_tx     = gt_plan-waerk.
    gt_plan_tot-waerk        = gt_plan-waerk.
    gt_plan_tot-sale_amt_krw = gt_plan-sale_amt_krw.
    gt_plan_tot-sale_amt     = gt_plan-sale_amt.
    gt_plan_tot-waers_krw    = gt_plan-waers_krw.
    gt_plan_tot-marginalprofit_krw_r = gt_plan-marginalprofit_krw_r.
    gt_plan_tot-salesprofit_krw_r    = gt_plan-salesprofit_krw_r.

    collect gt_plan_tot. "-- 3 레벨, 최하단

  endloop.


  loop at gt_plan_sum assigning field-symbol(<sum>).
    check <sum>-sale_amt_krw <> 0.
    <sum>-marginalprofit_per_r = <sum>-marginalprofit_krw_r / <sum>-sale_amt_krw * 100.
    <sum>-salesprofit_per_r    = <sum>-salesprofit_krw_r / <sum>-sale_amt_krw * 100.
  endloop.

  loop at gt_plan_tot assigning field-symbol(<tot>).
    check <tot>-sale_amt_krw <> 0.
    <tot>-marginalprofit_per_r = <tot>-marginalprofit_krw_r / <tot>-sale_amt_krw * 100.
    <tot>-salesprofit_per_r    = <tot>-salesprofit_krw_r / <tot>-sale_amt_krw * 100.
  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form CREATE_TREE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form create_tree .

  if g_alv_tree is initial.

    perform init_tree.

    call method cl_gui_cfw=>flush
      exceptions
        cntl_system_error = 1
        cntl_error        = 2.
    if sy-subrc ne 0.
      call function 'POPUP_TO_INFORM'
        exporting
          titel = 'Automation Queue failure'(801)
          txt1  = 'Internal error:'(802)
          txt2  = 'A method in the automation queue'(803)
          txt3  = 'caused a failure.'(804).
    endif.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form INIT_TREE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form init_tree .

* create tree control
  create object g_alv_tree
    exporting
      parent                      = go_cell_left "G_CUSTOM_CONTAINER
      node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
      item_selection              = 'X'
      no_html_header              = 'X'
      no_toolbar                  = ''
    exceptions
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      illegal_node_selection_mode = 5
      failed                      = 6
      illegal_column_name         = 7.
  if sy-subrc <> 0.
    message x208(00) with 'ERROR'.                          "#EC NOTEXT
  endif.

  data l_hierarchy_header type treev_hhdr.
  perform build_hierarchy_header changing l_hierarchy_header.

* Hide columns and sum up values initially using the fieldcatalog
  perform build_fieldcatalog_tree_alv.

* IMPORTANT: Table 'gt_sflight' must be empty. Do not change this table
* (even after this method call). You can change data of your table
* by calling methods of CL_GUI_ALV_TREE.
* Furthermore, the output table 'gt_outtab' must be global and can
* only be used for one ALV Tree Control.
  call method g_alv_tree->set_table_for_first_display
    exporting
      is_hierarchy_header = l_hierarchy_header
    changing
      it_fieldcatalog     = gt_fieldcatalog
      it_outtab           = gt_tree. "table must be empty !

* Extend funtions of standard toolbar
  perform change_toolbar.

  perform register_events.


*-- tree 구조 생성
  perform create_hierarchy.

**  perform build_layout_alv_tree.

  " 트리 표시 후 컬럼 최적화
  data:
    lv_col1   type lvc_fname,
    lv_collen type lvc_fname.

  lv_col1   = 'WAERK'.
  lv_collen = 'SALE_AMT_KRW'.
  call method g_alv_tree->column_optimize
    exporting
      i_start_column    = lv_col1
      i_end_column      = lv_collen
      i_include_heading = abap_true.

* Update calculations which were initially defined by field DO_SUM
* of the fieldcatalog. (see build_fieldcatalog).
  call method g_alv_tree->update_calculations.

* Send data to frontend.
  call method g_alv_tree->frontend_update.


endform.
*&---------------------------------------------------------------------*
*& Form BUILD_HIERARCHY_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      <--P_L_HIERARCHY_HEADER  text
*&---------------------------------------------------------------------*
form build_hierarchy_header  changing
                               p_hierarchy_header type treev_hhdr.

  p_hierarchy_header-heading = '월/판매처/프로젝트'(300).
  p_hierarchy_header-tooltip = '월별'(400).
  p_hierarchy_header-width = 45.
  p_hierarchy_header-width_pix = ''.

endform.
*&---------------------------------------------------------------------*
*& Form BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form build_fieldcatalog_tree_alv .

  data: ls_fieldcatalog type lvc_s_fcat.

* The following function module generates a fieldcatalog according
* to a given structure.
  call function 'LVC_FIELDCATALOG_MERGE'
    exporting
      i_structure_name = 'ZGTSDS0041'
    changing
      ct_fieldcat      = gt_fieldcatalog.

* Now change the fieldcatalog to hide fields and to determine
* some initial calculations for chosen fields.
  loop at gt_fieldcatalog into ls_fieldcatalog.
    case ls_fieldcatalog-fieldname.
* hide columns which are already displayed in our tree
      when 'BUKRS' or 'VKORG'.
        ls_fieldcatalog-no_out = 'X'.
      when 'WAERK'.
*        LS_FIELDCATALOG-DO_SUM = 'X'.    계획 물량은 계산해서 직접 넣어준다.
*        LS_FIELDCATALOG-H_FTYPE = 'SUM'.
        ls_fieldcatalog-coltext =
        ls_fieldcatalog-scrtext_l =
        ls_fieldcatalog-scrtext_m =
        ls_fieldcatalog-scrtext_s = '통화'.
        ls_fieldcatalog-outputlen = 20.
*        ls_fieldcatalog-hotspot   = 'X'.
        ls_fieldcatalog-col_opt   = 'X'.
      when 'SALE_AMT'.
        ls_fieldcatalog-coltext =
        ls_fieldcatalog-scrtext_l =
        ls_fieldcatalog-scrtext_m =
        ls_fieldcatalog-scrtext_s = '매출액(거래통화)'.
**        ls_fieldcatalog-do_sum    = 'X'.
**        ls_fieldcatalog-h_ftype   = 'SUM'.  total 리스트로 대체함
*        ls_fieldcatalog-hotspot   = 'X'.
        ls_fieldcatalog-col_opt   = 'X'.
      when 'SALE_AMT_KRW'.
        ls_fieldcatalog-coltext =
        ls_fieldcatalog-scrtext_l =
        ls_fieldcatalog-scrtext_m =
        ls_fieldcatalog-scrtext_s = '매출액(\)'.
**        ls_fieldcatalog-do_sum    = 'X'.
**        ls_fieldcatalog-h_ftype   = 'SUM'.  "total 리스트로 대체함
*        ls_fieldcatalog-hotspot   = 'X'.
        ls_fieldcatalog-col_opt   = 'X'.
      when 'MARGINALPROFIT_PER_R'.
        ls_fieldcatalog-coltext =   '한익률(%)_R'. "한계이익률(%)_R
        ls_fieldcatalog-scrtext_l = '한계이익률(%)_R '.
        ls_fieldcatalog-scrtext_m = '한익률(%)_R'.
        ls_fieldcatalog-scrtext_s = '한익률(%)_R'.
        ls_fieldcatalog-outputlen = 8.
        ls_fieldcatalog-col_pos   = 13.
        ls_fieldcatalog-col_opt   = 'X'.
      when 'MARGINALPROFIT_KRW_R'.
        ls_fieldcatalog-coltext =   '한익(\)_R'. "'한계이익(KRW)_R'.
        ls_fieldcatalog-scrtext_l = '한계이익(KRW)_R'.
        ls_fieldcatalog-scrtext_m = '한익(\)_R'.
        ls_fieldcatalog-scrtext_s = '한익(\)_R'.
        ls_fieldcatalog-outputlen = 8.
        ls_fieldcatalog-col_pos   = 12.
        ls_fieldcatalog-col_opt   = 'X'.
      when 'SALESPROFIT_PER_R'.
        ls_fieldcatalog-coltext =   '영익률(%)_R'.   "영업이익률(%)_R
        ls_fieldcatalog-scrtext_l = '영업이익률(%)_R'.
        ls_fieldcatalog-scrtext_m = '영익률(%)_R'.
        ls_fieldcatalog-scrtext_s = '영익률(%)_R'.
        ls_fieldcatalog-outputlen = 8.
        ls_fieldcatalog-col_pos   = 15.
        ls_fieldcatalog-col_opt   = 'X'.
      when 'SALESPROFIT_KRW_R'.
        ls_fieldcatalog-coltext =   '영익(\)_R'.  "영업이익(KRW)_R
        ls_fieldcatalog-scrtext_l = '영업이익(KRW)_R'.
        ls_fieldcatalog-scrtext_m = '영익(\)_R'.
        ls_fieldcatalog-scrtext_s = '영익(\)_R'.
        ls_fieldcatalog-outputlen = 8.
        ls_fieldcatalog-col_pos   = 14.
        ls_fieldcatalog-col_opt   = 'X'.
      when others.
        ls_fieldcatalog-no_out    = 'X'.
    endcase.
    modify gt_fieldcatalog from ls_fieldcatalog.
  endloop.

* The fieldcatalog is provided in form 'init_tree' using method
* set_table_for_first_display.

endform.
*&---------------------------------------------------------------------*
*& Form CREATE_HIERARCHY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form create_hierarchy .

* See BCALV_TREE_01 for more comments on building the hierarchy
  data: ls_main          like zgtsds0041,
        ls_old           like zgtsds0041,
        l_top_text       type lvc_value,
        lt_sflight       type sflight occurs 0,
        l_yyyymm(6)      type c,            "year and month of sflight-fldate
        l_yyyymm_last(6) type c,
        l_carrid         like sflight-carrid,
        l_carrid_last    like sflight-carrid.

  data: l_new_spmon type c,
        l_new_kunnr type c,
        l_new_zpjno type c,
        l_new_waerk type c,
        l_new_pernr type c.

  data: l_backorder_key type lvc_nkey,
        l_spmon_key     type lvc_nkey,
        l_zpjno_key     type lvc_nkey,
        l_waerk_key     type lvc_nkey,
        l_month00_key   type lvc_nkey,  "당월키
        l_week00_key    type lvc_nkey,  "당주키
        l_pernr_key     type lvc_nkey,
        l_kunnr_key     type lvc_nkey,
        l_last_key      type lvc_nkey,
        l_top_key       type lvc_nkey.
  data: lt_selected_nodes type lvc_t_nkey,
        l_selected_node   type lvc_nkey.

**  if g_alv_tree is bound.
**    g_alv_tree->delete_all_nodes( ).   " 항상 비우고 시작
**  endif.


  "-- 통화 합계용
  data: lt_tree_tot like zgtsds0041 occurs 0 with header line.

  clear: l_month00_key, l_week00_key.
  clear: gt_tree_m[], lt_tree_tot[].

  loop at gt_main.

    move-corresponding gt_main to gt_tree_m.

    "전체조회시 pernr를 사용하지 않아 clear함,
    "tree에 영업사원을 넣을으려면 수정할 것
    if p_pernr = '99999999'.
      clear: gt_tree_m-pernr, gt_tree_m-pernr_nm.
    endif.

    gt_tree_m-waerk_tx = gt_tree_m-waerk.

    clear: gt_tree_m-gubun.

*    append gt_tree_m.
    collect gt_tree_m.

  endloop.

  sort gt_tree_m by spmon kunnr_nm zptxt waerk_tx.
*  sort gt_tree_m by spmon kunnr zpjno waerk_tx.

  data ls_node_layout  type lvc_s_layn.
  data lt_item_layout  type lvc_t_layi.

  perform make_folder_hotspot  changing   ls_node_layout
                                          lt_item_layout.

* Define one top node. In this way it is possible to calculate
* values for the whole hierarchy.
  if gv_pernr_nm is not initial.
    l_top_text = gv_pernr_nm.
  else.
    l_top_text = '(담당자 없음)'.
  endif.

  call method g_alv_tree->add_node
    exporting
      i_relat_node_key = ''
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = l_top_text
      is_node_layout   = ls_node_layout
      it_item_layout   = lt_item_layout
    importing
      e_new_node_key   = l_top_key.


  clear ls_main.


* main data tree를 구성함
  clear ls_old.

  loop at gt_tree_m into ls_main.

    clear: l_new_spmon, l_new_kunnr, l_new_zpjno, l_new_waerk.

    at new spmon.
      l_new_spmon = 'X'.
    endat.
    at new kunnr.
      l_new_kunnr = 'X'.
    endat.
    at new zptxt.
      l_new_zpjno = 'X'.
    endat.
    at new waerk_tx.
      l_new_waerk = 'X'.
    endat.


    if l_new_spmon = 'X'.
* month nodes
      perform add_month using    ls_main
                                 l_top_key
                        changing l_spmon_key.
      if ls_main-spmon = gv_m00.  "당월
        l_month00_key = l_spmon_key.
      endif.
      clear l_kunnr_key.
    endif.

    if l_new_kunnr = 'X'.
* kunnr nodes
      perform add_kunnr using    ls_main
                                 l_spmon_key
                        changing l_kunnr_key.
      clear l_zpjno_key.
    endif.

    if l_new_zpjno = 'X'.
* zpjno nodes
      perform add_zpjno using    ls_main
                                 l_kunnr_key
                        changing l_zpjno_key.
      clear l_waerk_key.
    endif.

    if l_new_waerk = 'X'.
* 통화 nodes
      perform add_waerk using    ls_main
                                 l_zpjno_key
                        changing l_waerk_key.
    endif.

  endloop.

***********************************
* TOTAL tree를 구성함
  sort gt_plan_tot by spmon waerk_tx.

  move-corresponding gt_plan_tot[] to lt_tree_tot[].

  ls_main-spmon = 'TOTAL'.

  perform add_summary_tot using    ls_main
                                   l_top_key
                          changing l_spmon_key.

  loop at lt_tree_tot into ls_main
                      where waerk_tx is not initial.
    perform add_sub_tot using    ls_main
                                 l_spmon_key
                        changing l_last_key.
  endloop.


**********************************
* hotspot 속성을 directory에 반영함
  call method g_alv_tree->expand_node
    exporting
      i_node_key    = l_top_key
      i_level_count = 3.

  call method g_alv_tree->collapse_all_nodes.

***********************************
* expand first node initially
  call method g_alv_tree->expand_node
    exporting
      i_node_key    = l_top_key
      i_level_count = 0.

  gv_nkey_top = l_top_key.


* 초기 tree expand할 데이터
  data l_exp_level type i.

* 당주의 월을 expand
  if l_month00_key is not initial.
    call method g_alv_tree->expand_node
      exporting
        i_node_key    = l_month00_key
        i_level_count = 0.
  endif.

  " 화면 초기에 바로 detail을 볼수 있게 NKEY를 저장한다.
  gv_nkey_m0 = l_month00_key.

  if gv_nkey is initial.
    gv_nkey = gv_nkey_m0.
  endif.


endform.
*&---------------------------------------------------------------------*
*&      Form  add_month
*&---------------------------------------------------------------------*
form add_month  using     ps_main like zgtsds0041
                          p_relat_key type lvc_nkey
                changing  p_node_key type lvc_nkey.

  data: l_node_text type lvc_value,
        ls_main     like zgtsds0041,
        l_month(15) type c.            "output string for month
  data: lt_waerk type waerk occurs 0 with header line.

*  concatenate ps_main-spmon+0(4) '년' ps_main-spmon+4(2) '월' into l_month.
*  l_node_text = l_month.
  l_node_text = ps_main-spmon.

  "-- 금액은 미리 계산한 값을 넣어준다.
  clear gt_plan_sum.
  read table gt_plan_sum with key spmon = ps_main-spmon
                                  level = 2.
  move-corresponding ps_main to ls_main.
  ls_main-level        = 1.
  ls_main-sale_amt     = gt_plan_sum-sale_amt.
  ls_main-sale_amt_krw = gt_plan_sum-sale_amt_krw.
  ls_main-marginalprofit_per_r = gt_plan_sum-marginalprofit_per_r.
  ls_main-marginalprofit_krw_r = gt_plan_sum-marginalprofit_krw_r.
  ls_main-salesprofit_per_r    = gt_plan_sum-salesprofit_per_r.
  ls_main-salesprofit_krw_r    = gt_plan_sum-salesprofit_krw_r.

  "-- 통화가 2건 이상일 경우 합계금액은 없음
  clear lt_waerk[].
  loop at gt_plan where spmon = ls_main-spmon.
    lt_waerk = gt_plan-waerk.
    collect lt_waerk.
  endloop.
  if lines( lt_waerk ) >= 2.
    ls_main-sale_amt = 0.
    ls_main-waerk    = ''.
*    gt_plan_sum-waerk_tx = ''.
  endif.

*************
  data ls_node_layout  type lvc_s_layn.
  data lt_item_layout  type lvc_t_layi.
  clear: ls_node_layout, lt_item_layout.
  perform make_folder_hotspot  changing   ls_node_layout
                                          lt_item_layout.

************


* add node
  call method g_alv_tree->add_node
    exporting
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = l_node_text
      is_outtab_line   = ls_main
      is_node_layout   = ls_node_layout
      it_item_layout   = lt_item_layout
    importing
      e_new_node_key   = p_node_key.

endform.                               " add_month
*&---------------------------------------------------------------------*
*& Form ADD_PWEEK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_LS_MAIN_PWEEK  text
*      -->P_L_SPMON_KEY  text
*      <--P_L_PWEEK_KEY  text
*&---------------------------------------------------------------------*
form add_zpjno  using     ps_main like zgtsds0041
                           p_relat_key type lvc_nkey
                 changing  p_node_key type lvc_nkey.

  data: l_node_text type lvc_value,
        ls_main     like zgtsds0041.
  data: lt_waerk type waerk occurs 0 with header line.

* add node
  l_node_text = ps_main-zptxt.

  "-- 금액은 미리 계산한 값을 넣어준다.
  clear gt_plan_sum.
  read table gt_plan_sum with key spmon = ps_main-spmon
                                  kunnr = ps_main-kunnr
                                  zpjno = ps_main-zpjno
*                                  zptxt = ps_main-zptxt
                                  level = 4.
  move-corresponding ps_main to ls_main.
  ls_main-level        = 3.
  ls_main-sale_amt     = gt_plan_sum-sale_amt.
  ls_main-sale_amt_krw = gt_plan_sum-sale_amt_krw.
  ls_main-marginalprofit_per_r = gt_plan_sum-marginalprofit_per_r.
  ls_main-marginalprofit_krw_r = gt_plan_sum-marginalprofit_krw_r.
  ls_main-salesprofit_per_r    = gt_plan_sum-salesprofit_per_r.
  ls_main-salesprofit_krw_r    = gt_plan_sum-salesprofit_krw_r.

  "-- 통화가 2건 이상일 경우 이후 상위레벨의 합계금액은 없음
  clear lt_waerk[].
  loop at gt_plan where spmon = ls_main-spmon
                    and kunnr = ls_main-kunnr
                    and zpjno = ls_main-zpjno.
    lt_waerk = gt_plan-waerk.
    collect lt_waerk.
  endloop.
  if lines( lt_waerk ) >= 2.
    ls_main-sale_amt = 0.
    ls_main-waerk    = ''.
*    gt_plan_sum-waerk_tx = ''.
  endif.

*************
  data ls_node_layout  type lvc_s_layn.
  data lt_item_layout  type lvc_t_layi.
  clear: ls_node_layout, lt_item_layout.
  perform make_folder_hotspot  changing   ls_node_layout
                                          lt_item_layout.

************


  call method g_alv_tree->add_node
    exporting
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = l_node_text
      is_outtab_line   = ls_main
      is_node_layout   = ls_node_layout
      it_item_layout   = lt_item_layout
    importing
      e_new_node_key   = p_node_key.

endform.
*&---------------------------------------------------------------------*
*& Form ADD_PERNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_LS_MAIN_PERNR_NM  text
*      -->P_L_PERNR_KEY  text
*      <--P_L_PERNR_KEY  text
*&---------------------------------------------------------------------*
form add_pernr  using     ps_main like gt_main
                           p_relat_key type lvc_nkey
                 changing  p_node_key type lvc_nkey.

**  data: l_node_text type lvc_value,
**        ls_main     like gt_main.
**  data: ls_node_layout type lvc_s_layn.
**
*** set item-layout
**  data: lt_item_layout type lvc_t_layi,
**        ls_item_layout type lvc_s_layi.
**
**  clear: ls_node_layout, ls_item_layout, lt_item_layout.
**
***  LS_ITEM_LAYOUT-T_IMAGE  = ICON_POSITION_HR. "ICON_HR_POSITION
**  ls_item_layout-fieldname = g_alv_tree->c_hierarchy_column_name.
***  LS_ITEM_LAYOUT-STYLE   =
***                        CL_GUI_COLUMN_TREE=>STYLE_INTENSIFD_CRITICAL.
**  append ls_item_layout to lt_item_layout.
**
**  ls_node_layout-isfolder   = 'X'.   "=>add a folder, NOT a leaf
**  ls_node_layout-n_image    = icon_position_hr. "=>Display an icon
**  ls_node_layout-exp_image  = icon_position_hr. "=>Display an icon
************************************
**  ls_node_layout-expander   = 'X'.
**
**  perform make_folder_hotspot  changing   ls_node_layout
**                                          lt_item_layout.
**
*** add node
**  l_node_text =  ps_main-pernr_nm.
**
**  clear gt_plan_sum.
**  read table gt_plan_sum with key spmon = ps_main-spmon
**                                  pweek = ps_main-pweek
**                                  pernr = ps_main-pernr
**                                  level = 3.
**  move-corresponding ps_main to ls_main.
**  ls_main-level    = 3.
**  ls_main-plan_qty = gt_plan_sum-plan_qty.
**
**
**  call method g_alv_tree->add_node
**    exporting
**      i_relat_node_key = p_relat_key
**      i_relationship   = cl_gui_column_tree=>relat_last_child
**      i_node_text      = l_node_text
**      is_outtab_line   = ls_main
**      it_item_layout   = lt_item_layout
**      is_node_layout   = ls_node_layout
**    importing
**      e_new_node_key   = p_node_key.

endform.
*&---------------------------------------------------------------------*
*& Form ADD_KUNNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_LS_MAIN_PERNR_NM  text
*      -->P_L_PERNR_KEY  text
*      <--P_L_LAST_KEY  text
*&---------------------------------------------------------------------*
form add_kunnr  using     ps_main like zgtsds0041
                           p_relat_key type lvc_nkey
                 changing  p_node_key type lvc_nkey.

  data: l_node_text type lvc_value,
        ls_main     like zgtsds0041.
  data: l_layout_node type lvc_s_layn.
  data: lt_waerk type waerk occurs 0 with header line.

* add node
  l_node_text = ps_main-kunnr_nm.

  "-- 금액은 미리 계산한 값을 넣어준다.
  clear gt_plan_sum.
  read table gt_plan_sum with key spmon = ps_main-spmon
                                  kunnr = ps_main-kunnr
                                  level = 3.
  move-corresponding ps_main to ls_main.
  ls_main-level        = 2.
  ls_main-sale_amt     = gt_plan_sum-sale_amt.
  ls_main-sale_amt_krw = gt_plan_sum-sale_amt_krw.
  ls_main-marginalprofit_per_r = gt_plan_sum-marginalprofit_per_r.
  ls_main-marginalprofit_krw_r = gt_plan_sum-marginalprofit_krw_r.
  ls_main-salesprofit_per_r    = gt_plan_sum-salesprofit_per_r.
  ls_main-salesprofit_krw_r    = gt_plan_sum-salesprofit_krw_r.

  "-- 통화가 2건 이상일 경우 이후 상위레벨의 합계금액은 없음
  clear lt_waerk[].
  loop at gt_plan where spmon = ls_main-spmon
                    and kunnr = ls_main-kunnr.
    lt_waerk = gt_plan-waerk.
    collect lt_waerk.
  endloop.
  if lines( lt_waerk ) >= 2.
    ls_main-sale_amt = 0.
    ls_main-waerk    = ''.
*    gt_plan_sum-waerk_tx = ''.
  endif.

*************
  data ls_node_layout  type lvc_s_layn.
  data lt_item_layout  type lvc_t_layi.
  clear: ls_node_layout, lt_item_layout.
  perform make_folder_hotspot  changing   ls_node_layout
                                          lt_item_layout.

************


  call method g_alv_tree->add_node
    exporting
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = l_node_text
      is_outtab_line   = ls_main
      it_item_layout   = lt_item_layout
      is_node_layout   = l_layout_node
    importing
      e_new_node_key   = p_node_key.

endform.
*&---------------------------------------------------------------------*
*& Form ADD_KUNNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_LS_MAIN_PERNR_NM  text
*      -->P_L_PERNR_KEY  text
*      <--P_L_LAST_KEY  text
*&---------------------------------------------------------------------*
form add_waerk  using     ps_main like zgtsds0041
                           p_relat_key type lvc_nkey
                 changing  p_node_key type lvc_nkey.

  data: l_node_text type lvc_value,
        ls_main     like zgtsds0041.

* add node
  l_node_text = ps_main-waerk.

  "-- 금액은 미리 계산한 값을 넣어준다.
  clear gt_plan_sum.
  read table gt_plan_sum with key spmon = ps_main-spmon
                                  kunnr = ps_main-kunnr
                                  zpjno = ps_main-zpjno
                                  waerk_tx = ps_main-waerk_tx
                                  level = 5.
  move-corresponding ps_main to ls_main.
  ls_main-level        = 4.
  ls_main-sale_amt     = gt_plan_sum-sale_amt.
  ls_main-sale_amt_krw = gt_plan_sum-sale_amt_krw.
  ls_main-marginalprofit_per_r = gt_plan_sum-marginalprofit_per_r.
  ls_main-marginalprofit_krw_r = gt_plan_sum-marginalprofit_krw_r.
  ls_main-salesprofit_per_r    = gt_plan_sum-salesprofit_per_r.
  ls_main-salesprofit_krw_r    = gt_plan_sum-salesprofit_krw_r.

*************
  data ls_node_layout  type lvc_s_layn.
  data lt_item_layout  type lvc_t_layi.
  clear: ls_node_layout, lt_item_layout.
  perform make_folder_hotspot  changing   ls_node_layout
                                          lt_item_layout.

************


  call method g_alv_tree->add_node
    exporting
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = l_node_text
      is_outtab_line   = ls_main
      is_node_layout   = ls_node_layout
      it_item_layout   = lt_item_layout
    importing
      e_new_node_key   = p_node_key.

endform.
*&---------------------------------------------------------------------*
*& Form CHANGE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form change_toolbar .

* §1.Get toolbar instance of your ALV Tree.
* When you instantiate an instance of CL_GUI_ALV_TREE the constructor
* of the base class (CL_ALV_TREE_BASE) creates a toolbar.
* Fetch its reference with the following method if you want to
* modify it:
  call method g_alv_tree->get_toolbar_object
    importing
      er_toolbar = g_toolbar.

  check not g_toolbar is initial. "could happen if you do not use the
  "standard toolbar

* §2.Modify toolbar with methods of CL_GUI_TOOLBAR:
* add seperator to toolbar
  call method g_toolbar->add_button
    exporting
      fcode     = ''
      icon      = ''
      butn_type = cntb_btype_sep.

** add Standard Button to toolbar (for refresh)
*  call method g_toolbar->add_button
*    exporting
*      fcode     = 'REFR'
*      icon      = '@42@'
*      butn_type = cntb_btype_button
*      text      = 'Refresh'
*      quickinfo = 'Refresh'.   "Refresh

** add Standard Button to toolbar (for 주문생성)
*  call method g_toolbar->add_button
*    exporting
*      fcode     = 'CRTE'
*      icon      = '@15@'
*      butn_type = cntb_btype_button
*      text      = '주문생성'
*      quickinfo = '주문생성'.   "주문생성


endform.

*--------------------------------------------------------------------
form register_events.

  data: lt_events        type cntl_simple_events,
        l_event          type cntl_simple_event,
        l_event_receiver type ref to lcl_toolbar_event_receiver.

* Frontend registration: do not forget to register (for ALV Tree
* mandatory) tree events.

*................................................................
* Tree events:
* The following four tree events registers ALV Tree in the constructor
* method itself.
*    - cl_gui_column_tree=>eventid_expand_no_children
* (needed to load data to frontend when a user expands a node)
*    - cl_gui_column_tree=>eventid_header_context_men_req
* (needed for header context menu)
*    - cl_gui_column_tree=>eventid_header_click
* (allows selection of columns (only when item selection activated))
*   - cl_gui_column_tree=>eventid_item_keypress
* (needed for F1-Help (only when item selection activated))
*
* Nevertheless you have to provide their IDs again if you register
* additional events with SET_REGISTERED_EVENTS (see below).
* To do so, call first method  GET_REGISTERED_EVENTS (this way,
* all already registered events remain registered, even your own):
  call method g_alv_tree->get_registered_events
    importing
      events = lt_events.

* (If you do not these events will be deregistered!!!).
* You do not have to register events of the toolbar again.
*
* Toolbar events:
* Note that the instance of your ALV Tree Control registers the toolbar
* events on frontend as application events (within the constructor).
* You do not have to register events of the toolbar again.

*§4b. Frontend registration(ii): add additional event ids
  l_event-eventid = cl_gui_column_tree=>eventid_node_double_click.
  append l_event to lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_item_double_click.
  append l_event to lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_link_click.
  append l_event to lt_events.

* register events on frontend
  call method g_alv_tree->set_registered_events
    exporting
      events                    = lt_events
    exceptions
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3.
  if sy-subrc <> 0.
    message x208(00) with 'ERROR'.                          "#EC NOTEXT
  endif.
*-------------------------------------------------------------------
* §6. Register toolbar events on backend (ABAP Objects
*     event handling).
* Note that the instance of your ALV Tree Control registers the toolbar
* events on frontend as application events (within the constructor).
  create object l_event_receiver.
  set handler l_event_receiver->on_function_selected for g_toolbar.

  set handler l_event_receiver->handle_node_double_click for g_alv_tree.
  set handler l_event_receiver->handle_item_double_click for g_alv_tree.
  set handler l_event_receiver->handle_link_click        for g_alv_tree.

endform.                               " register_events

*&---------------------------------------------------------------------*
*& Form CHANGE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form change_toolbar_alv2 .

*  append cl_gui_alv_grid=>mc_fc_excl_all to gt_excl_func.

*  append cl_gui_alv_grid=>mc_fc_select_all to gt_excl_func.
*  append cl_gui_alv_grid=>mc_fc_deselect_all to gt_excl_func.


*** §1.Get toolbar instance of your ALV Tree.
*** When you instantiate an instance of CL_GUI_ALV_TREE the constructor
*** of the base class (CL_ALV_TREE_BASE) creates a toolbar.
*** Fetch its reference with the following method if you want to
*** modify it:
**  CALL METHOD GO_GRID2->GET_TOOLBAR_OBJECT
**    IMPORTING
**      ER_TOOLBAR = GO_TOOLBAR.
**
**  CHECK NOT G_TOOLBAR IS INITIAL. "could happen if you do not use the
**  "standard toolbar
**
*** §2.Modify toolbar with methods of CL_GUI_TOOLBAR:
*** add seperator to toolbar
**  CALL METHOD G_TOOLBAR->ADD_BUTTON
**    EXPORTING
**      FCODE     = ''
**      ICON      = ''
**      BUTN_TYPE = CNTB_BTYPE_SEP.
**
*** add Standard Button to toolbar (for Delete Subtree)
**  CALL METHOD G_TOOLBAR->ADD_BUTTON
**    EXPORTING
**      FCODE     = 'CRTE'
**      ICON      = '@15@'
**      BUTN_TYPE = CNTB_BTYPE_BUTTON
**      TEXT      = '주문생성'
**      QUICKINFO = '주문생성'.   "주문생성

endform.
*&---------------------------------------------------------------------*
*& Form GRID2_EVENT_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_E_OBJECT  text
*      -->P_E_INTERACTIVE  text
*&---------------------------------------------------------------------*
form grid2_event_toolbar  using e_object
                                   type ref to cl_alv_event_toolbar_set
                               e_interactive type char1.    "#EC *

  data: ls_toolbar type stb_button.

  "-- 전체 조회시에는 수정불가함
  if p_pernr = '99999999'.
    exit.
  endif.

*...Seperator
  ls_toolbar-function  = 'DUMMY'.
  ls_toolbar-butn_type = '3'.
  append ls_toolbar to e_object->mt_toolbar.

*... Normal Button
  clear ls_toolbar.
  ls_toolbar-function  = 'UPDMON'.
  ls_toolbar-icon      = icon_mass_change.
  ls_toolbar-butn_type = '0'.
  ls_toolbar-disabled  = space.
  ls_toolbar-text      = '매출일 변경(일괄)'.                      "#EC NOTEXT
  ls_toolbar-quickinfo = space.
  ls_toolbar-checked   = space.
  append ls_toolbar to e_object->mt_toolbar.

*...Seperator
  ls_toolbar-function  = 'DUMMY'.
  ls_toolbar-butn_type = '3'.
  append ls_toolbar to e_object->mt_toolbar.

*... Normal Button
  clear ls_toolbar.
  ls_toolbar-function  = 'SPLIT'.                           "#EC NOTEXT
  ls_toolbar-icon      = icon_annotation.
  ls_toolbar-butn_type = '0'.
  ls_toolbar-disabled  = space.
  ls_toolbar-text      = '분  할'.                            "#EC NOTEXT
  ls_toolbar-quickinfo = space.
  ls_toolbar-checked   = space.
  append ls_toolbar to e_object->mt_toolbar.

*...Seperator
  ls_toolbar-function  = 'DUMMY'.
  ls_toolbar-butn_type = '3'.
  append ls_toolbar to e_object->mt_toolbar.

  clear ls_toolbar.
  ls_toolbar-function  = 'WISH'.                            "#EC NOTEXT
  ls_toolbar-icon      = icon_intensify.
  ls_toolbar-butn_type = '0'.
  ls_toolbar-disabled  = space.
  ls_toolbar-text      = '의지치'.                             "#EC NOTEXT
  ls_toolbar-quickinfo = space.
  ls_toolbar-checked   = space.
  append ls_toolbar to e_object->mt_toolbar.

*...Seperator
  ls_toolbar-function  = 'DUMMY'.
  ls_toolbar-butn_type = '3'.
  append ls_toolbar to e_object->mt_toolbar.

  " 전체 선택 버튼 추가
  clear ls_toolbar.
  ls_toolbar-function = 'SELALL'.
  ls_toolbar-icon     = icon_select_all.
  ls_toolbar-butn_type = '0'.
  ls_toolbar-text     = '전체선택(행삭제)'.
  append ls_toolbar to e_object->mt_toolbar.

  " 전체 해제 버튼 추가
  clear ls_toolbar.
  ls_toolbar-function = 'DESELALL'.
  ls_toolbar-icon     = icon_deselect_all.
  ls_toolbar-butn_type = '0'.
  ls_toolbar-text     = '전체해제'.
  append ls_toolbar to e_object->mt_toolbar.

*...Seperator
  ls_toolbar-function  = 'DUMMY'.
  ls_toolbar-butn_type = '3'.
  append ls_toolbar to e_object->mt_toolbar.

  ls_toolbar-function  = 'DELROW'.                          "#EC NOTEXT
  ls_toolbar-icon      = icon_delete_row.
  ls_toolbar-butn_type = '0'.
  ls_toolbar-disabled  = space.
  ls_toolbar-text      = '행삭제'.                             "#EC NOTEXT
  ls_toolbar-quickinfo = '행삭제'.
  ls_toolbar-checked   = space.
  append ls_toolbar to e_object->mt_toolbar.


endform.
*&---------------------------------------------------------------------*
*& Form GRID2_EVENT_UCOMM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*&---------------------------------------------------------------------*
form grid2_event_ucomm  using e_ucomm like sy-ucomm.        "#EC *

  data: l_edit type i.
  data: l_rc       type c,
        l_msg(200) type c,
        l_err      type c.
  data: l_bukrs type bukrs.
  data: lt_rows  type lvc_t_row,
        ls_row   type lvc_s_row,
        ls_roid  type lvc_s_roid,
        lt_roids type lvc_t_roid.
  data : begin of lt_detl occurs 0. "우측의 ALV용 데이터
           include structure zgtsds0042.
  data : "FIELD_STYLE TYPE LVC_T_STYL,
         end of lt_detl.


  case e_ucomm.

    when 'UPDMON'.   "매출일 변경(일괄)

      call method go_grid2->get_selected_rows
        importing
          et_index_rows = lt_rows
          et_row_no     = lt_roids.
      if lt_rows is initial.
        message s001(00) with '작업할 행을 선택하세요.' display like 'E'.
        return.
      endif.

      loop at lt_rows into ls_row.
        read table gt_detail into gs_detail index ls_row-index.
        if sy-subrc = 0.
          if gs_detail-bltype = 'B'.
            message s001(00) with '매출일 변경(일괄)이 불가능한 유형을 선택하였습니다.'
                    display like 'E'.
            return.
          else.
            append gs_detail to lt_detl.
          endif.
        endif.
      endloop.

      check lt_detl[] is not initial.

      call function 'POPUP_TO_CONFIRM_STEP'
        exporting
          textline1      = '선택한 Lines의 매출일 변경(일괄)하겠습니까?'
*         textline2      = gv_vbeln_new
          titel          = 'Confirmation'(904)
          cancel_display = 'X'
          start_column   = c_90
*         start_row      = 20
        importing
          answer         = l_rc.
      if l_rc <> 'J'.
        return.
      endif.

      "-- 400 화면
      data: lv_sale_date like sy-datum,
            lv_month     like isellist-month.

      perform get_month_by_popup  changing  lv_month.

      if lv_month is initial.
        exit.
      endif.

      if lv_month < gv_bdate(6).

        message s001(00) with '매출월은 ' gv_bdate(6) '월 이후만 입력 가능합니다.'
                display like 'E'.
        exit.
      endif.

      lv_sale_date = lv_month && '01'.

      call function 'BKK_GET_MONTH_LASTDAY'
        exporting
          i_date = lv_sale_date
        importing
          e_date = lv_sale_date.


      "-- 의지치일자가 변경된후 중복을 미리 체크함
      perform check_duplicate_data   tables   lt_detl
                                     using    lv_sale_date
                                     changing l_err l_msg.
      if l_err = 'X'.
        message s001(00) with l_msg display like 'E'.
        exit.
      endif.

      loop at lt_detl.

        read table gt_main into gs_main with key keyfd = lt_detl-keyfd.

        check sy-subrc = 0.

        case lt_detl-bltype.
          when 'A'. "의지치 수정
            read table gt_027_upd assigning field-symbol(<fd_27>)
                                              with key vkbur = p_vkbur
                                                       pernr = p_pernr
                                                       spmon = gs_main-spmon
                                                       fkdat = gs_main-sale_date
                                                       kunnr = gs_main-kunnr
                                                       zpjno = gs_main-zpjno
                                                       prodh = gs_main-prodh
                                                       matnr = gs_main-matnr.
            if sy-subrc = 0.
              <fd_27>-spmon = lv_sale_date(6).
              <fd_27>-fkdat = lv_sale_date.
            else.
              read table gt_027 into gs_027 with key vkbur = p_vkbur
                                                      pernr = p_pernr
                                                      spmon = gs_main-spmon
                                                      fkdat = gs_main-sale_date
                                                      kunnr = gs_main-kunnr
                                                      zpjno = gs_main-zpjno
                                                      prodh = gs_main-prodh
                                                      matnr = gs_main-matnr.
              if sy-subrc = 0.
                delete gt_027 index sy-tabix.
                append gs_027 to gt_027_del.

                gs_027-spmon = lv_sale_date(6).
                gs_027-fkdat = lv_sale_date.
                append gs_027 to gt_027_upd.
              endif.
            endif.

          when 'F' or 'G' or 'H'. "분할용
            read table gt_026_upd assigning field-symbol(<fd_026>)
                                                with key vbeln_va = gs_main-vbeln_va
                                                         posnr_va = gs_main-posnr_va
                                                         seqno    = gs_main-seqno
                                                         vbeln_vl = gs_main-vbeln_vl
                                                         posnr_vl = gs_main-posnr_vl.
            if sy-subrc = 0.
              <fd_026>-bldat = lv_sale_date.
            else.
              read table gt_026 into gs_026     with key vbeln_va = gs_main-vbeln_va
                                                         posnr_va = gs_main-posnr_va
                                                         seqno    = gs_main-seqno
                                                         vbeln_vl = gs_main-vbeln_vl
                                                         posnr_vl = gs_main-posnr_vl.
              if sy-subrc = 0.
                delete gt_026 index sy-tabix.
                append gs_026 to gt_026_del.

                gs_026-bldat = lv_sale_date.
                append gs_026 to gt_026_upd.
              endif.
            endif.

          when others. "다른 모든 것도 26 table에 넣어준다.

            read table gt_026_upd assigning <fd_026>
                                                with key vbeln_va = gs_main-vbeln_va
                                                         posnr_va = gs_main-posnr_va
                                                         seqno    = gs_main-seqno
                                                         vbeln_vl = gs_main-vbeln_vl
                                                         posnr_vl = gs_main-posnr_vl.
            if sy-subrc = 0.
              <fd_026>-bldat = lv_sale_date.
            else.
              read table gt_026 into gs_026     with key vbeln_va = gs_main-vbeln_va
                                                         posnr_va = gs_main-posnr_va
                                                         seqno    = gs_main-seqno
                                                         vbeln_vl = gs_main-vbeln_vl
                                                         posnr_vl = gs_main-posnr_vl.
              if sy-subrc = 0.
                delete gt_026 index sy-tabix.
                append gs_026 to gt_026_del.

                gs_026-bldat = lv_sale_date.
                append gs_026 to gt_026_upd.
              else.
                clear gs_026.
                gs_026-vbeln_va = gs_main-vbeln_va.
                gs_026-posnr_va = gs_main-posnr_va.
                gs_026-seqno    = gs_main-seqno.
                gs_026-vbeln_vl = gs_main-vbeln_vl.
                gs_026-posnr_vl = gs_main-posnr_vl.
                gs_026-excep    = ''.
                gs_026-vrkme    = gs_main-vrkme.
                gs_026-kwmeng   = gs_main-kwmeng.
                gs_026-lfimg    = gs_main-lfimg.
                gs_026-gidat    = gs_main-gidat.
                gs_026-bldat    = lv_sale_date.
                gs_026-plqty    = gs_main-sale_qty.
                gs_026-waerk    = gs_main-waerk.
                gs_026-netwr    = gs_main-netwr_so * gs_026-plqty / gs_026-kwmeng.
                gs_026-remark   = ''.
                gs_026-ernam    = sy-uname.
                gs_026-erdat    = sy-datum.
                gs_026-erzet    = sy-uzeit.
                gs_026-aenam    = sy-uname.
                gs_026-aedat    = sy-datum.
                gs_026-aezet    = sy-uzeit.

                append gs_026 to gt_026_upd.
              endif.
            endif.

        endcase.

        gs_main-spmon     = lv_sale_date(6).
        gs_main-sale_date = lv_sale_date.

        perform calc_exchange_currency  changing gs_main.

        modify gt_main from gs_main transporting spmon sale_date kursf sale_amt_krw
                       where keyfd = lt_detl-keyfd.

      endloop.


      perform get_plan_data . "Tree 구성용 데이터

      "--- Tree 데이터를 새롭게 구성하고 보여준다.
      call method g_alv_tree->free.
      clear: g_alv_tree.

      perform create_tree .

      perform get_item_detail using gv_nkey  c_so.
      perform display_sub_grid.


    when 'SELALL'.   "전체 선택
      loop at gt_detail.
        ls_row-index = sy-tabix.
        if gt_detail-bltype = 'A' or
           gt_detail-bltype = 'F' or
           gt_detail-bltype = 'G' or
           gt_detail-bltype = 'H'.
          append ls_row to lt_rows.
        endif.
      endloop.

      loop at lt_rows into ls_row.
        clear ls_roid.
        ls_roid-row_id = ls_row-index.  " 간단 매핑
        append ls_roid to lt_roids.
      endloop.

      if lt_roids is not initial.
        go_grid2->set_selected_rows( it_row_no = lt_roids ).
      endif.


      call method go_grid2->set_selected_rows
        exporting
          it_index_rows = lt_rows.

      data(lv_lines) = lines( lt_rows ).

      if lv_lines = 0.
        message s001(00) with '선택된 라인이 없습니다.' display like 'E'.
      else.
        message s001(00) with lv_lines && '라인이 선택되었습니다.'.
      endif.

**      "- 아래는 display_sub_grid에서 처리함
*
**        call method cl_gui_control=>set_focus
**          exporting
**            control = go_grid2.
**      call method cl_gui_cfw=>flush. " GUI와 상태 동기화

    when 'DESELALL'. "전체 미선택

      data: lt_void type lvc_t_row. " 빈 테이블
      call method go_grid2->set_selected_rows
        exporting
          it_index_rows = lt_void.

    when 'SPLIT'. "분할 popup

      call method go_grid2->get_selected_rows
        importing
          et_index_rows = lt_rows
          et_row_no     = lt_roids.
      if lt_rows is initial.
        message s001(00) with '작업할 행을 선택하세요.' display like 'E'.
        return.
      endif.
      if lines( lt_rows ) > 1.
        message s001(00) with '1개 라인만 선택하시기 바랍니다.' display like 'E'.
        return.
      endif.

      read table lt_rows into ls_row index 1.
      check sy-subrc = 0.

      read table gt_detail into gs_detail index ls_row-index.
      check sy-subrc = 0.

      "--  [분할]이 가능한 유형 = (미출하 또는 출하진행 또는 출고)
      if gs_detail-bltype = 'C' or gs_detail-bltype = 'F' or
         gs_detail-bltype = 'D' or gs_detail-bltype = 'G' or
         gs_detail-bltype = 'E' or gs_detail-bltype = 'H'.
      else.
        message s001(00) with '분할이 불가능한 유형을 선택하였습니다.' display like 'E'.
        return.
      endif.

      call function 'POPUP_TO_CONFIRM_STEP'
        exporting
          textline1      = '선택한 Line에 대해 분할 작업을 하겠습니까?'(902)
*         textline2      = gv_vbeln_new
          titel          = 'Confirmation'(904)
          cancel_display = 'X'
          start_column   = c_90
*         start_row      = 20
        importing
          answer         = l_rc.
      if l_rc <> 'J'.
        return.
      endif.

      "-- 200헤더 데이터
      move-corresponding gs_detail to gs_200.
      "-- 200 item 데이터
      "-- origial = gt_026
      "-- update  = gt_026_upd
      "-- delete  = gt_026_del
      data ls_026 like zsdt_d365_026.

      refresh gt_list_200.
      loop at gt_026_upd where vbeln_va = gs_200-vbeln_va
                           and posnr_va = gs_200-posnr_va
                           and seqno    = gs_200-seqno
                           and vbeln_vl = gs_200-vbeln_vl
                           and posnr_vl = gs_200-posnr_vl.
        move-corresponding gt_026_upd to gt_list_200.
        append gt_list_200.
      endloop.
      if sy-subrc = 0.
      else.
        loop at gt_026 assigning field-symbol(<f26>)
                        where vbeln_va = gs_200-vbeln_va
                          and posnr_va = gs_200-posnr_va
                          and seqno    = gs_200-seqno
                          and vbeln_vl = gs_200-vbeln_vl
                          and posnr_vl = gs_200-posnr_vl.
          move-corresponding <f26> to gt_list_200.
          append gt_list_200.
        endloop.

      endif.

      data : ls_style type lvc_s_styl.

      loop at gt_list_200.

        ls_style-style     = cl_gui_alv_grid=>mc_style_enabled. " 활성화

        ls_style-fieldname = 'BLDAT'.
        insert ls_style into table gt_list_200-field_style.
        ls_style-fieldname = 'PLQTY'.
        insert ls_style into table gt_list_200-field_style.
        ls_style-fieldname = 'REMARK'.
        insert ls_style into table gt_list_200-field_style.

        modify gt_list_200.

      endloop.

      sort gt_list_200 by bldat seqno.

      call screen '200' starting at 50 5. " ENDING AT 50 30.


    when 'WISH'.  "의지치 popup

      if s_vbeln[] is not initial.
        message s001(00) with '초기화면에서 주문번호를 입력하면 의지치 관리는 불가합니다.' display like 'E'.
        return.
      endif.

      call function 'POPUP_TO_CONFIRM_STEP'
        exporting
*         defaultoption  = '2'
          textline1      = '의지치를 입력하겠습니까?'(902)
          titel          = 'Confirmation'(904)
          cancel_display = 'X'
          start_column   = c_90
*         start_row      = 20
        importing
          answer         = l_rc.
      if l_rc <> 'J'.
        return.
      endif.


      "-- 300헤더 데이터
      move-corresponding gs_detail to gs_300.
      "-- 300 item 데이터
      "-- origial = gt_027
      "-- update  = gt_027_upd
      "-- delete  = gt_027_del
      data ls_027 like zsdt_d365_027.

      refresh gt_list_300.

      loop at gt_027 into ls_027.
        move-corresponding ls_027 to gt_list_300.
        if gt_list_300-spmon is initial and gt_list_300-fkdat is not initial.
          gt_list_300-spmon = gt_list_300-fkdat(6).
        endif.

        perform get_prodh_name  using    gt_list_300-prodh
                                changing gt_list_300-prodh_nm.
        perform get_matnr_text  using    gt_list_300-matnr
                                changing gt_list_300-matnr_nm.
*        perform get_matnr_meins using    gt_list_300-matnr
*                                changing gt_list_300-vrkme.
        perform get_kunnr_name  using    gt_list_300-kunnr
                                changing gt_list_300-kunnr_nm.
        perform get_zpjno_name  using    gt_list_300-zpjno
                                changing gt_list_300-zptxt.
        append gt_list_300.
      endloop.

      if sy-subrc <> 0.
        loop at gt_027_upd.
          move-corresponding gt_027_upd to gt_list_300.

          perform get_prodh_name  using    gt_list_300-prodh
                                  changing gt_list_300-prodh_nm.
          perform get_matnr_text  using    gt_list_300-matnr
                                  changing gt_list_300-matnr_nm.
*          perform get_matnr_meins using    gt_list_300-matnr
*                                  changing gt_list_300-vrkme.
          perform get_kunnr_name  using    gt_list_300-kunnr
                                  changing gt_list_300-kunnr_nm.
          perform get_zpjno_name  using    gt_list_300-zpjno
                                  changing gt_list_300-zptxt.
          append gt_list_300.
        endloop.
      endif.

      "-- 필드 편집 가능하게....
      loop at gt_list_300.

        ls_style-style     = cl_gui_alv_grid=>mc_style_enabled. " 활성화

        ls_style-fieldname = 'SPMON'.
        insert ls_style into table gt_list_300-field_style.
        ls_style-fieldname = 'KUNNR'.
        insert ls_style into table gt_list_300-field_style.
        ls_style-fieldname = 'ZPJNO'.
        insert ls_style into table gt_list_300-field_style.
        ls_style-fieldname = 'PRODH'.
        insert ls_style into table gt_list_300-field_style.
        ls_style-fieldname = 'MATNR'.
        insert ls_style into table gt_list_300-field_style.
*        ls_style-fieldname = 'UNITPRICE_KRW'.
*        insert ls_style into table gt_list_300-field_style.
*        ls_style-fieldname = 'QUANTITY'.
*        insert ls_style into table gt_list_300-field_style.
*        ls_style-fieldname = 'VRKME'.
*        insert ls_style into table gt_list_300-field_style.
        ls_style-fieldname = 'AMOUNT_KRW'.
        insert ls_style into table gt_list_300-field_style.
        ls_style-fieldname = 'MARGINALPROFIT_PER'.
        insert ls_style into table gt_list_300-field_style.
        ls_style-fieldname = 'REMARK'.
        insert ls_style into table gt_list_300-field_style.

        modify gt_list_300.

      endloop.

      sort gt_list_300 by fkdat kunnr.

      clear gt_300_origin[].
      move-corresponding gt_list_300[] to gt_300_origin[].

      call screen '300' starting at 10 5. " ENDING AT 50 30.

    when 'DISP'.

**--  라인을 선택한 경우
      call method go_grid2->get_selected_rows
        importing
          et_index_rows = lt_rows
          et_row_no     = lt_roids.

    when 'DELROW'.

      "편집 중 값 반영
      go_grid2->check_changed_data( ).

      "선택행 가져오기
      clear: lt_rows, lt_roids.
      go_grid2->get_selected_rows(
        importing
          et_index_rows = lt_rows
          et_row_no     = lt_roids ).


      if lt_rows is initial.
        message s001(00) with '삭제할 행을 선택하세요.' display like 'E'.
        return.
      endif.

      call function 'POPUP_TO_CONFIRM_STEP'
        exporting
          textline1      = '선택한 Lines을 삭제하겠습니까?'(902)
*         textline2      = gv_vbeln_new
          titel          = 'Confirmation'(904)
          cancel_display = 'X'
          start_column   = c_90
        importing
          answer         = l_rc.
      if l_rc <> 'J'.
        return.
      endif.

      "내림차순 삭제(인덱스 밀림 방지)
      sort lt_rows by index descending.

      clear l_err.

      loop at lt_rows into ls_row.

        read table gt_detail index ls_row-index.
        check sy-subrc = 0.

        if gt_detail-bltype = 'F' or
           gt_detail-bltype = 'G' or
           gt_detail-bltype = 'H' or
           gt_detail-bltype = 'A'.
        else.
          message s001(00) with '삭제가 불가능한 유형을 선택하였습니다.' display like 'E'.
          l_err = 'X'.
          exit.
        endif.
      endloop.

      check l_err = ''.

      loop at lt_rows into ls_row.

        read table gt_detail index ls_row-index.
        if sy-subrc = 0.

          if gt_detail-bltype = 'F' or
             gt_detail-bltype = 'G' or
             gt_detail-bltype = 'H' or
             gt_detail-bltype = 'A'.

            delete gt_detail index ls_row-index.

            if gt_detail-bltype = 'A'.
              clear gt_027_del.
              gt_027_del-vkbur = p_vkbur.
              gt_027_del-pernr = p_pernr.
              gt_027_del-spmon = gt_detail-spmon.
              gt_027_del-fkdat = gt_detail-sale_date.
              gt_027_del-kunnr = gt_detail-kunnr.
              gt_027_del-zpjno = gt_detail-zpjno.
              gt_027_del-prodh = gt_detail-prodh.
              gt_027_del-matnr = gt_detail-matnr.
              append gt_027_del.
            else.
              if gt_detail-seqno > 0.
                clear gt_026_del.
                gt_026_del-vbeln_va = gt_detail-vbeln_va.
                gt_026_del-posnr_va = gt_detail-posnr_va.
                gt_026_del-seqno    = gt_detail-seqno.
                gt_026_del-vbeln_vl = gt_detail-vbeln_vl.
                gt_026_del-posnr_vl = gt_detail-posnr_vl.
                append gt_026_del.
              endif.
            endif.

            delete gt_main where keyfd = gt_detail-keyfd.

*            perform update_main_by_order using gt_detail-vbeln_va
*                                               gt_detail-posnr_va.

          endif.

        endif.
      endloop.

      "-- Tree와 main list에도 반영함
      perform refresh_main_list.

    when others.
  endcase.

endform.
*&---------------------------------------------------------------------*
*& Form SET_INIT_CLEAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_init_and_clear .

  data : lv_week like scal-week,
         lv_date like sy-datum,
         lv_mons like t5a4a-dlymo.


  clear: gr_abgru, gr_abgru[],
         gt_so,    gt_so[],
         gt_do,    gt_do[],
         gt_bl,    gt_bl[],
         gt_021,   gt_021[],
         gt_026,   gt_026[],
         gt_027,   gt_027[],
         gt_main,  gt_main[],
         gt_plan,  gt_plan[],
         gt_sales,    gt_sales[],
         gt_detail,   gt_detail[],
         gt_plan_sum, gt_plan_sum[],
         gt_plan_tot, gt_plan_tot[].
  clear: gt_021_del[], gt_026_del[], gt_027_del[],
         gt_021_upd[], gt_026_upd[], gt_027_upd[].
  clear: gv_nkey, gv_err.

  refresh : gr_so_pernr, gr_pernr.

  "-- 거부사유 체크
  gr_abgru-sign   = 'I'.
  gr_abgru-option = 'EQ'.
  gr_abgru-low    = '  '.
  append gr_abgru.

  set_range gr_abgru '94'.
  set_range gr_abgru '95'.
  set_range gr_abgru '96'.
  set_range gr_abgru 'Z1'.
  set_range gr_abgru 'Z2'.

  "-- 조회 기준월
  perform set_base_date.

  "-- 영업용 담당자
  gv_so_pernr = 'E' && p_pernr.

  if p_pernr = '99999999' or p_pernr is initial.
    "전체 데이터를 조회하는 경우
  else.
    set_range gr_so_pernr gv_so_pernr. "영업오더의 영업사원
    set_range gr_pernr    p_pernr.     "영업사원의 사번
  endif.

  if p_pernr = '99999999' or p_pernr is initial.
*    gv_pernr_nm = '전체 사원'.
    select single bezei into gv_pernr_nm
      from tvkbt where vkbur = p_vkbur
                   and spras = sy-langu.
  else.
    select single name1 into gv_pernr_nm
      from lfa1 where lifnr = gv_so_pernr.
  endif.

  "-- GRADE 등급
  call function 'CONVERSION_EXIT_ATINN_INPUT'
    exporting
      input  = 'ZBT_AA_GRADE'
    importing
      output = gv_atinn.

  "-- 당일의 주차
  call function 'GET_WEEK_INFO_BASED_ON_DATE'
    exporting
      date   = gv_bdate
    importing
      week   = lv_week
      monday = gv_week_monday
      sunday = gv_week_sunday.

  gv_bweek      = lv_week.           "오늘의 주차
  gv_week_month = gv_week_monday(6). "현재 주차의 월요일이 속한 월 20/21 table에 사용함

  call function 'WEEK_GET_FIRST_DAY'
    exporting
      week         = lv_week
    importing
      date         = lv_date
    exceptions
      week_invalid = 1
      others       = 2.
  if sy-subrc <> 0.
* Implement suitable error handling here
  endif.

*-- 당주 월요일과 전주 일요입
  gv_w00_monday = lv_date.
  gv_wp1_sunday = gv_w00_monday - 1.

*-- 당월
  gv_m00 = gv_bdate(6).
  perform get_next_month    using    gv_m00  '1'
                            changing gv_m01.
  perform get_next_month    using    gv_m01  '1'
                            changing gv_m02.
  perform get_next_month    using    gv_m02  '1'
                            changing gv_m03.


  call function 'BKK_GET_MONTH_LASTDAY'
    exporting
      i_date = lv_date
    importing
      e_date = gv_last_day.

  if gv_m00 = gv_bdate(6).
    gv_1st_edatu  = gv_bdate.
  else.
    "지난달 말일
    gv_1st_edatu  = gv_bdate(6) && '01'.
    gv_1st_edatu  = gv_1st_edatu  - 1.
  endif.

  select  single land1 a~waers a~bukrs
    into ( gv_land1, gv_waers, gv_bukrs )
    from  t001 as a join tvko as b on a~bukrs = b~bukrs
                             join tvkbz as c on b~vkorg = c~vkorg
    where c~vkbur = p_vkbur.

  "-- bltype의 ddname 가져오기
  select 1          as handle,
         domvalue_l as int_value,
         domvalue_l && ' ' && ddtext  as value
    into corresponding fields of table @gt_dbltype
    from dd07t
   where domname    = 'ZGTD_BLTYPE'
     and ddlanguage = @sy-langu.

  "---------------------------------------
  "-- 환율 가져오기
  "---------------------------------------
  perform get_exc_currency    tables gt_1300t.


endform.
*&---------------------------------------------------------------------*
*& Form GET_WEEK_BY_DATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_LV_DATE  text
*      <--P_GT_SO_PWEEK  text
*&---------------------------------------------------------------------*
form get_week_by_date  using    pv_date
                       changing pv_week.

  data: lv_date like sy-datum,
        lv_week like scal-week.

  lv_date = pv_date.

  call function 'HRIQ_DATE_GET_WEEK'
    exporting
      date         = lv_date
    importing
      week         = lv_week
    exceptions
      date_invalid = 1
      others       = 2.
  if sy-subrc = 0.
    pv_week = lv_week.
  else.
* Implement suitable error handling here
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form add_main_list   tables   pt_so   type ty_so_tab
                              pt_do   type ty_do_tab
                              pt_bl   type ty_bl_tab
                              pt_main structure zgtsds0042
                              pt_021  structure zsdt_d365_021
                              pt_026  structure zsdt_d365_026.

  data : ls_list like zgtsds0042,
         ls_so   type ty_so,
         ls_do   type ty_do,
         ls_bl   type ty_bl.
  data : lt_so type table of ty_so with empty key.
  data : lv_do_found type abap_bool value abap_false,
         lv_bl_found type abap_bool value abap_false.

  loop at pt_so into ls_so.

    clear : ls_list.
    clear : lv_do_found, lv_bl_found.

    ls_list-gubun               = ls_so-gubun.
    ls_list-vkgrp               = ls_so-vkgrp.
    ls_list-vtweg               = ls_so-vtweg.
    ls_list-spart               = ls_so-spart.
    ls_list-land1               = ls_so-land1.

    if ls_so-seqno <> 0.
      ls_list-gubun             = c_26.  "분할된 오더
    endif.

**    ls_list-spmon               = gv_week_month.
    ls_list-kunnr               = ls_so-kunnr.
    ls_list-zpjno               = ls_so-zpjno.
    ls_list-vbeln_va            = ls_so-vbeln_va.
    ls_list-posnr_va            = ls_so-posnr_va.
    ls_list-seqno               = ls_so-seqno.
    ls_list-matnr               = ls_so-matnr.
    ls_list-arktx               = ls_so-arktx.
    ls_list-edatu               = ls_so-edatu.
    ls_list-kwmeng              = ls_so-kwmeng.
    ls_list-vrkme               = ls_so-vrkme.
    ls_list-netwr_so            = ls_so-netwr.
    ls_list-waerk               = ls_so-waerk.
    ls_list-waers_krw           = 'KRW'.
    ls_list-remark              = ls_so-remark.
    ls_list-plqty               = ls_so-plqty.

    "-- open 수량 <== split에서 나온 수량을 사용함
    ls_list-open_qty            = ls_so-plqty.

    "--- 납품 데이터
    loop at pt_do where vbeln_va = ls_so-vbeln_va
                     and posnr_va = ls_so-posnr_va.

      lv_do_found               = abap_true.

      ls_list-vbeln_vl          = pt_do-vbeln_vl.
      ls_list-posnr_vl          = pt_do-posnr_vl.
      ls_list-erdat_vl          = pt_do-erdat.
      ls_list-lfimg             = pt_do-lfimg.
      ls_list-gidat             = pt_do-wadat_ist.

      "-- 빌링데이터
      loop at pt_bl where vbeln_vl = pt_do-vbeln_vl
                      and posnr_vl = pt_do-posnr_vl.

        lv_bl_found              = abap_true.

        ls_list-vbeln_vf         = pt_bl-vbeln_vf.
        ls_list-posnr_vf         = pt_bl-posnr_vf.
        ls_list-fkdat            = pt_bl-fkdat.
        ls_list-sale_date        = pt_bl-fkdat.
        ls_list-sale_qty         = pt_bl-fkimg.
        ls_list-sale_amt         = pt_bl-netwr.
        ls_list-kursf            = pt_bl-kurrf.
*        ls_list-sale_amt_krw     = ls_list-sale_amt * ls_list-kursf.

        "-- OPEN 수량 계산, DO도 분할되어 나갈수 있음
        ls_list-open_qty = ls_list-open_qty - ls_list-sale_qty. "SO 수량

        append ls_list to pt_main.

        ls_list-lfimg    = ls_list-lfimg - ls_list-sale_qty. "DO 수량
      endloop.

      if lv_bl_found = abap_false or ls_list-lfimg > 0.
        ls_list-open_qty = ls_list-open_qty - ls_list-lfimg.
        append ls_list to pt_main.
      endif.
    endloop.

    if lv_do_found = abap_false or ls_list-open_qty > 0.
      append ls_list to pt_main.
    endif.

  endloop.

  "---------------------------------------
  "-- status별 데이터 추가
  "---------------------------------------
**  perform update_status_type  tables pt_main
**                                     pt_021
**                                     pt_026.


endform.
*&---------------------------------------------------------------------*
*& Form COLLECT_CHILDREN_ITEMS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_LT_CHILDREN  text
*      -->P_LT_LEAFS  text
*&---------------------------------------------------------------------*
form collect_children_items  tables   pt_children type lvc_t_nkey
                                      pt_leafs structure zgtsds0041.

  data: lt_children type lvc_t_nkey.
  data: ls_children type lvc_nkey.
  data: ls_tree     type zgtsds0041.

  refresh lt_children.

  loop at pt_children into ls_children.

    call method g_alv_tree->get_children
      exporting
        i_node_key  = ls_children
      importing
        et_children = lt_children.

    if lt_children is initial.  "아래에 CHILD가 없는 최종 데이터임
*      READ TABLE GT_TREE INTO LS_TREE INDEX LS_CHILDREN.
      perform get_tree_line_data  using    ls_children
                                  changing ls_tree.
      if sy-subrc = 0.
        append ls_tree to pt_leafs.
      endif.
    else.
      perform collect_children_items  tables lt_children
                                             pt_leafs.
    endif.

  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form POPULATE_DETAIL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_LT_LEAFS  text
*&---------------------------------------------------------------------*
form populate_detail_data  tables   pt_leafs structure zgtsds0041
                           using    pv_ordtype.


  data: ls_tree     type zgtsds0041.
  data: lt_order    like gt_order occurs 0 with header line.

  " 오더리스트를 조회한다.
  clear: gt_detail, gt_detail[].

  if pv_ordtype = 'CURRENCY'.
    "-- 제일 하단의 데이터를 가져온다.
    loop at pt_leafs into ls_tree.
      loop at gt_main into gs_main where waerk = ls_tree-waerk.
        clear gt_detail.
        move-corresponding gs_main to gt_detail.
        append gt_detail.
      endloop.
    endloop.
  else.
    "-- 제일 하단의 데이터를 가져온다.
    loop at pt_leafs into ls_tree.
      check ls_tree-spmon <> 'TOTAL'.
      loop at gt_main into gs_main where spmon = ls_tree-spmon
                                      and kunnr = ls_tree-kunnr
                                      and zpjno = ls_tree-zpjno
                                      and waerk = ls_tree-waerk.
        clear gt_detail.
        move-corresponding gs_main to gt_detail.
        append gt_detail.
      endloop.
    endloop.
  endif.

*  perform get_detail  tables lt_order.

endform.

*&---------------------------------------------------------------------*
*& Form GET_NATION_VENDOR_NAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_LT_BK_TDLNR  text
*      <--P_PT_LIST_TDLNR_NM  text
*&---------------------------------------------------------------------*
form get_nation_vendor_name  using    pv_tdlnr
                             changing pv_tdlnr_nm.

  data: lv_adrnr  like lfa1-adrnr.

  clear lv_adrnr.

  select single adrnr   into lv_adrnr
    from lfa1          where kunnr = pv_tdlnr.

  check sy-subrc = 0.

  select single name1   into pv_tdlnr_nm
    from adrc          where addrnumber = lv_adrnr
                         and nation     = 'I'.

endform.
*&---------------------------------------------------------------------*
*& Form GET_LGORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_GT_DETIAL_MATNR  text
*      -->P_GT_DETIAL_WERKS  text
*      <--P_GT_DETAIL_LGORT  text
*&---------------------------------------------------------------------*
form get_lgort  using    pv_matnr
                         pv_werks
                changing pv_lgort.

  select single lgpro into pv_lgort
    from marc where matnr = pv_matnr
                and werks = pv_werks.

endform.
*&---------------------------------------------------------------------*
*&      Form  READ_TEXT
*&---------------------------------------------------------------------*
*       Read text
*----------------------------------------------------------------------*
form read_text  tables   pt_tline structure tline
                 using   pv_id
                         pv_langu
                         pv_name
                         pv_object.

  refresh : pt_tline.

  call function 'READ_TEXT'
    exporting
      id                      = pv_id
      language                = pv_langu
      name                    = pv_name
      object                  = pv_object
    tables
      lines                   = pt_tline
    exceptions
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      others                  = 8.

endform.                    " READ_TEXT
*&---------------------------------------------------------------------*
*& Form GET_Z001_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_GT_DETAIL_VBELN_VA  text
*      -->P_GT_DETAIL_VBELN_VL  text
*      <--P_GT_DETAIL_ZTEXT  text
*&---------------------------------------------------------------------*
form get_z001_text  using    pv_vbeln_va
                             pv_vbeln_vl
                    changing pv_ztext.


  data : lt_z001   like tline occurs 0 with header line.
  data : lv_object like thead-tdobject value 'VBBK',
         lv_id     like thead-tdid,
         lv_name   like thead-tdname,
         lv_spras  like thead-tdspras.

*& 특별출하조건 : 판매오더 헤더 텍스트
  lv_id   = 'Z001'.
  refresh : lt_z001.
  clear lv_spras.

  if pv_vbeln_vl is not initial.  " DO가 있으면 DO TEXT

    lv_name = pv_vbeln_vl.
    select single tdspras into lv_spras
                          from stxh
                         where tdobject eq lv_object
                           and tdname   eq lv_name
                           and tdid     eq lv_id.

    perform read_text tables lt_z001
                       using lv_id
                             lv_spras
                             lv_name
                             lv_object.
  elseif pv_vbeln_va is not initial.  " DO가 없으면 SO TEXT

    lv_name = pv_vbeln_va.
    select single tdspras into lv_spras
                          from stxh
                         where tdobject eq lv_object
                           and tdname   eq lv_name
                           and tdid     eq lv_id.

    perform read_text tables lt_z001
                       using lv_id
                             lv_spras
                             lv_name
                             lv_object.

  endif.


  read table lt_z001 index 1.
  if sy-subrc = 0.
    pv_ztext = lt_z001-tdline.
    if lines( lt_z001[] ) > 1.
      pv_ztext = pv_ztext && '....'.
    endif.
  endif.


endform.
*&---------------------------------------------------------------------*
*& Form GET_LGORT_TXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_GT_DETAIL_LGORT  text
*      <--P_GT_DETAIL_LGOBE  text
*&---------------------------------------------------------------------*
form get_lgort_txt  using    pv_werks pv_lgort
                    changing pv_lgobe.

  if gt_t001l[] is initial.
    select werks lgort lgobe
      into corresponding fields of table gt_t001l
      from t001l.
    sort gt_t001l by werks lgort.
  endif.

  read table gt_t001l with key werks = pv_werks
                               lgort = pv_lgort
                               binary search.
  if sy-subrc = 0.
    pv_lgobe = gt_t001l-lgobe.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form ADD_MONTH_WEEK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_LS_MAIN  text
*      -->P_L_BACKORDER_KEY  text
*      <--P_L_MONWEEK_KEY  text
*&---------------------------------------------------------------------*
form add_month_week  using    ps_main like gs_main
                           p_relat_key type lvc_nkey
                 changing  p_node_key type lvc_nkey.

  data: l_node_text type lvc_value.

* add node
  concatenate ps_main-spmon+0(4) '년' ps_main-spmon+4(2) '월' into l_node_text.

*  CONCATENATE PS_MAIN-SPMON+0(4) '년' PS_MAIN-SPMON+4(2) '월'
*              PS_MAIN-PWEEK+4(2) '주차('
*              PS_MAIN-FRDAT_W+4(2) '/' PS_MAIN-FRDAT_W+6(2) '~'
*              PS_MAIN-TODAT_W+4(2) '/' PS_MAIN-TODAT_W+6(2) ')'
*              INTO L_NODE_TEXT.

*************
  data ls_node_layout  type lvc_s_layn.
  data lt_item_layout  type lvc_t_layi.
  clear : ls_node_layout, lt_item_layout.
  perform make_folder_hotspot  changing   ls_node_layout
                                          lt_item_layout.

************


  call method g_alv_tree->add_node
    exporting
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = l_node_text
      is_outtab_line   = ps_main
      is_node_layout   = ls_node_layout
      it_item_layout   = lt_item_layout
    importing
      e_new_node_key   = p_node_key.

endform.

*&---------------------------------------------------------------------*
*& Form UPDATE_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form update_process changing pv_msg.

  data : lv_kwmeng_sum type zgtsds0043-kwmeng,
         lv_kwmeng_qty type zgtsds0043-kwmeng,
         lv_seqno      type zsdt_d365_026-seqno,
         lv_key_ok     type c,
         ls_026        like zsdt_d365_026.

  data: ls_row_id    type lvc_s_row,
        ls_column_id type lvc_s_col.

  "--------------------------------------------------
  "-- 커서를 강제로 이동, 숫자필드는 메세지가 잘 안보임
  ls_row_id-index = 1.        " 첫 번째 행
  ls_column_id-fieldname = 'BLDAT'. " 포커스를 줄 필드명

  call method go_grid_200->set_current_cell_via_id
    exporting
      is_row_id    = ls_row_id
      is_column_id = ls_column_id.

  call method cl_gui_cfw=>flush.
  "--------------------------------------------------


  clear pv_msg.

*  lv_kwmeng_qty = gs_200-kwmeng.
  lv_kwmeng_qty = gs_200-sale_qty.  "매출예정수량

  clear lv_kwmeng_sum.
  loop at gt_list_200.
    if gt_list_200-bldat is initial.
      pv_msg = '매출일은 필수로 입력해야 합니다.'.
      exit.
    endif.
    if gt_list_200-plqty is initial.
      pv_msg = '매출수량은 필수로 입력해야 합니다.'.
      exit.
    endif.
    lv_kwmeng_sum = lv_kwmeng_sum + gt_list_200-plqty.
  endloop.

  check pv_msg is initial.

  if lv_kwmeng_sum = 0.
    "-- 전체 삭제는 ok
  elseif lv_kwmeng_qty <> lv_kwmeng_sum.
    pv_msg = `분할 수량의 합이 ` && lv_kwmeng_qty && ` 와 일치하지 않습니다.`.
    exit.
  endif.

  "-------------------------------------------------------
  "-- max seqno, gt_026_upd에서 max를 찾아서 +1 추가한다.
  sort gt_026     by vbeln_va posnr_va seqno descending.
  sort gt_026_upd by vbeln_va posnr_va seqno descending.

  read table gt_026 into ls_026 with key vbeln_va = gs_200-vbeln_va
                                         posnr_va = gs_200-posnr_va.
  if sy-subrc = 0.
    lv_seqno = ls_026-seqno.
  else.
    lv_seqno = 0.
  endif.

  read table gt_026_upd with key vbeln_va = gs_200-vbeln_va
                                 posnr_va = gs_200-posnr_va.
  if sy-subrc = 0.
    if lv_seqno < gt_026_upd-seqno.
      lv_seqno = gt_026_upd-seqno.
    endif.
  endif.
  "-------------------------------------------------------

  sort gt_list_200 by bldat.

  refresh gt_026_tmp.

  loop at gt_list_200 where plqty <> 0.

    lv_seqno = lv_seqno + 1.
    if lv_seqno = '00'.
      lv_seqno = 1.
    endif.
    lv_key_ok = ''.

    "-- 중복키는 제외
    do 99 times.
      read table gt_026_upd transporting no fields
                            with key vbeln_va = gs_200-vbeln_va
                                     posnr_va = gs_200-posnr_va
                                     seqno    = lv_seqno.
      if sy-subrc = 0.
        lv_seqno = lv_seqno + 1.
        if lv_seqno = '00'.
          lv_seqno = 1.
        endif.
      else.
        lv_key_ok = 'X'.
        exit.
      endif.
    enddo.

    if lv_key_ok = ''.
      pv_msg = '분할을 너무 많이 해서 더 이상 불가합니다.(99)'.
      exit.
    endif.

    clear ls_026.
    ls_026-vbeln_va  = gs_200-vbeln_va.
    ls_026-posnr_va  = gs_200-posnr_va.
    ls_026-seqno     = lv_seqno.
    ls_026-vbeln_vl  = gs_200-vbeln_vl.
    ls_026-posnr_vl  = gs_200-posnr_vl.
*    ls_026-excep     = gs_200-excep.
    ls_026-vrkme     = gs_200-vrkme.
    ls_026-kwmeng    = gs_200-kwmeng.
    ls_026-lfimg     = gs_200-lfimg.
    ls_026-gidat     = gs_200-gidat.
    ls_026-bldat     = gt_list_200-bldat.
    ls_026-plqty     = gt_list_200-plqty.
    ls_026-waerk     = gs_200-waerk.
    ls_026-netwr     = gs_200-netwr_so * gt_list_200-plqty / gs_200-kwmeng.
    ls_026-remark    = gt_list_200-remark.

    zcl_snop_rfc_funcntion=>update_timestamp( changing cs_data = ls_026 ).

    append ls_026 to gt_026_tmp.

  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form SAVE_TEXT_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form save_wish_data changing pv_msg.

  data : lv_kwmeng_sum type zgtsds0043-kwmeng,
         lv_seqno      type zsdt_d365_026-seqno,
         ls_027        like zsdt_d365_027.

  "--------------------------------------------------
  "-- 커서를 강제로 이동, 숫자필드는 메세지가 잘 안보임
  data: ls_row_id    type lvc_s_row,
        ls_column_id type lvc_s_col.

  call method cl_gui_cfw=>flush.

  ls_row_id-index = 1.        " 첫 번째 행
  ls_column_id-fieldname = 'SPMON'. " 포커스를 줄 필드명

  call method go_grid_300->set_current_cell_via_id
    exporting
      is_row_id    = ls_row_id
      is_column_id = ls_column_id.

  "--------------------------------------------------


  clear pv_msg.

  clear lv_kwmeng_sum.
  loop at gt_list_300.
    if gt_list_300-spmon is initial.
      pv_msg = '매출월은 필수로 입력해야 합니다.'.
      exit.
    endif.
    if gt_list_300-kunnr is initial.
      pv_msg = '판매처는 필수로 입력해야 합니다.'.
      exit.
    endif.
*    if gt_list_300-prodh is initial.
*      pv_msg = '제품계층구조는 필수로 입력해야 합니다.'.
*      exit.
*    endif.
*    if gt_list_300-matnr is initial.
*      pv_msg = '자재는 필수로 입력해야 합니다.'.
*      exit.
*    endif.
*    if gt_list_300-unitprice_krw = 0.
*      pv_msg = '판가(KRW)는 필수로 입력해야 합니다.'.
*      exit.
*    endif.
*    if gt_list_300-vrkme is initial.
*      pv_msg = '단위는 필수로 입력해야 합니다.'.
*      exit.
*    endif.
*    if gt_list_300-quantity = 0.
*      pv_msg = '매출수량은 필수로 입력해야 합니다.'.
*      exit.
*    endif.
    if gt_list_300-amount_krw = 0.
      pv_msg = '매출액(KRW)은 필수로 입력해야 합니다.'.
      exit.
    endif.

*    gt_list_300-amount_krw = gt_list_300-unitprice_krw * gt_list_300-quantity.

    if gt_list_300-marginalprofit_per = 0.
      pv_msg = '한계이익률(%)은 필수로 입력해야 합니다.'.
      exit.
    endif.

    modify gt_list_300.
  endloop.

  check pv_msg is initial.

  data : lt_300 like zgtsds0044 occurs 0 with header line.

  move-corresponding gt_list_300[] to lt_300[].
  sort lt_300 by spmon kunnr zpjno prodh matnr.
  delete adjacent duplicates from lt_300 comparing spmon kunnr zpjno prodh matnr.
  if lines( gt_list_300 ) <> lines( lt_300 ).
    pv_msg = '의지치가 중복으로 입력되었습니다.'.
    exit.
  endif.

  "-- 키값 변경시엔 chk에 있는데, 화면에 없으면 삭제가 필요함
  loop at gt_027_chk into ls_027.
    read table gt_list_300 transporting no fields
                           with key spmon = ls_027-spmon
                                    kunnr = ls_027-kunnr
                                    zpjno = ls_027-zpjno
                                    prodh = ls_027-prodh
                                    matnr = ls_027-matnr.
    if sy-subrc <> 0.
      read table gt_027_del transporting no fields
                           with key spmon = ls_027-spmon
                                    kunnr = ls_027-kunnr
                                    zpjno = ls_027-zpjno
                                    prodh = ls_027-prodh
                                    matnr = ls_027-matnr.
      if sy-subrc <> 0.
        append ls_027 to gt_027_del. ""<--- db에서 삭제할 내용
      endif.
    endif.
  endloop.

  check pv_msg is initial.


  clear gt_027_tmp[].

  loop at gt_list_300.

    clear ls_027.
    ls_027-vkbur         = gt_list_300-vkbur.
    ls_027-pernr         = gt_list_300-pernr.
    ls_027-spmon         = gt_list_300-spmon.
    ls_027-fkdat         = gt_list_300-spmon && '01'.
    call function 'BKK_GET_MONTH_LASTDAY'
      exporting
        i_date = ls_027-fkdat
      importing
        e_date = ls_027-fkdat.

    ls_027-kunnr         = gt_list_300-kunnr.
    ls_027-zpjno         = gt_list_300-zpjno.
    ls_027-prodh         = gt_list_300-prodh.
    ls_027-matnr         = gt_list_300-matnr.
*    ls_027-unitprice_krw = gt_list_300-unitprice_krw.
    ls_027-waers_krw     = gt_list_300-waers_krw.
*    ls_027-quantity      = gt_list_300-quantity.
*    ls_027-vrkme         = gt_list_300-vrkme.
    ls_027-amount_krw    = gt_list_300-amount_krw.
    ls_027-marginalprofit_per    = gt_list_300-marginalprofit_per.
    ls_027-marginalprofit_krw    = gt_list_300-marginalprofit_krw.
    ls_027-remark        = gt_list_300-remark.

    ls_027-ernam         = gt_list_300-ernam.
    ls_027-erdat         = gt_list_300-erdat.
    ls_027-erzet         = gt_list_300-erzet.
    ls_027-aenam         = gt_list_300-aenam.
    ls_027-aedat         = gt_list_300-aedat.
    ls_027-aezet         = gt_list_300-aezet.

    zcl_snop_rfc_funcntion=>update_timestamp( changing cs_data = ls_027 ).

    append ls_027 to gt_027_tmp.

  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form GET_TEXT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_LS_DETAIL_VBELN_VL  text
*&---------------------------------------------------------------------*
form get_text_data  using    pv_vbeln_va
                             pv_vbeln_vl.


  data : lt_z001   like tline occurs 0 with header line.
  data : lv_object like thead-tdobject value 'VBBK',
         lv_id     like thead-tdid,
         lv_name   like thead-tdname,
         lv_spras  like thead-tdspras.

  clear g_mytable[].

*& 특별출하조건 : 판매오더 헤더 텍스트
  lv_id   = 'Z001'.
  refresh : lt_z001.
  clear: lv_spras, g_mytable,
         gv_vbeln, gv_vbeln_ty, gv_langu_tx.


  " do의 text를 가져오고 수정한다.
  if pv_vbeln_vl is not initial and pv_vbeln_vl ne icon_create.

    lv_name     = pv_vbeln_vl.
    gv_vbeln    = pv_vbeln_vl.
    gv_vbeln_ty = '납품오더'.

    " so의 text를 가져오고 수정한다.
  elseif pv_vbeln_va is not initial.

    lv_name     = pv_vbeln_va.
    gv_vbeln    = pv_vbeln_va.
    gv_vbeln_ty = '판매오더'.

  endif.


  select single tdspras into lv_spras
                        from stxh
                       where tdobject eq lv_object
                         and tdname   eq lv_name
                         and tdid     eq lv_id.
  gv_langu_tx = lv_spras.

  perform read_text tables lt_z001
                     using lv_id
                           lv_spras
                           lv_name
                           lv_object.


  data l_mytable(line_length) type c.

  loop at lt_z001.
    l_mytable = lt_z001-tdline.
    append l_mytable to g_mytable.
  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form GET_DO_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_do_data  tables  pt_so type ty_so_tab
                          pt_do type ty_do_tab.

  check pt_so[] is not initial.

  data : lt_so type ty_so_tab.
  lt_so[] = pt_so[].

  select a~vbeln,
         b~posnr,
         b~vgbel,
         b~vgpos,
         a~erdat,
         a~wadat_ist,
         a~wadat,
         b~werks,
         b~matnr,
         b~vrkme,
         b~lfimg,
         b~wbsta,
         b~uecha
    from likp as a inner join lips as b  on a~vbeln = b~vbeln
                   inner join @lt_so as c on b~vgbel eq c~vbeln_va
                                         and b~vgpos eq c~posnr_va
   where a~vkorg = @p_vkorg
    into table @data(lt_do).


  data(lt_do_batch) = lt_do[].
  delete lt_do_batch where uecha is initial.
  delete lt_do       where uecha is not initial.

  sort lt_do_batch by vbeln uecha.

  loop at lt_do assigning field-symbol(<fs>).

    read table pt_so into gs_so with key vbeln_va = <fs>-vgbel
                                         posnr_va = <fs>-vgpos.

    clear gs_do.
    gs_do-vbeln_va  = <fs>-vgbel.
    gs_do-posnr_va  = <fs>-vgpos.
    gs_do-vbeln_vl  = <fs>-vbeln.
    gs_do-posnr_vl  = <fs>-posnr.
    gs_do-werks     = <fs>-werks.
    gs_do-matnr     = <fs>-matnr.
    gs_do-erdat     = <fs>-erdat.
    gs_do-wadat     = <fs>-wadat.
    gs_do-wadat_ist = <fs>-wadat_ist.
*    gt_do-pernr      = gt_main-pernr.
    gs_do-vrkme      = <fs>-vrkme.
    if gs_so-vbtyp = 'H' or gs_so-vbtyp = 'K'.
      gs_do-lfimg    = <fs>-lfimg * -1.
    else.
      gs_do-lfimg    = <fs>-lfimg.
    endif.
    gs_do-wbsta      = <fs>-wbsta.
    gs_do-kunnr      = gs_so-kunnr.

    "배치수량을 10번 item으로 올려줌
    loop at lt_do_batch assigning field-symbol(<batch>)
                        where vbeln = <fs>-vbeln
                          and uecha = <fs>-posnr.
      gs_do-lfimg = gs_do-lfimg + <batch>-lfimg.
    endloop.

    if gs_so-vbtyp = 'H' or gs_so-vbtyp = 'K'.
      gs_do-lfimg    = gs_do-lfimg  * -1.
    else.
      gs_do-lfimg    = gs_do-lfimg.
    endif.

    collect gs_do into pt_do.

  endloop.

  delete pt_do where lfimg = 0.

  perform calculate_open_so tables gt_so    "-- open so 계산
                                   gt_do.

endform.
*&---------------------------------------------------------------------*
*& Form TREE_OPEN_CLOSE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form tree_open_close .

  if gv_tree_on = gc_open.
    call method go_splitter->set_column_width
      exporting
        id    = 1
        width = gc_close_width. " tree 부분을 최소로 보여줌

    gv_tree_on = gc_close.
  else.
    call method go_splitter->set_column_width
      exporting
        id    = 1
        width = gc_open_width.  " tree 부분을 초기넓이로 보여줌

    gv_tree_on = gc_open.
  endif.

endform.

*&---------------------------------------------------------------------*
*& Form GET_ITEM_DETAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_item_detail using pv_node_key
                            pv_ordtype.  "SO, DO

  data: lt_selected_nodes type lvc_t_nkey,
        l_selected_node   type lvc_nkey,
        l_rc              type c.

  data: ls_tree     type zgtsds0041.
  data: gs_tree     type zgtsds0041.

  data: lt_nkey     type table of lvc_nkey.
  data: ls_nkey     type lvc_nkey.

  data: lt_leafs    type table of zgtsds0041.

  data: l_index     type lvc_index.


  check pv_node_key is not initial.


  clear ls_tree.
*  READ TABLE GT_TREE INTO LS_TREE INDEX PV_NODE_KEY.

  perform get_tree_line_data  using    pv_node_key
                              changing ls_tree.

  check sy-subrc   = 0.

  ls_nkey = pv_node_key.
  append ls_nkey  to lt_nkey.


  " TREE의 최하단 데이터(SO&DO)만 가져온다.
  perform collect_children_items  tables lt_nkey
                                         lt_leafs.

  " 각 오더의 상세 데이터를 조회한다.
  if lt_leafs is not initial.

    if ls_tree-spmon = 'TOTAL'.
      perform populate_detail_data tables lt_leafs
                                   using  'CURRENCY'.
    else.
      perform populate_detail_data tables lt_leafs
                                   using  pv_ordtype.
    endif.

    sort gt_detail by kunnr zpjno vbeln_va posnr_va seqno bltype sale_date.

  else. "sy-subrc EQ 0
    message i000(0k) with 'Please select a node.'(900).
  endif.


endform.



*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
form user_ok_tc using    p_tc_name type dynfnam
                         p_table_name
                         p_mark_name
                changing p_ok      like sy-ucomm.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  data: l_ok     type sy-ucomm,
        l_offset type i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
  search p_ok for p_tc_name.
  if sy-subrc <> 0.
    exit.
  endif.
  l_offset = strlen( p_tc_name ) + 1.
  l_ok = p_ok+l_offset.
*&SPWIZARD: execute general and TC specific operations                 *
  case l_ok.
    when 'INSR'.                      "insert row
      perform fcode_insert_row using    p_tc_name
                                        p_table_name.
      clear p_ok.

    when 'DELE'.                      "delete row
      perform fcode_delete_row using    p_tc_name
                                        p_table_name
                                        p_mark_name.
      clear p_ok.

    when 'P--' or                     "top of list
         'P-'  or                     "previous page
         'P+'  or                     "next page
         'P++'.                       "bottom of list
      perform compute_scrolling_in_tc using p_tc_name
                                            l_ok.
      clear p_ok.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    when 'MARK'.                      "mark all filled lines
      perform fcode_tc_mark_lines using p_tc_name
                                        p_table_name
                                        p_mark_name   .
      clear p_ok.

    when 'DMRK'.                      "demark all filled lines
      perform fcode_tc_demark_lines using p_tc_name
                                          p_table_name
                                          p_mark_name .
      clear p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

  endcase.

endform.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
form fcode_insert_row
              using    p_tc_name           type dynfnam
                       p_table_name             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  data l_lines_name       like feld-name.
  data l_selline          like sy-stepl.
  data l_lastline         type i.
  data l_line             type i.
  data l_table_name       like feld-name.
  field-symbols <tc>                 type cxtab_control.
  field-symbols <table>              type standard table.
  field-symbols <lines>              type i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  assign (p_tc_name) to <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  concatenate p_table_name '[]' into l_table_name. "table body
  assign (l_table_name) to <table>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
  concatenate 'G_' p_tc_name '_LINES' into l_lines_name.
  assign (l_lines_name) to <lines>.

*&SPWIZARD: get current line                                           *
  get cursor line l_selline.
  if sy-subrc <> 0.                   " append line to table
    l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line                                               *
    if l_selline > <lines>.
      <tc>-top_line = l_selline - <lines> + 1 .
    else.
      <tc>-top_line = 1.
    endif.
  else.                               " insert line into table
    l_selline = <tc>-top_line + l_selline - 1.
    l_lastline = <tc>-top_line + <lines> - 1.
  endif.
*&SPWIZARD: set new cursor line                                        *
  l_line = l_selline - <tc>-top_line + 1.

*&SPWIZARD: insert initial line                                        *
  insert initial line into <table> index l_selline.
  <tc>-lines = <tc>-lines + 1.
*&SPWIZARD: set cursor                                                 *
  set cursor line l_line.

endform.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
form fcode_delete_row
              using    p_tc_name           type dynfnam
                       p_table_name
                       p_mark_name   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  data l_table_name       like feld-name.

  field-symbols <tc>         type cxtab_control.
  field-symbols <table>      type standard table.
  field-symbols <wa>.
  field-symbols <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  assign (p_tc_name) to <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  concatenate p_table_name '[]' into l_table_name. "table body
  assign (l_table_name) to <table>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
  describe table <table> lines <tc>-lines.

  loop at <table> assigning <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    assign component p_mark_name of structure <wa> to <mark_field>.

    if <mark_field> = 'X'.
      delete <table> index syst-tabix.
      if sy-subrc = 0.
        <tc>-lines = <tc>-lines - 1.
      endif.
    endif.
  endloop.

endform.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
form compute_scrolling_in_tc using    p_tc_name
                                      p_ok.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  data l_tc_new_top_line     type i.
  data l_tc_name             like feld-name.
  data l_tc_lines_name       like feld-name.
  data l_tc_field_name       like feld-name.

  field-symbols <tc>         type cxtab_control.
  field-symbols <lines>      type i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  assign (p_tc_name) to <tc>.
*&SPWIZARD: get looplines of TableControl                              *
  concatenate 'G_' p_tc_name '_LINES' into l_tc_lines_name.
  assign (l_tc_lines_name) to <lines>.


*&SPWIZARD: is no line filled?                                         *
  if <tc>-lines = 0.
*&SPWIZARD: yes, ...                                                   *
    l_tc_new_top_line = 1.
  else.
*&SPWIZARD: no, ...                                                    *
    call function 'SCROLLING_IN_TABLE'
      exporting
        entry_act      = <tc>-top_line
        entry_from     = 1
        entry_to       = <tc>-lines
        last_page_full = 'X'
        loops          = <lines>
        ok_code        = p_ok
        overlapping    = 'X'
      importing
        entry_new      = l_tc_new_top_line
      exceptions
*       NO_ENTRY_OR_PAGE_ACT  = 01
*       NO_ENTRY_TO    = 02
*       NO_OK_CODE_OR_PAGE_GO = 03
        others         = 0.
  endif.

*&SPWIZARD: get actual tc and column                                   *
  get cursor field l_tc_field_name
             area  l_tc_name.

  if syst-subrc = 0.
    if l_tc_name = p_tc_name.
*&SPWIZARD: et actual column                                           *
      set cursor field l_tc_field_name line 1.
    endif.
  endif.

*&SPWIZARD: set the new top line                                       *
  <tc>-top_line = l_tc_new_top_line.


endform.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
form fcode_tc_mark_lines using p_tc_name
                               p_table_name
                               p_mark_name.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
  data l_table_name       like feld-name.

  field-symbols <tc>         type cxtab_control.
  field-symbols <table>      type standard table.
  field-symbols <wa>.
  field-symbols <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  assign (p_tc_name) to <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  concatenate p_table_name '[]' into l_table_name. "table body
  assign (l_table_name) to <table>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
  loop at <table> assigning <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    assign component p_mark_name of structure <wa> to <mark_field>.

    <mark_field> = 'X'.
  endloop.
endform.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
form fcode_tc_demark_lines using p_tc_name
                                 p_table_name
                                 p_mark_name .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  data l_table_name       like feld-name.

  field-symbols <tc>         type cxtab_control.
  field-symbols <table>      type standard table.
  field-symbols <wa>.
  field-symbols <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  assign (p_tc_name) to <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  concatenate p_table_name '[]' into l_table_name. "table body
  assign (l_table_name) to <table>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
  loop at <table> assigning <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    assign component p_mark_name of structure <wa> to <mark_field>.

    <mark_field> = space.
  endloop.
endform.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*& Form DYNP_VALUES_UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_SY_REPID  text
*      -->P_SY_DYNNR  text
*      -->P_       text
*      -->P_DA_VALUE  text
*      <--P_SY_SUBRC  text
*&---------------------------------------------------------------------*
form dynp_values_update using us_repid
                              us_dynnr
                              us_field
                              us_value
                     changing ch_subrc.

  data: da_dynpfield_tab like dynpread occurs 0 with header line,
        da_stepl         like sy-stepl,
        da_repid         like d020s-prog,
        da_dynnr         like d020s-dnum.

  ch_subrc = 4.
  refresh da_dynpfield_tab.

  move us_repid to da_repid.
  move us_dynnr to da_dynnr.

  get cursor line da_stepl.
  move da_stepl to da_dynpfield_tab-stepl.
  move us_field to da_dynpfield_tab-fieldname.
  move us_value to da_dynpfield_tab-fieldvalue.
  append da_dynpfield_tab.

  call function 'DYNP_VALUES_UPDATE'
    exporting
      dyname               = da_repid
      dynumb               = da_dynnr
    tables
      dynpfields           = da_dynpfield_tab
    exceptions
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      others               = 8.

  if sy-subrc eq 0.
    ch_subrc = 0.
  endif.

endform.

*&---------------------------------------------------------------------*
*& Form CHECK_MATERIAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form check_material .

**** material을 체크하고 default값을 세팅한다.
**
**  check gs_item-matnr is not initial.
**
**  " 판매단위
**  select single vrkme into gs_item-vrkme
**    from mvke   where matnr = gs_item-matnr
**                  and vkorg = zotc1642s-vkorg
**                  and vtweg = zotc1642s-vtweg.
**  if sy-subrc <> 0.
**    message e382(v1) with gs_item-matnr
**                          zotc1642s-vkorg
**                          zotc1642s-vtweg
**                          sy-langu.
**    exit.
**  endif.
**
**  " 기본단위
**  if gs_item-vrkme is initial.
**    select single meins into gs_item-vrkme
**      from mara where matnr = gs_item-matnr.
**  endif.
**
**  " TEXT
**  if gs_item-arktx is initial.
**    select single maktx into gs_item-arktx
**      from makt   where matnr = gs_item-matnr
**                    and spras = sy-langu.
**  endif.
**
**  " 납품예정일
**  if gs_item-edatu is initial.
**    gs_item-edatu = sy-datum + 3.
**  endif.


endform.


*&---------------------------------------------------------------------*
*& Form GET_SCREEN_RESOLUTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_screen_resolution changing ps_factors.

  data: lref_consumer     type ref to cl_gui_props_consumer,
        ls_metric_factors type cntl_metric_factors.

  lref_consumer = cl_gui_props_consumer=>create_consumer( ).
  ps_factors = lref_consumer->get_metric_factors( ).


endform.
*&---------------------------------------------------------------------*
*& Form GET_TREE_LINE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_PV_NODE_KEY  text
*      <--P_LS_TREE  text
*&---------------------------------------------------------------------*
form get_tree_line_data  using    pv_node_key
                         changing ps_tree  like zgtsds0041.


  data:
    l_node_key     type lvc_nkey,
    l_outtab_line  type zgtsds0041,
    l_node_text    type lvc_value,
    lt_item_layout type lvc_t_layi,
    ls_node_layout type lvc_s_layn.

*  READ TABLE GT_TREE INTO LS_TREE 를  아래로 대체함
  " 선택한 라인의 데이터를 가져온다.
  l_node_key  = pv_node_key.

  call method g_alv_tree->get_outtab_line
    exporting
      i_node_key     = l_node_key
    importing
      e_outtab_line  = l_outtab_line
      e_node_text    = l_node_text
      et_item_layout = lt_item_layout
      es_node_layout = ls_node_layout
    exceptions
      node_not_found = 1.

  check sy-subrc = 0.

  move-corresponding l_outtab_line to ps_tree .

endform.
*&---------------------------------------------------------------------*
*& Form GET_COLLECTED_WEEK_NKEYS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_PV_NODE_KEY  text
*      <--P_LT_NKEY  text
*&---------------------------------------------------------------------*
form get_collected_week_nkeys  using   pv_node_key
                               changing pt_nkey type lvc_t_nkey.

  data l_top_nkey    type lvc_nkey.
  data l_sub_nkeys   type lvc_t_nkey.
  data l_sub_nkey    type lvc_nkey.
  data ls_tree_key   type zgtsds0041.
  data ls_tree_tmp   type zgtsds0041.


  " 조회할 주차용 데이터
  clear ls_tree_key.
  perform get_tree_line_data  using    pv_node_key
                              changing ls_tree_key.

  clear l_top_nkey.
  if gv_nkey_top is not initial.
    l_top_nkey = gv_nkey_top.
    clear gv_nkey_top.
  else.
    call method g_alv_tree->get_top_node
      importing
        e_node_key = l_top_nkey.
  endif.

  " 전체 TREE를 가져온다.
  call method g_alv_tree->get_subtree
    exporting
      i_node_key       = l_top_nkey
    importing
      et_subtree_nodes = l_sub_nkeys.


  loop at l_sub_nkeys into l_sub_nkey.

    clear ls_tree_tmp.
    " 각각의 주차를 조회한 후, 필요한 NODE를 저장한다.
    perform get_tree_line_data  using    l_sub_nkey
                                changing ls_tree_tmp.

**    check ls_tree_key-pweek = ls_tree_tmp-pweek.
***    check ls_tree_key-gubun = 'M'.
**    check ls_tree_key-level = ls_tree_tmp-level.
**
**    if ls_tree_tmp-level = 3.
**      check ls_tree_key-pernr = ls_tree_tmp-pernr.
**    elseif ls_tree_tmp-level = 4.
**      check ls_tree_key-pernr = ls_tree_tmp-pernr.
**      check ls_tree_key-kunnr = ls_tree_tmp-kunnr.
**    endif.

    append l_sub_nkey to pt_nkey.
  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form SET_SELECTED_NODE_W0
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_selected_node_m0 .

  data lt_selected_nodes type lvc_t_nkey.

  check gv_nkey_m0 is not initial.

  append gv_nkey_m0 to lt_selected_nodes.

  call method g_alv_tree->set_selected_nodes "라인을 선택하게
    exporting
      it_selected_nodes = lt_selected_nodes.

endform.
*&---------------------------------------------------------------------*
*& Form MAKE_FOLDER_HOTSPOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      <--P_LS_NODE_LAYOUT  text
*      <--P_LT_ITEM_LAYOUT  text
*&---------------------------------------------------------------------*
form make_folder_hotspot  changing ps_node_layout type lvc_s_layn
                                   pt_item_layout type lvc_t_layi.

  data ls_item_layout  type lvc_s_layi.

  ps_node_layout-isfolder    = abap_true.            "*/ node = folder
*  PS_NODE_LAYOUT-STYLE       = CL_GUI_COLUMN_TREE=>STYLE_EMPHASIZED.

  ls_item_layout-class       = cl_gui_column_tree=>item_class_link.
  ls_item_layout-fieldname   = 'SALE_AMT'.
  append ls_item_layout      to pt_item_layout.

  ls_item_layout-class       = cl_gui_column_tree=>item_class_link.
  ls_item_layout-fieldname   = 'SALE_AMT_KRW'.
  append ls_item_layout      to pt_item_layout.

endform.
*&---------------------------------------------------------------------*
*& Form CALL_SALES_ORDER_SCR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form call_sales_order_scr using p_selected_node type lvc_nkey.

**  data: lt_selected_nodes type lvc_t_nkey.
**  data: ls_tree           type zgtsds0041.
**
**
**  clear : ls_tree, zotc1642s, zotc1643s.
**  perform clear_order_text.
**
**  zotc1642s-vkorg = p_vkorg.
**  zotc1642s-vkgrp = p_vkgrp.
**  if p_vkgrp is not initial.
**    select single vkbur into zotc1642s-vkbur
**      from tvbvk  where vkgrp = p_vkgrp.
**  endif.
**
**  perform get_tree_line_data  using    p_selected_node
**                              changing ls_tree.
**  if sy-subrc = 0.
**    " 3단계일 경우에
**    if ls_tree-level = 3.
**      zotc1642s-pernr = ls_tree-pernr.
**    endif.
**    " 4단계일 경우에,,, 거래선 레벨을 선택한 경우
**    if ls_tree-level = 4.
**      zotc1642s-pernr = ls_tree-pernr.
**      zotc1642s-kunnr = ls_tree-kunnr.
**      perform set_salesorg_data.  " default조직을 세팅함 VTWEG , SPART.
**    endif.
**  endif.
**
**  zotc1642s-auart = 'ZOR1'.
**  gv_org_check = 'NO'.
**
**  call screen '410' starting at   5   5.
***                            ENDING   AT  60  16. " 주문정보 생성용 header 화면
**
**  " 확인 버튼을 눌렀을 때 에러가 없으면 상세 주문생성화면으로 진행함
**  if gv_org_check = 'YES'.
**
**    clear sy-ucomm.
**    clear: gs_item, gt_item, gt_item[].
**
****    zotc1643s-kunag = zotc1642s-kunnr.
**
**
****    " 거래선레벨이고 계획수량이 있으면 ITEM을 추가해준다.
****    if ls_tree-level = 4 and ls_tree-plan_qty > 0.
****      perform make_item_data using ls_tree.
****    endif.
**
**
**    gv_price_pushed = ''.
**
**    call screen '400' starting at   5   5.
***                              ENDING   AT  95  26. " 주문정보 생성용 화면 ITEM
**
***   update frontend. node를 잃어버리는 경우가 있어서 제외함
****    IF GV_VBELN_NEW IS NOT INITIAL AND " 정상적으로 생성된 경우
****        P_SELECTED_NODE IS NOT INITIAL.
****
****      APPEND P_SELECTED_NODE TO LT_SELECTED_NODES.
****      CALL METHOD G_ALV_TREE->SET_SELECTED_NODES "선택한 라인을 보여준다.
****        EXPORTING
****          IT_SELECTED_NODES = LT_SELECTED_NODES.
****
****      CALL METHOD G_ALV_TREE->FRONTEND_UPDATE.
****    ENDIF.
**
**  endif.


endform.
*&---------------------------------------------------------------------*
*& Form GET_F4_AUART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_f4_auart using       key
                              key2
                              key3
                              key4
                              key5
                   changing   field
                              description.

  data: da_titel(80).

  data: begin of da_fields occurs 2.
          include structure help_value.
  data: end of da_fields.

  data: offset    like sy-tabix.
  data: no_help(1) type c.

  data: titleline(80) type c.
  data: informationline(120) type c.
  data: da_callback_program type syrepid,
        da_callback_form    type syxform.

*-------Strukturen für number = '008'
  data: begin of da_008,
          auart type tvak-auart,
          bezei type tvakt-bezei,
        end of da_008.

  data: da_008tab like da_008 occurs 10.


  ranges: itab_vkorg for vbak-vkorg.
  ranges: itab_vtweg for vbak-vtweg.
  ranges: itab_spart for vbak-spart.
  ranges: itab_auart for vbak-auart.

  data: begin of xtvak occurs 2.
          include structure tvak.
  data: end of xtvak.

  data: bezei(20) type c.
  data: begin of showtab occurs 10,
          line(80) type c,
        end of showtab.


  da_fields-tabname    = 'TVAK'.
  da_fields-fieldname  = 'AUART'.
  da_fields-selectflag = 'X'.
  append da_fields.
  da_fields-tabname    = 'TVAKT'.
  da_fields-fieldname  = 'BEZEI'.
  da_fields-selectflag = ' '.
  append da_fields.

  offset = 4.
  clear: tvko, tvkov, tvkos.
  refresh itab_auart. clear itab_auart.
  refresh itab_vkorg. clear itab_vkorg.
  refresh itab_vtweg. clear itab_vtweg.
  refresh itab_spart. clear itab_spart.

  if key cn '? '.
    select single * from tvko  where vkorg = key.
    if sy-subrc ne 0. no_help = 'X'. endif.
    call function 'DDIF_FIELDINFO_GET'
      exporting
        tabname   = 'VKORG'
        all_types = charx
      importing
        dfies_wa  = dfies
      exceptions
        others    = 1.
    informationline(20) = dfies-scrtext_l.
    informationline+20(2) = '..'.
    informationline+22(4) = key.
    informationline+26(2) = '$$'.
    condense informationline(22) no-gaps.
  endif.
  if key2 cn '?  ' and key cn '? '.
    select single * from tvkov where vkorg = key
                               and   vtweg = key2.
    if sy-subrc ne 0. no_help = 'X'. endif.
    call function 'DDIF_FIELDINFO_GET'
      exporting
        tabname   = 'VTWEG'
        all_types = charx
      importing
        dfies_wa  = dfies
      exceptions
        others    = 1.
    informationline+30(20) = dfies-scrtext_l.
    informationline+50(2) = '..'.
    informationline+52(2) = key2.
    informationline+54(2) = '$$'.
    condense informationline+30(22) no-gaps.
  endif.
  if key3 cn '?  ' and key cn '? '.
    select single * from tvkos where vkorg = key
                               and   spart = key3.
    if sy-subrc ne 0. no_help = 'X'. endif.
    call function 'DDIF_FIELDINFO_GET'
      exporting
        tabname   = 'SPART'
        all_types = charx
      importing
        dfies_wa  = dfies
      exceptions
        others    = 1.
    informationline+58(20) = dfies-scrtext_l.
    informationline+78(2) = '..'.
    informationline+80(2) = key3.
    informationline+82(2) = '$$'.
    condense informationline+58(22) no-gaps.
  endif.

  condense informationline.
  replace '$$' with '  ' into informationline.
  replace '$$' with '  ' into informationline.
  replace '$$' with '  ' into informationline.


  if tvko-vkoau  ne ' ' or
     tvkov-vtwau ne ' ' or
     tvkos-spaau ne ' '.

    if tvko-vkoau ne ' '.
      itab_vkorg-sign   = 'I'.
      itab_vkorg-option = 'EQ'.
      itab_vkorg-low    = tvko-vkoau.
      append itab_vkorg.
    endif.

    if tvkov-vtwau ne ' '.
      itab_vtweg-sign   = 'I'.
      itab_vtweg-option = 'EQ'.
      itab_vtweg-low    = tvkov-vtwau.
      append itab_vtweg.
    endif.

    if tvkos-spaau ne ' '.
      itab_spart-sign   = 'I'.
      itab_spart-option = 'EQ'.
      itab_spart-low    = tvkos-spaau.
      append itab_spart.
    endif.

    select * from tvakz where vkorg in itab_vkorg and
                              vtweg in itab_vtweg and
                              spart in itab_spart.
      itab_auart-sign   = 'I'.
      itab_auart-option = 'EQ'.
      itab_auart-low    = tvakz-auart.
      append itab_auart.
    endselect.
*    DA_CALLBACK_PROGRAM = SY-REPID.
*    DA_CALLBACK_FORM = 'CALLBACK_F4_AUART'.
  endif.

  if key5 is initial.
    select * into table xtvak from tvak where auart in itab_auart
                       and   sperr = ' '
                       and   trvog = key4.
  else.
    select * into table xtvak from tvak where auart in itab_auart
                       and   sperr = ' '
                       and   trvog = key4
                       and   vbtyp = key5.
  endif.

  delete xtvak where auart = 'ZFD1'.  "화면에서 제외함

  sort xtvak by vbtyp auart.
  loop at xtvak.
    write xtvak-auart to showtab.
    da_008-auart = xtvak-auart.
    select single * from tvakt where spras = sy-langu
                               and   auart = xtvak-auart.
    if sy-subrc = 0.
      write tvakt-bezei to showtab+4.
      da_008-bezei = tvakt-bezei.
    else.
      write '텍스트유지보수안함' to showtab+4.
      write '텍스트유지보수안함' to da_008-bezei.
    endif.
    collect showtab.
    append da_008 to da_008tab.
  endloop.

  sort showtab.
  call function 'DDIF_FIELDINFO_GET'
    exporting
      tabname   = 'AUART'
      all_types = charx
    importing
      dfies_wa  = dfies
    exceptions
      others    = 1.
  titleline = dfies-scrtext_l.

  da_titel = titleline.



  field-symbols: <itab> type standard table.
  data: da_return   type table of ddshretval with header line,
        da_retfield type dfies-fieldname,
        da_valuetab type ref to data.
  data: da_display,
        da_pvalkey                  type ddshpvkey.


  create data da_valuetab like standard table of da_008.
  assign da_valuetab->* to <itab>.
  move da_008tab to <itab>.
  sort <itab> ascending.
  da_retfield   = 'AUART'.
  case key4.
    when '0'.   "order VA01/02/03
      da_pvalkey    = 'NUMBER008'.
    when '1'.   "inquiry VA11/12/13
      da_pvalkey    = 'NUMBER018'.
    when '2'.   "quotation VA21/22/23
      da_pvalkey    = 'NUMBER028'.
    when '3'.   "scheduling agreement VA31/32/33
      da_pvalkey    = 'NUMBER038'.
    when '4'.   "contract VA41/42/43
      da_pvalkey    = 'NUMBER048'.
    when '5'.   "item proposal VA51/52/53
      da_pvalkey    = 'NUMBER058'.
  endcase.

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = da_retfield
      pvalkey         = da_pvalkey
      value_org       = 'S'
      window_title    = da_titel
    tables
      value_tab       = <itab>
      return_tab      = da_return
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.

  field = da_return-fieldval.
  call function 'CONVERSION_EXIT_AUART_INPUT'
    exporting
      input  = field
    importing
      output = field.
  loop at da_008tab into da_008 where auart = field.
  endloop.
  description = da_008-bezei.


endform.
*&---------------------------------------------------------------------*
*& Form CLEAR_ORDER_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form clear_order_text .

  clear : tvakt, tvkot, tvtwt, tspat, tvkbt, tvgrt.

endform.
*&---------------------------------------------------------------------*
*& Form GET_F4_PERNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      <--P_L_PERNR  text
*      <--P_L_NAME  text
*&---------------------------------------------------------------------*
form get_f4_pernr  changing pv_pernr
                             pv_sname.

  data: begin of lt_pernr occurs 0,
          pernr like pa0001-pernr,
          sname like pa0001-sname,
        end of lt_pernr,
        l_pernr like  pa0001-pernr.
  data : lt_return type table of ddshretval with header line.
  data : lt_dynpfields like table of dynpread with header line,
         save_line     type i.

  refresh: lt_pernr.  clear : lt_pernr, l_pernr.

**  select pernr sname from zlts1100t
**         into table lt_pernr
**         where vkorg eq p_vkorg
**           and vkgrp eq p_vkgrp.
**  if sy-subrc = 0.
**    sort lt_pernr by sname pernr.
**  endif.

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = 'PERNR'          " 참조되는 dictionary
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
*     DYNPROFIELD     = P_TEXT    " 화면상의 해당 필드명
      window_title    = text-t34
      value_org       = 'S'
    tables
      value_tab       = lt_pernr
      return_tab      = lt_return
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.
  if sy-subrc <> 0.
    exit.
  else.

    read table lt_return index 1.
    if sy-subrc  = 0.
      pv_pernr = lt_pernr-pernr.
      pv_sname = lt_pernr-sname.
    endif.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form CALL_VA02
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form call_va02 .

  set parameter id 'AUN'   field gs_200-vbeln_va.

  call transaction 'VA02' and skip first screen.  " SO 변경

endform.
*&---------------------------------------------------------------------*
*& Form INSERT_LOG_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_       text
*&---------------------------------------------------------------------*
form insert_log_data  using    value(pv_prcty).

*-- log data를 저장한다.
*--   'SC' - 생성
*--   'SR' - 조회
*--   'SU' - 수정


**  data ls_9004dt  like zlts9004dt.
**
**  clear ls_9004dt.
**  select single * into ls_9004dt   from zlts9004dt
**   where logdt    = sy-datum
**     and bukrs    = gv_bukrs
**     and logty    = c_o
**     and logid    = sy-uname
**     and funcname = sy-repid
**     and prcty    = pv_prcty.
**
**  if sy-subrc = 0.
**    ls_9004dt-prcnt    = ls_9004dt-prcnt + 1.
**
**    ls_9004dt-aedat    = sy-datum.
**    ls_9004dt-aezet    = sy-uzeit.
**    ls_9004dt-aenam    = sy-uname.
**    ls_9004dt-aewid    = sy-uname.
**  else.
**    ls_9004dt-logdt    = sy-datum.
**    ls_9004dt-bukrs    = gv_bukrs.
**    ls_9004dt-logty    = c_o.
**    ls_9004dt-logid    = sy-uname.
**    ls_9004dt-funcname = sy-repid.
**    ls_9004dt-prcty    = pv_prcty.
**    ls_9004dt-prcnt    = 1.
**
**    ls_9004dt-erdat    = sy-datum.
**    ls_9004dt-erzet    = sy-uzeit.
**    ls_9004dt-ernam    = sy-uname.
**    ls_9004dt-erwid    = sy-uname.
**    ls_9004dt-aedat    = sy-datum.
**    ls_9004dt-aezet    = sy-uzeit.
**    ls_9004dt-aenam    = sy-uname.
**    ls_9004dt-aewid    = sy-uname.
**
**  endif.
**
**  modify zlts9004dt from ls_9004dt.


endform.
*&---------------------------------------------------------------------*
*& Form COLLECT_PARTIAL_DO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form collect_partial_do .


**  data: begin of lt_so occurs 0,
**          vbeln_va like vbak-vbeln,
**          posnr_va like vbap-posnr,
**          dlvcnt   type i,
**          billcnt  type i,
**          lfimg    like lips-lfimg,
**        end of lt_so.
**
**  loop at gt_detail.
**    clear lt_so.
**    move-corresponding gt_detail to lt_so.
**    if gt_detail-vbeln_vl is not initial.
**      lt_so-dlvcnt = 1.
**    endif.
**    if gt_detail-vbeln_vf is not initial.
**      lt_so-billcnt = 1.
**    endif.
**    collect lt_so.
**
**  endloop.
**
**  sort gt_detail by vbeln_va posnr_va.
**  delete adjacent duplicates from gt_detail comparing vbeln_va posnr_va.
**
**  sort lt_so by vbeln_va posnr_va.
**  loop at gt_detail.
**    read table lt_so with key vbeln_va = gt_detail-vbeln_va
**                                              posnr_va = gt_detail-posnr_va binary search.
**    if sy-subrc = 0.
**      if lt_so-dlvcnt > 1.
**        gt_detail-vbeln_vl = lt_so-dlvcnt.
**        gt_detail-lfimg = lt_so-lfimg.
**        clear gt_detail-posnr_vl.
**        clear gt_detail-wadat.
**        clear gt_detail-zbudat.
**        clear gt_detail-wadat_ist.
**        clear gt_detail-ztext.
**      endif.
**      if lt_so-billcnt > 1.
**        gt_detail-vbeln_vf = lt_so-billcnt.
**      endif.
**      modify gt_detail.
**    endif.
**  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form F4_VBELN_VL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      <--P_AA  text
*&---------------------------------------------------------------------*
form f4_vbeln_vl  using pv_vbeln_va pv_posnr_va
                                  changing pv_vbeln_vl.

  data: begin of lt_do occurs 0,
          vbeln     like likp-vbeln,
          posnr     like lips-posnr,
*          UECHA     LIKE LIPS-UECHA,
          lfimg     like lips-lfimg,
          vrkme     like lips-vrkme,
          wadat     like likp-wadat,
          zbudat    type datum,  " like likp-zbudat,
          wadat_ist like likp-wadat_ist,
        end of lt_do.
  data: begin of lt_do_batch occurs 0.
          include structure lt_do.
  data:   uecha like lips-uecha,
        end of lt_do_batch.

  data : lt_return type table of ddshretval with header line.
  data : lt_dynpfields like table of dynpread with header line,
         save_line     type i.

  refresh: lt_do.  clear : lt_do, pv_vbeln_vl .

  select a~vbeln
           b~posnr
           b~uecha
           a~wadat_ist
           "a~zbudat
           a~wadat
           b~vrkme
           b~lfimg
      into corresponding fields of table lt_do_batch
      from likp as a inner join lips as b
                                   on a~vbeln = b~vbeln
where b~vgbel = pv_vbeln_va
         and b~vgpos = pv_posnr_va.

  "배치수량을 10번 ITEM으로 올려줌
*  LT_DO_BATCH[] = LT_DO[].
*  DELETE LT_DO_BATCH WHERE UECHA IS INITIAL.
*  DELETE LT_DO       WHERE UECHA IS NOT INITIAL.

  loop at lt_do_batch .
    move-corresponding lt_do_batch to lt_do.
    if lt_do_batch-uecha is not initial.
      lt_do-posnr = lt_do_batch-uecha .

    endif.
    collect lt_do.
    clear lt_do.
  endloop.

*  MODIFY LT_DO.
*ENDLOOP.

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = 'VBELN'          " 참조되는 dictionary
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
*     DYNPROFIELD     = P_TEXT    " 화면상의 해당 필드명
*     WINDOW_TITLE    = TEXT-T34
      value_org       = 'S'
    tables
      value_tab       = lt_do
      return_tab      = lt_return
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.
  if sy-subrc <> 0.
    exit.
  else.

    read table lt_return index 1.
    if sy-subrc  = 0.
      pv_vbeln_vl = lt_return-fieldval.
    endif.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form F4_VBELN_VF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      <--P_AA  text
*&---------------------------------------------------------------------*
form f4_vbeln_vf  using pv_vbeln_va pv_posnr_va
                                  changing pv_vbeln_vf.

  data: begin of lt_do occurs 0,
          vbeln     like likp-vbeln,
          posnr     like lips-posnr,
*          UECHA     LIKE LIPS-UECHA,
          lfimg     like lips-lfimg,
          vrkme     like lips-vrkme,
          wadat     like likp-wadat,
          zbudat    type datum, "like likp-zbudat,
          wadat_ist like likp-wadat_ist,
        end of lt_do.
  data: begin of lt_do_batch occurs 0.
          include structure lt_do.
  data:   uecha like lips-uecha,
        end of lt_do_batch.

  data: begin of lt_bill occurs 0,
          vbeln like vbrk-vbeln,
          posnr like vbrp-posnr,
          fkdat like vbrk-fkdat,
        end of lt_bill.


  data : lt_return type table of ddshretval with header line.
  data : lt_dynpfields like table of dynpread with header line,
         save_line     type i.

  refresh: lt_do, lt_bill.  clear : lt_do, pv_vbeln_vf .

  select a~vbeln
           b~posnr
           b~uecha
           a~wadat_ist
           "a~zbudat
           a~wadat
           b~vrkme
           b~lfimg
      into corresponding fields of table lt_do_batch
      from likp as a inner join lips as b
                                   on a~vbeln = b~vbeln
where b~vgbel = pv_vbeln_va
         and b~vgpos = pv_posnr_va.

  "배치수량을 10번 ITEM으로 올려줌
*  LT_DO_BATCH[] = LT_DO[].
*  DELETE LT_DO_BATCH WHERE UECHA IS INITIAL.
*  DELETE LT_DO       WHERE UECHA IS NOT INITIAL.

  loop at lt_do_batch .
    move-corresponding lt_do_batch to lt_do.
    if lt_do_batch-uecha is not initial.
      lt_do-posnr = lt_do_batch-uecha .

    endif.
    collect lt_do.
    clear lt_do.
  endloop.

  if lt_do[] is not initial.
    select a~vbeln   as vbeln
           b~posnr   as posnr
           a~fkdat   as fkdat
      into corresponding fields of table lt_bill
      from vbrk as a inner join vbrp as b  on a~vbeln = b~vbeln
       for all entries in lt_do
     where b~vgbel = lt_do-vbeln
       and b~vgpos = lt_do-posnr
       and a~sfakn eq ''    " 취소
       and a~fksto eq ''.   " 취소
  endif.

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = 'VBELN'          " 참조되는 dictionary
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
*     DYNPROFIELD     = P_TEXT    " 화면상의 해당 필드명
*     WINDOW_TITLE    = TEXT-T34
      value_org       = 'S'
    tables
      value_tab       = lt_bill
      return_tab      = lt_return
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.
  if sy-subrc <> 0.
    exit.
  else.

    read table lt_return index 1.
    if sy-subrc  = 0.
      pv_vbeln_vf = lt_return-fieldval.
    endif.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form F4_ALV_DEF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_P_ALV  text
*&---------------------------------------------------------------------*
form f4_alv_def  using   p_variant like gs_variant-variant.
  data: ls_variant type disvariant.
  clear: ls_variant, gs_variant.

  move sy-repid to gs_variant-report.

* Layout selection
  call function 'REUSE_ALV_VARIANT_F4'
    exporting
      is_variant = gs_variant
      i_save     = 'A'
    importing
      e_exit     = g_exit
      es_variant = ls_variant
    exceptions
      not_found  = 2.

  if sy-subrc = 2.
    message id     sy-msgid
            type  'S'
            number sy-msgno
            with   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.

    if g_exit ne c_x.
* set name of layout on selection screen
      gs_variant = p_alv    = ls_variant-variant.
    endif.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form ALV_CHECK_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form alv_check_layout .
  if not p_alv is initial.
    move: sy-repid to gs_variant-report,
          p_alv    to gs_variant-variant.

    call function 'REUSE_ALV_VARIANT_EXISTENCE'
      exporting
        i_save     = 'A'
      changing
        cs_variant = gs_variant
      exceptions
        others     = 1.

    if sy-subrc <> 0.
      message e321(m7) with p_alv sy-repid.
    endif.
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form AUTH_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form auth_check .
**  authority-check object 'V_VBAK_VKO'
**                  id 'VKORG'  field  p_vkorg
**                  id 'ACTVT'  field '03'.
**
**  if sy-subrc <> 0.
**    message s000 with text-f01 display like 'E'.
**    stop.
**  endif.

endform.
*&---------------------------------------------------------------------*
*& Form GET_LMDNO_BY_KUNNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_lmdno_by_kunnr .

**  clear: gs_salesopp, gt_salesopp[].
**
**  check zotc1642s-vkorg is not initial.
**  check zotc1643s-kunag is not initial.
**
**  select distinct b~kunag
**                  b~lmdno
**                  b~subjt
**                  c~matnr
**                  c~seqno
**    into corresponding fields of table gt_salesopp
**    from zlts0320t as a inner join zlts0180t as b
**                           on a~lmdno = b~lmdno
**                          and a~stage = b~stage
**                        inner join zlts0340t as c
**                           on c~lmdno = b~lmdno
**                          and c~stage = b~stage
**   where a~kunag = zotc1643s-kunag
**     and b~vkorg = zotc1642s-vkorg
**     and b~lmstt = 'W'.  "수주인것만 추가함.
**  sort gt_salesopp by lmdno.
**
**  read table gt_salesopp into gs_salesopp index 1.
**  if sy-subrc = 0.
**    zotc1643s-zzlmdno = gs_salesopp-lmdno.  "default로 넣어줌
**  endif.

endform.

*&---------------------------------------------------------------------*
*& Form get_d365_21_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_d365_21_data  tables  pt_sales type ty_vbap_tab
                               pt_021 structure zsdt_d365_021.

  data: lv_week     type scal-week,
        lv_bweek    like zsdt_d365_020-week,
        lv_max_week like zsdt_d365_020-week.

  "-- 현재시점 max주차를 찾아온다.
  call function 'GET_WEEK_INFO_BASED_ON_DATE'
    exporting
      date = gv_bdate
    importing
      week = lv_week.

  lv_bweek = lv_week.
  clear lv_max_week.

  select single week into @lv_max_week
    from zsdt_d365_020
   where pltype   = 'SP'
     and cycltype = 'W'
     and vkbur    = @p_vkbur
     and week     = @lv_bweek.
  if sy-subrc = 0 and lv_max_week is not initial.
  else.
    select max( week ) into @lv_max_week
      from zsdt_d365_020
     where pltype   = 'SP'
       and cycltype = 'W'
       and vkbur    = @p_vkbur.
  endif.

  gv_max_week = lv_max_week.  "판매계획의 가장 최신 주차


  "-- where 조건은 삭제시에도 같은 로직을 사용한다.

  select a~*
    from zsdt_d365_021 as a
   where a~pltype   = 'SP'
     and a~cycltype = 'W'
     and a~week  = @lv_max_week
     and a~vkbur = @p_vkbur
     and a~pernr = @p_pernr
*     and b~erdat in @s_erdat     "주문생성일
     and a~vbeln in @s_vbeln     "주문번호
     and a~kunnr in @s_kunag     "판매처
     and a~zpjno in @s_zpjno    "프로젝트
    into corresponding fields of table @pt_021.


  move-corresponding pt_021[] to pt_sales[].

endform.
*&---------------------------------------------------------------------*
*& Form get_sales_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_so_data  tables  pt_sales type ty_vbap_tab
                          pt_so    type ty_so_tab.

  check pt_sales[] is not initial.

  data lt_sales type ty_vbap_tab.

  move-corresponding pt_sales[] to lt_sales[].
  sort lt_sales by vbeln posnr seqno.
  delete adjacent duplicates from lt_sales comparing vbeln posnr. " seqno.


  select  ak~vbeln as vbeln_va,
                  ap~posnr as posnr_va,
                  ak~vkorg,
                  ak~vkbur,
                  ak~vkgrp,
                  ak~vtweg,
                  ak~spart,
                  ak~kunnr,
                  ap~matnr,
                  ap~arktx,
                  ak~vbtyp,
                  case when ak~vbtyp eq 'H' or ak~vbtyp eq 'K'
                       then ap~netwr * -1
                       else ap~netwr end as netwr,
                  e~edatu,
                  e~ordqty_su,
                  ak~zpjno,
                  d~atwrt as scr_grade,
                  ak~waerk,
                  ap~waerk  as waers,
                  case when ak~vbtyp eq 'H' or ak~vbtyp eq 'K'
                       then ap~kwmeng * -1
                       else ap~kwmeng end as kwmeng,
                  ap~vrkme,
                  ap~prodh,
                  ap~abgru,
                  sa~seqno,
                  g~lifnr,
                  h~zptxt
    from  vbak as ak inner join vbap as ap on ak~vbeln = ap~vbeln
                     inner join @lt_sales as sa on ap~vbeln = sa~vbeln
                                               and ap~posnr = sa~posnr
                     inner join vbep as e  on ap~vbeln = e~vbeln and ap~posnr = e~posnr and e~etenr = '0001'
                     inner join vbkd as f  on ak~vbeln = f~vbeln  and f~posnr = '000000'
                     inner join vbpa as g  on ak~vbeln = g~vbeln
                                          and g~posnr = '000000'
                                          and g~parvw = 'VE'
                      left join zgtmm_cv_bd_get_vcofso as d
                                           on ap~vbeln eq d~vbeln
                                          and ap~posnr eq d~posnr
                                          and ap~werks eq d~werks
                                          and d~atinn eq @gv_atinn
                      left join zsd0106t as h on ak~zpjno = h~zpjno

    into corresponding fields of table @pt_so.


endform.
*&---------------------------------------------------------------------*
*& Form get_d365_26_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_d365_26_data tables pt_so type ty_so_tab
                              pt_026 structure zsdt_d365_026.

  check pt_so[] is not initial.

  select *
    into corresponding fields of table pt_026
    from zsdt_d365_026
     for all entries in pt_so
   where vbeln_va = pt_so-vbeln_va
     and posnr_va = pt_so-posnr_va.

  delete pt_026 where plqty = 0.

endform.
*&---------------------------------------------------------------------*
*& Form get_d365_27_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_d365_27_data tables pt_027 structure zsdt_d365_027.

*  data : lv_stdate      type sy-datum,
*         lv_week        type scal-week,
*         lv_week_monday type datum,
*         lv_week_sunday type datum.


*  if gv_read_new = 'X'.
*
*    lv_stdate = gv_week_monday. "오늘주차의 월요일
*
*    if lv_stdate(6) <> sy-datum(6).
*      lv_stdate = sy-datum(6) && '01'.
*    endif.
*
*  else.
*
*    lv_week = gv_max_week.
*
*    call function 'WEEK_GET_FIRST_DAY'
*      exporting
*        week         = lv_week
*      importing
*        date         = lv_stdate
*      exceptions
*        week_invalid = 1
*        others       = 2.
*
*    call function 'GET_WEEK_INFO_BASED_ON_DATE'
*      exporting
*        date   = lv_stdate
*      importing
*        monday = lv_week_monday
*        sunday = lv_week_sunday.
*
*    if lv_week_monday(6) <> lv_week_sunday(6).
*      lv_stdate = lv_week_sunday(6) && '01'.
*    endif.
*
*  endif.


  "-- 27 table 삭제는 화면에서 delete한 데이터만 삭제한다.
  if s_vbeln[] is not initial.
    "-- 27 table에 vbeln가 없으므로 대상에서 제외한다.
  else.
    select *
      from zsdt_d365_027
     where vkbur = @p_vkbur
       and pernr = @p_pernr
       and spmon >= @gv_bdate(6)
*    and fkdat >= @lv_stdate
       and kunnr in @s_kunag
       and zpjno in @s_zpjno
      into corresponding fields of table @pt_027.
  endif.

  gt_027_chk[] = pt_027[].

endform.
*&---------------------------------------------------------------------*
*& Form get_bl_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_bl_data tables  pt_do type ty_do_tab
                          pt_so type ty_so_tab
                          pt_bl type ty_bl_tab.

  if pt_do[] is not initial.

    select a~vbeln,
           b~posnr,
           b~vgbel   as vbeln_vl,
           b~vgpos   as posnr_vl,
           b~aubel   as vbeln_va,
           b~aupos   as posnr_va,
           b~matnr,
           a~fkdat,
           b~netwr,
           b~fkimg,
           b~vrkme,
           a~waerk,
           a~kurrf,
           a~fkart
      from vbrk as a inner join vbrp as b  on a~vbeln = b~vbeln
       for all entries in @pt_do
     where a~vkorg = @p_vkorg
**       and a~fkart <> 'ZF2'
       and b~vgbel = @pt_do-vbeln_vl
       and b~vgpos = @pt_do-posnr_vl
       and a~sfakn eq ''   " 취소
       and a~fksto eq ''   " 취소
      into table @data(lt_bl).

  endif.

  loop at lt_bl assigning field-symbol(<fs>).

    read table pt_so into gs_so with key vbeln_va = <fs>-vbeln_va
                                         posnr_va = <fs>-posnr_va.

    clear gs_bl.
    gs_bl-vbeln_vf  = <fs>-vbeln.
    gs_bl-posnr_vf  = <fs>-posnr.
    gs_bl-vbeln_vl  = <fs>-vbeln_vl.
    gs_bl-posnr_vl  = <fs>-posnr_vl.
    gs_bl-vbeln_va  = <fs>-vbeln_va.
    gs_bl-posnr_va  = <fs>-posnr_va.
    gs_bl-fkdat     = <fs>-fkdat.
    if gs_so-vbtyp = 'H' or gs_so-vbtyp = 'K'.
      gs_bl-netwr   = <fs>-netwr * -1.
      gs_bl-fkimg   = <fs>-fkimg * -1.
    else.
      gs_bl-netwr   = <fs>-netwr.
      gs_bl-fkimg   = <fs>-fkimg.
    endif.
    gs_bl-waerk     = <fs>-waerk.
    gs_bl-vrkme     = <fs>-vrkme.
    gs_bl-waerk     = <fs>-waerk.
    gs_bl-matnr     = <fs>-matnr.
*    gt_do-pernr      = gt_main-pernr.
    gs_bl-kunnr     = gs_so-kunnr.
    gs_bl-kurrf     = <fs>-kurrf.
    gs_bl-fkart     = <fs>-fkart.
**    gs_bl-vbtyp     = gs_so-vbtyp.

    collect gs_bl into pt_bl.

  endloop.

  "------------------------------------------
  "--- do 없이 빌링이 처리된 경우

  if pt_so[] is not initial.

    select a~vbeln,
           b~posnr,
           b~vgbel   as vbeln_vl,
           b~vgpos   as posnr_vl,
           b~aubel   as vbeln_va,
           b~aupos   as posnr_va,
           b~matnr,
           a~fkdat,
           b~netwr,
           b~fkimg,
           b~vrkme,
           a~waerk,
           a~kurrf,
           a~fkart
      from vbrk as a inner join vbrp as b  on a~vbeln = b~vbeln
       for all entries in @pt_so
     where a~vkorg = @p_vkorg
**       and a~fkart <> 'ZF2'
       and b~vgbel = @pt_so-vbeln_va
       and b~vgpos = @pt_so-posnr_va
       and b~aubel = @pt_so-vbeln_va
       and b~aupos = @pt_so-posnr_va
       and a~sfakn eq ''   " 취소
       and a~fksto eq ''   " 취소
      into table @data(lt_bl_so).

  endif.

  loop at lt_bl_so assigning field-symbol(<bl_so>).

    read table pt_so into gs_so with key vbeln_va = <bl_so>-vbeln_va
                                         posnr_va = <bl_so>-posnr_va.

    clear gs_bl.
    gs_bl-vbeln_vf  = <bl_so>-vbeln.
    gs_bl-posnr_vf  = <bl_so>-posnr.
*    gs_bl-vbeln_vl  = <bl_so>-vbeln_vl.
*    gs_bl-posnr_vl  = <bl_so>-posnr_vl.
    gs_bl-vbeln_va  = <bl_so>-vbeln_va.
    gs_bl-posnr_va  = <bl_so>-posnr_va.
    gs_bl-fkdat     = <bl_so>-fkdat.
    if gs_so-vbtyp = 'H' or gs_so-vbtyp = 'K'.
      gs_bl-netwr   = <bl_so>-netwr * -1.
      gs_bl-fkimg   = <bl_so>-fkimg * -1.
    else.
      gs_bl-netwr   = <bl_so>-netwr.
      gs_bl-fkimg   = <bl_so>-fkimg.
    endif.
    gs_bl-waerk     = <bl_so>-waerk.
    gs_bl-vrkme     = <bl_so>-vrkme.
    gs_bl-waerk     = <bl_so>-waerk.
    gs_bl-matnr     = <bl_so>-matnr.
*    gt_do-pernr      = gt_main-pernr.
    gs_bl-kunnr     = gs_so-kunnr.
**    gs_bl-vbtyp     = gs_so-vbtyp.
    gs_bl-kurrf     = <bl_so>-kurrf.
    gs_bl-fkart     = <bl_so>-fkart.

    collect gs_bl into pt_bl.

  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form get_exch_kurrency
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_DETAIL
*&---------------------------------------------------------------------*
form get_exch_kurrency  changing ps_detail structure zgtsds0042.

  data : lv_num(3) type n,
         lv_versi  type zpls1300t-versi.

  lv_num   = 40 + ps_detail-erdat_vl+4(2).
  lv_versi = lv_num.


  select a~bukrs, a~pyear, a~versi, a~fcurr, a~ukurs00, a~ukurs01,
         a~ukurs02, a~ukurs03, c~xfeld, c~ffact
    from zpls1300t as a left outer join zpls1301t as c
                                    on a~bukrs = c~bukrs
                                   and a~fcurr = c~fcurr
   where a~bukrs = @gv_bukrs
     and a~pyear = @ps_detail-sale_date(4)
     and a~versi = @lv_versi
    into table @data(lt_curb).

  read table lt_curb into data(ls_curb) with key fcurr = ps_detail-waerk.
  check sy-subrc = 0.

  data : lv_num2(2)   type n,
         lv_fname(30).
  field-symbols : <ukursxx>.

  lv_num2 = ps_detail-sale_date+4(2) - ps_detail-erdat_vl+4(2).
  lv_fname = 'ls_curb-ukurs' && lv_num2.
  assign (lv_fname) to <ukursxx>.
  if sy-subrc = 0 and <ukursxx> is assigned.
    ps_detail-kursf = <ukursxx>.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form get_so
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_sales_order tables  pt_sales type ty_vbap_tab.


  select  ak~vbeln,
          ap~posnr,
          ap~kwmeng,
          ap~klmeng,
          sum( e~dlvqty_bu ) as dlvqty_bu
    from  vbak as ak inner join vbap as ap on ak~vbeln = ap~vbeln
                     inner join vbep as e  on ap~vbeln = e~vbeln and ap~posnr = e~posnr "and e~etenr = '0001'
                     inner join vbkd as f  on ak~vbeln = f~vbeln  and f~posnr = '000000'
                     inner join vbpa as g  on ak~vbeln = g~vbeln
                                          and g~posnr = '000000'
                                          and g~parvw = 'VE'
   where ap~erdat in @s_erdat       "주문생성일
     "and ak~erdat in @s_erdat       "주문생성일
     and ak~vkbur eq @p_vkbur       "영업팀
     and g~lifnr  in @gr_so_pernr   "영업사원
     and ak~vbeln in @s_vbeln
     and ak~kunnr in @s_kunag
     and ak~zpjno in @s_zpjno
     and ak~augru <> '150'  " 선수금 오더 제외
     and ak~auart in ( 'TA','ZEXE','Z3RD','ZBC2', 'RE' )
     and ak~spart not in ( '33','36' )  "시공 제외
*     and ap~abgru in  ('', '94','95','96','Z1','Z2' )
    group by ak~vbeln,
          ap~posnr,
          ap~kwmeng,
          ap~klmeng
    into corresponding fields of table @pt_sales.

  sort pt_sales by vbeln posnr.

  "-- 전량 적송매출(ZBC2)된 원오더(TA, ZEXE, Z3RD, ZBC2)는 중복 방지를 위해서 제외함
  if pt_sales[] is not initial.
    select a~*
      from vbfa as a inner join vbak as b on a~vbeln = b~vbeln
                                         and b~auart = 'ZBC2'
       for all entries in @pt_sales
     where vbelv   = @pt_sales-vbeln
       and posnv   = @pt_sales-posnr
       and vbtyp_n = 'C'
    into table @data(lt_vbfa).

    sort lt_vbfa by vbelv posnv erdat.

    data: lv_rfmng type klmeng,
          lv_erdat type datum.

    loop at pt_sales where dlvqty_bu > 0.

      clear: lv_rfmng, lv_erdat.

      loop at lt_vbfa into data(ls_vbfa) where vbelv = pt_sales-vbeln
                                           and posnv = pt_sales-posnr.
        if ls_vbfa-erdat <> lv_erdat and lv_erdat is not initial.
          exit.
        endif.
        lv_rfmng += ls_vbfa-rfmng.
        lv_erdat  = ls_vbfa-erdat.
      endloop.

      if pt_sales-dlvqty_bu <= lv_rfmng.
        delete pt_sales.
      endif.

*      "-- 제일 빠른 오더 하나만 비교한다.
*      read table lt_vbfa with key vbelv = pt_sales-vbeln
*                                  posnv = pt_sales-posnr
*                                  into data(ls_vbfa)
*                                  binary search.
*      if sy-subrc = 0.
*        if pt_sales-klmeng <= ls_vbfa-rfmng.
*          delete pt_sales.
*        endif.
*      endif.
    endloop.

  endif.

endform.
*&---------------------------------------------------------------------*
*& Form split_and_move_12
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SO
*&      --> GV_WEEK_MONTH
*&---------------------------------------------------------------------*
form split_and_move  tables pt_data type ty_so_tab
                             pt_026 structure zsdt_d365_026.

**
**  data lt_split  like table of zsdt_d365_026  with header line.
**  data lt_so     type table of ty_so with header line.
**  data lt_new_so type table of ty_so with header line.
**  data ls_data   type ty_so.
**
**  lt_so[] = pt_data[].
**
**  sort lt_so by vbeln_va posnr_va.
**  check lt_so[] is not initial.
**
**  lt_split[] = pt_026[].
**
**  "-- 수량 맞추기
**  "  원본의 날짜를 cbo의 가장 늦은 날짜로  바꾸고
*** 원본의 수량을 CBO 수량으로 netting 한 다음
*** 남은 원본의 수량과 날짜를 추가 함.
**  sort lt_split by vbeln_va posnr_va gidat descending bldat descending.
**
**  loop at lt_so.
**    read table lt_split with key vbeln_va = lt_so-vbeln_va
**                                 posnr_va = lt_so-posnr_va binary search.
**    if sy-subrc = 0.
**      if lt_split-excep <> 'X'.  "제외대상이 아니면
**
**        lt_so-edatu = lt_split-bldat.
**        loop at lt_split where vbeln_va = lt_so-vbeln_va
**                           and posnr_va = lt_so-posnr_va.
**
**          move-corresponding lt_so to lt_new_so.
**          lt_new_so-seqno = lt_split-seqno.
**          lt_new_so-bldat = lt_split-bldat.
****          lt_new_so-wadat_ist = lt_split-gidat.  "출하?
**          if lt_so-plqty > lt_split-plqty.
**            lt_new_so-plqty = lt_split-plqty.
**          endif.
**          lt_new_so-remark = lt_split-remark.
**
**          lt_so-plqty = lt_so-plqty - lt_new_so-plqty.
**
**          append lt_new_so.
**          clear lt_new_so.
**
**          if lt_so-plqty <= 0.
**            exit.
**          endif.
**        endloop.
**
**      endif.
**    else.
**      move-corresponding lt_so to lt_new_so.
**      append lt_new_so.
**      clear lt_new_so.
**    endif.
**
**  endloop.
**
***--교체하기
**  refresh pt_data.
**
**  data lv_date like sy-datum.
**
***  if pv_spmon = sy-datum(6).
***    lv_date = sy-datum.
***  else.    "지난달 말일
***    lv_date = sy-datum(6) && '01'.
***    lv_date = lv_date - 1.
***  endif.
**
**  loop at lt_new_so.
**
**    move-corresponding lt_new_so to ls_data.
**
**    if ls_data-plqty = 0.
***--- check_exception_data 데이터틑 추후 고려함
***      pt_so-netwr =  pt_so-unit_price.
**    else.
***      pt_so-netwr = pt_so-unit_price * pt_so-plqty .
**      if ls_data-kwmeng = 0.
**        ls_data-plamt = ls_data-netpr * ls_data-plqty .
**      else.
**        ls_data-plamt = ls_data-netwr / ls_data-kwmeng * ls_data-plqty .
**      endif.
**    endif.
**
****    if ls_data-wadat_ist is initial.
****      ls_data-wadat_ist = ls_data-edatu.
****    endif.
****
****    if ls_data-wadat_ist < sy-datum.
****      ls_data-wadat_ist = lv_date.
****    endif.
**
****    if ls_data-edatu < sy-datum.
****      ls_data-edatu = lv_date.
****    endif.
**
**    append ls_data to pt_data.
**    clear pt_data.
**  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form update_so_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SO
*&---------------------------------------------------------------------*
form add_dlv_data  tables   pt_so type ty_so_tab
                            pt_do type ty_do_tab.

**  data : ls_so type ty_so.
**  data : lt_so type table of ty_so with empty key.
**  data : lt_gi type table of ty_do with empty key.
**  data : ls_gi type ty_do.
**  data : lv_tabix type sy-tabix.
**
****2) G/I 수량(billing 포함)
**  lt_gi[] = pt_do[].
**  delete lt_gi where not ( wadat_ist <> '00000000' and wbsta = 'C' ).
**  sort lt_gi by vbeln_va posnr_va.
**
**  lt_so[] = pt_so[].
**  sort lt_so by vbeln_va posnr_va ascending .
**  delete adjacent duplicates from lt_so comparing vbeln_va posnr_va.
**  check lt_so[] is not initial.
**
**
**  loop at lt_so into ls_so.
**    ls_so-netpr  = ls_so-netwr / ls_so-kwmeng.
**    modify lt_so from ls_so.
**  endloop.
**
**  refresh pt_so.
**
**  sort lt_gi by vbeln_va posnr_va.
**  loop at lt_so into ls_so.
**    read table lt_gi into ls_gi with key vbeln_va = ls_so-vbeln_va
**                                         posnr_va = ls_so-posnr_va binary search.
**    if sy-subrc = 0.
**      lv_tabix = sy-tabix.
**      loop at lt_gi from lv_tabix into ls_gi.
**        if ls_gi-vbeln_va <> ls_so-vbeln_va or ls_gi-posnr_va <> ls_so-posnr_va.
**          exit.
**        endif.
**        ls_so-vbeln_vl = ls_gi-vbeln_vl.
**        ls_so-posnr_vl = ls_gi-posnr_vl.
**        ls_so-plqty    = ls_so-plqty - ls_gi-lfimg.
**        ls_so-plamt    = 0.
**      endloop.
**
**      if ls_so-plqty > 0 and ls_so-plamt = 0.
**        ls_so-plqty = ls_so-plqty.
**        ls_so-plamt = ls_so-plqty * ls_so-netpr.
**        append  ls_so to pt_so.
**      elseif ls_so-plqty = 0 and ls_so-plamt = 0.
**        ls_so-plqty = ls_gi-lfimg.
**        ls_so-plamt = ls_so-plqty * ls_so-netpr.
**        append  ls_so to pt_so.
**      endif.
**
**    else.
**      ls_so-plqty = ls_so-kwmeng.
**      append ls_so to pt_so.
**    endif.
**
**  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form SAVE_PLAN_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form save_plan_data .

  data l_rc type c.

  call function 'POPUP_TO_CONFIRM_STEP'
    exporting
      textline1      = '저장하겠습니까?'(902)
*     textline2      = gv_vbeln_new
      titel          = 'Confirmation'(904)
      cancel_display = 'X'
    importing
      answer         = l_rc.
  if l_rc <> 'J'.
    exit.
  endif.


  perform save_data.


  if sy-subrc = 0.  " 정상적으로 저장

    message s001 with '정상적으로 저장되었습니다.'.
    perform refresh_data_from_cbo.

*    gv_read_new = ''.  "판매계획에서 데이터 가져온다.
*
*    perform get_data.
*
*    call method g_alv_tree->free.
*    clear: g_alv_tree.
*
*    perform create_tree .
*    perform get_item_detail using gv_nkey_m0  c_so. "당주 데이터를 화면에
*
*    perform display_sub_grid.

  endif.


endform.
*&---------------------------------------------------------------------*
*& Form save_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form save_data .

  data : lv_msg  type message-msgtx,
         lv_num  type char10,
         ls_main like zgtsds0042,
         ls_020  like zsdt_d365_020,
         ls_021  like zsdt_d365_021,
         ls_030  like zsdt_d365_030,
         ls_026  like zsdt_d365_026,
         ls_027  like zsdt_d365_027,
         lt_021  like table of zsdt_d365_021 with header line,
         lt_030  like table of zsdt_d365_030 with header line,
         lt_026  like table of zsdt_d365_026 with header line,
         lt_027  like table of zsdt_d365_027 with header line.

  "-- 환율 지정 여부를 확인(단, 통화≠T001-WAERS인 경우만)하여, 1개라도 없으면 Error 처리
  clear lv_msg.
  loop at gt_main into ls_main.
    if ls_main-waerk <> gv_waers and ls_main-kursf is initial.
      lv_msg = ls_main-waerk && ` Rolling 환율이 없습니다. 환율 등록을 먼저 요청하시기 바랍니다.`.
      exit.
    endif.
  endloop.

  if lv_msg is not initial.
    message s001 with lv_msg display like 'E'.
    sy-subrc = 4.
    exit.
  endif.

  "-- 판매계획 header 수정
  clear ls_020.
  select single *
    into corresponding fields of ls_020
    from zsdt_d365_020
   where week     = gv_bweek
     and pltype   = 'SP'
     and cycltype = 'W'
     and vkbur    = p_vkbur.
  if sy-subrc <> 0.
    ls_020-week     = gv_bweek.
    ls_020-pltype   = 'SP'.
    ls_020-cycltype = 'W'.
    ls_020-vkbur    = p_vkbur.
  endif.
  zcl_snop_rfc_funcntion=>update_timestamp( changing cs_data = ls_020 ).


  "-- 판매계획 item 추가
  loop at gt_main into ls_main.
    clear ls_021.

    perform get_next_number     changing  ls_021-dpid.
    perform populate_021_data   using     ls_main
                                changing  ls_021.

    perform make_timestamp      changing ls_021-createdon.
    perform make_timestamp      changing ls_021-modifiedon.

    "-- 삭제된 경우
    read table gt_026_del with key vbeln_va = ls_021-vbeln
                                   posnr_va = ls_021-posnr
                                   seqno    = ls_021-seqno
                                   vbeln_vl = ls_main-vbeln_vl
                                   posnr_vl = ls_main-posnr_vl.
    if sy-subrc = 0.
      "-- update에 있으면 삭제 아님
      read table gt_026_upd with key vbeln_va = ls_021-vbeln
                                     posnr_va = ls_021-posnr
                                     seqno    = ls_021-seqno
                                     vbeln_vl = ls_main-vbeln_vl
                                     posnr_vl = ls_main-posnr_vl.
      if sy-subrc <> 0.
        clear ls_021-seqno.
      endif.
    endif.

    append ls_021 to lt_021.

    "-- 30번 table용 데이터
    clear ls_030.

    ls_030-keyid  = ls_021-dpid.
    perform populate_030_data   using     ls_main
                                changing  ls_030.

    zcl_snop_rfc_funcntion=>update_timestamp( changing cs_data = ls_030 ).

    append ls_030 to lt_030.

  endloop.


  "--- 분할 데이터 저장
  loop at gt_026_upd.
    zcl_snop_rfc_funcntion=>update_timestamp( changing cs_data = gt_026_upd ).
    modify gt_026_upd.
  endloop.

  "--- 의지치 저장
  loop at gt_027_upd.
    zcl_snop_rfc_funcntion=>update_timestamp( changing cs_data = gt_027_upd ).
    modify gt_027_upd.
  endloop.

  "-- 기존 데이터 삭제
  delete from zsdt_d365_021
        where week     = gv_bweek
          and pltype   = 'SP'
          and cycltype = 'W'
          and vkbur    = p_vkbur
          and pernr   in gr_pernr
          and vbeln   in s_vbeln
          and kunnr   in s_kunag
          and zpjno   in s_zpjno.

  "-- 기존 데이터 삭제
  delete from zsdt_d365_030
        where vkbur    = p_vkbur
          and pernr   in gr_pernr
          and vbeln   in s_vbeln
          and kunnr   in s_kunag
          and zpjno   in s_zpjno.

  "-- 화면에서 삭제한 데이터를 delete처리함
  delete zsdt_d365_026 from table gt_026_del.
  delete zsdt_d365_027 from table gt_027_del.

  modify zsdt_d365_020 from ls_020.
  modify zsdt_d365_021 from table lt_021.
  modify zsdt_d365_026 from table gt_026_upd.
  modify zsdt_d365_027 from table gt_027_upd.
  modify zsdt_d365_030 from table lt_030.

  if sy-subrc = 0.
    commit work.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form GET_NEW_DATA_FROM_VBAK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_new_data_from_vbak .


  data l_rc type c.

  call function 'POPUP_TO_CONFIRM_STEP'
    exporting
      textline1      = '최신 주문 진행 현황을 반영한 SAP정보 갱신 작업을 하겠습니까?'(902)
*     textline2      = gv_vbeln_new
      titel          = 'Confirmation'(904)
      cancel_display = 'X'
    importing
      answer         = l_rc.

  check l_rc = 'J'.

  gv_read_new = 'X'.  "VBAK에서 데이터를 가져온다.

  perform get_data.


  if g_alv_tree is bound.
    call method g_alv_tree->free.
    free g_alv_tree.
  endif.

  "-- l_top_key를 1로 세팅하기 위해서 tree를 완전히 새로 생성해야함
  "-- node만 지워서는 key값이 계속 증가함
  perform init_tree.
  if gv_nkey_m0 is not initial.
    perform get_item_detail using gv_nkey_m0  c_so.
    perform set_selected_node_m0.
  endif.


endform.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GT_LIST_200[]
*&      --> GT_FCAT_200[]
*&---------------------------------------------------------------------*
form set_fieldcat_200  using value(pv_intrnname)
                             pt_table type standard table
                             pt_fcat  type lvc_t_fcat.

  field-symbols: <lfs_fieldcat> type lvc_s_fcat.
  data : ls_fcat                type lvc_s_fcat.

  data: gr_structdescr type ref to cl_abap_structdescr,
        gt_components  type abap_component_tab,
        gs_components  type abap_componentdescr.


  call function 'LVC_FIELDCATALOG_MERGE'
    exporting
      i_structure_name       = pv_intrnname
    changing
      ct_fieldcat            = pt_fcat
    exceptions
      inconsistent_interface = 1
      program_error          = 2
      others                 = 3.


  data lv_pos  type i.

  lv_pos = 0.
  loop at pt_fcat assigning <lfs_fieldcat>.

    case <lfs_fieldcat>-fieldname.
**      when 'VBELN_VL'.
***        <lfs_fieldcat>-just      = 'C'.
**        <lfs_fieldcat>-coltext   = 'DO 번호'.
**        <lfs_fieldcat>-scrtext_l = 'DO 번호'.
**        <lfs_fieldcat>-scrtext_m = 'DO 번호'.
**        <lfs_fieldcat>-scrtext_s = 'DO 번호'.
**      when 'GIDAT'.
***        <lfs_fieldcat>-just      = 'C'.
**        <lfs_fieldcat>-coltext   = '출하일'.
**        <lfs_fieldcat>-scrtext_l = '출하일'.
**        <lfs_fieldcat>-scrtext_m = '출하일'.
**        <lfs_fieldcat>-scrtext_s = '출하일'.
      when 'BLDAT'           .
*        <lfs_fieldcat>-just      = 'C'.
        <lfs_fieldcat>-edit      = 'X'.
        <lfs_fieldcat>-coltext   = '매출일'.
        <lfs_fieldcat>-scrtext_l = '매출일'.
        <lfs_fieldcat>-scrtext_m = '매출일'.
        <lfs_fieldcat>-scrtext_s = '매출일'.
      when 'PLQTY'           .
*        <lfs_fieldcat>-just      = 'C'.
        <lfs_fieldcat>-coltext   = '매출수량'.
        <lfs_fieldcat>-scrtext_l = '매출수량'.
        <lfs_fieldcat>-scrtext_m = '매출수량'.
        <lfs_fieldcat>-scrtext_s = '매출수량'.
      when 'REMARK'.
*        <lfs_fieldcat>-just      = 'C'.
        <lfs_fieldcat>-outputlen = '30'.
      when others.
        <lfs_fieldcat>-tech      = 'X'.
    endcase.

  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form update_main_detail_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form update_main_detail_data_200.

  data : ls_026  like zsdt_d365_026,
         ls_main like zgtsds0042,
         lt_main like zgtsds0042 occurs 0 with header line.

  clear lt_main[].

  "-- 기존의 data는 빼고 새로운 데이터로 채워준다.
  delete gt_026     where vbeln_va = gs_200-vbeln_va
                      and posnr_va = gs_200-posnr_va
                      and seqno    = gs_200-seqno
                      and vbeln_vl = gs_200-vbeln_vl
                      and posnr_vl = gs_200-posnr_vl.
  delete gt_026_upd where vbeln_va = gs_200-vbeln_va
                      and posnr_va = gs_200-posnr_va
                      and seqno    = gs_200-seqno
                      and vbeln_vl = gs_200-vbeln_vl
                      and posnr_vl = gs_200-posnr_vl.
  delete gt_main    where keyfd    = gs_200-keyfd.

  clear ls_026.

  "한번 분할한 무조건 라인은 삭제한다.
*  if gs_200-seqno is not initial. <<< 매출일변경인 경우
  ls_026-vbeln_va = gs_200-vbeln_va.
  ls_026-posnr_va = gs_200-posnr_va.
  ls_026-seqno    = gs_200-seqno.
  ls_026-vbeln_vl = gs_200-vbeln_vl.
  ls_026-posnr_vl = gs_200-posnr_vl.
  append ls_026 to gt_026_del.
*  endif.

  "-- 화면의 데이터로 채워준다.
  loop at gt_026_tmp.
    move-corresponding gs_200 to ls_main.

*      when '미출하'.        gs_main-bltype_nm = 'C'. => F
*      when '출하진행'.      gs_main-bltype_nm = 'D'. => G
*      when '출고'.          gs_main-bltype_nm = 'E'. => H
*      when '분할-미출하'.   gs_main-bltype_nm = 'F'.
*      when '분할-출하진행'. gs_main-bltype_nm = 'G'.
*      when '분할-출고'.     gs_main-bltype_nm = 'H'.

*    if ls_main-bltype ns '분할-'.
*      ls_main-bltype      = '분할-' && ls_main-bltype.
*    endif.

    case ls_main-bltype.
      when 'C'.
        ls_main-bltype = 'F'.
      when 'D'.
        ls_main-bltype = 'G'.
      when 'E'.
        ls_main-bltype = 'H'.
    endcase.

    ls_main-seqno         = gt_026_tmp-seqno.
    ls_main-spmon         = gt_026_tmp-bldat(6).
    ls_main-sale_date     = gt_026_tmp-bldat.
    ls_main-sale_qty      = gt_026_tmp-plqty.
    ls_main-sale_amt      = gs_200-sale_amt     * gt_026_tmp-plqty / gs_200-sale_qty.
    if ls_main-kursf > 0.
      perform calc_curency_exch    using    ls_main-sale_amt
                                            ls_main-kursf
                                            ls_main-sale_date
                                            ls_main-waerk
                                            'KRW'
                                  changing ls_main-sale_amt_krw.
    else.
      ls_main-sale_amt_krw  = gs_200-sale_amt_krw * gt_026_tmp-plqty / gs_200-sale_qty.
    endif.

    ls_main-remark        = gt_026_tmp-remark.

    append ls_main to lt_main.
  endloop.

  move-corresponding lt_main[] to gt_main[] keeping target lines.

  perform get_plan_data . "Tree 구성용 데이터


  move-corresponding gt_026_tmp[] to gt_026_upd[] keeping target lines.


endform.
*&---------------------------------------------------------------------*
*& Form GET_NEXT_NUMBER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_021_DPID
*&---------------------------------------------------------------------*
form get_next_number  changing pv_dpid.

  data : lv_number type char10.

  call function 'NUMBER_GET_NEXT'
    exporting
      nr_range_nr             = '01'
      object                  = 'ZSNOP001'
*     QUANTITY                = '1'
*     SUBOBJECT               = ' '
*     TOYEAR                  = '0000'
*     IGNORE_BUFFER           = ' '
    importing
      number                  = lv_number
*     QUANTITY                =
*     RETURNCODE              =
    exceptions
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      others                  = 8.
  if sy-subrc <> 0.
    exit.
* Implement suitable error handling here
  endif.

  pv_dpid = lv_number.

endform.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GT_LIST_300[]
*&      --> GT_FCAT_300[]
*&---------------------------------------------------------------------*
form set_fieldcat_300  using value(pv_intrnname)
                             pt_table type standard table
                             pt_fcat  type lvc_t_fcat.

  field-symbols: <lfs_fieldcat> type lvc_s_fcat.
  data : ls_fcat                type lvc_s_fcat.

  data: gr_structdescr type ref to cl_abap_structdescr,
        gt_components  type abap_component_tab,
        gs_components  type abap_componentdescr.


  call function 'LVC_FIELDCATALOG_MERGE'
    exporting
      i_structure_name       = pv_intrnname
    changing
      ct_fieldcat            = pt_fcat
    exceptions
      inconsistent_interface = 1
      program_error          = 2
      others                 = 3.


  data lv_pos  type i.

  lv_pos = 0.
  loop at pt_fcat assigning <lfs_fieldcat>.

    lv_pos = lv_pos + 1.

    case <lfs_fieldcat>-fieldname.
      when 'SPMON'           .
        <lfs_fieldcat>-col_pos   = 1.
        <lfs_fieldcat>-just      = 'L'.
        <lfs_fieldcat>-f4availabl = 'X'.
        <lfs_fieldcat>-coltext   = '매출월'.
        <lfs_fieldcat>-scrtext_l = '매출월'.
        <lfs_fieldcat>-scrtext_m = '매출월'.
        <lfs_fieldcat>-scrtext_s = '매출월'.
      when 'KUNNR'           .
        <lfs_fieldcat>-col_pos   = 2.
        <lfs_fieldcat>-outputlen = '10'.
        <lfs_fieldcat>-coltext   = '판매처'.
        <lfs_fieldcat>-scrtext_l = '판매처'.
        <lfs_fieldcat>-scrtext_m = '판매처'.
        <lfs_fieldcat>-scrtext_s = '판매처'.
      when 'KUNNR_NM'           .
        <lfs_fieldcat>-col_pos   = 3.
        <lfs_fieldcat>-outputlen = '10'.
        <lfs_fieldcat>-coltext   = '판매처명'.
        <lfs_fieldcat>-scrtext_l = '판매처명'.
        <lfs_fieldcat>-scrtext_m = '판매처명'.
        <lfs_fieldcat>-scrtext_s = '판매처명'.
      when 'ZPJNO'           .
        <lfs_fieldcat>-col_pos   = 4.
        <lfs_fieldcat>-outputlen = '10'.
        <lfs_fieldcat>-coltext   = '프로젝트'.
        <lfs_fieldcat>-scrtext_l = '프로젝트'.
        <lfs_fieldcat>-scrtext_m = '프로젝트'.
        <lfs_fieldcat>-scrtext_s = '프로젝트'.
      when 'ZPTXT'           .
        <lfs_fieldcat>-col_pos   = 5.
        <lfs_fieldcat>-outputlen = '10'.
        <lfs_fieldcat>-coltext   = '프로젝트명'.
        <lfs_fieldcat>-scrtext_l = '프로젝트명'.
        <lfs_fieldcat>-scrtext_m = '프로젝트명'.
        <lfs_fieldcat>-scrtext_s = '프로젝트명'.
      when 'PRODH'           .
        <lfs_fieldcat>-col_pos   = 6.
        <lfs_fieldcat>-outputlen = '18'.
        <lfs_fieldcat>-coltext   = '제품계층구조'.
        <lfs_fieldcat>-scrtext_l = '제품계층구조'.
        <lfs_fieldcat>-scrtext_m = '제품계층구조'.
        <lfs_fieldcat>-scrtext_s = '제품계층구조'.
      when 'PRODH_NM'           .
        <lfs_fieldcat>-col_pos   = 7.
        <lfs_fieldcat>-outputlen = '20'.
        <lfs_fieldcat>-coltext   = '제품계층구조명'.
        <lfs_fieldcat>-scrtext_l = '제품계층구조명'.
        <lfs_fieldcat>-scrtext_m = '제품계층구조명'.
        <lfs_fieldcat>-scrtext_s = '제품계층구조명'.
      when 'MATNR'           .
        <lfs_fieldcat>-col_pos   = 8.
        <lfs_fieldcat>-outputlen = '10'.
        <lfs_fieldcat>-coltext   = '자재'.
        <lfs_fieldcat>-scrtext_l = '자재'.
        <lfs_fieldcat>-scrtext_m = '자재'.
        <lfs_fieldcat>-scrtext_s = '자재'.
      when 'MATNR_NM'           .
        <lfs_fieldcat>-col_pos   = 9.
        <lfs_fieldcat>-outputlen = '15'.
        <lfs_fieldcat>-coltext   = '자재명'.
        <lfs_fieldcat>-scrtext_l = '자재명'.
        <lfs_fieldcat>-scrtext_m = '자재명'.
        <lfs_fieldcat>-scrtext_s = '자재명'.
*      when 'UNITPRICE_KRW'           .
*        <lfs_fieldcat>-col_pos   = 8.
*        <lfs_fieldcat>-outputlen = '15'.
*        <lfs_fieldcat>-coltext   = '판가(KRW)'.
*        <lfs_fieldcat>-scrtext_l = '판가(KRW)'.
*        <lfs_fieldcat>-scrtext_m = '판가(KRW)'.
*        <lfs_fieldcat>-scrtext_s = '판가(KRW)'.
      when 'WAERS_KRW'           .
        <lfs_fieldcat>-col_pos   = 10.
        <lfs_fieldcat>-outputlen = '5'.
        <lfs_fieldcat>-coltext   = '통화'.
        <lfs_fieldcat>-scrtext_l = '통화'.
        <lfs_fieldcat>-scrtext_m = '통화'.
        <lfs_fieldcat>-scrtext_s = '통화'.
*      when 'QUANTITY'           .
*        <lfs_fieldcat>-col_pos   = 11.
*        <lfs_fieldcat>-outputlen = '12'.
*        <lfs_fieldcat>-coltext   = '매출수량'.
*        <lfs_fieldcat>-scrtext_l = '매출수량'.
*        <lfs_fieldcat>-scrtext_m = '매출수량'.
*        <lfs_fieldcat>-scrtext_s = '매출수량'.
*      when 'VRKME'           .
*        <lfs_fieldcat>-col_pos   = 10.
*        <lfs_fieldcat>-outputlen = '5'.
*        <lfs_fieldcat>-coltext   = '단위'.
*        <lfs_fieldcat>-scrtext_l = '단위'.
*        <lfs_fieldcat>-scrtext_m = '단위'.
*        <lfs_fieldcat>-scrtext_s = '단위'.
*        <lfs_fieldcat>-f4availabl = 'X'.            " F4 서치헬프 활성화
*        <lfs_fieldcat>-ref_table  = 'MARA'.         " MARA 테이블 참조
*        <lfs_fieldcat>-ref_field  = 'MEINS'.        " MEINS 필드 참조
*
**        <lfs_fieldcat>-f4availabl = 'X'.
**        <lfs_fieldcat>-checktable = 'T006'.
      when 'AMOUNT_KRW'           .
        <lfs_fieldcat>-col_pos   = 11.
        <lfs_fieldcat>-outputlen = '15'.
        <lfs_fieldcat>-coltext   = '매출액(KRW)'.
        <lfs_fieldcat>-scrtext_l = '매출액(KRW)'.
        <lfs_fieldcat>-scrtext_m = '매출액(KRW)'.
        <lfs_fieldcat>-scrtext_s = '매출액(KRW)'.
      when 'MARGINALPROFIT_PER' .
        <lfs_fieldcat>-col_pos   = 12.
        <lfs_fieldcat>-outputlen = '6'.
        <lfs_fieldcat>-coltext   = '한계이익률(%)'.
        <lfs_fieldcat>-scrtext_l = '한계이익률(%)'.
        <lfs_fieldcat>-scrtext_m = '한계이익률(%)'.
        <lfs_fieldcat>-scrtext_s = '한계이익률(%)'.
      when 'MARGINALPROFIT_KRW' .
        <lfs_fieldcat>-col_pos   = 13.
        <lfs_fieldcat>-outputlen = '15'.
        <lfs_fieldcat>-coltext   = '한계이익(KRW)'.
        <lfs_fieldcat>-scrtext_l = '한계이익(KRW)'.
        <lfs_fieldcat>-scrtext_m = '한계이익(KRW)'.
        <lfs_fieldcat>-scrtext_s = '한계이익(KRW)'.
      when 'REMARK'.
        <lfs_fieldcat>-col_pos   = 14.
        <lfs_fieldcat>-outputlen = '30'.
      when others.
        <lfs_fieldcat>-tech      = 'X'.
    endcase.

  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form modify_main_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form modify_main_list_fr_300 .

  data : lt_027_upd  type table of zsdt_d365_027.
  data : lt_main like zgtsds0042 occurs 0 with header line.

  "-- 초기_27 와 저장_27 를 비교하여, upd, del를 분류한다.
*  perform compare_before_after_data tables lt_027_upd.


  "-- 기존의 data는 빼고 새로운 데이터로 채워준다.
  delete gt_027     where vkbur = p_vkbur
                      and pernr = p_pernr.
  delete gt_027_upd where vkbur = p_vkbur
                      and pernr = p_pernr.
  delete gt_main    where bltype = 'A'.


  "----------------------------------------------------------
  "-- 의지치 데이터로만 새로 만들어 추가한다.
  "----------------------------------------------------------
  gt_027_upd[] = gt_027_tmp[].

  "---- 추가 데이터
  perform add_027_to_main   tables gt_027_upd   "-- 의지치 추가
                                   lt_main.

  perform add_text_to_main  tables lt_main. "-- text정보 추가

  move-corresponding lt_main[] to gt_main[] keeping target lines.

  perform get_plan_data . "Tree 구성용 데이터


endform.

*&---------------------------------------------------------------------*
*& Form calc_open_so
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SO
*&      --> GT_BL
*&---------------------------------------------------------------------*
form calc_open_so  tables   pt_so type ty_so_tab
                            pt_do type ty_do_tab
                            pt_bl type ty_bl_tab.

  data : lt_last   type ty_bl_tab with header line,
         lt_do_del type ty_bl_tab with header line.
  data : lv_date type datum.

  "-- 지난달 포함 이전의 데이터는 제외한다.
  lt_last[] = pt_bl[].

  lv_date   = gv_bdate(6) && '01'.
  delete lt_last where fkdat >= lv_date.
  delete pt_bl   where fkdat < lv_date. "alv에는 오늘 이후의 데이터만 필요함

  "-- 빌링된 do도 필요없음
  loop at pt_do assigning field-symbol(<do>).
    read table lt_last with key vbeln_vl = <do>-vbeln_vl
                                posnr_vl = <do>-posnr_vl.
    if sy-subrc = 0.
      move-corresponding <do> to lt_do_del.
      append lt_do_del.
      delete pt_do.
    endif.
  endloop.

  "-- 빌링된 so는 수량과 금액이 필요없음
  loop at pt_so assigning field-symbol(<so>).
    <so>-plqty = <so>-kwmeng.
    <so>-plamt = <so>-netwr.
    loop at lt_last where vbeln_va = <so>-vbeln_va
                      and posnr_va = <so>-posnr_va.
      <so>-plqty  = <so>-plqty - lt_last-fkimg.
      <so>-plamt  = <so>-plamt - lt_last-netwr.
      delete lt_last.
    endloop.
  endloop.

  delete pt_so where plqty = 0 or plamt = 0.


endform.
*&---------------------------------------------------------------------*
*& Form add_sub_tot
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN
*&      --> L_SPMON_KEY
*&      <-- L_LAST_KEY
*&---------------------------------------------------------------------*
form add_sub_tot  using    ps_main like zgtsds0041
                           p_relat_key type lvc_nkey
                 changing  p_node_key type lvc_nkey.

  data: l_node_text type lvc_value,
        ls_main     like zgtsds0041.
  data: l_layout_node type lvc_s_layn.

* add node
  l_node_text = ps_main-waerk.

  "-- 금액은 미리 계산한 값을 넣어준다.
  clear gt_plan_tot.
  read table gt_plan_tot with key spmon = 'TOTAL' "ps_main-spmon
                                  waerk_tx = ps_main-waerk_tx
                                  level = 3.
  move-corresponding ps_main to ls_main.
  ls_main-level        = 3.
  ls_main-sale_amt     = gt_plan_tot-sale_amt.
  ls_main-sale_amt_krw = gt_plan_tot-sale_amt_krw.
  ls_main-marginalprofit_per_r = gt_plan_tot-marginalprofit_per_r.
  ls_main-marginalprofit_krw_r = gt_plan_tot-marginalprofit_krw_r.
  ls_main-salesprofit_per_r    = gt_plan_tot-salesprofit_per_r.
  ls_main-salesprofit_krw_r    = gt_plan_tot-salesprofit_krw_r.

*************
  data ls_node_layout  type lvc_s_layn.
  data lt_item_layout  type lvc_t_layi.
  clear: ls_node_layout, lt_item_layout.
  perform make_folder_hotspot  changing   ls_node_layout
                                          lt_item_layout.

************


  call method g_alv_tree->add_node
    exporting
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = l_node_text
      is_outtab_line   = ls_main
      it_item_layout   = lt_item_layout
      is_node_layout   = l_layout_node
    importing
      e_new_node_key   = p_node_key.

endform.
*&---------------------------------------------------------------------*
*& Form add_month_tot
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN
*&      --> L_TOP_KEY
*&      <-- L_SPMON_KEY
*&---------------------------------------------------------------------*
form add_summary_tot  using     ps_main like zgtsds0041
                          p_relat_key type lvc_nkey
                changing  p_node_key type lvc_nkey.

  data: l_node_text type lvc_value,
        ls_main     like zgtsds0041,
        l_month(15) type c.            "output string for month
  data: lt_waerk type waerk occurs 0 with header line.

*  concatenate ps_main-spmon+0(4) '년' ps_main-spmon+4(2) '월' into l_month.
*  l_node_text = l_month.
  l_node_text = ps_main-spmon.

  "-- 금액은 미리 계산한 값을 넣어준다.
  clear gt_plan_tot.
  read table gt_plan_tot with key spmon = 'TOTAL' "ps_main-spmon
*                                  waerk = ps_main-waerk
                                  level = 2.
  move-corresponding ps_main to ls_main.
  ls_main-level        = 2.
  ls_main-sale_amt     = gt_plan_tot-sale_amt.
  ls_main-sale_amt_krw = gt_plan_tot-sale_amt_krw.
  ls_main-marginalprofit_per_r = gt_plan_tot-marginalprofit_per_r.
  ls_main-marginalprofit_krw_r = gt_plan_tot-marginalprofit_krw_r.
  ls_main-salesprofit_per_r    = gt_plan_tot-salesprofit_per_r.
  ls_main-salesprofit_krw_r    = gt_plan_tot-salesprofit_krw_r.

  "-- 통화가 2건 이상일 경우 이후 상위레벨의 합계금액은 없음
  clear lt_waerk[].
  loop at gt_plan .
    lt_waerk = gt_plan-waerk.
    collect lt_waerk.
  endloop.
  if lines( lt_waerk ) >= 2.
    ls_main-sale_amt = 0.
    ls_main-waerk    = ''.
*    gt_plan_sum-waerk_tx = ''.
  endif.

*************
  data ls_node_layout  type lvc_s_layn.
  data lt_item_layout  type lvc_t_layi.
  clear: ls_node_layout, lt_item_layout.
  perform make_folder_hotspot  changing   ls_node_layout
                                          lt_item_layout.

************


* add node
  call method g_alv_tree->add_node
    exporting
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = l_node_text
      is_outtab_line   = ls_main
      is_node_layout   = ls_node_layout
      it_item_layout   = lt_item_layout
    importing
      e_new_node_key   = p_node_key.

endform.
*&---------------------------------------------------------------------*
*& Form add_027_to_main
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_027
*&      --> GT_MAIN
*&---------------------------------------------------------------------*
form add_027_to_main  tables pt_027 structure zsdt_d365_027
                             pt_main structure zgtsds0042.

  data : ls_list like zgtsds0042.

  loop at pt_027.

    clear : ls_list.

    ls_list-spmon               = pt_027-spmon.
    ls_list-kunnr               = pt_027-kunnr.

    select single b~name1 into ls_list-kunnr_nm
      from kna1 as a inner join adrc as b on a~adrnr = b~addrnumber
     where a~kunnr = ls_list-kunnr.

    ls_list-zpjno               = pt_027-zpjno.

    select single zptxt into ls_list-zptxt
      from zsd0106t
     where zpjno = pt_027-zpjno.

    if ls_list-zpjno is initial.
      ls_list-zptxt = '(프로젝트 없음)'.
    endif.

    ls_list-prodh              = pt_027-prodh.
    ls_list-matnr              = pt_027-matnr.
**    ls_list-arktx               = ls_so-arktx.
**    ls_list-maktx               = ls_so-arktx.
*    ls_list-edatu               = ls_so-edatu.
*    ls_list-jojang_uom
*    ls_list-jojang_qty
*    ls_list-kwmeng              = ls_so-kwmeng.
    ls_list-vrkme              = pt_027-vrkme.
*    ls_list-netwr_so            = ls_so-netwr.
    ls_list-waerk              = pt_027-waers_krw.
    ls_list-waers_krw          = 'KRW'.

    ls_list-bltype             = 'A'.

    ls_list-sale_date          = pt_027-fkdat.
    ls_list-sale_qty           = pt_027-quantity.
    ls_list-sale_amt           = pt_027-amount_krw.
    ls_list-kursf              = 1.
    ls_list-sale_amt_krw       = pt_027-amount_krw.
    ls_list-marginalprofit_per   = pt_027-marginalprofit_per.
    ls_list-marginalprofit_krw   = pt_027-marginalprofit_krw.
    "-- R-PLANNA까지 같이 update한다.
    ls_list-marginalprofit_per_r = pt_027-marginalprofit_per.
    ls_list-marginalprofit_krw_r = pt_027-marginalprofit_krw.
    ls_list-remark             = pt_027-remark.
    ls_list-pernr              = pt_027-pernr.

    append ls_list to pt_main.

  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form add_text_to_main
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MAIN
*&---------------------------------------------------------------------*
form add_text_to_main  tables  pt_main structure zgtsds0042.

  data: ls_main type zgtsds0042.
  data: lt_t179t like t179t occurs 0 with header line,
        lt_makt  like makt occurs 0 with header line.

  data: lt_ords    type table of zcharords,
        lt_ordvals type table of zcharvals,
        lr_atnamm  type table of eampic_sel_atnam,
        lr_atnamb  type table of eampic_sel_atnam,
        lr_atnamo  type table of eampic_sel_atnam.

  constants:
* SALES ORDER
    so_length(30) value 'SAP_LENGTH_VKRME',     "조장
    so_factor(30) value 'SAP_MILLCA_FACTOR'.    "조장수

*___오더 특성
  lr_atnamo = value #( base lr_atnamo
                         sign = 'I' option = 'EQ'
                         ( low = so_length          )
                         ( low = so_factor          ) ).
  lt_ords   = value #( base lt_ords
                       for ws_main in pt_main
                         where ( vbeln_va is not initial )
                         ( vbeln = ws_main-vbeln_va
                           posnv = ws_main-posnr_va ) ).

  call function 'Z_GET_CHAR_OF_ORDER'
    exporting
      ir_atnam = lr_atnamo
    tables
      it_ords  = lt_ords
      et_vals  = lt_ordvals.

  sort lt_ords    by vbeln posnv.
  sort lt_ordvals by objek atnam.

  "-- PRODH text
  if pt_main[] is not initial.
    select * into table lt_t179t
      from t179t
       for all entries in pt_main
     where prodh = pt_main-prodh
       and spras = sy-langu.
    sort lt_t179t by prodh.
  endif.

  "-- 지재 text
  if pt_main[] is not initial.
    select * into table lt_makt
      from makt
       for all entries in pt_main
     where matnr = pt_main-matnr
       and spras = sy-langu.
    sort lt_makt by matnr.
  endif.

  "-- 프로젝트
  if pt_main[] is not initial.
    select * into table @data(lt_0106t)
      from zsd0106t
       for all entries in @pt_main
      where zpjno = @pt_main-zpjno.
    sort lt_0106t by zpjno.
  endif.

  "-- 고객
  if pt_main[] is not initial.
    select a~kunnr, a~land1, b~name1
      into table @data(lt_custom)
      from kna1 as a inner join adrc as b on a~adrnr = b~addrnumber
       for all entries in @pt_main
     where a~kunnr = @pt_main-kunnr.
    sort lt_custom by kunnr.
  endif.

  "-- 사원명 가져오기
  data lt_main type standard table of zgtsds0042.

  lt_main[] = pt_main[].
  sort lt_main by pernr.
  delete lt_main where pernr is initial.
  delete adjacent duplicates from lt_main comparing pernr.

  select a~*
    from zgtmm_cv_getusername as a inner join @lt_main as b on a~userid = b~pernr
    into table @data(lt_user).
  sort lt_user by userid.


  loop at pt_main into ls_main.

    if ls_main-kunnr is not initial.
      read table lt_custom assigning field-symbol(<custom>)
                           with key kunnr = ls_main-kunnr
                           binary search.
      if sy-subrc = 0.
        ls_main-land1    = <custom>-land1.
        ls_main-kunnr_nm = <custom>-name1.
      endif.
    endif.

    "-- 프로젝트
    if ls_main-zpjno is initial.
      ls_main-zptxt = '(프로젝트 없음)'.
    else.
      read table lt_0106t assigning field-symbol(<pjz>)
                          with key zpjno = ls_main-zpjno
                          binary search.
      ls_main-zptxt = <pjz>-zptxt.
    endif.

    "-- 자재 text
    read table lt_makt with key matnr = ls_main-matnr
                       binary search.
    if sy-subrc = 0.
      ls_main-maktx = lt_makt-maktx.
      if ls_main-arktx is initial.
        ls_main-arktx = lt_makt-maktx.
      endif.
    endif.

    "--- 특성값 추가
    read table lt_ords into data(wa_ords)
                       with key vbeln = ls_main-vbeln_va
                                posnv = ls_main-posnr_va
                                binary search.
    if sy-subrc = 0.
      read table lt_ordvals into data(wa_ovals)
                            with key objek = wa_ords-objek
                                     atnam = so_length      "조장
                                     binary search.
      if sy-subrc = 0.
        ls_main-jojang_uom = wa_ovals-atwrt.
      endif.

      read table lt_ordvals into wa_ovals
                            with key objek = wa_ords-objek
                                     atnam = so_factor      "조장수
                                     binary search.
      if sy-subrc = 0.
        ls_main-jojang_qty = wa_ovals-atwrt.
        if ls_main-kwmeng < 0.
          ls_main-jojang_qty = ls_main-jojang_qty * -1.
        endif.
      endif.
    endif.

    "-- 제품계층구조
    read table lt_t179t with key prodh = ls_main-prodh
                                 binary search.
    if sy-subrc = 0.
      ls_main-prodh_nm = lt_t179t-vtext.
    endif.

    "-- 영업사원명
    read table lt_user assigning field-symbol(<user>)
                       with key userid = ls_main-pernr
                       binary search.
    if sy-subrc = 0.
      ls_main-pernr_nm = <user>-name.
    endif.

    ls_main-spmon = ls_main-sale_date(6).

    modify pt_main from ls_main.

  endloop.


endform.

*&---------------------------------------------------------------------*
*& Form get_next_month
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_MONTH
*&      --> P_
*&      <-- LV_MONTH
*&---------------------------------------------------------------------*
form get_next_month  using    pv_month
                              pv_val
                     changing pv_next_month.

  data : lv_date1 type sy-datum,
         lv_date2 type sy-datum.

  lv_date1 = pv_month && '01'.

  call function 'MONTH_PLUS_DETERMINE'
    exporting
      months  = pv_val
      olddate = lv_date1
    importing
      newdate = lv_date2.

  pv_next_month = lv_date2(6).

endform.
*&---------------------------------------------------------------------*
*& Form GET_CURRENCY_FACTOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_ITEMLIST_WAERK
*&      <-- LV_FACTOR
*&---------------------------------------------------------------------*
form get_currency_factor  using    pv_waerk
                          changing pv_factor.

  data lv_factor type isoc_factor.

  call function 'CURRENCY_CONVERTING_FACTOR'
    exporting
      currency          = pv_waerk
    importing
      factor            = lv_factor
    exceptions
      too_many_decimals = 1
      others            = 2.
  if sy-subrc <> 0.
* Implement suitable error handling here
  endif.

  pv_factor = lv_factor.

endform.
*&---------------------------------------------------------------------*
*& Form make_timestamp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_021_CREATEDON
*&---------------------------------------------------------------------*
form make_timestamp  changing pv_timestamp.

  data(lv_timestamp) = |{ sy-datum+4(2) }/{ sy-datum+6(2) }/{ sy-datum(4) }|.
  lv_timestamp = lv_timestamp && | { sy-uzeit(2) }:{ sy-uzeit+2(2) }:{ sy-uzeit+4(2) }|.

  pv_timestamp = lv_timestamp.

endform.
*&---------------------------------------------------------------------*
*& Form POPULATE_021_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAIN
*&      <-- LS_021
*&---------------------------------------------------------------------*
form populate_021_data  using    ps_main structure zgtsds0042
                        changing ls_021 structure zsdt_d365_021.

  ls_021-dpid                 = sy-datum && sy-uzeit && ls_021-dpid.
  ls_021-pltype               = 'SP'.
  ls_021-cycltype             = 'W'.
  ls_021-vkbur                = p_vkbur.
  ls_021-pernr                = p_pernr.
  ls_021-week                 = gv_bweek.  " 오늘의 주차
  ls_021-owntype              = 'U'.
*    ls_021-dpweeknumberidname
  ls_021-basemonth            = gv_week_month.
  ls_021-businessunitidname   = gv_vkbur_nm.
  ls_021-businessunitidcode   = p_vkbur.

*    ls_021-dptype
  ls_021-vkgrp                = ps_main-vkgrp.

  if ps_main-bltype = 'A'.
    ls_021-oppstatus          = 'T'.

    select single land1 into @data(lv_land1)
      from kna1 where kunnr = @ps_main-kunnr.
    if gv_land1 = lv_land1.
      ls_021-vtweg            = '10'.
    else.
      ls_021-vtweg            = '50'.
    endif.

    select single spart into @data(lv_spart)
      from mara where matnr = @ps_main-matnr.

    ls_021-spart              = lv_spart.
    ls_021-land1              = lv_land1.
  else.
    ls_021-oppstatus          = 'W'.
    ls_021-vtweg              = ps_main-vtweg.
    ls_021-spart              = ps_main-spart.
    ls_021-land1              = ps_main-land1.
  endif.


  ls_021-zpjno                = ps_main-zpjno.
  ls_021-kunnr                = ps_main-kunnr.
  ls_021-itemname             = ps_main-arktx.
  ls_021-attr01               = ps_main-prodh.
  ls_021-attr10               = ps_main-bltype.  "유형
  ls_021-matnr                = ps_main-matnr.
*    gs_main-sul_no
*    gs_main-rev_seq
*    gs_main-attr01
*    gs_main-attr02
*    gs_main-attr03
*    gs_main-attr04
*    gs_main-attr05
*    gs_main-attr06
*    gs_main-attr07
*    gs_main-attr08
*    gs_main-attr09
*    gs_main-attr10
*    gs_main-dpapply_per
  ls_021-vrkme               = ps_main-vrkme.
  ls_021-quantity            = ps_main-sale_qty.  "fkimg. "매출수량
  ls_021-quantity_dp         = ps_main-sale_qty.  "fkimg. "매출
  ls_021-waers               = ps_main-waerk.
  if ps_main-sale_qty = 0.
  else.
    ls_021-unitprice_local   = ps_main-sale_amt / ps_main-sale_qty. "vbrp-netwr / vbrp-fkimg.
  endif.
  ls_021-amount_local        = ps_main-sale_amt. "vbrp-netwr. "매출액(거래통화)
  ls_021-amount_dp_local     = ps_main-sale_amt. "vbrp-netwr. "매출액(거래통화)
*    ls_021-waers_usd
*    ls_021-unitprice_usd
*    ls_021-amount_usd
*    ls_021-amount_dp_usd
  ls_021-waers_krw           = 'KRW'.
  ls_021-amount_krw          = ps_main-sale_amt_krw. "vbrp-netwr * 100. "결과화면 우측 ALV의 환율
  ls_021-amount_dp_krw       = ps_main-sale_amt_krw. "vbrp-netwr * 100. "결과화면 우측 ALV의 환율
*    gs_main-soduemonth
  ls_021-vbeln               = ps_main-vbeln_va.
  ls_021-posnr               = ps_main-posnr_va.
  ls_021-seqno               = ps_main-seqno.
*----- (유형에 따라)
*     1) 매출 이면, BL
*     2) 출고 또는 분할-출고 이면, GI
*     3) 그 외이면, SO
  if ps_main-bltype = 'B'.  "매출
    ls_021-sotype = 'BL'.
  elseif ps_main-bltype = 'E' or ps_main-bltype = 'H'. "출고
    ls_021-sotype = 'GI'.
  elseif ps_main-bltype = 'D' or ps_main-bltype = 'G'. "출하진행
    ls_021-sotype = 'DO'.
  elseif ps_main-bltype = 'C' or ps_main-bltype = 'F'. "미출하
    ls_021-sotype = 'SO'.
  else.
    ls_021-sotype = ''.  "의지치
  endif.

  ls_021-marginalprofit_per = ps_main-marginalprofit_per.
  ls_021-marginalprofit_krw = ps_main-marginalprofit_krw.
*    gs_main-salesprofit_per
*    gs_main-salesprofit_usd
  ls_021-dlvdate            = ps_main-gidat.
  ls_021-fkdat              = ps_main-sale_date.
*    gs_main-inco1
*    gs_main-originname
*    gs_main-exportaddfee_usd
*    gs_main-commission_per
*    gs_main-commission_usd
*    gs_main-commission_krw
*    gs_main-dpfxrate_mastername
*    gs_main-duty_per
*    gs_main-duty_usd
*    gs_main-duty_krw
*    gs_main-marginalprofit_krw
*    gs_main-salesprofit_krw
*    gs_main-fxrate_usd
  ls_021-fxrate_krw        = ps_main-kursf.
  ls_021-remark            = ps_main-remark.

  if ps_main-kursf is initial and ps_main-waerk = 'KRW'.
    ls_021-fxrate_krw = 1.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form POPULATE_021_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAIN
*&      <-- LS_021
*&---------------------------------------------------------------------*
form populate_main_fr_021  using    ls_021 structure zsdt_d365_021
                           changing ps_list structure zgtsds0042.


  move :
       ls_021-vkgrp                to ps_list-vkgrp,
       ls_021-vtweg                to ps_list-vtweg,
       ls_021-spart                to ps_list-spart,
       ls_021-land1                to ps_list-land1,
       ls_021-zpjno                to ps_list-zpjno,
       ls_021-kunnr                to ps_list-kunnr,
       ls_021-itemname             to ps_list-arktx,
       ls_021-attr01               to ps_list-prodh,
       ls_021-matnr                to ps_list-matnr,
       ls_021-vrkme                to ps_list-vrkme,
       ls_021-quantity             to ps_list-sale_qty,  "fkimg. "매출수량
*       ls_021-quantity_dp          to ps_list-sale_qty,  "fkimg. "매출
       ls_021-waers                to ps_list-waerk,
       ls_021-amount_local         to ps_list-sale_amt, "vbrp-netwr. "매출액(거래통화)
       ls_021-amount_krw           to ps_list-sale_amt_krw, "vbrp-netwr * 100. "결과화면 우측 ALV의 환율
       ls_021-vbeln                to ps_list-vbeln_va,
       ls_021-posnr                to ps_list-posnr_va,
       ls_021-seqno                to ps_list-seqno,
       ls_021-fkdat                to ps_list-sale_date,
       ls_021-fxrate_krw           to ps_list-kursf,
       ls_021-marginalprofit_per   to ps_list-marginalprofit_per,
       ls_021-marginalprofit_krw   to ps_list-marginalprofit_krw,
       ls_021-remark               to ps_list-remark,
       'KRW'                       to ps_list-waers_krw.

*----- (유형에 따라)

  if ls_021-attr10 is not initial.
    ps_list-bltype = ls_021-attr10.  "유형
  else.
    case ls_021-sotype.
      when 'BL'.
        ps_list-bltype    = 'B'.
        ps_list-gidat     = ls_021-dlvdate.
      when 'GI'.
        if ls_021-dlvdate is not initial.
          ps_list-bltype  = 'E'.
          ps_list-gidat   = ls_021-dlvdate.
        endif.
      when 'DO'.
        ps_list-bltype    = 'D'.
      when 'SO'.
        ps_list-bltype    = 'C'.
      when ''.
        ps_list-bltype    = 'A'.
    endcase.
  endif.


endform.
*&---------------------------------------------------------------------*
*& Form get_exc_currency
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_1300T
*&---------------------------------------------------------------------*
form get_exc_currency  tables   pt_1300t structure zpls1300s.

  data : lv_versi  like zpls1300t-versi,
         lv_mon(2) type n.

  lv_mon   = gv_bdate+4(2) + 40.
  lv_versi = '0' && lv_mon.


*  if sy-sysid = 'S4Q' or sy-sysid = 'S4D'. "개발에서만
*    if sy-uname = 'ZGSISD08' or sy-uname = 'ZGSISD07'.
*      while lv_mon >= '41'.
*        lv_versi = '0' && lv_mon.
*        select single mandt into @sy-mandt
*          from zpls1300t
*         where bukrs = '1000'
*           and pyear = @sy-datum(4)
*           and versi = @lv_versi.
*        if sy-subrc = 0.
*          exit.
*        else.
*          lv_mon = lv_mon - 1.
*        endif.
*      endwhile.
*    endif.
*  endif.


  select *
    from zpls1300t
   where bukrs = @gv_bukrs
     and pyear = @gv_bdate(4)
     and versi = @lv_versi
    into corresponding fields of table @pt_1300t.
  if sy-subrc <> 0.
    gv_err = 'X'.
    message s001 with gv_bdate(6) `Rolling 환율이 없습니다. 환율 등록을 먼저 요청하시기 바랍니다.`
                      display like 'E'.
    exit.
  endif.


endform.
*&---------------------------------------------------------------------*
*& Form check_updated_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_YES
*&---------------------------------------------------------------------*
form check_updated_data  changing pv_confirm.

  data: l_rc   type c.

  check gt_021_upd[] is not initial or
        gt_026_upd[] is not initial or
        gt_027_upd[] is not initial or
        gt_021_del[] is not initial or
        gt_026_del[] is not initial or
        gt_027_del[] is not initial .


  call function 'POPUP_TO_CONFIRM_STEP'
    exporting
      textline1      = '수정된 내용을 DB에 반영하지 않고 나가겠습니까?'(902)
*     textline2      = gv_vbeln_new
      titel          = 'Confirmation'(904)
      cancel_display = 'X'
    importing
      answer         = l_rc.

  pv_confirm = l_rc.

endform.
*&---------------------------------------------------------------------*
*& Form set_selection_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_selection_screen .

  tx_vkbur = '영업팀'.
  tx_pernr = '영업사원'.
  tx_mon   = '전월기준'.

  perform set_vkbur_text.
  perform set_pernr_text.


*__화면 제어
  loop at screen.

    if screen-group1 = 'SC1'.
      screen-input  = 0.
      screen-active = 1.
    endif.

    modify screen.
  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form calc_exchange_currency
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_MAIN
*&---------------------------------------------------------------------*
form calc_exchange_currency  changing ps_list structure zgtsds0042.

  data: lv_factor type isoc_factor.

  if ps_list-waerk = 'KRW'.
    ps_list-sale_amt_krw   = ps_list-sale_amt.
    ps_list-kursf          = 1.
  else.

    if ps_list-bltype = 'B' and ps_list-kursf <> 0. "매출 처리된 경우
      perform calc_curency_exch    using    ps_list-sale_amt
                                            ps_list-kursf
                                            ps_list-sale_date
                                            ps_list-waerk
                                            'KRW'
                                  changing ps_list-sale_amt_krw.
    else.
      read table gt_1300t assigning field-symbol(<curr>) with key fcurr = ps_list-waerk.
      if sy-subrc = 0.
        case ps_list-sale_date(6).
          when gv_m00.
            ps_list-kursf = <curr>-ukurs01.
          when gv_m01.
            ps_list-kursf = <curr>-ukurs02.
          when gv_m02.
            ps_list-kursf = <curr>-ukurs03.
          when others.
            ps_list-kursf = <curr>-ukurs03.
        endcase.

        perform calc_curency_exch    using    ps_list-sale_amt
                                              ps_list-kursf
                                              ps_list-sale_date
                                              ps_list-waerk
                                              'KRW'
                                    changing ps_list-sale_amt_krw.
      endif.
    endif.
  endif.


endform.
*&---------------------------------------------------------------------*
*& Form get_matnr_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_300_MATNR
*&      <-- GT_LIST_300_MATNR_NM
*&---------------------------------------------------------------------*
form get_matnr_text  using    pv_matnr
                     changing pv_matnr_nm.

  clear pv_matnr_nm.

  " 자재명(MAKTX) 조회
  select single maktx into pv_matnr_nm
     from makt
    where matnr = pv_matnr and spras = sy-langu.

endform.
*&---------------------------------------------------------------------*
*& Form get_matnr_meins
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_300_MATNR
*&      <-- GT_LIST_300_VRKME
*&---------------------------------------------------------------------*
form get_matnr_meins  using    pv_matnr
                      changing pv_vrkme.

  select single meins into pv_vrkme
    from mara
    where matnr = pv_matnr.

endform.
*&---------------------------------------------------------------------*
*& Form get_kunnr_name
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_300_KUNNR
*&      <-- GT_LIST_300_KUNNR_NM
*&---------------------------------------------------------------------*
form get_kunnr_name  using    pv_kunnr
                     changing pv_kunnr_nm.

  " 고객명 조회
  select single name1 into pv_kunnr_nm
    from kna1
    where kunnr = pv_kunnr.

endform.
*&---------------------------------------------------------------------*
*& Form get_zpjno_name
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_300_ZPJNO
*&      <-- GT_LIST_300_ZPTXT
*&---------------------------------------------------------------------*
form get_zpjno_name  using    pv_zpjno
                     changing pv_zptxt.

  " 프로젝트명 조회
  select single zptxt into pv_zptxt
    from zsd0106t
    where zpjno = pv_zpjno.
  if pv_zpjno is initial.
    sy-subrc = 0.
    pv_zptxt = '(프로젝트 없음)'.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form calculate_open_so
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SO
*&      --> GT_DO
*&---------------------------------------------------------------------*
form calculate_open_so  tables  pt_so type ty_so_tab
                                pt_do type ty_do_tab.

  "-- 출하된 수량을 제외한 so 수량
  loop at pt_so assigning field-symbol(<so>).
    <so>-plqty = <so>-kwmeng.
    loop at pt_do where vbeln_va = <so>-vbeln_va
                     and posnr_va = <so>-posnr_va
                     and wadat_ist is not initial.
      <so>-plqty = <so>-plqty - pt_do-lfimg.
    endloop.
  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form split_and_move_new
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SO
*&      --> GT_DO
*&      --> GT_026
*&---------------------------------------------------------------------*
form split_and_move_new  tables   pt_so type ty_so_tab
                                  pt_do type ty_do_tab
                                  "pt_021 structure zsdt_d365_021
                                  pt_026 structure zsdt_d365_026
                                  pt_main structure zgtsds0042.


  data : lt_new_so type table of ty_so with header line.
  data : ls_list like zgtsds0042,
         ls_so   type ty_so,
         ls_do   type ty_do,
         ls_bl   type ty_bl.
  data : lt_so type table of ty_so with empty key.
  data : ls_026 type zsdt_d365_026,
         lt_026 type table of zsdt_d365_026 with header line.
  data : lv_do_found type abap_bool value abap_false,
         lv_26_found type abap_bool value abap_false.

  lt_026[] = pt_026[].

  sort pt_so  by vbeln_va posnr_va.
  sort pt_do  by vbeln_va posnr_va erdat.
  sort lt_026 by vbeln_va posnr_va erdat vbeln_vl posnr_vl bldat.
  sort pt_026 by vbeln_va posnr_va bldat descending.

************************************

  loop at pt_so into ls_so.

    clear : ls_list, lv_do_found, lv_26_found.

    ls_list-gubun        = ls_so-gubun.
    ls_list-vkgrp        = ls_so-vkgrp.
    ls_list-vtweg        = ls_so-vtweg.
    ls_list-spart        = ls_so-spart.
    ls_list-land1        = ls_so-land1.
    ls_list-kunnr        = ls_so-kunnr.
    ls_list-zpjno        = ls_so-zpjno.
    ls_list-vbeln_va     = ls_so-vbeln_va.
    ls_list-posnr_va     = ls_so-posnr_va.
    ls_list-seqno        = ls_so-seqno.
    ls_list-matnr        = ls_so-matnr.
    ls_list-arktx        = ls_so-arktx.
    ls_list-edatu        = ls_so-edatu.
    ls_list-kwmeng       = ls_so-kwmeng.
    ls_list-vrkme        = ls_so-vrkme.
    ls_list-netwr_so     = ls_so-netwr.
    ls_list-waerk        = ls_so-waerk.
    ls_list-prodh        = ls_so-prodh.
    ls_list-waers_krw    = 'KRW'.
    ls_list-remark       = ls_so-remark.
    ls_list-plqty        = ls_so-plqty.
    ls_list-lifnr        = ls_so-lifnr.
    ls_list-pernr        = ls_so-lifnr+1(8).

    "-- open 수량 <== split에서 나온 수량을 사용함
    ls_list-plqty        = ls_so-plqty.  "<-- do 뺀수량
    ls_list-open_qty     = ls_so-kwmeng. "<-- so 원래수량

    "--- do수량을 분할한 경우 할당해줌
    loop at pt_do where vbeln_va = ls_so-vbeln_va
                     and posnr_va = ls_so-posnr_va.

      perform split_do_data   tables   lt_026
                                       pt_main
                              using    ls_list
                                       pt_do.

      ls_list-open_qty = ls_list-open_qty - pt_do-lfimg.

    endloop.


    "--- 그래도 남은 수량은 bldat desc로 분할 데이터에 할당함
    data lv_open type kwmeng.

    if ls_so-vbtyp = 'H' or ls_so-vbtyp = 'K'.

      if ls_list-open_qty < 0.

        lv_open = ls_list-open_qty.

        loop at lt_026 into ls_026 where vbeln_va = ls_so-vbeln_va
                                     and posnr_va = ls_so-posnr_va
                                     and excep    = ''.

          clear : ls_list-vbeln_vl,
                  ls_list-posnr_vl,
                  ls_list-erdat_vl,
                  ls_list-lfimg,
                  ls_list-gidat.

          ls_list-gubun      = c_26.
          ls_list-seqno      = ls_026-seqno.
**        ls_list-edatu      = ls_026-bldat.
          ls_list-bldat      = ls_026-bldat.
          ls_list-plqty      = ls_026-plqty.
          ls_list-sale_qty   = ls_026-plqty.
          ls_list-open_qty   = ls_026-plqty.
          ls_list-remark     = ls_026-remark.

          append ls_list to pt_main.

          lv_open   = lv_open - ls_026-plqty.

          if lv_open >= 0.
            exit.
          endif.

        endloop.

        ls_list-open_qty = lv_open.

      endif.

      if ls_list-open_qty < 0.
        clear : ls_list-gubun,
                ls_list-vbeln_vl,
                ls_list-posnr_vl,
                ls_list-erdat_vl,
                ls_list-seqno,
                ls_list-lfimg,
                ls_list-remark,
                ls_list-gidat,
                ls_list-bldat,
                ls_list-wadat.

        ls_list-plqty      = ls_list-open_qty.
        ls_list-sale_qty   = ls_list-open_qty.
        append ls_list to pt_main.
      endif.

    else.

      if ls_list-open_qty > 0.

        lv_open = ls_list-open_qty.

        loop at lt_026 into ls_026 where vbeln_va = ls_so-vbeln_va
                                     and posnr_va = ls_so-posnr_va
                                     and excep    = ''.

          clear : ls_list-vbeln_vl,
                  ls_list-posnr_vl,
                  ls_list-erdat_vl,
                  ls_list-lfimg,
                  ls_list-gidat.

          ls_list-gubun      = c_26.
          ls_list-seqno      = ls_026-seqno.
**        ls_list-edatu      = ls_026-bldat.
          ls_list-bldat      = ls_026-bldat.
          ls_list-plqty      = ls_026-plqty.
          ls_list-sale_qty   = ls_026-plqty.
          ls_list-open_qty   = ls_026-plqty.
          ls_list-remark     = ls_026-remark.

          append ls_list to pt_main.

          lv_open   = lv_open - ls_026-plqty.

          if lv_open <= 0.
            exit.
          endif.

        endloop.

        ls_list-open_qty = lv_open.

      endif.

      if ls_list-open_qty > 0.
        clear : ls_list-gubun,
                ls_list-vbeln_vl,
                ls_list-posnr_vl,
                ls_list-erdat_vl,
                ls_list-seqno,
                ls_list-lfimg,
                ls_list-remark,
                ls_list-gidat,
                ls_list-bldat,
                ls_list-wadat.

        ls_list-plqty      = ls_list-open_qty.
        ls_list-sale_qty   = ls_list-open_qty.
        append ls_list to pt_main.
      endif.
    endif.

  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form UPDATE_STATUS_TYPE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_MAIN
*&      --> PT_021
*&      --> PT_026
*&---------------------------------------------------------------------*
form update_status_type  tables   pt_main structure zgtsds0042
                                  pt_021  structure zsdt_d365_021
                                  pt_026  structure zsdt_d365_026.

  data : ls_list like zgtsds0042.
  data : lv_lfimg type lfimg.
  data : lt_026 type table of zsdt_d365_026 with header line.

  sort pt_026 by vbeln_va posnr_va vbeln_vl posnr_vl seqno.

  lt_026[] = pt_026[].
  sort lt_026 by vbeln_va posnr_va bldat.

  loop at pt_main into ls_list.

    if ls_list-vbeln_vf is not initial.
      ls_list-bltype    = 'B'. "매출
    elseif ls_list-gidat is not initial.
      ls_list-bltype    = 'E'.  "출고
    elseif ls_list-wadat is not initial.
      ls_list-bltype    = 'D'.  "출하진행
    else.
      ls_list-bltype    = 'C'.  "미출하
    endif.

    "-- 매출일자 결정
    if ls_list-bltype = 'C' or ls_list-bltype = 'D' or ls_list-bltype = 'E'.

      ls_list-sale_date = ls_list-edatu.      "미출하

      if ls_list-wadat is not initial.
        ls_list-sale_date = ls_list-wadat.   "출하진행
      endif.
      if ls_list-gidat is not initial.
        ls_list-sale_date = ls_list-gidat.   "출고
      endif.
      if ls_list-sale_date < gv_bdate.
        ls_list-sale_date = gv_1st_edatu.  "과거이면 현재일 또는 전월말일로 변경함
      endif.

      "-- ZSDT_D365_026(분할)은 사용자가 입력한 일자 = ZSDT_D365_026-BLDAT 유지
      if ls_list-bldat is not initial.
        ls_list-sale_date = ls_list-bldat.   "26 table의 bldat
      endif.

      "-- 매출수량과금액 결정
      case ls_list-bltype.
        when 'C'.  "미출하
          ls_list-sale_qty   = ls_list-open_qty.
        when 'D'.  "출하진행
          ls_list-sale_qty   = ls_list-plqty.
        when 'E'.  "출고
          ls_list-sale_qty   = ls_list-plqty.
      endcase.

      ls_list-sale_amt   = ls_list-sale_qty * ls_list-netwr_so / ls_list-kwmeng.

    endif.


*    if ls_list-netwr_so < 0.  "-- order금액이 마이너스면 수량도 따라간다.
*      ls_list-sale_qty = ls_list-sale_qty * -1.
*    endif.

    read table pt_021 assigning field-symbol(<f21>)
                      with key vbeln = ls_list-vbeln_va
                               posnr = ls_list-posnr_va
                               seqno = ls_list-seqno.
    if sy-subrc = 0.

      "-- DO가 있으면 do기준으로 보여주고, 해당하는 분할은 차감함
      if ls_list-vbeln_vl is not initial.
      else.
        loop at lt_026 assigning field-symbol(<f26>)
                       where vbeln_va = ls_list-vbeln_va
                         and posnr_va = ls_list-posnr_va
                         and seqno    = ls_list-seqno
                         and excep = ''.
          ls_list-remark   =  <f26>-remark.
        endloop.
      endif.

    else.

      "----- 환율 적용
      perform calc_exchange_currency  changing ls_list.

    endif.

    "-- 분할상태
    if ls_list-seqno is not initial and ls_list-bltype <> 'B'. "매출이 아닌 경우에만
      if ls_list-vbeln_vl is initial.
        read table pt_026 with key vbeln_va = ls_list-vbeln_va
                                   posnr_va = ls_list-posnr_va
                                   seqno    = ls_list-seqno
                                   vbeln_vl = ls_list-vbeln_vl
                                   posnr_vl = ls_list-posnr_vl.
        if sy-subrc = 0 .
          ls_list-bltype = 'F'.  "분할-미출하
        endif.
      else.
        read table pt_026 with key vbeln_va = ls_list-vbeln_va
                                   posnr_va = ls_list-posnr_va
                                   vbeln_vl = ls_list-vbeln_vl
                                   posnr_vl = ls_list-posnr_vl
                                   seqno    = ls_list-seqno.
        if sy-subrc = 0 .
          if pt_026-gidat is not initial.
            ls_list-bltype = 'H'.  "분할-출고
          else.
            ls_list-bltype = 'G'.  "분할-출하진행
          endif.
        else.
          read table pt_026 with key vbeln_va = ls_list-vbeln_va
                                     posnr_va = ls_list-posnr_va
                                     seqno    = ls_list-seqno
                                     vbeln_vl = ls_list-vbeln_vl
                                     posnr_vl = ls_list-posnr_vl.
          if sy-subrc = 0 .
            if pt_026-gidat is not initial.
              ls_list-bltype = 'H'.  "분할-출고
            else.
              ls_list-bltype = 'F'.  "분할-미출하
            endif.
          endif.
        endif.
      endif.
    endif.

    ls_list-spmon = ls_list-sale_date(6).

    modify pt_main from ls_list.

  endloop.

  "-- 주문취소에 해당하는 거부사유가 있는 미출하는 삭제한다.
  loop at gt_so into gs_so where abgru not in gr_abgru.
    delete pt_main where vbeln_va = gs_so-vbeln_va
                     and posnr_va = gs_so-posnr_va
                     and ( bltype = 'C' or bltype = 'F' ).
  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form make_main_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_MAIN
*&      --> GT_BL
*&---------------------------------------------------------------------*
form make_main_data  tables   pt_main structure zgtsds0042
                              pt_bl type ty_bl_tab.

  data : ls_list like zgtsds0042.
  data : lt_main type table of zgtsds0042 with header line.
  data : lv_bl_found type abap_bool value abap_false.

  lt_main[] = pt_main[].
  clear pt_main[].

  loop at lt_main into ls_list.

    clear lv_bl_found.

    "-- do so기준 빌링데이터
    loop at pt_bl where vbeln_vl = ls_list-vbeln_vl
                    and posnr_vl = ls_list-posnr_vl
                    and vbeln_va = ls_list-vbeln_va
                    and posnr_va = ls_list-posnr_va.
*                    and vbeln_vl is not initial.

      lv_bl_found = abap_true.

      ls_list-vbeln_vf         = pt_bl-vbeln_vf.
      ls_list-posnr_vf         = pt_bl-posnr_vf.
      ls_list-fkdat            = pt_bl-fkdat.
      ls_list-sale_date        = pt_bl-fkdat.
      ls_list-sale_qty         = pt_bl-fkimg.
      ls_list-sale_amt         = pt_bl-netwr.
      ls_list-kursf            = pt_bl-kurrf.

      "-- OPEN 수량 계산, DO도 분할되어 나갈수 있음
      ls_list-open_qty = ls_list-open_qty - ls_list-sale_qty. "SO 수량

      if pt_bl-fkart = 'ZF2'.
        "-- 적송가매출라인은 추가 없음
      else.
        append ls_list to pt_main.
      endif.

      ls_list-lfimg     = ls_list-lfimg - ls_list-sale_qty.
    endloop.

    if lv_bl_found = abap_false or ls_list-lfimg > 0.
      append ls_list to pt_main.
    endif.

  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form delete_old_bl_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_MAIN
*&---------------------------------------------------------------------*
form delete_old_bl_data  tables   pt_main structure zgtsds0042.

  data lv_date type sy-datum.


  lv_date = gv_bdate(6) && '01'.

  delete pt_main where vbeln_vf is not initial
                   and fkdat < lv_date.


endform.
*&---------------------------------------------------------------------*
*& Form make_main_fr_21
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_021
*&      --> GT_SO
*&      --> GT_DO
*&      --> GT_BL
*&      --> LT_MAIN
*&---------------------------------------------------------------------*
form make_main_by_21  tables   pt_so   type ty_so_tab
                               pt_do   type ty_do_tab
                               pt_bl   type ty_bl_tab
                               pt_021 structure zsdt_d365_021
                               pt_026 structure zsdt_d365_026
                               pt_main structure zgtsds0042.

**  data : lt_so_one     type ty_so_tab,
**         lt_so_splited type ty_so_tab.
**
**  lt_so_one[]       = gt_so[].
**  delete lt_so_one where seqno is not initial.
**
**  perform split_and_move_new tables lt_so_one "-- 분할안된 것만 main에 추가함
**                                    pt_do
**                                    "pt_021
**                                    pt_026
**                                    pt_main.
**
**  lt_so_splited[] = gt_so[].
**  delete lt_so_splited where seqno is initial.
**
**  perform make_main_fr_21   tables pt_021    "-- 분할된건만 추가함
**                                   lt_so_splited
**                                   pt_do
**                                   pt_bl
**                                   pt_026
**                                   pt_main.

endform.
*&---------------------------------------------------------------------*
*& Form make_main_fr_21
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_021
*&      --> GT_SO
*&      --> GT_DO
*&      --> GT_BL
*&      --> LT_MAIN
*&---------------------------------------------------------------------*
form make_main_fr_21  tables   pt_021  structure zsdt_d365_021
                               pt_so   type ty_so_tab
                               pt_do   type ty_do_tab
                               pt_bl   type ty_bl_tab
                               pt_026 structure zsdt_d365_026
                               pt_main structure zgtsds0042.

**  data : ls_list like zgtsds0042,
**         ls_so   type ty_so,
**         ls_do   type ty_do,
**         ls_bl   type ty_bl.
**  data : lt_so type table of ty_so with empty key.
**  data : lt_026 type table of zsdt_d365_026 with header line.
**  data : lv_do_found type abap_bool value abap_false,
**         lv_26_found type abap_bool value abap_false.
**
**  data : lv_lfimg type lfimg.
**
**  sort pt_026 by vbeln_va posnr_va seqno.
**
**  lt_026[] = pt_026[].
**  sort lt_026 by vbeln_va posnr_va bldat.
**
**
**  loop at pt_so into ls_so.
**
**    clear : ls_list, lv_do_found, lv_26_found.
**
**    read table pt_021 assigning field-symbol(<f21>)
**                      with key vbeln = ls_so-vbeln_va
**                               posnr = ls_so-posnr_va
**                               seqno = ls_so-seqno.
**    if sy-subrc = 0.
**      perform populate_main_fr_021  using   <f21>
**                                    changing ls_list.
**    endif.
**
**    "-- open 수량 <== split에서 나온 수량을 사용함
**    ls_list-open_qty     = ls_so-plqty.  "<-- do 뺀수량
**    ls_list-kwmeng       = ls_so-kwmeng. "<-- so 원래수량
**    ls_list-netwr_so     = ls_so-netwr.
**    ls_list-waerk        = ls_so-waerk.
**
**    "-- 분할상태
**    if ls_list-seqno is not initial.
**      read table pt_026 with key vbeln_va = ls_list-vbeln_va
**                                 posnr_va = ls_list-posnr_va
**                                 seqno    = ls_list-seqno
**                                 binary search.
**      if sy-subrc = 0 .
**        ls_list-gubun      = c_26.
**        ls_list-seqno      = pt_026-seqno.
**        ls_list-edatu      = pt_026-bldat.
**        ls_list-bldat      = pt_026-bldat.
**        ls_list-sale_qty   = pt_026-plqty.
**        ls_list-open_qty   = pt_026-plqty.
**
**        if pt_026-vbeln_vl is not initial.
**          ls_list-vbeln_vl   = pt_026-vbeln_vl.
**          ls_list-posnr_vl   = pt_026-posnr_vl.
**          ls_list-lfimg      = pt_026-lfimg.
**          ls_list-gidat      = pt_026-gidat.
**        endif.
**      endif.
**    endif.
**
**    append ls_list to pt_main.
**
**  endloop.
**

endform.
*&---------------------------------------------------------------------*
*& Form get_sap_tab_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SALES
*&      --> GT_SO
*&      --> GT_DO
*&      --> GT_BL
*&      --> GT_026
*&---------------------------------------------------------------------*
form get_sap_tab_data  tables   pt_sales type ty_vbap_tab
                                pt_so type ty_so_tab
                                pt_do type ty_do_tab
                                pt_bl type ty_bl_tab
                                pt_026 structure zsdt_d365_026.

  perform get_so_data       tables pt_sales
                                   pt_so.   "-- 영업 세부사항
  perform get_do_data       tables pt_so
                                   pt_do.   "-- 납품오더 가져오기
  perform get_bl_data       tables pt_do
                                   pt_so
                                   pt_bl.   "-- 빌링오더 가져오기
  perform get_d365_26_data  tables pt_so
                                   pt_026.  "-- 분할용 데이터 가져오기

endform.
*&---------------------------------------------------------------------*
*& Form calc_curency_exch
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_LIST_SALE_AMT
*&      --> PS_LIST_KURSF
*&      --> PS_LIST_SALE_DATE
*&      --> PS_LIST_WAERK
*&      --> P_
*&      <-- PS_LIST_SALE_AMT_KRW
*&---------------------------------------------------------------------*
form calc_curency_exch  using    pv_amt      type any
                                pv_kursf    type any
                                pv_date     type d
                                pv_fr_wears type waers
                                pv_to_wears type waers
                       changing pv_amt_to   type any.

  " 계산의 정확도를 위해 Float 또는 충분한 소수점을 가진 Packed Data Type 사용
  data: lv_factor_from type bapi1093_0-from_factor,
        lv_factor_to   type bapi1093_0-from_factor,
        lv_dec_from    type isoc_factor,
        lv_dec_to      type isoc_factor,
        lv_amt         type f,
        lv_rate        type f,
        lv_amt_to      type f.

  clear pv_amt_to.

  " 1. 입력값 검증 (금액이나 환율이 없으면 종료)
  if pv_amt is initial or pv_kursf is initial.
    return.
  endif.

  " 동일 통화인 경우 변환 없이 그대로 반환
  if pv_fr_wears = pv_to_wears.
    pv_amt_to = pv_amt.
    return.
  endif.

  lv_amt  = pv_amt.
  lv_rate = pv_kursf.

  " 2. 환율 환산 비율(Factor) 가져오기
  call function 'BAPI_EXCHANGERATE_GETFACTORS'
    exporting
      rate_type   = 'M'
      from_curr   = pv_fr_wears
      to_currncy  = pv_to_wears
      date        = pv_date
    importing
      from_factor = lv_factor_from
      to_factor   = lv_factor_to.

  " Factor 값이 정상적으로 넘어오지 않은 경우 기본값 1 세팅
  if lv_factor_from is initial. lv_factor_from = 1. endif.
  if lv_factor_to   is initial. lv_factor_to   = 1. endif.

  " 3. From 통화의 소수점 배수 가져오기
  call function 'CURRENCY_CONVERTING_FACTOR'
    exporting
      currency          = pv_fr_wears
    importing
      factor            = lv_dec_from
    exceptions
      too_many_decimals = 1
      others            = 2.
  if sy-subrc <> 0 or lv_dec_from is initial.
    lv_dec_from = 1.
  endif.

  " 4. To 통화의 소수점 배수 가져오기
  call function 'CURRENCY_CONVERTING_FACTOR'
    exporting
      currency          = pv_to_wears
    importing
      factor            = lv_dec_to
    exceptions
      too_many_decimals = 1
      others            = 2.
  if sy-subrc <> 0 or lv_dec_to is initial.
    lv_dec_to = 1.
  endif.

  " 5. 최종 변환 금액 계산
  " 공식: 원금액 * 환율 * (To 비율 / From 비율) * (From 소수점 배수 / To 소수점 배수)
  lv_amt_to = lv_amt * lv_rate
            * ( lv_factor_to / lv_factor_from )
            * ( lv_dec_from / lv_dec_to ).

  " 6. 결과를 반환 변수에 할당
  pv_amt_to = lv_amt_to.


endform.
*&---------------------------------------------------------------------*
*& Form refresh_data_from_cbo
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form refresh_data_from_cbo .

  gv_read_new = ''.  "판매계획에서 데이터 가져온다.

  perform get_data.

  if g_alv_tree is bound.
    call method g_alv_tree->free.
    free g_alv_tree.
  endif.

  "-- l_top_key를 1로 세팅하기 위해서 tree를 완전히 새로 생성해야함
  "-- node만 지워서는 key값이 계속 증가함
  perform init_tree.
  if gv_nkey_m0 is not initial.
    perform get_item_detail using gv_nkey_m0  c_so.
    perform set_selected_node_m0.
  endif.


endform.
*&---------------------------------------------------------------------*
*& Form make_MAIN_FROM_21
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SO
*&      --> GT_DO
*&      --> GT_021
*&      --> LT_MAIN
*&---------------------------------------------------------------------*
form make_main_from_21  tables   pt_so type ty_so_tab
                                pt_do type ty_do_tab
                                pt_bl type ty_bl_tab
                                pt_021 structure zsdt_d365_021
                                pt_026 structure zsdt_d365_026
                                pt_main structure zgtsds0042.

**  data : ls_do type ty_do,
**         ls_so type ty_so,
**         lt_so type ty_so_tab.
**  data : ls_list like zgtsds0042.
**  data : lt_do type ty_do_tab with header line.
**
**  lt_do[] = pt_do[].
**
**  sort lt_do by vbeln_va posnr_va lfimg.
**
**  loop at pt_021.
**
**    clear ls_list.
**    read table pt_so into ls_so with key vbeln_va = pt_021-vbeln
**                                         posnr_va = pt_021-posnr.
**    if sy-subrc = 0.
**      ls_list-gubun        = ls_so-gubun.
**      ls_list-vkgrp        = ls_so-vkgrp.
**      ls_list-vtweg        = ls_so-vtweg.
**      ls_list-spart        = ls_so-spart.
**      ls_list-land1        = ls_so-land1.
**      ls_list-kunnr        = ls_so-kunnr.
**      ls_list-zpjno        = ls_so-zpjno.
**      ls_list-vbeln_va     = ls_so-vbeln_va.
**      ls_list-posnr_va     = ls_so-posnr_va.
***      ls_list-seqno        = ls_so-seqno.
**      ls_list-matnr        = ls_so-matnr.
**      ls_list-arktx        = ls_so-arktx.
**      ls_list-edatu        = ls_so-edatu.
**      ls_list-prodh        = ls_so-prodh.
**      ls_list-kwmeng       = ls_so-kwmeng.
**      ls_list-vrkme        = ls_so-vrkme.
**      ls_list-netwr_so     = ls_so-netwr.
**      ls_list-waerk        = ls_so-waerk.
**      ls_list-waers_krw    = 'KRW'.
**      ls_list-plqty        = ls_so-plqty.
**      ls_list-open_qty     = ls_so-kwmeng. "<-- so 원래수량
**    endif.
**
**    perform populate_main_fr_021  using    pt_021
**                                  changing ls_list.
**
**    read table pt_026 with key vbeln_va = pt_021-vbeln
**                               posnr_va = pt_021-posnr
**                               seqno    = pt_021-seqno.
**    if sy-subrc = 0.
**
***      ls_list-bltype = '분할-' && ls_list-bltype.
**      case ls_list-bltype.
**        when 'C'.
**          ls_list-bltype = 'F'.
**        when 'D'.
**          ls_list-bltype = 'G'.
**        when 'E'.
**          ls_list-bltype = 'H'.
**      endcase.
**
***      ls_list-remark = pt_026-remark.
**
**      read table lt_do  with key vbeln_va = pt_021-vbeln
**                                 posnr_va = pt_021-posnr
**                                 vbeln_vl = pt_026-vbeln_vl
**                                 posnr_vl = pt_026-posnr_vl.
**      if sy-subrc = 0.
**        ls_list-vbeln_vl = lt_do-vbeln_vl.
**        ls_list-posnr_vl = lt_do-posnr_vl.
**        ls_list-erdat_vl = lt_do-erdat.
**        ls_list-lfimg    = lt_do-lfimg.
**      endif.
**    endif.
**
**    "-- 출하 일자로 do정보 찾아서 추가
**    if ls_list-vbeln_vl is initial.
**      read table lt_do  with key vbeln_va = ls_list-vbeln_va
**                                 posnr_va = ls_list-posnr_va
**                                 wadat_ist = ls_list-gidat.
**      if sy-subrc = 0.
**        ls_list-vbeln_vl = lt_do-vbeln_vl.
**        ls_list-posnr_vl = lt_do-posnr_vl.
**        ls_list-erdat_vl = lt_do-erdat.
**        ls_list-lfimg    = lt_do-lfimg.
***        delete lt_do index sy-tabix.
**      endif.
**    endif.
**
**    "-- do 수량으로 do정보 찾아서 추가
**    if ls_list-vbeln_vl is initial.
**      read table lt_do  with key vbeln_va = ls_list-vbeln_va
**                                 posnr_va = ls_list-posnr_va
**                                 lfimg    = ls_list-sale_qty.
**      if sy-subrc = 0.
**        ls_list-vbeln_vl = lt_do-vbeln_vl.
**        ls_list-posnr_vl = lt_do-posnr_vl.
**        ls_list-erdat_vl = lt_do-erdat.
**        ls_list-lfimg    = lt_do-lfimg.
***        delete lt_do index sy-tabix.
**      endif.
**    endif.
**
**
**    "-- bl정보 추가
**    read table pt_bl  with key vbeln_va = pt_021-vbeln
**                               posnr_va = pt_021-posnr
**                               vbeln_vl = ls_list-vbeln_vl
**                               posnr_vl = ls_list-posnr_vl
**                               fkimg    = pt_021-quantity.
**    if sy-subrc = 0.
**      ls_list-vbeln_vf = pt_bl-vbeln_vf.
**      ls_list-posnr_vf = pt_bl-posnr_vf.
**    endif.
**
**    append ls_list to pt_main.
**
**  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form REFRESH_MAIN_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form refresh_main_list .

  "-- tree, main, detail에 반영한다.
  perform get_plan_data . "Tree 구성용 데이터

  call method g_alv_tree->free.
  clear: g_alv_tree.

  perform create_tree .

  perform get_item_detail using gv_nkey  c_so.
  perform display_sub_grid.


endform.
*&---------------------------------------------------------------------*
*& Form split_do_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_026
*&      --> PT_MAIN
*&      --> LS_SO_VBELN_VA
*&      --> LS_SO_POSNR_VA
*&      --> PT_DO_VBELN_VL
*&      --> PT_DO_POSNR_VL
*&---------------------------------------------------------------------*
form split_do_data  tables   pt_026 structure zsdt_d365_026
                             pt_main structure zgtsds0042
                    using    ps_list structure zgtsds0042
                             ps_do   type ty_do.

  data : lv_open type zgtsds0042-lfimg,
         ls_list like zgtsds0042.

  clear ls_list.

  move-corresponding ps_list to ls_list.

  ls_list-vbeln_vl   = ps_do-vbeln_vl.
  ls_list-posnr_vl   = ps_do-posnr_vl.
  ls_list-erdat_vl   = ps_do-erdat.
  ls_list-wadat      = ps_do-wadat.
  ls_list-gidat      = ps_do-wadat_ist.

  lv_open = ps_do-lfimg. "-- 여기선 DO기준으로 분할해주고, form밖에서 SO 수량을 분할한다.

  "-- 26분할 데이터를 do별로 할당해준다.
  loop at pt_026 assigning field-symbol(<f26>)
                  where vbeln_va = ps_list-vbeln_va
                    and posnr_va = ps_list-posnr_va
                    and vbeln_vl = ps_do-vbeln_vl
                    and posnr_vl = ps_do-posnr_vl
                    and excep    = ''.

    ls_list-gubun      = c_26.
    ls_list-seqno      = <f26>-seqno.
**    ls_list-edatu      = <f26>-bldat.
    ls_list-bldat      = <f26>-bldat.

    "-- DO수량과 분할 수량이 차이나는 경우(DO를 수정한 경우)
    "-- DO수량 기준으로 넣어준다.
    if <f26>-plqty > lv_open.
      ls_list-lfimg      = lv_open. "<f26>-lfimg. "do의 수량을 그대로 사용할 것
      ls_list-plqty      = lv_open.
      ls_list-sale_qty   = lv_open.
      ls_list-open_qty   = lv_open.
    else.
      ls_list-lfimg      = <f26>-lfimg. "do의 수량을 그대로 사용할 것
      ls_list-plqty      = <f26>-plqty.
      ls_list-sale_qty   = <f26>-plqty.
      ls_list-open_qty   = <f26>-plqty.
    endif.

    ls_list-remark     = <f26>-remark.
    append ls_list to pt_main.

    lv_open = lv_open - <f26>-plqty.

    if lv_open <= 0.
      delete pt_026.
      exit.
    endif.

  endloop.


  if lv_open > 0.  " 남은 do가 있는 경우
    clear : ls_list-gubun,
            ls_list-seqno,
            ls_list-remark,
            ls_list-wadat.

    ls_list-vbeln_vl   = ps_do-vbeln_vl.
    ls_list-posnr_vl   = ps_do-posnr_vl.
    ls_list-erdat_vl   = ps_do-erdat.
    ls_list-wadat      = ps_do-wadat.
    ls_list-gidat      = ps_do-wadat_ist.
    ls_list-lfimg      = ps_do-lfimg.
    ls_list-plqty      = lv_open.
    ls_list-sale_qty   = lv_open.
    ls_list-open_qty   = lv_open.

    append ls_list to pt_main.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form compare_before_after_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form compare_before_after_data tables pt_027_upd structure zsdt_d365_027.

  data : lv_idx     type sy-tabix,
         ls_origin  like zgtsds0044,
         ls_027     like zsdt_d365_027,
         lt_027_upd like zsdt_d365_027 occurs 0.

  clear lt_027_upd[].

  "-- 키값을 비교함
  loop at gt_300_origin into ls_origin.
    read table gt_list_300 with key vkbur = ls_origin-vkbur
                                    pernr = ls_origin-pernr
                                    fkdat = ls_origin-fkdat
                                    kunnr = ls_origin-kunnr
                                    zpjno = ls_origin-zpjno
                                    matnr = ls_origin-matnr.
    if sy-subrc = 0.
      lv_idx = sy-tabix.
      if ls_origin-unitprice_krw = gt_list_300-unitprice_krw or
         ls_origin-waers_krw     = gt_list_300-waers_krw or
         ls_origin-quantity      = gt_list_300-quantity or
         ls_origin-vrkme         = gt_list_300-vrkme or
         ls_origin-amount_krw    = gt_list_300-amount_krw or
         ls_origin-remark        = gt_list_300-remark.
        "-- 변경 처리
        move-corresponding gt_list_300 to ls_027.
        append ls_027 to lt_027_upd.
      else.
        "-- 변경없음
      endif.

      delete gt_300_origin.
      delete gt_list_300 index lv_idx.
    else.
      "-- 삭제 처리
      move-corresponding ls_origin to gt_027_del.
      append gt_027_del.

      delete gt_300_origin.
    endif.
  endloop.

  "-- 나머지는 추가로 입력한 건임
  loop at gt_list_300.
    move-corresponding gt_list_300 to ls_027.
    append ls_027 to lt_027_upd.
  endloop.

  loop at gt_027_del.
    read table gt_027_upd with key  vkbur = gt_027_del-vkbur
                                    pernr = gt_027_del-pernr
                                    fkdat = gt_027_del-fkdat
                                    kunnr = gt_027_del-kunnr
                                    zpjno = gt_027_del-zpjno
                                    matnr = gt_027_del-matnr.
    if sy-subrc = 0.
      delete gt_027_upd index sy-tabix.
    endif.
  endloop.

  move-corresponding lt_027_upd[] to pt_027_upd[] keeping target lines.

endform.
*&---------------------------------------------------------------------*
*& Form GET_MONTH_BY_POPUP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_MONTH
*&---------------------------------------------------------------------*
form get_month_by_popup  changing pv_month.

  data : lv_month  like  isellist-month,
         lv_return like  sy-subrc.


  clear pv_month.

  call function 'POPUP_TO_SELECT_MONTH'
    exporting
      actual_month   = gv_bdate(6)
*     FACTORY_CALENDAR                 = ' '
*     HOLIDAY_CALENDAR                 = ' '
      language       = sy-langu
      start_column   = 90
      start_row      = 9
    importing
      selected_month = lv_month
      return_code    = lv_return
*   EXCEPTIONS
*     FACTORY_CALENDAR_NOT_FOUND       = 1
*     HOLIDAY_CALENDAR_NOT_FOUND       = 2
*     MONTH_NOT_FOUND                  = 3
*     OTHERS         = 4
    .
  if sy-subrc <> 0.
* Implement suitable error handling here
  endif.

  if lv_return = 0.
    pv_month = lv_month.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form get_PRODH_name
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_PRODH
*&      <-- LV_PRODH_NM
*&---------------------------------------------------------------------*
form get_prodh_name  using    pv_prodh
                     changing pv_prodh_nm.

  clear pv_prodh_nm.

  if pv_prodh is initial.
    return.
  endif.

  select single vtext
    from t179t
    into pv_prodh_nm
    where spras = sy-langu
      and prodh = pv_prodh.

endform.
*&---------------------------------------------------------------------*
*& Form f4_vkbur_dialog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      <-- P_VKBUR
*&---------------------------------------------------------------------*
form f4_vkbur_dialog  using    p_text
                      changing p_vkbur.

  data: lt_return type table of ddshretval,
        ls_return type ddshretval.

  " Search Help(H_TVBUR)를 띄우고 사용자가 선택한 값을 가져옴
  call function 'F4IF_FIELD_VALUE_REQUEST'
    exporting
      tabname           = 'TVKBT'
      fieldname         = 'VKBUR'
      searchhelp        = 'H_TVBUR'
    tables
      return_tab        = lt_return
    exceptions
      field_not_found   = 1
      no_help_for_field = 2
      inconsistent_help = 3
      no_values_found   = 4
      others            = 5.

  " 사용자가 팝업에서 값을 선택했다면 (취소하지 않았다면)
  if sy-subrc = 0 and lt_return[] is not initial.

    read table lt_return into ls_return index 1.
    p_vkbur = ls_return-fieldval.

    " 강제 엔터
    call function 'SAPGUI_SET_FUNCTIONCODE'
      exporting
        functioncode = '='.

  endif.

endform.
*&---------------------------------------------------------------------*
*& Form set_vkbur_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_vkbur_text .

  if p_vkbur is not initial.
    select single bezei
      from tvkbt
      into v_vkbur
     where vkbur = p_vkbur
       and spras = sy-langu.

    if sy-subrc <> 0.
      v_vkbur = '존재하지 않는 코드입니다.'.
    endif.
  else.
    clear v_vkbur.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form set_pernr_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_pernr_text .

  if p_pernr is not initial.

    gv_so_pernr = 'E' && p_pernr.

    select single name1 into v_pernr
      from lfa1 where lifnr = gv_so_pernr.

    if sy-subrc <> 0.
      v_pernr = '존재하지 않는 사번이거나 영업사원으로 등록되지 않는 사번입니다.'.
    endif.
  else.
    clear v_pernr.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form check_matnr_prodh
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_MATNR
*&      --> LV_PRODH
*&      <-- LV_MSG
*&---------------------------------------------------------------------*
form check_matnr_prodh  using    pv_matnr
                                 pv_prodh
                        changing pv_msg.

  clear pv_msg.

  check pv_matnr is not initial and pv_prodh is not initial.

  select single prodh into @data(lv_prodh)
    from mvke
   where vkorg = @p_vkorg
     and matnr = @pv_matnr.
  if lv_prodh is initial.
    select single prdha into @lv_prodh
      from mara
     where matnr = @pv_matnr.
  endif.

  data(lv_len1) = strlen( pv_prodh ).

  if pv_prodh <> lv_prodh+0(lv_len1).
    concatenate '자재마스터 제품계층구조' lv_prodh '와 입력된 제품계층구조가 불일치합니다'
    into pv_msg.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form get_d365_30_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SALES
*&      --> GT_030
*&---------------------------------------------------------------------*
form get_d365_30_data  tables   pt_sales type ty_vbap_tab
                                pt_030 structure zsdt_d365_030.


  "-- where 조건은 삭제시에도 같은 로직을 사용한다.

  select a~*
    from zsdt_d365_030 as a
   where a~vkbur = @p_vkbur
     and a~pernr in @gr_pernr
     and a~vbeln in @s_vbeln     "주문번호
     and a~kunnr in @s_kunag     "판매처
     and a~zpjno in @s_zpjno    "프로젝트
*     and a~erdat in @s_erdat     "주문생성일
    into corresponding fields of table @pt_030.

  move-corresponding pt_030[] to pt_sales[].


endform.
*&---------------------------------------------------------------------*
*& Form make_main_from_30
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SO
*&      --> GT_DO
*&      --> GT_BL
*&      --> GT_030
*&      --> GT_026
*&      --> LT_MAIN
*&---------------------------------------------------------------------*
form make_main_from_30  tables  pt_so type ty_so_tab
                                pt_do type ty_do_tab
                                pt_bl type ty_bl_tab
                                pt_030 structure zsdt_d365_030
                                pt_026 structure zsdt_d365_026
                                pt_main structure zgtsds0042.

  data : ls_do type ty_do,
         ls_so type ty_so,
         lt_so type ty_so_tab.
  data : ls_list like zgtsds0042.
  data : lt_do type ty_do_tab with header line.

  lt_do[] = pt_do[].

  sort lt_do by vbeln_va posnr_va lfimg.

  loop at pt_030.

    clear ls_list.
    read table pt_so into ls_so with key vbeln_va = pt_030-vbeln
                                         posnr_va = pt_030-posnr.
    if sy-subrc = 0.
      ls_list-gubun        = ls_so-gubun.
      ls_list-vkgrp        = ls_so-vkgrp.
      ls_list-vtweg        = ls_so-vtweg.
      ls_list-spart        = ls_so-spart.
      ls_list-land1        = ls_so-land1.
      ls_list-kunnr        = ls_so-kunnr.
      ls_list-zpjno        = ls_so-zpjno.
      ls_list-vbeln_va     = ls_so-vbeln_va.
      ls_list-posnr_va     = ls_so-posnr_va.
*      ls_list-seqno        = ls_so-seqno.
      ls_list-matnr        = ls_so-matnr.
      ls_list-arktx        = ls_so-arktx.
      ls_list-edatu        = ls_so-edatu.
      ls_list-prodh        = ls_so-prodh.
      ls_list-kwmeng       = ls_so-kwmeng.
      ls_list-vrkme        = ls_so-vrkme.
      ls_list-netwr_so     = ls_so-netwr.
      ls_list-waerk        = ls_so-waerk.
      ls_list-waers_krw    = 'KRW'.
      ls_list-plqty        = ls_so-plqty.
      ls_list-open_qty     = ls_so-kwmeng. "<-- so 원래수량
      ls_list-lifnr        = ls_so-lifnr.
    endif.

*    perform populate_main_fr_021  using    pt_021
*                                  changing ls_list.
    perform populate_main_fr_030  using    pt_030
                                  changing ls_list.

    read table lt_do  with key vbeln_va = pt_030-vbeln
                               posnr_va = pt_030-posnr
                               vbeln_vl = pt_030-vbeln_vl
                               posnr_vl = pt_030-posnr_vl.
    if sy-subrc = 0.
      ls_list-wadat    = lt_do-wadat.
    endif.

    read table pt_026 with key vbeln_va = pt_030-vbeln
                               posnr_va = pt_030-posnr
                               seqno    = pt_030-seqno
                               vbeln_vl = pt_030-vbeln_vl
                               posnr_vl = pt_030-posnr_vl.
    if sy-subrc = 0.

*      ls_list-bltype = '분할-' && ls_list-bltype.
      if pt_030-seqno is initial.
      else.
        case ls_list-bltype.
          when 'C'.
            ls_list-bltype = 'F'.
          when 'D'.
            ls_list-bltype = 'G'.
          when 'E'.
            ls_list-bltype = 'H'.
        endcase.
      endif.

      if ls_list-vbeln_vl is initial.
        read table lt_do  with key vbeln_va = pt_030-vbeln
                                   posnr_va = pt_030-posnr
                                   vbeln_vl = pt_026-vbeln_vl
                                   posnr_vl = pt_026-posnr_vl.
        if sy-subrc = 0.
          ls_list-vbeln_vl = lt_do-vbeln_vl.
          ls_list-posnr_vl = lt_do-posnr_vl.
          ls_list-erdat_vl = lt_do-erdat.
          ls_list-wadat    = lt_do-wadat.
          ls_list-lfimg    = lt_do-lfimg.
        endif.
      endif.
    endif.

    "-- 출하 일자로 do정보 찾아서 추가
    if ls_list-vbeln_vl is initial.
      read table lt_do  with key vbeln_va = ls_list-vbeln_va
                                 posnr_va = ls_list-posnr_va
                                 wadat_ist = ls_list-gidat.
      if sy-subrc = 0.
        ls_list-vbeln_vl = lt_do-vbeln_vl.
        ls_list-posnr_vl = lt_do-posnr_vl.
        ls_list-erdat_vl = lt_do-erdat.
        ls_list-wadat    = lt_do-wadat.
        ls_list-lfimg    = lt_do-lfimg.
*        delete lt_do index sy-tabix.
      endif.
    endif.

    "-- do 수량으로 do정보 찾아서 추가
    if ls_list-vbeln_vl is initial.
      read table lt_do  with key vbeln_va = ls_list-vbeln_va
                                 posnr_va = ls_list-posnr_va
                                 lfimg    = ls_list-sale_qty.
      if sy-subrc = 0.
        ls_list-vbeln_vl = lt_do-vbeln_vl.
        ls_list-posnr_vl = lt_do-posnr_vl.
        ls_list-erdat_vl = lt_do-erdat.
        ls_list-wadat    = lt_do-wadat.
        ls_list-lfimg    = lt_do-lfimg.
*        delete lt_do index sy-tabix.
      endif.
    endif.


    "-- bl정보 추가
    if ls_list-vbeln_vf is initial.
      read table pt_bl  with key vbeln_va = pt_030-vbeln
                                 posnr_va = pt_030-posnr
                                 vbeln_vl = ls_list-vbeln_vl
                                 posnr_vl = ls_list-posnr_vl
                                 fkimg    = pt_030-sale_qty.
      if sy-subrc = 0.
        ls_list-vbeln_vf = pt_bl-vbeln_vf.
        ls_list-posnr_vf = pt_bl-posnr_vf.
      endif.
    endif.

    append ls_list to pt_main.

  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form populate_main_fr_030
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_030
*&      <-- LS_LIST
*&---------------------------------------------------------------------*
form populate_main_fr_030  using    ls_030 structure zsdt_d365_030
                           changing ps_list structure zgtsds0042.


  move :
       ls_030-vkgrp                to ps_list-vkgrp,
       ls_030-vtweg                to ps_list-vtweg,
       ls_030-spart                to ps_list-spart,
       ls_030-land1                to ps_list-land1,
       ls_030-zpjno                to ps_list-zpjno,
       ls_030-kunnr                to ps_list-kunnr,
       ls_030-arktx                to ps_list-arktx,
*       ls_030-attr01               to ps_list-prodh,
       ls_030-matnr                to ps_list-matnr,
       ls_030-vrkme                to ps_list-vrkme,
       ls_030-sale_qty             to ps_list-sale_qty,  "fkimg. "매출수량
       ls_030-waerk                to ps_list-waerk,
       ls_030-sale_amt             to ps_list-sale_amt, "vbrp-netwr. "매출액(거래통화)
       ls_030-sale_amt_krw         to ps_list-sale_amt_krw, "vbrp-netwr * 100. "결과화면 우측 ALV의 환율
       ls_030-vbeln                to ps_list-vbeln_va,
       ls_030-posnr                to ps_list-posnr_va,
       ls_030-seqno                to ps_list-seqno,
       ls_030-prodh                to ps_list-prodh,
       ls_030-vbeln_vl             to ps_list-vbeln_vl,
       ls_030-posnr_vl             to ps_list-posnr_vl,
       ls_030-erdat_vl             to ps_list-erdat_vl,
       ls_030-lfimg                to ps_list-lfimg,
       ls_030-gidat                to ps_list-gidat,
       ls_030-bltype               to ps_list-bltype,
       ls_030-gidat                to ps_list-gidat,
       ls_030-sale_date            to ps_list-sale_date,
       ls_030-vbeln_vf             to ps_list-vbeln_vf,
       ls_030-posnr_vf             to ps_list-posnr_vf,
       ls_030-spmon                to ps_list-spmon,
       ls_030-kursf                to ps_list-kursf,
       ls_030-marginalprofit_per   to ps_list-marginalprofit_per,
       ls_030-marginalprofit_krw   to ps_list-marginalprofit_krw,
       ls_030-remark               to ps_list-remark,
**       ls_030-marginalprofit_per_r to ps_list-marginalprofit_per_r,
**       ls_030-marginalprofit_krw_r to ps_list-marginalprofit_krw_r,
**       ls_030-salesprofit_per_r    to ps_list-salesprofit_per_r,
**       ls_030-salesprofit_krw_r    to ps_list-salesprofit_krw_r,
       ls_030-pernr                to ps_list-pernr,
       ls_030-waers_krw            to ps_list-waers_krw.

*----- (유형에 따라)

*  if ls_030-attr10 is not initial.
*    ps_list-bltype = ls_030-attr10.  "유형
*  else.
*    case ls_030-sotype.
*      when 'BL'.
*        ps_list-bltype    = 'B'.
*        ps_list-gidat     = ls_030-dlvdate.
*      when 'GI'.
*        if ls_030-dlvdate is not initial.
*          ps_list-bltype  = 'E'.
*          ps_list-gidat   = ls_030-dlvdate.
*        endif.
*      when 'DO'.
*        ps_list-bltype    = 'D'.
*      when 'SO'.
*        ps_list-bltype    = 'C'.
*      when ''.
*        ps_list-bltype    = 'A'.
*    endcase.
*  endif.


endform.
*&---------------------------------------------------------------------*
*& Form populate_030_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN
*&      <-- LS_030
*&---------------------------------------------------------------------*
form populate_030_data  using    ps_main structure zgtsds0042
                        changing ls_030 structure zsdt_d365_030.


  ls_030-vkorg                = p_vkorg.
  ls_030-vkbur                = p_vkbur.
  ls_030-pernr                = p_pernr.
  ls_030-spmon                = ps_main-sale_date(6).
  ls_030-vkgrp                = ps_main-vkgrp.

  if ps_main-bltype = 'A'.
    select single land1 into @data(lv_land1)
      from kna1 where kunnr = @ps_main-kunnr.
    if gv_land1 = lv_land1.
      ls_030-vtweg            = '10'.
    else.
      ls_030-vtweg            = '50'.
    endif.

    select single spart into @data(lv_spart)
      from mara where matnr = @ps_main-matnr.

    ls_030-spart              = lv_spart.
    ls_030-land1              = lv_land1.
  else.
    ls_030-vtweg              = ps_main-vtweg.
    ls_030-spart              = ps_main-spart.
    ls_030-land1              = ps_main-land1.
  endif.


  ls_030-zpjno                = ps_main-zpjno.
  ls_030-zptxt                = ps_main-zptxt.
  ls_030-kunnr                = ps_main-kunnr.
  ls_030-kunnr_nm             = ps_main-kunnr_nm.
  ls_030-arktx                = ps_main-arktx.
  ls_030-prodh                = ps_main-prodh.
  ls_030-prodh_nm             = ps_main-prodh_nm.
  ls_030-bltype               = ps_main-bltype.  "유형
  ls_030-edatu                = ps_main-edatu.
  ls_030-jojang_uom           = ps_main-jojang_uom.
  ls_030-jojang_qty           = ps_main-jojang_qty.
  ls_030-matnr                = ps_main-matnr.
  ls_030-kwmeng               = ps_main-kwmeng.
  ls_030-netwr_so             = ps_main-netwr_so.
  ls_030-vrkme                = ps_main-vrkme.
  ls_030-waerk                = ps_main-waerk.
  if ps_main-sale_qty = 0.
  else.
    ls_030-unitprice_local   = ps_main-sale_amt / ps_main-sale_qty. "vbrp-netwr / vbrp-fkimg.
  endif.
  ls_030-vbeln               = ps_main-vbeln_va.
  ls_030-posnr               = ps_main-posnr_va.
  ls_030-seqno               = ps_main-seqno.
*----- (유형에 따라)
*     1) 매출 이면, BL
*     2) 출고 또는 분할-출고 이면, GI
*     3) 그 외이면, SO
  if ps_main-bltype = 'B'.  "매출
    ls_030-sotype = 'BL'.
  elseif ps_main-bltype = 'E' or ps_main-bltype = 'H'. "출고
    ls_030-sotype = 'GI'.
  elseif ps_main-bltype = 'D' or ps_main-bltype = 'G'. "출하진행
    ls_030-sotype = 'DO'.
  elseif ps_main-bltype = 'C' or ps_main-bltype = 'F'. "미출하
    ls_030-sotype = 'SO'.
  else.
    ls_030-sotype = ''.  "의지치
  endif.


  ls_030-vbeln_vl            = ps_main-vbeln_vl.
  ls_030-posnr_vl            = ps_main-posnr_vl.
  ls_030-erdat_vl            = ps_main-erdat_vl.
  ls_030-lfimg               = ps_main-lfimg.
  ls_030-gidat               = ps_main-gidat.

  ls_030-vbeln_vf            = ps_main-vbeln_vf.
  ls_030-posnr_vf            = ps_main-posnr_vf.
  ls_030-erdat_vl            = ps_main-erdat_vl.
  ls_030-sale_qty            = ps_main-sale_qty.  "매출수량
  ls_030-fkdat               = ps_main-fkdat.
  ls_030-sale_date           = ps_main-sale_date.
  ls_030-sale_amt            = ps_main-sale_amt.  "매출액(거래통화)
  ls_030-waers_krw           = 'KRW'.
  ls_030-sale_amt_krw        = ps_main-sale_amt_krw. "매출액(krw)
  ls_030-marginalprofit_per  = ps_main-marginalprofit_per.
  ls_030-marginalprofit_krw  = ps_main-marginalprofit_krw.

**  if ps_main-bltype = 'A'.  "의지치의 경우에는 R-PLANNA값을 update한다.
**    ls_030-marginalprofit_per_r = ps_main-marginalprofit_per.
**    ls_030-marginalprofit_krw_r = ps_main-marginalprofit_krw.
**  else.
**    ls_030-marginalprofit_per_r = ps_main-marginalprofit_per_r.
**    ls_030-marginalprofit_krw_r = ps_main-marginalprofit_krw_r.
**  endif.
**  ls_030-salesprofit_per_r    = ps_main-salesprofit_per_r.
**  ls_030-salesprofit_krw_r    = ps_main-salesprofit_krw_r.

  ls_030-gidat               = ps_main-gidat.
  ls_030-kursf               = ps_main-kursf.
  ls_030-remark              = ps_main-remark.

  if ps_main-kursf is initial and ps_main-waerk = 'KRW'.
    ls_030-kursf = 1.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form set_init_erdat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_init_erdat .

  data: lv_date type sy-datum.

  lv_date = sy-datum(6) && '01'.

  perform get_next_month    using    lv_date(6)  '-6'
                            changing lv_date(6).

  s_erdat-sign    = 'I'.
  s_erdat-option  = 'BT'.
  s_erdat-low     = lv_date.
  s_erdat-high    = sy-datum.
  append s_erdat.

endform.
*&---------------------------------------------------------------------*
*& Form call_pa_report
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form call_pa_report .

  data: lv_versid     type zpls0120t-versid,
        lv_versi_n(2) type n,
        lv_versi      type zpls0120t-versi.

  case sscrfields-ucomm.
    when 'FC01'. " FUNCTION KEY 1의 기본 커맨드 코드
      perform set_base_date. "-- 조회 기준월 세팅
      lv_versi_n = gv_bdate+4(2) + 40.
      lv_versi   = lv_versi_n.
      concatenate '0' lv_versi into lv_versi.

      select max( versid ) into lv_versid
        from zpls0120t
       where kokrs = '1000'
         and bukrs = '1000'
         and zplsgroup = '1123'
         and pyear     = gv_bdate(4)
         and versi     = lv_versi
         and versid like '3%'.

      if sy-subrc = 0 and lv_versid is not initial.

        set parameter id 'CAC'  field '1000'.
        set parameter id 'BUK'  field '1000'.
        set parameter id 'KVS'  field lv_versi.
        set parameter id 'GJR'  field gv_bdate(4).
        set parameter id 'ZPGR' field '1123'.
        set parameter id 'ZPVD' field lv_versid.

        submit zpldr1040 with p_kokrs = '1000'
                         with p_bukrs  = '1000'
                         with p_group  = '1123'
                         with p_pyear  = gv_bdate(4)
                         with p_versi  = lv_versi
                         with p_versid = lv_versid
                         with p_layout = '1'
                         with p_tcode = 'ZPLDR1000'
                         and return.
      else.
        message s001(00) with '300번대 계획 차수 마스터 정보가 존재하지 않습니다.' display like 'E'.
      endif.

  endcase.

endform.
*&---------------------------------------------------------------------*
*& Form add_profit_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_MAIN
*&---------------------------------------------------------------------*
form add_profit_data  tables   pt_main structure zgtsds0042.

  check pt_main[] is not initial.

  loop at pt_main where bltype = 'A'.  "의지치는 영업팀에서 입력한 한계이익률, 한계이익(KRW)을 R-Planna에 그대로 사용함
    pt_main-marginalprofit_per_r = pt_main-marginalprofit_per.
    pt_main-marginalprofit_krw_r = pt_main-marginalprofit_krw.
    modify pt_main.
  endloop.

  data: lt_profit like zpls3024t_ls occurs 0 with header line.

  select * into corresponding fields of table lt_profit
    from zpls3024t_ls
   where spmon = gv_bdate(6).  "R-Planna 요청으로 조회기준월 정보만 가져옴
*   where spmon = ( select max( spmon ) from zpls3024t_ls ).  "R-Planna 요청으로 가장 최신월 정보만 가져옴

  check lt_profit[] is not initial.

*  sort lt_profit by spmon kunnr matnr vkgrp pernr vkbur zpjno.
  sort lt_profit by kunnr matnr vkgrp vkbur zpjno.  "R-Planna 테이블에서 영업사원 삭제됨

  loop at pt_main where bltype <> 'A'.  "의지치는 제외함
    read table lt_profit with key "spmon = pt_main-spmon  "R-Planna 요청으로 매출월은 고려하지 않음
                                  kunnr = pt_main-kunnr
                                  matnr = pt_main-matnr
                                  vkgrp = pt_main-vkgrp
*                                  pernr = pt_main-pernr  "R-Planna 테이블에서 영업사원 삭제됨
                                  vkbur = p_vkbur
                                  zpjno = pt_main-zpjno
                                  binary search.
    if sy-subrc = 0.
      pt_main-marginalprofit_per_r = lt_profit-marginalprofit_per_r.
      pt_main-marginalprofit_krw_r = pt_main-sale_amt_krw * lt_profit-marginalprofit_per_r / 100.
      pt_main-salesprofit_per_r    = lt_profit-salesprofit_per_r.
      pt_main-salesprofit_krw_r    = pt_main-sale_amt_krw * lt_profit-salesprofit_per_r / 100.
      modify pt_main.
    endif.
  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form set_base_date
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_base_date .

  if p_premon = ''.
    gv_bdate = sy-datum. "당월기준으로 재조회
  else.
    gv_bdate = sy-datum(6) && '01'.
    gv_bdate = gv_bdate - 1. "전월기준으로 재조회
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form check_duplicate_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_DETL
*&      <-- L_ERR
*&      <-- L_MSG
*&---------------------------------------------------------------------*
form check_duplicate_data  tables   pt_detl structure zgtsds0042
                           using    pv_date
                           changing pv_err
                                    pv_msg.

  data: lt_wish     like zgtsds0042 occurs 0 with header line,
        lt_wish_new like zgtsds0042 occurs 0 with header line.

  pv_err = ''.

  lt_wish[] = gt_main[].
  delete lt_wish where bltype <> 'A'.

  check lt_wish[] is not initial.

*  loop at pt_detl where bltype = 'A'.
*    read table lt_wish with key pernr = pt_detl-pernr
*                                spmon = pt_detl-spmon
*                                sale_date = pt_detl-sale_date
*                                kunnr = pt_detl-kunnr
*                                zpjno = pt_detl-zpjno
*                                prodh = pt_detl-prodh
*                                matnr = pt_detl-matnr
*                                 .
*    if sy-subrc = 0.
*      move-corresponding lt_wish to lt_wish_new.
*
*      lt_wish_new-spmon = pv_date(6).
*      lt_wish_new-fkdat = pv_date.
*      append lt_wish_new.
*    endif.
*  endloop.

  loop at lt_wish. " where bltype = 'A'.
    move-corresponding lt_wish to lt_wish_new.

    read table pt_detl with key pernr = lt_wish-pernr
                                spmon = lt_wish-spmon
                                sale_date = lt_wish-sale_date
                                kunnr = lt_wish-kunnr
                                zpjno = lt_wish-zpjno
                                prodh = lt_wish-prodh
                                matnr = lt_wish-matnr
                                bltype = 'A'
                                 .
    if sy-subrc = 0.
      lt_wish_new-spmon     = pv_date(6).
      lt_wish_new-sale_date = pv_date.
    endif.

    append lt_wish_new.

  endloop.

  sort lt_wish_new by pernr spmon sale_date kunnr zpjno prodh matnr.
  delete adjacent duplicates from lt_wish_new
         comparing pernr spmon sale_date kunnr zpjno prodh matnr.

  if lines( lt_wish[] ) <> lines( lt_wish_new[] ).
    pv_err = 'X'.
    pv_msg = '의지치가 중복으로 입력되었습니다.'.
  endif.

endform.
