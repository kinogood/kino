************************************************************************
* Title         :  ZTIR5000T01                                         *
*                                                                      *
* Description   : 수입 입고 관리 Top Include                           *
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
        ztitrqs,   ">수입의뢰(개설) 공통 상태 테이블
        ztitcck,   ">수입신고  MAIN (IMPREQ/IMPRES)
        ztitccp,   ">수입신고 아이템 테이블.
       *ztitgrk,   ">수입의뢰(개설) 공통 헤더 테이블
        ztitgrh,   ">수입물품 입고 이력 Table
        ztitgrp,   ">수입물품 입고 자재 Table
        ztitgrb,   ">[Import] 수입물품 입고 자재 Batch Table
        ZTITGRPX,  ">자체개선 104998 : 전자부품 외포장번호
        ZTITTAG,   ">기능개선 127661 : 꼬리표 생성 대상 관리 Table
        spop,      ">POPUP_TO_CONFIRM_... function 모듈 팝업화면 필드
        dd02l,
        ser03,
        mara,
        marc,
        EKES.

************************************************************************
* SAP Structure                                                        *
************************************************************************
TABLES: ztisgrit,    ">수입입고 Items
        ztisgrb.     ">[Import] 수입물품 입고 자재 Batch Table.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
  c_action              TYPE es_element     VALUE 'ZTIGR',
  c_no_draft_due_list   LIKE sy-tcode       VALUE 'ZTIR502', ">생성.
  c_create_d            LIKE sy-tcode       VALUE 'ZTIT500', ">생성.
  c_create              LIKE sy-tcode       VALUE 'ZTIT501', ">생성.
  c_create_a            LIKE sy-tcode       VALUE 'NONE',    ">None.
  c_change              LIKE sy-tcode       VALUE 'ZTIT502', ">변경.
  c_display             LIKE sy-tcode       VALUE 'ZTIT503', ">조회.
  c_delete              LIKE sy-tcode       VALUE 'ZTIT504', ">삭제.
  c_acceptance          LIKE sy-tcode       VALUE 'NONE',    ">None
  c_apply               LIKE sy-tcode       VALUE 'NONE',    ">None
  c_send                LIKE sy-tcode       VALUE space,     ">None
  c_open                LIKE sy-tcode       VALUE 'NONE',    ">None
  c_post                LIKE sy-tcode       VALUE 'ZTIT505', ">전기.
  c_reverse             LIKE sy-tcode       VALUE 'ZTIT506', ">취소
  c_reverse1            LIKE sy-tcode       VALUE 'NONE', ">역분개
  c_close               LIKE sy-tcode       VALUE 'NONE',    ">종료.
  c_textobject_header   LIKE ttxob-tdobject VALUE 'ZTIGRHD'.

************************************************************************
* Internal Tables                                                      *
************************************************************************
DATA: it_ztitblk LIKE ztitblk OCCURS 0 WITH HEADER LINE.

*-----------------------------------------------------------------------
*> 수입의뢰아이템 --> Tree용.
*-----------------------------------------------------------------------
*> TYPE FOR THE DATA OF '수입의뢰아이템'
TYPES: BEGIN OF t_ztisccit.
        INCLUDE STRUCTURE ztisccit.
TYPES: box        TYPE c,
       index(10)  TYPE n,
       END OF t_ztisccit.

*> INTERNAL TABLE FOR TABLECONTROL '수입의뢰아이템'
DATA:     it_ztisccit         TYPE t_ztisccit OCCURS 0 WITH HEADER LINE,
          g_ztisccit_wa       TYPE t_ztisccit.           ">work area

DATA : BEGIN OF it_ccitm OCCURS 0.
        INCLUDE STRUCTURE ztisccit.
DATA : END   OF it_ccitm.

DATA : BEGIN OF it_iccno OCCURS 0,
       iccno      TYPE ztiiccno.
DATA : END   OF it_iccno.

*> CHANGE DOCUMENT용.
DATA : BEGIN OF xztitgrp OCCURS 0.
        INCLUDE STRUCTURE vztitgrp.
DATA : END   OF xztitgrp.

DATA : BEGIN OF yztitgrp OCCURS 0.
        INCLUDE STRUCTURE vztitgrp.
DATA : END   OF yztitgrp.

*>-------------------------------------------------------------------
*> 입고용.
*>-------------------------------------------------------------------
TABLES : bapi2017_gm_head_01,
         bapi2017_gm_code,
         bapi2017_gm_head_ret,
         bapi2017_gm_item_create,
         bapi2017_gm_serialnumber,
         bapi2017_gm_item_04,
         bapiache08,
         bapiache02,
         bapiextc.

