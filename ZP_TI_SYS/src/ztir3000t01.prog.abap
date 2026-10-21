************************************************************************
* Title         :  ZTIR3000T01                                         *
*                                                                      *
* Description   : 수입 I/V 관리 Top Include                            *
*                                                                      *
* Creation Date : 2003/08/12                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
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
TABLES:*ztitivk,    ">I/V Header
        ztitivp,    ">I/V Header
        ztitivh,    ">I/V history
        ztitblp,    ">B/L Header
        ztitrqk,    ">수입의뢰 Header
        ztitrqs,    ">수입의뢰 Status
        ztitrqp,    ">수입의뢰 Items
        ztitrqx,    ">사전송금송장생성용 임시 Vendor관리
        ztitivv.    ">분할금액.

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES: ztivrq04.

************************************************************************
* SAP Structure                                                        *
************************************************************************
TABLES: ztisrqit,    ">수입의뢰 Items
        ztisblit,    ">B/L Items
        ztisivit,    ">I/V Items
        ztisivvs.    ">분할금액구조.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF ty_header,
            box(1)      TYPE c,
            iblno       LIKE ZTITBLK-iblno, "10B/L 관리번호.
            blnum       LIKE ZTITBLK-blnum, "25B/L 번호.
            bldty       LIKE ZTITBLK-bldty,                "1문서종류.
            bldtyx(20)  TYPE c,                 "문서종류TEXT.
            rptty       LIKE ZTITBLK-rptty, "1수입신고구분.
            rpttyx(20)  TYPE c,                 "수입신고구분TEXT.
            bukrs       LIKE ZTITBLK-bukrs,                "4회사코드.
            ekorg       LIKE ZTITBLK-ekorg,                "4구매조직.
            ekgrp       LIKE ZTITBLK-ekgrp,                "3구매그룹.
            lifnr       LIKE ZTITBLK-lifnr, "10공급업체 계정번호.
            name1       LIKE lfa1-name1,
            bletd       LIKE ZTITBLK-bletd, "8ETD(출발 예정 시각).
            bleta       LIKE ZTITBLK-bleta, "8ETA(도착 예정 시각).
            fwdty       LIKE ZTITBLK-fwdty, "1운송 방법.
            fwdtyx(20)  TYPE c,	                "1운송 방법TEXT.
            lponr       LIKE ZTITBLK-lponr, "5최종품목번호.
            waers       LIKE ZTITBLK-waers,                "5통화키.
            trefwr      LIKE ZTITBLP-refwr, ">> total 송장금액.
            lgayn       LIKE ZTITBLK-lgayn.    "LG대상여부.

TYPES: END OF ty_header.

TYPES: BEGIN OF ty_item.
INCLUDE     TYPE        ty_header.
TYPES :     iblit       LIKE ZTITBLP-iblit, "5B/L 품목번호.
            ndfty       LIKE ZTITBLP-ndfty, "1무환품 종류.
            ndftyx(20)  TYPE c,	              "무환품 종류TEXT.
            blmng       LIKE ZTITBLP-blmng, "13B/L 수량.
            refwr       LIKE ZTITBLP-refwr, "13송장값 (외화).
            meins       LIKE ZTITBLP-meins,                "3기본단위.
            ebeln       LIKE ZTITBLP-ebeln, "10구매전표번호.
            ebelp       LIKE ZTITBLP-ebelp, "5구매문서 품목번호.
            reqno       LIKE ZTITBLP-reqno, "10수입의뢰 관리번호.
            reqit       LIKE ZTITBLP-reqit, "5수입의뢰 품목번호.
