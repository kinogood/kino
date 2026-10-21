*&---------------------------------------------------------------------*
*& Include          ZGTSDR1330TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   TABLES
*----------------------------------------------------------------------*
tables : vbak,
         vbap,
         vbpa,
         vbkd,
         likp,
         lips,
         vbcom,
         s006,
         t179t,
         vttk,
         vbuk,
         vbep,
         zsd0098t,
         t052u.

data: gt_list_tmp like zgtsds1110 occurs 0 with header line.
**data: gt_list like zgtsds1110 occurs 0 with header line.
data: begin of gt_list occurs 0.
        include structure zgtsds1110.
data:   lstock_in   type  zgtelstock,
        in_qty2     type  zgtelstock,
        mill_length type  zgteweleng,
        pstyv       type  vbap-pstyv,
        ettyp       type  vbep-ettyp,
        poqty_meins type  bstmg,
        abgru        type abgru,

*        prod_cmpl type c,
*        in_dats   type datum,
      end of gt_list.

data : gt_so type table of vbap. "SO item key용

data: begin of gt_dlv_su occurs 0, " 납품과 거부사유가 있는 오더
        vbeln     type vbeln,
        posnr     type posnr,
        abgru     type abgru,
        kwmeng    type kwmeng,
        vrkme     type vrkme,
        dlvqty_su type kwmeng,
      end of gt_dlv_su.

data: begin of gt_prod occurs 0,
        vbeln   type vbeln,
        posnr   type posnr,
        matnr   type matnr,
        vrkme   type vrkme,

        linkqty type zgteweleng, "link stock
      end of gt_prod.

data: begin of gt_lstock occurs 0,
        vbeln     type vbeln,
        posnr     type posnr,
        matnr     type matnr,
        vrkme     type vrkme,

        in_dats   type datum,      "입고일자 from: 생산, oem, 정조장, 절단
        kalab     type labst,      "so 재고
        kalab_po  type labst,      "so 재고: 외주처
        lstock    type zgteweleng, "정재고
        so_lstock type zgteweleng, "정재고 for SO , 재고 계산용

        lcut_plan type zgteweleng, "절단지시 수량
        lcut_open type zgteweleng, "절단지시 OPEN 수량, SO물고 있는 수량
        lcut_comp type zgteweleng, "절단완료 수량
        lcut_dats type dats,       "절단완료 일자
      end of gt_lstock.

data: begin of gt_mchb1 occurs 0, " 소재용 입고 물량 가져오는 테이블
        matnr  type matnr,
        atwrt  type atwrt,
        meins  type meins,
        clabs  type labst,
        gidate type char8, "datum,
      end of gt_mchb1.

types : begin of ty_do,
          vbeln_vl  type vbeln_vl,
          posnr_vl  type posnr_vl,
          uecha     type uecha,
          vbeln     type vbeln,
          posnr     type posnr,
          erdat     type erdat,
          matnr     type matnr,
          lfimg     type lfimg,
          wbsta     type wbsta,
          wadat     type wadat,
          wadat_ist type wadat_ist,
          bwart     type bwart,
          lfart     type lfart,
          kostk     type kostk,
          kosta     type kosta,
          pikmg     type pikmg,
          vbtyp     type vbtyp,
          werks     type werks_d,
          vstel     type vstel,
          matkl     type matkl,
          arktx     type arktx,
          pstyv     type pstyv,
          zbcf      type likp-zbcf,
        end of ty_do.
types : ty_do_tab type table of ty_do.

types : begin of ty_mv,
          vbeln type vbeln,
          posnr type posnr,
          matnr type matnr,
          meins type meins,
          menge type menge_d,
        end of ty_mv.
types : ty_mv_tab type table of ty_mv.

data: gv_last_today    type datum, "과거일 조회시: 현재일
      gv_edatu         type datum, "기준일, 납기조회 최종일
      gv_lastmon_date  type datum, "지난달 마지막일
      gv_prev_spmon    type spmon, "이전 분석월 (변경 감지용)
      gv_spmon_changed type c.     "분석월 변경 플래그

