************************************************************************
* Title         :  ZTIR3020                                            *
*                                                                      *
* Description   : [Report] Invoice Verification 현황 List              *
*                                                                      *
* Creation Date : 2004/02/22                                           *
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
REPORT  ztir3020       MESSAGE-ID zmti00
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
            ivono       LIKE ztitivk-ivono,    "송장 관리번호
            ivnum       LIKE ztitivk-ivnum,    "송장번호
            civdt       LIKE ztitivk-civdt,    "문서의 송장일
            vorgang     LIKE ztitivk-vorgang,  "트랜잭션/이벤트
            bukrs       LIKE ztitivk-bukrs,    "회사코드
            ekorg       LIKE ztitivk-ekorg,    "구매조직
            ekgrp       LIKE ztitivk-ekgrp,    "구매그룹
            blart       LIKE ztitivk-blart,    "전표유형
            bupla       LIKE ztitivk-bupla,    "사업장
            gsber       LIKE ztitivk-gsber,    "사업영역
            budat       LIKE ztitivk-budat,    "전표의 전기일
            bldat       LIKE ztitivk-bldat,    "전표에서 송장일
            zterm       LIKE ztitivk-zterm,    "지급조건키
            zfbdt       LIKE ztitivk-zfbdt,    "만기계산기준일
            netdt       LIKE ztitivk-netdt,    "순액지급 만기일
            zbd1t       LIKE ztitivk-zbd1t,    "현금할인기간 1
            zbd2t       LIKE ztitivk-zbd2t,    "현금 할인기간 2
            zbd3t       LIKE ztitivk-zbd3t,    "순액지급조건기간
            zbd1p       LIKE ztitivk-zbd1p,    "현금할인율 1
            zbd2p       LIKE ztitivk-zbd2p,    "두번째 현금할인율
            mwskz       LIKE ztitivk-mwskz,    "부가가치세코드
            waers       LIKE ztitivk-waers,    "통화키
            wwert       LIKE ztitivk-wwert,    "환산일
            lifnr       LIKE ztitivk-lifnr,    "다른 송장발행처
            ivamt       LIKE ztitivk-ivamt,    "문서통화 - 총송장금액
            ivamp       LIKE ztitivk-ivamp,    "서통화 - 총처리금액
            pkchg       LIKE ztitivk-pkchg,    "Packing charge
            hdchg       LIKE ztitivk-hdchg,    "Handling Charge
            otchg       LIKE ztitivk-otchg,    "Others Charge
            rtchg       LIKE ztitivk-rtchg,    "Retention amount
            livst       LIKE ztitivk-livst,    "송장처리 상태
            prpyn       LIKE ztitivk-prpyn,    "선급금 구분
            pprat       LIKE ztitivk-pprat,    "선급금 비율
            xblnr       LIKE ztitivk-xblnr,    "참조전표번호
            bktxt       LIKE ztitivk-bktxt,    "전표헤더텍스트
            zlspr       LIKE ztitivk-zlspr,    "지급보류키
            zlsch       LIKE ztitivk-zlsch,    "지급방법
            uzawe       LIKE ztitivk-uzawe,    "지급방법보충
            belnr       LIKE ztitivk-belnr,    "송장문서의 문서번호
            gjahr       LIKE ztitivk-gjahr,    "회계연도
            lponr       LIKE ztitivk-lponr.    "최종품목번호
*non iv dictionary.
TYPES:      trefwr      LIKE ztitivp-refwr,    "송장값 total
            name1       LIKE lfa1-name1.       "LIFNR명

TYPES: END OF ty_header.

