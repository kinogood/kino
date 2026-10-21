************************************************************************
* Title         :  ZTIR0000T01                                         *
*                                                                      *
* Description   : 수입 B/L 관리 Top Include                            *
*                                                                      *
* Creation Date : 2004/02/11                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
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

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: ZTITRQK,    ">수입의뢰 Header
       *ZTITRQK,    ">수입의뢰 Header
        ZTITRQS,    ">수입의뢰 Status
       *ZTITRQS,    ">수입의뢰 Status
        ZTITRQP,    ">수입의뢰 Items
       *ZTITBLK,    ">Bill of Lading Header table
        ZTITBLP,    ">Bill of Lading Items table
       *ZTITBLP,    ">Bill of Lading Items table
        ZTITBLC,    ">Bill of Lading Container table
       *ZTITBLC,    ">Bill of Lading Container table
        RKPF,        ">예약헤더.
        RESB,        ">예약아이템.
        SPOP,
        ZTIBLIF,
        ZTITIVP,    "[Import] 상업송장 Items table
        EKES.  " [기능개선 ______] 공급업체확정 TABLE

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES: ZTIVRS00.

************************************************************************
* SAP Structure                                                        *
************************************************************************
TABLES: ZTISRQIT,    ">수입의뢰 Items
        ZTISBLIT.    ">B/L Items

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
  C_ACTION              TYPE ES_ELEMENT     VALUE 'ZTIRQ',
  C_DUE_LIST_OFE        LIKE SY-TCODE       VALUE 'ZTIR203', ">생성.
  C_DUE_LIST_TT         LIKE SY-TCODE       VALUE 'ZTIR201', ">생성.
  C_CREATE_D            LIKE SY-TCODE       VALUE 'ZTIT200', ">생성.
  C_CREATE              LIKE SY-TCODE       VALUE 'ZTIT201', ">생성.
  C_CREATE_A            LIKE SY-TCODE       VALUE 'NONE',    ">None.
  C_CHANGE              LIKE SY-TCODE       VALUE 'ZTIT202', ">변경.
  C_DISPLAY             LIKE SY-TCODE       VALUE 'ZTIT203', ">조회.
  C_DELETE              LIKE SY-TCODE       VALUE 'ZTIT204', ">삭제.
  C_ACCEPTANCE          LIKE SY-TCODE       VALUE 'ZTIT205', ">송부.
  C_APPLY               LIKE SY-TCODE       VALUE 'ZTIT206', ">실입항.
  C_SEND                LIKE SY-TCODE       VALUE SPACE,     ">None
  C_OPEN                LIKE SY-TCODE       VALUE 'ZTIT207', ">통관요청.
  C_POST                LIKE SY-TCODE       VALUE 'NONE',    ">None
  C_REVERSE             LIKE SY-TCODE       VALUE 'NONE',    ">None
  C_REVERSE1            LIKE SY-TCODE       VALUE 'NONE',    ">None
  C_CLOSE               LIKE SY-TCODE       VALUE 'NONE',    ">종료.
  C_TEXTOBJECT_HEADER   LIKE TTXOB-TDOBJECT VALUE 'ZTIBLHD'.

************************************************************************
* Internal Tables                                                      *
************************************************************************

*-----------------------------------------------------------------------
*> 수입의뢰아이템 --> Tree용.
*-----------------------------------------------------------------------
*> TYPE FOR THE DATA OF '수입의뢰아이템'
TYPES: BEGIN OF T_ZTISRQIT.
        INCLUDE STRUCTURE ZTISRQIT.
TYPES: BOX        TYPE C,
       INDEX(10)  TYPE N,
       BLMNG      TYPE ZTIBLMNG,
       BLMNGS     TYPE ZTIBLMNGS,
       BLMNGL     TYPE ZTIBLMNGI,
       END OF T_ZTISRQIT.

