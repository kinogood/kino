*&---------------------------------------------------------------------*
*& Include          ZGTSDR1185TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Tables.
*&---------------------------------------------------------------------*
TABLES: vbak,
        vbap,
        vbuk,
        vbpa,
        vbkd,
        likp,
        lips,
        knvi,
        knvv,
        t001cm,
        matdoc,
        j_1bt001wv.

TABLES: zsd0008t,
        zsdt0001,
        zsdt0002,
        zsdt0010,
        zsdt0011,
        zsds0010,
        zsds0011,
        ztstig0.

TABLES: sscrfields.

*&---------------------------------------------------------------------*
*& Internal Table / Structure.
*&---------------------------------------------------------------------*
*^ 검색된 거래처
DATA: BEGIN OF gt_kunnr OCCURS 0,
        kunnr  LIKE zsd0008t-kunnr,
        kkber  LIKE zsd0008t-kkber,
        zgubun LIKE zsd0008t-zgubun,
        bukrs  LIKE t001-bukrs,
      END   OF gt_kunnr.

*^ 거래처별 보증서 및 유효일자
DATA: BEGIN OF gt_req OCCURS 0,
        kunnr LIKE zsd0008t-kunnr,
        kkber LIKE zsd0008t-kkber,
        bukrs LIKE t001-bukrs,
        reqno LIKE zsdt0001-reqno,
        enddt LIKE zsdt0002-enddt,
      END   OF gt_req.

*^ 검색된 납품서, 품목
DATA: BEGIN OF gt_main OCCURS 0,
        vbeln     LIKE likp-vbeln,
        posnr     LIKE lips-posnr,
        vgbel     LIKE lips-vgbel,
        vgpos     LIKE lips-vgpos,
        werks     LIKE likp-werks,
        lfimg     LIKE lips-lfimg,
        vrkme     LIKE lips-vrkme,
        kunnr     LIKE likp-kunnr,
*        KUNAG  LIKE LIKP-KUNAG,
        knkli     LIKE likp-knkli,
        kkber     LIKE likp-kkber,
        matnr     LIKE lips-matnr,
        prodh     LIKE lips-prodh,
        wadat_ist LIKE likp-wadat_ist,
        wadat     LIKE likp-wadat,
        wbstk     LIKE vbuk-wbstk,
        bupla     LIKE zsdt0010-bupla         , "사업장
        arktx     LIKE lips-arktx,
        mbdat     LIKE lips-mbdat,
      END   OF gt_main.

*^ 매매계약서 헤더
DATA: BEGIN OF gt_head OCCURS 0,
        bukrs      LIKE t001cm-bukrs           , "회사코드
        vkorg      LIKE vbak-vkorg             , "영업조직
        vtweg      LIKE vbak-vtweg             , "유통경로
        spart      LIKE vbak-spart             , "제품군
        vkbur      LIKE vbak-vkbur             , "영업팀
        vkgrp      LIKE vbak-vkgrp             , "영업그룹
        kkbtx      LIKE t014t-kkbtx            , "여신영역명
        bupla      LIKE zsdt0010-bupla         , "사업장
        kunnr      LIKE zsdt0010-kunnr         , "고객
        name1      LIKE zsdt0010-name1         , "구매사명
        vbeln      LIKE lips-vbeln             , "납품문서
        seqno      LIKE zsdt0010-seqno         , "일련번호
        mjahr      LIKE matdoc-mjahr            , "자재문서년도
        mblnr      LIKE matdoc-mblnr            , "자재문서번호
        trano      LIKE zsdt0010-trano         , "전문번호
        wadat_ist  LIKE zsdt0010-wadat_ist     , "GI 일자
        stcd0      LIKE zsdt0010-stcd0         , "법인번호(판매처)
        stcd0_name LIKE zsdt0010-stcd0_name    , "사업자번호(판매처)
        stcd1      LIKE zsdt0010-stcd1         , "법인번호(구매처)
        stcd1_name LIKE zsdt0010-stcd1_name    , "사업자번호(구매처)
        name       LIKE zsdt0010-name          , "판매사명
        netwr      LIKE zsdt0010-netwr         , "정가
        waerk      LIKE zsdt0010-waerk         , "단위
        fkdat      LIKE zsdt0010-fkdat         , "대금청구일
        gubun      LIKE zsdt0010-gubun         , "담보보증구분
        damb_gubn  LIKE zsdt0010-damb_gubn     , "보증유형
        state      LIKE zsdt0010-state         , "전송상태
        tstate(10)                             , "전송상태 text
        message    LIKE zsdt0010-message       , "처리결과
        amend      TYPE n                      , "AMEND순번

        kkber      LIKE t001cm-kkber           , "여신영역
        vbeln_or   LIKE vbak-vbeln             , "영업문서
        adrnr      LIKE kna1-adrnr             , "주소
        vbtyp      LIKE vbak-vbtyp,
        chkbox,
        light(4),
      END   OF gt_head.

