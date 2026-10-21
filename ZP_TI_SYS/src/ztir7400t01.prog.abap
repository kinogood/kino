************************************************************************
* Title         :  ZTIR7400T01                                         *
*                                                                      *
* Description   : 수입 기납증/분증 관리 Top Include                    *
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
        ztitrqp,   ">[Import] 수입요청(개설) 공통 품목 테이블.
        ztitcck,   ">수입신고  MAIN (IMPREQ/IMPRES)
        ztitccp,   ">수입신고 아이템 테이블.
        ztittxk,   ">[Import] 기납증 Header
       *ztittxk,   ">[Import] 기납증 Header
        ztittxp,   ">[Import] 기납증 Items
        ztittxr,   ">[Import] 기납증 계산근거(을) Table
        ztivrq04,  ">수입의뢰 Views : 최종회차( Header + Status)
        ztitack,   ">[Import] 인수증 Table
       *ztitack,   ">[Import] 인수증 Table
        ztistxit,  ">[Import] 기납증 구매오더 품목용 구조체.
        t001k,     ">평가영역.
        ztitcsk,   ">[Import] 수입비용문서 Header table
        ztitig07,  ">[TraSys] 제비용 일괄전기 Default Value관리.
        ztivrq02,  ">수입의뢰 Views : 전체회차 ( Header + Status )
        spop.      ">POPUP_TO_CONFIRM_... function 모듈 팝업화면 필드

************************************************************************
* SAP Structure                                                        *
************************************************************************
TABLES: ztisacp .    ">인수증 Items

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
  c_action              TYPE es_element     VALUE 'ZTITX',
  c_no_draft_due_list   LIKE sy-tcode       VALUE space, ">생성.
  c_create_d            LIKE sy-tcode       VALUE 'ZTIT740', ">생성.
  c_create              LIKE sy-tcode       VALUE 'ZTIT741', ">생성.
  c_create_a            LIKE sy-tcode       VALUE space,     ">None.
  c_change              LIKE sy-tcode       VALUE 'ZTIT742', ">변경.
  c_display             LIKE sy-tcode       VALUE 'ZTIT743', ">조회.
  c_delete              LIKE sy-tcode       VALUE 'ZTIT744', ">삭제.
  c_acceptance          LIKE sy-tcode       VALUE space,     ">None
  c_apply               LIKE sy-tcode       VALUE space,     ">None
  c_open                LIKE sy-tcode       VALUE space,     ">None
  c_send                LIKE sy-tcode       VALUE space,     ">None
  c_post                LIKE sy-tcode       VALUE 'ZTIT745', ">전기.
  c_reverse             LIKE sy-tcode       VALUE space,     ">취소
  c_reverse1            LIKE sy-tcode       VALUE space,     ">역분개.
  c_close               LIKE sy-tcode       VALUE space,     ">종료.
  c_textobject_header   LIKE ttxob-tdobject VALUE 'ZTITXHD'.

************************************************************************
* Internal Tables                                                      *
************************************************************************

*-----------------------------------------------------------------------
*> 수입의뢰아이템 --> Tree용.
*-----------------------------------------------------------------------
*> TYPE FOR THE DATA OF '수입의뢰아이템'
TYPES: BEGIN OF t_ztistxit.
        INCLUDE STRUCTURE ztistxit.
TYPES: box        TYPE c,
       index(10)  TYPE n,
       END OF t_ztistxit.

*> INTERNAL TABLE FOR TABLECONTROL '수입의뢰아이템'
DATA:     it_ztistxit         TYPE t_ztistxit OCCURS 0 WITH HEADER LINE,
          g_ztistxit_wa       TYPE t_ztistxit.           ">work area

DATA : BEGIN OF it_acitm OCCURS 0.
        INCLUDE STRUCTURE ztistxit.
DATA : END   OF it_acitm.
*> 인수증 문서번호.
DATA : BEGIN OF it_taxno OCCURS 0,
       taxno      TYPE ztitaxno.
DATA : END   OF it_taxno.

*> CHANGE DOCUMENT용.
DATA : BEGIN OF xztittxp OCCURS 0.
        INCLUDE STRUCTURE vztittxp.
DATA : END   OF xztittxp.

DATA : BEGIN OF yztittxp OCCURS 0.
        INCLUDE STRUCTURE vztittxp.
DATA : END   OF yztittxp.

DATA : BEGIN OF xztittxr OCCURS 0.
        INCLUDE STRUCTURE vztittxr.
DATA : END   OF xztittxr.

DATA : BEGIN OF yztittxr OCCURS 0.
        INCLUDE STRUCTURE vztittxr.
