************************************************************************
* Title         :  ZTIR5010                                            *
*                                                                      *
* Description   : [Report] 외자 입고 현황 List                         *
*                                                                      *
* Creation Date : 2004/02/25                                           *
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
* dd-mmm-yyyy  xxxxxxxxxxxxxxx  DVPK9xxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  *
*                                                                      *
*                                                                      *
************************************************************************
REPORT  ZTIR5020       MESSAGE-ID ZMTI00
                       NO STANDARD PAGE HEADING.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE ZTS_REUSE_ALVFORMS_T00.  "> AVL 공용 Data 선언.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPES: BEGIN OF TY_HEADER,
*            box(1)      TYPE c,
            IGRNO       LIKE ZTITGRK-IGRNO,    "입고관리번호
            ICCNO       LIKE ZTITGRK-ICCNO,    "통관관리번호
            GRSEQ       LIKE ZTITGRK-GRSEQ,    "입고 순번
            IBLNO       LIKE ZTITGRK-IBLNO,    "B/L 관리번호
            WAERS       LIKE ZTITGRK-WAERS,    "통화키
            BUKRS       LIKE ZTITGRK-BUKRS,    "회사코드
            IGRST       LIKE ZTITGRK-IGRST,    "전기상태
            IGRSTX(20) TYPE C,                  "전기상태
            IGRTY       LIKE ZTITGRK-IGRTY,    "입고종류
            BWART       LIKE ZTITGRK-BWART,    "이동유형(재고)
            BLDAT       LIKE ZTITGRK-BLDAT,    "전표증빙일
            BUDAT       LIKE ZTITGRK-BUDAT,    "전표의 전기일
            MBLNR       LIKE ZTITGRK-MBLNR,    "자재문서번호
            MJAHR       LIKE ZTITGRK-MJAHR,    "자재문서연도
            LIFNR       LIKE ZTITGRK-LIFNR,    "구매처계정번호
            CBUDAT      LIKE ZTITGRK-CBUDAT,   "취소전표전기일
            CMBLNR      LIKE ZTITGRK-CMBLNR,   "취소자재문서번호
            CMJAHR      LIKE ZTITGRK-CMJAHR,   "취소자재문서연도
            BKTXT       LIKE ZTITGRK-BKTXT,    "헤더텍스트
            FRBNR       LIKE ZTITGRK-FRBNR,    "입고선하증권
            IBLDAT      LIKE ZTITBLK-BLDAT,    "BL발행일
            XBLNR       LIKE ZTITGRK-XBLNR,    "참조전표번호
            WEVER       LIKE ZTITGRK-WEVER,    "GR/GI전표출력
            BFWMS       LIKE ZTITGRK-BFWMS,    "WMS전기제어
            GRUND       LIKE ZTITGRK-GRUND,    "이동사유
            CNAM        LIKE ZTITGRK-CNAM,     "작성인
            CDAT        LIKE ZTITGRK-CDAT,     "생성일
            CTME        LIKE ZTITGRK-CTME,     "생성시간
            UNAM        LIKE ZTITGRK-UNAM,     "최종변경인
            UDAT        LIKE ZTITGRK-UDAT,     "변경일
            UTME        LIKE ZTITGRK-UTME.     "최종변경시간

TYPES: END OF TY_HEADER.

TYPES: BEGIN OF TY_ITEM.
INCLUDE     TYPE        TY_HEADER.
TYPES :     ICCIT       LIKE ZTITGRP-ICCIT,    "Items
            IBLNOT      LIKE ZTITGRP-IBLNO,    "B/L번호
            IBLIT       LIKE ZTITGRP-IBLIT,    "B/L품목
            ICCNOT      LIKE ZTITGRP-ICCNO,    "통관번호
            GRSEQT      LIKE ZTITGRP-GRSEQ,    "입고순번
            SHKZG       LIKE ZTITGRP-SHKZG,    "차변/대변
            WERKS       LIKE ZTITGRP-WERKS,    "플랜트
            LGORT       LIKE ZTITGRP-LGORT,    "저장위치
            EBELN       LIKE ZTITGRP-EBELN,    "구매전표번호
            EBELP       LIKE ZTITGRP-EBELP,    "구매문서번호
            REQNO       LIKE ZTITGRP-REQNO,    "수입의뢰번호
            REQIT       LIKE ZTITGRP-REQIT,    "수입의뢰품목
            RSNUM       LIKE ZTITGRP-RSNUM,    "예약/종속소요량
            RSPOS       LIKE ZTITGRP-RSPOS,    "예약/종속요청품목
            RSART       LIKE ZTITGRP-RSART,    "레코드유형
            MATNR       LIKE ZTITGRP-MATNR,    "자재번호
            GRMNG       LIKE ZTITGRP-GRMNG,    "입고 수량
            MEINS       LIKE ZTITGRP-MEINS,    "기본단위
            TXZ01       LIKE ZTITGRP-TXZ01,    "내역
            BATCH       LIKE ZTITGRP-BATCH,    "Loc. No.
            LICHA       LIKE ZTITGRP-LICHA,    "공급업체뱃치
            SGTXT       LIKE ZTITGRP-SGTXT,    "항목텍스트
            VFDAT       LIKE ZTITGRP-VFDAT,    "저장수명만기
            HSDAT       LIKE ZTITGRP-HSDAT,    "뱃치 생산일
            VBELN       LIKE ZTITGRP-VBELN,    "납품
            POSNR       LIKE ZTITGRP-POSNR,    "납품품목
            STAWN       LIKE ZTITGRP-STAWN,    "수입코드번호
            ABLAD       LIKE ZTITGRP-ABLAD,    "하역지점
            FLAG        LIKE ZTISGRIT-FLAG,     "일반표시
            MENGE       LIKE ZTISGRIT-MENGE,    "수량
            CCMNG       LIKE ZTISGRIT-CCMNG,    "통관 수량
            GRMNGS      LIKE ZTISGRIT-GRMNGS,   "입고누적수량
            GRMNGL      LIKE ZTISGRIT-GRMNGL,   "입고가능수량
            NAME1       LIKE ZTISGRIT-NAME1,    "플랜트
            LGOBE       LIKE ZTISGRIT-LGOBE,    "저장위치
            NETWR       LIKE ZTISGRIT-NETWR,    "문서통화정가
            EEIND       LIKE ZTISGRIT-EEIND,    "납품일
            UMSON       LIKE ZTISGRIT-UMSON,    "무상품목
            LOEKZ       LIKE ZTISGRIT-LOEKZ,    "구매문서상삭제지시
            ELIKZ       LIKE ZTISGRIT-ELIKZ,    "납품완료 지시자
            BPRME       LIKE ZTISGRIT-BPRME,    "오더가격단위 (구매)
            BPUMZ       LIKE ZTISGRIT-BPUMZ,    "오더단위환산분자
            BPUMN       LIKE ZTISGRIT-BPUMN,    "오더단위환산분모
            UMREZ       LIKE ZTISGRIT-UMREZ,    "기본단위로전환분자
            UMREN       LIKE ZTISGRIT-UMREN,    "기본단위로전환분모
            NETPR       LIKE ZTISGRIT-NETPR,    "구매문서의 단가
            PEINH       LIKE ZTISGRIT-PEINH,    "가격단위
            UEBTO       LIKE ZTISGRIT-UEBTO,    "초과납품 허용치
            UEBTK       LIKE ZTISGRIT-UEBTK,    "허용된 초과납품
            UNTTO       LIKE ZTISGRIT-UNTTO,    "미달납품 허용치
            BUPLA       LIKE ZTISGRIT-BUPLA.    "사업장
TYPES: END OF TY_ITEM.



