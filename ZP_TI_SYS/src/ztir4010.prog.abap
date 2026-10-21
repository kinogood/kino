************************************************************************
* Title         :  ZTIR4010                                            *
*                                                                      *
* Description   : [Report] 수입 통관 현황 List                         *
*                                                                      *
* Creation Date : 2004/02/22                                           *
*                                                                      *
* Author        : Seog Bong, Kang                                      *
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
* 18-04-2014   Sang Taek Kang   기능개선 17198 통관리스트에 수입자재   *
*                                              종류 추가               *
*                                                                      *
*                                                                      *                                                             *
************************************************************************
REPORT  ztir4020       MESSAGE-ID zmti00
                       NO STANDARD PAGE HEADING.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE zts_reuse_alvforms_t00.  "> AVL 공용 Data 선언.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF ty_header,
            iccno       LIKE ztitcck-iccno,  "통관관리번호
            iccsq       LIKE ztitcck-iccsq,  "정정차수.
            iblHo       LIKE ztitcck-iblno,  "B/L 관리번호
            lifnr       LIKE ztitcck-lifnr,  "구매처,채권자
            bukrs       LIKE ztitcck-bukrs,  "회사코드
            ekorg       LIKE ztitcck-ekorg,  "구매조직
            ekgrp       LIKE ztitcck-ekgrp,  "구매그룹
            cdhdt       LIKE ztitcck-cdhdt,  "신고희망일자
            cdadt       LIKE ztitcck-cdadt,  "수입신고의뢰일자
            cdcdt       LIKE ztitcck-cdcdt,  "(RES)신고일
            cdrdt       LIKE ztitcck-cdrdt,  "(RES)신고수리일
            cdrno       LIKE ztitcck-cdrno,  "(RES)신고의뢰번호
            cdcno       LIKE ztitcck-cdcno,  "(RES)신고(수리)번호
            cdcor       LIKE ztitcck-cdcor,  "신고세관
            cdcch       LIKE ztitcck-cdcch,  "신고과
            cimty       LIKE ztitcck-cimty,  "수입자구분
            cdapn       LIKE ztitcck-cdapn,  "신고의뢰자 상호
            cimnm       LIKE ztitcck-cimnm,  "수입자상호
            ccono       LIKE ztitcck-ccono,  "무역업등록번호
            cdupn       LIKE ztitcck-cdupn,  "납세의무자상호
            cdunm       LIKE ztitcck-cdunm,  "납세의무자성명
            cduad1      LIKE ztitcck-cduad1, "납세의무자 주소
            cduad2      LIKE ztitcck-cduad2, "납세의무자 주소
            cplsg       LIKE ztitcck-cplsg,  "소재지부호
            ccoid       LIKE ztitcck-ccoid,  "사업자 등록번호
            ccuid       LIKE ztitcck-ccuid,  "통관고유번호
            ccbnm       LIKE ztitcck-ccbnm,  "무역대리점상호
            ccbid       LIKE ztitcck-ccbid,  "무역대리점부호
            casnm       LIKE ztitcck-casnm,  "해외공급자상호
            casld       LIKE ztitcck-casld,  "해외공급자국가코드
            casid       LIKE ztitcck-casid,  "해외공급자부호
            crety       LIKE ztitcck-crety,  "신고구분
            ccupl       LIKE ztitcck-ccupl,  "통관계획
            csaty       LIKE ztitcck-csaty,  "거래구분
            cipty       LIKE ztitcck-cipty,  "수입종류
            cpyme       LIKE ztitcck-cpyme,  "결제방법
            carty       LIKE ztitcck-carty,  "징수형태
            cildt       LIKE ztitcck-cildt,  "반입일자
            cblno       LIKE ztitcck-cblno,  "B/L(AWB)번호
            ccano       LIKE ztitcck-ccano,  "화물관리번호
            cbldy       LIKE ztitcck-cbldy,  "B/L분할신고여부
            cmbln       LIKE ztitcck-cmbln,  "Master B/L No
            cispc       LIKE ztitcck-cispc,  "검사(반입)장소 코드
            cispl       LIKE ztitcck-cispl,  "검사(반입)장소
            ctrme       LIKE ztitcck-ctrme,  "운송수단
            ctrbo       LIKE ztitcck-ctrbo,  "운송용기
            cofld       LIKE ztitcck-cofld,  "적출국
            ctogi       LIKE ztitcck-ctogi,  "운수기관부호
            cspto       LIKE ztitcck-cspto,  "특송업체
            caldt       LIKE ztitcck-caldt,  "입항일자
            ciarp       LIKE ztitcck-ciarp,  "국내도착항
            cvsln       LIKE ztitcck-cvsln,  "선(기)명
            cvsld       LIKE ztitcck-cvsld,  "선(기)국적
            cinco       LIKE ztitcck-cinco,  "인도조건
            cpyatc      LIKE ztitcck-cpyatc, "결제금액 통화
            cpyat       LIKE ztitcck-cpyat,  "결제금액
            ccuakc      LIKE ztitcck-ccuakc, "과세가격합계(KRW)통화
            ccuak       LIKE ztitcck-ccuak,  "과세가격합계(KRW)
            ccuauc      LIKE ztitcck-ccuauc, "과세가격합계(USD)통화
            ccuau       LIKE ztitcck-ccuau,  "과세가격합계(USD)
            cfrat       LIKE ztitcck-cfrat,  "운임
            cipat       LIKE ztitcck-cipat,  "보험료
            cplat       LIKE ztitcck-cplat,  "가산금액
            cfeat       LIKE ztitcck-cfeat,  "공제금액
            cpyrt       LIKE ztitcck-cpyrt,  "결제환률
            ctoweu      LIKE ztitcck-ctoweu, "총중량단위
            ctowe       LIKE ztitcck-ctowe,  "총중량
            ctpkg       LIKE ztitcck-ctpkg,  "총포장갯수
            ctpkgu      LIKE ztitcck-ctpkgu, "총포장갯수단위
            ctseq       LIKE ztitcck-ctseq,  "총란수
            ctsak       LIKE ztitcck-ctsak,  "부가세과세과표
            ctsat       LIKE ztitcck-ctsat,  "부가세면세과표
            cdutx       LIKE ztitcck-cdutx,  "관세
            csptx       LIKE ztitcck-csptx,  "특소세
            caltx       LIKE ztitcck-caltx,  "주세
            ctrtx       LIKE ztitcck-ctrtx,  "교통세
            cintx       LIKE ztitcck-cintx,  "교육세
            cagtx       LIKE ztitcck-cagtx,  "농특세
            cadtx       LIKE ztitcck-cadtx,  "부가세
            clttx       LIKE ztitcck-clttx,  "신고지연가산세
            ctotl       LIKE ztitcck-ctotl,  "합계
            creag1      LIKE ztitcck-creag1, "(RES)관세사 기재란
            creag2      LIKE ztitcck-creag2, "(RES)관세사 기재란
            creag3      LIKE ztitcck-creag3, "(RES)관세사 기재란
            creag4      LIKE ztitcck-creag4, "(RES)관세사 기재란
            creag5      LIKE ztitcck-creag5, "(RES)관세사 기재란
            state       LIKE ztitcck-state,  "관세사
            lponr       LIKE ztitcck-lponr,  "최종품목번호
            impty       LIKE ztitcck-impty,  "수입자재 종류
            ddtext      LIKE dd07v-ddtext.   "수입자재 종류명
