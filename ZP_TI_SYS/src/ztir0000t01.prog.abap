************************************************************************
* Title         :  ZTIR0000T01                                         *
*                                                                      *
* Description   : 수입 L/C 관리 Top Include                            *
*                                                                      *
* Creation Date : 2003/07/11                                           *
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
************************************************************************

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: ztitrqk,    ">수입의뢰 Header
       *ztitrqk,    ">수입의뢰 Header
        ztitrqs,    ">수입의뢰 Status
       *ztitrqs,    ">수입의뢰 Status
        ztitrqp,    ">수입의뢰 Items
        ztitlo1,    ">LOCAL  L/C MAIN (LOCAPP/LOCAMR)
       *ztitlo1,    ">LOCAL  L/C MAIN (LOCAPP/LOCAMR)
        ztitpc1,    ">구매확인서 MAIN (APPPCR/PCRLIC)
       *ztitpc1,    ">구매확인서 MAIN (APPPCR/PCRLIC)
        ztitpc2,    ">구매확인서 ITEM (근거서류)
       *ztitpc2,    ">구매확인서 ITEM (근거서류)
        ztitpc3,    ">구매확인서 ITEM (물품내역)
       *ztitpc3,    ">구매확인서 ITEM (물품내역)
        ztitlc1,    ">MASTER L/C MAIN (APP700/APP707)
       *ztitlc1,    ">MASTER L/C MAIN (APP700/APP707)
        ztitlc2,    ">MASTER L/C ITEM (Long text)
       *ztitlc2,    ">MASTER L/C ITEM (Long text)
        ztitlc3,    ">MASTER L/C (수입승인)
       *ztitlc3,    ">MASTER L/C (수입승인)
        ztitlc5,    ">[Import] MASTER L/C MAIN (EDI 수신 데이타)
        ztittt1,    ">지급지시서 T/T MAIN (PAYORD)
       *ztittt1,    ">지급지시서 T/T MAIN (PAYORD)
        ztittt2,    ">지급지시서 T/T ITEM (입금관련서류)
       *ztittt2,    ">지급지시서 T/T ITEM (입금관련서류)
        ztittt3,    ">지급지시서 T/T ITEM (부가수수료)
       *ztittt3,    ">지급지시서 T/T ITEM (부가수수료)
        ztitdak,
       *ztitdak,
        ztitig10,   ">선적국가별 포워더 관리.
        ztitcrk,    ">[Import] 수입신고  의뢰 MAIN (IMPREQ/IMPRES)
        ztitig30,   ">[Import] 수입의뢰요청 -> 구매오더 복사필드 정의.
        rkwa,       ">위탁출고.
        adrc,       ">
        spop,       ">POPUP_TO_CONFIRM_... function 모듈 팝업화면 필드.
        ztivcc02,   ">면장이 발행된 B/L Views
        ztitig04,   ">수취인 계좌관리
        ztitig51,   ">신용장 기타 부가조건 텍스트 관리.
        ztitig52.   ">신용장 기타 추가문서 텍스트 관리.

TABLES: ztisrqit,   ">수입의뢰 Items
        ztislc04,   ">L/C 포워더 관리.
        zzpa0001.     ">결재자 사번table "TR-HR

************************************************************************
* Internal Tables                                                      *
************************************************************************
DATA : BEGIN OF it_ztitig51 OCCURS 0.
        INCLUDE STRUCTURE ztitig51.
DATA : END   OF it_ztitig51.

DATA : BEGIN OF it_ztitig52 OCCURS 0.
        INCLUDE STRUCTURE ztitig52.
DATA : END   OF it_ztitig52.

DATA : BEGIN OF it_ztitig02 OCCURS 0.
        INCLUDE STRUCTURE ztitig02.
DATA : END   OF it_ztitig02.

DATA : BEGIN OF xztisig51 OCCURS 0.
        INCLUDE STRUCTURE ztisig51.
DATA : END   OF xztisig51.

