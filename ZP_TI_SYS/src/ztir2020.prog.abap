************************************************************************
* Title         :  ZTIR2020                                            *
*                                                                      *
* Description   : [Report] B/L 현황                                    *
*                                                                      *
* Creation Date : 2004/02/07                                           *
*                                                                      *
* Author        : Seung Jun, Lee                                       *
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
* dd-mmm-yyyy  xxxxxxxxxxxxxxx  DVPK9xxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  *
*                                                                      *
* 20200715     박성수          CHM2007-00376 관세환급가능잔여일 추가   *
* 2021.02.25    박성수    CHM2102-00450   원산지증명서 발급여부 추가   *
************************************************************************
REPORT  ZTIR2020       MESSAGE-ID ZMTI00
                       NO STANDARD PAGE HEADING.


************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ZTS_REUSE_ALVFORMS_T00.  " > AVL 공용 Data 선언.

INCLUDE ZTS_REUSE_BDC_SUBROUTINE_F00. "> bdc용.
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
            NAME1       LIKE LFA1-NAME1,
            BLETD       LIKE ZTITBLK-BLETD,  "ETD(출발 예정 시각).
            BLETA       LIKE ZTITBLK-BLETA,  "ETA(도착 예정 시각).
            FWDTY       LIKE ZTITBLK-FWDTY,  "운송 방법.
            FWDTYX(20)  TYPE C,	           "운송 방법TEXT.
            LPONR       LIKE ZTITBLK-LPONR,  "최종품목번호.
            WAERS       LIKE ZTITBLK-WAERS,  "통화키.
            TREFWR      LIKE ZTITBLP-REFWR,  "total 금액.
            CRLSE       LIKE ZTITBLK-CRLSE,
            CRLSEX(20)  TYPE C,
            LGAYN       LIKE ZTITBLK-LGAYN,  "LG대상여부.
*--> LG전선에서 추가. by MSH
            INPDT       LIKE ZTITBLK-INPDT,  "입항예정일.
            OJRDT       LIKE ZTITBLK-OJRDT,  "원본입수일.
            BLAYN       LIKE ZTITBLK-BLAYN,  "원본입수여부.
            BLAYNX(10)  TYPE C,
            CDPDT       LIKE ZTITBLK-CDPDT.  "통관예정일.
*            ZCOTY       LIKE ZTITBLP-ZCOTY,  "원산지증명서 제출여부
*            ZCOTYX(25)  TYPE C.
*            CDDAY       TYPE I.     "CHM2007-00376 관세환급가능일

TYPES: END OF TY_HEADER.

TYPES: BEGIN OF TY_ITEM.
INCLUDE     TYPE        TY_HEADER.
TYPES :     IBLIT       LIKE ZTITBLP-IBLIT,  "B/L 품목번호.
            NDFTY       LIKE ZTITBLP-NDFTY,  "무환품 종류.
            NDFTYX(20)  TYPE C,              "무환품 종류TEXT.
            BLMNG       LIKE ZTITBLP-BLMNG,  "B/L 수량.
            REFWR       LIKE ZTITBLP-REFWR,  "송장값 (외화).
            MEINS       LIKE ZTITBLP-MEINS,  "기본단위.
            EBELN       LIKE ZTITBLP-EBELN,  "구매전표번호.
            EBELP       LIKE ZTITBLP-EBELP,  "구매문서 품목번호.
            REQNO       LIKE ZTITBLP-REQNO,  "수입의뢰 관리번호.
            REQIT       LIKE ZTITBLP-REQIT,  "수입의뢰 품목번호.
            CNAM        LIKE ZTITBLP-CNAM,   "작성인.
            CDAT        LIKE ZTITBLP-CDAT,   "생성일.
            CTME        LIKE ZTITBLP-CTME,   "생성시간.
            UNAM        LIKE ZTITBLP-UNAM,   "최종변경인.
            UDAT        LIKE ZTITBLP-UDAT,   "변경일.
            UTME        LIKE ZTITBLP-UTME,   "최종변경시간.
            POMNG       LIKE ZTISBLIT-MENGE, "p/o수량.
            MENGE       LIKE ZTISBLIT-MENGE,
            BLMNGS      LIKE ZTISBLIT-BLMNGS,
            BLMNGL      LIKE ZTISBLIT-BLMNGL,
            WERKS       LIKE ZTISBLIT-WERKS,
            NAME2       LIKE ZTISBLIT-NAME1,
            MATNR       LIKE ZTISBLIT-MATNR,
            TXZ01       LIKE ZTISBLIT-TXZ01,
            EEIND       LIKE ZTISBLIT-EEIND,
            NETPR       LIKE ZTISBLIT-NETPR,
            PEINH       LIKE ZTISBLIT-PEINH,
            NETWR       LIKE ZTISBLIT-NETWR,
*<CHM2007-00376
            ZCOTY       LIKE ZTITBLP-ZCOTY,  "원산지증명서 제출여부
            ZCOTYX(25)  TYPE C,
            CDDAY       TYPE I.     " 관세환급가능일.
*>CHM2007-00376
TYPES: END OF TY_ITEM.


TYPES: BEGIN OF TY_LIST.
INCLUDE             TYPE        TY_ITEM.
TYPES:      COLOR   TYPE SLIS_T_SPECIALCOL_ALV.
TYPES: END OF TY_LIST.

*> Select용.
TYPES: BEGIN OF TY_TAB.
INCLUDE     TYPE        TY_ITEM.
TYPES: END OF TY_TAB.

DATA : OK_CODE       TYPE SY-UCOMM.
DATA : GV_ZCOTY      TYPE ZECOTY,
       GV_ANSWER(1)  TYPE C.
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
        ZTITBLP.

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES: ZTIVPO00,    ">Purchasing Document : Header + Items
        ZTIVRQ00.    ">수입의뢰 Views(Header + Items + status)

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
*DATA : BEGIN OF it_ZTItig02 OCCURS 0.
*        INCLUDE STRUCTURE ZTItig02.
*DATA : END   OF it_ZTItig02.
*
DATA: IT_ZTITIG02  TYPE ZTITIG02  OCCURS 0 WITH HEADER LINE.
DATA: IT_LIST      TYPE TY_LIST   OCCURS 0 WITH HEADER LINE.
DATA: IT_HEADER    TYPE TY_HEADER OCCURS 0 WITH HEADER LINE.
DATA: IT_TAB       TYPE TY_TAB    OCCURS 0 WITH HEADER LINE.

*<<CHM2007-00376
DATA: BEGIN OF GT_RECV OCCURS 0,
        BNAME               LIKE USR21-BNAME,
        SMTP_ADDR           LIKE ADR6-SMTP_ADDR,
      END   OF GT_RECV.
