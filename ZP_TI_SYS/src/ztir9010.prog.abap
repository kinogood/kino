************************************************************************
*                                                                      *
* Title         : ZTIR9010                                             *
*                                                                      *
* Description   : [Report] 수입 비용 현황 List                         *
*                                                                      *
* Creation Date : 2004/02/07                                           *
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
* Date       Programmer  Transport#         Description                *
*----------------------------------------------------------------------*
* 2012.05.17   MMB04     Q20120315_62763   대표플랜트,사업영역 추가    *
* 2022.07.07   ZLSGMM3  [CHM2207-00033]  세금계산서 매핑 관련 필드 추가*
************************************************************************
PROGRAM   ZTIR9010
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
        ZTIVCS00.  ">수입비용 Views

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 --------------------------------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 --------------------------------------
    C_SAVE(1)   TYPE  C             VALUE 'A'.


************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK BOX1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS:
       S_BUKRS  FOR ZTIVCS00-BUKRS "회사코드
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID BUK
                    MODIF  ID IOG ,
       S_EBELN  FOR EKKO-EBELN,     "구매오더 번호
       S_ICSNO  FOR ZTIVCS00-ICSNO, "수입비용 문서번호
       S_GJAHR  FOR ZTIVCS00-GJAHR, "회계연도
       S_BELNR  FOR ZTIVCS00-BELNR, "회계전표번호
       S_MONAT  FOR ZTIVCS00-MONAT, "회계기간
       S_LIFNR  FOR ZTIVCS00-LIFNR, "구매처 또는 채권자 계정번호
       S_EXPGR  FOR ZTIVCS00-EXPGR, "비용그룹
       S_EXPCD  FOR ZTIVCS00-EXPCD, "수입비용코드
       S_REFNO  FOR ZTIVCS00-REFNO, "관련문서번호
       S_AMDSQ  FOR ZTIVCS00-AMDSQ, "배서차수
       S_MWSKZH FOR ZTIVCS00-MWSKZH, "부가가치세코드
       S_ZTERM  FOR ZTIVCS00-ZTERM, "지급조건키
       S_BUDAT  FOR ZTIVCS00-BUDAT, "전표의 전기일
       S_BLDAT  FOR ZTIVCS00-BLDAT, "전표증빙일
       S_PTDCL  FOR ZTIVCS00-PTDCL, "전기방법
       S_DSTRB  FOR ZTIVCS00-DSTRB, "비용배부방법
       S_CNAMH  FOR ZTIVCS00-CNAMH, "작성인
       S_CDATH  FOR ZTIVCS00-CDATH. "생성일
SELECTION-SCREEN ULINE.
PARAMETERS: P_STEP1 RADIOBUTTON GROUP AB1,
            P_STEP2 RADIOBUTTON GROUP AB1 DEFAULT 'X',
            P_STEP3 RADIOBUTTON GROUP AB1.
SELECTION-SCREEN ULINE.
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

*>- [CHM2207-00033] 세금계산서 매핑내역 추가 -[s]
  IF FCS-REF_FIELDNAME = 'INV_SE'.
    FCS-REF_FIELDNAME = FCS-FIELDNAME = 'INV_SEQ'.
  ENDIF.
  IF FCS-REF_FIELDNAME = 'DESC_T'.
    FCS-REF_FIELDNAME = FCS-FIELDNAME = 'DESC_TEXT1'.
  ENDIF.
  IF FCS-REF_FIELDNAME = 'SU_NAM'.
    FCS-REF_FIELDNAME = FCS-FIELDNAME ='SU_NAME'.
  ENDIF.
  IF FCS-REF_FIELDNAME = 'ISSUE'.
    FCS-REF_FIELDNAME = FCS-FIELDNAME ='ISSUE_ID'.
  ENDIF.
  IF FCS-REF_FIELDNAME = 'ISSUD'.
    FCS-REF_FIELDNAME = FCS-FIELDNAME ='ISSUE_DATE'.
  ENDIF.
  IF FCS-REF_FIELDNAME = 'CHARG'.
    FCS-REF_FIELDNAME = FCS-FIELDNAME ='CHARGETOTAL'.
  ENDIF.
  IF FCS-REF_FIELDNAME = 'TAXTO'.
    FCS-REF_FIELDNAME = FCS-FIELDNAME ='TAXTOTAL'.
  ENDIF.
  IF FCS-REF_FIELDNAME = 'GRAND'.
    FCS-REF_FIELDNAME = FCS-FIELDNAME ='GRANDTOTAL'.
  ENDIF.
