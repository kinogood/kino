*&---------------------------------------------------------------------*
*& Include          ZGTPPR1130F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PROC .

  CLEAR: GT_1010.
  SELECT *
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ @GC_PP
     AND CODEGRP EQ @GC_0010
    INTO CORRESPONDING FIELDS OF TABLE @GT_1010.

  CLEAR: GT_DATA.
  SELECT *
    FROM ZGTPPT1090
   WHERE WERKS IN @S_WERKS
     AND SPGCD IN @S_SPGCD
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>).
    PERFORM SET_STY_RTN USING SPACE
                        CHANGING <FS_S>.
  ENDLOOP.

  SORT: GT_1010 BY FLD_03 FLD_04,
        GT_DATA BY PI.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STY_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_S>
*&---------------------------------------------------------------------*
FORM SET_STY_RTN USING P_STATUS
                 CHANGING P_LINE LIKE GS_DATA.
  DATA: LS_STY TYPE LVC_S_STYL.

  DEFINE SET_STY.
    IF &2 EQ 'X'.
      LS_STY-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    ELSE.
      LS_STY-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
    ENDIF.

    LS_STY-FIELDNAME = &1.
    INSERT LS_STY INTO TABLE P_LINE-CELL_STY.
    CLEAR LS_STY.
  END-OF-DEFINITION.

  CLEAR : P_LINE-CELL_STY.

  IF P_STATUS EQ GC_C.
    SET_STY 'WERKS'   SPACE.
    SET_STY 'SPGCD'   SPACE.
    SET_STY 'BOBINID' SPACE.
    SET_STY 'ZGTDRNO' SPACE.
    SET_STY 'PI'      SPACE.
    SET_STY 'BAREDIA' SPACE.
    SET_STY 'SUSYN'   SPACE.
    SET_STY 'REMARK'  SPACE.
    SET_STY 'ADD3'    SPACE.
    SET_STY 'ADD4'    SPACE.
    SET_STY 'ADD5'    SPACE.

  ELSE.
    SET_STY 'WERKS'   'X'.
    SET_STY 'SPGCD'   'X'.
    SET_STY 'BOBINID' 'X'.
    SET_STY 'ZGTDRNO' SPACE.
    SET_STY 'PI'      SPACE.
    SET_STY 'BAREDIA' SPACE.
    SET_STY 'SUSYN'   SPACE.
    SET_STY 'REMARK'  SPACE.
    SET_STY 'ADD3'    SPACE.
    SET_STY 'ADD4'    SPACE.
    SET_STY 'ADD5'    SPACE.

  ENDIF.

  SET_STY 'ADD6'  'X'.
  SET_STY 'ADD7'  'X'.
  SET_STY 'ADD8'  'X'.
  SET_STY 'ADD9'  'X'.
  SET_STY 'ADD10' 'X'.
  SET_STY 'CRDAT' 'X'.
  SET_STY 'CRTIM' 'X'.
  SET_STY 'CRNAM' 'X'.
  SET_STY 'CHDAT' 'X'.
  SET_STY 'CHTIM' 'X'.
  SET_STY 'CHNAM' 'X'.
  SET_STY 'RTMSG' 'X'.

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
         GT_EXCLUDE_0100,
         GV_OK_CODE, GV_DBCNT,
         GT_DATA[], GT_1010[].

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
*  GS_LAYOUT_0100-ZEBRA      = GC_X.
  GS_LAYOUT_0100-COL_OPT    = GC_X.
*  GS_LAYOUT_0100-CWIDTH_OPT = GC_X.
*  GS_LAYOUT_0100-NO_ROWINS  = GC_X.
  GS_LAYOUT_0100-SEL_MODE   = GC_D.
