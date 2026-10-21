************************************************************************
* Title         :  ZTIR5020                                            *
*                                                                      *
* Description   : [Report] 미통관 입고 Due List                        *
*                                                                      *
* Creation Date : 2003/08/07                                           *
*                                                                      *
* Author        : Seog Bong, Kang                                      *
*                                                                      *
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
* 2012.03.12      MMB03         C20120222_56033                        *
*                         :송장 미처리 건에 대한 입고 제어처리         *
*----------------------------------------------------------------------*
* 2012.11.05    MMB04(HDY)      C20121026_06477                        *
*                         :SAP Standard 입고수량 제어 처리             *
*----------------------------------------------------------------------*
* 2012.11.20    MMB04(HDY)      Q20121119_56202                        *
*                         :선급금 BL 조건 처리                         *
*----------------------------------------------------------------------*
* 2013.02.15    MMB04(HDY)      C20130213_71713                        *
*                         :수입 입고완료 오더 삭제(테이블 유지보수)    *
*----------------------------------------------------------------------*
REPORT  ZTIR5020       MESSAGE-ID ZMTI00
                       NO STANDARD PAGE HEADING.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ZTS_REUSE_ALVFORMS_T00.       "> AVL 공용 Data 선언.
INCLUDE ZTS_REUSE_BDC_SUBROUTINE_F00. ">BDC 공용 Subroutines.
************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF TY_HEADER,
         BOX(1)     TYPE C,
         IBLNO      LIKE ZTITBLK-IBLNO,    "10B/L 관리번호.
         BLNUM      LIKE ZTITBLK-BLNUM,    "25B/L 번호.
         BLDTY      LIKE ZTITBLK-BLDTY,                 "1문서종류.
         BLDTYX(20) TYPE C,                 "문서종류TEXT.
         RPTTY      LIKE ZTITBLK-RPTTY,    "1수입신고구분.
         RPTTYX(20) TYPE C,                 "수입신고구분TEXT.
         BUKRS      LIKE ZTITBLK-BUKRS,                 "4회사코드.
         EKORG      LIKE ZTITBLK-EKORG,                 "4구매조직.
         EKGRP      LIKE ZTITBLK-EKGRP,                 "3구매그룹.
         LIFNR      LIKE ZTITBLK-LIFNR,    "10공급업체 계정번호.
         NAME1      LIKE LFA1-NAME1,
         IVSLN      LIKE ZTITBLK-IVSLN,    "B/L 발행일..
         BLDAT      LIKE ZTITBLK-BLDAT,    "B/L 발행일..
         BLETD      LIKE ZTITBLK-BLETD,    "8ETD(출발 예정 시각).
         BLETA      LIKE ZTITBLK-BLETA,    "8ETA(도착 예정 시각).
         FWDTY      LIKE ZTITBLK-FWDTY,    "1운송 방법.
         FWDTYX(20) TYPE C,                 "1운송 방법TEXT.
         LPONR      LIKE ZTITBLK-LPONR,    "5최종품목번호.
         WAERS      LIKE ZTITBLK-WAERS,                 "5통화키.
         TREFWR     LIKE ZTITBLP-REFWR,    ">> total 송장금액.
         LGAYN      LIKE ZTITBLK-LGAYN.    "LG대상여부.
TYPES: END OF TY_HEADER.

TYPES: BEGIN OF TY_ITEM.
         INCLUDE     TYPE        TY_HEADER.
