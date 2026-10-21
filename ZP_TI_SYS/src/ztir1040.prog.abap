************************************************************************
*                                                                      *
* Title         : ZTIR1040                                             *
*                                                                      *
* Description   : [Report] 적하부보 상태별 현황 List                   *
*                                                                      *
* Creation Date : 2006/02/17                                           *
*                                                                      *
* Author        : simcho                                      *
*                Copyright ⓒ ASEG Co., LTD. All rights reserved.      *
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
* Date.      Author.  CSR #           Description.                     *
*----------------------------------------------------------------------*
* 2010.02.18 MMB03    C20100217_12468 구매오더 조건 추가
* 2019.10.14 신재호   기능개선 294020 B/L 관리번호 추가
* 2022.06.10 ZLSGDV1  SRM2206-03696   보험증서 출력 시 보험사별 로고반영
************************************************************************
PROGRAM   ZTIR1040
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
*INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* Internal Tables                                                      *
************************************************************************
************************************************************************
* 2007/10/02 simcho by 박혁세K
* 구매오더 POSSIBLE ENTRY ITAB
************************************************************************
DATA: BEGIN OF GT_VALUES OCCURS 0,
        EBELN LIKE EKPO-EBELN,
      END OF GT_VALUES.

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
        ZTITRQK,  ">[Import] Document Header
        ZTITRQS,  ">[Import] Document Status
        ZTITRQP,  ">[Import] Document Items
        ZTIVRQ02,  ">header + status Views
        ZTITIP1,   ">적하 보험  MAIN (APPCIV/CIPADV)
        ZTITIP2,   ">적하부보 보험조건
        ZTITIP3,   ">수입보험구상관리
        ZTITIP4,   ">적하 보험 배서내역 table
        ZTIVIP00,  ">적하보험 Views <수입의뢰 item까지>
        ZTIVIP01.  ">적하보험 Views <수입의뢰 status>

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 KSH --------------------------------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 KSH --------------------------------------
    C_SAVE(1)   TYPE  C             VALUE 'A'.

*___보험증서 출력 추가_Start 2007.06.14
DATA: GS_OUTPUT_OPT  TYPE SSFCOMPOP,
      GS_CONTROL_PAR TYPE SSFCTRLOP,
      GV_FM_NAME     TYPE RS38L_FNAM.

DATA: GS_ZTISINSH    LIKE ZTISINSH.          "SRM2206-03696 - 추가

DATA: GT_ZTISINS     LIKE ZTISINS OCCURS 0 WITH HEADER LINE.
*___보험증서 출력 추가_End   2007.06.14

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK BOX1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS:
  S_BUKRS  FOR ZTIVIP01-BUKRS     "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID BUK,
  S_EKORG  FOR ZTIVIP01-EKORG ,  "구매조직.
  S_EKGRP  FOR ZTIVIP01-EKGRP ,  "구매그룹.
* 2007/10/01 simcho by 박혁세 K
  S_EBELN  FOR ZTIVIP01-EBELN ,  "구매오더
*
  S_IIPNO  FOR ZTIVIP01-IIPNO    "관리번호.
                              MEMORY ID ZTIIIPNO,
  S_AMDSQ  FOR ZTIVIP01-AMDSQ,   "Amend 차수.
  S_REQNO  FOR ZTIVIP01-REQNO    "수입의뢰 관리번호.
                              MEMORY ID ZTIREQNO,
  S_IBLNO  FOR ZTITIP1-IBLNO,    "B/L 관리번호 - 기능개선 294020
  S_INSCP  FOR ZTIVIP01-INSCP ,  "보험회사.
  S_OPNBK  FOR ZTIVIP01-OPNBK ,  "개설은행.

  S_IOPNO  FOR ZTIVIP01-IOPNO ,  "포괄증권번호.
  S_IISDT  FOR ZTIVIP01-IISDT ,  "증권발급일.
  S_ISPNO  FOR ZTIVIP01-ISPNO ,  "증권번호.
  S_REQTY  FOR ZTIVIP01-REQTY ,  "수입의뢰 종류.
  S_ILCTY  FOR ZTIVIP01-ILCTY .  "신용장 종류.
SELECTION-SCREEN ULINE.
PARAMETERS: P_STEP1 RADIOBUTTON GROUP AB1,
            P_STEP2 RADIOBUTTON GROUP AB1,
            P_STEP3 RADIOBUTTON GROUP AB1,
            P_STEP4 RADIOBUTTON GROUP AB1,
            P_STEP5 RADIOBUTTON GROUP AB1 DEFAULT 'X'.
SELECTION-SCREEN ULINE.
SELECT-OPTIONS:
  S_LIFNR  FOR ZTIVIP01-LIFNR ,   "공급업체 계정번호.
  S_LIFRE  FOR ZTIVIP01-LIFRE ,   "다른 송장발행처.
  S_OFFER  FOR ZTIVIP01-OFFER ,   "오퍼상(Offer).
  S_OPNNO  FOR ZTIVIP01-OPNNO ,   "수입개설번호
  S_OPNDT  FOR ZTIVIP01-OPNDT ,   "개설일자.
  S_ZTERM  FOR ZTIVIP01-ZTERM ,   "지급조건키.
  S_WAERS  FOR ZTIVIP01-WAERS ,   "개설통화.
  S_INCO1  FOR ZTIVIP01-INCO1 ,   "인도조건 (파트 1).
  S_EXDAT  FOR ZTIVIP01-EXDAT ,   "유효기일.
  S_LSDAT  FOR ZTIVIP01-LSDAT ,   "최종선적일자.
  S_FWDTY  FOR ZTIVIP01-FWDTY ,   "운송 방법.
  S_FLAND  FOR ZTIVIP01-FLAND ,   "선적국가.
  S_FPORT  FOR ZTIVIP01-FPORT ,   "선적항.
  S_TLAND  FOR ZTIVIP01-TLAND ,   "도착국가.
  S_TPORT  FOR ZTIVIP01-TPORT ,   "도착항.
  S_DOCST  FOR ZTIVIP01-DOCST ,   "문서상태.
  S_SNDST  FOR ZTIVIP01-SNDST ,   "EDI상태.
  S_CNAM   FOR ZTIVIP01-CNAM  ,   "작성인.
  S_CDAT   FOR ZTIVIP01-CDAT  ,   "생성일.
  S_UNAM   FOR ZTIVIP01-UNAM  ,   "최종변경인.
  S_UDAT   FOR ZTIVIP01-UDAT  .   "변경일.
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