*  GS_LAYOUT_0100-EDIT       = GC_X.
  GS_LAYOUT_0100-STYLEFNAME = 'CELL_STY'.
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
      I_INCLNAME             = 'ZGTPPR1130TOP'
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
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "플랜트
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EDIT = GC_X.
      WHEN 'SPGCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "SPG코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EDIT = GC_X.
      WHEN 'BOBINID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "보빈ID
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '15'.
        <LS_FCAT>-EDIT = GC_X.
      WHEN 'ZGTDRNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "보빈드럼No
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '15'.
        <LS_FCAT>-EDIT = GC_X.
      WHEN 'PI'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "보빈규격(파이)
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EDIT = GC_X.
      WHEN 'BAREDIA'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "동경치수(MM)
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EDIT = GC_X.
      WHEN 'SUSYN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "서스판여부
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-CHECKBOX = GC_X.
        <LS_FCAT>-EDIT = GC_X.
      WHEN 'REMARK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "특이사항
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '20'.
        <LS_FCAT>-EDIT = GC_X.
      WHEN 'ADD3'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "계산상수1
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EDIT = GC_X.
      WHEN 'ADD4'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "계산상수2
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EDIT = GC_X.
      WHEN 'ADD5'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "계산상수3
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-EDIT = GC_X.
      WHEN 'RTMSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "메시지
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-OUTPUTLEN = '20'.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
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
*& Form SET_EVENT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM SET_EVENT_GRID_0100  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.
  IF GO_EVTR_0100 IS NOT BOUND.
    CREATE OBJECT GO_EVTR_0100.
  ENDIF.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      SET HANDLER: GO_EVTR_0100->HDL_DATA_CHANGED FOR GO_GRID_0100.
  ENDCASE.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