TYPES :  IBLIT      LIKE ZTITBLP-IBLIT,    "5B/L 품목번호.
         NDFTY      LIKE ZTITBLP-NDFTY,    "1무환품 종류.
         NDFTYX(20) TYPE C,	              "무환품 종류TEXT.
         BLMNG      LIKE ZTITBLP-BLMNG,    "13B/L 수량.
         REFWR      LIKE ZTITBLP-REFWR,    "13송장값 (외화).
         MEINS      LIKE ZTITBLP-MEINS,                 "3기본단위.
         EBELN      LIKE ZTITBLP-EBELN,    "10구매전표번호.
         EBELP      LIKE ZTITBLP-EBELP,    "5구매문서 품목번호.
         REQNO      LIKE ZTITBLP-REQNO,    "10수입의뢰 관리번호.
         REQIT      LIKE ZTITBLP-REQIT,    "5수입의뢰 품목번호.
         CNAM       LIKE ZTITBLP-CNAM,                  "12작성인.
         CDAT       LIKE ZTITBLP-CDAT,                  "8생성일.
         CTME       LIKE ZTITBLP-CTME,                  "6생성시간.
         UNAM       LIKE ZTITBLP-UNAM,     "12최종변경인.
         UDAT       LIKE ZTITBLP-UDAT,                  "8변경일.
         UTME       LIKE ZTITBLP-UTME,     "6최종변경시간.
         MENGE      LIKE ZTISBLIT-MENGE,
         BLMNGS     LIKE ZTISBLIT-BLMNGS,
         BLMNGL     LIKE ZTISBLIT-BLMNGL,
         IVMNGL     LIKE ZTISIVIT-IVMNGL,
         IVMNGS     LIKE ZTISIVIT-IVMNGS,
         WERKS      LIKE ZTISBLIT-WERKS,
         NAME2      LIKE ZTISBLIT-NAME1,
         MATNR      LIKE ZTISBLIT-MATNR,
         TXZ01      LIKE ZTISBLIT-TXZ01,
         MATKL      LIKE ZTIVPO00-MATKL,
         EEIND      LIKE ZTISBLIT-EEIND,
         NETPR      LIKE ZTISBLIT-NETPR,
         PEINH      LIKE ZTISBLIT-PEINH,
         GRMNGS     LIKE ZTISGRIT-GRMNGS,
         GRMNGL     LIKE ZTISGRIT-GRMNGL,
         NETWR      LIKE ZTISBLIT-NETWR.
TYPES: END OF TY_ITEM.


TYPES: BEGIN OF TY_LIST.
         INCLUDE             TYPE        TY_ITEM.
TYPES:   COLOR TYPE SLIS_T_SPECIALCOL_ALV.
TYPES: END OF TY_LIST.

*> Select용.
TYPES: BEGIN OF TY_TAB.
         INCLUDE     TYPE        TY_ITEM.
TYPES: END OF TY_TAB.

*> TYPE FOR THE DATA OF '수입물품 미통관 아이템'
TYPES: BEGIN OF T_ZTISCCIT.
         INCLUDE STRUCTURE ZTISCCIT.
TYPES:   BOX       TYPE C,
         INDEX(10) TYPE N,
       END OF T_ZTISCCIT.

*> INTERNAL TABLE FOR TABLECONTROL '수입아이템'
DATA: IT_ZTISCCIT   TYPE T_ZTISCCIT OCCURS 0 WITH HEADER LINE,
      G_ZTISCCIT_WA TYPE T_ZTISCCIT.           ">work area

DATA: G_INDXKEY LIKE INDX-SRTFD VALUE 'ZTITCODE',
      GS_INDX   TYPE INDX.

**** HDY 20130215 START C20130213_71713 REQ.오상환
**** 스탠다드에서 입고 완료된 오더에 대해서 테이블 유지보수 하여
**** DUE LIST에 뜨지 않도록 TABLE 생성
DATA : GT_ZTITZGR LIKE ZTITZGR OCCURS 0 WITH HEADER LINE.
**** HDY 20130215 END

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
        MARA,
        ZTITRQK,
        ZTITRQS,
        ZTITRQP,
        ZTITBLK,
        ZTITBLP,
        ZTITIVK,
        ZTITIVP,
        ZTITCCK,
        ZTITCCP,
        ZTITGRK,
        ZTITGRP.

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES: ZTIVPO00,    ">Purchasing Document : Header + Items
        ZTIVRQ00,    ">수입의뢰 Views(Header + Items + status)
**** HDY 20121105 START C20121026_06477 REQ.현진영
        ZTIVGR00.    ">수입입고 Views(Header + Items)