DATA : BEGIN OF xztisig52 OCCURS 0.
        INCLUDE STRUCTURE ztisig52.
DATA : END   OF xztisig52.

DATA : BEGIN OF it_ztstigt OCCURS 0.
        INCLUDE STRUCTURE ztstigt.
DATA : END   OF it_ztstigt.

DATA : BEGIN OF it_ztitig11 OCCURS 0.
        INCLUDE STRUCTURE ztitig11.
DATA : END   OF it_ztitig11.

*> CHANGE DOCUMENT용.
DATA : BEGIN OF xztitlc2 OCCURS 0.
        INCLUDE STRUCTURE vztitlc2.
DATA : END   OF xztitlc2.

DATA : BEGIN OF yztitlc2 OCCURS 0.
        INCLUDE STRUCTURE vztitlc2.
DATA : END   OF yztitlc2.

DATA : BEGIN OF xztitlc3 OCCURS 0.
        INCLUDE STRUCTURE vztitlc3.
DATA : END   OF xztitlc3.

DATA : BEGIN OF yztitlc3 OCCURS 0.
        INCLUDE STRUCTURE vztitlc3.
DATA : END   OF yztitlc3.

DATA : BEGIN OF xztitlc4 OCCURS 0.
        INCLUDE STRUCTURE vztitlc4.
DATA : END   OF xztitlc4.

DATA : BEGIN OF yztitlc4 OCCURS 0.
        INCLUDE STRUCTURE vztitlc4.
DATA : END   OF yztitlc4.

DATA : BEGIN OF xztitpc2 OCCURS 0.
        INCLUDE STRUCTURE vztitpc2.
DATA : END   OF xztitpc2.

DATA : BEGIN OF yztitpc2 OCCURS 0.
        INCLUDE STRUCTURE vztitpc2.
DATA : END   OF yztitpc2.

DATA : BEGIN OF xztitpc3 OCCURS 0.
        INCLUDE STRUCTURE vztitpc3.
DATA : END   OF xztitpc3.

DATA : BEGIN OF yztitpc3 OCCURS 0.
        INCLUDE STRUCTURE vztitpc3.
DATA : END   OF yztitpc3.

DATA : BEGIN OF xztitrqp OCCURS 0.
        INCLUDE STRUCTURE vztitrqp.
DATA : END   OF xztitrqp.

DATA : BEGIN OF yztitrqp OCCURS 0.
        INCLUDE STRUCTURE vztitrqp.
DATA : END   OF yztitrqp.

DATA : BEGIN OF xztittt2 OCCURS 0.
        INCLUDE STRUCTURE vztittt2.
DATA : END   OF xztittt2.

DATA : BEGIN OF yztittt2 OCCURS 0.
        INCLUDE STRUCTURE vztittt2.
DATA : END   OF yztittt2.

DATA : BEGIN OF xztittt3 OCCURS 0.
        INCLUDE STRUCTURE vztittt3.
DATA : END   OF xztittt3.

DATA : BEGIN OF yztittt3 OCCURS 0.
        INCLUDE STRUCTURE vztittt3.
DATA : END   OF yztittt3.

DATA : BEGIN OF xztittt4 OCCURS 0.
        INCLUDE STRUCTURE vztittt4.
DATA : END   OF xztittt4.

DATA : BEGIN OF yztittt4 OCCURS 0.
        INCLUDE STRUCTURE vztittt4.
DATA : END   OF yztittt4.

DATA : BEGIN OF xztitivp OCCURS 0.
        INCLUDE STRUCTURE ztitivp.
DATA : END   OF xztitivp.

*-------> 출금통지서.
DATA : BEGIN OF xztitdas OCCURS 0.
        INCLUDE STRUCTURE ztitdas.
DATA : END   OF xztitdas.

DATA : BEGIN OF xztitdad OCCURS 0.
        INCLUDE STRUCTURE ztitdad.
DATA : END   OF xztitdad.

DATA : BEGIN OF xztitdac OCCURS 0.
        INCLUDE STRUCTURE ztitdac.