TYPES: END OF ty_header.

TYPES: BEGIN OF ty_item.
INCLUDE     TYPE        ty_header.
TYPES :     iccit       LIKE ztitccp-iccit,  "수입신고 Item
            ebeln       LIKE ztitccp-ebeln,  "구매전표번호
            ebelp       LIKE ztitccp-ebelp,  "구매문서 품목번호
            rsnum       LIKE ztitccp-rsnum,  "예약/종속 소요량
            rspos       LIKE ztitccp-rspos,  "예약 / 종속 품목
            rsart       LIKE ztitccp-rsart,  "레코드유형
            reqno       LIKE ztitccp-reqno,  "수입의뢰 관리
            reqit       LIKE ztitccp-reqit,  "수입의뢰 품목
            iblno       LIKE ztitccp-iblno,  "B/L 관리번호
            iblit       LIKE ztitccp-iblit,  "B/L 품목번호
            ndfty       LIKE ztitccp-ndfty,  "무환품 종류
            ccmng       LIKE ztitccp-ccmng,  "통관 수량
            refwr       LIKE ztitccp-refwr,  "송장값 (외화)
            meins       LIKE ztitccp-meins,  "기본단위
            stawn       LIKE ztitccp-stawn,  "해외무역 상품코드
            cnam        LIKE ztitccp-cnam,   "작성인
            cdat        LIKE ztitccp-cdat,   "생성일
            ctme        LIKE ztitccp-ctme,   "생성시간
            unam        LIKE ztitccp-unam,   "최종변경인
            udat        LIKE ztitccp-udat,   "변경일
            utme        LIKE ztitccp-utme,   "최종변경시간
            flag        LIKE ztisccit-flag,   "일반표시
            menge       LIKE ztisccit-menge,  "수량
            ccmngs      LIKE ztisccit-ccmngs, "수입신고 누적수량
            ccmngl      LIKE ztisccit-ccmngl, "수입신고 가능수량
            werks       LIKE ztisccit-werks,  "플랜트
            name1       LIKE ztisccit-name1,  "플랜트
            lgort       LIKE ztisccit-lgort,  "저장위치
            lgobe       LIKE ztisccit-lgobe,  "저장위치
            matnr       LIKE ztisccit-matnr,  "자재번호
            txz01       LIKE ztisccit-txz01,  "내역
            netwr       LIKE ztisccit-netwr,  "문서통화의 정가
            eeind       LIKE ztisccit-eeind,  "납품일
            umson       LIKE ztisccit-umson,  "무상품목
            loekz       LIKE ztisccit-loekz,  "구매문서 삭제지시
            elikz       LIKE ztisccit-elikz,  "납품완료" 지시자
            bprme       LIKE ztisccit-bprme,  "오더가격단위 (구매)
            bpumz       LIKE ztisccit-bpumz,  "오더단위로 환산분자
            bpumn       LIKE ztisccit-bpumn,  "오더단위로 환산분모
            umrez       LIKE ztisccit-umrez,  "기본단위로 전환분자
            umren       LIKE ztisccit-umren,  "기본단위로 전환분모
            netpr       LIKE ztisccit-netpr,  "구매문서단가(문서통화)
            peinh       LIKE ztisccit-peinh,  "가격단위
            uebto       LIKE ztisccit-uebto,  "초과납품 허용치
            uebtk       LIKE ztisccit-uebtk,  "허용 무제한초과납품
            untto       LIKE ztisccit-untto,  "미달납품 허용치
            bupla       LIKE ztisccit-bupla,  "사업장
            blmng       LIKE ztisccit-blmng,  "B/L 수량
            grmng       LIKE ztisccit-grmng,  "입고 수량
            grmngs      LIKE ztisccit-grmngs, "외자입고 누적수량
            grmngl      LIKE ztisccit-grmngl. "외자입고 가능수량
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
        ztitcck,
        ztitccp.

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
  s_bukrs  FOR ztitcck-bukrs                    "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk
                    MODIF  ID iog ,
  s_ekorg  FOR ztitcck-ekorg  MODIF  ID iog,   "구매조직
  s_ekgrp  FOR ztitcck-ekgrp  MODIF  ID iog,   "구매그룹
  s_ebeln  FOR ztitccp-ebeln  MODIF  ID iog,   "구매전표번호
  s_state  FOR ztitcck-state  MODIF  ID iog,   "관세사
  s_iccno  FOR ztitcck-iccno  MODIF  ID iog,   "통관관리번호
  s_rsnum  FOR ztitccp-rsnum  MODIF  ID iog,   "예약/종속소요량
  s_reqno  FOR ztitccp-reqno  MODIF  ID iog,   "수입의뢰 관리번호
  s_iblno  FOR ztitccp-iblno  MODIF  ID iog,   "B/L 관리번호
  s_lifnr  FOR ztitcck-lifnr  MODIF  ID iog,   "구매처채권자계정
  s_cdcno  FOR ztitcck-cdcno  MODIF  ID iog,   "(RES)신고(수리)번호
  s_cdrdt  FOR ztitcck-cdrdt  MODIF  ID iog,   "(RES)신고수리일
  s_cdcdt  FOR ztitcck-cdcdt  MODIF  ID iog,   "(RES)신고일
  s_cblno  FOR ztitcck-cblno  MODIF  ID iog,   "B/L(AWB)번호
  s_ccano  FOR ztitcck-ccano  MODIF  ID iog.   "화물관리번호

