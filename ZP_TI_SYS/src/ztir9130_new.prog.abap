************************************************************************
* Title         :  ZTIR9130                                            *
*                                                                      *
* Description   : [Report] B/L  관련비용 관리                          *
*                                                                      *
* Creation Date : 2004/02/14                                           *
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
* Date         Programmer   Transport#  Description                    *
*----------------------------------------------------------------------*
* 2019.04.19   권민선       [기능개선_275072]공급업체, 공급업체명 추가 *
*                           비용처리업체, 비용처리업체명으로 필드 수정 *
* 2019.05.29   신재호       [기능개선 281197]                          *
*                           국내영세율일때 사업자등록번호 지정란에 입력*
* 2019.07.02   신재호       [기능개선 283274]                          *
*                           비용코드 변경에 따른 수정                  *
* 2019.10.22   신재호       [기능개선 294519] 항공 운임 1의자리 절삭   *
* 2020.05.27   박성수       [기능개선 321231] 항공운임 1의자리 절삭해제*
* 2020.10.14   이원형       [기능개선 CHM2010-00297] 보세운송면허수수료*
*                        고정비용 공급가액 10,000원 세액 1,000원  설정 *
* 2021/12/20   송승규     [제목] 매입세금계산서 매핑                   *
*                         [요청번호] CHM2110-00555                     *
************************************************************************
REPORT  ZTIR9130       MESSAGE-ID ZMTI00
                       NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: SLIS,   "> Globale Type(ALV)
            KKBLO.  "> Generic list types

TYPES:  BEGIN OF TY_LIST.
          INCLUDE STRUCTURE ZTISBLCS.
TYPES :   CELLTAB TYPE LVC_T_STYL.            " Cell단위 수정 스타일
TYPES:  END   OF TY_LIST.

************************************************************************
* SAP Include Define                                                   *
************************************************************************
INCLUDE : <ICON>,
          <SYMBOL>,
          ZTS_REUSE_BDC_SUBROUTINE_F00.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: L_YN    TYPE C.
INCLUDE ZTS_AUTHORIZATION_CHECK. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

*---------------------------------------------------------------------*
*> Message dialog box용                                               *
*---------------------------------------------------------------------*
DATA: BEGIN OF IT_MSG  OCCURS 0.
        INCLUDE STRUCTURE ZTISMESSAGE.
DATA: END   OF IT_MSG.

************************************************************************
* SAP Tables                                                           *
************************************************************************
TABLES: ZTITCSK,
*        ztstiga,
        ZTISSCRCOM,
        ZTITCSO, ">one time vendor.
        ICON.

TABLES: T001,
        T005,
        LFA1,
        *LFA1,
        EKPO,
        ZTITIG00,     ">[TraSys] 회사별 프로세스 정의.
        ZTITIG07,     ">[TraSys]  제비용 일괄전기 Default Value관리.
        VF_KRED,
        ZTITRQK,
        ZTITRQS,
        ZTITCSP,
        ZTIVCS00,
        ZTITIG06,
        ZTITBLK,
        ZTITBLP,
        ZTIVBL00,
        ZTISBLCS.

TABLES: BAPI1093_0,
        BAPICURX,
        BAPIRET1.

************************************************************************
* SAP Views                                                            *
************************************************************************
TABLES: ZTIVIP01.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
CONSTANTS:
** JS전선 회사코드 2007/04 BY-MH.LEE------------------
*    c_bukrs     LIKE t001-bukrs     VALUE '1000',   ">Company code
** JS전선 회사코드 2007/04 ---------------------------
    C_TCODE     LIKE SY-TCODE       VALUE 'ZTIR913'.
************************************************************************
* Internal Tables                                                      *
************************************************************************
*> Select용.
DATA: IT_DISP TYPE STANDARD TABLE OF TY_LIST,
      IT_SELD TYPE STANDARD TABLE OF TY_LIST,
      IT_TEMP TYPE STANDARD TABLE OF TY_LIST,
      GS_DISP TYPE TY_LIST.

DATA: BEGIN OF IT_VENDOR  OCCURS 2,
        LIFNR TYPE LIFNR,
      END   OF IT_VENDOR.

DATA: BEGIN OF IT_MWSKZ  OCCURS 2,
        MWSKZ TYPE MWSKZ,
      END   OF IT_MWSKZ.

DATA: BEGIN OF IT_BUPLA  OCCURS 2,
        BUPLA TYPE BUPLA,
      END   OF IT_BUPLA.

DATA: BEGIN OF LT_COLLECT  OCCURS 2,
        LIFNR TYPE LIFNR,
        BUPLA TYPE BUPLA,
        MWSKZ TYPE MWSKZ,
      END   OF LT_COLLECT.

DATA: BEGIN OF IT_CSTCL  OCCURS 2,
        CSTCL TYPE ZTICSTCL,
      END   OF IT_CSTCL.

*> 비용코드.
DATA: BEGIN OF IT_ZTITIG06  OCCURS 2.
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

"[CHM2110-00555]
DATA : GT_ZMMT0311 TYPE TABLE OF ZMMT0311 WITH HEADER LINE.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
* Fieldcatalog Grid
DATA: IT_FIELDCAT_G TYPE LVC_T_FCAT,
      GS_FIELDCAT_G LIKE LINE OF IT_FIELDCAT_G.

*icon
DATA: G_LIGHTS_NAME TYPE LVC_CIFNM VALUE 'ICON'.

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
DATA:  GS_F4        TYPE LVC_S_F4.      " F4 필드 관련
DATA:  IT_F4        TYPE LVC_T_F4.
DATA:  WS_F4        TYPE DDSHRETVAL.

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
      G_PROCESS      TYPE C,
      G_COUNT        TYPE I,
      G_CNT          TYPE I,
      G_WRBTR        TYPE WRBTR,
      G_WMWST        TYPE WMWST,
      G_FWBAS        TYPE FWBAS,
      OK_CODE        LIKE SY-UCOMM,
      G_SUCCESS      TYPE I,
      G_ERROR        TYPE I,
      G_LINE         TYPE I,
      G_LINEN(3)     TYPE N,
      G_OUT_TEXT(70) TYPE C.
DATA: OK-CODE             LIKE SY-DATUM.

* Possible Entry
DATA : IT_VALUES TYPE TABLE OF SEAHLPRES,
       IT_FIELDS TYPE TABLE OF DFIES,
       GS_VALUE  TYPE SEAHLPRES,
       GS_FIELD  TYPE DFIES,

*       ls_f4     TYPE ddshretval,
       GS_MODI   TYPE LVC_S_MODI.

* define fields and field-symbols for data-update
FIELD-SYMBOLS : <F4TAB> TYPE LVC_T_MODI.

* POSSIBLE ENTRY HEADER TEXT
DATA : BEGIN OF IT_FIELD_TAB OCCURS 0.
         INCLUDE STRUCTURE DFIES.
DATA : END OF IT_FIELD_TAB.

*>>>
INCLUDE ZTI_REUSE_FORMS_FOR_FI_POSTING.

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK DBSEL WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:
    S_BUKRS  FOR ZTITRQK-BUKRS                "회사코드.
                      NO-EXTENSION NO INTERVALS OBLIGATORY
                      MEMORY ID BUK
                      MODIF  ID IOG ,
    S_EBELN  FOR ZTITBLK-EBELN MODIF ID IOG,  "구매조직.
    S_EKORG  FOR ZTITBLK-EKORG MODIF ID IOG,  "구매조직.
    S_EKGRP  FOR ZTITBLK-EKGRP MODIF ID IOG,  "구매그룹.
    S_IBLNO  FOR ZTITBLK-IBLNO MODIF ID IOG	   "B/L 관리번호.
                                MEMORY ID ZTIIBLNO,
    S_BLNUM  FOR ZTITBLK-BLNUM MODIF ID IOG,  "B/L 번호.
    S_BUPLA  FOR ZTITRQS-BUPLA,                  "사업장.
    S_MWSKZ  FOR ZTITCSK-MWSKZ,                  "세금코드.
    S_KNTTP  FOR EKPO-KNTTP,
    S_BLDTY  FOR ZTITBLK-BLDTY MODIF ID IOG,  "문서종류.
    S_RPTTY  FOR ZTITBLK-RPTTY MODIF ID IOG,  "수입신고구분.
    S_LIFNR  FOR ZTITBLK-LIFNR MODIF ID IOG,  "공급업체 계정번호.
    S_BLETD  FOR ZTITBLK-BLETD MODIF ID IOG,  "ETD(출발 예정 시각).
    S_BLETA  FOR ZTITBLK-BLETA MODIF ID IOG,  "ETA(도착 예정 시각).
    S_FWDTY  FOR ZTITBLK-FWDTY MODIF ID IOG,  "운송 방법.
    S_LPONR  FOR ZTITBLK-LPONR MODIF ID IOG,  "최종품목번호.
    S_WAERS  FOR ZTITBLK-WAERS MODIF ID IOG,  "통화키.
    S_CNAM   FOR ZTITRQS-CNAM  MODIF ID IOG,  "작성인.
    S_CDAT   FOR ZTITRQS-CDAT  MODIF ID IOG,  "생성일.
    S_UNAM   FOR ZTITRQS-UNAM  MODIF ID IOG,  "최종변경인.
    S_UDAT   FOR ZTITRQS-UDAT  MODIF ID IOG.  "변경일.
*  S_ERDAT  FOR ZTITBLK-BLDAT.  "[CHM2110-00555] 계산서발행일

  SELECTION-SCREEN ULINE.

  PARAMETERS: P_STEP1 RADIOBUTTON GROUP AB1 DEFAULT 'X',
              P_STEP2 RADIOBUTTON GROUP AB1,
              P_STEP3 RADIOBUTTON GROUP AB1.
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
  CHECK G_ANSWER EQ 'Y'.
*> 검색조건에 해당하는 데이타를 Select.
  PERFORM P2000_DATA_SELECTIONS.

************************************************************************
* END-OF-SELECTION Event                                               *
************************************************************************
END-OF-SELECTION.
  CHECK G_ANSWER EQ 'Y'.
  DESCRIBE TABLE IT_DISP LINES G_LINE.
  IF NOT G_LINE IS INITIAL.
*> PROGRESS Display.
    G_LINEN    = 90.
    G_OUT_TEXT = '리스트를 구성 중입니다 %99999%%'(P03).
    REPLACE '%99999%'(P99) WITH G_LINEN INTO G_OUT_TEXT.
    PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

*> Dynamic Data Table build
    PERFORM P3000_FIELD_CATEGORY_BUILD.
    PERFORM P3210_EXCLUDE_TABLE_BUILD   USING 'IT_EXCLUDE'.
    PERFORM P3500_SORT_TABLE_BUILD .
    PERFORM P3700_LAYOUT_BUILD.
    PERFORM P3800_FIELD_ATTRIBUTE_CHANGE.

    IF SY-TCODE NE C_TCODE.
      READ TABLE IT_DISP INTO GS_DISP INDEX 1.
      IF SY-SUBRC EQ 0.
        CLEAR: LFA1, ZTITBLK.
        SELECT SINGLE *
          FROM ZTITBLK
         WHERE IBLNO EQ GS_DISP-IBLNO.
        IF SY-SUBRC EQ 0.
          IF NOT GS_DISP-TRUCK IS INITIAL.
            SELECT SINGLE *
              FROM LFA1
             WHERE LIFNR EQ GS_DISP-TRUCK.
          ENDIF.
          MESSAGE S933.
        ELSE.
          MESSAGE S200 WITH GS_DISP-IBLNO.
        ENDIF.
      ENDIF.
    ENDIF.
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

ENDFORM.                    " p1000_alv_fields_initial
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
FORM P1001_INITIALIZATION .

  SET TITLEBAR 'T1000'.

*  GET PARAMETER ID 'BUK' FIELD s_bukrs-low.
*  s_bukrs-sign = 'I'.
*  s_bukrs-option = 'EQ'.
*  IF NOT s_bukrs-low IS INITIAL.
*    APPEND s_bukrs.
*  ENDIF.


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

  CHECK G_ANSWER EQ 'Y'.

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
*&      Form  P3000_field_category_build
*&---------------------------------------------------------------------*
FORM P3000_FIELD_CATEGORY_BUILD .

  DATA LS_FCAT TYPE LVC_S_FCAT.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME   = 'ZTISBLCS'
      I_INTERNAL_TABNAME = 'IT_DISP'
*     i_client_never_display = 'X'
    CHANGING
      CT_FIELDCAT        = IT_FIELDCAT_G[].

  LOOP AT IT_FIELDCAT_G INTO GS_FIELDCAT_G.
    CLEAR: GS_FIELDCAT_G-KEY.
    CASE GS_FIELDCAT_G-FIELDNAME.
      WHEN 'BOX'.
        GS_FIELDCAT_G-COLTEXT   = '선택'.
        GS_FIELDCAT_G-COL_OPT   = 'X'.
        GS_FIELDCAT_G-CHECKBOX  = 'X'.
        GS_FIELDCAT_G-COL_POS   = 1.
        GS_FIELDCAT_G-KEY       = 'X'.
      WHEN 'ICON'.
*        gs_fieldcat_g-key       = 'X'.
        GS_FIELDCAT_G-COLTEXT   = '전기'.
        GS_FIELDCAT_G-COL_OPT   = 'X'.
        GS_FIELDCAT_G-COL_POS   = 2.
        GS_FIELDCAT_G-KEY       = 'X'.

*      WHEN 'IBLNO'.
*        gs_fieldcat_g-key       = 'X'.
      WHEN 'BLNUM'.
*        gs_fieldcat_g-key       = 'X'.
        GS_FIELDCAT_G-HOTSPOT   = 'X'.
        GS_FIELDCAT_G-COL_OPT   = 'X'.
        GS_FIELDCAT_G-COL_POS   = 3.
        GS_FIELDCAT_G-KEY       = 'X'.
      WHEN 'BLDTX'.
        GS_FIELDCAT_G-COLTEXT   = '유형'.
        GS_FIELDCAT_G-OUTPUTLEN = 4.
*        gs_fieldcat_g-col_opt   = 'X'.
      WHEN 'EXPTX'.
        GS_FIELDCAT_G-COL_OPT   = 'X'.
      WHEN 'EBELN'.
        GS_FIELDCAT_G-COL_OPT   = 'X'.
      WHEN 'BLCNT'.
        GS_FIELDCAT_G-COL_OPT   = 'X'.
      WHEN 'WAERS'.
        GS_FIELDCAT_G-COL_OPT    = 'X'.
        GS_FIELDCAT_G-DO_SUM     = 'X'.
        GS_FIELDCAT_G-EDIT       = 'X'.
        GS_FIELDCAT_G-COL_POS    = 18.
      WHEN 'WRBTR'.
        GS_FIELDCAT_G-COLTEXT   = '공급가액'.
        GS_FIELDCAT_G-DO_SUM     = 'X'.
        GS_FIELDCAT_G-EDIT       = 'X'.
      WHEN 'WMWST' OR 'FWBAS'.
        GS_FIELDCAT_G-DO_SUM     = 'X'.
        GS_FIELDCAT_G-EDIT       = 'X'.
*        gs_fieldcat_g-col_opt    = 'X'.
*        gs_fieldcat_g-col_opt   = space.
        GS_FIELDCAT_G-OUTPUTLEN = 18.
      WHEN 'MWSKZ'.
*        gs_fieldcat_g-checktable = '!'.
        GS_FIELDCAT_G-EDIT       = 'X'.
        GS_FIELDCAT_G-COL_OPT    = 'X'.
        GS_FIELDCAT_G-F4AVAILABL = 'X'.
      WHEN 'BLART'.
        GS_FIELDCAT_G-COL_POS    = 18.
      WHEN 'BUPLA'.
        GS_FIELDCAT_G-OUTPUTLEN  = 8.
