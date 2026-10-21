*&---------------------------------------------------------------------*
*& Include          ZGTPPI1050F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_SCREEN_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SCREEN_VALUE .
  P_WERKS = '6500'.
  P_SPGCD = 'GP'.

  IF GT_TARGET[] IS INITIAL.
    SELECT *
      FROM ZGTPPT1010
     WHERE MODULE_KIND EQ @GC_PP
       AND CODEGRP EQ @GC_0010
      INTO CORRESPONDING FIELDS OF TABLE @GT_TARGET.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIRST_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_FIRST_SCREEN .
  LOOP AT SCREEN.
    CASE SCREEN-NAME.
      WHEN 'P_WERKS' OR 'P_SPGCD' OR 'P_TARGET'.
        SCREEN-REQUIRED = 2.
        MODIFY SCREEN.
    ENDCASE.

    IF P_SEND EQ GC_X.
      IF SCREEN-GROUP1 = 'S2'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF P_DISP EQ GC_X.
      IF SCREEN-GROUP1 = 'S1'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_TARGET
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_TARGET  USING   PV_DYNPROFLD TYPE HELP_INFO-DYNPROFLD .

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LV_OFFSET(6) TYPE N.
  DATA : LO_FLIEF TYPE REF TO DATA.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

  FREE LO_FLIEF.
  CREATE DATA LO_FLIEF LIKE GS_TARGET.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).

    CASE <LS_FIELD_TAB>-FIELDNAME.
      WHEN 'FLD_01'.
        <LS_FIELD_TAB>-REPTEXT  = '시스템 ID'.
      WHEN 'FLD_02'.
        <LS_FIELD_TAB>-REPTEXT  = '시스템 내역'.
      WHEN 'FLD_03'.
        <LS_FIELD_TAB>-REPTEXT  = '플랜트'.
      WHEN 'FLD_04'.
        <LS_FIELD_TAB>-REPTEXT  = 'SPG(사업부)'.
    ENDCASE.

    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'FLD_01'
      DYNPROFIELD     = PV_DYNPROFLD           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '송신대상 시스템 조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = GT_TARGET                "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.

    REFRESH LT_DYNPFIELDS.
    PERFORM GET_STEPL USING LV_LINE.

    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
    <LS_DYNPFIELDS>-FIELDNAME = PV_DYNPROFLD.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_RETURN_TAB-FIELDVAL.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME               = SY-CPROG
        DYNUMB               = SY-DYNNR
      TABLES
        DYNPFIELDS           = LT_DYNPFIELDS
      EXCEPTIONS
        INVALID_ABAPWORKAREA = 1
        INVALID_DYNPROFIELD  = 2
        INVALID_DYNPRONAME   = 3
        INVALID_DYNPRONUMMER = 4
        INVALID_REQUEST      = 5
        NO_FIELDDESCRIPTION  = 6
        UNDEFIND_ERROR       = 7
        OTHERS               = 8.
    IF SY-SUBRC <> 0.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STEPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_LINE
