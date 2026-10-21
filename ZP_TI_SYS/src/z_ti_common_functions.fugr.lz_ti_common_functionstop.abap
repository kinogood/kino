FUNCTION-POOL z_ti_common_functions   MESSAGE-ID zmti00.

TABLES: ztitig00,
        ztivcr00,
        ztitig07,
        ztstig8,
        ztitcsk,
        ztiscsk,
        ztitblp,
        ztitcsp,
        ztiscsit,
        ztitcso,
        ztittxk,
        FAEDE,
        ztivrq00,
       *ztitcsk,
        ztstfbc,
        t074u,
        tbsl,
        tbslt,
        knb1,
        vf_kred,
        kna1,
*        t100,
        tgsbt,
        skat,
        j_1bbranch,
       *lfa1,
        t134,
        bkpf,
        bseg,
        mara.

INCLUDE <icon>.


TYPE-POOLS: slis.   "> Globale Type(ALV)
TYPE-POOLS: kkblo, cntl, rsds.

INCLUDE lslvchc1.

CONSTANTS: gc_lvc_memid(60) TYPE c VALUE 'LVC_MEMID_TOTALS'.
INCLUDE:   <cl_alv_control>, <list>, <slvc_cell_data_get>.

FIELD-SYMBOLS: <coltab> TYPE lvc_t_scol.
FIELD-SYMBOLS: <slis_coltab> TYPE slis_t_specialcol_alv.
FIELD-SYMBOLS: <gt_table> TYPE table.
FIELD-SYMBOLS: <gs_table>.
FIELD-SYMBOLS: <gt_filter> TYPE lvc_t_fidx.
FIELD-SYMBOLS: <gt_style> TYPE lvc_t_styl.
FIELD-SYMBOLS: <g_field>.
DATA  g_subname TYPE kkblo_formname.

DATA: g_callback LIKE sy-repid.
DATA: g_stop_merge(1) TYPE c.
DATA: g_routine(30) TYPE c.
DATA: g_alv TYPE REF TO cl_gui_alv_grid.
DATA: g_view TYPE ui_func.
DATA: gt_log_alv TYPE lvc_t_log.
DATA: g_gui_type TYPE i.
DATA: gs_lvc_data TYPE lvc_s_data.
DATA: g_value TYPE lvc_s_data-value.
DATA: g_col_counter TYPE sy-tabix.
DATA: g_style TYPE lvc_s_data-style.                        "#EC NEEDED
DATA: g_style_color TYPE lvc_s_data-style.
DATA: gflg_invisible(1) TYPE c.
DATA: gs_subtot_info TYPE lvc_s_stxt.
DATA: g_subtottxt TYPE lvc_distxt.
DATA: gp_line TYPE REF TO data.
DATA: gt_dragdrop TYPE lvc_t_drdr.
DATA: gs_dragdrop TYPE lvc_s_drdr.
DATA: gs_poid TYPE lvc_s_roro.
DATA: gs_roid TYPE lvc_s_roid.
DATA: gs_style TYPE lvc_s_styl.
*=======================================
DATA: gs_grouplevels TYPE lvc_s_grpl.
DATA: g_lines TYPE sy-tabix.
DATA: g_entries TYPE sy-tabix.
DATA: g_packed TYPE p DECIMALS 2.
DATA: gs_fieldcat TYPE lvc_s_fcat.
FIELD-SYMBOLS: <g_unit>.
FIELD-SYMBOLS: <g_href>.
FIELD-SYMBOLS: <g_unit_dest>.
*=======================================
TYPES: BEGIN OF lvc_s_layo_local.
TYPES: indx_ctab_fname             TYPE i,
       indx_stylefname             TYPE i,
       indx_info_fname             TYPE i,
       indx_excp_fname             TYPE i,
       indx_countfname             TYPE i,
       indx_s_dragdrop_fieldname   TYPE i.
TYPES: END OF lvc_s_layo_local.

TYPES: BEGIN OF lvc_s_fcat_local.
        INCLUDE STRUCTURE lvc_s_fcat.
*TYPES: indx_field        type i,
*       indx_cfiel        type i,
*       indx_qfiel        type i,
*       indx_ifiel        type i,
*       indx_round        type i,
*       indx_decml        type i,
*       get_style         type c.
TYPES: END OF lvc_s_fcat_local.
TYPES: lvc_t_fcat_local TYPE lvc_s_fcat_local OCCURS 30.
*=======================================
FIELD-SYMBOLS: <gt_dragdrop>.
*-- Constants
CONSTANTS: con_c_light_green   TYPE c VALUE '3',
           con_c_light_yellow  TYPE c VALUE '2',
           con_c_light_red     TYPE c VALUE '1'.

* data for testing
DATA:
  g_testmode(1) TYPE c,
  g_debug(1)    TYPE c,
  gt_old_lvc_data TYPE lvc_t_data.
*--------------------> alv create internal table용


CONSTANTS: c_true      TYPE c        VALUE 'X',
           c_false     TYPE c        VALUE space,
           c_error     TYPE c        VALUE 'E',
           c_waring    TYPE c        VALUE 'W',
           c_success   TYPE c        VALUE 'S',
           c_info      TYPE c        VALUE 'I',
           c_abend     TYPE c        VALUE 'A',
           c_none      TYPE c        VALUE 'N'.

DATA: BEGIN OF fc_struct,
        tabname(7),
        fieldname(9),
        ref_tabname(7),
        ref_fieldname(6),
        no_out(1),
        cqindicator(1),
        cqfield(6),
      END OF fc_struct.

*>ALV POPUP.
DATA: gs_private  TYPE slis_data_caller_exit,
      gs_selfield TYPE slis_selfield,
      t_fieldcat  TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      g_exit(1)   TYPE c,
      dyname      LIKE d020s-prog,
*      L_TITLE     TYPE SY-TITLE.
      g_title(99) TYPE c,
      extab TYPE slis_t_extab.

DEFINE mfc.
  clear: t_fieldcat, fc_struct.
  t_fieldcat-tabname        = &1.
  t_fieldcat-fieldname      = &2.
  t_fieldcat-ref_tabname    = &3.
  t_fieldcat-ref_fieldname  = &4.
  t_fieldcat-no_out         = &5.

  case &6.
    when 'C'.
      t_fieldcat-cfieldname = &7.
    when 'Q'.
      t_fieldcat-qfieldname = &7.
  endcase.
  append t_fieldcat.
END-OF-DEFINITION.


*> 상수 정의(문자집합).
CONSTANTS:
           c_chara     TYPE c        VALUE 'A',
           c_charb     TYPE c        VALUE 'B',
           c_charc     TYPE c        VALUE 'C',
           c_chard     TYPE c        VALUE 'D',
           c_chare     TYPE c        VALUE 'E',
           c_charf     TYPE c        VALUE 'F',
           c_charg     TYPE c        VALUE 'G',
           c_charh     TYPE c        VALUE 'H',
           c_chari     TYPE c        VALUE 'I',
           c_charj     TYPE c        VALUE 'J',
           c_chark     TYPE c        VALUE 'K',
           c_charl     TYPE c        VALUE 'L',
           c_charm     TYPE c        VALUE 'M',
           c_charn     TYPE c        VALUE 'N',
           c_charo     TYPE c        VALUE 'O',
           c_charp     TYPE c        VALUE 'P',
           c_charq     TYPE c        VALUE 'Q',
           c_charr     TYPE c        VALUE 'R',
           c_chars     TYPE c        VALUE 'S',
           c_chart     TYPE c        VALUE 'T',
           c_charu     TYPE c        VALUE 'U',
           c_charv     TYPE c        VALUE 'V',
           c_charw     TYPE c        VALUE 'W',
           c_charx     TYPE c        VALUE 'X',
           c_chary     TYPE c        VALUE 'Y',
           c_charz     TYPE c        VALUE 'Z',
           c_char0     TYPE c        VALUE '0',
           c_char1     TYPE c        VALUE '1',
           c_char2     TYPE c        VALUE '2',
           c_char3     TYPE c        VALUE '3',
           c_char4     TYPE c        VALUE '4',
           c_char5     TYPE c        VALUE '5',
           c_char6     TYPE c        VALUE '6',
           c_char7     TYPE c        VALUE '7',
           c_char8     TYPE c        VALUE '8',
           c_char9     TYPE c        VALUE '9',
           c_char*     TYPE c        VALUE '*',
           c_char$     TYPE c        VALUE '$',
           c_char-     TYPE c        VALUE '-',
           c_char_plus TYPE c        VALUE '+'.


*> 전표전기용.
DATA: g_monat          LIKE bkpf-monat, "Save field for input period
      g_flag,
      g_hkont          LIKE bseg-hkont,
      g_bukrs          TYPE bukrs,
      g_egrkz          LIKE t007a-egrkz,
      g_term_changed   TYPE c,
      g_icsno          TYPE ztiicsno,
      g_empfk_changed  TYPE c.

