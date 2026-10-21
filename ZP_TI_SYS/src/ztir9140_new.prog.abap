************************************************************************
* Title         :  ZTIR9140                                            *
*                                                                      *
* Description   : [Report] 통관 비용 관리                              *
*                                                                      *
* Creation Date : 2004/02/18                                           *
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
*&---------------------------------------------------------------------*
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2009/09/17    조성임    [제목] DDP 수입 프로세스 정립 요청건         *
*                         [요청번호] C20090902_17722                   *
* 2016/03/17    신재호    [제목] 인천세관 합병에 따른 변경             *
*                         [요청번호] 기능개선 126639                   *
* 2019/04/19    권민선    [제목] 공급업체, 비용지급처 필드 추가 및 수정*
*                         [요청번호] 기능개선_275072                   *
* 2019/04/19    박성수    [제목] 구매오더 유형 텍스트 추가             *
*                         [요청번호] 기능개선_290009                   *
* 2020/05/06    신재호    [제목] DDP도 관세부가세 처리할수 있도록 수정 *
*                         [요청번호] 기능개선 318890                   *
* 2021/12/20    송승규    [제목] 매입세금계산서 매핑                   *
*                         [요청번호] CHM2110-00555                     *
* 2023/06/28    고범진    [제목] 인천세관 코드 합병 재분리             *
*                         [요청번호] CHM2306-00372                     *
************************************************************************
REPORT  ZTIR9140       MESSAGE-ID ZMTI00
                       NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: SLIS,   "> Globale Type(ALV)
            KKBLO.  "> Generic list types

TYPES:  BEGIN OF TY_LIST.
          INCLUDE STRUCTURE ZTISCCCS.
*      표현fields를 위한 보조 fields.
TYPES:    ERRMD     TYPE C,
          CSTCL     LIKE  ZTITIG06-CSTCL,
          ZTERM     LIKE  ZTITIG07-ZTERM,
          ZLSPR     LIKE  ZTITIG07-ZLSPR,
          ZLSCH     LIKE  ZTITIG07-ZLSCH,
          UZAWE     LIKE  ZTITIG07-UZAWE,
          STATE     LIKE  ZTITCCK-STATE,  "신고자.
          EPART     LIKE  ZTSTIG3-EPART,  "관세사에 해당하는 edi partner.
          PARTI     LIKE  ZTSTIG3-PARTI,  "H=edi partner group.
          LIFCC     LIKE  ZTSTIG3-LIFNR,  "=LIFNR관세사 계정.
          NAMCC     LIKE  ZTSTIG3-NAMET,  "text.
          CDCOR     LIKE  ZTITCCK-CDCOR,  "신고세관
          LIFOR     LIKE  ZTSVIG5-LIFNR,  "ZTSVIG5-CDCOR에 해당하는 계정.
          NAMOR     LIKE  ZTSVIG5-NAME1,  "text
          CPYATC    LIKE  ZTITCCK-CPYATC, "결제금액 통화
          CPYAT     LIKE  ZTITCCK-CPYAT,  "결제금액
          CCUAKC    LIKE  ZTITCCK-CCUAKC, "과세가격합계통화
          CCUAK     LIKE  ZTITCCK-CCUAK,  "과세가격합계
          CCUAUC    LIKE  ZTITCCK-CCUAUC, "과세가격합계통화
          CCUAU     LIKE  ZTITCCK-CCUAU,  "과세가격합계
          CDUTX     LIKE  ZTITCCK-CDUTX,  "관세
          CSPTX     LIKE  ZTITCCK-CSPTX,  "특소세
          CALTX     LIKE  ZTITCCK-CALTX,  "주세
          CTRTX     LIKE  ZTITCCK-CTRTX,  "교통세
          CINTX     LIKE  ZTITCCK-CINTX,  "교육세
          CAGTX     LIKE  ZTITCCK-CAGTX,  "농특세
          CADTX     LIKE  ZTITCCK-CADTX,  "부가세
          CTSAK     LIKE  ZTITCCK-CTSAK,  "부가세과세과표
          CLTTX     LIKE  ZTITCCK-CLTTX,  "신고지연가산세
          CTOTL     LIKE  ZTITCCK-CTOTL,  "합계
          CCHCG     LIKE  ZTITCCK-CCHCG,  "관세사 수수료
          EXPGR     LIKE  ZTISCSIT-EXPGR, "비용그룹
          PSPNR     LIKE  ZTITCCK-PSPNR,  "프로젝트 정의
          CSDRT     LIKE  ZTITCCK-CSDRT,  "란 관세율
          DOCST     LIKE  ZTITCCK-DOCST,  "문서상태
          BATXT     LIKE  T161T-BATXT   , "PO유형(텍스트)"기능개선 290009
          EKORG     LIKE  ZTITCCK-EKORG,  "구매조직
          EKGRP     LIKE  ZTITCCK-EKGRP,  "구매그룹
          CDADT     LIKE  ZTITCCK-CDADT,  "수입신고 의뢰일자
          CDRNO     LIKE  ZTITCCK-CDRNO,  "신고의뢰번호
          VORGX(20),
          CNAM      LIKE  ZTITCCK-CNAM,
          CDAT      LIKE  ZTITCCK-CDAT,
          UNAM      LIKE  ZTITCCK-UNAM,
          UDAT      LIKE  ZTITCCK-UDAT,
          CDCCH     LIKE  ZTITCCK-CDCCH,  "신고과
          CELLTAB   TYPE LVC_T_STYL,     "Cell단위 수정 스타일
        END   OF TY_LIST.

************************************************************************
* SAP Include Define                                                   *
************************************************************************
INCLUDE : <ICON>,
          <SYMBOL>,
          ZTS_REUSE_BDC_SUBROUTINE_F00.

*---------------------------------------------------------------------*
*> Message dialog box용                                               *
*---------------------------------------------------------------------*
DATA: BEGIN OF IT_MSG  OCCURS 0.
        INCLUDE STRUCTURE ZTISMESSAGE.
DATA: END   OF IT_MSG.

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: ZTITCCK,
        ZTITCSK,
        ZTITIG00,     ">[TraSys] 회사별 프로세스 정의.
        ZTITIG07,     ">[TraSys]  제비용 일괄전기 Default Value관리.
        ZTITCSP,
        ZTISCSIT,
        ZTISCCCS,
        ZTISSCRCOM,
        ZTIVCS00,
        EKPO,
        T001,
        T005,
        LFA1,
        *LFA1,
        ICON,
        VF_KRED,
        EKKO.

TABLES: BAPI1093_0,
        BAPICURX,
        BAPIRET1.

************************************************************************
* SAP Views                                                            *
************************************************************************

************************************************************************
* CONSTANTS                                                            *
************************************************************************
** JS전선 회사코드 2007/04 BY-MH.LEE------------------
*CONSTANTS:
*    c_bukrs     LIKE t001-bukrs     VALUE '1000'.   ">Company code
** JS전선 회사코드 2007/04 ---------------------------
************************************************************************
* Internal Tables                                                      *
************************************************************************
*> Select용.
*DATA: IT_DISP  TYPE STANDARD TABLE OF ty_list,
*      GS_DISP  TYPE ty_list.
DATA: IT_DISP TYPE STANDARD TABLE OF TY_LIST,
      IT_TEMP TYPE STANDARD TABLE OF TY_LIST,
      GS_DISP TYPE TY_LIST.

DATA: BEGIN OF IT_VENDOR  OCCURS 2,
        LIFNR TYPE LIFNR,
      END   OF IT_VENDOR.

*> 거래상대방(은행)
DATA: BEGIN OF IT_ZTSTIG3  OCCURS 0.
        INCLUDE STRUCTURE ZTSTIG3.
DATA: END   OF IT_ZTSTIG3.

*> 비용코드.
DATA: BEGIN OF IT_ZTITIG06  OCCURS 0.
        INCLUDE STRUCTURE ZTISIG06.
DATA: END   OF IT_ZTITIG06.

*> 수취인 HELP용.
DATA : DYNPROG            LIKE SY-REPID,
       DYNNR              LIKE SY-DYNNR,
       G_WINDOW_TITLE(60),
       G_DISPLAY.

DATA : BEGIN OF XLFZA OCCURS 0,
         LIFNR LIKE LFZA-LIFNR,
         BUKRS LIKE LFZA-BUKRS,
         EMPFK LIKE LFZA-EMPFK,
         NAME1 LIKE LFA1-NAME1.
DATA : END   OF XLFZA.

DATA : G_BUKRS TYPE BUKRS.

" [CHM2110-00555]
DATA : GT_ZMMT0312 TYPE TABLE OF ZMMT0312 WITH HEADER LINE.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
* Fieldcatalog Grid
DATA: IT_FIELDCAT_G TYPE LVC_T_FCAT,
      GS_FIELDCAT_G LIKE LINE OF IT_FIELDCAT_G.
*icon
*DATA: g_lights_name TYPE lvc_cifnm VALUE 'ICON'.
* Button exclude.
DATA : IT_EXCLUDE   TYPE UI_FUNCTIONS.
* Layout GRID.
DATA: GS_LAYOUT_G   TYPE LVC_S_LAYO.
DATA: GS_STABLE     TYPE LVC_S_STBL.

* PRINT GRID.
DATA:  GS_PRINT_G   TYPE LVC_S_PRNT.
DATA : GS_SORT_G    TYPE LVC_S_SORT.
DATA : IT_SORT_G    TYPE LVC_T_SORT.
DATA : GS_FILTER_G  TYPE LVC_S_FILT.
DATA : IT_FILTER_G  TYPE LVC_T_FILT.

DATA: IT_FIELDCAT         TYPE SLIS_T_FIELDCAT_ALV.
DATA: IT_XHEADER          TYPE SLIS_T_LISTHEADER WITH HEADER LINE.
DATA: IT_COLOR            TYPE SLIS_T_SPECIALCOL_ALV WITH HEADER LINE.
DATA: IT_SORT             TYPE SLIS_T_SORTINFO_ALV.
DATA: IT_FILTER           TYPE SLIS_T_FILTER_ALV.
DATA: IT_GRUPPEN          TYPE SLIS_T_SP_GROUP_ALV WITH HEADER LINE.
DATA: IT_EVENTS           TYPE SLIS_T_EVENT.
DATA: IT_EVENT_EXIT       TYPE SLIS_T_EVENT_EXIT WITH HEADER LINE.
DATA: IT_DISPHEADER       TYPE SLIS_T_LISTHEADER.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
DATA: G_SPLITTER           TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
      G_CUSTOM_CONTAINER   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      G_CUSTOM_CONTAINER_1 TYPE REF TO CL_GUI_CONTAINER,
      G_GRID               TYPE REF TO CL_GUI_ALV_GRID,
* Docking Container
      G_DOCKING            TYPE REF TO CL_GUI_DOCKING_CONTAINER.

DATA: G_REPID             LIKE SY-REPID.

DATA: GS_VARIANTE       LIKE DISVARIANT,
      GS_DEF_VARIANTE   LIKE DISVARIANT,
      G_VARIANT_EXIT(1) TYPE C,
      G_VARIANT_SAVE(1) TYPE C,
      G_VARIANT_DEF(1)  TYPE C.

DATA: G_TABIX        LIKE SY-TABIX,
      G_INDEX        LIKE SY-INDEX,
      G_SUBRC        LIKE SY-SUBRC,
      G_ANSWER       TYPE C,
      G_COUNT        TYPE I,
      G_CNT          TYPE I,
      G_FWBAS        TYPE FWBAS,
      G_WRBTR        TYPE WRBTR,
      G_WMWST        TYPE WMWST,
      G_LINE         TYPE I,
      G_GUBUN        TYPE C,
      OK_CODE        LIKE SY-UCOMM,
      G_SUCCESS      TYPE I,
      G_ERROR        TYPE I,
      G_LINEN(3)     TYPE N,
      G_OUT_TEXT(70) TYPE C.

*> fi 전기용.
INCLUDE ZTI_REUSE_FORMS_FOR_FI_POSTING.


************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK DBSEL WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:
    S_BUKRS  FOR ZTITCCK-BUKRS                    "회사코드.
                      NO-EXTENSION NO INTERVALS OBLIGATORY
                      MEMORY ID BUK
                      MODIF  ID IOG ,
    S_EBELN  FOR ZTITCCK-EBELN  MODIF  ID IOG,    "구매조직
    S_EKORG  FOR ZTITCCK-EKORG  MODIF  ID IOG,    "구매조직
    S_EKGRP  FOR ZTITCCK-EKGRP  MODIF  ID IOG,    "구매그룹
    S_BUPLA  FOR ZTITCCK-BUPLA  MODIF  ID IOG,    "사업장.
    S_MWSKZ  FOR ZTITCSK-MWSKZ,                   "세금코드.
    S_KNTTP  FOR EKPO-KNTTP,
    S_ICCNO  FOR ZTITCCK-ICCNO  MODIF  ID IOG     "통관관리번호
                                MEMORY ID ZTIICCNO,
    S_CDCNO  FOR ZTITCCK-CDCNO  MODIF  ID IOG,    "(RES)신고(수리)번호
    S_CDRDT  FOR ZTITCCK-CDRDT  MODIF  ID IOG,    "(RES)신고수리일
    S_PAYDA  FOR ZTITCCK-PAYDA  MODIF  ID IOG,    "납부예정일자.
    S_CARTY  FOR ZTITCCK-CARTY  MODIF  ID IOG,    "징수형태.
    S_LIFNR  FOR ZTITCCK-LIFNR  MODIF  ID IOG,    "구매처채권자계정
    S_CDHDT  FOR ZTITCCK-CDHDT  MODIF  ID IOG,    "신고희망일자(CCYYMMDD)
    S_CDADT  FOR ZTITCCK-CDADT  MODIF  ID IOG,    "수입신고 의뢰
    S_CDCDT  FOR ZTITCCK-CDCDT  MODIF  ID IOG,    "(RES)신고일
    S_CDRNO  FOR ZTITCCK-CDRNO  MODIF  ID IOG,    "(RES)신고의뢰번호
    S_STATE  FOR ZTITCCK-STATE  MODIF  ID IOG,    "신고자
    S_CDCOR  FOR ZTITCCK-CDCOR  MODIF  ID IOG,    "신고세관
    S_CDCCH  FOR ZTITCCK-CDCCH  MODIF  ID IOG,    "신고과
    S_CIMTY  FOR ZTITCCK-CIMTY  MODIF  ID IOG,    "수입자구분
    S_CDAPN  FOR ZTITCCK-CDAPN  MODIF  ID IOG,    "신고의뢰자 상호
    S_CIMNM  FOR ZTITCCK-CIMNM  MODIF  ID IOG,    "수입자상호
    S_CCONO  FOR ZTITCCK-CCONO  MODIF  ID IOG,    "무역업등록번호
    S_CNAM   FOR ZTITCCK-CNAM  ,                  "작성인.
    S_CDAT   FOR ZTITCCK-CDAT  ,                  "생성일.
    S_UNAM   FOR ZTITCCK-UNAM  ,                  "최종변경인.
    S_UDAT   FOR ZTITCCK-UDAT  ,                  "변경일.
    S_CBLNO  FOR ZTITCCK-CBLNO .                   "b/l번호.
*  S_ERDAT  FOR ZTITCCK-CDAT .  "[CHM2110-00555] 계산서발행일



  SELECTION-SCREEN ULINE.
  PARAMETERS: P_STEP1 RADIOBUTTON GROUP AB1 DEFAULT 'X',
              P_STEP2 RADIOBUTTON GROUP AB1,
              P_STEP3 RADIOBUTTON GROUP AB1.
  SELECTION-SCREEN ULINE.
SELECTION-SCREEN END OF BLOCK DBSEL.

SELECTION-SCREEN BEGIN OF BLOCK LISTS WITH FRAME TITLE TEXT-002.
  PARAMETERS: P_VARI LIKE DISVARIANT-VARIANT.
SELECTION-SCREEN END OF BLOCK LISTS.

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
  PERFORM P1101_CHECK_INPUT_VALUE.
*> 사용자 레이아웃 Input values Check
  PERFORM P1101_CHECK_VARIANT_VALUE.
*> 레이아웃 HELP
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM P1102_F4_FOR_VARIANT.

************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.
  CHECK G_ANSWER EQ 'Y'.
*> 검색조건에 해당하는 데이타를 Select.
  PERFORM P2000_DATA_SELECTIONS.

************************************************************************
* END-OF-SELECTION Event                                               *
************************************************************************
END-OF-SELECTION.
  DESCRIBE TABLE IT_DISP LINES G_LINE.
  IF NOT G_LINE IS INITIAL.
*> PROGRESS Display.
    G_LINEN    = 90.
    G_OUT_TEXT = '리스트를 구성 중입니다 %99999%%'(P03).
    REPLACE '%99999%'(P99) WITH G_LINEN INTO G_OUT_TEXT.
    PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

*> Dynamic Data Table build
    PERFORM 3000_FIELD_CATEGORY_BUILD.
    PERFORM 3210_EXCLUDE_TABLE_BUILD   USING 'IT_EXCLUDE'.
    PERFORM 3500_SORT_TABLE_BUILD.
    PERFORM 3700_LAYOUT_BUILD.
    PERFORM P3800_FIELD_ATTRIBUTE_CHANGE.
    CALL SCREEN 0100.
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

************************************************************************
*                                                                      *
* S U B R O U T I N E S                                                *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  p1000_alv_fields_initial
*&---------------------------------------------------------------------*
FORM P1000_ALV_FIELDS_INITIAL.

  CLEAR: GS_VARIANTE, GS_DEF_VARIANTE.

  MOVE SY-REPID TO : G_REPID ,
                     GS_VARIANTE-REPORT,
                     GS_DEF_VARIANTE-REPORT.

  CALL FUNCTION 'LVC_VARIANT_DEFAULT_GET'
    EXPORTING
      I_SAVE     = G_VARIANT_SAVE
    CHANGING
      CS_VARIANT = GS_DEF_VARIANTE
    EXCEPTIONS
      NOT_FOUND  = 2.

  IF SY-SUBRC = 0 .
    P_VARI = GS_DEF_VARIANTE-VARIANT.
  ENDIF.

  REFRESH IT_SORT.               CLEAR IT_SORT.
  REFRESH IT_FIELDCAT.           CLEAR IT_FIELDCAT.
  REFRESH IT_XHEADER.            CLEAR IT_XHEADER.
  REFRESH IT_COLOR.              CLEAR IT_COLOR.
  REFRESH IT_GRUPPEN.            CLEAR IT_GRUPPEN.
  REFRESH IT_EVENTS .            CLEAR IT_EVENTS.
  REFRESH IT_EVENT_EXIT .        CLEAR IT_EVENT_EXIT.
  REFRESH IT_DISPHEADER .        CLEAR IT_DISPHEADER.
*
ENDFORM.                    " p1000_alv_fields_initial
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
FORM P1001_INITIALIZATION .

  SET TITLEBAR 'T1000' WITH ' 현황 List'(T10).
  CLEAR: G_ANSWER.

**-- [CHM2110-00555] 세금계산서 추출 날짜 초기설정 -[s]
*  DATA : LV_DATE LIKE SY-DATUM.
*  LV_DATE = SY-DATUM.
*
*  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
*    EXPORTING
*      DATE      = LV_DATE
*      DAYS      = '00'
*      MONTHS    = '01'
*      SIGNUM    = '-'
*      YEARS     = '00'
*    IMPORTING
*      CALC_DATE = LV_DATE.
*  .
*  CONCATENATE LV_DATE(6) '01' INTO S_ERDAT-LOW.
*  S_ERDAT-HIGH = SY-DATUM.
*  S_ERDAT-SIGN = 'I'.
*  S_ERDAT-OPTION = 'EQ'.
*  APPEND S_ERDAT. CLEAR : S_ERDAT.
**-- [CHM2110-00555] 세금계산서 추출 날짜 초기설정 -[e]


ENDFORM.                    " p1001_initialization
*&---------------------------------------------------------------------*
*&      Form  p1101_check_variant_value
*&---------------------------------------------------------------------*
FORM P1101_CHECK_VARIANT_VALUE .

  IF NOT P_VARI IS INITIAL.
    MOVE GS_VARIANTE TO GS_DEF_VARIANTE.
    MOVE P_VARI TO GS_DEF_VARIANTE-VARIANT.
    CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
      EXPORTING
        I_SAVE        = G_VARIANT_SAVE
      CHANGING
        CS_VARIANT    = GS_DEF_VARIANTE
      EXCEPTIONS
        WRONG_INPUT   = 1
        NOT_FOUND     = 2
        PROGRAM_ERROR = 3
        OTHERS        = 4.
    IF SY-SUBRC <> 0 AND NOT P_VARI IS INITIAL.
      MESSAGE ID SY-MSGID TYPE 'E' NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    IF P_VARI IS INITIAL.
      CLEAR GS_VARIANTE-VARIANT.
    ELSE.
      GS_VARIANTE-VARIANT = P_VARI.
    ENDIF.

  ELSE.
    CLEAR GS_VARIANTE.
    GS_VARIANTE-REPORT = G_REPID.
  ENDIF.

ENDFORM.                    " p1101_check_variant_value
*&---------------------------------------------------------------------*
*&      Form  p1102_f4_for_variant
*&---------------------------------------------------------------------*
FORM P1102_F4_FOR_VARIANT .

  CLEAR GS_VARIANTE.
  MOVE G_REPID TO GS_VARIANTE-REPORT.

  CALL FUNCTION 'LVC_VARIANT_F4'
    EXPORTING
      IS_VARIANT = GS_VARIANTE
      I_SAVE     = G_VARIANT_SAVE
    IMPORTING
      E_EXIT     = G_VARIANT_EXIT
      ES_VARIANT = GS_DEF_VARIANTE
    EXCEPTIONS
      NOT_FOUND  = 1
      OTHERS     = 2.

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    IF G_VARIANT_EXIT = SPACE.
      P_VARI = GS_DEF_VARIANTE-VARIANT.
    ENDIF.
  ENDIF.

