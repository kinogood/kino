************************************************************************
* Title         :  ZTIR5000                                            *
*                                                                      *
* Description   : 수입물품 입고를 관리하는 통합 프로그램               *
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
* Date         Programmer  Transport#       Description                *
*----------------------------------------------------------------------*
* 2013.06.26   MMB04(HDY)  C20130625_56259  스탠다드 입고처리 된       *
*                                           내역 유지보수 테이블 관리  *
* 2014.12.23   김홍직      기능개선  57530  SELECTION화면 수정
* 2015.04.20   김홍직      기능개선  75028  플랜트3204 배치분할 기능추가
* 2015.11.27   김홍직      자체개선 104998  전자부품 스캔입고 기능추가
* 2016.03.23   신재호      기능개선 127661  꼬리표 생성 기능추가
************************************************************************
REPORT  ZTIR5000       MESSAGE-ID ZMTI00
                       NO STANDARD PAGE HEADING.

************************************************************************
* SAP Include Define                                                   *
************************************************************************
INCLUDE ZTIRCOMMTOP.  ">수입 공용 Top Include
INCLUDE ZTIR5000T01.  ">수입 L/C 관리 Top Include

************************************************************************
* Local Class Define                                                   *
************************************************************************
INCLUDE ZTSRCOMMCD1.  ">Class Define(lcl_header_basic_model_view)
INCLUDE ZTSRCOMMCD2.  ">Class Define(lcl_Application Class)
INCLUDE ZTIR5000CD1.  ">Others Class Define(lcl_document_view and Etc.)

************************************************************************
* Local Class Implementation                                           *
************************************************************************
INCLUDE ZTSRCOMMCI1.  ">Classe Implementation
INCLUDE ZTSRCOMMCI2.  ">Classe Implementation
INCLUDE ZTSRCOMMCI3.  ">Classe Implementation
INCLUDE ZTIR5000CI1.  ">수입입고 document Classes Implementation

*> Local Class Define
DATA: G_TREE            TYPE MMPUR_SCREEN_VIEW,
      G_APPLICATION     TYPE REF TO LCL_APPLICATION,
      G_DOCUMENT_VIEW   TYPE REF TO LCL_DOCUMENT_VIEW,
      G_ITEM_VIEW       TYPE REF TO LCL_ITEM_VIEW,
      G_SHOPPING_BASKET TYPE REF TO LCL_SHOPPING_BASKET.

*> 공조 GHP 일련번호 max number관리용 data선언
DATA:   GV_MAXNR     TYPE ZCURNR.

DATA:   GF_POST_DIV . "분할입고처리_202012221


**** HDY 20130626 START C20130625_56259 REQ.오민석
**** 스탠다드에서 입고 완료된 통관에 대해서 테이블 유지보수 하여
**** DUE LIST에 뜨지 않도록 TABLE 생성
DATA : GT_ZTITZTIGR LIKE ZTITZTIGR OCCURS 0 WITH HEADER LINE.
**** HDY 20130626 END

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK DBSEL WITH FRAME TITLE TEXT-001.
SELECTION-SCREEN: BEGIN OF LINE . "기능개선 57530(+)
SELECTION-SCREEN COMMENT 1(28) TEXT-900.
SELECT-OPTIONS:
  S_BUKRS  FOR ZTITCCK-BUKRS                 "회사코드.
               NO-EXTENSION NO INTERVALS OBLIGATORY
               MEMORY ID BUK
               MODIF  ID IOG.
SELECTION-SCREEN POSITION 52.
PARAMETERS: P_IVCHK TYPE C AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT 55(15) TEXT-901.
SELECTION-SCREEN:  END OF LINE . "기능개선 57530(+)