*> INTERNAL TABLE FOR TABLECONTROL '수입의뢰아이템'
DATA:     IT_ZTISRQIT         TYPE T_ZTISRQIT OCCURS 0 WITH HEADER LINE,
          G_ZTISRQIT_WA       TYPE T_ZTISRQIT.           ">work area

DATA : BEGIN OF IT_ZTITIG02 OCCURS 0.
        INCLUDE STRUCTURE ZTITIG02.
DATA : END   OF IT_ZTITIG02.

DATA : BEGIN OF IT_REQNO OCCURS 0,
       REQNO      TYPE ZTIREQNO.
DATA : END   OF IT_REQNO.

*> CHANGE DOCUMENT용.
DATA : BEGIN OF XZTITBLP OCCURS 0.
        INCLUDE STRUCTURE VZTITBLP.
DATA : END   OF XZTITBLP.

DATA : BEGIN OF YZTITBLP OCCURS 0.
        INCLUDE STRUCTURE VZTITBLP.
DATA : END   OF YZTITBLP.

DATA : BEGIN OF XZTITBLC OCCURS 0.
        INCLUDE STRUCTURE VZTITBLC.
DATA : END   OF XZTITBLC.

DATA : BEGIN OF YZTITBLC OCCURS 0.
        INCLUDE STRUCTURE VZTITBLC.
DATA : END   OF YZTITBLC.

*> 위탁자재용.
DATA : BEGIN OF IT_RESB OCCURS 0.
        INCLUDE STRUCTURE RESB.
DATA :  TXZ01       LIKE ZTISBLIT-TXZ01,
        BLMNG       LIKE ZTITBLP-BLMNG,
        BLMNGS      LIKE ZTISBLIT-BLMNGS,
        BLMNGL      LIKE ZTISBLIT-BLMNGL,
        PARBU       TYPE PARBU,
        BOX         TYPE C,
        INDEX(10)   TYPE N.
DATA : END   OF IT_RESB.

DATA : BEGIN OF IT_EKPO OCCURS 0.
        INCLUDE STRUCTURE ZTIVPO00.
DATA :  BLMNG       LIKE ZTITBLP-BLMNG,
        BLMNGS      LIKE ZTISBLIT-BLMNGS,
        BLMNGL      LIKE ZTISBLIT-BLMNGL,
        BOX        TYPE C,
        INDEX(10)  TYPE N.
DATA : END   OF IT_EKPO.

DATA: IT_EKBE      TYPE EKBE      OCCURS 0 WITH HEADER LINE.


* 20070503 simcho by 박혁세K
DATA : LV_ZTERM LIKE ZTIVRQ00-ZTERM,
       LV_EBELN LIKE ZTIVRQ00-EBELN.
* end simcho

DATA : GV_SUGI. "기능개선 99963 추가

DATA: GV_BEZEI      LIKE ZMMT0230-BEZEI,     "기능개선 283274 - 추가
      GV_MANUL.                              "기능개선 283274 - 추가

DATA : GV_ZCOTY      TYPE ZECOTY,
       GV_ANSWER(1)  TYPE C.

*-----------------------------------------------------------------------
*> B/L Item용.
*-----------------------------------------------------------------------
CONTROLS: TC_2130   TYPE TABLEVIEW USING SCREEN 2130.

*> TYPE FOR THE DATA OF TABLECONTROL 'tc_2130'
TYPES: BEGIN OF T_TC_2130.
        INCLUDE STRUCTURE ZTISBLIT.
TYPES: END OF T_TC_2130.

*> INTERNAL TABLE FOR TABLECONTROL 'tc_2130'
DATA:     IT_TAB           TYPE T_TC_2130 OCCURS 0,
          G_TC_2130_WA     TYPE T_TC_2130,           ">work area
          G_TC_2130_OLD    TYPE T_TC_2130,           ">work area
          G_TC_2130_COPIED.                          ">copy flag

DATA: BEGIN OF IT_BLCNT OCCURS 1,
      BLCNT LIKE ZTISBLIT-BLCNT,
      END   OF IT_BLCNT.

