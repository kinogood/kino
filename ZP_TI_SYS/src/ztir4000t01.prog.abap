************************************************************************
* Title         :  ZTIR4000T01                                         *
*                                                                      *
* Description   : 수입 C/C 관리 Top Include                            *
*                                                                      *
* Creation Date : 2004/02/18                                           *
*                                                                      *
* Author        : Seung Jun, Lee                                       *
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
TABLES: ztitcck,    ">C/C Header
       *ztitcck,    ">C/C Header
        ztitcrk,    ">수입신고의뢰 Header
        ztitccp,    ">C/C Item
        ztiscr01,
        ztstigh,
        ztitbik,    ">[Import] 반입신고 Header table
        ztitcc1,    ">C/C Item (란 사항)
        ztitcc2,    ">C/C Item (행 사항-규격)
        ztitcc3,    ">C/C Item (행 사항-요건)
        ztitcc4,    ">C/C Item - 요건승인내역(4G): 기능개선 XXXXX
        ztitblp,    ">B/L Item
        ztitrqk,    ">수입의뢰 Header
        ztitrqs,    ">수입의뢰 Status
        ztitrqp.    ">수입의뢰 Items

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
        ztisccit,    ">C/C Items
        ztisgrit,    ">G/R Items
        ztiscc01.    ">수입신고 필증 란.


************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
  c_action              TYPE es_element     VALUE 'ZTICC',
  c_create_d            LIKE sy-tcode       VALUE 'NONE',    ">생성.
  c_create              LIKE sy-tcode       VALUE 'ZTIT401', ">생성.
  c_create_a            LIKE sy-tcode       VALUE ' ', ">Amend.
  c_change              LIKE sy-tcode       VALUE 'ZTIT402', ">변경.
  c_display             LIKE sy-tcode       VALUE 'ZTIT403', ">조회.
  c_delete              LIKE sy-tcode       VALUE 'ZTIT404', ">삭제.
  c_acceptance          LIKE sy-tcode       VALUE ' ',       ">접수.
  c_apply               LIKE sy-tcode       VALUE ' ',       ">개설신청.
  c_send                LIKE sy-tcode       VALUE space,     ">None
  c_open                LIKE sy-tcode       VALUE ' ',       ">개설.
  c_post                LIKE sy-tcode       VALUE 'NONE',    ">전기.
  c_reverse             LIKE sy-tcode       VALUE 'NONE',    ">취소.
  c_reverse1            LIKE sy-tcode       VALUE 'NONE',    ">None
  c_close               LIKE sy-tcode       VALUE 'NONE',    ">종료.
  c_textobject_header   LIKE ttxob-tdobject VALUE 'ZTICCHD'.

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
       menge       LIKE ztisccit-menge,
       ccmngs      LIKE ztisccit-ccmngs,
       ccmngl      LIKE ztisccit-ccmngl.
DATA : END OF it_bl.

*> 수입신고의뢰 데이타.
DATA : BEGIN OF xztitcr1 OCCURS 0.
        INCLUDE STRUCTURE vztitcr1.
DATA : END   OF xztitcr1.

DATA : BEGIN OF xztitcr2 OCCURS 0.
        INCLUDE STRUCTURE vztitcr2.
DATA : END   OF xztitcr2.

DATA : BEGIN OF xztitcr3 OCCURS 0.
        INCLUDE STRUCTURE vztitcr3.
DATA : END   OF xztitcr3.

*-> 기능개선 XXXXX_신규 추가
DATA : BEGIN OF xztitcr5 OCCURS 0.
        INCLUDE STRUCTURE vztitcr5.
DATA : END   OF xztitcr5.
*<- 기능개선 XXXXX_신규 추가

DATA : BEGIN OF xztitcrp OCCURS 0.
        INCLUDE STRUCTURE ztiscrit.
DATA : END   OF xztitcrp.

*> CHANGE DOCUMENT용.
DATA : BEGIN OF xztitcc1 OCCURS 0.
        INCLUDE STRUCTURE vztitcc1.
