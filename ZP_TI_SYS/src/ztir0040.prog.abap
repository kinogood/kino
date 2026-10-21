************************************************************************
* Title         :  ZTIR0040                                            *
*                                                                      *
* Description   : [Report] 수입요청(개설) 현황                         *
*                                                                      *
* Creation Date : 2004/02/05                                           *
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
REPORT  ztir0040       MESSAGE-ID zmti00
                       NO STANDARD PAGE HEADING.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE zts_reuse_alvforms_t00.  "> AVL 공용 Data 선언.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    type c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF ty_header,
            box         TYPE c,
            reqno       LIKE ztitrqk-reqno,  "수입의뢰 관리번호.
            amdsq       LIKE ztitrqs-amdsq,  "Amend 차수.
            reqty       LIKE ztitrqk-reqty,  "수입의뢰 종류.
            ilcty       LIKE ztitrqk-ilcty,  "신용장 종류.
            ilctyx(15)  TYPE c,              "신용장 종류TEXT.
            lifnr       LIKE ztitrqk-lifnr,  "공급업체 계정번호.
            lifre       LIKE ztitrqk-lifre,  "다른 송장발행처.
            offer       LIKE ztitrqk-offer,  "오퍼상(Offer).
            opnbk       LIKE ztitrqk-opnbk,  "개설은행.
            bukrs       LIKE ztitrqk-bukrs,  "회사코드.
            ekorg       LIKE ztitrqk-ekorg,  "구매조직.
            ekgrp       LIKE ztitrqk-ekgrp,  "구매그룹.
            appct       LIKE ztitrqk-appct,  "수입자 구분.
            lstas       LIKE ztitrqk-lstas,  "최종 Amend 차수.
            anbty       LIKE ztitrqk-anbty,  "사전/사후 구분자.
            ppaid       LIKE ztitrqk-ppaid,  "선급금 여부.
            pprat       LIKE ztitrqk-pprat,  "선급금 비율.
            rpaid       LIKE ztitrqk-rpaid,  "유보금 여부.
            rprat       LIKE ztitrqk-rprat,  "유보금 비율.
            pspnr       LIKE ztitrqk-pspnr,  "Project No.
            opnno       LIKE ztitrqs-opnno,  "수입개설번호
            opndt       LIKE ztitrqs-opndt,  "개설일자.
            zterm       LIKE ztitrqs-zterm,  "지급조건키.
            opamt       LIKE ztitrqs-opamt,  "개설금액.
            waers       LIKE ztitrqs-waers,  "통화키.
            lponr       LIKE ztitrqs-lponr,  "최종품목번호.
            inco1       LIKE ztitrqs-inco1,  "인도조건 (파트 1).
            inco2       LIKE ztitrqs-inco2,  "인도조건 (파트 2).
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
            sndun       LIKE ztitrqs-sndun,  "개설신청자.
            snddt       LIKE ztitrqs-snddt,  "개설신청일.
            sndtm       LIKE ztitrqs-sndtm,  "개설신청시간.
            rcvun       LIKE ztitrqs-rcvun,  "개설등록자.
            rcvdt       LIKE ztitrqs-rcvdt,  "개설등록일자.
            rcvtm       LIKE ztitrqs-rcvtm,  "개설등록시간.
            recid       LIKE ztitrqs-recid,  "수신자 ID.
            recnm       LIKE ztitrqs-recnm,  "수신자 명.
            recno       LIKE ztitrqs-recno,  "문서번호.
            docst       LIKE ztitrqs-docst,  "문서상태.
            docstx(8)   TYPE c,              "문서상태TEXT.
            count       TYPE i.
TYPES: END OF ty_header.

