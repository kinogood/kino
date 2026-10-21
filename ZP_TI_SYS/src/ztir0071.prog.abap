************************************************************************
*                                                                      *
* Title         : ZTIR0030                                             *
*                                                                      *
* Description   : [Report] 수입요청 승인 관리                          *
*                                                                      *
* Creation Date : 2004/02/04                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*                                                                      *
* Inputs        :                                                      *
*                                                                      *
* Outputs       :                                                      *
*                                                                      *
************************************************************************
*                                                                      *
* Processing Steps:                                                    *
*   1.                                                                 *
*                                                                      *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
*                                                                      *
*                                                                      *
************************************************************************
PROGRAM   ztir0030
          MESSAGE-ID zmti00
          NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: slis.   "> Globale Type(ALV)

************************************************************************
* User Included                                                        *
************************************************************************
INCLUDE zts_reuse_bdc_subroutine_f00.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    type c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* Internal Tables                                                      *
************************************************************************

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: t001,      ">Company Codes
        t001w,     ">Plants/Branches
        t001k,     ">Valuation area
        t161,      ">Purchasing Document Types
        t134,      ">Material Types
        t134t,     ">Material Types Descriptions
        t024d,     ">MRP controllers
        mara,      ">General Material Data
        marc,      ">Plant Data for Material
        mard,      ">Storage Location Data for Material
        mslb,      ">Special Stocks with Vendor
        mbew,      ">Material Valuation
        march,     ">Plant Data for Material: History
        mardh,     ">Storage Location Data for Material: History
        mslbh,     ">Special Stocks with Vendor: History
        mbewh,     ">Material Valuation: History
        mkpf,      ">Header: Material Document
        mseg,      ">Document Segment: Material
        makt,      ">Material Descriptions
        ztitig00,  ">회사별 프로세스 정의
        marm,      ">Units of Measure for Material
        lfa1  ,    ">Vendor Master (General Section)
        lfb1  ,    ">Vendor Master (Company Code)
        t024e ,    ">Purchasing Organizations
        t024  ,    ">Purchasing Groups
        t163b ,    ">TEXT
        t163c ,    ">TEXT
        t685t ,    ">TEXT
        ztitrqk,
        ztitrqs,
        ekbz  ,    ">History per Purchasing Document: Delivery Costs
        ekbe  ,    ">History per Purchasing Document
        ekko,      ">Purchasing Document Header
        ekpo  ,    ">Purchasing Document Items
        ekkn,      ">Account Assignment in Purchasing Document
        dfies ,    ">DD Interface: Table Fields for DDIF_FIELDINFO_GET
        spop  ,    ">POPUP_TO_CONFIRM_... function 모듈 팝업화면 필드.
        ztisscrcom, ">수출입시스템 Screen용 Structure(공용)
        ztivrq02.  ">header + status Views

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 KSH --------------------------------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 KSH --------------------------------------
    c_save(1)   TYPE  c             VALUE 'A',
    c_error     TYPE  c             VALUE 'E'.

DATA: BEGIN OF it_reqno OCCURS 1,
      reqno    TYPE ztireqno,
      amdsq    TYPE ztiamdsq,
      retxt    TYPE ztiretxt,
      END   OF it_reqno.

DATA:
       gs_events   TYPE slis_alv_event,
       gt_events   TYPE slis_t_event,
       gs_gridset  TYPE lvc_s_glay.


************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ztitrqk-bukrs
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk,           "회사코드.
  s_ekorg  FOR ztitrqk-ekorg,                  "구매조직.
  s_ekgrp  FOR ztitrqk-ekgrp,                  "구매그룹.
  s_reqno  FOR ztitrqk-reqno                   "수입의뢰 관리번호.
                    MEMORY ID ztireqno,
  s_amdsq  FOR ztitrqs-amdsq                   "Amend 차수.
                    MEMORY ID ztiamdsq,
  s_reqty  FOR ztitrqk-reqty,                  "수입의뢰 종류.
  s_ilcty  FOR ztitrqk-ilcty,                  "신용장 종류.
  s_lifnr  FOR ztitrqk-lifnr,                  "공급업체 계정번호.
  s_reqdt  FOR ztitrqs-reqdt MODIF ID req,     "개설희망일자.
  s_appun  FOR ztitrqs-appun MODIF ID req,     "개설의뢰 요청자.
  s_appdt  FOR ztitrqs-appdt MODIF ID req,     "개설의뢰 요청일.
  s_accun  FOR ztitrqs-accun MODIF ID apy,     "요청접수 담당자.
  s_accdt  FOR ztitrqs-accdt MODIF ID apy,     "요청접수일자.
  s_sndun  FOR ztitrqs-sndun MODIF ID sed,     "개설신청자.
  s_snddt  FOR ztitrqs-snddt MODIF ID sed,     "개설신청일.
  s_rcvun  FOR ztitrqs-rcvun MODIF ID opn,     "개설등록자.
  s_rcvdt  FOR ztitrqs-rcvdt MODIF ID opn.     "개설등록일자.
SELECTION-SCREEN ULINE.
PARAMETERS: p_step1 RADIOBUTTON GROUP ab1  DEFAULT 'X'  MODIF ID m1,
            p_step2 RADIOBUTTON GROUP ab1               MODIF ID m1,
            p_step3 RADIOBUTTON GROUP ab1               MODIF ID m1.

SELECTION-SCREEN ULINE.
SELECT-OPTIONS:
  s_lifre  FOR ztitrqk-lifre,                  "다른 송장발행처.
  s_offer  FOR ztitrqk-offer,                  "오퍼상(Offer).
  s_opnbk  FOR ztitrqk-opnbk MODIF ID sed,     "개설은행.
  s_zterm  FOR ztitrqs-zterm,                  "지급조건키.
  s_waers  FOR ztitrqs-waers,                  "개설통화.
  s_inco1  FOR ztitrqs-inco1,                  "인도조건 (파트 1).
  s_exdat  FOR ztitrqs-exdat,                  "유효기일.
  s_lsdat  FOR ztitrqs-lsdat,                  "최종선적일자.
  s_fland  FOR ztitrqs-fland,                  "선적국가.
  s_fport  FOR ztitrqs-fport,                  "선적항.
  s_opnno  FOR ztitrqs-opnno MODIF ID opn,     "수입개설번호
  s_opndt  FOR ztitrqs-opndt MODIF ID opn,     "개설일자.
  s_cnam   FOR ztitrqs-cnam,                   "작성인.
  s_cdat   FOR ztitrqs-cdat,                   "생성일.
  s_unam   FOR ztitrqs-unam,                   "최종변경인.
  s_udat   FOR ztitrqs-udat.                   "변경일.

PARAMETERS: p_full RADIOBUTTON GROUP ab2 DEFAULT 'X',
            p_list RADIOBUTTON GROUP ab2.
SELECTION-SCREEN END OF BLOCK box1.

*> Report variant
SELECTION-SCREEN: BEGIN OF BLOCK alv WITH FRAME TITLE text-003.
PARAMETERS: alv_def LIKE disvariant-variant.
SELECTION-SCREEN: END OF BLOCK alv.



************************************************************************
* Internal Tables                                                      *
************************************************************************
*> 공급업체명
DATA : BEGIN OF xlfa1 OCCURS 0,
       lifnr           LIKE   lfa1-lifnr,
       name1           LIKE   lfa1-name1.
DATA : END   OF xlfa1.


DATA: it_fieldcat_g TYPE lvc_t_fcat,
      gs_fieldcat_g LIKE LINE OF it_fieldcat_g.

