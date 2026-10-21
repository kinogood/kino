*&---------------------------------------------------------------------*
*& Include          ZGTMMR1120F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form F_INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_INITIALIZATION .

  "T-code 구분
  CASE SY-TCODE.
    WHEN 'ZGTMMR1120'.
      GV_MNG = ABAP_TRUE.
    WHEN OTHERS.
      GV_MNG = SPACE.
  ENDCASE.

  "버튼
  IF GV_MNG EQ ABAP_TRUE.
    DATA LS_BTN TYPE SMP_DYNTXT.
    LS_BTN-ICON_ID = ICON_LIST.
    LS_BTN-ICON_TEXT = TEXT-BT1.
    LS_BTN-QUICKINFO = TEXT-QI1.
    SSCRFIELDS-FUNCTXT_01 = LS_BTN.
  ENDIF.

  "자재그룹명
  CLEAR GT_T023T[].
  SELECT
    MATKL,
    WGBEZ
    FROM T023T
    WHERE SPRAS EQ @SY-LANGU
    ORDER BY MATKL
    INTO TABLE @GT_T023T.

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

  "Title 설정
  CHECK SY-DYNNR NE '1100'.

  CASE GV_MNG.
    WHEN ABAP_TRUE.
      SET TITLEBAR '1000'. "비상비 자재 관리
    WHEN OTHERS.
      SET TITLEBAR '1001'. "비상비 자재 조회
  ENDCASE.

  "Screen 필드 속성 설정
  LOOP AT SCREEN.

    CASE SCREEN-GROUP1.
      WHEN 'DIS'.
        IF P_DISP EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.

      WHEN 'TCD'.
        IF GV_MNG EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
        MODIFY SCREEN.

      WHEN 'BUK'.
        SCREEN-REQUIRED = 2.
        MODIFY SCREEN.

    ENDCASE.
  ENDLOOP.

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

  CHECK SY-UCOMM EQ 'ONLI'
        OR SY-UCOMM EQ 'FC01'.

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
*& Form F_START_OF_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_START_OF_SELECTION .

  "입력 값 점검
  PERFORM F_CHECK_INPUT_VALUES_1000.

  "코드 값 조회
  PERFORM F_GET_COMMON_CODE.

  CASE ABAP_TRUE.
    WHEN P_NEW. "생성
      PERFORM F_GET_DATA_NEW.

    WHEN P_DISP. "조회/변경
      PERFORM F_GET_DATA_DISP.
  ENDCASE.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_INPUT_VALUES_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CHECK_INPUT_VALUES_1000 .

  "오류가 있으면 종료
  IF GV_ERROR EQ ABAP_TRUE.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_AT_SELECTION_SCREEN .

  CASE SY-UCOMM.
    WHEN 'FC01'.
      PERFORM F_CALL_SCREEN_900.
  ENDCASE.

ENDFORM.

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
               ID 'P_1BUKRS' FIELD P_1BUKRS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_1BUKRS'.
  MESSAGE E172 WITH P_1BUKRS."회사코드[&] 작업권한을 확인하세요.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CALL_SCREEN_900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CALL_SCREEN_900 .

  CHECK GV_ERROR NE ABAP_TRUE. "오류가 없는 경우 진행

  "기존 데이터 조회
  PERFORM F_GET_DATA_MRO1.

  "대분류 자재 점검
  PERFORM F_CHECK_MAT_MRO1.

  "화면호출
  CLEAR GV_EDIT. "기본으로 조회모드
  CALL SCREEN 900.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DATA_MRO1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DATA_MRO1 .

  "초기화
  CLEAR:
    GS_MRO1,
    GT_MRO1[],
    GT_MRO2[].

  SELECT
    Z1~BUKRS,
    Z1~MRO_TYPE1,
    Z1~MRO_TEXT1,
    Z1~MATKL,
    T1~WGBEZ
    FROM ZGTMMT1121 AS Z1
                LEFT OUTER JOIN
            T023T AS T1 ON Z1~MATKL EQ T1~MATKL
                            AND T1~SPRAS EQ @SY-LANGU
    WHERE Z1~BUKRS EQ @P_BUKRS
    INTO CORRESPONDING FIELDS OF TABLE @GT_MRO1.

  CHECK GT_MRO1[] IS NOT INITIAL.

  SORT GT_MRO1[]  BY MRO_TYPE1.

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

  LOOP AT GT_MRO1 ASSIGNING FIELD-SYMBOL(<LS_MRO1>).
    "라인별 점검
    PERFORM F_CHECK_LINE_DATA_MRO1 USING LT_KEY LT_TEXT LT_MRO2 CHANGING <LS_MRO1>.

    "스타일
    <LS_MRO1>-ZSTYLE = VALUE #( ( FIELDNAME = 'MRO_TYPE1' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                                                       ( FIELDNAME = 'MATKL' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )  ).
  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_LINE_DATA_MRO1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_KEY
*&      <-- <LS_MRO1>
*&---------------------------------------------------------------------*
FORM F_CHECK_LINE_DATA_MRO1  USING  PT_KEY TYPE TY_T_MRO1_KEY
                                                                  PT_TEXT TYPE TY_T_MRO1_TEXT
                                                                  PT_MRO2 TYPE TY_T_MRO2
                             CHANGING CS_MRO1 TYPE TY_MRO1.
  DATA:
    LV_MSG TYPE BAPI_MSG,
    LT_MSG TYPE STANDARD TABLE OF TY_MSG_T.

*그 外
  CS_MRO1-STATUS = ICON_LED_GREEN.
  CS_MRO1-MESSAGE = SPACE.

* 누락
  CLEAR LV_MSG.

*대분류 누락             GT_MRO1-MRO_TYPE1 IS INITIAL      누락: 대분류
  IF CS_MRO1-MRO_TYPE1 IS INITIAL.
    CS_MRO1-STATUS = ICON_LED_RED.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }, { TEXT-H04 }|. ""대분류
    ELSE.
      LV_MSG = TEXT-H04. "대분류
    ENDIF.
  ENDIF.

*대분류명 누락              GT_MRO1-MRO_TEXT1 IS INITIAL      누락: 대분류명
  IF CS_MRO1-MRO_TEXT1 IS INITIAL.
    CS_MRO1-STATUS = ICON_LED_RED.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }, { TEXT-H05 }|. ""대분류명
    ELSE.
      LV_MSG = TEXT-H05. "대분류명
    ENDIF.
  ENDIF.

*자재그룹 누락              GT_MRO1-MRO_MATKL IS INITIAL      누락: 자재그룹
  IF CS_MRO1-MATKL IS INITIAL.
    CS_MRO1-STATUS = ICON_LED_RED.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }, { TEXT-H06 }|. ""자재그룹
    ELSE.
      LV_MSG = TEXT-H06. "자재그룹
    ENDIF.
  ENDIF.

  IF LV_MSG IS NOT INITIAL.
    "누락:
    LV_MSG = |{ TEXT-E01 } { LV_MSG } |.
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = LV_MSG  ) ).
  ENDIF.


* 중복
  CLEAR LV_MSG.

*대분류 중복             GT_MRO1 안에서 MRO_TYPE1 중복      중복: 대분류
  READ TABLE PT_KEY WITH KEY MRO_TYPE1 = CS_MRO1-MRO_TYPE1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CS_MRO1-STATUS = ICON_LED_RED.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }, { TEXT-H04 }|. ""대분류
    ELSE.
      LV_MSG = TEXT-H04. "대분류
    ENDIF.
  ENDIF.

*대분류명 중복              GT_MRO1 안에서 MRO_TEXT1 중복      중복: 대분류명
  READ TABLE PT_TEXT WITH KEY MRO_TEXT1 = CS_MRO1-MRO_TEXT1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CS_MRO1-STATUS = ICON_LED_RED.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }, { TEXT-H05 }|. ""대분류명
    ELSE.
      LV_MSG = TEXT-H05. "대분류명
    ENDIF.
  ENDIF.

  IF LV_MSG IS NOT INITIAL.
    "중복:
    LV_MSG = |{ TEXT-E02 } { LV_MSG } |.
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = LV_MSG  ) ).
  ENDIF.

* 오류
  CLEAR LV_MSG.
*자재그룹 오류 (MRO 아닌 자재그룹 지정)             GT_MRO1-MATKL이 M0으로 시작하지 않음     오류: 자재그룹(MRO 그룹만 지정 가능)
  IF CS_MRO1-MATKL+0(2) NE 'M0'.
    CS_MRO1-STATUS = ICON_LED_RED.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }, { TEXT-E04 }|. ""자재그룹(MRO 그룹만 지정 가능)
    ELSE.
      LV_MSG = TEXT-E04. "자재그룹(MRO 그룹만 지정 가능)
    ENDIF.
  ENDIF.

  IF LV_MSG IS NOT INITIAL.
    "오류:
    LV_MSG = |{ TEXT-E03 } { LV_MSG } |.
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = LV_MSG  ) ).
  ENDIF.

  IF CS_MRO1-STATUS EQ ICON_LED_GREEN. "빨간색이 아닌 경우