TYPES: BEGIN OF ty_item.
INCLUDE     TYPE        ty_header.
TYPES :     reqit       LIKE ztitrqp-reqit,  "수입의뢰 품목번호.
            ebeln       LIKE ztitrqp-ebeln,  "구매전표번호.
            ebelp       LIKE ztitrqp-ebelp,  "구매문서 품목번호.
            rqmng       LIKE ztitrqp-rqmng,  "수입의뢰수량.
            meins       LIKE ztitrqp-meins,  "기본단위.
            mblnr       LIKE ztitrqp-mblnr,  "자재문서번호.
            mjahr       LIKE ztitrqp-mjahr,  "자재문서연도.
            zeile       LIKE ztitrqp-zeile,  "자재문서품목.
            cnam        LIKE ztitrqs-cnam,   "작성인.
            cdat        LIKE ztitrqs-cdat,   "생성일.
            ctme        LIKE ztitrqs-ctme,   "생성시간.
            unam        LIKE ztitrqs-unam,   "최종변경인.
            udat        LIKE ztitrqs-udat,   "변경일.
            utme        LIKE ztitrqs-utme,   "최종변경시간.
            menge       LIKE ztisrqit-menge,
            rqmngs      LIKE ztisrqit-rqmngs,
            rqmngl      LIKE ztisrqit-rqmngl,
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
** JS전선 회사코드 2007/04 KSH --------------------------------------
*CONSTANTS:
*    c_bukrs     LIKE t001-bukrs     VALUE '1000'.   ">Company code
** JS전선 회사코드 2007/04 KSH --------------------------------------
************************************************************************
* Internal Tables                                                      *
************************************************************************
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
  s_bukrs  FOR ztitrqk-bukrs                "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk
                    MODIF  ID iog,
  s_ekorg  FOR ztitrqk-ekorg MODIF ID iog,  "구매조직.
  s_ekgrp  FOR ztitrqk-ekgrp MODIF ID iog,  "구매그룹.
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* 2004.10.20   Sung-ho Maeng                검색조건 추가.             *
*----------------------------------------------------------------------*
  s_ebeln  FOR ztitrqp-ebeln MODIF ID iog  "구매전표번호
                              MEMORY ID ebeln,
*----------------------------< INSERT END >----------------------------*
  s_reqno  FOR ztitrqk-reqno MODIF ID iog	  "수입의뢰 관리번호.
                              MEMORY ID ztireqno,
  s_amdsq  FOR ztitrqs-amdsq MODIF ID iog  "Amend 차수.
                              MEMORY ID ztiamdsq,
  s_reqty  FOR ztitrqk-reqty MODIF ID iog,  "수입의뢰 종류.
  s_ilcty  FOR ztitrqk-ilcty MODIF ID iog,  "신용장 종류.
  s_lifnr  FOR ztitrqk-lifnr MODIF ID iog,  "공급업체 계정번호.
  s_lifre  FOR ztitrqk-lifre MODIF ID iog,  "다른 송장발행처.
  s_offer  FOR ztitrqk-offer MODIF ID iog,  "오퍼상(Offer).
  s_opnbk  FOR ztitrqk-opnbk MODIF ID iog,  "개설은행.
  s_appct  FOR ztitrqk-appct MODIF ID iog,  "수입자 구분.
  s_opnno  FOR ztitrqs-opnno MODIF ID iog,  "수입개설번호
  s_opndt  FOR ztitrqs-opndt MODIF ID iog,  "개설일자.
  s_zterm  FOR ztitrqs-zterm MODIF ID iog,  "지급조건키.
  s_waers  FOR ztitrqs-waers MODIF ID iog,  "개설통화.
  s_inco1  FOR ztitrqs-inco1 MODIF ID iog,  "인도조건 (파트 1).
  s_inco2  FOR ztitrqs-inco2 MODIF ID iog,  "인도조건 (파트 2).
  s_exdat  FOR ztitrqs-exdat MODIF ID iog,  "COM:유효기일.
  s_lsdat  FOR ztitrqs-lsdat MODIF ID iog,  "COM:최종선적일자.
  s_fland  FOR ztitrqs-fland MODIF ID iog,  "선적국가.
  s_fport  FOR ztitrqs-fport MODIF ID iog,  "선적항.
  s_pllod  FOR ztitrqs-pllod MODIF ID iog,  "COM:선적항.
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
  s_cnam   FOR ztitrqs-cnam  MODIF ID iog,  "작성인.
  s_cdat   FOR ztitrqs-cdat  MODIF ID iog,  "생성일.
  s_ctme   FOR ztitrqs-ctme  MODIF ID iog,  "생성시간.
  s_unam   FOR ztitrqs-unam  MODIF ID iog,  "최종변경인.
  s_udat   FOR ztitrqs-udat  MODIF ID iog,  "변경일.
  s_utme   FOR ztitrqs-utme  MODIF ID iog.  "최종변경시간.
