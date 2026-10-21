*&---------------------------------------------------------------------*
*& Include          ZGTSDR1320F01
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
  g_repid = sy-repid.
  g_save = 'A'.   "The user may save all types of a layout

*-납품요청일
  perform set_default_date.


endform.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form selection_screen_output .
** Layout관련
  if  default  =  ' '.

    clear def_layout.
    move  g_repid   to  def_layout-report.

    call function 'LVC_VARIANT_DEFAULT_GET'
      exporting
        i_save     = g_save
      changing
        cs_variant = def_layout
      exceptions
        not_found  = 2.

    if  sy-subrc  =  2.
      if  not p_vari is initial.
        message s001 with '레이아웃 기본세팅이 없습니다.'.
      endif.
    else.
      p_vari  =  def_layout-variant.
      default  =  'X'.
    endif.

  endif.

  loop at screen.
    if screen-group1 eq 'ZM1'.
      screen-active = 0.
    endif.
    modify screen.
  endloop.



endform.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form selection_screen .

  case sy-ucomm.
    when 'UCOMM'.
      perform set_date_range.
  endcase.

**  perform  authority_check.

** Layout 입력안했을때 Default(기본) Layout Display.
  clear gs_variant.

  "레이아웃 Variant 구분자
  if  p_vari is not initial.

    move p_vari   to gs_variant-variant.
    move sy-cprog to gs_variant-report.
    move '1'      to gs_variant-handle.

    call function 'LVC_VARIANT_EXISTENCE_CHECK'
      exporting
        i_save        = 'A'
      changing
        cs_variant    = gs_variant
      exceptions
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        others        = 4.

    if  sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.


endform.
*---------------------------------------------------------------------*
*      Form  USER COMMAND
*---------------------------------------------------------------------*
*      USER COMMAND 정의.
*---------------------------------------------------------------------*
form  user_command using p_ucomm    like sy-ucomm
                         p_selfield type slis_selfield.

  case p_ucomm.

    when '&IC1'.

**      case p_selfield-sel_tab_field.
**
**        when 'G_ITAB_T-VBELN'.
**          perform call_va03 using  p_selfield-value.
**
**        when 'G_ITAB_T-VBELN_VL'.
**          perform call_vl03n using  p_selfield-value.
**
**        when 'G_ITAB_T-TKNUM'.
**          perform call_vt03n using  p_selfield-value.
**
**        when 'G_ITAB_T-TKNUM_SEA'.
**          perform call_vt03n using  p_selfield-value.
**
**        when 'G_ITAB_T-VBELN_GI'.
**          perform call_mb03 using  p_selfield-value.
**
**        when 'G_ITAB_T-VBELN_VF'.
**          perform call_vf03 using  p_selfield-value.
**
**        when 'G_ITAB_T-FKNUM'.
**          perform call_vi03 using  p_selfield-value.
**
**      endcase.

**    when 'VA02'.
**      perform  call_va02.

    when 'EXI' or 'CAC' or 'BAC'.
      set screen 0. leave screen.

  endcase.

endform.                    "user_command

*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*       권한(ROLL) CHECK
*----------------------------------------------------------------------*
form authority_check.

  data: gt_tvtw  like tvtw occurs 0 with header line,
        gt_tspa  like tspa occurs 0 with header line,
        lv_subrc like sy-subrc.

  clear : lv_subrc.

  call function 'ZGTSD_AUTHORIZATION_CHECK'
    exporting
      i_vkorg = pa_vkorg
      i_type  = '1'
    importing
      e_subrc = lv_subrc.

  if lv_subrc <> 0.
    message e002 with '영업조직에 대한 권한이 없읍니다'
                      pa_vkorg.
  endif.

  select *
    into table gt_tvtw
    from tvtw
   where vtweg in so_vtweg.

  loop  at  gt_tvtw.
    call function 'ZGTSD_AUTHORIZATION_CHECK'
      exporting
        i_vtweg = gt_tvtw-vtweg
        i_type  = '2'
      importing
        e_subrc = lv_subrc.

    if lv_subrc <> 0.
      message e002 with '유통채널에 대한 권한이 없읍니다'
                        gt_tvtw-vtweg.
    endif.
  endloop.

  select *
    into table gt_tspa
    from tspa
   where spart in so_spart.

  loop  at  gt_tspa.
    clear : lv_subrc.
    call function 'ZGTSD_AUTHORIZATION_CHECK'
      exporting
        i_spart = gt_tspa-spart
        i_type  = '3'
      importing
        e_subrc = lv_subrc.

    if lv_subrc <> 0.
      message e002 with '제품군에 대한 권한이 없읍니다'
                        gt_tspa-spart.
    endif.
  endloop.

*-영업그룹
  select vkgrp
    from tvkgr
   where vkgrp in @so_vkgrp
    into table @data(lt_vkgrp).
  if sy-subrc ne 0.
    message s001 with text-m01 display like gc_e.
    leave list-processing.
  endif.

  loop at lt_vkgrp into data(ls_vkgrp).
    clear lv_subrc.
    call function 'ZGTSD_AUTHORIZATION_CHECK'
      exporting
        i_vkgrp = ls_vkgrp-vkgrp
        i_type  = '7'
      importing
        e_subrc = lv_subrc.
    if lv_subrc ne 0.
      message s023(zgtsd01) with ls_vkgrp-vkgrp display like gc_e.
      leave list-processing.
    endif.
  endloop.
endform.                    " AUTHORITY_CHECK

*---------------------------------------------------------------------*
*      Form  TOP_OF_PAGE
*---------------------------------------------------------------------*
*      TOP의 로그 부분 SETTING.
*---------------------------------------------------------------------*
form top_of_page.

  call function 'REUSE_ALV_COMMENTARY_WRITE'
    exporting
      i_logo             = ' '
      it_list_commentary = g_list_top_of_page_t.

endform.                    "top_of_page
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS_SET
*&---------------------------------------------------------------------*
*       text : PF-STATUS 정해주는 로직.
*----------------------------------------------------------------------*
form pf_status_set using p_rt_extab type slis_t_extab.

  set pf-status '1000'.          "EXCLUDING RT_EXTAB.
  set titlebar  '1000'.

endform.                    " PF_STATUS_SET
*&---------------------------------------------------------------------*
*&      Form  BL_SELECT_RTN
*&---------------------------------------------------------------------*
*       BILLING 번호 SELECT
*----------------------------------------------------------------------*
form bl_select_rtn.

*  if g_itso_t-auart = 'ZRE'  or g_itso_t-auart = 'ZREQ' or
*     g_itso_t-auart = 'ZKR'  or g_itso_t-auart = 'ZKR1' or
*     g_itso_t-auart = 'ZKR2' or g_itso_t-auart = 'ZEKR'.
  if g_itso_t-auart = 'RE' or g_itso_t-auart = 'ZREQ'.

    select  single max( vbeln )  as vbeln_vf   "빌링번호
      into  corresponding fields of g_itdl_t
      from  vbfa
     where  vbelv      =   g_itdl_t-vbeln_vl
       and  posnv      =   g_itdl_t-posnr_vl
       and  vbtyp_n    =   'O'.

  else.

    select  single max( vbeln )  as vbeln_vf   "빌링번호
      into  corresponding fields of g_itdl_t
      from  vbfa
     where  vbelv      =   g_itdl_t-vbeln_vl
       and  posnv      =   g_itdl_t-posnr_vl
       and  vbtyp_n    =   'M'.

  endif.

  select  single fkdat
    into  g_itdl_t-fkdat
    from  vbrk
   where  vbeln  =  g_itdl_t-vbeln_vf.

endform.                    " BL_SELECT_RTN

*&---------------------------------------------------------------------*
*& Form HANDLE_DBL_CLICK
*&---------------------------------------------------------------------*
*& ALV 그리드 더블클릭 이벤트 처리
*&---------------------------------------------------------------------*
form handle_dbl_click using ps_row    type lvc_s_row
                            ps_column type lvc_s_col.

  check ps_row-index > 0.

  read table gt_list assigning field-symbol(<ls_list>) index ps_row-index.
  check sy-subrc = 0.

  case ps_column-fieldname.
    when 'VBELN'.
      if <ls_list>-vbeln is not initial.
        perform call_va03 using <ls_list>-vbeln.
      endif.
  endcase.

endform.
*&---------------------------------------------------------------------*
*&      Form  CALL_VA03
*&---------------------------------------------------------------------*
*       오더 상세조회
*----------------------------------------------------------------------*
form call_va03 using    p_value.

* PARAMETER SETTING
  set parameter id: 'AUN'    field   p_value.

*   CALL TRANSACTION
  call   transaction  'VA03' and skip first screen.
  commit work and wait.

endform.                                                    " CALL_VA03

*&---------------------------------------------------------------------*
*&      Form  CALL_VL03N
*&---------------------------------------------------------------------*
*       DELIVERY 조회
*----------------------------------------------------------------------*
form call_vl03n using    p_value.

  check p_value ne space.

* PARAMETER SETTING
  set parameter id: 'VL'    field   p_value.

* CALL TRANSACTION
  call   transaction  'VL03N' and skip first screen.
  commit work and wait.

endform.                    " CALL_VL03N
*&---------------------------------------------------------------------*
*&      Form  CALL_VT03N
*&---------------------------------------------------------------------*
*       SHIPMENT 상세조회
*----------------------------------------------------------------------*
form call_vt03n using    p_value.

  check p_value ne space.

* PARAMETER SETTING
  set parameter id: 'TNR'    field   p_value.

* CALL TRANSACTION
  call   transaction  'VT03N' and skip first screen.
  commit work and wait.

endform.                    " CALL_VT03N
*&---------------------------------------------------------------------*
*&      Form  CALL_MB03
*&---------------------------------------------------------------------*
*       출고전기 상세조회
*----------------------------------------------------------------------*
form call_mb03 using    p_value.

  check p_value ne space.
*-> CCM : 12.04.2023 09:22:43 ZLSGSD5 - MB03 Function으로 변경
** PARAMETER SETTING
*  SET PARAMETER ID: 'MBN'    FIELD   P_VALUE.
*
** CALL TRANSACTION
*  CALL   TRANSACTION  'MB03' AND SKIP FIRST SCREEN.
*  COMMIT WORK AND WAIT.
  data : lv_mblnr type mblnr.
  lv_mblnr = p_value.

  call function 'MIGO_DIALOG'
    exporting
      i_action            = 'A04'
      i_refdoc            = 'R02'
      i_notree            = 'X'
      i_skip_first_screen = 'X'
      i_deadend           = 'X'
      i_okcode            = 'OK_GO'
      i_new_rollarea      = 'X'
      i_mblnr             = lv_mblnr
*     i_mjahr             = lv_mjahr
    exceptions
      illegal_combination = 1
      others              = 2.
*<-

endform.                                                    " CALL_MB03
*&---------------------------------------------------------------------*
*&      Form  CALL_VF03
*&---------------------------------------------------------------------*
*       BILLING 상세 조회
*----------------------------------------------------------------------*
form call_vf03 using    p_value.

  check p_value ne space.

* PARAMETER SETTING
  set parameter id: 'VF'    field   p_value.

* CALL TRANSACTION
  call   transaction  'VF03' and skip first screen.
  commit work and wait.

endform.                                                    " CALL_VF03

*&---------------------------------------------------------------------*
*&      Form  value_request_vari
*&---------------------------------------------------------------------*
form value_request_vari changing pv_layout like disvariant-variant.

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

endform.                    " value_request_vari

*&---------------------------------------------------------------------*
*&      Form  F4_FOR_SPART
*&---------------------------------------------------------------------*
*       제품군 POSSIBLE ENTRY
*----------------------------------------------------------------------*
form f4_for_spart.
* 현재 화면에 들어와 있는 영업조직 읽어드림.
  call function 'DYNP_VALUES_READ'
    exporting
      dyname               = 'ZSDR0200'
      dynumb               = pa_vkorg
    tables
      dynpfields           = g_dynpfields_t
    exceptions
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      others               = 11.

  read table g_dynpfields_t with key fieldname = 'PA_VKORG'.

  if sy-subrc = 0.
    pa_vkorg = g_dynpfields_t-fieldvalue.
  else.
    message e038.
  endif.


*FILL INTERNAL TABLE FOR POSSIBLE ENTRY
  select  distinct a~spart                  " 유통경로
                   b~vtext                  " 유통경로 TEXT
     from  tvta as a
    inner join  tspat as b
       on  a~spart = b~spart
     into  corresponding fields of table g_values2_t
    where a~vkorg = pa_vkorg
      and a~vtweg like '%'
      and b~spras = sy-langu.

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = 'SPART'
      dynpprog        = 'ZSDR0200'
      dynpnr          = pa_vkorg
      dynprofield     = 'PA_SPART'
      window_title    = '제품군'
      value_org       = 'S'
    tables
      value_tab       = g_values2_t
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.

  if sy-subrc <> 0.

    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  endif.

endform.                    " F4_FOR_SPART
*&---------------------------------------------------------------------*
*&      Form  SCREEN_MODIFY
*&---------------------------------------------------------------------*
form screen_modify.

*  LOOP AT SCREEN.
*
*    IF  SCREEN-GROUP1 = 'A'.
*        SCREEN-INPUT = 0.
*        SCREEN-INTENSIFIED = 1.
*    ENDIF.
*
*    MODIFY SCREEN.
*
*  ENDLOOP.

endform.                    " SCREEN_MODIFY


*&---------------------------------------------------------------------*
*&      Form  progress_indicator
*&---------------------------------------------------------------------*
form progress_indicator .

  g_msg(3)  =  g_ratio.
  g_msg+4  =  '%'.
  g_msg+7(20)  =  ' Data Loading....'.

  call function 'SAPGUI_PROGRESS_INDICATOR'
    exporting
      percentage = g_ratio
      text       = g_msg
    exceptions
      others     = 1.

endform.                    " progress_indicator


*&---------------------------------------------------------------------*
*&      Form  call_va02
*&---------------------------------------------------------------------*
form call_va02 .

  data : l_cnt type i.

  loop at g_itab_t where mark = 'X'.
    l_cnt  =  l_cnt  +  1.
  endloop.

  if  l_cnt  <  1  or
      l_cnt  >  1.
    message e001 with '하나의 Record를 선택하세요.'.
  endif.

  read table g_itab_t with key mark = 'X'.

* PARAMETER SETTING
  set parameter id: 'AUN'    field   g_itab_t-vbeln.

*   CALL TRANSACTION
  call   transaction  'VA02' and skip first screen.
  commit work and wait.

endform.                                                    " call_va02
*&---------------------------------------------------------------------*
*&      Form  value_request_auart
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form value_request_auart  using    value(p_auart).

*... F4 search help for order type
  data: begin of lt_value occurs 1,
          auart like tvak-auart,           "Order type
          bezei like tvakt-bezei,          "Order type description
        end of lt_value.

*... custmizing table ZSDT0900
*    being able to custmize at t-code 'ZSD1V4001'

  select zsdt0900~auart tvakt~bezei
        into corresponding fields of table lt_value
        from zsdt0900 inner join tvakt on zsdt0900~auart = tvakt~auart
        where zsdt0900~pgm_name = 'ZSD1R0020'
          and tvakt~spras = sy-langu.

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield    = 'AUART'
      dynpprog    = 'ZSDR0200'
      dynpnr      = pa_vkorg
      dynprofield = p_auart
      value_org   = 'S'
    tables
      value_tab   = lt_value
    exceptions
      others      = 1.
endform.                    " value_request_auart

*&---------------------------------------------------------------------*
*&      Form  le_data_query
*&---------------------------------------------------------------------*
form le_data_query .

  clear : g_itab_t.

  loop at g_itab_t.

** 절단수량
    select  sum( lfimg )
      into  g_itab_t-zlfimg
      from  zlet0002
     where  vbeln  =  g_itab_t-vbeln_vl
       and  uecha  =  g_itab_t-posnr_vl
       and  jisir  =  '1'.

** 절단지시일
    select  max( jisidat )
      into  g_itab_t-jisidat
      from  zlet0002
     where  vbeln  =  g_itab_t-vbeln_vl
       and  uecha  =  g_itab_t-posnr_vl
       and  jisir  =  '1'.

** 절단완료일
    select  max( cutsdat )
      into  g_itab_t-cutsdat
      from  zlet0002
     where  vbeln  =  g_itab_t-vbeln_vl
       and  uecha  =  g_itab_t-posnr_vl
       and  cutsr  =  '1'.

    modify  g_itab_t.
    clear  g_itab_t.

  endloop.

endform.                    " le_data_query
*&---------------------------------------------------------------------*
*&      Form  fill_sobkz
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form fill_sobkz .

*  case 'X'.
*    when r02.                   " mto
*      r_sobkz-sign = 'I'.
*      r_sobkz-option = 'EQ'.
*      r_sobkz-low = 'E'.
*      append r_sobkz.
*    when r03.                   " mts
*      r_sobkz-sign = 'I'.
*      r_sobkz-option = 'EQ'.
*      r_sobkz-low = ' '.
*      append r_sobkz.
*    when others.                " mto+mts
*      refresh r_sobkz. clear r_sobkz.
*  endcase.

endform.                    " fill_sobkz
*&---------------------------------------------------------------------*
*&      Form  CALC_NFM_QTY
*&---------------------------------------------------------------------*
form calc_nfm_qty .

  clear : g_itab_t.

  loop at g_itab_t.

    if g_itab_t-spart+0(1) < '5'.

      call function 'ZSD_CALC_NFM_QTY'
        exporting
          i_vkorg  = g_itab_t-vkorg
          i_vtweg  = g_itab_t-vtweg
          i_matnr  = g_itab_t-matnr
          i_vrkme  = g_itab_t-vrkme
          i_kwmeng = g_itab_t-kwmeng "오더수량
        importing
          e_cuqty  = g_itab_t-cu_qty
          e_alqty  = g_itab_t-al_qty.
    endif.

    modify  g_itab_t.
    clear  g_itab_t.

  endloop.

endform.                    " CALC_NFM_QTY

*&---------------------------------------------------------------------*
*&      Form  GET_INS_IDEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form get_ins_iden .

  data : lv_sul_no  like zedt1000-sul_no,
         lv_max_rev like zedt1000-rev_seq.

  select single sul_no rev_seq
    into (lv_sul_no, lv_max_rev)
    from zedt1000
   where new_matnr = g_itso_t-matnr
     and rev_seq = ( select max( rev_seq )
                       from zedt1000
                      where new_matnr = g_itso_t-matnr ).

  if sy-subrc = 0 .

    select single data_char
      into g_itso_t-value5
      from zedv009
     where sul_no = lv_sul_no
       and rev_seq = lv_max_rev
       and attribute = 'COLOR'
       and gong_cd = 'INS'
       and jack_cd = 'CVI'.
  endif.

endform.                    " GET_INS_IDEN


*&---------------------------------------------------------------------*
*& Form GET_OTHER_DATA_COLLECTIVELY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
form get_other_data_collectively .

  check g_itso_t[] is not initial.

  refresh : gr_atnamo, gt_ords,  gt_ordvals,
            gt_vbpa,   gt_mara,  gt_tvagt,
            gt_t179t.

*___마지막납품일
  select vbeln
         posnr
         edatu
    into table gt_vbep
    from vbep
     for all entries in g_itso_t
   where vbeln = g_itso_t-vbeln
     and posnr = g_itso_t-posnr
     and etenr = ( select max( etenr )
                     from vbep
                    where vbeln = g_itso_t-vbeln
                      and posnr = g_itso_t-posnr ).

  sort gt_vbep by vbeln posnr.

