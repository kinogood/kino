************************************************************************
* Title         :  ZTIR3010                                            *
*                                                                      *
* Description   : [Report] 사전(선급금) T/T Due List                   *
*                                                                      *
* Creation Date : 2004/02/06                                           *
*                                                                      *
* Author        : Seung Jun, Lee                                       *
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
* 1.                                                                   *
* 2.                                                                   *
*                                                                      *
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
REPORT  ztir3010        MESSAGE-ID zmti00
                        NO STANDARD PAGE HEADING.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE zts_reuse_alvforms_t00.       "> AVL 공용 Data 선언.
INCLUDE zts_reuse_bdc_subroutine_f00. ">

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF ty_header,
            box(1)      TYPE c,
            reqno       LIKE ztitrqk-reqno,  "수입의뢰 관리번호.
            amdsq	LIKE ztitrqs-amdsq,     "Amend 차수.
            reqty       LIKE ztitrqk-reqty,  "수입의뢰 종류.
            ilcty       LIKE ztitrqk-ilcty,  "1신용장 종류.
            ilctyx(15)  TYPE c,	            "신용장 종류TEXT.
            lifnr       LIKE ztitrqk-lifnr,  "공급업체 계정번호.
            name1       LIKE lfa1-name1,
            lifre       LIKE ztitrqk-lifre,  "다른 송장발행처.
            name3       LIKE lfa1-name1,
            offer       LIKE ztitrqk-offer,  "오퍼상(Offer).
            name4       LIKE lfa1-name1,
            opnbk       LIKE ztitrqk-opnbk,  "개설은행.
            namet       LIKE ztstig3-namet,
            bukrs       LIKE ztitrqk-bukrs,  "회사코드.
            ekorg       LIKE ztitrqk-ekorg,  "구매조직.
            ekgrp       LIKE ztitrqk-ekgrp,  "구매그룹.
            appct       LIKE ztitrqk-appct,  "수입자 구분.
            lstas       LIKE ztitrqk-lstas,  "최종 Amend 차수.
            lponr       LIKE ztitrqs-lponr,  "최종품목번호.
            anbty       LIKE ztitrqk-anbty,  "사전/사후 구분자.
            anbtx(20)   TYPE c,
            ppaid       LIKE ztitrqk-ppaid,  "선급금 여부.
            ppaix(20)   TYPE c,               "text
            pprat       LIKE ztitrqk-pprat,  "선급금 비율.
            rpaid       LIKE ztitrqk-rpaid,  "유보금 여부.
            rprat       LIKE ztitrqk-rprat,  "유보금 비율.
            opnno       LIKE ztitrqs-opnno,  "20수입개설번호.
            opndt       LIKE ztitrqs-opndt,  "개설일자.
            zterm       LIKE ztitrqs-zterm,  "4지급조건키.
            opamt       LIKE ztitrqs-opamt,  "개설금액.
            waers       LIKE ztitrqs-waers,  "통화키.
            wkurs       LIKE ztitrqs-wkurs,                 "9환율.
            inco1       LIKE ztitrqs-inco1,  "3인도조건 (파트 1).
            inco2       LIKE ztitrqs-inco2,  "28인도조건 (파트 2).
            exdat       LIKE ztitrqs-exdat,  "COM:유효기일.
            lsdat       LIKE ztitrqs-lsdat,  "COM:최종선적일자.
            ediyn       LIKE ztitrqs-ediyn,  "EDI 적용여부.
            insyn       LIKE ztitrqs-insyn,  "적하보험대상여부.
            fwdty       LIKE ztitrqs-fwdty,  "운송 방법.
            fland       LIKE ztitrqs-fland,  "선적국가.
            fport       LIKE ztitrqs-fport,  "선적항.
            pllod       LIKE ztitrqs-pllod,  "COM:선적항.
            tland       LIKE ztitrqs-tland,  "도착국가.
            tport       LIKE ztitrqs-tport,  "도착항.
            pltrn       LIKE ztitrqs-pltrn,  "COM:도착항.
            party       LIKE ztitrqs-party,  "분할선적허용여부.
            trany       LIKE ztitrqs-trany,  "환적허용여부.
            reqdt       LIKE ztitrqs-reqdt,  "개설희망일자.
            appun       LIKE ztitrqs-appun,  "개설의뢰 요청자.
            appdt       LIKE ztitrqs-appdt,  "개설의뢰 요청일.
            apptm       LIKE ztitrqs-apptm,  "개설의뢰 요청시간.
            accun       LIKE ztitrqs-accun,  "요청접수 담당자.
            accdt       LIKE ztitrqs-accdt,  "요청접수일자.
            acctm       LIKE ztitrqs-acctm,  "요청접수시간.
            sndun       LIKE ztitrqs-sndun,  "12개설신청자.
            snddt       LIKE ztitrqs-snddt,  "개설신청일.
            sndtm       LIKE ztitrqs-sndtm,  "개설신청시간.
            rcvun       LIKE ztitrqs-rcvun,  "12개설등록자.
            rcvdt       LIKE ztitrqs-rcvdt,  "개설등록일자.
            rcvtm       LIKE ztitrqs-rcvtm,  "개설등록시간.
            recid       LIKE ztitrqs-recid,  "수신자 ID.
            recnm       LIKE ztitrqs-recnm,  "수신자 명.
            recno       LIKE ztitrqs-recno,  "문서번호.
            docst       LIKE ztitrqs-docst,  "문서상태.
            docstx(8)   TYPE c,          	     "문서상태TEXT.
            count       TYPE i.
TYPES: END OF ty_header.

