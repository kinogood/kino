************************************************************************
* Title         :  ZTIR8020                                            *
*                                                                      *
* Description   : [Report] Notice 현황 List                            *
*                                                                      *
* Creation Date : 2004/02/25                                           *
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
REPORT  ztir8020       MESSAGE-ID zmti00
                       NO STANDARD PAGE HEADING.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE zts_reuse_alvforms_t00.  "> AVL 공용 Data 선언.


************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF ty_header,
            box(1)      TYPE c,
            pntno       LIKE ztitpnk-pntno, "Notice 관리번호
            bukrs       LIKE ztitpnk-bukrs, "회사코드
            ekorg       LIKE ztitpnk-ekorg, "구매조직
            ekgrp       LIKE ztitpnk-ekgrp, "구매그룹
            ntcbk       LIKE ztitpnk-ntcbk, "통지은행
            lifnr       LIKE ztitpnk-lifnr, "다른 송장발행처.
            name1       LIKE lfa1-name1,  "명.
            lctxt(20)   TYPE c,
            opnno       LIKE ztitpnk-opnno, "수입개설번호.
            blnum       LIKE ztitpnk-blnum, "B/L 번호.
            xranl       LIKE ztitpnk-xranl, "론번호.
            gjahr       LIKE ztitpnk-gjahr, "USANCE 반제 전표.
            belnr       LIKE ztitpnk-belnr, "USANCE 반제 전표.
            umtcu       LIKE ztitrqs-umtcu, "수입의뢰 FX
            umtcx(8)    TYPE c,
            pntdt       LIKE ztitpnk-pntdt, "통지일자
            stldt       LIKE ztitpnk-stldt, "최종결제일자
            ngodt       LIKE ztitpnk-ngodt, "NEGO 일자
            dctdt       LIKE ztitpnk-dctdt, "할인일자
            bgndt       LIKE ztitpnk-bgndt, "시작일자
            expdt       LIKE ztitpnk-expdt, "만기일자
*            KURSF       LIKE ZTITPNK-KURSF, "환율
            waers       LIKE ztitpnk-waers, "통화키
            pntam       LIKE ztitpnk-pntam, "Notice Amount
            dmbtr       LIKE ztitpnk-dmbtr, "현지통화금액
            hwaer       LIKE ztitpnk-hwaer, "현지통화
            procp       LIKE ztitpnk-procp, "선취/후취
            tsatz       LIKE ztitpnk-tsatz, "이자율
            itrst       LIKE ztitpnk-itrst, "이자금액
            intsc       LIKE ztitpnk-intsc, "이자액 통화키
            chgot       LIKE ztitpnk-chgot, "기타수수료
            chgoc       LIKE ztitpnk-chgoc, "기타수수료 통화
            lponr       LIKE ztitpnk-lponr, "최종품목번호
            fnetwr      LIKE ztispnit-netwr,  "문서통화의 정가
            cnam        LIKE ztitpnk-cnam,  "작성인
            cdat        LIKE ztitpnk-cdat,  "생성일
            ctme        LIKE ztitpnk-ctme,  "생성시간
            unam        LIKE ztitpnk-unam,  "최종변경인
            udat        LIKE ztitpnk-udat,  "변경일
            utme        LIKE ztitpnk-utme.  "최종변경시간

TYPES: END OF ty_header.