ranges: gr_gidat for likp-wadat_ist,
        gr_edatu for vbep-edatu.

data : gt_fcode   type table of sy-ucomm,
       gt_celltab type lvc_t_styl.

*----------------------------------------------------------------------
* 공정 상세 통합 내부 테이블 정의
*----------------------------------------------------------------------
types: begin of ty_prod_detail,
         vbeln    type vbeln_va,
         posnr    type posnr_va,
         sequance type numc4,
         gong_cd  type zgtpps1014-gong_cd,
         psmng    type zgtpps1014-psmng,
         wemng    type zgtpps1014-wemng,
         meins    type meins,
         status   type zgtpps1014-status,
         pldat    type dats,
         prdat    type dats,
         charg    type charg_d,
       end of ty_prod_detail.
types : ty_prod_tab type table of ty_prod_detail.

*----------------------------------------------------------------------*
* VARIABLE
*----------------------------------------------------------------------*
data : gv_saveok like sy-ucomm,
       gv_okcode like sy-ucomm,
       gv_error  type char1,
       gv_edit   type char1 value 'X',
       gv_tar    type zgtetarget,
       gv_answer type char1.

*----------------------------------------------------------------------*
*  ALV GRID.
*----------------------------------------------------------------------*
data : gt_toolbar type ui_functions.

data : go_con    type ref to cl_gui_docking_container,
       go_grid   type ref to cl_gui_alv_grid,
       gt_fcat   type lvc_t_fcat,
       gs_fcat   type lvc_s_fcat,
       gt_sort   type lvc_t_sort,   " ALV Sort
       gs_layout type lvc_s_layo.

*----------------------------------------------------------------------*
*   DATA
*----------------------------------------------------------------------*
data : begin of gt_tvgw occurs 500.    " 영업view별 cu, al, fi 가중치
         include structure /nfm/tvgw.
data :   bme like /nfm/tnes-bme.
data : end   of gt_tvgw.

data : gt_tkgw like /nfm/tkgw occurs 0 with header line. "plant별 cu,al,fi 가중치


** 최종 리스트 INTERNAL TABLE
data : begin of g_itab_t occurs 0,
         vbeln          like  vbak-vbeln,           "영업문서
         posnr          like  vbap-posnr,           "품목번호
         auart          like  vbak-auart,           "주문유형
         kunnr          like  vbak-kunnr,           "고객
         name1          like  kna1-name1,           "고객명
         kunnr_sh       like  vbpa-kunnr,           "인도처
         name1_sh       like  kna1-name1,           "인도처명
*-- 기능개선 211276 - 지급처, 구매오더번호 추가 {
         kunnr_py       like  vbpa-kunnr,           "지급처
         name1_py       like  kna1-name1,           "지급처명
*-- } 기능개선 211276_2017.11.07
         matnr          like  vbap-matnr,           "자재
         maktx          like  makt-maktx,           "자재내역
         prodh          like  vbap-prodh,           "제품계층구조
         werks          like  vbap-werks,           "플랜트
         vkorg          like  vbak-vkorg,           "영업조직
         vtweg          like  vbak-vtweg,           "유통경로
         vdatu          like  vbak-vdatu,           "납품요청일
         kwmeng         like  vbap-kwmeng,          "오더수량
         kbmeng         like  vbap-kbmeng,          "확정수량
         abgru          like  vbap-abgru,           "거절사유
         bezei          like  tvagt-bezei,          "거절사유NAME
         vbeln_vl       like  likp-vbeln,           "납품번호
         posnr_vl       like  lips-posnr,           "납품품목
         tknum          like  vttk-tknum,           "선적번호
         vbeln_gi       like  vbfa-vbeln,           "출고전기번호
         lfimg          like  lips-lfimg,           "납품수량
         rfmng          like  vbfa-rfmng,           "피킹수량
         wadat_ist      like  likp-wadat_ist,       "출고전기일
         vbeln_vf       like  vbrk-vbeln,           "빌링번호
         spart          like  vbak-spart,           "제품군
         vkbur          like  vbak-vkbur,           "사업장
         vkgrp          like  vbak-vkgrp,           "영업그룹
         lifnr          like  vbpa-lifnr,           "영업사원
