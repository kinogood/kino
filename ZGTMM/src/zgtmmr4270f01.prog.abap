*&---------------------------------------------------------------------*
*& Include          ZGTMMR4270F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH .

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'BUKRS' FIELD P_BUKRS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E172 WITH P_BUKRS. "회사코드[&] 작업권한을 확인하세요.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트[&] 작업권한을 확인하세요.

  IF S_WERKS[] IS NOT INITIAL.
    LOOP AT S_WERKS INTO DATA(LS_WERKS).
      AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                   ID 'WERKS' FIELD LS_WERKS-LOW.

      CHECK SY-SUBRC <> 0.

      SET CURSOR FIELD 'S_WERKS-LOW'.
      MESSAGE E106 WITH S_WERKS-LOW. "플랜트 [&] 작업권한을 확인하세요.
    ENDLOOP.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_SCREEN_ATTR_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_SCREEN_ATTR_1000 .

  "타이틀
  IF SY-TCODE EQ 'ZGTMMR4270'.
    SET TITLEBAR '1000' WITH TEXT-TT1.
  ELSE.
    SET TITLEBAR '1000' WITH TEXT-TT2.
  ENDIF.

  LOOP AT SCREEN.

    CASE SCREEN-GROUP1.
      WHEN 'DAY'.
        IF SY-TCODE EQ 'ZGTMMR4270'.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.
      WHEN 'BUK' OR 'WRK' OR 'LIF'.
        SCREEN-REQUIRED = 2.

        CASE SCREEN-GROUP1.
          WHEN 'WRK' OR 'LIF'.
            IF P_DISP EQ ABAP_TRUE.
              SCREEN-ACTIVE = 0.
            ELSE.
              SCREEN-ACTIVE = 1.
            ENDIF.
        ENDCASE.


        MODIFY SCREEN.
      WHEN 'DIS'.
        IF P_DAY EQ ABAP_TRUE OR P_MONTH EQ ABAP_TRUE.
          SCREEN-ACTIVE = 0.
        ELSE.
          SCREEN-ACTIVE = 1.
        ENDIF.
        MODIFY SCREEN.
      WHEN 'ZDA'.
        IF P_DAY EQ ABAP_TRUE OR P_DISP EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.
      WHEN 'SMO'.
        SCREEN-REQUIRED = 2.
        IF P_MONTH EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.
    ENDCASE.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_INITIALIZATION .

  DATA: LV_DATUM TYPE SY-DATUM.

  "조회인 경우 월 을 기본값 으로 설정
  IF SY-TCODE NE 'ZGTMMR4270'.
    IF P_DAY EQ ABAP_TRUE.
      P_DAY = SPACE.
      P_MONTH = ABAP_TRUE.
    ENDIF.
  ENDIF.

  LV_DATUM = |{ SY-DATUM(6) }01|.

*"기본값으로 당일 조회 -> [이번달 1일~오늘] 범위로 변경"
  IF S_ZDATE[] IS INITIAL.
    S_ZDATE[] = VALUE #( ( SIGN = 'I'
                                          OPTION = 'BT'
                                          LOW = LV_DATUM
                                          HIGH = SY-DATUM ) ).
  ENDIF.

  " 작업월 기본값
  IF P_SPMON IS INITIAL.
    P_SPMON = |{ SY-DATUM(6) }|.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_BUKRS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_BUKRS .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  "필수 값 점검
  IF P_BUKRS IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F01.
  ENDIF.

  CHECK GV_ERROR EQ SPACE.

  "유효성 점검
  SELECT SINGLE
    BUKRS
    FROM T001
    WHERE BUKRS EQ @P_BUKRS
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E013.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_WERKS .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  "일/월 선택한 경우만
  CHECK P_DAY EQ  ABAP_TRUE OR P_MONTH EQ ABAP_TRUE.

  "필수 값 점검
  IF P_WERKS IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F02.
  ENDIF.

  "유효성 점검
  SELECT SINGLE
    WERKS
    FROM T001W
    WHERE WERKS EQ @P_WERKS
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E013.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_LIFNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_LIFNR .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  "일/월 선택한 경우만
  CHECK P_DAY EQ  ABAP_TRUE OR P_MONTH EQ ABAP_TRUE.

  "필수 값 점검
  IF P_LIFNR IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F03.
  ENDIF.

  "유효성 점검
  SELECT SINGLE
    LIFNR
    FROM LFA1
    WHERE LIFNR EQ @P_LIFNR
    INTO @DATA(LV_CHK).
  CHECK SY-SUBRC NE 0.
  GV_ERROR = ABAP_TRUE.
  MESSAGE E013.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_SPMON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SCREEN_ON_SPMON .

  CHECK SY-UCOMM EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR GV_ERROR.

  "월 선택한 경우만
  CHECK P_MONTH EQ ABAP_TRUE.

  "필수 값 점검
  IF P_SPMON IS INITIAL.
    GV_ERROR = ABAP_TRUE.
    MESSAGE E278(00) WITH TEXT-F04.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_START_OF_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_START_OF_SELECTION .

  CLEAR:
    GS_DAY,
    GS_ITEM.

  CASE ABAP_TRUE.
    WHEN P_DAY. "일 실적(입고)
      PERFORM F_GET_DAY_LIST.

    WHEN P_MONTH. "월 실적(비용)
      PERFORM F_GET_MON_LIST.
    WHEN P_DISP.
      PERFORM F_GET_DISP_LIST.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DAY_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DAY_LIST .

  CLEAR GT_DAY[].

  "마감 기간 조회
  PERFORM F_GET_CLOSED_PERIOD.

  "목드럼 임가공 실적(Daily)  Header 조회
  PERFORM F_SET_ZGTMMT4271_DATA.

  "목드럼 임가공 실적(Daily) ITEM 조회
*  PERFORM F_SET_ZGTMMT4272_DATA.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ZGTMMT4271_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ZGTMMT4271_DATA .

  SELECT
    Z1~BUKRS,
    Z1~EKORG,
    Z1~WERKS,
    Z1~LIFNR,
    Z1~SPMON,
    Z1~ZDATE,
    Z1~EMP_TIME,
    Z1~DLAB_TIME,
    Z1~OVER_TIME,
    Z1~MEINH,
    Z1~MJAHR,
    Z1~MBLNR,
    Z1~MBLNR_G
    FROM ZGTMMT4271 AS Z1
    WHERE Z1~BUKRS EQ @P_BUKRS
    AND Z1~WERKS EQ @P_WERKS
    AND Z1~LIFNR EQ @P_LIFNR
    AND Z1~ZDATE IN @S_ZDATE
    ORDER BY Z1~ZDATE DESCENDING
    INTO CORRESPONDING FIELDS OF TABLE @GT_DAY.

  DATA LT_DUPL TYPE TY_T_KEY_DAY.
  LOOP AT GT_DAY ASSIGNING FIELD-SYMBOL(<LS_DAY>).

    "데이터 점검
    PERFORM F_CHECK_VALUES_GT_DAY USING LT_DUPL CHANGING <LS_DAY>.

    "Style 설정
    PERFORM F_SET_ALV_STYLE_GT_DAY CHANGING <LS_DAY>.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_END_OF_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_END_OF_SELECTION .

  CASE ABAP_TRUE.
    WHEN P_DAY.
      CALL SCREEN 100.
    WHEN P_MONTH.
      IF GT_SUM[] IS INITIAL.
        MESSAGE S002 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.
      CALL SCREEN 200.
    WHEN P_DISP.
      IF GT_DISP[] IS INITIAL.
        MESSAGE S002 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.
      CALL SCREEN 300.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CONV_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CONV_100.

  IF GV_EDIT EQ ABAP_TRUE.
    GV_EDIT = SPACE.
  ELSE.
    GV_EDIT = ABAP_TRUE.
  ENDIF.

  "필드카탈로그 설정
  PERFORM F_ADJ_FCAT_100_T.
  PERFORM F_ADJ_FCAT_100_M.
  PERFORM F_ADJ_FCAT_100_B.

  CALL METHOD GO_GRID_100_T->SET_FRONTEND_FIELDCATALOG
    EXPORTING
      IT_FIELDCATALOG = GT_FCAT_100_T.

  CALL METHOD GO_GRID_100_T->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO_100_T.

  CALL METHOD GO_GRID_100_M->SET_FRONTEND_FIELDCATALOG
    EXPORTING
      IT_FIELDCATALOG = GT_FCAT_100_M.

  CALL METHOD GO_GRID_100_M->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO_100_M.

  CALL METHOD GO_GRID_100_B->SET_FRONTEND_FIELDCATALOG
    EXPORTING
      IT_FIELDCATALOG = GT_FCAT_100_B.

  CALL METHOD GO_GRID_100_B->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO_100_B.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ITEM_DATA_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_DAY>
*&---------------------------------------------------------------------*
FORM F_SET_ITEM_DATA_100  USING  PS_DAY TYPE TY_DAY.

  "초기화
  CLEAR:
    GS_DAY,
    GT_ITEM[],
    GT_PO[].

  CHECK PS_DAY-ZDUPL EQ SPACE. "중복 오류가 아닌 경우만

  GS_DAY = PS_DAY.

  "실적 조회
  PERFORM F_GET_DATA_ZGTMMT4272 USING GS_DAY.

  IF GS_DAY-ZGR EQ ABAP_TRUE.
    "입고 처리된 경우
    PERFORM F_GET_DATA_ZGTMMT4274.
  ELSE.
    "입고 처리 전
    PERFORM F_GET_DATA_PO.
    "PO 량 설정
    PERFORM F_SET_DEFAULT_ENTRY_QNT.
  ENDIF.

  DATA:
    LT_DUPL  TYPE TY_T_KEY_ITEM,
    LT_FNAME TYPE TY_T_FNAME.

  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
    PERFORM F_CHECK_VALUES_GT_ITEM USING LT_DUPL LT_FNAME CHANGING <LS_ITEM>.
  ENDLOOP.

*"드럼 실적 상세 (작업일자)
*EX) 드럼 실적 상세 (2026.01.01)
*
*작업일자는 GT_HEAD의 SELECTED ROW - ZDATE (작업일자) 필드 값"

  GS_LAYO_100_M-GRID_TITLE = |{ TEXT-AT2 } ({ PS_DAY-ZDATE+0(4) }.{ PS_DAY-ZDATE+4(2) }.{ PS_DAY-ZDATE+6(2) })|.
  CALL METHOD GO_GRID_100_M->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO_100_M.

  GS_LAYO_100_B-GRID_TITLE = TEXT-AT3.
  CALL METHOD GO_GRID_100_B->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO_100_B.

  "ALV Refresh
  PERFORM F_REFRESH_ALV USING GO_GRID_100_M.
  PERFORM F_REFRESH_ALV USING GO_GRID_100_B.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_VALUES_GT_DAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_FNAME
