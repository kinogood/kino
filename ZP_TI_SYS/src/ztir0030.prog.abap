************************************************************************
*                                                                      *
* Title         : ZTIR0030                                             *
*                                                                      *
* Description   : [Report] 수입요청(개설) 상태별 현황 Report           *
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
* 2008/10/23   FIB05            [제목] 송금 요청화면에 선적일 표시     *
*                               [CSR_NO] C20080918_30288               *
* 2009/01/29   FIB05            [제목] 승인날짜를 레이아웃항목         *
*                               [CSR_NO] C20090116_87648               *
* 2009/05/22   FIB05            [제목]수입개설화면 항목 추가 요청      *
*                               [CSR_NO] C20090519_58482               *
* 2011/03/08   FIB05            [제목] 거래처 등록 확정관련 시스템 수정*
*                               [CSR_NO] C20110127_15925               *
* 2017/02/28   신재호           [제목] 구매처명/계좌주명 확인 로직 추가*
*                               [CSR_NO] 기능개선 184344               *
* 2024/08/22   이원형           [제목] 자재코드/구매그룹명 필드 추가*
*                               [CSR_NO] CHM2404-00292
* 2026/04/07   박우진           [제목] 선적일자/ 유효기일 필드 추가,
*                               [CSR_NO] NOT AVAILALBE YET
*
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
        EKBZ  ,    ">History per Purchasing Document: Delivery Costs
        EKBE  ,    ">History per Purchasing Document
        EKKO,      ">Purchasing Document Header
        EKPO  ,    ">Purchasing Document Items
        EKKN,      ">Account Assignment in Purchasing Document
        DFIES ,    ">DD Interface: Table Fields for DDIF_FIELDINFO_GET
        SPOP  ,    ">POPUP_TO_CONFIRM_... function 모듈 팝업화면 필드.
        ZTISSCRCOM, ">수출입시스템 Screen용 Structure(공용)
        ZTITRQK,    ">[Import] Document Header
        ZTITRQP,    ">[Import] Document Item
        ZTITRQS,    ">[Import] Document Status
        ZTITBLK,    ">BL내역
        ZTITBLP,    ">BL품목내역
        ZTIVRQ02,  ">header + status Views
        ZTITIG04.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 KSH --------------------------------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 KSH --------------------------------------
  C_SAVE(1) TYPE  C             VALUE 'A',
  C_ERROR   TYPE  C             VALUE 'E'.

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
  PARAMETERS: P_STEP1 RADIOBUTTON GROUP AB1              MODIF ID M1,
              P_STEP2 RADIOBUTTON GROUP AB1  DEFAULT 'X' MODIF ID M2,
              P_STEP3 RADIOBUTTON GROUP AB1              MODIF ID M3,
              P_STEP8 RADIOBUTTON GROUP AB1              MODIF ID M8,
*                                          NO-DISPLAY ,
*            p_step6 RADIOBUTTON GROUP ab1              MODIF ID m6
*                                          NO-DISPLAY ,
              P_STEP7 RADIOBUTTON GROUP AB1              MODIF ID M7,
              P_STEP4 RADIOBUTTON GROUP AB1              MODIF ID M4,
              P_STEP5 RADIOBUTTON GROUP AB1              MODIF ID M5.
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
         LIFNR LIKE   LFA1-LIFNR,
         NAME1 LIKE   LFA1-NAME1.
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

DATA: S_VARIANT LIKE  DISVARIANT,
      S_VAR_USR LIKE  DISVARIANT.

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
DATA: FC      TYPE SLIS_T_FIELDCAT_ALV,
      FC1     TYPE SLIS_T_FIELDCAT_ALV,
      FCS     TYPE SLIS_FIELDCAT_ALV,
      IT_SORT TYPE SLIS_T_SORTINFO_ALV.

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

AT SELECTION-SCREEN OUTPUT.
  CHECK NOT ZTITIG00-RQPCS IS INITIAL.

  LOOP AT SCREEN.
    CASE ZTITIG00-RQPCS.
      WHEN 'A'. ">의뢰->접수->EDI작성->승인(전송)->개설 단계사용.
      WHEN 'B'. ">의뢰->접수->EDI작성(전송)->개설 단계사용.
        IF SCREEN-GROUP1 EQ 'M8' OR
           SCREEN-GROUP1 EQ 'M6'.
          SCREEN-INPUT     = '0'.
          SCREEN-INVISIBLE = '1'.
          SCREEN-ACTIVE    = '0'.
        ENDIF.
      WHEN 'C'. ">의뢰->EDI작성(전송)->개설 단계사용.
        IF SCREEN-GROUP1 EQ 'M1' OR
           SCREEN-GROUP1 EQ 'M8' OR
           SCREEN-GROUP1 EQ 'M6'.
          SCREEN-INPUT     = '0'.
          SCREEN-INVISIBLE = '1'.
        ENDIF.
      WHEN 'D'. ">의뢰->은행배정->승인(전송)->개설 단계사용.
        IF SCREEN-GROUP1 EQ 'M1'.
          SCREEN-INPUT     = '0'.
          SCREEN-INVISIBLE = '1'.
          SCREEN-ACTIVE    = '0'.
        ENDIF.
      WHEN 'E'. ">의뢰(EDI작성/전송)->개설 단계사용.
        IF SCREEN-GROUP1 EQ 'M1' OR
           SCREEN-GROUP1 EQ 'M8' OR
           SCREEN-GROUP1 EQ 'M6' OR
           SCREEN-GROUP1 EQ 'M2'.
          SCREEN-INPUT     = '0'.
          SCREEN-INVISIBLE = '1'.
        ENDIF.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

AT SELECTION-SCREEN.
  PERFORM INPUT_FIELD_CHECK.
  PERFORM ALV_VARIANT_CHECK.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM P1102_AUTHORIZATION_CHECK USING S_BUKRS-LOW.
