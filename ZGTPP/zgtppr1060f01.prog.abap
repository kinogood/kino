*&---------------------------------------------------------------------*
*& Include          ZGTPPR1060F01
*&---------------------------------------------------------------------*
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
    IF P_EXEC = GC_X.
      IF SCREEN-GROUP1 = 'S1'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSE.
      IF SCREEN-GROUP1 = 'S2'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
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
  CLEAR: GT_1010.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_1010
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ 'PP'
     AND CODEGRP     EQ '1000'.

  IF P_EXEC EQ GC_X.
    PERFORM GET_EXEC_DATA.
  ELSEIF P_DISP EQ GC_X.
    PERFORM GET_HISTORY_DATA.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_EXEC_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_EXEC_DATA .

  CLEAR: GT_DATA.
  SELECT A~*,
         B~MAKTX,
         C~NAME1
    FROM           ZGTPPT1060 AS A
    LEFT OUTER JOIN MAKT      AS B ON B~MATNR EQ A~MATNR
                                  AND B~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T001W     AS C ON C~WERKS EQ A~WERKS
   WHERE A~WERKS     IN @S_WERKS
     AND A~MATNR     IN @S_MATNR
     AND A~STDDT     IN @S_STDDT
     AND A~ROUT_STAT NE @GC_S
     AND A~ZERP_STAT EQ @GC_S
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.

  SORT GT_DATA BY MATNR WERKS.

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

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>).
* ID
    IF <FS_S>-ROUT_STAT EQ GC_S.
      <FS_S>-ID = ICON_LED_GREEN.
    ELSEIF <FS_S>-ROUT_STAT EQ GC_E.
      <FS_S>-ID = ICON_LED_RED.
    ELSE.
      <FS_S>-ID = ICON_LED_INACTIVE.
    ENDIF.

    IF P_EXEC EQ GC_X.
* 라우팅 존재 여부 check
      SELECT SINGLE PLNNR
        INTO @DATA(L_PLNNR)
        FROM MAPL
       WHERE MATNR EQ @<FS_S>-MATNR   "ROUT_MATNR
         AND WERKS EQ @<FS_S>-WERKS.

      IF L_PLNNR IS INITIAL.
        <FS_S>-PTYPE = TEXT-T01.  "생성
      ELSE.
        <FS_S>-PTYPE = TEXT-T02.  "변경
      ENDIF.
      CLEAR: L_PLNNR.
    ENDIF.

* 품목내역
*    SELECT SINGLE MAKTX
*      INTO <FS_S>-ROUT_MAKTX
*      FROM MAKT
*     WHERE MATNR EQ <FS_S>-ROUT_MATNR
*       AND SPRAS EQ SY-LANGU.

* 작업유형내역/작업장
    READ TABLE GT_1010 INTO DATA(LS_1010) WITH KEY FLD_02 = <FS_S>-WC_TYPE.
    <FS_S>-TYPE_DESC = LS_1010-FLD_05.
    <FS_S>-ARBPL = LS_1010-FLD_04.
    CLEAR: LS_1010.

    <FS_S>-ARBPL = GC_ASM001.
    <FS_S>-VORNR = GC_0010.

*-자재+플랜트별 ACT 값 SUM
    IF <FS_S>-ID NE ICON_LED_GREEN.
      MOVE-CORRESPONDING <FS_S> TO GS_ACT_SUM.
      COLLECT GS_ACT_SUM INTO GT_ACT_SUM.
      CLEAR: GS_ACT_SUM.
    ENDIF.
  ENDLOOP.

  SORT GT_ACT_SUM BY MATNR WERKS.
  DELETE ADJACENT DUPLICATES FROM GT_ACT_SUM
         COMPARING MATNR WERKS.

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
         GT_EXCLUDE_0100, GT_DATA[], GV_OK_CODE, GV_DBCNT.

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
      I_INCLNAME             = 'ZGTPPR1060TOP'
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
      WHEN 'ID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "처리상태
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
      WHEN 'ROUT_STAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "처리
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-NO_OUT = GC_X.
      WHEN 'ROUT_MSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "메시지
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_L.
      WHEN 'PTYPE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "처리유형
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "완제품 코드
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "완제품 내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "플랜트
        <LS_FCAT>-JUST = GC_C.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "플랜트 내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'ZIFKEY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "인터페이스 키
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZSYSTEM_ID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "송신 시스템
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZSERNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "일련번호
        <LS_FCAT>-KEY = GC_X.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'STDDT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "기준일자
        <LS_FCAT>-JUST = GC_C.