*&      <-- <LS_DAY>
*&---------------------------------------------------------------------*
FORM F_CHECK_VALUES_GT_DAY  USING PT_DUPL TYPE TY_T_KEY_DAY
                            CHANGING CS_DAY TYPE TY_DAY.

  DATA:
    LV_MSG TYPE BAPI_MSG,
    LT_MSG TYPE STANDARD TABLE OF TY_MSG_T.

  ""점검 설정
  CS_DAY-STATUS = ICON_LED_GREEN. "기본 녹색 설정
  CS_DAY-MESSAGE = SPACE.
  CS_DAY-ZCLSD = SPACE. "마감여부
  CS_DAY-ZDUPL = SPACE. "중복여부
  CS_DAY-ZGR = SPACE. "입고여부
  CS_DAY-ZCNF = SPACE. "실적존재여부


  IF CS_DAY-ZDATE IS NOT INITIAL.
*작업 일자 중복             "GT_HEAD-ZDATE 가 ITAB안에서 중복되는 경우
*(행추가 후 ITAB에 이미 존재하는 작업일자 입력한 경우)"     오류: 작업일자 중복
    READ TABLE PT_DUPL WITH KEY ZDATE = CS_DAY-ZDATE
                                              BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC EQ 0.
      CS_DAY-ZDUPL = ABAP_TRUE.
      CS_DAY-STATUS = ICON_LED_RED.
      LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = TEXT-E01 ) ) .
    ENDIF.
  ELSE.
*필수값 누락             "GT_HEAD-ZDATE IS INITIAL
*(행추가 후 작업일자 미입력한 경우)"      오류: 작업일자 누락
    CS_DAY-STATUS = ICON_LED_RED.
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = TEXT-E02 ) ) .
  ENDIF.

*월 마감 완료              "1. 현재 전기기간 SELECT
*SELECT SINGLE *
*FROM MARV
*INTO LS_MARV
*WHERE MARV-BUKRS = P_BUKRS.
*
*2. 작업 일자의 월(ZDATE(6))이 현재 전기기간 미만인 경우
*--> 현재 전기기간: LS_MARV-LFGJA(YYYY) && LS_MARV-LFMON(MM)"     수정 불가: 월마감 완료
  IF GV_CDATE GT CS_DAY-ZDATE AND CS_DAY-ZDATE IS NOT INITIAL.
    CS_DAY-ZCLSD = ABAP_TRUE.
    CS_DAY-STATUS = ICON_LED_RED.
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = TEXT-E00 ) ) .
  ENDIF.

*🔺         해당 일자 자재문서 존재             GT_HEAD-MBLNR IS NOT INITIAL      입고 수량 수정 불가: 입고 완료
  IF CS_DAY-MBLNR IS NOT INITIAL
    OR CS_DAY-MBLNR_G IS NOT INITIAL.
    CS_DAY-ZGR = ABAP_TRUE.

    "오류가 없는 경우
    IF LT_MSG[] IS INITIAL.
      CS_DAY-STATUS = ICON_LED_YELLOW.
      LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = TEXT-W01 ) ) .
    ENDIF.
  ENDIF.

*하위 문서(ZGTMMT4272) 존재             "동일 조건의 ZGTMMT4272 데이터 존재여부 체크
*
*SELECT SINGLE ABAP_TRUE
*FROM ZGTMMT4272
*WHERE BUKRS, WERKS, LIFNR, ZDATE 조건"     삭제 불가: 상세 실적 존재

  SELECT SINGLE @ABAP_TRUE
    FROM ZGTMMT4272
    WHERE EKORG EQ @CS_DAY-EKORG
        AND WERKS EQ @CS_DAY-WERKS
        AND LIFNR EQ @CS_DAY-LIFNR
        AND ZDATE EQ @CS_DAY-ZDATE
  INTO @DATA(LV_CHK).
  IF SY-SUBRC EQ 0.
    CS_DAY-ZCNF = ABAP_TRUE.

    "메세지 없는경우
    IF LT_MSG[] IS INITIAL.
      LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = TEXT-M01 ) ) .
    ENDIF.
  ENDIF.

  "메세지 설정
  LOOP AT LT_MSG ASSIGNING FIELD-SYMBOL(<LS_MSG>).
    IF CS_DAY-MESSAGE IS NOT INITIAL.
      CS_DAY-MESSAGE = |{ CS_DAY-MESSAGE }, { <LS_MSG>-MESSAGE }|.
    ELSE.
      CS_DAY-MESSAGE = <LS_MSG>-MESSAGE.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_CLOSED_PERIOD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_CLOSED_PERIOD .

*"1. 현재 전기기간 SELECT
*SELECT SINGLE *
*FROM MARV
*INTO LS_MARV
*WHERE MARV-BUKRS = P_BUKRS.
*
*2. 작업 일자의 월(ZDATE(6))이 현재 전기기간 미만인 경우
*--> 현재 전기기간: LS_MARV-LFGJA(YYYY) && LS_MARV-LFMON(MM)"
  DATA:
    LV_LFGJA TYPE MARV-LFGJA,
    LV_LFMON TYPE MARV-LFMON.

  CLEAR GV_CDATE.

  SELECT SINGLE LFGJA, LFMON
    FROM MARV
    WHERE BUKRS EQ @P_BUKRS
    INTO ( @LV_LFGJA, @LV_LFMON ).

  GV_CDATE = LV_LFGJA && LV_LFMON && '01'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_STYLE_GT_DAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_DAY>
*&---------------------------------------------------------------------*
FORM F_SET_ALV_STYLE_GT_DAY  CHANGING PS_DAY TYPE TY_DAY.

  CLEAR PS_DAY-ZSTYLE[].

  "신규 추가가 아닌 경우 입력 불가
  IF PS_DAY-ZNEW EQ SPACE.
    PS_DAY-ZSTYLE[] = VALUE #( ( FIELDNAME = 'ZDATE' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
  ENDIF.

  "마감 완료된 경우 입력 불가
  IF PS_DAY-ZCLSD EQ ABAP_TRUE.
    PS_DAY-ZSTYLE[] = VALUE #( BASE  PS_DAY-ZSTYLE ( FIELDNAME = 'EMP_TIME' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
    PS_DAY-ZSTYLE[] = VALUE #( BASE  PS_DAY-ZSTYLE ( FIELDNAME = 'DLAB_TIME' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
    PS_DAY-ZSTYLE[] = VALUE #( BASE  PS_DAY-ZSTYLE ( FIELDNAME = 'OVER_TIME' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_DATA_GT_DAY_LINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_DAY>
*&---------------------------------------------------------------------*
FORM F_SET_DATA_GT_DAY_LINE  CHANGING CS_DAY TYPE TY_DAY.

  CLEAR:
    CS_DAY-EMP_TIME,
    CS_DAY-DLAB_TIME,
    CS_DAY-OVER_TIME,
    CS_DAY-MJAHR,
    CS_DAY-MBLNR.

  SELECT SINGLE
    Z1~EMP_TIME,
    Z1~DLAB_TIME,
    Z1~OVER_TIME,
    Z1~MJAHR,
    Z1~MBLNR
    FROM ZGTMMT4271 AS Z1
    WHERE Z1~BUKRS EQ @CS_DAY-BUKRS
    AND Z1~WERKS EQ @CS_DAY-WERKS
    AND Z1~LIFNR EQ @CS_DAY-LIFNR
    AND Z1~ZDATE EQ @CS_DAY-ZDATE
    INTO CORRESPONDING FIELDS OF @CS_DAY.

  "ZDATE 값 변경 시, SPMON도 반영
  CS_DAY-SPMON = CS_DAY-ZDATE+0(6).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE_DATA_100_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SAVE_DATA_100_T .

  DATA:
    LV_ROW_ID  TYPE INT4,
    LV_DEL_CNT TYPE INT4,
    LV_CHECK   TYPE C LENGTH 1.

  CALL METHOD GO_GRID_100_T->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

*생성/수정/삭제 표시된 LINE 대상으로 ZGTMMT4271 MODIFY / DELETE

*"1건이라도 있는 경우
*에러 메시지 출력 후 반영 하지 않음
*
*'오류가 존재하여  저장할 수 없습니다.' TYPE S DISPLAY LIKE E"
  SELECT SINGLE @ABAP_TRUE
    FROM @GT_DAY AS ZZ
    WHERE ZZ~ZCHG EQ @ABAP_TRUE "변경 건 중
    AND ZZ~STATUS EQ @ICON_LED_RED "오류 아이콘인 데이터가 존재
    INTO @DATA(LV_CHK).
  IF SY-SUBRC EQ 0.
    MESSAGE S000 DISPLAY LIKE GC_E WITH TEXT-E03.
    EXIT.
  ENDIF.

