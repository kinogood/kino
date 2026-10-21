*&---------------------------------------------------------------------*
*& Include          ZGTSDR0010F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form initialization .

  data : lv_sdt type sy-datlo,
         lv_edt type sy-datlo.

  concatenate sy-datlo(6) '01' into lv_sdt.
  append value #( sign = 'I' option = 'EQ' low = sy-datlo ) to s_spmon.

*검색일자 (현재일–3개월의 1일 ~ 현재일
  call function 'RP_CALC_DATE_IN_INTERVAL'
    exporting
      date      = sy-datlo
      days      = '00'
      months    = '03'
      signum    = '-'
      years     = '00'
    importing
      calc_date = lv_sdt.

  concatenate lv_sdt(6) '01' into lv_sdt.
  append value #( sign = 'I' option = 'BT' low = lv_sdt high = sy-datlo ) to s_edatu.

endform.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form modify_screen .

  loop at screen.
    case screen-name.
      when 'S_EDATU-LOW' or 'S_EDATU-HIGH'.
        screen-input = 0.
      when 'S_SPMON-LOW'.
        screen-required = 2.
      when 'S_VKBUR-LOW'.
        if rb_mbt2 = zgtsd_x.
          screen-required = 2.
        endif.
      when 'P_NAME1'.

        screen-input = 0.
        screen-intensified = 1.
        screen-display_3d  = 0.
      when others.
    endcase.

    case screen-group1.

      when 'M1'.
        if rb_mbt2 = gc_x.
          screen-active = 0.
        else.
          screen-active = 1.
        endif.
      when 'M2'.
        if rb_mbt2 = gc_x.
          screen-active = 1.
        else.
          screen-active = 0.
        endif.
    endcase.

    modify screen.
  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form check_input_data .

  clear gv_error.

  "기본 필수입력 필드 체크
*  IF S_KUNNR[] IS INITIAL. "
*    MESSAGE S055(00) DISPLAY LIKE ZGTSD_E.
*    GV_ERROR = ZGTSD_X.
*    RETURN.
*  ENDIF.

  if s_spmon[] is initial. "
    message s007 with %_s_spmon_%_app_%-text display like zgtsd_e.
    gv_error = zgtsd_x.
    return.
  endif.

  if rb_mbt2 = zgtsd_x and s_vkbur[] is initial. "
    message s007 with %_s_vkbur_%_app_%-text display like zgtsd_e.
    gv_error = zgtsd_x.
    return.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form authority_check .

*  "권한 체크
*  ZGTSD_CL_COMMON=>AUTHORITY_CHECK( EXPORTING IV_OBJECT     = 'VKO'
*                                              IV_AUTH_FIELD = CONV XUFIELD( |VKORG| )
*                                              IV_AUTH_VAL   = CONV XUVAL( P_VKORG )
*                                    IMPORTING EV_MTYPE      = DATA(LV_MTYPE)
*                                              EV_MSGTX      = DATA(LV_MSGTX) ).
*  IF LV_MTYPE = GC_E.
*    MESSAGE S001(00) WITH LV_MSGTX DISPLAY LIKE GC_E.
*    LEAVE LIST-PROCESSING.
*  ENDIF.

endform.
*&---------------------------------------------------------------------*
*& Form DATA_QUERY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form data_query using pv_type.

  ranges : lr_zpjno for zsdt_d365_021-zpjno.

  data : lt_0010 type table of zgtsdt0010 with non-unique sorted key
                                          k_key components vbeln posnr seqno.
  data : lv_zpjno  type vbak-zpjno,
         lv_tdname type thead-tdname,
         lv_stat   type char100,
         lv_flag   type char01,
         lt_line   type table of tline with header line.

  data : begin of ls_split,
           str type char200,
         end of ls_split,
         lt_split like table of ls_split with empty key.
  __cle : gt_s0100.

  case zgtsd_x.

    when rb_mbt1.

      perform get_plan_data.    " 판매계획 /

    when rb_mbt2.

      perform get_open_so_data.  "실시간주문

  endcase.

**********************************************************************
  data(lt_for) = gt_s0100[].
  sort lt_for by vbeln posnr seqno.
  delete adjacent duplicates from lt_for comparing vbeln posnr seqno.
  if lt_for[] is not initial.
    select zgtsdt0010~* into corresponding fields of table @lt_0010
      from zgtsdt0010
       for all entries in @lt_for
     where vbeln  = @lt_for-vbeln
       and posnr  = @lt_for-posnr
       and seqno  = @lt_for-seqno.

    select kdauf, kdpos, plnum, pedtr into table @data(lt_plaf)
      from plaf
       for all entries in @lt_for
     where kdauf = @lt_for-vbeln
       and kdpos = @lt_for-posnr.

    select b~kdauf, b~kdpos, c~gltrp, b~aufnr into table @data(lt_aufk)
      from aufk as a inner join afpo as b
        on a~aufnr = b~aufnr
     inner join afko as c
        on b~aufnr = c~aufnr
       for all entries in @lt_for
     where b~kdauf = @lt_for-vbeln
       and b~kdpos = @lt_for-posnr
       and auart like 'PP%'.
    loop at lt_aufk into data(ls_aufk).
      clear : lv_flag, lv_stat.
      call function 'Z_PP_ORDER_STATUS'
        exporting
          i_aufnr  = ls_aufk-aufnr
        importing
          e_status = lv_stat.

*생산 오더 상태 고려 필요, DLFL(삭제), TECO(기술적완료), CLSD(종료) 제외
      split lv_stat at space into table lt_split.
      select single @abap_on
        from @lt_split as a
       where str in ('DLFL', 'TECO', 'CLSD' )
        into @lv_flag.
      if lv_flag = 'X'.
        delete lt_aufk.
      endif.

    endloop.
  endif.

  lt_for[] = gt_s0100[].
  delete lt_for where zpjno is initial.
  sort lt_for by zpjno.
  delete adjacent duplicates from lt_for comparing zpjno.
  if lt_for[] is not initial.

    loop at lt_for into data(ls_tmp).
      if ls_tmp-zpjno(2) = |PD|.
        lv_zpjno = ls_tmp-zpjno.
      else.
        lv_zpjno = ls_tmp-zpjno(8) && |*|.
      endif.
      __rng lr_zpjno 'I' 'CP' lv_zpjno ''.
    endloop.

    select zpjno, zptxt into table @data(lt_zpjt)
      from zsd0106t
     where zpjno in @lr_zpjno.
  endif.

  sort lt_aufk by kdauf kdpos.
  sort lt_aufk by kdauf kdpos.

  loop at gt_s0100 into gs_s0100.

    read table lt_zpjt into data(ls_zpjt) with key zpjno = gs_s0100-zpjno.
    if sy-subrc = 0.
      gs_s0100-zptxt = ls_zpjt-zptxt.
    else.
      read table lt_zpjt into ls_zpjt with key zpjno(8) = gs_s0100-zpjno.
      if sy-subrc = 0.
        gs_s0100-zptxt = ls_zpjt-zptxt.
      endif.
    endif.
    clear ls_zpjt.

    data(lt_dat) = filter #( lt_0010 using key k_key
                                     where vbeln = gs_s0100-vbeln
                                       and posnr = gs_s0100-posnr
                                       and seqno = gs_s0100-seqno ).

    sort lt_dat by zckey descending ppdat descending.
    read table lt_dat into data(ls_0010) index 1.
    gs_s0100-ppdat = ls_0010-ppdat.

    clear ls_0010.
    sort lt_dat by zckey descending qmdat descending.
    read table lt_dat into ls_0010 index 1.
    gs_s0100-qmdat = ls_0010-qmdat.

    clear ls_0010.
    sort lt_dat by zckey descending ledat descending.
    read table lt_dat into ls_0010 index 1.
    gs_s0100-ledat = ls_0010-ledat.

    clear ls_0010.
    sort lt_dat by zckey descending lodat descending.
    read table lt_dat into ls_0010 index 1.
    gs_s0100-lodat = ls_0010-lodat.

    read table lt_plaf into data(ls_plaf) with key kdauf = gs_s0100-vbeln
                                                   kdpos = gs_s0100-posnr
                                                   binary search.
    if sy-subrc = 0.
      gs_s0100-plnum = ls_plaf-plnum.
      gs_s0100-pedtr = ls_plaf-pedtr.
    else.
      read table lt_aufk into ls_aufk with key kdauf = gs_s0100-vbeln
                                               kdpos = gs_s0100-posnr
                                               binary search.
      if sy-subrc = 0.
        gs_s0100-plnum =  |{ ls_aufk-aufnr alpha = out   }|. " LS_AUFK-AUFNR.
        gs_s0100-pedtr = ls_aufk-gltrp.
      endif.
    endif.

*URL
    __cle lt_line. clear lv_tdname.
    lv_tdname = gs_s0100-vbeln.
    call function 'READ_TEXT'
      exporting
        id                      = '0002'
        language                = sy-langu
        name                    = lv_tdname
        object                  = 'VBBK'
      tables
        lines                   = lt_line
      exceptions
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        others                  = 8.

    if lt_line[] is not initial.
      gs_s0100-uicon = icon_open_linked_folder.
      loop at lt_line.
        concatenate gs_s0100-url lt_line-tdline into gs_s0100-url.
      endloop.
    endif.

    __cle gs_s0100-cells.

    perform set_alv_fld_style using gs_s0100-cells :
                                    'PPDAT' rb_bt1,  " 생산완료일
                                    'QMDAT' rb_bt2,  " FAT
                                    'LEDAT' rb_bt3,  " 출하일
                                    'LODAT' rb_bt4.  " 선적확정일

