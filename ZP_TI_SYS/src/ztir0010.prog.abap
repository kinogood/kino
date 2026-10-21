************************************************************************
* Title         :  ZTIR0010                                            *
*                                                                      *
* Description   : [Report] 사후송금 Due List                           *
*                                                                      *
* Creation Date : 2004/02/30                                           *
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
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* 20090129       MMB03                     C20090121_89795             *
*                                         : 수입반품process 추가       *
* 20090610       MMB03                     C20090611_71632             *
*                                         : 사후송금 process개선       *
* 2010.09.20     MMC23           수입개설/송금요청 대상 제외           *
*                                구매오더 관리 테이블 데이터 체크      *
* 2017.10.19     신재호          LSEVK 분사에 따른 프로그램 수정       *
* 2018.10.23     강희대          검색조건에 플랜트 추가                *
************************************************************************
REPORT  ZTIR0010       MESSAGE-ID ZMTI00
                       NO STANDARD PAGE HEADING.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ZTS_REUSE_ALVFORMS_T00.  "> AVL 공용 Data 선언.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: L_YN    TYPE C.
INCLUDE ZTS_AUTHORIZATION_CHECK. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF TY_HEADER,
            BOX(1)      TYPE C,
            IBLNO       LIKE ZTITBLK-IBLNO,  "B/L 관리번호.
            BLNUM       LIKE ZTITBLK-BLNUM,  "B/L 번호.
            BLDTY       LIKE ZTITBLK-BLDTY,  "문서종류.
            BLDTYX(20)  TYPE C,              "문서종류TEXT.
            RPTTY       LIKE ZTITBLK-RPTTY,  "수입신고구분.
            RPTTYX(20)  TYPE C,              "수입신고구분TEXT.
            BUKRS       LIKE ZTITBLK-BUKRS,  "회사코드.
            EKORG       LIKE ZTITBLK-EKORG,  "구매조직.
            EKGRP       LIKE ZTITBLK-EKGRP,  "구매그룹.
            LIFNR       LIKE ZTITBLK-LIFNR,  "공급업체 계정번호.
            NAME1       LIKE LFA1-NAME1,     "구매처명.
            BLETD       LIKE ZTITBLK-BLETD,  "ETD(출발 예정 시각).
            BLETA       LIKE ZTITBLK-BLETA,  "ETA(도착 예정 시각).
            FWDTY       LIKE ZTITBLK-FWDTY,  "운송 방법.
            FWDTYX(20)  TYPE C,	           "운송 방법TEXT.
            LPONR       LIKE ZTITBLK-LPONR,  "최종품목번호.
            WAERS       LIKE ZTITBLK-WAERS,  "통화키.
            RTCHG       LIKE ZTITBLK-RTCHG,  "retention chg.
            TRTCHG      LIKE ZTITBLK-RTCHG,  "retention chg.
            SMAMT       LIKE ZTITBLK-SMAMT,  "총금액.
            TREFWR      LIKE ZTITBLP-REFWR, "total 송장금액.
            LGAYN       LIKE ZTITBLK-LGAYN.  "LG대상여부.
TYPES: END OF TY_HEADER.

TYPES: BEGIN OF TY_ITEM.
INCLUDE     TYPE        TY_HEADER.
TYPES :     IBLIT       LIKE ZTITBLP-IBLIT,  "B/L 품목번호.
            NDFTY       LIKE ZTITBLP-NDFTY,  "무환품 종류.
            NDFTYX(20)  TYPE C,	            "무환품 종류TEXT.
            BLMNG       LIKE ZTITBLP-BLMNG,  "B/L 수량.
            REFWR       LIKE ZTITBLP-REFWR,  "송장값 (외화).
            MEINS       LIKE ZTITBLP-MEINS,  "기본단위.
            EBELN       LIKE ZTITBLP-EBELN,  "구매전표번호.
            EBELP       LIKE ZTITBLP-EBELP,  "구매문서 품목번호.
            " 기능개선에 검색조건 추가 된 부분.
            WERKS       LIKE ZTISBLIT-WERKS,

            REQNO       LIKE ZTITBLP-REQNO,  "수입의뢰 관리번호.
            REQIT       LIKE ZTITBLP-REQIT,  "수입의뢰 품목번호.
            CNAM        LIKE ZTITBLP-CNAM,   "작성인.
            CDAT        LIKE ZTITBLP-CDAT,   "생성일.
            CTME        LIKE ZTITBLP-CTME,   "생성시간.
            UNAM        LIKE ZTITBLP-UNAM,   "최종변경인.
            UDAT        LIKE ZTITBLP-UDAT,   "변경일.
            UTME        LIKE ZTITBLP-UTME,   "최종변경시간.
            RQMNG       LIKE ZTISRQIT-RQMNG,
            RQMNGS      LIKE ZTISRQIT-RQMNGS,
            RQMNGL      LIKE ZTISRQIT-RQMNGL,
            NAME2       LIKE ZTISBLIT-NAME1,
            MATNR       LIKE ZTISBLIT-MATNR,
            TXZ01       LIKE ZTISBLIT-TXZ01,
            EEIND       LIKE ZTISBLIT-EEIND,
            NETPR       LIKE ZTISBLIT-NETPR,
            PEINH       LIKE ZTISBLIT-PEINH,
            CREFWR      LIKE ZTITCCP-REFWR,
            CCMNG       LIKE ZTITCCP-CCMNG,
            ICCNO       LIKE ZTITCCK-ICCNO,
            ICCSQ       LIKE ZTITCCK-ICCSQ,
            CDCNO       LIKE ZTITCCK-CDCNO,
            CDRDT       LIKE ZTITCCK-CDRDT,
            IRTCHG      LIKE ZTITBLK-RTCHG, ">> retention chg.
            NETWR       LIKE ZTISBLIT-NETWR.
TYPES: END OF TY_ITEM.


TYPES: BEGIN OF TY_LIST.
INCLUDE             TYPE        TY_ITEM.
TYPES:      COLOR   TYPE SLIS_T_SPECIALCOL_ALV.
TYPES: END OF TY_LIST.

*> Select용.
TYPES: BEGIN OF TY_TAB.
INCLUDE     TYPE        TY_ITEM.
TYPES: END OF TY_TAB.