*     화면에 입력된 값을 읽어들이기 위한 INTERNAL TABLE
DATA: GT_DYNPFIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

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
       LINE_CNT(02)    TYPE  N,
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

* 2007/10/02 simcho by 박혁세K
* 사후 적하부보 조회 대표구매오더로 가능하도록

  CLEAR: GT_DYNPFIELDS, GT_DYNPFIELDS[].

  GT_DYNPFIELDS-FIELDNAME = 'S_BUKRS-LOW'.   "회사코드

  APPEND GT_DYNPFIELDS.

*

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

***********************************************************************
* 2007/10/02 simcho by 박혁세K
***********************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_EBELN-LOW.

  PERFORM F4_EBELN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_EBELN-HIGH.

  PERFORM F4_EBELN.
*
***********************************************************************


AT SELECTION-SCREEN.
  PERFORM INPUT_FIELD_CHECK.
  PERFORM ALV_VARIANT_CHECK.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
*  PERFORM p1102_authorization_check USING s_bukrs-low.
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

  SET TITLEBAR 'T1000' WITH '상태별 적하부보'.

** 진로산업 Change 2007/04 --------------------------------------
*  FREE: s_bukrs.    CLEAR: s_bukrs.
*  s_bukrs-sign   = 'I'.
*  s_bukrs-option = 'EQ'.
*  s_bukrs-low    = c_bukrs.
*  APPEND s_bukrs.
** 진로산업 Change 2007/04 --------------------------------------

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
  SELECT BUKRS INTO (L_BUKRS)
               FROM T001 UP TO 1 ROWS WHERE BUKRS IN S_BUKRS.
  ENDSELECT.
  IF SY-SUBRC <> 0.
    PERFORM GET_FTEXT(RDDFIE00) USING 'T001' 'BUKRS' SY-LANGU
                                CHANGING DFIES G_SUBRC.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
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

  DATA:  L_COUNT     TYPE  I,
         LT_ZTITBLP  LIKE ZTITBLP OCCURS 0 WITH HEADER LINE.
  RANGES: LR_DOCST   FOR   ZTITRQS-DOCST OCCURS 1.
  CLEAR : LT_ZTITBLP, LT_ZTITBLP[].

  DATA : BEGIN OF LS_KEY,
         IBLNO LIKE ZTITBLP-IBLNO,
         EBELN LIKE ZTITBLP-EBELN,
         END OF LS_KEY.

  FIELD-SYMBOLS: <LS_TABLE>.
  FIELD-SYMBOLS: <L_FIELD1>.
  FIELD-SYMBOLS: <L_FIELD2>.

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
*  : 의뢰대상 >>
*C : 수입의뢰
*A : 접수완료
*W : 신청서작성
*Y : 개설신청 >>
*N : 개설취소
*O : 개설완료 >>
*R : 접수반려
*----------------------------------------------------------------------
  CASE 'X'.
    WHEN P_STEP1. ">의뢰대상
      MOVE: SPACE TO  LR_DOCST-LOW.    APPEND LR_DOCST .
*      MOVE: 'R'   TO  lr_docst-low.    APPEND lr_docst .
*    WHEN p_step2. ">접수대상
*      MOVE: 'C'   TO  lr_docst-low.    APPEND lr_docst .
    WHEN P_STEP2. ">신청대상
      MOVE: 'C'   TO  LR_DOCST-LOW.    APPEND LR_DOCST .
      MOVE: 'A'   TO  LR_DOCST-LOW.    APPEND LR_DOCST .
      MOVE: 'W'   TO  LR_DOCST-LOW.    APPEND LR_DOCST .
      MOVE: 'N'   TO  LR_DOCST-LOW.    APPEND LR_DOCST .
    WHEN P_STEP3. ">개설의뢰 진행 중
      MOVE: 'Y'   TO  LR_DOCST-LOW.    APPEND LR_DOCST .
    WHEN P_STEP4. ">개설완료
      MOVE: 'O'   TO  LR_DOCST-LOW.    APPEND LR_DOCST .
    WHEN P_STEP5. ">전체.
      REFRESH LR_DOCST .
  ENDCASE.

