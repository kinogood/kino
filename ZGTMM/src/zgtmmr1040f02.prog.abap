*&---------------------------------------------------------------------*
*& Include          ZGTMMR1040F02
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form F_CREATE_ALV_OBJECT_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_ALV_OBJECT_100 .

  GO_CONT_100 = NEW #( CONTAINER_NAME = 'CON100' ).
  GO_GRID_100 = NEW #( I_PARENT = GO_CONT_100 ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_EXCL_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_EXCL_100 .

  CLEAR GT_EXCL_100[].

  GT_EXCL_100[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
*                       ( CL_GUI_ALV_GRID=>MC_MB_EXPORT )
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH )
                       ( CL_GUI_ALV_GRID=>MC_FC_INFO ) ).
ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_LAYO_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_LAYO_100 .

  CLEAR GS_LAYO_100.
  GS_LAYO_100-SEL_MODE = GC_A.
*  GS_LAYO_100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_100-ZEBRA = ABAP_TRUE.
  GS_LAYO_100-SMALLTITLE = ABAP_TRUE.
  GS_LAYO_100-STYLEFNAME = 'ZSTYLE'.
  GS_LAYO_100-NO_ROWMOVE = ABAP_TRUE.
  GS_LAYO_100-NO_ROWINS = ABAP_TRUE.

  "업체명(NAME1) &&"" ""&& 계약연도(P_YEAR) && ' 규격 단가'
*EX) 용남목재 2026 규격 단가"
  SELECT SINGLE
    NAME1
    FROM LFA1
    WHERE LIFNR EQ @P_LIFNR
    INTO @DATA(LV_NAME1).
  GS_LAYO_100-GRID_TITLE = |{ LV_NAME1 } { P_YEAR } { TEXT-AT1 }|.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_VARI_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_VARI_100 .

  CLEAR GS_VARI_100.

  GS_VARI_100-REPORT = SY-REPID.
  GS_VARI_100-USERNAME = SY-UNAME.
  GS_VARI_100-HANDLE = 'AL01'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CREATE_FCAT_BY_ITAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ITAB
*&      <-- PT_FCAT
*&---------------------------------------------------------------------*
FORM F_CREATE_FCAT_BY_ITAB  USING    PT_ITAB TYPE ANY TABLE
                            CHANGING PT_FCAT TYPE LVC_T_FCAT.

  DATA :
    LO_TABDESCR  TYPE REF TO CL_ABAP_TABLEDESCR,
    LO_STRUDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  LO_TABDESCR ?= CL_ABAP_TABLEDESCR=>DESCRIBE_BY_DATA( PT_ITAB ).
  LO_STRUDESCR ?= LO_TABDESCR->GET_TABLE_LINE_TYPE( ).

  PT_FCAT[] = CORRESPONDING #( CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUDESCR )
                                 MAPPING
                                   KEY = KEYFLAG
                                   COLTEXT   = FIELDTEXT
                            EXCEPT ROLLNAME ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_FCAT_COLTXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TEXT_H01
*&      <-- <LS_FCAT>
*&---------------------------------------------------------------------*
FORM F_SET_FCAT_COLTXT  USING  PV_TEXT
                        CHANGING CS_FCAT TYPE LVC_S_FCAT.

  CS_FCAT-SCRTEXT_S  =
  CS_FCAT-SCRTEXT_M  =
  CS_FCAT-SCRTEXT_L  =
  CS_FCAT-COLTEXT    =
  CS_FCAT-SELTEXT    =
  CS_FCAT-TOOLTIP    =
  CS_FCAT-REPTEXT    = PV_TEXT.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_FCAT_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_FCAT_100 .

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_SIZE CHANGING GT_FCAT_100.
  PERFORM F_ADJ_FCAT_100.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_EVENT_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_EVENT_100 .

  GO_GRID_100->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).

  CREATE OBJECT GCL_EVENT_100.
  SET HANDLER:
*    GCL_EVENT_100->HANDLE_DATA_CHANGED                 FOR GO_GRID_100,
    GCL_EVENT_100->HANDLE_DATA_CHANGED_FINISHED  FOR GO_GRID_100,
    GCL_EVENT_100->HANDLE_TOOLBAR                           FOR GO_GRID_100,
    GCL_EVENT_100->HANDLE_USER_COMMAND               FOR GO_GRID_100.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_SORT_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM F_SET_ALV_SORT_100 .
*
*ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DISPLAY_ALV_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DISPLAY_ALV_100 .

  CALL METHOD GO_GRID_100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_100
      IT_TOOLBAR_EXCLUDING = GT_EXCL_100[]
      IS_VARIANT           = GS_VARI_100
      I_SAVE               = GV_ASAVE_100
    CHANGING
      IT_OUTTAB            = GT_SIZE[]
      IT_FIELDCATALOG      = GT_FCAT_100[]
      IT_SORT              = GT_SORT_100[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_REFRESH_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_100
*&---------------------------------------------------------------------*
FORM F_REFRESH_ALV  USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA LS_STABLE TYPE LVC_S_STBL.
  LS_STABLE-ROW = ABAP_TRUE.
  LS_STABLE-COL = ABAP_TRUE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_100 .

  LOOP AT GT_FCAT_100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'. ""상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ZSTAT'. ""신규/수정/삭제
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'BUKRS'. ""회사코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'T001'.
        <LS_FCAT>-REF_FIELD = 'BUKRS'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'EKORG'. ""구매조직
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'T024E'.
        <LS_FCAT>-REF_FIELD = 'EKORG'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'T001W'.
        <LS_FCAT>-REF_FIELD = 'WERKS'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'LIFNR'. ""공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'LFA1'.
        <LS_FCAT>-REF_FIELD = 'LIFNR'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ZYEAR'. ""계약연도
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'DRM_GUBUN'. ""드럼구분
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1041'.
        <LS_FCAT>-REF_FIELD = 'DRM_GUBUN'.
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'DRM_SIZE'. ""드럼규격
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'SDR_NETPR'. ""신드럼 입고
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
      WHEN 'GDR_NETPR'. ""고드럼 입고
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
      WHEN 'BOARD_NETPR'. ""골판지 조립
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
      WHEN 'MARK_NETPR'. ""신드럼 마킹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
      WHEN 'DIS_NETPR'. ""고드럼 해체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
      WHEN 'WAERS'. ""통화 키
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'MESSAGE'. ""메시지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 40.

      WHEN 'MARK_H_NETPR'. ""한전 마킹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H28 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.

      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    "수정 가능
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'DRM_GUBUN' OR 'DRM_SIZE'.
        IF P_LOAD EQ ABAP_TRUE.
          <LS_FCAT>-EDIT = GV_EDIT.
        ENDIF.
      WHEN 'SDR_NETPR' OR 'GDR_NETPR' OR 'BOARD_NETPR' OR 'MARK_NETPR' OR 'DIS_NETPR' OR 'MARK_H_NETPR'.
        <LS_FCAT>-EDIT = GV_EDIT.
    ENDCASE.

  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_TOOLBAR_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM F_TOOLBAR_100  USING  PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                                     PO_SENDER.

  CHECK GV_EDIT EQ ABAP_TRUE. "수정 모드인 경우만

  DATA : LS_TBAR TYPE STB_BUTTON.

  DEFINE _SET_TBAR.
    CLEAR : LS_TBAR.

    LS_TBAR-BUTN_TYPE = &1.
    LS_TBAR-FUNCTION   = &2.
    LS_TBAR-ICON           = &3.
    LS_TBAR-TEXT          = &4.
    LS_TBAR-QUICKINFO = &4.

    APPEND LS_TBAR TO PR_OBJ->MT_TOOLBAR.
  END-OF-DEFINITION.

  _SET_TBAR 3 '    ' '              ' '    '.
  IF P_LOAD EQ ABAP_TRUE. "조회/수정인 경우만 추가 가능
    _SET_TBAR 0 'INSR'  ICON_INSERT_ROW   TEXT-BT3.
  ENDIF.

  _SET_TBAR 0 'DELE' ICON_DELETE_ROW  TEXT-BT4.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_USER_COMMAND_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_100  USING PV_UCOMM TYPE SY-UCOMM.

  CASE PV_UCOMM.
    WHEN 'INSR'. "행 추가
      PERFORM F_INSERT_ROW_100.
    WHEN 'DELE'. "행 삭제
      PERFORM F_DELETE_ROW_100.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_INSERT_ROW_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_INSERT_ROW_100 .

  DATA LV_CHECK TYPE C LENGTH 1.
  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  IF GV_WAERS IS INITIAL.
    SELECT SINGLE
      WAERS
      FROM T001
      WHERE BUKRS EQ @P_BUKRS
      INTO @GV_WAERS.
  ENDIF.

  INSERT VALUE #( ZSTAT = ICON_CREATE
                             BUKRS = P_BUKRS
                             EKORG = P_EKORG
                             WERKS = P_WERKS
                             LIFNR = P_LIFNR
                             ZYEAR = P_YEAR
                             WAERS = GV_WAERS
                             ZNEW = ABAP_TRUE
                             ZCHG = ABAP_TRUE ) INTO GT_SIZE INDEX 1.


  DATA LT_DUPL TYPE TY_T_KEY_SIZE.
  READ TABLE GT_SIZE ASSIGNING FIELD-SYMBOL(<LS_SIZE>) INDEX 1.
  PERFORM F_CHK_LINE_DATA_SIZE USING LT_DUPL CHANGING <LS_SIZE>.

  PERFORM F_REFRESH_ALV USING GO_GRID_100.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DELETE_ROW_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DELETE_ROW_100.

  DATA:
    LV_ROW_ID  TYPE INT4,
    LV_DEL_CNT TYPE INT4,
    LV_CHECK   TYPE C LENGTH 1,
    LT_ROW_ID  TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_ID.

  DELETE LT_ROW_ID WHERE ROW_ID LE 0.
  CHECK LT_ROW_ID[] IS NOT INITIAL.

  LOOP AT LT_ROW_ID ASSIGNING FIELD-SYMBOL(<LS_ROW_ID>).
    LV_ROW_ID = <LS_ROW_ID>-ROW_ID - LV_DEL_CNT.
    READ TABLE GT_SIZE ASSIGNING FIELD-SYMBOL(<LS_SIZE>) INDEX LV_ROW_ID.
    CHECK SY-SUBRC EQ 0.

    IF <LS_SIZE>-ZSTAT EQ ICON_CREATE.
      DELETE GT_SIZE INDEX LV_ROW_ID.
      LV_DEL_CNT += 1.
      CONTINUE.
    ELSE.
      <LS_SIZE>-ZSTAT = ICON_DELETE.
      <LS_SIZE>-ZCHG = ABAP_TRUE.
    ENDIF.

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_100.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED_FIN_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED_FIN_100  USING    PV_MODIFIED TYPE CHAR01
                                     PT_GOOD_CELLS TYPE LVC_T_MODI.

  CHECK PV_MODIFIED EQ ABAP_TRUE.
  DATA LT_DUPL TYPE TY_T_KEY_SIZE.

  SELECT
    ZZ~DRM_GUBUN,
    ZZ~DRM_SIZE
    FROM @GT_SIZE AS ZZ
    GROUP BY ZZ~DRM_GUBUN, ZZ~DRM_SIZE
    HAVING SUM( 1 ) GT 1
    ORDER BY ZZ~DRM_GUBUN, ZZ~DRM_SIZE
    INTO TABLE @LT_DUPL.

  FIELD-SYMBOLS:
    <LS_SIZE>  TYPE TY_SIZE,
    <LS_CELLS> TYPE LVC_S_MODI.

  LOOP AT PT_GOOD_CELLS ASSIGNING  FIELD-SYMBOL(<LS_G1>) GROUP BY ( ROW_ID = <LS_G1>-ROW_ID )
                                                              ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    READ TABLE GT_SIZE ASSIGNING <LS_SIZE> INDEX <LS_GROUP>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    IF <LS_SIZE>-ZNEW EQ SPACE AND P_LOAD EQ ABAP_TRUE.
      <LS_SIZE>-ZSTAT = ICON_CHANGE.
    ELSE.
      <LS_SIZE>-ZSTAT = ICON_CREATE.
    ENDIF.

    <LS_SIZE>-ZCHG = ABAP_TRUE.

    PERFORM F_CHK_LINE_DATA_SIZE USING LT_DUPL CHANGING <LS_SIZE>.

