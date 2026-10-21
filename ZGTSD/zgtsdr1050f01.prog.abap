*&---------------------------------------------------------------------*
*& Include          ZGTSDR1050F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

  DATA: LV_OBJECT   LIKE AUSP-OBJEK,
        LT_SCLASS   TYPE TABLE OF SCLASS,
        LT_CLOBJDAT TYPE TABLE OF CLOBJDAT.

  CLEAR: GT_DATA.
  SELECT A~*,
         B~MAKTX,
         C~NAME1
    FROM ZGTSDT1050 AS A
    LEFT JOIN MAKT  AS B ON B~MATNR EQ A~MATNR
                        AND B~SPRAS EQ @SY-LANGU
    LEFT JOIN LFA1  AS C ON C~LIFNR EQ A~KUNNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_S>).
    <FS_S>-ID = ICON_LED_INACTIVE.

    CLEAR: LV_OBJECT.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT        = <FS_S>-MATNR
      IMPORTING
        OUTPUT       = LV_OBJECT
      EXCEPTIONS
        LENGTH_ERROR = 1
        OTHERS       = 2.

    CLEAR: LT_SCLASS, LT_CLOBJDAT.
    CALL FUNCTION 'CLAF_CLASSIFICATION_OF_OBJECTS'
      EXPORTING
        CLASSTEXT          = 'X'
        CLASSTYPE          = '001'
        FEATURES           = 'X'
        LANGUAGE           = SY-LANGU
        OBJECT             = LV_OBJECT
        KEY_DATE           = SY-DATUM
        INITIAL_CHARACT    = SPACE
        NO_VALUE_DESCRIPT  = 'X'
        CHANGE_SERVICE_CLF = 'X'
      TABLES
        T_CLASS            = LT_SCLASS
        T_OBJECTDATA       = LT_CLOBJDAT
      EXCEPTIONS
        NO_CLASSIFICATION  = 1
        NO_CLASSTYPES      = 2
        INVALID_CLASS_TYPE = 3.

    "가온제품 제품그룹/제품그룹명
    DATA(LV_ZSPART) = VALUE #( LT_CLOBJDAT[ ATNAM = 'MS-AUSP-ZSPART' ]-AUSP1 OPTIONAL ).
    IF LV_ZSPART IS NOT INITIAL.
      SELECT SINGLE CLRTX
        FROM ZGTEDT6800
       WHERE SPART_GAON EQ @LV_ZSPART
        INTO @<FS_S>-CLRTX.

      IF SY-SUBRC EQ 0.
        <FS_S>-SPART_GAON = LV_ZSPART.
      ENDIF.
    ENDIF.

    PERFORM SET_STY_RTN USING SPACE
                        CHANGING <FS_S>.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STY_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SPACE