** JS전선 회사코드 2007/04 KSH --------------------------------------

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

  SET TITLEBAR 'T1000' WITH '상태별 수입요청(개설)'.

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
    MESSAGE E348(M7) WITH  DFIES-SCRTEXT_M.
  ELSE.
    SELECT SINGLE *
      FROM ZTITIG00
     WHERE BUKRS EQ L_BUKRS.
    IF SY-SUBRC NE 0.
      MESSAGE E035 WITH L_BUKRS.
    ENDIF.
    CASE 'X'.
      WHEN P_STEP1. ">요청대상.
      WHEN P_STEP2. ">접수대상.
        IF NOT ( ZTITIG00-RQPCS EQ 'A' OR
                 ZTITIG00-RQPCS EQ 'B' ).
          MESSAGE E939 WITH '접수'.
        ENDIF.
      WHEN P_STEP3. ">은행배정 대상.
        IF ZTITIG00-RQPCS EQ 'E'.
          MESSAGE E939 WITH '은행배정'.
        ENDIF.
      WHEN P_STEP4. ">개설신청 진행 중.
      WHEN P_STEP5. ">개설완료.
*      WHEN p_step6. ">승인대상.
      WHEN P_STEP7. ">EDI전송 대상
*-----> 전선 요청으로 반려대상 나오게 함. by MSH,050506
      WHEN P_STEP8. ">반려 리스트.
        IF NOT ( ZTITIG00-RQPCS EQ 'A' OR
                 ZTITIG00-RQPCS EQ 'B' ).
          MESSAGE E939 WITH '회송대상'.
        ENDIF.
*-----> End of Modification.
    ENDCASE.
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

  RANGES: LR_DOCST   FOR   ZTITRQS-DOCST OCCURS 1.

  FIELD-SYMBOLS: <LS_TABLE>.
  FIELD-SYMBOLS: <L_FIELD1>.
  FIELD-SYMBOLS: <L_FIELD2>.
  FIELD-SYMBOLS: <L_EBELN>.
*  FIELD-SYMBOLS: <l_ebelp>.
  FIELD-SYMBOLS: <L_DDTEXT>.
  FIELD-SYMBOLS: <L_ILCTY>.
  FIELD-SYMBOLS: <L_TEXT2>.
  FIELD-SYMBOLS: <L_PAGRT>.
  FIELD-SYMBOLS: <L_BLETD>.
  FIELD-SYMBOLS: <L_APPDT>.
  FIELD-SYMBOLS: <L_STAWN>.

  FIELD-SYMBOLS: <L_TDPYN>.

  FIELD-SYMBOLS: <L_MATNR>.
  FIELD-SYMBOLS: <L_EKNAM>.
  FIELD-SYMBOLS: <L_EKGRP>.

  DATA: L_IBLNO LIKE ZTITBLK-IBLNO.
  DATA: L_EBELP LIKE ZTITRQP-EBELP.
  DATA: L_STAWN LIKE ZTITRQP-STAWN.

  CLEAR: L_IBLNO.

  REFRESH : <GT_TABLE>.
*> PROGRESS Display.
  G_LINE1    = 30.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
  REPLACE '%99999%' WITH G_LINE1 INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINE1.

  CLEAR LR_DOCST .
  MOVE: 'I'     TO    LR_DOCST-SIGN,
        'EQ'    TO    LR_DOCST-OPTION.
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
      MOVE: SPACE TO  LR_DOCST-LOW.    APPEND LR_DOCST .
      MOVE: 'R'   TO  LR_DOCST-LOW.    APPEND LR_DOCST .
    WHEN P_STEP2. ">접수대상
      MOVE: 'C'   TO  LR_DOCST-LOW.    APPEND LR_DOCST .
    WHEN P_STEP3. ">EDI 작성대상
      IF ZTITIG00-RQPCS EQ 'D'.
        MOVE: 'C'   TO  LR_DOCST-LOW.    APPEND LR_DOCST .
      ENDIF.
      MOVE: 'A'   TO  LR_DOCST-LOW.    APPEND LR_DOCST .
      MOVE: 'W'   TO  LR_DOCST-LOW.    APPEND LR_DOCST .
    WHEN P_STEP4. ">개설의뢰 진행 중
      MOVE: 'Y'   TO  LR_DOCST-LOW.    APPEND LR_DOCST .
    WHEN P_STEP5. ">개설완료
      MOVE: 'O'   TO  LR_DOCST-LOW.    APPEND LR_DOCST .
*    WHEN p_step6. ">상신대상.
*      MOVE: 'W'   TO  lr_docst-low.    APPEND lr_docst .
    WHEN P_STEP7. ">승인/송신대상
      MOVE: '1'   TO  LR_DOCST-LOW.    APPEND LR_DOCST .
      MOVE: 'N'   TO  LR_DOCST-LOW.    APPEND LR_DOCST .
*    WHEN p_step8. ">반려 리스트.
*      MOVE: '2'   TO  lr_docst-low.    APPEND lr_docst .
  ENDCASE.

  "--> [가온] 미승인 프로세스도 조회되도록 함
**** 가온은 승인 프로세스 사용 X (RQRLS)
  IF S_BUKRS-LOW <> '6000'.
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
       AND DOCST  IN  LR_DOCST
       AND RQRLS  = 'X'.
  ELSE.
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
       AND DOCST  IN  LR_DOCST.
*     AND RQRLS  = 'X'.
  ENDIF.
  "<-- [가온] 미승인 프로세스도 조회되도록 함

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
    ASSIGN COMPONENT 'MATNR' OF STRUCTURE
                        <LS_TABLE> TO <L_MATNR>.


    IF SY-SUBRC EQ 0.
      SELECT SINGLE EBELN EBELP
        INTO (<L_EBELN>,L_EBELP)
        FROM ZTITRQP
       WHERE REQNO EQ <L_FIELD1>
         AND AMDSQ EQ <L_FIELD2>.

      SELECT SINGLE MATNR
        INTO <L_MATNR>
        FROM EKPO
       WHERE EBELN EQ <L_EBELN>
         AND EBELP EQ L_EBELP.
    ENDIF.

    ASSIGN COMPONENT 'BLETD' OF STRUCTURE
                        <LS_TABLE> TO <L_BLETD>.
    ASSIGN COMPONENT 'APPDT' OF STRUCTURE
                        <LS_TABLE> TO <L_APPDT>.

    ASSIGN COMPONENT 'STAWN' OF STRUCTURE
                        <LS_TABLE> TO <L_STAWN>.

    SELECT SINGLE IBLNO STAWN
      INTO (L_IBLNO,<L_STAWN>)
      FROM ZTITRQP
     WHERE REQNO EQ <L_FIELD1>.
