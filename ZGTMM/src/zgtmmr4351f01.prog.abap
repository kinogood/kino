*&---------------------------------------------------------------------*
*& Include          ZGTMMR4351F01
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
      WHEN 'BAT'.
        IF P_ILOG EQ ABAP_TRUE.
          SCREEN-ACTIVE = 0.
        ELSE.
          SCREEN-ACTIVE = 1.
        ENDIF.

      WHEN 'IFD' OR  'FRC'.
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
    SELECT SINGLE WERKS
      FROM T001W
     WHERE WERKS IN @S_WERKS
      INTO @DATA(LV_CHK1).
    IF SY-SUBRC NE 0.
      MESSAGE E013 WITH TEXT-H01.
    ENDIF.
  ENDIF.

  "자재
  IF S_MATNR[] IS NOT INITIAL.
    SELECT SINGLE MATNR
      FROM MARA
     WHERE MATNR IN @S_MATNR
      INTO @DATA(LV_CHK2).
    IF SY-SUBRC NE 0.
      MESSAGE E013 WITH TEXT-H02.
    ENDIF.
  ENDIF.

  "구매오더
  IF S_EBELN[] IS NOT INITIAL.
    SELECT SINGLE EBELN
      FROM EKKO
     WHERE EBELN IN @S_EBELN
      INTO @DATA(LV_CHK4).
    IF SY-SUBRC NE 0.
      MESSAGE E013 WITH TEXT-H03.
    ENDIF.
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
  CLEAR: GT_FCAT[], GS_LAYO, GT_EXCL[],
         GT_EXCL, GV_OKCODE,
         GT_FIBER[].

  CALL METHOD GO_CONT->FREE.
  CLEAR : GO_CONT, GO_GRID.
  CALL METHOD CL_GUI_CFW=>FLUSH.
  LEAVE TO SCREEN 0.
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

      "FIBER 입고 정보 조회
      PERFORM F_GET_FIBER_DATA.

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

  CHECK S_WERKS[] IS NOT INITIAL.

  "TARGET과 플랜트 매칭
  SELECT FLD_01, FLD_02, FLD_03, FLD_04
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ @GC_PP
     AND CODEGRP EQ @GC_0010
     AND FLD_01 EQ @P_IFSYT
    INTO TABLE @DATA(LT_TARGET).

  SELECT WERKS
    FROM T001W
   WHERE WERKS IN @S_WERKS
    INTO TABLE @DATA(LT_WERKS).

  LOOP AT LT_WERKS ASSIGNING FIELD-SYMBOL(<LS_WERKS>).
    READ TABLE LT_TARGET INTO DATA(LS_TARGET) WITH KEY FLD_03 = <LS_WERKS>-WERKS.
    IF SY-SUBRC NE 0.
      MESSAGE S000 DISPLAY LIKE 'E'
         WITH TEXT-M01. "전송대상 플랜트가 아닙니다.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_GET_FIBER_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_FIBER_DATA .

  "초기화
  CLEAR: GT_FIBER[].

  SELECT A~VLABELNO, A~EBELN, A~EBELP, A~BUDAT, A~WERKS,
         A~MATNR, A~MENGE, A~MEINS, A~LANCHAR,
*>S.2026.07.08_수정된 정보 전송하기 위한 변경일자 정보 추가
         A~AEDAT, A~AEDAT_LOCAL,
         A~AETIM, A~AETIM_LOCAL,
         A~AENAM,
