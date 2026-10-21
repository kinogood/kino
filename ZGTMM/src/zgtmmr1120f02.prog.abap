*&---------------------------------------------------------------------*
*& Include          ZGTMMR1120F02
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form F_CREATE_ALV_OBJECT_900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_ALV_OBJECT_900 .

  DATA:
    LO_SPLIT  TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
    LO_CNTR_T TYPE REF TO CL_GUI_CONTAINER,
    LO_CNTR_B TYPE REF TO CL_GUI_CONTAINER.

  GO_CONT_900 = NEW #( CONTAINER_NAME = 'CON900' ).

  "Split Container
  LO_SPLIT = NEW #( PARENT  = GO_CONT_900
                    ROWS    = 2
                    COLUMNS = 1 ).

  LO_CNTR_T = LO_SPLIT->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
  LO_CNTR_B = LO_SPLIT->GET_CONTAINER( ROW = 2 COLUMN = 1 ).

  "ALV Obj.
  GO_GRID_900_T = NEW #( I_PARENT = LO_CNTR_T ).
  GO_GRID_900_B = NEW #( I_PARENT = LO_CNTR_B ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_EXCL_900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_EXCL_900 .

  CLEAR:
   GT_EXCL_900_T[],
   GT_EXCL_900_B[].

  GT_EXCL_900_T[] = GT_EXCL_900_B[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
                       ( CL_GUI_ALV_GRID=>MC_MB_EXPORT )
                       ( CL_GUI_ALV_GRID=>MC_FC_REFRESH )
                       ( CL_GUI_ALV_GRID=>MC_FC_INFO ) ).


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_LAYO_900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_LAYO_900 .

  CLEAR:
    GS_LAYO_900_T,
    GS_LAYO_900_B.

  GS_LAYO_900_T-SEL_MODE = GC_A.
  GS_LAYO_900_T-ZEBRA = SPACE.
  GS_LAYO_900_T-SMALLTITLE = ABAP_TRUE.
  GS_LAYO_900_T-NO_ROWMOVE = ABAP_TRUE.
  GS_LAYO_900_T-NO_ROWINS = ABAP_TRUE.
  GS_LAYO_900_T-ZEBRA = ABAP_TRUE.
  GS_LAYO_900_T-STYLEFNAME = 'ZSTYLE'.
  GS_LAYO_900_B = GS_LAYO_900_T.

  GS_LAYO_900_T-GRID_TITLE = TEXT-AT1. "대분류
  GS_LAYO_900_B-GRID_TITLE = TEXT-AT2. "중분류

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_VARI_900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_VARI_900 .

  CLEAR:
    GS_VARI_900_T,
    GS_VARI_900_B.

  GS_VARI_900_T-REPORT = SY-REPID.
  GS_VARI_900_T-USERNAME = SY-UNAME.
  GS_VARI_900_T-HANDLE = 'A90T'.

  GS_VARI_900_B-REPORT = SY-REPID.
  GS_VARI_900_B-USERNAME = SY-UNAME.
  GS_VARI_900_B-HANDLE = 'A90B'.

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
*& Form F_SET_FCAT_900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_FCAT_900 .

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_MRO1 CHANGING GT_FCAT_900_T.
  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_MRO2 CHANGING GT_FCAT_900_B.

  PERFORM F_ADJ_FCAT_900_T.
  PERFORM F_ADJ_FCAT_900_B.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_REFRESH_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_100_T
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
*& Form F_DISPLAY_ALV_900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DISPLAY_ALV_900 .

  CALL METHOD GO_GRID_900_T->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_900_T
      IT_TOOLBAR_EXCLUDING = GT_EXCL_900_T[]
      IS_VARIANT           = GS_VARI_900_T
      I_SAVE               = GV_ASAVE_900_T
    CHANGING
      IT_OUTTAB            = GT_MRO1[]
      IT_FIELDCATALOG      = GT_FCAT_900_T[]
      IT_SORT              = GT_SORT_900_T[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD GO_GRID_900_B->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_900_B
      IT_TOOLBAR_EXCLUDING = GT_EXCL_900_B[]
      IS_VARIANT           = GS_VARI_900_B
      I_SAVE               = GV_ASAVE_900_B
    CHANGING
      IT_OUTTAB            = GT_MRO2[]
      IT_FIELDCATALOG      = GT_FCAT_900_B[]
      IT_SORT              = GT_SORT_900_B[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_900_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_900_T .

  LOOP AT GT_FCAT_900_T ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.

      WHEN 'STATUS'. ""점검
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 5.
      WHEN 'ZSTAT'. ""상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 5.
      WHEN 'BUKRS'. ""회사코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'MRO_TYPE1'. ""대분류
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1122'.
        <LS_FCAT>-REF_FIELD = 'MRO_TYPE1'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-NO_CONVEXT = ABAP_TRUE.

      WHEN 'MRO_TEXT1'. ""대분류명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1121'.
        <LS_FCAT>-REF_FIELD = 'MRO_TEXT1'.
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'MATKL'. ""자재그룹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-F4AVAILABL = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'T023T'.
        <LS_FCAT>-REF_FIELD = 'MATKL'.
        <LS_FCAT>-CHECKTABLE = '!'.
      WHEN 'WGBEZ'. ""자재그룹명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'CHECK_MAT'. ""자재
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'MESSAGE'. ""메시지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 40.
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    "수정 가능
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'MRO_TYPE1' OR 'MRO_TEXT1' OR 'MATKL'.
        <LS_FCAT>-EDIT = GV_EDIT.
    ENDCASE.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_900_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_900_B .

  LOOP AT GT_FCAT_900_B ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.

      WHEN 'STATUS'. ""점검
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 5.
      WHEN 'ZSTAT'. ""상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 5.
*      WHEN 'BUKRS'. ""회사코드
*        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
*        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
*        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'MRO_TYPE1'. ""대분류
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1122'.
        <LS_FCAT>-REF_FIELD = 'MRO_TYPE1'.
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-NO_CONVEXT = ABAP_TRUE.
      WHEN 'MRO_TEXT1'. ""대분류명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1122'.
        <LS_FCAT>-REF_FIELD = 'MRO_TEXT1'.
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'MRO_TYPE2'. ""중분류
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1122'.
        <LS_FCAT>-REF_FIELD = 'MRO_TYPE2'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-F4AVAILABL = SPACE.
        <LS_FCAT>-NO_CONVEXT = ABAP_TRUE.
      WHEN 'MRO_TEXT2'. ""중분류명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1122'.
        <LS_FCAT>-REF_FIELD = 'MRO_TEXT2'.
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'CHECK_MAT'. ""자재
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>."
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'MESSAGE'. ""메시지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 40.
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    "수정 가능
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'MRO_TYPE2' OR 'MRO_TEXT2' .
        <LS_FCAT>-EDIT = GV_EDIT.
    ENDCASE.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_EVENT_900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_EVENT_900 .

  GO_GRID_900_T->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  GO_GRID_900_B->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).

  DATA(LT_LVC_T_F4) = VALUE LVC_T_F4( ( FIELDNAME = 'MATKL' REGISTER = ABAP_TRUE ) ).
  CALL METHOD GO_GRID_900_T->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_LVC_T_F4.

  CREATE OBJECT GCL_EVENT_900_T.
  CREATE OBJECT GCL_EVENT_900_B.

  SET HANDLER:
    GCL_EVENT_900_T->HANDLE_DOUBLE_CLICK FOR GO_GRID_900_T,
    GCL_EVENT_900_T->HANDLE_TOOLBAR FOR GO_GRID_900_T,
    GCL_EVENT_900_T->HANDLE_USER_COMMAND FOR GO_GRID_900_T,
    GCL_EVENT_900_T->HANDLE_DATA_CHANGED_FINISHED FOR GO_GRID_900_T,
    GCL_EVENT_900_T->HANDLE_ON_F4 FOR GO_GRID_900_T.

  SET HANDLER:
    GCL_EVENT_900_B->HANDLE_TOOLBAR FOR GO_GRID_900_B,
    GCL_EVENT_900_B->HANDLE_USER_COMMAND FOR GO_GRID_900_B,
    GCL_EVENT_900_B->HANDLE_DATA_CHANGED_FINISHED FOR GO_GRID_900_B.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_TOOLBAR_900_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&---------------------------------------------------------------------*
FORM F_TOOLBAR_900_T  USING  PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

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

  _SET_TBAR 3 SPACE SPACE SPACE.
  _SET_TBAR 0 'INSR'  ICON_INSERT_ROW   TEXT-BT4.
  _SET_TBAR 0 'DELE' ICON_DELETE_ROW  TEXT-BT2.
  _SET_TBAR 0 'SAVE' ICON_SYSTEM_SAVE TEXT-BT3.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_USER_COMMAND_900_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_900_T  USING PV_UCOMM TYPE SY-UCOMM.

  CASE PV_UCOMM.
    WHEN 'INSR'. "행 추가
      PERFORM F_INSERT_ROW_900_T.
    WHEN 'DELE'. "행 삭제
      PERFORM F_DELETE_ROW_900_T.
    WHEN 'SAVE'.
      PERFORM F_SAVE_DATA_900_T.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED_FIN_900_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED_FIN_900_T  USING    PV_MODIFIED TYPE CHAR01
                                     PT_GOOD_CELLS TYPE LVC_T_MODI.

  CHECK PV_MODIFIED EQ ABAP_TRUE.

  "데이터 점검
  DATA:
    LT_KEY  TYPE TY_T_MRO1_KEY,
    LT_TEXT TYPE TY_T_MRO1_TEXT,
    LT_MRO2 TYPE STANDARD TABLE OF TY_MRO2.

  LOOP AT PT_GOOD_CELLS ASSIGNING FIELD-SYMBOL(<LS_MODI>).
    CASE <LS_MODI>-FIELDNAME.
      WHEN 'MRO_TYPE1'.
        READ TABLE GT_MRO1 ASSIGNING FIELD-SYMBOL(<LS_CONV>) INDEX <LS_MODI>-ROW_ID.
        CHECK SY-SUBRC EQ 0.
        <LS_CONV>-MRO_TYPE1 = |{ <LS_CONV>-MRO_TYPE1 ALPHA = IN }|.
    ENDCASE.
  ENDLOOP.


  SELECT
    ZZ~MRO_TYPE1
    FROM @GT_MRO1 AS ZZ
    GROUP BY ZZ~MRO_TYPE1
    HAVING SUM( 1 ) GT 1
    ORDER BY ZZ~MRO_TYPE1
    INTO TABLE @LT_KEY.

  SELECT
    ZZ~MRO_TEXT1
    FROM @GT_MRO1 AS ZZ
    GROUP BY ZZ~MRO_TEXT1
    HAVING SUM( 1 ) GT 1
    ORDER BY ZZ~MRO_TEXT1
    INTO TABLE @LT_TEXT.

  SELECT DISTINCT
    Z1~MRO_TYPE1
    FROM ZGTMMT1122 AS Z1
    WHERE Z1~BUKRS EQ @P_BUKRS
    AND EXISTS (
      SELECT @ABAP_TRUE
        FROM @GT_MRO1 AS ZZ
        WHERE ZZ~BUKRS EQ Z1~BUKRS
          AND ZZ~MRO_TYPE1 EQ Z1~MRO_TYPE1
    )
    ORDER BY Z1~MRO_TYPE1
    INTO CORRESPONDING FIELDS OF TABLE @LT_MRO2.

  LOOP AT PT_GOOD_CELLS ASSIGNING  FIELD-SYMBOL(<LS_G0>)
                                                                GROUP BY ( ROW_ID = <LS_G0>-ROW_ID )
                                                                ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    READ TABLE GT_MRO1 ASSIGNING FIELD-SYMBOL(<LS_MRO1>) INDEX <LS_GROUP>-ROW_ID.
    CHECK SY-SUBRC EQ 0.


    "상태 설정
    IF <LS_MRO1>-ZNEW EQ SPACE.
      <LS_MRO1>-ZSTAT = ICON_CHANGE.
    ELSE.
      <LS_MRO1>-ZSTAT = ICON_CREATE.
    ENDIF.

    <LS_MRO1>-ZCHG = ABAP_TRUE.

    LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_CELLS>).
      CASE <LS_CELLS>-FIELDNAME.
        WHEN 'MATKL'. "자재그룹
          CLEAR <LS_MRO1>-WGBEZ.
          READ TABLE GT_T023T ASSIGNING FIELD-SYMBOL(<LS_T023T>) WITH KEY MATKL = <LS_MRO1>-MATKL BINARY SEARCH.
          IF SY-SUBRC EQ 0.
            <LS_MRO1>-WGBEZ = <LS_T023T>-WGBEZ.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    "라인별 점검
    PERFORM F_CHECK_LINE_DATA_MRO1 USING LT_KEY LT_TEXT LT_MRO2 CHANGING <LS_MRO1>.

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_900_T.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_INSERT_ROW_900_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_INSERT_ROW_900_T .

  DATA LV_CHECK TYPE C LENGTH 1.
  CALL METHOD GO_GRID_900_T->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.
  DATA LS_MRO1 TYPE TY_MRO1.
  LS_MRO1-ZSTAT = ICON_CREATE.
  LS_MRO1-BUKRS = P_BUKRS.
  LS_MRO1-ZNEW = ABAP_TRUE.
  LS_MRO1-ZCHG = ABAP_TRUE.

  "데이터 점검
  DATA:
    LT_KEY  TYPE TY_T_MRO1_KEY,
    LT_TEXT TYPE TY_T_MRO1_TEXT,
    LT_MRO2 TYPE STANDARD TABLE OF TY_MRO2.

  PERFORM F_CHECK_LINE_DATA_MRO1 USING LT_KEY LT_TEXT LT_MRO2 CHANGING LS_MRO1.

  "라인 추가
  APPEND LS_MRO1 TO GT_MRO1.

  "Refresh
  PERFORM F_REFRESH_ALV USING GO_GRID_900_T.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DELETE_ROW_900_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DELETE_ROW_900_T .

  DATA:
    LV_ROW_ID  TYPE INT4,
    LV_DEL_CNT TYPE INT4,
    LV_CHECK   TYPE C LENGTH 1,
    LT_ROW_ID  TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_900_T->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_900_T->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_ID.

  DELETE LT_ROW_ID WHERE ROW_ID LE 0.
  CHECK LT_ROW_ID[] IS NOT INITIAL.


  CLEAR LV_CHECK.
  LOOP AT LT_ROW_ID ASSIGNING FIELD-SYMBOL(<LS_ROW_ID>).
    READ TABLE GT_MRO1 ASSIGNING FIELD-SYMBOL(<LS_MRO1>) INDEX <LS_ROW_ID>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

