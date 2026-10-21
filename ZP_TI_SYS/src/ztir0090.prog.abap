*----------------------------------------------------------------------*
* Title         : ZTIR0090                                             *
*                                                                      *
* Description   : [Report] 수입요청(TT) 결재 프로그램                *
*                                                                      *
* Creation Date : 2014/01/04                                           *
*                                                                      *
* Author        : LEE J.K.                                             *
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* 20140205     FIB03            2013120300061(Initail release)         *
* 2014.07.24   FIB03            37445                                  *
* - GUI STATUS 보완
*----------------------------------------------------------------------*

PROGRAM   ztir0090
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
DATA: l_yn    TYPE c.
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
        ekbz  ,    ">History per Purchasing Document: Delivery Costs
        ekbe  ,    ">History per Purchasing Document
        ekko,      ">Purchasing Document Header
        ekpo  ,    ">Purchasing Document Items
        ekkn,      ">Account Assignment in Purchasing Document
        dfies ,    ">DD Interface: Table Fields for DDIF_FIELDINFO_GET
        spop  ,    ">POPUP_TO_CONFIRM_... function 모듈 팝업화면 필드.
        ztisscrcom, ">수출입시스템 Screen용 Structure(공용)
        ztitrqk,    ">[Import] Document Header
        ztitrqp,    ">[Import] Document Item
        ztitrqs,    ">[Import] Document Status
        ztitblk,    ">BL내역
        ztitblp,    ">BL품목내역
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
  s_reqty  FOR ztitrqk-reqty DEFAULT 'TT' MODIF ID s1
                    NO-EXTENSION NO INTERVALS, "수입의뢰 종류.
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
PARAMETERS: p_step1 RADIOBUTTON GROUP ab1 DEFAULT 'X' MODIF ID m1,
            p_step2 RADIOBUTTON GROUP ab1             MODIF ID m2,
            p_step3 RADIOBUTTON GROUP ab1             MODIF ID m3.
*            p_step8 radiobutton group ab1              modif id m8,
**                                          NO-DISPLAY ,
**            p_step6 RADIOBUTTON GROUP ab1              MODIF ID m6
**                                          NO-DISPLAY ,
*            p_step7 radiobutton group ab1              modif id m7,
*            p_step4 radiobutton group ab1              modif id m4,
*            p_step5 radiobutton group ab1              modif id m5.

*PARAMETERS: p_before RADIOBUTTON GROUP ab1  DEFAULT 'X' MODIF ID m1,
*            p_after  RADIOBUTTON GROUP ab1              MODIF ID m2
*                                           NO-DISPLAY.
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

SELECTION-SCREEN ULINE.
SELECTION-SCREEN ULINE.

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

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'S1'.
        IF s_reqty-low = 'TT'.
*          screen-invisible = 1.
          screen-input = 0.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.

  ENDLOOP.

  CHECK NOT ztitig00-rqpcs IS INITIAL.

  LOOP AT SCREEN.
    CASE ztitig00-rqpcs.
      WHEN 'A'. ">의뢰->접수->EDI작성->승인(전송)->개설 단계사용.
      WHEN 'B'. ">의뢰->접수->EDI작성(전송)->개설 단계사용.
        IF screen-group1 EQ 'M8' OR
           screen-group1 EQ 'M6'.
          screen-input     = '0'.
          screen-invisible = '1'.
          screen-active    = '0'.
        ENDIF.
      WHEN 'C'. ">의뢰->EDI작성(전송)->개설 단계사용.
        IF screen-group1 EQ 'M1' OR
           screen-group1 EQ 'M8' OR
           screen-group1 EQ 'M6'.
          screen-input     = '0'.
          screen-invisible = '1'.
        ENDIF.
      WHEN 'D'. ">의뢰->은행배정->승인(전송)->개설 단계사용.
        IF screen-group1 EQ 'M1'.
          screen-input     = '0'.
          screen-invisible = '1'.
          screen-active    = '0'.
        ENDIF.
      WHEN 'E'. ">의뢰(EDI작성/전송)->개설 단계사용.
        IF screen-group1 EQ 'M1' OR
           screen-group1 EQ 'M8' OR
           screen-group1 EQ 'M6' OR
           screen-group1 EQ 'M2'.
          screen-input     = '0'.
          screen-invisible = '1'.
        ENDIF.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

