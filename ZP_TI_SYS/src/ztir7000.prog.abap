************************************************************************
* Title         :  ZTIR7000                                            *
*                                                                      *
* Description   : 세금계산서/조회/삭제/invoice verification 관리       *
*                하는 통합 프로그램                                    *
*                                                                      *
* Creation Date : 2004/02/12                                           *
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
* 2014-03-27   ZLSGMM(hjkim)    R3TK9A0F7X  CSR 2014031800051 기능개선 *
* 2016-10-12   신재호         [기능개선 161906] 거래은행 입력 로직 삭제*
*                                                                      *
************************************************************************
REPORT  ztir7000       MESSAGE-ID zmti00
                       NO STANDARD PAGE HEADING.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ztircommtop.  ">수입 공용 Top Include
INCLUDE ztir9000top.  ">LIV Simulation Funciton용 Top Include
INCLUDE ztir7000t01.  ">수입 세금계산서 I/V 관리 Top Include

************************************************************************
* ALV Class Include Define                                             *
************************************************************************
INCLUDE zts_reuse_alvforms_t02.

************************************************************************
* Local Class Define                                                   *
************************************************************************
INCLUDE ztsrcommcd1.  ">Class Define(lcl_header_basic_model_view)
INCLUDE ztsrcommcd2.  ">Class Define(lcl_Application Class)
INCLUDE ztir7000cd1.  ">Others Class Define(lcl_document_view and Etc.)


************************************************************************
* Local Class Implementation                                           *
************************************************************************
INCLUDE ztsrcommci1.  ">Classe Implementation
INCLUDE ztsrcommci2.  ">Classe Implementation
INCLUDE ztsrcommci3.  ">Classe Implementation
INCLUDE ztir7000ci1.  ">계산서 document Classes Implementation

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
  s_bukrs  FOR ztivpo00-bukrs                   "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk
                    MODIF  ID iog ,
  s_budat  FOR ekbe-budat     OBLIGATORY,
  s_waers  FOR ztivpo00-waers MODIF ID iog      "통화키.
                              OBLIGATORY,
  s_ekorg  FOR ztivpo00-ekorg MODIF ID iog,     "구매조직.
  s_ekgrp  FOR ztivpo00-ekgrp MODIF ID iog,     "구매그룹.
  s_ebeln  FOR ztivpo00-ebeln MODIF ID iog,     "구매전표번호.
  s_ebelp  FOR ztivpo00-ebelp MODIF ID iog,     "구매문서.
  s_bsart  FOR ztivpo00-bsart,
  s_lifnr  FOR ztivpo00-lifnr MODIF ID iog,     "공급업체.
  s_zterm  FOR ztivpo00-zterm MODIF ID iog,
  s_reqty  FOR ztitrqk-reqty  MODIF ID iog,   "개설종류.
  s_opnno  FOR ztitrqs-opnno  MODIF ID iog,   "수입개설번호.
  s_opndt  FOR ztitrqs-opndt  MODIF ID iog,   "개설일자.
  s_matnr  FOR ztivpo00-matnr MODIF ID iog,
  s_txz01  FOR ztivpo00-txz01 MODIF ID iog,
  s_werks  FOR ztivpo00-werks MODIF ID iog
               MEMORY ID  wrk,
  s_matkl  FOR ztivpo00-matkl MODIF ID iog
                              MEMORY ID mkl,    "자재그룹.
  s_reqno  FOR ztitrqs-reqno  MODIF ID iog,     "수입의뢰 관리번호.
  s_cnam   FOR ztitrqs-cnam   MODIF ID iog,     "작성인.
  s_cdat   FOR ztitrqs-cdat   MODIF ID iog,     "생성일.
  s_ctme   FOR ztitrqs-ctme   MODIF ID iog,     "생성시간.
  s_unam   FOR ztitrqs-unam   MODIF ID iog,     "최종변경인.
  s_udat   FOR ztitrqs-udat   MODIF ID iog,     "변경일.
  s_utme   FOR ztitrqs-utme   MODIF ID iog.     "최종변경시간.
SELECTION-SCREEN END OF BLOCK dbsel.

SELECTION-SCREEN BEGIN OF BLOCK lists WITH FRAME TITLE text-002.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK lists.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ztircommo00.   ">공용 PBO Module Include
INCLUDE ztir9000o00.   ">LIV Simulation Funciton용 PBO Include
INCLUDE ztir7000o01.   ">계산서 관리 PBO Include

INCLUDE ztircommi00.   ">공용 PAI Module Include
INCLUDE ztir9000i00.   ">LIV Simulation Funciton용 PAI Include
INCLUDE ztir7000i01.   ">계산서 관리 PAI Include

INCLUDE zts_reuse_bdc_subroutine_f00.  ">BDC 공용 Subroutines
INCLUDE ztircommf00.   ">공용 Sub-routine Include
INCLUDE ztir9000f00.   ">LIV Simulation Funciton용 Sub-routine Include
INCLUDE ztir7000f01.   ">계산서 관리 Sub Routine Include
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

*----------------------------------------------------------------------
*> 지급조건 HELP
*----------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_zterm-low.
  PERFORM get_f4_for_zterm USING s_zterm-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_zterm-high.
  PERFORM get_f4_for_zterm USING s_zterm-high.


************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.
*> 검색조건에 해당하는 데이타를 Select.
  PERFORM p2000_data_selections.
**> Header table과 List(Items) table를 만듬.
*  PERFORM p2100_header_and_list_build.
*
************************************************************************
* END-OF-SELECTION Event                                               *
************************************************************************
END-OF-SELECTION.

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
  ELSE.
    MESSAGE s902.
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
