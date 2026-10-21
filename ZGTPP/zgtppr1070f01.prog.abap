*&---------------------------------------------------------------------*
*& Include          ZGTPPR1070F01
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

  S_ERSDA[] = VALUE #( ( SIGN = GC_I
                         OPTION = GC_BT
                         LOW = SY-DATUM
                         HIGH = SY-DATUM )
                      ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECKING_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECKING_PROC .
*& 플랜트에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
  ID 'WERKS' FIELD P_WERKS.

  IF SY-SUBRC <> 0.
    "플랜트[P_WERKS] 작업권한을 확인하세요.
    MESSAGE E006 WITH TEXT-M01 P_WERKS TEXT-M02.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

*-생산버전 구성 마스터
  CLEAR: GT_1010.
  SELECT (GC_ALL)
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ @GC_PP
     AND CODEGRP     EQ @GC_1010
    INTO CORRESPONDING FIELDS OF TABLE @GT_1010.

*-생산버전 생성 대상 품목
  CLEAR: GT_ODATA.
  SELECT A~MATNR, A~MTART,
         B~WERKS, B~BESKZ, B~SOBSL, B~FVIDK,
         C~NAME1,
         D~MAKTX
    FROM            MARA  AS A
   INNER JOIN       MARC  AS B ON B~MATNR EQ A~MATNR
    LEFT OUTER JOIN T001W AS C ON C~WERKS EQ B~WERKS
    LEFT OUTER JOIN MAKT  AS D ON D~MATNR EQ A~MATNR
                              AND D~SPRAS EQ @SY-LANGU
   WHERE A~MATNR IN @S_MATNR
     AND A~ERSDA IN @S_ERSDA
     AND A~MTART IN (@GC_FERT, @GC_HALB, @GC_MCHF)
     AND B~WERKS EQ @P_WERKS
     AND ( ( ( B~BESKZ EQ @GC_E OR B~BESKZ EQ @GC_X ) AND B~SOBSL EQ @SPACE ) "자작
          OR ( B~BESKZ EQ @GC_F AND B~SOBSL EQ @GC_30 )    "외주
          OR ( B~BESKZ EQ @GC_X AND B~SOBSL EQ @GC_30 ) )  "자작/외주
    INTO CORRESPONDING FIELDS OF TABLE @GT_ODATA.

  SORT GT_ODATA BY BESKZ SOBSL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA .

*-생산버전
  DATA: L_VERID LIKE MKAL-VERID,
        L_BDATU LIKE MKAL-BDATU,
        L_ADATU LIKE MKAL-ADATU.

*-BOM
  DATA: L_STLNR LIKE MAST-STLNR.

*-ROUTING
  DATA: L_PLNNR LIKE MAPL-PLNNR,
        L_PLNAL LIKE MAPL-PLNAL,
        L_PLNTY LIKE MAPL-PLNTY.

*-생산버전 구성 마스터 기준으로 대상 품목 확인
  CLEAR: GT_DATA.
  LOOP AT GT_ODATA INTO DATA(LS_ODATA).
    LOOP AT GT_1010 INTO DATA(LS_1010) WHERE FLD_02 EQ LS_ODATA-BESKZ
                                         AND FLD_03 EQ LS_ODATA-SOBSL.

*-공통
      MOVE: ICON_LED_INACTIVE TO GS_DATA-PROC_STAT,
            LS_ODATA-MATNR    TO GS_DATA-MATNR,
            LS_ODATA-MAKTX    TO GS_DATA-MAKTX,
            LS_ODATA-WERKS    TO GS_DATA-WERKS,
            LS_ODATA-NAME1    TO GS_DATA-NAME1,
            LS_ODATA-BESKZ    TO GS_DATA-BESKZ,
            LS_ODATA-SOBSL    TO GS_DATA-SOBSL,
            LS_ODATA-FVIDK    TO GS_DATA-FVIDK,
            LS_ODATA-MTART    TO GS_DATA-MTART,
            LS_1010-FLD_04    TO GS_DATA-FLD_04,
            LS_1010-FLD_05    TO GS_DATA-FLD_05.

