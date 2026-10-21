************************************************************************
* Title         :  ZTIR0000                                            *
*                                                                      *
* Description   : 수입의뢰/접수/개설/조회/삭제/송신 및 수신 관리하는   *
*                 통합 프로그램                                        *
*                                                                      *
* Creation Date : 2003/07/11                                           *
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
* 2007/08/13   조성임           [제목] 수입개설의뢰 시 EDI 주요부가조건*
*                                      text변경                        *
*                               [CSR_ID] 1113943                       *
*----------------------------------------------------------------------*
* 2008/09/03   FIB05            [제목] 수입개설EDI 문서 Misspell변경   *
*                                      text변경                        *
*                               [CSR_NO] C20080812_12895               *
*----------------------------------------------------------------------*
* 2008/10/31   FIB05            [제목] 수입개설요청변경   생성         *
*                               [CSR_NO] C20080910_27638               *
*----------------------------------------------------------------------*
* 2008/11/24   FIB05            [제목] TT지급계좌설정관련요청          *
*                               [CSR_NO] C20081120_61009               *
*----------------------------------------------------------------------*
* 2009/07/08   FIB05            [제목] 수출 TT 송금계좌정보SYSTEM수정  *
*                               [CSR_NO] C20090619_76375               *
*----------------------------------------------------------------------*
* 2009/08/17   FIB05            [제목] LC 개설시 -DESCRIPTION처리수정  *
*                               [CSR_NO] C20090813_06824               *
*----------------------------------------------------------------------*
* 2010/11/05   FIB05            [제목] LC개설응답서 출력물 포멧수정    *
*                               [CSR_NO] C20101027_62334               *
*----------------------------------------------------------------------*
* 20101223     MMB03            [CSR_NO] C20101203_84253               *
*                               [제목] 오류문구 수정처리               *
*----------------------------------------------------------------------*
* 2011/04/23   FIB05            [제목] TT개설요청접수시_EDI내역check   *
*                               [CSR_NO] C20110323_48869               *
*----------------------------------------------------------------------*
* 2011/10/27   FIB05            [제목] local LC개설시 필수항목 추가    *
*                               [CSR_NO] C20110916_63637               *
*----------------------------------------------------------------------*
* 2012/03/30   MMB04            [제목] 지급지시서 EDI변경              *
*                                      (래형태, 수입예정일 항목추가)   *
*                               [CSR_NO] C20120327_77021               *
*----------------------------------------------------------------------*
* 2014/02/20   FIB03            [제목] 지급조건 BU36인 경우 EDI문서상  *
*                               텍스트 항목 하드코딩                   *
*                               [CSR_NO] 11083                         *
*----------------------------------------------------------------------*
* 2014/03/31   FIB03            CSR : 14889                            *
* - 로컬LC(Amend포함) 개설요청시 EDI부분의 수혜자번호 필드 로직 변경   *
*   사업자번호+식별자+상세식별자로 입력되도록 함                       *
* - 구매승인서(Amend포함)의 경우 개설요청 메입화면에 동보전송 체크하면 *
*   로컬LC와 동일하고, 언체크하면 사업자번호만 입력되도록 함           *
*----------------------------------------------------------------------*
* 2015/04/29  김홍직   기능개선 75594  구매승인서(PU) EDI 품목내역 개선*
* 2015/09/17  ZLSGED   기능개선 96084  내국신용장 전자문서 변경        *
* 2017/02/27  신재호   기능개선 184344 TT 개설 시 계좌주명 필드 추가   *
* 2017/03/13  신재호   기능개선 186110 TT 경유은행 SWIFT 코드 추가     *
* 2017/03/17  신재호   기능개선 186601 은행정보 변경 시 체크로직 추가  *
* 2017/05/12  신재호   기능개선 193765 LC Usance Text 변경             *
* 2017/06/28  신재호   기능개선 198545 개설의뢰인 상호명 Block         *
* 2017/10/12  신재호   LSEVK 분사 관련 프로그램 수정                   *
* 2017/11/24  신재호   기능개선 213478 구매승인서 특수문자 체크 추가   *
* 2018/01/31  신재호   자체개선 222199 구매승인서 특수문자 체크 추가2  *
* 2018/02/23  신재호   기능개선 224957 사후송금(TT) 용도코드 로직 변경 *
* 2024/06/25  이원형    CHM2403-00155   HS CODE 체크로직 추가
************************************************************************
REPORT  ztir0000       MESSAGE-ID zmti00
                       NO STANDARD PAGE HEADING.

