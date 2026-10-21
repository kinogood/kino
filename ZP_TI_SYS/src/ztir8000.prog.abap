************************************************************************
* Title         :  ZTIR8000                                            *
*                                                                      *
* Description   : Payment Notice를 관리 하는 통합 프로그램             *
*                                                                      *
* Creation Date : 2004/02/18                                           *
*                                                                      *
* Author        : Seog bong, Kang                                      *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*                                                                      *
* Inputs        : None                                                 *
*                                                                      *
* Outputs       : None                                                 *
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
*----------------------------------------------------------------------*
* 2024-03-27   CHM2402-00485    ZLSGTR2     Banker's usance생성 시     *
*                                           차입원금 전기일자 지정     *
*                               요청자 : 전선 자금팀 배진숙, 김은영    *
*----------------------------------------------------------------------*
* 2024-05-20   CHM2404-00673    ZLSGTR2    BP:산업은행 02702 경우,     *
*                                          지급명세 26249 수기 지정    *
*                               요청자 : 전선 자금팀 배진숙            *
************************************************************************
REPORT  ztir8000       MESSAGE-ID zmti00
                       NO STANDARD PAGE HEADING.


************************************************************************
* SAP Include Define                                                   *
************************************************************************
INCLUDE ztircommtop.  ">수입 공용 Top Include
INCLUDE ztir8000t01.  ">수입 L/C 관리 Top Include

************************************************************************
* ALV Class Include Define                                             *
************************************************************************
INCLUDE zts_reuse_alvforms_t02.

************************************************************************
* Local Class Define                                                   *
************************************************************************
INCLUDE ztsrcommcd1.  ">Class Define(lcl_header_basic_model_view)
INCLUDE ztsrcommcd2.  ">Class Define(lcl_Application Class)
INCLUDE ztir8000cd1.  ">Others Class Define(lcl_document_view and Etc.)

************************************************************************
* Local Class Implementation                                           *
************************************************************************
INCLUDE ztsrcommci1.  ">Classe Implementation
INCLUDE ztsrcommci2.  ">Classe Implementation
INCLUDE ztsrcommci3.  ">Classe Implementation
INCLUDE ztir8000ci1.  ">수입의뢰 document Classes Implementation

*> Local Class Define
DATA: g_tree            TYPE mmpur_screen_view,
      g_application     TYPE REF TO lcl_application,
      g_document_view   TYPE REF TO lcl_document_view,
      g_item_view       TYPE REF TO lcl_item_view,
      g_shopping_basket TYPE REF TO lcl_shopping_basket.


************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK dbsel WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ztitivk-bukrs                 "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk
                    MODIF  ID iog,
  s_ekorg  FOR ztitivk-ekorg  MODIF    ID iog,  "4구매조직
  s_ekgrp  FOR ztitivk-ekgrp  MODIF    ID iog,  "3구매그룹
  s_ebeln  FOR ztitivp-ebeln  MODIF    ID iog,  "10구매전표
  s_ivono  FOR ztitivk-ivono  MODIF    ID iog,  "10송장 관리번호
  s_ivnum  FOR ztitivk-ivnum  MODIF    ID iog,  "20송장번호
  s_civdt  FOR ztitivk-civdt  MODIF    ID iog,  "8문서의 송장일
  s_reqno  FOR ztitivp-reqno  MODIF    ID iog,  "10수입의뢰번호
  s_cnam   FOR ztitivp-cnam   MODIF    ID iog,  "12작성인
  s_cdat   FOR ztitivp-cdat   MODIF    ID iog,  "8생성일
  s_unam   FOR ztitivp-unam   MODIF    ID iog,  "12최종변경인
  s_udat   FOR ztitivp-udat   MODIF    ID iog,  "8변경일
  s_OPNNO  FOR ZTIVRQ04-OPNNO MODIF    ID iog.  "L/C번호

SELECTION-SCREEN ULINE.