SELECTION-SCREEN END OF BLOCK dbsel.

SELECTION-SCREEN BEGIN OF BLOCK lists WITH FRAME TITLE text-002.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK lists.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE zts_reuse_alvforms_f00.  "> AVL 공용 Subroutines.

************************************************************************
* INITIALIZATION Event                                                 *
************************************************************************
INITIALIZATION.
*> Read default layout (description only, w/o field catalog)
  PERFORM p1000_alv_fields_initial.
*> Initializaton By Program
  PERFORM p1001_initialization.

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
    PERFORM 3910_call_alv_hierseq.
  ENDIF.

*> Program 종료.
  PERFORM  p9000_program_exit.

************************************************************************
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

  SET TITLEBAR 'T1000' WITH '요청(개설)대상'(t10).

ENDFORM.                    " p1001_initialization

*&---------------------------------------------------------------------*
*&      Form  p1100_check_input_values
*&---------------------------------------------------------------------*
FORM p1100_check_input_values .

  TABLES: dfies.

  DATA: l_bukrs   LIKE t001-bukrs,
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

  DATA: l_rqmng  LIKE ztitrqp-rqmng.

  CLEAR: g_count, it_tab, it_ztitig02, it_header, it_list.
  REFRESH : it_tab, it_ztitig02, it_header, it_list.
*> PROGRESS Display.
  g_linen    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

**> Get 수입가능 구매문서 종류 및 지급조건 .
*  PERFORM get_used_payment_term(ZTIr0000)  TABLES  it_ZTItig02
*                                           USING   g_subrc c_success.
*  IF g_subrc NE 0.
*    EXIT.
*  ENDIF.

*> 수입의뢰 데이타 select.
  SELECT *
        INTO CORRESPONDING FIELDS OF TABLE it_tab
        FROM ( ztitrqs AS a JOIN ztitrqk AS b
          ON a~reqno = b~reqno ) JOIN ztitrqp AS c
          ON a~reqno  = c~reqno
          AND a~amdsq = c~amdsq
        WHERE b~bukrs  IN s_bukrs  "회사코드.
          AND b~reqno  IN s_reqno  "수입의뢰 관리번호.
          AND a~amdsq  IN s_amdsq  "Amend 차수
          AND b~reqty  IN s_reqty  "수입의뢰 종류.
          AND b~ilcty  IN s_ilcty  "신용장 종류.
          AND b~lifnr  IN s_lifnr  "공급업체 계정번호.
          AND b~lifre  IN s_lifre  "다른 송장발행처.
          AND b~offer  IN s_offer  "오퍼상(Offer).
          AND b~opnbk  IN s_opnbk  "개설은행.
          AND b~ekorg  IN s_ekorg  "구매조직.
          AND b~ekgrp  IN s_ekgrp  "구매그룹.
          AND b~appct  IN s_appct  "수입자 구분.
          AND c~ebeln  IN s_ebeln  "구매전표번
          AND a~opnno  IN s_opnno  "수입개설번호
          AND a~opndt  IN s_opndt  "개설일자.
          AND a~zterm  IN s_zterm  "지급조건키.
          AND a~waers  IN s_waers  "개설통화.
          AND a~inco1  IN s_inco1  "인도조건 (파트 1).
          AND a~inco2  IN s_inco2  "인도조건 (파트 2).
          AND a~exdat  IN s_exdat  "COM:유효기일.
          AND a~lsdat  IN s_lsdat  "COM:최종선적일자.
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
          AND a~cnam   IN s_cnam   "작성인.
          AND a~cdat   IN s_cdat   "생성일.
          AND a~ctme   IN s_ctme   "생성시간.
          AND a~unam   IN s_unam   "최종변경인.
          AND a~udat   IN s_udat   "변경일.
          AND a~utme   IN s_utme.   "최종변경시간.

  IF sy-subrc NE 0.
    MESSAGE s902.
  ENDIF.

  CLEAR: g_tabix, g_count, g_cnt.
  LOOP AT it_tab.

    g_tabix = sy-tabix.