*"POP UP TO CONFIRM
*일 작업 시간을 저장 하시겠습니까? (예/아니오)"
*
  DATA LV_ANS TYPE C LENGTH 1.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT3 "확인
      TEXT_QUESTION = TEXT-Q01
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.


  DATA:
    LT_MOD TYPE STANDARD TABLE OF ZGTMMT4271,
    LT_DEL TYPE STANDARD TABLE OF ZGTMMT4271.

  LOOP AT GT_DAY ASSIGNING FIELD-SYMBOL(<LS_DAY>).
    CHECK <LS_DAY>-ZCHG EQ ABAP_TRUE.
    CASE <LS_DAY>-ZSTAT.
      WHEN ICON_DELETE. "삭제
        LT_DEL = VALUE #( BASE LT_DEL ( CORRESPONDING #( <LS_DAY> ) ) ).
      WHEN ICON_CREATE OR ICON_CHANGE. "신규/수정
        LT_MOD = VALUE #( BASE LT_MOD ( CORRESPONDING #( <LS_DAY> ) ) ).
    ENDCASE.
  ENDLOOP.

  IF LT_DEL[] IS NOT INITIAL.
    DELETE ZGTMMT4271 FROM TABLE LT_DEL.
  ENDIF.

  IF LT_MOD[] IS NOT INITIAL.
    SELECT
      Z1~BUKRS,
      Z1~EKORG,
      Z1~WERKS,
      Z1~LIFNR,
      Z1~SPMON,
      Z1~ZDATE,
      Z1~ERDAT,
      Z1~ERDAT_LOCAL,
      Z1~ERTIM,
      Z1~ERTIM_LOCAL,
      Z1~ERNAM
      FROM ZGTMMT4271 AS Z1
      WHERE EXISTS (
        SELECT @ABAP_TRUE
          FROM @LT_MOD AS ZZ
          WHERE ZZ~BUKRS EQ Z1~BUKRS
            AND ZZ~EKORG EQ Z1~EKORG
            AND ZZ~WERKS EQ Z1~WERKS
            AND ZZ~LIFNR EQ Z1~LIFNR
            AND ZZ~SPMON EQ Z1~SPMON
            AND ZZ~ZDATE EQ Z1~ZDATE
      )
      ORDER BY Z1~BUKRS, Z1~EKORG, Z1~WERKS, Z1~LIFNR, Z1~SPMON, Z1~ZDATE
      INTO TABLE @DATA(LT_ORG).

    LOOP AT LT_MOD ASSIGNING FIELD-SYMBOL(<LS_MOD>).
      <LS_MOD>-AEDAT = SY-DATUM.
      <LS_MOD>-AEDAT_LOCAL = SY-DATLO.
      <LS_MOD>-AETIM = SY-UZEIT.
      <LS_MOD>-AETIM_LOCAL = SY-TIMLO.
      <LS_MOD>-AENAM = SY-UNAME.
      READ TABLE LT_ORG ASSIGNING FIELD-SYMBOL(<LS_ORG>) WITH KEY BUKRS = <LS_MOD>-BUKRS
                    EKORG = <LS_MOD>-EKORG
                    WERKS = <LS_MOD>-WERKS
                    LIFNR = <LS_MOD>-LIFNR
                    SPMON = <LS_MOD>-SPMON
                    ZDATE = <LS_MOD>-ZDATE BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        <LS_MOD> = CORRESPONDING #( BASE ( <LS_MOD> ) <LS_ORG> ).
      ELSE.
        <LS_MOD>-ERDAT = SY-DATUM.
        <LS_MOD>-ERDAT_LOCAL = SY-DATLO.
        <LS_MOD>-ERTIM = SY-UZEIT.
        <LS_MOD>-ERTIM_LOCAL = SY-TIMLO.
        <LS_MOD>-ERNAM = SY-UNAME.
      ENDIF.

* 해당 일자 월실적 없는 경우 생성
      SELECT SINGLE @ABAP_TRUE
        FROM ZGTMMT4270
        WHERE BUKRS = @<LS_MOD>-BUKRS
             AND EKORG = @<LS_MOD>-EKORG
             AND WERKS = @<LS_MOD>-WERKS
             AND LIFNR = @<LS_MOD>-LIFNR
             AND SPMON = @<LS_MOD>-ZDATE(6) INTO @DATA(LV_CK).

      IF SY-SUBRC NE 0.
        DATA(LT_ZGTMMT4270) = VALUE ZGTMMT4270(
                                        BUKRS = <LS_MOD>-BUKRS
                                        EKORG = <LS_MOD>-EKORG
                                        WERKS = <LS_MOD>-WERKS
                                        LIFNR = <LS_MOD>-LIFNR
                                        SPMON = <LS_MOD>-ZDATE(6)
                                        WAERS = GC_KRW "KRW고정
                                        ERDAT = SY-DATUM
                                        ERDAT_LOCAL = SY-DATLO
                                        ERTIM = SY-UZEIT
                                        ERTIM_LOCAL = SY-TIMLO
                                        ERNAM = SY-UNAME ).
        TRY.
            INSERT ZGTMMT4270 FROM LT_ZGTMMT4270 .

          CATCH CX_ROOT INTO DATA(LV_ERROR).
            DATA(LV_MSG) = LV_ERROR->GET_TEXT( ).
        ENDTRY.
      ENDIF.
    ENDLOOP.

    MODIFY ZGTMMT4271 FROM TABLE LT_MOD.
  ENDIF.

  COMMIT WORK.

  LOOP AT GT_DAY ASSIGNING <LS_DAY>.
    CHECK <LS_DAY>-ZCHG EQ ABAP_TRUE.
    CASE <LS_DAY>-ZSTAT.
      WHEN ICON_DELETE. "삭제
        DELETE GT_DAY.
        CONTINUE.
      WHEN ICON_CREATE OR ICON_CHANGE. "신규/수정

        IF <LS_DAY>-ZSTAT EQ ICON_CREATE.
          <LS_DAY>-ZSTYLE = VALUE #( ( FIELDNAME = 'ZDATE' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
        ENDIF.

        "초기화
        CLEAR:
          <LS_DAY>-ZSTAT,
          <LS_DAY>-MESSAGE,
          <LS_DAY>-ZNEW,
          <LS_DAY>-ZCHG.

    ENDCASE.
  ENDLOOP.


  PERFORM F_REFRESH_ALV USING GO_GRID_100_T.

*	실패: TYPE S DISPLAY LIKE E 저장에 실패했습니다.
*	성공: TYPE S 저장에 성공했습니다.
  MESSAGE S000 WITH TEXT-M02.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DATA_ZGTMMT4272
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DAY
*&---------------------------------------------------------------------*
FORM F_GET_DATA_ZGTMMT4272  USING  PS_DAY TYPE TY_DAY.

  SELECT
    Z1~EKORG,
    Z1~WERKS,
    Z1~LIFNR,
    Z1~ZDATE,
    Z1~DRM_TYPE,
    Z1~DRM_SG_TYPE,
    Z1~DRM_LV,
    Z1~MATNR,
    MT~MAKTX,
    Z1~DRM_COUNT,
    Z1~DRM_NETPR,
    Z1~DRM_PRICE,
    Z1~BOARD_COUNT,
    Z1~BOARD_NETPR,
    Z1~BOARD_PRICE,
    Z1~MARK_COUNT,
    Z1~MARK_NETPR,
    Z1~MARK_PRICE,
    Z1~MARK_N_COUNT,
    Z1~MARK_N_NETPR,
    Z1~MARK_N_PRICE,
    Z1~MARK_H_COUNT,
    Z1~MARK_H_NETPR,
    Z1~MARK_H_PRICE,
    Z1~DIS_COUNT,
    Z1~DIS_NETPR,
    Z1~DIS_PRICE,
    Z1~WAERS,
    Z1~MEINS,
    Z1~PEINH,
    Z1~BPRME
    FROM ZGTMMT4272 AS Z1
                LEFT OUTER JOIN
              MAKT AS MT ON Z1~MATNR EQ MT~MATNR
                              AND MT~SPRAS EQ @SY-LANGU
    WHERE Z1~EKORG EQ @PS_DAY-EKORG
    AND Z1~WERKS EQ @PS_DAY-WERKS
    AND Z1~LIFNR EQ @PS_DAY-LIFNR
    AND Z1~ZDATE EQ @PS_DAY-ZDATE
    INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM.

  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
    <LS_ITEM>-ZSTYLE[] = VALUE #( ( FIELDNAME = 'MATNR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
    IF GS_DAY-ZCLSD EQ ABAP_TRUE.
      <LS_ITEM>-ZSTYLE[] = VALUE #( BASE <LS_ITEM>-ZSTYLE[] ( FIELDNAME = 'DRM_COUNT' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
      <LS_ITEM>-ZSTYLE[] = VALUE #( BASE <LS_ITEM>-ZSTYLE[] ( FIELDNAME = 'BOARD_COUNT' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
      <LS_ITEM>-ZSTYLE[] = VALUE #( BASE <LS_ITEM>-ZSTYLE[] ( FIELDNAME = 'MARK_COUNT' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
      <LS_ITEM>-ZSTYLE[] = VALUE #( BASE <LS_ITEM>-ZSTYLE[] ( FIELDNAME = 'MARK_H_COUNT' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
      <LS_ITEM>-ZSTYLE[] = VALUE #( BASE <LS_ITEM>-ZSTYLE[] ( FIELDNAME = 'DIS_COUNT' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
    ELSE.
      IF GS_DAY-ZGR EQ ABAP_TRUE.
        <LS_ITEM>-ZSTYLE[] = VALUE #( BASE <LS_ITEM>-ZSTYLE[] ( FIELDNAME = 'DRM_COUNT' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DATA_ZGTMMT4274
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DATA_ZGTMMT4274 .

  SELECT
    Z1~EBELN,
    Z1~EBELP,
    Z1~BUKRS,
    Z1~WERKS,
    Z1~LIFNR,
    Z1~MATNR,
    Z1~TXZ01,
    Z1~ERNAM,
    Z1~AEDAT,
    Z1~EINDT,
    Z1~VBELN,
    Z1~KUNNR,
    Z1~NAME1,
    Z1~NETPR,
    Z1~UEBTO,
    Z1~UEBTK,
    Z1~MENGE,
    Z1~WEMNG,
    Z1~MEINS,
    Z1~WAERS,
    Z1~ELIKZ,
    Z1~LOEKZ,
    Z1~REMAIN_QNT,
    Z1~REMAIN_MAX_QNT,
    Z1~ENTRY_QNT,
    Z1~LGORT
    FROM ZGTMMT4274 AS Z1
    WHERE EXISTS (
      SELECT @ABAP_TRUE AS CHK
        FROM @GT_ITEM AS ZZ
        WHERE Z1~BUKRS EQ @P_BUKRS
          AND ZZ~EKORG EQ Z1~EKORG
          AND ZZ~WERKS EQ Z1~WERKS
          AND ZZ~LIFNR EQ Z1~LIFNR
          AND ZZ~ZDATE EQ Z1~ZDATE
          AND ZZ~MATNR EQ Z1~MATNR
    )
    ORDER BY Z1~VBELN, Z1~EINDT, Z1~AEDAT
    INTO TABLE @DATA(LT_PO).

  IF LT_PO[] IS NOT INITIAL.
    DATA LS_PO TYPE TY_PO.
    LOOP AT LT_PO ASSIGNING FIELD-SYMBOL(<LS_PO>).
      READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>) WITH KEY MATNR = <LS_PO>-MATNR.
      CHECK SY-SUBRC EQ 0.
      LS_PO = CORRESPONDING #( <LS_PO> ).
      LS_PO-STATUS = ICON_LED_GREEN.
      LS_PO-ZSTYLE[] = VALUE #( ( FIELDNAME = 'ENTRY_QNT' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).

      "데이터 점검
      PERFORM F_CHECK_VALUES_GT_PO CHANGING LS_PO.

      <LS_ITEM>-IT_PO = VALUE #( BASE <LS_ITEM>-IT_PO ( LS_PO ) ).
      <LS_ITEM>-PO_COUNT += LS_PO-ENTRY_QNT.
    ENDLOOP.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DATA_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DATA_PO .

  DATA:
    BEGIN OF LS_KEY,
      MATNR TYPE MATNR,
    END OF LS_KEY,
    LT_KEY LIKE HASHED TABLE OF LS_KEY WITH UNIQUE KEY MATNR.

  SELECT DISTINCT ZZ~MATNR
    FROM @GT_ITEM AS ZZ
    WHERE ZZ~MATNR IS NOT INITIAL
    AND ZZ~DRM_SG_TYPE EQ @GC_S "신드럼
    INTO TABLE @LT_KEY.

  SELECT
    EP~EBELN,
    EP~EBELP,
    EK~BUKRS,
    EP~WERKS,
    EK~LIFNR,
    EP~MATNR,
    EP~TXZ01,
    EK~ERNAM,
    EP~AEDAT,
    ET~EINDT,
    EN~VBELN,
    VK~KUNNR,
    KN~NAME1,
    EP~NETPR,
    EP~UEBTO,
    EP~UEBTK,
    ET~MENGE,
    ET~WEMNG,
    EP~MEINS,
    EK~WAERS,
    EP~ELIKZ,
    EP~LOEKZ,
    ( ET~MENGE - ET~WEMNG ) AS REMAIN_QNT,
    EP~LGORT
    FROM @LT_KEY AS ZZ
                  INNER JOIN
            EKPO AS EP ON ZZ~MATNR EQ EP~MATNR
                  INNER JOIN
            EKKO AS EK ON EP~EBELN EQ EK~EBELN
                  LEFT OUTER JOIN
            EKET AS ET ON EP~EBELN EQ ET~EBELN
                             AND EP~EBELP EQ ET~EBELP
                  LEFT OUTER JOIN
            EKKN AS EN ON EP~EBELN EQ EN~EBELN
                            AND EP~EBELP EQ EN~EBELP
                  LEFT OUTER JOIN
            VBAK AS VK ON EN~VBELN EQ VK~VBELN
                  LEFT OUTER JOIN
            KNA1 AS KN ON VK~KUNNR EQ KN~KUNNR
    WHERE EP~LOEKZ  EQ @SPACE
    AND EP~ELIKZ EQ @SPACE
    AND EP~PSTYP EQ @GC_3
    ORDER BY EN~VBELN, ET~EINDT, EP~AEDAT
    INTO TABLE @DATA(LT_PO).

  IF LT_PO[] IS NOT INITIAL.

    DATA LS_PO TYPE TY_PO.
    LOOP AT LT_PO ASSIGNING FIELD-SYMBOL(<LS_PO>).
      READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>) WITH KEY MATNR = <LS_PO>-MATNR.
      CHECK SY-SUBRC EQ 0.
      CLEAR LS_PO.
      LS_PO = CORRESPONDING #( <LS_PO> ).
