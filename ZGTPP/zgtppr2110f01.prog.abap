*&---------------------------------------------------------------------*
*& Include          ZGTPPR2110F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form MODIFY_FIRST_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_FIRST_SCREEN .

  IF P_PROC = ABAP_TRUE.
    REFRESH S_DATE[].
    S_DATE-LOW = SY-DATUM.
    APPEND S_DATE.
  ENDIF.

  LOOP AT SCREEN.

    IF SCREEN-GROUP1 = 'M1'.
      SCREEN-INPUT = 0.
*      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.

    IF SCREEN-GROUP1 = 'M2'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.

    CASE ABAP_TRUE.
      WHEN P_DISP.
        IF SCREEN-NAME = 'S_DATE-LOW'.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.
      WHEN P_PROC.
        IF SCREEN-NAME = 'S_DATE-LOW'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PARAMETER_DESCRIPTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PARAMETER_DESCRIPTION .

* SPG
  IF NOT P_SPGCD IS INITIAL.
    SELECT SINGLE DESCR INTO P_DESCR
             FROM ZPPT0107
            WHERE SPGCD EQ P_SPGCD.
  ELSE.
    CLEAR P_DESCR.
  ENDIF.

* 플랜트명
  IF NOT P_WERKS IS INITIAL.
    SELECT SINGLE NAME1 INTO P_NAME1
             FROM T001W
            WHERE WERKS EQ P_WERKS.
  ELSE.
    CLEAR P_NAME1.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATION_OF_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VALIDATION_OF_WERKS .

  IF P_WERKS IS NOT INITIAL.
    SELECT SINGLE WERKS FROM ZPPT0107
       INTO @DATA(LV_WERKS)
     WHERE SPGCD = @P_SPGCD
        AND WERKS =  @P_WERKS.
    IF SY-SUBRC NE 0.
      MESSAGE E006 WITH '소재(SCR)에 해당하는 플랜트가 아닙니다.'.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_WERKS  USING    PV_DYNPROFLD TYPE HELP_INFO-DYNPROFLD .

  DATA : BEGIN OF LS_WERKS,
           WERKS TYPE ZPPT0107-WERKS,
           NAME1 TYPE T001W-NAME1,
           SPGCD TYPE ZPPT0107-SPGCD,
           DESCR TYPE ZPPT0107-DESCR,
         END OF LS_WERKS.
  DATA : LT_WERKS LIKE TABLE OF LS_WERKS.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LV_OFFSET(6) TYPE N.
  DATA : LO_FLIEF TYPE REF TO DATA.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

* SPG 기준 'BC' 해당 플랜트만 조회
  SELECT A~WERKS, B~NAME1, A~SPGCD, A~DESCR
    FROM ZPPT0107 AS A
    INNER JOIN T001W AS B ON B~WERKS = A~WERKS
    INTO CORRESPONDING FIELDS OF TABLE @LT_WERKS
   WHERE A~SPGCD = @P_SPGCD.
  SORT LT_WERKS BY WERKS.
  DELETE ADJACENT DUPLICATES FROM LT_WERKS COMPARING WERKS.

* 필드 속성 정의
  FREE LO_FLIEF.
  CREATE DATA LO_FLIEF LIKE LS_WERKS.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).

    CASE <LS_FIELD_TAB>-FIELDNAME.
      WHEN 'WERKS'.
        <LS_FIELD_TAB>-REPTEXT  = '플랜트'.
      WHEN 'NAME1'.
        <LS_FIELD_TAB>-REPTEXT  = '플랜트명'.
      WHEN 'SPGCD'.
        <LS_FIELD_TAB>-REPTEXT  = 'SPG'.
      WHEN 'DESCR'.
        <LS_FIELD_TAB>-REPTEXT  = 'SPG 내역'.
    ENDCASE.

    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'WERKS'
      DYNPROFIELD     = PV_DYNPROFLD           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '플랜트 조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = LT_WERKS                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    READ TABLE LT_WERKS INTO LS_WERKS WITH KEY WERKS = LS_RETURN_TAB-FIELDVAL.

    REFRESH LT_DYNPFIELDS.
    PERFORM GET_STEPL USING LV_LINE.
*      시뮬레이션 번호
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
    <LS_DYNPFIELDS>-FIELDNAME = 'P_WERKS'.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_WERKS-WERKS.

*      시뮬레이션 이름
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING <LS_DYNPFIELDS>.
    <LS_DYNPFIELDS>-FIELDNAME = 'P_NAME1'.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_WERKS-NAME1.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME               = SY-CPROG
        DYNUMB               = SY-DYNNR
      TABLES
        DYNPFIELDS           = LT_DYNPFIELDS
      EXCEPTIONS
        INVALID_ABAPWORKAREA = 1
        INVALID_DYNPROFIELD  = 2
        INVALID_DYNPRONAME   = 3
        INVALID_DYNPRONUMMER = 4
        INVALID_REQUEST      = 5
        NO_FIELDDESCRIPTION  = 6
        UNDEFIND_ERROR       = 7
        OTHERS               = 8.
    IF SY-SUBRC <> 0.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STEPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_LINE
*&---------------------------------------------------------------------*
FORM GET_STEPL  USING    PV_LINE LIKE SY-STEPL.
  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = PV_LINE
    EXCEPTIONS
      STEPL_NOT_FOUND = 01.

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

*& MRP관리자에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_SPGCD'
  ID 'WERKS'  FIELD P_WERKS
  ID 'SPGCD'  FIELD P_SPGCD.

  IF SY-SUBRC <> 0.
    MESSAGE E006 WITH 'SPG[' P_SPGCD
                      '] 작업권한을 확인하세요.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PROC .

* 초기 세팅 설정, 조회날짜범위 세팅
  PERFORM INIT_DATA.

* 디스플레이 화면 구성, 동적 인터널테이블 생성
  PERFORM INIT_SCREEN_100.

* 대상정보 추출.
  PERFORM GET_DATA.

* 대상정보 추출.
  PERFORM SET_DISP_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

  IF S_DATE IS INITIAL.
    S_DATE-LOW = SY-DATUM.
    S_DATE-HIGH = SY-DATUM.
    PERFORM CAL_DATE_TO_MONTH USING '2' CHANGING S_DATE-HIGH.
    PERFORM GET_LAST_DAY_OF_MONTH CHANGING S_DATE-HIGH.
    APPEND S_DATE.
  ENDIF.

  GET PARAMETER ID 'WRK' FIELD P_WERKS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LAST_DAY_OF_MONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_END_DATE
*&---------------------------------------------------------------------*
FORM GET_LAST_DAY_OF_MONTH  CHANGING PV_DATE TYPE SY-DATUM.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = PV_DATE
    IMPORTING
      LAST_DAY_OF_MONTH = PV_DATE
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.
  .
  IF SY-SUBRC <> 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form cal_date_to_month
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- S_DATE_HIGH
*&---------------------------------------------------------------------*
FORM CAL_DATE_TO_MONTH  USING PV_MONTH
                        CHANGING PV_DATE TYPE SY-DATUM.
  CALL FUNCTION 'CALCULATE_DATE'
    EXPORTING
      MONTHS      = PV_MONTH
      START_DATE  = PV_DATE
    IMPORTING
      RESULT_DATE = PV_DATE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATION_OF_PERIOD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VALIDATION_OF_PERIOD .

  DATA : LV_CHK_DATE TYPE SY-DATUM.

  LV_CHK_DATE = SY-DATUM - 40.

  IF S_DATE-LOW < LV_CHK_DATE.
    MESSAGE E006 WITH '현재일부터 40일 이전까지만 조회 가능합니다.'.
  ENDIF.
  CLEAR LV_CHK_DATE.

  IF S_DATE-HIGH IS INITIAL OR S_DATE-HIGH = '00000000'.
    MESSAGE E006 WITH '계획기간은 현재일부터 6개월까지 입니다.'.
  ELSE.
    LV_CHK_DATE = SY-DATUM.
    PERFORM CAL_DATE_TO_MONTH USING '6' CHANGING LV_CHK_DATE.
    PERFORM GET_LAST_DAY_OF_MONTH CHANGING LV_CHK_DATE.
    IF S_DATE-HIGH > LV_CHK_DATE.
      MESSAGE E006 WITH '계획기간은 현재일부터 6개월까지 입니다.'.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_DATA .

  PERFORM SET_CATALOG.

  PERFORM SET_INIT_RANGES_OF_DATE.

  PERFORM GET_MANAGEMENT_MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CATALOG .

  REFRESH GT_CATALOG.
  FREE GT_CATALOG.

  DEFINE __SET_CATALOG.
    CLEAR: gs_catalog.
    gs_catalog-seq_catalog = &1.
    gs_catalog-catalog = &2.
    APPEND gs_catalog TO gt_catalog.
  END-OF-DEFINITION.

  __SET_CATALOG : 1 '판매계획',
                  2 '판매오더',
                  3 '사내이체',
                  4 '생산계획',
                  11 '사급',
                  12 '신선',
                  60 '마이너스수량',
                  99 '예상재고'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_INIT_RANGES_OF_DATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_INIT_RANGES_OF_DATE .

  REFRESH : GT_DATE, GT_WEEK.
  FREE : GT_DATE, GT_WEEK.

  DATA : LV_STR_DATE TYPE SY-DATUM.
  DATA : LV_END_DATE TYPE SY-DATUM.
  DATA : LV_CHK_DATE TYPE SY-DATUM.
  DATA : LV_CURRENT_DATE TYPE SY-DATUM.
  DATA : LV_CHK_END.
  CLEAR GV_END_DT.
* 초기구간 세팅
*  - 계획기간 시작일부터  시작일 + 14일( 해당일이 해당주차 마지막 일자가 아니라면 해당주차 마지막 일까지)
*  - 날짜 계획기간 변경 말일 기준 -10일 이전이라면 현재월 말일까지, -10일 이후면 다음달 말일(2025114)
*  -  중간에 계획기간 종료일이 있다면 종료일로 세팅
*  -  초기 범위는 일자로 구성
*  - 위에서 정한 해당주차 다음주차부터 종료일 주차까지 주차로 세팅
*  - 해당 범위는 주자로 구성
  LV_STR_DATE = S_DATE-LOW.
*  계획일자 변경
*  LV_END_DATE = SY-DATUM + 13.
*  PERFORM SET_LASTDAY_OF_WEEK CHANGING LV_END_DATE.
*
  LV_END_DATE = LV_STR_DATE.
  PERFORM GET_LAST_DAY_OF_MONTH CHANGING LV_END_DATE.

* 다음달 일자로 조회조건 말일 -15일 이후
  LV_CHK_DATE = LV_END_DATE - 15.
  IF LV_CHK_DATE <= LV_STR_DATE.
    LV_END_DATE = LV_END_DATE + 1.
    PERFORM GET_LAST_DAY_OF_MONTH CHANGING LV_END_DATE.
  ENDIF.

  PERFORM SET_OFF_DAY USING LV_STR_DATE LV_END_DATE.


  CLEAR LV_CHK_END.
  IF LV_END_DATE >= S_DATE-HIGH.
    LV_END_DATE = S_DATE-HIGH.
    LV_CHK_END = ABAP_TRUE.
  ENDIF.

* 초기구간(일자별 구성)
  LV_CURRENT_DATE = LV_STR_DATE.
  DO.
    IF LV_CURRENT_DATE > LV_END_DATE.
      EXIT.
    ENDIF.

    CLEAR GS_DATE.
    GS_DATE-DATE = LV_CURRENT_DATE.
    GS_DATE-FIELDNAME = LV_CURRENT_DATE.
    IF LV_CURRENT_DATE+4(4) = '0101'.
      GS_DATE-REPTEXT = LV_CURRENT_DATE+0(4) && '/' && LV_CURRENT_DATE+4(2) && '/' && LV_CURRENT_DATE+6(2).
    ELSE.
      GS_DATE-REPTEXT = LV_CURRENT_DATE+4(2) && '/' && LV_CURRENT_DATE+6(2).
    ENDIF.
    APPEND GS_DATE TO GT_DATE.

    ADD 1 TO LV_CURRENT_DATE.
  ENDDO.

  IF GV_END_DT < S_DATE-HIGH.
    GV_END_DT = S_DATE-HIGH.
  ENDIF.


  CHECK LV_CHK_END IS INITIAL.
* 이후구간(주차별 구성)

  LV_CURRENT_DATE = LV_END_DATE + 7.

  DO.

    IF LV_CURRENT_DATE >= S_DATE-HIGH.
      GV_END_DT = LV_CURRENT_DATE - 1.
      EXIT.
    ENDIF.

    PERFORM SET_WEEK_INFO USING LV_CURRENT_DATE.


    ADD 7 TO LV_CURRENT_DATE.
  ENDDO.

*  set spmon table
  PERFORM SET_SPMON_TAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LASTDAY_OF_WEEK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_END_DATE
*&---------------------------------------------------------------------*
FORM SET_LASTDAY_OF_WEEK  CHANGING PV_DATE TYPE SY-DATUM.

  CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
    EXPORTING
      DATE   = PV_DATE
    IMPORTING
      SUNDAY = PV_DATE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_WEEK_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_CURRENT_DATE
*&---------------------------------------------------------------------*
FORM SET_WEEK_INFO  USING    PV_DATE TYPE SY-DATUM.

  CLEAR GS_WEEK.
  DATA : LV_MM(2).
  DATA : LV_WW(1).

  CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
    EXPORTING
      DATE   = PV_DATE
    IMPORTING
      WEEK   = GS_WEEK-WEEK
      MONDAY = GS_WEEK-FRDATE
      SUNDAY = GS_WEEK-TODATE.

  GS_WEEK-FIELDNAME = GS_WEEK-WEEK.

  IF GS_WEEK-WEEK+4(2) = '01'. "년초일경우 년도 포함
    GS_WEEK-REPTEXT = GS_WEEK-WEEK+0(4) && '년'.
  ENDIF.

  CLEAR LV_MM.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = GS_WEEK-TODATE+4(2)
    IMPORTING
      OUTPUT = LV_MM.

  CLEAR LV_WW.
  IF GS_WEEK-TODATE+6(2) BETWEEN '01' AND '07'.
    LV_WW = '1'.
  ELSEIF GS_WEEK-TODATE+6(2) BETWEEN '08' AND '14'.
    LV_WW = '2'.
  ELSEIF GS_WEEK-TODATE+6(2) BETWEEN '15' AND '21'.
    LV_WW = '3'.
  ELSEIF GS_WEEK-TODATE+6(2) BETWEEN '22' AND '28'.
    LV_WW = '4'.
  ELSEIF GS_WEEK-TODATE+6(2) > '28'.
    LV_WW = '5'.
  ENDIF.

  CONCATENATE GS_WEEK-REPTEXT LV_MM '월' LV_WW '주' INTO GS_WEEK-REPTEXT.

  APPEND GS_WEEK TO GT_WEEK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_SCREEN_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM INIT_SCREEN_100.

  PERFORM SET_FIELDCAT_0100.

  PERFORM MAKE_ITAB_FR_FCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_0100.

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LV_COL_POS TYPE I.
  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LV_CHK_DATE TYPE SY-DATUM.

*----------------------------------------------------------------------*
* fieldcat from gs_main.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = 'GS_MAIN'
      I_INCLNAME         = 'ZGTPPR2110TOP'
      I_BYPASSING_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT        = LT_FCAT.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_MAIN.

*----------------------------------------------------------------------*
* 추가필드 세팅
  READ TABLE GT_FIELDCAT_0100 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'SEQ_MAIN'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-FIELDNAME = 'SEQ_MAIN'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'SEQ_MATNR'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-FIELDNAME = 'SEQ_MATNR'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'SEQ_ATWRT'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 5.
    <LS_FCAT>-FIELDNAME = 'SEQ_ATWRT'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'SEQ_CATALOG'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 7.
    <LS_FCAT>-FIELDNAME = 'SEQ_CATALOG'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'CATALOG'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 8.
    <LS_FCAT>-FIELDNAME = 'CATALOG'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'OVERDUE'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 10.
    <LS_FCAT>-FIELDNAME = 'OVERDUE'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '현재재고'.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
    <LS_FCAT>-OUTPUTLEN = '5'.
    <LS_FCAT>-JUST = 'R'.
  ENDIF.

*----------------------------------------------------------------------*
* 일자 필드 추가.
  LV_COL_POS = 100.
  LOOP AT GT_DATE INTO GS_DATE.
    "월이 바뀌면 월합계 필드 추가.
    IF LV_CHK_DATE NE '00000000' AND LV_CHK_DATE+0(6) NE GS_DATE-DATE+0(6).
      READ TABLE GT_SPMON INTO GS_SPMON WITH KEY SPMON = LV_CHK_DATE+0(6).

      APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
      ADD 1 TO LV_COL_POS.
      <LS_FCAT>-COL_POS = LV_COL_POS.
      <LS_FCAT>-FIELDNAME = GS_SPMON-FIELDNAME.
      <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = GS_SPMON-REPTEXT.
      <LS_FCAT>-DATATYPE = 'CHAR'.
      <LS_FCAT>-DD_OUTLEN = '20'.
      <LS_FCAT>-JUST = 'R'.
    ENDIF.

    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    ADD 1 TO LV_COL_POS.
    <LS_FCAT>-COL_POS = LV_COL_POS.
    <LS_FCAT>-FIELDNAME = GS_DATE-FIELDNAME.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = GS_DATE-REPTEXT.
    IF GS_DATE-DATE = SY-DATUM.
      <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '*' && GS_DATE-REPTEXT.
    ENDIF.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '20'.
    <LS_FCAT>-JUST = 'R'.

    LV_CHK_DATE = GS_DATE-DATE.
  ENDLOOP.

*----------------------------------------------------------------------*
* 주차 필드 추가.
  IF GT_WEEK IS NOT INITIAL.
    LV_COL_POS = 200.

    LOOP AT GT_WEEK INTO GS_WEEK.
      "월이 바뀌면 월합계 필드 추가.
      IF LV_CHK_DATE NE '00000000' AND LV_CHK_DATE+0(6) NE GS_WEEK-FRDATE+0(6).
        READ TABLE GT_SPMON INTO GS_SPMON WITH KEY SPMON = LV_CHK_DATE+0(6).

        APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
        ADD 1 TO LV_COL_POS.
        <LS_FCAT>-COL_POS = LV_COL_POS.
        <LS_FCAT>-FIELDNAME = GS_SPMON-FIELDNAME.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = GS_SPMON-REPTEXT.
        <LS_FCAT>-DATATYPE = 'CHAR'.
        <LS_FCAT>-DD_OUTLEN = '20'.
        <LS_FCAT>-JUST = 'R'.
      ENDIF.

      APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
      ADD 1 TO LV_COL_POS.
      <LS_FCAT>-COL_POS = LV_COL_POS.
      <LS_FCAT>-FIELDNAME = GS_WEEK-FIELDNAME.
      <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = GS_WEEK-REPTEXT.
      <LS_FCAT>-DATATYPE = 'CHAR'.
      <LS_FCAT>-DD_OUTLEN = '20'.
      <LS_FCAT>-JUST = 'R'.

      LV_CHK_DATE = GS_WEEK-FRDATE.
    ENDLOOP.
  ENDIF.

*----------------------------------------------------------------------*
* 마지막 일자의 월합계 필드 추가.
  READ TABLE GT_SPMON INTO GS_SPMON WITH KEY SPMON = LV_CHK_DATE+0(6).
  IF SY-SUBRC EQ 0.
    READ TABLE GT_FIELDCAT_0100  ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = GS_SPMON-FIELDNAME.
    IF SY-SUBRC NE 0.
      APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
      ADD 1 TO LV_COL_POS.
      <LS_FCAT>-COL_POS = LV_COL_POS.
      <LS_FCAT>-FIELDNAME = GS_SPMON-FIELDNAME.
      <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = GS_SPMON-REPTEXT.
      <LS_FCAT>-DATATYPE = 'CHAR'.
      <LS_FCAT>-DD_OUTLEN = '20'.
      <LS_FCAT>-JUST = 'R'.
    ENDIF.
  ENDIF.

*  IF GT_SPMON IS NOT INITIAL.
*    LV_COL_POS = 500.
*
*    LOOP AT GT_SPMON INTO GS_SPMON.
*      APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
*      ADD 1 TO LV_COL_POS.
*      <LS_FCAT>-COL_POS = LV_COL_POS.
*      <LS_FCAT>-FIELDNAME = GS_SPMON-FIELDNAME.
*      <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = GS_SPMON-REPTEXT.
*      <LS_FCAT>-DATATYPE = 'CHAR'.
*      <LS_FCAT>-DD_OUTLEN = '20'.
*      <LS_FCAT>-JUST = 'R'.
*    ENDLOOP.
*
*  ENDIF.

*----------------------------------------------------------------------*
* 필드명 서술
  LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'SEQ_MAIN' OR 'SEQ_ATWRT' OR 'SEQ_CATALOG' OR 'SEQ_MATNR'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-TOOLTIP = '자재코드'(f01).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = '13'.
      WHEN 'MAKTX'.
        <LS_FCAT>-TOOLTIP = '자재내역'(f02).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = '15'.
      WHEN 'ATWRT'.
        <LS_FCAT>-TOOLTIP = '등급'(f03).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = '5'.
      WHEN 'CATALOG'.
        <LS_FCAT>-TOOLTIP = '구분'(f04).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = '5'.
      WHEN 'MEINS'.
        <LS_FCAT>-TOOLTIP = '단위'(f05).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = '5'.
      WHEN 'OVERDUE'.
*        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
*        <LS_FCAT>-QFIELDNAME = 'MEINS'.
*        <LS_FCAT>-QUANTITY = 'EA'.
*        <LS_FCAT>-DECIMALS = 0.
        <LS_FCAT>-OUTPUTLEN = '5'.
    ENDCASE.

    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP.
  ENDLOOP.

  SORT GT_FIELDCAT_0100 BY COL_POS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_ITAB_FR_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_ITAB_FR_FCAT .

  FREE GT_MAIN_DISP_100.

  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
      I_STYLE_TABLE             = ABAP_TRUE
      IT_FIELDCATALOG           = GT_FIELDCAT_0100
    IMPORTING
      EP_TABLE                  = GT_MAIN_DISP_100
    EXCEPTIONS
      GENERATE_SUBPOOL_DIR_FULL = 1                " At Most 36 Subroutine Pools Can Be Generated Temporarily
      OTHERS                    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE S005 DISPLAY LIKE 'E' WITH 'At Most 36 Subroutine Pools' 'Can Be Generated Temporarily'.
    LEAVE LIST-PROCESSING..
  ENDIF.

  ASSIGN GT_MAIN_DISP_100->* TO <GT_MAIN_DISP_100>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

  DATA : LV_DISPO TYPE MARC-DISPO.
  DATA : LT_MAIN LIKE TABLE OF GS_MAIN.
  DATA : LS_MAIN LIKE GS_MAIN.
  DATA : LV_INDEX TYPE I.
  DATA : LT_MATNR_RANGE TYPE RANGE OF MATNR.
  DATA : LT_SUM_STOCK LIKE TABLE OF GS_SUM_STOCK.

  REFRESH GT_DEL_AUFNR.

  PERFORM GET_INIT_INFOR.

  PERFORM GET_VBAP. " 판매오더정보 추출

  LV_DISPO = P_SPGCD && '%'.
*  모수대상 추출
  CLEAR: GT_MARC.
  SELECT MATNR, MAABC, EISBE, EISLO FROM MARC
    INTO CORRESPONDING FIELDS OF TABLE @GT_MARC
   WHERE DISPO LIKE @LV_DISPO
     AND WERKS = @P_WERKS
     AND MATNR IN @S_MATNR
     AND LVORM = ''
     AND MMSTA = ''
     AND EISBE <> ''
     AND EISLO <> ''.

  LT_MATNR_RANGE = VALUE #( FOR LW_MARC IN GT_MARC WHERE ( MATNR IS NOT INITIAL )
                                         ( SIGN = 'I' OPTION = 'EQ' LOW = LW_MARC-MATNR ) ).

  IF LT_MATNR_RANGE[] IS NOT INITIAL.
*** 판매계획 조회
**    SELECT A~MATNR, A~VERSB, B~PDATU, B~MEINS, B~PLNMG, B~ENTLI, B~PERXX
**      FROM PBIM AS A
**      INNER JOIN PBED AS B ON B~BDZEI = A~BDZEI
**     WHERE A~MATNR IN @LT_MATNR_RANGE
**       AND A~WERKS = @P_WERKS
**       AND A~VERVS = 'X'
**       AND A~LOEVR = ''
**       AND B~PDATU BETWEEN @S_DATE-LOW AND @GV_END_DT
**      INTO CORRESPONDING FIELDS OF TABLE @GT_PBED.

* 생산계획 조회(계획 오더 + 생산오더)
* 계획오더 조회
    SELECT PLNUM, MATNR, PSTTR, PTEXT, GSMNG, MEINS
      FROM PLAF
      INTO CORRESPONDING FIELDS OF TABLE @GT_PLAF
     WHERE PWWRK = @P_WERKS
        AND MATNR IN @LT_MATNR_RANGE
        AND PSTTR <= @GV_END_DT
        AND PTEXT EQ ' '.

* 생산오더 조회
    SELECT AUFNR, MATNR, GSTRP, GAMNG, GMEIN, REL, PCNF, CNF, PDLV, DLV
         FROM ZGTCVORDSYVAL
        INTO CORRESPONDING FIELDS OF TABLE @GT_AFPO
      WHERE WERKS = @P_WERKS
        AND MATNR IN @LT_MATNR_RANGE
        AND GSTRP BETWEEN @S_DATE-LOW AND @GV_END_DT
        AND DLV = ''
        AND DLFL = ''
        AND LKD = ''
        AND TECO = ''
        AND CLSD = ''.

* 예상재고
    SELECT MATNR, ATWRT, LABST, INSME, MEINS
      FROM ZGTCV_SCR_STOCK
      INTO CORRESPONDING FIELDS OF TABLE @GT_SUM_STOCK
      WHERE WERKS = @P_WERKS
        AND MATNR IN @LT_MATNR_RANGE.

    IF GT_SUM_STOCK[] IS NOT INITIAL.
      PERFORM SET_ATWRT_FR_STOCK.
    ENDIF.

* [소재] 월별 사내 거래 요청
    SELECT * FROM ZGTPPT2160
     WHERE PDWRK = @P_WERKS
       AND MATNR IN @LT_MATNR_RANGE
       AND RQMON BETWEEN @S_DATE-LOW+0(6) AND @GV_END_DT+0(6)
       AND EBELN IS NOT INITIAL
      INTO CORRESPONDING FIELDS OF TABLE @GT_2160.

* 사내이체 수량(계획 기준)
    SELECT * FROM ZGTPPT2161
     WHERE PDWRK = @P_WERKS
       AND MATNR IN @LT_MATNR_RANGE
       AND RQMON BETWEEN @S_DATE-LOW+0(6) AND @GV_END_DT+0(6)
      INTO CORRESPONDING FIELDS OF TABLE @GT_2161.

* 사내이체 수량(수기 생산 기준)
    SELECT C~EINDT, A~EBELN, A~EBELP, A~MATNR, A~CUOBJ, A~MENGE
      FROM EKPO AS A
      INNER JOIN EKKO AS B ON B~EBELN = A~EBELN
      INNER JOIN EKET AS C ON C~EBELN = A~EBELN
                           AND C~EBELP = A~EBELP
     WHERE B~BSART = 'UB'
       AND B~RESWK = @P_WERKS
       AND A~MATNR IN @LT_MATNR_RANGE
       AND A~LOEKZ EQ ' '
       AND C~EINDT BETWEEN @S_DATE-LOW AND @GV_END_DT
      INTO CORRESPONDING FIELDS OF TABLE @GT_EKPO.

    IF GT_EKPO[] IS NOT INITIAL.
      PERFORM SET_ATWRT_FR_EKPO.
    ENDIF.

* 판매계획 조회
    REFRESH GT_SALE_PLAN.
    SELECT MATNR, ATTR01, DLVDATE, VRKME, SUM( QUANTITY_DP ) AS QUANTITY_DP
      FROM ZSDT_D365_021
     WHERE PLTYPE = 'SP' "판매
       AND SPART = '10' "소재
       AND MATNR IN @LT_MATNR_RANGE " 소재대상 자재
       AND DLVDATE BETWEEN @S_DATE-LOW AND @GV_END_DT
       AND VBELN IS INITIAL
       GROUP BY MATNR, ATTR01, DLVDATE, VRKME
      INTO CORRESPONDING FIELDS OF TABLE @GT_SALE_PLAN.

    PERFORM SET_SALES_PLAN.
  ENDIF.

* 재고 현황 + 자재 특성
  SELECT A~MATNR, A~LGORT, A~CHARG, A~LABST, A~INSME, A~SPEME, A~MEINS, A~VBELN, A~LIFNR
    FROM ZGTCV_STOCKVAL AS A
   WHERE A~WERKS = @P_WERKS
     AND A~SPG = @P_SPGCD
     AND A~MATNR IN @LT_MATNR_RANGE
     AND A~MATNR NOT IN ( SELECT MATNR FROM ZGTPPT2151 WHERE WERKS = @P_WERKS )
    INTO TABLE @DATA(LT_STOCKVAL).

  LOOP AT LT_STOCKVAL INTO DATA(LS_STOCKVAL).
    IF LS_STOCKVAL-VBELN IS NOT INITIAL.
      CONTINUE.
    ENDIF.
    IF LS_STOCKVAL-LIFNR IS NOT INITIAL.
      CONTINUE.
    ENDIF.

    CLEAR GS_SUM_STOCK.
    GS_SUM_STOCK-MATNR = LS_STOCKVAL-MATNR.
    GS_SUM_STOCK-LABST = LS_STOCKVAL-LABST.
    GS_SUM_STOCK-INSME = LS_STOCKVAL-INSME.
    GS_SUM_STOCK-MEINS = LS_STOCKVAL-MEINS.
    COLLECT GS_SUM_STOCK INTO LT_SUM_STOCK.
  ENDLOOP.

  IF LT_SUM_STOCK[] IS NOT INITIAL.
    APPEND LINES OF LT_SUM_STOCK TO GT_SUM_STOCK.
  ENDIF.


* 예상재고 수량 SUM(재고 수량은 가용 및 품질 재고만 고려 ZGTCV_SCR_STOCK-LABST + ZGTCV_SCR_STOCK-INSME)
  IF GT_SUM_STOCK[] IS NOT INITIAL.
    LOOP AT GT_SUM_STOCK ASSIGNING FIELD-SYMBOL(<LS_STOCK>).
      <LS_STOCK>-STOCK = <LS_STOCK>-LABST + <LS_STOCK>-INSME.
    ENDLOOP.
  ENDIF.

* 계획오더 정리를 위에 삭제테이블에 옮겨준다.
  IF GT_PLAF[] IS NOT INITIAL.
    LOOP AT GT_PLAF INTO GS_PLAF.
      CLEAR GS_DEL_PLAF.
      GS_DEL_PLAF-PLNUM = GS_PLAF-PLNUM.
      COLLECT GS_DEL_PLAF INTO GT_DEL_PLAF.
    ENDLOOP.
  ENDIF.

* 등급(특성값으로 조회) - 특성값 변경으로 하드코딩으로 구성
*  SELECT A~ATNAM, B~ATWRT
*      FROM CABN AS A
*      INNER JOIN CAWN AS B ON B~ATINN = A~ATINN
*    WHERE A~ATNAM = 'PD_AA_GRADE_TEST'
*      INTO TABLE @DATA(LT_GRADE).
  DATA : BEGIN OF LS_GRADE ,
           ATNAM TYPE CABN-ATNAM,
           ATWRT TYPE CAWN-ATWRT,
         END OF LS_GRADE.
  DATA : LT_GRADE LIKE TABLE OF LS_GRADE.

  DEFINE __SET_ATWRT.
    CLEAR ls_grade.
    ls_grade-atnam = &1.
    ls_grade-atwrt = &2.
    APPEND ls_grade TO lt_grade.
  END-OF-DEFINITION.

  __SET_ATWRT : 'Grade 1' 'G1',
                'Grade 2' 'G2',
                'Grade 3' 'G3',
                'Grade 4' 'G4'.

* 높은 등급순으로 정렬후 2개 등급만 추출
  SORT LT_GRADE BY ATWRT DESCENDING.

* 신선 사급 이동자재
  SELECT * FROM ZGTPPT2153
    INTO TABLE GT_2153
   WHERE WERKS = P_WERKS
     AND MATNR IN LT_MATNR_RANGE
     AND RQDAY BETWEEN S_DATE-LOW AND GV_END_DT.


  REFRESH GT_MAIN.
  FREE GT_MAIN.

  SORT GT_2151 BY MATNR.

  LOOP AT LT_MATNR_RANGE INTO DATA(LS_MATNR).
    CLEAR LS_MAIN.
*   자재별 정렬순서 세팅
    READ TABLE GT_MARC INTO DATA(LS_MARC) WITH KEY MATNR = LS_MATNR-LOW.
    CASE LS_MARC-MAABC.
      WHEN 'A'.
        LS_MAIN-SEQ_MATNR = 1.
      WHEN 'B'.
        LS_MAIN-SEQ_MATNR = 2.
      WHEN 'C'.
        LS_MAIN-SEQ_MATNR = 3.
      WHEN OTHERS.
        LS_MAIN-SEQ_MATNR = 99.
    ENDCASE.

    LS_MAIN-MATNR = LS_MATNR-LOW.
    LS_MAIN-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_MAIN-MATNR ).
    LS_MAIN-MEINS = 'KG'.

    READ TABLE GT_2151 TRANSPORTING NO FIELDS WITH KEY MATNR = LS_MATNR-LOW BINARY SEARCH.
    IF SY-SUBRC EQ 0. " 등급관리 테이블 등급 적용.
      CLEAR LV_INDEX.
      LOOP AT LT_GRADE INTO LS_GRADE.
        LV_INDEX = SY-TABIX.
        LS_MAIN-SEQ_MAIN = 5.
        LS_MAIN-SEQ_ATWRT = LV_INDEX.
        LS_MAIN-ATWRT = LS_GRADE-ATWRT.

        APPEND LS_MAIN TO GT_MAIN.
        CONTINUE.