SELECT-OPTIONS:
  S_EKORG  FOR ZTITCCK-EKORG  MEMORY ID EKO,   "구매조직.
  S_EKGRP  FOR ZTITCCK-EKGRP  MEMORY ID EKG,   "구매그룹
  S_WERKS  FOR ZTITCCK-WERKS  MEMORY ID WRK,   "플랜트
  S_BLNUM  FOR ZTITBLK-BLNUM  MEMORY ID ZTIBLNUM, "B/L NUMBER
  S_IBLNO  FOR ZTITCCP-IBLNO  MODIF ID IOG,    "10B/L 관리번호.
  S_ICCNO  FOR ZTITCCK-ICCNO  MODIF ID IOG     "통관 관리번호.
                              MEMORY ID ZTIICCNO ,
  S_EBELN  FOR ZTITCCP-EBELN  MODIF ID IOG,    "10구매전표번호.

  "[기능개선 ______]  인바운드 납품문서,
  S_VBELN  FOR EKES-VBELN NO-EXTENSION NO INTERVALS MODIF ID INB
                                                    MEMORY ID INB ,

  S_CDCDT  FOR ZTITCCK-CDCDT  MODIF ID IOG,    "8신고수리일자.
  S_CDCNO  FOR ZTITCCK-CDCNO  MODIF ID IOG,    "8수입신고수리번호.
  S_CDCOR  FOR ZTITCCK-CDCOR  MODIF ID IOG,                 "3신고세관
  S_REQNO  FOR ZTITCCP-REQNO  MODIF ID IOG,    "10수입의뢰 관리번호.
  S_CNAM   FOR ZTITCCP-CNAM   MODIF ID IOG,                 "12작성인.
  S_CDAT   FOR ZTITCCP-CDAT   MODIF ID IOG,                 "8생성일.
  S_UNAM   FOR ZTITCCP-UNAM   MODIF ID IOG,    "12최종변경인.
  S_UDAT   FOR ZTITCCP-UDAT   MODIF ID IOG.                 "8변경일.