*	GT_PO_ALL의 REMAIN_MAX_QNT 필드 계산
*	REMAIN_MAX_QNT = ( MENGE * (1+UBETO/100) - WEMNG ) --> 정수로 버림처리해서 넣기
      LS_PO-REMAIN_MAX_QNT = ( LS_PO-MENGE * ( 1 + LS_PO-UEBTO / 100 ) - LS_PO-WEMNG ).
      LS_PO-REMAIN_MAX_QNT = TRUNC( LS_PO-REMAIN_MAX_QNT ).

      "데이터 점검
      PERFORM F_CHECK_VALUES_GT_PO CHANGING LS_PO.

      <LS_ITEM>-IT_PO = VALUE #( BASE <LS_ITEM>-IT_PO ( LS_PO ) ).
      <LS_ITEM>-PO_COUNT += LS_PO-ENTRY_QNT.
    ENDLOOP.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_VALUES_GT_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_ITEM>
*&---------------------------------------------------------------------*
FORM F_SET_VALUES_GT_ITEM  USING PT_FNAME TYPE TY_T_FNAME
                                                  CHANGING CS_ITEM LIKE GS_ITEM.


*"마킹의 경우 수량 계산 먼저 진행 후 합계 재계산 필요
*MARK_COUNT / MARK_H_COUNT 필드 변경 시,
*MARK_N_COUNT = MARK_COUNT - MARK_H_COUNT로 일반 마킹 수량 계산"
  CS_ITEM-MARK_N_COUNT = CS_ITEM-MARK_COUNT - CS_ITEM-MARK_H_COUNT.

  "자재코드 변경 시 데이터 조회
  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'MATNR' TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CLEAR:
      CS_ITEM-MAKTX, "자재내역
      CS_ITEM-IT_PO[]. "PO 제거

    "자재 내역
    SELECT SINGLE
      MAKTX
      FROM MAKT
      WHERE MATNR EQ @CS_ITEM-MATNR
      INTO @CS_ITEM-MAKTX.

    "단가 조회
    PERFORM F_GET_NETPR_GT_ITEM CHANGING CS_ITEM.

    "PO 조회
    PERFORM F_GET_PO_GT_ITEM CHANGING CS_ITEM.

  ELSE.
    "금액 계산
    PERFORM F_CALC_PRICE_GT_ITEM CHANGING CS_ITEM.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_NETPR_GT_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- CS_ITEM
*&---------------------------------------------------------------------*
FORM F_GET_NETPR_GT_ITEM  CHANGING CS_ITEM LIKE GS_ITEM.

  "입력되는 MATNR 값에 따라 단가 정보 가져옴
* SELECT로 채워지지 않는 작업일자 할당
  SELECT SINGLE
      Z1~DRM_TYPE,
      Z1~DRM_SG_TYPE,
      Z1~DRM_LV,
      Z1~WAERS,
      Z1~GDR_NETPR AS DRM_NETPR,
      Z1~BOARD_NETPR,
      Z1~MARK_NETPR,
      Z1~MARK_H_NETPR,
      Z1~DIS_NETPR,
      Z1~PEINH,
      Z1~BPRME,
      Z1~MEINS
  FROM ZGTMMT1042 AS Z1
  WHERE BUKRS EQ @GS_DAY-BUKRS
  AND EKORG EQ @CS_ITEM-EKORG
  AND WERKS EQ @CS_ITEM-WERKS
  AND LIFNR EQ @CS_ITEM-LIFNR
  AND ZYEAR EQ @GS_DAY-ZDATE+0(4)
  AND MATNR EQ @CS_ITEM-MATNR
  INTO CORRESPONDING FIELDS OF @CS_ITEM.
*  IF SY-SUBRC NE 0.
*    SELECT SINGLE
*      MEINS,
*      MEINS AS BPRME
*      FROM MARA
*      WHERE MATNR EQ @CS_ITEM-MATNR
*      INTO ( @CS_ITEM-MEINS, @CS_ITEM-BPRME ).
*  ENDIF.

  "신드럼은 인포레코드 조회
  IF CS_ITEM-DRM_SG_TYPE EQ GC_S.
    CLEAR CS_ITEM-DRM_NETPR.

    "인포레코드
    SELECT SINGLE
      KP~KBETR
      FROM EINA AS EA
                  INNER JOIN
                EINE AS EE ON EA~INFNR EQ EE~INFNR
                  INNER JOIN
                A017 AS AA ON EA~LIFNR EQ AA~LIFNR
                                AND EA~MATNR EQ AA~MATNR
                                AND EE~EKORG EQ AA~EKORG
                                AND EE~WERKS EQ AA~WERKS
                                AND EE~ESOKZ EQ AA~ESOKZ
                  INNER JOIN
                KONH AS KH ON AA~KNUMH EQ KH~KNUMH
                                  AND AA~KAPPL EQ KH~KAPPL
                                  AND AA~KSCHL EQ KH~KSCHL
                  INNER JOIN
                KONP AS KP ON KH~KNUMH EQ KP~KNUMH
                                 AND KH~KAPPL EQ KP~KAPPL
                                 AND KH~KSCHL EQ KP~KSCHL
      WHERE EE~EKORG EQ @CS_ITEM-EKORG
      AND EE~WERKS EQ @CS_ITEM-WERKS
      AND EA~LIFNR EQ @CS_ITEM-LIFNR
      AND EA~MATNR EQ @CS_ITEM-MATNR
      AND EA~LOEKZ EQ @SPACE
      AND EE~LOEKZ EQ @SPACE
      AND KP~LOEVM_KO EQ @SPACE
      AND EE~ESOKZ EQ @GC_3
      AND AA~KAPPL EQ @GC_M
      AND AA~KSCHL EQ @GC_PB00
      INTO @CS_ITEM-DRM_NETPR.
  ENDIF.

  CS_ITEM-MARK_N_NETPR = CS_ITEM-MARK_NETPR. "마킹 합/일반 동일한 단가 적용

  "금액 계산
  PERFORM F_CALC_PRICE_GT_ITEM CHANGING CS_ITEM.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_PO_GT_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- CS_ITEM
*&---------------------------------------------------------------------*
FORM F_GET_PO_GT_ITEM  CHANGING CS_ITEM LIKE GS_ITEM.

  CHECK CS_ITEM-DRM_SG_TYPE EQ GC_S. "신드럼

  SELECT
    EP~EBELN,
    EP~EBELP,
    EK~BUKRS,
    EP~WERKS,
    EK~LIFNR,
    EP~MATNR,
    EP~TXZ01,
    EK~ERNAM,
    EP~AEDAT,
    ET~EINDT,
    EN~VBELN,
    VK~KUNNR,
    KN~NAME1,
    EP~NETPR,
    EP~UEBTO,
    EP~UEBTK,
    ET~MENGE,
    ET~WEMNG,
    EP~MEINS,
    EK~WAERS,
    EP~ELIKZ,
    EP~LOEKZ,
    ( ET~MENGE - ET~WEMNG ) AS REMAIN_QNT,
    EP~LGORT
    FROM EKPO AS EP
                  INNER JOIN
            EKKO AS EK ON EP~EBELN EQ EK~EBELN
                  LEFT OUTER JOIN
            EKET AS ET ON EP~EBELN EQ ET~EBELN
                             AND EP~EBELP EQ ET~EBELP
                  LEFT OUTER JOIN
            EKKN AS EN ON EP~EBELN EQ EN~EBELN
                            AND EP~EBELP EQ EN~EBELP
                  LEFT OUTER JOIN
            VBAK AS VK ON EN~VBELN EQ VK~VBELN
                  LEFT OUTER JOIN
            KNA1 AS KN ON VK~KUNNR EQ KN~KUNNR
    WHERE EP~MATNR EQ @CS_ITEM-MATNR
    AND EP~LOEKZ  EQ @SPACE
    AND EP~ELIKZ EQ @SPACE
    AND EP~PSTYP EQ @GC_3
    ORDER BY EN~VBELN, ET~EINDT, EP~AEDAT
    INTO CORRESPONDING FIELDS OF TABLE @CS_ITEM-IT_PO.

  LOOP AT CS_ITEM-IT_PO ASSIGNING FIELD-SYMBOL(<LS_PO>).