TYPES: BEGIN OF ty_item.
INCLUDE     TYPE        ty_header.
TYPES :     reqit       LIKE ztitrqp-reqit,  "수입의뢰 품목번호.
            ebeln       LIKE ztitrqp-ebeln,  "구매전표번호.
            ebelp       LIKE ztitrqp-ebelp,  "구매문서 품목번호.
            matkl       LIKE ekpo-matkl,      "자재그룹.
            rqmng       LIKE ztitrqp-rqmng,  "수입의뢰수량.
            meins       LIKE ztitrqp-meins,  "기본단위.
            mblnr       LIKE ztitrqp-mblnr,  "자재문서번호.
            mjahr       LIKE ztitrqp-mjahr,  "자재문서연도.
            zeile       LIKE ztitrqp-zeile,  "자재문서품목.
            cnam        LIKE ztitrqp-cnam,   "작성인.
            cdat        LIKE ztitrqp-cdat,   "생성일.
            ctme        LIKE ztitrqp-ctme,   "생성시간.
            unam        LIKE ztitrqp-unam,   "최종변경인.
            udat        LIKE ztitrqp-udat,   "변경일.
            utme        LIKE ztitrqp-utme,   "최종변경시간.
            menge       LIKE ztisrqit-menge,
            ivmngs      LIKE ztisivit-ivmngs,
            ivmngl      LIKE ztisivit-ivmngl,
            werks       LIKE ztisrqit-werks,
            name2       LIKE ztisrqit-name1,
            matnr       LIKE ztisrqit-matnr,
            txz01       LIKE ztisrqit-txz01,
            eeind       LIKE ztisrqit-eeind,
            netpr       LIKE ztisrqit-netpr,
            peinh       LIKE ztisrqit-peinh,
            netwr       LIKE ztisrqit-netwr.
TYPES: END OF ty_item.


TYPES: BEGIN OF ty_list.
INCLUDE             TYPE        ty_item.
TYPES:      color   TYPE slis_t_specialcol_alv.
TYPES: END OF ty_list.

*> Select용.
TYPES: BEGIN OF ty_tab.
INCLUDE     TYPE        ty_item.
TYPES: END OF ty_tab.

************************************************************************
* SAP Include Define                                                   *
************************************************************************

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: t001,
        t001w,
        ztitig02,
        lfa1,
        ztitrqk,
        ztitrqs,
        ztitrqp.

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES: ztivpo00,    ">Purchasing Document : Header + Items
        ztivrq00.    ">수입의뢰 Views(Header + Items + status)

************************************************************************
* CONSTANTS                                                            *
************************************************************************
** 진로산업 Change 2007/04 --------------------------------------
*CONSTANTS:
*    c_bukrs     LIKE t001-bukrs     VALUE '1000'.   ">Company code
** 진로산업 Change 2007/04 --------------------------------------
************************************************************************
* Internal Tables                                                      *
************************************************************************
*DATA : BEGIN OF it_ZTItig02 OCCURS 0.
*        INCLUDE STRUCTURE ZTItig02.
*DATA : END   OF it_ZTItig02.
*
DATA: it_ztitig02  TYPE ztitig02  OCCURS 0 WITH HEADER LINE.
DATA: it_list      TYPE ty_list   OCCURS 0 WITH HEADER LINE.
DATA: it_header    TYPE ty_header OCCURS 0 WITH HEADER LINE.
DATA: it_tab       TYPE ty_tab    OCCURS 0 WITH HEADER LINE.

************************************************************************
* DATA Declarations                                                    *
************************************************************************

************************************************************************
** RANGES
************************************************************************
*RANGES:

***********************************************************************
* FIELD-GROUPS
***********************************************************************
*FIELD-GROUPS:

***********************************************************************
* FIELD-SYMBOLS
***********************************************************************
*FIELD-SYMBOLS:

************************************************************************
* MACRO DEFINE                                                         *
************************************************************************

************************************************************************
* CLASSES: Definition                                                  *
************************************************************************

************************************************************************
* CLASSES: IMPLEMENTATION
*
************************************************************************

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK dbsel WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ztitrqk-bukrs                  "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk
                    MODIF  ID iog ,
  s_ekorg  FOR ztitrqk-ekorg MODIF ID iog,   "구매조직.
  s_ekgrp  FOR ztitrqk-ekgrp MODIF ID iog,   "구매그룹.
  s_ebeln  FOR ztitrqp-ebeln MODIF ID iog	    "구매전표번호.
                              MEMORY ID bes,
  s_reqno  FOR ztitrqk-reqno MODIF ID iog    "수입의뢰 관리번호.
                              MEMORY ID ztireqno,
  s_matkl  FOR ztivpo00-matkl MODIF ID iog
                              MEMORY ID mkl, "자재그룹.
  s_lifnr  FOR ztitrqk-lifnr MODIF ID iog,   "공급업체 계정번호.
  s_exdat  FOR ztitrqs-exdat MODIF ID iog,   "COM:유효기일.
  s_lsdat  FOR ztitrqs-lsdat MODIF ID iog,   "COM:최종선적일자.
  s_lifre  FOR ztitrqk-lifre MODIF ID iog,   "다른 송장발행처.
  s_offer  FOR ztitrqk-offer MODIF ID iog,   "오퍼상(Offer).
  s_cnam   FOR ztitrqp-cnam  MODIF ID iog,   "작성인.
  s_cdat   FOR ztitrqp-cdat  MODIF ID iog,   "생성일.
  s_unam   FOR ztitrqp-unam  MODIF ID iog,   "최종변경인.
  s_udat   FOR ztitrqp-udat  MODIF ID iog.   "변경일.
SELECTION-SCREEN ULINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN: COMMENT 1(10) text-004,
                  COMMENT 30(4) text-014 FOR FIELD p_step4,
                  POSITION 36.
PARAMETERS: p_step4 RADIOBUTTON GROUP ab4.
SELECTION-SCREEN: COMMENT 45(4) text-015 FOR FIELD p_step5,
                  POSITION 51.
PARAMETERS: p_step5 RADIOBUTTON GROUP ab4.
SELECTION-SCREEN: COMMENT 60(4) text-016 FOR FIELD p_step6,
                  POSITION 66.
PARAMETERS: p_step6 RADIOBUTTON GROUP ab4  DEFAULT 'X'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN: COMMENT 1(10) text-003,
                  COMMENT 30(4) text-011 FOR FIELD p_step1,
                  POSITION 36.
PARAMETERS: p_step1 RADIOBUTTON GROUP ab1.
SELECTION-SCREEN: COMMENT 45(4) text-012 FOR FIELD p_step2,
                  POSITION 51.