*   domain의 value.
    PERFORM get_domain_value_text(ztir0000) USING :
                          'ZTIDOCST1' it_tab-docst  it_tab-docstx,
                          'ZTIILCTY'  it_tab-ilcty  it_tab-ilctyx.

*   수입의뢰 수량, 누적수량, 가능수량, p/o수량.

    SELECT  SINGLE menge werks matnr txz01
      INTO  (it_tab-menge,it_tab-werks, it_tab-matnr, it_tab-txz01)
      FROM  ztivpo00
     WHERE  ebeln  = it_tab-ebeln
       AND  ebelp  = it_tab-ebelp.

    SELECT SINGLE name1 INTO it_tab-name2
      FROM lfa1
     WHERE lifnr EQ it_tab-lifnr.

*   누적수량.
    SELECT  SUM( rqmng ) INTO it_tab-rqmngs FROM ztivrq00
     WHERE  ebeln  = it_tab-ebeln
       AND  ebelp  = it_tab-ebelp.
*   가능수량.
    it_tab-rqmngl =  it_tab-menge - it_tab-rqmngs.

    ADD 1 TO g_count.

    MOVE 1 TO it_tab-count.

    MODIFY it_tab INDEX g_tabix.

  ENDLOOP.


**> select된 구매오더 데이타를 수입의뢰된 수량과 비교.
*  CLEAR: g_count, g_cnt.
*  LOOP AT it_tab.
*    g_tabix = sy-tabix.
*    CLEAR: l_rqmng.
*
*    SELECT  SUM( rqmng ) INTO it_tab-rqmngs FROM ZTIvrq00
*     WHERE  ebeln  = it_tab-ebeln
*       AND  ebelp  = it_tab-ebelp.
*
*    it_tab-rqmng =  it_tab-menge - it_tab-rqmngs.
*
*    IF it_tab-rqmng LE c_zero.
**      IF p_delete EQ c_true.
*      DELETE it_tab INDEX g_tabix.
*      CONTINUE.
**      ELSE.
**        it_tab-rqmng = 0.
**      ENDIF.
*    ELSE.
*      ADD 1 TO g_cnt.
*    ENDIF.
*
*    it_tab-rqmngl =  it_tab-rqmng.
*
*    ADD 1 TO g_count.
*    MODIFY it_tab INDEX g_tabix.
*  ENDLOOP.
*
*  IF g_cnt EQ 0.
*    MESSAGE s103.
*  ENDIF.
**

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
          'E' 'OUTPUTLEN'     '10',
"Amend 차수
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'seltext_m'     'AMEND',
          ' ' 'FIELDNAME'     'AMDSQ',
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          ' ' 'LZERO'         c_charx,     "YSH 2004,09,21
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '10',
"문서상태
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'seltext_m'     '문서상태',
          ' ' 'FIELDNAME'     'DOCSTX',
          'E' 'OUTPUTLEN'     '8',
"수입의뢰 종류
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQK',
          ' ' 'seltext_m'     '종류',
          ' ' 'FIELDNAME'     'REQTY',
          'E' 'OUTPUTLEN'     '4',
"신용장 종류 TEXT
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQK',
          ' ' 'seltext_m'     '신용장 종류',
          ' ' 'FIELDNAME'     'ILCTYX',
          'E' 'OUTPUTLEN'     '13',
