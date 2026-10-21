*&-------------------------------------------------------*
*& Include          ZGTPPR3010TOP
*&-------------------------------------------------------*
TYPE-POOLS: icon.

TABLES : affw, afko, zgtppt3000, zedt0011.
***********************************************************************
*- 변수
***********************************************************************
DATA : gt_ucomm    TYPE TABLE OF sy-ucomm,
       gv_ok_code  LIKE sy-ucomm,
       gv_ok_code2 LIKE sy-ucomm,
       gv_ok_code3 LIKE sy-ucomm.

DATA : gv_cnt   TYPE sy-index,
       gv_cnt2  TYPE sy-index,
       gv_error.
***********************************************************************
*- TABLES, Structure
***********************************************************************
* 삭제 사유 코드 및 내역
DATA : gt_zgtppt1010 LIKE TABLE OF zgtppt1010,
       gs_zgtppt1010 LIKE zgtppt1010.
* 오류 생성자 명, 최종 변경자 명
DATA : gt_zpa0539 LIKE TABLE OF zpa0539,
       gs_zpa0539 LIKE zpa0539.
* DISPLAY 용
DATA : BEGIN OF gs_disp.
         INCLUDE STRUCTURE zgtppt3000.
DATA :   icon(4), "상태
         message(100), "오류 메시지
         name1        LIKE t001w-name1, "플랜트 내역
         dsnam        LIKE t024d-dsnam, "MRP관리자 내역
         ename(20), "성명
         cname(20), "성명
         dname(20), "성명
         maktx        LIKE makt-maktx, "자재내역
         matkl        LIKE mara-matkl, "자재그룹
         wgbez60      LIKE t023t-wgbez60, "자재그룹내역
         pmatnr       LIKE afpo-matnr, "품목코드
         maktx2       LIKE makt-maktx, "품목명
         erfmg_e      LIKE zgtppt3100-erfmg, "투입오류수량 20250107
         gubun(12), "오류 유형 20250107
         zserno       LIKE zgtppt3100-zserno,
         zsystem_id   LIKE zgtppt3100-zsystem_id,
         celltab      TYPE lvc_t_styl,
         cellcol      TYPE lvc_t_scol,
       END OF gs_disp.
DATA : gt_disp LIKE TABLE OF gs_disp.

DATA : gt_row_no TYPE lvc_t_roid WITH HEADER LINE.
* 생산 백로그 삭제 취소용
DATA : gt_affw LIKE TABLE OF affw,
       gs_affw LIKE affw.
* 상세 투입 팝업
DATA : BEGIN OF gs_popup,
         weblnr    LIKE zgtppt3101-weblnr, "실투입 오류 문서
         weblpos   LIKE zgtppt3101-weblpos, "오류 문서 아이템
         seqno     LIKE zgtppt3101-seqno, "순번
         matnr     LIKE zgtppt3101-matnr, "자재 번호
         maktx     LIKE makt-maktx, "자재 내역
         werks     LIKE zgtppt3101-werks, "플랜트
         lgort     LIKE zgtppt3101-lgort, "저장위치
         erfmg     LIKE zgtppt3101-erfmg, "투입 완료 수량
         erfme     LIKE zgtppt3101-erfme, "투입 단위
         charg     LIKE zgtppt3101-charg, "배치 번호
         tagnr     LIKE zgtppt3101-tagnr, "꼬리표번호
         zup_tagnr LIKE zgtppt3101-zup_tagnr, "모코드 투입 꼬리표
         budat     LIKE zgtppt3101-budat, "전기일
         mblnr     LIKE zgtppt3101-mblnr, "자재 문서 번호
         mjahr     LIKE zgtppt3101-mjahr, "자재 문서 연도
         crdat     LIKE zgtppt3101-crdat, "처리일자
         crtim     LIKE zgtppt3101-crtim, "처리시간
         crnam     LIKE zgtppt3101-crnam, "처리자
       END OF gs_popup.
DATA : gt_popup LIKE TABLE OF gs_popup.
***********************************************************************
*- ALV 정의
***********************************************************************
*& CLASS Reference 정의
CLASS: lcl_event_handler      DEFINITION DEFERRED,
       lcl_alv_grid           DEFINITION DEFERRED.

*& ALV Global Field
DATA : alv_variant LIKE disvariant,
       alv_repid   LIKE sy-repid.

* ALV Attribute
DATA : gt_exclude  TYPE ui_functions,    "Tool Bar Button저장
       gs_fieldcat TYPE lvc_s_fcat,      "필드 속성 Set
       gt_fieldcat TYPE lvc_t_fcat,      "필드 속성 저장
       gt_f4       TYPE lvc_t_f4,
       gs_f4       TYPE lvc_s_f4,                         "F4 필드
       gs_layocat  TYPE lvc_s_layo,      "Grid 속성 저장(Display)
       gt_sort     TYPE lvc_t_sort,
       gs_sort     TYPE lvc_s_sort,

       gs_scroll   TYPE lvc_s_stbl.

DATA : gv_repid     LIKE sy-repid,
       gv_title     TYPE lvc_title,
       gv_container TYPE scrfname VALUE 'CC_CONTAINER_0100'.

DATA : gt_scol TYPE lvc_t_scol WITH HEADER LINE,
       gs_colo TYPE lvc_s_colo.

*& Drop-Down List Box List.
DATA : gt_dropdown TYPE lvc_t_drop,
       gs_dropdown TYPE lvc_s_drop.

DATA : go_docking_container TYPE REF TO cl_gui_docking_container.
DATA : go_splitter TYPE REF TO cl_gui_splitter_container.
DATA : go_event_handler TYPE REF TO lcl_event_handler.

DATA : gv_stable TYPE lvc_s_stbl VALUE 'XX'.
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
*-----------
* ALV GRID 0200
DATA : go_contain_0200 TYPE REF TO cl_gui_docking_container.
DATA : go_grid_0200 TYPE REF TO cl_gui_alv_grid.
DATA : gs_layout_0200 TYPE lvc_s_layo.
DATA : gt_exclude_0200 TYPE ui_functions.
DATA : gt_fieldcat_0200 TYPE lvc_t_fcat.
