************************************************************************
* Title         :  ZTIR9150                                            *
*                                                                      *
* Description   : [Report] 기납증/분증(관세전가액) 관리                *
*                                                                      *
* Creation Date : 2004/02/13                                           *
*                                                                      *
* Author        : Seog Bong, Kang                                      *
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
REPORT  ZTIR9150       MESSAGE-ID ZMTI00
                       NO STANDARD PAGE HEADING.

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************
TYPE-POOLS: SLIS,   "> Globale Type(ALV)
            KKBLO.  "> Generic list types

TYPES:  BEGIN OF TY_LIST.
        INCLUDE STRUCTURE ZTISTXCS.
TYPES : CELLTAB TYPE LVC_T_STYL.            " Cell단위 수정 스타일
TYPES:  END   OF TY_LIST.

************************************************************************
* SAP Include Define                                                   *
************************************************************************
INCLUDE : <ICON>,
          <SYMBOL>,
          ZTS_REUSE_BDC_SUBROUTINE_F00.
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    type c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
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
TABLES: ZTITCSK,      ">수입제비용 헤더.
        ZTITTXK,      ">[Import] 기납증 Header.
        ZTISSCRCOM,   ">수출입시스템 Screen용 Structure(공용)
        ZTISTXCS,     ">수입의뢰 관련비용 관리 ALV용.
       *ZTISTXCS,     ">수입의뢰 관련비용 관리 ALV용.
        ICON.         ">아이콘테이블.

TABLES: T001,         ">회사코드.
        T005,         ">국가코드.
        LFA1,         ">구매처마스터 (일반섹션).
        ZTITIG00,     ">[TraSys] 회사별 프로세스 정의.
        ZTITIG07,     ">[TraSys]  제비용 일괄전기 Default Value관리.
        ZTITRQK,      ">수입의뢰(개설) 공통 헤더 테이블.
        ZTITRQS,      ">수입의뢰(개설) 공통 상태 테이블.
        ZTITCSP,      ">수입비용문서 비용항목 table.
        ZTIVCS00,     ">수입비용 Views.
        ZTITIG06,     ">수입비용코드.
        VF_KRED.      ">LFA1과 LFB1에 대한 데이타베이스 뷰.

TABLES: BAPI1093_0,   ">BAPI 환율테이블.
        BAPICURX,     ">BAPI에 대한 외화환산모듈구조.
        BAPIRET1.     ">리턴매개변수.

************************************************************************
* CONSTANTS                                                            *
************************************************************************
** JS전선 회사코드 2007/04 BY-MH.LEE -----------------
*CONSTANTS:
*    C_BUKRS     LIKE T001-BUKRS     VALUE '1000'.   ">Company code
** JS전선 회사코드 2007/04 ---------------------------
************************************************************************
* Internal Tables                                                      *
************************************************************************
*> Select용.
DATA: IT_LIST  TYPE STANDARD TABLE OF TY_LIST,
      IT_TEMP  TYPE STANDARD TABLE OF TY_LIST,
      GS_LIST  TYPE TY_LIST.

DATA: BEGIN OF IT_VENDOR  OCCURS 2,
      LIFNR    TYPE LIFNR,
      END   OF IT_VENDOR.

*> 거래상대방(은행)
DATA: BEGIN OF IT_ZTSTIG3  OCCURS 2.
        INCLUDE STRUCTURE ZTSTIG3.
DATA: END   OF IT_ZTSTIG3.

*> 비용코드.
DATA: BEGIN OF IT_ZTITIG06  OCCURS 2.
        INCLUDE STRUCTURE ZTISIG06.
DATA: END   OF IT_ZTITIG06.

DATA:    BEGIN OF EXCL OCCURS 25,
           FUNKTION(10),
         END OF EXCL.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
DATA SENDER_CHG TYPE REF TO CL_GUI_ALV_GRID.

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

DATA: IT_FIELDCAT         TYPE SLIS_T_FIELDCAT_ALV.
DATA: IT_XHEADER          TYPE SLIS_T_LISTHEADER WITH HEADER LINE.
DATA: IT_COLOR            TYPE SLIS_T_SPECIALCOL_ALV WITH HEADER LINE.
DATA: IT_SORT             TYPE SLIS_T_SORTINFO_ALV.
DATA: IT_FILTER           TYPE SLIS_T_FILTER_ALV.
DATA: IT_GRUPPEN          TYPE SLIS_T_SP_GROUP_ALV WITH HEADER LINE.
DATA: IT_EVENTS           TYPE SLIS_T_EVENT.
DATA: IT_EVENT_EXIT       TYPE SLIS_T_EVENT_EXIT WITH HEADER LINE.
DATA: IT_LISTHEADER       TYPE SLIS_T_LISTHEADER.

************************************************************************
* DATA Declarations                                                    *
************************************************************************
DATA: CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      G_GRID           TYPE REF TO CL_GUI_ALV_GRID.

DATA: G_REPID             LIKE SY-REPID.

DATA: GS_VARIANTE         LIKE DISVARIANT,
      GS_DEF_VARIANTE     LIKE DISVARIANT,
      G_VARIANT_EXIT(1)   TYPE C,
      G_VARIANT_SAVE(1)   TYPE C,
      G_VARIANT_DEF(1)    TYPE C.

DATA: G_TABIX             LIKE SY-TABIX,
      G_INDEX             LIKE SY-INDEX,
      G_SUBRC             LIKE SY-SUBRC,
      G_ANSWER            TYPE C,
      G_PROCESS           TYPE C,
      G_COUNT             TYPE I,
      G_CNT               TYPE I,
      G_WRBTR             TYPE WRBTR,
      G_WMWST             TYPE WMWST,
      OK_CODE             LIKE SY-UCOMM,
      G_LINE              TYPE I,
      G_SUCCESS           TYPE I,
      G_ERROR             TYPE I,
      G_LINEN(3)          TYPE N,
      G_OUT_TEXT(70)      TYPE C.

CLASS LCL_EVENT_RECEIVER DEFINITION DEFERRED.

DATA: EVENT_RECEIVER TYPE REF TO LCL_EVENT_RECEIVER.

************************************************************************
* CLASSES: Definition                                                  *
************************************************************************
CLASS LCL_EVENT_RECEIVER DEFINITION.
  PUBLIC SECTION.
    METHODS:
      HANDLE_HOTSPOT_CLICK
         FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
              IMPORTING E_ROW_ID
                        E_COLUMN_ID
                        ES_ROW_NO,

      HANDLE_DATA_CHANGED
         FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
             IMPORTING ER_DATA_CHANGED,

      HANDLE_DATA_CHANGED_FINISHED
          FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
              IMPORTING E_MODIFIED SENDER,

      HANDLE_DOUBLE_CLICK
           FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
               IMPORTING E_ROW E_COLUMN,

      HANDLE_BUTTON_CLICK
           FOR EVENT BUTTON_CLICK OF CL_GUI_ALV_GRID
               IMPORTING ES_COL_ID ES_ROW_NO,

      HANDLE_USER_COMMAND
           FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
               IMPORTING E_UCOMM,

      HANDLE_BEFORE_USER_COMMAND
            FOR EVENT BEFORE_USER_COMMAND OF CL_GUI_ALV_GRID
                IMPORTING E_UCOMM,

      HANDLE_AFTER_USER_COMMAND
            FOR EVENT AFTER_USER_COMMAND OF CL_GUI_ALV_GRID
                IMPORTING E_UCOMM,

      HANDLE_CONTEXT_MENU_REQUEST
           FOR EVENT CONTEXT_MENU_REQUEST OF CL_GUI_ALV_GRID
               IMPORTING E_OBJECT,

      HANDLE_TOOLBAR
           FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
               IMPORTING E_OBJECT E_INTERACTIVE,