************************************************************************
* SAP Include Define                                                   *
************************************************************************

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: T001,
        T001W,
        ZTITIG02,
        LFA1,
        ZTITRQK,
        ZTITRQP,
        ZTITBLK,
        ZTITBLP,
        ZTITIVP,
        ZTITIVK,
        BKPF.

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES: ZTIVPO00,    ">Purchasing Document : Header + Items
        ZTIVRQ00,    ">수입의뢰 Views(Header + Items + status)
        ZTIVBL00.    ">수입 B/L Views(Header + Items)

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

DATA: IT_LIST      TYPE TY_LIST   OCCURS 0 WITH HEADER LINE.
DATA: IT_HEADER    TYPE TY_HEADER OCCURS 0 WITH HEADER LINE.
DATA: IT_TAB       TYPE TY_TAB    OCCURS 0 WITH HEADER LINE.
DATA: GS_TAB       TYPE TY_TAB.


*> 사후송금 .
DATA : BEGIN OF IT_ZTISBLIT OCCURS 0.
        INCLUDE STRUCTURE ZTISBLIT.
DATA :  BOX        TYPE C,
        INDEX(10)  TYPE N.
DATA : END   OF IT_ZTISBLIT.

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
SELECTION-SCREEN BEGIN OF BLOCK DBSEL WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS:
  S_BUKRS  FOR ZTITRQK-BUKRS                  "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID BUK
                    MODIF  ID IOG ,
  S_EKORG  FOR ZTITBLK-EKORG MODIF ID IOG,    "구매조직.
  S_WERKS  FOR ZTITBLP-WERKS,
  S_EKGRP  FOR ZTITBLK-EKGRP MODIF ID IOG,    "구매그룹.
  S_EBELN  FOR ZTITBLP-EBELN MODIF ID IOG,    "구매전표번호.
  S_IBLNO  FOR ZTITBLK-IBLNO MODIF ID IOG	     "B/L 관리번호.
                              MEMORY ID ZTIIBLNO,
  S_BLNUM  FOR ZTITBLK-BLNUM MODIF ID IOG,    "B/L 번호.
  S_REQNO  FOR ZTITBLP-REQNO MODIF ID IOG,    "수입의뢰 관리번호.
  S_RPTTY  FOR ZTITBLK-RPTTY MODIF ID IOG,    "수입신고구분.
  S_LIFNR  FOR ZTITBLK-LIFNR MODIF ID IOG,    "공급업체 계정번호.
  S_BLETD  FOR ZTITBLK-BLETD MODIF ID IOG,    "ETD(출발 예정 시각).
  S_BLETA  FOR ZTITBLK-BLETA MODIF ID IOG,    "ETA(도착 예정 시각).
  S_FWDTY  FOR ZTITBLK-FWDTY MODIF ID IOG,    "운송 방법.
  S_LPONR  FOR ZTITBLK-LPONR MODIF ID IOG,    "최종품목번호.
  S_WAERS  FOR ZTITBLK-WAERS MODIF ID IOG,    "통화키.
  S_LGAYN  FOR ZTITBLK-LGAYN MODIF ID IOG,    "LG대상여부.
  S_IBLIT  FOR ZTITBLP-IBLIT MODIF ID IOG,    "B/L 품목번호.
  S_BLMNG  FOR ZTITBLP-BLMNG MODIF ID IOG,    "B/L 수량.
  S_REFWR  FOR ZTITBLP-REFWR MODIF ID IOG,    "송장값 (외화).
  S_MEINS  FOR ZTITBLP-MEINS MODIF ID IOG,    "기본단위.
  S_EBELP  FOR ZTITBLP-EBELP MODIF ID IOG,    "구매문서 품목번호.
  S_REQIT  FOR ZTITBLP-REQIT MODIF ID IOG,    "수입의뢰 품목번호.
  S_CNAM   FOR ZTITBLP-CNAM  MODIF ID IOG,    "작성인.
  S_CDAT   FOR ZTITBLP-CDAT  MODIF ID IOG,    "생성일.
  S_CTME   FOR ZTITBLP-CTME  MODIF ID IOG,    "생성시간.
  S_UNAM   FOR ZTITBLP-UNAM  MODIF ID IOG,    "최종변경인.
  S_UDAT   FOR ZTITBLP-UDAT  MODIF ID IOG,    "변경일.
  S_UTME   FOR ZTITBLP-UTME  MODIF ID IOG.    "최종변경시간.
SELECTION-SCREEN END OF BLOCK DBSEL.

SELECTION-SCREEN BEGIN OF BLOCK LISTS WITH FRAME TITLE TEXT-002.
PARAMETERS: P_VARI LIKE DISVARIANT-VARIANT.
SELECTION-SCREEN END OF BLOCK LISTS.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ZTS_REUSE_ALVFORMS_F00.  "> AVL 공용 Subroutines.

************************************************************************
* INITIALIZATION Event                                                 *
************************************************************************
INITIALIZATION.
*> Read default layout (description only, w/o field catalog)
  PERFORM P1000_ALV_FIELDS_INITIAL.
*> Initializaton By Program
  PERFORM P1001_INITIALIZATION.

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
  PERFORM P2100_HEADER_AND_LIST_BUILD_S.

************************************************************************
* END-OF-SELECTION Event                                               *
************************************************************************
END-OF-SELECTION.
  DESCRIBE TABLE IT_TAB LINES G_LINE.
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

*> Program 종료.
  PERFORM  P9000_PROGRAM_EXIT.

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
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
FORM P1001_INITIALIZATION .

  SET TITLEBAR 'T1000' WITH 'Due List'(T10).

ENDFORM.                    " p1001_initialization

*&---------------------------------------------------------------------*
*&      Form  p1100_check_input_values
*&---------------------------------------------------------------------*
FORM P1100_CHECK_INPUT_VALUES .

  TABLES: DFIES.

  DATA: L_BUKRS   LIKE T001-BUKRS,
        L_WERKS   LIKE T001W-WERKS,
        L_MATNR   LIKE MARA-MATNR,
        L_MTART   LIKE T134-MTART,
        L_EBELN   LIKE EKKO-EBELN,
        L_LIFNR   LIKE LFA1-LIFNR,
        L_EKORG   LIKE T024E-EKORG,
        L_EKGRP   LIKE T024-EKGRP.

