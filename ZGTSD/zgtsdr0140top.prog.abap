*&---------------------------------------------------------------------*
*& Include          ZSDR0140TOP
*&---------------------------------------------------------------------*

*-------------------------------------------------------------------*
*   TABLE DECLARATION                                               *
*-------------------------------------------------------------------*
TABLES : kna1,
         vbkd,
         vbak,
         vbap,
         vbep,
         likp,
         lips,
         vbrk,
         vbrp,
         vbup,
         ztetfdp,              " [Export] Financial Document Item
         rlgrap.

*-------------------------------------------------------------------*
*   DATA DECLARATION (INTERNAL TABLE DECLARE)                       *
*-------------------------------------------------------------------*
DATA: BEGIN OF g_itab_t OCCURS 0,
        mark,
        kunag          LIKE likp-kunag,                  " 거래선
        name1          LIKE kna1-name1,                  " 지급처명
        bstkd          LIKE vbkd-bstkd,                  " 고객계약번호
        werks          LIKE lips-werks,                  " Plant
        wadat          LIKE likp-wadat_ist,              " G/I Date
        vbeln          LIKE lips-vbeln,                  " 납품번호
        posnr          LIKE lips-posnr,                  " 품목번호
*__ 배치번호 추가
        charg          LIKE lips-charg,                  " 배치번호
        uecha          LIKE lips-uecha,                  "
        vgbel          LIKE vbap-vbeln,                  " 영업문서
        vgpos          LIKE vbap-posnr,                  " 영업품목
        stawn          LIKE marc-stawn,                  " HS Code
        matnr          LIKE lips-matnr,                  " 자재
        maktx          LIKE makt-maktx,                  " 자재명
        lfimg          LIKE lips-lfimg,                  " 납품수량
        vrkme          LIKE lips-vrkme,                  " 판매단위(UOM)
        vrkme_o        LIKE vbap-vrkme,                " 판매단위-오더
        spart          LIKE vbak-spart,                  " 제품군
        waerk          LIKE vbap-waerk,                  " 통화
        waers          LIKE vbap-waerk,                  " 통화(KRW)
        netwr          LIKE vbap-netwr,         " 계약금액(납품수량*단가)
        kursk          LIKE vbkd-kursk,                  " 환율
        k_netwr        LIKE vbap-netwr,                " 계약금액(원화)
        kwmeng         LIKE vbap-kwmeng,                " 주문수량
        netpr          LIKE vbap-netpr,                  " 단가
        netpr2         TYPE p DECIMALS 5,                       " 단가2
        netpr_cash     LIKE vbap-netpr,
        offer_no(20),                           " Offer Number
        kunnr          LIKE vbak-kunnr,                  " 판매처
        kunnr2         LIKE vbak-kunnr,                 " 납품처
        name2          LIKE kna1-name1,                  " 납품처명
        payer          LIKE vbak-kunnr,                  " 지급처
        iv_date        LIKE zlet0005-iv_date,    " 거래명세서 발행일자
        zzcolor_base   LIKE mara-zzcolor_base,    " 색상Base
        zzral_code     LIKE mara-zzral_code,        " 상세색상
        zzcolor_stripe LIKE mara-zzcolor_stripe, " 색상Stripe
        zziden_code    LIKE mara-zziden_code,      " 절연선심식별
        zzspec_no      LIKE mara-zzspec_no,          " Spec No
        zzspec_detail  LIKE mara-zzspec_detail,  " Spec 상세

        auart          LIKE vbak-auart,                  " 오더Type
        vkbur          LIKE vbak-vkbur,                  " 영업팀
        bezei          LIKE tvkbt-bezei,                 " 영업팀명
        vkgrp          LIKE vbak-vkgrp,                  " 영업그룹
        bezei2         LIKE tvgrt-bezei,                " 영업그룹명

        vstel          LIKE likp-vstel,                 " 출하지점
        vkorg          LIKE vbak-vkorg,                 " 영업그룹
        vtweg          LIKE vbak-vtweg,                 " 유통경로
        mtart          LIKE lips-mtart,                 " 자재유형
*** 동량 추가
        cu_qty         LIKE  vbap-brgew,               " 동량
        al_qty         LIKE  vbap-brgew,               " AL량
* 최초 출고일 추가
        vbeln_o        LIKE vbap-vbeln,                "
        posnr_o        LIKE vbap-posnr,                "
        vbeln_v        LIKE likp-vbeln,                "최초 납품문서
        f_wadat        LIKE likp-wadat,                "최초 출고일
        sobkz          LIKE lips-sobkz,                "MTO,MTS구분
        prodh          LIKE vbap-prodh,                "제품계층구조
        empst          LIKE vbkd-empst,                "드럼번호
