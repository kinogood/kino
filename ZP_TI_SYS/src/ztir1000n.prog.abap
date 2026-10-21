************************************************************************
* Title         :  ZTIR1000                                            *
*                                                                      *
* Description   : 적하부보(I/P) 관리하는 통합 프로그램                 *
*                                                                      *
* Creation Date : 2003/08/20                                           *
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
* Date.      Author.  CSR #            Description.
*----------------------------------------------------------------------*
* 2019.07.05 노승남   기능개선 283274  'ZTIR1000' Copy & Modify
* 2022.04.18 ZLSGDV1  SRM2203-09738    보험사 변경으로 인한 수정
************************************************************************

REPORT  ztir1000       MESSAGE-ID zmti00
                       NO STANDARD PAGE HEADING.

************************************************************************
* SAP Include Define                                                   *
************************************************************************
INCLUDE ztircommtop.  ">수입 공용 Top Include
INCLUDE ztir1000nt01. ">수입 L/C 관리 Top Include - New

************************************************************************
* Local Class Define                                                   *
************************************************************************
INCLUDE ztsrcommcd1.  ">Class Define(lcl_header_basic_model_view)
INCLUDE ztsrcommcd2.  ">Class Define(lcl_Application Class)
INCLUDE ztir1000cd1.  ">Others Class Define(lcl_document_view and Etc.)

************************************************************************
* Local Class Implementation                                           *
************************************************************************
INCLUDE ztsrcommci1.  ">Classe Implementation
INCLUDE ztsrcommci2.  ">Classe Implementation
INCLUDE ztsrcommci3.  ">Classe Implementation
INCLUDE ztir1000ci1.  ">수입의뢰 document Classes Implementation

*> Local Class Define
DATA: g_tree            TYPE mmpur_screen_view,
      g_application     TYPE REF TO lcl_application,
      g_document_view   TYPE REF TO lcl_document_view,
      g_item_view       TYPE REF TO lcl_item_view,
      g_shopping_basket TYPE REF TO lcl_shopping_basket.

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK box1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
    s_bukrs FOR  ztitblk-bukrs  DEFAULT '1000',
    s_ekorg FOR  ztitblk-ekorg  MODIF ID iog,     "구매조직.
    s_ekgrp FOR  ztitblk-ekgrp  MODIF ID iog,     "구매그룹.
    s_ebeln FOR  ztitblp-ebeln  MODIF ID iog,     "구매전표번호.
    s_iblno FOR  ztitblk-iblno  MODIF ID iog      "B/L 관리번호.
                                MEMORY ID ztiiblno,
    s_blnum FOR  ztitblk-blnum  MODIF ID iog,     "B/L 번호.
    s_bldty FOR  ztitblk-bldty  MODIF ID iog,     "문서종류.
    s_rptty FOR  ztitblk-rptty  MODIF ID iog,     "수입신고구분.
    s_matkl FOR  ztivpo00-matkl MODIF ID iog
                                MEMORY ID mkl,    "자재그룹.
    s_lifnr FOR  ztitblk-lifnr  MODIF ID iog,     "공급업체.
    s_bletd FOR  ztitblk-bletd  MODIF ID iog,     "ETD.
    s_bleta FOR  ztitblk-bleta  MODIF ID iog,     "ETA.
    s_fwdty FOR  ztitblk-fwdty  MODIF ID iog,     "운송 방법.
    s_lponr FOR  ztitblk-lponr  MODIF ID iog,     "최종품목번호.
    s_waers FOR  ztitblk-waers  MODIF ID iog,     "통화키.
    s_lgayn FOR  ztitblk-lgayn  MODIF ID iog,     "LG대상여부.
    s_iblit FOR  ztitblp-iblit  MODIF ID iog,     "B/L 품목번호.
    s_ebelp FOR  ztitblp-ebelp  MODIF ID iog,     "구매문서.
    s_reqno FOR  ztitblp-reqno  MODIF ID iog,     "수입의뢰 관리번호.
    s_reqit FOR  ztitblp-reqit  MODIF ID iog,     "수입의뢰 품목번호.
    s_cnam  FOR  ztitblp-cnam   MODIF ID iog,     "작성인.
    s_cdat  FOR  ztitblp-cdat   MODIF ID iog,     "생성일.
    s_ctme  FOR  ztitblp-ctme   MODIF ID iog,     "생성시간.
    s_unam  FOR  ztitblp-unam   MODIF ID iog,     "최종변경인.
    s_udat  FOR  ztitblp-udat   MODIF ID iog,     "변경일.
    s_utme  FOR  ztitblp-utme   MODIF ID iog.     "최종변경시간.

SELECTION-SCREEN ULINE.

PARAMETERS: p_full RADIOBUTTON GROUP ab2 DEFAULT 'X',
            p_list RADIOBUTTON GROUP ab2.
SELECTION-SCREEN END OF BLOCK box1.

*> Report variant
SELECTION-SCREEN: BEGIN OF BLOCK alv WITH FRAME TITLE text-003.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN: END OF BLOCK alv.

************************************************************************
* User Include Define                                                  *
************************************************************************
*INCLUDE ztircommo00.   ">공용 PBO Module Include
*INCLUDE ztir1000o01.   ">수입의뢰 document 관리 PBO Include
*INCLUDE ztircommi00.   ">공용 PAI Module Include
*INCLUDE ztir1000i01.   ">수입의뢰 document 관리 PAI Include
INCLUDE zts_reuse_bdc_subroutine_f00.  ">BDC 공용 Subroutines
INCLUDE ztircommf00.   ">공용 Sub-routine Include
INCLUDE ztir1000nf01.  ">수입의뢰 document 관리 Sub Routine - New
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

AT SELECTION-SCREEN OUTPUT.

************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.
  PERFORM clearing_work_area.      ">Initialize internal table
  PERFORM set_fieldcat_build.      ">Set ALV field category
  PERFORM create_dynamic_table.    ">
  PERFORM get_data_for_display.    ">data select


************************************************************************
* END-OF-SELECTION Event                                               *
************************************************************************
END-OF-SELECTION.
  CHECK g_line NE 0.
*>--------------------------------------------------------
*> PROGRESS INDICATOR DISPLAY.
*>  4.  LIST DISPLAY
*>--------------------------------------------------------
  g_linen = 100.
  g_out_text = text-905.
  REPLACE '%99999%' WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.
  PERFORM set_colorize_build.       ">Set color
  PERFORM set_sort_field.           ">Set ALV sort fields
  PERFORM display_alv_list.         ">Call ALV Functions


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
