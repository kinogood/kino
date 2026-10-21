*&---------------------------------------------------------------------*
*&  Include           ZGTSDR0070TOP
*&---------------------------------------------------------------------*


tables: sscrfields,
        vbak, vbap,  knvp,  knvv, zsdt_d365_030,
        tvko, tvkov, tvkos,
        tvak,
        tvakt,
        tvkot,
        tvtw,
        tvtwt,
        tspat,
        tvkbt,
        tvgrt,
        tvakz,
        dfies.


include <icon>.

data : gd_okcode     type ui_func,
       go_docking    type ref to cl_gui_docking_container,
       go_splitter   type ref to cl_gui_splitter_container,

       go_cell_left  type ref to cl_gui_container,
       go_cell_right type ref to cl_gui_container,
       gt_excl_func  type ui_functions,
       "GO_GRID1      TYPE REF TO CL_GUI_ALV_GRID,
       go_grid2      type ref to cl_gui_alv_grid. " right용 grid

data : gs_layout  type lvc_s_layo.
data : gs_variant type disvariant.
data : gt_fcat type lvc_t_fcat,
       gs_fcat type lvc_s_fcat.

data : gv_org_check(3).
data : g_exit     type c.
data : gv_err     type c.

class lcl_event_handler_200 definition deferred.
class lcl_event_handler_300 definition deferred.

*&---------------------------------------------------------------------*
*  100 화면 ( TREE용 TABLES & ALV GRID )
*&---------------------------------------------------------------------*

data: g_alv_tree         type ref to cl_gui_alv_tree,
      g_custom_container type ref to cl_gui_custom_container,
      g_toolbar          type ref to cl_gui_toolbar.

data: gt_fieldcatalog type lvc_t_fcat,
      gv_tree_on      type i,
      ok_code         like sy-ucomm,
      save_ok         like sy-ucomm,           "OK-Code
      g_max           type i value 255.

data : gt_fcat_detail type lvc_t_fcat.

*&---------------------------------------------------------------------*
*  200 화면 : 분할
*&---------------------------------------------------------------------*
data : go_container_200 type ref to cl_gui_custom_container,
       go_grid_200      type ref to cl_gui_alv_grid, " right용 grid
       g_toolbar_200    type ref to cl_gui_toolbar.
data : gs_layout_200    type lvc_s_layo,
       gt_excl_func_200 type ui_functions.
data : gt_fcat_200 type lvc_t_fcat,
       gs_fcat_200 type lvc_s_fcat.
data : go_handler_200 type ref to lcl_event_handler_200.
*&---------------------------------------------------------------------*
*  300 화면 : 의지치
*&---------------------------------------------------------------------*
data : go_container_300 type ref to cl_gui_custom_container,
       go_grid_300      type ref to cl_gui_alv_grid, " right용 grid
       g_toolbar_300    type ref to cl_gui_toolbar.
data : gs_layout_300    type lvc_s_layo,
       gt_excl_func_300 type ui_functions.
data : gt_fcat_300 type lvc_t_fcat,
       gs_fcat_300 type lvc_s_fcat.
data : go_handler_300 type ref to lcl_event_handler_300.


*************************************************

data : gt_tree    type zgtsds0041 occurs 0. "실제 tree용 데이터
data : gt_tree_m  like zgtsds0041 occurs 0 with header line. "tree에 사용하는 source 데이터

data : gs_main    like zgtsds0042.
data : gt_main    like zgtsds0042 occurs 0 with header line. "tree에 사용하는 source 데이터
*data : gt_back    like zgtsds0040 occurs 0 with header line. "tree에 사용하는 source 데이터
data : gs_detail like zgtsds0042.
data : begin of gt_detail occurs 0. "우측의 ALV용 데이터
         include structure zgtsds0042.
data : "FIELD_STYLE TYPE LVC_T_STYL,
       end of gt_detail.

*----- 삭제용 데이터
data : gs_026 like zsdt_d365_026.
data : gs_027 like zsdt_d365_027.
data : gt_026_tmp like table of zsdt_d365_026 with header line,
       gt_027_tmp like table of zsdt_d365_027 with header line,
       gt_021_upd like table of zsdt_d365_021 with header line,
       gt_026_upd like table of zsdt_d365_026 with header line,
       gt_027_upd like table of zsdt_d365_027 with header line.
data : gt_021_del like table of zsdt_d365_021 with header line,
       gt_026_del like table of zsdt_d365_026 with header line,
       gt_027_del like table of zsdt_d365_027 with header line.
*---- 환율정보
data: gt_1300t type table of zpls1300s with non-unique sorted key key1
                                        components fcurr.

