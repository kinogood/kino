*&---------------------------------------------------------------------*
*& Include          ZGTPPI2010TOP
*&---------------------------------------------------------------------*
TYPE-POOLS : slis.
INCLUDE <cl_alv_control>.
TABLES : zgtppt1010, zgtppt2000, zgtppt2030, zppt0107, marc.
*TABLES : ZGTPPT1010, marc, vbak, kna1, vbep, t001w, zgtppt2000, makt.

* 메인화면 Dislay
DATA : BEGIN OF gs_disp,
         zifkey       TYPE  zgtppt2030-zifkey,
         zstat        TYPE  icon_d,
         zmessage     TYPE  zgtppt2030-zmessage,
         zsystem_id   TYPE  zgtppt2030-zsystem_id,
         zsystem_desc TYPE  dd07v-ddtext,
         werks        TYPE  zgtppt2030-werks,
         spgcd        TYPE  zgtppt2030-spgcd,
         grpnr        TYPE  zgtppt2030-grpnr,
         ordno        TYPE  zgtppt2030-ordno,
         posnr        TYPE  zgtppt2030-posnr,
         linno        TYPE  zgtppt2030-linno,
         ifdat        TYPE  zgtppt2030-ifdat,
         iftim        TYPE  zgtppt2030-iftim,
         ifnam        TYPE  zgtppt2030-ifnam,
         zstatus      TYPE  zgtppt2000-zstatus,
         celltab      TYPE  lvc_t_styl,
         cellcol      TYPE  lvc_t_scol,
       END OF gs_disp.
DATA : gt_disp LIKE TABLE OF gs_disp.

DATA: BEGIN OF gt_sys OCCURS 0,
        fld_01 TYPE zgtppt2030-zsystem_id,
        fld_02 TYPE dd07v-ddtext,
      END OF gt_sys.

DATA: gt_header TYPE TABLE OF zgtppsif0018,
      gt_item   TYPE TABLE OF zgtppsif0019 WITH NON-UNIQUE SORTED KEY skey COMPONENTS grpnr.

DATA: gv_ok_code LIKE sy-ucomm.
DATA: gv_answer(1).
DATA: gv_fld01(10).
DATA: gv_fldtxt(20).

*-/ ALV Global Field
CLASS lcl_event_handler DEFINITION DEFERRED.
DATA : go_docking_container TYPE REF TO cl_gui_docking_container.
DATA : go_splitter TYPE REF TO cl_gui_splitter_container.
DATA : go_event_handler TYPE REF TO lcl_event_handler.

*-----------
*ALV GRID 100
DATA : go_contain_0100 TYPE REF TO cl_gui_docking_container.
DATA : go_grid_0100 TYPE REF TO cl_gui_alv_grid.
DATA : gs_variant TYPE disvariant.
DATA : gs_layout_0100 TYPE lvc_s_layo.
DATA : gt_sort_0100 TYPE lvc_t_sort.
DATA : gt_exclude_0100 TYPE ui_functions.
DATA : gt_fieldcat_0100 TYPE lvc_t_fcat.
DATA : go_object TYPE REF TO cl_alv_event_toolbar_set.