DATA: GT_MESSAGE            TYPE BCSY_TEXT,
      GV_SEND_RESULT        TYPE C,
      G_RECEIVER            TYPE REF TO IF_RECIPIENT_BCS,
      G_EMAIL               TYPE REF TO CL_BCS,
      G_EMAIL_BODY          TYPE REF TO CL_DOCUMENT_BCS,
      G_SENDER              TYPE REF TO IF_SENDER_BCS,
      G_EXCEPTION           TYPE REF TO CX_BCS,
      GV_ADDRESS            TYPE AD_SMTPADR,
      GT_FTEXT              TYPE LVC_TXTCOL OCCURS 0,
      GV_HDTITLE(40)        TYPE C,
      GV_SUBJECT            TYPE SO_OBJ_DES.
DEFINE MAIL_MSG.
  APPEND &1 TO GT_MESSAGE.
END-OF-DEFINITION.
*>>"CHM2007-00376

************************************************************************
* DATA Declarations                                                    *
************************************************************************

************************************************************************
** RANGES
************************************************************************
*--> LG전선에서 변경. by MSH
*RANGES: gr_crlse   FOR   ztitblk-crlse OCCURS 1.
RANGES: GR_BLAYN   FOR   ZTITBLK-BLAYN OCCURS 1.
*---------------------------------------------------------------------*
*> Message dialog box용                                               *
*---------------------------------------------------------------------*
DATA: BEGIN OF IT_MSG  OCCURS 0.
        INCLUDE STRUCTURE ZTISMESSAGE.
DATA: END   OF IT_MSG.
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
  S_BUKRS  FOR ZTITRQK-BUKRS 	"회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID BUK
                    MODIF  ID IOG ,
  S_EKORG  FOR ZTITBLK-EKORG MODIF ID IOG,                  "4구매조직.
  S_EKGRP  FOR ZTITBLK-EKGRP MODIF ID IOG,                  "3구매그룹.
  S_WERKS  FOR ZTITBLP-WERKS MODIF ID ZCO
                             MEMORY ID ZCO,
  S_EBELN  FOR ZTITBLP-EBELN MODIF ID IOG,  "10구매전표번호.
  S_IBLNO  FOR ZTITBLK-IBLNO MODIF ID IOG	"B/L 관리번호.
                              MEMORY ID ZTIIBLNO,

  S_REQNO  FOR ZTITBLP-REQNO MODIF ID IOG,  "10수입의뢰 관리번호.
  S_BLNUM  FOR ZTITBLK-BLNUM MODIF ID IOG,  "25B/L 번호.
  S_BLDTY  FOR ZTITBLK-BLDTY MODIF ID IOG,                  "1문서종류.
  S_RPTTY  FOR ZTITBLK-RPTTY MODIF ID IOG.  "1수입신고구분.

SELECTION-SCREEN ULINE.
*--> 대우조선 특화된 프로세스임. by MSH
*PARAMETERS: p_step1 RADIOBUTTON GROUP ab1,
*            p_step2 RADIOBUTTON GROUP ab1,
*            p_step3 RADIOBUTTON GROUP ab1,
*            p_step4 RADIOBUTTON GROUP ab1 DEFAULT 'X'.
*--> LG전선에서 추가. by MSH
PARAMETERS: P_ORI RADIOBUTTON GROUP AB1,
            P_DUP RADIOBUTTON GROUP AB1,
            P_ALL RADIOBUTTON GROUP AB1 DEFAULT 'X'.
*--> End of Modification.
SELECTION-SCREEN ULINE.

SELECT-OPTIONS:
  S_LIFNR  FOR ZTITBLK-LIFNR MODIF ID IOG,  "10공급업체 계정번호.
  S_BLETD  FOR ZTITBLK-BLETD MODIF ID IOG,  "8ETD(출발 예정 시각).
  S_BLETA  FOR ZTITBLK-BLETA MODIF ID IOG,  "8ETA(도착 예정 시각).
  S_FWDTY  FOR ZTITBLK-FWDTY MODIF ID IOG,  "1운송 방법.
  S_LPONR  FOR ZTITBLK-LPONR MODIF ID IOG,  "5최종품목번호.
  S_WAERS  FOR ZTITBLK-WAERS MODIF ID IOG,                  "5통화키.
  S_LGAYN  FOR ZTITBLK-LGAYN MODIF ID IOG,      "LG대상여부.
  S_IBLIT  FOR ZTITBLP-IBLIT MODIF ID IOG,  "5B/L 품목번호.
  S_ZCOTY  FOR ZTITBLP-ZCOTY MODIF ID ZCO
                             MEMORY ID ZCO,
  S_NDFTY  FOR ZTITBLP-NDFTY MODIF ID IOG,  "1무환품 종류.
  S_BLMNG  FOR ZTITBLP-BLMNG MODIF ID IOG,  "13B/L 수량.
  S_REFWR  FOR ZTITBLP-REFWR MODIF ID IOG,  "13송장값 (외화).
  S_MEINS  FOR ZTITBLP-MEINS MODIF ID IOG,                  "3기본단위.
  S_EBELP  FOR ZTITBLP-EBELP MODIF ID IOG,  "5구매문서 품목번호.
  S_REQIT  FOR ZTITBLP-REQIT MODIF ID IOG,  "5수입의뢰 품목번호.
*  s_mblnr  FOR ZTITBLP-mblnr MODIF ID iog,	"10자재문서번호.
*  s_mjahr  FOR ZTITBLP-mjahr MODIF ID iog,	"4자재문서연도.
*  s_zeile  FOR ZTITBLP-zeile MODIF ID iog,	"4자재문서품목.
  S_CNAM   FOR ZTITBLP-CNAM  MODIF ID IOG,                  "12작성인.
  S_CDAT   FOR ZTITBLP-CDAT  MODIF ID IOG,                  "8생성일.
  S_CTME   FOR ZTITBLP-CTME  MODIF ID IOG,                  "6생성시간.
  S_UNAM   FOR ZTITBLP-UNAM  MODIF ID IOG,  "12최종변경인.
  S_UDAT   FOR ZTITBLP-UDAT  MODIF ID IOG,                  "8변경일.
  S_UTME   FOR ZTITBLP-UTME  MODIF ID IOG.  "6최종변경시간.

SELECTION-SCREEN END OF BLOCK DBSEL.

SELECTION-SCREEN BEGIN OF BLOCK LISTS WITH FRAME TITLE TEXT-002.
PARAMETERS: P_VARI LIKE DISVARIANT-VARIANT,
            P_ITEM TYPE C AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK LISTS.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ZTS_REUSE_ALVFORMS_F00.  "> ALV 공용 Subroutines.
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