TYPES: BEGIN OF ty_item.
INCLUDE     TYPE        ty_header.
TYPES :     pntit       LIKE ztitpnp-pntit,  "Notice 품목
            ivono       LIKE ztitpnp-ivono,  "송장 관리번호
            rblgp       LIKE ztitpnp-rblgp,  "송장문서의 품목
            ebeln       LIKE ztitpnp-ebeln,  "구매전표번호
            ebelp       LIKE ztitpnp-ebelp,  "구매문서품목번호
            reqno       LIKE ztitpnp-reqno,  "수입의뢰관리번호
            reqit       LIKE ztitpnp-reqit,  "수입의뢰품목번호
            iblno       LIKE ztitpnp-iblno,  "B/L 관리번호
            iblit       LIKE ztitpnp-iblit,  "B/L 품목번호
            pnmng       LIKE ztitpnp-pnmng,  "Notice 수량
            meins       LIKE ztitpnp-meins,  "기본단위
            flag        LIKE ztispnit-flag,
            matnr       LIKE ztispnit-matnr,  "자재번호
            txz01       LIKE ztispnit-txz01,  "내역
            namet       LIKE ztstig3-namet,   "통지은행명
            netwr       LIKE ztispnit-netwr,  "문서통화의 정가
            bprme       LIKE ztispnit-bprme,  "오더가격단위
            bpumz       LIKE ztispnit-bpumz,  "오더단위환산 분자
            bpumn       LIKE ztispnit-bpumn,  "오더단위환산 분모
            umrez       LIKE ztispnit-umrez,  "기본단위로전환분자
            umren       LIKE ztispnit-umren,  "기본단위로전환분모
            netpr       LIKE ztispnit-netpr,  "단가
            peinh       LIKE ztispnit-peinh,  "가격단위
            uebto       LIKE ztispnit-uebto,  "초과납품 허용치
            uebtk       LIKE ztispnit-uebtk,  "무제한초과납품
            untto       LIKE ztispnit-untto,  "미달납품 허용치
            werks       LIKE ztispnit-werks,  "플랜트
            names       LIKE ztispnit-name1,  "플랜트
            lgort       LIKE ztispnit-lgort,  "저장위치
            lgobe       LIKE ztispnit-lgobe,  "저장위치
            elikz       LIKE ztispnit-elikz,  "납품완료 지시자
            loekz       LIKE ztispnit-loekz,  "삭제지시자
            menge       LIKE ztispnit-menge,  "수량
            remng       LIKE ztispnit-remng,  "송장처리수량
            pnmngs      LIKE ztispnit-pnmngs, "Notice누적수량
            pnmngl      LIKE ztispnit-pnmngl, "Notice가능수량
            bupla       LIKE ztispnit-bupla,  "사업장
            eeind       LIKE ztispnit-eeind.  "납품일
*            WAERS       LIKE ZTIspnit-WAERS.  "통화키
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
        lfa1,
        ztitrqk,
        ztitrqs,
        ztitrqp,
        ztitblk,
        ztitcck,
        ztitpnk,
        ztitpnp.

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES: ztivpo00,    ">Purchasing Document : Header + Items
        ztivrq00,    ">수입의뢰 Views(Header + Items + status)
        ztivbl00,    ">수입 B/L Views(Header + Items)
        ztivcc00,    ">통관 Views
        ztivgr00,    ">입고 Views
        ztivpn00,
        ztiviv00,    ">상업송장 View
        ztiviv01,    ">선급금   View
        ztiviv02.    ">상업송장 Items + B/L Header Views

************************************************************************
* CONSTANTS                                                            *
************************************************************************
** JS전선 회사코드 2007/04 --------------------------------------
*CONSTANTS:
*    c_bukrs     LIKE t001-bukrs     VALUE '1000'.   ">Company code
** JS전선 회사코드 2007/04 --------------------------------------
************************************************************************
* Internal Tables                                                      *
************************************************************************
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
  s_bukrs  FOR ztitcck-bukrs   "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk
                    MODIF  ID iog ,

  s_ekorg  FOR ztitpnk-ekorg  MODIF  ID iog, "구매조직
  s_ekgrp  FOR ztitpnk-ekgrp  MODIF  ID iog, "구매그룹
  s_ebeln  FOR ztitpnp-ebeln  MODIF  ID iog,  "구매전표번호
  s_ntcbk  FOR ztitpnk-ntcbk  MODIF  ID iog, "통지은행
  s_lifnr  FOR ztitpnk-lifnr  MODIF  ID iog, "송장발행처
  s_pntno  FOR ztitpnk-pntno  MODIF  ID iog, "Notice 관리번호
  s_reqno  FOR ztitpnp-reqno  MODIF  ID iog,  "수입의뢰번호
  s_opnno  FOR ztitpnk-opnno  MODIF  ID iog, "수입개설번호
  s_iblno  FOR ztitpnp-iblno  MODIF  ID iog,  "B/L 관리번호
  s_blnum  FOR ztitpnk-blnum  MODIF  ID iog, "B/L 번호
  s_ivono  FOR ztitpnp-ivono  MODIF  ID iog,  "송장관리번호
  s_pntdt  FOR ztitpnk-pntdt  MODIF  ID iog, "통지일자
  s_stldt  FOR ztitpnk-stldt  MODIF  ID iog, "최종결제일자
  s_ngodt  FOR ztitpnk-ngodt  MODIF  ID iog, "NEGO 일자
  s_expdt  FOR ztitpnk-expdt  MODIF  ID iog, "만기일자
  s_cnam   FOR ztitpnk-cnam   MODIF  ID iog,  "작성인
  s_cdat   FOR ztitpnk-cdat   MODIF  ID iog,  "생성일
  s_unam   FOR ztitpnk-unam   MODIF  ID iog,  "최종변경인
  s_udat   FOR ztitpnk-udat   MODIF  ID iog.  "변경일