*> 수입의뢰 데이타 select.
*  SELECT *
*    INTO CORRESPONDING FIELDS OF TABLE <gt_table>
*    FROM ztivip01
*   WHERE bukrs  IN s_bukrs  "회사코드.
*     AND iipno  IN s_iipno  "적하부보 관리번호.
*     AND reqno  IN s_reqno  "수입의뢰 관리번호.
*     AND amdsq  IN s_amdsq  "Amend 차수
*     AND reqty  IN s_reqty  "수입의뢰 종류.
*     AND ilcty  IN s_ilcty  "신용장 종류.
*     AND lifnr  IN s_lifnr  "공급업체 계정번호.
*     AND inscp  IN s_inscp  "보험회사.
*     AND iopno  IN s_iopno  "포괄증권번호.
*     AND iisdt  IN s_iisdt  "증권발급일.
*     AND ispno  IN s_ispno  "증권번호.
*     AND lifre  IN s_lifre  "다른 송장발행처.
*     AND offer  IN s_offer  "오퍼상(Offer).
*     AND opnbk  IN s_opnbk  "개설은행.
*     AND ekorg  IN s_ekorg  "구매조직.
*     AND ekgrp  IN s_ekgrp  "구매그룹.
*     AND opnno  IN s_opnno  "수입개설번호
*     AND opndt  IN s_opndt  "개설일자.
*     AND zterm  IN s_zterm  "지급조건키.
*     AND waers  IN s_waers  "개설통화.
*     AND inco1  IN s_inco1  "인도조건 (파트 1).
*     AND exdat  IN s_exdat  "유효기일.
*     AND lsdat  IN s_lsdat  "최종선적일자.
*     AND fwdty  IN s_fwdty  "운송 방법.
*     AND fland  IN s_fland  "선적국가.
*     AND fport  IN s_fport  "선적항.
*     AND tland  IN s_tland  "도착국가.
*     AND tport  IN s_tport  "도착항.
**      and docst  in s_DOCST  "문서상태.
*     AND sndst  IN s_sndst  "EDI상태.
*     AND cnam   IN s_cnam   "작성인.
*     AND cdat   IN s_cdat   "생성일.
*     AND unam   IN s_unam   "최종변경인.
*     AND udat   IN s_udat  "변경일.
*     AND docst  IN  lr_docst.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE <GT_TABLE>
    FROM ZTITIP1
   WHERE BUKRS  IN S_BUKRS  "회사코드.
     AND IIPNO  IN S_IIPNO  "적하부보 관리번호.
     AND REQNO  = ''        "IN s_reqno  "수입의뢰 관리번호.
     AND EBELN  IN S_EBELN
     AND IBLNO  IN S_IBLNO  "B/L 관리번호 - 기능개선 294020
     AND INSCP  IN S_INSCP  "보험회사.
     AND IOPNO  IN S_IOPNO  "포괄증권번호.
     AND IISDT  IN S_IISDT  "증권발급일.
     AND ISPNO  IN S_ISPNO  "증권번호.
     AND EKORG  IN S_EKORG  "구매조직.
     AND EKGRP  IN S_EKGRP  "구매그룹.
     AND SNDST  IN S_SNDST  "EDI상태.
     AND CNAM   IN S_CNAM   "작성인.
     AND CDAT   IN S_CDAT   "생성일.
     AND UNAM   IN S_UNAM   "최종변경인.
     AND UDAT   IN S_UDAT  "변경일.
     AND DOCST  IN  LR_DOCST.


  IF <GT_TABLE> IS INITIAL.
    MESSAGE S902.
  ENDIF.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <GT_TABLE> TO <LS_TABLE>.
*  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <L_FIELD3>.
  FIELD-SYMBOLS: <L_FIELD4>.
  FIELD-SYMBOLS: <L_FIELD5>.
  DATA: L_DDTEXT LIKE DD07T-DDTEXT,
        L_TXZ01  LIKE EKPO-TXZ01.
  LOOP AT <GT_TABLE> INTO <LS_TABLE>.
    G_TABIX = SY-TABIX.
    ASSIGN COMPONENT 'DOCST' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD1>.

    ASSIGN COMPONENT 'DDTEXT' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD2>.

    ASSIGN COMPONENT 'EBELN' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD3>.

    ASSIGN COMPONENT 'TXZ01' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD4>.

    ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD5>.

**> 기존 부보내역 확인.
*    CLEAR:  L_COUNT.
*    SELECT COUNT( * )
*      INTO L_COUNT
*      FROM ZTITIP01
*     WHERE REQNO EQ <l_field5>.
*    IF L_COUNT GT 0.
*      DELETE <GT_TABLE> INDEX G_TABIX.
*      CONTINUE.
*    ENDIF.

****************************************************
* CSR No. : C20100217_12468
****************************************************
*    SELECT ebeln
*      INTO <l_field3>
*      FROM ztitrqp UP TO 1 ROWS
*     WHERE reqno EQ <l_field5>.
*    ENDSELECT.
*
    IF NOT <L_FIELD3> IS INITIAL.
      SELECT TXZ01
        INTO <L_FIELD4>
        FROM EKPO UP TO 1 ROWS
       WHERE EBELN EQ <L_FIELD3>.
      ENDSELECT.
    ENDIF.
****************************************************

    PERFORM  GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING 'ZTIDOCST'
                                                   <L_FIELD1>
                                                   <L_FIELD2>.
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

  AC 'ITAB   IIPNO ZTIVIP01                     IIPNO '.
  AC 'ITAB   AMDSQ ZTIVIP01                     AMDSQ '.
  AC 'ITAB   REQTY ZTIVIP01                     REQTY '.
*문서상태
  AC 'ITAB   DOCST ZTIVIP01                     DOCST '.
  AC 'ITAB   DDTEXTDD07T                        DDTEXT'.
*L/C NO       ZTITRQS-OPNNO
  AC 'ITAB   OPNNO ZTIVIP01                     OPNNO '.
  AC 'ITAB   REQNO ZTIVIP01                     REQNO '.
*B/L NO - 기능개선 294020
  AC 'ITAB   IBLNO ZTITIP1                      IBLNO '.
*공사번호     ZTITRQK-PSPNR
  AC 'ITAB   PSPNR ZTIVIP01                     PSPNR '.
*OPEN금액통화 ZTITRQS-WAERS
  AC 'ITAB   WAERS ZTITRQS                      WAERS '.
*OPEN금액     ZTITRQS-OPAMT
  AC 'ITAB   OPAMT ZTITRQS                      OPAMT  CWAERS '.
*보험회사
  AC 'ITAB   INSCP ZTIVIP01                     INSCP '.
*보험료(원화)  ZTITIP01-ITPA1(수신시) ZTITIP01-ITPA1C
  AC 'ITAB   ITPA1CZTIVIP01                     ITPA1C'.
  AC 'ITAB   ITPA1 ZTIVIP01                     ITPA1  CITPA1C'.
*보험정보
  AC 'ITAB   IOPNO ZTIVIP01                     IOPNO '.
  AC 'ITAB   IISDT ZTIVIP01                     IISDT '.
  AC 'ITAB   ISPNO ZTIVIP01                     ISPNO '.
*보험사제출일  TAPDT 신청일
  AC 'ITAB   TAPDT ZTIVIP01                     TAPDT '.
*부보일자 ZTITIP01-IOPDT"보험개시일
  AC 'ITAB   IOPDT ZTIVIP01                     IOPDT '.
*보험료(USD)
*보험요율      ZTITIP01-IWART "희망이익률
  AC 'ITAB   IWART ZTIVIP01                     IWART '.
*부보조건
*전표번호
*품명         ZTISRQIT-TXZ01
  AC 'ITAB   TXZ01 ZTISRQIT                     TXZ01 '.