*      WHEN 'ROUT_MATNR'.
*        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "품목 코드
*        <LS_FCAT>-JUST = GC_C.
*      WHEN 'ROUT_MAKTX'.
*        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "품목 내역
*        <LS_FCAT>-JUST = GC_L.
      WHEN 'WC_TYPE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "작업유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'TYPE_DESC'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "유형내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'ZTIME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "작업시간
        <LS_FCAT>-JUST = GC_R.
      WHEN 'ZUNIT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "시간단위
        <LS_FCAT>-JUST = GC_C.
      WHEN 'IFDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "전송일자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'IFTIM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "전송시간
        <LS_FCAT>-JUST = GC_C.
      WHEN 'IFNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "전송자
        <LS_FCAT>-JUST = GC_C.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    IF <LS_FCAT>-FIELDNAME = 'ID'       OR <LS_FCAT>-FIELDNAME = 'ROUT_STAT' OR
       <LS_FCAT>-FIELDNAME = 'ROUT_MSG' OR <LS_FCAT>-FIELDNAME = 'PTYPE' OR
       <LS_FCAT>-FIELDNAME = 'MATNR'.

    ELSE.
      CLEAR: <LS_FCAT>-KEY.
    ENDIF.
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

  DATA: LT_DATASEL LIKE TABLE OF GS_DATA.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'W'
       WITH TEXT-M05. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T03 "표준 Routing 생성/변경
      TEXT_QUESTION         = TEXT-T04 "표준 Routing을 생성/변경 하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LT_DATASEL.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-ID EQ ICON_LED_GREEN.
        <FS_S>-ROUT_MSG = TEXT-M01. "이미 처리된 레코드입니다.
      ELSE.
        IF <FS_S>-MATNR IS INITIAL. "ROUT_MATNR IS INITIAL.
          <FS_S>-ID       = ICON_LED_RED.
          <FS_S>-ROUT_MSG = TEXT-M04. "품목이 없습니다.
        ELSE.
*-선택한 데이터
          APPEND <FS_S> TO LT_DATASEL.
        ENDIF.
      ENDIF.

    ENDLOOP.

*-선택된 데이터를 완제품코드+플랜트 기준으로 중복 제거
    SORT LT_DATASEL BY MATNR WERKS.
    DELETE ADJACENT DUPLICATES FROM LT_DATASEL
                          COMPARING MATNR WERKS.

    SORT LT_DATASEL BY MATNR WERKS.

*-선택된 데이터를 완제품코드+플랜트 기준으로 라우팅 생성/변경
    LOOP AT LT_DATASEL ASSIGNING FIELD-SYMBOL(<FS_SEL>).
      " 표준 Routing 생성/변경
      PERFORM EXEC_ROUTING USING <FS_SEL>.
    ENDLOOP.

*-처리 결과 ALV 적용
    LOOP AT GT_DATA ASSIGNING <FS_S> WHERE ID NE ICON_LED_GREEN.
      READ TABLE LT_DATASEL INTO DATA(LS_DATASEL) WITH KEY MATNR = <FS_S>-MATNR
                                                           WERKS = <FS_S>-WERKS.
      IF SY-SUBRC EQ 0.
        <FS_S>-ID        = LS_DATASEL-ID.
        <FS_S>-ROUT_STAT = LS_DATASEL-ROUT_STAT.
        <FS_S>-ROUT_MSG  = LS_DATASEL-ROUT_MSG.

        UPDATE ZGTPPT1060 SET ROUT_STAT  = <FS_S>-ROUT_STAT
                              ROUT_MSG   = <FS_S>-ROUT_MSG
                        WHERE WERKS      = <FS_S>-WERKS
                          AND MATNR      = <FS_S>-MATNR.
        COMMIT WORK.
      ENDIF.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_HISTORY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_HISTORY_DATA .

  CLEAR: GT_DATA.
  SELECT A~*,
         B~MAKTX,
         C~NAME1
    FROM            ZGTPPT1060 AS A
    LEFT OUTER JOIN MAKT       AS B ON B~MATNR EQ A~MATNR
                                   AND B~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN T001W      AS C ON C~WERKS EQ A~WERKS
   WHERE A~WERKS IN @S_WERKS
     AND A~MATNR IN @S_MATNR
     AND A~STDDT IN @S_STDDT
     AND A~IFDAT IN @S_IFDAT
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.

  CASE ABAP_TRUE.
    WHEN P_ALL.
    WHEN P_SUC.
      DELETE GT_DATA WHERE ROUT_STAT NE GC_S.
    WHEN P_ERR.
      DELETE GT_DATA WHERE ROUT_STAT NE GC_E.
  ENDCASE.

  SORT GT_DATA BY WERKS MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ref_alv_rtn
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
*&      --> GCL_ALVG
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
*& Form EXEC_ROUTING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_ROUTING  USING    P_LINE LIKE GS_DATA.

  IF P_LINE-PTYPE EQ TEXT-T01.      "생성
    PERFORM CREATE_ROUTING USING P_LINE.
  ELSEIF P_LINE-PTYPE EQ TEXT-T02.  "변경
    PERFORM CHANGE_ROUTING USING P_LINE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_routing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM CREATE_ROUTING  USING    P_LINE LIKE GS_DATA.

  _CL: GT_TASK, GT_MAT_TASK_ALC, GT_OPERATION.

  CLEAR: GV_PLNNR.