*
*    case zgtsd_x.
*      when rb_bt1.
*        perform set_alv_fld_style using gs_s0100-cells :
*                                        'PPDAT' 'X',
*                                        'QMDAT' '',
*                                        'LEDAT' '',
*                                        'LODAT' ''.
*      when rb_bt2.
*        perform set_alv_fld_style using gs_s0100-cells :
*                                        'PPDAT' '',
*                                        'QMDAT' 'X',
*                                        'LEDAT' '',
*                                        'LODAT' ''.
*      when rb_bt3.
*        perform set_alv_fld_style using gs_s0100-cells :
*                                        'PPDAT' '',
*                                        'QMDAT' '',
*                                        'LEDAT' 'X',
*                                        'LODAT' ''.
*      when rb_bt4.
*        perform set_alv_fld_style using gs_s0100-cells :
*                                        'PPDAT' '',
*                                        'QMDAT' '',
*                                        'LEDAT' '',
*                                        'LODAT' 'X'.
*    endcase.


    clear ls_0010.
    modify gt_s0100 from gs_s0100.
  endloop.


  sort gt_s0100 by vbeln posnr.

**********************************************************************
  check pv_type is initial.
  "데이타 건수 메시지 출력
  if gt_s0100 is not initial.
    message s009 with |{ lines( gt_s0100 ) number = user }|. "& 건 검색되었습니다.
  else.
    message s010.                                           "조회할 데이타가 없습니다.
    gv_error = gc_x.                                        "데이타 없으면 출력 X
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form INIT_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GO_CON
*&      <-- GO_GRID
*&---------------------------------------------------------------------*
form init_alv_0100  changing po_dcon type ref to cl_gui_docking_container
                             po_grid type ref to cl_gui_alv_grid.

  "Create Main Container
  perform create_doc_container changing po_dcon.

  case sy-dynnr.

    when 0100.

*      "Split
*      GO_SPLIT = NEW #( PARENT = PO_DCON ROWS = 2 COLUMNS = 1 ).
*
*      GO_CON_TOP       = GO_SPLIT->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
*      DATA(LO_CON_BTT) = GO_SPLIT->GET_CONTAINER( ROW = 2 COLUMN = 1 ).
*
*      GO_SPLIT->SET_ROW_HEIGHT( ID = 1 HEIGHT = 10 ).
*
*      "Create Object
*      GO_DOCU = NEW #( STYLE = 'ALV_GRID' ).  "Top-Of-Page

      perform create_alv using    po_dcon "LO_CON_BTT
                         changing po_grid.

    when others.
      perform create_alv using    po_dcon
                         changing po_grid.
  endcase.

endform.
*&---------------------------------------------------------------------*
*&      Form  CREATE_DOC_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form create_doc_container changing po_dcon type ref to cl_gui_docking_container.

  create object po_dcon
    exporting
      parent                      = cl_gui_container=>default_screen
      repid                       = sy-repid
      dynnr                       = sy-dynnr
      side                        = cl_gui_docking_container=>dock_at_top
      extension                   = 3000
    exceptions
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      others                      = 6.

endform.
*&---------------------------------------------------------------------*
*&      Form  CREATE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form create_alv changing po_con
                         po_grid type ref to cl_gui_alv_grid.

  create object po_grid
    exporting
      i_parent          = po_con
    exceptions
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      others            = 5.

endform.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form set_attributes_0100 .

  "Layout 지정
  perform set_grid_layout using space 'CELLS' zgtsd_d.
  gs_layout-no_rowmark = 'X'.
  gs_layout-ctab_fname = 'CELLC'.

  "Field Catalog
  perform set_fieldcatalog.

  "Toolbar 제외
  perform exclude_toolbar tables gt_toolbar.

  "Event Handler 등록
  perform create_event_receiver using go_grid.

  "F4 필드 등록
  perform register_f4_fields.

  "SORT
  perform set_alv_sort changing gt_sort.

  "Top-Of-Page Event 등록
*  PERFORM SET_TOP_OF_PAGE_EVENT.

  perform set_color.

  "ALV Grid Display
  perform set_table_for_first_display using go_grid
                                            gt_s0100.

endform.
*&---------------------------------------------------------------------*
*& Form SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form set_grid_layout using pv_cwopt
                           pv_stylefname
                           pv_sel_mode.

  clear gs_layout.
  gs_layout = value #( sel_mode   = pv_sel_mode
                       zebra      = zgtsd_x
                       cwidth_opt = pv_cwopt
                       stylefname = pv_stylefname ).

endform.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form set_fieldcatalog .

  "Get Field Catalog
  perform get_field_catalog using gt_s0100 changing gt_fcat.

  "Set Field Catalog
  perform set_fieldcatalog_main.

endform.
*&---------------------------------------------------------------------*
*& Form GET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form get_field_catalog using pt_table type table
                    changing pt_fcat type lvc_t_fcat.

  refresh pt_fcat.

  pt_fcat = zgtsd_cl_common=>get_field_catalog( it_table = pt_table
                                                iv_cells = zgtsd_x
                                                iv_cellc = zgtsd_x ).

endform.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG_MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_fieldcatalog_main .


  sort gt_fcat by fieldname.

  perform reset_field_catalog tables gt_fcat using :

      'S' 'FIELDNAME'   'HDSEL',
      ' ' 'COLTEXT'     'S/O선택',
      ' ' 'CHECKBOX'    'X',
      ' ' 'EDIT'         'X',
      ' ' 'OUTPUTLEN'   '6',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'ITSEL',
      ' ' 'COLTEXT'     '품목선택',
      ' ' 'CHECKBOX'    'X',
      ' ' 'EDIT'         'X',
      ' ' 'OUTPUTLEN'   '6',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'VBELN',
      ' ' 'COLTEXT'     text-f04,
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'POSNR',
      ' ' 'COLTEXT'     text-f05,
      ' ' 'OUTPUTLEN'   '6',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'KUNNR',
      ' ' 'COLTEXT'     text-f22,
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'NAME1',
      ' ' 'COLTEXT'     text-f23,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'SPART',
      ' ' 'COLTEXT'     text-f31,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'VTEXT',
      ' ' 'COLTEXT'     text-f32,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'VKBUR',
      ' ' 'COLTEXT'     text-f28,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'BEZEI',
      ' ' 'COLTEXT'     text-f29,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'ZPJNO',
      ' ' 'COLTEXT'     text-f02,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'ZPTXT',
      ' ' 'COLTEXT'     text-f03,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'NAME',
      ' ' 'COLTEXT'     text-f30,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'MATNR',
      ' ' 'COLTEXT'     text-f06,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'ITEMNAME',
      ' ' 'COLTEXT'     text-f07,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'KWMENG',
      ' ' 'COLTEXT'     text-f08,
      ' ' 'QFIELDNAME' 'VRKME',
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'VRKME',
      ' ' 'COLTEXT'     text-f09,
      'E' 'OUTPUTLEN'   '6',

      'S' 'FIELDNAME'   'EDATU',
      ' ' 'COLTEXT'     text-f33,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'PLNUM',
      ' ' 'COLTEXT'     text-f10,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'PEDTR',
      ' ' 'COLTEXT'     text-f11,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'PPDAT',
      ' ' 'COLTEXT'     text-f12,
      ' ' 'REF_TABLE'   'ZGTSDT0010',
      ' ' 'REF_FIELD'   'PPDAT',
      ' ' 'EDIT'        'X',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'SEQNO',
      ' ' 'COLTEXT'     text-f13,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'QUANTITY',
      ' ' 'COLTEXT'     text-f14,
      ' ' 'QFIELDNAME' 'VRKME',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'DLVDATE',
      ' ' 'COLTEXT'     text-f15,
      ' ' 'REF_TABLE'   'ZGTSDT0010',
      ' ' 'REF_FIELD'   'DLVDATE',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'QMDAT',
      ' ' 'COLTEXT'     text-f16,
      ' ' 'REF_TABLE'   'ZGTSDT0010',
      ' ' 'REF_FIELD'   'QMDAT',
      ' ' 'EDIT'        'X',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'LEDAT',
      ' ' 'COLTEXT'     text-f17,
      ' ' 'REF_TABLE'   'ZGTSDT0010',
      ' ' 'REF_FIELD'   'LEDAT',
      ' ' 'EDIT'        'X',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'LODAT',
      ' ' 'COLTEXT'     text-f18,
      ' ' 'REF_TABLE'   'ZGTSDT0010',
      ' ' 'REF_FIELD'   'LODAT',
      ' ' 'EDIT'        'X',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'FKDAT',
      ' ' 'COLTEXT'     text-f19,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'ERDAT',
      ' ' 'COLTEXT'     text-f20,
      ' ' 'REF_TABLE'   'ZGTSDT0010',
      ' ' 'REF_FIELD'   'ERDAT',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'UICON',
      ' ' 'COLTEXT'     text-f24,
      ' ' 'ICON'        'X',
      ' ' 'HOTSPOT'     'X',
      'E' 'OUTPUTLEN'   '10'.