*&---------------------------------------------------------------------*
FORM GET_STEPL  USING    PV_LINE LIKE SY-STEPL.
  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = PV_LINE
    EXCEPTIONS
      STEPL_NOT_FOUND = 01.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INPUT_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INPUT_CHECK .
  IF P_WERKS IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH TEXT-M01. "필수 필드 "플랜트"에 입력하십시오.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF P_SPGCD IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH TEXT-M02. "필수 필드 "SPG코드"에 입력하십시오.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF P_TARGET IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH TEXT-M03. "필수 필드 "송신 대상 시스템"에 입력하십시오.
    LEAVE LIST-PROCESSING.
  ENDIF.

  READ TABLE GT_TARGET INTO GS_TARGET WITH KEY FLD_01 = P_TARGET
                                               FLD_03 = P_WERKS.
  IF SY-SUBRC NE 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH TEXT-M04. "전송대상 플랜트가 아닙니다.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PROC .
  IF P_SEND EQ GC_X.
    PERFORM GET_SEND.
  ELSEIF P_DISP EQ GC_X.
    PERFORM GET_DISP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SEND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SEND .

  CLEAR: GT_DATA.
  SELECT A~*,
         B~NAME1
    FROM ZGTPPT1090 AS A
    LEFT OUTER JOIN T001W AS B ON B~WERKS EQ A~WERKS
   WHERE A~WERKS   EQ @P_WERKS
     AND A~SPGCD   EQ @P_SPGCD
     AND A~BOBINID IN @S_BBID
     AND A~ZGTDRNO IN @S_DRNO
     AND A~PI      IN @S_PI
     AND ( A~CRDAT IN @S_CRDAT OR A~CHDAT IN @S_CRDAT )
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>).
    <FS_S>-SEND_STAT = ICON_LED_INACTIVE.
    <FS_S>-ZSYSTEM_ID = P_TARGET.