*LC OPEN일자  ZTITRQS-OPNDT
  AC 'ITAB   OPNDT ZTITRQS                      OPNDT '.
*선적지       ZTITRQS-PLLOD
  AC 'ITAB   PLLOD ZTITRQS                      PLLOD '.
*도착지       ZTITRQS-PLTRN
  AC 'ITAB   PLTRN ZTITRQS                      PLTRN '.
*대표PO       ZTISRQIT-EBELN
  AC 'ITAB   EBELN ZTISRQIT                     EBELN '.

*> Create field catagory table
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = 'ZTIVIP01'
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
      WHEN 'IIPNO' OR 'AMDSQ'.
        FCS-HOTSPOT = 'X'.
        FCS-KEY     = 'X'.
      WHEN 'OPAMT' OR 'ITPA1'.
        FCS-DO_SUM = 'X'.
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
    WHEN P_STEP1. ">의뢰대상
      SET TITLEBAR 'T1000' WITH '적하부보 의뢰대상'.
    WHEN P_STEP2. ">접수대상
      SET TITLEBAR 'T1000' WITH '적하부보 신청대상'.
    WHEN P_STEP3. ">신청대상
      SET TITLEBAR 'T1000' WITH '적하부보 신청 진행 중'.
    WHEN P_STEP4. ">개설의뢰 진행 중
      SET TITLEBAR 'T1000' WITH '적하부보 완료대상'.
    WHEN P_STEP5. ">개설완료
      SET TITLEBAR 'T1000' WITH '전체'.
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
*     I_STRUCTURE_NAME               =
*     IT_EXCLUDING                   =
*     IT_SPECIAL_GROUPS              =
*     IT_FILTER                      =
*     IS_SEL_HIDE                    =
*     I_DEFAULT                      = 'X'
*     I_SAVE                         = ' '
*     IS_VARIANT                     =
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
  APPEND '&VEXCEL'   TO EXTAB.
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
      APPEND 'ZTIT002'  TO EXTAB.
      APPEND 'ZTIT005'  TO EXTAB.
    WHEN P_STEP2. ">신청대상
*      APPEND 'ZTIT002'  TO extab.
*      APPEND 'ZTIT005'  TO extab.
    WHEN P_STEP3. ">개설의뢰 진행 중
      APPEND 'ZTIT002'  TO EXTAB.
      APPEND 'ZTIT005'  TO EXTAB.
    WHEN P_STEP4. ">완료
      APPEND 'ZTIT002'  TO EXTAB.
      APPEND 'ZTIT005'  TO EXTAB.
    WHEN P_STEP5. ">전체.
      APPEND 'ZTIT002'  TO EXTAB.
      APPEND 'ZTIT005'  TO EXTAB.
  ENDCASE.

  SET PF-STATUS 'STANDARD' EXCLUDING EXTAB.

ENDFORM.                    " SET_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  USER_ALV_COMMAND
*&---------------------------------------------------------------------*
FORM USER_ALV_COMMAND USING   R_UCOMM      LIKE SY-UCOMM
                              RS_SELFIELD  TYPE SLIS_SELFIELD.
*
  DATA: L_COUNT   TYPE I.
  DATA: L_INDEX   TYPE I.
  DATA: L_SUBRC   LIKE SY-SUBRC.
  DATA: L_TCODE   LIKE SY-TCODE.
  FIELD-SYMBOLS: <LS_TABLE>.
  FIELD-SYMBOLS: <L_FIELD>.
  FIELD-SYMBOLS: <L_FIELD1>.
  FIELD-SYMBOLS: <L_FIELD2>.
  FIELD-SYMBOLS: <L_FIELD3>.

*___보험증서 출력 추가_Start 2007.06.14
  DATA: LV_IIPNO    LIKE ZTITIP1-IIPNO,
        LV_AMDSQ    LIKE ZTITIP1-AMDSQ,
        LV_ITES1    LIKE ZTITIP2-ITES1,
        LV_DOMVALUE LIKE DD07V-DOMVALUE_L,
        LV_DDTEXT   LIKE DD07V-DDTEXT,
        LV_IIVAT(20),
        LV_IIVAK(20),
        LV_WKURS    TYPE P DECIMALS 5. "TYPE WKURS.
*___보험증서 출력 추가_End   2007.06.14

  DATA: LV_EBELN    LIKE ZTITBLP-EBELN,           "SRM2206-03696 - 추가
        LV_EBELP    LIKE ZTITBLP-EBELP.           "SRM2206-03696 - 추가

  ASSIGN LOCAL COPY OF INITIAL LINE OF <GT_TABLE> TO <LS_TABLE>.

  CASE R_UCOMM.
*___보험증서 출력 추가_Start 2007.06.14
    WHEN 'PRNT'.
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
        PERFORM SSF_OPEN.                         "SRM2206-03696 - 추가

        LOOP AT <GT_TABLE> INTO <LS_TABLE>.
          CHECK <L_FIELD> EQ 'X'.

          CLEAR   : GT_ZTISINS, LV_IIPNO, LV_AMDSQ.
          REFRESH : GT_ZTISINS.

          ASSIGN COMPONENT 'IIPNO' OF STRUCTURE
                                 <LS_TABLE> TO <L_FIELD1>.
          LV_IIPNO = <L_FIELD1>.
          ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                                 <LS_TABLE> TO <L_FIELD2>.
          LV_AMDSQ = <L_FIELD2>.

          SELECT SINGLE *
            FROM ZTITIP1
           WHERE IIPNO = LV_IIPNO
             AND AMDSQ = LV_AMDSQ.

          CHECK SY-SUBRC = 0.

*{ SRM2206-03696 - 추가_S
          PERFORM SET_INS_LOGO_N_ADRR IN PROGRAM ZTIR1010 IF FOUND
                                      USING ZTITIP1-RECID
                                            GS_ZTISINSH.
*} SRM2206-03696 - 추가_E

          GT_ZTISINS-BUKRS = ZTITIP1-BUKRS.       "회사코드

          SELECT SINGLE NOMNM
            INTO GT_ZTISINS-BUTXT                 "회사명
            FROM ZTSTIG0
           WHERE BUKRS = GT_ZTISINS-BUKRS.

          GT_ZTISINS-IOPNO = ZTITIP1-IOPNO.       "Open Policy No