*---------------------------------------------------------------------*
*> Message dialog box용                                               *
*---------------------------------------------------------------------*
DATA: BEGIN OF it_msg  OCCURS 0.
        INCLUDE STRUCTURE ztismessage.
DATA: END   OF it_msg.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
*---------------------------------------------------------------------
* Accumulators
*---------------------------------------------------------------------
*DATA:
*  BEGIN OF A,
*
*  END OF A.
*
*
*----------------------------------------------------------------------
* Switches
*----------------------------------------------------------------------
DATA: BEGIN OF fc_struct,
        tabname(7),
        fieldname(6),
        ref_tabname(29),
        ref_fieldname(6),
        no_out(1),
        cqindicator(1),
        cqfield(6),
      END OF fc_struct.

DATA: s_variant      LIKE  disvariant,
      s_var_usr      LIKE  disvariant.

*----------------------------------------------------------------------
* Work fields
*----------------------------------------------------------------------
DATA : g_line          TYPE   i,             "Line counter
       g_subrc         LIKE   sy-subrc,      "Return code
       g_tabix         LIKE   sy-tabix,      "table index
       g_line1(3)      TYPE   n,             "LINE COUNT
       g_out_text(70)  TYPE   c,             "text field(display)
       g_err_mode      TYPE   c,
       line_cnt(02)    TYPE   n,
       ok-code         LIKE   sy-ucomm,
       field_name(20),
       field_name1(20).

* Global variables for handling ALV functionality
DATA: alv_keyinfo      TYPE slis_keyinfo_alv.
DATA: alv_variant      LIKE disvariant.
DATA: gs_layout        TYPE slis_layout_alv.
DATA: alv_repid        LIKE sy-repid.
DATA: alv_print        TYPE slis_print_alv.
DATA: st_sort          TYPE slis_sortinfo_alv.

DATA: alv_detail_func(30).
DATA: fc       TYPE slis_t_fieldcat_alv,
      fc1      TYPE slis_t_fieldcat_alv,
      fcs      TYPE slis_fieldcat_alv,
      it_sort  TYPE slis_t_sortinfo_alv.

************************************************************************
* RANGES
************************************************************************
*RANGES:
*   XXXT FOR XXX-XXX OCCURS 1.

***********************************************************************
* FIELD-GROUPS
***********************************************************************
*FIELD-GROUPS:

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
*  FC_STRUCT         = &1.
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

************************************************************************
*                                                                      *
* INITIALIZATION Event                                                 *
*                                                                      *
************************************************************************
INITIALIZATION.
  PERFORM  set_initial_data.
  PERFORM  set_alv_init.             ">Initialize ALV variable

************************************************************************
*                                                                      *
* AT SELECTION-SCREEN Events                                           *
*                                                                      *
************************************************************************
*>The layout determines the list format
AT SELECTION-SCREEN ON VALUE-REQUEST FOR alv_def.
  PERFORM exec_alv_f4.

AT SELECTION-SCREEN.
  PERFORM input_field_check.
  PERFORM alv_variant_check.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING s_bukrs-low.
** JS전선 회사코드 2007/04 KSH --------------------------------------

AT SELECTION-SCREEN OUTPUT.

************************************************************************
*                                                                      *
* START-OF-SELECTION Event                                             *
*                                                                      *
************************************************************************
START-OF-SELECTION.
  PERFORM clearing_work_area.      ">Initialize internal table
  PERFORM set_fieldcat_build.      ">Set ALV field category
  PERFORM create_dynamic_table.    ">
  PERFORM get_data_for_display.    ">data select

************************************************************************
*                                                                      *
* END-OF-SELECTION Event                                               *
*                                                                      *
************************************************************************
END-OF-SELECTION.
  CHECK g_line NE 0.
*>--------------------------------------------------------
*> PROGRESS INDICATOR DISPLAY.
*>  4.  LIST DISPLAY
*>--------------------------------------------------------
  g_line1 = 100.
  g_out_text = text-905.
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM set_progress_bar USING g_out_text g_line1.
  PERFORM set_colorize_build.       ">Set color
*  PERFORM set_event_form           ">Set ALV Use-event
*            USING : slis_ev_data_changed  slis_ev_data_changed.
  PERFORM set_sort_field.           ">Set ALV sort fields
  PERFORM display_alv_list.         ">Call ALV Functions

************************************************************************
*                                                                      *
* TOP-OF-PAGE Event                                                    *
*                                                                      *
************************************************************************
TOP-OF-PAGE.

************************************************************************
*                                                                      *
* END-OF-PAGE Event                                                    *
*                                                                      *
************************************************************************
END-OF-PAGE.


************************************************************************
*                                                                      *
* TOP-OF-PAGE DURING LINE-SELECTION Event                              *
*                                                                      *
************************************************************************
TOP-OF-PAGE DURING LINE-SELECTION.


************************************************************************
*                                                                      *
* AT LINE-SELECTION Event                                              *
*                                                                      *
************************************************************************
AT LINE-SELECTION.


************************************************************************
*                                                                      *
* AT USER-COMMAND Event                                                *
*                                                                      *
************************************************************************
AT USER-COMMAND.


*eject
************************************************************************
*                                                                      *
* S U B R O U T I N E S                                                *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  SET_INITIAL_DATA
*&---------------------------------------------------------------------*
FORM set_initial_data.

  SET TITLEBAR 'T1000'.

*  FREE: s_bukrs.
*  CLEAR: s_bukrs, ztitig00.
*
*  s_bukrs-sign   = 'I'.
*  s_bukrs-option = 'EQ'.
*  GET PARAMETER ID 'BUK' FIELD s_bukrs-low.
**  s_bukrs-low    = c_bukrs.
*  IF NOT s_bukrs-low IS INITIAL.
*    APPEND s_bukrs.
*
*    SELECT SINGLE *
*      FROM ztitig00
*     WHERE bukrs EQ s_bukrs-low.
*  ENDIF.

  alv_repid = sy-repid.
  CLEAR s_variant.
  s_variant-report = sy-repid.

* Get default variant
  s_var_usr = s_variant.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = c_save
    CHANGING
      cs_variant = s_var_usr
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    alv_def =  s_var_usr-variant.
  ENDIF.

ENDFORM.                    " SET_INITIAL_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_PROGRESS_BAR
*&---------------------------------------------------------------------*
FORM set_progress_bar USING   text perc.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = perc
      text       = text.

ENDFORM.                    " SET_PROGRESS_BAR
*&---------------------------------------------------------------------*
*&      Form  INPUT_FIELD_CHECK
*&---------------------------------------------------------------------*
FORM input_field_check.

  DATA: l_bukrs   LIKE t001-bukrs,
        l_werks   LIKE t001w-werks,
        l_matnr   LIKE mara-matnr,
        l_mtart   LIKE t134-mtart,
        l_ebeln   LIKE ekko-ebeln,
        l_lifnr   LIKE lfa1-lifnr,
        l_ekorg   LIKE t024e-ekorg,
        l_ekgrp   LIKE t024-ekgrp.

* Company code
  SELECT *
    FROM t001 UP TO 1 ROWS
   WHERE bukrs IN s_bukrs.
  ENDSELECT.
  IF sy-subrc <> 0.
    PERFORM get_ftext(rddfie00) USING 'T001' 'BUKRS' sy-langu
                                CHANGING dfies g_subrc.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE e348(m7) WITH  dfies-scrtext_m.
  ELSE.

    SELECT SINGLE *
      FROM ztitig00
     WHERE bukrs EQ t001-bukrs.
    IF sy-subrc NE 0.
      MESSAGE e035 WITH t001-bukrs.
    ENDIF.

    IF ztitig00-rqrls NE 'X'.
      MESSAGE e166 WITH t001-butxt.
    ENDIF.

  ENDIF.