SELECTION-SCREEN ULINE.
SELECT-OPTIONS:
  S_CDHDT  FOR ZTITCCK-CDHDT  MODIF ID IOG,    "8신고희망일자.
  S_CDADT  FOR ZTITCCK-CDADT  MODIF ID IOG,    "8수입신고 의뢰일자.
  S_CDCCH  FOR ZTITCCK-CDCCH  MODIF ID IOG,                 "2신고과.
  S_CIMTY  FOR ZTITCCK-CIMTY  MODIF ID IOG,    "1수입자구분.
  S_CDAPN  FOR ZTITCCK-CDAPN  MODIF ID IOG,    "28신고의뢰자 상호.
  S_CIMNM  FOR ZTITCCK-CIMNM  MODIF ID IOG,    "28수입자상호.
  S_CCONO  FOR ZTITCCK-CCONO  MODIF ID IOG,    "8무역업등록번호.
  S_CDUPN  FOR ZTITCCK-CDUPN  MODIF ID IOG,    "28납세의무자상호.
  S_CDUNM  FOR ZTITCCK-CDUNM  MODIF ID IOG,    "12납세의무자성명.
  S_CDUAD1 FOR ZTITCCK-CDUAD1 MODIF ID IOG,    "20납세의무자 주소.
  S_CDUAD2 FOR ZTITCCK-CDUAD2 MODIF ID IOG,    "20납세의무자 주소.
  S_CPLSG  FOR ZTITCCK-CPLSG  MODIF ID IOG,    "3소재지부호.
  S_CCOID  FOR ZTITCCK-CCOID  MODIF ID IOG,    "13사업자 등록번호.
  S_CCUID  FOR ZTITCCK-CCUID  MODIF ID IOG,    "15통관고유번호.
  S_CCBNM  FOR ZTITCCK-CCBNM  MODIF ID IOG,    "28무역대리점상호.
  S_CCBID  FOR ZTITCCK-CCBID  MODIF ID IOG,    "7무역대리점부호.
  S_CASNM  FOR ZTITCCK-CASNM  MODIF ID IOG,    "30해외공급자상호.
  S_CASLD  FOR ZTITCCK-CASLD  MODIF ID IOG,    "3해외공급자국.
  S_CASID  FOR ZTITCCK-CASID  MODIF ID IOG,    "10해외공급자부호.
  S_CRETY  FOR ZTITCCK-CRETY  MODIF ID IOG,                 "1신고구분.
  S_CCUPL  FOR ZTITCCK-CCUPL  MODIF ID IOG,                 "1통관계.
  S_CSATY  FOR ZTITCCK-CSATY  MODIF ID IOG,                 "2거래구.
  S_CIPTY  FOR ZTITCCK-CIPTY  MODIF ID IOG,                 "1수입종.
  S_CPYME  FOR ZTITCCK-CPYME  MODIF ID IOG,                 "2결제방.
  S_CARTY  FOR ZTITCCK-CARTY  MODIF ID IOG,                 "2징수형.
  S_CILDT  FOR ZTITCCK-CILDT  MODIF ID IOG,                 "8반입일.
  S_CBLNO  FOR ZTITCCK-CBLNO  MODIF ID IOG,    "20B/L(AWB)번호.
  S_CCANO  FOR ZTITCCK-CCANO  MODIF ID IOG,    "20화물관리번호.
  S_CBLDY  FOR ZTITCCK-CBLDY  MODIF ID IOG,    "1B/L분할신고여부.
  S_CMBLN  FOR ZTITCCK-CMBLN  MODIF ID IOG,    "20Master B/L No.
  S_CISPC  FOR ZTITCCK-CISPC  MODIF ID IOG,    "8검사(반입)장소 코드.
  S_CISPL  FOR ZTITCCK-CISPL  MODIF ID IOG,    "10검사(반입)장소.
  S_CTRME  FOR ZTITCCK-CTRME  MODIF ID IOG,                 "2운송수.
  S_CTRBO  FOR ZTITCCK-CTRBO  MODIF ID IOG,                 "3운송용.
  S_COFLD  FOR ZTITCCK-COFLD  MODIF ID IOG,                 "3적출국.
  S_CTOGI  FOR ZTITCCK-CTOGI  MODIF ID IOG,    "4운수기관부호.
  S_CSPTO  FOR ZTITCCK-CSPTO  MODIF ID IOG,                 "2특송업.
  S_CALDT  FOR ZTITCCK-CALDT  MODIF ID IOG,                 "8입항일.
  S_CIARP  FOR ZTITCCK-CIARP  MODIF ID IOG,    "3국내도착항.
  S_CVSLN  FOR ZTITCCK-CVSLN  MODIF ID IOG,    "20선(기)명.
  S_CVSLD  FOR ZTITCCK-CVSLD  MODIF ID IOG,    "3선(기)국적.
  S_CINCO  FOR ZTITCCK-CINCO  MODIF ID IOG,                 "3인도조.
  S_CPYATC FOR ZTITCCK-CPYATC MODIF ID IOG,    "5결제금액 통화.
  S_CPYAT  FOR ZTITCCK-CPYAT  MODIF ID IOG,    "11결제금액.
  S_CTOWEU FOR ZTITCCK-CTOWEU MODIF ID IOG,    "3총중량단위.
  S_CTOWE  FOR ZTITCCK-CTOWE  MODIF ID IOG,                 "15총중량.
  S_CTPKG  FOR ZTITCCK-CTPKG  MODIF ID IOG,    "8총포장갯수.
  S_CTPKGU FOR ZTITCCK-CTPKGU MODIF ID IOG,    "3총포장갯수단위.
  S_CTSEQ  FOR ZTITCCK-CTSEQ  MODIF ID IOG,                 "3총란수.
  S_ICCIT  FOR ZTITCCP-ICCIT  MODIF ID IOG,    "5수입신고 Items Number.
  S_EBELP  FOR ZTITCCP-EBELP  MODIF ID IOG,    "5구매문서 품목번호.
  S_REQIT  FOR ZTITCCP-REQIT  MODIF ID IOG,    "5수입의뢰 품목번호.
  S_IBLIT  FOR ZTITCCP-IBLIT  MODIF ID IOG,    "5B/L 품목번호.
  S_NDFTY  FOR ZTITCCP-NDFTY  MODIF ID IOG,    "1무환품 종류.
  S_CCMNG  FOR ZTITCCP-CCMNG  MODIF ID IOG,    "13통관 수량.
  S_REFWR  FOR ZTITCCP-REFWR  MODIF ID IOG,    "13송장값 (외화).
  S_MEINS  FOR ZTITCCP-MEINS  MODIF ID IOG,                 "3기본단.
  S_CTME   FOR ZTITCCP-CTME   MODIF ID IOG,                 "6생성시.
  S_UTME   FOR ZTITCCP-UTME   MODIF ID IOG.    "6최종변경시간.