*___문서번호
*          CONCATENATE 'LGEI' ZTITIP1-IIPNO INTO GT_ZTISINS-RECNO.
          GT_ZTISINS-RECNO = ZTITIP1-IIPNO.

          IF ZTITIP1-AMDSQ <> '00'.
            CONCATENATE GT_ZTISINS-RECNO '-' ZTITIP1-AMDSQ
                   INTO GT_ZTISINS-RECNO.
          ENDIF.

          CONDENSE GT_ZTISINS-RECNO NO-GAPS.

          GT_ZTISINS-ISPNO = ZTITIP1-ISPNO.       "보험증권번호
          GT_ZTISINS-IISDT = ZTITIP1-IISDT.       "보험증권발급일

*{ SRM2206-03696 - 추가_S
*___B/L 번호
          IF ZTITIP1-IBLNO IS NOT INITIAL.
            SELECT SINGLE BLNUM
              INTO GT_ZTISINS-OPNNO
              FROM ZTITBLK
             WHERE IBLNO = ZTITIP1-IBLNO.
          ELSE.
            CLEAR : LV_EBELN, LV_EBELP.

            IF ZTITIP1-REQNO IS NOT INITIAL.
              SELECT SINGLE EBELN
                            EBELP
                INTO (LV_EBELN, LV_EBELP)
                FROM ZTIVRQ00
               WHERE REQNO = ZTITIP1-REQNO.
            ELSEIF ZTITIP1-EBELN IS NOT INITIAL.
              SELECT SINGLE EBELN
                            EBELP
                INTO (LV_EBELN, LV_EBELP)
                FROM EKPO
               WHERE EBELN = ZTITIP1-EBELN.
            ENDIF.

            IF LV_EBELN IS NOT INITIAL.
              SELECT SINGLE BLNUM
                INTO GT_ZTISINS-OPNNO
                FROM ZTITBLK AS A
               INNER JOIN ZTITBLP AS B
                  ON A~IBLNO = B~IBLNO
               WHERE B~EBELN = LV_EBELN
                 AND B~EBELP = LV_EBELP.
            ENDIF.
          ENDIF.

          IF GT_ZTISINS-OPNNO IS INITIAL.
*} SRM2206-03696 - 추가_E
*___수입개설번호
            ASSIGN COMPONENT 'OPNNO' OF STRUCTURE
                                   <LS_TABLE> TO <L_FIELD1>.

            GT_ZTISINS-OPNNO = <L_FIELD1>.
          ENDIF.

          GT_ZTISINS-ISHNM  = ZTITIP1-ISHNM.      "선적항
          GT_ZTISINS-ILDNM  = ZTITIP1-ILDNM.      "도착항
          GT_ZTISINS-IVSLN  = ZTITIP1-IVSLN.      "선기명
          GT_ZTISINS-IGOTE1 = ZTITIP1-IGOTE1.               "상품명세1
          GT_ZTISINS-IGOTE2 = ZTITIP1-IGOTE2.               "상품명세2
          GT_ZTISINS-IGOTE3 = ZTITIP1-IGOTE3.               "상품명세3
          GT_ZTISINS-IGOTE4 = ZTITIP1-IGOTE4.               "상품명세4
          GT_ZTISINS-IGOTE5 = ZTITIP1-IGOTE5.               "상품명세5
*___기본부보조건
          SELECT SINGLE ITES1
            INTO GT_ZTISINS-ITES1
            FROM ZTITIP2
           WHERE IIPNO = LV_IIPNO
             AND AMDSQ = LV_AMDSQ
             AND ITETY = 'B'.
*___부가부보조건
          SELECT DISTINCT ITES1
            INTO LV_ITES1
            FROM ZTITIP2
           WHERE IIPNO = LV_IIPNO
             AND AMDSQ = LV_AMDSQ
             AND ITETY = 'A'.

            CASE SY-DBCNT.
              WHEN 1.
                GT_ZTISINS-ITES2 = LV_ITES1.
              WHEN 2.
                GT_ZTISINS-ITES3 = LV_ITES1.
              WHEN 3.
                GT_ZTISINS-ITES4 = LV_ITES1.
              WHEN 4.
                GT_ZTISINS-ITES5 = LV_ITES1.
              WHEN 5.
                GT_ZTISINS-ITES6 = LV_ITES1.
              WHEN 6.
                GT_ZTISINS-ITES7 = LV_ITES1.
              WHEN 7.
                GT_ZTISINS-ITES8 = LV_ITES1.
            ENDCASE.

          ENDSELECT.
*___송장금액(외화)
          WRITE : ZTITIP1-IIVAT TO GT_ZTISINS-IIVAT
                                CURRENCY ZTITIP1-IIVATC
                                RIGHT-JUSTIFIED
                                NO-SIGN.
          CONCATENATE GT_ZTISINS-IIVAT '.-' INTO GT_ZTISINS-IIVAT.
          PERFORM REPLACE_SPACE_TO_STAR USING GT_ZTISINS-IIVAT.
          GT_ZTISINS-IIVATC = ZTITIP1-IIVATC.
*___송장금액(원화)
*          GT_ZTISINS-HWAER = ZTITIP1-HWAER.
          GT_ZTISINS-HWAER = 'KRW'.
          WRITE : ZTITIP1-IIVAK TO GT_ZTISINS-IIVAK
                                CURRENCY GT_ZTISINS-HWAER
                                RIGHT-JUSTIFIED
                                NO-SIGN.
          PERFORM REPLACE_SPACE_TO_STAR USING GT_ZTISINS-IIVAK.
*___희망이익율
          WRITE : ZTITIP1-IWART TO GT_ZTISINS-IWART NO-SIGN.
          PERFORM REPLACE_SPACE_TO_STAR USING GT_ZTISINS-IWART.