*       AND cdat  GE <l_appdt>.
*    ENDSELECT.
    MOVE <L_STAWN> TO L_STAWN.

    IF SY-SUBRC EQ 0.
      SELECT BLETD
        INTO <L_BLETD>
        FROM ZTITBLK UP TO 1 ROWS
       WHERE IBLNO EQ L_IBLNO.
      ENDSELECT.
    ELSE.
      SELECT IBLNO
        INTO L_IBLNO
        FROM ZTITBLP
       WHERE EBELN EQ <L_EBELN>
         AND EBELP EQ L_EBELP.
      ENDSELECT.
      IF SY-SUBRC EQ 0.
        SELECT BLETD
          INTO <L_BLETD>
          FROM ZTITBLK UP TO 1 ROWS
         WHERE IBLNO EQ L_IBLNO.
        ENDSELECT.
      ENDIF.
    ENDIF.

*>신용공여주체
    PERFORM  GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING 'ZTIPAGRT'
                                                   <L_PAGRT>
                                                   <L_TEXT2>.

*>지불조건
    PERFORM  GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING 'ZTIILCTY'
                                                   <L_ILCTY>
                                                   <L_DDTEXT>.


*=={ CHM-XXXXXXX, 양환옥
    ASSIGN COMPONENT 'TDPYN' OF STRUCTURE
                        <LS_TABLE> TO <L_TDPYN>.

    SELECT SINGLE TDPYN
      INTO <L_TDPYN>
      FROM ZTITRQK
     WHERE REQNO EQ <L_FIELD1>.
*==  CHM-XXXXXX }

    ASSIGN COMPONENT 'EKGRP' OF STRUCTURE
                        <LS_TABLE> TO <L_EKGRP>.
    ASSIGN COMPONENT 'EKNAM' OF STRUCTURE
                        <LS_TABLE> TO <L_EKNAM>.

    SELECT SINGLE EKNAM
      INTO <L_EKNAM>
      FROM T024
     WHERE EKGRP EQ <L_EKGRP>.

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
  AC 'ITAB   OPNNO ZTITRQS                      OPNNO '.
  AC 'ITAB   REQTY ZTITRQK                      REQTY '.
  AC 'ITAB   ILCTY ZTITRQK                      ILCTY '.
  AC 'ITAB   DDTEXTDD07D                        DDTEXT'.
  AC 'ITAB   PAGRT ZTITRQS                      PAGRT X'.
  AC 'ITAB   TEXT2 DD07D                        DDTEXT'.
  AC 'ITAB   USCDY ZTITRQK                      USCDY '.
  AC 'ITAB   EBELN ZTITIP1                      EBELN '.
  AC 'ITAB   PSPNR ZTITRQK                      PSPNR X'.
  AC 'ITAB   SNDDT ZTITRQS                      SNDDT '.

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
  AC 'ITAB   RQRLS ZTITRQS                      RQRLS '.
  AC 'ITAB   BLETD ZTITBLK                      BLETD '.
  AC 'ITAB   STAWN ZTITRQP                      STAWN '.
  AC 'ITAB   MATNR EKPO                         MATNR '.
  AC 'ITAB   EKNAM T024                         EKNAM '.

  AC 'ITAB   ANAM  ZTITRQS                      ANAM '.
  AC 'ITAB   ADAT  ZTITRQS                      ADAT '.
  AC 'ITAB   ATME  ZTITRQS                      ATME '.


*=={ CHM-XXXXXXX, 양환옥
  AC 'ITAB   TDPYN ZTITRQK                      TDPYN '.  " 삼국무역
  AC 'ITAB   FLAND ZTITRQS                      FLAND '.  " 선적국가
  AC 'ITAB   FPORT ZTITRQS                      FPORT '.  " 선적항
  AC 'ITAB   TLAND ZTITRQS                      TLAND '.  " 도착국가
  AC 'ITAB   TPORT ZTITRQS                      TPORT '.  " 도착항
*==  CHM-XXXXXX }


*[S] 선적일, 유효기일 필드 추가 by 박우진
  AC 'ITAB   EXDAT ZTITRQS                      EXDAT '.   "유효기일
  AC 'ITAB   LSDAT ZTITRQS                      LSDAT '.   "최종선적일자

*[E] 선적일, 유효기일 필드 추가 by 박우진

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
      WHEN 'TEXT2'.
        FCS-SELTEXT_L = '신용'.
        FCS-SELTEXT_S = '신용공여'.
        FCS-SELTEXT_M = '신용공여주체'.
        FCS-OUTPUTLEN = 12.
      WHEN 'OPAMT' OR 'USAMT'.
        FCS-DO_SUM = 'X'.

*=={ CHM-XXXXXXX, 양환옥
      WHEN 'TDPYN'.
        FCS-SELTEXT_L = '삼국'.
        FCS-SELTEXT_S = '삼국'.
        FCS-SELTEXT_M = '삼국무역'.
        FCS-CHECKBOX  = 'X'.
*==  CHM-XXXXXX }

      WHEN 'MATNR'.
        FCS-SELTEXT_L = '자재코드'.
        FCS-SELTEXT_S = '자재코드'.
        FCS-SELTEXT_M = '자재코드'.

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
      SET TITLEBAR 'T1000' WITH '수입개설 요청대상'.
    WHEN P_STEP2. ">접수대상
      SET TITLEBAR 'T1000' WITH '수입개설 접수대상'.
    WHEN P_STEP3. ">신청대상
      SET TITLEBAR 'T1000' WITH '수입개설 신청대상'.
    WHEN P_STEP4. ">개설의뢰 진행 중
      SET TITLEBAR 'T1000' WITH '수입개설 신청 진행 중'.
    WHEN P_STEP5. ">개설완료
      SET TITLEBAR 'T1000' WITH '수입 개설'.
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