SELECTION-SCREEN ULINE.
SELECT-OPTIONS:
  s_cdhdt  FOR ztitcck-cdhdt  MODIF  ID iog,   "신고희망일자(CCYYMMDD)
  s_cdadt  FOR ztitcck-cdadt  MODIF  ID iog,   "수입신고 의뢰
  s_cdrno  FOR ztitcck-cdrno  MODIF  ID iog,   "(RES)신고의뢰번호
  s_cdcor  FOR ztitcck-cdcor  MODIF  ID iog,   "신고세관
  s_cdcch  FOR ztitcck-cdcch  MODIF  ID iog,   "신고과
  s_cimty  FOR ztitcck-cimty  MODIF  ID iog,   "수입자구분
  s_cdapn  FOR ztitcck-cdapn  MODIF  ID iog,   "신고의뢰자 상호
  s_cimnm  FOR ztitcck-cimnm  MODIF  ID iog,   "수입자상호
  s_ccono  FOR ztitcck-ccono  MODIF  ID iog,   "무역업등록번호
  s_cdupn  FOR ztitcck-cdupn  MODIF  ID iog,   "납세의무자상호
  s_cdunm  FOR ztitcck-cdunm  MODIF  ID iog,   "납세의무자성명
  s_cduad1 FOR ztitcck-cduad1 MODIF  ID iog,   "납세의무자 주소
  s_cduad2 FOR ztitcck-cduad2 MODIF  ID iog,   "납세의무자 주소
  s_cplsg  FOR ztitcck-cplsg  MODIF  ID iog,   "소재지부호
  s_ccoid  FOR ztitcck-ccoid  MODIF  ID iog,   "사업자 등록번호
  s_ccuid  FOR ztitcck-ccuid  MODIF  ID iog,   "통관고유번호
  s_ccbnm  FOR ztitcck-ccbnm  MODIF  ID iog,   "무역대리점상호
  s_ccbid  FOR ztitcck-ccbid  MODIF  ID iog,   "무역대리점부호
  s_casnm  FOR ztitcck-casnm  MODIF  ID iog,   "해외공급자상호
  s_casld  FOR ztitcck-casld  MODIF  ID iog,   "해외공급자국가코드
  s_casid  FOR ztitcck-casid  MODIF  ID iog,   "해외공급자부호
  s_crety  FOR ztitcck-crety  MODIF  ID iog,   "신고구분
  s_ccupl  FOR ztitcck-ccupl  MODIF  ID iog,   "통관계획
  s_csaty  FOR ztitcck-csaty  MODIF  ID iog,   "거래구분
  s_cipty  FOR ztitcck-cipty  MODIF  ID iog,   "수입종류
  s_cpyme  FOR ztitcck-cpyme  MODIF  ID iog,   "결제방법
  s_carty  FOR ztitcck-carty  MODIF  ID iog,   "징수형태
  s_cildt  FOR ztitcck-cildt  MODIF  ID iog,   "반입일자
  s_cbldy  FOR ztitcck-cbldy  MODIF  ID iog,   "B/L분할신고여부
  s_cmbln  FOR ztitcck-cmbln  MODIF  ID iog,   "Master B/L No
  s_cispc  FOR ztitcck-cispc  MODIF  ID iog,   "검사(반입)장소 코드
  s_cispl  FOR ztitcck-cispl  MODIF  ID iog,   "검사(반입)장소
  s_ctrme  FOR ztitcck-ctrme  MODIF  ID iog,   "운송수단
  s_ctrbo  FOR ztitcck-ctrbo  MODIF  ID iog,   "운송용기
  s_cofld  FOR ztitcck-cofld  MODIF  ID iog,   "적출국
  s_ctogi  FOR ztitcck-ctogi  MODIF  ID iog,   "운수기관부호
  s_cspto  FOR ztitcck-cspto  MODIF  ID iog,   "특송업체
  s_caldt  FOR ztitcck-caldt  MODIF  ID iog,   "입항일자
  s_ciarp  FOR ztitcck-ciarp  MODIF  ID iog,   "국내도착항
  s_cvsln  FOR ztitcck-cvsln  MODIF  ID iog,   "선(기)명
  s_cvsld  FOR ztitcck-cvsld  MODIF  ID iog,   "선(기)국적
  s_cinco  FOR ztitcck-cinco  MODIF  ID iog,   "인도조건
  s_cpyatc FOR ztitcck-cpyatc MODIF  ID iog,   "결제금액 통화
  s_iccit  FOR ztitccp-iccit  MODIF  ID iog,   "수입신고 Items
  s_ebelp  FOR ztitccp-ebelp  MODIF  ID iog,   "구매문서 품목번호
  s_rspos  FOR ztitccp-rspos  MODIF  ID iog,   "예약/종속요청품목
  s_rsart  FOR ztitccp-rsart  MODIF  ID iog,   "레코드유형
  s_reqit  FOR ztitccp-reqit  MODIF  ID iog,   "수입의뢰 품목번호
  s_iblit  FOR ztitccp-iblit  MODIF  ID iog,   "B/L 품목번호
  s_ndfty  FOR ztitccp-ndfty  MODIF  ID iog,   "무환품 종류
  s_stawn  FOR ztitccp-stawn  MODIF  ID iog,   "해외무역 상품코드
  s_cnam   FOR ztitccp-cnam   MODIF  ID iog,   "작성인
  s_cdat   FOR ztitccp-cdat   MODIF  ID iog,   "생성일
  s_ctme   FOR ztitccp-ctme   MODIF  ID iog,   "생성시간
  s_unam   FOR ztitccp-unam   MODIF  ID iog,   "최종변경인
  s_udat   FOR ztitccp-udat   MODIF  ID iog,   "변경일
  s_utme   FOR ztitccp-utme   MODIF  ID iog.   "최종변경시간
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
*>> 금액이 Summary 되면서 OverFlow되는 현상을 해결함.
*  PERFORM p2100_header_and_list_build.
  PERFORM p2101_header_and_list_build.

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

  DATA: l_rqmng  TYPE ztirqmng.

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
    FROM ztivcc00
   WHERE bukrs   IN s_bukrs "회사코드.
     AND iccno   IN s_iccno "통관관리번호
     AND state   IN s_state "관세사
     AND lifnr   IN s_lifnr "구매처,채권자계정
     AND ekorg   IN s_ekorg "구매조직
     AND ekgrp   IN s_ekgrp "구매그룹
     AND cdhdt   IN s_cdhdt "신고희망일자
     AND cdadt   IN s_cdadt "수입신고 의뢰일자
     AND cdcdt   IN s_cdcdt "(RES)신고일
     AND cdrdt   IN s_cdrdt "(RES)신고수리일
     AND cdrno   IN s_cdrno "(RES)신고의뢰번호
     AND cdcno   IN s_cdcno "(RES)신고(수리)번호
     AND cdcor   IN s_cdcor "신고세관
     AND cdcch   IN s_cdcch "신고과
     AND cimty   IN s_cimty "수입자구분
     AND cdapn   IN s_cdapn "신고의뢰자 상호
     AND cimnm   IN s_cimnm "수입자상호
     AND ccono   IN s_ccono "무역업등록번호
     AND cdupn   IN s_cdupn "납세의무자상호
     AND cdunm   IN s_cdunm "납세의무자성명
     AND cduad1  IN s_cduad1 "납세의무자 주소
     AND cduad2  IN s_cduad2 "납세의무자 주소
     AND cplsg   IN s_cplsg  "소재지부호
     AND ccoid   IN s_ccoid "사업자 등록번호
     AND ccuid   IN s_ccuid "통관고유번호
     AND ccbnm   IN s_ccbnm "무역대리점상호
     AND ccbid   IN s_ccbid "무역대리점부호
     AND casnm   IN s_casnm "해외공급자상호
     AND casld   IN s_casld "해외공급자국가코드
     AND casid   IN s_casid "해외공급자부호
     AND crety   IN s_crety "신고구분
     AND ccupl   IN s_ccupl "통관계획
     AND csaty   IN s_csaty "거래구분
     AND cipty   IN s_cipty "수입종류
     AND cpyme   IN s_cpyme "결제방법
     AND carty   IN s_carty "징수형태
     AND cildt   IN s_cildt "반입일자
     AND cblno   IN s_cblno "B/L(AWB)번호
     AND ccano   IN s_ccano "화물관리번호
     AND cbldy   IN s_cbldy "B/L분할신고여부
     AND cmbln   IN s_cmbln "Master B/L No
     AND cispc   IN s_cispc "검사(반입)장소 코드
     AND cispl   IN s_cispl "검사(반입)장소
     AND ctrme   IN s_ctrme "운송수단
     AND ctrbo   IN s_ctrbo "운송용기
     AND cofld   IN s_cofld "적출국
     AND ctogi   IN s_ctogi "운수기관부호
     AND cspto   IN s_cspto "특송업체
     AND caldt   IN s_caldt "입항일자
     AND ciarp   IN s_ciarp "국내도착항
     AND cvsln   IN s_cvsln "선(기)명
     AND cvsld   IN s_cvsld "선(기)국적
     AND cinco   IN s_cinco "인도조건
     AND cpyatc  IN s_cpyatc "결제금액 통화
     AND iccit   IN s_iccit "수입신고Item.
     AND ebeln   IN s_ebeln "구매전표번호
     AND ebelp   IN s_ebelp "구매문서 품목
     AND rsnum   IN s_rsnum "예약종속소요량
     AND rspos   IN s_rspos "예약종속요청번호
     AND rsart   IN s_rsart "레코드유형
     AND reqno   IN s_reqno "수입의뢰관리
     AND reqit   IN s_reqit "수입의뢰품목
     AND iblno   IN s_iblno "B/L 관리번호
     AND iblit   IN s_iblit "B/L 품목번호
     AND ndfty   IN s_ndfty "무환품 종류
     AND stawn   IN s_stawn "수입코드번호
     AND cnam    IN s_cnam  "작성인
     AND cdat    IN s_cdat  "생성일
     AND ctme    IN s_ctme  "생성시간
     AND unam    IN s_unam  "최종변경인
     AND udat    IN s_udat  "변경일
     AND utme    IN s_utme. "최종변경시간

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