* DATA CHANGE
  CALL METHOD PO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

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
      I_BYPASSING_BUFFER   = 'X'
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
    CHANGING
      IT_OUTTAB            = GT_DATA
      IT_SORT              = GT_SORT_0100
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ADDLINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_ADDLINE .

  CLEAR: GS_DATA.

  PERFORM SET_STY_RTN USING GC_C
                      CHANGING GS_DATA.
  APPEND GS_DATA TO GT_DATA.

  " REFRESH DISPLAY
  PERFORM REF_ALV_RTN USING GO_GRID_0100.

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
*& Form PROCESS_DELLINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_DELLINE .

  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LS_ZGTPPT1090 LIKE ZGTPPT1090.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M01. "삭제할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T02 "삭제
      TEXT_QUESTION         = TEXT-T03 "삭제를 진행하시겠습니까?(DB에서도 삭제됩니다.)
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    SORT LT_ROW_NO BY ROW_ID DESCENDING.

    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      CLEAR: LS_ZGTPPT1090.
      SELECT SINGLE *
        FROM ZGTPPT1090
       WHERE WERKS EQ @<FS_S>-WERKS
         AND SPGCD EQ @<FS_S>-SPGCD
         AND BOBINID EQ @<FS_S>-BOBINID
        INTO @LS_ZGTPPT1090.

      IF SY-SUBRC EQ 0.
        "ZGTPPT1090에서 삭제
        DELETE ZGTPPT1090 FROM LS_ZGTPPT1090.

        IF SY-SUBRC EQ 0.
          COMMIT WORK.
          "ALV에서 삭제
          DELETE GT_DATA INDEX LT_ROW_NO-ROW_ID.
          MESSAGE S003 WITH TEXT-M05. "삭제되었습니다.
        ELSE.
          ROLLBACK WORK.
          MESSAGE S003 WITH TEXT-M06. "삭제 중 오류가 발생하였습니다.
        ENDIF.

      ELSE.
        "ALV에서 삭제
        DELETE GT_DATA INDEX LT_ROW_NO-ROW_ID.
        MESSAGE S003 WITH TEXT-M05. "삭제되었습니다.
      ENDIF.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ENDIF.

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
*& Form PROCESS_ZSAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_ZSAVE .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  DATA: LT_DATA LIKE TABLE OF GS_DATA.

  DATA: LS_ZGTPPT1090  LIKE ZGTPPT1090,
        LS_ZGTPPT1090I LIKE ZGTPPT1090.

  DATA: LV_CX_REF TYPE REF TO CX_ROOT.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M02. "저장할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T04 "저장
      TEXT_QUESTION         = TEXT-T05 "데이터 저장을 진행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-WERKS IS INITIAL OR <FS_S>-SPGCD IS INITIAL OR
         <FS_S>-BOBINID IS INITIAL OR <FS_S>-ZGTDRNO IS INITIAL OR
         <FS_S>-PI IS INITIAL." OR <FS_S>-BAREDIA IS INITIAL.
        <FS_S>-RTMSG = TEXT-M07. "빈값이 있습니다.

      ELSE.
        CLEAR: LT_DATA.
        APPEND LINES OF GT_DATA TO LT_DATA.
        SORT LT_DATA BY WERKS SPGCD BOBINID.
        DELETE ADJACENT DUPLICATES FROM LT_DATA COMPARING WERKS SPGCD BOBINID.

        IF SY-SUBRC EQ 0.
          MESSAGE S000 DISPLAY LIKE 'E' WITH '중복된 데이터가 있습니다.'.
          EXIT.

        ELSE.
          READ TABLE GT_1010 INTO DATA(LS_1010) WITH KEY FLD_03 = <FS_S>-WERKS
                                                         FLD_04 = <FS_S>-SPGCD.
          IF SY-SUBRC NE 0.
            <FS_S>-RTMSG = TEXT-M08. "대상 플랜트가 아닙니다.

          ELSE.
            CLEAR: LS_ZGTPPT1090.
            SELECT SINGLE *
              FROM ZGTPPT1090
             WHERE WERKS EQ @<FS_S>-WERKS
               AND SPGCD EQ @<FS_S>-SPGCD
               AND BOBINID EQ @<FS_S>-BOBINID
              INTO @LS_ZGTPPT1090.

            IF SY-SUBRC EQ 0.
              "ZGTPPT1090에 UPDATE
              UPDATE ZGTPPT1090 SET ZGTDRNO = <FS_S>-ZGTDRNO
                                    PI      = <FS_S>-PI
                                    BAREDIA = <FS_S>-BAREDIA
                                    SUSYN   = <FS_S>-SUSYN
                                    REMARK  = <FS_S>-REMARK
                                    ADD3    = <FS_S>-ADD3
                                    ADD4    = <FS_S>-ADD4
                                    ADD5    = <FS_S>-ADD5
                                    CHDAT   = SY-DATUM
                                    CHTIM   = SY-UZEIT
                                    CHNAM   = SY-UNAME
                              WHERE WERKS EQ <FS_S>-WERKS
                                AND SPGCD EQ <FS_S>-SPGCD
                                AND BOBINID EQ <FS_S>-BOBINID.

              IF SY-SUBRC EQ 0.
                COMMIT WORK.
                <FS_S>-RTMSG = TEXT-M03. "저장되었습니다.
              ELSE.
                ROLLBACK WORK.
                <FS_S>-RTMSG = TEXT-M04. "저장 중 오류가 발생하였습니다.
              ENDIF.

            ELSE.
              "ZGTPPT1090에 INSERT
              CLEAR: LS_ZGTPPT1090I.
              MOVE-CORRESPONDING <FS_S> TO LS_ZGTPPT1090I.
              MOVE: SY-DATUM TO LS_ZGTPPT1090I-CRDAT,
                    SY-UZEIT TO LS_ZGTPPT1090I-CRTIM,
                    SY-UNAME TO LS_ZGTPPT1090I-CRNAM.

              MODIFY ZGTPPT1090 FROM LS_ZGTPPT1090I.

              IF SY-SUBRC EQ 0.
                COMMIT WORK.
                <FS_S>-RTMSG = TEXT-M03. "저장되었습니다.
              ELSE.
                ROLLBACK WORK.
                <FS_S>-RTMSG = TEXT-M04. "저장 중 오류가 발생하였습니다.
              ENDIF.

            ENDIF.

            PERFORM SET_STY_RTN USING SPACE
                             CHANGING <FS_S>.

          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SPGCD_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LVC_S_MODI
*&      <-- ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM SET_SPGCD_RTN  USING    P_LVC_S_MODI   TYPE LVC_S_MODI
                    CHANGING P_DATA_CHANGED
                             TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: L_VALUE TYPE LVC_S_MODI-VALUE.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

*  READ TABLE GT_DATA ASSIGNING <FS_S> INDEX P_LVC_S_MODI-ROW_ID.

  L_VALUE = P_LVC_S_MODI-VALUE.

  TRANSLATE L_VALUE TO UPPER CASE.

  READ TABLE GT_1010 INTO DATA(LS_1010) WITH KEY FLD_03 = L_VALUE.

  IF LS_1010-FLD_04 IS INITIAL.
    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'WERKS'
        I_VALUE     = <FS_S>-WERKS.

    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'SPGCD'
        I_VALUE     = <FS_S>-SPGCD.

  ELSE.
    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'SPGCD'
        I_VALUE     = LS_1010-FLD_04.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SPGCD_CHK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LVC_S_MODI