*___파트너 - 판매처/납품처/지급처/특별재고파트너/영업사원
  select a~vbeln
         a~posnr
         a~parvw
         a~kunnr
         a~lifnr
         a~adrnr
         b~name1
         c~name1 as name2
         d~name1 as namad
    into table gt_vbpa
    from vbpa as a
    left outer join kna1 as b
      on a~kunnr = b~kunnr
    left outer join lfa1 as c
      on a~lifnr = c~lifnr
    left outer join adrc as d
      on a~adrnr     =  d~addrnumber
     and d~date_from <= sy-datum
     and d~nation    =  ' '
     for all entries in g_itso_t
   where vbeln =   g_itso_t-vbeln
     and parvw in ('AG', 'WE', 'RG', 'SB', 'VE').

  sort gt_vbpa by vbeln posnr parvw.

*___자재내역
  select a~matnr
         a~zzmaktx80
         b~maktx
    into table gt_mara
    from mara as a
   inner join makt as b
      on a~matnr = b~matnr
     and b~spras = sy-langu
     for all entries in g_itso_t
   where a~matnr = g_itso_t-matnr.

  sort gt_mara by matnr.

*___거절사유
  select abgru
         bezei
    into table gt_tvagt
    from tvagt
     for all entries in g_itso_t
   where spras = sy-langu
     and abgru = g_itso_t-abgru.

  sort gt_tvagt by abgru.

*___제품계층구조
  select prodh
         vtext
    into table gt_t179t
    from t179t
     for all entries in g_itso_t
   where prodh = g_itso_t-prodh.

  sort gt_t179t by prodh.

*___오더 특성
  gr_atnamo = value #( base gr_atnamo
                         sign = 'I' option = 'EQ'
                         ( low = 'SAP_MILLCA_FACTOR'        )
                         ( low = 'SAP_LENGTH_VKRME'         )
                         ( low = 'PD_CA_COLOR_BASE'         )
                         ( low = 'PD_AA_WITNESS_INSPECTION' )
                         ( low = 'PD_CA_INS_IDEN_CODE'      )
                         ( low = 'PD_TB_PRINT_APP'          )
                         ( low = 'PD_CA_COLOR_STRIPE'       )
                         ( low = 'PD_CA_COLOR_STRIPE_NO'    )

                          ).

  gt_ords   = value #( base gt_ords
                        for lw_data in g_itso_t
                          where ( vbeln is not initial )
                          ( vbeln = lw_data-vbeln
                            posnv = lw_data-posnr ) ).

*___오더 특성
  call function 'Z_GET_CHAR_OF_ORDER'
    exporting
      ir_atnam = gr_atnamo
    tables
      it_ords  = gt_ords
      et_vals  = gt_ordvals.

endform.
*&---------------------------------------------------------------------*
*& Form SET_DEFAULT_DATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_default_date .
  data: lv_date_fr type sy-datum,
        lv_date_to type sy-datum.

  lv_date_fr = sy-datlo.
  lv_date_fr+6(2) = '01'.

  lv_date_to = lv_date_fr.
  lv_date_to = zgtsd_cl_common2=>get_last_day_month( iv_date = lv_date_to ).
*  lv_date_to = lv_date_to + 1.
*  lv_date_to = zgtsd_cl_common2=>get_last_day_month( iv_date = lv_date_to ).

  append value #( sign = 'I' option = 'BT'
                  low  = lv_date_fr high = lv_date_to )
      to so_edatu.

endform.
*&---------------------------------------------------------------------*
*& Form MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form main .

  perform get_data.

endform.

*&---------------------------------------------------------------------*
*& Form F4_VKBUR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
form f4_vkbur  using    pv_fname.

  select distinct a~vkbur,b~bezei
    from tvkbz as a inner join tvkbt as b
                    on a~vkbur = b~vkbur

   where a~vkorg eq @pa_vkorg
    into table @data(lt_value).
  sort lt_value by vkbur.
  check lt_value[] is not initial.

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = 'VKBUR'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = pv_fname
      value_org       = 'S'
    tables
      value_tab       = lt_value
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.

endform.
*&---------------------------------------------------------------------*
*& Form F4_VKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
form f4_vkgrp  using   pv_fname.
  ranges: lr_vkbur for vbak-vkbur.

  lr_vkbur[] = corresponding #( so_vkbur[] ).

  select distinct a~vkbur,b~bezei,a~vkgrp,c~bezei as vkgrp_txt
    from tvkbz as h inner join tvbvk as a
                    on h~vkbur = a~vkbur
                    inner join tvkbt as b
                    on a~vkbur = b~vkbur and
                       b~spras = @sy-langu
                    inner join tvgrt as c
                    on a~vkgrp = c~vkgrp and
                       c~spras = @sy-langu
   where h~vkorg eq @pa_vkorg
     and a~vkbur in @lr_vkbur
    into table @data(lt_value).

  sort lt_value by vkbur.

  check lt_value[] is not initial.

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = 'VKGRP'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = pv_fname
      value_org       = 'S'
    tables
      value_tab       = lt_value
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.

endform.

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_data .

  refresh: gt_list,
           gt_so,
           gt_lstock.

  perform init_date.

  "-- 기본 so list 검색, SO, DO수량 가져옴
  perform get_basic_so_list.

  "--  수량 정보를 가져옴
  perform add_quantity_data.

  "-- 출하요청 정보 추가 - 기타 비철금속 수량 계산함
  perform get_additional_info .


  sort gt_list by vbeln posnr.


endform.
*&---------------------------------------------------------------------*
*& Form DISPLAY_NEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form display_new .

  refresh: g_field_t, g_fieldcat_t2.

  data: lt_dfies type standard table of dfies,
        ls_dfies type dfies.

  call function 'DDIF_FIELDINFO_GET'
    exporting
      tabname   = 'ZGTSDS1110'
      langu     = sy-langu
    tables
      dfies_tab = lt_dfies
    exceptions
      others    = 1.

  call function 'LVC_FIELDCATALOG_MERGE'
    exporting
      i_structure_name       = 'ZGTSDS1110'
    changing
      ct_fieldcat            = g_fieldcat_t2
    exceptions
      inconsistent_interface = 1
      program_error          = 2
      others                 = 3.


  data: g_fieldcat_s2 type lvc_s_fcat,
        g_fieldcat_s  type line of slis_t_fieldcat_alv.

  loop at g_fieldcat_t2 assigning field-symbol(<fd>).

    clear g_fieldcat_s.

    move-corresponding <fd> to g_fieldcat_s.
    if sy-tabix > 88.
      g_fieldcat_s-no_out = 'X'.
    endif.

    if <fd>-reptext is initial.
      read table lt_dfies into ls_dfies with key fieldname = <fd>-fieldname.
      if sy-subrc = 0.
        g_fieldcat_s-seltext_s = ls_dfies-fieldtext.
      endif.
    else.
      g_fieldcat_s-seltext_s = <fd>-reptext.
    endif.

    append g_fieldcat_s to g_fieldcat_t.
  endloop.


** Layout관련
  clear  gs_variant.
  move-corresponding  spec_layout  to  gs_variant.

** 기본값 SETTING
  g_layout_s-detail_popup      = 'X'.
  g_layout_s-zebra             = 'X'.
*  g_layout_s-box_fieldname     = 'MARK'.
  g_layout_s-colwidth_optimize = 'X'.

  g_save = 'A'.

  call function 'REUSE_ALV_GRID_DISPLAY'
    exporting
      i_callback_program      = g_program
      is_layout               = g_layout_s
      i_save                  = g_save
      is_variant              = gs_variant
      it_events               = g_events_t[]
      it_fieldcat             = g_fieldcat_t[]
      i_bypassing_buffer      = 'X'
      i_buffer_active         = 'X'
    importing
      e_exit_caused_by_caller = g_exit_caused_by_caller
      es_exit_caused_by_user  = g_exit_caused_by_user_s
    tables
      t_outtab                = gt_list
    exceptions
      program_error           = 1
      others                  = 2.


endform.
*&---------------------------------------------------------------------*
*& Form get_additional_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST
*&---------------------------------------------------------------------*
form get_additional_info .

*  data: lr_tdname like range of stxh-tdname,
*        lv_remark type zgte_bd_zremark.


  constants: lc_atnam_cust type atnam         value 'PD_CA_CUSTOMER_CODE',
             lc_matnr_scr  type matnr         value '000000000005000001', " SCR 8.0mm 자재코드
             lc_tdobject   type stxh-tdobject value 'VBBP',
             lc_tdid       type stxh-tdid     value '0001'.

  types: begin of ty_kunag_filter,
           kunag type kunag,
         end of ty_kunag_filter.
  data: lt_kunag_filter type standard table of ty_kunag_filter.

**
  data(lt_tmp) = gt_list[].
  if lt_tmp[] is initial.
    return.
  endif.

* 부서명
  select * from tvgrt into table @data(lt_tvgrt).

* 출하요청 수량
  select b~vbeln, b~posnr, sum( b~dlrmg ) as dlrmg, b~vrkme
    from @lt_tmp as a inner join zlet0401 as b
                         on a~vbeln eq b~vbeln
                        and a~posnr eq b~posnr
   where b~lvorm eq @abap_false
   group by b~vbeln, b~posnr, b~vrkme
    into table @data(lt_dlvrq).

  sort lt_dlvrq by vbeln posnr.
  delete adjacent duplicates from lt_dlvrq comparing vbeln posnr.

* 가장 최신 출하요청의 도착예정일
  select a~vbeln, a~posnr, c~arrdt, c~drdat
    from @lt_tmp as a inner join zlet0401 as b
                         on a~vbeln eq b~vbeln
                        and a~posnr eq b~posnr
                      inner join zlet0400 as c
                         on b~dlvrq eq c~dlvrq
  where b~lvorm eq @abap_false
    and c~lvorm eq @abap_false
    and b~dlvrq in ( select max( dlvrq )
                      from zlet0401
                     where vbeln eq a~vbeln
                       and posnr eq a~posnr
                       and lvorm eq @abap_false
                     group by vbeln, posnr )
  into table @data(lt_arrdt).

  sort lt_arrdt by vbeln posnr.
  delete adjacent duplicates from lt_arrdt comparing vbeln posnr.


**  " 직송 출하요청 정보
**  select distinct a~vbeln, a~posnr, coalesce( b~dlvrq, c~dlvrq ) as dlvrq
**    from @lt_tmp as a left join zgtmmt4411 as b
**                             on a~vbeln eq b~vbeln
**                            and a~posnr eq b~posnr
**                      left join zgtmmt4412 as c
**                             on a~vbeln eq c~vbeln
**                            and a~posnr eq c~posnr
**   where b~dlvrq is not initial
**      or c~dlvrq is not initial
**    into table @data(lt_dreq).

  " 출하요청 주소지 정보 조회
  select distinct a~vbeln, c~city1, c~street,
                  c~cust_name, c~cust_tel
    from @lt_tmp as a inner join zlet0401 as b
                               on a~vbeln eq b~vbeln
                              and a~posnr eq b~posnr
                              and b~lvorm eq @abap_false
                    inner join zlet0400 as c
                               on b~dlvrq eq c~dlvrq
     into table @data(lt_kunwe_adr).

  sort lt_kunwe_adr by vbeln.
  delete adjacent duplicates from lt_kunwe_adr comparing vbeln.


**  " 거래처 별 SCR 8.0mm 재고 합계
**  lt_kunag_filter = value #( for ls_tmp in lt_tmp
**                               ( kunag = |{ ls_tmp-kunag alpha = out }| ) ).
**
**  sort lt_kunag_filter by kunag.
**  delete adjacent duplicates from lt_kunag_filter comparing kunag.

**  select a~atwrt as kunag, a~matnr, sum( a~clabs ) as clabs
**      from @lt_kunag_filter as t inner join zgtsd_cv_get_vcofbatch as a
**                                         on a~atwrt = t~kunag
**     where a~atnam eq @lc_atnam_cust
**       and a~clabs gt 0
**       and a~matnr eq @lc_matnr_scr
**       and a~lgort like '34%'
**       and not exists ( select @abap_true
**                          from zgtsd_i_batch_picked_qty as b
**                         where b~matnr eq a~matnr
**                           and b~charg eq a~charg
**                           and b~total_picked_qty gt 0 )
**     group by a~atwrt, a~matnr
**      into table @data(lt_scr).

  "-- 지급인명
  select kunnr, name1
    from kna1
     for all entries in @gt_list
   where kunnr = @gt_list-kunrg
    into table @data(lt_kunrg).
  sort lt_kunrg by kunnr.
  delete adjacent duplicates from lt_kunrg comparing kunnr.

  "-- 사원명 가져오기
  select *
    from lfa1
     for all entries in @gt_list
   where lifnr = @gt_list-sales_empl
    into table @data(lt_user).
  sort lt_user by lifnr.


* 판매오더 Item 추가정보 입력
**  sort: lt_kunwe_adr by vbeln,
**        lt_scr       by kunag matnr,
**        lt_dreq      by vbeln posnr.


*  refresh lr_tdname.


  loop at gt_list assigning field-symbol(<lfs_wa>).

    "지급처
    read table lt_kunrg with key kunnr = <lfs_wa>-kunrg
                        assigning field-symbol(<kunrg>)
                        binary search.
    if sy-subrc = 0.
      <lfs_wa>-payer_name = <kunrg>-name1.
    endif.

    "영업사원
    read table lt_user  with key lifnr = <lfs_wa>-sales_empl
                        assigning field-symbol(<user>)
                        binary search.
    if sy-subrc = 0.
      <lfs_wa>-empl_name = <user>-name1.
    endif.

    "부서명
    read table lt_tvgrt with key vkgrp = <lfs_wa>-vkgrp
                        assigning field-symbol(<lfs_vkgrp>).
    if sy-subrc = 0.
      <lfs_wa>-vkgrp_nm = <lfs_vkgrp>-bezei.
    endif.

    " 출하요청 수량
    read table lt_dlvrq with key vbeln = <lfs_wa>-vbeln
                                 posnr = <lfs_wa>-posnr
                        binary search assigning field-symbol(<lfs_dlvrq>).
    if sy-subrc eq 0.
      if <lfs_dlvrq>-vrkme <> <lfs_wa>-vrkme.
        perform conversion_mat_unit  using    <lfs_wa>-matnr
                                              <lfs_dlvrq>-vrkme
                                              <lfs_dlvrq>-dlrmg
                                              <lfs_wa>-vrkme
                                     changing <lfs_dlvrq>-dlrmg.
      endif.
      <lfs_wa>-dlrmg = <lfs_dlvrq>-dlrmg.
      "-- 출하요청 수량도 완료수량을 제외한다.
      <lfs_wa>-dlrmg = <lfs_wa>-dlrmg - <lfs_wa>-kwmeng_cmpl.
    endif.

    " 출하요청 - 도착예정일
    read table lt_arrdt with key vbeln = <lfs_wa>-vbeln
                                 posnr = <lfs_wa>-posnr
                        binary search assigning field-symbol(<lfs_arrdt>).
    if sy-subrc eq 0.
      <lfs_wa>-do_arrdt = <lfs_arrdt>-arrdt.
      <lfs_wa>-do_drdat = <lfs_arrdt>-drdat.
    endif.


    " 출하요청 주소지 업데이트
**    if <lfs_wa>-shipto_addr is initial.
    read table lt_kunwe_adr with key vbeln = <lfs_wa>-vbeln
                            binary search assigning field-symbol(<lfs_adr>).
    if sy-subrc eq 0.
      <lfs_wa>-shipto_addr  = <lfs_adr>-city1 && <lfs_adr>-street.
*        <lfs_wa>-shipto_addr2 = <lfs_adr>-street.
      <lfs_wa>-cust_name  = <lfs_adr>-cust_name.
      <lfs_wa>-cust_tel   = <lfs_adr>-cust_tel.
    endif.
**    endif.

*   적송 판매오더 Migration 출하상태 변경
    if <lfs_wa>-vbeln eq '5110000782' or <lfs_wa>-vbeln eq '5110000774' or
       <lfs_wa>-vbeln eq '5110000776' or <lfs_wa>-vbeln eq '5110000777' or
       <lfs_wa>-vbeln eq '5110000778' or <lfs_wa>-vbeln eq '5110000779' or
       <lfs_wa>-vbeln eq '5110000780' or <lfs_wa>-vbeln eq '5110000781' or
       <lfs_wa>-vbeln eq '5110000775' or <lfs_wa>-vbeln eq '5110000783' or
       <lfs_wa>-vbeln eq '5110000784' or <lfs_wa>-vbeln eq '5110000785'.

      <lfs_wa>-wbsta = 'C'.
    endif.


    <lfs_wa>-in_cu = <lfs_wa>-so_cu * <lfs_wa>-in_qty_sum / <lfs_wa>-kwmeng.
    <lfs_wa>-in_al = <lfs_wa>-so_al * <lfs_wa>-in_qty_sum / <lfs_wa>-kwmeng.
    <lfs_wa>-in_fi = <lfs_wa>-so_fi * <lfs_wa>-in_qty_sum / <lfs_wa>-kwmeng.

    <lfs_wa>-do_m0_cu = <lfs_wa>-so_cu * <lfs_wa>-do_m0_gi / <lfs_wa>-kwmeng.
    <lfs_wa>-do_m0_al = <lfs_wa>-so_al * <lfs_wa>-do_m0_gi / <lfs_wa>-kwmeng.
    <lfs_wa>-do_m0_fi = <lfs_wa>-so_fi * <lfs_wa>-do_m0_gi / <lfs_wa>-kwmeng.

    <lfs_wa>-trans_cu = <lfs_wa>-so_cu * <lfs_wa>-trans_qty / <lfs_wa>-kwmeng.
    <lfs_wa>-trans_al = <lfs_wa>-so_al * <lfs_wa>-trans_qty / <lfs_wa>-kwmeng.
    <lfs_wa>-trans_fi = <lfs_wa>-so_fi * <lfs_wa>-trans_qty / <lfs_wa>-kwmeng.

  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form get_deliv_req_so_progress_go
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_DELVREQ
*&      --> PS_TYPE_DELIVERYREQUEST
*&      <-- PS_RETURN
*&---------------------------------------------------------------------*
form get_deliv_req_so_progress_go  tables   pt_delvreq_truck_o structure zgtmms4512
                                   using    ps_login           type zsds_log_0000_go
                                   changing ps_return          type zsds_log_0001_go.

  clear pt_delvreq_truck_o.

  if gt_so[] is not initial.
    select from zgtmm_cv_get_ddinfo
      fields *
       for all entries in @gt_so
      where bukrs = '6000'
        and vbeln = @gt_so-vbeln
        and posnr = @gt_so-posnr
        and vkbur in @so_vkbur
        and vkgrp in @so_vkgrp
       into table @data(lt_data).
  endif.


  if lt_data[] is not initial.
*배차정보 가져오기
    select from zgtmmt4403
      fields *
      for all entries in @lt_data
      where bukrs         eq @lt_data-bukrs
        and zreq_type eq @lt_data-zreq_type
        and dlvrq         eq @lt_data-dlvrq
        and vbeln         eq @lt_data-vbeln
        and posnr        eq @lt_data-posnr
        and ebeln         eq @lt_data-ebeln
        and ebelp         eq @lt_data-ebelp
        into corresponding fields of table @pt_delvreq_truck_o.

    select from zgtmmt4405
      fields *
      for all entries in @lt_data
      where bukrs         eq @lt_data-bukrs
           and zreq_type eq @lt_data-zreq_type
           and dlvrq         eq @lt_data-dlvrq
           and vbeln         eq @lt_data-vbeln
           and posnr        eq @lt_data-posnr
           appending corresponding fields of table @pt_delvreq_truck_o.
  endif.

  exit.
