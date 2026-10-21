*&---------------------------------------------------------------------*
*& Include          ZGTMMR1070F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form F_TOOLBAR_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&---------------------------------------------------------------------*
FORM F_TOOLBAR_100  USING  PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.


  DATA : LS_TBAR TYPE STB_BUTTON.

  DEFINE _SET_TBAR.
    CLEAR : LS_TBAR.

    LS_TBAR-BUTN_TYPE = &1.
    LS_TBAR-FUNCTION   = &2.
    LS_TBAR-ICON           = &3.
    LS_TBAR-TEXT          = &4.
    LS_TBAR-QUICKINFO = &5.

    APPEND LS_TBAR TO PR_OBJ->MT_TOOLBAR.
  END-OF-DEFINITION.

  _SET_TBAR 3 SPACE SPACE SPACE SPACE.

  _SET_TBAR 0 'INS' ICON_INSERT_ROW   TEXT-BT1 TEXT-BT1.
  _SET_TBAR 0 'DEL' ICON_DELETE_ROW   TEXT-BT2 TEXT-BT2.

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
    WHEN 'INS'.
      PERFORM F_INSERT_ROW_100.
    WHEN 'DEL'.
      PERFORM F_DELETE_ROW_100.
  ENDCASE.
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

  DATA: LV_ENAME TYPE ZZPA0001-ENAME.

  CHECK PV_MODIFIED EQ ABAP_TRUE.

  FIELD-SYMBOLS <LS_USER> TYPE TY_USER.

  LOOP AT PT_GOOD_CELLS ASSIGNING  FIELD-SYMBOL(<LS_G0>)
                                                                GROUP BY ( ROW_ID = <LS_G0>-ROW_ID )
                                                                ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    CLEAR: LV_ENAME.

    READ TABLE GT_USER ASSIGNING <LS_USER> INDEX <LS_GROUP>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    SELECT SINGLE ENAME
      FROM ZZPA0001
      INTO LV_ENAME
      WHERE PERNR EQ <LS_USER>-APPUSER
      AND ENDDA EQ '99991231'.

    <LS_USER>-ENAME = LV_ENAME.

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_REFRESH_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_REFRESH_100 .

  DATA LV_CHECK TYPE C LENGTH 1.

  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CLEAR:
    GS_USER,
    GT_USER[].

  "데이터 다시 조회
  PERFORM F_GET_DATA_USER.


ENDFORM.
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

  CLEAR:
   GT_EXCL_100.

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

  CLEAR:
    GS_LAYO_100.

  GS_LAYO_100-SEL_MODE = GC_A.
*  GS_LAYO_100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_100-ZEBRA = ABAP_TRUE.
*  GS_LAYO_100-SMALLTITLE = ABAP_TRUE.
  GS_LAYO_100-STYLEFNAME = 'ZSTYLE'.
  GS_LAYO_100-NO_ROWMOVE = ABAP_TRUE.
  GS_LAYO_100-NO_ROWINS = ABAP_TRUE.

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
  CLEAR:
    GS_VARI_100.

  GS_VARI_100-REPORT = SY-REPID.
  GS_VARI_100-USERNAME = SY-UNAME.
  GS_VARI_100-HANDLE = 'ALD1'.

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

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_USER CHANGING GT_FCAT_100.

  PERFORM F_ADJ_FCAT_100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_CREATE_FCAT_BY_ITAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SKID
*&      <-- GT_FCAT_100
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
*& Form F_FCAT_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_100 .

  LOOP AT GT_FCAT_100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.

      WHEN 'BUKRS'.  "회사코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.

      WHEN 'BUTXT'.  "회사명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 10.    "

      WHEN 'WERKS'.  "플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'T001W'.
        <LS_FCAT>-REF_FIELD = 'WERKS'.
        <LS_FCAT>-JUST = GC_C.

      WHEN 'NAME1'.  "플랜트명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 10.    "

      WHEN 'APPUSER'.  "담당자 사번
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>.
        <LS_FCAT>-EDIT = ABAP_TRUE.    "
        <LS_FCAT>-F4AVAILABL = ABAP_TRUE.    "
        <LS_FCAT>-OUTPUTLEN = 12.    "
        <LS_FCAT>-JUST = 'L'.

      WHEN 'BNAME'.  "담당자 ID
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.

      WHEN 'ENAME'.  "담당자 명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 12.    "

      WHEN 'ERDAT'.  "생성일자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>.

      WHEN 'ERTIM'.  "생성시간
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>.

      WHEN 'ERNAM'.  "생성자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>.

      WHEN 'AEDAT'.  "변경일자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>.

      WHEN 'AETIM'.  "변경시간
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>.

      WHEN 'AENAM'.  "변경자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>.

      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.    "
    ENDCASE.

  ENDLOOP.




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
*    GCL_EVENT_100->HANDLE_HOTSPOT_CLICK FOR GO_GRID_100,
    GCL_EVENT_100->HANDLE_TOOLBAR FOR GO_GRID_100,
    GCL_EVENT_100->HANDLE_USER_COMMAND FOR GO_GRID_100,
    GCL_EVENT_100->HANDLE_DATA_CHANGED_FINISHED FOR GO_GRID_100,
    GCL_EVENT_100->HANDLE_ON_F4 FOR GO_GRID_100.