*    LOOP AT GROUP <LS_GROUP> ASSIGNING <LS_CELLS>.
*
*    ENDLOOP.
  ENDLOOP.

*  LOOP AT CT_SIZE ASSIGNING FIELD-SYMBOL(<LS_SIZE>).
*    PERFORM F_CHK_LINE_DATA_SIZE USING LT_DUPL CHANGING <LS_SIZE>.
*  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_100.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CREATE_ALV_OBJECT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_ALV_OBJECT_200 .

  GO_CONT_200 = NEW #( CONTAINER_NAME = 'CON200' ).
  GO_GRID_200 = NEW #( I_PARENT = GO_CONT_200 ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_EXCL_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_EXCL_200 .

  CLEAR GT_EXCL_200[].

  GT_EXCL_200[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
*                       ( CL_GUI_ALV_GRID=>MC_MB_EXPORT )
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH )
                       ( CL_GUI_ALV_GRID=>MC_FC_INFO ) ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_LAYO_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_LAYO_200 .

  CLEAR GS_LAYO_200.
  GS_LAYO_200-SEL_MODE = GC_A.
*  GS_LAYO_200-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_200-ZEBRA = ABAP_TRUE.
  GS_LAYO_200-STYLEFNAME = 'ZSTYLE'.
  GS_LAYO_200-NO_ROWMOVE = ABAP_TRUE.
  GS_LAYO_200-NO_ROWINS = ABAP_TRUE.