*               IMPORTING sender e_object e_interactive,

      HANDLE_PRINT_TOP_OF_PAGE
           FOR EVENT PRINT_TOP_OF_PAGE OF CL_GUI_ALV_GRID,

      HANDLE_PRINT_TOP_OF_LIST
           FOR EVENT PRINT_TOP_OF_LIST OF CL_GUI_ALV_GRID,

      HANDLE_PRINT_END_OF_PAGE
           FOR EVENT PRINT_END_OF_PAGE OF CL_GUI_ALV_GRID,

      HANDLE_PRINT_END_OF_LIST
           FOR EVENT PRINT_END_OF_LIST OF CL_GUI_ALV_GRID,

      HANDLE_TOP_OF_PAGE
           FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID
               IMPORTING E_DYNDOC_ID,

      HANDLE_END_OF_LIST
           FOR EVENT END_OF_LIST OF CL_GUI_ALV_GRID
               IMPORTING E_DYNDOC_ID.

ENDCLASS.                    "lcl_event_receiver DEFINITION

************************************************************************
* CLASSES: IMPLEMENTATION                                              *
************************************************************************
CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.

  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM HANDLE_HOTSPOT_CLICK IN PROGRAM (G_REPID)
                                 USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "hotspot_click

  METHOD HANDLE_DATA_CHANGED.
    PERFORM HANDLE_DATA_CHANGED IN PROGRAM (G_REPID)
                                USING ER_DATA_CHANGED.
  ENDMETHOD.                    "handle_data_changed

  METHOD HANDLE_DATA_CHANGED_FINISHED.
    PERFORM  HANDLE_DATA_CHANGED_FINISHED IN PROGRAM (G_REPID)
                  USING E_MODIFIED SENDER.
  ENDMETHOD.                    "handle_data_changed_finished

  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM  HANDLE_DOUBLE_CLICK IN PROGRAM (G_REPID)
                                 USING E_ROW E_COLUMN.
  ENDMETHOD.                    "handle_double_click

  METHOD HANDLE_BUTTON_CLICK.
    PERFORM  HANDLE_BUTTON_CLICK IN PROGRAM (G_REPID)
                                 USING ES_COL_ID ES_ROW_NO.
  ENDMETHOD.                    "handle_button_click

  METHOD HANDLE_USER_COMMAND.
    PERFORM  HANDLE_USER_COMMAND_GRID IN PROGRAM (G_REPID)
                                      USING E_UCOMM.
  ENDMETHOD.                    "handle_user_command

  METHOD HANDLE_BEFORE_USER_COMMAND.
    PERFORM  HANDLE_BEFORE_USER_COMM IN PROGRAM (G_REPID)
                                     USING E_UCOMM.
  ENDMETHOD.                    "handle_before_user_command

  METHOD HANDLE_AFTER_USER_COMMAND.
    PERFORM  HANDLE_AFTER_USER_COMM IN PROGRAM (G_REPID)
                                    USING E_UCOMM.
  ENDMETHOD.                    "handle_after_user_command

  METHOD HANDLE_CONTEXT_MENU_REQUEST.
    PERFORM  HANDLE_CONTEXT_MENU IN PROGRAM (G_REPID)
                                 USING E_OBJECT.
  ENDMETHOD.                    "handle_context_menu_request

  METHOD HANDLE_TOOLBAR.
    PERFORM  HANDLE_TOOLBAR IN PROGRAM (G_REPID)
*                            USING e_object.
                            USING  E_OBJECT E_INTERACTIVE.
  ENDMETHOD.                    "handle_toolbar

  METHOD HANDLE_PRINT_TOP_OF_PAGE.
    PERFORM  HANDLE_PRINT_TOP_OF_PAGE IN PROGRAM (G_REPID).
  ENDMETHOD.                    "handle_print_top_of_page

  METHOD HANDLE_PRINT_TOP_OF_LIST.
    PERFORM  HANDLE_PRINT_TOP_OF_LIST IN PROGRAM (G_REPID).
  ENDMETHOD.                    "handle_print_top_of_list

  METHOD HANDLE_PRINT_END_OF_PAGE.
    PERFORM  HANDLE_PRINT_END_OF_PAGE IN PROGRAM (G_REPID).
  ENDMETHOD.                    "handle_print_end_of_page

  METHOD HANDLE_PRINT_END_OF_LIST.
    PERFORM  HANDLE_PRINT_END_OF_LIST IN PROGRAM (G_REPID).
  ENDMETHOD.                    "handle_print_end_of_list

  METHOD HANDLE_TOP_OF_PAGE.
    PERFORM  HANDLE_TOP_OF_PAGE IN PROGRAM (G_REPID) USING E_DYNDOC_ID.
  ENDMETHOD.                    "handle_top_of_page

  METHOD HANDLE_END_OF_LIST.
    PERFORM  HANDLE_END_OF_LIST IN PROGRAM (G_REPID) USING E_DYNDOC_ID.
  ENDMETHOD.                    "handle_end_of_list

ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK DBSEL WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS:
  S_BUKRS  FOR ZTITRQK-BUKRS                   "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID BUK,
  S_EKORG  FOR ZTITRQK-EKORG,                  "구매조직.
  S_EKGRP  FOR ZTITRQK-EKGRP,                  "구매그룹.
  S_REQNO  FOR ZTITRQK-REQNO                   "수입의뢰 관리번호.
                    MEMORY ID ZTIREQNO,
  S_TAXNO  FOR ZTITTXK-TAXNO,
  S_LIFNR  FOR ZTITRQK-LIFNR,                  "공급업체 계정번호.
  S_LIFRE  FOR ZTITRQK-LIFRE,                  "다른 송장발행처.
  S_OFFER  FOR ZTITRQK-OFFER,                  "오퍼상(Offer).
  S_OPNBK  FOR ZTITRQK-OPNBK MODIF ID SED,     "개설은행.

  S_ZTERM  FOR ZTITRQS-ZTERM,                  "지급조건키.
  S_OPNNO  FOR ZTITRQS-OPNNO MODIF ID OPN,     "수입개설번호
  S_OPNDT  FOR ZTITRQS-OPNDT MODIF ID OPN,     "개설일자.
  S_CNAM   FOR ZTITRQS-CNAM,                   "작성인.
  S_CDAT   FOR ZTITRQS-CDAT,                   "생성일.
  S_UNAM   FOR ZTITRQS-UNAM,                   "최종변경인.
  S_UDAT   FOR ZTITRQS-UDAT.                   "변경일.
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
  PERFORM P1000_ALV_FIELDS_INITIAL.
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
  PERFORM p1102_authorization_check USING s_bukrs-low.
** JS전선 회사코드 2007/04 KSH --------------------------------------

*> 레이아웃 HELP
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM P1102_F4_FOR_VARIANT.

*> 지급조건 HELP(Low values)
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ZTERM-LOW.
  PERFORM GET_F4_FOR_ZTERM(ZTIR0000) USING S_ZTERM-LOW.
