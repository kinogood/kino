************************************************************************
* Title         :  ZTIR7400                                            *
*                                                                      *
* Description   : 수입 기납증/분증을 관리하는 통합 프로그램            *
*                                                                      *
* Creation Date : 2004/02/21                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
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
*                                                                      *
*                                                                      *
************************************************************************
REPORT  ztir7400       MESSAGE-ID zmti00
                       NO STANDARD PAGE HEADING.

************************************************************************
* SAP Include Define                                                   *
************************************************************************
INCLUDE ztircommtop.  ">수입 공용 Top Include
INCLUDE ztir7400t01.  ">수입 기납증/분증 관리 Top Include

************************************************************************
* Local Class Define                                                   *
************************************************************************
INCLUDE ztsrcommcd1.  ">Class Define(lcl_header_basic_model_view)
INCLUDE ztsrcommcd2.  ">Class Define(lcl_Application Class)
INCLUDE ztir7400cd1.  ">Others Class Define(lcl_document_view and Etc.)

************************************************************************
* Local Class Implementation                                           *
************************************************************************
INCLUDE ztsrcommci1.  ">Classe Implementation
INCLUDE ztsrcommci2.  ">Classe Implementation
INCLUDE ztsrcommci3.  ">Classe Implementation
INCLUDE ztir7400ci1.  ">수입기납증/분증 document Classes Implementation

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
  s_bukrs  FOR ztitrqk-bukrs                 "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk
                    MODIF  ID iog ,
  s_ekgrp  FOR ztitrqk-ekgrp MODIF ID iog,   "구매그룹.
  s_ekorg  FOR ztitrqk-ekorg MODIF ID iog,   "구매조직.
  s_ebeln  FOR ztitrqp-ebeln MODIF ID iog	   "구매전표번호.
                              MEMORY ID bes,
  s_reqno  FOR ztitrqk-reqno MODIF ID iog	   "수입의뢰 관리번호.
                              MEMORY ID ztireqno,
  s_matkl  FOR ztivpo00-matkl MODIF ID iog
                              MEMORY ID mkl,   "자재그룹.
  s_lifnr  FOR ztitrqk-lifnr MODIF ID iog,   "공급업체 계정번호.
*  s_exdat  FOR ztitrqs-exdat MODIF ID iog,   "COM:유효기일.
*  s_lsdat  FOR ztitrqs-lsdat MODIF ID iog,   "COM:최종선적일자.
  s_lifre  FOR ztitrqk-lifre MODIF ID iog,   "다른 송장발행처.
  s_offer  FOR ztitrqk-offer MODIF ID iog,   "오퍼상(Offer).
*  s_reqty  FOR ztitrqk-reqty MODIF ID iog,   "수입의뢰 종류.
*  s_ilcty  FOR ztitrqk-ilcty MODIF ID iog,   "신용장 종류.
  s_cnam   FOR ztitrqp-cnam  MODIF ID iog,   "작성인.
  s_cdat   FOR ztitrqp-cdat  MODIF ID iog,   "생성일.
  s_unam   FOR ztitrqp-unam  MODIF ID iog,   "최종변경인.
  s_udat   FOR ztitrqp-udat  MODIF ID iog.   "변경일.
SELECTION-SCREEN ULINE.
SELECT-OPTIONS:
  s_reqit  FOR ztitrqp-reqit MODIF ID iog,   "수입의뢰 품목번호.
  s_ebelp  FOR ztitrqp-ebelp MODIF ID iog,   "구매문서 품목번호.
  s_opnbk  FOR ztitrqk-opnbk MODIF ID iog,   "개설은행.
  s_appct  FOR ztitrqk-appct MODIF ID iog,   "수입자 구분.
  s_opnno  FOR ztitrqs-opnno MODIF ID iog,   "수입개설번호
  s_opndt  FOR ztitrqs-opndt MODIF ID iog,   "개설일자.
  s_zterm  FOR ztitrqs-zterm MODIF ID iog,   "지급조건키.
*  s_mblnr  FOR ztitrqp-mblnr MODIF ID iog,   "자재문서번호.
*  s_mjahr  FOR ztitrqp-mjahr MODIF ID iog,   "자재문서연도.
*  s_zeile  FOR ztitrqp-zeile MODIF ID iog,   "자재문서품목.
  s_waers  FOR ztitrqs-waers MODIF ID iog,   "개설통화.
  s_inco1  FOR ztitrqs-inco1 MODIF ID iog,   "인도조건 (파트 1).
  s_inco2  FOR ztitrqs-inco2 MODIF ID iog,   "인도조건 (파트 2).
  s_ediyn  FOR ztitrqs-ediyn MODIF ID iog,   "EDI 적용여부.