DATA : END   OF yztittxr.

DATA : g_ztittxk_temp LIKE ztittxk.

DATA:    BEGIN OF excl OCCURS 25,
           funktion(10),
         END OF excl.
*-----------------------------------------------------------------------
*> Item용.
*-----------------------------------------------------------------------
CONTROLS: tc_2130   TYPE TABLEVIEW USING SCREEN 2130.

*> TYPE FOR THE DATA OF TABLECONTROL 'tc_2130'
TYPES: BEGIN OF t_tc_2130.
        INCLUDE STRUCTURE ztistxit.
TYPES: END OF t_tc_2130.

*> INTERNAL TABLE FOR TABLECONTROL 'tc_2130'
DATA:     it_tab           TYPE t_tc_2130 OCCURS 0,
          g_tc_2130_wa     TYPE t_tc_2130,           ">work area
          g_tc_2130_copied.                          ">copy flag

*> LINES OF TABLECONTROL 'tc_2130'
DATA:     g_tc_2130_lines  LIKE sy-loopc.

DATA: BEGIN OF it_ztistxr OCCURS 0.
        INCLUDE STRUCTURE ztistxr.
DATA: END   OF it_ztistxr.

*> 전기용 Items
DATA: BEGIN OF it_ztistxd OCCURS 0.
        INCLUDE STRUCTURE ztistxd.
DATA: END   OF it_ztistxd.

*---------------------------------------------------------------------*
*> Message dialog box용                                               *
*---------------------------------------------------------------------*
DATA: BEGIN OF it_msg  OCCURS 0.
        INCLUDE STRUCTURE ztismessage.
DATA: END   OF it_msg.

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
*DATA: it_ZTIscshs TYPE TABLE OF ZTIscshs.
DATA: BEGIN OF it_ztistxh OCCURS 10.
        INCLUDE STRUCTURE ztistxh.
DATA: END   OF it_ztistxh.
*
*> TYPE FOR THE DATA OF '수입의뢰아이템'
TYPES: BEGIN OF t_ztisrqit.
        INCLUDE STRUCTURE ztisrqit.
TYPES: box        TYPE c,
       index(10)  TYPE n,
       txmng      TYPE ztitxmng,
       txmngs     TYPE ztitxmngs,
       txmngl     TYPE ztitxmngl,
       END OF t_ztisrqit.

*> INTERNAL TABLE FOR TABLECONTROL '수입의뢰아이템'
DATA:     it_ztisrqit         TYPE t_ztisrqit OCCURS 0 WITH HEADER LINE,
          g_ztisrqit_wa       TYPE t_ztisrqit.           ">work area

DATA : BEGIN OF it_reqno OCCURS 0,
       reqno      TYPE ztireqno.
DATA : END   OF it_reqno.


************************************************************************
* ALV Class Include Define                                             *
************************************************************************
INCLUDE : zts_reuse_alvforms_t02.