"Project No.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQK',
          ' ' 'seltext_m'     '호선번호',
          ' ' 'FIELDNAME'     'PSPNR',
          ' ' 'JUST'          c_charl,     "YSH 2004,09,21.
          'E' 'OUTPUTLEN'     '18',
"개설통화
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'WAERS',
          'E' 'OUTPUTLEN'     '4',
"개설금액.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'OPAMT',
          ' ' 'CFIELDNAME'    'WAERS',
          'E' 'CTABNAME'      'IT_HEADER',
*          ' ' 'OUTPUTLEN'     '10',
"회사코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQK',
          ' ' 'FIELDNAME'     'BUKRS',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '4',

"수입개설번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'JUST'          c_charc,     "YSH 2004,09,21.
          'E' 'FIELDNAME'     'OPNNO',
*          'E' 'OUTPUTLEN'     '10',
"개설일자
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITRQS',
          ' ' 'FIELDNAME'     'OPNDT',
          'E' 'OUTPUTLEN'     '10',

*>>>>>>>>>LIST
"수입의뢰 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'FIELDNAME'     'REQIT',
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          ' ' 'LZERO'         c_charx,          "YSH 2004,09,21
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '10',
"구매전표번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'FIELDNAME'     'EBELN',
          ' ' 'HOTSPOT'       'X',       " Double Click 효과
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '10',
"구매문서 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'FIELDNAME'     'EBELP',
          ' ' 'HOTSPOT'       ' ',       " Double Click 효과
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '8',
"작성인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISRQST',
          ' ' 'FIELDNAME'     'MATNR',
          'E' 'OUTPUTLEN'     '18',
"기본단위
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'FIELDNAME'     'MEINS',
          'E' 'OUTPUTLEN'     '4',
"P/O 수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISRQIT',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'FIELDNAME'     'MENGE',
          'E' 'KEY'           ' ',
"수입요청누적수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISRQIT',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'RQMNGS',
          'E' 'KEY'           ' ',
"수입요청가능수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISRQIT',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'FIELDNAME'     'RQMNGL',
          ' ' 'OUTPUTLEN'     '20',
          'E' 'KEY'           ' ',
"수입의뢰수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITRQP',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'FIELDNAME'     'RQMNG',
*          ' ' 'do_sum'        ' ',
          'E' 'KEY'           ' ',
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

  LOOP AT it_list.
*    CLEAR: LT_RESRC_VW-COLOR_INFO[],
*           GS_COLOR_INFO.
*    ON CHANGE OF LT_RESRC_VW-RESRC.
*      GS_COLOR_INFO-FIELDNAME = 'RESRC'.
*      GS_COLOR_INFO-COLOR-COL = '3'.
*      APPEND GS_COLOR_INFO TO LT_RESRC_VW-COLOR_INFO[].
*      MODIFY LT_RESRC_VW.
*    ENDON.
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
  gs_listheader-info = '수입요청(개설) 현황 List'(t13).
*  SHIFT gs_listheader-info RIGHT BY 15 PLACES.
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

  DATA: ls_header TYPE ty_header.

  CLEAR: ls_header.

  CASE r_ucomm.
    WHEN '&REFRESH'.
*> 검색조건에 해당하는 데이타를 Select.
      PERFORM p2000_data_selections.
*> Header table과 List(Items) table를 만듬.
      PERFORM p2100_header_and_list_build.
      DESCRIBE TABLE it_tab LINES g_line.
      IF NOT g_line IS INITIAL.
        rs_selfield-refresh = 'X'.
      ELSE.
*> Program 종료.
        PERFORM  p9000_program_exit.
      ENDIF.

    WHEN 'ZTIT001'. " 후속기능
*> 개설 의뢰 상태에 따라 ZTIT005(접수) ZTIT006(신청) ZTIT007(개설)
      CLEAR : g_line, ls_header.
      LOOP AT it_header WHERE box EQ 'X'.
        ADD 1 TO g_line.
        MOVE-CORRESPONDING it_header TO ls_header.
      ENDLOOP.
      CASE g_line.
        WHEN 0.
          MESSAGE s003(ok). EXIT.

        WHEN 1.