*<- [CHM2207-00033] 세금계산서 매핑내역 추가 -[e]

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

  SET TITLEBAR 'T1000' WITH '상태별 수입관련비용'.

** JS전선 회사코드 2007/04 --------------------------------------
*  FREE: s_bukrs.    CLEAR: s_bukrs.
*  s_bukrs-sign   = 'I'.
*  s_bukrs-option = 'EQ'.
*  s_bukrs-low    = c_bukrs.
*  APPEND s_bukrs.
** JS전선 회사코드 2007/04 --------------------------------------

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
    MESSAGE E348(M7) WITH TEXT-102.
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

  DATA:  L_COUNT     TYPE  I.
  RANGES: LR_LIVST   FOR   ZTIVCS00-LIVST OCCURS 1.

  FIELD-SYMBOLS: <LS_TABLE>.
  FIELD-SYMBOLS: <L_FIELD1>.
  FIELD-SYMBOLS: <L_FIELD2>.

  REFRESH : <GT_TABLE>.
*> PROGRESS Display.
  G_LINE1    = 30.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
  REPLACE '%99999%' WITH G_LINE1 INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINE1.

  CLEAR LR_LIVST .
  MOVE: 'I'     TO    LR_LIVST-SIGN,
        'EQ'    TO    LR_LIVST-OPTION.
*----------------------------------------------------------------------
*P :  전기완료
*N :  전기대상
*----------------------------------------------------------------------
  CASE 'X'.
    WHEN P_STEP1. ">전기대상.
      MOVE: 'N'   TO  LR_LIVST-LOW.    APPEND LR_LIVST .
    WHEN P_STEP2. ">전기완료.
      MOVE: 'P'   TO  LR_LIVST-LOW.    APPEND LR_LIVST .
    WHEN P_STEP3. ">전체.
      REFRESH LR_LIVST .
  ENDCASE.

*> 수입의뢰 데이타 select.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE <GT_TABLE>
    FROM ZTIVCS00
   WHERE BUKRS   IN  S_BUKRS
     AND ICSNO   IN  S_ICSNO
     AND GJAHR   IN  S_GJAHR
     AND BELNR   IN  S_BELNR
     AND MONAT   IN  S_MONAT
     AND LIFNR   IN  S_LIFNR
     AND EXPGR   IN  S_EXPGR
     AND EXPCD   IN  S_EXPCD
     AND REFNO   IN  S_REFNO
     AND AMDSQ   IN  S_AMDSQ
     AND MWSKZH  IN  S_MWSKZH
     AND ZTERM   IN  S_ZTERM
     AND BUDAT   IN  S_BUDAT
     AND BLDAT   IN  S_BLDAT
     AND PTDCL   IN  S_PTDCL
     AND DSTRB   IN  S_DSTRB
     AND CNAMH   IN  S_CNAMH
     AND CDATH   IN  S_CDATH
     AND LIVST   IN  LR_LIVST.

  IF SY-SUBRC NE 0.
    MESSAGE S902.
  ENDIF.


  ASSIGN LOCAL COPY OF INITIAL LINE OF <GT_TABLE> TO <LS_TABLE>.

  FIELD-SYMBOLS: <L_FIELD3>.
  FIELD-SYMBOLS: <L_FIELD4>.
  FIELD-SYMBOLS: <EBELN>.
  FIELD-SYMBOLS: <EXPCD>.
  FIELD-SYMBOLS: <EXPTX>.
  FIELD-SYMBOLS: <DDTEXT>.
  FIELD-SYMBOLS: <BUKRS>.
  FIELD-SYMBOLS: <WERKS>.