*> 사업영역용.
DATA : BEGIN OF xgsber OCCURS 0,
       gsber    TYPE   gsber,
       END   OF xgsber.

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



*>-------------------------------------------------------------------
*> 제비용 처리를 위한 Internal table
*>-------------------------------------------------------------------
TABLES : mtreesnode_ft.

CONSTANTS: line_length    TYPE i VALUE 256.

DATA : gv_xthead_updkz    TYPE i.
CLASS lcl_application     DEFINITION DEFERRED.
CLASS cl_gui_cfw          DEFINITION LOAD.
CLASS cl_gui_column_tree  DEFINITION LOAD.

* Docking Container
DATA: g_application       TYPE REF TO lcl_application,
      g_ok_code           TYPE        sy-ucomm.
DATA: g_docking           TYPE REF TO cl_gui_docking_container,
      g_tree_7000         TYPE REF TO cl_gui_column_tree.

* Definition of Control Framework
TYPE-POOLS cndp.

DATA  g_init   TYPE c.
DATA  g_dynnr  TYPE sy-dynnr.

DATA: g_find           TYPE i.

TYPES: item_table_type    LIKE STANDARD TABLE OF mtreeitm
                                              WITH DEFAULT KEY.

DATA: node                TYPE treev_node,
      item                TYPE mtreeitm.
DATA: node_table          TYPE treev_ntab,
      item_table          TYPE item_table_type.


* Fields on Dynpro
DATA:   g_event(30),
        g_node_key        TYPE tv_nodekey,
        g_node_key_old    TYPE tv_nodekey,
        g_node_key_new    TYPE tv_nodekey,
        g_node_key_all    TYPE tv_nodekey,
        g_item_name       TYPE tv_itmname,
        g_header_name     TYPE tv_hdrname,
        g_return_code     TYPE i.

DATA : it_ztitcsk   LIKE ztiscsk
                          OCCURS 10 WITH HEADER LINE,
       it_ztitcsp   LIKE ztiscsit
                          OCCURS 10 WITH HEADER LINE,
       xztitcsp     LIKE ztiscsit
                          OCCURS 10 WITH HEADER LINE,
       it_ztitcso   LIKE ztitcso
                          OCCURS 10 WITH HEADER LINE,
       it_ztstfbc   LIKE ztstfbc
                          OCCURS 10 WITH HEADER LINE.

DATA : BEGIN OF it_exptx OCCURS 0,
       exptx    TYPE ztsexptx,
       END   OF it_exptx.


****************************************************************
* LOCAL CLASSES: Definition
*>
*> Tree Control용.
****************************************************************
CLASS lcl_application DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_node_double_click
        FOR EVENT node_double_click
        OF cl_gui_column_tree
        IMPORTING node_key,
      handle_expand_no_children
        FOR EVENT expand_no_children
        OF cl_gui_column_tree
        IMPORTING node_key,
      handle_item_double_click
        FOR EVENT item_double_click
        OF cl_gui_column_tree
        IMPORTING node_key item_name,
      handle_button_click
        FOR EVENT button_click
        OF cl_gui_column_tree
        IMPORTING node_key item_name,
      handle_checkbox_change
        FOR EVENT checkbox_change
        OF cl_gui_column_tree
        IMPORTING node_key item_name checked.
ENDCLASS.                    "lcl_application DEFINITION

*---------------------------------------------------------------------*
*       CLASS LCL_APPLICATION IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_application IMPLEMENTATION.

*> this method handles the node double click event of the tree
*> control instance
*> show the key of the double clicked node in a dynpro field
  METHOD handle_node_double_click.
    g_event      = 'NODE_DOUBLE_CLICK'.
    g_node_key   = node_key.
    CLEAR: g_item_name, g_header_name.

*    PERFORM get_new_node_data  USING g_node_key.
*> Tree Chosen
    PERFORM set_tree_chosen_item.

  ENDMETHOD.                    "HANDLE_NODE_DOUBLE_CLICK

*> this method handles the item double click event of the tree
*> control instance
*> show the key of the node and the name of the item
*> of the double clicked item in a dynpro field
  METHOD  handle_item_double_click.
    g_event      = 'ITEM_DOUBLE_CLICK'.
    g_node_key   = node_key.
    g_item_name  = item_name.
    CLEAR g_header_name.

*    PERFORM get_new_node_data  USING g_node_key.
*> Tree Chosen
    PERFORM set_tree_chosen_item.

  ENDMETHOD.                    "HANDLE_ITEM_DOUBLE_CLICK

*> this method handles the checkbox_change event of the tree
*> control instance
*> show the key of the node and the name of the item
*> of the clicked checkbox in a dynpro field
  METHOD  handle_checkbox_change.
    g_event      = 'CHECKBOX_CHANGE'.
    g_node_key   = node_key.
    g_item_name  = item_name.
    CLEAR  g_header_name.

    PERFORM check_node_checkbox  USING g_node_key.
*> Tree Chosen
    PERFORM set_tree_chosen_item.

  ENDMETHOD.                    "HANDLE_CHECKBOX_CHANGE

  METHOD  handle_button_click.
    " this method handles the button click event of the tree
    " control instance

    " show the key of the node and the name of the item
    " of the clicked button in a dynpro field
    g_event = 'BUTTON_CLICK'.
    g_node_key = node_key.
    g_item_name = item_name.
    CLEAR g_header_name.

    PERFORM get_new_node_data  USING g_node_key.

  ENDMETHOD.                    "HANDLE_BUTTON_CLICK

  METHOD handle_expand_no_children.

  ENDMETHOD.                    "HANDLE_EXPAND_NO_CHILDREN

ENDCLASS.                    "lcl_application IMPLEMENTATION


*> 구매오더 이력 조회용
DATA BEGIN OF iekbe OCCURS 0.
        INCLUDE STRUCTURE ekbe.
DATA END OF iekbe.
DATA BEGIN OF iekbz OCCURS 0.
        INCLUDE STRUCTURE ekbz.
DATA END OF iekbz.

DATA BEGIN OF iekbes OCCURS 0.
        INCLUDE STRUCTURE ekbes.
DATA END OF iekbes.

DATA BEGIN OF iekbez OCCURS 0.
        INCLUDE STRUCTURE ekbez.
DATA END OF iekbez.

DATA BEGIN OF iekbnk OCCURS 0.
        INCLUDE STRUCTURE ekbnk.
DATA END OF iekbnk.



DATA: BEGIN OF it_reqno OCCURS 0,
      box,
      reqno   LIKE ztitrqk-reqno,  "수입의뢰 관리번호.
      amdsq   LIKE ztitrqs-amdsq,  "Amend 차수.
      reqty   LIKE ztitrqk-reqty,  "수입의뢰 종류.
      lifnr   LIKE ztitrqk-lifnr,	  "공급업체 계정번호.
      bukrs   LIKE ztitrqk-bukrs,	  "회사코드.
      ekorg   LIKE ztitrqk-ekorg,	  "구매조직.
      ekgrp   LIKE ztitrqk-ekgrp,	  "구매그룹.
      docst   LIKE ztitrqs-docst,	  "문서상태.
      appun   LIKE ztitrqs-appun,  "개설의뢰 요청자.
      appdt   LIKE ztitrqs-appdt,  "개설의뢰 요청일.
      apptm   LIKE ztitrqs-apptm,  "개설의뢰 요청시간.
      END   OF it_reqno.

DATA: BEGIN OF it_iblno OCCURS 0,
      box,
      ilgno   LIKE ztitlg1-ilgno,    "L/G 관리번호.
      iblno   LIKE ztitblk-iblno,    "B/L 관리번호.
      blnum   LIKE ztitblk-blnum,    "B/L 번호.
      bldty   LIKE ztitblk-bldty,    "B/L 종류.
      lifnr   LIKE ztitblk-lifnr,	  "공급업체 계정번호.
      bukrs   LIKE ztitblk-bukrs,	  "회사코드.
      ekorg   LIKE ztitblk-ekorg,	  "구매조직.
      ekgrp   LIKE ztitblk-ekgrp,	  "구매그룹.
      bleta   LIKE ztitblk-bleta,	  "ETA.
      bletd   LIKE ztitblk-bletd,	  "ETD.
      cnam    LIKE ztitblk-cnam,     "생성인.
      cdat    LIKE ztitblk-cdat,     "생성일.
      END   OF it_iblno.

DATA: BEGIN OF it_iccno OCCURS 0,
      box,
      iccno   LIKE ztitcck-iccno,    "통관관리번호.
      iccsq   like ztitcck-iccsq,    "통관순번.
      CDRDT   LIKE ztitcck-CDRDT,    "수리일자.
      CDCNO   LIKE ztitcck-CDCNO,    "신고(수리)번호.
      lifnr   LIKE ztitcck-lifnr,    "공급업체 계정번호.
      CPYATc  like ztitcck-CPYATc,   "통화.
      CPYAT   LIKE ztitcck-CPYAT,    "송장처리금액.
      bukrs   LIKE ztitcck-bukrs,	   "회사코드.
      ekorg   LIKE ztitcck-ekorg,	   "구매조직.
      ekgrp   LIKE ztitcck-ekgrp,	   "구매그룹.
      cnam    LIKE ztitcck-cnam,     "생성인.
      cdat    LIKE ztitcck-cdat,     "생성일.
      name1   LIKE lfa1-name1,       "이름1.
      END   OF it_iccno.