*<E.2026.07.08 ZGODEV04.
         B~TXZ01,
         C~LIFNR
    FROM ZGTMMT9460 AS A
    LEFT JOIN EKPO AS B ON B~EBELN EQ A~EBELN
                       AND B~EBELP EQ A~EBELP
                       AND B~MATNR EQ A~MATNR
    LEFT JOIN EKKO AS C ON C~EBELN EQ A~EBELN
   WHERE A~WERKS IN @S_WERKS
     AND A~BUDAT IN @S_BUDAT
     AND A~MATNR IN @S_MATNR
     AND A~EBELN IN @S_EBELN
     AND NOT EXISTS ( SELECT ZF~VLABELNO, ZF~EBELN, ZF~EBELP
                        FROM ZGTMMT9466 AS ZF
                       INNER JOIN ZGTMMT9000 AS ZLOG ON ZLOG~ZIFKEY EQ ZF~ZIFKEY
                                                    AND ZLOG~SYSTEM_ID EQ ZF~SYSTEM_ID
                       WHERE ZF~VLABELNO    EQ A~VLABELNO
                         AND ZF~EBELN       EQ A~EBELN
                         AND ZF~EBELP       EQ A~EBELP
                         AND ZLOG~SYSTEM_ID EQ @P_IFSYT
                         AND ZLOG~ZSTAT     EQ @GC_S
                         AND ZLOG~ZIFNO     EQ @GC_MM00065
                         AND A~AEDAT IS INITIAL )
    INTO CORRESPONDING FIELDS OF TABLE @GT_FIBER.

  SORT GT_FIBER BY VLABELNO EBELN EBELP BUDAT.

  CHECK GT_FIBER[] IS NOT INITIAL.

  LOOP AT GT_FIBER ASSIGNING FIELD-SYMBOL(<LS_FIBER>).
    <LS_FIBER>-SYSTEM_ID = P_IFSYT.
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
  IF GT_FIBER[] IS INITIAL.
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
    CALL SCREEN 0100.
  ENDIF.

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
*& Form F_GET_IF_LOG_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_GET_IF_LOG_DATA .

  "초기화
  CLEAR GT_FIBER[].

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
   SELECT Z1~ZIFNO,
          Z1~SYSTEM_ID,
          Z2~VLABELNO,
          MAX( Z1~ZIFKEY ) AS ZIFKEY
     FROM ZGTMMT9000 AS Z1
     INNER JOIN ZGTMMT9466 AS Z2 ON Z1~ZIFKEY EQ Z2~ZIFKEY
                                AND Z1~SYSTEM_ID EQ Z2~SYSTEM_ID
     WHERE Z1~ZIFNO EQ @GC_MM00065
       AND Z1~SYSTEM_ID IN @LR_SYSTEM_ID
       AND Z1~ERDAT IN @S_IFDAT
       AND Z2~WERKS IN @S_WERKS
       AND Z2~MATNR IN @S_MATNR
       AND Z2~EBELN IN @S_EBELN
     GROUP BY Z1~ZIFNO, Z1~SYSTEM_ID, Z2~VLABELNO
     )
     SELECT
   "I/F
       Z1~ZIFNO,
       Z1~ZIFKEY,
       Z1~SYSTEM_ID,
       Z1~ZSTAT,
       Z1~MESSAGE,
       Z1~IFNAM,
   "FIBER정보
       Z2~VLABELNO,
       Z2~EBELN,
       Z2~EBELP,
       Z2~BUDAT,
       Z2~WERKS,
       Z2~MATNR,
       Z2~MENGE,
       Z2~MEINS,
       Z2~LANCHAR
       FROM ZGTMMT9000 AS Z1
      INNER JOIN ZGTMMT9466 AS Z2 ON Z1~ZIFKEY EQ Z2~ZIFKEY
                                 AND Z1~SYSTEM_ID EQ Z2~SYSTEM_ID
      INNER JOIN +V_LAST AS V1 ON Z1~ZIFNO EQ V1~ZIFNO
                              AND Z1~SYSTEM_ID EQ V1~SYSTEM_ID
                              AND Z1~ZIFKEY EQ V1~ZIFKEY
                              AND Z2~VLABELNO EQ V1~VLABELNO
       WHERE Z1~ZSTAT IN @LR_ZSTAT "I/F 성공 데이터 포함
     INTO CORRESPONDING FIELDS OF TABLE @GT_FIBER.

  CHECK GT_FIBER[] IS NOT INITIAL.

  LOOP AT GT_FIBER ASSIGNING FIELD-SYMBOL(<LS_FIBER>).
    <LS_FIBER>-EBELN = |{ <LS_FIBER>-EBELN ALPHA = IN }|.
    <LS_FIBER>-EBELP = |{ <LS_FIBER>-EBELP ALPHA = IN }|.
    <LS_FIBER>-MENGE = ABS( <LS_FIBER>-MENGE ).

    "자재코드
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT  = <LS_FIBER>-MATNR
      IMPORTING
        OUTPUT = <LS_FIBER>-MATNR.

    "단위
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        INPUT  = <LS_FIBER>-MEINS
      IMPORTING
        OUTPUT = <LS_FIBER>-MEINS.

  ENDLOOP.

  "시스템 내역
  SELECT DISTINCT
         FLD_01,
         FLD_02
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ @GC_PP
   AND CODEGRP EQ @GC_0010
   ORDER BY FLD_01
   INTO TABLE @DATA(LT_TXT).

  "자재내역