SELECTION-SCREEN END OF BLOCK DBSEL.

SELECTION-SCREEN BEGIN OF BLOCK LISTS WITH FRAME TITLE TEXT-002.
PARAMETERS: P_VARI LIKE DISVARIANT-VARIANT.
*            p_ivchk TYPE c AS CHECKBOX DEFAULT 'X'. "기능개선 57530
SELECTION-SCREEN END OF BLOCK LISTS.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ZTIRCOMMO00.   ">공용 PBO Module Include
INCLUDE ZTIR5000O01.   ">수입입고 document 관리 PBO Include
INCLUDE ZTIRCOMMI00.   ">공용 PAI Module Include
INCLUDE ZTIR5000I01.   ">수입입고 document 관리 PAI Include
INCLUDE ZTS_REUSE_BDC_SUBROUTINE_F00.  ">BDC 공용 Subroutines
INCLUDE ZTIRCOMMF00.   ">공용 Sub-routine Include
INCLUDE ZTIR5000F01.   ">수입입고 document 관리 Sub Routine Include
** JS전선 회사코드 2007/04 KSH --------------------------------------
INCLUDE ZTS_AUTHORIZATION_CHECK. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* INITIALIZATION Event                                                 *
************************************************************************
INITIALIZATION.
*> Read default layout (description only, w/o field catalog)
  PERFORM  P1000_ALV_FIELDS_INITIAL.
*> Initializaton By Program
  PERFORM  P1000_SET_INITIAL_DATA.
*> Report initialization
  PERFORM  P1001_INITIALIZATION.

AT SELECTION-SCREEN OUTPUT .
  PERFORM SET_SCREEN_FIELD.    "[기능개선 ______] 조건필드사용제한


************************************************************************
* AT SELECTION-SCREEN Events                                           *
************************************************************************
AT SELECTION-SCREEN.
*> 사용자 Input Value Check
  PERFORM P1101_CHECK_INPUT_VALUE.
*> 사용자 레이아웃 Input values Check
  PERFORM P1101_CHECK_VARIANT_VALUE.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM P1102_AUTHORIZATION_CHECK USING S_BUKRS-LOW.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> 레이아웃 HELP
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM P1102_F4_FOR_VARIANT.


************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.
*> 검색조건에 해당하는 데이타를 Select.
  PERFORM P2000_DATA_SELECTIONS.
*> Header table과 List(Items) table를 만듬.
  PERFORM P2100_HEADER_AND_LIST_BUILD.


************************************************************************
* END-OF-SELECTION Event                                               *
************************************************************************
END-OF-SELECTION.
  DESCRIBE TABLE IT_TAB_H LINES G_LINE.
  IF NOT G_LINE IS INITIAL.
*> PROGRESS Display.
    G_LINEN    = 90.
    G_OUT_TEXT = '리스트를 구성 중입니다 %99999%%'(P03).
    REPLACE '%99999%'(P99) WITH G_LINEN INTO G_OUT_TEXT.
    PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

    PERFORM 3000_FIELD_CATEGORY_BUILD.
    PERFORM 3100_SET_COLOR_INFOMATION.
    PERFORM 3200_KEY_INFOMATION_BUILD.
    PERFORM 3300_EVENT_EXIT_TABLE_BUILD.
    PERFORM 3400_COMMENT_BUILD.
    PERFORM 3500_SORT_TABLE_BUILD.
    PERFORM 3600_EVENT_TABLE_BUILD USING : SLIS_EV_TOP_OF_PAGE,
                                           SLIS_EV_PF_STATUS_SET,
                                           SLIS_EV_USER_COMMAND.
    PERFORM 3700_LAYOUT_BUILD.
    PERFORM 3910_CALL_ALV_HIERSEQ.
  ENDIF.

*--> [가온수입] 요청사항 반영
*  PERFORM  P9000_PROGRAM_EXIT. "--> 원본 주석
  IF NOT SY-CALLD IS INITIAL.
    LEAVE.
  ELSE.
    LEAVE TO TRANSACTION SY-TCODE.
  ENDIF.
*<-- [가온수입] 요청사항 반영
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
