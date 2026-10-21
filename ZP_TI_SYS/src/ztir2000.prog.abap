************************************************************************
* Title         :  ZTIR2000                                            *
*                                                                      *
* Description   : [Report] B/L(AWB) 관리하는 통합프로그램              *
*                                                                      *
* Creation Date : 2004/02/01                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
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
*    Date     Programmer  Description                                  *
*----------------------------------------------------------------------*
* 2015.10.16    신재호    [기능개선 99963] 수입운임 자동계산 로직 추가
* 2018.11.05    강희대    [기능개선 253501] BL 리스트 등록
* 2019.06.24    신재호    [기능개선 283274] 수입 운임 관련 추가/변경
* 2019.10.25    신재호    [기능개선 294534] 해상 LCL min.rate 설정
* 2019.11.20    신재호    [기능개선 298023] 1.미통관은 부보/운임 제외
*                                           2.포장유형 세분화
* 2020.02.28    신재호    [기능개선 310412] Min rate 일부조건 제외
* 2020.04.08    송승규    [기능개선 ______] 인바운드납품서 조건추가
* 2020.07.17    박성수    [CHM2007-00376]   원산지증명서여부 메일발송
* 2020.09.04    송승규    [CHM ______] BL업로드기능추가(엠트론한정)
* 2020.09.21    박성수    CHM2009-00411   원산지증명서 메일발송 기준변경
************************************************************************
REPORT  ZTIR2000       MESSAGE-ID ZMTI00
                       NO STANDARD PAGE HEADING.

************************************************************************
* SAP Include Define                                                   *
************************************************************************
INCLUDE ZTIRCOMMTOP.  ">수입 공용 Top Include
INCLUDE ZTIR2000T01.  ">수입 B/L 관리 Top Include

************************************************************************
* Local Class Define                                                   *
************************************************************************
INCLUDE ZTSRCOMMCD1.  ">Class Define(lcl_header_basic_model_view)
INCLUDE ZTSRCOMMCD2.  ">Class Define(lcl_Application Class)
INCLUDE ZTIR2000CD1.  ">Others Class Define(lcl_document_view and Etc.)

************************************************************************
* Local Class Implementation                                           *
************************************************************************
INCLUDE ZTSRCOMMCI1.  ">Classe Implementation
INCLUDE ZTSRCOMMCI2.  ">Classe Implementation
INCLUDE ZTSRCOMMCI3.  ">Classe Implementation
INCLUDE ZTIR2000CI1.  ">수입의뢰 document Classes Implementation


*> Local Class Define
DATA: G_TREE            TYPE MMPUR_SCREEN_VIEW,
      G_APPLICATION     TYPE REF TO LCL_APPLICATION,
      G_DOCUMENT_VIEW   TYPE REF TO LCL_DOCUMENT_VIEW,
      G_ITEM_VIEW       TYPE REF TO LCL_ITEM_VIEW,
      G_SHOPPING_BASKET TYPE REF TO LCL_SHOPPING_BASKET.

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK DBSEL WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS:
  S_BUKRS  FOR ZTITRQK-BUKRS                 "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID BUK
                    MODIF  ID IOG ,
  S_EKORG  FOR ZTITRQK-EKORG MODIF ID IOG,   "구매조직.
  S_EKGRP  FOR ZTITRQK-EKGRP MODIF ID IOG,   "구매그룹.
  S_EBELN  FOR ZTITRQP-EBELN MODIF ID IOG	   "구매전표번호.
                              MEMORY ID BES,
  S_REQNO  FOR ZTITRQK-REQNO MODIF ID IOG	   "수입의뢰 관리번호.
                              MEMORY ID ZTIREQNO,
  S_AMDSQ  FOR ZTITRQS-AMDSQ MODIF ID IOG   "Amend 차수.
                              MEMORY ID ZTIAMDSQ,

  "[기능개선 ______]  인바운드 납품문서,
  S_VBELN  FOR EKES-VBELN NO-EXTENSION NO INTERVALS MODIF ID INB
                                                   MEMORY ID INB,
  S_MATKL  FOR ZTIVPO00-MATKL MODIF ID IOG
                              MEMORY ID MKL,   "자재그룹.
  S_LIFNR  FOR ZTITRQK-LIFNR MODIF ID IOG,   "공급업체 계정번호.
  S_EXDAT  FOR ZTITRQS-EXDAT MODIF ID IOG,   "COM:유효기일.
  S_LSDAT  FOR ZTITRQS-LSDAT MODIF ID IOG,   "COM:최종선적일자.
  S_LIFRE  FOR ZTITRQK-LIFRE MODIF ID IOG,   "다른 송장발행처.
  S_OFFER  FOR ZTITRQK-OFFER MODIF ID IOG,   "오퍼상(Offer).
  S_REQTY  FOR ZTITRQK-REQTY MODIF ID IOG,   "수입의뢰 종류.
  S_ILCTY  FOR ZTITRQK-ILCTY MODIF ID IOG,   "신용장 종류.
  S_CNAM   FOR ZTITRQP-CNAM  MODIF ID IOG,   "작성인.
  S_CDAT   FOR ZTITRQP-CDAT  MODIF ID IOG,   "생성일.
  S_UNAM   FOR ZTITRQP-UNAM  MODIF ID IOG,   "최종변경인.
  S_UDAT   FOR ZTITRQP-UDAT  MODIF ID IOG.   "변경일.