ENDFORM.                    " p1102_f4_for_variant
*&---------------------------------------------------------------------*
*&      Form  3000_field_category_build
*&---------------------------------------------------------------------*
FORM 3000_FIELD_CATEGORY_BUILD .

  DATA LS_FCAT TYPE LVC_S_FCAT.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME   = 'ZTISCCCS'
      I_INTERNAL_TABNAME = 'IT_DISP'
    CHANGING
      CT_FIELDCAT        = IT_FIELDCAT_G[].

  LS_FCAT-COL_POS = '54'.
  LS_FCAT-FIELDNAME = 'BATXT'.
  LS_FCAT-TABNAME = 'IT_DISP'.
  LS_FCAT-DATATYPE = 'C'.
  LS_FCAT-INTLEN = '20'.
  LS_FCAT-REPTEXT = '구매오더 유형'.
  LS_FCAT-DOMNAME = 'TEXT20'.
  LS_FCAT-DD_OUTLEN = '20'.
  LS_FCAT-SCRTEXT_L = '구매오더 유형'.
  LS_FCAT-SCRTEXT_M = '구매오더 유형'.
  LS_FCAT-SCRTEXT_S = '구매오더 유형'.

  APPEND LS_FCAT TO IT_FIELDCAT_G.
  CLEAR LS_FCAT.
*----------------------------------------------------------------------*
* 필드명과 Output Length등을 사용자의 입맛에 맞게 바꿈.
*----------------------------------------------------------------------*
  PERFORM 3010_INSERT_FIELD_CATEGORY USING :
          'S' 'FIELDNAME'     'VORGX',
          'E' 'OUTPUTLEN'     '10'.

  LOOP AT IT_FIELDCAT_G INTO GS_FIELDCAT_G.
    CLEAR: GS_FIELDCAT_G-KEY,
           GS_FIELDCAT_G-TECH,
           GS_FIELDCAT_G-NO_OUT.

    CASE GS_FIELDCAT_G-FIELDNAME.
      WHEN 'BOX'.
        GS_FIELDCAT_G-COL_POS   = 1.
        GS_FIELDCAT_G-COLTEXT   = '선택'.
        GS_FIELDCAT_G-COL_OPT   = 'X'.
        GS_FIELDCAT_G-CHECKBOX  = 'X'.
        GS_FIELDCAT_G-EDIT      = 'X'.
        GS_FIELDCAT_G-KEY       = 'X'.
      WHEN 'ICON'.
        GS_FIELDCAT_G-COL_POS    = 2.
        GS_FIELDCAT_G-COLTEXT    = 'ICON'.
        GS_FIELDCAT_G-KEY        = 'X'.
      WHEN 'CDCNO'. "
        GS_FIELDCAT_G-COL_POS    = 4.
      WHEN 'ICCNO'.   "
        GS_FIELDCAT_G-COL_POS    = 3.
        GS_FIELDCAT_G-HOTSPOT    = 'X'.
        GS_FIELDCAT_G-KEY        = 'X'.
      WHEN 'ICCSQ'.   "
        GS_FIELDCAT_G-COLTEXT    = '정정차수'.
        GS_FIELDCAT_G-COL_OPT    = 'X'.
        GS_FIELDCAT_G-KEY        = 'X'.
      WHEN 'LIFNR'.   "
        GS_FIELDCAT_G-COLTEXT    = '비용지급처'.  "기능개선_275072
        GS_FIELDCAT_G-EDIT       = 'X'.
        GS_FIELDCAT_G-CHECKTABLE = '!'.
      WHEN 'BUPLA'.
        GS_FIELDCAT_G-OUTPUTLEN  = 6.
      WHEN 'WRBTR'.   "
        GS_FIELDCAT_G-EDIT       = 'X'.
        GS_FIELDCAT_G-COLTEXT    = '공급가액'.
*        gs_fieldcat_g-checktable = '!'.
        GS_FIELDCAT_G-DO_SUM     = 'X'.
      WHEN 'WMWST'.   "
        GS_FIELDCAT_G-EDIT       = 'X'.
*        gs_fieldcat_g-checktable = '!'.
        GS_FIELDCAT_G-DO_SUM     = 'X'.
      WHEN 'FWBAS'.   "
        GS_FIELDCAT_G-EDIT       = 'X'.
*        gs_fieldcat_g-checktable = '!'.
        GS_FIELDCAT_G-DO_SUM     = 'X'.
      WHEN 'WAERS'.   "
        GS_FIELDCAT_G-EDIT       = 'X'.
        GS_FIELDCAT_G-CHECKTABLE = '!'.
      WHEN 'NAME1'.
*        gs_fieldcat_g-coltext = '구매처 명'.     "기능개선_275072
        GS_FIELDCAT_G-COLTEXT   = '비용지급처명'. "기능개선_275072
        GS_FIELDCAT_G-OUTPUTLEN  = 10.
      WHEN 'EXPTX'.
        GS_FIELDCAT_G-OUTPUTLEN  = 10.
      WHEN 'MWSKZ'.
        GS_FIELDCAT_G-EDIT       = 'X'.
        GS_FIELDCAT_G-OUTPUTLEN  = 8.
*        gs_fieldcat_g-checktable = '!'.
        GS_FIELDCAT_G-COL_OPT    = 'X'.
        GS_FIELDCAT_G-F4AVAILABL = 'X'.
      WHEN 'PAYDA'.
      WHEN 'ZFBDT'.
        GS_FIELDCAT_G-EDIT       = 'X'.
        GS_FIELDCAT_G-COL_OPT    = 'X'.
      WHEN 'VORGX'.
        GS_FIELDCAT_G-COLTEXT    = '트랜잭션'.
        GS_FIELDCAT_G-COL_OPT    = 'X'.
        GS_FIELDCAT_G-COL_POS    = 10.
*--{기능개선_275072 - 추가
      WHEN 'LIFNR2'.
        GS_FIELDCAT_G-COLTEXT    = '공급업체'.
        GS_FIELDCAT_G-OUTPUTLEN  = 10.
        GS_FIELDCAT_G-NO_OUT = 'X'.
      WHEN 'NAME2'.
        GS_FIELDCAT_G-COLTEXT    = '공급업체명'.
        GS_FIELDCAT_G-OUTPUTLEN  = 10.
        GS_FIELDCAT_G-NO_OUT = 'X'.
*--}기능개선_275072 - 2019.04.19

*--}기능개선_290009 - 추가
      WHEN 'BATXT'.
        GS_FIELDCAT_G-COLTEXT    = '구매오더 유형'.
        GS_FIELDCAT_G-OUTPUTLEN  = 10.
        GS_FIELDCAT_G-NO_OUT = 'X'.
*--}기능개선_290009 - 2019.09.02

**-- [CHM2110-00555] 세금계산서 관련 필드 추가  -[s]
      WHEN 'BUTTON'.
        GS_FIELDCAT_G-COLTEXT = '계산서'..
        GS_FIELDCAT_G-ICON      = 'X'.
        GS_FIELDCAT_G-HOTSPOT   = 'X'.
*        IF S_BUKRS-LOW NE 3000.
        GS_FIELDCAT_G-TECH = 'X'.
*        ENDIF.

      WHEN 'INV_SEQ'.
        GS_FIELDCAT_G-COLTEXT = '매입계산서'.
        GS_FIELDCAT_G-COL_OPT    = 'X'.
        IF S_BUKRS-LOW NE 3000 OR P_STEP1 IS NOT INITIAL.
          GS_FIELDCAT_G-TECH = 'X'.
        ENDIF.

      WHEN 'DESC_TEXT1'.
        GS_FIELDCAT_G-COLTEXT    = '계산서비고'.
        GS_FIELDCAT_G-OUTPUTLEN = '40'.
        GS_FIELDCAT_G-COL_OPT    = 'X'.
        IF S_BUKRS-LOW NE 3000 OR P_STEP1 IS NOT INITIAL.
          GS_FIELDCAT_G-TECH = 'X'.
        ENDIF.

      WHEN 'ISSUE_DATE'.
        GS_FIELDCAT_G-COLTEXT = '계산서작성일'.
        GS_FIELDCAT_G-COL_OPT    = 'X'.
        IF S_BUKRS-LOW NE 3000 OR P_STEP1 IS NOT INITIAL.
          GS_FIELDCAT_G-TECH = 'X'.
        ENDIF.
**-- [CHM2110-00555] 세금계산서 관련 필드 추가  -[e]

      WHEN OTHERS.
*        gs_fieldcat_g-col_pos = gs_fieldcat_g-col_pos + 100.
        GS_FIELDCAT_G-NO_OUT = 'X'.
    ENDCASE.


    MODIFY IT_FIELDCAT_G FROM GS_FIELDCAT_G.
  ENDLOOP.

ENDFORM.                    " 3000_field_category_build
*&---------------------------------------------------------------------*
*&      Form  p3800_field_attribute_change
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P3800_FIELD_ATTRIBUTE_CHANGE .

* 각 셀의 특성 제어
  DATA : LT_CELLTAB TYPE LVC_T_STYL,
         L_INDEX    TYPE I,
         P_MODE(01).

  LOOP AT IT_DISP INTO GS_DISP.
    L_INDEX = SY-TABIX.
*> 전표가 입력되었을 경우 입력 불가능
    IF GS_DISP-ICSNO IS INITIAL.
      P_MODE = 'W'.
    ELSE.
      P_MODE = 'O'.
    ENDIF.

    REFRESH LT_CELLTAB.

    PERFORM P3810_FILL_CELLTAB USING    P_MODE
                               CHANGING LT_CELLTAB.

    CLEAR GS_DISP-CELLTAB.
    INSERT LINES OF LT_CELLTAB  INTO TABLE GS_DISP-CELLTAB.
    MODIFY IT_DISP FROM GS_DISP INDEX L_INDEX.
  ENDLOOP.

ENDFORM.                    " p3800_field_attribute_change

*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
FORM P2000_DATA_SELECTIONS .
  DATA: L_ICCSQ  LIKE ZTITCCK-ICCSQ,
        LV_INCO1 LIKE EKKO-INCO1.
  DATA: BEGIN OF LS_BSART,
          BSART LIKE EKKO-BSART,
          BSTYP LIKE EKKO-BSTYP,
        END OF LS_BSART.
*> PROGRESS Display.
  G_LINEN    = 30.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

*> 수입의뢰 데이타 select.
  SELECT *
        INTO CORRESPONDING FIELDS OF TABLE IT_TEMP
        FROM ZTITCCK
        WHERE BUKRS  IN  S_BUKRS
          AND EBELN  IN  S_EBELN
          AND ICCNO  IN  S_ICCNO
          AND CDCNO  IN  S_CDCNO
          AND CDRDT  IN  S_CDRDT
          AND PAYDA  IN  S_PAYDA
          AND CARTY  IN  S_CARTY
          AND CDRDT  IN  S_CDRDT
          AND BUPLA  IN  S_BUPLA
          AND LIFNR  IN  S_LIFNR
          AND EKORG  IN  S_EKORG
          AND EKGRP  IN  S_EKGRP
          AND CDHDT  IN  S_CDHDT
          AND CDADT  IN  S_CDADT
          AND CDCDT  IN  S_CDCDT
          AND CDRNO  IN  S_CDRNO
          AND STATE  IN  S_STATE
          AND CDCOR  IN  S_CDCOR
          AND CDCCH  IN  S_CDCCH
          AND CIMTY  IN  S_CIMTY
          AND CDAPN  IN  S_CDAPN
          AND CIMNM  IN  S_CIMNM
          AND CCONO  IN  S_CCONO
          AND CBLNO  IN  S_CBLNO
          AND CNAM   IN  S_CNAM    "작성인.
          AND CDAT   IN  S_CDAT    "생성일.
          AND UNAM   IN  S_UNAM    "최종변경인.
          AND UDAT   IN  S_UDAT.   "변경일.

  IF SY-SUBRC NE 0.
    MESSAGE S902.   EXIT.
  ENDIF.

  REFRESH: IT_DISP.

  LOOP AT IT_TEMP INTO GS_DISP.

************************************************************
* date     : 20090917
* 요청번호 : C20090902_17722
* 내용     : 구매오더 인도조건 DDP인 경우 관세부과 제외
************************************************************
    CLEAR LV_INCO1.

    IF GS_DISP-EBELN IS NOT INITIAL.

      CLEAR EKKO.
      SELECT SINGLE INCO1 INTO LV_INCO1
        FROM EKKO
       WHERE EBELN = GS_DISP-EBELN.

      IF LV_INCO1 = 'DDP'. "기능개선 318890 - DDP 관세부가세 처리
        IF S_BUKRS-LOW NE '1000'.
          DELETE IT_TEMP.
          CONTINUE.
        ENDIF.
      ENDIF.

    ENDIF.
************************************************************
*>>>>>>> 계정지정범주 로직 추가....
    SELECT *
      FROM EKPO UP TO 1 ROWS
     WHERE EBELN EQ GS_DISP-EBELN
       AND KNTTP IN S_KNTTP.
    ENDSELECT.
    IF SY-SUBRC NE 0.
      CONTINUE.
    ENDIF.

*--{기능개선_275072 - 추가
    GS_DISP-LIFNR2 = GS_DISP-LIFNR.
    SELECT SINGLE NAME1
      FROM LFA1
      INTO GS_DISP-NAME2
     WHERE LIFNR = GS_DISP-LIFNR2.
*--}기능개선_275072 - 2019.04.19

*--{기능개선 290009 - 추가
    CLEAR  LS_BSART.
    SELECT SINGLE BSART BSTYP
      FROM EKKO
      INTO CORRESPONDING FIELDS OF LS_BSART
     WHERE EBELN = GS_DISP-EBELN.

    SELECT SINGLE BATXT
      FROM T161T
      INTO GS_DISP-BATXT
     WHERE BSART = LS_BSART-BSART
       AND BSTYP = LS_BSART-BSTYP
       AND SPRAS = SY-LANGU.
*--} END. 2019.09.02

*   각각의 문서에서 해당하는 데이터의 필드 가져오기.
    LOOP AT IT_ZTITIG06 WHERE BOX = 'X'.

      CLEAR: GS_DISP-FWBAS,
             GS_DISP-WMWST,
             GS_DISP-WRBTR,
             GS_DISP-DMBTR.

*--<<기능개선 318890 - DDP 관세부가세 처리
      IF LV_INCO1 = 'DDP'.
        IF IT_ZTITIG06-CSTCL NE '2'.
          CONTINUE.
        ENDIF.
      ENDIF.
*-->>

*> 계산절차.
      MOVE T005-KALSM  TO  GS_DISP-KALSM.
*> 통화단위.
      MOVE T001-WAERS  TO  GS_DISP-HWAER.

      MOVE: IT_ZTITIG06-EXPCD  TO  GS_DISP-EXPCD,
            IT_ZTITIG06-EXPTX  TO  GS_DISP-EXPTX,
            IT_ZTITIG06-RSBTR  TO  GS_DISP-WRBTR,
            IT_ZTITIG06-BLART  TO  GS_DISP-BLART,
            '1'                TO  GS_DISP-VORGANG,
            'P'                TO  GS_DISP-CSTYP,
*            t001-waers         TO  gs_disp-waers,
            IT_ZTITIG06-MWSKZ  TO  GS_DISP-MWSKZ,
            IT_ZTITIG06-KSCHL  TO  GS_DISP-KSCHL,
            IT_ZTITIG06-CSCTY  TO  GS_DISP-CSCTY,
*            it_ztitig06-cscrt  TO  GS_DISP-CSCRT,
            IT_ZTITIG06-CSTCL  TO  GS_DISP-CSTCL.

*> 관세사.계정/명.
      IF IT_ZTITIG06-CSTCL EQ 'Z'.
        SELECT SINGLE LIFNR
          FROM ZTSTIG3
          INTO (GS_DISP-LIFCC)
         WHERE EPART EQ GS_DISP-STATE
           AND PARTI EQ 'H'.
        IF SY-SUBRC EQ 0.
          SELECT SINGLE NAME1
            INTO GS_DISP-NAMCC
            FROM LFA1
           WHERE LIFNR EQ GS_DISP-LIFCC.

          GS_DISP-LIFNR =  GS_DISP-LIFCC.
          GS_DISP-NAME1 =  GS_DISP-NAMCC.
          GS_DISP-LIFNX =  GS_DISP-NAMCC.
        ELSE.
          CLEAR: GS_DISP-LIFCC, GS_DISP-LIFNX.
        ENDIF.
      ELSEIF IT_ZTITIG06-CSTCL EQ SPACE.
        CLEAR: GS_DISP-LIFCC, GS_DISP-LIFNX,
               GS_DISP-LIFNR, GS_DISP-NAME1.
      ELSE.
*        "세관.계정/명.
*-{CHM2306-00372} 인천 세관 코드 합병 재분리
*-{기능개선 126639 - 인천세관 합병에 따른 변경
*        IF GS_DISP-CDCOR = '040'.
*          GS_DISP-CDCOR = '020'.
*        ENDIF.
*-}기능개선 126639
*-{CHM2306-00372} 인천 세관 코드 합병 재분리
        SELECT SINGLE LIFNR
          FROM ZTSTIG5
          INTO GS_DISP-LIFOR
         WHERE CDCOR EQ GS_DISP-CDCOR.
        IF SY-SUBRC EQ 0.
          SELECT SINGLE NAME1
            FROM LFA1
            INTO GS_DISP-NAMOR
           WHERE LIFNR EQ GS_DISP-LIFOR.

          GS_DISP-LIFNR =  GS_DISP-LIFOR.
          GS_DISP-NAME1 =  GS_DISP-NAMOR.
          GS_DISP-LIFNX =  GS_DISP-NAMOR.
        ELSE.
          CLEAR: GS_DISP-LIFOR, GS_DISP-LIFNX.
        ENDIF.
      ENDIF.

      CASE IT_ZTITIG06-CSTCL.
        WHEN 'B'.
          IF GS_DISP-CARTY NE '33'.
            CONTINUE.
          ENDIF.
        WHEN 'C'.
          IF GS_DISP-CARTY NE '13'.
            CONTINUE.
          ENDIF.
        WHEN 'D'.
          IF GS_DISP-CARTY NE '43'.
            CONTINUE.
          ENDIF.
        WHEN '1'.
          IF GS_DISP-CARTY EQ '13' OR
             GS_DISP-CARTY EQ '33' OR
             GS_DISP-CARTY EQ '43'.
            CONTINUE.
          ENDIF.
      ENDCASE.

      CASE IT_ZTITIG06-CSTCL.
        WHEN 'Z'. "관세사 수수료 cchcg.
*        "금액/통화."wmwst/세액, fwbas/과세표준액미사용.
          MOVE: GS_DISP-CCHCG   TO  GS_DISP-WRBTR,
                GS_DISP-CCUAKC  TO  GS_DISP-WAERS,
                GS_DISP-LIFCC   TO  GS_DISP-LIFNR,
                GS_DISP-NAMCC   TO  GS_DISP-NAME1.
          CLEAR: GS_DISP-FWBAS,
                 GS_DISP-WMWST.

          IF GS_DISP-MWSKZ IS INITIAL.
            CLEAR : GS_DISP-FWBAS, GS_DISP-WMWST.
          ELSE.
            IF GS_DISP-WRBTR IS INITIAL.
              CLEAR : GS_DISP-FWBAS, GS_DISP-WMWST.
            ELSE.
              CALL FUNCTION 'Z_TS_GET_AND_CALC_TAX_AMOUNT' " 세액계산
                EXPORTING
                  IM_TAXTM = SPACE
                  IM_WRBTR = GS_DISP-WRBTR
                  IM_WAERS = GS_DISP-WAERS
                  IM_BUKRS = ZTITIG00-BUKRS
                  IM_MWSKZ = GS_DISP-MWSKZ
                IMPORTING
                  EX_WMWST = GS_DISP-WMWST.            " 변경후 세액

              IF GS_DISP-WMWST IS INITIAL.
                CLEAR: GS_DISP-FWBAS.
              ELSE.
                GS_DISP-FWBAS = GS_DISP-WRBTR.
              ENDIF.
            ENDIF.
          ENDIF.
        WHEN '1' OR 'B' OR 'C' OR 'D'. "관세 cdutx.
*        "금액/통화."wmwst/세액, fwbas/과세표준액미사용.
          MOVE: GS_DISP-CDUTX   TO  GS_DISP-WRBTR,
                GS_DISP-CCUAKC  TO  GS_DISP-WAERS,
                GS_DISP-LIFOR   TO  GS_DISP-LIFNR,
                GS_DISP-NAMOR   TO  GS_DISP-NAME1.

          GS_DISP-WRBTR = GS_DISP-CDUTX + GS_DISP-CSPTX +
                          GS_DISP-CALTX + GS_DISP-CTRTX +
                          GS_DISP-CINTX + GS_DISP-CAGTX +
                          GS_DISP-CLTTX.

* 정정차수가 있는경우 전 차수 신고건과 차이액계산
          IF GS_DISP-ICCSQ > 0.
            L_ICCSQ = GS_DISP-ICCSQ - 1.
            CLEAR ZTITCCK.
            SELECT SINGLE *
              FROM ZTITCCK
             WHERE ICCNO = GS_DISP-ICCNO
               AND ICCSQ = L_ICCSQ.

            GS_DISP-WRBTR = GS_DISP-WRBTR -
                            ( ZTITCCK-CDUTX +
                              ZTITCCK-CSPTX +
                              ZTITCCK-CALTX +
                              ZTITCCK-CTRTX +
                              ZTITCCK-CINTX +
                              ZTITCCK-CAGTX +
                              ZTITCCK-CLTTX ).

            IF GS_DISP-WRBTR < 0.
              GS_DISP-VORGANG = '2'.                 " 대변메모
              GS_DISP-WRBTR = GS_DISP-WRBTR * -1.    " 절대값
            ENDIF.
          ENDIF.
          CLEAR: GS_DISP-FWBAS,
                 GS_DISP-WMWST.


        WHEN '2'. "통관부가세cadtx.
          MOVE: 0               TO  GS_DISP-WRBTR,
                GS_DISP-CADTX   TO  GS_DISP-WMWST,
                GS_DISP-CCUAKC  TO  GS_DISP-WAERS,
                GS_DISP-CTSAK   TO  GS_DISP-FWBAS,
                GS_DISP-LIFOR   TO  GS_DISP-LIFNR,
                GS_DISP-NAMOR   TO  GS_DISP-NAME1.