*-> CCM : 27.07.2023 11:36:08 / ZLSGSD3
         ename          like  zzpa0001-ename,       "기능개선 323173 - 추가
*         ENAME     LIKE  PA0001-ENAME,         "기능개선 323173 - 추가
*<-
         ernam          like  vbak-ernam,           "사용자ID
         netpr          like  vbap-netpr,           "단가
         waerk          like  vbap-waerk,           "통화키
         knumv          like  vbak-knumv,           "문서조건번호
         vrkme          like  vbap-vrkme,           "판매단위
         erdat          like  vbak-erdat,           "레코드생성일
         erzet          like  vbak-erzet,           "입력시간
         adrnr          like  vbpa-adrnr,           "주소번호
         pstyv          like  vbap-pstyv,           "Item Category
         prod1(40),                            "제품계층구조1
         prod2(40),                            "제품계층구조2
         prod3(40),                            "제품계층구조3
         vstel          like  vbap-vstel,           "출하지점
         brgew          like  vbap-brgew,           "중량
         matkl          like  vbap-matkl,           "자재그룹
         kodat          like  likp-kodat,           "납품생성일
         lddat          like  likp-lddat,           "적하일
         etenr          like  vbep-etenr,           "일정라인
         edatu          like  vbep-edatu,           "주문도착일(시스템납품일)
         ezeit          like  vbep-ezeit,           "주문도착시간
         mbdat          like  vbep-mbdat,           "자재가용일
         lfdat          like  likp-lfdat,           "납품도착일
         lfuhr          like  likp-lfuhr,           "납품도착시간
         wadat          like  likp-wadat,           "계획G.I
         fkdat          like  vbrk-fkdat,           "대금청구일
         erdat2         like  vttk-erdat,           "선적생성일
         netwr          like  vbap-netwr,           "오더금액
         diff_date      type  i,                    "오더확정차이일
         augru          like  vbak-augru,           "오더사유
         bezei2         like  tvaut-bezei,          "오더사유TEXT
         kunnr_sb       like  vbpa-kunnr,           "특별재고파트너
         ltrmp          like  afpo-ltrmp,           "생산계획일
         ltrmi          like  afpo-ltrmi,           "입고일
         lgort          like  lips-lgort,           "저장위치
         bstkd          like  vbkd-bstkd,           "FILE번호
         kostk          like  vbuk-kostk,           "피킹관련성
         kostk_text(19),                       "피킹설명
         tknum_sea      like  vttk-tknum,           "해상선적번호
         tknum2         like  vttp-tknum,           "준비구간선적번호
         tpnum2         like  vttp-tpnum,           "준비구간선적품목번호
         fknum          like  vfkp-fknum,           "선적비용번호
         erzet2         like  likp-erzet,           "납품생성시간
         signi          like  vttk-signi,           "차량번호
         wbstk          like  vbuk-wbstk,           "전체상품이동상태
         route          like  likp-route,           "운송경로
         tplst          like  vttk-tplst,           "운송계획지점
         lfart          like  likp-lfart,           "납품유형
         erzet3         like  vttk-erzet,           "선적생성시간
         uzdis          like  vttk-uzdis,           "계획시간
         uareg          like  vttk-uareg,           "체크인시간
         btgew          like  likp-btgew,           "납품중량
         cputm          like  mkpf-cputm,           "G/I시간
         vkbur_text     like tvkbt-bezei,          "사업장명
         vkgrp_text     like tvgrt-bezei,          "영업그룹명
         werks_text     like t001w-name1,          "플랜트명
         vstel_text     like tvstt-vtext,          "출하지점명
         route_text     like tvrot-bezei,          "운송경로명
         kunnr_sb_text  like kna1-name1,        "특별재고파트너명

         zpjno          like vbak-zpjno,            "프로젝트No
         zptxt          like zsd0106t-zptxt,        "프로젝트명
         spart2         like vbap-spart,            "품목별제품군

         cuobj          like vbap-cuobj,            "조장수특성값
         value1         like cuxe1cuval-value,      "조장수
         value2         like cuxe1cuval-value,      "개별길이
         value3         like cuxe1cuval-value,      "색상
         value4         like cuxe1cuval-value,      "입회검사유무
         value5         like cuxe1cuval-value,      "절연선심식별
         value6         like cuxe1cuval-value,      "튜브 인쇄사양 SRM2404-07578

         value7         like cuxe1cuval-value,      "STRIPE
         value8         like cuxe1cuval-value,      "띄줄수

         ordid          like zsd0098t-ordid,        "생산오더번호
         sostat         like zsd0098t-sostat,       "판매오더시작일
         soend          like zsd0098t-soend,        "판매오더종료일
         oprtx          like zsd0098t-oprtx,        "공정진행Status
         opstat         like zsd0098t-sostat,       "현공정오더시작일
         opend          like zsd0098t-soend,        "현공정오더완료일
         charg          like zsd0098t-charg,        "Batch
         charg_v        like vbap-charg,               "오더배치번호 CHM2009-00236
         menge          like zsd0098t-menge,        "입고수량
         budat          like mkpf-budat,            "입고일

         dpten          like vttk-dpten,            "선적종료계획
         upten          like vttk-upten,            "선적종료계획시간

         zlfimg         like zlet0002-lfimg,        "절단지시수량
         jisidat        like zlet0002-jisidat,      "절단지시일
         cutsdat        like zlet0002-cutsdat,      "절단완료일

