************************************************************************
* Title         :  ZTIR0011                                            *
*                                                                      *
* Description   : [Report] 사후송금 요청 대상 List                     *
*                                                                      *
* Creation Date : 2008/05/28                                           *
*                                                                      *
* Author        : Soo Ho, Yoon                                         *
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
REPORT  ztir0011       MESSAGE-ID zmti00
                       NO STANDARD PAGE HEADING.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE zts_reuse_alvforms_t00.  "> AVL 공용 Data 선언.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    TYPE c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF ty_header,
            box(1)      TYPE c,
            iblno       LIKE ztitblk-iblno,  "B/L 관리번호.
            blnum       LIKE ztitblk-blnum,  "B/L 번호.
            bldty       LIKE ztitblk-bldty,  "문서종류.
            bldtyx(20)  TYPE c,              "문서종류TEXT.
            rptty       LIKE ztitblk-rptty,  "수입신고구분.
            rpttyx(20)  TYPE c,              "수입신고구분TEXT.
            bukrs       LIKE ztitblk-bukrs,  "회사코드.
            ekorg       LIKE ztitblk-ekorg,  "구매조직.
            ekgrp       LIKE ztitblk-ekgrp,  "구매그룹.
            lifnr       LIKE ztitblk-lifnr,  "공급업체 계정번호.
            name1       LIKE lfa1-name1,     "구매처명.
            bletd       LIKE ztitblk-bletd,  "ETD(출발 예정 시각).
            bleta       LIKE ztitblk-bleta,  "ETA(도착 예정 시각).
            fwdty       LIKE ztitblk-fwdty,  "운송 방법.
            fwdtyx(20)  TYPE c,	           "운송 방법TEXT.
            lponr       LIKE ztitblk-lponr,  "최종품목번호.
            waers       LIKE ztitblk-waers,  "통화키.
            rtchg       LIKE ztitblk-rtchg,  "retention chg.
            trtchg      LIKE ztitblk-rtchg,  "retention chg.
            smamt       LIKE ztitblk-smamt,  "총금액.
            trefwr      LIKE ztitblp-refwr, "total 송장금액.
*            EKGRP       like ztitblk-EKGRP,
*            werks       like ztitblp-werks,
            lgayn       LIKE ztitblk-lgayn.  "LG대상여부.
TYPES: END OF ty_header.

TYPES: BEGIN OF ty_item.
INCLUDE     TYPE        ty_header.
TYPES :     iblit       LIKE ztitblp-iblit,  "B/L 품목번호.
            ndfty       LIKE ztitblp-ndfty,  "무환품 종류.
            ndftyx(20)  TYPE c,	            "무환품 종류TEXT.
            blmng       LIKE ztitblp-blmng,  "B/L 수량.
            refwr       LIKE ztitblp-refwr,  "송장값 (외화).
            meins       LIKE ztitblp-meins,  "기본단위.
            ebeln       LIKE ztitblp-ebeln,  "구매전표번호.
            ebelp       LIKE ztitblp-ebelp,  "구매문서 품목번호.
            reqno       LIKE ztitblp-reqno,  "수입의뢰 관리번호.
            reqit       LIKE ztitblp-reqit,  "수입의뢰 품목번호.
            cnam        LIKE ztitblp-cnam,   "작성인.
            cdat        LIKE ztitblp-cdat,   "생성일.
            ctme        LIKE ztitblp-ctme,   "생성시간.
            unam        LIKE ztitblp-unam,   "최종변경인.
            udat        LIKE ztitblp-udat,   "변경일.
            utme        LIKE ztitblp-utme,   "최종변경시간.
            rqmng       LIKE ztisrqit-rqmng,
            rqmngs      LIKE ztisrqit-rqmngs,
            rqmngl      LIKE ztisrqit-rqmngl,
            werks       LIKE ztisblit-werks,
            name2       LIKE ztisblit-name1,
            matnr       LIKE ztisblit-matnr,
            txz01       LIKE ztisblit-txz01,
            eeind       LIKE ztisblit-eeind,
            netpr       LIKE ztisblit-netpr,
            peinh       LIKE ztisblit-peinh,
            crefwr      LIKE ztitccp-refwr,
            ccmng       LIKE ztitccp-ccmng,
            iccno       LIKE ztitcck-iccno,
            iccsq       LIKE ztitcck-iccsq,
            cdcno       LIKE ztitcck-cdcno,
            cdrdt       LIKE ztitcck-cdrdt,
            irtchg      LIKE ztitblk-rtchg, ">> retention chg.
            netwr       LIKE ztisblit-netwr.
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
        ztitrqp,
        ztitblk,
        ztitblp,
        ztitivp,
        ztitivk,
        bkpf.

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES: ztivpo00,    ">Purchasing Document : Header + Items
        ztivrq00,    ">수입의뢰 Views(Header + Items + status)
        ztivbl00.    ">수입 B/L Views(Header + Items)

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