* 정정차수가 있는경우 전 차수 신고건과 차이액계산
          IF GS_DISP-ICCSQ > 0.
            L_ICCSQ = GS_DISP-ICCSQ - 1.
            CLEAR ZTITCCK.
            SELECT SINGLE *
              FROM ZTITCCK
             WHERE ICCNO = GS_DISP-ICCNO
               AND ICCSQ = L_ICCSQ.

            GS_DISP-WMWST = GS_DISP-WMWST - ZTITCCK-CADTX.
            GS_DISP-FWBAS = GS_DISP-FWBAS - ZTITCCK-CTSAK.

            IF GS_DISP-WMWST < 0.
              GS_DISP-VORGANG = '2'.                 " 대변메모
              GS_DISP-WMWST = GS_DISP-WMWST * -1.    " 절대값
              GS_DISP-FWBAS = GS_DISP-FWBAS * -1.
            ENDIF.
          ENDIF.

*        WHEN '3'. "특소세csptx
**        "금액/통화."wmwst/세액, fwbas/과세표준액미사용.
*          MOVE: GS_DISP-csptx   TO  GS_DISP-wrbtr,
*                GS_DISP-ccuakc  TO  GS_DISP-waers.
*
*        WHEN '4'. "주세 caltx
**        "금액/통화."wmwst/세액, fwbas/과세표준액미사용.
*          MOVE: GS_DISP-caltx   TO  GS_DISP-wrbtr,
*                GS_DISP-ccuakc  TO  GS_DISP-waers.
*
*        WHEN '5'. "교통세 ctrtx
**        "금액/통화."wmwst/세액, fwbas/과세표준액미사용.
*          MOVE: GS_DISP-ctrtx   TO  GS_DISP-wrbtr,
*                GS_DISP-ccuakc  TO  GS_DISP-waers.
*
*        WHEN '6'. "교육세 cintx
**        "금액/통화."wmwst/세액, fwbas/과세표준액미사용.
*          MOVE: GS_DISP-cintx   TO  GS_DISP-wrbtr,
*                GS_DISP-ccuakc  TO  GS_DISP-waers.
*
*        WHEN '7'. "농특세 cagtx
**        "금액/통화."wmwst/세액, fwbas/과세표준액미사용.
*          MOVE: GS_DISP-cagtx   TO  GS_DISP-wrbtr,
*                GS_DISP-ccuakc  TO  GS_DISP-waers.

*        WHEN '8'. "신고지연가산세 clttx
**        "금액/통화."wmwst/세액, fwbas/과세표준액미사용.
*          MOVE: GS_DISP-clttx   TO  GS_DISP-wrbtr,
*                GS_DISP-ccuakc  TO  GS_DISP-waers.
*
        WHEN OTHERS.
          MOVE GS_DISP-CCUAKC  TO  GS_DISP-WAERS.
          CLEAR: GS_DISP-LIFNR, GS_DISP-NAME1.
          IF GS_DISP-ICCSQ > 0.
            CONTINUE.
          ENDIF.
      ENDCASE.

* 트랜잭션/이벤트
      PERFORM  GET_DOMAIN_VALUE_TEXT(ZTIR0000)
                               USING 'MRM_VORGANG'
                                     GS_DISP-VORGANG
                                     GS_DISP-VORGX.

      CLEAR: ZTIVCS00.
      SELECT *
        FROM ZTIVCS00 UP TO 1 ROWS
       WHERE BUKRS   EQ  T001-BUKRS
         AND EXPGR   EQ  IT_ZTITIG06-EXPGR
         AND EXPCD   EQ  IT_ZTITIG06-EXPCD
         AND REFNO   EQ  GS_DISP-ICCNO
         AND AMDSQ   EQ  GS_DISP-ICCSQ.
      ENDSELECT.

      IF SY-SUBRC EQ 0.
        IF P_STEP1 EQ 'X'.
          CONTINUE.
        ENDIF.
*> 비용문서 MOVE
        MOVE :
          ZTIVCS00-ICSNO  TO GS_DISP-ICSNO,  "수입비용 문서번호
*          ztivcs00-icssq  TO gs_disp-icssq,  "비용문서의 품목
          ZTIVCS00-BELNR  TO GS_DISP-BELNR,  "회계전표번호
          ZTIVCS00-GJAHR  TO GS_DISP-GJAHR,  "회계연도
          ZTIVCS00-MONAT  TO GS_DISP-MONAT,  "회계기간
          ZTIVCS00-WRBTR  TO GS_DISP-WRBTRA, "전표통화금액
          ZTIVCS00-WAERS  TO GS_DISP-WAERSA, "통화키
          ZTIVCS00-WMWST  TO GS_DISP-WMWSTA, "전표통화세액
          ZTIVCS00-FWBAS  TO GS_DISP-FWBASA, "전표통화과세표준액
          ZTIVCS00-LIVST  TO GS_DISP-LIVST,  "송장처리 상태
          ZTIVCS00-WRBTR  TO GS_DISP-WRBTR,  "전표통화금액
          ZTIVCS00-WAERS  TO GS_DISP-HWAER,  "통화키
          ZTIVCS00-WMWST  TO GS_DISP-WMWST,  "전표통화세액
          ZTIVCS00-FWBAS  TO GS_DISP-FWBAS,  "전표통화과세표준액
          ZTIVCS00-LIVST  TO GS_DISP-LIVST,  "송장처리 상태
          ZTIVCS00-MWSKZ  TO GS_DISP-MWSKZ,  "세금코드.
          ZTIVCS00-KURSF  TO GS_DISP-KURSF,  "환율
*          ZTIvcs00-MONCT  to GS_DISP-MONCT,  "개월수
*          ZTIvcs00-BGNDT  to GS_DISP-BGNDT,  "시작일자
*          ZTIvcs00-EXPDT  to GS_DISP-EXPDT.  "만기일자

*-[CHM2110-00555]  세금계산서 매핑내역 -[s]
          ZTIVCS00-INV_SEQ       TO GS_DISP-INV_SEQ ,
          ZTIVCS00-ISSUE_DATE    TO GS_DISP-ISSUE_DATE,
          ZTIVCS00-DESC_TEXT1    TO GS_DISP-DESC_TEXT1.
*-[CHM2110-00555]  세금계산서 매핑내역 -[e]

      ELSE.
        IF P_STEP2 EQ 'X'.
          CONTINUE.
        ENDIF.
        CLEAR ZTIVCS00.
      ENDIF.

*> 기존처리된 비용여부 판단.
      CASE GS_DISP-LIVST.
        WHEN 'P'.
          GS_DISP-ICON = ICON_GREEN_LIGHT.
        WHEN 'N'.
          GS_DISP-ICON = ICON_YELLOW_LIGHT.
        WHEN OTHERS.
          GS_DISP-ICON = ICON_RED_LIGHT.
      ENDCASE.

      GS_DISP-KALSM = T005-KALSM.
      GS_DISP-REFNO = GS_DISP-ICCNO.
      GS_DISP-AMDSQ = GS_DISP-ICCSQ.
      GS_DISP-ZFBDT = GS_DISP-CDRDT.
      GS_DISP-DMBTR = GS_DISP-WRBTR.
      GS_DISP-DOCNM = GS_DISP-CDCNO.
*> 관세사 수수료.
      IF IT_ZTITIG06-CSTCL EQ 'Z'.
        IF GS_DISP-CDRDT IS INITIAL.
          CLEAR GS_DISP-ZFBDT.
        ELSE.
          CALL FUNCTION 'LAST_DAY_OF_MONTHS'
            EXPORTING
              DAY_IN            = GS_DISP-CDRDT
            IMPORTING
              LAST_DAY_OF_MONTH = GS_DISP-ZFBDT
            EXCEPTIONS
              DAY_IN_NO_DATE    = 1
              OTHERS            = 2.
          IF SY-SUBRC <> 0.
            MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.
        ENDIF.
      ELSEIF IT_ZTITIG06-CSTCL EQ '1' OR
             IT_ZTITIG06-CSTCL EQ 'B' OR
             IT_ZTITIG06-CSTCL EQ 'C' OR
             IT_ZTITIG06-CSTCL EQ 'D'.
        GS_DISP-ZFBDT = GS_DISP-PAYDA.
      ELSE.
        GS_DISP-ZFBDT = GS_DISP-CDRDT.
      ENDIF.

      IF GS_DISP-WAERS EQ T001-WAERS.
        GS_DISP-DMBTR = GS_DISP-WRBTR.
      ENDIF.


*-[CHM2110-00555]  세금계산서 매핑   -[s]
*      IF S_BUKRS-LOW = 3000.
*        CLEAR: GS_DISP-INV_SEQ, GS_DISP-DESC_TEXT1.
*        SELECT SINGLE INV_SEQ DESC_TEXT1
*          INTO (GS_DISP-INV_SEQ , GS_DISP-DESC_TEXT1)
*          FROM ZMMT0312
*          WHERE ICCNO = GS_DISP-ICCNO
*          AND   EXPCD = GS_DISP-EXPCD
*          AND   BUKRS = GS_DISP-BUKRS.
*        IF SY-SUBRC <> 0 AND GS_DISP-INV_SEQ = ' ' AND
*          IT_ZTITIG06-MWSKZ NE 'V0'. "세금계산서 무관 영세제외.
*          GS_DISP-BUTTON = ICON_CLOSED_FOLDER.
*        ELSE.
*          CLEAR GS_DISP-BUTTON.
*        ENDIF.
*      ENDIF.



*-[CHM2110-00555]  세금계산서 매핑   -[e]


      APPEND GS_DISP TO IT_DISP.
    ENDLOOP.
  ENDLOOP.

  DESCRIBE TABLE IT_DISP LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE S902.   EXIT.
  ENDIF.

ENDFORM.                    " p2000_data_selections
*&---------------------------------------------------------------------*
*&      Form  3010_insert_field_category
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 3010_INSERT_FIELD_CATEGORY  USING  P_SECTION
                                        P_FNAME
                                        P_VALUE.

  DATA L_COL(40).
  FIELD-SYMBOLS <L_FS>.

  IF P_SECTION = 'S'.
    CLEAR GS_FIELDCAT_G.
  ENDIF.

* 속성 MOVE
  CONCATENATE 'GS_FIELDCAT_G-' P_FNAME  INTO L_COL.

  ASSIGN      (L_COL)         TO       <L_FS>.
  MOVE         P_VALUE        TO       <L_FS>.

  IF P_SECTION = 'E'.
    INSERT GS_FIELDCAT_G INTO IT_FIELDCAT_G INDEX 1.
  ENDIF.
*  IF p_section = 'E'.
*    APPEND gs_fieldcat_g TO it_fieldcat_g.
*  ENDIF.
ENDFORM.                    " 3010_insert_field_category


*&---------------------------------------------------------------------*
*&      Module  pbo_scr0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_SCR0100 OUTPUT.
  SET PF-STATUS 'STATUS100'.
  SET TITLEBAR  'T1000' WITH '현황 List'(T10).

  PERFORM CREATE_AND_INIT_CONTROLS_0100.

ENDMODULE.                 " pbo_scr0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  create_and_init_controls_0100
*&---------------------------------------------------------------------*
FORM CREATE_AND_INIT_CONTROLS_0100 .

  IF G_CUSTOM_CONTAINER IS INITIAL.

**   create a custom container control for our alv control
*    CREATE OBJECT g_custom_container
*        EXPORTING
*            container_name = 'CUSTOMER_CONTAINER_0100'.
*
*    CREATE OBJECT g_splitter
*                  EXPORTING parent = g_custom_container
*                            rows    = 1
*                            columns = 1.
*
*    CALL METHOD g_splitter->get_container
*                      EXPORTING row      = 1
*                                column   = 1
*                      RECEIVING container = g_custom_container_1.

* create the docking container
    CREATE OBJECT G_DOCKING
      EXPORTING
        REPID     = SY-REPID
        DYNNR     = SY-DYNNR
        SIDE      = G_DOCKING->DOCK_AT_LEFT
        EXTENSION = 9999.

*   Create an Instance of ALV Control
    CREATE OBJECT G_GRID
      EXPORTING
        I_PARENT = G_DOCKING.

    CALL METHOD G_GRID->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GS_LAYOUT_G
        IS_VARIANT           = GS_VARIANTE
        IT_TOOLBAR_EXCLUDING = IT_EXCLUDE
        IS_PRINT             = GS_PRINT_G
        I_SAVE               = 'A'   " 전체가능유형.
*                                       'U'   " 특정사용자전용.
*                                       'X'   " 광역 전용.
*                                       ' '   " 저장안함.
*       i_default            = 'X'   " 레이아웃 사전셋팅 허용.
*  LAYOUT   Standard   BCALV_GRID_09  참조.
*  is_variant 레이아웃선택/변경/저장/관리 enable
      CHANGING
        IT_SORT              = IT_SORT_G
        IT_FILTER            = IT_FILTER_G
        IT_FIELDCATALOG      = IT_FIELDCAT_G[]
        IT_OUTTAB            = IT_DISP.

    CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
      EXPORTING
        CONTROL = G_GRID.

* set editable cells to ready for input
    CALL METHOD G_GRID->SET_READY_FOR_INPUT
      EXPORTING
        I_READY_FOR_INPUT = 1.

*?.Optionally register ENTER to raise event DATA_CHANGED.
*   (Per default the user may check data by using the check icon).
    CALL METHOD G_GRID->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

    CREATE OBJECT EVENT_RECEIVER.

    SET HANDLER :
          EVENT_RECEIVER->HANDLE_TOOLBAR               FOR G_GRID,
          EVENT_RECEIVER->HANDLE_DATA_CHANGED          FOR G_GRID,
          EVENT_RECEIVER->HANDLE_DATA_CHANGED_FINISHED FOR G_GRID,
          EVENT_RECEIVER->HANDLE_DOUBLE_CLICK          FOR G_GRID,
          EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK         FOR G_GRID,
          EVENT_RECEIVER->HANDLE_USER_COMMAND          FOR G_GRID.

*>.Call method 'set_toolbar_interactive' to raise event TOOLBAR.
    CALL METHOD G_GRID->SET_TOOLBAR_INTERACTIVE.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*// TITLE 지정
    PERFORM P3800_SET_TITLE_TEXT.
** JS전선 회사코드 2007/04 KSH --------------------------------------
  ENDIF.

ENDFORM.                    " create_and_init_controls_0100
*&---------------------------------------------------------------------*
*&      Form  handle_toolbar
*&---------------------------------------------------------------------*
FORM HANDLE_TOOLBAR USING R_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                          R_INTERACTIVE.
*0    Button (normal)
*1    Menu and default button
*2    Menu
*3    Separator
*4    Radio button
*5    Checkbox
*6    Menu entry

  DATA: LS_TOOLBAR  TYPE STB_BUTTON.

* append a separator to normal toolbar
  CLEAR  LS_TOOLBAR.
  MOVE 3                    TO LS_TOOLBAR-BUTN_TYPE.
  APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.

* append an icon to refresh
  CLEAR LS_TOOLBAR.
  MOVE 0                    TO LS_TOOLBAR-BUTN_TYPE.
  MOVE 'REFRESH'            TO LS_TOOLBAR-FUNCTION.
  MOVE ICON_REFRESH         TO LS_TOOLBAR-ICON.
  MOVE 'REFRESH'(120)       TO LS_TOOLBAR-QUICKINFO.
  MOVE SPACE                TO LS_TOOLBAR-DISABLED.
  APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.

* append an icon
  CLEAR LS_TOOLBAR.
  MOVE 0                    TO LS_TOOLBAR-BUTN_TYPE.
  MOVE 'SELECT'             TO LS_TOOLBAR-FUNCTION.
  MOVE ICON_SELECT_ALL      TO LS_TOOLBAR-ICON.
  MOVE '모두 선택'(121)    TO LS_TOOLBAR-QUICKINFO.
  MOVE SPACE                TO LS_TOOLBAR-DISABLED.
  APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.

* append an icon
  CLEAR LS_TOOLBAR.
  MOVE 0                    TO LS_TOOLBAR-BUTN_TYPE.
  MOVE 'DESELECT'           TO LS_TOOLBAR-FUNCTION.
  MOVE ICON_DESELECT_ALL    TO LS_TOOLBAR-ICON.
  MOVE '선택 해제'(122)    TO LS_TOOLBAR-QUICKINFO.
  MOVE SPACE                TO LS_TOOLBAR-DISABLED.
  APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.


* append a separator to normal toolbar
  CLEAR  LS_TOOLBAR.
  MOVE 3                    TO LS_TOOLBAR-BUTN_TYPE.
  APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.
*

* append an icon to show 적하보험문서
  CLEAR LS_TOOLBAR.
  MOVE 0                    TO LS_TOOLBAR-BUTN_TYPE.
  MOVE 'ZTIT402'            TO LS_TOOLBAR-FUNCTION.
  MOVE ICON_PRICE           TO LS_TOOLBAR-ICON.
  MOVE '수정'               TO LS_TOOLBAR-QUICKINFO.
  MOVE '통관비용 수정'      TO LS_TOOLBAR-TEXT.
  MOVE SPACE                TO LS_TOOLBAR-DISABLED.
  APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.

* append an icon to show 적하보험문서
  CLEAR LS_TOOLBAR.
  MOVE 0                    TO LS_TOOLBAR-BUTN_TYPE.
  MOVE 'ZTIT901'            TO LS_TOOLBAR-FUNCTION.
  MOVE ICON_FINANCING       TO LS_TOOLBAR-ICON.
  MOVE '비용전기'           TO LS_TOOLBAR-QUICKINFO.
  MOVE '비용전기'           TO LS_TOOLBAR-TEXT.
  MOVE SPACE                TO LS_TOOLBAR-DISABLED.
  APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.


*  IF P_STEP2 IS INITIAL. " [CHM2110-00555] 세금계산서 매핑 삭제
*    CLEAR LS_TOOLBAR.
*    MOVE 0                    TO LS_TOOLBAR-BUTN_TYPE.
*    MOVE 'ZTIT003'            TO LS_TOOLBAR-FUNCTION.
*    MOVE ICON_CANCEL          TO LS_TOOLBAR-ICON.
*    MOVE ' 매핑 계산서 삭제 '    TO LS_TOOLBAR-QUICKINFO.
*    MOVE ' 매핑 계산서 삭제 '    TO LS_TOOLBAR-TEXT.
*    MOVE SPACE                TO LS_TOOLBAR-DISABLED.
*    APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.
*  ENDIF.



ENDFORM.                    " handle_toolbar

*&--------------------------------------------------------------------*
*&      Form  handle_data_changed
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->ER_DATA_CHAtext
*---------------------------------------------------------------------*
FORM  HANDLE_DATA_CHANGED  USING ER_DATA_CHANGED
                           TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.
  DATA : LS_MOD_CELLS TYPE LVC_S_MODI,
         LS_CELLS     TYPE LVC_S_MODI.

  DATA : L_BOX   TYPE C,
         L_LIFNR LIKE LFA1-LIFNR,
         L_NAME1 LIKE LFA1-NAME1,
         L_WAERS LIKE ZTISCCCS-WAERS,
         L_WRBTR LIKE ZTISCCCS-WRBTR,
         L_FWBAS LIKE ZTISCCCS-FWBAS,
         L_MWSKZ LIKE ZTISCCCS-MWSKZ,
         L_WMWST LIKE ZTISCCCS-WMWST,
         N_WMWST LIKE ZTISCCCS-WMWST. " 계산된세액

  LOOP AT ER_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.

    CLEAR GS_DISP.
    READ TABLE IT_DISP INTO GS_DISP INDEX LS_MOD_CELLS-ROW_ID.
    IF SY-SUBRC NE 0.       CONTINUE.        ENDIF.

    CASE LS_MOD_CELLS-FIELDNAME.
      WHEN 'LIFNR'.
        CALL METHOD ER_DATA_CHANGED->GET_CELL_VALUE
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = 'LIFNR'
          IMPORTING
            E_VALUE     = L_LIFNR.

        IF NOT L_LIFNR IS INITIAL.
          SELECT SINGLE NAME1
            INTO L_NAME1
            FROM LFA1
           WHERE LIFNR = L_LIFNR.

          IF SY-SUBRC <> 0.
            CALL METHOD ER_DATA_CHANGED->ADD_PROTOCOL_ENTRY
              EXPORTING
                I_MSGID     = '0K'
                I_MSGNO     = '000'
                I_MSGTY     = 'E'
                I_MSGV1     = '존재하지 않는 구매처입니다.'
                I_MSGV2     = ' '
                I_MSGV3     = ' '
                I_FIELDNAME = 'LIFNR'
                I_ROW_ID    = LS_MOD_CELLS-ROW_ID.
          ELSE.
            CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
              EXPORTING
                I_ROW_ID    = LS_MOD_CELLS-ROW_ID
                I_FIELDNAME = 'NAME1'
                I_VALUE     = L_NAME1.
          ENDIF.
        ENDIF.

        IF GS_DISP-LIFNR NE L_LIFNR.
          GS_DISP-LIFNR = L_LIFNR.
          GS_DISP-NAME1 = L_NAME1.
          MODIFY IT_DISP FROM GS_DISP INDEX LS_MOD_CELLS-ROW_ID
                                      TRANSPORTING LIFNR NAME1.
        ENDIF.

*> 공급가액을 변경한 경우
      WHEN 'WRBTR'.
        PERFORM GET_INPUT_VALUE   USING  L_WRBTR
                                         L_WMWST
                                         L_FWBAS
                                         L_MWSKZ
                                         L_WAERS
                                         ER_DATA_CHANGED
                                         LS_MOD_CELLS.

        IF GS_DISP-CSTCL = ' ' OR          " 기타비용
           GS_DISP-CSTCL = 'Z'.            " 관세사수수료
*> 세액을 입력하지 않고 공급가액과 세액코드를 입력한경우
          IF NOT L_MWSKZ IS INITIAL.