*** 동량 추가
         cu_qty         like  vbap-brgew,           "동량
         al_qty         like  vbap-brgew,           "AL량

* 현재재고를 가져오기 위한 추가 변수
         sobkz          like  vbap-sobkz,           "특별재고지시자
         xchpf          like  vbap-xchpf,           "배치지시자
         clabs          like  mchb-clabs,           "현재고
         n_clabs(20)    type c,                   "현재고 수량을 N TYPE

         mark,
*__  JS전선 호선반영
         zproject       like vbak-zproject,         "호선

* CSR Number : C20080218_18635 필드 추가
         zzmaktx80      like  mara-zzmaktx80,       "상세 품명 FIELD
* CSR Number : C20080218_18635

* CSR Number : C20081226_77528 드럼 번호 필드 추가
         empst          like  vbkd-empst,       "드럼번호 FIELD
* CSR Number : C20081226_77528
         packing_dm     like zedt0230-packing_dm,  "드럼포장재_hoi
         packing_dm_nm  like makt-maktx,
*-{기능개선175813_추가
         kdmat          like vbap-kdmat,        "고객자재
         bstkd_e        like vbkd-bstkd_e,      "납품처 구매오더번호
*-}기능개선175813_2016.12.29
         sotext(100),          "기능개선178174 "오더 텍스트
**-{기능개선 314430
         scr_grade      like  ausp-atwrt,                "등급
         zterm          like  vbkd-zterm,           "지급(수금) 조건
         text1          like  t052u-text1,          "지급조건 텍스트
         prctr          like  vbap-prctr,           "손익센터
         land1          like  kna1-land1,           "고객 국가
**-} 기능개선 314430
       end of g_itab_t.

data : begin of g_tmp_t occurs 0.
         include structure g_itab_t.
data : end of g_tmp_t.

** 오더 INTERNAL TABLE
data : begin of g_itso_t occurs 0,
         vbeln     like  vbak-vbeln,           "영업문서
         posnr     like  vbap-posnr,           "품목번호
         auart     like  vbak-auart,           "주문유형
         kunnr     like  vbak-kunnr,           "고객
         name1     like  kna1-name1,           "고객명
         kunnr_sh  like  vbpa-kunnr,           "인도처
         name1_sh  like  kna1-name1,           "인도처명