*___환율 = 원화 / ( 외화 * ( 희망이익율 / 100 ) ).
          WRITE : ZTITIP1-IIVAT TO LV_IIVAT CURRENCY ZTITIP1-IIVATC
                                            NO-GROUPING,
                  ZTITIP1-IIVAK TO LV_IIVAK CURRENCY ZTITIP1-HWAER
                                            NO-GROUPING.
          IF ZTITIP1-IIVAT <> 0 AND ZTITIP1-IWART <> 0.
           LV_WKURS = LV_IIVAK / ( LV_IIVAT * ( ZTITIP1-IWART / 100 ) ).
            WRITE LV_WKURS TO GT_ZTISINS-WKURS RIGHT-JUSTIFIED NO-SIGN.
            PERFORM REPLACE_SPACE_TO_STAR USING GT_ZTISINS-WKURS.
          ENDIF.

          GT_ZTISINS-IAJRT = ZTITIP1-IAJRT.        "적용환율
          GT_ZTISINS-ICPRT = ZTITIP1-ICPRT.        "Cargo Rate
          GT_ZTISINS-ICPAM = ZTITIP1-ICPAM.        "Cargo Premium
          GT_ZTISINS-IDPRT = ZTITIP1-IDPRT.        "Duty Rate
          GT_ZTISINS-IDPAM = ZTITIP1-IDPAM.        "Duty Premium
          GT_ZTISINS-IVPRT = ZTITIP1-IVPRT.        "V/P Rate
          GT_ZTISINS-IVPAM = ZTITIP1-IVPAM.        "V/P Premium
          GT_ZTISINS-ITPRT = ZTITIP1-ITPRT.        "Total Rate
          GT_ZTISINS-ITPA1 = ZTITIP1-ITPA1.        "Total Premium
*___공동인수사
          CLEAR : LV_DOMVALUE, LV_DDTEXT.

          LV_DOMVALUE = ZTITIP1-ITOCP.

          CALL FUNCTION 'DOMAIN_VALUE_GET'
            EXPORTING
              I_DOMNAME  = 'ZTIITOCP'
              I_DOMVALUE = LV_DOMVALUE
            IMPORTING
              E_DDTEXT   = LV_DDTEXT
            EXCEPTIONS
              NOT_EXIST  = 1
              OTHERS     = 2.

          GT_ZTISINS-ITOCP = LV_DDTEXT.

          GT_ZTISINS-ITORT = ZTITIP1-ITORT.        "공동인수율

          APPEND GT_ZTISINS.

          PERFORM CALL_SMARTFORMS.                "SRM2206-03696 - 추가
        ENDLOOP.

        PERFORM SSF_CLOSE.                        "SRM2206-03696 - 추가

*        IF NOT GT_ZTISINS[] IS INITIAL.
*          PERFORM PRINT_INSURANCE_POLICY.        "SRM2206-03696 - 삭제
*        ENDIF.
      ENDIF.
*___보험증서 출력 추가_End   2007.06.14

    WHEN 'ZTIT005'.
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
        PERFORM SET_INITAIL_IP_BATCHDATA.

        REFRESH: BDCDATA, IT_MSG.
        CLEAR: SESSION.
        CTU_PARAMS-DISMODE  = 'A'. ">처리모드
        CTU_PARAMS-UPDMODE  = 'S'. ">갱신모드
        CTU_PARAMS-CATTMODE = ' '. ">CATT 모드...
        CTU_PARAMS-DEFSIZE  = ' '. ">기본화면 크기
        CTU_PARAMS-RACOMMIT = 'X'.
        CTU_PARAMS-NOBINPT  = ' ' .
        CTU_PARAMS-NOBIEND  = ' '.
*
        LOOP AT <GT_TABLE> INTO   <LS_TABLE>.
          IF <L_FIELD> EQ 'X'.
*> 초기화면.
            ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                                  <LS_TABLE> TO <L_FIELD1>.
*            ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
*                                  <ls_table> TO <l_field2>.

            PERFORM BDC_DYNPRO_BUILD USING :
                   'X' 'ZTIR1000'          '0100',
                   ' ' 'ZTISSCRCOM-REQNO'  <L_FIELD1>,
                   ' ' 'BDC_OKCODE'       '=ZTIENTER'.
*> 세부화면.
            PERFORM BDC_DYNPRO_BUILD USING :
                   'X' 'ZTIR1000'         '2000'.

            PERFORM BDC_DYNPRO_BUILD USING :
                   ' ' 'BDC_OKCODE'       '=ZTIREQUEST'.

            PERFORM BDC_DYNPRO_BUILD USING :
                   'X' 'SAPLSPO1'         '0300',
                   ' ' 'BDC_OKCODE'       '=YES'.

            PERFORM BDC_TRANSACTION USING 'ZTIT101' L_SUBRC.

            IF L_SUBRC EQ 0.
              MESSAGE S121 WITH <L_FIELD1>.
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

    WHEN 'ZTIT002'.
      ASSIGN COMPONENT 'BOX' OF STRUCTURE
                               <LS_TABLE> TO <L_FIELD>.
      CLEAR: L_COUNT.
      LOOP AT <GT_TABLE> INTO   <LS_TABLE>.
        IF <L_FIELD> EQ 'X'.
          ADD 1 TO L_COUNT.
          L_INDEX = SY-TABIX.
        ENDIF.
      ENDLOOP.
      IF L_COUNT NE 1.
        MESSAGE S903.
      ELSE.
        READ TABLE <GT_TABLE> INTO   <LS_TABLE>
                              INDEX L_INDEX.

        ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                              <LS_TABLE> TO <L_FIELD1>.
*        ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
*                              <ls_table> TO <l_field2>.
        SET PARAMETER ID 'ZTIREQNO' FIELD <L_FIELD1>.