*                 l_wmwst IS INITIAL.
            CALL FUNCTION 'Z_TS_GET_AND_CALC_TAX_AMOUNT'
              EXPORTING
                IM_TAXTM = SPACE
                IM_WRBTR = L_WRBTR
                IM_WAERS = L_WAERS
                IM_BUKRS = ZTITIG00-BUKRS
                IM_MWSKZ = L_MWSKZ
              IMPORTING
                EX_WMWST = N_WMWST.
          ENDIF.

          IF L_WMWST <> N_WMWST.
            MESSAGE I999 WITH '세액과 과세표준액이 변경됩니다.'.
          ENDIF.

          CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = 'WMWST'
              I_VALUE     = N_WMWST.

*> 계산된 세액이 있고 과세표준액이 없는경우 과세표준액을
*> 공급가액으로 대체
*          IF NOT n_wmwst IS INITIAL AND
*             NOT l_wrbtr IS INITIAL AND
*                 l_fwbas IS INITIAL.
*
          CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = 'FWBAS'
              I_VALUE     = L_WRBTR.
*          ENDIF.

*> Check Box Marking Logic
*> 종류가 관세사 수수료,기타비용인 경우엔 세액이 계산된 경우만
*> 그외의 비용은 공급가액 변경시(금액이 있는경우만 MARK,없으면 해제)
          IF L_WRBTR IS INITIAL.
            CLEAR L_BOX.
          ELSE.
            L_BOX = 'X'.
          ENDIF.

          CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = 'BOX'
              I_VALUE     = L_BOX.
        ELSE.
          IF L_WRBTR IS INITIAL.
            CLEAR L_BOX.
          ELSE.
            L_BOX = 'X'.
          ENDIF.

          CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = 'BOX'
              I_VALUE     = L_BOX.
        ENDIF.

        IF GS_DISP-WRBTR NE L_WRBTR.
          GS_DISP-WRBTR = L_WRBTR.
          MODIFY IT_DISP FROM GS_DISP INDEX LS_MOD_CELLS-ROW_ID
                                      TRANSPORTING WRBTR.
        ENDIF.

*> 과세표준액 변경시 세액재계산
      WHEN 'FWBAS'.
        PERFORM GET_INPUT_VALUE   USING  L_WRBTR
                                         L_WMWST
                                         L_FWBAS
                                         L_MWSKZ
                                         L_WAERS
                                         ER_DATA_CHANGED
                                         LS_MOD_CELLS.

        IF NOT L_MWSKZ IS INITIAL.
          CALL FUNCTION 'Z_TS_GET_AND_CALC_TAX_AMOUNT'   " 세액계산
            EXPORTING
              IM_TAXTM = SPACE
              IM_WRBTR = L_FWBAS
              IM_WAERS = L_WAERS
              IM_BUKRS = ZTITIG00-BUKRS
              IM_MWSKZ = L_MWSKZ
            IMPORTING
              EX_WMWST = N_WMWST.

          IF L_WMWST <> N_WMWST.
            MESSAGE I999 WITH '세액이 변경됩니다.'.
            CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
              EXPORTING
                I_ROW_ID    = LS_MOD_CELLS-ROW_ID
                I_FIELDNAME = 'WMWST'
                I_VALUE     = N_WMWST.

            IF N_WMWST IS INITIAL.
              CLEAR L_BOX.
            ELSE.
              L_BOX = 'X'.
            ENDIF.

            CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
              EXPORTING
                I_ROW_ID    = LS_MOD_CELLS-ROW_ID
                I_FIELDNAME = 'BOX'
                I_VALUE     = L_BOX.
          ENDIF.
        ENDIF.

        IF GS_DISP-FWBAS NE L_FWBAS.
          GS_DISP-FWBAS =  L_FWBAS.
          MODIFY IT_DISP FROM GS_DISP INDEX LS_MOD_CELLS-ROW_ID
                                      TRANSPORTING FWBAS.
        ENDIF.

* 세금코드 변경시 세액 재계산
      WHEN 'MWSKZ'.
        PERFORM GET_INPUT_VALUE   USING  L_WRBTR
                                         L_WMWST
                                         L_FWBAS
                                         L_MWSKZ
                                         L_WAERS
                                         ER_DATA_CHANGED
                                         LS_MOD_CELLS.

        IF NOT L_MWSKZ IS INITIAL.
          IF L_FWBAS IS INITIAL.
            L_FWBAS = L_WRBTR.
            CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
              EXPORTING
                I_ROW_ID    = LS_MOD_CELLS-ROW_ID
                I_FIELDNAME = 'FWBAS'
                I_VALUE     = L_FWBAS.

          ENDIF.

          CALL FUNCTION 'Z_TS_GET_AND_CALC_TAX_AMOUNT'
            EXPORTING
              IM_TAXTM = SPACE
              IM_WRBTR = L_FWBAS
              IM_WAERS = L_WAERS
              IM_BUKRS = ZTITIG00-BUKRS
              IM_MWSKZ = L_MWSKZ
            IMPORTING
              EX_WMWST = N_WMWST.

          IF L_WMWST <> N_WMWST.
            MESSAGE I999 WITH '세액이 변경됩니다.'.
          ENDIF.

          CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = 'WMWST'
              I_VALUE     = N_WMWST.

          IF N_WMWST IS INITIAL.
            CLEAR L_BOX.
          ELSE.
            L_BOX = 'X'.
          ENDIF.

          CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = 'BOX'
              I_VALUE     = L_BOX.
        ENDIF.

        IF GS_DISP-MWSKZ NE L_MWSKZ.
          GS_DISP-MWSKZ =  L_MWSKZ.
          GS_DISP-WMWST =  L_WMWST.
          MODIFY IT_DISP FROM GS_DISP INDEX LS_MOD_CELLS-ROW_ID
                                      TRANSPORTING MWSKZ WMWST.
        ENDIF.

    ENDCASE.
  ENDLOOP.


** ICON/CHECK BOX 변경
*  PERFORM 1100_icon_checkbox_part.
*  -->  gt_display-icon  = icon_green_light.
*       gt_display-icon  = icon_yellow_light.
*
*  CALL METHOD rr_data_changed->modify_cell
*              EXPORTING i_row_id    = rs_mod_cells-row_id
*                        i_fieldname = 'ICON'
*                        i_value     = gt_display-icon.
ENDFORM.                    "handle_data_changed

*&---------------------------------------------------------------------*
*&      Form  handle_data_changed_finished
*&---------------------------------------------------------------------*
FORM  HANDLE_DATA_CHANGED_FINISHED   USING P_MODIFIED
                                           P_SENDER.

*  DATA lt_rows     TYPE lvc_t_row.
*  DATA l_row_id    TYPE lvc_s_row.
*  DATA l_col_id    TYPE lvc_s_col.
*  DATA ls_stable   TYPE lvc_s_stbl.
*  DATA l_control   TYPE REF TO cl_gui_control.
*  DATA l_row_no    TYPE lvc_s_roid.
*  DATA lt_roid     TYPE lvc_t_roid.
*  DATA l_row       TYPE i.
*  DATA l_col       TYPE i.
*  DATA l_end_pos   TYPE i.
*  DATA l_start_pos TYPE i.
*
*  CHECK NOT p_modified IS INITIAL.
*
** keep in mind selected rows
*  REFRESH lt_rows.
*  CALL METHOD g_grid->get_selected_rows
*    IMPORTING
*      et_index_rows = lt_rows.
*
*  IF lt_rows[] IS INITIAL.
*    CALL METHOD g_grid->get_focus
*      IMPORTING
*        control           = l_control
*      EXCEPTIONS
*        cntl_error        = 1
*        cntl_system_error = 2
*        OTHERS            = 3.
** Flush now to avoid a system_pointer_pending dump.
*    CALL METHOD cl_gui_cfw=>flush.
*    IF sy-subrc = 0 AND
*       l_control = g_grid.
*      CALL METHOD g_grid->get_current_cell
*        IMPORTING
*          es_row_no = l_row_no
*          es_row_id = l_row_id
*          es_col_id = l_col_id
*          e_row     = l_row
*          e_col     = l_col.
*
** Flush now to avoid a system_pointer_pending dump.
*      CALL METHOD cl_gui_cfw=>flush.
*    ENDIF.
*  ENDIF.
*
*  CALL METHOD g_grid->refresh_table_display
*    EXPORTING
*      is_stable = ls_stable.
*
*  IF lt_rows[] IS INITIAL.
*    CALL METHOD g_grid->set_focus
*      EXPORTING
*        control = l_control.
** Flush now to avoid a system_pointer_pending dump.
*    CALL METHOD cl_gui_cfw=>flush.
*
*    IF sy-subrc  = 0       AND
*       l_control = g_grid.
*
*      l_start_pos = 1.
*      l_end_pos   = 1.
*
*      APPEND l_row_no TO lt_roid.
*
*      CALL METHOD g_grid->set_selected_rows
*        EXPORTING
**          IT_INDEX_ROWS            =
*          it_row_no                = lt_roid
**          IS_KEEP_OTHER_SELECTIONS =
*          .
*
** Flush now to avoid a system_pointer_pending dump.
*      CALL METHOD cl_gui_cfw=>flush.
*    ENDIF.
*  ELSE.
** reset selected rows
*    CALL METHOD g_grid->set_selected_rows
*      EXPORTING
*        it_index_rows = lt_rows.
*  ENDIF.
**   flush
*  CALL METHOD cl_gui_cfw=>flush.

ENDFORM.                    "handle_data_changed_finished

*&---------------------------------------------------------------------*
*&      Form  handle_double_click
*&---------------------------------------------------------------------*
FORM HANDLE_DOUBLE_CLICK  USING  P_ROW P_COLUMN.

  DATA: L_DATATYPE    LIKE DD01V-DATATYPE.

  CALL FUNCTION 'Z_TI_NUMBER_CHECK'
    EXPORTING
      STRING_IN  = P_ROW
    IMPORTING
      STRING_OUT = P_ROW
      HTYPE      = L_DATATYPE.

  CHECK L_DATATYPE EQ 'NUMC'.

  READ TABLE IT_DISP INTO GS_DISP INDEX  P_ROW.

  CASE P_COLUMN.
    WHEN 'ICCNO'.
      PERFORM DISPLAY_CC_DOCUMENT(ZTIR0000)
                                      USING GS_DISP-ICCNO
                                            '00000'.

    WHEN 'ICSNO'.
      PERFORM DISPLAY_CS_DOCUMENT(ZTIR0000)
                                      USING GS_DISP-ICSNO
                                      '1000'.
  ENDCASE.

ENDFORM.                    "handle_double_click
*&---------------------------------------------------------------------*
*&      Form  handle_hotspot_click
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK  USING E_ROW_ID    TYPE LVC_S_ROW
                                 E_COLUMN_ID TYPE LVC_S_COL.

  READ TABLE IT_DISP INTO GS_DISP INDEX E_ROW_ID-INDEX.

  CASE E_COLUMN_ID-FIELDNAME.
    WHEN 'ICCNO'.
      PERFORM DISPLAY_CC_DOCUMENT(ZTIR0000)
                                      USING GS_DISP-ICCNO
                                            '00000'.

    WHEN 'ICSNO'.
      PERFORM DISPLAY_CS_DOCUMENT(ZTIR0000)
                                      USING GS_DISP-ICSNO
                                      '1000'.

*    WHEN 'BUTTON'. " [CHM2110-00555] 세금계산서 매핑
*      CHECK GS_DISP-BUTTON = ICON_CLOSED_FOLDER.
*      PERFORM CHOOSE_ETAX_UNMATCH  USING E_ROW_ID-INDEX .


    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    "_hotspot_click
*&---------------------------------------------------------------------*
*&      Form  handle_user_command_grid
*&---------------------------------------------------------------------*
FORM HANDLE_USER_COMMAND_GRID USING R_UCOMM.

  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
    EXPORTING
      NEW_CODE = R_UCOMM.

  IF R_UCOMM EQ 'SELECT'.
    PERFORM  SET_SELECTED_ROW USING 'X'.
    EXIT.
  ELSEIF R_UCOMM EQ 'DESELECT'.
    PERFORM  SET_SELECTED_ROW USING ' '.
    EXIT.
  ELSEIF R_UCOMM EQ 'REFRESH'.
    PERFORM REFRESH_CONFIRM USING G_ANSWER.
    CHECK G_ANSWER = 'J'.

    PERFORM P2000_DATA_SELECTIONS.
    PERFORM 3000_FIELD_CATEGORY_BUILD.
    PERFORM P3800_FIELD_ATTRIBUTE_CHANGE.
    PERFORM P9000_REFRESH_DISPLAY.
  ENDIF.

*  DATA: l_valid TYPE c,
*        lt_row_no TYPE lvc_t_roid WITH HEADER LINE.
*  DATA: l_subrc   LIKE sy-subrc,
*        l_text_amout(20).
*
*  REFRESH: bdcdata, it_msg.
*  CLEAR: session.
*  ctu_params-dismode  = 'N'. ">처리모드n
*  ctu_params-updmode  = 'S'. ">갱신모드
*  ctu_params-cattmode = ' '. ">CATT 모드...
*  ctu_params-defsize  = ' '. ">기본화면 크기
*  ctu_params-racommit = 'X'.
*  ctu_params-nobinpt  = 'X' .
*  ctu_params-nobiend  = 'X'.
*
*  CLEAR g_count.
*  IF r_ucomm EQ 'ZTIT402' OR
*     r_ucomm EQ 'ZTIT901' OR
*     r_ucomm EQ 'ZTIT901S'.
*    PERFORM  get_selected_row  TABLES lt_row_no.
*  ELSEIF r_ucomm EQ 'SELECT'.
*    PERFORM  set_selected_row USING 'X'.
*    EXIT.
*  ELSEIF r_ucomm EQ 'DESELECT'.
*    PERFORM  set_selected_row USING ' '.
*    EXIT.
*  ENDIF.
*
*  CHECK g_count GT 0.
*
*  CASE r_ucomm.
*    WHEN 'ZTIT402'.
**> 보험료 정보를 Update.
*      PERFORM  modify_customs_table.
*
*    WHEN 'ZTIT901'.
**> 전표전기 종류 선택 함수(월합계산서 or 개별전표)
*      IF g_count EQ 1.
*        ztisscrcom-monsc = 'S'.
*      ELSE.
*        CALL FUNCTION 'Z_TI_COST_DOCUMENT_TYPE_POPUP'
*          IMPORTING
*            p_answer = g_answer
*            p_monsc  = ztisscrcom-monsc.
*
*        CHECK g_answer EQ 'Y'.
*      ENDIF.
*      CLEAR: g_count, g_wrbtr, g_wmwst, g_fwbas, ztisscrcom-itcnt.
*      REFRESH: it_vendor.
*
**> 데이타 체크.
*      LOOP AT it_disp INTO gs_disp WHERE box = 'X'.
*        CLEAR: gs_disp-errmd.
*
*        MOVE: gs_disp-lifnr  TO  it_vendor-lifnr.
*        COLLECT it_vendor.
*
*        IF gs_disp-lifnr IS INITIAL.
*          gs_disp-errmd = 'X'.
*          MESSAGE s508 WITH gs_disp-iccno 'Vnedor'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF NOT gs_disp-icsno IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          IF NOT GS_DISP-belnr IS INITIAL.
*            MESSAGE s132 WITH gs_disp-iccno ' ' '전기'.
*          ELSE.
*            MESSAGE s132 WITH gs_disp-iccno ' ' '생성'.
*          ENDIF.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF gs_disp-wrbtr IS INITIAL AND
*           gs_disp-wmwst IS INITIAL.
*          gs_disp-errmd = 'X'.
*          MESSAGE s508 WITH gs_disp-iccno  '통관비용 및 부가세'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF NOT gs_disp-wmwst IS INITIAL AND
*               gs_disp-fwbas IS INITIAL.
*          gs_disp-errmd = 'X'.
*          MESSAGE s508 WITH gs_disp-iccno '과세표준액'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF gs_disp-waers IS INITIAL.
*          gs_disp-errmd = 'X'.
*          MESSAGE s508 WITH gs_disp-iccno '통화'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        ADD 1 TO ztisscrcom-itcnt.
*        ADD gs_disp-wrbtr TO g_wrbtr.
*        ADD gs_disp-wmwst TO g_wmwst.
*        ADD gs_disp-fwbas TO g_fwbas.
*        MODIFY it_disp FROM gs_disp.
*      ENDLOOP.
*
**> 합계전표일 경우 Vendor 등을 체크함.
*      IF ztisscrcom-monsc EQ 'S'.
*        DESCRIBE TABLE it_vendor LINES g_line.
*        CASE g_line.
*          WHEN 0.
*            MESSAGE s509.
*            PERFORM set_return_message_fill USING 'E'.
*          WHEN 1.
*          WHEN OTHERS.
*            MESSAGE s510.
*            PERFORM set_return_message_fill USING 'E'.
*        ENDCASE.
**> Error Message Display.
*        PERFORM display_error_message.
*        DESCRIBE TABLE it_msg LINES g_line.
*        CHECK g_line EQ 0.
*      ENDIF.
*
**> 전기확인용 대화화면 Call
*      CLEAR: ok_code.
**> 전기용 HEADER DATA Fill
*      PERFORM   fill_default_header_data.
***> 확인 대화상자 Call
*      CALL SCREEN '0200' STARTING AT 1 8.
*      IF ok_code EQ 'ABBR'.
*        MESSAGE s900.
*        EXIT.
*      ELSEIF ok_code EQ 'SIMU'.
*        ctu_params-dismode  = 'E'. ">처리모드
*      ENDIF.
*      CLEAR: g_success, g_error.
*
**> 통관비용 정보를 Update.
*      PERFORM modify_customs_table.
*      IF ztisscrcom-monsc EQ 'S'.
*        PERFORM execute_collective_posting.
*      ELSE.
*        PERFORM execute_individual_posting.
*      ENDIF.
*  ENDCASE.
*
**> Error Message Display.
*  PERFORM display_error_message.
*
**> 검색조건에 해당하는 데이타를 Select.
*  CHECK g_success GT 0.
*  PERFORM p2000_data_selections.
*  PERFORM 3000_field_category_build.
*  PERFORM p3800_field_attribute_change.
**  PERFORM p9000_refresh_display.
*  CALL METHOD g_grid->refresh_table_display.

ENDFORM.                    "handle_user_command_grid
*&---------------------------------------------------------------------*
*&      Form  3210_exclude_table_build
*&---------------------------------------------------------------------*
FORM 3210_EXCLUDE_TABLE_BUILD USING P_TABNAME.

*  툴바의 버튼중 나타내지 않을 버튼을 지정한다.
  FIELD-SYMBOLS : <TABLE> TYPE UI_FUNCTIONS.

  DATA : LS_EXCLUDE   TYPE UI_FUNC.
  DATA : L_TABLE_NAME LIKE FELD-NAME.

  CONCATENATE P_TABNAME '[]' INTO  L_TABLE_NAME.
  ASSIGN     (L_TABLE_NAME)    TO <TABLE>.

  PERFORM APPEND_EXCLUDE_FUNCTIONS
        TABLES <TABLE>
*        USING : cl_gui_alv_grid=>mc_fc_excl_all. " ** 툴바 모두제거 **
         USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO, " 실행취소 &LOCAL&UNDO
*                cl_gui_alv_grid=>mc_fc_auf,      " 소계확장 &AUF
*                cl_gui_alv_grid=>mc_fc_average,  " &AVERAGE
*                cl_gui_alv_grid=>mc_fc_back_classic,
*                cl_gui_alv_grid=>mc_fc_call_abc, " &ABC
*                cl_gui_alv_grid=>mc_fc_call_chain,
*                cl_gui_alv_grid=>mc_fc_call_crbatch,
*                cl_gui_alv_grid=>mc_fc_call_crweb,
*                cl_gui_alv_grid=>mc_fc_call_lineitems,
*                cl_gui_alv_grid=>mc_fc_call_master_data,
*                cl_gui_alv_grid=>mc_fc_call_more,
*                cl_gui_alv_grid=>mc_fc_call_report,
*                cl_gui_alv_grid=>mc_fc_call_xint,
*                cl_gui_alv_grid=>mc_fc_call_xxl,
*                cl_gui_alv_grid=>mc_fc_col_invisible,
*                cl_gui_alv_grid=>mc_fc_col_optimize,
*                cl_gui_alv_grid=>mc_fc_current_variant,
*                cl_gui_alv_grid=>mc_fc_data_save,
*                cl_gui_alv_grid=>mc_fc_delete_filter,
*                cl_gui_alv_grid=>mc_fc_deselect_all,
*                cl_gui_alv_grid=>mc_fc_detail,
*                cl_gui_alv_grid=>mc_fc_expcrdata,
*                cl_gui_alv_grid=>mc_fc_expcrdesig,
*                cl_gui_alv_grid=>mc_fc_expcrtempl,
*                cl_gui_alv_grid=>mc_fc_expmdb,
*                cl_gui_alv_grid=>mc_fc_extend,
*                cl_gui_alv_grid=>mc_fc_f4,
*                cl_gui_alv_grid=>mc_fc_filter,
*                cl_gui_alv_grid=>mc_fc_find,
*                cl_gui_alv_grid=>mc_fc_fix_columns,
*                cl_gui_alv_grid=>mc_fc_graph,
*                cl_gui_alv_grid=>mc_fc_help,
*                cl_gui_alv_grid=>mc_fc_info,
*                cl_gui_alv_grid=>mc_fc_load_variant,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,          " 행 카피.
*                cl_gui_alv_grid=>mc_fc_html,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,      " 행 카피.
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,           " 가위.
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,    " 행삭제.
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,    " 행삽입.
                CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,    " 라인생성.
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,         " 겹쳐쓰기.
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW. " 겹쳐쓰기.
*                cl_gui_alv_grid=>mc_fc_refresh.           " Refresh