*하위 중분류가 없는 경우              GT_MRO1-MRO_TYPE1 에 해당하는 ZGTMMT1122 테이블 데이터 없는 경우     하위 중분류 미존재
    READ TABLE PT_MRO2 WITH KEY MRO_TYPE1 = CS_MRO1-MRO_TYPE1 TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      CS_MRO1-STATUS = ICON_LED_YELLOW.
      LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = TEXT-W01  ) ).
    ENDIF.
  ENDIF.

  "메세지 설정
  LOOP AT LT_MSG ASSIGNING FIELD-SYMBOL(<LS_MSG>).
    IF CS_MRO1-MESSAGE IS NOT INITIAL.
      CS_MRO1-MESSAGE = |{ CS_MRO1-MESSAGE }, { <LS_MSG>-MESSAGE }|.
    ELSE.
      CS_MRO1-MESSAGE = <LS_MSG>-MESSAGE.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CONV_900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CONV_900 .

  IF GV_EDIT EQ ABAP_TRUE.
    GV_EDIT = SPACE.
    "데이터 다시 조회
    PERFORM F_GET_DATA_MRO1.

    "대분류 자재 다시 점검
    PERFORM F_CHECK_MAT_MRO1.

    "중분류 ALV 타이틀 설정
    PERFORM F_SET_ALV_TITLE_900_B.


  ELSE.
    GV_EDIT = ABAP_TRUE.
  ENDIF.

  "필드카탈로그 설정
  PERFORM F_ADJ_FCAT_900_T.
  PERFORM F_ADJ_FCAT_900_B.

  CALL METHOD GO_GRID_900_T->SET_FRONTEND_FIELDCATALOG
    EXPORTING
      IT_FIELDCATALOG = GT_FCAT_900_T.

  CALL METHOD GO_GRID_900_T->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO_900_T.

  CALL METHOD GO_GRID_900_B->SET_FRONTEND_FIELDCATALOG
    EXPORTING
      IT_FIELDCATALOG = GT_FCAT_900_B.

  CALL METHOD GO_GRID_900_B->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO_900_B.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_MAT_MRO1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CHECK_MAT_MRO1 .

  CHECK GT_MRO1[] IS NOT INITIAL.
*"SELECT SINGLE @ABAP_TRUE
*FROM ZGTMMT1120
*WHERE BUKRS = P_BUKRS
*AND MRO_TYPE1 = GT_MRO1-MRO_TYPE1"

  SELECT DISTINCT
    Z1~MRO_TYPE1
    FROM ZGTMMT1120 AS Z1
    WHERE EXISTS (
      SELECT @ABAP_TRUE
        FROM @GT_MRO1 AS ZZ
        WHERE ZZ~BUKRS EQ Z1~BUKRS
          AND ZZ~MRO_TYPE1 EQ Z1~MRO_TYPE1
    )
    ORDER BY Z1~MRO_TYPE1
    INTO TABLE @DATA(LT_CHK).

  LOOP AT GT_MRO1 ASSIGNING FIELD-SYMBOL(<LS_MRO1>).
    READ TABLE LT_CHK WITH KEY MRO_TYPE1 = <LS_MRO1>-MRO_TYPE1 TRANSPORTING NO FIELDS.
    CHECK SY-SUBRC EQ 0.
    <LS_MRO1>-CHECK_MAT = ABAP_TRUE.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_MAT_MRO2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CHECK_MAT_MRO2 .

  CHECK GT_MRO2[] IS NOT INITIAL.
*"SELECT SINGLE @ABAP_TRUE
*FROM ZGTMMT1120
*WHERE BUKRS = P_BUKRS
*AND MRO_TYPE1 = GT_MRO2-MRO_TYPE1
*AND MRO_TYPE2 = GT_MRO2-MRO_TYPE2"

  SELECT DISTINCT
    Z1~MRO_TYPE1,
    Z1~MRO_TYPE2
    FROM ZGTMMT1120 AS Z1
    WHERE EXISTS (
      SELECT @ABAP_TRUE
        FROM @GT_MRO2 AS ZZ
        WHERE ZZ~BUKRS EQ Z1~BUKRS
          AND ZZ~MRO_TYPE1 EQ Z1~MRO_TYPE1
          AND ZZ~MRO_TYPE2 EQ Z1~MRO_TYPE2
    )
    ORDER BY Z1~MRO_TYPE1, Z1~MRO_TYPE2
    INTO TABLE @DATA(LT_CHK).

  LOOP AT GT_MRO2 ASSIGNING FIELD-SYMBOL(<LS_MRO2>).
    READ TABLE LT_CHK WITH KEY MRO_TYPE1 = <LS_MRO2>-MRO_TYPE1
                                                   MRO_TYPE2 = <LS_MRO2>-MRO_TYPE2 TRANSPORTING NO FIELDS.
    CHECK SY-SUBRC EQ 0.
    <LS_MRO2>-CHECK_MAT = ABAP_TRUE.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DATA_MRO2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DATA_MRO2 USING PS_MRO1 TYPE TY_MRO1.

  "초기화
  CLEAR:
   GS_MRO1,
   GT_MRO2[].

  GS_MRO1 = PS_MRO1. "더블클릭한 값

  SELECT
    Z1~BUKRS,
    Z1~MRO_TYPE1,
    Z1~MRO_TEXT1,
    Z2~MRO_TYPE2,
    Z2~MRO_TEXT2
    FROM ZGTMMT1121 AS Z1
                INNER JOIN
            ZGTMMT1122 AS Z2 ON Z1~BUKRS EQ Z2~BUKRS
                                       AND Z1~MRO_TYPE1 EQ Z2~MRO_TYPE1
    WHERE Z1~BUKRS EQ @GS_MRO1-BUKRS
    AND Z1~MRO_TYPE1 EQ @GS_MRO1-MRO_TYPE1
    ORDER BY Z2~MRO_TYPE2
    INTO CORRESPONDING FIELDS OF TABLE @GT_MRO2.


  CHECK GT_MRO2[] IS NOT INITIAL.

  "데이터 점검
  DATA:
    LT_KEY  TYPE TY_T_MRO2_KEY,
    LT_TEXT TYPE TY_T_MRO2_TEXT.

  LOOP AT GT_MRO2 ASSIGNING FIELD-SYMBOL(<LS_MRO2>).

    "라인별 점검
    PERFORM F_CHECK_LINE_DATA_MRO2 USING LT_KEY LT_TEXT CHANGING <LS_MRO2>.

    "스타일
    <LS_MRO2>-ZSTYLE = VALUE #( ( FIELDNAME = 'MRO_TYPE2' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).

  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_LINE_DATA_MRO2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_KEY
*&      --> LT_TEXT
*&      <-- <LS_MRO2>
*&---------------------------------------------------------------------*
FORM F_CHECK_LINE_DATA_MRO2  USING    PT_KEY TYPE TY_T_MRO2_KEY
                                      PT_TEXT TYPE TY_T_MRO2_TEXT
                             CHANGING CS_MRO2 TYPE TY_MRO2.

  DATA:
    LV_MSG TYPE BAPI_MSG,
    LT_MSG TYPE STANDARD TABLE OF TY_MSG_T.

*그 外
  CS_MRO2-STATUS = ICON_LED_GREEN.
  CS_MRO2-MESSAGE = SPACE.

* 누락
  CLEAR LV_MSG.

*중분류 누락             GT_MRO2-MRO_TYPE2 IS INITIAL      누락: 중분류
  IF CS_MRO2-MRO_TYPE2 IS INITIAL.
    CS_MRO2-STATUS = ICON_LED_RED.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }, { TEXT-H10 }|. ""중분류
    ELSE.
      LV_MSG = TEXT-H10. "중분류
    ENDIF.
  ENDIF.

*중분류 누락              GT_MRO2-MRO_TEXT2 IS INITIAL      누락: 중분류명
  IF CS_MRO2-MRO_TEXT2 IS INITIAL.
    CS_MRO2-STATUS = ICON_LED_RED.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }, { TEXT-H11 }|. ""중분류명
    ELSE.
      LV_MSG = TEXT-H11. "중분류명
    ENDIF.
  ENDIF.

  IF LV_MSG IS NOT INITIAL.
    "누락:
    LV_MSG = |{ TEXT-E01 } { LV_MSG } |.
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = LV_MSG  ) ).
  ENDIF.

* 중복
  CLEAR LV_MSG.

*중분류 중복             GT_MRO2 안에서 MRO_TYPE2 중복      중복: 중분류
  READ TABLE PT_KEY WITH KEY MRO_TYPE2 = CS_MRO2-MRO_TYPE2 TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CS_MRO2-STATUS = ICON_LED_RED.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }, { TEXT-H10 }|. ""중분류
    ELSE.
      LV_MSG = TEXT-H10. "중분류
    ENDIF.
  ENDIF.

