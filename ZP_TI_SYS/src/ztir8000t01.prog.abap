************************************************************************
* Title         :  ZTIR8000T01                                         *
*                                                                      *
* Description   : 수입 Notice 관리 Top Include                         *
*                                                                      *
* Creation Date : 2004/02/12                                           *
*                                                                      *
* Author        : Seog bong, Kang                                      *
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
TABLES: *ztitivk,   ">I/V Header
        ztitivp,    ">I/V Header
        ztitblp,    ">B/L Header
        ztitpnk,    ">Notice Header
       *ztitpnk,    ">Notice Header
        ztitpnp,    ">Notice Items
        ztitpnh,    ">Notice Usance 반제전기 History table
        ztitrqk,    ">수입의뢰 Header
        ztitrqs,    ">수입의뢰 Status
        ztitrqp,    ">수입의뢰 Items
        ztitig38,   ">[Import] Notice 관련 초기값 및 TR매치코드 정의.
        spop,        ">POPUP_TO_CONFIRM_... function 모듈 팝업화면 필드.
        but000.      ">BP: 일반데이타 I

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES: ztivrq04.    ">수입의뢰 Views(Header + Items) : 최종회차별.

************************************************************************
* SAP Structure                                                        *
************************************************************************
TABLES: ztisrqit,    ">수입의뢰 Items
        ztisblit,    ">B/L Items
        ztisivit,    ">I/V Items
        ztispnit.    ">Notice Items

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
  c_create_d            LIKE sy-tcode       VALUE 'ZTIT800', ">생성.
  c_create              LIKE sy-tcode       VALUE 'ZTIT801', ">생성.
  c_create_a            LIKE sy-tcode       VALUE 'NONE',    ">Amend.
  c_change              LIKE sy-tcode       VALUE 'ZTIT802', ">변경.
  c_display             LIKE sy-tcode       VALUE 'ZTIT803', ">조회.
  c_delete              LIKE sy-tcode       VALUE 'ZTIT804', ">삭제.
  c_acceptance          LIKE sy-tcode       VALUE 'NONE',    ">접수.
  c_apply               LIKE sy-tcode       VALUE 'NONE',    ">신청.
  c_open                LIKE sy-tcode       VALUE 'NONE',    ">개설.
  c_send                LIKE sy-tcode       VALUE space,     ">None
  c_post                LIKE sy-tcode       VALUE 'ZTIT805', ">전기.
  c_reverse             LIKE sy-tcode       VALUE 'ZTIT806', ">취소.
  c_reverse1            LIKE sy-tcode       VALUE 'NONE',    ">None
  c_close               LIKE sy-tcode       VALUE 'NONE',    ">종료.
  c_textobject_header   LIKE ttxob-tdobject VALUE 'ZTIPNHD',
*----->Usance임시계정과목.
  c_saknr               LIKE skb1-saknr     VALUE '0009520000',
  c_due_list_lo         LIKE sy-tcode       VALUE 'ZTIR801',
  c_due_list_rt         LIKE sy-tcode       VALUE 'ZTIR804',
  c_action              TYPE es_element     VALUE 'ZTIPN'.

************************************************************************
* Internal Tables                                                      *
************************************************************************
*> TYPE FOR THE DATA OF 'Notice 아이템'
TYPES: BEGIN OF t_ztispnit.
        INCLUDE STRUCTURE ztispnit.
TYPES: box        TYPE c,
       index(10)  TYPE n,
       ivmng      TYPE remng,
       ivmngs     TYPE ztiivmngs,
       ivmngl     TYPE ztiivmngi,
       END OF t_ztispnit.

DATA:  it_ztispnit         TYPE t_ztispnit OCCURS 0 WITH HEADER LINE,
       it_ztisivit         LIKE ztisivit   OCCURS 0 WITH HEADER LINE.

*> CHANGE DOCUMENT용.
DATA : BEGIN OF xztitpnp OCCURS 0.
        INCLUDE STRUCTURE vztitpnp.
DATA : END   OF xztitpnp.

DATA : BEGIN OF yztitpnp OCCURS 0.
        INCLUDE STRUCTURE vztitpnp.
DATA : END   OF yztitpnp.

DATA : BEGIN OF it_belnr OCCURS 0,
       ivono    TYPE ztiivono,
       belnr    TYPE belnr_d,
       gjahr    TYPE gjahr,
       refwr    TYPE refwr,
       netwr    TYPE netwr.
DATA : END   OF it_belnr.

DATA: BEGIN OF it_ztisrqit OCCURS 0.
        INCLUDE STRUCTURE ztispnit.
DATA: END   OF it_ztisrqit.

DATA: g_reqty   TYPE ztireqty.

*-----------------------------------------------------------------------
*> 아이템 테이블용.
*-----------------------------------------------------------------------
CONTROLS: tc_2130   TYPE TABLEVIEW USING SCREEN 2130.