*	GT_PO_ALL의 REMAIN_MAX_QNT 필드 계산
*	REMAIN_MAX_QNT = ( MENGE * (1+UBETO/100) - WEMNG ) --> 정수로 버림처리해서 넣기
    <LS_PO>-REMAIN_MAX_QNT = ( <LS_PO>-MENGE * ( 1 + <LS_PO>-UEBTO / 100 ) - <LS_PO>-WEMNG ).
    <LS_PO>-REMAIN_MAX_QNT = TRUNC( <LS_PO>-REMAIN_MAX_QNT ).

    "데이터 점검
    PERFORM F_CHECK_VALUES_GT_PO CHANGING <LS_PO>.

    CS_ITEM-PO_COUNT += <LS_PO>-ENTRY_QNT.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_VALUES_GT_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_PO>
*&---------------------------------------------------------------------*
FORM F_CHECK_VALUES_GT_PO  CHANGING CS_PO TYPE TY_PO.


  CS_PO-STATUS = ICON_LED_GREEN.
  CS_PO-MESSAGE = SPACE.

  DATA:
    LT_MSG TYPE STANDARD TABLE OF TY_MSG_T.

*⚫          "PO 입고 가능수량을 초과한 수량 입력
*(초과납품, 무제한 납품 반영)"             "GT_PO-UEBTK IS INITIAL
*AND GT_PO-REMAIN_MAX_QNT < GT_PO-ENTRY_QNT"      PO 잔여 수량 초과

  IF CS_PO-UEBTK EQ SPACE.

    IF CS_PO-REMAIN_MAX_QNT LT CS_PO-ENTRY_QNT.
      CS_PO-STATUS = ICON_LED_RED.
      LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = TEXT-E16  ) ).
    ENDIF.
  ENDIF.

  "저장위치 누락. PO 수정 필요
  IF CS_PO-LGORT IS INITIAL.
    CS_PO-STATUS = ICON_LED_RED.
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = TEXT-E18  ) ).
  ENDIF.

  "메세지 설정
  LOOP AT LT_MSG ASSIGNING FIELD-SYMBOL(<LS_MSG>).
    IF CS_PO-MESSAGE IS NOT INITIAL.
      CS_PO-MESSAGE = |{ CS_PO-MESSAGE }, { <LS_MSG>-MESSAGE }|.
    ELSE.
      CS_PO-MESSAGE = <LS_MSG>-MESSAGE.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_VALUES_GT_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_PO>
*&---------------------------------------------------------------------*
FORM F_SET_VALUES_GT_PO  USING PS_PO TYPE TY_PO
                                  CHANGING CV_CHECK.

  DATA:
    LT_DUPL  TYPE TY_T_KEY_ITEM,
    LT_FNAME TYPE TY_T_FNAME.

  READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>) WITH KEY MATNR = PS_PO-MATNR
                                                                                                   ZDUPL = SPACE.

  CHECK SY-SUBRC EQ 0.

  READ TABLE <LS_ITEM>-IT_PO ASSIGNING FIELD-SYMBOL(<LS_PO>) WITH KEY EBELN = PS_PO-EBELN
                                                                                                              EBELP = PS_PO-EBELP
                                                                                                              EINDT = PS_PO-EINDT.

  CHECK SY-SUBRC EQ 0.
  <LS_PO> = PS_PO. "PO 데이터를 ITEM 에 설정

  "ITEM 에 PO 설정수량 적용
  CLEAR <LS_ITEM>-PO_COUNT.
  LOOP AT <LS_ITEM>-IT_PO ASSIGNING <LS_PO>.
    <LS_ITEM>-PO_COUNT += <LS_PO>-ENTRY_QNT.
  ENDLOOP.

  <LS_ITEM>-ZCHG = ABAP_TRUE.
  IF <LS_ITEM>-ZNEW EQ ABAP_TRUE.
    <LS_ITEM>-ZSTAT = ICON_CREATE.
  ELSE.
    <LS_ITEM>-ZSTAT = ICON_CHANGE.
  ENDIF.

  "ITEM 데이터 점검
  PERFORM F_CHECK_VALUES_GT_ITEM USING LT_DUPL LT_FNAME CHANGING <LS_ITEM>.

  CV_CHECK = ABAP_TRUE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE_DATA_ZGTMMT4272
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SAVE_DATA_ZGTMMT4272 .

  DATA:
    LT_MOD TYPE STANDARD TABLE OF ZGTMMT4272,
    LT_DEL TYPE STANDARD TABLE OF ZGTMMT4272.

  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
    CHECK <LS_ITEM>-ZCHG EQ ABAP_TRUE.
    CASE <LS_ITEM>-ZSTAT.
      WHEN ICON_DELETE. "삭제
        LT_DEL = VALUE #( BASE LT_DEL ( CORRESPONDING #( <LS_ITEM> ) ) ).
      WHEN ICON_CREATE OR ICON_CHANGE. "신규/수정
        LT_MOD = VALUE #( BASE LT_MOD ( CORRESPONDING #( <LS_ITEM> ) ) ).
    ENDCASE.
  ENDLOOP.

  IF LT_DEL[] IS NOT INITIAL.
    DELETE ZGTMMT4272 FROM TABLE LT_DEL.
  ENDIF.

  IF LT_MOD[] IS NOT INITIAL.

    SELECT
      Z1~EKORG,
      Z1~WERKS,
      Z1~LIFNR,
      Z1~ZDATE,
      Z1~MATNR,
      Z1~ERDAT,
      Z1~ERDAT_LOCAL,
      Z1~ERTIM,
      Z1~ERTIM_LOCAL,
      Z1~ERNAM
      FROM ZGTMMT4272 AS Z1
      WHERE EXISTS (
        SELECT @ABAP_TRUE
          FROM @LT_MOD AS ZZ
          WHERE ZZ~EKORG EQ Z1~EKORG
            AND ZZ~WERKS EQ Z1~WERKS
            AND ZZ~LIFNR EQ Z1~LIFNR
            AND ZZ~ZDATE EQ Z1~ZDATE
            AND ZZ~MATNR EQ Z1~MATNR
      )
      ORDER BY Z1~EKORG, Z1~WERKS, Z1~LIFNR, Z1~ZDATE, Z1~MATNR
      INTO TABLE @DATA(LT_ORG).

    LOOP AT LT_MOD ASSIGNING FIELD-SYMBOL(<LS_MOD>).
      <LS_MOD>-AEDAT = SY-DATUM.
      <LS_MOD>-AEDAT_LOCAL = SY-DATLO.
      <LS_MOD>-AETIM = SY-UZEIT.
      <LS_MOD>-AETIM_LOCAL = SY-TIMLO.
      <LS_MOD>-AENAM = SY-UNAME.
      READ TABLE LT_ORG ASSIGNING FIELD-SYMBOL(<LS_ORG>) WITH KEY
                    EKORG = <LS_MOD>-EKORG
                    WERKS = <LS_MOD>-WERKS
                    LIFNR = <LS_MOD>-LIFNR
                    ZDATE = <LS_MOD>-ZDATE
                    MATNR = <LS_MOD>-MATNR BINARY SEARCH.
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

    MODIFY ZGTMMT4272 FROM TABLE LT_MOD.
  ENDIF.

  COMMIT WORK.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_RUN_GR_BAPI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM F_RUN_GR_BAPI  CHANGING CV_CHECK.

  DATA:
    LV_CHECK     TYPE C LENGTH 1,
    LS_HEADER    TYPE BAPI2017_GM_HEAD_01,
    LS_CODE_S    TYPE BAPI2017_GM_CODE,
    LS_CODE_G    TYPE BAPI2017_GM_CODE,
    LT_ITEM_S    TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
    LT_ITEM_G    TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
    LS_HEADRET_S TYPE BAPI2017_GM_HEAD_RET,
    LS_HEADRET_G TYPE BAPI2017_GM_HEAD_RET,
    LS_RETURN    TYPE BAPIRET2,
    LT_RETURN    TYPE STANDARD TABLE OF BAPIRET2.

  DATA LT_DUPL TYPE TY_T_KEY_DAY.
  DATA:
    LT_ZGTMMT4274     TYPE STANDARD TABLE OF ZGTMMT4274,
    LT_ZGTMMT4274_ALL TYPE STANDARD TABLE OF ZGTMMT4274.

  DATA LV_STR TYPE STRING.

  FIELD-SYMBOLS <LS_RETURN> TYPE BAPIRET2.

  "header
  LS_HEADER-PSTNG_DATE = GS_DAY-ZDATE.
  LS_HEADER-DOC_DATE = GS_DAY-ZDATE.

  "code
  LS_CODE_S-GM_CODE = '01'.
  LS_CODE_G-GM_CODE = '05'.

  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
    CHECK <LS_ITEM>-DRM_COUNT IS NOT INITIAL. "수량 있는 경우
    CASE <LS_ITEM>-DRM_SG_TYPE.
      WHEN GC_S.
        LOOP AT <LS_ITEM>-IT_PO ASSIGNING FIELD-SYMBOL(<LS_PO>).
          CHECK <LS_PO>-ENTRY_QNT IS NOT INITIAL.
          LT_ITEM_S =  VALUE #( BASE LT_ITEM_S (
                MATERIAL = <LS_PO>-MATNR
                PLANT = <LS_PO>-WERKS
                STGE_LOC = <LS_PO>-LGORT
                MOVE_TYPE = '101'
                ENTRY_QNT = <LS_PO>-ENTRY_QNT
                ENTRY_UOM = <LS_PO>-MEINS
                PO_NUMBER = <LS_PO>-EBELN
                PO_ITEM = <LS_PO>-EBELP
                MVT_IND = 'B'
          ) ).
        ENDLOOP.
      WHEN GC_G.
        LT_ITEM_G =  VALUE #( BASE LT_ITEM_G (
              MATERIAL = <LS_ITEM>-MATNR
              PLANT = <LS_ITEM>-WERKS
              STGE_LOC = GS_SCR-LGORT
              MOVE_TYPE = '501'
              ENTRY_QNT = <LS_ITEM>-DRM_COUNT
              ENTRY_UOM = <LS_ITEM>-MEINS
        ) ).
    ENDCASE.
  ENDLOOP.

  CLEAR LV_CHECK.

  "신드럼 입고
  IF LT_ITEM_S[] IS NOT INITIAL.
    CLEAR LT_RETURN[].
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = LS_HEADER
        GOODSMVT_CODE    = LS_CODE_S
      IMPORTING
        GOODSMVT_HEADRET = LS_HEADRET_S
      TABLES
        GOODSMVT_ITEM    = LT_ITEM_S
        RETURN           = LT_RETURN.
    READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY TYPE = GC_E.
    IF SY-SUBRC EQ 0.
      LV_CHECK = GC_E.
      LS_RETURN = <LS_RETURN>.

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*"BAPI 에러메시지 출력
*(RETURN-ID && RETURN-NUMBER) && RETURN-MESSAGE
*EX) (ME006) 사용자가(이) 구매 문서 4504264603 을(를) 이미 처리중 입니다"

      LV_STR = |({ LS_RETURN-ID }-{ LS_RETURN-NUMBER })|.
      MESSAGE S000 DISPLAY LIKE GC_E WITH LV_STR LS_RETURN-MESSAGE.
      EXIT.
    ELSE.
      LV_CHECK = GC_S.
      "Commit
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.
    ENDIF.
  ENDIF.

  IF LT_ITEM_G[] IS NOT INITIAL.
    "고드럼 입고
    CLEAR LT_RETURN[].
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = LS_HEADER
        GOODSMVT_CODE    = LS_CODE_G
      IMPORTING
        GOODSMVT_HEADRET = LS_HEADRET_G
      TABLES
        GOODSMVT_ITEM    = LT_ITEM_G
        RETURN           = LT_RETURN.
    READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY TYPE = GC_E.
    IF SY-SUBRC EQ 0.
      LV_CHECK = GC_E.
      LS_RETURN = <LS_RETURN>.

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*"BAPI 에러메시지 출력
*(RETURN-ID && RETURN-NUMBER) && RETURN-MESSAGE
*EX) (ME006) 사용자가(이) 구매 문서 4504264603 을(를) 이미 처리중 입니다"
      LV_STR = |({ LS_RETURN-ID }-{ LS_RETURN-NUMBER })|.
      MESSAGE S000 DISPLAY LIKE GC_E WITH LV_STR LS_RETURN-MESSAGE.

      "신드럼 자재문서 취소
      IF LS_HEADRET_S-MAT_DOC IS NOT INITIAL.
        DATA LV_MESSAGE TYPE BAPI_MSG.
        PERFORM F_MBST_DOC USING LS_HEADRET_S-MAT_DOC LS_HEADRET_S-DOC_YEAR GS_DAY-ZDATE CHANGING LV_CHECK LV_MESSAGE.
        IF LV_CHECK EQ GC_E.
