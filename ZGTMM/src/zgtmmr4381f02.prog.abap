*&---------------------------------------------------------------------*
*& Include          ZGTMMR4381F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form F_SET_ALV_STYLE_GT_ADJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_ADJ>
*&---------------------------------------------------------------------*
FORM F_SET_ALV_STYLE_GT_ADJ  CHANGING PS_ADJ TYPE TY_ADJ.

  CLEAR PS_ADJ-ZSTYLE[].
  CASE ABAP_TRUE.
      "  조정 -> 자재 문서 생성된 경우 ADDQTY, CANCELQTY 수정 불가
    WHEN P_ADJ.
      IF PS_ADJ-MBLNR IS NOT INITIAL.
        PS_ADJ-ZSTYLE = VALUE #(
            ( FIELDNAME = 'ADDQTY'    STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
            ( FIELDNAME = 'CANCELQTY' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
          ).
      ENDIF.
  ENDCASE.


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
    LO_SPLIT TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
    LO_CNTR  TYPE REF TO CL_GUI_CONTAINER.

  GO_CONT_100 = NEW #(
      SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
      EXTENSION = 2000
    ).

  LO_SPLIT = NEW #( PARENT  = GO_CONT_100
                    ROWS    = 1
                    COLUMNS = 1 ).

  LO_CNTR = LO_SPLIT->GET_CONTAINER( ROW = 1 COLUMN = 1 ).

  "ALV Obj.
  GO_GRID_100 = NEW #( I_PARENT = LO_CNTR ).

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

  PERFORM F_CREATE_FCAT_BY_ITAB USING GT_ADJ CHANGING GT_FCAT_100.

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
      WHEN 'STATUS'. ""점검
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H01 CHANGING <LS_FCAT>."
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 4.    "

      WHEN 'RESULT'.   "결과
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 4.    "

      WHEN 'WERKS'.   "플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'T001W'.
        <LS_FCAT>-REF_FIELD = 'WERKS'.
        <LS_FCAT>-JUST = GC_C.

      WHEN 'NAME1'.   "플랜트명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 10.    "

      WHEN 'LGORT'.   "저장위치
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'T001L'.
        <LS_FCAT>-REF_FIELD = 'LGORT'.
        <LS_FCAT>-JUST = GC_C.

      WHEN 'LGOBE'.   "저장위치명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 10.

      WHEN 'MATNR'.   "자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'MARA'.
        <LS_FCAT>-REF_FIELD = 'MATNR'.
        <LS_FCAT>-OUTPUTLEN = 12.
        <LS_FCAT>-INTLEN = 40.

      WHEN 'MAKTX'.   "자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 20.

      WHEN 'CHARG'.   "배치번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>.

      WHEN 'LABST'.   "재고수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H10 CHANGING <LS_FCAT>.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-OUTPUTLEN = 12.

      WHEN 'MEINS'.   "단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'T006'.
        <LS_FCAT>-REF_FIELD = 'MEINS'.

      WHEN 'ADDQTY'.   "추가입고
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H12 CHANGING <LS_FCAT>.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 12.

      WHEN 'CANCELQTY'.   "입고취소
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H13 CHANGING <LS_FCAT>.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 12.

      WHEN 'MJAHR'.   "자재문서연도
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>.
        <LS_FCAT>-EMPHASIZE = GC_C500.
        <LS_FCAT>-JUST = GC_C.

      WHEN 'MBLNR'.   "자재문서번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>.
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
        <LS_FCAT>-EMPHASIZE = GC_C500.

      WHEN 'MESSAGE'.   "처리메세지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 50.    "

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
    GCL_EVENT_100->HANDLE_HOTSPOT_CLICK FOR GO_GRID_100,