*[START CSR : C20100618_87084]
* 납품 예정일 추가
        edatu          LIKE vbep-edatu,
*[END CSR : C20100618_87084]
*[Start CSR : C20100928_44362]PJT&APPL번호 추가.
        zpjno          LIKE vbak-zpjno,
        zptxt          LIKE zsd0106t-zptxt,
*[End CSR : C20100928_44362]
        lfimg_ch       LIKE lips-lfimg,                  " 단위변환수량

*--[START]C20120628_36875 출하실적 조회 내용(튜브인쇄사양/조장) 추가 건
        length         LIKE zles020-length, "조장
        factor         LIKE zles020-factor, "조장수
        tb_print(30),
*--[END]C20120628_36875 출하실적 조회 내용(튜브인쇄사양/조장) 추가 건
        kdkg4          LIKE vbkd-kdkg4,
        bwart          LIKE lips-bwart,
        fkimg          LIKE vbrp-fkimg,
        sit_gi         LIKE vbrp-fkimg,
        sit_dt         LIKE likp-wadat_ist,
        bstnk          LIKE vbak-bstnk,
        salk3          LIKE zgtcot4180-salk3,

      END OF g_itab_t.

DATA : Gt_deli   TYPE TABLE OF shp_vbeln_range WITH HEADER LINE.
DATA : Gt_result TYPE TABLE OF mb5sit WITH DEFAULT KEY WITH HEADER LINE.

** 거래선/HS Code/자재/단가별 수량 및 금액 Sum
DATA: BEGIN OF g_sum_t OCCURS 0,
        kunag      LIKE likp-kunag,                  " 거래선
        stawn      LIKE marc-stawn,                  " HS Code
        matnr      LIKE lips-matnr,                  " 자재
        maktx      LIKE makt-maktx,                  " 자재명
        lfimg      LIKE lips-lfimg,                  " 납품수량
        vrkme      LIKE lips-vrkme,                  " 판매단위(UOM)
        waerk      LIKE vbap-waerk,                  " 통화
        netwr      LIKE vbap-netwr,         " 계약금액(납품수량*단가)
*           netpr like vbap-netpr,                  " 단가
        netpr(10),                              " 단가
        netpr2(15),                             " 단가
      END OF g_sum_t.

*--[START]C20120628_36875 출하실적 조회 내용(튜브인쇄사양/조장) 추가 건
DATA: gt_char1 LIKE conf_out OCCURS 0 WITH HEADER LINE.


CONSTANTS:
* SALES ORDER
  so_length(30)          VALUE 'SAP_LENGTH_VKRME',     "조장
  so_factor(30)          VALUE 'SAP_MILLCA_FACTOR',    "조장수 "사용안함
  ba_pd_tb_print_app(30) VALUE 'PD_TB_PRINT_APP'.   "튜브 인쇄사양
*--[END]C20120628_36875 출하실적 조회 내용(튜브인쇄사양/조장) 추가 건

** Header Text
DATA : g_h_offer(20),
       g_h_waerk       LIKE vbap-waerk,                           " (5),
       g_h_total       LIKE vbap-netwr,                           " (20),
       g_c_total(20),
       g_h_hsno(17),
       g_h_z081(132),
       g_h_z082(132),
       g_h_z091(132),
       g_h_z091_2(132),
       g_h_z091_3(132),
       g_h_z092(132),
       g_h_z093(132),
       g_h_z094(132),
       g_h_z095(132),
       g_h_z096(132),
       g_h_z097(132).

DATA : g_totcnt TYPE i.
DATA : lv_chul_qty LIKE vbap-kwmeng.

DATA : gv_change.         "기능개선 44758 - 추가

**========================
** BDC관련 Internal Table
**========================
** MESSAGES OF CALL TRANSACTION
DATA: g_msg_t LIKE bdcmsgcoll
              OCCURS 0 WITH HEADER LINE.

** BDCDATA DECLARE
DATA: BEGIN OF bdctab OCCURS 0.
        INCLUDE STRUCTURE bdcdata.
DATA: END OF bdctab.

DATA: BEGIN OF g_bdc_t OCCURS 0,
        mark,
        vbeln(10),              " 납품문서
        posnr(6),               " 납품품목
        offer_no(20),           " Offer No
        subrc        LIKE sy-subrc,    " BDC수행결과
        mesg(70),               " BDC메세지
      END OF g_bdc_t.

