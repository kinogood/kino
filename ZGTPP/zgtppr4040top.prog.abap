*&---------------------------------------------------------------------*
*& Include          ZGTPPR4040TOP
*&---------------------------------------------------------------------*
***********************************************************************
* TABLES
***********************************************************************
TABLES : mard, zppt0107, t001w, afpo, zedt0011, crhd, ZPPT0600.

***********************************************************************
* Variable
***********************************************************************
DATA : gv_answer(1) TYPE c,
       gv_ok_code   LIKE sy-ucomm,
       gv_ok_code2  LIKE sy-ucomm,
       gv_exit,
       gv_tabix     LIKE sy-tabix,
       gv_aufnr     LIKE mseg-aufnr,
       gv_menge     LIKE mseg-menge,
       gv_erfmg     LIKE mseg-menge.

DATA : gt_row TYPE lvc_t_row.
DATA : gs_row TYPE lvc_s_row.
DATA : gv_start_day LIKE sy-datum,
       gv_end_day   LIKE sy-datum.
DATA : gs_scroll   TYPE lvc_s_stbl VALUE 'XX'.
***********************************************************************
* INTERNAL TABLE, Structure
***********************************************************************
*- 실사 데이터
DATA : gs_0600   LIKE zppt0600,
       gt_0600   LIKE TABLE OF zppt0600,
       gt_0600_1 LIKE TABLE OF zppt0600.
*- 재고 데이터
DATA : gs_stock LIKE zgtcv_stockval,
       gt_stock LIKE TABLE OF zgtcv_stockval.
*- 투입 데이터
DATA : BEGIN OF gs_mseg.
         INCLUDE STRUCTURE mseg.
DATA :   matnr2       LIKE zgtcvordsyval-matnr, "조회 조건 : 생산(반)제품
         pdcaproccode LIKE zgtcvordsyval-pdcaproccode, " 조회 조건 : 공정 코드
         arbpl        LIKE zgtcvordsyval-arbpl, "조회 조건 : 설비 코드
       END OF gs_mseg.
DATA : gt_mseg  LIKE TABLE OF gs_mseg, "이동 유형 : 101,102 데이터
       gt_mseg2 LIKE TABLE OF gs_mseg. "이동 유형 : 261,262 데이터
*- 투입 데이터 취합용 실사 자재
DATA : BEGIN OF gs_silsa,
         matnr LIKE mseg-matnr, "실사 사재
       END OF gs_silsa.
DATA : gt_silsa LIKE TABLE OF gs_silsa.
*- ALV 실사수량확인
DATA : BEGIN OF gs_disp,
         icon(4), "상태
         matnr   LIKE zppt0600-matnr, "자재 코드
         maktx   LIKE makt-maktx,     "자재 내역
         charg   LIKE zppt0600-charg, "배치 번호
         lgort   LIKE zppt0600-lgort, "저장위치
         btext   LIKE t064b-btext,    "재고 유형
         meins   LIKE zppt0600-meins, "단위
         jego    LIKE zppt0600-menge, "재고 수량
         silsa   LIKE zppt0600-menge, "실사 수량
         chai    LIKE zppt0600-menge, "차이량
         cellcol TYPE lvc_t_scol, "CELL COLOR
         celltab TYPE lvc_t_styl, "CELL STYLE
       END OF gs_disp.
DATA : gt_disp   LIKE TABLE OF gs_disp,
       gs_disp_1 LIKE gs_disp,
       gt_disp_1 LIKE TABLE OF gs_disp.
*- ALV 생산오더조정
DATA : BEGIN OF gs_disp2,
         icon(4), "상태
         werks        LIKE zgtcvordsyval-werks, "플랜트
         pdcaproccode LIKE zgtcvordsyval-pdcaproccode, "공정 코드
         arbpl        LIKE zgtcvordsyval-arbpl, "설비 코드
         aufnr        LIKE zgtcvordsyval-aufnr, "생산 오더
         matnr        LIKE zgtcvordsyval-matnr, "생산(반)제품
         maktx        LIKE makt-maktx, "내역
         menge1       LIKE mseg-menge, "입고량
         meins1       LIKE mseg-meins, "입고 단위
         matnr2       LIKE mseg-matnr, "투입 자재
         maktx2       LIKE makt-maktx, "내역
         charg2       LIKE mseg-charg, "투입 배치
         lgort2       LIKE mseg-lgort, "투입 저장위치
         erfmg2       LIKE mseg-erfmg, "투입량
         erfme2       LIKE mseg-erfme, "투입 단위
         menge3       LIKE mseg-menge, "가중치(%)
         menge4       LIKE mseg-menge, "계산 투입량
         lgort5       LIKE mseg-lgort, "조정 저장위치
         charg5       LIKE mseg-charg, "조정 배치
         erfmg5       LIKE mseg-erfmg, "조정량
         message(100), "처리 결과
         cellcol TYPE lvc_t_scol, "CELL COLOR
         celltab TYPE lvc_t_styl, "CELL STYLE
       END OF gs_disp2.
DATA : gt_disp2   LIKE TABLE OF gs_disp2,
       gs_disp2_1 LIKE gs_disp2,
       gt_disp2_1 LIKE TABLE OF gs_disp2, "가중치(%), 계산 투입량 계산용
       gs_disp2_2 LIKE gs_disp2,
       gt_disp2_2 LIKE TABLE OF gs_disp2.
***********************************************************************
* ALV
***********************************************************************
*-/ ALV Global Field
CLASS lcl_event_handler DEFINITION DEFERRED.
DATA : go_docking_container TYPE REF TO cl_gui_docking_container.
DATA : go_splitter TYPE REF TO cl_gui_splitter_container.
DATA : go_event_handler TYPE REF TO lcl_event_handler.
*-----------
*ALV GRID 100
DATA : go_contain_0100 TYPE REF TO cl_gui_container.
DATA : go_grid_0100 TYPE REF TO cl_gui_alv_grid.
DATA : gs_variant TYPE disvariant.
DATA : gs_layout_0100 TYPE lvc_s_layo.
DATA : gt_sort_0100 TYPE lvc_t_sort.
DATA : gt_exclude_0100 TYPE ui_functions.
DATA : gt_fieldcat_0100 TYPE lvc_t_fcat.
DATA : go_object TYPE REF TO cl_alv_event_toolbar_set.
*-----------
* ALV GRID 0101
DATA : go_contain_0101 TYPE REF TO cl_gui_container.
DATA : go_grid_0101 TYPE REF TO cl_gui_alv_grid.
DATA : gs_layout_0101 TYPE lvc_s_layo.
DATA : gt_sort_0101 TYPE lvc_t_sort.
DATA : gt_exclude_0101 TYPE ui_functions.
DATA : gt_fieldcat_0101 TYPE lvc_t_fcat.

***********************************************************************
* Macro
***********************************************************************
DEFINE __set_cell_attribute.
  ls_celltab-fieldname = &1.
  ls_celltab-style = &2.
END-OF-DEFINITION.