SELECTION-SCREEN ULINE.
SELECT-OPTIONS:
  s_dctdt  FOR ztitpnk-dctdt  MODIF  ID iog, "할인일자
  s_bgndt  FOR ztitpnk-bgndt  MODIF  ID iog, "시작일자
  s_kursf  FOR ztitpnk-kursf  MODIF  ID iog, "환율
  s_waers  FOR ztitpnk-waers  MODIF  ID iog, "통화키
  s_pntam  FOR ztitpnk-pntam  MODIF  ID iog, "Notice Amount
  s_dmbtr  FOR ztitpnk-dmbtr  MODIF  ID iog, "현지통화금액
  s_hwaer  FOR ztitpnk-hwaer  MODIF  ID iog, "현지통화
  s_procp  FOR ztitpnk-procp  MODIF  ID iog, "선취/후취
  s_tsatz  FOR ztitpnk-tsatz  MODIF  ID iog, "이자율
  s_itrst  FOR ztitpnk-itrst  MODIF  ID iog, "이자금액
  s_intsc  FOR ztitpnk-intsc  MODIF  ID iog, "이자액 통화키
  s_chgot  FOR ztitpnk-chgot  MODIF  ID iog, "기타수수료
  s_chgoc  FOR ztitpnk-chgoc  MODIF  ID iog, "기타수수료통화
  s_lponr  FOR ztitpnk-lponr  MODIF  ID iog, "최종품목번호

  s_ctme   FOR ztitpnk-ctme   MODIF  ID iog,  "생성시간

  s_utme   FOR ztitpnk-utme   MODIF  ID iog,  "최종변경시간
  s_pntit  FOR ztitpnp-pntit  MODIF  ID iog,  "Notice품목

  s_rblgp  FOR ztitpnp-rblgp  MODIF  ID iog,  "송장문서품목
  s_ebelp  FOR ztitpnp-ebelp  MODIF  ID iog,  "구매문서품목
  s_reqit  FOR ztitpnp-reqit  MODIF  ID iog,  "수입의뢰품목
  s_iblit  FOR ztitpnp-iblit  MODIF  ID iog,  "B/L 품목번호
  s_pnmng  FOR ztitpnp-pnmng  MODIF  ID iog,  "Notice 수량
  s_meins  FOR ztitpnp-meins  MODIF  ID iog.  "기본단위

SELECTION-SCREEN END OF BLOCK dbsel.

SELECTION-SCREEN BEGIN OF BLOCK lists WITH FRAME TITLE text-002.
PARAMETERS: p_vari LIKE disvariant-variant,
            p_item TYPE c AS CHECKBOX DEFAULT 'X'.
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
  PERFORM p1000_alv_fields_initial.
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

**> 지급조건 HELP(Low values)
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_zterm-low.
*  PERFORM get_f4_for_zterm(ZTIr0000) USING s_zterm-low.
**> 지급조건 HELP(High values)
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_zterm-high.
*  PERFORM get_f4_for_zterm(ZTIr0000) USING s_zterm-high.

************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.
*> 검색조건에 해당하는 데이타를 Select.
  PERFORM p2000_data_selections.
*> Header table과 List(Items) table를 만듬.
  PERFORM p2100_header_and_list_build.
*> 품목을 조회하지 않음.
  PERFORM p2001_item_clear USING p_item.
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

  SET TITLEBAR 'T1000' WITH '현황 List'(t10).

ENDFORM.                    " p1001_initialization

*&---------------------------------------------------------------------*
*&      Form  p1100_check_input_values
*&---------------------------------------------------------------------*
FORM p1100_check_input_values .

  TABLES : dfies.
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

  CLEAR: g_count, it_tab, it_header, it_list.
  REFRESH : it_tab, it_header, it_list.
*> PROGRESS Display.
  g_linen    = 30.
  g_out_text = '데이타를 검색 중입니다 %99999%%'(p01).
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