* Company code
  SELECT BUKRS INTO (L_BUKRS)
               FROM T001 UP TO 1 ROWS WHERE BUKRS IN S_BUKRS.
  ENDSELECT.
  IF SY-SUBRC <> 0.
    PERFORM GET_FTEXT(RDDFIE00) USING 'T001' 'BUKRS' SY-LANGU
                                CHANGING DFIES G_SUBRC.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE E348(M7) WITH '회사코드'.
  ENDIF.

* Vendor
  READ TABLE S_LIFNR INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    SELECT LIFNR INTO (L_LIFNR)
                 FROM LFB1 UP TO 1 ROWS WHERE LIFNR IN S_LIFNR
                                        AND   BUKRS IN S_BUKRS.
    ENDSELECT.
    IF SY-SUBRC <> 0.
      PERFORM GET_FTEXT(RDDFIE00) USING 'LFA1' 'LIFNR' SY-LANGU
                                  CHANGING DFIES G_SUBRC.
      SET CURSOR FIELD 'S_LIFNR-LOW'.
      MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
    ENDIF.
  ENDIF.

* Purchase Organization
  READ TABLE S_EKORG INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    SELECT EKORG INTO (L_EKORG)
                 FROM T024E UP TO 1 ROWS WHERE EKORG IN S_EKORG.
    ENDSELECT.
    IF SY-SUBRC <> 0.
      PERFORM GET_FTEXT(RDDFIE00) USING 'T024E' 'EKORG' SY-LANGU
                                  CHANGING DFIES G_SUBRC.
      SET CURSOR FIELD 'S_EKORG-LOW'.
      MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
    ENDIF.
  ENDIF.

* Purchase GROUP
  READ TABLE S_EKGRP INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    SELECT EKGRP INTO (L_EKGRP)
                 FROM T024 UP TO 1 ROWS WHERE EKGRP IN S_EKGRP.
    ENDSELECT.
    IF SY-SUBRC <> 0.
      PERFORM GET_FTEXT(RDDFIE00) USING 'T024' 'EKGRP' SY-LANGU
                                  CHANGING DFIES G_SUBRC.
      SET CURSOR FIELD 'S_EKGRP-LOW'.
      MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
    ENDIF.
  ENDIF.

ENDFORM.                    " p1100_check_input_values

*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
FORM P2000_DATA_SELECTIONS .

  DATA: L_RQMNG  LIKE ZTITRQP-RQMNG.

  CLEAR: G_COUNT, IT_TAB,  IT_HEADER, IT_LIST.
  REFRESH : IT_TAB, IT_HEADER, IT_LIST.
*> PROGRESS Display.
  G_LINEN    = 30.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

**********************************************************************
* CSR  : C20090611_71632
* 사후송금 조건:수입통관 기준아닌 BL입력 시점으로 logic변경
**********************************************************************
* LSEVK 분사 관련 로직 추가
* LSEVK는 사후송금 시 관련 증빙 서류가 필요하여 통관이후 송금 가능함
**********************************************************************
  IF S_BUKRS-LOW = '5000'. "LSEVK
*> B/L 데이타 select.
    SELECT *
          INTO CORRESPONDING FIELDS OF TABLE IT_TAB
          FROM ZTIVCC02
         WHERE BUKRS  IN S_BUKRS  "회사코드.
           AND BLDTY  NE 'B'      " B/L유형 반품제외
           AND NDFTY  EQ 'A'      " 사후송금.
*         AND reqno  EQ space    "10수입의뢰 관리번호.
*         AND reqit  EQ space    "5수입의뢰 품목번호.
           AND IBLNO  IN S_IBLNO
           AND BLNUM  IN S_BLNUM  "25B/L 번호.
           AND RPTTY  IN S_RPTTY  "1수입신고구분.
           AND EKORG  IN S_EKORG                              "4구매조직.
           AND EKGRP  IN S_EKGRP                              "3구매그룹.
           AND LIFNR  IN S_LIFNR  "10공급업체 계정번호.
           AND BLETD  IN S_BLETD  "8ETD(출발 예정 시각).
           AND BLETA  IN S_BLETA  "8ETA(도착 예정 시각).
           AND FWDTY  IN S_FWDTY  "1운송 방법.
           AND LPONR  IN S_LPONR  "5최종품목번호.
           AND WAERS  IN S_WAERS                              "5통화키.
           AND LGAYN  IN S_LGAYN  "LG대상여부.
           AND IBLIT  IN S_IBLIT  "5B/L 품목번호.
*         AND b~ndfty  IN s_ndfty  "1무환품 종류.
           AND BLMNG  IN S_BLMNG  "13B/L 수량.
           AND REFWR  IN S_REFWR  "13송장값 (외화).
           AND MEINS  IN S_MEINS                              "3기본단위.
           AND EBELN  IN S_EBELN  "10구매전표번호.
           AND EBELP  IN S_EBELP  "5구매문서 품목번호.
*         AND reqno  IN s_reqno  "10수입의뢰 관리번호.
*         AND reqit  IN s_reqit  "5수입의뢰 품목번호.
           AND CNAM   IN S_CNAM                               "12작성인.
           AND CDAT   IN S_CDAT                               "8생성일.
           AND CTME   IN S_CTME                               "6생성시간.
           AND UNAM   IN S_UNAM   "12최종변경인.
           AND UDAT   IN S_UDAT                               "8변경일.
           AND UTME   IN S_UTME.  "6최종변경시간.

*> 무통관 입고 사후송금B/L 데이타 select.
*  IF it_tab[] IS INITIAL.
    SELECT *
          APPENDING CORRESPONDING FIELDS OF TABLE IT_TAB
          FROM ZTIVBL00
         WHERE BUKRS  IN S_BUKRS  "회사코드.
*         AND bldty  EQ s_bldty
           AND BLDTY  NE 'B'      " B/L유형 반품제외
           AND NDFTY  EQ 'A'      " 사후송금.
           AND RPTTY  EQ 'Z'      " 미통관