*&      <-- <FS_S>
*&---------------------------------------------------------------------*
FORM SET_STY_RTN  USING P_STATUS
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
    SET_STY 'MATNR'      SPACE.
    SET_STY 'MAKTX'      'X'.
    SET_STY 'DANGA'      SPACE.
    SET_STY 'KUNNR'      SPACE.
    SET_STY 'NAME1'      'X'.
    SET_STY 'MEINS'      'X'.
    SET_STY 'SPART_GAON' 'X'.
    SET_STY 'CLRTX'      'X'.

  ELSE.
    SET_STY 'MATNR'      'X'.
    SET_STY 'MAKTX'      'X'.
    SET_STY 'DANGA'      SPACE.
    SET_STY 'KUNNR'      SPACE.
    SET_STY 'NAME1'      'X'.
    SET_STY 'MEINS'      'X'.
    SET_STY 'SPART_GAON' 'X'.
    SET_STY 'CLRTX'      'X'.

  ENDIF.

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
      I_INCLNAME             = 'ZGTSDR1050TOP'
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
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "자재코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EDIT = GC_X.
        <LS_FCAT>-OUTPUTLEN = '20'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "자재내역
        <LS_FCAT>-OUTPUTLEN = '20'.
        <LS_FCAT>-JUST = GC_L.
      WHEN 'DANGA'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "금액
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EDIT = GC_X.
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
      WHEN 'KUNNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "판매처
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-EDIT = GC_X.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "판매처명
        <LS_FCAT>-OUTPUTLEN = '20'.
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "단위
        <LS_FCAT>-OUTPUTLEN = '5'.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'SPART_GAON'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "가온제품제품그룹
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'CLRTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "제품그룹명
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-JUST = GC_L.
      WHEN 'RTMSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "메시지
        <LS_FCAT>-OUTPUTLEN = '20'.
        <LS_FCAT>-JUST = GC_L.
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
*& Form PROCESS_ADDLINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_ADDLINE .
  CLEAR: GS_DATA.

  GS_DATA-ID = ICON_LED_INACTIVE.
  GS_DATA-WAERS = 'KRW'.

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

  DATA: LT_DATA LIKE TABLE OF GS_DATA.

  DATA: LS_ZGTSDT1050 LIKE ZGTSDT1050.

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
      TITLEBAR              = TEXT-T01 "삭제
      TEXT_QUESTION         = TEXT-T02 "삭제를 진행하시겠습니까?(DB에서도 삭제됩니다.)
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.

    SORT LT_ROW_NO BY ROW_ID DESCENDING.

    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      CLEAR: LS_ZGTSDT1050.
      SELECT SINGLE *
        FROM ZGTSDT1050
       WHERE MATNR EQ @<FS_S>-MATNR
        INTO @LS_ZGTSDT1050.

      IF SY-SUBRC EQ 0.
        "ZGTSDT1050에서 삭제
        DELETE ZGTSDT1050 FROM LS_ZGTSDT1050.

        IF SY-SUBRC EQ 0.
          COMMIT WORK.
          "ALV에서 삭제
          DELETE GT_DATA INDEX LT_ROW_NO-ROW_ID.
          MESSAGE S003 WITH TEXT-M02. "삭제되었습니다.
        ELSE.
          ROLLBACK WORK.
          MESSAGE S003 WITH TEXT-M03. "삭제 중 오류가 발생하였습니다.
        ENDIF.

      ELSE.
        "ALV에서 삭제
        DELETE GT_DATA INDEX LT_ROW_NO-ROW_ID.
        MESSAGE S003 WITH TEXT-M02. "삭제되었습니다.
      ENDIF.

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

  DATA: LS_ZGTSDT1050 LIKE ZGTSDT1050.

  DATA: LV_CHK(1).

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M04. "저장할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T03 "저장
      TEXT_QUESTION         = TEXT-T04 "데이터 저장을 진행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    CLEAR: LV_CHK.

    LOOP AT LT_ROW_NO.
      READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      LOOP AT GT_DATA INTO DATA(LS_DATA) WHERE MATNR = <FS_S>-MATNR
           GROUP BY ( MATNR = LS_DATA-MATNR
                      SIZE = GROUP SIZE )
           ASCENDING REFERENCE INTO DATA(GROUP_REF).

        CHECK GROUP_REF->*-SIZE > 1.

        LV_CHK = 'X'.

        MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-E01. "중복된 데이터가 있습니다.
        EXIT.
      ENDLOOP.

      CHECK LV_CHK IS INITIAL.
      CHECK <FS_S>-ID NE ICON_LED_RED.

      CLEAR: LS_ZGTSDT1050.
      MOVE-CORRESPONDING <FS_S> TO LS_ZGTSDT1050.

      MODIFY ZGTSDT1050 FROM LS_ZGTSDT1050.

      IF SY-SUBRC EQ 0.
        COMMIT WORK.
        <FS_S>-ID = ICON_LED_GREEN.
        <FS_S>-RTMSG = TEXT-M05. "저장되었습니다.
      ELSE.
        ROLLBACK WORK.
        <FS_S>-ID = ICON_LED_RED.
        <FS_S>-RTMSG = TEXT-M06. "저장 중 오류가 발생하였습니다.
      ENDIF.

      PERFORM SET_STY_RTN USING SPACE
                       CHANGING <FS_S>.

    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MATNR_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LVC_S_MODI
