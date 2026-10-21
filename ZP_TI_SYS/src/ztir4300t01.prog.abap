************************************************************************
* Title         :  ZTIR4300T01                                         *
*                                                                      *
* Description   : 수입신고의뢰 관리 Top Include                        *
*                                                                      *
* Creation Date : 2004/08/23                                           *
*                                                                      *
* Author        : Sung Ho, Maeng                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* dd-mmm-yyyy  xxxxxxxxxxxxxxx  DVPK9xxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  *
*                                                                      *
*                                                                      *
*----------------------------------------------------------------------*


************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: ztitcrk,    ">수입신고의뢰 Header
       *ztitcrk,    ">수입신고의뢰 Header
        ztitcrp,    ">수입신고의뢰 Item
        ztitcr1,    ">수입신고의뢰 Item (란 사항)
        ztitcr2,    ">수입신고의뢰 Item (행 사항-규격)
        ztitcr3,    ">수입신고의뢰 Item (행 사항-요건)
        ztitcr5,    ">수입신고의뢰 ITEM -요건승인내역(4G):기능개선 xxxxx
        ztitblp,    ">B/L Item
        ztstigh,    ">[TraSys] HS코드별 관세율 관리.
        ztitcck,    ">[Import] 수입신고필증  MAIN (IMPREQ/IMPRES)
        ztitbik,    ">반입예정정보.
        ztitrqk,    ">수입의뢰 Header
        ztitrqs,    ">수입의뢰 Status
        ztitrqp,    ">수입의뢰 Items
        ztitivp.

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES : ztsvig5.

************************************************************************
* SAP Structure                                                        *
************************************************************************
TABLES: ztisrqit,    ">수입의뢰 Items
        ztisblit,    ">B/L Items
        ztisivit,    ">I/V Items
        ztiscrit,    ">수입신고의뢰 Items
        ztisgrit,    ">G/R Items
        ztiscr01.    ">수입신고의뢰 란.


************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
  c_action              TYPE es_element     VALUE 'ZTICR',
  c_create_d            LIKE sy-tcode       VALUE 'NONE',    ">생성.
  c_create              LIKE sy-tcode       VALUE 'ZTIT431', ">생성.
  c_create_a            LIKE sy-tcode       VALUE 'ZTIT439', ">Amend.
  c_change              LIKE sy-tcode       VALUE 'ZTIT432', ">변경.
  c_display             LIKE sy-tcode       VALUE 'ZTIT433', ">조회.
  c_delete              LIKE sy-tcode       VALUE 'ZTIT434', ">삭제.
  c_acceptance          LIKE sy-tcode       VALUE ' ',       ">접수.
  c_send                LIKE sy-tcode       VALUE space,     ">None
  c_apply               LIKE sy-tcode       VALUE ' ',       ">개설신청.
  c_open                LIKE sy-tcode       VALUE ' ',       ">개설.
  c_post                LIKE sy-tcode       VALUE 'NONE',    ">전기.
  c_reverse             LIKE sy-tcode       VALUE 'NONE',    ">취소.
  c_reverse1            LIKE sy-tcode       VALUE 'NONE',    ">None
  c_close               LIKE sy-tcode       VALUE 'NONE',    ">종료.
  c_textobject_header   LIKE ttxob-tdobject VALUE 'ZTICRHD'.

************************************************************************
* Internal Tables                                                      *
************************************************************************
DATA : BEGIN OF it_blnum OCCURS 0,
       iblno      LIKE ztitblk-iblno.
DATA : END   OF it_blnum.

DATA : BEGIN OF it_bl OCCURS 0,
       box        TYPE c,
       index(10)  TYPE n,
       iblno       LIKE ztitblk-iblno,  "10B/L 관리번호.
       iblit       LIKE ztitblp-iblit,  "5B/L 품목번호.
       ndfty       LIKE ztitblp-ndfty,  "1무환품 종류.
       blmng       LIKE ztitblp-blmng,  "13B/L 수량.
       refwr       LIKE ztitblp-refwr,  "13송장값 (외화).
       meins       LIKE ztitblp-meins,                      "3기본단위.
       ebeln       LIKE ztitblp-ebeln,  "10구매전표번호.
       ebelp       LIKE ztitblp-ebelp,  "5구매문서 품목번호.
       reqno       LIKE ztitblp-reqno,  "10수입의뢰 관리번호.
       reqit       LIKE ztitblp-reqit,  "5수입의뢰 품목번호.
       menge       LIKE ztiscrit-menge,
       ccmngs      LIKE ztiscrit-ccmngs,
       ccmngl      LIKE ztiscrit-ccmngl.