*> 지급조건 HELP(High values)
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ZTERM-HIGH.
  PERFORM GET_F4_FOR_ZTERM(ZTIR0000) USING S_ZTERM-HIGH.

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
  DESCRIBE TABLE IT_LIST LINES G_LINE.
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

  GET PARAMETER ID 'BUK' FIELD S_BUKRS-LOW.
  S_BUKRS-SIGN = 'I'.
  S_BUKRS-OPTION = 'EQ'.
  IF NOT S_BUKRS-LOW IS INITIAL.
    APPEND S_BUKRS.
  ENDIF.

  CLEAR: G_ANSWER.

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
      I_STRUCTURE_NAME       = 'ZTISTXCS'
      I_CLIENT_NEVER_DISPLAY = 'X'
    CHANGING
      CT_FIELDCAT            = IT_FIELDCAT_G[].

  LOOP AT IT_FIELDCAT_G INTO GS_FIELDCAT_G.
    CLEAR: GS_FIELDCAT_G-KEY.

    CASE GS_FIELDCAT_G-FIELDNAME.
      WHEN 'ICON'.
        GS_FIELDCAT_G-KEY       = 'X'.
        GS_FIELDCAT_G-COLTEXT   = '전기가능'.
      WHEN 'TAXNO'.
        GS_FIELDCAT_G-KEY       = 'X'.
      WHEN 'LIFNR'.
        GS_FIELDCAT_G-KEY       = 'X'.
        GS_FIELDCAT_G-COLTEXT   = '거래처'.
      WHEN 'NAME1'.
      WHEN 'EXPTX'.
        GS_FIELDCAT_G-KEY       = ' '.
      WHEN 'OPNNO'.
        GS_FIELDCAT_G-HOTSPOT   = 'X'.
      WHEN 'PSPNR'.
        GS_FIELDCAT_G-HOTSPOT   = 'X'.
        GS_FIELDCAT_G-JUST      = 'L'.
      WHEN 'REQTX'.
        GS_FIELDCAT_G-COLTEXT   = '문서유형'.
      WHEN 'EBELN'.
      WHEN 'WRBTR'  OR 'HWAER'.
        GS_FIELDCAT_G-CHECKTABLE = '!'.
        GS_FIELDCAT_G-DO_SUM     = 'X'.
        GS_FIELDCAT_G-EDIT       = 'X'.
      WHEN 'ICSNO'  OR 'BELNR'.
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
  SELECT R~REQNO R~AMDSQ R~OPNNO R~OPNDT R~REQTY R~EBELN
         T~LIFNR T~TAXNO T~TRNNM AS NAME1
         T~TXAMTS AS WRBTR T~KRCUR AS HWAER
    INTO CORRESPONDING FIELDS OF TABLE IT_TEMP
    FROM ZTIVRQ04 AS R INNER JOIN ZTITTXK AS T
      ON R~REQNO  EQ  T~REQNO
   WHERE R~BUKRS  IN  S_BUKRS        "회사코드.
     AND R~EKORG  IN  S_EKORG        "구매조직.
     AND R~EKGRP  IN  S_EKGRP        "구매그룹.
     AND R~REQNO  IN  S_REQNO        "수입의뢰 관리번호.
     AND T~TAXNO  IN  S_TAXNO        "기납증번호.
     AND R~LIFNR  IN  S_LIFNR        "공급업체 계정번호.
     AND R~LIFRE  IN  S_LIFRE        "다른 송장발행처.
     AND R~OFFER  IN  S_OFFER        "오퍼상(Offer).
     AND R~OPNBK  IN  S_OPNBK        "개설은행.
     AND R~ZTERM  IN  S_ZTERM        "지급조건키.
     AND R~OPNNO  IN  S_OPNNO        "수입개설번호
     AND R~OPNDT  IN  S_OPNDT        "개설일자.
     AND R~CNAM   IN  S_CNAM         "작성인.
     AND R~CDAT   IN  S_CDAT         "생성일.
     AND R~UNAM   IN  S_UNAM         "최종변경인.
     AND R~UDAT   IN  S_UDAT         "변경일
     AND R~DOCST  EQ  'O'.

  IF SY-SUBRC NE 0.
    MESSAGE S902.   EXIT.
  ENDIF.
  REFRESH: IT_LIST.
  LOOP AT IT_TEMP INTO GS_LIST.
*> 문서 종류.
    CASE GS_LIST-REQTY.
      WHEN 'LC'.
        GS_LIST-REQTX = '수입신용장'.
      WHEN 'TT'.
        GS_LIST-REQTX = '전신환송금'.
      WHEN 'LO'.
        GS_LIST-REQTX = '내국신용장'.
      WHEN 'PU'.
        GS_LIST-REQTX = '구매확인서'.
      WHEN 'DA'.
        GS_LIST-REQTX = 'D/A'.
      WHEN 'DP'.
        GS_LIST-REQTX = 'D/P'.
    ENDCASE.

**> 대표 PO
*    SELECT ebeln
*      INTO gs_list-ebeln
*      FROM ztitrqp UP TO 1 ROWS
*     WHERE reqno  EQ  gs_list-reqno
*       AND amdsq  EQ  gs_list-amdsq.
*    ENDSELECT.

*> 선택한 비용코드를 추가함.
    LOOP AT IT_ZTITIG06 WHERE BOX = 'X'.
*> 문서종류 체크.
      IF NOT IT_ZTITIG06-REQTY IS INITIAL.
        IF IT_ZTITIG06-REQTY NE GS_LIST-REQTY.
          CONTINUE.
        ENDIF.
      ENDIF.
*> 통화단위.
      MOVE T001-WAERS  TO  GS_LIST-HWAER.

      MOVE: IT_ZTITIG06-EXPCD  TO  GS_LIST-EXPCD,
            IT_ZTITIG06-EXPTX  TO  GS_LIST-EXPTX,
*            it_ztitig06-rsbtr  TO  gs_list-wrbtr,
            IT_ZTITIG06-CSTCL  TO  GS_LIST-CSTCL.

      CLEAR: ZTIVCS00.
      SELECT *
        FROM ZTIVCS00 UP TO 1 ROWS
       WHERE BUKRS   EQ  T001-BUKRS
         AND EXPGR   EQ  IT_ZTITIG06-EXPGR
         AND EXPCD   EQ  IT_ZTITIG06-EXPCD
         AND REFNO   EQ  GS_LIST-TAXNO.
      ENDSELECT.
      IF SY-SUBRC EQ 0.
        IF P_STEP1 EQ 'X'.
          CONTINUE.
        ENDIF.
*> 비용문서 MOVE
        MOVE-CORRESPONDING ZTIVCS00 TO GS_LIST.
        MOVE: ZTIVCS00-WRBTR        TO GS_LIST-WRBTR,
              ZTIVCS00-WAERS        TO GS_LIST-HWAER.
      ELSE.
        IF P_STEP2 EQ 'X'.
          CONTINUE.
        ENDIF.
      ENDIF.

*> 기존처리된 비용여부 판단.
      CASE GS_LIST-LIVST.
        WHEN 'P'.
          GS_LIST-ICON = ICON_GREEN_LIGHT.
        WHEN 'N'.
          GS_LIST-ICON = ICON_YELLOW_LIGHT.
        WHEN OTHERS.
          GS_LIST-ICON = ICON_RED_LIGHT.
      ENDCASE.
      APPEND GS_LIST TO IT_LIST.
    ENDLOOP.
  ENDLOOP.

*> 데이타가 존재하지 않을 경우.
  DESCRIBE TABLE IT_LIST LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE S902.   EXIT.
  ENDIF.

ENDFORM.                    " p2000_data_selections
*&---------------------------------------------------------------------*
*&      Form  3010_insert_field_category
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1100   text
*      -->P_1101   text
*      -->P_1102   text
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

  IF CUSTOM_CONTAINER IS INITIAL.