*        gs_fieldcat_g-no_out    = 'X'.
      WHEN 'LIFNR'.
        GS_FIELDCAT_G-COLTEXT   = '비용처리업체'. "기능개선_275072
        GS_FIELDCAT_G-CHECKTABLE = '!'.
        GS_FIELDCAT_G-EDIT       = 'X'.
        GS_FIELDCAT_G-F4AVAILABL = 'X'.
      WHEN 'NAME1'.
        GS_FIELDCAT_G-COLTEXT   = '비용처리업체명'."기능개선_275072
*        gs_fieldcat_g-coltext   = '공급업체명'.   "기능개선_275072
        GS_FIELDCAT_G-COL_OPT    = 'X'.
      WHEN 'NAME2'.
        GS_FIELDCAT_G-COLTEXT   = 'Trucker'.
        GS_FIELDCAT_G-COL_OPT    = 'X'.
*      WHEN 'NAME'.
*        gs_fieldcat_g-outputlen = 18.
*        gs_fieldcat_g-coltext   = '사업장'.
*      WHEN 'WRBTRA' OR  'WMWSTA' OR 'FWBASA'.
*        gs_fieldcat_g-COL_OPT   = SPACE.
      WHEN 'ICSNO'  OR 'BELNR'  OR
           'WAERSA'.
*        gs_fieldcat_g-edit      = 'X'.
        GS_FIELDCAT_G-COL_OPT   = 'X'.
*--{기능개선_275072 - 추가
      WHEN 'LIFNR3'.
        GS_FIELDCAT_G-COLTEXT   = '공급업체'.
        GS_FIELDCAT_G-NO_OUT = 'X'.
      WHEN 'NAME3'.
        GS_FIELDCAT_G-COLTEXT   = '공급업체명'.
        GS_FIELDCAT_G-NO_OUT = 'X'.
*--}기능개선_275072 - 2019.04.19

*-- [CHM2110-00555] 세금계산서 관련 필드 추가  -[s]
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


*-- [CHM2110-00555] 세금계산서 관련 필드 추가  -[e]

      WHEN OTHERS.
        GS_FIELDCAT_G-NO_OUT = 'X'.
    ENDCASE.
    MODIFY IT_FIELDCAT_G FROM GS_FIELDCAT_G.
  ENDLOOP.

ENDFORM.                    " P3000_field_category_build
*&---------------------------------------------------------------------*
*&      Form  p2000_data_selections
*&---------------------------------------------------------------------*
FORM P2000_DATA_SELECTIONS .

*> PROGRESS Display.
  G_LINEN    = 30.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

*> 수입의뢰 데이타 select.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE IT_TEMP
    FROM ZTITBLK AS K
   INNER JOIN J_1BBRANCH AS B
      ON K~BUKRS EQ B~BUKRS
     AND K~BUPLA EQ B~BRANCH
   INNER JOIN J_1BBRANCHT AS C
      ON B~BUKRS      EQ C~BUKRS
     AND B~BRANCH     EQ C~BRANCH
     AND B~BUPLA_TYPE EQ C~BUPLA_TYPE
   WHERE K~BUKRS  IN  S_BUKRS     "회사코드.
     AND K~EBELN  IN  S_EBELN
     AND K~IBLNO  IN  S_IBLNO
     AND K~BLNUM  IN  S_BLNUM
     AND K~BUPLA  IN  S_BUPLA  "사업장.
     AND K~BLDTY  IN  S_BLDTY
     AND K~RPTTY  IN  S_RPTTY
     AND K~EKORG  IN  S_EKORG
     AND K~EKGRP  IN  S_EKGRP
     AND K~LIFNR  IN  S_LIFNR
     AND K~BLETD  IN  S_BLETD
     AND K~BLETA  IN  S_BLETA
     AND K~FWDTY  IN  S_FWDTY
     AND K~LPONR  IN  S_LPONR
     AND K~WAERS  IN  S_WAERS
     AND K~CNAM   IN  S_CNAM
     AND K~CDAT   IN  S_CDAT
     AND K~UNAM   IN  S_UNAM
     AND K~UDAT   IN  S_UDAT.

  IF SY-SUBRC NE 0.
    MESSAGE S902.   EXIT.
  ENDIF.

  REFRESH: IT_DISP.
  LOOP AT IT_TEMP INTO GS_DISP.

    PERFORM GET_DOMAIN_VALUE_TEXT(ZTIR0000)  USING  'ZTIBLDTY'
                                                GS_DISP-BLDTY
                                                GS_DISP-BLDTX.


    PERFORM GET_DOMAIN_VALUE_TEXT(ZTIR0000)  USING  'ZTIRPTTY'
                                                GS_DISP-RPTTY
                                                GS_DISP-RPTTX.

*> 대표 PO
    SELECT EBELN
      INTO GS_DISP-EBELN
      FROM ZTITBLP UP TO 1 ROWS
     WHERE IBLNO  EQ  GS_DISP-IBLNO.
    ENDSELECT.

*>>>>>>> 계정지정범주 로직 추가....
    SELECT *
      FROM EKPO UP TO 1 ROWS
     WHERE EBELN EQ GS_DISP-EBELN
       AND KNTTP IN S_KNTTP.
    ENDSELECT.
    IF SY-SUBRC NE 0.
      CONTINUE.
    ENDIF.

*>  선택한 비용코드를 추가함.
    LOOP AT IT_ZTITIG06 WHERE BOX = 'X'.
      CLEAR : GS_DISP-WRBTR, GS_DISP-WMWST, GS_DISP-FWBAS.
      IF IT_ZTITIG06-CSTCL EQ 'O' OR   ">해상.
         IT_ZTITIG06-CSTCL EQ '+'.     ">조출료.
        IF GS_DISP-FWDTY NA 'OC'.  "==>
          CONTINUE.
        ENDIF.
        GS_DISP-WAERS = 'USD'.
      ELSEIF IT_ZTITIG06-CSTCL EQ 'R'. ">항공.
        IF GS_DISP-FWDTY NA 'AC'.  "==>
          CONTINUE.
        ENDIF.
        GS_DISP-WAERS = T001-WAERS.
      ELSE.
        GS_DISP-WAERS = T001-WAERS.
      ENDIF.
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

      IF IT_ZTITIG06-CSTCL EQ '+'.     ">조출료.
        MOVE '2' TO  GS_DISP-VORGANG.
      ENDIF.

      CLEAR: ZTIVCS00.
      SELECT *
        FROM ZTIVCS00 UP TO 1 ROWS
       WHERE BUKRS   EQ  T001-BUKRS
         AND EXPGR   EQ  IT_ZTITIG06-EXPGR
         AND EXPCD   EQ  IT_ZTITIG06-EXPCD
         AND REFNO   EQ  GS_DISP-IBLNO.
      ENDSELECT.

      IF SY-SUBRC EQ 0.
        IF P_STEP1 EQ 'X'.
          CONTINUE.
        ENDIF.
*> 비용문서 MOVE
        MOVE :
          ZTIVCS00-ICSNO  TO GS_DISP-ICSNO,  "수입비용 문서번호
          ZTIVCS00-ICSSQ  TO GS_DISP-ICSSQ,  "비용문서의 품목
          ZTIVCS00-BELNR  TO GS_DISP-BELNR,  "회계전표번호
          ZTIVCS00-GJAHR  TO GS_DISP-GJAHR,  "회계연도
          ZTIVCS00-MONAT  TO GS_DISP-MONAT,  "회계기간
          ZTIVCS00-WRBTR  TO GS_DISP-WRBTRA, "전표통화금액
          ZTIVCS00-WAERS  TO GS_DISP-WAERSA, "통화키
          ZTIVCS00-WAERS  TO GS_DISP-WAERS, "통화키
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
          ZTIVCS00-INV_SEQ    TO GS_DISP-INV_SEQ ,
          ZTIVCS00-DESC_TEXT1 TO GS_DISP-DESC_TEXT1,
          ZTIVCS00-ISSUE_DATE TO GS_DISP-ISSUE_DATE.
*-[CHM2110-00555]  세금계산서 매핑내역 -[e]

      ELSE.
        IF P_STEP2 EQ 'X'.
          CONTINUE.
        ENDIF.
        CLEAR ZTIVCS00.
      ENDIF.

*-<< 기능개선 283274 - 해상/항공 운임 자동 입력
      IF T001-BUKRS = '1000'.
        IF P_STEP1 EQ 'X'.

          DATA: LV_BLDAT LIKE ZTITBLK-BLDAT.
          CLEAR LV_BLDAT.
          CASE IT_ZTITIG06-EXPCD.
            WHEN 'AIR'.
              SELECT SINGLE BLDAT CFRAT CFRATC
                INTO (LV_BLDAT, GS_DISP-WRBTR, GS_DISP-WAERS)
                FROM ZTITBLK
               WHERE IBLNO = GS_DISP-IBLNO
                 AND FWDTY = 'A'.

            WHEN 'SEA'.
              SELECT SINGLE BLDAT CFRAT CFRATC
                INTO (LV_BLDAT, GS_DISP-WRBTR, GS_DISP-WAERS)
                FROM ZTITBLK
               WHERE IBLNO = GS_DISP-IBLNO
                 AND FWDTY = 'O'.
            WHEN OTHERS.
          ENDCASE.

          "운임이 KRW가 아닐경우 B/L 발행일 환율로 환산함
          IF GS_DISP-WRBTR IS NOT INITIAL AND GS_DISP-WAERS NE 'KRW'.
            DATA: LV_GSDTU  LIKE TCURR-GDATU.       "환율변환일자
            DATA: LV_UKURS  LIKE TCURR-UKURS.       "B/L선적일 환율
            CLEAR : LV_GSDTU, LV_UKURS.

            CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'
              EXPORTING
                INPUT  = LV_BLDAT
              IMPORTING
                OUTPUT = LV_GSDTU.

            SELECT SINGLE UKURS
              INTO LV_UKURS
              FROM TCURR
             WHERE KURST  = 'M'
               AND FCURR  = GS_DISP-WAERS
               AND TCURR  = 'KRW'
               AND GDATU  = LV_GSDTU.

            IF SY-SUBRC NE 0. "발행일 환율이 없을 경우 가장 최신 환율
              SELECT UKURS
                INTO LV_UKURS UP TO 1 ROWS
                FROM TCURR
               WHERE KURST  = 'M'
                 AND FCURR  = GS_DISP-WAERS
                 AND TCURR  = 'KRW'.
              ENDSELECT.
            ENDIF.

            GS_DISP-WRBTR = GS_DISP-WRBTR * LV_UKURS / 100.

*-기능개선 321231- 항공 운임 1의자리 절삭해제
*-<< 기능개선 294519 - 항공 운임 1의자리 절삭
*            IF GS_DISP-EXPCD = 'AIR'.
*              CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
*                EXPORTING
*                  I_RTYPE     = '-'     "절삭
*                  I_RUNIT     = '0.1'   "기준자리 수
*                  I_VALUE     = GS_DISP-WRBTR
*                IMPORTING
*                  E_VALUE_RND = GS_DISP-WRBTR.
*            ENDIF.
*->> 기능개선 294519
*-기능개선 321231 END.
            GS_DISP-WAERS = 'KRW'.
          ENDIF.
        ENDIF.
      ENDIF.
*->> 기능개선 283274


*> 기존처리된 비용여부 판단.
      CASE GS_DISP-LIVST.
        WHEN 'P'.
          GS_DISP-ICON = ICON_GREEN_LIGHT.
        WHEN 'N'.
          GS_DISP-ICON = ICON_YELLOW_LIGHT.
        WHEN OTHERS.
          GS_DISP-ICON = ICON_RED_LIGHT.
      ENDCASE.

*--{기능개선_275072 - 추가
      IF SY-TABIX = 1.
        GS_DISP-LIFNR3 = GS_DISP-LIFNR.
        SELECT SINGLE NAME1
          FROM LFA1
          INTO GS_DISP-NAME3
         WHERE LIFNR = GS_DISP-LIFNR3.
      ELSE.
        GS_DISP-LIFNR3 = GS_DISP-LIFNR3.
        GS_DISP-NAME3  = GS_DISP-NAME3.
      ENDIF.

*--}기능개선_275072 - 2019.04.19
      GS_DISP-LIFNR = GS_DISP-FWDCD.

      IF NOT GS_DISP-LIFNR IS INITIAL.
        SELECT SINGLE NAME1
          INTO GS_DISP-NAME1
          FROM LFA1
         WHERE LIFNR EQ GS_DISP-LIFNR.
      ENDIF.

*      IF NOT GS_DISP-truck IS INITIAL.
*        SELECT SINGLE name1
*          INTO GS_DISP-name2
*          FROM lfa1
*         WHERE lifnr EQ GS_DISP-truck.
*      ENDIF.
*
*
      GS_DISP-KALSM = T005-KALSM.
      GS_DISP-REFNO = GS_DISP-IBLNO.
      GS_DISP-DOCNM = GS_DISP-BLNUM.

*--}기능개선 CHM2010-00297



      IF GS_DISP-ICON EQ '@0A@'.
        IF GS_DISP-EXPCD  EQ 'BTC' AND
             GS_DISP-BUKRS EQ '1000'.

*           SY-UNAME EQ '20140037' .
          GS_DISP-WRBTR = '100'.            "공급가액
          GS_DISP-WMWST = '10'.             "세액
          GS_DISP-FWBAS  = '100'.             "과세 표준 금액
        ENDIF.
      ENDIF.

*--}기능개선 CHM2010-00297 2020.10.27


*-[CHM2110-00555]  세금계산서 매핑   -[s]
*      IF S_BUKRS-LOW = 3000.
*        CLEAR: GS_DISP-INV_SEQ, GS_DISP-DESC_TEXT1.
*        SELECT SINGLE INV_SEQ DESC_TEXT1
*          INTO (GS_DISP-INV_SEQ , GS_DISP-DESC_TEXT1)
*          FROM ZMMT0311
*          WHERE IBLNO = GS_DISP-IBLNO
*          AND   EXPCD = GS_DISP-EXPCD
*          AND   BUKRS = GS_DISP-BUKRS
*          AND   ICSNO = GS_DISP-ICSNO .
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
*
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
  SET TITLEBAR  'T1000'.

  PERFORM CREATE_AND_INIT_CONTROLS_0100.

ENDMODULE.                 " pbo_scr0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  create_and_init_controls_0100
*&---------------------------------------------------------------------*
FORM CREATE_AND_INIT_CONTROLS_0100 .

*  IF g_custom_container IS INITIAL.

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

  IF G_GRID IS INITIAL.
* create the docking container
    CREATE OBJECT G_DOCKING
      EXPORTING
        REPID     = SY-REPID
        DYNNR     = SY-DYNNR
*       SIDE      = G_DOCKING->DOCK_AT_BOTTOM
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
          EVENT_RECEIVER->HANDLE_DOUBLE_CLICK          FOR G_GRID,
          EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK         FOR G_GRID,
          EVENT_RECEIVER->HANDLE_USER_COMMAND          FOR G_GRID,
          EVENT_RECEIVER->HANDLE_DATA_CHANGED_FINISHED FOR G_GRID,
          EVENT_RECEIVER->HANDLE_DATA_CHANGED          FOR G_GRID.