*         AND reqno  EQ space    "10수입의뢰 관리번호.
*         AND reqit  EQ space    "5수입의뢰 품목번호.
           AND IBLNO  IN S_IBLNO
           AND BLNUM  IN S_BLNUM  "25B/L 번호.
           AND RPTTY  IN S_RPTTY  "1수입신고구분.
           AND EKORG  IN S_EKORG                               "4구매조직.
           AND EKGRP  IN S_EKGRP                               "3구매그룹.
           AND LIFNR  IN S_LIFNR  "10공급업체 계정번호.
           AND BLETD  IN S_BLETD  "8ETD(출발 예정 시각).
           AND BLETA  IN S_BLETA  "8ETA(도착 예정 시각).
           AND FWDTY  IN S_FWDTY  "1운송 방법.
           AND LPONR  IN S_LPONR  "5최종품목번호.
           AND WAERS  IN S_WAERS                              "5통화키.
           AND LGAYN  IN S_LGAYN  "LG대상여부.
           AND IBLIT  IN S_IBLIT  "5B/L 품목번호.
*         AND b~ndfty  IN s_ndfty  "1무환품 종류.
           AND BLMNG  IN S_BLMNG  "13B/L 수량.
           AND REFWR  IN S_REFWR  "13송장값 (외화).
           AND MEINS  IN S_MEINS                               "3기본단위.
           AND EBELN  IN S_EBELN  "10구매전표번호.
           AND EBELP  IN S_EBELP  "5구매문서 품목번호.
*         AND reqno  IN s_reqno  "10수입의뢰 관리번호.
*         AND reqit  IN s_reqit  "5수입의뢰 품목번호.
           AND CNAM   IN S_CNAM                               "12작성인.
           AND CDAT   IN S_CDAT                               "8생성일.
           AND CTME   IN S_CTME                                "6생성시간.
           AND UNAM   IN S_UNAM   "12최종변경인.
           AND UDAT   IN S_UDAT                               "8변경일.
           AND UTME   IN S_UTME.  "6최종변경시간.
*  ENDIF.



  ELSE.
**********************************************************************
* CSR  : C20090611_71632
**********************************************************************
    SELECT *
          INTO CORRESPONDING FIELDS OF TABLE IT_TAB
*        APPENDING CORRESPONDING FIELDS OF TABLE it_tab
          FROM ZTIVBL00
         WHERE BUKRS  IN S_BUKRS  "회사코드.
            "  플랜트 개선 기능 사항
           AND WERKS  IN S_WERKS
           AND BLDTY  NE 'B'      " B/L유형 반품제외
           AND NDFTY  EQ 'A'      " 사후송금.
*         AND rptty  EQ 'Z'      " 미통관
*         AND reqno  EQ space    "10수입의뢰 관리번호.
*         AND reqit  EQ space    "5수입의뢰 품목번호.
          AND IBLNO  IN S_IBLNO
          AND BLNUM  IN S_BLNUM  "25B/L 번호.
          AND RPTTY  IN S_RPTTY  "1수입신고구분.
          AND EKORG  IN S_EKORG                               "4구매조직.
          AND EKGRP  IN S_EKGRP                               "3구매그룹.
          AND LIFNR  IN S_LIFNR  "10공급업체 계정번호.
          AND BLETD  IN S_BLETD  "8ETD(출발 예정 시각).
          AND BLETA  IN S_BLETA  "8ETA(도착 예정 시각).
          AND FWDTY  IN S_FWDTY  "1운송 방법.
          AND LPONR  IN S_LPONR  "5최종품목번호.
          AND WAERS  IN S_WAERS                               "5통화키.
          AND LGAYN  IN S_LGAYN  "LG대상여부.
          AND IBLIT  IN S_IBLIT  "5B/L 품목번호.
*        AND b~ndfty  IN s_ndfty  "1무환품 종류.
          AND BLMNG  IN S_BLMNG  "13B/L 수량.
          AND REFWR  IN S_REFWR  "13송장값 (외화).
          AND MEINS  IN S_MEINS                               "3기본단위.
          AND EBELN  IN S_EBELN  "10구매전표번호.
          AND EBELP  IN S_EBELP  "5구매문서 품목번호.
*         AND reqno  IN s_reqno  "10수입의뢰 관리번호.
*         AND reqit  IN s_reqit  "5수입의뢰 품목번호.
          AND CNAM   IN S_CNAM                                "12작성인.
          AND CDAT   IN S_CDAT                                "8생성일.
          AND CTME   IN S_CTME                                "6생성시간.
          AND UNAM   IN S_UNAM   "12최종변경인.
          AND UDAT   IN S_UDAT                                "8변경일.
          AND UTME   IN S_UTME.  "6최종변경시간.
**********************************************************************

  ENDIF.

  IF SY-SUBRC NE 0.
    MESSAGE S902.
  ENDIF.

  DATA : LS_0165 TYPE ZMMT0165,
         LV_ZTERM TYPE EKKO-ZTERM.

  CLEAR: G_TABIX, G_COUNT, G_CNT.



  LOOP AT IT_TAB.

    CLEAR LV_ZTERM.
    G_TABIX = SY-TABIX.

*&  2010.09.20 MMC23 zmmt0165 table 존재하는 대상 제외
    SELECT SINGLE * INTO LS_0165 FROM ZMMT0165
     WHERE EBELN EQ IT_TAB-EBELN
       AND EBELP EQ IT_TAB-EBELP
       AND WERKS EQ IT_TAB-WERKS.
    IF SY-SUBRC = 0.
      DELETE IT_TAB INDEX G_TABIX.
      CONTINUE.
    ENDIF.

**&  2011.09.22 구매지급조건 TANO 제외
    SELECT SINGLE ZTERM INTO LV_ZTERM FROM EKKO
     WHERE EBELN EQ IT_TAB-EBELN.

    IF LV_ZTERM = 'TANO'.
      DELETE IT_TAB INDEX G_TABIX.
      CONTINUE.
    ENDIF.
**

*   domain의 value.
    PERFORM GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING :
                           'ZTIBLDTY' IT_TAB-BLDTY  IT_TAB-BLDTYX,
                           'ZTIRPTTY' IT_TAB-RPTTY  IT_TAB-RPTTYX,
                           'ZTIFWDTY' IT_TAB-FWDTY  IT_TAB-FWDTYX,
                           'ZTINDFTY' IT_TAB-NDFTY  IT_TAB-NDFTYX.