* Vendor
  READ TABLE s_lifnr INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT lifnr INTO (l_lifnr)
                 FROM lfb1 UP TO 1 ROWS WHERE lifnr IN s_lifnr
                                        AND   bukrs IN s_bukrs.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'LFA1' 'LIFNR' sy-langu
                                  CHANGING dfies g_subrc.
      SET CURSOR FIELD 'S_LIFNR-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

* Purchase Organization
  READ TABLE s_ekorg INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT ekorg INTO (l_ekorg)
                 FROM t024e UP TO 1 ROWS WHERE ekorg IN s_ekorg.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'T024E' 'EKORG' sy-langu
                                  CHANGING dfies g_subrc.
      SET CURSOR FIELD 'S_EKORG-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

* Purchase GROUP
  READ TABLE s_ekgrp INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    SELECT ekgrp INTO (l_ekgrp)
                 FROM t024 UP TO 1 ROWS WHERE ekgrp IN s_ekgrp.
    ENDSELECT.
    IF sy-subrc <> 0.
      PERFORM get_ftext(rddfie00) USING 'T024' 'EKGRP' sy-langu
                                  CHANGING dfies g_subrc.
      SET CURSOR FIELD 'S_EKGRP-LOW'.
      MESSAGE e348(m7) WITH dfies-scrtext_m.
    ENDIF.
  ENDIF.

ENDFORM.                    " INPUT_FIELD_CHECK
*&---------------------------------------------------------------------*
*&      Form  CLEARING_WORK_AREA
*&---------------------------------------------------------------------*
FORM clearing_work_area.

  FREE:  xlfa1.
  CLEAR: xlfa1.

  IF p_full EQ 'X'.
    alv_detail_func = 'REUSE_ALV_GRID_DISPLAY'.
  ELSE.
    alv_detail_func = 'REUSE_ALV_LIST_DISPLAY'.
  ENDIF.

ENDFORM.                    " CLEARING_WORK_AREA
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_FOR_DISPLAY
*&---------------------------------------------------------------------*
FORM get_data_for_display.

  RANGES: lr_docst   FOR   ztitrqs-docst OCCURS 1,
          lr_rqrls   FOR   ztitrqs-rqrls OCCURS 1,
          lr_retns   FOR   ztitrqs-retns OCCURS 1.

*  DATA : l_rqrls type c.

  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.
  FIELD-SYMBOLS: <l_ebeln>.
  FIELD-SYMBOLS: <l_ddtext>.
  FIELD-SYMBOLS: <l_ilcty>.
  FIELD-SYMBOLS: <l_text2>.
  FIELD-SYMBOLS: <l_pagrt>.
  FIELD-SYMBOLS: <l_reqty>.


  REFRESH : <gt_table>.
*> PROGRESS Display.
  g_line1    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_line1.

  CASE 'X'.
    WHEN p_step1.   ">의뢰대상
      CLEAR lr_rqrls .
      MOVE: 'I'     TO    lr_rqrls-sign,
            'NE'    TO    lr_rqrls-option.
      MOVE: 'X'     TO    lr_rqrls-low.    APPEND lr_rqrls .
      CLEAR: lr_retns.
      MOVE: 'I'     TO    lr_retns-sign,
            'EQ'    TO    lr_retns-option.
      MOVE: space   TO    lr_retns-low.    APPEND lr_retns .
    WHEN p_step2.   ">접수대상
      CLEAR lr_rqrls .
      MOVE: 'I'     TO    lr_rqrls-sign,
            'EQ'    TO    lr_rqrls-option.
      MOVE: 'X'     TO    lr_rqrls-low.    APPEND lr_rqrls .
    WHEN p_step3.
      CLEAR: lr_retns.
      MOVE: 'I'     TO    lr_retns-sign,
            'EQ'    TO    lr_retns-option.
      MOVE: 'X'     TO    lr_retns-low.    APPEND lr_retns .
  ENDCASE.

*> 수입의뢰 데이타 select.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE <gt_table>
    FROM ztivrq04
   WHERE bukrs  IN  s_bukrs        "회사코드.
     AND ekorg  IN  s_ekorg        "구매조직.
     AND ekgrp  IN  s_ekgrp        "구매그룹.
     AND reqno  IN  s_reqno        "수입의뢰 관리번호.
     AND amdsq  IN  s_amdsq        "Amend 차수.
     AND reqty  IN  s_reqty        "수입의뢰 종류.
     AND ilcty  IN  s_ilcty        "신용장 종류.
     AND lifnr  IN  s_lifnr        "공급업체 계정번호.
     AND lifre  IN  s_lifre        "다른 송장발행처.
     AND offer  IN  s_offer        "오퍼상(Offer).
     AND opnbk  IN  s_opnbk        "개설은행.
     AND zterm  IN  s_zterm        "지급조건키.
     AND waers  IN  s_waers        "개설통화.
     AND inco1  IN  s_inco1        "인도조건 (파트 1).
     AND exdat  IN  s_exdat        "유효기일.
     AND lsdat  IN  s_lsdat        "최종선적일자.
     AND fland  IN  s_fland        "선적국가.
     AND fport  IN  s_fport        "선적항.
     AND reqdt  IN  s_reqdt        "개설희망일자.
     AND appun  IN  s_appun        "개설의뢰 요청자.
     AND appdt  IN  s_appdt        "개설의뢰 요청일.
     AND accun  IN  s_accun        "요청접수 담당자.
     AND accdt  IN  s_accdt        "요청접수일자.
     AND sndun  IN  s_sndun        "개설신청자.
     AND snddt  IN  s_snddt        "개설신청일.
     AND rcvun  IN  s_rcvun        "개설등록자.
     AND rcvdt  IN  s_rcvdt        "개설등록일자.
     AND opnno  IN  s_opnno        "수입개설번호
     AND opndt  IN  s_opndt        "개설일자.
     AND cnam   IN  s_cnam         "작성인.
     AND cdat   IN  s_cdat         "생성일.
     AND unam   IN  s_unam         "최종변경인.
     AND udat   IN  s_udat         "변경일
     AND docst  EQ  'C'
     AND retns  IN  lr_retns
     AND rqrls  IN  lr_rqrls.

  IF sy-subrc NE 0.
    MESSAGE s902.
  ENDIF.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.

  LOOP AT <gt_table> INTO <ls_table>.
    ASSIGN COMPONENT 'LIFNR' OF STRUCTURE
                        <ls_table> TO <l_field2>.
    ASSIGN COMPONENT 'NAME1' OF STRUCTURE
                        <ls_table> TO <l_field1>.
    IF sy-subrc EQ 0.
      SELECT SINGLE name1
        INTO <l_field1>
        FROM lfa1
       WHERE lifnr  EQ  <l_field2>.
    ENDIF.

    ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                        <ls_table> TO <l_field1>.
    ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                        <ls_table> TO <l_field2>.
    ASSIGN COMPONENT 'EBELN' OF STRUCTURE
                        <ls_table> TO <l_ebeln>.
    ASSIGN COMPONENT 'ILCTY' OF STRUCTURE
                        <ls_table> TO <l_ilcty>.
    ASSIGN COMPONENT 'DDTEXT' OF STRUCTURE
                        <ls_table> TO <l_ddtext>.
    ASSIGN COMPONENT 'PAGRT' OF STRUCTURE
                        <ls_table> TO <l_pagrt>.
    ASSIGN COMPONENT 'TEXT2' OF STRUCTURE
                        <ls_table> TO <l_text2>.
    ASSIGN COMPONENT 'REQTY' OF STRUCTURE
                        <ls_table> TO <l_reqty>.

    IF sy-subrc EQ 0.
      SELECT ebeln
        INTO <l_ebeln>
        FROM ztitrqp UP TO 1 ROWS
       WHERE reqno EQ <l_field1>
         AND amdsq EQ <l_field2>.
      ENDSELECT.
    ENDIF.

    IF <l_reqty> NE 'LC'.


