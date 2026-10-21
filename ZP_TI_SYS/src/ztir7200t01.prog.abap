************************************************************************
* Title         :  ZTIR7200T01                                         *
*                                                                      *
* Description   : 수입 인수증 관리 Top Include                         *
*                                                                      *
* Creation Date : 2003/07/11                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                                                                      *
************************************************************************

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: ztitrqk,   ">수입의뢰(개설) 공통 헤더 테이블.
        ztitrqs,   ">수입의뢰(개설) 공통 상태 테이블.
        ztitlo1,   ">[Import] LOCAL  L/C MAIN (LOCAPP/LOCAMR)
        ztivrq04,  ">수입의뢰 Views : 최종회차( Header + Status)
        ztitack,   ">[Import] 인수증 Table
       *ztitack,   ">[Import] 인수증 Table
        ekbe,      ">구매문서별 이력.
        ztivac00,  ">인수증 조회.
        spop.      ">POPUP_TO_CONFIRM_... function 모듈 팝업화면 필드

************************************************************************
* SAP Structure                                                        *
************************************************************************
TABLES: ztisacp ,    ">인수증 Items
        ztisacit.    ">인수증 Items

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
  c_action              TYPE es_element     VALUE 'ZTIAC',
  c_no_draft_due_list   LIKE sy-tcode       VALUE space,     ">생성.
  c_create_d            LIKE sy-tcode       VALUE 'ZTIT720', ">생성.
  c_create              LIKE sy-tcode       VALUE space,     ">생성.
  c_create_a            LIKE sy-tcode       VALUE space,     ">None.
  c_change              LIKE sy-tcode       VALUE 'ZTIT722', ">변경.
  c_display             LIKE sy-tcode       VALUE 'ZTIT723', ">조회.
  c_delete              LIKE sy-tcode       VALUE 'ZTIT724', ">삭제.
  c_acceptance          LIKE sy-tcode       VALUE space,     ">None
  c_apply               LIKE sy-tcode       VALUE space,     ">None
  c_send                LIKE sy-tcode       VALUE space,     ">None
  c_open                LIKE sy-tcode       VALUE space,     ">None
  c_post                LIKE sy-tcode       VALUE space,     ">전기.
  c_reverse             LIKE sy-tcode       VALUE space,     ">취소
  c_reverse1            LIKE sy-tcode       VALUE space,     ">역분개.
  c_close               LIKE sy-tcode       VALUE space,     ">종료.
  c_textobject_header   LIKE ttxob-tdobject VALUE 'ZTIACHD'.

************************************************************************
* Internal Tables                                                      *
************************************************************************

*-----------------------------------------------------------------------
*> 수입의뢰아이템 --> Tree용.
*-----------------------------------------------------------------------
*> TYPE FOR THE DATA OF '수입의뢰아이템'
TYPES: BEGIN OF t_ztisacit.
        INCLUDE STRUCTURE ztisacit.
TYPES: box        TYPE c,
       index(10)  TYPE n,
       END OF t_ztisacit.

*> INTERNAL TABLE FOR TABLECONTROL '수입의뢰아이템'
DATA:     it_ztisacit         TYPE t_ztisacit OCCURS 0 WITH HEADER LINE,
          g_ztisacit_wa       TYPE t_ztisacit.           ">work area

DATA : BEGIN OF it_acitm OCCURS 0.
        INCLUDE STRUCTURE ztisacit.
DATA : END   OF it_acitm.
*> 인수증 문서번호.
DATA : BEGIN OF it_acdno OCCURS 0,
       iccno      TYPE ztiacdno.
DATA : END   OF it_acdno.

*> CHANGE DOCUMENT용.
DATA : BEGIN OF xztitacf OCCURS 0.
        INCLUDE STRUCTURE vztitacf.
DATA : END   OF xztitacf.

DATA : BEGIN OF yztitacf OCCURS 0.
        INCLUDE STRUCTURE vztitacf.
DATA : END   OF yztitacf.

DATA : BEGIN OF xztitacp OCCURS 0.
        INCLUDE STRUCTURE vztitacp.
DATA : END   OF xztitacp.

DATA : BEGIN OF yztitacp OCCURS 0.
        INCLUDE STRUCTURE vztitacp.
DATA : END   OF yztitacp.

DATA : BEGIN OF xztitac1 OCCURS 0.
        INCLUDE STRUCTURE vztitac1.
DATA : END   OF xztitac1.

DATA : BEGIN OF yztitac1 OCCURS 0.
        INCLUDE STRUCTURE vztitac1.
DATA : END   OF yztitac1.


*-----------------------------------------------------------------------
*> Item용.
*-----------------------------------------------------------------------
CONTROLS: tc_2130   TYPE TABLEVIEW USING SCREEN 2130.

*> TYPE FOR THE DATA OF TABLECONTROL 'tc_2130'
TYPES: BEGIN OF t_tc_2130.
        INCLUDE STRUCTURE ztisacp.
TYPES: END OF t_tc_2130.

*> INTERNAL TABLE FOR TABLECONTROL 'tc_2130'
DATA:     it_tab           TYPE t_tc_2130 OCCURS 0,
          g_tc_2130_wa     TYPE t_tc_2130,           ">work area
          g_tc_2130_copied.                          ">copy flag