##ITAB_KEY_IN_SELECT
  SELECT DISTINCT
    EKPO~MATNR,
    EKPO~TXZ01
    FROM EKPO AS EKPO
   WHERE EXISTS ( SELECT ZZ~MATNR
                    FROM @GT_FIBER AS ZZ
                   WHERE ZZ~EBELN EQ EKPO~EBELN
                     AND ZZ~EBELP EQ EKPO~EBELP
                     AND ZZ~MATNR IS NOT INITIAL )
   ORDER BY EKPO~MATNR
    INTO TABLE @DATA(LT_TXZ01).

  "공급업체
##ITAB_KEY_IN_SELECT
  SELECT DISTINCT
    EKKO~EBELN,
    EKKO~LIFNR
    FROM EKKO AS EKKO
   WHERE EXISTS ( SELECT ZZ~LIFNR
                    FROM @GT_FIBER AS ZZ
                   WHERE ZZ~EBELN EQ EKKO~EBELN )
   ORDER BY EKKO~EBELN
    INTO TABLE @DATA(LT_LIFNR).

  UNASSIGN <LS_FIBER>.
  LOOP AT GT_FIBER ASSIGNING <LS_FIBER>.
    "시스템 내역
    READ TABLE LT_TXT ASSIGNING FIELD-SYMBOL(<LS_TXT>) WITH KEY FLD_01 = <LS_FIBER>-SYSTEM_ID BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_FIBER>-SYSTEM_TXT = <LS_TXT>-FLD_02.
    ENDIF.

    "자재내역
    READ TABLE LT_TXZ01 ASSIGNING FIELD-SYMBOL(<LS_TXZ01>) WITH KEY MATNR = <LS_FIBER>-MATNR BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_FIBER>-TXZ01 = <LS_TXZ01>-TXZ01.
    ENDIF.

    "공급업체명
    READ TABLE LT_LIFNR ASSIGNING FIELD-SYMBOL(<LS_LIFNR>) WITH KEY EBELN = <LS_FIBER>-EBELN BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_FIBER>-LIFNR = <LS_LIFNR>-LIFNR.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SEND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F_SEND .

  DATA:
    LV_CNT_S   TYPE INT4,
    LV_CNT_E   TYPE INT4,
    LV_CNT_RUN TYPE INT4,
    LV_DEST    TYPE ZDEST,
    LT_DATA    TYPE TY_T_DATA,
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
        TITLEBAR      = TEXT-TT1
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

*	: 최종 전송 대상이 전송 이력 테이블에 존재하는지 점검. 전송 이력이 없는 대상을 기준으로함
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
    IF GT_FIBER[] IS INITIAL.
*4-3) 전송 버튼 클릭시 선택 된 라인이 없으면 하단 에러 메시지 처리 "선택된 데이터가 없습니다."
      MESSAGE E050.
    ENDIF.

  ENDIF.

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
        READ TABLE GT_FIBER ASSIGNING FIELD-SYMBOL(<LS_FIBER>) INDEX <LS_ROW>-ROW_ID.
        CHECK SY-SUBRC EQ 0.
        CT_SYS[] = VALUE #( BASE CT_SYS[] ( SYSTEM_ID = <LS_FIBER>-SYSTEM_ID ) ).
      ENDLOOP.

      SORT CT_SYS BY SYSTEM_ID.
      DELETE ADJACENT DUPLICATES FROM CT_SYS COMPARING SYSTEM_ID.

    ELSE.

      "조회 된 전체 시스템
##ITAB_KEY_IN_SELECT
##ITAB_DB_SELECT
      SELECT DISTINCT ZZ~SYSTEM_ID
        FROM @GT_FIBER AS ZZ
         INTO TABLE @CT_SYS.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_DATA
*&      --> <LS_SYS>_SYSTEM_ID
*&---------------------------------------------------------------------*
FORM F_SET_SEND_DATA  TABLES   PT_DATA TYPE TY_T_DATA
                      USING    PV_SYSTEM_ID.

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
    READ TABLE GT_FIBER ASSIGNING FIELD-SYMBOL(<LS_FIBER>) INDEX <LS_ROW>-ROW_ID.
    CHECK SY-SUBRC EQ 0.

    "대상 시스템
    CHECK <LS_FIBER>-SYSTEM_ID = PV_SYSTEM_ID.

    "데이터 설정
    PERFORM F_SET_DOC_DATA USING <LS_FIBER> CHANGING LS_DATA.

    "라인추가
    PT_DATA[] = VALUE #( BASE PT_DATA[] ( LS_DATA  ) ).

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SET_DOC_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_FIBER>
*&      <-- LS_DATA
*&---------------------------------------------------------------------*
FORM F_SET_DOC_DATA  USING    PS_FIBER TYPE TY_FIBER
                     CHANGING CS_DATA TYPE TY_DATA.

  "초기화
  CLEAR CS_DATA.

  "값 설정
  CS_DATA = CORRESPONDING #( PS_FIBER ).

  CS_DATA-EBELN = |{ CS_DATA-EBELN ALPHA = OUT }|.
  CS_DATA-EBELP = |{ CS_DATA-EBELP ALPHA = OUT }|.
  CS_DATA-LIFNR = |{ CS_DATA-LIFNR ALPHA = OUT }|.

  "수량