SELECTION-SCREEN ULINE.
SELECT-OPTIONS:
  S_REQIT  FOR ZTITRQP-REQIT MODIF ID IOG,   "수입의뢰 품목번호.
  S_EBELP  FOR ZTITRQP-EBELP MODIF ID IOG,   "구매문서 품목번호.
  S_OPNBK  FOR ZTITRQK-OPNBK MODIF ID IOG,   "개설은행.
  S_APPCT  FOR ZTITRQK-APPCT MODIF ID IOG,   "수입자 구분.
  S_OPNNO  FOR ZTITRQS-OPNNO MODIF ID IOG,   "수입개설번호
  S_OPNDT  FOR ZTITRQS-OPNDT MODIF ID IOG,   "개설일자.
  S_ZTERM  FOR ZTITRQS-ZTERM MODIF ID IOG,   "지급조건키.
*  s_mblnr  FOR ztitrqp-mblnr MODIF ID iog,   "자재문서번호.
*  s_mjahr  FOR ztitrqp-mjahr MODIF ID iog,   "자재문서연도.
*  s_zeile  FOR ztitrqp-zeile MODIF ID iog,   "자재문서품목.
  S_WAERS  FOR ZTITRQS-WAERS MODIF ID IOG,   "개설통화.
  S_INCO1  FOR ZTITRQS-INCO1 MODIF ID IOG,   "인도조건 (파트 1).
  S_INCO2  FOR ZTITRQS-INCO2 MODIF ID IOG,   "인도조건 (파트 2).
  S_EDIYN  FOR ZTITRQS-EDIYN MODIF ID IOG,   "EDI 적용여부.
  S_INSYN  FOR ZTITRQS-INSYN MODIF ID IOG,   "적하보험대상여부.
  S_FWDTY  FOR ZTITRQS-FWDTY MODIF ID IOG,   "운송 방법.
  S_FLAND  FOR ZTITRQS-FLAND MODIF ID IOG,   "선적국가.
  S_FPORT  FOR ZTITRQS-FPORT MODIF ID IOG,   "선적항.
  S_PLLOD  FOR ZTITRQS-PLLOD MODIF ID IOG,   "COM:선적항.
  S_TLAND  FOR ZTITRQS-TLAND MODIF ID IOG,   "도착국가.
  S_TPORT  FOR ZTITRQS-TPORT MODIF ID IOG,   "도착항.
  S_PLTRN  FOR ZTITRQS-PLTRN MODIF ID IOG,   "COM:도착항.
  S_REQDT  FOR ZTITRQS-REQDT MODIF ID IOG,   "개설희망일자.
  S_APPUN  FOR ZTITRQS-APPUN MODIF ID IOG,   "개설의뢰 요청자.
  S_APPDT  FOR ZTITRQS-APPDT MODIF ID IOG,   "개설의뢰 요청일.
  S_APPTM  FOR ZTITRQS-APPTM MODIF ID IOG,   "개설의뢰 요청시간.
  S_ACCUN  FOR ZTITRQS-ACCUN MODIF ID IOG,   "요청접수 담당자.
  S_ACCDT  FOR ZTITRQS-ACCDT MODIF ID IOG,   "요청접수일자.
  S_ACCTM  FOR ZTITRQS-ACCTM MODIF ID IOG,   "요청접수시간.
  S_SNDUN  FOR ZTITRQS-SNDUN MODIF ID IOG,   "개설신청자.
  S_SNDDT  FOR ZTITRQS-SNDDT MODIF ID IOG,   "개설신청일.
  S_SNDTM  FOR ZTITRQS-SNDTM MODIF ID IOG,   "개설신청시간.
  S_RCVUN  FOR ZTITRQS-RCVUN MODIF ID IOG,   "개설등록자.
  S_RCVDT  FOR ZTITRQS-RCVDT MODIF ID IOG,   "개설등록일자.
  S_RCVTM  FOR ZTITRQS-RCVTM MODIF ID IOG,   "개설등록시간.
  S_RECID  FOR ZTITRQS-RECID MODIF ID IOG,   "수신자 ID.
  S_RECNM  FOR ZTITRQS-RECNM MODIF ID IOG,   "수신자 명.
  S_RECNO  FOR ZTITRQS-RECNO MODIF ID IOG,   "문서번호.
  S_DOCST  FOR ZTITRQS-DOCST MODIF ID IOG,   "문서상태.