*   create a custom container control for our alv control
    CREATE OBJECT CUSTOM_CONTAINER
        EXPORTING
            CONTAINER_NAME = 'CUSTOMER_CONTAINER_0100'.

*   Create an Instance of ALV Control
    CREATE OBJECT G_GRID
          EXPORTING I_PARENT      = CUSTOM_CONTAINER.

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
*                 i_default            = 'X'   " 레이아웃 사전셋팅 허용.
*  LAYOUT   Standard   BCALV_GRID_09  참조.
*  is_variant 레이아웃선택/변경/저장/관리 enable
      CHANGING
        IT_SORT             = IT_SORT_G
        IT_FILTER           = IT_FILTER_G
        IT_FIELDCATALOG     = IT_FIELDCAT_G[]
        IT_OUTTAB           = IT_LIST.

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
    PERFORM p3800_set_title_text.
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
*
* append an icon to posting 비용문서.
  CLEAR LS_TOOLBAR.
  MOVE 0                    TO LS_TOOLBAR-BUTN_TYPE.
  MOVE 'ZTIT901'            TO LS_TOOLBAR-FUNCTION.
  MOVE ICON_FINANCING       TO LS_TOOLBAR-ICON.
  MOVE ' 비용 전기'(113)   TO LS_TOOLBAR-QUICKINFO.
  MOVE ' 비용 전기'(113)    TO LS_TOOLBAR-TEXT.
  MOVE SPACE                TO LS_TOOLBAR-DISABLED.
  APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.

* append an icon to Term Charge 계산.
  READ TABLE IT_ZTITIG06 WITH KEY CSTCL = 'T'.
  IF SY-SUBRC EQ 0.
    CLEAR LS_TOOLBAR.
    MOVE 0                    TO LS_TOOLBAR-BUTN_TYPE.
    MOVE 'ZTIT901S'           TO LS_TOOLBAR-FUNCTION.
    MOVE ICON_SIMULATE        TO LS_TOOLBAR-ICON.
    MOVE 'Term Charge 시뮬레이션'(115)    TO LS_TOOLBAR-QUICKINFO.
    MOVE 'Term Charge'(114)   TO LS_TOOLBAR-TEXT.
    MOVE SPACE                TO LS_TOOLBAR-DISABLED.
    APPEND LS_TOOLBAR         TO R_OBJECT->MT_TOOLBAR.
  ENDIF.

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

  LOOP AT ER_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    CASE LS_MOD_CELLS-FIELDNAME.
      WHEN 'WRBTR' OR 'HWAER'.     ">금액.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    "handle_data_changed
*&---------------------------------------------------------------------*
*&      Form  handle_data_changed_finished
*&---------------------------------------------------------------------*
FORM  HANDLE_DATA_CHANGED_FINISHED   USING P_MODIFIED
                                           P_SENDER.

  DATA LT_ROWS     TYPE LVC_T_ROW.
  DATA L_ROW_ID    TYPE LVC_S_ROW.
  DATA L_COL_ID    TYPE LVC_S_COL.
  DATA LS_STABLE   TYPE LVC_S_STBL.
  DATA L_CONTROL   TYPE REF TO CL_GUI_CONTROL.
  DATA L_ROW_NO    TYPE LVC_S_ROID.
  DATA LT_ROID     TYPE LVC_T_ROID.
  DATA L_ROW       TYPE I.
  DATA L_COL       TYPE I.
  DATA L_END_POS   TYPE I.
  DATA L_START_POS TYPE I.

  CHECK NOT P_MODIFIED IS INITIAL.

* keep in mind selected rows
  REFRESH LT_ROWS.
  CALL METHOD G_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS.

  IF LT_ROWS[] IS INITIAL.
    CALL METHOD G_GRID->GET_FOCUS
      IMPORTING
        CONTROL           = L_CONTROL
      EXCEPTIONS
        CNTL_ERROR        = 1
        CNTL_SYSTEM_ERROR = 2
        OTHERS            = 3.
* Flush now to avoid a system_pointer_pending dump.
    CALL METHOD CL_GUI_CFW=>FLUSH.
    IF SY-SUBRC = 0 AND
       L_CONTROL = G_GRID.
      CALL METHOD G_GRID->GET_CURRENT_CELL
        IMPORTING
          ES_ROW_NO = L_ROW_NO
          ES_ROW_ID = L_ROW_ID
          ES_COL_ID = L_COL_ID
          E_ROW     = L_ROW
          E_COL     = L_COL.

* Flush now to avoid a system_pointer_pending dump.
      CALL METHOD CL_GUI_CFW=>FLUSH.
    ENDIF.
  ENDIF.

  CALL METHOD G_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE.

  IF LT_ROWS[] IS INITIAL.
    CALL METHOD G_GRID->SET_FOCUS
      EXPORTING
        CONTROL = L_CONTROL.
* Flush now to avoid a system_pointer_pending dump.
    CALL METHOD CL_GUI_CFW=>FLUSH.

    IF SY-SUBRC  = 0       AND
       L_CONTROL = G_GRID.

      L_START_POS = 1.
      L_END_POS   = 1.

      APPEND L_ROW_NO TO LT_ROID.

      CALL METHOD G_GRID->SET_SELECTED_ROWS
        EXPORTING
*          IT_INDEX_ROWS            =
          IT_ROW_NO                = LT_ROID
*          IS_KEEP_OTHER_SELECTIONS =
          .

* Flush now to avoid a system_pointer_pending dump.
      CALL METHOD CL_GUI_CFW=>FLUSH.
    ENDIF.
  ELSE.
* reset selected rows
    CALL METHOD G_GRID->SET_SELECTED_ROWS
      EXPORTING
        IT_INDEX_ROWS = LT_ROWS.
  ENDIF.
*   flush
  CALL METHOD CL_GUI_CFW=>FLUSH.

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

  READ TABLE IT_LIST INTO GS_LIST INDEX P_ROW.
  IF SY-SUBRC EQ 0.

    CASE P_COLUMN.
      WHEN 'TAXNO'.
        PERFORM DISPLAY_LIV_DOCUMENT(ZTIR9000)
                                             USING GS_LIST-BELNR
                                                   GS_LIST-GJAHR
                                                   GS_LIST-BUKRS.
      WHEN 'ICSNO' OR 'ICSSQ'.
        PERFORM DISPLAY_CS_DOCUMENT(ZTIR0000)
                                           USING GS_LIST-ICSNO
                                                 GS_LIST-BUKRS.
      WHEN 'BELNR'.
        PERFORM DISPLAY_LIV_DOCUMENT(ZTIR9000)
                                             USING GS_LIST-BELNR
                                                   GS_LIST-GJAHR
                                                   GS_LIST-BUKRS.
      WHEN OTHERS.
        PERFORM DISPLAY_IMPORT_DOCUMENT(ZTIR0000)
                                           USING GS_LIST-REQNO
                                                 GS_LIST-AMDSQ
                                                 '00000'.
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

  READ TABLE IT_LIST INTO GS_LIST INDEX E_ROW_ID-INDEX.
  IF SY-SUBRC NE 0.
    MESSAGE S903.   EXIT.
  ENDIF.

  CASE E_COLUMN_ID-FIELDNAME.
    WHEN 'REQNO' OR 'OPNNO'.
      PERFORM  DISPLAY_IMPORT_DOCUMENT(ZTIR0000)
                                      USING GS_LIST-REQNO
                                            GS_LIST-AMDSQ
                                            SPACE.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    "_hotspot_click
