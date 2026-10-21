*&---------------------------------------------------------------------*
*& Include          ZGTLER1140TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Tables.
*&---------------------------------------------------------------------*
TABLES: likp,
        zlet0005,    " [LE] 통문 헤더.
        zlet0006,    " [LE] 통문 Line Item.
        zlet0007,    " [LE] 통문유형 코드.
        zlet0033.    " [LE] 거래명세서 - 사업장 매핑 (LE용).

*&---------------------------------------------------------------------*
*& Internal Table / Structure.
*&---------------------------------------------------------------------*
* [LE] 통문유형 코드
DATA: gt_0007   LIKE zlet0007 OCCURS 0 WITH HEADER LINE.

* 납품문서
DATA: BEGIN OF gt_tab OCCURS 0,
        iv_no        LIKE zlet0005-iv_no,     "거래선번호
        iv_type      LIKE zlet0005-iv_type,   "통문유형
        out_yn       LIKE zlet0005-out_yn,    "통문여부
        vbeln        LIKE lips-vbeln,         "납품문서
        posnr        LIKE lips-posnr,         "품목
        kunnr        LIKE likp-kunnr,         "거래처
        kunnr1       LIKE likp-kunnr,         "거래처
        umwrk        LIKE t001w-werks,
        tknum        LIKE vttk-tknum,         "선적번호
        matnr        LIKE lips-matnr,         "자재코드
        arktx        LIKE lips-arktx,         "자재내역
        vrkme        LIKE lips-vrkme,         "단위
        lfimg        LIKE lips-lfimg,         "납품수량
        werks        LIKE lips-werks,         "Plant
        route        LIKE likp-route,         "Router
        truck_no     LIKE zlet0005-truck_no,  "Truck no
        iv_date      LIKE zlet0005-iv_date,   "거래명세서 발행일
        driver_nm    LIKE zlet0005-driver_nm, "운전자
        driver_telno LIKE zlet0005-driver_telno, "운전자전화번호
        mblnr        LIKE zlet0006-mblnr,     "자재문서
        zeile        LIKE zlet0006-zeile,     "자재문서 ITEM
        mjahr        LIKE zlet0006-mjahr,     "자재문서 년도
        mtr_unit     LIKE zlet0006-mtr_unit,  "단위
        maktx        LIKE zlet0006-maktx,     "품명규격
        dmbtr        LIKE zlet0006-dmbtr,     "금액
        charg        LIKE lips-charg,         "배치값
        pernr        LIKE zlet0005-pernr,     "사원번호
        ename        LIKE zlet0005-ename,     "사원 또는 지원자 이름
        orgeh        LIKE zlet0005-orgeh,     "조직단위
        orgtx        LIKE zlet0005-orgtx,     "조직단위 Text
        asset_nm     LIKE zlet0006-asset_nm,  "자산명칭
        gdlgrp       LIKE zlet0006-gdlgrp,
        asset_spec   LIKE zlet0006-asset_spec, "자산용도/규격
        asset_etc    LIKE zlet0006-asset_etc, "기타
        asset_no     LIKE zlet0006-asset_no,  "자산번호
        charg_cnt    TYPE i,
        reqst        LIKE zlet0005-reqst,     "취소여부(기타통문일경우)
        lgort        LIKE zlet0006-lgort,
        charg_e      LIKE zlet0006-charg,     "기능개선 228147 - 추가
        rsnum        LIKE zlet0005-rsnum,  "예약번호,
        wbsta        LIKE lips-wbsta,
      END OF gt_tab.

DATA: BEGIN OF gt_out OCCURS 0,
        chk(1),                             "Check box
        iv_no        LIKE zlet0005-iv_no,     "거래선번호
        iv_type      LIKE zlet0005-iv_type,   "통문유형
        iv_tdes      LIKE zlet0007-iv_type_nm, "통문유형설명
        out_yn       LIKE zlet0005-out_yn,    "통문여부
        kunnr        LIKE likp-kunnr,         "납품처
        vbeln        LIKE lips-vbeln,         "납품번호
        posnr        LIKE lips-posnr,         "품목
        wadat        LIKE likp-wadat,         "출고일자
        vgbel        LIKE lips-vgbel,         "주문번호
        vgpos        LIKE lips-vgpos,         "품목
        matnr        LIKE lips-matnr,         "자재
        arktx        LIKE lips-arktx,         "자재내역
        vrkme        LIKE lips-vrkme,         "단위
        jojan        TYPE p,                  "조장
        jojsu(13)    TYPE p,                  "조장수
        gjosa        LIKE lips-lfimg,         "발행수(실제납품수량)
        color(10),                          "색상
        lfimg        LIKE lips-lfimg,          "납품수량
        packc(18),                          "포장재유형
        packg(18),                          "포장재
        packg_t      LIKE makt-maktx,
        tknum        LIKE vttk-tknum,         "선적번호
        tdlnr        LIKE vttk-tdlnr,          "운송업체
        tdlnr_t      LIKE lfa1-name1,
        name1        LIKE kna1-name1,         "업체명
        werks_t      LIKE kna1-name1,         "PLANT
        iv_date      LIKE zlet0005-iv_date,   "거래명세 발행일자
        driver_nm    LIKE zlet0005-driver_nm, "운송기사
        driver_telno LIKE zlet0005-driver_telno, "운전자전화번호
        mblnr        LIKE zlet0006-mblnr,     "자재문서
        zeile        LIKE zlet0006-zeile,     "자재문서 ITEM
        mjahr        LIKE zlet0006-mjahr,     "자재문서 년도
        mtr_unit     LIKE zlet0006-mtr_unit,  "단위
        maktx        LIKE makt-maktx,         "품명:규격
        truck_no     LIKE zlet0005-truck_no,  "Truck no
        dmbtr        LIKE zlet0006-dmbtr,     "금액
        pernr        LIKE zlet0005-pernr,     "사원번호
        ename        LIKE zlet0005-ename,     "사원이름 및 조직
        orgeh        LIKE zlet0005-orgeh,     "조직단위
        orgtx        LIKE zlet0005-orgtx,     "조직단위 Text
        werks        LIKE zlet0005-werks,     "Plant
        asset_nm     LIKE zlet0006-asset_nm,  "자산명칭
        gdlgrp       LIKE zlet0006-gdlgrp,
        asset_spec   LIKE zlet0006-asset_spec, "자산용도/규격
        asset_etc    LIKE zlet0006-asset_etc, "기타
        asset_no     LIKE zlet0006-asset_no,  "자산번호
        fg(1),
        alv_col      TYPE slis_t_specialcol_alv,
        lgort        LIKE zlet0006-lgort,  "창고번호
        rsnum        LIKE zlet0005-rsnum,  "예약번호
        wbsta        LIKE lips-wbsta,
      END OF gt_out,
      gs_out     LIKE gt_out,
      gt_confirm LIKE gt_out   OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_etab OCCURS 0,
        iv_no      LIKE  zlet0005-iv_no,
        mstxt(100),
      END OF gt_etab,
      BEGIN OF gt_stab OCCURS 0,
        iv_no LIKE  zlet0005-iv_no,
      END OF gt_stab.