DATA : END   OF xztitdac.



*> 변경이력 관리를 위해.
DATA : old_ztitrqs   LIKE ztitrqs,
       old_ztitpc1   LIKE ztitpc1,
       new_ekko       LIKE ekko,
       g_amdsq        TYPE ztiamdsq.

DATA : g_opamtx(50)   TYPE c,
       g_exdatx(50)   TYPE c,
       g_lsdatx(50)   TYPE c,
       g_partyx(50)   TYPE c,
       g_tranyx(50)   TYPE c,
       g_fportx(50)   TYPE c,
       g_tportx(50)   TYPE c,
       g_inco1x(50)   TYPE c,
       g_ztermx(50)   TYPE c,
       g_fwdtyx(50)   TYPE c.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
  c_due_list            LIKE sy-tcode       VALUE 'ZTIR000', ">생성.
  c_due_list_pu         LIKE sy-tcode       VALUE ' ',       ">생성.
  c_due_list_tt         LIKE sy-tcode       VALUE 'ZTIR001', ">생성.
  c_due_list_rt         LIKE sy-tcode       VALUE 'ZTIR002', ">생성.
  c_create_d            LIKE sy-tcode       VALUE 'ZTIT000', ">생성.
  c_create              LIKE sy-tcode       VALUE 'ZTIT001', ">생성.
  c_create_a            LIKE sy-tcode       VALUE 'ZTIT051', ">Amend.
  c_change              LIKE sy-tcode       VALUE 'ZTIT002', ">변경.
  c_display             LIKE sy-tcode       VALUE 'ZTIT003', ">조회.
  c_delete              LIKE sy-tcode       VALUE 'ZTIT004', ">삭제.
  c_acceptance          LIKE sy-tcode       VALUE 'ZTIT005', ">접수.
  c_apply               LIKE sy-tcode       VALUE 'ZTIT006', ">개설신청.
  c_open                LIKE sy-tcode       VALUE 'ZTIT007', ">개설.
  c_post                LIKE sy-tcode       VALUE ' ',       ">전기.
  c_send                LIKE sy-tcode       VALUE 'ZTIT009', ">Send.
  c_reverse             LIKE sy-tcode       VALUE ' ',       ">취소.
  c_reverse1            LIKE sy-tcode       VALUE ' ',       ">취소.
  c_close               LIKE sy-tcode       VALUE 'ZTIT008', ">종료.
  c_damages             LIKE sy-tcode       VALUE ' ',        ">
  c_textobject_header   LIKE ttxob-tdobject VALUE 'ZTIRQHD',
  c_textobject_edi      LIKE ttxob-tdobject VALUE 'ZTIEDI',
  c_action              TYPE es_element     VALUE 'ZTIRQ'.



*> 기타 텍스트용.
DATA: BEGIN OF it_lctext OCCURS 0.
        INCLUDE STRUCTURE ztislc02.
DATA: END OF it_lctext.

*> WBS 요소.
DATA: BEGIN OF it_pspnr  OCCURS 2,
      pspnr   TYPE  ps_psp_pnr.
DATA: END   OF it_pspnr.

DATA: BEGIN OF it_lsdat  OCCURS 2,
      lsdat   TYPE  ztilsdat.
DATA: END   OF it_lsdat.

*> 위탁자재 .
DATA : BEGIN OF it_rkwa OCCURS 0.
        INCLUDE STRUCTURE rkwa.
DATA :  txz01       LIKE ztisrqit-txz01,
        rqmng       LIKE ztitrqp-rqmng,
        rqmngs      LIKE ztisrqit-rqmngs,
        rqmngl      LIKE ztisrqit-rqmngl,
        ps_psp_pnr  LIKE mseg-ps_psp_pnr,
        nplnr       TYPE nplnr,
        aufnr       TYPE aufnr,
        box         TYPE c,
        index(10)   TYPE n.
DATA : END   OF it_rkwa.

*> 사후송금 .
DATA : BEGIN OF it_ztisblit OCCURS 0.
        INCLUDE STRUCTURE ztisblit.
