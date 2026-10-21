*&---------------------------------------------------------------------*
*& Include          ZGTLER2100TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Tables.
*&---------------------------------------------------------------------*
TABLES: mseg,    "문서세그멘트: 자재
        likp,    "SD 문서: 납품 헤더데이타
        lips,    "SD 문서: 납품: 품목데이타
        vbap,    "영업문서: 품목데이타
        vbak,    "영업문서: 헤더데이타
        vbuk.    "영업문서: 헤더상태와 관리데이타

*&---------------------------------------------------------------------*
*& Internal Table / Structure.
*&---------------------------------------------------------------------*
DATA: BEGIN OF gt_data OCCURS 0,
        vbeln     LIKE  lips-vbeln,    "납품문서
        uecha     LIKE  lips-uecha,    "
        posnr     LIKE  lips-posnr,    "납품항번
        vstel     LIKE  likp-vstel,    "출하/입고지점
        lfdat     LIKE  likp-lfdat,    "납품생성일
        wadat     LIKE  likp-wadat,    "출고일
        wadat_ist LIKE  likp-wadat_ist,
        kodat     LIKE  likp-kodat,    "피킹일
        route     LIKE  likp-route,    "Route
        kunnr     LIKE  likp-kunnr,    "납품처
        kunag     LIKE  likp-kunag,    "판매처
        matnr     LIKE  lips-matnr,    "자재번호
        maktx     LIKE  makt-maktx,    "자재품명
        charg     LIKE  lips-charg,    "뱃치번호
        werks     LIKE  lips-werks,    "플랜트
        lgort     LIKE  lips-lgort,    "저장위치
        meins     LIKE  lips-meins,    "기본단위
        lfimg     LIKE  lips-lfimg,    "납품수량
        vrkme     LIKE  lips-vrkme,    "판매단위
        vgbel     LIKE  lips-vgbel,    "영업문서
        vgpos     LIKE  lips-vgpos,    "영업문서 품목
        lgnum     LIKE  lips-lgnum,    "저장번호
        xchar     LIKE  lips-xchar,    "배치필드
        zmblnr    LIKE  mseg-mblnr,    "자재문서
        ablad     LIKE  likp-ablad,    "하역지점
        ntgew     LIKE  lips-ntgew,    "순중량
        brgew     LIKE  lips-brgew,    "총중량
        gewei     LIKE  lips-gewei,    "중량단위
        volum     LIKE  lips-volum,    "볼륨
        voleh     LIKE  lips-voleh,    "부피단위
        zmigo     LIKE  likp-zmigo,    "미입고 여부
      END OF gt_data.

* Report Header
DATA: BEGIN OF gt_head OCCURS 0,
        checkbox,                    "Check box
        vbeln     LIKE  likp-vbeln,    "납품번호
        vstel     LIKE  likp-vstel,    "출하지점/입고지점
        lfdat     LIKE  likp-lfdat,    "납품생성일
        wadat     LIKE  likp-wadat,    "출고일
        wadat_ist LIKE likp-wadat_ist,
        kodat     LIKE  likp-kodat,    "피킹일
        route     LIKE  likp-route,    "Router
        kunnr     LIKE  likp-kunnr,    "납품처
        rname     LIKE  kna1-name1,    "납품처 명
        kunag     LIKE  likp-kunag,    "판매처
        gname     LIKE  kna1-name1,    "판매처 명
        serks     LIKE lips-werks,     "입고 플랜트
        sgort     LIKE lips-lgort,     "입고 저장위치 - 입력.
        box,
        lights,
        expand,
        zcsfg(1),
      END OF gt_head.

* Report Detail
DATA: BEGIN OF gt_item OCCURS 0,
        checkbox,                    "Check box
        vbeln     LIKE  lips-vbeln,    "납품번호
        uecha     LIKE  lips-uecha,
        posnr     LIKE  lips-posnr,    "납품품목
        lfdat     LIKE  likp-lfdat,    "납품생성일
        kodat     LIKE  likp-kodat,    "피킹일
        wadat     LIKE  likp-wadat,    "출고일
        route     LIKE  likp-route,    "Router
        kunnr     LIKE  likp-kunnr,    "납품처
        kunag     LIKE  likp-kunag,    "판매처
        matnr     LIKE  lips-matnr,    "자재번호
        maktx     LIKE  makt-maktx,    "자재품명
        charg     LIKE  lips-charg,    "뱃치번호
        werks     LIKE  lips-werks,    "Plant
        lgort     LIKE  lips-lgort,    "창고번호
        meins     LIKE  lips-meins,    "기본단위
        lfimg     LIKE  lips-lfimg,    "납품수량
        menge     LIKE  lips-lfimg,    "Picking 수량
        vrkme     LIKE  lips-vrkme,    "판매단위
        vgbel     LIKE  lips-vgbel,    "수주번호
        vgpos     LIKE  lips-vgpos,    "수주항번
        zmblnr    LIKE  mseg-mblnr,    "자재문서번호
        ablad     LIKE  likp-ablad,    "하역지점
        ntgew     LIKE  lips-ntgew,    "순중량
        brgew     LIKE  lips-brgew,    "총중량
        gewei     LIKE  lips-gewei,    "중량단위
        volum     LIKE  lips-volum,    "볼륨
        voleh     LIKE  lips-voleh,    "부피단위
        kdauf     LIKE  lips-vbeln,    "ZCS 납품번호
        kdpos     LIKE  lips-posnr,    "ZCS 납품항번