TYPES: BEGIN OF ty_item.
INCLUDE     TYPE        ty_header.
TYPES :     rblgp       LIKE ztitivp-rblgp,                 "5 품목
            ebeln       LIKE ztitivp-ebeln,                 "10구매전표
            ebelp       LIKE ztitivp-ebelp,   "5구매문서 품목
            reqno       LIKE ztitivp-reqno,   "10수입의뢰번호
            reqit       LIKE ztitivp-reqit,   "5수입의뢰 품목
            iblno       LIKE ztitivp-iblno,   "10B/L 관리번호
            iblit       LIKE ztitivp-iblit,   "5B/L 품목번호
            refwr       LIKE ztitivp-refwr,   "13송장값 (외화)trefwr
            remng       LIKE ztitivp-remng,   "13송장처리수량
            meins       LIKE ztitivp-meins,                 "3기본단위
            tbtkz       LIKE ztitivp-tbtkz,   "1후속 차변/대변
            kschl       LIKE ztitivp-kschl,                 "4조건유형
            stunr       LIKE ztitivp-stunr,                 "3단계번호
            zaehk       LIKE ztitivp-zaehk,   "2조건카운터
            sgtxt       LIKE ztitivp-sgtxt,   "50항목텍스트
            cnam        LIKE ztitivp-cnam,                  "12작성인
            cdat        LIKE ztitivp-cdat,                  "8생성일
            ctme        LIKE ztitivp-ctme,                  "6생성시간
            unam        LIKE ztitivp-unam,    "12최종변경인
            udat        LIKE ztitivp-udat,                  "8변경일
            utme        LIKE ztitivp-utme,    "6최종변경시간
            flag        LIKE ztisivit-flag,                 "1일반표시
            menge       LIKE ztisivit-menge,                "13수량
            ivmngs      LIKE ztisivit-ivmngs, "13I/V 누적수량
            ivmngl      LIKE ztisivit-ivmngl, "13I/V 가능수량
            werks       LIKE ztisivit-werks,                "4플랜트
            name2       LIKE ztisivit-name1,                "30플랜트
            lgort       LIKE ztisivit-lgort,                "4저장위치
            lgobe       LIKE ztisivit-lgobe,                "16저장위치
            matnr       LIKE ztisivit-matnr,                "18자재번호
            txz01       LIKE ztisivit-txz01,                "40내역
            netwr       LIKE ztisivit-netwr,  "15문서통화 정가
            eeind       LIKE ztisivit-eeind,                "10납품일
            umson       LIKE ztisivit-umson,                "1무상품목
            loekz       LIKE ztisivit-loekz,  "1구매문서삭제지시
            elikz       LIKE ztisivit-elikz,  "1"납품완료"지시자
            bprme       LIKE ztisivit-bprme,  "3오더가격단위
            bpumz       LIKE ztisivit-bpumz,  "5오더단위환산분자
            bpumn       LIKE ztisivit-bpumn,  "5오더단위환산분모
            umrez       LIKE ztisivit-umrez,  "5기본단위전환분자
            umren       LIKE ztisivit-umren,  "5기본단위전환분모
            netpr       LIKE ztisivit-netpr,  "11구매문서의 단가
            peinh       LIKE ztisivit-peinh,                "5가격단위
            uebto       LIKE ztisivit-uebto,  "3초과납품 허용치
            uebtk       LIKE ztisivit-uebtk,  "1허용무제한초과납품
            untto       LIKE ztisivit-untto.  "3미달납품 허용치
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
        ztitrqp,
        ztitblk,
        ztitblp,
        ztitivk,
        ztitivp.

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES: ztivpo00,    ">Purchasing Document : Header + Items
        ztivrq00,    ">수입의뢰 Views(Header + Items + status)
        ztivbl00,    ">수입 B/L Views(Header + Items)
        ztivcc00,    ">통관 Views
        ztivgr00,    ">입고 Views
        ztiviv00,    ">상업송장 View
        ztiviv01,    ">선급금   View
        ztiviv02.    ">상업송장 Items + B/L Header Views

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
  s_bukrs  FOR ztitivk-bukrs                   "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk
                    MODIF  ID iog ,
  s_ekorg  FOR ztitivk-ekorg MODIF  ID iog,                 "4구매조직
  s_ekgrp  FOR ztitivk-ekgrp MODIF  ID iog,                 "3구매그룹
  s_ebeln  FOR ztitivp-ebeln MODIF  ID iog,                 "10구매전표
  s_ivono  FOR ztitivk-ivono MODIF  ID iog,    "10송장 관리번호
  s_ivnum  FOR ztitivk-ivnum MODIF  ID iog,                 "20송장번호
  s_civdt  FOR ztitivk-civdt MODIF  ID iog,    "8문서의 송장일
  s_reqno  FOR ztitivp-reqno MODIF  ID iog,    "10수입의뢰번호
  s_iblno  FOR ztitivp-iblno MODIF  ID iog,    "10B/L 관리번호
  s_vorga  FOR ztitivk-vorgang MODIF ID iog,   "1트랜잭션/이벤트
  s_blart  FOR ztitivk-blart MODIF  ID iog,                 "2전표유형
  s_bupla  FOR ztitivk-bupla MODIF  ID iog,                 "4사업장
  s_gsber  FOR ztitivk-gsber MODIF  ID iog.                 "4사업영역