************************************************************************
* CONSTANTS                                                            *
************************************************************************
** JS전선 회사코드 2007/04 --------------------------------------
*CONSTANTS:
*    c_bukrs     LIKE t001-bukrs     VALUE '1000'.   ">Company code
** JS전선 회사코드 2007/04 --------------------------------------
************************************************************************
* Internal Tables                                                      *
************************************************************************
*DATA : BEGIN OF it_ZTItig02 OCCURS 0.
*        INCLUDE STRUCTURE ZTItig02.
*DATA : END   OF it_ZTItig02.
*
DATA: IT_ZTITIG02  TYPE ZTITIG02  OCCURS 0 WITH HEADER LINE.
DATA: IT_LIST      TYPE TY_LIST   OCCURS 0 WITH HEADER LINE.
DATA: IT_HEADER    TYPE TY_HEADER OCCURS 0 WITH HEADER LINE.
DATA: IT_TAB       TYPE TY_TAB    OCCURS 0 WITH HEADER LINE.

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
SELECT-OPTIONS:
  S_BUKRS  FOR ZTITRQK-BUKRS                   "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID BUK
                    MODIF  ID IOG ,
  S_EKORG  FOR ZTITBLK-EKORG MODIF ID IOG,                  "4구매조직.
  S_EKGRP  FOR ZTITBLK-EKGRP MODIF ID IOG,                  "3구매그룹.
  S_EBELN  FOR ZTITBLP-EBELN MODIF ID IOG
                              MEMORY ID BES,    "10구매전표번호.
  S_IBLNO  FOR ZTITBLK-IBLNO MODIF ID IOG      "B/L 관리번호.
                              MEMORY ID ZTIIBLNO,
  S_BLNUM  FOR ZTITBLK-BLNUM MODIF ID IOG,     "25B/L 번호.
  S_REQNO  FOR ZTITBLP-REQNO MODIF ID IOG      "10수입의뢰 관리번호.
                              MEMORY ID ZTIREQNO,
  S_MATKL  FOR ZTIVPO00-MATKL MODIF ID IOG
                              MEMORY ID MKL,    "자재그룹.
  S_LIFNR  FOR ZTITBLK-LIFNR MODIF ID IOG.     "10공급업체 계정번호.
SELECTION-SCREEN ULINE.
SELECT-OPTIONS:
  S_BLDTY  FOR ZTITBLK-BLDTY MODIF ID IOG,                  "1문서종류.
  S_RPTTY  FOR ZTITBLK-RPTTY MODIF ID IOG,     "1수입신고구분.
  S_BLETD  FOR ZTITBLK-BLETD MODIF ID IOG,     "8ETD(출발 예정 시각).
  S_BLETA  FOR ZTITBLK-BLETA MODIF ID IOG,     "8ETA(도착 예정 시각).
  S_FWDTY  FOR ZTITBLK-FWDTY MODIF ID IOG,     "1운송 방법.
  S_LPONR  FOR ZTITBLK-LPONR MODIF ID IOG,     "5최종품목번호.
  S_WAERS  FOR ZTITBLK-WAERS MODIF ID IOG,                  "5통화키.
  S_LGAYN  FOR ZTITBLK-LGAYN MODIF ID IOG,     "LG대상여부.
  S_IBLIT  FOR ZTITBLP-IBLIT MODIF ID IOG,     "5B/L 품목번호.
  S_EBELP  FOR ZTITBLP-EBELP MODIF ID IOG,     "5구매문서 품목번호.
  S_REQIT  FOR ZTITBLP-REQIT MODIF ID IOG,     "5수입의뢰 품목번호.
  S_CNAM   FOR ZTITBLP-CNAM  MODIF ID IOG,                  "12작성인.
  S_CDAT   FOR ZTITBLP-CDAT  MODIF ID IOG,                  "8생성일.
  S_CTME   FOR ZTITBLP-CTME  MODIF ID IOG,                  "6생성시간.
  S_UNAM   FOR ZTITBLP-UNAM  MODIF ID IOG,     "12최종변경인.
  S_UDAT   FOR ZTITBLP-UDAT  MODIF ID IOG,                  "8변경일.
  S_UTME   FOR ZTITBLP-UTME  MODIF ID IOG.     "6최종변경시간.


SELECTION-SCREEN BEGIN OF BLOCK LISTS WITH FRAME TITLE TEXT-002.
  PARAMETERS: P_VARI  LIKE DISVARIANT-VARIANT,
              P_ITEM  TYPE C AS CHECKBOX DEFAULT 'X',
              P_IVCHK TYPE C AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK LISTS.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ZTS_REUSE_ALVFORMS_F00.  "> AVL 공용 Subroutines.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: L_YN    TYPE C.
INCLUDE ZTS_AUTHORIZATION_CHECK. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* INITIALIZATION Event                                                 *
************************************************************************
INITIALIZATION.
  PERFORM P1000_ALV_FIELDS_INITIAL.
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
  PERFORM P2100_HEADER_AND_LIST_BUILD.