*  s_insyn  FOR ztitrqs-insyn MODIF ID iog,   "적하보험대상여부.
*  s_fwdty  FOR ztitrqs-fwdty MODIF ID iog,   "운송 방법.
*  s_fland  FOR ztitrqs-fland MODIF ID iog,   "선적국가.
*  s_fport  FOR ztitrqs-fport MODIF ID iog,   "선적항.
*  s_pllod  FOR ztitrqs-pllod MODIF ID iog,   "COM:선적항.
*  s_tland  FOR ztitrqs-tland MODIF ID iog,   "도착국가.
*  s_tport  FOR ztitrqs-tport MODIF ID iog,   "도착항.
*  s_pltrn  FOR ztitrqs-pltrn MODIF ID iog,   "COM:도착항.
  s_reqdt  FOR ztitrqs-reqdt MODIF ID iog,   "개설희망일자.
  s_appun  FOR ztitrqs-appun MODIF ID iog,   "개설의뢰 요청자.
  s_appdt  FOR ztitrqs-appdt MODIF ID iog,   "개설의뢰 요청일.
  s_apptm  FOR ztitrqs-apptm MODIF ID iog,   "개설의뢰 요청시간.
  s_accun  FOR ztitrqs-accun MODIF ID iog,   "요청접수 담당자.
  s_accdt  FOR ztitrqs-accdt MODIF ID iog,   "요청접수일자.
  s_acctm  FOR ztitrqs-acctm MODIF ID iog,   "요청접수시간.
  s_sndun  FOR ztitrqs-sndun MODIF ID iog,   "개설신청자.
  s_snddt  FOR ztitrqs-snddt MODIF ID iog,   "개설신청일.
  s_sndtm  FOR ztitrqs-sndtm MODIF ID iog,   "개설신청시간.
  s_rcvun  FOR ztitrqs-rcvun MODIF ID iog,   "개설등록자.
  s_rcvdt  FOR ztitrqs-rcvdt MODIF ID iog,   "개설등록일자.
  s_rcvtm  FOR ztitrqs-rcvtm MODIF ID iog,   "개설등록시간.
  s_recid  FOR ztitrqs-recid MODIF ID iog,   "수신자 ID.
  s_recnm  FOR ztitrqs-recnm MODIF ID iog,   "수신자 명.
  s_recno  FOR ztitrqs-recno MODIF ID iog,   "문서번호.
  s_docst  FOR ztitrqs-docst MODIF ID iog,   "문서상태.
*  s_rqmng  FOR ztitrqp-rqmng MODIF ID iog,   "수입의뢰수량.
*  s_meins  FOR ztitrqp-meins MODIF ID iog,   "기본단위.
  s_ctme   FOR ztitrqp-ctme  MODIF ID iog,   "생성시간.
  s_utme   FOR ztitrqp-utme  MODIF ID iog.   "최종변경시간.
SELECTION-SCREEN END OF BLOCK dbsel.

SELECTION-SCREEN BEGIN OF BLOCK lists WITH FRAME TITLE text-002.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK lists.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ztircommo00.   ">공용 PBO Module Include
INCLUDE ztir7400o01.   ">수입 기납증/분증 document 관리 PBO Include
INCLUDE ztircommi00.   ">공용 PAI Module Include
INCLUDE ztir7400i01.   ">수입 기납증/분증 document 관리 PAI Include
INCLUDE zts_reuse_bdc_subroutine_f00.  ">BDC 공용 Subroutines
INCLUDE ztircommf00.   ">공용 Sub-routine Include
INCLUDE ztir7400f01.   ">수입 기납증/분증 document Sub Routine Include
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
*> 사용자 레이아웃 Input values Check
  PERFORM p1101_check_variant_value.
*> 사용자 Input values Check
  PERFORM p1101_check_input_value.
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
  PERFORM p2101_header_and_list_build.

************************************************************************
* END-OF-SELECTION Event                                               *
************************************************************************
END-OF-SELECTION.
  DESCRIBE TABLE it_tabh LINES g_line.
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
*> Program 종료.
    PERFORM  p9000_program_exit.
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