AT SELECTION-SCREEN OUTPUT .
  PERFORM SET_SCREEN_FIELD.

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
**> 지급조건 HELP(Low values)
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_zterm-low.
*  PERFORM get_f4_for_zterm(ZTIr0000) USING s_zterm-low.
**> 지급조건 HELP(High values)
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_zterm-high.
*  PERFORM get_f4_for_zterm(ZTIr0000) USING s_zterm-high.

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

    IF SY-BATCH = 'X'.
      PERFORM SEND_MAIL_BATCH.
    ELSE.
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

*> Program 종료.
      PERFORM  P9000_PROGRAM_EXIT.
    ENDIF.
  ENDIF.



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

  SET TITLEBAR 'T1000' WITH '현황 List'(T10).

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
  DATA: LV_DATE  LIKE SY-DATUM. "CHM2007-00376
  DATA: LV_DDAY  TYPE I. "CHM2007-00376

  CLEAR: G_COUNT, IT_TAB, IT_ZTITIG02, IT_HEADER, IT_LIST.
  REFRESH : IT_TAB, IT_ZTITIG02, IT_HEADER, IT_LIST.
*> PROGRESS Display.
  G_LINEN    = 30.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

*--> LG전선에서 변경(원본 입수여부로 대체). by MSH
*  CLEAR gr_crlse .
*  MOVE: 'I'     TO    gr_crlse-sign,
*        'EQ'    TO    gr_crlse-option.
  CLEAR GR_BLAYN .
  MOVE: 'I'     TO    GR_BLAYN-SIGN,
        'EQ'    TO    GR_BLAYN-OPTION.
*----------------------------------------------------------------------
*	구매담당 입력
*B  ASP 인터페이스(미확인)
*C  ASP 인터페이스 후 구매담당 확인
*----------------------------------------------------------------------
*  CASE 'X'.
*    WHEN p_step1.  ">구매담당 입력
*      MOVE: space TO  gr_crlse-low.    APPEND gr_crlse .
*    WHEN p_step2. ">ASP 인터페이스(미확인)
*      MOVE: 'B'   TO  gr_crlse-low.    APPEND gr_crlse .
*    WHEN p_step3. ">ASP 인터페이스 후 구매담당 확인
*      MOVE: 'C'   TO  gr_crlse-low.    APPEND gr_crlse .
*    WHEN p_step4. ">all
*      CLEAR gr_crlse.
*  ENDCASE.
*----------------------------------------------------------------------
*O  원본 B/L
*D  사본 B/L
*----------------------------------------------------------------------
  CASE 'X'.
    WHEN P_ORI. ">원본 B/L
      MOVE: 'O'   TO  GR_BLAYN-LOW.    APPEND GR_BLAYN .
    WHEN P_DUP. ">사본 B/L
      MOVE: 'D'   TO  GR_BLAYN-LOW.    APPEND GR_BLAYN .
    WHEN P_ALL. ">all
      CLEAR GR_BLAYN.
  ENDCASE.
*--> End of Modification.

*> B/L 데이타 select.
  SELECT *
        INTO CORRESPONDING FIELDS OF TABLE IT_TAB
        FROM ZTITBLK AS A JOIN ZTITBLP AS B
          ON A~IBLNO EQ B~IBLNO
*       WHERE a~crlse  IN gr_crlse "ASP 여부.
       WHERE A~BLAYN  IN GR_BLAYN "원본입수여부
         AND A~BUKRS  IN S_BUKRS  "회사코드.
         AND A~IBLNO  IN S_IBLNO
         AND A~BLNUM  IN S_BLNUM  "25B/L 번호.
         AND A~BLDTY  IN S_BLDTY                            "1문서종류.
         AND A~RPTTY  IN S_RPTTY  "1수입신고구분.
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
         AND B~WERKS  IN S_WERKS
         AND B~ZCOTY  IN S_ZCOTY
         AND B~NDFTY  IN S_NDFTY  "1무환품 종류.
         AND B~BLMNG  IN S_BLMNG  "13B/L 수량.
         AND B~REFWR  IN S_REFWR  "13송장값 (외화).
         AND B~MEINS  IN S_MEINS                            "3기본단위.
         AND B~EBELN  IN S_EBELN  "10구매전표번호.
         AND B~EBELP  IN S_EBELP  "5구매문서 품목번호.
         AND B~REQNO  IN S_REQNO  "10수입의뢰 관리번호.
         AND B~REQIT  IN S_REQIT  "5수입의뢰 품목번호.
*         AND b~mblnr  IN s_mblnr  "10자재문서번호.
*         AND b~mjahr  IN s_mjahr  "4자재문서연도.
*         AND b~zeile  IN s_zeile  "4자재문서품목.
         AND B~CNAM   IN S_CNAM                             "12작성인.
         AND B~CDAT   IN S_CDAT                             "8생성일.
         AND B~CTME   IN S_CTME                             "6생성시간.
         AND B~UNAM   IN S_UNAM   "12최종변경인.
         AND B~UDAT   IN S_UDAT                             "8변경일.
         AND B~UTME   IN S_UTME.  "6최종변경시간.

  IF SY-SUBRC NE 0.
    MESSAGE S902.
  ENDIF.

  CLEAR: G_TABIX, G_COUNT, G_CNT.
  LOOP AT IT_TAB.
    G_TABIX = SY-TABIX.
*   domain의 value.
    PERFORM GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING :
*                           'ZTICRLSE' it_tab-crlse  it_tab-crlsex,
                           'ZTIBLAYN' IT_TAB-BLAYN  IT_TAB-BLAYNX,
                           'ZTIBLDTY' IT_TAB-BLDTY  IT_TAB-BLDTYX,
                           'ZTIRPTTY' IT_TAB-RPTTY  IT_TAB-RPTTYX,
                           'ZTIFWDTY' IT_TAB-FWDTY  IT_TAB-FWDTYX,
                           'ZTINDFTY' IT_TAB-NDFTY  IT_TAB-NDFTYX,
                           'ZDCOTY'   IT_TAB-ZCOTY  IT_TAB-ZCOTYX.
*   공급업체.
    SELECT SINGLE NAME1 INTO IT_TAB-NAME1
      FROM LFA1
     WHERE LIFNR EQ IT_TAB-LIFNR.

*   p/o정보.
    SELECT  SINGLE MENGE WERKS MATNR TXZ01
      INTO  (IT_TAB-POMNG, IT_TAB-WERKS, IT_TAB-MATNR, IT_TAB-TXZ01)
      FROM  ZTIVPO00
     WHERE  EBELN  = IT_TAB-EBELN
       AND  EBELP  = IT_TAB-EBELP.

    IF IT_TAB-REQNO IS NOT INITIAL.
*   수입의뢰 정보 수량.
      SELECT  SINGLE RQMNG
        INTO  IT_TAB-MENGE
        FROM  ZTIVRQ00
       WHERE  REQNO  = IT_TAB-REQNO
         AND  REQIT  = IT_TAB-REQIT.

