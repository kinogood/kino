************************************************************************
* Title         :  ZTIR4000                                            *
*                                                                      *
* Description   : 수입신고필증/접수/조회/삭제/수신 관리하는            *
*                 통합 프로그램                                        *
*                                                                      *
* Creation Date : 2004/02/18                                           *
*                                                                      *
* Author        : Seung Jun, Lee                                       *
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
REPORT  ztir4000       MESSAGE-ID zmti00
                       NO STANDARD PAGE HEADING.

************************************************************************
* SAP Include Define                                                   *
************************************************************************
INCLUDE ztircommtop.  ">수입 공용 Top Include
INCLUDE ztir4000t01.  ">수입 C/C 관리 Top Include
INCLUDE ztir4000t02.   ">Inbound 생성 Top Include

************************************************************************
* Local Class Define                                                   *
************************************************************************
INCLUDE ztsrcommcd1.  ">Class Define(lcl_header_basic_model_view)
INCLUDE ztsrcommcd2.  ">Class Define(lcl_Application Class)
INCLUDE ztir4000cd1.  ">Others Class Define(lcl_document_view and Etc.)

************************************************************************
* Local Class Implementation                                           *
************************************************************************
INCLUDE ztsrcommci1.  ">Classe Implementation
INCLUDE ztsrcommci2.  ">Classe Implementation
INCLUDE ztsrcommci3.  ">Classe Implementation
INCLUDE ztir4000ci1.  ">수입의뢰 document Classes Implementation

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
  s_bukrs  FOR ztitrqk-bukrs                   "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk
                    MODIF  ID iog ,
  s_ekorg  FOR ztitblk-ekorg MODIF ID iog,     "구매조직.
  s_ekgrp  FOR ztitblk-ekgrp MODIF ID iog,     "구매그룹.
  s_ebeln  FOR ztitblp-ebeln MODIF ID iog,     "구매전표번호.
  s_iblno  FOR ztitblk-iblno MODIF ID iog      "B/L 관리번호.
                              MEMORY ID ztiiblno,
  s_blnum  FOR ztitblk-blnum MODIF ID iog,     "B/L 번호.
  s_reqno  FOR ztitblp-reqno MODIF ID iog,	"수입의뢰 관리번호.
  s_bldty  FOR ztitblk-bldty MODIF ID iog,     "문서종류.
  s_rptty  FOR ztitblk-rptty MODIF ID iog,     "수입신고구분.
  s_lifnr  FOR ztitblk-lifnr MODIF ID iog,     "공급업체 계정번호.
  s_bletd  FOR ztitblk-bletd MODIF ID iog,     "ETD(출발 예정 시각).
  s_bleta  FOR ztitblk-bleta MODIF ID iog,     "ETA(도착 예정 시각).
  s_fwdty  FOR ztitblk-fwdty MODIF ID iog,     "운송 방법.
  s_waers  FOR ztitblk-waers MODIF ID iog,     "통화키.
  s_lgayn  FOR ztitblk-lgayn MODIF ID iog,     "LG대상여부.
  s_iblit  FOR ztitblp-iblit MODIF ID iog,     "B/L 품목번호.
  s_ndfty  FOR ztitblp-ndfty MODIF ID iog,     "무환품 종류.
  s_ebelp  FOR ztitblp-ebelp MODIF ID iog,     "구매문서 품목번호.
  s_reqit  FOR ztitblp-reqit MODIF ID iog,     "수입의뢰 품목번호.
  s_cnam   FOR ztitblp-cnam  MODIF ID iog,     "작성인.
  s_cdat   FOR ztitblp-cdat  MODIF ID iog,     "생성일.
  s_ctme   FOR ztitblp-ctme  MODIF ID iog,     "생성시간.
  s_unam   FOR ztitblp-unam  MODIF ID iog,     "최종변경인.
  s_udat   FOR ztitblp-udat  MODIF ID iog,     "변경일.
  s_utme   FOR ztitblp-utme  MODIF ID iog.     "최종변경시간.

SELECTION-SCREEN END OF BLOCK dbsel.

SELECTION-SCREEN BEGIN OF BLOCK lists WITH FRAME TITLE text-002.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK lists.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ztircommo00.   ">공용 PBO Module Include
INCLUDE ztir4000o01.   ">C/C 관리 PBO Module Include
INCLUDE ztircommi00.   ">공용 PAI Module Include
INCLUDE ztir4000i01.   ">C/C 관리 PAI Module Include
INCLUDE zts_reuse_bdc_subroutine_f00.  ">BDC 공용 Subroutines
INCLUDE ztircommf00.   ">공용 Sub-routine Include
INCLUDE ztir4000f01.   ">C/C 관리 Sub-Routine Include
INCLUDE ztir4000f02.   ">Inbound 생성 Sub-Routine Include
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


************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.
*> 검색조건에 해당하는 데이타를 Select.
  PERFORM p2000_data_selections.
*> Header table과 List(Items) table를 만듬.
  PERFORM p2100_header_and_list_build.


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
