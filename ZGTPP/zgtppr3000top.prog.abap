*&--------------------------------------------------------------------*
*& Include          ZGTPPR3000TOP
*&--------------------------------------------------------------------*
TYPE-POOLS: icon.

TABLES : affw, afko, zgtppt3000, zedt0011, vbak.
***********************************************************************
*- 변수
***********************************************************************
DATA : gv_ok_code     LIKE sy-ucomm,
       gv_ok_code2    LIKE sy-ucomm,
       gv_ok_code3    LIKE sy-ucomm,
       gv_ok_code4    LIKE sy-ucomm,
       gv_ok_code5    LIKE sy-ucomm,
       gv_cnt(5)      TYPE c,
       gv_cnt2(5)     TYPE c,
       gv_cnt3(5)     TYPE c,
       gv_cnt4(5)     TYPE c,
       gv_error,
       gv_error2,
       gv_mandt       LIKE sy-mandt,
       gv_del_reason  LIKE zgtppt3000-del_reason,
       gv_reason_text LIKE zgtppt3000-reason_text,
       gv_details     LIKE zgtppt3000-details,
       gv_matnr       LIKE mara-matnr,
       gv_maktx       LIKE makt-maktx,
       gv_lgort       LIKE mard-lgort,
       gv_lgobe       LIKE t001l-lgobe,
       gv_meins       LIKE mara-meins,
       gv_matkl       LIKE mara-matkl,
       gv_answer      TYPE c,
       gv_tabix       LIKE sy-tabix.
DATA : gv_waers LIKE t001-waers.
*& 도움말 생성관련 구조 및 테이블정의...
DATA  : gs_selectfield  LIKE help_info-fieldname,
        gs_select_value LIKE help_info-fldvalue,
        gt_field        LIKE help_value OCCURS 0 WITH HEADER LINE,
        gt_dynpread     LIKE dynpread   OCCURS 0 WITH HEADER LINE,
        gt_dynpupdate   TYPE dynpread   OCCURS 0 WITH HEADER LINE,
        gt_row_no       TYPE lvc_t_roid WITH HEADER LINE,
        gt_row_now      TYPE lvc_t_roid WITH HEADER LINE.

DATA : gv_message(50),
       gv_message2(50),
       gv_message3(50),
       gv_message4(100),
       gv_text  TYPE char255.

DATA : gv_erfmg LIKE affw-erfmg.

DATA : gv_xchpf  TYPE marc-xchpf,
       gv_menge  LIKE zgtppt3070-menge,
       gv_charg  LIKE zgtppt3070-charg,
       gv_menge2 LIKE zgtppt3070-menge.

CONSTANTS : gc_x TYPE c VALUE 'X'.

RANGES : gr_meins FOR mara-meins,
         gr_matkl FOR mara-matkl,
         gr_matnr FOR mara-matnr.
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
         INCLUDE STRUCTURE affw.
DATA : icon(4), "상태
         message(100), "오류 메시지
         gubun(12), "오류 유형
         name1        LIKE t001w-name1, "플랜트 내역
         dsnam        LIKE t024d-dsnam, "MRP관리자 내역
         del_reason   LIKE zgtppt3000-del_reason, "삭제 사유 코드
         reason_text  LIKE zgtppt3000-reason_text, "삭제 사유 내역
         details      LIKE zgtppt3000-details, "상세 내역
         ename(20), "성명
         cname(20), "성명
         maktx        LIKE makt-maktx, "자재내역
         matkl        LIKE mara-matkl, "자재그룹
         wgbez60      LIKE t023t-wgbez60, "자재그룹내역
         pmatnr       LIKE afpo-matnr, "품목코드
         maktx2       LIKE makt-maktx, "품목명
         xchar        LIKE marc-xchar, "배치관리 지시자
         tagnr        LIKE zppt0001-tagnr, "꼬리표
         zup_tagnr    LIKE zgtppt3100-zup_tagnr, "모코드 투입 꼬리표
         gimng        LIKE affw-erfmg, "오류 수량
         enmng        LIKE affw-erfmg, "투입 완료 수량
         zserno       LIKE zgtppt3100-zserno, "Serial No.
         zsystem_id   LIKE zgtppt3100-zsystem_id, "Interface Target 시스템