*   p/o정보.
    SELECT  SINGLE werks matnr txz01
      INTO  (it_tab-werks, it_tab-matnr, it_tab-txz01)
      FROM  ztivpo00
     WHERE  ebeln  = it_tab-ebeln
       AND  ebelp  = it_tab-ebelp.

*140417_KST 수정 (기능개선 17198)
*수입자재 종류 명 가지고 오기(수출용원자재/내수용원자재...)
    SELECT SINGLE ddtext
      INTO it_tab-ddtext
      FROM dd07v
     WHERE DOMNAME = 'ZTIIMPTY'
       AND DOMVALUE_L = it_tab-impty.

*   수입의뢰 정보 수량.
*    SELECT  SINGLE rqmng
*      INTO  it_tab-menge
*      FROM  ZTIvrq00
*     WHERE  reqno  = it_tab-reqno
*       AND  reqit  = it_tab-reqit.

*   b/l 정보 수량.
    SELECT  SINGLE blmng
      INTO  it_tab-menge
      FROM  ztivbl00
     WHERE  iblno  = it_tab-iblno
       AND  iblit  = it_tab-iblit.

    MOVE it_tab-iblno TO it_tab-iblho.

    ADD 1 TO g_count.

    MODIFY it_tab INDEX g_tabix.

  ENDLOOP.

