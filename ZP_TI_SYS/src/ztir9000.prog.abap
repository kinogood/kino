************************************************************************
* Title         :  ZTIR9000                                            *
*                                                                      *
* Description   : 수입제비용을 관리 하는 통합 프로그램                 *
*                                                                      *
* Creation Date : 2004/02/19                                           *
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
* Date       Programmer  Transport#  Description                       *
*----------------------------------------------------------------------*
* 2013.03.27   FIB05     C20130115_53137 FINBIL연계건에 대한 처리      *
* 2018.04.04   신재호    [기능개선 230853]기납증 전표 텍스트 추가      *
* 2022.03.31   송승규    [CHM2110-00555] 세금계산서 매핑,
*                          사업영역별 분할송장 처리                    *
* 2022.07.07   송승규    [CHM2207-00033] 세금계산서 매핑시 외화,
*                          영세율 관련 금액 미일치 오류 수정
* 2022.07.15   송승규    [CHM2207-00114] 제비용처리시 상단 트랜잭션
*                 리스트 박스 '1 송장'으로 비활성화처리 (엠트론 한정)
* 2022.09.29   송승규    [CHM2209-00266] 중복구매오더 송장제비용처리
************************************************************************
REPORT  ztir9000       MESSAGE-ID zmti00
                       NO STANDARD PAGE HEADING.

************************************************************************
* SAP Include Define                                                   *
************************************************************************
INCLUDE ztircommtop.  ">수입 공용 Top Include
INCLUDE ztir9000top.  ">LIV Simulation Funciton용 Top Include
INCLUDE ztir9000t01.  ">수입 제비용 관리 Top Include

************************************************************************
* ALV Class Include Define                                             *
************************************************************************
INCLUDE zts_reuse_alvforms_t02.

************************************************************************
* Local Class Define                                                   *
************************************************************************
INCLUDE ztsrcommcd1.  ">Class Define(lcl_header_basic_model_view)
INCLUDE ztsrcommcd2.  ">Class Define(lcl_Application Class)
INCLUDE ztir9000cd1.  ">Others Class Define(lcl_document_view and Etc.)

************************************************************************
* Local Class Implementation                                           *
************************************************************************
INCLUDE ztsrcommci1.  ">Classe Implementation
INCLUDE ztsrcommci2.  ">Classe Implementation
INCLUDE ztsrcommci3.  ">Classe Implementation
INCLUDE ztir9000ci1.  ">수입의뢰 document Classes Implementation

*> Local Class Define
DATA: g_tree            TYPE mmpur_screen_view,
      g_application     TYPE REF TO lcl_application,
      g_document_view   TYPE REF TO lcl_document_view,
      g_item_view       TYPE REF TO lcl_item_view,
      g_shopping_basket TYPE REF TO lcl_shopping_basket.

PARAMETERS: p_vari LIKE disvariant-variant NO-DISPLAY.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ztircommo00.   ">공용 PBO Module Include
INCLUDE ztir9000o00.   ">LIV Simulation Funciton용 PBO
INCLUDE ztir9000o01.   ">수입의뢰 document 관리 PBO Include
INCLUDE ztircommi00.   ">공용 PAI Module Include
INCLUDE ztir9000i00.   ">수입의뢰 document 관리 PAI Include
INCLUDE ztir9000i01.   ">수입의뢰 document 관리 PAI Include
INCLUDE zts_reuse_bdc_subroutine_f00.  ">BDC 공용 Subroutines
INCLUDE ztircommf00.   ">공용 Sub-routine Include
INCLUDE ztir9000f00.   ">수입의뢰 document 관리 Sub Routine Include
INCLUDE ztir9000f01.   ">수입의뢰 document 관리 Sub Routine Include
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    type c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* INITIALIZATION Event                                                 *
************************************************************************
INITIALIZATION.

************************************************************************
* AT SELECTION-SCREEN Events                                           *
************************************************************************
AT SELECTION-SCREEN.

************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.

************************************************************************
* END-OF-SELECTION Event                                               *
************************************************************************
END-OF-SELECTION.

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