*    PERFORM p3201_f4_field_build.

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

  DATA: L_XAUTO TYPE C.

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
  MOVE '재조회'(120)        TO LS_TOOLBAR-QUICKINFO.
  MOVE ' 재조회'            TO LS_TOOLBAR-DISABLED.
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
* append an icon to show 전기버튼
  IF SY-TCODE EQ C_TCODE.
    CLEAR LS_TOOLBAR.
    MOVE 0                    TO LS_TOOLBAR-BUTN_TYPE.
    MOVE 'ZTIT901'            TO LS_TOOLBAR-FUNCTION.
    MOVE ICON_FINANCING       TO LS_TOOLBAR-ICON.
    MOVE '비용전기'(115)      TO LS_TOOLBAR-QUICKINFO.
    MOVE '비용전기'(115)      TO LS_TOOLBAR-TEXT.
    MOVE SPACE                TO LS_TOOLBAR-DISABLED.
    APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.
  ELSE.
* append an icon to show 전기버튼
    CLEAR LS_TOOLBAR.
    MOVE 0                    TO LS_TOOLBAR-BUTN_TYPE.
    MOVE 'ZTIT902'            TO LS_TOOLBAR-FUNCTION.
    MOVE ICON_FINANCING       TO LS_TOOLBAR-ICON.
    MOVE '비용전기'(115)      TO LS_TOOLBAR-QUICKINFO.
    MOVE '비용전기'(115)      TO LS_TOOLBAR-TEXT.
    MOVE SPACE                TO LS_TOOLBAR-DISABLED.
    APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.

  ENDIF.

  CLEAR LS_TOOLBAR.
  MOVE 0                    TO LS_TOOLBAR-BUTN_TYPE.
  MOVE 'ZTITINS'            TO LS_TOOLBAR-FUNCTION.
  MOVE ICON_CREATE          TO LS_TOOLBAR-ICON.
  MOVE ' 비용 항목추가 '    TO LS_TOOLBAR-QUICKINFO.
  MOVE ' 비용 항목추가 '    TO LS_TOOLBAR-TEXT.
  MOVE SPACE                TO LS_TOOLBAR-DISABLED.
  APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.


*  " [CHM2110-00555] 세금계산서 매핑
*  IF P_STEP2 IS NOT INITIAL.
*   CLEAR LS_TOOLBAR.
*   MOVE 0                    TO LS_TOOLBAR-BUTN_TYPE.
*   MOVE 'ZTIT002'            TO LS_TOOLBAR-FUNCTION.
*   MOVE ICON_CHECKED         TO LS_TOOLBAR-ICON.
*   MOVE ' 세금 계산서 매핑 '    TO LS_TOOLBAR-QUICKINFO.
*   MOVE ' 세금 계산서 매핑 '    TO LS_TOOLBAR-TEXT.
*   MOVE SPACE                TO LS_TOOLBAR-DISABLED.
*   APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.
*
*  " [CHM2110-00555] 세금계산서 매핑 삭제
*   CLEAR LS_TOOLBAR.
*   MOVE 0                    TO LS_TOOLBAR-BUTN_TYPE.
*   MOVE 'ZTIT003'            TO LS_TOOLBAR-FUNCTION.
*   MOVE ICON_CANCEL          TO LS_TOOLBAR-ICON.
*   MOVE ' 매핑 계산서 삭제 '    TO LS_TOOLBAR-QUICKINFO.
*   MOVE ' 매핑 계산서 삭제 '    TO LS_TOOLBAR-TEXT.
*   MOVE SPACE                TO LS_TOOLBAR-DISABLED.
*   APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.
* ENDIF.

ENDFORM.                    " handle_toolbar


*&--------------------------------------------------------------------*
*&      Form  handle_data_changed
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM  HANDLE_DATA_CHANGED  USING ER_DATA_CHANGED
                           TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.
  DATA : LS_MOD_CELLS TYPE LVC_S_MODI,
         LS_CELLS     TYPE LVC_S_MODI,
         LS_CHANGE    TYPE C,
         L_LIFNR      LIKE LFA1-LIFNR,
         L_NAME1      LIKE LFA1-NAME1,
         L_WRBTR      TYPE WRBTR,
         L_WMWST      TYPE WMWST,
         N_WMWST      TYPE WMWST,
         L_FWBAS      TYPE FWBAS,
         L_MWSKZ      TYPE MWSKZ,
         L_WAERS      TYPE WAERS,
         L_BOX        TYPE C.

*> 변경된 Cells 검증.
  LOOP AT ER_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.

    CLEAR LS_CHANGE.

    READ TABLE IT_DISP   INTO  GS_DISP
                 INDEX LS_MOD_CELLS-ROW_ID .
    IF SY-SUBRC NE 0.
      CONTINUE.
    ENDIF.

    CASE LS_MOD_CELLS-FIELDNAME.
      WHEN 'WRBTR'.     ">금액.
        PERFORM  GET_INPUT_VALUE   USING   L_WRBTR
                                           L_WMWST
                                           L_FWBAS
                                           L_MWSKZ
                                           L_WAERS
                                           ER_DATA_CHANGED
                                           LS_MOD_CELLS.

*> Checkbox Update
        IF L_WRBTR = 0.
          CLEAR L_BOX.
        ELSE.
          L_BOX = 'X'.
        ENDIF.

        CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = 'BOX'
            I_VALUE     = L_BOX.
*> 세액계산
        IF NOT L_MWSKZ IS INITIAL.
          CALL FUNCTION 'Z_TS_GET_AND_CALC_TAX_AMOUNT'
            EXPORTING
              IM_TAXTM = SPACE
              IM_WRBTR = L_WRBTR
              IM_WAERS = L_WAERS
              IM_BUKRS = ZTITIG00-BUKRS
              IM_MWSKZ = L_MWSKZ
            IMPORTING
              EX_WMWST = L_WMWST.

          CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = 'WMWST'
              I_VALUE     = L_WMWST.
        ENDIF.

* 세액이 있고 과세표준액이 없는경우 공급가액 move
        IF NOT L_WMWST IS INITIAL AND
               L_FWBAS IS INITIAL.

          CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = 'FWBAS'
              I_VALUE     = L_WRBTR.
        ENDIF.

      WHEN 'WMWST'.     ">세액.
        PERFORM  GET_INPUT_VALUE   USING   L_WRBTR
                                           L_WMWST
                                           L_FWBAS
                                           L_MWSKZ
                                           L_WAERS
                                           ER_DATA_CHANGED
                                           LS_MOD_CELLS.
*        IF l_wrbtr IS INITIAL AND
*           l_wmwst IS INITIAL.
**          MESSAGE e864.
*          MESSAGE i864.
*          EXIT.
*        ENDIF.
*
      WHEN 'FWBAS'.     ">과세표준액.
        PERFORM  GET_INPUT_VALUE   USING   L_WRBTR
                                           L_WMWST
                                           L_FWBAS
                                           L_MWSKZ
                                           L_WAERS
                                           ER_DATA_CHANGED
                                           LS_MOD_CELLS.

      WHEN 'LIFNR'.
        PERFORM  GET_INPUT_VALUE   USING   L_WRBTR
                                           L_WMWST
                                           L_FWBAS
                                           L_MWSKZ
                                           L_WAERS
                                           ER_DATA_CHANGED
                                           LS_MOD_CELLS.


        CALL METHOD ER_DATA_CHANGED->GET_CELL_VALUE
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = 'LIFNR'
          IMPORTING
            E_VALUE     = L_LIFNR.

*        CALL FUNCTION 'FI_VENDOR_CHECK'
*             EXPORTING
*                  I_BUKRS = I_BUKRS
*                  I_LIFNR = I_LIFNR
*             EXCEPTIONS
*                  OTHERS  = 1.
*        IF SY-SUBRC = 1.
*          MESSAGE i104 WITH I_LIFNR I_BUKRS RAISING VENDOR_MISSING.
*        ENDIF.
*
        SELECT SINGLE NAME1
          INTO L_NAME1
          FROM LFA1
         WHERE LIFNR EQ L_LIFNR.
*        if sy-subrc ne 0.
*          message e000 with l_lifnr.
*        endif.
*
        CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = 'NAME1'
            I_VALUE     = L_NAME1.
      WHEN 'MWSKZ'.
        PERFORM  GET_INPUT_VALUE   USING   L_WRBTR
                                           L_WMWST
                                           L_FWBAS
                                           L_MWSKZ
                                           L_WAERS
                                           ER_DATA_CHANGED
                                           LS_MOD_CELLS.


*> 세액계산
        CALL FUNCTION 'Z_TS_GET_AND_CALC_TAX_AMOUNT'
          EXPORTING
            IM_TAXTM = SPACE
            IM_WRBTR = L_WRBTR
            IM_WAERS = L_WAERS
            IM_BUKRS = ZTITIG00-BUKRS
            IM_MWSKZ = L_MWSKZ
          IMPORTING
            EX_WMWST = L_WMWST.

        IF GS_DISP-WMWST <> L_WMWST.
          MESSAGE I999 WITH '세액이 변경됩니다.'.
        ENDIF.

        CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = 'WMWST'
            I_VALUE     = L_WMWST.

        IF NOT L_WMWST IS INITIAL.
          L_FWBAS = L_WRBTR.
        ELSE.
          CLEAR L_FWBAS.
        ENDIF.

        CALL METHOD ER_DATA_CHANGED->MODIFY_CELL
          EXPORTING
            I_ROW_ID    = LS_MOD_CELLS-ROW_ID
            I_FIELDNAME = 'FWBAS'
            I_VALUE     = L_FWBAS.


      WHEN OTHERS.
        PERFORM  GET_INPUT_VALUE   USING   L_WRBTR
                                           L_WMWST
                                           L_FWBAS
                                           L_MWSKZ
                                           L_WAERS
                                           ER_DATA_CHANGED
                                           LS_MOD_CELLS.

    ENDCASE.

**    IF l_mwskz EQ 'V1'.
**      IF l_wmwst IS INITIAL.
**        l_wmwst = l_wrbtr / 10.
**      ENDIF.
**      IF l_fwbas IS INITIAL.
**        l_fwbas = l_wrbtr.
**      ENDIF.
**    ELSE.
**      CLEAR: l_fwbas, l_wmwst.
**    ENDIF.
**
**    CALL METHOD er_data_changed->modify_cell
**      EXPORTING
**        i_row_id    = ls_mod_cells-row_id
**        i_fieldname = 'WRBTR'
**        i_value     = l_wrbtr.
**
**    CALL METHOD er_data_changed->modify_cell
**      EXPORTING
**        i_row_id    = ls_mod_cells-row_id
**        i_fieldname = 'FWBAS'
**        i_value     = l_fwbas.
**
**    CALL METHOD er_data_changed->modify_cell
**      EXPORTING
**        i_row_id    = ls_mod_cells-row_id
**        i_fieldname = 'WMWST'
**        i_value     = l_wmwst.

*    IF l_wrbtr IS INITIAL AND
*       l_wmwst IS INITIAL.
*      CALL METHOD er_data_changed->modify_cell
*        EXPORTING
*          i_row_id    = ls_mod_cells-row_id
*          i_fieldname = 'BOX'
*          i_value     = space.
*    ELSE.
*      CALL METHOD er_data_changed->modify_cell
*        EXPORTING
*          i_row_id    = ls_mod_cells-row_id
*          i_fieldname = 'BOX'
*          i_value     = 'X'.
*
*    ENDIF.
  ENDLOOP.

*BREAK-POINT.
*
*  PERFORM p3800_field_attribute_change.
*  LOOP AT er_data_changed->mt_good_cells INTO ls_mod_cells.
*    CASE ls_mod_cells-fieldname.
*      WHEN 'ITPA1'.                    "
*
*        READ TABLE IT_DISP   INTO  GS_DISP
*                             INDEX ls_mod_cells-row_id .
*        IF GS_DISP-itpac  EQ  ls_mod_cells-value .
*
*          CALL METHOD er_data_changed->modify_cell
*            EXPORTING
*              i_row_id    = ls_mod_cells-row_id
*              i_fieldname = 'ICON'
*              i_value     = icon_green_light.
*        ELSE.
*          CALL METHOD er_data_changed->modify_cell
*            EXPORTING
*              i_row_id    = ls_mod_cells-row_id
*              i_fieldname = 'ICON'
*              i_value     = icon_red_light.
*        ENDIF.
*    ENDCASE.
*  ENDLOOP.

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
*
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

  READ TABLE IT_DISP INTO GS_DISP INDEX P_ROW.
  IF SY-SUBRC EQ 0.

    CASE P_COLUMN.
      WHEN 'ICSNO' OR 'ICSSQ'.
        PERFORM DISPLAY_CS_DOCUMENT(ZTIR0000)
                                           USING GS_DISP-ICSNO
                                                 GS_DISP-BUKRS.
      WHEN 'BELNR'.
        PERFORM DISPLAY_LIV_DOCUMENT(ZTIR9000)
                                           USING GS_DISP-BELNR
                                                   GS_DISP-GJAHR
                                                   GS_DISP-BUKRS.
      WHEN 'BLNUM' OR 'IBLNO'.
        PERFORM DISPLAY_BL_DOCUMENT(ZTIR0000)
                                           USING GS_DISP-IBLNO
                                                 SPACE.
      WHEN 'EBELN'.
        PERFORM DISPLAY_PURCHASE_ORDER(ZTIR0000)
                                           USING GS_DISP-EBELN
                                                 '00000'.
      WHEN OTHERS.
        IF ZTITBLK-IBLNO EQ GS_DISP-IBLNO.
          MESSAGE S933.
        ELSE.
          CLEAR: LFA1, ZTITBLK.
          SELECT SINGLE *
            FROM ZTITBLK
           WHERE IBLNO EQ GS_DISP-IBLNO.
          IF SY-SUBRC EQ 0.
            IF NOT GS_DISP-TRUCK IS INITIAL.
              SELECT SINGLE *
                FROM LFA1
               WHERE LIFNR EQ GS_DISP-TRUCK.
            ENDIF.
            MESSAGE S933.
          ELSE.
            MESSAGE S200 WITH GS_DISP-IBLNO.
          ENDIF.
        ENDIF.

        CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
          EXPORTING
            NEW_CODE = 'ZTEENTER'.

*        PERFORM display_bl_document(ztir0000)
*                                           USING GS_DISP-iblno
*                                                 '00000'.
    ENDCASE.
  ELSE.
    MESSAGE S903.
  ENDIF.

ENDFORM.                    "handle_double_click
*&---------------------------------------------------------------------*
*&      Form  handle_hotspot_click
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK  USING E_ROW_ID    TYPE LVC_S_ROW
                                 E_COLUMN_ID TYPE LVC_S_COL.

  READ TABLE IT_DISP INTO GS_DISP INDEX E_ROW_ID-INDEX.
  IF SY-SUBRC NE 0.
    MESSAGE S903.   EXIT.
  ENDIF.

  CASE E_COLUMN_ID-FIELDNAME.
    WHEN 'BLNUM' OR 'IBLNO'.
      PERFORM DISPLAY_BL_DOCUMENT(ZTIR0000)
                                    USING GS_DISP-IBLNO
                                               SPACE.
    WHEN 'PSPNR'.
      PERFORM  DISPLAY_PROJECT_MASTER(ZTIR0000)
                                      USING GS_DISP-PSPNR.


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
    PERFORM P3000_FIELD_CATEGORY_BUILD.
    PERFORM P3800_FIELD_ATTRIBUTE_CHANGE.
    PERFORM P9000_REFRESH_DISPLAY.
  ENDIF.


  EXIT.

