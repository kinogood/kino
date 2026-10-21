************************************************************************
*                                                                      *
* Title         : ZTIR0030                                             *
*                                                                      *
* Description   : [Report] 수입요청 승인 관리                          *
*                                                                      *
* Creation Date : 2004/02/04                                           *
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
*   1.                                                                 *
*                                                                      *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* 2009.01.16    MMB03            by  C20090114_85960                   *
*                                    승인/반려시 날짜,시간 추가        *
************************************************************************
PROGRAM   ZTIR0030
          MESSAGE-ID ZMTI00
          NO STANDARD PAGE HEADING.
************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: SLIS.   "> Globale Type(ALV)
************************************************************************
* User Included                                                        *
************************************************************************
INCLUDE ZTS_REUSE_BDC_SUBROUTINE_F00.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: L_YN    TYPE C.
INCLUDE ZTS_AUTHORIZATION_CHECK. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* Internal Tables                                                      *
************************************************************************

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: T001,      ">Company Codes
        T001W,     ">Plants/Branches
        T001K,     ">Valuation area
        T161,      ">Purchasing Document Types
        T134,      ">Material Types
        T134T,     ">Material Types Descriptions
        T024D,     ">MRP controllers
        MARA,      ">General Material Data
        MARC,      ">Plant Data for Material
        MARD,      ">Storage Location Data for Material
        MSLB,      ">Special Stocks with Vendor
        MBEW,      ">Material Valuation
        MARCH,     ">Plant Data for Material: History
        MARDH,     ">Storage Location Data for Material: History
        MSLBH,     ">Special Stocks with Vendor: History
        MBEWH,     ">Material Valuation: History
        MKPF,      ">Header: Material Document
        MSEG,      ">Document Segment: Material
        MAKT,      ">Material Descriptions
        ZTITIG00,  ">회사별 프로세스 정의
        MARM,      ">Units of Measure for Material
        LFA1  ,    ">Vendor Master (General Section)
        LFB1  ,    ">Vendor Master (Company Code)
        T024E ,    ">Purchasing Organizations
        T024  ,    ">Purchasing Groups
        T163B ,    ">TEXT
        T163C ,    ">TEXT
        T685T ,    ">TEXT
        ZTITRQK,
        ZTITRQS,
        EKBZ  ,    ">History per Purchasing Document: Delivery Costs
        EKBE  ,    ">History per Purchasing Document
        EKKO,      ">Purchasing Document Header
        EKPO  ,    ">Purchasing Document Items
        EKKN,      ">Account Assignment in Purchasing Document
        DFIES ,    ">DD Interface: Table Fields for DDIF_FIELDINFO_GET
        SPOP  ,    ">POPUP_TO_CONFIRM_... function 모듈 팝업화면 필드.
        ZTISSCRCOM, ">수출입시스템 Screen용 Structure(공용)
        ZTIVRQ02.  ">header + status Views

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 KSH --------------------------------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 KSH --------------------------------------
    C_SAVE(1)   TYPE  C             VALUE 'A',
    C_ERROR     TYPE  C             VALUE 'E'.

DATA: BEGIN OF IT_REQNO OCCURS 1,
      REQNO    TYPE ZTIREQNO,
      AMDSQ    TYPE ZTIAMDSQ,
      RETXT    TYPE ZTIRETXT,
      END   OF IT_REQNO.

DATA:
       GS_EVENTS   TYPE SLIS_ALV_EVENT,
       GT_EVENTS   TYPE SLIS_T_EVENT,
       GS_GRIDSET  TYPE LVC_S_GLAY.


************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK BOX1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS:
  S_BUKRS  FOR ZTITRQK-BUKRS
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID BUK,           "회사코드.
  S_EKORG  FOR ZTITRQK-EKORG,                  "구매조직.
  S_EKGRP  FOR ZTITRQK-EKGRP,                  "구매그룹.
  S_REQNO  FOR ZTITRQK-REQNO                   "수입의뢰 관리번호.
                    MEMORY ID ZTIREQNO,
  S_AMDSQ  FOR ZTITRQS-AMDSQ                   "Amend 차수.
                    MEMORY ID ZTIAMDSQ,
  S_REQTY  FOR ZTITRQK-REQTY,                  "수입의뢰 종류.
  S_ILCTY  FOR ZTITRQK-ILCTY,                  "신용장 종류.
  S_LIFNR  FOR ZTITRQK-LIFNR,                  "공급업체 계정번호.
  S_REQDT  FOR ZTITRQS-REQDT MODIF ID REQ,     "개설희망일자.
  S_APPUN  FOR ZTITRQS-APPUN MODIF ID REQ,     "개설의뢰 요청자.
  S_APPDT  FOR ZTITRQS-APPDT MODIF ID REQ,     "개설의뢰 요청일.
  S_ACCUN  FOR ZTITRQS-ACCUN MODIF ID APY,     "요청접수 담당자.
  S_ACCDT  FOR ZTITRQS-ACCDT MODIF ID APY,     "요청접수일자.
  S_SNDUN  FOR ZTITRQS-SNDUN MODIF ID SED,     "개설신청자.
  S_SNDDT  FOR ZTITRQS-SNDDT MODIF ID SED,     "개설신청일.
  S_RCVUN  FOR ZTITRQS-RCVUN MODIF ID OPN,     "개설등록자.
  S_RCVDT  FOR ZTITRQS-RCVDT MODIF ID OPN.     "개설등록일자.
SELECTION-SCREEN ULINE.
PARAMETERS: P_STEP1 RADIOBUTTON GROUP AB1  DEFAULT 'X'  MODIF ID M1,
            P_STEP2 RADIOBUTTON GROUP AB1               MODIF ID M1,
            P_STEP3 RADIOBUTTON GROUP AB1               MODIF ID M1.

SELECTION-SCREEN ULINE.
SELECT-OPTIONS:
  S_LIFRE  FOR ZTITRQK-LIFRE,                  "다른 송장발행처.
  S_OFFER  FOR ZTITRQK-OFFER,                  "오퍼상(Offer).
  S_OPNBK  FOR ZTITRQK-OPNBK MODIF ID SED,     "개설은행.
  S_ZTERM  FOR ZTITRQS-ZTERM,                  "지급조건키.
  S_WAERS  FOR ZTITRQS-WAERS,                  "개설통화.
  S_INCO1  FOR ZTITRQS-INCO1,                  "인도조건 (파트 1).
  S_EXDAT  FOR ZTITRQS-EXDAT,                  "유효기일.
  S_LSDAT  FOR ZTITRQS-LSDAT,                  "최종선적일자.
  S_FLAND  FOR ZTITRQS-FLAND,                  "선적국가.
  S_FPORT  FOR ZTITRQS-FPORT,                  "선적항.
  S_OPNNO  FOR ZTITRQS-OPNNO MODIF ID OPN,     "수입개설번호
  S_OPNDT  FOR ZTITRQS-OPNDT MODIF ID OPN,     "개설일자.
  S_CNAM   FOR ZTITRQS-CNAM,                   "작성인.
  S_CDAT   FOR ZTITRQS-CDAT,                   "생성일.
  S_UNAM   FOR ZTITRQS-UNAM,                   "최종변경인.
  S_UDAT   FOR ZTITRQS-UDAT.                   "변경일.

PARAMETERS: P_FULL RADIOBUTTON GROUP AB2 DEFAULT 'X',
            P_LIST RADIOBUTTON GROUP AB2.
SELECTION-SCREEN END OF BLOCK BOX1.

*> Report variant
SELECTION-SCREEN: BEGIN OF BLOCK ALV WITH FRAME TITLE TEXT-003.
PARAMETERS: ALV_DEF LIKE DISVARIANT-VARIANT.
SELECTION-SCREEN: END OF BLOCK ALV.



************************************************************************
* Internal Tables                                                      *
************************************************************************
*> 공급업체명
DATA : BEGIN OF XLFA1 OCCURS 0,
       LIFNR           LIKE   LFA1-LIFNR,
       NAME1           LIKE   LFA1-NAME1.
DATA : END   OF XLFA1.


DATA: IT_FIELDCAT_G TYPE LVC_T_FCAT,
      GS_FIELDCAT_G LIKE LINE OF IT_FIELDCAT_G.

*---------------------------------------------------------------------*
*> Message dialog box용                                               *
*---------------------------------------------------------------------*
DATA: BEGIN OF IT_MSG  OCCURS 0.
        INCLUDE STRUCTURE ZTISMESSAGE.
DATA: END   OF IT_MSG.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
*---------------------------------------------------------------------
* Accumulators
*---------------------------------------------------------------------
*DATA:
*  BEGIN OF A,
*
*  END OF A.
*
*
*----------------------------------------------------------------------
* Switches
*----------------------------------------------------------------------
DATA: BEGIN OF FC_STRUCT,
        TABNAME(7),
        FIELDNAME(6),
        REF_TABNAME(29),
        REF_FIELDNAME(6),
        NO_OUT(1),
        CQINDICATOR(1),
        CQFIELD(6),
      END OF FC_STRUCT.

DATA: S_VARIANT      LIKE  DISVARIANT,
      S_VAR_USR      LIKE  DISVARIANT.

*----------------------------------------------------------------------
* Work fields
*----------------------------------------------------------------------
DATA : G_LINE          TYPE   I,             "Line counter
       G_SUBRC         LIKE   SY-SUBRC,      "Return code
       G_TABIX         LIKE   SY-TABIX,      "table index
       G_LINE1(3)      TYPE   N,             "LINE COUNT
       G_OUT_TEXT(70)  TYPE   C,             "text field(display)
       G_ERR_MODE      TYPE   C,
       LINE_CNT(02)    TYPE   N,
       OK-CODE         LIKE   SY-UCOMM,
       FIELD_NAME(20),
       FIELD_NAME1(20).

