************************************************************************
* Title         :  ZTIR9000T01                                         *
*                                                                      *
* Description   : 수입 제비용 관리 Top Include                         *
*                                                                      *
* Creation Date : 2003/08/22                                           *
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
* TYPES and TYPE-POOLS                                                 *
************************************************************************
*TYPE-POOLS:

************************************************************************
* SAP Include Define                                                   *
************************************************************************

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: ztitcck,
       *ztitivk,    ">I/V Header
        ztitblp,    ">B/L Header
        ztittxk,    ">기납증 Header.
        ztitcso,    ">[Import] 수입비용문서 (일회용계정데이타)
       *ztitcso,
        ztitrqk,    ">수입의뢰 Header
        ztitrqs,    ">수입의뢰 Status
        ztitcsk,    ">수입비용문서 Header table
       *ztitcsk,    ">수입비용문서 Header table
        ztitcsp,    ">수입비용문서 비용항목 table
        ztitcsd,    ">수입비용문서 배부 table
        ztitcsh,    ">수입비용문서 History table
        ztitpnk.    "> Payment Notice Header Table

************************************************************************
* SAP Structure                                                        *
************************************************************************
TABLES: ztisrqit,    ">수입의뢰 Items
        ztisblit,    ">B/L Items
        ztisivit,    ">I/V Items
        ztispnit,    ">Notice Items
        ztiscsit.    ">비용항목 Items.

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES: ztivcs00,
        ztivrq04.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
  c_action              TYPE es_element     VALUE 'ZTICS',

  c_create_d            LIKE sy-tcode       VALUE 'ZTIT900', ">생성.
  c_create              LIKE sy-tcode       VALUE 'ZTIT901', ">생성.
  c_create_a            LIKE sy-tcode       VALUE '', ">Amend/ZTIT351.
  c_change              LIKE sy-tcode       VALUE 'ZTIT902', ">변경.
  c_display             LIKE sy-tcode       VALUE 'ZTIT903', ">조회.
  c_delete              LIKE sy-tcode       VALUE 'ZTIT904', ">삭제.
  c_acceptance          LIKE sy-tcode       VALUE '', ">접수/ZTIT305.
  c_apply               LIKE sy-tcode       VALUE '', ">신청/ZTIT306.
  c_send                LIKE sy-tcode       VALUE space,     ">None
  c_open                LIKE sy-tcode       VALUE '', ">개설/ZTIT307.
  c_post                LIKE sy-tcode       VALUE '', ">전기.
  c_reverse             LIKE sy-tcode       VALUE 'ZTIT905', ">취소.
  c_reverse1            LIKE sy-tcode       VALUE 'NONE',    ">None
  c_damages             LIKE sy-tcode       VALUE 'NONE',    ">구상.
  c_close               LIKE sy-tcode       VALUE 'NONE',    ">종료.
  c_textobject_header   LIKE ttxob-tdobject VALUE 'ZTICSHD'.

************************************************************************
* Internal Tables                                                      *
************************************************************************

*> CHANGE DOCUMENT용.
DATA : BEGIN OF xztitcsp OCCURS 0.
        INCLUDE STRUCTURE vztitcsp.
DATA : END   OF xztitcsp.

DATA : BEGIN OF yztitcsp OCCURS 0.
        INCLUDE STRUCTURE vztitcsp.
DATA : END   OF yztitcsp.

*> 비용코드 HELP
DATA : BEGIN OF it_ztitig06 OCCURS 0,
                expcd      LIKE ztitig06-expcd,
                exptx      LIKE ztitig06-exptx,
                mwskz      LIKE ztitig06-mwskz,
                kschl      LIKE ztitig06-kschl,
                cscty      LIKE ztitig06-cscty,
                saknr      LIKE ztitig06-saknr,
       END   OF it_ztitig06.

DATA : BEGIN OF it_bupla OCCURS 0,
       bupla    TYPE bupla,
       END   OF it_bupla.

DATA : BEGIN OF it_mwskz OCCURS 0,
       mwskz    TYPE mwskz,
       END   OF it_mwskz.

DATA : g_bukrs  TYPE bukrs,
       g_msatz  TYPE msatz.

******************** Fields for Communication with F4-Modules **********
DATA:    g_bvtyp    LIKE invfo-bvtyp,
         g_empfb    LIKE invfo-empfb,
         g_f4dyn    LIKE sy-dynnr,
         g_f4rcode  LIKE sy-subrc,
         g_filkd    LIKE invfo-filkd,
         g_kunnr    LIKE invfo-kunnr,
         g_lifnr    LIKE invfo-lifnr,
         g_rstgr    LIKE invfo-rstgr,
         g_sgtxt_f4 LIKE invfo-sgtxt,
         g_xshow.                      "Field is only display field