DATA : BEGIN OF IT_LIST_ALV OCCURS 0,
            IGRNO       LIKE ZTITGRK-IGRNO,    "입고관리번호
            GRSEQ       LIKE ZTITGRK-GRSEQ,    "입고 순번
            ICCNO       LIKE ZTITGRK-ICCNO,    "통관관리번호
            IBLNO       LIKE ZTITGRK-IBLNO,    "B/L 관리번호
            WAERS       LIKE ZTITGRK-WAERS,    "통화키
            BUKRS       LIKE ZTITGRK-BUKRS,    "회사코드
            IGRST       LIKE ZTITGRK-IGRST,    "전기상태
            IGRSTX(20) TYPE C,                  "전기상태
            IGRTY       LIKE ZTITGRK-IGRTY,    "입고종류
            BWART       LIKE ZTITGRK-BWART,    "이동유형(재고)
            BLDAT       LIKE ZTITGRK-BLDAT,    "전표증빙일
            BUDAT       LIKE ZTITGRK-BUDAT,    "전표의 전기일
            MBLNR       LIKE ZTITGRK-MBLNR,    "자재문서번호
            MJAHR       LIKE ZTITGRK-MJAHR,    "자재문서연도
            LIFNR       LIKE ZTITGRK-LIFNR,    "구매처계정번호
            CBUDAT      LIKE ZTITGRK-CBUDAT,   "취소전표전기일
            CMBLNR      LIKE ZTITGRK-CMBLNR,   "취소자재문서번호
            CMJAHR      LIKE ZTITGRK-CMJAHR,   "취소자재문서연도
            BKTXT       LIKE ZTITGRK-BKTXT,    "헤더텍스트
            FRBNR       LIKE ZTITGRK-FRBNR,    "입고선하증권
            IBLDAT      LIKE ZTITBLK-BLDAT,    "BL발행일
            XBLNR       LIKE ZTITGRK-XBLNR,    "참조전표번호
            WEVER       LIKE ZTITGRK-WEVER,    "GR/GI전표출력
            BFWMS       LIKE ZTITGRK-BFWMS,    "WMS전기제어
            GRUND       LIKE ZTITGRK-GRUND,    "이동사유

            IBLNOT      LIKE ZTITGRP-IBLNO,    "B/L번호
            IBLIT       LIKE ZTITGRP-IBLIT,    "B/L품목
            ICCNOT      LIKE ZTITGRP-ICCNO,    "통관번호
            ICCIT       LIKE ZTITGRP-ICCIT,    "Items
            GRSEQT      LIKE ZTITGRP-GRSEQ,    "입고순번
            SHKZG       LIKE ZTITGRP-SHKZG,    "차변/대변
            WERKS       LIKE ZTITGRP-WERKS,    "플랜트
            LGORT       LIKE ZTITGRP-LGORT,    "저장위치
            EBELN       LIKE ZTITGRP-EBELN,    "구매전표번호
            EBELP       LIKE ZTITGRP-EBELP,    "구매문서번호
            REQNO       LIKE ZTITGRP-REQNO,    "수입의뢰번호
            REQIT       LIKE ZTITGRP-REQIT,    "수입의뢰품목
            RSNUM       LIKE ZTITGRP-RSNUM,    "예약/종속소요량
            RSPOS       LIKE ZTITGRP-RSPOS,    "예약/종속요청품목
            RSART       LIKE ZTITGRP-RSART,    "레코드유형
            MATNR       LIKE ZTITGRP-MATNR,    "자재번호
            GRMNG       LIKE ZTITGRP-GRMNG,    "입고 수량
            MEINS       LIKE ZTITGRP-MEINS,    "기본단위
            TXZ01       LIKE ZTITGRP-TXZ01,    "내역
            BATCH       LIKE ZTITGRP-BATCH,    "Loc. No.
            LICHA       LIKE ZTITGRP-LICHA,    "공급업체뱃치
            SGTXT       LIKE ZTITGRP-SGTXT,    "항목텍스트
            VFDAT       LIKE ZTITGRP-VFDAT,    "저장수명만기
            HSDAT       LIKE ZTITGRP-HSDAT,    "뱃치 생산일
            VBELN       LIKE ZTITGRP-VBELN,    "납품
            POSNR       LIKE ZTITGRP-POSNR,    "납품품목
            STAWN       LIKE ZTITGRP-STAWN,    "수입코드번호
            ABLAD       LIKE ZTITGRP-ABLAD,    "하역지점
            FLAG        LIKE ZTISGRIT-FLAG,     "일반표시
            MENGE       LIKE ZTISGRIT-MENGE,    "수량
            CCMNG       LIKE ZTISGRIT-CCMNG,    "통관 수량
            GRMNGS      LIKE ZTISGRIT-GRMNGS,   "입고누적수량
            GRMNGL      LIKE ZTISGRIT-GRMNGL,   "입고가능수량
            NAME1       LIKE ZTISGRIT-NAME1,    "플랜트
            LGOBE       LIKE ZTISGRIT-LGOBE,    "저장위치
            NETWR       LIKE ZTISGRIT-NETWR,    "문서통화정가
            EEIND       LIKE ZTISGRIT-EEIND,    "납품일
            UMSON       LIKE ZTISGRIT-UMSON,    "무상품목
            LOEKZ       LIKE ZTISGRIT-LOEKZ,    "구매문서상삭제지시
            ELIKZ       LIKE ZTISGRIT-ELIKZ,    "납품완료 지시자
            BPRME       LIKE ZTISGRIT-BPRME,    "오더가격단위 (구매)
            BPUMZ       LIKE ZTISGRIT-BPUMZ,    "오더단위환산분자
            BPUMN       LIKE ZTISGRIT-BPUMN,    "오더단위환산분모
            UMREZ       LIKE ZTISGRIT-UMREZ,    "기본단위로전환분자
            UMREN       LIKE ZTISGRIT-UMREN,    "기본단위로전환분모
            NETPR       LIKE ZTISGRIT-NETPR,    "구매문서의 단가
            PEINH       LIKE ZTISGRIT-PEINH,    "가격단위
            UEBTO       LIKE ZTISGRIT-UEBTO,    "초과납품 허용치
            UEBTK       LIKE ZTISGRIT-UEBTK,    "허용된 초과납품
            UNTTO       LIKE ZTISGRIT-UNTTO,    "미달납품 허용치
            BUPLA       LIKE ZTISGRIT-BUPLA,    "사업장
            CNAM        LIKE ZTITGRK-CNAM,     "작성인
            CDAT        LIKE ZTITGRK-CDAT,     "생성일
            CTME        LIKE ZTITGRK-CTME,     "생성시간
            UNAM        LIKE ZTITGRK-UNAM,     "최종변경인
            UDAT        LIKE ZTITGRK-UDAT,     "변경일
            UTME        LIKE ZTITGRK-UTME,     "최종변경시간
*--< ALV color information
          INFO(4) TYPE C,            "ALV ROW COLOR
          COLINFO TYPE LVC_T_SCOL,   "ALV COLUMN COLOR
          STYLE   TYPE LVC_T_STYL.   "ALV CONTROL

DATA : END OF IT_LIST_ALV.



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
        ZTITGRK,
        ZTITGRP.

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES: ZTIVPO00,    ">Purchasing Document : Header + Items
        ZTIVRQ00,    ">수입의뢰 Views(Header + Items + status)
        ZTIVBL00,    ">수입 B/L Views(Header + Items)
        ZTIVCC00,    ">통관 Views
        ZTIVGR00,    ">입고 Views
        ZTIVIV00,    ">상업송장 View
        ZTIVIV01,    ">선급금   View
        ZTIVIV02.    ">상업송장 Items + B/L Header Views

************************************************************************
* CONSTANTS                                                            *
************************************************************************

*----------------------------------------------------------------------*
* CONSTANT
*----------------------------------------------------------------------*
CONSTANTS : C_X           VALUE 'X',
            C_KRW(3)      VALUE 'KRW',

*-- ALV 필드 색상
   C_COL_YELLOW  TYPE CHAR4 VALUE 'C300',
   C_COL_BLUE    TYPE CHAR4 VALUE 'C400',
   C_COL_GREEN   TYPE CHAR4 VALUE 'C500',
   C_COL_RED     TYPE CHAR4 VALUE 'C600',
   C_COL_GREY    TYPE CHAR4 VALUE 'C000',
   C_COL_LGREY   TYPE CHAR4 VALUE 'C200',
   C_COL_VIOLET  TYPE CHAR4 VALUE 'C700',

   C_COL_YELLOW1  TYPE CHAR4 VALUE 'C310',
   C_COL_BLUE1    TYPE CHAR4 VALUE 'C410',
   C_COL_GREEN1   TYPE CHAR4 VALUE 'C510',
   C_COL_RED1     TYPE CHAR4 VALUE 'C610',
   C_COL_GREY1    TYPE CHAR4 VALUE 'C010',
   C_COL_LGREY1   TYPE CHAR4 VALUE 'C210',
   C_COL_VIOLET1  TYPE CHAR4 VALUE 'C710',

   C_COL_YELLOW2  TYPE CHAR4 VALUE 'C301',
   C_COL_BLUE2    TYPE CHAR4 VALUE 'C401',
   C_COL_GREEN2   TYPE CHAR4 VALUE 'C501',
   C_COL_RED2     TYPE CHAR4 VALUE 'C601',
   C_COL_GREY2    TYPE CHAR4 VALUE 'C001',
   C_COL_LGREY2   TYPE CHAR4 VALUE 'C201',
   C_COL_VIOLET2  TYPE CHAR4 VALUE 'C701',

   C_VAT_RATE TYPE P DECIMALS 1 VALUE '0.1'.