*          SET PARAMETER ID 'ZTIAMDSQ' FIELD <l_field2>.
        CALL TRANSACTION 'ZTIT101' AND SKIP FIRST SCREEN .
        PERFORM GET_DATA_FOR_DISPLAY.    ">data select
        RS_SELFIELD-REFRESH = 'X'.
      ENDIF.

    WHEN 'DISPLAY' OR '&IC1'.    " AUF DOPPELKLICK REAGIERIEN
      CHECK RS_SELFIELD-TABINDEX GT 0.

      READ TABLE <GT_TABLE> INTO <LS_TABLE> INDEX RS_SELFIELD-TABINDEX.
      IF SY-SUBRC NE 0.
        MESSAGE S906.            EXIT.
      ENDIF.

      ASSIGN COMPONENT 'IIPNO' OF STRUCTURE
                            <LS_TABLE> TO <L_FIELD1>.

      ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                            <LS_TABLE> TO <L_FIELD2>.

      ASSIGN COMPONENT 'DOCST' OF STRUCTURE
                            <LS_TABLE> TO <L_FIELD3>.

      CASE RS_SELFIELD-FIELDNAME.
        WHEN 'IIPNO'.
          SET PARAMETER ID 'ZTIIIPNO' FIELD <L_FIELD1>.
          SET PARAMETER ID 'ZTIAMSEQ' FIELD <L_FIELD2>.
          CALL TRANSACTION 'ZTIT103' AND SKIP FIRST SCREEN.
        WHEN 'OPNNO' OR 'REQNO'.
          ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                            <LS_TABLE> TO <L_FIELD1>.
          SELECT SINGLE *
            FROM ZTITRQK
           WHERE REQNO  EQ  <L_FIELD1>.
          IF SY-SUBRC EQ 0.
            PERFORM EXCUTE_IMPORT_DOCUMENT(ZTIR0000)
                                 USING <L_FIELD1> ZTITRQK-LSTAS
                                       'ZTIT003'.
          ENDIF.
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
          CASE <L_FIELD3>.
            WHEN ' '.    ">의뢰대상
              L_TCODE = 'ZTIT102'.
            WHEN 'Y'.    ">개설의뢰 진행 중
              L_TCODE = 'ZTIT105'.
            WHEN OTHERS.
              L_TCODE = 'ZTIT103'.
          ENDCASE.
          SET PARAMETER ID 'ZTIIIPNO' FIELD <L_FIELD1>.
          SET PARAMETER ID 'ZTIAMSEQ' FIELD <L_FIELD2>.
          CALL TRANSACTION L_TCODE AND SKIP FIRST SCREEN.
          IF L_TCODE NE 'ZTIT103'.
            PERFORM EXCUTE_IMPORT_DOCUMENT(ZTIR0000)
                                 USING <L_FIELD1> <L_FIELD2> L_TCODE.
            PERFORM GET_DATA_FOR_DISPLAY.    ">data select
            RS_SELFIELD-REFRESH = 'X'.
          ENDIF.
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
    WHEN P_STEP1.
      HEADER-INFO = '적하부보 요청대상 현황'.
    WHEN P_STEP2.
      HEADER-INFO = '적하부보 신청대상 현황'.
    WHEN P_STEP3.
      HEADER-INFO = '부보의뢰 진행 중 현황'.
    WHEN P_STEP4.
      HEADER-INFO = '부보완료 현황'.
    WHEN P_STEP5.
      HEADER-INFO = '전체 현황'.
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
              'ZTIVIP01'                  TO FCS-REF_TABNAME.
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
*&      Form  SET_INITAIL_IP_BATCHDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_INITAIL_IP_BATCHDATA .

ENDFORM.                    " SET_INITAIL_IP_BATCHDATA
*&---------------------------------------------------------------------*
*&      Form  PRINT_INSURANCE_POLICY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_INSURANCE_POLICY .

  DATA: LV_FM_NAME      TYPE RS38L_FNAM.

  CLEAR : GS_CONTROL_PAR, GS_OUTPUT_OPT.

*& 스마트폼 제어 매개변수 설정...
  GS_CONTROL_PAR-NO_DIALOG = ' '.     "출력화면 표시여부
*& 출력 매개변수 설정...
  GS_OUTPUT_OPT-TDDEST     = 'ZP01'.  "출력장치
  GS_OUTPUT_OPT-TDIMMED    = 'X'.     "Print immdiately.
  GS_OUTPUT_OPT-TDNEWID    = 'X'.     "New spool request.
  GS_OUTPUT_OPT-TDDELETE   = 'X'.     "Delete after printing.
  GS_OUTPUT_OPT-TDNOPREV   = ' '.     "No print preview
  GS_OUTPUT_OPT-TDNOPRINT  = ' '.     "
  GS_OUTPUT_OPT-TDFINAL    = ' '.     "스풀 요청을 완료

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
       EXPORTING
            FORMNAME           = 'Z_TI_MM_INSURANCE_POLICY'
*           VARIANT = ' '
*           DIRECT_CALL = ' '
       IMPORTING
            FM_NAME            = LV_FM_NAME
       EXCEPTIONS
            NO_FORM            = 1
            NO_FUNCTION_MODULE = 2
            OTHERS             = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID
          TYPE 'S'     "sy-msgty
        NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CALL FUNCTION LV_FM_NAME
         EXPORTING
*           ARCHIVE_INDEX        =
*           ARCHIVE_INDEX_TAB    =
*           ARCHIVE_PARAMETERS   =
              CONTROL_PARAMETERS = GS_CONTROL_PAR
*           MAIL_APPL_OBJ =
*           MAIL_RECIPIENT =
*           MAIL_SENDER =
              OUTPUT_OPTIONS     = GS_OUTPUT_OPT
              USER_SETTINGS      = ' '
              IS_ZTISINSH        = GS_ZTISINSH    "SRM2206-03696 - 추가
*      IMPORTING
*           DOCUMENT_OUTPUT_INFO =
*           JOB_OUTPUT_INFO      =
*           JOB_OUTPUT_OPTIONS   =
         TABLES
              GT_ZTISINS         = GT_ZTISINS
         EXCEPTIONS
              FORMATTING_ERROR   = 1
              INTERNAL_ERROR     = 2
              SEND_ERROR         = 3
              USER_CANCELED      = 4
              OTHERS             = 5.
  ENDIF.

ENDFORM.                    " PRINT_INSURANCE_POLICY
*&---------------------------------------------------------------------*
*&      Form  REPLACE_SPACE_TO_STAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM REPLACE_SPACE_TO_STAR  USING  P_FIELD.

  DO.
    REPLACE ' ' WITH '*' INTO P_FIELD.
    IF SY-SUBRC <> 0.
      EXIT.
    ENDIF.
  ENDDO.

