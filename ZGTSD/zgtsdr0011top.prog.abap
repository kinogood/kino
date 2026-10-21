*&---------------------------------------------------------------------*
*& Include          ZGTSDR0011TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
tables : ctu_params,             " CALL TRANSACTION OPTION..
         vbak, vbap, tvko.

*----------------------------------------------------------------------*
* Class
*----------------------------------------------------------------------*
class : lcl_event_receiver definition deferred.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
constants : gc_e     type char1 value 'E',
            gc_x     type char1 value 'X',
            gc_quota type char1 value '"'.

constants : gc_crlf type c value cl_bcs_convert=>gc_crlf,
            gc_tab  type c value cl_bcs_convert=>gc_tab.


*----------------------------------------------------------------------*
* VARIABLE
*----------------------------------------------------------------------*
data : gv_saveok like sy-ucomm,
       gv_okcode like sy-ucomm,
       gv_error  type char1,
       gv_web    type char1,
       gv_answer type char1.

*----------------------------------------------------------------------*
* TYPE & STRUCTURE & INTERNAL TABLE
*----------------------------------------------------------------------*
data : gt_fcode   type table of sy-ucomm,
       gt_celltab type lvc_t_styl.

"ALV Default Fields
types : begin of ty_s_alvdef,
          statu type icon_d,     "신규/변경/삭제 상태 ICON
          msg   type text100,
          insrt type char1,      "신규 여부 Flag : 'X' or ' '
          modi  type char1,      "변경 여부 Flag : 'X' or ' '
          sel   type char1,
          cells type lvc_t_styl, "Cell Style
          cellc type lvc_t_styl, "Cell Color
        end of ty_s_alvdef.

types : begin of ty_s_chg,
          vkorg type vkorg,
          matnr type matnr,
        end of ty_s_chg,
        ty_t_chg type table of ty_s_chg
                   with non-unique sorted key key_mode
                   components vkorg.

data  : begin of gs_s0100,
          vkorg     type vkorg,
          vtweg     type vtweg,
          spart     type spart,
          vkbur     type vbak-vkbur,
          vkgrp     type vbak-vkgrp,
          auart     type vbak-auart,
          kunag     type vbak-kunnr,
          kunwe     type vbak-kunnr,
          kunrg     type vbak-kunnr,
          bstnk     type vbak-bstnk,
          vdatu     type vbak-vdatu,
          vrkme     type vbap-vrkme,
          maktx     type makt-maktx,
          jojan_cnt type i,
          jojan     type kwmeng.
          include    type zgtsdt0011.
          include    type ty_s_alvdef. "ALV Default Fields
data : end of gs_s0100.
data : gt_s0100 like table of gs_s0100.

data  : begin of gs_s0101,
          posnr  type vbap-posnr,
          matnr  type vbap-matnr,
          maktx  type makt-maktx,
          vrkme  type vbap-vrkme,
          charg  type vbap-charg,
          kwmeng type vbap-kwmeng,
        end of gs_s0101,
        gt_s0101 like table of gs_s0101 with non-unique sorted key k_key components posnr.

data : begin of gs_excel,
         kwmeng type kwmeng,
         charg  type charg_d,
       end of gs_excel,
       gt_excel like table of gs_excel with empty key.

data : gs_header_in  type bapisdhd1,
       gs_header_inx type bapisdhd1x,
       gt_items_in   type crmt_bapisditm_t,
       gt_items_inx  type crmt_bapisditmx_t,
       gt_partners   type zbapiparnr_tab,
       gt_schdl_in   type zisi_bapischdl_tt,
       gt_schdl_inx	 type oij_bapischdlx_t,
       gt_cond_in	   type crmt_bapicond_t,
       gt_cond_inx   type crmt_bapicondx_t,
       gt_paddr      type crmt_bapiaddr1,
       gt_extens     like bapiparex  occurs 0,
       gt_ref        like bapicucfg  occurs 0,
       gt_inst       like bapicuins  occurs 0,
       gt_part       like bapicuprt  occurs 0,
       gt_val        like bapicuval  occurs 0,
       gt_return     like bapiret2 occurs 0 with header line,
       gv_vbeln      type vbeln_va.

"화면 변경 정보
data : gt_chg   type ty_t_chg.
*----------------------------------------------------------------------*
*  ALV GRID.
*----------------------------------------------------------------------*

data : gt_toolbar type ui_functions.
data : go_con     type ref to cl_gui_docking_container,
       go_grid    type ref to cl_gui_alv_grid,
       gt_fcat    type lvc_t_fcat,
       gs_fcat    type lvc_s_fcat,
       gt_sort    type lvc_t_sort,   " ALV Sort

       go_grid2   type ref to cl_gui_alv_grid,
       gt_fcat2   type lvc_t_fcat,
       gs_fcat2   type lvc_s_fcat,
       gt_sort2   type lvc_t_sort,   " ALV Sort

       gs_layout  type lvc_s_layo,
       gs_layout2 type lvc_s_layo,
       go_split   type ref to cl_gui_splitter_container,
       go_con_top type ref to cl_gui_container,
       go_docu    type ref to cl_dd_document.


data : gs_variant type disvariant.
data : gs_stbl type lvc_s_stbl.

data : gt_row type lvc_t_row with header line,
       gs_row like gt_row.

** BDCDATA DECLARE
data: begin of bdctab occurs 0.
        include structure bdcdata.
data: end of bdctab.

data: g_msg_t like bdcmsgcoll
              occurs 0 with header line.

*----------------------------------------------------------------------*
* DEFINE
*----------------------------------------------------------------------*
define __cle.
  CLEAR: &1, &1[].
end-of-definition.

define __rng.
  &1-SIGN   = &2.
  &1-OPTION = &3.
  &1-LOW    = &4.
  &1-HIGH    = &5.
  APPEND &1. CLEAR &1.
end-of-definition.

define __alpha_in.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
end-of-definition.

define __alpha_ou.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
end-of-definition.

define __get_rows.
  __CLE : &2.
  CHECK &1 IS BOUND.
  CALL METHOD &1->GET_SELECTED_ROWS
     IMPORTING
       ET_INDEX_ROWS = &2[].

  DELETE &2 WHERE ROWTYPE IS NOT INITIAL.

  CHECK &3 IS NOT INITIAL.
end-of-definition.

define _matnr_i.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT = &1
    IMPORTING
      OUTPUT = &2
    EXCEPTIONS
      LENTH_ERROR = 1
      OTHERS = 2.
end-of-definition.
define _matnr_o.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      INPUT = &1
    IMPORTING
      OUTPUT = &2
    EXCEPTIONS
      LENTH_ERROR = 1
      OTHERS = 2.
end-of-definition.
