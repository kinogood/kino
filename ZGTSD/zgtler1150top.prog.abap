*&---------------------------------------------------------------------*
*& Include          ZGTLER1150TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Tables.
*&---------------------------------------------------------------------*
TABLES: lips,     "SD 문서: 납품: 품목데이타
        likp,     "SD 문서: 납품 헤더데이타
        vbak,     "영업문서: 헤더데이타
        vbuk,     "영업문서: 헤더상태와 관리데이타
        vbup,     "영업문서: 품목상태
        vttk,     "선적헤더
        vttp,     "운송품목
        kna1,     "고객마스터의 일반데이타
        usr21,    "사용자이름 주소키 지정
        adrp,     "사원 (근무처주소서비스)
        t001w,    "플랜트/분기
        mch1,     "Batch (플랜트간 Batch 관리일 경우)
        lfa1,     "구매처마스터 (일반섹션)
        ekpo,     "구매문서품목
        t001l,
        zlet0005, "[LE] 통문 헤더
        zlet0006, "[LE] 통문 Line Item
        zlet0033,
        zlet0034,
        zlet0071,
        zlet0072,
        vbkd.     "영업문서: 비지니스데이타

TYPE-POOLS: slis, kkblo.

*&---------------------------------------------------------------------*
*& Internal Table / Structure.
*&---------------------------------------------------------------------*
* Data Tab
DATA: BEGIN OF gt_data OCCURS 0,
        iv_no           LIKE  zlet0005-iv_no,
        tknum           LIKE  vttk-tknum,       "선적번호
        exti2           LIKE  vttk-exti2,       "운전자명
        exti1           LIKE  vttk-exti1,       "차량번호
        sdabw           LIKE  vttk-sdabw,       "운임톤수
        tdlnr           LIKE  vttk-tdlnr,       "운송사
        tdlnr_t         LIKE  lfa1-name1,       "운송사
        tpbez           LIKE  kna1-name1,       "운송기사전화번호
        vkbur           LIKE  lips-vkbur,       "영업팀
        vkgrp           LIKE  lips-vkgrp,       "영업그룹
        kunnr           LIKE  likp-kunnr,       "납품처
        kunnr_t         LIKE  kna1-name1,
        kunag           LIKE  likp-kunag,       "판매처
        kunag_t         LIKE  kna1-name1,
        vsart           LIKE  likp-vsart,       "출하유형
        vbtyp           LIKE  likp-vbtyp,       "SD 문서범주
        vstel           LIKE  likp-vstel,       "출하지점
        lfart           LIKE  likp-lfart,       "납품유형
        wbstk(10),                      "제품이동상태(A:미완료,C:G/I완료)
        wbstk_t(10),                    "제품이동상태(A:미완료,C:G/I완료)
        vtweg           LIKE  lips-vtweg,       "유통경로
        spart           LIKE  lips-spart,       "제품군
        vbeln           LIKE  lips-vbeln,       "납품번호
        posnr           LIKE  lips-posnr,       "품목
        wadat           LIKE  likp-wadat,       "출고예정일자
        wadat_ist       LIKE  likp-wadat_ist,   "출고일자
        vgbel           LIKE  lips-vgbel,       "주문번호
        vgpos           LIKE  lips-vgpos,       "품목
        werks           LIKE  lips-werks,       "플랜트
        lgort           LIKE  lips-lgort,       " 저장위치
        matnr           LIKE  lips-matnr,       "자재
        arktx           LIKE  lips-arktx,       "자재내역
        charg           LIKE  lips-charg,       "배치
        lfimg           LIKE  lips-lfimg,       "납품수량
        vrkme           LIKE  lips-vrkme,       "단위
        meins           LIKE  lips-meins,       "기본단위
        umvkz           LIKE  lips-umvkz,
        umvkn           LIKE  lips-umvkn,
        mtart           LIKE  lips-mtart,       "제품유형
        chk_b,                          "검증완료 여부
        empst           LIKE  vbkd-empst,       "드럼 by song
        iv_type         LIKE  zlet0005-iv_type, "통문유형
        iv_type_nm(40),                         "통문유형명
        iv_date         LIKE  zlet0005-iv_date, "통문증발행일자
        packc(20),                              "포장재유형
        packg           LIKE  mara-matnr,       "포장재
        packg_t         LIKE  makt-maktx,
        length          TYPE p DECIMALS 3,
        length_c(30),
        length_so       TYPE p DECIMALS 3,
        length_so_c(30),
        factor          TYPE i,
        base(30),                      "
        detail(30),
        stripe(30),
        stripe_no(30),
        iden(30),
        charg_cnt       TYPE i,
        diff,
        chk,
        chk_a,
        so_grd          TYPE atwrt,
        so_grdt         TYPE atwtb,
        batch_grd       TYPE atwrt,
        batch_grdt      TYPE atwtb,
        lifsk           LIKE likp-lifsk,        " DO Header Block
        route           LIKE likp-route,        "운송경로
        shtyp           LIKE vttk-shtyp,
        ntgew           LIKE lips-ntgew,
        gewei           LIKE lips-gewei,
      END OF gt_data.