*  DATA: l_valid TYPE c,
*        lt_row_no TYPE lvc_t_roid WITH HEADER LINE.
*  DATA: l_subrc   LIKE sy-subrc,
*        l_text_amout(20),
*        l_xauto   TYPE c.
*
*  DATA: BEGIN OF lt_ztitig06  OCCURS 2.
*          INCLUDE STRUCTURE ztisig06.
*  DATA: END   OF lt_ztitig06.
*
*  REFRESH: bdcdata, it_msg.
*  CLEAR: session.
*  ctu_params-dismode  = 'N'. ">처리모드
*  ctu_params-updmode  = 'S'. ">갱신모드
*  ctu_params-cattmode = ' '. ">CATT 모드...
*  ctu_params-defsize  = ' '. ">기본화면 크기
*  ctu_params-racommit = 'X'.
*  ctu_params-nobinpt  = ' ' .
*  ctu_params-nobiend  = ' '.
*
*  CLEAR g_count.
*
*  IF r_ucomm EQ 'ZTIT105' OR
*     r_ucomm EQ 'ZTIT901' OR
*     r_ucomm EQ 'ZTIT902' OR
*     r_ucomm EQ 'ZTIT901S'.
*    PERFORM  get_selected_row  TABLES lt_row_no.
*    CHECK g_count GT 0.
*  ELSEIF r_ucomm EQ 'ZTITINS'.
*    IF sy-tcode EQ c_tcode.
*      PERFORM  get_selected_row  TABLES lt_row_no.
*      IF g_count EQ 0.
*        MESSAGE e909.
*      ELSEIF g_count EQ 1.
*        LOOP AT IT_DISP INTO GS_DISP WHERE box = 'X'.
*          EXIT.
*        ENDLOOP.
*        CLEAR: lfa1, ztitblk.
*        SELECT SINGLE *
*          FROM ztitblk
*         WHERE iblno EQ GS_DISP-iblno.
*        IF sy-subrc EQ 0.
*          IF NOT GS_DISP-truck IS INITIAL.
*            SELECT SINGLE *
*              FROM lfa1
*             WHERE lifnr EQ GS_DISP-truck.
*          ENDIF.
*          MESSAGE s933.
*        ELSE.
*          MESSAGE e200 WITH GS_DISP-iblno.
*        ENDIF.
*      ELSE.
*        MESSAGE e929.
*      ENDIF.
*    ENDIF.
*
*    CLEAR: g_answer.
*    CALL FUNCTION 'Z_TI_EXPENCES_CODE_BY_GROUP'
*      EXPORTING
*        xbukrs    = t001-bukrs
*        xexpgr    = 'B'
*        xauto     = l_xauto
*      IMPORTING
*        p_answer  = g_answer
*      TABLES
*        xztitig06 = lt_ztitig06
*      EXCEPTIONS
*        not_found = 1
*        OTHERS    = 2.
*
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*    CHECK g_answer EQ 'Y'.
*  ENDIF.
*
*  CASE r_ucomm.
**> 비용항목 추가.
*    WHEN 'ZTITINS'.
*      LOOP AT lt_ztitig06 WHERE box = 'X'.
*        GS_DISP-expcd = lt_ztitig06-expcd.
*        GS_DISP-exptx = lt_ztitig06-exptx.
*        GS_DISP-cstcl = lt_ztitig06-cstcl.
*        GS_DISP-mwskz = lt_ztitig06-mwskz.
*        CLEAR: GS_DISP-wrbtr, GS_DISP-wmwst, GS_DISP-fwbas,
*               GS_DISP-hwaer, GS_DISP-icsno, GS_DISP-icssq,
*               GS_DISP-belnr, GS_DISP-gjahr, GS_DISP-monat,
*               GS_DISP-wrbtra,GS_DISP-wmwsta,GS_DISP-fwbasa,
*               GS_DISP-waersa,GS_DISP-kursf, GS_DISP-monct,
*               GS_DISP-bgndt, GS_DISP-expdt, GS_DISP-errmd.
*        APPEND GS_DISP TO IT_DISP.
*      ENDLOOP.
*      IF sy-subrc EQ 0.
*        PERFORM p3800_field_attribute_change.
*        PERFORM p9000_refresh_display.
*      ENDIF.
*
*    WHEN 'ZTIT901' OR 'ZTIT902'.
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
*      CLEAR: g_count, g_wrbtr, g_wmwst,g_fwbas, ztisscrcom-itcnt.
*      REFRESH: it_vendor, it_bupla, it_mwskz, lt_collect, it_cstcl.
*
**> 데이타 체크.
*      LOOP AT IT_DISP INTO GS_DISP WHERE box = 'X'.
*        CLEAR: GS_DISP-errmd.
*
**> 전기상태.
*        IF NOT GS_DISP-icsno IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          IF NOT GS_DISP-belnr IS INITIAL.
*            MESSAGE s231 WITH GS_DISP-iblno '전기'.
*          ELSE.
*            MESSAGE s231 WITH GS_DISP-iblno '생성'.
*          ENDIF.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF GS_DISP-lifnr IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          MESSAGE s508 WITH GS_DISP-iblno '지불처'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF GS_DISP-bupla IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          MESSAGE s508 WITH GS_DISP-iblno '사업장'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF GS_DISP-mwskz IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          MESSAGE s508 WITH GS_DISP-iblno '세금코드'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF GS_DISP-hwaer  IS INITIAL AND
*           GS_DISP-errmd  IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          MESSAGE s224 WITH GS_DISP-iblno '통화단위'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF ( GS_DISP-wrbtr  IS INITIAL   AND
*             GS_DISP-wmwst  IS INITIAL ) AND
*           GS_DISP-errmd  IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          MESSAGE s232 WITH GS_DISP-iblno '비용금액'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF GS_DISP-mwskz  IS INITIAL AND
*           GS_DISP-errmd  IS INITIAL.
*          GS_DISP-errmd = 'X'.
*          MESSAGE s224 WITH GS_DISP-iblno '세금코드'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
**
*        ADD GS_DISP-wrbtr TO g_wrbtr.
*        ADD GS_DISP-wmwst TO g_wrbtr.
*        ADD GS_DISP-wmwst TO g_wmwst.
*        ADD GS_DISP-fwbas TO g_fwbas.
*        ADD 1 TO ztisscrcom-itcnt.
*
*        MOVE-CORRESPONDING GS_DISP TO lt_collect.
*        COLLECT lt_collect.
*
*        MOVE: GS_DISP-lifnr  TO  it_vendor-lifnr.
*        COLLECT it_vendor.
*
*        MOVE: GS_DISP-lifnr  TO  it_vendor-lifnr.
*        COLLECT it_vendor.
*
*        MOVE: GS_DISP-lifnr  TO  it_vendor-lifnr.
*        COLLECT it_vendor.
*
*        MOVE: GS_DISP-cstcl  TO  it_cstcl-cstcl.
*        COLLECT it_cstcl.
*
*        MODIFY IT_DISP FROM GS_DISP.
*      ENDLOOP.
**> 합계전표일 경우
*      IF ztisscrcom-monsc EQ 'S'.
**---->Vendor 등을 체크함.
*        DESCRIBE TABLE it_cstcl LINES g_line.
*        CASE g_line.
*          WHEN 0.
*            MESSAGE s509.
*            PERFORM set_return_message_fill USING 'E'.
*          WHEN 1.
*          WHEN OTHERS.
*            READ TABLE it_cstcl WITH KEY cstcl = '+'.
*            IF sy-subrc EQ 0.
*              MESSAGE s527.
*              PERFORM set_return_message_fill USING 'E'.
*            ENDIF.
*        ENDCASE.
*      ENDIF.
*
***> 합계전표일 경우
**      IF ztisscrcom-monsc EQ 'S'.
***---->Vendor 등을 체크함.
**        DESCRIBE TABLE it_vendor LINES g_line.
**        CASE g_line.
**          WHEN 0.
**            MESSAGE s509.
**            PERFORM set_return_message_fill USING 'E'.
**          WHEN 1.
**          WHEN OTHERS.
**            MESSAGE s510.
**            PERFORM set_return_message_fill USING 'E'.
**        ENDCASE.
***---->사업장 등을 체크함.
**        DESCRIBE TABLE it_BUPLA LINES g_line.
**        CASE g_line.
**          WHEN 0.
**            MESSAGE s520.
**            PERFORM set_return_message_fill USING 'E'.
**          WHEN 1.
**          WHEN OTHERS.
**            MESSAGE s521.
**            PERFORM set_return_message_fill USING 'E'.
**        ENDCASE.
***---->세금코드 등을 체크함.
**        DESCRIBE TABLE it_MWSKZ LINES g_line.
**        CASE g_line.
**          WHEN 0.
**            MESSAGE s509.
**            PERFORM set_return_message_fill USING 'E'.
**          WHEN 1.
**          WHEN OTHERS.
**            MESSAGE s510.
**            PERFORM set_return_message_fill USING 'E'.
**        ENDCASE.
**      ENDIF.
**> Error Message Display.
*      PERFORM display_error_message.
*      DESCRIBE TABLE it_msg LINES g_line.
*      CHECK g_line EQ 0.
*
***> 합계전표일 경우 Vendor 등을 체크함.
**      IF ztisscrcom-monsc EQ 'S'.
***> Error Message Display.
**        PERFORM display_error_message.
**        CHECK g_line EQ 0.
**      ENDIF.
**
**> 전기확인용 대화화면 Call
*      CLEAR: ok_code.
**> 전기용 HEADER DATA Fill
*      PERFORM   fill_default_header_data.
**> 확인 대화상자 Call
*      CALL SCREEN '0200' STARTING AT 1 8.
*      IF ok_code EQ 'ABBR'.
*        MESSAGE s900.
*        EXIT.
*      ELSEIF ok_code EQ 'SIMU'.
*        ctu_params-dismode  = 'E'. ">처리모드
*      ENDIF.
*      CLEAR: g_success, g_error.
*
*      IF ztisscrcom-monsc EQ 'S'.
*        PERFORM execute_collective_posting.
*      ELSE.
*        PERFORM execute_individual_posting.
*      ENDIF.
*  ENDCASE.
*
**> Error Message Display.
*  PERFORM display_error_message.
*  IF g_success GT 0.
**> 검색조건에 해당하는 데이타를 Select.
*    PERFORM p2000_data_selections.
*    PERFORM p3000_field_category_build.
*    PERFORM p3800_field_attribute_change.
*    PERFORM p9000_refresh_display.
*  ENDIF.

ENDFORM.                    "handle_user_command_grid
*&---------------------------------------------------------------------*
*&      Form  P3210_exclude_table_build
*&---------------------------------------------------------------------*
FORM P3210_EXCLUDE_TABLE_BUILD USING P_TABNAME.

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
*                cl_gui_alv_grid=>mc_fc_refresh.           " Rrefresh

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

ENDFORM.                    " P3210_exclude_table_build
*&---------------------------------------------------------------------*
*&      Form  P3700_layout_build
*&---------------------------------------------------------------------*
FORM P3700_LAYOUT_BUILD .

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

ENDFORM.                    " P3700_layout_build
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

  DATA: L_VALID   TYPE C,
        LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE.
  DATA: L_SUBRC          LIKE SY-SUBRC,
        L_TEXT_AMOUT(20),
        L_XAUTO          TYPE C.

  DATA: BEGIN OF LT_ZTITIG06  OCCURS 2.
          INCLUDE STRUCTURE ZTISIG06.
  DATA: END   OF LT_ZTITIG06.

  DATA : LV_ERR_CHK.


  CALL METHOD G_GRID->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = G_VALID.

  CLEAR G_COUNT.
  IF SY-UCOMM EQ 'ZTIT105' OR
     SY-UCOMM EQ 'ZTIT901' OR
     SY-UCOMM EQ 'ZTIT902' OR
     SY-UCOMM EQ 'ZTIT901S'.
    PERFORM  GET_SELECTED_ROW  TABLES LT_ROW_NO.
    CHECK G_COUNT GT 0.

  ELSEIF SY-UCOMM EQ 'ZTITINS'.
    IF SY-TCODE EQ C_TCODE.
      PERFORM  GET_SELECTED_ROW  TABLES LT_ROW_NO.
      IF G_COUNT EQ 0.
        MESSAGE E909.
      ELSEIF G_COUNT EQ 1.
        LOOP AT IT_DISP INTO GS_DISP WHERE BOX = 'X'.
          EXIT.
        ENDLOOP.
        CLEAR: LFA1, ZTITBLK.
        SELECT SINGLE *
          FROM ZTITBLK
         WHERE IBLNO EQ GS_DISP-IBLNO.
        IF SY-SUBRC EQ 0.
          IF NOT GS_DISP-TRUCK IS INITIAL.
            SELECT SINGLE *
              FROM LFA1
             WHERE LIFNR EQ GS_DISP-TRUCK.
          ENDIF.
          MESSAGE S933.
        ELSE.
          MESSAGE E200 WITH GS_DISP-IBLNO.
        ENDIF.
      ELSE.
        MESSAGE E929.
      ENDIF.
    ENDIF.
    CLEAR: G_ANSWER.
    CALL FUNCTION 'Z_TI_EXPENCES_CODE_BY_GROUP'
      EXPORTING
        XBUKRS    = T001-BUKRS
        XEXPGR    = 'B'
        XAUTO     = L_XAUTO
      IMPORTING
        P_ANSWER  = G_ANSWER
      TABLES
        XZTITIG06 = LT_ZTITIG06
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    CHECK G_ANSWER EQ 'Y'.
  ENDIF.


  CASE SY-UCOMM.
    WHEN 'EXIT' OR 'CANC' OR 'BACK'.
      IF G_GRID IS INITIAL.
        CALL METHOD G_GRID->FREE.
      ENDIF.
      SET SCREEN 0.
      LEAVE SCREEN.

*> 비용항목 추가.
    WHEN 'ZTITINS'.
      LOOP AT LT_ZTITIG06 WHERE BOX = 'X'.
        GS_DISP-EXPCD = LT_ZTITIG06-EXPCD.
        GS_DISP-EXPTX = LT_ZTITIG06-EXPTX.
        GS_DISP-CSTCL = LT_ZTITIG06-CSTCL.
        GS_DISP-MWSKZ = LT_ZTITIG06-MWSKZ.
*            '1'                TO  gs_disp-vorgang,
*            'P'                TO  gs_disp-cstyp,


        CLEAR: GS_DISP-WRBTR, GS_DISP-WMWST, GS_DISP-FWBAS,
               GS_DISP-ICSNO, GS_DISP-ICSSQ,
               GS_DISP-BELNR, GS_DISP-GJAHR, GS_DISP-MONAT,
               GS_DISP-WRBTRA,GS_DISP-WMWSTA,GS_DISP-FWBASA,
               GS_DISP-WAERSA,GS_DISP-KURSF, GS_DISP-MONCT,
               GS_DISP-BGNDT, GS_DISP-EXPDT, GS_DISP-ERRMD.

        GS_DISP-REFNO = GS_DISP-IBLNO.
        GS_DISP-DOCNM = GS_DISP-BLNUM.

        APPEND GS_DISP TO IT_DISP.
      ENDLOOP.
      IF SY-SUBRC EQ 0.
        PERFORM P3800_FIELD_ATTRIBUTE_CHANGE.
        PERFORM P9000_REFRESH_DISPLAY.
      ENDIF.

    WHEN 'ZTIT901' OR 'ZTIT902'.
      CHECK G_COUNT GT 0.
*> Clearing
      PERFORM  SET_POSTING_DATA_INITIAL.

*> 전기유형 선택.
      PERFORM  GET_POSTING_TYPE   USING G_COUNT
                                        ZTISSCRCOM-MONSC  G_ANSWER.
      CHECK G_ANSWER EQ 'Y'.

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
      PERFORM   BUILD_FI_DOCUMENT USING 'B'
                                        ZTISSCRCOM-MONSC.

*> 검색조건에 해당하는 데이타를 Select.
*      BREAK-POINT.


      CHECK G_SUCCESS GT 0.