DATA : END   OF xztitcc1.

DATA : BEGIN OF yztitcc1 OCCURS 0.
        INCLUDE STRUCTURE vztitcc1.
DATA : END   OF yztitcc1.

DATA : BEGIN OF xztitcc2 OCCURS 0.
        INCLUDE STRUCTURE vztitcc2 .
DATA : END   OF xztitcc2.

DATA : BEGIN OF yztitcc2 OCCURS 0.
        INCLUDE STRUCTURE vztitcc2 .
DATA : END   OF yztitcc2.

DATA : BEGIN OF xztitcc3 OCCURS 0.
        INCLUDE STRUCTURE vztitcc3 .
DATA : END   OF xztitcc3.

DATA : BEGIN OF yztitcc3 OCCURS 0.
        INCLUDE STRUCTURE vztitcc3 .
DATA : END   OF yztitcc3.

*-> 기능개선 XXXXX_신규 추가
DATA : BEGIN OF xztitcc4 OCCURS 0.
        INCLUDE STRUCTURE vztitcc4 .
DATA : END   OF xztitcc4.

DATA : BEGIN OF yztitcc4 OCCURS 0.
        INCLUDE STRUCTURE vztitcc4 .
DATA : END   OF yztitcc4.
*<- 기능개선 XXXXX_신규 추가

DATA : BEGIN OF xztitccp OCCURS 0.
        INCLUDE STRUCTURE vztitccp.
DATA : END   OF xztitccp.

DATA : BEGIN OF yztitccp OCCURS 0.
        INCLUDE STRUCTURE vztitccp.
DATA : END   OF yztitccp.


*> 기타 텍스트용.
DATA: BEGIN OF it_lctext OCCURS 0.
        INCLUDE STRUCTURE ztislc02.
DATA: END OF it_lctext.

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

DATA: ztitcck_old TYPE ztitcck,
      ztitcck_tmp TYPE ztitcck.

*-----------------------------------------------------------------------
*> 아이템 테이블용.
*-----------------------------------------------------------------------
CONTROLS: tc_2130   TYPE TABLEVIEW USING SCREEN 2130.

*> TYPE FOR THE DATA OF TABLECONTROL 'tc_2130'
TYPES: BEGIN OF t_tc_2130.
        INCLUDE STRUCTURE ztisccit.
TYPES: END OF t_tc_2130.

*> INTERNAL TABLE FOR TABLECONTROL 'tc_2130'
DATA:     it_tab           TYPE t_tc_2130 OCCURS 0,
          it_tab_o         TYPE t_tc_2130 OCCURS 0,
          g_tc_2130_wa     TYPE t_tc_2130,           ">work area
          g_tc_2130_copied.                          ">copy flag

*> LINES OF TABLECONTROL 'tc_2130'
DATA:     g_tc_2130_lines  LIKE sy-loopc.

*-----------------------------------------------------------------------
*> 수입신고필증 란사항 테이블 컨트롤용.
*-----------------------------------------------------------------------

DATA : g_csseq LIKE ztitcc1-csseq.

*> type for the data of tablecontrol 'TC_2211'
TYPES: BEGIN OF t_tc_2211.
        INCLUDE STRUCTURE ztitcc1.
TYPES:   flag,       "flag for mark column
       END OF t_tc_2211.

*> internal table for tablecontrol 'TC_2211'
DATA:     g_tc_2211_itab   TYPE t_tc_2211 OCCURS 0,
          g_tc_2211_wa     TYPE t_tc_2211, "work area
          g_tc_2211_tmp    TYPE t_tc_2211. "work area
DATA:     g_tc_2211_copied.           "copy flag

*> declaration of tablecontrol 'TC_2211' itself
CONTROLS: tc_2211 TYPE TABLEVIEW USING SCREEN 2211.

*> lines of tablecontrol 'TC_2211'
DATA:     g_tc_2211_lines  LIKE sy-loopc.