DATA: BEGIN OF IT_NDFTY OCCURS 1,
      NDFTY LIKE ZTISBLIT-NDFTY,
      END   OF IT_NDFTY.

*> LINES OF TABLECONTROL 'tc_2130'
DATA:     G_TC_2130_LINES  LIKE SY-LOOPC.

*> WBS 요소.
DATA: BEGIN OF IT_PSPNR  OCCURS 2,
      PSPNR   TYPE  PS_PSP_PNR.
DATA: END   OF IT_PSPNR.

DATA: BEGIN OF GT_EKPO OCCURS 0,
      EBELN   TYPE EBELN,
      EBELP   TYPE EBELP,
      PEINH   TYPE PEINH,
      BPUMZ   TYPE BPUMZ,
      BPUMN   TYPE BPUMN,
      MENGE   TYPE MENGE_D,
      NETPR   TYPE NETPR,
      NETWR   TYPE NETWR,
      END   OF GT_EKPO.

DATA: G_ZTITBLK_PBO LIKE ZTITBLK,
      G_NDFTY       TYPE ZTINDFTY,
      GS_TRUCKER    LIKE LFA1,
      GS_FORWERDER  LIKE LFA1.


*-----------------------------------------------------------------------
*> 컨테이너 입력용.
*-----------------------------------------------------------------------
*> type for the data of tablecontrol 'TC_2122'
TYPES: BEGIN OF T_TC_2122.
        INCLUDE STRUCTURE ZTITBLC.
TYPES:   FLAG,       "flag for mark column
       END OF T_TC_2122.

*> internal table for tablecontrol 'TC_2122'
DATA:     G_TC_2122_ITAB   TYPE T_TC_2122 OCCURS 0,
          G_TC_2122_WA     TYPE T_TC_2122. "work area
DATA:     G_TC_2122_COPIED.           "copy flag

*> declaration of tablecontrol 'TC_2122' itself
CONTROLS: TC_2122 TYPE TABLEVIEW USING SCREEN 2122.

*> lines of tablecontrol 'TC_2122'
DATA:     G_TC_2122_LINES  LIKE SY-LOOPC.

DATA:     G_REQTY          TYPE ZTIREQTY,
          G_BLNUM          TYPE ZTIBLNUM,
          G_AMOUNT_CHK1    TYPE C,
          G_AMOUNT_CHK2    TYPE C,
          G_AMOUNT_CHK3    TYPE C,
          G_BLNUM_CHK1     TYPE C,
          G_BLNUM_CHK2     TYPE C.

