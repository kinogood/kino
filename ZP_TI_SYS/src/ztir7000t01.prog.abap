************************************************************************
* Title         :  ZTIR7000T01                                         *
*                                                                      *
* Description   : 수입 세금계산서 I/V 관리 Top Include                 *
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
        ztitvah,    ">[Import] 세금계산서 History table
        ztitvak,    ">[Import] 세금계산서 Header Table
       *ztitvak,    ">[Import] 세금계산서 Header Table
        ztitvap,    ">[Import] 세금계산서 Items table
        ztitblp,    ">B/L Header
        ztitlo1,
        ekbe,
        ztitrqk,    ">수입의뢰 Header
        ztitrqs,    ">수입의뢰 Status
        ztitrqp,    ">수입의뢰 Items
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
        ztisvait,    ">I/V Items
        ztisivvs.    ">분할금액구조.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF ty_header,
            CHKBX       TYPE C,
            reqno       LIKE ztitrqs-reqno,  ">수입의뢰 관리번호.
            amdsq       LIKE ztitrqs-amdsq,  ">수입의뢰 Seq.
            bukrs       LIKE ztitrqk-bukrs,  ">회사코드.
            ekorg       LIKE ztitrqk-ekorg,  ">구매조직.
            ekgrp       LIKE ztitrqk-ekgrp,  ">구매그룹.
            reqty       LIKE ztitrqk-reqty,  ">수입의뢰종류.
            reqtx(08)   TYPE c,
            lifnr       LIKE ztitrqk-lifnr,  ">공급업체 계정번호.
            name1       LIKE lfa1-name1,
            waers       LIKE ztitrqs-waers,  ">통화키.
            opamt       LIKE ztitrqs-opamt,
            ucurr       LIKE ztitrqs-ucurr,
            usamt       LIKE ztitrqs-usamt,
            hwaer       LIKE ztitrqs-hwaer,
            dmbtr       LIKE ztitrqs-dmbtr,
            opnno       LIKE ztitrqs-opnno,
            opndt       LIKE ztitrqs-opndt,  ">개설일자.
            opnbk       LIKE ztitrqk-opnbk,
            namet       LIKE ztstig3-namet,
            zterm       LIKE ztitrqs-zterm,
            llcty       LIKE ztitlo1-llcty.
TYPES: END OF ty_header.

TYPES: BEGIN OF ty_item.
INCLUDE     TYPE        ty_header.
TYPES       box(1)      TYPE c.
TYPES :
            ebeln       LIKE ztitrqp-ebeln, "10구매전표번호.
            ebelp       LIKE ztitrqp-ebelp, "5구매문서 품목번호.
            meins       LIKE ekpo-meins,    "구매오더단위.
            menge       LIKE ekpo-menge,    "구매오더수량.
            webre       LIKE ekpo-webre,
            reqit       LIKE ztitblp-reqit, "수입의뢰 품목번호.
            rqmng       LIKE ztitrqp-rqmng, "수입의뢰수량.
            gjahr       LIKE ekbe-gjahr,
            belnr       LIKE ekbe-belnr,
            buzei       LIKE ekbe-buzei,
            budat       LIKE ekbe-budat,
            ivmng       LIKE ztitvap-ivmng,
            ivmngi      LIKE ztisvait-ivmngi,
            ivmngs      LIKE ztisvait-ivmngs,
            cnam        LIKE ztitblp-cnam,  ">작성인.
            cdat        LIKE ztitblp-cdat,  ">생성일.
            ctme        LIKE ztitblp-ctme,  ">생성시간.
            unam        LIKE ztitblp-unam,  ">최종변경인.
            udat        LIKE ztitblp-udat,  ">변경일.
            utme        LIKE ztitblp-utme,   ">최종변경시간.
            werks       LIKE ztisblit-werks,
            name2       LIKE ztisblit-name1,
            matnr       LIKE ztisblit-matnr,
            txz01       LIKE ztisblit-txz01,
            matkl       LIKE ztivpo00-matkl,
            eindt       LIKE eket-eindt,
            mwskz       LIKE ekbe-mwskz,
            netpr       LIKE ztisblit-netpr,
            peinh       LIKE ztisblit-peinh,
            BPRME       LIKE ZTISBLIT-BPRME,
            netwr       LIKE ztisblit-netwr,
************************************************************
*> For TraSys ECC Upgrade By ASEG Co., Ltd.
************************************************************
*> 2009/02/16
*> Internal Table 상에 필드 추가
*> Started of Insert
************************************************************
            refwr       LIKE ztitvap-ivmng.
