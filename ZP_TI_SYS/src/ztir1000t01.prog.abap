************************************************************************
* Title         :  ZTIR1000T01                                         *
*                                                                      *
* Description   : 적하부보 관리 TOP Include                            *
*                                                                      *
* Creation Date : 2003/08/20                                           *
*                                                                      *
* Author        : Seung Jun, Lee                                       *
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
       *ztitip1,    ">적하 보험  MAIN (APPCIV/CIPADV)
        ztitip3,    ">적하 보험  MAIN (APPCIV/CIPADV)
       *ztitip3,    ">적하 보험  MAIN (APPCIV/CIPADV)
        ztitip4,    ">적하 보험  배서 (APPCIV/CIPADV)
        ztstig4,    ">..
        ztitig30,   ">
        ztisip02,   ">적하보험 부보조건.
       *ztitip4,    ">적하 보험  배서 (APPCIV/CIPADV)
       *ztitblk,    ">Bill of Lading Header table
        ztitblp,    ">Bill of Lading Items table
       *ztitblp,    ">Bill of Lading Items table
        ztitblc,    ">Bill of Lading Container table
       *ztitblc.    ">Bill of Lading Container table
*        ZTItlo01,    ">LOCAL  L/C MAIN (LOCAPP/LOCAMR)
*       *ZTItlo01,    ">LOCAL  L/C MAIN (LOCAPP/LOCAMR)
*        ZTItpc01,    ">구매확인서 MAIN (APPPCR/PCRLIC)
*       *ZTItpc01,    ">구매확인서 MAIN (APPPCR/PCRLIC)
*        ZTItpc02,    ">구매확인서 ITEM (근거서류)
*       *ZTItpc02,    ">구매확인서 ITEM (근거서류)
*        ZTItpc03,    ">구매확인서 ITEM (물품내역)
*       *ZTItpc03,    ">구매확인서 ITEM (물품내역)
*        ZTItlc01,    ">MASTER L/C MAIN (APP700/APP707)
*       *ZTItlc01,    ">MASTER L/C MAIN (APP700/APP707)
*        ZTItlc02,    ">MASTER L/C ITEM (Long text)
*       *ZTItlc02,    ">MASTER L/C ITEM (Long text)
*        ZTIttt01,    ">지급지시서 T/T MAIN (PAYORD)
*       *ZTIttt01,    ">지급지시서 T/T MAIN (PAYORD)
*        ZTIttt02,    ">지급지시서 T/T ITEM (입금관련서류)
*       *ZTIttt02.    ">지급지시서 T/T ITEM (입금관련서류)
*
************************************************************************
* SAP Structure                                                        *
************************************************************************
TABLES: ztisrqit,    ">수입의뢰 Items
        ztisblit.    ">B/L Items

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
  c_due_list_po         LIKE sy-tcode       VALUE 'ZTIR103', ">생성.
  c_create_d            LIKE sy-tcode       VALUE 'ZTIT100', ">생성.
  c_create              LIKE sy-tcode       VALUE 'ZTIT101', ">생성.
*{ 기능개선 283274 - 추가_S
  c_create_bl           LIKE sy-tcode       VALUE 'ZTIT101N',">생성-B/L
*} 기능개선 283274 - 추가_E
  c_create_a            LIKE sy-tcode       VALUE 'ZTIT151', ">amend.
  c_change              LIKE sy-tcode       VALUE space,    ">변경.
  c_display             LIKE sy-tcode       VALUE 'ZTIT103', ">조회.
  c_delete              LIKE sy-tcode       VALUE 'ZTIT104', ">삭제.
  c_acceptance          LIKE sy-tcode       VALUE space,    ">None
  c_apply               LIKE sy-tcode       VALUE 'ZTIT102', ">신청.
  c_send                LIKE sy-tcode       VALUE space,     ">None
  c_open                LIKE sy-tcode       VALUE 'ZTIT105', ">부보내역.
  c_post                LIKE sy-tcode       VALUE space,    ">None
  c_reverse             LIKE sy-tcode       VALUE space,    ">None
  c_reverse1            LIKE sy-tcode       VALUE space,    ">None
  c_damages             LIKE sy-tcode       VALUE 'ZTIT106', ">구상.
  c_close               LIKE sy-tcode       VALUE space,    ">Close
  c_textobject_header   LIKE ttxob-tdobject VALUE 'ZTIIPHD',
  c_action              TYPE es_element     VALUE 'ZTIIP'.

************************************************************************
* Internal Tables                                                      *
************************************************************************
*> CHANGE DOCUMENT용.
DATA : BEGIN OF xztitip2 OCCURS 0.
        INCLUDE STRUCTURE vztitip2.
DATA : END   OF xztitip2.

DATA : BEGIN OF yztitip2 OCCURS 0.
        INCLUDE STRUCTURE vztitip2.
DATA : END   OF yztitip2.

*-----------------------------------------------------------------------
*> 수입의뢰아이템 --> Tree용.
*-----------------------------------------------------------------------
*> TYPE FOR THE DATA OF '수입의뢰아이템'
TYPES: BEGIN OF t_ztisrqit.
        INCLUDE STRUCTURE ztisrqit.
TYPES: box        TYPE c,
       index(10)  TYPE n,
       blmng      TYPE ztiblmng,
       blmngs     TYPE ztiblmngs,
       blmngl     TYPE ztiblmngi,
       END OF t_ztisrqit.