* Global variables for handling ALV functionality
DATA: ALV_KEYINFO      TYPE SLIS_KEYINFO_ALV.
DATA: ALV_VARIANT      LIKE DISVARIANT.
DATA: GS_LAYOUT        TYPE SLIS_LAYOUT_ALV.
DATA: ALV_REPID        LIKE SY-REPID.
DATA: ALV_PRINT        TYPE SLIS_PRINT_ALV.
DATA: ST_SORT          TYPE SLIS_SORTINFO_ALV.

DATA: ALV_DETAIL_FUNC(30).
DATA: FC       TYPE SLIS_T_FIELDCAT_ALV,
      FC1      TYPE SLIS_T_FIELDCAT_ALV,
      FCS      TYPE SLIS_FIELDCAT_ALV,
      IT_SORT  TYPE SLIS_T_SORTINFO_ALV.

************************************************************************
* RANGES
************************************************************************
*RANGES:
*   XXXT FOR XXX-XXX OCCURS 1.

***********************************************************************
* FIELD-GROUPS
***********************************************************************
*FIELD-GROUPS:

***********************************************************************
* FIELD-SYMBOLS
***********************************************************************
FIELD-SYMBOLS: <FS>  TYPE ANY,
               <FSL> TYPE ANY,
               <FSS> TYPE ANY.

FIELD-SYMBOLS: <GT_TABLE> TYPE TABLE.

************************************************************************
* MACRO DEFINE                                                         *
************************************************************************
DEFINE AC.
  CLEAR:  FCS, FC_STRUCT.
  FC_STRUCT         = &1.
  FCS-TABNAME        = FC_STRUCT-TABNAME.
  FCS-FIELDNAME      = FC_STRUCT-FIELDNAME.
  FCS-REF_TABNAME    = FC_STRUCT-REF_TABNAME.
  FCS-REF_FIELDNAME  = FC_STRUCT-REF_FIELDNAME.
  FCS-NO_OUT         = FC_STRUCT-NO_OUT.

  CASE FC_STRUCT-CQINDICATOR.
    WHEN 'C'.
      FCS-CFIELDNAME = FC_STRUCT-CQFIELD.
    WHEN 'Q'.
      FCS-QFIELDNAME = FC_STRUCT-CQFIELD.
  ENDCASE.
  APPEND FCS TO FC.
END-OF-DEFINITION.

DEFINE AC_1.
  CLEAR: FCS, FC_STRUCT.
*  FC_STRUCT         = &1.
  FCS-TABNAME        = &1.
  FCS-FIELDNAME      = &2.
  FCS-REF_TABNAME    = &3.
  FCS-REF_FIELDNAME  = &4.
  FCS-NO_OUT         = &5.

  CASE &6.
    WHEN 'C'.
      FCS-CFIELDNAME = &7.
    WHEN 'Q'.
      FCS-QFIELDNAME = &7.
  ENDCASE.
  APPEND FCS TO FC.

END-OF-DEFINITION.

************************************************************************
*                                                                      *
* INITIALIZATION Event                                                 *
*                                                                      *
************************************************************************
INITIALIZATION.
  PERFORM  SET_INITIAL_DATA.
  PERFORM  SET_ALV_INIT.             ">Initialize ALV variable

************************************************************************
*                                                                      *
* AT SELECTION-SCREEN Events                                           *
*                                                                      *
************************************************************************
*>The layout determines the list format
AT SELECTION-SCREEN ON VALUE-REQUEST FOR ALV_DEF.
  PERFORM EXEC_ALV_F4.

AT SELECTION-SCREEN.
  PERFORM INPUT_FIELD_CHECK.
  PERFORM ALV_VARIANT_CHECK.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM P1102_AUTHORIZATION_CHECK USING S_BUKRS-LOW.
** JS전선 회사코드 2007/04 KSH --------------------------------------

AT SELECTION-SCREEN OUTPUT.

************************************************************************
*                                                                      *
* START-OF-SELECTION Event                                             *
*                                                                      *
************************************************************************
START-OF-SELECTION.
  PERFORM CLEARING_WORK_AREA.      ">Initialize internal table
  PERFORM SET_FIELDCAT_BUILD.      ">Set ALV field category
  PERFORM CREATE_DYNAMIC_TABLE.    ">
  PERFORM GET_DATA_FOR_DISPLAY.    ">data select

************************************************************************
*                                                                      *
* END-OF-SELECTION Event                                               *
*                                                                      *
************************************************************************
END-OF-SELECTION.
  CHECK G_LINE NE 0.
*>--------------------------------------------------------
*> PROGRESS INDICATOR DISPLAY.
*>  4.  LIST DISPLAY
*>--------------------------------------------------------
  G_LINE1 = 100.
  G_OUT_TEXT = TEXT-905.
  REPLACE '%99999%' WITH G_LINE1 INTO G_OUT_TEXT.
  PERFORM SET_PROGRESS_BAR USING G_OUT_TEXT G_LINE1.
  PERFORM SET_COLORIZE_BUILD.       ">Set color
*  PERFORM set_event_form           ">Set ALV Use-event
*            USING : slis_ev_data_changed  slis_ev_data_changed.
  PERFORM SET_SORT_FIELD.           ">Set ALV sort fields
  PERFORM DISPLAY_ALV_LIST.         ">Call ALV Functions

************************************************************************
*                                                                      *
* TOP-OF-PAGE Event                                                    *
*                                                                      *
************************************************************************
TOP-OF-PAGE.

************************************************************************
*                                                                      *
* END-OF-PAGE Event                                                    *
*                                                                      *
************************************************************************
END-OF-PAGE.


************************************************************************
*                                                                      *
* TOP-OF-PAGE DURING LINE-SELECTION Event                              *
*                                                                      *
************************************************************************
TOP-OF-PAGE DURING LINE-SELECTION.


************************************************************************
*                                                                      *
* AT LINE-SELECTION Event                                              *
*                                                                      *
************************************************************************
AT LINE-SELECTION.


************************************************************************
*                                                                      *
* AT USER-COMMAND Event                                                *
*                                                                      *
************************************************************************
AT USER-COMMAND.


*eject
************************************************************************
*                                                                      *
* S U B R O U T I N E S                                                *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  SET_INITIAL_DATA
*&---------------------------------------------------------------------*
FORM SET_INITIAL_DATA.

  SET TITLEBAR 'T1000'.

*  FREE: s_bukrs.
*  CLEAR: s_bukrs, ztitig00.
*
*  s_bukrs-sign   = 'I'.
*  s_bukrs-option = 'EQ'.
*  GET PARAMETER ID 'BUK' FIELD s_bukrs-low.
**  s_bukrs-low    = c_bukrs.
*  IF NOT s_bukrs-low IS INITIAL.
*    APPEND s_bukrs.
*
*    SELECT SINGLE *
*      FROM ztitig00
*     WHERE bukrs EQ s_bukrs-low.
*  ENDIF.

  ALV_REPID = SY-REPID.
  CLEAR S_VARIANT.
  S_VARIANT-REPORT = SY-REPID.

* Get default variant
  S_VAR_USR = S_VARIANT.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      I_SAVE     = C_SAVE
    CHANGING
      CS_VARIANT = S_VAR_USR
    EXCEPTIONS
      NOT_FOUND  = 2.
  IF SY-SUBRC = 0.
    ALV_DEF =  S_VAR_USR-VARIANT.
  ENDIF.

ENDFORM.                    " SET_INITIAL_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_PROGRESS_BAR
*&---------------------------------------------------------------------*
FORM SET_PROGRESS_BAR USING   TEXT PERC.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      PERCENTAGE = PERC
      TEXT       = TEXT.

ENDFORM.                    " SET_PROGRESS_BAR
*&---------------------------------------------------------------------*
*&      Form  INPUT_FIELD_CHECK
*&---------------------------------------------------------------------*
FORM INPUT_FIELD_CHECK.

  DATA: L_BUKRS   LIKE T001-BUKRS,
        L_WERKS   LIKE T001W-WERKS,
        L_MATNR   LIKE MARA-MATNR,
        L_MTART   LIKE T134-MTART,
        L_EBELN   LIKE EKKO-EBELN,
        L_LIFNR   LIKE LFA1-LIFNR,
        L_EKORG   LIKE T024E-EKORG,
        L_EKGRP   LIKE T024-EKGRP.

* Company code
  SELECT *
    FROM T001 UP TO 1 ROWS
   WHERE BUKRS IN S_BUKRS.
  ENDSELECT.
  IF SY-SUBRC <> 0.
    PERFORM GET_FTEXT(RDDFIE00) USING 'T001' 'BUKRS' SY-LANGU
                                CHANGING DFIES G_SUBRC.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE E348(M7) WITH  DFIES-SCRTEXT_M.
  ELSE.

    SELECT SINGLE *
      FROM ZTITIG00
     WHERE BUKRS EQ T001-BUKRS.
    IF SY-SUBRC NE 0.
      MESSAGE E035 WITH T001-BUKRS.
    ENDIF.

    IF ZTITIG00-RQRLS NE 'X'.
      MESSAGE E166 WITH T001-BUTXT.
    ENDIF.

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

ENDFORM.                    " INPUT_FIELD_CHECK
*&---------------------------------------------------------------------*
*&      Form  CLEARING_WORK_AREA
*&---------------------------------------------------------------------*
FORM CLEARING_WORK_AREA.

  FREE:  XLFA1.
  CLEAR: XLFA1.

  IF P_FULL EQ 'X'.
    ALV_DETAIL_FUNC = 'REUSE_ALV_GRID_DISPLAY'.
  ELSE.
    ALV_DETAIL_FUNC = 'REUSE_ALV_LIST_DISPLAY'.
  ENDIF.

ENDFORM.                    " CLEARING_WORK_AREA
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_FOR_DISPLAY
*&---------------------------------------------------------------------*
FORM GET_DATA_FOR_DISPLAY.

  RANGES: LR_DOCST   FOR   ZTITRQS-DOCST OCCURS 1,
          LR_RQRLS   FOR   ZTITRQS-RQRLS OCCURS 1,
          LR_RETNS   FOR   ZTITRQS-RETNS OCCURS 1.

