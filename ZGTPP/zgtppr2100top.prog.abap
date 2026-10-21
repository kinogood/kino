*&---------------------------------------------------------------------*
*& Include          ZGTPPR2100TOP
*&---------------------------------------------------------------------*
***********************************************************************
* TABLES
***********************************************************************
TABLES : zgtppt2080, t001w, zedt0011, zgtppt2100, zppt0107.

INCLUDE <cl_alv_control>.

***********************************************************************
* Variable
***********************************************************************
DATA : gv_date_s  LIKE sy-datum,
       gv_date_e  LIKE sy-datum,
       gv_mon_cnt	LIKE vtbbewe-atage,
       gv_cnt(2)  TYPE i.

DATA : gv_ok_code LIKE sy-ucomm,
       gv_error,
       gv_tabix   LIKE sy-tabix.

DATA : gv_fieldname  TYPE fieldname,
       gv_fieldname2 TYPE fieldname,
       gv_fs1        TYPE fieldname,
       gv_fs2        TYPE fieldname,
       gv_columns    TYPE string.

FIELD-SYMBOLS : <gt_main_disp_100> TYPE table,
                <gs_line>          TYPE any,
                <gt_line>          TYPE table,
                <gs_main>          TYPE any,
                <gv_field>         TYPE any,
                <gv_field2>        TYPE any.

***********************************************************************
* INTERNAL TABLE, Structure
***********************************************************************
DATA : gs_2100 LIKE zgtppt2100,
       gt_2100 LIKE TABLE OF zgtppt2100,
       gs_plan LIKE zgtcvsalesplan,
       gt_plan LIKE TABLE OF zgtcvsalesplan.

DATA : BEGIN OF gs_data,
         plnid       LIKE zgtppt2080-plnid, "생산 계획 대상 ID
         spec        LIKE zgtppt2080-spec,  "규격
         zpjno       LIKE zgtppt2080-zpjno, "프로젝트 No.
         zptxt       LIKE zgtcvsalesplan-zptxt, "프로젝트명
         basemonth   LIKE zgtcvsalesplan-basemonth, "판매계획월
         vrkme       LIKE zgtcvsalesplan-vrkme, "판매단위
         quantity_dp LIKE vbap-zmeng, "판매계획량
         matnr_s     LIKE zgtcvsalesplan-matnr, "판매계획제품
         meins       LIKE zgtppt2100-meins, "생산단위
         gong_seq    LIKE zgtppt2100-gong_seq, "공정순번
         gong_cd     LIKE zgtppt2100-gong_cd, "공정
         matnr_fh    LIKE zgtppt2100-matnr, "완/반제품
         maktx       LIKE makt-maktx, "제품명
         simno       LIKE zgtppt2100-simno, "시뮬레이션
         simvr       LIKE zgtppt2100-simvr, "버전
         zspmon      LIKE zgtppt2100-zspmon, "생산계획월
         menge       LIKE zgtppt2100-menge, "생산계획량
       END OF gs_data.
DATA : gt_data LIKE TABLE OF gs_data.

DATA : BEGIN OF gs_month,
         month LIKE zgtppt2100-zspmon,
       END OF gs_month.
DATA : gt_month LIKE TABLE OF gs_month.
* 고정 ALV 필드
DATA : BEGIN OF gs_base,
         spec        LIKE zgtppt2080-spec,  "규격
         zpjno       LIKE zgtppt2080-zpjno, "프로젝트 No.
         zptxt       LIKE zgtcvsalesplan-zptxt, "프로젝트명
         basemonth   LIKE vbap-mfrgr, "판매계획월
         vrkme       LIKE zgtcvsalesplan-vrkme, "판매단위
         quantity_dp LIKE vbap-prodh, "판매계획량
         matnr_s     LIKE zgtcvsalesplan-matnr, "판매계획제품
         meins       LIKE zgtppt2100-meins, "생산단위
         gong_seq    LIKE zgtppt2100-gong_seq, "공정순번
         gong_cd     LIKE zgtppt2100-gong_cd, "공정
         matnr_fh    LIKE zgtppt2100-matnr, "완/반제품
         maktx       LIKE makt-maktx, "제품명
         simul       LIKE mara-pstat, "확정시뮬레이션
         hap         LIKE zgtppt2100-menge, "생산계획량 합계
       END OF gs_base.
DATA : gt_base LIKE TABLE OF gs_base.
* Display
DATA : gt_main_disp_100 TYPE REF TO data.

***********************************************************************
* ALV
***********************************************************************
CLASS lcl_event_handler DEFINITION DEFERRED.

DATA : go_event_handler TYPE REF TO lcl_event_handler.
* screen 100
DATA : go_docking_0100 TYPE REF TO cl_gui_docking_container.
DATA : go_splitter_0100 TYPE REF TO cl_gui_splitter_container.
DATA : go_contain_0100 TYPE REF TO cl_gui_container.
DATA : go_contain_top_0100 TYPE REF TO cl_gui_container.
DATA : go_dd_docu_0100 TYPE REF TO cl_dd_document.
DATA : go_grid_0100 TYPE REF TO cl_gui_alv_grid.
DATA : gs_variant TYPE disvariant.
DATA : gs_layout_0100 TYPE lvc_s_layo.
DATA : gt_exclude_0100 TYPE ui_functions.
DATA : gt_sort_0100 TYPE lvc_t_sort.
DATA : gt_fieldcat_0100 TYPE lvc_t_fcat.

***********************************************************************
* Macro
***********************************************************************
DEFINE __assign_field.
  CLEAR gv_fs1.
  gv_fs1 = &1.
  IF <gv_field> IS ASSIGNED. UNASSIGN <gv_field>. ENDIF.
  ASSIGN COMPONENT gv_fs1 OF STRUCTURE <gs_main> TO <gv_field>.
END-OF-DEFINITION.

DEFINE __assign_field2.
  CLEAR gv_fs2.
  gv_fs2 = &1.
  IF <gv_field2> IS ASSIGNED. UNASSIGN <gv_field2>. ENDIF.
  ASSIGN COMPONENT gv_fs2 OF STRUCTURE <gs_main> TO <gv_field2>.
END-OF-DEFINITION.
