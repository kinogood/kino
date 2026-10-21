*&---------------------------------------------------------------------*
*& Include          ZGTSDR1030TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Tables.
*&---------------------------------------------------------------------*
TABLES: zgtsdt1030.    " [GT] 거래처별 SCR 8.0mm 가공비 관리

*&---------------------------------------------------------------------*
*& Internal Table / Structure.
*&---------------------------------------------------------------------*
* Data Tab.
DATA: BEGIN OF gs_base,
        spmon  LIKE zgtsdt1030-spmon,
        vkorg  LIKE zgtsdt1030-vkorg,
        kunnr  LIKE zgtsdt1030-kunnr,
        name1  LIKE kna1-name1,
        matnr  LIKE zgtsdt1030-matnr,
        maktx  LIKE makt-maktx,
        kondm  LIKE zgtsdt1030-kondm,
        kondmt LIKE zgtsdt1030-kondmt,
        vtweg  LIKE zgtsdt1030-vtweg,
        spart  LIKE zgtsdt1030-spart,
        vkbur  LIKE zgtsdt1030-vkbur,
        kbetr  LIKE zgtsdt1030-kbetr,
        waers  LIKE zgtsdt1030-waers,
        kpein  LIKE zgtsdt1030-kpein,
        kmein  LIKE zgtsdt1030-kmein,
        fld_06 LIKE zgtppt1010-fld_06,
        fld_01 LIKE zgtppt1010-fld_01,
      END OF gs_base,

      gt_base LIKE TABLE OF gs_base,

      BEGIN OF gs_head,
        spmon   LIKE zgtsdt1030-spmon,
        vkbur   LIKE zgtsdt1030-vkbur,
        price   LIKE oicqp-price,
        defcurr LIKE oicqp-defcurr,
        defper  LIKE oicqp-defper,
        defuom  LIKE oicqp-defuom,
      END OF gs_head.

DATA: BEGIN OF gt_kunnr  OCCURS 0,
        kunnr TYPE kunnr,
      END OF gt_kunnr,

      BEGIN OF gt_type  OCCURS 0,
        codeid LIKE zgtppt1010-codeid,
        fld_01 LIKE zgtppt1010-fld_01,
        fld_02 LIKE zgtppt1010-fld_02,
        fld_03 LIKE zgtppt1010-fld_03,
        fld_06 LIKE zgtppt1010-fld_06,
      END OF gt_type.

*&---------------------------------------------------------------------*
*& Values.
*&---------------------------------------------------------------------*
DATA: gv_error(1),
      gv_lock(1),
      gv_answer(1),
      gv_line      TYPE i,

      gv_okcode    TYPE sy-ucomm,
      gv_save_cd   TYPE sy-ucomm.

*&---------------------------------------------------------------------*
*& Field-Symbols
*&---------------------------------------------------------------------*
FIELD-SYMBOLS: <gt_list> TYPE STANDARD TABLE,
               <gs_list> TYPE data.

*&---------------------------------------------------------------------*
*& For ALV
*&---------------------------------------------------------------------*
DATA: go_event_handler TYPE REF TO lcl_event_handler,
      go_costom        TYPE REF TO cl_gui_custom_container,
      go_docking       TYPE REF TO cl_gui_docking_container,
      go_split         TYPE REF TO cl_gui_splitter_container,

      go_cont_t        TYPE REF TO cl_gui_container,
      go_cont_m        TYPE REF TO cl_gui_container,

      go_docid         TYPE REF TO cl_dd_document,
      go_grid          TYPE REF TO cl_gui_alv_grid,
      go_grid_top      TYPE REF TO cl_gui_alv_grid,

      gt_fcat          TYPE lvc_t_fcat,
      gt_toolbar       TYPE ui_functions,
      gt_sort          TYPE lvc_t_sort,   " ALV Sort
      gt_row           TYPE lvc_t_row WITH HEADER LINE,

      gs_layout        TYPE lvc_s_layo,
      gs_variant       TYPE disvariant,
      gs_stbl          TYPE lvc_s_stbl,
      gs_row           TYPE lvc_s_row,
      gv_pos           TYPE lvc_colpos.

*&---------------------------------------------------------------------*
*& Define.
*&---------------------------------------------------------------------*
DEFINE: _clear.
  REFRESH: &1.    CLEAR: &1.
END-OF-DEFINITION.

DEFINE _matn1_input.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input  = &1
    IMPORTING
      output = &2.
END-OF-DEFINITION.

DEFINE _matn1_output.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      input  = &1
    IMPORTING
      output = &2.
END-OF-DEFINITION.