DATA: it_list      TYPE ty_list   OCCURS 0 WITH HEADER LINE.
DATA: it_header    TYPE ty_header OCCURS 0 WITH HEADER LINE.
DATA: it_tab       TYPE ty_tab    OCCURS 0 WITH HEADER LINE.
DATA: gs_tab       TYPE ty_tab.


*> 사후송금 .
DATA : BEGIN OF it_ztisblit OCCURS 0.
        INCLUDE STRUCTURE ztisblit.
DATA :  box        TYPE c,
        index(10)  TYPE n.
DATA : END   OF it_ztisblit.


*> ALV용 변수 선언.
   CONSTANTS:
         c_save(1)        TYPE  c              VALUE 'A',
         c_top_of_page    TYPE  slis_formname  VALUE 'TOP_OF_PAGE',
         c_pf_status_set  TYPE  slis_formname  VALUE 'SET_STATUS',
         c_user_command   TYPE  slis_formname  VALUE 'USER_COMMAND'.
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
  s_ekorg  FOR ztitblk-ekorg MODIF ID iog,    "구매조직.
  s_ekgrp  FOR ztitblk-ekgrp MODIF ID iog,    "구매그룹.
  s_werks  for ztitblp-werks modif id iog,
  s_ebeln  FOR ztitblp-ebeln MODIF ID iog,    "구매전표번호.
  s_iblno  FOR ztitblk-iblno MODIF ID iog	     "B/L 관리번호.
                              MEMORY ID ztiiblno,
  s_blnum  FOR ztitblk-blnum MODIF ID iog,    "B/L 번호.
  s_reqno  FOR ztitblp-reqno MODIF ID iog,    "수입의뢰 관리번호.
  s_rptty  FOR ztitblk-rptty MODIF ID iog,    "수입신고구분.
  s_lifnr  FOR ztitblk-lifnr MODIF ID iog,    "공급업체 계정번호.
  s_bletd  FOR ztitblk-bletd MODIF ID iog,    "ETD(출발 예정 시각).
  s_bleta  FOR ztitblk-bleta MODIF ID iog,    "ETA(도착 예정 시각).
  s_fwdty  FOR ztitblk-fwdty MODIF ID iog,    "운송 방법.
  s_lponr  FOR ztitblk-lponr MODIF ID iog,    "최종품목번호.
  s_waers  FOR ztitblk-waers MODIF ID iog,    "통화키.
  s_lgayn  FOR ztitblk-lgayn MODIF ID iog,    "LG대상여부.
  s_iblit  FOR ztitblp-iblit MODIF ID iog,    "B/L 품목번호.
  s_blmng  FOR ztitblp-blmng MODIF ID iog,    "B/L 수량.
  s_refwr  FOR ztitblp-refwr MODIF ID iog,    "송장값 (외화).
  s_meins  FOR ztitblp-meins MODIF ID iog,    "기본단위.
  s_ebelp  FOR ztitblp-ebelp MODIF ID iog,    "구매문서 품목번호.
  s_reqit  FOR ztitblp-reqit MODIF ID iog,    "수입의뢰 품목번호.
  s_cnam   FOR ztitblp-cnam  MODIF ID iog,    "작성인.
  s_cdat   FOR ztitblp-cdat  MODIF ID iog,    "생성일.
  s_ctme   FOR ztitblp-ctme  MODIF ID iog,    "생성시간.
  s_unam   FOR ztitblp-unam  MODIF ID iog,    "최종변경인.
  s_udat   FOR ztitblp-udat  MODIF ID iog,    "변경일.
  s_utme   FOR ztitblp-utme  MODIF ID iog.    "최종변경시간.
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

************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.
*> 검색조건에 해당하는 데이타를 Select.
  PERFORM p2000_data_selections.
*> Header table과 List(Items) table를 만듬.
  PERFORM p2100_header_and_list_build_s.

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
*    PERFORM 3100_set_color_infomation.
*    PERFORM 3200_key_infomation_build.
    PERFORM 3300_event_exit_table_build.
    PERFORM 3400_comment_build.