*> TYPE FOR THE DATA OF TABLECONTROL 'tc_2130'
TYPES: BEGIN OF t_tc_2130.
        INCLUDE STRUCTURE ztispnit.
TYPES: END OF t_tc_2130.

*> INTERNAL TABLE FOR TABLECONTROL 'tc_2130'
DATA:     it_tab           TYPE t_tc_2130 OCCURS 0,
          it_tab_o         TYPE t_tc_2130 OCCURS 0,
          g_tc_2130_wa     TYPE t_tc_2130,           ">work area
          g_tc_2130_copied.                          ">copy flag

*> LINES OF TABLECONTROL 'tc_2130'
DATA:     g_tc_2130_lines  LIKE sy-loopc.

*> WBS 요소.
DATA: BEGIN OF it_pspnr  OCCURS 2,
      pspnr   TYPE  ps_psp_pnr.
DATA: END   OF it_pspnr.

*> 전기이력.
DATA: BEGIN OF it_ztispnhs  OCCURS 1.
        INCLUDE STRUCTURE ztispnhs.
DATA: END   OF it_ztispnhs.

DATA: g_scr2123_grid      TYPE REF TO cl_gui_alv_grid,
      g_scr2123_container TYPE REF TO cl_gui_custom_container.

DATA: it_fieldcat_lvc     TYPE lvc_t_fcat WITH HEADER LINE.
DATA: it_fieldcat_lvc_1   TYPE lvc_t_fcat WITH HEADER LINE.

DATA: g_variant           LIKE disvariant.

*-------------------------------------------------
*> LIV CANCEL..
DATA: reasonreversal             LIKE bapi_incinv_fld-reason_rev,
      postingdate                LIKE bapi_incinv_fld-pstng_date,
      invoicedocnumber_reversal  LIKE bapi_incinv_fld-inv_doc_no,
      fiscalyear_reversal        LIKE bapi_incinv_fld-fisc_year,
      return                     LIKE bapiret2
                                      OCCURS 10 WITH HEADER LINE.
*-------------------------------------------------


************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF ty_header,
            box(1)      TYPE c,
            ivono       LIKE ztitivk-ivono,  "10송장 관리번호
            ivnum       LIKE ztitivk-ivnum,
            blnum       LIKE ztitblk-blnum,  "B/L NUMBER
            opnno       LIKE ztitrqs-opnno,  "수입개설번호
            reqty       LIKE ztitrqk-reqty,
            reqtyx(30)  TYPE c,
            ilcty       LIKE ztitrqk-ilcty,
            ilctyx(20)  TYPE c,
            docst       LIKE ztitrqs-docst,
            civdt       LIKE ztitivk-civdt,  "8문서의 송장일
            vorgang     LIKE ztitivk-vorgang,"1트랜잭션/이벤트
            bukrs       LIKE ztitivk-bukrs,
            ekorg       LIKE ztitivk-ekorg,
            ekgrp       LIKE ztitivk-ekgrp,
            blart       LIKE ztitivk-blart,
            bupla       LIKE ztitivk-bupla,
            gsber       LIKE ztitivk-gsber,
            budat       LIKE ztitivk-budat,  "8전표의 전기일
            bldat       LIKE ztitivk-bldat,  "8전표에서 송장일
            zterm       LIKE ztitivk-zterm,  "4지급조건키
            zfbdt       LIKE ztitivk-zfbdt,  "8만기계산기준일
            netdt       LIKE ztitivk-netdt,  "8순액지급 만기일
            zbd1t       LIKE ztitivk-zbd1t,  "3현금할인기간 1
            zbd2t       LIKE ztitivk-zbd2t,  "3현금 할인기간 2
            zbd3t       LIKE ztitivk-zbd3t,  "3순액지급조건기간
            zbd1p       LIKE ztitivk-zbd1p,  "5현금할인율 1
            zbd2p       LIKE ztitivk-zbd2p,  "5두번째 현금할인율
            mwskz       LIKE ztitivk-mwskz,  "2부가가치세코드
            waers       LIKE ztitivk-waers,
*            kursf       LIKE ZTITIVK-kursf,
            wwert       LIKE ztitivk-wwert,
            lifnr       LIKE ztitivk-lifnr,  "10다른 송장발행처
            ivamt       LIKE ztitivk-ivamt,  "13문서통화 - 총송장금액
            ivamp       LIKE ztitivk-ivamp,  "13서통화 - 총처리금액
            pkchg       LIKE ztitivk-pkchg,  "13Packing charge
            hdchg       LIKE ztitivk-hdchg,  "13Handling Charge
            otchg       LIKE ztitivk-otchg,  "13Others Charge
            rtchg       LIKE ztitivk-rtchg,  "13Retention amount
            livst       LIKE ztitivk-livst,  "1송장처리 상태
            prpyn       LIKE ztitivk-prpyn,  "1선급금 구분
            pprat       LIKE ztitivk-pprat,  "3선급금 비율
            xblnr       LIKE ztitivk-xblnr,  "16참조전표번호
            bktxt       LIKE ztitivk-bktxt,  "25전표헤더텍스트
            zlspr       LIKE ztitivk-zlspr,  "1지급보류키
            zlsch       LIKE ztitivk-zlsch,
            uzawe       LIKE ztitivk-uzawe,  "2지급방법보충
            belnr       LIKE ztitivk-belnr,  "10송장문서의 문서번호
            gjahr       LIKE ztitivk-gjahr,
            lponr       LIKE ztitivk-lponr.	"6최종품목번호