PARAMETERS: p_step2 RADIOBUTTON GROUP ab1.
SELECTION-SCREEN: COMMENT 60(4) text-013 FOR FIELD p_step3,
                  POSITION 66.
PARAMETERS: p_step3 RADIOBUTTON GROUP ab1  DEFAULT 'X'.
SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN END OF BLOCK option.
SELECTION-SCREEN ULINE.
SELECT-OPTIONS:
  s_reqit  FOR ztitrqp-reqit MODIF ID iog,  "수입의뢰 품목번호.
  s_ebelp  FOR ztitrqp-ebelp MODIF ID iog,  "구매문서 품목번호.
  s_opnbk  FOR ztitrqk-opnbk MODIF ID iog,  "개설은행.
  s_appct  FOR ztitrqk-appct MODIF ID iog,  "수입자 구분.
  s_opnno  FOR ztitrqs-opnno MODIF ID iog,  "수입개설번호
  s_opndt  FOR ztitrqs-opndt MODIF ID iog,  "개설일자.
  s_zterm  FOR ztitrqs-zterm MODIF ID iog,  "지급조건키.
  s_mblnr  FOR ztitrqp-mblnr MODIF ID iog,  "자재문서번호.
  s_mjahr  FOR ztitrqp-mjahr MODIF ID iog,  "자재문서연도.
  s_zeile  FOR ztitrqp-zeile MODIF ID iog,  "자재문서품목.
  s_waers  FOR ztitrqs-waers MODIF ID iog,  "개설통화.
  s_inco1  FOR ztitrqs-inco1 MODIF ID iog,  "인도조건 (파트 1).
  s_inco2  FOR ztitrqs-inco2 MODIF ID iog,  "인도조건 (파트 2).
  s_ediyn  FOR ztitrqs-ediyn MODIF ID iog,  "EDI 적용여부.
  s_insyn  FOR ztitrqs-insyn MODIF ID iog,  "적하보험대상여부.
  s_fwdty  FOR ztitrqs-fwdty MODIF ID iog,  "운송 방법.
  s_fland  FOR ztitrqs-fland MODIF ID iog,  "선적국가.
  s_fport  FOR ztitrqs-fport MODIF ID iog,  "선적항.
  s_pllod  FOR ztitrqs-pllod MODIF ID iog, 	"COM:선적항.
  s_tland  FOR ztitrqs-tland MODIF ID iog,  "도착국가.
  s_tport  FOR ztitrqs-tport MODIF ID iog,  "도착항.
  s_pltrn  FOR ztitrqs-pltrn MODIF ID iog,  "COM:도착항.
  s_reqdt  FOR ztitrqs-reqdt MODIF ID iog,  "개설희망일자.
  s_appun  FOR ztitrqs-appun MODIF ID iog,  "개설의뢰 요청자.
  s_appdt  FOR ztitrqs-appdt MODIF ID iog,  "개설의뢰 요청일.
  s_apptm  FOR ztitrqs-apptm MODIF ID iog,  "개설의뢰 요청시간.
  s_accun  FOR ztitrqs-accun MODIF ID iog,  "요청접수 담당자.
  s_accdt  FOR ztitrqs-accdt MODIF ID iog,  "요청접수일자.
  s_acctm  FOR ztitrqs-acctm MODIF ID iog,  "요청접수시간.
  s_sndun  FOR ztitrqs-sndun MODIF ID iog,  "개설신청자.
  s_snddt  FOR ztitrqs-snddt MODIF ID iog,  "개설신청일.
  s_sndtm  FOR ztitrqs-sndtm MODIF ID iog,  "개설신청시간.
  s_rcvun  FOR ztitrqs-rcvun MODIF ID iog,  "개설등록자.
  s_rcvdt  FOR ztitrqs-rcvdt MODIF ID iog,  "개설등록일자.
  s_rcvtm  FOR ztitrqs-rcvtm MODIF ID iog,  "개설등록시간.
  s_recid  FOR ztitrqs-recid MODIF ID iog,  "수신자 ID.
  s_recnm  FOR ztitrqs-recnm MODIF ID iog,  "수신자 명.
  s_recno  FOR ztitrqs-recno MODIF ID iog,  "문서번호.
  s_docst  FOR ztitrqs-docst MODIF ID iog,  "문서상태.
  s_rqmng  FOR ztitrqp-rqmng MODIF ID iog,  "수입의뢰수량.
  s_meins  FOR ztitrqp-meins MODIF ID iog,  "기본단위.
  s_ctme   FOR ztitrqp-ctme  MODIF ID iog,  "생성시간.
  s_utme   FOR ztitrqp-utme  MODIF ID iog.  "최종변경시간.
SELECTION-SCREEN END OF BLOCK dbsel.

SELECTION-SCREEN BEGIN OF BLOCK lists WITH FRAME TITLE text-002.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK lists.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE zts_reuse_alvforms_f00.  "> AVL 공용 Subroutines.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    type c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* INITIALIZATION Event                                                 *
************************************************************************
INITIALIZATION.
*> Read default layout (description only, w/o field catalog)
  PERFORM  p1000_alv_fields_initial.
*> Report initialization
  PERFORM  p1001_initialization.

************************************************************************
* AT SELECTION-SCREEN Events                                           *
************************************************************************
AT SELECTION-SCREEN.
*> 사용자 Input values Check
  PERFORM p1100_check_input_values.
*> 사용자 레이아웃 Input values Check
  PERFORM p1101_check_variant_value.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING s_bukrs-low.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> 레이아웃 HELP
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM p1102_f4_for_variant.
*> 지급조건 HELP(Low values)
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_zterm-low.
  PERFORM get_f4_for_zterm(ztir0000) USING s_zterm-low.
*> 지급조건 HELP(High values)
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_zterm-high.
  PERFORM get_f4_for_zterm(ztir0000) USING s_zterm-high.

************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.
*> 검색조건에 해당하는 데이타를 Select.
  PERFORM p2000_data_selections.
*> Header table과 List(Items) table를 만듬.
  PERFORM p2100_header_and_list_build.
*> Header table 금액 조정.
  PERFORM p2101_adjust_header_amount.