** JS전선 회사코드 2007/04 --------------------------------------
*CONSTANTS:
*    c_bukrs     LIKE t001-bukrs     VALUE '1000'.   ">Company code
** JS전선 회사코드 2007/04 --------------------------------------
************************************************************************
* Internal Tables                                                      *
************************************************************************
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
CLASS LCL_EVENT_RECEIVER DEFINITION.
  PUBLIC SECTION.
    METHODS:
      HANDLE_DATA_CHANGED
                    FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
        IMPORTING SENDER ER_DATA_CHANGED,
      HANDLE_HOTSPOT_CLICK
                    FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
        IMPORTING SENDER E_ROW_ID E_COLUMN_ID,
      HANDLE_DOUBLE_CLICK
                    FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
        IMPORTING SENDER E_ROW E_COLUMN,
      HANDLE_ONF4
                    FOR EVENT ONF4 OF CL_GUI_ALV_GRID
        IMPORTING SENDER E_FIELDNAME E_FIELDVALUE
                    ES_ROW_NO ER_EVENT_DATA
                    ET_BAD_CELLS E_DISPLAY,
      HANDLE_TOOLBAR
                    FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
        IMPORTING SENDER E_OBJECT E_INTERACTIVE,
      HANDLE_USER_COMMAND
                    FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
        IMPORTING SENDER E_UCOMM.

ENDCLASS.                    "LCL_EVENT_RECEIVER DEFINITION

************************************************************************
* CLASSES: IMPLEMENTATION
*
************************************************************************
CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.
  METHOD HANDLE_DATA_CHANGED.
*    PERFORM HANDLE_DATA_CHANGED USING SENDER
*                                      ER_DATA_CHANGED.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED

  METHOD HANDLE_HOTSPOT_CLICK.

    PERFORM HANDLE_HOTSPOT_CLICK USING SENDER
                                       E_ROW_ID-INDEX
                                       E_COLUMN_ID-FIELDNAME.


  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  METHOD HANDLE_DOUBLE_CLICK.
*   PERFORM HANDLE_DOUBLE_CLICK USING SENDER
*                                     E_ROW-INDEX
*                                     E_COLUMN-FIELDNAME.
  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK
  METHOD HANDLE_ONF4.
*    PERFORM GET_ON_F4 USING SENDER
*                            E_FIELDNAME
*                            E_FIELDVALUE
*                            ES_ROW_NO
*                            ER_EVENT_DATA
*                            ET_BAD_CELLS
*                            E_DISPLAY.
*    ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.
  ENDMETHOD.                    "HANDLE_ONF4
  METHOD HANDLE_TOOLBAR.
*    PERFORM TOOLBAR_PART USING SENDER
*                               E_OBJECT
*                               E_INTERACTIVE.
  ENDMETHOD.                    "HANDLE_TOOLBAR
  METHOD HANDLE_USER_COMMAND.
*    PERFORM USER_COMMAND_PART USING SENDER
*                                    E_UCOMM.
  ENDMETHOD.                    "HANDLE_USER_COMMAND
ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION

************************************************************************
* ALV GRID
************************************************************************
*메인
DATA : GS_CUSTOM_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GS_SPLITTER         TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       GS_CONTAINER_TOP    TYPE REF TO CL_GUI_CONTAINER,
       GS_ALV_GRID         TYPE REF TO CL_GUI_ALV_GRID,      "alv grid
       GS_VARIANT          TYPE DISVARIANT,    " Layout (External Use)
       GS_LAYOUT_1         TYPE LVC_S_LAYO,      " ALV control: Layout
       GT_FIELDCAT         TYPE LVC_T_FCAT WITH HEADER LINE,
       GT_FIELD            TYPE SLIS_T_FIELDCAT_ALV,
       GT_SORT             TYPE TABLE OF LVC_S_SORT,        "Field sort
       GT_EXCLUDE          TYPE UI_FUNCTIONS,          "ALV Toolbar dim
       GT_COLOR            TYPE LVC_T_SCOL WITH HEADER LINE, "ALV color
       GS_EVENT_RECEIVER   TYPE REF TO LCL_EVENT_RECEIVER,   "ALV Event
       GS_STBL             TYPE LVC_S_STBL.            "최신표시 안정성



************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK DBSEL WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS:
  S_BUKRS  FOR ZTITGRK-BUKRS                   "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID BUK
                    MODIF  ID IOG ,
  S_EBELN  FOR ZTITGRP-EBELN  MODIF  ID IOG,   "구매전표번호
  S_IGRNO  FOR ZTITGRK-IGRNO  MODIF  ID IOG,   "입고관리번호
  S_ICCNO  FOR ZTITGRK-ICCNO  MODIF  ID IOG,   "통관관리번호
  S_IBLNO  FOR ZTITGRK-IBLNO  MODIF  ID IOG,   "B/L 관리번호
  S_REQNO  FOR ZTITGRP-REQNO  MODIF  ID IOG,   "수입의뢰번호
  S_RSNUM  FOR ZTITGRP-RSNUM  MODIF  ID IOG,   "예약/종속소요량
  S_CNAM   FOR ZTITGRK-CNAM   MODIF  ID IOG,   "작성인
  S_CDAT   FOR ZTITGRK-CDAT   MODIF  ID IOG,   "생성일
  S_UNAM   FOR ZTITGRK-UNAM   MODIF  ID IOG,   "최종변경인
  S_UDAT   FOR ZTITGRK-UDAT   MODIF  ID IOG.   "변경일