DATA: BEGIN OF it_ivono OCCURS 0,
      box,
      ivono   LIKE ztitivk-ivono,    "송장관리번호.
      ivnum   LIKE ztitivk-ivnum,    "송장번호.
      prpyn   LIKE ztitivk-prpyn,    "송장 종류.
      livst   LIKE ztitivk-livst,    "전기여부.
      lifnr   LIKE ztitivk-lifnr,	  "공급업체 계정번호.
      ivamp   LIKE ztitivk-ivamp,    "송장처리금액.
      bukrs   LIKE ztitivk-bukrs,	  "회사코드.
      ekorg   LIKE ztitivk-ekorg,	  "구매조직.
      ekgrp   LIKE ztitivk-ekgrp,	  "구매그룹.
      civdt   LIKE ztitivk-civdt,    "송장일.
      cnam    LIKE ztitivk-cnam,     "생성인.
      cdat    LIKE ztitivk-cdat,     "생성일.
      name1   LIKE lfa1-name1,                              "이름1.
      END   OF it_ivono.

DATA: BEGIN OF it_igrno OCCURS 0,
      box,
      igrno   LIKE ztitgrk-igrno,    "G/R 관리번호.
      iccno   LIKE ztitgrk-iccno,    "CC 관리번호.
      grseq   LIKE ztitgrk-grseq,    "G/R 회차.
      iblno   LIKE ztitgrk-iblno,    "B/L 관리번호.
*      blnum   LIKE ZTITGRK-blnum,    "B/L 번호.
*      bldty   LIKE ZTITGRK-bldty,    "B/L 종류.
      lifnr   LIKE ztitgrk-lifnr,	  "공급업체 계정번호.
      bukrs   LIKE ztitgrk-bukrs,	  "회사코드.
      bleta   LIKE ztitgrk-budat,	  "증빙.
      bletd   LIKE ztitgrk-bldat,	  "전기.
      cnam    LIKE ztitgrk-cnam,     "생성인.
      cdat    LIKE ztitgrk-cdat,     "생성일.
      igrst   LIKE ztitgrk-igrst,
      igrty   LIKE ztitgrk-igrty,
      bwart   LIKE ztitgrk-bwart,
      END   OF it_igrno.

*-----------------------------------------------------------------------
*> LDB Process 관련.
*-----------------------------------------------------------------------
DATA: it_selscreen   LIKE rsparams OCCURS 10 WITH HEADER LINE,
      it_callback    LIKE ldbcb OCCURS 10    WITH HEADER LINE.

CONSTANTS:
      c_repid        LIKE sy-repid    VALUE 'SAPLZ_TI_COMMON_FUNCTIONS'.

*-----------------------------------------------------------------------
*> 수입이력관련.
*-----------------------------------------------------------------------
INCLUDE cnt4defs.
INCLUDE <ctldef>.

TABLES : ztisdochis,
         ztisscrcom,
         rkwa_key,
         ztitlg1,
         ztitip1,
         ztitbsk,
         ztitbik,
         ztitbok,
         ztivpo01,
         ztivbl00,
         ztiviv00,
         ztiviv01,
         ztivcc00,
         ztivgr00,
         ztivpn00,
         ztivrq04,
         ztitblk,
         ztitcck.

CONSTANTS: c_column1(1)        TYPE c               VALUE '1',
           c_column2(1)        TYPE c               VALUE '2',
           c_column3(1)        TYPE c               VALUE '3',
           c_column4(1)        TYPE c               VALUE '4',
           c_column5(1)        TYPE c               VALUE '5',
           c_column6(1)        TYPE c               VALUE '6',
           c_column7(1)        TYPE c               VALUE '7',
           c_column8(1)        TYPE c               VALUE '8',
           c_column9(1)        TYPE c               VALUE '9',
           c_header1(2)        TYPE c               VALUE 'H1',
           c_header2(2)        TYPE c               VALUE 'H2',
           c_header3(2)        TYPE c               VALUE 'H3',
           c_header4(2)        TYPE c               VALUE 'H4',
           c_header5(2)        TYPE c               VALUE 'H5',
           c_header6(2)        TYPE c               VALUE 'H6',
           c_header7(2)        TYPE c               VALUE 'H7',
           c_header8(2)        TYPE c               VALUE 'H8',
           c_header9(2)        TYPE c               VALUE 'H9'.

DATA: it_dochis      LIKE ztisdochis   OCCURS 0 WITH HEADER LINE,
      it_costdoc     LIKE ztiscostdoc  OCCURS 0 WITH HEADER LINE,
      it_amendfield  LIKE ztisamendfid OCCURS 0 WITH HEADER LINE,
      g_tree_handle  TYPE cntl_handle.

DATA: g_node         LIKE treev_node,
*      g_node_key     LIKE treev_node-node_key,
      g_node_seq(12) TYPE n,
      g_docty        TYPE ztireqty,
      g_docno        TYPE ztireqno,
      g_amdsq        TYPE ztiamdsq,
      g_set_nodekey  LIKE treev_node-node_key,
      g_dochis_tm    LIKE ztisdochis,
      g_dochis_po    LIKE ztisdochis,
      g_dochis_lc    LIKE ztisdochis,
      g_dochis_bl    LIKE ztisdochis,
      g_dochis_bs    LIKE ztisdochis,
      g_dochis_bi    LIKE ztisdochis,
      g_dochis_cr    LIKE ztisdochis,
      g_dochis_cc    LIKE ztisdochis,
      g_dochis_iv    LIKE ztisdochis.

TABLES : ztispokey,
         ztitrqk,
         ztitrqs,
         ztivpo00.

DATA: BEGIN OF it_pokey OCCURS 0.
        INCLUDE STRUCTURE ztispokey.
DATA: END   OF it_pokey.

DATA: BEGIN OF it_rkwa_key OCCURS 0.
        INCLUDE STRUCTURE rkwa_key.
DATA: END   OF it_rkwa_key.

DATA: BEGIN OF it_reqit OCCURS 0.
        INCLUDE STRUCTURE ztisrqit.
DATA: END   OF it_reqit.

DATA: BEGIN OF it_ekpo OCCURS 0.
        INCLUDE STRUCTURE ekpo.
DATA: END   OF it_ekpo.

DATA : BEGIN OF it_ztitig02 OCCURS 0.
        INCLUDE STRUCTURE ztitig02.
DATA : END   OF it_ztitig02.


DATA : BEGIN OF it_ztitig06 OCCURS 0.
        INCLUDE STRUCTURE ztitig06.
DATA : END   OF it_ztitig06.

* item을 저장하기 위한 테이블.
DATA : BEGIN OF it_po OCCURS 0,
       box        TYPE c,
       index(10)  TYPE n,
       ebeln      LIKE ekpo-ebeln,
       ebelp      LIKE ekpo-ebelp,
       menge      LIKE ekpo-menge,
       meins      LIKE ekpo-meins,
       bstyp      LIKE ekko-bstyp,
       zterm      LIKE ekko-zterm,
       frgrl      LIKE ekko-frgrl,
       bsart      LIKE ekko-bsart,
       hloekz     LIKE ekko-loekz,  ">헤더 삭제지시자.
       loekz      LIKE ekpo-loekz,  ">아이템 삭제지시자.
       elikz      LIKE ekpo-elikz,  ">납품완료 지시자.
       rqmng      LIKE ztitrqp-rqmng,
       rqmngs     LIKE ztisrqit-rqmngs,
       rqmngl     LIKE ztisrqit-rqmngl,
       END   OF it_po.

DATA : BEGIN OF it_ponum OCCURS 0,
       ebeln      LIKE ekpo-ebeln.
DATA : END   OF it_ponum.


*> declaration of tablecontrol 'TC_0100' itself
CONTROLS: tc_0100 TYPE TABLEVIEW USING SCREEN 0100.

TABLES : ztisprtctl,
         dfies.

*> lines of tablecontrol 'TC_0100'
DATA:     g_tc_0100_lines  LIKE sy-loopc.
DATA:     wa_prtctl        LIKE ztisprtctl.
DATA:     ok_code          LIKE sy-ucomm.
DATA:     ok-code          LIKE sy-ucomm.
DATA:     g_count          TYPE i,
          g_cnt            TYPE I,
          g_ztitcso        LIKE ztitcso,
          g_okcode         LIKE sy-ucomm,
          ok_code_old      LIKE SY-UCOMM,
          g_modify         TYPE c,
          g_mode           TYPE c,
          g_fieldgroup(12) TYPE c,
          g_lcity          TYPE ztilcity,
          g_findscr        LIKE sy-dynnr,
          g_findline       TYPE i,
          g_fieldname(20)  TYPE c,
          g_button         TYPE c,
          g_count_1        TYPE i,
          g_line           TYPE i,
          g_line1          TYPE i,
          g_answer         TYPE c,
          g_success_cnt    TYPE i,
          g_error_cnt      TYPE i,
          g_subrc          LIKE sy-subrc,
          g_tabix          LIKE sy-tabix,
          g_tabix1         LIKE sy-tabix,
          g_tabix2         LIKE sy-tabix,
          g_index          LIKE sy-index.

