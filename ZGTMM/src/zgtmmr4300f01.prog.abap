*&---------------------------------------------------------------------*
*& Include          ZGTMMR4300F01
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

  "I/F 시스템
  DATA : LT_IFNO TYPE VRM_VALUES.

  " 1) SELECT FLD_01,FLD_02 INTO Internal Table IFSYST
*   FROM ZGTPPT1010 WHERE MODULE_KIND = 'PP' AND CODEGRP = '0010'.
* 2) IFSYST FLD_01,FLD_02 기준 중복 제거"
  SELECT DISTINCT
         FLD_01 AS KEY,
         FLD_02 AS TEXT
    FROM ZGTPPT1010
    INTO CORRESPONDING FIELDS OF TABLE @LT_IFNO
   WHERE MODULE_KIND EQ @GC_PP
   AND CODEGRP EQ @GC_0010.

  "값이 있는 경우
  IF LT_IFNO[] IS NOT INITIAL.
    "정렬
    SORT LT_IFNO BY KEY.
    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        ID     = 'P_IFSYT'
        VALUES = LT_IFNO.

    "기본 값 설정
    READ TABLE LT_IFNO WITH KEY KEY = 'KGPM' TRANSPORTING NO FIELDS.
    IF SY-SUBRC EQ 0.
      P_IFSYT = 'KGPM'.
    ENDIF.
  ENDIF.

  "I/F Date
  IF S_IFDAT[] IS INITIAL.
    S_IFDAT[] = VALUE #( ( SIGN = 'I' OPTION = 'BT' LOW = SY-DATLO - 1  HIGH = SY-DATLO ) ).
  ENDIF.

  "전기 일자
  IF S_BUDAT[] IS INITIAL.
    S_BUDAT[] = VALUE #( ( SIGN = 'I' OPTION = 'BT' LOW = SY-DATLO - 1  HIGH = SY-DATLO ) ).
  ENDIF.

  "이동유형
  IF S_BWART[] IS INITIAL.
    S_BWART[] = VALUE #( ( SIGN = 'I' OPTION = 'BT' LOW = '543' HIGH = '544' ) ).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_FIELD_VALUE_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CHECK_FIELD_VALUE_1000 .

  "플랜트
  IF S_WERKS[] IS NOT INITIAL.
    SELECT SINGLE
      WERKS
      FROM T001W
      WHERE WERKS IN @S_WERKS
      INTO @DATA(LV_CHK1).
    IF SY-SUBRC NE 0.
      MESSAGE E013 WITH TEXT-H05.
    ENDIF.
  ENDIF.

  "자재
  IF S_MATNR[] IS NOT INITIAL.
    SELECT SINGLE
      MATNR
      FROM MARA
      WHERE MATNR IN @S_MATNR
      INTO @DATA(LV_CHK2).
    IF SY-SUBRC NE 0.
      MESSAGE E013 WITH TEXT-H06.
    ENDIF.
  ENDIF.

  "공급업체
  IF S_LIFNR[] IS NOT INITIAL.
    SELECT SINGLE
      LIFNR
      FROM LFA1
      WHERE LIFNR IN @S_LIFNR
      INTO @DATA(LV_CHK3).
    IF SY-SUBRC NE 0.
      MESSAGE E013 WITH TEXT-H14.
    ENDIF.
  ENDIF.

  "구매오더
  IF S_EBELN[] IS NOT INITIAL AND P_ILOG EQ ABAP_TRUE.
    SELECT SINGLE
      EBELN
      FROM EKKO
      WHERE EBELN IN @S_EBELN
      INTO @DATA(LV_CHK4).
    IF SY-SUBRC NE 0.
      MESSAGE E013 WITH TEXT-H12.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH .

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

  LOOP AT SCREEN.

    "활성화/비활성화
    CASE SCREEN-GROUP1.
      WHEN 'BWA'.
        SCREEN-INPUT = 0.
      WHEN 'CPU' OR 'BUD' OR 'BAT'.
        IF P_ILOG EQ ABAP_TRUE.
          SCREEN-ACTIVE = 0.
        ELSE.
          SCREEN-ACTIVE = 1.
        ENDIF.

      WHEN 'IFD' OR 'EBE' OR  'FRC'.
        IF P_ILOG EQ ABAP_TRUE.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.
    ENDCASE.

    "필수입력 표시
    CASE SCREEN-GROUP1.
      WHEN 'IFD' OR 'BUD'.
        IF SCREEN-GROUP3 EQ 'LOW'.
          SCREEN-REQUIRED = 2.
        ENDIF.

      WHEN 'IFS'.
        IF P_ILOG EQ SPACE.
          SCREEN-REQUIRED = 2.
        ENDIF.

      WHEN 'WRK'.
        IF SCREEN-GROUP3 EQ 'LOW' AND P_ILOG EQ SPACE.
          SCREEN-REQUIRED = 2.
        ENDIF.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

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

  "필수 입력 값 점검
  PERFORM F_CHECK_INPUT_REQU_VALUES_1000.

  "데이터 조회
  CASE ABAP_TRUE.
    WHEN P_SEND. "CASE 1 : RADIO BUTTON = "Data 전송" 인 경우 Data Gathering

      "자재 문서 데이터 조회
      PERFORM F_GET_DOC_DATA.

    WHEN P_ILOG. "로그조회

      "로그 데이터 조회
      PERFORM F_GET_IF_LOG_DATA.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_INPUT_REQU_VALUES_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CHECK_INPUT_REQU_VALUES_1000 .

  CASE ABAP_TRUE.
    WHEN P_ILOG. "I/F Log 조회
      IF S_IFDAT[] IS INITIAL.
        MESSAGE S018 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.
    WHEN P_SEND. "Data 전송
      IF P_IFSYT IS INITIAL
        OR S_WERKS[] IS INITIAL
        OR S_BUDAT[] IS INITIAL.
        MESSAGE S018 DISPLAY LIKE GC_E.
        LEAVE LIST-PROCESSING.
      ENDIF.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_DOC_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_DOC_DATA .

  "초기화
  CLEAR GT_DOC[].