*   b/l 누적수량.
      SELECT  SUM( BLMNG ) INTO IT_TAB-BLMNGS FROM ZTITBLP
       WHERE  REQNO  = IT_TAB-REQNO
         AND  REQIT  = IT_TAB-REQIT.
    ENDIF.

*   b/l 가능수량.
    IT_TAB-BLMNGL =  IT_TAB-MENGE - IT_TAB-BLMNGS.

    MOVE IT_TAB-REFWR TO IT_TAB-TREFWR.

*<< CHM2007-00376 "관세환급 가능 잔여일 계산 (수입신고일 +1년 = D-DAY)
*    AT END OF IBLNO.
    IF S_BUKRS-LOW = '1000'.
      IF IT_TAB-ZCOTY = 'D' OR
         IT_TAB-ZCOTY = 'K'.

        CLEAR LV_DATE.
        CLEAR LV_DDAY.
        SELECT SINGLE CDCDT
          INTO LV_DATE
          FROM ZTITCRK
         WHERE IBLNO = IT_TAB-IBLNO
           AND ICCSQ = ( SELECT MAX( ICCSQ )
                           FROM ZTITCRK
                           WHERE IBLNO = IT_TAB-IBLNO ).

        CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
          EXPORTING
            DATE      = LV_DATE
            DAYS      = '00'
            MONTHS    = '00'
            SIGNUM    = '+'
            YEARS     = '01'
          IMPORTING
            CALC_DATE = LV_DATE.


        CALL FUNCTION 'FIMA_DAYS_AND_MONTHS_AND_YEARS'
          EXPORTING
            I_DATE_FROM          =   SY-DATUM
*          I_KEY_DAY_FROM       =
            I_DATE_TO            =   LV_DATE
*          I_KEY_DAY_TO         =
*          I_FLG_SEPARATE       = ' '
          IMPORTING
            E_DAYS               =   LV_DDAY
*          E_MONTHS             =
*          E_YEARS              =
          .
        IT_TAB-CDDAY = LV_DDAY.

      ENDIF.
    ENDIF.
*    ENDAT.

*>> CHM2007-00376


    ADD 1 TO G_COUNT.

    MODIFY IT_TAB INDEX G_TABIX.

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
"B/L번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
*          ' ' 'seltext_m'     'BLNUM',
          ' ' 'FIELDNAME'     'BLNUM',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '31',
"문서상태
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '문서상태',
          ' ' 'FIELDNAME'     'BLDTYX',
          'E' 'OUTPUTLEN'     '10',
"공급업체.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'LFA1',
*          ' ' 'seltext_m'     '공급업체명',
          ' ' 'FIELDNAME'     'LIFNR',
          'E' 'OUTPUTLEN'     '15',
"공급업체명.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '공급업체명',
          ' ' 'FIELDNAME'     'NAME1',
          'E' 'OUTPUTLEN'     '30',
"원본입수여부.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '원본여부',
          ' ' 'FIELDNAME'     'BLAYNX',
          'E' 'OUTPUTLEN'     '11',
"ETD
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'FIELDNAME'     'BLETD',
          'E' 'OUTPUTLEN'     '11',
"ETA
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
*          ' ' 'seltext_m'     '',
          ' ' 'FIELDNAME'     'BLETA',
          'E' 'OUTPUTLEN'     '11',
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
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'FWDTYX',
          'E' 'OUTPUTLEN'     '10',
"수입신고구분
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '신고구분',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'RPTTYX',
          'E' 'OUTPUTLEN'     '14',

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
"수입신고구분
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '입력주체',
          ' ' 'NO_OUT'        'X',
          ' ' 'FIELDNAME'     'CRLSEX',
          'E' 'OUTPUTLEN'     '14',
**<<CHM2007-00376
*          'S' 'TABNAME'       'IT_HEADER',
**          ' ' 'REF_TABNAME'   'ZTITBLK',
*          ' ' 'seltext_m'     '관세환급 가능 잔여일',
*          ' ' 'seltext_l'     '관세환급 가능 잔여일',
**          ' ' 'NO_OUT'        'X',
*          ' ' 'FIELDNAME'     'CDDAY',
*          ' ' 'NO_ZERO'       'X',
*          'E' 'OUTPUTLEN'     '20',
**>>CHM2007-00376


*>>>>>>>>>LIST
"B/L 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'IBLIT',
          ' ' 'HOTSPOT'       'X',
*          ' ' 'CONVEXIT'      'ALPHA',
          ' ' 'INTLEN'         10,
          ' ' 'JUST'          'L',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"수입의뢰번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'REQNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '10',
"수입의뢰 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'REQIT',
          'E' 'OUTPUTLEN'     '4',
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
          'E' 'OUTPUTLEN'     '4',
"종류.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'seltext_m'     '유무환',
          ' ' 'FIELDNAME'     'NDFTYX',
          'E' 'OUTPUTLEN'     '10',
"자재번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'FIELDNAME'     'MATNR',
          'E' 'OUTPUTLEN'     '15',
"자재내역.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'FIELDNAME'     'TXZ01',
          ' ' 'NO_OUT'        ' ',
          'E' 'OUTPUTLEN'     '30',
"원본입수일.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'seltext_m'     '원본입수일',
          ' ' 'FIELDNAME'     'OJRDT',
          'E' 'OUTPUTLEN'     '11',
"P/O수량
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'seltext_m'     'P/O 수량',
          ' ' 'QTABNAME'       'IT_LIST',
          ' ' 'QFIELDNAME'     'MEINS',
          ' ' 'FIELDNAME'     'POMNG',
          ' ' 'NO_OUT'        'X',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '15',
"수입의뢰수량
          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'QTABNAME'       'IT_LIST',
          ' ' 'QFIELDNAME'     'MEINS',
          ' ' 'seltext_m'     '수입의뢰수량',
          ' ' 'FIELDNAME'     'MENGE',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'NO_OUT'        'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '15',
"B/L가능수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'QTABNAME'       'IT_LIST',
          ' ' 'QFIELDNAME'     'MEINS',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'FIELDNAME'     'BLMNGL',
          ' ' 'NO_OUT'        'X',
          ' ' 'HOTSPOT'       ' ',
          'E' 'KEY'           ' ',
"B/L누적수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'QTABNAME'       'IT_LIST',
          ' ' 'QFIELDNAME'     'MEINS',
          ' ' 'FIELDNAME'     'BLMNGS',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'NO_OUT'        'X',
          'E' 'KEY'           ' ',