DATA :  box        TYPE c,
        index(10)  TYPE n.
DATA : END   OF it_ztisblit.


DATA : g_odycd     LIKE ztitlc1-odycd,
       g_mate5     LIKE ztitlc1-mate5,
       g_textobj   LIKE ttxob-tdobject.

DATA: g_ukurs   TYPE tcurr-ukurs,
      g_dispaly TYPE xfeld.


*-----------------------------------------------------------------------
*> 아이템 테이블용.
*-----------------------------------------------------------------------
CONTROLS: tc_2130   TYPE TABLEVIEW USING SCREEN 2130.
*> TYPE FOR THE DATA OF TABLECONTROL 'tc_2130'
TYPES: BEGIN OF t_tc_2130.
        INCLUDE STRUCTURE ztisrqit.
TYPES: END OF t_tc_2130.
*> INTERNAL TABLE FOR TABLECONTROL 'tc_2130'
DATA:     it_tab           TYPE t_tc_2130 OCCURS 0,
          it_tab_o         TYPE t_tc_2130 OCCURS 0,
          g_tc_2130_wa     TYPE t_tc_2130,           ">work area
          g_tc_2130_old    TYPE t_tc_2130,           ">work area
          g_tab_old        TYPE t_tc_2130,
          g_tc_2130_copied.                          ">copy flag
*> LINES OF TABLECONTROL 'tc_2130'
DATA:     g_tc_2130_lines  LIKE sy-loopc.

*-----------------------------------------------------------------------
*> 전신환 송금 테이블용.
*-----------------------------------------------------------------------
*> type for the data of tablecontrol 'TC_2240'
TYPES: BEGIN OF t_tc_2240,
         tbqit LIKE ztittt2-tbqit,
         tbdcd LIKE ztittt2-tbdcd,
         tbdno LIKE ztittt2-tbdno,
         tbidt LIKE ztittt2-tbidt,
         tbano LIKE ztittt2-tbano,
         flag,       "flag for mark column
       END OF t_tc_2240.
*> internal table for tablecontrol 'TC_2240'
DATA:     g_tc_2240_itab   TYPE t_tc_2240 OCCURS 0,
          g_tc_2240_wa     TYPE t_tc_2240. "work area
DATA:     g_tc_2240_copied.           "copy flag
*> declaration of tablecontrol 'TC_2240' itself
CONTROLS: tc_2240 TYPE TABLEVIEW USING SCREEN 2240.
*> lines of tablecontrol 'TC_2240'
DATA:     g_tc_2240_lines  LIKE sy-loopc.
DATA :    g_txt50(50)   TYPE c.

*-----------------------------------------------------------------------
*> 구매확인서 테이블용. --> 근거서류.
*-----------------------------------------------------------------------
*> type for the data of tablecontrol 'TC_2220_1'
TYPES: BEGIN OF t_tc_2220_1,
         pbqit  LIKE ztitpc2-pbqit,
         pbdty  LIKE ztitpc2-pbdty,
         pbdno  LIKE ztitpc2-pbdno,
         pbdsn  LIKE ztitpc2-pbdsn,
         pbded  LIKE ztitpc2-pbded,
         pbdhs  LIKE ztitpc2-pbdhs,
         pbdat  LIKE ztitpc2-pbdat,
         pbdatc LIKE ztitpc2-pbdatc,
         pbdsd  LIKE ztitpc2-pbdsd,
         pbds1  LIKE ztitpc2-pbds1,
         pbds2  LIKE ztitpc2-pbds2,
         pbds3  LIKE ztitpc2-pbds3,
         pbds4  LIKE ztitpc2-pbds4,
         flag,       "flag for mark column
       END OF t_tc_2220_1.
*> internal table for tablecontrol 'TC_2220_1'
DATA:     g_tc_2220_1_itab   TYPE t_tc_2220_1 OCCURS 0,
          g_tc_2220_1_wa     TYPE t_tc_2220_1. "work area