********************************************************


*  check : pi_deliveryrequest eq 'X',
*          gr_vbeln[] is not initial,
*          gr_posnr[] is not initial.

  data : ls_search type zsds_365_0030_0080_search_go.
  clear ls_search.

  ps_login-ename     = sy-uname.
  ps_login-bukrs     = '6000'.
  ls_search = value #( base ls_search
                      drdlv = 'Z'
                      reqdat_s = '20260101'
                      reqdat_e = '99991231' ).
*                      vbeln    = gr_vbeln[ 1 ]-low
*                      posnr    = gr_posnr[ 1 ]-low  ).

  try.
      call function 'ZSD_365_0030_0080_GO'
        exporting
          is_d365_login = ps_login
          is_search     = ls_search
* IMPORTING
*         ES_RETURN     =
        tables
*         et_head       = pt_delvreq_h
*         et_item       = pt_delvreq_i
          et_truck_oem  = pt_delvreq_truck_o
*         et_truck      = pt_delvreq_truck
        .

    catch cx_root into data(lo_err).
      ps_return = value #( mtype = 'E' message = lo_err->get_longtext( ) ).
  endtry.

endform.
*&---------------------------------------------------------------------*
*& Form get_purchase_so_progress_go
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_PURCHASE
*&      --> PT_INSPECTION
*&      --> PS_TYPE_PURCHASEORDER
*&      <-- PS_RETURN
*&---------------------------------------------------------------------*
form get_purchase_so_progress_go  tables   pt_purchase structure zgtsdsif1030
                                           pt_inspection structure zgtsdsif1031
                                  changing ps_return.


  "구매오더 정보 추출
  if gt_list[] is not initial.
    select a~*, b~menge as po_menge
      from zgtsd_cv_so_item_po as a inner join ekpo as b
                                    on a~ebeln eq b~ebeln
                                    and a~ebelp eq b~ebelp
       for all entries in @gt_list
     where vbeln = @gt_list-vbeln
       and posnr = @gt_list-posnr
    into corresponding fields of table @pt_purchase.
    sort pt_purchase by vbeln posnr ebeln ebelp.
  endif.

  delete pt_purchase where vbeln = '5110000177'. " 이중 처리된 po는 제외함


  "검사요청 정보 추출
  if pt_purchase[] is not initial.

*    입고 수량이 없을 경우 전기일(BUDAT) 삭제
    loop at pt_purchase assigning field-symbol(<lfs_po>).
      if <lfs_po>-gr_menge eq 0.
        clear : <lfs_po>-budat.
      endif.
    endloop.

*     검사요청 정보 추출
    data(lt_temp) = pt_purchase[].
    select b~vbeln,b~vbelp as posnr,b~ebeln,b~ebelp,b~zinsp_no,
           c~length, c~vrkme, b~zinsp_qty,
           b~zinsptype,b~zinspdate,b~zinspres,b~erdat
      from @lt_temp as a inner join zgtmm_cv_get_dd_qcdata as b
                             on a~vbeln = b~vbeln and
                                a~posnr = b~vbelp and
                                a~ebeln = b~ebeln and
                                a~ebelp = b~ebelp
                         left join zgtsd_cv_get_vcofso as c
                             on b~vbeln eq c~vbeln and
                                b~vbelp eq c~posnr
     order by b~vbeln, b~vbelp, b~ebeln, b~ebelp
      into corresponding fields of table @pt_inspection.
  endif.


**
  free : lt_temp.

endform.
*&---------------------------------------------------------------------*
*& Form get_production_so_progress_go
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_PRODUCTION
*&      --> PT_PRODUCTION_DETAIL
*&      --> PT_ITEM
*&      --> PS_TYPE
*&      <-- PS_RETURN
*&---------------------------------------------------------------------*
form get_production_so_progress_go  tables   pt_production        structure zgtpps1013
                                             pt_production_detail structure zgtpps1014
                                             pt_item              structure zgtsdsif1022
                                    changing ps_return            type zsds_log_0001_go.

  types : begin of ty_order,
            vbeln type vbeln_va,
            posnr type posnr_va,
          end of ty_order.

  data : lt_target type standard table of ty_order with empty key,
         ls_target type ty_order.

  check gt_list[] is not initial.

  move-corresponding gt_list[] to lt_target[].
  sort lt_target by vbeln posnr.
  delete adjacent duplicates from lt_target comparing vbeln posnr.
**********************************************************************
** Call Function
**********************************************************************
  try.
      call function 'ZGTPP_PROD_STATUS_REF_SO'
        tables
          it_item          = lt_target
          ot_stat_overview = pt_production
          ot_stat_detail   = pt_production_detail.
    catch cx_root into data(lo_err).
      ps_return = value #( mtype = 'E' message = lo_err->get_longtext( ) ).
  endtry.


**********************************************************************
**  Moidfy Header Data: 생산지시일자가 없을 경우 PR 생성 일자 입력
**********************************************************************
  if ps_return-mtype ne 'E' and pt_production[] is not initial.

    perform modify_prd_header tables pt_production.

  endif.

  sort : pt_production by vbeln posnr,
         pt_production_detail by vbeln posnr gong_cd sequance.

**********************************************************************
** Modify item Data: 정조장(ST) 여부 검증 및 집계
**********************************************************************
  check: pt_production_detail[] is not initial.

* Item Detail 조회
  perform modify_prd_item_detail tables pt_production_detail.

* Item Overview 조회
**  perform modify_prd_item tables pt_production_detail.

**
  free : lt_target.
  clear : ls_target.

endform.
*&---------------------------------------------------------------------*
*& Form modify_prd_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_PRODUCTION_DETAIL
*&---------------------------------------------------------------------*
form modify_prd_item  tables   pt_production_detail structure zgtpps1014.

**********************************************************************
**  데이터 재구성을 위해 생산공정(lt_prd), 절단(lt_ct), 정조장(lt_st) 분류
**********************************************************************
  data(lt_prd) =  pt_production_detail[].
  data(lt_ct)  =  pt_production_detail[].
  data(lt_st)  =  pt_production_detail[].

  clear : pt_production_detail[].


**********************************************************************
**   Setp 0) 생산공정의 가장 마지막 공정 출력
**********************************************************************
  delete: lt_prd where ( gong_cd eq 'CT' or  "절단
                        gong_cd eq 'ST' ) "정조장
                   and   status eq '미진행'.

  sort lt_prd by vbeln posnr ascending sequance descending.
  delete adjacent duplicates from lt_prd comparing vbeln posnr.


**********************************************************************
**   Setep 1) 절단 수량(CT) 판매오더/아이템/공정/상태 기준 수량 집계
**********************************************************************
  delete: lt_ct where gong_cd ne 'CT'.  "절단

  data: ls_ct_sum type zgtpps1014,
        lt_ct_sum type standard table of zgtpps1014.

  select a~vbeln, a~posnr, a~gong_cd, a~status,
         sum( a~psmng ) as psmng
    from @lt_ct as a
   where a~gong_cd eq 'CT'
   group by a~vbeln, a~posnr, a~gong_cd, a~status
    into corresponding fields of table @lt_ct_sum.

  sort: lt_ct_sum by vbeln posnr.
  delete adjacent duplicates from lt_ct_sum comparing vbeln posnr.



**   Setp 2) 정조장(ST) 수량 집계 (Single Unit Batch 대상)
  delete: lt_st where gong_cd ne 'ST'. "정조장

**********************************************************************
**   Step 2-1) Single Unit Batch 아닌 대상 추출
**********************************************************************
  select a~vbeln, a~posnr, a~gong_cd, a~charg,
         sum( a~psmng ) as psmng
    from @lt_st as a inner join vbap as b
                     on a~vbeln eq b~vbeln
                     and a~posnr eq b~posnr
                     left join marc as c
                     on b~matnr eq c~matnr
                     and b~werks eq c~werks
  where c~dpcbt ne 'C'
     or c~dpcbt is null
  group by a~vbeln, a~posnr, a~gong_cd, a~charg
    into table @data(lt_factor).

**********************************************************************
**   Step 2-2) Single Unit Batch 추출
**********************************************************************
  select a~vbeln, a~posnr, a~gong_cd,
         a~charg, a~psmng, a~status,
         b~matnr, b~werks
    from @lt_st as a inner join vbap as b
                     on a~vbeln eq b~vbeln
                     and a~posnr eq b~posnr
                     inner join marc as c
                     on b~matnr eq c~matnr
                     and b~werks eq c~werks
  where c~dpcbt eq 'C'
    into table @data(lt_st_c).
  sort: lt_st_c by vbeln posnr gong_cd.

**   Step 2-2-1) 판매오더 재고 추출
  select a~vbeln, a~posnr, a~matnr, a~charg,
         sum( b~kalab ) as kalab

    from @lt_st_c as a inner join mska as b
                       on a~vbeln eq b~vbeln
                       and a~posnr eq b~posnr
*                         and a~matnr EQ b~matnr
                       and a~charg eq b~charg
*                         and a~wekrs EQ b~werks
  group by a~vbeln, a~posnr, a~matnr, a~charg
   into table @data(lt_estock).

  sort: lt_estock by vbeln posnr charg.

**   Step 2-2-2) Plant 재고 추출
  select a~matnr, a~werks, a~charg,
         sum(  b~clabs ) as clabs

    from @lt_st_c as a inner join mchb as b
                       on a~matnr eq b~matnr
                       and a~charg eq b~charg
                       and a~werks eq b~werks
   where b~clabs gt 0
   group by a~matnr, a~werks, a~charg
    into table @data(lt_mchb).

  sort: lt_mchb by matnr werks charg.


**   Step 2-2-3) 정조장(ST) 여부 검증 후 절단 요청(CT) 전환
  loop at lt_st_c assigning field-symbol(<lfs_st>).
    read table lt_estock into data(ls_estock) with key vbeln = <lfs_st>-vbeln
                                                       posnr = <lfs_st>-posnr
*                                                         matnr = <lfs_st>-matnr
                                                       charg = <lfs_st>-charg.
*                                                         werks = <lfs_st>-werks.

    if line_exists( lt_estock[ vbeln = <lfs_st>-vbeln posnr = <lfs_st>-posnr ] ).
    else.
      read table lt_mchb into data(ls_mchb) with key matnr = <lfs_st>-matnr
                                                     werks = <lfs_st>-werks
                                                     charg = <lfs_st>-charg.
      if sy-subrc eq 0.
*          수량 비교
        if <lfs_st>-psmng ne ls_mchb-clabs.
          <lfs_st>-gong_cd = 'CT'.
          <lfs_st>-status = '미진행'.
        endif.
      else.
        <lfs_st>-gong_cd = 'CT'.
        <lfs_st>-status = '미진행'.

      endif.
    endif.
  endloop.

**********************************************************************
**   Step 3) 절단(CT) 수량 정보 재집계 Collect
**           Step 2-2-3) 에서 ST->CT 변경된 데이터 Collect
**********************************************************************
  loop at lt_st_c into data(ls_st_c) where gong_cd eq 'CT'.
    clear: ls_ct_sum.

    move-corresponding ls_st_c to ls_ct_sum.
    collect ls_ct_sum into lt_ct_sum.
    delete lt_st_c.

  endloop.


**********************************************************************
**  Step 4) 생산공정, 절단(CT), 정조장(ST) 정보 구성
**********************************************************************
  data: lt_prd_detail type standard table of zgtpps1014.

**    1) 절단완료 정보 이관
  lt_prd_detail[] = corresponding #( lt_ct_sum[] ).
  append lines of lt_prd_detail to pt_production_detail.
  clear lt_prd_detail[].

**    2) 정조장 정보 이관
  lt_prd_detail[] = corresponding #( lt_st_c[] ).
  append lines of lt_prd_detail to pt_production_detail.
  clear lt_prd_detail[].

**    3) 공정현황 정보 이관
  lt_prd_detail[] = corresponding #( lt_prd[] ).
  append lines of lt_prd_detail to pt_production_detail.
  clear lt_prd_detail[].

  sort: pt_production_detail by vbeln posnr gong_cd.
  delete adjacent duplicates from pt_production_detail comparing vbeln posnr gong_cd status.

**
  free: lt_prd_detail, lt_ct_sum.

endform.
*&---------------------------------------------------------------------*
*& Form modify_prd_item_detail
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_PRODUCTION_DETAIL
*&---------------------------------------------------------------------*
form modify_prd_item_detail  tables   pt_production_detail structure zgtpps1014.

  data(lt_tmp) =  pt_production_detail[].

  sort lt_tmp by vbeln posnr charg.
  delete adjacent duplicates from lt_tmp comparing vbeln posnr charg.

**********************************************************************
** Single Unit Batch 추출
**********************************************************************
  select a~vbeln, a~posnr, a~psmng,
         a~sequance, a~gong_cd, a~status,
         b~werks, b~matnr, a~charg
    from @lt_tmp as a inner join vbap as b
                      on a~vbeln eq b~vbeln
                      and a~posnr eq b~posnr
                      inner join marc as c
                      on b~matnr eq c~matnr
                      and b~werks eq c~werks
  where c~dpcbt eq 'C'
    and a~gong_cd eq 'ST'
   into table @data(lt_single).

  sort: lt_single by vbeln posnr matnr charg.

**********************************************************************
**  Sales Order Stock 정보 추출
**********************************************************************
  select a~vbeln, a~posnr, a~matnr, a~charg,
         sum( b~kalab ) as kalab

    from @lt_single as a inner join mska as b
                         on a~vbeln eq b~vbeln
                         and a~posnr eq b~posnr
                         and a~charg eq b~charg
  group by a~vbeln, a~posnr, a~matnr, a~charg
   into table @data(lt_estock).

  sort : lt_estock by vbeln posnr matnr charg.

**********************************************************************
**  Plant 재고 추출
**********************************************************************
  select a~matnr, a~werks, a~charg,
         sum(  b~clabs ) as clabs

    from @lt_single as a inner join mchb as b
                         on a~matnr eq b~matnr
                         and a~charg eq b~charg
                         and a~werks eq b~werks
   where b~clabs gt 0
   group by a~matnr, a~werks, a~charg
    into table @data(lt_mchb).

  sort: lt_mchb by matnr werks charg.


**********************************************************************
**   정조장(ST) 여부 검증 후 절단요청(CT)전환
**********************************************************************
  loop at lt_single assigning field-symbol(<lfs_detail>).

**    Sales Order Stock 입고 여부
    read table lt_estock into data(ls_estock) with key vbeln = <lfs_detail>-vbeln
                                                       posnr = <lfs_detail>-posnr
                                                       charg = <lfs_detail>-charg.

    if line_exists( lt_estock[ vbeln = <lfs_detail>-vbeln posnr = <lfs_detail>-posnr ] ).
    else.

**    Plant Stock 존재 여부
      read table lt_mchb into data(ls_mchb) with key matnr = <lfs_detail>-matnr
                                                     werks = <lfs_detail>-werks
                                                     charg = <lfs_detail>-charg.
      if sy-subrc eq 0.
**    Batch Qty 일치 여부
        if <lfs_detail>-psmng ne ls_mchb-clabs.
          <lfs_detail>-gong_cd = 'CT'.
          <lfs_detail>-status = '미진행'.
        endif.
      else.
        <lfs_detail>-gong_cd = 'CT'.
        <lfs_detail>-status = '미진행'.

      endif.
    endif.
  endloop.


**********************************************************************
**  검증 결과 Update
**********************************************************************
  loop at pt_production_detail assigning field-symbol(<lfs_prd_detail>)
                                                where gong_cd eq 'ST' and
                                                      charg   is not initial.

    assign lt_single[ vbeln    = <lfs_prd_detail>-vbeln
                      posnr    = <lfs_prd_detail>-posnr
                      sequance = <lfs_prd_detail>-sequance
                      charg    = <lfs_prd_detail>-charg ] to field-symbol(<lfs_single>).

    if sy-subrc eq 0 and <lfs_prd_detail>-gong_cd ne <lfs_single>-gong_cd.
      <lfs_prd_detail>-gong_cd = <lfs_single>-gong_cd.
    endif.

  endloop.

endform.
*&---------------------------------------------------------------------*
*& Form modify_prd_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_PRODUCTION
*&---------------------------------------------------------------------*
form modify_prd_header  tables   pt_production  structure zgtpps1013.


  types: begin of ty_ebkn_key,
           vbeln type ebkn-vbeln,
           vbelp type ebkn-vbelp,
           matnr type matnr,
         end of ty_ebkn_key.
  data: lt_ebkn_keys type standard table of ty_ebkn_key.

**

  data(lt_tmp) = pt_production[].

  select a~vbeln, a~posnr, b~matnr, a~podat
    from @lt_tmp as a inner join vbap as b
                      on a~vbeln eq b~vbeln
                      and a~posnr eq b~posnr
  into table @data(lt_so).

  " 1. PODAT 필드가 비어있는 데이터의 Key(VBELN, POSNR) 추출
  lt_ebkn_keys = value #( for ls_det in lt_so
                          where ( podat is initial and
                                  vbeln is not initial and
                                  posnr is not initial )
                          ( vbeln = ls_det-vbeln
                            vbelp = ls_det-posnr
                            matnr = ls_det-matnr ) ).

  if lt_ebkn_keys[] is not initial.
    sort lt_ebkn_keys by vbeln vbelp.
    delete adjacent duplicates from lt_ebkn_keys comparing vbeln vbelp.

    " 2. EBKN 테이블에서 생성일(ERDAT) 일괄 조회
    select a~vbeln, a~vbelp, b~erdat
      from ebkn as a inner join eban as b
                      on a~banfn eq b~banfn
                      and a~bnfpo eq b~bnfpo
      for all entries in @lt_ebkn_keys
     where vbeln eq @lt_ebkn_keys-vbeln
       and vbelp eq @lt_ebkn_keys-vbelp
       and matnr eq @lt_ebkn_keys-matnr
       and b~loekz eq @space
      into table @data(lt_ebkn_res).

    if sy-subrc eq 0.
      sort lt_ebkn_res by vbeln vbelp.

      " 3. 값을 찾은 경우 해당 행의 PODAT 업데이트
      loop at pt_production assigning field-symbol(<ls_det>) where podat is initial.
        assign lt_ebkn_res[ vbeln = <ls_det>-vbeln
                            vbelp = <ls_det>-posnr ] to field-symbol(<ls_ebkn>).
        if sy-subrc eq 0.
          <ls_det>-podat = <ls_ebkn>-erdat.
        endif.
      endloop.

    endif.

  endif.

**
  free: lt_ebkn_keys.

endform.
*&---------------------------------------------------------------------*
*& Form get_delivery_so_progress_go
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_DELV
*&      --> P_
*&      <-- PS_RETURN
*&---------------------------------------------------------------------*
form get_delivery_so_progress_go  tables   pt_delv    structure zgtsdsif1023
                                  changing ps_return  type zsds_log_0001_go.

**
  check: ps_return-mtype is initial.

  check gt_list[] is not initial.

  select *
    from zgtsd_cv_deliveryorder
    for all entries in @gt_list
   where vbeln  =  @gt_list-vbeln
     and posnr  =  @gt_list-posnr
    into corresponding fields of table @pt_delv.