SELECTION-SCREEN ULINE.
SELECT-OPTIONS:
  S_GRSEQ  FOR ZTITGRK-GRSEQ  MODIF  ID IOG,   "입고 순번
  S_IGRST  FOR ZTITGRK-IGRST  MODIF  ID IOG,   "전기상태
  S_IGRTY  FOR ZTITGRK-IGRTY  MODIF  ID IOG,   "입고종류
  S_WAERS  FOR ZTITGRK-WAERS  MODIF  ID IOG,   "통화키
  S_BLDAT  FOR ZTITGRK-BLDAT  MODIF  ID IOG,   "전표증빙일
  S_BUDAT  FOR ZTITGRK-BUDAT  MODIF  ID IOG,   "전표의 전기일
  S_MBLNR  FOR ZTITGRK-MBLNR  MODIF  ID IOG,   "자재문서번호
  S_MJAHR  FOR ZTITGRK-MJAHR  MODIF  ID IOG,   "자재문서연도
  S_LIFNR  FOR ZTITGRK-LIFNR  MODIF  ID IOG,   "구매처계정번호
  S_CBUDAT FOR ZTITGRK-CBUDAT MODIF  ID IOG,   "취소전표전기일
  S_CMBLNR FOR ZTITGRK-CMBLNR MODIF  ID IOG,   "취소자재문서번호
  S_CMJAHR FOR ZTITGRK-CMJAHR MODIF  ID IOG,   "취소자재문서연도
  S_BKTXT  FOR ZTITGRK-BKTXT  MODIF  ID IOG,   "헤더텍스트
  S_FRBNR  FOR ZTITGRK-FRBNR  MODIF  ID IOG,   "입고선하증권
  S_XBLNR  FOR ZTITGRK-XBLNR  MODIF  ID IOG,   "참조전표번호
  S_WEVER  FOR ZTITGRK-WEVER  MODIF  ID IOG,   "GR/GI전표출력
  S_BFWMS  FOR ZTITGRK-BFWMS  MODIF  ID IOG,   "WMS전기제어
  S_GRUND  FOR ZTITGRK-GRUND  MODIF  ID IOG,   "이동사유
  S_CTME   FOR ZTITGRK-CTME   MODIF  ID IOG,   "생성시간
  S_UTME   FOR ZTITGRK-UTME   MODIF  ID IOG,   "최종변경시간
  S_ICCIT  FOR ZTITGRP-ICCIT  MODIF  ID IOG,   "Items
  S_IBLNOT FOR ZTITGRP-IBLNO  MODIF  ID IOG,   "B/L번호
  S_IBLIT  FOR ZTITGRP-IBLIT  MODIF  ID IOG,   "B/L품목
  S_ICCNOT FOR ZTITGRP-ICCNO  MODIF  ID IOG,   "통관번호
  S_GRSEQT FOR ZTITGRP-GRSEQ  MODIF  ID IOG,   "입고순번
  S_SHKZG  FOR ZTITGRP-SHKZG  MODIF  ID IOG,   "차변/대변
  S_BWART  FOR ZTITGRP-BWART  MODIF  ID IOG,   "이동유형(재고)
  S_WERKS  FOR ZTITGRP-WERKS  MODIF  ID IOG,   "플랜트
  S_LGORT  FOR ZTITGRP-LGORT  MODIF  ID IOG,   "저장위치
  S_EBELP  FOR ZTITGRP-EBELP  MODIF  ID IOG,   "구매문서번호
  S_REQIT  FOR ZTITGRP-REQIT  MODIF  ID IOG,   "수입의뢰품목
  S_RSPOS  FOR ZTITGRP-RSPOS  MODIF  ID IOG,   "예약/종속요청품목
  S_RSART  FOR ZTITGRP-RSART  MODIF  ID IOG,   "레코드유형
  S_MATNR  FOR ZTITGRP-MATNR  MODIF  ID IOG,   "자재번호
  S_TXZ01  FOR ZTITGRP-TXZ01  MODIF  ID IOG,   "내역
  S_BATCH  FOR ZTITGRP-BATCH  MODIF  ID IOG,   "Loc. No.
  S_LICHA  FOR ZTITGRP-LICHA  MODIF  ID IOG,   "공급업체뱃치
  S_SGTXT  FOR ZTITGRP-SGTXT  MODIF  ID IOG,   "항목텍스트
  S_VFDAT  FOR ZTITGRP-VFDAT  MODIF  ID IOG,   "저장수명만기
  S_HSDAT  FOR ZTITGRP-HSDAT  MODIF  ID IOG,   "뱃치 생산일
  S_VBELN  FOR ZTITGRP-VBELN  MODIF  ID IOG,   "납품
  S_POSNR  FOR ZTITGRP-POSNR  MODIF  ID IOG,   "납품품목
  S_STAWN  FOR ZTITGRP-STAWN  MODIF  ID IOG,   "수입코드번호
  S_ABLAD  FOR ZTITGRP-ABLAD  MODIF  ID IOG.   "하역지점
SELECTION-SCREEN END OF BLOCK DBSEL.

SELECTION-SCREEN BEGIN OF BLOCK LISTS WITH FRAME TITLE TEXT-002.
PARAMETERS: P_VARI LIKE DISVARIANT-VARIANT,
            P_ITEM  TYPE C AS CHECKBOX DEFAULT 'X',
            P_CGRID TYPE C AS CHECKBOX . "ALV GRID CLASS 조회
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

    IF P_CGRID IS INITIAL.
      PERFORM 3910_CALL_ALV_HIERSEQ.
    ELSE.
      CALL SCREEN 0100.
    ENDIF.

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

  SET TITLEBAR 'T1000' WITH '현황 List'(T10).

ENDFORM.                    " p1001_initialization

*&---------------------------------------------------------------------*
*&      Form  p1100_check_input_values
*&---------------------------------------------------------------------*
FORM P1100_CHECK_INPUT_VALUES .

  TABLES : DFIES.
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

ENDFORM.                    " p1100_check_input_values

*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
FORM P2000_DATA_SELECTIONS .

  DATA: L_RQMNG  TYPE ZTIRQMNG.

  CLEAR: G_COUNT, IT_TAB, IT_HEADER, IT_LIST.
  REFRESH : IT_TAB, IT_HEADER, IT_LIST.
*> PROGRESS Display.
  G_LINEN    = 30.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

*> I/V 데이타 select.
  SELECT *
         INTO CORRESPONDING FIELDS OF TABLE IT_TAB
         FROM ZTIVGR00
        WHERE BUKRS   IN S_BUKRS  "회사코드.
          AND IGRNO   IN S_IGRNO  "입고관리번호
          AND ICCNO   IN S_ICCNO  "통관관리번호
          AND GRSEQ   IN S_GRSEQ  "입고 순번
          AND IBLNO   IN S_IBLNO  "B/L 관리번호
          AND WAERS   IN S_WAERS  "통화키
          AND BUKRS   IN S_BUKRS  "회사코드
          AND IGRST   IN S_IGRST  "전기상태
          AND IGRTY   IN S_IGRTY  "입고종류
          AND BLDAT   IN S_BLDAT  "전표증빙일
          AND BUDAT   IN S_BUDAT  "전표의 전기일
          AND MBLNR   IN S_MBLNR  "자재문서번호
          AND MJAHR   IN S_MJAHR  "자재문서연도
          AND LIFNR   IN S_LIFNR  "구매처 또는 채권자 계정번호
          AND CBUDAT  IN S_CBUDAT "취소전표전기일
          AND CMBLNR  IN S_CMBLNR "취소자재문서번호
          AND CMJAHR  IN S_CMJAHR "취소자재문서연도
          AND BKTXT   IN S_BKTXT  "헤더텍스트
          AND FRBNR   IN S_FRBNR  "입고선하증권
          AND XBLNR   IN S_XBLNR  "참조전표번호
          AND WEVER   IN S_WEVER  "GR/GI전표출력
          AND BFWMS   IN S_BFWMS  "WMS전기제어
          AND GRUND   IN S_GRUND  "이동사유
          AND CNAM    IN S_CNAM   "작성인
          AND CDAT    IN S_CDAT   "생성일
          AND CTME    IN S_CTME   "생성시간
          AND UNAM    IN S_UNAM   "최종변경인
          AND UDAT    IN S_UDAT   "변경일
          AND UTME    IN S_UTME   "최종변경시간
          AND ICCIT   IN S_ICCIT  "Items
          AND IBLNO   IN S_IBLNOT "B/L번호
          AND IBLIT   IN S_IBLIT  "B/L품목
          AND ICCNO   IN S_ICCNOT "통관번호
          AND GRSEQ   IN S_GRSEQT "입고순번
          AND SHKZG   IN S_SHKZG  "차변/대변
          AND BWART   IN S_BWART  "이동유형(재고)
          AND WERKS   IN S_WERKS  "플랜트
          AND LGORT   IN S_LGORT  "저장위치
          AND EBELN   IN S_EBELN  "구매전표번호
          AND EBELP   IN S_EBELP  "구매문서번호
          AND REQNO   IN S_REQNO  "수입의뢰번호
          AND REQIT   IN S_REQIT  "수입의뢰품목
          AND RSNUM   IN S_RSNUM  "예약/종속소요량
          AND RSPOS   IN S_RSPOS  "예약/종속요청품목
          AND RSART   IN S_RSART  "레코드유형
          AND MATNR   IN S_MATNR  "자재번호
          AND TXZ01   IN S_TXZ01  "내역
          AND BATCH   IN S_BATCH  "Loc. No.
          AND LICHA   IN S_LICHA  "공급업체뱃치
          AND SGTXT   IN S_SGTXT  "항목텍스트
          AND VFDAT   IN S_VFDAT  "저장수명만기
          AND HSDAT   IN S_HSDAT  "뱃치 생산일
          AND VBELN   IN S_VBELN  "납품
          AND POSNR   IN S_POSNR  "납품품목
          AND STAWN   IN S_STAWN  "수입코드번호
          AND ABLAD   IN S_ABLAD. "하역지점

  IF SY-SUBRC NE 0.
    MESSAGE S902.
  ENDIF.

  CLEAR: G_TABIX, G_COUNT, G_CNT.
  LOOP AT IT_TAB.

    G_TABIX = SY-TABIX.
*   domain의 value.
    PERFORM GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING :
                           'ZTIIGRST' IT_TAB-IGRST  IT_TAB-IGRSTX.

*   공급업체.
*  SELECT SINGLE name1 INTO it_tab-name1
*    FROM lfa1
*   WHERE lifnr EQ it_tab-lifnr.