*1)	 실행 조회조건 값을 기준으로 자재문서 이력 정보 추출
*	: Batch 자재가 존재하는 임가공 투입 자재 문서 1차 추출
*	Table : MATDOC
*	Select 조건  : MBLNR,MJAHR,ZEILE,WERKS,BWART,MATNR,MENGE,MEINS,CHARG,EBELN,EBELP,LIFNR
*	WHERE조건
*	WERKS = 입력 플랜트
*	BUDAT = 입력 기간
*	BWART = 543, 544
*	CHARG = 공백이 아닌 대상
*
*2) 상위자재 문서의 Batch 번호 존재 여부 점검
*	: 1-1에서 조회된 EBELN, EBELP 값을 키로 동일한 MBLNR 내에 BWART = 101,102 or 121 라인의 CHARG 값 존재 여부 점검
*
*3) 최종 전송 대상 점검
*	: 1-2 에서 CHARG 값이 존재하는 자재문서를 최종 전송 대상으로함
*	: 최종 전송 대상 문서가 전송 이력 테이블에 존재하는지 점검. 전송 이력이 없는 대상을 기준으로함

*4-4) 플랜트,배치,자재번호 기준으로 ZPPT0001-TAGNR
  SELECT
    MD~MBLNR,
    MD~MJAHR,
    MD~ZEILE,
    MD~BUDAT,
    MD~WERKS,
    MD~MATNR,
    CASE WHEN MR~ZZMAKTX80 EQ @SPACE THEN MT~MAKTX ELSE MR~ZZMAKTX80 END AS ZZMAKTX80,
    MD~BWART,
    MD~CHARG,
    MD~MENGE,
    MD~MEINS,
    MD~EBELN,
    MD~EBELP,
    MD~LIFNR,
    LF~NAME1 AS LIFNR_TXT,
    MD~SHKZG,
    MD~MENGE AS MENGE_V
    FROM MATDOC AS MD
              INNER JOIN
            MARA AS MR ON MD~MATNR EQ MR~MATNR
              LEFT OUTER JOIN
            LFA1 AS LF ON MD~LIFNR EQ LF~LIFNR
              LEFT OUTER JOIN
            MAKT AS MT ON MD~MATNR EQ MT~MATNR
                           AND MT~SPRAS EQ @SY-LANGU
    WHERE MD~WERKS IN @S_WERKS
    AND MD~MATNR IN @S_MATNR
    AND MD~BWART IN @S_BWART
    AND MD~BUDAT IN @S_BUDAT
    AND MD~CPUDT IN @S_CPUDT
    AND MD~LIFNR IN @S_LIFNR
    AND MD~CHARG IS NOT INITIAL
*2) 상위자재 문서의 Batch 번호 존재 여부 점검
*	: 1-1에서 조회된 EBELN, EBELP 값을 키로 동일한 MBLNR 내에 BWART = 101,102 or 121 라인의 CHARG 값 존재 여부 점검
    AND EXISTS (
      SELECT ZZ~MBLNR, ZZ~EBELN, ZZ~EBELP
          FROM MATDOC AS ZZ
          WHERE ZZ~MBLNR EQ MD~MBLNR
             AND ZZ~EBELN EQ MD~EBELN
             AND ZZ~EBELP EQ MD~EBELP
             AND ZZ~CHARG IS NOT INITIAL
             AND ZZ~BWART IN ( '101', '102', '121' )
    )
