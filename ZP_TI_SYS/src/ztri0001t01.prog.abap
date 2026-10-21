************************************************************************
* Title         :  ZTER6910T01                                         *
*                                                                      *
* Description   : T/T 미정리 리스트 관리용 Top Include                 *
*                                                                      *
* Creation Date : 2003/03/12                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis,   "> Globale Type(ALV)
            cntl.   "> Type Controls

************************************************************************
* SAP Include Define                                                   *
************************************************************************
INCLUDE : <icon>,   ">ASCII 코드로 리스트에 대한 아이콘 글꼴문자.
          <symbol>. ">ASCII 코드로 리스트에 대한 상징글꼴문자 할당.

************************************************************************
* SAP Tables                                                           *
************************************************************************
*> Structure.
TABLES: ztesusk,
        *ztesusk,
        ztisig04,
       *ztisig04,
        ztitig04,
       *ztitig04,       ">
        t001,          ">
        ztstig3,       ">
        kuwev,         ">고객마스터 레코드의 인도처뷰.
        dfies.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
  c_action              TYPE es_element     VALUE 'ZTIUS',

  c_create              LIKE sy-tcode       VALUE space,     ">계좌관리.
  c_create_a            LIKE sy-tcode       VALUE space,     ">Amend.
  c_create_d            LIKE sy-tcode       VALUE space,     ">Multy.
  c_change              LIKE sy-tcode       VALUE space,     ">변경.
  c_display             LIKE sy-tcode       VALUE space,     ">조회.
  c_delete              LIKE sy-tcode       VALUE space,     ">삭제.
  c_acceptance          LIKE sy-tcode       VALUE space,     ">정리.
  c_apply               LIKE sy-tcode       VALUE space,     ">개설신청.
  c_send                LIKE sy-tcode       VALUE space,     ">Send.
  c_open                LIKE sy-tcode       VALUE space,     ">개설.
  c_post                LIKE sy-tcode       VALUE space,     ">전기.
  c_reverse             LIKE sy-tcode       VALUE space,     ">취소.
  c_reverse1            LIKE sy-tcode       VALUE space,     ">취소.
  c_close               LIKE sy-tcode       VALUE space,     ">종료.
  c_damages             LIKE sy-tcode       VALUE space.

************************************************************************
* Internal Tables                                                      *
************************************************************************
*-----------------------------------------------------------------------
*> 아이템 테이블용.
*-----------------------------------------------------------------------
TYPES: BEGIN OF t_tc_2000.
        INCLUDE STRUCTURE ztisig04.
TYPES : celltab TYPE lvc_t_styl.            " Cell단위 수정 스타일.
TYPES: END OF t_tc_2000.

TYPES:  BEGIN OF ty_upload,
        seqno(03),            "일련번호.
        sdpsa(18),            "별단예금 계좌번호.
        epart(10),            "은행코드.
        melda(10),            "통지일자.
        waers(05),            "통화.
        uebtr(20),            "입금액.
        tocnm(35),            "지급인.
        sdidt(10),            "별단계좌입금일.
        bankn(10),            "당좌계좌.
        END   OF ty_upload.

DATA:  gs_upload   TYPE ty_upload.

DATA: gt_upload_list  LIKE gs_upload OCCURS 0 WITH HEADER LINE,
      gt_upload_title LIKE gs_upload OCCURS 0 WITH HEADER LINE,
      gs_upload_list  LIKE gs_upload.

*> INTERNAL TABLE FOR TABLECONTROL 'tc_2000'
DATA:it_tab        TYPE STANDARD TABLE OF t_tc_2000 WITH HEADER LINE,
     it_header     LIKE ztisig04 OCCURS 0 WITH HEADER LINE,
     it_list       LIKE ztisig04 OCCURS 0 WITH HEADER LINE,
     gs_list       LIKE ztisig04,
     g_tc_2000_wa  TYPE t_tc_2000,           ">work area
     g_tc_2000_old TYPE t_tc_2000,           ">work area
     g_tab_old     TYPE t_tc_2000,
     g_tc_2000_copied.                          ">copy flag
*> LINES OF TABLECONTROL 'tc_2000'
DATA:     g_tc_2000_lines  LIKE sy-loopc.

DATA:    BEGIN OF excl OCCURS 25,
           funktion(10),
         END OF excl.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************


************************************************************************
* DATA                                                                 *
************************************************************************
DATA: g_answer           TYPE c,
      g_mode             TYPE c,
      g_fieldgroup(12)   TYPE c,
      g_bukrs            TYPE bukrs,
      ok_code            LIKE sy-ucomm,
      ok-code            LIKE sy-ucomm,
      g_lifnrnm          LIKE lfa1-name1,
      g_landx            LIKE t005T-landx50,
      g_landy            LIKE t005T-landx50.

DATA: g_custom_container TYPE REF TO cl_gui_custom_container,
      g_message_handler  TYPE REF TO cl_message_handler_mm,
      g_grid             TYPE REF TO cl_gui_alv_grid.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
DATA sender_chg TYPE REF TO cl_gui_alv_grid.

* Fieldcatalog Grid
DATA: it_fieldcat_g TYPE lvc_t_fcat,
      gs_fieldcat_g LIKE LINE OF it_fieldcat_g.
*icon
DATA: g_lights_name TYPE lvc_cifnm VALUE 'ICON'.
* Button exclude.
DATA : it_exclude   TYPE ui_functions.
* Layout GRID.
DATA: gs_layout_g   TYPE lvc_s_layo.
DATA: gs_stable     TYPE lvc_s_stbl.
* PRINT GRID.
DATA:  gs_print_g   TYPE lvc_s_prnt.
DATA : gs_sort_g    TYPE lvc_s_sort.
DATA : it_sort_g    TYPE lvc_t_sort.
DATA : gs_filter_g  TYPE lvc_s_filt.
DATA : it_filter_g  TYPE lvc_t_filt.

DATA: it_filter           TYPE slis_t_filter_alv.

FIELD-SYMBOLS: <gt_table> TYPE INDEX TABLE .

************************************************************************
* Message 처리를 위한 Macro                                            *
************************************************************************
DATA: g_dummy(72).

DEFINE zte_message.
  g_tabix = sy-tabix.
  g_subrc = sy-subrc.

  message id &2 type &1 number &3 with &4 &5 &6 &7 into g_dummy.

  call method cl_message_mm=>create
    exporting
      im_msgid         = &2
      im_msgty         = &1
      im_msgno         = &3
      im_msgv1         = sy-msgv1
      im_msgv2         = sy-msgv2
      im_msgv3         = sy-msgv3
      im_msgv4         = sy-msgv4
      im_force_collect = c_true
    exceptions
      failure          = 01
      dialog           = 02.
  if sy-subrc = 1 or sy-subrc = 2.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  endif.
  sy-subrc = g_subrc.
  sy-tabix = g_tabix.

END-OF-DEFINITION.