*-> [CHM2207-00033] 세금계산서 연결 필드  -[s]
  FIELD-SYMBOLS: <L_INVNO>.
  FIELD-SYMBOLS: <L_NAME9>.
  FIELD-SYMBOLS: <L_DESC1>.
  FIELD-SYMBOLS: <ISSUE_ID>.
  FIELD-SYMBOLS: <ISSUE_DA>.
  FIELD-SYMBOLS: <GRANDTOTAL>.
  FIELD-SYMBOLS: <CHARGETOTAL>.
  FIELD-SYMBOLS: <TAXTOTAL>.

*-< [CHM2207-00033] 세금계산서 연결 필드  -[s]



  LOOP AT <GT_TABLE> INTO <LS_TABLE>.
    G_TABIX = SY-TABIX.

    ASSIGN COMPONENT 'REFTX' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD1>.

    ASSIGN COMPONENT 'REFNO' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD2>.

    ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD3>.

    ASSIGN COMPONENT 'EXPGR' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD4>.

    ASSIGN COMPONENT 'EBELN' OF STRUCTURE
                        <LS_TABLE> TO <EBELN>.

    ASSIGN COMPONENT 'WERKS' OF STRUCTURE
                        <LS_TABLE> TO <WERKS>.
*********************
*L:	수입의뢰비용
*I:	적하보험비용
*B:	선적관련비용
*C:	수입통관비용
*********************

    CASE <L_FIELD4>.

      WHEN 'L'.
        SELECT SINGLE OPNNO EBELN
          INTO (<L_FIELD1>, <EBELN>)
          FROM ZTITRQS
         WHERE REQNO EQ <L_FIELD2>
           AND AMDSQ EQ <L_FIELD3>
           AND EBELN IN S_EBELN.
        IF SY-SUBRC NE 0.
          DELETE <GT_TABLE> INDEX G_TABIX.
          CONTINUE.
        ENDIF.

      WHEN 'I'.
        SELECT SINGLE IOPNO EBELN
          INTO (<L_FIELD1>, <EBELN>)
          FROM ZTITIP1
         WHERE IIPNO EQ <L_FIELD2>
           AND AMDSQ EQ <L_FIELD3>
           AND EBELN IN S_EBELN.
        IF SY-SUBRC NE 0.
          DELETE <GT_TABLE> INDEX G_TABIX.
          CONTINUE.
        ENDIF.

      WHEN 'B'.
        SELECT SINGLE BLNUM EBELN
          INTO (<L_FIELD1>, <EBELN>)
          FROM ZTITBLK
         WHERE IBLNO EQ <L_FIELD2>
           AND EBELN IN S_EBELN.
        IF SY-SUBRC NE 0.
          DELETE <GT_TABLE> INDEX G_TABIX.
          CONTINUE.
        ENDIF.

      WHEN 'C'.
        SELECT SINGLE CDCNO EBELN
          INTO (<L_FIELD1>, <EBELN>)
          FROM ZTITCCK
         WHERE ICCNO EQ <L_FIELD2>
           AND EBELN IN S_EBELN.
        IF SY-SUBRC NE 0.
          DELETE <GT_TABLE> INDEX G_TABIX.
          CONTINUE.
        ENDIF.

      WHEN 'T'.
        SELECT SINGLE TXRNO EBELN
          INTO (<L_FIELD1>, <EBELN>)
          FROM ZTITTXK
         WHERE TAXNO EQ <L_FIELD2>
           AND EBELN IN S_EBELN.
        IF SY-SUBRC NE 0.
          DELETE <GT_TABLE> INDEX G_TABIX.
          CONTINUE.
        ENDIF.

    ENDCASE.


    ASSIGN COMPONENT 'EXPCD' OF STRUCTURE
                        <LS_TABLE> TO <EXPCD>.

    ASSIGN COMPONENT 'EXPTX' OF STRUCTURE
                        <LS_TABLE> TO <EXPTX>.

    ASSIGN COMPONENT 'DDTEXT' OF STRUCTURE
                        <LS_TABLE> TO <DDTEXT>.

    ASSIGN COMPONENT 'BUKRS' OF STRUCTURE
                        <LS_TABLE> TO <BUKRS>.

    PERFORM  GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING 'ZTIEXPGR'
                                                   <L_FIELD4>
                                                   <DDTEXT>.

    SELECT SINGLE EXPTX
      INTO <EXPTX>
      FROM ZTITIG06
     WHERE BUKRS EQ <BUKRS>
       AND EXPGR EQ <L_FIELD4>
       AND EXPCD EQ <EXPCD>.