*   p/o정보.
    SELECT  SINGLE WERKS MATNR TXZ01
      INTO  (IT_TAB-WERKS, IT_TAB-MATNR, IT_TAB-TXZ01)
      FROM  ZTIVPO00
     WHERE  EBELN  = IT_TAB-EBELN
       AND  EBELP  = IT_TAB-EBELP.

*   수입의뢰 정보 수량.
*    SELECT  SINGLE rqmng
*      INTO  it_tab-menge
*      FROM  ZTIvrq00
*     WHERE  reqno  = it_tab-reqno
*       AND  reqit  = it_tab-reqit.

* b/l 정보 수량.
    SELECT  SINGLE CCMNG
      INTO  IT_TAB-MENGE
      FROM  ZTIVCC00
     WHERE  ICCNO  = IT_TAB-ICCNO
       AND  ICCIT  = IT_TAB-ICCIT.

* 누적수량.
    SELECT  SUM( GRMNG ) INTO IT_TAB-GRMNGS FROM ZTITGRP
     WHERE  IGRNO  = IT_TAB-IGRNO
       AND  ICCIT  = IT_TAB-ICCIT.

* 가능수량.
    IT_TAB-GRMNGL =  IT_TAB-MENGE - IT_TAB-GRMNGS.

* BL생성일
    SELECT SINGLE BLDAT
     INTO  IT_TAB-IBLDAT
     FROM ZTITBLK
    WHERE IBLNO  EQ IT_TAB-IBLNO.

    MOVE IT_TAB-ICCNO TO IT_TAB-ICCNOT.
    MOVE IT_TAB-GRSEQ TO IT_TAB-GRSEQT.
    MOVE IT_TAB-IBLNO TO IT_TAB-IBLNOT.

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
*"BOX.
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'FIELDNAME'     'BOX',
*          'E' 'KEY'           ' ',

"G/R 관리번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITGRK',
          ' ' 'FIELDNAME'     'IGRNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"자재문서번호.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'seltext_m'     '문서종류',
          ' ' 'REF_TABNAME'   'ZTITGRK',
          ' ' 'FIELDNAME'     'MBLNR',
          'E' 'OUTPUTLEN'     '12',
"자재문서연도.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'seltext_m'     '문서종류',
          ' ' 'REF_TABNAME'   'ZTITGRK',
          ' ' 'FIELDNAME'     'MJAHR',
          'E' 'OUTPUTLEN'     '5',
"전표증빙일.
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITGRK',
          ' ' 'FIELDNAME'     'BLDAT',
          'E' 'OUTPUTLEN'     '12',
"전기일.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'seltext_m'     '문서종류',
          ' ' 'REF_TABNAME'   'ZTITGRK',
          ' ' 'FIELDNAME'     'BUDAT',
          'E' 'OUTPUTLEN'     '12',

"참조전표번호
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITGRK',
          ' ' 'FIELDNAME'     'XBLNR',
          'E' 'OUTPUTLEN'     '20',
"입고선하증권
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITGRK',
          ' ' 'FIELDNAME'     'FRBNR',
          'E' 'OUTPUTLEN'     '20',

"BL발행일
          'S' 'TABNAME'       'IT_HEADER',
          ' ' 'REF_TABNAME'   'ZTITBLK',
          ' ' 'REF_FIELDNAME'  'BLDAT',
          ' ' 'FIELDNAME'     'IBLDAT',
          'E' 'OUTPUTLEN'     '10',



"헤더텍스트.
          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'seltext_m'     '문서종류',
          ' ' 'REF_TABNAME'   'ZTITGRK',
          ' ' 'FIELDNAME'     'BKTXT',
          'E' 'OUTPUTLEN'     '30',

*"공급업체코드
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'EKKO',
*          ' ' 'FIELDNAME'     'LIFNR',
*          ' ' 'OUTPUTLEN'     20,
*          'E' 'HOTSPOT'       'X',
*"공급업체명
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'LFA1',
*          ' ' 'OUTPUTLEN'     50,
*          'E' 'FIELDNAME'     'NAME1',
*"송장금액통화
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'seltext_m'     'Cur',
*          ' ' 'REF_TABNAME'   'ZTITBLHD',
*          ' ' 'FIELDNAME'     'WAERS',
*          'E' 'OUTPUTLEN'     '3',
*"송장금액.
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'seltext_m'     '송장값 (외화)',
*          ' ' 'FIELDNAME'     'TREFWR',
*          ' ' 'CFIELDNAME'    'WAERS',
*          ' ' 'CTABNAME'      'IT_HEADER',
*          'E' 'OUTPUTLEN'     '16',

*>>>>>>>>>LIST
"I/V 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITGRP',
          ' ' 'FIELDNAME'     'ICCIT',
          ' ' 'HOTSPOT'       'X',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'INTLEN'         10,
          ' ' 'KEY'           'X',
          'E' 'OUTPUTLEN'     '12',
"구매전표번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVIT',
          ' ' 'FIELDNAME'     'EBELN',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '12',
"구매문서 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVIT',
          ' ' 'FIELDNAME'     'EBELP',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          'E' 'OUTPUTLEN'     '5',
"B/L.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVIT',
          ' ' 'FIELDNAME'     'IBLNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '12',

"수입의뢰번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVIT',
          ' ' 'FIELDNAME'     'REQNO',
          ' ' 'HOTSPOT'       'X',
          ' ' 'NO_OUT'        'X',
          ' ' 'KEY'           ' ',
          'E' 'OUTPUTLEN'     '12',

"수입의뢰 품목번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITIVIT',
          ' ' 'JUST'          C_CHARL," (R)ight (L)eft (C)ent.
          ' ' 'LZERO'         C_CHARX,
          ' ' 'FIELDNAME'     'REQIT',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',

"통관 관리번호
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITGRK',
          ' ' 'FIELDNAME'     'ICCNO',
          ' ' 'HOTSPOT'       'X',
          'E' 'OUTPUTLEN'     '12',

"자재번호.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISGRIT',
          ' ' 'FIELDNAME'     'MATNR',
          'E' 'OUTPUTLEN'     '20',

"자재내역.
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTISGRIT',
          ' ' 'FIELDNAME'     'TXZ01',
          'E' 'OUTPUTLEN'     '40',
"입고수량
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITGRP',
          ' ' 'FIELDNAME'     'GRMNG',
          ' ' 'QFIELDNAME'    'MEINS',
          ' ' 'QTABNAME'      'IT_LIST',
          'E' 'OUTPUTLEN'     '16',
"기본단위
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITGRP',
          ' ' 'FIELDNAME'     'MEINS',
          ' ' 'INTLEN'         10,
          'E' 'OUTPUTLEN'     '4',

*"수입의뢰수량
*          'S' 'TABNAME'       'IT_LIST',
**          ' ' 'REF_TABNAME'   'ZTISBLIT',
*          ' ' 'seltext_m'     '수입의뢰수량',
*          ' ' 'FIELDNAME'     'MENGE',
*          ' ' 'QFIELDNAME'    'MEINS',
*          ' ' 'QTABNAME'      'IT_LIST',
*          ' ' 'NO_OUT'        'X',
*          'E' 'OUTPUTLEN'     '15',
*"B/L가능수량
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISBLIT',
**          ' ' 'seltext_m'     '수입의뢰수량',
*          ' ' 'FIELDNAME'     'BLMNGL',
*          ' ' 'QFIELDNAME'    'MEINS',
*          ' ' 'QTABNAME'      'IT_LIST',
*          ' ' 'NO_OUT'        'X',
*          'E' 'KEY'           ' ',
*"B/L누적수량
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISBLIT',
**          ' ' 'seltext_m'     '수입의뢰수량',
*          ' ' 'FIELDNAME'     'BLMNGS',
*          ' ' 'QFIELDNAME'    'MEINS',
*          ' ' 'QTABNAME'      'IT_LIST',
*          ' ' 'NO_OUT'        'X',
*          'E' 'KEY'           ' ',
*"B/L수량
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISBLIT',
**          ' ' 'seltext_m'     '수입의뢰수량',
*          ' ' 'QFIELDNAME'    'MEINS',
*          ' ' 'QTABNAME'      'IT_LIST',
*          ' ' 'NO_OUT'        'X',
*          ' ' 'FIELDNAME'     'BLMNG',
*          'E' 'KEY'           ' ',
*"송장가능수량
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTISIVIT',
*          ' ' 'seltext_m'     'I/V가능수량    ',
*          ' ' 'FIELDNAME'     'IVMNGL',
*          ' ' 'QFIELDNAME'    'MEINS',
*          ' ' 'QTABNAME'      'IT_LIST',
*          'E' 'OUTPUTLEN'     '16',
*"기본단위
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTITBLIT',
*          ' ' 'FIELDNAME'     'MEINS',
*          ' ' 'INTLEN'         10,
*          'E' 'OUTPUTLEN'     '4',
*"송장금액.
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'seltext_m'     '송장값',
*          ' ' 'FIELDNAME'     'REFWR',
*          ' ' 'CFIELDNAME'    'WAERS',
*          ' ' 'JUST'          c_charr," (R)ight (L)eft (C)ent.
**          ' ' 'LZERO'         c_charx,
*          ' ' 'CTABNAME'      'IT_HEADER',
*          'E' 'OUTPUTLEN'     '20',
*"자재문서번호
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTITBLIT',
*          ' ' 'FIELDNAME'     'MBLNR',
*          ' ' 'NO_OUT'        'X',
*          'E' 'OUTPUTLEN'     '10',
*"자재문서연도
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTITBLIT',
*          ' ' 'FIELDNAME'     'MJAHR',
*          ' ' 'NO_OUT'        'X',
*          'E' 'OUTPUTLEN'     '10',
*"자재문서품목
*          'S' 'TABNAME'       'IT_LIST',
*          ' ' 'REF_TABNAME'   'ZTITBLIT',
*          ' ' 'FIELDNAME'     'ZEILE',
*          ' ' 'NO_OUT'        'X',
**          'E' 'OUTPUTLEN'     '10'.
"작성인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLIT',
          ' ' 'FIELDNAME'     'CNAM',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10',