endform.
*&---------------------------------------------------------------------*
*& Form get_billing_so_progress_go
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_BILL
*&      --> PS_TYPE_BILLING
*&      <-- PS_RETURN
*&---------------------------------------------------------------------*
form get_billing_so_progress_go  tables   pt_bill    structure zgtsdsif1024
                                 changing ps_return  type zsds_log_0001_go.

**
  check: ps_return-mtype is initial.

  check gt_list[] is not initial.

  select *  from zgtsd_cv_billing
    for all entries in @gt_list
   where vbeln  =  @gt_list-vbeln
     and posnr  =  @gt_list-posnr
    into corresponding fields of table @pt_bill.


endform.
**&---------------------------------------------------------------------*
**& Form initialization
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
*form initialization .
*  G_REPID = SY-REPID.
*  G_SAVE = 'A'.   "The user may save all types of a layout
*
**-납품요청일
*  PERFORM SET_DEFAULT_DATE.
*
*endform.
*&---------------------------------------------------------------------*
*& Form selection_screen_output
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*form selection_screen_output .
*** Layout관련
*  IF  DEFAULT  =  ' '.
*
*    CLEAR DEF_LAYOUT.
*    MOVE  G_REPID   TO  DEF_LAYOUT-REPORT.
*
*    CALL FUNCTION 'LVC_VARIANT_DEFAULT_GET'
*      EXPORTING
*        I_SAVE     = G_SAVE
*      CHANGING
*        CS_VARIANT = DEF_LAYOUT
*      EXCEPTIONS
*        NOT_FOUND  = 2.
*
*    IF  SY-SUBRC  =  2.
*      IF  NOT P_VARI IS INITIAL.
*        MESSAGE S001 WITH '레이아웃 기본세팅이 없습니다.'.
*      ENDIF.
*    ELSE.
*      P_VARI  =  DEF_LAYOUT-VARIANT.
*      DEFAULT  =  'X'.
*    ENDIF.
*
*  ENDIF.
*
*  LOOP AT SCREEN.
*    IF SCREEN-GROUP1 EQ 'ZM1'.
*      SCREEN-ACTIVE = 0.
*    ENDIF.
*    MODIFY SCREEN.
*  ENDLOOP.
*
*endform.
*&---------------------------------------------------------------------*
*& Form init_date
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form init_date .

  refresh: gr_gidat, gr_edatu.

  read table so_edatu index 1.
  if sy-subrc = 0.
    gv_edatu        = so_edatu-high.    "납기조회 최종일
    gv_lastmon_date = so_edatu-low - 1. "납시조회 이전 마지막일

    if ra1 = 'X'.  "당월+미출고
      call function 'RP_LAST_DAY_OF_MONTHS'
        exporting
          day_in            = gv_edatu
        importing
          last_day_of_month = gv_edatu
        exceptions
          day_in_no_date    = 1
          others            = 2.

      gr_gidat-sign   = 'I'.
      gr_gidat-option = 'BT'.
      gr_gidat-low    = gv_edatu(6) && '01'.
      gr_gidat-high   = gv_edatu.
      append gr_gidat. " 당월출고 데이터 검색용

      gr_edatu-sign   = 'I'.
      gr_edatu-option = 'BT'.
      gr_edatu-low    = '20100101'.
      gr_edatu-high   = gv_edatu.
      append gr_edatu. " 납기기준 검색용, 당월은  ~ 현재월 말일까지
    else.
      gr_edatu[] = so_edatu[]. " 납기기준 검색용, 차월01 ~ 차월31
    endif.

  endif.


endform.
*&---------------------------------------------------------------------*
*& Form get_basic_so_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_basic_so_list .

  data: begin of lt_order occurs 0,
          vbeln type vbeln,
          posnr type posnr,
        end of lt_order.

  ranges: lr_kunwe for vbak-kunnr,             "인도처
          lr_kunrg for vbak-kunnr.             "지급처

  clear: lr_kunwe[], lr_kunrg[].

  if pa_kunwe is not initial.
    set_range lr_kunwe pa_kunwe.
  endif.

  if pa_kunrg is not initial.
    set_range lr_kunrg pa_kunrg.
  endif.

  "-- 자재명은 대문자로 검색
  if so_arktx[] is not initial.
    loop at so_arktx.
      translate so_arktx-low to upper case.
      translate so_arktx-high to upper case.
      modify so_arktx.
    endloop.
  endif.

  "1. open SO
  select distinct
         a~vbeln,
         b~posnr
    from vbak as a
    inner join vbap as b on a~vbeln = b~vbeln
    inner join tvak as t on a~auart = t~auart
    inner join vbep as c on b~vbeln = c~vbeln
                        and b~posnr = c~posnr
    inner join vbpa as d on d~vbeln = b~vbeln
                        and d~posnr = '000000'
                        and d~parvw = 'VE'
   where a~erdat  in  @so_erdat
     and a~auart  in  @so_auart
     and a~vbeln  in  @so_vbeln
     and a~zpjno  in  @so_zpjno
     and a~kunnr  in  @so_kunnr
     and a~vkorg  =   @pa_vkorg
     and a~vtweg  in  @so_vtweg
     and a~spart  in  @so_spart
     and a~vkbur  in  @so_vkbur
     and a~vkgrp  in  @so_vkgrp
     and a~zqtno  in  @so_zqtno
     and a~ztver  in  @so_ztver
     and b~werks  in  @so_werks
     and b~matnr  in  @so_matnr
     and upper( b~arktx ) in  @so_arktx
     and a~ernam  in  @so_ernam
*     and t~vbtyp in ( 'C', 'H' )   " 일반 판매오더 (Order), 반품
*     and c~edatu <= @gv_edatu      "조회 기준월의 말일 이전 데이터
     and c~edatu  in  @gr_edatu     "당월+미출고 , 익월이후
     and b~vstel  in  @so_vstel     "출하지점
     and b~matkl  in  @so_matkl     "자재그룹
     and d~lifnr  in  @so_lifnr     "영업사원
     and c~lfrel   = 'X'
     and b~abgru =  @space        " 거부사유 없음
     and b~gbsta <> 'C'           " S/4HANA: VBAP-GBSTA (전체처리상태 완료 제외)
     and b~lfsta <> 'C'           " S/4HANA: VBAP-LFSTA (납품상태 완료 제외)
   into table @data(lt_open_so).


  "-- 필요한 do list를 가져온다.
  data : lt_do      type ty_do_tab,  "현재 open과 당월출고 do
         lt_last_do type ty_do_tab.  "지난달 이전에 출고된 do

  perform make_do_data  tables  lt_do
                                lt_last_do.



  "-- 전체 리스트할 SO를 collect함, do와 so를 합침
  move-corresponding lt_open_so[] to lt_order[].
  move-corresponding lt_do[]      to lt_order[] keeping target lines.
  sort lt_order by vbeln posnr.
  delete adjacent duplicates from lt_order comparing vbeln posnr.

  "-- 납품 & 미완료 오더로 SO 정보를 가져옴
  if lt_order[] is not initial.

    select a~vbeln,
           b~posnr,
           c~etenr,
           b~werks,
           b~matnr,              " 자재번호
           b~arktx,              " 자재명
           b~kwmeng,             " 수량
           b~vrkme,              " 단위
           b~netpr,              " 단가(KRW)
           b~netwr,              " 금액
           b~waerk,
           b~mvgr3,              " 정조장 여부
           b~absta,              " 거부 상태(품목)
           b~fixmg,              " 납품일 및 수량(고정)
           b~pstyv,              " 판매 문서 항목 범주
           b~abgru,              " 거부사유
           c~edatu,              " 납기일
           c~lfrel,              " 납품관련품목
           c~bmeng,              " 확인된 수량
           c~banfn,              " 구매 요청 번호
           c~lifsp,              " 납품보류
           c~ettyp,              " 일정 라인 범주

           f~bstkd_e,            " 납품처의 구매 오더 번호
           f~bstkd,
           a~zpjno,
           a~spart,              " 제품유형
           a~vkgrp,
           a~vtweg,
           b~shkzg,
           a~auart,
           a~vbtyp,
           a~vkbur,
           a~erdat,
           a~zqtno,
           a~ztver,
           m~meins,
           k~kursk,
           k~prsdt,

           d~kunnr  as shipto,
           d2~kunnr as kunrg,
           d3~lifnr as sales_empl,
           d4~kunnr as kunnr,
           e~name1  as shipto_nm,
           e~city1  ,
           e~street ,
           e4~name1 as kunnr_nm,
           j~zptxt
      from vbak as a
      inner join vbap as b on a~vbeln = b~vbeln
      inner join vbep as c on b~vbeln = c~vbeln
                          and b~posnr = c~posnr
                          and c~etenr = '0001'
      inner join mara as m on b~matnr = m~matnr
      inner join vbkd as k on a~vbeln = k~vbeln
                          and k~posnr = '000000'
      inner join vbpa as d on a~vbeln eq d~vbeln
                          and d~posnr eq '000000'
                          and d~parvw eq 'WE'         "납품처
      inner join vbpa as d2 on a~vbeln eq d2~vbeln
                          and d2~posnr eq '000000'
                          and d2~parvw eq 'RG'        "지급처
      inner join vbpa as d3 on a~vbeln eq d3~vbeln
                          and d3~posnr eq '000000'
                          and d3~parvw eq 'VE'        "영업사원
      inner join vbpa as d4 on a~vbeln eq d4~vbeln
                          and d4~posnr eq '000000'
                          and d4~parvw eq 'AG'         "판매처
       left join adrc as e on d~adrnr eq e~addrnumber
       left join adrc as e4 on d4~adrnr eq e4~addrnumber
       left join vbkd as f on a~vbeln = f~vbeln
                          and b~posnr = f~posnr
       left join zsd0106t as j on a~zpjno = j~zpjno
       for all entries in @lt_order
     where a~vbeln = @lt_order-vbeln
       and b~posnr = @lt_order-posnr
*       and c~edatu  in @gr_edatu   "당월+미출고 , 익월이후
       and d~kunnr  in @lr_kunwe    "납품처
       and d2~kunnr in @lr_kunrg    "지급처
       and d3~lifnr in @so_lifnr    "영업사원
       and c~lfrel = 'X'
      into table @data(lt_all).

*
    clear gt_dlv_su[].
    select a~vbeln,
           a~posnr,
           a~abgru,
           a~kwmeng,
           a~vrkme,
           sum( b~dlvqty_su ) as dlvqty_su
      from vbap as a inner join vbep as b on a~vbeln = b~vbeln
                                         and a~posnr = b~posnr
                     inner join @lt_all as c on a~vbeln = c~vbeln
                                            and a~posnr = c~posnr
     where a~abgru <> ''
       and dlvqty_su > 0
     group by a~vbeln, a~posnr, a~abgru, a~kwmeng, a~vrkme
      into table @gt_dlv_su.
  endif.


  check lt_all[] is not initial.


*--- 비철금속용 마스터 데이터
  data   : lv_kwmeng type vbap-kwmeng,
           lv_tmpqty type vbap-brgew.

  select  *
    into  corresponding fields of table @gt_tkgw
    from  /nfm/tkgw
    for all entries in @lt_all
   where  matnr = @lt_all-matnr
     and  werks = @lt_all-werks
     and  nes in ( 'CU', 'AL', 'FI' ).

  sort gt_tvgw    by org vtweg matnr.
  sort gt_tkgw    by matnr werks.
  sort lt_last_do by vbeln posnr.
  sort lt_do      by vbeln posnr.
  sort gt_dlv_su  by vbeln posnr.

  data lv_sign type i.


  loop at lt_all assigning field-symbol(<all>).
    clear gt_list.

    if <all>-vbtyp = 'T'. "반품
      lv_sign = -1.
    else.
      lv_sign = 1.
    endif.

    "-- 거부사유가 있지만 납품완료 수량이 있는 경우, 원 수량을 바꿔준다.
    if <all>-abgru is not initial.
      gt_list-abgru  = <all>-abgru.
      read table gt_dlv_su  assigning field-symbol(<dlv>)
                             with key vbeln = <all>-vbeln
                                      posnr = <all>-posnr
                                      binary search.
      if sy-subrc = 0.
        <all>-kwmeng = <all>-kwmeng - <dlv>-dlvqty_su.
      endif.
    endif.

    gt_list-shipto         = <all>-shipto.
    gt_list-shipto_nm      = <all>-shipto_nm.   " [KUNWE] SHIPTO_NAME
    gt_list-kunrg          = <all>-kunrg.       " 지급처
    gt_list-vbeln          = <all>-vbeln.       " 주문번호
    gt_list-posnr          = <all>-posnr.       " 품목번호
    gt_list-werks          = <all>-werks.       " 자재번호
    gt_list-matnr          = <all>-matnr.       " 자재번호
    gt_list-arktx          = <all>-arktx.       " 자재명
    gt_list-shkzg          = <all>-shkzg.       " 차변/대변
    gt_list-kwmeng         = <all>-kwmeng * lv_sign.      " 수량
    gt_list-vrkme          = <all>-vrkme.      " 단위
    gt_list-netpr          = <all>-netpr * lv_sign.      " 단가
    gt_list-netwr          = <all>-netwr * lv_sign.      " 금액(잔여)
    gt_list-waerk          = <all>-waerk.
    gt_list-edatu          = <all>-edatu.      " 납기
    gt_list-lfrel          = <all>-lfrel.      " 납품관련품목
    gt_list-meins          = <all>-meins.      " 재고/생산 단위
*    gt_list-meins          = <all>-vrkme.      " 재고/생산 단위
    gt_list-kursk          = <all>-kursk.      " 환율
    gt_list-prsdt          = <all>-prsdt.      " 환율일자
    gt_list-kunnr          = <all>-kunnr.      " 판매처
    gt_list-kunnr_nm       = <all>-kunnr_nm.   " 판매처명
    gt_list-pstyv          = <all>-pstyv.      " 납품
    gt_list-ettyp          = <all>-ettyp.      " 일정 라인 범주

    case <all>-mvgr3.
      when 'X'.
        gt_list-stdlen = '정조장'.
      when 'Y'.
        gt_list-stdlen = '부분 정조장'.
    endcase.
    gt_list-shipto_addr    = <all>-city1 && <all>-street. " 납품처주소

    gt_list-zpjno           = <all>-zpjno.        " 프로젝트
    gt_list-zptxt           = <all>-zptxt.        " 프로젝트 명
    gt_list-bstkd_e         = <all>-bstkd_e.      " C/S 작번
    gt_list-bstnk           = <all>-bstkd.        " 고객구매번호
    gt_list-vkorg           = pa_vkorg.
    gt_list-spart           = <all>-spart.        " 제품유형
    gt_list-vkgrp           = <all>-vkgrp.        " 영업 그룹
    gt_list-vtweg           = <all>-vtweg.        " 제품군
    gt_list-auart           = <all>-auart.        " 오더 type
    gt_list-vbtyp           = <all>-vbtyp.        " SD 문서 범주
    gt_list-vkbur           = <all>-vkbur.        " 영업팀
    gt_list-kunrg           = <all>-kunrg.        " 지급인
    gt_list-sales_empl      = <all>-sales_empl.   " 영업사원
    gt_list-erdat           = <all>-erdat.        " SO생성일
    gt_list-zqtno           = <all>-zqtno.        " 견적번호
    gt_list-ztver           = <all>-ztver.        " Version Number

    "-- 잔여수량 계산 ([최적화] BINARY SEARCH + FROM sy-tabix로 선형 전체 스캔 제거)
    read table lt_last_do transporting no fields
      with key vbeln = <all>-vbeln
               posnr = <all>-posnr binary search.
    if sy-subrc = 0.
      loop at lt_last_do assigning field-symbol(<last_do>) from sy-tabix.
        if <last_do>-vbeln <> <all>-vbeln or <last_do>-posnr <> <all>-posnr.
          exit.
        endif.
        gt_list-kwmeng_cmpl = gt_list-kwmeng_cmpl + <last_do>-lfimg.
      endloop.
    endif.

    gt_list-kwmeng_open = gt_list-kwmeng - gt_list-kwmeng_cmpl. " 수량(잔여)
    gt_list-netwr_open  = gt_list-kwmeng_open * gt_list-netpr.  " 금액(잔여)

    "-- 원화로 변경함 ([최적화] 통화가 이미 KRW인 경우 불필요한 서브루틴 호출 배제)
    gt_list-waerk_krw      = 'KRW'.

    if gt_list-waerk = 'KRW'.
      gt_list-netpr_krw      = gt_list-netpr.
      gt_list-netwr_krw      = gt_list-netwr.
      gt_list-netwr_krw_open = gt_list-netwr_open.
    else.
      perform convert_currency  using    gt_list-prsdt
                                         gt_list-waerk
                                         gt_list-waerk_krw
                                         gt_list-netpr
                                         gt_list-kursk
                                changing gt_list-netpr_krw.

      perform convert_currency  using    gt_list-prsdt
                                         gt_list-waerk
                                         gt_list-waerk_krw
                                         gt_list-netwr
                                         gt_list-kursk
                                changing gt_list-netwr_krw.

      perform convert_currency  using    gt_list-prsdt
                                         gt_list-waerk
                                         gt_list-waerk_krw
                                         gt_list-netwr_open
                                         gt_list-kursk
                                changing gt_list-netwr_krw_open.
    endif.

    if <all>-lifsp = 'G1' or <all>-fixmg = 'X'.
      gt_list-os_type = 'SM'.
    else.
      gt_list-os_type = 'OM'.
    endif.

    gt_list-do_open     = gt_list-kwmeng_open.                  " 미출고수량

    "-- do로 데이터 추가 ([최적화] BINARY SEARCH + FROM sy-tabix로 선형 전체 스캔 제거)
    read table lt_do transporting no fields
      with key vbeln = <all>-vbeln
               posnr = <all>-posnr binary search.
    if sy-subrc = 0.
      "-- 당월출하와 open DO만 있음
      loop at lt_do assigning field-symbol(<do>) from sy-tabix.
        if <do>-vbeln <> <all>-vbeln or <do>-posnr <> <all>-posnr.
          exit.
        endif.

        gt_list-do_pick   += <do>-pikmg.             " 피킹 수량

        if gt_list-pstyv = 'ZSCR'.   "소재는 (kosta)피킹상태로 출고를 판단한다.
          <do>-wbsta = <do>-kostk.
        endif.

        if gt_list-wbsta is initial.
          gt_list-wbsta     = <do>-wbsta.            " 출고현황
        elseif gt_list-wbsta > <do>-wbsta.
          gt_list-wbsta     = <do>-wbsta.            " 출고현황
        endif.

        if gt_list-do_wadat_ist < <do>-wadat_ist.
          gt_list-do_wadat_ist  = <do>-wadat_ist.    " 출고일
        endif.
        if <do>-wbsta = 'C'.
          gt_list-do_m0_gi      += <do>-lfimg.       " 당월출하 수량
          gt_list-do_m0_gi_qty  += <do>-lfimg.       " 당월전기 수량
          gt_list-do_m0_gi_amt  += gt_list-netpr_krw * <do>-lfimg. " 단가 * 당월 출하수량
          gt_list-do_open       -= <do>-lfimg.       " open에서 당월출하수량을 빼면 미출하
        endif.

        "-- 적송납품 [적송처리]
        if ( <do>-wbsta <> 'C' and <do>-lfart = 'ZLF3' ) or
           ( gt_list-auart = 'ZEXE' and <do>-zbcf = 'E' ).       "수출적송
          gt_list-trans_qty  += <do>-lfimg.   "적송 수량
          gt_list-trans_amt  += <do>-lfimg * gt_list-netpr_krw.   "적송 금액
        endif.

      endloop.
    endif.

    "-- 납품일자 이내이거나 납품완료된 건만 보여준다.
    if gt_list-edatu in gr_edatu or gt_list-wbsta = 'C' or gt_list-wbsta = 'B'.
      "OK
    else.
      continue..
    endif.

    clear : lv_kwmeng.
    if gt_list-vrkme is not initial and gt_list-vrkme <> gt_list-meins.
      call function 'FCO_CONVERT_TO_BASE_UNIT'
        exporting
          i_matnr = gt_list-matnr
          i_quant = gt_list-kwmeng
          i_meinh = gt_list-vrkme
          i_plnme = gt_list-vrkme
          i_umrez = 1
          i_umren = 1
        importing
          e_quant = lv_kwmeng.

      gt_list-kwmeng_m  = lv_kwmeng. " 기본단위 수량
    else.
      gt_list-kwmeng_m  = gt_list-kwmeng. " 기본단위 수량
      lv_kwmeng         = gt_list-kwmeng.
    endif.

    "-- 비철 수량 ([최적화] FROM sy-tabix + EXIT로 순회 범위 최소화)
    "-- 판매단위와 기본단위가 상이할 경우 기본단위로 판매수량을 변환한다.
    read table gt_tkgw with key matnr = gt_list-matnr
                                werks = gt_list-werks
                                binary search.
    if sy-subrc = 0.

      loop at gt_tkgw from sy-tabix.
        if gt_tkgw-matnr <> gt_list-matnr or gt_tkgw-werks <> gt_list-werks.
          exit.
        endif.

        clear lv_tmpqty.
        if not gt_tkgw-kgu is initial.
          lv_tmpqty  = ( gt_tkgw-kgw * lv_kwmeng ) / gt_tkgw-kgu.
        endif.

        case gt_tkgw-nes.
          when 'CU'.
            gt_list-so_cu   = lv_tmpqty.
            gt_list-cu_unit = gt_tkgw-bme.
          when 'AL'.
            gt_list-so_al   = lv_tmpqty.
            gt_list-al_unit = gt_tkgw-bme.
          when 'FI'.
            gt_list-so_fi   = lv_tmpqty.
            gt_list-fi_unit = gt_tkgw-bme.
        endcase.

      endloop.

    endif.

    "-- 잔여 비철
    if gt_list-kwmeng is not initial.
      gt_list-cu_open = gt_list-so_cu * gt_list-kwmeng_open / gt_list-kwmeng.
      gt_list-al_open = gt_list-so_al * gt_list-kwmeng_open / gt_list-kwmeng.
      gt_list-fi_open = gt_list-so_fi * gt_list-kwmeng_open / gt_list-kwmeng.
    endif.

    "-- 납품 status
    if <all>-lfrel <> 'X' or <all>-absta = 'C'.
      gt_list-wbsta = ''.
    else.
      data(lv_open) = gt_list-kwmeng_open - gt_list-do_m0_gi.

      if gt_list-kwmeng_open = gt_list-do_m0_gi. "잔여수량이 당월에 다 빠짐
        gt_list-wbsta = 'C'.
      elseif gt_list-do_m0_gi > 0. " 당월에 일부만 빠짐
        gt_list-wbsta = 'B'.
      else.
        gt_list-wbsta = 'A'.  " 당월에 출하가 없음
      endif.
    endif.

    append gt_list.

  endloop.


  if pa_bstkd is not initial.
    delete gt_list where bstkd_e <> pa_bstkd. " PO번호
  endif.
  if so_wbstk[] is not initial.
    delete gt_list where wbsta not in so_wbstk. "status
  endif.