*> INTERNAL TABLE FOR TABLECONTROL '수입의뢰아이템'
DATA:     it_ztisrqit         TYPE t_ztisrqit OCCURS 0 WITH HEADER LINE,
          g_ztisrqit_wa       TYPE t_ztisrqit.           ">work area

*{ 기능개선 283274 - 추가_S
DATA: it_ztitblp  LIKE ztisblit OCCURS 0 WITH HEADER LINE.
*} 기능개선 283274 - 추가_E

DATA : BEGIN OF it_reqno OCCURS 0,
       reqno      TYPE ztireqno.
DATA : END   OF it_reqno.

*> 공급업체명
DATA : BEGIN OF xlfa1 OCCURS 0,
       lifnr           LIKE   lfa1-lifnr,
       name1           LIKE   lfa1-name1.
DATA : END   OF xlfa1.


*-----------------------------------------------------------------------
*> 적하보험. Item용.
*-----------------------------------------------------------------------
CONTROLS: tc_2130   TYPE TABLEVIEW USING SCREEN 2130.

*> TYPE FOR THE DATA OF TABLECONTROL 'tc_2130'
TYPES: BEGIN OF t_tc_2130.
        INCLUDE STRUCTURE ztisrqit.
TYPES: END OF t_tc_2130.

*> INTERNAL TABLE FOR TABLECONTROL 'tc_2130'
DATA:     it_tab           TYPE t_tc_2130 OCCURS 0,
          g_tc_2130_wa     TYPE t_tc_2130,           ">work area
          g_tc_2130_copied.                          ">copy flag

*> LINES OF TABLECONTROL 'tc_2130'
DATA:     g_tc_2130_lines  LIKE sy-loopc.

*-----------------------------------------------------------------------
*> 적하보험. Item용.
*-----------------------------------------------------------------------
*> data declaration for tablecontrol 'TC_2210'
*> definition of ddic-table
TABLES:   ztitip2.

*> type for the data of tablecontrol 'TC_2210'
TYPES: BEGIN OF t_tc_2210.
        INCLUDE STRUCTURE ztisip02.
TYPES: END   OF t_tc_2210.

*> internal table for tablecontrol 'TC_2210'
DATA:     g_tc_2210_itab   TYPE t_tc_2210 OCCURS 0,
          g_tc_2210_itab_o TYPE t_tc_2210 OCCURS 0,
          g_tc_2210_wa     TYPE t_tc_2210. "work area
DATA:     g_tc_2210_copied.           "copy flag

*> declaration of tablecontrol 'TC_2210' itself
CONTROLS: tc_2210 TYPE TABLEVIEW USING SCREEN 2210.
CONTROLS: tc_2124 TYPE TABLEVIEW USING SCREEN 2124.

*> lines of tablecontrol 'TC_2210'
DATA:     g_tc_2210_lines  LIKE sy-loopc.
DATA:     g_tc_2124_lines  LIKE sy-loopc.

DATA: g_ipnum_chk1,
      g_ipnum_chk2,
      G_IIPNO             TYPE ZTIIIPNO,
      g_ispno             LIKE ztitip1-ispno.

DATA: old_ztitip1         LIKE ztitip1,
      old_ztitip3         LIKE ztitip3,
      old_ztitip4         LIKE ztitip4,
      g_amdsq             TYPE ztiamseq.

DATA: alv_detail_func(30).


DATA: fc       TYPE slis_t_fieldcat_alv,
      fc1      TYPE slis_t_fieldcat_alv,
      fcs      TYPE slis_fieldcat_alv.

DATA: BEGIN OF fc_struct,
        tabname(7),
        fieldname(6),
        ref_tabname(29),
        ref_fieldname(6),
        no_out(1),
        cqindicator(1),
        cqfield(6),
      END OF fc_struct.


DATA: it_fieldcat_g TYPE lvc_t_fcat,
      gs_fieldcat_g LIKE LINE OF it_fieldcat_g.


***********************************************************************
* FIELD-SYMBOLS
***********************************************************************
FIELD-SYMBOLS: <fs>  TYPE ANY,
               <fsl> TYPE ANY,
               <fss> TYPE ANY.

FIELD-SYMBOLS: <gt_table> TYPE table.

************************************************************************
* MACRO DEFINE                                                         *
************************************************************************
DEFINE ac.

  clear:  fcs, fc_struct.

  fc_struct         = &1.
  fcs-tabname        = fc_struct-tabname.
  fcs-fieldname      = fc_struct-fieldname.
  fcs-ref_tabname    = fc_struct-ref_tabname.
  fcs-ref_fieldname  = fc_struct-ref_fieldname.
  fcs-no_out         = fc_struct-no_out.

  case fc_struct-cqindicator.
    when 'C'.
      fcs-cfieldname = fc_struct-cqfield.
    when 'Q'.
      fcs-qfieldname = fc_struct-cqfield.
  endcase.
  append fcs to fc.
END-OF-DEFINITION.

DEFINE ac_1.
  clear: fcs, fc_struct.
  fcs-tabname        = &1.
  fcs-fieldname      = &2.
  fcs-ref_tabname    = &3.
  fcs-ref_fieldname  = &4.
  fcs-no_out         = &5.

  case &6.
    when 'C'.
      fcs-cfieldname = &7.
    when 'Q'.
      fcs-qfieldname = &7.
  endcase.
  append fcs to fc.

END-OF-DEFINITION.

** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: a_bukrs LIKE t001-bukrs,
      l_yn    type c.
** JS전선 회사코드 2007/04 KSH --------------------------------------