*  DATA : l_rqrls type c.

  FIELD-SYMBOLS: <LS_TABLE>.
  FIELD-SYMBOLS: <L_FIELD1>.
  FIELD-SYMBOLS: <L_FIELD2>.
  FIELD-SYMBOLS: <L_EBELN>.
  FIELD-SYMBOLS: <L_DDTEXT>.
  FIELD-SYMBOLS: <L_ILCTY>.
  FIELD-SYMBOLS: <L_TEXT2>.
  FIELD-SYMBOLS: <L_PAGRT>.
  FIELD-SYMBOLS: <L_REQTY>.


  REFRESH : <GT_TABLE>.
*> PROGRESS Display.
  G_LINE1    = 30.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
  REPLACE '%99999%' WITH G_LINE1 INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINE1.

  CASE 'X'.
    WHEN P_STEP1.   ">의뢰대상
      CLEAR LR_RQRLS .
      MOVE: 'I'     TO    LR_RQRLS-SIGN,
            'NE'    TO    LR_RQRLS-OPTION.
      MOVE: 'X'     TO    LR_RQRLS-LOW.    APPEND LR_RQRLS .
      CLEAR: LR_RETNS.
      MOVE: 'I'     TO    LR_RETNS-SIGN,
            'EQ'    TO    LR_RETNS-OPTION.
      MOVE: SPACE   TO    LR_RETNS-LOW.    APPEND LR_RETNS .
    WHEN P_STEP2.   ">접수대상
      CLEAR LR_RQRLS .
      MOVE: 'I'     TO    LR_RQRLS-SIGN,
            'EQ'    TO    LR_RQRLS-OPTION.
      MOVE: 'X'     TO    LR_RQRLS-LOW.    APPEND LR_RQRLS .
    WHEN P_STEP3.
      CLEAR: LR_RETNS.
      MOVE: 'I'     TO    LR_RETNS-SIGN,
            'EQ'    TO    LR_RETNS-OPTION.
      MOVE: 'X'     TO    LR_RETNS-LOW.    APPEND LR_RETNS .
  ENDCASE.

*> 수입의뢰 데이타 select.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE <GT_TABLE>
    FROM ZTIVRQ04
   WHERE BUKRS  IN  S_BUKRS        "회사코드.
     AND EKORG  IN  S_EKORG        "구매조직.
     AND EKGRP  IN  S_EKGRP        "구매그룹.
     AND REQNO  IN  S_REQNO        "수입의뢰 관리번호.
     AND AMDSQ  IN  S_AMDSQ        "Amend 차수.
     AND REQTY  IN  S_REQTY        "수입의뢰 종류.
     AND ILCTY  IN  S_ILCTY        "신용장 종류.
     AND LIFNR  IN  S_LIFNR        "공급업체 계정번호.
     AND LIFRE  IN  S_LIFRE        "다른 송장발행처.
     AND OFFER  IN  S_OFFER        "오퍼상(Offer).
     AND OPNBK  IN  S_OPNBK        "개설은행.
     AND ZTERM  IN  S_ZTERM        "지급조건키.
     AND WAERS  IN  S_WAERS        "개설통화.
     AND INCO1  IN  S_INCO1        "인도조건 (파트 1).
     AND EXDAT  IN  S_EXDAT        "유효기일.
     AND LSDAT  IN  S_LSDAT        "최종선적일자.
     AND FLAND  IN  S_FLAND        "선적국가.
     AND FPORT  IN  S_FPORT        "선적항.
     AND REQDT  IN  S_REQDT        "개설희망일자.
     AND APPUN  IN  S_APPUN        "개설의뢰 요청자.
     AND APPDT  IN  S_APPDT        "개설의뢰 요청일.
     AND ACCUN  IN  S_ACCUN        "요청접수 담당자.
     AND ACCDT  IN  S_ACCDT        "요청접수일자.
     AND SNDUN  IN  S_SNDUN        "개설신청자.
     AND SNDDT  IN  S_SNDDT        "개설신청일.
     AND RCVUN  IN  S_RCVUN        "개설등록자.
     AND RCVDT  IN  S_RCVDT        "개설등록일자.
     AND OPNNO  IN  S_OPNNO        "수입개설번호
     AND OPNDT  IN  S_OPNDT        "개설일자.
     AND CNAM   IN  S_CNAM         "작성인.
     AND CDAT   IN  S_CDAT         "생성일.
     AND UNAM   IN  S_UNAM         "최종변경인.
     AND UDAT   IN  S_UDAT         "변경일
     AND DOCST  EQ  'C'
     AND RETNS  IN  LR_RETNS
     AND RQRLS  IN  LR_RQRLS.

  IF SY-SUBRC NE 0.
    MESSAGE S902.
  ENDIF.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <GT_TABLE> TO <LS_TABLE>.

  LOOP AT <GT_TABLE> INTO <LS_TABLE>.
    ASSIGN COMPONENT 'LIFNR' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD2>.
    ASSIGN COMPONENT 'NAME1' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD1>.
    IF SY-SUBRC EQ 0.
      SELECT SINGLE NAME1
        INTO <L_FIELD1>
        FROM LFA1
       WHERE LIFNR  EQ  <L_FIELD2>.
    ENDIF.

    ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD1>.
    ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD2>.
    ASSIGN COMPONENT 'EBELN' OF STRUCTURE
                        <LS_TABLE> TO <L_EBELN>.
    ASSIGN COMPONENT 'ILCTY' OF STRUCTURE
                        <LS_TABLE> TO <L_ILCTY>.
    ASSIGN COMPONENT 'DDTEXT' OF STRUCTURE
                        <LS_TABLE> TO <L_DDTEXT>.
    ASSIGN COMPONENT 'PAGRT' OF STRUCTURE
                        <LS_TABLE> TO <L_PAGRT>.
    ASSIGN COMPONENT 'TEXT2' OF STRUCTURE
                        <LS_TABLE> TO <L_TEXT2>.
    ASSIGN COMPONENT 'REQTY' OF STRUCTURE
                        <LS_TABLE> TO <L_REQTY>.

    IF SY-SUBRC EQ 0.
      SELECT EBELN
        INTO <L_EBELN>
        FROM ZTITRQP UP TO 1 ROWS
       WHERE REQNO EQ <L_FIELD1>
         AND AMDSQ EQ <L_FIELD2>.
      ENDSELECT.
    ENDIF.

    IF <L_REQTY> NE 'LC'.


*>지불조건
      PERFORM  GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING 'ZTIREQTY'
                                                     <L_REQTY>
                                                     <L_DDTEXT>.
    ELSE.

*>지불조건
      PERFORM  GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING 'ZTIILCTY'
                                                     <L_ILCTY>
                                                     <L_DDTEXT>.

    ENDIF.

*>신용공여주체
    PERFORM  GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING 'ZTIPAGRT'
                                                   <L_PAGRT>
                                                   <L_TEXT2>.



    MODIFY <GT_TABLE> FROM <LS_TABLE>.

  ENDLOOP.

  DESCRIBE TABLE <GT_TABLE> LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE S902.
  ENDIF.

ENDFORM.                    " GET_DATA_FOR_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  EXEC_ALV_F4
*&---------------------------------------------------------------------*
FORM EXEC_ALV_F4.

  ALV_REPID = SY-REPID.
  CLEAR: ALV_VARIANT.
  ALV_VARIANT-REPORT = ALV_REPID.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      IS_VARIANT = ALV_VARIANT
      I_SAVE     = 'A'
    IMPORTING
      ES_VARIANT = ALV_VARIANT
    EXCEPTIONS
      NOT_FOUND  = 2.
  IF SY-SUBRC = 2.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    ALV_DEF = ALV_VARIANT-VARIANT.
  ENDIF.

ENDFORM.                    " EXEC_ALV_F4
*&---------------------------------------------------------------------*
*&      Form  SET_ALV_INIT
*&---------------------------------------------------------------------*
FORM SET_ALV_INIT.

  FREE:  IT_SORT, FC.
  CLEAR: ALV_KEYINFO, GS_LAYOUT, ALV_PRINT, FC.

* PRINTING SETTINGS
  GS_LAYOUT-GET_SELINFOS = 'X'.
  GS_LAYOUT-GROUP_CHANGE_EDIT = 'X'.

  ALV_PRINT-NO_PRINT_SELINFOS = 'X'.
  ALV_PRINT-NO_COVERPAGE = 'X'.
  ALV_PRINT-NO_PRINT_LISTINFOS = 'X'.

ENDFORM.                    " SET_ALV_INIT
*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT_BUILD
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_BUILD.

  DATA: COLOR TYPE SLIS_T_SPECIALCOL_ALV WITH HEADER LINE.

  FREE : FC.  CLEAR: FC.

  AC 'ITAB   BOX   ZTISRQIT                     FLAG  X'.
  AC 'ITAB   REQNO ZTITRQS                      REQNO '.
  AC 'ITAB   AMDSQ ZTITRQS                      AMDSQ '.
  AC 'ITAB   REQTY ZTITRQK                      REQTY '.
  AC 'ITAB   ILCTY ZTITRQK                      ILCTY '.
  AC 'ITAB   DDTEXTDD07D                        DDTEXT'.
  AC 'ITAB   RETXT ZTITRQS                      RETXT '.
  AC 'ITAB   PAGRT ZTITRQS                      PAGRT X'.
  AC 'ITAB   TEXT2 DD07D                        DDTEXT'.
  AC 'ITAB   USCDY ZTITRQK                      USCDY '.
  AC 'ITAB   EBELN ZTITIP1                      EBELN '.
  AC 'ITAB   PSPNR ZTITRQK                      PSPNR X'.

  AC 'ITAB   LIFNR ZTITRQK                      LIFNR '.
  AC 'ITAB   NAME1 LFA1                         NAME1 '.
  AC 'ITAB   OPAMT ZTITRQS                      OPAMT  CWAERS '.
  AC 'ITAB   WAERS ZTITRQS                      WAERS '.
  AC 'ITAB   USAMT ZTITRQS                      USAMT  CUCURR '.
  AC 'ITAB   UCURR ZTITRQS                      UCURR '.
  AC 'ITAB   ZTERM ZTITRQS                      ZTERM '.
  AC 'ITAB   REQDT ZTITRQS                      REQDT '.
  AC 'ITAB   INCO1 ZTITRQS                      INCO1 '.
  AC 'ITAB   CTONM ZTITRQS                      CTONM '.