ENDFORM.                    " p2000_data_selections
*&---------------------------------------------------------------------*
*&      Form  3000_field_category_build
*&---------------------------------------------------------------------*
FORM 3000_field_category_build .

  FIELD-SYMBOLS : <L_WA>,
                  <L_FIELDS>.
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
*  gs_fieldcat-tabname   = 'IT_HEADER'.
*  gs_fieldcat-fieldname = 'BOX'.
*  APPEND  gs_fieldcat TO it_fieldcat.
*
* Build the fieldcat according to DDIC structure SBOOK:
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
*      i_structure_name   = 'ZTITCCK'
      i_structure_name   = 'ZTISCCK'

      i_internal_tabname = 'IT_HEADER'
    CHANGING
      ct_fieldcat        = it_fieldcat[].

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name   = 'ZTISCCIT'
      i_internal_tabname = 'IT_LIST'
    CHANGING
      ct_fieldcat        = it_fieldcat[].

  LOOP AT it_fieldcat INTO gs_fieldcat.

************************************************************
*> For TraSys ECC Upgrade By ASEG Co., Ltd.
************************************************************
*> 2009/02/16
*> Internal Table상 미존재 필드 삭제 로직 추가
*> Started of Insert
************************************************************
    G_TABIX = SY-TABIX.

    ASSIGN (gs_fieldcat-tabname) TO <L_WA>.

    ASSIGN COMPONENT gs_fieldcat-fieldname OF STRUCTURE
                     <L_WA>  TO <L_FIELDS>.