endform.
*&---------------------------------------------------------------------*
*& Form RESET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form reset_field_catalog tables pt_fcat type lvc_t_fcat
                         using  pv_flag
                                pv_fname
                                pv_value.

  statics : ls_fcat   type lvc_s_fcat,
            lv_colpos type lvc_colpos,
            lv_tabix  type sytabix.

  if pv_flag = zgtsd_s.  "Start
    clear ls_fcat.
    read table pt_fcat into ls_fcat with key fieldname = pv_value binary search.
    check sy-subrc = 0.
    lv_tabix = sy-tabix.

    lv_colpos = lv_colpos + 1.

    ls_fcat-tech    = space.
    ls_fcat-col_pos = lv_colpos.
  endif.

  case pv_fname.
    when 'EDIT'.
      assign component pv_fname of structure ls_fcat to field-symbol(<lv_value>).
      check sy-subrc = 0.
      case ls_fcat-fieldname.
        when 'PPDAT'. <lv_value> = cond #( when rb_bt1 = 'X' then 'X' else space ).
        when 'QMDAT'. <lv_value> = cond #( when rb_bt2 = 'X' then 'X' else space ).
        when 'LEDAT'. <lv_value> = cond #( when rb_bt3 = 'X' then 'X' else space ).
        when 'LODAT'. <lv_value> = cond #( when rb_bt4 = 'X' then 'X' else space ).
        when others.
          <lv_value> = pv_value.
      endcase.

    when 'COLTEXT'.   "Text
      ls_fcat-coltext  = pv_value.
      ls_fcat-reptext  = pv_value.
      ls_fcat-seltext  = pv_value.
      ls_fcat-tooltip  = pv_value.
    when others.
      assign component pv_fname of structure ls_fcat to <lv_value>.
      check sy-subrc = 0.
      <lv_value> = pv_value.
  endcase.

  if pv_flag = zgtsd_e.  "End
    modify pt_fcat from ls_fcat index lv_tabix.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*----------------------------------------------------------------------*
form exclude_toolbar tables pt_exclude type ui_functions.

  refresh pt_exclude.

  append : cl_gui_alv_grid=>mc_fc_loc_undo            to pt_exclude,
           cl_gui_alv_grid=>mc_fc_data_save           to pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_copy            to pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_copy_row        to pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_cut             to pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_delete_row      to pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_insert_row      to pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_move_row        to pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_append_row      to pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_paste           to pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_paste_new_row   to pt_exclude,
           cl_gui_alv_grid=>mc_fc_refresh             to pt_exclude,
           cl_gui_alv_grid=>mc_fc_check               to pt_exclude,
           cl_gui_alv_grid=>mc_fc_print               to pt_exclude,
           cl_gui_alv_grid=>mc_fc_views               to pt_exclude,
           cl_gui_alv_grid=>mc_fc_graph               to pt_exclude,
           cl_gui_alv_grid=>mc_fc_info                to pt_exclude.

endform.
*&---------------------------------------------------------------------*
*& Form CREATE_EVENT_RECEIVER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form create_event_receiver using po_sender type ref to cl_gui_alv_grid.

  "Create Event
  data(lo_event) = new lcl_event_receiver( ).

*  CASE PO_SENDER.
*    WHEN GO_GRID.
**      SET HANDLER : LO_EVENT->HANDLE_TOP_OF_PAGE FOR PO_SENDER.
*  ENDCASE.

  set handler : lo_event->handle_hotspot_click         for po_sender,
                lo_event->handle_data_changed          for po_sender,
                lo_event->handle_toolbar               for po_sender,
                lo_event->handle_user_command          for po_sender,
                lo_event->handle_dbl_click             for po_sender,
*                LO_EVENT->HANDLE_ON_F4                 FOR PO_SENDER.
                lo_event->handle_data_changed_finished for po_sender.

  "Data Changed Event
  po_sender->register_edit_event( cl_gui_alv_grid=>mc_evt_modified ).
  po_sender->register_edit_event( cl_gui_alv_grid=>mc_evt_enter ).

  "Set Ready for Input
  go_grid->set_ready_for_input( switch #( gv_edit when zgtsd_x then 1 else 0 ) ).

endform.
*&---------------------------------------------------------------------*
*& Form REGISTER_F4_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form register_f4_fields .

  data : lt_f4   type lvc_t_f4,
         lt_fcat type table of lvc_s_fcat
                 with non-unique sorted key key_mode
                 components f4availabl fieldname.

  lt_fcat = gt_fcat.
  loop at lt_fcat into data(ls_fcat) using key key_mode
                  where f4availabl = zgtsd_x.
    lt_f4 = value #( base lt_f4 ( fieldname  = ls_fcat-fieldname
                                  register   = zgtsd_x
                                  chngeafter = zgtsd_x ) ).
  endloop.

  go_grid->register_f4_for_fields( exporting it_f4 = lt_f4 ).

endform.
*&---------------------------------------------------------------------*
*& Form SET_TOP_OF_PAGE_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form set_top_of_page_event .

  check go_docu is bound.

  go_docu->initialize_document( background_color = cl_dd_area=>col_textarea ).

  call method go_grid->list_processing_events(
      i_event_name = slis_ev_top_of_page
      i_dyndoc_id  = go_docu ).

endform.
*&---------------------------------------------------------------------*
*& Form SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form set_table_for_first_display using po_sender type ref to cl_gui_alv_grid
                                       pt_data type table.
  data : lv_handl type slis_handl.

  perform set_variant_handle using po_sender changing lv_handl.
  gs_variant-report = sy-cprog.
  gs_variant-handle = lv_handl.


  delete gt_fcat where tech = zgtsd_x. "불필요한 필드 제외

  "Formatted Output Table is Sent to Control
  call method po_sender->set_table_for_first_display
    exporting
      is_layout            = gs_layout
      is_variant           = gs_variant " VALUE #( REPORT = SY-REPID
    " HANDLE               = LV_HANDL )
      i_save               = zgtsd_a
      it_toolbar_excluding = gt_toolbar
    changing
      it_fieldcatalog      = gt_fcat
      it_sort              = gt_sort[]
      it_outtab            = pt_data[].

endform.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_HANDLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form set_variant_handle using po_sender type ref to cl_gui_alv_grid
                         changing pv_handl.

  clear pv_handl.
  case po_sender.
    when go_grid. "Main
      pv_handl = '1'.
    when others.
  endcase.
  condense pv_handl.
endform.
*&---------------------------------------------------------------------*
*& Form HANDLE_DBL_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
form handle_dbl_click  using    pv_row     type lvc_s_row
                                pv_column  type lvc_s_col.

  ranges : lr_do for lips-vbeln.

  check pv_row-rowtype eq space.
  read table gt_s0100 into gs_s0100 index pv_row-index.
  check sy-subrc = 0 .

  case pv_column.

    when 'VBELN'.
      check gs_s0100-vbeln is not initial.
      set parameter id 'AUN' field   gs_s0100-vbeln.
      call transaction  'VA03' and skip first screen.

  endcase.

endform.
*&---------------------------------------------------------------------*
*& Form SET_ALV_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_SORT
*&---------------------------------------------------------------------*
form set_alv_sort  changing pt_sort type lvc_t_sort.

  clear : pt_sort[].

*  PERFORM SET_SORT_FIELD USING: PT_SORT 'KUNNR' GC_X '' '',
*                                PT_SORT 'AEDAT' GC_X '' '',
*                                PT_SORT 'AEZET' GC_X '' ''.

endform.
*&---------------------------------------------------------------------*
*& Form SET_SORT_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_SORT
*&      --> P_
*&      --> GC_X
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
form set_sort_field  using pt_sort type lvc_t_sort
                           pv_fldname
                           pv_up
                           pv_down
                           pv_subtot.

  append value #( spos      = lines( pt_sort ) + 1
                  fieldname = pv_fldname
                  up        = pv_up
                  down      = pv_down
                  subtot    = pv_subtot ) to pt_sort.
endform.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form handle_top_of_page using po_docu type ref to cl_dd_document
                                  po_sender.
  data : lv_text type sdydo_text_element.

  check po_sender = go_grid "Main
    and po_docu is bound.

  "Set Column Width
  po_docu->add_table( exporting no_of_columns = 3 border = '0' importing table = data(lo_table) ).

  lo_table->add_column( exporting width = '20%' importing column = data(lo_col_key) ).
  lo_table->add_column( exporting width = '3%' importing column = data(lo_col_sep) ).
  lo_table->add_column( exporting width = '77%' importing column = data(lo_col_val) ).
  lo_table->new_row( ).

  "Set Column Style
  lo_table->set_column_style( col_no = 1 sap_emphasis = cl_dd_document=>strong sap_align = 'LEFT' ).
  lo_table->set_column_style( col_no = 3 sap_emphasis = cl_dd_document=>medium sap_align = 'LEFT' ).

  perform add_text_common using lo_col_key lo_col_sep lo_col_val lo_table
                                zgtsd_s %_s_vkbur_%_app_%-text 'S_VKBUR[]'.

  perform add_text_common using lo_col_key lo_col_sep lo_col_val lo_table
                                zgtsd_s %_s_zpjno_%_app_%-text 'S_ZPJNO[]'.

  perform add_text_common using lo_col_key lo_col_sep lo_col_val lo_table
                              zgtsd_s %_s_vbeln_%_app_%-text 'S_VBELN[]'.

  perform add_text_common using lo_col_key lo_col_sep lo_col_val lo_table
                            zgtsd_s %_s_matnr_%_app_%-text 'S_MATNR[]'.

  perform add_text_common using lo_col_key lo_col_sep lo_col_val lo_table
                            zgtsd_s %_s_spmon_%_app_%-text 'S_SPMON[]'.