*> 라디오 버튼.
DATA:     g_radio1(1)      TYPE c,
          g_radio2(1)      TYPE c,
          g_radio3(1)      TYPE c.



*-------- Table CUA-PF-Status -----------------------------------------*
DATA:    BEGIN OF excl OCCURS 25,
           funktion(10),
         END OF excl.

*> declaration of tablecontrol 'TC_0200' itself
CONTROLS: tc_0200 TYPE TABLEVIEW USING SCREEN 0200,
          tc_0210 TYPE TABLEVIEW USING SCREEN 0210.

*&----------------------------------------------------------------------
*   기타 텍스트용 화면.
*&----------------------------------------------------------------------
*> data declaration for tablecontrol 'TC_0300'
*> definition of ddic-table
*----------------------------------------------------------------------*
TABLES:   ztitlc2.

DATA: BEGIN OF it_ztitlc2 OCCURS 0.
        INCLUDE STRUCTURE ztislc02.
DATA: END   OF it_ztitlc2.

*> type for the data of tablecontrol 'TC_0300'
TYPES: BEGIN OF t_tc_0300,
         qitno LIKE ztitlc2-qitno,
         ltext LIKE ztitlc2-ltext,
         flag,       "flag for mark column
       END OF t_tc_0300.

*> internal table for tablecontrol 'TC_0300'
DATA:     g_tc_0300_itab   TYPE t_tc_0300 OCCURS 0,
          g_tc_0300_wa     TYPE t_tc_0300. "work area
DATA:     g_tc_0300_copied.           "copy flag

*> declaration of tablecontrol 'TC_0300' itself
CONTROLS: tc_0300 TYPE TABLEVIEW USING SCREEN 0300.

*> lines of tablecontrol 'TC_0300'
DATA:     g_tc_0300_lines  LIKE sy-loopc.

*> callback include.
INCLUDE lz_ti_common_functionscb1.



*-- Tabellen ----------------------------------------------------------*
TABLES: ekbe,                   ekbz,
        ekkn,                   ekko, *ekko,           ekpo,
        eket,                   ekab,                  ekub,
        ekpv,                   ekki,                  eban,
        ebkn,                   eina,                  eine,
        ekes,

        komk,                   komp,                  konv,

        lfa1,                   lfm1,
        likp,
        mseg,                   mkpf,
        mdpa,                   mdgi,
        mdcp,
        essr,
        t001,                   t001k,                 t001w,
        t149,
        t160b,                  t160s,
        t161v,                  t161w,
        t163b,                  t163k,
        t052,
        t685a,                  t685t,
        ekrs,                   tmppf,
        ek08ers,
        ekbez,
        ek05a,
        ek05n,      "Tabelle mit neuen Kontierungsobjekten
        m_mebel,
        m_mebex,
        m_mebzf,
        m_mebzx,
*        M_MEKKA,                                                "371571
*       M_MEKKD,
*        M_MBANA,                                                "371571
        addr1_val,
        t024e.                                              "@80181

TYPE-POOLS: copo.
RANGES: m_werks FOR ekpo-werks.

*-- Hilfsfelder -------------------------------------------------------*
DATA: h-ebeln LIKE ekbe-ebeln.
DATA: betragf  TYPE f.                 "Rechenfeld fuer Kursumrechnung
DATA: h-wert LIKE ekpo-netwr.          "Hilfsfeld Betrag
DATA: h2-wert LIKE ekpo-netwr.         "Hilfsfeld Betrag Rechnungsplan
DATA: h-eindt(10).                     "Hilfsfeld Lieferdatum
DATA: h-bzdat LIKE bseg-bzdat.         "Hilfsfeld Bezugsdatum
DATA: h-lvgdt LIKE ekbes-lvgdt.        "Hilfsfeld letzter Vorgang
DATA: h-menge LIKE ekbes-wemng.        "Hilfsfeld WE-Menge
DATA: h-datum LIKE ekpv-ledat.         "Hilfsfeld rel. Lieferdatum
DATA: h-kondi.                         "Konditionen noch offen
DATA: xnosel.                          "Position pa? nicht
DATA: xmatrix.                         "Matrixerfassung erforderlich
DATA: f1 TYPE f.                       "Gleitkommahilfsfeld
DATA: f2 TYPE f.                       "Gleitkommahilfsfeld
DATA: refe1(16) TYPE p.                "Rechenfeld
DATA: refe1abs(16) TYPE p.             "Rechenfeld, Absolutwert
DATA: h-vbeln LIKE ekes-vbeln.         "Lieferavisnummer
DATA: h-vbelp LIKE ekes-vbelp.         "Lieferavisposition
DATA: h-etens LIKE ekes-etens.         "Lfd. Nr. Best?igung "321534
DATA: h-lamng LIKE ekes-menge.         "Hilfsfeld Avis
DATA: h-lwmng LIKE ekes-menge.         "Hilfsfeld Avis
DATA: h-index LIKE sy-tabix.           "Hilfsfeld Tabellenindex

*DATA: MAXWERT LIKE EBEFU-UETMG VALUE '9999999999999'.   "Maximalwert
*DATA: MAXMENGE LIKE EKPO-MENGE VALUE 9999999999999.
DATA: maxwert LIKE ebefu-uetmg VALUE '9999999999.999'.   "Maximalwert
DATA: maxmenge LIKE ekpo-menge VALUE '9999999999.999'.


DATA: vrt-wemng LIKE ekbe-menge,       "Zu Verteilende WE-Menge
      vrt-menge LIKE ekbe-menge,       "Verteilte WE_Menge
      vrt-mengk LIKE ekbe-menge,       "aufnahmef?ige Menge der Kont
      vrt-shkzg LIKE ekbe-shkzg,       "S/H-Kennz
      vrt-datum LIKE ekbe-cpudt.       "CPU-Datum

DATA: zaehlsel  TYPE p,                "Zaehler Selektierte Pos
      zaehlall  TYPE p.                "Zaehler Positionen

DATA: refe      TYPE p.                "%-Satz Kursabweichung
DATA: su_waers  LIKE ekko-waers.       "Fremdw?rung f? Summen
DATA: su_kont_waers  LIKE ekko-waers.                       "72479
DATA: su_wewae  LIKE ekko-waers.       "Fremdw?rung f? Summen WE
DATA: su_arekz.                        "AREWW nicht komplett da
DATA: su_fwknz_we.                     "Kz. EKBZ-Summe in FW in WE
DATA: su_fwknz.                        "Kz. EKBE-Summe in FW
DATA: su_fwknz_pos.  "Kz. EKBE-Summe auf Pos.ebene w?rungsrein  "72479
DATA: h_index LIKE sy-tabix.           "Hilfsindex
DATA: kot_index LIKE sy-tabix.          "Hilfsindex f? KOT
DATA: maxpreis LIKE ekpo-netpr VALUE '999999999.99'.
DATA: h_bets_wemng(10) TYPE p DECIMALS 3.                   "TK 4.5A
DATA: h_betz_wemng(10) TYPE p DECIMALS 3.                   "TK 4.5A
DATA: h_bets_bpmng(10) TYPE p DECIMALS 3.                   "TK 4.5A
DATA: h_betz_bpmng(10) TYPE p DECIMALS 3.                   "TK 4.5A

DATA: srv_tax.                          "H.feld Steuern Leistung

*- allgemeine Direktwerte ----------------------------------------------
INCLUDE fmmexdir.

*- Hilfsfelder f? Reporting -------------------------------------------
DATA: zugflag(2),                      "Kennzeichen DB-Zugriff
      kopfexit,                        "Kennz. Exit aus Kopf
      posexit.                         "Kennz. Exit aus Pos

*- Hilfsfelder f? Komponenten -----------------------------------------
DATA: lb_ebelp LIKE ekpo-ebelp,
      lb_wemng LIKE ekbes-wemng,
      lb_first LIKE sy-tabix,
      lb_last  LIKE sy-tabix,
      lb_next  LIKE sy-tabix,
      lb_akt   LIKE sy-tabix.

* Internal tables
* Scheduling lines for subcontracting
DATA:   BEGIN OF let OCCURS 10,
           ebeln LIKE eket-ebeln,
           ebelp LIKE eket-ebelp,
           etenr LIKE eket-etenr,
           eindt LIKE eket-eindt,
           uzeit LIKE eket-uzeit,
           menge LIKE eket-menge,
           bedat LIKE eket-bedat,
           wemng LIKE eket-wemng,   "received quantity