*                cl_gui_alv_grid=>mc_fc_maintain_variant,
*                cl_gui_alv_grid=>mc_fc_maximum,
*                cl_gui_alv_grid=>mc_fc_minimum,
*                cl_gui_alv_grid=>mc_fc_pc_file,
*                cl_gui_alv_grid=>mc_fc_print,
*                cl_gui_alv_grid=>mc_fc_print_back,
*                cl_gui_alv_grid=>mc_fc_print_prev,
*                cl_gui_alv_grid=>mc_fc_reprep,
*                cl_gui_alv_grid=>mc_fc_save_variant,
*                cl_gui_alv_grid=>mc_fc_select_all,
*                cl_gui_alv_grid=>mc_fc_send,
*                cl_gui_alv_grid=>mc_fc_separator,
*                cl_gui_alv_grid=>mc_fc_sort,
*                cl_gui_alv_grid=>mc_fc_sort_asc,
*                cl_gui_alv_grid=>mc_fc_sort_dsc,
*                cl_gui_alv_grid=>mc_fc_subtot,
*                cl_gui_alv_grid=>mc_fc_sum,
*                cl_gui_alv_grid=>mc_fc_to_office,
*                cl_gui_alv_grid=>mc_fc_to_rep_tree,
*                cl_gui_alv_grid=>mc_fc_unfix_columns,
*                cl_gui_alv_grid=>mc_fc_views,
*                cl_gui_alv_grid=>mc_fc_view_crystal,
*                cl_gui_alv_grid=>mc_fc_view_excel,
*                cl_gui_alv_grid=>mc_fc_view_grid,
*                cl_gui_alv_grid=>mc_fc_word_processor.

ENDFORM.                    " 3210_exclude_table_build
*&---------------------------------------------------------------------*
*&      Form  3700_layout_build
*&---------------------------------------------------------------------*
FORM 3700_LAYOUT_BUILD .

** General display options
*  gs_layout_g-cwidth_opt = 'X'.
  GS_LAYOUT_G-SMALLTITLE = 'X'.
*  gs_layout_g-box_fname  = 'BOX'.
* ICON.
*      gs_layout_g-excp_fname = g_lights_name.

** Grid customizing
* Title between grid control and toolbar(70자 이내)
* GS_LAYOUT_G-grid_title = '프로그램 LIST'.

** Column headers are hidden
* GS_LAYOUT_G-no_headers = 'X'.

** Columns are displayed without horizontal grid lines
* GS_LAYOUT_G-no_hgridln = 'X'.
*
** Cells are not merged when a column is sorted
* GS_LAYOUT_G-no_merging = ' '.

* the button at the beginning of a row is hidden in selection modes
* cell selection ( SEL_MODE = 'D' ) and column/row selection
* ( SEL_MODE = 'A' ).
  GS_LAYOUT_G-NO_ROWMARK = 'A'. "(or 'X')

* Selection modes for SEL_MODE
* 'A' : Column and row selection
* 'B' : Simple selection, list box
* 'C' : Multiple selection, list box
* 'D' : Cell selection
*  gs_layout_g-sel_mode = 'C'.
* If this field is set, the toolbar is hidden.
* GS_LAYOUT_G-no_toolbar = 'X'.

* columns are displayed without vertical grid lines
* GS_LAYOUT_G-no_vgridln = 'X'.

* In case of PRINT_END_OF_PAGE, you must set 'reservelns' to
* the number of reserved lines at the end of a page.
* reserve two lines for the PRINT_END_OF_PAGE event
* p_print-reservelns = 2.

* Standard(BCALV_EDIT_01)에서는 다음과 같이 했다.
* Set status of all cells to editable using the layout structure.
* 옵션에 안보이던데... 어째껀 수정모드로 바꾸는 중요한 옵션이다.
*  IF g_mode = c_display.
*    GS_LAYOUT_G-edit = ' '.
*  ELSEIF g_mode = c_edit.
*    GS_LAYOUT_G-edit = 'X'.
*  ENDIF.

* Provide the fieldname of the celltab field by using field
* STYLEFNAME of the layout structure.

  GS_LAYOUT_G-STYLEFNAME = 'CELLTAB'.

* 합을 제일 윗라인에 DISPLAY
*  gs_layout_g-totals_bef = 'X'.

ENDFORM.                    " 3700_layout_build
*&---------------------------------------------------------------------*
*&      Form  append_exclude_functions
*&---------------------------------------------------------------------*
FORM APPEND_EXCLUDE_FUNCTIONS  TABLES P_TABLE
                               USING  P_VALUE.

  DATA : LS_EXCLUDE TYPE UI_FUNC.
  LS_EXCLUDE = P_VALUE.
  APPEND LS_EXCLUDE TO P_TABLE.

ENDFORM.                    " append_exclude_functions
*&---------------------------------------------------------------------*
*&      Module  pai_scr0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_SCR0100 INPUT.

  DATA : LV_ERR_CHK.

  CALL METHOD G_GRID->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = G_VALID.

  CLEAR G_COUNT.

  IF SY-UCOMM EQ 'ZTIT402' OR
     SY-UCOMM EQ 'ZTIT901' OR
     SY-UCOMM EQ 'ZTIT901S'.
    PERFORM  GET_SELECTED_ROW  TABLES GT_ROW_NO.
  ENDIF.

  CASE SY-UCOMM.
    WHEN 'EXIT' OR 'CANC' OR 'BACK'.
      IF G_GRID IS INITIAL.
        CALL METHOD G_GRID->FREE.
      ENDIF.

      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'ZTIT402'.
*> 면장 정보를 Update.
      PERFORM  MODIFY_CUSTOMS_TABLE.
    WHEN 'ZTIT901'.
      CHECK G_COUNT GT 0.
*> Clearing
      PERFORM  SET_POSTING_DATA_INITIAL.
*> 전기유형 선택.
      PERFORM  GET_POSTING_TYPE   USING G_COUNT
                                        ZTISSCRCOM-MONSC  G_ANSWER.
*> 전기용 데이타 Collect.
      PERFORM  BUILD_POSTING_DATA.
*> Error Message Display.
      PERFORM DISPLAY_ERROR_MESSAGE.
      CHECK G_LINE EQ 0.

*> 전기확인용 대화화면 Call
      CLEAR: OK_CODE.
*> 전기용 HEADER DATA Fill
      PERFORM   FILL_POSTING_DATA.

*> 비용전기용 공통 함수.
      PERFORM   BUILD_FI_DOCUMENT USING 'C'
                                        ZTISSCRCOM-MONSC.
*> 검색조건에 해당하는 데이타를 Select.
*      BREAK-POINT.

      CHECK G_SUCCESS GT 0.

** [CHM2110-00555] 전자세금계산서 미대사건데이타를 선택하여
** 전표입력시에는 전기후 미대사여부를 대사완료로 변경해줘야 함
*      PERFORM SET_ZDTV3T_AP_EXT_USE_DOC.

*> 검색조건에 해당하는 데이타를 Select.
      PERFORM P2000_DATA_SELECTIONS.
      PERFORM 3000_FIELD_CATEGORY_BUILD.
      PERFORM P3800_FIELD_ATTRIBUTE_CHANGE.
      CALL METHOD G_GRID->REFRESH_TABLE_DISPLAY.

    WHEN 'ZTIT003'.     "[CHM2110-00555] 세금계산서 매핑 삭제
      CLEAR LV_ERR_CHK.

      LOOP AT IT_DISP INTO GS_DISP WHERE BOX = 'X'.
        IF GS_DISP-ICON = ICON_GREEN_LIGHT.
          LV_ERR_CHK  = 'X'.
          MESSAGE S999 WITH '이미 처리된 내역이 있습니다'.
          EXIT.
        ENDIF.

        IF GS_DISP-INV_SEQ IS INITIAL.
          LV_ERR_CHK  = 'X'.
          MESSAGE S999 WITH '매핑되지 않은 내역이 있습니다.'.
          EXIT.
        ENDIF.

      ENDLOOP.

      IF SY-SUBRC NE 0.
        MESSAGE S999 WITH '매핑 삭제할 라인을 선택해주세요'.
        EXIT.
      ENDIF.

      CHECK LV_ERR_CHK IS INITIAL .

      LOOP AT IT_DISP INTO GS_DISP WHERE BOX = 'X'.

        DELETE  GT_ZMMT0312 WHERE BUKRS   = S_BUKRS-LOW
                              AND ICCNO   = GS_DISP-ICCNO
                              AND EXPCD   = GS_DISP-EXPCD
                              AND INV_SEQ = GS_DISP-INV_SEQ.

        GS_DISP-BUTTON = ICON_CLOSED_FOLDER.

        CLEAR : GS_DISP-INV_SEQ, GS_DISP-WRBTR,
                GS_DISP-WMWST,   GS_DISP-FWBAS,
                GS_DISP-DESC_TEXT1, GS_DISP-BOX.

        MODIFY IT_DISP FROM GS_DISP .

      ENDLOOP.

      PERFORM P9000_REFRESH_DISPLAY.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " pai_scr0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  3500_sort_table_build
*&---------------------------------------------------------------------*
FORM 3500_SORT_TABLE_BUILD .

* it_sort_g    TYPE lvc_t_sort.

*  CLEAR gs_sort_g.
*  gs_sort_g-spos      = '01'.
*  gs_sort_g-fieldname = 'ICCNO'.
*  gs_sort_g-up        = 'X'.
**  gs_sort_g-LEVEL     =  1.
**  gs_sort_g-GROUP     = 'X'.
*  APPEND gs_sort_g TO it_sort_g.
*
*
*  CLEAR gs_sort_g.
*  gs_sort_g-spos      = '02'.
*  gs_sort_g-fieldname = 'CDCNO'.
*  gs_sort_g-up        = 'X'.
*  gs_sort_g-subtot    = 'X'.
*  APPEND gs_sort_g TO it_sort_g.
*
*  CLEAR gs_sort_g.
*  gs_sort_g-spos      = '03'.
*  gs_sort_g-fieldname = 'CDRDT'.
*  gs_sort_g-up        = 'X'.
*  APPEND gs_sort_g TO it_sort_g.
*
  CLEAR GS_SORT_G.
  GS_SORT_G-SPOS      = '01'.
  GS_SORT_G-FIELDNAME = 'LIFNR'.
  GS_SORT_G-UP        = 'X'.
  GS_SORT_G-SUBTOT    = 'X'.
  APPEND GS_SORT_G TO IT_SORT_G.

  CLEAR GS_SORT_G.
  GS_SORT_G-SPOS      = '02'.
  GS_SORT_G-FIELDNAME = 'EXPCD'.
  GS_SORT_G-UP        = 'X'.
  GS_SORT_G-SUBTOT    = 'X'.
  APPEND GS_SORT_G TO IT_SORT_G.

  CLEAR GS_SORT_G.
  GS_SORT_G-SPOS      = '03'.
  GS_SORT_G-FIELDNAME = 'ICCNO'.
  GS_SORT_G-UP        = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
  APPEND GS_SORT_G TO IT_SORT_G.

*SPOS	정렬순서
*FIELDNAME  ALV 제어: 내부테이블필드의 필드이름
*UP	단일문자 플래그
*DOWN	단일문자 플래그
*GROUP  제어중단: 페이지구분삽입, 밑줄
*SUBTOT	출력소계
*COMP	단일문자 플래그
*EXPA	단일문자 플래그
*SELTEXT  정렬기준
*OBLIGATORY	단일문자 플래그
*LEVEL  정수
*NO_OUT	단일문자 플래그

ENDFORM.                    " 3500_sort_table_build
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.

  DATA: BEGIN OF EXCL OCCURS 25,
          FUNKTION(10),
        END OF EXCL.
  REFRESH EXCL.

  IF ZTISSCRCOM-MONSC EQ 'I'.
    MOVE 'SIMU' TO EXCL-FUNKTION.    APPEND EXCL.
  ENDIF.

  SET PF-STATUS '0200' EXCLUDING EXCL.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE OK_CODE.
    WHEN 'ABBR'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'BU' OR 'BUC' OR 'SIMU'.
*> 일괄전기 확인메시지 사용시.
*      IF ztitig00-pstcm EQ 'X'.
      CALL FUNCTION 'Z_TI_POPUP_TO_CONFIRM_MESSAGE'
        EXPORTING
          XMODE       = 'P'
          IM_DOCUMENT = 'CS'
        IMPORTING
          ANSWER      = G_ANSWER.
      IF G_ANSWER NE 'Y'.
        OK_CODE = 'ABBR'.
      ENDIF.
*      ENDIF.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN OTHERS.
  ENDCASE.
  CLEAR: OK_CODE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_BEARBEITEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_BEARBEITEN INPUT.
  SET SCREEN 0. LEAVE SCREEN.
ENDMODULE.                 " EXIT_BEARBEITEN  INPUT
*&---------------------------------------------------------------------*
*&      Form  ZTIT905_bdc_data
*&---------------------------------------------------------------------*
FORM ZTIT905_BDC_DATA .

  LOOP AT IT_DISP INTO GS_DISP WHERE BOX = 'X'.

    PERFORM BDC_ZTITCCK_UPDATE USING GS_DISP.

    PERFORM BDC_ZTITCSK_CREATE USING GS_DISP.
    "전기와 생성여부는 내부에서 .

    PERFORM BDC_ZTITCSK_UPDATE USING GS_DISP.
    "전기와 생성여부는 내부에서 .
******************************************************
*      PERFORM bdc_transaction USING 'ZTIT905' g_subrc.

    IF G_SUBRC EQ 0.

      MESSAGE S202 WITH GS_DISP-ICCNO.

      MOVE:  SY-MSGID   TO  IT_MSG-MSGID,
             SY-MSGTY   TO  IT_MSG-MSGTY,
             SY-MSGNO   TO  IT_MSG-MSGNO,
             SY-MSGV1   TO  IT_MSG-MSGV1,
             SY-MSGV2   TO  IT_MSG-MSGV2,
             SY-MSGV3   TO  IT_MSG-MSGV3,
             SY-MSGV4   TO  IT_MSG-MSGV4,
             GS_DISP-ICCNO TO  IT_MSG-REFNO.
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
               GS_DISP-ICCNO   TO IT_MSG-REFNO.
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
               GS_DISP-ICCNO TO  IT_MSG-REFNO.
        APPEND IT_MSG.
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

ENDFORM.                    " ZTIT905_bdc_data
*&---------------------------------------------------------------------*
*&      Form  bdc_ZTITCCK_update
*&---------------------------------------------------------------------*
FORM BDC_ZTITCCK_UPDATE  USING    GS_DISP TYPE TY_LIST.

*            PERFORM bdc_dynpro_build USING :
*                   'X' 'ZTIR1000'          '0200',
*                   ' ' 'ZTISSCRCOM-IIPNO'  GS_DISP-iccno,
*                   ' ' 'ZTISSCRCOM-AMSEQ'  GS_DISP-amdsq,
*                   ' ' 'BDC_OKCODE'       '=ZTIENTER'.
**> 세부화면.
*           WRITE GS_DISP-itpa1 TO l_text_amout CURRENCY GS_DISP-itpa1c.
*            PERFORM    set_write_no_mask(ZTIr9000)
*                                              CHANGING  l_text_amout.
*
*            PERFORM bdc_dynpro_build USING :
*                   'X' 'ZTIR1000'          '2000',
*                   ' ' 'ZTITIP01-ITPA1'    l_text_amout,
*                   ' ' 'BDC_OKCODE'       '=ZTISAVE'.
*
*            PERFORM bdc_dynpro_build USING :
*                   'X' 'SAPLSPO1'          '0300',
*                   ' ' 'BDC_OKCODE'       '=YES'.



ENDFORM.                    " bdc_ZTITCCK_update
*&---------------------------------------------------------------------*
*&      Form  bdc_ZTITCSK_create
*&---------------------------------------------------------------------*
FORM BDC_ZTITCSK_CREATE  USING    GS_DISP TYPE TY_LIST.

ENDFORM.                    " bdc_ZTITCSK_create
*&---------------------------------------------------------------------*
*&      Form  bdc_ZTITCSK_update
*&---------------------------------------------------------------------*
FORM BDC_ZTITCSK_UPDATE  USING    GS_DISP TYPE TY_LIST.

ENDFORM.                    " bdc_ZTITCSK_update
*&---------------------------------------------------------------------*
*&      Form  get_selected_row
*&---------------------------------------------------------------------*
FORM GET_SELECTED_ROW  TABLES   PT_ROW_NO TYPE LVC_T_ROID.

*  DATA: l_valid TYPE c.
*
*  CALL METHOD g_grid->check_changed_data
*    IMPORTING
*      e_valid = l_valid.
*
*  IF l_valid EQ 'X'.
*    CALL METHOD g_grid->get_selected_rows
*      IMPORTING
*        et_row_no = pt_row_no[].
*
*    IF pt_row_no[] IS INITIAL.
*      MESSAGE s909.
*      EXIT.
*    ENDIF.
*
*    CLEAR gs_disp-box.
*    MODIFY it_disp FROM gs_disp TRANSPORTING box WHERE box = 'X'.
*
*    LOOP AT pt_row_no.
*      CHECK pt_row_no-row_id > 0.
*      ADD 1 TO g_count.
*      READ TABLE it_disp INTO gs_disp INDEX pt_row_no-row_id.
*      IF gs_disp-box NE 'X'.
*        gs_disp-box = 'X'.
*      ENDIF.
*      MODIFY it_disp FROM gs_disp INDEX pt_row_no-row_id.
*    ENDLOOP.
*  ENDIF.

  CLEAR: G_COUNT.
  LOOP AT IT_DISP INTO GS_DISP WHERE BOX = 'X'.
    ADD 1 TO G_COUNT.
  ENDLOOP.
  IF G_COUNT EQ 0.
    MESSAGE S909.
  ENDIF.

ENDFORM.                    " get_selected_row
*&---------------------------------------------------------------------*
*&      Form  modify_customs_table
*&---------------------------------------------------------------------*
FORM MODIFY_CUSTOMS_TABLE .

  DATA L_SUBRC LIKE SY-SUBRC.

  LOOP AT IT_DISP INTO GS_DISP WHERE BOX   EQ 'X'
                                 AND ERRMD EQ SPACE.
    SELECT SINGLE *
      FROM ZTITCCK
     WHERE ICCNO   EQ  GS_DISP-ICCNO.

*--> [가온] BDC MODE 수정
**** 전 회사 적용
    CTU_PARAMS-DISMODE = 'N'.
*<-- [가온] BDC MODE 수정

    CASE GS_DISP-CSTCL.
      WHEN 'Z'. "관세사 수수료 cchcg.
        IF GS_DISP-WRBTR EQ ZTITCCK-CCHCG.
          MESSAGE S511 WITH GS_DISP-ICCNO '관세사 수수료'.
          PERFORM SET_RETURN_MESSAGE_FILL USING 'W'.
        ELSE.
*      > build BDC data
          PERFORM BUILD_CC_CHANGED_BDCDATA.
*      > Call transaction
          PERFORM BDC_TRANSACTION        USING 'ZTIT402' L_SUBRC.
*      > build Message internal table.
          PERFORM BUILD_CHANGED_MESSAGE  USING L_SUBRC.
          IF L_SUBRC NE 0.
            GS_DISP-ERRMD = 'X'.
          ENDIF.
        ENDIF.
      WHEN '1'. "관세 cdutx.
        IF GS_DISP-WRBTR EQ ZTITCCK-CDUTX.
          MESSAGE S511 WITH GS_DISP-ICCNO '특소세'.
          PERFORM SET_RETURN_MESSAGE_FILL USING 'W'.
        ELSE.
*      > build BDC data
          PERFORM BUILD_CC_CHANGED_BDCDATA.
*      > Call transaction
          PERFORM BDC_TRANSACTION        USING 'ZTIT402' L_SUBRC.
*      > build Message internal table.
          PERFORM BUILD_CHANGED_MESSAGE  USING L_SUBRC.
          IF L_SUBRC NE 0.
            GS_DISP-ERRMD = 'X'.
          ENDIF.
        ENDIF.
      WHEN '2'. "통관부가세cadtx.
        IF GS_DISP-WMWST EQ ZTITCCK-CADTX AND
           GS_DISP-FWBAS EQ ZTITCCK-CTSAK.
          MESSAGE S511 WITH GS_DISP-ICCNO '부가세 관련'.
          PERFORM SET_RETURN_MESSAGE_FILL USING 'W'.
        ELSE.
*      > build BDC data
          PERFORM BUILD_CC_CHANGED_BDCDATA.
*      > Call transaction
          PERFORM BDC_TRANSACTION        USING 'ZTIT402' L_SUBRC.
*      > build Message internal table.
          PERFORM BUILD_CHANGED_MESSAGE  USING L_SUBRC.
          IF L_SUBRC NE 0.
            GS_DISP-ERRMD = 'X'.
          ENDIF.
        ENDIF.
      WHEN '3'. "특소세csptx
        IF GS_DISP-WRBTR EQ ZTITCCK-CSPTX.
          MESSAGE S511 WITH GS_DISP-ICCNO '특소세'.
          PERFORM SET_RETURN_MESSAGE_FILL USING 'W'.
        ELSE.
*      > build BDC data
          PERFORM BUILD_CC_CHANGED_BDCDATA.
*      > Call transaction
          PERFORM BDC_TRANSACTION        USING 'ZTIT402' L_SUBRC.
*      > build Message internal table.
          PERFORM BUILD_CHANGED_MESSAGE  USING L_SUBRC.
          IF L_SUBRC NE 0.
            GS_DISP-ERRMD = 'X'.
          ENDIF.
        ENDIF.
      WHEN '4'. "주세 caltx
        IF GS_DISP-WRBTR EQ ZTITCCK-CALTX.
          MESSAGE S511 WITH GS_DISP-ICCNO '주세'.
          PERFORM SET_RETURN_MESSAGE_FILL USING 'W'.
        ELSE.
*      > build BDC data
          PERFORM BUILD_CC_CHANGED_BDCDATA.
*      > Call transaction
          PERFORM BDC_TRANSACTION        USING 'ZTIT402' L_SUBRC.
*      > build Message internal table.
          PERFORM BUILD_CHANGED_MESSAGE  USING L_SUBRC.
          IF L_SUBRC NE 0.
            GS_DISP-ERRMD = 'X'.
          ENDIF.
        ENDIF.
      WHEN '5'. "교통세 ctrtx
        IF GS_DISP-WRBTR EQ ZTITCCK-CTRTX.
          MESSAGE S511 WITH GS_DISP-ICCNO '교통세'.
          PERFORM SET_RETURN_MESSAGE_FILL USING 'W'.
        ELSE.
*      > build BDC data
          PERFORM BUILD_CC_CHANGED_BDCDATA.