*-- internal table for fields to display: normal F4 --------------------
DATA: fldtab LIKE help_value OCCURS 2 WITH HEADER LINE.
DATA: f4hlp  LIKE dynpread   OCCURS 0 WITH HEADER LINE.


*-----------------------------------------------------------------------
*> 비용이력 조회용.
*-----------------------------------------------------------------------
DATA: g_variant           LIKE disvariant.
DATA: gx_variant          LIKE disvariant.
DATA: gs_stable           TYPE lvc_s_stbl.
DATA: gs_layout_alv       TYPE lvc_s_layo.

*DATA: g_variant_save.
DATA: p_variant           LIKE disvariant-variant.
DATA: it_fieldcat_lvc     TYPE lvc_t_fcat WITH HEADER LINE.
DATA: it_fieldcat_lvc_1   TYPE lvc_t_fcat WITH HEADER LINE.
DATA: it_dynpread         LIKE dynpread OCCURS 0 WITH HEADER LINE.
DATA  g_user_specific.
DATA: gt_sort_lvc         TYPE lvc_t_sort WITH HEADER LINE.
DATA: gt_filt_lvc         TYPE lvc_t_filt WITH HEADER LINE.

DATA: g_scr2123_grid      TYPE REF TO cl_gui_alv_grid,
      g_scr2123_container TYPE REF TO cl_gui_custom_container.

DATA: g_scr7000_grid      TYPE REF TO cl_gui_alv_grid,
      g_scr7000_container TYPE REF TO cl_gui_custom_container.

*> 이력조회용.
*DATA: it_ZTIscshs TYPE TABLE OF ZTIscshs.
DATA: BEGIN OF it_ztiscshs OCCURS 10.
        INCLUDE STRUCTURE ztiscshs.
DATA: END   OF it_ztiscshs.
*
*> 배부내역 조회용.
DATA: BEGIN OF it_ztiscsdt OCCURS 10.
        INCLUDE STRUCTURE ztiscsdt.
* 20051022 simcho 액티비티 번호 추가
DATA:   activity(4). "액티비티번호
*
data: END   OF it_ztiscsdt.

DATA: BEGIN OF it_ztiscsdty OCCURS 10.
        INCLUDE STRUCTURE ztiscsdt.
DATA: END   OF it_ztiscsdty.

*-----------------------------------------------------------------------
*> 비용항목 테이블용.
*-----------------------------------------------------------------------
CONTROLS: tc_2130   TYPE TABLEVIEW USING SCREEN 2130.

*> TYPE FOR THE DATA OF TABLECONTROL 'tc_2130'
TYPES: BEGIN OF t_tc_2130.
        INCLUDE STRUCTURE ztiscsit.
TYPES: END OF t_tc_2130.

*> INTERNAL TABLE FOR TABLECONTROL 'tc_2130'
DATA:     it_tab           TYPE t_tc_2130 OCCURS 0,
          it_taby          TYPE t_tc_2130 OCCURS 0,
          g_tc_2130_wa     TYPE t_tc_2130,           ">work area
          g_tc_2130_copied.                          ">copy flag

*> LINES OF TABLECONTROL 'tc_2130'
DATA:     g_tc_2130_lines  LIKE sy-loopc.

*> payment terms logic.
TABLES: faede.

DATA:   g_zlspr LIKE t052-zschf,
        g_zlsch LIKE t052-zlsch,
        g_zfbdt LIKE rbkp_v-zfbdt.

*> 수취인 HELP용.
DATA : dynprog  LIKE sy-repid,
       dynnr    LIKE sy-dynnr,
       g_window_title(60),
       g_display.

DATA : BEGIN OF xlfza OCCURS 0,
       lifnr   LIKE lfza-lifnr,
       bukrs   LIKE lfza-bukrs,
       empfk   LIKE lfza-empfk,
       name1   LIKE lfa1-name1.
DATA : END   OF xlfza.


DATA : g_text_exrate(255)    TYPE c,
       g_foreign_factor(255) TYPE c,
       g_factor              TYPE p,
       g_zterm               TYPE c,
       g_cstct_temp          TYPE zticstct,
       g_ztitcsk             LIKE ztitcsk,
       g_ztitcso             LIKE ztitcso,
       g_fixed_rate          LIKE tcurs-spred,
       g_local_amt           LIKE ekpo-netwr.  " UAmount