*-- 기능개선 211276 - 지급처, 구매오더번호 추가 {
         kunnr_py  like  vbpa-kunnr,           "지급처
         name1_py  like  kna1-name1,           "지급처명
*-- } 기능개선 211276_2017.11.07
         matnr     like  vbap-matnr,           "자재
         maktx     like  makt-maktx,           "자재내역
         prodh     like  vbap-prodh,           "제품계층구조
         werks     like  vbap-werks,           "플랜트
         vkorg     like  vbak-vkorg,           "영업조직
         vtweg     like  vbak-vtweg,           "유통경로
         vdatu     like  vbak-vdatu,           "납품요청일
         kwmeng    like  vbap-kwmeng,          "오더수량
         kbmeng    like  vbap-kbmeng,          "확정수량
         abgru     like  vbap-abgru,           "거절사유
         bezei     like  tvagt-bezei,          "거절사유 NAME
         spart     like  vbak-spart,           "제품군
         vkbur     like  vbak-vkbur,           "사업장
         vkgrp     like  vbak-vkgrp,           "영업그룹
         lifnr     like  vbpa-lifnr,           "영업사원
         ernam     like  vbak-ernam,           "사용자ID
         netpr     like  vbap-netpr,           "단가
         waerk     like  vbap-waerk,           "통화키
         knumv     like  vbak-knumv,           "문서조건번호
         vrkme     like  vbap-vrkme,           "판매단위
         erdat     like  vbak-erdat,           "레코드생성일
         erzet     like  vbak-erzet,           "입력시간
         adrnr     like  vbpa-adrnr,           "주소번호
         pstyv     like  vbap-pstyv,           "Item Category
         prod1(40),                            "제품계층구조1
         prod2(40),                            "제품계층구조2
         prod3(40),                            "제품계층구조3
         vstel     like  vbap-vstel,           "출하지점
         brgew     like  vbap-brgew,           "중량
         matkl     like  vbap-matkl,           "자재그룹
         etenr     like  vbep-etenr,           "일정라인
         edatu     like  vbep-edatu,           "주문도착일(시스템납품일)
         ezeit     like  vbep-ezeit,           "주문도착시간
         mbdat     like  vbep-mbdat,           "자재가용일
         netwr     like  vbap-netwr,           "오더금액
         augru     like  vbak-augru,           "오더사유
         zpjno     like  vbak-zpjno,           "프로젝트No
         spart2    like  vbap-spart,           "품목별제품군
         charg_v   like vbap-charg,               "오더배치번호 CHM2009-00236

         cuobj     like vbap-cuobj,            "조장수특성값

*->  01.02.2024 15:59:26 / ZLSGSD2

         value1    like cuxe1cuval-value,      "조장수
         value2    like cuxe1cuval-value,      "개별길이
         value3    like cuxe1cuval-value,      "색상
         value4    like cuxe1cuval-value,      "입회검사유무
         value5    like cuxe1cuval-value,      "절연선심식별
         value6    like cuxe1cuval-value,      "튜브 인쇄사양 SRM2404-07578

         value7    like cuxe1cuval-value,      "STRIPE
         value8    like cuxe1cuval-value,      "띄줄수


         sobkz     like vbap-sobkz,            "특별재고지시자
         xchpf     like vbap-xchpf,            "배치지시자
*__  JS전선 호선반영
         zproject  like vbak-zproject,         "호선
* CSR Number : C20080218_18635 필드 추가
         zzmaktx80 like mara-zzmaktx80,        "상세 품명 FIELD
* CSR Number : C20080218_18635
**-{기능개선 314430
         zterm     like  vbkd-zterm,           "지급(수금) 조건
         text1     like  t052u-text1,          "지급조건 텍스트
         prctr     like  vbap-prctr,           "손익센터
         land1     like  kna1-land1,           "고객 국가
**-} 기능개선 314430
         kdmat     like vbap-kdmat,        "고객자재
         scr_grade like ausp-atwrt,                "등급
       end of g_itso_t.