*-원가추정용 생산버전 설정 존재 유무
      IF LS_ODATA-FVIDK IS INITIAL.
        MOVE: ICON_LED_INACTIVE TO GS_DATA-FVIDK_STAT.
      ELSE.
        MOVE: ICON_LED_GREEN TO GS_DATA-FVIDK_STAT.
      ENDIF.

*-생산버전 구성 기준 정보로 존재 유무 파악(생산버전,BOM,ROUTING)
*-생산버전
      CLEAR: L_VERID, L_BDATU, L_ADATU.
      SELECT SINGLE VERID, BDATU, ADATU
        FROM MKAL
       WHERE MATNR EQ @LS_ODATA-MATNR
         AND WERKS EQ @LS_ODATA-WERKS
         AND VERID EQ @LS_1010-FLD_06
        INTO (@L_VERID, @L_BDATU, @L_ADATU).

      IF L_VERID IS INITIAL.
        MOVE: ICON_LED_INACTIVE TO GS_DATA-PVER_STAT,
              LS_1010-FLD_06    TO GS_DATA-VERID,
              LS_1010-FLD_07    TO GS_DATA-TEXT1,
              SY-DATUM          TO GS_DATA-ADATU,
              '99991231'        TO GS_DATA-BDATU.
      ELSE.
        MOVE: ICON_LED_GREEN TO GS_DATA-PVER_STAT,
              LS_1010-FLD_06 TO GS_DATA-VERID,
              LS_1010-FLD_07 TO GS_DATA-TEXT1,
              L_ADATU        TO GS_DATA-ADATU,
              L_BDATU        TO GS_DATA-BDATU.
      ENDIF.

*-BOM
      CLEAR: L_STLNR.
      SELECT SINGLE STLNR
        FROM MAST
       WHERE MATNR EQ @LS_ODATA-MATNR
         AND WERKS EQ @LS_ODATA-WERKS
         AND STLAN EQ @LS_1010-FLD_08
         AND STLAL EQ @LS_1010-FLD_09
        INTO @L_STLNR.

      IF L_STLNR IS INITIAL.
        IF LS_1010-FLD_06 EQ GC_CO10.
          MOVE: ICON_LED_RED   TO GS_DATA-BOM_STAT,
                LS_1010-FLD_08 TO GS_DATA-STLAN,
                LS_1010-FLD_09 TO GS_DATA-STLAL.
        ELSE.
          MOVE: ICON_LED_INACTIVE TO GS_DATA-BOM_STAT,
                LS_1010-FLD_08    TO GS_DATA-STLAN,
                LS_1010-FLD_09    TO GS_DATA-STLAL.
        ENDIF.
      ELSE.
        MOVE: ICON_LED_GREEN TO GS_DATA-BOM_STAT,
              LS_1010-FLD_08 TO GS_DATA-STLAN,
              LS_1010-FLD_09 TO GS_DATA-STLAL,
              L_STLNR        TO GS_DATA-STLNR.
      ENDIF.