*    ASSIGN COMPONENT gs_fieldcat-fieldname OF STRUCTURE
*                     gs_fieldcat-tabname   TO <L_FIELDS>.

    IF SY-SUBRC NE 0.
      DELETE IT_FIELDCAT INDEX G_TABIX.
      CONTINUE.
    ENDIF.
************************************************************
*> Ended of Insert
************************************************************


    IF ( gs_fieldcat-fieldname = 'ICCNO'AND
         gs_fieldcat-tabname   = 'IT_HEADER' )
      OR gs_fieldcat-fieldname = 'ICCSQ'
      OR gs_fieldcat-fieldname = 'CDRDT'
      OR gs_fieldcat-fieldname = 'CIVDT'
      OR gs_fieldcat-fieldname = 'CDUPN'
      OR gs_fieldcat-fieldname = 'CDUNM'
      OR gs_fieldcat-fieldname = 'CINCO'
      OR gs_fieldcat-fieldname = 'CVSLN'
      OR gs_fieldcat-fieldname = 'ICCIT'
      OR gs_fieldcat-fieldname = 'EBELN'
      OR gs_fieldcat-fieldname = 'EBELP'
      OR gs_fieldcat-fieldname = 'RSNUM'
      OR gs_fieldcat-fieldname = 'RSPOS'
      OR gs_fieldcat-fieldname = 'REQNO'
      OR gs_fieldcat-fieldname = 'MATNR'
      OR gs_fieldcat-fieldname = 'STATE'
      OR gs_fieldcat-fieldname = 'IMPTY'
      OR gs_fieldcat-fieldname = 'DDTEXT'
      OR ( gs_fieldcat-fieldname = 'IBLNO' AND
         gs_fieldcat-tabname   = 'IT_LIST' ).

      CASE gs_fieldcat-fieldname.
        WHEN 'ICCNO'.
          gs_fieldcat-key     = 'X'.
          gs_fieldcat-hotspot = 'X'.