"B/L수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISBLIT',
          ' ' 'QTABNAME'       'IT_LIST',
          ' ' 'QFIELDNAME'     'MEINS',
          ' ' 'FIELDNAME'     'BLMNG',
          ' ' 'HOTSPOT'       ' ',
          ' ' 'OUTPUTLEN'     '11',
          'E' 'KEY'           ' ',
"기본단위
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLP',
          ' ' 'FIELDNAME'     'MEINS',
          ' ' 'INTLEN'         10,
          'E' 'OUTPUTLEN'     '4',
"송장금액.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'seltext_m'     '송장값 (외화)',
          ' ' 'FIELDNAME'     'REFWR',
          ' ' 'CFIELDNAME'    'WAERS',
          ' ' 'CTABNAME'      'IT_HEADER',
          ' ' 'NO_OUT'        ' ',
          'E' 'OUTPUTLEN'     '21',
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
          'E' 'OUTPUTLEN'     '10',

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

*<<CHM2007-00376
  IF S_BUKRS-LOW = '1000'.
    "원산지 증명서 제출여부
    PERFORM 3010_FILL_FIELD_CATEGORY USING :
    'S' 'TABNAME'       'IT_LIST',
    ' ' 'seltext_m'     '원산지 증명서 제출',
    ' ' 'FIELDNAME'     'ZCOTYX',
    'E' 'OUTPUTLEN'     '25',

    "관세환급 가능 D-day
    'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTITBLK',
    ' ' 'seltext_m'     '관세환급 가능 잔여일',
    ' ' 'seltext_l'     '관세환급 가능 잔여일',
*          ' ' 'NO_OUT'        'X',
    ' ' 'FIELDNAME'     'CDDAY',
    ' ' 'NO_ZERO'       'X',
    'E' 'OUTPUTLEN'     '20'.
*>>CHM2007-00376
  ENDIF.


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
  GS_LISTHEADER-INFO = 'B/L 현황 List'(T13).
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

* STATUS LINE:  TYPE S
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


  DATA: LS_LIST   TYPE TY_TAB,
        LS_HEADER TYPE TY_HEADER.

  DATA: L_SUBRC   LIKE SY-SUBRC.

  CLEAR: LS_LIST,LS_HEADER.

  CASE R_UCOMM.
    WHEN '&REFRESH'.
      PERFORM P9000_DUELIST_REFRESH USING  RS_SELFIELD.

*--> 대우조선에 특화됨(LG전선 사용안함). by MSH
*    WHEN 'ZTICONFIRM' OR 'ZTICONFIRC'. "선적서류 확인/취소.
*      CLEAR: g_line.
*      LOOP AT it_header WHERE box EQ 'X'.
*        ADD 1 TO g_line.
*      ENDLOOP.
*      IF g_line EQ 0.
*        MESSAGE s903.
*      ELSE.
****************
*        REFRESH: bdcdata, it_msg.
*        CLEAR: session.
*        ctu_params-dismode  = 'N'. ">처리모드
*        ctu_params-updmode  = 'S'. ">갱신모드
*        ctu_params-cattmode = ' '. ">CATT 모드...
*        ctu_params-defsize  = ' '. ">기본화면 크기
*        ctu_params-racommit = 'X'.
*        ctu_params-nobinpt  = ' ' .
*        ctu_params-nobiend  = ' '.
****************
*        LOOP AT it_header WHERE box EQ 'X'.
**> 초기화면.
*            PERFORM bdc_dynpro_build USING :
*                   'X' 'ZTIR0000'          '0200',
*                   ' ' 'ZTISSCRCOM-REQNO'  <l_field1>,
*                   ' ' 'ZTISSCRCOM-AMDSQ'  <l_field2>,
**                   ' ' 'ZTISSCRCOM-EBELN'  space,
**                   ' ' 'ZTISSCRCOM-OPNNO'  space,
*                   ' ' 'BDC_OKCODE'       '=ZTIENTER'.
**> 세부화면.
*            PERFORM bdc_dynpro_build USING :
*                   'X' 'ZTIR0000'          '2000'.
*
*            IF r_ucomm EQ 'ZTIT002'.       ">의뢰요청.
*              PERFORM bdc_dynpro_build USING :
*                     ' ' 'BDC_OKCODE'       '=ZTIREQUEST'.
*            ELSEIF r_ucomm EQ 'ZTIT005'.   ">접수.
*              PERFORM bdc_dynpro_build USING :
*                     ' ' 'BDC_OKCODE'       '=ZTIACCEPT'.
*            ELSEIF r_ucomm EQ 'ZTIT006'.   ">신청.
*              PERFORM bdc_dynpro_build USING :
*                     ' ' 'BDC_OKCODE'       '=ZTISEND'.
*            ENDIF.
*
*            PERFORM bdc_dynpro_build USING :
*                   'X' 'SAPLSPO1'          '0300',
*                   ' ' 'BDC_OKCODE'       '=YES'.
*
*          PERFORM bdc_transaction USING 'ZTIT202' l_subrc.
*
*            IF l_subrc EQ 0.
*              IF r_ucomm EQ 'ZTIT002'.
*                MESSAGE s121 WITH <l_field1>.
*              ELSEIF r_ucomm EQ 'ZTIT005'.
*                MESSAGE s122 WITH <l_field1>.
*              ELSEIF r_ucomm EQ 'ZTIT006'.
*                MESSAGE s123 WITH <l_field1>.
*              ENDIF.
*              MOVE:  sy-msgid   TO  it_msg-msgid,
*                     sy-msgty   TO  it_msg-msgty,
*                     sy-msgno   TO  it_msg-msgno,
*                     sy-msgv1   TO  it_msg-msgv1,
*                     sy-msgv2   TO  it_msg-msgv2,
*                     sy-msgv3   TO  it_msg-msgv3,
*                     sy-msgv4   TO  it_msg-msgv4,
*                     <l_field1> TO  it_msg-refno.
*              APPEND it_msg.
*            ELSE.
*              LOOP AT messtab WHERE msgtyp EQ 'E'.
*                MOVE : messtab-msgtyp  TO it_msg-msgty,
*                       messtab-msgid   TO it_msg-msgid,
*                       messtab-msgnr   TO it_msg-msgno,
*                       messtab-msgv1   TO it_msg-msgv1,
*                       messtab-msgv2   TO it_msg-msgv2,
*                       messtab-msgv3   TO it_msg-msgv3,
*                       messtab-msgv4   TO it_msg-msgv4,
*                       <l_field1>      TO it_msg-refno.
*                APPEND it_msg.
*              ENDLOOP.
*              IF sy-subrc NE 0.
*                MESSAGE s926.
*                MOVE:  sy-msgid   TO  it_msg-msgid,
*                       'E'        TO  it_msg-msgty,
*                       sy-msgno   TO  it_msg-msgno,
*                       sy-msgv1   TO  it_msg-msgv1,
*                       sy-msgv2   TO  it_msg-msgv2,
*                       sy-msgv3   TO  it_msg-msgv3,
*                       sy-msgv4   TO  it_msg-msgv4,
*                       <l_field1> TO  it_msg-refno.
*                APPEND it_msg.
*              ENDIF.
*            ENDIF.
*        ENDLOOP.
*        DESCRIBE TABLE it_msg LINES g_line.
*        IF g_line GT 0.
*          CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
*            EXPORTING
*              xdocno_show = 'X'
*            TABLES
*              xmsg        = it_msg.
*        ENDIF.
*      ENDIF.
*--> End of Modification

    WHEN 'ZTIT202'. "B/L 변경.

      CLEAR : G_LINE, LS_LIST.
      LOOP AT IT_HEADER WHERE BOX EQ 'X'.
        ADD 1 TO G_LINE.
        MOVE-CORRESPONDING IT_HEADER TO LS_HEADER.
      ENDLOOP.
      CASE G_LINE.
        WHEN 0.
          MESSAGE S003(OK). EXIT.
        WHEN 1.
          SET PARAMETER ID 'ZTIIBLNO' FIELD LS_HEADER-IBLNO.
          SET PARAMETER ID 'ZTIBLNUM' FIELD SPACE.
          CALL TRANSACTION 'ZTIT202' AND SKIP FIRST SCREEN .
        WHEN OTHERS.
          MESSAGE S035(0K).   EXIT.
      ENDCASE.

      SET PARAMETER ID 'ZTIIBLNO' FIELD SPACE.
      SET PARAMETER ID 'ZTIBLNUM' FIELD SPACE.