ENDFORM.

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
      IT_OUTTAB            = GT_USER[]
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
*& Form F_INSERT_ROW_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_INSERT_ROW_100 .
  DATA: LV_LINES TYPE I.

  DATA LV_CHECK TYPE C LENGTH 1.
  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  " 승인자 기존 데이터 확인
  SELECT *
    FROM ZGTMMT1022
  WHERE BUKRS EQ @P_BUKRS
    AND WERKS EQ @P_WERKS
    INTO TABLE @DATA(LT_CHK).

  IF GT_USER[] IS NOT INITIAL.  "이미 LINE 존재하는 경우
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E01.

  ELSEIF LT_CHK IS NOT INITIAL."LINE은 없지만 DB에 데이터 존재하는 경우
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E02.

  ELSE.
    INSERT VALUE #( BUKRS = P_BUKRS
                               WERKS = P_WERKS
                               ) INTO GT_USER INDEX 1.

    LOOP AT  GT_USER ASSIGNING FIELD-SYMBOL(<LS_USER>).
      PERFORM F_MAKE_DATA_USER CHANGING <LS_USER>.
    ENDLOOP.

    PERFORM F_REFRESH_ALV USING GO_GRID_100.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_DELETE_ROW_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DELETE_ROW_100 .
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

  CLEAR LV_CHECK.

  LOOP AT LT_ROW_ID ASSIGNING FIELD-SYMBOL(<LS_ROW_ID>).
    LV_ROW_ID = <LS_ROW_ID>-ROW_ID - LV_DEL_CNT.
    READ TABLE GT_USER ASSIGNING FIELD-SYMBOL(<LS_USER>) INDEX LV_ROW_ID.
    CHECK SY-SUBRC EQ 0.

    " DB에 저장된 값인지 확인
    SELECT SINGLE *
      FROM ZGTMMT1022
      WHERE BUKRS EQ @<LS_USER>-BUKRS
      AND WERKS EQ @<LS_USER>-WERKS
      AND APPUSER EQ @<LS_USER>-APPUSER
      INTO @DATA(LS_1022).

    IF LS_1022 IS NOT INITIAL.    "DB에 존재하는 값인 경우

      "POP UP TO CONFIRM
      "승인 담당자 정보를 삭제하시겠습니까? (예/아니오)"
      DATA LV_ANS TYPE C LENGTH 1.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR      = TEXT-TT1 "확인
          TEXT_QUESTION = TEXT-Q01
        IMPORTING
          ANSWER        = LV_ANS.

      CHECK LV_ANS EQ GC_1.

      DELETE ZGTMMT1022 FROM LS_1022.
      IF SY-SUBRC EQ 0.
        MESSAGE S000 WITH TEXT-M01.
        DELETE GT_USER INDEX LV_ROW_ID.
      ELSE.
        MESSAGE E014.
      ENDIF.

    ELSE.     " DB에 존재하지 않는 경우 -> 즉시 삭제
      DELETE GT_USER INDEX LV_ROW_ID.
    ENDIF.

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ON_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_FIELDNAME
*&      --> E_FIELDVALUE
*&      --> ES_ROW_NO
*&      --> ER_EVENT_DATA
*&      --> ET_BAD_CELLS
*&      --> E_DISPLAY
*&---------------------------------------------------------------------*
FORM F_ON_F4  USING    PV_FIELDNAME
                                    PV_FIELDVALUE
                                    PS_ROW_NO     TYPE LVC_S_ROID
                                    PO_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                                    PT_BAD_CELLS  TYPE LVC_T_MODI
                                    PV_DISPLAY.

  FIELD-SYMBOLS <LS_MODI> TYPE LVC_T_MODI.

  DATA: LT_RETURN TYPE TABLE OF DDSHRETVAL,
        LS_SHLP   TYPE SHLP_DESCR,
        LT_RECORD TYPE TABLE OF SEAHLPRES.