*&      <-- ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM SET_MATNR_RTN  USING    P_LVC_S_MODI   TYPE LVC_S_MODI
                    CHANGING P_DATA_CHANGED
                             TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: LV_OBJECT   LIKE AUSP-OBJEK,
        LT_SCLASS   TYPE TABLE OF SCLASS,
        LT_CLOBJDAT TYPE TABLE OF CLOBJDAT.

  DATA: L_MATNR TYPE MATNR,
        L_MAKTX TYPE MAKTX,
        L_MEINS TYPE MEINS.

  DATA: L_VALUE TYPE LVC_S_MODI-VALUE.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  READ TABLE GT_DATA ASSIGNING <FS_S> INDEX P_LVC_S_MODI-ROW_ID.

  L_VALUE = P_LVC_S_MODI-VALUE.

  TRANSLATE L_VALUE TO UPPER CASE.

  CLEAR: L_MATNR.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT        = L_VALUE
    IMPORTING
      OUTPUT       = L_MATNR
    EXCEPTIONS
      LENGTH_ERROR = 1
      OTHERS       = 2.

  CLEAR: L_MEINS, L_MAKTX.
  SELECT SINGLE A~MEINS, B~MAKTX
    FROM MARA AS A
    LEFT JOIN MAKT AS B ON B~MATNR EQ A~MATNR
                       AND B~SPRAS EQ @SY-LANGU
   WHERE A~MATNR EQ @L_MATNR
    INTO (@L_MEINS, @L_MAKTX).

  IF L_MEINS NE 'EA'.
    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'ID'
        I_VALUE     = ICON_LED_RED.

    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'RTMSG'
        I_VALUE     = '단위가 EA가 아닙니다.'.

  ELSE.
    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'MEINS'
        I_VALUE     = L_MEINS.

    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'MAKTX'
        I_VALUE     = L_MAKTX.

    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'ID'
        I_VALUE     = ICON_LED_INACTIVE.

    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'RTMSG'
        I_VALUE     = SPACE.

    CLEAR: LV_OBJECT.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT        = L_MATNR
      IMPORTING
        OUTPUT       = LV_OBJECT
      EXCEPTIONS
        LENGTH_ERROR = 1
        OTHERS       = 2.

    CLEAR: LT_SCLASS, LT_CLOBJDAT.
    CALL FUNCTION 'CLAF_CLASSIFICATION_OF_OBJECTS'
      EXPORTING
        CLASSTEXT          = 'X'
        CLASSTYPE          = '001'
        FEATURES           = 'X'
        LANGUAGE           = SY-LANGU
        OBJECT             = LV_OBJECT
        KEY_DATE           = SY-DATUM
        INITIAL_CHARACT    = SPACE
        NO_VALUE_DESCRIPT  = 'X'
        CHANGE_SERVICE_CLF = 'X'
      TABLES
        T_CLASS            = LT_SCLASS
        T_OBJECTDATA       = LT_CLOBJDAT
      EXCEPTIONS
        NO_CLASSIFICATION  = 1
        NO_CLASSTYPES      = 2
        INVALID_CLASS_TYPE = 3.

    "가온제품 제품그룹/제품그룹명
    DATA(LV_ZSPART) = VALUE #( LT_CLOBJDAT[ ATNAM = 'MS-AUSP-ZSPART' ]-AUSP1 OPTIONAL ).

    IF LV_ZSPART IS NOT INITIAL.
      SELECT SINGLE CLRTX
        FROM ZGTEDT6800
       WHERE SPART_GAON EQ @LV_ZSPART
        INTO @DATA(LV_CLRTX).

      IF SY-SUBRC EQ 0.
        CALL METHOD P_DATA_CHANGED->MODIFY_CELL
          EXPORTING
            I_ROW_ID    = P_LVC_S_MODI-ROW_ID
            I_TABIX     = P_LVC_S_MODI-TABIX
            I_FIELDNAME = 'SPART_GAON'
            I_VALUE     = LV_ZSPART.

        CALL METHOD P_DATA_CHANGED->MODIFY_CELL
          EXPORTING
            I_ROW_ID    = P_LVC_S_MODI-ROW_ID
            I_TABIX     = P_LVC_S_MODI-TABIX
            I_FIELDNAME = 'CLRTX'
            I_VALUE     = LV_CLRTX.

      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_NAME1_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LVC_S_MODI
*&      <-- ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM SET_NAME1_RTN  USING    P_LVC_S_MODI   TYPE LVC_S_MODI
                    CHANGING P_DATA_CHANGED
                             TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: L_KUNNR TYPE KUNNR,
        L_NAME1 TYPE NAME1_GP.

  DATA: L_VALUE TYPE LVC_S_MODI-VALUE.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  READ TABLE GT_DATA ASSIGNING <FS_S> INDEX P_LVC_S_MODI-ROW_ID.

  L_VALUE = P_LVC_S_MODI-VALUE.

  TRANSLATE L_VALUE TO UPPER CASE.

  CLEAR: L_KUNNR.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = L_VALUE
    IMPORTING
      OUTPUT = L_KUNNR.

  CLEAR: L_NAME1.
  SELECT SINGLE NAME1
    FROM LFA1
   WHERE LIFNR EQ @L_KUNNR
    INTO @L_NAME1.

  IF L_NAME1 IS INITIAL.
    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'NAME1'
        I_VALUE     = SPACE.

    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'ID'
        I_VALUE     = ICON_LED_RED.

    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'RTMSG'
        I_VALUE     = '판매처명이 없습니다.'.
  ELSE.
    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'NAME1'
        I_VALUE     = L_NAME1.

    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'ID'
        I_VALUE     = ICON_LED_INACTIVE.

    CALL METHOD P_DATA_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = P_LVC_S_MODI-ROW_ID
        I_TABIX     = P_LVC_S_MODI-TABIX
        I_FIELDNAME = 'RTMSG'
        I_VALUE     = SPACE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DANGA_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LVC_S_MODI
*&      <-- ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM SET_DANGA_RTN  USING    P_LVC_S_MODI   TYPE LVC_S_MODI
                    CHANGING P_DATA_CHANGED
                             TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: L_VALUE TYPE LVC_S_MODI-VALUE.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  READ TABLE GT_DATA ASSIGNING <FS_S> INDEX P_LVC_S_MODI-ROW_ID.

  L_VALUE = P_LVC_S_MODI-VALUE.

  TRANSLATE L_VALUE TO UPPER CASE.

  L_VALUE = L_VALUE / 100.
  CONDENSE L_VALUE NO-GAPS.

  CALL METHOD P_DATA_CHANGED->MODIFY_CELL
    EXPORTING
      I_ROW_ID    = P_LVC_S_MODI-ROW_ID
      I_TABIX     = P_LVC_S_MODI-TABIX
      I_FIELDNAME = 'DANGA'
      I_VALUE     = L_VALUE.

  CALL METHOD P_DATA_CHANGED->MODIFY_CELL
    EXPORTING
      I_ROW_ID    = P_LVC_S_MODI-ROW_ID
      I_TABIX     = P_LVC_S_MODI-TABIX
      I_FIELDNAME = 'WAERS'
      I_VALUE     = 'KRW'.

ENDFORM.