*>지불조건
      PERFORM  get_domain_value_text(ztir0000) USING 'ZTIREQTY'
                                                     <l_reqty>
                                                     <l_ddtext>.
    ELSE.

*>지불조건
      PERFORM  get_domain_value_text(ztir0000) USING 'ZTIILCTY'
                                                     <l_ilcty>
                                                     <l_ddtext>.

    ENDIF.

*>신용공여주체
    PERFORM  get_domain_value_text(ztir0000) USING 'ZTIPAGRT'
                                                   <l_pagrt>
                                                   <l_text2>.



    MODIFY <gt_table> FROM <ls_table>.

  ENDLOOP.

  DESCRIBE TABLE <gt_table> LINES g_line.
  IF g_line EQ 0.
    MESSAGE s902.
  ENDIF.

ENDFORM.                    " GET_DATA_FOR_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  EXEC_ALV_F4
*&---------------------------------------------------------------------*
FORM exec_alv_f4.

  alv_repid = sy-repid.
  CLEAR: alv_variant.
  alv_variant-report = alv_repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = alv_variant
      i_save     = 'A'
    IMPORTING
      es_variant = alv_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    alv_def = alv_variant-variant.
  ENDIF.

ENDFORM.                    " EXEC_ALV_F4
*&---------------------------------------------------------------------*
*&      Form  SET_ALV_INIT
*&---------------------------------------------------------------------*
FORM set_alv_init.

  FREE:  it_sort, fc.
  CLEAR: alv_keyinfo, gs_layout, alv_print, fc.

* PRINTING SETTINGS
  gs_layout-get_selinfos = 'X'.
  gs_layout-group_change_edit = 'X'.

  alv_print-no_print_selinfos = 'X'.
  alv_print-no_coverpage = 'X'.
  alv_print-no_print_listinfos = 'X'.

ENDFORM.                    " SET_ALV_INIT
*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT_BUILD
*&---------------------------------------------------------------------*
FORM set_fieldcat_build.

  DATA: color TYPE slis_t_specialcol_alv WITH HEADER LINE.

  FREE : fc.  CLEAR: fc.

  ac 'ITAB   BOX   ZTISRQIT                     FLAG  X'.
  ac 'ITAB   REQNO ZTITRQS                      REQNO '.
  ac 'ITAB   AMDSQ ZTITRQS                      AMDSQ '.
  ac 'ITAB   REQTY ZTITRQK                      REQTY '.
  ac 'ITAB   ILCTY ZTITRQK                      ILCTY '.
  ac 'ITAB   DDTEXTDD07D                        DDTEXT'.
  ac 'ITAB   RETXT ZTITRQS                      RETXT '.
  ac 'ITAB   PAGRT ZTITRQS                      PAGRT X'.
  ac 'ITAB   TEXT2 DD07D                        DDTEXT'.
  ac 'ITAB   USCDY ZTITRQK                      USCDY '.
  ac 'ITAB   EBELN ZTITIP1                      EBELN '.
  ac 'ITAB   PSPNR ZTITRQK                      PSPNR X'.

  ac 'ITAB   LIFNR ZTITRQK                      LIFNR '.
  ac 'ITAB   NAME1 LFA1                         NAME1 '.
  ac 'ITAB   OPAMT ZTITRQS                      OPAMT  CWAERS '.
  ac 'ITAB   WAERS ZTITRQS                      WAERS '.
  ac 'ITAB   USAMT ZTITRQS                      USAMT  CUCURR '.
  ac 'ITAB   UCURR ZTITRQS                      UCURR '.
  ac 'ITAB   ZTERM ZTITRQS                      ZTERM '.
  ac 'ITAB   REQDT ZTITRQS                      REQDT '.
  ac 'ITAB   INCO1 ZTITRQS                      INCO1 '.
  ac 'ITAB   CTONM ZTITRQS                      CTONM '.

*> Create field catagory table
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZTIVRQ02'
      i_client_never_display = 'X'
    CHANGING
      ct_fieldcat            = it_fieldcat_g[].

*>Adjust ALV field category
  PERFORM adjust_fieldcat.         ">Adjust ALV field category

  fc1[] = fc[].

  ac 'ITAB   COLOR SLIS_T_SPECIALCOL_ALV              X'.

  LOOP AT fc1 INTO fcs.
    CLEAR: fcs-key .
    CASE fcs-fieldname.
      WHEN 'REQNO' OR 'AMDSQ'.
        fcs-hotspot = 'X'.
        fcs-key     = 'X'.
      WHEN 'EBELN'.
        fcs-hotspot = 'X'.
      WHEN 'DDTEXT'.
        fcs-outputlen = 30.
      WHEN 'TEXT2'.
        fcs-seltext_l = '신용'.
        fcs-seltext_s = '신용공여'.
        fcs-seltext_m = '신용공여주체'.
        fcs-outputlen = 12.
      WHEN 'OPAMT' OR 'USAMT'.
        fcs-do_sum = 'X'.
      WHEN 'RETXT'.
        IF p_step1 EQ 'X' OR p_step2 EQ 'X'.
          fcs-edit   = 'X'.
        ENDIF.
        fcs-outputlen = 120.
    ENDCASE.
    MODIFY fc1 FROM fcs.
  ENDLOOP.

ENDFORM.                    " SET_FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_LIST
*&---------------------------------------------------------------------*
FORM display_alv_list.

  DATA: fc_detail TYPE slis_fieldcat_alv OCCURS 0 WITH HEADER LINE.
  DATA: variant_detail      LIKE disvariant.
  DATA: exit     TYPE slis_event_exit   OCCURS 0 WITH HEADER LINE.
  DATA: events   TYPE slis_alv_event    OCCURS 0 WITH HEADER LINE.
  DATA: groups   TYPE slis_sp_group_alv OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
*  : 의뢰대상
*C : 수입의뢰
*A : 접수완료
*W : 신청서작성
*Y : 개설신청
*N : 개설취소
*O : 개설완료
*R : 접수반려
*----------------------------------------------------------------------
  CASE 'X'.
    WHEN p_step1.   ">의뢰대상
      SET TITLEBAR 'T1000'.
    WHEN p_step2. ">접수대상
      SET TITLEBAR 'T1000'.
  ENDCASE.

* The detail ALV may modify the list (sorting). If returned to the
* base list, the original list needs to be restored.
  REFRESH fc_detail.
  LOOP AT fc1 INTO fcs.
    MOVE-CORRESPONDING fcs TO fc_detail.
    CLEAR fc_detail-tabname.
    APPEND fc_detail.
  ENDLOOP.

  CLEAR variant_detail.
  variant_detail-report = alv_repid.
  variant_detail-handle = ' '.

  gs_layout-colwidth_optimize = 'X'.
  gs_layout-zebra             = 'X'.
  gs_layout-box_fieldname     = 'BOX'.
*>color field define.
  gs_layout-coltab_fieldname  = 'COLOR'.
  gs_layout-group_change_edit = 'X'.
  gs_layout-f2code            = 'DISPLAY'.

  REFRESH exit.
  exit-ucomm = '&OL0'. exit-after = 'X'. APPEND exit.
  exit-ucomm = '&OLX'. APPEND exit.
  exit-ucomm = '&OAD'. APPEND exit.