*  case zgtsd_x.
*    when rb_bt1.
*      concatenate text-s06 text-s02 into data(lv_msg) separated by space.
*    when rb_bt2.
*      concatenate text-s06 text-s03 into lv_msg separated by space.
*    when rb_bt3.
*      concatenate text-s06 text-s04 into lv_msg separated by space.
*    when rb_bt4.
*      concatenate text-s06 text-s05 into lv_msg separated by space.
*  endcase.

  data lv_msg(120) type c.
  data(lv_list) = ``.
  if rb_bt1 = 'X'. lv_list = cond string( when lv_list is initial then text-s02 else lv_list && ', ' && text-s02 ). endif.
  if rb_bt2 = 'X'. lv_list = cond string( when lv_list is initial then text-s03 else lv_list && ', ' && text-s03 ). endif.
  if rb_bt3 = 'X'. lv_list = cond string( when lv_list is initial then text-s04 else lv_list && ', ' && text-s04 ). endif.
  if rb_bt4 = 'X'. lv_list = cond string( when lv_list is initial then text-s05 else lv_list && ', ' && text-s05 ). endif.

  lv_msg = text-s06.
  if lv_list is not initial.
    concatenate text-s06 lv_list into lv_msg separated by space.
  endif.
  perform add_text_common using lo_col_key lo_col_sep lo_col_val lo_table
                          zgtsd_p lv_msg space.

  "Display Document
  po_docu->merge_document( ).
  po_docu->display_document( exporting
                               reuse_control      = zgtsd_x
                               parent             = go_con_top
                             exceptions
                               html_display_error = 1 ).

endform.
*&---------------------------------------------------------------------*
*& Form ADD_TEXT_COMMON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form add_text_common using po_col_key type ref to cl_dd_area
                               po_col_sep type ref to cl_dd_area
                               po_col_val type ref to cl_dd_area
                               po_table   type ref to cl_dd_table_element
                               pv_flag
                               pv_key
                               pv_value.
  field-symbols : <lt_selopt> type table.
  data lv_text type char255.

  case pv_flag.
    when zgtsd_p. "Parameter
      check pv_value is not initial.
      lv_text = conv sdydo_text_element( pv_value ).
    when zgtsd_s. "Select-Option
      assign (pv_value) to <lt_selopt>.
      check sy-subrc = 0.

      check lines( <lt_selopt> ) => 1.

      assign component 'LOW' of structure <lt_selopt>[ 1 ] to field-symbol(<lv_low>).
      check sy-subrc = 0.
      assign component 'HIGH' of structure <lt_selopt>[ 1 ] to field-symbol(<lv_high>).
      check sy-subrc = 0.

      if <lv_high> is initial.
        lv_text = <lv_low>.
      elseif <lv_low> is initial.
        lv_text = `~ ` &&  <lv_low>.
      else.
        lv_text = <lv_low> && ` ~ ` &&  <lv_high>.
      endif.
  endcase.

  po_col_key->add_text( text = conv sdydo_text_element( pv_key ) ).
  po_col_sep->add_text( text = conv sdydo_text_element( zgtsd_colon ) ).
  po_col_val->add_text( text = lv_text ).

  po_table->new_row( ).

endform.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form handle_hotspot_click using ps_column type lvc_s_col
                                ps_row_no type lvc_s_roid
                                po_sender.

  check po_sender = go_grid. "Main

  case ps_column-fieldname.

    when 'UICON'. "

      read table gt_s0100 into data(ls_main) index ps_row_no-row_id.
      check sy-subrc = 0.

      check ls_main-uicon is not initial.
      perform call_url using ls_main-url.

  endcase.

endform.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form handle_data_changed using po_data_changed type ref to
                                 cl_alv_changed_data_protocol
                                 po_sender.

  check po_sender = go_grid.  "Main

  data(lt_mod_cells) = po_data_changed->mt_good_cells.
  sort lt_mod_cells by row_id fieldname.

  refresh gt_chg.

  call method po_data_changed->refresh_protocol.

  loop at lt_mod_cells into data(ls_mod_temp).

    data(ls_mod_cells) = ls_mod_temp.

    at new row_id.
      read table gt_s0100 into data(ls_main) index ls_mod_cells-row_id.
      check sy-subrc = 0.
    endat.

    "체크사항 점검 및 Set Value
    perform check_value_in_datachd using    po_data_changed
                                            ls_mod_cells
                                   changing ls_main.

    at end of row_id.
      "변경상태 Update
      perform update_statu using    po_data_changed
                                    ls_mod_cells
                           changing ls_main-statu
                                    ls_main-modi.
      modify gt_s0100 from ls_main index ls_mod_cells-row_id.
      append corresponding #( ls_main ) to gt_chg.
    endat.

  endloop.

  "Display Protocol
  po_data_changed->display_protocol( ).

endform.
*&---------------------------------------------------------------------*
*& Form CHECK_VALUE_IN_DATACHD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form check_value_in_datachd using po_data_changed type ref to cl_alv_changed_data_protocol
                                  ps_mod_cells type lvc_s_modi
                         changing ps_data structure gs_s0100.

  data : lv_subrc type sysubrc.

  case ps_mod_cells-fieldname.

    when 'PPDAT'. "확정(생산완료일)

      "유효성 체크
      if ps_mod_cells-value is not initial and ps_mod_cells-value > 1.

        perform check_changed_ppdat using    ps_data
                                             ps_mod_cells
                                    changing lv_subrc.

        if lv_subrc is not initial.
          perform add_protocol_entry using po_data_changed
                                           'ZGTSD01' '000' space text-e01
                                           ps_mod_cells-fieldname
                                           ps_mod_cells-row_id.
          return.
        endif.
      endif.

      assign component ps_mod_cells-fieldname of structure ps_data to field-symbol(<lv_value>).
      check sy-subrc = 0.
      <lv_value> = ps_mod_cells-value.

    when 'QMDAT'. "FAT

      if ps_mod_cells-value is not initial and ps_mod_cells-value > 1.

        perform check_changed_qmdat using    ps_data
                                             ps_mod_cells
                                    changing lv_subrc.
        if lv_subrc is not initial.
          perform add_protocol_entry using po_data_changed
                                   'ZGTSD01' '000' space text-e01
                                   ps_mod_cells-fieldname
                                   ps_mod_cells-row_id.
          return.
        endif.
      endif.

      assign component ps_mod_cells-fieldname of structure ps_data to <lv_value>.
      check sy-subrc = 0.
      <lv_value> = ps_mod_cells-value.

    when 'LEDAT'. "출하일

      if ps_mod_cells-value is not initial and ps_mod_cells-value > 1.

        perform check_changed_ledat using    ps_data
                                             ps_mod_cells
                                    changing lv_subrc.
        if lv_subrc is not initial.
          perform add_protocol_entry using po_data_changed
                                   'ZGTSD01' '000' space text-e01
                                   ps_mod_cells-fieldname
                                   ps_mod_cells-row_id.
          return.
        endif.

      endif.

      assign component ps_mod_cells-fieldname of structure ps_data to <lv_value>.
      check sy-subrc = 0.
      <lv_value> = ps_mod_cells-value.

    when 'LODAT'. "선적확정일

      if ps_mod_cells-value is not initial and ps_mod_cells-value > 1.
        perform check_changed_lodat using    ps_data
                                             ps_mod_cells
                                    changing lv_subrc.

        if lv_subrc is not initial.
          perform add_protocol_entry using po_data_changed
                                           'ZGTSD01' '000' space text-e01
                                           ps_mod_cells-fieldname
                                           ps_mod_cells-row_id.
          return.
        endif.
      endif.

      assign component ps_mod_cells-fieldname of structure ps_data to <lv_value>.
      check sy-subrc = 0.
      <lv_value> = ps_mod_cells-value.

    when others.
      assign component ps_mod_cells-fieldname of structure ps_data to <lv_value>.
      check sy-subrc = 0.
      <lv_value> = ps_mod_cells-value.
  endcase.

endform.
*&---------------------------------------------------------------------*
*& Form CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form check_changed_data using po_grid type ref to cl_gui_alv_grid
                              pv_ck.

  clear gv_error.
  check po_grid is bound.

  po_grid->check_changed_data( importing e_valid = data(lv_valid) ).

  if pv_ck = zgtsd_x and lv_valid is initial.
    gv_error = zgtsd_x. "오류 Flag
    message s029 display like zgtsd_e. "오류 내역이 존재합니다.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form UPDATE_STATU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form update_statu using po_data_changed type ref to
                            cl_alv_changed_data_protocol
                            ps_mod_cells type lvc_s_modi
                   changing pv_statu
                            pv_modi.

  pv_modi  = zgtsd_x.     "변경 Flag
  pv_statu = icon_change. "변경 Icon

  perform modify_cell using po_data_changed
                            ps_mod_cells-row_id
                            ps_mod_cells-tabix
                            'STATU'
                            pv_statu.

endform.
*&---------------------------------------------------------------------*
*& Form GET_CELL_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form get_cell_value using po_data_changed type ref to
                              cl_alv_changed_data_protocol
                              pv_row_id
                              pv_fieldname
                     changing pv_value.

  clear pv_value.
  po_data_changed->get_cell_value( exporting
                                     i_row_id    = pv_row_id
                                     i_fieldname = pv_fieldname
                                   importing
                                     e_value     = pv_value ).