*   시스템 내역
    <FS_S>-ZSYSTEM_ID_DESC = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
                              IV_DOMNAME  = 'ZGTDTARGET'  " 도메인이름
                              IV_DOMVALUE = CONV #( <FS_S>-ZSYSTEM_ID ) ).
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLS_OBJT_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CLS_OBJT_RTN .
  CLEAR: GT_FIELDCAT_0100[], GS_LAYOUT_0100, GT_EXCLUDE_0100[],
         GT_EXCLUDE_0100, GV_OK_CODE, GV_DBCNT,
         GT_DATA[].

  CALL METHOD GO_CONTAIN_0100->FREE.
  CLEAR : GO_CONTAIN_0100, GO_GRID_0100.
  CALL METHOD CL_GUI_CFW=>FLUSH.
  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0100 .
  CREATE OBJECT GO_CONTAIN_0100
    EXPORTING
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 10000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .
  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-ZEBRA      = GC_X.
  GS_LAYOUT_0100-COL_OPT    = GC_X.
  GS_LAYOUT_0100-CWIDTH_OPT = GC_X.
  GS_LAYOUT_0100-NO_ROWINS  = GC_X.
  GS_LAYOUT_0100-SEL_MODE   = GC_D.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPI1050TOP'
      I_INTERNAL_TABNAME     = 'GS_DATA'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_DATA
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ZIFKEY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "인터페이스키
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZSEQNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "순번
        <LS_FCAT>-JUST = GC_C.
      WHEN 'SEND_STAT'.
        CASE ABAP_TRUE.
          WHEN P_SEND.
            <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "전송상태
          WHEN P_DISP.
            <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F32. "전송결과
        ENDCASE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'ZMESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "결과메시지
        <LS_FCAT>-JUST = GC_L.
      WHEN 'ZSYSTEM_ID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "수신시스템
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZSYSTEM_ID_DESC'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "시스템내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "플랜트
        <LS_FCAT>-JUST = GC_C.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "플랜트 내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'SPGCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "SPG코드
        <LS_FCAT>-JUST = GC_C.
      WHEN 'BOBINID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F33. "보빈ID
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZGTDRNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "드럼No
        <LS_FCAT>-JUST = GC_C.
      WHEN 'PI'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "보빈규격(파이)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'BAREDIA'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F34. "동경치수
        <LS_FCAT>-JUST = GC_C.
      WHEN 'SUSYN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F35. "서스판여부
        <LS_FCAT>-JUST = GC_C.
      WHEN 'REMARK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F36. "특이사항
        <LS_FCAT>-JUST = GC_L.
      WHEN 'CRDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "생성일
        <LS_FCAT>-JUST = GC_C.
      WHEN 'CRTIM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "생성시간
        <LS_FCAT>-JUST = GC_C.
      WHEN 'CRNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "생성자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'CHDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "변경일
        <LS_FCAT>-JUST = GC_C.
      WHEN 'CHTIM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "변경시간
        <LS_FCAT>-JUST = GC_C.
      WHEN 'CHNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "변경자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'IFDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "전송일
        <LS_FCAT>-JUST = GC_C.
      WHEN 'IFTIM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "전송시간
        <LS_FCAT>-JUST = GC_C.
      WHEN 'IFNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "전송자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ADD3'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "여분필드3
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ADD4'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "여분필드4
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ADD5'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F26. "여분필드5
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ADD6'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27. "여분필드6
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ADD7'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F28. "여분필드7
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ADD8'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F29. "여분필드8
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ADD9'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F30. "여분필드9
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ADD10'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F31. "여분필드10
        <LS_FCAT>-JUST = GC_C.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CASE ABAP_TRUE.
      WHEN P_SEND.
        CASE <LS_FCAT>-FIELDNAME.
          WHEN 'ZIFKEY' OR 'ZSEQNO' OR 'IFDAT' OR 'IFTIM' OR 'IFNAM' OR
               'ADD3' OR 'ADD4' OR 'ADD5' OR
               'ADD6' OR 'ADD7' OR 'ADD8' OR 'ADD9' OR 'ADD10'.
            <LS_FCAT>-NO_OUT = GC_X.
        ENDCASE.

      WHEN P_DISP.
        CASE <LS_FCAT>-FIELDNAME.
          WHEN 'CRDAT' OR 'CRTIM' OR 'CRNAM' OR 'CHDAT' OR 'CHTIM' OR 'CHNAM' OR
               'ADD3' OR 'ADD4' OR 'ADD5' OR
               'ADD6' OR 'ADD7' OR 'ADD8' OR 'ADD9' OR 'ADD10'.
            <LS_FCAT>-NO_OUT = GC_X.
        ENDCASE.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0100 .
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0100
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_EXCLUDE_TOOLBAR_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_EXCLUDE_0100
*&      --> CL_GUI_ALV_GRID=>MC_FC_LOC_UND
*&---------------------------------------------------------------------*
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.
  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0100_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .

  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
    CHANGING
      IT_OUTTAB            = GT_DATA
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DISP .

  CLEAR: GT_DATA.
  SELECT A~*,
         B~NAME1,
         C~DDTEXT AS ZSYSTEM_ID_DESC
    FROM ZGTPPT1100 AS A
    LEFT OUTER JOIN T001W AS B ON B~WERKS EQ A~WERKS
    LEFT OUTER JOIN DD07V AS C ON C~DDLANGUAGE EQ @SY-LANGU
                              AND C~DOMNAME    EQ 'ZGTDTARGET'
                              AND C~DOMVALUE_L EQ A~ZSYSTEM_ID
   WHERE A~ZSYSTEM_ID EQ @P_TARGET
     AND A~WERKS      EQ @P_WERKS
     AND A~SPGCD      EQ @P_SPGCD
     AND A~BOBINID    IN @S_BBID
     AND A~ZGTDRNO    IN @S_DRNO
     AND A~PI         IN @S_PI
     AND A~IFDAT      IN @S_IFDAT
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.

  CASE GC_X.
    WHEN P_SUC.
      DELETE GT_DATA WHERE ZSTAT NE '00' AND ZSTAT NE '0'.
    WHEN P_FAIL.
      DELETE GT_DATA WHERE ZSTAT NE '01'.
  ENDCASE.

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>).
    CASE <FS_S>-ZSTAT.
      WHEN '00' OR '0'.
        <FS_S>-SEND_STAT = ICON_LED_GREEN.
      WHEN '01'.
        <FS_S>-SEND_STAT = ICON_LED_RED.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_SEND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_SEND .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE.

  DATA: LT_SEND LIKE TABLE OF GS_DATA.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'W'
       WITH TEXT-M05. "전송 대상 데이터가 없습니다.
    EXIT.
  ENDIF.

  CLEAR: LT_SEND.
  LOOP AT LT_ROW_NO.
    READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

    IF P_SEND EQ GC_X.
      IF <FS_S>-SEND_STAT EQ ICON_LED_GREEN.
        CONTINUE.
      ENDIF.
    ENDIF.

    APPEND INITIAL LINE TO LT_SEND ASSIGNING FIELD-SYMBOL(<LS_SEND>).
    MOVE-CORRESPONDING <FS_S> TO <LS_SEND>.
  ENDLOOP.

  IF LT_SEND[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'W'
       WITH TEXT-M05. "전송 대상 데이터가 없습니다.
  ELSE.
    PERFORM CALL_RFC TABLES LT_SEND.

    READ TABLE LT_SEND INTO DATA(LS_SEND) INDEX 1.

    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF LINE_EXISTS( LT_SEND[ ZSTAT = '00' ] ) OR
         LINE_EXISTS( LT_SEND[ ZSTAT = '0' ] ).
        <FS_S>-SEND_STAT = ICON_LED_GREEN.
      ELSE.
        <FS_S>-SEND_STAT = ICON_LED_RED.
      ENDIF.
      <FS_S>-ZMESSAGE = LS_SEND-ZMESSAGE.

      CASE ABAP_TRUE.
        WHEN P_DISP.
          <FS_S>-ZIFKEY = LS_SEND-ZIFKEY.
          <FS_S>-IFDAT = LS_SEND-IFDAT.
          <FS_S>-IFTIM = LS_SEND-IFTIM.
          <FS_S>-IFNAM = LS_SEND-IFNAM.
      ENDCASE.
    ENDLOOP.

  ENDIF.

  " REFRESH DISPLAY
  PERFORM REF_ALV_RTN USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEL_ROW_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW_NO
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM SEL_ROW_RTN  TABLES PT_ROW_NO TYPE LVC_T_ROID
                  USING  PR_ALV TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LT_INDEX_ROWS TYPE LVC_T_ROW,
        LT_ROW_NO     TYPE LVC_T_ROID.

  CLEAR: LT_INDEX_ROWS, LT_INDEX_ROWS[],
         LT_ROW_NO, LT_ROW_NO[].

  PR_ALV->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_INDEX_ROWS
      ET_ROW_NO     = LT_ROW_NO ).

  PT_ROW_NO[] = LT_ROW_NO[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REF_ALV_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM REF_ALV_RTN  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA LS_STABLE TYPE LVC_S_STBL.

  LS_STABLE-ROW = 'X'.
  LS_STABLE-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0100.

  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_RFC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SEND
*&---------------------------------------------------------------------*
FORM CALL_RFC  TABLES   PT_SENDTAB STRUCTURE GS_DATA.

  DATA: LT_OT_TAB LIKE GT_OT_TAB.
  MOVE-CORRESPONDING PT_SENDTAB[] TO LT_OT_TAB[].

*- 앞에 0 제거
*  PERFORM DATA_CONVERSION TABLES LT_OT_TAB.

  DATA: LV_DEST TYPE ZIFDEST-DEST.
  DATA: LV_ZSYSTEM_ID TYPE ZGTPPT1100-ZSYSTEM_ID. "송신대상시스템

  CLEAR: GV_RESULT, GV_MESSAGE, LV_DEST.

*- Destination 가져오기
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      GUBUN                 = 'P1'    "Destination 점검
    IMPORTING
      DEST_NAME             = LV_DEST
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.

  LV_ZSYSTEM_ID = P_TARGET.

*- RFC 전송
  CALL FUNCTION 'ZGTPP_IF_O_BOBIN_SEND' DESTINATION LV_DEST
    EXPORTING
      I_SYSTEM_ID = LV_ZSYSTEM_ID
    IMPORTING
      ZO_RESULT   = GV_RESULT
      ZO_MESSAGE  = GV_MESSAGE
    TABLES
      OT_TAB      = LT_OT_TAB.

*- History_Table에 저장
  IF GV_RESULT = '00' OR GV_RESULT = '0'.
    IF GV_MESSAGE IS INITIAL.
      GV_MESSAGE = TEXT-M06. "전송을 완료하였습니다.
    ENDIF.
  ELSE.
    IF GV_MESSAGE IS INITIAL.
      GV_MESSAGE = TEXT-M07. "전송 중 오류가 발생하였습니다.
    ENDIF.
  ENDIF.

  PERFORM SAVE_HISTORY_TABLE TABLES PT_SENDTAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_CONVERSION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_OT_TAB
*&---------------------------------------------------------------------*
FORM DATA_CONVERSION  TABLES   PT_OT_TAB STRUCTURE ZGTPPSIF0038.

  LOOP AT PT_OT_TAB ASSIGNING FIELD-SYMBOL(<LS_TAB>).
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = <LS_TAB>-ZGTDRNO
      IMPORTING
        OUTPUT = <LS_TAB>-ZGTDRNO.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_HISTORY_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_SENDTAB
*&---------------------------------------------------------------------*
FORM SAVE_HISTORY_TABLE  TABLES   PT_SENDTAB STRUCTURE GS_DATA.

  DATA: LV_SEQNO_N TYPE N LENGTH 10.
  DATA: LV_TIMESTAMP TYPE TIMESTAMPL.

  DATA: LT_ZGTPPT1100 LIKE TABLE OF ZGTPPT1100,
        LS_ZGTPPT1100 LIKE ZGTPPT1100.

  LV_SEQNO_N = 1.

  CLEAR: LT_ZGTPPT1100.
  GET TIME STAMP FIELD LV_TIMESTAMP.
  SORT PT_SENDTAB BY WERKS SPGCD ZGTDRNO PI.
  LOOP AT PT_SENDTAB ASSIGNING FIELD-SYMBOL(<LS_SENDTAB>).
    <LS_SENDTAB>-ZIFKEY     = LV_TIMESTAMP.
    <LS_SENDTAB>-ZSEQNO     = LV_SEQNO_N.
    <LS_SENDTAB>-ZSYSTEM_ID = P_TARGET.
    <LS_SENDTAB>-ZSTAT      = GV_RESULT.
    <LS_SENDTAB>-ZMESSAGE   = GV_MESSAGE.
    <LS_SENDTAB>-IFDAT      = SY-DATUM.
    <LS_SENDTAB>-IFTIM      = SY-UZEIT.
    <LS_SENDTAB>-IFNAM      = SY-UNAME.

    ADD 1 TO LV_SEQNO_N.

    MOVE-CORRESPONDING <LS_SENDTAB> TO LS_ZGTPPT1100.
    APPEND LS_ZGTPPT1100 TO LT_ZGTPPT1100.
    CLEAR: LS_ZGTPPT1100.
  ENDLOOP.

  MODIFY ZGTPPT1100 FROM TABLE LT_ZGTPPT1100.
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BATCH_EXEC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BATCH_EXEC .
  DATA: LV_LINES_C TYPE C LENGTH 10.

  IF GT_DATA[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH TEXT-M05. "전송 대상 데이터가 없습니다.

  ELSE.
    CLEAR: GT_SEND.
    APPEND LINES OF GT_DATA TO GT_SEND.

    PERFORM CALL_RFC TABLES GT_SEND.

    IF LINE_EXISTS( GT_SEND[ ZSTAT = '00' ] ) OR
       LINE_EXISTS( GT_SEND[ ZSTAT = '0' ] ).
      DATA(LV_INDEX) = LINES( GT_SEND ) .
      LV_LINES_C = LV_INDEX.
      CONDENSE LV_LINES_C.
      MESSAGE S000 WITH LV_LINES_C TEXT-M08. "건 전송되었습니다.
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH TEXT-M05. "전송 대상 데이터가 없습니다.
    ENDIF.
  ENDIF.

ENDFORM.