*"업체명(NAME1) &&"" ""&& 계약연도(P_YEAR) && ' 드럼 단가'
*EX) 용남목재 2026 드럼 단가"
  CHECK P_DISP NE ABAP_TRUE.
  GS_LAYO_200-SMALLTITLE = ABAP_TRUE.
  SELECT SINGLE
    NAME1
    FROM LFA1
    WHERE LIFNR EQ @P_LIFNR
    INTO @DATA(LV_NAME1).
  GS_LAYO_200-GRID_TITLE = |{ LV_NAME1 } { P_YEAR } { TEXT-AT2 }|.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_VARI_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_VARI_200 .

  CLEAR GS_VARI_200.

  GS_VARI_200-REPORT = SY-REPID.
  GS_VARI_200-USERNAME = SY-UNAME.
  GS_VARI_200-HANDLE = 'AL02'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_FCAT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_FCAT_200 .

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_DRUM CHANGING GT_FCAT_200.
  PERFORM F_ADJ_FCAT_200.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_200 .

  LOOP AT GT_FCAT_200 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'. ""상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ZSTAT'. ""신규/수정/삭제
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'BUKRS'. ""회사코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'T001'.
        <LS_FCAT>-REF_FIELD = 'BUKRS'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'EKORG'. ""구매조직
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'T024E'.
        <LS_FCAT>-REF_FIELD = 'EKORG'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'WERKS'. ""플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'MARC'.
        <LS_FCAT>-REF_FIELD = 'WERKS'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'LIFNR'. ""공급업체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'LFA1'.
        <LS_FCAT>-REF_FIELD = 'LIFNR'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ZYEAR'. ""계약연도
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'MATNR'. ""자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'MARC'.
        <LS_FCAT>-REF_FIELD = 'MATNR'.
      WHEN 'MAKTX'. ""자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 20.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'DRM_TYPE'. ""일반/특수
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1042'.
        <LS_FCAT>-REF_FIELD = 'DRM_TYPE'.
      WHEN 'DRM_GUBUN'. ""드럼구분
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1041'.
        <LS_FCAT>-REF_FIELD = 'DRM_GUBUN'.
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'DRM_SIZE'. ""드럼규격
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'DRM_SG_TYPE'. ""신/고
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'DRM_LV'. ""관리 레벨
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H21 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'DRM_NETPR'. ""드럼 입고
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H22 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
      WHEN 'BOARD_NETPR'. ""골판지 조립
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
      WHEN 'MARK_NETPR'. ""신드럼 마킹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
      WHEN 'DIS_NETPR'. ""고드럼 해체
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.
      WHEN 'WAERS'. ""통화 키
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'PEINH'. ""가격 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H23 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
      WHEN 'BPRME'. ""오더 가격 단위(구매)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H24 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MEINS'. ""기본 단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H25 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LVORM'. ""삭제 지시자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H26 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'AUTO'. ""자동 계산여부
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H27 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 6.
        <LS_FCAT>-JUST = GC_C.

      WHEN 'MARK_H_NETPR'. ""한전 마킹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H28 CHANGING <LS_FCAT>."
        <LS_FCAT>-CFIELDNAME = 'WAERS'.

      WHEN 'VERID'. ""생산버전(인포)
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H29 CHANGING <LS_FCAT>."
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = 10.

      WHEN 'STATUS_SC10'. ""생산버전
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H30 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = 6.

      WHEN 'MESSAGE'. ""메시지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 40.
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    "수정 가능
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'MATNR' OR 'DRM_NETPR' OR 'BOARD_NETPR' OR 'MARK_NETPR' OR 'DIS_NETPR' OR 'MARK_H_NETPR'
        OR 'DRM_TYPE' OR 'DRM_LV'.  "드럼 타입 / 관리레벨 수정 가능하게 변경
        <LS_FCAT>-EDIT = GV_EDIT.
    ENDCASE.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_EVENT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_EVENT_200 .

  GO_GRID_200->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).

  CREATE OBJECT GCL_EVENT_200.
  SET HANDLER:
*    GCL_EVENT_100->HANDLE_DATA_CHANGED                 FOR GO_GRID_100,
    GCL_EVENT_200->HANDLE_DATA_CHANGED_FINISHED  FOR GO_GRID_200,
    GCL_EVENT_200->HANDLE_TOOLBAR                           FOR GO_GRID_200,
    GCL_EVENT_200->HANDLE_USER_COMMAND               FOR GO_GRID_200.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DISPLAY_ALV_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DISPLAY_ALV_200 .

  CALL METHOD GO_GRID_200->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_200
      IT_TOOLBAR_EXCLUDING = GT_EXCL_200[]
      IS_VARIANT           = GS_VARI_200
      I_SAVE               = GV_ASAVE_200
    CHANGING
      IT_OUTTAB            = GT_DRUM[]
      IT_FIELDCATALOG      = GT_FCAT_200[]
      IT_SORT              = GT_SORT_200[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_TOOLBAR_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM F_TOOLBAR_200  USING  PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                                     PO_SENDER.

  CHECK GV_EDIT EQ ABAP_TRUE. "수정 모드인 경우만

  DATA : LS_TBAR TYPE STB_BUTTON.

  DEFINE _SET_TBAR.
    CLEAR : LS_TBAR.

    LS_TBAR-BUTN_TYPE = &1.
    LS_TBAR-FUNCTION   = &2.
    LS_TBAR-ICON           = &3.
    LS_TBAR-TEXT          = &4.
    LS_TBAR-QUICKINFO = &4.

    APPEND LS_TBAR TO PR_OBJ->MT_TOOLBAR.
  END-OF-DEFINITION.

  _SET_TBAR 3 '    ' '              ' '    '.
  IF P_DISP EQ ABAP_TRUE. "조회/변경인 경우만 라인추가
    _SET_TBAR 0 'INSR'  ICON_INSERT_ROW   TEXT-BT3.
  ENDIF.

  _SET_TBAR 0 'DELE' ICON_DELETE_ROW  TEXT-BT4.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_USER_COMMAND_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_200  USING PV_UCOMM TYPE SY-UCOMM.

  CASE PV_UCOMM.
    WHEN 'INSR'. "행 추가
      PERFORM F_INSERT_ROW_200.
    WHEN 'DELE'. "행 삭제
      PERFORM F_DELETE_ROW_200.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_INSERT_ROW_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_INSERT_ROW_200 .

  DATA LV_CHECK TYPE C LENGTH 1.
  CALL METHOD GO_GRID_200->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  IF GV_WAERS IS INITIAL.
    SELECT SINGLE
      WAERS
      FROM T001
      WHERE BUKRS EQ @P_BUKRS
      INTO @GV_WAERS.
  ENDIF.

  READ TABLE GT_DRUM ASSIGNING FIELD-SYMBOL(<LS_DRUM>) INDEX 1.
  CHECK SY-SUBRC EQ 0.

  INSERT VALUE #( ZSTAT = ICON_CREATE
                             BUKRS = <LS_DRUM>-BUKRS
                             EKORG = <LS_DRUM>-EKORG
                             WERKS = <LS_DRUM>-WERKS
                             LIFNR = <LS_DRUM>-LIFNR
                             ZYEAR = <LS_DRUM>-ZYEAR
                             WAERS = GV_WAERS
                             PEINH = 1
                             ZNEW = ABAP_TRUE
                             ZCHG = ABAP_TRUE ) INTO GT_DRUM INDEX 1.

  DATA:
    LT_DUPL TYPE TY_T_KEY_DRUM,
    LT_MST  TYPE TY_T_MST,
    LT_MARA TYPE TY_T_MARA.

  "오류 점검 및 메세지 설정
  READ TABLE GT_DRUM ASSIGNING <LS_DRUM> INDEX 1.
  CHECK SY-SUBRC EQ 0.
  PERFORM F_CHK_LINE_DATA_DRUM USING LT_DUPL LT_MST LT_MARA CHANGING <LS_DRUM>.

  PERFORM F_REFRESH_ALV USING GO_GRID_200.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DELETE_ROW_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DELETE_ROW_200 .

  DATA:
    LV_ROW_ID  TYPE INT4,
    LV_DEL_CNT TYPE INT4,
    LV_CHECK   TYPE C LENGTH 1,
    LT_ROW_ID  TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_200->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_200->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_ID.

  DELETE LT_ROW_ID WHERE ROW_ID LE 0.
  CHECK LT_ROW_ID[] IS NOT INITIAL.

  LOOP AT LT_ROW_ID ASSIGNING FIELD-SYMBOL(<LS_ROW_ID>).
    LV_ROW_ID = <LS_ROW_ID>-ROW_ID - LV_DEL_CNT.
    READ TABLE GT_DRUM ASSIGNING FIELD-SYMBOL(<LS_DRUM>) INDEX LV_ROW_ID.
    CHECK SY-SUBRC EQ 0.

    IF <LS_DRUM>-ZSTAT EQ ICON_CREATE.
      DELETE GT_DRUM INDEX LV_ROW_ID.
      LV_DEL_CNT += 1.
      CONTINUE.
    ELSE.
      <LS_DRUM>-ZSTAT = ICON_DELETE.
      <LS_DRUM>-ZCHG = ABAP_TRUE.
    ENDIF.

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_200.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED_FIN_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED_FIN_200  USING    PV_MODIFIED TYPE CHAR01
                                     PT_GOOD_CELLS TYPE LVC_T_MODI.

  CHECK PV_MODIFIED EQ ABAP_TRUE.


  DATA:
    LT_DUPL TYPE TY_T_KEY_DRUM,
    LT_MST  TYPE TY_T_MST,
    LT_MARA TYPE TY_T_MARA.

  "Key 중복
  SELECT
    ZZ~BUKRS,
    ZZ~EKORG,
    ZZ~WERKS,
    ZZ~LIFNR,
    ZZ~ZYEAR,
    ZZ~MATNR
    FROM @GT_DRUM AS ZZ
    GROUP BY ZZ~BUKRS, ZZ~EKORG, ZZ~WERKS, ZZ~LIFNR, ZZ~ZYEAR, ZZ~MATNR
    HAVING SUM( 1 ) GT 1
    ORDER BY ZZ~BUKRS, ZZ~EKORG, ZZ~WERKS, ZZ~LIFNR, ZZ~ZYEAR, ZZ~MATNR
    INTO TABLE @LT_DUPL.

  "특성 값
  SELECT
    V1~MATNR,
    V1~MAKTX,
    V1~DRM_GUBUN,
    V1~DRM_SIZE,
    V1~DRM_SG_TYPE,
    V1~MEINS,
    V1~LVORM
    FROM ZGTMM_CV_DRUM_STATUS AS V1
    WHERE EXISTS (
      SELECT ZZ~MATNR
        FROM @GT_DRUM AS ZZ
        WHERE ZZ~MATNR EQ V1~MATNR
    )
    ORDER BY V1~MATNR
    INTO TABLE @LT_MST.

  "규격 단가
  SELECT
    Z1~BUKRS,
    Z1~EKORG,
    Z1~WERKS,
    Z1~LIFNR,
    Z1~ZYEAR,
    Z1~DRM_GUBUN,
    Z1~DRM_SIZE,
    Z1~WAERS,
    Z1~SDR_NETPR,
    Z1~GDR_NETPR,
    Z1~BOARD_NETPR,
    Z1~MARK_NETPR,
    Z1~MARK_H_NETPR,
    Z1~DIS_NETPR
    FROM ZGTMMT1041 AS Z1
    WHERE EXISTS (
        SELECT ZZ~BUKRS
          FROM @GT_DRUM AS ZZ
          WHERE ZZ~BUKRS EQ Z1~BUKRS
             AND ZZ~EKORG EQ Z1~EKORG
             AND ZZ~WERKS EQ Z1~WERKS
             AND ZZ~LIFNR EQ Z1~LIFNR
             AND ZZ~ZYEAR EQ Z1~ZYEAR
    )
    ORDER BY Z1~BUKRS, Z1~EKORG, Z1~WERKS, Z1~LIFNR, Z1~ZYEAR, Z1~DRM_GUBUN,  Z1~DRM_SIZE
    INTO TABLE @DATA(LT_SIZE).

  "자재마스터
  SELECT
    MR~MATNR
    FROM MARA AS MR
    WHERE EXISTS (
      SELECT ZZ~MATNR
        FROM @GT_DRUM AS ZZ
        WHERE ZZ~MATNR EQ MR~MATNR
    )
    ORDER BY MR~MATNR
    INTO TABLE @LT_MARA.

  "인포레코드
  SELECT
    V1~EKORG,
    V1~WERKS,
    V1~LIFNR,
    V1~MATNR,
    V1~DATAB,
    V1~DATBI,
    V1~KBETR
    FROM ZGTMM_CV_GET_INFOPRICE AS V1
    WHERE EXISTS (
      SELECT ZZ~EKORG
        FROM @GT_DRUM AS ZZ
        WHERE ZZ~EKORG EQ V1~EKORG
           AND ZZ~WERKS EQ V1~WERKS
           AND ZZ~LIFNR EQ V1~LIFNR
           AND ZZ~MATNR EQ V1~MATNR
    )
    INTO TABLE @DATA(LT_INFO).

  FIELD-SYMBOLS:
    <LS_DRUM>  TYPE TY_DRUM,
    <LS_CELLS> TYPE LVC_S_MODI.

  DATA LV_DATE TYPE DATUM.

  LOOP AT PT_GOOD_CELLS ASSIGNING  FIELD-SYMBOL(<LS_G0>) GROUP BY ( ROW_ID = <LS_G0>-ROW_ID )
                                                              ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    READ TABLE GT_DRUM ASSIGNING <LS_DRUM> INDEX <LS_GROUP>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    IF <LS_DRUM>-ZNEW EQ SPACE.
      <LS_DRUM>-ZSTAT = ICON_CHANGE.
    ELSE.
      <LS_DRUM>-ZSTAT = ICON_CREATE.
    ENDIF.

    <LS_DRUM>-ZCHG = ABAP_TRUE.

    LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_FIELD>).
      CASE <LS_FIELD>-FIELDNAME.
        WHEN 'MATNR'. "자재번호
          "특성 값 설정
          READ TABLE LT_MST ASSIGNING FIELD-SYMBOL(<LS_MST>) WITH KEY MATNR = <LS_DRUM>-MATNR BINARY SEARCH.
          IF SY-SUBRC EQ 0.
            <LS_DRUM> = CORRESPONDING #( BASE ( <LS_DRUM> ) <LS_MST> ). "값 설정
            <LS_DRUM>-BPRME = <LS_DRUM>-MEINS.
          ENDIF.

          "일반/특수 설정
          READ TABLE GT_TYPE_CD ASSIGNING FIELD-SYMBOL(<LS_TYPE_CD>) WITH KEY DRM_GUBUN = <LS_DRUM>-DRM_GUBUN BINARY SEARCH.
          IF SY-SUBRC EQ 0.
            <LS_DRUM> = CORRESPONDING #( BASE ( <LS_DRUM> ) <LS_TYPE_CD> ). "값 설정
          ENDIF.

          "관리 레벨 설정
          LOOP AT GT_LV_CD ASSIGNING FIELD-SYMBOL(<LS_G1>) GROUP BY ( WERKS = <LS_G1>-WERKS )
                                                                                          ASSIGNING FIELD-SYMBOL(<LS_LV_GROUP>).
            CHECK <LS_LV_GROUP>-WERKS = <LS_DRUM>-WERKS.
            LOOP AT GROUP <LS_LV_GROUP> ASSIGNING FIELD-SYMBOL(<LS_LV_CD>).
              CHECK <LS_LV_CD>-DRM_SIZE_F LE <LS_DRUM>-DRM_SIZE AND <LS_LV_CD>-DRM_SIZE_T GE <LS_DRUM>-DRM_SIZE.
              <LS_DRUM>-DRM_LV = <LS_LV_CD>-DRM_LV.
              EXIT.
            ENDLOOP.
          ENDLOOP.

          "생산버전/BOM 설정
          IF <LS_DRUM>-DRM_SG_TYPE EQ GC_S.  "신드럼일때
            " BOM+생산버전 SELECT
            SELECT SINGLE MA~STLAN, MA~STLAL, MK~VERID
              FROM MAST AS MA
              LEFT OUTER JOIN MKAL AS MK ON MA~MATNR EQ MK~MATNR
                                                            AND MA~WERKS EQ MK~WERKS
                                                            AND MK~VERID EQ @GC_SC10
              WHERE MA~STLAN EQ @GC_1
                  AND MA~STLAL EQ '01'
                  AND MA~MATNR EQ @<LS_DRUM>-MATNR
                  AND MA~WERKS EQ @<LS_DRUM>-WERKS
                INTO @DATA(LS_SC10).

            IF LS_SC10 IS INITIAL.  "BOM, 생산버전 미존재
              <LS_DRUM>-STATUS_SC10 = ICON_LED_RED.
            ELSEIF LS_SC10-VERID IS INITIAL.  "BOM 존재 / 생산버전 미존재
              <LS_DRUM>-STATUS_SC10 = ICON_LED_YELLOW.
            ELSE.
              <LS_DRUM>-STATUS_SC10 = ICON_LED_GREEN. "BOM, 생산버전 존재
            ENDIF.
            CLEAR: LS_SC10.
          ENDIF.

      ENDCASE.
    ENDLOOP.

    PERFORM F_CHK_LINE_DATA_DRUM USING LT_DUPL LT_MST LT_MARA CHANGING <LS_DRUM>.

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_200.


ENDFORM.