* WENEU = received quantity of the previous lines of document
           weneu LIKE eket-wemng,
* WEAKT = received quantity of the current line
           weakt LIKE eket-wemng,
* WESTN = reversed quantity of the previous lines of document
           westn LIKE eket-wemng,
* WESTO = reversed quantity of the current line
           westo LIKE eket-wemng,
           rsnum LIKE eket-rsnum,
        END OF let.

*-- Tabelle der Einkaufsbelegk?fe ------------------------------------*
DATA:   BEGIN OF ekt OCCURS 10.
        INCLUDE STRUCTURE ekko.
DATA:   END OF ekt.

*-- Tabelle der Einkaufsbelegk?fe ------------------------------------*
DATA:   BEGIN OF ekp OCCURS 50.
        INCLUDE STRUCTURE ekpo.
DATA:      xmetall,                      "Metallpreis vorhanden?
           xnokonv,                      "KONV nicht abspeichern
           pmeng LIKE ekpo-menge,        "Preisfindungsmenge
        END OF ekp.

*-- Tabelle der LB-Komponenten ----------------------------------------*
DATA:   BEGIN OF mdsbx OCCURS 10.
        INCLUDE STRUCTURE mdsb.
DATA:   END OF mdsbx.

*-- Tabelle der LB-Komponenten ----------------------------------------*
DATA:   BEGIN OF mdpmx OCCURS 10.
        INCLUDE STRUCTURE mdpm.
DATA:   END OF mdpmx.

*-- Tabelle der Einkaufsbelegpositionen -------------------------------*
*DATA:   BEGIN OF POT OCCURS 10.
*           INCLUDE STRUCTURE BEKPO.
*data:      BZDAT LIKE BSEG-BZDAT,
*           XMETALL,                      "Metallpreis vorhanden?
*           VKWRT LIKE MSEG-VKWRT,        "Verkaufswert mit Steuer
*           VKWRA LIKE MSEG-VKWRT,        "Verkaufswert ohne Steuer
*           ERFMG LIKE EBEFU-ERFMG,       "Vorschlag f? LP-Pos     KR
*           LPDAT LIKE EKET-EINDT,        "Eindt der letzten offenen KR
*        END OF POT.                      "Einteilung bis heute

DATA: pot TYPE einr_s_pot OCCURS 10 WITH HEADER LINE.

*-- Key zum Lesen der Tabelle KOT -------------------------------------*
DATA:   BEGIN OF kotkey,
           mandt LIKE ekko-mandt,
           ebeln LIKE ekko-ebeln,
        END OF kotkey.

*-- Key zum Lesen der Tabelle POT -------------------------------------*
DATA:   BEGIN OF potkey,
           mandt LIKE ekpo-mandt,
           ebeln LIKE ekpo-ebeln,
           ebelp LIKE ekpo-ebelp,
        END OF potkey.

*-- Tabelle der Einkaufsbelegkontierungen -----------------------------*
DATA:   BEGIN OF knt OCCURS 10.
        INCLUDE STRUCTURE ekkn.
DATA:   END OF knt.

*-- Tabelle der Einteilungen ------------------------------------------*
DATA:   BEGIN OF ett OCCURS 10.
        INCLUDE STRUCTURE eket.
DATA:   END OF ett.

*-- Tabelle der Einteilungen f? User Exit 001 und 003 ----------------*
DATA:   BEGIN OF cett OCCURS 10.
        INCLUDE STRUCTURE eket.
DATA:   END OF cett.

*-- Sammeltabelle f? Einteilungen ------------------------------------*
DATA:   BEGIN OF t_ett OCCURS 0.
        INCLUDE STRUCTURE eket.
DATA:   END OF t_ett.

*-- Sammeltabelle f? Bestellentwicklung ------------------------------*
DATA:   BEGIN OF t_bet OCCURS 0.
        INCLUDE STRUCTURE ekbe.
DATA:   END OF t_bet.

*-- Tabelle der Abrufdoku ---------------------------------------------*
DATA:   BEGIN OF ado OCCURS 10.
        INCLUDE STRUCTURE ekabf.
DATA:   END OF ado.

*-- Tabelle der Abrufdokusummen ---------------------------------------*
DATA:   BEGIN OF ados OCCURS 10.
        INCLUDE STRUCTURE ekabs.
DATA:   END OF ados.

*------- BET ( Tabelle der Bestellentwicklungssaetze ) ----------------*
DATA:   BEGIN OF bet OCCURS 50.
        INCLUDE STRUCTURE ekbe.
DATA:   END OF bet.

*------- BET ( lokale (FB) Tabelle der Bestellentwicklungssaetze ) --*
DATA:   BEGIN OF l_bet OCCURS 50.
        INCLUDE STRUCTURE ekbe.
DATA:   END OF l_bet.

*------- BzT ( Tabelle der Bezugsnebenkostensaetze ) ------------------*
DATA:   BEGIN OF bzt OCCURS 50.
        INCLUDE STRUCTURE ekbz.
DATA:   END OF bzt.

*------- BETB (Tabelle der Bezugsnebenkostensummen ) ------------------*
DATA:   BEGIN OF betb OCCURS 10.
        INCLUDE STRUCTURE ekbnk.
DATA:   END OF betb.

*------- BETS (Tabelle der Bestellentwicklungssummen ) ----------------*
DATA:   BEGIN OF bets OCCURS 50.
        INCLUDE STRUCTURE ekbes.
DATA:   END OF bets.

*------- BETZ (Tabelle der WE-RE-Zuordnungen) -------------------------*
DATA:   BEGIN OF betz OCCURS 50.
        INCLUDE STRUCTURE ekbez.
DATA:   END OF betz.

*------- BETSL (Tabelle der Leistungssummen ) -------------------------*
DATA:   BEGIN OF betsl OCCURS 50.
        INCLUDE STRUCTURE ekbesl.
DATA:   END OF betsl.

*------- TKOMV ( Tabelle der Konditionen im Beleg)
DATA:    BEGIN OF tkomv OCCURS 50.
        INCLUDE STRUCTURE komv.
DATA:    END OF tkomv.

*------- GKOMV ( Tabelle der Konditionen im Beleg) DB-Stand
DATA:    BEGIN OF gkomv OCCURS 200.
        INCLUDE STRUCTURE komv.
DATA:    END OF gkomv.

*------- VRTZ (Tabelle der zu verteilenden WE-Mengen) -----------------*
DATA:   BEGIN OF vrtz OCCURS 10,
           ebelp LIKE ekpo-ebelp,
           zekkn LIKE ekkn-zekkn,
           lfgja LIKE ekbe-lfgja,
           lfbnr LIKE ekbe-lfbnr,
           lfpos LIKE ekbe-lfpos,
           wemng LIKE ekpo-menge,
        END OF vrtz.

*------- XKBEFU (Tabelle der Kopfkommunikationsstrukturen WE)
DATA:    BEGIN OF xkbefu OCCURS 5.
        INCLUDE STRUCTURE kbefu.
DATA:    END OF xkbefu.

*------- XM_MEKKD (Tabelle der Matchcodes f? WE/RE-Kto.Pflege)
*ATA:    BEGIN OF XM_MEKKD OCCURS 100.
*          INCLUDE STRUCTURE M_MEKKD.
*ATA:    END OF XM_MEKKD.

*-- Tabelle der Kontierungen zum Liestungserfassungsblatt -------------*
DATA: BEGIN OF xeskn OCCURS 1.
        INCLUDE STRUCTURE eskn.
DATA: END OF xeskn.
DATA: BEGIN OF xeskl OCCURS 1.
        INCLUDE STRUCTURE eskl.
DATA: END OF xeskl.
DATA: BEGIN OF xesll OCCURS 1.
        INCLUDE STRUCTURE esll.
DATA: END OF xesll.

*-- Feldleiste f? Gruppenwechsel WE/RE-Zuordnung ---------------------*
DATA: BEGIN OF werez,
        ebelp LIKE ekbe-ebelp,
        zekkn LIKE ekbe-zekkn,
        lfgja LIKE ekbe-lfgja,
        lfbnr LIKE ekbe-lfbnr,
        lfpos LIKE ekbe-lfpos,
      END OF werez.

*-- Feldleiste f? Gruppenwechsel Leistungen --------------------------*
DATA: BEGIN OF lerez,
        ebelp  LIKE ekbe-ebelp,
        packno LIKE ekbe-packno,
        introw LIKE ekbe-introw,
        zekkn  LIKE ekbe-zekkn,
      END OF lerez.

*-- Feldleiste f? Gruppenwechsel Konditionen -------------------------*
DATA: BEGIN OF kondz,
        ebeln LIKE ekbz-ebeln,
        ebelp LIKE ekbz-ebelp,
        stunr LIKE ekbz-stunr,
        zaehk LIKE ekbz-zaehk,
      END OF kondz.