*> 개설 의뢰 상태에 따라 ZTIT005(접수) ZTIT006(신청) ZTIT007(개설)
          CASE it_header-docst.
            WHEN ' '. "수입의뢰
              SET PARAMETER ID 'ZTIREQNO' FIELD it_header-reqno.
              SET PARAMETER ID 'ZTIAMDSQ' FIELD it_header-amdsq.
              CALL TRANSACTION 'ZTIT002' AND SKIP FIRST SCREEN .
            WHEN 'C'. "수입의뢰
              SET PARAMETER ID 'ZTIREQNO' FIELD it_header-reqno.
              SET PARAMETER ID 'ZTIAMDSQ' FIELD it_header-amdsq.
              CALL TRANSACTION 'ZTIT005' AND SKIP FIRST SCREEN .
            WHEN 'A'. "접수
              SET PARAMETER ID 'ZTIREQNO' FIELD it_header-reqno.
              SET PARAMETER ID 'ZTIAMDSQ' FIELD it_header-amdsq.
              CALL TRANSACTION 'ZTIT006' AND SKIP FIRST SCREEN .
            WHEN 'Y'. "개설신청
              SET PARAMETER ID 'ZTIREQNO' FIELD it_header-reqno.
              SET PARAMETER ID 'ZTIAMDSQ' FIELD it_header-amdsq.
              CALL TRANSACTION 'ZTIT007' AND SKIP FIRST SCREEN .
            WHEN 'O'.
              MESSAGE s901. EXIT.
            WHEN OTHERS.
              MESSAGE s901. EXIT.
          ENDCASE.
          PERFORM p9000_duelist_refresh USING  rs_selfield.

        WHEN OTHERS.
          MESSAGE s035(0k).   EXIT.
      ENDCASE.


    WHEN 'ZTIT002'. " 변경
*      CLEAR : g_line, ls_header.
*      LOOP AT it_header WHERE box EQ 'X'.
*        ADD 1 TO g_line.
*        MOVE-CORRESPONDING it_header TO ls_header.
*      ENDLOOP.
*      CASE g_line.
*        WHEN 0.
*          IF rs_selfield-tabname EQ 'IT_HEADER'.
*            READ TABLE it_header INDEX rs_selfield-tabindex.
*          ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
*            READ TABLE it_list INDEX rs_selfield-tabindex.
*          ENDIF.
*          IF sy-subrc NE 0.
*            MESSAGE s003(ok). EXIT.
*          ENDIF.
*          IF rs_selfield-tabname EQ 'HEADER'.
*            MOVE-CORRESPONDING it_header TO ls_header.
*          ELSEIF rs_selfield-tabname EQ 'LIST'.
*            MOVE-CORRESPONDING it_list   TO ls_header.
*          ENDIF.
*        WHEN 1.
*          SET PARAMETER ID 'ZTIREQNO' FIELD it_header-reqno.
*          SET PARAMETER ID 'ZTIAMDSQ' FIELD it_header-amdsq.
*          CALL TRANSACTION r_ucomm AND SKIP FIRST SCREEN .
*        WHEN OTHERS.
*          MESSAGE s035(0k).   EXIT.
*      ENDCASE.
*      perform p9000_duelist_refresh USING  rs_selfield.
*
    WHEN 'ZTIT004'. " 삭제