data : gt_kna1  type table of kna1 with header line.
data : gv_so_pernr like vbpa-lifnr.
data : gv_pernr_nm type ad_name1.
data : gv_read_new type c.
data : gv_atinn type atinn.
data : gv_exchg_krw type kurrf.
data : gv_max_week like zsdt_d365_020-week.

" SO정보 집계용
types : begin of ty_so,
          vbeln_va   type vbap-vbeln,
          posnr_va   type vbap-posnr,
          vbeln_vl   type lips-vbeln,
          posnr_vl   type lips-posnr,
          seqno      type zeseqno,
          vkorg      like vbak-vkorg,
          vkbur      like vbak-vkbur,
          vkgrp      like vbak-vkgrp,
          vtweg      like vbak-vtweg,
          spart      like vbak-spart,
          vbtyp      like vbak-vbtyp,
          pernr      type pernr_d,
          land1      type land1,
          zpjno      type vbak-zpjno,
          zptxt      like zsd0106t-zptxt,
          kunnr      like vbak-kunnr,
          kunnr_nm   like adrc-name1,
          lifnr      like vbpa-lifnr,
          werks      like lips-werks,
          matnr      like lips-matnr,
          arktx      like vbap-arktx,
          edatu      type edatu,
          wadat_ist  like likp-wadat_ist,
          jojang_uom type char10,
          jojang_qty type char10,
          kwmeng     like vbap-kwmeng,
          netwr      like vbap-netwr,
          vrkme      like vbap-vrkme,
          netpr      like vbap-netpr,
          waerk      like vbak-waerk,
          waers      type waers,
          prodh      type prodh_d,
          abgru      type abgru,

          plqty      like vbap-kwmeng,
          plamt      like vbap-netwr,
          bldat      type edatu,

          ordqty_su  like vbep-ordqty_su,
          scr_grade  type atwrt,
          remark     type zeremark,
          gubun      type char10,
        end of ty_so.
types : ty_so_tab type table of ty_so.

" 납품정보 집계용
types : begin of ty_do,
          vbeln_vl  type lips-vbeln,
          posnr_vl  type lips-posnr,
          vbeln_va  type vbap-vbeln,
          posnr_va  type vbap-posnr,
          wadat_ist like likp-wadat_ist,
          erdat     like likp-erdat,
          wadat     like likp-wadat,
          vrkme     like lips-vrkme,
          lfimg     like lips-lfimg,
          werks     like lips-werks,
          matnr     like lips-matnr,
          wbsta     like lips-wbsta,
          kunnr     like vbak-kunnr,
        end of ty_do.
types : ty_do_tab type table of ty_do.

" 빌링정보 집계용
types : begin of ty_bl,
          vbeln_vf type vbrp-vbeln,
          posnr_vf type vbrp-posnr,
          vbeln_vl like lips-vbeln,
          posnr_vl like lips-posnr,
          vbeln_va like vbap-vbeln,
          posnr_va like vbap-posnr,
          fkdat    like vbrk-fkdat,
          netwr    like vbrp-netwr,
          waerk    like vbrk-waerk,
          fkimg    like vbrp-fkimg,
          vrkme    like vbrp-vrkme,
          werks    like lips-werks,
          matnr    like lips-matnr,
          kunnr    like vbak-kunnr,
          kurrf    like vbrk-kurrf,
          vbtyp    like vbak-vbtyp,
          fkart    like vbrk-fkart,
        end of ty_bl.
types : ty_bl_tab type table of ty_bl.

types : begin of ty_vbap,
          vbeln     like vbap-vbeln,
          posnr     like vbap-posnr,
          seqno     like zsdt_d365_026-seqno,
          kwmeng    type kwmeng,
          klmeng    type klmeng,
          dlvqty_bu type dlvqty,
        end of ty_vbap.
types : ty_vbap_tab type table of ty_vbap.


data : gt_sales type table of ty_vbap.
data : gt_030  type table of zsdt_d365_030.
data : gt_021  type table of zsdt_d365_021.
data : gt_026  type table of zsdt_d365_026.
data : gt_027  type table of zsdt_d365_027.
data : gt_027_chk  type table of zsdt_d365_027.


" 주문정보 집계용
data : gs_so type ty_so,
       gt_so type ty_so_tab.
" 납품정보 집계용
data : gs_do type ty_do,
       gt_do type ty_do_tab.
" 빌링정보 집계용
data : gs_bl type ty_bl,
       gt_bl type ty_bl_tab.



* SO와 DO 데이터.
data: begin of gt_order occurs 0,
        vbeln_va like vbap-vbeln,
        posnr_va like vbap-posnr,
        vbeln_vl like lips-vbeln,
        posnr_vl like lips-posnr,
        uecha    like lips-uecha,                           "20180619 K
        pernr    like zgtsds0041-pernr,
        pernr_nm like zgtsds0041-pernr_nm,
      end of gt_order.

