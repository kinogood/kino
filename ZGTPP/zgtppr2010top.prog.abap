*&---------------------------------------------------------------------*
*& Include          ZGTPPR2010TOP
*&---------------------------------------------------------------------*
TYPE-POOLS : slis.
INCLUDE <cl_alv_control>.
TABLES : zppt0107, marc, vbak, kna1, vbep, t001w, zgtppt2000, makt.
TABLES : zgtcv_stockval, zgtppt2010.

* 메인화면 Dislay
DATA : BEGIN OF gs_main_disp,
         status   TYPE char10,
         zstatus  TYPE zgtppt2000-zstatus,
         check    TYPE c LENGTH 1,
         grpnr    LIKE zgtppt2000-grpnr,
         erdat    LIKE zgtppt2000-erdat,
         gcatg    LIKE zgtppt2000-gcatg,
         ordno_c  TYPE char30,
         matnr    LIKE zgtppt2000-matnr,
         ordno    LIKE zgtppt2000-ordno,
         posnr    LIKE zgtppt2000-posnr,
         linno    LIKE zgtppt2000-linno,
         maktx    LIKE zgtppt2000-maktx,
         kunnr    LIKE zgtppt2000-kunnr,
         name1    LIKE kna1-name1,
         edatu    LIKE zgtppt2000-edatu,
         wmeng    LIKE zgtppt2000-wmeng,
         wmeng2   LIKE zgtppt2000-wmeng,  "DISPLAY용
         inlength LIKE zgtppt2000-inlength,
         meins    LIKE zgtppt2000-meins,
         infactor LIKE zgtppt2000-infactor,
         ernam    LIKE zgtppt2000-ernam,
         celltab  TYPE lvc_t_styl,
         cellcol  TYPE lvc_t_scol,
       END OF gs_main_disp.
DATA : gt_main_disp LIKE TABLE OF gs_main_disp.

DATA : BEGIN OF gs_seq_routing,
         seqno     TYPE i,   " 공정단계
         stufe     TYPE histu,
         matnr     TYPE matnr,
         mtart     TYPE mtart,
         chart     TYPE atwrt,
         chart_val TYPE  atwtb30,
         maabc     TYPE marc-maabc, "ABC 지시자
       END OF gs_seq_routing.
DATA : gt_seq_routing LIKE TABLE OF gs_seq_routing.
* 상세조장구성 테이블(Header)
DATA : BEGIN OF gs_main_200,
         grpnr    LIKE zgtppt2000-grpnr,
         erdat    LIKE zgtppt2000-erdat,
         gcatg    LIKE zgtppt2000-gcatg,
         ordno_c  TYPE char30,
         matnr    LIKE zgtppt2000-matnr,
         ordno    LIKE zgtppt2000-ordno,
         posnr    LIKE zgtppt2000-posnr,
         linno    LIKE zgtppt2000-linno,
         maktx    LIKE zgtppt2000-maktx,
         kunnr    LIKE zgtppt2000-kunnr,
         name1    LIKE kna1-name1,
         edatu    LIKE zgtppt2000-edatu,
         wmeng    LIKE zgtppt2000-wmeng,
         wmeng2   LIKE zgtppt2000-wmeng,  "DISPLAY용
         inlength LIKE zgtppt2000-inlength,
         meins    LIKE zgtppt2000-meins,
         infactor LIKE zgtppt2000-infactor,
         pack_yn  TYPE char20,
         pack_no  TYPE char20,
       END OF gs_main_200.
DATA : gt_main_200 LIKE TABLE OF gs_main_200.
DATA : gv_grpnr TYPE zgtppt2000-grpnr.

* 상세조장구성 테이블(Item)
DATA : gv_line_jojang TYPE i.

DATA : gt_main_201 TYPE REF TO data.
FIELD-SYMBOLS : <gt_main_201> TYPE table.

DATA : gt_routing TYPE REF TO data.
FIELD-SYMBOLS : <gt_routing> TYPE table.

DATA : BEGIN OF gs_2010.
         INCLUDE STRUCTURE zgtppt2010.
DATA :   use_chk    TYPE char01,
         status     TYPE char01,
         check_jego TYPE char01,
         chk_char   TYPE char02,
         chk_prd    TYPE char01, "생산중 확인
       END OF gs_2010.
DATA : gt_2010 LIKE TABLE OF gs_2010.

* 체크박스 선택을 위한 변수 선언
DATA : gv_chk_line TYPE i.
DATA : gv_chk_value.
DATA : gv_check_lock.

* 팝업 결과 변수
DATA : gv_answer TYPE char01.

* 추가여장 입력 화면 변수
DATA : gv_adtype TYPE zgteadtype.
DATA : gv_adlength TYPE zgteadlength.
DATA : gv_chk_exit.

* 고정스크랩편집 화면 변수.SRM2607-10582.2026.07.28.zlsgpp5.
DATA: BEGIN OF gs_0260,
        qlength TYPE zgtppt2010-qlength,
      END OF gs_0260.

* 설비변경 디스플레이 테이블
DATA : BEGIN OF gs_disp_arbpl,
         check TYPE char01,
         ktext LIKE crtx-ktext,
         arbpl LIKE crhd-arbpl,
         plnfl LIKE plas-plnfl,
       END OF gs_disp_arbpl.
DATA : gt_disp_arbpl LIKE TABLE OF gs_disp_arbpl.

DATA : gv_dupl_chk TYPE i.