*^ 매매계약서 품목
DATA: BEGIN OF gt_item OCCURS 0,
        bukrs      LIKE t001cm-bukrs           , "회사코드
        vkorg      LIKE vbak-vkorg             , "영업조직
        vtweg      LIKE vbak-vtweg             , "유통경로
        spart      LIKE vbak-spart             , "제품군
        vkbur      LIKE vbak-vkbur             , "영업팀
        vkgrp      LIKE vbak-vkgrp             , "영업그룹
        kkbtx      LIKE t014t-kkbtx            , "여신영역명
        name       LIKE kna1-name1             , "구매사명
        wadat_ist  LIKE zsdt0010-wadat_ist     , "GI 일자
        trano      LIKE zsdt0010-trano         , "전문번호
        gubun      LIKE zsdt0010-gubun         , "담보보증구분
        damb_gubn  LIKE zsdt0010-damb_gubn     , "보증유형
        state      LIKE zsdt0010-state         , "전송상태
        tstate(10)                             , "전송상태 text
        amend      TYPE n                      , "AMEND순번
        bupla      LIKE zsdt0011-bupla         , "사업장
        kunnr      LIKE zsdt0011-kunnr         , "고객
        vbeln      LIKE lips-vbeln             , "납품문서
        seqno      LIKE zsdt0011-seqno         , "일련번호
        posnr      LIKE zsdt0011-posnr         , "납품품목
        matnr      LIKE zsdt0011-matnr         , "자재
        arktx      LIKE zsdt0011-arktx         , "자재내역
        lfimg      LIKE zsdt0011-lfimg         , "수량
        vrkme      LIKE zsdt0011-vrkme         , "단위
        char01     LIKE zsdt0011-char01        , "규격
        netpr      LIKE zsdt0011-netpr         , "단가
        hwbas      LIKE zsdt0011-hwbas         , "공급가액
        hwste      LIKE zsdt0011-hwste         , "세액
        netwr      LIKE zsdt0011-netwr         , "정가
        waerk      LIKE zsdt0011-waerk         , "통화
        vbeln_or   LIKE zsdt0011-vbeln_or      , "영업문서
        posnr_or   LIKE zsdt0011-posnr_or      , "영업품목
        bstkd      LIKE zsdt0011-bstkd         , "주문서명
        pernr      LIKE zsdt0011-pernr         , "담당자
        name1      LIKE zsdt0011-name1         , "납품장소
        ketdat     LIKE zsdt0011-ketdat        , "납품요청일
        char02     LIKE zsdt0011-char02        , "조장
        char03     LIKE zsdt0011-char03        , "드럼
        char04     LIKE zsdt0011-char04        , "냉동능력-RT
        char05     LIKE zsdt0011-char05        , "전압
        char06     LIKE zsdt0011-char06        , "수압
        char07     LIKE zsdt0011-char07        , "형체결력
        char08     LIKE zsdt0011-char08        , "시리즈

        kkber      LIKE t001cm-kkber           , "여신영역
        cuobj      LIKE vbap-cuobj,
      END   OF gt_item.

DATA: gt_selt  LIKE gt_item OCCURS 0 WITH HEADER LINE.

*&---------------------------------------------------------------------*
*& RANGES.
*&---------------------------------------------------------------------*
* 상태
RANGES: r_state FOR zsdt0010-state.

*&---------------------------------------------------------------------*
*& Values.
*&---------------------------------------------------------------------*
* 일련번호
DATA: g_seqno  LIKE zsdt0010-seqno.

DATA: gv_error(1).

*&---------------------------------------------------------------------*
*& CONSTANTS.
*&---------------------------------------------------------------------*
*^ 전문번호
CONSTANTS: c_b211(4) TYPE c VALUE 'B211',  "매매계약통보
           c_b213(4) TYPE c VALUE 'B213',  "매매계약변경
           c_b215(4) TYPE c VALUE 'B215'.  "매매계약취소

*^ 대출/담보보증구분
CONSTANTS: c_gubun(4) TYPE c VALUE 'GUAR'.  "담보보증

*^ 전송상태
CONSTANTS: c_state1(2) TYPE c VALUE '00', "성공
           c_state2(2) TYPE c VALUE '01', "eai 실패
           c_state3(2) TYPE c VALUE '99'. "데이터오류

* Constants: 권한유형
CONSTANTS: c_tp_vkorg(1) TYPE c VALUE '1', "영업조직
           c_tp_bukrs(1) TYPE c VALUE '6', "회사코드
           c_tp_kkber(1) TYPE c VALUE '5'. "여신영역

*&---------------------------------------------------------------------*
*& ALV
*&---------------------------------------------------------------------*
*^ alv
TYPE-POOLS: slis.                      " for reuse_alv-display_list

*- FUNCTION
DATA: gt_sort     TYPE slis_t_sortinfo_alv    WITH HEADER LINE,
      gs_layout   TYPE slis_layout_alv,
      gt_fieldcat TYPE slis_t_fieldcat_alv    WITH HEADER LINE,
      gt_events   TYPE slis_t_event           WITH HEADER LINE.

DATA: g_repid    LIKE sy-repid,
      g_inclname LIKE trdir-name.
DATA: g_variant          LIKE disvariant.
DATA: gx_variant         LIKE disvariant.

*- OBJECT
DATA: g_splitter TYPE REF TO cl_gui_splitter_container.
DATA: g_parent_head TYPE REF TO cl_gui_container,
      g_parent_item TYPE REF TO cl_gui_container.

DATA: g_grid_head   TYPE REF TO cl_gui_alv_grid,
      g_grid_item   TYPE REF TO cl_gui_alv_grid,
      g_docking_con TYPE REF TO cl_gui_docking_container.

DATA: gt_fieldh    TYPE lvc_t_fcat WITH HEADER LINE.
DATA: gt_sorth     TYPE lvc_t_sort WITH HEADER LINE.   " Sort
DATA: gs_layh      TYPE lvc_s_layo.

DATA: gt_fieldi    TYPE lvc_t_fcat WITH HEADER LINE.
DATA: gt_sorti     TYPE lvc_t_sort WITH HEADER LINE.   " Sort
DATA: gs_layi      TYPE lvc_s_layo.

DATA: gs_toolbar  TYPE stb_button.
DATA: gt_exclude  TYPE ui_functions.                  " ToolBar

DATA: g_dynnr     LIKE sy-dynnr.

*&---------------------------------------------------------------------*
*& Define.
*&---------------------------------------------------------------------*
DEFINE: _clear.
  REFRESH: &1.    CLEAR: &1.
END-OF-DEFINITION.