endform.
*&---------------------------------------------------------------------*
*& Form ADD_PROTOCOL_ENTRY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form add_protocol_entry using po_data_changed type ref to
                                cl_alv_changed_data_protocol
                                pv_msgid
                                pv_msgno
                                pv_msgv1
                                pv_msgv2
                                pv_fieldname
                                pv_row_id.

  data : lt_data type table of lvc_s_msg1
                 with non-unique sorted key key_mode
                 components msgid msgno msgv1 msgv2 fieldname row_id.

  lt_data = po_data_changed->mt_protocol.  "기존 동일 오류 제외

  check not line_exists( lt_data[ key key_mode components msgid     = pv_msgid
                                                          msgno     = pv_msgno
                                                          msgv1     = pv_msgv1
                                                          msgv2     = pv_msgv2
                                                          fieldname = pv_fieldname
                                                          row_id    = pv_row_id ] ).

  po_data_changed->add_protocol_entry(
      exporting
        i_msgid     = pv_msgid
        i_msgno     = pv_msgno
        i_msgty     = zgtsd_e
        i_msgv1     = pv_msgv1
        i_msgv2     = pv_msgv2
        i_fieldname = pv_fieldname
        i_row_id    = pv_row_id ).

endform.
*&---------------------------------------------------------------------*
*& Form MODIFY_CELL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form modify_cell using po_data_changed type ref to
                         cl_alv_changed_data_protocol
                         pv_row_id
                         pv_tabix
                         pv_fieldname
                         pv_value.

  po_data_changed->modify_cell( i_row_id    = pv_row_id
                                i_tabix     = pv_tabix
                                i_fieldname = pv_fieldname
                                i_value     = pv_value ).

endform.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form handle_data_changed_finished using pv_modified
                                        pt_good_cells type lvc_t_modi
                                        po_sender.

  check pv_modified = zgtsd_x
    and po_sender   = go_grid
    and gt_chg is not initial.

*  변경사항 반영

  loop at pt_good_cells into data(ls_good_cells).

    read table gt_s0100 into gs_s0100 index ls_good_cells-row_id.
    check sy-subrc = 0.
    case ls_good_cells-fieldname.
      when 'HDSEL'.   "판매오더 선택
        gs_s0100-itsel = gs_s0100-hdsel.
        modify gt_s0100 from gs_s0100 transporting hdsel itsel where vbeln = gs_s0100-vbeln.

        perform set_color.

      when 'ITSEL'.
        perform set_color.

    endcase.

  endloop.

  "Refresh Grid
  perform refresh_table_display using po_sender space.

endform.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form handle_toolbar using po_object type ref to cl_alv_event_toolbar_set
                              po_sender.
  define _add_toolbar.
    ls_toolbar = VALUE #( function   = &1
                          icon       = &2
                          quickinfo  = &3
                          text       = &4
                          butn_type  = &5 ).

    CASE &6.
      WHEN 'A'. "Append
        APPEND ls_toolbar TO po_object->mt_toolbar.
      WHEN 'I'. "Insert
        INSERT ls_toolbar INTO po_object->mt_toolbar INDEX 1.
    ENDCASE.
  end-of-definition.

  data : ls_toolbar type stb_button.

  check gv_edit = zgtsd_x.     "수정가능 상태

**  case po_sender.
**    when go_grid. "Main
**      _add_toolbar space space space space  3 'A'.
**      _add_toolbar 'REF' icon_refresh text-f27 text-f27 0 'A'. "
**      _add_toolbar 'APPL' icon_change_text text-f26 text-f26 0 'A'. "
**      _add_toolbar space space space space  3 'A'.
**      _add_toolbar 'HIST' icon_history text-f21 text-f21 0 'A'. "
**      _add_toolbar 'PACK' icon_history text-f25 text-f25 0 'A'. "
**  endcase.
  case po_sender.
    when go_grid.  "Main
      _add_toolbar space      space              space              space              3 'A'.
      _add_toolbar 'REF'      icon_refresh       text-f27           text-f27           0 'A'.
      " 기존 'APPL' 제거 후 4개 버튼 추가
      _add_toolbar space      space              space              space              3 'A'.

      if rb_bt1 = 'X'.
        _add_toolbar 'APPL_PP'  icon_change_text   '일괄적용-생산'   '일괄적용-생산'   0 'A'.
      endif.
      if rb_bt2 = 'X'.
        _add_toolbar 'APPL_QM'  icon_change_text   '일괄적용-FAT'    '일괄적용-FAT'    0 'A'.
      endif.
      if rb_bt3 = 'X'.
        _add_toolbar 'APPL_LE'  icon_change_text   '일괄적용-출하'   '일괄적용-출하'   0 'A'.
      endif.
      if rb_bt4 = 'X'.
        _add_toolbar 'APPL_LO'  icon_change_text   '일괄적용-선적'   '일괄적용-선적'   0 'A'.
      endif.

      _add_toolbar space      space              space              space              3 'A'.
      _add_toolbar 'HIST'     icon_history       text-f21           text-f21           0 'A'.
      _add_toolbar 'PACK'     icon_history       text-f25           text-f25           0 'A'.
  endcase.

endform.
*&---------------------------------------------------------------------*
*& Form REFRESH_TABLE_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form refresh_table_display using po_grid type ref to cl_gui_alv_grid
                                  pv_soft_refresh.

  check po_grid is bound.

  call method po_grid->refresh_table_display
    exporting
      is_stable      = conv #( 'XX' )
      i_soft_refresh = pv_soft_refresh
    exceptions
      finished       = 1
      others         = 2.

endform.
*&---------------------------------------------------------------------*
*& Form HANDLE_ON_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form handle_on_f4 using pv_fieldname type lvc_fname
                            pv_fieldvalue  type lvc_value
                            ps_row_no      type lvc_s_roid
                            po_event_data  type ref to cl_alv_event_data
                            pv_display     type char01
                            po_sender.
  data : lv_value type lvc_value.
  field-symbols : <lt_data> type table.

*  CHECK PO_SENDER = GO_GRID. "Main
*
*  PO_EVENT_DATA->M_EVENT_HANDLED = ZPS01_X.
*
*  CASE PV_FIELDNAME.
*    WHEN ZPS01_FNAME-Z_IV_ANLKL.  "자산 클래스
*
*      PERFORM F4_CODE_MASTER USING    ZPS01_ROLLNAME-ZE_IV_ANLKL
*                                      ZPS01_CODE-PSAC02
*                                      PV_DISPLAY
*                             CHANGING LV_VALUE.
*
*    WHEN OTHERS.
*      RETURN.
*  ENDCASE.
*
*  CHECK LV_VALUE IS NOT INITIAL.
*
*  ASSIGN PO_EVENT_DATA->M_DATA->* TO <LT_DATA>.
*  CHECK SY-SUBRC = 0.
*
*  APPEND VALUE LVC_S_MODI( FIELDNAME = PV_FIELDNAME
*                           ROW_ID    = PS_ROW_NO-ROW_ID
*                           VALUE     = LV_VALUE ) TO <LT_DATA>.

endform.
*&---------------------------------------------------------------------*
*& Form FREE_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form free_object .
* Field Catalog
  clear: gt_fcat[].

* Grid Clear
  call method: go_grid->free.

  clear: go_grid.

* Container Clear
  call method: go_con->free,
               go_split->free,
               go_con_top->free.

  clear: go_con, go_split, go_con_top.
endform.
*&---------------------------------------------------------------------*
*& Form SAVE_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&---------------------------------------------------------------------*
form save_process.

  data : lv_subrc type sy-subrc,
         lv_err   type c,
         lt_tmp   like table of gs_s0100,
         lt_0010  type table of zgtsdt0010 with header line.

  clear gv_error.
  perform check_changed_data using go_grid zgtsd_x.
  check gv_error is initial.

  clear gs_s0100.
  modify gt_s0100 from gs_s0100 transporting sel where sel is not initial.

  loop at gt_s0100 into gs_s0100.

    if gs_s0100-ppdat is initial and gs_s0100-qmdat is initial and
       gs_s0100-ledat is initial and gs_s0100-lodat is initial.
*      MESSAGE S007 WITH TEXT-F24 DISPLAY LIKE 'E'.
      continue.
    endif.

    gs_s0100-sel = gc_x.
    append gs_s0100 to lt_tmp.
    modify gt_s0100 from gs_s0100.

  endloop.

  if lt_tmp[] is initial.
    message s015 display like zgtsd_e.exit.
  endif.

  clear gv_answer.
  gv_answer = zgtsd_cl_common=>popup_to_comfirm( iv_ucomm = space
                                                 iv_messa = text-m01 ).
  check gv_answer = zgtsd_j.

************************************************************************
*** 내용 저장
************************************************************************
  loop at lt_tmp into data(ls_tmp).

    move-corresponding ls_tmp to lt_0010.

    get time stamp field lt_0010-zckey.

    zgtsd_cl_common=>set_timestamp( exporting iv_gubun = zgtsd_c
                                     changing cs_timestamp = lt_0010-timestamp ).
    append lt_0010. clear lt_0010.

  endloop.

  if lt_0010[] is not initial.
    modify zgtsdt0010 from table lt_0010.
  endif.

  perform data_query using 'X'.
  perform set_color.
  message s011.
  perform refresh_table_display using go_grid space.

endform.
*&---------------------------------------------------------------------*
*& Form F4HELP_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_VARI
*&---------------------------------------------------------------------*
form f4help_layout   changing pv_layout like disvariant-variant.

  data : ls_variant    like disvariant,
         lt_dynpfields like dynpread occurs 0 with header line,
         lt_fcat       type lvc_t_fcat.

  ls_variant-report      = sy-cprog.
  ls_variant-handle      = '1'.
  ls_variant-log_group   = space.
  ls_variant-username    = space.
  ls_variant-variant     = pv_layout.
  ls_variant-text        = space.
  ls_variant-dependvars  = space.


  clear lt_dynpfields.
  lt_dynpfields-fieldname = 'P_LAYOUT'.
  append lt_dynpfields.

  read table lt_dynpfields with key fieldname = 'P_LAYOUT'.
  if sy-subrc eq 0.
    if not lt_dynpfields-fieldvalue(1) ca '0123456789/' and
       not lt_dynpfields-fieldvalue is initial.
      ls_variant-username = sy-uname.
    endif.
    ls_variant-variant = lt_dynpfields-fieldvalue.
  endif.

  call function 'LVC_VARIANT_SAVE_LOAD'
    exporting
      i_save_load = 'F'
      i_tabname   = '1'
    changing
      cs_variant  = ls_variant
      ct_fieldcat = lt_fcat[].

  pv_layout = ls_variant-variant.