************************************************************************
* SAP Include Define                                                   *
************************************************************************
INCLUDE ztircommtop.  ">수입 공용 Top Include
INCLUDE ztir0000t01.  ">수입 L/C 관리 Top Include

************************************************************************
* Local Class Define                                                   *
************************************************************************
INCLUDE ztsrcommcd1.  ">Class Define(lcl_header_basic_model_view)
INCLUDE ztsrcommcd2.  ">Class Define(lcl_Application Class)
INCLUDE ztir0000cd1.  ">Others Class Define(lcl_document_view and Etc.)

************************************************************************
* Local Class Implementation                                           *
************************************************************************
INCLUDE ztsrcommci1.  ">Classe Implementation
INCLUDE ztsrcommci2.  ">Classe Implementation
INCLUDE ztsrcommci3.  ">Classe Implementation
INCLUDE ztir0000ci1.  ">수입의뢰 document Classes Implementation

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
  s_bukrs  FOR ztivpo00-bukrs
               NO-EXTENSION NO INTERVALS OBLIGATORY
               MEMORY ID  buk
               MODIF  ID iog ,

  s_ekorg  FOR ztivpo00-ekorg MODIF ID iog
               MEMORY ID  eko,
*>>> LG전선에서 사용.by MSH
*               NO-DISPLAY,
  s_ekgrp  FOR ztivpo00-ekgrp MODIF ID iog
               MEMORY ID  ekg,
*               NO-EXTENSION NO INTERVALS,
*                               OBLIGATORY,
  s_ebeln  FOR ztivpo00-ebeln MODIF ID iog
               MEMORY ID  bes,
  s_zterm  FOR ztivpo00-zterm MODIF ID iog,
  s_inco1  FOR ztivpo00-inco1 MODIF ID iog,
  s_matkl  FOR ztivpo00-matkl MODIF ID iog
               MEMORY ID  mkl,
*                 NO-EXTENSION NO INTERVALS OBLIGATORY,
  s_eindt  FOR eket-eindt     MODIF ID iog,
*                                         OBLIGATORY,
  s_lsdat  FOR ztitrqs-lsdat  MODIF ID iog,
  s_lifnr  FOR ztivpo00-lifnr MODIF ID iog,
  s_waers  FOR ztivpo00-waers MODIF ID iog,
  s_matnr  FOR ztivpo00-matnr MODIF ID iog,
  s_txz01  FOR ztivpo00-txz01 MODIF ID iog,
  s_werks  FOR ztivpo00-werks MODIF ID iog
               MEMORY ID  wrk,
  s_land1  FOR ztivpo00-land1 MODIF ID iog,
  s_bedat  FOR ztivpo00-bedat MODIF ID iog,
  s_aedat  FOR ztivpo00-aedat MODIF ID iog,
  s_ernam  FOR ztivpo00-ernam MODIF ID iog.
SELECTION-SCREEN END OF BLOCK dbsel.

SELECTION-SCREEN BEGIN OF BLOCK lists WITH FRAME TITLE text-002.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK lists.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ztircommo00.   ">공용 PBO Module Include
INCLUDE ztir0000o01.   ">수입의뢰 document 관리 PBO Include
INCLUDE ztircommi00.   ">공용 PAI Module Include
INCLUDE ztir0000i01.   ">수입의뢰 document 관리 PAI Include
INCLUDE zts_reuse_bdc_subroutine_f00.  ">BDC 공용 Subroutines
INCLUDE ztircommf00.   ">공용 Sub-routine Include
INCLUDE ztir0000f01.   ">수입의뢰 document 관리 Sub Routine Include
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
*> Header table과 List(Items) table를 만듬.
  PERFORM p2100_header_and_list_build.
*  PERFORM  p2000_get_po_open_items.

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
*     MESSAGE s103.
  ENDIF.
*

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