DATA:     G_RADIO1         TYPE C,
          G_RADIO2         TYPE C,
          G_RADIO3         TYPE C,
          G_RADIO4         TYPE C,
          G_RADIO5         TYPE C,
          G_RADIO6         TYPE C,
          G_RADIO7         TYPE C,
          G_RADIO8         TYPE C,
          G_RADIO9         TYPE C.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF TY_HEADER,
            BOX(1)      TYPE C,
            REQNO       LIKE ZTITRQK-REQNO,	"수입의뢰 관리번호.
            AMDSQ	LIKE ZTITRQS-AMDSQ,    "Amend 차수.
            REQTY       LIKE ZTITRQK-REQTY,	"수입의뢰 종류.
            ILCTY       LIKE ZTITRQK-ILCTY,	"1신용장 종류.
            ILCTYX(15)  TYPE C,	                "신용장 종류TEXT.
            LIFNR       LIKE ZTITRQK-LIFNR,	"공급업체 계정번호.
            NAME1       LIKE LFA1-NAME1,
            LIFRE       LIKE ZTITRQK-LIFRE,	"다른 송장발행처.
            NAME3       LIKE LFA1-NAME1,
            OFFER       LIKE ZTITRQK-OFFER,	"오퍼상(Offer).
            NAME4       LIKE LFA1-NAME1,
            OPNBK       LIKE ZTITRQK-OPNBK,	"개설은행.
            NAMET       LIKE ZTSTIG3-NAMET,
            BUKRS       LIKE ZTITRQK-BUKRS,	"회사코드.
            EKORG       LIKE ZTITRQK-EKORG,	"구매조직.
            EKGRP       LIKE ZTITRQK-EKGRP,	"구매그룹.
            APPCT       LIKE ZTITRQK-APPCT,	"수입자 구분.
            LSTAS       LIKE ZTITRQK-LSTAS,	"최종 Amend 차수.
            LPONR       LIKE ZTITRQS-LPONR,	"최종품목번호.
            ANBTY       LIKE ZTITRQK-ANBTY,	"사전/사후 구분자.
            PPAID       LIKE ZTITRQK-PPAID,	"선급금 여부.
            PPRAT       LIKE ZTITRQK-PPRAT,	"선급금 비율.
            RPAID       LIKE ZTITRQK-RPAID,	"유보금 여부.
            RPRAT       LIKE ZTITRQK-RPRAT,	"유보금 비율.

            OPNNO       LIKE ZTITRQS-OPNNO,	"20수입개설번호.
            OPNDT       LIKE ZTITRQS-OPNDT,	"개설일자.
            ZTERM       LIKE ZTITRQS-ZTERM,	"4지급조건키.
            OPAMT       LIKE ZTITRQS-OPAMT,	"개설금액.
            WAERS       LIKE ZTITRQS-WAERS,	"통화키.
            WKURS       LIKE ZTITRQS-WKURS,	                "9환율.
            INCO1       LIKE ZTITRQS-INCO1,	"3인도조건 (파트 1).
            INCO2       LIKE ZTITRQS-INCO2,	"28인도조건 (파트 2).
            EXDAT       LIKE ZTITRQS-EXDAT,	"COM:유효기일.
            LSDAT       LIKE ZTITRQS-LSDAT,	"COM:최종선적일자.
            EDIYN       LIKE ZTITRQS-EDIYN,	"EDI 적용여부.
            INSYN       LIKE ZTITRQS-INSYN,	"적하보험대상여부.
            FWDTY       LIKE ZTITRQS-FWDTY,	"운송 방법.
            FLAND       LIKE ZTITRQS-FLAND,	"선적국가.
            FPORT       LIKE ZTITRQS-FPORT,	"선적항.
            PLLOD       LIKE ZTITRQS-PLLOD,   "COM:선적항.
            TLAND       LIKE ZTITRQS-TLAND,	"도착국가.
            TPORT       LIKE ZTITRQS-TPORT,	"도착항.
            PLTRN       LIKE ZTITRQS-PLTRN,	"COM:도착항.
            PARTY       LIKE ZTITRQS-PARTY,	"분할선적허용여부.
            TRANY       LIKE ZTITRQS-TRANY,	"환적허용여부.
            REQDT       LIKE ZTITRQS-REQDT,	"개설희망일자.
            APPUN       LIKE ZTITRQS-APPUN,	"개설의뢰 요청자.
            APPDT       LIKE ZTITRQS-APPDT,	"개설의뢰 요청일.
            APPTM       LIKE ZTITRQS-APPTM,	"개설의뢰 요청시간.
            ACCUN       LIKE ZTITRQS-ACCUN,	"요청접수 담당자.
            ACCDT       LIKE ZTITRQS-ACCDT,	"요청접수일자.
            ACCTM       LIKE ZTITRQS-ACCTM,	"요청접수시간.
            SNDUN       LIKE ZTITRQS-SNDUN,	"12개설신청자.
            SNDDT       LIKE ZTITRQS-SNDDT,	"개설신청일.
            SNDTM       LIKE ZTITRQS-SNDTM,	"개설신청시간.
            RCVUN       LIKE ZTITRQS-RCVUN,	"12개설등록자.
            RCVDT       LIKE ZTITRQS-RCVDT,	"개설등록일자.
            RCVTM       LIKE ZTITRQS-RCVTM,	"개설등록시간.
            RECID       LIKE ZTITRQS-RECID,	"수신자 ID.
            RECNM       LIKE ZTITRQS-RECNM,	"수신자 명.
            RECNO       LIKE ZTITRQS-RECNO,	"문서번호.
            DOCST       LIKE ZTITRQS-DOCST,	"문서상태.
            DOCSTX(8)   TYPE C,          	"문서상태TEXT.
            COUNT       TYPE I.