* 전송 성공 이력이 있으면 제외
    AND NOT EXISTS (
       SELECT ZDOC~MBLNR, ZDOC~MJAHR, ZDOC~ZEILE
          FROM ZGTMMT9400 AS ZDOC
                    INNER JOIN
                 ZGTMMT9000 AS ZLOG ON ZDOC~SYSTEM_ID EQ ZLOG~SYSTEM_ID
                                                  AND  ZDOC~ZIFKEY EQ ZLOG~ZIFKEY
          WHERE ZDOC~MJAHR EQ MD~MJAHR
             AND ZDOC~MBLNR EQ MD~MBLNR
             AND ZDOC~ZEILE EQ MD~ZEILE
             AND ZLOG~SYSTEM_ID EQ @P_IFSYT "전송 대상 시스템 ID
             AND ZLOG~ZSTAT EQ @GC_S "전송 성공
             AND ZLOG~ZIFNO EQ @GC_MM00039 "[MES]배치 투입정보 전송

    )
    INTO CORRESPONDING FIELDS OF TABLE @GT_DOC.

*4-4) 플랜트,배치,자재번호 기준으로 ZPPT0001-TAGNR
  CHECK GT_DOC[] IS NOT INITIAL.

  SELECT DISTINCT
    ZP~WERKS,
    ZP~MATNR,
    ZP~CHARG,
    ZP~TAGNR
    FROM ZPPT0001 AS ZP
    WHERE EXISTS (
      SELECT ZZ~WERKS, ZZ~MATNR, ZZ~CHARG
        FROM @GT_DOC AS ZZ
        WHERE ZZ~WERKS EQ ZP~WERKS
           AND ZZ~MATNR EQ ZP~MATNR
           AND ZZ~CHARG EQ ZP~CHARG
    )
    ORDER BY ZP~WERKS, ZP~MATNR, ZP~CHARG
    INTO TABLE @DATA(LT_PP).

  LOOP AT GT_DOC ASSIGNING FIELD-SYMBOL(<LS_DOC>).
    <LS_DOC>-SYSTEM_ID = P_IFSYT.

    IF <LS_DOC>-SHKZG EQ GC_H.
      <LS_DOC>-MENGE_V *= -1.
    ENDIF.

    READ TABLE LT_PP ASSIGNING FIELD-SYMBOL(<LS_PP>) WITH KEY WERKS = <LS_DOC>-WERKS
                                                                                               MATNR = <LS_DOC>-MATNR
                                                                                               CHARG = <LS_DOC>-CHARG
                                                                                               BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_DOC>-TAGNR = <LS_PP>-TAGNR.
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

  "데이터가 없으면 메세지 처리
  IF GT_DOC[] IS INITIAL.
    MESSAGE S002 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.

  "배치 체크인 경우 바로 전송
  IF P_SEND EQ ABAP_TRUE AND P_BAT EQ ABAP_TRUE.
    "데이터 전송
    PERFORM F_SEND.
  ELSE.
    CHECK SY-BATCH NE ABAP_TRUE. "배치 실행이 아닌 경우
    "Screen 100 이동
    CALL SCREEN 100.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SEND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  PV_RE  재전송 여부
*&
*&---------------------------------------------------------------------*
FORM F_SEND.

  DATA:
    LV_CNT_S   TYPE INT4,
    LV_CNT_E   TYPE INT4,
    LV_CNT_RUN TYPE INT4,
    LV_DEST    TYPE ZDEST,
    LT_DATA    TYPE TY_T_DATA, "STANDARD TABLE OF ZGTMMS4000,
    LT_SUC     TYPE TY_T_SUC,
    LT_SYS     TYPE TY_T_SYS,
    LV_RESULT  TYPE ZO_RESULT,
    LV_MESSAGE TYPE ZO_MESSAGE.

  "선택 여부 점검
  PERFORM F_CHECK_SEL_DATA.

  "대상 시스템 설정
  PERFORM F_SET_TARGET_SYSTEM_LIST CHANGING LT_SYS.

  "배치 전송이 아닌 경우 확인 팝업
  IF ( SY-BATCH EQ SPACE AND P_BAT EQ SPACE )
    OR P_ILOG EQ ABAP_TRUE.
    DATA LV_ANS TYPE C LENGTH 1.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR      = TEXT-TT3
        TEXT_QUESTION = TEXT-Q01
      IMPORTING
        ANSWER        = LV_ANS.
    CHECK LV_ANS EQ GC_1.
  ENDIF.

  LOOP AT LT_SYS ASSIGNING FIELD-SYMBOL(<LS_SYS>).

    "전송 데이터 설정
    IF ( SY-BATCH EQ SPACE AND P_BAT EQ SPACE )
      OR P_ILOG EQ ABAP_TRUE.
      "일반 실행 인 경우 / 재전송 인 경우
      PERFORM F_SET_SEND_DATA TABLES LT_DATA USING <LS_SYS>-SYSTEM_ID.
    ELSE.
      "배치 인 경우
      PERFORM F_SET_BAT_SEND_DATA TABLES LT_DATA USING <LS_SYS>-SYSTEM_ID.
    ENDIF.

    "실행 건 계산
    LV_CNT_RUN = LINES( LT_DATA ) DIV GC_MAX.
    IF LINES( LT_DATA ) MOD GC_MAX NE 0.
      LV_CNT_RUN += 1.
    ENDIF.