DATA : END OF it_bl.

*> CHANGE DOCUMENT용.
DATA : BEGIN OF xztitcr1 OCCURS 0.
        INCLUDE STRUCTURE vztitcr1.
DATA : END   OF xztitcr1.

DATA : BEGIN OF yztitcr1 OCCURS 0.
        INCLUDE STRUCTURE vztitcr1.
DATA : END   OF yztitcr1.

DATA : BEGIN OF xztitcr2 OCCURS 0.
        INCLUDE STRUCTURE vztitcr2 .
DATA : END   OF xztitcr2.

DATA : BEGIN OF yztitcr2 OCCURS 0.
        INCLUDE STRUCTURE vztitcr2 .
DATA : END   OF yztitcr2.

DATA : BEGIN OF xztitcr3 OCCURS 0.
        INCLUDE STRUCTURE vztitcr3 .
DATA : END   OF xztitcr3.

DATA : BEGIN OF yztitcr3 OCCURS 0.
        INCLUDE STRUCTURE vztitcr3 .
DATA : END   OF yztitcr3.

*-> 기능개선 XXXXX_신규 추가
DATA : BEGIN OF xztitcr5 OCCURS 0.
        INCLUDE STRUCTURE vztitcr5 .
DATA : END   OF xztitcr5.

DATA : BEGIN OF yztitcr5 OCCURS 0.
        INCLUDE STRUCTURE vztitcr5 .
DATA : END   OF yztitcr5.
*<- 기능개선 XXXXX_신규 추가

DATA : BEGIN OF xztitcrp OCCURS 0.
        INCLUDE STRUCTURE vztitcrp.
DATA : END   OF xztitcrp.

DATA : BEGIN OF yztitcrp OCCURS 0.
        INCLUDE STRUCTURE vztitcrp.
DATA : END   OF yztitcrp.


*> WBS 요소.
DATA: BEGIN OF it_pspnr  OCCURS 2,
      pspnr   TYPE  ps_psp_pnr.
DATA: END   OF it_pspnr.

*> 자재코드.
DATA: BEGIN OF it_matnr  OCCURS 2,
      matnr   LIKE mara-matnr,  ">자재코드.
      brgew   LIKE mara-brgew,  ">총중량.
      ntgew   LIKE mara-ntgew,  ">순중량.
      gewei   LIKE mara-gewei,  ">중량단위.
      volum   LIKE mara-volum,  ">볼륨.
      voleh   LIKE mara-voleh.  ">볼륨단위.
DATA: END   OF it_matnr.


*-----------------------------------------------------------------------
*> 아이템 테이블용.
*-----------------------------------------------------------------------
CONTROLS: tc_2130   TYPE TABLEVIEW USING SCREEN 2130.

*> TYPE FOR THE DATA OF TABLECONTROL 'tc_2130'
TYPES: BEGIN OF t_tc_2130.
        INCLUDE STRUCTURE ztiscrit.
TYPES: END OF t_tc_2130.

*> INTERNAL TABLE FOR TABLECONTROL 'tc_2130'
DATA:     it_tab           TYPE t_tc_2130 OCCURS 0,
          it_tab_o         TYPE t_tc_2130 OCCURS 0,
          g_tc_2130_wa     TYPE t_tc_2130,           ">work area
          g_tc_2130_copied.                          ">copy flag

*> LINES OF TABLECONTROL 'tc_2130'
DATA:     g_tc_2130_lines  LIKE sy-loopc.

*-----------------------------------------------------------------------
*> 수입신고의뢰 란사항 테이블 컨트롤용.
*-----------------------------------------------------------------------

DATA : g_csseq         LIKE ztitcr1-csseq,
       g_cdseq         LIKE ztitcr3-cdseq,
       gs_ztstig6_usd  LIKE ztstig6,
       G_Z9050         LIKE ZTITCR5-Z9050. "기능개선 XXXXX

*> type for the data of tablecontrol 'TC_2211'
TYPES: BEGIN OF t_tc_2211.
        INCLUDE STRUCTURE ztitcr1.