***>>>> Due List용.
************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF ty_header,
            box(1)      TYPE c,
            reqno       LIKE ztitrqk-reqno,   "수입의뢰 관리번호.
            amdsq       LIKE ztitrqs-amdsq,   "Amend 차수.
            reqty       LIKE ztitrqk-reqty,   "수입의뢰 종류.
            ilcty       LIKE ztitrqk-ilcty,   "1신용장 종류.
            ilctyx(15)  TYPE c,	            "신용장 종류TEXT.
            lifnr       LIKE ztitrqk-lifnr,   "공급업체 계정번호.
            name1       LIKE lfa1-name1,
            lifre       LIKE ztitrqk-lifre,   "다른 송장발행처.
            name3       LIKE lfa1-name1,
            offer       LIKE ztitrqk-offer,   "오퍼상(Offer).
            name4       LIKE lfa1-name1,
            opnbk       LIKE ztitrqk-opnbk,   "개설은행.
            namet       LIKE ztstig3-namet,
            bukrs       LIKE ztitrqk-bukrs,   "회사코드.
            ekorg       LIKE ztitrqk-ekorg,   "구매조직.
            ekgrp       LIKE ztitrqk-ekgrp,   "구매그룹.
            appct       LIKE ztitrqk-appct,   "수입자 구분.
            lstas       LIKE ztitrqk-lstas,   "최종 Amend 차수.
            lponr       LIKE ztitrqs-lponr,   "최종품목번호.
            anbty       LIKE ztitrqk-anbty,   "사전/사후 구분자.
            ppaid       LIKE ztitrqk-ppaid,   "선급금 여부.
            pprat       LIKE ztitrqk-pprat,   "선급금 비율.
            rpaid       LIKE ztitrqk-rpaid,   "유보금 여부.
            rprat       LIKE ztitrqk-rprat,   "유보금 비율.

            opnno       LIKE ztitrqs-opnno,   "20수입개설번호.
            opndt       LIKE ztitrqs-opndt,   "개설일자.
            zterm       LIKE ztitrqs-zterm,   "4지급조건키.
            opamt       LIKE ztitrqs-opamt,   "개설금액.
            waers       LIKE ztitrqs-waers,   "통화키.
            wkurs       LIKE ztitrqs-wkurs,                 "9환율.
            inco1       LIKE ztitrqs-inco1,   "3인도조건 (파트 1).
            inco2       LIKE ztitrqs-inco2,   "28인도조건 (파트 2).
            exdat       LIKE ztitrqs-exdat,   "COM:유효기일.
            lsdat       LIKE ztitrqs-lsdat,   "COM:최종선적일자.
            ediyn       LIKE ztitrqs-ediyn,   "EDI 적용여부.
            insyn       LIKE ztitrqs-insyn,   "적하보험대상여부.
            fwdty       LIKE ztitrqs-fwdty,   "운송 방법.
            fland       LIKE ztitrqs-fland,   "선적국가.
            fport       LIKE ztitrqs-fport,   "선적항.
            pllod       LIKE ztitrqs-pllod,   "COM:선적항.
            tland       LIKE ztitrqs-tland,   "도착국가.
            tport       LIKE ztitrqs-tport,   "도착항.
            pltrn       LIKE ztitrqs-pltrn,   "COM:도착항.
            party       LIKE ztitrqs-party,   "분할선적허용여부.
            trany       LIKE ztitrqs-trany,   "환적허용여부.
            reqdt       LIKE ztitrqs-reqdt,   "개설희망일자.
            appun       LIKE ztitrqs-appun,   "개설의뢰 요청자.
            appdt       LIKE ztitrqs-appdt,   "개설의뢰 요청일.
            apptm       LIKE ztitrqs-apptm,   "개설의뢰 요청시간.
            accun       LIKE ztitrqs-accun,   "요청접수 담당자.
            accdt       LIKE ztitrqs-accdt,   "요청접수일자.
            acctm       LIKE ztitrqs-acctm,   "요청접수시간.
            sndun       LIKE ztitrqs-sndun,   "12개설신청자.
            snddt       LIKE ztitrqs-snddt,   "개설신청일.
            sndtm       LIKE ztitrqs-sndtm,   "개설신청시간.
            rcvun       LIKE ztitrqs-rcvun,   "12개설등록자.
            rcvdt       LIKE ztitrqs-rcvdt,   "개설등록일자.
            rcvtm       LIKE ztitrqs-rcvtm,   "개설등록시간.
            recid       LIKE ztitrqs-recid,   "수신자 ID.
            recnm       LIKE ztitrqs-recnm,   "수신자 명.
            recno       LIKE ztitrqs-recno,   "문서번호.
            docst       LIKE ztitrqs-docst,   "문서상태.
            docstx(8)   TYPE c,          	     "문서상태TEXT.
            count       TYPE i.
TYPES: END OF ty_header.

TYPES: BEGIN OF ty_item.
INCLUDE     TYPE        ty_header.
TYPES :     reqit       LIKE ztistxit-reqit,   "수입의뢰 품목번호.
            ebeln       LIKE ztistxit-ebeln,   "구매전표번호.
            ebelp       LIKE ztistxit-ebelp,   "구매문서 품목번호.
            matkl       LIKE ekpo-matkl,      "자재그룹.
            rqmng       LIKE ztistxit-rqmng,   "수입의뢰수량.
            meins       LIKE ztistxit-meins,   "기본단위.
            menge       LIKE ztistxit-menge,
            txmngs      LIKE ztistxit-txmngs,
            txmngl      LIKE ztistxit-txmngl,
            werks       LIKE ztistxit-werks,
            name2       LIKE ztistxit-name1,
            matnr       LIKE ztistxit-matnr,
            txz01       LIKE ztistxit-txz01,
            eeind       LIKE ztistxit-eeind,
            netpr       LIKE ztistxit-netpr,
            peinh       LIKE ztistxit-peinh,
            netwr       LIKE ztistxit-netwr.
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
DATA: it_tabh      TYPE ty_tab    OCCURS 0 WITH HEADER LINE.

** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: a_bukrs LIKE t001-bukrs,
      l_yn    type c.
** JS전선 회사코드 2007/04 KSH --------------------------------------