*> I/V 데이타 select.
  SELECT *
         INTO CORRESPONDING FIELDS OF TABLE it_tab
         FROM ztivpn00
        WHERE pntno  IN s_pntno   "Notice 관리번호
          AND bukrs  IN s_bukrs   "회사코드
          AND ekorg  IN s_ekorg   "구매조직
          AND ekgrp  IN s_ekgrp   "구매그룹
          AND ntcbk  IN s_ntcbk   "통지은행
          AND lifnr  IN s_lifnr   "송장발행처
*          and REQNO  in s_REQNO   "수입의뢰번호
          AND opnno  IN s_opnno   "수입개설번호
*          and IBLNO  in s_IBLNO   "B/L 관리번호
          AND blnum  IN s_blnum   "B/L 번호
          AND pntdt  IN s_pntdt   "통지일자
          AND stldt  IN s_stldt   "최종결제일자
          AND ngodt  IN s_ngodt   "NEGO 일자
          AND dctdt  IN s_dctdt   "할인일자
          AND bgndt  IN s_bgndt   "시작일자
          AND expdt  IN s_expdt   "만기일자
          AND kursf  IN s_kursf   "환율
          AND waers  IN s_waers   "통화키
          AND pntam  IN s_pntam   "Notice Amount
          AND dmbtr  IN s_dmbtr   "현지통화금액
          AND hwaer  IN s_hwaer   "현지통화
          AND procp  IN s_procp   "선취/후취
          AND tsatz  IN s_tsatz   "이자율
          AND itrst  IN s_itrst   "이자금액
          AND intsc  IN s_intsc   "이자액 통화키
          AND chgot  IN s_chgot   "기타수수료
          AND chgoc  IN s_chgoc   "기타수수료통화
*          and LPONR  in s_LPONR   "최종품목번호
          AND cnam   IN s_cnam    "작성인
          AND cdat   IN s_cdat    "생성일
          AND ctme   IN s_ctme    "생성시간
          AND unam   IN s_unam    "최종변경인
          AND udat   IN s_udat    "변경일
          AND utme   IN s_utme    "최종변경시간
          AND pntit  IN s_pntit   "Notice품목
          AND ivono  IN s_ivono   "송장관리번호
          AND rblgp  IN s_rblgp   "송장문서품목
          AND ebeln  IN s_ebeln   "구매전표번호
          AND ebelp  IN s_ebelp   "구매문서품목
          AND reqno  IN s_reqno   "수입의뢰번호
          AND reqit  IN s_reqit   "수입의뢰품목
          AND iblno  IN s_iblno   "B/L 관리번호
          AND iblit  IN s_iblit   "B/L 품목번호
          AND pnmng  IN s_pnmng   "Notice 수량
          AND meins  IN s_meins.  "기본단위

  IF sy-subrc NE 0.
    MESSAGE s902.
  ENDIF.

  CLEAR: g_tabix, g_count, g_cnt.
  LOOP AT it_tab.


    g_tabix = sy-tabix.
*   domain의 value.
*    PERFORM get_domain_value_text(ZTIr0000) USING :
*                           'ZTIBLDTY' it_tab-bldty  it_tab-bldtyx,
*                           'ZTIRPTTY' it_tab-rptty  it_tab-rpttyx,
*                           'ZTIFWDTY' it_tab-fwdty  it_tab-fwdtyx,
*                           'ZTINDFTY' it_tab-ndfty  it_tab-ndftyx.
*   공급업체.
    SELECT SINGLE name1 INTO it_tab-name1
      FROM lfa1
     WHERE lifnr EQ it_tab-lifnr.

*  통지은행명
    SELECT SINGLE namet INTO it_tab-namet
      FROM ztstig3
     WHERE epart EQ it_tab-ntcbk
      AND  bukrs EQ s_bukrs-low
      AND  parti EQ 'B'.

*   수입의뢰 TYPE결정.
    CLEAR ztitrqk.

    SELECT SINGLE *
      FROM ztitrqk
     WHERE reqno EQ it_tab-reqno.

    CASE ztitrqk-reqty.
      WHEN 'LO'.
        it_tab-lctxt = '내국신용장'.
      WHEN 'LC'.
        IF ztitrqk-ilcty EQ 'A'.
          it_tab-lctxt = 'At Sight'.
        ELSE.
          it_tab-lctxt = 'Usance'.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.

    SELECT SINGLE umtcu
      INTO it_tab-umtcu
      FROM ztitrqs
     WHERE reqno EQ it_tab-reqno.

    IF it_tab-umtcu EQ 'X'.
      it_tab-umtcx = '이종통화'.
    ELSE.
      CLEAR it_tab-umtcx.
    ENDIF.