TYPES:   flag,       "flag for mark column
       END OF t_tc_2211.

*> internal table for tablecontrol 'TC_2211'
DATA:     g_tc_2211_itab   TYPE t_tc_2211 OCCURS 0,
          g_tc_2211_wa     TYPE t_tc_2211, "work area
          g_tc_2211_tmp    TYPE t_tc_2211 OCCURS 0.
DATA:     g_tc_2211_copied.           "copy flag

*> declaration of tablecontrol 'TC_2211' itself
CONTROLS: tc_2211 TYPE TABLEVIEW USING SCREEN 2211.

*> lines of tablecontrol 'TC_2211'
DATA:     g_tc_2211_lines  LIKE sy-loopc.

*-----------------------------------------------------------------------
*> 수입신고의뢰 란사항 컨트롤용.
*-----------------------------------------------------------------------
*> 규격.
*> type for the data of tablecontrol 'TC_2212'
TYPES: BEGIN OF t_tc_2212.
        INCLUDE STRUCTURE ztitcr2.
TYPES:   flag,       "flag for mark column
       END OF t_tc_2212.

*> internal table for tablecontrol 'TC_2212'
DATA:     g_tc_2212_itab   TYPE t_tc_2212 OCCURS 0,
          g_tc_2212_tmp    TYPE t_tc_2212 OCCURS 0,
          g_tc_2212_wa     TYPE t_tc_2212. "work area
DATA:     g_tc_2212_copied.           "copy flag

*> declaration of tablecontrol 'TC_2212' itself
CONTROLS: tc_2212 TYPE TABLEVIEW USING SCREEN 2212.

*> lines of tablecontrol 'TC_2212'
DATA:     g_tc_2212_lines  LIKE sy-loopc.


*> 요건확인.
*> type for the data of tablecontrol 'TC_2212'
TYPES: BEGIN OF t_tc_2212_1.
        INCLUDE STRUCTURE ztitcr3.
TYPES:   flag,       "flag for mark column
       END OF t_tc_2212_1.

*> internal table for tablecontrol 'TC_2212'
DATA:     g_tc_2212_1_itab   TYPE t_tc_2212_1 OCCURS 0,
          g_tc_2212_1_tmp    TYPE t_tc_2212_1 OCCURS 0,
          g_tc_2212_1_wa     TYPE t_tc_2212_1. "work area
DATA:     g_tc_2212_1_copied.           "copy flag

*> declaration of tablecontrol 'TC_2212' itself
CONTROLS: tc_2212_1 TYPE TABLEVIEW USING SCREEN 2212.

*> lines of tablecontrol 'TC_2212'
DATA:     g_tc_2212_1_lines  LIKE sy-loopc.

*-> 기능개선 xxxxx
*> 요건승인(4세대).
*> type for the data of tablecontrol 'TC_2212_2'
TYPES: BEGIN OF t_tc_2212_2.
        INCLUDE STRUCTURE ZTITCR5.
TYPES:   flag,       "flag for mark column
       END OF t_tc_2212_2.

*> internal table for tablecontrol 'TC_2212'
DATA:     g_tc_2212_2_itab   TYPE t_tc_2212_2 OCCURS 0,
          g_tc_2212_2_tmp    TYPE t_tc_2212_2 OCCURS 0,
          g_tc_2212_2_wa     TYPE t_tc_2212_2. "work area
DATA:     g_tc_2212_2_copied.           "copy flag

*> declaration of tablecontrol 'TC_2212' itself
CONTROLS: tc_2212_2 TYPE TABLEVIEW USING SCREEN 2212 .

*> lines of tablecontrol 'TC_2212'
DATA:     g_tc_2212_2_lines  LIKE sy-loopc.
*<- 기능개선 xxxxx

DATA:   g_cdrno      LIKE ztitcrk-cdrno,
        g_ccnum_chk1 TYPE c,
        g_ccnum_chk2 TYPE c.