"최종변경인
          'S' 'TABNAME'       'IT_LIST',
          ' ' 'REF_TABNAME'   'ZTITBLIT',
          ' ' 'FIELDNAME'     'UNAM',
          ' ' 'NO_OUT'        'X',
          'E' 'OUTPUTLEN'     '10'.



**************************************************
**  frequently.
*  PERFORM 3010_fill_field_category USING :
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'REF_TABNAME'   'ZTITIVHD',
*          ' ' 'SELTEXT_M'     '',
*          ' ' 'FIELDNAME'     '',
*          ' ' 'HOTSPOT'       '',
*          ' ' 'OUTPUTLEN'     '',
*          ' ' 'NO_OUT'        '',
*          ' ' 'CFIELDNAME'    'WAERS',
*          ' ' 'CTABNAME'      'IT_HEADER',
*          ' ' 'QFIELDNAME'    'MEINS',
*          ' ' 'QTABNAME'      'IT_LIST',
*          'E' 'KEY'           ''.
*"BOX.
*          'S' 'TABNAME'       'IT_HEADER',
*          ' ' 'FIELDNAME'     'BOX',
*          'E' 'KEY'           ' '.

*  CLEAR  gs_fieldcat.
*  gs_fieldcat-tabname   = 'IT_HEADER'.
*  gs_fieldcat-fieldname = 'BOX'.
*  APPEND  gs_fieldcat TO it_fieldcat.
*
** Build the fieldcat according to DDIC structure SBOOK:
*  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
*    EXPORTING
*      i_structure_name   = 'ZTITGRK'
*      i_internal_tabname = 'IT_HEADER'
*    CHANGING
*      ct_fieldcat        = it_fieldcat[].
*
*  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
*    EXPORTING
*      i_structure_name   = 'ZTISGRIT'
*      i_internal_tabname = 'IT_LIST'
*    CHANGING
*      ct_fieldcat        = it_fieldcat[].
*
*  CLEAR  gs_fieldcat.
*  gs_fieldcat-tabname   = 'IT_HEADER'.
*  gs_fieldcat-fieldname = 'IGRSTX'.
*  APPEND  gs_fieldcat TO it_fieldcat.
*  CLEAR  gs_fieldcat.
*
*  LOOP AT it_fieldcat INTO gs_fieldcat.
*
*    IF   ( gs_fieldcat-fieldname = 'IGRNO'
*           and gs_fieldcat-tabname = 'IT_HEADER')
*      OR ( gs_fieldcat-fieldname = 'IBLNO'
*           and gs_fieldcat-tabname = 'IT_HEADER')
*      OR ( gs_fieldcat-fieldname = 'ICCNO'
*           and gs_fieldcat-tabname = 'IT_HEADER')
*      OR ( gs_fieldcat-fieldname = 'GRSEQ'
*           and gs_fieldcat-tabname = 'IT_HEADER')
*      OR gs_fieldcat-fieldname = 'IGRSTX'
**      OR gs_fieldcat-fieldname = 'IGRST'
*      OR gs_fieldcat-fieldname = 'ICCIT'
**      OR gs_fieldcat-fieldname = 'IBLNOt'
**      OR gs_fieldcat-fieldname = 'IBLIT'
**      OR gs_fieldcat-fieldname = 'ICCNOt'
**      OR gs_fieldcat-fieldname = 'GRSEQt'
*      OR gs_fieldcat-fieldname = 'EBELN'
*      OR gs_fieldcat-fieldname = 'EBELP'
*      OR gs_fieldcat-fieldname = 'MATNR'
*      OR gs_fieldcat-fieldname = 'TXZ01'
*      OR gs_fieldcat-fieldname = 'MEINS'
*      OR gs_fieldcat-fieldname = 'GRMNG'.
*
*      CLEAR gs_fieldcat-no_out.
*    ELSE.
*      gs_fieldcat-no_out = 'X'.
*    ENDIF.
*    gs_fieldcat-col_pos = ' '.
*    MODIFY it_fieldcat FROM gs_fieldcat INDEX sy-tabix.
*
*  ENDLOOP.

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

  GS_KEYINFO-HEADER01 = 'IGRNO'.
  GS_KEYINFO-ITEM01   = 'IGRNO'.

  GS_KEYINFO-HEADER02 =  SPACE.
  GS_KEYINFO-ITEM02   = 'ICCIT'.

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
  GS_LISTHEADER-INFO = '외자 입고 현황'(T13).
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
  LS_SORT-FIELDNAME = 'IGRNO'.
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

*  MOVE: 'BOX'        TO gs_layout-box_fieldname,
*        'IT_HEADER'  TO gs_layout-box_tabname.

*  MOVE: '3'          TO gs_layout-no_vline. " 분리자 라인.
*  clear ls_variant.
*  ls_variant = p_vari.


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

  DATA : LS_LIST TYPE TY_TAB.

  CLEAR: LS_LIST.

  CASE R_UCOMM.
    WHEN '&REFRESH'.
      PERFORM P9000_DUELIST_REFRESH USING  RS_SELFIELD.

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
        WHEN 'REQNO'.
          PERFORM  DISPLAY_IMPORT_DOCUMENT(ZTIR0000)
                                          USING LS_LIST-REQNO
                                                SPACE
                                                LS_LIST-REQIT.

        WHEN 'IBLNO' OR 'IBLIT'.
          PERFORM  DISPLAY_BL_DOCUMENT(ZTIR0000)
                                          USING LS_LIST-IBLNO
                                                LS_LIST-IBLIT.

        WHEN 'ICCNO'.
          PERFORM  DISPLAY_CC_DOCUMENT(ZTIR0000)
                                          USING LS_LIST-ICCNO
                                                '00'.

        WHEN 'IGRNO'.
          PERFORM  DISPLAY_GR_DOCUMENT(ZTIR0000)
                                          USING LS_LIST-IGRNO.

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
  SET TITLEBAR 'T1000' WITH 'Due List'(T10).

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ALV_DISPLAY  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ALV_DISPLAY OUTPUT.


  IF GS_ALV_GRID IS INITIAL.

    CREATE OBJECT GS_ALV_GRID
      EXPORTING
        I_PARENT = CL_GUI_CUSTOM_CONTAINER=>DEFAULT_SCREEN.

    PERFORM MAKE_MAIN_LIST.  "MAIN LIST

  ELSE.
*---// ALV Refresh - Column & line fix
*     PERFORM REFRESH_TABLE_DISPLAY USING GS_ALV_GRID.
  ENDIF.


ENDMODULE.                 " ALV_DISPLAY  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.


  CASE SY-UCOMM.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      FORM  MAKE_MAIN_LIST
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
*  -->  P1        TEXT
*  <--  P2        TEXT
*----------------------------------------------------------------------*
FORM MAKE_MAIN_LIST .

  PERFORM ALV_VARIANT.         " ALV VARIANT
  PERFORM ALV_SORT.            " SORT1