*> LINES OF TABLECONTROL 'tc_2130'
DATA:     g_tc_2130_lines  LIKE sy-loopc.

*-----------------------------------------------------------------------
*> 회계문서 조회용.
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

DATA: g_scr2123_grid      TYPE REF TO cl_gui_alv_grid,
      g_scr2123_container TYPE REF TO cl_gui_custom_container.

*> 이력조회용.
*DATA: it_ztisacf TYPE TABLE OF ztisacf.
DATA: BEGIN OF it_ztisacf OCCURS 10.
        INCLUDE STRUCTURE ztisacf.
DATA: END   OF it_ztisacf.

DATA: BEGIN OF it_ztisac1 OCCURS 10.
        INCLUDE STRUCTURE ztisac1.
DATA: END   OF it_ztisac1.
*
************************************************************************
* ALV Class Include Define                                             *
************************************************************************
INCLUDE : zts_reuse_alvforms_t02.

***>>>> Due List용.
************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF ty_header,
            box         TYPE c,
            opnno       LIKE ztivac00-opnno,  "개설번호.
            opndt       LIKE ztivac00-opndt,  "개설일자.
            lifnr       LIKE ztivac00-lifnr,  "공급업체.
            name1       LIKE ztivac00-name1,  "공급업체명.
            vatno       LIKE ztitvak-vatno,
            lifnrb      LIKE ztivac00-lifnrb, "은행코드.
            namet       LIKE ztivac00-namet,  "은행명.
            enmt1       LIKE ztivac00-enmt1,  "은행영문명.
            bupla       LIKE ztivac00-bupla,  "사업장.
            bukrs       LIKE ztivac00-bukrs,  "회사코드.
            gjahr       LIKE bkpf-gjahr,      "연도.
            belnr       LIKE bkpf-belnr,      "전표번호.
            mjahr       LIKE ztivac00-mjahr,  "연도.
            mblnr       LIKE ztivac00-mblnr,  "전표번호.
            ekorg       LIKE ztivac00-ekorg,  "구매조직.
            ekgrp       LIKE ztivac00-ekgrp,  "구매그룹.
            waers       LIKE ztivac00-waers,  "전표통화.
            wrbtrh      LIKE ztivac00-wrbtr,  "전표금액.
            hwaer       LIKE bkpf-hwaer,      "현지통화.
            dmbtrh      LIKE ztivac00-dmbtr,  "현지금액.
            blart       LIKE ztivac00-blart,  "전표유형.
            budat       LIKE ztivac00-budat,  "전기일.
            bldat       LIKE ztivac00-bldat,  "증빙일.
            reqno       LIKE ztivac00-reqno,  "수입의뢰번호.
            amdsq       LIKE ztivac00-amdsq.  "Amend 차수.
TYPES: END OF ty_header.

TYPES: BEGIN OF ty_item.
INCLUDE     TYPE        ty_header.
TYPES :     ebeln       LIKE ztivac00-ebeln,  "구매전표번호.
            ebelp       LIKE ztivac00-ebelp,  "구매문서 품목번호.
            reqit       LIKE ztivac00-reqit,  "수입의뢰 품목번호.
            rqmng       LIKE ztivac00-rqmng,  "수입의뢰 수량.
            netwr       LIKE ztivac00-netwr,  "송장값 (외화).
            meins       LIKE ztivac00-meins,  "기본단위.
            zekkn       LIKE ztivac00-zekkn,  "계정지정순번.
            vgabe       LIKE ztivac00-vgabe,  "트랜잭션/이벤트 유형.
            buzei       LIKE ztivac00-buzei,  "자재문서품목.
            matnr       LIKE ztivac00-matnr,  "자재코드.
            txz01       LIKE ztivac00-txz01,  "자재명.
            werks       LIKE ztivac00-werks,  "플랜트.
            wrbtr       LIKE ztivac00-wrbtr,  "전표금액.
            dmbtr       LIKE ztivac00-dmbtr,  "현지금액..
            bewtl       LIKE ztivac00-bewtl.
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

DATA: BEGIN OF it_ztivac00 OCCURS 0.
        INCLUDE STRUCTURE ztivac00.
DATA: END   OF it_ztivac00.

DATA: BEGIN OF it_ztiTVAK OCCURS 0.
        INCLUDE STRUCTURE ztiTVAK.
DATA: END   OF it_ztiTVAK.

DATA: BEGIN OF it_ac_key OCCURS 0,
      mblnr    LIKE ztivac00-mblnr,
      mjahr    LIKE ztivac00-mjahr,
      bukrs    LIKE ztivac00-bukrs.
DATA: END   OF it_ac_key.

DATA: BEGIN OF it_opnno OCCURS 0,
      opnno    LIKE ztivac00-opnno.
DATA: END   OF it_opnno.

DATA: BEGIN OF it_reqno OCCURS 0,
      reqno    LIKE ztivac00-reqno,
      amdsq    LIKE ztivac00-amdsq.
DATA: END   OF it_reqno.


DATA: l_ukurs   TYPE tcurr-ukurs,
      l_dispaly TYPE xfeld.

** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: a_bukrs LIKE t001-bukrs,
      l_yn    type c.
** JS전선 회사코드 2007/04 KSH --------------------------------------