endform.
*&---------------------------------------------------------------------*
*& Form SET_ALV_FLD_STYLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_S0100_CELLS
*&---------------------------------------------------------------------*
form set_alv_fld_style  using pt_cell type lvc_t_styl
                              pv_fld
                              pv_edit.

  data : lt_styl type lvc_t_styl,
         ls_styl type lvc_s_styl.

  ls_styl-fieldname = pv_fld.
  if pv_edit is not initial.
    ls_styl-style = cl_gui_alv_grid=>mc_style_enabled.
  else.
    ls_styl-style = cl_gui_alv_grid=>mc_style_disabled.
  endif.

  insert ls_styl into table pt_cell.

endform.
*&---------------------------------------------------------------------*
*& Form GET_YYMM_F4_SEARCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- S_SPMON_LOW
*&---------------------------------------------------------------------*
form get_yymm_f4_search  changing pv_yymm.

  if pv_yymm is initial.
    pv_yymm = sy-datum(6).
  endif.

  call function 'POPUP_TO_SELECT_MONTH'
    exporting
      actual_month               = pv_yymm
      language                   = sy-langu
    importing
      selected_month             = pv_yymm
    exceptions
      factory_calendar_not_found = 1
      holiday_calendar_not_found = 2
      month_not_found            = 3
      others                     = 4.
endform.
*&---------------------------------------------------------------------*
*& Form CHECK_KUNNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TEXT_S07
*&      --> P_KUNNR
*&      <-- P_NAME1
*&---------------------------------------------------------------------*
form check_kunnr  using   pv_ftext
                          pv_code
                 changing pv_text.

  data : lv_subrc type sysubrc.

  clear pv_text.
  check pv_code is not initial.

  select single name1 into @data(lv_name1) from kna1 where kunnr = @pv_code.
  check sy-subrc = 0.
  pv_text = lv_name1.
endform.
*&---------------------------------------------------------------------*
*& Form GET_HISTORY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_history .

  data : lv_subrc  type sy-subrc.

  data : begin of ls_join,
           vbeln type vbeln,
           posnr type posnr,
         end of ls_join,
         lt_join like table of ls_join with empty key.

  "Selected Rows
*  DATA(LT_ROWS) = ZGTSD_CL_COMMON=>GET_SELECTED_ROWS( EXPORTING
*                                                        IO_GRID = GO_GRID
*                                                        IV_CK   = ZGTSD_X
*                                                      IMPORTING
*                                                        EV_SUBRC = LV_SUBRC ).
*  CHECK LV_SUBRC IS INITIAL.
*  CLEAR GS_S0100.
*  MODIFY GT_S0100 FROM GS_S0100 TRANSPORTING SEL WHERE SEL IS NOT INITIAL.
*
*  LOOP AT LT_ROWS INTO DATA(LS_ROW).
*    CLEAR LS_JOIN.
*    READ TABLE GT_S0100 INTO GS_S0100 INDEX LS_ROW-INDEX.
*    CHECK SY-SUBRC = 0.
*    MOVE-CORRESPONDING GS_S0100 TO LS_JOIN.
*    APPEND LS_JOIN TO LT_JOIN. CLEAR LS_JOIN.
*  ENDLOOP.

  read table gt_s0100 into gs_s0100 with key itsel = 'X'.
  if sy-subrc ne 0.
    message s003 display like zgtsd_e.exit.
  endif.

  data(lt_tmp) = gt_s0100[].
  delete lt_tmp where itsel = space.
  lt_join[] = corresponding #( lt_tmp[] ).
  sort lt_join by vbeln posnr.
  delete adjacent duplicates from lt_join comparing vbeln posnr.

  with +adrp as ( select bname, b~name_text
                    from usr21 as a inner join adrp as b
                      on a~persnumber = b~persnumber )
  select b~*, c~name_text as name
    from @lt_join as a inner join zgtsdt0010 as b
      on a~vbeln = b~vbeln
     and a~posnr = b~posnr
    left outer join +adrp as c
      on c~bname = b~ernam
   order by b~zckey
    into corresponding fields of table @gt_s0200.

  sort gt_s0200 by vbeln posnr ppdat qmdat ledat lodat.
  delete adjacent duplicates from gt_s0200 comparing vbeln posnr ppdat qmdat ledat lodat.
  if gt_s0200[] is not initial.
    call screen 0200 starting at 10 01 ending at 120 20.
  else.
    message s010(zgtsd01)  display like zgtsd_e.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_attributes_0200 .

  "Layout 지정
  perform set_grid_layout2 using 'X' 'CELLS' zgtsd_d.

  "Field Catalog
  perform set_fieldcatalog2.

  "Toolbar 제외
  perform exclude_toolbar tables gt_toolbar2.

  "Event Handler 등록
  perform create_event_receiver using go_grid2.

*  "F4 필드 등록
*  PERFORM REGISTER_F4_FIELDS.

  "SORT
  perform set_alv_sort changing gt_sort2.

  "ALV Grid Display
  perform set_table_for_first_display2  using go_grid2
                                              gt_s0200[].

endform.
*&---------------------------------------------------------------------*
*& Form SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form set_grid_layout2 using pv_cwopt
                           pv_stylefname
                           pv_sel_mode.

  clear gs_layout2.
  gs_layout2 = value #( sel_mode   = pv_sel_mode
                       zebra      = zgtsd_x
                       cwidth_opt = pv_cwopt
*                       NO_ROWMARK = 'X'
                       stylefname = pv_stylefname ).

endform.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form set_fieldcatalog2 .

  "Get Field Catalog
  perform get_field_catalog using gt_s0200[] changing gt_fcat2.

  "Set Field Catalog
  perform set_fieldcatalog_0200.

endform.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_fieldcatalog_0200.


  sort gt_fcat2 by fieldname.

  perform reset_field_catalog tables gt_fcat2 using :

      'S' 'FIELDNAME' 'VBELN',
      ' ' 'COLTEXT'   '주문번호',
      ' ' 'OUTPUTLEN'   '10',
      ' ' 'COL_POS'     '2',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'POSNR',
      ' ' 'COLTEXT'   '주문품목',
      ' ' 'OUTPUTLEN'   '8',
      ' ' 'COL_POS'     '3',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME' 'PPDAT',
      ' ' 'COLTEXT'   text-f12,
      ' ' 'COL_POS'     '4',
      'E' 'KEY'         ' ',

      'S' 'FIELDNAME' 'QMDAT',
      ' ' 'COLTEXT'   text-f16,
      ' ' 'COL_POS'     '5',
      'E' 'KEY'         ' ',

      'S' 'FIELDNAME' 'LEDAT',
      ' ' 'COLTEXT'   text-f17,
      'E' 'COL_POS'     '7',

      'S' 'FIELDNAME' 'LODAT',
      ' ' 'COLTEXT'   text-f18,
      ' ' 'OUTPUTLEN'   '8',
      'E' 'COL_POS'     '8',

      'S' 'FIELDNAME' 'ERDAT',
      ' ' 'COLTEXT'   text-f20,
      ' ' 'OUTPUTLEN'   '10',
      'E' 'COL_POS'     '9',

*      'S' 'FIELDNAME' 'ERZEIT',
*      ' ' 'COLTEXT'   '납품품목',
*      ' ' 'OUTPUTLEN'   '8',
*      'E' 'COL_POS'     '10',

      'S' 'FIELDNAME' 'ERNAM',
      ' ' 'COLTEXT'   '등록자',
      ' ' 'OUTPUTLEN'   '18',
      'E' 'COL_POS'     '13',

      'S' 'FIELDNAME' 'NAME',
      ' ' 'COLTEXT'   '등록자명',
      ' ' 'OUTPUTLEN'   '25',
      'E' 'COL_POS'     '14'.

endform.
*&---------------------------------------------------------------------*
*& Form SET_TABLE_FOR_FIRST_DISPLAY2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID2
*&      --> GT_S0200[]
*&---------------------------------------------------------------------*
form set_table_for_first_display2  using po_sender type ref to cl_gui_alv_grid
                                         pt_data type table.
  data : lv_handl type slis_handl.

  "레이아웃 Variant 구분자
  perform set_variant_handle using po_sender changing lv_handl.

  delete gt_fcat2 where tech = zgtsd_x. "불필요한 필드 제외

  "Formatted Output Table is Sent to Control
  call method po_sender->set_table_for_first_display
    exporting
      is_layout            = gs_layout2
      is_variant           = value #( report = sy-repid
                                      handle = lv_handl )
      i_save               = zgtsd_a
      it_toolbar_excluding = gt_toolbar
    changing
      it_fieldcatalog      = gt_fcat2
      it_sort              = gt_sort2[]
      it_outtab            = pt_data[].

