*&--------------------------------------------------------------------*
*& Include          ZGTPPR2070TOP
*&--------------------------------------------------------------------*
***********************************************************************
* TABLES
***********************************************************************
TABLES : zgtppt2120, zppt0107, t001w, sscrfields.
INCLUDE <cl_alv_control>.

* 2026.02.02.zlsgpp5.CHM2601-00657.
CONSTANTS: c_pd_ca_proc_gr TYPE ausp-atinn VALUE '0000004717'.

***********************************************************************
* Variable
***********************************************************************
DATA : gv_dyntxt       TYPE smp_dyntxt,
       gv_tabix        LIKE sy-tabix,
       gv_ok_code      LIKE sy-ucomm,
       gv_answer       TYPE c,
       gv_cnt(5)       TYPE c,
       gv_user_command TYPE c,
       gv_error        TYPE c,
       gv_icon(4)      TYPE c.

DATA : gv_spec  LIKE zgtppt2120-spec,
       gv_out   TYPE lvc_noout,
       gv_vgwrt TYPE vgwrt.
DATA : gv_matnr TYPE matnr.
DATA : gv_idnrk LIKE zgtppt2120-idnrk.

DATA : gv_fieldname  TYPE fieldname,
       gv_fieldname2 TYPE fieldname.

DATA : gv_fs1 TYPE fieldname,
       gv_fs2 TYPE fieldname,
       gv_fs3 TYPE fieldname,
       gv_fs4 TYPE fieldname,
       gv_fs5 TYPE fieldname,
       gv_fs6 TYPE fieldname,
       gv_fs7 TYPE fieldname,
       gv_fs8 TYPE fieldname,
       gv_fs9 TYPE fieldname.

DATA : gv_columns TYPE string.

FIELD-SYMBOLS : <gt_main_disp_100>   TYPE table,
                <gt_main_disp_100_2> TYPE table,
                <gs_line>            TYPE any,
                <gt_line>            TYPE table,
                <gs_main>            TYPE any,
                <gv_field>           TYPE any,
                <gv_field2>          TYPE any,
                <gv_field3>          TYPE any,
                <gv_field4>          TYPE any,
                <gv_field5>          TYPE any,
                <gv_field6>          TYPE any,
                <gv_field7>          TYPE any,
                <gv_field8>          TYPE any,
                <gv_field9>          TYPE any.

RANGES : gr_matnr FOR mara-matnr.
* CELL 속성
DATA : gt_celltab TYPE lvc_t_styl.
DATA : gs_celltab TYPE lvc_s_styl.
DATA : gv_fieldname3 TYPE fieldname.
FIELD-SYMBOLS <gt_celltab> TYPE any.
***********************************************************************
* INTERNAL TABLE, Structure
***********************************************************************
* 설비 Capa. 구성 관련 필요 데이터
DATA : gs_2080   LIKE zgtppt2080,
       gt_2080   LIKE TABLE OF zgtppt2080,
       gs_2120   LIKE zgtppt2120,
       gt_2120   LIKE TABLE OF zgtppt2120,
       gt_2120_s LIKE TABLE OF zgtppt2120,
       gs_char   LIKE zgtcvmstval,
       gt_char   LIKE TABLE OF zgtcvmstval,
       gs_1010   LIKE zgtppt1010,
       gt_1010   LIKE TABLE OF zgtppt1010.

DATA : BEGIN OF gs_2110,
         werks   LIKE zgtppt2110-werks,
         spgcd   LIKE zgtppt2110-spgcd,
         gong_cd LIKE zgtppt2110-gong_cd,
         arbpl   LIKE zgtppt2110-arbpl,
         objid   LIKE crhd-objid,
         seq     LIKE zgtppt2110-seq,
         ktext   LIKE crtx-ktext,
       END OF gs_2110.
DATA : gt_2110 LIKE TABLE OF gs_2110.

DATA : BEGIN OF gs_mat,
         matnr LIKE mara-matnr,
       END OF gs_mat.
DATA : gt_mat LIKE TABLE OF gs_mat.

DATA : gs_stb	   LIKE stpox,
       gt_stb    LIKE TABLE OF stpox,
       gs_matcat LIKE	cscmat,
       gt_matcat LIKE TABLE OF cscmat.

DATA : gs_mapl    LIKE mapl,
       gs_opr_tab LIKE capp_opr,
       gt_opr_tab LIKE TABLE OF capp_opr.