*      perform p9000_duelist_refresh USING  rs_selfield.
***********************************
*    > 검색조건에 해당하는 데이타를 Select.
      PERFORM P2000_DATA_SELECTIONS.
*    > Header table과 List(Items) table를 만듬.
      PERFORM P2100_HEADER_AND_LIST_BUILD.
      DESCRIBE TABLE IT_TAB LINES G_LINE.
      IF NOT G_LINE IS INITIAL.
        RS_SELFIELD-REFRESH = 'X'.
      ELSE.
*    > Program 종료.
        PERFORM  P9000_PROGRAM_EXIT.
      ENDIF.
***********************************

      RS_SELFIELD-REFRESH = 'X'.
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
        WHEN 'EBELN'.
          PERFORM  DISPLAY_PURCHASE_ORDER(ZTIR0000)
                                          USING LS_LIST-EBELN
                                                LS_LIST-EBELP.
        WHEN 'REQNO' OR 'REQIT'.
          PERFORM  DISPLAY_IMPORT_DOCUMENT(ZTIR0000)
                                          USING LS_LIST-REQNO
                                                SPACE
                                                LS_LIST-REQIT.

        WHEN 'IBLNO' OR 'IBLIT'.
          PERFORM  DISPLAY_BL_DOCUMENT(ZTIR0000)
                                          USING LS_LIST-IBLNO
                                                LS_LIST-IBLIT.

      ENDCASE.

    WHEN 'ZCOTY'.
      CLEAR : GV_ANSWER, GV_ZCOTY.
      DATA: LV_BNAME LIKE ZTITBLNAM-BNAME.

      READ TABLE IT_HEADER WITH KEY BOX = 'X'.

      IF SY-SUBRC = 0.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            TITLEBAR              = '원산지증명서 제출여부'
            TEXT_QUESTION         = '변경 하시겠습니까?'
            TEXT_BUTTON_1         = '확인'
            ICON_BUTTON_1         = 'ICON_OKAY'
            TEXT_BUTTON_2         = '취소'
            ICON_BUTTON_2         = 'ICON_CANCEL'
            DEFAULT_BUTTON        = '2'            "Default Button: 취소
            DISPLAY_CANCEL_BUTTON = ' '
            POPUP_TYPE            = 'ICON_MESSAGE_QUESTION'
          IMPORTING
            ANSWER                = GV_ANSWER
          EXCEPTIONS
            TEXT_NOT_FOUND        = 1
            OTHERS                = 2.

        IF GV_ANSWER = '1'.
          CALL SCREEN 100 STARTING  AT  25 5.
        ENDIF.
      ELSE.
        MESSAGE S000(ZMM) WITH '라인을 선택하세요'.   EXIT.
      ENDIF.

      CHECK GV_ZCOTY IS NOT INITIAL.

      CLEAR LS_LIST.
      LOOP AT IT_HEADER WHERE BOX EQ 'X'.
        MOVE-CORRESPONDING IT_HEADER TO LS_HEADER.
        UPDATE ZTITBLK
           SET UNAM  = SY-UNAME
               UDAT  = SY-DATUM
               UTME  = SY-UZEIT
         WHERE IBLNO = LS_HEADER-IBLNO.

        IF SY-SUBRC = 0.
          COMMIT WORK.
        ENDIF.

        LOOP AT IT_LIST WHERE IBLNO EQ LS_HEADER-IBLNO.
          UPDATE ZTITBLP
             SET ZCOTY = GV_ZCOTY
                 UNAM  = SY-UNAME
                 UDAT  = SY-DATUM
                 UTME  = SY-UZEIT
           WHERE IBLNO = IT_LIST-IBLNO
             AND IBLIT = IT_LIST-IBLIT.

          IF SY-SUBRC = 0.
            MESSAGE S999(ZMTI00) WITH '변경했습니다.'.
          ENDIF.
        ENDLOOP.
*<<CHM2007-00376 일괄변경이므로 헤더LOOP에서 발송
        IF GV_ZCOTY = 'A' OR GV_ZCOTY = 'L'.
          PERFORM SEND_MAIL.
        ENDIF.
*>>CHM2007-00376
      ENDLOOP.
*********************************
*    > 검색조건에 해당하는 데이타를 Select.
      PERFORM P2000_DATA_SELECTIONS.
*    > Header table과 List(Items) table를 만듬.
      PERFORM P2100_HEADER_AND_LIST_BUILD.
      DESCRIBE TABLE IT_TAB LINES G_LINE.
      IF NOT G_LINE IS INITIAL.
        RS_SELFIELD-REFRESH = 'X'.
      ELSE.
*    > Program 종료.
        PERFORM  P9000_PROGRAM_EXIT.
      ENDIF.
***********************************

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