*------- BETSKEY ( Tabellenkey ) --------------------------------------*
DATA:   BEGIN OF betskey,
           ebelp LIKE ekpo-ebelp,
           zekkn LIKE ekkn-zekkn,
        END OF betskey.

*------- BETZKEY ( Tabellenkey ) --------------------------------------*
DATA:   BEGIN OF betzkey,
           ebelp LIKE ekpo-ebelp,
           zekkn LIKE ekkn-zekkn,
           lfgja LIKE ekbe-lfgja,
           lfbnr LIKE ekbe-lfbnr,
           lfpos LIKE ekbe-lfpos,
        END OF betzkey.

*------- BETSLKEY ( table key ) --------------------------------"1779814
DATA: BEGIN OF betslkey,                                    "1779814
        ebelp  LIKE ekpo-ebelp,                             "1779814
        packno LIKE ekbe-packno,                            "1779814
        introw LIKE ekbe-introw,                            "1779814
        zekkn  LIKE ekkn-zekkn,                             "1779814
      END OF betslkey.                                      "1779814

*   Tabelle der Reprü-Daten    694091                                  *
DATA:    BEGIN OF t_ref_rseg OCCURS 50.
           INCLUDE STRUCTURE rseg.
DATA:    END OF t_ref_rseg.
*   Verdichtungsdaten          694091                                  *
DATA: BEGIN OF lt_ekbe_sum OCCURS 50.   "needed ekbe data 694091
        INCLUDE STRUCTURE ekbe.
DATA:      END OF lt_ekbe_sum.
DATA: BEGIN OF lt_ekbeh_sum OCCURS 5.   "needed ekbeh data 694091
        INCLUDE STRUCTURE ekbe.
DATA: END OF lt_ekbeh_sum.
DATA: BEGIN OF lr_bet OCCURS 50.
        INCLUDE STRUCTURE ekbe.
DATA:      END OF lr_bet.

*   Key zum Lesen interne Tab. für Bezugsnebenkosten                   *

DATA: BEGIN OF betb_key,
        ebeln             LIKE ekpo-ebeln,
        ebelp             LIKE ekpo-ebelp,
        stunr             LIKE konv-stunr,
        zaehk             LIKE konv-zaehk,
      END OF   betb_key.

*-- Key zum Lesen interne Tab. f? Bezugsnebenkosten ------------------*
DATA: BEGIN OF bzt_key,
        mandt             LIKE ekbz-mandt,
        ebeln             LIKE ekpo-ebeln,
        ebelp             LIKE ekpo-ebelp,
        stunr             LIKE konv-stunr,
        zaehk             LIKE konv-zaehk,
      END OF   bzt_key.

*-- Schluessel TKOMV --------------------------------------------------*
DATA: BEGIN OF tkomvkey,
        mandt LIKE komv-mandt,
        knumv LIKE komv-knumv,
        kposn LIKE komv-kposn,
        stunr LIKE komv-stunr,
        zaehk LIKE komv-zaehk,
      END OF tkomvkey.

*-- Komponenten -------------------------------------------------------*
DATA: BEGIN OF xmdvw OCCURS 50.
        INCLUDE STRUCTURE mdvw.
DATA: END OF xmdvw.

*-- Key zum Lesen der Komponententabelle ------------------------------*
DATA: BEGIN OF mdvwkey,
         matnr LIKE mdvw-matnr,
         werks LIKE mdvw-werks,
      END OF mdvwkey.

*-- Bestellbest?igungen ----------------------------------------------*
DATA: BEGIN OF ets OCCURS 50.
        INCLUDE STRUCTURE uekes.
DATA: END OF ets.

*-- Einkaufsbelegk?fe (f? EKKO-LIFNR bei EKKO-LIFRE wegen Obligo)----*
**-- (nur in der Rechnungspr?ung ben?igt)
*DATA: BEGIN OF XEKKO OCCURS 20,
*         EBELN LIKE EKKO-EBELN,
*         LIFNR LIKE EKKO-LIFNR,
*         LIFRE LIKE EKKO-LIFRE,
*      END OF XEKKO.
*
DATA: BEGIN OF ir_ekko.
        INCLUDE STRUCTURE ekko.
DATA: END OF ir_ekko.

*- Konditionen f? Bezugsnebenkosten (bei neuer Preisfindung im WE) ---*
DATA: BEGIN OF xkonv OCCURS 50.
        INCLUDE STRUCTURE konv.
DATA: END OF xkonv.

*- Konditionsindex Bezugsnebenkosten bei Erfassung in Rechnungspr?ung *
DATA: BEGIN OF bekki OCCURS 50.
        INCLUDE STRUCTURE ekki.
DATA:    stunr LIKE konv-stunr,
         zaehk LIKE konv-zaehk,
      END OF bekki.

*- Tabelle der EKRS-S?ze ---------------------------------------------*
DATA: BEGIN OF tekrs OCCURS 50.
        INCLUDE STRUCTURE ekrs.
DATA: END OF tekrs.


*- Tabelle der KONV-S?ze f? EKBE bei Preisfindung im WE -------------*
DATA: BEGIN OF ukonv OCCURS 50.
        INCLUDE STRUCTURE konv.
DATA: END OF ukonv.

*----- TEKBEV( Tabelle der Bestellentwicklungssaetze f? Verbucher )---*
DATA:   BEGIN OF tekbev OCCURS 50.
        INCLUDE STRUCTURE ekbev.
DATA:   END OF tekbev.

DATA: BEGIN OF read_items OCCURS 10,
         ebeln LIKE ekko-ebeln,
      END OF read_items.

*-- Tabelle der gelesenen Einteilungen --------------------------------*
DATA:   BEGIN OF read_data OCCURS 10,
           ebeln LIKE ekko-ebeln,
           schedules,                    "Einteilungen
           history,                      "Bestellentwicklung
        END OF read_data.

*-- Hilfstabelle mit den WE-Summen (f? Umlagerung Endlieferkennz) ----*
*-- (nicht nur f? Umlagerung, auch f? Abrufdoku beim WE)         ----*
DATA:   BEGIN OF sbets OCCURS 0,
           mandt LIKE ekpo-mandt,
           ebeln LIKE ekpo-ebeln,
           ebelp LIKE ekpo-ebelp,
           wemng LIKE ekbes-wemng,
           wamng LIKE ekbes-wamng,
           glmng LIKE ekbes-glmng,
           waneu LIKE ekbes-wamng,
        END OF sbets.

*-- Hilfstabelle mit den Frachtkosten aus SD-Transportabwicklung ------*
DATA:   BEGIN OF sbetb OCCURS 0,
           mandt LIKE ekpo-mandt,
           ebeln LIKE ekpo-ebeln,
           ebelp LIKE ekpo-ebelp,
           stunr LIKE ekbz-stunr,
           zaehk LIKE ekbz-zaehk,
           vnetw LIKE konv-kwert,
           vmeng LIKE ekbz-menge,
        END OF sbetb.

*-- Hilfstabelle f? update der Grouping/Pegging-Tabellen -------------*
DATA:   BEGIN OF sgrpg OCCURS 0.
        INCLUDE STRUCTURE pgwlint.
DATA:      menge LIKE ekpo-menge,
           wemng LIKE ekpo-menge,
           umrez LIKE ekpo-umrez,
           umren LIKE ekpo-umren,
           elikz LIKE ekpo-elikz,
        END OF sgrpg.

* Tabelle f? ?ergabe Fortschreibung Abrufdoku beim WE
DATA: BEGIN OF sekab OCCURS 0.
        INCLUDE STRUCTURE ekab_gr.
DATA: END OF sekab.

*-- Versanddaten Position ---------------------------------------------*
DATA:    BEGIN OF ptv OCCURS 10.
        INCLUDE STRUCTURE uekpv.
DATA:    END OF ptv.

*-- Tabelle mit Positionen f? Versandindex?derung -------------------*
DATA:    BEGIN OF zupo OCCURS 10.
        INCLUDE STRUCTURE uzupo.
DATA:    END OF zupo.

*--- Lieferplan mit Stammkonditionen:
*--- - Menge = Summe der Einteilungen, die bis heute geliefert werden
*--- - Datum = Planlieferdatum der letzten dieser Einteilungen
*ATA: LPSTAF VALUE ' '. "Vorab f? Keiper Recaro  "ausgeschaltet Klemm

DATA: vorgang LIKE t160-vorga.
DATA: kurstyp LIKE tcurr-kurst VALUE 'M'.                   "TK 4.0BML
DATA: counter LIKE sy-tabix.

*-- Dispsatzvormerkungen ----------------------------------------------*
DATA:    BEGIN OF xmdcp OCCURS 10.                          "3.1G
        INCLUDE STRUCTURE mdcp.
DATA:    END OF xmdcp.

DATA: BEGIN OF db_ekub OCCURS 10.
        INCLUDE STRUCTURE ekub.
DATA: END OF db_ekub.

DATA: BEGIN OF db_ekub_d OCCURS 10.
        INCLUDE STRUCTURE ekub.
DATA: END OF db_ekub_d.