SELECTION-SCREEN ULINE.
SELECT-OPTIONS:
  s_budat  FOR ztitivk-budat MODIF  ID iog,   "8전표의 전기일
  s_bldat  FOR ztitivk-bldat MODIF  ID iog,   "8전표에서 송장일
  s_zterm  FOR ztitivk-zterm MODIF  ID iog,   "4지급조건키
  s_zfbdt  FOR ztitivk-zfbdt MODIF  ID iog,   "8만기계산기준일
  s_netdt  FOR ztitivk-netdt MODIF  ID iog,   "8순액지급 만기일
  s_mwskz  FOR ztitivk-mwskz MODIF  ID iog,   "2부가가치세코드
  s_waers  FOR ztitivk-waers MODIF  ID iog,                 "5통화키
  s_wwert  FOR ztitivk-wwert MODIF  ID iog,                 "8환산일
  s_lifnr  FOR ztitivk-lifnr MODIF  ID iog,   "10다른 송장발행처
  s_livst  FOR ztitivk-livst MODIF  ID iog,   "1송장처리 상태
  s_prpyn  FOR ztitivk-prpyn MODIF  ID iog,   "1선급금 구분
  s_pprat  FOR ztitivk-pprat MODIF  ID iog,   "3선급금 비율
  s_xblnr  FOR ztitivk-xblnr MODIF  ID iog,   "16참조전표번호
  s_bktxt  FOR ztitivk-bktxt MODIF  ID iog,   "25전표헤더텍스트
  s_zlspr  FOR ztitivk-zlspr MODIF  ID iog,   "1지급보류키
  s_zlsch  FOR ztitivk-zlsch MODIF  ID iog,                 "1지급방법
  s_uzawe  FOR ztitivk-uzawe MODIF  ID iog,   "2지급방법보충
  s_belnr  FOR ztitivk-belnr MODIF  ID iog,   "10송장문서의 문서번호
  s_gjahr  FOR ztitivk-gjahr MODIF  ID iog,                 "4회계연도
  s_lponr  FOR ztitivk-lponr MODIF  ID iog,   "6최종품목번호
  s_rblgp  FOR ztitivp-rblgp MODIF  ID iog,                 "5 품목
  s_ebelp  FOR ztitivp-ebelp MODIF  ID iog,   "5구매문서 품목
  s_reqit  FOR ztitivp-reqit MODIF  ID iog,   "5수입의뢰 품목
  s_iblit  FOR ztitivp-iblit MODIF  ID iog,   "5B/L 품목번호
  s_tbtkz  FOR ztitivp-tbtkz MODIF  ID iog,   "1후속 차변/대변
  s_kschl  FOR ztitivp-kschl MODIF  ID iog,                 "4조건유형
  s_stunr  FOR ztitivp-stunr MODIF  ID iog,                 "3단계번호
  s_zaehk  FOR ztitivp-zaehk MODIF  ID iog,   "2조건카운터
  s_sgtxt  FOR ztitivp-sgtxt MODIF  ID iog,   "50항목텍스트
  s_cnam   FOR ztitivp-cnam  MODIF  ID iog,                 "12작성인
  s_cdat   FOR ztitivp-cdat  MODIF  ID iog,                 "8생성일
  s_ctme   FOR ztitivp-ctme  MODIF  ID iog,                 "6생성시간
  s_unam   FOR ztitivp-unam  MODIF  ID iog,   "12최종변경인
  s_udat   FOR ztitivp-udat  MODIF  ID iog,                 "8변경일
  s_utme   FOR ztitivp-utme  MODIF  ID iog.   "6최종변경시간
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