SELECT-OPTIONS:
  s_vorga  FOR ztitivk-vorgang MODIF  ID iog,  "1트랜잭션/이벤트
  s_blart  FOR ztitivk-blart MODIF  ID iog,    "2전표유형
  s_bupla  FOR ztitivk-bupla MODIF  ID iog,    "4사업장
  s_gsber  FOR ztitivk-gsber MODIF  ID iog,    "4사업영역
  s_budat  FOR ztitivk-budat MODIF  ID iog,    "8전표의 전기일
  s_bldat  FOR ztitivk-bldat MODIF  ID iog,    "8전표에서 송장일
  s_zterm  FOR ztitivk-zterm MODIF  ID iog,    "4지급조건키
  s_zfbdt  FOR ztitivk-zfbdt MODIF  ID iog,    "8만기계산기준일
  s_netdt  FOR ztitivk-netdt MODIF  ID iog,    "8순액지급 만기일
  s_zbd1t  FOR ztitivk-zbd1t MODIF  ID iog,    "3현금할인기간 1
  s_zbd2t  FOR ztitivk-zbd2t MODIF  ID iog,    "3현금 할인기간 2
  s_zbd3t  FOR ztitivk-zbd3t MODIF  ID iog,    "3순액지급조건기간
  s_zbd1p  FOR ztitivk-zbd1p MODIF  ID iog,    "5현금할인율 1
  s_zbd2p  FOR ztitivk-zbd2p MODIF  ID iog,    "5두번째 현금할인율
  s_mwskz  FOR ztitivk-mwskz MODIF  ID iog,    "2부가가치세코드
  s_waers  FOR ztitivk-waers MODIF  ID iog,    "5통화키
  s_wwert  FOR ztitivk-wwert MODIF  ID iog,    "8환산일
  s_lifnr  FOR ztitivk-lifnr MODIF  ID iog,    "10다른 송장발행처
  s_livst  FOR ztitivk-livst MODIF  ID iog,    "1송장처리 상태
  s_prpyn  FOR ztitivk-prpyn MODIF  ID iog,    "1선급금 구분
  s_xblnr  FOR ztitivk-xblnr MODIF  ID iog,    "16참조전표번호
  s_bktxt  FOR ztitivk-bktxt MODIF  ID iog,    "25전표헤더텍스트
  s_zlspr  FOR ztitivk-zlspr MODIF  ID iog,    "1지급보류키
  s_zlsch  FOR ztitivk-zlsch MODIF  ID iog,    "1지급방법
  s_uzawe  FOR ztitivk-uzawe MODIF  ID iog,    "2지급방법보충
  s_belnr  FOR ztitivk-belnr MODIF  ID iog,    "10송장문서의 문서번호
  s_gjahr  FOR ztitivk-gjahr MODIF  ID iog,    "4회계연도
  s_lponr  FOR ztitivk-lponr MODIF  ID iog,    "6최종품목번호
  s_rblgp  FOR ztitivp-rblgp MODIF  ID iog,    "5 품목
  s_ebelp  FOR ztitivp-ebelp MODIF  ID iog,    "5구매문서 품목
  s_reqit  FOR ztitivp-reqit MODIF  ID iog,    "5수입의뢰 품목
  s_iblno  FOR ztitivp-iblno MODIF  ID iog,    "10B/L 관리번호
  s_iblit  FOR ztitivp-iblit MODIF  ID iog,    "5B/L 품목번호
  s_tbtkz  FOR ztitivp-tbtkz MODIF  ID iog,    "1후속 차변/대변
  s_kschl  FOR ztitivp-kschl MODIF  ID iog,    "4조건유형
  s_stunr  FOR ztitivp-stunr MODIF  ID iog,    "3단계번호
  s_zaehk  FOR ztitivp-zaehk MODIF  ID iog,    "2조건카운터
  s_sgtxt  FOR ztitivp-sgtxt MODIF  ID iog,    "50항목텍스트
  s_ctme   FOR ztitivp-ctme  MODIF  ID iog,    "6생성시간
  s_utme   FOR ztitivp-utme  MODIF  ID iog.    "6최종변경시간
SELECTION-SCREEN END OF BLOCK dbsel.

SELECTION-SCREEN BEGIN OF BLOCK lists WITH FRAME TITLE text-002.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK lists.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ztircommo00.   ">공용 PBO Module Include
INCLUDE ztir8000o01.   ">수입의뢰 document 관리 PBO Include
INCLUDE ztircommi00.   ">공용 PAI Module Include
INCLUDE ztir8000i01.   ">수입의뢰 document 관리 PAI Include
INCLUDE zts_reuse_bdc_subroutine_f00.  ">BDC 공용 Subroutines
INCLUDE ztircommf00.   ">공용 Sub-routine Include
INCLUDE ztir8000f01.   ">수입의뢰 document 관리 Sub Routine Include
** JS전선 회사코드 2007/04 KSH --------------------------------------
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* INITIALIZATION Event                                                 *
************************************************************************
INITIALIZATION.
*> Read default layout (description only, w/o field catalog)
  PERFORM  p1000_alv_fields_initial.
*> Initializaton By Program
  PERFORM  p1000_set_initial_data.
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

************************************************************************
* END-OF-SELECTION Event                                               *
************************************************************************
END-OF-SELECTION.
  DESCRIBE TABLE it_tab_h LINES g_line.
  IF NOT g_line IS INITIAL.
*> PROGRESS Display.
    g_linen    = 90.
    g_out_text = '리스트를 구성 중입니다 %99999%%'(p03).
    REPLACE '%99999%'(p99) WITH g_linen INTO g_out_text.
    PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

    PERFORM 3000_field_category_build.
    PERFORM 3100_set_color_infomation.
    PERFORM 3200_key_infomation_build.
    PERFORM 3300_event_exit_tab_hle_build.
    PERFORM 3400_comment_build.
    PERFORM 3500_sort_table_build.
    PERFORM 3600_event_table_build USING : slis_ev_top_of_page,
                                           slis_ev_pf_status_set,
                                           slis_ev_user_command.
    PERFORM 3700_layout_build.
    PERFORM 3910_call_alv_hierseq.
*> Program 종료.
    PERFORM  p9000_program_exit.
  ELSE.
    MESSAGE S902.
  ENDIF.


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
************************************************************************