*> event define.
  REFRESH events.
  events-name = slis_ev_top_of_page.
  events-form = 'TOP_OF_PAGE'.
  APPEND events.

  events-name = slis_ev_data_changed.
  events-form = slis_ev_data_changed.
  APPEND events.
*
  gs_gridset-edt_cll_cb = 'X'.

*> ALV reuse function call..
  CALL FUNCTION alv_detail_func
      EXPORTING
        i_callback_program       = alv_repid
        i_callback_pf_status_set = 'SET_ALV_STATUS'
        i_callback_user_command  = 'USER_ALV_COMMAND'
        i_grid_settings          = gs_gridset
*     I_STRUCTURE_NAME               =
*     IT_EXCLUDING                   =
*     IT_SPECIAL_GROUPS              =
*     IT_FILTER                      =
*     IS_SEL_HIDE                    =
*     I_DEFAULT                      = 'X'
*     I_SAVE                         = ' '
*     IS_VARIANT                     =
*      it_events                      = gt_events[]
      it_events                      = events[]
      it_event_exit                  = exit[]
*     IS_PRINT                       =
*     IS_REPREP_ID                   =
*     I_SCREEN_START_COLUMN          = 0
*     I_SCREEN_START_LINE            = 0
*     I_SCREEN_END_COLUMN            = 0
*     I_SCREEN_END_LINE              = 0
        it_fieldcat              = fc_detail[]
        it_sort                  = it_sort
*        I_DEFAULT                = 'X'
*        IS_VARIANT               = VARIANT_DETAIL
        is_variant               = alv_variant
        i_save                   = c_save
        is_layout                = gs_layout
        is_print                 = alv_print
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER        =
*     ES_EXIT_CAUSED_BY_USER         =
      TABLES
        t_outtab                 = <gt_table>.

ENDFORM.                    " DISPLAY_ALV_LIST

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_STATUS
*&---------------------------------------------------------------------*
FORM set_alv_status USING  extab TYPE slis_t_extab.


  APPEND 'ARCHIVE'   TO extab.
*  APPEND '&VEXCEL'   TO extab.
  APPEND '&AQW'      TO extab.
  APPEND '&VCRYSTAL' TO extab.
  APPEND '&VGRID'    TO extab.
  APPEND '&EB9'      TO extab.
  APPEND '&CRDESIG'  TO extab.
*----------------------------------------------------------------------
*  : 의뢰대상
*C : 수입의뢰
*A : 접수완료
*W : 신청서작성
*Y : 개설신청
*N : 개설취소
*O : 개설완료
*R : 접수반려
*----------------------------------------------------------------------
  CASE 'X'.
    WHEN p_step1.	">의뢰대상
      APPEND 'ZTICANCEL'  TO extab.
    WHEN p_step2. ">접수대상
      APPEND 'ZTIRELEASE'  TO extab.
      APPEND 'ZTIRETURN'  TO extab.
    WHEN OTHERS.
      APPEND 'ZTICANCEL'  TO extab.
      APPEND 'ZTIRELEASE'  TO extab.
      APPEND 'ZTIRETURN'  TO extab.
  ENDCASE.

  SET PF-STATUS 'STANDARD' EXCLUDING extab.

ENDFORM.                    " SET_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  USER_ALV_COMMAND
*&---------------------------------------------------------------------*
FORM user_alv_command USING   r_ucomm      LIKE sy-ucomm
                              rs_selfield  TYPE slis_selfield.
*
  DATA: l_count    TYPE i.
  DATA: l_subrc    LIKE sy-subrc.
  DATA: l_tcode    LIKE sy-tcode.

  DATA: l_reqno    TYPE ztireqno,
        l_amdsq    TYPE ztiamdsq,
        l_answer   TYPE c,
        l_date(10) TYPE c.

  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_box>.
  FIELD-SYMBOLS: <l_field>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.
  FIELD-SYMBOLS: <l_retxt>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.
  ASSIGN COMPONENT 'BOX' OF STRUCTURE  <ls_table> TO <l_box>.

  CLEAR: it_reqno, it_reqno[].
  CLEAR: l_count.

  CASE r_ucomm.
    WHEN 'ZTIRELEASE' OR  ">승인.
         'ZTIRETURN' OR   ">반려.
         'ZTICANCEL'.   ">취소.

      LOOP AT <gt_table> INTO <ls_table>.
        IF <l_box> EQ 'X'.
          ADD 1 TO l_count.
          ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                                  <ls_table> TO <l_field1>.
          ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                        <ls_table> TO <l_field2>.
          ASSIGN COMPONENT 'RETXT' OF STRUCTURE
                        <ls_table> TO <l_retxt>.

          l_reqno = <l_field1>.
          l_amdsq = <l_field2>.
          it_reqno-reqno = l_reqno.
          it_reqno-amdsq = l_amdsq.
          it_reqno-retxt = <l_retxt>.
          APPEND it_reqno.
        ENDIF.
      ENDLOOP.
      IF l_count EQ 0.
        MESSAGE e909.
      ENDIF.

  ENDCASE.

  CASE r_ucomm.
    WHEN 'ZTIRELEASE'.  ">승인.
      PERFORM confirm_message   USING r_ucomm  l_answer.
      IF l_answer EQ 'Y'.
        PERFORM update_database USING r_ucomm  l_count.
        IF l_count GT 0.
          PERFORM get_data_for_display.    ">data select
          rs_selfield-refresh = 'X'.
        ENDIF.
      ENDIF.
    WHEN 'ZTIRETURN'.   ">반려.
      PERFORM confirm_message   USING r_ucomm  l_answer.
      IF l_answer EQ 'Y'.
        PERFORM update_database USING r_ucomm  l_count.
        IF l_count GT 0.
          PERFORM get_data_for_display.    ">data select
          rs_selfield-refresh = 'X'.
        ENDIF.
      ENDIF.
    WHEN 'ZTICANCEL'.   ">취소.
      PERFORM confirm_message   USING r_ucomm  l_answer.
      IF l_answer EQ 'Y'.
        PERFORM update_database USING r_ucomm  l_count.
        IF l_count GT 0.
          PERFORM get_data_for_display.    ">data select
          rs_selfield-refresh = 'X'.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
*> 초기화면.
      CHECK rs_selfield-tabindex GT 0.

      READ TABLE <gt_table> INTO <ls_table> INDEX rs_selfield-tabindex.
      IF sy-subrc NE 0.
        MESSAGE s906.            EXIT.
      ENDIF.
      IF rs_selfield-fieldname EQ 'EBELN'.
        ASSIGN COMPONENT 'EBELN' OF STRUCTURE
                              <ls_table> TO <l_field1>.
        PERFORM display_purchase_order(ztir0000)
                             USING <l_field1> '00' .
      ELSE.
        ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                              <ls_table> TO <l_field1>.
        ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                              <ls_table> TO <l_field2>.
        PERFORM excute_import_document(ztir0000)
                             USING <l_field1> <l_field2> 'ZTIT003'.
      ENDIF.
  ENDCASE.

  CLEAR: r_ucomm.

ENDFORM.                    " USER_ALV_COMMAND
*&---------------------------------------------------------------------*
*&      Form  ALV_VARIANT_CHECK
*&---------------------------------------------------------------------*
FORM alv_variant_check.

  alv_variant-report = alv_repid.
  alv_variant-variant = alv_def.
  IF NOT alv_def IS INITIAL.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save     = 'A'
      CHANGING
        cs_variant = alv_variant
      EXCEPTIONS
        OTHERS     = 1.
    IF sy-subrc <> 0.
      MESSAGE e321(m7) WITH alv_def alv_repid.
    ENDIF.
  ENDIF.