*  events-name = slis_ev_subtotal_text.
*  events-form = slis_ev_subtotal_text.
*  APPEND events.
*
*> ALV reuse function call..
  CALL FUNCTION ALV_DETAIL_FUNC
    EXPORTING
      I_CALLBACK_PROGRAM       = ALV_REPID
      I_CALLBACK_PF_STATUS_SET = 'SET_ALV_STATUS'
      I_CALLBACK_USER_COMMAND  = 'USER_ALV_COMMAND'
*     I_STRUCTURE_NAME         =
*     IT_EXCLUDING             =
*     IT_SPECIAL_GROUPS        =
*     IT_FILTER                =
*     IS_SEL_HIDE              =
*     I_DEFAULT                = 'X'
*     I_SAVE                   = ' '
*     IS_VARIANT               =
      IT_EVENTS                = EVENTS[]
      IT_EVENT_EXIT            = EXIT[]
*     IS_PRINT                 =
*     IS_REPREP_ID             =
*     I_SCREEN_START_COLUMN    = 0
*     I_SCREEN_START_LINE      = 0
*     I_SCREEN_END_COLUMN      = 0
*     I_SCREEN_END_LINE        = 0
      IT_FIELDCAT              = FC_DETAIL[]
      IT_SORT                  = IT_SORT
*     I_DEFAULT                = 'X'
*     IS_VARIANT               = VARIANT_DETAIL
      IS_VARIANT               = ALV_VARIANT
      I_SAVE                   = C_SAVE
      IS_LAYOUT                = GS_LAYOUT
      IS_PRINT                 = ALV_PRINT
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
*     ES_EXIT_CAUSED_BY_USER   =
    TABLES
      T_OUTTAB                 = <GT_TABLE>.
*        t_outtab                 = gt_tran.

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
      APPEND 'ZTIT005'  TO EXTAB.
      APPEND 'ZTIT006'  TO EXTAB.
      APPEND 'ZTIT007'  TO EXTAB.
      APPEND 'ZTIT007B' TO EXTAB.
      APPEND 'ZTIT008'  TO EXTAB.
      APPEND 'ZTIT009'  TO EXTAB.
    WHEN P_STEP2. ">접수대상
      APPEND 'ZTIT002'  TO EXTAB.
      APPEND 'ZTIT006'  TO EXTAB.
      APPEND 'ZTIT007'  TO EXTAB.
      APPEND 'ZTIT007B' TO EXTAB.
      APPEND 'ZTIT008'  TO EXTAB.
      APPEND 'ZTIT009'  TO EXTAB.
    WHEN P_STEP3. ">EDI 신청대상
      APPEND 'ZTIT002'  TO EXTAB.
      APPEND 'ZTIT005'  TO EXTAB.
      APPEND 'ZTIT006'  TO EXTAB.
      APPEND 'ZTIT009'  TO EXTAB.
    WHEN P_STEP4. ">개설의뢰 진행 중
      APPEND 'ZTIT002'  TO EXTAB.
      APPEND 'ZTIT005'  TO EXTAB.
      APPEND 'ZTIT006'  TO EXTAB.
      APPEND 'ZTIT007'  TO EXTAB.
      APPEND 'ZTIT007B' TO EXTAB.
      APPEND 'ZTIT008'  TO EXTAB.
      APPEND 'ZTIT009'  TO EXTAB.
    WHEN P_STEP5. ">개설완료
      APPEND 'ZTIT002'  TO EXTAB.
      APPEND 'ZTIT005'  TO EXTAB.
      APPEND 'ZTIT006'  TO EXTAB.
      APPEND 'ZTIT007'  TO EXTAB.
      APPEND 'ZTIT007B' TO EXTAB.
      APPEND 'ZTIT008'  TO EXTAB.
      APPEND 'ZTIT009'  TO EXTAB.
*    WHEN p_step6. ">상신처리.
*      APPEND 'ZTIT002'  TO extab.
*      APPEND 'ZTIT005'  TO extab.
*      APPEND 'ZTIT007'  TO extab.
*      APPEND 'ZTIT007B' TO extab.
*      APPEND 'ZTIT008'  TO extab.
*      APPEND 'ZTIT009'  TO extab.
*    WHEN p_step8. ">반려 처리.
*      APPEND 'ZTIT002'  TO extab.
*      APPEND 'ZTIT005'  TO extab.
*      APPEND 'ZTIT007'  TO extab.
*      APPEND 'ZTIT007B' TO extab.
*      APPEND 'ZTIT008'  TO extab.
*      APPEND 'ZTIT009'  TO extab.
    WHEN P_STEP7. ">승인/전송관리.
      APPEND 'ZTIT002'  TO EXTAB.
      APPEND 'ZTIT005'  TO EXTAB.
      APPEND 'ZTIT006'  TO EXTAB.
      APPEND 'ZTIT008'  TO EXTAB.
      APPEND 'ZTIT007'  TO EXTAB.
      APPEND 'ZTIT007B' TO EXTAB.
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
        L_DATE(10) TYPE C.

  FIELD-SYMBOLS: <LS_TABLE>.
  FIELD-SYMBOLS: <L_FIELD>.
  FIELD-SYMBOLS: <L_FIELD1>.
  FIELD-SYMBOLS: <L_FIELD2>.
  FIELD-SYMBOLS: <L_FIELD3>.
  FIELD-SYMBOLS: <L_FIELD4>. "기능개선 184344.
  FIELD-SYMBOLS: <L_FIELD5>. "기능개선 184344.


  ASSIGN LOCAL COPY OF INITIAL LINE OF <GT_TABLE> TO <LS_TABLE>.

  CASE R_UCOMM.
    WHEN 'ZTIT007'.   ">EDI 작성.
      ASSIGN COMPONENT 'BOX' OF STRUCTURE
                               <LS_TABLE> TO <L_FIELD>.
      CLEAR: L_COUNT.

      LOOP AT <GT_TABLE> INTO <LS_TABLE>.
        IF <L_FIELD> EQ 'X'.
          ADD 1 TO L_COUNT.
          ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                                  <LS_TABLE> TO <L_FIELD1>.
          ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD2>.
          L_REQNO = <L_FIELD1>.
          L_AMDSQ = <L_FIELD2>.
        ENDIF.
      ENDLOOP.
      CASE L_COUNT.
        WHEN 1.
        WHEN 0.
          MESSAGE E909.
        WHEN OTHERS.
          MESSAGE E929.
      ENDCASE.