*- Task
  PERFORM SET_TASK_HEADER USING P_LINE.
  PERFORM SET_MAT_TASK_ALC USING P_LINE.
  PERFORM SET_OPERATION USING P_LINE.

  CLEAR: GT_RETURN, GV_GROUP, GV_GROUPCOUNTER, GS_RETURN.

  CALL FUNCTION 'BAPI_ROUTING_CREATE'
    EXPORTING
*     TESTRUN                = ' '
      APPLICATION            = GC_CAPID_PP01
    IMPORTING
      GROUP                  = GV_GROUP
      GROUPCOUNTER           = GV_GROUPCOUNTER
    TABLES
      TASK                   = GT_TASK
      MATERIALTASKALLOCATION = GT_MAT_TASK_ALC
      OPERATION              = GT_OPERATION
      RETURN                 = GT_RETURN.

  READ TABLE GT_RETURN INTO GS_RETURN WITH KEY TYPE   = GC_S
                                               ID     = 'BAPI'
                                               NUMBER = '000'.

  IF SY-SUBRC EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    READ TABLE GT_RETURN INTO GS_RETURN WITH KEY TYPE = GC_S.

    P_LINE-ID        = ICON_LED_GREEN.
    P_LINE-ROUT_STAT = GC_S.
    P_LINE-ROUT_MSG  = TEXT-M02. "라우팅의 생성/변경을 성공적으로 수행하였습니다.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    READ TABLE GT_RETURN INTO GS_RETURN WITH KEY TYPE = GC_E.

    P_LINE-ID        = ICON_LED_RED.
    P_LINE-ROUT_STAT = GC_E.
    P_LINE-ROUT_MSG  = TEXT-M06. "라우팅 생성 도중 오류가 발생하였습니다. "GS_RETURN-MESSAGE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_task_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM SET_TASK_HEADER  USING    P_LINE LIKE GS_DATA.

  GS_TASK-GROUP_COUNTER    = '6'.
  GS_TASK-VALID_FROM       = '20240101'.
  GS_TASK-TASK_LIST_USAGE  = '1'.
  GS_TASK-PLANT            = P_LINE-WERKS.
  GS_TASK-TASK_LIST_STATUS = '4'.
  GS_TASK-DESCRIPTION      = P_LINE-MAKTX. "ROUT_MAKTX.

  SELECT SINGLE MEINS
    INTO GS_TASK-TASK_MEASURE_UNIT
    FROM MARA
   WHERE MATNR EQ P_LINE-MATNR. "ROUT_MATNR.

  APPEND GS_TASK TO GT_TASK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_mat_task_alc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM SET_MAT_TASK_ALC  USING    P_LINE LIKE GS_DATA.

  GS_MAT_TASK_ALC-MATERIAL   = P_LINE-MATNR. "ROUT_MATNR.
  GS_MAT_TASK_ALC-PLANT      = P_LINE-WERKS.
  GS_MAT_TASK_ALC-VALID_FROM = '20240101'.

  APPEND GS_MAT_TASK_ALC TO GT_MAT_TASK_ALC.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OPERATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM SET_OPERATION  USING    P_LINE LIKE GS_DATA.