* STANDARD F4(Search Help)는 무시
  PO_EVENT_DATA->M_EVENT_HANDLED = ABAP_TRUE.


  CASE PV_FIELDNAME.
    WHEN 'APPUSER'.

      CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
        EXPORTING
          SHLPNAME = 'ZGTHMM_APPUSER'
        IMPORTING
          SHLP     = LS_SHLP.

      LOOP AT LS_SHLP-INTERFACE ASSIGNING FIELD-SYMBOL(<LS_IF>).

        CASE <LS_IF>-SHLPFIELD.
          WHEN 'BUKRS'.
            <LS_IF>-VALFIELD = 'X'.
            <LS_IF>-VALUE    = P_BUKRS.
          WHEN 'ENDDA'.
            <LS_IF>-VALFIELD = 'X'.
            <LS_IF>-VALUE    = '99991231'.
          WHEN OTHERS.
            <LS_IF>-VALFIELD = 'X'.
        ENDCASE.

      ENDLOOP.

      CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
        EXPORTING
          SHLP          = LS_SHLP
        TABLES
          RETURN_VALUES = LT_RETURN.

      CHECK LT_RETURN IS NOT INITIAL.

      ASSIGN PO_EVENT_DATA->M_DATA->* TO <LS_MODI>.

      READ TABLE LT_RETURN INTO DATA(LS_RETURN) INDEX 1.
      DATA(LS_MODI) = VALUE LVC_S_MODI( ROW_ID    = PS_ROW_NO-ROW_ID
                                        FIELDNAME = 'APPUSER'
                                        VALUE     = LS_RETURN-FIELDVAL ).

      APPEND LS_MODI TO <LS_MODI>.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_F4_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_F4_100 .

  DATA(LT_F4) = VALUE LVC_T_F4( REGISTER = GC_X ( FIELDNAME = 'APPUSER' )
                               ).
  CALL METHOD GO_GRID_100->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SAVE_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SAVE_100 .
  DATA:
    LV_ROW_ID  TYPE INT4,
    LV_DEL_CNT TYPE INT4,
    LV_CHECK   TYPE C LENGTH 1,
    LT_ROW_ID  TYPE LVC_T_ROID,

    LS_1022    TYPE ZGTMMT1022,
    LV_TOT     TYPE I,
    LV_E       TYPE I,
    LV_S       TYPE I.

  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_ID.

  DELETE LT_ROW_ID WHERE ROW_ID LE 0.

  IF LT_ROW_ID[] IS INITIAL.
    MESSAGE E000 WITH TEXT-E05.
  ENDIF.

  CHECK LT_ROW_ID[] IS NOT INITIAL.

  CLEAR LV_CHECK.

  "POP UP TO CONFIRM
  "승인 담당자 정보를 저장하시겠습니까? (예/아니오)"
  DATA LV_ANS TYPE C LENGTH 1.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1 "확인
      TEXT_QUESTION = TEXT-Q02
    IMPORTING
      ANSWER        = LV_ANS.

  CHECK LV_ANS EQ GC_1.

  "타임스탬프 설정

  LOOP AT LT_ROW_ID ASSIGNING FIELD-SYMBOL(<LS_ROW_ID>).
    LV_ROW_ID = <LS_ROW_ID>-ROW_ID - LV_DEL_CNT.
    READ TABLE GT_USER ASSIGNING FIELD-SYMBOL(<LS_USER>) INDEX LV_ROW_ID.
    CHECK SY-SUBRC EQ 0.

    IF <LS_USER>-APPUSER IS INITIAL.
        MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E04.
    ENDIF.

    " 기존 데이터 조회 - 플랜트 단위
    SELECT SINGLE *
    FROM ZGTMMT1022
    INTO LS_1022
    WHERE BUKRS EQ <LS_USER>-BUKRS
    AND WERKS EQ <LS_USER>-WERKS.

" 추후 플랜트별 다수 승인자 확장을 고려하여 키는 APPUSER까지 지정해두었으나
" 현재 기준으로는 PLANT당 한명으로 관리되어야하므로, 기존 값을 삭제한 뒤 신규값 추가하도록 함
    IF SY-SUBRC EQ 0. "수정
      DELETE ZGTMMT1022 FROM LS_1022.

      LS_1022-APPUSER = <LS_USER>-APPUSER.
      LS_1022-BNAME = <LS_USER>-BNAME.

      LS_1022-AEDAT = SY-DATUM.
      LS_1022-AEDAT_LOCAL = SY-DATLO.
      LS_1022-AETIM = SY-UZEIT.
      LS_1022-AETIM_LOCAL = SY-TIMLO.
      LS_1022-AENAM = SY-UNAME.

    ELSE. "신규
      MOVE-CORRESPONDING <LS_USER> TO LS_1022.
      LS_1022-ERDAT = SY-DATUM.
      LS_1022-ERDAT_LOCAL = SY-DATLO.
      LS_1022-ERTIM = SY-UZEIT.
      LS_1022-ERTIM_LOCAL = SY-TIMLO.
      LS_1022-ERNAM = SY-UNAME.
    ENDIF.

    MODIFY ZGTMMT1022 FROM LS_1022.

    IF SY-SUBRC EQ 0.
      LV_S += 1.

    ELSE.
      LV_E += 1.
    ENDIF.

  ENDLOOP.

  COMMIT WORK.

  LV_TOT = LV_E + LV_S.

  MESSAGE S009 WITH LV_TOT LV_S LV_E.

  PERFORM F_REFRESH_ALV USING GO_GRID_100.

ENDFORM.