*      > Call transaction
          PERFORM BDC_TRANSACTION        USING 'ZTIT402' L_SUBRC.
*      > build Message internal table.
          PERFORM BUILD_CHANGED_MESSAGE  USING L_SUBRC.
          IF L_SUBRC NE 0.
            GS_DISP-ERRMD = 'X'.
          ENDIF.
        ENDIF.
      WHEN '6'. "교육세 cintx
        IF GS_DISP-WRBTR EQ ZTITCCK-CINTX.
          MESSAGE S511 WITH GS_DISP-ICCNO '교육세'.
          PERFORM SET_RETURN_MESSAGE_FILL USING 'W'.
        ELSE.
*      > build BDC data
          PERFORM BUILD_CC_CHANGED_BDCDATA.
*      > Call transaction
          PERFORM BDC_TRANSACTION        USING 'ZTIT402' L_SUBRC.
*      > build Message internal table.
          PERFORM BUILD_CHANGED_MESSAGE  USING L_SUBRC.
          IF L_SUBRC NE 0.
            GS_DISP-ERRMD = 'X'.
          ENDIF.
        ENDIF.
      WHEN '7'. "농특세 cagtx
        IF GS_DISP-WRBTR EQ ZTITCCK-CAGTX.
          MESSAGE S511 WITH GS_DISP-ICCNO '농특세'.
          PERFORM SET_RETURN_MESSAGE_FILL USING 'W'.
        ELSE.
*      > build BDC data
          PERFORM BUILD_CC_CHANGED_BDCDATA.
*      > Call transaction
          PERFORM BDC_TRANSACTION        USING 'ZTIT402' L_SUBRC.
*      > build Message internal table.
          PERFORM BUILD_CHANGED_MESSAGE  USING L_SUBRC.
          IF L_SUBRC NE 0.
            GS_DISP-ERRMD = 'X'.
          ENDIF.
        ENDIF.
      WHEN '8'. "신고지연가산세 clttx
        IF GS_DISP-WRBTR EQ ZTITCCK-CLTTX.
          MESSAGE S511 WITH GS_DISP-ICCNO '신고지연가산세'.
          PERFORM SET_RETURN_MESSAGE_FILL USING 'W'.
        ELSE.
*      > build BDC data
          PERFORM BUILD_CC_CHANGED_BDCDATA.
*      > Call transaction
          PERFORM BDC_TRANSACTION        USING 'ZTIT402' L_SUBRC.
*      > build Message internal table.
          PERFORM BUILD_CHANGED_MESSAGE  USING L_SUBRC.
          IF L_SUBRC NE 0.
            GS_DISP-ERRMD = 'X'.
          ENDIF.
        ENDIF.
    ENDCASE.

    MODIFY IT_DISP FROM GS_DISP.
  ENDLOOP.


ENDFORM.                    " modify_customs_table
*&---------------------------------------------------------------------*
*&      Form  build_ip_changed_bdcdata
*&---------------------------------------------------------------------*
FORM BUILD_CC_CHANGED_BDCDATA .

  DATA: L_TEXT_AMOUT(20),
        L_TEXT_AMOUT1(20) .

  REFRESH: BDCDATA.
  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR4000'          '0200',
         ' ' 'ZTISSCRCOM-ICCNO'  GS_DISP-ICCNO,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.
*> 세부화면.
  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'BDC_OKCODE'        '=TABSTRIP_FC2'.

*******************************************
  IF GS_DISP-CSTCL EQ '2'.    ">부가일 경우.
    WRITE GS_DISP-WMWST TO L_TEXT_AMOUT  CURRENCY GS_DISP-CCUAKC.
    WRITE GS_DISP-FWBAS TO L_TEXT_AMOUT1 CURRENCY GS_DISP-CCUAKC.
  ELSE.
    WRITE GS_DISP-WRBTR TO L_TEXT_AMOUT CURRENCY GS_DISP-CCUAKC.
  ENDIF.
  PERFORM    SET_WRITE_NO_MASK(ZTIR9000)
                                    CHANGING : L_TEXT_AMOUT,
                                               L_TEXT_AMOUT1.

  CASE GS_DISP-CSTCL.
    WHEN 'Z'. "관세사 수수료 cchcg.
      PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'ZTITCCK-CCHCG'    L_TEXT_AMOUT,
*         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
    WHEN '1'. "관세 cdutx.
      PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'ZTITCCK-CDUTX'    L_TEXT_AMOUT,
*         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
    WHEN '2'. "통관부가세cadtx.
      PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'ZTITCCK-CADTX'    L_TEXT_AMOUT,
         ' ' 'ZTITCCK-CTSAK'    L_TEXT_AMOUT1,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
    WHEN '3'. "특소세csptx
      PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'ZTITCCK-CSPTX'    L_TEXT_AMOUT,
*         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
    WHEN '4'. "주세 caltx
      PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'ZTITCCK-CALTX'    L_TEXT_AMOUT,
*         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
    WHEN '5'. "교통세 ctrtx
      PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'ZTITCCK-CTRTX'    L_TEXT_AMOUT,
*         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
    WHEN '6'. "교육세 cintx
      PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'ZTITCCK-CINTX'    L_TEXT_AMOUT,
*         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
    WHEN '7'. "농특세 cagtx
      PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'ZTITCCK-CAGTX'    L_TEXT_AMOUT,
*         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
    WHEN '8'. "신고지연가산세 clttx
      PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR4000'          '2000',
         ' ' 'ZTITCCK-CLTTX'    L_TEXT_AMOUT,
*         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
  ENDCASE.
*******************************************
*  case gs_disp-expcd.
*    when p_cdutx.
*      WRITE gs_disp-wrbtr TO l_text_amout CURRENCY gs_disp-ccuakc.
*      PERFORM    set_write_no_mask(ZTIr9000)
*                                        CHANGING  l_text_amout.
*      PERFORM bdc_dynpro_build USING :
*         'X' 'ZTIR4000'          '2000',
*         ' ' 'ZTITCCK-CDUTX'    l_text_amout,
**         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
*                                 "통관에서 자동로직 들어가면 삭제.
*         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
*
*    when p_CADTX.
*      WRITE gs_disp-wrbtr TO l_text_amout CURRENCY gs_disp-ccuakc.
*      PERFORM    set_write_no_mask(ZTIr9000)
*                                        CHANGING  l_text_amout.
*      PERFORM bdc_dynpro_build USING :
*         'X' 'ZTIR4000'          '2000',
*         ' ' 'ZTITCCK-CADTX'    l_text_amout,
**         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
*         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
*
*    when p_CCHCG.
*      WRITE gs_disp-wrbtr TO l_text_amout CURRENCY gs_disp-ccuakc.
*      PERFORM    set_write_no_mask(ZTIr9000)
*                                        CHANGING  l_text_amout.
*      PERFORM bdc_dynpro_build USING :
*         'X' 'ZTIR4000'          '2000',
*         ' ' 'ZTITCCK-CCHCG'    l_text_amout,
**         ' ' 'ZTITCCK-CCUAKC'   gs_disp-WAERS,
*         ' ' 'BDC_OKCODE'       '=ZTISAVE'.
*
*  endcase.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'SAPLSPO1'          '0300',
         ' ' 'BDC_OKCODE'       '=YES'.

ENDFORM.                    " build_ip_changed_bdcdata
*&---------------------------------------------------------------------*
*&      Form  build_changed_message
*&---------------------------------------------------------------------*
FORM BUILD_CHANGED_MESSAGE  USING    P_SUBRC.

  IF P_SUBRC EQ 0.
****************************************
    CASE GS_DISP-CSTCL.
      WHEN 'Z'. "관세사 수수료 cchcg.
        MESSAGE S507 WITH GS_DISP-ICCNO '통관수수료'.
      WHEN '1'. "관세 cdutx.
        MESSAGE S507 WITH GS_DISP-ICCNO '관세'.
      WHEN '2'. "통관부가세cadtx.
        MESSAGE S507 WITH GS_DISP-ICCNO '부가세'.
      WHEN '3'. "특소세csptx
        MESSAGE S507 WITH GS_DISP-ICCNO '특소세'.
      WHEN '4'. "주세 caltx
        MESSAGE S507 WITH GS_DISP-ICCNO '주세'.
      WHEN '5'. "교통세 ctrtx
        MESSAGE S507 WITH GS_DISP-ICCNO '교통세'.
      WHEN '6'. "교육세 cintx
        MESSAGE S507 WITH GS_DISP-ICCNO '교육세'.
      WHEN '7'. "농특세 cagtx
        MESSAGE S507 WITH GS_DISP-ICCNO '농특세'.
      WHEN '8'. "신고지연가산세 clttx
        MESSAGE S507 WITH GS_DISP-ICCNO '신고지연가산세'.
    ENDCASE.
******************************************************

    MOVE:  SY-MSGID   TO  IT_MSG-MSGID,
           SY-MSGTY   TO  IT_MSG-MSGTY,
           SY-MSGNO   TO  IT_MSG-MSGNO,
           SY-MSGV1   TO  IT_MSG-MSGV1,
           SY-MSGV2   TO  IT_MSG-MSGV2,
           SY-MSGV3   TO  IT_MSG-MSGV3,
           SY-MSGV4   TO  IT_MSG-MSGV4,
           GS_DISP-ICCNO TO  IT_MSG-REFNO.
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
             GS_DISP-ICCNO   TO IT_MSG-REFNO.
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
             GS_DISP-ICCNO TO  IT_MSG-REFNO.
      APPEND IT_MSG.
    ENDIF.
  ENDIF.

ENDFORM.                    " build_changed_message
*&---------------------------------------------------------------------*
*&      Form  fill_default_header_data
*&---------------------------------------------------------------------*
FORM FILL_DEFAULT_HEADER_DATA .

  DATA: L_DAY(2)   TYPE   N.

  LOOP AT IT_DISP INTO GS_DISP WHERE BOX = 'X'.
    EXIT.
  ENDLOOP.

  READ TABLE IT_ZTITIG06 WITH KEY EXPCD = GS_DISP-EXPCD.

  SELECT *
    FROM ZTITIG07 UP TO 1 ROWS
   WHERE BUKRS EQ T001-BUKRS
     AND EXPGR EQ IT_ZTITIG06-EXPGR
     AND EXPCD EQ IT_ZTITIG06-EXPCD.
*     AND cstct IN ('C', 'D','E').
  ENDSELECT.
  IF SY-SUBRC EQ 0.
    MOVE: ZTITIG07-BLART   TO    ZTITCSK-BLART,
          ZTITIG07-BUPLA   TO    ZTITCSK-BUPLA,
          ZTITIG07-GSBER   TO    ZTITCSK-GSBER,
          ZTITIG07-CSTYP   TO    ZTITCSK-CSTYP,
          ZTITIG07-ZTERM   TO    ZTITCSK-ZTERM,
          ZTITIG07-MWSKZ   TO    ZTITCSK-MWSKZ,
          ZTITIG07-ZLSPR   TO    ZTITCSK-ZLSPR,
          ZTITIG07-ZLSCH   TO    ZTITCSK-ZLSCH,
          ZTITIG07-UZAWE   TO    ZTITCSK-UZAWE.
  ELSE.
    MOVE: IT_ZTITIG06-BLART   TO    ZTITCSK-BLART,
*          it_ztitig06-bupla   TO    ztitcsk-bupla,
*          it_ztitig06-gsber   TO    ztitcsk-gsber,
          'P'                 TO    ZTITCSK-CSTYP,
*          it_ztitig06-zterm   TO    ztitcsk-zterm,
          IT_ZTITIG06-MWSKZ   TO    ZTITCSK-MWSKZ.
*          it_ztitig06-zlspr   TO    ztitcsk-zlspr,
*          it_ztitig06-zlsch   TO    ztitcsk-zlsch,
*          it_ztitig06-uzawe   TO    ztitcsk-uzawe.
  ENDIF.

  MOVE: SY-DATLO         TO    ZTITCSK-BUDAT,
        SY-DATLO         TO    ZTITCSK-BLDAT,
        GS_DISP-PAYDA    TO    ZTITCSK-ZFBDT,
        GS_DISP-BUPLA    TO    ZTITCSK-BUPLA,
        T001-BUKRS       TO    ZTITCSK-BUKRS,
        SY-MANDT         TO    ZTITCSK-MANDT,
        GS_DISP-CDCNO    TO    ZTITCSK-XBLNR,
        GS_DISP-LIFNR    TO    ZTITCSK-LIFNR,
        T001-WAERS       TO    ZTITCSK-WAERS,
        G_WRBTR          TO    ZTITCSK-WRBTR,
        G_WMWST          TO    ZTITCSK-WMWST,
        G_FWBAS          TO    ZTITCSK-FWBAS.

*> 관세사 수수료일 경우. 마지막 일자로...
  IF IT_ZTITIG06-CSTCL EQ 'Z'.
    ZTITCSK-ZFBDT = SY-DATLO.

    CALL FUNCTION 'END_OF_MONTH_DETERMINE'
      EXPORTING
        DATUM = ZTITCSK-ZFBDT
      IMPORTING
        TT    = L_DAY.

    MOVE: L_DAY TO ZTITCSK-ZFBDT+6(2).
  ENDIF.

  PERFORM  GET_DOMAIN_VALUE_TEXT(ZTIR9000)
                                 USING   'ZTIEXPGR'
                                         'C'
                                 CHANGING ZTITCSK-BKTXT.

  SELECT SINGLE *
    FROM LFA1
   WHERE LIFNR  EQ  GS_DISP-LIFNR.

  SELECT NAME_TEXT
    INTO ZTITCSK-INAME
    FROM ADRP UP TO 1 ROWS
   WHERE PERSNUMBER EQ ( SELECT PERSNUMBER
                           FROM USR21
                          WHERE BNAME EQ SY-UNAME ).

  ENDSELECT.

*> 입력된 값 체크.
  PERFORM  CHECK_INPUT_VALUE.

ENDFORM.                    " fill_default_header_data
*&---------------------------------------------------------------------*
*&      Module  change_field_attribute_scr0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_FIELD_ATTRIBUTE_SCR0200 OUTPUT.

  LOOP AT SCREEN.
    IF ZTISSCRCOM-MONSC EQ 'I'.
      IF SCREEN-NAME EQ 'ZTITCSK-LIFNR' OR
         SCREEN-NAME EQ 'LFA1-NAME1'     OR
         SCREEN-NAME EQ 'ZTITCSK-AKONT' OR
*         screen-name EQ 'ZTITCSK-WRBTR' OR
*         screen-name EQ 'ZTITCSK-WAERS' OR
*         screen-name EQ 'ZTITCSK-MWSKZ' OR
         SCREEN-NAME EQ 'ZTITCSK-WMWST' OR
         SCREEN-NAME EQ 'ZTITCSK-BKTXT' OR
         SCREEN-NAME EQ 'ZTITCSK-XBLNR' OR
         SCREEN-NAME EQ 'ZTITCSK-SGTXT'.
        SCREEN-INPUT     = '0'.
        SCREEN-INVISIBLE = '1'.
      ENDIF.
    ENDIF.
    IF ZTITIG00-CHKBP IS INITIAL AND
       SCREEN-NAME EQ 'ZTITCSK-BUPLA'.
      SCREEN-INPUT     = '0'.
      SCREEN-INVISIBLE = '1'.
    ENDIF.
    IF ZTITIG00-CHKBA IS INITIAL AND
       SCREEN-NAME EQ 'ZTITCSK-GSBER'.
      SCREEN-INPUT     = '0'.
      SCREEN-INVISIBLE = '1'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_field_attribute_scr0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  execute_collective_posting
*&---------------------------------------------------------------------*
FORM EXECUTE_COLLECTIVE_POSTING .

  DATA: L_SUBRC   LIKE SY-SUBRC.

  REFRESH: BDCDATA.
  CLEAR: G_CNT, G_WRBTR.

*> 전기할 품목의 Counter.
  LOOP AT IT_DISP INTO GS_DISP WHERE BOX = 'X'
                                 AND ERRMD EQ SPACE.
    ADD 1 TO G_CNT.
    ADD GS_DISP-WRBTR TO G_WRBTR.
  ENDLOOP.

*> build BDC data
  PERFORM BUILD_COLLECTIVE_POSTING_DATA.
  CLEAR: SY.
*> Call transaction
  PERFORM BDC_TRANSACTION        USING 'ZTIT901' L_SUBRC.
*> build Message internal table.
  PERFORM BUILD_POSTED_MESSAGE   USING L_SUBRC.

  IF L_SUBRC EQ 0.
    ADD 1 TO G_SUCCESS.
  ELSE.
    ADD 1 TO G_ERROR.
  ENDIF.

ENDFORM.                    " execute_collective_posting
*&---------------------------------------------------------------------*
*&      Form  build_collective_posting_data
*&---------------------------------------------------------------------*
FORM BUILD_COLLECTIVE_POSTING_DATA .

  DATA: L_TEXT_AMOUT1(20),
        L_TEXT_AMOUT2(20),
        L_TEXT_AMOUT3(20),
        L_SGTXT           TYPE SGTXT,
        L_ICSSQ           TYPE ZTIICSSQ.

  DATA  L_DATE(10)        TYPE C.

  REFRESH: BDCDATA.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR9000'          '0100',
         ' ' 'ZTISSCRCOM-BUKRS'  ZTITCSK-BUKRS,
         ' ' 'ZTISSCRCOM-BUDAT'  ZTITCSK-BUDAT,
         ' ' 'ZTISSCRCOM-BLDAT'  ZTITCSK-BLDAT,
         ' ' 'ZTISSCRCOM-LIFNR'  ZTITCSK-LIFNR,
         ' ' 'ZTISSCRCOM-EXPGR'  'C',
*         ' ' 'ZTISSCRCOM-CSTYP'  ZTISSCRCOM-CSTYP
         ' ' 'ZTISSCRCOM-BLART'  ZTITCSK-BLART,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

**> 세부화면.
*  WRITE g_wrbtr TO l_text_amout CURRENCY ZTITCSK-waers.
*  PERFORM    set_write_no_mask(ZTIr9000)
*                                    CHANGING  l_text_amout.

  CLEAR: L_DATE.
  IF NOT ZTITCSK-ZFBDT IS INITIAL.
    WRITE ZTITCSK-ZFBDT TO L_DATE.
  ENDIF.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR9000'          '2000',
*         ' ' 'ZTITCSK-BUDAT'
*         ' ' 'ZTITCSK-BLART'
*         ' ' 'ZTITCSK-BLDAT'
*         ' ' 'ZTITCSK-BUPLA'  ztitcsk-bupla,
*         ' ' 'ZTITCSK-GSBER'  ztitcsk-gsber,
         ' ' 'ZTITCSK-ZFBDT'  L_DATE,
         ' ' 'ZTITCSK-ZLSPR'  ZTITCSK-ZLSPR,
         ' ' 'ZTITCSK-CSTYP'  ZTITCSK-CSTYP,
         ' ' 'ZTITCSK-INAME'  ZTITCSK-INAME,
         ' ' 'ZTITCSK-HKONT'  ZTITCSK-HKONT,
*         ' ' 'ZTITCSK-AKONT'
*         ' ' 'ZTITCSK-ZLSCH'  ztitcsk-zlsch,
         ' ' 'ZTITCSK-ZTERM'  ZTITCSK-ZTERM,
*         ' ' 'ZTITCSK-WRBTR'  l_text_amout,
*         ' ' 'ZTITCSK-WAERS'
         ' ' 'ZTITCSK-MWSKZ'  ZTITCSK-MWSKZ.
*         ' ' 'ZTITCSK-WMWST'  '0',
*         ' ' 'ZTITCSK-FWBAS'  '0',
*         ' ' 'ZTITCSK-XBLNR'  ztitcsk-xblnr.
*         ' ' 'ZTITCSK-BKTXT'  ztitcsk-bktxt.
*         ' ' 'ZTITCSK-EBILL'  ZTITCSK-ebill.
*         ' ' 'ZTITCSK-SGTXT'  ZTITCSK-sgtxt.



  IF NOT ZTITIG00-CHKBP IS INITIAL.
    PERFORM BDC_DYNPRO_BUILD USING :
           ' ' 'ZTITCSK-BUPLA'  ZTITCSK-BUPLA.
  ENDIF.

  IF NOT ZTITIG00-CHKBA IS INITIAL.
    PERFORM BDC_DYNPRO_BUILD USING :
           ' ' 'ZTITCSK-GSBER'  ZTITCSK-GSBER.
  ENDIF.

  CLEAR: G_COUNT.
  LOOP AT IT_DISP INTO GS_DISP WHERE BOX = 'X'
                                 AND ERRMD EQ SPACE.
    ADD 1 TO G_COUNT.

    WRITE GS_DISP-WRBTR TO L_TEXT_AMOUT1 CURRENCY GS_DISP-WAERS.
    WRITE GS_DISP-WMWST TO L_TEXT_AMOUT2 CURRENCY GS_DISP-WAERS.
    WRITE GS_DISP-FWBAS TO L_TEXT_AMOUT3 CURRENCY GS_DISP-WAERS.
    PERFORM    SET_WRITE_NO_MASK(ZTIR9000)
                                      CHANGING : L_TEXT_AMOUT1,
                                                 L_TEXT_AMOUT2,
                                                 L_TEXT_AMOUT3.

    IF G_COUNT EQ 1.
      PERFORM BDC_DYNPRO_BUILD USING :
             ' ' 'ZTISCSIT-EXPCD(01)'  GS_DISP-EXPCD,
             ' ' 'ZTISCSIT-ICCNO(01)'  GS_DISP-ICCNO,
             ' ' 'ZTISCSIT-WRBTR(01)'  L_TEXT_AMOUT1,
             ' ' 'ZTISCSIT-MWSKZ(01)'  ZTITCSK-MWSKZ,
             ' ' 'ZTISCSIT-WMWST(01)'  L_TEXT_AMOUT2,
             ' ' 'ZTISCSIT-FWBAS(01)'  L_TEXT_AMOUT3.
      CASE GS_DISP-CSTCL.
        WHEN 'B' OR 'C' OR 'D'.
          WRITE GS_DISP-PAYDA TO L_SGTXT.
          PERFORM BDC_DYNPRO_BUILD USING :
                 ' ' 'ZTISCSIT-SGTXT(01)'  L_SGTXT.
      ENDCASE.

      L_ICSSQ = 1.
    ELSE.
      PERFORM BDC_DYNPRO_BUILD USING :
             'X' 'ZTIR9000'          '2000',
             ' ' 'ZTISCSIT-EXPCD(02)'  GS_DISP-EXPCD,
             ' ' 'ZTISCSIT-ICCNO(02)'  GS_DISP-ICCNO,
             ' ' 'ZTISCSIT-WRBTR(02)'  L_TEXT_AMOUT1,
             ' ' 'ZTISCSIT-MWSKZ(02)'  ZTITCSK-MWSKZ,
             ' ' 'ZTISCSIT-WMWST(02)'  L_TEXT_AMOUT2,
             ' ' 'ZTISCSIT-FWBAS(02)'  L_TEXT_AMOUT3.
      CASE GS_DISP-CSTCL.
        WHEN 'B' OR 'C' OR 'D'.
          WRITE GS_DISP-PAYDA TO L_SGTXT.
          PERFORM BDC_DYNPRO_BUILD USING :
                 ' ' 'ZTISCSIT-SGTXT(02)'  L_SGTXT.
      ENDCASE.

      L_ICSSQ = G_COUNT - 1.
    ENDIF.

    IF G_COUNT NE G_CNT.
      PERFORM BDC_DYNPRO_BUILD USING :
         ' ' 'ZTITCSP-ICSSQ'   L_ICSSQ,
         ' ' 'BDC_OKCODE'       '=TC_2130_PMVC'.
    ENDIF.

  ENDLOOP.

  IF OK_CODE EQ 'BUC'.
    PERFORM BDC_DYNPRO_BUILD USING :
           ' ' 'BDC_OKCODE'       '=ZTISAVE'.
  ELSEIF OK_CODE EQ 'SIMU'.
    PERFORM BDC_DYNPRO_BUILD USING :
           ' ' 'BDC_OKCODE'       '=ZTISIMUL'.
  ELSE.
    PERFORM BDC_DYNPRO_BUILD USING :
           ' ' 'BDC_OKCODE'       '=ZTIPOST'.
  ENDIF.
  IF OK_CODE NE 'SIMU'.
    PERFORM BDC_DYNPRO_BUILD USING :
           'X' 'SAPLSPO1'          '0300',
           ' ' 'BDC_OKCODE'       '=YES'.
  ENDIF.