** DELIVERY INTERNAL TABLE
data : begin of g_itdl_t occurs 0,
         vbeln_vl  like  likp-vbeln,           "납품번호
         posnr_vl  like  lips-posnr,           "납품품목
         tknum     like  vttk-tknum,           "선적번호
         vbeln_gi  like  vbfa-vbeln,           "출고전기번호
         lfimg     like  lips-lfimg,           "납품수량
         rfmng     like  vbfa-rfmng,           "피킹수량
         wadat_ist like  likp-wadat_ist,       "출고전기일
         vbeln_vf  like  vbrk-vbeln,           "빌링번호
         kodat     like  likp-kodat,           "납품생성일
         lddat     like  likp-lddat,           "적하일
         lfdat     like  likp-lfdat,           "납품도착일
         lfuhr     like  likp-lfuhr,           "납품도착시간
         wadat     like  likp-wadat,           "계획G.I
         fkdat     like  vbrk-fkdat,           "대금청구일
         lgort     like  lips-lgort,           "저장위치
         erzet2    like  likp-erzet,           "납품생성시간
         route     like  likp-route,           "운송경로
         lfart     like  likp-lfart,           "납품유형
         btgew     like  likp-btgew,           "납품중량
         kostk     like  likp-kostk,           "피킹상태
         wbstk     like  likp-wbstk,           "출고전기상태
       end of g_itdl_t.

* 화면에 입력된 값을 읽어들이기 위한 INTERNAL TABLE
data : begin of g_dynpfields_t occurs 0.
         include structure dynpread.
data : end of g_dynpfields_t.

* 제품군 POSSIBLE ENTRY ITAB.
data : begin of g_values2_t occurs 0,
         spart like tvta-spart,
         vtext like tspat-vtext,
       end of g_values2_t.

data : g_totcnt  type i,
       g_cnt     type i,
       g_msg(50),
       g_ratio   type i.

data : g_linen(3)     type n,
       g_out_text(70) type c.

* 특별재고 지시자 : MTO, MTS 구분하기 위해 사용
ranges: r_sobkz for lips-sobkz.

*-{기능개선178174 - 추가
* READ_TEXT
data: wa_thead like thead,
      tdtext   type tline occurs 0 with header line.
*-}기능개선178174_2017.01.12

*{ SRM2404-10815 - 추가_S
data: gt_vttk  like vttk  occurs 0 with header line,
      gt_tvaut like tvaut occurs 0 with header line,
      gt_tvkbt like tvkbt occurs 0 with header line,
      gt_tvgrt like tvgrt occurs 0 with header line,
      gt_tvstt like tvstt occurs 0 with header line.

data: begin of gt_vbep occurs 0,
        vbeln like vbep-vbeln,
        posnr like vbep-posnr,
        edatu like vbep-edatu,
      end   of gt_vbep.

data: begin of gt_vbpa occurs 0,
        vbeln like vbpa-vbeln,
        posnr like vbpa-posnr,
        parvw like vbpa-parvw,
        kunnr like vbpa-kunnr,
        lifnr like vbpa-lifnr,
        adrnr like vbpa-adrnr,
        name1 like kna1-name1,
        name2 like lfa1-name1,
        namad like adrc-name1,
      end   of gt_vbpa.

data: begin of gt_afpo occurs 0,
        kdauf like afpo-kdauf,
        kdpos like afpo-kdpos,
        aufnr like afpo-aufnr,
        posnr like afpo-posnr,
        ltrmp like afpo-ltrmp,
        ltrmi like afpo-ltrmi,
      end   of gt_afpo.

data: begin of gt_vbkd occurs 0,
        vbeln   like vbkd-vbeln,
        posnr   like vbkd-posnr,
        bstkd   like vbkd-bstkd,
        empst   like vbkd-empst,
        bstkd_e like vbkd-bstkd_e,
        zterm   like vbkd-zterm,
      end   of gt_vbkd.

data: begin of gt_vttp occurs 0,
        vbeln like vttp-vbeln,
        tknum like vttp-tknum,
        tpnum like vttp-tpnum,
        shtyp like vttk-shtyp,
      end   of gt_vttp.

data: begin of gt_vfkp occurs 0,
        rebel like vfkp-rebel,
        repos like vfkp-repos,
        fknum like vfkp-fknum,
      end   of gt_vfkp.

data: begin of gt_0230 occurs 0,
        vbeln      like zedt0230-vbeln,
        posnr      like zedt0230-posnr,
        packing_dm like zedt0230-packing_dm,
        maktx      like makt-maktx,
      end   of gt_0230.

data: begin of gt_mara occurs 0,
        matnr     like mara-matnr,
        zzmaktx80 like mara-zzmaktx80,
        maktx     like makt-maktx,
      end   of gt_mara.

data: begin of gt_tvagt occurs 0,
        abgru like tvagt-abgru,
        bezei like tvagt-bezei,
      end   of gt_tvagt.

data: begin of gt_t179t occurs 0,
        prodh like t179t-prodh,
        vtext like t179t-vtext,
      end   of gt_t179t.

data: begin of gt_t052u occurs 0,
        zterm like t052u-zterm,
        text1 like t052u-text1,
      end   of gt_t052u.

data: begin of gt_kna1 occurs 0,
        kunnr like kna1-kunnr,
        land1 like kna1-land1,
      end   of gt_kna1.

data: begin of gt_mkpf occurs 0,
        mblnr like mkpf-mblnr,
        mjahr like mkpf-mjahr,
        cputm like mkpf-cputm,
      end   of gt_mkpf.

data: begin of gt_t001w occurs 0,
        werks like t001w-werks,
        name1 like t001w-name1,
      end   of gt_t001w.

data: begin of gt_tvrot occurs 0,
        route like tvrot-route,
        bezei like tvrot-bezei,
      end   of gt_tvrot.

data: begin of gt_0106 occurs 0,
        zpjno like zsd0106t-zpjno,
        zptxt like zsd0106t-zptxt,
      end   of gt_0106.

data: begin of gt_grade occurs 0,
        vbeln     type vbeln,
        posnr     type posnr,
        werks     type werks_d,
        scr_grade type atwrt,
      end   of gt_grade.

data: gt_ords    type table of zcharords,
      gt_ordvals type table of zcharvals,
      gr_atnamo  type table of eampic_sel_atnam.
*} SRM2404-10815 - 추가_E