DATA : goodsmvt_header   LIKE bapi2017_gm_head_01,
       goodsmvt_code     LIKE bapi2017_gm_code,
       testrun           LIKE bapi2017_gm_gen-testrun,
       goodsmvt_headret  LIKE bapi2017_gm_head_ret,
       materialdocument  TYPE bapi2017_gm_head_ret-mat_doc,
       matdocumentyear   TYPE bapi2017_gm_head_ret-doc_year.

DATA:   BEGIN OF goodsmvt_item OCCURS 0.   ">> ITEM 내역.
        INCLUDE STRUCTURE   bapi2017_gm_item_create.
DATA:   END   OF goodsmvt_item.

DATA:   BEGIN OF goodsmvt_serialnumber OCCURS 0.   ">> RETURN 내역.
        INCLUDE STRUCTURE   bapi2017_gm_serialnumber.
DATA:   END   OF goodsmvt_serialnumber.

DATA:   BEGIN OF goodsmvt_matdocitem OCCURS 0.   ">> ITEM 내역.
        INCLUDE STRUCTURE   bapi2017_gm_item_04.
DATA:   END   OF goodsmvt_matdocitem.

DATA:   g_mvt_type LIKE  mseg-bwart.

DATA: goodsmvt_pstng_date LIKE  bapi2017_gm_head_02-pstng_date,
      goodsmvt_pr_uname   LIKE  bapi2017_gm_head_01-pr_uname.

DATA: g_mvt_ind           LIKE  goodsmvt_item-mvt_ind,
      g_no_more_gr        LIKE  goodsmvt_item-no_more_gr.

DATA:   BEGIN OF return OCCURS 0.   ">> RETURN 내역.
        INCLUDE STRUCTURE   bapiret2.
DATA:   END   OF return.

*-----------------------------------------------------------------------
*> Batch 관련 .
*-----------------------------------------------------------------------
DATA: g_tabname   TYPE tabname    VALUE 'ZMMT0024',
      g_iccit     TYPE ztiiccit,
      g_btabix    TYPE sy-tabix,
      g_ibcit     TYPE ztiibcit.

*-----------------------------------------------------------------------
*> 입고 Item용.
*-----------------------------------------------------------------------
CONTROLS: tc_2130   TYPE TABLEVIEW USING SCREEN 2130.

*> TYPE FOR THE DATA OF TABLECONTROL 'tc_2130'
TYPES: BEGIN OF t_tc_2130.
        INCLUDE STRUCTURE ztisgrit.
TYPES: END OF t_tc_2130.

*> INTERNAL TABLE FOR TABLECONTROL 'tc_2130'
DATA:     it_tab           TYPE t_tc_2130 OCCURS 0,
          g_tc_2130_wa     TYPE t_tc_2130,           ">work area
          g_tc_2130_copied.                          ">copy flag

*> LINES OF TABLECONTROL 'tc_2130'
DATA:     g_tc_2130_lines  LIKE sy-loopc.

*-----------------------------------------------------------------------
*> 입고 하위 Batch Item용.
*-----------------------------------------------------------------------
CONTROLS: tc_7000   TYPE TABLEVIEW USING SCREEN 7000.

*> TYPE FOR THE DATA OF TABLECONTROL 'tc_7000'
TYPES: BEGIN OF t_tc_7000.
        INCLUDE STRUCTURE ztisgrb.
TYPES: END OF t_tc_7000.

*> INTERNAL TABLE FOR TABLECONTROL 'tc_7000'
DATA:     g_tc_7000_itab       TYPE t_tc_7000 OCCURS 0,
          g_tc_7000_temp       TYPE t_tc_7000 OCCURS 0 WITH HEADER LINE,
          g_tc_7000_temp2      TYPE t_tc_7000 OCCURS 0 WITH HEADER LINE,
          g_tc_7000_temp_ghp   TYPE t_tc_7000 ,
          g_tc_7000_save       TYPE ztitgrb   OCCURS 0,
          g_tc_7000_wa         TYPE t_tc_7000,           ">work area
          g_tc_7000_copied.                              ">copy flag

*> LINES OF TABLECONTROL 'tc_7000'
DATA:     g_tc_7000_lines  LIKE sy-loopc.

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

DATA: g_scr2123_grid      TYPE REF TO cl_gui_alv_grid,
      g_scr2123_container TYPE REF TO cl_gui_custom_container.