*          MESSAGE I000 DISPLAY LIKE GC_E WITH TEXT-ZZ1 LS_HEADRET_S-DOC_YEAR LS_HEADRET_S-MAT_DOC . "자재문서 취소 오류
          MESSAGE I000 DISPLAY LIKE GC_E WITH LV_MESSAGE.
        ENDIF.
        EXIT.
      ENDIF.
      EXIT.

    ELSE.
      LV_CHECK = GC_S.
      "Commit
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.
    ENDIF.
  ENDIF.

* Header 설정
  "전표변호
  GS_DAY-MBLNR = LS_HEADRET_S-MAT_DOC.
  GS_DAY-MBLNR_G = LS_HEADRET_G-MAT_DOC.
  GS_DAY-MJAHR = GS_DAY-ZDATE+0(4).
  GS_DAY-ZGR = ABAP_TRUE.
  GS_DAY-STATUS = ICON_LED_YELLOW.
  GS_DAY-ZSTAT = SPACE.
  GS_DAY-MESSAGE = SPACE.

  "데이터 점검
  PERFORM F_CHECK_VALUES_GT_DAY USING LT_DUPL CHANGING GS_DAY.

  "Style 설정
  PERFORM F_SET_ALV_STYLE_GT_DAY CHANGING GS_DAY.

  READ TABLE GT_DAY ASSIGNING FIELD-SYMBOL(<LS_DAY>) WITH KEY ZDATE = GS_DAY-ZDATE.
  IF SY-SUBRC EQ 0.
    <LS_DAY> = GS_DAY.
  ENDIF.

* Item 설정
  LOOP AT GT_ITEM ASSIGNING <LS_ITEM>.
    "CBO Table 저장
    CLEAR LT_ZGTMMT4274[].
    LT_ZGTMMT4274 = CORRESPONDING #( <LS_ITEM>-IT_PO[] ) .
    LOOP AT LT_ZGTMMT4274 ASSIGNING FIELD-SYMBOL(<LS_ZGTMMT4274>).
      "(TO-BE) 입고 수량이 입력된 PO만 저장 (실제 입고된 PO)
      IF <LS_ZGTMMT4274>-ENTRY_QNT IS INITIAL.
        DELETE LT_ZGTMMT4274.
        CONTINUE.
      ENDIF.
      <LS_ZGTMMT4274>-EKORG = GS_DAY-EKORG.
      <LS_ZGTMMT4274>-ZDATE = GS_DAY-ZDATE.
    ENDLOOP.
    APPEND LINES OF LT_ZGTMMT4274 TO LT_ZGTMMT4274_ALL.
  ENDLOOP.

  "기존 PO 데이터 삭제
  DELETE FROM ZGTMMT4274
    WHERE BUKRS EQ @GS_DAY-BUKRS
    AND EKORG EQ @GS_DAY-EKORG
    AND WERKS EQ @GS_DAY-WERKS
    AND LIFNR EQ @GS_DAY-LIFNR
    AND ZDATE  EQ @GS_DAY-ZDATE.

  "PO 데이터 저장
  MODIFY ZGTMMT4274 FROM TABLE LT_ZGTMMT4274_ALL.

  "전표번호 저장
  UPDATE ZGTMMT4271 SET
    MJAHR  = @GS_DAY-MJAHR,
    MBLNR = @GS_DAY-MBLNR,
    MBLNR_G = @GS_DAY-MBLNR_G,
    AEDAT = @SY-DATUM,
    AEDAT_LOCAL = @SY-DATLO,
    AETIM = @SY-UZEIT,
    AETIM_LOCAL = @SY-TIMLO,
    AENAM = @SY-UNAME
    WHERE BUKRS EQ @GS_DAY-BUKRS
    AND EKORG EQ @GS_DAY-EKORG
    AND WERKS EQ @GS_DAY-WERKS
    AND LIFNR EQ @GS_DAY-LIFNR
    AND SPMON EQ @GS_DAY-SPMON
    AND ZDATE  EQ @GS_DAY-ZDATE.

  COMMIT WORK.


  CV_CHECK = GC_S.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_DATA_AFTER_SAVE_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_ALV_DATA_AFTER_SAVE_ITEM .

  "ALV 적용
  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
    CHECK <LS_ITEM>-ZCHG EQ ABAP_TRUE.
    CASE <LS_ITEM>-ZSTAT.
      WHEN ICON_DELETE. "삭제
        DELETE GT_ITEM.
        CONTINUE.
      WHEN ICON_CREATE OR ICON_CHANGE. "신규/수정

        IF <LS_ITEM>-ZSTAT EQ ICON_CREATE.
          READ TABLE <LS_ITEM>-ZSTYLE WITH KEY FIELDNAME = 'MATNR' TRANSPORTING NO FIELDS.
          IF SY-SUBRC NE 0.
            <LS_ITEM>-ZSTYLE = VALUE #( BASE <LS_ITEM>-ZSTYLE ( FIELDNAME = 'MATNR' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).
          ENDIF.
        ENDIF.

        "초기화
        CLEAR:
          <LS_ITEM>-ZSTAT,
          <LS_ITEM>-MESSAGE,
          <LS_ITEM>-ZNEW,
          <LS_ITEM>-ZCHG.

        LOOP AT <LS_ITEM>-IT_PO ASSIGNING FIELD-SYMBOL(<LS_IT_PO>).
          CLEAR:
              <LS_IT_PO>-ZSTAT,
              <LS_IT_PO>-MESSAGE.
        ENDLOOP.
        IF <LS_ITEM>-MATNR EQ GS_ITEM-MATNR.
          LOOP AT GT_PO ASSIGNING FIELD-SYMBOL(<LS_PO>).
            CLEAR:
                <LS_PO>-ZSTAT,
                <LS_PO>-MESSAGE.
          ENDLOOP.
        ENDIF.

    ENDCASE.
  ENDLOOP.


  PERFORM F_REFRESH_ALV USING GO_GRID_100_M.
  PERFORM F_REFRESH_ALV USING GO_GRID_100_B.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_MBST_DOC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_HEADRET_S_MAT_DOC
*&      --> LS_HEADRET_S_DOC_YEAR
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM F_MBST_DOC  USING    PV_MAT_DOC
                          PV_DOC_YEAR
                          PV_BUDAT
                 CHANGING CV_CHECK
                                  CV_MESSAGE.

  CLEAR:
     CV_CHECK,
     CV_MESSAGE.

  DATA:
    LS_HEADRET TYPE BAPI2017_GM_HEAD_RET,
    LT_RETURN  TYPE STANDARD TABLE OF BAPIRET2.

  FIELD-SYMBOLS <LS_RETURN> TYPE BAPIRET2.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = PV_MAT_DOC
      MATDOCUMENTYEAR     = PV_DOC_YEAR
      GOODSMVT_PSTNG_DATE = PV_BUDAT
      GOODSMVT_PR_UNAME   = SY-UNAME
    IMPORTING
      GOODSMVT_HEADRET    = LS_HEADRET
    TABLES
      RETURN              = LT_RETURN.

  IF LS_HEADRET IS NOT INITIAL.
    CV_CHECK = GC_S.
    "Commit
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.
  ELSE.
    CV_CHECK = GC_E.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY TYPE = GC_E.
    IF SY-SUBRC NE 0.
      READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY TYPE = GC_A.
      IF SY-SUBRC NE 0.
        READ TABLE LT_RETURN ASSIGNING <LS_RETURN> WITH KEY TYPE = GC_W.
      ENDIF.
    ENDIF.
    IF SY-SUBRC EQ 0.
      CV_MESSAGE = <LS_RETURN>-MESSAGE.
    ELSE.
      MESSAGE S000 WITH TEXT-ZZ1 PV_MAT_DOC PV_DOC_YEAR INTO CV_MESSAGE. "자재문서 취소 오류
    ENDIF.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ITEM_DATA_REFRESH_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DAY