*            mblnr       LIKE ZTITBLP-mblnr, "10자재문서번호.
*            mjahr       LIKE ZTITBLP-mjahr, "4자재문서연도.
*            zeile       LIKE ZTITBLP-zeile, "4자재문서품목.
            cnam        LIKE ZTITBLP-cnam,                 "12작성인.
            cdat        LIKE ZTITBLP-cdat,                 "8생성일.
            ctme        LIKE ZTITBLP-ctme,                 "6생성시간.
            unam        LIKE ZTITBLP-unam, "12최종변경인.
            udat        LIKE ZTITBLP-udat,                 "8변경일.
            utme        LIKE ZTITBLP-utme, "6최종변경시간.
            menge       LIKE ZTIsblit-menge,
            blmngs      LIKE ZTIsblit-blmngs,
            blmngl      LIKE ZTIsblit-blmngl,
            ivmngl      LIKE ZTIsivit-ivmngl,
            ivmngs      LIKE ZTIsivit-ivmngs,
            werks       LIKE ZTIsblit-werks,
            name2       LIKE ZTIsblit-name1,
            matnr       LIKE ZTIsblit-matnr,
            txz01       LIKE ZTIsblit-txz01,
            matkl       LIKE ZTIvpo00-matkl,
            eeind       LIKE ZTIsblit-eeind,
            netpr       LIKE ZTIsblit-netpr,
            peinh       LIKE ZTIsblit-peinh,
            netwr       LIKE ZTIsblit-netwr.

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

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
  c_action              TYPE es_element     VALUE 'ZTIIV',
  c_create_d            LIKE sy-tcode       VALUE 'ZTIT300', ">생성.
  c_create              LIKE sy-tcode       VALUE 'ZTIT301', ">생성.
  c_create_a            LIKE sy-tcode       VALUE '',        ">Amend
  c_change              LIKE sy-tcode       VALUE 'ZTIT302', ">변경.
  c_display             LIKE sy-tcode       VALUE 'ZTIT303', ">조회.
  c_delete              LIKE sy-tcode       VALUE 'ZTIT304', ">삭제.
  c_acceptance          LIKE sy-tcode       VALUE '',        ">접수.
  c_apply               LIKE sy-tcode       VALUE '',        ">신청.
  c_send                LIKE sy-tcode       VALUE space,     ">None
  c_open                LIKE sy-tcode       VALUE '',        ">개설.
  c_post                LIKE sy-tcode       VALUE ' ',       ">전기.
  c_reverse             LIKE sy-tcode       VALUE 'ZTIT305', ">취소.
  c_reverse1            LIKE sy-tcode       VALUE 'NONE',    ">None
  c_close               LIKE sy-tcode       VALUE 'NONE',    ">종료.
  c_textobject_header   LIKE ttxob-tdobject VALUE 'ZTIIVHD'.

************************************************************************
* Internal Tables                                                      *
************************************************************************
DATA : BEGIN OF it_blnum OCCURS 0,
       iblno      LIKE ztitblk-iblno.
DATA : END   OF it_blnum.

DATA : BEGIN OF it_reqno OCCURS 0,
       reqno      LIKE ztitrqk-reqno.
DATA : END   OF it_reqno.

DATA : BEGIN OF it_ztitig02 OCCURS 0.
        INCLUDE STRUCTURE ztitig02.
DATA : END   OF it_ztitig02.

DATA : BEGIN OF it_bl OCCURS 0,
       box        TYPE c,
       index(10)  TYPE n,
       iblno      LIKE ztitblk-iblno,  "10B/L 관리번호.
       iblit      LIKE ztitblp-iblit,  "5B/L 품목번호.
       ndfty      LIKE ztitblp-ndfty,  "1무환품 종류.
       blmng      LIKE ztitblp-blmng,  "13B/L 수량.
       refwr      LIKE ztitblp-refwr,  "13송장값 (외화).
       meins      LIKE ztitblp-meins,                       "3기본단위.
       ebeln      LIKE ztitblp-ebeln,  "10구매전표번호.
       ebelp      LIKE ztitblp-ebelp,  "5구매문서 품목번호.
       reqno      LIKE ztitblp-reqno,  "10수입의뢰 관리번호.
       reqit      LIKE ztitblp-reqit,  "5수입의뢰 품목번호.
       menge      LIKE ztisivit-menge,
       ivmngs     LIKE ztisivit-ivmngs,
       ivmngl     LIKE ztisivit-ivmngl,
       refwrs     LIKE ztitblp-refwr,  "13송장값 (외화).
       ppmng      TYPE ztippmng,
       ppamt      TYPE ztippamt,
       ppmngs     TYPE ztippmng,
       ppamts     TYPE ztippamt.
DATA : END OF it_bl.

*> TYPE FOR THE DATA OF '수입의뢰아이템'
TYPES: BEGIN OF t_ztisrqit.
        INCLUDE STRUCTURE ztisrqit.
TYPES: box        TYPE c,
       index(10)  TYPE n,
       remng      TYPE remng,
       ivmngs     TYPE ztiivmngs,
       ivmngl     TYPE ztiivmngi,
       END OF t_ztisrqit.

*> INTERNAL TABLE FOR TABLECONTROL '수입의뢰아이템'
DATA:     it_ztisrqit         TYPE t_ztisrqit OCCURS 0 WITH HEADER LINE,
          it_reqit_tmp        TYPE t_ztisrqit OCCURS 0 WITH HEADER LINE,
          g_ztisrqit_wa       TYPE t_ztisrqit.           ">work area