*--> LG전선에서 제외. by MSH
*************************************
*  CASE 'X'.
*    WHEN p_step1.  ">구매입력.
*      APPEND 'ZTICONFIRM'  TO rt_extab.
*      APPEND 'ZTICONFIRC'  TO rt_extab.
*      APPEND 'ZTIT202'     TO rt_extab.
*
*    WHEN p_step2. ">미확인
*      APPEND 'ZTICONFIRC'  TO rt_extab.
*      APPEND 'ZTICONFIRM'  TO rt_extab.
*    WHEN p_step3. ">확인
*      APPEND 'ZTICONFIRM'  TO rt_extab.
*      APPEND 'ZTICONFIRC'  TO rt_extab.
*    WHEN p_step4. ">all
*      APPEND 'ZTICONFIRM'  TO rt_extab.
*      APPEND 'ZTICONFIRC'  TO rt_extab.
*      APPEND 'ZTIT202'     TO rt_extab.
*  ENDCASE.
*************************************
  CASE 'X'.
    WHEN P_ORI.	">원본.
      APPEND 'ZTICONFIRM'  TO RT_EXTAB.
      APPEND 'ZTICONFIRC'  TO RT_EXTAB.
      APPEND 'ZTIT202'     TO RT_EXTAB.

    WHEN P_DUP OR P_ALL.     ">사본 또는 전체.
      APPEND 'ZTICONFIRC'  TO RT_EXTAB.
      APPEND 'ZTICONFIRM'  TO RT_EXTAB.
  ENDCASE.
*--> End of Modification.

  IF S_BUKRS-LOW NE '1000'.
    APPEND 'ZCOTY'  TO RT_EXTAB.
  ENDIF.

  SET PF-STATUS 'STANDARD ' EXCLUDING RT_EXTAB.

*SET PF-STATUS 'ABCD' OF PROGRAM PROG.

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
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100'.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CLEAR : OK_CODE.
  OK_CODE = SY-UCOMM.

  CASE OK_CODE.
    WHEN 'OKAY'.
      CLEAR GV_ZCOTY.
      IF ZTITBLP-ZCOTY IS INITIAL.
        MESSAGE S000(ZMM1) WITH '제출여부를 선택하세요.'.
      ELSE.
        GV_ZCOTY = ZTITBLP-ZCOTY.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_EXIT_0100 INPUT.
  CLEAR GV_ZCOTY.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " USER_COMMAND_EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SCREEN_FIELD .
  GET PARAMETER ID 'BUK' FIELD S_BUKRS-LOW .
  LOOP AT SCREEN .
    IF SCREEN-GROUP1 EQ 'ZCO'.
      IF S_BUKRS-LOW EQ '1000'.
        SCREEN-INVISIBLE = 0.
        SCREEN-INPUT     = 1.
      ELSE.
        SCREEN-INVISIBLE = 1.
        SCREEN-INPUT     = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " SET_SCREEN_FIELD
*&---------------------------------------------------------------------*
*&      Form  GET_RECEIVER_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_RECEIVER_LIST .
  DATA LT_ADR6 TYPE ADR6 OCCURS 0.
  DATA LV_ADDR TYPE AD_ADDRNUM.
  DATA LV_PERS TYPE AD_PERSNUM.
*  CLEAR   : GT_RECV.
*  REFRESH : GT_RECV.

  FIELD-SYMBOLS <LFS_ADR6> LIKE LINE OF LT_ADR6.

  SELECT SINGLE ADDRNUMBER PERSNUMBER INTO (LV_ADDR, LV_PERS)
    FROM USR21
   WHERE BNAME EQ GT_RECV-BNAME.

  CHECK SY-SUBRC = 0.

  CALL FUNCTION 'ADDR_SELECT_ADR6_SINGLE'
    EXPORTING
      ADDRNUMBER          = LV_ADDR
      PERSNUMBER          = LV_PERS
    TABLES
      ET_ADR6             = LT_ADR6
    EXCEPTIONS
      COMM_DATA_NOT_EXIST = 1
      PARAMETER_ERROR     = 2
      INTERNAL_ERROR      = 3
      OTHERS              = 4.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.

  CHECK NOT LT_ADR6[] IS INITIAL.

  READ TABLE LT_ADR6 ASSIGNING <LFS_ADR6> INDEX 1.
  IF SY-SUBRC = 0.
*    GT_RECV-BNAME = GT_MAIL-ERNAM.
    GT_RECV-SMTP_ADDR = <LFS_ADR6>-SMTP_ADDR.
    MODIFY GT_RECV.
  ENDIF.
ENDFORM.                    " GET_RECEIVER_LIST
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEND_MAIL .
  REFRESH: GT_RECV, GT_MESSAGE, GT_RECV[], GT_MESSAGE[] .
  DATA: LV_FLAG,
        LV_TEXT1(255),
        LV_TEXT2(255),
        LV_TEXT3(255),
        LV_TEXT4(255),
        LV_TEXT5(255),
        LT_RECV LIKE TABLE OF GT_RECV.

*수신자 리스트
  SELECT BNAME                                   "담당자
      INTO CORRESPONDING FIELDS OF TABLE GT_RECV
      FROM ZTITBLNAM.

  SELECT SINGLE CNAM                             "생성자
     FROM ZTITBLK
     INTO GT_RECV-BNAME
    WHERE IBLNO = IT_LIST-IBLNO.

*  GT_RECV-BNAME = IT_LIST-CNAM.
  APPEND GT_RECV.
  CLEAR GT_RECV.

  LOOP AT GT_RECV.
    PERFORM GET_RECEIVER_LIST.
  ENDLOOP.

  SORT GT_RECV BY BNAME.

DELETE ADJACENT DUPLICATES FROM GT_RECV[] COMPARING ALL FIELDS."중복방지

  DELETE GT_RECV WHERE SMTP_ADDR IS INITIAL.

*메일 내용 생성
  CLEAR : LV_TEXT1, LV_TEXT2, LV_TEXT3, LV_TEXT4, LV_TEXT5.

*___메일 제목(50 Byte)
  CONCATENATE 'B/L번호:' IT_HEADER-BLNUM
              '원산지증명서 변경알림'
         INTO GV_SUBJECT SEPARATED BY SPACE.
*___메일 내용(라인길이 255 Byte)
  CONCATENATE '<br>'
            '아래 B/L 번호의 원산지 증명서 제출 상태가 변경되었습니다.'
              '<br><br>'
         INTO LV_TEXT1 SEPARATED BY SPACE.
  CONCATENATE '<br>'
              '1. B/L 관리번호 : ' IT_HEADER-IBLNO
              '<br><br>'
         INTO LV_TEXT2 SEPARATED BY SPACE.

  CONCATENATE '<br>'
              '2. B/L 변경자 : ' SY-UNAME
              '<br><br>'
         INTO LV_TEXT3 SEPARATED BY SPACE.

  IF GV_ZCOTY = 'A'.
    CONCATENATE '<br>'
                '3. 원산지 증명서 제출상태 : 발급완료 '
                '<br><br>'
           INTO LV_TEXT4 SEPARATED BY SPACE.
  ELSEIF GV_ZCOTY = 'L'.
    CONCATENATE '<br>'
                '3. 원산지 증명서 제출상태 : 재수출 이행 완료 '
                '<br><br>'
           INTO LV_TEXT4 SEPARATED BY SPACE.
  ENDIF.

  MAIL_MSG: '<html>',
            '<body>',
            LV_TEXT1,
            LV_TEXT2,
            LV_TEXT3,
            LV_TEXT4,
            '</body>',
            '</html>'.