endform.
*&---------------------------------------------------------------------*
*& Form CALL_URL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form call_url using pv_url.

  call function 'CALL_BROWSER'
    exporting
      url                    = pv_url
      window_name            = 'Shipping Mark 양식조회'
    exceptions
      frontend_not_supported = 1
      frontend_error         = 2
      prog_not_found         = 3
      no_batch               = 4
      unspecified_error      = 5
      others                 = 6.

endform.
*&---------------------------------------------------------------------*
*& Form GET_PACKING_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_packing_list .

  data : lv_subrc  type sy-subrc.

  data lt_tmp like table of gs_s0100.
*  "Selected Rows
*  DATA(LT_ROWS) = ZGTSD_CL_COMMON=>GET_SELECTED_ROWS( EXPORTING
*                                                        IO_GRID = GO_GRID
*                                                        IV_CK   = ZGTSD_X
*                                                      IMPORTING
*                                                        EV_SUBRC = LV_SUBRC ).
*  CHECK LV_SUBRC IS INITIAL.
*  CLEAR GS_S0100.
*  MODIFY GT_S0100 FROM GS_S0100 TRANSPORTING SEL WHERE SEL IS NOT INITIAL.

  read table gt_s0100 into gs_s0100 with key itsel = 'X'.
  if sy-subrc ne 0.
    message s003 display like zgtsd_e.exit.
  endif.

  lt_tmp[] = gt_s0100[].
  delete lt_tmp where itsel = space.

  sort lt_tmp by vbeln.
  delete adjacent duplicates from lt_tmp comparing vbeln.
  if lines( lt_tmp ) ne 1.
    message s002 display like zgtsd_e.exit.
  endif.

  read table lt_tmp into data(ls_tmp) index 1.
  check sy-subrc = 0.
  select single vbeln, spart into @data(ls_vb) from vbak where vbeln = @ls_tmp-vbeln.
  submit zgtsdr0050 with p_vbeln = ls_vb-vbeln
                    with p_spart = ls_vb-spart and return.

endform.
*&---------------------------------------------------------------------*
*& Form SET_COLOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_color .

  data : lt_color type lvc_t_scol.

  loop at gt_s0100 into gs_s0100.
    __cle : lt_color, gs_s0100-cellc.
    perform fill_color  changing lt_color.
    insert lines of lt_color into table gs_s0100-cellc.
    modify gt_s0100 from gs_s0100.
  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form FILL_COLOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_COLOR
*&---------------------------------------------------------------------*
form fill_color  changing pt_color.

  data: ls_color   type lvc_s_scol.

  loop at gt_fcat into gs_fcat.

    ls_color-fname = gs_fcat-fieldname.

    if  gs_fcat-key = 'X'.
      if ls_color-fname <> 'HDSEL' and ls_color-fname <> 'ITSEL'.
        ls_color-color-col = 4.
        ls_color-color-int = 1.
        insert ls_color into table pt_color.
      endif.
    else.
      if gs_fcat-edit is initial.
        if gs_s0100-itsel = 'X'.
          ls_color-color-col = 7.
          ls_color-color-int = 0.
        else.
          ls_color-color-col = 2.
          ls_color-color-int = 0.
        endif.

        insert ls_color into table pt_color.

      endif.

    endif.
  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form ALL_APPLY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form all_apply .

  read table gt_s0100 into gs_s0100 with key itsel = 'X'.
  if sy-subrc ne 0.
    message s003 display like zgtsd_e.exit.
  endif.

  clear gs_s0101.
  gs_s0101-date = sy-datlo.

**  case zgtsd_x.
**    when rb_bt1.
**      gs_s0101-text = text-f12.
**    when rb_bt2.
**      gs_s0101-text = text-f16.
**    when rb_bt3.
**      gs_s0101-text = text-f17.
**    when rb_bt4.
**      gs_s0101-text = text-f18.
**  endcase.

  case gv_apply_mode.
    when 'PP'. gs_s0101-text = '확정(생산완료일)'.
    when 'QM'. gs_s0101-text = 'FAT'.
    when 'LE'. gs_s0101-text = '출하일'.
    when 'LO'. gs_s0101-text = '선적확정일'.
    when others.
      gv_apply_mode = 'PP'. gs_s0101-text = '확정(생산완료일)'.
  endcase.

  call screen 0101 starting at 60 1 ending at 108 4.

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

  ranges : lr_kunag for kna1-kunnr.

  data : begin of lt_021 occurs 0.
           include structure zsdt_d365_021.
  data :   zptxt  type zsd0106t-zptxt,
           erdat  type erdat,
           name1  type kna1-name1,
           kwmeng type vbap-kwmeng,
           vtext  type tspat-vtext,
           bezei  type tvkbt-bezei,   "영업팀명
           name   type zgtmm_cv_getusername-name ,   "영업사원명
         end of lt_021.

  data : lv_type   type zsdt_d365_020-cycltype.

  if p_kunnr is not initial.
    __rng : lr_kunag 'I' 'EQ' p_kunnr ''.
  endif.

  case zgtsd_x.
    when rb_mbt3.
      lv_type = zgtsd_m.
    when rb_mbt4.
      lv_type = zgtsd_w.
  endcase.

*  SELECT ZSDT_D365_020~* INTO TABLE @DATA(LT_HEAD)
*    FROM ZSDT_D365_020
*   WHERE PLTYPE    = 'SP'
*     AND CYCLTYPE  = @LV_TYPE
*     AND VKBUR    IN @S_VKBUR
*     AND WEEK = ( SELECT MAX( WEEK )
*                    FROM ZSDT_D365_020
*                   WHERE CYCLTYPE = @LV_TYPE
*                     AND VKBUR    IN @S_VKBUR
*                     AND PLTYPE   = 'SP' ).
  select zsdt_d365_020~* into table @data(lt_head)
    from zsdt_d365_020
   where pltype    = 'SP'
     and cycltype  = @lv_type
     and vkbur    in @s_vkbur.
  sort lt_head by pltype cycltype vkbur week descending.
  delete adjacent duplicates from lt_head comparing pltype cycltype vkbur.


  select b~*, a~erdat, d~kwmeng, e~name1, f~bezei, name,
         j~vtext
    from @lt_head as a inner join zsdt_d365_021 as b
      on a~pltype   = b~pltype
     and a~cycltype = b~cycltype
     and a~vkbur    = b~vkbur
     and a~week     = b~week
*    LEFT OUTER JOIN ZSD0106T AS C
*      ON C~ZPJNO = B~ZPJNO
    left outer join vbap as d
      on b~vbeln = d~vbeln
     and b~posnr = d~posnr
    left outer join kna1 as e
      on e~kunnr = b~kunnr
    left outer join tvkbt as f
      on b~vkbur = f~vkbur
     and f~spras = @sy-langu
    left outer join zgtmm_cv_getusername as g
      on b~pernr = g~userid
    left outer join tspat as j
      on b~spart = j~spart
     and j~spras = @sy-langu
   where b~sotype = 'SO'
     "AND B~DPTYPE = @TEXT-F01  '26-01-12 kch요청
     and b~vbeln in @s_vbeln
     and b~vkbur in @s_vkbur
     and b~zpjno in @s_zpjno
     and b~kunnr in @lr_kunag
     and b~matnr in @s_matnr
     and b~spart in @s_spart
     and b~basemonth in @s_spmon
    into corresponding fields of table @lt_021.

  data(lt_for) = lt_021[].
  sort lt_for by vbeln posnr.
  delete adjacent duplicates from lt_for comparing vbeln posnr.
  delete lt_for where vbeln is initial.
  if lt_for[] is not initial.
    select b~vbeln, b~posnr, etenr, edatu
      from @lt_for as a inner join vbep as b
        on a~vbeln = b~vbeln
       and a~posnr = b~posnr
      into table @data(lt_vbed).
  endif.

  sort lt_vbed by vbeln posnr ascending etenr descending.
  delete adjacent duplicates from lt_vbed comparing vbeln posnr.
  sort lt_vbed by vbeln posnr.

  gt_s0100[] = corresponding #( lt_021[] ).
  loop at gt_s0100 into gs_s0100.
    read table lt_vbed into data(ls_vb) with key vbeln = gs_s0100-vbeln
                                                 posnr = gs_s0100-posnr binary search.
    if sy-subrc = 0.
      gs_s0100-edatu = ls_vb-edatu.
    endif.
    modify gt_s0100 from gs_s0100.
  endloop.
endform.
*&---------------------------------------------------------------------*
*& Form GET_OPEN_SO_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_open_so_data .

  ranges : lr_kunnr for kna1-kunnr,
           lr_edatu for vbep-edatu.

  data : begin of ls_so,
           vbeln  type vbeln_va,
           posnr  type posnr_va,
           etenr  type etenr,
           kwmeng type kwmeng,
           netwr  type netwr,
           edatu  type edatu,
         end of ls_so,
         lt_so  like table of ls_so with empty key,
         lv_sdt type sy-datlo,
         lv_edt type sy-datlo.

  loop at s_spmon.
    clear : lv_sdt, lv_edt.
    concatenate s_spmon-low(6) '01' into lv_sdt.
    call function 'RP_LAST_DAY_OF_MONTHS'
      exporting
        day_in            = lv_sdt
      importing
        last_day_of_month = lv_edt
      exceptions
        day_in_no_date    = 1
        others            = 2.
    append value #( sign = 'I' option = 'BT' low = lv_sdt high = lv_edt ) to lr_edatu.
  endloop.

  if p_kunnr is not initial.
    __rng lr_kunnr 'I' 'EQ' p_kunnr ''.
  endif.

  select distinct kunnr, vkorg, vtweg, spart
    from knvv
   where kunnr in @lr_kunnr
     and vkbur in @s_vkbur
     and spart in @s_spart
    into table @data(lt_kunnr).