*중분류명 중복              GT_MRO2 안에서 MRO_TEXT2 중복      중복: 중분류명
  READ TABLE PT_TEXT WITH KEY MRO_TEXT2 = CS_MRO2-MRO_TEXT2 TRANSPORTING NO FIELDS.
  IF SY-SUBRC EQ 0.
    CS_MRO2-STATUS = ICON_LED_RED.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }, { TEXT-H11 }|. ""중분류명
    ELSE.
      LV_MSG = TEXT-H11. "중분류명
    ENDIF.
  ENDIF.

  IF LV_MSG IS NOT INITIAL.
    "중복:
    LV_MSG = |{ TEXT-E02 } { LV_MSG } |.
    LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = LV_MSG  ) ).
  ENDIF.

  "메세지 설정
  LOOP AT LT_MSG ASSIGNING FIELD-SYMBOL(<LS_MSG>).
    IF CS_MRO2-MESSAGE IS NOT INITIAL.
      CS_MRO2-MESSAGE = |{ CS_MRO2-MESSAGE }, { <LS_MSG>-MESSAGE }|.
    ELSE.
      CS_MRO2-MESSAGE = <LS_MSG>-MESSAGE.
    ENDIF.
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
    WHEN P_NEW. "생성
      CALL SCREEN 100.

    WHEN P_DISP. "조회/변경
      IF GT_DISP[] IS INITIAL.
        MESSAGE S002 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.
      CALL SCREEN 200.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DATA_NEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DATA_NEW .

  "생성 시 사용 하는 데이터 조회

  "초기화
  CLEAR:
    GT_MRO1[],
    GT_MRO2[].

  "대분류
  SELECT
    Z1~BUKRS,
    Z1~MRO_TYPE1,
    Z1~MRO_TEXT1,
    Z1~MATKL,
    T1~WGBEZ
    FROM ZGTMMT1121 AS Z1
                LEFT OUTER JOIN
            T023T AS T1 ON Z1~MATKL EQ T1~MATKL
                            AND T1~SPRAS EQ @SY-LANGU
    WHERE Z1~BUKRS EQ @P_BUKRS
    ORDER BY Z1~MRO_TYPE1
    INTO CORRESPONDING FIELDS OF TABLE @GT_MRO1.

  "중분류
  SELECT
    Z1~BUKRS,
    Z1~MRO_TYPE1,
    Z1~MRO_TEXT1,
    Z2~MRO_TYPE2,
    Z2~MRO_TEXT2
    FROM ZGTMMT1121 AS Z1
                INNER JOIN
            ZGTMMT1122 AS Z2 ON Z1~BUKRS EQ Z2~BUKRS
                                       AND Z1~MRO_TYPE1 EQ Z2~MRO_TYPE1
    WHERE Z1~BUKRS EQ @P_BUKRS
    ORDER BY Z1~MRO_TYPE1, Z2~MRO_TYPE2
    INTO CORRESPONDING FIELDS OF TABLE @GT_MRO2.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_F4_HELP_MRO_TYPE2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_F4_HELP_MRO_TYPE2 .

  DATA:
    LS_SHLP   TYPE SHLP_DESCR,
    LT_RETVAL TYPE STANDARD TABLE OF DDSHRETVAL.

  CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
    EXPORTING
      SHLPNAME = 'ZGTHMM_MRO2'
    IMPORTING
      SHLP     = LS_SHLP.

  LOOP AT LS_SHLP-INTERFACE ASSIGNING FIELD-SYMBOL(<LS_IF>).
    IF <LS_IF>-SHLPFIELD EQ 'BUKRS'.
      <LS_IF>-VALUE    = P_BUKRS.
    ENDIF.

    IF <LS_IF>-SHLPFIELD EQ 'MRO_TYPE1'.
      <LS_IF>-VALUE    = GS_SCR_102-MRO_TYPE1.
    ENDIF.

    IF <LS_IF>-SHLPFIELD EQ 'MRO_TYPE2'.
      <LS_IF>-VALFIELD = ABAP_TRUE.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
    EXPORTING
      SHLP          = LS_SHLP
    TABLES
      RETURN_VALUES = LT_RETVAL.

  LOOP AT LT_RETVAL ASSIGNING FIELD-SYMBOL(<LS_RETVAL>).
    GS_SCR_102-MRO_TYPE2 = <LS_RETVAL>-FIELDVAL.
    EXIT.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_F4_HELP_MRO_TYPE1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_F4_HELP_MRO_TYPE1 .

  DATA:
    LS_SHLP   TYPE SHLP_DESCR,
    LT_RETVAL TYPE STANDARD TABLE OF DDSHRETVAL.

  CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
    EXPORTING
      SHLPNAME = 'ZGTHMM_MRO1'
    IMPORTING
      SHLP     = LS_SHLP.

  LOOP AT LS_SHLP-INTERFACE ASSIGNING FIELD-SYMBOL(<LS_IF>).
    IF <LS_IF>-SHLPFIELD EQ 'BUKRS'.
      <LS_IF>-VALUE    = P_BUKRS.
    ENDIF.

    IF <LS_IF>-SHLPFIELD EQ 'MRO_TYPE1'.
      <LS_IF>-VALFIELD = ABAP_TRUE.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
    EXPORTING
      SHLP          = LS_SHLP
    TABLES
      RETURN_VALUES = LT_RETVAL.

  LOOP AT LT_RETVAL ASSIGNING FIELD-SYMBOL(<LS_RETVAL>).
    GS_SCR_102-MRO_TYPE1 = <LS_RETVAL>-FIELDVAL.
    EXIT.
  ENDLOOP.

  CHECK LT_RETVAL[] IS NOT INITIAL.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_SCREEN_TEXT_102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_SCREEN_TEXT_102 .

  CLEAR:
   GS_SCR_102-MRO_TEXT1,
   GS_SCR_102-MRO_TEXT2.

  DATA:
    LV_MRO_TYPE1 TYPE ZGTMMT1122-MRO_TYPE1,
    LV_MRO_TYPE2 TYPE ZGTMMT1122-MRO_TYPE2.

  LV_MRO_TYPE1 = |{ GS_SCR_102-MRO_TYPE1 ALPHA = IN }|.
  LV_MRO_TYPE2 = |{ GS_SCR_102-MRO_TYPE2 ALPHA = IN }|.

  READ TABLE GT_MRO1 ASSIGNING FIELD-SYMBOL(<LS_MRO1>) WITH KEY MRO_TYPE1 = LV_MRO_TYPE1 BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    GS_SCR_102-MRO_TEXT1 = <LS_MRO1>-MRO_TEXT1.
  ENDIF.

  READ TABLE GT_MRO2 ASSIGNING FIELD-SYMBOL(<LS_MRO2>) WITH KEY MRO_TYPE1 = LV_MRO_TYPE1
                                                                                         MRO_TYPE2 = LV_MRO_TYPE2 BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    GS_SCR_102-MRO_TEXT2 = <LS_MRO2>-MRO_TEXT2.
  ENDIF.

  "화면에 값 설정
  DATA LT_DYN TYPE STANDARD TABLE OF DYNPREAD.
  LT_DYN = VALUE #( (  FIELDNAME = 'GS_SCR_102-MRO_TEXT1'  FIELDVALUE = GS_SCR_102-MRO_TEXT1  )
                                 (  FIELDNAME = 'GS_SCR_102-MRO_TEXT2'  FIELDVALUE = GS_SCR_102-MRO_TEXT2 ) ).

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_DYN
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      UNDEFIND_ERROR       = 7
      OTHERS               = 8.
  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_TEMPLATE_DOWNLOAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_ZGTMMR1120