** 판매계획 존재
*        READ TABLE GT_PBED INTO GS_PBED WITH KEY MATNR = LS_MAIN-MATNR
*                                                                       VERSB = LS_MAIN-ATWRT.
*
*        IF SY-SUBRC EQ 0.
*          APPEND LS_MAIN TO GT_MAIN.
*          CONTINUE.
*        ENDIF.
*
** 재고 조회
*        READ TABLE GT_SUM_STOCK INTO GS_SUM_STOCK WITH KEY MATNR = LS_MAIN-MATNR
*                                                                                           ATWRT = LS_MAIN-ATWRT.
*        IF SY-SUBRC EQ 0.
*          APPEND LS_MAIN TO GT_MAIN.
*          CONTINUE.
*        ENDIF.
** 판매오더 조회
*        READ TABLE GT_VBAP INTO GS_VBAP WITH KEY MATNR = LS_MAIN-MATNR
*                                                                        ATWRT = LS_MAIN-ATWRT.
*        IF SY-SUBRC EQ 0.
*          APPEND LS_MAIN TO GT_MAIN.
*          CONTINUE.
*        ENDIF.
**사내이체건 조회
*        LOOP AT GT_2160 INTO DATA(LS_2160) WHERE MATNR = LS_MAIN-MATNR
*                                                                 AND SCRGRADE = LS_MAIN-ATWRT.
*          IF LS_2160-EBELN IS NOT INITIAL.
*            APPEND LS_MAIN TO GT_MAIN.
*            EXIT.
*          ENDIF.
*        ENDLOOP.

      ENDLOOP.
      LS_MAIN-SEQ_MAIN = 5.
      LS_MAIN-SEQ_ATWRT = 0.
      CLEAR LS_MAIN-ATWRT.

      APPEND LS_MAIN TO GT_MAIN.


    ELSE.
      LS_MAIN-SEQ_MAIN = 9.
      LS_MAIN-SEQ_ATWRT = 9.
      LS_MAIN-ATWRT = ''.
      APPEND LS_MAIN TO GT_MAIN.
    ENDIF.
  ENDLOOP.

  LOOP AT GT_VBAP INTO DATA(LS_VBAP).
    READ TABLE GT_2151 TRANSPORTING NO FIELDS WITH KEY MATNR = LS_VBAP-MATNR BINARY SEARCH.
    IF SY-SUBRC EQ 0. " 등급관리 테이블 등급 적용.
      DATA(LV_TABIX) = SY-TABIX.
      READ TABLE LT_GRADE TRANSPORTING NO FIELDS WITH KEY ATWRT = LS_VBAP-ATWRT.
      IF SY-SUBRC NE 0.
        DELETE GT_VBAP INDEX LV_TABIX.
      ENDIF.
    ENDIF.
  ENDLOOP.

  PERFORM MAKE_MAINTAIN_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_MAINTAIN_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_MAINTAIN_DATA .

  DATA : LV_WEEK TYPE SCAL-WEEK.
  DATA : LV_CAL_STOCK TYPE ZGTCV_SCR_STOCK-LABST.
  DATA : LV_CAL_PSAMG TYPE CO_PSAMG.
  DATA : LV_PLUS_STOCK TYPE ZGTCV_SCR_STOCK-LABST.
  DATA : LV_MINUS_STOCK TYPE ZGTCV_SCR_STOCK-LABST.
  DATA : LV_CHK_LOOP.
  DATA : LV_ATWRT LIKE GS_MAIN-ATWRT.
  DATA : LT_2161 TYPE TABLE OF ZGTPPT2161.
  DATA : LT_2160 TYPE TABLE OF ZGTPPT2160.
  DATA : LV_CHK_USE.

  REFRESH     GT_MAINTAIN_MAIN.
  REFRESH     GT_MATNR_MAIN.
  FREE GT_MAINTAIN_MAIN.
  FREE GT_MATNR_MAIN.

  SORT GT_DATE BY DATE.
  SORT GT_WEEK BY WEEK.
  SORT GT_MAIN BY MATNR SEQ_ATWRT.
  SORT GT_PBED BY MATNR VERSB ENTLI PDATU PERXX.
  SORT GT_SALE_PLAN BY MATNR ATTR01 DLVDATE.
  SORT GT_PLAF BY MATNR PTEXT PSTTR.
  SORT GT_AFPO BY MATNR ATWRT GSTRP.
*  SORT GT_CATALOG BY SEQ_CATALOG.
  SORT GT_SUM_STOCK BY MATNR ATWRT.
  SORT GT_VBAP BY MATNR ATWRT EDATU.
  SORT GT_2153 BY MATNR SCRGRADE RQDAY.

  LOOP AT GT_MAIN INTO GS_MAIN.
    CLEAR GS_MAINTAIN_MAIN.
    MOVE-CORRESPONDING GS_MAIN TO GS_MAINTAIN_MAIN.
    CLEAR LV_ATWRT.
    LV_ATWRT = GS_MAIN-ATWRT.
    IF GS_MAIN-ATWRT = SPACE.
      LV_ATWRT = '00'.
    ENDIF.
    REFRESH GT_MATAIN_CAT.
    FREE GT_MATAIN_CAT.

    IF GS_MAIN-SEQ_ATWRT = 0.
      APPEND GS_MAINTAIN_MAIN TO GT_MAINTAIN_MAIN.
      CONTINUE.
    ENDIF.

    " *----------------------------------------------------------------*
    IF S_DATE-LOW < SY-DATUM.
      REFRESH LT_2160.
      LT_2160 = VALUE #( FOR LW_2160 IN GT_2160 WHERE ( MATNR = GS_MAIN-MATNR
                                                        AND  SCRGRADE = GS_MAIN-ATWRT
                                                        AND  EBELN IS NOT INITIAL )
                                ( CORRESPONDING #( LW_2160 ) ) ).

      IF LT_2160 IS NOT INITIAL.
        SELECT B~BUDAT_MKPF,
               SUM( CASE B~BWART WHEN '351' THEN B~MENGE
                                 WHEN '352' THEN B~MENGE * -1
                    END ) AS MENGE
          FROM @LT_2160 AS A INNER JOIN MSEG AS B ON B~EBELN = A~EBELN
                                                  AND B~EBELP = A~EBELP
         WHERE B~BWART IN ( '351', '352' )
           AND B~BUDAT_MKPF BETWEEN @S_DATE-LOW AND @GV_END_DT
         GROUP BY BUDAT_MKPF
          INTO TABLE @DATA(LT_CHK_MENGE).
      ENDIF.

    ENDIF.

    " *----------------------------------------------------------------*
* 구분별 테이블 어팬드
    LOOP AT GT_CATALOG INTO GS_CATALOG.
      CASE GS_CATALOG-SEQ_CATALOG.
        WHEN 11 OR 12.
          IF GS_MAIN-SEQ_ATWRT EQ 1 OR GS_MAIN-SEQ_ATWRT EQ 9.
            IF GS_MAIN-ATWRT = 'G4'.
              CONCATENATE GS_CATALOG-CATALOG '(G4)' INTO GS_CATALOG-CATALOG.
            ENDIF.
          ELSE.
            CONTINUE.
          ENDIF.

      ENDCASE.

      CLEAR GS_MATAIN_CAT.
      MOVE-CORRESPONDING GS_CATALOG TO GS_MATAIN_CAT.

      " *--------------------------------------------------------------*
*    초기정보 데일리 세팅
      LOOP AT GT_DATE INTO GS_DATE.
        CLEAR GS_DIFINE_DAY.
        CASE GS_CATALOG-SEQ_CATALOG.
          WHEN 1. " 판매계획
* 해당일자 판매계획 조회
***            READ TABLE GT_PBED INTO GS_PBED WITH KEY MATNR = GS_MAIN-MATNR
***                                                                      VERSB = LV_ATWRT
***                                                                      ENTLI = '1' " 일자먼저 조회
***                                                                      PDATU = GS_DATE-DATE.
***            IF SY-SUBRC EQ 0.
***              GS_DIFINE_DAY-DATE = GS_DATE-DATE.
***              GS_DIFINE_DAY-PSAMG = GS_PBED-PLNMG.
***              APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.
***            ELSE. "
**** 일자별 판매계획 미존재시 주차별 계획 조회하여 해당 날자에만 입력
***              READ TABLE GT_PBED INTO GS_PBED WITH KEY MATNR = GS_MAIN-MATNR
***                                                                              VERSB = GS_MAIN-ATWRT
***                                                                              ENTLI = '2' " 주차 조회
***                                                                              PDATU = GS_DATE-DATE.
***              IF SY-SUBRC EQ 0.
***                GS_DIFINE_DAY-DATE = GS_DATE-DATE.
***                GS_DIFINE_DAY-PSAMG = GS_PBED-PLNMG.
***                APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.
***              ENDIF.
***            ENDIF.
            READ TABLE GT_SALE_PLAN INTO GS_SALE_PLAN WITH KEY MATNR = GS_MAIN-MATNR
                                                               ATTR01 = GS_MAIN-ATWRT
                                                               DLVDATE = GS_DATE-DATE.
            IF SY-SUBRC EQ 0.
              GS_DIFINE_DAY-DATE = GS_DATE-DATE.
              GS_DIFINE_DAY-PSAMG = GS_SALE_PLAN-QUANTITY_DP.
              APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.
            ENDIF.

          WHEN 3.  " 사내이체
            CLEAR LV_CHK_USE.
**            LOOP AT GT_2160 INTO DATA(LS_2160) WHERE MATNR = GS_MAIN-MATNR
**                                                 AND SCRGRADE = GS_MAIN-ATWRT
**                                                 AND RQMON = GS_DATE-DATE+0(6).
**              IF LS_2160-EBELN IS NOT INITIAL.
**                LV_CHK_USE = ABAP_TRUE.
            IF GS_DATE-DATE < SY-DATUM.
              READ TABLE LT_CHK_MENGE INTO DATA(LS_CHK_MENGE) WITH KEY BUDAT_MKPF = GS_DATE-DATE.
              IF SY-SUBRC EQ 0.
                GS_DIFINE_DAY-PSAMG = LS_CHK_MENGE-MENGE.
                GS_DIFINE_DAY-DATE = GS_DATE-DATE.
                APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.
              ENDIF.
            ELSE.

              REFRESH LT_2161.
              LT_2161 = VALUE #( FOR LW_2161 IN GT_2161 WHERE ( MATNR = GS_MAIN-MATNR
                                                                           AND  SCRGRADE = GS_MAIN-ATWRT
                                                                           AND  RQDAY = GS_DATE-DATE )
**                                                                             AND  ZSEQ  = LS_2160-ZSEQ )
                                        ( CORRESPONDING #( LW_2161 ) ) ).
              IF LT_2161[] IS NOT INITIAL.
                LOOP AT LT_2161 INTO DATA(LS_2161).
                  LV_CHK_USE = ABAP_TRUE.
                  ADD LS_2161-RQMNG TO GS_DIFINE_DAY-PSAMG.
                ENDLOOP.
              ENDIF.

**              LOOP AT GT_EKPO INTO GS_EKPO WHERE MATNR = GS_MAIN-MATNR
**                                                      AND ATWRT = GS_MAIN-ATWRT
**                                                      AND EINDT = GS_DATE-DATE.
**                LV_CHK_USE = ABAP_TRUE.
**                ADD GS_EKPO-MENGE TO GS_DIFINE_DAY-PSAMG.
**              ENDLOOP.

              IF LV_CHK_USE = ABAP_TRUE.
                GS_DIFINE_DAY-DATE = GS_DATE-DATE.
                APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.
              ENDIF.
            ENDIF.

          WHEN 2.  " 판매오더
            CLEAR LV_CHK_LOOP.
            LOOP AT GT_VBAP INTO GS_VBAP WHERE MATNR = GS_MAIN-MATNR
                                           AND ATWRT = GS_MAIN-ATWRT
                                           AND EDATU = GS_DATE-DATE.

              LV_CHK_LOOP = ABAP_TRUE.
              GS_DIFINE_DAY-DATE = GS_DATE-DATE.
              GS_DIFINE_DAY-PSAMG = GS_DIFINE_DAY-PSAMG + GS_VBAP-KWMENG.
            ENDLOOP.
            IF LV_CHK_LOOP = ABAP_TRUE.
              APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.
            ENDIF.

          WHEN 4.  " 생산계획
* 해당일자 생산오더 조회
            CLEAR LV_CHK_LOOP.
            LOOP AT GT_AFPO INTO GS_AFPO WHERE MATNR = GS_MAIN-MATNR
                                           AND GSTRP = GS_DATE-DATE.
              LV_CHK_LOOP = ABAP_TRUE.
* 해당일자 여러 생산오더 존재 가능,
* 1. 기본적으로 최초 생선된 오더 기준으로 보여준다.
* 2. 릴리즈된 오더 존재시 릴리즈된 오더로 보여준다. 이것도 최초로 나오는 오더 기준
              IF GS_DIFINE_DAY IS INITIAL.
                GS_DIFINE_DAY-DATE = GS_DATE-DATE.
                GS_DIFINE_DAY-AUFNR = GS_AFPO-AUFNR.
              ENDIF.

              ADD GS_AFPO-GAMNG TO GS_DIFINE_DAY-PSAMG.

              IF GS_AFPO-REL IS NOT INITIAL AND GS_DIFINE_DAY-ORDER_STAT IS INITIAL. " 릴리즈 상태시 R로 마킹
                GS_DIFINE_DAY-AUFNR = GS_AFPO-AUFNR.
                GS_DIFINE_DAY-ORDER_STAT = 'R'.
              ENDIF.
            ENDLOOP.

            IF LV_CHK_LOOP = ABAP_TRUE.
              APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.
            ELSE.
* 일자별 생성계획 조회시 생성오더 미존재 계획 오더만 존재시 해당 날짜에만 보여준다.
              READ TABLE GT_PLAF INTO GS_PLAF WITH KEY MATNR = GS_MAIN-MATNR
                                                       PTEXT = GS_MAIN-ATWRT
                                                       PSTTR = GS_DATE-DATE. " 계획오더 조회시 주의 첫날짜로 조회
              IF SY-SUBRC EQ 0.
                GS_DIFINE_DAY-DATE = GS_DATE-DATE.
                GS_DIFINE_DAY-PSAMG = GS_PLAF-GSMNG.
                GS_DIFINE_DAY-PLNUM = GS_PLAF-PLNUM. " 변경되었을 경우에만 삭제
                APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.
              ENDIF.
            ENDIF.

          WHEN 99.  " 예상재고 라인만 생성
            IF GS_DATE-DATE < SY-DATUM.
              CONTINUE.
            ENDIF.

            CLEAR GS_DIFINE_DAY.
            GS_DIFINE_DAY-DATE = GS_DATE-DATE.
            APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.

          WHEN 11.  " 사급재고
            READ TABLE GT_2153 INTO DATA(LS_2153) WITH KEY MATNR = GS_MAIN-MATNR
                                                           SCRGRADE = GS_MAIN-ATWRT
                                                           RQDAY = GS_DATE-DATE.
            IF SY-SUBRC EQ 0 AND LS_2153-CONTMNG NE 0.
              CLEAR GS_DIFINE_DAY.
              GS_DIFINE_DAY-DATE = GS_DATE-DATE.
              GS_DIFINE_DAY-PSAMG = LS_2153-CONTMNG .
              APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.
            ENDIF.

          WHEN 12.  " 신선재고
            READ TABLE GT_2153 INTO LS_2153 WITH KEY MATNR = GS_MAIN-MATNR
                                                     SCRGRADE = GS_MAIN-ATWRT
                                                     RQDAY = GS_DATE-DATE.
            IF SY-SUBRC EQ 0 AND LS_2153-MOVEMNG NE 0.
              CLEAR GS_DIFINE_DAY.
              GS_DIFINE_DAY-DATE = GS_DATE-DATE.
              GS_DIFINE_DAY-PSAMG = LS_2153-MOVEMNG .
              APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.
            ENDIF.

          WHEN 60.  " 마이너스 수량
            IF GS_DATE-DATE < SY-DATUM.
              CONTINUE.
            ENDIF.

            CLEAR : LV_PLUS_STOCK, LV_MINUS_STOCK.
* 해당 날짜의 + 재고 조회 (생산계획)
            READ TABLE GT_MATAIN_CAT INTO DATA(LS_TEMP_CAT) WITH KEY SEQ_CATALOG = 4.
            IF SY-SUBRC EQ 0.
              READ TABLE LS_TEMP_CAT-T_DAY INTO DATA(LS_DAY) WITH KEY DATE = GS_DATE-DATE.
              IF SY-SUBRC EQ 0.
                LV_PLUS_STOCK =  LS_DAY-PSAMG.
              ENDIF.
            ENDIF.
* 해당 날짜의 - 재고 조회 (판매오더, 사내이체)
*           사내이체
            READ TABLE GT_MATAIN_CAT INTO LS_TEMP_CAT WITH KEY SEQ_CATALOG = 2.
            IF SY-SUBRC EQ 0.
              READ TABLE LS_TEMP_CAT-T_DAY INTO LS_DAY WITH KEY DATE = GS_DATE-DATE.
              IF SY-SUBRC EQ 0.
                ADD LS_DAY-PSAMG TO LV_MINUS_STOCK.
              ENDIF.
            ENDIF.
*           판매오더
            READ TABLE GT_MATAIN_CAT INTO LS_TEMP_CAT WITH KEY SEQ_CATALOG = 3.
            IF SY-SUBRC EQ 0.
              READ TABLE LS_TEMP_CAT-T_DAY INTO LS_DAY WITH KEY DATE = GS_DATE-DATE.
              IF SY-SUBRC EQ 0.
                ADD LS_DAY-PSAMG TO LV_MINUS_STOCK.
              ENDIF.
            ENDIF.

*          사급자재
            READ TABLE GT_MATAIN_CAT INTO LS_TEMP_CAT WITH KEY SEQ_CATALOG = 11.
            IF SY-SUBRC EQ 0.
              READ TABLE LS_TEMP_CAT-T_DAY INTO LS_DAY WITH KEY DATE = GS_DATE-DATE.
              IF SY-SUBRC EQ 0.
                ADD LS_DAY-PSAMG TO LV_MINUS_STOCK.
              ENDIF.
            ENDIF.

*           신선자재
            READ TABLE GT_MATAIN_CAT INTO LS_TEMP_CAT WITH KEY SEQ_CATALOG = 12.
            IF SY-SUBRC EQ 0.
              READ TABLE LS_TEMP_CAT-T_DAY INTO LS_DAY WITH KEY DATE = GS_DATE-DATE.
              IF SY-SUBRC EQ 0.
                ADD LS_DAY-PSAMG TO LV_MINUS_STOCK.
              ENDIF.
            ENDIF.


*          재고 계산
            GS_DIFINE_DAY-DATE = GS_DATE-DATE.
            GS_DIFINE_DAY-PSAMG = LV_PLUS_STOCK - LV_MINUS_STOCK.

            APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.
        ENDCASE.
      ENDLOOP.

      " *--------------------------------------------------------------*
*    주간 세팅
      LOOP AT GT_WEEK INTO GS_WEEK.
        CLEAR GS_DIFINE_WEEK.
        CASE GS_CATALOG-SEQ_CATALOG.
          WHEN 1. " 판매계획
* 해당일자 판매계획 조회
            LOOP AT  GT_SALE_PLAN INTO GS_SALE_PLAN WHERE MATNR = GS_MAIN-MATNR
                                                      AND ATTR01 = GS_MAIN-ATWRT
                                                      AND DLVDATE BETWEEN  GS_WEEK-FRDATE AND GS_WEEK-TODATE.

              ADD GS_SALE_PLAN-QUANTITY_DP TO GS_DIFINE_WEEK-GSMNG.
            ENDLOOP.

            IF GS_DIFINE_WEEK-GSMNG NE 0.
              GS_DIFINE_WEEK-WEEK = GS_WEEK-WEEK.
              APPEND GS_DIFINE_WEEK TO GS_MATAIN_CAT-T_WEEK.
            ENDIF.


*            READ TABLE GT_PBED INTO GS_PBED WITH KEY MATNR = GS_MAIN-MATNR
*                                                                              VERSB = LV_ATWRT
*                                                                              ENTLI = '2' " 주차 조회
*                                                                              PERXX = GS_WEEK-WEEK.
*            IF SY-SUBRC EQ 0. " 주차별 조회시 계획량 / 7
*              GS_DIFINE_WEEK-WEEK = GS_WEEK-WEEK.
*              GS_DIFINE_WEEK-GSMNG = GS_PBED-PLNMG.
*              APPEND GS_DIFINE_WEEK TO GS_MATAIN_CAT-T_WEEK.
*            ENDIF.

          WHEN 3.  " 사내이체

            CLEAR LV_CHK_USE.
**            LOOP AT GT_2160 INTO LS_2160 WHERE MATNR = GS_MAIN-MATNR
**                                                                    AND SCRGRADE = GS_MAIN-ATWRT
**                                                                    AND RQMON BETWEEN GS_WEEK-FRDATE+0(6) AND GS_WEEK-TODATE+0(6).
**              IF LS_2160-EBELN IS NOT INITIAL.
            LV_CHK_USE = ABAP_TRUE.
            REFRESH LT_2161.
            LT_2161 = VALUE #( FOR LW_2161 IN GT_2161 WHERE ( MATNR = GS_MAIN-MATNR
                                                                         AND  SCRGRADE = GS_MAIN-ATWRT
**                                                                             AND  RQMON = LS_2160-RQMON
                                                                         AND  RQDAY BETWEEN GS_WEEK-FRDATE AND GS_WEEK-TODATE )