endform.
*&---------------------------------------------------------------------*
*& Form set_date_range
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form set_date_range .


  data: lv_date      type sy-datum,
        lv_first_day type sy-datum,
        lv_last_day  type sy-datum.

  if ra1 = 'X'.

* 당월 1일
    concatenate sy-datum(6) '01'
           into lv_first_day.

* 당월 말일
    call function 'RP_LAST_DAY_OF_MONTHS'
      exporting
        day_in            = sy-datum
      importing
        last_day_of_month = lv_last_day.

  elseif ra2 = 'X'.

    concatenate sy-datum(6) '01'
           into lv_date.

* 당월 말일
    call function 'RP_LAST_DAY_OF_MONTHS'
      exporting
        day_in            = lv_date
      importing
        last_day_of_month = lv_date.

* 차월 1일 계산
    lv_first_day = lv_date.
    add 1 to lv_first_day.

* 차월 말일
    call function 'RP_LAST_DAY_OF_MONTHS'
      exporting
        day_in            = lv_first_day
      importing
        last_day_of_month = lv_last_day.

  endif.

  clear so_edatu[].

  so_edatu-sign   = 'I'.
  so_edatu-option = 'BT'.
  so_edatu-low    = lv_first_day.
  so_edatu-high   = lv_last_day.
  append so_edatu.

endform.
*&---------------------------------------------------------------------*
*& Form init_alv_0100
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
*& Form set_variant_handle
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_SENDER
*&      <-- LV_HANDL
*&---------------------------------------------------------------------*
form set_variant_handle  using po_sender type ref to cl_gui_alv_grid
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
*& Form CONVERT_CURRENCY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_WAERK
*&      --> GT_LIST_WAERK_KRW
*&      --> GT_LIST_NETPR
*&      --> <ALL>_KURSK
*&      <-- GT_LIST_NETPR_KRW
*&---------------------------------------------------------------------*
form convert_currency  using    pv_prsdt
                                pv_waerk
                                pv_waerk_krw
                                pv_amt
                                pv_kursk
                       changing pv_amt_krw.

  data: lv_foreign_amount type bseg-dmbtr value '1000.00', " 외화 금액 (예: 1,000 USD)
        lv_local_amount   type bseg-dmbtr,                 " 변환된 로컬 금액 (KRW)
        lv_exchange_rate  type tcurr-ukurs.                " 적용된 환율

  if pv_waerk = pv_waerk_krw.
    pv_amt_krw = pv_amt.
  endif.

  lv_foreign_amount = pv_amt.
  lv_exchange_rate  = pv_kursk.

  call function 'CONVERT_TO_LOCAL_CURRENCY'
    exporting
      date             = pv_prsdt        " 기준 일자
      foreign_currency = pv_waerk           " 출발 통화 (From)
      local_currency   = pv_waerk_krw        " 도착 통화 (To)
      foreign_amount   = lv_foreign_amount
      type_of_rate     = 'M'
      rate             = lv_exchange_rate
    importing
      local_amount     = lv_local_amount
    exceptions
      no_rate_found    = 1
      overflow         = 2
      no_factors_found = 3
      no_spread_found  = 4
      derived_2_times  = 5
      others           = 6.

  if sy-subrc = 0.
    pv_amt_krw = lv_local_amount.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form conversion_mat_unit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_MATNR
*&      --> LT_INSPECTION_MEINS
*&      --> LT_INSPECTION_LENGTH
*&      --> GT_LIST_VRKME
*&      <-- LT_INSPECTION_LENGTH
*&---------------------------------------------------------------------*
form conversion_mat_unit  using    pv_matnr
                                   pv_fr_meins
                                   pv_in_qty
                                   pv_to_meins
                          changing pv_out_qty.

  data: lv_matnr  type matnr value '000000000000000100',
        lv_in_me  type meins value 'BOX',
        lv_out_me type meins value 'EA',
        lv_menge  type menge_d value '10.000',
        lv_result type menge_d.

  check pv_fr_meins <> pv_to_meins.
  if pv_in_qty = 0.
    pv_out_qty = pv_in_qty.
    exit.
  endif.


  lv_matnr  = pv_matnr.
  lv_in_me  = pv_fr_meins.
  lv_out_me = pv_to_meins.
  lv_menge  = pv_in_qty.

  call function 'MD_CONVERT_MATERIAL_UNIT'
    exporting
      i_matnr              = lv_matnr
      i_in_me              = lv_in_me
      i_out_me             = lv_out_me
      i_menge              = lv_menge
    importing
      e_menge              = lv_result
    exceptions
      error_in_application = 1
      error                = 2
      others               = 3.

  if sy-subrc = 0.
    pv_out_qty = lv_result.
  else.
    "    write: / '단위 변환 실패 (sy-subrc:', sy-subrc, ')'.
  endif.


endform.
*&---------------------------------------------------------------------*
*& Form conversion_mat_unit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_MATNR
*&      --> LT_INSPECTION_MEINS
*&      --> LT_INSPECTION_LENGTH
*&      --> GT_LIST_VRKME
*&      <-- LT_INSPECTION_LENGTH
*&---------------------------------------------------------------------*
form conversion_lenth_unit  using  pv_in_qty
                                   pv_length
                                   pv_mill_length
                          changing pv_out_qty.

  data : lv_int type i.

  if pv_mill_length > 0.

    lv_int = trunc( pv_in_qty / pv_mill_length ).
    pv_out_qty = lv_int * pv_length.

  endif.


endform.

*&---------------------------------------------------------------------*
*& Form SET_PRODUCTION_QUANTITY_TOTAL
*&---------------------------------------------------------------------*
*& 개요   : 생산수량 및 공정 진척 현황 단일 통합 추출 루틴 (구문 에러 완벽 해결)
*& 설명   : ZGTPP_PROD_STATUS_REF_SO, ZGTPP_GET_JOJANG, 수행 PERFORM 및
*&          생산수량 집계 로직을 하나의 고속 PERFORM으로 완전 통합
*& 호출   : PERFORM SET_PRODUCTION_QUANTITY_TOTAL.
*& 전제   : 전역 테이블 GT_LIST (VBELN, POSNR, MATNR, VRKME 필수)
*& 반영   : GT_LIST의 PROD_GONG_CD, PROD_QTY, PROD_DATE,
*&                 LSTOCK, LCUT_PLAN, LCUT_COMP, LCUT_DATS
*&---------------------------------------------------------------------*
form set_production_quantity_total.

  check gt_list[] is not initial.

*----------------------------------------------------------------------
* 0. 대상 판매오더 Key 목록 추출
*----------------------------------------------------------------------
  types: begin of ty_so_key,
           vbeln type vbeln_va,
           posnr type posnr_va,
           matnr type matnr,
           vrkme type vrkme,
         end of ty_so_key.
  data: lt_so_keys type standard table of ty_so_key with empty key.

  lt_so_keys = corresponding #( gt_list[] ).
  sort lt_so_keys by vbeln posnr.
  delete adjacent duplicates from lt_so_keys comparing vbeln posnr.

*----------------------------------------------------------------------
* 공정 상세 통합 내부 테이블 정의
*----------------------------------------------------------------------
*  types: begin of ty_prod_detail,
*           vbeln    type vbeln_va,
*           posnr    type posnr_va,
*           sequance type numc4,
*           gong_cd  type zgtpps1014-gong_cd,
*           psmng    type zgtpps1014-psmng,
*           wemng    type zgtpps1014-wemng,
*           meins    type meins,
*           status   type zgtpps1014-status,
*           pldat    type dats,
*           prdat    type dats,
*           charg    type charg_d,
*         end of ty_prod_detail.
  data: lt_detail type standard table of ty_prod_detail.

*======================================================================
* 1. 절단/할당 오더 데이터 일괄 조회 (Bulk Select)
*======================================================================
  select zt01~vbeln, zt01~posnr, zt01~werks, zt01~weleng,
         zt01~zassign_no,  zt02~zassign_item, zt02~zord_type,
         zt02~f_charg, zt02~zcut_cnt,
         zt03~zcut_ord_no, zt03~zcut_ord_item, zt03~zcut_mblnr, zt03~zcut_mjahr,
         zt03~crdat, zt03~zcut_len
    from zgtppt2170 as zt01
    join zgtppt2180 as zt02
      on zt01~zassign_no eq zt02~zassign_no
    left join zgtppt2190 as zt03
      on zt02~zassign_no   eq zt03~zassign_no
     and zt02~zassign_item eq zt03~zassign_item
     and zt03~loekz        eq @space
     and zt03~sobkz        ne @space
     for all entries in @lt_so_keys
   where zt01~loekz        ne 'X'
     and zt01~vbeln        eq @lt_so_keys-vbeln
     and zt01~posnr        eq @lt_so_keys-posnr
     and zt01~zassign_type ne 'PC'
     and zt02~zord_type    ne @zgtpp_if_const=>gc_zord_type-c9
    into table @data(lt_assign).

  if lt_assign is not initial.
    " MATDOC 일괄 사전 조회 (루프 내 개별 조회 방지)
    types: begin of ty_mblnr_key,
             mblnr type matdoc-mblnr,
             mjahr type matdoc-mjahr,
           end of ty_mblnr_key.
    data: lt_mblnr_keys type standard table of ty_mblnr_key with empty key.

    lt_mblnr_keys = value #( for ls_asn in lt_assign
                             where ( zcut_mblnr is not initial and zcut_mjahr is not initial )
                             ( mblnr = ls_asn-zcut_mblnr mjahr = ls_asn-zcut_mjahr ) ).
    sort lt_mblnr_keys by mblnr mjahr.
    delete adjacent duplicates from lt_mblnr_keys comparing mblnr mjahr.

    if lt_mblnr_keys is not initial.
      select mblnr, mjahr, erfmg, budat, erfme
        from matdoc
         for all entries in @lt_mblnr_keys
       where mblnr eq @lt_mblnr_keys-mblnr
         and mjahr eq @lt_mblnr_keys-mjahr
        into table @data(lt_matdoc_assign).
      sort lt_matdoc_assign by mblnr mjahr.
    endif.

    " 절단(CT) 및 할당(ST) 레코드 변환
    sort lt_assign by vbeln posnr zassign_no zassign_item zcut_ord_no zcut_ord_item.

    loop at lt_assign into data(ls_key)
                      group by ( vbeln        = ls_key-vbeln
                                 posnr        = ls_key-posnr
                                 zassign_no   = ls_key-zassign_no
                                 zassign_item = ls_key-zassign_item
                                 zord_type    = ls_key-zord_type )
                      into data(lt_grp).

      if lt_grp-zord_type eq zgtpp_if_const=>gc_zord_type-c1. " 절단(CT)
        data(lv_seq_ct) = 0.
        loop at group lt_grp into data(ls_ct).
          lv_seq_ct += 1.
          data(lv_erfmg) = conv menge_d( 0 ).
          data(lv_budat) = conv budat( '00000000' ).
          data(lv_erfme) = conv meins( space ).

          if ls_ct-zcut_mblnr is not initial.
            read table lt_matdoc_assign into data(ls_mda)
              with key mblnr = ls_ct-zcut_mblnr
                       mjahr = ls_ct-zcut_mjahr binary search.
            if sy-subrc eq 0.
              lv_erfmg = ls_mda-erfmg.
              lv_budat = ls_mda-budat.
              lv_erfme = ls_mda-erfme.
            endif.
          endif.

          append value #( vbeln    = ls_ct-vbeln
                          posnr    = ls_ct-posnr
                          sequance = lv_seq_ct
                          gong_cd  = 'CT'
                          psmng    = ls_ct-zcut_len
                          wemng    = lv_erfmg
                          meins    = lv_erfme
                          status   = cond #( when ls_ct-zcut_mblnr is initial then text-t13 else text-t11 )
                          pldat    = ls_ct-crdat
                          prdat    = lv_budat
                          charg    = ls_ct-f_charg ) to lt_detail.
        endloop.

      else. " 정재고/주문할당(ST)
        data(lv_seq_st) = 0.
        loop at group lt_grp into data(ls_st).
          lv_seq_st += 1.
          read table lt_so_keys into data(ls_so_u) with key vbeln = ls_st-vbeln posnr = ls_st-posnr binary search.
          data(lv_def_u) = cond meins( when sy-subrc = 0 then ls_so_u-vrkme else space ).

          append value #( vbeln    = ls_st-vbeln
                          posnr    = ls_st-posnr
                          sequance = lv_seq_st
                          gong_cd  = 'ST'
                          psmng    = ls_st-weleng * ls_st-zcut_cnt
                          status   = text-t14
                          charg    = ls_st-f_charg
                          meins    = lv_def_u ) to lt_detail.
        endloop.
      endif.
    endloop.
  endif.