*체크 로직  "각 테이블의 CHECK_MAT 필드 NULL 인경우만 가능
*삭제할 LINE의 분류와 동일한 자재가 하나도 없어야 삭제 가능
*--> CHECK_MAT 필드 NULL 인경우만 가능
*
*CHECK_MAT = 'X'인데 삭제대상에 들어간 경우 하단 메시지 출력, 삭제 상태값 마킹하지 않음"      """자재가 존재하는 분류는 삭제할 수 없습니다.""
*TYPE S DISPLAY LIKE E"
    IF <LS_MRO1>-CHECK_MAT EQ ABAP_TRUE.
      MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E05. "자재가 존재하는 분류는 삭제할 수 없습니다.
      LV_CHECK = GC_E.
      EXIT.
    ENDIF.
  ENDLOOP.

  CHECK LV_CHECK EQ SPACE. "오류가 없는 경우 진행

  CLEAR LV_CHECK.
  LOOP AT LT_ROW_ID ASSIGNING <LS_ROW_ID>.
    LV_ROW_ID = <LS_ROW_ID>-ROW_ID - LV_DEL_CNT.
    READ TABLE GT_MRO1 ASSIGNING <LS_MRO1> INDEX LV_ROW_ID.
    CHECK SY-SUBRC EQ 0.

    IF <LS_MRO1>-ZNEW EQ ABAP_TRUE.
      DELETE GT_MRO1 INDEX LV_ROW_ID.
      LV_DEL_CNT += 1.
      CONTINUE.
    ELSE.
      <LS_MRO1>-ZSTAT = ICON_DELETE.
      <LS_MRO1>-ZCHG = ABAP_TRUE.
    ENDIF.

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_900_T.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE_DATA_900_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SAVE_DATA_900_T .

  DATA:
    LV_ROW_ID TYPE INT4,
    LV_CHECK  TYPE C LENGTH 1.

  CALL METHOD GO_GRID_900_T->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  "변경 건이 없으면 메시지 출력
  SELECT SINGLE @ABAP_TRUE
    FROM @GT_MRO1 AS ZZ
    WHERE ZZ~ZCHG EQ @ABAP_TRUE "변경 건
    INTO @DATA(LV_CHG).
  IF SY-SUBRC NE 0.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E08. "저장 대상이 없습니다.
    EXIT.
  ENDIF.