AT SELECTION-SCREEN.
  PERFORM input_field_check.
  PERFORM alv_variant_check.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING s_bukrs-low.
** JS전선 회사코드 2007/04 KSH --------------------------------------

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

  SET TITLEBAR 'T1000' WITH '수입요청(TT) 결재관리'.

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
  SELECT bukrs INTO (l_bukrs)
               FROM t001 UP TO 1 ROWS WHERE bukrs IN s_bukrs.
  ENDSELECT.
  IF sy-subrc <> 0.
    PERFORM get_ftext(rddfie00) USING 'T001' 'BUKRS' sy-langu
                                CHANGING dfies g_subrc.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE e348(m7) WITH  dfies-scrtext_m.
  ELSE.
    SELECT SINGLE *
      FROM ztitig00
     WHERE bukrs EQ l_bukrs.
    IF sy-subrc NE 0.
      MESSAGE e035 WITH l_bukrs.
    ENDIF.
*    case 'X'.
*      when p_step1. ">요청대상.
*      when p_step2. ">접수대상.
*        if not ( ztitig00-rqpcs eq 'A' or
*                 ztitig00-rqpcs eq 'B' ).
*          message e939 with '접수'.
*        endif.
*      when p_step3. ">은행배정 대상.
*        if ztitig00-rqpcs eq 'E'.
*          message e939 with '은행배정'.
*        endif.
*      when p_step4. ">개설신청 진행 중.
*      when p_step5. ">개설완료.
**      WHEN p_step6. ">승인대상.
*      when p_step7. ">EDI전송 대상
**-----> 전선 요청으로 반려대상 나오게 함. by MSH,050506
*      when p_step8. ">반려 리스트.
*        if not ( ztitig00-rqpcs eq 'A' or
*                 ztitig00-rqpcs eq 'B' ).
*          message e939 with '회송대상'.
*        endif.
**-----> End of Modification.
*    endcase.
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

  RANGES: lr_docst   FOR   ztitrqs-docst OCCURS 1.

  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.
  FIELD-SYMBOLS: <l_ebeln>.
*  FIELD-SYMBOLS: <l_ebelp>.
  FIELD-SYMBOLS: <l_ddtext>.
  FIELD-SYMBOLS: <l_ilcty>.
  FIELD-SYMBOLS: <l_text2>.
  FIELD-SYMBOLS: <l_pagrt>.
  FIELD-SYMBOLS: <l_bletd>.
  FIELD-SYMBOLS: <l_appdt>.
  FIELD-SYMBOLS: <l_stawn>.

  DATA: l_iblno LIKE ztitblk-iblno.
  DATA: l_ebelp LIKE ztitrqp-ebelp.
  DATA: l_stawn LIKE ztitrqp-stawn.
  DATA: l_apvun LIKE ztitrqs-apvun.

  CLEAR: l_iblno.

  REFRESH : <gt_table>.
*> PROGRESS Display.
  g_line1    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_line1 INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_line1.

  CLEAR lr_docst .
  MOVE: 'I'     TO    lr_docst-sign,
        'EQ'    TO    lr_docst-option.
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
*  CASE 'X'.
*    when p_step1.  ">의뢰대상
*      move: space to  lr_docst-low.    append lr_docst .
*      move: 'R'   to  lr_docst-low.    append lr_docst .
*    when p_step2. ">접수대상
*      move: 'C'   to  lr_docst-low.    append lr_docst .
*    when p_step3. ">EDI 작성대상
*      if ztitig00-rqpcs eq 'D'.
*        move: 'C'   to  lr_docst-low.    append lr_docst .
*      endif.
*      move: 'A'   to  lr_docst-low.    append lr_docst .
*      move: 'W'   to  lr_docst-low.    append lr_docst .
*    when p_step4. ">개설의뢰 진행 중
*      move: 'Y'   to  lr_docst-low.    append lr_docst .
*    when p_step5. ">개설완료
*      move: 'O'   to  lr_docst-low.    append lr_docst .
**    WHEN p_step6. ">상신대상.
**      MOVE: 'W'   TO  lr_docst-low.    APPEND lr_docst .
*    when p_step7. ">승인/송신대상
*      move: '1'   to  lr_docst-low.    append lr_docst .
*      move: 'N'   to  lr_docst-low.    append lr_docst .
**    WHEN p_step8. ">반려 리스트.
**      MOVE: '2'   TO  lr_docst-low.    APPEND lr_docst .