*&      <-- ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM SET_SPGCD_CHK  USING    P_LVC_S_MODI   TYPE LVC_S_MODI
                    CHANGING P_DATA_CHANGED
                             TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: L_VALUE TYPE LVC_S_MODI-VALUE.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  READ TABLE GT_DATA ASSIGNING <FS_S> INDEX P_LVC_S_MODI-ROW_ID.

  L_VALUE = P_LVC_S_MODI-VALUE.

  TRANSLATE L_VALUE TO UPPER CASE.

  LOOP AT P_DATA_CHANGED->MT_GOOD_CELLS INTO DATA(LS_GOOD_CELLS) WHERE ROW_ID = P_LVC_S_MODI-ROW_ID.
    IF LS_GOOD_CELLS-FIELDNAME = 'WERKS' AND LS_GOOD_CELLS-VALUE IS NOT INITIAL.
      READ TABLE GT_1010 INTO DATA(LS_1010) WITH KEY FLD_03 = LS_GOOD_CELLS-VALUE
                                                     FLD_04 = L_VALUE.

      IF SY-SUBRC NE 0.
        CALL METHOD P_DATA_CHANGED->MODIFY_CELL
          EXPORTING
            I_ROW_ID    = P_LVC_S_MODI-ROW_ID
            I_TABIX     = P_LVC_S_MODI-TABIX
            I_FIELDNAME = 'RTMSG'
            I_VALUE     = '대상 플랜트가 아닙니다.'.
      ELSE.
        CALL METHOD P_DATA_CHANGED->MODIFY_CELL
          EXPORTING
            I_ROW_ID    = P_LVC_S_MODI-ROW_ID
            I_TABIX     = P_LVC_S_MODI-TABIX
            I_FIELDNAME = 'RTMSG'
            I_VALUE     = SPACE.
      ENDIF.
    ENDIF.

  ENDLOOP.

*  IF <FS_S>-WERKS IS NOT INITIAL.
*    READ TABLE GT_1010 INTO DATA(LS_1010) WITH KEY FLD_03 = <FS_S>-WERKS
*                                                   FLD_04 = L_VALUE.
*
*    IF SY-SUBRC NE 0.
*      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
*        EXPORTING
*          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
*          I_TABIX     = P_LVC_S_MODI-TABIX
*          I_FIELDNAME = 'RTMSG'
*          I_VALUE     = '대상 플랜트가 아닙니다.'.
*    ELSE.
*      CALL METHOD P_DATA_CHANGED->MODIFY_CELL
*        EXPORTING
*          I_ROW_ID    = P_LVC_S_MODI-ROW_ID
*          I_TABIX     = P_LVC_S_MODI-TABIX
*          I_FIELDNAME = 'RTMSG'
*          I_VALUE     = SPACE.
*    ENDIF.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0100 .
  REFRESH GT_SORT_0100.

*  PERFORM SET_SORT_TAB TABLES GT_SORT_0100
*                        USING : 1 'PI'      'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_TAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SORT_0100
*&      --> P_1
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SORT_TAB  TABLES   PT_SORTTAB STRUCTURE LVC_S_SORT
                   USING    PV_POS
                            PV_FIELDNAME
                            PV_UP
                            PV_DOWN
                            PV_SUBTOT.

  DATA : LS_SORT TYPE LVC_S_SORT.
  LS_SORT-SPOS = PV_POS.
  LS_SORT-FIELDNAME = PV_FIELDNAME.
  LS_SORT-UP = PV_UP.
  LS_SORT-DOWN = PV_DOWN.
  LS_SORT-SUBTOT =  PV_SUBTOT.
  APPEND LS_SORT TO PT_SORTTAB.

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
*& SPG에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_SPGCD'
  ID 'WERKS'  FIELD S_WERKS-LOW
  ID 'SPGCD'  FIELD S_SPGCD-LOW.

  IF SY-SUBRC <> 0.
    "SPG[S_SPGCD-LOW] 작업권한을 확인하세요.
    MESSAGE E006 WITH TEXT-M09 S_SPGCD-LOW TEXT-M10.
  ENDIF.

ENDFORM.