*Open SO 조회
  select b~vbeln, b~posnr, d~etenr, b~kwmeng, b~netwr, d~edatu
    from vbak as a inner join vbap as b
      on a~vbeln = b~vbeln
   inner join vbep as d
      on b~vbeln = d~vbeln
     and b~posnr = d~posnr
   inner join @lt_kunnr as c
      on b~vkorg_ana = c~vkorg
     and b~vtweg_ana = c~vtweg
     and b~spart_ana = c~spart
     and b~kunnr_ana = c~kunnr
   where b~augru_ana <> '150'  " 선수금 오더 제외
     and b~spart not in ( '33','36' )  "시공 제외
     and b~matnr in @s_matnr
     and a~spart in @s_spart
     and a~vbeln in @s_vbeln
     and a~vkbur in @s_vkbur
     and a~zpjno in @s_zpjno
     and a~erdat in @s_edatu
     and d~edatu in @lr_edatu
*     AND B~LFSTA NE 'C'
     and b~auart_ana in ( 'TA','ZEXE','Z3RD','ZBC2' )
     and b~abgru in  ('', '94','95','96','Z1','Z2' )
    into corresponding fields of table @lt_so.

  sort lt_so by vbeln posnr ascending etenr descending.
  delete adjacent duplicates from lt_so comparing vbeln posnr.
  if lt_so[] is not initial.

* 납품 완료되지 않은 판매오더 Item 조회
    select a~vbeln, b~posnr, a~kunnr, a~vkbur, a~zpjno,
           b~matnr, i~maktx as itemname, b~kwmeng, b~vrkme,
           a~erdat, g~name1, f~bezei, h~name, d~edatu, a~spart, vtext
      from @lt_so as so inner join vbak as a
        on so~vbeln = a~vbeln
     inner join vbap as b
        on so~vbeln = b~vbeln
       and so~posnr = b~posnr
     inner join vbep as d
        on so~vbeln = d~vbeln
       and so~posnr = d~posnr
       and so~etenr = d~etenr
      left outer join tvkbt as f
        on a~vkbur = f~vkbur
       and f~spras = @sy-langu
      left outer join kna1 as g
        on a~kunnr = g~kunnr
      left outer join zgtmm_cv_getusername as h
        on a~ernam = h~userid
      left outer join makt as i
        on b~matnr = i~matnr
       and i~spras = @sy-langu
      left outer join tspat as j
        on a~spart = j~spart
       and j~spras = @sy-langu

      into table @data(lt_data).

* Open 판매오더 아이템 기준으로 출고되지 않은 수량 조회
    with +do as ( select vgbel, vgpos, wadat, etenr, sum( lfimg ) as kwmeng
                    from @lt_so as c inner join lips as b
                      on b~vgbel = c~vbeln
                     and b~vgpos = c~posnr
                   inner join likp as a
                      on a~vbeln eq b~vbeln
                   where a~kunag eq @p_kunnr
                     and b~wbsta ne 'C'
                     and b~lfimg > 0
                   group by vgbel, vgpos, wadat, etenr )

         select a~vbeln, b~posnr, a~kunnr, a~vkbur, a~zpjno,
                b~matnr, i~maktx as itemname, b~kwmeng, b~vrkme,
                a~erdat, g~name1, f~bezei, h~name, a~spart, vtext, d~edatu
           from +do as do inner join vbap as b
             on do~vgbel = b~vbeln
            and do~vgpos = b~posnr
          inner join vbak as a
             on b~vbeln = a~vbeln
          inner join vbep as d
             on do~vgbel = d~vbeln
            and do~vgpos = d~posnr
            and do~etenr = d~etenr
           left outer join tvkbt as f
             on a~vkbur = f~vkbur
            and f~spras = @sy-langu
           left outer join kna1 as g
             on a~kunnr = g~kunnr
           left outer join zgtmm_cv_getusername as h
             on a~ernam = h~userid
           left outer join makt as i
             on b~matnr = i~matnr
            and i~spras = @sy-langu
           left outer join tspat as j
             on a~spart = j~spart
            and j~spras = @sy-langu
     appending corresponding fields of table @lt_data.

  endif.

  delete lt_data where kwmeng <= 0.  "

  gt_s0100[] = corresponding #( lt_data[] ).

endform.
*&---------------------------------------------------------------------*
*& Form CHECK_MULT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form check_multi_data .

  clear : gv_error.

  loop at gt_s0100 into gs_s0100 where itsel = 'X'.
    data(lv_bad) = space.

    case gv_apply_mode.
      when 'PP'. gs_s0100-ppdat = gs_s0101-date.
      when 'QM'. gs_s0100-qmdat = gs_s0101-date.
      when 'LE'. gs_s0100-ledat = gs_s0101-date.
      when 'LO'. gs_s0100-lodat = gs_s0101-date.
    endcase.

    " 1) PPDAT <= LEDAT <= LODAT  (존재 시에만)
    perform local_cmp using gs_s0100-ppdat '<=' gs_s0100-ledat changing lv_bad.
    perform local_cmp using gs_s0100-ledat '<=' gs_s0100-lodat changing lv_bad.

    " 2) QMDAT <= LEDAT <= LODAT  (존재 시에만)
    perform local_cmp using gs_s0100-qmdat '<=' gs_s0100-ledat changing lv_bad.
    perform local_cmp using gs_s0100-ledat '<=' gs_s0100-lodat changing lv_bad.

    if lv_bad = 'X'.
      gv_error = 'X'. exit.
    endif.

  endloop.


  if gv_error is not initial.
    message s000 with text-e01 display like zgtsd_e.
  endif.

endform.
*&---------------------------------------------------------------------*
" 로컬 헬퍼: 존재하는(>1) 날짜만 비교
*&---------------------------------------------------------------------*
form local_cmp using    pv_left  type d
                    pv_op    type c
                    pv_right type d
             changing pv_bad  type c.

  check pv_bad is initial.
  check pv_left  > 1 and pv_right > 1.

  case pv_op.
    when '<='.
      if pv_left > pv_right. pv_bad = 'X'. endif.
    when '<'.
      if pv_left >= pv_right. pv_bad = 'X'. endif.
    when '>' .
      if pv_left <= pv_right. pv_bad = 'X'. endif.
    when '>='.
      if pv_left < pv_right. pv_bad = 'X'. endif.
  endcase.

endform.

*&---------------------------------------------------------------------*
*& Form CHECK_CHANGED_QMDAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_DATA
*&      --> PS_MOD_CELLS
*&      <-- LV_SUBRC
*&---------------------------------------------------------------------*
form check_changed_qmdat  using    ps_data structure gs_s0100
                                   ps_mod_cells type lvc_s_modi
                          changing pv_subrc.

*  if ps_data-ppdat > 1 and ps_mod_cells-value < ps_data-ppdat.
*    pv_subrc = 4.
*  endif.

  if ps_data-ledat > 1.
    if ps_mod_cells-value > ps_data-ledat.
      pv_subrc = 4.
    endif.
  else.
    if ps_data-lodat > 1.
      if ps_mod_cells-value > ps_data-lodat.
        pv_subrc = 4.
      endif.
    endif.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form CHECK_CHANGED_PPDAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_DATA
*&      --> PS_MOD_CELLS
*&      <-- LV_SUBRC
*&---------------------------------------------------------------------*
form check_changed_ppdat  using    ps_data structure gs_s0100
                                   ps_mod_cells type lvc_s_modi
                          changing pv_subrc.

*  if ps_data-qmdat > 1.
*    if ps_mod_cells-value > ps_data-qmdat.
*      pv_subrc = 4.
*    endif.
*  else.

    if ps_data-ledat > 1.
      if ps_mod_cells-value > ps_data-ledat.
        pv_subrc = 4.
      endif.
    else.

      if ps_data-lodat > 1.
        if ps_mod_cells-value > ps_data-lodat.
          pv_subrc = 4.
        endif.
      endif.

    endif.

*  endif.
endform.
*&---------------------------------------------------------------------*
*& Form CHECK_CHANGED_LEDAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_DATA
*&      --> PS_MOD_CELLS
*&      <-- LV_SUBRC
*&---------------------------------------------------------------------*
form check_changed_ledat  using    ps_data structure gs_s0100
                                   ps_mod_cells type lvc_s_modi
                          changing pv_subrc.


  if ps_data-qmdat > 1 and ps_mod_cells-value < ps_data-qmdat.
    pv_subrc = 4.
  endif.

  if ps_data-ppdat > 1 and ps_mod_cells-value < ps_data-ppdat.
    pv_subrc = 4.
  endif.

  if ps_data-lodat > 1.
    if ps_mod_cells-value > ps_data-lodat.
      pv_subrc = 4.
    endif.
  endif.


endform.
*&---------------------------------------------------------------------*
*& Form CHECK_CHANGED_LODAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_DATA
*&      --> PS_MOD_CELLS
*&      <-- LV_SUBRC
*&---------------------------------------------------------------------*
form check_changed_lodat  using    ps_data structure gs_s0100
                                   ps_mod_cells type lvc_s_modi
                          changing pv_subrc.

  if ps_data-ledat > 1 and ps_mod_cells-value < ps_data-ledat.
    pv_subrc = 4.
  endif.

  if ps_data-qmdat > 1 and ps_mod_cells-value < ps_data-qmdat.
    pv_subrc = 4.
  endif.

  if ps_data-ppdat > 1 and ps_mod_cells-value < ps_data-ppdat.
    pv_subrc = 4.
  endif.


endform.
