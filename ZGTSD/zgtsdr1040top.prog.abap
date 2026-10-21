*&---------------------------------------------------------------------*
*& Include          ZGTSDR1040TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Tables.
*&---------------------------------------------------------------------*
TABLES: zgtsdt1040,    " [GT] 소재 매출 정산 이력 Header
        zgtsdt1041.    " [GT] 소재 매출 정산 이력 Item

*&---------------------------------------------------------------------*
*& Internal Table / Structure.
*&---------------------------------------------------------------------*
* Display Tab - Header.
DATA: BEGIN OF gs_head,
        chk(1),     " Check box
        save(4),    " 정산 Data
        stat(4),    " 정산 상태
        oemgr_sumqty LIKE zgtsdt1040-oemgr_qty,
        message      LIKE bapiret2-message,
*        OEML_GRQTY LIKE ZGTSDT1040-OEMGR_QTY,
*        OEMN_GRQTY LIKE ZGTSDT1040-OEMGR_QTY,
        noedit(1),
        cur_lfimg    TYPE fkimg,
        color_tab    TYPE lvc_t_scol,
        style_tab    TYPE lvc_t_styl.
        INCLUDE STRUCTURE zgtsdt1040.
DATA: END OF gs_head.
DATA: gt_head     LIKE TABLE OF gs_head,
      gt_pjt_base LIKE TABLE OF gs_head.

* Display Tab - Item.
DATA: BEGIN OF gs_item,
        save(4),     " 정산 Data
*        stat(4),    " 정산 상태
        kondmt          TYPE zgtekondmt,
        fld_06          LIKE zgtppt1010-fld_06,
        message         LIKE bapiret2-message,
        noedit(1),
        noedit_kondm(1),
        color_tab       TYPE lvc_t_scol,
        style_tab       TYPE lvc_t_styl.
        INCLUDE STRUCTURE zgtsdt1041.
DATA: END OF gs_item.
DATA: gt_item     LIKE TABLE OF gs_item,
      gt_item_tmp LIKE TABLE OF gs_item.

DATA: gt_save_item TYPE TABLE OF zgtsdt1041,
      gt_seginfo   TYPE TABLE OF zgtsdt1110,
      gt_kondm     TYPE TABLE OF zgtsdt1030.

* 가공비 유형
DATA: BEGIN OF gt_type  OCCURS 0,
        codeid LIKE zgtppt1010-codeid,
        fld_01 LIKE zgtppt1010-fld_01,
        fld_02 LIKE zgtppt1010-fld_02,
        fld_03 LIKE zgtppt1010-fld_03,
        fld_06 LIKE zgtppt1010-fld_06,
        fld_07 LIKE zgtppt1010-fld_07,
      END OF gt_type.

DATA: BEGIN OF gs_nfprice,
        price   LIKE oicqp-price,
        defper  LIKE oicqp-defper,
        nfprice LIKE oicqp-price,
      END OF gs_nfprice.

DATA: gt_batch  TYPE TABLE OF zgtsdt1042.

DATA: BEGIN OF gs_do_info,
        zpjno     LIKE zsd0106t-zpjno,
        zptxt     LIKE zsd0106t-zptxt,
        kunnr     LIKE vbak-kunnr,
        name1     LIKE kna1-name1,
        matnr     LIKE lips-matnr,
        arktx     LIKE lips-arktx,
        vbeln     LIKE vbap-vbeln,
        posnr     LIKE vbap-posnr,
        do_vbeln  LIKE lips-vbeln,
        do_posnr  LIKE lips-posnr,
        lfimg     LIKE lips-lfimg,
        vrkme     LIKE lips-vrkme,
        wadat_ist LIKE likp-wadat_ist,
      END OF gs_do_info.
DATA: gt_do_info  LIKE TABLE OF gs_do_info.

* Billing Info
DATA: BEGIN OF gs_bl_info,
        vbeln    LIKE vbap-vbeln,
        posnr    LIKE vbap-posnr,
        do_vbeln LIKE lips-vbeln,
        do_posnr LIKE lips-posnr,
        bl_vbeln LIKE vbrp-vbeln,    " Billing
        bl_posnr LIKE vbrp-posnr,    " Billing품번
      END OF gs_bl_info,
      gt_bl_info LIKE TABLE OF gs_bl_info.

*&---------------------------------------------------------------------*
*& Values.
*&---------------------------------------------------------------------*
DATA: gv_error(1),
      gv_disp(1),
      gv_save_chg(1),
      gv_change(1),
      gv_change_h(1),
      gv_lock(1),
      gv_answer(1),
      gv_line        TYPE i,

      gv_okcode      TYPE sy-ucomm,
      gv_save_cd     TYPE sy-ucomm,
      gv_okcode2     TYPE sy-ucomm,
      gv_save_cd2    TYPE sy-ucomm.