DATA:     g_tc_2220_1_copied.           "copy flag
*> declaration of tablecontrol 'TC_2220_1' itself
CONTROLS: tc_2220_1 TYPE TABLEVIEW USING SCREEN 2220.
*> lines of tablecontrol 'TC_2220_1'
DATA:     g_tc_2220_1_lines  LIKE sy-loopc.

*-----------------------------------------------------------------------
*> 구매확인서 테이블용. --> 품목별.
*-----------------------------------------------------------------------
*> type for the data of tablecontrol 'TC_2220_2'
TYPES: BEGIN OF t_tc_2220_2,
         pcqit  LIKE ztitpc3-pcqit,
         pchsc  LIKE ztitpc3-pchsc,
         pcsnm  LIKE ztitpc3-pcsnm,
         pcsz1  LIKE ztitpc3-pcsz1,
         pcsz2  LIKE ztitpc3-pcsz2,
         pcsz3  LIKE ztitpc3-pcsz3,
         pcsz4  LIKE ztitpc3-pcsz4,
         pcsz5  LIKE ztitpc3-pcsz5,
         pcsa1  LIKE ztitpc3-pcsa1,
         pcsa2  LIKE ztitpc3-pcsa2,
         pcsa3  LIKE ztitpc3-pcsa3,
         pcsa4  LIKE ztitpc3-pcsa4,
         pcsa5  LIKE ztitpc3-pcsa5,
         pcnum  LIKE ztitpc3-pcnum,
         pcnumu LIKE ztitpc3-pcnumu,
         pcpam  LIKE ztitpc3-pcpam,
         pcppb  LIKE ztitpc3-pcppb,
         pcppu  LIKE ztitpc3-pcppu,
         pcpaf  LIKE ztitpc3-pcpaf,
         pcamt  LIKE ztitpc3-pcamt,
         pcamtc LIKE ztitpc3-pcamtc,
         pcamtu LIKE ztitpc3-pcamtu,
         pcamf  LIKE ztitpc3-pcamf,
         pcspd  LIKE ztitpc3-pcspd,
         dsdct  LIKE ztitpc3-dsdct,
         pcdam  LIKE ztitpc3-pcdam,
         pcdamc LIKE ztitpc3-pcdamc,
         pcdaf  LIKE ztitpc3-pcdaf,
         flag,       "flag for mark column
       END OF t_tc_2220_2.

*> internal table for tablecontrol 'TC_2220_2'
DATA:     g_tc_2220_2_itab   TYPE t_tc_2220_2 OCCURS 0,
          g_tc_2220_2_wa     TYPE t_tc_2220_2. "work area
DATA:     g_tc_2220_2_copied.           "copy flag

*> declaration of tablecontrol 'TC_2220_2' itself
CONTROLS: tc_2220_2 TYPE TABLEVIEW USING SCREEN 2220.

*> lines of tablecontrol 'TC_2220_2'
DATA:     g_tc_2220_2_lines  LIKE sy-loopc.

*-----------------------------------------------------------------------
*> 수입신용장 상품명세 테이블 컨트롤용.
*-----------------------------------------------------------------------
*> type for the data of tablecontrol 'TC_2211'
TYPES: BEGIN OF t_tc_2211,
         qitno LIKE ztitlc2-qitno,
         ltext LIKE ztitlc2-ltext,
         flag,       "flag for mark column
       END OF t_tc_2211.

*> internal table for tablecontrol 'TC_2211'
DATA:     g_tc_2211_itab   TYPE t_tc_2211 OCCURS 0,
          g_tc_2211_wa     TYPE t_tc_2211. "work area
DATA:     g_tc_2211_copied.           "copy flag

*> declaration of tablecontrol 'TC_2211' itself
CONTROLS: tc_2211 TYPE TABLEVIEW USING SCREEN 2211.

*> lines of tablecontrol 'TC_2211'
DATA:     g_tc_2211_lines  LIKE sy-loopc.