*   p/o정보.
    SELECT  SINGLE menge werks matnr txz01
      INTO  (it_tab-menge, it_tab-werks, it_tab-matnr, it_tab-txz01)
      FROM  ztivpo00
     WHERE  ebeln  = it_tab-ebeln
       AND  ebelp  = it_tab-ebelp.

*   수입의뢰 정보 수량.
*    SELECT  SINGLE rqmng
*      INTO  it_tab-menge
*      FROM  ZTIvrq00
*     WHERE  reqno  = it_tab-reqno
*       AND  reqit  = it_tab-reqit.

*     i/v 정보 수량.
    SELECT  SINGLE remng
      INTO  it_tab-remng
      FROM  ztiviv00
     WHERE  ivono  = it_tab-ivono
       AND  rblgp  = it_tab-rblgp.

*     p/n 누적수량.
    SELECT  SUM( pnmng ) INTO it_tab-pnmngs FROM ztitpnp
     WHERE  pntno  = it_tab-pntno
       AND  pntit  = it_tab-pntit.

*     c/c 가능수량.
    it_tab-pnmngl =  it_tab-remng - it_tab-pnmngs.

*    move it_tab-iccno to it_tab-iccnot.
    MOVE it_tab-netwr TO it_tab-fnetwr.

    ADD 1 TO g_count.

    MODIFY it_tab INDEX g_tabix.

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
************************************************************************
* Templete                                                 *
************************************************************************

*>>>>>>HEADER
"BOX.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'FIELDNAME'     'BOX',
          'E' 'KEY'           ' ',
"B/L 관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITPNK',
          ' ' 'FIELDNAME'     'PNTNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"수입의뢰 Type
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     '수입의뢰Type',
          ' ' 'FIELDNAME'     'LCTXT',
          ' ' 'OUTPUTLEN'     10,
          'E' 'HOTSPOT'       'X',

"수입의뢰 Type
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     '이종여부',
          ' ' 'FIELDNAME'     'UMTCX',
          ' ' 'OUTPUTLEN'     8,
          'E' 'HOTSPOT'       'X',

"공급업체코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'LIFNR',
          ' ' 'OUTPUTLEN'     20,
          'E' 'HOTSPOT'       'X',
"공급업체명
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'OUTPUTLEN'      50,
          'E' 'FIELDNAME'     'NAME1',
*"ilctyx
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITIVHD',
**          ' ' 'seltext_m'     '',
*          ' ' 'FIELDNAME'     'BUDAT',
*          'E' 'OUTPUTLEN'     '10',
"회사코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'BUKRS',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '4',

"통지은행코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITPNK',
          ' ' 'FIELDNAME'     'NTCBK',
          'E' 'OUTPUTLEN'     '20',



"송장금액통화
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     'Cur',
          ' ' 'REF_TABNAME'   'ZTITPNK',
          ' ' 'FIELDNAME'     'WAERS',
          'E' 'OUTPUTLEN'     '3',
"송장금액.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     '송장값 (외화)',
          ' ' 'FIELDNAME'     'FNETWR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '16',
"통지일자
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITPNK',
          ' ' 'FIELDNAME'     'PNTDT',
          ' ' 'NO_OUT'        'X',
*          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '15',
"최종결제일자
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITPNK',
          ' ' 'FIELDNAME'     'STLDT',
          'E' 'OUTPUTLEN'     '10',
"만기일자
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITPNK',
          ' ' 'FIELDNAME'     'EXPDT',
          'E' 'OUTPUTLEN'     '10',
"NEGO 일자
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITPNK',
          ' ' 'FIELDNAME'     'NGODT',
          'E' 'OUTPUTLEN'     '10',
"할인일자
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITPNK',
          ' ' 'FIELDNAME'     'DCTDT',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"시작일자
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITPNK',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'BGNDT',
          'E' 'OUTPUTLEN'     '10',
"론번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITPNK',
          ' ' 'HOTSPOT'       'X',
          ' ' 'FIELDNAME'     'XRANL',
          'E' 'OUTPUTLEN'     '10',

"수입개설번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITPNK',
          ' ' 'HOTSPOT'       'X',
          ' ' 'FIELDNAME'     'OPNNO',
          'E' 'OUTPUTLEN'     '20',