*  WRITE PS_FIBER-MENGE_V TO CS_DATA-MENGE LEFT-JUSTIFIED NO-GROUPING.
*  CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
*    CHANGING
*      VALUE = CS_DATA-MENGE.

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
*&      --> <LS_SYS>_SYSTEM_ID
*&---------------------------------------------------------------------*
FORM F_SET_BAT_SEND_DATA  TABLES   PT_DATA TYPE TY_T_DATA
                          USING    PV_SYSTEM_ID.

  "초기화
  CLEAR PT_DATA[].

  DATA LS_DATA TYPE TY_DATA.

  LOOP AT GT_FIBER ASSIGNING FIELD-SYMBOL(<LS_FIBER>).
    "대상 시스템
    CHECK <LS_FIBER>-SYSTEM_ID = PV_SYSTEM_ID.

    "데이터 설정
    PERFORM F_SET_DOC_DATA USING <LS_FIBER> CHANGING LS_DATA.

    "라인추가
    PT_DATA[] = VALUE #( BASE PT_DATA[] ( LS_DATA ) ).
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_CHECK_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_SYS>_SYSTEM_ID
*&      --> LT_DATA
*&      <-- LT_SUC
*&---------------------------------------------------------------------*
FORM F_CHECK_SEND_DATA  USING    PV_SYSTEM_ID TYPE ZGTE_IF_TARGET
                                 PT_DATA TYPE TY_T_DATA
                        CHANGING CT_SUC TYPE TY_T_SUC.

  "전송 성공 이력이 포함된 자재문서
##ITAB_KEY_IN_SELECT
  SELECT DISTINCT
         @PV_SYSTEM_ID AS SYSTEM_ID,
         ZZ~VLABELNO
    FROM @PT_DATA AS ZZ
   WHERE EXISTS (
* 전송 성공 이력이 있는 문서번호
         SELECT ZF~VLABELNO
           FROM ZGTMMT9466 AS ZF
          INNER JOIN ZGTMMT9000 AS ZLOG ON ZLOG~SYSTEM_ID EQ ZF~SYSTEM_ID
                                       AND ZLOG~ZIFKEY EQ ZF~ZIFKEY
          WHERE ZF~VLABELNO EQ ZZ~VLABELNO
            AND ZLOG~SYSTEM_ID EQ @PV_SYSTEM_ID "전송 대상 시스템 ID
            AND ZLOG~ZSTAT EQ @GC_S "전송 성공
            AND ZLOG~ZIFNO EQ @GC_MM00065 )"[MES]FIBER 입고 정보 전송
    INTO TABLE @CT_SUC.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_RUN_SEND_RFC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SY_INDEX
*&      --> <LS_SYS>_SYSTEM_ID
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
    LT_DATA      TYPE STANDARD TABLE OF ZGTMMS4008,
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

    "이미 성공한 정보는 오류로 처리
    READ TABLE PT_SUC WITH TABLE KEY SYSTEM_ID = PV_SYSTEM_ID
                                     VLABELNO = <LS_DATA>-VLABELNO
                                     TRANSPORTING NO FIELDS.
    IF SY-SUBRC EQ 0.