*  GS_OPERATION-TASK_LIST_GROUP        = G_PLNNR.
  GS_OPERATION-VALID_FROM             = '20240101'.
  GS_OPERATION-ACTIVITY               = P_LINE-VORNR.
  GS_OPERATION-WORK_CNTR              = P_LINE-ARBPL.
  GS_OPERATION-PLANT                  = P_LINE-WERKS.

  SELECT SINGLE KTEXT
    INTO GS_OPERATION-DESCRIPTION
    FROM      CRHD AS A
   INNER JOIN CRTX AS B ON B~OBJTY EQ A~OBJTY
                       AND B~OBJID EQ A~OBJID
                       AND B~SPRAS EQ SY-LANGU
   WHERE A~ARBPL EQ GS_OPERATION-WORK_CNTR. "P_LINE-ARBPL.

  GS_OPERATION-OPERATION_MEASURE_UNIT = GS_TASK-TASK_MEASURE_UNIT.

*  GS_OPERATION-CONTROL_KEY            = PS_ITAB-STEUS.

  GS_OPERATION-DENOMINATOR            = GC_UMREN.
  GS_OPERATION-NOMINATOR              = GC_UMREN.
  GS_OPERATION-BASE_QUANTITY          = '1'.

  GS_OPERATION-COST_RELEVANT          = 'X'.

*-완제품코드+플랜트 기준의 ACT SUM
  READ TABLE GT_ACT_SUM INTO DATA(LS_ACT_SUM) WITH KEY MATNR = P_LINE-MATNR
                                                       WERKS = P_LINE-WERKS.