data : begin of gt_plan occurs 0,      "계획 수량
         vkbur like vbak-vkbur.
         include structure zgtsds0041.
data : end of gt_plan.
data : begin of gt_plan_sum occurs 0, "Summary node용 수량
         vkbur like vbak-vkbur.
         include structure zgtsds0041.
data : end of gt_plan_sum.
data : begin of gt_plan_tot occurs 0, "Summary node용 수량
         vkbur like vbak-vkbur.
         include structure zgtsds0041.
data : end of gt_plan_tot.

data : gt_t001l like t001l     occurs 0 with header line. "저장위치


data : gv_vkbur_nm like tvgrt-bezei.
data : gv_top_nm type char100.

data : gv_wp1_sunday  like sy-datum,
       gv_w00_monday  like sy-datum,
       gv_w00_sunday  like sy-datum,
       gv_w00         like zsdt_d365_020-week,
       gv_week_month  type spmon,
       gv_week_monday like sy-datum,
       gv_week_sunday like sy-datum,
       gv_bdate       like sy-datum,
       gv_bweek       like zsdt_d365_020-week.

data : gv_mp1 type spmon,
       gv_m00 type spmon,
       gv_m01 type spmon,
       gv_m02 type spmon,
       gv_m03 type spmon,
       gv_m04 type spmon.
data : gv_first_day like sy-datum,
       gv_last_day  like sy-datum,
       gv_1st_edatu like sy-datum.

data: gv_nkey       type lvc_nkey.
data: gv_nkey_m0    type lvc_nkey. "당주 node key
data: gv_nkey_top   type lvc_nkey. "TOP node key

data: gv_bukrs type vkbuk,    "영업조직의 회사코드
      gv_waers type waers,
      gv_land1 type land1.

data: gt_dbltype type lvc_t_dral,
      gs_dbltype type lvc_s_dral.

*&---------------------------------------------------------------------*
*  200 화면 : SO 분할 회면
*&---------------------------------------------------------------------*
data : gd_200okcode     type ui_func.
data : g200_alv     type ref to cl_gui_custom_container,
       g200_toolbar type ref to cl_gui_toolbar.

data : gt_fieldcatalog_200 type lvc_t_fcat.

data : begin of gs_200.
         include structure zgtsds0042.
data :
       end of gs_200.
data : begin of gt_list_200 occurs 0.
         include structure zgtsds0043.
data :   field_style type lvc_t_styl,
       end of gt_list_200 .

*&---------------------------------------------------------------------*
*  300 화면 : 의지치 입력
*&---------------------------------------------------------------------*
data : gd_300okcode     type ui_func.
data : gt_300_tab like table of zgtsds0044 with header line.

data : begin of gs_300.
         include structure zgtsds0044.
data :
       end of gs_300.
data : begin of gt_list_300 occurs 0.
         include structure zgtsds0044.
data :   field_style type lvc_t_styl,
       end of gt_list_300 .

data : gt_300_origin like zgtsds0044 occurs 0 with header line.

*&---------------------------------------------------------------------*
*  400 화면 : 매출액 일괄변경
*&---------------------------------------------------------------------*
data : gd_400okcode     type ui_func.

data : gv_400_sales_month type spmon.
data : gt_f4 type lvc_t_f4,
       gs_f4 type lvc_s_f4.



constants: line_length type i value 132.

data:
*   reference to wrapper class of control
  g_editor               type ref to cl_gui_textedit,
*   reference to custom container: necessary to bind TextEdit Control
  g_editor_container     type ref to cl_gui_custom_container,
  g_repid                like sy-repid,
  g_ok_code              like sy-ucomm,       " return code from screen
  g_relink               type c,               " to manage relinking
  g_mytable(line_length) type c occurs 0,
  g_mycontainer(30)      type c,      " string for the containers
  g_container_linked     type i.                            "#EC NEEDED
" container to which control is linked

* necessary to flush the automation queue
class cl_gui_cfw definition load.


** 영업오더 TEXT 정보
data: gs_thead like thead.
data: gt_tline type table of tline with header line,
      g_tline  type tline.

data: gv_vbeln        type vbeln,
      gv_vbeln_ty(10) type c,        "판매오더 or 납품오더 구분
      gv_langu_tx     like sy-langu. "text의 언어

data: begin of gt_tdname occurs 0,
        tdobject type tdobject,
        tdname   type  tdobname,
      end of gt_tdname.

*&---------------------------------------------------------------------*
*  RANGES
*&---------------------------------------------------------------------*