*"STATUS 빨간불 없는 경우 POPUP TO CONFIRM 후 DB 반영
*(빨간불 있는 경우 메시지 출력)"
*"""오류가 존재하여 저장할 수 없습니다.""
*TYPE S DISPLAY LIKE E"

  SELECT SINGLE @ABAP_TRUE
    FROM @GT_MRO1 AS ZZ
    WHERE ZZ~ZCHG EQ @ABAP_TRUE "변경 건 중
    AND ZZ~STATUS EQ @ICON_LED_RED "오류 아이콘인 데이터가 존재
    INTO @DATA(LV_CHK).
  IF SY-SUBRC EQ 0.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E06.
    EXIT.
  ENDIF.

*GT_MRO1  "MODIFY ZGTMMT1121
*DELETE ZGTMMT1121, ZGTMMT1122
*(ZGTMMT1122는 회사코드, MRO_TYPE1기준으로 DELETE)
*-> 삭제 마킹 있는 경우 붉은색으로 표시한 메시지 추가"     """변경 내용을 저장 하시겠습니까?
*(대분류를 삭제할 경우 하위 중분류도 모두 삭제됩니다.)"""

  DATA:
    LV_ANS  TYPE C LENGTH 1,
    LV_TEXT TYPE STRING.

  LV_TEXT = TEXT-Q01. "변경 내용을 저장 하시겠습니까?
  SELECT SINGLE @ABAP_TRUE
    FROM @GT_MRO1 AS ZZ
    WHERE ZZ~ZCHG EQ @ABAP_TRUE "변경 건 중
    AND ZZ~ZSTAT EQ @ICON_DELETE "삭제 마킹인 데이터
    INTO @DATA(LV_DEL).
  IF SY-SUBRC EQ 0.
    LV_TEXT = |{ LV_TEXT } { TEXT-Q02 }|.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1 "확인
      TEXT_QUESTION = LV_TEXT
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

  DATA:
    LT_MOD TYPE STANDARD TABLE OF ZGTMMT1121,
    LT_DEL TYPE STANDARD TABLE OF ZGTMMT1121.

  LOOP AT GT_MRO1 ASSIGNING FIELD-SYMBOL(<LS_MRO1>).
    CHECK <LS_MRO1>-ZCHG EQ ABAP_TRUE.
    CASE <LS_MRO1>-ZSTAT.
      WHEN ICON_DELETE. "삭제
        LT_DEL = VALUE #( BASE LT_DEL ( CORRESPONDING #( <LS_MRO1> ) ) ).
      WHEN ICON_CREATE OR ICON_CHANGE. "신규/수정
        LT_MOD = VALUE #( BASE LT_MOD ( CORRESPONDING #( <LS_MRO1> ) ) ).
    ENDCASE.
  ENDLOOP.

  IF LT_DEL[] IS NOT INITIAL.
    DELETE ZGTMMT1121 FROM TABLE LT_DEL.

    DELETE FROM ZGTMMT1122 WHERE EXISTS (
      SELECT @ABAP_TRUE
        FROM @LT_DEL AS ZZ
        WHERE ZZ~BUKRS EQ ZGTMMT1122~BUKRS
          AND ZZ~MRO_TYPE1 EQ ZGTMMT1122~MRO_TYPE1
    ).
  ENDIF.

  IF LT_MOD[] IS NOT INITIAL.
    SELECT
      Z1~BUKRS,
      Z1~MRO_TYPE1,
      Z1~ERDAT,
      Z1~ERDAT_LOCAL,
      Z1~ERTIM,
      Z1~ERTIM_LOCAL,
      Z1~ERNAM
      FROM ZGTMMT1121 AS Z1
      WHERE EXISTS (
        SELECT @ABAP_TRUE
          FROM @LT_MOD AS ZZ
          WHERE ZZ~BUKRS EQ Z1~BUKRS
            AND ZZ~MRO_TYPE1 EQ Z1~MRO_TYPE1
      )
      ORDER BY Z1~BUKRS, Z1~MRO_TYPE1
      INTO TABLE @DATA(LT_ORG).

    LOOP AT LT_MOD ASSIGNING FIELD-SYMBOL(<LS_MOD>).
      <LS_MOD>-AEDAT = SY-DATUM.
      <LS_MOD>-AEDAT_LOCAL = SY-DATLO.
      <LS_MOD>-AETIM = SY-UZEIT.
      <LS_MOD>-AETIM_LOCAL = SY-TIMLO.
      <LS_MOD>-AENAM = SY-UNAME.
      READ TABLE LT_ORG ASSIGNING FIELD-SYMBOL(<LS_ORG>) WITH KEY BUKRS = <LS_MOD>-BUKRS
                                                                                                                  MRO_TYPE1 = <LS_MOD>-MRO_TYPE1 BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        <LS_MOD> = CORRESPONDING #( BASE ( <LS_MOD> ) <LS_ORG> ).
      ELSE.
        <LS_MOD>-ERDAT = SY-DATUM.
        <LS_MOD>-ERDAT_LOCAL = SY-DATLO.
        <LS_MOD>-ERTIM = SY-UZEIT.
        <LS_MOD>-ERTIM_LOCAL = SY-TIMLO.
        <LS_MOD>-ERNAM = SY-UNAME.
      ENDIF.
    ENDLOOP.

    MODIFY ZGTMMT1121 FROM TABLE LT_MOD.
  ENDIF.

  COMMIT WORK.

  LOOP AT GT_MRO1 ASSIGNING <LS_MRO1>.
    CHECK <LS_MRO1>-ZCHG EQ ABAP_TRUE.
    CASE <LS_MRO1>-ZSTAT.
      WHEN ICON_DELETE. "삭제
        IF <LS_MRO1>-MRO_TYPE1 EQ GS_MRO1-MRO_TYPE1.
          DELETE GT_MRO2 WHERE MRO_TYPE1 EQ <LS_MRO1>-MRO_TYPE1.
          CLEAR GS_MRO1.
        ENDIF.
        DELETE GT_MRO1.
        CONTINUE.
      WHEN ICON_CREATE OR ICON_CHANGE. "신규/수정

        IF <LS_MRO1>-ZSTAT EQ ICON_CREATE.
          <LS_MRO1>-ZSTYLE = VALUE #( ( FIELDNAME = 'MRO_TYPE1' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                                                   ( FIELDNAME = 'MATKL' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )  ).
        ENDIF.

        "초기화
        CLEAR:
          <LS_MRO1>-ZSTAT,
          <LS_MRO1>-ZNEW,
          <LS_MRO1>-ZCHG.

    ENDCASE.
  ENDLOOP.

  "중분류 ALV 타이틀 설정
  PERFORM F_SET_ALV_TITLE_900_B.

  PERFORM F_REFRESH_ALV USING GO_GRID_900_T.
  PERFORM F_REFRESH_ALV USING GO_GRID_900_B.

*	실패: TYPE S DISPLAY LIKE E 저장에 실패했습니다.
*	성공: TYPE S 저장에 성공했습니다.
  MESSAGE S000 WITH TEXT-M01.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ON_F4_900_T
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
FORM F_ON_F4_900_T  USING  PV_FIELDNAME
                 PV_FIELDVALUE
                 PS_ROW_NO     TYPE LVC_S_ROID
                 PO_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                 PT_BAD_CELLS  TYPE LVC_T_MODI
                 PV_DISPLAY.

  FIELD-SYMBOLS <LS_MODI> TYPE LVC_T_MODI.
  DATA : LT_RETURN TYPE TABLE OF DDSHRETVAL.

  PO_EVENT_DATA->M_EVENT_HANDLED = ABAP_TRUE.

  CASE PV_FIELDNAME.
    WHEN 'MATKL'.
*"서치헬프 설정
*- T023T에서 MATKL LIKE 'M0%' 조건"

      SELECT
        ZZ~MATKL,
        ZZ~WGBEZ
        FROM T023T AS ZZ
        WHERE ZZ~MATKL LIKE 'M0%'
        AND ZZ~SPRAS EQ @SY-LANGU
        ORDER BY ZZ~MATKL
        INTO TABLE @DATA(LT_T023T).

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          RETFIELD   = 'MATKL'
          DYNPPROG   = SY-REPID
          DYNPNR     = SY-DYNNR
          VALUE_ORG  = GC_S
        TABLES
          VALUE_TAB  = LT_T023T
          RETURN_TAB = LT_RETURN.

      CHECK LT_RETURN IS NOT INITIAL.

      ASSIGN PO_EVENT_DATA->M_DATA->* TO <LS_MODI>.

      READ TABLE LT_RETURN INTO DATA(LS_RETURN) INDEX 1.
      DATA(LS_MODI) = VALUE LVC_S_MODI( ROW_ID    = PS_ROW_NO-ROW_ID
                                        FIELDNAME = 'MATKL'
                                        VALUE     = LS_RETURN-FIELDVAL ).

      APPEND LS_MODI TO <LS_MODI>.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DOUBLE_CLICK_900_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_ROW_NO_ROW_ID
*&---------------------------------------------------------------------*
FORM F_DOUBLE_CLICK_900_T  USING  PV_ROW_ID.

  CHECK PV_ROW_ID GT 0.

  READ TABLE GT_MRO1 ASSIGNING FIELD-SYMBOL(<LS_MRO1>) INDEX PV_ROW_ID.
  CHECK SY-SUBRC EQ 0.

  "저장 하기 전에 더블클릭 해서 진행 할 수 없음
  IF <LS_MRO1>-ZNEW EQ ABAP_TRUE.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E07.
    EXIT.
  ENDIF.

*  저장되지 않은 중분류가 있습니다. 계속 진행하시겠습니까?
*
  DATA LV_ANS TYPE C LENGTH 1.
  SELECT SINGLE @ABAP_TRUE
    FROM @GT_MRO2 AS ZZ
    WHERE ZZ~ZCHG EQ @ABAP_TRUE
    INTO @DATA(LV_CHK).

  IF LV_CHK EQ ABAP_TRUE.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR      = TEXT-TT1 "확인
        TEXT_QUESTION = TEXT-Q03
      IMPORTING
        ANSWER        = LV_ANS.
    CHECK LV_ANS EQ GC_1.
  ENDIF.

  "기존 데이터 조회
  PERFORM F_GET_DATA_MRO2 USING <LS_MRO1>.

  "중분류 자재 점검
  PERFORM F_CHECK_MAT_MRO2.

  "ALV Title 설정
  PERFORM F_SET_ALV_TITLE_900_B.

  "ALV Refresh
  PERFORM F_REFRESH_ALV USING GO_GRID_900_B.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_USER_COMMAND_900_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_900_B  USING PV_UCOMM TYPE SY-UCOMM.

  CASE PV_UCOMM.
    WHEN 'INSR'. "행 추가
      PERFORM F_INSERT_ROW_900_B.
    WHEN 'DELE'. "행 삭제
      PERFORM F_DELETE_ROW_900_B.
    WHEN 'SAVE'.
      PERFORM F_SAVE_DATA_900_B.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_INSERT_ROW_900_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_INSERT_ROW_900_B .

  DATA LV_CHECK TYPE C LENGTH 1.

  CALL METHOD GO_GRID_900_T->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_900_B->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE
  AND GS_MRO1 IS NOT INITIAL.


  DATA LS_MRO2 TYPE TY_MRO2.
  LS_MRO2-ZSTAT = ICON_CREATE.
  LS_MRO2-BUKRS = GS_MRO1-BUKRS.
  LS_MRO2-MRO_TYPE1 = GS_MRO1-MRO_TYPE1.
  LS_MRO2-MRO_TEXT1 = GS_MRO1-MRO_TEXT1.
  LS_MRO2-ZNEW = ABAP_TRUE.
  LS_MRO2-ZCHG = ABAP_TRUE.

  "데이터 점검
  DATA:
    LT_KEY  TYPE TY_T_MRO2_KEY,
    LT_TEXT TYPE TY_T_MRO2_TEXT.

  PERFORM F_CHECK_LINE_DATA_MRO2 USING LT_KEY LT_TEXT CHANGING LS_MRO2.

  "라인 추가
  APPEND LS_MRO2 TO GT_MRO2.

  "Refresh
  PERFORM F_REFRESH_ALV USING GO_GRID_900_B.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DELETE_ROW_900_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DELETE_ROW_900_B .

  DATA:
    LV_ROW_ID  TYPE INT4,
    LV_DEL_CNT TYPE INT4,
    LV_CHECK   TYPE C LENGTH 1,
    LT_ROW_ID  TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_900_B->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_900_B->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_ID.

  DELETE LT_ROW_ID WHERE ROW_ID LE 0.
  CHECK LT_ROW_ID[] IS NOT INITIAL.


  CLEAR LV_CHECK.
  LOOP AT LT_ROW_ID ASSIGNING FIELD-SYMBOL(<LS_ROW_ID>).
    READ TABLE GT_MRO2 ASSIGNING FIELD-SYMBOL(<LS_MRO2>) INDEX <LS_ROW_ID>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

*체크 로직  "각 테이블의 CHECK_MAT 필드 NULL 인경우만 가능
*삭제할 LINE의 분류와 동일한 자재가 하나도 없어야 삭제 가능
*--> CHECK_MAT 필드 NULL 인경우만 가능
*
*CHECK_MAT = 'X'인데 삭제대상에 들어간 경우 하단 메시지 출력, 삭제 상태값 마킹하지 않음"      """자재가 존재하는 분류는 삭제할 수 없습니다.""
*TYPE S DISPLAY LIKE E"
    IF <LS_MRO2>-CHECK_MAT EQ ABAP_TRUE.
      MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E05. "자재가 존재하는 분류는 삭제할 수 없습니다.
      LV_CHECK = GC_E.
      EXIT.
    ENDIF.
  ENDLOOP.

  CHECK LV_CHECK EQ SPACE. "오류가 없는 경우 진행

  CLEAR LV_CHECK.
  LOOP AT LT_ROW_ID ASSIGNING <LS_ROW_ID>.
    LV_ROW_ID = <LS_ROW_ID>-ROW_ID - LV_DEL_CNT.
    READ TABLE GT_MRO2 ASSIGNING <LS_MRO2> INDEX LV_ROW_ID.
    CHECK SY-SUBRC EQ 0.

    IF <LS_MRO2>-ZNEW EQ ABAP_TRUE.
      DELETE GT_MRO2 INDEX LV_ROW_ID.
      LV_DEL_CNT += 1.
      CONTINUE.
    ELSE.
      <LS_MRO2>-ZSTAT = ICON_DELETE.
      <LS_MRO2>-ZCHG = ABAP_TRUE.
    ENDIF.

  ENDLOOP.


  "ALV Refresh
  PERFORM F_REFRESH_ALV USING GO_GRID_900_B.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED_FIN_900_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED_FIN_900_B  USING    PV_MODIFIED TYPE CHAR01
                                     PT_GOOD_CELLS TYPE LVC_T_MODI.

  CHECK PV_MODIFIED EQ ABAP_TRUE.

  "데이터 점검
  DATA:
    LT_KEY  TYPE TY_T_MRO2_KEY,
    LT_TEXT TYPE TY_T_MRO2_TEXT.

  LOOP AT PT_GOOD_CELLS ASSIGNING FIELD-SYMBOL(<LS_MODI>).
    CASE <LS_MODI>-FIELDNAME.
      WHEN 'MRO_TYPE2'.
        READ TABLE GT_MRO2 ASSIGNING FIELD-SYMBOL(<LS_CONV>) INDEX <LS_MODI>-ROW_ID.
        CHECK SY-SUBRC EQ 0.
        <LS_CONV>-MRO_TYPE2 = |{ <LS_CONV>-MRO_TYPE2 ALPHA = IN }|.
    ENDCASE.
  ENDLOOP.


  SELECT
    ZZ~MRO_TYPE2
    FROM @GT_MRO2 AS ZZ
    GROUP BY ZZ~MRO_TYPE2
    HAVING SUM( 1 ) GT 1
    ORDER BY ZZ~MRO_TYPE2
    INTO TABLE @LT_KEY.

  SELECT
    ZZ~MRO_TEXT2
    FROM @GT_MRO2 AS ZZ
    GROUP BY ZZ~MRO_TEXT2
    HAVING SUM( 1 ) GT 1
    ORDER BY ZZ~MRO_TEXT2
    INTO TABLE @LT_TEXT.

  LOOP AT PT_GOOD_CELLS ASSIGNING  FIELD-SYMBOL(<LS_G0>)
                                                                GROUP BY ( ROW_ID = <LS_G0>-ROW_ID )
                                                                ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    READ TABLE GT_MRO2 ASSIGNING FIELD-SYMBOL(<LS_MRO2>) INDEX <LS_GROUP>-ROW_ID.
    CHECK SY-SUBRC EQ 0.


    "상태 설정
    IF <LS_MRO2>-ZNEW EQ SPACE.
      <LS_MRO2>-ZSTAT = ICON_CHANGE.
    ELSE.
      <LS_MRO2>-ZSTAT = ICON_CREATE.
    ENDIF.

    <LS_MRO2>-ZCHG = ABAP_TRUE.

    "라인별 점검
    PERFORM F_CHECK_LINE_DATA_MRO2 USING LT_KEY LT_TEXT CHANGING <LS_MRO2>.

  ENDLOOP.

  "ALV Refresh
  PERFORM F_REFRESH_ALV USING GO_GRID_900_B.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE_DATA_900_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SAVE_DATA_900_B .

  DATA:
    LV_ROW_ID TYPE INT4,
    LV_CHECK  TYPE C LENGTH 1.

  CALL METHOD GO_GRID_900_B->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  "변경 건이 없으면 메시지 출력
  SELECT SINGLE @ABAP_TRUE
    FROM @GT_MRO2 AS ZZ
    WHERE ZZ~ZCHG EQ @ABAP_TRUE "변경 건
    INTO @DATA(LV_CHG).
  IF SY-SUBRC NE 0.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E08. "저장 대상이 없습니다.
    EXIT.
  ENDIF.