* Display Table.
DATA: BEGIN OF gt_list  OCCURS 0,
        vkgrp       LIKE vbak-vkgrp ,          " 영업그룹
        vkgrp_txt   LIKE tvgrt-bezei ,         " 영업그룹명
        iv_no       LIKE zlet0005-iv_no ,      " 거래명세표번호
        kunag_nm    LIKE adrc-name1 ,          " 판매처명
        kunnr_nm    LIKE adrc-name1 ,          " 납품처명
        zzyuscd     LIKE zgtsdt1103-zzyuscd ,  " 영업소코드
        tknum       LIKE vttk-tknum ,          " 선적번호
        vgbel       LIKE lips-vgbel ,          " 주문번호
        vgpos       LIKE lips-vgpos ,          " 항번
        maktx       LIKE lips-arktx ,          " 자재내역
        color       LIKE conf_out-atwrt ,      " 색상 ( PD_CA_COLOR_BASE )
        str         LIKE conf_out-atwrt ,      " Str ( PD_CA_COLOR_STRIPE )
        str_no      LIKE conf_out-atwrt ,      " 띄줄 ( PD_CA_COLOR_STRIPE_NO )
        kgw         TYPE /nfm/kgw ,            " 동량
        fiber_c     LIKE conf_out-atwrt ,      " F량 ( PD_CA_FIBER_NO_1ST )
        fiber       TYPE p DECIMALS 2,         " F량 계산.
        fiber_n     TYPE p DECIMALS 2 ,        " F량 ( 화면표시용 )
        lfimg       LIKE lips-lfimg ,          " 납품수량
        vrkme       LIKE lips-vrkme ,          " 단위
        length      LIKE conf_out-atwrt ,      " 조장 ( SAP_LENGTH_VKRME )
        factor      LIKE conf_out-atwrt ,      " 조장수 ( SAP_MILLCA_FACTOR )
        factor_n    TYPE p DECIMALS 0 ,        " 조장수 ( 화면표시용 )
        fixmg       LIKE vbap-fixmg ,          " OS.
        zgubun(15),                             " 구분
        out_wid     LIKE zedt0210-out_wid ,    " 폭/드럼
        plan_dia    LIKE zedt0210-plan_dia  ,  " 약경/드럼
        dr_weight   LIKE zedt0210-dr_weight ,  " 드럼무게/개
        total_brgew LIKE mara-brgew ,          " 총 중량(드럼포함)
        brgew       LIKE mara-brgew ,    " 중량
        ntgew       LIKE lips-ntgew,
        gewei       LIKE lips-gewei,
        route_txt   LIKE tvrot-bezei ,         " 운송경로명
        wadat       LIKE likp-wadat ,          " 출고요청일
        erdat       LIKE zlet0400-erdat,       " 입력일