************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF ty_header,
            box(1)      TYPE c,
            iblno       LIKE ztitblk-iblno,	"10B/L 관리번호.
            blnum       LIKE ztitblk-blnum,	"25B/L 번호.
            bldty       LIKE ztitblk-bldty,                 "1문서종류.
            bldtyx(20)  TYPE c,                 "문서종류TEXT.
            rptty       LIKE ztitblk-rptty,	"1수입신고구분.
            rpttyx(20)  TYPE c,                 "수입신고구분TEXT.
            bukrs       LIKE ztitblk-bukrs,                 "4회사코드.
            ekorg       LIKE ztitblk-ekorg,                 "4구매조직.
            ekgrp       LIKE ztitblk-ekgrp,                 "3구매그룹.
            lifnr       LIKE ztitblk-lifnr,	"10공급업체 계정번호.
            name1       LIKE lfa1-name1,
            bletd       LIKE ztitblk-bletd,	"8ETD(출발 예정 시각).
            bleta       LIKE ztitblk-bleta,	"8ETA(도착 예정 시각).
            fwdty       LIKE ztitblk-fwdty,	"1운송 방법.
            fwdtyx(20)  TYPE c,	                "1운송 방법TEXT.
            lponr       LIKE ztitblk-lponr,	"5최종품목번호.
            waers       LIKE ztitblk-waers,                 "5통화키.
            trefwr      LIKE ztitblp-refwr,    "total 금액.
            lgayn       LIKE ztitblk-lgayn.    "LG대상여부.

TYPES: END OF ty_header.

TYPES: BEGIN OF ty_item.
INCLUDE     TYPE        ty_header.
TYPES :     iblit       LIKE ztitblp-iblit,	"5B/L 품목번호.
            ndfty       LIKE ztitblp-ndfty,	"1무환품 종류.
            ndftyx(20)  TYPE c,	                "무환품 종류TEXT.
            blmng       LIKE ztitblp-blmng,	"13B/L 수량.
            refwr       LIKE ztitblp-refwr,	"13송장값 (외화).
            meins       LIKE ztitblp-meins,                 "3기본단위.
            ebeln       LIKE ztitblp-ebeln,	"10구매전표번호.
            ebelp       LIKE ztitblp-ebelp,	"5구매문서 품목번호.
            reqno       LIKE ztitblp-reqno,	"10수입의뢰 관리번호.
            reqit       LIKE ztitblp-reqit,	"5수입의뢰 품목번호.
*            mblnr       LIKE ZTITBLP-mblnr,  "10자재문서번호.
*            mjahr       LIKE ZTITBLP-mjahr,  "4자재문서연도.
*            zeile       LIKE ZTITBLP-zeile,  "4자재문서품목.
            cnam        LIKE ztitblp-cnam,                  "12작성인.
            cdat        LIKE ztitblp-cdat,                  "8생성일.
            ctme        LIKE ztitblp-ctme,                  "6생성시간.
            unam        LIKE ztitblp-unam,  "12최종변경인.
            udat        LIKE ztitblp-udat,                  "8변경일.
            utme        LIKE ztitblp-utme,  "6최종변경시간.
            pomng       LIKE ztisblit-menge,    "p/o수량.
            menge       LIKE ztisblit-menge,
            blmngs      LIKE ztisblit-blmngs,
            blmngl      LIKE ztisblit-blmngl,
            ccmngs      LIKE ztiscrit-ccmngs,
            ccmngl      LIKE ztiscrit-ccmngl,
            werks       LIKE ztisblit-werks,
            name2       LIKE ztisblit-name1,
            matnr       LIKE ztisblit-matnr,
            txz01       LIKE ztisblit-txz01,
            eeind       LIKE ztisblit-eeind,
            netpr       LIKE ztisblit-netpr,
            peinh       LIKE ztisblit-peinh,
            netwr       LIKE ztisblit-netwr.

TYPES: END OF ty_item.


TYPES: BEGIN OF ty_list.
INCLUDE             TYPE        ty_item.
TYPES:      color   TYPE slis_t_specialcol_alv.
TYPES: END OF ty_list.

*> Select용.
TYPES: BEGIN OF ty_tab.
INCLUDE     TYPE        ty_item.
TYPES: END OF ty_tab.

DATA: it_ztitig02  TYPE ztitig02  OCCURS 0 WITH HEADER LINE.
DATA: it_list      TYPE ty_list   OCCURS 0 WITH HEADER LINE.
DATA: it_header    TYPE ty_header OCCURS 0 WITH HEADER LINE.
DATA: it_tab_h     TYPE ty_tab    OCCURS 0 WITH HEADER LINE.

** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: a_bukrs LIKE t001-bukrs,
      l_yn    TYPE c.
** JS전선 회사코드 2007/04 KSH --------------------------------------