*-ROUTING
      CLEAR: L_PLNNR, L_PLNAL, L_PLNTY.
      SELECT SINGLE PLNNR, PLNAL, PLNTY
        FROM MAPL
       WHERE MATNR EQ @LS_ODATA-MATNR
         AND WERKS EQ @LS_ODATA-WERKS
         AND PLNAL EQ @LS_1010-FLD_10
        INTO (@L_PLNNR, @L_PLNAL, @L_PLNTY).

      IF L_PLNNR IS INITIAL.
        IF LS_1010-FLD_06 EQ GC_0010.
          MOVE: ICON_LED_INACTIVE TO GS_DATA-ROUT_STAT,
                LS_1010-FLD_10    TO GS_DATA-PLNAL.
        ELSEIF LS_1010-FLD_06 EQ GC_CO10.
          MOVE: ICON_LED_RED   TO GS_DATA-ROUT_STAT,
                LS_1010-FLD_10 TO GS_DATA-PLNAL.
        ENDIF.
      ELSE.
        IF LS_1010-FLD_06 EQ GC_0010 OR LS_1010-FLD_06 = GC_CO10.
          MOVE: ICON_LED_GREEN TO GS_DATA-ROUT_STAT,
                LS_1010-FLD_10 TO GS_DATA-PLNAL,
                L_PLNNR        TO GS_DATA-PLNNR,
                L_PLNTY        TO GS_DATA-PLNTY.
        ENDIF.
      ENDIF.

      IF GS_DATA-VERID EQ GC_CO10 AND GS_DATA-MTART NE GC_FERT.
        "생산버전 = CO10 은 MTART = FERT 만 조회되도록 그외는 PASS
      ELSE.
        APPEND GS_DATA TO GT_DATA.
      ENDIF.

      CLEAR: LS_1010, GS_DATA.
    ENDLOOP.

    CLEAR: LS_ODATA, GS_DATA.
  ENDLOOP.

  SORT GT_DATA BY MATNR VERID.

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
         GT_EXCLUDE_0100, GT_DATA[], GV_OK_CODE, GV_DBCNT,
         GT_1010[], GT_ODATA[].

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
      I_INCLNAME             = 'ZGTPPR1070TOP'
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
      WHEN 'PROC_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "처리상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'PROC_MSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "메세지
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "품목코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "품목내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "플랜트
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "플랜트 내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'BESKZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "조달유형
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'SOBSL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "특별조달
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'PVER_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "생산버전상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'VERID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "생산버전
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'TEXT1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "생산버전내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'FVIDK_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "원가추정용 생산버전 설정
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'ADATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "효력시작일
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'BDATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "효력종료일
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C510'.
      WHEN 'BOM_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "BOM상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'STLAN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "BOM용도
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'STLAL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "대체BOM
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C600'.
      WHEN 'ROUT_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "ROUTING상태
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN 'PLNAL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "그룹카운터
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EMPHASIZE = 'C500'.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

*    IF <LS_FCAT>-FIELDNAME = 'PROC_STAT' OR <LS_FCAT>-FIELDNAME = 'PROC_MSG'.
*
*    ELSE.
    CLEAR: <LS_FCAT>-KEY.
*    ENDIF.
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
*& Form PROCESS_EXEC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_EXEC .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'W'
       WITH TEXT-M03. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T01 "생산버전 생성
      TEXT_QUESTION         = TEXT-T02 "생산버전 생성을 수행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-PVER_STAT EQ ICON_LED_GREEN OR <FS_S>-PROC_STAT EQ ICON_LED_GREEN.
        <FS_S>-PROC_MSG = TEXT-M04. "이미 생산버전이 생성된 레코드입니다.
      ELSE.
        IF <FS_S>-FLD_04 EQ GC_Y AND <FS_S>-BOM_STAT EQ ICON_LED_RED.
          <FS_S>-PROC_MSG = TEXT-M05. "생산버전 생성 전, BOM 생성이 선행되어야 합니다.
        ELSE.
          IF <FS_S>-FLD_05 EQ GC_Y AND <FS_S>-ROUT_STAT EQ ICON_LED_RED.
            <FS_S>-PROC_MSG = TEXT-M06. "생산버전 생성 전, Routing 생성이 선행되어야 합니다.
          ELSE.
            PERFORM EXEC_VERID USING <FS_S>.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REF_ALV_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REF_ALV_RTN .
  DATA LS_STABLE TYPE LVC_S_STBL.

  CALL METHOD GO_GRID_0100->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYOUT_0100.

  LS_STABLE-ROW = 'X'.
  LS_STABLE-COL = 'X'.

  CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.
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