*&---------------------------------------------------------------------*
*&      Form  handle_user_command_grid
*&---------------------------------------------------------------------*
FORM HANDLE_USER_COMMAND_GRID USING R_UCOMM.

  DATA: L_VALID TYPE C,
        LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE.
  DATA: L_SUBRC   LIKE SY-SUBRC,
        L_TEXT_AMOUT(20).

  REFRESH: BDCDATA, IT_MSG.
  CLEAR: SESSION.
  CTU_PARAMS-DISMODE  = 'E'. ">처리모드
  CTU_PARAMS-UPDMODE  = 'S'. ">갱신모드
  CTU_PARAMS-CATTMODE = ' '. ">CATT 모드...
  CTU_PARAMS-DEFSIZE  = ' '. ">기본화면 크기
  CTU_PARAMS-RACOMMIT = 'X'.
  CTU_PARAMS-NOBINPT  = ' ' .
  CTU_PARAMS-NOBIEND  = ' '.

  CLEAR G_COUNT.

  IF R_UCOMM EQ 'ZTIT105' OR
     R_UCOMM EQ 'ZTIT901' OR
     R_UCOMM EQ 'ZTIT901S'.
    PERFORM  GET_SELECTED_ROW  TABLES LT_ROW_NO.
  ENDIF.

  CHECK G_COUNT GT 0.

  CASE R_UCOMM.
*>---------------------------------------------------------------------
*> 비용전기.
*>---------------------------------------------------------------------
    WHEN 'ZTIT901'.
*> 전표전기 종류 선택 함수(월합계산서 or 개별전표)
      IF G_COUNT EQ 1.
        ZTISSCRCOM-MONSC = 'S'.
      ELSE.
        CALL FUNCTION 'Z_TI_COST_DOCUMENT_TYPE_POPUP'
          IMPORTING
            P_ANSWER = G_ANSWER
            P_MONSC  = ZTISSCRCOM-MONSC.

        CHECK G_ANSWER EQ 'Y'.
      ENDIF.
      CLEAR: G_COUNT, G_WRBTR, G_WMWST.
      REFRESH: IT_VENDOR.

*> 데이타 체크.
      LOOP AT IT_LIST INTO GS_LIST WHERE BOX = 'X'.
        CLEAR: GS_LIST-ERRMD.

        MOVE: GS_LIST-LIFNR  TO  IT_VENDOR-LIFNR.
        COLLECT IT_VENDOR.

        IF NOT GS_LIST-ICSNO IS INITIAL.
          GS_LIST-ERRMD = 'X'.
          IF NOT GS_LIST-BELNR IS INITIAL.
            MESSAGE S745 WITH GS_LIST-REQNO GS_LIST-AMDSQ '전기'.
          ELSE.
            MESSAGE S745 WITH GS_LIST-REQNO GS_LIST-AMDSQ '생성'.
          ENDIF.
          PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
        ENDIF.

        IF GS_LIST-LIFNR IS INITIAL.
          GS_LIST-ERRMD = 'X'.
          MESSAGE S744 WITH GS_LIST-TAXNO '은행코드'.
          PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
        ENDIF.

        IF GS_LIST-HWAER  IS INITIAL AND
           GS_LIST-ERRMD  IS INITIAL.
          GS_LIST-ERRMD = 'X'.
          MESSAGE S744 WITH GS_LIST-REQNO GS_LIST-AMDSQ '통화단위'.
          PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
        ENDIF.

        IF GS_LIST-WRBTR  IS INITIAL AND
           GS_LIST-ERRMD  IS INITIAL.
          GS_LIST-ERRMD = 'X'.
          MESSAGE S744 WITH GS_LIST-REQNO GS_LIST-AMDSQ '비용금액'.
          PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
        ENDIF.
*
        ADD GS_LIST-WRBTR TO G_WRBTR.
        ADD 0             TO G_WMWST.
        MODIFY IT_LIST FROM GS_LIST.
      ENDLOOP.

*> 합계전표일 경우 Vendor 등을 체크함.
      IF ZTISSCRCOM-MONSC EQ 'S'.
        DESCRIBE TABLE IT_VENDOR LINES G_LINE.
        CASE G_LINE.
          WHEN 0.
            MESSAGE S022.
            PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
          WHEN 1.
          WHEN OTHERS.
            MESSAGE S023.
            PERFORM SET_RETURN_MESSAGE_FILL USING 'E'.
        ENDCASE.
*> Error Message Display.
        PERFORM DISPLAY_ERROR_MESSAGE.
        DESCRIBE TABLE IT_MSG LINES G_LINE.
        CHECK G_LINE EQ 0.
      ENDIF.

*> 전기확인용 대화화면 Call
      CLEAR: OK_CODE.
*> 전기용 HEADER DATA Fill
      PERFORM   FILL_DEFAULT_HEADER_DATA.
*> 확인 대화상자 Call
      CLEAR: OK_CODE.
      CALL SCREEN '0200' STARTING AT 1 8.
      IF OK_CODE EQ 'ABBR'.
        MESSAGE S900.
        EXIT.
      ELSEIF OK_CODE EQ 'SIMU'.
        CTU_PARAMS-DISMODE  = 'E'. ">처리모드
      ENDIF.
      CLEAR: G_SUCCESS, G_ERROR.

      IF ZTISSCRCOM-MONSC EQ 'S'.
        PERFORM EXECUTE_COLLECTIVE_POSTING.
      ELSE.
        PERFORM EXECUTE_INDIVIDUAL_POSTING.
      ENDIF.
  ENDCASE.

*> Error Message Display.
  PERFORM DISPLAY_ERROR_MESSAGE.
*> 검색조건에 해당하는 데이타를 Select.
  CHECK G_SUCCESS GT 0.
  PERFORM P2000_DATA_SELECTIONS.
  PERFORM P3000_FIELD_CATEGORY_BUILD.
  PERFORM P3800_FIELD_ATTRIBUTE_CHANGE.
  PERFORM P9000_REFRESH_DISPLAY.

ENDFORM.                    "handle_user_command_grid
*&---------------------------------------------------------------------*
*&      Form  set_return_message_FILL
*&---------------------------------------------------------------------*
FORM SET_RETURN_MESSAGE_FILL USING P_MSGTY.

  MOVE:  SY-MSGID  TO  IT_MSG-MSGID,
         P_MSGTY   TO  IT_MSG-MSGTY,
         SY-MSGNO  TO  IT_MSG-MSGNO,
         SY-MSGV1  TO  IT_MSG-MSGV1,
         SY-MSGV2  TO  IT_MSG-MSGV2,
         SY-MSGV3  TO  IT_MSG-MSGV3,
         SY-MSGV4  TO  IT_MSG-MSGV4.

  COLLECT IT_MSG.

ENDFORM.                    " set_return_message_FILL
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
*                cl_gui_alv_grid=>mc_fc_maintain_variant,
*                cl_gui_alv_grid=>mc_fc_maximum,
*                cl_gui_alv_grid=>mc_fc_minimum,
*                cl_gui_alv_grid=>mc_fc_pc_file,
*                cl_gui_alv_grid=>mc_fc_print,
*                cl_gui_alv_grid=>mc_fc_print_back,
*                cl_gui_alv_grid=>mc_fc_print_prev,
*                cl_gui_alv_grid=>mc_fc_refresh,
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
  GS_LAYOUT_G-CWIDTH_OPT = 'X'.
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
*  gs_layout_g-no_rowmark = 'A'. "(or 'X')