*        city1       LIKE zlet0400-city1 ,      " 납지
        city1       TYPE C LENGTH 100 ,      " 납지
        pack_gubun  LIKE conf_out-atwtb,       " 포장구분
        remark      LIKE zlet0400-remark ,     " 특기사항
        zremark1    LIKE zlet0400-zremark1,    " 출하실요청사항
        lgort       LIKE lips-lgort,           " 저장위치
        vbeln       LIKE lips-vbeln ,          " 납풉번호
        posnr       LIKE lips-posnr ,          " 항번
        kunag       LIKE likp-kunag,           " 판매처
        kunnr       LIKE likp-kunnr ,          " 납품처
        wadat_ist   LIKE likp-wadat_ist ,      " 출고일
        matnr       LIKE lips-matnr ,          " 자재
        tdlnr       LIKE vttk-tdlnr ,          " 운송사
        bstnk       LIKE vbak-bstnk ,          " PO번호
        exti1       LIKE vttk-exti1 ,          " 차량번호
        exti2       LIKE vttk-exti2 ,          " 운전자명
        tpbez       LIKE vttk-tpbez ,          " 전화번호
        shtyp_txt   LIKE tvtkt-bezei ,         " 선적유형내역
        shtyp       LIKE vttk-shtyp ,          " 선적유형

**      No out
        werks       LIKE lips-werks,           " 플랜트
        vstel       LIKE likp-vstel,           " 출하지점
        mtart       LIKE lips-mtart,           " 제품유형
        iv_date     LIKE zlet0005-iv_date,     " 통문증발행일자
        lfart       LIKE likp-lfart,           " 납품유형
        iv_type     LIKE zlet0005-iv_type,     " 통문유형
        sdabw       LIKE  vttk-sdabw,          " 운임톤수
        extension1  LIKE zlet0400-extension1,  " 수령인
        tel_number  LIKE zlet0400-tel_number,  " 수령인 연락처
        route       LIKE likp-route,        "운송경로
*        alv_scol    TYPE lvc_t_scol,           " Cell color
*        alv_styl    TYPE lvc_t_styl,           " Style.
      END OF gt_list,
      gt_stab LIKE TABLE OF gt_list.

* Characteristic Data
DATA: BEGIN OF gt_char  OCCURS 0,
        vbeln      LIKE vbap-vbeln,
        posnr      LIKE vbap-posnr,
        matnr      LIKE vbap-matnr,
        color      LIKE conf_out-atwrt ,      " 색상 ( PD_CA_COLOR_BASE )
        str        LIKE conf_out-atwrt ,      " Str ( PD_CA_COLOR_STRIPE )
        str_no     LIKE conf_out-atwrt ,      " 띄줄 ( PD_CA_COLOR_STRIPE_NO )
        fiber      LIKE conf_out-atwrt ,      " F량 ( PD_CA_FIBER_NO_1ST )
        length     TYPE zgteweleng,
        factor     TYPE zgtewecnt,
        pack_gubun LIKE conf_out-atwtb ,      " 포장구분 ( PD_GA_PACKAGE_METHOD )
      END OF gt_char.

* OS / 구분 Field from Stock
*DATA: gt_estock   TYPE TABLE OF zgtsdsif0102.
DATA: gt_lstock   TYPE TABLE OF zgtsdsif0100,
      gt_lstock_d TYPE TABLE OF zgtsdsif0101,
      gt_estock   TYPE TABLE OF zgtsdsif0102,
      gt_estock_d TYPE TABLE OF zgtsdsif0103.