* SD 통문 Data
DATA: gt_likp LIKE likp OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_lips OCCURS 0.
        INCLUDE STRUCTURE lips.
DATA:   auart LIKE vbak-auart,
      END OF gt_lips,
      gt_lips_uecha LIKE gt_lips OCCURS 0 WITH HEADER LINE,

      BEGIN OF gt_uecha_cnt OCCURS 0,
        vbeln     LIKE likp-vbeln,
        uecha     LIKE lips-uecha,
        lfimg     LIKE lips-lfimg,
        charg_cnt TYPE i,
      END OF gt_uecha_cnt.

* 배차정보 입력
DATA: BEGIN OF gs_car_info,
        truck_no     LIKE zlet0005-truck_no,     "Truck no
        driver_nm    LIKE zlet0005-driver_nm,    "운송기사
        driver_telno LIKE zlet0005-driver_telno, "운전자전화번호
      END OF gs_car_info,
      gs_car_temp LIKE gs_car_info.

* For BDC.
DATA: gt_bdcdata    LIKE  bdcdata  OCCURS 0 WITH HEADER LINE,
      gv_bdcmode(1) VALUE 'N'.

*&---------------------------------------------------------------------*
*& Values.
*&---------------------------------------------------------------------*
DATA: gv_error(1),
      gv_answer(1),
      gv_iv_type(3),
      gv_tot_cnt    TYPE i,
      gv_chk_cnt    TYPE i,
      gv_out_date   LIKE sy-datum,

      gv_okcode     TYPE sy-ucomm,
      gv_save_cd    TYPE sy-ucomm,
      gv_okcode2    TYPE sy-ucomm,
      gv_save_cd2   TYPE sy-ucomm,
      gv_okcode3    TYPE sy-ucomm,
      gv_save_cd3   TYPE sy-ucomm.

*&---------------------------------------------------------------------*
*& For ALV
*&---------------------------------------------------------------------*
DATA: go_event_handler TYPE REF TO lcl_event_handler,
      go_costom        TYPE REF TO cl_gui_custom_container,
      go_docking       TYPE REF TO cl_gui_docking_container,
      go_grid          TYPE REF TO cl_gui_alv_grid,

      gt_fcat          TYPE lvc_t_fcat,
      gt_toolbar       TYPE ui_functions,
      gt_sort          TYPE lvc_t_sort,   " ALV Sort
      gt_row           TYPE lvc_t_row WITH HEADER LINE,

      gs_layout        TYPE lvc_s_layo,
      gs_variant       TYPE disvariant,
      gs_stbl          TYPE lvc_s_stbl,
      gs_row           TYPE lvc_s_row,
      gv_pos           TYPE lvc_colpos.

*&---------------------------------------------------------------------*
*& Constants
*&---------------------------------------------------------------------*
CONSTANTS:
* BATCH
  gc_length(30)        VALUE 'SAP_MILLCA_LENGTH',        "조장
  gc_allength(30)      VALUE 'BT_AL_LENGTH',             "절단길이
  gc_factor(30)        VALUE 'SAP_MILLCA_FACTOR',        "조장수
  gc_packaging(30)     VALUE 'SAP_MILLCA_PACKAGING',     "포장재 코드
  gc_packaging_cat(30) VALUE 'SAP_MILLCA_PACKAGING_CAT', "포장재 유형
  gc_color(30)         VALUE 'PD_CA_COLOR_BASE'.         "색상

*&---------------------------------------------------------------------*
*& Define.
*&---------------------------------------------------------------------*
DEFINE: _clear.
  REFRESH: &1.    CLEAR: &1.
END-OF-DEFINITION.