*메일 발송
  IF GT_RECV[] IS NOT INITIAL.
    TRY.
        G_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

        G_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                        I_TYPE    = 'HTM'
                        I_TEXT    = GT_MESSAGE
                        I_SUBJECT = GV_SUBJECT ).

        G_EMAIL->SET_DOCUMENT( G_EMAIL_BODY ).

        LOOP AT GT_RECV.
          G_RECEIVER = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
                        I_ADDRESS_STRING = GT_RECV-SMTP_ADDR ).

          G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                                  I_EXPRESS   = 'X' ).
        ENDLOOP.

        G_SENDER = CL_SAPUSER_BCS=>CREATE( SY-UNAME ).
        G_EMAIL->SET_SENDER( G_SENDER ).

        G_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

        G_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                       RECEIVING RESULT              = GV_SEND_RESULT ).

        COMMIT WORK.

      CATCH CX_BCS INTO G_EXCEPTION.
        LV_FLAG = 'X'.

*        EXIT.
    ENDTRY.
  ELSE.
    LV_FLAG = 'X'.
  ENDIF.

ENDFORM.                    " SEND_MAIL
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEND_MAIL_BATCH .
  DATA: LV_FLAG,
        LV_TEXT1(255),
        LV_TEXT2(255),
        LV_TEXT3(255),
        LV_TEXT4(255),
        LV_TEXT5(255),
        LV_NUM TYPE N LENGTH 2,
        LT_RECV LIKE TABLE OF GT_RECV.

  LOOP AT IT_LIST WHERE ZCOTY = 'D' OR ZCOTY = 'K'.

    IF IT_LIST-CDDAY > 60.
      CONTINUE.
    ENDIF.
    REFRESH: GT_RECV, GT_MESSAGE .
*수신자 리스트

    SELECT SINGLE CNAM                             "생성자
       FROM ZTITBLK
       INTO GT_RECV-BNAME
      WHERE IBLNO = IT_LIST-IBLNO.

*    GT_RECV-BNAME = IT_LIST-CNAM.
    APPEND GT_RECV.
    CLEAR GT_RECV.

    LOOP AT GT_RECV.
      PERFORM GET_RECEIVER_LIST.
    ENDLOOP.

    SORT GT_RECV BY BNAME.

* DELETE ADJACENT DUPLICATES FROM GT_RECV[] COMPARING ALL FIELDS."중복발송
*  DELETE GT_RECV WHERE SMTP_ADDR IS INITIAL.

*메일 내용 생성
    CLEAR : LV_TEXT1, LV_TEXT2, LV_TEXT3, LV_TEXT4, LV_TEXT5, LV_NUM.

*___메일 제목(50 Byte)
    CONDENSE IT_LIST-BLNUM.
    CONCATENATE 'B/L번호:' IT_LIST-BLNUM' 관세환급 잔여일 알림'
           INTO GV_SUBJECT SEPARATED BY SPACE.  " SEPARATED BY SPACE.
*___메일 내용(라인길이 255 Byte)
    LV_NUM = IT_LIST-CDDAY.
    CONCATENATE '<br>'
      '아래 B/L 번호의 관세환급 잔여일은' LV_NUM '일 남았습니다.'
                '<br><br>'
           INTO LV_TEXT1 SEPARATED BY SPACE.

    CONCATENATE '<br>'
          '1. B/L 관리번호 : ' IT_LIST-IBLNO ', B/L 품목:' IT_LIST-IBLIT
          '<br><br>'
           INTO LV_TEXT2 SEPARATED BY SPACE.

    IF IT_LIST-ZCOTY = 'D'.
      CONCATENATE '<br>'
                  '3. 원산지 증명서 제출상태 : 사후발급 예정 '
                  '<br><br>'
             INTO LV_TEXT3 SEPARATED BY SPACE.
    ELSEIF IT_LIST-ZCOTY = 'K'.
      CONCATENATE '<br>'
                  '3. 원산지 증명서 제출상태 : 재수출 이행 예정 '
                  '<br><br>'
             INTO LV_TEXT3 SEPARATED BY SPACE.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = IT_LIST-MATNR
      IMPORTING
        OUTPUT = IT_LIST-MATNR.

    CONCATENATE '<br>'
                '4. 자재코드  : ' IT_LIST-MATNR
                '<br><br>'
           INTO LV_TEXT4 SEPARATED BY SPACE.
"CCM : 2023.04.13  ZITCS4HDEV04 - *ALPHA_INPUT -> *MATN1_INPUT 변경
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*        INPUT  = IT_LIST-MATNR
*      IMPORTING
*        OUTPUT = IT_LIST-MATNR.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input              = IT_LIST-MATNR
     IMPORTING
       OUTPUT             = IT_LIST-MATNR .
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.




    CONCATENATE '<br>'
                '5. 자재내역  : ' IT_LIST-TXZ01
                '<br><br>'
           INTO LV_TEXT5 SEPARATED BY SPACE.


    MAIL_MSG: '<html>',
              '<body>',
              LV_TEXT1,
              LV_TEXT2,
              LV_TEXT3,
              LV_TEXT4,
              LV_TEXT5,
              '</body>',
              '</html>'.

*메일 발송
    IF GT_RECV[] IS NOT INITIAL.
      TRY.
          G_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

          G_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                          I_TYPE    = 'HTM'
                          I_TEXT    = GT_MESSAGE
                          I_SUBJECT = GV_SUBJECT ).

          G_EMAIL->SET_DOCUMENT( G_EMAIL_BODY ).

          LOOP AT GT_RECV.
            G_RECEIVER = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
                          I_ADDRESS_STRING = GT_RECV-SMTP_ADDR ).

            G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                                    I_EXPRESS   = 'X' ).
          ENDLOOP.

          G_SENDER = CL_SAPUSER_BCS=>CREATE( 'ADMIN' ).
          G_EMAIL->SET_SENDER( G_SENDER ).

          G_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

          G_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                         RECEIVING RESULT              =
GV_SEND_RESULT ).

          COMMIT WORK.

        CATCH CX_BCS INTO G_EXCEPTION.
          LV_FLAG = 'X'.

*        EXIT.
      ENDTRY.
    ELSE.
      LV_FLAG = 'X'.
    ENDIF.

  ENDLOOP.
ENDFORM.                    " SEND_MAIL_BATCH