*    IF ( it_tab-bldty  EQ 'A' ) AND ( it_tab-ndfty  EQ space ).
    IF  IT_TAB-NDFTY  EQ 'A'.

    ELSE.
*      IF it_tab-rtchg IS INITIAL.
      DELETE IT_TAB INDEX G_TABIX.
      CONTINUE.
*      ELSE.
*        it_tab-bldtyx = '유보금'.
*      ENDIF.
    ENDIF.

*   공급업체.
    SELECT SINGLE NAME1 INTO IT_TAB-NAME1
      FROM LFA1
     WHERE LIFNR EQ IT_TAB-LIFNR.

*   p/o정보.
    SELECT  SINGLE WERKS MATNR TXZ01
      INTO  (IT_TAB-WERKS, IT_TAB-MATNR, IT_TAB-TXZ01)
      FROM  ZTIVPO00
     WHERE  EBELN  = IT_TAB-EBELN
       AND  EBELP  = IT_TAB-EBELP.

*   사후 송금 누적수량.
    SELECT  SUM( RQMNG )
      INTO  IT_TAB-RQMNGS
      FROM  ZTITRQP
     WHERE  IBLNO  = IT_TAB-IBLNO
       AND  IBLIT  = IT_TAB-IBLIT.

*  사후 송금가능수량.
    IT_TAB-RQMNGL =  IT_TAB-BLMNG - IT_TAB-RQMNGS.
    IT_TAB-RQMNG  =  IT_TAB-RQMNGL.
    IF IT_TAB-RQMNGL LE 0.
      DELETE IT_TAB INDEX G_TABIX.
      CONTINUE.
    ENDIF.

    MOVE IT_TAB-REFWR TO IT_TAB-TREFWR.

    ADD 1 TO G_COUNT.

    MODIFY IT_TAB INDEX G_TABIX.

  ENDLOOP.


*> 유보금 계산로직.
  CLEAR G_TABIX.
  DATA: LO_RTCHG LIKE ZTITIVK-RTCHG,
        LT_RTCHG LIKE ZTITIVK-RTCHG.
"-> CCM : 2023.04.10 ZITCS4HDEV06 - sort 추가 작업.
  SORT it_tab.
  LOOP AT IT_TAB.
    G_TABIX = SY-TABIX.
    IF NOT IT_TAB-RTCHG IS INITIAL.
      MOVE-CORRESPONDING IT_TAB TO GS_TAB.
      AT NEW IBLNO.
        CLEAR : LO_RTCHG, LT_RTCHG .
      ENDAT.
      IF GS_TAB-SMAMT NE 0.
        GS_TAB-IRTCHG = GS_TAB-RTCHG *
                       ( GS_TAB-REFWR / GS_TAB-SMAMT ).
        LO_RTCHG = LO_RTCHG + GS_TAB-IRTCHG.
      ELSE.

      ENDIF.
      AT END OF IBLNO.
        LT_RTCHG = GS_TAB-RTCHG - LO_RTCHG.
        GS_TAB-IRTCHG = GS_TAB-IRTCHG + LT_RTCHG.
      ENDAT.

      MOVE GS_TAB-IRTCHG TO GS_TAB-TRTCHG.
      MODIFY IT_TAB FROM GS_TAB.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " p2000_data_selections
*&---------------------------------------------------------------------*
*&      Form  3000_field_category_build
*&---------------------------------------------------------------------*
FORM 3000_FIELD_CATEGORY_BUILD .

*----------------------------------------------------------------------*
* 필드명과 Output Length등을 사용자의 입맛에 맞게 바꿈.
*----------------------------------------------------------------------*
  PERFORM 3010_FILL_FIELD_CATEGORY USING :
*>>>>>>HEADER
"BOX.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'FIELDNAME'     'BOX',
          'E' 'KEY'           ' ',
"B/L 관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'IBLNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"문서상태 ndftyx
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '문서상태',
          ' ' 'FIELDNAME'     'BLDTYX',
          'E' 'OUTPUTLEN'     '10',
"회사코드
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'BUKRS',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '4',
"운송방법.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '운송방법',
          ' ' 'FIELDNAME'     'FWDTYX',
          'E' 'OUTPUTLEN'     '10',
"공급업체.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'LFA1',
*          ' ' 'seltext_m'     '공급업체명',
          ' ' 'FIELDNAME'     'LIFNR',
          'E' 'OUTPUTLEN'     '20',
"공급업체명.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '공급업체명',
          ' ' 'FIELDNAME'     'NAME1',
          'E' 'OUTPUTLEN'     '40',

"송장금액통화
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     'Cur',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'WAERS',
          'E' 'OUTPUTLEN'     '3',
"송장금액.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     '송장값 (외화)',
          ' ' 'FIELDNAME'     'TREFWR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '16',
"유보금.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'seltext_m'     '유보금',
          ' ' 'FIELDNAME'     'TRTCHG',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '16',
"수입신고구분
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '신고구분',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'RPTTYX',
          'E' 'OUTPUTLEN'     '14',

"B/L번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
*          ' ' 'seltext_m'     'BLNUM',
          ' ' 'FIELDNAME'     'BLNUM',
          ' ' 'HOTSPOT'       ' ',
          'E' 'OUTPUTLEN'     '26',

*>>>>>>>>>LIST
"B/L 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'IBLIT',
          ' ' 'HOTSPOT'       'X',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'INTLEN'         10,
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"구매전표번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'EBELN',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '10',
"구매문서 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'EBELP',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'NO_OUT'        ' ',
          'E' 'OUTPUTLEN'     '10',

"자재번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'FIELDNAME'     'MATNR',
          'E' 'OUTPUTLEN'     '20',
"자재내역.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'FIELDNAME'     'TXZ01',
          ' ' 'NO_OUT'        ' ',
          'E' 'OUTPUTLEN'     '40',
"송장금액.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'seltext_m'     '송장값 (외화)',
          ' ' 'FIELDNAME'     'REFWR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '20',