*&---------------------------------------------------------------------*
FORM F_SET_ITEM_DATA_REFRESH_100  USING  PS_DAY TYPE TY_DAY.

  "초기화
  CLEAR:
    GT_ITEM[],
    GT_PO[].

  "실적 조회
  PERFORM F_GET_DATA_ZGTMMT4272 USING GS_DAY.

  IF GS_DAY-ZGR EQ ABAP_TRUE.
    "입고 처리된 경우
    PERFORM F_GET_DATA_ZGTMMT4274.
  ELSE.
    "입고 처리 전
    PERFORM F_GET_DATA_PO.
  ENDIF.

  DATA:
    LT_DUPL  TYPE TY_T_KEY_ITEM,
    LT_FNAME TYPE TY_T_FNAME.

  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
    PERFORM F_CHECK_VALUES_GT_ITEM USING LT_DUPL LT_FNAME CHANGING <LS_ITEM>.
  ENDLOOP.

*"드럼 실적 상세 (작업일자)
*EX) 드럼 실적 상세 (2026.01.01)
*
*작업일자는 GT_HEAD의 SELECTED ROW - ZDATE (작업일자) 필드 값"

  GS_LAYO_100_M-GRID_TITLE = |{ TEXT-AT2 } ({ PS_DAY-ZDATE+0(4) }.{ PS_DAY-ZDATE+4(2) }.{ PS_DAY-ZDATE+6(2) })|.
  CALL METHOD GO_GRID_100_M->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO_100_M.

  GS_LAYO_100_B-GRID_TITLE = TEXT-AT3.
  CALL METHOD GO_GRID_100_B->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO_100_B.

  "ALV Refresh
  PERFORM F_REFRESH_ALV USING GO_GRID_100_M.
  PERFORM F_REFRESH_ALV USING GO_GRID_100_B.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_MON_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_MON_LIST .

  CLEAR:
    GT_MON[],
    GT_SUM[],
    GT_LV[].

  "합계 데이터 조회
  PERFORM F_SET_GT_SUM_LIST.

  "월 데이터 조회
  PERFORM F_SET_GT_MON_LIST.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_GT_MON_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_GT_MON_LIST .

  SELECT
    ZZ~BUKRS,
    ZZ~EKORG,
    ZZ~WERKS,
    ZZ~LIFNR,
    ZZ~SPMON,
    ZZ~WAERS,
    SUM( ZZ~SDR_PRICE ) AS SDR_PRICE_SUM,
    SUM( ZZ~GDR_PRICE ) AS GDR_PRICE_SUM,
    SUM( ZZ~BOARD_PRICE ) AS BOARD_PRICE_SUM,
    SUM( ZZ~MARK_N_PRICE +  ZZ~MARK_H_PRICE ) AS MARK_PRICE_SUM,
    SUM( ZZ~DIS_PRICE ) AS DIS_PRICE_SUM
    FROM @GT_SUM AS ZZ
    GROUP BY ZZ~BUKRS,ZZ~EKORG, ZZ~WERKS, ZZ~LIFNR, ZZ~SPMON, ZZ~WAERS
    ORDER BY ZZ~BUKRS,ZZ~EKORG, ZZ~WERKS, ZZ~LIFNR, ZZ~SPMON, ZZ~WAERS
    INTO CORRESPONDING FIELDS OF TABLE @GT_MON.

  CHECK GT_MON[] IS NOT INITIAL.
  READ TABLE GT_MON ASSIGNING FIELD-SYMBOL(<LS_MON>) INDEX 1.

*4-1) DATA SELECT
*   ZGTMMR4270에서 P_BUKRS, P_WERKS, P_LIFNR, P_SPMON 기준으로 SELECT
*   (단건 조회됨)
  SELECT SINGLE
    Z1~ADJUST,
    Z1~WAERS,
    Z1~TEXT
    FROM ZGTMMT4270 AS Z1
    WHERE Z1~BUKRS EQ @P_BUKRS
    AND Z1~WERKS EQ @P_WERKS
    AND Z1~LIFNR EQ @P_LIFNR
    AND Z1~SPMON EQ @P_SPMON
    INTO @DATA(LS_ZGTMMR4270).
  IF SY-SUBRC EQ 0.
    <LS_MON> = CORRESPONDING #( BASE ( <LS_MON> ) LS_ZGTMMR4270 ).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_GT_SUM_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_GT_SUM_LIST .

  SELECT
    *
    FROM ZGTMM_CV_DRUM_RESULT AS V1
    WHERE V1~BUKRS EQ @P_BUKRS
    AND V1~WERKS EQ @P_WERKS
    AND V1~LIFNR EQ @P_LIFNR
    AND V1~SPMON EQ @P_SPMON
    ORDER BY V1~DRM_TYPE, V1~DRM_LV
    INTO CORRESPONDING FIELDS OF TABLE @GT_SUM.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CONV_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CONV_200 .

  IF GV_EDIT EQ ABAP_TRUE.
    GV_EDIT = SPACE.

    "월 데이터 조회
    PERFORM F_SET_GT_MON_LIST.
  ELSE.
    GV_EDIT = ABAP_TRUE.
  ENDIF.

  "필드카탈로그 설정
  PERFORM F_ADJ_FCAT_200_T.

  CALL METHOD GO_GRID_200_T->SET_FRONTEND_FIELDCATALOG
    EXPORTING
      IT_FIELDCATALOG = GT_FCAT_200_T.

  CALL METHOD GO_GRID_200_T->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO_200_T.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SAVE_200 .

*저장                   "회사코드, 플랜트, 공급업체, 작업월 기준으로 ZGTMMT4270 MODIFY
*
*POP UP TO CONFIRM
*일 상세 실적을 저장 하시겠습니까? (예/아니오)
*
*성공/실패에 따른 메시지 출력"
  DATA LV_CHECK TYPE C LENGTH 1.
  CALL METHOD GO_GRID_200_T->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.
  CHECK LV_CHECK EQ ABAP_TRUE.

  DATA LV_ANS TYPE C LENGTH 1.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT3 "확인
      TEXT_QUESTION = TEXT-Q06
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

  CHECK GT_MON[] IS NOT INITIAL.
  READ TABLE GT_MON ASSIGNING FIELD-SYMBOL(<LS_MON>) INDEX 1.

  DATA LS_ZGTMMT4270 TYPE ZGTMMT4270.
  LS_ZGTMMT4270-BUKRS = <LS_MON>-BUKRS.
  LS_ZGTMMT4270-EKORG = <LS_MON>-EKORG.
  LS_ZGTMMT4270-WERKS = <LS_MON>-WERKS.
  LS_ZGTMMT4270-LIFNR = <LS_MON>-LIFNR.
  LS_ZGTMMT4270-SPMON = <LS_MON>-SPMON.
  LS_ZGTMMT4270-ADJUST = <LS_MON>-ADJUST.
  LS_ZGTMMT4270-TEXT = <LS_MON>-TEXT.
  LS_ZGTMMT4270-WAERS = <LS_MON>-WAERS.

  SELECT SINGLE
    ERDAT,
    ERDAT_LOCAL,
    ERTIM,
    ERTIM_LOCAL,
    ERNAM
    FROM ZGTMMT4270
    WHERE BUKRS EQ @<LS_MON>-BUKRS
    AND EKORG EQ @<LS_MON>-EKORG
    AND WERKS EQ @<LS_MON>-WERKS
    AND LIFNR EQ @<LS_MON>-LIFNR
    AND SPMON EQ @<LS_MON>-SPMON
    INTO @DATA(LS_ORG).
  IF SY-SUBRC EQ 0.
    LS_ZGTMMT4270 = CORRESPONDING #( BASE ( LS_ZGTMMT4270 ) LS_ORG ).
  ELSE.
    LS_ZGTMMT4270-ERDAT = SY-DATUM.
    LS_ZGTMMT4270-ERDAT_LOCAL = SY-DATLO.
    LS_ZGTMMT4270-ERTIM = SY-UZEIT.
    LS_ZGTMMT4270-ERTIM_LOCAL = SY-TIMLO.
    LS_ZGTMMT4270-ERNAM = SY-UNAME.
  ENDIF.

  LS_ZGTMMT4270-AEDAT = SY-DATUM.
  LS_ZGTMMT4270-AEDAT_LOCAL = SY-DATLO.
  LS_ZGTMMT4270-AETIM = SY-UZEIT.
  LS_ZGTMMT4270-AETIM_LOCAL = SY-TIMLO.
  LS_ZGTMMT4270-AENAM = SY-UNAME.

  MODIFY ZGTMMT4270 FROM LS_ZGTMMT4270.
  COMMIT WORK.

  MESSAGE S000 WITH TEXT-M02. "저장에 성공했습니다.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DISP_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DISP_LIST .

  CLEAR GT_DISP[].

  SELECT
    Z1~BUKRS,
    Z1~EKORG,
    Z1~WERKS,
    Z1~LIFNR,
    Z1~SPMON,
    Z1~ZDATE,
    Z2~MATNR,
    MT~MAKTX,
    Z2~DRM_TYPE,
    Z2~DRM_LV,
    Z2~DRM_SG_TYPE,
    Z2~DRM_COUNT,
    Z2~DRM_NETPR,
    Z2~DRM_PRICE,
    Z2~BOARD_COUNT,
    Z2~BOARD_NETPR,
    Z2~BOARD_PRICE,
    Z2~MARK_COUNT,
    Z2~MARK_NETPR,
    Z2~MARK_PRICE,
    Z2~MARK_N_COUNT,
    Z2~MARK_N_NETPR,
    Z2~MARK_N_PRICE,
    Z2~MARK_H_COUNT,
    Z2~MARK_H_NETPR,
    Z2~MARK_H_PRICE,
    Z2~DIS_COUNT,
    Z2~DIS_NETPR,
    Z2~DIS_PRICE,
    Z2~MEINS,
    Z2~WAERS
  FROM ZGTMMT4271 AS Z1
            INNER JOIN
          ZGTMMT4272 AS Z2 ON Z1~EKORG EQ Z2~EKORG
                                      AND Z1~WERKS EQ Z2~WERKS
                                      AND Z1~LIFNR EQ Z2~LIFNR
                                      AND Z1~ZDATE EQ Z2~ZDATE
           LEFT OUTER JOIN
          MAKT AS MT ON Z2~MATNR EQ MT~MATNR
                          AND MT~SPRAS EQ @SY-LANGU

  WHERE Z1~BUKRS EQ @P_BUKRS
  AND Z1~WERKS IN @S_WERKS
  AND Z1~LIFNR IN @S_LIFNR
  AND Z1~ZDATE IN @S_ZDATE
  AND Z2~DRM_TYPE IN @S_TYPE
  AND Z2~DRM_SG_TYPE IN @S_SG_TYP
  AND Z2~DRM_LV IN @S_LV
  AND Z2~MATNR IN @S_MATNR
  INTO CORRESPONDING FIELDS OF TABLE @GT_DISP.

  CHECK GT_DISP[] IS NOT INITIAL.

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
        FROM @GT_DISP AS ZZ
        WHERE ZZ~MATNR EQ V1~MATNR
    )
    ORDER BY V1~MATNR
    INTO TABLE @DATA(LT_MST).

  LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP>).
    READ TABLE LT_MST ASSIGNING FIELD-SYMBOL(<LS_MST>) WITH KEY MATNR = <LS_DISP>-MATNR BINARY SEARCH.
    CHECK SY-SUBRC EQ 0.

    <LS_DISP>-DRM_GUBUN = <LS_MST>-DRM_GUBUN.
    <LS_DISP>-DRM_SIZE = <LS_MST>-DRM_SIZE.

  ENDLOOP.

  DELETE GT_DISP WHERE DRM_GUBUN NOT IN S_GUBUN.
  DELETE GT_DISP WHERE DRM_SIZE NOT IN S_SIZE.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CALC_PRICE_GT_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- CS_ITEM