*> 초기화면.
      PERFORM EXCUTE_IMPORT_DOCUMENT(ZTIR0000)
                           USING L_REQNO L_AMDSQ 'ZTIT006'.

      PERFORM GET_DATA_FOR_DISPLAY.    ">data select
      RS_SELFIELD-REFRESH = 'X'.
*> 은행배정.
    WHEN 'ZTIT007B'.
      ASSIGN COMPONENT 'BOX' OF STRUCTURE
                               <LS_TABLE> TO <L_FIELD>.
      CLEAR: L_COUNT.
      LOOP AT <GT_TABLE> INTO   <LS_TABLE>.
        IF <L_FIELD> EQ 'X'.
          ADD 1 TO L_COUNT.
        ENDIF.
      ENDLOOP.
      IF L_COUNT EQ 0.
        MESSAGE S903.
      ELSE.
        CLEAR: OK-CODE.
        ZTISSCRCOM-SNDDT  =  SY-DATLO.

        SPOP-TEXTLINE1 = '선택된 수입의뢰문서들의 은행을 배정합니다.'.
        SPOP-TEXTLINE2 = '일괄로 은행을 배정하시겠습니까?'.

        CALL SCREEN  2000 STARTING AT 01    01.

        CHECK OK-CODE EQ 'ZTIOKAY'.

        REFRESH: BDCDATA, IT_MSG.
        CLEAR: SESSION.
        CTU_PARAMS-DISMODE  = 'E'. ">처리모드
        CTU_PARAMS-UPDMODE  = 'S'. ">갱신모드
        CTU_PARAMS-CATTMODE = ' '. ">CATT 모드...
        CTU_PARAMS-DEFSIZE  = ' '. ">기본화면 크기
        CTU_PARAMS-RACOMMIT = 'X'.
        CTU_PARAMS-NOBINPT  = ' ' .
        CTU_PARAMS-NOBIEND  = ' '.

        LOOP AT <GT_TABLE> INTO   <LS_TABLE>.
          IF <L_FIELD> EQ 'X'.
*> 초기화면.
            ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                                  <LS_TABLE> TO <L_FIELD1>.
            ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                                  <LS_TABLE> TO <L_FIELD2>.

            PERFORM BDC_DYNPRO_BUILD USING :
                   'X' 'ZTIR0000'          '0200',
                   ' ' 'ZTISSCRCOM-REQNO'  <L_FIELD1>,
                   ' ' 'ZTISSCRCOM-AMDSQ'  <L_FIELD2>,
                   ' ' 'BDC_OKCODE'       '=ZTIENTER'.
*> 세부화면.
            WRITE: ZTISSCRCOM-SNDDT TO L_DATE.
            IF <L_FIELD2> IS INITIAL.
              PERFORM BDC_DYNPRO_BUILD USING :
                     'X' 'ZTIR0000'          '2000',
                     ' ' 'ZTITRQK-OPNBK'     ZTISSCRCOM-OPNBK,
                     ' ' 'ZTITRQS-SNDDT'     L_DATE,
                     ' ' 'BDC_OKCODE'       '=ZTIAPPLY'.
            ELSE.
              PERFORM BDC_DYNPRO_BUILD USING :
                     'X' 'ZTIR0000'          '2000',
                     ' ' 'ZTITRQS-SNDDT'     L_DATE,
                     ' ' 'BDC_OKCODE'       '=ZTIAPPLY'.
            ENDIF.

            PERFORM BDC_DYNPRO_BUILD USING :
                   'X' 'SAPLSPO1'          '0300',
                   ' ' 'BDC_OKCODE'       '=YES'.

            PERFORM BDC_TRANSACTION USING 'ZTIT006' L_SUBRC.

            IF L_SUBRC EQ 0.
              LOOP AT MESSTAB WHERE MSGTYP EQ 'E'.
                MOVE : MESSTAB-MSGTYP  TO IT_MSG-MSGTY,
                       MESSTAB-MSGID   TO IT_MSG-MSGID,
                       MESSTAB-MSGNR   TO IT_MSG-MSGNO,
                       MESSTAB-MSGV1   TO IT_MSG-MSGV1,
                       MESSTAB-MSGV2   TO IT_MSG-MSGV2,
                       MESSTAB-MSGV3   TO IT_MSG-MSGV3,
                       MESSTAB-MSGV4   TO IT_MSG-MSGV4,
                       <L_FIELD1>      TO IT_MSG-REFNO.
                APPEND IT_MSG.
              ENDLOOP.
              IF SY-SUBRC NE 0.
                MESSAGE S143 WITH <L_FIELD1>.
                MOVE:  SY-MSGID   TO  IT_MSG-MSGID,
                       SY-MSGTY   TO  IT_MSG-MSGTY,
                       SY-MSGNO   TO  IT_MSG-MSGNO,
                       SY-MSGV1   TO  IT_MSG-MSGV1,
                       SY-MSGV2   TO  IT_MSG-MSGV2,
                       SY-MSGV3   TO  IT_MSG-MSGV3,
                       SY-MSGV4   TO  IT_MSG-MSGV4,
                       <L_FIELD1> TO  IT_MSG-REFNO.
                APPEND IT_MSG.
              ENDIF.
            ELSE.
              LOOP AT MESSTAB WHERE MSGTYP EQ 'E'.
                MOVE : MESSTAB-MSGTYP  TO IT_MSG-MSGTY,
                       MESSTAB-MSGID   TO IT_MSG-MSGID,
                       MESSTAB-MSGNR   TO IT_MSG-MSGNO,
                       MESSTAB-MSGV1   TO IT_MSG-MSGV1,
                       MESSTAB-MSGV2   TO IT_MSG-MSGV2,
                       MESSTAB-MSGV3   TO IT_MSG-MSGV3,
                       MESSTAB-MSGV4   TO IT_MSG-MSGV4,
                       <L_FIELD1>      TO IT_MSG-REFNO.
                APPEND IT_MSG.
              ENDLOOP.
              IF SY-SUBRC NE 0.
                MESSAGE S926.
                MOVE:  SY-MSGID   TO  IT_MSG-MSGID,
                       'E'        TO  IT_MSG-MSGTY,
                       SY-MSGNO   TO  IT_MSG-MSGNO,
                       SY-MSGV1   TO  IT_MSG-MSGV1,
                       SY-MSGV2   TO  IT_MSG-MSGV2,
                       SY-MSGV3   TO  IT_MSG-MSGV3,
                       SY-MSGV4   TO  IT_MSG-MSGV4,
                       <L_FIELD1> TO  IT_MSG-REFNO.
                APPEND IT_MSG.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
        DESCRIBE TABLE IT_MSG LINES G_LINE.
        IF G_LINE GT 0.
          CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
            EXPORTING
              XDOCNO_SHOW = 'X'
            TABLES
              XMSG        = IT_MSG.
        ENDIF.
        PERFORM GET_DATA_FOR_DISPLAY.    ">data select
        RS_SELFIELD-REFRESH = 'X'.

      ENDIF.
    WHEN 'ZTIT002' OR 'ZTIT005' OR 'ZTIT006' OR 'ZTIT009'.

      ASSIGN COMPONENT 'BOX' OF STRUCTURE
                               <LS_TABLE> TO <L_FIELD>.

      CLEAR: L_COUNT.
      LOOP AT <GT_TABLE> INTO   <LS_TABLE>.
        IF <L_FIELD> EQ 'X'.
          ADD 1 TO L_COUNT.
        ENDIF.
      ENDLOOP.
      IF L_COUNT EQ 0.
        MESSAGE S903.
      ELSE.
        REFRESH: BDCDATA, IT_MSG.
        CLEAR: SESSION.
        CTU_PARAMS-DISMODE  = 'N'. ">처리모드
        CTU_PARAMS-UPDMODE  = 'S'. ">갱신모드
        CTU_PARAMS-CATTMODE = ' '. ">CATT 모드...
        CTU_PARAMS-DEFSIZE  = ' '. ">기본화면 크기
        CTU_PARAMS-RACOMMIT = 'X'.
        CTU_PARAMS-NOBINPT  = ' ' .
        CTU_PARAMS-NOBIEND  = ' '.

        LOOP AT <GT_TABLE> INTO   <LS_TABLE>.
          IF <L_FIELD> EQ 'X'.