*	: 최종 전송 대상 문서가 전송 이력 테이블에 존재하는지 점검. 전송 이력이 없는 대상을 기준으로함
    PERFORM F_CHECK_SEND_DATA USING <LS_SYS>-SYSTEM_ID LT_DATA CHANGING LT_SUC.

    "분할 전송
    DO LV_CNT_RUN TIMES.
      "RFC 전송 실행
      PERFORM F_RUN_SEND_RFC USING SY-INDEX <LS_SYS>-SYSTEM_ID LT_DATA LT_SUC
                                                   CHANGING LV_CNT_S LV_CNT_E.
    ENDDO.
  ENDLOOP.

  "메세지 처리
  "전체 데이터: &1 성공: &2 실패: &3
  DATA(LV_TOT) = LV_CNT_S + LV_CNT_E.
  MESSAGE S073 WITH LV_TOT LV_CNT_S LV_CNT_E.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_DATA
*&---------------------------------------------------------------------*
FORM F_SET_SEND_DATA  TABLES PT_DATA TYPE TY_T_DATA
                                          USING PV_SYSTEM_ID.

  "초기화
  CLEAR PT_DATA[].

  "선택 한 라인 조회
  DATA LT_ROW TYPE LVC_T_ROID.
  CALL METHOD GO_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW.

  DATA LS_DATA TYPE TY_DATA.

  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
    CHECK <LS_ROW>-ROW_ID GT 0.
    READ TABLE GT_DOC ASSIGNING FIELD-SYMBOL(<LS_DOC>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    "대상 시스템
    CHECK <LS_DOC>-SYSTEM_ID = PV_SYSTEM_ID.

    "데이터 설정
    PERFORM F_SET_DOC_DATA USING <LS_DOC> CHANGING LS_DATA.

    "라인추가
    PT_DATA[] = VALUE #( BASE PT_DATA[] ( LS_DATA  ) ).

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_DOC_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_DOC>
*&      <-- LS_DATA
*&---------------------------------------------------------------------*
FORM F_SET_DOC_DATA  USING    PS_DOC TYPE TY_DOC
                     CHANGING CS_DATA TYPE TY_DATA.

  "초기화
  CLEAR CS_DATA.

  "값 설정
  CS_DATA = CORRESPONDING #( PS_DOC ).

  CS_DATA-MBLNR = |{ CS_DATA-MBLNR ALPHA = OUT }|.
  CS_DATA-ZEILE = |{ CS_DATA-ZEILE ALPHA = OUT }|.
  CS_DATA-EBELN = |{ CS_DATA-EBELN ALPHA = OUT }|.
  CS_DATA-EBELP = |{ CS_DATA-EBELP ALPHA = OUT }|.
  CS_DATA-LIFNR = |{ CS_DATA-LIFNR ALPHA = OUT }|.

  "수량
  WRITE PS_DOC-MENGE_V TO CS_DATA-MENGE LEFT-JUSTIFIED NO-GROUPING.
  CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
    CHANGING
      VALUE = CS_DATA-MENGE.

  "자재코드
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      INPUT  = CS_DATA-MATNR
    IMPORTING
      OUTPUT = CS_DATA-MATNR.

  "단위
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      INPUT  = CS_DATA-MEINS
    IMPORTING
      OUTPUT = CS_DATA-MEINS.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_BAT_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_DATA
*&---------------------------------------------------------------------*
FORM F_SET_BAT_SEND_DATA  TABLES PT_DATA TYPE TY_T_DATA
                                                  USING PV_SYSTEM_ID.

  "초기화
  CLEAR PT_DATA[].

  DATA LS_DATA TYPE TY_DATA.

  LOOP AT GT_DOC ASSIGNING FIELD-SYMBOL(<LS_DOC>).
    "대상 시스템
    CHECK <LS_DOC>-SYSTEM_ID = PV_SYSTEM_ID.

    "데이터 설정
    PERFORM F_SET_DOC_DATA USING <LS_DOC> CHANGING LS_DATA.

    "라인추가
    PT_DATA[] = VALUE #( BASE PT_DATA[] ( LS_DATA ) ).
  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_DATA TYPE TY_T_DATA
*&      <-- CT_SUC TYPE TY_T_SUC
*&---------------------------------------------------------------------*
FORM F_CHECK_SEND_DATA  USING PV_SYSTEM_ID TYPE ZGTE_IF_TARGET
                                                        PT_DATA TYPE TY_T_DATA
                                               CHANGING CT_SUC TYPE TY_T_SUC.

  "전송 성공 이력이 포함된 자재문서
  SELECT DISTINCT
    @PV_SYSTEM_ID AS SYSTEM_ID,
    ZZ~MJAHR,
    ZZ~MBLNR,
    ZZ~ZEILE
    FROM @PT_DATA AS ZZ
    WHERE
* 전송 성공 이력이 있는 문서번호
      EXISTS (
       SELECT ZDOC~MBLNR, ZDOC~MJAHR, ZDOC~ZEILE
          FROM ZGTMMT9400 AS ZDOC
                    INNER JOIN
                 ZGTMMT9000 AS ZLOG ON ZDOC~SYSTEM_ID EQ ZLOG~SYSTEM_ID
                                                  AND  ZDOC~ZIFKEY EQ ZLOG~ZIFKEY
          WHERE ZDOC~MJAHR EQ ZZ~MJAHR
             AND ZDOC~MBLNR EQ ZZ~MBLNR
             AND ZDOC~ZEILE EQ ZZ~ZEILE
             AND ZLOG~SYSTEM_ID EQ @PV_SYSTEM_ID "전송 대상 시스템 ID
             AND ZLOG~ZSTAT EQ @GC_S "전송 성공
             AND ZLOG~ZIFNO EQ @GC_MM00039 "[MES]배치 투입정보 전송
    )
    INTO TABLE @CT_SUC.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_RUN_SEND_RFC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SY_INDEX
*&      --> LT_DATA
*&      --> LT_SUC
*&      <-- LV_CNT_S
*&      <-- LV_CNT_E
*&---------------------------------------------------------------------*
FORM F_RUN_SEND_RFC  USING    PV_INDEX
                              PV_SYSTEM_ID
                              PT_DATA TYPE TY_T_DATA
                              PT_SUC TYPE TY_T_SUC
                     CHANGING CV_CNT_S
                              CV_CNT_E.

  DATA:
    LV_START_IDX TYPE INT4,
    LV_END_IDX   TYPE INT4,
    LT_DATA      TYPE STANDARD TABLE OF ZGTMMS4000,
    LT_LOG       TYPE TY_T_DATA.

  DATA:
    LV_DEST    TYPE ZDEST,
    LV_RESULT  TYPE ZO_RESULT,
    LV_MESSAGE TYPE ZO_MESSAGE.

  "시작 Tabix
  LV_START_IDX = PV_INDEX - 1.
  LV_START_IDX *= GC_MAX.
  LV_START_IDX += 1.

  "종료 Tabix
  LV_END_IDX = LV_START_IDX + GC_MAX.

  LOOP AT PT_DATA ASSIGNING FIELD-SYMBOL(<LS_DATA>) FROM LV_START_IDX.
    "종료 Tab index 보다 크거나 같으면 종료
    IF SY-TABIX GE LV_END_IDX.
      EXIT.
    ENDIF.

    "이미 성공한 자재문서는 오류로 처리
    READ TABLE PT_SUC WITH TABLE KEY SYSTEM_ID = PV_SYSTEM_ID
                                                     MJAHR = <LS_DATA>-MJAHR
                                                     MBLNR = <LS_DATA>-MBLNR
                                                     ZEILE = <LS_DATA>-ZEILE TRANSPORTING NO FIELDS.
    IF SY-SUBRC EQ 0.
      CV_CNT_E += 1. "오류 추가
      CONTINUE.
    ENDIF.

    "라인추가
    LT_DATA[] = VALUE #( BASE LT_DATA ( CORRESPONDING #( <LS_DATA> ) ) ).
    LT_LOG[] = VALUE #( BASE LT_LOG ( <LS_DATA> ) ).
  ENDLOOP.

  "전송 대상이 있으면 진행
  CHECK LT_DATA[] IS NOT INITIAL.

  CALL FUNCTION 'ZGTMM_IF_GET_DESTINATION'
    EXPORTING
      I_ZIFNO = GC_MM00039
    IMPORTING
      E_ZDEST = LV_DEST.

  CALL FUNCTION 'ZGTMM_IF_O_SCISSUE_SEND'
    DESTINATION LV_DEST
    EXPORTING
      I_SYSTEM_ID = PV_SYSTEM_ID
    IMPORTING
      ZO_RESULT   = LV_RESULT
      ZO_MESSAGE  = LV_MESSAGE
    TABLES
      OT_ITEM     = LT_DATA
    EXCEPTIONS
      OTHERS      = 1.
  IF SY-SUBRC NE 0.
    LV_RESULT = GC_02.
  ENDIF.

  "메세지 처리
  IF LV_RESULT EQ GC_00.
    "성공
    CV_CNT_S += LINES( LT_DATA ).
    LV_RESULT = GC_S.
  ELSE.
    "오류
    CV_CNT_E += LINES( LT_DATA ).
    LV_RESULT = GC_E  .
  ENDIF.

  "로그 저장
  PERFORM F_SAVE_IF_LOG TABLES LT_LOG USING LV_RESULT LV_MESSAGE PV_SYSTEM_ID.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE_IF_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_DATA
*&      --> LV_RET
*&      --> LV_MSG
*&---------------------------------------------------------------------*
FORM F_SAVE_IF_LOG  TABLES    PT_DATA TYPE TY_T_DATA
                                      USING    PV_RET
                                                   PV_MSG
                                                   PV_SYSTEM_ID.

  DATA:
    LS_LOG      TYPE ZGTMMT9000,
    LS_LOG_DATA TYPE ZGTMMT9400,
    LT_LOG_DATA TYPE STANDARD TABLE OF ZGTMMT9400.

  GET TIME STAMP FIELD LS_LOG-ZIFKEY.
  LS_LOG-ZIFNO       = GC_MM00039.
  IF PV_SYSTEM_ID EQ SPACE.
    LS_LOG-SYSTEM_ID   = P_IFSYT.
  ELSE.
    LS_LOG-SYSTEM_ID   = PV_SYSTEM_ID.
  ENDIF.
  LS_LOG-ZSTAT       = PV_RET.
  LS_LOG-MESSAGE     = PV_MSG.
  LS_LOG-IFDAT       = SY-DATLO.
  LS_LOG-IFTIM       = SY-TIMLO.
  LS_LOG-IFNAM       = SY-UNAME.
  LS_LOG-ERDAT       = SY-DATUM.
  LS_LOG-ERDAT_LOCAL = SY-DATLO.
  LS_LOG-ERTIM       = SY-UZEIT.
  LS_LOG-ERTIM_LOCAL = SY-TIMLO.
  LS_LOG-ERNAM       = SY-UNAME.

  LT_LOG_DATA[] = VALUE #( FOR <LS_DATA> IN PT_DATA
                       ( VALUE #( BASE CORRESPONDING #( <LS_DATA> )
                                  ZIFKEY  = LS_LOG-ZIFKEY
                                  SYSTEM_ID = LS_LOG-SYSTEM_ID
                                  MENGE = <LS_DATA>-MENGE_V ) ) ).

  LOOP AT LT_LOG_DATA ASSIGNING FIELD-SYMBOL(<LS_LOG_DATA>).
    <LS_LOG_DATA>-MBLNR = |{ <LS_LOG_DATA>-MBLNR ALPHA = IN }|.
    <LS_LOG_DATA>-ZEILE = |{ <LS_LOG_DATA>-ZEILE ALPHA = IN }|.
    <LS_LOG_DATA>-EBELN = |{ <LS_LOG_DATA>-EBELN ALPHA = IN }|.
    <LS_LOG_DATA>-EBELP = |{ <LS_LOG_DATA>-EBELP ALPHA = IN }|.
    <LS_LOG_DATA>-LIFNR = |{ <LS_LOG_DATA>-LIFNR ALPHA = IN }|.

    "자재코드
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT  = <LS_LOG_DATA>-MATNR
      IMPORTING
        OUTPUT = <LS_LOG_DATA>-MATNR.

    "단위
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        INPUT  = <LS_LOG_DATA>-MEINS
      IMPORTING
        OUTPUT = <LS_LOG_DATA>-MEINS.
  ENDLOOP.


  MODIFY ZGTMMT9400 FROM TABLE LT_LOG_DATA.
  MODIFY ZGTMMT9000 FROM LS_LOG.
  COMMIT WORK.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_TARGET_SYSTEM_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_SYS