DATA: gv_vkorg     LIKE zgtsdt1040-vkorg,
      gv_vtweg     LIKE zgtsdt1040-vtweg,
      gv_spart     LIKE zgtsdt1040-spart,
      gv_vkbur     LIKE zgtsdt1040-vkbur,
      gv_vkgrp     LIKE zgtsdt1040-vkgrp,
      gv_spmon     LIKE zgtsdt1040-spmon,
      gv_first_day LIKE sy-datlo,
      gv_last_day  LIKE sy-datlo.



*&---------------------------------------------------------------------*
*& For BAPI
*&---------------------------------------------------------------------*

DATA: gt_return           TYPE TABLE OF bapiret2,

* BAPI_SALESORDER_CREATEFROMDAT2
      gs_so_head          LIKE bapisdhd1,
      gs_so_headx         LIKE bapisdhd1x,
      gt_so_item          TYPE TABLE OF bapisditm,
      gt_so_itemx         TYPE TABLE OF bapisditmx,
      gt_so_partn         TYPE TABLE OF bapiparnr,
      gt_so_schdl         TYPE TABLE OF bapischdl,
      gt_so_schdlx        TYPE TABLE OF bapischdlx,
      gt_so_cond          TYPE TABLE OF bapicond,
      gt_so_condx         TYPE TABLE OF bapicondx,
      gt_so_exten         TYPE TABLE OF bapiparex,

*     BAPI_DELIVERYPROCESSING_EXEC
      gs_do_tech          TYPE bapideliciouscontrol,
      gt_do_request       TYPE TABLE OF bapideliciousrequest,
      gt_do_item          TYPE TABLE OF bapideliciouscreateditems,

*     BAPI_OUTB_DELIVERY_CHANGE
      gs_do_chg_head      TYPE bapiobdlvhdrchg,
      gs_do_chg_cont      TYPE bapiobdlvhdrctrlchg,
      gt_do_chg_item      TYPE TABLE OF bapiobdlvitemchg,
      gt_do_chg_item_cont TYPE TABLE OF bapiobdlvitemctrlchg,
      gt_do_chg_item_splt TYPE TABLE OF /spe/bapiobdlvitemchg,

*     Good Issue : WS_DELIVERY_UPDATE_2
      gs_gi_vbkok         LIKE vbkok,
      gt_gi_vbpok         TYPE TABLE OF vbpok,
      gt_gi_prot          TYPE TABLE OF prott,

*     BAPI_SALESORDER_CHANGE
      gs_so_canc_hdx      TYPE bapisdh1x.

*&---------------------------------------------------------------------*
*& For ALV
*&---------------------------------------------------------------------*
DATA: go_event_handler TYPE REF TO lcl_event_handler,
      go_docking       TYPE REF TO cl_gui_docking_container,
      go_split         TYPE REF TO cl_gui_splitter_container,

      go_cont_t        TYPE REF TO cl_gui_container,
      go_cont_h        TYPE REF TO cl_gui_container,
      go_cont_i        TYPE REF TO cl_gui_container,

      go_docid         TYPE REF TO cl_dd_document,
      go_grid_top      TYPE REF TO cl_gui_alv_grid,
      go_grid_h        TYPE REF TO cl_gui_alv_grid,
      go_grid_i        TYPE REF TO cl_gui_alv_grid,

      gt_fcat_h        TYPE lvc_t_fcat,
      gt_toolbar_h     TYPE ui_functions,
      gt_sort_h        TYPE lvc_t_sort,   " ALV Sort
      gs_layout_h      TYPE lvc_s_layo,
      gs_variant_h     TYPE disvariant,

      gt_fcat_i        TYPE lvc_t_fcat,
      gt_toolbar_i     TYPE ui_functions,
      gt_sort_i        TYPE lvc_t_sort,   " ALV Sort
      gs_layout_i      TYPE lvc_s_layo,
      gs_variant_i     TYPE disvariant,

      gt_row           TYPE lvc_t_row WITH HEADER LINE,
      gs_stbl          TYPE lvc_s_stbl,
      gs_row           TYPE lvc_s_row,
      gv_pos           TYPE lvc_colpos.

DATA: go_costom      TYPE REF TO cl_gui_custom_container,
      go_grid_200    TYPE REF TO cl_gui_alv_grid,
      gt_fcat_200    TYPE lvc_t_fcat,
      gt_toolbar_200 TYPE ui_functions,
      gt_sort_200    TYPE lvc_t_sort,   " ALV Sort
      gs_layout_200  TYPE lvc_s_layo,
      gs_variant_200 TYPE disvariant.

DATA: gt_color TYPE lvc_t_scol,
      gt_style TYPE lvc_t_styl.

*&---------------------------------------------------------------------*
*& Define.
*&---------------------------------------------------------------------*
DEFINE: _clear.
  REFRESH: &1.    CLEAR: &1.
END-OF-DEFINITION.
