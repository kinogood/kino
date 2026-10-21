*&---------------------------------------------------------------------*
*& Include          ZGTPPR2060TOP
*&---------------------------------------------------------------------*

TYPE-POOLS : slis.
INCLUDE <cl_alv_control>.

TABLES : marc, kna1, zsdt_d365_021, mara.

CONSTANTS: c_yellow TYPE c VALUE 'Y',           "2026.01.27.zlsgpp5.add.
           c_green  TYPE c VALUE 'G',           "2026.01.27.zlsgpp5.add.
           c_delete TYPE char6 VALUE 'DELETE'.  "2026.01.27.zlsgpp5.add.

DATA : gv_chk_date TYPE sy-datum.

* screen 100
DATA : BEGIN OF gs_main,
         stat_t      TYPE char10,
         basemonth   LIKE zsdt_d365_021-basemonth,
         cycltype    LIKE zsdt_d365_021-cycltype,
         vkbur       LIKE zsdt_d365_021-vkbur,
         pltype      LIKE zsdt_d365_021-pltype,
         itemname    LIKE zsdt_d365_021-itemname,
         zpjno       LIKE zsdt_d365_021-zpjno,
         zptxt       LIKE zgtcvsalesplan-zptxt,
         kunnr       LIKE zsdt_d365_021-kunnr,
         name1       LIKE kna1-name1,
         matnr       LIKE zsdt_d365_021-matnr,
         sul_no      LIKE zedt1000-sul_no,
         vrkme       LIKE zsdt_d365_021-vrkme,
         quantity_dp LIKE zsdt_d365_021-quantity_dp,
         meins       LIKE mara-meins,
         menge       LIKE mseg-menge, " 생산수량
         menge2      LIKE mseg-menge, " 환산수량
         oppstatus   LIKE zsdt_d365_021-oppstatus,
         ddtext      LIKE dd07t-ddtext,
         dptype      LIKE zsdt_d365_021-dptype,
         spart       LIKE zsdt_d365_021-spart,
         vbeln       LIKE zsdt_d365_021-vbeln,
         posnr       LIKE zsdt_d365_021-posnr,
         buname      LIKE zsdt_d365_021-businessunitidname,
         pernr       LIKE zsdt_d365_021-pernr,
         attr01      LIKE zsdt_d365_021-attr01, "2026.01.27.zlsgpp5.add.
         attr02      LIKE zsdt_d365_021-attr02, "2026.01.27.zlsgpp5.add.
         attr03      LIKE zsdt_d365_021-attr03, "2026.01.27.zlsgpp5.add.
         attr04      LIKE zsdt_d365_021-attr04, "2026.01.27.zlsgpp5.add.
         attr05      LIKE zsdt_d365_021-attr05, "2026.01.27.zlsgpp5.add.
         attr06      LIKE zsdt_d365_021-attr06, "2026.01.27.zlsgpp5.add.
         attr07      LIKE zsdt_d365_021-attr07, "2026.01.27.zlsgpp5.add.
         attr08      LIKE zsdt_d365_021-attr08, "2026.01.27.zlsgpp5.add.
         attr09      LIKE zsdt_d365_021-attr09, "2026.01.27.zlsgpp5.add.
         attr10      LIKE zsdt_d365_021-attr10, "2026.01.27.zlsgpp5.add.
         celltab     TYPE lvc_t_styl,
         matnr_color TYPE c,  "2026.01.27.zlsgpp5.add.
       END OF gs_main.

DATA : gt_main     LIKE TABLE OF gs_main,
       gt_main_org LIKE TABLE OF gs_main, "2026.01.27.zlsgpp5.add.
       gt_similar  LIKE TABLE OF gs_main, "2026.01.27.zlsgpp5.add.
       gt_main_400 LIKE TABLE OF gs_main. "2026.01.27.zlsgpp5.add.

DATA : gt_2080 TYPE TABLE OF zgtppt2080.

DATA : BEGIN OF gs_chk_basemonth,
         basemonth LIKE zsdt_d365_021-basemonth,
       END OF gs_chk_basemonth.
DATA : gt_chk_basemonth LIKE TABLE OF gs_chk_basemonth.

DATA : BEGIN OF gs_chk_2080,
         cycltype TYPE zsdt_d365_021-cycltype,
         vkbur    TYPE zsdt_d365_021-vkbur,
         itemname TYPE zsdt_d365_021-itemname,
         zpjno    TYPE zsdt_d365_021-zpjno,
         vbeln    TYPE zsdt_d365_021-vbeln,
         posnr    TYPE zsdt_d365_021-posnr,
       END OF gs_chk_2080.
DATA : gt_chk_2080 LIKE TABLE OF gs_chk_2080.

DATA : gt_week TYPE RANGE OF zsdt_d365_021-week.