* Selection modes for SEL_MODE
* 'A' : Column and row selection
* 'B' : Simple selection, list box
* 'C' : Multiple selection, list box
* 'D' : Cell selection
  GS_LAYOUT_G-SEL_MODE = 'C'.
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

  CASE SY-UCOMM.
    WHEN 'EXIT' OR 'CANC' OR 'BACK'.
      IF G_GRID IS INITIAL.
        CALL METHOD G_GRID->FREE.
      ENDIF.

      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.

ENDMODULE.                 " pai_scr0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  status_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.

  REFRESH EXCL.

  IF ZTISSCRCOM-MONSC EQ 'I'.
    MOVE 'SIMU' TO EXCL-FUNKTION.    APPEND EXCL.
  ENDIF.

  SET PF-STATUS '0300' EXCLUDING EXCL.

ENDMODULE.                 " status_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_SELECTED_ROW  TABLES   PT_ROW_NO TYPE LVC_T_ROID.

  DATA: L_VALID TYPE C.

  CALL METHOD G_GRID->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = L_VALID.

  IF L_VALID EQ 'X'.
    CALL METHOD G_GRID->GET_SELECTED_ROWS
      IMPORTING
        ET_ROW_NO = PT_ROW_NO[].

    IF PT_ROW_NO[] IS INITIAL.
      MESSAGE S909.
      EXIT.
    ENDIF.

    CLEAR GS_LIST-BOX.
    MODIFY IT_LIST FROM GS_LIST TRANSPORTING BOX WHERE BOX = 'X'.

    LOOP AT PT_ROW_NO.
      IF PT_ROW_NO-ROW_ID GT 0.
        READ TABLE IT_LIST INTO GS_LIST INDEX PT_ROW_NO-ROW_ID.
        IF SY-SUBRC EQ 0.
          ADD 1 TO G_COUNT.
          IF GS_LIST-BOX NE 'X'.
            GS_LIST-BOX = 'X'.
          ENDIF.
          MODIFY IT_LIST FROM GS_LIST INDEX PT_ROW_NO-ROW_ID.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

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

*> 사업장.
  IF ZTITCSK-BUPLA IS INITIAL.
    PERFORM NO_INPUT_CHECK(ZTIR0000) USING 'ZTITCSK' 'BUPLA' 'E'.
  ENDIF.

*> 입력된 값 체크.
  PERFORM  CHECK_INPUT_VALUE.

*> 지급조건.
  IF ZTITCSK-ZTERM IS INITIAL.
    PERFORM NO_INPUT_CHECK(ZTIR0000) USING 'ZTITCSK' 'ZTERM' 'E'.
  ENDIF.

  IF ZTITCSK-CSTYP IS INITIAL.
    PERFORM NO_INPUT_CHECK(ZTIR0000) USING 'ZTITCSK' 'CSTYP' 'E'.
  ELSE.
    IF ZTITCSK-CSTYP EQ 'A'.
*> Get 업무가불 Default value
*      break-point.
*      SELECT SINGLE *
*        FROM ztitig07
*       WHERE bukrs EQ ztitcsk-bukrs
*         AND CSTCT EQ 'L'.
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
*> 개별전표일 경우.
  IF ZTISSCRCOM-MONSC EQ 'I'.

*> 일괄전표일 경우.
  ELSE.

  ENDIF.

ENDMODULE.                 " pai_check_fields_scr0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_SCR0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_SCR0200 INPUT.

  CASE OK_CODE.
    WHEN 'ABBR'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'BU' OR 'BUC' OR 'SIMU'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN OTHERS.
  ENDCASE.
  CLEAR: OK_CODE.

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
*&      Form  FILL_DEFAULT_HEADER_DATA
*&---------------------------------------------------------------------*
FORM FILL_DEFAULT_HEADER_DATA .

  LOOP AT IT_LIST INTO GS_LIST WHERE BOX = 'X'.
    EXIT.
  ENDLOOP.

  SELECT SINGLE *
    FROM ZTITIG07
   WHERE BUKRS EQ T001-BUKRS
     AND CSTCT EQ 'T'.

  MOVE: SY-DATLO         TO    ZTITCSK-BUDAT,
        SY-DATLO         TO    ZTITCSK-BLDAT,
*        sy-datlo         TO    ZTITCSK-zfbdt,
        ZTITIG07-BLART   TO    ZTITCSK-BLART,
        T001-BUKRS       TO    ZTITCSK-BUKRS,
        SY-MANDT         TO    ZTITCSK-MANDT,
        ZTITIG07-BUPLA   TO    ZTITCSK-BUPLA,
        ZTITIG07-GSBER   TO    ZTITCSK-GSBER,
        ZTITIG07-CSTYP   TO    ZTITCSK-CSTYP,
*        '0000'           TO    ZTITCSK-zterm,
        ZTITIG07-MWSKZ   TO    ZTITCSK-MWSKZ,
*        '수입적하보험료' TO    ZTITCSK-bktxt,
*        '수입적하보험료' TO    ZTITCSK-sgtxt,
        ZTITIG07-ZLSPR   TO    ZTITCSK-ZLSPR,
        ZTITIG07-ZLSCH   TO    ZTITCSK-ZLSCH,
        ZTITIG07-UZAWE   TO    ZTITCSK-UZAWE,
        GS_LIST-OPNNO    TO    ZTITCSK-XBLNR,
        GS_LIST-LIFNR    TO    ZTITCSK-LIFNR,
        GS_LIST-HWAER    TO    ZTITCSK-WAERS,
        G_WRBTR          TO    ZTITCSK-WRBTR,
        G_WMWST          TO    ZTITCSK-WMWST.

  IF ZTITCSK-BUPLA IS INITIAL.
    ZTITCSK-BUPLA = GS_LIST-BUPLA.
  ENDIF.

  SELECT NAME_TEXT
    INTO ZTITCSK-INAME
    FROM ADRP UP TO 1 ROWS
   WHERE PERSNUMBER EQ ( SELECT PERSNUMBER
                           FROM USR21
                          WHERE BNAME EQ SY-UNAME ).

  ENDSELECT.
*  READ TABLE it_ZTItig06 WITH KEY BOX = 'X'.
*  IF SY-SUBRC EQ 0.
*    MOVE: it_ZTItig06-BLART TO ZTITCSK-blart,
*          it_ZTItig06-MWSKZ TO ZTITCSK-mwskz.
*  ENDIF.
*
  PERFORM  GET_DOMAIN_VALUE_TEXT(ZTIR9000)
                                 USING   'ZTIEXPGR'
                                         'T'
                                 CHANGING ZTITCSK-BKTXT.

*  ZTITCSK-sgtxt = ZTITCSK-bktxt.

  SELECT SINGLE *
    FROM LFA1
   WHERE LIFNR  EQ  GS_LIST-LIFNR.

  CONCATENATE ZTITCSK-BKTXT '(' LFA1-NAME1 ')' INTO ZTITCSK-BKTXT.

*> 입력된 값 체크.
  PERFORM  CHECK_INPUT_VALUE.