*        WHEN 'ICCSQ'.
*          gs_fieldcat-key     = 'X'.
*          gs_fieldcat-hotspot = 'X'.
        WHEN 'ICCIT'.
          gs_fieldcat-key     = 'X'.
          gs_fieldcat-just    = 'L'.
          gs_fieldcat-lzero   = 'X'.
          gs_fieldcat-hotspot = 'X'.
        WHEN 'EBELN'.
          gs_fieldcat-hotspot = 'X'.
        WHEN 'IBLNO'.
          gs_fieldcat-hotspot = 'X'.
        WHEN 'STATE'.
          gs_fieldcat-col_pos = 15.
        WHEN 'RSNUM'.
          gs_fieldcat-hotspot = 'X'.
*           WHEN 'MATNR'.
*              gs_fieldcat-HOTSPOT = 'X'.

      ENDCASE.
      CLEAR gs_fieldcat-no_out.
    ELSE.
      gs_fieldcat-no_out = 'X'.
    ENDIF.
    gs_fieldcat-col_pos = ' '.
    MODIFY it_fieldcat FROM gs_fieldcat INDEX sy-tabix.

  ENDLOOP.

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

  gs_keyinfo-header01 = 'ICCNO'.
  gs_keyinfo-item01   = 'ICCNO'.