*-UNIT
  GS_OPERATION-STD_VALUE_01 = LS_ACT_SUM-ZTIME. "P_LINE-ZTIME.
  TRANSLATE P_LINE-ZUNIT TO UPPER CASE.
  M_CUNIT : 'I' P_LINE-ZUNIT GS_OPERATION-STD_UNIT_01.
  GS_OPERATION-ACTTYPE_01 = 'AT101'.

  GS_OPERATION-STD_VALUE_02 = LS_ACT_SUM-ZTIME. "P_LINE-ZTIME.
  TRANSLATE P_LINE-ZUNIT TO UPPER CASE.
  M_CUNIT : 'I' P_LINE-ZUNIT GS_OPERATION-STD_UNIT_02.
  GS_OPERATION-ACTTYPE_02 = 'AT102'.

  GS_OPERATION-STD_VALUE_03 = LS_ACT_SUM-ZTIME. "P_LINE-ZTIME.
  TRANSLATE P_LINE-ZUNIT TO UPPER CASE.
  M_CUNIT : 'I' P_LINE-ZUNIT GS_OPERATION-STD_UNIT_03.
  GS_OPERATION-ACTTYPE_03 = 'AT103'.

  GS_OPERATION-STD_VALUE_04 = LS_ACT_SUM-ZTIME. "P_LINE-ZTIME.
  TRANSLATE P_LINE-ZUNIT TO UPPER CASE.
  M_CUNIT : 'I' P_LINE-ZUNIT GS_OPERATION-STD_UNIT_04.
  GS_OPERATION-ACTTYPE_04 = 'AT104'.

  GS_OPERATION-STD_VALUE_05 = LS_ACT_SUM-ZTIME. "P_LINE-ZTIME.
  TRANSLATE P_LINE-ZUNIT TO UPPER CASE.
  M_CUNIT : 'I' P_LINE-ZUNIT GS_OPERATION-STD_UNIT_05.
  GS_OPERATION-ACTTYPE_05 = 'AT105'.

  GS_OPERATION-STD_VALUE_06 = LS_ACT_SUM-ZTIME. "P_LINE-ZTIME.
  TRANSLATE P_LINE-ZUNIT TO UPPER CASE.
  M_CUNIT : 'I' P_LINE-ZUNIT GS_OPERATION-STD_UNIT_06.
  GS_OPERATION-ACTTYPE_06 = 'AT106'.

  APPEND GS_OPERATION TO GT_OPERATION.

  CLEAR: LS_ACT_SUM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_ROUTING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM CHANGE_ROUTING  USING    P_LINE LIKE GS_DATA.

  DATA: LV_UNIT LIKE PLPOD-VGE01,
        LV_TIME TYPE CHAR13.

  CLEAR: BDCDATA, BDCDATA[], MESSTAB, MESSTAB[],
         GV_INDEX, GV_TEXT.

  PERFORM DYNPRO1 USING:
        'X' 'SAPLCPDI'    '1010',
        ' ' 'BDC_OKCODE'  '=XALU',
        ' ' 'RC27M-MATNR' P_LINE-MATNR, "ROUT_MATNR,
        ' ' 'RC27M-WERKS' P_LINE-WERKS,
        ' ' 'RC271-STTAG' '20240101',   "SY-DATUM.
        ' ' 'RC271-PLNAL' '6'.

  CLEAR: LV_UNIT.
  TRANSLATE P_LINE-ZUNIT TO UPPER CASE.
  M_CUNIT : 'I' P_LINE-ZUNIT LV_UNIT.

  READ TABLE GT_ACT_SUM INTO DATA(LS_ACT_SUM) WITH KEY MATNR = P_LINE-MATNR
                                                       WERKS = P_LINE-WERKS.

  CLEAR: LV_TIME.
  LV_TIME = LS_ACT_SUM-ZTIME. "P_LINE-ZTIME.
  CONDENSE LV_TIME.

  PERFORM DYNPRO1 USING:
        'X' 'SAPLCPDI'        '1400',
        ' ' 'BDC_OKCODE'      '=BU',
        ' ' 'RC27X-ENTRY_ACT' '1',
        ' ' 'PLPOD-VGW01(01)' LV_TIME,
        ' ' 'PLPOD-VGE01(01)' LV_UNIT,
        ' ' 'PLPOD-VGW02(01)' LV_TIME,
        ' ' 'PLPOD-VGE02(01)' LV_UNIT,
        ' ' 'PLPOD-VGW03(01)' LV_TIME,
        ' ' 'PLPOD-VGE03(01)' LV_UNIT,
        ' ' 'PLPOD-VGW04(01)' LV_TIME,
        ' ' 'PLPOD-VGE04(01)' LV_UNIT,
        ' ' 'PLPOD-VGW05(01)' LV_TIME,
        ' ' 'PLPOD-VGE05(01)' LV_UNIT,
        ' ' 'PLPOD-VGW06(01)' LV_TIME,
        ' ' 'PLPOD-VGE06(01)' LV_UNIT.

  GS_PARAMS-DISMODE  = 'N'.   " 처리모드
  GS_PARAMS-UPDMODE  = 'S'.   " 갱신세션
  GS_PARAMS-CATTMODE = 'A'.   " CATT모드
  GS_PARAMS-DEFSIZE  = ' '.   " 기본화면
  GS_PARAMS-RACOMMIT = 'X'.   " COMMIT 이후 지속
  GS_PARAMS-NOBINPT  = 'X'.   " BI 세션

  CALL TRANSACTION 'CA02'
             USING BDCDATA
           OPTIONS FROM GS_PARAMS
          MESSAGES INTO MESSTAB.

  CLEAR: GV_INDEX.
  GV_INDEX = LINES( MESSTAB ).
  CLEAR: MESSTAB.

  READ TABLE MESSTAB INDEX GV_INDEX.

  IF GV_INDEX EQ 0.
    P_LINE-ID        = ICON_LED_GREEN.
    P_LINE-ROUT_STAT = GC_S.
    P_LINE-ROUT_MSG  = TEXT-M03. "변경된 내용이 없습니다.

  ELSE.
    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        MSGID               = MESSTAB-MSGID
        MSGNR               = MESSTAB-MSGNR
        MSGV1               = MESSTAB-MSGV1
        MSGV2               = MESSTAB-MSGV2
        MSGV3               = MESSTAB-MSGV3
        MSGV4               = MESSTAB-MSGV4
      IMPORTING
        MESSAGE_TEXT_OUTPUT = GV_TEXT.

    IF MESSTAB-MSGTYP = 'S' AND MESSTAB-MSGID = 'CV' AND
       MESSTAB-MSGNR  = '761' AND MESSTAB-MSGV1 IS NOT INITIAL.
      P_LINE-ID        = ICON_LED_GREEN.
      P_LINE-ROUT_STAT = GC_S.
      P_LINE-ROUT_MSG  = TEXT-M02. "라우팅의 생성/변경을 성공적으로 수행하였습니다.