*    PERFORM 3500_sort_table_build.
*    PERFORM 3600_event_table_build USING : slis_ev_top_of_page,
*                                           slis_ev_pf_status_set,
*                                           slis_ev_user_command.
    PERFORM 3700_layout_build.
*    PERFORM 3910_call_alv_hierseq.
    PERFORM 3910_call_alv_hierseq_list.
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

  DATA: l_rqmng  LIKE ztitrqp-rqmng.

  CLEAR: g_count, it_tab,  it_header, it_list.
  REFRESH : it_tab, it_header, it_list.
*> PROGRESS Display.
  g_linen    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

*> B/L 데이타 select.
  SELECT *
        INTO CORRESPONDING FIELDS OF TABLE it_tab
        FROM ztivcc02
       WHERE bukrs  IN s_bukrs  "회사코드.
*         AND bldty  EQ s_bldty
         AND ndfty  EQ 'A'      "1무환품 종류.
*         AND reqno  EQ space    "10수입의뢰 관리번호.
*         AND reqit  EQ space    "5수입의뢰 품목번호.
         AND iblno  IN s_iblno
         AND blnum  IN s_blnum  "25B/L 번호.
         AND rptty  IN s_rptty  "1수입신고구분.
         AND ekorg  IN s_ekorg                              "4구매조직.
         AND ekgrp  IN s_ekgrp
         and werks  in s_werks
         AND lifnr  IN s_lifnr  "10공급업체 계정번호.
         AND bletd  IN s_bletd  "8ETD(출발 예정 시각).
         AND bleta  IN s_bleta  "8ETA(도착 예정 시각).
         AND fwdty  IN s_fwdty  "1운송 방법.
         AND lponr  IN s_lponr  "5최종품목번호.
         AND waers  IN s_waers                              "5통화키.
         AND lgayn  IN s_lgayn  "LG대상여부.
         AND iblit  IN s_iblit  "5B/L 품목번호.
*         AND b~ndfty  IN s_ndfty  "1무환품 종류.
         AND blmng  IN s_blmng  "13B/L 수량.
         AND refwr  IN s_refwr  "13송장값 (외화).
         AND meins  IN s_meins                              "3기본단위.
         AND ebeln  IN s_ebeln  "10구매전표번호.
         AND ebelp  IN s_ebelp  "5구매문서 품목번호.
*         AND reqno  IN s_reqno  "10수입의뢰 관리번호.
*         AND reqit  IN s_reqit  "5수입의뢰 품목번호.
         AND cnam   IN s_cnam                               "12작성인.
         AND cdat   IN s_cdat                               "8생성일.
         AND ctme   IN s_ctme                               "6생성시간.
         AND unam   IN s_unam   "12최종변경인.
         AND udat   IN s_udat                               "8변경일.
         AND utme   IN s_utme.  "6최종변경시간.

**********************************************************************
* 20070207 simcho by 박혁세 K
* 삼국무역에 대해 사후송금도 가능토록 수정하기 위함
* 사후조건 TA** 통관없이 개설요청 due list에 띄우도록
**********************************************************************
* 고민중

*> 무통관 입고 사후송금B/L 데이타 select.
*  IF it_tab[] IS INITIAL.
  SELECT *
        APPENDING CORRESPONDING FIELDS OF TABLE it_tab
        FROM ztivbl00
       WHERE bukrs  IN s_bukrs  "회사코드.
*         AND bldty  EQ s_bldty
         AND ndfty  EQ 'A'      " 사후송금.
         AND rptty  EQ 'Z'      " 미통관
*         AND reqno  EQ space    "10수입의뢰 관리번호.
*         AND reqit  EQ space    "5수입의뢰 품목번호.
         AND iblno  IN s_iblno
         AND blnum  IN s_blnum  "25B/L 번호.
         AND rptty  IN s_rptty  "1수입신고구분.
        AND ekorg  IN s_ekorg                               "4구매조직.
        AND ekgrp  IN s_ekgrp                               "3구매그룹.
        and WERKS  in s_WERKS
         AND lifnr  IN s_lifnr  "10공급업체 계정번호.
         AND bletd  IN s_bletd  "8ETD(출발 예정 시각).
         AND bleta  IN s_bleta  "8ETA(도착 예정 시각).
         AND fwdty  IN s_fwdty  "1운송 방법.
         AND lponr  IN s_lponr  "5최종품목번호.
         AND waers  IN s_waers                              "5통화키.
         AND lgayn  IN s_lgayn  "LG대상여부.
         AND iblit  IN s_iblit  "5B/L 품목번호.