*&---------------------------------------------------------------------*
FORM F_TEMPLATE_DOWNLOAD USING  PV_OBJID TYPE W3OBJID.

  DATA:
    LS_WWWDATA           TYPE WWWDATATAB,
    LV_DEFAULT_FILE_NAME TYPE STRING,
    LV_FILENAME          TYPE STRING,
    LV_PATH              TYPE STRING,
    LV_FULLPATH          TYPE STRING,
    LV_RC                TYPE SY-SUBRC.

  CONSTANTS
    LC_FILE_EXT          TYPE W3_NAME VALUE 'fileextension'.

  "SMW0 조회
  SELECT SINGLE *
    FROM WWWDATA
   WHERE OBJID EQ @PV_OBJID
    INTO CORRESPONDING FIELDS OF @LS_WWWDATA.

  IF SY-SUBRC NE 0.
    EXIT.
  ENDIF.

  SELECT SINGLE
    VALUE
    FROM WWWPARAMS
    WHERE RELID EQ @LS_WWWDATA-RELID
    AND OBJID EQ @LS_WWWDATA-OBJID
    AND NAME EQ @LC_FILE_EXT
    INTO @DATA(LV_FILE_EXT).

  LV_DEFAULT_FILE_NAME = LS_WWWDATA-TEXT && LV_FILE_EXT.
  CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG(
    EXPORTING
      DEFAULT_EXTENSION         = CONV STRING( LV_FILE_EXT )
      DEFAULT_FILE_NAME         = LV_DEFAULT_FILE_NAME
      FILE_FILTER               = CONV STRING( LV_FILE_EXT )
    CHANGING
      FILENAME                  = LV_FILENAME
      PATH                      = LV_PATH
      FULLPATH                  = LV_FULLPATH
    EXCEPTIONS
      CNTL_ERROR                = 1
      ERROR_NO_GUI              = 2
      NOT_SUPPORTED_BY_GUI      = 3
      INVALID_DEFAULT_FILE_NAME = 4
      OTHERS                    = 5
  ).

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE GC_S NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
      DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  CHECK LV_FULLPATH IS NOT INITIAL.
  CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
    EXPORTING
      KEY         = LS_WWWDATA
      DESTINATION = CONV LOCALFILE( LV_FULLPATH )
    IMPORTING
      RC          = LV_RC.

  CHECK LV_RC EQ 0.

  CL_GUI_FRONTEND_SERVICES=>EXECUTE(
    EXPORTING
      DOCUMENT               = LV_FULLPATH
    EXCEPTIONS
      CNTL_ERROR             = 1
      ERROR_NO_GUI           = 2
      BAD_PARAMETER          = 3
      FILE_NOT_FOUND         = 4
      PATH_NOT_FOUND         = 5
      FILE_EXTENSION_UNKNOWN = 6
      ERROR_EXECUTE_FAILED   = 7
      SYNCHRONOUS_FAILED     = 8
      NOT_SUPPORTED_BY_GUI   = 9
      OTHERS                 = 10
  ).

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE GC_S NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
      DISPLAY LIKE GC_E.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_EXCEL_UPLOAD_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_EXCEL_UPLOAD_CREATE .

  DATA LV_CHECK TYPE C LENGTH 1.
  CALL METHOD GO_GRID_100_T->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

*"파일 업로드 -> GT_CREATE에 해당 값 채워넣음 (CLEAR하고 아예 덮어씌움)
*GT_CREATE에 값 있는 경우 POPUP TO CONFIRM 창"       "기존 입력값을 엑셀 파일의 값으로 덮어씁니다. 계속 진행하시겠습니까?
*예/아니오"
  IF GT_CREATE[] IS NOT INITIAL.
    DATA:
      LV_ANS  TYPE C LENGTH 1,
      LV_TEXT TYPE STRING.
    LV_TEXT = TEXT-Q04. "기존 입력값을 엑셀 파일의 값으로 덮어씁니다. 계속 진행하시겠습니까?
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR      = TEXT-TT1 "확인
        TEXT_QUESTION = LV_TEXT
      IMPORTING
        ANSWER        = LV_ANS.
    CHECK LV_ANS EQ GC_1.
  ENDIF.

  DATA:
    LV_FILE TYPE RLGRAP-FILENAME,
    LT_XLS  TYPE STANDARD TABLE OF TY_CREATE_XLS.

  "파일명 선택
  PERFORM F_GET_FILE_NAME CHANGING LV_FILE.

  "Excel 조회
  CHECK LV_FILE IS NOT INITIAL.
  PERFORM F_GET_EXCEL_DATA USING 1 3 4 60000 LV_FILE 'TY_CREATE_XLS' CHANGING LT_XLS.

  "데이터 설정
  PERFORM F_SET_ALV_DATA_CREATE USING LT_XLS CHANGING GT_CREATE LV_CHECK.

  "데이터 점검
  PERFORM F_CHECK_ALV_DATA_CREATE.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_FILE_NAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_FILE
*&---------------------------------------------------------------------*
FORM F_GET_FILE_NAME  CHANGING CV_FILE.

  CLEAR CV_FILE.

  DATA:
    LT_FILE_TABLE TYPE FILETABLE,
    LV_SUBRC      TYPE SY-SUBRC,
    LV_ACTION     TYPE I.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      DEFAULT_EXTENSION       = CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
      FILE_FILTER             = CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
    CHANGING
      FILE_TABLE              = LT_FILE_TABLE
      RC                      = LV_SUBRC
      USER_ACTION             = LV_ACTION
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1
      CNTL_ERROR              = 2
      ERROR_NO_GUI            = 3
      NOT_SUPPORTED_BY_GUI    = 4
      OTHERS                  = 5.
  IF SY-SUBRC EQ 0 AND LT_FILE_TABLE[] IS NOT INITIAL.
    READ TABLE LT_FILE_TABLE ASSIGNING FIELD-SYMBOL(<LS_FILE>) INDEX 1.
    CHECK SY-SUBRC EQ 0.
    CV_FILE = <LS_FILE>-FILENAME.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_EXCEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_1
*&      --> P_3
*&      --> P_4
*&      --> P_6000
*&      --> LV_FILE
*&      --> P_
*&      <-- LT_XLS
*&---------------------------------------------------------------------*
FORM F_GET_EXCEL_DATA  USING PV_BEGIN_COL
                                                      PV_BEGIN_ROW
                                                      PV_END_COL
                                                      PV_END_ROW
                                                      PV_FILE
                                                      PV_T_TYPE
                       CHANGING CT_XLS TYPE STANDARD TABLE.
  CLEAR:
     CT_XLS[].

  DATA LT_ITAB TYPE STANDARD TABLE OF ALSMEX_TABLINE.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME                = PV_FILE
      I_BEGIN_COL             = PV_BEGIN_COL
      I_BEGIN_ROW             = PV_BEGIN_ROW
      I_END_COL               = PV_END_COL
      I_END_ROW               = PV_END_ROW
    TABLES
      INTERN                  = LT_ITAB
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2
      OTHERS                  = 3.

  CHECK SY-SUBRC EQ 0.

  DATA:
    LO_DATA    TYPE REF TO DATA,
    LV_COL_IDX TYPE INT4.

  FIELD-SYMBOLS <LS_STRU> TYPE ANY.

  CREATE DATA LO_DATA TYPE (PV_T_TYPE).
  ASSIGN LO_DATA->* TO <LS_STRU>.

  LOOP AT LT_ITAB ASSIGNING FIELD-SYMBOL(<LS_G>) GROUP BY ( ROW = <LS_G>-ROW )
                                                                             ASSIGNING FIELD-SYMBOL(<LS_GROUP>).

    "값 설정
    CLEAR <LS_STRU>.
    LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_XLS>).
      LV_COL_IDX = <LS_XLS>-COL.
      ASSIGN COMPONENT LV_COL_IDX OF STRUCTURE <LS_STRU> TO FIELD-SYMBOL(<LV_VAL>).
      CHECK <LV_VAL> IS ASSIGNED.
      <LV_VAL> = <LS_XLS>-VALUE.
    ENDLOOP.

    "라인추가
    APPEND <LS_STRU> TO CT_XLS.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_DATA_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_XLS
*&      <-- GT_CREATE
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM F_SET_ALV_DATA_CREATE  USING  PT_XLS TYPE TY_T_CREATE_XLS
                            CHANGING CT_CREATE TYPE TY_T_CREATE
                                     CV_CHECK.
  "초기화
  CLEAR:
    CV_CHECK.

  DATA:
    LT_CREATE TYPE STANDARD TABLE OF TY_CREATE,
    LS_CREATE TYPE TY_CREATE.

  SELECT
    MSEHI
    FROM T006
    ORDER BY MSEHI
    INTO TABLE @DATA(LT_UNIT).

  LOOP AT PT_XLS ASSIGNING FIELD-SYMBOL(<LS_XLS>).

    "초기화
    CLEAR LS_CREATE.

    "대문자 변경
    TRANSLATE:
      <LS_XLS>-MRO_TYPE1 TO UPPER CASE,
      <LS_XLS>-MRO_TYPE2 TO UPPER CASE.

    "공백 제거
    CONDENSE:
      <LS_XLS>-MRO_TYPE1,
      <LS_XLS>-MRO_TYPE2.

    LS_CREATE-BUKRS = P_BUKRS.
    LS_CREATE-MAKTX = <LS_XLS>-MAKTX.
    LS_CREATE-MEINS = <LS_XLS>-MEINS.
    LS_CREATE-MRO_TYPE1 = <LS_XLS>-MRO_TYPE1.
    LS_CREATE-MRO_TYPE2 = <LS_XLS>-MRO_TYPE2.

    LS_CREATE-MRO_TYPE1 = |{ LS_CREATE-MRO_TYPE1 ALPHA = IN }|.
    LS_CREATE-MRO_TYPE2 = |{ LS_CREATE-MRO_TYPE2 ALPHA = IN }|.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        INPUT  = LS_CREATE-MEINS
      IMPORTING
        OUTPUT = LS_CREATE-MEINS.

*    기본단위 T006-MSEHI    MEINS 유효하지 않은 단위가 존재합니다.
    READ TABLE LT_UNIT WITH KEY MSEHI = LS_CREATE-MEINS BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      MESSAGE E000 WITH TEXT-E10.
    ENDIF.