*> Create field catagory table
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = 'ZTIVRQ02'
      I_CLIENT_NEVER_DISPLAY = 'X'
    CHANGING
      CT_FIELDCAT            = IT_FIELDCAT_G[].

*>Adjust ALV field category
  PERFORM ADJUST_FIELDCAT.         ">Adjust ALV field category

  FC1[] = FC[].

  AC 'ITAB   COLOR SLIS_T_SPECIALCOL_ALV              X'.

  LOOP AT FC1 INTO FCS.
    CLEAR: FCS-KEY .
    CASE FCS-FIELDNAME.
      WHEN 'REQNO' OR 'AMDSQ'.
        FCS-HOTSPOT = 'X'.
        FCS-KEY     = 'X'.
      WHEN 'EBELN'.
        FCS-HOTSPOT = 'X'.
      WHEN 'DDTEXT'.
        FCS-OUTPUTLEN = 30.
      WHEN 'TEXT2'.
        FCS-SELTEXT_L = '신용'.
        FCS-SELTEXT_S = '신용공여'.
        FCS-SELTEXT_M = '신용공여주체'.
        FCS-OUTPUTLEN = 12.
      WHEN 'OPAMT' OR 'USAMT'.
        FCS-DO_SUM = 'X'.
      WHEN 'RETXT'.
        IF P_STEP1 EQ 'X' OR P_STEP2 EQ 'X'.
          FCS-EDIT   = 'X'.
        ENDIF.
        FCS-OUTPUTLEN = 120.
    ENDCASE.
    MODIFY FC1 FROM FCS.
  ENDLOOP.

ENDFORM.                    " SET_FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_LIST
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_LIST.

  DATA: FC_DETAIL TYPE SLIS_FIELDCAT_ALV OCCURS 0 WITH HEADER LINE.
  DATA: VARIANT_DETAIL      LIKE DISVARIANT.
  DATA: EXIT     TYPE SLIS_EVENT_EXIT   OCCURS 0 WITH HEADER LINE.
  DATA: EVENTS   TYPE SLIS_ALV_EVENT    OCCURS 0 WITH HEADER LINE.
  DATA: GROUPS   TYPE SLIS_SP_GROUP_ALV OCCURS 0 WITH HEADER LINE.


*----------------------------------------------------------------------
*  : 의뢰대상
*C : 수입의뢰
*A : 접수완료
*W : 신청서작성
*Y : 개설신청
*N : 개설취소
*O : 개설완료
*R : 접수반려
*----------------------------------------------------------------------
  CASE 'X'.
    WHEN P_STEP1.   ">의뢰대상
      SET TITLEBAR 'T1000'.
    WHEN P_STEP2. ">접수대상
      SET TITLEBAR 'T1000'.
  ENDCASE.

* The detail ALV may modify the list (sorting). If returned to the
* base list, the original list needs to be restored.
  REFRESH FC_DETAIL.
  LOOP AT FC1 INTO FCS.
    MOVE-CORRESPONDING FCS TO FC_DETAIL.
    CLEAR FC_DETAIL-TABNAME.
    APPEND FC_DETAIL.
  ENDLOOP.

  CLEAR VARIANT_DETAIL.
  VARIANT_DETAIL-REPORT = ALV_REPID.
  VARIANT_DETAIL-HANDLE = ' '.

  GS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  GS_LAYOUT-ZEBRA             = 'X'.
  GS_LAYOUT-BOX_FIELDNAME     = 'BOX'.
*>color field define.
  GS_LAYOUT-COLTAB_FIELDNAME  = 'COLOR'.
  GS_LAYOUT-GROUP_CHANGE_EDIT = 'X'.
  GS_LAYOUT-F2CODE            = 'DISPLAY'.

  REFRESH EXIT.
  EXIT-UCOMM = '&OL0'. EXIT-AFTER = 'X'. APPEND EXIT.
  EXIT-UCOMM = '&OLX'. APPEND EXIT.
  EXIT-UCOMM = '&OAD'. APPEND EXIT.

*> event define.
  REFRESH EVENTS.
  EVENTS-NAME = SLIS_EV_TOP_OF_PAGE.
  EVENTS-FORM = 'TOP_OF_PAGE'.
  APPEND EVENTS.

  EVENTS-NAME = SLIS_EV_DATA_CHANGED.
  EVENTS-FORM = SLIS_EV_DATA_CHANGED.
  APPEND EVENTS.
*
  GS_GRIDSET-EDT_CLL_CB = 'X'.

*> ALV reuse function call..
  CALL FUNCTION ALV_DETAIL_FUNC
      EXPORTING
        I_CALLBACK_PROGRAM       = ALV_REPID
        I_CALLBACK_PF_STATUS_SET = 'SET_ALV_STATUS'
        I_CALLBACK_USER_COMMAND  = 'USER_ALV_COMMAND'
        I_GRID_SETTINGS          = GS_GRIDSET
*     I_STRUCTURE_NAME               =
*     IT_EXCLUDING                   =
*     IT_SPECIAL_GROUPS              =
*     IT_FILTER                      =
*     IS_SEL_HIDE                    =
*     I_DEFAULT                      = 'X'
*     I_SAVE                         = ' '
*     IS_VARIANT                     =
*      it_events                      = gt_events[]
      IT_EVENTS                      = EVENTS[]
      IT_EVENT_EXIT                  = EXIT[]
*     IS_PRINT                       =
*     IS_REPREP_ID                   =
*     I_SCREEN_START_COLUMN          = 0
*     I_SCREEN_START_LINE            = 0
*     I_SCREEN_END_COLUMN            = 0
*     I_SCREEN_END_LINE              = 0
        IT_FIELDCAT              = FC_DETAIL[]
        IT_SORT                  = IT_SORT
*        I_DEFAULT                = 'X'
*        IS_VARIANT               = VARIANT_DETAIL
        IS_VARIANT               = ALV_VARIANT
        I_SAVE                   = C_SAVE
        IS_LAYOUT                = GS_LAYOUT
        IS_PRINT                 = ALV_PRINT
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER        =
*     ES_EXIT_CAUSED_BY_USER         =
      TABLES
        T_OUTTAB                 = <GT_TABLE>.

ENDFORM.                    " DISPLAY_ALV_LIST

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_STATUS
*&---------------------------------------------------------------------*
FORM SET_ALV_STATUS USING  EXTAB TYPE SLIS_T_EXTAB.


  APPEND 'ARCHIVE'   TO EXTAB.
*  APPEND '&VEXCEL'   TO extab.
  APPEND '&AQW'      TO EXTAB.
  APPEND '&VCRYSTAL' TO EXTAB.
  APPEND '&VGRID'    TO EXTAB.
  APPEND '&EB9'      TO EXTAB.
  APPEND '&CRDESIG'  TO EXTAB.
*----------------------------------------------------------------------
*  : 의뢰대상
*C : 수입의뢰
*A : 접수완료
*W : 신청서작성
*Y : 개설신청
*N : 개설취소
*O : 개설완료
*R : 접수반려
*----------------------------------------------------------------------
  CASE 'X'.
    WHEN P_STEP1.	">의뢰대상
      APPEND 'ZTICANCEL'  TO EXTAB.
    WHEN P_STEP2. ">접수대상
      APPEND 'ZTIRELEASE'  TO EXTAB.
      APPEND 'ZTIRETURN'  TO EXTAB.
    WHEN OTHERS.
      APPEND 'ZTICANCEL'  TO EXTAB.
      APPEND 'ZTIRELEASE'  TO EXTAB.
      APPEND 'ZTIRETURN'  TO EXTAB.
  ENDCASE.

  SET PF-STATUS 'STANDARD' EXCLUDING EXTAB.

ENDFORM.                    " SET_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  USER_ALV_COMMAND
*&---------------------------------------------------------------------*
FORM USER_ALV_COMMAND USING   R_UCOMM      LIKE SY-UCOMM
                              RS_SELFIELD  TYPE SLIS_SELFIELD.