*> 이력조회용.
*DATA: it_ZTIscshs TYPE TABLE OF ZTIscshs.
DATA: BEGIN OF it_ztisgrhs OCCURS 10.
        INCLUDE STRUCTURE ztisgrhs.
DATA: END   OF it_ztisgrhs.
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
            bldty       TYPE ztibldty,
            blnum       TYPE ztiblnum,
            iccno       LIKE ztitcck-iccno,	"10통관관리번호.
            iccsq       LIKE ztitcck-iccsq,
            bdseq       LIKE ztitbdp-bdseq,     "
            cdhdt       LIKE ztitcck-cdhdt,	"8신고희망일자.
            cdcdt       LIKE ztitcck-cdcdt,     "신고일
            cdrdt       LIKE ztitcck-cdrdt,     "신고수리일
            cdrno       LIKE ztitcck-cdrno,     "신고의뢰번호
            cdcno       LIKE ztitcck-cdcno,     "신고(수리)번호
            cdadt       LIKE ztitcck-cdadt,	"8수입신고 의뢰일자.
            cdcor       LIKE ztitcck-cdcor,                 "3신고세관
            cdcch       LIKE ztitcck-cdcch,                 "2신고과.
            cimty       LIKE ztitcck-cimty,	"1수입자구분.
            cdapn       LIKE ztitcck-cdapn,	"28신고의뢰자 상호.
            cimnm       LIKE ztitcck-cimnm,	"28수입자상호.
            ccono       LIKE ztitcck-ccono,	"8무역업등록번호.
            cdupn       LIKE ztitcck-cdupn,	"28납세의무자상호.
            cdunm       LIKE ztitcck-cdunm,	"12납세의무자성명.
            cduad1      LIKE ztitcck-cduad1,  "20납세의무자 주소.
            cduad2      LIKE ztitcck-cduad2,  "20납세의무자 주소.
            cplsg       LIKE ztitcck-cplsg,	"3소재지부호.
            ccoid       LIKE ztitcck-ccoid,	"13사업자 등록번호.
            ccuid       LIKE ztitcck-ccuid,	"15통관고유번호.
            ccbnm       LIKE ztitcck-ccbnm,	"28무역대리점상호.
            ccbid       LIKE ztitcck-ccbid,	"7무역대리점부호.
            casnm       LIKE ztitcck-casnm,	"30해외공급자상호.
            casld       LIKE ztitcck-casld,	"3해외공급자국.
            casid       LIKE ztitcck-casid,     "10해외공급자부호.
            crety       LIKE ztitcck-crety,                 "1신고구분.
            ccupl       LIKE ztitcck-ccupl,                 "1통관계획.
            csaty       LIKE ztitcck-csaty,                 "2거래구분.
            cipty       LIKE ztitcck-cipty,                 "1수입종류.
            cpyme       LIKE ztitcck-cpyme,                 "2결제방법.
            carty       LIKE ztitcck-carty,                 "2징수형태.
            cildt       LIKE ztitcck-cildt,                 "8반입일자.
            cblno       LIKE ztitcck-cblno,	"20B/L(AWB)번호.
            ccano       LIKE ztitcck-ccano,	"20화물관리번호.
            cbldy       LIKE ztitcck-cbldy,	"1B/L분할신고여부.
            cmbln       LIKE ztitcck-cmbln,	"20Master B/L No.
            cispc       LIKE ztitcck-cispc,	"8검사(반입)장소 코드.
            cispl       LIKE ztitcck-cispl,	"10검사(반입)장소.
            ctrme       LIKE ztitcck-ctrme,                 "2운송수단.
            ctrbo       LIKE ztitcck-ctrbo,                 "3운송용기.
            cofld       LIKE ztitcck-cofld,                 "3적출국.
            ctogi       LIKE ztitcck-ctogi,	"4운수기관부호.
            cspto       LIKE ztitcck-cspto,                 "2특송업체.
            caldt       LIKE ztitcck-caldt,                 "8입항일자.
            ciarp       LIKE ztitcck-ciarp,	"3국내도착항.
            cvsln       LIKE ztitcck-cvsln,	"20선(기)명.
            cvsld       LIKE ztitcck-cvsld,	"3선(기)국적.
            cinco       LIKE ztitcck-cinco,                 "3인도조건.
            cpyatc      LIKE ztitcck-cpyatc,  "5결제금액 통화.
            cpyat       LIKE ztitcck-cpyat,	"11결제금액.
            ccuakc      LIKE ztitcck-ccuakc,  "5과세가격합계(KRW)통화.
            ccuak       LIKE ztitcck-ccuak,	"11과세가격합계(KRW).
            ccuauc      LIKE ztitcck-ccuauc,  "5과세가격합계(USD)통화.
            ccuau       LIKE ztitcck-ccuau,	"11과세가격합계(USD).