**                                                                             AND  ZSEQ  = LS_2160-ZSEQ )
                                      ( CORRESPONDING #( LW_2161 ) ) ).
            IF LT_2161[] IS NOT INITIAL.
              LOOP AT LT_2161 INTO LS_2161.
                CLEAR LV_CHK_USE.
                ADD LS_2161-RQMNG TO GS_DIFINE_WEEK-GSMNG.
              ENDLOOP.
            ENDIF.

**            LOOP AT GT_EKPO INTO GS_EKPO WHERE MATNR = GS_MAIN-MATNR
**                                                    AND ATWRT = GS_MAIN-ATWRT
**                                                    AND EINDT BETWEEN GS_WEEK-FRDATE AND GS_WEEK-TODATE.
**              CLEAR LV_CHK_USE.
**              ADD GS_EKPO-MENGE TO GS_DIFINE_WEEK-GSMNG.
**            ENDLOOP.


            IF LV_CHK_USE IS INITIAL.
              GS_DIFINE_WEEK-WEEK = GS_WEEK-WEEK.
              APPEND GS_DIFINE_WEEK TO GS_MATAIN_CAT-T_WEEK.
            ENDIF.

          WHEN 2.  " 판매오더
            CLEAR LV_CHK_LOOP.
            LOOP AT GT_VBAP INTO GS_VBAP WHERE MATNR = GS_MAIN-MATNR
                                           AND ATWRT = GS_MAIN-ATWRT
                                           AND EDATU BETWEEN GS_WEEK-FRDATE AND GS_WEEK-TODATE..

              LV_CHK_LOOP = ABAP_TRUE.
              GS_DIFINE_WEEK-WEEK = GS_WEEK-WEEK.
              GS_DIFINE_WEEK-GSMNG = GS_DIFINE_WEEK-GSMNG + GS_VBAP-KWMENG.
            ENDLOOP.

            IF LV_CHK_LOOP = ABAP_TRUE.
              GS_DIFINE_WEEK-WEEK = GS_WEEK-WEEK.
              APPEND GS_DIFINE_WEEK TO GS_MATAIN_CAT-T_WEEK.
            ENDIF.

          WHEN 4.  " 생산계획
            READ TABLE GT_PLAF INTO GS_PLAF WITH KEY MATNR = GS_MAIN-MATNR
                                                     PTEXT = GS_MAIN-ATWRT
                                                     PSTTR = GS_WEEK-FRDATE. " 계획오더 조회시 주의 첫날짜로 조회
            IF SY-SUBRC EQ 0. " 주차별 조회시 계획량 / 7
              GS_DIFINE_WEEK-WEEK = GS_WEEK-WEEK.
              GS_DIFINE_WEEK-GSMNG = GS_PLAF-GSMNG.
              GS_DIFINE_WEEK-PLNUM = GS_PLAF-PLNUM.
              APPEND GS_DIFINE_WEEK TO GS_MATAIN_CAT-T_WEEK.
              DELETE GT_DEL_PLAF WHERE PLNUM = GS_PLAF-PLNUM.

            ENDIF.

          WHEN 99.  " 예상재고 - 라인만 생성
*          재고 계산
            GS_DIFINE_WEEK-WEEK = GS_WEEK-WEEK.

            APPEND GS_DIFINE_WEEK TO GS_MATAIN_CAT-T_WEEK.

          WHEN 11.  " 사급재고
            READ TABLE GT_2153 INTO LS_2153 WITH KEY MATNR = GS_MAIN-MATNR
                                                     SCRGRADE = GS_MAIN-ATWRT
                                                     RQDAY = GS_WEEK-FRDATE.
            IF SY-SUBRC EQ 0 AND LS_2153-CONTMNG NE 0.
              CLEAR GS_DIFINE_WEEK.
              GS_DIFINE_WEEK-WEEK = GS_WEEK-WEEK.
              GS_DIFINE_WEEK-GSMNG = LS_2153-CONTMNG .
              APPEND GS_DIFINE_WEEK TO GS_MATAIN_CAT-T_WEEK.
            ENDIF.

          WHEN 12.  " 신선재고
            READ TABLE GT_2153 INTO LS_2153 WITH KEY MATNR = GS_MAIN-MATNR
                                                     SCRGRADE = GS_MAIN-ATWRT
                                                     RQDAY = GS_WEEK-FRDATE.
            IF SY-SUBRC EQ 0 AND LS_2153-MOVEMNG NE 0.
              CLEAR GS_DIFINE_WEEK.
              GS_DIFINE_WEEK-WEEK = GS_WEEK-WEEK.
              GS_DIFINE_WEEK-GSMNG = LS_2153-MOVEMNG .
              APPEND GS_DIFINE_WEEK TO GS_MATAIN_CAT-T_WEEK.
            ENDIF.

          WHEN 60.  " 마이너스 수량
            CLEAR : LV_PLUS_STOCK, LV_MINUS_STOCK.
* 해당 날짜의 + 재고 조회 (생산계획)
*            READ TABLE GT_MATAIN_CAT INTO LS_TEMP_CAT WITH KEY SEQ_CATALOG = 4.
*            IF SY-SUBRC EQ 0.
*              READ TABLE LS_TEMP_CAT-T_WEEK INTO DATA(LS_WEEK) WITH KEY WEEK = GS_WEEK-WEEK.
*              IF SY-SUBRC EQ 0.
*                LV_PLUS_STOCK =  LS_WEEK-GSMNG.
*              ENDIF.
*            ENDIF.
* 해당 날짜의 - 재고 조회 (판매오더, 사내이체)
*           사내이체
            READ TABLE GT_MATAIN_CAT INTO LS_TEMP_CAT WITH KEY SEQ_CATALOG = 3.
            IF SY-SUBRC EQ 0.
              READ TABLE LS_TEMP_CAT-T_WEEK INTO DATA(LS_WEEK) WITH KEY WEEK = GS_WEEK-WEEK.
              IF SY-SUBRC EQ 0.
                ADD LS_WEEK-GSMNG TO LV_MINUS_STOCK.
              ENDIF.
            ENDIF.
*           판매오더
            READ TABLE GT_MATAIN_CAT INTO LS_TEMP_CAT WITH KEY SEQ_CATALOG = 2.
            IF SY-SUBRC EQ 0.
              READ TABLE LS_TEMP_CAT-T_WEEK INTO LS_WEEK WITH KEY WEEK = GS_WEEK-WEEK.
              IF SY-SUBRC EQ 0.
                ADD LS_WEEK-GSMNG TO LV_MINUS_STOCK.
              ENDIF.
            ENDIF.
*           사급자재
            READ TABLE GT_MATAIN_CAT INTO LS_TEMP_CAT WITH KEY SEQ_CATALOG = 11.
            IF SY-SUBRC EQ 0.
              READ TABLE LS_TEMP_CAT-T_WEEK INTO LS_WEEK WITH KEY WEEK = GS_WEEK-WEEK.
              IF SY-SUBRC EQ 0.
                ADD LS_WEEK-GSMNG TO LV_MINUS_STOCK.
              ENDIF.
            ENDIF.
*           신선자재
            READ TABLE GT_MATAIN_CAT INTO LS_TEMP_CAT WITH KEY SEQ_CATALOG = 12.
            IF SY-SUBRC EQ 0.
              READ TABLE LS_TEMP_CAT-T_WEEK INTO LS_WEEK WITH KEY WEEK = GS_WEEK-WEEK.
              IF SY-SUBRC EQ 0.
                ADD LS_WEEK-GSMNG TO LV_MINUS_STOCK.
              ENDIF.
            ENDIF.
*          재고 계산
            GS_DIFINE_WEEK-WEEK = GS_WEEK-WEEK.
            GS_DIFINE_WEEK-GSMNG = LV_PLUS_STOCK - LV_MINUS_STOCK.

            APPEND GS_DIFINE_WEEK TO GS_MATAIN_CAT-T_WEEK.

        ENDCASE.
      ENDLOOP.

      " *--------------------------------------------------------------*
      LOOP AT GT_SPMON INTO GS_SPMON.
        CLEAR GS_DIFINE_SPMON.
        CLEAR LV_CAL_PSAMG.
        CASE GS_CATALOG-SEQ_CATALOG.
          WHEN 1 OR 2 OR 3 OR 11 OR 12.
            LOOP AT GS_MATAIN_CAT-T_DAY INTO GS_DIFINE_DAY WHERE DATE+0(6) = GS_SPMON-SPMON.
              ADD GS_DIFINE_DAY-PSAMG TO LV_CAL_PSAMG.
            ENDLOOP.

            LOOP AT GT_WEEK INTO GS_WEEK WHERE FRDATE+0(6) = GS_SPMON-SPMON.
              READ TABLE GS_MATAIN_CAT-T_WEEK INTO GS_DIFINE_WEEK WITH KEY WEEK = GS_WEEK-WEEK.
              IF SY-SUBRC EQ 0.
                ADD GS_DIFINE_WEEK-GSMNG TO LV_CAL_PSAMG.
              ENDIF.
            ENDLOOP.

            IF LV_CAL_PSAMG NE 0.
              GS_DIFINE_SPMON-SPMON = GS_SPMON-SPMON.
              GS_DIFINE_SPMON-GSMNG = LV_CAL_PSAMG.
              APPEND GS_DIFINE_SPMON TO GS_MATAIN_CAT-T_SPMON.
            ENDIF.

        ENDCASE.
      ENDLOOP.

      " *--------------------------------------------------------------*
      CASE GS_MAINTAIN_MAIN-SEQ_ATWRT.
        WHEN 9 OR 1 OR 2.
          APPEND GS_MATAIN_CAT TO GT_MATAIN_CAT.
        WHEN 3 OR 4. " 하위 등급은 생산계획과 판매계획 존재 안함
          CASE GS_MATAIN_CAT-SEQ_CATALOG.
            WHEN  4.
            WHEN OTHERS.
              APPEND GS_MATAIN_CAT TO GT_MATAIN_CAT.
          ENDCASE.
      ENDCASE.

    ENDLOOP.

    MOVE-CORRESPONDING GT_MATAIN_CAT TO GS_MAINTAIN_MAIN-T_CAT .

    APPEND GS_MAINTAIN_MAIN TO GT_MAINTAIN_MAIN.
  ENDLOOP.

*

  PERFORM SET_MATNR_HEADER.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_WEEK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DATE_DATE
*&      <-- LV_WEEK
*&---------------------------------------------------------------------*
FORM GET_WEEK  USING    PV_DATE TYPE SY-DATUM
               CHANGING PV_WEEK.

  CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
    EXPORTING
      DATE = PV_DATE
    IMPORTING
      WEEK = PV_WEEK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DISP_TABLE .

  DATA : LO_WA TYPE REF TO DATA.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_NUM_C(2) TYPE C.
  DATA : LV_PSAMG TYPE CO_PSAMG.

  FIELD-SYMBOLS : <LS_MAIN> TYPE ANY.
  FIELD-SYMBOLS : <LV_VALUE> TYPE ANY.

  CREATE DATA LO_WA LIKE LINE OF <GT_MAIN_DISP_100>.
  ASSIGN LO_WA->* TO <LS_MAIN>.

  REFRESH <GT_MAIN_DISP_100>.


* 달력 추가(첫번째라인)
*&---------------------------------------------------------------------*
  CLEAR <LS_MAIN>.
* 라인 정렬을 위한 seq 필드
  IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
  ASSIGN COMPONENT 'SEQ_MAIN' OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
  IF <LV_VALUE> IS ASSIGNED.
    <LV_VALUE> = 0.
  ENDIF.

* 설비 가동 시간 text
  IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
  ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
  IF <LV_VALUE> IS ASSIGNED.
    <LV_VALUE> = '요일'.
  ENDIF.

  LOOP AT GT_DATE INTO GS_DATE.
    READ TABLE GT_DAY_ATTR INTO DATA(LS_DAY_ATTR) WITH KEY DATE = GS_DATE-DATE.
    IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
    ASSIGN COMPONENT GS_DATE-FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
    IF <LV_VALUE> IS ASSIGNED.
      <LV_VALUE> = LS_DAY_ATTR-WEEKDAY_L.
    ENDIF.
  ENDLOOP.
  APPEND <LS_MAIN> TO <GT_MAIN_DISP_100>.
*&---------------------------------------------------------------------*

* 설비 가동시간 세팅(두번째라인)
*&---------------------------------------------------------------------*
  CLEAR <LS_MAIN>.
* 라인 정렬을 위한 seq 필드
  IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
  ASSIGN COMPONENT 'SEQ_MAIN' OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
  IF <LV_VALUE> IS ASSIGNED.
    <LV_VALUE> = 1.
  ENDIF.

* 설비 가동 시간 text
  IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
  ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
  IF <LV_VALUE> IS ASSIGNED.
    <LV_VALUE> = '설비 가동 시간'.
  ENDIF.

* 일자별 가동시간 세팅
  LOOP AT GT_DATE INTO GS_DATE.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = GS_DATE-DATE.
    IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
    IF <LV_VALUE> IS ASSIGNED.
      READ TABLE GT_2150 INTO DATA(LS_2150) WITH KEY PLDAT = GS_DATE-DATE.
      IF SY-SUBRC EQ 0.
        CLEAR LV_NUM_C.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = LS_2150-OPRTIM
          IMPORTING
            OUTPUT = LV_NUM_C.
        <LV_VALUE> = LV_NUM_C.
        CONDENSE <LV_VALUE>.
      ELSE.
        READ TABLE GT_DAY_ATTR INTO DATA(LS_CHK_DATE) WITH KEY DATE = GS_DATE-DATE.
        IF SY-SUBRC EQ 0 AND ( LS_CHK_DATE-WEEKDAY = 6 OR LS_CHK_DATE-WEEKDAY = 7 ).
          <LV_VALUE> = '0'.
        ELSE.
          <LV_VALUE> = '24'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

* 주차별 가동시간 세팅(24로 세팅)
  LOOP AT GT_WEEK INTO GS_WEEK.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = GS_WEEK-WEEK.
    IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
    IF <LV_VALUE> IS ASSIGNED.
      <LV_VALUE> = '24'.
    ENDIF.
  ENDLOOP..

  APPEND <LS_MAIN> TO <GT_MAIN_DISP_100>.
*&---------------------------------------------------------------------*

* 2라인이후 데이터 세팅
  LOOP AT GT_MAINTAIN_MAIN INTO GS_MAINTAIN_MAIN.
    LOOP AT GS_MAINTAIN_MAIN-T_CAT INTO GS_MATAIN_CAT.
*  사내이체, 판매오더 데이터 미존재시 라인생성 없음
*  전체디스플레이 모드시 제외 없음
      IF P_CHKUSE = ABAP_TRUE.
        CASE GS_MAINTAIN_MAIN-SEQ_ATWRT.
          WHEN 1 OR 2 OR 3 OR 4 OR 9.
            CASE GS_MATAIN_CAT-SEQ_CATALOG.
              WHEN 1 OR 2 OR 3.
                IF GS_MATAIN_CAT-T_DAY IS INITIAL AND GS_MATAIN_CAT-T_WEEK IS INITIAL.
                  CONTINUE.
                ENDIF.
            ENDCASE..
        ENDCASE.
      ENDIF.


      CLEAR GS_MAIN.
      READ TABLE GT_MAIN INTO GS_MAIN WITH KEY MATNR = GS_MAINTAIN_MAIN-MATNR
                                               ATWRT = GS_MAINTAIN_MAIN-ATWRT.

      IF SY-SUBRC EQ 0. " 기준데이터 존재해야 디스플레이 테이블 적재가능합니다.
        CLEAR <LS_MAIN>.

        GS_MAIN-SEQ_CATALOG = GS_MATAIN_CAT-SEQ_CATALOG.
        GS_MAIN-CATALOG = GS_MATAIN_CAT-CATALOG.

        MOVE-CORRESPONDING GS_MAIN TO <LS_MAIN>.

        CASE GS_MATAIN_CAT-SEQ_CATALOG.
          WHEN 4 OR 60.
            CONTINUE.
*          WHEN 5.
          WHEN OTHERS.
* 일별 데이터 세팅
            LOOP AT GS_MATAIN_CAT-T_DAY INTO GS_DIFINE_DAY.
              CLEAR LV_FIELDNAME.
              LV_FIELDNAME = GS_DIFINE_DAY-DATE.
              IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
              ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
              IF <LV_VALUE> IS ASSIGNED.
                WRITE GS_DIFINE_DAY-PSAMG TO <LV_VALUE> UNIT 'EA'.
                CONDENSE <LV_VALUE>.
              ENDIF.
            ENDLOOP.

* 주차별 데이터 세팅
            LOOP AT GS_MATAIN_CAT-T_WEEK INTO GS_DIFINE_WEEK.
              CLEAR LV_FIELDNAME.
              LV_FIELDNAME = GS_DIFINE_WEEK-WEEK.
              IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
              ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
              IF <LV_VALUE> IS ASSIGNED.
                WRITE GS_DIFINE_WEEK-GSMNG TO <LV_VALUE> UNIT 'EA'.
                CONDENSE <LV_VALUE>.
              ENDIF.
            ENDLOOP.

* 월별 데이터 세팅
            LOOP AT GS_MATAIN_CAT-T_SPMON INTO GS_DIFINE_SPMON.
              CLEAR LV_FIELDNAME.
              READ TABLE GT_SPMON INTO GS_SPMON WITH KEY SPMON = GS_DIFINE_SPMON-SPMON.
              LV_FIELDNAME = GS_SPMON-FIELDNAME.
              IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
              ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
              IF <LV_VALUE> IS ASSIGNED.
                WRITE GS_DIFINE_SPMON-GSMNG TO <LV_VALUE> UNIT 'EA'.
                CONDENSE <LV_VALUE>.
              ENDIF.
            ENDLOOP.

        ENDCASE.
* 예상재고 Overdue 필드 세팅
        CASE GS_MATAIN_CAT-SEQ_CATALOG.
          WHEN 99.
            IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
            ASSIGN COMPONENT 'OVERDUE' OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
            IF <LV_VALUE> IS ASSIGNED.
              CLEAR LV_PSAMG.
              LOOP AT GT_SUM_STOCK INTO GS_SUM_STOCK WHERE MATNR = GS_MAIN-MATNR
                                                       AND ATWRT = GS_MAIN-ATWRT.
                ADD GS_SUM_STOCK-STOCK TO LV_PSAMG.
              ENDLOOP.

              IF LV_PSAMG NE 0.
                WRITE LV_PSAMG TO <LV_VALUE> UNIT 'EA'.
                CONDENSE <LV_VALUE>.
              ELSE.
                <LV_VALUE> = 0.
                CONDENSE <LV_VALUE>.
              ENDIF.
            ENDIF.

        ENDCASE.

        APPEND <LS_MAIN> TO <GT_MAIN_DISP_100>.

      ENDIF.
    ENDLOOP.


    CASE GS_MAINTAIN_MAIN-SEQ_ATWRT.
      WHEN 0.

        CLEAR GS_MAIN.
        READ TABLE GT_MAIN INTO GS_MAIN WITH KEY MATNR = GS_MAINTAIN_MAIN-MATNR
                                                 SEQ_ATWRT = GS_MAINTAIN_MAIN-SEQ_ATWRT.

        IF SY-SUBRC EQ 0. " 기준데이터 존재해야 디스플레이 테이블 적재가능합니다.
          CLEAR <LS_MAIN>.
          GS_MAIN-ATWRT = '계획'.
          GS_MAIN-SEQ_CATALOG = 9.
          GS_MAIN-CATALOG = '합계'.
          MOVE-CORRESPONDING GS_MAIN TO <LS_MAIN>.

          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT 'OVERDUE' OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
          IF <LV_VALUE> IS ASSIGNED.
            CLEAR LV_PSAMG.
            LOOP AT GT_SUM_STOCK INTO GS_SUM_STOCK WHERE MATNR = GS_MAIN-MATNR.
              ADD GS_SUM_STOCK-STOCK TO LV_PSAMG.
            ENDLOOP.

            IF LV_PSAMG NE 0.
              WRITE LV_PSAMG TO <LV_VALUE> UNIT 'EA'.
              CONDENSE <LV_VALUE>.
            ELSE.
              <LV_VALUE> = 0.
              CONDENSE <LV_VALUE>.
            ENDIF.
          ENDIF.

* 일별 데이터 세팅
          LOOP AT GT_DATE INTO GS_DATE.
            CLEAR LV_FIELDNAME.
            LV_FIELDNAME = GS_DATE-FIELDNAME.
            IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
            ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
            IF <LV_VALUE> IS ASSIGNED.
              CLEAR LV_PSAMG.
              LOOP AT GT_MAINTAIN_MAIN INTO DATA(LS_TEMP) WHERE MATNR = GS_MAIN-MATNR.
                CASE LS_TEMP-SEQ_ATWRT.
                  WHEN 1 OR 2 OR 3 OR 4.
                    READ TABLE LS_TEMP-T_CAT INTO DATA(LS_CAT_TEMP) WITH KEY SEQ_CATALOG = 99.
                    IF SY-SUBRC EQ 0.
                      READ TABLE LS_CAT_TEMP-T_DAY INTO DATA(LS_TEMP_DAY) WITH KEY DATE = GS_DATE-DATE.
                      IF SY-SUBRC EQ 0.
                        ADD LS_TEMP_DAY-PSAMG TO LV_PSAMG.
                      ENDIF.
                    ENDIF.

                ENDCASE.
              ENDLOOP.

              IF LV_PSAMG NE 0.
                WRITE LV_PSAMG TO <LV_VALUE> UNIT 'EA'.
                CONDENSE <LV_VALUE>.
              ENDIF.
            ENDIF.
          ENDLOOP.

* 주차별 데이터 세팅
          LOOP AT GT_WEEK INTO GS_WEEK.
            CLEAR LV_FIELDNAME.
            LV_FIELDNAME = GS_WEEK-FIELDNAME.
            IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
            ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
            IF <LV_VALUE> IS ASSIGNED.
              CLEAR LV_PSAMG.
              LOOP AT GT_MAINTAIN_MAIN INTO LS_TEMP WHERE MATNR = GS_MAIN-MATNR.
                CASE LS_TEMP-SEQ_ATWRT.
                  WHEN 1 OR 2 OR 3 OR 4.
                    READ TABLE LS_TEMP-T_CAT INTO LS_CAT_TEMP WITH KEY SEQ_CATALOG = 99.
                    IF SY-SUBRC EQ 0.
                      READ TABLE LS_CAT_TEMP-T_WEEK INTO DATA(LS_TEMP_WEEK) WITH KEY WEEK = GS_WEEK-WEEK.
                      IF SY-SUBRC EQ 0.
                        ADD LS_TEMP_WEEK-GSMNG TO LV_PSAMG.
                      ENDIF.
                    ENDIF.
                ENDCASE.
              ENDLOOP.

              IF LV_PSAMG NE 0.
                WRITE LV_PSAMG TO <LV_VALUE> UNIT 'EA'.
                CONDENSE <LV_VALUE>.
              ENDIF.
            ENDIF.
          ENDLOOP.

* 월별 데이터 세팅
          LOOP AT GT_SPMON INTO GS_SPMON.
            CLEAR LV_FIELDNAME.
            LV_FIELDNAME = GS_SPMON-FIELDNAME.
            IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
            ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
            IF <LV_VALUE> IS ASSIGNED.
              CLEAR LV_PSAMG.
              LOOP AT GT_MAINTAIN_MAIN INTO LS_TEMP WHERE MATNR = GS_MAIN-MATNR.
                CASE LS_TEMP-SEQ_ATWRT.
                  WHEN 1 OR 2 OR 3 OR 4.
                    READ TABLE LS_TEMP-T_CAT INTO LS_CAT_TEMP WITH KEY SEQ_CATALOG = 99.
                    IF SY-SUBRC EQ 0.
                      READ TABLE LS_CAT_TEMP-T_SPMON INTO DATA(LS_TEMP_SPMON) WITH KEY SPMON = GS_SPMON-SPMON.
                      IF SY-SUBRC EQ 0.
                        ADD LS_TEMP_SPMON-GSMNG TO LV_PSAMG.
                      ENDIF.
                    ENDIF.
                ENDCASE.
              ENDLOOP.

              IF LV_PSAMG NE 0.
                WRITE LV_PSAMG TO <LV_VALUE> UNIT 'EA'.
                CONDENSE <LV_VALUE>.
              ENDIF.
            ENDIF.
          ENDLOOP.

          APPEND <LS_MAIN> TO <GT_MAIN_DISP_100>.
        ENDIF.
    ENDCASE.


  ENDLOOP.

  LOOP AT GT_DATE_AVAILABLE ASSIGNING FIELD-SYMBOL(<LS_DATE>).
    CLEAR <LS_DATE>-AVAILABLE.
  ENDLOOP.

  LOOP AT GT_WEEK_AVAILABLE ASSIGNING FIELD-SYMBOL(<LS_WEEK>).
    CLEAR <LS_WEEK>-AVAILABLE.
  ENDLOOP.

  LOOP AT GT_MATNR_MAIN INTO GS_MATNR_MAIN.
    CLEAR <LS_MAIN>.
    GS_MATNR_MAIN-ATWRT = '계획'.
    MOVE-CORRESPONDING GS_MATNR_MAIN TO <LS_MAIN>.
* 일별 데이터 세팅
    CLEAR GS_MATAIN_CAT.
    GS_MATAIN_CAT = GS_MATNR_MAIN-S_CAT .

    LOOP AT GS_MATAIN_CAT-T_DAY INTO GS_DIFINE_DAY.
      CLEAR LV_FIELDNAME.
      LV_FIELDNAME = GS_DIFINE_DAY-DATE.
      IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
      IF <LV_VALUE> IS ASSIGNED.
        IF GS_DIFINE_DAY-PSAMG NE 0.
          IF GS_MATNR_MAIN-SEQ_CATALOG = 7.
            READ TABLE GT_DATE_AVAILABLE ASSIGNING <LS_DATE> WITH KEY DATE = GS_DIFINE_DAY-DATE.
            IF SY-SUBRC EQ 0.
              ADD GS_DIFINE_DAY-PSAMG TO <LS_DATE>-AVAILABLE.
            ENDIF.
          ENDIF.
          WRITE GS_DIFINE_DAY-PSAMG TO <LV_VALUE> UNIT 'EA'.
          CONDENSE <LV_VALUE>.
          IF GS_DIFINE_DAY-AUFNR IS NOT INITIAL.
            CASE GS_DIFINE_DAY-ORDER_STAT.
              WHEN 'D'.
                <LV_VALUE> = <LV_VALUE> && '(D)'.
              WHEN 'R'.
                <LV_VALUE> = <LV_VALUE> && '(R)'.
              WHEN OTHERS.
                <LV_VALUE> = <LV_VALUE> && '(C)'.
            ENDCASE.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

* 주차별 데이터 세팅
    LOOP AT GS_MATAIN_CAT-T_WEEK INTO GS_DIFINE_WEEK.
      CLEAR LV_FIELDNAME.
      LV_FIELDNAME = GS_DIFINE_WEEK-WEEK.
      IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
      IF <LV_VALUE> IS ASSIGNED.
        IF GS_DIFINE_WEEK-GSMNG NE 0.

          READ TABLE GT_WEEK_AVAILABLE ASSIGNING <LS_WEEK> WITH KEY WEEK = GS_DIFINE_WEEK-WEEK.
          IF SY-SUBRC EQ 0.
            ADD GS_DIFINE_WEEK-GSMNG TO <LS_WEEK>-AVAILABLE.
          ENDIF.

          WRITE GS_DIFINE_WEEK-GSMNG TO <LV_VALUE> UNIT 'EA'.
          CONDENSE <LV_VALUE>.
        ENDIF.
      ENDIF.
    ENDLOOP.

* 월별 데이터 세팅
    LOOP AT GS_MATAIN_CAT-T_SPMON INTO GS_DIFINE_SPMON.
      CLEAR LV_FIELDNAME.
      READ TABLE GT_SPMON INTO GS_SPMON WITH KEY SPMON = GS_DIFINE_SPMON-SPMON.
      LV_FIELDNAME = GS_SPMON-FIELDNAME.
      IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
      IF <LV_VALUE> IS ASSIGNED.
        IF GS_DIFINE_SPMON-GSMNG NE 0.
          WRITE GS_DIFINE_SPMON-GSMNG TO <LV_VALUE> UNIT 'EA'.
          CONDENSE <LV_VALUE>.
        ENDIF.
      ENDIF.
    ENDLOOP.

    APPEND <LS_MAIN> TO <GT_MAIN_DISP_100>.

  ENDLOOP.


* 설비 가동시간 세팅(세번째라인)
*&---------------------------------------------------------------------*
  CLEAR <LS_MAIN>.
* 라인 정렬을 위한 seq 필드
  IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
  ASSIGN COMPONENT 'SEQ_MAIN' OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
  IF <LV_VALUE> IS ASSIGNED.
    <LV_VALUE> = 3.
  ENDIF.

* 일별 계획수량 text
  IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
  ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
  IF <LV_VALUE> IS ASSIGNED.
    <LV_VALUE> = '계획 가능 수량'.
  ENDIF.

* 단위 text
  IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
  ASSIGN COMPONENT 'MEINS' OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
  IF <LV_VALUE> IS ASSIGNED.
    <LV_VALUE> = 'KG'.
  ENDIF.

* 일자별 가동시간 세팅
  LOOP AT GT_DATE_AVAILABLE INTO GS_DATE_AVAILABLE.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = GS_DATE_AVAILABLE-DATE.
    IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
    IF <LV_VALUE> IS ASSIGNED.
      LV_PSAMG = GS_DATE_AVAILABLE-LIMIT - GS_DATE_AVAILABLE-AVAILABLE.
      IF LV_PSAMG < 0.
        LV_PSAMG = 0.
      ENDIF.
      WRITE LV_PSAMG TO <LV_VALUE> UNIT 'EA'.
      CONDENSE  <LV_VALUE>.
    ENDIF.
  ENDLOOP.

* 주차별 가동시간 세팅(24로 세팅)
  LOOP AT GT_WEEK_AVAILABLE INTO GS_WEEK_AVAILABLE.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = GS_WEEK_AVAILABLE-WEEK.
    IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
    IF <LV_VALUE> IS ASSIGNED.
      LV_PSAMG = GS_WEEK_AVAILABLE-LIMIT - GS_WEEK_AVAILABLE-AVAILABLE.
      IF LV_PSAMG < 0.
        LV_PSAMG = 0.
      ENDIF.
      WRITE LV_PSAMG TO <LV_VALUE> UNIT 'EA'.
    ENDIF.
  ENDLOOP.

  APPEND <LS_MAIN> TO <GT_MAIN_DISP_100>.
*&---------------------------------------------------------------------*


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_INIT_INFOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_INIT_INFOR .

* [소재] 일자별 가동시간 추출
  REFRESH GT_2150.
  FREE GT_2150.

  SELECT * INTO TABLE GT_2150 FROM ZGTPPT2150
   WHERE WERKS = P_WERKS
     AND SPGCD = P_SPGCD.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISP_PROC .
  CLEAR GV_CHK_EDIT.
  CALL SCREEN '0100'.
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

  CREATE OBJECT GO_DOCKING_0100
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
*화면 분할
  CREATE OBJECT GO_SPLITTER_0100
    EXPORTING
      PARENT  = GO_DOCKING_0100
      ROWS    = 2
      COLUMNS = 1.

  GO_SPLITTER_0100->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    6 ).             " Height

** top 컨테이너
  CALL METHOD GO_SPLITTER_0100->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_TOP_0100.

* bottom 컨테이너
  CALL METHOD GO_SPLITTER_0100->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0100.

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

*// Event Handler ##
  CASE PO_GRID.
    WHEN GO_GRID_0100.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
      IF P_PROC = ABAP_TRUE.
        SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
        SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
        SET HANDLER GO_EVENT_HANDLER->HANDLE_CONTEXT_MENU          FOR PO_GRID.
      ENDIF.
    WHEN GO_GRID_0200.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
    WHEN GO_GRID_0300.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.

    WHEN GO_GRID_0400.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
  ENDCASE.

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
  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
*  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0100-STYLEFNAME = 'XYZSTYLEZYX'.
  GS_LAYOUT_0100-NO_ROWMARK  = ABAP_TRUE.
  GS_LAYOUT_0100-SEL_MODE  = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0100 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  DATA : LV_FIELDNAME TYPE FIELDNAME.

  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.
  FIELD-SYMBOLS <LV_VALUE> TYPE ANY.

  LOOP AT <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_DATA>).
    CLEAR GS_MAIN.
    MOVE-CORRESPONDING <LS_DATA> TO GS_MAIN.
    CASE GS_MAIN-SEQ_MAIN.
      WHEN 0.
        REFRESH LT_CELLTAB.
        LOOP AT GT_FIELDCAT_0100 INTO DATA(LS_FCAT).
          IF LS_FCAT-NO_OUT IS INITIAL AND LS_FCAT-TECH IS INITIAL.
            READ TABLE GT_DAY_ATTR INTO DATA(LS_DAY) WITH KEY DATE = LS_FCAT-FIELDNAME.
            IF SY-SUBRC EQ 0 AND ( LS_DAY-WEEKDAY = 6 OR LS_DAY-WEEKDAY = 7 ).
              CLEAR LS_CELLTAB.
              LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_NEGATIVE + ALV_STYLE_ALIGN_CENTER_TOP.
              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
            ELSE.
              CLEAR LS_CELLTAB.
              LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_BACKGROUND + ALV_STYLE_ALIGN_CENTER_TOP.
              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
            ENDIF.
          ELSE.
            CLEAR LS_CELLTAB.
            LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
            LS_CELLTAB-STYLE = ALV_STYLE_COLOR_BACKGROUND + ALV_STYLE_ALIGN_CENTER_TOP.
            INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
          ENDIF.
        ENDLOOP.
      WHEN 1.
        REFRESH LT_CELLTAB.
        LOOP AT GT_FIELDCAT_0100 INTO LS_FCAT.
          IF LS_FCAT-NO_OUT IS INITIAL AND LS_FCAT-TECH IS INITIAL.
            CLEAR LS_CELLTAB.
            LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
            LS_CELLTAB-STYLE = ALV_STYLE_COLOR_BACKGROUND + ALV_STYLE_ALIGN_CENTER_TOP.
            INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
          ENDIF.
        ENDLOOP.
      WHEN 3.
        REFRESH LT_CELLTAB.
        LOOP AT GT_FIELDCAT_0100 INTO LS_FCAT.
          IF LS_FCAT-NO_OUT IS INITIAL AND LS_FCAT-TECH IS INITIAL.
            CASE LS_FCAT-FIELDNAME.
              WHEN 'MATNR' OR 'MAKTX' OR 'ATWRT' OR 'CATALOG' OR 'MEINS' OR 'OVERDUE'.

                CLEAR LS_CELLTAB.
                LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
                LS_CELLTAB-STYLE = ALV_STYLE_COLOR_BACKGROUND + ALV_STYLE_ALIGN_CENTER_TOP.
                INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
              WHEN OTHERS.
                CLEAR GS_DATE_AVAILABLE.
                READ TABLE GT_DATE_AVAILABLE INTO GS_DATE_AVAILABLE WITH KEY DATE = LS_FCAT-FIELDNAME.
                IF SY-SUBRC = 0.
                  CLEAR LS_CELLTAB.
                  LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
                  IF GS_DATE_AVAILABLE-LIMIT < GS_DATE_AVAILABLE-AVAILABLE.
                    LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INV_NEGATIVE .
                  ELSE.
                    LS_CELLTAB-STYLE = ALV_STYLE_COLOR_BACKGROUND .
                  ENDIF.
                  INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
                ELSE .
                  CLEAR GS_WEEK_AVAILABLE.
                  READ TABLE GT_WEEK_AVAILABLE INTO GS_WEEK_AVAILABLE WITH KEY WEEK = LS_FCAT-FIELDNAME.
                  IF SY-SUBRC = 0.
                    CLEAR LS_CELLTAB.
                    LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
                    IF GS_DATE_AVAILABLE-LIMIT < GS_DATE_AVAILABLE-AVAILABLE.
                      LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INV_NEGATIVE .
                    ELSE.
                      LS_CELLTAB-STYLE = ALV_STYLE_COLOR_BACKGROUND .
                    ENDIF.
                    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
                  ELSE.
                    READ TABLE GT_SPMON INTO GS_SPMON WITH KEY FIELDNAME = LS_FCAT-FIELDNAME.
                    IF SY-SUBRC EQ 0.
                      CLEAR LS_CELLTAB.
                      LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
                      LS_CELLTAB-STYLE = ALV_STYLE_COLOR_BACKGROUND .
                      INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
                    ENDIF.
                  ENDIF.
                ENDIF.
            ENDCASE.
          ENDIF.
        ENDLOOP.
      WHEN OTHERS.
        REFRESH LT_CELLTAB.
* 키필드 색상지정
        LOOP AT GT_FIELDCAT_0100 INTO LS_FCAT.
          CASE LS_FCAT-FIELDNAME.
            WHEN 'MATNR' OR 'MAKTX' OR 'ATWRT'.
              CLEAR LS_CELLTAB.
              LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_KEY.
              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
            WHEN 'CATALOG' OR 'MEINS' OR 'OVERDUE'.
              LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
              IF GS_MAIN-SEQ_ATWRT = 0.
                CASE GS_MAIN-SEQ_CATALOG.
                  WHEN 7. " 생산계획, 예상재고 노랑
                    LS_CELLTAB-STYLE = ALV_STYLE_COLOR_TOTAL.
                  WHEN OTHERS.
                    LS_CELLTAB-STYLE = ALV_STYLE_COLOR_KEY.
                ENDCASE.
              ELSE.
                CASE GS_MAIN-SEQ_CATALOG.
                  WHEN 99. " 현재재고 초록
                    LS_CELLTAB-STYLE = ALV_STYLE_COLOR_KEY.
                  WHEN OTHERS.
                    LS_CELLTAB-STYLE = ALV_STYLE_COLOR_KEY.
                ENDCASE.
              ENDIF.
              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
          ENDCASE.
        ENDLOOP.

        CASE GS_MAIN-SEQ_CATALOG.
          WHEN 7. " 판매계획, 예상재고만 색상 적용대상

            READ TABLE GT_MATNR_MAIN INTO GS_MATNR_MAIN WITH KEY MATNR = GS_MAIN-MATNR
                                                                                               SEQ_CATALOG = 7.
            LOOP AT GS_MATNR_MAIN-S_CAT-T_DAY INTO GS_DIFINE_DAY.
*             기존 계획 오더 추출건에 변경사항 없으면 회색
              IF GS_DIFINE_DAY-PLNUM IS NOT INITIAL AND GS_DIFINE_DAY-CHANGE IS INITIAL. " 계획 오더 회색처리
                CLEAR LS_CELLTAB.
                LS_CELLTAB-FIELDNAME = GS_DIFINE_DAY-DATE.
                LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_BACKGROUND.
                INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
              ENDIF.

              IF GS_DIFINE_DAY-AUFNR IS NOT INITIAL.
                CLEAR LS_CELLTAB.
                LS_CELLTAB-FIELDNAME = GS_DIFINE_DAY-DATE.
                IF GS_DIFINE_DAY-ORDER_STAT IS INITIAL." 생산오더 존재시 노란색
                  LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_TOTAL.
                ELSE. " 생산오더 릴리즈시 초록
                  LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_POSITIVE.
                ENDIF.
                INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
              ENDIF.
            ENDLOOP.

            LOOP AT GT_DATE INTO GS_DATE.
              READ TABLE GS_MATNR_MAIN-S_CAT-T_DAY TRANSPORTING NO FIELDS WITH KEY DATE = GS_DATE-DATE.
              IF SY-SUBRC NE 0.
                CLEAR LS_CELLTAB.
                LS_CELLTAB-FIELDNAME = GS_DATE-DATE.
                LS_CELLTAB-STYLE = ALV_STYLE_COLOR_TOTAL.
                INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
              ENDIF.
            ENDLOOP.

            LOOP AT GS_MATNR_MAIN-S_CAT-T_WEEK INTO GS_DIFINE_WEEK.
              IF GS_DIFINE_WEEK-PLNUM IS NOT INITIAL.
                CLEAR LS_CELLTAB.
                LS_CELLTAB-FIELDNAME = GS_DIFINE_WEEK-WEEK.
                LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_BACKGROUND.
                INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
              ENDIF.
            ENDLOOP.

            LOOP AT GT_WEEK INTO GS_WEEK.
              READ TABLE GS_MATNR_MAIN-S_CAT-T_WEEK TRANSPORTING NO FIELDS WITH KEY WEEK = GS_WEEK-WEEK.
              IF SY-SUBRC NE 0.
                CLEAR LS_CELLTAB.
                LS_CELLTAB-FIELDNAME = GS_WEEK-FIELDNAME.
                LS_CELLTAB-STYLE = ALV_STYLE_COLOR_TOTAL.
                INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
              ENDIF.
            ENDLOOP.

** 월별 필드 색상 노락색
*            LOOP AT GT_SPMON INTO GS_SPMON.
*              CLEAR LS_CELLTAB.
*              LS_CELLTAB-FIELDNAME = GS_SPMON-FIELDNAME.
*              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_TOTAL.
*              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
*            ENDLOOP.


          WHEN 99.

            READ TABLE GT_MAINTAIN_MAIN INTO GS_MAINTAIN_MAIN WITH KEY MATNR = GS_MAIN-MATNR
                                                                                                    SEQ_ATWRT = GS_MAIN-SEQ_ATWRT.

            READ TABLE GS_MAINTAIN_MAIN-T_CAT INTO GS_MATAIN_CAT WITH KEY SEQ_CATALOG = 99.

            LOOP AT GS_MATAIN_CAT-T_DAY INTO GS_DIFINE_DAY.
              CASE GS_DIFINE_DAY-STATUS.
                WHEN 'L'.
                  CLEAR LS_CELLTAB.
                  LS_CELLTAB-FIELDNAME = GS_DIFINE_DAY-DATE.
                  LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_HEADING.
                  INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
                WHEN 'H'.
                  CLEAR LS_CELLTAB.
                  LS_CELLTAB-FIELDNAME = GS_DIFINE_DAY-DATE.
                  LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_GROUP.
                  INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
                WHEN 'R'.
                  CLEAR LS_CELLTAB.
                  LS_CELLTAB-FIELDNAME = GS_DIFINE_DAY-DATE.
                  LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_NEGATIVE.
                  INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
                WHEN 'N'.
                  CLEAR LS_CELLTAB.
                  LS_CELLTAB-FIELDNAME = GS_DIFINE_DAY-DATE.
                  LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INV_POSITIVE.
                  INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
                WHEN OTHERS.
                  IF GS_DIFINE_DAY-DATE >= SY-DATUM.
                    CLEAR LS_CELLTAB.
                    LS_CELLTAB-FIELDNAME = GS_DIFINE_DAY-DATE.
                    LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_BACKGROUND.
                    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
                  ENDIF.
              ENDCASE.
            ENDLOOP.

            LOOP AT GS_MATAIN_CAT-T_WEEK INTO GS_DIFINE_WEEK.
              CASE GS_DIFINE_WEEK-STATUS.
                WHEN 'L'.
                  CLEAR LS_CELLTAB.
                  LS_CELLTAB-FIELDNAME = GS_DIFINE_WEEK-WEEK.
                  LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_HEADING.
                  INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
                WHEN 'H'.
                  CLEAR LS_CELLTAB.
                  LS_CELLTAB-FIELDNAME = GS_DIFINE_WEEK-WEEK.
                  LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_GROUP.
                  INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
                WHEN 'R'.
                  CLEAR LS_CELLTAB.
                  LS_CELLTAB-FIELDNAME = GS_DIFINE_WEEK-WEEK.
                  LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_NEGATIVE.
                  INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
                WHEN 'N'.
                  CLEAR LS_CELLTAB.
                  LS_CELLTAB-FIELDNAME = GS_DIFINE_WEEK-WEEK.
                  LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INV_POSITIVE.
                  INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
                WHEN OTHERS.
                  CLEAR LS_CELLTAB.
                  LS_CELLTAB-FIELDNAME = GS_DIFINE_WEEK-WEEK.
                  LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_BACKGROUND.
                  INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
              ENDCASE.
            ENDLOOP.
          WHEN OTHERS.

*            LOOP AT GT_DATE INTO GS_DATE.
*              CLEAR LS_CELLTAB.
*              LS_CELLTAB-FIELDNAME = GS_DATE-DATE.
*              IF GS_MAIN-SEQ_ATWRT = 0.
*                CASE GS_MAIN-SEQ_CATALOG.
*                  WHEN '1'.
*                    LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_NORMAL.
*                ENDCASE.
*              ELSE.
*                LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INV_NORMAL.
*              ENDIF.
*              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
*            ENDLOOP.
*
*            LOOP AT GT_WEEK INTO GS_WEEK.
*              CLEAR LS_CELLTAB.
*              LS_CELLTAB-FIELDNAME = GS_WEEK-FIELDNAME.
*              IF GS_MAIN-SEQ_ATWRT = 0.
*                CASE GS_MAIN-SEQ_CATALOG.
*                  WHEN '1'.
*                    LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_NORMAL.
*                ENDCASE.
*              ELSE.
*                LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INV_NORMAL.
*              ENDIF.
*              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
*            ENDLOOP.


        ENDCASE.

    ENDCASE.

    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'XYZSTYLEZYX' OF STRUCTURE <LS_DATA> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

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
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_DESELECT_ALL,
                CL_GUI_ALV_GRID=>MC_FC_DETAIL,
                CL_GUI_ALV_GRID=>MC_FC_SELECT_ALL,
                CL_GUI_ALV_GRID=>MC_FC_DELETE_FILTER,
                CL_GUI_ALV_GRID=>MC_FC_FILTER,
                CL_GUI_ALV_GRID=>MC_FC_SORT_ASC,
                CL_GUI_ALV_GRID=>MC_FC_SORT_DSC,
                CL_GUI_ALV_GRID=>MC_FC_SUBTOT,
                CL_GUI_ALV_GRID=>MC_FC_SUM,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FG_SORT,
                CL_GUI_ALV_GRID=>MC_MB_SUM,
*                CL_GUI_ALV_GRID=>MC_MB_VARIANT,
                CL_GUI_ALV_GRID=>MC_MB_VIEW,
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
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*-----------------------------------------------------------------------
**
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.
  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.
ENDFORM.                    " add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0100 .

  PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                                  USING : 1 'SEQ_MAIN'  'X' '' '',
                                             2 'SEQ_MATNR' '' '' '',
                                             3 'MATNR'  'X' '' '',
                                             4 'MAKTX'  'X' '' '',
                                             5 'SEQ_ATWRT'  'X' '' '',
                                             6 'ATWRT'  'X' '' '',
                                             7 'SEQ_CATALOG'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_sort_tab
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
      IT_OUTTAB            = <GT_MAIN_DISP_100>
      IT_SORT              = GT_SORT_0100
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

  IF GO_DD_DOCU_0100 IS BOUND.
    CALL METHOD GO_DD_DOCU_0100->INITIALIZE_DOCUMENT.
  ELSE.
    CREATE OBJECT GO_DD_DOCU_0100
      EXPORTING
        STYLE = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD GO_GRID_0100->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DD_DOCU_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form TOOLBAR_PROS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM TOOLBAR_PROS  USING    PO_SENDER
                          PO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                          R_INTERACTIVE.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                        USING : 'RELEASE' ICON_RELEASE '생산오더릴리즈' '생산오더릴리즈' 0.

    WHEN GO_GRID_0200.
      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                        USING : 'INSERT' ICON_INSERT_ROW ' ' '' 0 ,
                                   'DELETE' ICON_DELETE_ROW '' '' 0 .

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> PO_OBJECT_>MT_TOOLBAR
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR  TABLES  PT_TOOLBAR STRUCTURE STB_BUTTON
               USING    PV_FUNCTION
                           PV_ICON
                           PV_TEXT
                           PV_QUICKINFO
                           PV_BUTN_TYPE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION  = PV_FUNCTION.
  LS_TOOLBAR-ICON      = PV_ICON.
  IF PV_TEXT IS NOT INITIAL.
    CONCATENATE ' '  PV_TEXT ' '  INTO LS_TOOLBAR-TEXT SEPARATED BY SPACE.
  ENDIF.
  LS_TOOLBAR-QUICKINFO = PV_QUICKINFO.
  LS_TOOLBAR-BUTN_TYPE = PV_BUTN_TYPE.
  APPEND LS_TOOLBAR TO PT_TOOLBAR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_PROS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM USER_COMMAND_PROS  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                 PV_UCOMM.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      CASE PV_UCOMM.
        WHEN 'RELEASE'. " 생산오더 릴리즈
          PERFORM PROC_AUTO_REALEASE.
        WHEN 'A1'. " 생산(Full)
          PERFORM PROC_AUTO_CREATE_PLAN.
        WHEN 'A2'.  " 생산(수량입력)
          PERFORM PROC_MANUAL_USE_INPUT_PLAN.
        WHEN 'A3'.  " 삭제
          PERFORM PROC_DEL_SELECTED_PLAN.
        WHEN 'A4'.  " 라인삭제
          PERFORM PROC_DEL_LINES.
        WHEN 'A5'.  " 상세생산(수량입력)
          PERFORM PROC_SET_LINE_FULL_MANUAL.
        WHEN 'A7'.  " 차감재고 관리
          PERFORM PROC_MANAGE_JEGO.
      ENDCASE.
    WHEN GO_GRID_0200.
      CASE PV_UCOMM.
        WHEN 'INSERT'. " append line
          PERFORM INSERT_LINE_SCREEN200.
        WHEN 'DELETE'. " delete line
          PERFORM DELETE_LINE_SCREEN200.
      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      <-- E_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM ALV_TOP_OF_PAGE  USING    PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                CHANGING    PO_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      PERFORM SET_TITLE_SCREEN100 CHANGING PO_DYNDOC_ID.
    WHEN GO_GRID_0300.
      PERFORM SET_TITLE_SCREEN300 CHANGING PO_DYNDOC_ID.
    WHEN GO_GRID_0400.
      PERFORM SET_TITLE_SCREEN400 CHANGING PO_DYNDOC_ID.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_SCREEN100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PO_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM SET_TITLE_SCREEN100  CHANGING PO_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  DATA : LV_TEXT(255) TYPE C.
  DATA : LV_FR_SPMON(10).
  DATA : LV_TO_SPMON(10).

* 플랜트명
  CLEAR LV_TEXT.
  IF P_NAME1 IS INITIAL.
    SELECT SINGLE NAME1 INTO P_NAME1
             FROM T001W
            WHERE WERKS EQ P_WERKS.
  ENDIF.
  IF P_DESCR IS INITIAL.
    SELECT SINGLE DESCR INTO P_DESCR
         FROM ZPPT0107
        WHERE SPGCD EQ P_SPGCD.
  ENDIF.

  LV_TEXT = P_NAME1 && '(' && P_DESCR && ')'.
  CONCATENATE '플랜트 :' LV_TEXT INTO LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PO_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PO_DYNDOC_ID->NEW_LINE.