*  gs_keyinfo-header02 = 'ICCSQ'.
*  gs_keyinfo-item01   = 'ICCNO'.
*  gs_keyinfo-header02 =  space.
*  gs_keyinfo-item02   = 'ICCIT'.

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
  gs_listheader-info = '수입통관 현황 List'(t13).
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
  ls_sort-fieldname = 'ICCNO'.
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

*  MOVE: 'BOX'        TO gs_layout-box_fieldname,
*        'IT_HEADER'  TO gs_layout-box_tabname.
*
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

  DATA: ls_list TYPE ty_tab.

  CLEAR: ls_list.

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
        WHEN 'EBELN'.
          PERFORM  display_purchase_order(ztir0000)
                                          USING ls_list-ebeln
                                                ls_list-ebelp.
        WHEN 'REQNO' OR 'REQIT'.
          PERFORM  display_import_document(ztir0000)
                                          USING ls_list-reqno
                                                space
                                                ls_list-reqit.
        WHEN 'LIFNR'.
          PERFORM display_vendor_master(ztir0000)
                                          USING ls_list-lifnr
                                                ls_list-ekorg.
        WHEN 'IBLNO'.
          PERFORM  display_bl_document(ztir0000)
                                          USING ls_list-iblno
                                                '00000'.
        WHEN 'RSNUM'.
          PERFORM  display_reservation(ztir0000)
                                          USING ls_list-rsnum
                                                ls_list-rspos.


        WHEN OTHERS.
          PERFORM  display_cc_document(ztir0000)
                                          USING ls_list-iccno
                                                ls_list-iccsq.

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
*&      Form  p2101_header_and_list_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM p2101_header_and_list_build .

  DATA: ls_header TYPE ty_header.

  LOOP AT it_tab.
    MOVE-CORRESPONDING it_tab TO : it_header, it_list.
    READ TABLE it_header INTO ls_header
                         WITH KEY iccno = it_tab-iccno
                                  iccsq = it_tab-iccsq.
    IF sy-subrc NE 0.
      APPEND : it_header.
    ENDIF.
    APPEND    it_list.
  ENDLOOP.

ENDFORM.                    " p2101_header_and_list_build


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