************************************************************************
* END-OF-SELECTION Event                                               *
************************************************************************
END-OF-SELECTION.
  DESCRIBE TABLE it_tab LINES g_line.
  IF NOT g_line IS INITIAL.
*> PROGRESS Display.
    g_linen    = 90.
    g_out_text = '리스트를 구성 중입니다 %99999%%'(p03).
    REPLACE '%99999%'(p99) WITH g_linen INTO g_out_text.
    PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

    PERFORM 3000_field_category_build.
    PERFORM 3100_set_color_infomation.
    PERFORM 3200_key_infomation_build.
    PERFORM 3300_event_exit_table_build.
    PERFORM 3400_comment_build.
    PERFORM 3500_sort_table_build.
    PERFORM 3600_event_table_build USING : slis_ev_top_of_page,
                                           slis_ev_pf_status_set,
                                           slis_ev_user_command.
    PERFORM 3700_layout_build.
*    REFRESH IT_LIST.
    PERFORM 3910_call_alv_hierseq.
*> Program 종료.
    PERFORM  p9000_program_exit.
  ENDIF.
****************u*******************************************************
*
* TOP-OF-PAGE Event                                                    *
************************************************************************
TOP-OF-PAGE.

************************************************************************
* END-OF-PAGE Event                                                    *
************************************************************************
END-OF-PAGE.

************************************************************************
* TOP-OF-PAGE DURING LINE-SELECTION Event                              *
************************************************************************
TOP-OF-PAGE DURING LINE-SELECTION.


************************************************************************
* AT LINE-SELECTION Event                                              *
************************************************************************
AT LINE-SELECTION.


************************************************************************
* AT USER-COMMAND Event                                                *
************************************************************************
AT USER-COMMAND.

*eject
************************************************************************
*                                                                      *
* S U B R O U T I N E S                                                *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
FORM p1001_initialization .

  SET TITLEBAR 'T1000' WITH 'Due List'(t10).

ENDFORM.                    " p1001_initialization

*&---------------------------------------------------------------------*
*&      Form  p1100_check_input_values
*&---------------------------------------------------------------------*
FORM p1100_check_input_values .

  TABLES: dfies.

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
    MESSAGE e348(m7) WITH '회사코드'.
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

ENDFORM.                    " p1100_check_input_values

*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
FORM p2000_data_selections .

  DATA: l_rqmng  LIKE ztitrqp-rqmng,
        l_check  TYPE i.

  RANGES: lr_ppaid   FOR   ztitrqk-ppaid OCCURS 1,
          lr_anbty   FOR   ztitrqk-ppaid OCCURS 1.

  CLEAR: g_count, it_tab, it_ztitig02, it_header, it_list.
  REFRESH : it_tab, it_ztitig02, it_header, it_list.
*> PROGRESS Display.
  g_linen    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

  CLEAR lr_ppaid .
  MOVE: 'I'     TO    lr_ppaid-sign,
        'EQ'    TO    lr_ppaid-option.
  CASE 'X'.
    WHEN p_step1. ">선급금.
      MOVE: 'X'   TO  lr_ppaid-low.    APPEND lr_ppaid .
    WHEN p_step2. ">사전T/T이나 선급금아님.
      MOVE: space TO  lr_ppaid-low.    APPEND lr_ppaid .
    WHEN p_step3. ">all
      REFRESH lr_ppaid.
  ENDCASE.
  CLEAR lr_anbty .
  MOVE: 'I'     TO    lr_anbty-sign,
        'EQ'    TO    lr_anbty-option.
  CASE 'X'.
    WHEN p_step4. ">사전.
      MOVE: 'B'   TO  lr_anbty-low.    APPEND lr_anbty .
    WHEN p_step5. ">사후.
      MOVE: 'A'   TO  lr_anbty-low.    APPEND lr_anbty .
    WHEN p_step6. ">all
      REFRESH lr_anbty.
  ENDCASE.
*> 수입의뢰 데이타 select.
  SELECT *
        INTO CORRESPONDING FIELDS OF TABLE it_tab
        FROM ztivrq00 AS a JOIN ekpo AS b
             ON  a~ebeln EQ b~ebeln
             AND a~ebelp EQ b~ebelp
        WHERE a~bukrs  IN s_bukrs  "회사코드.
          AND a~reqno  IN s_reqno  "수입의뢰 관리번호.