*
  DATA: L_COUNT    TYPE I.
  DATA: L_SUBRC    LIKE SY-SUBRC.
  DATA: L_TCODE    LIKE SY-TCODE.

  DATA: L_REQNO    TYPE ZTIREQNO,
        L_AMDSQ    TYPE ZTIAMDSQ,
        L_ANSWER   TYPE C,
        L_DATE(10) TYPE C.

  FIELD-SYMBOLS: <LS_TABLE>.
  FIELD-SYMBOLS: <L_BOX>.
  FIELD-SYMBOLS: <L_FIELD>.
  FIELD-SYMBOLS: <L_FIELD1>.
  FIELD-SYMBOLS: <L_FIELD2>.
  FIELD-SYMBOLS: <L_RETXT>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <GT_TABLE> TO <LS_TABLE>.
  ASSIGN COMPONENT 'BOX' OF STRUCTURE  <LS_TABLE> TO <L_BOX>.

  CLEAR: IT_REQNO, IT_REQNO[].
  CLEAR: L_COUNT.

  CASE R_UCOMM.
    WHEN 'ZTIRELEASE' OR  ">승인.
         'ZTIRETURN' OR   ">반려.
         'ZTICANCEL'.   ">취소.

      LOOP AT <GT_TABLE> INTO <LS_TABLE>.
        IF <L_BOX> EQ 'X'.
          ADD 1 TO L_COUNT.
          ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                                  <LS_TABLE> TO <L_FIELD1>.
          ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD2>.
          ASSIGN COMPONENT 'RETXT' OF STRUCTURE
                        <LS_TABLE> TO <L_RETXT>.

          L_REQNO = <L_FIELD1>.
          L_AMDSQ = <L_FIELD2>.
          IT_REQNO-REQNO = L_REQNO.
          IT_REQNO-AMDSQ = L_AMDSQ.
          IT_REQNO-RETXT = <L_RETXT>.
          APPEND IT_REQNO.
        ENDIF.
      ENDLOOP.
      IF L_COUNT EQ 0.
        MESSAGE E909.
      ENDIF.

  ENDCASE.

  CASE R_UCOMM.
    WHEN 'ZTIRELEASE'.  ">승인.
      PERFORM CONFIRM_MESSAGE   USING R_UCOMM  L_ANSWER.
      IF L_ANSWER EQ 'Y'.
        PERFORM UPDATE_DATABASE USING R_UCOMM  L_COUNT.
        IF L_COUNT GT 0.
          PERFORM GET_DATA_FOR_DISPLAY.    ">data select
          RS_SELFIELD-REFRESH = 'X'.
        ENDIF.
      ENDIF.
    WHEN 'ZTIRETURN'.   ">반려.
      PERFORM CONFIRM_MESSAGE   USING R_UCOMM  L_ANSWER.
      IF L_ANSWER EQ 'Y'.
        PERFORM UPDATE_DATABASE USING R_UCOMM  L_COUNT.
        IF L_COUNT GT 0.
          PERFORM GET_DATA_FOR_DISPLAY.    ">data select
          RS_SELFIELD-REFRESH = 'X'.
        ENDIF.
      ENDIF.
    WHEN 'ZTICANCEL'.   ">취소.
      PERFORM CONFIRM_MESSAGE   USING R_UCOMM  L_ANSWER.
      IF L_ANSWER EQ 'Y'.
        PERFORM UPDATE_DATABASE USING R_UCOMM  L_COUNT.
        IF L_COUNT GT 0.
          PERFORM GET_DATA_FOR_DISPLAY.    ">data select
          RS_SELFIELD-REFRESH = 'X'.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
*> 초기화면.
      CHECK RS_SELFIELD-TABINDEX GT 0.

      READ TABLE <GT_TABLE> INTO <LS_TABLE> INDEX RS_SELFIELD-TABINDEX.
      IF SY-SUBRC NE 0.
        MESSAGE S906.            EXIT.
      ENDIF.
      IF RS_SELFIELD-FIELDNAME EQ 'EBELN'.
        ASSIGN COMPONENT 'EBELN' OF STRUCTURE
                              <LS_TABLE> TO <L_FIELD1>.
        PERFORM DISPLAY_PURCHASE_ORDER(ZTIR0000)
                             USING <L_FIELD1> '00' .
      ELSE.
        ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                              <LS_TABLE> TO <L_FIELD1>.
        ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                              <LS_TABLE> TO <L_FIELD2>.
        PERFORM EXCUTE_IMPORT_DOCUMENT(ZTIR0000)
                             USING <L_FIELD1> <L_FIELD2> 'ZTIT003'.
      ENDIF.
  ENDCASE.

  CLEAR: R_UCOMM.

ENDFORM.                    " USER_ALV_COMMAND
*&---------------------------------------------------------------------*
*&      Form  ALV_VARIANT_CHECK
*&---------------------------------------------------------------------*
FORM ALV_VARIANT_CHECK.

  ALV_VARIANT-REPORT = ALV_REPID.
  ALV_VARIANT-VARIANT = ALV_DEF.
  IF NOT ALV_DEF IS INITIAL.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        I_SAVE     = 'A'
      CHANGING
        CS_VARIANT = ALV_VARIANT
      EXCEPTIONS
        OTHERS     = 1.
    IF SY-SUBRC <> 0.
      MESSAGE E321(M7) WITH ALV_DEF ALV_REPID.
    ENDIF.
  ENDIF.

ENDFORM.                    " ALV_VARIANT_CHECK
*&---------------------------------------------------------------------*
*&      Form  SET_SORT_FIELD
*&---------------------------------------------------------------------*
FORM SET_SORT_FIELD.

  REFRESH: IT_SORT.

*  CLEAR  st_sort.
*  st_sort-spos = '01'.
*  st_sort-fieldname = 'REQNO'.
*  st_sort-tabname   = '<GT_TABLE>'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
*  st_sort-subtot    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.
*
*  CLEAR  st_sort.
*  st_sort-spos = '02'.
*  st_sort-fieldname = 'MTBEZ'.
*  st_sort-tabname   = 'ITAB'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
**  ST_SORT-SUBTOT    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.
*
*  CLEAR  st_sort.
*  st_sort-spos = '03'.
*  st_sort-fieldname = 'EBELN'.
*  st_sort-tabname   = 'ITAB'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
**  ST_SORT-SUBTOT    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.

ENDFORM.                    " SET_SORT_FIELD

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM TOP_OF_PAGE.

  DATA: L_MODE TYPE I.
  DATA: HEADER TYPE SLIS_LISTHEADER OCCURS 0 WITH HEADER LINE.

  REFRESH HEADER.

  HEADER-TYP = 'H'.
*----------------------------------------------------------------------
*  : 의뢰대상
*C : 수입의뢰
*A : 접수완료
*W : 신청서작성
*Y : 개설신청
*N : 개설취소
*O : 개설완료
*R : 접수반려
*----------------------------------------------------------------------
  CASE 'X'.
    WHEN P_STEP1. ">승인대상
      HEADER-INFO = '수입요청 승인대상 현황'.
    WHEN P_STEP2. ">취소대상
      HEADER-INFO = '수입요청 취소대상 현황'.
    WHEN OTHERS.  ">개설완료
      HEADER-INFO = '수입요청 전체 현황'.
  ENDCASE.

  CLEAR: HEADER-KEY.
  APPEND HEADER.

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: L_BUTXT LIKE T001-BUTXT.
  CLEAR: L_BUTXT.
  SELECT SINGLE BUTXT FROM T001
                      INTO L_BUTXT
                     WHERE BUKRS EQ S_BUKRS-LOW.

  HEADER-TYP = 'S'.
  HEADER-KEY = '회사코드 '.
  CONCATENATE S_BUKRS-LOW L_BUTXT INTO HEADER-INFO SEPARATED BY SPACE.
  APPEND HEADER.
  CLEAR: HEADER.
** JS전선 회사코드 2007/04 KSH --------------------------------------


  HEADER-TYP = 'S'.
  HEADER-KEY = '출력일자'(106).
  WRITE: SY-DATLO TO HEADER-INFO.
  APPEND HEADER.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = HEADER[].

ENDFORM.    ">TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  MATERIAL_MASTER_DISPLAY
*&---------------------------------------------------------------------*
FORM MATERIAL_MASTER_DISPLAY USING RS_SELFIELD  TYPE SLIS_SELFIELD.

  FIELD-SYMBOLS: <LS_TABLE>.

  READ TABLE <GT_TABLE> INTO <LS_TABLE>
                        INDEX RS_SELFIELD-TABINDEX. "cursorposit.
  IF SY-SUBRC EQ 0.
*    MOVE-CORRESPONDING <ls_table> TO xitab.
*
*    READ TABLE organ WITH KEY werks = xitab-werks.
*
*    SET PARAMETER ID 'MAT' FIELD xitab-matnr.
*    SET PARAMETER ID 'BUK' FIELD organ-bukrs.
*    SET PARAMETER ID 'WRK' FIELD xitab-werks.
    SET PARAMETER ID 'LAG' FIELD ''.
*  SET PARAMETER ID 'MXX' FIELD 'KDEALBSZXVPCFQG'.
    SET PARAMETER ID 'MXX' FIELD 'KDE'.

    CALL TRANSACTION 'MM03' AND SKIP  FIRST SCREEN.
  ELSE.
    MESSAGE S903.
  ENDIF.

ENDFORM.                    " MATERIAL_MASTER_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  create_dynamic_table
*&---------------------------------------------------------------------*
FORM CREATE_DYNAMIC_TABLE .

  DATA: LP_TABLE        TYPE REF TO DATA.
  DATA: E_STYLE_FNAME   TYPE LVC_FNAME.
  DATA: I_STYLE_TABLE   TYPE C.
  DATA: LT_FIELDCAT     TYPE LVC_T_FCAT.

*create_dynamic_table
  CLEAR LP_TABLE.
  CALL METHOD Z_TI_CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE_GRID
    EXPORTING
      IT_FIELDCATALOG = FC
*      i_style_table   = i_style_table
    IMPORTING
      EP_TABLE        = LP_TABLE.

  ASSIGN LP_TABLE->* TO <GT_TABLE>.

ENDFORM.                    " create_dynamic_table
*&---------------------------------------------------------------------*
*&      Form  set_colorize_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_COLORIZE_BUILD .

  FIELD-SYMBOLS: <LT_TABLE> TYPE TABLE.
  FIELD-SYMBOLS: <LS_TABLE>.
  FIELD-SYMBOLS: <LT_COLOR>.
  FIELD-SYMBOLS: <LS_COLOR>.
  FIELD-SYMBOLS: <L_FIELD> TYPE TABLE.
  FIELD-SYMBOLS: <L_NAME>.
  FIELD-SYMBOLS: <L_COL>.
  FIELD-SYMBOLS: <L_INT>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <GT_TABLE> TO <LT_TABLE>.

  DATA: COLOR TYPE SLIS_T_SPECIALCOL_ALV WITH HEADER LINE.