ENDFORM.                    " REPLACE_SPACE_TO_STAR
*&---------------------------------------------------------------------*
*&      Form  f4_ebeln
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F4_EBELN.

  CLEAR: GT_VALUES, GT_VALUES[].

* 현재 화면에 들어와 있는 회사코드를 읽어들임
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = 'ZTIR1040'
      DYNUMB     = '1000'
    TABLES
      DYNPFIELDS = GT_DYNPFIELDS.

  READ TABLE GT_DYNPFIELDS WITH KEY FIELDNAME = 'S_BUKRS-LOW'.
  S_BUKRS-LOW = GT_DYNPFIELDS-FIELDVALUE.

  CLEAR ZTITIP1.

  SELECT EBELN
    INTO TABLE GT_VALUES
    FROM ZTITIP1
   WHERE REQNO = ''
     AND BUKRS IN S_BUKRS.

  IF SY-SUBRC = 0.

    SORT GT_VALUES BY EBELN.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD     = 'EBELN'
        DYNPPROG     = SY-CPROG
        DYNPNR       = SY-DYNNR
        DYNPROFIELD  = 'S_EBELN'
        WINDOW_TITLE = '구매오더'
        VALUE_ORG    = 'S'
      TABLES
        VALUE_TAB    = GT_VALUES.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID
            TYPE SY-MSGTY
          NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ELSE.

    MESSAGE I999 WITH
        '사후 적하부보에 해당하는 대표 구매오더가 없습니다.'.

  ENDIF.

ENDFORM.                                                    " f4_ebeln
*&---------------------------------------------------------------------*
*&      Form  SSF_OPEN
*&---------------------------------------------------------------------*
*       SRM2206-03696 - 추가
*----------------------------------------------------------------------*
FORM SSF_OPEN .

  CLEAR : GS_CONTROL_PAR, GS_OUTPUT_OPT, GV_FM_NAME.

*& 스마트폼 제어 매개변수 설정...
  GS_CONTROL_PAR-NO_DIALOG = ' '.     "출력화면 표시여부
*& 출력 매개변수 설정...
  GS_OUTPUT_OPT-TDDEST     = 'ZP01'.  "출력장치
  GS_OUTPUT_OPT-TDIMMED    = 'X'.     "Print immdiately.
  GS_OUTPUT_OPT-TDNEWID    = 'X'.     "New spool request.
  GS_OUTPUT_OPT-TDDELETE   = 'X'.     "Delete after printing.
  GS_OUTPUT_OPT-TDNOPREV   = ' '.     "No print preview
  GS_OUTPUT_OPT-TDNOPRINT  = ' '.     "
  GS_OUTPUT_OPT-TDFINAL    = ' '.     "스풀 요청을 완료

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
       EXPORTING
            FORMNAME           = 'Z_TI_MM_INSURANCE_POLICY'
*           VARIANT = ' '
*           DIRECT_CALL = ' '
       IMPORTING
            FM_NAME            = GV_FM_NAME
       EXCEPTIONS
            NO_FORM            = 1
            NO_FUNCTION_MODULE = 2
            OTHERS             = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    EXIT.
  ENDIF.

  CALL FUNCTION 'SSF_OPEN'
    EXPORTING
      USER_SETTINGS            = ' '
      OUTPUT_OPTIONS           = GS_OUTPUT_OPT
      CONTROL_PARAMETERS       = GS_CONTROL_PAR
*    IMPORTING
*      JOB_OUTPUT_OPTIONS       = SSFCRESOP
    EXCEPTIONS
      FORMATTING_ERROR         = 1
      INTERNAL_ERROR           = 2
      SEND_ERROR               = 3
      USER_CANCELED            = 4
      OTHERS                   = 5.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    EXIT.
  ENDIF.

ENDFORM.                    " SSF_OPEN
*&---------------------------------------------------------------------*
*&      Form  CALL_SMARTFORMS
*&---------------------------------------------------------------------*
*       SRM2206-03696 - 추가
*----------------------------------------------------------------------*
FORM CALL_SMARTFORMS .

  GS_CONTROL_PAR-NO_OPEN   = 'X'.
  GS_CONTROL_PAR-NO_CLOSE  = 'X'.

  CALL FUNCTION GV_FM_NAME
       EXPORTING
*         ARCHIVE_INDEX        =
*         ARCHIVE_INDEX_TAB    =
*         ARCHIVE_PARAMETERS   =
            CONTROL_PARAMETERS = GS_CONTROL_PAR
*         MAIL_APPL_OBJ =
*         MAIL_RECIPIENT =
*         MAIL_SENDER =
            OUTPUT_OPTIONS     = GS_OUTPUT_OPT
            USER_SETTINGS      = ' '
            IS_ZTISINSH        = GS_ZTISINSH
*    IMPORTING
*         DOCUMENT_OUTPUT_INFO =
*         JOB_OUTPUT_INFO      =
*         JOB_OUTPUT_OPTIONS   =
       TABLES
            GT_ZTISINS         = GT_ZTISINS
       EXCEPTIONS
            FORMATTING_ERROR   = 1
            INTERNAL_ERROR     = 2
            SEND_ERROR         = 3
            USER_CANCELED      = 4
            OTHERS             = 5.

ENDFORM.                    " CALL_SMARTFORMS
*&---------------------------------------------------------------------*
*&      Form  SSF_CLOSE
*&---------------------------------------------------------------------*
*       SRM2206-03696 - 추가
*----------------------------------------------------------------------*
FORM SSF_CLOSE .
  DATA: SSFCRESPD          TYPE SSFCRESPD,
        SSFCRESCL          TYPE SSFCRESCL,
        SSFCRESOP          TYPE SSFCRESOP.

  CALL FUNCTION 'SSF_CLOSE'
    IMPORTING
      JOB_OUTPUT_INFO        = SSFCRESCL
    EXCEPTIONS
      FORMATTING_ERROR       = 1
      INTERNAL_ERROR         = 2
      SEND_ERROR             = 3
      OTHERS                 = 4.

  IF SSFCRESCL-OUTPUTDONE = 'X'.
*___출력완료 후 처리

  ENDIF.

ENDFORM.                    " SSF_CLOSE