*-----------------------------------------------------------------------
*> 수입신용장 기타텍스트 컨트롤용.
*-----------------------------------------------------------------------
*> type for the data of tablecontrol 'TC_2212'
TYPES: BEGIN OF t_tc_2212,
         qitno LIKE ztitlc2-qitno,
         ltext LIKE ztitlc2-ltext,
         flag,       "flag for mark column
       END OF t_tc_2212.

*> internal table for tablecontrol 'TC_2212'
DATA:     g_tc_2212_itab   TYPE t_tc_2212 OCCURS 0,
          g_tc_2212_wa     TYPE t_tc_2212. "work area
DATA:     g_tc_2212_copied.           "copy flag

*> declaration of tablecontrol 'TC_2212' itself
CONTROLS: tc_2212 TYPE TABLEVIEW USING SCREEN 2212.

*> lines of tablecontrol 'TC_2212'
DATA:     g_tc_2212_lines  LIKE sy-loopc.

*-----------------------------------------------------------------------
*> 수입신용장 기타텍스트 테이블 컨트롤용.
*-----------------------------------------------------------------------
*> type for the data of tablecontrol 'TC_2213'
TYPES: BEGIN OF t_tc_2213,
         qitno LIKE ztitlc2-qitno,
         ltext LIKE ztitlc2-ltext,
         flag,       "flag for mark column
       END OF t_tc_2213.

*> internal table for tablecontrol 'TC_2213'
DATA:     g_tc_2213_itab   TYPE t_tc_2213 OCCURS 0,
          g_tc_2213_wa     TYPE t_tc_2213. "work area
DATA:     g_tc_2213_copied.           "copy flag

*> declaration of tablecontrol 'TC_2212' itself
CONTROLS: tc_2213 TYPE TABLEVIEW USING SCREEN 2213.

*> lines of tablecontrol 'TC_2213'
DATA:     g_tc_2213_lines  LIKE sy-loopc.

*-----------------------------------------------------------------------
*> 수입승인 테이블 컨트롤용.
*-----------------------------------------------------------------------
*> type for the data of tablecontrol 'TC_2214'
TYPES: BEGIN OF t_tc_2214,
         imasq  LIKE ztitlc3-imasq,
         imacd  LIKE ztitlc3-imacd,
         imano  LIKE ztitlc3-imano,
         imamtc LIKE ztitlc3-imamtc,
         imamt  LIKE ztitlc3-imamt,
         flag,       "flag for mark column
       END OF t_tc_2214.

*> internal table for tablecontrol 'TC_2214'
DATA:     g_tc_2214_itab   TYPE t_tc_2214 OCCURS 0,
          g_tc_2214_wa     TYPE t_tc_2214. "work area
DATA:     g_tc_2214_copied.           "copy flag

*> declaration of tablecontrol 'TC_2214' itself
CONTROLS: tc_2214 TYPE TABLEVIEW USING SCREEN 2214.

*> lines of tablecontrol 'TC_2214'
DATA:     g_tc_2214_lines  LIKE sy-loopc.

*-----------------------------------------------------------------------
*> 수입신용장 Long Text 테이블 컨트롤용.
*-----------------------------------------------------------------------
*> type for the data of tablecontrol 'TC_2216'
TYPES: BEGIN OF t_tc_2216,
         qitno LIKE ztitlc2-qitno,
         ltext LIKE ztitlc2-ltext,
         flag,       "flag for mark column
       END OF t_tc_2216.

*> internal table for tablecontrol 'TC_2216'
DATA:     g_tc_2216_itab   TYPE t_tc_2216 OCCURS 0,
          g_tc_2216_wa     TYPE t_tc_2216. "work area
DATA:     g_tc_2216_copied.           "copy flag

*> declaration of tablecontrol 'TC_2216' itself
CONTROLS: tc_2216 TYPE TABLEVIEW USING SCREEN 2216.

*> lines of tablecontrol 'TC_2216'
DATA:     g_tc_2216_lines  LIKE sy-loopc.