*  PERFORM ALV_LAYOUT.          " GENERAL LAYOUT
  PERFORM ALV_FIELDCATALOG.    " FIELD ATTRIBUTE
  PERFORM ALV_TOOLBAR_EXCLUDE. " TOOLBAR DIM
  PERFORM ALV_DISPLAY.         " DISPLAY
  PERFORM ALV_EVENT.           " EVENT

*--//EDIT (0: EIDT 불가, 1: EDIT 가능)
  CALL METHOD GS_ALV_GRID->SET_READY_FOR_INPUT
    EXPORTING
      I_READY_FOR_INPUT = 1.

ENDFORM.                    "MAKE_MAIN_LIST

*&---------------------------------------------------------------------*
*&      FORM  ALV_VARIANT
*&---------------------------------------------------------------------*
FORM ALV_VARIANT .
  CLEAR GS_VARIANT.
  GS_VARIANT-REPORT    = SY-REPID.     "프로그램명
  GS_VARIANT-USERNAME  = SY-UNAME.     "사용자
  GS_VARIANT-HANDLE    = 1.
ENDFORM.                    " ALV_VARIANT

*&---------------------------------------------------------------------*
*&      FORM  ALV_SORT
*&---------------------------------------------------------------------*
FORM ALV_SORT.

  CLEAR : GT_SORT, GT_SORT[].

*  PERFORM SORT_FIELD TABLES GT_SORT USING :
*      1  'INV_TYPE'         'X' ' ' '',
*      2  'LIFNR'            'X' ' ' '',
*      3  'WERKS'            'X' ' ' ''.
*


ENDFORM.                                                    " ALV_SORT

*&---------------------------------------------------------------------*
*&      FORM  SORT_FIELD
*&---------------------------------------------------------------------*
FORM SORT_FIELD  TABLES PT_SORT TYPE LVC_T_SORT
                 USING    P_SPOS
                          P_FIELDNAME
                          P_UP
                          P_DOWN
                          P_SUBTOT.
  PT_SORT-SPOS      = P_SPOS.
  PT_SORT-FIELDNAME = P_FIELDNAME.
  PT_SORT-UP        = P_UP.
  PT_SORT-DOWN      = P_DOWN.
  PT_SORT-SUBTOT    = P_SUBTOT.

  APPEND PT_SORT.
ENDFORM.                    " SORT_FIELD

*&---------------------------------------------------------------------*
*&      FORM  ALV_LAYOUT
*&---------------------------------------------------------------------*
FORM ALV_LAYOUT .
  CLEAR GS_LAYOUT_1.
  GS_LAYOUT_1-ZEBRA      = 'X'.          " LINE COLOR
*  GS_LAYOUT_1-CWIDTH_OPT = 'X'.          " ALV 제어: 열너비최적화
  GS_LAYOUT_1-INFO_FNAME = 'INFO'.       " ROW COLOR.
  GS_LAYOUT_1-CTAB_FNAME = 'COLINFO'.    " COLUMN COLOR.
  GS_LAYOUT_1-STYLEFNAME = 'STYLE'.
  GS_LAYOUT_1-SEL_MODE   = 'D'.
*  GS_LAYOUT_1-NO_ROWMARK = 'X'.
*  GS_LAYOUT_1-GRID_TITLE = SY-TITLE.

ENDFORM.                    " ALV_LAYOUT

*&---------------------------------------------------------------------*
*&      FORM  ALV_FIELDCATALOG
*&---------------------------------------------------------------------*
FORM ALV_FIELDCATALOG .

  CLEAR: GT_FIELDCAT, GT_FIELDCAT[], GT_FIELD, GT_FIELD[].

* 선언된 인터럴 테이블 값을 가지고 옴
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = 'IT_LIST_ALV'
*      I_STRUCTURE_NAME   = 'IT_ITEM1'
      I_INCLNAME         = SY-REPID
    CHANGING
      CT_FIELDCAT        = GT_FIELD[].

* 펑션구조로된 FIELDCAT을 클래스 FIELDCAT으로 변환
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = GT_FIELD
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT[]
    TABLES
      IT_DATA         = IT_TAB
    EXCEPTIONS
      IT_DATA_MISSING = 1
      OTHERS          = 2.



  LOOP AT GT_FIELDCAT.

    GT_FIELDCAT-COL_OPT = C_X.

*-  필드명 정의
    CASE GT_FIELDCAT-FIELDNAME.
      WHEN 'IGRNO'  OR 'MBLNR' OR 'MJAHR' OR 'BLDAT' OR
           'BUDAT'   .
        GT_FIELDCAT-EMPHASIZE = C_COL_BLUE1.
        GT_FIELDCAT-KEY = C_X.


      WHEN  'XBLNR' OR 'FRBNR' OR 'IBLDAT' OR 'BKTXT'.
        GT_FIELDCAT-EMPHASIZE = C_COL_BLUE.

      WHEN 'EBELN' OR 'EBELP' OR 'IBLNOT' OR  'IBLIT'  OR
           'REQNO' OR 'REQIT' OR 'ICCNOT' OR  'ICCIT' .
        GT_FIELDCAT-EMPHASIZE = C_COL_GREEN.

      WHEN   'MATNR' OR 'TXZ01' OR  'GRMNG' OR  'MEINS'  OR
             'MEINS' .
        GT_FIELDCAT-EMPHASIZE = C_COL_YELLOW.


      WHEN OTHERS .
        GT_FIELDCAT-NO_OUT = C_X.

    ENDCASE.


    IF GT_FIELDCAT-FIELDNAME EQ 'IGRNO'  OR
       GT_FIELDCAT-FIELDNAME EQ 'ICCNOT' OR
       GT_FIELDCAT-FIELDNAME EQ 'ICCIT'  OR
       GT_FIELDCAT-FIELDNAME EQ 'EBELN'  OR
       GT_FIELDCAT-FIELDNAME EQ 'EBELP'  OR
       GT_FIELDCAT-FIELDNAME EQ 'IBLNOT' OR
       GT_FIELDCAT-FIELDNAME EQ 'IBLIT' OR
       GT_FIELDCAT-FIELDNAME EQ 'REQNO'  .

      GT_FIELDCAT-HOTSPOT = C_X.
    ENDIF.


    IF GT_FIELDCAT-COLTEXT IS NOT INITIAL.
      GT_FIELDCAT-SCRTEXT_L = GT_FIELDCAT-SCRTEXT_M =
      GT_FIELDCAT-SCRTEXT_S = GT_FIELDCAT-COLTEXT .
    ENDIF.


    CLEAR GT_FIELDCAT-KEY.
    MODIFY GT_FIELDCAT.
  ENDLOOP.



ENDFORM.                    " ALV_FIELDCATALOG

*&---------------------------------------------------------------------*
*&      FORM  ALV_TOOLBAR_EXCLUDE
*&---------------------------------------------------------------------*
FORM ALV_TOOLBAR_EXCLUDE.

  PERFORM ALV_TOOLBAR_EXCLUDE_SET USING :
*          CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL,    " ** 툴바 모두제거 **
          CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,     " 실행취소 &LOCAL&UNDO