** 화면에 입력된 값을 읽어들이기 위한 INTERNAL TABLE
DATA : BEGIN OF g_dynpfields_t OCCURS 0.
         INCLUDE STRUCTURE dynpread.
DATA : END OF g_dynpfields_t.

** 납품별 Header Text를 가져오기 위한 Internal Table
DATA: BEGIN OF g_htext.
        INCLUDE STRUCTURE thead.
DATA: END OF g_htext.

DATA: BEGIN OF g_ltext OCCURS 50.
        INCLUDE STRUCTURE tline.
DATA: END OF g_ltext.

DATA: g_tname LIKE thead-tdname.

*{ SRM2403-04408 - 추가_S
DATA: gt_tvkbt LIKE tvkbt OCCURS 0 WITH HEADER LINE,
      gt_tvgrt LIKE tvgrt OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_vbep OCCURS 0,
        vbeln LIKE vbep-vbeln,
        posnr LIKE vbep-posnr,
        edatu LIKE vbep-edatu,
      END   OF gt_vbep.

DATA: BEGIN OF gt_vbpa OCCURS 0,
        vbeln LIKE vbpa-vbeln,
        posnr LIKE vbpa-posnr,
        parvw LIKE vbpa-parvw,
        kunnr LIKE vbpa-kunnr,
        lifnr LIKE vbpa-lifnr,
        adrnr LIKE vbpa-adrnr,
        name1 LIKE kna1-name1,
        name2 LIKE lfa1-name1,
        namad LIKE adrc-name1,
      END   OF gt_vbpa.

DATA: BEGIN OF gt_vbkd OCCURS 0,
        vbeln LIKE vbkd-vbeln,
        posnr LIKE vbkd-posnr,
        empst LIKE vbkd-empst,
      END   OF gt_vbkd.

DATA: BEGIN OF gt_vbfa_all OCCURS 0,
        vbelv LIKE vbfa-vbelv,
        posnv LIKE vbfa-posnv,
        vbeln LIKE vbfa-vbeln,
        posnn LIKE vbfa-posnn,
        bwart LIKE vbfa-bwart,
        erdat LIKE vbfa-erdat,
      END   OF gt_vbfa_all.

DATA: BEGIN OF gt_kna1 OCCURS 0,
        kunnr LIKE kna1-kunnr,
        name1 LIKE kna1-name1,
      END   OF gt_kna1.

DATA: BEGIN OF gt_mara OCCURS 0,
        matnr          LIKE mara-matnr,
        zzcolor_base   LIKE mara-zzcolor_base,    " 색상Base
        zzral_code     LIKE mara-zzral_code,      " 상세색상
        zzcolor_stripe LIKE mara-zzcolor_stripe,  " 색상Stripe
        zziden_code    LIKE mara-zziden_code,     " 절연선심식별
        zzspec_no      LIKE mara-zzspec_no,       " Spec No
        zzspec_detail  LIKE mara-zzspec_detail,   " Spec 상세
      END   OF gt_mara.

DATA: BEGIN OF gt_marc OCCURS 0,
        werks LIKE marc-werks,
        matnr LIKE marc-matnr,
        stawn LIKE marc-stawn,
      END   OF gt_marc.

DATA: BEGIN OF gt_zfdp OCCURS 0,
        vbeln LIKE ztetfdp-vbeln,
        posnr LIKE ztetfdp-posnr,
        wmeng LIKE ztetfdp-wmeng,
      END   OF gt_zfdp.

DATA: BEGIN OF gt_0005 OCCURS 0,
        vbeln   LIKE zlet0006-vbeln,
        posnr   LIKE zlet0006-posnr,
        iv_date LIKE zlet0005-iv_date,
      END   OF gt_0005.

DATA: BEGIN OF gt_0106 OCCURS 0,
        zpjno LIKE zsd0106t-zpjno,
        zptxt LIKE zsd0106t-zptxt,
      END   OF gt_0106.

DATA: gt_mats    TYPE TABLE OF zcharmats,
      gt_matvals TYPE TABLE OF zcharvals,
      gt_bats    TYPE TABLE OF zcharbats,
      gt_batvals TYPE TABLE OF zcharvals,
      gt_ords    TYPE TABLE OF zcharords,
      gt_ordvals TYPE TABLE OF zcharvals,
      gr_atnamm  TYPE TABLE OF eampic_sel_atnam,
      gr_atnamb  TYPE TABLE OF eampic_sel_atnam,
      gr_atnamo  TYPE TABLE OF eampic_sel_atnam.
*} SRM2403-04408 - 추가_E