*S__ 신용장 변경에 따른 수정 20181010 BY SDW
*1 .기타조건변경사항 - 상품(용역)명세 변경사항
DATA:     g_tc_2216_itab_1_1   TYPE t_tc_2216 OCCURS 0,
          g_tc_2216_wa_1_1     TYPE t_tc_2216. "work area

DATA:     g_tc_2216_itab_1_2   TYPE t_tc_2216 OCCURS 0,
          g_tc_2216_wa_1_2     TYPE t_tc_2216. "work area

DATA:     g_tc_2216_itab_1_3   TYPE t_tc_2216 OCCURS 0,
          g_tc_2216_wa_1_3     TYPE t_tc_2216. "work area

*2 .기타조건변경사항 - 주요구비서류
DATA:     g_tc_2216_itab_2_1   TYPE t_tc_2216 OCCURS 0,
          g_tc_2216_wa_2_1     TYPE t_tc_2216. "work area

DATA:     g_tc_2216_itab_2_2   TYPE t_tc_2216 OCCURS 0,
          g_tc_2216_wa_2_2     TYPE t_tc_2216. "work area

DATA:     g_tc_2216_itab_2_3   TYPE t_tc_2216 OCCURS 0,
          g_tc_2216_wa_2_3     TYPE t_tc_2216. "work area

*3 .기타조건변경사항 - 부가조건
DATA:     g_tc_2216_itab_3_1   TYPE t_tc_2216 OCCURS 0,
          g_tc_2216_wa_3_1     TYPE t_tc_2216. "work area

DATA:     g_tc_2216_itab_3_2   TYPE t_tc_2216 OCCURS 0,
          g_tc_2216_wa_3_2     TYPE t_tc_2216. "work area

DATA:     g_tc_2216_itab_3_3   TYPE t_tc_2216 OCCURS 0,
          g_tc_2216_wa_3_3     TYPE t_tc_2216. "work area

*4 .기타조건변경사항 - 특별지급조건
DATA:     g_tc_2216_itab_4_1   TYPE t_tc_2216 OCCURS 0,
          g_tc_2216_wa_4_1     TYPE t_tc_2216. "work area

DATA:     g_tc_2216_itab_4_2   TYPE t_tc_2216 OCCURS 0,
          g_tc_2216_wa_4_2     TYPE t_tc_2216. "work area

DATA:     g_tc_2216_itab_4_3   TYPE t_tc_2216 OCCURS 0,
          g_tc_2216_wa_4_3     TYPE t_tc_2216. "work area
*E__ 신용장 변경에 따른 수정 20181010 BY SDW


*-----------------------------------------------------------------------
*> 포워더 관리 테이블 컨트롤용.
*-----------------------------------------------------------------------
*  data declaration for tablecontrol 'TC_2123' definition of ddic-table
TABLES:   ztitlc4.

* type for the data of tablecontrol 'TC_2123'
TYPES: BEGIN OF t_tc_2123.
        INCLUDE STRUCTURE ztislc04.
TYPES: END OF t_tc_2123.

* internal table for tablecontrol 'TC_2123'
DATA:     g_tc_2123_itab   TYPE t_tc_2123 OCCURS 0,
          g_tc_2123_wa     TYPE t_tc_2123. "work area
DATA:     g_tc_2123_copied.           "copy flag

* declaration of tablecontrol 'TC_2123' itself
CONTROLS: tc_2123 TYPE TABLEVIEW USING SCREEN 2123.

* lines of tablecontrol 'TC_2123'
DATA:     g_tc_2123_lines  LIKE sy-loopc.

*> 선적국가별 포워더.
DATA: BEGIN OF it_ztitig10 OCCURS 10.
        INCLUDE STRUCTURE ztivig10.
DATA: END   OF it_ztitig10.


*-----------------------------------------------------------------------
*> 지급확인서용 테이블 컨트롤용.
*-----------------------------------------------------------------------
*> data declaration for tablecontrol 'TC_2124'
*> definition of ddic-table
TABLES:   ztittt4,
         *ztittt4,
          ztistt4.