*******************************************************************
* CSR : 201203 Start  "Q20120315_62763
*******************************************************************
    SELECT SINGLE WERKS
      INTO <WERKS>
      FROM EKPO
     WHERE EBELN EQ <EBELN>
       AND EBELP EQ '10'.
*******************************************************************
* CSR : 201203 Start
*******************************************************************

*-> [CHM2207-00033] 세금계산서 필드 할당 -[s]
  IF S_BUKRS-LOW EQ '3000'.

    ASSIGN COMPONENT 'INV_SEQ'  OF STRUCTURE
                        <LS_TABLE> TO <L_INVNO>.
    ASSIGN COMPONENT 'SU_NAME'  OF STRUCTURE
                        <LS_TABLE> TO <L_NAME9>.
    ASSIGN COMPONENT 'DESC_TEXT1' OF STRUCTURE
                        <LS_TABLE> TO <L_DESC1>.
    ASSIGN COMPONENT 'ISSUE_ID' OF STRUCTURE
                        <LS_TABLE> TO <ISSUE_ID>.
    ASSIGN COMPONENT 'ISSUE_DATE' OF STRUCTURE
                        <LS_TABLE> TO <ISSUE_DA>.
    ASSIGN COMPONENT 'CHARGETOTAL' OF STRUCTURE
                        <LS_TABLE> TO <CHARGETOTAL>.
    ASSIGN COMPONENT 'TAXTOTAL' OF STRUCTURE
                        <LS_TABLE> TO <TAXTOTAL>.
    ASSIGN COMPONENT 'GRANDTOTAL' OF STRUCTURE
                        <LS_TABLE> TO <GRANDTOTAL>.

     SELECT SINGLE  DESC_TEXT1 SU_NAME ISSUE_ID ISSUE_DATE
                   CHARGETOTAL TAXTOTAL GRANDTOTAL
       INTO (<L_DESC1>,<L_NAME9> ,<ISSUE_ID>, <ISSUE_DA>,
             <CHARGETOTAL>,<TAXTOTAL>,<GRANDTOTAL>)
      FROM ZDTV3T_AP_HEAD
     WHERE BUKRS   EQ <BUKRS>
       AND INV_SEQ EQ <L_INVNO>.
   ENDIF.