* 라우팅 생성/변경 Std. 메세지
*  공정을 그룹 &1 및 자재 &2과(와) 함께 저장했습니다
    ELSE.
      P_LINE-ID        = ICON_LED_RED.
      P_LINE-ROUT_STAT = GC_E.
      P_LINE-ROUT_MSG  = GV_TEXT.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form dynpro1
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
*& Form BATCH_EXEC_ROUTING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BATCH_EXEC_ROUTING .

  DATA: LT_DATASEL LIKE TABLE OF GS_DATA.

  CLEAR: LT_DATASEL.
  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>).
    IF <FS_S>-ID EQ ICON_LED_GREEN.
      <FS_S>-ROUT_STAT = GC_S.
      <FS_S>-ROUT_MSG  = TEXT-M01. "이미 처리된 레코드입니다.
    ELSE.
      IF <FS_S>-MATNR IS INITIAL. "ROUT_MATNR IS INITIAL.
        <FS_S>-ROUT_STAT = GC_E.
        <FS_S>-ROUT_MSG = TEXT-M04. "품목이 없습니다.
      ELSE.
*-선택한 데이터
        APPEND <FS_S> TO LT_DATASEL.
      ENDIF.
    ENDIF.
  ENDLOOP.

*-선택된 데이터를 완제품코드+플랜트 기준으로 중복 제거
  SORT LT_DATASEL BY MATNR WERKS.
  DELETE ADJACENT DUPLICATES FROM LT_DATASEL
                        COMPARING MATNR WERKS.

  SORT LT_DATASEL BY MATNR WERKS.

*-선택된 데이터를 완제품코드+플랜트 기준으로 라우팅 생성/변경
  LOOP AT LT_DATASEL ASSIGNING FIELD-SYMBOL(<FS_SEL>).
    " 표준 Routing 생성/변경
    PERFORM EXEC_ROUTING USING <FS_SEL>.
  ENDLOOP.

*-처리 결과 ALV 적용
  LOOP AT GT_DATA ASSIGNING <FS_S> WHERE ID NE ICON_LED_GREEN.
    READ TABLE LT_DATASEL INTO DATA(LS_DATASEL) WITH KEY MATNR = <FS_S>-MATNR
                                                         WERKS = <FS_S>-WERKS.
    IF SY-SUBRC EQ 0.
      <FS_S>-ID        = LS_DATASEL-ID.
      <FS_S>-ROUT_STAT = LS_DATASEL-ROUT_STAT.
      <FS_S>-ROUT_MSG  = LS_DATASEL-ROUT_MSG.

      UPDATE ZGTPPT1060 SET ROUT_STAT  = <FS_S>-ROUT_STAT
                            ROUT_MSG   = <FS_S>-ROUT_MSG
                      WHERE WERKS      = <FS_S>-WERKS
                        AND MATNR      = <FS_S>-MATNR.
      COMMIT WORK.
    ENDIF.
  ENDLOOP.

*- 전체 건수
  DATA(LV_CNT_T) = REDUCE I(
                   INIT SUM = 0 FOR LS_CNT_T IN GT_DATA
                   NEXT SUM = SUM + 1 ).

*- 성공 건수
  DATA(LV_CNT_S) = REDUCE I(
                   INIT SUM = 0 FOR LS_CNT_S IN GT_DATA
                   WHERE ( ROUT_STAT = 'S' )
                   NEXT SUM = SUM + 1 ).

*- 실패 건수
  DATA(LV_CNT_E) = REDUCE I(
                   INIT SUM = 0 FOR LS_CNT_E IN GT_DATA
                   WHERE ( ROUT_STAT = 'E' )
                   NEXT SUM = SUM + 1 ).

  "전체 &1건 중 &2건 처리 성공, &3건 처리 실패
  MESSAGE S009(ZGTPP00) WITH LV_CNT_T LV_CNT_S LV_CNT_E.

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
  ID 'WERKS'  FIELD S_WERKS-LOW.

  IF SY-SUBRC <> 0.
    "플랜트[S_WERKS-LOW] 작업권한을 확인하세요.
    MESSAGE E006 WITH TEXT-M07 S_WERKS-LOW TEXT-M08.
  ENDIF.
ENDFORM.
