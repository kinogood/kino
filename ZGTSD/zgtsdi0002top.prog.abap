*&---------------------------------------------------------------------*
*& Include          ZGTSDI0002TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES : vbak, vbap, zgtsdt1003.

*----------------------------------------------------------------------*
* Class
*----------------------------------------------------------------------*
CLASS : lcl_event_receiver DEFINITION DEFERRED.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS : gc_e    TYPE char1 VALUE 'E',
            gc_x    TYPE char1 VALUE 'X',
            gc_kpcm TYPE zgtetarget VALUE 'KPCM',
            gc_kscm TYPE zgtetarget VALUE 'KSCM',
            gc_kbdm TYPE zgtetarget VALUE 'KBDM',
* [GO-SD][26.02.09] 가온전선 로직 분리  - Start.
            gc_kgom TYPE zgtetarget VALUE 'KGOM',
            gc_kgpm TYPE zgtetarget VALUE 'KGPM',
* [GO-SD][26.02.09] 가온전선 로직 분리  - End.
*[S] 한미소 MOM 전송 기능 추가
           gc_kmom TYPE zgtetarget VALUE 'KFCM'.
*[E] 한미소

CONSTANTS : gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf,
            gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab.


*----------------------------------------------------------------------*
* VARIABLE
*----------------------------------------------------------------------*
DATA : gv_saveok  LIKE sy-ucomm,
       gv_okcode  LIKE sy-ucomm,
       gv_error   TYPE char1,
       gv_tar     TYPE zgtetarget,
* [GO-SD][26.02.09] 가온전선 로직 분리  - Start.
       gv_go(1),
* [GO-SD][26.02.09] 가온전선 로직 분리  - End.
       gv_result  TYPE c LENGTH 2,
       gv_message TYPE string,
       gv_vbeln   LIKE vbak-vbeln,
       gv_answer  TYPE char1.

RANGES : gr_atnam FOR conf_out-atnam,
         gr_werks FOR vbap-werks,
         gr_vstel FOR vbap-vstel.
*----------------------------------------------------------------------*
* TYPE & STRUCTURE & INTERNAL TABLE
*----------------------------------------------------------------------*
DATA : gt_fcode   TYPE TABLE OF sy-ucomm,
       gt_celltab TYPE lvc_t_styl.

"ALV Default Fields
TYPES : BEGIN OF ty_s_alvdef,
          statu TYPE icon_d,     "신규/변경/삭제 상태 ICON
          msg   TYPE text100,
          insrt TYPE char1,      "신규 여부 Flag : 'X' or ' '
          modi  TYPE char1,      "변경 여부 Flag : 'X' or ' '
          sel   TYPE char1,
          cells TYPE lvc_t_styl, "Cell Style
          cellc TYPE lvc_t_styl, "Cell Color
        END OF ty_s_alvdef.

TYPES : BEGIN OF ty_s_chg,
          vkorg TYPE vkorg,
          matnr TYPE matnr,
        END OF ty_s_chg,
        ty_t_chg TYPE TABLE OF ty_s_chg
                   WITH NON-UNIQUE SORTED KEY key_mode
                   COMPONENTS vkorg.

DATA  : BEGIN OF gs_s0100,
          posnr     TYPE vbap-posnr,
          matnr     TYPE vbap-matnr,
          werks     TYPE vbap-werks,
          name1     TYPE kna1-name1,
          erzet     TYPE erzet,
          spart_nm  TYPE tspat-vtext,
          vkgrp_nm  TYPE tvgrt-bezei,
          vkbur_nm  TYPE tvkbt-bezei,
          ctlpc_nm  TYPE t691t-rtext,
          system_nm TYPE char20,
          crud      TYPE char10,
          changenr  TYPE cdhdr-changenr.

          INCLUDE    TYPE zgtsdt1003.
          INCLUDE    TYPE ty_s_alvdef. "ALV Default Fields
DATA : END OF gs_s0100.
DATA : gt_s0100     LIKE TABLE OF gs_s0100,
*       GT_HEADER  TYPE TABLE OF ZGTSDT1003 WITH HEADER LINE WITH EMPTY KEY,
*       GT_ITEM    TYPE TABLE OF ZGTSDT1004 WITH HEADER LINE WITH NON-UNIQUE SORTED KEY K_KEY COMPONENTS VBELN,
       gt_char      TYPE TABLE OF zgtsdt1005 WITH HEADER LINE WITH NON-UNIQUE SORTED KEY k_key COMPONENTS vbeln,
       gt_char_r    TYPE TABLE OF zgtsdt1005 WITH HEADER LINE WITH NON-UNIQUE SORTED KEY k_key COMPONENTS vbeln,
       gt_partner   TYPE TABLE OF zgtsdt1006 WITH HEADER LINE WITH NON-UNIQUE SORTED KEY k_key COMPONENTS vbeln,
       gt_partner_r TYPE TABLE OF zgtsdt1006 WITH HEADER LINE WITH NON-UNIQUE SORTED KEY k_key COMPONENTS vbeln,
       gt_1004_l    TYPE TABLE OF zgtsdt1004 WITH NON-UNIQUE SORTED KEY k_key COMPONENTS zifkey vbeln,
       gt_1005_l    TYPE TABLE OF zgtsdt1005 WITH NON-UNIQUE SORTED KEY k_key COMPONENTS zifkey vbeln,
       gt_1006_l    TYPE TABLE OF zgtsdt1006 WITH NON-UNIQUE SORTED KEY k_key COMPONENTS zifkey vbeln.