*> 품목을 조회하지 않음.
  PERFORM P2001_ITEM_CLEAR USING P_ITEM.
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

****************u*******************************************************
*
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
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
FORM P2000_DATA_SELECTIONS .

  DATA: L_RQMNG  LIKE ZTITRQP-RQMNG.

  CLEAR: G_COUNT, IT_TAB, IT_ZTITIG02, IT_HEADER, IT_LIST.
  REFRESH : IT_TAB, IT_ZTITIG02, IT_HEADER, IT_LIST.
*> PROGRESS Display.
  G_LINEN    = 30.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

*> B/L 데이타 select.
  SELECT *
        INTO CORRESPONDING FIELDS OF TABLE IT_TAB
        FROM ( ZTITBLK AS A JOIN ZTITBLP AS B
          ON A~IBLNO EQ B~IBLNO )
       WHERE A~BUKRS  IN S_BUKRS  "회사코드.
         AND A~IBLNO  IN S_IBLNO
         AND A~BLNUM  IN S_BLNUM  "25B/L 번호.
         AND A~BLDTY  IN S_BLDTY                            "1문서종류.
         AND A~RPTTY  EQ C_CHARZ  "미통관분만 발췌.
         AND A~EKORG  IN S_EKORG                            "4구매조직.
         AND A~EKGRP  IN S_EKGRP                            "3구매그룹.
         AND A~LIFNR  IN S_LIFNR  "10공급업체 계정번호.
         AND A~BLETD  IN S_BLETD  "8ETD(출발 예정 시각).
         AND A~BLETA  IN S_BLETA  "8ETA(도착 예정 시각).
         AND A~FWDTY  IN S_FWDTY  "1운송 방법.
         AND A~LPONR  IN S_LPONR  "5최종품목번호.
         AND A~WAERS  IN S_WAERS                            "5통화키.
         AND A~LGAYN  IN S_LGAYN  "LG대상여부.
         AND B~IBLIT  IN S_IBLIT  "5B/L 품목번호.
*         AND b~ndfty  EQ space    "1무환품 종류.
         AND B~EBELN  IN S_EBELN  "10구매전표번호.
         AND B~EBELP  IN S_EBELP  "5구매문서 품목번호.
         AND B~REQNO  IN S_REQNO  "10수입의뢰 관리번호.
         AND B~REQIT  IN S_REQIT  "5수입의뢰 품목번호.
         AND B~CNAM   IN S_CNAM                             "12작성인.
         AND B~CDAT   IN S_CDAT                             "8생성일.
         AND B~CTME   IN S_CTME                             "6생성시간.
         AND B~UNAM   IN S_UNAM   "12최종변경인.
         AND B~UDAT   IN S_UDAT                             "8변경일.
         AND B~UTME   IN S_UTME   "6최종변경시간.
         AND A~CRLSE  NE 'B'.     "입수경로가 미확인이 아닌것만.
**** HDY 20130215 START C20130213_71713 REQ.오상환
**** 스탠다드에서 입고 완료된 오더에 대해서 테이블 유지보수 하여
**** DUE LIST에 뜨지 않도록
**** HDY 20121105 START C20121026_06477 REQ.현진영
**** 미통관건 제외부분
*         AND b~ebeln  NE '4501583726'
*         AND b~ebeln  NE '4501687314'.
**** HDY 20121105 END
**** HDY 20130215 END

  IF SY-SUBRC NE 0.
    MESSAGE S902.
  ENDIF.

  DATA : L_PPMNG LIKE ZTITIVP-PPMNG,
         L_COUNT TYPE I.

  CLEAR: G_TABIX, G_COUNT, G_CNT.
  LOOP AT IT_TAB.
    G_TABIX = SY-TABIX.

********************************************************************
**> CSR : C20120222_56033 Start
********************************************************************
**> 미송장 처리일 경우.
*            IF ztitig00-igrmt EQ 'E'.
    IF P_IVCHK = 'X'.
      CLEAR L_COUNT.
      SELECT COUNT( * )
        INTO L_COUNT
        FROM ZTIVIV00
       WHERE IBLNO EQ IT_TAB-IBLNO
         AND IBLIT EQ IT_TAB-IBLIT
         AND LIVST EQ 'P'.