ENDFORM.                    " build_collective_posting_data
*&---------------------------------------------------------------------*
*&      Form  build_posted_message
*&---------------------------------------------------------------------*
FORM BUILD_POSTED_MESSAGE  USING    P_SUBRC.

  IF P_SUBRC EQ 0.
    MOVE:  SY-MSGID   TO  IT_MSG-MSGID,
           SY-MSGTY   TO  IT_MSG-MSGTY,
           SY-MSGNO   TO  IT_MSG-MSGNO,
           SY-MSGV1   TO  IT_MSG-MSGV1,
           SY-MSGV2   TO  IT_MSG-MSGV2,
           SY-MSGV3   TO  IT_MSG-MSGV3,
           SY-MSGV4   TO  IT_MSG-MSGV4,
           GS_DISP-ICCNO TO  IT_MSG-REFNO.
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
             GS_DISP-ICCNO   TO IT_MSG-REFNO.
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
             GS_DISP-ICCNO TO  IT_MSG-REFNO.
      APPEND IT_MSG.
    ENDIF.
  ENDIF.

ENDFORM.                    " build_posted_message
*&---------------------------------------------------------------------*
*&      Form  execute_individual_posting
*&---------------------------------------------------------------------*
FORM EXECUTE_INDIVIDUAL_POSTING .

  DATA: L_SUBRC   LIKE SY-SUBRC.

  LOOP AT IT_DISP INTO GS_DISP WHERE BOX = 'X'
                                 AND ERRMD EQ SPACE.

*> build BDC data
    PERFORM BUILD_INDIVIDUAL_POSTING_DATA.
*> Call transaction
    PERFORM BDC_TRANSACTION        USING 'ZTIT901' L_SUBRC.
*> build Message internal table.
    PERFORM BUILD_POSTED_MESSAGE   USING L_SUBRC.
    IF L_SUBRC EQ 0.
      ADD 1 TO G_SUCCESS.
    ELSE.
      ADD 1 TO G_ERROR.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " execute_individual_posting
*&---------------------------------------------------------------------*
*&      Form  build_individual_posting_data
*&---------------------------------------------------------------------*
FORM BUILD_INDIVIDUAL_POSTING_DATA .

  DATA: L_TEXT_AMOUT1(20),
        L_TEXT_AMOUT2(20),
        L_TEXT_AMOUT3(20),
        L_SGTXT             TYPE SGTXT.

  DATA  L_DATE(10)          TYPE C.

  REFRESH: BDCDATA.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR9000'          '0100',
         ' ' 'ZTISSCRCOM-BUKRS'  ZTITCSK-BUKRS,
         ' ' 'ZTISSCRCOM-BUDAT'  ZTITCSK-BUDAT,
         ' ' 'ZTISSCRCOM-BLDAT'  ZTITCSK-BLDAT,
         ' ' 'ZTISSCRCOM-LIFNR'  GS_DISP-LIFNR,
         ' ' 'ZTISSCRCOM-EXPGR'  'C',
*         ' ' 'ZTISSCRCOM-CSTYP'  ZTISSCRCOM-CSTYP
         ' ' 'ZTISSCRCOM-BLART'  ZTITCSK-BLART,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

*> 세부화면.
  WRITE GS_DISP-WRBTR TO L_TEXT_AMOUT1 CURRENCY GS_DISP-WAERS.
  WRITE GS_DISP-WMWST TO L_TEXT_AMOUT2 CURRENCY GS_DISP-WAERS.
  WRITE GS_DISP-FWBAS TO L_TEXT_AMOUT3 CURRENCY GS_DISP-WAERS.
  PERFORM    SET_WRITE_NO_MASK(ZTIR9000)
                                    CHANGING : L_TEXT_AMOUT1,
                                               L_TEXT_AMOUT2,
                                               L_TEXT_AMOUT3.

  CLEAR: L_DATE.
  IF NOT ZTITCSK-ZFBDT IS INITIAL.
    WRITE ZTITCSK-ZFBDT TO L_DATE.
  ENDIF.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR9000'          '2000',
*         ' ' 'ZTITCSK-BUDAT'
*         ' ' 'ZTITCSK-BLART'
*         ' ' 'ZTITCSK-BLDAT'
*         ' ' 'ZTITCSK-BUPLA'  ZTITCSK-bupla,
*         ' ' 'ZTITCSK-GSBER'  ZTITCSK-gsber,
         ' ' 'ZTITCSK-CSTYP'  ZTITCSK-CSTYP,
         ' ' 'ZTITCSK-INAME'  ZTITCSK-INAME,
         ' ' 'ZTITCSK-HKONT'  ZTITCSK-HKONT,
         ' ' 'ZTITCSK-ZLSPR'  ZTITCSK-ZLSPR,
         ' ' 'ZTITCSK-ZFBDT'  L_DATE,
*         ' ' 'ZTITCSK-AKONT'
         ' ' 'ZTITCSK-ZLSCH'  ZTITCSK-ZLSCH,
         ' ' 'ZTITCSK-ZTERM'  ZTITCSK-ZTERM,
*         ' ' 'ZTITCSK-WRBTR'  l_text_amout,
*         ' ' 'ZTITCSK-WAERS'
*         ' ' 'ZTITCSK-MWSKZ'  ZTITCSK-mwskz,
*         ' ' 'ZTITCSK-WMWST'  '0',
*         ' ' 'ZTITCSK-FWBAS'  '0',
         ' ' 'ZTITCSK-XBLNR'  GS_DISP-CDCNO,
*         ' ' 'ZTITCSK-BKTXT'  ztitcsk-bktxt,
*         ' ' 'ZTITCSK-BKTXT'  '통관관련비용',
*         ' ' 'ZTITCSK-EBILL'  ZTITCSK-ebill,
*         ' ' 'ZTITCSK-SGTXT'  '통관관련비용',
         ' ' 'ZTISCSIT-EXPCD(01)'  GS_DISP-EXPCD,
         ' ' 'ZTISCSIT-ICCNO(01)'  GS_DISP-ICCNO,
         ' ' 'ZTISCSIT-WRBTR(01)'  L_TEXT_AMOUT1,
         ' ' 'ZTISCSIT-MWSKZ(01)'  ZTITCSK-MWSKZ,
         ' ' 'ZTISCSIT-WMWST(01)'  L_TEXT_AMOUT2,
         ' ' 'ZTISCSIT-FWBAS(01)'  L_TEXT_AMOUT3.

  IF NOT ZTITCSK-EMPFK IS INITIAL.
    PERFORM BDC_DYNPRO_BUILD USING :
         ' ' 'ZTITCSK-EMPFK'  ZTITCSK-EMPFK.
  ENDIF.

  IF NOT ZTITIG00-CHKBP IS INITIAL.
    PERFORM BDC_DYNPRO_BUILD USING :
         ' ' 'ZTITCSK-BUPLA'  ZTITCSK-BUPLA.
  ENDIF.
  IF NOT ZTITIG00-CHKBA IS INITIAL.
    PERFORM BDC_DYNPRO_BUILD USING :
         ' ' 'ZTITCSK-GSBER'  ZTITCSK-GSBER.
  ENDIF.

  CASE GS_DISP-CSTCL.
    WHEN 'B' OR 'C' OR 'D'.
      WRITE GS_DISP-PAYDA TO L_SGTXT.
      PERFORM BDC_DYNPRO_BUILD USING :
             ' ' 'ZTISCSIT-SGTXT(01)'  L_SGTXT.
  ENDCASE.


  IF OK_CODE EQ 'BUC'.
    PERFORM BDC_DYNPRO_BUILD USING :
           ' ' 'BDC_OKCODE'       '=ZTISAVE'.
  ELSEIF OK_CODE EQ 'SIMU'.
    PERFORM BDC_DYNPRO_BUILD USING :
           ' ' 'BDC_OKCODE'       '=ZTISIMUL'.
  ELSE.
    PERFORM BDC_DYNPRO_BUILD USING :
           ' ' 'BDC_OKCODE'       '=ZTIPOST'.
  ENDIF.
  IF OK_CODE NE 'SIMU'.
    PERFORM BDC_DYNPRO_BUILD USING :
           'X' 'SAPLSPO1'          '0300',
           ' ' 'BDC_OKCODE'       '=YES'.
  ENDIF.

ENDFORM.                    " build_individual_posting_data
*&---------------------------------------------------------------------*
*&      Module  pai_check_fields_scr0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_CHECK_FIELDS_SCR0200 INPUT.

  CHECK OK_CODE NE 'ABBR'.

*> 전기일.
  IF ZTITCSK-BUDAT IS INITIAL.
    PERFORM NO_INPUT_CHECK(ZTIR0000) USING 'ZTITCSK' 'BUDAT' 'E'.
  ENDIF.
*> 증빙일.
  IF ZTITCSK-BLDAT IS INITIAL.
    PERFORM NO_INPUT_CHECK(ZTIR0000) USING 'ZTITCSK' 'BLDAT' 'E'.
  ENDIF.

  IF NOT ZTITIG00-CHKBP IS INITIAL.
    IF ZTITCSK-BUPLA IS INITIAL.    ">
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'BUPLA'.
      PERFORM  CHECK_MANDATORY_INPUT(ZTIR0000)
                             USING  'ZTITCSK-BUPLA' ZTITIG00-CHKBP.
    ENDIF.
  ENDIF.

  IF NOT ZTITIG00-CHKBA IS INITIAL.
    IF ZTITCSK-GSBER IS INITIAL.    ">
*      PERFORM no_input(sapfmmex) USING 'ZTITCSK' 'BUPLA'.
      PERFORM  CHECK_MANDATORY_INPUT(ZTIR0000)
                            USING  'ZTITCSK-GSBER' ZTITIG00-CHKBA.
    ENDIF.
  ENDIF.

  IF ZTITCSK-CSTYP IS INITIAL.
    PERFORM  CHECK_MANDATORY_INPUT(ZTIR0000)
                           USING  'ZTITCSK-CSTYP' 'E'.
  ENDIF.

  IF ZTITCSK-CSTYP EQ 'A'.
    IF ZTITCSK-INAME IS INITIAL.
      PERFORM  CHECK_MANDATORY_INPUT(ZTIR0000)
                             USING  'ZTITCSK-INAME' 'E'.
    ENDIF.
    IF ZTITCSK-HKONT IS INITIAL.
      PERFORM  CHECK_MANDATORY_INPUT(ZTIR0000)
                             USING  'ZTITCSK-HKONT' 'E'.
    ENDIF.
  ENDIF.

*> 입력된 값 체크.
  PERFORM  CHECK_INPUT_VALUE.

*> 지급조건.
  IF ZTITCSK-ZTERM IS INITIAL.
    PERFORM NO_INPUT_CHECK(ZTIR0000) USING 'ZTITCSK' 'ZTERM' 'E'.
  ENDIF.

*> 세금코드.
  IF ZTITCSK-MWSKZ IS INITIAL.
    PERFORM NO_INPUT_CHECK(ZTIR0000) USING 'ZTITCSK' 'MWSKZ' 'E'.
  ENDIF.

**> 사업영역.
*  IF ZTITCSK-gsber IS INITIAL.
*    PERFORM no_input_check(ZTIr0000) USING 'ZTITCSK' 'GSBER' 'E'.
*  ENDIF.
**> 사용가능한 사업영역 체크.
*  PERFORM  check_business_area(ZTIr0000)
*                                     USING ZTITCSK-gsber.
*
  IF NOT ZTITCSK-EMPFK IS INITIAL.
    SELECT SINGLE * INTO *LFA1
           FROM LFA1
           WHERE  LIFNR EQ ZTITCSK-EMPFK.
  ELSE.
    CLEAR *LFA1.
  ENDIF.

*> 개별전표일 경우.
  IF ZTISSCRCOM-MONSC EQ 'I'.

*> 일괄전표일 경우.
  ELSE.

  ENDIF.

ENDMODULE.                 " pai_check_fields_scr0200  INPUT
*&---------------------------------------------------------------------*
*&      Form  p1101_check_input_value
*&---------------------------------------------------------------------*
FORM P1101_CHECK_INPUT_VALUE .

  READ TABLE S_BUKRS INDEX 1.

  SELECT SINGLE *
    FROM T001
   WHERE BUKRS IN S_BUKRS.
  IF SY-SUBRC NE 0.
    MESSAGE E011 WITH S_BUKRS-LOW.
  ENDIF.

  SELECT SINGLE *
    FROM ZTITIG00
   WHERE BUKRS EQ T001-BUKRS.
  IF SY-SUBRC NE 0.
    MESSAGE E035 WITH T001-BUKRS.
  ENDIF.

*  SELECT SINGLE *
*    FROM ztitig07
*   WHERE bukrs EQ t001-bukrs
*     AND cstct EQ 'B'.
*
  SELECT SINGLE *
    FROM T005
   WHERE LAND1 EQ T001-LAND1.

  IF G_ANSWER IS INITIAL.
    CALL FUNCTION 'Z_TI_EXPENCES_CODE_BY_GROUP'
      EXPORTING
        XBUKRS    = T001-BUKRS
        XEXPGR    = 'C'
      IMPORTING
        P_ANSWER  = G_ANSWER
      TABLES
        XZTITIG06 = IT_ZTITIG06
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
*****************************************
    LOOP AT IT_ZTITIG06 WHERE NOT MWSKZ IN S_MWSKZ.
      DELETE IT_ZTITIG06.
    ENDLOOP.
    DESCRIBE TABLE IT_ZTITIG06 LINES G_LINE.
    IF G_LINE EQ 0.
      MESSAGE E874 WITH '통관관련'.
    ENDIF.
*****************************************
  ENDIF.

*  CHECK g_answer EQ 'Y'.


ENDFORM.                    " p1101_check_input_value
*&---------------------------------------------------------------------*
*&      Form  p3810_fill_celltab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P3810_FILL_CELLTAB  USING    P_MODE
                         CHANGING PT_CELLTAB TYPE LVC_T_STYL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         L_MODE     TYPE RAW4.

  DATA : BEGIN OF L_FIELDCAT,
           ROW_POS(04),
           COL_POS(04),
           FIELDNAME(30),
         END OF L_FIELDCAT.

  LOOP AT IT_FIELDCAT_G INTO GS_FIELDCAT_G.
    LS_CELLTAB-FIELDNAME = GS_FIELDCAT_G-FIELDNAME.

    IF GS_FIELDCAT_G-FIELDNAME = 'WRBTR'   OR
       GS_FIELDCAT_G-FIELDNAME = 'WMWST'   OR
       GS_FIELDCAT_G-FIELDNAME = 'FWBAS'   OR
       GS_FIELDCAT_G-FIELDNAME = 'LIFNR'   OR
       GS_FIELDCAT_G-FIELDNAME = 'MWSKZ'   OR
       GS_FIELDCAT_G-FIELDNAME = 'ZFBDT'   OR
       GS_FIELDCAT_G-FIELDNAME = 'BOX'.

      IF GS_FIELDCAT_G-FIELDNAME = 'BOX' .
        IF P_MODE EQ 'W'.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
          INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
        ENDIF.
        CONTINUE.
      ENDIF.

      CASE GS_DISP-CSTCL.
        WHEN '2'.    ">부가세.
          IF GS_FIELDCAT_G-FIELDNAME EQ 'WRBTR' OR
             GS_FIELDCAT_G-FIELDNAME EQ 'ZFBDT'.
            LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
            INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
          ELSE.
            IF P_MODE EQ 'W'.
              LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
              INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
            ELSE.
              LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
              INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
            ENDIF.
          ENDIF.
        WHEN 'Z'.    ">관세사 수수료.
          IF P_MODE EQ 'W'.
            LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
            INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
          ELSE.
            LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
            INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
          ENDIF.
        WHEN '1' OR 'B' OR 'C' OR 'D'.    ">관세.
          IF GS_FIELDCAT_G-FIELDNAME EQ 'WRBTR' OR
             GS_FIELDCAT_G-FIELDNAME EQ 'LIFNR' OR
             GS_FIELDCAT_G-FIELDNAME EQ 'ZFBDT'.
            IF P_MODE EQ 'W'.
              LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
              INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
            ELSE.
              LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
              INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
            ENDIF.
          ELSE.
            LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
            INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
          ENDIF.
        WHEN OTHERS.
          IF NOT GS_DISP-CSTCL IS INITIAL.
            IF GS_FIELDCAT_G-FIELDNAME EQ 'WRBTR' OR
               GS_FIELDCAT_G-FIELDNAME EQ 'LIFNR' OR
               GS_FIELDCAT_G-FIELDNAME EQ 'ZFBDT'.
              IF P_MODE EQ 'W'.
                LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
                INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
              ELSE.
                LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
                INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
              ENDIF.
            ELSE.
              LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
              INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
            ENDIF.
          ELSE.
            IF GS_FIELDCAT_G-FIELDNAME EQ 'WRBTR' OR
               GS_FIELDCAT_G-FIELDNAME EQ 'WMWST' OR
               GS_FIELDCAT_G-FIELDNAME EQ 'FWBAS' OR
               GS_FIELDCAT_G-FIELDNAME EQ 'LIFNR' OR
               GS_FIELDCAT_G-FIELDNAME EQ 'MWSKZ' OR
               GS_FIELDCAT_G-FIELDNAME EQ 'ZFBDT'.
              IF P_MODE EQ 'W'.
                LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
                INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
              ELSE.
                LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
                INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
              ENDIF.
            ELSE.
              LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
              INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
            ENDIF.
          ENDIF.
      ENDCASE.
      IF NOT GS_DISP-ICSNO IS INITIAL.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
      ENDIF.
    ELSE.
      LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
      INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " p3810_fill_celltab
*&---------------------------------------------------------------------*
*&      Form  check_input_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE .

  CALL FUNCTION 'FI_VENDOR_DATA'
    EXPORTING
      I_BUKRS = ZTITCSK-BUKRS
      I_LIFNR = ZTITCSK-LIFNR
    IMPORTING
      E_KRED  = VF_KRED.

  ZTITCSK-XCPDK = VF_KRED-XCPDK.
  LFA1-NAME1    = VF_KRED-NAME1.

  IF ZTITCSK-ZTERM IS INITIAL.
    ZTITCSK-ZTERM = VF_KRED-ZTERM.
  ENDIF.

  IF SY-DYNNR EQ '0100'.
    CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
      EXPORTING
        I_BLDAT = ZTITCSK-BLDAT
        I_BUDAT = ZTITCSK-BUDAT
        I_CPUDT = SY-DATLO
*       i_zfbdt = ZTITCSK-zfbdt
        I_ZTERM = ZTITCSK-ZTERM
      IMPORTING
        E_ZBD1T = ZTITCSK-ZBD1T
        E_ZBD1P = ZTITCSK-ZBD1P
        E_ZBD2T = ZTITCSK-ZBD2T
        E_ZBD2P = ZTITCSK-ZBD2P
        E_ZBD3T = ZTITCSK-ZBD3T
        E_ZLSCH = ZTITCSK-ZLSCH
        E_ZSCHF = ZTITCSK-ZLSPR
        E_ZFBDT = ZTITCSK-ZFBDT.
  ELSE.
    CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
      EXPORTING
        I_BLDAT = ZTITCSK-BLDAT
        I_BUDAT = ZTITCSK-BUDAT
        I_CPUDT = SY-DATLO
*       i_zfbdt = ZTITCSK-zfbdt
        I_ZTERM = ZTITCSK-ZTERM
      IMPORTING
        E_ZBD1T = ZTITCSK-ZBD1T
        E_ZBD1P = ZTITCSK-ZBD1P
        E_ZBD2T = ZTITCSK-ZBD2T
        E_ZBD2P = ZTITCSK-ZBD2P
        E_ZBD3T = ZTITCSK-ZBD3T.