*&---------------------------------------------------------------------*
FORM F_CALC_PRICE_GT_ITEM  CHANGING CS_ITEM LIKE GS_ITEM.

*DRM_PRICE    PRICE = COUNT * NETPR 로 계산
*BOARD_PRICE
*DIS_PRICE
  CS_ITEM-DRM_PRICE = CS_ITEM-DRM_COUNT * CS_ITEM-DRM_NETPR.
  CS_ITEM-BOARD_PRICE = CS_ITEM-BOARD_COUNT * CS_ITEM-BOARD_NETPR.
  CS_ITEM-DIS_PRICE = CS_ITEM-DIS_COUNT * CS_ITEM-DIS_NETPR.

*MARK_H_PRICE   PRICE = COUNT * NETPR 로 계산
*MARK_N_PRICE
  CS_ITEM-MARK_N_PRICE = CS_ITEM-MARK_N_COUNT * CS_ITEM-MARK_N_NETPR.
  CS_ITEM-MARK_H_PRICE = CS_ITEM-MARK_H_COUNT * CS_ITEM-MARK_H_NETPR.

*MARK_PRICE   "1) 한전+일반으로 총액 계산
*PRICE = H_PRICE + N_PRICE
*
*2) NETPR 역산
*NETPR = PRICE / COUNT"
  CS_ITEM-MARK_PRICE = CS_ITEM-MARK_N_PRICE + CS_ITEM-MARK_H_PRICE.
  IF CS_ITEM-MARK_COUNT IS NOT INITIAL.
    CS_ITEM-MARK_NETPR = CS_ITEM-MARK_PRICE / CS_ITEM-MARK_COUNT.
  ELSE.
    CS_ITEM-MARK_NETPR = 0.
  ENDIF.

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

  CALL METHOD GO_GRID_100_T->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_100_M->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  CALL METHOD GO_GRID_100_B->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  DATA LV_ANS TYPE C LENGTH 1.
  SELECT SINGLE @ABAP_TRUE
    FROM @GT_ITEM AS ZZ
    WHERE ZZ~ZCHG EQ @ABAP_TRUE
    INTO @DATA(LV_CHK_M).

  SELECT SINGLE @ABAP_TRUE
    FROM @GT_DAY AS ZZ
    WHERE ZZ~ZCHG EQ @ABAP_TRUE
    INTO @DATA(LV_CHK_T).

  IF LV_CHK_M EQ ABAP_TRUE OR LV_CHK_T EQ ABAP_TRUE.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR      = TEXT-TT3 "확인
        TEXT_QUESTION = TEXT-Q07
      IMPORTING
        ANSWER        = LV_ANS.
    CHECK LV_ANS EQ GC_1.
  ENDIF.

  CLEAR:
    GS_DAY,
    GS_ITEM,
    GT_DAY[],
    GT_ITEM[],
    GT_PO[].

  "데이터 다시 조회
  PERFORM F_GET_DAY_LIST.

  GS_LAYO_100_M-GRID_TITLE = TEXT-AT2.
  GS_LAYO_100_B-GRID_TITLE = TEXT-AT3.

  CALL METHOD GO_GRID_100_M->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO_100_M.

  CALL METHOD GO_GRID_100_B->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO_100_B.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_DEFAULT_ENTRY_QNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_DEFAULT_ENTRY_QNT .

  CHECK GT_ITEM[] IS NOT INITIAL.

*(+) GT_ITEM-IT_PO-ENTRY_QNT 초기 값 할당 로직
*	실행 위치: GT_HEAD 더블클릭하며 PO 전체 가져올 때 최초 1회 할당


*1) ZGTMMT4273에서 해당일자, 자재, PO 기준으로 입고 수량 정보 가져옴
*	조회 조건: BUKRS, WERKS, LIFNR, ZDATE, MATNR, EBELN
  SELECT
    Z1~MATNR,
    Z1~EBELN,
    Z1~DRM_COUNT,
    Z1~DRM_COUNT AS REMAIN_COUNT  " 260526 동일 PO 자재 중복 CASE 처리용 잔여 수량 필드 추가
    FROM ZGTMMT4273 AS Z1
    WHERE Z1~BUKRS EQ @GS_DAY-BUKRS
    AND Z1~WERKS EQ @GS_DAY-WERKS
    AND Z1~LIFNR EQ @GS_DAY-LIFNR
    AND Z1~ZDATE EQ @GS_DAY-ZDATE
    AND Z1~DRM_COUNT IS NOT INITIAL
    ORDER BY Z1~MATNR, Z1~EBELN
    INTO TABLE @DATA(LT_QTY).


  FIELD-SYMBOLS <LS_PO> TYPE TY_PO.
  DATA LV_DRM_COUNT TYPE ZGTMMT4273-DRM_COUNT.

  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
    CHECK <LS_ITEM>-DRM_COUNT IS NOT INITIAL. "드럼 입고 수량이 있는 경우

    CHECK <LS_ITEM>-IT_PO[] IS NOT INITIAL.
    LV_DRM_COUNT = <LS_ITEM>-DRM_COUNT.

    "정렬
*"동일한 조건의 ZGTMMT4273-DRM_COUNT 값을 할당
*- 동일 PO에 항번 2개인 경우, 납품 요청일순 할당"
    SORT <LS_ITEM>-IT_PO[] BY EBELN EINDT.

*    2) DRM_COUNT 값 만큼 해당 PO에 입고수량 할당
*	GT_ITEM-IT_PO-ENTRY_QNT = ZGTMMT4273-DRM_COUNT
    LOOP AT <LS_ITEM>-IT_PO[] ASSIGNING <LS_PO>.
      READ TABLE LT_QTY ASSIGNING FIELD-SYMBOL(<LS_QTY>) WITH KEY MATNR = <LS_PO>-MATNR
                                                                                                   EBELN = <LS_PO>-EBELN BINARY SEARCH.
      IF SY-SUBRC EQ 0.

        "<--260526 동일 PO 자재 중복 CASE 고려 수정
        IF LV_DRM_COUNT GE <LS_QTY>-DRM_COUNT.

          " PO 잔여수량이 할당 잔여수량보다 작은 경우 구매오더 수량만큼만 할당
          IF <LS_PO>-REMAIN_QNT LE <LS_QTY>-REMAIN_COUNT.
            <LS_PO>-ENTRY_QNT = <LS_PO>-REMAIN_QNT.
          ELSE.
            <LS_PO>-ENTRY_QNT = <LS_QTY>-REMAIN_COUNT.
          ENDIF.

          <LS_QTY>-REMAIN_COUNT = <LS_QTY>-REMAIN_COUNT - <LS_PO>-ENTRY_QNT. " 잔여 수량 차감

          LV_DRM_COUNT -= <LS_PO>-ENTRY_QNT.
*           <LS_PO>-ENTRY_QNT = <LS_QTY>-DRM_COUNT.
*          LV_DRM_COUNT -= <LS_QTY>-DRM_COUNT.
          "260526 동일 PO 자재 중복 CASE 고려 수정 -->
        ELSE.
          <LS_PO>-ENTRY_QNT = LV_DRM_COUNT.
          EXIT.
        ENDIF.
        IF LV_DRM_COUNT LE 0.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    "IT_PO-VBELN = SPACE 인 경우 MTS PO로 판단
*(GT_ITEM-DRM_COUNT - MTO에 할당된 수량) 만큼을 MTS에 할당"
*"[할당 PO 순서]
*1. EINDT - 납품요청일(오름차순)
*2. AEDAT - 생성일(오름차순)
*3. EBELN - PO번호(오름차순)
*4. EBELP - 항번(오름차순)
*
*[ENTRY_QNT 값]
*남은 수량 or 해당 PO의 REMAIN_QNT (잔여수량)
*--> 초과납품/무제한 고려 X"
*

    CHECK LV_DRM_COUNT GE 0. "드럼입고 적용 대상이 남이 있는 경우 남은 수량을 MTS PO에 적용
    "정렬
    SORT <LS_ITEM>-IT_PO[] BY EINDT AEDAT EBELN EBELP.
    LOOP AT <LS_ITEM>-IT_PO[] ASSIGNING <LS_PO>.
      READ TABLE LT_QTY WITH KEY MATNR = <LS_PO>-MATNR
                                                      EBELN = <LS_PO>-EBELN BINARY SEARCH TRANSPORTING NO FIELDS.
      CHECK SY-SUBRC NE 0. "실적에 없는 경우
      CHECK <LS_PO>-VBELN IS INITIAL AND <LS_PO>-ENTRY_QNT IS INITIAL.

      IF LV_DRM_COUNT GE <LS_PO>-REMAIN_QNT.
        <LS_PO>-ENTRY_QNT = <LS_PO>-REMAIN_QNT.
        LV_DRM_COUNT -= <LS_PO>-REMAIN_QNT.
      ELSE.
        <LS_PO>-ENTRY_QNT = LV_DRM_COUNT.
        EXIT.
      ENDIF.

      IF LV_DRM_COUNT LE 0.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

  "PO 수량 적용
  LOOP AT GT_ITEM ASSIGNING <LS_ITEM>.
    CHECK <LS_ITEM>-DRM_COUNT IS NOT INITIAL.

    LOOP AT <LS_ITEM>-IT_PO ASSIGNING <LS_PO>.
      <LS_ITEM>-PO_COUNT += <LS_PO>-ENTRY_QNT.
    ENDLOOP.
  ENDLOOP.
*      "데이터 점검
*      PERFORM F_CHECK_VALUES_GT_PO CHANGING LS_PO.
ENDFORM.