DATA : gt_row_no TYPE lvc_t_roid WITH HEADER LINE.
* 고정 ALV 필드
DATA : BEGIN OF gs_data,
         icon(4), "상태
         spec         LIKE zgtppt2080-spec,  "규격
         matnf        LIKE zgtppt2080-matnr, "완제품 코드(판매 기준)
         matnh        LIKE zgtppt2120-matnr, "반제품 코드
         pdcaprocname LIKE zgtcvmstval-pdcaprocname, "반제품 공정
         vgwrt1       LIKE zgtppt2120-vgwrt, "연속 생산일
         vgwrt2       LIKE zgtppt2120-vgwrt, "교체 소요일
         vge02        LIKE capp_opr-vge02,   "선속 단위
         zstate       LIKE zgtppt2120-zstate, "확인 상태
         matnh_f      LIKE zgtppt2120-matnr, "반제품 코드 기준 완제품
       END OF gs_data.
DATA : gt_data LIKE TABLE OF gs_data.
* Display
DATA : gt_main_disp_100   TYPE REF TO data,
       gt_main_disp_100_2 TYPE REF TO data.

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
DATA : go_dd_docu_0100      TYPE REF TO cl_dd_document.
DATA : go_grid_0100 TYPE REF TO cl_gui_alv_grid.
DATA : gs_variant TYPE disvariant.
DATA : gs_layout_0100 TYPE lvc_s_layo.
DATA : gt_exclude_0100 TYPE ui_functions.
DATA : gt_sort_0100 TYPE lvc_t_sort.
DATA : gt_fieldcat_0100   TYPE lvc_t_fcat.

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

DEFINE __assign_field3.
  CLEAR gv_fs3.
  gv_fs3 = &1.
  IF <gv_field3> IS ASSIGNED. UNASSIGN <gv_field3>. ENDIF.
  ASSIGN COMPONENT gv_fs3 OF STRUCTURE <gs_main> TO <gv_field3>.
END-OF-DEFINITION.

DEFINE __assign_field4.
  CLEAR gv_fs4.
  gv_fs4 = &1.
  IF <gv_field4> IS ASSIGNED. UNASSIGN <gv_field4>. ENDIF.
  ASSIGN COMPONENT gv_fs4 OF STRUCTURE <gs_main> TO <gv_field4>.
END-OF-DEFINITION.

DEFINE __assign_field5.
  CLEAR gv_fs5.
  gv_fs5 = &1.
  IF <gv_field5> IS ASSIGNED. UNASSIGN <gv_field5>. ENDIF.
  ASSIGN COMPONENT gv_fs5 OF STRUCTURE <gs_main> TO <gv_field5>.
END-OF-DEFINITION.

DEFINE __assign_field6.
  CLEAR gv_fs6.
  gv_fs6 = &1.
  IF <gv_field6> IS ASSIGNED. UNASSIGN <gv_field6>. ENDIF.
  ASSIGN COMPONENT gv_fs6 OF STRUCTURE <gs_main> TO <gv_field6>.
END-OF-DEFINITION.

DEFINE __assign_field7.
  CLEAR gv_fs7.
  gv_fs7 = &1.
  IF <gv_field7> IS ASSIGNED. UNASSIGN <gv_field7>. ENDIF.
  ASSIGN (gv_fs7) TO <gv_field7>.
END-OF-DEFINITION.

DEFINE __assign_field8.
  CLEAR gv_fs8.
  gv_fs8 = &1.
  IF <gv_field8> IS ASSIGNED. UNASSIGN <gv_field8>. ENDIF.
  ASSIGN COMPONENT gv_fs8 OF STRUCTURE <gs_main> TO <gv_field8>.
END-OF-DEFINITION.

DEFINE __assign_field9.
  CLEAR gv_fs9.
  gv_fs9 = &1.
  IF <gv_field9> IS ASSIGNED. UNASSIGN <gv_field9>. ENDIF.
  ASSIGN COMPONENT gv_fs9 OF STRUCTURE <gs_main> TO <gv_field9>.
END-OF-DEFINITION.

DEFINE __range_set.

  CLEAR gr_matnr.
  gr_matnr-sign   = 'I'.
  gr_matnr-option = 'EQ'.
  gr_matnr-low    = &1.
  APPEND gr_matnr.

END-OF-DEFINITION.

DEFINE __set_style.
  CLEAR gs_celltab.
  CLEAR gv_fieldname3.
  gv_fieldname3 = &1.
  gs_celltab-fieldname = gv_fieldname3.
  gs_celltab-style = CONV #( &2 ).
  INSERT gs_celltab INTO TABLE gt_celltab.
END-OF-DEFINITION.