*> 초기화면.
            ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                                  <LS_TABLE> TO <L_FIELD1>.
            ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                                  <LS_TABLE> TO <L_FIELD2>.

            SELECT SINGLE *
              FROM ZTITRQK
             WHERE REQNO EQ <L_FIELD1>.
            IF SY-SUBRC EQ 0.
              IF ZTITRQK-ANBTY EQ 'A' AND
                 ZTITRQK-REQTY EQ 'TT'.
                MESSAGE S144 WITH <L_FIELD1>.
                MOVE:  SY-MSGID   TO  IT_MSG-MSGID,
                       'E'        TO  IT_MSG-MSGTY,
                       SY-MSGNO   TO  IT_MSG-MSGNO,
                       SY-MSGV1   TO  IT_MSG-MSGV1,
                       SY-MSGV2   TO  IT_MSG-MSGV2,
                       SY-MSGV3   TO  IT_MSG-MSGV3,
                       SY-MSGV4   TO  IT_MSG-MSGV4,
                       <L_FIELD1> TO  IT_MSG-REFNO.
                APPEND IT_MSG.
              ENDIF.
            ELSE.
              MESSAGE S108 WITH <L_FIELD1>.
              MOVE:  SY-MSGID   TO  IT_MSG-MSGID,
                     'E'        TO  IT_MSG-MSGTY,
                     SY-MSGNO   TO  IT_MSG-MSGNO,
                     SY-MSGV1   TO  IT_MSG-MSGV1,
                     SY-MSGV2   TO  IT_MSG-MSGV2,
                     SY-MSGV3   TO  IT_MSG-MSGV3,
                     SY-MSGV4   TO  IT_MSG-MSGV4,
                     <L_FIELD1> TO  IT_MSG-REFNO.
              APPEND IT_MSG.
            ENDIF.

*-{ 기능개선 184344 - 구매처명/계좌주명 확인 로직 추가
            IF ( ZTITRQK-BUKRS EQ '1000' OR ZTITRQK-BUKRS EQ '5000' )
                 AND R_UCOMM EQ 'ZTIT005' AND ZTITRQK-REQTY EQ 'TT'.
              ASSIGN COMPONENT 'LIFNR' OF STRUCTURE
                                       <LS_TABLE> TO <L_FIELD4>.
              ASSIGN COMPONENT 'NAME1' OF STRUCTURE
                                       <LS_TABLE> TO <L_FIELD5>.
              CLEAR ZTITIG04.
              SELECT SINGLE *
                FROM ZTITIG04
               WHERE LIFNR = <L_FIELD4>.

              IF SY-SUBRC EQ 0.
                IF <L_FIELD5> NE ZTITIG04-TBBAM.
                  DATA : L_TEXT1(50) TYPE C,
                         L_TEXT2(50) TYPE C,
                         LV_ANSWER   TYPE C.
                  CLEAR : L_TEXT1, L_TEXT2, LV_ANSWER.
                  CONCATENATE '업체명-' <L_FIELD5> INTO L_TEXT1.
                  CONCATENATE '계좌주명-' ZTITIG04-TBBAM INTO L_TEXT2.

                  CALL FUNCTION 'POPUP_TO_DECIDE'
                    EXPORTING
                      TEXTLINE1      = L_TEXT1
                      TEXTLINE2      = L_TEXT2
                      TEXTLINE3      = '계속 진행 하시겠습니까? '
                      TEXT_OPTION1   = 'YES'
                      TEXT_OPTION2   = 'NO'
                      TITEL          = '계좌 확인'
                      START_COLUMN   = 25
                      START_ROW      = 6
                      CANCEL_DISPLAY = 'X'
                    IMPORTING
                      ANSWER         = LV_ANSWER.

                  IF LV_ANSWER NE '1'.
                    CONTINUE.
                  ENDIF.
                ELSE.
                  CLEAR LV_ANSWER.
                  LV_ANSWER = '1'.
                ENDIF.

                CHECK LV_ANSWER = '1'.
              ENDIF.
            ENDIF.
*-} 기능개선 184344

            PERFORM BDC_DYNPRO_BUILD USING :
                   'X' 'ZTIR0000'          '0200',
                   ' ' 'ZTISSCRCOM-REQNO'  <L_FIELD1>,
                   ' ' 'ZTISSCRCOM-AMDSQ'  <L_FIELD2>,