*--------------------------------------------------------------------*

  CLEAR: LT_INDEX_ROWS, LT_INDEX_ROWS[],
         LT_ROW_NO, LT_ROW_NO[].

  PR_ALV->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_INDEX_ROWS
      ET_ROW_NO     = LT_ROW_NO ).

  PT_ROW_NO[] = LT_ROW_NO[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_VERID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_VERID  USING    P_LINE LIKE GS_DATA.

  "BOM 점검 = P AND BOM 미생성 인 경우 BOM 생성
  IF P_LINE-FLD_04 EQ GC_P AND P_LINE-BOM_STAT NE ICON_LED_GREEN.
    PERFORM BOM_CREATE USING P_LINE.
  ENDIF.

  "ROUTING 점검 = P AND ROUTING 미생성 인 경우 ROUTING 생성
  IF P_LINE-FLD_05 EQ GC_P AND P_LINE-ROUT_STAT NE ICON_LED_GREEN.
    PERFORM ROUTING_CREATE USING P_LINE.
  ENDIF.

  "생산버전 = 0010 OR CO10인 경우 BOM/ROUTING 필요
  IF P_LINE-VERID EQ GC_0010 OR P_LINE-VERID EQ GC_CO10.
    IF P_LINE-BOM_STAT EQ ICON_LED_GREEN AND
       P_LINE-ROUT_STAT EQ ICON_LED_GREEN.
      PERFORM VERID_CREATE USING P_LINE.
    ELSE.
      P_LINE-PROC_MSG = TEXT-M11. "BOM 또는 Routing 생성이 선행되어야 합니다.
    ENDIF.
    "생산버전 = SC10 인 경우 BOM 필요
  ELSEIF P_LINE-VERID EQ GC_SC10.
    IF P_LINE-BOM_STAT EQ ICON_LED_GREEN.
      PERFORM VERID_CREATE USING P_LINE.
    ELSE.
      P_LINE-PROC_MSG = TEXT-M12. "BOM 생성이 선행되어야 합니다.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BOM_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM BOM_CREATE  USING    P_LINE LIKE GS_DATA.

  DATA: L_STLNR LIKE MAST-STLNR.

  CLEAR: L_STLNR.
  SELECT SINGLE STLNR
    FROM MAST
   WHERE MATNR EQ @P_LINE-MATNR
     AND WERKS EQ @P_LINE-WERKS
     AND STLAN EQ @P_LINE-STLAN
     AND STLAL EQ @P_LINE-STLAL
    INTO @L_STLNR.

  IF L_STLNR IS NOT INITIAL.
    P_LINE-STLNR = L_STLNR.
  ELSE.
    CLEAR: BDCDATA, BDCDATA[], MESSTAB, MESSTAB[],
           GV_INDEX, GV_TEXT.

    PERFORM DYNPRO1 USING:
          'X' 'SAPLCSDI'    '0100',
          ' ' 'BDC_OKCODE'  '/00',
          ' ' 'RC29N-MATNR' P_LINE-MATNR,
          ' ' 'RC29N-WERKS' P_LINE-WERKS,
          ' ' 'RC29N-STLAN' P_LINE-STLAN,
          ' ' 'RC29N-STLAL' P_LINE-STLAL,
          ' ' 'RC29N-DATUV' '20240101'.

    PERFORM DYNPRO1 USING:
          'X' 'SAPLCSDI'    '2150',
          ' ' 'BDC_OKCODE'  '=FCBU'.

    GS_PARAMS-DISMODE  = 'N'.   " 처리모드
    GS_PARAMS-UPDMODE  = 'S'.   " 갱신세션
    GS_PARAMS-CATTMODE = 'A'.   " CATT모드
    GS_PARAMS-DEFSIZE  = ' '.   " 기본화면
    GS_PARAMS-RACOMMIT = 'X'.   " COMMIT 이후 지속
    GS_PARAMS-NOBINPT  = 'X'.   " BI 세션

    CALL TRANSACTION 'CS01'
               USING BDCDATA
             OPTIONS FROM GS_PARAMS
            MESSAGES INTO MESSTAB.

    READ TABLE MESSTAB WITH KEY MSGTYP = GC_E.

    IF SY-SUBRC EQ 0.
      P_LINE-PROC_MSG = TEXT-M09. "BOM 생성 중 오류 발생
    ELSE.
      "자재 ~에 대한 BOM을 생성하고 있습니다.
      READ TABLE MESSTAB WITH KEY MSGTYP = GC_S
                                  MSGID  = '29'
                                  MSGNR  = '030'.

      IF SY-SUBRC EQ 0.
        DO 1000 TIMES.
          SELECT SINGLE STLNR
            FROM MAST
           WHERE MATNR EQ @P_LINE-MATNR
             AND WERKS EQ @P_LINE-WERKS
             AND STLAN EQ @P_LINE-STLAN
             AND STLAL EQ @P_LINE-STLAL
            INTO @P_LINE-STLNR.
          IF SY-SUBRC EQ 0.
            EXIT.
          ELSE.
            WAIT UP TO '0.5' SECONDS.
          ENDIF.
        ENDDO.
      ELSE.
        P_LINE-PROC_MSG = TEXT-M09. "BOM 생성 중 오류 발생
      ENDIF.
    ENDIF.

  ENDIF.

  IF P_LINE-STLNR IS NOT INITIAL.
    P_LINE-BOM_STAT = ICON_LED_GREEN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DYNPRO1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM DYNPRO1  USING DYNBEGIN NAME VALUE.
  CLEAR BDCDATA.
  IF DYNBEGIN = 'X'.
    MOVE: NAME  TO BDCDATA-PROGRAM,
          VALUE TO BDCDATA-DYNPRO,
          'X'   TO BDCDATA-DYNBEGIN.
    APPEND BDCDATA.
  ELSE.
    MOVE: NAME  TO BDCDATA-FNAM,
          VALUE TO BDCDATA-FVAL.
    APPEND BDCDATA.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ROUTING_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM ROUTING_CREATE  USING    P_LINE LIKE GS_DATA.

  DATA: L_PLNNR LIKE MAPL-PLNNR,
        L_PLNAL LIKE MAPL-PLNAL,
        L_PLNTY LIKE MAPL-PLNTY.

  CLEAR: L_PLNNR, L_PLNAL, L_PLNTY.
  SELECT SINGLE PLNNR, PLNAL, PLNTY
    FROM MAPL
   WHERE MATNR EQ @P_LINE-MATNR
     AND WERKS EQ @P_LINE-WERKS
     AND PLNAL EQ @P_LINE-PLNAL
    INTO (@L_PLNNR, @L_PLNAL, @L_PLNTY).

  IF L_PLNNR IS NOT INITIAL.
    P_LINE-PLNNR = L_PLNNR.
    P_LINE-PLNTY = L_PLNTY.
  ELSE.
    CLEAR: BDCDATA, BDCDATA[], MESSTAB, MESSTAB[],
           GV_INDEX, GV_TEXT.

    PERFORM DYNPRO1 USING:
          'X' 'SAPLCPDI'        '1010',
          ' ' 'BDC_OKCODE'      '=XALU',
          ' ' 'RC27M-MATNR'     P_LINE-MATNR,
          ' ' 'RC27M-WERKS'     P_LINE-WERKS,
          ' ' 'RC271-STTAG'     '20240101'.

    PERFORM DYNPRO1 USING:
          'X' 'SAPLCPDA'        '1200',
          ' ' 'BDC_OKCODE'      '=VOUE',
          ' ' 'PLKOD-PLNAL'     P_LINE-PLNAL,
          ' ' 'PLKOD-VERWE'     '1',
          ' ' 'PLKOD-STATU'     '4'.

    PERFORM DYNPRO1 USING:
          'X' 'SAPLCPDI'        '1400',
          ' ' 'BDC_OKCODE'      '/00',
          ' ' 'PLPOD-ARBPL(01)' 'ASM001'.

    PERFORM DYNPRO1 USING:
          'X' 'SAPLCPDI'        '1400',
          ' ' 'BDC_OKCODE'      '/00',
          ' ' 'PLPOD-VGW01(01)' '1',
          ' ' 'PLPOD-VGW02(01)' '1',
          ' ' 'PLPOD-VGW03(01)' '1',
          ' ' 'PLPOD-VGW04(01)' '1',
          ' ' 'PLPOD-VGW05(01)' '1',
          ' ' 'PLPOD-VGW06(01)' '1'.

    PERFORM DYNPRO1 USING:
          'X' 'SAPLCPDI'        '1400',
          ' ' 'BDC_OKCODE'      '=BU'.

    GS_PARAMS-DISMODE  = 'N'.   " 처리모드
    GS_PARAMS-UPDMODE  = 'S'.   " 갱신세션
    GS_PARAMS-CATTMODE = 'A'.   " CATT모드
    GS_PARAMS-DEFSIZE  = ' '.   " 기본화면
    GS_PARAMS-RACOMMIT = 'X'.   " COMMIT 이후 지속
    GS_PARAMS-NOBINPT  = 'X'.   " BI 세션

    CALL TRANSACTION 'CA01'
               USING BDCDATA
             OPTIONS FROM GS_PARAMS
            MESSAGES INTO MESSTAB.

    READ TABLE MESSTAB WITH KEY MSGTYP = GC_E.

    IF SY-SUBRC EQ 0.
      P_LINE-PROC_MSG = TEXT-M10. "Routing 생성 중 오류 발생
    ELSE.
      "공정을 그룹 ~ 및 자재 ~과(와) 함께 저장했습니다.
      READ TABLE MESSTAB WITH KEY MSGTYP = GC_S
                                  MSGID  = 'CV'
                                  MSGNR  = '761'.
      IF SY-SUBRC EQ 0.
        DO 1000 TIMES.
          SELECT SINGLE PLNNR, PLNTY
            FROM MAPL
           WHERE MATNR EQ @P_LINE-MATNR
             AND WERKS EQ @P_LINE-WERKS
             AND PLNAL EQ @P_LINE-PLNAL
            INTO (@P_LINE-PLNNR, @P_LINE-PLNTY).
          IF SY-SUBRC EQ 0.
            EXIT.
          ELSE.
            WAIT UP TO '0.5' SECONDS.
          ENDIF.
        ENDDO.
      ELSE.
        P_LINE-PROC_MSG = TEXT-M10. "Routing 생성 중 오류 발생
      ENDIF.
    ENDIF.

  ENDIF.

  IF P_LINE-PLNNR IS NOT INITIAL.
    P_LINE-ROUT_STAT = ICON_LED_GREEN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VERID_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM VERID_CREATE  USING    P_LINE LIKE GS_DATA.

  DATA: LT_PROD_VERSION TYPE BOM_TT_PRODVER_MKAL_ENTRIES,
        LS_PROD_VERSION TYPE BOM_TY_PRODVER_MKAL_ENTRIES.

  CLEAR: LS_PROD_VERSION, LT_PROD_VERSION, LT_PROD_VERSION[].
  LS_PROD_VERSION-MATNR  = P_LINE-MATNR.
  LS_PROD_VERSION-WERKS  = P_LINE-WERKS.
  LS_PROD_VERSION-VERID  = P_LINE-VERID.
  LS_PROD_VERSION-ADATU  = P_LINE-ADATU.
  LS_PROD_VERSION-BDATU  = P_LINE-BDATU.
  LS_PROD_VERSION-STLAL  = P_LINE-STLAL.
  LS_PROD_VERSION-STLAN  = P_LINE-STLAN.
  IF P_LINE-VERID EQ GC_0010 OR P_LINE-VERID EQ GC_CO10.
    LS_PROD_VERSION-PLNTY  = GC_N.
    LS_PROD_VERSION-PLNNR  = P_LINE-PLNNR.
    LS_PROD_VERSION-ALNAL  = P_LINE-PLNAL.
    LS_PROD_VERSION-PRFG_F = '1'.
  ENDIF.
  LS_PROD_VERSION-PRFG_S = '1'.
  LS_PROD_VERSION-PRDAT  = SY-DATUM.
  LS_PROD_VERSION-TEXT1  = P_LINE-TEXT1.

  APPEND LS_PROD_VERSION TO LT_PROD_VERSION.

  CALL FUNCTION 'CS_BOM_UPDATE_PROD_VERSIONS'
    EXPORTING
      IT_PROD_VERSION = LT_PROD_VERSION.

  IF SY-SUBRC EQ 0.
    "버전지시자 update
    UPDATE MARC SET VERKZ = @GC_X
              WHERE WERKS EQ @P_LINE-WERKS
                AND MATNR EQ @P_LINE-MATNR.

    IF P_LINE-VERID EQ GC_CO10.
      "원가 계산될 생산버전 update
      CLEAR: HEADDATA, PLANTDATA, PLANTDATAX.
      HEADDATA-MATERIAL = P_LINE-MATNR.
      HEADDATA-COST_VIEW = GC_X.

      PLANTDATA-PLANT = P_LINE-WERKS.
      PLANTDATA-PRODVERSCS = P_LINE-VERID.

      PLANTDATAX-PLANT = P_LINE-WERKS.
      PLANTDATAX-PRODVERSCS = GC_X.

      CLEAR: GS_RETURN.
      CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
        EXPORTING
          HEADDATA   = HEADDATA
          PLANTDATA  = PLANTDATA
          PLANTDATAX = PLANTDATAX
        IMPORTING
          RETURN     = GS_RETURN.

      IF GS_RETURN-TYPE EQ 'E'.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        P_LINE-PROC_STAT = ICON_LED_RED.
        P_LINE-FVIDK_STAT = ICON_LED_RED.
        P_LINE-PROC_MSG = GS_RETURN-MESSAGE.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = GC_X.

        P_LINE-PVER_STAT = ICON_LED_GREEN.
        P_LINE-PROC_STAT = ICON_LED_GREEN.
        P_LINE-FVIDK_STAT = ICON_LED_GREEN.
        P_LINE-FVIDK = P_LINE-VERID.
        P_LINE-PROC_MSG = TEXT-M07. "생산버전이 성공적으로 생성되었습니다.
      ENDIF.
    ELSE.
      IF SY-SUBRC EQ 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = GC_X.

        P_LINE-PVER_STAT = ICON_LED_GREEN.
        P_LINE-PROC_STAT = ICON_LED_GREEN.
        P_LINE-PROC_MSG = TEXT-M07. "생산버전이 성공적으로 생성되었습니다.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        P_LINE-PROC_STAT = ICON_LED_RED.
        P_LINE-PROC_MSG = TEXT-M08. "생산버전 생성 중 오류가 발생하였습니다.
      ENDIF.
    ENDIF.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    P_LINE-PROC_STAT = ICON_LED_RED.
    P_LINE-PROC_MSG = TEXT-M08. "생산버전 생성 중 오류가 발생하였습니다.
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

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>).
    IF <FS_S>-PVER_STAT EQ ICON_LED_GREEN OR <FS_S>-PROC_STAT EQ ICON_LED_GREEN.
      <FS_S>-PROC_MSG = TEXT-M04. "이미 생산버전이 생성된 레코드입니다.
    ELSE.
      IF <FS_S>-FLD_04 EQ GC_Y AND <FS_S>-BOM_STAT EQ ICON_LED_RED.
        <FS_S>-PROC_MSG = TEXT-M05. "생산버전 생성 전, BOM 생성이 선행되어야 합니다.
      ELSE.
        IF <FS_S>-FLD_05 EQ GC_Y AND <FS_S>-ROUT_STAT EQ ICON_LED_RED.
          <FS_S>-PROC_MSG = TEXT-M06. "생산버전 생성 전, Routing 생성이 선행되어야 합니다.
        ELSE.
          PERFORM EXEC_VERID USING <FS_S>.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

*- 전체 건수
  DATA(LV_CNT_T) = LINES( GT_DATA ).

*- 성공 건수
  DATA(LV_CNT_S) = REDUCE I(
                   INIT SUM = 0 FOR LS_CNT_S IN GT_DATA
                   WHERE ( PROC_STAT = ICON_LED_GREEN )
                   NEXT SUM = SUM + 1 ).

*- 실패 건수
  DATA(LV_CNT_E) = LV_CNT_T - LV_CNT_S.

  "전체 &1건 중 &2건 처리 성공, &3건 처리 실패
  MESSAGE S009(ZGTPP00) WITH LV_CNT_T LV_CNT_S LV_CNT_E.

ENDFORM.