*"STATUS 빨간불 없는 경우 POPUP TO CONFIRM 후 DB 반영
*(빨간불 있는 경우 메시지 출력)"
*"""오류가 존재하여 저장할 수 없습니다.""
*TYPE S DISPLAY LIKE E"

  SELECT SINGLE @ABAP_TRUE
    FROM @GT_MRO2 AS ZZ
    WHERE ZZ~ZCHG EQ @ABAP_TRUE "변경 건 중
    AND ZZ~STATUS EQ @ICON_LED_RED "오류 아이콘인 데이터가 존재
    INTO @DATA(LV_CHK).
  IF SY-SUBRC EQ 0.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E06.
    EXIT.
  ENDIF.

*GT_MRO2  MODIFY / DELETE ZGTMMT1122      "변경 내용을 저장 하시겠습니까?"
  DATA:
    LV_ANS  TYPE C LENGTH 1,
    LV_TEXT TYPE STRING.

  LV_TEXT = TEXT-Q01. "변경 내용을 저장 하시겠습니까?
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1 "확인
      TEXT_QUESTION = LV_TEXT
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

  DATA:
    LT_MOD TYPE STANDARD TABLE OF ZGTMMT1122,
    LT_DEL TYPE STANDARD TABLE OF ZGTMMT1122.

  LOOP AT GT_MRO2 ASSIGNING FIELD-SYMBOL(<LS_MRO2>).
    CHECK <LS_MRO2>-ZCHG EQ ABAP_TRUE.
    CASE <LS_MRO2>-ZSTAT.
      WHEN ICON_DELETE. "삭제
        LT_DEL = VALUE #( BASE LT_DEL ( CORRESPONDING #( <LS_MRO2> ) ) ).
      WHEN ICON_CREATE OR ICON_CHANGE. "신규/수정
        LT_MOD = VALUE #( BASE LT_MOD ( CORRESPONDING #( <LS_MRO2> ) ) ).
    ENDCASE.
  ENDLOOP.

  IF LT_DEL[] IS NOT INITIAL.
    DELETE ZGTMMT1122 FROM TABLE LT_DEL.
  ENDIF.

  IF LT_MOD[] IS NOT INITIAL.
    SELECT
      Z1~BUKRS,
      Z1~MRO_TYPE1,
      Z1~MRO_TYPE2,
      Z1~ERDAT,
      Z1~ERDAT_LOCAL,
      Z1~ERTIM,
      Z1~ERTIM_LOCAL,
      Z1~ERNAM
      FROM ZGTMMT1122 AS Z1
      WHERE EXISTS (
        SELECT @ABAP_TRUE
          FROM @LT_MOD AS ZZ
          WHERE ZZ~BUKRS EQ Z1~BUKRS
            AND ZZ~MRO_TYPE1 EQ Z1~MRO_TYPE1
            AND ZZ~MRO_TYPE2 EQ Z1~MRO_TYPE2
      )
      ORDER BY Z1~BUKRS, Z1~MRO_TYPE1, Z1~MRO_TYPE2
      INTO TABLE @DATA(LT_ORG).

    LOOP AT LT_MOD ASSIGNING FIELD-SYMBOL(<LS_MOD>).
      <LS_MOD>-AEDAT = SY-DATUM.
      <LS_MOD>-AEDAT_LOCAL = SY-DATLO.
      <LS_MOD>-AETIM = SY-UZEIT.
      <LS_MOD>-AETIM_LOCAL = SY-TIMLO.
      <LS_MOD>-AENAM = SY-UNAME.
      READ TABLE LT_ORG ASSIGNING FIELD-SYMBOL(<LS_ORG>) WITH KEY BUKRS = <LS_MOD>-BUKRS
                                                                                                                  MRO_TYPE1 = <LS_MOD>-MRO_TYPE1
                                                                                                                  MRO_TYPE2 = <LS_MOD>-MRO_TYPE2 BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        <LS_MOD> = CORRESPONDING #( BASE ( <LS_MOD> ) <LS_ORG> ).
      ELSE.
        <LS_MOD>-ERDAT = SY-DATUM.
        <LS_MOD>-ERDAT_LOCAL = SY-DATLO.
        <LS_MOD>-ERTIM = SY-UZEIT.
        <LS_MOD>-ERTIM_LOCAL = SY-TIMLO.
        <LS_MOD>-ERNAM = SY-UNAME.
      ENDIF.
    ENDLOOP.

    MODIFY ZGTMMT1122 FROM TABLE LT_MOD.
  ENDIF.

  COMMIT WORK.

  LOOP AT GT_MRO2 ASSIGNING <LS_MRO2>.
    CHECK <LS_MRO2>-ZCHG EQ ABAP_TRUE.
    CASE <LS_MRO2>-ZSTAT.
      WHEN ICON_DELETE. "삭제
        DELETE GT_MRO2.
        CONTINUE.
      WHEN ICON_CREATE OR ICON_CHANGE. "신규/수정

        IF <LS_MRO2>-ZSTAT EQ ICON_CREATE.
          <LS_MRO2>-ZSTYLE = VALUE #( ( FIELDNAME = 'MRO_TYPE2' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
        ENDIF.

        "초기화
        CLEAR:
          <LS_MRO2>-ZSTAT,
          <LS_MRO2>-ZNEW,
          <LS_MRO2>-ZCHG.

    ENDCASE.
  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_900_B.

  "대분류 점검 로직 실행
  READ TABLE GT_MRO1 ASSIGNING FIELD-SYMBOL(<LS_MRO1>) WITH KEY MRO_TYPE1 = GS_MRO1-MRO_TYPE1.
  IF SY-SUBRC EQ 0.
    "데이터 점검
    DATA:
      LT_KEY  TYPE TY_T_MRO1_KEY,
      LT_TEXT TYPE TY_T_MRO1_TEXT,
      LT_MRO2 TYPE STANDARD TABLE OF TY_MRO2.

    SELECT DISTINCT
      Z1~MRO_TYPE1
      FROM ZGTMMT1122 AS Z1
      WHERE Z1~BUKRS EQ @P_BUKRS
      AND EXISTS (
        SELECT @ABAP_TRUE
          FROM @GT_MRO1 AS ZZ
          WHERE ZZ~BUKRS EQ Z1~BUKRS
            AND ZZ~MRO_TYPE1 EQ Z1~MRO_TYPE1
      )
      ORDER BY Z1~MRO_TYPE1
      INTO CORRESPONDING FIELDS OF TABLE @LT_MRO2.

    "점검
    PERFORM F_CHECK_LINE_DATA_MRO1 USING LT_KEY LT_TEXT LT_MRO2 CHANGING <LS_MRO1>.

    PERFORM F_REFRESH_ALV USING GO_GRID_900_T.

  ENDIF.

*	실패: TYPE S DISPLAY LIKE E 저장에 실패했습니다.
*	성공: TYPE S 저장에 성공했습니다.
  MESSAGE S000 WITH TEXT-M01.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_TITLE_900_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_TITLE_900_B .

  "Title 설정
  IF GS_MRO1 IS NOT INITIAL.
    GS_LAYO_900_B-GRID_TITLE = |{ TEXT-AT2 } ({ TEXT-AT1 }: { GS_MRO1-MRO_TYPE1 ALPHA = OUT } - { GS_MRO1-MRO_TEXT1 })|.
  ELSE.
    GS_LAYO_900_B-GRID_TITLE = TEXT-AT2.
  ENDIF.
  CALL METHOD GO_GRID_900_B->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO_900_B.

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

  DATA:
    LO_SPLIT  TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
    LO_CNTR_T TYPE REF TO CL_GUI_CONTAINER,
    LO_CNTR_B TYPE REF TO CL_GUI_CONTAINER.

  GO_CONT_100 = NEW #( CONTAINER_NAME = 'CON100' ).

  "Split Container
  LO_SPLIT = NEW #( PARENT  = GO_CONT_100
                    ROWS    = 2
                    COLUMNS = 1 ).

  LO_CNTR_T = LO_SPLIT->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
  LO_CNTR_B = LO_SPLIT->GET_CONTAINER( ROW = 2 COLUMN = 1 ).

  "ALV Obj.
  GO_GRID_100_T = NEW #( I_PARENT = LO_CNTR_T ).
  GO_GRID_100_B = NEW #( I_PARENT = LO_CNTR_B ).

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
   GT_EXCL_100_T[],
   GT_EXCL_100_B[].

  GT_EXCL_100_T[] = GT_EXCL_100_B[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
                       ( CL_GUI_ALV_GRID=>MC_MB_EXPORT )
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
    GS_LAYO_100_T,
    GS_LAYO_100_B.

  GS_LAYO_100_T-SEL_MODE = GC_A.
  GS_LAYO_100_T-ZEBRA = SPACE.
  GS_LAYO_100_T-SMALLTITLE = ABAP_TRUE.
*  GS_LAYO_100_T-NO_ROWMOVE = ABAP_TRUE.
*  GS_LAYO_100_T-NO_ROWINS = ABAP_TRUE.
  GS_LAYO_100_T-ZEBRA = ABAP_TRUE.
  GS_LAYO_100_B = GS_LAYO_100_T.

  GS_LAYO_100_T-STYLEFNAME = 'ZSTYLE'.
  GS_LAYO_100_B-GRID_TITLE = TEXT-AT3. "비상비 자재 목록

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
    GS_VARI_100_T,
    GS_VARI_100_B.

  GS_VARI_100_T-REPORT = SY-REPID.
  GS_VARI_100_T-USERNAME = SY-UNAME.
  GS_VARI_100_T-HANDLE = 'A10T'.

  GS_VARI_100_B-REPORT = SY-REPID.
  GS_VARI_100_B-USERNAME = SY-UNAME.
  GS_VARI_100_B-HANDLE = 'A10B'.

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

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_CREATE CHANGING GT_FCAT_100_T.
  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_SEARCH CHANGING GT_FCAT_100_B.

  PERFORM F_ADJ_FCAT_100_T.
  PERFORM F_ADJ_FCAT_100_B.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_100_T .

  LOOP AT GT_FCAT_100_T ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.

      WHEN 'STATUS'. ""점검
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 5.
      WHEN 'RESULT'. ""결과
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 5.
      WHEN 'BUKRS'. ""회사코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1122'.
        <LS_FCAT>-REF_FIELD = 'BUKRS'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'MATNR'. ""자재 번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'MARA'.
        <LS_FCAT>-REF_FIELD = 'MATNR'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-OUTPUTLEN = 18.
      WHEN 'MAKTX'. ""자재 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'MAKT'.
        <LS_FCAT>-REF_FIELD = 'MAKTX'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'MEINS'. ""단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'MARA'.
        <LS_FCAT>-REF_FIELD = 'MEINS'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'MRO_TYPE1'. ""대분류
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1122'.
        <LS_FCAT>-REF_FIELD = 'MRO_TYPE1'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-NO_CONVEXT = ABAP_TRUE.
      WHEN 'MRO_TEXT1'. ""대분류명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1121'.
        <LS_FCAT>-REF_FIELD = 'MRO_TEXT1'.
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'MRO_TYPE2'. ""중분류
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1122'.
        <LS_FCAT>-REF_FIELD = 'MRO_TYPE2'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-NO_CONVEXT = ABAP_TRUE.
      WHEN 'MRO_TEXT2'. ""중분류명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1122'.
        <LS_FCAT>-REF_FIELD = 'MRO_TEXT2'.
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'MATKL'. ""자재그룹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'WGBEZ'. ""자재그룹명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'VIEW_BASIC'. ""기본
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>."
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'VIEW_ETC'. ""확장
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'SAVE'. ""저장
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>."
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = 7.

      WHEN 'MESSAGE'. ""메시지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 40.
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    "수정 가능
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'MAKTX' OR 'MEINS' OR 'MRO_TYPE1' OR 'MRO_TYPE2' .
        <LS_FCAT>-EDIT = ABAP_TRUE.
    ENDCASE.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ADJ_FCAT_100_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_ADJ_FCAT_100_B .

  LOOP AT GT_FCAT_100_B ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'BUKRS'. ""회사코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'MATNR'. ""자재 번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'MARA'.
        <LS_FCAT>-REF_TABLE = 'MATNR'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-OUTPUTLEN = 18.
      WHEN 'MAKTX'. ""자재 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'MAKT'.
        <LS_FCAT>-REF_TABLE = 'MAKTX'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'MEINS'. ""단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'MARA'.
        <LS_FCAT>-REF_TABLE = 'MEINS'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'MRO_TYPE1'. ""대분류
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1122'.
        <LS_FCAT>-REF_FIELD = 'MRO_TYPE1'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-NO_CONVEXT = ABAP_TRUE.
      WHEN 'MRO_TEXT1'. ""대분류명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1122'.
        <LS_FCAT>-REF_FIELD = 'MRO_TEXT1'.
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'MRO_TYPE2'. ""중분류
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1122'.
        <LS_FCAT>-REF_FIELD = 'MRO_TYPE2'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-NO_CONVEXT = ABAP_TRUE.
      WHEN 'MRO_TEXT2'. ""중분류명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1122'.
        <LS_FCAT>-REF_FIELD = 'MRO_TEXT2'.
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'MATKL'. ""자재그룹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'WGBEZ'. ""자재그룹명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

  ENDLOOP.

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

  GO_GRID_100_T->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).

  CREATE OBJECT GCL_EVENT_100_T.
  CREATE OBJECT GCL_EVENT_100_B.

  SET HANDLER:
    GCL_EVENT_100_T->HANDLE_DATA_CHANGED FOR GO_GRID_100_T,
    GCL_EVENT_100_T->HANDLE_TOOLBAR FOR GO_GRID_100_T,
    GCL_EVENT_100_T->HANDLE_USER_COMMAND FOR GO_GRID_100_T,
    GCL_EVENT_100_T->HANDLE_DATA_CHANGED_FINISHED FOR GO_GRID_100_T.

  SET HANDLER:
    GCL_EVENT_100_B->HANDLE_TOOLBAR FOR GO_GRID_100_B,
    GCL_EVENT_100_B->HANDLE_USER_COMMAND FOR GO_GRID_100_B.

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

  CALL METHOD GO_GRID_100_T->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_100_T
      IT_TOOLBAR_EXCLUDING = GT_EXCL_100_T[]
      IS_VARIANT           = GS_VARI_100_T
      I_SAVE               = GV_ASAVE_100_T
    CHANGING
      IT_OUTTAB            = GT_CREATE[]
      IT_FIELDCATALOG      = GT_FCAT_100_T[]
      IT_SORT              = GT_SORT_100_T[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD GO_GRID_100_B->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYO_100_B
      IT_TOOLBAR_EXCLUDING = GT_EXCL_100_B[]
      IS_VARIANT           = GS_VARI_100_B
      I_SAVE               = GV_ASAVE_100_B
    CHANGING
      IT_OUTTAB            = GT_SEARCH[]
      IT_FIELDCATALOG      = GT_FCAT_100_B[]
      IT_SORT              = GT_SORT_100_B[]
    EXCEPTIONS
      OTHERS               = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_TOOLBAR_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&---------------------------------------------------------------------*
FORM F_TOOLBAR_100_T  USING  PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

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

  _SET_TBAR 3 SPACE SPACE SPACE.
  _SET_TBAR 0 'INSR'  ICON_INSERT_ROW   TEXT-BT4.
  _SET_TBAR 0 'DELE' ICON_DELETE_ROW  TEXT-BT2.
  _SET_TBAR 3 SPACE SPACE SPACE.
  _SET_TBAR 0 'UNIT' ICON_CHANGE TEXT-BT5. "단위 일괄입력
  _SET_TBAR 0 'MROT' ICON_CHANGE TEXT-BT6. "대/중분류 일괄 입력


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_USER_COMMAND_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_100_T  USING PV_UCOMM TYPE SY-UCOMM.

  CASE PV_UCOMM.
    WHEN 'INSR'. "행 추가
      PERFORM F_INSERT_ROW_100_T.
    WHEN 'DELE'. "행 삭제
      PERFORM F_DELETE_ROW_100_T.
    WHEN 'UNIT'. "단위 일괄 입력
      PERFORM F_MASS_SET_UNIT_100_T.
    WHEN 'MROT'. "대/중분류 일괄 입력
      PERFORM F_MASS_SET_MRO_TYPE_100_T.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED_FIN_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED_FIN_100_T  USING    PV_MODIFIED TYPE CHAR01
                                     PT_GOOD_CELLS TYPE LVC_T_MODI.

  CHECK PV_MODIFIED EQ ABAP_TRUE.

  "데이터 점검
  DATA:
    LT_KEY_ALV  TYPE TY_T_CREA_KEY,
    LT_KEY_DB   TYPE TY_T_CREA_KEY,
    LT_TEXT_ALV TYPE TY_T_CREA_KEY,
    LT_TEXT_DB  TYPE TY_T_CREA_KEY.

  LOOP AT PT_GOOD_CELLS ASSIGNING FIELD-SYMBOL(<LS_MODI>).
    CASE <LS_MODI>-FIELDNAME.
      WHEN 'MRO_TYPE1' OR 'MRO_TYPE2'.
        READ TABLE GT_CREATE ASSIGNING FIELD-SYMBOL(<LS_CONV>) INDEX <LS_MODI>-ROW_ID.
        CHECK SY-SUBRC EQ 0.
        CASE <LS_MODI>-FIELDNAME.
          WHEN 'MRO_TYPE1'.
            <LS_CONV>-MRO_TYPE1 = |{ <LS_CONV>-MRO_TYPE1 ALPHA = IN }|.
          WHEN 'MRO_TYPE2'.
            <LS_CONV>-MRO_TYPE2 = |{ <LS_CONV>-MRO_TYPE2 ALPHA = IN }|.
        ENDCASE.
    ENDCASE.
  ENDLOOP.


  "GT_CREATE 내에서 MAKTX, MRO_TYPE1, MRO_TYPE2 동일
  SELECT
    ZZ~MAKTX,
    ZZ~MRO_TYPE1,
    ZZ~MRO_TYPE2
    FROM @GT_CREATE AS ZZ
    GROUP BY ZZ~MAKTX, ZZ~MRO_TYPE1, ZZ~MRO_TYPE2
    HAVING SUM( 1 ) GT 1
    ORDER BY ZZ~MAKTX, ZZ~MRO_TYPE1, ZZ~MRO_TYPE2
    INTO CORRESPONDING FIELDS OF TABLE @LT_KEY_ALV.

  "ZGTMMR1120에 대분류, 중분류, 자재내역 완전히 동일한 자재 있는 경우
  SELECT
    MT~MAKTX,
    Z1~MRO_TYPE1,
    Z1~MRO_TYPE2,
    Z1~MATNR
    FROM ZGTMMT1120 AS Z1
                INNER JOIN
              MAKT AS MT ON Z1~MATNR EQ MT~MATNR
                              AND MT~SPRAS EQ @SY-LANGU
    WHERE Z1~BUKRS EQ @P_BUKRS
    AND EXISTS (
      SELECT @ABAP_TRUE
        FROM @GT_CREATE AS ZZ
        WHERE ZZ~MAKTX EQ MT~MAKTX
            AND ZZ~MRO_TYPE1 EQ Z1~MRO_TYPE1
            AND ZZ~MRO_TYPE2 EQ Z1~MRO_TYPE2
    )
    ORDER BY MT~MAKTX, Z1~MRO_TYPE1, Z1~MRO_TYPE2
    INTO CORRESPONDING FIELDS OF TABLE @LT_KEY_DB.

  "GT_CREATE 내에서 MAKTX가 중복되는 경우
  SELECT
    ZZ~MAKTX
    FROM @GT_CREATE AS ZZ
    GROUP BY ZZ~MAKTX
    HAVING SUM( 1 ) GT 1
    ORDER BY ZZ~MAKTX
    INTO CORRESPONDING FIELDS OF TABLE @LT_TEXT_ALV.

  "자재-분류 매핑 테이블에 동일 자재내역 존재하는 경우
  SELECT
    MT~MAKTX,
    Z1~MATNR
    FROM ZGTMMT1120 AS Z1
                INNER JOIN
              MAKT AS MT ON Z1~MATNR EQ MT~MATNR
                              AND MT~SPRAS EQ @SY-LANGU
    WHERE Z1~BUKRS EQ @P_BUKRS
    AND EXISTS (
      SELECT @ABAP_TRUE
        FROM @GT_CREATE AS ZZ
        WHERE ZZ~MAKTX EQ MT~MAKTX
    )
    ORDER BY MT~MAKTX
    INTO CORRESPONDING FIELDS OF TABLE @LT_TEXT_DB.

  FIELD-SYMBOLS:
    <LS_MRO1> TYPE TY_MRO1,
    <LS_MRO2> TYPE TY_MRO2.

  LOOP AT PT_GOOD_CELLS ASSIGNING  FIELD-SYMBOL(<LS_G0>)
                                                                GROUP BY ( ROW_ID = <LS_G0>-ROW_ID )
                                                                ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    READ TABLE GT_CREATE ASSIGNING FIELD-SYMBOL(<LS_CREATE>) INDEX <LS_GROUP>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_CELLS>).
      CASE <LS_CELLS>-FIELDNAME.
        WHEN 'MRO_TYPE1'. "대분류

          CLEAR <LS_CREATE>-MRO_TEXT1.
          READ TABLE GT_MRO1 ASSIGNING <LS_MRO1> WITH KEY MRO_TYPE1 = <LS_CREATE>-MRO_TYPE1 BINARY SEARCH.
          IF SY-SUBRC EQ 0.
            <LS_CREATE>-MRO_TEXT1 = <LS_MRO1>-MRO_TEXT1.
            <LS_CREATE>-MATKL = <LS_MRO1>-MATKL.
            <LS_CREATE>-WGBEZ = <LS_MRO1>-WGBEZ.
          ENDIF.

          CLEAR:
            <LS_CREATE>-MRO_TEXT2.
          READ TABLE GT_MRO2 ASSIGNING <LS_MRO2> WITH KEY MRO_TYPE1 = <LS_CREATE>-MRO_TYPE1
                                                                                                 MRO_TYPE2 = <LS_CREATE>-MRO_TYPE2 BINARY SEARCH.
          IF SY-SUBRC EQ 0.
            <LS_CREATE>-MRO_TEXT2 = <LS_MRO2>-MRO_TEXT2.
          ENDIF.

        WHEN 'MRO_TYPE2'. "중분류
          CLEAR:
            <LS_CREATE>-MRO_TEXT2.
          READ TABLE GT_MRO2 ASSIGNING <LS_MRO2> WITH KEY MRO_TYPE1 = <LS_CREATE>-MRO_TYPE1
                                                                                                 MRO_TYPE2 = <LS_CREATE>-MRO_TYPE2 BINARY SEARCH.
          IF SY-SUBRC EQ 0.
            <LS_CREATE>-MRO_TEXT2 = <LS_MRO2>-MRO_TEXT2.
          ENDIF.

      ENDCASE.
    ENDLOOP.

    "라인별 점검
    PERFORM F_CHECK_LINE_DATA_CREATE USING LT_KEY_ALV LT_KEY_DB LT_TEXT_ALV LT_TEXT_DB CHANGING <LS_CREATE>.

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_100_T.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_ALV_MODIFY_CELL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID
*&      --> <LS_INS>_ROW_ID
*&      --> P_
*&      --> ABAP_TRUE
*&---------------------------------------------------------------------*
FORM F_ALV_MODIFY_CELL  USING   PO_CHANGE TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                 PV_ROW_ID
                                 PV_FNAME
                                 PV_FVALUE.

  CALL METHOD PO_CHANGE->MODIFY_CELL
    EXPORTING
      I_ROW_ID    = PV_ROW_ID
      I_FIELDNAME = PV_FNAME
      I_VALUE     = PV_FVALUE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DATA_CHANGED_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> E_ONF4_AFTER
*&---------------------------------------------------------------------*
FORM F_DATA_CHANGED_100_T  USING  PO_DATA_CHANGED
                                     TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                        PV_ONF4_AFTER .
  "신규
  LOOP AT PO_DATA_CHANGED->MT_INSERTED_ROWS ASSIGNING FIELD-SYMBOL(<LS_INS>).
    PERFORM F_ALV_MODIFY_CELL USING:
            PO_DATA_CHANGED <LS_INS>-ROW_ID 'BUKRS' P_BUKRS,
            PO_DATA_CHANGED <LS_INS>-ROW_ID 'ZNEW' ABAP_TRUE.
  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_INSERT_ROW_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_INSERT_ROW_100_T .

  DATA LV_CHECK TYPE C LENGTH 1.
  CALL METHOD GO_GRID_100_T->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.
  DATA LS_CREATE TYPE TY_CREATE.
  LS_CREATE-BUKRS = P_BUKRS.
  LS_CREATE-ZNEW = ABAP_TRUE.

  "데이터 점검
  DATA:
    LT_KEY_ALV  TYPE TY_T_CREA_KEY,
    LT_KEY_DB   TYPE TY_T_CREA_KEY,
    LT_TEXT_ALV TYPE TY_T_CREA_KEY,
    LT_TEXT_DB  TYPE TY_T_CREA_KEY.


  PERFORM F_CHECK_LINE_DATA_CREATE USING LT_KEY_ALV LT_KEY_DB LT_TEXT_ALV LT_TEXT_DB CHANGING LS_CREATE.

  "라인 추가
  APPEND LS_CREATE TO GT_CREATE.

  "Refresh
  PERFORM F_REFRESH_ALV USING GO_GRID_100_T.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DELETE_ROW_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DELETE_ROW_100_T .

  DATA:
    LV_ROW_ID  TYPE INT4,
    LV_DEL_CNT TYPE INT4,
    LV_CHECK   TYPE C LENGTH 1,
    LT_ROW_ID  TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_100_T->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_100_T->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_ID.

  DELETE LT_ROW_ID WHERE ROW_ID LE 0.
  CHECK LT_ROW_ID[] IS NOT INITIAL.

  CLEAR LV_CHECK.
  LOOP AT LT_ROW_ID ASSIGNING FIELD-SYMBOL(<LS_ROW_ID>).
    LV_ROW_ID = <LS_ROW_ID>-ROW_ID - LV_DEL_CNT.
    DELETE GT_CREATE INDEX LV_ROW_ID.
    LV_DEL_CNT += 1.
    CONTINUE.
  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_100_T.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_LINE_DATA_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_KEY_ALV
*&      --> LT_KEY_DB
*&      --> LT_TEXT_ALV
*&      --> LT_TEXT_DB
*&      <-- <LS_CREATE>
*&---------------------------------------------------------------------*
FORM F_CHECK_LINE_DATA_CREATE  USING    PT_KEY_ALV TYPE TY_T_CREA_KEY
                                        PT_KEY_DB TYPE TY_T_CREA_KEY
                                        PT_TEXT_ALV TYPE TY_T_CREA_KEY
                                        PT_TEXT_DB TYPE TY_T_CREA_KEY
                               CHANGING CS_CREATE TYPE TY_CREATE.
  DATA:
    LV_MATNR TYPE MATNR,
    LV_MSG   TYPE BAPI_MSG,
    LT_MSG   TYPE STANDARD TABLE OF TY_MSG_T.

*그 外
  CS_CREATE-STATUS = ICON_LED_GREEN.
  CS_CREATE-MESSAGE = SPACE.

* 누락
  CLEAR LV_MSG.

*자재내역   CS_CREATE-MAKTX IS INITIAL
  IF CS_CREATE-MAKTX IS INITIAL.
    CS_CREATE-STATUS = ICON_LED_RED.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }, { TEXT-H14 }|. ""자재내역
    ELSE.
      LV_MSG = TEXT-H14. "자재내역
    ENDIF.
  ENDIF.

*기본단위   CS_CREATE-MEINS IS INITIAL
  IF CS_CREATE-MEINS IS INITIAL.
    CS_CREATE-STATUS = ICON_LED_RED.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }, { TEXT-H15 }|. ""기본단위
    ELSE.
      LV_MSG = TEXT-H15. "기본단위
    ENDIF.
  ENDIF.

*대분류 누락             CS_CREATE-MRO_TYPE1 IS INITIAL      누락: 대분류
  IF CS_CREATE-MRO_TYPE1 IS INITIAL.
    CS_CREATE-STATUS = ICON_LED_RED.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }, { TEXT-H04 }|. ""대분류
    ELSE.
      LV_MSG = TEXT-H04. "대분류
    ENDIF.
  ENDIF.

*중분류 누락             CS_CREATE-MRO_TYPE2 IS INITIAL      누락: 중분류
  IF CS_CREATE-MRO_TYPE2 IS INITIAL.
    CS_CREATE-STATUS = ICON_LED_RED.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }, { TEXT-H10 }|. ""중분류
    ELSE.
      LV_MSG = TEXT-H10. "중분류
    ENDIF.
  ENDIF.

  IF LV_MSG IS NOT INITIAL.
    "누락:
    LV_MSG = |{ TEXT-E01 } { LV_MSG } |.
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = LV_MSG  ) ).
  ENDIF.

* 오류
  CLEAR LV_MSG.
*  대분류, 중분류   "아래 SELECT 결과값 없는 경우 오류
*(회사코드에 해당 대분류-중분류 조합이 없는 경우)
*
*SELECT SINGLE @ABAP_TRUE
*FROM ZGTMMT1122
*WHERE BUKRS = P_BUKRS
*AND MRO_TYPE1 = GT_CREATE-MRO_TYPE1
*AND MRO_TYPE2 = GT_CREATE-MRO_TYPE2"     오류: 대-중분류
  READ TABLE GT_MRO2 WITH KEY MRO_TYPE1 = CS_CREATE-MRO_TYPE1
                                          MRO_TYPE2 = CS_CREATE-MRO_TYPE2 BINARY SEARCH TRANSPORTING NO FIELDS.
  IF SY-SUBRC NE 0.
    CS_CREATE-STATUS = ICON_LED_RED.
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE =  |{ TEXT-E03 } { TEXT-E09 }| ) ).
  ENDIF.

* 중복
  CLEAR LV_MSG.
*ZGTMMR1120에 대분류, 중분류, 자재내역 완전히 동일한 자재 있는 경우
*  중복: 자재 (MATNR)
  READ TABLE PT_KEY_DB ASSIGNING FIELD-SYMBOL(<LS_KEY_DB>) WITH KEY MAKTX = CS_CREATE-MAKTX
                                                MRO_TYPE1 = CS_CREATE-MRO_TYPE1
                                                MRO_TYPE2 = CS_CREATE-MRO_TYPE2 BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    CS_CREATE-STATUS = ICON_LED_RED.
    LV_MATNR = CONDENSE( |{ <LS_KEY_DB>-MATNR ALPHA = OUT }| ).
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE =  |{ TEXT-E02 } { TEXT-H08 } ({ LV_MATNR })| ) ).
  ELSE.
*    GT_CREATE 내에서 MAKTX, MRO_TYPE1, MRO_TYPE2 동일 중복: 자재
    READ TABLE PT_KEY_ALV WITH KEY MAKTX = CS_CREATE-MAKTX
                                                MRO_TYPE1 = CS_CREATE-MRO_TYPE1
                                                MRO_TYPE2 = CS_CREATE-MRO_TYPE2 BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC EQ 0.
      CS_CREATE-STATUS = ICON_LED_RED.
      LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE =  |{ TEXT-E02 } { TEXT-H08 }| ) ).
    ELSE.
*      자재-분류 매핑 테이블에 동일 자재내역 존재하는 경우
*      아래 결과값 존재하는 경우
      READ TABLE PT_TEXT_DB ASSIGNING FIELD-SYMBOL(<LS_TEXT_DB>) WITH KEY MAKTX = CS_CREATE-MAKTX BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        IF CS_CREATE-STATUS NE ICON_LED_RED.
          CS_CREATE-STATUS = ICON_LED_YELLOW.
        ENDIF.

        LV_MATNR = CONDENSE( |{ <LS_TEXT_DB>-MATNR ALPHA = OUT }| ).
        LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE =  |{ TEXT-E02 } { TEXT-H14 } ({ LV_MATNR })| ) ).
      ELSE.
*      GT_CREATE 내에서 MAKTX가 중복되는 경우
        READ TABLE PT_TEXT_ALV WITH KEY MAKTX = CS_CREATE-MAKTX BINARY SEARCH TRANSPORTING NO FIELDS.
        IF SY-SUBRC EQ 0.
          IF CS_CREATE-STATUS NE ICON_LED_RED.
            CS_CREATE-STATUS = ICON_LED_YELLOW.
          ENDIF.
          LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE =  |{ TEXT-E02 } { TEXT-H14 }| ) ).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  "메세지 설정
  LOOP AT LT_MSG ASSIGNING FIELD-SYMBOL(<LS_MSG>).
    IF CS_CREATE-MESSAGE IS NOT INITIAL.
      CS_CREATE-MESSAGE = |{ CS_CREATE-MESSAGE }, { <LS_MSG>-MESSAGE }|.
    ELSE.
      CS_CREATE-MESSAGE = <LS_MSG>-MESSAGE.
    ENDIF.
  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_MASS_SET_UNIT_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_MASS_SET_UNIT_100_T .

  DATA:
    LV_CHECK  TYPE C LENGTH 1,
    LT_ROW_ID TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_100_T->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_100_T->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_ID.

  DELETE LT_ROW_ID WHERE ROW_ID LE 0.
  CHECK LT_ROW_ID[] IS NOT INITIAL.

  "초기화
  CLEAR GS_SCR_101.
  CALL SCREEN 101 STARTING AT 1 4.

  CHECK GS_SCR_101-ZOK EQ ABAP_TRUE.

  "데이터 점검
  DATA:
    LT_KEY_ALV  TYPE TY_T_CREA_KEY,
    LT_KEY_DB   TYPE TY_T_CREA_KEY,
    LT_TEXT_ALV TYPE TY_T_CREA_KEY,
    LT_TEXT_DB  TYPE TY_T_CREA_KEY.


  "GT_CREATE 내에서 MAKTX, MRO_TYPE1, MRO_TYPE2 동일
  SELECT
    ZZ~MAKTX,
    ZZ~MRO_TYPE1,
    ZZ~MRO_TYPE2
    FROM @GT_CREATE AS ZZ
    GROUP BY ZZ~MAKTX, ZZ~MRO_TYPE1, ZZ~MRO_TYPE2
    HAVING SUM( 1 ) GT 1
    ORDER BY ZZ~MAKTX, ZZ~MRO_TYPE1, ZZ~MRO_TYPE2
    INTO CORRESPONDING FIELDS OF TABLE @LT_KEY_ALV.

  "ZGTMMR1120에 대분류, 중분류, 자재내역 완전히 동일한 자재 있는 경우
  SELECT
    MT~MAKTX,
    Z1~MRO_TYPE1,
    Z1~MRO_TYPE2,
    Z1~MATNR
    FROM ZGTMMT1120 AS Z1
                INNER JOIN
              MAKT AS MT ON Z1~MATNR EQ MT~MATNR
                              AND MT~SPRAS EQ @SY-LANGU
    WHERE Z1~BUKRS EQ @P_BUKRS
    AND EXISTS (
      SELECT @ABAP_TRUE
        FROM @GT_CREATE AS ZZ
        WHERE ZZ~MAKTX EQ MT~MAKTX
            AND ZZ~MRO_TYPE1 EQ Z1~MRO_TYPE1
            AND ZZ~MRO_TYPE2 EQ Z1~MRO_TYPE2
    )
    ORDER BY MT~MAKTX, Z1~MRO_TYPE1, Z1~MRO_TYPE2
    INTO CORRESPONDING FIELDS OF TABLE @LT_KEY_DB.

  "GT_CREATE 내에서 MAKTX가 중복되는 경우
  SELECT
    ZZ~MAKTX
    FROM @GT_CREATE AS ZZ
    GROUP BY ZZ~MAKTX
    HAVING SUM( 1 ) GT 1
    ORDER BY ZZ~MAKTX
    INTO CORRESPONDING FIELDS OF TABLE @LT_TEXT_ALV.

  "자재-분류 매핑 테이블에 동일 자재내역 존재하는 경우
  SELECT
    MT~MAKTX,
    Z1~MATNR
    FROM ZGTMMT1120 AS Z1
                INNER JOIN
              MAKT AS MT ON Z1~MATNR EQ MT~MATNR
                              AND MT~SPRAS EQ @SY-LANGU
    WHERE Z1~BUKRS EQ @P_BUKRS
    AND EXISTS (
      SELECT @ABAP_TRUE
        FROM @GT_CREATE AS ZZ
        WHERE ZZ~MAKTX EQ MT~MAKTX
    )
    ORDER BY MT~MAKTX
    INTO CORRESPONDING FIELDS OF TABLE @LT_TEXT_DB.


  LOOP AT LT_ROW_ID ASSIGNING FIELD-SYMBOL(<LS_ROW_ID>).
    READ TABLE GT_CREATE ASSIGNING FIELD-SYMBOL(<LS_CREATE>) INDEX <LS_ROW_ID>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
    <LS_CREATE>-MEINS = GS_SCR_101-MEINS.

    "점검
    PERFORM F_CHECK_LINE_DATA_CREATE USING LT_KEY_ALV LT_KEY_DB LT_TEXT_ALV LT_TEXT_DB CHANGING <LS_CREATE>.
  ENDLOOP.

  "ALV Refresh
  PERFORM F_REFRESH_ALV USING GO_GRID_100_T.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_MASS_SET_MRO_TYPE_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_MASS_SET_MRO_TYPE_100_T .

  DATA:
    LV_CHECK  TYPE C LENGTH 1,
    LT_ROW_ID TYPE LVC_T_ROID.

  CALL METHOD GO_GRID_100_T->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_100_T->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_ID.

  DELETE LT_ROW_ID WHERE ROW_ID LE 0.
  CHECK LT_ROW_ID[] IS NOT INITIAL.

  "초기화
  CLEAR GS_SCR_102.
  GS_SCR_102-BUKRS = P_BUKRS.
  CALL SCREEN 102 STARTING AT 1 4.

  CHECK GS_SCR_102-ZOK EQ ABAP_TRUE.

  "데이터 점검
  DATA:
    LT_KEY_ALV  TYPE TY_T_CREA_KEY,
    LT_KEY_DB   TYPE TY_T_CREA_KEY,
    LT_TEXT_ALV TYPE TY_T_CREA_KEY,
    LT_TEXT_DB  TYPE TY_T_CREA_KEY.


  "GT_CREATE 내에서 MAKTX, MRO_TYPE1, MRO_TYPE2 동일
  SELECT
    ZZ~MAKTX,
    ZZ~MRO_TYPE1,
    ZZ~MRO_TYPE2
    FROM @GT_CREATE AS ZZ
    GROUP BY ZZ~MAKTX, ZZ~MRO_TYPE1, ZZ~MRO_TYPE2
    HAVING SUM( 1 ) GT 1
    ORDER BY ZZ~MAKTX, ZZ~MRO_TYPE1, ZZ~MRO_TYPE2
    INTO CORRESPONDING FIELDS OF TABLE @LT_KEY_ALV.

  "ZGTMMR1120에 대분류, 중분류, 자재내역 완전히 동일한 자재 있는 경우
  SELECT
    MT~MAKTX,
    Z1~MRO_TYPE1,
    Z1~MRO_TYPE2,
    Z1~MATNR
    FROM ZGTMMT1120 AS Z1
                INNER JOIN
              MAKT AS MT ON Z1~MATNR EQ MT~MATNR
                              AND MT~SPRAS EQ @SY-LANGU
    WHERE Z1~BUKRS EQ @P_BUKRS
    AND EXISTS (
      SELECT @ABAP_TRUE
        FROM @GT_CREATE AS ZZ
        WHERE ZZ~MAKTX EQ MT~MAKTX
            AND ZZ~MRO_TYPE1 EQ Z1~MRO_TYPE1
            AND ZZ~MRO_TYPE2 EQ Z1~MRO_TYPE2
    )
    ORDER BY MT~MAKTX, Z1~MRO_TYPE1, Z1~MRO_TYPE2
    INTO CORRESPONDING FIELDS OF TABLE @LT_KEY_DB.

  "GT_CREATE 내에서 MAKTX가 중복되는 경우
  SELECT
    ZZ~MAKTX
    FROM @GT_CREATE AS ZZ
    GROUP BY ZZ~MAKTX
    HAVING SUM( 1 ) GT 1
    ORDER BY ZZ~MAKTX
    INTO CORRESPONDING FIELDS OF TABLE @LT_TEXT_ALV.

  "자재-분류 매핑 테이블에 동일 자재내역 존재하는 경우
  SELECT
    MT~MAKTX,
    Z1~MATNR
    FROM ZGTMMT1120 AS Z1
                INNER JOIN
              MAKT AS MT ON Z1~MATNR EQ MT~MATNR
                              AND MT~SPRAS EQ @SY-LANGU
    WHERE Z1~BUKRS EQ @P_BUKRS
    AND EXISTS (
      SELECT @ABAP_TRUE
        FROM @GT_CREATE AS ZZ
        WHERE ZZ~MAKTX EQ MT~MAKTX
    )
    ORDER BY MT~MAKTX
    INTO CORRESPONDING FIELDS OF TABLE @LT_TEXT_DB.


  LOOP AT LT_ROW_ID ASSIGNING FIELD-SYMBOL(<LS_ROW_ID>).
    READ TABLE GT_CREATE ASSIGNING FIELD-SYMBOL(<LS_CREATE>) INDEX <LS_ROW_ID>-ROW_ID.
    CHECK SY-SUBRC EQ 0.
    <LS_CREATE>-MRO_TYPE1 = GS_SCR_102-MRO_TYPE1.
    <LS_CREATE>-MRO_TYPE2 = GS_SCR_102-MRO_TYPE2.

    CLEAR <LS_CREATE>-MRO_TEXT1.
    READ TABLE GT_MRO1 ASSIGNING FIELD-SYMBOL(<LS_MRO1>) WITH KEY MRO_TYPE1 = <LS_CREATE>-MRO_TYPE1 BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_CREATE>-MRO_TEXT1 = <LS_MRO1>-MRO_TEXT1.
      <LS_CREATE>-MATKL = <LS_MRO1>-MATKL.
      <LS_CREATE>-WGBEZ = <LS_MRO1>-WGBEZ.
    ENDIF.

    CLEAR:
      <LS_CREATE>-MRO_TEXT2.
    READ TABLE GT_MRO2 ASSIGNING FIELD-SYMBOL(<LS_MRO2>) WITH KEY MRO_TYPE1 = <LS_CREATE>-MRO_TYPE1
                                                                                           MRO_TYPE2 = <LS_CREATE>-MRO_TYPE2 BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_CREATE>-MRO_TEXT2 = <LS_MRO2>-MRO_TEXT2.
    ENDIF.

    "점검
    PERFORM F_CHECK_LINE_DATA_CREATE USING LT_KEY_ALV LT_KEY_DB LT_TEXT_ALV LT_TEXT_DB CHANGING <LS_CREATE>.
  ENDLOOP.

  "ALV Refresh
  PERFORM F_REFRESH_ALV USING GO_GRID_100_T.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_TOOLBAR_100_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&---------------------------------------------------------------------*
FORM F_TOOLBAR_100_B  USING  PR_OBJ TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

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

  _SET_TBAR 3 SPACE SPACE SPACE.
  _SET_TBAR 0 'SEAR'  ICON_SEARCH   TEXT-BT7.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_USER_COMMAND_100_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_100_B  USING PV_UCOMM TYPE SY-UCOMM.

  CASE PV_UCOMM.
    WHEN 'SEAR'. "검색
      PERFORM F_SEARCH_DATA_100_B.

  ENDCASE.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SEARCH_DATA_100_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SEARCH_DATA_100_B .

  CLEAR GS_SCR_103.
  CALL SCREEN 103 STARTING AT 1 4.
  CHECK GS_SCR_103-ZOK EQ ABAP_TRUE.

  "데이터 조회
  CLEAR GT_SEARCH[].

  SELECT
    Z1~BUKRS,
    Z1~MATNR,
    MT~MAKTX,
    MR~MEINS,
    Z1~MRO_TYPE1,
    Z2~MRO_TEXT1,
    Z1~MRO_TYPE2,
    Z3~MRO_TEXT2,
    Z2~MATKL,
    T1~WGBEZ
    FROM ZGTMMT1120 AS Z1
              INNER JOIN
           ZGTMMT1121 AS Z2 ON Z1~BUKRS EQ Z2~BUKRS
                                       AND Z1~MRO_TYPE1 EQ Z2~MRO_TYPE1
              INNER JOIN
           ZGTMMT1122 AS Z3 ON Z1~BUKRS EQ Z2~BUKRS
                                       AND Z1~MRO_TYPE1 EQ Z3~MRO_TYPE1
                                       AND Z1~MRO_TYPE2 EQ Z3~MRO_TYPE2
              INNER JOIN
           MARA AS MR ON Z1~MATNR EQ MR~MATNR
              INNER JOIN
           MAKT AS MT ON Z1~MATNR EQ MT~MATNR
                           AND MT~SPRAS EQ @SY-LANGU
              LEFT OUTER JOIN
           T023T AS T1 ON Z2~MATKL EQ T1~MATKL
                           AND T1~SPRAS EQ @SY-LANGU
    WHERE Z1~BUKRS EQ @P_1BUKRS
    AND Z1~MRO_TYPE1 IN @S_1MRO1
    AND Z1~MRO_TYPE2 IN @S_1MRO2
    AND Z2~MATKL IN @S_1MATKL
    AND Z1~MATNR IN @S_1MATNR
    AND MT~MAKTX IN @S_1MAKTX
    INTO CORRESPONDING FIELDS OF TABLE @GT_SEARCH.

  "ALV Refresh
  PERFORM F_REFRESH_ALV USING GO_GRID_100_B.

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
  CLEAR:
   GT_EXCL_200[].

  GT_EXCL_200[] = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO  )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE )
                       ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW )
                       ( CL_GUI_ALV_GRID=>MC_MB_EXPORT )
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

  CLEAR:
    GS_LAYO_200.

  GS_LAYO_200-SEL_MODE = GC_A.
  GS_LAYO_200-ZEBRA = SPACE.
  GS_LAYO_200-SMALLTITLE = ABAP_TRUE.
  GS_LAYO_200-STYLEFNAME = 'ZSTYLE'.
  GS_LAYO_200-NO_ROWMOVE = ABAP_TRUE.
  GS_LAYO_200-NO_ROWINS = ABAP_TRUE.


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
  CLEAR:
    GS_VARI_200.

  GS_VARI_200-REPORT = SY-REPID.
  GS_VARI_200-USERNAME = SY-UNAME.
  GS_VARI_200-HANDLE = 'A20T'.


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

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_DISP CHANGING GT_FCAT_200.
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

      WHEN 'STATUS'. ""점검
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 5.
      WHEN 'ZSTAT'. ""상태
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>."
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 5.
      WHEN 'BUKRS'. ""회사코드
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1122'.
        <LS_FCAT>-REF_FIELD = 'BUKRS'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'MATNR'. ""자재 번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'MARA'.
        <LS_FCAT>-REF_FIELD = 'MATNR'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-OUTPUTLEN = 18.
      WHEN 'MAKTX'. ""자재 내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'MAKT'.
        <LS_FCAT>-REF_FIELD = 'MAKTX'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'MEINS'. ""단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'MARA'.
        <LS_FCAT>-REF_FIELD = 'MEINS'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'MRO_TYPE1'. ""대분류
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1122'.
        <LS_FCAT>-REF_FIELD = 'MRO_TYPE1'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-NO_CONVEXT = ABAP_TRUE.
      WHEN 'MRO_TEXT1'. ""대분류명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>."
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1121'.
        <LS_FCAT>-REF_FIELD = 'MRO_TEXT1'.
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'MRO_TYPE2'. ""중분류
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 10.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1122'.
        <LS_FCAT>-REF_FIELD = 'MRO_TYPE2'.
        <LS_FCAT>-CHECKTABLE = '!'.
        <LS_FCAT>-NO_CONVEXT = ABAP_TRUE.
      WHEN 'MRO_TEXT2'. ""중분류명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REF_TABLE = 'ZGTMMT1122'.
        <LS_FCAT>-REF_FIELD = 'MRO_TEXT2'.
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'MATKL'. ""자재그룹
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 10.
      WHEN 'WGBEZ'. ""자재그룹명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 30.
      WHEN 'VIEW_ETC'. ""확장
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>."
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = 7.
      WHEN 'MESSAGE'. ""메시지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>."
        <LS_FCAT>-OUTPUTLEN = 40.
      WHEN OTHERS.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.

    "수정 가능
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'MRO_TYPE1' OR 'MRO_TYPE2' .
        <LS_FCAT>-EDIT = GV_EDIT.
    ENDCASE.

    "T-code 점검
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS' OR 'ZSTAT'  OR 'MESSAGE'.
        IF GV_MNG EQ ABAP_TRUE.
          <LS_FCAT>-TECH = SPACE.
        ELSE.
          <LS_FCAT>-TECH = ABAP_TRUE.
        ENDIF.
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
    GCL_EVENT_200->HANDLE_DATA_CHANGED_FINISHED FOR GO_GRID_200.

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
      IT_OUTTAB            = GT_DISP[]
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

  FIELD-SYMBOLS:
    <LS_MRO1> TYPE TY_MRO1,
    <LS_MRO2> TYPE TY_MRO2.

  LOOP AT PT_GOOD_CELLS ASSIGNING FIELD-SYMBOL(<LS_MODI>).
    CASE <LS_MODI>-FIELDNAME.
      WHEN 'MRO_TYPE1' OR 'MRO_TYPE2'.
        READ TABLE GT_DISP ASSIGNING FIELD-SYMBOL(<LS_CONV>) INDEX <LS_MODI>-ROW_ID.
        CHECK SY-SUBRC EQ 0.
        CASE <LS_MODI>-FIELDNAME.
          WHEN 'MRO_TYPE1'.
            <LS_CONV>-MRO_TYPE1 = |{ <LS_CONV>-MRO_TYPE1 ALPHA = IN }|.
          WHEN 'MRO_TYPE2'.
            <LS_CONV>-MRO_TYPE2 = |{ <LS_CONV>-MRO_TYPE2 ALPHA = IN }|.
        ENDCASE.
    ENDCASE.
  ENDLOOP.


  LOOP AT PT_GOOD_CELLS ASSIGNING  FIELD-SYMBOL(<LS_G0>)
                                                                GROUP BY ( ROW_ID = <LS_G0>-ROW_ID )
                                                                ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    READ TABLE GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP>) INDEX <LS_GROUP>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    <LS_DISP>-ZSTAT = ICON_CHANGE.
    <LS_DISP>-ZCHG = ABAP_TRUE.

    LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_CELLS>).
      CASE <LS_CELLS>-FIELDNAME.
        WHEN 'MRO_TYPE1'. "대분류

          CLEAR <LS_DISP>-MRO_TEXT1.
          READ TABLE GT_MRO1 ASSIGNING <LS_MRO1> WITH KEY MRO_TYPE1 = <LS_DISP>-MRO_TYPE1 BINARY SEARCH.
          IF SY-SUBRC EQ 0.
            <LS_DISP>-MRO_TEXT1 = <LS_MRO1>-MRO_TEXT1.
            <LS_DISP>-MATKL = <LS_MRO1>-MATKL.
            <LS_DISP>-WGBEZ = <LS_MRO1>-WGBEZ.
          ENDIF.

          CLEAR:
            <LS_DISP>-MRO_TEXT2.
          READ TABLE GT_MRO2 ASSIGNING <LS_MRO2> WITH KEY MRO_TYPE1 = <LS_DISP>-MRO_TYPE1
                                                                                                 MRO_TYPE2 = <LS_DISP>-MRO_TYPE2 BINARY SEARCH.
          IF SY-SUBRC EQ 0.
            <LS_DISP>-MRO_TEXT2 = <LS_MRO2>-MRO_TEXT2.
          ENDIF.

        WHEN 'MRO_TYPE2'. "중분류
          CLEAR:
            <LS_DISP>-MRO_TEXT2.
          READ TABLE GT_MRO2 ASSIGNING <LS_MRO2> WITH KEY MRO_TYPE1 = <LS_DISP>-MRO_TYPE1
                                                                                                 MRO_TYPE2 = <LS_DISP>-MRO_TYPE2 BINARY SEARCH.
          IF SY-SUBRC EQ 0.
            <LS_DISP>-MRO_TEXT2 = <LS_MRO2>-MRO_TEXT2.
          ENDIF.

      ENDCASE.
    ENDLOOP.

    "라인별 점검
    PERFORM F_CHECK_LINE_DATA_DISP CHANGING <LS_DISP>.

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_200.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_FCAT_RESET_900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_FCAT_RESET_900 .

  PERFORM F_ADJ_FCAT_900_T.
  PERFORM F_ADJ_FCAT_900_B.

  CALL METHOD GO_GRID_900_T->SET_FRONTEND_FIELDCATALOG
    EXPORTING
      IT_FIELDCATALOG = GT_FCAT_900_T.

  CALL METHOD GO_GRID_900_B->SET_FRONTEND_FIELDCATALOG
    EXPORTING
      IT_FIELDCATALOG = GT_FCAT_900_B.

ENDFORM.