DATA  : BEGIN OF gs_item,
          changenr TYPE cdhdr-changenr.
          INCLUDE  TYPE zgtsdt1004.
DATA : END OF gs_item.
DATA : gt_item   LIKE TABLE OF gs_item WITH NON-UNIQUE SORTED KEY k_key COMPONENTS vbeln changenr,
       gt_item_r LIKE TABLE OF gs_item WITH NON-UNIQUE SORTED KEY k_key COMPONENTS vbeln changenr.

"화면 변경 정보
DATA : gt_chg   TYPE ty_t_chg.

* [GO-SD][26.02.09] 가온전선 로직 분리  - Start.
* 판매오더 송신 Data
DATA: gt_s0100_sel LIKE TABLE OF gs_s0100.

DATA: gt_if_head TYPE TABLE OF zgtsdsif0002,
      gt_if_item TYPE TABLE OF zgtsdsif0003,
      gt_if_char TYPE TABLE OF zgtsdsif0004,
      gt_if_prtn TYPE TABLE OF zgtsdsif0005,
      gt_if_drum TYPE TABLE OF zgtsdsif0095.

DATA: gt_1003_go    TYPE TABLE OF zgtsdt1003,
      gt_1004_go    TYPE TABLE OF zgtsdt1004,
      gt_1005_go    TYPE TABLE OF zgtsdt1005,
      gt_1006_go    TYPE TABLE OF zgtsdt1006,
      gt_1095_go    TYPE TABLE OF zgtsdt1095,
      gt_if_head_go TYPE TABLE OF zgtsdsif0002,
      gt_if_item_go TYPE TABLE OF zgtsdsif0003,
      gt_if_char_go TYPE TABLE OF zgtsdsif0004,
      gt_if_prtn_go TYPE TABLE OF zgtsdsif0005,
      gt_if_drum_go TYPE TABLE OF zgtsdsif0095.

DATA: BEGIN OF gt_vbeln  OCCURS 0,
        vbeln LIKE vbak-vbeln,
      END OF gt_vbeln,

      gt_change TYPE TABLE OF cdhdr.

DATA: BEGIN OF gt_log  OCCURS 0.
        INCLUDE TYPE zgtsdt1003.
DATA:   erzet LIKE vbak-erzet,
      END OF gt_log.
* [GO-SD][26.02.09] 가온전선 로직 분리  - End.

*----------------------------------------------------------------------*
*  ALV GRID.
*----------------------------------------------------------------------*

DATA : gt_toolbar TYPE ui_functions.
DATA : go_con     TYPE REF TO cl_gui_docking_container,
       go_grid    TYPE REF TO cl_gui_alv_grid,
       gt_fcat    TYPE lvc_t_fcat,
       gs_fcat    TYPE lvc_s_fcat,
       gt_sort    TYPE lvc_t_sort,   " ALV Sort
       gs_layout  TYPE lvc_s_layo,
       go_split   TYPE REF TO cl_gui_splitter_container,
       go_con_top TYPE REF TO cl_gui_container,
       go_docu    TYPE REF TO cl_dd_document.


DATA : gs_variant TYPE disvariant.
DATA : gs_stbl TYPE lvc_s_stbl.

DATA : gt_row TYPE lvc_t_row WITH HEADER LINE,
       gs_row LIKE gt_row.

*----------------------------------------------------------------------*
* Ranges
*----------------------------------------------------------------------*
* [GO-SD][26.02.09] 가온전선 로직 분리  - Start.
RANGES: gr_targ  FOR zgtsdt1002-zsystem_id,
        gr_auart FOR vbak-auart,
        gr_vkorg FOR vbak-vkorg,
        gr_vtweg FOR vbak-vtweg,
        gr_spart FOR vbak-spart.
* [GO-SD][26.02.09] 가온전선 로직 분리  - End.

*----------------------------------------------------------------------*
* DEFINE
*----------------------------------------------------------------------*
DEFINE __cle.
  CLEAR: &1, &1[].
END-OF-DEFINITION.

DEFINE __rng.
  &1-sign   = &2.
  &1-option = &3.
  &1-low    = &4.
  &1-high    = &5.
  APPEND &1. CLEAR &1.
END-OF-DEFINITION.

DEFINE __alpha_in.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = &1
    IMPORTING
      output = &2.
END-OF-DEFINITION.

DEFINE __alpha_ou.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = &1
    IMPORTING
      output = &2.
END-OF-DEFINITION.

DEFINE __get_rows.
  __cle : &2.
  CHECK &1 IS BOUND.
  CALL METHOD &1->get_selected_rows
     IMPORTING
       et_index_rows = &2[].

  DELETE &2 WHERE rowtype IS NOT INITIAL.

  CHECK &3 IS NOT INITIAL.


END-OF-DEFINITION.