*                   ' ' 'ZTISSCRCOM-EBELN'  space,
*                   ' ' 'ZTISSCRCOM-OPNNO'  space,
                   ' ' 'BDC_OKCODE'       '=ZTIENTER'.
*> 세부화면.
            PERFORM BDC_DYNPRO_BUILD USING :
                   'X' 'ZTIR0000'          '2000'.

            IF R_UCOMM EQ 'ZTIT002'.       ">의뢰요청.

* 2011/03/08   FIB05            [제목] 거래처 등록 확정관련 시스템 수정*
*                               [CSR_NO] C20110127_15925               *
***[START]***
              "               거래처 미확정 상태에서는 개설이 불가능하도록
              DATA : LFA_CONF  LIKE LFA1-CONFS,
                     LFB_CONF  LIKE LFB1-CONFS,
                     L_MSG(50).
              CLEAR : LFA_CONF, LFB_CONF, L_MSG.

              ASSIGN COMPONENT 'LIFNR' OF STRUCTURE
                                  <LS_TABLE> TO <L_FIELD3>.
*               확정상태(중앙)
              SELECT SINGLE CONFS
                INTO LFA_CONF
                FROM LFA1
               WHERE LIFNR = <L_FIELD3>.
*               확정상태(회사코드)
              SELECT SINGLE CONFS
                INTO LFB_CONF
                FROM LFB1
               WHERE LIFNR = <L_FIELD3>
                 AND BUKRS = S_BUKRS.

              CONDENSE LFA_CONF NO-GAPS.
              CONDENSE LFB_CONF NO-GAPS.

              IF LFA_CONF NE ''
              OR LFB_CONF NE ''. "미확정상태(1,2)
                L_MSG = '거래처가 미확정 상태입니다. ('.
                CONCATENATE L_MSG <L_FIELD3> ')' INTO L_MSG.

                MOVE : 'E'              TO IT_MSG-MSGTY,
                       'ZMTI00'         TO IT_MSG-MSGID,
                       '999'            TO IT_MSG-MSGNO,
                       L_MSG            TO IT_MSG-MSGV1,
                       <L_FIELD1>       TO IT_MSG-REFNO.
                APPEND IT_MSG.
              ELSE.
                PERFORM BDC_DYNPRO_BUILD USING :
                       ' ' 'BDC_OKCODE'       '=ZTIREQUEST'.
              ENDIF.
***[END]***
            ELSEIF R_UCOMM EQ 'ZTIT005'.   ">접수.
              PERFORM BDC_DYNPRO_BUILD USING :
                     ' ' 'BDC_OKCODE'       '=ZTIACCEPT'.
            ELSEIF R_UCOMM EQ 'ZTIT006'.   ">신청.
              PERFORM BDC_DYNPRO_BUILD USING :
                     ' ' 'BDC_OKCODE'       '=ZTIAPPLY'.
            ELSEIF R_UCOMM EQ 'ZTIT009'.   ">승인..
              PERFORM BDC_DYNPRO_BUILD USING :
                     ' ' 'BDC_OKCODE'       '=ZTISEND'.
            ENDIF.

            PERFORM BDC_DYNPRO_BUILD USING :
                   'X' 'SAPLSPO1'          '0300',
                   ' ' 'BDC_OKCODE'       '=YES'.

            PERFORM BDC_TRANSACTION USING R_UCOMM L_SUBRC.

            IF L_SUBRC EQ 0.
              IF R_UCOMM EQ 'ZTIT002'.
                MESSAGE S121 WITH <L_FIELD1>.
              ELSEIF R_UCOMM EQ 'ZTIT005'.
                MESSAGE S122 WITH <L_FIELD1>.
              ELSEIF R_UCOMM EQ 'ZTIT006'.
                MESSAGE S123 WITH <L_FIELD1>.
              ENDIF.
              MOVE:  SY-MSGID   TO  IT_MSG-MSGID,
                     SY-MSGTY   TO  IT_MSG-MSGTY,
                     SY-MSGNO   TO  IT_MSG-MSGNO,
                     SY-MSGV1   TO  IT_MSG-MSGV1,
                     SY-MSGV2   TO  IT_MSG-MSGV2,
                     SY-MSGV3   TO  IT_MSG-MSGV3,
                     SY-MSGV4   TO  IT_MSG-MSGV4,
                     <L_FIELD1> TO  IT_MSG-REFNO.
              APPEND IT_MSG.
            ELSE.
              LOOP AT MESSTAB WHERE MSGTYP EQ 'E'.
                MOVE : MESSTAB-MSGTYP  TO IT_MSG-MSGTY,
                       MESSTAB-MSGID   TO IT_MSG-MSGID,
                       MESSTAB-MSGNR   TO IT_MSG-MSGNO,
                       MESSTAB-MSGV1   TO IT_MSG-MSGV1,
                       MESSTAB-MSGV2   TO IT_MSG-MSGV2,
                       MESSTAB-MSGV3   TO IT_MSG-MSGV3,
                       MESSTAB-MSGV4   TO IT_MSG-MSGV4,
                       <L_FIELD1>      TO IT_MSG-REFNO.
                APPEND IT_MSG.
              ENDLOOP.
              IF SY-SUBRC NE 0.
                MESSAGE S926.
                MOVE:  SY-MSGID   TO  IT_MSG-MSGID,
                       'E'        TO  IT_MSG-MSGTY,
                       SY-MSGNO   TO  IT_MSG-MSGNO,
                       SY-MSGV1   TO  IT_MSG-MSGV1,
                       SY-MSGV2   TO  IT_MSG-MSGV2,
                       SY-MSGV3   TO  IT_MSG-MSGV3,
                       SY-MSGV4   TO  IT_MSG-MSGV4,
                       <L_FIELD1> TO  IT_MSG-REFNO.
                APPEND IT_MSG.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
        DESCRIBE TABLE IT_MSG LINES G_LINE.
        IF G_LINE GT 0.
          CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
            EXPORTING
              XDOCNO_SHOW = 'X'
            TABLES
              XMSG        = IT_MSG.
        ENDIF.
        PERFORM GET_DATA_FOR_DISPLAY.    ">data select
        RS_SELFIELD-REFRESH = 'X'.
      ENDIF.
    WHEN 'DISPLAY' OR '&IC1'.    " AUF DOPPELKLICK REAGIERIEN
      CHECK RS_SELFIELD-TABINDEX GT 0.

      READ TABLE <GT_TABLE> INTO <LS_TABLE> INDEX RS_SELFIELD-TABINDEX.
      IF SY-SUBRC NE 0.
        MESSAGE S906.            EXIT.
      ENDIF.
      ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                            <LS_TABLE> TO <L_FIELD1>.
      ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                            <LS_TABLE> TO <L_FIELD2>.

      CASE RS_SELFIELD-FIELDNAME.
        WHEN 'REQNO' OR 'AMDSQ'.
          PERFORM DISPLAY_IMPORT_DOCUMENT(ZTIR0000)
                               USING <L_FIELD1> <L_FIELD2> '00000'.
        WHEN OTHERS.              ">해당작업수행..
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
            WHEN P_STEP1. ">의뢰대상
              L_TCODE = 'ZTIT002'.
            WHEN P_STEP2. ">접수대상
              L_TCODE = 'ZTIT005'.
            WHEN P_STEP3. ">신청대상
              L_TCODE = 'ZTIT006'.