*          AND a~amdsq  IN s_amdsq  "Amend 차수
*          AND a~ilcty  IN s_ilcty  "신용장 종류.
          AND a~lifnr  IN s_lifnr  "공급업체 계정번호.
          AND a~lifre  IN s_lifre  "다른 송장발행처.
          AND a~offer  IN s_offer  "오퍼상(Offer).
          AND a~opnbk  IN s_opnbk  "개설은행.
          AND a~ekorg  IN s_ekorg  "구매조직.
          AND a~ekgrp  IN s_ekgrp  "구매그룹.
          AND a~appct  IN s_appct  "수입자 구분.
          AND a~opnno  IN s_opnno  "수입개설번호
          AND a~opndt  IN s_opndt  "개설일자.
          AND a~zterm  IN s_zterm  "지급조건키.
          AND a~waers  IN s_waers  "개설통화.
          AND a~inco1  IN s_inco1  "인도조건 (파트 1).
          AND a~inco2  IN s_inco2  "인도조건 (파트 2).
          AND a~exdat  IN s_exdat  "COM:유효기일.
          AND a~lsdat  IN s_lsdat  "COM:최종선적일자.
          AND a~ediyn  IN s_ediyn  "EDI 적용여부.
          AND a~insyn  IN s_insyn  "적하보험대상여부.
          AND a~fwdty  IN s_fwdty  "운송 방법.
          AND a~fland  IN s_fland  "선적국가.
          AND a~fport  IN s_fport  "선적항.
          AND a~pllod  IN s_pllod  "COM:선적항.
          AND a~tland  IN s_tland  "도착국가.
          AND a~tport  IN s_tport  "도착항.
          AND a~pltrn  IN s_pltrn  "COM:도착항.
          AND a~reqdt  IN s_reqdt  "개설희망일자.
          AND a~appun  IN s_appun  "개설의뢰 요청자.
          AND a~appdt  IN s_appdt  "개설의뢰 요청일.
          AND a~apptm  IN s_apptm  "개설의뢰 요청시간.
          AND a~accun  IN s_accun  "요청접수 담당자.
          AND a~accdt  IN s_accdt  "요청접수일자.
          AND a~acctm  IN s_acctm  "요청접수시간.
          AND a~sndun  IN s_sndun  "개설신청자.
          AND a~snddt  IN s_snddt  "개설신청일.
          AND a~sndtm  IN s_sndtm  "개설신청시간.
          AND a~rcvun  IN s_rcvun  "개설등록자.
          AND a~rcvdt  IN s_rcvdt  "개설등록일자.
          AND a~rcvtm  IN s_rcvtm  "개설등록시간.
          AND a~recid  IN s_recid  "수신자 ID.
          AND a~recnm  IN s_recnm  "수신자 명.
          AND a~recno  IN s_recno  "문서번호.
          AND a~docst  IN s_docst  "문서상태.
          AND a~reqit  IN s_reqit  "수입의뢰 품목번호.
          AND a~ebeln  IN s_ebeln  "구매전표번호.
          AND a~ebelp  IN s_ebelp  "구매문서 품목번호.
          AND a~rqmng  IN s_rqmng  "수입의뢰수량.
          AND a~meins  IN s_meins  "기본단위.
          AND a~mblnr  IN s_mblnr  "자재문서번호.
          AND a~mjahr  IN s_mjahr  "자재문서연도.
          AND a~zeile  IN s_zeile  "자재문서품목.
          AND a~cnam   IN s_cnam   "작성인.
          AND a~cdat   IN s_cdat   "생성일.
          AND a~ctme   IN s_ctme   "생성시간.
          AND a~unam   IN s_unam   "최종변경인.
          AND a~udat   IN s_udat   "변경일.
          AND a~utme   IN s_utme   "최종변경시간.
          AND b~matkl  IN s_matkl
*         구매오더의 송장처리 지시자 mark된것.(for무환제외)
          AND b~repos  EQ 'X'
*>        수입의뢰 종류 중 T/T 이면서 사전인것 + 사후도(1024 add.).
          AND a~reqty  EQ 'TT'
*          AND a~ANBTY  EQ 'B'
*         유보금은 제외.
          AND a~rpaid  NE 'X'
*         문서상태 'O'인것만.
*          AND a~docst  in ('O', 'Y', 'W', '1')
          AND a~anbty  IN lr_anbty
          AND a~ppaid  IN lr_ppaid.
  IF sy-subrc NE 0.
    MESSAGE s902.
    EXIT.
  ENDIF.

  CLEAR: g_tabix, g_count, g_cnt.
  LOOP AT it_tab.

    g_tabix = sy-tabix.

*> 050704 JP, PARK 추가.
    SELECT SINGLE COUNT( * )
       INTO l_check
       FROM ztitivp
       WHERE reqno EQ it_tab-reqno.
    IF sy-subrc EQ 0.
      DELETE it_tab INDEX g_tabix.
      CONTINUE.
    ENDIF.


    IF it_tab-ppaid EQ 'X'.
      it_tab-ppaix = '선급금'.
    ELSE.
      CLEAR it_tab-ppaix.
    ENDIF.

*   domain의 value.
    PERFORM get_domain_value_text(ztir0000) USING :
                          'ZTIANBTY'  it_tab-anbty  it_tab-anbtx,
                          'ZTIDOCST'  it_tab-docst  it_tab-docstx,
                          'ZTIILCTY'  it_tab-ilcty  it_tab-ilctyx.

*   공급업체등/다른 송장발행처/오퍼상(Offer) lifnr/lifre/offer
    SELECT SINGLE name1 INTO it_tab-name1
      FROM lfa1
     WHERE lifnr EQ it_tab-lifnr.

    SELECT SINGLE name1 INTO it_tab-name4
      FROM lfa1
     WHERE lifnr EQ it_tab-offer.
*   개설은행  opnbk
    SELECT SINGLE namet INTO it_tab-namet
      FROM ztstig3
     WHERE epart EQ it_tab-opnbk.
*   수입의뢰 수량, 누적수량, 가능수량, p/o수량.

    SELECT  SINGLE menge werks matnr txz01
      INTO  (it_tab-menge, it_tab-werks, it_tab-matnr, it_tab-txz01)
      FROM  ekpo
     WHERE  ebeln  = it_tab-ebeln
       AND  ebelp  = it_tab-ebelp.
*
*   누적수량.
    SELECT  SUM( remng )
      INTO  it_tab-ivmngs
      FROM  ztiviv00
     WHERE  reqno  = it_tab-reqno
       AND  reqit  = it_tab-reqit.
*   가능수량.
    it_tab-ivmngl =  it_tab-rqmng - it_tab-ivmngs.

    IF it_tab-ivmngl LE 0.
      DELETE it_tab INDEX g_tabix.
      CONTINUE.
    ENDIF.

    ADD 1 TO g_count.

    MOVE 1 TO it_tab-count.

    MODIFY it_tab INDEX g_tabix.
  ENDLOOP.

  IF g_count EQ 0.
    MESSAGE s103.
    EXIT.
  ENDIF.


ENDFORM.                    " p2000_data_selections
*&---------------------------------------------------------------------*
*&      Form  3000_field_category_build
*&---------------------------------------------------------------------*
FORM 3000_field_category_build .

*----------------------------------------------------------------------*
* 필드명과 Output Length등을 사용자의 입맛에 맞게 바꿈.
*----------------------------------------------------------------------*
  PERFORM 3010_fill_field_category USING :
*>>>>>>HEADER
"BOX.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   ' ',
          ' ' 'FIELDNAME'     'BOX',
          ' ' 'HOTSPOT'       ' ',       " Double Click 효과
          'E' 'KEY'           ' ',
"수입의뢰 관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQK',
*          ' ' 'seltext_m'     'HEADER Middle TEXT(20)',
          ' ' 'FIELDNAME'     'REQNO',
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"Amend 차수
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'seltext_m'     'AMEND',
          ' ' 'FIELDNAME'     'AMDSQ',
          ' ' 'JUST'          c_charl,
          ' ' 'LZERO'         c_charx,
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"문서상태
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'seltext_m'     '사전/사후',
          ' ' 'FIELDNAME'     'ANBTX',
          'E' 'OUTPUTLEN'     '10',