*         AND b~ndfty  IN s_ndfty  "1무환품 종류.
         AND blmng  IN s_blmng  "13B/L 수량.
         AND refwr  IN s_refwr  "13송장값 (외화).
        AND meins  IN s_meins                               "3기본단위.
         AND ebeln  IN s_ebeln  "10구매전표번호.
         AND ebelp  IN s_ebelp  "5구매문서 품목번호.
*         AND reqno  IN s_reqno  "10수입의뢰 관리번호.
*         AND reqit  IN s_reqit  "5수입의뢰 품목번호.
         AND cnam   IN s_cnam                               "12작성인.
         AND cdat   IN s_cdat                               "8생성일.
        AND ctme   IN s_ctme                                "6생성시간.
         AND unam   IN s_unam   "12최종변경인.
         AND udat   IN s_udat                               "8변경일.
         AND utme   IN s_utme.  "6최종변경시간.
*  ENDIF.

**********************************************************************

  IF sy-subrc NE 0.
    MESSAGE s902.
  ENDIF.

  CLEAR: g_tabix, g_count, g_cnt.
  LOOP AT it_tab.

    g_tabix = sy-tabix.

*   domain의 value.
    PERFORM get_domain_value_text(ztir0000) USING :
                           'ZTIBLDTY' it_tab-bldty  it_tab-bldtyx,
                           'ZTIRPTTY' it_tab-rptty  it_tab-rpttyx,
                           'ZTIFWDTY' it_tab-fwdty  it_tab-fwdtyx,
                           'ZTINDFTY' it_tab-ndfty  it_tab-ndftyx.

*    IF ( it_tab-bldty  EQ 'A' ) AND ( it_tab-ndfty  EQ space ).
    IF  it_tab-ndfty  EQ 'A'.

    ELSE.
*      IF it_tab-rtchg IS INITIAL.
      DELETE it_tab INDEX g_tabix.
      CONTINUE.
*      ELSE.
*        it_tab-bldtyx = '유보금'.
*      ENDIF.
    ENDIF.

*   공급업체.
    SELECT SINGLE name1 INTO it_tab-name1
      FROM lfa1
     WHERE lifnr EQ it_tab-lifnr.

*   p/o정보.
    SELECT  SINGLE werks matnr txz01
      INTO  (it_tab-werks, it_tab-matnr, it_tab-txz01)
      FROM  ztivpo00
     WHERE  ebeln  = it_tab-ebeln
       AND  ebelp  = it_tab-ebelp.

*   사후 송금 누적수량.
    SELECT  SUM( rqmng )
      INTO  it_tab-rqmngs
      FROM  ztitrqp
     WHERE  iblno  = it_tab-iblno
       AND  iblit  = it_tab-iblit.

*  사후 송금가능수량.
    it_tab-rqmngl =  it_tab-blmng - it_tab-rqmngs.
    it_tab-rqmng  =  it_tab-rqmngl.
    IF it_tab-rqmngl LE 0.
      DELETE it_tab INDEX g_tabix.
      CONTINUE.
    ENDIF.

    MOVE it_tab-refwr TO it_tab-trefwr.

    ADD 1 TO g_count.

    MODIFY it_tab INDEX g_tabix.

  ENDLOOP.

*> 유보금 계산로직.
  CLEAR g_tabix.
  DATA: lo_rtchg LIKE ztitivk-rtchg,
        lt_rtchg LIKE ztitivk-rtchg.