*          CL_GUI_ALV_GRID=>MC_FC_AUF,         " 소계확장 &AUF
*          CL_GUI_ALV_GRID=>MC_FC_AVERAGE,     " &AVERAGE
*          CL_GUI_ALV_GRID=>MC_FC_BACK_CLASSIC,
*          CL_GUI_ALV_GRID=>MC_FC_CALL_ABC,    " &ABC
*          CL_GUI_ALV_GRID=>MC_FC_CALL_CHAIN,
*          CL_GUI_ALV_GRID=>MC_FC_CALL_CRBATCH,
*          CL_GUI_ALV_GRID=>MC_FC_CALL_CRWEB,
*          CL_GUI_ALV_GRID=>MC_FC_CALL_LINEITEMS,
*          CL_GUI_ALV_GRID=>MC_FC_CALL_MASTER_DATA,
*          CL_GUI_ALV_GRID=>MC_FC_CALL_MORE,
*          CL_GUI_ALV_GRID=>MC_FC_CALL_REPORT,
*          CL_GUI_ALV_GRID=>MC_FC_CALL_XINT,
*          CL_GUI_ALV_GRID=>MC_FC_CALL_XXL,
*          CL_GUI_ALV_GRID=>MC_FC_COL_INVISIBLE,
*          CL_GUI_ALV_GRID=>MC_FC_COL_OPTIMIZE,
*          CL_GUI_ALV_GRID=>MC_FC_CURRENT_VARIANT,
*          CL_GUI_ALV_GRID=>MC_FC_DATA_SAVE,
*          CL_GUI_ALV_GRID=>MC_FC_DELETE_FILTER,
*          CL_GUI_ALV_GRID=>MC_FC_DESELECT_ALL,
*          CL_GUI_ALV_GRID=>MC_FC_DETAIL,
*          CL_GUI_ALV_GRID=>MC_FC_EXPCRDATA,
*          CL_GUI_ALV_GRID=>MC_FC_EXPCRDESIG,
*          CL_GUI_ALV_GRID=>MC_FC_EXPCRTEMPL,
*          CL_GUI_ALV_GRID=>MC_FC_EXPMDB,
*          CL_GUI_ALV_GRID=>MC_FC_EXTEND,
*          CL_GUI_ALV_GRID=>MC_FC_F4,
*          CL_GUI_ALV_GRID=>MC_FC_FILTER,
*          CL_GUI_ALV_GRID=>MC_FC_FIND,
*          CL_GUI_ALV_GRID=>MC_FC_FIX_COLUMNS,
*          CL_GUI_ALV_GRID=>MC_FC_GRAPH,
*          CL_GUI_ALV_GRID=>MC_FC_HELP,
*          CL_GUI_ALV_GRID=>MC_FC_INFO,
*          CL_GUI_ALV_GRID=>MC_FC_LOAD_VARIANT,
          CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,          " 행 카피.
*          CL_GUI_ALV_GRID=>MC_FC_HTML,
          CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,      " 행 카피.
          CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,           " 가위.
          CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,    " 행삭제.
          CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,    " 행삽입.
*          CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW,
          CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,    " 라인생성.
          CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,         " 겹쳐쓰기.
          CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW, " 겹쳐쓰기.
*          CL_GUI_ALV_GRID=>MC_FC_MAINTAIN_VARIANT,
*          CL_GUI_ALV_GRID=>MC_FC_MAXIMUM,
*          CL_GUI_ALV_GRID=>MC_FC_MINIMUM,
*          CL_GUI_ALV_GRID=>MC_FC_PC_FILE,
*          CL_GUI_ALV_GRID=>MC_FC_PRINT,
*          CL_GUI_ALV_GRID=>MC_FC_PRINT_BACK,
*          CL_GUI_ALV_GRID=>MC_FC_PRINT_PREV,
          CL_GUI_ALV_GRID=>MC_FC_REFRESH.           " 새로고침.
*          CL_GUI_ALV_GRID=>MC_FC_REPREP,
*          CL_GUI_ALV_GRID=>MC_FC_SAVE_VARIANT,
*          CL_GUI_ALV_GRID=>MC_FC_SELECT_ALL,
*          CL_GUI_ALV_GRID=>MC_FC_SEND,
*          CL_GUI_ALV_GRID=>MC_FC_SEPARATOR,
*          CL_GUI_ALV_GRID=>MC_FC_SORT,
*          CL_GUI_ALV_GRID=>MC_FC_SORT_ASC,
*          CL_GUI_ALV_GRID=>MC_FC_SORT_DSC,
*          CL_GUI_ALV_GRID=>MC_FC_SUBTOT,
*          CL_GUI_ALV_GRID=>MC_FC_SUM,
*          CL_GUI_ALV_GRID=>MC_FC_TO_OFFICE,
*          CL_GUI_ALV_GRID=>MC_FC_TO_REP_TREE,
*          CL_GUI_ALV_GRID=>MC_FC_UNFIX_COLUMNS,
*          CL_GUI_ALV_GRID=>MC_FC_VIEWS,
*          CL_GUI_ALV_GRID=>MC_FC_VIEW_CRYSTAL,
*          CL_GUI_ALV_GRID=>MC_FC_VIEW_EXCEL,
*          CL_GUI_ALV_GRID=>MC_FC_VIEW_GRID,
*          CL_GUI_ALV_GRID=>MC_FC_WORD_PROCESSOR.

ENDFORM.                    " ALV_TOOLBAR_EXCLUDE

*&---------------------------------------------------------------------*
*&      FORM  ALV_TOOLBAR_EXCLUDE_SET
*&---------------------------------------------------------------------*
*       툴바 설정
*----------------------------------------------------------------------*
FORM ALV_TOOLBAR_EXCLUDE_SET  USING    VALUE(P_TEXT).

  DATA LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = P_TEXT.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.

ENDFORM.                    " ALV_TOOLBAR_EXCLUDE_SET

*&---------------------------------------------------------------------*
*&      FORM  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       ALV DISPLAY
*----------------------------------------------------------------------*
FORM ALV_DISPLAY .

  CALL METHOD GS_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_DEFAULT            = 'X'
      IS_LAYOUT            = GS_LAYOUT_1
      IS_VARIANT           = GS_VARIANT
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
      I_SAVE               = 'A'
    CHANGING
      IT_OUTTAB            = IT_TAB[]
      IT_FIELDCATALOG      = GT_FIELDCAT[]
      IT_SORT              = GT_SORT.

ENDFORM.                    " ALV_DISPLAY

*&---------------------------------------------------------------------*
*&      FORM  ALV_EVENT
*&---------------------------------------------------------------------*
*       EVENT
*----------------------------------------------------------------------*
FORM ALV_EVENT .

  CREATE OBJECT GS_EVENT_RECEIVER.

*--// ALV 변경사항 관리
  SET HANDLER
     GS_EVENT_RECEIVER->HANDLE_DATA_CHANGED  FOR GS_ALV_GRID.

* EDIT후 CHANGE EVENT
  CALL METHOD GS_ALV_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

*--// HOTSPOT CLICK EVENT
  SET HANDLER
     GS_EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK FOR GS_ALV_GRID.

*--// DOUBLE CLICK EVENT
  SET HANDLER
     GS_EVENT_RECEIVER->HANDLE_DOUBLE_CLICK FOR GS_ALV_GRID.

*--// TOOLBAR EVENT
  SET HANDLER
     GS_EVENT_RECEIVER->HANDLE_TOOLBAR      FOR GS_ALV_GRID.

*--// USER COMMAND EVENT
  SET HANDLER
     GS_EVENT_RECEIVER->HANDLE_USER_COMMAND FOR GS_ALV_GRID.

*--// F4 EVENT
  SET HANDLER
     GS_EVENT_RECEIVER->HANDLE_ONF4         FOR GS_ALV_GRID.

ENDFORM.                    "ALV_EVENT

*&---------------------------------------------------------------------*
*&      Form  HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SENDER   text
*      -->P_ROW      text
*      -->P_COLUMN   text
*----------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK  USING  P_SENDER
                                  P_ROW    TYPE LVC_S_ROW-INDEX
                                  P_COLUMN TYPE LVC_S_COL-FIELDNAME.

  CHECK NOT P_ROW IS INITIAL.

  IF P_SENDER EQ GS_ALV_GRID.

    READ TABLE IT_LIST INDEX P_ROW.

    CASE P_COLUMN.
       WHEN 'EBELN' OR 'EBELP'.
          PERFORM  DISPLAY_PURCHASE_ORDER(ZTIR0000)
                                          USING IT_LIST-EBELN
                                                IT_LIST-EBELP.
        WHEN 'REQNO'.
          PERFORM  DISPLAY_IMPORT_DOCUMENT(ZTIR0000)
                                          USING IT_LIST-REQNO
                                                SPACE
                                                IT_LIST-REQIT.

        WHEN 'IBLNOT' OR 'IBLIT'.
          PERFORM  DISPLAY_BL_DOCUMENT(ZTIR0000)
                                          USING IT_LIST-IBLNOT
                                                IT_LIST-IBLIT.

        WHEN 'ICCNOT' OR 'ICCIT'.
          PERFORM  DISPLAY_CC_DOCUMENT(ZTIR0000)
                                          USING IT_LIST-ICCNOT
                                                '00'.

        WHEN 'IGRNO'.
          PERFORM  DISPLAY_GR_DOCUMENT(ZTIR0000)
                                          USING IT_LIST-IGRNO.

    ENDCASE.
  ENDIF.




ENDFORM.                    " HANDLE_HOTSPOT_CLICK