*-> [CHM2207-00033] 세금계산서 필드 할당 -[e]
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
  "회사코드
  AC 'ITAB   BUKRS ZTIVCS00                     BUKRS '.
  "수입비용 문서번호
  AC 'ITAB   ICSNO ZTIVCS00                     ICSNO '.
  "수입비용 문서품목
  AC 'ITAB   ICSSQ ZTIVCS00                     ICSSQ '.
  "회계연도
  AC 'ITAB   GJAHR ZTIVCS00                     GJAHR '.
  "회계전표번호
  AC 'ITAB   BELNR ZTIVCS00                     BELNR '.
  "사업영역  "Q20120315_62763
  AC 'ITAB   GSBER ZTIVCS00                     GSBER '.
  "구매오더번호
  AC 'ITAB   EBELN ZTITRQS                      EBELN '.
  "회계기간
  AC 'ITAB   MONAT ZTIVCS00                     MONAT '.
  "구매처 또는 채권자 정번호
  AC 'ITAB   LIFNR ZTIVCS00                     LIFNR '.
  "구매처 또는 채권자 정번호
  AC 'ITAB   NAME1 ZTIVCS00                     NAME1 '.
  "수입비용코드
  AC 'ITAB   EXPCD ZTIVCS00                     EXPCD '.
  "수입비용코드 TEXT
  AC 'ITAB   EXPTX ZTITIG06                     EXPTX '.
  "비용그룹
  AC 'ITAB   EXPGR ZTIVCS00                     EXPGR '.
  "비용그룹 TEXT.
  AC 'ITAB   DDTEXTDD07T                        DDTEXT'.
  "관련문서번호
  AC 'ITAB   REFNO ZTIVCS00                     REFNO '.
  "배서차수
  AC 'ITAB   AMDSQ ZTIVCS00                     AMDSQ '.
  "해당문서번호
  AC 'ITAB   REFTX ZTITBLK                      BLNUM '.
  "부가가치세코드
  AC 'ITAB   MWSKZHZTIVCS00                     MWSKZH'.
  "지급조건키
  AC 'ITAB   ZTERM ZTIVCS00                     ZTERM '.
  "통화.
  AC 'ITAB   WAERS ZTIVCS00                     WAERS '.
  "금액
  AC 'ITAB   WRBTR ZTIVCS00                     WRBTR  CWAERS '.
  "전표의 전기일
  AC 'ITAB   BUDAT ZTIVCS00                     BUDAT '.
  "전표증빙일
  AC 'ITAB   BLDAT ZTIVCS00                     BLDAT '.
  "전기방법
  AC 'ITAB   PTDCL ZTIVCS00                     PTDCL '.
  "비용배부방법
  AC 'ITAB   DSTRB ZTIVCS00                     DSTRB '.
  "작성인
  AC 'ITAB   CNAMH ZTIVCS00                     CNAMH '.
  "생성일
  AC 'ITAB   CDATH ZTIVCS00                     CDATH '.

* CSR : 2012   "Q20120315_62763
  "대표플랜트
  AC 'ITAB   WERKS ZTITBLK                      WERKS '.
*

*>- [CHM2207-00033] 세금계산서 매핑내역 추가 -[s]

*{ 기능개선 279122 - S

 IF S_BUKRS-LOW EQ '3000'.
  "매입세금계산서
  AC 'ITAB   INVNO ZSDT3010                     INV_SEQ '.
   "매입세금계산서 비고
  AC 'ITAB   DESCT ZSDT3010                     DESC_TEXT1 '.
   "매입세금계산서 구매처
  AC 'ITAB   NAME9 ZSDT3010                     SU_NAME'.
   "매입세금계산서 구매처
  AC 'ITAB   ISSUE ZDTV3T_AP_HEAD               ISSUE'.
   "매입세금계산서
  AC 'ITAB   ISSUD ZDTV3T_AP_HEAD               ISSUD'.
  "매입세금계산서 구매처
  AC 'ITAB   CHARG ZDTV3T_AP_HEAD               CHARG  CWAERS '..
   "매입세금계산서 구매처
  AC 'ITAB   TAXTO ZDTV3T_AP_HEAD               TAXTO  CWAERS '..
  "매입세금계산서 구매처
  AC 'ITAB   GRAND ZDTV3T_AP_HEAD               GRAND  CWAERS '..
*} 기능개선 279122 - E
*<- [CHM2207-00033] 세금계산서 매핑내역 추가 -[e]
 ENDIF.

