*&---------------------------------------------------------------------*
*&  Include           ZFIR0581TOP
*&---------------------------------------------------------------------*
data g_subrc type sy-subrc.
data g_flag.
*동적 테이블 변수
type-pools : abap, rsds.

field-symbols: <dyn_table> type standard table,
               <dyn_table2> type standard table,
               <dyn_table_old> type standard table,
               <dyn_wa>,
               <dyn_field>.
data: dy_table     type ref to data,
      dy_table_old type ref to data,
      dy_line      type ref to data,
      xfc          type lvc_s_fcat,
      ifc          type lvc_t_fcat,
      g_init_200,
      g_title  like syst-title.

*view 테이블 정보 담겨있는 테이블
data gs_zfit0113 like zfit0113.

* Maintenance Table에 회사코드(BUKRS)가 존재하는지 여부
data: g_bukrs_exist(1),
      g_selopt_bukrs like bkpf-bukrs.

*View 테이블에서 데이타에 대한 sql의 where 절
data g_rsds_where TYPE  RSDS_WHERE.

*alv 데이터
data:
* table with class position
      g_tab_positions    type trfy_class_pos_t,
* TRF manager
      g_trf_manager      type ref to cl_manager_trf,
* message that no positions were found
      g_message          type bal_s_msg.
type-pools: slis , icon.
data: ok_code             like sy-ucomm,
      l_wrk_variant       like disvariant,
      g_container         type scrfname value 'ZALV_GRID',
      g_container2        type scrfname value 'ZALV_GRID2',
      grid1               type ref to cl_gui_alv_grid,
      grid2               type ref to cl_gui_alv_grid,
      g_custom_container  type ref to cl_gui_custom_container,
      g_custom_container2 type ref to cl_gui_custom_container,
*      event_receiver      type ref to lcl_event_receiver,
      gt_gfdcat           type lvc_t_fcat,
      gs_gfdcat           type lvc_s_fcat,
      gs_gexclude         type ui_func,
      gt_gexclude         type ui_functions,
      g_repid             like sy-repid,
      gs_gstable          type lvc_s_stbl,
      gs_layout           type lvc_s_layo.
data: g_pos             like sy-cucol.
data gt_fdcat            type slis_t_fieldcat_alv.
data g_table(30).


************************************************************************
*메크로
************************************************************************
* << GRID ALV >>
define mod_gfdcat.
  gs_gfdcat-key              = &1.
  if not &2 is initial.
    gs_gfdcat-outputlen      = &2.
  endif.

  if not &3 is initial.
    gs_gfdcat-scrtext_l      = &3.
    gs_gfdcat-scrtext_m      = &3.
    gs_gfdcat-scrtext_s      = &3.
    gs_gfdcat-reptext        = &3.
    gs_gfdcat-selddictxt     = 'M'.
  endif.
  gs_gfdcat-do_sum           = &4.
  gs_gfdcat-col_pos          = &5.
  gs_gfdcat-currency         = &6.
  gs_gfdcat-no_out           = &7.
  gs_gfdcat-edit             = &8.
  gs_gfdcat-f4availabl       = &9.
end-of-definition.
*체크박스 정의
define mod_cbox.
  if &1 is not initial.
    if gs_gfdcat-fieldname = &1.
      gs_gfdcat-checkbox = 'X'.
    endif.
  endif.
end-of-definition.