************************************************************************
* 20070603 simcho by C2007060401000000092
************************************************************************
  LOOP AT it_tab.
    IF sy-tabix >= 2.
      it_tab-zbd1t = 0.
      MODIFY it_tab.
    ENDIF.
  ENDLOOP.
************************************************************************

  PERFORM p2100_header_and_list_build.

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
        FROM ztiviv00
       WHERE ivono   IN s_ivono   "10송장 관리번호
         AND ivnum   IN s_ivnum                             "20송장번호
         AND civdt   IN s_civdt   "8문서의 송장일
         AND vorgang IN s_vorga   "1트랜잭션/이벤트
         AND bukrs   IN s_bukrs                             "4회사코드
         AND ekorg   IN s_ekorg                             "4구매조직
         AND ekgrp   IN s_ekgrp                             "3구매그룹
         AND blart   IN s_blart                             "2전표유형
         AND bupla   IN s_bupla                             "4사업장
         AND gsber   IN s_gsber                             "4사업영역
         AND budat   IN s_budat   "8전표의 전기일
         AND bldat   IN s_bldat   "8전표에서 송장일
         AND zterm   IN s_zterm   "4지급조건키
         AND zfbdt   IN s_zfbdt   "8만기계산기준일
         AND netdt   IN s_netdt   "8순액지급 만기일
         AND mwskz   IN s_mwskz   "2부가가치세코드
         AND waers   IN s_waers                             "5통화키
         AND wwert   IN s_wwert                             "8환산일
         AND lifnr   IN s_lifnr   "10다른 송장발행처
         AND livst   IN s_livst   "1송장처리 상태
         AND prpyn   IN s_prpyn   "1선급금 구분
         AND pprat   IN s_pprat   "3선급금 비율
         AND xblnr   IN s_xblnr   "16참조전표번호
         AND bktxt   IN s_bktxt   "25전표헤더텍스트
         AND zlspr   IN s_zlspr   "1지급보류키
         AND zlsch   IN s_zlsch                             "1지급방법
         AND uzawe   IN s_uzawe   "2지급방법보충
         AND belnr   IN s_belnr   "10송장문서의 문서번호
         AND gjahr   IN s_gjahr                             "4회계연도
         AND ebeln   IN s_ebeln                             "10구매전표
         AND ebelp   IN s_ebelp	"5구매문서 품목
         AND reqno   IN s_reqno	"10수입의뢰번호
         AND reqit   IN s_reqit	"5수입의뢰 품목
         AND iblno   IN s_iblno	"10B/L 관리번호
         AND iblit   IN s_iblit	"5B/L 품목번호
         AND tbtkz   IN s_tbtkz	"1후속 차변/대변
         AND kschl   IN s_kschl                             "4조건유형
         AND stunr   IN s_stunr                             "3단계번호
         AND zaehk   IN s_zaehk   "2조건카운터
         AND sgtxt   IN s_sgtxt   "50항목텍스트
         AND cnam    IN s_cnam                              "12작성인
         AND cdat    IN s_cdat                              "8생성일
         AND ctme    IN s_ctme                              "6생성시간
         AND unam    IN s_unam    "12최종변경인
         AND udat    IN s_udat                              "8변경일
         AND utme    IN s_utme.    "6최종변경시간

  IF sy-subrc NE 0.
    MESSAGE s902.
  ENDIF.

  CLEAR: g_tabix, g_count, g_cnt.
  LOOP AT it_tab.

    g_tabix = sy-tabix.
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

*   b/l 정보 수량.
    SELECT  SINGLE blmng
      INTO  it_tab-menge
      FROM  ztivbl00
     WHERE  iblno  = it_tab-iblno
       AND  iblit  = it_tab-iblit.