*-- Hilfstabelle zum Sortieren der Bestellpositionen-------------------*
DATA:    BEGIN OF h_xebefu OCCURS 10.
        INCLUDE STRUCTURE ebefu.
DATA:          sort_ean11 LIKE ebefu-ean11,
               sort_matnr LIKE ebefu-matnr,
               sort_idnlf LIKE ebefu-idnlf,
               sort_matkl LIKE ebefu-matkl.
DATA:    END OF h_xebefu.
DATA:    BEGIN OF h_xbbefu OCCURS 10.
        INCLUDE STRUCTURE bbefu.
DATA:          sort_ean11 LIKE bbefu-ean11,
               sort_matnr LIKE bbefu-matnr,
               sort_matkl LIKE bbefu-matkl.
DATA:    END OF h_xbbefu.
DATA: h_ean11 LIKE ebefu-ean11.
DATA: h_matnr LIKE ebefu-matnr.
DATA: h_idnlf LIKE ebefu-idnlf.
DATA: h_matkl LIKE ebefu-matkl.
DATA: h_ebeln LIKE ebefu-ebeln.
DATA: h_ebelp LIKE ebefu-ebelp.
DATA: xek08rn_tfill LIKE sy-tfill.
DATA: xek08bn_tfill LIKE sy-tfill.

INCLUDE leinrd01.          "Datendefinition: WE/RE (parallele W?rungen)
* Daten f? Rechnungsplan
DATA: gesamtnetwr LIKE fplt-fakwr.  "Gesamtnettowert des Rechnungsplans

DATA: old_ebeln LIKE ebefu-ebeln,
      old_ebelp LIKE ebefu-ebelp.

DATA: xrevfl.                    "--> Neue Stornologik f? Konditionen
*----------------------------------------------------------------------*
*--- LSA Begin Retrofit Brasilien -------------------------------------*
*----------------------------------------------------------------------*
DATA: j_1a_bldat_save LIKE bkpf-bldat.
*----------------------------------------------------------------------*
*--- LSA Ende Retrofit Brasilien --------------------------------------*
*----------------------------------------------------------------------*
* Archivierungsdatum wegen EURO-Umsetzung    TK 4.0B
DATA: archive_date LIKE sy-datlo.             "TK 4.0B EURO
************************************************************************
* Selektion von Bestellungen (RoFi46a)                                 *
************************************************************************
TYPE-POOLS: rsds,
            rsfs.
*------- Tabelle der Unterpositionen ----------------------------------*
DATA: BEGIN OF upot OCCURS 10.
        INCLUDE STRUCTURE ekpo.
DATA: END OF upot.
*------- Tabelle der 훞derungsbelegstruktur ---------------------------*
DATA: BEGIN OF yeket OCCURS 20.
        INCLUDE STRUCTURE ueket.
DATA: END OF yeket.
*------- Tabelle der Einteilungen -------------------------------------*
DATA: BEGIN OF yett OCCURS 10.
        INCLUDE STRUCTURE beket.
DATA: END OF yett.
*------- ADOS ( Tabelle der Summen zur Abrufdoku ) --------------------*
DATA:    ekabs_suwrt LIKE ekko-ktwrt.
*------- Position ablehnen --------------------------------------------*
DATA: reject.
*------- Kennzeichen f? Selektivit? ---------------------------------*
DATA: selk,                            "Kopf
      selp.                            "Position.
*------- Kennzeichen f? Zus?zliche Zugriffe -------------------------*
DATA: ekabks,                          "Selektion Abrufdoku Kopf
      ekabps,                          "Selektion Abrufdoku Position
      eketps,                          "Selektion Einteilungen Position
      ekbeps,                          "Selektion Bestellentw. Position
      lfa1ks.                          "Selektion Lieferant Kopf
*------- Hilfsfelder Selektion ----------------------------------------*
DATA: vfeld1(11) TYPE p,               "Vergleichsfeld
      vfeld2(11) TYPE p.               "Vergleichsfeld
*------- Waehrung -----------------------------------------------------*
DATA: BEGIN OF t001key,
        mandt LIKE t001-mandt,
        bukrs LIKE t001-bukrs.
DATA: END   OF t001key.
DATA: BEGIN OF it001 OCCURS 0.
        INCLUDE STRUCTURE t001.
DATA: END   OF it001.
* flag for new logic to determine invoice value for GR   "215075
DATA: gf_new_logic VALUE ' '.   "old logic is on         "215075
*BAdi Declaration for India
CLASS: cl_ex_me_cin_leinrf2v DEFINITION LOAD.
DATA: me_leinrf2v TYPE REF TO if_ex_me_cin_leinrf2v.
*
CLASS: cl_ex_me_cin_leinrf2r DEFINITION LOAD.
DATA: me_leinrf2r TYPE REF TO if_ex_me_cin_leinrf2r.
*
TABLES: t005.
*Badi Declaration for India

DATA: lfdat_ab  LIKE  rbkp_v-lfdatabli,
      lfdat_bis LIKE  rbkp_v-lfdatbisli,
      re_waers  LIKE  bkpf-waers.
RANGES: r_budat FOR ekbe-budat OCCURS 10.

*---------------------------------------------------------------------**
*> 물류송장검증 BAPIs Function용
*---------------------------------------------------------------------**

*---------------------------------------------------------------------**
* Data: Includes for internal tables, fields, constants etc.
*---------------------------------------------------------------------**
INCLUDE mrm_const_mrm.
INCLUDE mrm_const_me.
INCLUDE mrm_const_common.

CONSTANTS:                                                  "TM EhP5e
  c_tab_rbkp     TYPE tabname   VALUE 'RBKP',

  c_field_lifnr  TYPE fieldname VALUE 'LIFNR',
  c_field_budat  TYPE fieldname VALUE 'BUDAT',
  c_field_bldat  TYPE fieldname VALUE 'BLDAT',
  c_field_cpudt  TYPE fieldname VALUE 'CPUDT',
  c_field_ername TYPE fieldname VALUE 'ERNAME',
  c_field_xblnr  TYPE fieldname VALUE 'XBLNR'.
*---------------------------------------------------------------------*
*         Types                                                       *
*---------------------------------------------------------------------*

TYPE-POOLS:
    mmcr,
    mrm.
TYPES:
    mrm_tab_return TYPE bapiret2 OCCURS 1.

*------- structure of export table HeaderList from BAPI GetList
TYPES: BEGIN OF mrm_headerlist,
          belnr  LIKE rbkp-belnr,
          gjahr  LIKE rbkp-gjahr,
          budat  LIKE rbkp-budat,
          bldat  LIKE rbkp-bldat,
          cpudt  LIKE rbkp-cpudt,
          cputm  LIKE rbkp-cputm,
          bukrs  LIKE rbkp-bukrs,
          rmwwr  LIKE rbkp-rmwwr,
          waers  LIKE rbkp-waers,
          lifnr  LIKE rbkp-lifnr,
          xblnr  LIKE rbkp-xblnr,
          bktxt  LIKE rbkp-bktxt,
          ername LIKE rbkp-ername,
          rbstat LIKE rbkp-rbstat,
          xtm    LIKE rbkpb-xtm.                            "TM EhP5e
TYPES: END OF mrm_headerlist.

TYPES: mrm_tab_headerlist TYPE mrm_headerlist OCCURS 10.

*------ structure of service entry sheet-data
TYPES: BEGIN OF mrm_lfbdata,
         lfbnr  LIKE essr-lblni,
         lfgja  LIKE ekbe-lfgja,
         lfpos  LIKE eskl-lfpos,
         packno LIKE eskl-packno,
         introw LIKE eskl-introw,
       END OF mrm_lfbdata.

*--- help structure to fill table COBL_MRM ----------------------------*
TYPES: BEGIN OF mrm_acc_cobl,
         saknr      TYPE saknr,
         kostl      TYPE kostl,
         vbeln      TYPE vbeln,
         vbelp      TYPE vbelp,
         anln1      TYPE anln1,
         anln2      TYPE anln2,
         aufnr      TYPE aufnr,
         dabrz      TYPE dabrbez,
         fistl      TYPE fistl,
         geber      TYPE bp_geber,
         budget_pd  TYPE fm_budget_period,
         grant_nbr  TYPE gm_grant_nbr,
         gsber      TYPE gsber,
         imkey      TYPE imkey,
         kokrs      TYPE kokrs,
         kstrg      TYPE kstrg,
         paobjnr    TYPE rkeobjnr,
         prctr      TYPE prctr,
         ps_psp_pnr TYPE ps_psp_pnr,
         fkber      TYPE fkber,
         fipos      TYPE fipos,
         fmfgus_key     TYPE fmfg_us_key,    "3211350-Include US Fed hash key
*----------------------------------------------------------------------*
* Invoice verification as separated consumption, KBLNR and KBLPOS will
* be available only if switch fmre_inv_consumption is active and if the
*company code is active for invoice consumption
*----------------------------------------------------------------------*
         kblnr      TYPE kblnr,
         kblpos     TYPE kblpos,