*-----------------------------------------------------------------------
*> 수입신고필증 란사항 컨트롤용.
*-----------------------------------------------------------------------
*> 규격.
*> type for the data of tablecontrol 'TC_2212'
TYPES: BEGIN OF t_tc_2212.
        INCLUDE STRUCTURE ztitcc2.
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
        INCLUDE STRUCTURE ztitcc3.
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
        INCLUDE STRUCTURE ZTITCC4.
TYPES:   flag,       "flag for mark column
       END OF t_tc_2212_2.

*> internal table for tablecontrol 'TC_2212_2'
DATA:     g_tc_2212_2_itab   TYPE t_tc_2212_2 OCCURS 0,
          g_tc_2212_2_tmp    TYPE t_tc_2212_2 OCCURS 0,
          g_tc_2212_2_wa     TYPE t_tc_2212_2. "work area
DATA:     g_tc_2212_2_copied.           "copy flag

*> declaration of tablecontrol 'TC_2212_2' itself
CONTROLS: tc_2212_2 TYPE TABLEVIEW USING SCREEN 2212 .

*> lines of tablecontrol 'TC_2212_2'
DATA:     g_tc_2212_2_lines  LIKE sy-loopc.
*<- 기능개선 xxxxx

DATA:   g_ccnum         LIKE ztitcck-cdcno,
        g_cdseq         LIKE ztitcc3-cdseq,
        gs_ztstig6_usd  LIKE ztstig6,
        G_Z9050         LIKE ZTITCC4-Z9050, "기능개선 XXXXX
        g_ccnum_chk1    TYPE c,
        g_ccnum_chk2    TYPE c.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF ty_header,
            box(1)      TYPE c,
            iccno       LIKE ztitcrk-iccno, "통관관리번호
            iccsq       LIKE ztitcrk-iccsq, "정정회차.
            cdrno       LIKE ztitcrk-cdrno, "신고번호.
            cdcdt       LIKE ztitcrk-cdcdt, "신고일자.
            iblno       LIKE ztitblk-iblno, "10B/L 관리번호.
            blnum       LIKE ztitblk-blnum, "25B/L 번호.
            bldty       LIKE ztitblk-bldty,                 "1문서종류.
            bldtyx(20)  TYPE c,             "문서종류TEXT.
            rptty       LIKE ztitblk-rptty, "1수입신고구분.
            rpttyx(20)  TYPE c,             "수입신고구분TEXT.
            bukrs       LIKE ztitblk-bukrs,                 "4회사코드.
            ekorg       LIKE ztitblk-ekorg,                 "4구매조직.
            ekgrp       LIKE ztitblk-ekgrp,                 "3구매그룹.
            lifnr       LIKE ztitblk-lifnr, "10공급업체 계정번호.
            name1       LIKE lfa1-name1,
            bletd       LIKE ztitblk-bletd, "8ETD(출발 예정 시각).
            bleta       LIKE ztitblk-bleta, "8ETA(도착 예정 시각).
            fwdty       LIKE ztitblk-fwdty, "1운송 방법.
            fwdtyx(20)  TYPE c,	          "1운송 방법TEXT.
            lponr       LIKE ztitblk-lponr, "5최종품목번호.
            waers       LIKE ztitblk-waers,                 "5통화키.
            trefwr      LIKE ztitblp-refwr, "total 금액.
            lgayn       LIKE ztitblk-lgayn. "LG대상여부.

TYPES: END OF ty_header.

TYPES: BEGIN OF ty_item.
INCLUDE     TYPE        ty_header.
TYPES :     iblit       LIKE ztitblp-iblit,	"5B/L 품목번호.
            iccit       LIKE ztitcrp-iccit,     "통관품번.
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
            ccmng       LIKE ztisccit-ccmngs,
            ccmngs      LIKE ztisccit-ccmngs,
            ccmngl      LIKE ztisccit-ccmngl,
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
      l_yn    type c.
** JS전선 회사코드 2007/04 KSH --------------------------------------