*"1.
*대/중분류에는 숫자만 입력이 가능합니다.
*2.
*유효하지 않은 대분류-중분류 조합이 존재합니다."
    READ TABLE GT_MRO2 WITH KEY MRO_TYPE1 = LS_CREATE-MRO_TYPE1
                                            MRO_TYPE2 = LS_CREATE-MRO_TYPE2 BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      MESSAGE E000 WITH TEXT-E11.
    ENDIF.

    "라인추가
    APPEND LS_CREATE TO LT_CREATE.
  ENDLOOP.

  "데이터 적용
  CT_CREATE[] = LT_CREATE[].

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_ALV_DATA_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CHECK_ALV_DATA_CREATE .

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

  FIELD-SYMBOLS:
    <LS_MRO1> TYPE TY_MRO1,
    <LS_MRO2> TYPE TY_MRO2.

  LOOP AT GT_CREATE ASSIGNING FIELD-SYMBOL(<LS_CREATE>).

    READ TABLE GT_MRO1 ASSIGNING <LS_MRO1> WITH KEY MRO_TYPE1 = <LS_CREATE>-MRO_TYPE1 BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_CREATE>-MRO_TEXT1 = <LS_MRO1>-MRO_TEXT1.
      <LS_CREATE>-MATKL = <LS_MRO1>-MATKL.
      <LS_CREATE>-WGBEZ = <LS_MRO1>-WGBEZ.
    ENDIF.

    READ TABLE GT_MRO2 ASSIGNING <LS_MRO2> WITH KEY MRO_TYPE1 = <LS_CREATE>-MRO_TYPE1
                                                                                           MRO_TYPE2 = <LS_CREATE>-MRO_TYPE2 BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_CREATE>-MRO_TEXT2 = <LS_MRO2>-MRO_TEXT2.
    ENDIF.

    "라인별 점검
    PERFORM F_CHECK_LINE_DATA_CREATE USING LT_KEY_ALV LT_KEY_DB LT_TEXT_ALV LT_TEXT_DB CHANGING <LS_CREATE>.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE .

  DATA LV_CHECK TYPE C LENGTH 1.
  CALL METHOD GO_GRID_100_T->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

* 점검에 빨간 불 없는 경우만 가능
  SELECT SINGLE
    @ABAP_TRUE
    FROM @GT_CREATE AS ZZ
    WHERE ZZ~STATUS EQ @ICON_LED_RED "점검 빨간 불인게 있으면 오류
    INTO @DATA(LV_CHK_E).
  IF SY-SUBRC EQ 0.
    MESSAGE E000 WITH TEXT-E12. "오류가 존재하여 생성 할 수 없습니다.
  ENDIF.

* 결과(GT_CREATE-RESULT) 초록불 아닌 LINE들만 대상
  SELECT SINGLE
    @ABAP_TRUE
    FROM @GT_CREATE AS ZZ
    WHERE ZZ~RESULT NE @ICON_LED_GREEN "점검 빨간 불인게 있으면 오류
    INTO @DATA(LV_CHK_G).
  IF SY-SUBRC NE 0.
    MESSAGE E000 WITH TEXT-E13. "생성 대상이 없습니다.
  ENDIF.

* POPUP TO CONFIRM -> 비상비 자재를 생성하시겠습니까? 예/아니오
  DATA:
    LV_ANS  TYPE C LENGTH 1,
    LV_TEXT TYPE STRING.
  LV_TEXT = TEXT-Q05. " 비상비 자재를 생성하시겠습니까?
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1 "확인
      TEXT_QUESTION = LV_TEXT
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

  "기본 뷰 생성
  PERFORM F_CREATE_BASIC_VIEW.

  "기타 뷰 생성(구매/회계)
  PERFORM F_CREATE_ETC_VIEW.

  "메세지
  MESSAGE S000 WITH TEXT-M02.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CREATE_BASIC_VIEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_BASIC_VIEW .

  DATA:
    LV_MTART      TYPE MTART,
    LV_LANGU      TYPE SPRAS,
    LV_LANGU_ISO  TYPE LAISO,
    LV_DIVISION   TYPE SPART,   "2026.07.03 제품군 추가
    LV_CNT        TYPE INT4,
    LV_RUN        TYPE INT4,
    LV_MAT_CNT    TYPE IMATNRANZ,
    LS_RETURN     TYPE BAPIRETURN1,
    LS_RETURN_MAT TYPE BAPIRET2,
    LT_MATNR_TMP  TYPE STANDARD TABLE OF BAPIMATINR,
    LT_MATNR      TYPE STANDARD TABLE OF BAPIMATINR,
    LS_MATNR      TYPE BAPIMATINR.

  DATA LT_CBO TYPE STANDARD TABLE OF ZGTMMT1120.

*  "SELECT *
*FROM ZGTPPT1010
*WHERE MODULE_KIND = 'MM'
*AND CODEGRP = '0060'
*AND FLD_01 = P_BUKRS"
  SELECT SINGLE
    FLD_02, FLD_08, FLD_09, FLD_10  "
    FROM ZGTPPT1010
    WHERE MODULE_KIND EQ 'MM'"2026.07.03 제품군 추가
    AND CODEGRP EQ '0060'
    AND FLD_01 EQ @P_BUKRS
    INTO ( @LV_MTART, @LV_LANGU, @LV_LANGU_ISO, @LV_DIVISION ). "2026.07.03 제품군 추가

  SELECT COUNT( @ABAP_TRUE )
    FROM @GT_CREATE AS ZZ
    WHERE ZZ~MATNR IS INITIAL
    INTO @LV_CNT.

  IF LV_CNT GT 100.
    LV_RUN = ( LV_CNT DIV 100 ) + 1.
  ELSE.
    LV_RUN = 1.
  ENDIF.

  DO LV_RUN TIMES.

    IF LV_CNT GT 100.
      LV_MAT_CNT = 100.
    ELSE.
      LV_MAT_CNT = LV_CNT.
    ENDIF.

    CLEAR LT_MATNR_TMP[].

    IF LV_MAT_CNT GT 0. " 채번 대상 존재하는 경우에만 펑션 사용
      CALL FUNCTION 'BAPI_MATERIAL_GETINTNUMBER'
        EXPORTING
          MATERIAL_TYPE    = LV_MTART
          INDUSTRY_SECTOR  = 'M'
          REQUIRED_NUMBERS = LV_MAT_CNT
        IMPORTING
          RETURN           = LS_RETURN
        TABLES
          MATERIAL_NUMBER  = LT_MATNR_TMP.
    ENDIF.


*성공               아래 프로세스 계속 진행
*실패               하단에 BAPI_MESSAGE 메시지 리턴 후 프로세스 중단
    IF LS_RETURN-TYPE EQ GC_E.
      MESSAGE E000 WITH LS_RETURN-MESSAGE.
    ENDIF.

    APPEND LINES OF LT_MATNR_TMP TO LT_MATNR.

    LV_CNT -= 100.
  ENDDO.


  CHECK LT_MATNR[] IS NOT INITIAL.

  DATA:
    LV_MATNR   TYPE MATNR,
    LS_HEAD    TYPE BAPIMATHEAD,
    LS_CLIENT  TYPE BAPI_MARA,
    LS_CLIENTX TYPE BAPI_MARAX,
    LT_DESC    TYPE STANDARD TABLE OF BAPI_MAKT.

  LOOP AT GT_CREATE  ASSIGNING FIELD-SYMBOL(<LS_CREATE>).
    CHECK <LS_CREATE>-MATNR IS INITIAL
    AND <LS_CREATE>-VIEW_BASIC EQ SPACE.

    CLEAR:
      LS_RETURN_MAT,
      LS_HEAD,
      LS_CLIENT,
      LS_CLIENTX,
      LT_DESC[].

    CLEAR LS_MATNR.
    READ TABLE LT_MATNR INTO LS_MATNR INDEX 1.
    LV_MATNR = LS_MATNR-MATERIAL.

    DELETE LT_MATNR INDEX 1.

    LS_HEAD-MATERIAL = LV_MATNR.
    LS_HEAD-IND_SECTOR = 'M'.
    LS_HEAD-MATL_TYPE = LV_MTART.
    LS_HEAD-BASIC_VIEW = ABAP_TRUE.

    LS_CLIENT-MATL_GROUP = <LS_CREATE>-MATKL.
    LS_CLIENT-BASE_UOM = <LS_CREATE>-MEINS.
    LS_CLIENT-DIVISION = LV_DIVISION. "2026.07.03 제품군 추가

    LS_CLIENTX-MATL_GROUP = ABAP_TRUE.
    LS_CLIENTX-BASE_UOM = ABAP_TRUE.
    LS_CLIENTX-DIVISION = ABAP_TRUE."2026.07.03 제품군 추가

    LT_DESC = VALUE #( ( LANGU = LV_LANGU
                                       LANGU_ISO = LV_LANGU_ISO
                                       MATL_DESC = <LS_CREATE>-MAKTX ) ).

    CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
      EXPORTING
        HEADDATA            = LS_HEAD
        CLIENTDATA          = LS_CLIENT
        CLIENTDATAX         = LS_CLIENTX
      IMPORTING
        RETURN              = LS_RETURN_MAT
      TABLES
        MATERIALDESCRIPTION = LT_DESC.