*   b/l 누적수량.
    SELECT  SUM( remng ) INTO it_tab-ivmngs FROM ztitivp
     WHERE  ivono  = it_tab-ivono
       AND  rblgp  = it_tab-rblgp.

*   b/l 가능수량.
    it_tab-ivmngl =  it_tab-menge - it_tab-ivmngs.

    MOVE it_tab-refwr TO it_tab-trefwr.

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
*>>>>>>HEADER
"BOX.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'FIELDNAME'     'BOX',
          'E' 'KEY'           ' ',
"I/V 관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITIVK',
          ' ' 'FIELDNAME'     'IVONO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"I/V번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITIVK',
          ' ' 'FIELDNAME'     'IVNUM',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '25',
"송장일.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'seltext_m'     '문서종류',
          ' ' 'REF_TABNAME'   'ZTITIVK',
          ' ' 'FIELDNAME'     'CIVDT',
          'E' 'OUTPUTLEN'     '10',

"만기일.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'seltext_m'     '문서종류',
          ' ' 'REF_TABNAME'   'ZTITIVK',
          ' ' 'FIELDNAME'     'NETDT',
          'E' 'OUTPUTLEN'     '10',
"공급업체코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'EKKO',
          ' ' 'FIELDNAME'     'LIFNR',
          ' ' 'OUTPUTLEN'     20,
          'E' 'HOTSPOT'       'X',

"공급업체명
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'OUTPUTLEN'     50,
          'E' 'FIELDNAME'     'NAME1',

*"ETD
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
*          ' ' 'FIELDNAME'     'BLETD',
*          'E' 'OUTPUTLEN'     '10',
*"ETA
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
**          ' ' 'seltext_m'     '',
*          ' ' 'FIELDNAME'     'BLETA',
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
*           ' ' 'NO_OUT'        'X',
*          ' ' 'FIELDNAME'     'FWDTYX',
*          'E' 'OUTPUTLEN'     '8',
*"수입신고구분
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
*          ' ' 'seltext_m'     '신고구분',
*           ' ' 'NO_OUT'        'X',
*          ' ' 'FIELDNAME'     'RPTTYX',
*          'E' 'OUTPUTLEN'     '14',
"송장금액통화
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     'Cur',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'WAERS',
          'E' 'OUTPUTLEN'     '3',
"송장금액.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     '송장값 (외화)',
          ' ' 'FIELDNAME'     'TREFWR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '16',

*>>>>>>>>>LIST
"I/V 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVP',
          ' ' 'FIELDNAME'     'RBLGP',
          ' ' 'HOTSPOT'       'X',
          ' ' 'JUST'          c_charl," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
          ' ' 'INTLEN'         10,
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"구매전표번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVP',
          ' ' 'FIELDNAME'     'EBELN',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '12',
"구매문서 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVP',
          ' ' 'FIELDNAME'     'EBELP',
          ' ' 'JUST'          c_charl," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '5',
"B/L.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVP',
          ' ' 'FIELDNAME'     'IBLNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '12',
"수입의뢰번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVP',
          ' ' 'FIELDNAME'     'REQNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '10',
"수입의뢰 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVP',
          ' ' 'JUST'          c_charl," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         c_charx,
          ' ' 'FIELDNAME'     'REQIT',
          'E' 'OUTPUTLEN'     '10',
"자재번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISIVIT',
          ' ' 'FIELDNAME'     'MATNR',
          'E' 'OUTPUTLEN'     '20',

"자재내역.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISIVIT',
          ' ' 'FIELDNAME'     'TXZ01',
          'E' 'OUTPUTLEN'     '50',