* [CHM2110-00555] 전자세금계산서 미대사건데이타를 선택하여
* 전표입력시에는 전기후 미대사여부를 대사완료로 변경해줘야 함
*      PERFORM SET_ZDTV3T_AP_EXT_USE_DOC.

*> 검색조건에 해당하는 데이타를 Select.
      PERFORM P2000_DATA_SELECTIONS.
      PERFORM P3000_FIELD_CATEGORY_BUILD.
      PERFORM P3800_FIELD_ATTRIBUTE_CHANGE.
      PERFORM P9000_REFRESH_DISPLAY.


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
*      CLEAR: g_count, g_wrbtr, g_wmwst,g_fwbas, ztisscrcom-itcnt.
*      REFRESH: it_vendor, it_bupla, it_mwskz, lt_collect, it_cstcl.
*
**> 데이타 체크.
*      LOOP AT it_disp INTO gs_disp WHERE box = 'X'.
*        CLEAR: gs_disp-errmd.
*
**> 전기상태.
*        IF NOT gs_disp-icsno IS INITIAL.
*          gs_disp-errmd = 'X'.
*          IF NOT gs_disp-belnr IS INITIAL.
*            MESSAGE s231 WITH gs_disp-iblno '전기'.
*          ELSE.
*            MESSAGE s231 WITH gs_disp-iblno '생성'.
*          ENDIF.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF gs_disp-lifnr IS INITIAL.
*          gs_disp-errmd = 'X'.
*          MESSAGE s508 WITH gs_disp-iblno '지불처'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF gs_disp-bupla IS INITIAL.
*          gs_disp-errmd = 'X'.
*          MESSAGE s508 WITH gs_disp-iblno '사업장'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF gs_disp-mwskz IS INITIAL.
*          gs_disp-errmd = 'X'.
*          MESSAGE s508 WITH gs_disp-iblno '세금코드'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF gs_disp-hwaer  IS INITIAL AND
*           gs_disp-errmd  IS INITIAL.
*          gs_disp-errmd = 'X'.
*          MESSAGE s224 WITH gs_disp-iblno '통화단위'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF ( gs_disp-wrbtr  IS INITIAL   AND
*             gs_disp-wmwst  IS INITIAL ) AND
*           gs_disp-errmd  IS INITIAL.
*          gs_disp-errmd = 'X'.
*          MESSAGE s232 WITH gs_disp-iblno '비용금액'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
*
*        IF gs_disp-mwskz  IS INITIAL AND
*           gs_disp-errmd  IS INITIAL.
*          gs_disp-errmd = 'X'.
*          MESSAGE s224 WITH gs_disp-iblno '세금코드'.
*          PERFORM set_return_message_fill USING 'E'.
*        ENDIF.
**
*        ADD gs_disp-wrbtr TO g_wrbtr.
*        ADD gs_disp-wmwst TO g_wrbtr.
*        ADD gs_disp-wmwst TO g_wmwst.
*        ADD gs_disp-fwbas TO g_fwbas.
*        ADD 1 TO ztisscrcom-itcnt.
*
*        MOVE-CORRESPONDING gs_disp TO lt_collect.
*        COLLECT lt_collect.
*
*        MOVE: gs_disp-lifnr  TO  it_vendor-lifnr.
*        COLLECT it_vendor.
*
*        MOVE: gs_disp-lifnr  TO  it_vendor-lifnr.
*        COLLECT it_vendor.
*
*        MOVE: gs_disp-lifnr  TO  it_vendor-lifnr.
*        COLLECT it_vendor.
*
*        MOVE: gs_disp-cstcl  TO  it_cstcl-cstcl.
*        COLLECT it_cstcl.
*
*        MODIFY it_disp FROM gs_disp.
*      ENDLOOP.
**> 합계전표일 경우
*      IF ztisscrcom-monsc EQ 'S'.
**---->Vendor 등을 체크함.
*        DESCRIBE TABLE it_cstcl LINES g_line.
*        CASE g_line.
*          WHEN 0.
*            MESSAGE s509.
*            PERFORM set_return_message_fill USING 'E'.
*          WHEN 1.
*          WHEN OTHERS.
*            READ TABLE it_cstcl WITH KEY cstcl = '+'.
*            IF sy-subrc EQ 0.
*              MESSAGE s527.
*              PERFORM set_return_message_fill USING 'E'.
*            ENDIF.
*        ENDCASE.
*      ENDIF.
*
***> 합계전표일 경우
**      IF ztisscrcom-monsc EQ 'S'.
***---->Vendor 등을 체크함.
**        DESCRIBE TABLE it_vendor LINES g_line.
**        CASE g_line.
**          WHEN 0.
**            MESSAGE s509.
**            PERFORM set_return_message_fill USING 'E'.
**          WHEN 1.
**          WHEN OTHERS.
**            MESSAGE s510.
**            PERFORM set_return_message_fill USING 'E'.
**        ENDCASE.
***---->사업장 등을 체크함.
**        DESCRIBE TABLE it_BUPLA LINES g_line.
**        CASE g_line.
**          WHEN 0.
**            MESSAGE s520.
**            PERFORM set_return_message_fill USING 'E'.
**          WHEN 1.
**          WHEN OTHERS.
**            MESSAGE s521.
**            PERFORM set_return_message_fill USING 'E'.
**        ENDCASE.
***---->세금코드 등을 체크함.
**        DESCRIBE TABLE it_MWSKZ LINES g_line.
**        CASE g_line.
**          WHEN 0.
**            MESSAGE s509.
**            PERFORM set_return_message_fill USING 'E'.
**          WHEN 1.
**          WHEN OTHERS.
**            MESSAGE s510.
**            PERFORM set_return_message_fill USING 'E'.
**        ENDCASE.
**      ENDIF.
**> Error Message Display.
*      PERFORM display_error_message.
*      DESCRIBE TABLE it_msg LINES g_line.
*      CHECK g_line EQ 0.
*
***> 합계전표일 경우 Vendor 등을 체크함.
**      IF ztisscrcom-monsc EQ 'S'.
***> Error Message Display.
**        PERFORM display_error_message.
**        CHECK g_line EQ 0.
**      ENDIF.
**
**> 전기확인용 대화화면 Call
*      CLEAR: ok_code.
**> 전기용 HEADER DATA Fill
*      PERFORM   fill_default_header_data.
**> 확인 대화상자 Call
*      CALL SCREEN '0200' STARTING AT 1 8.
*      IF ok_code EQ 'ABBR'.
*        MESSAGE s900.
*        EXIT.
*      ELSEIF ok_code EQ 'SIMU'.
*        ctu_params-dismode  = 'E'. ">처리모드
*      ENDIF.
*      CLEAR: g_success, g_error.
*
*      IF ztisscrcom-monsc EQ 'S'.
*        PERFORM execute_collective_posting.
*      ELSE.
*        PERFORM execute_individual_posting.
*      ENDIF.
**> Error Message Display.
*      PERFORM display_error_message.
*      IF g_success GT 0.
**> 검색조건에 해당하는 데이타를 Select.
*        PERFORM p2000_data_selections.
*        PERFORM p3000_field_category_build.
*        PERFORM p3800_field_attribute_change.
*        PERFORM p9000_refresh_display.
*      ENDIF.

    WHEN 'ZTIT002'.     "[CHM2110-00555] 세금계산서 매핑
      PERFORM CHOOSE_ETAX_UNMATCH.


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

        DELETE  GT_ZMMT0311 WHERE BUKRS   = S_BUKRS-LOW
                              AND IBLNO   = GS_DISP-IBLNO
                              AND EXPCD   = GS_DISP-EXPCD
                              AND INV_SEQ = GS_DISP-INV_SEQ.



        IF GS_DISP-ICSNO IS NOT INITIAL.
          DELETE FROM ZMMT0311  WHERE BUKRS   = S_BUKRS-LOW
                                 AND IBLNO   = GS_DISP-IBLNO
                                 AND EXPCD   = GS_DISP-EXPCD
                                 AND ICSNO   = GS_DISP-ICSNO
                                 AND INV_SEQ = GS_DISP-INV_SEQ.

          UPDATE ZDTV3T_AP_EXT   SET USE_DOC = ''
                              WHERE BUKRS   = S_BUKRS-LOW
                                AND INV_SEQ = GS_DISP-INV_SEQ.


        ENDIF.


        GS_DISP-BUTTON = ICON_CLOSED_FOLDER.

        CLEAR : GS_DISP-INV_SEQ, GS_DISP-DESC_TEXT1.

        MODIFY IT_DISP FROM GS_DISP .

      ENDLOOP.

      MESSAGE S999 WITH '매핑 삭제되었습니다.'.

      PERFORM P9000_REFRESH_DISPLAY.


  ENDCASE.

ENDMODULE.                 " pai_scr0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  status_0200  OUTPUT
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

ENDMODULE.                 " status_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
*    CLEAR GS_DISP-box.
*    MODIFY IT_DISP FROM GS_DISP TRANSPORTING box WHERE box = 'X'.
*
*    LOOP AT pt_row_no.
*      IF pt_row_no-row_id GT 0.
*        READ TABLE IT_DISP INTO GS_DISP INDEX pt_row_no-row_id.
*        IF sy-subrc EQ 0.
*          ADD 1 TO g_count.
*          IF GS_DISP-box NE 'X'.
*            GS_DISP-box = 'X'.
*          ENDIF.
*          MODIFY IT_DISP FROM GS_DISP INDEX pt_row_no-row_id.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*
*  IF g_count EQ 0.
*    MESSAGE s909.
*  ENDIF.

  CLEAR: G_COUNT.
  LOOP AT IT_DISP INTO GS_DISP WHERE BOX = 'X'.
    ADD 1 TO G_COUNT.
  ENDLOOP.
  IF G_COUNT EQ 0.
    MESSAGE S909.
  ENDIF.

ENDFORM.                    " GET_SELECTED_ROW
*&---------------------------------------------------------------------*
*&      Module  user_command_0200  INPUT
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

ENDMODULE.                 " user_command_0200  INPUT
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

  IF ZTITCSK-LIFNR IS INITIAL.
    PERFORM NO_INPUT_CHECK(ZTIR0000) USING 'ZTITCSK' 'LIFNR' 'E'.
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

*> 정산종류....
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
*>
  CLEAR : LFA1.
  SELECT SINGLE * INTO LFA1 FROM LFA1
                  WHERE LIFNR EQ ZTITCSK-LIFNR.
  IF SY-SUBRC NE 0.
    MESSAGE E924 WITH '구매처' ZTITCSK-LIFNR.
  ENDIF.

*> 지급조건.
  IF ZTITCSK-ZTERM IS INITIAL.
    PERFORM NO_INPUT_CHECK(ZTIR0000) USING 'ZTITCSK' 'ZTERM' 'E'.
  ENDIF.

  IF ZTITCSK-CSTYP IS INITIAL.
    PERFORM NO_INPUT_CHECK(ZTIR0000) USING 'ZTITCSK' 'CSTYP' 'E'.
  ELSE.
    IF ZTITCSK-CSTYP EQ 'A'.
*> Get 업무가불 Default value
*      SELECT SINGLE *
*        FROM ztitig07
*       WHERE bukrs EQ ztitcsk-bukrs
*         AND cstct EQ 'L'.
*      IF sy-subrc EQ 0.
*        IF ztitig07-blart NE ztitcsk-blart.
*          MESSAGE w941 WITH ztitcsk-blart ztitig07-blart.
*          ztitcsk-blart = ztitig07-blart.
*        ENDIF.
*      ENDIF.
      IF ZTITCSK-INAME IS INITIAL.
        PERFORM NO_INPUT_CHECK(ZTIR0000) USING 'ZTITCSK' 'INAME' 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

**> 사업영역.
*  IF ZTITCSK-gsber IS INITIAL.
*    PERFORM no_input_check(ZTIr0000) USING 'ZTITCSK' 'GSBER' 'E'.
*  ENDIF.
**> 사용가능한 사업영역 체크.
*  PERFORM  check_business_area(ZTIr0000)
*                                     USING ZTITCSK-gsber.
*
*> 지급조건.
  IF ZTITCSK-XBLNR IS INITIAL.
    PERFORM NO_INPUT_CHECK(ZTIR0000) USING 'ZTITCSK' 'XBLNR' 'E'.
  ENDIF.

*> 개별전표일 경우.
  IF ZTISSCRCOM-MONSC EQ 'I'.

*> 일괄전표일 경우.
  ELSE.

  ENDIF.

*> 일회성 계정.
  IF NOT LFA1-XCPDK IS INITIAL.
    CLEAR : OK-CODE.
    IF ZTITCSO IS INITIAL.
      PERFORM SET_ONE_TIME_VENDER_DATA USING   'C'
                                       CHANGING OK-CODE.
      IF OK-CODE NE 'ZTIOKAY'.
        MESSAGE S900.
      ENDIF.
    ENDIF.
    IF ZTITCSO IS INITIAL.
      MESSAGE S266(F5).
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.
  ELSE.
    CLEAR: ZTITCSO.
  ENDIF.

  IF NOT ZTITCSK-EMPFK IS INITIAL.
    SELECT SINGLE * INTO *LFA1
           FROM LFA1
           WHERE  LIFNR EQ ZTITCSK-EMPFK.
  ELSE.
    CLEAR *LFA1.
  ENDIF.

  IF ZTISSCRCOM-MONSC EQ 'I'.

  ENDIF.

ENDMODULE.                 " pai_check_fields_scr0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_SCR0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_SCR0200 INPUT.
  SET SCREEN 0. LEAVE SCREEN.
ENDMODULE.                 " exit_SCR0200  INPUT
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
*&      Form  FILL_DEFAULT_HEADER_DATA
*&---------------------------------------------------------------------*
FORM FILL_DEFAULT_HEADER_DATA .

  LOOP AT IT_DISP INTO GS_DISP WHERE BOX = 'X'.
    EXIT.
  ENDLOOP.

  SELECT SINGLE *
    FROM ZTITIG07
   WHERE BUKRS EQ T001-BUKRS
     AND CSTCT EQ 'F'.

  READ TABLE LT_COLLECT INDEX 1.


  MOVE: SY-DATLO         TO    ZTITCSK-BUDAT,
        SY-DATLO         TO    ZTITCSK-BLDAT,
        SY-DATLO         TO    ZTITCSK-ZFBDT,
        ZTITIG07-BLART   TO    ZTITCSK-BLART,
        T001-BUKRS       TO    ZTITCSK-BUKRS,
        SY-MANDT         TO    ZTITCSK-MANDT,
        LT_COLLECT-BUPLA TO    ZTITCSK-BUPLA,
        ZTITIG07-GSBER   TO    ZTITCSK-GSBER,
        ZTITIG07-CSTYP   TO    ZTITCSK-CSTYP,
        ZTITIG07-ZTERM   TO    ZTITCSK-ZTERM,
*        ztitig07-mwskz   TO    ztitcsk-mwskz,
        ZTITIG07-ZLSPR   TO    ZTITCSK-ZLSPR,
        ZTITIG07-ZLSCH   TO    ZTITCSK-ZLSCH,
        ZTITIG07-UZAWE   TO    ZTITCSK-UZAWE,
        GS_DISP-BLNUM    TO    ZTITCSK-XBLNR,
        LT_COLLECT-LIFNR TO    ZTITCSK-LIFNR,
        LT_COLLECT-MWSKZ TO    ZTITCSK-MWSKZ,
        GS_DISP-HWAER    TO    ZTITCSK-WAERS,
        G_WRBTR          TO    ZTITCSK-WRBTR,
        G_WMWST          TO    ZTITCSK-WMWST.

  IF  ZTITCSK-BUPLA IS INITIAL.
    ZTITCSK-BUPLA = GS_DISP-BUPLA.
  ENDIF.