"선급여부
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'seltext_m'     '선급여부',
          ' ' 'FIELDNAME'     'PPAIX',
          ' ' 'OUTPUTLEN'     9,
          'E' 'HOTSPOT'       'X',

"공급업체코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'LIFNR',
          ' ' 'OUTPUTLEN'     10,
          'E' 'HOTSPOT'       'X',

"공급업체명
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'OUTPUTLEN'     50,
          'E' 'FIELDNAME'     'NAME1',

"유효기일
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'JUST'          c_charr," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
*          ' ' 'seltext_m'     '종류',
          ' ' 'FIELDNAME'     'EXDAT',
          'E' 'OUTPUTLEN'     '13',

"최종선적일자
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'JUST'          c_charr," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
*          ' ' 'seltext_m'     '종류',
          ' ' 'FIELDNAME'     'LSDAT',
          'E' 'OUTPUTLEN'     '13',

"수입의뢰 종류
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQK',
          ' ' 'seltext_m'     '종류',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'REQTY',
          'E' 'OUTPUTLEN'     '4',
"신용장 종류 TEXT
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQK',
          ' ' 'seltext_m'     '신용장 종류',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'ILCTYX',
          'E' 'OUTPUTLEN'     '13',
"수입개설번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'OPNNO',
*          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '17',
"회사코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQK',
          ' ' 'FIELDNAME'     'BUKRS',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '4',
"개설일자
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'OPNDT',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"개설은행.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'seltext_m'     '개설은행',
          ' ' 'FIELDNAME'     'NAMET',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '15',

"Offer상
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'seltext_m'     'Offer상',
          ' ' 'FIELDNAME'     'NAME4',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '15',
"개설통화
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'WAERS',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '4',
"개설금액.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'OPAMT',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'NO_OUT'        'X',
          'E' 'CTABNAME'      'IT_HEADER',
*          ' ' 'OUTPUTLEN'     '10',
*>>>>>>>>>LIST
"수입의뢰 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'FIELDNAME'     'REQIT',
          ' ' 'JUST'          c_charl," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"구매전표번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'FIELDNAME'     'EBELN',
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '12',
"구매문서 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'FIELDNAME'     'EBELP',
          ' ' 'JUST'          c_charl," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
          ' ' 'HOTSPOT'       ' ',       " Double Click 효과
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '10',
"자재그룹.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'FIELDNAME'     'MATKL',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '18',
"자재.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISRQIT',
          ' ' 'FIELDNAME'     'MATNR',
          'E' 'OUTPUTLEN'     '20',
"자재내역.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISRQIT',
          ' ' 'FIELDNAME'     'TXZ01',
          'E' 'OUTPUTLEN'     '50',

"P/O 수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'EKPO',
          ' ' 'seltext_L'     'P/O 수량',
          ' ' 'seltext_m'     'P/O 수량',
          ' ' 'seltext_S'     'P/O 수량',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'MENGE',
          ' ' 'OUTPUTLEN'     '13',
          'E' 'KEY'           ' ',
"수입의뢰수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'JUST'          c_charr," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
          ' ' 'FIELDNAME'     'RQMNG',
          ' ' 'OUTPUTLEN'     '13',
          'E' 'KEY'           ' ',

"I/V 가능 수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISIVIT',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'seltext_L'     'I/V가능수량',
          ' ' 'seltext_m'     'I/V가능수량',
          ' ' 'seltext_S'     'I/V가능수량',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'JUST'          c_charr," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
          ' ' 'OUTPUTLEN'     '13',
          ' ' 'FIELDNAME'     'IVMNGL',
          'E' 'KEY'           ' ',

"I/V 누적수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISIVIT',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          ' ' 'seltext_L'     'I/V누적수량',
          ' ' 'seltext_m'     'I/V누적수량',
          ' ' 'seltext_S'     'I/V누적수량',
          ' ' 'OUTPUTLEN'     '13',
          ' ' 'FIELDNAME'     'IVMNGS',
          'E' 'KEY'           ' ',
"기본단위
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'FIELDNAME'     'MEINS',
          'E' 'OUTPUTLEN'     '4',
"작성인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'CNAM',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',

"변경인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'UNAM',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10'.

ENDFORM.                    " 3000_field_category_build

*&---------------------------------------------------------------------*
*&      Form  3200_KEY_INFOMATION_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM 3200_key_infomation_build .

  CLEAR gs_keyinfo.

  gs_keyinfo-header01 = 'REQNO'.
  gs_keyinfo-item01   = 'REQNO'.

  gs_keyinfo-header02 = 'AMDSQ'.
  gs_keyinfo-item02   = 'AMDSQ'.

  gs_keyinfo-header03 =  space.
  gs_keyinfo-item03   = 'REQIT'.
*  GS_KEYINFO-HEADER02 = SPACE.
*  GS_KEYINFO-ITEM02   = 'OBART'.
*
*  GS_KEYINFO-HEADER03 = SPACE.
*  GS_KEYINFO-ITEM03   = 'OBJNR'.

ENDFORM.                    " 3200_KEY_INFOMATION_BUILD
*&---------------------------------------------------------------------*
*&      Form  3100_SET_COLOR_INFOMATION
*&---------------------------------------------------------------------*
FORM 3100_set_color_infomation .

  DATA: color TYPE slis_t_specialcol_alv WITH HEADER LINE.
*> colorize
  DATA: ls_cnt TYPE i.

  LOOP AT it_list.
*    ls_cnt = sy-tabix MOD 2.

*    CLEAR: it_color,
*           GS_COLOR_INFO.
**    ON CHANGE OF LT_RESRC_VW-RESRC.
*      it_color-FIELDNAME = 'REQNO'.
*      it_color-COLOR-COL = '5'.
*      APPEND GS_COLOR_INFO TO it_color.
*      MODIFY it_list.
**    ENDON.

  ENDLOOP.                             " AT LT_RESRC_VW