*성공               "GT_CREATE-VIEW_BASIC = 'X'
*구매뷰/회계뷰 확장 로직 계속 진행"
*실패               "GT_CREATE-MESSAGE = (LS_RETURN-ID && LS_RETURN-NUMBER) LS_RETURN-MESSAGE
*예) (ME123) 유효하지않은 자재유형입니다."
    IF LS_RETURN_MAT-TYPE EQ GC_E.
      <LS_CREATE>-RESULT = ICON_LED_RED.
      <LS_CREATE>-MESSAGE = |({ LS_RETURN_MAT-ID }{ LS_RETURN_MAT-NUMBER }) { LS_RETURN_MAT-MESSAGE }|.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      CONTINUE.
    ELSE.
      <LS_CREATE>-RESULT = ICON_LED_YELLOW.
      <LS_CREATE>-VIEW_BASIC = ABAP_TRUE.
      <LS_CREATE>-SAVE = ABAP_TRUE.
      <LS_CREATE>-MATNR = LV_MATNR.
      <LS_CREATE>-ZSTYLE = VALUE #( ( FIELDNAME = 'MAKTX' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                                                             ( FIELDNAME = 'MEINS' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                                                             ( FIELDNAME = 'MRO_TYPE1' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
                                                             ( FIELDNAME = 'MRO_TYPE2' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).

      LT_CBO = VALUE #( (
        BUKRS = <LS_CREATE>-BUKRS
        MATNR = <LS_CREATE>-MATNR
        MRO_TYPE1 = <LS_CREATE>-MRO_TYPE1
        MRO_TYPE2 = <LS_CREATE>-MRO_TYPE2
        ERDAT = SY-DATUM
        ERDAT_LOCAL = SY-DATLO
        ERTIM = SY-UZEIT
        ERTIM_LOCAL = SY-TIMLO
        ERNAM = SY-UNAME
        AEDAT = SY-DATUM
        AEDAT_LOCAL = SY-DATLO
        AETIM = SY-UZEIT
        AETIM_LOCAL = SY-TIMLO
        AENAM = SY-UNAME
      ) ).
      MODIFY ZGTMMT1120 FROM TABLE LT_CBO.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CREATE_ETC_VIEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CREATE_ETC_VIEW .

  DATA:
    LV_FAIL   TYPE C LENGTH 1,
    LS_HEAD   TYPE BAPIMATHEAD,
    LS_PLANT  TYPE BAPI_MARC,
    LS_PLANTX TYPE BAPI_MARCX,
    LS_VALU   TYPE BAPI_MBEW,
    LS_VALUX  TYPE BAPI_MBEWX,
    LS_RETURN TYPE BAPIRET2.


  LOOP AT GT_CREATE ASSIGNING FIELD-SYMBOL(<LS_CREATE>).
    CHECK <LS_CREATE>-MATNR IS NOT INITIAL
    AND <LS_CREATE>-VIEW_BASIC EQ ABAP_TRUE AND <LS_CREATE>-VIEW_ETC EQ SPACE.

    CLEAR LV_FAIL.

    LOOP AT GT_CODE ASSIGNING FIELD-SYMBOL(<LS_CODE>).

      CLEAR:
        LS_HEAD,
        LS_PLANT,
        LS_PLANTX,
        LS_VALU,
        LS_VALUX,
        LS_RETURN.


      LS_HEAD-MATERIAL = <LS_CREATE>-MATNR.
      LS_HEAD-IND_SECTOR = 'M'.
      LS_HEAD-PURCHASE_VIEW = ABAP_TRUE.
      LS_HEAD-ACCOUNT_VIEW = ABAP_TRUE.
      LS_HEAD-COST_VIEW = ABAP_TRUE.  "2026.07.03 원가 뷰 추가

      LS_PLANT-PLANT = <LS_CODE>-FLD_03.
      LS_PLANT-PUR_GROUP = <LS_CODE>-FLD_04.
      LS_PLANT-PROFIT_CTR = <LS_CODE>-FLD_11. " "2026.07.03 원가 뷰 추가
      LS_PLANT-LOT_SIZE = <LS_CODE>-FLD_14. " "2026.07.03 원가 뷰 추가
      LS_PLANT-PUR_STATUS = <LS_CODE>-FLD_15. " "2026.07.16 구매 뷰-자재상태값 추가
      LS_PLANTX-PLANT = <LS_CODE>-FLD_03.
      LS_PLANTX-PUR_GROUP = ABAP_TRUE.
      LS_PLANTX-PROFIT_CTR = ABAP_TRUE.  "2026.07.03 원가 뷰 추가
      LS_PLANTX-LOT_SIZE = ABAP_TRUE.  "2026.07.03 원가 뷰 추가
      LS_PLANTX-PUR_STATUS = ABAP_TRUE. " "2026.07.16 구매 뷰-자재상태값 추가

      LS_VALU-VAL_AREA  = <LS_CODE>-FLD_03.
      LS_VALU-VAL_CLASS  = <LS_CODE>-FLD_05.
      LS_VALU-ML_SETTLE  = <LS_CODE>-FLD_06.
      LS_VALU-PRICE_CTRL  = <LS_CODE>-FLD_07.
      LS_VALU-QTY_STRUCT  = <LS_CODE>-FLD_12.  "2026.07.03 원가 뷰 추가
      LS_VALU-ORIG_MAT  = <LS_CODE>-FLD_13.  "2026.07.03 원가 뷰 추가
      LS_VALUX-VAL_AREA = <LS_CODE>-FLD_03.
      LS_VALUX-VAL_CLASS = ABAP_TRUE.
      LS_VALUX-ML_SETTLE = ABAP_TRUE.
      LS_VALUX-PRICE_CTRL = ABAP_TRUE.
      LS_VALUX-QTY_STRUCT  = ABAP_TRUE.   "2026.07.03 원가 뷰 추가
      LS_VALUX-ORIG_MAT  = ABAP_TRUE.  "2026.07.03 원가 뷰 추가

      CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
        EXPORTING
          HEADDATA       = LS_HEAD
          PLANTDATA      = LS_PLANT
          PLANTDATAX     = LS_PLANTX
          VALUATIONDATA  = LS_VALU
          VALUATIONDATAX = LS_VALUX
        IMPORTING
          RETURN         = LS_RETURN.
      IF LS_RETURN-TYPE EQ GC_E.
        <LS_CREATE>-MESSAGE = |({ LS_RETURN-ID }{ LS_RETURN-NUMBER }) { LS_RETURN-MESSAGE }|.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        LV_FAIL = ABAP_TRUE.
        CONTINUE.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.
      ENDIF.
    ENDLOOP.

    IF LV_FAIL IS INITIAL.
      <LS_CREATE>-VIEW_ETC = ABAP_TRUE.
      <LS_CREATE>-RESULT = ICON_LED_GREEN.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DATA_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DATA_DISP .

  "초기화
  CLEAR:
    GV_EDIT,
    GT_DISP[].

  "MRO 대/중분류 조회
  PERFORM F_GET_DATA_NEW.

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
    WHERE Z1~BUKRS EQ @P_BUKRS
    AND Z1~MRO_TYPE1 IN @S_MRO1
    AND Z1~MRO_TYPE2 IN @S_MRO2
    AND Z2~MATKL IN @S_MATKL
    AND Z1~MATNR IN @S_MATNR
    AND MT~MAKTX IN @S_MAKTX
    INTO CORRESPONDING FIELDS OF TABLE @GT_DISP.

  CHECK GT_DISP[] IS NOT INITIAL.

  "MARC 데이터 설정
  PERFORM F_SET_GT_MARC.

  LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP>).
*    <LS_DISP>-ZSTYLE = VALUE #(
*          ( FIELDNAME = 'MRO_TYPE1' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED )
*          ( FIELDNAME = 'MRO_TYPE2' STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED ) ).

    "데이터 점검
    PERFORM F_CHECK_LINE_DATA_DISP CHANGING <LS_DISP>.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_COMMON_CODE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_COMMON_CODE .

  "자재 확장 플랜트
  CLEAR GT_CODE[].
  SELECT *
    FROM ZGTPPT1010
    WHERE MODULE_KIND EQ 'MM'
    AND CODEGRP EQ '0060'
    AND FLD_01 EQ @P_BUKRS
    INTO CORRESPONDING FIELDS OF TABLE @GT_CODE.

  IF GT_CODE IS NOT INITIAL.
    LOOP AT GT_CODE ASSIGNING FIELD-SYMBOL(<LS_CODE>).
      <LS_CODE>-FLD_11 = CONV PRCTR( |{ <LS_CODE>-FLD_11 ALPHA = IN }| ). "손익센터 ALPHA IN
    ENDLOOP.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_LINE_DATA_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_DISP>
*&---------------------------------------------------------------------*
FORM F_CHECK_LINE_DATA_DISP CHANGING CS_DISP TYPE TY_DISP.

  DATA:
    LV_MSG TYPE BAPI_MSG,
    LT_MSG TYPE STANDARD TABLE OF TY_MSG_T.