* 오류처리 화면 디스플레이
DATA : BEGIN OF gs_del_disp,
         status  LIKE icon-id,
         ordnr   LIKE zgtppt2010-ordnr,
         ordty   LIKE zgtppt2010-ordty,
         message LIKE bapi_order_return-message,
       END OF gs_del_disp.
DATA : gt_del_disp LIKE TABLE OF gs_del_disp.

DATA : gv_disp_set TYPE char01.

* Pegging 선택화면
DATA : BEGIN OF gs_pegging,
         check   TYPE char01,
         types   TYPE char10,
         matnr   LIKE zgtcv_stockval-matnr,
         charg   LIKE zgtcv_stockval-charg,
         psmng   LIKE zgtcv_stockval-labst,
         labst   LIKE zgtcv_stockval-labst,
         insme   LIKE zgtcv_stockval-insme,
         speme   LIKE zgtcv_stockval-speme,
         meins   LIKE zgtcv_stockval-meins,
         lgort   LIKE zgtcv_stockval-lgort,
         maktx   LIKE makt-maktx,
         aufnr   LIKE afpo-aufnr,
         posnr   LIKE afpo-posnr,
         grpnr   LIKE zgtppt2010-grpnr,
         celltab TYPE lvc_t_styl,
       END OF gs_pegging.
DATA : gt_pegging LIKE TABLE OF gs_pegging.

* 가용수량 확인용 변수
DATA : gv_chk_psmng LIKE zgtcv_stockval-labst.
DATA : gv_chk_labst LIKE zgtcv_stockval-labst.
DATA : gv_chk_insme LIKE zgtcv_stockval-labst.
DATA : gv_chk_speme LIKE zgtcv_stockval-labst.

* 표준여장편집 화면 디스플레이
DATA : BEGIN OF gs_standard_adlength,
         matnr    TYPE matnr,
         vbeln    TYPE vbeln_va,
         posnr    TYPE posnr_va,
         inlength TYPE zgtppt2000-inlength,
         qlength  TYPE zgtppt2010-qlength,
         clength  TYPE zgtppt2010-clength,
       END OF gs_standard_adlength.
* 단일 오더, 전체 오더 확인
DATA : gv_chk_all.

* Pegging 화면 디스플레이
DATA : BEGIN OF gs_pegging_disp,
         gong_text TYPE char30,
         matnr     TYPE matnr,
         inlength  TYPE char10,
         matnr_re  TYPE matnr,
         maktx_re  TYPE maktx,
       END OF gs_pegging_disp.

DATA : gt_pegging_2010 TYPE TABLE OF zgtppt2010.
DATA : gv_pagging_gong_cd TYPE atwrt.

* 쉬스공정이 완제품아니고 연합 뒤에 올시 디스플레이모드 변경.
DATA : gv_chk_she.

DATA : gv_chk_subpool_dir_full.

DATA: gv_ok_code LIKE sy-ucomm.
DATA: gv_ok_code2 LIKE sy-ucomm.
DATA: gv_ok_code3 LIKE sy-ucomm.
DATA: gv_ok_code4 LIKE sy-ucomm.
DATA: gv_ok_code5 LIKE sy-ucomm.
DATA: gv_ok_code6 LIKE sy-ucomm.
DATA: gv_ok_code7 LIKE sy-ucomm.

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


*-----------
* ALV GRID 0200
DATA : go_contain_0200 TYPE REF TO cl_gui_container.
DATA : go_contain_top_0200 TYPE REF TO cl_gui_container.
DATA : go_grid_0200 TYPE REF TO cl_gui_alv_grid.
DATA : go_dd_docu_0200      TYPE REF TO cl_dd_document.
DATA : gs_layout_0200 TYPE lvc_s_layo.
DATA : gt_sort_0200 TYPE lvc_t_sort.
DATA : gt_exclude_0200 TYPE ui_functions.
DATA : gt_fieldcat_0200 TYPE lvc_t_fcat.

*-----------
* ALV GRID 0201
DATA : go_contain_0201 TYPE REF TO cl_gui_container.
DATA : go_grid_0201 TYPE REF TO cl_gui_alv_grid.
DATA : gs_layout_0201 TYPE lvc_s_layo.
DATA : gt_sort_0201 TYPE lvc_t_sort.
DATA : gt_exclude_0201 TYPE ui_functions.
DATA : gt_fieldcat_0201 TYPE lvc_t_fcat.


* ALV GRID 0220
DATA : go_contain_0220 TYPE REF TO cl_gui_docking_container.
DATA : go_grid_0220 TYPE REF TO cl_gui_alv_grid.
DATA : gs_layout_0220 TYPE lvc_s_layo.
DATA : gt_exclude_0220 TYPE ui_functions.
DATA : gt_fieldcat_0220 TYPE lvc_t_fcat.


* ALV GRID 0230
DATA : go_contain_0230 TYPE REF TO cl_gui_docking_container.
DATA : go_grid_0230 TYPE REF TO cl_gui_alv_grid.
DATA : gs_layout_0230 TYPE lvc_s_layo.
DATA : gt_exclude_0230 TYPE ui_functions.
DATA : gt_fieldcat_0230 TYPE lvc_t_fcat.

* ALV GRID 0240
DATA : go_contain_0240 TYPE REF TO cl_gui_custom_container.
DATA : go_grid_0240 TYPE REF TO cl_gui_alv_grid.
DATA : gs_layout_0240 TYPE lvc_s_layo.
DATA : gt_exclude_0240 TYPE ui_functions.
DATA : gt_fieldcat_0240 TYPE lvc_t_fcat.