*            WHEN p_step4. ">개설의뢰 진행 중
*              l_tcode = 'ZTIT007'.
*            WHEN p_step5. ">개설완료
*              l_tcode = 'ZTIT008'.
            WHEN OTHERS.
              L_TCODE = 'ZTIT003'.
          ENDCASE.

          PERFORM EXCUTE_IMPORT_DOCUMENT(ZTIR0000)
                               USING <L_FIELD1> <L_FIELD2> L_TCODE.
          PERFORM GET_DATA_FOR_DISPLAY.    ">data select
          RS_SELFIELD-REFRESH = 'X'.
      ENDCASE.

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
    WHEN P_STEP1.	">의뢰대상
      HEADER-INFO = '수입요청 대상 현황'.
    WHEN P_STEP2. ">접수대상
      HEADER-INFO = '수입요청 접수대상 현황'.
    WHEN P_STEP3. ">신청대상
      HEADER-INFO = '수입 은행배정 대상 현황'.
    WHEN P_STEP4. ">개설의뢰 진행 중
      HEADER-INFO = '개설요청 진행 중 현황'.
    WHEN P_STEP5. ">개설완료
      HEADER-INFO = '수입개설 현황'.
*    WHEN p_step6. ">개설완료
*      header-info = '상신대상 현황'.
    WHEN P_STEP7. ">개설완료
      HEADER-INFO = '승인/송신 현황'.
*    WHEN p_step8. ">개설완료
*      header-info = '반려 리스트'.
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
*     i_style_table   = i_style_table
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
        CASE GS_FIELDCAT_G-FIELDNAME.
          WHEN 'STAWN'.
            MOVE-CORRESPONDING  GS_FIELDCAT_G TO FCS.
            MOVE: GS_FIELDCAT_G-FIELDNAME     TO FCS-REF_FIELDNAME,
                  'ZTITRQP'                   TO FCS-REF_TABNAME.
            CLEAR: FCS-KEY.
            FCS-NO_OUT = 'X'.
          WHEN OTHERS.
            MOVE-CORRESPONDING  GS_FIELDCAT_G TO FCS.
            MOVE: GS_FIELDCAT_G-FIELDNAME     TO FCS-REF_FIELDNAME,
                  'ZTIVRQ02'                  TO FCS-REF_TABNAME.
            CLEAR: FCS-KEY.
            FCS-NO_OUT = 'X'.
        ENDCASE.
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
*&      Module  pbo_status_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_STATUS_2000 OUTPUT.

  SET PF-STATUS '2000'.
  SET TITLEBAR  'T2000'.

ENDMODULE.                 " pbo_status_2000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  fcode_exit_scr2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FCODE_EXIT_SCR2000 INPUT.

  LEAVE TO SCREEN 0.

ENDMODULE.                 " fcode_exit_scr2000  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_fields  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_FIELDS INPUT.

  CHECK OK-CODE EQ 'ZTIOKAY'.

  IF ZTISSCRCOM-OPNBK IS INITIAL.
    PERFORM  NO_INPUT_CHECK(ZTIR0000) USING 'ZTISSCRCOM'
                                            'OPNBK' C_ERROR.
  ENDIF.

  IF ZTISSCRCOM-SNDDT IS INITIAL.
    PERFORM  NO_INPUT_CHECK(ZTIR0000) USING 'ZTISSCRCOM'
                                            'SNDDT' C_ERROR.
  ENDIF.

ENDMODULE.                 " check_input_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_SCR2000 INPUT.

  CASE OK-CODE.
    WHEN 'ZTIOKAY'.
      LEAVE TO SCREEN 0.
    WHEN 'ZTICANCEL'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " user_command_scr2000  INPUT