*&---------------------------------------------------------------------*
FORM F_SET_TARGET_SYSTEM_LIST  CHANGING CT_SYS TYPE TY_T_SYS.

  "초기화
  CLEAR CT_SYS[].

  "전송 대상 시스템 설정
  IF P_SEND EQ ABAP_TRUE.
    CT_SYS[] = VALUE #( ( SYSTEM_ID = P_IFSYT ) ).
  ELSE.
    IF ( SY-BATCH EQ SPACE AND P_BAT EQ SPACE ).

      "선택 한 라인 조회
      DATA LT_ROW TYPE LVC_T_ROID.
      CALL METHOD GO_GRID->GET_SELECTED_ROWS
        IMPORTING
          ET_ROW_NO = LT_ROW.

      LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
        CHECK <LS_ROW>-ROW_ID GT 0.
        READ TABLE GT_DOC ASSIGNING FIELD-SYMBOL(<LS_DOC>) INDEX <LS_ROW>-ROW_ID.
        CHECK SY-SUBRC EQ 0.
        CT_SYS[] = VALUE #( BASE CT_SYS[] ( SYSTEM_ID = <LS_DOC>-SYSTEM_ID ) ).
      ENDLOOP.

      SORT CT_SYS BY SYSTEM_ID.
      DELETE ADJACENT DUPLICATES FROM CT_SYS COMPARING SYSTEM_ID.

    ELSE.

      "조회 된 전체 시스템
      SELECT DISTINCT ZZ~SYSTEM_ID
        FROM @GT_DOC AS ZZ
         INTO TABLE @CT_SYS.

    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_SEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_CHECK_SEL_DATA .

  "데이터 점검
  IF ( SY-BATCH EQ SPACE AND P_BAT EQ SPACE )
    OR P_ILOG EQ ABAP_TRUE.

    "선택 한 라인  없으면 오류
    DATA LT_ROW TYPE LVC_T_ROID.
    CALL METHOD GO_GRID->GET_SELECTED_ROWS
      IMPORTING
        ET_ROW_NO = LT_ROW.
    DELETE LT_ROW WHERE ROW_ID LE 0.
    IF LT_ROW[] IS INITIAL.
      MESSAGE E050.
    ENDIF.

  ELSE.

    "배치 실행인 경우 데이터 없으면 오류
    IF GT_DOC[] IS INITIAL.