*    WHEN p_before. ">승인/송신대상
  MOVE: '1'   TO  lr_docst-low.    APPEND lr_docst .
*  ENDCASE.

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
     AND docst  IN  lr_docst       "문서유형
     AND sndst  EQ  ' '            "전송상태-미전송
     AND rqrls  = 'X'.             "수입요청승인

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
    IF sy-subrc EQ 0.
      SELECT SINGLE ebeln ebelp
        INTO (<l_ebeln>,l_ebelp)
        FROM ztitrqp
       WHERE reqno EQ <l_field1>
         AND amdsq EQ <l_field2>.
    ENDIF.

    ASSIGN COMPONENT 'BLETD' OF STRUCTURE
                        <ls_table> TO <l_bletd>.
    ASSIGN COMPONENT 'APPDT' OF STRUCTURE
                        <ls_table> TO <l_appdt>.

    ASSIGN COMPONENT 'STAWN' OF STRUCTURE
                        <ls_table> TO <l_stawn>.

    SELECT SINGLE iblno stawn
      INTO (l_iblno,<l_stawn>)
      FROM ztitrqp
     WHERE reqno EQ <l_field1>.
*       AND cdat  GE <l_appdt>.
*    ENDSELECT.
    MOVE <l_stawn> TO l_stawn.

    IF sy-subrc EQ 0.
      SELECT bletd
        INTO <l_bletd>
        FROM ztitblk UP TO 1 ROWS
       WHERE iblno EQ l_iblno.
      ENDSELECT.
    ELSE.
      SELECT iblno
        INTO l_iblno
        FROM ztitblp
       WHERE ebeln EQ <l_ebeln>
         AND ebelp EQ l_ebelp.
      ENDSELECT.
      IF sy-subrc EQ 0.
        SELECT bletd
          INTO <l_bletd>
          FROM ztitblk UP TO 1 ROWS
         WHERE iblno EQ l_iblno.
        ENDSELECT.
      ENDIF.
    ENDIF.

*>신용공여주체
    PERFORM  get_domain_value_text(ztir0000) USING 'ZTIPAGRT'
                                                   <l_pagrt>
                                                   <l_text2>.

*>지불조건
    PERFORM  get_domain_value_text(ztir0000) USING 'ZTIILCTY'
                                                   <l_ilcty>
                                                   <l_ddtext>.

*>결재여부
    CLEAR : l_apvun.

    SELECT SINGLE apvun
      FROM ztitrqs
      INTO l_apvun
     WHERE reqno = <l_field1>
       AND amdsq = <l_field2>.

* 상태값에 따른 삭제처리
    CASE 'X'.
      WHEN p_step1.
        IF l_apvun <> ''.    "기 결재건 제외
          DELETE <gt_table>.
        ELSE.
          MODIFY <gt_table> FROM <ls_table>.
        ENDIF.
      WHEN p_step2.
        IF l_apvun EQ ''.    "기 결재건 제외
          DELETE <gt_table>.
        ELSE.
          MODIFY <gt_table> FROM <ls_table>.
        ENDIF.

      WHEN OTHERS.

    ENDCASE.


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
  ac 'ITAB   OPNNO ZTITRQS                      OPNNO '.
  ac 'ITAB   REQTY ZTITRQK                      REQTY '.
  ac 'ITAB   ILCTY ZTITRQK                      ILCTY '.
  ac 'ITAB   DDTEXTDD07D                        DDTEXT'.
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
  ac 'ITAB   RQRLS ZTITRQS                      RQRLS '.
  ac 'ITAB   BLETD ZTITBLK                      BLETD '.
  ac 'ITAB   STAWN ZTITRQP                      STAWN '.

  ac 'ITAB   APVUN ZTITRQS                      APVUN '.
*  ac 'ITAB   ANAM  ZTITRQS                      ANAM '.
  ac 'ITAB   ADAT  ZTITRQS                      ADAT '.
  ac 'ITAB   ATME  ZTITRQS                      ATME '.