TYPES: END OF TY_HEADER.

TYPES: BEGIN OF TY_ITEM.
INCLUDE     TYPE        TY_HEADER.
TYPES :     REQIT       LIKE ZTITRQP-REQIT,	"수입의뢰 품목번호.
            EBELN       LIKE ZTITRQP-EBELN,	"구매전표번호.
            EBELP       LIKE ZTITRQP-EBELP,	"구매문서 품목번호.
            MATKL       LIKE EKPO-MATKL,        "자재그룹.
            RQMNG       LIKE ZTITRQP-RQMNG,	"수입의뢰수량.
            MEINS       LIKE ZTITRQP-MEINS,	"기본단위.
            MBLNR       LIKE ZTITRQP-MBLNR,	"자재문서번호.
            MJAHR       LIKE ZTITRQP-MJAHR,	"자재문서연도.
            ZEILE       LIKE ZTITRQP-ZEILE,	"자재문서품목.
            CNAM        LIKE ZTITRQP-CNAM,  "작성인.
            CDAT        LIKE ZTITRQP-CDAT,  "생성일.
            CTME        LIKE ZTITRQP-CTME,  "생성시간.
            UNAM        LIKE ZTITRQP-UNAM,  "최종변경인.
            UDAT        LIKE ZTITRQP-UDAT,  "변경일.
            UTME        LIKE ZTITRQP-UTME,  "최종변경시간.
            MENGE       LIKE ZTISRQIT-MENGE,
            BLMNGS      LIKE ZTISBLIT-BLMNGS,
            BLMNGL      LIKE ZTISBLIT-BLMNGL,
            WERKS       LIKE ZTISRQIT-WERKS,
            NAME2       LIKE ZTISRQIT-NAME1,
            MATNR       LIKE ZTISRQIT-MATNR,
            TXZ01       LIKE ZTISRQIT-TXZ01,
            EEIND       LIKE ZTISRQIT-EEIND,
            NETPR       LIKE ZTISRQIT-NETPR,
            PEINH       LIKE ZTISRQIT-PEINH,
            NETWR       LIKE ZTISRQIT-NETWR,

*-- [기능개선 ______] 인바운드 납품 필드추가   -[s]
            VBELN       LIKE EKES-VBELN .
*            VBELP       LIKE EKES-VBELP .
*-- [기능개선 ______] 인바운드 납품 필드추가   -[e]

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
*TABLES: t001,
*        t001w,
*        ZTItig02,
*        lfa1,
*        ZTITRQK,
*        ZTITRQS,
*        ZTITRQP.

************************************************************************
* SAP Views                                                            *
************************************************************************
*TABLES: ZTIvpo00,    ">Purchasing Document : Header + Items
*        ZTIvrq00.    ">수입의뢰 Views(Header + Items + status)

*DATA: it_ZTItig02  TYPE ZTItig02  OCCURS 0 WITH HEADER LINE.
DATA: IT_LIST      TYPE TY_LIST   OCCURS 0 WITH HEADER LINE.
DATA: IT_HEADER    TYPE TY_HEADER OCCURS 0 WITH HEADER LINE.
DATA: IT_TABH      TYPE TY_TAB    OCCURS 0 WITH HEADER LINE.

** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: A_BUKRS LIKE T001-BUKRS,
      L_YN    TYPE C.

** JS전선 회사코드 2007/04 KSH --------------------------------------

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