*
*  MOVE: sy-datlo         TO    ztitcsk-budat,
*        sy-datlo         TO    ztitcsk-bldat,
*        sy-datlo         TO    ztitcsk-zfbdt,
*        'RE'             TO    ztitcsk-blart,
*        t001-bukrs       TO    ztitcsk-bukrs,
*        sy-mandt         TO    ztitcsk-mandt,
*        '130'           TO    ztitcsk-bupla,
**        '0000'           TO    ZTITCSK-zterm,
*        GS_DISP-mwskz    TO    ztitcsk-mwskz,
**        'B/L 관련비용'   TO    ZTITCSK-bktxt,
**        'B/L 관련비용'   TO    ZTITCSK-sgtxt,
**--> LG전선 테스트를 위해 일시 수정. by MSH,20041121
**        GS_DISP-blnum    TO    ztitcsk-xblnr,
*        'Test'           TO    ztitcsk-xblnr,
**--> End of Modification.
*        GS_DISP-hwaer    TO    ztitcsk-waers,
*        g_wrbtr          TO    ztitcsk-wrbtr,
*        g_wmwst          TO    ztitcsk-wmwst,
*        g_fwbas          TO    ztitcsk-fwbas.
*
  IF GS_DISP-BLNUM IS INITIAL.
    ZTITCSK-XBLNR = GS_DISP-IBLNO.
  ENDIF.

  SELECT NAME_TEXT
    INTO ZTITCSK-INAME
    FROM ADRP UP TO 1 ROWS
   WHERE PERSNUMBER EQ ( SELECT PERSNUMBER
                           FROM USR21
                          WHERE BNAME EQ SY-UNAME ).

  ENDSELECT.

  PERFORM  GET_DOMAIN_VALUE_TEXT(ZTIR9000)
                                 USING   'ZTIEXPGR'
                                         'B'
                                 CHANGING ZTITCSK-BKTXT.

*> 입력된 값 체크.
  PERFORM  CHECK_INPUT_VALUE.

*  CLEAR: ztitcsk-cstyp.

ENDFORM.                    " FILL_DEFAULT_HEADER_DATA
*&---------------------------------------------------------------------*
*&      Module  change_field_attribute_scr0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_FIELD_ATTRIBUTE_SCR0200 OUTPUT.

  LOOP AT SCREEN.
    IF ZTISSCRCOM-MONSC EQ 'I'.
*      IF screen-name EQ 'ZTITCSK-LIFNR' OR
*         screen-name EQ 'LFA1-NAME1'     OR
      IF SCREEN-NAME EQ 'ZTITCSK-AKONT' OR
*         screen-name EQ 'ZTITCSK-WRBTR' OR
*         screen-name EQ 'ZTITCSK-WAERS' OR
*         screen-name EQ 'ZTITCSK-WMWST' OR
         SCREEN-NAME EQ 'ZTITCSK-WMSKZ' OR
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
*&      Form  execute_individual_posting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM EXECUTE_INDIVIDUAL_POSTING .

  DATA: L_SUBRC   LIKE SY-SUBRC.

*--> [가온] BDC MODE 수정
**** 전 회사 적용
  CTU_PARAMS-DISMODE = 'N'.
*<-- [가온] BDC MODE 수정

  LOOP AT IT_DISP INTO GS_DISP WHERE BOX = 'X'
                                 AND ERRMD EQ SPACE.
    CLEAR G_WRBTR.
    ADD GS_DISP-WMWST TO G_WRBTR.
    ADD GS_DISP-WRBTR TO G_WRBTR.

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
*       text
*----------------------------------------------------------------------*
FORM BUILD_INDIVIDUAL_POSTING_DATA .

  DATA: L_TEXT_AMOUT(20),
        L_TEXT_AMOUTH(20),
        L_TEXT_AMOUT2(20),
        L_TEXT_AMOUT3(20).
  DATA  L_DATE(10)        TYPE C.
  DATA: L_VORGANG         LIKE ZTITCSK-VORGANG.

  REFRESH: BDCDATA.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR9000'          '0100',
         ' ' 'ZTISSCRCOM-BUKRS'  ZTITCSK-BUKRS,
         ' ' 'ZTISSCRCOM-BUDAT'  ZTITCSK-BUDAT,
         ' ' 'ZTISSCRCOM-BLDAT'  ZTITCSK-BLDAT,
         ' ' 'ZTISSCRCOM-LIFNR'  ZTITCSK-LIFNR,
*         ' ' 'ZTISSCRCOM-EMPFK'  ZTITCSK-empfk,
         ' ' 'ZTISSCRCOM-EXPGR'  'B',
*         ' ' 'ZTISSCRCOM-CSTYP'  ZTISSCRCOM-CSTYP
         ' ' 'ZTISSCRCOM-WAERS'  GS_DISP-WAERS,
         ' ' 'ZTISSCRCOM-BLART'  ZTITCSK-BLART,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

*> 세부화면.
  WRITE GS_DISP-WRBTR TO L_TEXT_AMOUT  CURRENCY GS_DISP-HWAER.
  PERFORM    SET_WRITE_NO_MASK(ZTIR9000)
                                    CHANGING  L_TEXT_AMOUT.
  WRITE G_WRBTR       TO L_TEXT_AMOUTH CURRENCY GS_DISP-HWAER.
  PERFORM    SET_WRITE_NO_MASK(ZTIR9000)
                                    CHANGING  L_TEXT_AMOUTH.
  WRITE GS_DISP-WMWST TO L_TEXT_AMOUT2 CURRENCY GS_DISP-HWAER.
  PERFORM    SET_WRITE_NO_MASK(ZTIR9000)
                                    CHANGING  L_TEXT_AMOUT2.
  WRITE GS_DISP-FWBAS TO L_TEXT_AMOUT3 CURRENCY GS_DISP-HWAER.
  PERFORM    SET_WRITE_NO_MASK(ZTIR9000)
                                    CHANGING  L_TEXT_AMOUT3.

*  IF ztitcsk-cstyp EQ 'P'.
*    CLEAR: ztitcsk-hkont.
*  ENDIF.
*
  CLEAR: L_DATE.
  IF NOT ZTITCSK-ZFBDT IS INITIAL.
    WRITE ZTITCSK-ZFBDT TO L_DATE.
  ENDIF.

*> 조출료일 경우.
  IF GS_DISP-CSTCL EQ '+'.
    L_VORGANG  =  '2'.
  ELSE.
    L_VORGANG  =  '1'.
  ENDIF.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR9000'           '2000',
         ' ' 'ZTITCSK-VORGANG' L_VORGANG,
         ' ' 'ZTITCSK-CSTYP'  ZTITCSK-CSTYP,
         ' ' 'ZTITCSK-INAME'  ZTITCSK-INAME,
         ' ' 'ZTITCSK-HKONT'  ZTITCSK-HKONT,
*         ' ' 'ZTITCSK-ZFBDT'  l_date,
*         ' ' 'ZTITCSK-BUPLA'  ztitcsk-bupla,
*         ' ' 'ZTITCSK-GSBER'  ztitcsk-gsber,
         ' ' 'ZTITCSK-ZLSPR'  ZTITCSK-ZLSPR,
*         ' ' 'ZTITCSK-UZAWE'  ztitcsk-uzawe,
*         ' ' 'ZTITCSK-ZLSCH'  ztitcsk-zlsch,
         ' ' 'ZTITCSK-ZTERM'  ZTITCSK-ZTERM,
         ' ' 'ZTITCSK-MWSKZ'  ZTITCSK-MWSKZ,
         ' ' 'ZTITCSK-XBLNR'  ZTITCSK-XBLNR,
         ' ' 'ZTITCSK-BKTXT'  ZTITCSK-BKTXT,
*         ' ' 'ZTITCSK-BUDAT'
*         ' ' 'ZTITCSK-BLART'
*         ' ' 'ZTITCSK-BLDAT'
*         ' ' 'ZTITCSK-BUPLA'      ZTITCSK-bupla,
*         ' ' 'ZTITCSK-GSBER'      ZTITCSK-gsber,
*         ' ' 'ZTITCSK-ZLSPR'      ZTITCSK-zlspr,
*         ' ' 'ZTITCSK-AKONT'
*         ' ' 'ZTITCSK-ZLSCH'      ZTITCSK-zlsch,
*         ' ' 'ZTITCSK-ZTERM'      ztitcsk-zterm,
**         ' ' 'ZTITCSK-WRBTR'      l_text_amouth,
**         ' ' 'ZTITCSK-WAERS'
*         ' ' 'ZTITCSK-MWSKZ'      ztitcsk-mwskz,
**         ' ' 'ZTITCSK-WMWST'      l_text_amout2,
**         ' ' 'ZTITCSK-FWBAS'      l_text_amout3,
**         ' ' 'ZTITCSK-WMWST'      GS_DISP-wmwst,
**         ' ' 'ZTITCSK-FWBAS'      GS_DISP-fwbas,
*         ' ' 'ZTITCSK-XBLNR'      GS_DISP-blnum,
*         ' ' 'ZTITCSK-BKTXT'      GS_DISP-exptx,
*         ' ' 'ZTITCSK-EBILL'      ZTITCSK-ebill,
*         ' ' 'ZTITCSK-SGTXT'      GS_DISP-exptx,
         ' ' 'ZTISCSIT-EXPCD(01)'  GS_DISP-EXPCD,
         ' ' 'ZTISCSIT-IBLNO(01)'  GS_DISP-IBLNO,
         ' ' 'ZTISCSIT-WRBTR(01)'  L_TEXT_AMOUT,
         ' ' 'ZTISCSIT-MWSKZ(01)'  GS_DISP-MWSKZ,
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

* one-time vendor.
  PERFORM ONE_TIME_VENDOR_BDC USING LFA1-XCPDK
                                    ZTITCSO.


ENDFORM.                    " build_individual_posting_data
*&---------------------------------------------------------------------*
*&      Form  execute_collective_posting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM EXECUTE_COLLECTIVE_POSTING .

  DATA: L_SUBRC   LIKE SY-SUBRC.

*--> [가온] BDC MODE 수정
**** 전 회사 적용
  CTU_PARAMS-DISMODE = 'N'.
*<-- [가온] BDC MODE 수정

  LOOP AT LT_COLLECT.
    REFRESH: BDCDATA.
    CLEAR: G_CNT, G_WRBTR ,G_WMWST, G_FWBAS.

*> 전기할 품목의 Counter.
    LOOP AT IT_DISP INTO GS_DISP WHERE BOX   EQ 'X'
                                   AND ERRMD EQ SPACE
                                   AND LIFNR EQ LT_COLLECT-LIFNR
                                   AND BUPLA EQ LT_COLLECT-BUPLA
                                   AND MWSKZ EQ LT_COLLECT-MWSKZ.
      ADD 1 TO G_CNT.
      ADD GS_DISP-WRBTR TO G_WRBTR.
      ADD GS_DISP-WMWST TO G_WRBTR.
      ADD GS_DISP-WMWST TO G_WMWST.
      ADD GS_DISP-FWBAS TO G_FWBAS.

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


  ENDLOOP.



ENDFORM.                    " execute_collective_posting
*&---------------------------------------------------------------------*
*&      Form  build_collective_posting_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_COLLECTIVE_POSTING_DATA .

  DATA: L_TEXT_AMOUT(20),
        L_TEXT_AMOUT2(20),
        L_TEXT_AMOUT3(20),
        L_ICSSQ           TYPE ZTIICSSQ.

  DATA  L_DATE(10)        TYPE C.
  DATA: L_VORGANG         LIKE ZTITCSK-VORGANG.

  REFRESH: BDCDATA.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR9000'          '0100',
         ' ' 'ZTISSCRCOM-BUKRS'  ZTITCSK-BUKRS,
         ' ' 'ZTISSCRCOM-BUDAT'  ZTITCSK-BUDAT,
         ' ' 'ZTISSCRCOM-BLDAT'  ZTITCSK-BLDAT,
         ' ' 'ZTISSCRCOM-LIFNR'  LT_COLLECT-LIFNR,
*         ' ' 'ZTISSCRCOM-EMPFK'  ZTITCSK-empfk,
         ' ' 'ZTISSCRCOM-EXPGR'  'B',
*         ' ' 'ZTISSCRCOM-CSTYP'  ZTISSCRCOM-CSTYP
         ' ' 'ZTISSCRCOM-WAERS'  ZTITCSK-WAERS,
         ' ' 'ZTISSCRCOM-BLART'  ZTITCSK-BLART,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

*> 세부화면.
  WRITE G_WRBTR TO L_TEXT_AMOUT CURRENCY ZTITCSK-WAERS.
  PERFORM    SET_WRITE_NO_MASK(ZTIR9000)
                                    CHANGING  L_TEXT_AMOUT.
  WRITE G_WMWST TO L_TEXT_AMOUT2 CURRENCY ZTITCSK-WAERS.
  PERFORM    SET_WRITE_NO_MASK(ZTIR9000)
                                    CHANGING  L_TEXT_AMOUT2.
  WRITE G_FWBAS TO L_TEXT_AMOUT3 CURRENCY ZTITCSK-WAERS.
  PERFORM    SET_WRITE_NO_MASK(ZTIR9000)
                                    CHANGING  L_TEXT_AMOUT3.

  CLEAR: L_DATE.
  IF NOT ZTITCSK-ZFBDT IS INITIAL.
    WRITE ZTITCSK-ZFBDT TO L_DATE.
  ENDIF.

*> 조출료일 경우.
  READ TABLE IT_CSTCL INDEX 1.
  IF IT_CSTCL-CSTCL EQ '+'.
    L_VORGANG  =  '2'.
  ELSE.
    L_VORGANG  =  '1'.
  ENDIF.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR9000'          '2000',
         ' ' 'ZTITCSK-VORGANG' L_VORGANG,
         ' ' 'ZTITCSK-CSTYP'  ZTITCSK-CSTYP,
         ' ' 'ZTITCSK-INAME'  ZTITCSK-INAME,
         ' ' 'ZTITCSK-HKONT'  ZTITCSK-HKONT,
*         ' ' 'ZTITCSK-BUPLA'  ztitcsk-bupla,
*         ' ' 'ZTITCSK-GSBER'  ztitcsk-gsber,
*         ' ' 'ZTITCSK-ZFBDT'  l_date,
         ' ' 'ZTITCSK-ZLSPR'  ZTITCSK-ZLSPR,
*         ' ' 'ZTITCSK-UZAWE'  ztitcsk-uzawe,
*         ' ' 'ZTITCSK-ZLSCH'  ztitcsk-zlsch,
         ' ' 'ZTITCSK-ZTERM'  ZTITCSK-ZTERM,
         ' ' 'ZTITCSK-MWSKZ'  LT_COLLECT-MWSKZ,
         ' ' 'ZTITCSK-XBLNR'  ZTITCSK-XBLNR,
         ' ' 'ZTITCSK-BKTXT'  ZTITCSK-BKTXT.

  IF NOT ZTITCSK-EMPFK IS INITIAL.
    PERFORM BDC_DYNPRO_BUILD USING :
         ' ' 'ZTITCSK-EMPFK'  ZTITCSK-EMPFK.
  ENDIF.

  IF NOT ZTITIG00-CHKBP IS INITIAL.
    PERFORM BDC_DYNPRO_BUILD USING :
         ' ' 'ZTITCSK-BUPLA'  LT_COLLECT-BUPLA.
  ENDIF.
  IF NOT ZTITIG00-CHKBA IS INITIAL.
    PERFORM BDC_DYNPRO_BUILD USING :
         ' ' 'ZTITCSK-GSBER'  ZTITCSK-GSBER.
  ENDIF.