ENDFORM.                    " FILL_DEFAULT_HEADER_DATA
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
         SCREEN-NAME EQ 'ZTITCSK-WRBTR' OR
         SCREEN-NAME EQ 'ZTITCSK-WAERS' OR
         SCREEN-NAME EQ 'ZTITCSK-WMWST' OR
         SCREEN-NAME EQ 'ZTITCSK-BKTXT' OR
         SCREEN-NAME EQ 'ZTITCSK-XBLNR' OR
         SCREEN-NAME EQ 'ZTITCSK-SGTXT'.
        SCREEN-INPUT     = '0'.
        SCREEN-INVISIBLE = '1'.
      ENDIF.
    ENDIF.
    IF SCREEN-NAME EQ 'ZTITCSK-ZLSPR' OR
       SCREEN-NAME EQ 'ZTITCSK-ZLSCH'.
      SCREEN-INPUT     = '0'.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_field_attribute_scr0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ERROR_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_ERROR_MESSAGE .

  DESCRIBE TABLE IT_MSG LINES G_LINE.
  IF G_LINE GT 0.
    IF G_LINE EQ 1.
      READ TABLE IT_MSG INDEX 1.
      IF SY-SUBRC EQ 0.
        IF IT_MSG-MSGTY EQ 'E'.
          MESSAGE ID     IT_MSG-MSGID TYPE 'S'
                  NUMBER IT_MSG-MSGNO
                  WITH   IT_MSG-MSGV1  IT_MSG-MSGV2
                         IT_MSG-MSGV3  IT_MSG-MSGV4.
          G_LINE = 0.
        ELSE.
          MESSAGE ID     IT_MSG-MSGID TYPE 'S'
                  NUMBER IT_MSG-MSGNO
                  WITH   IT_MSG-MSGV1  IT_MSG-MSGV2
                         IT_MSG-MSGV3  IT_MSG-MSGV4.
          G_LINE = 1.
        ENDIF.
      ENDIF.
    ELSE.
      CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
        EXPORTING
          XDOCNO_SHOW = 'X'
        TABLES
          XMSG        = IT_MSG.
    ENDIF.
  ENDIF.

ENDFORM.                    " DISPLAY_ERROR_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  execute_individual_posting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM EXECUTE_INDIVIDUAL_POSTING .

  DATA: L_SUBRC   LIKE SY-SUBRC.

  LOOP AT IT_LIST INTO GS_LIST WHERE BOX = 'X'
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
*       text
*----------------------------------------------------------------------*
FORM BUILD_INDIVIDUAL_POSTING_DATA .

  DATA: L_TEXT_AMOUT(20).

  REFRESH: BDCDATA.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR9000'          '0100',
         ' ' 'ZTISSCRCOM-BUKRS'  ZTITCSK-BUKRS,
         ' ' 'ZTISSCRCOM-BUDAT'  ZTITCSK-BUDAT,
         ' ' 'ZTISSCRCOM-BLDAT'  ZTITCSK-BLDAT,
         ' ' 'ZTISSCRCOM-LIFNR'  GS_LIST-LIFNR,
         ' ' 'ZTISSCRCOM-EXPGR'  'T',
*         ' ' 'ZTISSCRCOM-CSTYP'  ZTISSCRCOM-CSTYP
         ' ' 'ZTISSCRCOM-WAERS'  GS_LIST-HWAER,
         ' ' 'ZTISSCRCOM-BLART'  ZTITCSK-BLART,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

*> 세부화면.
  WRITE GS_LIST-WRBTR TO L_TEXT_AMOUT CURRENCY GS_LIST-HWAER.
  PERFORM    SET_WRITE_NO_MASK(ZTIR9000)
                                    CHANGING  L_TEXT_AMOUT.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR9000'           '2000',
         ' ' 'ZTITCSK-CSTYP'  ZTITCSK-CSTYP,
         ' ' 'ZTITCSK-INAME'  ZTITCSK-INAME,
         ' ' 'ZTITCSK-BUPLA'  ZTITCSK-BUPLA,
         ' ' 'ZTITCSK-GSBER'  ZTITCSK-GSBER,
         ' ' 'ZTITCSK-ZLSPR'  ZTITCSK-ZLSPR,
         ' ' 'ZTITCSK-UZAWE'  ZTITCSK-UZAWE,
         ' ' 'ZTITCSK-ZLSCH'  ZTITCSK-ZLSCH,
         ' ' 'ZTITCSK-ZTERM'  ZTITCSK-ZTERM,
         ' ' 'ZTITCSK-MWSKZ'  ZTITCSK-MWSKZ,
*         ' ' 'ZTITCSK-XBLNR'  ztitcsk-xblnr,
*         ' ' 'ZTITCSK-BKTXT'  ztitcsk-bktxt.
         ' ' 'ZTITCSK-XBLNR'      GS_LIST-OPNNO,
         ' ' 'ZTITCSK-BKTXT'      GS_LIST-EXPTX,
*         ' ' 'ZTITCSK-SGTXT'      gs_list-exptx,
         ' ' 'ZTISCSIT-EXPCD(01)'  GS_LIST-EXPCD,
         ' ' 'ZTISCSIT-TAXNO(01)'  GS_LIST-TAXNO,
*         ' ' 'ZTISCSIT-AMDSQ(01)'  gs_list-amdsq,
         ' ' 'ZTISCSIT-WRBTR(01)'  L_TEXT_AMOUT,
         ' ' 'ZTISCSIT-MWSKZ(01)'  ZTITCSK-MWSKZ,
         ' ' 'ZTISCSIT-WMWST(01)'  '0',
         ' ' 'ZTISCSIT-FWBAS(01)'  '0'.

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
*&      Form  execute_collective_posting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM EXECUTE_COLLECTIVE_POSTING .

  DATA: L_SUBRC   LIKE SY-SUBRC.

  REFRESH: BDCDATA.
  CLEAR: G_CNT, G_WRBTR.

*> 전기할 품목의 Counter.
  LOOP AT IT_LIST INTO GS_LIST WHERE BOX = 'X'
                                 AND ERRMD EQ SPACE.
    ADD 1 TO G_CNT.
    ADD GS_LIST-WRBTR TO G_WRBTR.
  ENDLOOP.

*> build BDC data
  PERFORM BUILD_COLLECTIVE_POSTING_DATA.
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
*       text
*----------------------------------------------------------------------*
FORM BUILD_COLLECTIVE_POSTING_DATA .

  DATA: L_TEXT_AMOUT(20),
        L_ICSSQ           TYPE ZTIICSSQ.

  REFRESH: BDCDATA.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR9000'          '0100',
         ' ' 'ZTISSCRCOM-BUKRS'  ZTITCSK-BUKRS,
         ' ' 'ZTISSCRCOM-BUDAT'  ZTITCSK-BUDAT,
         ' ' 'ZTISSCRCOM-BLDAT'  ZTITCSK-BLDAT,
         ' ' 'ZTISSCRCOM-LIFNR'  GS_LIST-LIFNR,
         ' ' 'ZTISSCRCOM-EXPGR'  'T',
         ' ' 'ZTISSCRCOM-WAERS'  ZTITCSK-WAERS,
         ' ' 'ZTISSCRCOM-BLART'  ZTITCSK-BLART,
         ' ' 'BDC_OKCODE'       '=ZTIENTER'.

**> 세부화면.
*  WRITE g_wrbtr TO l_text_amout CURRENCY ZTITCSK-waers.
*  PERFORM    set_write_no_mask(ZTIr9000)
*                                    CHANGING  l_text_amout.

  PERFORM BDC_DYNPRO_BUILD USING :
         'X' 'ZTIR9000'       '2000',
         ' ' 'ZTITCSK-CSTYP'  ZTITCSK-CSTYP,
         ' ' 'ZTITCSK-INAME'  ZTITCSK-INAME,
         ' ' 'ZTITCSK-BUPLA'  ZTITCSK-BUPLA,
         ' ' 'ZTITCSK-GSBER'  ZTITCSK-GSBER,
         ' ' 'ZTITCSK-ZLSPR'  ZTITCSK-ZLSPR,
         ' ' 'ZTITCSK-UZAWE'  ZTITCSK-UZAWE,
         ' ' 'ZTITCSK-ZLSCH'  ZTITCSK-ZLSCH,
         ' ' 'ZTITCSK-ZTERM'  ZTITCSK-ZTERM,
         ' ' 'ZTITCSK-MWSKZ'  ZTITCSK-MWSKZ,
         ' ' 'ZTITCSK-XBLNR'  ZTITCSK-XBLNR,
         ' ' 'ZTITCSK-BKTXT'  ZTITCSK-BKTXT.