*> Create field catagory table
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = 'ZTIVCS00'
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
      WHEN 'ICSNO' OR 'ICSSQ'.
        FCS-HOTSPOT = 'X'.
        FCS-KEY     = 'X'.

      WHEN 'REFNO'.
        FCS-HOTSPOT = 'X'.

      WHEN 'GJAHR' OR 'BELNR' OR 'MONAT'.
        IF P_STEP1 EQ 'X'.
          FCS-NO_OUT = 'X'.
        ENDIF.

      WHEN 'REFTX'.
        FCS-SELTEXT_L = '문서번호'.
        FCS-SELTEXT_M = '해당문서번호'.
        FCS-SELTEXT_S = '해당문서번호'.
*        fcs-outputlen = 20.

*>- [CHM2207-00033] 세금계산서 매핑 필드 추가 -[s]
      WHEN 'INVNO'.
        FCS-SELTEXT_L = '매입계산서'.
        FCS-SELTEXT_M = '매입계산서'.
        FCS-SELTEXT_S = '매입계산서'.
      WHEN 'DESC_TEXT1'.
        FCS-SELTEXT_L = '계산서비고'.
        FCS-SELTEXT_M = '계산서비고'.
        FCS-SELTEXT_S = '계산서비고'.
      WHEN 'NAME9'.
        FCS-SELTEXT_L = '계산서구매처'.
        FCS-SELTEXT_M = '계산서구매처'.
        FCS-SELTEXT_S = '계산서구매처'.
      WHEN 'ISSUE_ID'.
        FCS-SELTEXT_L = '계산서승인번호'.
        FCS-SELTEXT_M = '계산서승인번호'.
        FCS-SELTEXT_S = '계산서승인번호'.
      WHEN 'ISSUE_DATE'.
        FCS-SELTEXT_L = '계산서작성일자'.
        FCS-SELTEXT_M = '계산서작성일자'.
        FCS-SELTEXT_S = '계산서작성일자'.
      WHEN 'CHARGETOTAL'.
        FCS-SELTEXT_L = '계산서공급가액'.
        FCS-SELTEXT_M = '계산서공급가액'.
        FCS-SELTEXT_S = '계산서공급가액'.
        FCS-CURRENCY = 'KRW'.
      WHEN 'TAXTOTAL'.
        FCS-SELTEXT_L = '계산서 세액'.
        FCS-SELTEXT_M = '계산서 세액'.
        FCS-SELTEXT_S = '계산서 세액'.
        FCS-CURRENCY = 'KRW'.
      WHEN 'GRANDTOTAL'.
        FCS-SELTEXT_L = '계산서 총금액'.
        FCS-SELTEXT_M = '계산서 총금액'.
        FCS-SELTEXT_S = '계산서 총금액'.
        FCS-CURRENCY = 'KRW'.

*<- [CHM2207-00033] 세금계산서 매핑 필드 추가 -[e]

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


  CASE 'X'.
    WHEN P_STEP1. ">의뢰대상
      SET TITLEBAR 'T1000' WITH '미전기현황'.
    WHEN P_STEP2. ">접수대상
      SET TITLEBAR 'T1000' WITH '전기현황'.
    WHEN P_STEP3. ">신청대상
      SET TITLEBAR 'T1000' WITH '전체현황'.
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
      APPEND 'ZTIT002'  TO EXTAB.
      APPEND 'ZTIT005'  TO EXTAB.
    WHEN P_STEP3. ">개설의뢰 진행 중
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

  ASSIGN LOCAL COPY OF INITIAL LINE OF <GT_TABLE> TO <LS_TABLE>.

  CASE R_UCOMM.

    WHEN 'DISPLAY' OR '&IC1'.    " AUF DOPPELKLICK REAGIERIEN

      CHECK RS_SELFIELD-TABINDEX GT 0.

      READ TABLE <GT_TABLE> INTO <LS_TABLE> INDEX RS_SELFIELD-TABINDEX.
      IF SY-SUBRC NE 0.
        MESSAGE S906.            EXIT.
      ENDIF.

      CASE RS_SELFIELD-FIELDNAME.
        WHEN 'ICSNO'.
          ASSIGN COMPONENT 'ICSNO' OF STRUCTURE
                          <LS_TABLE> TO <L_FIELD1>.

          SET PARAMETER ID 'ZTIICSNO' FIELD <L_FIELD1>.
          CALL TRANSACTION 'ZTIT903' AND SKIP FIRST SCREEN.

        WHEN 'REFNO'.
          ASSIGN COMPONENT 'REFNO' OF STRUCTURE
                          <LS_TABLE> TO <L_FIELD1>.

          ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                          <LS_TABLE> TO <L_FIELD2>.

          ASSIGN COMPONENT 'EXPGR' OF STRUCTURE
                          <LS_TABLE> TO <L_FIELD>.