ranges :  gr_abgru    for vbap-abgru,
          gr_pernr    for zsdt_d365_030-pernr,
          gr_so_pernr for vbpa-lifnr.

*&---------------------------------------------------------------------*
*  Constants
*&---------------------------------------------------------------------*

constants: gc_open_width  type i         value 33,
           gc_close_width type i         value 0,
           gc_open        type i         value 1,
           gc_close       type i         value -1,

           charx          type char01    value 'X',

           c_so           type char02    value 'SO',
           c_do           type char02    value 'DO',
           c_26           type char02    value '26', "분할 Table
           c_27           type char02    value '27', "의지치 Table
           c_90           type sy-cucol  value '90', "확정팝업 시작위치

           c_a            type char01    value 'A',
           c_b            type char01    value 'B',
           c_c            type char01    value 'C',
           c_d            type char01    value 'D',
           c_e            type char01    value 'E',
           c_f            type char01    value 'F',
           c_g            type char01    value 'G',
           c_h            type char01    value 'H',
           c_h_small      type char01    value 'h',
           c_i            type char01    value 'I',
           c_j            type char01    value 'J',
           c_k            type char01    value 'K',
           c_l            type char01    value 'L',
           c_m            type char01    value 'M',
           c_n            type char01    value 'N',
           c_o            type char01    value 'O',
           c_p            type char01    value 'P',
           c_q            type char01    value 'Q',
           c_r            type char01    value 'R',
           c_s            type char01    value 'S',
           c_t            type char01    value 'T',
           c_u            type char01    value 'U',
           c_v            type char01    value 'V',
           c_w            type char01    value 'W',
           c_x            type char01    value 'X',
           c_y            type char01    value 'Y',
           c_z            type char01    value 'Z'.


*&---------------------------------------------------------------------*
*  DEFINES
*&---------------------------------------------------------------------*
define set_range.
  IF &2 IS NOT INITIAL.
     &1-SIGN   = 'I'.
     &1-OPTION = 'EQ'.
     &1-LOW    = &2.
     APPEND &1.
  ENDIF.
end-of-definition.

define atinn_output.
  CALL FUNCTION 'CONVERSION_EXIT_ATINN_OUTPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
end-of-definition.

define alpha_input.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
end-of-definition.

define alpha_output.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
end-of-definition.
*&---------------------------------------------------------------------*
*  SELECTION-SCREEN
*&---------------------------------------------------------------------*
selection-screen function key 1. "버튼명 : PA 손익계산서 (피복선)
selection-screen function key 2.

selection-screen begin of block bl1 with frame title text-001.

  parameters : p_vkorg like vbak-vkorg default '1000' no-display.
*  parameters : p_vkgrp like vbak-vkgrp no-display.
  parameters : p_vtweg like vbak-vtweg no-display.



  selection-screen begin of line.
    selection-screen comment 1(8)  tx_vkbur for field p_vkbur. " '영업팀'
    selection-screen position 33.
    parameters p_vkbur type vkbur obligatory memory id vkb.
    selection-screen position 45.
    selection-screen comment (35) v_vkbur for field p_vkbur modif id md1.    " 명칭 표시
  selection-screen end of line.

  selection-screen begin of line.
    selection-screen comment 1(8)  tx_pernr for field p_pernr. " '영업사원'
    selection-screen position 33.
    parameters p_pernr like zsdt_d365_021-pernr memory id per.
    selection-screen position 45.
    selection-screen comment (45) v_pernr for field p_pernr.     " 성명 표시
  selection-screen end of line.

*
*  parameters : p_vkbur like vbak-vkbur obligatory memory id vkb
*                                       matchcode object h_tvbur. "영업팀
*  parameters : p_pernr like zsdt_d365_021-pernr obligatory memory id per
*                                                matchcode object zle_pernr. "영업사원

  selection-screen skip 1.

  select-options : s_erdat  for vbak-erdat obligatory "주문생성일
                                           modif id sc1.
  select-options : s_vbeln  for vbak-vbeln.      "주문번호
  select-options : s_kunag  for vbak-kunnr.      "판매처
  select-options : s_zpjno  for vbak-zpjno matchcode object zsd_pjnot.      "프로젝트

  selection-screen skip 1.

  selection-screen begin of line.
    selection-screen comment 1(8)  tx_mon for field p_premon. " 전월기준
    selection-screen position 33.
    parameters p_premon type c as checkbox.  "전월기준으로 데이터를 검색함
  selection-screen end of line.

  parameters : p_alv like disvariant-variant no-display .
selection-screen end of block bl1.



parameters : p_call type c no-display.   "submit용 체크박스