ENDFORM.                    " ALV_VARIANT_CHECK
*&---------------------------------------------------------------------*
*&      Form  SET_SORT_FIELD
*&---------------------------------------------------------------------*
FORM set_sort_field.

  REFRESH: it_sort.

*  CLEAR  st_sort.
*  st_sort-spos = '01'.
*  st_sort-fieldname = 'REQNO'.
*  st_sort-tabname   = '<GT_TABLE>'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
*  st_sort-subtot    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.
*
*  CLEAR  st_sort.
*  st_sort-spos = '02'.
*  st_sort-fieldname = 'MTBEZ'.
*  st_sort-tabname   = 'ITAB'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
**  ST_SORT-SUBTOT    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.
*
*  CLEAR  st_sort.
*  st_sort-spos = '03'.
*  st_sort-fieldname = 'EBELN'.
*  st_sort-tabname   = 'ITAB'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
**  ST_SORT-SUBTOT    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.

ENDFORM.                    " SET_SORT_FIELD

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM top_of_page.

  DATA: l_mode TYPE i.
  DATA: header TYPE slis_listheader OCCURS 0 WITH HEADER LINE.

  REFRESH header.

  header-typ = 'H'.
*----------------------------------------------------------------------
*  : 의뢰대상
*C : 수입의뢰
*A : 접수완료
*W : 신청서작성
*Y : 개설신청
*N : 개설취소
*O : 개설완료
*R : 접수반려
*----------------------------------------------------------------------
  CASE 'X'.
    WHEN p_step1. ">승인대상
      header-info = '승인대상 현황'.
    WHEN p_step2. ">취소대상
      header-info = '승인 현황'.
    WHEN OTHERS.  ">개설완료
      header-info = '반려 현황'.
  ENDCASE.

  CLEAR: header-key.
  APPEND header.

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: l_butxt LIKE t001-butxt.
  CLEAR: l_butxt.
  SELECT SINGLE butxt FROM t001
                      INTO l_butxt
                     WHERE bukrs EQ s_bukrs-low.

  header-typ = 'S'.
  header-key = '회사코드 '.
  CONCATENATE s_bukrs-low l_butxt INTO header-info SEPARATED BY space.
  APPEND header.
  CLEAR: header.
** JS전선 회사코드 2007/04 KSH --------------------------------------

  header-typ = 'S'.
  header-key = '출력일자'(106).
  WRITE: sy-datlo TO header-info.
  APPEND header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = header[].

ENDFORM.    ">TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  MATERIAL_MASTER_DISPLAY
*&---------------------------------------------------------------------*
FORM material_master_display USING rs_selfield  TYPE slis_selfield.

  FIELD-SYMBOLS: <ls_table>.

  READ TABLE <gt_table> INTO <ls_table>
                        INDEX rs_selfield-tabindex. "cursorposit.
  IF sy-subrc EQ 0.
*    MOVE-CORRESPONDING <ls_table> TO xitab.
*
*    READ TABLE organ WITH KEY werks = xitab-werks.
*
*    SET PARAMETER ID 'MAT' FIELD xitab-matnr.
*    SET PARAMETER ID 'BUK' FIELD organ-bukrs.
*    SET PARAMETER ID 'WRK' FIELD xitab-werks.
    SET PARAMETER ID 'LAG' FIELD ''.
*  SET PARAMETER ID 'MXX' FIELD 'KDEALBSZXVPCFQG'.
    SET PARAMETER ID 'MXX' FIELD 'KDE'.

    CALL TRANSACTION 'MM03' AND SKIP  FIRST SCREEN.
  ELSE.
    MESSAGE s903.
  ENDIF.

ENDFORM.                    " MATERIAL_MASTER_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  create_dynamic_table
*&---------------------------------------------------------------------*
FORM create_dynamic_table .

  DATA: lp_table        TYPE REF TO data.
  DATA: e_style_fname   TYPE lvc_fname.
  DATA: i_style_table   TYPE c.
  DATA: lt_fieldcat     TYPE lvc_t_fcat.

*create_dynamic_table
  CLEAR lp_table.
  CALL METHOD z_ti_cl_alv_table_create=>create_dynamic_table_grid
    EXPORTING
      it_fieldcatalog = fc
*      i_style_table   = i_style_table
    IMPORTING
      ep_table        = lp_table.

  ASSIGN lp_table->* TO <gt_table>.

ENDFORM.                    " create_dynamic_table
*&---------------------------------------------------------------------*
*&      Form  set_colorize_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_colorize_build .

  FIELD-SYMBOLS: <lt_table> TYPE table.
  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <lt_color>.
  FIELD-SYMBOLS: <ls_color>.
  FIELD-SYMBOLS: <l_field> TYPE table.
  FIELD-SYMBOLS: <l_name>.
  FIELD-SYMBOLS: <l_col>.
  FIELD-SYMBOLS: <l_int>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <lt_table>.

  DATA: color TYPE slis_t_specialcol_alv WITH HEADER LINE.

*> colorize
  LOOP AT <gt_table> INTO <lt_table>.

    ASSIGN COMPONENT 'COLOR' OF STRUCTURE
                             <lt_table> TO <l_field>.

    ASSIGN LOCAL COPY OF INITIAL LINE OF <l_field> TO <ls_color>.

    ASSIGN COMPONENT 'COLOR-COL' OF STRUCTURE
                             <ls_color> TO <l_col>.
    ASSIGN COMPONENT 'COLOR-INT' OF STRUCTURE
                             <ls_color> TO <l_int>.
    ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE
                             <ls_color> TO <l_name>.
    <l_col> = 4.
    <l_int> = 0.
    <l_name> = 'REQTY'.
    APPEND <ls_color> TO <l_field>.

    MODIFY <gt_table> FROM <lt_table>.
  ENDLOOP.

ENDFORM.                    " set_colorize_build
*&---------------------------------------------------------------------*
*&      Form  ADJUST_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM adjust_fieldcat .

  FIELD-SYMBOLS: <ls_table>,
                 <l_field>.

  DATA: lt_fieldcat_g TYPE lvc_t_fcat.

*>Internal table에 존재하지 않는 필드.
  LOOP AT it_fieldcat_g INTO gs_fieldcat_g.
    READ TABLE fc INTO fcs WITH KEY fieldname = gs_fieldcat_g-fieldname.
    IF sy-subrc NE 0.
      IF NOT gs_fieldcat_g-fieldname IS INITIAL AND
         gs_fieldcat_g-fieldname     NE 'MANDT'.
        MOVE-CORRESPONDING  gs_fieldcat_g TO fcs.
        MOVE: gs_fieldcat_g-fieldname     TO fcs-ref_fieldname,
              'ZTIVRQ02'                  TO fcs-ref_tabname.
        CLEAR: fcs-key.
        fcs-no_out = 'X'.
        APPEND fcs TO fc.
      ENDIF.
    ENDIF.
    DESCRIBE TABLE fc LINES g_line.
    IF g_line GT 50.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " ADJUST_fieldcat
*&---------------------------------------------------------------------*
*&      Form  confirm_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM confirm_message  USING    p_ucomm  p_answer.

  DATA: cancel_display.