*       JOJAN   TYPE  P DECIMALS 3,  "조장
        jojan     LIKE  lips-lfimg,    "조장
        jojsu(15),                   "조장수
        color(15),                   "색상
        box,
        lights,
        expand,
        zcsfg(1),                    "ZCS Order N개 여부
      END OF gt_item,
      gt_item_temp LIKE gt_item  OCCURS 0.

DATA: BEGIN OF gt_bapi_tab OCCURS 0,
        vbeln LIKE lips-vbeln,   "납품번호
        uecha LIKE lips-uecha,
        posnr LIKE lips-posnr,   "납품품목
        vgbel LIKE lips-vgbel,   "주문번호
        matnr LIKE lips-matnr,   "자재번호
        vgpos LIKE lips-vgpos,   "자재항번
        werks LIKE lips-werks,   "플랜트
        charg LIKE lips-charg,   "뱃치번호
        lgort LIKE lips-lgort,   "저장위치
        lfimg LIKE lips-lfimg,   "납품수량
        vrkme LIKE mseg-erfme,   "판매단위
        kdauf LIKE vbap-vbeln,   "ZCS주문번호
        kdpos LIKE lips-posnr,   "ZCS주문항번
        serks LIKE lips-werks,   "미고 BDC 플랜트
        sgort LIKE lips-lgort,   "미고 BDC 저장위치
        ablad LIKE likp-ablad,   "하역지점
      END OF gt_bapi_tab.

DATA: gt_mtab TYPE TABLE OF zles009,

      BEGIN OF gt_stab OCCURS 0,
        vbeln  LIKE lips-vbeln,
        posnr  LIKE lips-posnr,
        uecha  LIKE lips-uecha,
        zmblnr LIKE mseg-mblnr,
      END OF gt_stab.

*
DATA: BEGIN OF gs_sgort,
        werks TYPE werks_d,
        name1 TYPE name1,
        lgort TYPE lgort_d,
        lgobe TYPE lgobe,
      END OF gs_sgort.

*&---------------------------------------------------------------------*
*& Values.
*&---------------------------------------------------------------------*
DATA: gv_error(1),
      gv_line     TYPE i,
      gv_boxnam   TYPE slis_fieldname VALUE  'CHECKBOX',

      gv_okcode   TYPE sy-ucomm,
      gv_save_cd  TYPE sy-ucomm,
      gv_okcode2  TYPE sy-ucomm,
      gv_save_cd2 TYPE sy-ucomm.

*&---------------------------------------------------------------------*
*& For ALV
*&---------------------------------------------------------------------*
DATA: go_event_handler TYPE REF TO lcl_event_handler,

      go_docking       TYPE REF TO cl_gui_docking_container,
      go_split         TYPE REF TO cl_gui_splitter_container,

      go_cont_h        TYPE REF TO cl_gui_container,
      go_grid_h        TYPE REF TO cl_gui_alv_grid,
      gt_fcat_h        TYPE lvc_t_fcat,
      gt_toolbar_h     TYPE ui_functions,
      gt_sort_h        TYPE lvc_t_sort,   " ALV Sort
      gs_layout_h      TYPE lvc_s_layo,
      gs_variant_h     TYPE disvariant,

      go_cont_i        TYPE REF TO cl_gui_container,
      go_grid_i        TYPE REF TO cl_gui_alv_grid,
      gt_fcat_i        TYPE lvc_t_fcat,
      gt_toolbar_i     TYPE ui_functions,
      gt_sort_i        TYPE lvc_t_sort,   " ALV Sort
      gs_layout_i      TYPE lvc_s_layo,
      gs_variant_i     TYPE disvariant,

      gt_row           TYPE lvc_t_row WITH HEADER LINE,

      gs_variant       TYPE disvariant,
      gs_stbl          TYPE lvc_s_stbl,
      gs_row           TYPE lvc_s_row,
      gv_pos           TYPE lvc_colpos.

*&---------------------------------------------------------------------*
*& Ranges
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Define.
*&---------------------------------------------------------------------*
DEFINE: _clear.
  REFRESH: &1.    CLEAR: &1.
END-OF-DEFINITION.
