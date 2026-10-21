************************************************************************
* Title         : ZTII_COMMON_PART_T02                                 *
*                                                                      *
* Description   : Text Object를 위한 공용 Top Include                  *
*                                                                      *
* Creation Date : 2004/02/11                                           *
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
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: cntl.   "> Type Controls

************************************************************************
* SAP Include Define                                                   *
************************************************************************

************************************************************************
* Tables                                                               *
************************************************************************
TABLES: thead,      ">유효 텍스트 오브젝트.
        ttxob,      ">유효 텍스트 오브젝트.
        ttxid,      ">유효 텍스트 ID.
        ttxit.      ">텍스트 ID의 텍스트.

************************************************************************
* SAP Views                                                            *
************************************************************************

************************************************************************
* Constants                                                            *
************************************************************************
*> 상수들 정의.
CONSTANTS: c_column1(1)        TYPE c               VALUE '1',
           c_column2(1)        TYPE c               VALUE '2',
           c_header(1)         TYPE c               VALUE 'H',
           c_textedit          LIKE mepotext-editor VALUE '1',
           c_inline            LIKE mepotext-editor VALUE '2',
           c_sapscript         LIKE mepotext-editor VALUE '3',
           c_common_prog       LIKE sy-repid
                               VALUE 'SAPLZ_MI_COMMON_FUNCTIONS',
           c_text_prog         LIKE sy-repid
                               VALUE 'SAPLZ_MI_WORD_PROCESSING'.
*> Text Editor를 위한 구조.
DATA: BEGIN OF gt_control OCCURS 0,
        object         LIKE ttxob-tdobject,
        tree_handle    TYPE cntl_handle,
        current_node   LIKE treev_node-node_key,
        previous_node  LIKE treev_node-node_key,
        editor_type    LIKE mepotext-editor,
        editor_handle  TYPE REF TO cl_gui_textedit,
*        event_receiver TYPE REF TO lcl_event_receiver,
        items          TYPE STANDARD TABLE OF mtreeitm
                            INITIAL SIZE 0,
        texttypes      TYPE mmpur_texttypes OCCURS 0,
        textlines      TYPE mmpur_textlines OCCURS 0,
        textlines_ch   TYPE mmpur_textlines OCCURS 0,
        dynnr          TYPE sydynnr,
        doubleclick    TYPE xfeld,
        ignore_okcode  TYPE xfeld,
      END OF gt_control.

*> Text Editor를 위한 변수.
DATA: g_textobject        LIKE ttxob-tdobject,
      g_textid            LIKE ttxid-tdid,
      g_doctype           LIKE ekko-bstyp,
      g_textname          LIKE thead-tdname,
      g_okcode            LIKE sy-ucomm,
      g_editor_screen     LIKE sy-dynnr,
      gs_proj             LIKE proj,
      gs_vsproj_cn        LIKE vsproj_cn,
      g_item_no           LIKE ekpo-ebelp,
      g_previous_node     LIKE treev_node-node_key.

*> Text data를 저장하는 Internal table.
DATA: BEGIN OF it_line OCCURS 0.
        INCLUDE STRUCTURE tline.
DATA: END   OF it_line.

*> Text ID를 저장하는 Internal table.
DATA: BEGIN OF xttxid OCCURS 0.
        INCLUDE STRUCTURE ttxid.
DATA: END   OF xttxid.

*> 구매오더: 텍스트편집기 사용.
DATA: g_editor LIKE mepotext-editor.

*> 전체 ID를 저장하기 위한 구조.
DATA: gt_inline_header LIKE mepotext OCCURS 0 WITH HEADER LINE.

DATA : g_texttypes LIKE mmpur_texttypes OCCURS 0 WITH HEADER LINE,
       g_textlines LIKE mmpur_textlines OCCURS 0 WITH HEADER LINE.

DATA: it_texttypes   TYPE mmpur_t_texttypes,
      it_textlines   TYPE mmpur_t_textlines,
      it_all_lines   TYPE mmpur_t_textlines.