*    GCL_EVENT_100->HANDLE_TOOLBAR FOR GO_GRID_100,
*    GCL_EVENT_100->HANDLE_USER_COMMAND FOR GO_GRID_100,
    GCL_EVENT_100->HANDLE_DATA_CHANGED_FINISHED FOR GO_GRID_100.

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
      IT_OUTTAB            = GT_ADJ[]
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
*& Form F_HOTSPOT_CLICK_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_ROW_NO_ROW_ID
*&      --> E_COLUMN_ID
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM F_HOTSPOT_CLICK_100  USING PS_ROW_ID TYPE INT4
                                               PS_COLUMN TYPE LVC_S_COL
                                               PO_SENDER.

  CHECK PS_ROW_ID IS NOT INITIAL.
  READ TABLE GT_ADJ ASSIGNING FIELD-SYMBOL(<LS_ADJ>) INDEX PS_ROW_ID.
  CHECK SY-SUBRC EQ 0.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'MBLNR'. "자재문서
      IF <LS_ADJ>-MBLNR IS NOT INITIAL.
        CALL FUNCTION 'MIGO_DIALOG'
          EXPORTING
            I_MBLNR = <LS_ADJ>-MBLNR
            I_MJAHR = <LS_ADJ>-MJAHR.
      ENDIF.
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

  CHECK PV_MODIFIED EQ ABAP_TRUE.

  FIELD-SYMBOLS <LS_ADJ> TYPE TY_ADJ.

  LOOP AT PT_GOOD_CELLS ASSIGNING  FIELD-SYMBOL(<LS_G0>)
                                                                GROUP BY ( ROW_ID = <LS_G0>-ROW_ID )
                                                                ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    " 입고요청일 여부에 따라 CHECK 표시/해제
    READ TABLE GT_ADJ ASSIGNING <LS_ADJ> INDEX <LS_GROUP>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    PERFORM F_SET_CHECK_GT_ADJ CHANGING <LS_ADJ>.

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_CHECK_GT_ADJ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_ADJ>
*&---------------------------------------------------------------------*
FORM F_SET_CHECK_GT_ADJ  CHANGING PS_ADJ TYPE TY_ADJ.

  " 추가/취소 수량 중복 기입
  IF PS_ADJ-ADDQTY IS NOT INITIAL
    AND PS_ADJ-CANCELQTY IS NOT INITIAL.

    PS_ADJ-STATUS = ICON_LED_RED.
    PS_ADJ-MESSAGE = TEXT-E01.

    " 추가/취소 수량 하나만 기입
  ELSEIF PS_ADJ-ADDQTY IS NOT INITIAL
    OR PS_ADJ-CANCELQTY IS NOT INITIAL.

    PS_ADJ-STATUS = ICON_LED_GREEN.
    PS_ADJ-MESSAGE = SPACE.

  ELSE.
    PS_ADJ-STATUS = SPACE.
    PS_ADJ-MESSAGE = SPACE.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_REFRESH_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_100