*> colorize
  LOOP AT <GT_TABLE> INTO <LT_TABLE>.

    ASSIGN COMPONENT 'COLOR' OF STRUCTURE
                             <LT_TABLE> TO <L_FIELD>.

    ASSIGN LOCAL COPY OF INITIAL LINE OF <L_FIELD> TO <LS_COLOR>.

    ASSIGN COMPONENT 'COLOR-COL' OF STRUCTURE
                             <LS_COLOR> TO <L_COL>.
    ASSIGN COMPONENT 'COLOR-INT' OF STRUCTURE
                             <LS_COLOR> TO <L_INT>.
    ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE
                             <LS_COLOR> TO <L_NAME>.
    <L_COL> = 4.
    <L_INT> = 0.
    <L_NAME> = 'REQTY'.
    APPEND <LS_COLOR> TO <L_FIELD>.

    MODIFY <GT_TABLE> FROM <LT_TABLE>.
  ENDLOOP.

ENDFORM.                    " set_colorize_build
*&---------------------------------------------------------------------*
*&      Form  ADJUST_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ADJUST_FIELDCAT .

  FIELD-SYMBOLS: <LS_TABLE>,
                 <L_FIELD>.

  DATA: LT_FIELDCAT_G TYPE LVC_T_FCAT.

*>Internal table에 존재하지 않는 필드.
  LOOP AT IT_FIELDCAT_G INTO GS_FIELDCAT_G.
    READ TABLE FC INTO FCS WITH KEY FIELDNAME = GS_FIELDCAT_G-FIELDNAME.
    IF SY-SUBRC NE 0.
      IF NOT GS_FIELDCAT_G-FIELDNAME IS INITIAL AND
         GS_FIELDCAT_G-FIELDNAME     NE 'MANDT'.
        MOVE-CORRESPONDING  GS_FIELDCAT_G TO FCS.
        MOVE: GS_FIELDCAT_G-FIELDNAME     TO FCS-REF_FIELDNAME,
              'ZTIVRQ02'                  TO FCS-REF_TABNAME.
        CLEAR: FCS-KEY.
        FCS-NO_OUT = 'X'.
        APPEND FCS TO FC.
      ENDIF.
    ENDIF.
    DESCRIBE TABLE FC LINES G_LINE.
    IF G_LINE GT 50.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " ADJUST_fieldcat
*&---------------------------------------------------------------------*
*&      Form  confirm_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CONFIRM_MESSAGE  USING    P_UCOMM  P_ANSWER.

  DATA: CANCEL_DISPLAY.
*>------------------------------------------------------
*> MESSAGE POPUP용.
*>------------------------------------------------------
  DATA: BEGIN OF POP,
        TITEL      LIKE SPOP-TITEL,
        DIAGNOSE1  LIKE SPOP-DIAGNOSE1,
        DIAGNOSE2  LIKE SPOP-DIAGNOSE2,
        DIAGNOSE3  LIKE SPOP-DIAGNOSE3,
        TEXTLINE1  LIKE SPOP-TEXTLINE1,
        TEXTLINE2  LIKE SPOP-TEXTLINE2,
        TEXTLINE3  LIKE SPOP-TEXTLINE3,
        OPTION1    LIKE SPOP-VAROPTION1,
        OPTION2    LIKE SPOP-VAROPTION2,
        DEFAULT,             "defaultoption fuer Confirm_step
        ANSWER,
  END OF POP.

  CLEAR CANCEL_DISPLAY.

  CASE P_UCOMM.
    WHEN 'ZTIRELEASE'. ">승인.
      MOVE: '선택한 수입요청을 승인처리합니다.'  TO POP-DIAGNOSE1,
            '승인 하시겠습니까?'                 TO POP-TEXTLINE1,
            '승인 확인'                          TO POP-TITEL.

    WHEN 'ZTIRETURN'.   ">반려.
      MOVE: '선택한 수입요청을 반려처리합니다.'  TO POP-DIAGNOSE1,
            '반려처리 하시겠습니까?'             TO POP-TEXTLINE1,
            '반려 확인'                          TO POP-TITEL.

    WHEN 'ZTICANCEL'.   ">취소.
      MOVE: '선택한 수입요청을 승인취소합니다.'  TO POP-DIAGNOSE1,
            '승인취소 하시겠습니까?'             TO POP-TEXTLINE1,
            '승인취소 확인'                      TO POP-TITEL.
  ENDCASE.

  CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
         EXPORTING
*             DEFAULTOPTION = 'Y'
              DIAGNOSETEXT1 = POP-DIAGNOSE1
*             DIAGNOSETEXT2 = POP-DIAGNOSE2
*             DIAGNOSETEXT3 = ' '
              TEXTLINE1      = POP-TEXTLINE1
              TEXTLINE2      = POP-TEXTLINE2
              TITEL          = POP-TITEL
*             START_COLUMN   = 25
*             START_ROW      = 6
              CANCEL_DISPLAY = CANCEL_DISPLAY
         IMPORTING
              ANSWER        = POP-ANSWER
         EXCEPTIONS
              OTHERS        = 1.


  CASE POP-ANSWER.
    WHEN 'J'.
      P_ANSWER = 'Y'.
    WHEN 'N'.
      P_ANSWER = 'N'.
    WHEN 'A'.
      P_ANSWER = 'A'.
  ENDCASE.

ENDFORM.                    " confirm_message
*&---------------------------------------------------------------------*
*&      Form  update_database
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPDATE_DATABASE  USING    P_UCOMM    P_COUNT.

  DATA: LT_ZTITRQS_NEW LIKE ZTITRQS OCCURS 1 WITH HEADER LINE.
  DATA: LT_ZTITRQS_OLD LIKE ZTITRQS OCCURS 1 WITH HEADER LINE.

  DATA: L_COUNT    TYPE I,
        L_RQRLS    TYPE ZTIRQRLS,
        L_RETNS    TYPE ZTIRETNS,
        L_SUBRC    LIKE SY-SUBRC.

  CLEAR: P_COUNT.

  CALL FUNCTION 'MESSAGES_INITIALIZE'.

  LOOP AT IT_REQNO.
    G_TABIX = SY-TABIX.
    PERFORM  SET_LC_LOCK_OBJECT  USING IT_REQNO-REQNO
                                       IT_REQNO-AMDSQ
                                       'L'
                                       L_SUBRC.
    IF L_SUBRC NE 0.
      DELETE IT_REQNO INDEX G_TABIX.
      CONTINUE.
    ENDIF.
    IF P_UCOMM EQ 'ZTIRETURN'.
      IF IT_REQNO-RETXT IS INITIAL.
        CALL FUNCTION 'MESSAGE_STORE'
          EXPORTING
            ARBGB  = 'ZMTI00'
            MSGTY  = 'E'
            MSGV1  = IT_REQNO-REQNO
            MSGV2  = IT_REQNO-AMDSQ
            MSGV3  = SPACE
            MSGV4  = SPACE
            TXTNR  = '175'
*            zeile  = itab_mesg-zeile
          EXCEPTIONS
            OTHERS = 1.

        CHECK SY-SUBRC EQ 0.
        DELETE IT_REQNO INDEX G_TABIX.
      ENDIF.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE IT_REQNO LINES L_COUNT.
  IF L_COUNT EQ 0.
    CALL FUNCTION 'MESSAGES_SHOW'
      EXPORTING
        OBJECT             = '※ Error Message'
        I_USE_GRID         = 'X'
        I_AMODAL_WINDOW    = 'X'
      EXCEPTIONS
        INCONSISTENT_RANGE = 1
        NO_MESSAGES        = 2
        OTHERS             = 3.
    EXIT.
  ENDIF.

*> data select
  SELECT *
    INTO TABLE LT_ZTITRQS_OLD
    FROM ZTITRQS
     FOR ALL ENTRIES IN IT_REQNO
   WHERE REQNO EQ IT_REQNO-REQNO
     AND AMDSQ EQ IT_REQNO-AMDSQ.

  LT_ZTITRQS_NEW[] = LT_ZTITRQS_OLD[].

  CASE P_UCOMM.
    WHEN 'ZTIRELEASE'.  ">승인.
      L_RQRLS = 'X'.
      L_RETNS = ' '.
    WHEN 'ZTIRETURN'.  ">반려.
      L_RQRLS = ' '.
      L_RETNS = 'X'.
    WHEN 'ZTICANCEL'.   ">취소.
      L_RQRLS = ' '.
      L_RETNS = ' '.
  ENDCASE.

  LOOP AT LT_ZTITRQS_NEW.
    READ TABLE LT_ZTITRQS_OLD
               WITH KEY REQNO = LT_ZTITRQS_NEW-REQNO
                        AMDSQ = LT_ZTITRQS_NEW-AMDSQ.

    READ TABLE IT_REQNO WITH KEY REQNO = LT_ZTITRQS_NEW-REQNO
                                 AMDSQ = LT_ZTITRQS_NEW-AMDSQ.
    IF SY-SUBRC EQ 0.
      MOVE:IT_REQNO-RETXT  TO   LT_ZTITRQS_NEW-RETXT.
    ENDIF.

*****************************************************************
* 2009.01.12 simcho by 조정주S:  C20090114_85960
* 승인시 승인자,승인날짜,시간 table field 추가
*****************************************************************
    MOVE:L_RQRLS    TO   LT_ZTITRQS_NEW-RQRLS,
         L_RETNS    TO   LT_ZTITRQS_NEW-RETNS,
         SY-UNAME   TO   LT_ZTITRQS_NEW-UNAM,
         SY-DATLO   TO   LT_ZTITRQS_NEW-UDAT,
         SY-TIMLO   TO   LT_ZTITRQS_NEW-UTME,
*****************************************************************
         SY-UNAME   TO   LT_ZTITRQS_NEW-ANAM,
         SY-DATLO   TO   LT_ZTITRQS_NEW-ADAT,
         SY-TIMLO   TO   LT_ZTITRQS_NEW-ATME.