"B/L 번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITPNK',
          ' ' 'HOTSPOT'       'X',
          ' ' 'FIELDNAME'     'BLNUM',
          'E' 'OUTPUTLEN'     '20',

"USANCE 반제 전표년도
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITPNK',
          ' ' 'FIELDNAME'     'GJAHR',
          ' ' 'HOTSPOT'       'X',
          ' ' 'NO_OUT'        ' ',
          'E' 'OUTPUTLEN'     '4',

"USANCE 반제 전표
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITPNK',
          ' ' 'HOTSPOT'       'X',
          ' ' 'NO_OUT'        ' ',
          ' ' 'FIELDNAME'     'BELNR',
          'E' 'OUTPUTLEN'     '10',

*>>>>>>>>>LIST
"B/L 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITPNP',
          ' ' 'FIELDNAME'     'PNTIT',
          ' ' 'HOTSPOT'       'X',
          ' ' 'JUST'          c_charl," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
          ' ' 'INTLEN'         10,
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',

"구매전표번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITPNP',
          ' ' 'FIELDNAME'     'EBELN',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '10',

"구매문서 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITPNP',
          ' ' 'FIELDNAME'     'EBELP',
          ' ' 'JUST'          c_charl," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
          ' ' 'NO_OUT'        ' ',
          'E' 'OUTPUTLEN'     '8',

"자재번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISPNIT',
          ' ' 'FIELDNAME'     'MATNR',
          'E' 'OUTPUTLEN'     '20',

"자재내역.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISPNIT',
          ' ' 'FIELDNAME'     'TXZ01',
          'E' 'OUTPUTLEN'     '50',

"통지은행명
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTSTIG3',
          ' ' 'FIELDNAME'     'NAMET',
          'E' 'OUTPUTLEN'     '20',

"송장금액.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'seltext_m'     '송장값',
          ' ' 'FIELDNAME'     'NETWR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'JUST'          c_charr," (R)ight (L)eft (C)ent.
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '20',

"I/V수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISPNIT',
*          ' ' 'seltext_m'     'I/V수량',
          ' ' 'FIELDNAME'     'PNMNG',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        ' ',
          'E' 'OUTPUTLEN'     '15',

"기본단위
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITPNP',
          ' ' 'FIELDNAME'     'MEINS',
          ' ' 'INTLEN'         10,
          'E' 'OUTPUTLEN'     '5',

"송장관리번호
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITPNP',
          ' ' 'FIELDNAME'     'IVONO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '10',

"수입의뢰번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITPNP',
          ' ' 'FIELDNAME'     'REQNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'NO_OUT'        ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '10',

"수입의뢰 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITPNP',
          ' ' 'JUST'          c_charl," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'REQIT',
          'E' 'OUTPUTLEN'     '10',

"자재문서번호
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITPNP',
          ' ' 'FIELDNAME'     'MBLNR',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',

"자재문서연도
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITPNP',
          ' ' 'FIELDNAME'     'MJAHR',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',

"자재문서품목
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITPNP',
          ' ' 'FIELDNAME'     'ZEILE',
          ' ' 'NO_OUT'        'X',
*          'E' 'OUTPUTLEN'     '10'.

"작성인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITPNP',
          ' ' 'FIELDNAME'     'CNAM',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',

"최종변경인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITPNP',
          ' ' 'FIELDNAME'     'UNAM',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10'.







**********************************************************
**  frequently.
*  PERFORM 3010_fill_field_category USING :
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITIVHD',
*          ' ' 'SELTEXT_M'     '',
*          ' ' 'FIELDNAME'     '',
*          ' ' 'HOTSPOT'       '',
*          ' ' 'OUTPUTLEN'     '',
*          ' ' 'NO_OUT'        '',
*          ' ' 'CFIELDNAME'    'WAERS',
*          ' ' 'CTABNAME'      'IT_HEADER',
*          ' ' 'QFIELDNAME'    'MEINS',
*          ' ' 'QTABNAME'      'IT_LIST',
*          'E' 'KEY'           ''.
*"BOX.
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'FIELDNAME'     'BOX',
*          'E' 'KEY'           ' '.