**         ' ' 'ZTITCSK-BUDAT'
**         ' ' 'ZTITCSK-BLART'
**         ' ' 'ZTITCSK-BLDAT'
**         ' ' 'ZTITCSK-BUPLA'  ZTITCSK-bupla,
**         ' ' 'ZTITCSK-GSBER'  ZTITCSK-gsber,
**         ' ' 'ZTITCSK-ZLSPR'  ZTITCSK-zlspr,
**         ' ' 'ZTITCSK-AKONT'
**         ' ' 'ZTITCSK-ZLSCH'  ZTITCSK-zlsch,
*         ' ' 'ZTITCSK-ZTERM'  ztitcsk-zterm,
**         ' ' 'ZTITCSK-WRBTR'  l_text_amout,
**         ' ' 'ZTITCSK-WAERS'
*         ' ' 'ZTITCSK-MWSKZ'  ztitcsk-mwskz,
**         ' ' 'ZTITCSK-WMWST'  l_text_amout2,
**         ' ' 'ZTITCSK-FWBAS'  l_text_amout3,
*         ' ' 'ZTITCSK-XBLNR'  ztitcsk-xblnr,
*         ' ' 'ZTITCSK-BKTXT'  ztitcsk-bktxt.
**         ' ' 'ZTITCSK-EBILL'  ZTITCSK-ebill.
**         ' ' 'ZTITCSK-SGTXT'  ZTITCSK-sgtxt.
*
  CLEAR: G_COUNT.
  LOOP AT IT_DISP INTO GS_DISP WHERE BOX   EQ 'X'
                                 AND ERRMD EQ SPACE
                                 AND LIFNR EQ LT_COLLECT-LIFNR
                                 AND BUPLA EQ LT_COLLECT-BUPLA
                                 AND MWSKZ EQ LT_COLLECT-MWSKZ.
    ADD 1 TO G_COUNT.

    WRITE GS_DISP-WRBTR TO L_TEXT_AMOUT CURRENCY GS_DISP-HWAER.
    PERFORM    SET_WRITE_NO_MASK(ZTIR9000)
                                      CHANGING  L_TEXT_AMOUT.
    WRITE GS_DISP-WMWST TO L_TEXT_AMOUT2 CURRENCY GS_DISP-HWAER.
    PERFORM    SET_WRITE_NO_MASK(ZTIR9000)
                                      CHANGING  L_TEXT_AMOUT2.
    WRITE GS_DISP-FWBAS TO L_TEXT_AMOUT3 CURRENCY GS_DISP-HWAER.
    PERFORM    SET_WRITE_NO_MASK(ZTIR9000)
                                      CHANGING  L_TEXT_AMOUT3.

    IF G_COUNT EQ 1.
      PERFORM BDC_DYNPRO_BUILD USING :
             ' ' 'ZTISCSIT-EXPCD(01)'  GS_DISP-EXPCD,
             ' ' 'ZTISCSIT-IBLNO(01)'  GS_DISP-IBLNO,
             ' ' 'ZTISCSIT-WRBTR(01)'  L_TEXT_AMOUT,
             ' ' 'ZTISCSIT-MWSKZ(01)'  GS_DISP-MWSKZ,
             ' ' 'ZTISCSIT-WMWST(01)'  L_TEXT_AMOUT2,
             ' ' 'ZTISCSIT-FWBAS(01)'  L_TEXT_AMOUT3.
      L_ICSSQ = 1.
    ELSE.
      PERFORM BDC_DYNPRO_BUILD USING :
             'X' 'ZTIR9000'          '2000',
             ' ' 'ZTISCSIT-EXPCD(02)'  GS_DISP-EXPCD,
             ' ' 'ZTISCSIT-IBLNO(02)'  GS_DISP-IBLNO,
             ' ' 'ZTISCSIT-WRBTR(02)'  L_TEXT_AMOUT,
             ' ' 'ZTISCSIT-MWSKZ(02)'  GS_DISP-MWSKZ,
             ' ' 'ZTISCSIT-WMWST(02)'  L_TEXT_AMOUT2,
             ' ' 'ZTISCSIT-FWBAS(02)'  L_TEXT_AMOUT3.
      L_ICSSQ = G_COUNT.
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

******************************************
* one-time vendor.
  PERFORM ONE_TIME_VENDOR_BDC USING LFA1-XCPDK
                                    ZTITCSO.
*******************************************


ENDFORM.                    " build_collective_posting_data
*&---------------------------------------------------------------------*
*&      Form  p1101_check_input_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P1101_CHECK_INPUT_VALUE .

  DATA: L_XAUTO TYPE C.

  CLEAR: G_PROCESS.

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

  SELECT SINGLE *
    FROM ZTITIG07
   WHERE BUKRS EQ T001-BUKRS
     AND CSTCT EQ 'F'.

  SELECT SINGLE *
    FROM T005
   WHERE LAND1 EQ T001-LAND1.

  IF SY-TCODE(7) EQ C_TCODE.
    L_XAUTO = SPACE.
  ELSE.
    L_XAUTO = 'X'.
  ENDIF.

  IF G_ANSWER IS INITIAL.
    CALL FUNCTION 'Z_TI_EXPENCES_CODE_BY_GROUP' "기능개선 283274 수정
      EXPORTING
        XBUKRS    = T001-BUKRS
        XEXPGR    = 'B'
        XAUTO     = L_XAUTO
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
      MESSAGE E874 WITH 'B/L(AWB) 관련'.
    ENDIF.
*****************************************
  ENDIF.

  CHECK G_ANSWER EQ 'Y'.

ENDFORM.                    " p1101_check_input_value
*&---------------------------------------------------------------------*
*&      Form  build_posted_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_POSTED_MESSAGE  USING    P_SUBRC.

  IF P_SUBRC EQ 0.
    MOVE:  SY-MSGID   TO  IT_MSG-MSGID,
           SY-MSGTY   TO  IT_MSG-MSGTY,
           SY-MSGNO   TO  IT_MSG-MSGNO,
           SY-MSGV1   TO  IT_MSG-MSGV1,
           SY-MSGV2   TO  IT_MSG-MSGV2,
           SY-MSGV3   TO  IT_MSG-MSGV3,
           SY-MSGV4   TO  IT_MSG-MSGV4,
           GS_DISP-IBLNO TO  IT_MSG-REFNO.
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
             GS_DISP-IBLNO   TO IT_MSG-REFNO.
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
             GS_DISP-IBLNO TO  IT_MSG-REFNO.
      APPEND IT_MSG.
    ENDIF.
  ENDIF.

ENDFORM.                    " build_posted_message
*&---------------------------------------------------------------------*
*&      Form  P3500_sort_table_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P3500_SORT_TABLE_BUILD .


  " [CHM2110-00555] 세금계산서 매핑시 리플레시에 따른 화면변화 방지
*  IF P_STEP2 IS INITIAL.

  CLEAR GS_SORT_G.
  GS_SORT_G-SPOS      = '00'.
  GS_SORT_G-FIELDNAME = 'BOX'.
  GS_SORT_G-DOWN      = 'X'.
  GS_SORT_G-SUBTOT    = 'X'.
*    gs_sort_g-LEVEL     =  1.
*    gs_sort_g-GROUP     = 'X'.
  APPEND GS_SORT_G TO IT_SORT_G.

*  ENDIF .

  CLEAR GS_SORT_G.
  GS_SORT_G-SPOS      = '01'.
  GS_SORT_G-FIELDNAME = 'LIFNR'.
  GS_SORT_G-DOWN      = 'X'.
*    gs_sort_g-up        = 'X'.
  GS_SORT_G-SUBTOT    = 'X'.
*    gs_sort_g-LEVEL     =  1.
*    gs_sort_g-GROUP     = 'X'.
  APPEND GS_SORT_G TO IT_SORT_G.


  CLEAR GS_SORT_G.
  GS_SORT_G-SPOS      = '02'.
  GS_SORT_G-FIELDNAME = 'BUPLA'.
  GS_SORT_G-UP        = 'X'.
  GS_SORT_G-SUBTOT    = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
  APPEND GS_SORT_G TO IT_SORT_G.

  CLEAR GS_SORT_G.
  GS_SORT_G-SPOS      = '03'.
  GS_SORT_G-FIELDNAME = 'MWSKZ'.
  GS_SORT_G-DOWN      = 'X'.
*  gs_sort_g-up        = 'X'.
  GS_SORT_G-SUBTOT    = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
  APPEND GS_SORT_G TO IT_SORT_G.

  CLEAR GS_SORT_G.
  GS_SORT_G-SPOS      = '04'.
  GS_SORT_G-FIELDNAME = 'IBLNO'.
  GS_SORT_G-UP        = 'X'.
*  gs_sort_g-subtot    = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
  APPEND GS_SORT_G TO IT_SORT_G.

  CLEAR GS_SORT_G.
  GS_SORT_G-SPOS      = '05'.
  GS_SORT_G-FIELDNAME = 'EXPCD'.
  GS_SORT_G-UP        = 'X'.
*  gs_sort_g-subtot    = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
  APPEND GS_SORT_G TO IT_SORT_G.


*" [CHM2110-00555] 세금계산서 매핑시 리플레시에 따른 화면변화 방지
* IF P_STEP1 IS NOT INITIAL.
*   CLEAR GS_SORT_G-SUBTOT .
*   MODIFY IT_SORT_G FROM  GS_SORT_G
*             TRANSPORTING SUBTOT
*                   WHERE  SUBTOT = 'X'.
*
* ENDIF.

ENDFORM.                    " P3500_sort_table_build
*&---------------------------------------------------------------------*
*&      Form  P3800_field_attribute_change
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

ENDFORM.                    " P3800_field_attribute_change
*&---------------------------------------------------------------------*
*&      Form  P3810_fill_celltab
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

    IF GS_FIELDCAT_G-FIELDNAME = 'WRBTR' OR
*       gs_fieldcat_g-fieldname = 'HWAER' OR
       GS_FIELDCAT_G-FIELDNAME = 'MWSKZ' OR
       GS_FIELDCAT_G-FIELDNAME = 'WMWST' OR
       GS_FIELDCAT_G-FIELDNAME = 'FWBAS' OR
       GS_FIELDCAT_G-FIELDNAME = 'BOX'   OR
       GS_FIELDCAT_G-FIELDNAME = 'LIFNR' OR
       GS_FIELDCAT_G-FIELDNAME = 'WAERS'.

      IF GS_FIELDCAT_G-FIELDNAME = 'WMWST' OR
         GS_FIELDCAT_G-FIELDNAME = 'FWBAS'.
        IF T001-WAERS EQ GS_DISP-HWAER.
          IF GS_DISP-ICSNO IS INITIAL.
            LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
            INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
          ELSE.
            LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
            INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
          ENDIF.
        ELSE.
          GS_DISP-FWBAS  = GS_DISP-WMWST = 0.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
        ENDIF.
      ELSE.
        IF P_MODE EQ 'W'.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
          INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
        ENDIF.
      ENDIF.
    ELSE.
      LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
      INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " P3810_fill_celltab
*&---------------------------------------------------------------------*
*&      Form  P9000_REFRESH_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P9000_REFRESH_DISPLAY .

*  CALL METHOD g_grid->get_frontend_layout
*    IMPORTING
*      es_layout = gs_layout_g.
*
*  CALL METHOD cl_gui_cfw=>flush.
*
*  CALL METHOD g_grid->set_frontend_layout
*    EXPORTING
*      is_layout = gs_layout_g.
*
*  CALL METHOD g_grid->set_frontend_fieldcatalog
*    EXPORTING
*      it_fieldcatalog = it_fieldcat_g.

  GS_STABLE-ROW = 'X'.
  GS_STABLE-COL = 'X'.

  CALL METHOD G_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = GS_STABLE.

*  CALL METHOD cl_gui_cfw=>flush.

ENDFORM.                    " P9000_REFRESH_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  set_one_time_vender_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_ONE_TIME_VENDER_DATA USING    G_MODE
                              CHANGING OK-CODE.

  CLEAR: OK-CODE.

  CALL FUNCTION 'Z_TI_GET_ONE_TIME_VENDOR_FIELD'
    EXPORTING
      XZTITCSK = ZTITCSK
      XLFA1    = LFA1
      XMODE    = G_MODE
    CHANGING
      XZTITCSO = ZTITCSO
      XOK_CODE = OK-CODE.

ENDFORM.                    " set_one_time_vender_data
*&---------------------------------------------------------------------*
*&      Form  one_time_vendor_bdc
*&---------------------------------------------------------------------*
FORM ONE_TIME_VENDOR_BDC  USING    P_XCPDK
                                   ZTITCSO LIKE ZTITCSO.

  IF NOT P_XCPDK IS INITIAL.
    PERFORM BDC_DYNPRO_BUILD USING :
           'X' 'SAPLZ_TI_COMMON_FUNCTIONS' '8000',
           ' ' 'ZTITCSO-FORM_OF_ADDR' ZTITCSO-FORM_OF_ADDR,
           ' ' 'ZTITCSO-NAME'         ZTITCSO-NAME        ,
           ' ' 'ZTITCSO-NAME_2'       ZTITCSO-NAME_2      ,
           ' ' 'ZTITCSO-NAME_3'       ZTITCSO-NAME_3      ,
           ' ' 'ZTITCSO-NAME_4'       ZTITCSO-NAME_4      ,
           ' ' 'ZTITCSO-STREET'       ZTITCSO-STREET      ,
           ' ' 'ZTITCSO-PO_BOX'       ZTITCSO-PO_BOX      ,
           ' ' 'ZTITCSO-POBX_PCD'     ZTITCSO-POBX_PCD    ,
           ' ' 'ZTITCSO-CITY'         ZTITCSO-CITY        ,
           ' ' 'ZTITCSO-POSTL_CODE'   ZTITCSO-POSTL_CODE  ,
           ' ' 'ZTITCSO-COUNTRY'      ZTITCSO-COUNTRY     ,
           ' ' 'ZTITCSO-REGION'       ZTITCSO-REGION      ,
           ' ' 'ZTITCSO-BANK_NO'      ZTITCSO-BANK_NO     ,
           ' ' 'ZTITCSO-BANK_CTRY'    ZTITCSO-BANK_CTRY   ,
           ' ' 'ZTITCSO-BANK_ACCT'    ZTITCSO-BANK_ACCT   ,
           ' ' 'ZTITCSO-CTRL_KEY'     ZTITCSO-CTRL_KEY    ,
           ' ' 'ZTITCSO-BANK_REF'     ZTITCSO-BANK_REF    ,
           ' ' 'ZTITCSO-INSTR_KEY'    ZTITCSO-INSTR_KEY   ,
           ' ' 'ZTITCSO-DME_IND'      ZTITCSO-DME_IND     ,
           ' ' 'ZTITCSO-TAX_NO_1'     ZTITCSO-TAX_NO_1    ,
           ' ' 'ZTITCSO-TAX_CATEGORY' ZTITCSO-TAX_CATEGORY,
           ' ' 'ZTITCSO-TAX_NO_2'     ZTITCSO-TAX_NO_2    ,
           ' ' 'ZTITCSO-TAX_NO_TY'    ZTITCSO-TAX_NO_TY   ,
           ' ' 'ZTITCSO-TAX_NO_3'     ZTITCSO-TAX_NO_3    ,
           ' ' 'ZTITCSO-SOLE_PROP'    ZTITCSO-SOLE_PROP   ,
           ' ' 'ZTITCSO-TAX_NO_4'     ZTITCSO-TAX_NO_4    ,
           ' ' 'ZTITCSO-EQUAL_TAX'    ZTITCSO-EQUAL_TAX   ,
           ' ' 'ZTITCSO-BUS_TYPE'     ZTITCSO-BUS_TYPE    ,
           ' ' 'ZTITCSO-SLS_PUR_TX'   ZTITCSO-SLS_PUR_TX  ,
           ' ' 'ZTITCSO-IND_TYPE'     ZTITCSO-IND_TYPE    ,
           ' ' 'ZTITCSO-REP_NAME'     ZTITCSO-REP_NAME    ,
           ' ' 'BDC_OKCODE'          '=ZTIOKAY'.
  ENDIF.