*****************************************************************
    MODIFY LT_ZTITRQS_NEW.

    CASE P_UCOMM.
      WHEN 'ZTIRELEASE'.  ">승인.
        MESSAGE S167 WITH LT_ZTITRQS_NEW-REQNO '승인'.
      WHEN 'ZTIRETURN'.  ">반려.
        MESSAGE S167 WITH LT_ZTITRQS_NEW-REQNO '반려'.
      WHEN 'ZTICANCEL'.   ">취소.
        MESSAGE S167 WITH LT_ZTITRQS_NEW-REQNO '취소'.
    ENDCASE.

    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        ARBGB  = SY-MSGID
        MSGTY  = SY-MSGTY
        MSGV1  = SY-MSGV1
        MSGV2  = SY-MSGV2
        MSGV3  = SY-MSGV3
        MSGV4  = SY-MSGV4
        TXTNR  = SY-MSGNO
*          zeile  = itab_mesg-zeile
      EXCEPTIONS
        OTHERS = 1.

*> Change Document
    PERFORM  SET_CHANGE_DOCUMENT USING LT_ZTITRQS_OLD
                                       LT_ZTITRQS_NEW.

    ADD 1 TO P_COUNT.
  ENDLOOP.

  MODIFY ZTITRQS FROM TABLE LT_ZTITRQS_NEW.

*  break-point.

*> Unlock
  LOOP AT LT_ZTITRQS_NEW.
    PERFORM  SET_LC_LOCK_OBJECT  USING LT_ZTITRQS_NEW-REQNO
                                       LT_ZTITRQS_NEW-AMDSQ
                                       'U'
                                       L_SUBRC.

*> CHM2202-00131 메일전송 기능 추가 요청 건 EVK 정재원
  IF LT_ZTITRQS_NEW-WERKS EQ '5201'.
    IF P_UCOMM EQ 'ZTIRELEASE'.
      IF LT_ZTITRQS_NEW-REQNO+0(1) EQ '7'.
        PERFORM SEND_MAIL USING LT_ZTITRQS_NEW-REQNO.
      ENDIF.
    ENDIF.
  ENDIF.
*> CHM2202-00131 메일전송 기능 추가 요청 건 EVK 정재원

  ENDLOOP.


  CALL FUNCTION 'MESSAGES_SHOW'
    EXPORTING
      OBJECT             = '※ Error Message'
      I_USE_GRID         = 'X'
      I_AMODAL_WINDOW    = 'X'
    EXCEPTIONS
      INCONSISTENT_RANGE = 1
      NO_MESSAGES        = 2
      OTHERS             = 3.

ENDFORM.                    " update_database
*&---------------------------------------------------------------------*
*&      Form  set_lc_lock_object
*&---------------------------------------------------------------------*
FORM SET_LC_LOCK_OBJECT  USING    P_REQNO
                                  P_AMDSQ
                                  P_MODE
                                  P_SUBRC.

  DATA: L_MESS(100).

*   CLEAR: p_check.
  CLEAR: P_SUBRC.

  IF P_MODE EQ 'L'.
    CALL FUNCTION 'ENQUEUE_EZ_TI_ZTITRQK'
      EXPORTING
        MANDT          = SY-MANDT
        REQNO          = P_REQNO
        AMDSQ          = P_AMDSQ
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.
    IF SY-SUBRC <> 0.
      P_SUBRC = 4.
*      CALL FUNCTION 'RKC_MSG_STRING'
*        EXPORTING
*          id      = sy-msgid
*          mtype   = sy-msgty
*          number  = sy-msgno
*          par1    = sy-msgv1
*          par2    = sy-msgv2
*          par3    = sy-msgv3
*          par4    = sy-msgv4
*        IMPORTING
*          msg_lin = l_mess.

      CALL FUNCTION 'MESSAGE_STORE'
        EXPORTING
          ARBGB  = SY-MSGID
          MSGTY  = SY-MSGTY
          MSGV1  = SY-MSGV1
          MSGV2  = SY-MSGV2
          MSGV3  = SY-MSGV3
          MSGV4  = SY-MSGV4
          TXTNR  = SY-MSGNO
*          zeile  = itab_mesg-zeile
        EXCEPTIONS
          OTHERS = 1.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZ_TI_ZTITRQK'
      EXPORTING
        MANDT = SY-MANDT
        REQNO = P_REQNO
        AMDSQ = P_AMDSQ.
  ENDIF.

ENDFORM.                    " set_LC_lock_object
*&---------------------------------------------------------------------*
*&      Form  set_change_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_CHANGE_DOCUMENT USING L_ZTITRQS_OLD STRUCTURE ZTITRQS
                               L_ZTITRQS_NEW STRUCTURE ZTITRQS.

  DATA: L_OBJECTID              TYPE CDHDR-OBJECTID,
        L_TCODE                 TYPE CDHDR-TCODE,
        L_UTIME                 TYPE CDHDR-UTIME,
        L_UDATE                 TYPE CDHDR-UDATE,
        L_USERNAME              TYPE CDHDR-USERNAME,
        L_CDOC_UPD_OBJECT       TYPE CDHDR-CHANGE_IND,
        L_UPD_ICDTXT            TYPE CHAR1,
        L_UPD                   TYPE CHAR1,
        LT_CDTXT                TYPE STANDARD TABLE OF CDTXT
                                     INITIAL SIZE 0.

*> CHANGE DOCUMENT용.
  DATA : BEGIN OF XZTITLC2 OCCURS 0.
          INCLUDE STRUCTURE VZTITLC2.
  DATA : END   OF XZTITLC2.

  DATA : BEGIN OF YZTITLC2 OCCURS 0.
          INCLUDE STRUCTURE VZTITLC2.
  DATA : END   OF YZTITLC2.

  DATA : BEGIN OF XZTITLC3 OCCURS 0.
          INCLUDE STRUCTURE VZTITLC3.
  DATA : END   OF XZTITLC3.

  DATA : BEGIN OF YZTITLC3 OCCURS 0.
          INCLUDE STRUCTURE VZTITLC3.
  DATA : END   OF YZTITLC3.

  DATA : BEGIN OF XZTITLC4 OCCURS 0.
          INCLUDE STRUCTURE VZTITLC4.
  DATA : END   OF XZTITLC4.

  DATA : BEGIN OF YZTITLC4 OCCURS 0.
          INCLUDE STRUCTURE VZTITLC4.
  DATA : END   OF YZTITLC4.

  DATA : BEGIN OF XZTITPC2 OCCURS 0.
          INCLUDE STRUCTURE VZTITPC2.
  DATA : END   OF XZTITPC2.

  DATA : BEGIN OF YZTITPC2 OCCURS 0.
          INCLUDE STRUCTURE VZTITPC2.
  DATA : END   OF YZTITPC2.

  DATA : BEGIN OF XZTITPC3 OCCURS 0.
          INCLUDE STRUCTURE VZTITPC3.
  DATA : END   OF XZTITPC3.

  DATA : BEGIN OF YZTITPC3 OCCURS 0.
          INCLUDE STRUCTURE VZTITPC3.
  DATA : END   OF YZTITPC3.

  DATA : BEGIN OF XZTITRQP OCCURS 0.
          INCLUDE STRUCTURE VZTITRQP.
  DATA : END   OF XZTITRQP.

  DATA : BEGIN OF YZTITRQP OCCURS 0.
          INCLUDE STRUCTURE VZTITRQP.
  DATA : END   OF YZTITRQP.

  DATA : BEGIN OF XZTITTT2 OCCURS 0.
          INCLUDE STRUCTURE VZTITTT2.
  DATA : END   OF XZTITTT2.

  DATA : BEGIN OF YZTITTT2 OCCURS 0.
          INCLUDE STRUCTURE VZTITTT2.
  DATA : END   OF YZTITTT2.

  DATA : BEGIN OF XZTITTT3 OCCURS 0.
          INCLUDE STRUCTURE VZTITTT3.
  DATA : END   OF XZTITTT3.

  DATA : BEGIN OF YZTITTT3 OCCURS 0.
          INCLUDE STRUCTURE VZTITTT3.
  DATA : END   OF YZTITTT3.

  DATA : BEGIN OF XZTITTT4 OCCURS 0.
          INCLUDE STRUCTURE VZTITTT4.
  DATA : END   OF XZTITTT4.

  DATA : BEGIN OF YZTITTT4 OCCURS 0.
          INCLUDE STRUCTURE VZTITTT4.
  DATA : END   OF YZTITTT4.

  TABLES:*ZTITRQK,    ">수입의뢰 Header
         *ZTITRQS,    ">수입의뢰 Status
          ZTITRQP,    ">수입의뢰 Items
          ZTITLO1,    ">LOCAL  L/C MAIN (LOCAPP/LOCAMR)
         *ZTITLO1,    ">LOCAL  L/C MAIN (LOCAPP/LOCAMR)
          ZTITPC1,    ">구매확인서 MAIN (APPPCR/PCRLIC)
         *ZTITPC1,    ">구매확인서 MAIN (APPPCR/PCRLIC)
          ZTITPC2,    ">구매확인서 ITEM (근거서류)
         *ZTITPC2,    ">구매확인서 ITEM (근거서류)
          ZTITPC3,    ">구매확인서 ITEM (물품내역)
         *ZTITPC3,    ">구매확인서 ITEM (물품내역)
          ZTITLC1,    ">MASTER L/C MAIN (APP700/APP707)
         *ZTITLC1,    ">MASTER L/C MAIN (APP700/APP707)
          ZTITLC2,    ">MASTER L/C ITEM (Long text)
         *ZTITLC2,    ">MASTER L/C ITEM (Long text)
          ZTITLC3,    ">MASTER L/C (수입승인)
         *ZTITLC3,    ">MASTER L/C (수입승인)
          ZTITLC5,    ">[Import] MASTER L/C MAIN (EDI 수신 데이타)
          ZTITTT1,    ">지급지시서 T/T MAIN (PAYORD)
         *ZTITTT1,    ">지급지시서 T/T MAIN (PAYORD)
          ZTITTT2,    ">지급지시서 T/T ITEM (입금관련서류)
         *ZTITTT2,    ">지급지시서 T/T ITEM (입금관련서류)
          ZTITTT3,    ">지급지시서 T/T ITEM (부가수수료)
         *ZTITTT3.    ">지급지시서 T/T ITEM (부가수수료)


  L_CDOC_UPD_OBJECT = 'U'.
  L_UPD_ICDTXT      = 'U'.
  L_UPD             = 'U'.

  L_OBJECTID(12) = L_ZTITRQS_OLD+3(12).

  L_TCODE        = SY-TCODE.
  L_UTIME        = SY-TIMLO.
  L_UDATE        = SY-DATLO.
  L_USERNAME     = SY-UNAME.

  CALL FUNCTION 'ZTILCCHDOC_WRITE_DOCUMENT'
    EXPORTING
      OBJECTID                      = L_OBJECTID
      TCODE                         = L_TCODE
      UTIME                         = L_UTIME
      UDATE                         = L_UDATE
      USERNAME                      = L_USERNAME