*======================================================================
* 2. 조장구성표 및 생산오더 체인 일괄 조회 및 고속 추적
*======================================================================
  " 조장 관리 대상 여부 확인
  select zt01~vbeln, zt01~posnr
    from @lt_so_keys as zt01
    join zgtppt2000  as zt02
      on zt01~vbeln   eq zt02~ordno
     and zt01~posnr   eq zt02~posnr
     and zt02~zstatus ne 'D'
    into table @data(lt_t2000).

  if lt_t2000 is not initial.
    sort lt_t2000 by vbeln posnr.

    " [구문 에러 해결] FOR ALL ENTRIES 타입 및 길이 일치용 구조체 정의
    types: begin of ty_dmord_key,
             dmord  type zgtppt2010-dmord,
             dmline type zgtppt2010-dmline,
           end of ty_dmord_key.
    data: lt_dmord_keys type standard table of ty_dmord_key with empty key.

    lt_dmord_keys = value #( for ls_t in lt_t2000
                             ( dmord  = ls_t-vbeln
                               dmline = ls_t-posnr ) ).
    sort lt_dmord_keys by dmord dmline.
    delete adjacent duplicates from lt_dmord_keys comparing dmord dmline.

    " 조장 구성표 모수 일괄 조회 (명시적 테이블 선언)
    data: lt_mosu_all type standard table of zgtppt2010.

    select *
      from zgtppt2010
       for all entries in @lt_dmord_keys
     where dmord   eq @lt_dmord_keys-dmord
       and dmline  eq @lt_dmord_keys-dmline
       and dmordty eq 'SO'
      into table @lt_mosu_all.

    if lt_mosu_all is not initial.
      " [구문 에러 해결] GRPNR 전용 구조체 테이블 정의
      types: begin of ty_grpnr_key,
               grpnr type zgtppt2010-grpnr,
             end of ty_grpnr_key.
      data: lt_grpnr_keys type standard table of ty_grpnr_key with empty key.

      lt_grpnr_keys = value #( for ls_m in lt_mosu_all ( grpnr = ls_m-grpnr ) ).
      sort lt_grpnr_keys by grpnr.
      delete adjacent duplicates from lt_grpnr_keys comparing grpnr.

      " 체인 데이터 전체 일괄 사전 조회
      data: lt_2010_all type standard table of zgtppt2010.

      select *
        from zgtppt2010
         for all entries in @lt_grpnr_keys
       where grpnr eq @lt_grpnr_keys-grpnr
        into table @lt_2010_all.
      sort lt_2010_all by grpnr.

      " 메모리 기반 고속 체인 추적 (PRD 생산오더만 추출)
      types: begin of ty_prd_order,
               vbeln        type vbeln_va,
               posnr        type posnr_va,
               gong_cd      type zgtpps1014-gong_cd,
               gong_seq     type numc4,
               ordnr        type aufnr,
               posnr_jojang type numc4,
               posnr_afpo   type afpo-posnr,
               ordty        type char3,
             end of ty_prd_order.
      data: lt_result_orders type standard table of ty_prd_order,
            lt_total_prd     type standard table of ty_prd_order,
            lt_2010          type standard table of zgtppt2010,
            lt_dev_2010      type standard table of zgtppt2010,
            lt_pre_2010      type standard table of zgtppt2010.

      loop at lt_t2000 into data(ls_t2k).
        loop at lt_mosu_all into data(ls_mosu) where dmord = ls_t2k-vbeln and dmline = ls_t2k-posnr.
          refresh: lt_result_orders, lt_2010, lt_dev_2010.

          " [구문 에러 해결] LS_A 대신 고유 변수명 LS_CHAIN 사용
          loop at lt_2010_all into data(ls_chain) where grpnr = ls_mosu-grpnr.
            append ls_chain to lt_2010.
          endloop.

          append ls_mosu to lt_dev_2010.

          do.
            refresh lt_pre_2010.
            loop at lt_dev_2010 into data(ls_dev).
              loop at lt_2010 into data(ls_20) where gong_seq < ls_dev-gong_seq
                                                 and dmord    = ls_dev-ordnr
                                                 and dmline   = ls_dev-posnr
                                                 and dmordty  = ls_dev-ordty.
                append ls_20 to lt_pre_2010.
              endloop.

              loop at lt_2010 into ls_20 where gong_seq < ls_dev-gong_seq
                                           and ordnr    = ls_dev-reord
                                           and posnr    = ls_dev-reline
                                           and ordty    = ls_dev-reordty.
                if ls_20-dmord = ls_dev-ordnr and ls_20-dmline = ls_dev-posnr and ls_20-dmordty = ls_dev-ordty.
                else.
                  loop at lt_2010 into data(ls_pre) where gong_seq < ls_dev-gong_seq
                                                      and dmord    = ls_20-dmord
                                                      and dmline   = ls_20-dmline
                                                      and dmordty  = ls_20-dmordty.
                    append ls_pre to lt_pre_2010.
                  endloop.
                endif.
              endloop.
            endloop.

            sort lt_pre_2010 by ordnr posnr ordty.
            delete adjacent duplicates from lt_pre_2010 comparing ordnr posnr ordty.

            loop at lt_dev_2010 into ls_dev.
              if ls_dev-ordty = 'REF'.
                read table lt_result_orders transporting no fields with key ordnr = ls_dev-ordnr.
                if sy-subrc eq 0.
                  continue.
                else.
                  append value #( vbeln        = ls_t2k-vbeln
                                  posnr        = ls_t2k-posnr
                                  gong_cd      = ls_dev-gong_cd
                                  gong_seq     = ls_dev-gong_seq
                                  ordnr        = ls_dev-ordnr
                                  posnr_jojang = '0001'
                                  posnr_afpo   = '0001'
                                  ordty        = 'PRD' ) to lt_result_orders.
                  continue.
                endif.
              endif.

              if ls_dev-ref_tandem = 'X' or ls_dev-ordty = 'PO'.
                continue.
              endif.

              " POSNR_AFPO에 4자리 품목번호 미리 정규화 매핑
              data(lv_afpo_pos) = cond afpo-posnr( when strlen( ls_dev-posnr ) >= 4
                                                   then substring( val = ls_dev-posnr off = strlen( ls_dev-posnr ) - 4 len = 4 )
                                                   else conv #( ls_dev-posnr ) ).

              append value #( vbeln        = ls_t2k-vbeln
                              posnr        = ls_t2k-posnr
                              gong_cd      = ls_dev-gong_cd
                              gong_seq     = ls_dev-gong_seq
                              ordnr        = ls_dev-ordnr
                              posnr_jojang = ls_dev-posnr
                              posnr_afpo   = lv_afpo_pos
                              ordty        = ls_dev-ordty ) to lt_result_orders.
            endloop.

            if lt_pre_2010[] is initial.
              exit.
            endif.

            refresh lt_dev_2010.
            append lines of lt_pre_2010 to lt_dev_2010.
          enddo.

          append lines of lt_result_orders to lt_total_prd.
        endloop.
      endloop.

      " 생산오더 정보 (AFPO, AFKO) 일괄 조회 및 매핑
      if lt_total_prd is not initial.
        delete lt_total_prd where ordty ne 'PRD'.
        sort lt_total_prd by ordnr posnr_afpo.
        delete adjacent duplicates from lt_total_prd comparing ordnr posnr_afpo.

        select a~vbeln, a~posnr, a~gong_seq, a~gong_cd,
               afpo~meins,
               sum( afpo~psmng ) as psmng,
               sum( afpo~wemng ) as wemng,
               max( afpo~ltrmi ) as ltrmi,
               min( afko~gstrp ) as gstrp
          from @lt_total_prd as a
          join afpo on afpo~aufnr eq a~ordnr
                   and afpo~posnr eq a~posnr_afpo
          join afko on afko~aufnr eq afpo~aufnr
         where a~ordty eq 'PRD'
         group by a~vbeln, a~posnr, a~gong_seq, a~gong_cd, afpo~meins
         order by a~vbeln, a~posnr, a~gong_seq, a~gong_cd
          into table @data(lt_jojang_res).

        loop at lt_jojang_res into data(ls_jr).
          append value #( vbeln    = ls_jr-vbeln
                          posnr    = ls_jr-posnr
                          sequance = ls_jr-gong_seq
                          gong_cd  = ls_jr-gong_cd
                          psmng    = ls_jr-psmng
                          wemng    = ls_jr-wemng
                          meins    = ls_jr-meins
                          pldat    = ls_jr-gstrp
                          prdat    = ls_jr-ltrmi ) to lt_detail.
        endloop.
      endif.
    endif.
  endif.

*======================================================================
* 3. Single Unit Batch 정재고(ST) 재고 검증 및 CT 전환
*======================================================================
  types: begin of ty_st_chk,
           vbeln    type vbeln_va,
           posnr    type posnr_va,
           sequance type numc4,
           charg    type charg_d,
           psmng    type menge_d,
         end of ty_st_chk.
  data: lt_st_chk type standard table of ty_st_chk with empty key.

  lt_st_chk = value #( for ls_d in lt_detail
                       where ( gong_cd = 'ST' and charg is not initial )
                       ( vbeln    = ls_d-vbeln
                         posnr    = ls_d-posnr
                         sequance = ls_d-sequance
                         charg    = ls_d-charg
                         psmng    = ls_d-psmng ) ).

  if lt_st_chk is not initial.
    sort lt_st_chk by vbeln posnr charg.
    delete adjacent duplicates from lt_st_chk comparing vbeln posnr charg.

    select a~vbeln, a~posnr, a~psmng, a~sequance, b~werks, b~matnr, a~charg
      from @lt_st_chk as a
      join vbap as b on a~vbeln eq b~vbeln and a~posnr eq b~posnr
      join marc as c on b~matnr eq c~matnr and b~werks eq c~werks
     where c~dpcbt eq 'C'
      into table @data(lt_single_chk).

    if lt_single_chk is not initial.
      " Sales Order Stock (MSKA) 일괄 조회
      select a~vbeln, a~posnr, a~matnr, a~charg, sum( b~kalab ) as kalab
        from @lt_single_chk as a
        join mska as b on a~vbeln eq b~vbeln and a~posnr eq b~posnr and a~charg eq b~charg
       group by a~vbeln, a~posnr, a~matnr, a~charg
        into table @data(lt_mska_chk).
      sort lt_mska_chk by vbeln posnr charg.

      " Plant Stock (MCHB) 일괄 조회
      select a~matnr, a~werks, a~charg, sum( b~clabs ) as clabs
        from @lt_single_chk as a
        join mchb as b on a~matnr eq b~matnr and a~charg eq b~charg and a~werks eq b~werks
       where b~clabs gt 0
       group by a~matnr, a~werks, a~charg
        into table @data(lt_mchb_chk).
      sort lt_mchb_chk by matnr werks charg.

      " 재고 불일치 건 ST -> CT 전환
      loop at lt_single_chk assigning field-symbol(<ls_sc>).
        read table lt_mska_chk transporting no fields
          with key vbeln = <ls_sc>-vbeln
                   posnr = <ls_sc>-posnr
                   charg = <ls_sc>-charg binary search.

        if sy-subrc ne 0.
          read table lt_mchb_chk into data(ls_mchb_c)
            with key matnr = <ls_sc>-matnr
                     werks = <ls_sc>-werks
                     charg = <ls_sc>-charg binary search.

          if sy-subrc ne 0 or <ls_sc>-psmng ne ls_mchb_c-clabs.
            loop at lt_detail assigning field-symbol(<ls_dt>)
                 where vbeln    = <ls_sc>-vbeln
                   and posnr    = <ls_sc>-posnr
                   and sequance = <ls_sc>-sequance
                   and charg    = <ls_sc>-charg
                   and gong_cd  = 'ST'.
              <ls_dt>-gong_cd = 'CT'.
              <ls_dt>-status  = '미진행'.
            endloop.
          endif.
        endif.
      endloop.
    endif.
  endif.

*======================================================================
* 지난달 말일까지 601로 나간것과, 951로 나간 물량은 제외한다. 배치기준
*======================================================================
  data : lt_batch type table of pkch.
  move-corresponding lt_detail[] to lt_batch[].
  sort lt_batch by charg.
  delete adjacent duplicates from lt_batch comparing charg.
  delete lt_batch where charg is initial.

  select a~matnr,
         a~mat_kdauf as vbeln,
         a~mat_kdpos as posnr,
         a~charg,
         a~meins,
         sum( case when a~shkzg = 'H' then menge
                   when a~shkzg = 'S' then - menge
                   else 0
              end ) as net_menge
*    from @lt_batch as a inner join matdoc as b on a~charg = b~charg
    from matdoc as a inner join @gt_so as b on a~mat_kdauf = b~vbeln
                                           and a~mat_kdpos = b~posnr
   where bwart in ( '601', '602', '951', '952' )
*     and cancelled = @space
     and (
           ( bwart in ( '601', '602' ) and budat <= @gv_lastmon_date )
        or ( bwart in ( '951', '952' ) )
     )
   group by a~matnr,
            a~mat_kdauf,
            a~mat_kdpos,
            a~charg,
            a~meins
    into table @data(lt_batch_mv).

  "-- 다른 so에 할당된 배치는 제외한다.
  select a~*
    from mska as a
   inner join @lt_batch as b on a~charg = b~charg
   where a~kalab > 0
     and a~vbeln <> ''
    into table @data(lt_mska).

  sort lt_batch_mv by vbeln posnr. "charg.
  sort lt_mska by vbeln posnr charg.


  "-- 배치가 나간 detail은 생산수량에서 제외함
  loop at lt_detail assigning field-symbol(<detail>)
                    where gong_cd = 'ST'.
    loop at lt_batch_mv assigning field-symbol(<mv>)
                        where vbeln = <detail>-vbeln
                          and posnr = <detail>-posnr.
      <detail>-psmng -= <mv>-net_menge.
    endloop.
  endloop.


  loop at lt_detail into data(ls_dtl).
    "-- 다른 so에 할당된 배치도 제외한다.
    read table lt_mska assigning field-symbol(<mska>)
                       with key vbeln = ls_dtl-vbeln
                                posnr = ls_dtl-posnr
                                charg = ls_dtl-charg
                           binary search.
    if sy-subrc = 0.
      if ls_dtl-vbeln = <mska>-vbeln and
          ls_dtl-posnr = <mska>-posnr.
      else.
        ls_dtl-charg = <mska>-charg.
        modify lt_detail from ls_dtl.
        "delete lt_detail.
      endif.
    endif.
  endloop.


*======================================================================
* 4. GT_LIST에 생산수량/일자 매핑 및 단위변환 집계 (단일 고속 루프)
*======================================================================
  sort lt_detail by vbeln posnr sequance descending.

  data: begin of lt_dbl_stock occurs 0,
          vbeln type vbeln,
          posnr type posnr,
          charg type charg_d,
          menge type menge_d,
        end of lt_dbl_stock.

  data: lv_psmng_c type zgtpps1014-psmng,
        lv_wemng_c type zgtpps1014-wemng.

  loop at gt_list assigning field-symbol(<ls_list>).

    " 생산 관련 필드 초기화
    clear: <ls_list>-prod_gong_cd, <ls_list>-prod_qty,   <ls_list>-prod_date,
           <ls_list>-lstock,       <ls_list>-lcut_plan,  <ls_list>-lcut_comp,
           <ls_list>-lcut_dats.

    read table lt_detail with key vbeln = <ls_list>-vbeln
                                  posnr = <ls_list>-posnr
                                  transporting no fields
                                  binary search.
    if sy-subrc = 0.
      data(lv_idx) = sy-tabix.

      loop at lt_detail into ls_dtl from sy-tabix.
        if ls_dtl-vbeln <> <ls_list>-vbeln or
           ls_dtl-posnr <> <ls_list>-posnr.
          exit.
        endif.

        if lv_idx = sy-tabix. " 최종생산 라인임
          "-- 생산이 완료/부분완료/미완료 구분
          <ls_list>-in_qty2 = ls_dtl-wemng.
          if ls_dtl-psmng <= ls_dtl-wemng or <ls_list>-kwmeng <= ls_dtl-wemng. "-- 완료
            <ls_list>-prod_cmpl = 'F'. "finished
          elseif ls_dtl-wemng > 0 and ls_dtl-psmng > ls_dtl-wemng . "-- 부분완료
            <ls_list>-prod_cmpl = 'P'. "partial finished
          else.
            <ls_list>-prod_cmpl = ''.
          endif.
        endif.

        " 1. 생산 공정 정보 추출 (ST, CT 제외 최초 1건 설정)
        if <ls_list>-prod_gong_cd is initial and
           ls_dtl-gong_cd <> 'CT' and
           ls_dtl-gong_cd <> 'ST' and
           ls_dtl-prdat   is not initial.
          <ls_list>-prod_gong_cd = ls_dtl-gong_cd. "공정
          <ls_list>-prod_qty     = ls_dtl-psmng.   "수량
          <ls_list>-prod_date    = ls_dtl-prdat.   "작업일자
        endif.

        " 2. 정재고(ST) 및 절단(CT) 수량/일자 집계
        if ls_dtl-gong_cd = 'ST' or
          ( ls_dtl-gong_cd = 'CT' and ls_dtl-pldat is not initial ).

          lv_psmng_c = ls_dtl-psmng.
          lv_wemng_c = ls_dtl-wemng.

          " 판매단위와 상이할 경우에만 단위 변환 수행
          if ls_dtl-meins <> <ls_list>-vrkme and ls_dtl-meins is not initial.
            perform conversion_mat_unit using    <ls_list>-matnr
                                                 ls_dtl-meins
                                                 lv_psmng_c
                                                 <ls_list>-vrkme
                                        changing lv_psmng_c.

            if ls_dtl-gong_cd = 'CT'.
              perform conversion_mat_unit using    <ls_list>-matnr
                                                   ls_dtl-meins
                                                   lv_wemng_c
                                                   <ls_list>-vrkme
                                          changing lv_wemng_c.
            endif.
          endif.

          " 수량 누적 및 최신 작업일자 반영
          if ls_dtl-gong_cd = 'ST'.
            <ls_list>-lstock     += lv_psmng_c. "정재고
            "-- lstcok에서 배치기준으로 maka에 있는 lsstock은 빼준다.
            read table lt_mska into data(ls_mska)
                     with key vbeln = ls_dtl-vbeln
                              posnr = ls_dtl-posnr
                              charg = ls_dtl-charg
                              binary search.
            if sy-subrc = 0.
              clear lt_dbl_stock.
              lt_dbl_stock-vbeln = ls_dtl-vbeln.
              lt_dbl_stock-posnr = ls_dtl-posnr.
              lt_dbl_stock-charg = ls_dtl-charg.
              lt_dbl_stock-menge = lv_psmng_c. "이 수량만큼 재고가 중복되므로 제외함
              append lt_dbl_stock.
            else.
*            <ls_list>-lstock_in += lv_psmng_c. "아직 재고로 입고안된 정재고
            endif.
          elseif ls_dtl-gong_cd = 'CT'.
            <ls_list>-lcut_plan  += lv_psmng_c. "절단지시
            <ls_list>-lcut_comp  += lv_wemng_c. "절단완료
            if <ls_list>-lcut_dats < ls_dtl-prdat.
              <ls_list>-lcut_dats = ls_dtl-prdat. "작업일자
            endif.
          endif.

        endif.

      endloop.
    endif.

  endloop.



endform.
*&---------------------------------------------------------------------*
*& Form add_quantity_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form add_quantity_data .

  data: lt_delvreq_truck_o like zgtmms4512 occurs 0 with header line,
        lt_purchase        like zgtsdsif1030 occurs 0 with header line,
        lt_inspection      like zgtsdsif1031 occurs 0 with header line.
  data: ls_login  type zsds_log_0000_go,
        ls_return type zsds_log_0001_go.
  data: lt_bill type standard table of zgtsdsif1024
                 with default key
                 with non-unique sorted key sec_key components vbeln posnr,
        ls_bill type zgtsdsif1024.


  check gt_list[] is not initial.

  move-corresponding gt_list[] to gt_so[].
  sort gt_so by vbeln posnr.
  delete adjacent duplicates from gt_so comparing vbeln posnr.


* 4) Get Delivery data.
  select a~iv_no,
         a~iv_seq,
         b~out_yn,
         b~out_date,
         a~lfimg,
         a~mtr_unit,
         c~vgbel as vbeln,
         c~vgpos as posnr,
         c~wbsta,
         b~truck_no
    from zlet0006 as a
   inner join zlet0005 as b on a~iv_no = b~iv_no
   inner join lips     as c on a~vbeln = c~vbeln
                           and a~posnr = c~posnr
     for all entries in @gt_list
   where c~vgbel        =  @gt_list-vbeln
     and c~vgpos        =  @gt_list-posnr
     and b~out_date     <= @gv_edatu  "통문도 최종 납기 이전까지만
     and b~iv_cancel_yn = ' '
     and b~iv_type      = 'A01'
    into table @data(lt_outdlv).


* 5) Get Delivery Request data.
  perform get_deliv_req_so_progress_go    tables   lt_delvreq_truck_o
                                          using    ls_login
                                          changing ls_return.

* 6) Get Billing data.
  perform get_billing_so_progress_go      tables   lt_bill
                                          changing ls_return.

* 7) 구매오더 / 검사요청
  perform get_purchase_so_progress_go     tables   lt_purchase
                                                   lt_inspection
                                          changing ls_return.

  " 구매요청 정보
  select a~vbeln, a~vbelp as posnr, b~matnr, b~ebeln
    from ebkn as a inner join eban as b
                   on a~banfn eq b~banfn
                   and a~bnfpo eq b~bnfpo
                   inner join @gt_so as c on a~vbeln = c~vbeln
                                          and a~vbelp = c~posnr
   where b~loekz eq @abap_false
     and b~blckd eq @abap_false
    into table @data(lt_preq).
  sort lt_preq by vbeln posnr matnr.
  delete adjacent duplicates from lt_preq comparing vbeln posnr matnr.


* 8) 생산오더: 진행현황, Lstock, link절단지시, link절단완료
  perform set_production_quantity_total.


* 9) 입고 데이터를 계산한다.
  perform calculate_in_stock_data.  " gt_lstock


*----- 조장과 조장수
  select *
    from zgtsd_cv_get_vcofso
     for all entries in @gt_list
   where vbeln = @gt_list-vbeln
     and posnr = @gt_list-posnr
    into table @data(lt_jojang).
  "-- LENGTH       FT 단위 조장
  "-- MILL_LENGTH   M 단위 조장

