************************************************************************
* Title         :  ZTIR4800T01                                         *
*                                                                      *
* Description   : 보세구역 반출 관리 TOP Include                       *
*                                                                      *
* Creation Date : 2004/12/21                                           *
*                                                                      *
* Author        : Seog Bong, Kang                                      *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: ztitbsk,    ">Bill of Lading 보세운송(반입예정정보).
        ztitbik,    ">Bill of Lading 반입신고.
        ztitbok,    ">Bill of Lading 반출 신고.
       *ztitbok,    ">Bill of Lading 반출 신고.
        ztitblp,    ">B/L Header
        vztitbdp,   ">
        ztitcck,    ">[Import] 수입신고필증  MAIN (IMPREQ/IMPRES)
        ztitbdk,    ">보세구역 반출 Header
       *ztitbdk,    ">보세구역 반출 Header
        ztitbdp,    ">보세구역 반출 Items
        ztitrqk,    ">수입의뢰 Header
        ztitrqs,    ">수입의뢰 Status
        ztitrqp.    ">수입의뢰 Items

************************************************************************
* SAP Structure                                                        *
************************************************************************
TABLES: ztisrqit,    ">수입의뢰 Items
        ztisblit,    ">B/L Items
        ztisbdit,    ">보세구역 반출 Items
        ztisccit.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
  c_action              TYPE es_element     VALUE 'ZTIBD',
  c_create_d            LIKE sy-tcode       VALUE 'ZTIT480', ">생성.
  c_create              LIKE sy-tcode       VALUE 'ZTIT481', ">생성.
  c_create_a            LIKE sy-tcode       VALUE 'NONE',    ">None.
  c_change              LIKE sy-tcode       VALUE 'ZTIT482', ">변경.
  c_display             LIKE sy-tcode       VALUE 'ZTIT483', ">조회.
  c_delete              LIKE sy-tcode       VALUE 'ZTIT484', ">삭제.
  c_acceptance          LIKE sy-tcode       VALUE 'NONE', ">접수.
  c_apply               LIKE sy-tcode       VALUE 'NONE', ">개설신청.
  c_send                LIKE sy-tcode       VALUE space,     ">None
  c_open                LIKE sy-tcode       VALUE 'NONE', ">개설.
  c_post                LIKE sy-tcode       VALUE 'NONE',    ">전기.
  c_reverse             LIKE sy-tcode       VALUE 'NONE',    ">취소.
  c_reverse1            LIKE sy-tcode       VALUE 'NONE',    ">None
  c_close               LIKE sy-tcode       VALUE 'NONE',    ">종료.
  c_textobject_header   LIKE ttxob-tdobject VALUE 'ZTIBDHD'.

************************************************************************
* Internal Tables                                                      *
************************************************************************
DATA : BEGIN OF it_blnum OCCURS 0,
       iblno      LIKE ztitblk-iblno.
DATA : END   OF it_blnum.

DATA : BEGIN OF it_bl OCCURS 0,
       box         TYPE c,
       index(10)   TYPE n,
       iblno       LIKE ztitblk-iblno,	"10B/L 관리번호.
       iblit       LIKE ztitblp-iblit,	"5B/L 품목번호.
       ndfty       LIKE ztitblp-ndfty,	"1무환품 종류.
       blmng       LIKE ztitblp-blmng,	"13B/L 수량.
       refwr       LIKE ztitblp-refwr,	"13송장값 (외화).
       meins       LIKE ztitblp-meins,                      "3기본단위.
       ebeln       LIKE ztitblp-ebeln,	"10구매전표번호.
       ebelp       LIKE ztitblp-ebelp,	"5구매문서 품목번호.
       reqno       LIKE ztitblp-reqno,	"10수입의뢰 관리번호.
       reqit       LIKE ztitblp-reqit,	"5수입의뢰 품목번호.
*       mblnr       LIKE ZTITBLP-mblnr,	"10자재문서번호.
*       mjahr       LIKE ZTITBLP-mjahr,	"4자재문서연도.
*       zeile       LIKE ZTITBLP-zeile,	"4자재문서품목.
       menge       LIKE ztisivit-menge,
       ivmngs      LIKE ztisivit-ivmngs,
       ivmngl      LIKE ztisivit-ivmngl.
DATA : END OF it_bl.
************************************************************************
* DATA Declarations                                                    *
************************************************************************
*---------------------------------------------------------------------
* Accumulators
*---------------------------------------------------------------------
*DATA:
*  BEGIN OF A,
*
*  END OF A.
*----------------------------------------------------------------------
* Switches
*----------------------------------------------------------------------
*DATA:
*  BEGIN OF SW,
*
*  END OF SW.
*----------------------------------------------------------------------
* Work fields
*----------------------------------------------------------------------
*DATA:
*  BEGIN OF W,
*
*  END OF W.
************************************************************************
** RANGES
************************************************************************
*RANGES:
*  R_XXXXX                    FOR TTTT-XXXXX.
*
***********************************************************************
* FIELD-GROUPS
***********************************************************************
*FIELD-GROUPS:
*
***********************************************************************
* FIELD-SYMBOLS
***********************************************************************
*FIELD-SYMBOLS:
*
************************************************************************
* MACRO DEFINE                                                         *
************************************************************************