*--> [가온] 사전 TT는 B/L 정보 없기에 PO/ITEM으로 한번 더 체크
**** 밑에서 수량으로 한번 더 체크해서 안전
      IF S_BUKRS-LOW = '6000'.
        IF L_COUNT EQ 0.
          SELECT COUNT( * )
            INTO L_COUNT
            FROM ZTIVIV00
           WHERE EBELN EQ IT_TAB-EBELN
             AND EBELP EQ IT_TAB-EBELP
             AND LIVST EQ 'P'.
          IF L_COUNT EQ 0.
            DELETE IT_TAB INDEX G_TABIX.
            CONTINUE.
          ENDIF.
        ENDIF.
*<-- [가온] 사전 TT는 B/L 정보 없기에 PO/ITEM으로 한번 더 체크
      ELSE.
        IF L_COUNT EQ 0.
          DELETE IT_TAB INDEX G_TABIX.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.
*            ENDIF.
********************************************************************
**> CSR : C20120222_56033 End
********************************************************************


*   I/V 누적수량.
*   CC 누적수량.

**** HDY 20121120 START Q20121119_56202 REQ.오상환

**** HDY 20121105 START C20121026_06477 REQ.현진영
**** 수입 GR테이블에 데이터 확인하여 Standard에서 GR 수량 체크
*      SELECT  SINGLE *
*        FROM  ztivgr00
*       WHERE  iblno  EQ it_tab-iblno
*         AND  iccit  EQ it_tab-iblit
*         AND  rptty  EQ 'Z'.
*
*    IF SY-SUBRC = 0.
**** HDY 20121105 END
**** HDY 20121120 END

    SELECT  SUM( GRMNG )
      INTO  IT_TAB-GRMNGS
      FROM  ZTIVGR00
     WHERE  IBLNO  EQ IT_TAB-IBLNO
       AND  ICCIT  EQ IT_TAB-IBLIT
*       AND  iblit  EQ it_tab-iblit
       AND  RPTTY  EQ 'Z'.

**** HDY 20121120 START Q20121119_56202 REQ.오상환

**** HDY 20121105 START C20121026_06477 REQ.현진영
**** 수입테이블에 데이터가 없을 경우 STANDARD 테이블 조회
*    ELSE.
*    SELECT SUM( WEMNG )
*      INTO it_tab-grmngs
*      FROM EKET
*     WHERE ebeln EQ it_tab-ebeln
*       AND ebelp EQ it_tab-ebelp.
*    ENDIF.
**** HDY 20121105 END
**** HDY 20121120 END

*   I/V가능수량.
    IT_TAB-GRMNGL =  IT_TAB-BLMNG - IT_TAB-GRMNGS.
    IF IT_TAB-GRMNGL LE 0.
      DELETE IT_TAB INDEX G_TABIX.
      CONTINUE.
    ENDIF.

*   domain의 value.
    PERFORM GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING :
                           'ZTIBLDTY' IT_TAB-BLDTY  IT_TAB-BLDTYX,
                           'ZTIRPTTY' IT_TAB-RPTTY  IT_TAB-RPTTYX,
                           'ZTIFWDTY' IT_TAB-FWDTY  IT_TAB-FWDTYX,
                           'ZTINDFTY' IT_TAB-NDFTY  IT_TAB-NDFTYX.
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

*> 강재일 경우 삭제로직 추가.
    SELECT SINGLE MTART MATKL
      INTO (MARA-MTART, MARA-MATKL)
      FROM MARA
     WHERE MATNR  EQ  IT_TAB-MATNR.
    IF SY-SUBRC        EQ 0      AND
       MARA-MTART      EQ 'ROH1' AND
       ( MARA-MATKL(2) EQ '1L'   OR
         MARA-MATKL(2) EQ '1S' ).
      DELETE IT_TAB INDEX G_TABIX.
      CONTINUE.
    ENDIF.

**** HDY 20130215 START C20130213_71713 REQ.오상환
**** 스탠다드에서 입고 완료된 오더에 대해서 테이블 유지보수 하여
**** DUE LIST에 뜨지 않도록
    SELECT SINGLE EBELN EBELP
      INTO (GT_ZTITZGR-EBELN, GT_ZTITZGR-EBELP)
      FROM ZTITZGR
     WHERE EBELN EQ IT_TAB-EBELN
       AND EBELP EQ IT_TAB-EBELP.
    IF SY-SUBRC       EQ 0.
      DELETE IT_TAB INDEX G_TABIX.
      CONTINUE.
    ENDIF.