*&---------------------------------------------------------------------*
FORM F_REFRESH_ALV  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

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


  DATA LV_ANS TYPE C LENGTH 1.
  SELECT SINGLE @ABAP_TRUE
    FROM @GT_ADJ AS ZZ
    WHERE ( ZZ~ADDQTY NE @SPACE OR ZZ~CANCELQTY NE @SPACE )
    AND ZZ~MBLNR EQ @SPACE
    INTO @DATA(LV_CHK).


  IF LV_CHK EQ ABAP_TRUE.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR      = TEXT-TT1 "확인
        TEXT_QUESTION = TEXT-Q01
      IMPORTING
        ANSWER        = LV_ANS.
    CHECK LV_ANS EQ GC_1.
  ENDIF.

  CLEAR:
    GS_ADJ,
    GT_ADJ[].

  "데이터 다시 조회
  PERFORM F_GET_DATA_ADJ.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GOODSMVT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GOODSMVT .

  DATA:
    LV_ROW_ID TYPE INT4,
    LV_CHECK  TYPE C LENGTH 1,
    LT_ROW_ID TYPE LVC_T_ROID,
    LT_ADJ    TYPE TY_T_ADJ.

  CLEAR GS_SCR_101.

  CALL METHOD GO_GRID_100->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_100->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_ID.

  DELETE LT_ROW_ID WHERE ROW_ID LE 0.

  "  선택된 GT_ADJ -> LT_ADJ
  LT_ADJ = VALUE #( FOR LS_ROW IN LT_ROW_ID ( GT_ADJ[ LS_ROW-ROW_ID ] ) ).

  " --선택된 행 없는 경우
  IF LT_ADJ[] IS INITIAL.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E02.
    EXIT.
  ENDIF.

  " -- 상태값 GREEN 아닌 경우
  SELECT SINGLE @ABAP_TRUE
    FROM @LT_ADJ AS Z1
    WHERE STATUS NE @ICON_LED_GREEN
    INTO @DATA(LV_CHK).

  IF LV_CHK EQ ABAP_TRUE.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E03.
    EXIT.
  ENDIF.

  " 자재문서 생성된 경우
  SELECT SINGLE @ABAP_TRUE
    FROM @LT_ADJ AS Z1
    WHERE MBLNR NE @SPACE
    INTO @DATA(LV_CHK2).

  IF LV_CHK2 EQ ABAP_TRUE.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E04.
    EXIT.
  ENDIF.

  " 전기일 설정 팝업
  CALL SCREEN 101 STARTING AT 50 4.
  CHECK GS_SCR_101-ZCHK EQ ABAP_TRUE.

  "결과 필드 초기화
  PERFORM F_REFRESH_RESULT.

  "BAPI 실행
  PERFORM F_GOODSMVT_BAPI CHANGING LT_ADJ LV_CHECK.

  PERFORM F_REFRESH_ALV USING GO_GRID_100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GOODSMVT_BAPI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_ADJ
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM F_GOODSMVT_BAPI CHANGING PT_ADJ TYPE TY_T_ADJ
                                                      CV_CHECK.
  DATA:
    LV_CHECK     TYPE C LENGTH 1,
    LV_STR       TYPE STRING,
    LV_COUNT     TYPE I,
    LV_S         TYPE I,
    LV_E         TYPE I,
    LV_MESSAGE   TYPE STRING,

    LS_HEADER    TYPE BAPI2017_GM_HEAD_01,
    LS_CODE      TYPE BAPI2017_GM_CODE,
    LT_ITEM_A    TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
    LT_ITEM_C    TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
    LS_HEADRET_A TYPE BAPI2017_GM_HEAD_RET,
    LS_HEADRET_C TYPE BAPI2017_GM_HEAD_RET,
    LS_RETURN    TYPE BAPIRET2,
    LT_RETURN    TYPE STANDARD TABLE OF BAPIRET2.

  FIELD-SYMBOLS:
    <LS_RETURN>     TYPE BAPIRET2,
    <LS_ADJ_RETURN> TYPE TY_ADJ,
    <LS_ITEM>       TYPE BAPI2017_GM_ITEM_CREATE.

  " --HEADER
  LS_HEADER-PSTNG_DATE = GS_SCR_101-BUDAT.
  LS_HEADER-DOC_DATE = GS_SCR_101-BUDAT.

  "--CODE