************************************************************
*> Ended of Insert
************************************************************
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
DATA: it_temp      TYPE ty_list   OCCURS 0 WITH HEADER LINE.
DATA: it_header    TYPE ty_header OCCURS 0 WITH HEADER LINE.
DATA: it_tab_h     TYPE ty_tab    OCCURS 0 WITH HEADER LINE.

DATA: it_ekbe      LIKE ekbe      OCCURS 0  WITH HEADER LINE,
      it_ek08rn    LIKE ek08rn    OCCURS 10 WITH HEADER LINE.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
  c_action              TYPE es_element     VALUE 'ZTIVA',
  c_create_d            LIKE sy-tcode       VALUE 'ZTIT700', ">생성.
  c_create              LIKE sy-tcode       VALUE 'ZTIT701', ">생성.
  c_create_a            LIKE sy-tcode       VALUE '',        ">Amend
  c_change              LIKE sy-tcode       VALUE 'ZTIT702', ">변경.
  c_display             LIKE sy-tcode       VALUE 'ZTIT703', ">조회.
  c_delete              LIKE sy-tcode       VALUE 'ZTIT704', ">삭제.
  c_acceptance          LIKE sy-tcode       VALUE '',        ">접수.
  c_apply               LIKE sy-tcode       VALUE '',        ">신청.
  c_send                LIKE sy-tcode       VALUE space,     ">None
  c_open                LIKE sy-tcode       VALUE '',        ">개설.
  c_post                LIKE sy-tcode       VALUE ' ',       ">전기.
  c_reverse             LIKE sy-tcode       VALUE 'ZTIT705', ">취소.
  c_reverse1            LIKE sy-tcode       VALUE 'NONE',    ">None
  c_close               LIKE sy-tcode       VALUE 'NONE',    ">종료.
  c_textobject_header   LIKE ttxob-tdobject VALUE 'ZTIVAHD'.

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

*> TYPE FOR THE DATA OF '수입의뢰아이템'
TYPES: BEGIN OF t_ztisrqit.
        INCLUDE STRUCTURE ztisrqit.
TYPES: box        TYPE c,
       index(10)  TYPE n,
       remng      TYPE remng,
       webre      TYPE webre,
       ivmng      TYPE ztiivmng,
       ivmngs     TYPE ztiivmngs,
       ivmngl     TYPE ztiivmngi,
       END OF t_ztisrqit.

*> INTERNAL TABLE FOR TABLECONTROL '수입의뢰아이템'
DATA:     it_ztisrqit         TYPE t_ztisrqit OCCURS 0 WITH HEADER LINE,
          it_reqit_tmp        TYPE t_ztisrqit OCCURS 0 WITH HEADER LINE,
          g_ztisrqit_wa       TYPE t_ztisrqit.           ">work area

*> CHANGE DOCUMENT용.
DATA : BEGIN OF xztitvap OCCURS 0.
        INCLUDE STRUCTURE vztitvap.
DATA : END   OF xztitvap.

DATA : BEGIN OF yztitvap OCCURS 0.
        INCLUDE STRUCTURE vztitvap.
DATA : END   OF yztitvap.
**> CHANGE DOCUMENT용.
*DATA : BEGIN OF xztitivv OCCURS 0.
*        INCLUDE STRUCTURE vztitivv.
*DATA : END   OF xztitivv.
*
*DATA : BEGIN OF yztitivv OCCURS 0.
*        INCLUDE STRUCTURE vztitivv.
*DATA : END   OF yztitivv.
*> 전기이력.
DATA : BEGIN OF it_ztitvah OCCURS 0.
        INCLUDE STRUCTURE ztisvahs.
DATA : END   OF it_ztitvah.

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
        INCLUDE STRUCTURE ztisvait.
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

DATA:   g_vatsq      LIKE ztitvak-vatsq,
        g_kursf(16)  TYPE p DECIMALS 5,
        g_vatsq_chk1 TYPE c,
        g_vatsq_chk2 TYPE c.

DATA: BEGIN OF gt_ekpo OCCURS 0,
      ebeln   TYPE ebeln,
      ebelp   TYPE ebelp,
      peinh   TYPE peinh,
      bpumz   TYPE bpumz,
      bpumn   TYPE bpumn,
      menge   TYPE menge_d,
      netpr   TYPE netpr,
      netwr   TYPE netwr,
      webre   TYPE webre,
      uebto   TYPE uebto,
      END   OF gt_ekpo.

** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: a_bukrs LIKE t001-bukrs,
      l_yn    type c.
** JS전선 회사코드 2007/04 KSH --------------------------------------