ENDFORM.                    " 3100_SET_COLOR_INFOMATION
*&---------------------------------------------------------------------*
*&      Form  3400_COMMENT_BUILD
*&---------------------------------------------------------------------*
FORM 3400_comment_build .

  DATA: l_text20(20) TYPE c.

  CLEAR: it_listheader, gs_listheader.
  REFRESH: it_listheader.

* LIST HEADING LINE: TYPE H
  CLEAR gs_listheader.
  gs_listheader-typ  = 'H'.
* gs_listheader-KEY:  NOT USED FOR THIS TYPE
  gs_listheader-info = 'T/T I/V Due List'(t13).
*  SHIFT gs_listheader-info RIGHT BY 20 PLACES.
  APPEND gs_listheader TO it_listheader.

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: l_butxt LIKE t001-butxt.
  CLEAR: l_butxt.
  SELECT SINGLE butxt FROM t001
                      INTO l_butxt
                     WHERE bukrs EQ s_bukrs-low.

  CLEAR gs_listheader.
  gs_listheader-typ  = 'A'.
  gs_listheader-info = '회사코드 :'.
  CONCATENATE gs_listheader-info s_bukrs-low l_butxt
         INTO gs_listheader-info SEPARATED BY space.
  APPEND gs_listheader TO it_listheader.
** JS전선 회사코드 2007/04 KSH --------------------------------------

* ACTION LINE: TYPE A
  CLEAR gs_listheader.
  gs_listheader-typ  = 'A'.
  gs_listheader-info = '출력일자 :'(t12).
  WRITE: sy-datlo TO l_text20.
  CONCATENATE gs_listheader-info l_text20 INTO gs_listheader-info
              SEPARATED BY space.
  APPEND gs_listheader TO it_listheader.

ENDFORM.                    " 3400_COMMENT_BUILD
*&---------------------------------------------------------------------*
*&      Form  3500_SORT_TABLE_BUILD
*&---------------------------------------------------------------------*
FORM 3500_sort_table_build .

  DATA: ls_sort TYPE slis_sortinfo_alv.

  CLEAR ls_sort.
  ls_sort-spos      = 1.
  ls_sort-fieldname = 'REQNO'.
  ls_sort-tabname   = 'IT_LIST'.
  ls_sort-up        = 'X'.
* LS_SORT-GROUP     = '*'.             " Seiten- bei Gruppenwechsel
*  ls_sort-group     = 'UL'.            " Underline      -"-
  APPEND ls_sort TO it_sort.

ENDFORM.                    " 3500_SORT_TABLE_BUILD
*&---------------------------------------------------------------------*
*&      Form  3700_LAYOUT_build
*&---------------------------------------------------------------------*
FORM 3700_layout_build .

  MOVE: 'BOX'        TO gs_layout-box_fieldname,
        'IT_HEADER'  TO gs_layout-box_tabname.

*  MOVE: '3'          TO gs_layout-no_vline. " 분리자 라인.

ENDFORM.                    " 3700_LAYOUT_build

*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
FORM top_of_page.                                           "#EC CALLED

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = it_listheader[].



ENDFORM.                    "TOP_OF_PAGE

*---------------------------------------------------------------------*
*       Form  USER_COMMAND                                            *
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  DATA: ls_header TYPE ty_tab.

  CLEAR: ls_header.

  CASE r_ucomm.
    WHEN  '&REFRESH'.

*    > 검색조건에 해당하는 데이타를 Select.
      PERFORM p2000_data_selections.
*    > Header table과 List(Items) table를 만듬.
      PERFORM p2100_header_and_list_build.
*    > Header table 금액 조정.
      PERFORM p2101_adjust_header_amount.

      DESCRIBE TABLE it_tab LINES g_line.
      IF NOT g_line IS INITIAL.
        rs_selfield-refresh = 'X'.
      ELSE.
*    > Program 종료.
        PERFORM  p9000_program_exit.
      ENDIF.

*      PERFORM p9000_duelist_refresh USING  rs_selfield.

    WHEN 'ZTIT001'. " 후속기능
*> 개설 의뢰 상태에 따라 ZTIT005(접수) ZTIT006(신청) ZTIT007(개설)
      CLEAR : g_line, ls_header.
      LOOP AT it_header WHERE box EQ 'X'.
        ADD 1 TO g_line.
        MOVE-CORRESPONDING it_header TO ls_header.
      ENDLOOP.
      CASE g_line.
        WHEN 0.
          IF rs_selfield-tabname EQ 'IT_HEADER'.
            READ TABLE it_header INDEX rs_selfield-tabindex.
          ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
            READ TABLE it_list INDEX rs_selfield-tabindex.
          ENDIF.
          IF sy-subrc NE 0.
            MESSAGE s003(ok). EXIT.
          ENDIF.
          IF rs_selfield-tabname EQ 'IT_HEADER'.
            MOVE-CORRESPONDING it_header TO ls_header.
          ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
            MOVE-CORRESPONDING it_list   TO ls_header.
          ENDIF.
        WHEN 1.
*          SET PARAMETER ID 'ZTIIBLNO' FIELD ' '.
*          SET PARAMETER ID 'ZTIBLNUM' FIELD ' '.
*          SET PARAMETER ID 'ZTIREQNO' FIELD it_header-reqno.
*          CALL TRANSACTION 'ZTIT301'." AND SKIP FIRST SCREEN .
          PERFORM create_invoice_document.

*        > 검색조건에 해당하는 데이타를 Select.
          PERFORM p2000_data_selections.
*        > Header table과 List(Items) table를 만듬.
          PERFORM p2100_header_and_list_build.
*        > Header table 금액 조정.
          PERFORM p2101_adjust_header_amount.

          DESCRIBE TABLE it_tab LINES g_line.
          IF NOT g_line IS INITIAL.
            rs_selfield-refresh = 'X'.
          ELSE.
*        > Program 종료.
            PERFORM  p9000_program_exit.
          ENDIF.