** Smartform Internal table
DATA : BEGIN OF g_form_t OCCURS 0.
         INCLUDE STRUCTURE zsds001.
DATA : END OF g_form_t.

** 화면에 진행속도를 표시하기 위한 Buffer
DATA : status(01)      TYPE c,
       title(75)       TYPE c,
       title_1(80)     TYPE c,
       title_2(80)     TYPE c,
       winid(4)        TYPE c,
       pgmid(4)        TYPE c,
       popup_event(10) TYPE c,
       read_cnt(08)    TYPE n,
       total_cnt(08)   TYPE n,
       call_cnt        LIKE sy-tabix,
       persent         LIKE sy-tabix.

DATA: gt_vbfa      LIKE vbfa    OCCURS 0 WITH HEADER LINE.
DATA: gv_wadat_ist LIKE likp-wadat_ist.
DATA: c_vbtyp_n LIKE vbfa-vbtyp_n VALUE 'J',
      c_vbtyp_v LIKE vbfa-vbtyp_v VALUE 'J',
      c_lfart   LIKE likp-lfart   VALUE 'LF'.

DATA : gt_4180 TYPE TABLE OF zgtcot4180 WITH HEADER LINE.

*----------------------------------------------------------------------*
* SMART FORM PRINT DECLARATION
*----------------------------------------------------------------------*
**출력옵션 컨트롤위함.
DATA : options TYPE ssfcompop.
DATA : device  TYPE ssfctrlop.


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

*-------------------------------------------------------------------*
*   SELECTION SCREEN                                                *
*-------------------------------------------------------------------*
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECTION-SCREEN SKIP 1.

  SELECT-OPTIONS : so_wadat FOR likp-wadat_ist OBLIGATORY NO-EXTENSION,
                   so_vstel FOR likp-vstel NO INTERVALS.

*parameters : pa_vstel like likp-vstel no-display.
*select-options : so_vstel for likp-vstel NO-EXTENSION NO INTERVALS.

  SELECT-OPTIONS : so_auart FOR vbak-auart.

*parameters : pa_bstkd like vbkd-bstkd.
  SELECT-OPTIONS : so_bstkd FOR vbkd-bstkd NO INTERVALS.

  SELECT-OPTIONS : so_lfart FOR likp-lfart.

*parameters : pa_vtweg like vbak-vtweg.

  PARAMETERS : pa_vkorg LIKE vbak-vkorg OBLIGATORY MEMORY ID vko DEFAULT 1000.

  SELECT-OPTIONS : so_vtweg FOR vbak-vtweg NO-EXTENSION NO INTERVALS.

  SELECT-OPTIONS : so_spart FOR vbak-spart MEMORY ID spa,
                   so_vkbur FOR vbak-vkbur,
                   so_vkgrp FOR vbak-vkgrp.

  SELECT-OPTIONS : so_kunnr FOR vbak-kunnr NO-EXTENSION NO INTERVALS,
                   so_payer FOR vbak-kunnr NO-EXTENSION NO INTERVALS.

  SELECT-OPTIONS : so_fksta FOR vbup-fksta OBLIGATORY DEFAULT 'C'
                                NO INTERVALS,
                   so_absta FOR vbup-absta NO INTERVALS,
                   so_kdkg4 FOR vbkd-kdkg4 NO INTERVALS,
                   so_bstnk FOR vbak-bstnk NO INTERVALS MODIF ID m1,
                   so_zpjno FOR vbak-zpjno NO INTERVALS
                   MATCHCODE OBJECT zsd_pjnot.

  SELECTION-SCREEN SKIP 1.

  PARAMETERS: p_vari    LIKE disvariant-variant.

SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-003.
  SELECTION-SCREEN: BEGIN OF LINE.
    PARAMETERS      : r1     RADIOBUTTON GROUP rd1
                      USER-COMMAND ucomm .     "출고실적조회
    SELECTION-SCREEN COMMENT 4(15)  TEXT-004 FOR FIELD r1.
    PARAMETERS      : r2     RADIOBUTTON GROUP rd1.       "전체출고조회
    SELECTION-SCREEN COMMENT 27(15) TEXT-005 FOR FIELD r2.
    PARAMETERS      : r3     RADIOBUTTON GROUP rd1 DEFAULT 'X'.       "적송조회
    SELECTION-SCREEN COMMENT 50(15) TEXT-006 FOR FIELD r3.
  SELECTION-SCREEN: END OF LINE.
SELECTION-SCREEN END   OF BLOCK b2.

PARAMETERS    : p_new  DEFAULT 'X' NO-DISPLAY.