*----- 가온 데이터
  select a~matnr,
         a~atwrt as spart_gaon,
         b~clrtx as spart_gaon_nm
    from zgtsd_i_materialcharacteristic as a
    left outer join zgtedt6800 as b on b~spart_gaon = a~atwrt
     for all entries in @gt_list
   where a~matnr = @gt_list-matnr
     and a~atnam = 'MS-AUSP-ZSPART'
    into table @data(lt_gaon).


  sort lt_gaon by matnr.
  sort lt_jojang by vbeln posnr.
  sort lt_purchase by vbeln posnr.
  sort lt_delvreq_truck_o by vbeln posnr zdoc_date.
  sort gt_lstock by vbeln posnr.
  sort gt_mchb1 by matnr atwrt.

  data: lv_kunnr       type kunnr,
        lv_kwmeng_cmpl type kwmeng,
        lv_lcut_comp   type kwmeng.

  loop at gt_list.

    read table lt_jojang assigning field-symbol(<jojang>)
                              with key vbeln = gt_list-vbeln
                                       posnr = gt_list-posnr
                                       binary search.
    if sy-subrc = 0.
      gt_list-length        = <jojang>-length.       "VRKME 단위
      gt_list-factor        = <jojang>-factor.

      "-- 남품과 거부사유가 같이 있으면 조장수도 재계산해준다.
      if gt_list-abgru is not initial.
        read table gt_dlv_su into data(ls_dlv)
                             with key vbeln = gt_list-vbeln
                                      posnr = gt_list-posnr
                                      binary search.
        if sy-subrc = 0.
          gt_list-factor = <jojang>-factor * ls_dlv-dlvqty_su / ls_dlv-kwmeng.
        endif.
      endif.


      gt_list-mill_length   = <jojang>-mill_length.  "기본단위
      if gt_list-length <> 0.
        gt_list-factor_cmpl = gt_list-kwmeng_cmpl / gt_list-length.
      endif.
      gt_list-factor_open   = gt_list-factor - gt_list-factor_cmpl.
      gt_list-specno        = <jojang>-specno.
      gt_list-color         = <jojang>-color.
      gt_list-stripe_color  = <jojang>-stripe_color. "띠줄 색상
      gt_list-stripe_cnt    = <jojang>-stripe_cnt.   "띠줄 갯수
    endif.

    " 조장수가 없으면, 조장은 1로 세팅하고 조장수는 잔여수량을 넣는다.
    if gt_list-factor = 0.
      gt_list-factor      = gt_list-kwmeng_open.
      gt_list-factor_open = gt_list-kwmeng_open.
      gt_list-length      = 1.
    endif.

    "-- 거래명세서 생성일이 당월 인 전체 수량( SUM(ET_DELIVERYREQUEST_TRUCK_OEM_Items.LOADQTY)
    loop at lt_delvreq_truck_o where vbeln = gt_list-vbeln
                                  and posnr = gt_list-posnr
                                  and zdoc_date in so_edatu.
      gt_list-oem_load_qty       += lt_delvreq_truck_o-loadqty.
      gt_list-oem_last_load_dats  = lt_delvreq_truck_o-zdoc_date.
    endloop.

    gt_list-do_m0_factor     = gt_list-factor * gt_list-do_m0_gi / gt_list-kwmeng.

    loop at lt_outdlv into data(ls_outdlv)
                     where vbeln = gt_list-vbeln
                       and posnr = gt_list-posnr.
      "-- 통문
      if ls_outdlv-wbsta  = 'C' and ls_outdlv-out_yn = 'X'.
        " and ls_outdlv-out_date in so_edatu.
        if ls_outdlv-mtr_unit <> gt_list-vrkme.
          perform conversion_mat_unit  using    gt_list-matnr
                                                ls_outdlv-mtr_unit
                                                ls_outdlv-lfimg
                                                gt_list-vrkme
                                       changing ls_outdlv-lfimg.
        endif.
        gt_list-do_out_qty += ls_outdlv-lfimg.
      endif.
    endloop.

    "ET_BILLING_Items.FKDAT 청구일이 당월인 전체 수량( SUM(ET_DELIVERYORDER.LFIMG)
    loop at lt_bill into ls_bill
                    using key sec_key
                    where vbeln = gt_list-vbeln
                      and posnr = gt_list-posnr.
      if ls_bill-fkdat in so_edatu.
        gt_list-do_m0_bl_amt += ls_bill-fkimg * gt_list-netpr_krw.
      endif.
    endloop.

    "-- OEM 데이터
    if gt_list-lfrel = 'X'.
      read table lt_purchase with key vbeln = gt_list-vbeln
                                      posnr = gt_list-posnr
                                      binary search.
      if sy-subrc = 0.
*      OEM 일 때 (ET_SALESORDER_ITEM.OEMREL == "Y"),
*      주문 조장 * (검사결과 완료인 (ET_INSPECTION_Items.ZINSPRES == "C") ,
*        검사요청 수량 (ET_INSPECTION_Items.ZINSP_QTY)) // OEM_QTY => ISOEM ? LENGTH * (ZINSP_QTY ?? 0)
        data(lv_idx) = sy-tabix.

        loop at lt_inspection where vbeln = gt_list-vbeln
                                and posnr = gt_list-posnr
                                and zinspres = 'C'.
          if lt_inspection-vrkme <> gt_list-vrkme.
            perform conversion_mat_unit  using    gt_list-matnr
                                                  lt_inspection-meins
                                                  lt_inspection-length
                                                  gt_list-vrkme
                                         changing lt_inspection-length.
          endif.
          if lt_inspection-length = 0.
            lt_inspection-length = 1.
          endif.
          gt_list-oem_inspect_qty += lt_inspection-length * trunc( lt_inspection-zinsp_qty ).
        endloop.

        gt_list-oem_inspect_qty   = gt_list-oem_inspect_qty - gt_list-kwmeng_cmpl.
        if gt_list-oem_inspect_qty < 0.
          gt_list-oem_inspect_qty = 0.
        endif.

        gt_list-oem_load_vnd      = lt_purchase-lifnr.
        gt_list-oem_load_vnd_name = lt_purchase-vendor_name.

        gt_list-oemrel = 'PO'.  "구매오더

        loop at lt_purchase from lv_idx.
          if lt_purchase-vbeln <> gt_list-vbeln or lt_purchase-posnr <> gt_list-posnr.
            exit.
          else.
            data lv_po_menge_jojang type  bstmg.

            lv_po_menge_jojang = lt_purchase-po_menge.

            if lt_purchase-meins <> gt_list-vrkme.
              "-- 조장수를 구해서 계산함
              perform conversion_jojang_unit using  gt_list-matnr
                                                    lt_purchase-meins
                                                    lv_po_menge_jojang
                                                    gt_list-vrkme
                                                    gt_list-length
                                                    gt_list-mill_length
                                           changing lv_po_menge_jojang.

              perform conversion_mat_unit  using    gt_list-matnr
                                                    lt_purchase-meins
                                                    lt_purchase-po_menge
                                                    gt_list-vrkme
                                           changing lt_purchase-po_menge.
            endif.
            if lt_purchase-meins <> gt_list-vrkme.
              perform conversion_mat_unit  using    gt_list-matnr
                                                    lt_purchase-meins
                                                    lt_purchase-gr_menge
                                                    gt_list-vrkme
                                           changing lt_purchase-gr_menge.
            endif.

            gt_list-poqty       += lv_po_menge_jojang.
            gt_list-poqty_meins += lt_purchase-po_menge.
            gt_list-poqty_gr    += lt_purchase-gr_menge.
          endif.
        endloop.

      else.
        " 구매요청 정보
        read table lt_preq with key vbeln = gt_list-vbeln
                                    posnr = gt_list-posnr
                                    matnr = gt_list-matnr
                            binary search assigning field-symbol(<lfs_preq>).
        if sy-subrc = 0.
          gt_list-oemrel = 'PR'. "구매요청
        endif.
      endif.
    endif.

    "-- 입고 데이터 추가하기
    if gt_list-pstyv = 'ZSCR'. "소재용, 배치재고 관리용 자재

      gt_list-in_qty     = gt_list-do_m0_gi_qty.

      lv_kunnr = |{ gt_list-kunnr alpha = out }|.
      read table gt_mchb1 with key matnr = gt_list-matnr
                                   atwrt = lv_kunnr
                                   binary search.
      if sy-subrc = 0.
*        gt_list-in_qty    += gt_mchb1-clabs.
        if gt_mchb1-meins <> gt_list-vrkme.
          perform conversion_mat_unit  using    gt_list-matnr
                                                gt_mchb1-meins
                                                gt_mchb1-clabs
                                                gt_list-vrkme
                                       changing gt_mchb1-clabs.
        endif.
        gt_list-in_qty_po  = gt_mchb1-clabs.
        gt_list-in_qty_sum = gt_list-in_qty + gt_list-in_qty_po.
        gt_list-in_dats    = gt_mchb1-gidate.
      endif.
    else.
      "-- 입고 = 당월출하 + SO재고 + 정재고 + 절단요청수량, so와 정재고 중복은 제외
      read table gt_lstock into data(ls_lstock)
                           with key vbeln = gt_list-vbeln
                                    posnr = gt_list-posnr
                                    binary search.
      if sy-subrc = 0.
        gt_list-lcut_dats  = ls_lstock-lcut_dats.
        gt_list-lcut_plan  = ls_lstock-lcut_plan.
        gt_list-lcut_comp  = ls_lstock-lcut_comp.

        gt_list-lstock     = ls_lstock-lstock. "정재고

        if ls_lstock-lstock > 0. " 정재고가 있으면 413에서 빠지므로 절단지시수량을 사용함
          gt_list-in_qty     = gt_list-do_m0_gi_qty + ls_lstock-kalab
                             + ls_lstock-so_lstock  + ls_lstock-lcut_plan.
        else. " 정재고가 없으면 413로직에 안들어가므로 절단 open수량을 사용함
          " lcut_plan 수량을 사용하면 중복 수량이 될 수 있음
          gt_list-in_qty     = gt_list-do_m0_gi_qty + ls_lstock-kalab
                             + ls_lstock-so_lstock  + ls_lstock-lcut_open.
        endif.

        if gt_list-in_qty < 0.
          gt_list-in_qty = 0.
        endif.
        gt_list-in_qty_po  = ls_lstock-kalab_po.
        gt_list-in_qty_sum = gt_list-in_qty + gt_list-in_qty_po.
        gt_list-in_dats    = ls_lstock-in_dats.
      else.
        clear gt_list-lcut_dats.
        gt_list-lcut_plan  = 0.
        gt_list-lcut_comp  = 0.
        gt_list-lstock     = 0. "정재고
        gt_list-in_qty     = gt_list-do_m0_gi_qty.
        gt_list-in_qty_po  = 0.
        gt_list-in_qty_sum = gt_list-in_qty + gt_list-in_qty_po.
        clear gt_list-in_dats.
      endif.
    endif.

    if gt_list-kwmeng <> 0.
      gt_list-in_factor     = gt_list-factor * gt_list-in_qty     / gt_list-kwmeng.
      gt_list-in_factor_po  = gt_list-factor * gt_list-in_qty_po  / gt_list-kwmeng.
      gt_list-in_factor_sum = gt_list-factor * gt_list-in_qty_sum / gt_list-kwmeng.
    endif.

    read table lt_gaon into data(ls_gaon)
                           with key matnr = gt_list-matnr
                           binary search.
    if sy-subrc = 0.
      gt_list-spart_gaon    = ls_gaon-spart_gaon.
      gt_list-spart_gaon_nm = ls_gaon-spart_gaon_nm.
    endif.

    "-- link의 잔여수량을 재계산한다. 전월까지 완료수량을 감안한다.
    lv_kwmeng_cmpl = gt_list-kwmeng_cmpl. "전월까지 완료수량
    lv_lcut_comp   = gt_list-lcut_comp.

    perform calc_completed_qty  changing gt_list-poqty     lv_kwmeng_cmpl.
    perform calc_completed_qty  changing gt_list-lcut_comp lv_kwmeng_cmpl.
    perform calc_completed_qty  changing gt_list-lstock    lv_kwmeng_cmpl.

    "-- 계획수량 = 계획수량 - 완료수량 + 잔여완료수량
    gt_list-lcut_plan = gt_list-lcut_plan - lv_lcut_comp + gt_list-lcut_comp.

    "-- 통문도 완료수량은 제외한다.
    gt_list-do_out_qty = gt_list-do_out_qty - gt_list-kwmeng_cmpl.
    if gt_list-do_out_qty < 0.
      gt_list-do_out_qty = 0.
    endif.

    gt_list-in_qty_amt = gt_list-in_qty_sum * gt_list-netpr_krw.

    modify gt_list.

  endloop.


endform.
*&---------------------------------------------------------------------*
*& Form get_do_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_OPEN
*&      --> LT_DOLIST
*&---------------------------------------------------------------------*
form get_do_detail  tables  pt_do     structure lips
                            pt_detail type ty_do_tab.

  check pt_do[] is not initial.
  data(lt_do) = pt_do[].

  data : lt_detail type ty_do_tab,
         lt_batch  type ty_do_tab.

  clear: lt_detail[], lt_batch[].

  select a~vbeln as vbeln_vl,
         b~posnr as posnr_vl,
         b~uecha,
         b~vgbel as vbeln,
         b~vgpos as posnr,
         a~erdat,
         b~matnr,
           case a~vbtyp
             when 'T' then b~lfimg * -1
             else b~lfimg
           end as lfimg,
         b~wbsta,
         a~wadat,
         a~wadat_ist,
         b~bwart,
         a~lfart,
         a~kostk,  " 피킹 헤드
         b~kosta,  " 피킹 아이템
         case when b~kosta = 'C' or a~kostk = 'C' then b~lfimg
            else 0
         end as pikmg,
         a~vbtyp,
         c~pstyv as pstyv, " <-- vbap에서 넘어옴
         a~zbcf
    from likp as a
    inner join lips as b on a~vbeln = b~vbeln
    inner join @lt_do as c on b~vbeln = c~vbeln
                          and b~posnr = c~posnr
   into corresponding fields of table @lt_detail.

  modify lt_detail from value #( wbsta = 'C' )
                   transporting wbsta
                   where pstyv = 'ZSCR'
                     and kostk = 'C'
                     and wadat_ist is not initial.

  lt_batch[] = lt_detail[].

  delete lt_batch  where uecha is initial.
  delete lt_detail where uecha is not initial.

  "-- 배치수량을 sum한다.
  if lt_batch[] is not initial.
    sort lt_batch by vbeln_vl uecha.

    loop at lt_detail assigning field-symbol(<do>).
      read table lt_batch with key vbeln_vl = <do>-vbeln_vl
                                   uecha   = <do>-posnr_vl
                                   transporting no fields
                                   binary search.
      if sy-subrc = 0.
        loop at lt_batch from sy-tabix assigning field-symbol(<batch>).
          if <batch>-vbeln_vl <> <do>-vbeln_vl or <batch>-uecha <> <do>-posnr_vl.
            exit.
          endif.
          <do>-lfimg += <batch>-lfimg.
          <do>-pikmg += <batch>-pikmg.
        endloop.
      endif.
    endloop.
  endif.

  delete lt_detail where lfimg = 0.

  pt_detail[] = lt_detail[].

endform.
*&---------------------------------------------------------------------*
*& Form make_do_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_DOLIST
*&      --> LT_DOLAST
*&---------------------------------------------------------------------*
form make_do_data  tables   pt_do_dtl type ty_do_tab
                            pt_last_do type ty_do_tab.

  data : lt_open type table of lips,
         lt_gi   type table of lips,
         lt_last type table of lips,
         lt_do   type table of lips.
  data : lt_open_dtl type ty_do_tab,
         lt_gi_dtl   type ty_do_tab,
         lt_last_dtl type ty_do_tab.

  "-- do list를 가져온다.
  perform get_key_do_data tables lt_open  "-- open do
                                 lt_gi    "-- 당월 출하된 dO
                                 lt_last. "-- 2010 ~ 지난달까지 출하된 do

  "-- do 상세 정보를 가져온다.
  perform get_do_detail  tables  lt_open
                                 lt_open_dtl.
  perform get_do_detail  tables  lt_gi
                                 lt_gi_dtl.
  perform get_do_detail  tables  lt_last
                                 lt_last_dtl.

  "-- open / 당월 gi된 do만 collect함, 배치는 한 라인으로 정리함
  move-corresponding lt_open_dtl[] to pt_do_dtl[].
  move-corresponding lt_gi_dtl[]   to pt_do_dtl[] keeping target lines.

  "-- 지난달 gi된 do만 collect함
  move-corresponding lt_last_dtl[] to pt_last_do[].

endform.
*&---------------------------------------------------------------------*
*& Form calculate_in_stock_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form calculate_in_stock_data .


*----- 입고용: SO재고 데이터
  select a~vbeln, a~posnr,
         sum( case when a~lgort = '3497' or a~lgort = '3498' then kalab
                   else 0
              end ) as kalab_po,
         sum( case when a~lgort = '3497' or a~lgort = '3498' then 0
                   else kalab
              end ) as kalab,
         c~meins
    from mska as a inner join @gt_so as b on a~vbeln = b~vbeln
                                         and a~posnr = b~posnr
                   inner join mara as c on b~matnr = c~matnr
   where a~kalab > 0
    group by a~vbeln, a~posnr, c~meins
    into table @data(lt_mska).

*----- 입고용: 정조장 피킹용,
  select a~vbeln, a~posnr, "b~f_charg,
         sum( a~weleng * b~zcut_cnt ) as lstock,
         sum( a~weleng * b~zcut_cnt ) as so_lstock,
         a~vrkme
    from zgtppt2170 as a
    inner join zgtppt2180  as b on a~zassign_no = b~zassign_no
    inner join @gt_so as c on a~vbeln = c~vbeln
                          and a~posnr = c~posnr
   where b~zord_type <> 'C1'  " CUT가 아닌 오더만 필요함
     and a~loekz <> 'X'
   group by a~vbeln, a~posnr, a~vrkme "b~f_charg,
    into table @data(lt_lstock_in).


*----- 입고용: 413/414 입고 수량
  select a~matnr,
         a~werks,
         b~vbeln,
         b~posnr,
         a~charg,
         a~meins,
         sum( case when a~shkzg = 'H' then menge
                   when a~shkzg = 'S' then - menge
                   else 0
              end ) as net_menge
   from matdoc as a
        inner join @gt_so as b
        on ( a~kdauf = b~vbeln and a~kdpos = b~posnr )
   where bwart in ( '413', '414' )
*     and cancelled = ''
   group by a~matnr,
            a~werks,
            b~vbeln,
            b~posnr,
            a~charg,
            a~meins
    into table @data(lt_413).

  sort lt_413 by vbeln posnr.

*----- 입고용: lstock에서 413으로 입고된 수량을 제외한다.
  loop at lt_lstock_in into data(ls_in).
    loop at lt_413 into data(ls_413) where vbeln = ls_in-vbeln
                                        and posnr = ls_in-posnr.
      if ls_413-meins <> ls_in-vrkme.
        perform conversion_mat_unit  using    ls_413-matnr
                                              ls_413-meins
                                              ls_413-net_menge
                                              ls_in-vrkme
                                     changing ls_413-net_menge.
      endif.
      ls_in-so_lstock -= ls_413-net_menge.
    endloop.
    modify lt_lstock_in from ls_in.
  endloop.