* 기간
  CLEAR LV_TEXT.
  IF S_DATE-LOW = S_DATE-HIGH.
    LV_FR_SPMON = S_DATE-LOW+0(4) &&'.' && S_DATE-LOW+4(2) && '.' && S_DATE-LOW+6(2).
    CONCATENATE '기간 :' LV_FR_SPMON INTO LV_TEXT SEPARATED BY SPACE.
  ELSE.
    .LV_FR_SPMON = S_DATE-LOW+0(4) &&'.' && S_DATE-LOW+4(2) && '.' && S_DATE-LOW+6(2).
    .LV_TO_SPMON = S_DATE-HIGH+0(4) &&'.' && S_DATE-HIGH+4(2) && '.' && S_DATE-HIGH+6(2).
    CONCATENATE '기간 :' LV_FR_SPMON '~' LV_TO_SPMON INTO LV_TEXT SEPARATED BY SPACE.
  ENDIF.
  "텍스트 추가
  CALL METHOD PO_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PO_DYNDOC_ID->NEW_LINE.


  "위쪽에 추가한 텍스트 출력
  CALL METHOD PO_DYNDOC_ID->DISPLAY_DOCUMENT
    EXPORTING
      PARENT             = GO_CONTAIN_TOP_0100
      REUSE_CONTROL      = ABAP_TRUE
      REUSE_REGISTRATION = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONTEXT_MENU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&---------------------------------------------------------------------*
FORM CONTEXT_MENU  USING   P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                         P_OBJECT TYPE REF TO CL_CTMENU.

  DATA: LT_STD_FCODES TYPE UI_FUNCTIONS,
        LT_OWN_FCODES TYPE UI_FUNCTIONS.
  DATA : LV_TEXT TYPE GUI_TEXT.

  DATA : LV_ROW TYPE I.
  DATA : LS_COL_ID TYPE LVC_S_COL.

  GO_GRID_0100->GET_CURRENT_CELL(
    IMPORTING
      E_ROW     =  LV_ROW                " Row on Grid
      ES_COL_ID =  LS_COL_ID ).               " colum ID

  IF LV_ROW = 0.
    RETURN.
  ENDIF.

  P_OBJECT->CLEAR( ).

  READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LV_ROW.
  CLEAR GS_MAIN.
  MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.

  CASE GS_MAIN-SEQ_CATALOG.
    WHEN 11 OR 12.
* 생산(자동)
      CLEAR LV_TEXT.
      LV_TEXT = '사급, 신선 관리'.
      CALL METHOD P_OBJECT->ADD_FUNCTION
        EXPORTING
          FCODE = 'A7'
          TEXT  = LV_TEXT.

    WHEN 7.

* 생산(자동)
      CLEAR LV_TEXT.
      LV_TEXT = '생산(Full)'.
      CALL METHOD P_OBJECT->ADD_FUNCTION
        EXPORTING
          FCODE = 'A1'
          TEXT  = LV_TEXT.

* 생산(수동)
      LV_TEXT = '생산(수량입력)'.
      CALL METHOD P_OBJECT->ADD_FUNCTION
        EXPORTING
          FCODE = 'A2'
          TEXT  = LV_TEXT.

* 생산(수동)
      LV_TEXT = '상세생산(수량입력)'.
      CALL METHOD P_OBJECT->ADD_FUNCTION
        EXPORTING
          FCODE = 'A5'
          TEXT  = LV_TEXT.

* 분리자
      P_OBJECT->ADD_SEPARATOR( ).

* 삭제
      LV_TEXT = '삭제'.
      CALL METHOD P_OBJECT->ADD_FUNCTION
        EXPORTING
          FCODE = 'A3'
          TEXT  = LV_TEXT.

* 라인삭제
      LV_TEXT = '라인삭제'.
      CALL METHOD P_OBJECT->ADD_FUNCTION
        EXPORTING
          FCODE = 'A4'
          TEXT  = LV_TEXT.

    WHEN OTHERS.
      RETURN.
  ENDCASE.

**  CLEAR GS_DATE.
**  READ TABLE GT_DATE INTO GS_DATE WITH KEY FIELDNAME = LS_COL_ID-FIELDNAME.
**  IF SY-SUBRC EQ 0.
**    IF GS_DATE-DATE < SY-DATUM.
**      RETURN.
**    ENDIF.
**  ENDIF.