* screen 200
DATA : BEGIN OF gs_main_200,
         plnid    LIKE zgtppt2080-plnid,
         itemname LIKE zsdt_d365_021-itemname,
         zpjno    LIKE zsdt_d365_021-zpjno,
         zptxt    LIKE zgtcvsalesplan-zptxt,
         kunnr    LIKE zsdt_d365_021-kunnr,
         name1    LIKE kna1-name1,
         matnr    LIKE zsdt_d365_021-matnr,
         alenr    LIKE zgtppt2080-alenr,
         check    LIKE icon-id,
         check2   LIKE icon-id,
         sul_no   LIKE zedt1000-sul_no,
         meins    LIKE mara-meins,
       END OF gs_main_200.
DATA : gt_main_200 LIKE TABLE OF gs_main_200.

DATA : gt_main_disp_200 TYPE REF TO data. "
FIELD-SYMBOLS : <gt_main_disp_200> TYPE table.

DATA: BEGIN OF gs_spmon,
        spmon TYPE spmon,
      END OF gs_spmon.
DATA: gt_spmon LIKE TABLE OF gs_spmon.

DATA : gt_range_spmon TYPE RANGE OF spmon.

* screen 300 판매계획 제외
DATA : BEGIN OF gs_main_300,
         plnid       LIKE zgtppt2080-plnid,
         basemonth   LIKE zsdt_d365_021-basemonth,
         cycltype    LIKE zsdt_d365_021-cycltype,
         vkbur       LIKE zsdt_d365_021-vkbur,
         itemname    LIKE zsdt_d365_021-itemname,
         zpjno       LIKE zsdt_d365_021-zpjno,
         zptxt       LIKE  zgtcvsalesplan-zptxt,
         matnr       LIKE zsdt_d365_021-matnr,
         vrkme       LIKE zsdt_d365_021-vrkme,
         quantity_dp LIKE zsdt_d365_021-quantity_dp,
         ddtext      LIKE dd07t-ddtext,
         dptype      LIKE zsdt_d365_021-dptype,
         vbeln       LIKE zsdt_d365_021-vbeln,
         posnr       LIKE zsdt_d365_021-posnr,
         chk_sales   TYPE char01,
         chk_simul   TYPE char01,
         celltab     TYPE lvc_t_styl,
       END OF gs_main_300.
DATA : gt_main_300 LIKE TABLE OF gs_main_300.

DATA : gv_chk_del_ok.

* 팝업 결과 변수
DATA : gv_answer TYPE char01.
* 자재코드 변경 내역 있음
DATA : gv_chk_edit TYPE char01.

DATA: gv_ok_code LIKE sy-ucomm.
DATA: gv_ok_code2 LIKE sy-ucomm.
DATA: gv_ok_code3 LIKE sy-ucomm.
DATA: gv_ok_code4 LIKE sy-ucomm.  "2026.01.30.zlsgpp5.add.

*-/ ALV Global Field
CLASS lcl_event_handler DEFINITION DEFERRED.
DATA : go_event_handler TYPE REF TO lcl_event_handler.

* screen 100
DATA : go_docking_0100 TYPE REF TO cl_gui_docking_container.
DATA : go_splitter_0100 TYPE REF TO cl_gui_splitter_container.
DATA : go_contain_0100 TYPE REF TO cl_gui_container.
DATA : go_contain_0200 TYPE REF TO cl_gui_container.
DATA : go_contain_top_0100 TYPE REF TO cl_gui_container.
DATA : go_dd_docu_0100      TYPE REF TO cl_dd_document.
DATA : go_grid_0100 TYPE REF TO cl_gui_alv_grid.
DATA : gs_variant TYPE disvariant.
DATA : gs_layout_0100 TYPE lvc_s_layo.
DATA : gt_exclude_0100 TYPE ui_functions.
DATA : gt_sort_0100 TYPE lvc_t_sort.
DATA : gt_fieldcat_0100 TYPE lvc_t_fcat.


* screen 100, bottom
DATA : go_grid_0200 TYPE REF TO cl_gui_alv_grid.
DATA : gs_variant_0200 TYPE disvariant.
DATA : gs_layout_0200 TYPE lvc_s_layo.
DATA : gt_exclude_0200 TYPE ui_functions.
DATA : gt_sort_0200 TYPE lvc_t_sort.
DATA : gt_fieldcat_0200 TYPE lvc_t_fcat.

* screen 300
DATA : go_docking_0300 TYPE REF TO cl_gui_docking_container.
DATA : go_grid_0300 TYPE REF TO cl_gui_alv_grid.
DATA : gs_variant_0300 TYPE disvariant.
DATA : gs_layout_0300 TYPE lvc_s_layo.
DATA : gt_exclude_0300 TYPE ui_functions.
DATA : gt_sort_0300 TYPE lvc_t_sort.
DATA : gt_fieldcat_0300 TYPE lvc_t_fcat.

* screen 400
DATA : go_docking_0400 TYPE REF TO cl_gui_docking_container.
DATA : go_grid_0400 TYPE REF TO cl_gui_alv_grid.
DATA : gs_variant_0400 TYPE disvariant.
DATA : gs_layout_0400 TYPE lvc_s_layo.
DATA : gt_exclude_0400 TYPE ui_functions.
DATA : gt_sort_0400 TYPE lvc_t_sort.
DATA : gt_fieldcat_0400 TYPE lvc_t_fcat.