"유보금.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'seltext_m'     '유보금',
          ' ' 'FIELDNAME'     'IRTCHG',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          'E' 'OUTPUTLEN'     '16',
"문서상태 ndftyx
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '품목범주',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'NDFTYX',
          'E' 'OUTPUTLEN'     '13',
"B/L수량
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'seltext_m'     'B/L 수량',
          ' ' 'FIELDNAME'     'BLMNG',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'NO_OUT'        'X',
          ' ' 'QTABNAME'      'IT_LIST',
          'E' 'OUTPUTLEN'     '15',

"사전송금가능수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISRQIT',
*          ' ' 'seltext_s'     '의뢰가능수량',
*          ' ' 'seltext_m'     '의뢰(사후송금)가능수량',
          ' ' 'FIELDNAME'     'RQMNGL',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        ' ',
          'E' 'KEY'           ' ',
"사전송금누적수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISRQIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'FIELDNAME'     'RQMNGS',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'NO_OUT'        'X',
          'E' 'KEY'           ' ',
"사전송금수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISRQIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'FIELDNAME'     'RQMNG',
          ' ' 'NO_OUT'        'X',
          'E' 'KEY'           ' ',
"기본단위
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'MEINS',
          ' ' 'INTLEN'         10,
          'E' 'OUTPUTLEN'     '4',

"자재문서번호
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'MBLNR',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"자재문서연도
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'MJAHR',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"자재문서품목
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'ZEILE',
          ' ' 'NO_OUT'        'X',
*          'E' 'OUTPUTLEN'     '10'.
"작성인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'CNAM',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"최종변경인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'UNAM',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10'.

ENDFORM.                    " 3000_field_category_build

*&---------------------------------------------------------------------*
*&      Form  3200_KEY_INFOMATION_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM 3200_KEY_INFOMATION_BUILD .

  CLEAR GS_KEYINFO.

  GS_KEYINFO-HEADER01 = 'IBLNO'.
  GS_KEYINFO-ITEM01   = 'IBLNO'.

  GS_KEYINFO-HEADER02 =  SPACE.
  GS_KEYINFO-ITEM02   = 'IBLIT'.

*  GS_KEYINFO-HEADER03 = SPACE.
*  GS_KEYINFO-ITEM03   = 'OBJNR'.

ENDFORM.                    " 3200_KEY_INFOMATION_BUILD
*&---------------------------------------------------------------------*
*&      Form  3100_SET_COLOR_INFOMATION
*&---------------------------------------------------------------------*
FORM 3100_SET_COLOR_INFOMATION .

  LOOP AT IT_LIST.

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
FORM 3400_COMMENT_BUILD .

  DATA: L_TEXT20(20) TYPE C.

  CLEAR: IT_LISTHEADER, GS_LISTHEADER.
  REFRESH: IT_LISTHEADER.

* LIST HEADING LINE: TYPE H
  CLEAR GS_LISTHEADER.
  GS_LISTHEADER-TYP  = 'H'.
* gs_listheader-KEY:  NOT USED FOR THIS TYPE
  GS_LISTHEADER-INFO = '사후송금 수입의뢰 요청Due List'(T13).
*  SHIFT gs_listheader-info RIGHT BY 20 PLACES.
  APPEND GS_LISTHEADER TO IT_LISTHEADER.

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: L_BUTXT LIKE T001-BUTXT.
  CLEAR: L_BUTXT.
  SELECT SINGLE BUTXT FROM T001
                      INTO L_BUTXT
                     WHERE BUKRS EQ S_BUKRS-LOW.

  CLEAR GS_LISTHEADER.
  GS_LISTHEADER-TYP  = 'A'.
  GS_LISTHEADER-INFO = '회사코드 :'.
  CONCATENATE GS_LISTHEADER-INFO S_BUKRS-LOW L_BUTXT
         INTO GS_LISTHEADER-INFO SEPARATED BY SPACE.
  APPEND GS_LISTHEADER TO IT_LISTHEADER.
** JS전선 회사코드 2007/04 KSH --------------------------------------

* ACTION LINE: TYPE A
  CLEAR GS_LISTHEADER.
  GS_LISTHEADER-TYP  = 'A'.
  GS_LISTHEADER-INFO = '출력일자 :'(T12).
  WRITE: SY-DATLO TO L_TEXT20.
  CONCATENATE GS_LISTHEADER-INFO L_TEXT20 INTO GS_LISTHEADER-INFO
              SEPARATED BY SPACE.
  APPEND GS_LISTHEADER TO IT_LISTHEADER.

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
FORM 3500_SORT_TABLE_BUILD .

  DATA: LS_SORT TYPE SLIS_SORTINFO_ALV.

  CLEAR LS_SORT.
  LS_SORT-SPOS      = 1.
  LS_SORT-FIELDNAME = 'IBLNO'.
  LS_SORT-TABNAME   = 'IT_LIST'.
  LS_SORT-UP        = 'X'.
* LS_SORT-GROUP     = '*'.             " Seiten- bei Gruppenwechsel
*  ls_sort-group     = 'UL'.            " Underline      -"-
  APPEND LS_SORT TO IT_SORT.

ENDFORM.                    " 3500_SORT_TABLE_BUILD
*&---------------------------------------------------------------------*
*&      Form  3700_LAYOUT_build
*&---------------------------------------------------------------------*
FORM 3700_LAYOUT_BUILD .

  MOVE: 'BOX'        TO GS_LAYOUT-BOX_FIELDNAME,
        'IT_HEADER'  TO GS_LAYOUT-BOX_TABNAME.

*  MOVE: '3'          TO gs_layout-no_vline. " 분리자 라인.

ENDFORM.                    " 3700_LAYOUT_build

*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
FORM TOP_OF_PAGE.                                           "#EC CALLED

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = IT_LISTHEADER[].



ENDFORM.                    "TOP_OF_PAGE