*----- 절단 지시
  select a~vbeln, a~posnr,
         sum( b~zcut_len * b~zcut_cnt ) as qty,
         b~meins
    from zgtppt2170 as a
    inner join zgtppt2180  as e on a~zassign_no   = e~zassign_no
    inner join zgtppt2190  as b on e~zassign_no   = b~zassign_no
                               and e~zassign_item = b~zassign_item
    inner join @gt_so as c on a~vbeln = c~vbeln
                          and a~posnr = c~posnr
   where a~loekz <> 'X'
     and e~zord_type = 'C1'    " CUT만 필요함
     and b~sobkz     = 'E'     "SO로 지시
   group by a~vbeln, a~posnr, b~meins
    into table @data(lt_lcut_plan).

*---- 절단 OPEN, SO를 가지고 있어야함
  select a~vbeln, a~posnr,
         sum( b~zcut_len * b~zcut_cnt ) as qty,
         b~meins
    from zgtppt2170 as a
    inner join zgtppt2180  as e on a~zassign_no   = e~zassign_no
    inner join zgtppt2190  as b on e~zassign_no   = b~zassign_no
                               and e~zassign_item = b~zassign_item
    inner join @gt_so as c on a~vbeln = c~vbeln
                          and a~posnr = c~posnr
   where a~loekz <> 'X'
     and e~zord_type = 'C1'    " CUT만 필요함
     and b~sobkz     = 'E'     "SO로 지시
     and b~ztr_mblnr = @space "아직 완료안된 것
   group by a~vbeln, a~posnr, b~meins
    into table @data(lt_lcut_open).

*----- 절단 완료
  select a~vbeln, a~posnr,
         sum( b~zcut_len * b~zcut_cnt ) as qty,
         b~meins
    from zgtppt2170 as a
    inner join zgtppt2180  as e on a~zassign_no   = e~zassign_no
    inner join zgtppt2190  as b on e~zassign_no   = b~zassign_no
                               and e~zassign_item = b~zassign_item
    inner join @gt_so as c on a~vbeln = c~vbeln
                          and a~posnr = c~posnr
   where a~loekz <> 'X'
     and e~zord_type = 'C1'    " CUT만 필요함
     and b~sobkz     = 'E'     "SO로 지시
     and b~zcut_mblnr <> ''    "절단완료
   group by a~vbeln, a~posnr, b~meins
    into table @data(lt_lcut_cmpl).

*----- 절단 완료일
  select a~vbeln, a~posnr, max( f~budat ) as budat
    from zgtppt2170 as a
    inner join zgtppt2180  as e on a~zassign_no   = e~zassign_no
    inner join zgtppt2190  as b on e~zassign_no   = b~zassign_no
                               and e~zassign_item = b~zassign_item
    inner join @gt_so as c on a~vbeln = c~vbeln
                          and a~posnr = c~posnr
    inner join matdoc as f on b~zcut_mblnr = f~mblnr
                          and b~zcut_mjahr = f~mjahr
   where a~loekz <> 'X'
     and e~zord_type = 'C1'    " CUT만 필요함
     and b~sobkz     = 'E'     "SO로 지시
     and b~zcut_mblnr <> ''    "절단완료
   group by a~vbeln, a~posnr
    into table @data(lt_lcut_dat).

*===== 최종 생산일자 가져오기, max 일자
  " 생산 입고 일자 : 101 mv
  " oem PO 입고일자 : 101 mv
  " 정조장 : 413 mv

  select b~vbeln,
         b~posnr,
         a~matnr,
         max( a~budat ) as budat
    from matdoc as a
   inner join @gt_so as b
      on ( ( a~mat_kdauf = b~vbeln and a~mat_kdpos = b~posnr )
        or ( a~mat_kdauf = @space  and a~kdauf = b~vbeln and a~kdpos = b~posnr ) )
   where a~bwart     in ( '101', '413' )
     and a~cancelled = @space
   group by b~vbeln,
            b~posnr,
            a~matnr
    into table @data(lt_in_dat).


  sort lt_in_dat by vbeln posnr.
  sort lt_lcut_dat by vbeln posnr.
  sort lt_mska by vbeln posnr.
  sort lt_lcut_open by vbeln posnr.
  sort lt_lstock_in by vbeln posnr.
  sort lt_lcut_plan by vbeln posnr.
  sort lt_lcut_cmpl by vbeln posnr.

  move-corresponding gt_list[] to gt_lstock[].

  loop at gt_lstock assigning field-symbol(<lstock>).

    "-- SO재고
    read table lt_mska into data(ls_mska)
                           with key vbeln = <lstock>-vbeln
                                    posnr = <lstock>-posnr
                                    binary search.
    if sy-subrc = 0.
      if ls_mska-meins <> <lstock>-vrkme and ls_mska-kalab > 0.
        perform conversion_mat_unit  using    <lstock>-matnr
                                              ls_mska-meins
                                              ls_mska-kalab
                                              <lstock>-vrkme
                                     changing ls_mska-kalab.

        perform conversion_mat_unit  using    <lstock>-matnr
                                              ls_mska-meins
                                              ls_mska-kalab_po
                                              <lstock>-vrkme
                                     changing ls_mska-kalab_po.
      endif.
    else.
      ls_mska-kalab    = 0.
      ls_mska-kalab_po = 0.
    endif.

    "-- SO재고: 외주처
    read table lt_mska into data(ls_mska_po)
                           with key vbeln = <lstock>-vbeln
                                    posnr = <lstock>-posnr
                                    binary search.
    if sy-subrc = 0.
      if ls_mska_po-meins <> <lstock>-vrkme and ls_mska_po-kalab > 0.
        perform conversion_mat_unit  using    <lstock>-matnr
                                              ls_mska_po-meins
                                              ls_mska_po-kalab
                                              <lstock>-vrkme
                                     changing ls_mska_po-kalab.
      endif.
    else.
      ls_mska_po-kalab = 0.
    endif.

    "-- 입고용 정재고
    read table lt_lstock_in into data(ls_lstock)
                            with key vbeln = <lstock>-vbeln
                                     posnr = <lstock>-posnr
                                binary search.
    if sy-subrc = 0.
      if ls_lstock-vrkme <> gt_list-vrkme and ls_lstock-so_lstock > 0.
        perform conversion_mat_unit  using    <lstock>-matnr
                                              ls_lstock-vrkme
                                              ls_lstock-so_lstock
                                              <lstock>-vrkme
                                     changing ls_lstock-so_lstock.
      endif.
      if ls_lstock-vrkme <> gt_list-vrkme and ls_lstock-lstock > 0.
        perform conversion_mat_unit  using    <lstock>-matnr
                                              ls_lstock-vrkme
                                              ls_lstock-lstock
                                              <lstock>-vrkme
                                     changing ls_lstock-lstock.
      endif.
    else.
      ls_lstock-lstock    = 0.
      ls_lstock-so_lstock = 0.
    endif.

    "-- 절단 지시
    read table lt_lcut_plan into data(ls_lcut_plan)
                            with key vbeln = <lstock>-vbeln
                                     posnr = <lstock>-posnr
                                     binary search.
    if sy-subrc = 0.
      if ls_lcut_plan-meins <> <lstock>-vrkme and ls_lcut_plan-qty > 0.
        perform conversion_mat_unit  using    <lstock>-matnr
                                              ls_lcut_plan-meins
                                              ls_lcut_plan-qty
                                              <lstock>-vrkme
                                     changing ls_lcut_plan-qty.
      endif.
    else.
      ls_lcut_plan-qty = 0.
    endif.

    "-- 절단 완료
    read table lt_lcut_cmpl into data(ls_lcut_cmpl)
                            with key vbeln = <lstock>-vbeln
                                     posnr = <lstock>-posnr
                                     binary search.
    if sy-subrc = 0.
      if ls_lcut_cmpl-meins <> <lstock>-vrkme and ls_lcut_cmpl-qty > 0.
        perform conversion_mat_unit  using    <lstock>-matnr
                                              ls_lcut_cmpl-meins
                                              ls_lcut_cmpl-qty
                                              <lstock>-vrkme
                                     changing ls_lcut_cmpl-qty.
      endif.
    else.
      ls_lcut_cmpl-qty = 0.
    endif.

    "-- 절단 완료일자
    read table lt_lcut_dat into data(ls_lcut_dat)
                            with key vbeln = <lstock>-vbeln
                                     posnr = <lstock>-posnr
                                     binary search.
    if sy-subrc = 0.
      <lstock>-lcut_dats = ls_lcut_dat-budat.    " 절단완료일
    else.
      clear <lstock>-lcut_dats.
    endif.


    "-- 생산 입고, po 입고, 정재고 입고 일자
    <lstock>-in_dats = <lstock>-lcut_dats.
    read table lt_in_dat into data(ls_in_dat)
                            with key vbeln = <lstock>-vbeln
                                     posnr = <lstock>-posnr
                                     binary search.
    if sy-subrc = 0.
      if <lstock>-lcut_dats < ls_in_dat-budat.
        <lstock>-in_dats = ls_in_dat-budat.
      endif.
    endif.


    "-- 절단 OPEN
    read table lt_lcut_open into data(ls_lcut_open)
                            with key vbeln = <lstock>-vbeln
                                     posnr = <lstock>-posnr
                                     binary search.
    if sy-subrc = 0.
      if ls_lcut_open-meins <> <lstock>-vrkme and ls_lcut_open-qty > 0.
        perform conversion_mat_unit  using    <lstock>-matnr
                                              ls_lcut_open-meins
                                              ls_lcut_open-qty
                                              <lstock>-vrkme
                                     changing ls_lcut_open-qty.
      endif.
    else.
      ls_lcut_open-qty = 0.
    endif.

    <lstock>-kalab     = ls_mska-kalab.       " so 재고
    <lstock>-kalab_po  = ls_mska-kalab_po.    " so 재고 외주처
    <lstock>-so_lstock = ls_lstock-so_lstock. " so용 정재고
    <lstock>-lcut_open = ls_lcut_open-qty.    " 절단지시 OPEN

    <lstock>-lstock    = ls_lstock-lstock.    " link용 정재고
    <lstock>-lcut_plan = ls_lcut_plan-qty.    " 절단지시
    <lstock>-lcut_comp = ls_lcut_cmpl-qty.    " 절단완료

  endloop.


  delete gt_lstock where kalab = 0     and kalab_po = 0
                     and so_lstock = 0 and lstock = 0
                     and lcut_open = 0 and lcut_plan = 0 and lcut_comp = 0.



*----- 배치재고를 찾는다.
  data : lt_matnr type table of vbap.
  move-corresponding gt_list[] to lt_matnr[].
  delete lt_matnr where pstyv <> 'ZSCR'.
  sort lt_matnr by matnr.
  delete adjacent duplicates from lt_matnr comparing matnr.

  clear gt_mchb1[].

  if lt_matnr[] is not initial.
    select a~matnr, c1~atwrt, g~meins,
           a~lgort,
           a~charg,
           a~clabs,
           substring( cast( c2~atflv as char( 24 ) ), 1, 8 ) as gidate
**           sum( a~clabs ) as clabs,
**           substring( cast( max( c2~atflv ) as char( 24 ) ), 1, 8 ) as gidate
*           b~objek as matnr_charg,
*           e~atnam,
*           c~atflv
      from mchb as a
     inner join mch1 as a1 on a~matnr = a1~matnr
                          and a~charg = a1~charg
     inner join inob as b on a1~cuobj_bm = b~cuobj
     "-- 1) 고객코드 특성 조인 (c1, e1)
     left outer join ( ausp as c1
            inner join cabn as e1
                            on e1~atinn = c1~atinn
                           and e1~atnam = 'PD_CA_CUSTOMER_CODE' )
            on c1~objek = b~cuobj
           and c1~klart = b~klart
    "-- 2) 출고일자 특성 조인 (c2, e2)
     left outer join ( ausp as c2
            inner join cabn as e2
                            on e2~atinn = c2~atinn
                           and e2~atnam = 'PD_CA_GIDATE' )
          on c2~objek = b~cuobj
         and c2~klart = b~klart
     inner join @lt_matnr as f on a~matnr = f~matnr
     inner join mara as g on a~matnr = g~matnr
    where b~klart = '023'
      and b~obtab = 'MCH1'
      and a~clabs > 0
**    group by a~matnr, c1~atwrt, g~meins
     into table @data(lt_mchb1).

    sort lt_mchb1 by matnr atwrt gidate.
    data: ls_out   like line of gt_mchb1.

    loop at lt_mchb1 assigning field-symbol(<mchb1>).
      " 새로운 키가 시작될 때 변수 초기화
      at new atwrt.
        clear ls_out.
        ls_out-matnr = <mchb1>-matnr.
        ls_out-atwrt = <mchb1>-atwrt.
        ls_out-meins = <mchb1>-meins.
      endat.

      " clabs 합산
      ls_out-clabs = ls_out-clabs + <mchb1>-clabs.

      " 최대 gidate 유지
      if <mchb1>-gidate > ls_out-gidate.
        ls_out-gidate = <mchb1>-gidate.
      endif.

      " 현재 키 그룹이 끝날 때 테이블에 추가
      at end of atwrt.
        append ls_out to gt_mchb1.
      endat.
    endloop.

  endif.


endform.
*&---------------------------------------------------------------------*
*& Form calc_completed_qty
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_LIST_POQTY
*&      <-- LV_KWMENG_CMPL
*&---------------------------------------------------------------------*
form calc_completed_qty  changing pv_lqty
                                  pv_kwmeng_cmpl.

  if pv_lqty >= pv_kwmeng_cmpl.
    pv_lqty        = pv_lqty - pv_kwmeng_cmpl.
    pv_kwmeng_cmpl = 0.
  else.
    pv_lqty        = 0.
    pv_kwmeng_cmpl = pv_kwmeng_cmpl - pv_lqty.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form CONVERSION_JOJANG_UNIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_MATNR
*&      --> LT_PURCHASE_MEINS
*&      --> LT_PURCHASE_PO_MENGE
*&      --> GT_LIST_VRKME
*&      --> GT_LIST_LENGTH
*&      --> GT_LIST_MILL_LENGTH
*&      <-- LT_PURCHASE_PO_MENGE
*&---------------------------------------------------------------------*
form conversion_jojang_unit  using    pv_matnr
                                      pv_fr_meins
                                      pv_in_qty
                                      pv_to_meins
                                      pv_length
                                      pv_mill_length
                             changing pv_out_qty.

  if pv_length is not initial and pv_mill_length is not initial.
    "-- 조장과 조장수로 conversion함
    perform conversion_lenth_unit  using  pv_in_qty
                                          pv_length
                                          pv_mill_length
                                 changing pv_out_qty.
  else.
    perform conversion_mat_unit  using    pv_matnr
                                          pv_fr_meins
                                          pv_in_qty
                                          pv_to_meins
                                 changing pv_out_qty.
  endif.

endform.
*&---------------------------------------------------------------------*
*& Form get_zscr_do_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form get_key_do_data tables  lt_open     structure lips
                              lt_gi     structure lips
                              lt_last     structure lips.

  clear: lt_open[], lt_gi[], lt_last[].

  "-- DO KEY 데이터
  select distinct a~vbeln, b~posnr, f~pstyv, a~wadat_ist, b~wbsta, a~kostk
    from likp as a
    inner join lips as b on a~vbeln = b~vbeln
    inner join vbap as f on f~vbeln = b~vgbel
                        and f~posnr = b~vgpos
    inner join vbak as c on b~vgbel = c~vbeln
   where a~vkorg = @pa_vkorg
     and a~vbtyp  in ( 'J', 'T' )
     and a~vstel  in  @so_vstel
     and c~erdat  in  @so_erdat
     and c~auart  in  @so_auart
     and c~vbeln  in  @so_vbeln
     and c~zpjno  in  @so_zpjno
     and c~kunnr  in  @so_kunnr
     and c~vkorg  =   @pa_vkorg
     and c~vtweg  in  @so_vtweg
     and c~spart  in  @so_spart
     and c~vkbur  in  @so_vkbur
     and c~vkgrp  in  @so_vkgrp
     and c~zqtno  in  @so_zqtno
     and c~ztver  in  @so_ztver
     and b~werks  in  @so_werks
     and b~matnr  in  @so_matnr
     and upper( b~arktx ) in  @so_arktx
     and c~ernam  in  @so_ernam
     and b~matkl  in  @so_matkl
     and b~vgbel in ( select vbeln from vbep where edatu in @gr_edatu )
    into table @data(lt_dolist).

  "-- 납품일 상관없이 출고 된 DO 가져오기
  select distinct a~vbeln, b~posnr, f~pstyv, a~wadat_ist, b~wbsta, a~kostk
    from likp as a
    inner join lips as b on a~vbeln = b~vbeln
    inner join vbap as f on f~vbeln = b~vgbel
                        and f~posnr = b~vgpos
    inner join vbak as c on b~vgbel = c~vbeln
   where a~vkorg = @pa_vkorg
     and a~vbtyp  in ( 'J', 'T' )
     and a~vstel  in  @so_vstel
     and c~erdat  in  @so_erdat
     and c~auart  in  @so_auart
     and c~vbeln  in  @so_vbeln
     and c~zpjno  in  @so_zpjno
     and c~kunnr  in  @so_kunnr
     and c~vkorg  =   @pa_vkorg
     and c~vtweg  in  @so_vtweg
     and c~spart  in  @so_spart
     and c~vkbur  in  @so_vkbur
     and c~vkgrp  in  @so_vkgrp
     and c~zqtno  in  @so_zqtno
     and c~ztver  in  @so_ztver
     and b~werks  in  @so_werks
     and b~matnr  in  @so_matnr
     and upper( b~arktx ) in  @so_arktx
     and c~ernam  in  @so_ernam
     and b~matkl  in  @so_matkl
     and ( b~wbsta = 'C' or ( a~kostk = 'C' and f~pstyv ='ZSCR' ) )
*     and b~vgbel in ( select vbeln from vbep where edatu in @gr_edatu )
    appending corresponding fields of table @lt_dolist.

  sort lt_dolist by vbeln posnr.
  delete adjacent duplicates from lt_dolist comparing vbeln posnr.

  data: ls_do   like lips.

  loop at lt_dolist assigning field-symbol(<do>).

    move-corresponding <do> to ls_do.

    if <do>-pstyv = 'ZSCR'.

      if <do>-kostk = 'C'.

        "----- 지난달까지 완료된 DO, 잔여수량 계산용
        if gv_lastmon_date <= sy-datum.
          if <do>-wadat_ist <= gv_lastmon_date.
            ls_do-wbsta = 'C'.  " 소재는 피킹이 되면 출하완료로 처리함
            append ls_do to lt_last.
          endif.
        endif.

        "----- 당월 출고된 dO
        if ra1 = 'X'.  "당월+미출고
          if <do>-wadat_ist in gr_gidat.
            ls_do-wbsta = 'C'.  " 소재는 피킹이 되면 출하완료로 처리함
            append ls_do to lt_gi.
          endif.
        endif.

      else.
        "----- open do
        append ls_do to lt_open.
      endif.

    else.

      if <do>-wbsta = 'C'.

        "----- 지난달까지 완료된 DO, 잔여수량 계산용
        if gv_lastmon_date <= sy-datum.
          if <do>-wadat_ist <= gv_lastmon_date.
            append ls_do to lt_last.
          endif.
        endif.

        "----- 당월 출고된 dO
        if ra1 = 'X'.  "당월+미출고
          if <do>-wadat_ist in gr_gidat.
            append ls_do to lt_gi.
          endif.
        endif.

      else.
        "----- open do
        append ls_do to lt_open.
      endif.

    endif.

  endloop.


endform.