**** HDY 20130215 END

    ADD 1 TO G_COUNT.

    MODIFY IT_TAB INDEX G_TABIX.
  ENDLOOP.

  IF G_COUNT EQ 0.
    MESSAGE S902.
  ENDIF.


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
          ' ' 'REF_TABNAME'   ' ',
          ' ' 'FIELDNAME'     'BOX',
          ' ' 'HOTSPOT'       ' ',
          'E' 'KEY'           ' ',

"CC 관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'IBLNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"B/L 번호.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'BLNUM',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '27',
"발행일.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'BLDAT',
          'E' 'OUTPUTLEN'     '12',

"ETD.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'BLETD',
          'E' 'OUTPUTLEN'     '12',

"ETA.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'BLETA',
          'E' 'OUTPUTLEN'     '12',

"선기명
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'IVSLN',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '40',
"공급업체.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'LIFNR',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '12',
"공급업체.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'LIFNR',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '12',
"공급업체명
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'LFA1',
          ' ' 'OUTPUTLEN'     50,
          'E' 'FIELDNAME'     'NAME1',

*>>>>>>>>>LIST
"I/V 품목번호.
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
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '10',

"구매문서 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'EBELP',

          ' ' 'HOTSPOT'       ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '5',
"수입의뢰번호
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'REQNO',
          ' ' 'HOTSPOT'       'X',

          'E' 'KEY'           ' ',
*          'E' 'OUTPUTLEN'     '10',
"수입의뢰 품목번호
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'REQIT',
          ' ' 'NO_OUT'        'X',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '5',
"자재번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'FIELDNAME'     'MATNR',
          'E' 'OUTPUTLEN'     '20',

"자재내역.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'FIELDNAME'     'TXZ01',
          'E' 'OUTPUTLEN'     '40',

"B/L 수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'BLMNG',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'NO_OUT'        ' ',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'HOTSPOT'       ' ',
          'E' 'KEY'           ' ',
"입고수량
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISGRIT',
          ' ' 'FIELDNAME'     'GRMNGL',
          ' ' 'seltext_S'     '입고가능수량',
          ' ' 'seltext_m'     '입고가능수량',
          ' ' 'seltext_L'     '입고가능수량',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          ' ' 'HOTSPOT'       ' ',
          'E' 'OUTPUTLEN'     '16',
"단위
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'MEINS',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '3',
"최종변경인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'UNAM',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'NO_OUT'        'X',
          ' ' 'KEY'           ' ',
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

*  gs_keyinfo-header02 =  space.
*  gs_keyinfo-item02   = 'ICCIT'.
*
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

  TABLES : DFIES.
  DATA: L_TEXT20(20) TYPE C.

  CLEAR: IT_LISTHEADER, GS_LISTHEADER.
  REFRESH: IT_LISTHEADER.

* LIST HEADING LINE: TYPE H
  CLEAR GS_LISTHEADER.
  GS_LISTHEADER-TYP  = 'H'.
* gs_listheader-KEY:  NOT USED FOR THIS TYPE
  GS_LISTHEADER-INFO = '수입물품 미통관 입고 Due List'(T13).
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

  DATA: LS_HEADER TYPE TY_TAB.

  CLEAR: LS_HEADER.

  CASE R_UCOMM.
    WHEN 'REFE'.
      PERFORM P9000_DUELIST_REFRESH USING  RS_SELFIELD.

    WHEN 'ZTIT001'. " 후속기능
*> 전기처리.
      CLEAR : G_LINE, LS_HEADER.
      LOOP AT IT_HEADER WHERE BOX EQ 'X'.
        ADD 1 TO G_LINE.
        MOVE-CORRESPONDING IT_HEADER TO LS_HEADER.
      ENDLOOP.
      CASE G_LINE.
        WHEN 0.
          MESSAGE S006(0K).   EXIT.
        WHEN 1.
        WHEN OTHERS.
          MESSAGE S929.       EXIT.
      ENDCASE.

      REFRESH: IT_ZTISCCIT.
      LOOP AT IT_LIST WHERE IBLNO EQ LS_HEADER-IBLNO.
        MOVE-CORRESPONDING IT_LIST TO IT_ZTISCCIT.
        APPEND IT_ZTISCCIT.
      ENDLOOP.
      SORT IT_ZTISCCIT BY ICCNO ICCIT.