*      CLEAR : g_line, ls_header.
*      LOOP AT it_header WHERE box EQ 'X'.
*        ADD 1 TO g_line.
*        MOVE-CORRESPONDING it_header TO ls_header.
*      ENDLOOP.
*      CASE g_line.
*        WHEN 0.
*          IF rs_selfield-tabname EQ 'IT_HEADER'.
*            READ TABLE it_header INDEX rs_selfield-tabindex.
*          ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
*            READ TABLE it_list INDEX rs_selfield-tabindex.
*          ENDIF.
*          IF sy-subrc NE 0.
*            MESSAGE s003(ok). EXIT.
*          ENDIF.
*          IF rs_selfield-tabname EQ 'HEADER'.
*            MOVE-CORRESPONDING it_header TO ls_header.
*          ELSEIF rs_selfield-tabname EQ 'LIST'.
*            MOVE-CORRESPONDING it_list   TO ls_header.
*          ENDIF.
*        WHEN 1.
*          SET PARAMETER ID 'ZTIREQNO' FIELD it_header-reqno.
*          SET PARAMETER ID 'ZTIAMDSQ' FIELD it_header-amdsq.
*          CALL TRANSACTION r_ucomm AND SKIP FIRST SCREEN .
*
*        WHEN OTHERS.
*          MESSAGE s035(0k).   EXIT.
*      ENDCASE.
*      perform p9000_duelist_refresh USING  rs_selfield.

    WHEN '&IC1'.

      IF rs_selfield-tabname EQ 'IT_HEADER'.
        READ TABLE it_header INDEX rs_selfield-tabindex.
      ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
        READ TABLE it_list INDEX rs_selfield-tabindex.
      ENDIF.
      IF sy-subrc NE 0.
        MESSAGE s903. EXIT.
      ENDIF.

      IF rs_selfield-tabname EQ 'HEADER'.
        MOVE-CORRESPONDING it_header TO ls_header.
      ELSEIF rs_selfield-tabname EQ 'LIST'.
        MOVE-CORRESPONDING it_list   TO ls_header.
      ENDIF.

      CASE rs_selfield-fieldname.
        WHEN 'EBELN'.
          PERFORM  display_purchase_order(ztir0000)
                                          USING it_list-ebeln
                                                it_list-ebelp.
        WHEN 'AMDSQ' OR 'REQNO'.
          SET PARAMETER ID 'ZTIREQNO' FIELD it_header-reqno.
          SET PARAMETER ID 'ZTIAMDSQ' FIELD it_header-amdsq.
          CALL TRANSACTION 'ZTIT003' AND SKIP FIRST SCREEN.

      ENDCASE.

    WHEN 'ZTIT201'. " B/L
*      CLEAR : g_line, ls_header.
*      LOOP AT it_header WHERE box EQ 'X'.
*        ADD 1 TO g_line.
*        MOVE-CORRESPONDING it_header TO ls_header.
*      ENDLOOP.
*      CASE g_line.
*        WHEN 0.
*          IF rs_selfield-tabname EQ 'IT_HEADER'.
*            READ TABLE it_header INDEX rs_selfield-tabindex.
*          ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
*            READ TABLE it_list INDEX rs_selfield-tabindex.
*          ENDIF.
*          IF sy-subrc NE 0.
*            MESSAGE s003(ok). EXIT.
*          ENDIF.
*          IF rs_selfield-tabname EQ 'HEADER'.
*            MOVE-CORRESPONDING it_header TO ls_header.
*          ELSEIF rs_selfield-tabname EQ 'LIST'.
*            MOVE-CORRESPONDING it_list   TO ls_header.
*          ENDIF.
*        WHEN 1.
*          select single * from ZTIvbl00
*           where iblno eq iblno
*          SET PARAMETER ID 'ZTIREQNO' FIELD it_header-reqno.
*          SET PARAMETER ID 'ZTIAMDSQ' FIELD it_header-amdsq.
*          CALL TRANSACTION r_ucomm AND SKIP FIRST SCREEN .
*        WHEN OTHERS.
*          MESSAGE s035(0k).   EXIT.
*      ENDCASE.






    WHEN OTHERS.
  ENDCASE.

  CLEAR: r_ucomm.

ENDFORM.                    "USER_COMMAND
*---------------------------------------------------------------------*
*       FORM PF_STATUS_SET                                            *
*---------------------------------------------------------------------*
FORM pf_status_set USING rt_extab TYPE slis_t_extab.

  SET TITLEBAR 'T1000' WITH '현황'(t10).

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
*