* Picking List Download
DATA: BEGIN OF gs_pick_head,
        vstel(25),         " 출하지점 + 출하지점명
        vkgrp(25),         " 영업그룹 + 영업그룹명
        wadat(25),         " 출하요청일 ( from / to )
        lgort(25),         " 저장위치 + 저장위치명
        prt_date(10),      " 출력일
        prt_time(8),       " 출력시간
      END OF gs_pick_head,

      BEGIN OF gs_picking,
        seq(4)          TYPE i,    " Line no
        type(1),           " Line Type: T: Total Sum, S:Sub Sum, N: Nomal.
        kunag_nm(15),      " 영업그룹명, 판매처명
        iv_stat(5),        " 거래명세서번호 유무( 유: 완, 무: Null )
        zzyuscd(2),        " 영업소코드
        vbeln(10),         " 주문번호
        posnr(6),          " 항번
        maktx           LIKE lips-arktx ,          " 자재내역
        color(15),         " 색상 ( PD_CA_COLOR_BASE )
        kgw(15),           " 동량
        fiber(15),         " F량 ( 화면표시값 )
        lfimg(15),         " 납품수량
        length(15),        " 조장 ( SAP_LENGTH_VKRME )
        factor(15),        " 조장수 ( 화면표시값 )
        fixmg(2),          " OS.
        zgubun(8),                             " 구분
        plan_dia(15),      " 약경
        out_wid(15),       " 폭
        total_brgew(15),   " 총중량
        route_txt       LIKE tvrot-bezei ,         " 운송경로명
        remark          LIKE zlet0400-remark ,     " 특기사항
        city1           LIKE zlet0400-city1 ,      " 납지
        pack_gubun(10),    " 포장구분
        wadat(10),         " 출고요청일
        erdat(10),         " 입력일
        lgort_nm(10),      " 저장위치명
        iv_no(15),         " 거래명세서번호
        tknum(10),         " 선적번호
      END OF gs_picking,
      gt_picking LIKE TABLE OF gs_picking.

DATA: BEGIN OF gt_iv_tab  OCCURS 0,
        iv_no   LIKE zlet0005-iv_no ,      " 거래명세표번호
        iv_date LIKE zlet0005-iv_date,     " 통문증발행일자
      END OF gt_iv_tab.

DATA: gt_cbm  TYPE TABLE OF zgtedsif0034,

      gt_0005 LIKE zlet0005   OCCURS 0 WITH HEADER LINE,
      gt_0006 LIKE zlet0006   OCCURS 0 WITH HEADER LINE,
      gt_2101 TYPE TABLE OF zgtsdt2101,
      gt_2102 TYPE TABLE OF zgtsdt2102,
*     Smartform Print.
      gt_otf  LIKE itcoo OCCURS 0 WITH HEADER LINE.

** 출력장수 별 Title 변경
DATA: BEGIN OF gt_prt_title  OCCURS 0,
        seq(1),
        title(10),
      END OF gt_prt_title.

*&---------------------------------------------------------------------*
*& Values.
*&---------------------------------------------------------------------*
DATA: gv_error(1),
      gv_line          TYPE i,
      gv_wadat_s       TYPE sy-datum,
      gv_wadat_t       TYPE sy-datum,
      gv_wadat_ist_s   TYPE sy-datum,
      gv_wadat_ist_t   TYPE sy-datum,
*     거래명세서 발행 Comfirm
      gv_title(100),
      gv_text1(100),
      gv_text2(100),
      gv_copies(1),
      gv_title_chk1(1),
      gv_title_chk2(1),
      gv_title_chk3(1),
      gv_title_chk4(1),
      gv_answer(1),

      gv_okcode        TYPE sy-ucomm,
      gv_save_cd       TYPE sy-ucomm,
      gv_okcode2       TYPE sy-ucomm,
      gv_save_cd2      TYPE sy-ucomm.

*&---------------------------------------------------------------------*
*& Ranges
*&---------------------------------------------------------------------*
DATA: gr_vl    like RANGE OF likp-vbeln,        " 납품문서
      gr_lfart LIKE RANGE OF likp-lfart,
      gr_vstel LIKE RANGE OF likp-vstel,
      gr_lgort LIKE RANGE OF t001l-lgort,
      gr_route LIKE RANGE OF likp-route.

*&---------------------------------------------------------------------*
*& For Excel OLE.
*&---------------------------------------------------------------------*
DATA: go_excel    TYPE ole2_object,
      go_workbook TYPE ole2_object,
      go_workopen TYPE ole2_object,
      go_sheet    TYPE ole2_object.

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
*& Define.
*&---------------------------------------------------------------------*
DEFINE: _clear.
  REFRESH: &1.    CLEAR: &1.
END-OF-DEFINITION.