*---------------------------------------------------------------------*
*       Form  USER_COMMAND                                            *
*---------------------------------------------------------------------*
FORM USER_COMMAND USING R_UCOMM     LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.

  DATA: LS_HEADER TYPE TY_HEADER.
  DATA: LS_LIST   TYPE TY_TAB,
        L_ERROR   TYPE C          VALUE 'N'.

  CLEAR: LS_HEADER.

  CASE R_UCOMM.
    WHEN '&REFRESH'.
      PERFORM P9000_DUELIST_REFRESH USING  RS_SELFIELD.

    WHEN 'ZTIT001'. " 후속기능
      CLEAR : G_LINE, G_COUNT.
      REFRESH: IT_ZTISBLIT.  CLEAR: IT_ZTISBLIT.
      LOOP AT IT_HEADER WHERE BOX EQ 'X'.
        ADD 1 TO G_LINE.
        LOOP AT IT_LIST WHERE IBLNO EQ IT_HEADER-IBLNO.
          ADD 1 TO G_COUNT.

****************************************************************
** 2007.09.03 simcho  채권채무 상계처리
****************************************************************

          CLEAR: ZTITIVP,ZTITIVK,BKPF.

          DATA : LV_BUKRS LIKE BKPF-BUKRS,
                 LV_IVONO LIKE ZTITIVP-IVONO,
                 LV_RBLGP LIKE ZTITIVP-RBLGP,
                 LV_BELNR LIKE ZTITIVK-BELNR,
                 LV_GJAHR LIKE ZTITIVK-GJAHR,
                 LV_BELNR_SAP LIKE BKPF-BELNR,
                 LV_AWKEY LIKE BKPF-AWKEY,
                 LV_AUGBL LIKE BSEG-AUGBL,
                 LV_BELNR_CLR LIKE BSE_CLR-BELNR_CLR,
                 LV_MSG01(300),
                 LV_MSG02(300),
                 LV_MSG03(300).
**************************************************************
** CSR  : C20090611_71632
** 사후송금 조건:수입통관 기준아닌 BL입력 시점으로 logic변경
**               송장생성 여부 체크
***************************************************************
*          CLEAR : lv_ivono, lv_rblgp, lv_belnr, lv_gjahr.
*
*          SELECT SINGLE ivono  rblgp  INTO (lv_ivono, lv_rblgp)
*            FROM ztitivp
*           WHERE iblno  EQ  it_list-iblno
*             AND iblit  EQ  it_list-iblit.
*
*          IF sy-subrc = '00'.
*            SELECT SINGLE belnr gjahr INTO (lv_belnr, lv_gjahr)
*              FROM ztitivk
*             WHERE ivono = lv_ivono.
*          ENDIF.
*
*          IF lv_belnr = '' .
*            MESSAGE e997 WITH it_list-iblno it_list-iblit
*                              '송장 미처리 상태입니다.'.
*          ENDIF.
*************************************************************
*          SELECT SINGLE ivono  rblgp  INTO (lv_ivono, lv_rblgp)
*            FROM ztitivp
*           WHERE iblno  EQ  it_list-iblno
*             AND iblit  EQ  it_list-iblit.
*
*          IF sy-subrc = '00'.
*            SELECT SINGLE belnr gjahr INTO (lv_belnr, lv_gjahr)
*              FROM ztitivk
*             WHERE ivono = lv_ivono.
*
*            IF sy-subrc = '00'.
*
*              CONCATENATE lv_belnr lv_gjahr INTO lv_awkey.
*
*              SELECT SINGLE bukrs belnr INTO (lv_bukrs, lv_belnr_sap)
*                FROM bkpf
*               WHERE awkey = lv_awkey.
*********************************************************************
** 반제전표 찾기
*********************************************************************
*              IF sy-subrc = '00'.
*                SELECT SINGLE augbl INTO lv_augbl
*                  FROM bseg
*                 WHERE bukrs = lv_bukrs
*                   AND belnr = lv_belnr_sap
*                   AND gjahr = lv_gjahr
*                   AND koart = 'K'.  "공급업체
*
*                IF lv_augbl IS NOT INITIAL.
*                  MESSAGE e997 WITH
*                  it_list-iblno '해당 B/L은 채권과 완전반제 되었습니다'
*                  '선택 할 수 없습니다.'.
*                ELSE.
*********************************************************************
** 채권 < 채무 상계전표 유무 확인
*********************************************************************
*                  SELECT SINGLE belnr_clr INTO lv_belnr_clr
*                    FROM bse_clr
*                   WHERE bukrs = lv_bukrs
*                     AND belnr = lv_belnr_sap
*                     AND gjahr = lv_gjahr.
*
**                  IF lv_belnr_clr IS NOT INITIAL.
**
**                    CONCATENATE it_list-iblno
**                                ' 해당 B/L은 채권과
*부분반제되었습니다'
**                                INTO lv_msg01.
**
**                    CONCATENATE '반제전표 번호는' lv_belnr_clr
**                                INTO lv_msg02.
**
**                    MESSAGE i997 WITH lv_msg01 lv_msg02 '입니다.'.
**
**                  ENDIF.
*********************************************************************
*
*                ENDIF.
*              ENDIF.

*            ENDIF.

*          ENDIF.


***************************************************************

          SELECT  SINGLE *
            INTO  CORRESPONDING FIELDS OF IT_ZTISBLIT
            FROM  ZTIVBL00
           WHERE  IBLNO  EQ  IT_LIST-IBLNO
             AND  IBLIT  EQ  IT_LIST-IBLIT.

          MOVE: G_COUNT              TO IT_ZTISBLIT-INDEX,
                C_TRUE               TO IT_ZTISBLIT-BOX,
                IT_LIST-RQMNG        TO IT_ZTISBLIT-RQMNG,
                IT_LIST-RQMNGL       TO IT_ZTISBLIT-RQMNGL,
                IT_LIST-RQMNGS       TO IT_ZTISBLIT-RQMNGS.

          APPEND IT_ZTISBLIT.
        ENDLOOP.
      ENDLOOP.

************************************************************************
      IF LV_BELNR_CLR IS NOT INITIAL.

        CONCATENATE IT_LIST-IBLNO
                    ' 해당 B/L은 채권과 부분반제 되었습니다'
                    INTO LV_MSG01.
        CONCATENATE '반제전표 번호는' LV_BELNR_CLR INTO LV_MSG02.

        MESSAGE I997 WITH LV_MSG01 LV_MSG02 '입니다.'.

      ENDIF.
************************************************************************
      CHECK L_ERROR EQ 'N'.