*그 外
  CS_DISP-STATUS = ICON_LED_GREEN.
  CS_DISP-MESSAGE = SPACE.

*
*⚫          누락          대분류   MRO_TYPE1 IS INITIAL      누락: &
*                   중분류   MRO_TYPE2 IS INITIAL      누락: &
*
* 누락
  CLEAR LV_MSG.

*대분류 누락   대분류   MRO_TYPE1 IS INITIAL      누락: &
  IF CS_DISP-MRO_TYPE1 IS INITIAL.
    CS_DISP-STATUS = ICON_LED_RED.
    IF LV_MSG IS NOT INITIAL.
      LV_MSG = |{ LV_MSG }, { TEXT-H04 }|. ""대분류
    ELSE.
      LV_MSG = TEXT-H04. "대분류
    ENDIF.
  ENDIF.

*중분류 누락   중분류   MRO_TYPE2 IS INITIAL      누락: &
  IF CS_DISP-MRO_TYPE2 IS INITIAL.
    CS_DISP-STATUS = ICON_LED_RED.
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

*         오류          대분류, 중분류    "아래 SELECT 결과값 없는 경우 오류
*(회사코드에 해당 대분류-중분류 조합이 없는 경우)
  CLEAR LV_MSG.
*SELECT SINGLE @ABAP_TRUE
*FROM ZGTMMT1122
*WHERE BUKRS = P_BUKRS
*AND MRO_TYPE1 = GT_DISP-MRO_TYPE1
*AND MRO_TYPE2 = GT_DISP-MRO_TYPE2"     오류: 대-중분류
  IF CS_DISP-MRO_TYPE1 IS NOT INITIAL
    AND CS_DISP-MRO_TYPE2 IS NOT INITIAL.

    READ TABLE GT_MRO2 WITH KEY MRO_TYPE1 = CS_DISP-MRO_TYPE1
                                            MRO_TYPE2 = CS_DISP-MRO_TYPE2 BINARY SEARCH TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      "오류:
      CS_DISP-STATUS = ICON_LED_RED.
      LV_MSG = |{ TEXT-E03 } { TEXT-E09 } |.
      LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = LV_MSG  ) ).
    ENDIF.
  ENDIF.

  "누락/오류 가 없는 경우
  CS_DISP-VIEW_ETC = ABAP_TRUE.
  IF CS_DISP-STATUS NE ICON_LED_RED.

*플랜트 확장         ZGTPPT1010(코드마스터)에 등록된 플랜트에 전부 확장되어있지 않음    "*확장 대상 플랜트
*SELECT FLD_03
*FROM ZGTPPT1010
*WHERE MODULE_KIND = 'MM'
*AND CODEGRP = '0060'
*AND FLD_01 = P_BUKRS
*
**해당 플랜트에 자재별 구매/회계뷰 확장 여부 확인
*SELECT
*FROM MARC
*WHERE MATNR = GT_DISP-MATNR
*AND WERKS IN ~~
*AND PSTAT LIKE %E%B%"

    CLEAR LV_MSG.
    LOOP AT GT_CODE ASSIGNING FIELD-SYMBOL(<LS_CODE>).
      READ TABLE GT_MARC WITH KEY MATNR = CS_DISP-MATNR
                                               WERKS = <LS_CODE>-FLD_03 BINARY SEARCH TRANSPORTING NO FIELDS.
      IF SY-SUBRC NE 0.
        IF LV_MSG IS NOT INITIAL.
          LV_MSG = |{ LV_MSG }, { <LS_CODE>-FLD_03 }|.
        ELSE.
          LV_MSG = <LS_CODE>-FLD_03.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF LV_MSG IS NOT INITIAL.
      "미확장 플랜트:
      CS_DISP-STATUS = ICON_LED_YELLOW.
      CS_DISP-VIEW_ETC = SPACE.

      LV_MSG = |{ TEXT-E14 } { LV_MSG } |.
      LT_MSG = VALUE #( BASE LT_MSG ( MESSAGE = LV_MSG  ) ).
    ENDIF.
  ENDIF.

  "메세지 설정
  LOOP AT LT_MSG ASSIGNING FIELD-SYMBOL(<LS_MSG>).
    IF CS_DISP-MESSAGE IS NOT INITIAL.
      CS_DISP-MESSAGE = |{ CS_DISP-MESSAGE }, { <LS_MSG>-MESSAGE }|.
    ELSE.
      CS_DISP-MESSAGE = <LS_MSG>-MESSAGE.
    ENDIF.
  ENDLOOP.

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
*3-4-1) 조회 <-.> 변경
*대분류, 중분류(MRO_TYPE1, TYPE2) 필드 입력 가능여부 전환

  IF GV_EDIT EQ ABAP_TRUE.
    GV_EDIT = SPACE.
    "데이터 다시 조회
    PERFORM F_GET_DATA_DISP.

  ELSE.
    GV_EDIT = ABAP_TRUE.
  ENDIF.

  "필드카탈로그 설정
  PERFORM F_ADJ_FCAT_200.

  CALL METHOD GO_GRID_200->SET_FRONTEND_FIELDCATALOG
    EXPORTING
      IT_FIELDCATALOG = GT_FCAT_200.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_MMODI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_MMODI .

*3-4-2) 저장 (기본 뷰 + CBO TABLE)
*	* 점검에 빨간 불 없는 경우만 가능
*	* 상태에 수정 표시된 건들 대상
*	* POPUP TO CONFIRM -> 변경 내용을 저장하시겠습니까? 예/아니오

  DATA LV_CHECK TYPE C LENGTH 1.
  CALL METHOD GO_GRID_200->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  SELECT SINGLE
    @ABAP_TRUE
    FROM @GT_DISP AS ZZ
    WHERE ZZ~ZCHG EQ @ABAP_TRUE "변경 한 데이터
    INTO @DATA(LV_CHK_G).
  IF SY-SUBRC NE 0.
    MESSAGE E000 WITH TEXT-E08. "저장 대상이 없습니다.
  ENDIF.

  SELECT SINGLE
    @ABAP_TRUE
    FROM @GT_DISP AS ZZ
    WHERE ZZ~STATUS EQ @ICON_LED_RED "점검 빨간 불인게 있으면 오류
    AND ZZ~ZCHG EQ @ABAP_TRUE
    INTO @DATA(LV_CHK_E).
  IF SY-SUBRC EQ 0.
    MESSAGE E000 WITH TEXT-E06. "오류가 존재하여 저장 할 수 없습니다.
  ENDIF.

  DATA:
    LV_ANS  TYPE C LENGTH 1,
    LV_TEXT TYPE STRING.
  LV_TEXT = TEXT-Q01. " 변경 내용을 저장하시겠습니까?
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1 "확인
      TEXT_QUESTION = LV_TEXT
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

  "기본 뷰 저장
  PERFORM F_SAVE_BASIC_VIEW.

  "메세지
  MESSAGE S000 WITH TEXT-M04. "저장(자재변경) 완료 했습니다.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE_BASIC_VIEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SAVE_BASIC_VIEW .

  DATA:
    LT_CBO      TYPE STANDARD TABLE OF ZGTMMT1120,
    LS_HEAD     TYPE BAPIMATHEAD,
    LS_CLIENT   TYPE BAPI_MARA,
    LS_CLIENTX  TYPE BAPI_MARAX,
    LS_RETURN   TYPE BAPIRET2,

    LV_DIVISION TYPE SPART.   "2026.07.03 제품군 추가

  SELECT SINGLE FLD_10  "
    FROM ZGTPPT1010
    WHERE MODULE_KIND EQ 'MM'
    AND CODEGRP EQ '0060'
    AND FLD_01 EQ @P_BUKRS
    INTO @LV_DIVISION.

  LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP>).
    CHECK <LS_DISP>-ZCHG EQ ABAP_TRUE.

    CLEAR:
      LS_HEAD,
      LS_CLIENT,
      LS_CLIENTX,
      LS_RETURN.

    LS_HEAD-MATERIAL = <LS_DISP>-MATNR.
    LS_HEAD-IND_SECTOR = 'M'.
    LS_HEAD-BASIC_VIEW = ABAP_TRUE.

    LS_CLIENT-MATL_GROUP = <LS_DISP>-MATKL.
    LS_CLIENT-DIVISION = LV_DIVISION. "2026.07.03 제품군 추가
    LS_CLIENTX-MATL_GROUP = ABAP_TRUE.
    LS_CLIENTX-DIVISION = ABAP_TRUE."2026.07.03 제품군 추가


    CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
      EXPORTING
        HEADDATA    = LS_HEAD
        CLIENTDATA  = LS_CLIENT
        CLIENTDATAX = LS_CLIENTX
      IMPORTING
        RETURN      = LS_RETURN.

    IF LS_RETURN-TYPE EQ GC_E.
      <LS_DISP>-MESSAGE = |({ LS_RETURN-ID }{ LS_RETURN-NUMBER }) { LS_RETURN-MESSAGE }|.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      CONTINUE.
    ELSE.
      <LS_DISP>-ZCHG = SPACE.
      <LS_DISP>-ZSTAT = SPACE.