*  LS_CODE-GM_CODE = GC_04.
  LS_CODE-GM_CODE = GC_05.  "기타입고로 수정

  "--ITEM
  LOOP AT PT_ADJ ASSIGNING FIELD-SYMBOL(<LS_ADJ>).
    IF <LS_ADJ>-ADDQTY IS NOT INITIAL.  "추가 입고

      LT_ITEM_A = VALUE #( BASE LT_ITEM_A (
                      MOVE_TYPE = GC_Z21
                      MATERIAL  = <LS_ADJ>-MATNR
                      PLANT     = <LS_ADJ>-WERKS
                      STGE_LOC  = <LS_ADJ>-LGORT
                      ENTRY_QNT = <LS_ADJ>-ADDQTY
                      ENTRY_UOM = <LS_ADJ>-MEINS
                      BATCH = <LS_ADJ>-CHARG
                  ) ).

    ELSEIF <LS_ADJ>-CANCELQTY IS NOT INITIAL. "입고 취소

      LT_ITEM_C = VALUE #( BASE LT_ITEM_C (
                      MOVE_TYPE = GC_Z22
                      MATERIAL  = <LS_ADJ>-MATNR
                      PLANT     = <LS_ADJ>-WERKS
                      STGE_LOC  = <LS_ADJ>-LGORT
                      ENTRY_QNT = <LS_ADJ>-CANCELQTY
                      ENTRY_UOM = <LS_ADJ>-MEINS
                      BATCH = <LS_ADJ>-CHARG
                  ) ).
    ENDIF.
  ENDLOOP.

  " --추가 입고 BAPI (ADD)
  IF LT_ITEM_A[] IS NOT INITIAL.
    CLEAR LT_RETURN[].
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = LS_HEADER
        GOODSMVT_CODE    = LS_CODE
      IMPORTING
        GOODSMVT_HEADRET = LS_HEADRET_A
      TABLES
        GOODSMVT_ITEM    = LT_ITEM_A
        RETURN           = LT_RETURN.

    READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY TYPE = GC_E.
    "-- 실패
    IF SY-SUBRC EQ 0.
      LV_CHECK = GC_E.
      LS_RETURN = <LS_RETURN>.

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      "결과 필드 할당 + 메시지 리턴
      LV_STR = |({ LS_RETURN-ID }-{ LS_RETURN-NUMBER }) { LS_RETURN-MESSAGE }|.

      LOOP AT LT_ITEM_A ASSIGNING <LS_ITEM>.

        READ TABLE GT_ADJ ASSIGNING <LS_ADJ_RETURN>
                                        WITH KEY WERKS = <LS_ITEM>-PLANT
                                                       LGORT = <LS_ITEM>-STGE_LOC
                                                       MATNR = <LS_ITEM>-MATERIAL
                                                       CHARG = <LS_ITEM>-BATCH.

        <LS_ADJ_RETURN>-RESULT = ICON_LED_RED.
        <LS_ADJ_RETURN>-MESSAGE = LV_STR.
      ENDLOOP.

      "--성공
    ELSE.
      LV_CHECK = GC_S.
      "Commit
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.
      "결과 필드 할당 + 자재문서 리턴
      LOOP AT LT_ITEM_A ASSIGNING <LS_ITEM>.

        READ TABLE GT_ADJ ASSIGNING <LS_ADJ_RETURN>
                                        WITH KEY WERKS = <LS_ITEM>-PLANT
                                                       LGORT = <LS_ITEM>-STGE_LOC
                                                       MATNR = <LS_ITEM>-MATERIAL
                                                       CHARG = <LS_ITEM>-BATCH.

        <LS_ADJ_RETURN>-RESULT = ICON_LED_GREEN.
        <LS_ADJ_RETURN>-MJAHR = LS_HEADRET_A-DOC_YEAR.
        <LS_ADJ_RETURN>-MBLNR = LS_HEADRET_A-MAT_DOC.

        "--STYLE 설정
        PERFORM F_SET_ALV_STYLE_GT_ADJ CHANGING <LS_ADJ_RETURN>.
      ENDLOOP.

    ENDIF.
  ENDIF.


  " --입고 취소 BAPI (CANCEL)
  IF LT_ITEM_C[] IS NOT INITIAL.
    CLEAR LT_RETURN[].
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = LS_HEADER
        GOODSMVT_CODE    = LS_CODE
      IMPORTING
        GOODSMVT_HEADRET = LS_HEADRET_C
      TABLES
        GOODSMVT_ITEM    = LT_ITEM_C
        RETURN           = LT_RETURN.

    READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY TYPE = GC_E.
    "-- 실패
    IF SY-SUBRC EQ 0.
      LV_CHECK = GC_E.
      LS_RETURN = <LS_RETURN>.

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      "결과 필드 할당 + 메시지 리턴
      LV_STR = |({ LS_RETURN-ID }-{ LS_RETURN-NUMBER }) { LS_RETURN-MESSAGE }|.

      LOOP AT LT_ITEM_C ASSIGNING <LS_ITEM>.

        READ TABLE GT_ADJ ASSIGNING <LS_ADJ_RETURN>
                                        WITH KEY WERKS = <LS_ITEM>-PLANT
                                                       LGORT = <LS_ITEM>-STGE_LOC
                                                       MATNR = <LS_ITEM>-MATERIAL
                                                       CHARG = <LS_ITEM>-BATCH.

        <LS_ADJ_RETURN>-RESULT = ICON_LED_RED.
        <LS_ADJ_RETURN>-MESSAGE = LV_STR.
      ENDLOOP.

      "--성공
    ELSE.
      LV_CHECK = GC_S.
      "Commit
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.
      "결과 필드 할당 + 자재문서 리턴
      LOOP AT LT_ITEM_C ASSIGNING <LS_ITEM>.

        READ TABLE GT_ADJ ASSIGNING <LS_ADJ_RETURN>
                                        WITH KEY WERKS = <LS_ITEM>-PLANT
                                                       LGORT = <LS_ITEM>-STGE_LOC
                                                       MATNR = <LS_ITEM>-MATERIAL
                                                       CHARG = <LS_ITEM>-BATCH.

        <LS_ADJ_RETURN>-RESULT = ICON_LED_GREEN.
        <LS_ADJ_RETURN>-MJAHR = LS_HEADRET_C-DOC_YEAR.
        <LS_ADJ_RETURN>-MBLNR = LS_HEADRET_C-MAT_DOC.
      ENDLOOP.

    ENDIF.
  ENDIF.

  "--하단 메시지

  SELECT COUNT(*)
    FROM @GT_ADJ AS Z1
   WHERE Z1~RESULT = @ICON_LED_GREEN
    INTO @LV_S.

  SELECT COUNT(*)
    FROM @GT_ADJ AS Z1
   WHERE Z1~RESULT = @ICON_LED_RED
    INTO @LV_E.

  LV_COUNT = LV_S + LV_E.

  MESSAGE S073 WITH LV_COUNT LV_S LV_E.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_REFRESH_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_REFRESH_200 .

  DATA LV_CHECK TYPE C LENGTH 1.

  CALL METHOD GO_GRID_200->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CLEAR:
    GS_DISP,
    GT_DISP[].

  "데이터 다시 조회
  PERFORM F_GET_DATA_DISP.

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

  DATA:
    LO_SPLIT TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
    LO_CNTR  TYPE REF TO CL_GUI_CONTAINER.

  GO_CONT_200 = NEW #(
      SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
      EXTENSION = 2000
    ).

  LO_SPLIT = NEW #( PARENT  = GO_CONT_200
                    ROWS    = 1
                    COLUMNS = 1 ).

  LO_CNTR = LO_SPLIT->GET_CONTAINER( ROW = 1 COLUMN = 1 ).

  "ALV Obj.
  GO_GRID_200 = NEW #( I_PARENT = LO_CNTR ).

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
   GT_EXCL_200.

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

  CLEAR:
    GS_LAYO_200.

  GS_LAYO_200-SEL_MODE = GC_A.