*  IF GS_MAIN-ATWRT EQ '계획'. " 생산계획 라인이 아니라면 컨텍스트 보여줄 필요없음
*    RETURN.
*  ENDIF.

  CALL METHOD P_OBJECT->SHOW_FUNCTIONS
    EXPORTING
      FCODES = LT_OWN_FCODES.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_AUTO_CREATE_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_AUTO_CREATE_PLAN .

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LT_CHG_DATE TYPE TABLE OF SY-DATUM.
  DATA : LT_CHG_WEEK TYPE TABLE OF SCAL-WEEK.
  DATA : LV_ROW TYPE I.
  DATA : LV_CHK_REL.
  DATA : LV_CAL_PSAMG TYPE CO_PSAMG.

  GO_GRID_0100->GET_SELECTED_CELLS_ID(
        IMPORTING
         ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_CELLS[] IS INITIAL.
    RETURN.
  ENDIF.

  DATA(LT_CELL_CHK) = LT_CELLS.

  SORT LT_CELL_CHK BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CELL_CHK COMPARING ROW_ID.
  IF LINES( LT_CELL_CHK ) > 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산(Full) 은 한 라인만 처리 할 수 있습니다.'(e01).
    RETURN.
  ENDIF.

  SORT LT_CELLS BY COL_ID.

* 가용한 날짜 필드 인지 확인
  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    LV_ROW = LS_CELLS-ROW_ID.

    READ TABLE GT_FIELDCAT_0100 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.

    CLEAR GS_DATE.
    READ TABLE GT_DATE INTO GS_DATE WITH KEY DATE = LS_FCAT-FIELDNAME.
    IF SY-SUBRC EQ 0.
      IF GS_DATE-DATE < SY-DATUM.
        CONTINUE.
      ENDIF.

      COLLECT GS_DATE-DATE INTO LT_CHG_DATE.
    ELSE.
      CLEAR GS_WEEK.
      READ TABLE GT_WEEK INTO GS_WEEK WITH KEY WEEK = LS_FCAT-FIELDNAME.
      IF SY-SUBRC EQ 0.
        COLLECT GS_WEEK-WEEK INTO LT_CHG_WEEK.
      ELSE.
        MESSAGE S005 DISPLAY LIKE 'E' WITH LS_FCAT-REPTEXT '는(은) 생산(Full) 가능한 필드가 아닙니다.'(e02).
        RETURN.
      ENDIF.
    ENDIF.
  ENDLOOP.

* 생산수량 자동 적용
*- 생산(Full) : 선택한 Cell에 생산 Capa 일일 생산량 입력, 드래그 선택
*                   가동시간 24시간 Full Capa 850kg, 1시간 36kg, 소수점 반올림

  READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LV_ROW.
  CLEAR GS_MAIN.
  MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.

  READ TABLE GT_MATNR_MAIN ASSIGNING FIELD-SYMBOL(<LS_MAINTAIN>) WITH KEY MATNR = GS_MAIN-MATNR
                                                                                                                  SEQ_CATALOG = 7.

  ASSIGN <LS_MAINTAIN>-S_CAT TO FIELD-SYMBOL(<LS_CAT>).

* 릴리즈 상태 체크 확인 팝업 적용
  LOOP AT LT_CHG_DATE INTO DATA(LV_DATE).
    CLEAR GS_DIFINE_DAY.
    READ TABLE <LS_CAT>-T_DAY INTO GS_DIFINE_DAY WITH KEY DATE = LV_DATE
                                                                                        ORDER_STAT = 'D' .
    IF SY-SUBRC EQ 0.
      LV_CHK_REL = 'D'.
      EXIT.
    ENDIF.

    IF LV_CHK_REL IS INITIAL.
      READ TABLE <LS_CAT>-T_DAY INTO GS_DIFINE_DAY WITH KEY DATE = LV_DATE
                                                                                        ORDER_STAT = 'R' .
      IF SY-SUBRC EQ 0.
        LV_CHK_REL = ABAP_TRUE.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF LV_CHK_REL = 'D'.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더' GS_DIFINE_DAY-AUFNR '는 작업중으로 변경 불가능합니다.'.
    RETURN.
  ENDIF.

  IF LV_CHK_REL = ABAP_TRUE.
    CLEAR GV_ANSWER.
    PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
      ' '
      '릴리즈되어 작업지시된 생산 오더가 있습니다. 계속 작업하시겠습니까?'
      '작업확인'.
    IF GV_ANSWER NE 'J'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

* 수정 시작
  LOOP AT LT_CHG_DATE INTO LV_DATE.

    READ TABLE <LS_CAT>-T_DAY ASSIGNING FIELD-SYMBOL(<LS_DAY>) WITH KEY DATE = LV_DATE.
    IF SY-SUBRC EQ 0.
      CLEAR LV_CAL_PSAMG.
      READ TABLE GT_DATE_AVAILABLE ASSIGNING FIELD-SYMBOL(<LS_DATE>) WITH KEY DATE = LV_DATE.
      IF SY-SUBRC EQ 0.
        LV_CAL_PSAMG = <LS_DATE>-LIMIT - ( <LS_DATE>-AVAILABLE - <LS_DAY>-PSAMG ).
        IF LV_CAL_PSAMG <= 0.
          CONTINUE.
        ELSE.
          IF <LS_DAY>-PSAMG NE LV_CAL_PSAMG.
            <LS_DAY>-CHANGE = ABAP_TRUE.
          ENDIF.
          <LS_DAY>-PSAMG = LV_CAL_PSAMG.
        ENDIF.
      ENDIF.
    ELSE. " 해달 날짜 조회가 없을경우 추가
      DATA(LV_TABIX) = SY-TABIX.
      CLEAR GS_DIFINE_DAY.
      GS_DIFINE_DAY-DATE = LV_DATE.
      GS_DIFINE_DAY-CHANGE = ABAP_TRUE.

      CLEAR LV_CAL_PSAMG.
      READ TABLE GT_DATE_AVAILABLE ASSIGNING <LS_DATE> WITH KEY DATE = LV_DATE.
      IF SY-SUBRC EQ 0.
        LV_CAL_PSAMG = <LS_DATE>-LIMIT - <LS_DATE>-AVAILABLE.
        IF LV_CAL_PSAMG <= 0.
          CONTINUE.
        ELSE.
          GS_DIFINE_DAY-PSAMG = LV_CAL_PSAMG.
          INSERT GS_DIFINE_DAY INTO TABLE <LS_CAT>-T_DAY.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT LT_CHG_WEEK INTO DATA(LV_WEEK).

    READ TABLE <LS_CAT>-T_WEEK ASSIGNING FIELD-SYMBOL(<LS_WEEK>) WITH KEY WEEK = LV_WEEK.
    IF SY-SUBRC EQ 0.
      CLEAR LV_CAL_PSAMG.
      READ TABLE GT_WEEK_AVAILABLE ASSIGNING FIELD-SYMBOL(<LS_WEEK_AV>) WITH KEY WEEK = LV_WEEK.
      IF SY-SUBRC EQ 0.
        LV_CAL_PSAMG = <LS_WEEK_AV>-LIMIT - ( <LS_WEEK_AV>-AVAILABLE - <LS_WEEK>-GSMNG ).
        IF LV_CAL_PSAMG <= 0.
          CONTINUE.
        ELSE.
          IF <LS_WEEK>-GSMNG NE LV_CAL_PSAMG.
            <LS_WEEK>-CHANGE = ABAP_TRUE.
          ENDIF.
          <LS_WEEK>-GSMNG = LV_CAL_PSAMG.
        ENDIF.
      ENDIF.

    ELSE. " 해달 날짜 조회가 없을경우 추가
      LV_TABIX = SY-TABIX.
      CLEAR GS_DIFINE_WEEK.
      GS_DIFINE_WEEK-WEEK = LV_WEEK.
      GS_DIFINE_WEEK-CHANGE = ABAP_TRUE.

      CLEAR LV_CAL_PSAMG.
      READ TABLE GT_WEEK_AVAILABLE ASSIGNING <LS_WEEK_AV> WITH KEY WEEK = LV_WEEK.
      IF SY-SUBRC EQ 0.
        LV_CAL_PSAMG = <LS_WEEK_AV>-LIMIT - <LS_WEEK_AV>-AVAILABLE.
        IF LV_CAL_PSAMG <= 0.
          CONTINUE.
        ELSE.
          GS_DIFINE_WEEK-GSMNG = LV_CAL_PSAMG.
          INSERT GS_DIFINE_WEEK INTO TABLE <LS_CAT>-T_WEEK.
        ENDIF.
      ENDIF.

    ENDIF.
  ENDLOOP.

  PERFORM SET_SPMON_FIELD CHANGING <LS_MAINTAIN>-S_CAT.
  UNASSIGN <LS_MAINTAIN>.

  PERFORM SET_CAL_STOCK.

  PERFORM SET_DISP_TABLE.

  PERFORM REFRESH_0100.

  GV_CHK_EDIT = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form TRANSPER_ROUND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CAL_PSAMG
*&---------------------------------------------------------------------*
FORM TRANSPER_ROUND  CHANGING PV_PSAMG TYPE CO_PSAMG.

  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
    EXPORTING
      I_RTYPE     = ' ' " 반올림
      I_RUNIT     = 1
      I_VALUE     = PV_PSAMG
    IMPORTING
      E_VALUE_RND = PV_PSAMG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CAL_STOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CAL_STOCK .

  DATA : LV_CAL_STOCK TYPE ZGTCV_SCR_STOCK-LABST.
  DATA : LV_PLUS_STOCK TYPE ZGTCV_SCR_STOCK-LABST.
  DATA : LV_MINUS_STOCK TYPE ZGTCV_SCR_STOCK-LABST.
  DATA : LV_CAL_PSAMG TYPE CO_PSAMG.
  DATA : LT_DAY LIKE TABLE OF GS_DIFINE_DAY.
  DATA : LT_WEEK LIKE TABLE OF GS_WEEK.

* 자재별 예상재고
  LOOP AT GT_MAINTAIN_MAIN ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

    READ TABLE GT_MARC INTO DATA(LS_MARC) WITH KEY <LS_MAIN>-MATNR.

    CLEAR GS_MATNR_MAIN.
    READ TABLE GT_MATNR_MAIN INTO GS_MATNR_MAIN WITH KEY MATNR = <LS_MAIN>-MATNR
                                                         SEQ_CATALOG = 7.

    READ TABLE <LS_MAIN>-T_CAT INTO DATA(LS_CAT) WITH KEY SEQ_CATALOG = 60.

    LOOP AT <LS_MAIN>-T_CAT ASSIGNING FIELD-SYMBOL(<LS_CAT>) WHERE SEQ_CATALOG = 99.
*     현재재고
      CLEAR LV_CAL_STOCK.
      LOOP AT GT_SUM_STOCK INTO GS_SUM_STOCK WHERE MATNR = <LS_MAIN>-MATNR
                                               AND ATWRT = <LS_MAIN>-ATWRT.
        ADD GS_SUM_STOCK-STOCK TO  LV_CAL_STOCK.
      ENDLOOP.

*    일별재고 계산
      LOOP AT <LS_CAT>-T_DAY ASSIGNING FIELD-SYMBOL(<LS_DAY>).
*     + 재고
        CLEAR LV_PLUS_STOCK.
        CLEAR GS_DIFINE_DAY.
        READ TABLE GS_MATNR_MAIN-S_CAT-T_DAY INTO GS_DIFINE_DAY WITH KEY DATE = <LS_DAY>-DATE.
        IF SY-SUBRC EQ 0.
          READ TABLE GT_2152 INTO DATA(LS_2152) WITH KEY SCRGRADE = <LS_MAIN>-ATWRT.
          IF SY-SUBRC EQ 0.
            IF GS_DIFINE_DAY-PSAMG NE 0.
              LV_PLUS_STOCK = GS_DIFINE_DAY-PSAMG * LS_2152-RATE / 100.
              PERFORM TRANSPER_ROUND CHANGING LV_PLUS_STOCK.
            ENDIF.
          ENDIF.
        ENDIF.

*     - 재고
        READ TABLE LS_CAT-T_DAY INTO DATA(LS_DAY_TEMP) WITH KEY DATE = <LS_DAY>-DATE.
        IF SY-SUBRC EQ 0.
          LV_CAL_STOCK = LV_CAL_STOCK + LV_PLUS_STOCK + LS_DAY_TEMP-PSAMG.
        ELSE.
          LV_CAL_STOCK = LV_CAL_STOCK + LV_PLUS_STOCK.
        ENDIF.

        <LS_DAY>-PSAMG = LV_CAL_STOCK.

* - 계산된 예상 재고 수량이 MIN 보다 작으면 파란색 CELL 표시
        IF <LS_DAY>-PSAMG < LS_MARC-EISLO.
          <LS_DAY>-STATUS = 'L'.
          IF <LS_DAY>-PSAMG < 0.
            <LS_DAY>-STATUS = 'R'.
          ENDIF.
        ENDIF.
* - 계산된 예상 재고 수량이 Max 보다 많으면 주황색 Cell 표시
        IF <LS_DAY>-PSAMG > LS_MARC-EISBE.
          <LS_DAY>-STATUS = 'H'.
        ENDIF.

        IF <LS_DAY>-PSAMG BETWEEN LS_MARC-EISLO AND LS_MARC-EISBE.
          <LS_DAY>-STATUS = 'N'.
        ENDIF.

      ENDLOOP.


*    주별재고 계산
      LOOP AT <LS_CAT>-T_WEEK ASSIGNING FIELD-SYMBOL(<LS_WEEK>).
*     + 재고
        CLEAR LV_PLUS_STOCK.
        CLEAR GS_DIFINE_WEEK.
        READ TABLE GS_MATNR_MAIN-S_CAT-T_WEEK INTO GS_DIFINE_WEEK WITH KEY WEEK = <LS_WEEK>-WEEK.
        IF SY-SUBRC EQ 0.
          READ TABLE GT_2152 INTO LS_2152 WITH KEY SCRGRADE = <LS_MAIN>-ATWRT.
          IF SY-SUBRC EQ 0.
            IF GS_DIFINE_WEEK-GSMNG NE 0.
              LV_PLUS_STOCK = GS_DIFINE_WEEK-GSMNG * LS_2152-RATE / 100.
              PERFORM TRANSPER_ROUND CHANGING LV_PLUS_STOCK.
            ENDIF.
          ENDIF.
        ENDIF.

*     - 재고
        READ TABLE LS_CAT-T_WEEK INTO DATA(LS_WEEK_TEMP) WITH KEY WEEK = <LS_WEEK>-WEEK.
        IF SY-SUBRC EQ 0.
          LV_CAL_STOCK = LV_CAL_STOCK + LV_PLUS_STOCK + LS_WEEK_TEMP-GSMNG.
        ELSE.
          LV_CAL_STOCK = LV_CAL_STOCK + LV_PLUS_STOCK.
        ENDIF.

        <LS_WEEK>-GSMNG = LV_CAL_STOCK.

* - 계산된 예상 재고 수량이 MIN 보다 작으면 파란색 CELL 표시
        IF <LS_WEEK>-GSMNG < LS_MARC-EISLO.
          <LS_WEEK>-STATUS = 'L'.
          IF <LS_WEEK>-GSMNG < 0.
            <LS_WEEK>-STATUS = 'R'.
          ENDIF.
        ENDIF.
* - 계산된 예상 재고 수량이 Max 보다 많으면 주황색 Cell 표시
        IF <LS_WEEK>-GSMNG > LS_MARC-EISBE.
          <LS_WEEK>-STATUS = 'H'.
        ENDIF.

        IF <LS_WEEK>-GSMNG BETWEEN LS_MARC-EISLO AND LS_MARC-EISBE.
          <LS_WEEK>-STATUS = 'N'.
        ENDIF.

      ENDLOOP.

      LOOP AT GT_SPMON INTO GS_SPMON.
        CLEAR GS_DIFINE_SPMON.
        CLEAR LV_CAL_PSAMG.

        REFRESH : LT_DAY, LT_WEEK.

        LT_DAY = VALUE #( FOR LW_DAY IN <LS_CAT>-T_DAY WHERE ( DATE+0(6) = GS_SPMON-SPMON )
                                 ( CORRESPONDING #( LW_DAY ) ) ).

        IF LT_DAY[] IS NOT INITIAL.
          SORT LT_DAY BY DATE DESCENDING.
          READ TABLE LT_DAY INTO DATA(LS_DAY_CHK) INDEX 1.
          IF SY-SUBRC EQ 0.
            LV_CAL_PSAMG = LS_DAY_CHK-PSAMG.
          ENDIF.
        ELSE.
          LT_WEEK = VALUE #( FOR LW_WEEK IN GT_WEEK WHERE ( FRDATE+0(6) = GS_SPMON-SPMON )
                                 ( CORRESPONDING #( LW_WEEK ) ) ).
          IF LT_WEEK IS NOT INITIAL.
            SORT LT_WEEK BY FRDATE DESCENDING.
            CLEAR GS_WEEK.
            READ TABLE LT_WEEK INTO GS_WEEK INDEX 1.
            READ TABLE <LS_CAT>-T_WEEK INTO DATA(LS_WEEK_CHK) WITH KEY WEEK = GS_WEEK-WEEK.
            IF SY-SUBRC EQ 0.
              LV_CAL_PSAMG = LS_WEEK_CHK-GSMNG.
            ENDIF.

          ENDIF.
        ENDIF.

        IF LV_CAL_PSAMG NE 0.
          GS_DIFINE_SPMON-SPMON = GS_SPMON-SPMON.
          GS_DIFINE_SPMON-GSMNG = LV_CAL_PSAMG.
          APPEND GS_DIFINE_SPMON TO <LS_CAT>-T_SPMON.
        ENDIF.

      ENDLOOP.

    ENDLOOP.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_0100 .

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
  GO_GRID_0100->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0100 ).

  CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_MANUAL_USE_INPUT_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_MANUAL_USE_INPUT_PLAN .

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LT_CHG_DATE TYPE TABLE OF SY-DATUM.
  DATA : LT_CHG_WEEK TYPE TABLE OF SCAL-WEEK.
  DATA : LV_ROW TYPE I.
  DATA : LV_CHK_REL.
  DATA : LV_PSAMG TYPE CO_PSAMG.
  DATA : LV_CHK_ERR.

  GO_GRID_0100->GET_SELECTED_CELLS_ID(
        IMPORTING
         ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_CELLS[] IS INITIAL.
    RETURN.
  ENDIF.

  DATA(LT_CELL_CHK) = LT_CELLS.

  SORT LT_CELL_CHK BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CELL_CHK COMPARING ROW_ID.
  IF LINES( LT_CELL_CHK ) > 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산(수량입력) 은 한 라인만 처리 할 수 있습니다.'(e04).
    RETURN.
  ENDIF.

  SORT LT_CELLS BY COL_ID.

* 가용한 날짜 필드 인지 확인
  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    LV_ROW = LS_CELLS-ROW_ID.

    READ TABLE GT_FIELDCAT_0100 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.

    CLEAR GS_DATE.
    READ TABLE GT_DATE INTO GS_DATE WITH KEY DATE = LS_FCAT-FIELDNAME.
    IF SY-SUBRC EQ 0.

      IF GS_DATE-DATE < SY-DATUM.
        CONTINUE.
      ENDIF.

      COLLECT GS_DATE-DATE INTO LT_CHG_DATE.
    ELSE.
      CLEAR GS_WEEK.
      READ TABLE GT_WEEK INTO GS_WEEK WITH KEY WEEK = LS_FCAT-FIELDNAME.
      IF SY-SUBRC EQ 0.
        COLLECT GS_WEEK-WEEK INTO LT_CHG_WEEK.
      ELSE.
        MESSAGE S006 DISPLAY LIKE 'E' WITH LS_FCAT-REPTEXT '는(은) 생산(수량입력) 가능한 필드가 아닙니다.'(e05).
        RETURN.
      ENDIF.
    ENDIF.
  ENDLOOP.

* 생산수량 적용
  READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LV_ROW.
  CLEAR GS_MAIN.
  MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.

  READ TABLE GT_MATNR_MAIN ASSIGNING FIELD-SYMBOL(<LS_MAINTAIN>) WITH KEY MATNR = GS_MAIN-MATNR
                                                                                                                  SEQ_CATALOG = 7.

  ASSIGN <LS_MAINTAIN>-S_CAT TO FIELD-SYMBOL(<LS_CAT>).
* 릴리즈 상태 체크 확인 팝업 적용
  LOOP AT LT_CHG_DATE INTO DATA(LV_DATE).
    CLEAR GS_DIFINE_DAY.
    READ TABLE <LS_CAT>-T_DAY INTO GS_DIFINE_DAY WITH KEY DATE = LV_DATE
                                                                                        ORDER_STAT = 'D' .
    IF SY-SUBRC EQ 0.
      LV_CHK_REL = 'D'.
      EXIT.
    ENDIF.

    IF LV_CHK_REL IS INITIAL.
      READ TABLE <LS_CAT>-T_DAY INTO GS_DIFINE_DAY WITH KEY DATE = LV_DATE
                                                                                        ORDER_STAT = 'R' .
      IF SY-SUBRC EQ 0.
        LV_CHK_REL = ABAP_TRUE.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF LV_CHK_REL = 'D'.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더' GS_DIFINE_DAY-AUFNR '는 작업중으로 변경 불가능합니다.'.
    RETURN.
  ENDIF.

  IF LV_CHK_REL = ABAP_TRUE.
    CLEAR GV_ANSWER.
    PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
      ' '
      '릴리즈되어 작업지시된 생산 오더가 있습니다. 계속 작업하시겠습니까?'
      '작업확인'.
    IF GV_ANSWER NE 'J'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

* 유저 지정 계획수량
  PERFORM GET_PSAMG_POPUP CHANGING LV_PSAMG LV_CHK_ERR.
  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

* 수정 시작
  LOOP AT LT_CHG_DATE INTO LV_DATE.

    READ TABLE <LS_CAT>-T_DAY ASSIGNING FIELD-SYMBOL(<LS_DAY>) WITH KEY DATE = LV_DATE.
    IF SY-SUBRC EQ 0.
      IF <LS_DAY>-PSAMG NE LV_PSAMG.
        <LS_DAY>-CHANGE = ABAP_TRUE.
      ENDIF.

      <LS_DAY>-PSAMG = LV_PSAMG.

    ELSE. " 해달 날짜 조회가 없을경우 추가
      CLEAR GS_DIFINE_DAY.
      GS_DIFINE_DAY-DATE = LV_DATE.
      GS_DIFINE_DAY-CHANGE = ABAP_TRUE.
      GS_DIFINE_DAY-PSAMG = LV_PSAMG.

      INSERT GS_DIFINE_DAY INTO TABLE <LS_CAT>-T_DAY.

    ENDIF.
  ENDLOOP.

  LOOP AT LT_CHG_WEEK INTO DATA(LV_WEEK).

    READ TABLE <LS_CAT>-T_WEEK ASSIGNING FIELD-SYMBOL(<LS_WEEK>) WITH KEY WEEK = LV_WEEK.
    IF SY-SUBRC EQ 0.
      IF <LS_WEEK>-GSMNG NE LV_PSAMG.
        <LS_WEEK>-CHANGE = ABAP_TRUE.
      ENDIF.
      <LS_WEEK>-GSMNG = LV_PSAMG.
    ELSE. " 해달 날짜 조회가 없을경우 추가
      CLEAR GS_DIFINE_WEEK.
      GS_DIFINE_WEEK-WEEK = LV_WEEK.
      GS_DIFINE_WEEK-CHANGE = ABAP_TRUE.
      GS_DIFINE_WEEK-GSMNG = LV_PSAMG * 7.

      INSERT GS_DIFINE_WEEK INTO TABLE <LS_CAT>-T_WEEK.

    ENDIF.
  ENDLOOP.

  PERFORM SET_SPMON_FIELD CHANGING <LS_MAINTAIN>-S_CAT.
  UNASSIGN <LS_MAINTAIN>.

  PERFORM SET_CAL_STOCK.

  PERFORM SET_DISP_TABLE.

  PERFORM REFRESH_0100.

  GV_CHK_EDIT = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PSAMG_POPUP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_PSAMG
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM GET_PSAMG_POPUP  CHANGING PV_PLMNG  TYPE CO_PSAMG
                                   PV_CHK_ERR.

  DATA : LV_RETURN_CODE TYPE C.
  DATA : LT_FIELD TYPE TABLE OF SVAL.

  APPEND INITIAL LINE TO LT_FIELD ASSIGNING FIELD-SYMBOL(<LS_FIELD>).
  <LS_FIELD>-FIELDTEXT = '생산수량'.
  <LS_FIELD>-TABNAME = 'AFPO'.
  <LS_FIELD>-FIELDNAME = 'PSAMG'.
  <LS_FIELD>-FIELD_OBL = ABAP_TRUE.


  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      POPUP_TITLE     = '계획수량 입력'
*     START_COLUMN    = '5'
*     START_ROW       = '5'
    IMPORTING
      RETURNCODE      = LV_RETURN_CODE
    TABLES
      FIELDS          = LT_FIELD
    EXCEPTIONS
      ERROR_IN_FIELDS = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  IF LV_RETURN_CODE = 'A'. " 취소로 종료시
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.


  READ TABLE LT_FIELD INTO DATA(LS_FIELD) INDEX 1.
  PV_PLMNG = LS_FIELD-VALUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DEL_SELECTED_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DEL_SELECTED_PLAN .

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LT_CHG_DATE TYPE TABLE OF SY-DATUM.
  DATA : LT_CHG_WEEK TYPE TABLE OF SCAL-WEEK.
  DATA : LV_ROW TYPE I.
  DATA : LV_CHK_REL.

  GO_GRID_0100->GET_SELECTED_CELLS_ID(
        IMPORTING
         ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_CELLS[] IS INITIAL.
    RETURN.
  ENDIF.

  DATA(LT_CELL_CHK) = LT_CELLS.

  SORT LT_CELL_CHK BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CELL_CHK COMPARING ROW_ID.
  IF LINES( LT_CELL_CHK ) > 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '삭제는 한 라인만 처리 할 수 있습니다.'(e06).
    RETURN.
  ENDIF.

  SORT LT_CELLS BY COL_ID.

* 가용한 날짜 필드 인지 확인
  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    LV_ROW = LS_CELLS-ROW_ID.

    READ TABLE GT_FIELDCAT_0100 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.

    CLEAR GS_DATE.
    READ TABLE GT_DATE INTO GS_DATE WITH KEY DATE = LS_FCAT-FIELDNAME.
    IF SY-SUBRC EQ 0.

      IF GS_DATE-DATE < SY-DATUM.
        CONTINUE.
      ENDIF.

      COLLECT GS_DATE-DATE INTO LT_CHG_DATE.
    ELSE.
      CLEAR GS_WEEK.
      READ TABLE GT_WEEK INTO GS_WEEK WITH KEY WEEK = LS_FCAT-FIELDNAME.
      IF SY-SUBRC EQ 0.
        COLLECT GS_WEEK-WEEK INTO LT_CHG_WEEK.
      ELSE.
        MESSAGE S005 DISPLAY LIKE 'E' WITH LS_FCAT-REPTEXT '는(은) 삭제 가능한 필드가 아닙니다.'(e07).
        RETURN.
      ENDIF.
    ENDIF.
  ENDLOOP.

* 생산수량 적용
  READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LV_ROW.
  CLEAR GS_MAIN.
  MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.

  READ TABLE GT_MATNR_MAIN ASSIGNING FIELD-SYMBOL(<LS_MAINTAIN>) WITH KEY MATNR = GS_MAIN-MATNR
                                                                                                                  SEQ_CATALOG = 7.

  ASSIGN <LS_MAINTAIN>-S_CAT TO FIELD-SYMBOL(<LS_CAT>).
* 릴리즈 상태 체크 확인 팝업 적용
  LOOP AT LT_CHG_DATE INTO DATA(LV_DATE).
    CLEAR GS_DIFINE_DAY.
    READ TABLE <LS_CAT>-T_DAY INTO GS_DIFINE_DAY WITH KEY DATE = LV_DATE
                                                                                        ORDER_STAT = 'D' .
    IF SY-SUBRC EQ 0.
      LV_CHK_REL = 'D'.
      EXIT.
    ENDIF.

    IF LV_CHK_REL IS INITIAL.
      READ TABLE <LS_CAT>-T_DAY INTO GS_DIFINE_DAY WITH KEY DATE = LV_DATE.
      IF SY-SUBRC EQ 0 AND GS_DIFINE_DAY-AUFNR IS NOT INITIAL.
        LV_CHK_REL = ABAP_TRUE.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF LV_CHK_REL = 'D'.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더' GS_DIFINE_DAY-AUFNR '는 작업중으로 변경 불가능합니다.'.
    RETURN.
  ENDIF.

  IF LV_CHK_REL = ABAP_TRUE.
    CLEAR GV_ANSWER.
    PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
      ' '
      '기존 생성된 생산 오더가 존재합니다. 저장 시 기존 생산오더는 삭제됩니다. 계속 작업하시겠습니까?'
      '작업확인'.
    IF GV_ANSWER NE 'J'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

* 삭제 시작
  LOOP AT LT_CHG_DATE INTO LV_DATE.

    READ TABLE <LS_CAT>-T_DAY ASSIGNING FIELD-SYMBOL(<LS_DAY>) WITH KEY DATE = LV_DATE.
    IF SY-SUBRC EQ 0.
      IF <LS_DAY>-AUFNR IS NOT INITIAL. " 기존 생산오더 존재시 삭제 테이블 이관후 삭제
        LOOP AT GT_AFPO INTO GS_AFPO WHERE MATNR = GS_MAIN-MATNR
                                                       AND GSTRP = <LS_DAY>-DATE.

          APPEND GS_AFPO-AUFNR TO GT_DEL_AUFNR.
        ENDLOOP.
      ENDIF.
      DELETE <LS_CAT>-T_DAY WHERE DATE = LV_DATE.
    ENDIF.
  ENDLOOP.

  LOOP AT LT_CHG_WEEK INTO DATA(LV_WEEK).

    READ TABLE <LS_CAT>-T_WEEK ASSIGNING FIELD-SYMBOL(<LS_WEEK>) WITH KEY WEEK = LV_WEEK.
    IF SY-SUBRC EQ 0.
      IF <LS_WEEK>-PLNUM IS NOT INITIAL. " 기존 계획오더 존재시 삭제 테이블 이관후 삭제
        APPEND <LS_WEEK>-PLNUM TO GT_DEL_PLAF.
      ENDIF.
      DELETE <LS_CAT>-T_WEEK WHERE WEEK = LV_WEEK.
    ENDIF.
  ENDLOOP.

  PERFORM SET_SPMON_FIELD CHANGING <LS_MAINTAIN>-S_CAT.
  UNASSIGN <LS_MAINTAIN>.

  PERFORM SET_CAL_STOCK.

  PERFORM SET_DISP_TABLE.

  PERFORM REFRESH_0100.

  GV_CHK_EDIT = ABAP_TRUE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DEL_LINES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DEL_LINES .

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_CHK_REL.

  GO_GRID_0100->GET_SELECTED_CELLS_ID(
        IMPORTING
         ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_CELLS[] IS INITIAL.
    RETURN.
  ENDIF.

  DATA(LT_CELL_CHK) = LT_CELLS.

  SORT LT_CELL_CHK BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CELL_CHK COMPARING ROW_ID.
  IF LINES( LT_CELL_CHK ) > 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '삭제는 한 라인만 처리 할 수 있습니다.'(e06).
    RETURN.
  ENDIF.

  SORT LT_CELLS BY COL_ID.

  READ TABLE LT_CELLS INTO DATA(LS_CELLS) INDEX 1.

* 생산수량 적용
  READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_CELLS-ROW_ID.
  CLEAR GS_MAIN.
  MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.

  READ TABLE GT_MATNR_MAIN ASSIGNING FIELD-SYMBOL(<LS_MAINTAIN>) WITH KEY MATNR = GS_MAIN-MATNR
                                                                                                                  SEQ_CATALOG = 7.

  ASSIGN <LS_MAINTAIN>-S_CAT TO FIELD-SYMBOL(<LS_CAT>).
* 릴리즈 상태 체크 확인 팝업 적용
  LOOP AT <LS_CAT>-T_DAY INTO GS_DIFINE_DAY.
    IF GS_DIFINE_DAY-ORDER_STAT = 'D' .
      READ TABLE GT_FIELDCAT_0100 INTO DATA(LS_FCAT) WITH KEY FIELDNAME = GS_DIFINE_DAY-DATE.
      LV_CHK_REL = 'D'.
      EXIT.
    ENDIF.

    IF GS_DIFINE_DAY-AUFNR IS NOT INITIAL.
      LV_CHK_REL = ABAP_TRUE.
    ENDIF.
  ENDLOOP.

  IF LV_CHK_REL = 'D'.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더' GS_DIFINE_DAY-AUFNR '는 작업중으로 변경 불가능합니다.'.
    RETURN.
  ENDIF.

  IF LV_CHK_REL = ABAP_TRUE.
    CLEAR GV_ANSWER.
    PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
      ' '
      '기존 생성된 생산 오더가 존재합니다. 저장 시 기존 생산오더는 삭제됩니다. 계속 작업하시겠습니까?'
      '작업확인'.
    IF GV_ANSWER NE 'J'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

* 삭제 시작
  LOOP AT <LS_CAT>-T_DAY ASSIGNING FIELD-SYMBOL(<LS_DAY>).

    IF <LS_DAY>-DATE < SY-DATUM.
      CONTINUE.
    ENDIF.

    IF <LS_DAY>-AUFNR IS NOT INITIAL. " 기존 생산오더 존재시 삭제 테이블 이관후 삭제
      LOOP AT GT_AFPO INTO GS_AFPO WHERE MATNR = GS_MAIN-MATNR
                                                       AND GSTRP = <LS_DAY>-DATE.

        APPEND GS_AFPO-AUFNR TO GT_DEL_AUFNR.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
  REFRESH <LS_CAT>-T_DAY.


  LOOP AT <LS_CAT>-T_WEEK ASSIGNING FIELD-SYMBOL(<LS_WEEK>).
    IF <LS_WEEK>-PLNUM IS NOT INITIAL. " 기존 계획오더 존재시 삭제 테이블 이관후 삭제
      APPEND <LS_WEEK>-PLNUM TO GT_DEL_PLAF.
    ENDIF.
  ENDLOOP.
  REFRESH <LS_CAT>-T_WEEK.

  PERFORM SET_SPMON_FIELD CHANGING <LS_MAINTAIN>-S_CAT.
  UNASSIGN <LS_MAINTAIN>.

  PERFORM SET_CAL_STOCK.

  PERFORM SET_DISP_TABLE.

  PERFORM REFRESH_0100.

  GV_CHK_EDIT = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_SAVE .

  DATA : LV_CHK_ERR.
  REFRESH GT_WP_SEND.
* 저장 Process
* 1. 삭제 처리된 생산오더 삭제
* 2. 일자에 세팅된 계획 오더, 삭제처리된 삭제
* 3. 일자에 수립된 수량으로 생산오더 생성 및 기존 생산오더 변경
* 4. 주차에 수립된 수량으로 계획오더 생성 및 기존 계획오더 변경

  PERFORM SET_INDICATOR USING '1' '생산계획 저장 시작..'.
* 1. 삭제 처리된 생산오더 삭제
  PERFORM DELETE_AUFNR CHANGING LV_CHK_ERR.
  CHECK LV_CHK_ERR IS INITIAL.
* 2. 일자에 세팅된 계획 오더, 삭제처리된 삭제
  PERFORM DELETE_PLNUM CHANGING LV_CHK_ERR.
  CHECK LV_CHK_ERR IS INITIAL.

  PERFORM SET_INDICATOR USING '20' '생산계획 저장 중...'.
* 3. 일자에 수립된 수량으로 생산오더 생성 및 기존 생산오더 변경
  PERFORM SET_PO_FOR_PLAN CHANGING LV_CHK_ERR.

  PERFORM SET_INDICATOR USING '70' '생산계획 저장 중...'.
* 4. 주차에 수립된 수량으로 계획오더 생성 및 기존 계획오더 변경
  PERFORM SET_PLAF_FOR_PLAN CHANGING LV_CHK_ERR.

* 5. 2. 생산 계획 저장 시 RTO 저장(일자, 자재, 등급 기준)
  PERFORM SET_INDICATOR USING '90' 'RTO 저장 중...'.
  PERFORM SET_RTO CHANGING LV_CHK_ERR.

  PERFORM SET_INDICATOR USING '99' '생산계획 저장완료.'.

* 6. 일자별 가동시간 IF데이터 구성
  PERFORM SET_DAILY_OPERATING_HOURS.

  IF GT_WP_SEND IS NOT INITIAL.
    PERFORM SEND_TO_MES TABLES GT_WP_SEND.
  ENDIF.

* 대상정보 추출.
  PERFORM GET_DATA.

* 대상정보 추출.
  PERFORM SET_DISP_TABLE.

  PERFORM REFRESH_0100.

  CLEAR : GV_CHK_EDIT.
  MESSAGE S006 WITH '생산계획 저장완료'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_INDICATOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_INDICATOR  USING    PV_PERCENTAGE
                             PV_TEXT.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      PERCENTAGE = PV_PERCENTAGE                 "indicator에 진행률(%)
      TEXT       = PV_TEXT.  "텍스트 표시

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_AUFNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELETE_AUFNR CHANGING PV_CHK_ERR.

  CHECK GT_DEL_AUFNR[] IS NOT INITIAL.

  DATA : LT_ORDERS TYPE TABLE OF BAPI_ORDER_KEY.
  DATA : LS_RETURN TYPE BAPIRET2.
  DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.

  LOOP AT GT_DEL_AUFNR INTO DATA(LS_AUFNR).
    APPEND INITIAL LINE TO LT_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDERS>).
    <LS_ORDERS>-ORDER_NUMBER = LS_AUFNR-AUFNR.
  ENDLOOP.

* 삭제처리
  CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
    IMPORTING
      RETURN        = LS_RETURN
    TABLES
      ORDERS        = LT_ORDERS
      DETAIL_RETURN = LT_DETAIL_RETURN.

  IF LINE_EXISTS( LT_DETAIL_RETURN[ TYPE = 'E' ] ).
    ROLLBACK WORK.
    PV_CHK_ERR = ABAP_TRUE.
    READ TABLE LT_DETAIL_RETURN INTO DATA(LS_DETAIL_RETURN) WITH KEY TYPE = 'E'.
    MESSAGE ID LS_DETAIL_RETURN-ID TYPE 'S' NUMBER LS_DETAIL_RETURN-NUMBER
          WITH LS_DETAIL_RETURN-MESSAGE_V1
               LS_DETAIL_RETURN-MESSAGE_V2
               LS_DETAIL_RETURN-MESSAGE_V3
               LS_DETAIL_RETURN-MESSAGE_V4
          DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = ABAP_TRUE.

* 삭제 완료시 대상에서 삭제
  REFRESH GT_DEL_AUFNR.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_PLNUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM DELETE_PLNUM  CHANGING PV_CHK_ERR.

  CHECK GT_DEL_PLAF[] IS NOT INITIAL.

  DATA : LV_PLANNEDORDER TYPE BAPI_PLDORD-PLDORD_NUM.
  DATA : LS_RETURN TYPE BAPIRETURN1.

  LOOP AT GT_DEL_PLAF INTO DATA(LS_PLAF).
    CLEAR : LV_PLANNEDORDER, LS_RETURN.

    PERFORM SET_IF_DATA_FR_PLNUM USING LS_PLAF-PLNUM 0.
    LV_PLANNEDORDER = LS_PLAF-PLNUM.
    CALL FUNCTION 'BAPI_PLANNEDORDER_DELETE'
      EXPORTING
        PLANNEDORDER = LV_PLANNEDORDER
      IMPORTING
        RETURN       = LS_RETURN.

    IF NOT ( LS_RETURN-TYPE EQ 'S' OR LS_RETURN-TYPE EQ '' ).
      CLEAR GS_PLAF.
      READ TABLE GT_PLAF INTO GS_PLAF WITH KEY PLNUM = LV_PLANNEDORDER.
      MESSAGE S006 DISPLAY LIKE 'E' WITH GS_PLAF-PSTTR 'Planned Order 삭제오류'.
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = ABAP_TRUE.

* 삭제 완료시 대상에서 삭제
  REFRESH GT_DEL_PLAF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PO_FOR_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_PO_FOR_PLAN  CHANGING PV_CHK_ERR.



  LOOP AT GT_MATNR_MAIN INTO GS_MATNR_MAIN WHERE SEQ_CATALOG = 7.
*   생산 계획 수량만 확인
    LOOP AT GS_MATNR_MAIN-S_CAT-T_DAY INTO GS_DIFINE_DAY.
* 기존 생산오더 존재건중 수정 마킹된 필드 확인, 생산오더 변경
      IF GS_DIFINE_DAY-AUFNR IS NOT INITIAL AND GS_DIFINE_DAY-CHANGE = ABAP_TRUE.
        PERFORM CHANGE_PO USING GS_DIFINE_DAY-AUFNR GS_DIFINE_DAY-PSAMG CHANGING PV_CHK_ERR.

        IF PV_CHK_ERR IS NOT INITIAL.
          RETURN.
        ENDIF.

        CONTINUE.
      ENDIF.

* 신규 계획 수량 입력건, 생산오더 생성
      IF GS_DIFINE_DAY-AUFNR IS INITIAL AND GS_DIFINE_DAY-PSAMG NE 0.

        PERFORM CREATE_PO USING GS_DIFINE_DAY GS_MATNR_MAIN CHANGING PV_CHK_ERR.

        IF PV_CHK_ERR IS NOT INITIAL.
          RETURN.
        ENDIF.

      ENDIF.

    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DIFINE_DAY_AUFNR
*&      --> GS_DIFINE_DAY_PSAMG
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHANGE_PO  USING    PV_AUFNR TYPE AUFNR
                                       PV_PSAMG TYPE CO_PSAMG
                         CHANGING PV_CHK_ERR.

  DATA : LV_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.
  DATA : LS_ORDERDATA TYPE BAPI_PP_ORDER_CHANGE.
  DATA : LS_ORDERDATAX TYPE BAPI_PP_ORDER_CHANGEX.
  DATA : LS_RETURN TYPE BAPIRET2.

  READ TABLE GT_AFPO INTO GS_AFPO WITH KEY AUFNR = PV_AUFNR.
  IF SY-SUBRC EQ 0.
    IF PV_PSAMG NE GS_AFPO-GAMNG. "수량이 틀리면 변경

      LV_NUMBER = PV_AUFNR.
      LS_ORDERDATA-QUANTITY = PV_PSAMG.
      LS_ORDERDATAX-QUANTITY = ABAP_TRUE.

      CALL FUNCTION 'BAPI_PRODORD_CHANGE'
        EXPORTING
          NUMBER     = LV_NUMBER
          ORDERDATA  = LS_ORDERDATA
          ORDERDATAX = LS_ORDERDATAX
        IMPORTING
          RETURN     = LS_RETURN.

      IF LS_RETURN-TYPE NE 'E'.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.
        WAIT UP TO 1 SECONDS.
      ELSE.
        ROLLBACK WORK.
        MESSAGE S006 DISPLAY LIKE 'E' WITH 'Production Order' LV_NUMBER '수정오류'.
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DIFINE_DAY_AUFNR
*&      --> GS_DIFINE_DAY_PSAMG
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CREATE_PO  USING    PS_DIFINE_DAY LIKE GS_DIFINE_DAY
                                       PS_MAINTAIN       LIKE GS_MATNR_MAIN
                         CHANGING PV_CHK_ERR.

  DATA : LS_ORDER TYPE BAPI_PP_ORDER_CREATE.
  DATA : LS_RETURN TYPE BAPIRET2.
  DATA : LV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.

*  오더 생성
  LS_ORDER-MATERIAL = PS_MAINTAIN-MATNR.
  LS_ORDER-PLANT = P_WERKS.
  LS_ORDER-ORDER_TYPE = 'PP01'.
  LS_ORDER-BASIC_START_DATE = PS_DIFINE_DAY-DATE.
  LS_ORDER-BASIC_END_DATE = PS_DIFINE_DAY-DATE.
  LS_ORDER-QUANTITY = PS_DIFINE_DAY-PSAMG.
  LS_ORDER-BASIC_SCHEDULING_TYPE = '3'.

  CALL FUNCTION 'BAPI_PRODORD_CREATE'
    EXPORTING
      ORDERDATA    = LS_ORDER
    IMPORTING
      RETURN       = LS_RETURN
      ORDER_NUMBER = LV_ORDER_NUMBER.

*  등급 특성값으로 모디
  IF LS_RETURN-TYPE NE 'E'.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

*      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
    DO .
      SELECT SINGLE AUFNR, POSNR
        FROM AFPO
       WHERE AUFNR = @LV_ORDER_NUMBER
        INTO @DATA(LS_AFPO).
      IF SY-SUBRC EQ 0.
        EXIT.
      ELSE.
        WAIT UP TO '0.1' SECONDS.
      ENDIF.
    ENDDO.

* 특성값 생성 없음
*    PERFORM SET_BDC_CO02 USING LV_ORDER_NUMBER PS_MAINTAIN-ATWRT CHANGING PV_CHK_ERR.
    IF PV_CHK_ERR = ABAP_TRUE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH  PS_DIFINE_DAY-DATE 'Production Order 생성 오류' '- 등급지정'.
      RETURN.
    ENDIF.

  ELSE.
    MESSAGE S006 DISPLAY LIKE 'E' WITH  PS_DIFINE_DAY-DATE 'Production Order 생성 오류'.
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BDC_CO02
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ORDER_NUMBER
*&      --> PS_MAINTAIN_ATWRT
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM SET_BDC_CO02  USING    PV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER
                                            PV_GRADE
                             CHANGING  PV_CHK_ERR.

  DATA : LV_TEXT(10).
  LV_TEXT = PV_GRADE.
  REFRESH : GT_BDCDATA, GT_MESSTAB.

  __SETTING_BDC_PARAMS.

  __BDC_DYNPRO 'SAPLCOKO1' '0110'.
  __BDC_FIELD : 'CAUFVD-AUFNR' PV_ORDER_NUMBER,
                      'R62CLORD-FLG_OVIEW'  'X',
                      'BDC_OKCODE' '=ENTK'.

  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD : 'BDC_OKCODE' '=KOTA'. " 빠른입력화면으로 전환

  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_SEL_ALL'.

  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_CONFIG'.

  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_CONFIG'.

  __BDC_DYNPRO 'SAPLCEI0' '0109'.
  __BDC_FIELD : 'BDC_OKCODE' '=BACK',
                      'RCTMS-MNAME(01)' 'SCR Grade',
                      'RCTMS-MWERT(01)' LV_TEXT. "

  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD : 'BDC_OKCODE' '=BU'.

  __BDC_TRANSACTION 'CO02'.
  LOOP AT GT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'A'
                                                         OR MSGTYP = 'E'
                                                         OR MSGTYP = 'X'.
    PV_CHK_ERR = 'E'.
    RETURN.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PLAF_FOR_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM SET_PLAF_FOR_PLAN  CHANGING PV_CHK_ERR.

  LOOP AT GT_MATNR_MAIN INTO GS_MATNR_MAIN  WHERE SEQ_CATALOG = 7.
*   생산 계획 수량만 확인
    LOOP AT GS_MATNR_MAIN-S_CAT-T_WEEK INTO GS_DIFINE_WEEK.
* 기존 생산오더 존재건중 수정 마킹된 필드 확인, 생산오더 변경
      IF GS_DIFINE_WEEK-PLNUM IS NOT INITIAL AND GS_DIFINE_DAY-CHANGE = ABAP_TRUE.
        PERFORM CHANGE_PLAF USING GS_DIFINE_WEEK-PLNUM GS_DIFINE_WEEK-GSMNG CHANGING PV_CHK_ERR.

        IF PV_CHK_ERR IS NOT INITIAL.
          RETURN.
        ENDIF.

        CONTINUE.
      ENDIF.

* 신규 계획 수량 입력건, 생산오더 생성
      IF GS_DIFINE_WEEK-PLNUM IS INITIAL AND GS_DIFINE_DAY-PSAMG NE 0.

        PERFORM CREATE_PLAF USING GS_DIFINE_WEEK GS_MATNR_MAIN CHANGING PV_CHK_ERR.

        IF PV_CHK_ERR IS NOT INITIAL.
          RETURN.
        ENDIF.

      ENDIF.

    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_PLAF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DIFINE_WEEK_PLNUM
*&      --> GS_DIFINE_WEEK_GSMNG
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHANGE_PLAF  USING    PV_PLNUM
                                          PV_GSMNG
                           CHANGING  PV_CHK_ERR.

  DATA : LV_PLANNEDORDER TYPE BAPI_PLDORD-PLDORD_NUM.
  DATA : LS_HEADER TYPE BAPIPLAF_I2.
  DATA : LS_HEADERX TYPE BAPIPLAF_I2X.
  DATA : LS_RETURN TYPE BAPIRETURN1.

  READ TABLE GT_PLAF INTO GS_PLAF WITH KEY PLNUM = PV_PLNUM.
  IF SY-SUBRC EQ 0.
    IF GS_PLAF-GSMNG NE PV_GSMNG. " 수량이 틀릴경우에만 계획오더 변경

      LV_PLANNEDORDER = PV_PLNUM.
      LS_HEADER-TOTAL_PLORD_QTY = PV_GSMNG.
      LS_HEADERX-TOTAL_PLORD_QTY = ABAP_TRUE.

      CALL FUNCTION 'BAPI_PLANNEDORDER_CHANGE'
        EXPORTING
          PLANNEDORDER = LV_PLANNEDORDER
          HEADERDATA   = LS_HEADER
          HEADERDATAX  = LS_HEADERX
        IMPORTING
          RETURN       = LS_RETURN.

      IF LS_RETURN-TYPE NE 'S'. "성공건에 대해 후행 로직 진행
        MESSAGE S006 DISPLAY LIKE 'E' WITH GS_PLAF-PSTTR 'Planned Order 변경오류'.
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.

        PERFORM SET_IF_DATA_FR_PLNUM USING LV_PLANNEDORDER PV_GSMNG.
      ENDIF.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PLAF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DIFINE_WEEK
*&      --> GS_MAINTAIN_MAIN
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CREATE_PLAF  USING    PS_DIFINE_WEEK LIKE GS_DIFINE_WEEK
                                         PS_MAINTAIN_MAIN LIKE GS_MATNR_MAIN
                         CHANGING   PV_CHK_ERR.


  DATA : LS_HEADERDATA TYPE BAPIPLAF_I1.
  DATA : LV_PLANNEDORDER TYPE BAPI_PLDORD-PLDORD_NUM.
  DATA : LS_RETURN TYPE BAPIRETURN1.

  LS_HEADERDATA-PLDORD_PROFILE  = 'LA'.
  LS_HEADERDATA-MATERIAL = PS_MAINTAIN_MAIN-MATNR.
*   조장구성 플랜트
  LS_HEADERDATA-PLAN_PLANT = P_WERKS.
  LS_HEADERDATA-PROD_PLANT = P_WERKS.
  LS_HEADERDATA-FIRMING_IND = 'X'.
*  LS_HEADERDATA-PLDORD_TEXT = PS_MAINTAIN_MAIN-ATWRT.

  READ TABLE GT_WEEK INTO GS_WEEK WITH KEY WEEK = PS_DIFINE_WEEK-WEEK.
  IF SY-SUBRC EQ 0.
    LS_HEADERDATA-ORDER_START_DATE = GS_WEEK-FRDATE. " 해당주의 시작일로 계획오더  시작일자 세팅
    LS_HEADERDATA-ORDER_FIN_DATE = GS_WEEK-FRDATE. " 오더 시작일과 동일
  ELSE.
    MESSAGE S006 DISPLAY LIKE 'E' WITH PS_DIFINE_WEEK-WEEK '주차' 'Planned Order 생성오류'.
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LS_HEADERDATA-TOTAL_PLORD_QTY = PS_DIFINE_WEEK-GSMNG.

  CALL FUNCTION 'BAPI_PLANNEDORDER_CREATE'
    EXPORTING
      HEADERDATA   = LS_HEADERDATA
    IMPORTING
      RETURN       = LS_RETURN
      PLANNEDORDER = LV_PLANNEDORDER.

  IF LS_RETURN-TYPE NE 'S'. "성공건에 대해 후행 로직 진행
    MESSAGE S006 DISPLAY LIKE 'E' WITH PS_DIFINE_WEEK-WEEK '주차' 'Planned Order 생성오류'.
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    PERFORM SET_IF_DATA_FR_PLNUM USING LV_PLANNEDORDER PS_DIFINE_WEEK-GSMNG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VIEW_2150
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VIEW_2150 .

  DATA : LT_2150 TYPE TABLE OF ZGTPPT2150.

  REFRESH GT_2150.
  SELECT * FROM ZGTPPT2150
    INTO TABLE LT_2150
   WHERE WERKS = P_WERKS
     AND SPGCD = P_SPGCD
     AND PLDAT >= S_DATE-LOW.

  GT_2150_MAINTAIN = LT_2150.

  CALL SCREEN 200 STARTING AT 5 5 ENDING AT 85 15.

  IF GT_2150_MAINTAIN[] IS NOT INITIAL.
    DELETE ZGTPPT2150 FROM TABLE LT_2150.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
      MODIFY ZGTPPT2150 FROM TABLE GT_2150_MAINTAIN.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.

    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '[소재] 일자별 가동시간 업데이트 중 오류 발생하였습니다'.
      RETURN.
    ENDIF.
  ENDIF.

  PERFORM GET_INIT_INFOR.

  PERFORM SET_DISP_TABLE.

  PERFORM REFRESH_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CLEAR GV_OK_CODE2.
  GV_OK_CODE2 = SY-UCOMM.

  CASE GV_OK_CODE2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      REFRESH GT_2150_MAINTAIN.
*     종료
      CALL METHOD GO_CONTAIN_0200->FREE.

      FREE : GO_CONTAIN_0200.
      FREE : GO_GRID_0200.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      CLEAR GV_CHK_ERR.
      PERFORM CHECK_BEFORE_SAVE_2150.

      CHECK GV_CHK_ERR IS INITIAL.

*     종료
      CALL METHOD GO_CONTAIN_0200->FREE.
      FREE : GO_CONTAIN_0200.
      FREE : GO_GRID_0200.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0200 .

  CREATE OBJECT GO_CONTAIN_0200
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

  CREATE OBJECT GO_GRID_0200
    EXPORTING
      I_PARENT      = GO_CONTAIN_0200
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0200 .

  CLEAR GS_LAYOUT_0200.
  GS_LAYOUT_0200-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0200-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0200-SEL_MODE  = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0200 .

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_POS_NO TYPE I.
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = 'ZGTPPT2150'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0200.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0200[]
    TABLES
      IT_DATA         = GT_2150_MAINTAIN
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0200 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'(f08).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'SPGCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SPG'(f09).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PLDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획일'(f10).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'OPRTIM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '가동시간'(f11).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'MANDT' OR 'ERDAT' OR 'ERNAM' OR 'AEDAT' OR 'AENAM'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0200 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0200
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_DESELECT_ALL,
                CL_GUI_ALV_GRID=>MC_FC_DETAIL,
                CL_GUI_ALV_GRID=>MC_FC_SELECT_ALL,
                CL_GUI_ALV_GRID=>MC_FC_DELETE_FILTER,
                CL_GUI_ALV_GRID=>MC_FC_FILTER,
                CL_GUI_ALV_GRID=>MC_FC_SORT_ASC,
                CL_GUI_ALV_GRID=>MC_FC_SORT_DSC,
                CL_GUI_ALV_GRID=>MC_FC_SUBTOT,
                CL_GUI_ALV_GRID=>MC_FC_SUM,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FG_SORT,
                CL_GUI_ALV_GRID=>MC_MB_SUM,
*                CL_GUI_ALV_GRID=>MC_MB_VARIANT,
                CL_GUI_ALV_GRID=>MC_MB_VIEW,
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
*& Form CALL_GRID_0200_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0200_DISPLAY .

  CALL METHOD GO_GRID_0200->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0200
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0200
    CHANGING
      IT_OUTTAB            = GT_2150_MAINTAIN
      IT_FIELDCATALOG      = GT_FIELDCAT_0200.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0200->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0200->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_VBAP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_VBAP .

  DATA : LV_DISPO TYPE MARC-DISPO.

  LV_DISPO = P_SPGCD && '%'.

  SELECT  K~VBELN, P~POSNR, P~MATNR, P~VRKME,
          P~KWMENG, "판매단위 수량
          A~EDATU, P~CUOBJ
    FROM VBEP AS A
      INNER JOIN VBAK AS K  ON K~VBELN = A~VBELN
      INNER JOIN VBAP AS P  ON P~VBELN = A~VBELN
                            AND P~POSNR = A~POSNR
      INNER JOIN MARC AS C  ON C~MATNR = P~MATNR
   WHERE A~EDATU IN @S_DATE
     AND K~VBTYP IN ( 'B', 'C', 'I' ) "B  견적,C  오더,I  오더(무상)
     AND CONCAT( CONCAT( A~VBELN, A~POSNR ), A~ETENR ) IN
          ( SELECT CONCAT( CONCAT( VBELN, POSNR ), MAX( ETENR ) )
              FROM VBEP
             WHERE VBELN  = A~VBELN
               AND POSNR  = A~POSNR
               AND WMENG  NE 0
            GROUP BY VBELN, POSNR )
     AND CONCAT( P~VBELN, P~POSNR ) NOT IN
          ( SELECT CONCAT( VBELN, POSNR )
              FROM VBEP
             WHERE VBELN  = A~VBELN
               AND POSNR  = A~POSNR
               AND ETTYP  = 'CN'
               AND EDATU  = ( SELECT MAX( EDATU ) AS EDATU
                                FROM VBEP
                               WHERE VBELN = A~VBELN
                                 AND POSNR = A~POSNR
                              GROUP BY VBELN, POSNR ) )
     AND P~ABGRU IS INITIAL
     AND P~MATNR IN @S_MATNR
     AND C~WERKS = @P_WERKS
     AND C~DISPO LIKE @LV_DISPO
    INTO CORRESPONDING FIELDS OF TABLE @GT_VBAP.

* 특성값 세팅
  LOOP AT GT_VBAP ASSIGNING FIELD-SYMBOL(<LS_VBAP>).
*    등급
    ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
      EXPORTING
        IV_CUOBJ      = <LS_VBAP>-CUOBJ                 " 구성
      IMPORTING
        EV_GRADE = <LS_VBAP>-ATWRT  ).

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INSERT_LINE_SCREEN200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INSERT_LINE_SCREEN200 .

  APPEND INITIAL LINE TO GT_2150_MAINTAIN ASSIGNING FIELD-SYMBOL(<LS_2150>).
  <LS_2150>-SPGCD = P_SPGCD.
  <LS_2150>-WERKS = P_WERKS.
  <LS_2150>-AEDAT = SY-DATUM.
  <LS_2150>-ERDAT = SY-DATUM.
  <LS_2150>-ERNAM = SY-UNAME.
  <LS_2150>-AENAM = SY-UNAME.

  PERFORM REFRESH_GRID USING GO_GRID_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_LINE_SCREEN200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELETE_LINE_SCREEN200 .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.

  CALL METHOD GO_GRID_0200->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  IF LT_ROW[] IS INITIAL.
    MESSAGE S005 DISPLAY LIKE 'E' WITH '선택된 라인이 없습니다.'.
  ENDIF.

*  딜리트는 역순으로 진행
  SORT LT_ROW BY INDEX DESCENDING.

  LOOP AT LT_ROW INTO LS_ROW.
    DELETE GT_2150_MAINTAIN INDEX LS_ROW-INDEX.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0200
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID..

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_SCROLL.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> ER_DATA_CHANGED
*&      --> E_ONF4
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM DATA_CHANGED  USING    P_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                PO_DATA_CHANGED TYPE REF TO
                                          CL_ALV_CHANGED_DATA_PROTOCOL
                                PE_ONF4
                                PE_UCOMM.

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_CHK_ERR.

  DEFINE __SET_ERR_MSG.
    lv_chk_err = abap_true.
    po_data_changed->add_protocol_entry(
        i_msgid     = 'ZGTPP00'                 " Message ID
        i_msgty     = 'E'                 " Message Type
        i_msgno     =  '03'                " Message No.
        i_msgv1     =  &1                " Message Variable1
        i_fieldname =  &2                " Field Name
        i_row_id    =  ls_mod_cells-row_id ).                " RowID
  END-OF-DEFINITION.

  DEFINE __MODI_CELL.
    po_data_changed->modify_cell(
      i_row_id     = ls_mod_cells-row_id               " Row ID
      i_fieldname = &1                 " Field Name
      i_value       = &2 ).               " Value
  END-OF-DEFINITION.

  CASE P_SENDER.
    WHEN GO_GRID_0200.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'PLDAT'.
            __MODI_CELL : 'AENAM' SY-UNAME,
                                 'AEDAT' SY-DATUM.

          WHEN 'OPRTIM'.
            LV_NUM = LS_MOD_CELLS-VALUE.
            IF NOT LV_NUM BETWEEN 0 AND 24.
              __SET_ERR_MSG '가동시간은 0 ~ 24시 입니다.' 'OPRTIM'.
            ENDIF.

        ENDCASE.
      ENDLOOP.
    WHEN GO_GRID_0300.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'GAMNG'.
            __MODI_CELL : 'STATUS' ICON_CHANGE.
        ENDCASE.
      ENDLOOP.

    WHEN GO_GRID_0400.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        __MODI_CELL : 'STATUS' ICON_CHANGE.
      ENDLOOP.

  ENDCASE.

  IF LV_CHK_ERR IS NOT INITIAL.
    PO_DATA_CHANGED->DISPLAY_PROTOCOL( ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BEFORE_SAVE_2150
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_SAVE_2150 .

  LOOP AT GT_2150_MAINTAIN INTO DATA(LS_2150).
    IF LS_2150-PLDAT IS INITIAL OR LS_2150-PLDAT = '00000000'.
      GV_CHK_ERR = ABAP_TRUE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '계획일이 비어있습니다.'.
      RETURN.
    ENDIF.

    IF NOT LS_2150-OPRTIM BETWEEN 0 AND 24.
      GV_CHK_ERR = ABAP_TRUE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '가동시간 범위는 0 ~ 24 시간입니다.'.
      RETURN.
    ENDIF.

  ENDLOOP.

  DATA(LT_CHK_SORT) = GT_2150_MAINTAIN.
  SORT LT_CHK_SORT BY PLDAT.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_SORT COMPARING PLDAT.
  IF SY-SUBRC EQ 0.
    GV_CHK_ERR = ABAP_TRUE.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '계획일자는 중복 될 수 없습니다.'.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_AUTO_REALEASE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_AUTO_REALEASE .

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LT_ORDERS TYPE TABLE OF BAPI_ORDER_KEY.
  DATA : LT_ORDERS2 TYPE TABLE OF BAPI_ORDER_KEY.
  DATA : LS_ORDERS TYPE BAPI_ORDER_KEY.
  DATA : LT_RETURN TYPE BAPI_ORDER_RETURN_TT.

  IF GV_CHK_EDIT IS NOT INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '변경된 데이터가 있습니다. 생산계획 저장 후 릴리즈 하세요.'.
  ENDIF.

  GO_GRID_0100->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_CELLS[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '선택된 데이터가 없습니다.'.
    RETURN.
  ENDIF.

* 가용한 날짜 필드 인지 확인
  LOOP AT LT_CELLS INTO DATA(LS_CELLS).

    READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_CELLS-ROW_ID.
    CLEAR GS_MAIN.
    MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.
    IF GS_MAIN-SEQ_CATALOG EQ 7.
      READ TABLE GT_FIELDCAT_0100 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
      CLEAR GS_DATE.
      READ TABLE GT_DATE INTO GS_DATE WITH KEY DATE = LS_FCAT-FIELDNAME.
      IF SY-SUBRC EQ 0.
        IF GS_DATE-DATE < SY-DATUM.
          CONTINUE.
        ENDIF.

        CLEAR GS_MATNR_MAIN.
        READ TABLE GT_MATNR_MAIN INTO GS_MATNR_MAIN WITH KEY MATNR = GS_MAIN-MATNR
                                                                                           SEQ_CATALOG = 7.
        CLEAR GS_MATAIN_CAT.
        GS_MATAIN_CAT = GS_MATNR_MAIN-S_CAT.
        CLEAR GS_DIFINE_DAY.
        READ TABLE GS_MATAIN_CAT-T_DAY INTO GS_DIFINE_DAY WITH KEY DATE = GS_DATE-DATE.
        IF SY-SUBRC EQ 0 AND GS_DIFINE_DAY-AUFNR IS NOT INITIAL AND GS_DIFINE_DAY-ORDER_STAT IS INITIAL.
          CLEAR LS_ORDERS.
          LS_ORDERS-ORDER_NUMBER = GS_DIFINE_DAY-AUFNR.
          COLLECT LS_ORDERS INTO LT_ORDERS.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF LT_ORDERS[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '릴리즈 가능한 생산오더가 없습니다.'.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '릴리즈 진행하시겠습니까?'
    '작업확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LOOP AT LT_ORDERS INTO LS_ORDERS.
    REFRESH LT_ORDERS2.
    APPEND LS_ORDERS TO LT_ORDERS2.

    CALL FUNCTION 'BAPI_PRODORD_RELEASE'
      TABLES
        ORDERS        = LT_ORDERS
        DETAIL_RETURN = LT_RETURN.

    IF LINE_EXISTS( LT_RETURN[ TYPE = 'E'] ).
      MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더' LS_ORDERS-ORDER_NUMBER '릴리즈 처리 오류 발생하였습니다.'.
      RETURN.
    ENDIF.
  ENDLOOP.

* 대상정보 추출.
  PERFORM GET_DATA.

* 대상정보 추출.
  PERFORM SET_DISP_TABLE.

  PERFORM REFRESH_0100.

  DATA : LV_LINE_C(10) TYPE C.

  LV_LINE_C = LINES( LT_ORDERS ).
  CONDENSE LV_LINE_C.

  MESSAGE S006 WITH '생산 오더 릴리즈 처리 총' LV_LINE_C '건, 릴리즈 완료하였습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                            P_ROW TYPE LVC_S_ROW
                            P_COLUMN TYPE LVC_S_COL.

  CHECK P_ROW-INDEX > 0.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      CLEAR GS_MAIN.
      READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX P_ROW-INDEX.
      MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.

      CASE P_COLUMN-FIELDNAME.
        WHEN 'MATNR'.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'K'.
          SET PARAMETER ID 'MAT' FIELD GS_MAIN-MATNR .
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
        WHEN OTHERS.
          CASE GS_MAIN-SEQ_CATALOG.
            WHEN 7.

              READ TABLE GT_MATNR_MAIN INTO GS_MATNR_MAIN WITH KEY MATNR = GS_MAIN-MATNR
                                                                                                 SEQ_CATALOG = 7.

              READ TABLE GT_DATE INTO GS_DATE WITH KEY DATE = P_COLUMN-FIELDNAME.
              IF SY-SUBRC EQ 0.
                READ TABLE GS_MATNR_MAIN-S_CAT-T_DAY INTO GS_DIFINE_DAY WITH KEY GS_DATE-DATE.
                IF SY-SUBRC EQ 0 AND GS_DIFINE_DAY-AUFNR IS NOT INITIAL.
                  SET PARAMETER ID 'ANR' FIELD GS_DIFINE_DAY-AUFNR .
                  CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
                ELSEIF SY-SUBRC EQ 0 AND GS_DIFINE_DAY-PLNUM IS NOT INITIAL.
                  SET PARAMETER ID 'PAF' FIELD GS_DIFINE_DAY-PLNUM .
                  CALL TRANSACTION 'MD13' AND SKIP FIRST SCREEN.
                ENDIF.
              ENDIF.

              READ TABLE GT_WEEK INTO GS_WEEK WITH KEY FIELDNAME = P_COLUMN-FIELDNAME.
              IF SY-SUBRC EQ 0.
                READ TABLE GS_MATNR_MAIN-S_CAT-T_WEEK INTO GS_DIFINE_WEEK WITH KEY WEEK = GS_WEEK-WEEK.
                IF SY-SUBRC EQ 0 AND GS_DIFINE_WEEK-PLNUM IS NOT INITIAL.
                  SET PARAMETER ID 'PAF' FIELD GS_DIFINE_WEEK-PLNUM .
                  CALL TRANSACTION 'MD13' AND SKIP FIRST SCREEN.
                ENDIF.
              ENDIF.
            WHEN 2 OR 3.
              SET PARAMETER ID 'WRK' FIELD P_WERKS.
              SET PARAMETER ID 'BERID' FIELD P_WERKS.
              SET PARAMETER ID 'MAT' FIELD GS_MAIN-MATNR.

              CALL TRANSACTION 'MD04' AND SKIP FIRST SCREEN.

          ENDCASE.
      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_matnr_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MATNR_HEADER .

  DATA : LV_CAL_STOCK TYPE ZGTCV_SCR_STOCK-LABST.
  DATA : LV_CONV_STOCK TYPE ZGTCV_SCR_STOCK-LABST.
  DATA : LV_PLUS_STOCK TYPE ZGTCV_SCR_STOCK-LABST.
  DATA : LV_MINUS_STOCK TYPE ZGTCV_SCR_STOCK-LABST.
  DATA : LV_CAL_PSAMG TYPE CO_PSAMG.
  DATA : LV_USE_CHK.

  DATA : LT_DAY LIKE TABLE OF GS_DIFINE_DAY.
  DATA : LT_WEEK LIKE TABLE OF GS_WEEK.

*** 판매계획
**  LOOP AT GT_MARC INTO DATA(LS_MARC).
**    CLEAR LV_USE_CHK.
**    CLEAR GS_MATNR_MAIN.
**    CLEAR GS_MAIN.
**    CLEAR GS_MATAIN_CAT.
**    READ TABLE GT_MAIN INTO GS_MAIN WITH KEY MATNR = LS_MARC-MATNR.
**    IF SY-SUBRC EQ 0. " 기준데이터 존재해야 디스플레이 테이블 적재가능합니다.
**      MOVE-CORRESPONDING GS_MAIN TO GS_MATNR_MAIN.
**
**      GS_MATNR_MAIN-SEQ_ATWRT = 0.
**      GS_MATNR_MAIN-SEQ_CATALOG = 1.
**      CLEAR GS_MATNR_MAIN-ATWRT.
**      GS_MATNR_MAIN-CATALOG = '판매계획'.
**
**      GS_MATAIN_CAT-SEQ_CATALOG = 1.
**      GS_MATAIN_CAT-CATALOG = '판매계획'.
**
**      LOOP AT GT_DATE INTO GS_DATE.
**        CLEAR : LV_PLUS_STOCK, LV_MINUS_STOCK.
**        CLEAR GS_DIFINE_DAY.
**        GS_DIFINE_DAY-DATE = GS_DATE-DATE.
*** 해당일자 생산오더 조회
**        LOOP AT GT_MAINTAIN_MAIN INTO GS_MAINTAIN_MAIN WHERE MATNR = GS_MAIN-MATNR.
**          READ TABLE GS_MAINTAIN_MAIN-T_CAT INTO DATA(LS_CAT) WITH KEY SEQ_CATALOG = 1.
**          IF SY-SUBRC EQ 0.
**            LOOP AT LS_CAT-T_DAY INTO DATA(LS_DAY) WHERE DATE = GS_DATE-DATE.
**              ADD LS_DAY-PSAMG TO GS_DIFINE_DAY-PSAMG.
**              LV_USE_CHK = ABAP_TRUE.
**            ENDLOOP.
**          ENDIF.
**        ENDLOOP.
**
**        APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.
**      ENDLOOP.
**
**
**      LOOP AT GT_WEEK INTO GS_WEEK.
**        CLEAR : LV_PLUS_STOCK, LV_MINUS_STOCK.
**        CLEAR GS_DIFINE_WEEK.
**        GS_DIFINE_WEEK-WEEK = GS_WEEK-WEEK.
*** 해당일자 생산오더 조회
**        LOOP AT GT_MAINTAIN_MAIN INTO GS_MAINTAIN_MAIN WHERE MATNR = GS_MAIN-MATNR.
**          READ TABLE GS_MAINTAIN_MAIN-T_CAT INTO LS_CAT WITH KEY SEQ_CATALOG = 1.
**          IF SY-SUBRC EQ 0.
**            LOOP AT LS_CAT-T_WEEK INTO DATA(LS_WEEK) WHERE WEEK = GS_WEEK-WEEK.
**              ADD LS_WEEK-GSMNG TO GS_DIFINE_WEEK-GSMNG.
**              LV_USE_CHK = ABAP_TRUE.
**            ENDLOOP.
**          ENDIF.
**        ENDLOOP.
**
**        APPEND GS_DIFINE_WEEK TO GS_MATAIN_CAT-T_WEEK.
**
**      ENDLOOP.
**
**      GS_MATNR_MAIN-S_CAT = GS_MATAIN_CAT.
**      IF LV_USE_CHK = ABAP_TRUE.
**        APPEND GS_MATNR_MAIN TO GT_MATNR_MAIN.
**      ENDIF.
**    ENDIF.
**  ENDLOOP.


*** 사내이체
**  LOOP AT GT_MARC INTO LS_MARC.
**    CLEAR LV_USE_CHK.
**    CLEAR GS_MATNR_MAIN.
**    CLEAR GS_MAIN.
**    CLEAR GS_MATAIN_CAT.
**    READ TABLE GT_MAIN INTO GS_MAIN WITH KEY MATNR = LS_MARC-MATNR.
**    IF SY-SUBRC EQ 0. " 기준데이터 존재해야 디스플레이 테이블 적재가능합니다.
**      MOVE-CORRESPONDING GS_MAIN TO GS_MATNR_MAIN.
**
**      GS_MATNR_MAIN-SEQ_ATWRT = 0.
**      GS_MATNR_MAIN-SEQ_CATALOG = 3.
**      CLEAR GS_MATNR_MAIN-ATWRT.
**      GS_MATNR_MAIN-CATALOG = '사내이체'.
**
**      GS_MATAIN_CAT-SEQ_CATALOG = 3.
**      GS_MATAIN_CAT-CATALOG = '사내이체'.
**
**      LOOP AT GT_DATE INTO GS_DATE.
**        CLEAR : LV_PLUS_STOCK, LV_MINUS_STOCK.
**        CLEAR GS_DIFINE_DAY.
**        GS_DIFINE_DAY-DATE = GS_DATE-DATE.
*** 해당일자 생산오더 조회
**        LOOP AT GT_MAINTAIN_MAIN INTO GS_MAINTAIN_MAIN WHERE MATNR = GS_MAIN-MATNR.
**          READ TABLE GS_MAINTAIN_MAIN-T_CAT INTO LS_CAT WITH KEY SEQ_CATALOG = 3.
**          IF SY-SUBRC EQ 0.
**            LOOP AT LS_CAT-T_DAY INTO LS_DAY WHERE DATE = GS_DATE-DATE.
**              ADD LS_DAY-PSAMG TO GS_DIFINE_DAY-PSAMG.
**              LV_USE_CHK = ABAP_TRUE.
**            ENDLOOP.
**          ENDIF.
**        ENDLOOP.
**
**        APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.
**      ENDLOOP.
**
**
**      LOOP AT GT_WEEK INTO GS_WEEK.
**        CLEAR : LV_PLUS_STOCK, LV_MINUS_STOCK.
**        CLEAR GS_DIFINE_WEEK.
**        GS_DIFINE_WEEK-WEEK = GS_WEEK-WEEK.
*** 해당일자 생산오더 조회
**        LOOP AT GT_MAINTAIN_MAIN INTO GS_MAINTAIN_MAIN WHERE MATNR = GS_MAIN-MATNR.
**          READ TABLE GS_MAINTAIN_MAIN-T_CAT INTO LS_CAT WITH KEY SEQ_CATALOG = 3.
**          IF SY-SUBRC EQ 0.
**            LOOP AT LS_CAT-T_WEEK INTO LS_WEEK WHERE WEEK = GS_WEEK-WEEK.
**              ADD LS_WEEK-GSMNG TO GS_DIFINE_WEEK-GSMNG.
**              LV_USE_CHK = ABAP_TRUE.
**            ENDLOOP.
**          ENDIF.
**        ENDLOOP.
**
**        APPEND GS_DIFINE_WEEK TO GS_MATAIN_CAT-T_WEEK.
**
**      ENDLOOP.
**
**      GS_MATNR_MAIN-S_CAT = GS_MATAIN_CAT.
**      IF LV_USE_CHK = ABAP_TRUE.
**        APPEND GS_MATNR_MAIN TO GT_MATNR_MAIN.
**      ENDIF.
**    ENDIF.
**  ENDLOOP.

*** 판매오더
**  LOOP AT GT_MARC INTO LS_MARC.
**    CLEAR LV_USE_CHK.
**    CLEAR GS_MATNR_MAIN.
**    CLEAR GS_MAIN.
**    CLEAR GS_MATAIN_CAT.
**    READ TABLE GT_MAIN INTO GS_MAIN WITH KEY MATNR = LS_MARC-MATNR.
**    IF SY-SUBRC EQ 0. " 기준데이터 존재해야 디스플레이 테이블 적재가능합니다.
**      MOVE-CORRESPONDING GS_MAIN TO GS_MATNR_MAIN.
**
**      GS_MATNR_MAIN-SEQ_ATWRT = 0.
**      GS_MATNR_MAIN-SEQ_CATALOG = 2.
**      CLEAR GS_MATNR_MAIN-ATWRT.
**      GS_MATNR_MAIN-CATALOG = '판매오더'.
**
**      GS_MATAIN_CAT-SEQ_CATALOG = 2.
**      GS_MATAIN_CAT-CATALOG = '판매오더'.
**
**      LOOP AT GT_DATE INTO GS_DATE.
**        CLEAR : LV_PLUS_STOCK, LV_MINUS_STOCK.
**        CLEAR GS_DIFINE_DAY.
**        GS_DIFINE_DAY-DATE = GS_DATE-DATE.
*** 해당일자 생산오더 조회
**        LOOP AT GT_MAINTAIN_MAIN INTO GS_MAINTAIN_MAIN WHERE MATNR = GS_MAIN-MATNR.
**          READ TABLE GS_MAINTAIN_MAIN-T_CAT INTO LS_CAT WITH KEY SEQ_CATALOG = 2.
**          IF SY-SUBRC EQ 0.
**            LOOP AT LS_CAT-T_DAY INTO LS_DAY WHERE DATE = GS_DATE-DATE.
**              ADD LS_DAY-PSAMG TO GS_DIFINE_DAY-PSAMG.
**              LV_USE_CHK = ABAP_TRUE.
**            ENDLOOP.
**          ENDIF.
**        ENDLOOP.
**
**        APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.
**      ENDLOOP.
**
**
**      LOOP AT GT_WEEK INTO GS_WEEK.
**        CLEAR : LV_PLUS_STOCK, LV_MINUS_STOCK.
**        CLEAR GS_DIFINE_WEEK.
**        GS_DIFINE_WEEK-WEEK = GS_WEEK-WEEK.
*** 해당일자 생산오더 조회
**        LOOP AT GT_MAINTAIN_MAIN INTO GS_MAINTAIN_MAIN WHERE MATNR = GS_MAIN-MATNR.
**          READ TABLE GS_MAINTAIN_MAIN-T_CAT INTO LS_CAT WITH KEY SEQ_CATALOG = 2.
**          IF SY-SUBRC EQ 0.
**            LOOP AT LS_CAT-T_WEEK INTO LS_WEEK WHERE WEEK = GS_WEEK-WEEK.
**              ADD LS_WEEK-GSMNG TO GS_DIFINE_WEEK-GSMNG.
**              LV_USE_CHK = ABAP_TRUE.
**            ENDLOOP.
**          ENDIF.
**        ENDLOOP.
**
**        APPEND GS_DIFINE_WEEK TO GS_MATAIN_CAT-T_WEEK.
**
**      ENDLOOP.
**
**      GS_MATNR_MAIN-S_CAT = GS_MATAIN_CAT.
**      IF LV_USE_CHK = ABAP_TRUE.
**        APPEND GS_MATNR_MAIN TO GT_MATNR_MAIN.
**      ENDIF.
**    ENDIF.
**  ENDLOOP.


* 자재별 생산계획
  LOOP AT GT_MARC INTO DATA(LS_MARC).
    CLEAR GS_MATNR_MAIN.
    CLEAR GS_MAIN.
    CLEAR GS_MATAIN_CAT.
    READ TABLE GT_MAIN INTO GS_MAIN WITH KEY MATNR = LS_MARC-MATNR.
    IF SY-SUBRC EQ 0. " 기준데이터 존재해야 디스플레이 테이블 적재가능합니다.
      MOVE-CORRESPONDING GS_MAIN TO GS_MATNR_MAIN.

      GS_MATNR_MAIN-SEQ_ATWRT = 0.
      GS_MATNR_MAIN-SEQ_CATALOG = 7.
      CLEAR GS_MATNR_MAIN-ATWRT.
      GS_MATNR_MAIN-CATALOG = '생산계획'.

      GS_MATAIN_CAT-SEQ_CATALOG = 7.
      GS_MATAIN_CAT-CATALOG = '생산계획'.
      " *--------------------------------------------------------------*
      LOOP AT GT_DATE INTO GS_DATE.
        CLEAR GS_DIFINE_DAY.
        CLEAR LV_USE_CHK.
* 해당일자 생산오더 조회
        LOOP AT GT_AFPO INTO GS_AFPO WHERE MATNR = GS_MAIN-MATNR
                                       AND GSTRP = GS_DATE-DATE.
          LV_USE_CHK = ABAP_TRUE.
* 해당일자 여러 생산오더 존재 가능,
* 1. 기본적으로 최초 생선된 오더 기준으로 보여준다.
* 2. 릴리즈된 오더 존재시 릴리즈된 오더로 보여준다. 이것도 최초로 나오는 오더 기준
          IF GS_DIFINE_DAY IS INITIAL.
            GS_DIFINE_DAY-DATE = GS_DATE-DATE.
            GS_DIFINE_DAY-AUFNR = GS_AFPO-AUFNR.
          ENDIF.

          ADD GS_AFPO-GAMNG TO GS_DIFINE_DAY-PSAMG.

          IF GS_AFPO-REL IS NOT INITIAL AND GS_DIFINE_DAY-ORDER_STAT IS INITIAL. " 릴리즈 상태시 R로 마킹
            GS_DIFINE_DAY-AUFNR = GS_AFPO-AUFNR.
            GS_DIFINE_DAY-ORDER_STAT = 'R'.
          ENDIF.

          IF GS_DIFINE_DAY-ORDER_STAT = 'R'.
            CASE ABAP_TRUE.
              WHEN GS_AFPO-PCNF OR GS_AFPO-CNF OR GS_AFPO-PDLV OR GS_AFPO-DLV.
                GS_DIFINE_DAY-AUFNR = GS_AFPO-AUFNR.
                GS_DIFINE_DAY-ORDER_STAT = 'D'.
            ENDCASE.
          ENDIF.


        ENDLOOP.

        IF LV_USE_CHK = ABAP_TRUE.
          APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.
        ELSE.
* 일자별 생성계획 조회시 생성오더 미존재 계획 오더만 존재시 해당 날짜에만 보여준다.
          READ TABLE GT_PLAF INTO GS_PLAF WITH KEY MATNR = GS_MAIN-MATNR
                                                   PTEXT = GS_MAIN-ATWRT
                                                   PSTTR = GS_DATE-DATE. " 계획오더 조회시 주의 첫날짜로 조회
          IF SY-SUBRC EQ 0.
            GS_DIFINE_DAY-DATE = GS_DATE-DATE.
            GS_DIFINE_DAY-PSAMG = GS_PLAF-GSMNG.
            GS_DIFINE_DAY-PLNUM = GS_PLAF-PLNUM. " 변경되었을 경우에만 삭제
            APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.
          ENDIF.
        ENDIF.
      ENDLOOP.
      " *--------------------------------------------------------------*
      LOOP AT GT_WEEK INTO GS_WEEK.
        CLEAR GS_DIFINE_WEEK.
        READ TABLE GT_PLAF INTO GS_PLAF WITH KEY MATNR = GS_MAIN-MATNR
                                                 PSTTR = GS_WEEK-FRDATE. " 계획오더 조회시 주의 첫날짜로 조회
        IF SY-SUBRC EQ 0. " 주차별 조회시 계획량 / 7
          GS_DIFINE_WEEK-WEEK = GS_WEEK-WEEK.
          GS_DIFINE_WEEK-GSMNG = GS_PLAF-GSMNG.
          GS_DIFINE_WEEK-PLNUM = GS_PLAF-PLNUM.
          APPEND GS_DIFINE_WEEK TO GS_MATAIN_CAT-T_WEEK.
          DELETE GT_DEL_PLAF WHERE PLNUM = GS_PLAF-PLNUM.
        ENDIF.
      ENDLOOP.
      " *--------------------------------------------------------------*
      LOOP AT GT_SPMON INTO GS_SPMON.
        CLEAR GS_DIFINE_SPMON.
        CLEAR LV_CAL_PSAMG.
        LOOP AT GS_MATAIN_CAT-T_DAY INTO GS_DIFINE_DAY WHERE DATE+0(6) = GS_SPMON-SPMON.
          ADD GS_DIFINE_DAY-PSAMG TO LV_CAL_PSAMG.
        ENDLOOP.

        LOOP AT GT_WEEK INTO GS_WEEK WHERE FRDATE+0(6) = GS_SPMON-SPMON.
          READ TABLE GS_MATAIN_CAT-T_WEEK INTO GS_DIFINE_WEEK WITH KEY WEEK = GS_WEEK-WEEK.
          IF SY-SUBRC EQ 0.
            ADD GS_DIFINE_WEEK-GSMNG TO LV_CAL_PSAMG.
          ENDIF.
        ENDLOOP.

        IF LV_CAL_PSAMG NE 0.
          GS_DIFINE_SPMON-SPMON = GS_SPMON-SPMON.
          GS_DIFINE_SPMON-GSMNG = LV_CAL_PSAMG.
          APPEND GS_DIFINE_SPMON TO GS_MATAIN_CAT-T_SPMON.
        ENDIF.

      ENDLOOP.


      GS_MATNR_MAIN-S_CAT = GS_MATAIN_CAT.
      APPEND GS_MATNR_MAIN TO GT_MATNR_MAIN.

    ENDIF.
  ENDLOOP.


*** 자재별 예상재고
**  LOOP AT GT_MARC INTO LS_MARC.
**    CLEAR GS_MATNR_MAIN.
**    CLEAR GS_MAIN.
**    CLEAR GS_MATAIN_CAT.
**    READ TABLE GT_MAIN INTO GS_MAIN WITH KEY MATNR = LS_MARC-MATNR.
**    IF SY-SUBRC EQ 0. " 기준데이터 존재해야 디스플레이 테이블 적재가능합니다.
**      MOVE-CORRESPONDING GS_MAIN TO GS_MATNR_MAIN.
**
**      GS_MATNR_MAIN-SEQ_ATWRT = 0.
**      GS_MATNR_MAIN-SEQ_CATALOG = 8.
**      CLEAR GS_MATNR_MAIN-ATWRT.
**      GS_MATNR_MAIN-CATALOG = '예상재고'.
**
**      LOOP AT GT_SUM_STOCK INTO GS_SUM_STOCK WHERE MATNR = GS_MAIN-MATNR.
**        ADD GS_SUM_STOCK-STOCK TO  GS_MATNR_MAIN-OVERDUE.
**      ENDLOOP.
**
**      CLEAR LV_CAL_STOCK.
**      LV_CAL_STOCK = GS_MATNR_MAIN-OVERDUE.
**      CLEAR GS_MATNR_MAIN-OVERDUE.
**
**      GS_MATAIN_CAT-SEQ_CATALOG = 8.
**      GS_MATAIN_CAT-CATALOG = '예상재고'.
**
**      READ TABLE GT_MATNR_MAIN INTO DATA(LS_MATNR_MAIN) WITH KEY MATNR = GS_MAIN-MATNR
**                                                                                                  SEQ_CATALOG = 7.
**
**      LOOP AT GT_DATE INTO GS_DATE.
**        CLEAR : LV_PLUS_STOCK, LV_MINUS_STOCK.
**        CLEAR GS_DIFINE_DAY.
**        IF GS_DATE-DATE < SY-DATUM.
**          GS_DIFINE_DAY-DATE = GS_DATE-DATE.
**          APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.
**          CONTINUE.
**        ENDIF.
**
**        GS_DIFINE_DAY-DATE = GS_DATE-DATE.
*** 해당일자 생산오더 조회
**        LOOP AT GT_MAINTAIN_MAIN INTO GS_MAINTAIN_MAIN WHERE MATNR = GS_MAIN-MATNR.
**          READ TABLE GS_MAINTAIN_MAIN-T_CAT INTO LS_CAT WITH KEY SEQ_CATALOG = 5.
**          IF SY-SUBRC EQ 0.
**            LOOP AT LS_CAT-T_DAY INTO LS_DAY WHERE DATE = GS_DATE-DATE.
**              ADD LS_DAY-PSAMG TO LV_MINUS_STOCK.
**            ENDLOOP.
**          ENDIF.
**        ENDLOOP.
**
**        READ TABLE LS_MATNR_MAIN-S_CAT-T_DAY INTO DATA(LS_TEMP_DATE) WITH KEY DATE = GS_DATE-DATE.
**        IF SY-SUBRC EQ 0.
**          ADD LS_TEMP_DATE-PSAMG TO LV_PLUS_STOCK.
**        ENDIF.
**
**        LV_CAL_STOCK = LV_CAL_STOCK + LV_PLUS_STOCK + LV_MINUS_STOCK.
**        GS_DIFINE_DAY-PSAMG = LV_CAL_STOCK.
**
*** - 계산된 예상 재고 수량이 MIN 보다 작으면 파란색 CELL 표시
**        IF GS_DIFINE_DAY-PSAMG < LS_MARC-EISLO.
**          GS_DIFINE_DAY-STATUS = 'L'.
**          IF GS_DIFINE_DAY-PSAMG < 0.
**            GS_DIFINE_DAY-STATUS = 'R'.
**          ENDIF.
**        ENDIF.
*** - 계산된 예상 재고 수량이 Max 보다 많으면 주황색 Cell 표시
**        IF GS_DIFINE_DAY-PSAMG > LS_MARC-EISBE.
**          GS_DIFINE_DAY-STATUS = 'H'.
**        ENDIF.
**
**        IF GS_DIFINE_DAY-PSAMG BETWEEN LS_MARC-EISLO AND LS_MARC-EISBE.
**          GS_DIFINE_DAY-STATUS = 'N'.
**        ENDIF.
**
**        APPEND GS_DIFINE_DAY TO GS_MATAIN_CAT-T_DAY.
**
**      ENDLOOP.
**
**
**      LOOP AT GT_WEEK INTO GS_WEEK.
**        CLEAR : LV_PLUS_STOCK, LV_MINUS_STOCK.
**        CLEAR GS_DIFINE_WEEK.
**        GS_DIFINE_WEEK-WEEK = GS_WEEK-WEEK.
*** 해당일자 생산오더 조회
**        LOOP AT GT_MAINTAIN_MAIN INTO GS_MAINTAIN_MAIN WHERE MATNR = GS_MAIN-MATNR.
**          READ TABLE GS_MAINTAIN_MAIN-T_CAT INTO LS_CAT WITH KEY SEQ_CATALOG = 5.
**          IF SY-SUBRC EQ 0.
**            LOOP AT LS_CAT-T_WEEK INTO LS_WEEK WHERE WEEK = GS_WEEK-WEEK.
**              ADD LS_WEEK-GSMNG TO LV_MINUS_STOCK.
**            ENDLOOP.
**          ENDIF.
**        ENDLOOP.
**
**        READ TABLE LS_MATNR_MAIN-S_CAT-T_WEEK INTO DATA(LS_TEMP_WEEK) WITH KEY WEEK = GS_WEEK-WEEK.
**        IF SY-SUBRC EQ 0.
**          ADD LS_TEMP_WEEK-GSMNG TO LV_PLUS_STOCK.
**        ENDIF.
**
**        LV_CAL_STOCK = LV_CAL_STOCK + LV_PLUS_STOCK + LV_MINUS_STOCK.
**        GS_DIFINE_WEEK-GSMNG = LV_CAL_STOCK.
**
*** - 계산된 예상 재고 수량이 MIN 보다 작으면 파란색 CELL 표시
**        IF GS_DIFINE_WEEK-GSMNG < LS_MARC-EISLO.
**          GS_DIFINE_WEEK-STATUS = 'L'.
**          IF GS_DIFINE_WEEK-GSMNG < 0.
**            GS_DIFINE_WEEK-STATUS = 'R'.
**          ENDIF.
**        ENDIF.
*** - 계산된 예상 재고 수량이 Max 보다 많으면 주황색 Cell 표시
**        IF GS_DIFINE_WEEK-GSMNG > LS_MARC-EISBE.
**          GS_DIFINE_WEEK-STATUS = 'H'.
**        ENDIF.
**
**        IF GS_DIFINE_WEEK-GSMNG BETWEEN LS_MARC-EISLO AND LS_MARC-EISBE.
**          GS_DIFINE_WEEK-STATUS = 'N'.
**        ENDIF.
**
**
**        APPEND GS_DIFINE_WEEK TO GS_MATAIN_CAT-T_WEEK.
**
**      ENDLOOP.
**
**      GS_MATNR_MAIN-S_CAT = GS_MATAIN_CAT.
**
**
***      IF GS_MATNR_MAIN-OVERDUE IS NOT INITIAL.
***        CLEAR LV_CONV_STOCK.
***        LV_CONV_STOCK = GS_MATNR_MAIN-OVERDUE.
***        WRITE LV_CONV_STOCK TO GS_MATNR_MAIN-OVERDUE UNIT 'EA'.
***        CONDENSE GS_MATNR_MAIN-OVERDUE.
***      ENDIF.
**
**      APPEND GS_MATNR_MAIN TO GT_MATNR_MAIN.
**
**    ENDIF.
**  ENDLOOP.

* 자재별 예상재고
  LOOP AT GT_MAINTAIN_MAIN ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

    READ TABLE GT_MARC INTO LS_MARC WITH KEY <LS_MAIN>-MATNR.

    CLEAR GS_MATNR_MAIN.
    READ TABLE GT_MATNR_MAIN INTO GS_MATNR_MAIN WITH KEY MATNR = <LS_MAIN>-MATNR
                                                         SEQ_CATALOG = 7.

    READ TABLE <LS_MAIN>-T_CAT INTO DATA(LS_CAT) WITH KEY SEQ_CATALOG = 60.

    LOOP AT <LS_MAIN>-T_CAT ASSIGNING FIELD-SYMBOL(<LS_CAT>) WHERE SEQ_CATALOG = 99.
*     현재재고
      CLEAR LV_CAL_STOCK.
      LOOP AT GT_SUM_STOCK INTO GS_SUM_STOCK WHERE MATNR = <LS_MAIN>-MATNR
                                               AND ATWRT = <LS_MAIN>-ATWRT.
        ADD GS_SUM_STOCK-STOCK TO  LV_CAL_STOCK.
      ENDLOOP.

*    일별재고 계산
      LOOP AT <LS_CAT>-T_DAY ASSIGNING FIELD-SYMBOL(<LS_DAY>).
*     + 재고
        CLEAR LV_PLUS_STOCK.
        CLEAR GS_DIFINE_DAY.
        READ TABLE GS_MATNR_MAIN-S_CAT-T_DAY INTO GS_DIFINE_DAY WITH KEY DATE = <LS_DAY>-DATE.
        IF SY-SUBRC EQ 0.
          READ TABLE GT_2152 INTO DATA(LS_2152) WITH KEY SCRGRADE = <LS_MAIN>-ATWRT.
          IF SY-SUBRC EQ 0.
            IF GS_DIFINE_DAY-PSAMG NE 0.
              LV_PLUS_STOCK = GS_DIFINE_DAY-PSAMG * LS_2152-RATE / 100.
              PERFORM TRANSPER_ROUND CHANGING LV_PLUS_STOCK.
            ENDIF.
          ELSE.
            LV_PLUS_STOCK = GS_DIFINE_DAY-PSAMG.
          ENDIF.
        ENDIF.

*     - 재고
        READ TABLE LS_CAT-T_DAY INTO DATA(LS_DAY_TEMP) WITH KEY DATE = <LS_DAY>-DATE.
        IF SY-SUBRC EQ 0.
          LV_CAL_STOCK = LV_CAL_STOCK + LV_PLUS_STOCK + LS_DAY_TEMP-PSAMG.
        ELSE.
          LV_CAL_STOCK = LV_CAL_STOCK + LV_PLUS_STOCK.
        ENDIF.

        <LS_DAY>-PSAMG = LV_CAL_STOCK.

* - 계산된 예상 재고 수량이 MIN 보다 작으면 파란색 CELL 표시
        IF <LS_DAY>-PSAMG < LS_MARC-EISLO.
          <LS_DAY>-STATUS = 'L'.
          IF <LS_DAY>-PSAMG < 0.
            <LS_DAY>-STATUS = 'R'.
          ENDIF.
        ENDIF.
* - 계산된 예상 재고 수량이 Max 보다 많으면 주황색 Cell 표시
        IF <LS_DAY>-PSAMG > LS_MARC-EISBE.
          <LS_DAY>-STATUS = 'H'.
        ENDIF.

        IF <LS_DAY>-PSAMG BETWEEN LS_MARC-EISLO AND LS_MARC-EISBE.
          <LS_DAY>-STATUS = 'N'.
        ENDIF.

      ENDLOOP.


*    주별재고 계산
      LOOP AT <LS_CAT>-T_WEEK ASSIGNING FIELD-SYMBOL(<LS_WEEK>).
*     + 재고
        CLEAR LV_PLUS_STOCK.
        CLEAR GS_DIFINE_WEEK.
        READ TABLE GS_MATNR_MAIN-S_CAT-T_WEEK INTO GS_DIFINE_WEEK WITH KEY WEEK = <LS_WEEK>-WEEK.
        IF SY-SUBRC EQ 0.
          READ TABLE GT_2152 INTO LS_2152 WITH KEY SCRGRADE = <LS_MAIN>-ATWRT.
          IF SY-SUBRC EQ 0.
            IF GS_DIFINE_WEEK-GSMNG NE 0.
              LV_PLUS_STOCK = GS_DIFINE_WEEK-GSMNG * LS_2152-RATE / 100.
              PERFORM TRANSPER_ROUND CHANGING LV_PLUS_STOCK.
            ENDIF.
          ELSE.
            LV_PLUS_STOCK = GS_DIFINE_WEEK-GSMNG.
          ENDIF.
        ENDIF.

*     - 재고
        READ TABLE LS_CAT-T_WEEK INTO DATA(LS_WEEK_TEMP) WITH KEY WEEK = <LS_WEEK>-WEEK.
        IF SY-SUBRC EQ 0.
          LV_CAL_STOCK = LV_CAL_STOCK + LV_PLUS_STOCK + LS_WEEK_TEMP-GSMNG.
        ELSE.
          LV_CAL_STOCK = LV_CAL_STOCK + LV_PLUS_STOCK.
        ENDIF.

        <LS_WEEK>-GSMNG = LV_CAL_STOCK.

* - 계산된 예상 재고 수량이 MIN 보다 작으면 파란색 CELL 표시
        IF <LS_WEEK>-GSMNG < LS_MARC-EISLO.
          <LS_WEEK>-STATUS = 'L'.
          IF <LS_WEEK>-GSMNG < 0.
            <LS_WEEK>-STATUS = 'R'.
          ENDIF.
        ENDIF.
* - 계산된 예상 재고 수량이 Max 보다 많으면 주황색 Cell 표시
        IF <LS_WEEK>-GSMNG > LS_MARC-EISBE.
          <LS_WEEK>-STATUS = 'H'.
        ENDIF.

        IF <LS_WEEK>-GSMNG BETWEEN LS_MARC-EISLO AND LS_MARC-EISBE.
          <LS_WEEK>-STATUS = 'N'.
        ENDIF.

      ENDLOOP.

      LOOP AT GT_SPMON INTO GS_SPMON.
        CLEAR GS_DIFINE_SPMON.
        CLEAR LV_CAL_PSAMG.

        REFRESH : LT_DAY, LT_WEEK.

        LT_DAY = VALUE #( FOR LW_DAY IN <LS_CAT>-T_DAY WHERE ( DATE+0(6) = GS_SPMON-SPMON )
                                 ( CORRESPONDING #( LW_DAY ) ) ).

        IF LT_DAY[] IS NOT INITIAL.
          SORT LT_DAY BY DATE DESCENDING.
          READ TABLE LT_DAY INTO DATA(LS_DAY_CHK) INDEX 1.
          IF SY-SUBRC EQ 0.
            LV_CAL_PSAMG = LS_DAY_CHK-PSAMG.
          ENDIF.
        ELSE.
          LT_WEEK = VALUE #( FOR LW_WEEK IN GT_WEEK WHERE ( FRDATE+0(6) = GS_SPMON-SPMON )
                                 ( CORRESPONDING #( LW_WEEK ) ) ).
          IF LT_WEEK IS NOT INITIAL.
            SORT LT_WEEK BY FRDATE DESCENDING.
            CLEAR GS_WEEK.
            READ TABLE LT_WEEK INTO GS_WEEK INDEX 1.
            READ TABLE <LS_CAT>-T_WEEK INTO DATA(LS_WEEK_CHK) WITH KEY WEEK = GS_WEEK-WEEK.
            IF SY-SUBRC EQ 0.
              LV_CAL_PSAMG = LS_WEEK_CHK-GSMNG.
            ENDIF.

          ENDIF.
        ENDIF.

        IF LV_CAL_PSAMG NE 0.
          GS_DIFINE_SPMON-SPMON = GS_SPMON-SPMON.
          GS_DIFINE_SPMON-GSMNG = LV_CAL_PSAMG.
          APPEND GS_DIFINE_SPMON TO <LS_CAT>-T_SPMON.
        ENDIF.

      ENDLOOP.


    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BUTTON .

  CLEAR GV_DYNTXT.
  GV_DYNTXT-ICON_ID = ICON_TABLE_SETTINGS.
  GV_DYNTXT-TEXT = '등급관리 자재'.
  GV_DYNTXT-QUICKINFO = '등급관리 자재'.
  SSCRFIELDS-FUNCTXT_01 = GV_DYNTXT.

  CLEAR GV_DYNTXT.
  GV_DYNTXT-ICON_ID = ICON_TABLE_SETTINGS.
  GV_DYNTXT-TEXT = '생산등급 비율'.
  GV_DYNTXT-QUICKINFO = '생산등급 비율'.
  SSCRFIELDS-FUNCTXT_02 = GV_DYNTXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_MAINTAIN_VIEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_MAINTAIN_VIEW .

  DATA : LV_TABNAME TYPE DD02V-TABNAME.
  DATA : LV_TITLE TYPE SY-TITLE.
  CASE SY-UCOMM.
    WHEN 'FC01'.
      LV_TABNAME = 'ZGTPPT2151'.
      LV_TITLE = '등급관리자재'.
    WHEN 'FC02'.
      LV_TABNAME = 'ZGTPPT2152'.
      LV_TITLE = '생산등급 비율'.
  ENDCASE.

  CALL FUNCTION 'ZGTPP_UTILL_VIEW'
    DESTINATION 'NONE'
    EXPORTING
      IV_TABNAME = LV_TABNAME
      IV_TITLE   = LV_TITLE.


*  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
*    EXPORTING
*      ACTION                       = 'U'
**     CORR_NUMBER                  = '          '
**     GENERATE_MAINT_TOOL_IF_MISSING       = ' '
**     SHOW_SELECTION_POPUP         = ' '
*      VIEW_NAME                    = LV_TABNAME
**     NO_WARNING_FOR_CLIENTINDEP   = ' '
**     RFC_DESTINATION_FOR_UPGRADE  = ' '
**     CLIENT_FOR_UPGRADE           = ' '
**     VARIANT_FOR_SELECTION        = ' '
*      COMPLEX_SELCONDS_USED        = 'X'
**     CHECK_DDIC_MAINFLAG          = ' '
**     SUPPRESS_WA_POPUP            = ' '
**   TABLES
**     DBA_SELLIST                  =
**     EXCL_CUA_FUNCT               =
*    EXCEPTIONS
*      CLIENT_REFERENCE             = 1
*      FOREIGN_LOCK                 = 2
*      INVALID_ACTION               = 3
*      NO_CLIENTINDEPENDENT_AUTH    = 4
*      NO_DATABASE_FUNCTION         = 5
*      NO_EDITOR_FUNCTION           = 6
*      NO_SHOW_AUTH                 = 7
*      NO_TVDIR_ENTRY               = 8
*      NO_UPD_AUTH                  = 9
*      ONLY_SHOW_ALLOWED            = 10
*      SYSTEM_FAILURE               = 11
*      UNKNOWN_FIELD_IN_DBA_SELLIST = 12
*      VIEW_NOT_FOUND               = 13
*      MAINTENANCE_PROHIBITED       = 14
*      OTHERS                       = 15.
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MANAGEMENT_MATNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_MANAGEMENT_MATNR .

  "[소재] 일자별 가동시간
  CLEAR: GT_2150.
  SELECT * INTO TABLE GT_2150 FROM ZGTPPT2150
   WHERE WERKS = P_WERKS
     AND SPGCD = P_SPGCD.

  "[소재] 등급관리 자재
  CLEAR: GT_2151.
  SELECT * INTO TABLE GT_2151 FROM ZGTPPT2151
   WHERE WERKS = P_WERKS.

  "[소재] SCR 생산 등급 비율
  CLEAR: GT_2152.
  SELECT * INTO TABLE GT_2152 FROM ZGTPPT2152
   WHERE WERKS = P_WERKS.

* 일자별 가용 수량 계산
  PERFORM SET_AVAILABLE_QUANTITY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OFF_DAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_STR_DATE
*&      --> LV_END_DATE
*&---------------------------------------------------------------------*
FORM SET_OFF_DAY  USING    PV_STR_DATE TYPE SY-DATUM
                           PV_END_DATE TYPE SY-DATUM.

  REFRESH GT_DAY_ATTR.

  DATA : LV_FACTORY_ID TYPE SCAL-FCALID.
  DATA : LV_HOLIDAY_ID TYPE SCAL-FCALID.

*  SELECT SINGLE A~FABKL, B~HOCID
*    FROM T001W AS A
*    INNER JOIN TFACD AS B ON B~IDENT = A~FABKL
*    WHERE A~WERKS = @P_WERKS
*    INTO ( @LV_FACTORY_ID, @LV_HOLIDAY_ID ).

  CALL FUNCTION 'DAY_ATTRIBUTES_GET'
    EXPORTING
      FACTORY_CALENDAR           = 'LG'
      HOLIDAY_CALENDAR           = 'LG'
      DATE_FROM                  = PV_STR_DATE
      DATE_TO                    = PV_END_DATE
      LANGUAGE                   = SY-LANGU
    TABLES
      DAY_ATTRIBUTES             = GT_DAY_ATTR
    EXCEPTIONS
      FACTORY_CALENDAR_NOT_FOUND = 1
      HOLIDAY_CALENDAR_NOT_FOUND = 2
      DATE_HAS_INVALID_FORMAT    = 3
      DATE_INCONSISTENCY         = 4
      OTHERS                     = 5.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_AVAILABLE_QUANTITY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_AVAILABLE_QUANTITY .

  REFRESH GT_DATE_AVAILABLE.
  FREE GT_DATE_AVAILABLE.
  REFRESH GT_WEEK_AVAILABLE.
  FREE GT_WEEK_AVAILABLE.

  DATA : LV_CAL_PSAMG TYPE CO_PSAMG.

  LOOP AT GT_DATE INTO GS_DATE.
    CLEAR GS_DATE_AVAILABLE.
    GS_DATE_AVAILABLE-DATE = GS_DATE-DATE.

    CLEAR LV_CAL_PSAMG.
    READ TABLE GT_2150 INTO DATA(LS_2150) WITH KEY PLDAT = GS_DATE-DATE.
    IF SY-SUBRC EQ 0 AND LS_2150-OPRTIM NE 0.
      LV_CAL_PSAMG = 850000 / 24 * LS_2150-OPRTIM.
      PERFORM TRANSPER_ROUND CHANGING LV_CAL_PSAMG.
    ELSE.

      READ TABLE GT_DAY_ATTR INTO DATA(LS_CHK_DATE) WITH KEY DATE = GS_DATE-DATE.
      IF SY-SUBRC EQ 0 AND ( LS_CHK_DATE-WEEKDAY = 6 OR LS_CHK_DATE-WEEKDAY = 7 ).
        LV_CAL_PSAMG = 0.
      ELSE.
        LV_CAL_PSAMG = 850000.
      ENDIF.
    ENDIF.

    GS_DATE_AVAILABLE-LIMIT = LV_CAL_PSAMG.
    APPEND GS_DATE_AVAILABLE TO GT_DATE_AVAILABLE.
  ENDLOOP.


  LOOP AT GT_WEEK INTO GS_WEEK.
    CLEAR GS_WEEK_AVAILABLE.
    GS_WEEK_AVAILABLE-WEEK = GS_WEEK-WEEK.
    LV_CAL_PSAMG = 850000 * 5.
    GS_WEEK_AVAILABLE-LIMIT = LV_CAL_PSAMG.
    APPEND GS_WEEK_AVAILABLE TO GT_WEEK_AVAILABLE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RTO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM SET_RTO  CHANGING PV_CHK_ERR.

  DATA : LT_SAVE_TAB TYPE TABLE OF ZGTSDT0010.
  DATA : LS_SAVE_TAB TYPE ZGTSDT0010.
  DATA : LS_JEGO_CAT LIKE GS_MATAIN_CAT.
  DATA : LS_JEGO LIKE GS_DIFINE_DAY.
  DATA : LS_PRODUCT_CAT LIKE GS_MATAIN_CAT.
  DATA : LS_PRODUCT LIKE GS_DIFINE_DAY.
  DATA : LS_STO_CAT LIKE GS_MATAIN_CAT.
  DATA : LS_STO LIKE GS_DIFINE_DAY.
  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LV_CNT_JEGO TYPE CO_PSAMG.
  DATA : LT_VBAP LIKE TABLE OF GS_VBAP.


  LOOP AT GT_MAINTAIN_MAIN INTO GS_MAINTAIN_MAIN.

    READ TABLE GT_2151 TRANSPORTING NO FIELDS WITH KEY MATNR = GS_MAINTAIN_MAIN-MATNR BINARY SEARCH.
    IF SY-SUBRC EQ 0 AND GS_MAINTAIN_MAIN-SEQ_ATWRT = 9.
      CONTINUE.
    ENDIF.


    READ TABLE GS_MAINTAIN_MAIN-T_CAT INTO GS_MATAIN_CAT WITH KEY SEQ_CATALOG = 2.
    IF SY-SUBRC EQ 0 AND GS_MATAIN_CAT-T_DAY[] IS NOT INITIAL.
* 예상재고 계산을 위한 재고 정보
      CLEAR LS_JEGO_CAT.
      READ TABLE GS_MAINTAIN_MAIN-T_CAT INTO LS_JEGO_CAT WITH KEY SEQ_CATALOG = 99.
* 예상재고 계산을 위한 생산계획 정보
      CLEAR LS_PRODUCT_CAT.
      READ TABLE GS_MAINTAIN_MAIN-T_CAT INTO LS_PRODUCT_CAT WITH KEY SEQ_CATALOG = 4.
* 예상재고 계산을 위한 sto 정보
      CLEAR LS_STO_CAT.
      READ TABLE GS_MAINTAIN_MAIN-T_CAT INTO LS_STO_CAT WITH KEY SEQ_CATALOG = 3.

      LOOP AT GS_MATAIN_CAT-T_DAY INTO GS_DIFINE_DAY.
* 계산을 위한 재고 수량 정보 추출
        CLEAR LV_DATE.
        IF GS_DIFINE_DAY-DATE = SY-DATUM. " 판매오더 일자가 현재일과 동일하면 현재재고
          CLEAR LV_CNT_JEGO.
          LOOP AT GT_SUM_STOCK INTO GS_SUM_STOCK WHERE MATNR = GS_MAINTAIN_MAIN-MATNR
                                                   AND ATWRT = GS_MAINTAIN_MAIN-ATWRT.
            ADD GS_SUM_STOCK-STOCK TO  LV_CNT_JEGO.
          ENDLOOP.

        ELSE. " 아니라면 전일자 재고 수량
          LV_DATE = GS_DIFINE_DAY-DATE - 1.
          CLEAR LS_JEGO.
          READ TABLE LS_JEGO_CAT-T_DAY INTO LS_JEGO WITH KEY DATE = LV_DATE.
          IF SY-SUBRC EQ 0.
            LV_CNT_JEGO = LS_JEGO-PSAMG.
          ENDIF.
        ENDIF.
* 계산을 위한 STO 수량 정보 추출
        CLEAR LS_STO.
        READ TABLE LS_STO_CAT-T_DAY INTO LS_STO WITH KEY DATE = GS_DIFINE_DAY-DATE.
        IF SY-SUBRC EQ 0.
          LV_CNT_JEGO = LV_CNT_JEGO - LS_STO-PSAMG.
        ENDIF.

* 계산을 위한 생산계획 수량 정보 추출
        CLEAR LS_PRODUCT.
        READ TABLE LS_PRODUCT_CAT-T_DAY INTO LS_PRODUCT WITH KEY DATE = GS_DIFINE_DAY-DATE.
        IF SY-SUBRC EQ 0.
          LV_CNT_JEGO = LV_CNT_JEGO + LS_PRODUCT-PSAMG.
        ENDIF.

*      추출된 판매오더 정보로 RTO 정보 저장
        REFRESH LT_VBAP.
        LT_VBAP = VALUE #( FOR LW_VBAP IN GT_VBAP WHERE ( MATNR = GS_MAINTAIN_MAIN-MATNR
                                                                   AND  ATWRT = GS_MAINTAIN_MAIN-ATWRT
                                                                   AND   EDATU = GS_DIFINE_DAY-DATE )
                                   ( CORRESPONDING #( LW_VBAP ) ) ).

        SORT LT_VBAP BY VBELN POSNR.
        LOOP AT LT_VBAP INTO DATA(LS_VBAP).
          CLEAR LS_SAVE_TAB.
          PERFORM SET_SAVE_RTO_INFO USING LS_VBAP CHANGING LS_SAVE_TAB LV_CNT_JEGO.
          APPEND LS_SAVE_TAB TO LT_SAVE_TAB.

        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  IF LT_SAVE_TAB[] IS NOT INITIAL.
    MODIFY ZGTSDT0010 FROM TABLE LT_SAVE_TAB.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S006 DISPLAY LIKE 'E' WITH 'RTO 저장중오류'.
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
  ENDIF.

  COMMIT WORK AND WAIT.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SAVE_RTO_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_VBAP
*&      <-- LS_SAVE_TAB
*&---------------------------------------------------------------------*
FORM SET_SAVE_RTO_INFO  USING  PS_VBAP LIKE GS_VBAP
                        CHANGING PS_SAVE_TAB TYPE ZGTSDT0010
                              PV_JEGO TYPE CO_PSAMG.

  GET TIME STAMP FIELD PS_SAVE_TAB-ZCKEY.

  ZGTSD_CL_COMMON=>SET_TIMESTAMP( EXPORTING IV_GUBUN = 'C'
                                   CHANGING CS_TIMESTAMP = PS_SAVE_TAB-TIMESTAMP ).

  PS_SAVE_TAB-VBELN = PS_VBAP-VBELN.
  PS_SAVE_TAB-POSNR = PS_VBAP-POSNR.
  PS_SAVE_TAB-SEQNO = '00'.
  PS_SAVE_TAB-MATNR = PS_VBAP-MATNR.
  PS_SAVE_TAB-ITEMNAME = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = PS_VBAP-MATNR ).
  PV_JEGO = PV_JEGO - PS_VBAP-KWMENG.
  IF PV_JEGO >= 0.
    PS_SAVE_TAB-PPDAT = PS_VBAP-EDATU.
    PS_SAVE_TAB-LEDAT = PS_VBAP-EDATU.
  ENDIF.

*  PS_SAVE_TAB-PPDAT = PS_VBAP-VBELN.
*  PS_SAVE_TAB-QMDAT = PS_VBAP-VBELN.
*  PS_SAVE_TAB-LEDAT = PS_VBAP-VBELN.
*  PS_SAVE_TAB-LODAT = PS_VBAP-VBELN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ATWRT_FR_EKPO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ATWRT_FR_EKPO .

  DATA : LV_TABIX TYPE I.

  LOOP AT GT_EKPO ASSIGNING FIELD-SYMBOL(<LS_EKPO>).
    LV_TABIX = SY-TABIX.
    READ TABLE GT_2160 TRANSPORTING NO FIELDS WITH KEY EBELN = <LS_EKPO>-EBELN
                                                       EBELP = <LS_EKPO>-EBELP.
    IF SY-SUBRC EQ 0.
      DELETE GT_EKPO INDEX LV_TABIX.
      CONTINUE.
    ENDIF.

*    등급
    ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
      EXPORTING
        IV_CUOBJ      = <LS_EKPO>-CUOBJ                 " 구성
      IMPORTING
        EV_GRADE = <LS_EKPO>-ATWRT  ).
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ATWRT_FR_STOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ATWRT_FR_STOCK .

  LOOP AT GT_SUM_STOCK ASSIGNING FIELD-SYMBOL(<LS_DATA>).

    CASE <LS_DATA>-ATWRT.
      WHEN 'X08      4'.
        <LS_DATA>-ATWRT = 'G4'.
      WHEN 'X08      3'.
        <LS_DATA>-ATWRT = 'G3'.
      WHEN 'X08      2'.
        <LS_DATA>-ATWRT = 'G2'.
      WHEN 'X08      1'.
        <LS_DATA>-ATWRT = 'G1'.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SALES_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SALES_PLAN .

  DATA : LS_PLAN LIKE GS_SALE_PLAN.
  DATA : LT_PLAN LIKE TABLE OF GS_SALE_PLAN.

  LT_PLAN = GT_SALE_PLAN.
  REFRESH GT_SALE_PLAN.

  LOOP AT LT_PLAN INTO  LS_PLAN.
    CASE LS_PLAN-ATTR01.
      WHEN '1'.
        LS_PLAN-ATTR01 = 'G1'.
      WHEN '2'.
        LS_PLAN-ATTR01 = 'G2'.
      WHEN '3'.
        LS_PLAN-ATTR01 = 'G3'.
      WHEN '4'.
        LS_PLAN-ATTR01 = 'G4'.
      WHEN OTHERS.
        CLEAR LS_PLAN-ATTR01.
    ENDCASE.

    IF LS_PLAN-VRKME NE 'KG'.

      IF LS_PLAN-VRKME IS INITIAL.
        LS_PLAN-VRKME = 'KG'.
      ELSE.
        PERFORM TRANSLATE_UNIT_QUANTITY USING LS_PLAN-VRKME 'KG' LS_PLAN-QUANTITY_DP CHANGING LS_PLAN-QUANTITY_DP.
        LS_PLAN-VRKME = 'KG'.
      ENDIF.
    ENDIF.

    COLLECT LS_PLAN INTO GT_SALE_PLAN.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form TRANSLATE_UNIT_QUANTITY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LV_MEINS>
*&      --> LV_MEINS
*&      --> <LV_SO_UNIT>
*&      <-- <LV_SO_UNIT>
*&---------------------------------------------------------------------*
FORM TRANSLATE_UNIT_QUANTITY  USING    PV_UNIT_IN TYPE T006-MSEHI
                                                            PV_UNIT_OUT TYPE T006-MSEHI
                                                            PV_INPUT
                                           CHANGING    PV_OUTPUT.

  CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
    EXPORTING
      INPUT                = PV_INPUT
      UNIT_IN              = PV_UNIT_IN
      UNIT_OUT             = PV_UNIT_OUT
    IMPORTING
      OUTPUT               = PV_OUTPUT
    EXCEPTIONS
      CONVERSION_NOT_FOUND = 1
      DIVISION_BY_ZERO     = 2
      INPUT_INVALID        = 3
      OUTPUT_INVALID       = 4
      OVERFLOW             = 5
      TYPE_INVALID         = 6
      UNITS_MISSING        = 7
      UNIT_IN_NOT_FOUND    = 8
      UNIT_OUT_NOT_FOUND   = 9
      OTHERS               = 10.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
    EXPORTING
      I_RTYPE     = '+'
      I_RUNIT     = 1
      I_VALUE     = PV_OUTPUT
    IMPORTING
      E_VALUE_RND = PV_OUTPUT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SPMON_TAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SPMON_TAB .

  REFRESH GT_SPMON.
  DATA : LV_MON_C(2).


  LOOP AT GT_DATE INTO GS_DATE.
    CLEAR GS_SPMON.
    GS_SPMON-SPMON = GS_DATE-DATE+0(6).
    COLLECT GS_SPMON INTO GT_SPMON.
  ENDLOOP.

  LOOP AT GT_WEEK INTO GS_WEEK.
    CLEAR GS_SPMON.
    GS_SPMON-SPMON = GS_WEEK-FRDATE+0(6).
    COLLECT GS_SPMON INTO GT_SPMON.
  ENDLOOP.


  LOOP AT GT_SPMON ASSIGNING FIELD-SYMBOL(<LS_SPMON>).
    <LS_SPMON>-FIELDNAME = 'M' && <LS_SPMON>-SPMON.

    CLEAR LV_MON_C.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = <LS_SPMON>-SPMON+4(2)
      IMPORTING
        OUTPUT = LV_MON_C.

    IF <LS_SPMON>-SPMON+4(2) = '01'.
      <LS_SPMON>-REPTEXT = |{ <LS_SPMON>-SPMON+0(4) }년 { LV_MON_C }월 계|.
    ELSE.
      <LS_SPMON>-REPTEXT = |{ LV_MON_C }월 계|.
    ENDIF.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_SET_LINE_FULL_MANUAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_SET_LINE_FULL_MANUAL .

  DATA : LT_CELLS TYPE LVC_T_CENO.

  GO_GRID_0100->GET_SELECTED_CELLS_ID(
        IMPORTING
         ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_CELLS[] IS INITIAL.
    RETURN.
  ENDIF.

  DATA(LT_CELL_CHK) = LT_CELLS.

  SORT LT_CELL_CHK BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CELL_CHK COMPARING ROW_ID.
  IF LINES( LT_CELL_CHK ) > 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '상세생산(수량입력)은 한 라인만 처리 할 수 있습니다.'(e08).
    RETURN.
  ENDIF.

  SORT LT_CELLS BY COL_ID.

  READ TABLE LT_CELLS INTO DATA(LS_CELLS) INDEX 1.

* 생산수량 적용
  READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_CELLS-ROW_ID.
  CLEAR GS_MAIN.
  MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.
  MOVE-CORRESPONDING GS_MAIN TO GS_HEADER_0300.

  READ TABLE GT_MATNR_MAIN ASSIGNING FIELD-SYMBOL(<LS_MAINTAIN>) WITH KEY MATNR = GS_MAIN-MATNR
                                                                                                                  SEQ_CATALOG = 7.
  PERFORM MAKE_SCREEN_300_TABLE USING <LS_MAINTAIN>-S_CAT.

  IF GT_MAIN_DISP_300[] IS NOT INITIAL.
    CLEAR GV_CHK_STATUS_300.
    CALL SCREEN '0300' STARTING AT 5 5 ENDING AT 60 30.
    IF GV_CHK_STATUS_300 = 'S'. " 테이블 변경 요청

      PERFORM SET_CHANGE_MENGE TABLES GT_MAIN_DISP_300 CHANGING <LS_MAINTAIN>-S_CAT.
      PERFORM SET_SPMON_FIELD CHANGING <LS_MAINTAIN>-S_CAT.
      UNASSIGN <LS_MAINTAIN>.

      PERFORM SET_CAL_STOCK.
      PERFORM SET_DISP_TABLE.
      PERFORM REFRESH_0100.

      GV_CHK_EDIT = ABAP_TRUE.

      MESSAGE S003 WITH '생산수량 입력되었습니다.'.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_SCREEN_300_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAINTAIN>_S_CAT
*&---------------------------------------------------------------------*
FORM MAKE_SCREEN_300_TABLE  USING    PS_CAT LIKE GS_MATAIN_CAT.

  DATA : LV_SEQNO TYPE I.

  CLEAR GV_CHK_STATUS_300.
  REFRESH GT_MAIN_DISP_300.
  FREE GT_MAIN_DISP_300.

* 일자별 수량 입력 필드 구성
  LOOP AT GT_DATE INTO GS_DATE.
    CLEAR GS_MAIN_DISP_300.
    ADD 1 TO LV_SEQNO.
    GS_MAIN_DISP_300-SEQ_FIELD = LV_SEQNO.
    GS_MAIN_DISP_300-FIELDNAME = GS_DATE-DATE.
    GS_MAIN_DISP_300-GUBUN = 'D'.
    READ TABLE GT_DAY_ATTR INTO DATA(LS_DAY_ATTR) WITH KEY DATE = GS_DATE-DATE.
    IF SY-SUBRC EQ 0 AND ( LS_DAY_ATTR-WEEKDAY = 6 OR LS_DAY_ATTR-WEEKDAY = 7 ).
      GS_MAIN_DISP_300-CHK_BREAK = ABAP_TRUE.
    ENDIF.

    READ TABLE PS_CAT-T_DAY INTO GS_DIFINE_DAY WITH KEY DATE = GS_DATE-DATE.
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP_300-GAMNG = GS_DIFINE_DAY-PSAMG.
      IF GS_DIFINE_DAY-AUFNR IS NOT INITIAL OR  GS_DIFINE_DAY-PLNUM IS NOT INITIAL.
        GS_MAIN_DISP_300-STATUS = ICON_DISPLAY_NOTE.
      ENDIF.
    ENDIF.

    READ TABLE GT_DATE_AVAILABLE INTO GS_DATE_AVAILABLE WITH KEY DATE = GS_DATE-DATE.
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP_300-AVAILABLE = GS_DATE_AVAILABLE-LIMIT - GS_DATE_AVAILABLE-AVAILABLE.
    ENDIF.

    APPEND GS_MAIN_DISP_300 TO GT_MAIN_DISP_300.
  ENDLOOP.

* 주차별 수량 입력 필드 구성
  LOOP AT GT_WEEK INTO GS_WEEK.
    CLEAR GS_MAIN_DISP_300.
    ADD 1 TO LV_SEQNO.
    GS_MAIN_DISP_300-SEQ_FIELD = LV_SEQNO.
    GS_MAIN_DISP_300-FIELDNAME = GS_WEEK-WEEK.
    GS_MAIN_DISP_300-GUBUN = 'W'.

    READ TABLE PS_CAT-T_WEEK INTO GS_DIFINE_WEEK WITH KEY WEEK = GS_WEEK-WEEK.
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP_300-GAMNG = GS_DIFINE_WEEK-GSMNG.
      IF GS_DIFINE_WEEK-PLNUM IS NOT INITIAL.
        GS_MAIN_DISP_300-STATUS = ICON_DISPLAY_NOTE.
      ENDIF.
    ENDIF.

    READ TABLE GT_WEEK_AVAILABLE INTO GS_WEEK_AVAILABLE WITH KEY WEEK = GS_WEEK-WEEK.
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP_300-AVAILABLE = GS_WEEK_AVAILABLE-LIMIT - GS_WEEK_AVAILABLE-AVAILABLE..
    ENDIF.

    APPEND GS_MAIN_DISP_300 TO GT_MAIN_DISP_300.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHANGE_MENGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MAIN_DISP_300
*&      <-- <LS_MAINTAIN>
*&---------------------------------------------------------------------*
FORM SET_CHANGE_MENGE  TABLES   PT_MAIN STRUCTURE GS_MAIN_DISP_300
                       CHANGING PS_MAINTAIN LIKE GS_MATAIN_CAT.

  LOOP AT PT_MAIN INTO DATA(LS_MAIN) WHERE STATUS = ICON_CHANGE.
    CASE LS_MAIN-GUBUN.
      WHEN 'D'.
        READ TABLE PS_MAINTAIN-T_DAY ASSIGNING FIELD-SYMBOL(<LS_DIFINE_DAY>) WITH KEY DATE = LS_MAIN-FIELDNAME.
        IF SY-SUBRC EQ 0.
          <LS_DIFINE_DAY>-PSAMG = LS_MAIN-GAMNG.
          IF LS_MAIN-GAMNG = 0.
            CLEAR <LS_DIFINE_DAY>-CHANGE.
          ELSE.
            <LS_DIFINE_DAY>-CHANGE = ABAP_TRUE.
          ENDIF.
        ELSE.
          APPEND INITIAL LINE TO PS_MAINTAIN-T_DAY ASSIGNING <LS_DIFINE_DAY>.
          <LS_DIFINE_DAY>-DATE = LS_MAIN-FIELDNAME.
          <LS_DIFINE_DAY>-PSAMG = LS_MAIN-GAMNG.
          <LS_DIFINE_DAY>-CHANGE = ABAP_TRUE.
        ENDIF.
      WHEN 'W'.
        READ TABLE PS_MAINTAIN-T_WEEK ASSIGNING FIELD-SYMBOL(<LS_DIFINE_WEEK>) WITH KEY WEEK = LS_MAIN-FIELDNAME.
        IF SY-SUBRC EQ 0.
          <LS_DIFINE_WEEK>-GSMNG = LS_MAIN-GAMNG.
          IF LS_MAIN-GAMNG = 0.
            CLEAR <LS_DIFINE_WEEK>-CHANGE.
          ELSE.
            <LS_DIFINE_WEEK>-CHANGE = ABAP_TRUE.
          ENDIF.
        ELSE.
          APPEND INITIAL LINE TO PS_MAINTAIN-T_WEEK ASSIGNING <LS_DIFINE_WEEK>.
          <LS_DIFINE_WEEK>-WEEK = LS_MAIN-FIELDNAME.
          <LS_DIFINE_WEEK>-GSMNG = LS_MAIN-GAMNG.
          <LS_DIFINE_WEEK>-CHANGE = ABAP_TRUE.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  SORT PS_MAINTAIN-T_DAY BY DATE.
  SORT PS_MAINTAIN-T_WEEK BY WEEK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0300 .

  CREATE OBJECT GO_DOCKING_0300
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
*화면 분할
  CREATE OBJECT GO_SPLITTER_0300
    EXPORTING
      PARENT  = GO_DOCKING_0300
      ROWS    = 2
      COLUMNS = 1.

  GO_SPLITTER_0300->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    6 ).             " Height

** top 컨테이너
  CALL METHOD GO_SPLITTER_0300->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_TOP_0300.

* bottom 컨테이너
  CALL METHOD GO_SPLITTER_0300->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0300.

  CREATE OBJECT GO_GRID_0300
    EXPORTING
      I_PARENT      = GO_CONTAIN_0300
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0300 .

  CLEAR GS_LAYOUT_0300.
  GS_LAYOUT_0300-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0300-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT_0300-SEL_MODE  = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0300 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0300
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0300 .

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LV_DATE TYPE SY-DATUM.

  REFRESH GT_FIELDCAT_0300.
  FREE GT_FIELDCAT_0300.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = 'GS_MAIN_DISP_300'
      I_INCLNAME         = 'ZGTPPR2110TOP'
      I_BYPASSING_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT        = LT_FCAT.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0300[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_300.

  READ TABLE GT_FIELDCAT_0300 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'SEQ_FIELD'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0300 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-FIELDNAME = 'SEQ_FIELD'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'INT4'.
    <LS_FCAT>-DD_OUTLEN = '11'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
    UNASSIGN <LS_FCAT>.
  ENDIF.

  READ TABLE GT_FIELDCAT_0300 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'FIELDNAME'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0300 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-FIELDNAME = 'FIELDNAME'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
*    <LS_FCAT>-NO_OUT = ABAP_TRUE.
    UNASSIGN <LS_FCAT>.
  ENDIF.

  READ TABLE GT_FIELDCAT_0300 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'GUBUN'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0300 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 3.
    <LS_FCAT>-FIELDNAME = 'GUBUN'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기간단위'.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-COL_OPT = ABAP_TRUE.
    UNASSIGN <LS_FCAT>.
  ENDIF.

  READ TABLE GT_FIELDCAT_0300 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'CHK_BREAK'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0300 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 4.
    <LS_FCAT>-FIELDNAME = 'CHK_BREAK'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
    UNASSIGN <LS_FCAT>.
  ENDIF.

* 필드명 서술
  LOOP AT GT_FIELDCAT_0300 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'FIELDNAME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수립기간'(f12).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'GUBUN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기간단위'(f16).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'STATUS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '상태'(f13).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'AVAILABLE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산가능수량'(f14).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = '9'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'GAMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '요청수량'(f15).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-OUTPUTLEN = 12.
        <LS_FCAT>-QUANTITY = 'EA'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

  SORT GT_FIELDCAT_0300 BY COL_POS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0300 .

  PERFORM SET_SORT_TAB TABLES GT_SORT_0300
                                  USING : 1 'SEQ_FIELD' 'X' '' '',
                                        2 'FIELDNAME'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0300_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0300_DISPLAY .

  CALL METHOD GO_GRID_0300->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0300
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0300
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_300
      IT_SORT              = GT_SORT_0300
      IT_FIELDCATALOG      = GT_FIELDCAT_0300.

  IF GO_DD_DOCU_0300 IS BOUND.
    CALL METHOD GO_DD_DOCU_0300->INITIALIZE_DOCUMENT.
  ELSE.
    CREATE OBJECT GO_DD_DOCU_0300
      EXPORTING
        STYLE = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD GO_GRID_0300->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DD_DOCU_0300.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0300->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0300->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_SCREEN300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PO_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM SET_TITLE_SCREEN300  CHANGING PO_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  DATA : LV_TEXT(255) TYPE C.
  DATA : LV_FR_SPMON(10).
  DATA : LV_TO_SPMON(10).

* 자재명
  CLEAR LV_TEXT.
  CONCATENATE '자재명 :' GS_HEADER_0300-MAKTX INTO LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PO_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PO_DYNDOC_ID->NEW_LINE.

* 등급
  IF GS_HEADER_0300-ATWRT IS NOT INITIAL.
    CLEAR LV_TEXT.
    CONCATENATE '등급 :' GS_HEADER_0300-ATWRT INTO LV_TEXT SEPARATED BY SPACE.
    "텍스트 추가
    CALL METHOD PO_DYNDOC_ID->ADD_TEXT
      EXPORTING
        TEXT         = LV_TEXT
        SAP_FONTSIZE = '20'.

    CALL METHOD PO_DYNDOC_ID->NEW_LINE.
  ENDIF.

  "위쪽에 추가한 텍스트 출력
  CALL METHOD PO_DYNDOC_ID->DISPLAY_DOCUMENT
    EXPORTING
      PARENT             = GO_CONTAIN_TOP_0300
      REUSE_CONTROL      = ABAP_TRUE
      REUSE_REGISTRATION = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0300 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_STYLE TYPE LVC_STYLE.

  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

  LOOP AT GT_MAIN_DISP_300 ASSIGNING FIELD-SYMBOL(<LS_DATA>).

    REFRESH LT_CELLTAB.

    LOOP AT GT_FIELDCAT_0300 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
      CASE <LS_FCAT>-FIELDNAME.
        WHEN 'FIELDNAME' OR 'GUBUN' OR 'STATUS' OR 'AVAILABLE'.
          CLEAR LV_STYLE.
          IF <LS_DATA>-CHK_BREAK = ABAP_TRUE.
            LV_STYLE = ALV_STYLE_COLOR_GROUP.
          ELSE.
            LV_STYLE = ALV_STYLE_COLOR_KEY.
          ENDIF.
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = <LS_FCAT>-FIELDNAME.
          LS_CELLTAB-STYLE = LV_STYLE.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
        WHEN 'GAMNG'.
          CLEAR LV_STYLE.
          IF <LS_DATA>-STATUS = ICON_DISPLAY_NOTE.
            LV_STYLE = ALV_STYLE_DISABLED.
          ELSE.
            LV_STYLE = ALV_STYLE_ENABLED.
          ENDIF.

          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = <LS_FCAT>-FIELDNAME.
          LS_CELLTAB-STYLE = LV_STYLE.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
      ENDCASE.
    ENDLOOP.


    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <LS_DATA> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SPMON_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_MAINTAIN
*&---------------------------------------------------------------------*
FORM SET_SPMON_FIELD  CHANGING    PS_MAINTAIN LIKE GS_MATAIN_CAT.

* 월별 합계 반영
  LOOP AT GT_SPMON INTO GS_SPMON.
    READ TABLE PS_MAINTAIN-T_SPMON ASSIGNING FIELD-SYMBOL(<LS_SPMON>) WITH KEY GS_SPMON-FIELDNAME.
    IF SY-SUBRC NE 0.
      APPEND INITIAL LINE TO PS_MAINTAIN-T_SPMON ASSIGNING <LS_SPMON>.
      <LS_SPMON>-SPMON = GS_SPMON-SPMON.
    ELSE.
      CLEAR <LS_SPMON>-GSMNG.
    ENDIF.

    LOOP AT PS_MAINTAIN-T_DAY INTO GS_DIFINE_DAY WHERE DATE+0(6) = GS_SPMON-SPMON.
      ADD GS_DIFINE_DAY-PSAMG TO <LS_SPMON>-GSMNG.
    ENDLOOP.


    LOOP AT GT_WEEK INTO GS_WEEK WHERE FRDATE+0(6) = GS_SPMON-SPMON.
      READ TABLE PS_MAINTAIN-T_WEEK INTO GS_DIFINE_WEEK WITH KEY WEEK = GS_WEEK-WEEK.
      IF SY-SUBRC EQ 0.
        ADD GS_DIFINE_WEEK-GSMNG TO <LS_SPMON>-GSMNG.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

  SORT PS_MAINTAIN-T_SPMON BY SPMON.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_MANAGE_JEGO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_MANAGE_JEGO .

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_ERR_CHK.

  GO_GRID_0100->GET_SELECTED_CELLS_ID(
        IMPORTING
         ET_CELLS = LT_CELLS ).                " Cell IDs

  CLEAR GS_HEADER_0400.

  IF LT_CELLS[] IS INITIAL.
    RETURN.
  ENDIF.

  DATA(LT_CELL_CHK) = LT_CELLS.

  SORT LT_CELL_CHK BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CELL_CHK COMPARING ROW_ID.
  IF LINES( LT_CELL_CHK ) > 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '사급, 신선 관리는 한 라인만 처리 할 수 있습니다.'(e09).
    RETURN.
  ENDIF.

  SORT LT_CELLS BY COL_ID.

  READ TABLE LT_CELLS INTO DATA(LS_CELLS) INDEX 1.

* 생산수량 적용
  READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_CELLS-ROW_ID.
  CLEAR GS_MAIN.
  MOVE-CORRESPONDING <LS_MAIN> TO GS_MAIN.
  MOVE-CORRESPONDING GS_MAIN TO GS_HEADER_0400.
  IF ( GS_MAIN-ATWRT = 'G4' OR GS_MAIN-ATWRT = '' ) AND ( GS_MAIN-SEQ_CATALOG = 11 OR GS_MAIN-SEQ_CATALOG = 12 ).
    READ TABLE GT_MAINTAIN_MAIN ASSIGNING FIELD-SYMBOL(<LS_MAINTAIN>) WITH KEY MATNR = GS_MAIN-MATNR
                                                                                                                ATWRT = GS_MAIN-ATWRT.
    IF SY-SUBRC EQ 0.
      PERFORM MAKE_SCREEN_400_TABLE USING <LS_MAINTAIN>.
      CALL SCREEN '0400' STARTING AT 5 5 ENDING AT 60 30.
      IF GV_CHK_STATUS_400 = 'S'. " 테이블 변경 요청

        PERFORM SET_CHANGE_JEGO CHANGING <LS_MAINTAIN> LV_ERR_CHK.
        IF LV_ERR_CHK = ABAP_TRUE.
          RETURN.
        ENDIF.

        PERFORM SET_SPMON_FIELD_JEGO CHANGING <LS_MAINTAIN>.
        UNASSIGN <LS_MAINTAIN>.

        PERFORM SET_CAL_STOCK.
        PERFORM SET_DISP_TABLE.
        PERFORM REFRESH_0100.
      ENDIF.
    ENDIF.
  ENDIF.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_SCREEN_400_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAINTAIN>
*&---------------------------------------------------------------------*
FORM MAKE_SCREEN_400_TABLE  USING    PS_MAINTAIN LIKE GS_MAINTAIN_MAIN.

  DATA : LV_SEQNO TYPE I.
  DATA : LS_MAIN_CONTMNG LIKE GS_MATAIN_CAT.
  DATA : LS_MAIN_MOVEMNG LIKE GS_MATAIN_CAT.

  CLEAR GV_CHK_STATUS_400.
  REFRESH GT_MAIN_DISP_400.
  FREE GT_MAIN_DISP_400.

* 사급자재 수량정보
  READ TABLE PS_MAINTAIN-T_CAT INTO LS_MAIN_CONTMNG WITH KEY SEQ_CATALOG = 11.
* 신선자재 수량정보
  READ TABLE PS_MAINTAIN-T_CAT INTO LS_MAIN_MOVEMNG WITH KEY SEQ_CATALOG = 12.

* 일자별 수량 입력 필드 구성
  LOOP AT GT_DATE INTO GS_DATE.
    CLEAR GS_MAIN_DISP_400.
    ADD 1 TO LV_SEQNO.
    GS_MAIN_DISP_400-SEQ_FIELD = LV_SEQNO.
    GS_MAIN_DISP_400-FIELDNAME = GS_DATE-DATE.
    GS_MAIN_DISP_400-GUBUN = 'D'.

    CLEAR GS_DIFINE_DAY.
    READ TABLE LS_MAIN_CONTMNG-T_DAY INTO GS_DIFINE_DAY WITH KEY DATE = GS_DATE-DATE.
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP_400-CONTMNG = GS_DIFINE_DAY-PSAMG.
    ENDIF.

    CLEAR GS_DIFINE_DAY.
    READ TABLE LS_MAIN_MOVEMNG-T_DAY INTO GS_DIFINE_DAY WITH KEY DATE = GS_DATE-DATE.
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP_400-MOVEMNG = GS_DIFINE_DAY-PSAMG.
    ENDIF.

    APPEND GS_MAIN_DISP_400 TO GT_MAIN_DISP_400.
  ENDLOOP.

* 주차별 수량 입력 필드 구성
  LOOP AT GT_WEEK INTO GS_WEEK.
    CLEAR GS_MAIN_DISP_400.
    ADD 1 TO LV_SEQNO.
    GS_MAIN_DISP_400-SEQ_FIELD = LV_SEQNO.
    GS_MAIN_DISP_400-FIELDNAME = GS_WEEK-WEEK.
    GS_MAIN_DISP_400-GUBUN = 'W'.

    CLEAR GS_DIFINE_WEEK.
    READ TABLE LS_MAIN_CONTMNG-T_WEEK INTO GS_DIFINE_WEEK WITH KEY WEEK = GS_WEEK-WEEK.
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP_400-CONTMNG = GS_DIFINE_WEEK-GSMNG.
    ENDIF.

    CLEAR GS_DIFINE_WEEK.
    READ TABLE LS_MAIN_MOVEMNG-T_WEEK INTO GS_DIFINE_WEEK WITH KEY WEEK = GS_WEEK-WEEK.
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP_400-MOVEMNG = GS_DIFINE_WEEK-GSMNG.
    ENDIF.

    APPEND GS_MAIN_DISP_400 TO GT_MAIN_DISP_400.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0400 .

  CREATE OBJECT GO_DOCKING_0400
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
*화면 분할
  CREATE OBJECT GO_SPLITTER_0400
    EXPORTING
      PARENT  = GO_DOCKING_0400
      ROWS    = 2
      COLUMNS = 1.

  GO_SPLITTER_0400->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    12 ).             " Height

** top 컨테이너
  CALL METHOD GO_SPLITTER_0400->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_TOP_0400.

* bottom 컨테이너
  CALL METHOD GO_SPLITTER_0400->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0400.

  CREATE OBJECT GO_GRID_0400
    EXPORTING
      I_PARENT      = GO_CONTAIN_0400
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0400 .

  CLEAR GS_LAYOUT_0400.
  GS_LAYOUT_0400-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0400-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT_0400-SEL_MODE  = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0400 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0400
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0400 .

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LV_DATE TYPE SY-DATUM.

  REFRESH GT_FIELDCAT_0400.
  FREE GT_FIELDCAT_0400.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = 'GS_MAIN_DISP_400'
      I_INCLNAME         = 'ZGTPPR2110TOP'
      I_BYPASSING_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT        = LT_FCAT.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0400[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_300.

  READ TABLE GT_FIELDCAT_0400 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'SEQ_FIELD'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0400 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-FIELDNAME = 'SEQ_FIELD'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'INT4'.
    <LS_FCAT>-DD_OUTLEN = '11'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
    UNASSIGN <LS_FCAT>.
  ENDIF.

  READ TABLE GT_FIELDCAT_0400 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'FIELDNAME'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0400 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-FIELDNAME = 'FIELDNAME'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
*    <LS_FCAT>-NO_OUT = ABAP_TRUE.
    UNASSIGN <LS_FCAT>.
  ENDIF.

  READ TABLE GT_FIELDCAT_0400 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'GUBUN'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0400 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 3.
    <LS_FCAT>-FIELDNAME = 'GUBUN'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기간단위'.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-COL_OPT = ABAP_TRUE.
    UNASSIGN <LS_FCAT>.
  ENDIF.

* 필드명 서술
  LOOP AT GT_FIELDCAT_0400 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'FIELDNAME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획일'(f17).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'GUBUN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기간단위'(f16).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'STATUS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '상태'(f13).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'CONTMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '사급자재출고 수량'(f18).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-OUTPUTLEN = 12.
        <LS_FCAT>-QUANTITY = 'EA'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'MOVEMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '신선자재출고 수량'(f19).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-OUTPUTLEN = 12.
        <LS_FCAT>-QUANTITY = 'EA'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

  SORT GT_FIELDCAT_0400 BY COL_POS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0400 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_STYLE TYPE LVC_STYLE.

  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

  LOOP AT GT_MAIN_DISP_400 ASSIGNING FIELD-SYMBOL(<LS_DATA>).

    REFRESH LT_CELLTAB.

    LOOP AT GT_FIELDCAT_0400 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
      CASE <LS_FCAT>-FIELDNAME.
        WHEN 'FIELDNAME' OR 'GUBUN' OR 'STATUS'.
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = <LS_FCAT>-FIELDNAME.
          LS_CELLTAB-STYLE = ALV_STYLE_COLOR_KEY.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
      ENDCASE.
    ENDLOOP.

    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <LS_DATA> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0400 .

  PERFORM SET_SORT_TAB TABLES GT_SORT_0400
                                  USING : 1 'SEQ_FIELD' 'X' '' '',
                                        2 'FIELDNAME'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0400_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0400_DISPLAY .

  CALL METHOD GO_GRID_0400->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0400
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0400
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_400
      IT_SORT              = GT_SORT_0400
      IT_FIELDCATALOG      = GT_FIELDCAT_0400.

  IF GO_DD_DOCU_0400 IS BOUND.
    CALL METHOD GO_DD_DOCU_0400->INITIALIZE_DOCUMENT.
  ELSE.
    CREATE OBJECT GO_DD_DOCU_0400
      EXPORTING
        STYLE = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD GO_GRID_0400->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DD_DOCU_0400.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0400->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0400->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHANGE_JEGO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_MAINTAIN>
*&---------------------------------------------------------------------*
FORM SET_CHANGE_JEGO  CHANGING PS_MAINTAIN  LIKE GS_MAINTAIN_MAIN
                                                   PV_ERR_CHK.

  DATA : LV_ORIGN_MNG TYPE CO_PSMNG.
  DATA : LV_CHANGE_MNG TYPE CO_PSMNG.
  DATA : LS_SAVE_TAB TYPE ZGTPPT2153.
  DATA : LT_SAVE_TAB LIKE TABLE OF ZGTPPT2153.
  DATA : LT_DEL_TAB LIKE TABLE OF ZGTPPT2153.
  DATA : LV_CHK_DATE TYPE SY-DATUM.
  DATA : LT_ITEM TYPE TABLE OF ZGTPPSIF0036.


  READ TABLE PS_MAINTAIN-T_CAT ASSIGNING FIELD-SYMBOL(<LS_CONTMNG>) WITH KEY SEQ_CATALOG = 11.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO PS_MAINTAIN-T_CAT ASSIGNING <LS_CONTMNG>.
    <LS_CONTMNG>-SEQ_CATALOG = 11.
    IF PS_MAINTAIN-ATWRT = 'G4'.
      <LS_CONTMNG>-CATALOG = '사급(G4)'.
    ELSE.
      <LS_CONTMNG>-CATALOG = '사급'.
    ENDIF.
  ENDIF.

  READ TABLE PS_MAINTAIN-T_CAT ASSIGNING FIELD-SYMBOL(<LS_MOVEMNG>) WITH KEY SEQ_CATALOG = 12.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO PS_MAINTAIN-T_CAT ASSIGNING <LS_MOVEMNG>.
    <LS_MOVEMNG>-SEQ_CATALOG = 12.
    IF PS_MAINTAIN-ATWRT = 'G4'.
      <LS_MOVEMNG>-CATALOG = '신선(G4)'.
    ELSE.
      <LS_MOVEMNG>-CATALOG = '신선'.
    ENDIF.
  ENDIF.

  READ TABLE PS_MAINTAIN-T_CAT ASSIGNING FIELD-SYMBOL(<LS_JEGO>) WITH KEY SEQ_CATALOG = 60.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO PS_MAINTAIN-T_CAT ASSIGNING <LS_JEGO>.
    <LS_MOVEMNG>-SEQ_CATALOG = 60.
    <LS_MOVEMNG>-CATALOG = '마이너스수량'.
  ENDIF.

  LOOP AT GT_MAIN_DISP_400 INTO DATA(LS_MAIN) WHERE STATUS = ICON_CHANGE.
    CLEAR : LV_ORIGN_MNG, LV_CHANGE_MNG.

* 관리테이블 저장위한 인터널테이블 구성
*   조회일자
    CLEAR LV_CHK_DATE.
    CASE LS_MAIN-GUBUN.
      WHEN 'D'.
        LV_CHK_DATE = LS_MAIN-FIELDNAME.
      WHEN 'W'.
        CLEAR GS_WEEK.
        READ TABLE GT_WEEK INTO GS_WEEK WITH KEY WEEK = LS_MAIN-FIELDNAME.
        IF SY-SUBRC EQ 0.
          LV_CHK_DATE = GS_WEEK-FRDATE.
        ENDIF.
    ENDCASE.

    CLEAR LS_SAVE_TAB.
    READ TABLE GT_2153 INTO LS_SAVE_TAB WITH KEY WERKS = P_WERKS
                                                                          MATNR = PS_MAINTAIN-MATNR
                                                                          SCRGRADE = PS_MAINTAIN-ATWRT
                                                                          RQDAY = LV_CHK_DATE.
    IF SY-SUBRC EQ 0.
      APPEND LS_SAVE_TAB TO LT_DEL_TAB.
      LS_SAVE_TAB-CONTMNG = LS_MAIN-CONTMNG.
      LS_SAVE_TAB-MOVEMNG = LS_MAIN-MOVEMNG.
      PERFORM SET_IF_STRUCTURE TABLES LT_ITEM USING LS_SAVE_TAB.
      IF LS_SAVE_TAB-CONTMNG NE 0 OR LS_SAVE_TAB-MOVEMNG NE 0.
        APPEND LS_SAVE_TAB TO LT_SAVE_TAB.
      ENDIF.
    ELSE.
      LS_SAVE_TAB-WERKS = P_WERKS.
      LS_SAVE_TAB-MATNR = PS_MAINTAIN-MATNR.
      LS_SAVE_TAB-SCRGRADE = PS_MAINTAIN-ATWRT.
      LS_SAVE_TAB-RQDAY = LV_CHK_DATE.
      LS_SAVE_TAB-CONTMNG = LS_MAIN-CONTMNG.
      LS_SAVE_TAB-MOVEMNG = LS_MAIN-MOVEMNG.
      PERFORM SET_IF_STRUCTURE TABLES LT_ITEM USING LS_SAVE_TAB.
      IF LS_SAVE_TAB-CONTMNG NE 0 OR LS_SAVE_TAB-MOVEMNG NE 0.
        APPEND LS_SAVE_TAB TO LT_SAVE_TAB.
      ENDIF.
    ENDIF.

* 인터페이스 항목 적용
    CASE LS_MAIN-GUBUN.
      WHEN 'D'.
*       사급자재
        READ TABLE <LS_CONTMNG>-T_DAY ASSIGNING FIELD-SYMBOL(<LS_DIFINE_DAY>) WITH KEY DATE = LS_MAIN-FIELDNAME.
        IF SY-SUBRC EQ 0.
          ADD <LS_DIFINE_DAY>-PSAMG TO LV_ORIGN_MNG.
          <LS_DIFINE_DAY>-PSAMG = LS_MAIN-CONTMNG.
          ADD <LS_DIFINE_DAY>-PSAMG TO LV_CHANGE_MNG.
          <LS_DIFINE_DAY>-CHANGE = ABAP_TRUE.
        ELSE.
          APPEND INITIAL LINE TO <LS_CONTMNG>-T_DAY ASSIGNING <LS_DIFINE_DAY>.
          <LS_DIFINE_DAY>-DATE = LS_MAIN-FIELDNAME.
          <LS_DIFINE_DAY>-PSAMG = LS_MAIN-CONTMNG.
          ADD <LS_DIFINE_DAY>-PSAMG TO LV_CHANGE_MNG.
          <LS_DIFINE_DAY>-CHANGE = ABAP_TRUE.
        ENDIF.

*       신선자재
        READ TABLE <LS_MOVEMNG>-T_DAY ASSIGNING <LS_DIFINE_DAY> WITH KEY DATE = LS_MAIN-FIELDNAME.
        IF SY-SUBRC EQ 0.
          ADD <LS_DIFINE_DAY>-PSAMG TO LV_ORIGN_MNG.
          <LS_DIFINE_DAY>-PSAMG = LS_MAIN-MOVEMNG.
          ADD <LS_DIFINE_DAY>-PSAMG TO LV_CHANGE_MNG.
          <LS_DIFINE_DAY>-CHANGE = ABAP_TRUE.
        ELSE.
          APPEND INITIAL LINE TO <LS_MOVEMNG>-T_DAY ASSIGNING <LS_DIFINE_DAY>.
          <LS_DIFINE_DAY>-DATE = LS_MAIN-FIELDNAME.
          <LS_DIFINE_DAY>-PSAMG = LS_MAIN-MOVEMNG.
          ADD <LS_DIFINE_DAY>-PSAMG TO LV_CHANGE_MNG.
          <LS_DIFINE_DAY>-CHANGE = ABAP_TRUE.
        ENDIF.

*       -수량 재정의
        READ TABLE <LS_JEGO>-T_DAY ASSIGNING <LS_DIFINE_DAY> WITH KEY DATE = LS_MAIN-FIELDNAME.
        IF SY-SUBRC EQ 0.
          <LS_DIFINE_DAY>-PSAMG = <LS_DIFINE_DAY>-PSAMG + LV_ORIGN_MNG - LV_CHANGE_MNG.
        ELSE.
          APPEND INITIAL LINE TO <LS_JEGO>-T_DAY ASSIGNING <LS_DIFINE_DAY>.
          <LS_DIFINE_DAY>-DATE = LS_MAIN-FIELDNAME.
          <LS_DIFINE_DAY>-PSAMG = <LS_DIFINE_DAY>-PSAMG + LV_ORIGN_MNG - LV_CHANGE_MNG.
        ENDIF.

      WHEN 'W'.
*       사급자재
        READ TABLE <LS_CONTMNG>-T_WEEK ASSIGNING FIELD-SYMBOL(<LS_DIFINE_WEEK>) WITH KEY WEEK = LS_MAIN-FIELDNAME.
        IF SY-SUBRC EQ 0.
          ADD <LS_DIFINE_WEEK>-GSMNG TO LV_ORIGN_MNG.
          <LS_DIFINE_WEEK>-GSMNG = LS_MAIN-CONTMNG.
          ADD <LS_DIFINE_WEEK>-GSMNG TO LV_CHANGE_MNG.
          <LS_DIFINE_WEEK>-CHANGE = ABAP_TRUE.
        ELSE.
          APPEND INITIAL LINE TO <LS_CONTMNG>-T_WEEK ASSIGNING <LS_DIFINE_WEEK>.
          <LS_DIFINE_WEEK>-WEEK = LS_MAIN-FIELDNAME.
          <LS_DIFINE_WEEK>-GSMNG = LS_MAIN-CONTMNG.
          ADD <LS_DIFINE_WEEK>-GSMNG TO LV_CHANGE_MNG.
          <LS_DIFINE_WEEK>-CHANGE = ABAP_TRUE.
        ENDIF.

*       신선자재
        READ TABLE <LS_MOVEMNG>-T_WEEK ASSIGNING <LS_DIFINE_WEEK> WITH KEY WEEK = LS_MAIN-FIELDNAME.
        IF SY-SUBRC EQ 0.
          ADD <LS_DIFINE_WEEK>-GSMNG TO LV_ORIGN_MNG.
          <LS_DIFINE_WEEK>-GSMNG = LS_MAIN-MOVEMNG.
          ADD <LS_DIFINE_WEEK>-GSMNG TO LV_CHANGE_MNG.
          <LS_DIFINE_WEEK>-CHANGE = ABAP_TRUE.
        ELSE.
          APPEND INITIAL LINE TO <LS_MOVEMNG>-T_WEEK ASSIGNING <LS_DIFINE_WEEK>.
          <LS_DIFINE_WEEK>-WEEK = LS_MAIN-FIELDNAME.
          <LS_DIFINE_WEEK>-GSMNG = LS_MAIN-MOVEMNG.
          ADD <LS_DIFINE_WEEK>-GSMNG TO LV_CHANGE_MNG.
          <LS_DIFINE_WEEK>-CHANGE = ABAP_TRUE.
        ENDIF.

*       -수량 재정의
        READ TABLE <LS_JEGO>-T_WEEK ASSIGNING <LS_DIFINE_WEEK> WITH KEY WEEK = LS_MAIN-FIELDNAME.
        IF SY-SUBRC EQ 0.
          <LS_DIFINE_WEEK>-GSMNG = <LS_DIFINE_WEEK>-GSMNG + LV_ORIGN_MNG - LV_CHANGE_MNG.
        ELSE.
          APPEND INITIAL LINE TO <LS_JEGO>-T_WEEK ASSIGNING <LS_DIFINE_WEEK>.
          <LS_DIFINE_WEEK>-WEEK = LS_MAIN-FIELDNAME.
          <LS_DIFINE_WEEK>-GSMNG = <LS_DIFINE_WEEK>-GSMNG + LV_ORIGN_MNG - LV_CHANGE_MNG.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  IF LT_DEL_TAB IS NOT INITIAL.
    DELETE ZGTPPT2153 FROM TABLE LT_DEL_TAB.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S005 DISPLAY LIKE 'E' WITH '차감재고 저장중 오류 발생하였습니다.'.
      PV_ERR_CHK = ABAP_TRUE.
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_SAVE_TAB IS NOT INITIAL.
    MODIFY ZGTPPT2153 FROM TABLE LT_SAVE_TAB.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S005 DISPLAY LIKE 'E' WITH '차감재고 저장중 오류 발생하였습니다.'.
      PV_ERR_CHK = ABAP_TRUE.
      RETURN.
    ENDIF.
  ENDIF.

  COMMIT WORK AND WAIT.

  IF LT_ITEM[] IS NOT INITIAL.
    PERFORM SEND_TO_MES TABLES LT_ITEM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SPMON_FIELD_JEGO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_MAINTAIN>
*&---------------------------------------------------------------------*
FORM SET_SPMON_FIELD_JEGO  CHANGING PS_MAINTAIN  LIKE GS_MAINTAIN_MAIN.

* 월별 합계 반영(사급)

  READ TABLE PS_MAINTAIN-T_CAT ASSIGNING FIELD-SYMBOL(<LS_CONTMNG>) WITH KEY SEQ_CATALOG = 11.
  IF SY-SUBRC EQ 0.
    LOOP AT GT_SPMON INTO GS_SPMON.
      READ TABLE <LS_CONTMNG>-T_SPMON ASSIGNING FIELD-SYMBOL(<LS_SPMON>) WITH KEY GS_SPMON-FIELDNAME.
      IF SY-SUBRC NE 0.
        APPEND INITIAL LINE TO <LS_CONTMNG>-T_SPMON ASSIGNING <LS_SPMON>.
        <LS_SPMON>-SPMON = GS_SPMON-SPMON.
      ELSE.
        CLEAR <LS_SPMON>-GSMNG.
      ENDIF.

      LOOP AT <LS_CONTMNG>-T_DAY INTO GS_DIFINE_DAY WHERE DATE+0(6) = GS_SPMON-SPMON.
        ADD GS_DIFINE_DAY-PSAMG TO <LS_SPMON>-GSMNG.
      ENDLOOP.


      LOOP AT GT_WEEK INTO GS_WEEK WHERE FRDATE+0(6) = GS_SPMON-SPMON.
        READ TABLE <LS_CONTMNG>-T_WEEK INTO GS_DIFINE_WEEK WITH KEY WEEK = GS_WEEK-WEEK.
        IF SY-SUBRC EQ 0.
          ADD GS_DIFINE_WEEK-GSMNG TO <LS_SPMON>-GSMNG.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

    SORT <LS_CONTMNG>-T_SPMON BY SPMON.
  ENDIF.

* 월별 합계 반영(신선)
  READ TABLE PS_MAINTAIN-T_CAT ASSIGNING FIELD-SYMBOL(<LS_MOVEMNG>) WITH KEY SEQ_CATALOG = 12.
  IF SY-SUBRC EQ 0.
    LOOP AT GT_SPMON INTO GS_SPMON.
      READ TABLE <LS_MOVEMNG>-T_SPMON ASSIGNING <LS_SPMON> WITH KEY GS_SPMON-FIELDNAME.
      IF SY-SUBRC NE 0.
        APPEND INITIAL LINE TO <LS_MOVEMNG>-T_SPMON ASSIGNING <LS_SPMON>.
        <LS_SPMON>-SPMON = GS_SPMON-SPMON.
      ELSE.
        CLEAR <LS_SPMON>-GSMNG.
      ENDIF.

      LOOP AT <LS_MOVEMNG>-T_DAY INTO GS_DIFINE_DAY WHERE DATE+0(6) = GS_SPMON-SPMON.
        ADD GS_DIFINE_DAY-PSAMG TO <LS_SPMON>-GSMNG.
      ENDLOOP.


      LOOP AT GT_WEEK INTO GS_WEEK WHERE FRDATE+0(6) = GS_SPMON-SPMON.
        READ TABLE <LS_MOVEMNG>-T_WEEK INTO GS_DIFINE_WEEK WITH KEY WEEK = GS_WEEK-WEEK.
        IF SY-SUBRC EQ 0.
          ADD GS_DIFINE_WEEK-GSMNG TO <LS_SPMON>-GSMNG.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

    SORT <LS_MOVEMNG>-T_SPMON BY SPMON.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_SCREEN400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PO_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM SET_TITLE_SCREEN400  CHANGING PO_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  DATA : LV_TEXT(255) TYPE C.
  DATA : LV_FR_SPMON(10).
  DATA : LV_TO_SPMON(10).

* 자재명
  CLEAR LV_TEXT.
  CONCATENATE '자재명 :' GS_HEADER_0400-MAKTX INTO LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PO_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PO_DYNDOC_ID->NEW_LINE.

* 등급
  IF GS_HEADER_0400-ATWRT IS NOT INITIAL.
    CLEAR LV_TEXT.
    CONCATENATE '등급 :' GS_HEADER_0400-ATWRT INTO LV_TEXT SEPARATED BY SPACE.
    "텍스트 추가
    CALL METHOD PO_DYNDOC_ID->ADD_TEXT
      EXPORTING
        TEXT         = LV_TEXT
        SAP_FONTSIZE = '20'.

    CALL METHOD PO_DYNDOC_ID->NEW_LINE.
  ENDIF.

  "위쪽에 추가한 텍스트 출력
  CALL METHOD PO_DYNDOC_ID->DISPLAY_DOCUMENT
    EXPORTING
      PARENT             = GO_CONTAIN_TOP_0400
      REUSE_CONTROL      = ABAP_TRUE
      REUSE_REGISTRATION = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_IF_STRUCTURE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ITEM
*&      --> LS_SAVE_TAB
*&---------------------------------------------------------------------*
FORM SET_IF_STRUCTURE  TABLES   PT_ITEM STRUCTURE ZGTPPSIF0036
                       USING    PS_SAVE_TAB TYPE ZGTPPT2153.

  DATA : LS_ITEM TYPE ZGTPPSIF0036.

* 사급자재(CN)
  CLEAR LS_ITEM.
  LS_ITEM-WERKS = PS_SAVE_TAB-WERKS.
  LS_ITEM-MATNR = PS_SAVE_TAB-MATNR.
  LS_ITEM-PLCTG = 'CN'.
  LS_ITEM-RQDAY = PS_SAVE_TAB-RQDAY.
  LS_ITEM-SCRGRADE = PS_SAVE_TAB-SCRGRADE.
  LS_ITEM-MENGE = PS_SAVE_TAB-CONTMNG.
  LS_ITEM-MEINS = 'KG'.
  APPEND LS_ITEM TO PT_ITEM.

* 신선자재(DW)
  CLEAR LS_ITEM.
  LS_ITEM-WERKS = PS_SAVE_TAB-WERKS.
  LS_ITEM-MATNR = PS_SAVE_TAB-MATNR.
  LS_ITEM-PLCTG = 'DW'.
  LS_ITEM-RQDAY = PS_SAVE_TAB-RQDAY.
  LS_ITEM-SCRGRADE = PS_SAVE_TAB-SCRGRADE.
  LS_ITEM-MENGE = PS_SAVE_TAB-MOVEMNG.
  LS_ITEM-MEINS = 'KG'.
  APPEND LS_ITEM TO PT_ITEM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_TO_MES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ITEM
*&---------------------------------------------------------------------*
FORM SEND_TO_MES  TABLES   PT_ITEM STRUCTURE ZGTPPSIF0036.

  DATA : LV_DEST TYPE ZIFDEST-DEST.
  DATA : LV_RESULT  TYPE ZO_RESULT,
         LV_MESSAGE TYPE ZO_MESSAGE.
  DATA : LV_TIMESTAMP TYPE TIMESTAMPL.
  DATA : LT_ITEM TYPE TABLE OF ZGTPPSIF0036.

  DATA : LT_LOG_TAB TYPE TABLE OF ZGTPPT2240.

* 전송대상 시스쳄 소재 MES
  CONSTANTS : LC_TARGET TYPE ZGTPPT1020-ZSYSTEM_ID VALUE 'KSCM'.

  LT_ITEM = PT_ITEM[].

* 전송데이터 앞에 0제거
  LOOP AT LT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = <LS_ITEM>-MATNR
      IMPORTING
        OUTPUT = <LS_ITEM>-MATNR.
  ENDLOOP.

*- Destination 가져오기
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      GUBUN                 = 'P1'    "Destination 점검
    IMPORTING
      DEST_NAME             = LV_DEST
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.

  CALL FUNCTION 'ZGTPP_IF_ETC_PLAN' DESTINATION LV_DEST
    EXPORTING
      I_SYSTEM_ID = LC_TARGET
    IMPORTING
      ZO_RESULT   = LV_RESULT
      ZO_MESSAGE  = LV_MESSAGE
    TABLES
      OT_ITEM     = LT_ITEM[].

*- History_Table에 저장
  IF LV_RESULT = '00' OR LV_RESULT = '0'.
    IF LV_MESSAGE IS INITIAL.
      LV_MESSAGE    = |전송성공|.
    ENDIF.
  ELSE.
    IF LV_MESSAGE IS INITIAL.
      LV_MESSAGE = |전송실패|.
    ENDIF.
  ENDIF.

  GET TIME STAMP FIELD LV_TIMESTAMP.
* 송신 로그 저장
  LOOP AT PT_ITEM INTO DATA(LS_ITEM).
    APPEND INITIAL LINE TO LT_LOG_TAB ASSIGNING FIELD-SYMBOL(<LS_LOG_TAB>).
    MOVE-CORRESPONDING LS_ITEM TO <LS_LOG_TAB>.
    <LS_LOG_TAB>-ZIFKEY = LV_TIMESTAMP.
    <LS_LOG_TAB>-ZSYSTEM_ID = LC_TARGET.
    <LS_LOG_TAB>-ZSTAT = LV_RESULT.
    <LS_LOG_TAB>-ZMESSAGE = LV_MESSAGE.
    <LS_LOG_TAB>-IFDAT = SY-DATUM.
    <LS_LOG_TAB>-IFTIM = SY-UZEIT.
    <LS_LOG_TAB>-IFNAM = SY-UNAME.

  ENDLOOP.

  MODIFY ZGTPPT2240 FROM TABLE LT_LOG_TAB.
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_IF_DATA_FR_PLNUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_PLAF_PLNUM
*&---------------------------------------------------------------------*
FORM SET_IF_DATA_FR_PLNUM  USING    PV_PLNUM TYPE PLNUM
                                                         PV_GSMNG TYPE GSMNG.

  DATA : LV_PLNUM TYPE PLNUM.
  DATA : LS_CHK_PLAF LIKE GS_PLAF.

  LV_PLNUM = PV_PLNUM.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = LV_PLNUM
    IMPORTING
      OUTPUT = LV_PLNUM.

  CLEAR GS_PLAF.
  READ TABLE GT_PLAF INTO GS_PLAF WITH KEY PLNUM = LV_PLNUM.
  IF SY-SUBRC NE 0.
    CLEAR LS_CHK_PLAF.
    SELECT SINGLE PLNUM, MATNR, PSTTR, PTEXT, GSMNG, MEINS
      FROM PLAF
      INTO CORRESPONDING FIELDS OF @LS_CHK_PLAF
     WHERE PLNUM = @LV_PLNUM.
    IF SY-SUBRC EQ 0 AND LS_CHK_PLAF IS NOT INITIAL..
      MOVE-CORRESPONDING LS_CHK_PLAF TO GS_PLAF.
    ELSE. " 대상건이 없으므로 IF 적재 불가
      RETURN.
    ENDIF.
  ENDIF.

  READ TABLE GT_WP_SEND ASSIGNING FIELD-SYMBOL(<LS_WP_SEND>) WITH KEY MATNR = GS_PLAF-MATNR
                                                                                                             PLCTG = 'WP'
                                                                                                             RQDAY = GS_PLAF-PSTTR.
  IF SY-SUBRC EQ 0. "일자별 자재별 점검
    RETURN.
  ELSE.
    APPEND INITIAL LINE TO GT_WP_SEND ASSIGNING <LS_WP_SEND>.
    <LS_WP_SEND>-WERKS = P_WERKS.
    <LS_WP_SEND>-MATNR = GS_PLAF-MATNR.
    <LS_WP_SEND>-PLCTG = 'WP'.
    <LS_WP_SEND>-RQDAY = GS_PLAF-PSTTR.
    <LS_WP_SEND>-SCRGRADE = ''. " 계획은 등급 구분 미존재
    <LS_WP_SEND>-MENGE = PV_GSMNG. .
    <LS_WP_SEND>-MEINS = 'KG'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DAILY_OPERATING_HOURS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DAILY_OPERATING_HOURS .

  DATA : LV_MENGE TYPE MENGE_D.

  LOOP AT GT_DATE INTO GS_DATE.
    READ TABLE GT_2150 INTO DATA(LS_2150) WITH KEY PLDAT = GS_DATE-DATE.
    IF SY-SUBRC EQ 0.
      LV_MENGE = LS_2150-OPRTIM + 0.
    ELSE.
      READ TABLE GT_DAY_ATTR INTO DATA(LS_CHK_DATE) WITH KEY DATE = GS_DATE-DATE.
      IF SY-SUBRC EQ 0 AND ( LS_CHK_DATE-WEEKDAY = 6 OR LS_CHK_DATE-WEEKDAY = 7 ).
        LV_MENGE = 0.
      ELSE.
        LV_MENGE = 24.
      ENDIF.
    ENDIF.

    READ TABLE GT_WP_SEND ASSIGNING FIELD-SYMBOL(<LS_WP_SEND>) WITH KEY PLCTG = 'RT'
                                                                                                               RQDAY = GS_PLAF-PSTTR.
    IF SY-SUBRC EQ 0.
      RETURN.
    ELSE.
      APPEND INITIAL LINE TO GT_WP_SEND ASSIGNING <LS_WP_SEND>.
      <LS_WP_SEND>-WERKS = P_WERKS.
      <LS_WP_SEND>-PLCTG = 'RT'.
      <LS_WP_SEND>-RQDAY = GS_DATE-DATE.
      <LS_WP_SEND>-MENGE = LV_MENGE. .
      <LS_WP_SEND>-MEINS = 'H'.
    ENDIF.

  ENDLOOP.

ENDFORM.