*"수입의뢰수량
*          'S' 'TABNAME'       'IT_LIST',
**          ' ' 'REF_TABNAME'   'ZTISBLIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
*          ' ' 'FIELDNAME'     'MENGE',
*          ' ' 'QFIELDNAME'    'MEINS',
*          ' ' 'QTABNAME'      'IT_LIST',
*          ' ' 'NO_OUT'        'X',
*          'E' 'OUTPUTLEN'     '15',
*"B/L가능수량
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISBLIT',
**          ' ' 'seltext_m'     '수입의뢰수량',
*          ' ' 'FIELDNAME'     'BLMNGL',
*          ' ' 'QFIELDNAME'    'MEINS',
*          ' ' 'QTABNAME'      'IT_LIST',
*          ' ' 'NO_OUT'        'X',
*          'E' 'KEY'           ' ',
*"B/L누적수량
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISBLIT',
**          ' ' 'seltext_m'     '수입의뢰수량',
*          ' ' 'FIELDNAME'     'BLMNGS',
*          ' ' 'QFIELDNAME'    'MEINS',
*          ' ' 'QTABNAME'      'IT_LIST',
*          ' ' 'NO_OUT'        'X',
*          'E' 'KEY'           ' ',
*"B/L수량
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISBLIT',
**          ' ' 'seltext_m'     '수입의뢰수량',
*          ' ' 'QFIELDNAME'    'MEINS',
*          ' ' 'QTABNAME'      'IT_LIST',
*          ' ' 'NO_OUT'        'X',
*          ' ' 'FIELDNAME'     'BLMNG',
*          'E' 'KEY'           ' ',
*"송장가능수량
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISIVIT',
*          ' ' 'seltext_m'     'I/V가능수량    ',
*          ' ' 'FIELDNAME'     'IVMNGL',
*          ' ' 'QFIELDNAME'    'MEINS',
*          ' ' 'QTABNAME'      'IT_LIST',
*          'E' 'OUTPUTLEN'     '16',
*"기본단위
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTITBLP',
*          ' ' 'FIELDNAME'     'MEINS',
*          ' ' 'INTLEN'         10,
*          'E' 'OUTPUTLEN'     '4',
"송장금액.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'seltext_m'     '송장값',
          ' ' 'FIELDNAME'     'REFWR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'JUST'          c_charr," (R)ight (L)eft (C)ent.
*          ' ' 'LZERO'         c_charx,
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '20',
*"자재문서번호
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTITBLP',
*          ' ' 'FIELDNAME'     'MBLNR',
*          ' ' 'NO_OUT'        'X',
*          'E' 'OUTPUTLEN'     '10',
*"자재문서연도
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTITBLP',
*          ' ' 'FIELDNAME'     'MJAHR',
*          ' ' 'NO_OUT'        'X',
*          'E' 'OUTPUTLEN'     '10',
*"자재문서품목
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTITBLP',
*          ' ' 'FIELDNAME'     'ZEILE',
*          ' ' 'NO_OUT'        'X',
**          'E' 'OUTPUTLEN'     '10'.
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






*****************************************************

*  CLEAR  gs_fieldcat.
*  gs_fieldcat-TABNAME   = 'IT_HEADER'.
*  gs_fieldcat-FIELDNAME = 'BOX'.
*  APPEND  gs_fieldcat TO IT_fieldcat.
*
** Build the fieldcat according to DDIC structure SBOOK:
*  call function 'REUSE_ALV_FIELDCATALOG_MERGE'
*       exporting
*            i_structure_name   = 'ZTITIVK'
*            I_INTERNAL_TABNAME = 'IT_HEADER'
*       changing
*            ct_fieldcat      = IT_fieldcat[].
*
*  call function 'REUSE_ALV_FIELDCATALOG_MERGE'
*       exporting
*            i_structure_name   = 'ZTITIVP'
*            I_INTERNAL_TABNAME = 'IT_LIST'
*       changing
*            ct_fieldcat      = IT_fieldcat[].
*
*  DELETE IT_FIELDCAT WHERE TABNAME = 'IT_HEADER'
*                       AND fieldname = 'MANDT'.
*
*  DELETE IT_FIELDCAT WHERE TABNAME = 'IT_LIST'
*                       AND fieldname = 'MANDT'.
*
*  DELETE IT_FIELDCAT WHERE TABNAME = 'IT_LIST'
*                       AND fieldname = 'IVONO'.
*
*  LOOP AT IT_FIELDCAT INTO gs_fieldcat.
*
*     IF   gs_fieldcat-fieldname = 'IVONO'
*       OR gs_fieldcat-fieldname = 'IVNUM'
*       OR gs_fieldcat-fieldname = 'CIVDT'
*       OR gs_fieldcat-fieldname = 'BELNR'
*       OR gs_fieldcat-fieldname = 'RBLGP'
*       OR gs_fieldcat-fieldname = 'EBELP'
*       OR gs_fieldcat-fieldname = 'REQNO'
*       OR gs_fieldcat-fieldname = 'REQIT'
*       OR gs_fieldcat-fieldname = 'IBLNO'.
*
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

  gs_keyinfo-header01 = 'IVONO'.
  gs_keyinfo-item01   = 'IVONO'.

  gs_keyinfo-header02 =  space.
  gs_keyinfo-item02   = 'RBLGP'.

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
  gs_listheader-info = 'I/V 현황 List'(t13).
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
  ls_sort-fieldname = 'IVONO'.
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

    WHEN 'ZTIT001'. " 후속기능