*  CLEAR  gs_fieldcat.
*  gs_fieldcat-TABNAME   = 'IT_HEADER'.
*  gs_fieldcat-FIELDNAME = 'BOX'.
*  APPEND  gs_fieldcat TO IT_fieldcat.
*
** Build the fieldcat according to DDIC structure SBOOK:
*  call function 'REUSE_ALV_FIELDCATALOG_MERGE'
*       exporting
*            i_structure_name   = 'ZTITPNK'
*            I_INTERNAL_TABNAME = 'IT_HEADER'
*       changing
*            ct_fieldcat      = IT_fieldcat[].
*
*  call function 'REUSE_ALV_FIELDCATALOG_MERGE'
*       exporting
*            i_structure_name   = 'ZTISPNIT'
*            I_INTERNAL_TABNAME = 'IT_LIST'
*       changing
*            ct_fieldcat      = IT_fieldcat[].
*
*  LOOP AT IT_FIELDCAT INTO gs_fieldcat.
*
*     IF ( gs_fieldcat-fieldname = 'PNTNO' and
*          gs_fieldcat-TABNAME   = 'IT_HEADER' )
*       OR gs_fieldcat-fieldname = 'NTCBK'
*       OR gs_fieldcat-fieldname = 'LIFNR'
*       OR gs_fieldcat-fieldname = 'OPNNO'
*       OR gs_fieldcat-fieldname = 'BLNUM'
*       OR gs_fieldcat-fieldname = 'PNTDT'
*       OR gs_fieldcat-fieldname = 'STLDT'
*       OR gs_fieldcat-fieldname = 'NGODT'
*       OR gs_fieldcat-fieldname = 'PNTIT'
*       OR gs_fieldcat-fieldname = 'EBELN'
*       OR gs_fieldcat-fieldname = 'EBELP'
*       OR gs_fieldcat-fieldname = 'IVONO'
*       OR gs_fieldcat-fieldname = 'RBLGP'
*       or ( gs_fieldcat-fieldname = 'REQNO' and
*            gs_fieldcat-TABNAME   = 'IT_LIST' )
*       or ( gs_fieldcat-fieldname = 'IBLNO' and
*            gs_fieldcat-TABNAME   = 'IT_LIST' ).
*
*
*          clear gs_fieldcat-no_out.
*     ELSE.
*          gs_fieldcat-no_out = 'X'.
*     ENDIF.
*     gs_fieldcat-COL_POS = ' '.
*     MODIFY IT_FIELDCAT FROM gs_fieldcat INDEX SY-TABIX.
*
*  ENDLOOP.

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

  gs_keyinfo-header01 = 'PNTNO'.
  gs_keyinfo-item01   = 'PNTNO'.

  gs_keyinfo-header02 =  space.
  gs_keyinfo-item02   = 'PNTIT'.

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
  gs_listheader-info = 'Noitce 현황 List'(t13).
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
  ls_sort-fieldname = 'PNTNO'.
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
*  clear ls_variant.
*  ls_variant = p_vari.


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
    WHEN '&REFRESH'.
      PERFORM p9000_duelist_refresh USING  rs_selfield.

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

        WHEN 'REQNO'.
          PERFORM  display_import_document(ztir0000)
                                          USING ls_header-reqno
                                                space
                                                ls_header-reqit.

        WHEN 'IBLNO' OR 'IBLIT'.
          PERFORM  display_bl_document(ztir0000)
                                          USING ls_header-iblno
                                                ls_header-iblit.

        WHEN 'IVONO'.
          PERFORM display_civ_document(ztir0000)
                                          USING ls_header-ivono.

        WHEN 'XRANL'.
          PERFORM display_loan_master(ztir0000)
                                          USING ls_header-xranl
                                                ls_header-ekorg.

        WHEN 'BELNR' OR 'GJAHR'.
          PERFORM display_liv_document(ztir0000)
                                         USING ls_header-belnr
                                               ls_header-gjahr
                                               ls_header-bukrs.

        WHEN OTHERS.
          PERFORM display_pn_document(ztir0000)
                                          USING ls_header-pntno.

      ENDCASE.
    WHEN OTHERS.
  ENDCASE.

  CLEAR: r_ucomm.

ENDFORM.                    "USER_COMMAND
*---------------------------------------------------------------------*
*       FORM PF_STATUS_SET                                            *
*---------------------------------------------------------------------*
FORM pf_status_set USING rt_extab TYPE slis_t_extab.

  SET TITLEBAR 'T1000' WITH '현황 List'(t10).

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