*> CHANGE DOCUMENT용.
DATA : BEGIN OF xztitivp OCCURS 0.
        INCLUDE STRUCTURE vztitivp.
DATA : END   OF xztitivp.

DATA : BEGIN OF yztitivp OCCURS 0.
        INCLUDE STRUCTURE vztitivp.
DATA : END   OF yztitivp.
*> CHANGE DOCUMENT용.
DATA : BEGIN OF xztitivv OCCURS 0.
        INCLUDE STRUCTURE vztitivv.
DATA : END   OF xztitivv.

DATA : BEGIN OF yztitivv OCCURS 0.
        INCLUDE STRUCTURE vztitivv.
DATA : END   OF yztitivv.
*> 전기이력.
DATA : BEGIN OF it_ztitivh OCCURS 0.
        INCLUDE STRUCTURE ztisivhs.
DATA : END   OF it_ztitivh.
*> 분할금액.
DATA : BEGIN OF it_ztitivv OCCURS 0.
        INCLUDE STRUCTURE ztisivvs.
DATA : END   OF it_ztitivv.

DATA : gs_ztitivv TYPE ztisivvs.

*-----------------------------------------------------------------------
*> 비용이력 조회용.
*-----------------------------------------------------------------------
DATA: g_variant           LIKE disvariant.
DATA: gx_variant          LIKE disvariant.
*DATA: g_variant_save.
DATA: p_variant           LIKE disvariant-variant.
DATA: it_fieldcat_lvc     TYPE lvc_t_fcat WITH HEADER LINE.
DATA: it_dynpread         LIKE dynpread OCCURS 0 WITH HEADER LINE.
DATA  g_user_specific.
DATA: gt_sort_lvc         TYPE lvc_t_sort WITH HEADER LINE.
DATA: gt_filt_lvc         TYPE lvc_t_filt WITH HEADER LINE.

DATA: g_scr2124_grid      TYPE REF TO cl_gui_alv_grid,
      g_scr2124_container TYPE REF TO cl_gui_custom_container.

*-----------------------------------------------------------------------
*> 아이템 테이블용.
*-----------------------------------------------------------------------
CONTROLS: tc_2130   TYPE TABLEVIEW USING SCREEN 2130.

*> TYPE FOR THE DATA OF TABLECONTROL 'tc_2130'
TYPES: BEGIN OF t_tc_2130.
        INCLUDE STRUCTURE ztisivit.
TYPES: END OF t_tc_2130.

*> INTERNAL TABLE FOR TABLECONTROL 'tc_2130'
DATA:     it_tab           TYPE t_tc_2130 OCCURS 0,
          it_tab_o         TYPE t_tc_2130 OCCURS 0,
          g_tc_2130_wa     TYPE t_tc_2130,           ">work area
          g_tc_2130_old    TYPE t_tc_2130,           ">work area
          g_tc_2130_copied.                          ">copy flag

*> LINES OF TABLECONTROL 'tc_2130'
DATA:     g_tc_2130_lines  LIKE sy-loopc.


*-----------------------------------------------------------------------
*> 아이템 테이블용.
*-----------------------------------------------------------------------
*> internal table for tablecontrol 'TC_2123'
DATA:     g_tc_2123_wa     TYPE ztisivvs. "work area
DATA:     g_tc_2123_copied.               "copy flag

*> declaration of tablecontrol 'TC_2123' itself
CONTROLS: tc_2123 TYPE TABLEVIEW USING SCREEN 2123.

*> lines of tablecontrol 'TC_2123'
DATA:     g_tc_2123_lines  LIKE sy-loopc.


*> payment terms logic.
TABLES: faede.

DATA:   g_zlspr LIKE t052-zschf,
        g_zlsch LIKE t052-zlsch,
        g_zfbdt LIKE rbkp_v-zfbdt.

DATA:   g_ivnum      LIKE ztitivk-ivnum,
        g_ivnum_chk1 TYPE c,
        g_ivnum_chk2 TYPE c.

DATA:   G_AFTYN LIKE ZTITIG02-AFTYN."43436 추가

DATA: BEGIN OF gt_ekpo OCCURS 0,
      ebeln   TYPE ebeln,
      ebelp   TYPE ebelp,
      peinh   TYPE peinh,
      bpumz   TYPE bpumz,
      bpumn   TYPE bpumn,
      menge   TYPE menge_d,
      netpr   TYPE netpr,
      netwr   TYPE netwr,
      webre   type webre,
      uebto   type uebto,
      END   OF gt_ekpo.

** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: a_bukrs LIKE t001-bukrs,
      l_yn    type c.
** JS전선 회사코드 2007/04 KSH --------------------------------------