*4-3) 전송 버튼 클릭시 선택 된 라인이 없으면 하단 에러 메시지 처리 "선택된 데이터가 없습니다."
      MESSAGE E050.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_IF_LOG_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_IF_LOG_DATA .

  "초기화
  CLEAR GT_DOC[].
*
*1)  실행 조회조건 값을 기준으로 인터페이스 이력 테이블 정보 추출                   `
*	Table : ZMMT9000
*	Select 조건  : ZIFNO,ZIFKEY,SYSTEM_ID,ZSTAT,MESSAGE,IFNAM
*	WHERE조건
*	SYSTEM_ID = 입력 조건 값
*	IFDAT = 입력 기간
*
*
*2) 인터페이스 이력 세부 정보 데이터 추출
*	Table : ZMMT9400
*	Select 조건  : MBLNR,MJAHR,ZEILE,BUDAT.WERKS,MATNR,BWART,CHARG.MENGE,EBELN.EBELP,LIFNR
*	WHERE조건
*	ZIFKEY = 1) 에서 추출한 Interface Key
*
*3) 자재내역, 공급업체 명, 시스템 명, 꼬리표번호 추출
*	4-1) MARA-ZZMAKTX80 (값이 없는 경우 MAKTX)
*	4-2) LFA1-NAME1
*	4-3) ZGTPPT1010-FLD_02
*	4-4) 플랜트,배치,자재번호 기준으로 ZPPT0001-TAGNR
*

  DATA:
    LR_SYSTEM_ID TYPE RANGE OF ZGTMMT9000-SYSTEM_ID,
    LR_ZSTAT     TYPE RANGE OF ZGTMMT9000-ZSTAT.

  "I/F 시스템
  IF P_IFSYT IS NOT INITIAL.
    LR_SYSTEM_ID = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = P_IFSYT ) ).
  ENDIF.

  "상태
  IF P_FRC NE ABAP_TRUE.
    LR_ZSTAT = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = GC_E ) ).
  ENDIF.

  WITH
    +V_LAST AS (
        SELECT
         Z1~ZIFNO,
         Z1~SYSTEM_ID,
         Z2~MBLNR,
         Z2~MJAHR,
         Z2~ZEILE,
         MAX( Z1~ZIFKEY ) AS ZIFKEY
         FROM ZGTMMT9000 AS Z1
                       INNER JOIN
                   ZGTMMT9400 AS Z2 ON Z1~ZIFKEY EQ Z2~ZIFKEY
                                                AND Z1~SYSTEM_ID EQ Z2~SYSTEM_ID
         WHERE Z1~ZIFNO EQ @GC_MM00039
         AND Z1~SYSTEM_ID IN @LR_SYSTEM_ID
         AND Z1~ERDAT IN @S_IFDAT
         AND Z2~WERKS IN @S_WERKS
         AND Z2~MATNR IN @S_MATNR
         AND Z2~BWART IN @S_BWART
         AND Z2~LIFNR IN @S_LIFNR
         AND Z2~EBELN IN @S_EBELN
         GROUP BY Z1~ZIFNO, Z1~SYSTEM_ID, Z2~MBLNR, Z2~MJAHR, Z2~ZEILE
    )
    SELECT
  "I/F
      Z1~ZIFNO,
      Z1~ZIFKEY,
      Z1~SYSTEM_ID,
      Z1~ZSTAT,
      Z1~MESSAGE,
      Z1~IFNAM,
  "자재문서
      Z2~MBLNR,
      Z2~MJAHR,
      Z2~ZEILE,
      Z2~BUDAT,
      Z2~WERKS,
      Z2~MATNR,
      Z2~BWART,
      Z2~CHARG,
      Z2~MENGE,
      Z2~MENGE AS MENGE_V,
      Z2~MEINS,
      Z2~EBELN,
      Z2~EBELP,
      Z2~LIFNR,
      Z2~TAGNR
      FROM ZGTMMT9000 AS Z1
                    INNER JOIN
                ZGTMMT9400 AS Z2 ON Z1~ZIFKEY EQ Z2~ZIFKEY
                                             AND Z1~SYSTEM_ID EQ Z2~SYSTEM_ID
                    INNER JOIN
               +V_LAST AS V1 ON Z1~ZIFNO EQ V1~ZIFNO
                                 AND Z1~SYSTEM_ID EQ V1~SYSTEM_ID
                                 AND Z1~ZIFKEY EQ V1~ZIFKEY
                                 AND Z2~MBLNR EQ V1~MBLNR
                                 AND Z2~MJAHR EQ V1~MJAHR
                                 AND Z2~ZEILE EQ V1~ZEILE
      WHERE Z1~ZSTAT IN @LR_ZSTAT "I/F 성공 데이터 포함
    INTO CORRESPONDING FIELDS OF TABLE @GT_DOC.

  CHECK GT_DOC[] IS NOT INITIAL.

  "Conversion Exit
  LOOP AT GT_DOC ASSIGNING FIELD-SYMBOL(<LS_DOC>).

    <LS_DOC>-MBLNR = |{ <LS_DOC>-MBLNR ALPHA = IN }|.
    <LS_DOC>-ZEILE = |{ <LS_DOC>-ZEILE ALPHA = IN }|.
    <LS_DOC>-EBELN = |{ <LS_DOC>-EBELN ALPHA = IN }|.
    <LS_DOC>-EBELP = |{ <LS_DOC>-EBELP ALPHA = IN }|.
    <LS_DOC>-LIFNR = |{ <LS_DOC>-LIFNR ALPHA = IN }|.
    <LS_DOC>-MENGE = ABS( <LS_DOC>-MENGE ).

    "자재코드
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT  = <LS_DOC>-MATNR
      IMPORTING
        OUTPUT = <LS_DOC>-MATNR.

    "단위
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        INPUT  = <LS_DOC>-MEINS
      IMPORTING
        OUTPUT = <LS_DOC>-MEINS.

  ENDLOOP.

  "내역 조회

  "시스템 내역
  SELECT DISTINCT
         FLD_01,
         FLD_02
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ @GC_PP
   AND CODEGRP EQ @GC_0010
   ORDER BY FLD_01
   INTO TABLE @DATA(LT_TXT).

*3) 자재내역, 공급업체 명, 시스템 명, 꼬리표번호 추출
*	4-1) MARA-ZZMAKTX80 (값이 없는 경우 MAKTX)
*	4-2) LFA1-NAME1
*	4-3) ZGTPPT1010-FLD_02
  "자재내역
  SELECT DISTINCT
    MR~MATNR,
    MR~ZZMAKTX80,
    MT~MAKTX
    FROM MARA AS MR
              LEFT OUTER JOIN
            MAKT AS MT ON MR~MATNR EQ MT~MATNR
                            AND MT~SPRAS EQ @SY-LANGU
    WHERE EXISTS (
      SELECT ZZ~MATNR
          FROM @GT_DOC AS ZZ
          WHERE ZZ~MATNR EQ MR~MATNR
             AND ZZ~MATNR IS NOT INITIAL
    )
    ORDER BY MR~MATNR
    INTO TABLE @DATA(LT_MAKT).

  "공급업체
  SELECT DISTINCT
    LF~LIFNR,
    LF~NAME1
    FROM LFA1 AS LF
    WHERE EXISTS (
     SELECT ZZ~LIFNR
       FROM @GT_DOC AS ZZ
       WHERE ZZ~LIFNR EQ LF~LIFNR
    )
    ORDER BY LF~LIFNR
    INTO TABLE @DATA(LT_LFA1).

  LOOP AT GT_DOC ASSIGNING <LS_DOC>.

    "시스템 명
    READ TABLE LT_TXT ASSIGNING FIELD-SYMBOL(<LS_TXT>) WITH KEY FLD_01 = <LS_DOC>-SYSTEM_ID BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_DOC>-SYSTEM_TXT = <LS_TXT>-FLD_02.
    ENDIF.

    "자재내역
    READ TABLE LT_MAKT ASSIGNING FIELD-SYMBOL(<LS_MAKT>) WITH KEY MATNR = <LS_DOC>-MATNR BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      IF <LS_MAKT>-ZZMAKTX80 IS NOT INITIAL.
        <LS_DOC>-ZZMAKTX80 = <LS_MAKT>-ZZMAKTX80.
      ELSE.
        <LS_DOC>-ZZMAKTX80 = <LS_MAKT>-MAKTX.
      ENDIF.
    ENDIF.

    "공급업체명
    READ TABLE LT_LFA1 ASSIGNING FIELD-SYMBOL(<LS_LFA1>) WITH KEY LIFNR = <LS_DOC>-LIFNR BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_DOC>-LIFNR_TXT = <LS_LFA1>-NAME1.
    ENDIF.


  ENDLOOP.

ENDFORM.