*>------------------------------------------------------
*> MESSAGE POPUP용.
*>------------------------------------------------------
  DATA: BEGIN OF pop,
        titel      LIKE spop-titel,
        diagnose1  LIKE spop-diagnose1,
        diagnose2  LIKE spop-diagnose2,
        diagnose3  LIKE spop-diagnose3,
        textline1  LIKE spop-textline1,
        textline2  LIKE spop-textline2,
        textline3  LIKE spop-textline3,
        option1    LIKE spop-varoption1,
        option2    LIKE spop-varoption2,
        default,             "defaultoption fuer Confirm_step
        answer,
  END OF pop.

  CLEAR cancel_display.

  CASE p_ucomm.
    WHEN 'ZTIRELEASE'. ">승인.
      MOVE: '선택한 수입요청을 승인처리합니다.'  TO pop-diagnose1,
            '승인 하시겠습니까?'                 TO pop-textline1,
            '승인 확인'                          TO pop-titel.

    WHEN 'ZTIRETURN'.   ">반려.
      MOVE: '선택한 수입요청을 반려처리합니다.'  TO pop-diagnose1,
            '반려처리 하시겠습니까?'             TO pop-textline1,
            '반려 확인'                          TO pop-titel.

    WHEN 'ZTICANCEL'.   ">취소.
      MOVE: '선택한 수입요청을 승인취소합니다.'  TO pop-diagnose1,
            '승인취소 하시겠습니까?'             TO pop-textline1,
            '승인취소 확인'                      TO pop-titel.
  ENDCASE.

  CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
         EXPORTING
*             DEFAULTOPTION = 'Y'
              diagnosetext1 = pop-diagnose1
*             DIAGNOSETEXT2 = POP-DIAGNOSE2
*             DIAGNOSETEXT3 = ' '
              textline1      = pop-textline1
              textline2      = pop-textline2
              titel          = pop-titel
*             START_COLUMN   = 25
*             START_ROW      = 6
              cancel_display = cancel_display
         IMPORTING
              answer        = pop-answer
         EXCEPTIONS
              OTHERS        = 1.


  CASE pop-answer.
    WHEN 'J'.
      p_answer = 'Y'.
    WHEN 'N'.
      p_answer = 'N'.
    WHEN 'A'.
      p_answer = 'A'.
  ENDCASE.

ENDFORM.                    " confirm_message
*&---------------------------------------------------------------------*
*&      Form  update_database
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM update_database  USING    p_ucomm    p_count.

  DATA: lt_ztitrqs_new LIKE ztitrqs OCCURS 1 WITH HEADER LINE.
  DATA: lt_ztitrqs_old LIKE ztitrqs OCCURS 1 WITH HEADER LINE.

  DATA: l_count    TYPE i,
        l_rqrls    TYPE ztirqrls,
        l_retns    TYPE ztiretns,
        l_subrc    LIKE sy-subrc.

  CLEAR: p_count.

  CALL FUNCTION 'MESSAGES_INITIALIZE'.

  LOOP AT it_reqno.
    g_tabix = sy-tabix.
    PERFORM  set_lc_lock_object  USING it_reqno-reqno
                                       it_reqno-amdsq
                                       'L'
                                       l_subrc.
    IF l_subrc NE 0.
      DELETE it_reqno INDEX g_tabix.
      CONTINUE.
    ENDIF.
    IF p_ucomm EQ 'ZTIRETURN'.
      IF it_reqno-retxt IS INITIAL.
        CALL FUNCTION 'MESSAGE_STORE'
          EXPORTING
            arbgb  = 'ZMTI00'
            msgty  = 'E'
            msgv1  = it_reqno-reqno
            msgv2  = it_reqno-amdsq
            msgv3  = space
            msgv4  = space
            txtnr  = '175'
*            zeile  = itab_mesg-zeile
          EXCEPTIONS
            OTHERS = 1.

        CHECK sy-subrc EQ 0.
        DELETE it_reqno INDEX g_tabix.
      ENDIF.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE it_reqno LINES l_count.
  IF l_count EQ 0.
    CALL FUNCTION 'MESSAGES_SHOW'
      EXPORTING
        object             = '※ Error Message'
        i_use_grid         = 'X'
        i_amodal_window    = 'X'
      EXCEPTIONS
        inconsistent_range = 1
        no_messages        = 2
        OTHERS             = 3.
    EXIT.
  ENDIF.

*> data select
  SELECT *
    INTO TABLE lt_ztitrqs_old
    FROM ztitrqs
     FOR ALL ENTRIES IN it_reqno
   WHERE reqno EQ it_reqno-reqno
     AND amdsq EQ it_reqno-amdsq.

  lt_ztitrqs_new[] = lt_ztitrqs_old[].

  CASE p_ucomm.
    WHEN 'ZTIRELEASE'.  ">승인.
      l_rqrls = 'X'.
      l_retns = ' '.
    WHEN 'ZTIRETURN'.  ">반려.
      l_rqrls = ' '.
      l_retns = 'X'.
    WHEN 'ZTICANCEL'.   ">취소.
      l_rqrls = ' '.
      l_retns = ' '.
  ENDCASE.

  LOOP AT lt_ztitrqs_new.
    READ TABLE lt_ztitrqs_old
               WITH KEY reqno = lt_ztitrqs_new-reqno
                        amdsq = lt_ztitrqs_new-amdsq.

    READ TABLE it_reqno WITH KEY reqno = lt_ztitrqs_new-reqno
                                 amdsq = lt_ztitrqs_new-amdsq.
    IF sy-subrc EQ 0.
      MOVE:it_reqno-retxt  TO   lt_ztitrqs_new-retxt.
    ENDIF.

    MOVE:l_rqrls    TO   lt_ztitrqs_new-rqrls,
         l_retns    TO   lt_ztitrqs_new-retns,
         sy-uname   TO   lt_ztitrqs_new-unam,
         sy-datlo   TO   lt_ztitrqs_new-udat,
         sy-timlo   TO   lt_ztitrqs_new-utme.

    MODIFY lt_ztitrqs_new.

    CASE p_ucomm.
      WHEN 'ZTIRELEASE'.  ">승인.
        MESSAGE s167 WITH lt_ztitrqs_new-reqno '승인'.
      WHEN 'ZTIRETURN'.  ">반려.
        MESSAGE s167 WITH lt_ztitrqs_new-reqno '반려'.
      WHEN 'ZTICANCEL'.   ">취소.
        MESSAGE s167 WITH lt_ztitrqs_new-reqno '취소'.
    ENDCASE.

    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        arbgb  = sy-msgid
        msgty  = sy-msgty
        msgv1  = sy-msgv1
        msgv2  = sy-msgv2
        msgv3  = sy-msgv3
        msgv4  = sy-msgv4
        txtnr  = sy-msgno
*          zeile  = itab_mesg-zeile
      EXCEPTIONS
        OTHERS = 1.

*> Change Document
    PERFORM  set_change_document USING lt_ztitrqs_old
                                       lt_ztitrqs_new.

    ADD 1 TO p_count.
  ENDLOOP.

  MODIFY ztitrqs FROM TABLE lt_ztitrqs_new.

*  break-point.

*> Unlock
  LOOP AT lt_ztitrqs_new.
    PERFORM  set_lc_lock_object  USING lt_ztitrqs_new-reqno
                                       lt_ztitrqs_new-amdsq
                                       'U'
                                       l_subrc.
  ENDLOOP.

  CALL FUNCTION 'MESSAGES_SHOW'
    EXPORTING
      object             = '※ Error Message'
      i_use_grid         = 'X'
      i_amodal_window    = 'X'
    EXCEPTIONS
      inconsistent_range = 1
      no_messages        = 2
      OTHERS             = 3.

ENDFORM.                    " update_database
*&---------------------------------------------------------------------*
*&      Form  set_lc_lock_object
*&---------------------------------------------------------------------*
FORM set_lc_lock_object  USING    p_reqno
                                  p_amdsq
                                  p_mode
                                  p_subrc.

  DATA: l_mess(100).