"-> CCM : 2023.04.10 ZITCS4HDEV06 - sort 추가 작업.
  SORT it_tab.
  LOOP AT it_tab.
    g_tabix = sy-tabix.
    IF NOT it_tab-rtchg IS INITIAL.
      MOVE-CORRESPONDING it_tab TO gs_tab.
      AT NEW iblno.
        CLEAR : lo_rtchg, lt_rtchg .
      ENDAT.
      IF gs_tab-smamt NE 0.
        gs_tab-irtchg = gs_tab-rtchg *
                       ( gs_tab-refwr / gs_tab-smamt ).
        lo_rtchg = lo_rtchg + gs_tab-irtchg.
      ELSE.

      ENDIF.
      AT END OF iblno.
        lt_rtchg = gs_tab-rtchg - lo_rtchg.
        gs_tab-irtchg = gs_tab-irtchg + lt_rtchg.
      ENDAT.

      MOVE gs_tab-irtchg TO gs_tab-trtchg.
      MODIFY it_tab FROM gs_tab.
    ENDIF.
  ENDLOOP.



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
*"BOX.
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'FIELDNAME'     'BOX',
*          'E' 'KEY'           ' ',
"B/L 관리번호
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'IBLNO',
*          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
*"문서상태 ndftyx
*          'S' 'TABNAME'       'IT_HEADER',
**          ' ' 'REF_TABNAME'   'ZTITBLK',
*          ' ' 'seltext_m'     '문서상태',
*          ' ' 'FIELDNAME'     'BLDTYX',
*          'E' 'OUTPUTLEN'     '10',
*"회사코드
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
*          ' ' 'FIELDNAME'     'BUKRS',
*          ' ' 'NO_OUT'        'X',
*          'E' 'OUTPUTLEN'     '4',
*"운송방법.
*          'S' 'TABNAME'       'IT_HEADER',
**          ' ' 'REF_TABNAME'   'ZTITBLK',
*          ' ' 'seltext_m'     '운송방법',
*          ' ' 'FIELDNAME'     'FWDTYX',
*          'E' 'OUTPUTLEN'     '10',
*"공급업체.
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'LFA1',
**          ' ' 'seltext_m'     '공급업체명',
*          ' ' 'FIELDNAME'     'LIFNR',
*          'E' 'OUTPUTLEN'     '20',
*"공급업체명.
*          'S' 'TABNAME'       'IT_HEADER',
**          ' ' 'REF_TABNAME'   'ZTITBLK',
*          ' ' 'seltext_m'     '공급업체명',
*          ' ' 'FIELDNAME'     'NAME1',
*          'E' 'OUTPUTLEN'     '40',
*
*"송장금액통화
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'seltext_m'     'Cur',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
*          ' ' 'FIELDNAME'     'WAERS',
*          'E' 'OUTPUTLEN'     '3',
*"송장금액.
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'seltext_m'     '송장값 (외화)',
*          ' ' 'FIELDNAME'     'TREFWR',
*          ' ' 'CFIELDNAME'    'WAERS',
*          ' ' 'CTABNAME'      'IT_HEADER',
*          'E' 'OUTPUTLEN'     '16',
*"유보금.
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'seltext_m'     '유보금',
*          ' ' 'FIELDNAME'     'TRTCHG',
*          ' ' 'CFIELDNAME'    'WAERS',
*          ' ' 'CTABNAME'      'IT_HEADER',
*          'E' 'OUTPUTLEN'     '16',
*"수입신고구분
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
*          ' ' 'seltext_m'     '신고구분',
*          ' ' 'NO_OUT'        'X',
*          ' ' 'FIELDNAME'     'RPTTYX',
*          'E' 'OUTPUTLEN'     '14',
*
*"B/L번호
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
**          ' ' 'seltext_m'     'BLNUM',
*          ' ' 'FIELDNAME'     'BLNUM',
*          ' ' 'HOTSPOT'       ' ',
*          'E' 'OUTPUTLEN'     '26',

*>>>>>>>>>LIST
"B/L 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'IBLIT',
*          ' ' 'HOTSPOT'       'X',
          ' ' 'JUST'          c_charl," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
          ' ' 'INTLEN'         10,
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"구매전표번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'EBELN',
*          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '10',
"구매문서 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'EBELP',
          ' ' 'JUST'          c_charl," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
          ' ' 'NO_OUT'        ' ',
          'E' 'OUTPUTLEN'     '10',

"자재번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'FIELDNAME'     'MATNR',
          'E' 'OUTPUTLEN'     '20',
"자재내역.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'FIELDNAME'     'TXZ01',
          ' ' 'NO_OUT'        ' ',
          'E' 'OUTPUTLEN'     '40',
"송장금액.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'seltext_m'     '송장값 (외화)',
          ' ' 'FIELDNAME'     'REFWR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '20',
"유보금.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'seltext_m'     '유보금',
          ' ' 'FIELDNAME'     'IRTCHG',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '16',
"문서상태 ndftyx
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '품목범주',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'NDFTYX',
          'E' 'OUTPUTLEN'     '13',
"B/L수량
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'seltext_m'     'B/L 수량',
          ' ' 'FIELDNAME'     'BLMNG',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'NO_OUT'        'X',
          ' ' 'QTABNAME'      'IT_LIST',
          'E' 'OUTPUTLEN'     '15',