*  GS_LAYO_200-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_200-ZEBRA = ABAP_TRUE.
*  GS_LAYO_200-SMALLTITLE = ABAP_TRUE.
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
  GS_VARI_200-HANDLE = 'ALD2'.

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

  PERFORM F_DISP_FCAT_200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_DISP_FCAT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_DISP_FCAT_200 .

  LOOP AT GT_FCAT_200 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME. "

      WHEN 'RESULT'.   "결과
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H02 CHANGING <LS_FCAT>.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 4.    "
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.

      WHEN 'SMBLN'.   "취소자재문서번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H25 CHANGING <LS_FCAT>.
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-EMPHASIZE = GC_C500.

      WHEN 'MBLNR'.   "자재문서번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H15 CHANGING <LS_FCAT>.
        <LS_FCAT>-HOTSPOT = ABAP_TRUE.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-EMPHASIZE = GC_C500.

      WHEN 'MJAHR'.   "자재문서연도
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H14 CHANGING <LS_FCAT>.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.

      WHEN 'ZEILE'.   "품목
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H20 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.

      WHEN 'BUDAT'.   "전기일자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H17 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.

      WHEN 'CHECK'.   "선택
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H24 CHANGING <LS_FCAT>.
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 4.    "

      WHEN 'BWART'.   "이동유형
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H18 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'T156T'.
        <LS_FCAT>-REF_FIELD = 'BWART'.

      WHEN 'BTEXT'.   "이동유형내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H19 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 12.

      WHEN 'WERKS'.   "플랜트
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H03 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'T001W'.
        <LS_FCAT>-REF_FIELD = 'WERKS'.
        <LS_FCAT>-JUST = GC_C.

      WHEN 'NAME1'.   "플랜트명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H04 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 10.    "

      WHEN 'LGORT'.   "저장위치
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H05 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'T001L'.
        <LS_FCAT>-REF_FIELD = 'LGORT'.
        <LS_FCAT>-JUST = GC_C.

      WHEN 'LGOBE'.   "저장위치명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H06 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 10.

      WHEN 'MATNR'.   "자재번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H07 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'MARA'.
        <LS_FCAT>-REF_FIELD = 'MATNR'.
        <LS_FCAT>-OUTPUTLEN = 12.
        <LS_FCAT>-INTLEN = 40.

      WHEN 'MAKTX'.   "자재내역
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H08 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 20.

      WHEN 'CHARG'.   "배치번호
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H09 CHANGING <LS_FCAT>.

      WHEN 'ERFMG'.   "재고수량
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H21 CHANGING <LS_FCAT>.
        <LS_FCAT>-QFIELDNAME = 'ERFME'.
        <LS_FCAT>-OUTPUTLEN = 12.

      WHEN 'ERFME'.   "단위
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H11 CHANGING <LS_FCAT>.
        <LS_FCAT>-REF_TABLE = 'T006'.
        <LS_FCAT>-REF_FIELD = 'MEINS'.

      WHEN 'UNAME'.   "생성자
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H22 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 8.
        <LS_FCAT>-JUST = GC_C.

      WHEN 'NAME_TEXT'.   "생성자명
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H23 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 8.
        <LS_FCAT>-JUST = GC_C.

      WHEN 'MESSAGE'.   "처리메세지
        PERFORM F_SET_FCAT_COLTXT USING TEXT-H16 CHANGING <LS_FCAT>.
        <LS_FCAT>-OUTPUTLEN = 50.    "

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
    GCL_EVENT_200->HANDLE_HOTSPOT_CLICK FOR GO_GRID_200,
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
*& Form F_HOTSPOT_CLICK_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_ROW_NO_ROW_ID
*&      --> E_COLUMN_ID
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM F_HOTSPOT_CLICK_200  USING PS_ROW_ID TYPE INT4
                                               PS_COLUMN TYPE LVC_S_COL
                                               PO_SENDER.

  CHECK PS_ROW_ID IS NOT INITIAL.
  READ TABLE GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP>) INDEX PS_ROW_ID.
  CHECK SY-SUBRC EQ 0.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'MBLNR'. "자재문서
      IF <LS_DISP>-MBLNR IS NOT INITIAL.
        CALL FUNCTION 'MIGO_DIALOG'
          EXPORTING
            I_MBLNR = <LS_DISP>-MBLNR
            I_MJAHR = <LS_DISP>-MJAHR
            I_ZEILE = <LS_DISP>-ZEILE.
      ENDIF.

    WHEN 'SMBLN'. "취소자재문서
      IF <LS_DISP>-SMBLN IS NOT INITIAL.
        CALL FUNCTION 'MIGO_DIALOG'
          EXPORTING
            I_MBLNR = <LS_DISP>-SMBLN
            I_MJAHR = <LS_DISP>-MJAHR
            I_ZEILE = <LS_DISP>-ZEILE.
      ENDIF.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GOODSMVT_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GOODSMVT_CANCEL .
  DATA:
    LV_ROW_ID TYPE INT4,
    LV_CHECK  TYPE C LENGTH 1,
    LT_ROW_ID TYPE LVC_T_ROID,
    LT_DISP   TYPE TY_T_DISP.

  CLEAR GS_SCR_201.

  CALL METHOD GO_GRID_200->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  " MOVE CHECKED DATA
  LT_DISP = VALUE #( FOR LS_DISP IN GT_DISP WHERE ( CHECK = ABAP_TRUE ) ( LS_DISP ) ).

  " --선택된 행 없는 경우
  IF LT_DISP[] IS INITIAL.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E02.
    EXIT.
  ENDIF.

  " --자재문서 여러건 선택된 경우
  " 서로 다른 MBLNR이 몇 종류인지 카운트
  SELECT COUNT( DISTINCT MBLNR )
    FROM @LT_DISP AS Z1
    INTO @DATA(LV_COUNT).

  IF LV_COUNT GT 1.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E05.
    EXIT.
  ENDIF.

  " 전기일 설정 팝업
  SELECT SINGLE Z1~BUDAT
    FROM @LT_DISP AS Z1
    INTO @GS_SCR_201-BUDAT.

  CALL SCREEN 201 STARTING AT 50 4.
  CHECK GS_SCR_201-ZCHK EQ ABAP_TRUE.

  "결과 필드 초기화
  PERFORM F_REFRESH_RESULT.

  "BAPI 실행
  PERFORM F_GOODSMVT_CANCEL_BAPI CHANGING LT_DISP LV_CHECK.

  IF LV_CHECK EQ GC_S.
    MESSAGE S000 WITH TEXT-M02.
  ELSEIF LV_CHECK EQ GC_E.
    MESSAGE S000 WITH TEXT-M03.
  ENDIF.

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

  FIELD-SYMBOLS <LS_DISP> TYPE TY_DISP.

  LOOP AT PT_GOOD_CELLS ASSIGNING  FIELD-SYMBOL(<LS_G0>)
                                                                GROUP BY ( ROW_ID = <LS_G0>-ROW_ID )
                                                                ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    " 입고요청일 여부에 따라 CHECK 표시/해제
    READ TABLE GT_DISP ASSIGNING <LS_DISP> INDEX <LS_GROUP>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    PERFORM F_SET_CHECK_GT_DISP CHANGING <LS_DISP>.

  ENDLOOP.

  PERFORM F_REFRESH_ALV USING GO_GRID_200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_CHECK_GT_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_DISP>