*   PLANNED_CHANGE_NUMBER         = ' '
      OBJECT_CHANGE_INDICATOR       = L_CDOC_UPD_OBJECT
*   PLANNED_OR_REAL_CHANGES       = ' '
*   NO_CHANGE_POINTERS            = ' '
*   UPD_ICDTXT_ZTILCCHDOC         = ' '
      N_ZTITLC1                    = ZTITLC1
      O_ZTITLC1                    = *ZTITLC1
      UPD_ZTITLC1                  = L_UPD
      UPD_ZTITLC2                  = L_UPD
      UPD_ZTITLC4                  = L_UPD
      N_ZTITLO1                    = ZTITLO1
      O_ZTITLO1                    = *ZTITLO1
      UPD_ZTITLO1                  = L_UPD
      N_ZTITPC1                    = ZTITPC1
      O_ZTITPC1                    = *ZTITPC1
      UPD_ZTITPC1                  = L_UPD
      UPD_ZTITPC2                  = L_UPD
      UPD_ZTITPC3                  = L_UPD
      N_ZTITRQK                    = ZTITRQK
      O_ZTITRQK                    = *ZTITRQK
      UPD_ZTITRQK                  = L_UPD
      UPD_ZTITRQP                  = L_UPD
      N_ZTITRQS                    = L_ZTITRQS_NEW
      O_ZTITRQS                    = L_ZTITRQS_OLD
      UPD_ZTITRQS                  = L_UPD
      N_ZTITTT1                    = ZTITTT1
      O_ZTITTT1                    = *ZTITTT1
      UPD_ZTITTT1                  = L_UPD
      UPD_ZTITTT2                  = L_UPD
      UPD_ZTITTT3                  = L_UPD
    TABLES
      ICDTXT_ZTILCCHDOC             = LT_CDTXT
      XZTITLC2                     = XZTITLC2
      YZTITLC2                     = YZTITLC2
      XZTITLC3                     = XZTITLC3
      YZTITLC3                     = YZTITLC3
      XZTITLC4                     = XZTITLC4
      YZTITLC4                     = YZTITLC4
      XZTITPC2                     = XZTITPC2
      YZTITPC2                     = YZTITPC2
      XZTITPC3                     = XZTITPC3
      YZTITPC3                     = YZTITPC3
      XZTITRQP                     = XZTITRQP
      YZTITRQP                     = YZTITRQP
      XZTITTT2                     = XZTITTT2
      YZTITTT2                     = YZTITTT2
      XZTITTT3                     = XZTITTT3
      YZTITTT3                     = YZTITTT3
      XZTITTT4                     = XZTITTT4
      YZTITTT4                     = YZTITTT4.


ENDFORM.                    " set_change_document
*&---------------------------------------------------------------------*
*&      Form  set_event_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_EVENT_FORM USING    P_EVENT
                             P_FORM.
  CLEAR GS_EVENTS.
  READ TABLE GT_EVENTS WITH KEY NAME = P_EVENT
                       INTO GS_EVENTS.
  IF SY-SUBRC = 0.
    GS_EVENTS-FORM = P_FORM.
    MODIFY GT_EVENTS FROM GS_EVENTS INDEX SY-TABIX.
  ELSE.
    GS_EVENTS-NAME = P_EVENT.
    GS_EVENTS-FORM = P_FORM.
    APPEND GS_EVENTS TO GT_EVENTS.
  ENDIF.

ENDFORM.                    " set_event_form
*&--------------------------------------------------------------------*
*&      Form  alv_data_changed
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM DATA_CHANGED USING RR_DATA_CHANGED
                        TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA : LS_MOD_CELLS TYPE LVC_S_MODI,
         LS_CELLS     TYPE LVC_S_MODI,
         L_MATNR      LIKE MARA-MATNR.

  LOOP AT RR_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    CASE LS_MOD_CELLS-FIELDNAME.
      WHEN 'RETXT'.
        PERFORM SET_DATA_CHANGED USING RR_DATA_CHANGED LS_MOD_CELLS.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    "alv_data_changed
*&---------------------------------------------------------------------*
*&      Form  set_data_changed
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_DATA_CHANGED  USING
      RR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                  RS_MOD_CELLS TYPE LVC_S_MODI.

  FIELD-SYMBOLS: <LS_TABLE>,
                 <L_RETXT>.

  DATA: LS_TABLE      LIKE ZTITRQS.

*> Work Area Assign
  ASSIGN LOCAL COPY OF INITIAL LINE OF <GT_TABLE> TO <LS_TABLE>.

  READ TABLE <GT_TABLE> INTO <LS_TABLE> INDEX RS_MOD_CELLS-ROW_ID.

  ASSIGN COMPONENT 'RETXT' OF STRUCTURE
                        <LS_TABLE> TO <L_RETXT>.

*  MOVE-CORRESPONDING <ls_table> TO ls_table.

  CASE RS_MOD_CELLS-FIELDNAME.
    WHEN 'RETXT'.
      CALL METHOD RR_DATA_CHANGED->GET_CELL_VALUE
           EXPORTING
              I_ROW_ID       = RS_MOD_CELLS-ROW_ID
*              I_TABIX
              I_FIELDNAME    = 'RETXT'
           IMPORTING
              E_VALUE        = <L_RETXT>.

      CALL METHOD RR_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = RS_MOD_CELLS-ROW_ID
          I_FIELDNAME = 'RETXT'
          I_VALUE     = <L_RETXT>.

    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " set_data_changed
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEND_MAIL USING    P_REQNO.
  DATA: LV_FLAG,
        LV_TEXT1(255),
        LV_TEXT2(255),
        LV_TEXT3(255),
        LV_STEP_TXT(15),
        LV_STEP_TXT_S(15). "메일제목

**E-MAIL
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


  DATA : LV_SEND LIKE ADR6-SMTP_ADDR,
         LV_RECV LIKE ADR6-SMTP_ADDR.

  DATA: RESULT_TAB  TYPE MATCH_RESULT_TAB.

  CLEAR : LV_FLAG.

  DEFINE MAIL_MSG.
    APPEND &1 TO GT_MESSAGE.
  END-OF-DEFINITION.

  CLEAR  : GT_MESSAGE, GV_SUBJECT, LV_TEXT1, LV_TEXT2, LV_TEXT3.
  REFRESH: GT_MESSAGE.

  CLEAR : LV_STEP_TXT, LV_STEP_TXT_S.

  LV_STEP_TXT = '구매확인서 관련의 건'.
  LV_STEP_TXT_S = ' 수입문서'.

  CONCATENATE LV_STEP_TXT
          '[' LV_STEP_TXT_S ':'  P_REQNO ']'
         INTO GV_SUBJECT SEPARATED BY SPACE.


  CONCATENATE '<br>'
              '수입요청번호 : ['
              P_REQNO
              '] 가 승인되었습니다.'
              '확인 후 처리 부탁 드립니다.'
              '<br><br>'
         INTO LV_TEXT1 SEPARATED BY SPACE.

  MAIL_MSG: '<html>',
            '<body>',
            LV_TEXT1,
*            LV_TEXT2,
*            LV_TEXT3,
            '</body>',
            '</html>'.

  TRY.
      G_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

      " 보내는 사람 지정
      CLEAR : LV_SEND.

      G_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                      I_TYPE    = 'HTM'
                      I_TEXT    = GT_MESSAGE
                      I_SUBJECT = GV_SUBJECT ).

      G_EMAIL->SET_DOCUMENT( G_EMAIL_BODY ).


      CLEAR : LV_RECV.
*       LV_RECV = 'lwh10@naver.com'.

      SELECT SINGLE  EMAIL
        INTO LV_RECV
        FROM ZTITRQM
        WHERE ZAUTH EQ 'V'.

      G_RECEIVER = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
                    I_ADDRESS_STRING = LV_RECV ).

      G_EMAIL->ADD_RECIPIENT( I_RECIPIENT = G_RECEIVER
                              I_EXPRESS   = 'X' ).

      G_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

      G_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                     RECEIVING RESULT              = GV_SEND_RESULT ).

      COMMIT WORK.

    CATCH CX_BCS INTO G_EXCEPTION.
*       LV_FLAG = 'X'.

      EXIT.
  ENDTRY.

** 메일 전송여부에 따라 COMMIT 및 ROLLBACK 수행
  IF LV_FLAG = 'X'.
*___메일 전송 실패
    ROLLBACK WORK.
    MESSAGE S001 WITH '메일전송 실패!'
    DISPLAY LIKE 'E'.
    EXIT.
  ELSE.
    COMMIT WORK.
  ENDIF.

ENDFORM.                    " SEND_MAIL