"사전송금가능수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISRQIT',
*          ' ' 'seltext_s'     '의뢰가능수량',
*          ' ' 'seltext_m'     '의뢰(사후송금)가능수량',
          ' ' 'FIELDNAME'     'RQMNGL',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        ' ',
          'E' 'KEY'           ' ',
"사전송금누적수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISRQIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'FIELDNAME'     'RQMNGS',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          'E' 'KEY'           ' ',
"사전송금수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISRQIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'FIELDNAME'     'RQMNG',
          ' ' 'NO_OUT'        'X',
          'E' 'KEY'           ' ',
"기본단위
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'MEINS',
          ' ' 'INTLEN'         10,
          'E' 'OUTPUTLEN'     '4',

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'EKGRP',
          ' ' 'INTLEN'         10,
          'E' 'OUTPUTLEN'     '4',

          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'WERKS',
          ' ' 'INTLEN'         10,
          'E' 'OUTPUTLEN'     '4',


"자재문서번호
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'MBLNR',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"자재문서연도
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'MJAHR',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"자재문서품목
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'ZEILE',
          ' ' 'NO_OUT'        'X',
*          'E' 'OUTPUTLEN'     '10'.
"작성인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'CNAM',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"최종변경인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
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

  gs_keyinfo-header01 = 'IBLNO'.
  gs_keyinfo-item01   = 'IBLNO'.

  gs_keyinfo-header02 =  space.
  gs_keyinfo-item02   = 'IBLIT'.

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
  gs_listheader-info = '입고후 송금 요청 대상 List'(t13).
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

* STATUS LINE: TYPE S
* CLEAR LS_LINE.
* LS_LINE-TYP  = 'S'.
* LS_LINE-KEY  = 'Kostenrechnungskreis:'.
* LS_LINE-INFO = P_KOKRS.
* APPEND LS_LINE TO LT_TOP_OF_PAGE.

* LS_LINE-KEY  = 'Gesch?tsjahr:_______'.
* LS_LINE-INFO = P_GJAHR.
* APPEND LS_LINE TO LT_TOP_OF_PAGE.

* LS_LINE-KEY  = 'Version:_____________'.
* LS_LINE-INFO = P_VERSN.
* APPEND LS_LINE TO LT_TOP_OF_PAGE.

* ACTION LINE: TYPE A
*  CLEAR LS_LINE.
*  LS_LINE-TYP  = 'A'.
** LS_LINE-KEY:  NOT USED FOR THIS TYPE
*  LS_LINE-INFO = '<Action>'.
*  APPEND LS_LINE TO LT_TOP_OF_PAGE.

ENDFORM.                    " 3400_COMMENT_BUILD
*&---------------------------------------------------------------------*
*&      Form  3500_SORT_TABLE_BUILD
*&---------------------------------------------------------------------*
FORM 3500_sort_table_build .

  DATA: ls_sort TYPE slis_sortinfo_alv.

  CLEAR ls_sort.
  ls_sort-spos      = 1.
  ls_sort-fieldname = 'IBLNO'.
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

  DATA: ls_header TYPE ty_header.
  DATA: ls_list   TYPE ty_tab,
        l_error   TYPE c          VALUE 'N'.

  CLEAR: ls_header.

  CASE r_ucomm.
    WHEN '&REFRESH'.
      PERFORM p9000_duelist_refresh USING  rs_selfield.

    WHEN 'ZTIT001'. " 후속기능
      CLEAR : g_line, g_count.
      REFRESH: it_ztisblit.  CLEAR: it_ztisblit.
      LOOP AT it_header WHERE box EQ 'X'.
        ADD 1 TO g_line.
        LOOP AT it_list WHERE iblno EQ it_header-iblno.
          ADD 1 TO g_count.

****************************************************************
** 2007.09.03 simcho  채권채무 상계처리
****************************************************************

          CLEAR: ztitivp,ztitivk,bkpf.

          DATA : lv_bukrs LIKE bkpf-bukrs,
                 lv_ivono LIKE ztitivp-ivono,
                 lv_rblgp LIKE ztitivp-rblgp,
                 lv_belnr LIKE ztitivk-belnr,
                 lv_gjahr LIKE ztitivk-gjahr,
                 lv_belnr_sap LIKE bkpf-belnr,
                 lv_awkey LIKE bkpf-awkey,
                 lv_augbl LIKE bseg-augbl,
                 lv_belnr_clr LIKE bse_clr-belnr_clr,
                 lv_msg01(300),
                 lv_msg02(300),
                 lv_msg03(300).