*      e_zlsch = ztitcsk-zlsch
*      e_zschf = ZTITCSK-zlspr
*      e_zfbdt = ztitcsk-zfbdt.
  ENDIF.

ENDFORM.                    " check_input_value
*&---------------------------------------------------------------------*
*&      Module  help_payment_term_scr0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HELP_PAYMENT_TERM_SCR0200 INPUT.

  LOOP AT SCREEN.
    IF SCREEN-NAME EQ 'ZTITCSK-ZTERM'.
      EXIT.
    ENDIF.
  ENDLOOP.

  PERFORM GET_F4_FOR_ZTERM_DYNPRO(ZTIR9000) USING ZTITCSK-ZTERM.

ENDMODULE.                 " help_payment_term_scr0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  help_payer_scr0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HELP_PAYER_SCR0200 INPUT.

  LOOP AT SCREEN.
    IF SCREEN-NAME EQ 'ZTITCSK-EMPKF'.
      IF SCREEN-INPUT EQ '1'.
        CLEAR: G_DISPLAY.
      ELSE.
        G_DISPLAY = 'X'.
      ENDIF.

      EXIT.
    ENDIF.
  ENDLOOP.

*> IMG화.
*  IF ztitig00-lfzac EQ 'P'.
*    CLEAR: g_bukrs.
*  ELSEIF ztitig00-lfzac EQ 'A'.
*    g_bukrs = ztitcsk-bukrs.
*  ENDIF.

  SELECT P~BUKRS P~LIFNR P~EMPFK H~NAME1
         INTO CORRESPONDING FIELDS OF TABLE XLFZA
         FROM   LFA1 AS H INNER JOIN LFZA AS P
         ON     H~LIFNR   EQ  P~EMPFK
         WHERE  P~BUKRS   EQ  G_BUKRS
         AND    P~LIFNR   EQ   ZTITCSK-LIFNR.

  IF SY-SUBRC NE 0.
    MESSAGE S854 WITH ZTITCSK-LIFNR.
    EXIT.
  ENDIF.

  DYNPROG = SY-REPID.
  DYNNR   = SY-DYNNR.

  G_WINDOW_TITLE = '대체 수취/지급인'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     RETFIELD        = 'OTYPE'
      RETFIELD        = 'EMPFK'
      DYNPPROG        = DYNPROG
      DYNPNR          = DYNNR
      DYNPROFIELD     = 'ZTITCSK-EMPFK'
      WINDOW_TITLE    = G_WINDOW_TITLE
      VALUE_ORG       = 'S'
      DISPLAY         = G_DISPLAY
    TABLES
      VALUE_TAB       = XLFZA
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.

ENDMODULE.                 " help_payer_scr0200  INPUT
*&---------------------------------------------------------------------*
*&      Form  set_selected_row
*&---------------------------------------------------------------------*
FORM SET_SELECTED_ROW  USING   P_MARK.
  CLEAR: G_COUNT.

  LOOP AT IT_DISP INTO GS_DISP.
    GS_DISP-BOX = P_MARK.
    MODIFY IT_DISP FROM GS_DISP.

    IF P_MARK = 'X'.
      G_COUNT = G_COUNT + 1.
    ENDIF.
  ENDLOOP.

  IF G_COUNT <> 0.
    MESSAGE S883 WITH G_COUNT.
  ENDIF.

  CALL METHOD G_GRID->REFRESH_TABLE_DISPLAY.
ENDFORM.                    " set_selected_row
*&---------------------------------------------------------------------*
*&      Form  build_posting_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_POSTING_DATA .

*> 데이타 체크.
  LOOP AT IT_DISP INTO GS_DISP WHERE BOX = 'X'.

    G_TABIX  =  SY-TABIX.

    CLEAR: GS_DISP-ERRMD.

*> 전기여부체크.
    IF NOT GS_DISP-ICSNO IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      IF NOT GS_DISP-BELNR IS INITIAL.
        MESSAGE S132 WITH GS_DISP-ICCNO ' ' '전기'.
      ELSE.
        MESSAGE S132 WITH GS_DISP-ICCNO ' ' '생성'.
      ENDIF.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.

*> 전표유형.
    IF GS_DISP-BLART IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S508 WITH GS_DISP-ICCNO '전표유형'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.

*> 공급업체.
    IF GS_DISP-LIFNR IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S508 WITH GS_DISP-ICCNO '공급업체'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.

*> 사업장.
    IF GS_DISP-BUPLA IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S508 WITH GS_DISP-ICCNO '사업장'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.

*> 트랜잭션유형.
    IF GS_DISP-MWSKZ IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S508 WITH GS_DISP-ICCNO '세금코드'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.
*> 전기방법.
    IF GS_DISP-CSCTY IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S508 WITH GS_DISP-ICCNO '전기방법'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.
*> 전기유형.
    IF GS_DISP-CSTYP IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S508 WITH GS_DISP-ICCNO '전기 유형'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.

*> 트랜잭션유형.
    IF GS_DISP-VORGANG IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S508 WITH GS_DISP-ICCNO '트랜잭션유형'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.

*> 금액.
    IF GS_DISP-WRBTR IS INITIAL AND
       GS_DISP-WMWST IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S508 WITH GS_DISP-ICCNO  '통관비용 및 부가세'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.

*> 과세표준액.
    IF NOT GS_DISP-WMWST IS INITIAL AND
           GS_DISP-FWBAS IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S508 WITH GS_DISP-ICCNO '과세표준액'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.

*> 통화금액.
    IF GS_DISP-WAERS IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S508 WITH GS_DISP-ICCNO '통화'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.

    IF GS_DISP-ERRMD IS INITIAL.
      ADD 1 TO ZTISSCRCOM-ITCNT.
      CLEAR:IT_COLLECT.
*> 공급업체+세금코드+사업장별 Collect.
      MOVE: GS_DISP-LIFNR   TO  IT_COLLECT-LIFNR.
      MOVE: GS_DISP-BLART   TO  IT_COLLECT-BLART.
      MOVE: GS_DISP-MWSKZ   TO  IT_COLLECT-MWSKZ.
      MOVE: GS_DISP-BUPLA   TO  IT_COLLECT-BUPLA.
      MOVE: GS_DISP-WRBTR   TO  IT_COLLECT-WRBTR.
      MOVE: GS_DISP-DMBTR   TO  IT_COLLECT-DMBTR.
      MOVE: GS_DISP-WMWST   TO  IT_COLLECT-WMWST.
      MOVE: GS_DISP-FWBAS   TO  IT_COLLECT-FWBAS.
      MOVE: GS_DISP-HWAER   TO  IT_COLLECT-HWAER.
      MOVE: GS_DISP-WAERS   TO  IT_COLLECT-WAERS.
      MOVE: GS_DISP-CSTYP   TO  IT_COLLECT-CSTYP.
      MOVE: GS_DISP-CSCTY   TO  IT_COLLECT-CSCTY.
      MOVE: GS_DISP-VORGANG TO  IT_COLLECT-VORGANG.
      MOVE: GS_DISP-ZFBDT   TO  IT_COLLECT-ZFBDT.
      COLLECT IT_COLLECT.
    ENDIF.
    MODIFY IT_DISP FROM GS_DISP INDEX G_TABIX.
  ENDLOOP.

ENDFORM.                    " build_posting_data
*&---------------------------------------------------------------------*
*&      Form  fill_posting_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_POSTING_DATA .

  DATA: L_ICSNO(5) TYPE N,
        L_ICSSQ    TYPE ZTIICSSQ.

  CLEAR: L_ICSNO.
*  BREAK-POINT.
************************************************************************
*> 일괄전기일 경우...
************************************************************************
  IF ZTISSCRCOM-MONSC EQ 'S'.
    LOOP AT IT_COLLECT.
      ADD 1 TO L_ICSNO.
*> Header data Move
      PERFORM SET_HEADER_DATA_BY_COLLECT USING L_ICSNO  'C'.

*---> Item data Move
      CLEAR: L_ICSSQ.
      LOOP AT IT_DISP INTO GS_DISP
                       WHERE LIFNR   EQ IT_COLLECT-LIFNR
                         AND BUPLA   EQ IT_COLLECT-BUPLA
                         AND MWSKZ   EQ IT_COLLECT-MWSKZ
                         AND WAERS   EQ IT_COLLECT-WAERS
                         AND HWAER   EQ IT_COLLECT-HWAER
                         AND BLART   EQ IT_COLLECT-BLART
                         AND CSTYP   EQ IT_COLLECT-CSTYP
                         AND VORGANG EQ IT_COLLECT-VORGANG
                         AND ZFBDT   EQ IT_COLLECT-ZFBDT
                         AND CSCTY   EQ IT_COLLECT-CSCTY
                         AND BOX   EQ 'X'
                         AND ERRMD EQ SPACE.

        CLEAR: IT_ZTITCSP.
        ADD 1 TO L_ICSSQ.

        PERFORM SET_ITEM_DATA   USING L_ICSNO  L_ICSSQ  'C'.
      ENDLOOP.
    ENDLOOP.
  ELSE.
************************************************************************
*> 개별전기일 경우...
************************************************************************
    LOOP AT IT_DISP INTO GS_DISP WHERE BOX   EQ 'X'
                                   AND ERRMD EQ SPACE.
      ADD 1 TO L_ICSNO.
*> Header data Move
      PERFORM SET_HEADER_DATA_BY_INDIVIDUAL USING L_ICSNO  'C'.
*---> Item data Move
      CLEAR: L_ICSSQ.
      ADD 1 TO L_ICSSQ.
      PERFORM SET_ITEM_DATA   USING L_ICSNO  L_ICSSQ  'C'.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " fill_posting_data
*&---------------------------------------------------------------------*
*&      Form  p9000_refresh_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P9000_REFRESH_DISPLAY.
  GS_STABLE-ROW = 'X'.
  GS_STABLE-COL = 'X'.

  CALL METHOD G_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = GS_STABLE.
ENDFORM.                    " p9000_refresh_display
*&---------------------------------------------------------------------*
*&      Form  refresh_confirm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM REFRESH_CONFIRM  USING    P_ANSWER.
  DATA: L_CANCEL_DISPLAY.

  DATA: BEGIN OF POP,
          TITEL     LIKE SPOP-TITEL,
          DIAGNOSE1 LIKE SPOP-DIAGNOSE1,
          DIAGNOSE2 LIKE SPOP-DIAGNOSE2,
          DIAGNOSE3 LIKE SPOP-DIAGNOSE3,
          TEXTLINE1 LIKE SPOP-TEXTLINE1,
          TEXTLINE2 LIKE SPOP-TEXTLINE2,
          TEXTLINE3 LIKE SPOP-TEXTLINE3,
          OPTION1   LIKE SPOP-VAROPTION1,
          OPTION2   LIKE SPOP-VAROPTION2,
          DEFAULT,             "defaultoption fuer Confirm_step
          ANSWER,
        END OF POP.

  CLEAR : POP, L_CANCEL_DISPLAY.

  MOVE: '입력(수정)된 데이타가 손실됩니다.' TO POP-DIAGNOSE1,
        '최신정보로 수정하시겠습니까?'                 TO POP-TEXTLINE1,
        '확인'                              TO POP-TITEL.

  CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
    EXPORTING
      DIAGNOSETEXT1  = POP-DIAGNOSE1
*     diagnosetext2  = pop-diagnose2
*     DIAGNOSETEXT3  = ' '
      TEXTLINE1      = POP-TEXTLINE1
      TEXTLINE2      = POP-TEXTLINE2
      TITEL          = POP-TITEL
*     START_COLUMN   = 25
*     START_ROW      = 6
      CANCEL_DISPLAY = L_CANCEL_DISPLAY
    IMPORTING
      ANSWER         = POP-ANSWER
    EXCEPTIONS
      OTHERS         = 1.

  P_ANSWER = POP-ANSWER.
ENDFORM.                    " refresh_confirm
*&---------------------------------------------------------------------*
*&      Form  get_input_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_INPUT_VALUE  USING    P_WRBTR
                               P_WMWST
                               P_FWBAS
                               P_MWSKZ
                               P_HWAER
                               PR_DATA_CHANGED
                               TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                               PS_MOD_CELLS TYPE LVC_S_MODI.

*> 공급가액.
  CALL METHOD PR_DATA_CHANGED->GET_CELL_VALUE
    EXPORTING
      I_ROW_ID    = PS_MOD_CELLS-ROW_ID
      I_FIELDNAME = 'WRBTR'
    IMPORTING
      E_VALUE     = P_WRBTR.
*> 세액.
  CALL METHOD PR_DATA_CHANGED->GET_CELL_VALUE
    EXPORTING
      I_ROW_ID    = PS_MOD_CELLS-ROW_ID
      I_FIELDNAME = 'WMWST'
    IMPORTING
      E_VALUE     = P_WMWST.

*> 과세표준액.
  CALL METHOD PR_DATA_CHANGED->GET_CELL_VALUE
    EXPORTING
      I_ROW_ID    = PS_MOD_CELLS-ROW_ID
      I_FIELDNAME = 'FWBAS'
    IMPORTING
      E_VALUE     = P_FWBAS.

* 통화.
  CALL METHOD PR_DATA_CHANGED->GET_CELL_VALUE
    EXPORTING
      I_ROW_ID    = PS_MOD_CELLS-ROW_ID
      I_FIELDNAME = 'WAERS'
    IMPORTING
      E_VALUE     = P_HWAER.

*> 세금코드.
  CALL METHOD PR_DATA_CHANGED->GET_CELL_VALUE
    EXPORTING
      I_ROW_ID    = PS_MOD_CELLS-ROW_ID
      I_FIELDNAME = 'MWSKZ'
    IMPORTING
      E_VALUE     = P_MWSKZ.

ENDFORM.                    " get_input_value
*&---------------------------------------------------------------------*
*&      Form  p3800_set_title_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM P3800_SET_TITLE_TEXT .

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: L_BUTXT LIKE T001-BUTXT,
        L_TITLE TYPE LVC_TITLE.
  CLEAR: L_BUTXT, L_TITLE.
  SELECT SINGLE BUTXT FROM T001
                      INTO L_BUTXT
                     WHERE BUKRS EQ S_BUKRS-LOW.

  CONCATENATE '회사코드:' S_BUKRS-LOW L_BUTXT
         INTO L_TITLE SEPARATED BY SPACE.

  CALL METHOD G_GRID->SET_GRIDTITLE
    EXPORTING
      I_GRIDTITLE = L_TITLE.
** JS전선 회사코드 2007/04 KSH --------------------------------------

ENDFORM.                    " p3800_set_title_text
*&---------------------------------------------------------------------*
*&      Form  CHOOSE_ETAX_UNMATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHOOSE_ETAX_UNMATCH USING P_INDEX.

  IF GS_DISP-ICON = ICON_GREEN_LIGHT.
    MESSAGE S999 WITH '이미 처리된 내역입니다'.
    EXIT.
  ENDIF.



  DATA: L_LIFNR  LIKE LFA1-LIFNR,
        L_SU_ID  LIKE LFA1-STCD2,
        LV_COUNT TYPE N LENGTH 3.

  CLEAR : LV_COUNT.

  DATA: LR_ISSUE_DATE LIKE TABLE OF RANGE_DATE WITH HEADER LINE.
  DATA: LT_ETAX_AP_HEAD LIKE TABLE OF ZDTV3T_AP_HEAD WITH HEADER LINE.

  SELECT SINGLE STCD2
    INTO  L_SU_ID
    FROM LFA1
    WHERE LIFNR = GS_DISP-LIFNR.

*  LR_ISSUE_DATE[] = S_ERDAT[].
  IF LR_ISSUE_DATE[] IS INITIAL.
    LR_ISSUE_DATE-SIGN   = 'I'.
    LR_ISSUE_DATE-OPTION = 'BT'.


    PERFORM SET_ISSUE_DATE IN PROGRAM ZTER7130_NEW IF FOUND
                          TABLES LR_ISSUE_DATE.

    LR_ISSUE_DATE-HIGH   = SY-DATUM.
    APPEND LR_ISSUE_DATE.
  ENDIF.

  CALL FUNCTION 'Z_FI_ETAX_PURCH_LIST'
    EXPORTING
      I_BUKRS        = S_BUKRS-LOW
      I_LIFNR        = GS_DISP-LIFNR
      I_SU_ID        = L_SU_ID
      I_MATCH        = ' '
      I_POPUPX       = 'X'
      I_ONLYONE      = 'X'
    TABLES
      I_ISSUE_DATE   = LR_ISSUE_DATE
      O_ETAX_AP_HEAD = LT_ETAX_AP_HEAD.

  CHECK LT_ETAX_AP_HEAD[] IS NOT INITIAL.

  LV_COUNT = LINES( LT_ETAX_AP_HEAD ).
  READ TABLE LT_ETAX_AP_HEAD.

  READ TABLE GT_ZMMT0312 WITH KEY INV_SEQ = LT_ETAX_AP_HEAD-INV_SEQ.

  IF SY-SUBRC = 0.
    MESSAGE S000 WITH '이미 지정된 매입계산서 입니다.'
      DISPLAY LIKE 'E'.
    EXIT.
  ELSEIF LV_COUNT <> 1 .
    MESSAGE S000 WITH '한개의 매입계산서만 지정 가능합니다.'
      DISPLAY LIKE 'E'.
    EXIT.
  ELSE.
    GS_DISP-INV_SEQ = LT_ETAX_AP_HEAD-INV_SEQ.
    CLEAR GS_DISP-BUTTON .

    IF GS_DISP-WAERS = 'KRW'.
      GS_DISP-WRBTR = LT_ETAX_AP_HEAD-CHARGETOTAL.

      IF LT_ETAX_AP_HEAD-TAXTOTAL IS NOT INITIAL.
        GS_DISP-WMWST = LT_ETAX_AP_HEAD-TAXTOTAL.
        GS_DISP-FWBAS = LT_ETAX_AP_HEAD-CHARGETOTAL.
      ENDIF.
    ENDIF.


    GS_DISP-DESC_TEXT1   = LT_ETAX_AP_HEAD-DESC_TEXT1.
    GS_DISP-BOX = 'X'.
    MODIFY IT_DISP FROM GS_DISP INDEX P_INDEX.
  ENDIF.

  MOVE-CORRESPONDING GS_DISP TO GT_ZMMT0312.
  GT_ZMMT0312-BUPLA       = LT_ETAX_AP_HEAD-BUPLA.
  GT_ZMMT0312-ISSUE_DATE  = LT_ETAX_AP_HEAD-ISSUE_DATE.
  GT_ZMMT0312-CHARGETOTAL = LT_ETAX_AP_HEAD-CHARGETOTAL.
  GT_ZMMT0312-TAXTOTAL    = LT_ETAX_AP_HEAD-TAXTOTAL.
  GT_ZMMT0312-GRANDTOTAL  = LT_ETAX_AP_HEAD-GRANDTOTAL.
  APPEND GT_ZMMT0312.   CLEAR : GT_ZMMT0312.


  PERFORM P9000_REFRESH_DISPLAY.

ENDFORM.                    " CHOOSE_ETAX_UNMATCH
*&---------------------------------------------------------------------*
*&      Form  SET_ZDTV3T_AP_EXT_USE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_ZDTV3T_AP_EXT_USE_DOC .


  CHECK GT_ZMMT0312[] IS NOT INITIAL.

  LOOP AT IT_DISP INTO GS_DISP WHERE INV_SEQ <> ' '
                                 AND BOX = 'X'.
    CLEAR : GT_ZMMT0312.
    READ TABLE IT_ZTITCSK INDEX 1.

    READ TABLE IT_ZTITCSP WITH KEY REFNO = GS_DISP-ICCNO
                                   EXPCD = GS_DISP-EXPCD.

    IF  SY-SUBRC NE 0  OR IT_ZTITCSK-BELNR IS INITIAL.
      CONTINUE.
    ENDIF.


    READ TABLE GT_ZMMT0312  WITH KEY ICCNO = GS_DISP-ICCNO
                                     EXPCD = GS_DISP-EXPCD.

*   전자세금과 연결여부 설정
    UPDATE ZDTV3T_AP_EXT
       SET USE_DOC = 'X'
    WHERE BUKRS      EQ IT_ZTITCSK-BUKRS
      AND ISSUE_DATE EQ GT_ZMMT0312-ISSUE_DATE
      AND BUPLA      EQ GT_ZMMT0312-BUPLA
      AND INV_SEQ    EQ GT_ZMMT0312-INV_SEQ.


*   전자세금상세에 연결된 전표번호 설정
    UPDATE ZDTV3T_AP_EXT_D
       SET  BELNR = IT_ZTITCSK-BELNR
            ZGJAH = IT_ZTITCSK-BUDAT(4)
            BUDAT = IT_ZTITCSK-BUDAT
            BLDAT = IT_ZTITCSK-BLDAT
            BLART = IT_ZTITCSK-BLART
            MWSKZ = IT_ZTITCSK-MWSKZ
            DMBTR = IT_ZTITCSK-DMBTR
     WHERE BUKRS  = IT_ZTITCSK-BUKRS
       AND ISSUE_DATE = GT_ZMMT0312-ISSUE_DATE
       AND BUPLA      = GT_ZMMT0312-BUPLA
      AND INV_SEQ     = GT_ZMMT0312-INV_SEQ.

    GT_ZMMT0312-ICSNO = IT_ZTITCSK-ICSEX .
    GT_ZMMT0312-ICSSQ = IT_ZTITCSP-ICSSQ.
    GT_ZMMT0312-BUKRS = GS_DISP-BUKRS.
    GT_ZMMT0312-BELNR = IT_ZTITCSK-BELNR.
    GT_ZMMT0312-GJAHR = IT_ZTITCSK-BUDAT(4).
    GT_ZMMT0312-CHARGETOTAL = IT_ZTITCSK-DMBTR.
    GT_ZMMT0312-ERDAT = SY-DATUM.
    GT_ZMMT0312-UZEIT = SY-UZEIT.
    GT_ZMMT0312-UNAME = SY-UNAME.
    MODIFY ZMMT0312 FROM GT_ZMMT0312.
  ENDLOOP.

  CLEAR : GT_ZMMT0312, GT_ZMMT0312[].

ENDFORM.                    " SET_ZDTV3T_AP_EXT_USE_DOC