*- Start 2025.05.13
         stprs        LIKE mbewh-stprs, "표준가
         money        LIKE mbewh-lbkum, "백로그 금액
         waers2       LIKE t001-waers, "통화키
*- Start 2025.06.10
         bstnk        LIKE vbak-bstnk, "제조지시번호
*- End 2025.06.10
*- End 2025.05.13
         celltab      TYPE lvc_t_styl,
         cellcol      TYPE lvc_t_scol,
       END OF gs_disp.
DATA : gt_disp LIKE TABLE OF gs_disp.
*- 저장위치 탐색도움말 관련
DATA : BEGIN OF gs_t001l,
         lgort LIKE t001l-lgort,
         lgobe LIKE t001l-lgobe,
       END OF gs_t001l.
DATA : gt_t001l LIKE TABLE OF gs_t001l.
*- 삭제 사유 코드 탐색도움말 관련
DATA : BEGIN OF gs_1010,
         fld_02 LIKE gs_zgtppt1010-fld_02,
         fld_03 LIKE gs_zgtppt1010-fld_03,
       END OF gs_1010.
DATA : gt_1010 LIKE TABLE OF gs_1010.
*- 생산 백로그 삭제 로그 관련
DATA : gt_zgtppt3000 LIKE TABLE OF zgtppt3000,
       gs_zgtppt3000 LIKE zgtppt3000.
*- COGI BDC 자재 관련
DATA : BEGIN OF gs_matnr,
         matnr LIKE affw-matnr,
       END OF gs_matnr.
DATA : gt_matnr LIKE TABLE OF gs_matnr.
*- Start 2025.05.02
DATA : BEGIN OF gs_weblnr,
         weblnr LIKE affw-weblnr,
       END OF gs_weblnr.
DATA : gt_weblnr LIKE TABLE OF gs_weblnr.
*- End 2025.05.02
*- BDC관련 구조 및 테이블 정의...
DATA  : BEGIN OF gt_bdcdata OCCURS 5.
          INCLUDE STRUCTURE bdcdata.
DATA  : END   OF gt_bdcdata.

DATA  : BEGIN OF gt_msgcoll OCCURS 1.
          INCLUDE STRUCTURE bdcmsgcoll.
DATA  : END   OF gt_msgcoll.

DATA  : gs_bdcparams LIKE ctu_params.           "BDC 매개변수

DATA : BEGIN OF gs_meins,
         meins LIKE mara-meins,
       END OF gs_meins.
DATA : gt_meins LIKE TABLE OF gs_meins.

DATA : BEGIN OF gs_matkl,
         matkl LIKE mara-matkl,
       END OF gs_matkl.
DATA : gt_matkl LIKE TABLE OF gs_matkl.
*- 실투입 처리 관련
TYPES : BEGIN OF sty_stock,
          matnr TYPE mard-matnr,
          werks TYPE mard-werks,
          lgort TYPE mard-lgort,
          labst TYPE mard-labst,
          meins TYPE mara-meins,
        END OF sty_stock,
        gty_stock TYPE TABLE OF sty_stock.

DATA : gs_stock TYPE sty_stock.

TYPES : BEGIN OF sty_stock2,
          werks TYPE marc-werks,
          matnr TYPE mchb-matnr,
          rgekz TYPE marc-rgekz,
          lgort TYPE mchb-lgort,
          charg TYPE mchb-charg,
          clabs TYPE mchb-clabs,
          budat TYPE matdoc-budat,
          meins TYPE mara-meins,
        END OF sty_stock2,
        gty_stock2 TYPE TABLE OF sty_stock2.

DATA : gs_stock2 TYPE sty_stock2,
       gt_stock2 TYPE gty_stock2.

DATA : BEGIN OF gs_batch,
         charg LIKE mchb-charg,
         menge LIKE affw-erfmg,
       END OF gs_batch.
DATA : gt_batch LIKE TABLE OF gs_batch.

TYPES : BEGIN OF sty_stock3,
          werks TYPE marc-werks,
          matnr TYPE mchb-matnr,
          rgekz TYPE marc-rgekz,
          lgort TYPE mchb-lgort,
          charg TYPE mchb-charg,
          menge TYPE mseg-menge,
          meins TYPE mara-meins,
        END OF sty_stock3,
        gty_stock3 TYPE TABLE OF sty_stock3.