*
*          SELECT SINGLE ivono  rblgp  INTO (lv_ivono, lv_rblgp)
*            FROM ztitivp
*           WHERE iblno  EQ  it_list-iblno
*             AND iblit  EQ  it_list-iblit.
*
*          IF sy-subrc = '00'.
*            SELECT SINGLE belnr gjahr INTO (lv_belnr, lv_gjahr)
*              FROM ztitivk
*             WHERE ivono = lv_ivono.
*
*            IF sy-subrc = '00'.
*
*              CONCATENATE lv_belnr lv_gjahr INTO lv_awkey.
*
*              SELECT SINGLE bukrs belnr INTO (lv_bukrs, lv_belnr_sap)
*                FROM bkpf
*               WHERE awkey = lv_awkey.
*********************************************************************
** 반제전표 찾기
*********************************************************************
*              IF sy-subrc = '00'.
*                SELECT SINGLE augbl INTO lv_augbl
*                  FROM bseg
*                 WHERE bukrs = lv_bukrs
*                   AND belnr = lv_belnr_sap
*                   AND gjahr = lv_gjahr
*                   AND koart = 'K'.  "공급업체
*
*                IF lv_augbl IS NOT INITIAL.
*                  MESSAGE e997 WITH
*                  it_list-iblno '해당 B/L은 채권과 완전반제 되었습니다'
*                  '선택 할 수 없습니다.'.
*                ELSE.
*********************************************************************
** 채권 < 채무 상계전표 유무 확인
*********************************************************************
*                  SELECT SINGLE belnr_clr INTO lv_belnr_clr
*                    FROM bse_clr
*                   WHERE bukrs = lv_bukrs
*                     AND belnr = lv_belnr_sap
*                     AND gjahr = lv_gjahr.
*
**                  IF lv_belnr_clr IS NOT INITIAL.
**
**                    CONCATENATE it_list-iblno
**                                ' 해당 B/L은 채권과
*부분반제되었습니다'
**                                INTO lv_msg01.
**
**                    CONCATENATE '반제전표 번호는' lv_belnr_clr
**                                INTO lv_msg02.
**
**                    MESSAGE i997 WITH lv_msg01 lv_msg02 '입니다.'.
**
**                  ENDIF.
*********************************************************************
*
*                ENDIF.
*              ENDIF.

*            ENDIF.

*          ENDIF.


***************************************************************

          SELECT  SINGLE *
            INTO  CORRESPONDING FIELDS OF it_ztisblit
            FROM  ztivbl00
           WHERE  iblno  EQ  it_list-iblno
             AND  iblit  EQ  it_list-iblit.

          MOVE: g_count              TO it_ztisblit-index,
                c_true               TO it_ztisblit-box,
                it_list-rqmng        TO it_ztisblit-rqmng,
                it_list-rqmngl       TO it_ztisblit-rqmngl,
                it_list-rqmngs       TO it_ztisblit-rqmngs.

          APPEND it_ztisblit.
        ENDLOOP.
      ENDLOOP.

************************************************************************
      IF lv_belnr_clr IS NOT INITIAL.

        CONCATENATE it_list-iblno
                    ' 해당 B/L은 채권과 부분반제 되었습니다'
                    INTO lv_msg01.
        CONCATENATE '반제전표 번호는' lv_belnr_clr INTO lv_msg02.

        MESSAGE i997 WITH lv_msg01 lv_msg02 '입니다.'.

      ENDIF.
************************************************************************
      CHECK l_error EQ 'N'.


***************************************************
* 20061214 오민석 K요청
***************************************************
*      CASE g_line.
*        WHEN 0.
*          MESSAGE s006(0k).   EXIT.
*        WHEN 1.
*        WHEN OTHERS.
*          MESSAGE s929.       EXIT.
*      ENDCASE.

      CASE g_line.
        WHEN 0.
          MESSAGE s006(0k).   EXIT.
        WHEN 1.
        WHEN OTHERS.
          MESSAGE s999 WITH
          'B/L을 하나이상 선택하셨습니다. 계속하시겠습니까?'.

      ENDCASE.

***************************************************
* end
***************************************************