*----------------------------------------------------------------------*
* --> END Invoice verification as separated consumption
*----------------------------------------------------------------------*
         aufpl      TYPE co_aufpl,
         aplzl      TYPE co_aufpl,
         abper          TYPE abper_rf,       "1682363
       END OF mrm_acc_cobl.

DATA: g_documentdate TYPE  bldat.

*> 비용이력용.
DATA: g_print             TYPE lvc_s_prnt.
DATA: g_layout            TYPE lvc_s_layo.
DATA: gs_stable           TYPE lvc_s_stbl.
DATA: g_variant           LIKE disvariant.
DATA: gx_variant          LIKE disvariant.
DATA: g_variant_save.
DATA: p_variant           LIKE disvariant-variant.
DATA: it_fieldcat_lvc     TYPE lvc_t_fcat WITH HEADER LINE.
DATA: it_dynpread         LIKE dynpread OCCURS 0 WITH HEADER LINE.
DATA  g_user_specific.
DATA: gt_sort_lvc         TYPE lvc_t_sort WITH HEADER LINE.
DATA: gt_filt_lvc         TYPE lvc_t_filt WITH HEADER LINE.

DATA: g_scr2127_grid      TYPE REF TO cl_gui_alv_grid,
      g_scr2127_container TYPE REF TO cl_gui_custom_container.
DATA: g_scr0600_grid      TYPE REF TO cl_gui_alv_grid,
      g_scr0600_container TYPE REF TO cl_gui_custom_container.
DATA: g_repid             LIKE sy-repid  VALUE
                               'SAPLZ_TI_COMMON_FUNCTIONS'.

************************************************************************
* CLASSES: Definition                                                  *
************************************************************************
CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_hotspot_click
         FOR EVENT hotspot_click OF cl_gui_alv_grid
              IMPORTING e_row_id
                        e_column_id
                        es_row_no,

      handle_data_changed
         FOR EVENT data_changed OF cl_gui_alv_grid
             IMPORTING er_data_changed,

      handle_data_changed_finished
          FOR EVENT data_changed_finished OF cl_gui_alv_grid
              IMPORTING e_modified,

      handle_double_click
           FOR EVENT double_click OF cl_gui_alv_grid
               IMPORTING e_row e_column,

      handle_button_click
           FOR EVENT button_click OF cl_gui_alv_grid
               IMPORTING es_col_id es_row_no,

      handle_user_command
           FOR EVENT user_command OF cl_gui_alv_grid
               IMPORTING e_ucomm,

      handle_before_user_command
            FOR EVENT before_user_command OF cl_gui_alv_grid
                IMPORTING e_ucomm,

      handle_after_user_command
            FOR EVENT after_user_command OF cl_gui_alv_grid
                IMPORTING e_ucomm,

      handle_context_menu_request
           FOR EVENT context_menu_request OF cl_gui_alv_grid
               IMPORTING e_object,

      handle_toolbar
           FOR EVENT toolbar OF cl_gui_alv_grid
               IMPORTING e_object e_interactive,
*               IMPORTING sender e_object e_interactive,

      handle_print_top_of_page
           FOR EVENT print_top_of_page OF cl_gui_alv_grid,

      handle_print_top_of_list
           FOR EVENT print_top_of_list OF cl_gui_alv_grid,

      handle_print_end_of_page
           FOR EVENT print_end_of_page OF cl_gui_alv_grid,

      handle_print_end_of_list
           FOR EVENT print_end_of_list OF cl_gui_alv_grid,

      handle_top_of_page
           FOR EVENT top_of_page OF cl_gui_alv_grid
               IMPORTING e_dyndoc_id,

      handle_end_of_list
           FOR EVENT end_of_list OF cl_gui_alv_grid
               IMPORTING e_dyndoc_id.

ENDCLASS.                    "lcl_event_receiver DEFINITION

************************************************************************
* CLASSES: IMPLEMENTATION                                              *
************************************************************************
CLASS lcl_event_receiver IMPLEMENTATION.

  METHOD handle_hotspot_click.
    PERFORM handle_hotspot_click IN PROGRAM (g_repid)
                                 USING e_row_id e_column_id.
  ENDMETHOD.                    "hotspot_click

  METHOD handle_data_changed.
    PERFORM handle_data_changed IN PROGRAM (g_repid)
                                USING er_data_changed.
  ENDMETHOD.                    "handle_data_changed

  METHOD handle_data_changed_finished.
    PERFORM  handle_data_changed_finished IN PROGRAM (g_repid)
                  USING e_modified.
  ENDMETHOD.                    "handle_data_changed_finished

  METHOD handle_double_click.
    PERFORM  handle_double_click IN PROGRAM (g_repid)
                                 USING e_row e_column.
  ENDMETHOD.                    "handle_double_click

  METHOD handle_button_click.
    PERFORM  handle_button_click IN PROGRAM (g_repid)
                                 USING es_col_id es_row_no.
  ENDMETHOD.                    "handle_button_click

  METHOD handle_user_command.
    PERFORM  handle_user_command_grid IN PROGRAM (g_repid)
                                      USING e_ucomm.
  ENDMETHOD.                    "handle_user_command

  METHOD handle_before_user_command.
    PERFORM  handle_before_user_comm IN PROGRAM (g_repid)
                                     USING e_ucomm.
  ENDMETHOD.                    "handle_before_user_command

  METHOD handle_after_user_command.
    PERFORM  handle_after_user_comm IN PROGRAM (g_repid)
                                    USING e_ucomm.
  ENDMETHOD.                    "handle_after_user_command

  METHOD handle_context_menu_request.
    PERFORM  handle_context_menu IN PROGRAM (g_repid)
                                 USING e_object.
  ENDMETHOD.                    "handle_context_menu_request

  METHOD handle_toolbar.
    PERFORM  handle_toolbar IN PROGRAM (g_repid)
*                            USING e_object.
                            USING  e_object e_interactive.
  ENDMETHOD.                    "handle_toolbar

  METHOD handle_print_top_of_page.
    PERFORM  handle_print_top_of_page IN PROGRAM (g_repid).
  ENDMETHOD.                    "handle_print_top_of_page

  METHOD handle_print_top_of_list.
    PERFORM  handle_print_top_of_list IN PROGRAM (g_repid).
  ENDMETHOD.                    "handle_print_top_of_list

  METHOD handle_print_end_of_page.
    PERFORM  handle_print_end_of_page IN PROGRAM (g_repid).
  ENDMETHOD.                    "handle_print_end_of_page

  METHOD handle_print_end_of_list.
    PERFORM  handle_print_end_of_list IN PROGRAM (g_repid).
  ENDMETHOD.                    "handle_print_end_of_list

  METHOD handle_top_of_page.
    PERFORM  handle_top_of_page IN PROGRAM (g_repid) USING e_dyndoc_id.
  ENDMETHOD.                    "handle_top_of_page

  METHOD handle_end_of_list.
    PERFORM  handle_end_of_list IN PROGRAM (g_repid) USING e_dyndoc_id.
  ENDMETHOD.                    "handle_end_of_list

ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION

DATA: event_receiver TYPE REF TO lcl_event_receiver.

*----------------------------------------------------------------------*
*> declaration of tablecontrol 'TC_7000' itself
*----------------------------------------------------------------------*
CONTROLS: tc_7000 TYPE TABLEVIEW USING SCREEN 7000.

*> lines of tablecontrol 'TC_7000'
DATA:     g_tc_7000_lines  LIKE sy-loopc,
          g_tc_7000_copied.
*----------------------------------------------------------------------*

INCLUDE lmrm_bapid01.                                     "DPC EhP4
INCLUDE lmrm_bapid02.                                     "TM EhP5e
INCLUDE lmrm_bapid03.                                     "1654740
INCLUDE lmrm_bapid04.
INCLUDE lmrm_bapid05.
INCLUDE lmrm_bapid06.

INCLUDE lmrm_bapif02.
INCLUDE lmrm_bapif03.
INCLUDE lmrm_bapif07.
INCLUDE lmrm_bapif08.
INCLUDE lmrm_bapif09.
INCLUDE lmrm_bapif0b.
INCLUDE lmrm_bapif0c.
INCLUDE lmrm_bapif0r.
INCLUDE lmrm_bapif0z.
INCLUDE lmrm_bapif11.
INCLUDE lmrm_bapif15.
INCLUDE lmrm_bapif16.
INCLUDE lmrm_bapif20.
INCLUDE lmrm_bapif21.
INCLUDE lmrm_bapif22.
INCLUDE lmrm_bapif23.
INCLUDE lmrm_bapif24.
INCLUDE lmrm_bapif25.
INCLUDE lmrm_bapif40.
INCLUDE lmrm_bapif43.
INCLUDE lmrm_bapif46.

INCLUDE lmrm_bapip01.
INCLUDE lmrm_bapip05.
INCLUDE lmrm_bapip10.
INCLUDE lmrm_bapip11.