DATA : gs_stock3 TYPE sty_stock3,
       gt_stock3 TYPE gty_stock3.

DATA : BEGIN OF gs_marc,
         matnr LIKE marc-matnr,
         werks LIKE marc-werks,
       END OF gs_marc.
DATA : gt_marc LIKE TABLE OF gs_marc.
DATA : BEGIN OF gs_marc2,
         matnr LIKE marc-matnr,
         werks LIKE marc-werks,
         xchar LIKE marc-xchar,
         xchpf LIKE marc-xchpf,
         dpcbt LIKE marc-dpcbt,
       END OF gs_marc2.
DATA : gt_marc2 LIKE TABLE OF gs_marc2.
*- 탐색도움말 관련
DATA: gt_fldtab TYPE dfies      OCCURS 0 WITH HEADER LINE,
      gt_rtntab LIKE ddshretval OCCURS 0 WITH HEADER LINE,
      gt_dselc  LIKE dselc OCCURS 0 WITH HEADER LINE.
*- 처리 결과 리스트 출력용
DATA : BEGIN OF gs_result,
         icon(4),   "재처리 상태
*         icon2(4), "배치 업데이트 상태
         message(100), "처리 결과
         gubun(12), "오류 유형
         weblnr       LIKE affw-weblnr, "백로그 번호
         weblpos      LIKE affw-weblpos, "백로그 아이템
         matnr        LIKE affw-matnr, " 자재코드
         maktx        LIKE makt-maktx, "자재내역
         werks        LIKE affw-werks, "플랜트
         lgort        LIKE affw-lgort, "저장위치
         charg        LIKE affw-charg, "배치번호
         erfmg        LIKE affw-erfmg, "수량
         erfme        LIKE affw-erfme, "단위
       END OF gs_result.
DATA : gt_result LIKE TABLE OF gs_result.
*- Start 2025.05.08
DATA : gs_affw  LIKE affw,
       gs_affw2 LIKE affw,
       gt_affw  LIKE TABLE OF affw.
DATA : gs_3100 LIKE zgtppt3100,
       gt_3100 LIKE TABLE OF zgtppt3100.
* 대체 자재 변경 업데이트용
DATA : gs_3270 LIKE zgtppt3270,
       gt_3270 LIKE TABLE OF zgtppt3270.
* 대체자재 변경 내역 화면
DATA : BEGIN OF gs_302,
         weblnr   LIKE affw-weblnr, "백로그 문서 번호
         weblpos  LIKE affw-weblpos, "백로그 문서 아이템
         seqno    LIKE zgtppt3270-seqno, "순번
         matnr_fr LIKE zgtppt3270-matnr_fr, "기존 자재코드
         maktx    LIKE makt-maktx, "기존 자재내역
         matnr_to LIKE zgtppt3270-matnr_to, "변경 자재코드
         maktx2   LIKE makt-maktx, "변경 자재내역
         crdat    LIKE zgtppt3270-crdat, "변경일자
         crtim    LIKE zgtppt3270-crtim, "변경시간
         crnam    LIKE zgtppt3270-crnam, "변경자
       END OF gs_302.
DATA : gt_302 LIKE TABLE OF gs_302.
*- End 2025.05.08
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

DATA : gv_stable TYPE lvc_s_stbl VALUE 'XX'.
*-----------
* ALV GRID 0102
DATA : go_contain_0102 TYPE REF TO cl_gui_docking_container.
DATA : go_grid_0102 TYPE REF TO cl_gui_alv_grid.
DATA : gs_layout_0102 TYPE lvc_s_layo.
DATA : gt_exclude_0102 TYPE ui_functions.
DATA : gt_fieldcat_0102 TYPE lvc_t_fcat.
*-----------
* ALV GRID 0302
DATA : go_contain_0302 TYPE REF TO cl_gui_docking_container.
DATA : go_grid_0302 TYPE REF TO cl_gui_alv_grid.
DATA : gs_layout_0302 TYPE lvc_s_layo.
DATA : gt_exclude_0302 TYPE ui_functions.
DATA : gt_fieldcat_0302 TYPE lvc_t_fcat.