*         ' ' 'ZTITCSK-SGTXT'  ZTITCSK-sgtxt.

  CLEAR: G_COUNT.
  LOOP AT IT_LIST INTO GS_LIST WHERE BOX = 'X'
                                 AND ERRMD EQ SPACE.
    ADD 1 TO G_COUNT.

    WRITE GS_LIST-WRBTR TO L_TEXT_AMOUT CURRENCY GS_LIST-HWAER.
    PERFORM    SET_WRITE_NO_MASK(ZTIR9000)
                                      CHANGING  L_TEXT_AMOUT.

    IF G_COUNT EQ 1.
      PERFORM BDC_DYNPRO_BUILD USING :
             ' ' 'ZTISCSIT-EXPCD(01)'  GS_LIST-EXPCD,
             ' ' 'ZTISCSIT-TAXNO(01)'  GS_LIST-TAXNO,
*             ' ' 'ZTISCSIT-REQNO(01)'  gs_list-reqno,
*             ' ' 'ZTISCSIT-AMDSQ(01)'  gs_list-amdsq,
             ' ' 'ZTISCSIT-WRBTR(01)'  L_TEXT_AMOUT,
             ' ' 'ZTISCSIT-MWSKZ(01)'  ZTITCSK-MWSKZ,
             ' ' 'ZTISCSIT-WMWST(01)'  '0',
             ' ' 'ZTISCSIT-FWBAS(01)'  '0'.
      L_ICSSQ = 1.
    ELSE.
      PERFORM BDC_DYNPRO_BUILD USING :
             'X' 'ZTIR9000'          '2000',
             ' ' 'ZTISCSIT-EXPCD(02)'  GS_LIST-EXPCD,
             ' ' 'ZTISCSIT-REQNO(02)'  GS_LIST-REQNO,
             ' ' 'ZTISCSIT-AMDSQ(02)'  GS_LIST-AMDSQ,
             ' ' 'ZTISCSIT-WRBTR(02)'  L_TEXT_AMOUT,
             ' ' 'ZTISCSIT-MWSKZ(02)'  ZTITCSK-MWSKZ,
             ' ' 'ZTISCSIT-WMWST(02)'  '0',
             ' ' 'ZTISCSIT-FWBAS(02)'  '0'.
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

* one-time vendor인 경우.




  IF OK_CODE NE 'SIMU'.
    PERFORM BDC_DYNPRO_BUILD USING :
           'X' 'SAPLSPO1'          '0300',
           ' ' 'BDC_OKCODE'       '=YES'.
  ENDIF.

ENDFORM.                    " build_collective_posting_data
*&---------------------------------------------------------------------*
*&      Form  p1101_check_input_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P1101_CHECK_INPUT_VALUE .

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
     AND CSTCT EQ 'T'.

  SELECT SINGLE *
    FROM T005
   WHERE LAND1 EQ T001-LAND1.

  IF G_ANSWER IS INITIAL.
    CALL FUNCTION 'Z_TI_EXPENCES_CODE_BY_GROUP'
      EXPORTING
        XBUKRS    = T001-BUKRS
        XEXPGR    = 'T'
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
           GS_LIST-REQNO TO  IT_MSG-REFNO.
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
             GS_LIST-REQNO   TO IT_MSG-REFNO.
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
             GS_LIST-REQNO TO  IT_MSG-REFNO.
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

  CLEAR GS_SORT_G.
  GS_SORT_G-SPOS      = '01'.
  GS_SORT_G-FIELDNAME = 'LIFNR'.
  GS_SORT_G-UP        = 'X'.
  GS_SORT_G-SUBTOT    = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
  APPEND GS_SORT_G TO IT_SORT_G.

  CLEAR GS_SORT_G.
  GS_SORT_G-SPOS      = '02'.
  GS_SORT_G-FIELDNAME = 'EXPCD'.
  GS_SORT_G-UP        = 'X'.
  GS_SORT_G-SUBTOT    = 'X'.
*  gs_sort_g-LEVEL     =  1.
*  gs_sort_g-GROUP     = 'X'.
  APPEND GS_SORT_G TO IT_SORT_G.

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

  LOOP AT IT_LIST INTO GS_LIST.
    L_INDEX = SY-TABIX.
*> 전표가 입력되었을 경우 입력 불가능
    IF GS_LIST-ICSNO IS INITIAL.
      P_MODE = 'W'.
    ELSE.
      P_MODE = 'O'.
    ENDIF.

    REFRESH LT_CELLTAB.

    PERFORM P3810_FILL_CELLTAB USING    P_MODE
                               CHANGING LT_CELLTAB.

    CLEAR GS_LIST-CELLTAB.
    INSERT LINES OF LT_CELLTAB  INTO TABLE GS_LIST-CELLTAB.
    MODIFY IT_LIST FROM GS_LIST INDEX L_INDEX.
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

    IF GS_FIELDCAT_G-FIELDNAME = 'WRBTR'.         " 금액.
*       gs_fieldcat_g-fieldname = 'HWAER'.
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

*  gs_stable-row = 'X'.
*  gs_stable-col = 'X'.
*
  CALL METHOD G_GRID->REFRESH_TABLE_DISPLAY.
*    EXPORTING
*      is_stable = gs_stable.
*
*  CALL METHOD cl_gui_cfw=>flush.

ENDFORM.                    " P9000_REFRESH_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT_VALUE
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
  IF ZTITCSK-ZTERM IS INITIAL.
    ZTITCSK-ZTERM = VF_KRED-ZTERM.
  ENDIF.

  CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
    EXPORTING
      I_BLDAT = ZTITCSK-BLDAT
      I_BUDAT = ZTITCSK-BUDAT
      I_CPUDT = SY-DATLO
*      i_zfbdt = ZTITCSK-zfbdt
      I_ZTERM = ZTITCSK-ZTERM
    IMPORTING
      E_ZBD1T = ZTITCSK-ZBD1T
      E_ZBD1P = ZTITCSK-ZBD1P
      E_ZBD2T = ZTITCSK-ZBD2T
      E_ZBD2P = ZTITCSK-ZBD2P
      E_ZBD3T = ZTITCSK-ZBD3T
*      e_zlsch = ztitcsk-zlsch
*      e_zschf = ZTITCSK-zlspr
      E_ZFBDT = ZTITCSK-ZFBDT.

ENDFORM.                    " CHECK_INPUT_VALUE
*&---------------------------------------------------------------------*
*&      Form  p3800_set_title_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form p3800_set_title_text .

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: l_butxt LIKE t001-butxt,
        l_title TYPE lvc_title.
  CLEAR: l_butxt, l_title.
  SELECT SINGLE butxt FROM t001
                      INTO l_butxt
                     WHERE bukrs EQ s_bukrs-low.

  CONCATENATE '회사코드:' s_bukrs-low l_butxt
         INTO l_title SEPARATED BY space.

  CALL METHOD g_grid->set_gridtitle
    EXPORTING
      i_gridtitle = l_title.
** JS전선 회사코드 2007/04 KSH --------------------------------------

endform.                    " p3800_set_title_text