*          PERFORM p9000_duelist_refresh USING  rs_selfield.

        WHEN OTHERS.
          MESSAGE s035(0k).   EXIT.
      ENDCASE.


    WHEN '&IC1'.

      IF rs_selfield-tabname EQ 'IT_HEADER'.
        READ TABLE it_header INDEX rs_selfield-tabindex.
      ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
        READ TABLE it_list INDEX rs_selfield-tabindex.
      ENDIF.
      IF sy-subrc NE 0.
        MESSAGE s903. EXIT.
      ENDIF.

      IF rs_selfield-tabname EQ 'IT_HEADER'.
        MOVE-CORRESPONDING it_header TO ls_header.
      ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
        MOVE-CORRESPONDING it_list   TO ls_header.
      ENDIF.

      CASE rs_selfield-fieldname.
        WHEN 'EBELN'.
          PERFORM  display_purchase_order(ztir0000)
                                          USING ls_header-ebeln
                                                ls_header-ebelp.

        WHEN 'AMDSQ' OR 'REQNO'.
          SET PARAMETER ID 'ZTIREQNO' FIELD ls_header-reqno.
          SET PARAMETER ID 'ZTIAMDSQ' FIELD ls_header-amdsq.
          CALL TRANSACTION 'ZTIT003' AND SKIP FIRST SCREEN.

        WHEN 'LIFNR'.
          PERFORM display_vendor_master(ztir0000)
                                          USING ls_header-lifnr
                                                ls_header-ekorg.
      ENDCASE.
    WHEN OTHERS.
  ENDCASE.

  CLEAR: r_ucomm.

ENDFORM.                    "USER_COMMAND
*---------------------------------------------------------------------*
*       FORM PF_STATUS_SET                                            *
*---------------------------------------------------------------------*
FORM pf_status_set USING rt_extab TYPE slis_t_extab.

  SET TITLEBAR 'T1000' WITH 'Due List'(t10).

  REFRESH: rt_extab.

  APPEND 'ARCHIVE'   TO rt_extab.
  APPEND '&VEXCEL'   TO rt_extab.
  APPEND '&AQW'      TO rt_extab.
  APPEND '&VCRYSTAL' TO rt_extab.
  APPEND '&VGRID'    TO rt_extab.
  APPEND '&EB9'      TO rt_extab.
  APPEND '&CRDESIG'  TO rt_extab.
  APPEND '&XXL'      TO rt_extab.
  APPEND '&ABC'      TO rt_extab.

  SET PF-STATUS 'STANDARD ' EXCLUDING rt_extab.
*SET PF-STATUS 'ABCD' OF PROGRAM PROG.

ENDFORM.                    "PF_STATUS_SET
*&---------------------------------------------------------------------*
*&      Form  p2101_adjust_header_amount
*&---------------------------------------------------------------------*
*       헤더금액 조정.
*----------------------------------------------------------------------*
FORM p2101_adjust_header_amount .
  LOOP AT it_header.
    it_header-opamt = it_header-opamt / it_header-count.
    MODIFY it_header.
  ENDLOOP.
ENDFORM.                    " p2101_adjust_header_amount

*eject
************************************************************************
*                                                                      *
* P B O   M O D U L E                                                  *
*                                                                      *
************************************************************************

*eject
************************************************************************
*                                                                      *
* P A I   M O D U L E                                                  *
*                                                                      *
***********************************************************************
*&---------------------------------------------------------------------*
*&      Form  create_invoice_document
*&---------------------------------------------------------------------*
FORM create_invoice_document .

  DATA: l_subrc LIKE  sy-subrc.

  REFRESH: bdcdata.", it_msg.
  CLEAR: session.
  ctu_params-dismode  = 'E'. ">처리모드
  ctu_params-updmode  = 'S'. ">갱신모드
  ctu_params-cattmode = ' '. ">CATT 모드...
  ctu_params-defsize  = ' '. ">기본화면 크기
  ctu_params-racommit = 'X'.
  ctu_params-nobinpt  = ' ' .
  ctu_params-nobiend  = ' '.

*> 초기화면.
  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR3000'          '0100',
         ' ' 'BDC_OKCODE'       '=ZTICOPY'.
*> 초기화면.
  PERFORM bdc_dynpro_build USING :
         'X' 'ZTIR3000'          '7000',
         ' ' 'ZTISSCRCOM-REQNO'  it_header-reqno,
         ' ' 'BDC_OKCODE'       '=FCOPY'.

**> 세부화면.
*  PERFORM bdc_dynpro_build USING :
*         'X' 'ZTIR3000'         '2000',
*         ' ' 'ZTITIVHD-IVNUM'   it_header-opnno,
*         ' ' 'ZTITIVHD-CIVDT'   it_header-opndt,
*         ' ' 'ZTITIVHD-BUDAT'   sy-datlo,
**         ' ' 'ZTITIVHD-BLDAT'   '',
**         ' ' 'ZTITIVHD-BUPLA'   it_header-bupla,
*         ' ' 'ZTITIVHD-GSBER'   '1110',
*         ' ' 'ZTITIVHD-BLART'   'RE',
**         ' ' 'ZTITIVHD-MWSKZ'   it_header-mwskz,
*         ' ' 'ZTITIVHD-ZTERM'   it_header-zterm,
**         ' ' 'ZTITIVHD-PKCHG'   '',
**         ' ' 'ZTITIVHD-HDCHG'   '',
**         ' ' 'ZTITIVHD-OTCHG'   '',
*         ' ' 'ZTITIVHD-ZLSPR'   'M',
**         ' ' 'ZTITIVHD-RTCHG'   '',
*         ' ' 'ZTITIVHD-ZLSCH'   'C',
*         ' ' 'ZTITIVHD-XBLNR'   it_header-opnno,
*         ' ' 'ZTITIVHD-BKTXT'   '수입물대금액(사전)',
*         ' ' 'ZTITIVHD-SGTXT'   '아이템 텍스트'.
*ZTISIVIT-SGTXT(01)
*ZTISIVIT-SGTXT(02)
*         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
*
*  PERFORM bdc_dynpro_build USING :
*         'X' 'SAPLSPO1'         '0300',
*         ' ' 'BDC_OKCODE'       '=YES'.

  PERFORM bdc_transaction USING 'ZTIT301' l_subrc.

ENDFORM.                    " create_invoice_document
