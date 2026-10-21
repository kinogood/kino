*&---------------------------------------------------------------------*
*& Include          ZGTSDR1300SEL
*&---------------------------------------------------------------------*
*--------------------------------------------------------------------*
*   SELECTION SCREEN
*--------------------------------------------------------------------*

*/ 고객 요청으로 인한 전체,MTO,MTS 구분 추가 20061012 koo
*selection-screen begin of block b3 with frame title text-003. "납품일
*  selection-screen begin of line.
*
*    parameters: ra1 radiobutton group g_ra                "당월+미출고
*                    user-command ucomm default 'X'.
*    selection-screen comment 4(32) text-104 for field ra1.
*
*    parameters: ra2 radiobutton group g_ra .              "익월이후
*    selection-screen comment 40(25) text-105 for field ra2.
*
*  selection-screen end of line.
*selection-screen end   of block b3.


selection-screen begin of block b1 with frame title text-001.

  parameters : p_spmon type spmon default sy-datum(6).
  parameters : p_sdate type datum no-display.

  selection-screen skip 1.

  select-options : so_edatu for  vbep-edatu " obligatory  "납품요청일 당월
                   "no-extension,
                   no-display,
                   so_erdat for  vbak-erdat.             "주문생성일

  select-options : so_auart for  vbak-auart             "오더유형
                   no intervals,
                   so_vbeln for  vbak-vbeln
                            matchcode object vmva.       "영업문서
  parameters     : pa_bstkd like vbkd-bstkd.             "PO번호
  select-options : so_zpjno for  vbak-zpjno             "프로젝트번호
                            matchcode object zsd_pjnot,
                   so_kunnr for  vbak-kunnr.             "거래선

  parameters     : pa_kunwe like vbak-kunnr,             "인도처
                   pa_kunrg like vbak-kunnr,             "지급처
                   pa_vkorg like vbak-vkorg obligatory
                                 default '6000'.         "영업조직

  select-options : so_vtweg for  vbcom-vtweg , "유통경로
                   so_spart for  vbcom-spart , "제품군
                   so_vkbur for  vbcom-vkbur , "memory id vkb, "사업장
                   so_vkgrp for  vbcom-vkgrp , "memory id vkg, "영업그룹
*-> S4HANA 영업사원변경 : 2023.07.20
                   so_lifnr for vbpa-lifnr, "영업사원
*<-
                   so_werks for  vbap-werks,             "플랜트
                   so_matnr for  vbap-matnr,             "자재
                   so_arktx for  vbap-arktx,             "자재명
                   so_ernam for  vbak-ernam.             "사용자ID

  select-options : "so_kodat for  likp-kodat,             "납품생성일
                   "so_lddat for  likp-lddat,             "적하일
                   so_vstel for  vbap-vstel,             "출하지점
                   so_matkl for  vbap-matkl.             "자재그룹

  select-options :  so_wbstk for  vbuk-wbstk,             "전체상품이동상태
                    so_zqtno for  vbak-zqtno,             "견적번호
                    so_ztver for  vbak-ztver.             "Version Number
*                  "so_erda2 for  vttk-erdat,             "선적생성일
*                   so_w_ist for  likp-wadat_ist,         "실제자재이동일
*                   so_wadat for  likp-wadat,             "계획자재이동일
*                   "so_tknum for  vttk-tknum,             "선적번호
*                   "so_vbel2 for  likp-vbeln,             "납품번호
*                   "so_signi for  vttk-signi,             "차량번호
*                   "so_route for  likp-route,             "운송경로
*                   "so_tplst for  vttk-tplst,             "운송계획지점
*                   "so_lfart for  likp-lfart,             "납품유형
*                   "so_kunn2 for  vbpa-kunnr,             "특별재고파트너
*                   "so_lgort for  lips-lgort.             "저장위치

  selection-screen skip 1.

  parameters: p_vari    like disvariant-variant.

selection-screen end of block b1.

parameters: p_call type c default space no-display.