*"MODIFY ZGTMMT1120
*-> MODIFY까지 성공 시 COMMIT 후 ZSTAT CLEAR"
      UPDATE ZGTMMT1120 SET
        MRO_TYPE1 = @<LS_DISP>-MRO_TYPE1,
        MRO_TYPE2 = @<LS_DISP>-MRO_TYPE2,
        AEDAT = @SY-DATUM,
        AEDAT_LOCAL = @SY-DATLO,
        AETIM = @SY-UZEIT,
        AETIM_LOCAL = @SY-TIMLO,
        AENAM = @SY-UNAME
       WHERE BUKRS EQ @<LS_DISP>-BUKRS
       AND MATNR EQ @<LS_DISP>-MATNR.

      IF SY-SUBRC EQ 0.
        <LS_DISP>-ZCHG = SPACE.
        <LS_DISP>-ZSTAT = SPACE.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.

      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_MEXPA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_MEXPA .
*3-4-3) 플랜트 확장 (구매뷰/회계뷰) -> P_NEW의 구매/회계뷰 확장과 동일
*	* 점검에 빨간 불 없는 경우만 가능
*	* GT_DISP-VIEW_ETC IS INITIAL인 건 대상
*
  DATA LV_CHECK TYPE C LENGTH 1.
  CALL METHOD GO_GRID_200->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = LV_CHECK.

  CHECK LV_CHECK EQ ABAP_TRUE.

  SELECT SINGLE
    @ABAP_TRUE
    FROM @GT_DISP AS ZZ
    WHERE ZZ~STATUS EQ @ICON_LED_RED "점검 빨간 불인게 있으면 오류
    AND ZZ~VIEW_ETC EQ @SPACE
    INTO @DATA(LV_CHK_E).
  IF SY-SUBRC EQ 0.
    MESSAGE E000 WITH TEXT-E15. "오류가 존재하여 확장 할 수 없습니다.
  ENDIF.

  SELECT SINGLE
    @ABAP_TRUE
    FROM @GT_DISP AS ZZ
    WHERE ZZ~VIEW_ETC EQ @SPACE "확장 space
    INTO @DATA(LV_CHK_G).
  IF SY-SUBRC NE 0.
    MESSAGE E000 WITH TEXT-E16. "플랜트 확장 대상이 없습니다.
  ENDIF.

  DATA:
    LV_ANS  TYPE C LENGTH 1,
    LV_TEXT TYPE STRING.

  LV_TEXT = TEXT-Q06. " 플랜트 확장 하시겠습니까?
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-TT1 "확인
      TEXT_QUESTION = LV_TEXT
    IMPORTING
      ANSWER        = LV_ANS.
  CHECK LV_ANS EQ GC_1.

  "기타 뷰 생성(구매/회계)
  PERFORM F_EXPAND_ETC_VIEW.

  "MARC 데이터 설정
  PERFORM F_SET_GT_MARC.

  "데이터 설정
  LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP>).
    CHECK <LS_DISP>-MATNR IS NOT INITIAL
    AND <LS_DISP>-VIEW_ETC EQ SPACE
    AND <LS_DISP>-ZERR EQ SPACE. "확장 시 오류 발생하지 않은 건만

    "데이터 점검
    PERFORM F_CHECK_LINE_DATA_DISP CHANGING <LS_DISP>.

  ENDLOOP.


  "메세지
  MESSAGE S000 WITH TEXT-M03.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_EXPAND_ETC_VIEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_EXPAND_ETC_VIEW .

  DATA:
    LV_FAIL   TYPE C LENGTH 1,
    LS_HEAD   TYPE BAPIMATHEAD,
    LS_PLANT  TYPE BAPI_MARC,
    LS_PLANTX TYPE BAPI_MARCX,
    LS_VALU   TYPE BAPI_MBEW,
    LS_VALUX  TYPE BAPI_MBEWX,
    LS_RETURN TYPE BAPIRET2.


  LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP>).
    CHECK <LS_DISP>-MATNR IS NOT INITIAL
    AND <LS_DISP>-VIEW_ETC EQ SPACE.

    <LS_DISP>-ZERR = SPACE.

    CLEAR LV_FAIL.

    LOOP AT GT_CODE ASSIGNING FIELD-SYMBOL(<LS_CODE>).
      "MARC에 없는 플랜트만 실행
      READ TABLE GT_MARC WITH KEY MATNR = <LS_DISP>-MATNR
                                               WERKS = <LS_CODE>-FLD_03 BINARY SEARCH TRANSPORTING NO FIELDS.
      CHECK SY-SUBRC NE 0.

      CLEAR:
        LS_HEAD,
        LS_PLANT,
        LS_PLANTX,
        LS_VALU,
        LS_VALUX,
        LS_RETURN.

      LS_HEAD-MATERIAL = <LS_DISP>-MATNR.
      LS_HEAD-IND_SECTOR = 'M'.
      LS_HEAD-PURCHASE_VIEW = ABAP_TRUE.
      LS_HEAD-ACCOUNT_VIEW = ABAP_TRUE.
      LS_HEAD-COST_VIEW = ABAP_TRUE.  "2026.07.03 원가 뷰 추가

      LS_PLANT-PLANT = <LS_CODE>-FLD_03.
      LS_PLANT-PUR_GROUP = <LS_CODE>-FLD_04.
      LS_PLANT-PROFIT_CTR = <LS_CODE>-FLD_11. " "2026.07.03 원가 뷰 추가
      LS_PLANT-LOT_SIZE = <LS_CODE>-FLD_14. " "2026.07.03 원가 뷰 추가
      LS_PLANT-PUR_STATUS = <LS_CODE>-FLD_15. " "2026.07.16 구매 뷰-자재상태값 추가
      LS_PLANTX-PLANT = <LS_CODE>-FLD_03.
      LS_PLANTX-PUR_GROUP = ABAP_TRUE.
      LS_PLANTX-PROFIT_CTR = ABAP_TRUE.  "2026.07.03 원가 뷰 추가
      LS_PLANTX-LOT_SIZE = ABAP_TRUE.  "2026.07.03 원가 뷰 추가
      LS_PLANTX-PUR_STATUS = ABAP_TRUE. " "2026.07.16 구매 뷰-자재상태값 추가

      LS_VALU-VAL_AREA  = <LS_CODE>-FLD_03.
      LS_VALU-VAL_CLASS  = <LS_CODE>-FLD_05.
      LS_VALU-ML_SETTLE  = <LS_CODE>-FLD_06.
      LS_VALU-PRICE_CTRL  = <LS_CODE>-FLD_07.
      LS_VALU-QTY_STRUCT  = <LS_CODE>-FLD_12.  "2026.07.03 원가 뷰 추가
      LS_VALU-ORIG_MAT  = <LS_CODE>-FLD_13.  "2026.07.03 원가 뷰 추가
      LS_VALUX-VAL_AREA = <LS_CODE>-FLD_03.
      LS_VALUX-VAL_CLASS = ABAP_TRUE.
      LS_VALUX-ML_SETTLE = ABAP_TRUE.
      LS_VALUX-PRICE_CTRL = ABAP_TRUE.
      LS_VALUX-QTY_STRUCT  = ABAP_TRUE.   "2026.07.03 원가 뷰 추가
      LS_VALUX-ORIG_MAT  = ABAP_TRUE.  "2026.07.03 원가 뷰 추가

      CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
        EXPORTING
          HEADDATA       = LS_HEAD
          PLANTDATA      = LS_PLANT
          PLANTDATAX     = LS_PLANTX
          VALUATIONDATA  = LS_VALU
          VALUATIONDATAX = LS_VALUX
        IMPORTING
          RETURN         = LS_RETURN.
      IF LS_RETURN-TYPE EQ GC_E.
        <LS_DISP>-MESSAGE = |({ LS_RETURN-ID }{ LS_RETURN-NUMBER }) { LS_RETURN-MESSAGE }|.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        <LS_DISP>-ZERR = ABAP_TRUE.
        CONTINUE.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_GT_MARC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SET_GT_MARC .

  CLEAR GT_MARC[].

  "확장 플랜트 점검
**해당 플랜트에 자재별 구매/회계뷰 확장 여부 확인
*SELECT
*FROM MARC
*WHERE MATNR = GT_DISP-MATNR
*AND WERKS IN ~~
*AND PSTAT LIKE %E%B%
  CLEAR GT_MARC[].
  SELECT
    MC~MATNR,
    MC~WERKS
    FROM MARC AS MC
    WHERE EXISTS (
      SELECT @ABAP_TRUE
        FROM @GT_DISP AS ZZ
        WHERE ZZ~MATNR EQ MC~MATNR
    )
    AND MC~PSTAT LIKE '%E%'
    AND MC~PSTAT LIKE '%B%'
    ORDER BY MC~MATNR, MC~WERKS
    INTO TABLE @GT_MARC.

ENDFORM.