*   CLEAR: p_check.
  CLEAR: p_subrc.

  IF p_mode EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITRQK'
      EXPORTING
        mandt          = sy-mandt
        reqno          = p_reqno
        amdsq          = p_amdsq
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      p_subrc = 4.
*      CALL FUNCTION 'RKC_MSG_STRING'
*        EXPORTING
*          id      = sy-msgid
*          mtype   = sy-msgty
*          number  = sy-msgno
*          par1    = sy-msgv1
*          par2    = sy-msgv2
*          par3    = sy-msgv3
*          par4    = sy-msgv4
*        IMPORTING
*          msg_lin = l_mess.

      CALL FUNCTION 'MESSAGE_STORE'
        EXPORTING
          arbgb  = sy-msgid
          msgty  = sy-msgty
          msgv1  = sy-msgv1
          msgv2  = sy-msgv2
          msgv3  = sy-msgv3
          msgv4  = sy-msgv4
          txtnr  = sy-msgno
*          zeile  = itab_mesg-zeile
        EXCEPTIONS
          OTHERS = 1.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITRQK'
      EXPORTING
        mandt = sy-mandt
        reqno = p_reqno
        amdsq = p_amdsq.
  ENDIF.

ENDFORM.                    " set_LC_lock_object
*&---------------------------------------------------------------------*
*&      Form  set_change_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_change_document USING l_ztitrqs_old STRUCTURE ztitrqs
                               l_ztitrqs_new STRUCTURE ztitrqs.

  DATA: l_objectid              TYPE cdhdr-objectid,
        l_tcode                 TYPE cdhdr-tcode,
        l_utime                 TYPE cdhdr-utime,
        l_udate                 TYPE cdhdr-udate,
        l_username              TYPE cdhdr-username,
        l_cdoc_upd_object       TYPE cdhdr-change_ind,
        l_upd_icdtxt            TYPE char1,
        l_upd                   TYPE char1,
        lt_cdtxt                TYPE STANDARD TABLE OF cdtxt
                                     INITIAL SIZE 0.

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

  TABLES:*ztitrqk,    ">수입의뢰 Header
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
         *ztittt3.    ">지급지시서 T/T ITEM (부가수수료)


  l_cdoc_upd_object = 'U'.
  l_upd_icdtxt      = 'U'.
  l_upd             = 'U'.

  l_objectid(12) = l_ztitrqs_old+3(12).

  l_tcode        = sy-tcode.
  l_utime        = sy-timlo.
  l_udate        = sy-datlo.
  l_username     = sy-uname.

  CALL FUNCTION 'ZTILCCHDOC_WRITE_DOCUMENT'
    EXPORTING
      objectid                      = l_objectid
      tcode                         = l_tcode
      utime                         = l_utime
      udate                         = l_udate
      username                      = l_username
*   PLANNED_CHANGE_NUMBER         = ' '
      object_change_indicator       = l_cdoc_upd_object
*   PLANNED_OR_REAL_CHANGES       = ' '
*   NO_CHANGE_POINTERS            = ' '
*   UPD_ICDTXT_ZTILCCHDOC         = ' '
      n_ztitlc1                    = ztitlc1
      o_ztitlc1                    = *ztitlc1
      upd_ztitlc1                  = l_upd
      upd_ztitlc2                  = l_upd
      upd_ztitlc4                  = l_upd
      n_ztitlo1                    = ztitlo1
      o_ztitlo1                    = *ztitlo1
      upd_ztitlo1                  = l_upd
      n_ztitpc1                    = ztitpc1
      o_ztitpc1                    = *ztitpc1
      upd_ztitpc1                  = l_upd
      upd_ztitpc2                  = l_upd
      upd_ztitpc3                  = l_upd
      n_ztitrqk                    = ztitrqk
      o_ztitrqk                    = *ztitrqk
      upd_ztitrqk                  = l_upd
      upd_ztitrqp                  = l_upd
      n_ztitrqs                    = l_ztitrqs_new
      o_ztitrqs                    = l_ztitrqs_old
      upd_ztitrqs                  = l_upd
      n_ztittt1                    = ztittt1
      o_ztittt1                    = *ztittt1
      upd_ztittt1                  = l_upd
      upd_ztittt2                  = l_upd
      upd_ztittt3                  = l_upd
    TABLES
      icdtxt_ztilcchdoc             = lt_cdtxt
      xztitlc2                     = xztitlc2
      yztitlc2                     = yztitlc2
      xztitlc3                     = xztitlc3
      yztitlc3                     = yztitlc3
      xztitlc4                     = xztitlc4
      yztitlc4                     = yztitlc4
      xztitpc2                     = xztitpc2
      yztitpc2                     = yztitpc2
      xztitpc3                     = xztitpc3
      yztitpc3                     = yztitpc3
      xztitrqp                     = xztitrqp
      yztitrqp                     = yztitrqp
      xztittt2                     = xztittt2
      yztittt2                     = yztittt2
      xztittt3                     = xztittt3
      yztittt3                     = yztittt3
      xztittt4                     = xztittt4
      yztittt4                     = yztittt4.


ENDFORM.                    " set_change_document
*&---------------------------------------------------------------------*
*&      Form  set_event_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_event_form USING    p_event
                             p_form.
  CLEAR gs_events.
  READ TABLE gt_events WITH KEY name = p_event
                       INTO gs_events.
  IF sy-subrc = 0.
    gs_events-form = p_form.
    MODIFY gt_events FROM gs_events INDEX sy-tabix.
  ELSE.
    gs_events-name = p_event.
    gs_events-form = p_form.
    APPEND gs_events TO gt_events.
  ENDIF.

ENDFORM.                    " set_event_form
*&--------------------------------------------------------------------*
*&      Form  alv_data_changed
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM data_changed USING rr_data_changed
                        TYPE REF TO cl_alv_changed_data_protocol.

  DATA : ls_mod_cells TYPE lvc_s_modi,
         ls_cells     TYPE lvc_s_modi,
         l_matnr      LIKE mara-matnr.

  LOOP AT rr_data_changed->mt_good_cells INTO ls_mod_cells.
    CASE ls_mod_cells-fieldname.
      WHEN 'RETXT'.
        PERFORM set_data_changed USING rr_data_changed ls_mod_cells.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    "alv_data_changed
*&---------------------------------------------------------------------*
*&      Form  set_data_changed
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_data_changed  USING
      rr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                  rs_mod_cells TYPE lvc_s_modi.

  FIELD-SYMBOLS: <ls_table>,
                 <l_retxt>.

  DATA: ls_table      LIKE ztitrqs.

*> Work Area Assign
  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.

  READ TABLE <gt_table> INTO <ls_table> INDEX rs_mod_cells-row_id.

  ASSIGN COMPONENT 'RETXT' OF STRUCTURE
                        <ls_table> TO <l_retxt>.

*  MOVE-CORRESPONDING <ls_table> TO ls_table.

  CASE rs_mod_cells-fieldname.
    WHEN 'RETXT'.
      CALL METHOD rr_data_changed->get_cell_value
           EXPORTING
              i_row_id       = rs_mod_cells-row_id
*              I_TABIX
              i_fieldname    = 'RETXT'
           IMPORTING
              e_value        = <l_retxt>.

      CALL METHOD rr_data_changed->modify_cell
        EXPORTING
          i_row_id    = rs_mod_cells-row_id
          i_fieldname = 'RETXT'
          i_value     = <l_retxt>.

    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " set_data_changed