*-----------------------------------------------------------------------
*> B/L Item용.
*-----------------------------------------------------------------------
CONTROLS: tc_2130   TYPE TABLEVIEW USING SCREEN 2130.

*> TYPE FOR THE DATA OF TABLECONTROL 'tc_2130'
TYPES: BEGIN OF t_tc_2130.
        INCLUDE STRUCTURE ztisbdit.
TYPES: END OF t_tc_2130.

*> INTERNAL TABLE FOR TABLECONTROL 'tc_2130'
DATA:     it_tab           TYPE t_tc_2130 OCCURS 0,
          g_tc_2130_wa     TYPE t_tc_2130,           ">work area
          g_tc_2130_copied.                          ">copy flag

*> LINES OF TABLECONTROL 'tc_2130'
DATA:     g_tc_2130_lines  LIKE sy-loopc.


*> CHANGE DOCUMENT용.
DATA : BEGIN OF xztitbdp OCCURS 0.
        INCLUDE STRUCTURE vztitbdp.
DATA : END   OF xztitbdp.

DATA : BEGIN OF yztitbdp OCCURS 0.
        INCLUDE STRUCTURE vztitbdp.
DATA : END   OF yztitbdp.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF ty_header,
            box(1)      TYPE c,
            iccno       LIKE ztitbdp-iccno,   "10수입의뢰 관리번호.
            iblno       LIKE ztitblk-iblno,	"10B/L 관리번호.
            ibsno       LIKE ztitbsk-ibsno,	"10B/L 관리번호.
            ibino       LIKE ztitbik-ibino,	"10B/L 관리번호.
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
            fwdtyx(20)  TYPE c,	              "1운송 방법TEXT.
            lponr       LIKE ztitblk-lponr,	"5최종품목번호.
            waers       LIKE ztitblk-waers,                 "5통화키.
            trefwr      LIKE ztitblp-refwr,     "total 금액.
            lgayn       LIKE ztitblk-lgayn.     "LG대상여부.

TYPES: END OF ty_header.

TYPES: BEGIN OF ty_item.
INCLUDE     TYPE        ty_header.
TYPES :     iblit       LIKE ztitblp-iblit,   "5B/L 품목번호.
            ndfty       LIKE ztitblp-ndfty,   "1무환품 종류.
            ndftyx(20)  TYPE c,	            "무환품 종류TEXT.
            blmng       LIKE ztitblp-blmng,   "13B/L 수량.
            refwr       LIKE ztitblp-refwr,   "13송장값 (외화).
            meins       LIKE ztitblp-meins,                 "3기본단위.
            ebeln       LIKE ztitblp-ebeln,   "10구매전표번호.
            ebelp       LIKE ztitblp-ebelp,   "5구매문서 품목번호.
            reqno       LIKE ztitblp-reqno,   "10수입의뢰 관리번호.
            reqit       LIKE ztitblp-reqit,   "5수입의뢰 품목번호.
            iccit       LIKE ztitbdp-iccit,   "5수입의뢰 품목번호.

*            mblnr       LIKE ZTITBLP-mblnr,	"10자재문서번호.
*            mjahr       LIKE ZTITBLP-mjahr,	"4자재문서연도.
*            zeile       LIKE ZTITBLP-zeile,	"4자재문서품목.
            cnam        LIKE ztitblp-cnam,                  "12작성인.
            cdat        LIKE ztitblp-cdat,                  "8생성일.
            ctme        LIKE ztitblp-ctme,                  "6생성시간.
            unam        LIKE ztitblp-unam,	"12최종변경인.
            udat        LIKE ztitblp-udat,                  "8변경일.
            utme        LIKE ztitblp-utme,	"6최종변경시간.
            pomng       LIKE ztisblit-menge,    "p/o수량.
            menge       LIKE ztisblit-menge,
            ccmng       LIKE ztisccit-ccmng,
            bdqty       LIKE ztisbdit-bdqty,
            bdqtys      LIKE ztisbdit-bdqtys,
            bdqtyl      LIKE ztisbdit-bdqtyl,
            blmngs      LIKE ztisblit-blmngs,
            blmngl      LIKE ztisblit-blmngl,
            ccmngs      LIKE ztisccit-ccmngs,
            ccmngl      LIKE ztisccit-ccmngl,
            grmngs      LIKE ztisgrit-grmngs,
            grmngl      LIKE ztisgrit-grmngl,
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

DATA: it_list      TYPE ty_list   OCCURS 0 WITH HEADER LINE.
DATA: it_header    TYPE ty_header OCCURS 0 WITH HEADER LINE.
DATA: it_tab_h     TYPE ty_tab    OCCURS 0 WITH HEADER LINE.