*********************
*L:	수입의뢰비용
*I:	적하보험비용
*B:	선적관련비용
*C:	수입통관비용
*********************
          CASE <L_FIELD>.

            WHEN 'L'.
              PERFORM  DISPLAY_IMPORT_DOCUMENT(ZTIR0000)
                                        USING <L_FIELD1>
                                              <L_FIELD2>
                                              SPACE.

            WHEN 'I'.
              PERFORM  DISPLAY_IP_DOCUMENT(ZTIR0000)
                                      USING  <L_FIELD1>
                                             <L_FIELD2>.

            WHEN 'B'.
              PERFORM  DISPLAY_BL_DOCUMENT(ZTIR0000)
                                        USING <L_FIELD1>
                                              SPACE.

            WHEN 'C'.
              PERFORM DISPLAY_CC_DOCUMENT(ZTIR0000)
                                        USING <L_FIELD1>
                                              <L_FIELD2>.
          ENDCASE.


        WHEN OTHERS.              ">해당작업수행..
*          PERFORM get_data_for_display.    ">data select
*          rs_selfield-refresh = 'X'.
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

  CLEAR  ST_SORT.
  ST_SORT-SPOS = '00'.
  ST_SORT-FIELDNAME = 'BUKRS'.
  ST_SORT-TABNAME   = 'ITAB'.
  ST_SORT-UP        = 'X'.
*  ST_SORT-GROUP     = 'X'.
  ST_SORT-SUBTOT    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND ST_SORT TO IT_SORT.

  CLEAR  ST_SORT.
  ST_SORT-SPOS = '01'.
  ST_SORT-FIELDNAME = 'ICSNO'.
  ST_SORT-TABNAME   = 'ITAB'.
  ST_SORT-UP        = 'X'.
*  ST_SORT-GROUP     = 'X'.
  ST_SORT-SUBTOT    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND ST_SORT TO IT_SORT.

  CLEAR  ST_SORT.
  ST_SORT-SPOS = '02'.
  ST_SORT-FIELDNAME = 'BELNR'.
  ST_SORT-TABNAME   = 'ITAB'.
  ST_SORT-UP        = 'X'.
*  ST_SORT-GROUP     = 'X'.
*  ST_SORT-SUBTOT    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND ST_SORT TO IT_SORT.

  CLEAR  ST_SORT.
  ST_SORT-SPOS = '03'.
  ST_SORT-FIELDNAME = 'GJAHR'.
  ST_SORT-TABNAME   = 'ITAB'.
  ST_SORT-UP        = 'X'.
*  ST_SORT-GROUP     = 'X'.
*  ST_SORT-SUBTOT    = 'X'.
*  ST_SORT-EXPA      = 'X'.
  APPEND ST_SORT TO IT_SORT.

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
      HEADER-INFO = '전기대상 현황'.
    WHEN P_STEP2.
      HEADER-INFO = '전기완료 현황'.
    WHEN P_STEP3.
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
              'ZTIVCS00'                  TO FCS-REF_TABNAME.
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