*  ac 'ITAB   APVUN  ZTITRQS                      APVUN '.

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
      WHEN 'TEXT2'.
        fcs-seltext_l = '신용'.
        fcs-seltext_s = '신용공여'.
        fcs-seltext_m = '신용공여주체'.
        fcs-outputlen = 12.
      WHEN 'OPAMT' OR 'USAMT'.
        fcs-do_sum = 'X'.
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
*  CASE 'X'.
*    WHEN p_step1.   ">의뢰대상
*      SET TITLEBAR 'T1000' WITH '수입개설 요청대상'.
*    WHEN p_step2. ">접수대상
*      SET TITLEBAR 'T1000' WITH '수입개설 접수대상'.
*    WHEN p_step3. ">신청대상
*      SET TITLEBAR 'T1000' WITH '수입개설 신청대상'.
*    WHEN p_step4. ">개설의뢰 진행 중
*      SET TITLEBAR 'T1000' WITH '수입개설 신청 진행 중'.
*    WHEN p_step5. ">개설완료
*      SET TITLEBAR 'T1000' WITH '수입 개설'.

*    WHEN p_before. "결재전
  SET TITLEBAR 'T1000' WITH '수입개설 결재 대상'.
*    WHEN p_after.  "결재후
*      SET TITLEBAR 'T1000' WITH '수입개설 결재 완료'.
*  ENDCASE.

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

*  events-name = slis_ev_subtotal_text.
*  events-form = slis_ev_subtotal_text.
*  APPEND events.
*
*> ALV reuse function call..
  CALL FUNCTION alv_detail_func
      EXPORTING
        i_callback_program       = alv_repid
        i_callback_pf_status_set = 'SET_ALV_STATUS'
        i_callback_user_command  = 'USER_ALV_COMMAND'
*     I_STRUCTURE_NAME               =
*     IT_EXCLUDING                   =
*     IT_SPECIAL_GROUPS              =
*     IT_FILTER                      =
*     IS_SEL_HIDE                    =
*     I_DEFAULT                      = 'X'
*     I_SAVE                         = ' '
*     IS_VARIANT                     =
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
*        t_outtab                 = gt_tran.

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
    WHEN p_step1.  ">승인대상
      APPEND 'CANC'  TO extab.
    WHEN p_step2. ">승인취소대상
      APPEND 'CONF'  TO extab.
    WHEN p_step3. ">전체조회
      APPEND 'CONF'  TO extab.
      APPEND 'CANC'  TO extab.
  ENDCASE.

  SET PF-STATUS '1000' EXCLUDING extab.

ENDFORM.                    " SET_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  USER_ALV_COMMAND
*&---------------------------------------------------------------------*
FORM user_alv_command USING   r_ucomm      LIKE sy-ucomm
                              rs_selfield  TYPE slis_selfield.