*> type for the data of tablecontrol 'TC_2124'
TYPES: BEGIN OF t_tc_2124.
        INCLUDE STRUCTURE ztistt4.
TYPES: END   OF t_tc_2124.

*> internal table for tablecontrol 'TC_2124'
DATA:     g_tc_2124_itab   TYPE t_tc_2124 OCCURS 0,
          g_tc_2124_wa     TYPE t_tc_2124. "work area
DATA:     g_tc_2124_copied.           "copy flag

*> declaration of tablecontrol 'TC_2124' itself
CONTROLS: tc_2124 TYPE TABLEVIEW USING SCREEN 2124.

*> lines of tablecontrol 'TC_2124'
DATA:     g_tc_2124_lines  LIKE sy-loopc.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF ty_header,
            box(1)      TYPE c,
            ebeln       TYPE ebeln,
            bukrs       LIKE ekko-bukrs,
            ekorg       LIKE ekko-ekorg,
            ekgrp       LIKE ekko-ekgrp,
            bstyp       LIKE ekko-bstyp,
            zterm       LIKE ekko-zterm,
            frgke     LIKE ekko-frgke, ">가온 승인절차 추가
            frgrl       LIKE ekko-frgrl,
            bsart       LIKE ekko-bsart,
            hloekz      LIKE ekko-loekz,      ">헤더 삭제지시자.
            waers       LIKE ekko-waers,
            hnetwr      LIKE ztisrqit-netwr,  ">총금액.
            reqty       TYPE ztireqty,
            reqtx(12)   TYPE c,
            land1       LIKE lfa1-land1,
            lifnr       TYPE lifnr,
            name1       TYPE name1,
            hstat(10)   TYPE c.
TYPES: END OF ty_header.

TYPES: BEGIN OF ty_item.
INCLUDE     TYPE        ty_header.
TYPES :     ebelp       TYPE ebelp,
            menge       LIKE ekpo-menge,
            meins       LIKE ekpo-meins,
            eindt       LIKE eket-eindt,
            lsdat       LIKE ztitrqs-lsdat,
            pspnr       LIKE ekkn-ps_psp_pnr,
            nplnr       LIKE ekkn-nplnr,
            pspid       LIKE proj-pspid,
            rqmng       LIKE ztitrqp-rqmng,
            rqmngs      LIKE ztisrqit-rqmngs,
            rqmngl      LIKE ztisrqit-rqmngl,
            werks       LIKE ztisrqit-werks,
            name2       LIKE ztisrqit-name1,
            matnr       LIKE ztisrqit-matnr,
            txz01       LIKE ztisrqit-txz01,
            eeind       LIKE ztisrqit-eeind,
            bpumz       LIKE ztisrqit-bpumz,
            bpumn       LIKE ztisrqit-bpumn,
            netpr       LIKE ztisrqit-netpr,
            peinh       LIKE ztisrqit-peinh,
            netwr       LIKE ztisrqit-netwr,
            netwrs      LIKE ztisrqit-netwr,
            istat(10)   TYPE c.
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

** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: a_bukrs LIKE t001-bukrs,
      l_yn    type c.
** JS전선 회사코드 2007/04 KSH --------------------------------------


*S__ 신용장 변경에 따른 수정 20181010 BY SDW
************************************************************************
* 기타텍스트 CHECK를 위한 변수                                         *
************************************************************************
  DATA : GV_CHK_TEXT_B,
         GV_CHK_TEXT_C,
         GV_CHK_TEXT_D,
         GV_CHK_TEXT_E,
         GV_CHK_TEXT_F,
         GV_CHK_TEXT_G,
         GV_CHK_TEXT_H,
         GV_CHK_TEXT_I,
         GV_CHK_TEXT_J,
         GV_CHK_TEXT_K,
         GV_CHK_TEXT_L,
         GV_CHK_TEXT_M.
*E__ 신용장 변경에 따른 수정 20181010 BY SDW