*            cfratc      LIKE ZTITCCK-cfratc,	"5운임 통화.
*EHKIM CCM 수정 2023.04.25 ZTITCCK -> ZTITBLK 변경
*            cfrat       LIKE ztitcck-cfrat,                 "11운임.
            cfrat       LIKE ZTITBLK-cfrat,                 "11운임.
*            cipatc      LIKE ZTITCCK-cipatc,	"5보험료 통화.
            cipat       LIKE ztitcck-cipat,                 "11보험료.
*            cplatc      LIKE ZTITCCK-cplatc,	"5가산금액통화.
            cplat       LIKE ztitcck-cplat,	"11가산금액.
*            cfeatc      LIKE ZTITCCK-cfeatc,	"5공제금액 통화.
            cfeat       LIKE ztitcck-cfeat,	"11공제금액.
            cpyrt       LIKE ztitcck-cpyrt,                 "9결제환률.
            ctoweu      LIKE ztitcck-ctoweu,  "3총중량단위.
            ctowe       LIKE ztitcck-ctowe,                 "15총중량.
            ctpkg       LIKE ztitcck-ctpkg,	"8총포장갯수.
            ctpkgu      LIKE ztitcck-ctpkgu,  "3총포장갯수단위.
            ctseq       LIKE ztitcck-ctseq,                 "3총란수.
            ctsak       LIKE ztitcck-ctsak,	"11부가세과세과표.
            ctsat       LIKE ztitcck-ctsat,	"11부가세면세과표.
            cdutx       LIKE ztitcck-cdutx,                 "11관세.
            csptx       LIKE ztitcck-csptx,                 "11특소세.
            caltx       LIKE ztitcck-caltx,                 "11주세.
            ctrtx       LIKE ztitcck-ctrtx,                 "11교통세.
            cintx       LIKE ztitcck-cintx,                 "11교육세.
            cagtx       LIKE ztitcck-cagtx,                 "11농특세.
            cadtx       LIKE ztitcck-cadtx,                 "11부가세.
            clttx       LIKE ztitcck-clttx,    "11신고지연가산세.
            ctotl       LIKE ztitcck-ctotl.                 "11합계 .
TYPES: END OF ty_header.

TYPES: BEGIN OF ty_item.
INCLUDE     TYPE        ty_header.
TYPES :     iccit       LIKE ztitccp-iccit,	"수입신고 Items Number.
            ebeln       LIKE ztitccp-ebeln,	"구매전표번호.
            ebelp       LIKE ztitccp-ebelp,	"구매문서 품목번호.
            reqno       LIKE ztitccp-reqno,	"수입의뢰 관리번호.
            reqit       LIKE ztitccp-reqit,	"수입의뢰 품목번호.
            iblno       LIKE ztitccp-iblno,	"B/L 관리번호.
            iblit       LIKE ztitccp-iblit,	"B/L 품목번호.
            ibdsq       LIKE ztitbdp-ibdsq,     "
            ndfty       LIKE ztitccp-ndfty,	"무환품 종류.
            ccmng       LIKE ztitccp-ccmng,	"통관 수량.
            refwr       LIKE ztitccp-refwr,	"송장값 (외화).
            wepos       LIKE ekpo-wepos,
            meins       LIKE ztitccp-meins,    "기본단위.
            cnam        LIKE ztitccp-cnam,     "작성인.
            cdat        LIKE ztitccp-cdat,     "생성일.
            ctme        LIKE ztitccp-ctme,     "생성시간.
            unam        LIKE ztitccp-unam,  "최종변경인.
            udat        LIKE ztitccp-udat,     "변경일.
            utme        LIKE ztitccp-utme,  "최종변경시간.
            menge       LIKE ztisgrit-menge,
            grmngs      LIKE ztisgrit-grmngs,
            grmngl      LIKE ztisgrit-grmngl,
            matnr       LIKE ztisgrit-matnr,
            txz01       LIKE ztisgrit-txz01,
*-- [기능개선 ______] 인바운드 납품 필드추가   -[s]
            VBELN       LIKE EKES-VBELN .
*            VBELP       LIKE EKES-VBELP .
*-- [기능개선 ______] 인바운드 납품 필드추가   -[e]


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