**> Call Dialog
*      CALL DIALOG 'Z_TI_GR_CREATE'
*        AND SKIP FIRST SCREEN
*        EXPORTING
*          g_tcode     FROM sy-tcode
*          it_ztisccit FROM it_ztisccit
*        IMPORTING
*          ztitgrk.
*    EXPORT ztitcsk TO MEMORY ID 'ZTIR9000'.
*> Memory Clear
      CLEAR: ZTITGRK.
      EXPORT ZTITGRK TO MEMORY ID 'ZTIR5000'.

      EXPORT G_TCODE      FROM SY-TCODE
             IT_ZTISCCIT  FROM IT_ZTISCCIT
             TO DATABASE INDX(ZM)  ID   G_INDXKEY
                                   FROM GS_INDX.

*> Call transaction
      CALL TRANSACTION 'ZTIT501' AND SKIP FIRST SCREEN.

*> build Message internal table.
      CLEAR: ZTITGRK.
      IMPORT ZTITGRK FROM MEMORY ID 'ZTIR5000'.
      FREE MEMORY ID 'ZTIR5000'.

      CLEAR: IT_ZTISCCIT, IT_ZTISCCIT[].
      EXPORT G_TCODE      FROM SPACE
             IT_ZTISCCIT  FROM IT_ZTISCCIT
             TO DATABASE INDX(ZM)  ID   G_INDXKEY
                                   FROM GS_INDX.

*> Refresh.
      IF NOT ZTITGRK-IGRNO IS INITIAL.
        PERFORM P9000_DUELIST_REFRESH USING  RS_SELFIELD.
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
        MOVE-CORRESPONDING IT_HEADER TO LS_HEADER.
      ELSEIF RS_SELFIELD-TABNAME EQ 'IT_LIST'.
        MOVE-CORRESPONDING IT_LIST   TO LS_HEADER.
      ENDIF.

      CASE RS_SELFIELD-FIELDNAME.
        WHEN 'EBELN'.
          PERFORM  DISPLAY_PURCHASE_ORDER(ZTIR0000)
                                          USING LS_HEADER-EBELN
                                                LS_HEADER-EBELP.
        WHEN 'REQNO' OR 'REQIT'.
          PERFORM  DISPLAY_IMPORT_DOCUMENT(ZTIR0000)
                                          USING LS_HEADER-REQNO
                                                SPACE
                                                LS_HEADER-REQIT.

        WHEN 'IBLNO' OR 'IBLIT'.
          PERFORM  DISPLAY_BL_DOCUMENT(ZTIR0000)
                                          USING LS_HEADER-IBLNO
                                                LS_HEADER-IBLIT.
        WHEN OTHERS.
          PERFORM  DISPLAY_BL_DOCUMENT(ZTIR0000)
                                          USING LS_HEADER-IBLNO
                                                LS_HEADER-IBLIT.
      ENDCASE.
    WHEN OTHERS.
  ENDCASE.

  CLEAR: R_UCOMM.

ENDFORM.                    "USER_COMMAND
*---------------------------------------------------------------------*
*       FORM PF_STATUS_SET                                            *
*---------------------------------------------------------------------*
FORM PF_STATUS_SET USING RT_EXTAB TYPE SLIS_T_EXTAB.

  SET TITLEBAR 'T1000' WITH 'Due List'(T10).

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
*SET PF-STATUS 'ABCD' OF PROGRAM PROG.

ENDFORM.                    "PF_STATUS_SET
*&---------------------------------------------------------------------*
*&      Form  p1100_check_input_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P1100_CHECK_INPUT_VALUES .

  DATA: L_BUKRS LIKE T001-BUKRS,
        L_WERKS LIKE T001W-WERKS,
        L_MATNR LIKE MARA-MATNR,
        L_MTART LIKE T134-MTART,
        L_EBELN LIKE EKKO-EBELN,
        L_LIFNR LIKE LFA1-LIFNR,
        L_EKORG LIKE T024E-EKORG,
        L_EKGRP LIKE T024-EKGRP.

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