*non iv dictionary.
TYPES:      trefwr      LIKE ztitivp-refwr,	"13송장값 total
            name1       LIKE lfa1-name1.        "LIFNR명
TYPES: END OF ty_header.

TYPES: BEGIN OF ty_item.
INCLUDE     TYPE        ty_header.
TYPES :     rblgp       LIKE ztitivp-rblgp,	                "5 품목
            ebeln       LIKE ztitivp-ebeln,
            ebelp       LIKE ztitivp-ebelp,	"5구매문서 품목
            matnr       LIKE ekpo-matnr,
            txz01       LIKE ekpo-txz01,
            reqno       LIKE ztitivp-reqno,	"10수입의뢰번호
            reqit       LIKE ztitivp-reqit,	"5수입의뢰 품목
            iblno       LIKE ztitivp-iblno,	"10B/L 관리번호
            iblit       LIKE ztitivp-iblit,	"5B/L 품목번호
            refwr       LIKE ztitivp-refwr,	"13송장값 (외화)trefwr
            remng       LIKE ztitivp-remng,	"13송장처리수량
            meins       LIKE ztitivp-meins,
            tbtkz       LIKE ztitivp-tbtkz,	"1후속 차변/대변
*            MWSKZ       LIKE ZTITIVP-MWSKZ,	"2부가가치세코드
            kschl       LIKE ztitivp-kschl,
            stunr       LIKE ztitivp-stunr,
            zaehk       LIKE ztitivp-zaehk,	"2조건카운터
            sgtxt       LIKE ztitivp-sgtxt,	"50항목텍스트
            cnam        LIKE ztitivp-cnam,
            cdat        LIKE ztitivp-cdat,
            ctme        LIKE ztitivp-ctme,
            unam        LIKE ztitivp-unam,
            udat        LIKE ztitivp-udat,
            utme        LIKE ztitivp-utme,
            flag        LIKE ztisivit-flag,
            menge       LIKE ztisivit-menge,
            ivmngs      LIKE ztisivit-ivmngs,	"13I/V 누적수량
            ivmngl      LIKE ztisivit-ivmngl,	"13I/V 가능수량
            werks       LIKE ztisivit-werks,
            name2       LIKE ztisivit-name1,
            lgort       LIKE ztisivit-lgort,
            lgobe       LIKE ztisivit-lgobe,
*            matnr       LIKE ZTIsivit-matnr,
*            txz01       LIKE ZTIsivit-txz01,
            netwr       LIKE ztisivit-netwr,	"15문서통화 정가
            eeind       LIKE ztisivit-eeind,
            umson       LIKE ztisivit-umson,
            loekz       LIKE ztisivit-loekz,	"1구매문서삭제지시
            elikz       LIKE ztisivit-elikz,	"1"납품완료"지시자
            bprme       LIKE ztisivit-bprme,	"3오더가격단위
            bpumz       LIKE ztisivit-bpumz,	"5오더단위환산분자
            bpumn       LIKE ztisivit-bpumn,	"5오더단위환산분모
            umrez       LIKE ztisivit-umrez,	"5기본단위전환분자
            umren       LIKE ztisivit-umren,	"5기본단위전환분모
            netpr       LIKE ztisivit-netpr,	"11구매문서의 단가
            peinh       LIKE ztisivit-peinh,
            uebto       LIKE ztisivit-uebto,	"3초과납품 허용치
            uebtk       LIKE ztisivit-uebtk,	"1허용무제한초과납품
            untto       LIKE ztisivit-untto.	"3미달납품 허용치

TYPES: END OF ty_item.


TYPES: BEGIN OF ty_list.
INCLUDE             TYPE        ty_item.
TYPES:      color   TYPE slis_t_specialcol_alv.
TYPES: END OF ty_list.

*> Select용.
TYPES: BEGIN OF ty_tab.
INCLUDE     TYPE        ty_item.
TYPES: END OF ty_tab.

************************************************************************
* Internal Tables                                                      *
************************************************************************
DATA: it_list      TYPE ty_list   OCCURS 0 WITH HEADER LINE.
DATA: it_header    TYPE ty_header OCCURS 0 WITH HEADER LINE.
DATA: it_tab_h     TYPE ty_tab    OCCURS 0 WITH HEADER LINE.

** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: a_bukrs LIKE t001-bukrs,
      l_yn    type c.
** JS전선 회사코드 2007/04 KSH --------------------------------------