*  s_rqmng  FOR ztitrqp-rqmng MODIF ID iog,   "수입의뢰수량.
*  s_meins  FOR ztitrqp-meins MODIF ID iog,   "기본단위.
  S_CTME   FOR ZTITRQP-CTME  MODIF ID IOG,   "생성시간.
  S_UTME   FOR ZTITRQP-UTME  MODIF ID IOG.   "최종변경시간.
SELECTION-SCREEN END OF BLOCK DBSEL.

SELECTION-SCREEN BEGIN OF BLOCK LISTS WITH FRAME TITLE TEXT-003.
PARAMETERS: P_VARI LIKE DISVARIANT-VARIANT.
*            p_item TYPE c AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK LISTS.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ZTIRCOMMO00.   ">공용 PBO Module Include

INCLUDE ZTIR2000M01.  ">엠트론 관련 Include

INCLUDE ZTIR2000O01.   ">수입의뢰 document 관리 PBO Include
INCLUDE ZTIRCOMMI00.   ">공용 PAI Module Include
INCLUDE ZTIR2000I01.   ">수입의뢰 document 관리 PAI Include
INCLUDE ZTS_REUSE_BDC_SUBROUTINE_F00.  ">BDC 공용 Subroutines
INCLUDE ZTIRCOMMF00.   ">공용 Sub-routine Include
INCLUDE ZTIR2000F01.   ">수입의뢰 document 관리 Sub Routine Include
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

  SELECTION-SCREEN FUNCTION KEY 1.

************************************************************************
* AT SELECTION-SCREEN OUTPUT                                           *
************************************************************************
AT SELECTION-SCREEN OUTPUT .
  PERFORM SET_SCREEN_FIELD.    "[기능개선 ______] 조건필드사용제한


************************************************************************
* AT SELECTION-SCREEN Events                                           *
************************************************************************
AT SELECTION-SCREEN.
*> 사용자 Input values Check
  PERFORM P1100_CHECK_INPUT_VALUES.
*> 사용자 레이아웃 Input values Check
  PERFORM P1101_CHECK_VARIANT_VALUE.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM P1102_AUTHORIZATION_CHECK USING S_BUKRS-LOW.
** JS전선 회사코드 2007/04 KSH --------------------------------------
  PERFORM SET_SSCRFIELDS.

*> 레이아웃 HELP
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM P1102_F4_FOR_VARIANT.
*> 지급조건 HELP(Low values)
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ZTERM-LOW.
  PERFORM GET_F4_FOR_ZTERM(ZTIR0000) USING S_ZTERM-LOW.
*> 지급조건 HELP(High values)
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ZTERM-HIGH.
  PERFORM GET_F4_FOR_ZTERM(ZTIR0000) USING S_ZTERM-HIGH.


************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.
*> 검색조건에 해당하는 데이타를 Select.
  PERFORM P2000_DATA_SELECTIONS.
*> Header table과 List(Items) table를 만듬.
  PERFORM P2100_HEADER_AND_LIST_BUILD.
*> Header table 금액 조정.
  PERFORM P2101_ADJUST_HEADER_AMOUNT.

************************************************************************
* END-OF-SELECTION Event                                               *
************************************************************************
END-OF-SELECTION.
  DESCRIBE TABLE IT_TABH LINES G_LINE.
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
*    REFRESH IT_LIST.
    PERFORM 3910_CALL_ALV_HIERSEQ.
*> Program 종료.
    PERFORM  P9000_PROGRAM_EXIT.
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

**eject
************************************************************************
* S U B R O U T I N E S
************************************************************************

**eject
************************************************************************
* P B O   M O D U L E
************************************************************************


**eject
************************************************************************
* P A I   M O D U L E
************************************************************************