ENDFORM.                    " one_time_vendor_bdc
*&---------------------------------------------------------------------*
*&      Form  get_input_value
*&---------------------------------------------------------------------*
*       해당 Row의 변경가능한 필드값을 Get
*----------------------------------------------------------------------*
FORM GET_INPUT_VALUE  USING    P_WRBTR
                               P_WMWST
                               P_FWBAS
                               P_MWSKZ
                               P_WAERS
                               PR_DATA_CHANGED
                               TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                               PS_MOD_CELLS TYPE LVC_S_MODI.

*> 금액.
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
      E_VALUE     = P_WAERS.

*> 세금코드.
  CALL METHOD PR_DATA_CHANGED->GET_CELL_VALUE
    EXPORTING
      I_ROW_ID    = PS_MOD_CELLS-ROW_ID
      I_FIELDNAME = 'MWSKZ'
    IMPORTING
      E_VALUE     = P_MWSKZ.
ENDFORM.                    " get_input_value
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

*  SELECT SINGLE *
*    FROM ztstiga
*   WHERE zterm EQ ztitcsk-zterm.
*  IF sy-subrc NE 0.
*    MESSAGE e002(zmts00) WITH ztitcsk-zterm.
*  ENDIF.

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
*&      Form  P3201_F4_FIELD_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P3201_F4_FIELD_BUILD .
* F4 FIELD 등록.
* 주의할점-필드명을 ABC순으로 기술하여야 함

  GS_F4-FIELDNAME  = 'MWSKZ'.
  GS_F4-REGISTER   = 'X'.
  APPEND GS_F4 TO IT_F4.

  CALL METHOD G_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = IT_F4.

ENDFORM.                    " P3201_F4_FIELD_BUILD
*&---------------------------------------------------------------------*
*&      Form  set_selected_row
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_SELECTED_ROW  USING    P_MARK.
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

ENDFORM.                    " set_selected_row  " set_selected_row
*&---------------------------------------------------------------------*
*&      Form  refresh_confirm
*&---------------------------------------------------------------------*
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

  MOVE: '입력된 데이타가 손실됩니다.'     TO POP-DIAGNOSE1,
        '진행하시겠습니까?'               TO POP-TEXTLINE1,
        '확인'                            TO POP-TITEL.

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
        MESSAGE S231 WITH GS_DISP-IBLNO '전기'.
      ELSE.
        MESSAGE S231 WITH GS_DISP-IBLNO '생성'.
      ENDIF.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.

*> 전표유형.
    IF GS_DISP-BLART IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S232 WITH GS_DISP-IBLNO '전표유형'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.

*> 공급업체.
    IF GS_DISP-LIFNR IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S232 WITH GS_DISP-IBLNO '공급업체'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.

*> 사업장.
    IF GS_DISP-BUPLA IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S232 WITH GS_DISP-IBLNO '사업장'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.

*> 트랜잭션유형.
    IF GS_DISP-MWSKZ IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S232 WITH GS_DISP-IBLNO '세금코드'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.

*> 전기유형.
    IF GS_DISP-CSTYP IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S232 WITH GS_DISP-IBLNO '전기 유형'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.

*> 트랜잭션유형.
    IF GS_DISP-VORGANG IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S232 WITH GS_DISP-IBLNO '트랜잭션유형'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.
*> 전기방법.
    IF GS_DISP-CSCTY IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S232 WITH GS_DISP-IBLNO '전기방법'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.

*> 금액.
    IF GS_DISP-WRBTR IS INITIAL AND
       GS_DISP-WMWST IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S232 WITH GS_DISP-IBLNO '비용'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.

*> 과세표준액.
    IF NOT GS_DISP-WMWST IS INITIAL AND
           GS_DISP-FWBAS IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S232 WITH GS_DISP-IBLNO '과세표준액'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.

*> 통화금액.
*    BREAK-POINT.

    IF GS_DISP-WAERS IS INITIAL.
      GS_DISP-ERRMD = 'X'.
      MESSAGE S232 WITH GS_DISP-IBLNO '통화'.
      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
    ENDIF.


**> 세금계산서 연동
*    IF GS_DISP-BUTTON EQ ICON_CLOSED_FOLDER AND
*       GS_DISP-INV_SEQ IS INITIAL.
*      GS_DISP-ERRMD = 'X'.
*      MESSAGE S232 WITH GS_DISP-IBLNO '세금계산서'.
*      PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
*    ENDIF.



    IF GS_DISP-ERRMD IS INITIAL.
      ADD 1 TO ZTISSCRCOM-ITCNT.
      CLEAR: IT_COLLECT.
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
*      MOVE: gs_disp-payda   TO  it_collect-zfbdt.
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
************************************************************************
*> 일괄전기일 경우...
************************************************************************
  IF ZTISSCRCOM-MONSC EQ 'S'.
    LOOP AT IT_COLLECT.
      ADD 1 TO L_ICSNO.
*> Header data Move
      PERFORM SET_HEADER_DATA_BY_COLLECT USING L_ICSNO  'B'.

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

        PERFORM SET_ITEM_DATA   USING L_ICSNO  L_ICSSQ  'B'.
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
      PERFORM SET_HEADER_DATA_BY_INDIVIDUAL USING L_ICSNO  'B'.
*---> Item data Move
      CLEAR: L_ICSSQ.
      ADD 1 TO L_ICSSQ.
      PERFORM SET_ITEM_DATA   USING L_ICSNO  L_ICSSQ  'B'.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " fill_posting_data
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
FORM CHOOSE_ETAX_UNMATCH .

  DATA: L_LIFNR  LIKE LFA1-LIFNR,
        L_SU_ID  LIKE LFA1-STCD2,
        LV_LIFNR LIKE GS_DISP-LIFNR,
        LV_COUNT TYPE N LENGTH 3.

  DATA: LR_ISSUE_DATE LIKE TABLE OF RANGE_DATE WITH HEADER LINE.
  DATA: LT_ETAX_AP_HEAD LIKE TABLE OF ZDTV3T_AP_HEAD WITH HEADER LINE.

  DATA : LV_ERR_CHK ,
         LV_FIRST.

  LOOP AT IT_DISP INTO GS_DISP WHERE BOX EQ 'X'.

    IF LV_FIRST IS INITIAL.
      LV_FIRST  = 'X'.
      LV_LIFNR  = GS_DISP-LIFNR .
    ENDIF.

    IF LV_LIFNR <> GS_DISP-LIFNR.
      MESSAGE S999 WITH '동일 공급업체만 매핑이 가능합니다.'.
      LV_ERR_CHK = 'X'.
      EXIT.
    ENDIF.

    IF GS_DISP-ICON = ICON_GREEN_LIGHT.
      MESSAGE S999 WITH '전기처리된 내역이 있습니다. '.
      LV_ERR_CHK = 'X'.
      EXIT.
    ENDIF.

    IF GS_DISP-MWSKZ  EQ 'V0'.
      MESSAGE S999 WITH '세금코드 V0는 매핑이 제한됩니다 . '.
      LV_ERR_CHK = 'X'.
      EXIT.
    ENDIF.

  ENDLOOP.

  CHECK LV_ERR_CHK IS INITIAL.

  IF SY-SUBRC NE 0.
    MESSAGE S999 WITH '매핑처리할 라인을 선택해주세요'.
    EXIT.
  ENDIF.

  CLEAR : LV_COUNT.

  SELECT SINGLE STCD2
    INTO  L_SU_ID
    FROM LFA1
    WHERE LIFNR = GS_DISP-LIFNR.

*  LR_ISSUE_DATE[] = S_ERDAT[].
  IF LR_ISSUE_DATE[] IS INITIAL.
    LR_ISSUE_DATE-SIGN   = 'I'.
    LR_ISSUE_DATE-OPTION = 'BT'.


    PERFORM SET_ISSUE_DATE TABLES LR_ISSUE_DATE.

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

  READ TABLE GT_ZMMT0311 WITH KEY INV_SEQ = LT_ETAX_AP_HEAD-INV_SEQ.

  IF SY-SUBRC = 0.
    MESSAGE S000 WITH '이미 지정된 매입계산서 입니다.'
      DISPLAY LIKE 'E'.
    EXIT.
  ELSEIF LV_COUNT <> 1 .
    MESSAGE S000 WITH '한개의 매입계산서만 지정 가능합니다.'
      DISPLAY LIKE 'E'.
    EXIT.
  ELSE.

    LOOP AT IT_DISP INTO GS_DISP WHERE BOX EQ 'X'.
      CLEAR GS_DISP-BUTTON .
      GS_DISP-INV_SEQ      = LT_ETAX_AP_HEAD-INV_SEQ.
      GS_DISP-DESC_TEXT1   = LT_ETAX_AP_HEAD-DESC_TEXT1.
      MODIFY IT_DISP FROM GS_DISP TRANSPORTING BUTTON INV_SEQ DESC_TEXT1.

      MOVE-CORRESPONDING GS_DISP TO GT_ZMMT0311.
      GT_ZMMT0311-BUPLA       = LT_ETAX_AP_HEAD-BUPLA.
      GT_ZMMT0311-ISSUE_DATE  = LT_ETAX_AP_HEAD-ISSUE_DATE.
      APPEND GT_ZMMT0311.   CLEAR : GT_ZMMT0311.

*
**   전자세금과 연결여부 설정
*    UPDATE ZDTV3T_AP_EXT
*       SET USE_DOC = 'X'
*    WHERE BUKRS      EQ IT_ZTITCSK-BUKRS
*      AND ISSUE_DATE EQ GT_ZMMT0311-ISSUE_DATE
*      AND BUPLA      EQ GT_ZMMT0311-BUPLA
*      AND INV_SEQ    EQ GT_ZMMT0311-INV_SEQ.
*
*
**     전자세금상세에 연결된 전표번호 설정
*      UPDATE ZDTV3T_AP_EXT_D
*         SET  BELNR = GT_ZMMT0311-BELNR
*              ZGJAH = GT_ZMMT0311-BUDAT(4)
*              BUDAT = GT_ZMMT0311-BUDAT
*              BLDAT = GT_ZMMT0311-BLDAT
*              BLART = GT_ZMMT0311-BLART
*              MWSKZ = GT_ZMMT0311-MWSKZ
*              DMBTR = GT_ZMMT0311-DMBTR
*       WHERE BUKRS  = GT_ZMMT0311-BUKRS
*         AND ISSUE_DATE = GT_ZMMT0311-ISSUE_DATE
*         AND BUPLA      = GT_ZMMT0311-BUPLA
*        AND INV_SEQ     = GT_ZMMT0311-INV_SEQ.
*
*      GT_ZMMT0311-ICSNO = GS_DISP-ICSNO .
*      GT_ZMMT0311-ICSSQ = GS_DISP-ICSSQ.
*      GT_ZMMT0311-BUKRS = GS_DISP-BUKRS.
*      GT_ZMMT0311-BELNR = GS_DISP-BELNR.
*      GT_ZMMT0311-GJAHR = GS_DISP-BUDAT(4).
*      GT_ZMMT0311-CHARGETOTAL = GS_DISP-DMBTR.
*      GT_ZMMT0311-ERDAT = SY-DATUM.
*      GT_ZMMT0311-UZEIT = SY-UZEIT.
*      GT_ZMMT0311-UNAME = SY-UNAME.
*      MODIFY ZMMT0311 FROM GT_ZMMT0311.
*    ENDLOOP.



    ENDLOOP.

  ENDIF.

  PERFORM SET_ZDTV3T_AP_EXT_USE_DOC.


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


  CHECK GT_ZMMT0311[] IS NOT INITIAL.

  LOOP AT IT_DISP INTO GS_DISP WHERE INV_SEQ <> ' '
                                 AND BOX = 'X'.
    CLEAR : GT_ZMMT0311.
    READ TABLE IT_ZTITCSK INDEX 1.

    READ TABLE IT_ZTITCSP WITH KEY REFNO = GS_DISP-IBLNO
                                   EXPCD = GS_DISP-EXPCD.

    IF  SY-SUBRC NE 0  OR IT_ZTITCSK-ICSNO IS INITIAL.
      CONTINUE.
    ENDIF.


    READ TABLE GT_ZMMT0311  WITH KEY IBLNO = GS_DISP-IBLNO
                                     EXPCD = GS_DISP-EXPCD.

*   전자세금과 연결여부 설정
    UPDATE ZDTV3T_AP_EXT
       SET USE_DOC = 'X'
    WHERE BUKRS      EQ IT_ZTITCSK-BUKRS
      AND ISSUE_DATE EQ GT_ZMMT0311-ISSUE_DATE
      AND BUPLA      EQ GT_ZMMT0311-BUPLA
      AND INV_SEQ    EQ GT_ZMMT0311-INV_SEQ.


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
       AND ISSUE_DATE = GT_ZMMT0311-ISSUE_DATE
       AND BUPLA      = GT_ZMMT0311-BUPLA
      AND INV_SEQ     = GT_ZMMT0311-INV_SEQ.

    GT_ZMMT0311-ICSNO = IT_ZTITCSK-ICSNO .
    GT_ZMMT0311-ICSSQ = IT_ZTITCSP-ICSSQ.
    GT_ZMMT0311-BUKRS = GS_DISP-BUKRS.
    GT_ZMMT0311-BELNR = IT_ZTITCSK-BELNR.
    GT_ZMMT0311-GJAHR = IT_ZTITCSK-BUDAT(4).
    GT_ZMMT0311-CHARGETOTAL = IT_ZTITCSK-DMBTR.
    GT_ZMMT0311-ERDAT = SY-DATUM.
    GT_ZMMT0311-UZEIT = SY-UZEIT.
    GT_ZMMT0311-UNAME = SY-UNAME.
    MODIFY ZMMT0311 FROM GT_ZMMT0311.
  ENDLOOP.

  CLEAR : GT_ZMMT0311, GT_ZMMT0311[].

ENDFORM.                    " SET_ZDTV3T_AP_EXT_USE_DOC
*&---------------------------------------------------------------------*
*&      Form  SET_ISSUE_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PR_ISSUE_DATE  text
*----------------------------------------------------------------------*
FORM SET_ISSUE_DATE  TABLES   PR_ISSUE_DATE STRUCTURE RANGE_DATE.

* 현재날짜가 10일 이후라면 전달것은 조회안되도록 함
  IF SY-SYSID = 'R3P'.

    IF SY-DATUM+6(2) >= '11'.
      "당월 1일부터 조회하도록 함
      CONCATENATE SY-DATUM(6) '01' INTO PR_ISSUE_DATE-LOW.
    ELSE.

      "전월 1일부터 조회되도록 함
      "1) 당월 1일로 설정
      CONCATENATE SY-DATUM(6) '01' INTO PR_ISSUE_DATE-LOW.
      "2) 전월 말일로 설정
      PR_ISSUE_DATE-LOW = PR_ISSUE_DATE-LOW - 1.
      "3) 전월 1일로 설정
      CONCATENATE PR_ISSUE_DATE-LOW(6) '01' INTO PR_ISSUE_DATE-LOW.

    ENDIF.
  ELSE.
    PR_ISSUE_DATE-LOW    = SY-DATUM - 9999.
  ENDIF.

ENDFORM.                    " SET_ISSUE_DATE