***************************************************
* 20061214 오민석 K요청
***************************************************
*      CASE g_line.
*        WHEN 0.
*          MESSAGE s006(0k).   EXIT.
*        WHEN 1.
*        WHEN OTHERS.
*          MESSAGE s929.       EXIT.
*      ENDCASE.

      CASE G_LINE.
        WHEN 0.
          MESSAGE S006(0K).   EXIT.
        WHEN 1.
        WHEN OTHERS.
          MESSAGE S999 WITH
          'B/L을 하나이상 선택하셨습니다. 계속하시겠습니까?'.

      ENDCASE.

***************************************************
* end
***************************************************

*> Call Dialog
      CALL DIALOG 'Z_TI_LC_CREATE'
        AND SKIP FIRST SCREEN
        EXPORTING
          G_TCODE     FROM SY-TCODE
          IT_ZTISBLIT FROM IT_ZTISBLIT
          G_MSG01     FROM LV_MSG01
          G_MSG02     FROM LV_MSG02
        IMPORTING
          ZTITRQK.

*> 검색조건에 해당하는 데이타를 Select.
      PERFORM P2000_DATA_SELECTIONS.
*> Header table과 List(Items) table를 만듬.
      PERFORM P2100_HEADER_AND_LIST_BUILD.

      DESCRIBE TABLE IT_TAB LINES G_LINE.
      IF NOT G_LINE IS INITIAL.
        RS_SELFIELD-REFRESH = 'X'.
      ELSE.
*> Program 종료.
        PERFORM  P9000_PROGRAM_EXIT.
      ENDIF.

    WHEN '&IC1'.

      IF RS_SELFIELD-TABNAME EQ 'IT_HEADER'.
        READ TABLE IT_HEADER INDEX RS_SELFIELD-TABINDEX.
      ELSEIF RS_SELFIELD-TABNAME EQ 'IT_LIST'.
        READ TABLE IT_LIST INDEX RS_SELFIELD-TABINDEX.
      ENDIF.
      IF SY-SUBRC NE 0.
        MESSAGE S903. EXIT.
      ENDIF.

      IF RS_SELFIELD-TABNAME EQ 'IT_HEADER'.
        MOVE-CORRESPONDING IT_HEADER TO LS_LIST.
      ELSEIF RS_SELFIELD-TABNAME EQ 'IT_LIST'.
        MOVE-CORRESPONDING IT_LIST   TO LS_LIST.
      ENDIF.

      CASE RS_SELFIELD-FIELDNAME.
        WHEN 'EBELN' OR 'EBELP'.
          PERFORM  DISPLAY_PURCHASE_ORDER(ZTIR0000)
                                          USING LS_LIST-EBELN
                                                LS_LIST-EBELP.
        WHEN OTHERS.
          PERFORM  DISPLAY_BL_DOCUMENT(ZTIR0000)
                                          USING LS_LIST-IBLNO
                                                '00000'.
      ENDCASE.
*      perform p9000_duelist_refresh USING  rs_selfield.
    WHEN OTHERS.
  ENDCASE.

  CLEAR: R_UCOMM.

ENDFORM.                    "USER_COMMAND
*---------------------------------------------------------------------*
*       FORM PF_STATUS_SET                                            *
*---------------------------------------------------------------------*
FORM PF_STATUS_SET USING RT_EXTAB TYPE SLIS_T_EXTAB.

  SET TITLEBAR 'T1000' WITH '요청'(T10).

  REFRESH: RT_EXTAB.

  APPEND 'ARCHIVE'   TO RT_EXTAB.
  APPEND '&VEXCEL'   TO RT_EXTAB.
  APPEND '&AQW'      TO RT_EXTAB.
  APPEND '&VCRYSTAL' TO RT_EXTAB.
  APPEND '&VGRID'    TO RT_EXTAB.
  APPEND '&EB9'      TO RT_EXTAB.
  APPEND '&CRDESIG'  TO RT_EXTAB.
  APPEND '&XXL'      TO RT_EXTAB.
  APPEND '&ABC'      TO RT_EXTAB.

  SET PF-STATUS 'STANDARD ' EXCLUDING RT_EXTAB.

ENDFORM.                    "PF_STATUS_SET

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
*&---------------------------------------------------------------------*
*&      Form  p2100_header_and_list_build_s
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM P2100_HEADER_AND_LIST_BUILD_S .

  LOOP AT IT_TAB.
    MOVE-CORRESPONDING IT_TAB TO : IT_HEADER, IT_LIST.
    COLLECT : IT_HEADER.
    APPEND  IT_LIST.
  ENDLOOP.


  IF S_BUKRS-LOW EQ '3000'.
    DATA : LV_CHK_300 .

    GET PARAMETER ID 'ZTIT300'  FIELD LV_CHK_300.
    SET PARAMETER ID 'ZTIT300'  FIELD SPACE.

    IF LV_CHK_300 IS NOT INITIAL.
      LOOP AT IT_HEADER.
        IT_HEADER-BOX = 'X'.
        MODIFY IT_HEADER TRANSPORTING BOX.
      ENDLOOP.

      PERFORM USER_COMMAND USING 'ZTIT001'
                                  GS_SELFIELD.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.



*  clear g_tabix.
*  data: lo_rtchg like ZTITIVK-rtchg,
*        lt_rtchg like ZTITIVK-rtchg.
*
*  loop at it_tab.
*     g_tabix = sy-tabix.
*     move-corresponding it_tab to gs_tab.
*     at new iblno.
*        clear : lo_rtchg, lt_rtchg .
*     endat.
*     if gs_tab-smamt ne 0.
*        gs_tab-irtchg = gs_tab-rtchg *
*                       ( gs_tab-refwr / gs_tab-smamt ).
*        lo_rtchg = lo_rtchg + gs_tab-irtchg.
*     else.
*
*     endif.
*     at end of iblno.
*       lt_rtchg = gs_tab-rtchg - lo_rtchg.
*       gs_tab-irtchg = gs_tab-irtchg + lt_rtchg.
*     endat.
*
*     MOVE gs_tab-irtchg TO gs_tab-trtchg.
*     MODIFY it_tab from gs_tab.
*  endloop.




ENDFORM.                    " p2100_header_and_list_build_s