**> 개설 의뢰 상태에 따라 ZTIT005(접수) ZTIT006(신청) ZTIT007(개설)
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
***> 개설 의뢰 상태에 따라 ZTIT005(접수) ZTIT006(신청) ZTIT007(개설)
**          CASE it_header-docst.
**            WHEN 'C'. "수입의뢰
**              MOVE 'ZTIT005' TO r_ucomm.
**            WHEN 'A'. "접수
**              MOVE 'ZTIT006' TO r_ucomm.
**            WHEN 'Y'. "개설신청
**              MOVE 'ZTIT007' TO r_ucomm.
**            WHEN 'O'.
**
**            WHEN OTHERS.
**          ENDCASE.
**          SET PARAMETER ID 'ZTIREQNO' FIELD it_header-reqno.
**          SET PARAMETER ID 'ZTIAMDSQ' FIELD it_header-amdsq.
*          CALL TRANSACTION r_ucomm AND SKIP FIRST SCREEN .
*        WHEN OTHERS.
*          MESSAGE s035(0k).   EXIT.
*      ENDCASE.
*      perform p9000_duelist_refresh USING  rs_selfield.
    WHEN 'ZTIT002'. " 변경
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

          SET PARAMETER ID 'ZTIIVONO' FIELD it_list-ivono.
          SET PARAMETER ID 'ZTIIBLNO' FIELD space.
          SET PARAMETER ID 'ZTIBLNUM' FIELD space.
          SET PARAMETER ID 'ZTIOPNNO' FIELD space.
          SET PARAMETER ID 'ZTIREQNO' FIELD space.
          SET PARAMETER ID 'BES'      FIELD space.

          CALL TRANSACTION 'ZTIT302' AND SKIP FIRST SCREEN.

        WHEN OTHERS.
          MESSAGE s035(0k).   EXIT.
      ENDCASE.
      PERFORM p9000_duelist_refresh USING  rs_selfield.

    WHEN 'ZTIT004'. " 삭제
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
          SET PARAMETER ID 'ZTIIVONO' FIELD it_list-ivono.
          SET PARAMETER ID 'ZTIIBLNO' FIELD space.
          SET PARAMETER ID 'ZTIBLNUM' FIELD space.
          SET PARAMETER ID 'ZTIOPNNO' FIELD space.
          SET PARAMETER ID 'ZTIREQNO' FIELD space.
          SET PARAMETER ID 'BES'      FIELD space.

          CALL TRANSACTION 'ZTIT304' AND SKIP FIRST SCREEN.

        WHEN OTHERS.
          MESSAGE s035(0k).   EXIT.
      ENDCASE.
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
        WHEN 'REQNO' OR 'REQIT'.
          PERFORM  display_import_document(ztir0000)
                                          USING ls_header-reqno
                                                space
                                                ls_header-reqit.

        WHEN 'IBLNO' OR 'IBLIT'.
          PERFORM  display_bl_document(ztir0000)
                                          USING ls_header-iblno
                                                ls_header-iblit.
        WHEN OTHERS.
          PERFORM display_civ_document(ztir0000)
                                          USING ls_header-ivono.
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