*&---------------------------------------------------------------------*
FORM F_SET_CHECK_GT_DISP  CHANGING PS_DISP TYPE TY_DISP.

  "--동일 자재문서에 대해 체크 동일화
  LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP>) WHERE MBLNR EQ PS_DISP-MBLNR.
    <LS_DISP>-CHECK = PS_DISP-CHECK.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GOODSMVT_CANCEL_BAPI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_DISP
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM F_GOODSMVT_CANCEL_BAPI  CHANGING PT_DISP TYPE TY_T_DISP
                                      CV_CHECK.

  DATA:
    LS_HEADRET TYPE BAPI2017_GM_HEAD_RET,
    LT_RETURN  TYPE STANDARD TABLE OF BAPIRET2,
    LS_RETURN  TYPE BAPIRET2,
    LV_STR     TYPE STRING.

  CLEAR:
     CV_CHECK.

  FIELD-SYMBOLS:
    <LS_RETURN> TYPE BAPIRET2,
    <LS_DISP>   TYPE TY_DISP.

  "--삭제할 자재문서 READ
  READ TABLE PT_DISP INTO DATA(LS_DISP) INDEX GC_1.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = LS_DISP-MBLNR
      MATDOCUMENTYEAR     = LS_DISP-MJAHR
      GOODSMVT_PSTNG_DATE = LS_DISP-BUDAT
      GOODSMVT_PR_UNAME   = SY-UNAME
    IMPORTING
      GOODSMVT_HEADRET    = LS_HEADRET
    TABLES
      RETURN              = LT_RETURN.

  "--성공
  IF LS_HEADRET IS NOT INITIAL.
    CV_CHECK = GC_S.
    "Commit
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    LOOP AT GT_DISP ASSIGNING <LS_DISP> WHERE MBLNR = LS_DISP-MBLNR
                                                                     AND MJAHR = LS_DISP-MJAHR.
      <LS_DISP>-RESULT = ICON_LED_GREEN.
      <LS_DISP>-SMBLN = LS_HEADRET-MAT_DOC.
      <LS_DISP>-CHECK = SPACE.
      PERFORM F_SET_ALV_STYLE_GT_DISP CHANGING <LS_DISP>.

    ENDLOOP.

    "--실패
  ELSE.
    CV_CHECK = GC_E.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    READ TABLE LT_RETURN INTO LS_RETURN WITH KEY TYPE = GC_E.
    LV_STR = |({ LS_RETURN-ID }-{ LS_RETURN-NUMBER }) { LS_RETURN-MESSAGE }|.

    LOOP AT GT_DISP ASSIGNING <LS_DISP> WHERE MBLNR = LS_DISP-MBLNR
                                                                     AND MJAHR = LS_DISP-MJAHR.
      <LS_DISP>-RESULT = ICON_LED_RED.
      <LS_DISP>-MESSAGE = LV_STR.

    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_ALV_STYLE_GT_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_DISP>
*&---------------------------------------------------------------------*
FORM F_SET_ALV_STYLE_GT_DISP  CHANGING PS_DISP TYPE TY_DISP.
  CLEAR PS_DISP-ZSTYLE[].

  " 취소 완료된 문서는 재처리 불가
  IF PS_DISP-SMBLN IS NOT INITIAL.
    PS_DISP-ZSTYLE[] = VALUE #( ( FIELDNAME = 'CHECK' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
  ENDIF.

ENDFORM.