data: begin of gt_vttk_sea occurs 0,
        vbeln like vttp-vbeln,
        vsbed like likp-vsbed,
        tknum like vttk-tknum,
        shtyp like vttk-shtyp,
      end of gt_vttk_sea.

*&---------------------------------------------------------------------*
*  DEFINES
*&---------------------------------------------------------------------*
define set_range.
  IF &2 IS NOT INITIAL.
     &1-SIGN   = 'I'.
     &1-OPTION = 'EQ'.
     &1-LOW    = &2.
     APPEND &1.
  ENDIF.
end-of-definition.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
constants: gc_vkorg_6000 type vkorg   value '6000',
           gc_vtweg_10   type vtweg   value '10',
           gc_vtweg_50   type vtweg   value '50',
           gc_spart_3c   type spart   value '3C',
           gc_spart_4c   type spart   value '4C',
           gc_spart_90   type spart   value '90'.
constants: gc_krw        type waerk   value 'KRW'.

constants:
  gc_a type c value 'A',
  gc_b type c value 'B',
  gc_c type c value 'C',
  gc_d type c value 'D',
  gc_e type c value 'E',
  gc_f type c value 'F',
  gc_g type c value 'G',
  gc_h type c value 'H',
  gc_i type c value 'I',
  gc_j type c value 'J',
  gc_k type c value 'K',
  gc_l type c value 'L',
  gc_m type c value 'M',
  gc_n type c value 'N',
  gc_o type c value 'O',
  gc_p type c value 'P',
  gc_q type c value 'Q',
  gc_r type c value 'R',
  gc_s type c value 'S',
  gc_t type c value 'T',
  gc_u type c value 'U',
  gc_v type c value 'V',
  gc_w type c value 'W',
  gc_x type c value 'X',
  gc_y type c value 'Y',
  gc_z type c value 'Z',
  gc_0 type c value '0',
  gc_1 type c value '1',
  gc_2 type c value '2',
  gc_3 type c value '3',
  gc_4 type c value '4',
  gc_5 type c value '5',
  gc_6 type c value '6',
  gc_7 type c value '7',
  gc_8 type c value '8',
  gc_9 type c value '9'.
