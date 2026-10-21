*&---------------------------------------------------------------------*
*& Include          ZGTSDR1300SEL
*&---------------------------------------------------------------------*
*--------------------------------------------------------------------*
*   SELECTION SCREEN
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
** 현업의 요청으로 일정라인의 일자(VBEP-EDATU)을 납품요청일로
** 입력받는다 : 2005-05-19 => 시스템납품일
*select-options : so_vdatu for  vbak-vdatu obligatory,  "납품요청일
  SELECT-OPTIONS : SO_EDATU FOR  VBEP-EDATU OBLIGATORY,  "납품요청일
                   SO_ERDAT FOR  VBAK-ERDAT.             "주문생성일

  PARAMETERS     : PA_SPMON LIKE S005-SPMON.             "출고전기일

  SELECT-OPTIONS : SO_AUART FOR  VBAK-AUART             "오더유형
                   NO INTERVALS,
                   SO_VBELN FOR  VBAK-VBELN
                            MATCHCODE OBJECT VMVA.       "영업문서
*-- 기능개선 211276 - 지급처, 구매오더번호 추가 {
  PARAMETERS     : PA_BSTKD LIKE VBKD-BSTKD.             "PO번호
*-- } 기능개선 211276_2017.11.07
  SELECT-OPTIONS : SO_ZPJNO FOR  VBAK-ZPJNO             "프로젝트번호
                            MATCHCODE OBJECT ZSD_PJNOT,
                   SO_KUNNR FOR  VBAK-KUNNR.             "거래선

  PARAMETERS     : PA_KUNWE LIKE VBAK-KUNNR,             "인도처
*-- 기능개선 211276 - 지급처, 구매오더번호 추가 {
                   PA_KUNRG LIKE VBAK-KUNNR,             "지급처
*-- } 기능개선 211276_2017.11.07
                   PA_VKORG LIKE VBAK-VKORG OBLIGATORY
                                 DEFAULT '6000'.         "영업조직

  SELECT-OPTIONS : SO_VTWEG FOR  VBCOM-VTWEG OBLIGATORY, "유통경로
                   SO_SPART FOR  VBCOM-SPART OBLIGATORY, "제품군
                   SO_VKBUR FOR  VBCOM-VKBUR MEMORY ID VKB, "사업장
                   SO_VKGRP FOR  VBCOM-VKGRP OBLIGATORY MEMORY ID VKG, "영업그룹
*-> S4HANA 영업사원변경 : 2023.07.20
                   SO_LIFNR FOR VBPA-LIFNR, "영업사원
*<-
                   SO_WERKS FOR  VBAP-WERKS,             "플랜트
                   SO_MATNR FOR  VBAP-MATNR,             "자
                   SO_ERNAM FOR  VBAK-ERNAM.             "사용자ID

  SELECT-OPTIONS : SO_KODAT FOR  LIKP-KODAT,             "납품생성일
                   SO_LDDAT FOR  LIKP-LDDAT,             "적하일
                   SO_VSTEL FOR  VBAP-VSTEL,             "출하지점
                   SO_MATKL FOR  VBAP-MATKL.             "자재그룹

  SELECT-OPTIONS : SO_ERDA2 FOR  VTTK-ERDAT,             "선적생성일
                   SO_W_IST FOR  LIKP-WADAT_IST,         "실제자재이동일
                   SO_WADAT FOR  LIKP-WADAT,             "계획자재이동일
                   SO_TKNUM FOR  VTTK-TKNUM,             "선적번호
                   SO_VBEL2 FOR  LIKP-VBELN,             "납품번호
                   SO_SIGNI FOR  VTTK-SIGNI,             "차량번호
                   SO_WBSTK FOR  VBUK-WBSTK,             "전체상품이동상태
                   SO_ROUTE FOR  LIKP-ROUTE,             "운송경로
                   SO_TPLST FOR  VTTK-TPLST,             "운송계획지점
                   SO_LFART FOR  LIKP-LFART,             "납품유형
                   SO_KUNN2 FOR  VBPA-KUNNR,             "특별재고파트너
                   SO_LGORT FOR  LIPS-LGORT.             "저장위치

  SELECTION-SCREEN SKIP 1.

  PARAMETERS: P_VARI    LIKE DISVARIANT-VARIANT.

SELECTION-SCREEN END OF BLOCK B1.

PARAMETERS: P_SUB(1)  NO-DISPLAY,  "SUBMIT 처리
            P_MODE(1) NO-DISPLAY,  "SUBMIT 처리
            P_ID(100) NO-DISPLAY.

*/ 고객 요청으로 인한 전체,MTO,MTS 구분 추가 20061012 koo
SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-002.
  SELECTION-SCREEN BEGIN OF LINE.

    PARAMETERS: R01 RADIOBUTTON GROUP G_R1                 "mto+mts
                    USER-COMMAND UCOMM DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 4(32) TEXT-101 FOR FIELD R01.

    PARAMETERS: R02 RADIOBUTTON GROUP G_R1.                "mto
    SELECTION-SCREEN COMMENT 40(25) TEXT-102 FOR FIELD R02.

    PARAMETERS: R03 RADIOBUTTON GROUP G_R1.                "mts
    SELECTION-SCREEN COMMENT 68(17) TEXT-103 FOR FIELD R03.

  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END   OF BLOCK B2.

PARAMETERS    : P_NEW   AS CHECKBOX DEFAULT 'X' MODIF ID ZM1.  "SRM2404-10815 - 추가