*
  DATA: l_count    TYPE i,
        l_count2   TYPE i.
  DATA: l_subrc    LIKE sy-subrc.
  DATA: l_tcode    LIKE sy-tcode.

  DATA: l_reqno    TYPE ztireqno,
        l_amdsq    TYPE ztiamdsq,
        l_date(10) TYPE c.

  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <l_field>.
  FIELD-SYMBOLS: <l_field1>.
  FIELD-SYMBOLS: <l_field2>.
  FIELD-SYMBOLS: <l_field3>.


  ASSIGN LOCAL COPY OF INITIAL LINE OF <gt_table> TO <ls_table>.

  CASE r_ucomm.
    WHEN 'CONF'.
      ASSIGN COMPONENT 'BOX' OF STRUCTURE
                               <ls_table> TO <l_field>.

      CLEAR: l_count, l_count2, l_reqno, l_amdsq.

      LOOP AT <gt_table> INTO <ls_table>.
        IF <l_field> EQ 'X'.
          ADD 1 TO l_count2.

          ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                                  <ls_table> TO <l_field1>.
          ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                        <ls_table> TO <l_field2>.

          l_reqno = <l_field1>.
          l_amdsq = <l_field2>.

          UPDATE ztitrqs SET apvun = sy-uname
                             apvdt = sy-datlo
                             apvtm = sy-uzeit
                       WHERE reqno = l_reqno
                         AND amdsq = l_amdsq.

          IF sy-subrc = 0.
            ADD 1 TO l_count.
          ENDIF.

        ENDIF.
      ENDLOOP.
    WHEN 'CANC'.
      ASSIGN COMPONENT 'BOX' OF STRUCTURE
                               <ls_table> TO <l_field>.

      CLEAR: l_count, l_count2, l_reqno, l_amdsq.

      LOOP AT <gt_table> INTO <ls_table>.
        IF <l_field> EQ 'X'.
          ADD 1 TO l_count2.

          ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                                  <ls_table> TO <l_field1>.
          ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                        <ls_table> TO <l_field2>.

          l_reqno = <l_field1>.
          l_amdsq = <l_field2>.

          UPDATE ztitrqs SET apvun = ' '
                             apvdt = ' '
                             apvtm = ' '
                       WHERE reqno = l_reqno
                         AND amdsq = l_amdsq.

          IF sy-subrc = 0.
            ADD 1 TO l_count.
          ENDIF.

        ENDIF.
      ENDLOOP.
  ENDCASE.

  IF l_count2 = 0.
    MESSAGE s999 WITH '대상을 선택하세요.'.
    EXIT.
  ENDIF.

  IF l_count > 0.
    MESSAGE s997 WITH '총 ' l_count '건 처리되었습니다.'.
    COMMIT WORK.
  ENDIF.

  CLEAR: r_ucomm.

  PERFORM get_data_for_display.    ">data select
  rs_selfield-refresh = 'X'.

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
*  CASE 'X'.
*    WHEN p_step1.  ">의뢰대상
*       header-info = '수입요청 대상 현황'.
*    WHEN p_step2. ">접수대상
*      header-info = '수입요청 접수대상 현황'.
*    WHEN p_step3. ">신청대상
*      header-info = '수입 은행배정 대상 현황'.
*    WHEN p_step4. ">개설의뢰 진행 중
*      header-info = '개설요청 진행 중 현황'.
*    WHEN p_step5. ">개설완료
*      header-info = '수입개설 현황'.
**    WHEN p_step6. ">개설완료
**      header-info = '상신대상 현황'.
*    WHEN p_step7. ">개설완료
*      header-info = '승인/송신 현황'.
**    WHEN p_step8. ">개설완료
**      header-info = '반려 리스트'.

*    WHEN p_before.
  header-info = '결재 대상 조회'.
*    WHEN p_after.
*      header-info = '결재 완료 조회'.
*  ENDCASE.

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
        CASE gs_fieldcat_g-fieldname.
          WHEN 'STAWN'.
            MOVE-CORRESPONDING  gs_fieldcat_g TO fcs.
            MOVE: gs_fieldcat_g-fieldname     TO fcs-ref_fieldname,
                  'ZTITRQP'                   TO fcs-ref_tabname.
            CLEAR: fcs-key.
            fcs-no_out = 'X'.
          WHEN OTHERS.
            MOVE-CORRESPONDING  gs_fieldcat_g TO fcs.
            MOVE: gs_fieldcat_g-fieldname     TO fcs-ref_fieldname,
                  'ZTIVRQ02'                  TO fcs-ref_tabname.
            CLEAR: fcs-key.
            fcs-no_out = 'X'.
        ENDCASE.
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
*&      Module  pbo_status_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_status_2000 OUTPUT.

  SET PF-STATUS '2000'.
  SET TITLEBAR  'T2000'.

ENDMODULE.                 " pbo_status_2000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  fcode_exit_scr2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fcode_exit_scr2000 INPUT.

  LEAVE TO SCREEN 0.

ENDMODULE.                 " fcode_exit_scr2000  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_fields  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_input_fields INPUT.

  CHECK ok-code EQ 'ZTIOKAY'.

  IF ztisscrcom-opnbk IS INITIAL.
    PERFORM  no_input_check(ztir0000) USING 'ZTISSCRCOM'
                                            'OPNBK' c_error.
  ENDIF.

  IF ztisscrcom-snddt IS INITIAL.
    PERFORM  no_input_check(ztir0000) USING 'ZTISSCRCOM'
                                            'SNDDT' c_error.
  ENDIF.

ENDMODULE.                 " check_input_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_scr2000 INPUT.

  CASE ok-code.
    WHEN 'ZTIOKAY'.
      LEAVE TO SCREEN 0.
    WHEN 'ZTICANCEL'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " user_command_scr2000  INPUT