*>S.2026.07.08
*입고정보 수정이 가능하게 기능추가가 되면서 전송/재전송 시 PT_SUC 존재하면 제외하던것을
*대상라벨의 AEDAT정보가 없을 경우에만 제외하는 것으로 추가 체크.
      IF <LS_DATA>-AEDAT IS INITIAL.
        CV_CNT_E += 1. "오류 추가
        CONTINUE.
      ENDIF.       "<E.2026.07.08 ZGODEV04.
    ENDIF.

    "라인추가
    LT_DATA[] = VALUE #( BASE LT_DATA ( CORRESPONDING #( <LS_DATA> ) ) ).
    LT_LOG[] = VALUE #( BASE LT_LOG ( <LS_DATA> ) ).
  ENDLOOP.

  "전송 대상이 있으면 진행
  CHECK LT_DATA[] IS NOT INITIAL.

  CALL FUNCTION 'ZGTMM_IF_GET_DESTINATION'
    EXPORTING
      I_ZIFNO = GC_MM00065
    IMPORTING
      E_ZDEST = LV_DEST.

  CALL FUNCTION 'ZGTMM_IF_O_FIBERGRDETAIL_SEND'
    DESTINATION LV_DEST
    EXPORTING
      I_SYSTEM_ID = PV_SYSTEM_ID
    IMPORTING
      ZO_RESULT   = LV_RESULT
      ZO_MESSAGE  = LV_MESSAGE
    TABLES
      OT_ITEM     = LT_DATA.

  IF SY-SUBRC NE 0.
    LV_RESULT = GC_02.
  ENDIF.

  "메세지 처리
  IF LV_RESULT EQ GC_00.
    "성공
    CV_CNT_S += LINES( LT_LOG ).
    LV_RESULT = GC_S.
  ELSE.
    "오류
    CV_CNT_E += LINES( LT_LOG ).
    LV_RESULT = GC_E  .
  ENDIF.

  "로그 저장
  SORT LT_LOG BY VLABELNO EBELN EBELP.
  PERFORM F_SAVE_IF_LOG TABLES LT_LOG USING LV_RESULT LV_MESSAGE PV_SYSTEM_ID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_SAVE_IF_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_LOG
*&      --> LV_RESULT
*&      --> LV_MESSAGE
*&      --> PV_SYSTEM_ID
*&---------------------------------------------------------------------*
FORM F_SAVE_IF_LOG  TABLES    PT_DATA TYPE TY_T_DATA
                     USING    PV_RET
                              PV_MSG
                              PV_SYSTEM_ID.

  DATA:
    LS_LOG      TYPE ZGTMMT9000,
    LS_LOG_DATA TYPE ZGTMMT9466,
    LT_LOG_DATA TYPE STANDARD TABLE OF ZGTMMT9466,
    LT_LOG_9460 TYPE STANDARD TABLE OF ZGTMMT9460.

  GET TIME STAMP FIELD LS_LOG-ZIFKEY.
  LS_LOG-ZIFNO       = GC_MM00065.
  IF PV_SYSTEM_ID EQ SPACE.
    LS_LOG-SYSTEM_ID = P_IFSYT.
  ELSE.
    LS_LOG-SYSTEM_ID = PV_SYSTEM_ID.
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
                                  SYSTEM_ID = LS_LOG-SYSTEM_ID ) ) ).

  LOOP AT LT_LOG_DATA ASSIGNING FIELD-SYMBOL(<LS_LOG_DATA>).
    <LS_LOG_DATA>-EBELN = |{ <LS_LOG_DATA>-EBELN ALPHA = IN }|.
    <LS_LOG_DATA>-EBELP = |{ <LS_LOG_DATA>-EBELP ALPHA = IN }|.

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

*>S.2026.07.08
*5) 전송 성공 후 대상 라벨의 ZGTMMT9460-AEDAT 값이 존재하는 데이터의 경우,
*ZGTMMT9460-ERDAT을 AEDAT로 변경하고, AEDAT은 빈 값으로 업데이트 한다.
     READ TABLE PT_DATA ASSIGNING FIELD-SYMBOL(<L9460>)
     WITH KEY VLABELNO = <LS_LOG_DATA>-VLABELNO
                     EBELN      = <LS_LOG_DATA>-EBELN
                     EBELP      = <LS_LOG_DATA>-EBELP BINARY SEARCH.

     IF SY-SUBRC = 0 AND <L9460>-AEDAT IS NOT INITIAL.
       LT_LOG_9460 = VALUE #( BASE LT_LOG_9460 (
                               VALUE #( BASE CORRESPONDING #( <L9460> )
                                              ERDAT = <L9460>-AEDAT
                                              ERDAT_LOCAL = <L9460>-AEDAT_LOCAL
                                              ERTIM = <L9460>-AETIM
                                              ERTIM_LOCAL = <L9460>-AETIM_LOCAL
                                              ERNAM = <L9460>-AENAM
                                              AEDAT = ''
                                              AEDAT_LOCAL = ''
                                              AETIM = ''
                                              AETIM_LOCAL = ''
                                              AENAM = '' ) ) ).
     ENDIF.
  ENDLOOP.

  IF LT_LOG_9460[] IS NOT INITIAL.
    MODIFY ZGTMMT9460 FROM TABLE LT_LOG_9460.
    COMMIT WORK.
  ENDIF.
*<E.2026.07.08 ZGODEV04.

  MODIFY ZGTMMT9466 FROM TABLE LT_LOG_DATA.
  MODIFY ZGTMMT9000 FROM LS_LOG.
  COMMIT WORK.

ENDFORM.