*> Call Dialog
      CALL DIALOG 'Z_TI_LC_CREATE'
        AND SKIP FIRST SCREEN
        EXPORTING
          g_tcode     FROM sy-tcode
          it_ztisblit FROM it_ztisblit
          g_msg01     FROM lv_msg01
          g_msg02     FROM lv_msg02
        IMPORTING
          ztitrqk.

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
        MOVE-CORRESPONDING it_header TO ls_list.
      ELSEIF rs_selfield-tabname EQ 'IT_LIST'.
        MOVE-CORRESPONDING it_list   TO ls_list.
      ENDIF.

      CASE rs_selfield-fieldname.
        WHEN 'EBELN' OR 'EBELP'.
          PERFORM  display_purchase_order(ztir0000)
                                          USING ls_list-ebeln
                                                ls_list-ebelp.
        WHEN OTHERS.
          PERFORM  display_bl_document(ztir0000)
                                          USING ls_list-iblno
                                                '00000'.
      ENDCASE.
*      perform p9000_duelist_refresh USING  rs_selfield.
    WHEN OTHERS.
  ENDCASE.

  CLEAR: r_ucomm.

ENDFORM.                    "USER_COMMAND
*---------------------------------------------------------------------*
*       FORM PF_STATUS_SET                                            *
*---------------------------------------------------------------------*
FORM pf_status_set USING rt_extab TYPE slis_t_extab.

  SET TITLEBAR 'T1000' WITH '요청'(t10).

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

ENDFORM.                    "PF_STATUS_SET

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
*&      Form  p2100_header_and_list_build_s
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM p2100_header_and_list_build_s .

  LOOP AT it_tab.
    MOVE-CORRESPONDING it_tab TO : it_header, it_list.
    COLLECT : it_header.
    APPEND  it_list.
  ENDLOOP.

*  clear g_tabix.
*  data: lo_rtchg like ZTITIVK-rtchg,
*        lt_rtchg like ZTITIVK-rtchg.
*
*  loop at it_tab.
*     g_tabix = sy-tabix.
*     move-corresponding it_tab to gs_tab.
*     at new iblno.
*        clear : lo_rtchg, lt_rtchg .
*     endat.
*     if gs_tab-smamt ne 0.
*        gs_tab-irtchg = gs_tab-rtchg *
*                       ( gs_tab-refwr / gs_tab-smamt ).
*        lo_rtchg = lo_rtchg + gs_tab-irtchg.
*     else.
*
*     endif.
*     at end of iblno.
*       lt_rtchg = gs_tab-rtchg - lo_rtchg.
*       gs_tab-irtchg = gs_tab-irtchg + lt_rtchg.
*     endat.
*
*     MOVE gs_tab-irtchg TO gs_tab-trtchg.
*     MODIFY it_tab from gs_tab.
*  endloop.




ENDFORM.                    " p2100_header_and_list_build_s
*&---------------------------------------------------------------------*
*&      Form  3910_CALL_ALV_HIERSEQ_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form 3910_CALL_ALV_HIERSEQ_LIST .
  DATA: fc_detail  TYPE slis_fieldcat_alv OCCURS 0 WITH HEADER LINE.
  DATA: variant_detail      LIKE disvariant.
  DATA: exit       TYPE slis_event_exit   OCCURS 0 WITH HEADER LINE.
  DATA: events     TYPE slis_alv_event    OCCURS 0 WITH HEADER LINE.
  DATA: groups     TYPE slis_sp_group_alv OCCURS 0 WITH HEADER LINE.
  DATA: ls_variant LIKE disvariant.

*  REFRESH fc_detail.
*  LOOP AT fc1 INTO fcs.
*    MOVE-CORRESPONDING fcs TO fc_detail.
*    CLEAR fc_detail-tabname.
*    APPEND fc_detail.
*  ENDLOOP.

  CLEAR variant_detail.
  variant_detail-report = g_repid.
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
  ls_variant-report  = sy-repid.
  ls_variant-variant = p_vari.
  g_repid            = sy-repid.                  " Callback Program.

*> ALV reuse function call..
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program       = g_repid
        i_callback_pf_status_set = 'PF_STATUS_SET'
        i_callback_user_command  = 'USER_COMMAND'
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
        it_fieldcat              = it_fieldcat[]
        it_sort                  = it_sort
*        I_DEFAULT                = 'X'
*        IS_VARIANT               = VARIANT_DETAIL
        is_variant               = ls_variant
        i_save                   = c_save
        is_layout                = gs_layout
        is_print                 = gs_print
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER        =
*     ES_EXIT_CAUSED_BY_USER         =
      TABLES
        t_outtab                 = it_list[].

endform.                    " 3910_CALL_ALV_HIERSEQ_LIST
