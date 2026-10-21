*&---------------------------------------------------------------------*
*& Include          ZGTPPR2280F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INIT_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_SCREEN .

  CALL FUNCTION 'DATE_GET_WEEK'
    EXPORTING
      DATE         = SY-DATUM
    IMPORTING
      WEEK         = P_WEEK
    EXCEPTIONS
      DATE_INVALID = 1
      OTHERS       = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  GV_CHK_WEEK = P_WEEK.

  CALL FUNCTION 'WEEK_GET_FIRST_DAY'
    EXPORTING
      WEEK         = P_WEEK
    IMPORTING
      DATE         = P_WEEKFR
    EXCEPTIONS
      WEEK_INVALID = 1
      OTHERS       = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  P_WEEKTO = P_WEEKFR + 6.

  GET PARAMETER ID 'WRK' FIELD P_WERKS.
  GET PARAMETER ID 'ZSPG' FIELD P_SPGCD.
  GET PARAMETER ID 'ZEGONG_CD' FIELD P_GONGCD.

  PERFORM GET_PARAMETER_DESCRIPTION.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SELECTION_PERIOD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SELECTION_PERIOD .

  IF S_GSTRP[] IS NOT INITIAL.
    READ TABLE S_GSTRP INDEX 1.
  ENDIF.

  REFRESH S_GSTRP[].
  S_GSTRP-SIGN = 'I'.
  S_GSTRP-OPTION = 'BT'.


  IF S_GSTRP-LOW IS INITIAL.
    S_GSTRP-LOW = SY-DATUM.
  ENDIF.

  IF S_GSTRP-HIGH IS INITIAL.
    CALL FUNCTION '/BEV4/PLPS__ADD_MONTH_TO_DATE'
      EXPORTING
        MONTHS  = '1'
        OLDDATE = SY-DATUM
      IMPORTING
        NEWDATE = S_GSTRP-HIGH.
  ENDIF.
  APPEND S_GSTRP.

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

* 플랜트명
  IF NOT P_GONGCD IS INITIAL.
    SELECT SINGLE GONG_NM INTO P_GONGNM
             FROM ZEDT0011
            WHERE GONG_CD EQ P_GONGCD.
  ELSE.
    CLEAR P_GONGNM.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIRST_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_FIRST_SCREEN .

  LOOP AT SCREEN.
    CASE ABAP_TRUE.
      WHEN P_DISP.

        IF SCREEN-GROUP1 = 'M1'.
          SCREEN-INPUT = 0.
          SCREEN-INTENSIFIED = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP1 = 'M2'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP1 = 'M3'.
          SCREEN-ACTIVE = 0.
          SCREEN-REQUIRED = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP1 = 'S2'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.

      WHEN P_PLAN.
        CASE SCREEN-NAME.
          WHEN 'P_GONGCD'.
            SCREEN-REQUIRED = 2.
            MODIFY SCREEN.
        ENDCASE.

        IF SCREEN-GROUP1 = 'M1'.
          SCREEN-INPUT = 0.
          SCREEN-INTENSIFIED = 1.
          MODIFY SCREEN.
        ENDIF.
        IF SCREEN-GROUP1 = 'M2'.
          SCREEN-INPUT = 0.
          SCREEN-INTENSIFIED = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP1 = 'M3'.
          SCREEN-ACTIVE = 1.
          SCREEN-REQUIRED = 2.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP1 = 'S1'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.


    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_WEEK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_WEEK  USING    PV_DYNPROFLD TYPE HELP_INFO-DYNPROFLD .

  DATA : LV_DATUM TYPE SY-DATUM.
  DATA : LV_WEEK TYPE SCAL-WEEK.
  DATA : LV_WEEKFR TYPE SY-DATUM.
  DATA : LV_WEEKTO TYPE SY-DATUM.
  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.


  CALL FUNCTION 'F4_DATE'
    EXPORTING
      DATE_FOR_FIRST_MONTH         = SY-DATUM
    IMPORTING
      SELECT_DATE                  = LV_DATUM
*     SELECT_WEEK                  = LV_WEEK
*     SELECT_WEEK_BEGIN            = LV_WEEKFR
*     SELECT_WEEK_END              = LV_WEEKTO
    EXCEPTIONS
      CALENDAR_BUFFER_NOT_LOADABLE = 1
      DATE_AFTER_RANGE             = 2
      DATE_BEFORE_RANGE            = 3
      DATE_INVALID                 = 4
      FACTORY_CALENDAR_NOT_FOUND   = 5
      HOLIDAY_CALENDAR_NOT_FOUND   = 6
      PARAMETER_CONFLICT           = 7
      OTHERS                       = 8.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  CHECK LV_DATUM IS NOT INITIAL.

  CALL FUNCTION 'DATE_GET_WEEK'
    EXPORTING
      DATE         = LV_DATUM
    IMPORTING
      WEEK         = LV_WEEK
    EXCEPTIONS
      DATE_INVALID = 1
      OTHERS       = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  CALL FUNCTION 'WEEK_GET_FIRST_DAY'
    EXPORTING
      WEEK         = LV_WEEK
    IMPORTING
      DATE         = LV_WEEKFR
    EXCEPTIONS
      WEEK_INVALID = 1
      OTHERS       = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  LV_WEEKTO = LV_WEEKFR + 6.

  IF LV_WEEK IS NOT INITIAL.

    REFRESH LT_DYNPFIELDS.
    PERFORM GET_STEPL USING LV_LINE.
*      선택주차
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
    <LS_DYNPFIELDS>-FIELDNAME = PV_DYNPROFLD.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LV_WEEK.

*      주차 시작일
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING <LS_DYNPFIELDS>.
    <LS_DYNPFIELDS>-FIELDNAME = 'P_WEEKFR'.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LV_WEEKFR.

*      주차 종료일
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING <LS_DYNPFIELDS>.
    <LS_DYNPFIELDS>-FIELDNAME = 'P_WEEKTO'.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LV_WEEKTO.

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
*& Form F4_GONG_CD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_GONG_CD  USING    PV_DYNPROFLD TYPE HELP_INFO-DYNPROFLD .

  DATA : BEGIN OF LS_GONG,
           GONG_CD TYPE ZEDT0011-GONG_CD,
           GONG_NM TYPE ZEDT0011-GONG_NM,
         END OF LS_GONG.
  DATA : LT_GONG LIKE TABLE OF LS_GONG.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LV_OFFSET(6) TYPE N.
  DATA : LO_FLIEF TYPE REF TO DATA.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

  SELECT DISTINCT B~GONG_CD, C~GONG_NM
    INTO CORRESPONDING FIELDS OF TABLE @LT_GONG
    FROM T001K AS A
    INNER JOIN ZEDT0010 AS B ON B~BUKRS = A~BUKRS
    INNER JOIN ZEDT0011 AS C ON C~GONG_CD = B~GONG_CD
    INNER JOIN ZPPT0107 AS E ON E~SPART = B~SPART
                                     AND E~WERKS = A~BWKEY
   WHERE A~BWKEY = @P_WERKS
      AND E~SPGCD = @P_SPGCD.

  SORT LT_GONG BY GONG_CD.

* 필드 속성 정의
  FREE LO_FLIEF.
  CREATE DATA LO_FLIEF LIKE LS_GONG.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).

    CASE <LS_FIELD_TAB>-FIELDNAME.
      WHEN 'GONG_CD'.
        <LS_FIELD_TAB>-REPTEXT  = '공정'.
      WHEN 'GONG_NM'.
        <LS_FIELD_TAB>-REPTEXT  = '공정명'.
    ENDCASE.

    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'GONG_CD'
      DYNPROFIELD     = PV_DYNPROFLD
      VALUE_ORG       = 'S'
      WINDOW_TITLE    = '공정 조회'
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = LT_GONG                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    READ TABLE LT_GONG INTO LS_GONG WITH KEY GONG_CD = LS_RETURN_TAB-FIELDVAL.

    REFRESH LT_DYNPFIELDS.
    PERFORM GET_STEPL USING LV_LINE.
*      공정
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
    <LS_DYNPFIELDS>-FIELDNAME = PV_DYNPROFLD.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_GONG-GONG_CD.

    IF PV_DYNPROFLD = 'P_GONGCD'.
*      공정명
      APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING <LS_DYNPFIELDS>.
      <LS_DYNPFIELDS>-FIELDNAME = 'P_GONGNM'.
      <LS_DYNPFIELDS>-STEPL = LV_LINE.
      <LS_DYNPFIELDS>-FIELDVALUE = LS_GONG-GONG_NM.
    ENDIF.

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
*& Form INPUT_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INPUT_CHECK .

  IF P_PLAN = ABAP_TRUE.
    IF P_GONGCD IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '필수 필드 "공정"에 입력하십시오.'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATION_OF_WEEK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VALIDATION_OF_WEEK .

  CLEAR GV_CHK_PAST.
  CHECK P_PLAN = ABAP_TRUE.
  IF GV_CHK_WEEK > P_WEEK.
    MESSAGE S006 WITH '현재주차' GV_CHK_WEEK '보다 이전 주차는 조회만 가능합니다.' .
    GV_CHK_PAST = ABAP_TRUE.
  ENDIF.


  CALL FUNCTION 'WEEK_GET_FIRST_DAY'
    EXPORTING
      WEEK         = P_WEEK
    IMPORTING
      DATE         = P_WEEKFR
    EXCEPTIONS
      WEEK_INVALID = 1
      OTHERS       = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  P_WEEKTO = P_WEEKFR + 6.

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

* 기본 조회 파라미터 세팅( 생산시작일 )
  PERFORM INIT_DATA.

  PERFORM GET_MAIN_PROD_ORDER_INFOR.

  CASE ABAP_TRUE.
    WHEN P_DISP.
      PERFORM MAKE_SCHEDULE_TABLE.

    WHEN P_PLAN.
*    요일 세팅
      PERFORM INIT_PLAN_DATA.
*    수립가능한 오더 세팅
      PERFORM MAKE_ORDER_INFO.
*    해당 설비별 순번별 수립된 데이터 세팅
      REFRESH GT_MAKE_PLAN.
      PERFORM MAKE_PLAN_DATA TABLES GT_ORDSYVAL_PLANED.
*    해당 설비별 순번별 일자별 수립된 작업 시간 관리
      REFRESH GT_WORKTIME_DAY.
      PERFORM SET_CRT_TIME_DAY.

      PERFORM RESET_ARBPL_MAIN.

*    선댁된 일자로 설비별 순번별 수립된 데이터 세팅
      REFRESH GT_MAIN_DISP_101.
      PERFORM MAKE_PLAN_DISP_DATA TABLES GT_ORDSYVAL_PLANED.

      PERFORM SET_TOTAL_DISP_TABLE.

  ENDCASE.


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

  REFRESH GT_GSTRP.
  REFRESH GT_GONGCD.
  CLEAR : GV_CHK_GO_JOJANG, GV_CHK_GO_HALF.

* 공정코드, 생산오더 시작일
  CASE ABAP_TRUE.
    WHEN P_DISP.
      MOVE-CORRESPONDING S_GSTRP[] TO GT_GSTRP.
      MOVE-CORRESPONDING S_GONGCD[] TO GT_GONGCD.

    WHEN P_PLAN.
      APPEND INITIAL LINE TO GT_GSTRP ASSIGNING FIELD-SYMBOL(<LS_GSTRP>).
      <LS_GSTRP>-SIGN = 'I'.
      <LS_GSTRP>-OPTION = 'BT'.
      <LS_GSTRP>-LOW = P_WEEKFR.
      <LS_GSTRP>-HIGH = P_WEEKTO.

      APPEND INITIAL LINE TO GT_GONGCD ASSIGNING FIELD-SYMBOL(<LS_GONGCD>).
      <LS_GONGCD>-SIGN = 'I'.
      <LS_GONGCD>-OPTION = 'EQ'.
      <LS_GONGCD>-LOW = P_GONGCD.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_SCHEDULE_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_SCHEDULE_TABLE .

* 초기 화면 구성을 위한 날짜 세팅
  PERFORM SET_DATE_FOR_DISPLAY.
* 디스플레이 화면 구성, 동적 인터널테이블 생성
  PERFORM INIT_SCREEN_200.
* 스케줄 데이터 구성
  PERFORM MAKE_MAINTAIN_SCHEDULE.
* 화면 구성
  PERFORM MAKE_DISP_TABLE_SCHEDULE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_PLAN_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_PLAN_DATA .

  DATA : LV_INDEX TYPE I.
  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LV_FIELDVALUE TYPE CHAR20.

  FIELD-SYMBOLS <LV_DAY> TYPE ANY.

  CLEAR GV_SELECTED_DAY.
  GV_SELECTED_DAY = P_WEEKFR.

  REFRESH GT_WEEK_DISP.
  CLEAR GS_WEEK_DISP.

  LV_DATE = P_WEEKFR.

  DO.
    IF LV_DATE > P_WEEKTO.
      EXIT.
    ENDIF.

    ADD 1 TO LV_INDEX.
    LV_FIELDVALUE = LV_DATE+0(4) && '.' && LV_DATE+4(2) && '.' && LV_DATE+6(2).

    CASE LV_INDEX.
      WHEN 1.
        LV_FIELDVALUE = LV_FIELDVALUE && '(월)'.
      WHEN 2.
        LV_FIELDVALUE = LV_FIELDVALUE && '(화)'.
      WHEN 3.
        LV_FIELDVALUE = LV_FIELDVALUE && '(수)'.
      WHEN 4.
        LV_FIELDVALUE = LV_FIELDVALUE && '(목)'.
      WHEN 5.
        LV_FIELDVALUE = LV_FIELDVALUE && '(금)'.
      WHEN 6.
        LV_FIELDVALUE = LV_FIELDVALUE && '(토)'.
      WHEN 7.
        LV_FIELDVALUE = LV_FIELDVALUE && '(일)'.
    ENDCASE.

    IF <LV_DAY> IS ASSIGNED. UNASSIGN <LV_DAY>. ENDIF.
    ASSIGN COMPONENT LV_INDEX OF STRUCTURE GS_WEEK_DISP TO <LV_DAY>.
    IF <LV_DAY> IS ASSIGNED.
      <LV_DAY> = LV_FIELDVALUE.
    ENDIF.

    ADD 1 TO LV_DATE.

  ENDDO.

  APPEND GS_WEEK_DISP TO GT_WEEK_DISP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MAIN_PROD_ORDER_INFOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_MAIN_PROD_ORDER_INFOR .

  DATA : LV_DISPO TYPE MARC-DISPO.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : LV_GRPNR TYPE ZGTPPT2010-GRPNR.
  DATA : LT_GRPNR TYPE RANGE OF ZGTPPT2010-GRPNR.

* SPG 테이블 조회용 필드로 변경
  LV_DISPO = P_SPGCD && '%'. "

  CASE ABAP_TRUE.
    WHEN P_DISP.
* 일정
      SELECT * FROM ZGTCVORDSYVAL
        INTO TABLE GT_ORDSYVAL
       WHERE WERKS = P_WERKS
          AND DISPO LIKE LV_DISPO
          AND PDCAPROCCODE IN GT_GONGCD
          AND ( GSTRP IN GT_GSTRP
           OR   GLTRP IN GT_GSTRP )
          AND TERKZ = '7'
          AND DLFL = ''
          AND LKD = ''
          AND CLSD = ''
          AND TECO = ''.

    WHEN P_PLAN.
* 일정수립할 오더정보( 생성오더정보)
      SELECT * FROM ZGTCVORDSYVAL
        INTO TABLE GT_ORDSYVAL
       WHERE WERKS = P_WERKS
          AND DISPO LIKE LV_DISPO
          AND PDCAPROCCODE IN GT_GONGCD
          AND MATNR IN S_MATNR
          AND TERKZ NE '7'
          AND DLFL = ''
          AND LKD = ''
          AND CLSD = ''
          AND PCNF = ''
          AND CNF = ''
          AND PDLV = ''
          AND DLV = ''
          AND TECO = ''.
* 일정수립된 오더정보
      REFRESH GT_ORDSYVAL_PLANED.
      SELECT * FROM ZGTCVORDSYVAL
        INTO TABLE GT_ORDSYVAL_PLANED
       WHERE WERKS = P_WERKS
          AND DISPO LIKE LV_DISPO
          AND PDCAPROCCODE IN GT_GONGCD
          AND ( GSTRP IN GT_GSTRP
           OR   GLTRP IN GT_GSTRP )
          AND TERKZ = '7'
          AND DLFL = ''
          AND LKD = ''
          AND CLSD = ''
          AND TECO = ''.

  ENDCASE.

  IF P_WERKS = '6600' AND P_SPGCD = 'GO' AND
    ( GV_CHK_GO_JOJANG IS INITIAL AND GV_CHK_GO_HALF IS INITIAL ).

    REFRESH : GT_2010_FUL, GT_2010.

    PERFORM CHK_DECISION_MATNR_TYPE.

    IF GV_CHK_GO_JOJANG = ABAP_TRUE.
      CLEAR LV_GRPNR.
      LV_GRPNR = 'GO%'.
      SELECT * FROM ZGTPPT2010
        INTO TABLE GT_2010
       WHERE GRPNR LIKE LV_GRPNR
         AND GRPNR IN S_GRPNR
         AND GONG_CD IN GT_GONGCD
         AND ORDTY = 'PRD'.

      SELECT DISTINCT B~*
        FROM @GT_2010 AS A
        INNER JOIN ZGTPPT2010 AS B ON B~GRPNR = A~GRPNR
        INTO TABLE @GT_2010_FUL.
    ENDIF.

    REFRESH LT_AUFNR.
    LT_AUFNR = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( ORDNR IS NOT INITIAL )
                                ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2010-ORDNR ) ).

  ENDIF.

  IF GV_CHK_GO_JOJANG NE ABAP_TRUE AND S_GRPNR[] IS NOT INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '조장 조회대상 공정이 아닙니다.'.
    LEAVE LIST-PROCESSING.
  ENDIF.

* 선택월 조장구성표 수립된 정보 가져오기
  SELECT * FROM ZGTPPT2330
    INTO TABLE GT_2330
   WHERE WERKS = P_WERKS
     AND SPGCD = P_SPGCD
     AND GONG_CD IN GT_GONGCD
     AND ZDISTRIB = '1'
     AND RQMON = P_SPMON.

  SELECT DISTINCT B~*
    FROM @GT_2330 AS A
    INNER JOIN ZGTPPT2340 AS B ON B~ZWKREQ = A~ZWKREQ
   WHERE B~ORDTY = 'PRD'
    INTO TABLE @GT_2340.

* 삭제시 대상건 확인을 위한 테이블
  REFRESH GT_2340_DEL_CHK.
  SELECT DISTINCT B~*
    FROM @GT_ORDSYVAL_PLANED AS A
    INNER JOIN ZGTPPT2340 AS B ON B~ORDNR = A~AUFNR
   WHERE B~ORDTY = 'PRD'
      AND B~GONG_CD IN @GT_GONGCD
    INTO TABLE @GT_2340_DEL_CHK.


  IF GV_CHK_GO_JOJANG IS INITIAL.
    REFRESH LT_AUFNR.
    LT_AUFNR = VALUE #( FOR LW_2340 IN GT_2340 WHERE ( ORDNR IS NOT INITIAL )
                                ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2340-ORDNR ) ).
  ENDIF.

  IF LT_AUFNR[] IS NOT INITIAL.
    SORT LT_AUFNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_AUFNR COMPARING LOW.

    SELECT DISTINCT *
      FROM ZGTCVORDSYVAL
      APPENDING TABLE GT_ORDSYVAL_PLANED
     WHERE WERKS = P_WERKS
        AND DISPO LIKE LV_DISPO
        AND PDCAPROCCODE IN GT_GONGCD
        AND AUFNR IN LT_AUFNR
        AND TERKZ = '7'
        AND DLFL = ''
        AND LKD = ''
        AND CLSD = ''
        AND TECO = ''.
    SORT GT_ORDSYVAL_PLANED BY AUFNR POSNR.
    DELETE ADJACENT DUPLICATES FROM GT_ORDSYVAL_PLANED COMPARING AUFNR POSNR.

  ENDIF.

  PERFORM GET_ETC_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ETC_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ETC_DATA .

  DATA : LT_ORDNR TYPE RANGE OF ZGTPPT2010-ORDNR.
  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LT_ERDAT TYPE RANGE OF SY-DATUM.
  DATA : LT_CHK_2070 TYPE TABLE OF ZGTPPT2270.

  LOOP AT GT_ORDSYVAL INTO DATA(LS_ORDSYVAL).
    APPEND INITIAL LINE TO LT_ORDNR ASSIGNING FIELD-SYMBOL(<LS_ORDNR>).
    <LS_ORDNR>-SIGN = 'I'.
    <LS_ORDNR>-OPTION = 'EQ'.
    <LS_ORDNR>-LOW = LS_ORDSYVAL-AUFNR.

    APPEND INITIAL LINE TO LT_MATNR ASSIGNING FIELD-SYMBOL(<LS_MATNR>).
    <LS_MATNR>-SIGN = 'I'.
    <LS_MATNR>-OPTION = 'EQ'.
    <LS_MATNR>-LOW = LS_ORDSYVAL-MATNR.

  ENDLOOP.

  LOOP AT GT_2330 INTO DATA(LS_2330).
    APPEND INITIAL LINE TO LT_MATNR ASSIGNING <LS_MATNR>.
    <LS_MATNR>-SIGN = 'I'.
    <LS_MATNR>-OPTION = 'EQ'.
    <LS_MATNR>-LOW = LS_2330-MATNR.
  ENDLOOP.

  LOOP AT GT_2010 INTO DATA(LS_2010).
    APPEND INITIAL LINE TO LT_MATNR ASSIGNING <LS_MATNR>.
    <LS_MATNR>-SIGN = 'I'.
    <LS_MATNR>-OPTION = 'EQ'.
    <LS_MATNR>-LOW = LS_2010-MATNR.
  ENDLOOP.


  LOOP AT GT_ORDSYVAL_PLANED INTO LS_ORDSYVAL.
    APPEND INITIAL LINE TO LT_ORDNR ASSIGNING <LS_ORDNR>.
    <LS_ORDNR>-SIGN = 'I'.
    <LS_ORDNR>-OPTION = 'EQ'.
    <LS_ORDNR>-LOW = LS_ORDSYVAL-AUFNR.

    APPEND INITIAL LINE TO LT_MATNR ASSIGNING <LS_MATNR>.
    <LS_MATNR>-SIGN = 'I'.
    <LS_MATNR>-OPTION = 'EQ'.
    <LS_MATNR>-LOW = LS_ORDSYVAL-MATNR.

  ENDLOOP.

  SORT LT_ORDNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_ORDNR COMPARING LOW.

  SORT LT_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.


* 자재별 설비정보 추출
  IF LT_MATNR IS NOT INITIAL.
    SELECT * FROM ZGTCVROUTING
      INTO TABLE GT_ROUTING
     WHERE MATNR IN LT_MATNR
        AND WERKS = P_WERKS.

    SELECT * FROM ZGTCVMSTVAL
      INTO TABLE GT_CVMVAL
     WHERE WERKS = P_WERKS
        AND MATNR IN LT_MATNR.

    CLEAR GV_CHK_PRD.
    IF P_GONGCD NE 'REW'.
      SELECT DISTINCT A~MATNR
        FROM MARA AS A
        INNER JOIN T134 AS B ON B~MTART = A~MTART
        INTO TABLE @DATA(LT_PRD)
       WHERE A~MATNR IN @LT_MATNR
         AND A~LVORM = ' '
         AND B~MTREF = 'FERT'.
      IF SY-SUBRC EQ 0 AND LT_PRD[] IS NOT INITIAL.
        GV_CHK_PRD = ABAP_TRUE.
      ENDIF.
    ENDIF.

    SELECT DISTINCT * FROM ZGTPPT2270
      INTO TABLE @DATA(LT_2070)
     WHERE WERKS = @P_WERKS.

    LOOP AT GT_ROUTING INTO DATA(LS_ROUTING).
      APPEND INITIAL LINE TO GT_ARBPL ASSIGNING FIELD-SYMBOL(<LS_ARBPL>).
      <LS_ARBPL>-GONG_CD = LS_ROUTING-ARBPL+0(3).
      <LS_ARBPL>-ARBPL = LS_ROUTING-ARBPL.
      <LS_ARBPL>-KTEXT = LS_ROUTING-KTEXT.

      REFRESH LT_CHK_2070.
      LT_CHK_2070 = VALUE #( FOR LW_2070 IN LT_2070 WHERE ( ARBPL = LS_ROUTING-ARBPL )
                                      ( CORRESPONDING #( LW_2070 ) ) ).
      <LS_ARBPL>-EQUCD_CNT = LINES( LT_CHK_2070 ).
      IF <LS_ARBPL>-EQUCD_CNT = 0.
        <LS_ARBPL>-EQUCD_CNT = 1.
      ENDIF.

    ENDLOOP.

    SORT GT_ARBPL BY GONG_CD ARBPL.
    DELETE ADJACENT DUPLICATES FROM GT_ARBPL COMPARING GONG_CD ARBPL.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_ORDER_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_ORDER_INFO .

  DATA : LS_2340 TYPE ZGTPPT2340.
  DATA : LV_POSNR(6) TYPE C.
  DATA : LT_ORD TYPE TABLE OF ZGTCVORDSYVAL.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LS_MATNR LIKE LINE OF  LT_MATNR.
  REFRESH GT_MAIN_DISP_100.

  LOOP AT GT_2010 INTO DATA(LS_2010_MATNR).
    CLEAR LS_MATNR.
    LS_MATNR-SIGN = 'I'.
    LS_MATNR-OPTION = 'EQ'.
    LS_MATNR-LOW = LS_2010_MATNR-MATNR.
    COLLECT LS_MATNR INTO LT_MATNR.
  ENDLOOP.

  LOOP AT GT_2330 INTO DATA(LS_2330_MATNR).
    CLEAR LS_MATNR.
    LS_MATNR-SIGN = 'I'.
    LS_MATNR-OPTION = 'EQ'.
    LS_MATNR-LOW = LS_2330_MATNR-MATNR.
    COLLECT LS_MATNR INTO LT_MATNR.
  ENDLOOP.

*  재고 조회
  SELECT DISTINCT
                  MATNR,
                  SUM( LABST ) AS LABST,
                  SUM( INSME ) AS INSME,
                  SUM( SPEME ) AS SPEME,
                  MEINS
    FROM ZGTCV_STOCKVAL
   WHERE WERKS = @P_WERKS
     AND MATNR IN @LT_MATNR
    GROUP BY WERKS, MATNR, MEINS
    INTO TABLE @DATA(LT_AUFNR_JEGO).

  SORT LT_AUFNR_JEGO BY MATNR.

  IF GV_CHK_GO_JOJANG = ABAP_TRUE.
    LT_AUFNR = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( ORDNR IS NOT INITIAL
                                                                     AND   ORDTY = 'PRD' )
                                ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2010-ORDNR ) ).
    IF LT_AUFNR IS NOT INITIAL.
      SORT LT_AUFNR BY LOW.
      DELETE ADJACENT DUPLICATES FROM LT_AUFNR COMPARING LOW.

      SELECT * FROM ZGTCVORDSYVAL
        INTO TABLE LT_ORD
       WHERE WERKS = P_WERKS
          AND AUFNR IN LT_AUFNR
          AND DLFL = ''
          AND LKD = ''
          AND CLSD = ''
          AND TECO = ''.
    ENDIF.

* 해당월 조장 기준으로 데이터 선구성
    LOOP AT GT_2010 INTO DATA(LS_2010).
      READ TABLE LT_ORD TRANSPORTING NO FIELDS WITH KEY AUFNR = LS_2010-ORDNR.
      IF SY-SUBRC NE 0. " 오더 상태가 정상적이지 않은 오더는 보여주지 않는다.
        CONTINUE.
      ENDIF.

*    탄뎀의 참조문서의 경우 보여주거나 프로세스 흘릴수 없음.
      IF LS_2010-REF_TANDEM = ABAP_TRUE.
        CONTINUE.
      ENDIF.

      CLEAR GS_MAIN_DISP_100.
      GS_MAIN_DISP_100-SEQNO = 0.

      GS_MAIN_DISP_100-GRPNR = LS_2010-GRPNR.
      GS_MAIN_DISP_100-ORDNR = LS_2010-ORDNR.
      __ALPHA_OUT GS_MAIN_DISP_100-ORDNR.
      GS_MAIN_DISP_100-POSNR = LS_2010-POSNR.
      GS_MAIN_DISP_100-GCATG = '조장'.

      GS_MAIN_DISP_100-MATNR = LS_2010-MATNR.
      GS_MAIN_DISP_100-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_2010-MATNR ).
      READ TABLE GT_CVMVAL INTO DATA(LS_CVMVAL) WITH KEY MATNR = LS_2010-MATNR.
      IF SY-SUBRC EQ 0.
        GS_MAIN_DISP_100-COLOR = LS_CVMVAL-COLORBASE.
      ENDIF.

      GS_MAIN_DISP_100-PSMNG = ( LS_2010-INLENGTH + LS_2010-QLENGTH +
                                               LS_2010-CLENGTH + LS_2010-ADLENGTH ) *
                                             LS_2010-INFACTOR.

      GS_MAIN_DISP_100-INFACTOR = LS_2010-INFACTOR.
      GS_MAIN_DISP_100-INLENGTH = LS_2010-INLENGTH.
* 현재고량
      READ TABLE LT_AUFNR_JEGO INTO DATA(LS_AUFNR_JEGO) WITH KEY MATNR = LS_2010-MATNR.
      IF SY-SUBRC EQ 0.
        GS_MAIN_DISP_100-MENGE04 = LS_AUFNR_JEGO-LABST + LS_AUFNR_JEGO-INSME + LS_AUFNR_JEGO-SPEME.
      ENDIF.

      GS_MAIN_DISP_100-MENGE04 = LS_AUFNR_JEGO-LABST + LS_AUFNR_JEGO-INSME + LS_AUFNR_JEGO-SPEME.
      GS_MAIN_DISP_100-MEINS = LS_AUFNR_JEGO-MEINS.
      GS_MAIN_DISP_100-CLENGTH = LS_2010-CLENGTH + LS_2010-SLENGTH + LS_2010-ADLENGTH.
      GS_MAIN_DISP_100-QLENGTH = LS_2010-QLENGTH.

      READ TABLE GT_ORDSYVAL_PLANED INTO DATA(LS_CHK_ORD) WITH KEY AUFNR = LS_2010-ORDNR.
      IF SY-SUBRC EQ 0.
        CONTINUE.
      ENDIF.

      APPEND GS_MAIN_DISP_100 TO GT_MAIN_DISP_100.

    ENDLOOP.

    CHECK S_GRPNR[] IS INITIAL.

    LOOP AT GT_ORDSYVAL INTO DATA(LS_ORDSYVAL).
      CLEAR LS_2010.
      READ TABLE GT_2010 INTO LS_2010 WITH KEY ORDNR = LS_ORDSYVAL-AUFNR.
      IF SY-SUBRC EQ 0.
*     작업지시량
        CONTINUE.
      ELSE.

        APPEND INITIAL LINE TO GT_MAIN_DISP_100 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

        <LS_MAIN>-SEQNO = 9.
        <LS_MAIN>-ORDNR = LS_ORDSYVAL-AUFNR.
        __ALPHA_OUT <LS_MAIN>-ORDNR.
        CONCATENATE '##' LS_ORDSYVAL-AUART INTO <LS_MAIN>-GRPNR.
        CONCATENATE <LS_MAIN>-GRPNR <LS_MAIN>-ORDNR INTO <LS_MAIN>-GRPNR SEPARATED BY SPACE.

        <LS_MAIN>-ORDNR = LS_ORDSYVAL-AUFNR.
        <LS_MAIN>-POSNR = LS_ORDSYVAL-POSNR.
        <LS_MAIN>-GCATG = '생산오더'.
        <LS_MAIN>-MATNR = LS_ORDSYVAL-MATNR.
        <LS_MAIN>-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_ORDSYVAL-MATNR ).
        READ TABLE GT_CVMVAL INTO LS_CVMVAL WITH KEY MATNR = LS_ORDSYVAL-MATNR.
        IF SY-SUBRC EQ 0.
          <LS_MAIN>-COLOR = LS_CVMVAL-COLORBASE.
        ENDIF.
        ADD LS_ORDSYVAL-GAMNG TO <LS_MAIN>-MENGE01.
        IF LS_ORDSYVAL-MILLCAFACTOR NE 0.
          <LS_MAIN>-MENGE02 = LS_ORDSYVAL-MILLCAFACTOR.
        ELSE.
          <LS_MAIN>-MENGE02 = 1.
        ENDIF.
        <LS_MAIN>-MEINS = LS_ORDSYVAL-MEINS.
      ENDIF.
    ENDLOOP.

  ELSE.
* 해당월 조장 기준으로 데이터 선구성
    LOOP AT GT_2330 INTO DATA(LS_2330).
      IF LS_2330-PLNUM IS INITIAL AND LS_2330-DMORD IS INITIAL.
        CONTINUE.
      ENDIF.
      CLEAR GS_MAIN_DISP_100.
      GS_MAIN_DISP_100-SEQNO = 0.

*    GS_MAIN_DISP_100-POSNR =
*      IF P_GONGCD = 'REW'.
      IF LS_2330-GONG_SEQ = '01' AND LS_2330-DMORD IS NOT INITIAL.

        CLEAR LS_2340.
        READ TABLE GT_2340 INTO LS_2340 WITH KEY ZWKREQ = LS_2330-ZWKREQ
                                                 ORDTY = 'PRD'.
        IF SY-SUBRC NE 0. " 생산오더 생성 안된건은 제외
          CONTINUE.
        ENDIF.

        GS_MAIN_DISP_100-GRPNR = LS_2330-DMORD.
        __ALPHA_OUT GS_MAIN_DISP_100-GRPNR.
        GS_MAIN_DISP_100-POSNR = LS_2330-DMLINE.
        LV_POSNR = GS_MAIN_DISP_100-POSNR.
        __ALPHA_OUT LV_POSNR.
        CONCATENATE GS_MAIN_DISP_100-GRPNR '/' LV_POSNR INTO GS_MAIN_DISP_100-GRPNR.

        GS_MAIN_DISP_100-ORDNR = LS_2330-DMORD.
        CASE LS_2330-DMORDTY.
          WHEN 'SO'.
            GS_MAIN_DISP_100-GCATG = '판매오더'.
          WHEN 'PRD'.
            GS_MAIN_DISP_100-GCATG = 'SM오더'.
        ENDCASE.

      ELSE.
        GS_MAIN_DISP_100-GRPNR = LS_2330-PLNUM.
        __ALPHA_OUT GS_MAIN_DISP_100-GRPNR.
        GS_MAIN_DISP_100-ORDNR = LS_2330-PLNUM.
        GS_MAIN_DISP_100-GCATG = '계획오더'.

        SELECT SINGLE GSMNG FROM PLAF
          INTO GS_MAIN_DISP_100-GSMNG
         WHERE PLNUM = LS_2330-PLNUM.

      ENDIF.

      GS_MAIN_DISP_100-MATNR = LS_2330-MATNR.
      GS_MAIN_DISP_100-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_2330-MATNR ).
      READ TABLE GT_CVMVAL INTO LS_CVMVAL WITH KEY MATNR = LS_2330-MATNR.
      IF SY-SUBRC EQ 0.
        GS_MAIN_DISP_100-COLOR = LS_CVMVAL-COLORBASE.
      ENDIF.
      GS_MAIN_DISP_100-PSMNG = LS_2330-GSMNG.

      GS_MAIN_DISP_100-INFACTOR = LS_2330-INFACTOR.
      GS_MAIN_DISP_100-INLENGTH = LS_2330-INLENGTH.
      GS_MAIN_DISP_100-CLENGTH = LS_2330-CLENGTH.
      GS_MAIN_DISP_100-QLENGTH = LS_2330-QLENGTH.
* 현재고량

* 현재고량
      READ TABLE LT_AUFNR_JEGO INTO LS_AUFNR_JEGO WITH KEY MATNR = LS_2330-MATNR.
      IF SY-SUBRC EQ 0.
        GS_MAIN_DISP_100-MENGE04 = LS_AUFNR_JEGO-LABST + LS_AUFNR_JEGO-INSME + LS_AUFNR_JEGO-SPEME.
      ENDIF.

      GS_MAIN_DISP_100-MEINS = LS_2330-MEINS.
      GS_MAIN_DISP_100-ZWKREQ = LS_2330-ZWKREQ.
      APPEND GS_MAIN_DISP_100 TO GT_MAIN_DISP_100.

    ENDLOOP.

    LOOP AT GT_ORDSYVAL INTO LS_ORDSYVAL.
      CLEAR LS_2340.
      READ TABLE GT_2340 INTO LS_2340 WITH KEY ORDNR = LS_ORDSYVAL-AUFNR.
      IF SY-SUBRC EQ 0.
*     작업지시량
        CONTINUE.
      ELSE.

* 분할오더 추가
        IF P_WERKS = '6600'  " AND P_GONGCD = 'REW'
           AND LS_ORDSYVAL-KDAUF IS NOT INITIAL.
          SELECT SINGLE * FROM ZGTPPT2330
            INTO @DATA(LS_2330_CHK)
           WHERE DMORD = @LS_ORDSYVAL-KDAUF
             AND DMLINE = @LS_ORDSYVAL-KDPOS
             AND DMORDTY = 'SO'.
          IF SY-SUBRC EQ 0.
            SELECT SINGLE * FROM ZGTPPT2340
              INTO @DATA(LS_2340_CHK)
           WHERE ORDNR = @LS_ORDSYVAL-AUFNR.
            IF SY-SUBRC EQ 0.

            ELSE.
              IF LS_2330_CHK-GONG_CD = 'REW' AND P_SPGCD = 'GL'.
                APPEND INITIAL LINE TO GT_MAIN_DISP_100 ASSIGNING <LS_MAIN>.

                <LS_MAIN>-SEQNO = 0.

                <LS_MAIN>-ORDNR = LS_ORDSYVAL-KDAUF.
                __ALPHA_OUT <LS_MAIN>-ORDNR.
                <LS_MAIN>-POSNR = LS_ORDSYVAL-KDPOS.
                __ALPHA_OUT <LS_MAIN>-POSNR.

                CONCATENATE <LS_MAIN>-ORDNR '/' <LS_MAIN>-POSNR INTO <LS_MAIN>-GRPNR.

                <LS_MAIN>-ORDNR = LS_ORDSYVAL-AUFNR.
                <LS_MAIN>-POSNR = LS_ORDSYVAL-POSNR.
                <LS_MAIN>-GCATG = '분할오더'.
                <LS_MAIN>-MATNR = LS_ORDSYVAL-MATNR.
                <LS_MAIN>-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_ORDSYVAL-MATNR ).
                READ TABLE GT_CVMVAL INTO LS_CVMVAL WITH KEY MATNR = LS_ORDSYVAL-MATNR.
                IF SY-SUBRC EQ 0.
                  <LS_MAIN>-COLOR = LS_CVMVAL-COLORBASE.
                ENDIF.

                IF LS_ORDSYVAL-MILLCALENGTH NE 0.
                  <LS_MAIN>-INFACTOR = LS_ORDSYVAL-GAMNG / LS_ORDSYVAL-MILLCALENGTH.
                  <LS_MAIN>-INLENGTH = LS_ORDSYVAL-MILLCALENGTH.
                ELSE.
                  <LS_MAIN>-INFACTOR = LS_ORDSYVAL-GAMNG.
                  <LS_MAIN>-INLENGTH = 1.
                ENDIF.


                <LS_MAIN>-MEINS = LS_ORDSYVAL-MEINS.

                CONTINUE.

              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        APPEND INITIAL LINE TO GT_MAIN_DISP_100 ASSIGNING <LS_MAIN>.

        <LS_MAIN>-SEQNO = 9.

        <LS_MAIN>-ORDNR = LS_ORDSYVAL-AUFNR.
        __ALPHA_OUT <LS_MAIN>-ORDNR.
        CONCATENATE '##' LS_ORDSYVAL-AUART INTO <LS_MAIN>-GRPNR.
        CONCATENATE <LS_MAIN>-GRPNR <LS_MAIN>-ORDNR INTO <LS_MAIN>-GRPNR SEPARATED BY SPACE.

        <LS_MAIN>-ORDNR = LS_ORDSYVAL-AUFNR.
        <LS_MAIN>-POSNR = LS_ORDSYVAL-POSNR.
        <LS_MAIN>-GCATG = '생산오더'.
        <LS_MAIN>-MATNR = LS_ORDSYVAL-MATNR.
        <LS_MAIN>-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_ORDSYVAL-MATNR ).
        READ TABLE GT_CVMVAL INTO LS_CVMVAL WITH KEY MATNR = LS_ORDSYVAL-MATNR.
        IF SY-SUBRC EQ 0.
          <LS_MAIN>-COLOR = LS_CVMVAL-COLORBASE.
        ENDIF.
        ADD LS_ORDSYVAL-GAMNG TO <LS_MAIN>-MENGE01.
        IF LS_ORDSYVAL-MILLCAFACTOR NE 0.
          <LS_MAIN>-MENGE02 = LS_ORDSYVAL-MILLCAFACTOR.
        ELSE.
          <LS_MAIN>-MENGE02 = 1.
        ENDIF.
        <LS_MAIN>-MEINS = LS_ORDSYVAL-MEINS.
      ENDIF.
    ENDLOOP.

    LOOP AT GT_ORDSYVAL_PLANED INTO LS_ORDSYVAL.
      CLEAR LS_2340.
      READ TABLE GT_2340 INTO LS_2340 WITH KEY ORDNR = LS_ORDSYVAL-AUFNR.
      IF SY-SUBRC EQ 0.
*     작업지시량
        READ TABLE GT_MAIN_DISP_100 ASSIGNING <LS_MAIN> WITH KEY ZWKREQ = LS_2340-ZWKREQ.
        IF SY-SUBRC EQ 0.
          ADD LS_ORDSYVAL-GAMNG TO <LS_MAIN>-MENGE01.
*     작업지시 B/N
          ADD LS_2340-INFACTOR TO <LS_MAIN>-MENGE02.
*     입고량
          ADD LS_ORDSYVAL-WEMNG TO <LS_MAIN>-MENGE03.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_PLAN_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_ORDSYVAL_PLANED
*&---------------------------------------------------------------------*
FORM MAKE_PLAN_DATA  TABLES   PT_MAIN STRUCTURE ZGTCVORDSYVAL.

  DATA : LT_MAIN TYPE TABLE OF ZGTCVORDSYVAL.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_CHK_ERR.
  DATA : LV_MENGE_IN TYPE EKPO-MENGE.
  DATA : LV_MENGE_OUT TYPE EKPO-MENGE.
  DATA : LV_OBJNR TYPE JEST-OBJNR.
  DATA : LV_USER_LINE TYPE BSVX-STTXT.
  DATA : LS_2010_CHECK TYPE ZGTPPT2010.
  DATA : LS_CHK_2010 TYPE ZGTPPT2010.

  LT_MAIN = PT_MAIN[].

  SORT LT_MAIN BY ARBPL ZZPRIORITY AUFNR POSNR.

  SELECT DISTINCT B~*
    FROM @LT_MAIN AS A
    INNER JOIN ZGTPPT2400 AS B ON B~AUFNR = A~AUFNR
                                           AND B~POSNR = A~POSNR
    INTO TABLE @DATA(LT_MANAGE_LEADTIME).

  LOOP AT GT_ARBPL INTO GS_ARBPL.

    CLEAR LV_SEQNO.
    LOOP AT LT_MAIN INTO DATA(LS_MAIN) WHERE ARBPL = GS_ARBPL-ARBPL.
      CLEAR GS_MAKE_PLAN.
      GS_MAKE_PLAN-GONG_CD = GS_ARBPL-GONG_CD.
      GS_MAKE_PLAN-ARBPL = GS_ARBPL-ARBPL.

      ADD 1 TO LV_SEQNO.
      GS_MAKE_PLAN-SEQNO = LV_SEQNO.
*생산오더
      GS_MAKE_PLAN-ORDNR = LS_MAIN-AUFNR.
      __ALPHA_OUT : GS_MAKE_PLAN-ORDNR.
*탄뎀 확인
      SELECT SINGLE ZZTANDEM FROM AUFK
        INTO GS_MAKE_PLAN-TANDEM
        WHERE AUFNR = LS_MAIN-AUFNR.

*오더품목
      GS_MAKE_PLAN-POSNR = LS_MAIN-POSNR.
*오더상태
      IF LS_MAIN-DLV = ABAP_TRUE.
        GS_MAKE_PLAN-ORD_STAT = '작업완료'.
      ELSEIF LS_MAIN-PDLV = ABAP_TRUE.
        GS_MAKE_PLAN-ORD_STAT = '작업중'.
      ELSEIF LS_MAIN-REL = ABAP_TRUE.
        GS_MAKE_PLAN-ORD_STAT = '릴리즈'.
      ELSE.
        GS_MAKE_PLAN-ORD_STAT = '생성'.
      ENDIF.

* pay off상태 확인
      CASE GS_MAKE_PLAN-ORD_STAT.
        WHEN '릴리즈' OR '생성'.
          LV_OBJNR = 'OR' && LS_MAIN-AUFNR.
          CALL FUNCTION 'STATUS_TEXT_EDIT'
            EXPORTING
              FLG_USER_STAT    = 'X'
              OBJNR            = LV_OBJNR
              ONLY_ACTIVE      = 'X'
              SPRAS            = SY-LANGU
              BYPASS_BUFFER    = 'X'
            IMPORTING
              USER_LINE        = LV_USER_LINE
            EXCEPTIONS
              OBJECT_NOT_FOUND = 1
              OTHERS           = 2.

          FIND ALL OCCURRENCES OF 'PAYO' IN LV_USER_LINE MATCH COUNT FINAL(LV_LINE).
          IF LV_LINE > 0. " Patoff 상태일지 작업중으로 변경
            GS_MAKE_PLAN-ORD_STAT = '작업중'.
          ENDIF.
      ENDCASE.

*자재코드
      GS_MAKE_PLAN-MATNR = LS_MAIN-MATNR.
*색상
      READ TABLE GT_CVMVAL INTO DATA(LS_CVMVAL) WITH KEY MATNR = LS_MAIN-MATNR.
      IF SY-SUBRC EQ 0.
        IF LS_CVMVAL-COLORBASE IS NOT INITIAL.
          GS_MAKE_PLAN-COLOR = LS_CVMVAL-COLORBASE.
        ENDIF.
      ENDIF.

*자재내역
      GS_MAKE_PLAN-MAKTX = LS_MAIN-MAKTX.

      READ TABLE GT_ROUTING INTO DATA(LS_ROUTING) WITH KEY MATNR = LS_MAIN-MATNR
                                                                               ARBPL = LS_MAIN-ARBPL.
* prodchg(시간)
      IF LS_ROUTING-VGW01 NE 0.
        CLEAR : LV_MENGE_IN, LV_MENGE_OUT.
        LV_MENGE_IN = LS_ROUTING-VGW01.
        CASE LS_ROUTING-VGE01.
          WHEN 'MIN'.
            LV_MENGE_OUT = LS_ROUTING-VGW01 / 60.
          WHEN 'H'.
            LV_MENGE_OUT = LS_ROUTING-VGW01.
          WHEN 'D' OR '10'.
            LV_MENGE_OUT = LS_ROUTING-VGW01 * 24.
        ENDCASE.
        GS_MAKE_PLAN-WKCHH_B = LV_MENGE_OUT / GS_ARBPL-EQUCD_CNT.
      ENDIF.
* LeadTime(시간)
      CLEAR : LV_MENGE_IN, LV_MENGE_OUT.

      IF P_WERKS = '6600' AND P_SPGCD = 'GL' AND P_GONGCD = 'PAR'. " 전주 랜 대연 공정은 기게 작업시간이 아닌 노무 시간으로 시간 적용

        IF LS_ROUTING-VGW06 NE 0.
          CASE LS_ROUTING-VGE06.
            WHEN 'MIN'.
              LV_MENGE_OUT = LS_ROUTING-BMSCH * ( 60 / LS_ROUTING-VGW06 ).
            WHEN 'H'.
              LV_MENGE_OUT = LS_ROUTING-BMSCH / LS_ROUTING-VGW06 .
            WHEN 'D' OR '10'.
              LV_MENGE_OUT = LS_ROUTING-BMSCH / ( LS_ROUTING-VGW06 * 24 ).
          ENDCASE.

          LV_MENGE_OUT = ( LS_MAIN-PSAMG + LS_MAIN-PSMNG ) / LV_MENGE_OUT.
          GS_MAKE_PLAN-ZWKLTH_B = LV_MENGE_OUT / GS_ARBPL-EQUCD_CNT.
        ENDIF.

      ELSE.
        IF LS_ROUTING-VGW02 NE 0.
          CASE LS_ROUTING-VGE02.
            WHEN 'MIN'.
              LV_MENGE_OUT = LS_ROUTING-BMSCH * ( 60 / LS_ROUTING-VGW02 ).
            WHEN 'H'.
              LV_MENGE_OUT = LS_ROUTING-BMSCH / LS_ROUTING-VGW02 .
            WHEN 'D' OR '10'.
              LV_MENGE_OUT = LS_ROUTING-BMSCH / ( LS_ROUTING-VGW02 * 24 ).
          ENDCASE.

          LV_MENGE_OUT = ( LS_MAIN-PSAMG + LS_MAIN-PSMNG ) / LV_MENGE_OUT.
          GS_MAKE_PLAN-ZWKLTH_B = LV_MENGE_OUT / GS_ARBPL-EQUCD_CNT.
        ENDIF.
      ENDIF.

* 가동율(기준 입력)
      IF LS_ROUTING-USR05 = 0 .
        GS_MAKE_PLAN-RATE_OP_B = 1.
      ELSE.
        GS_MAKE_PLAN-RATE_OP_B = LS_ROUTING-USR05.
      ENDIF.


*    수동입력테이블 조회후 있으면 입력된 결과 없으면 라우팅데이터로 적용
      READ TABLE LT_MANAGE_LEADTIME INTO DATA(LS_MANAGE_LEADTIME) WITH KEY AUFNR = LS_MAIN-AUFNR
                                                                                                         POSNR = LS_MAIN-POSNR.
      IF SY-SUBRC EQ 0.
* prodchg(시간)
        GS_MAKE_PLAN-WKCHH = LS_MANAGE_LEADTIME-ZWKCHH.
        GS_MAKE_PLAN-ZWKLTH = LS_MANAGE_LEADTIME-ZWKLTH.
        GS_MAKE_PLAN-RATE_OP = LS_MANAGE_LEADTIME-RATE_OP.
      ELSE.
        GS_MAKE_PLAN-WKCHH = 0.
        GS_MAKE_PLAN-ZWKLTH = GS_MAKE_PLAN-ZWKLTH_B.
        GS_MAKE_PLAN-RATE_OP = GS_MAKE_PLAN-RATE_OP_B.
      ENDIF.

*시작일(계획)
      GS_MAKE_PLAN-GSTRP = LS_MAIN-GSTRP.
      GS_MAKE_PLAN-GSUZP = LS_MAIN-GSUZP.
*종료일(계획)
      GS_MAKE_PLAN-GLTRP = LS_MAIN-GLTRP.
      GS_MAKE_PLAN-GLUZP = LS_MAIN-GLUZP.
*우선순위
      GS_MAKE_PLAN-ZZPRIORITY = LS_MAIN-ZZPRIORITY.
*작업특기사항
      GS_MAKE_PLAN-SNOTE = ICON_DISPLAY_TEXT.
* 표준조장
      GS_MAKE_PLAN-INLENGTH = LS_MAIN-MILLCALENGTH.
* 작업지시B/N
      IF LS_MAIN-INFACTOR NE 0.
        GS_MAKE_PLAN-INFACTOR = LS_MAIN-INFACTOR.
      ELSE.
        GS_MAKE_PLAN-INFACTOR = LS_MAIN-MILLCAFACTOR.
      ENDIF.
*지시수량
      GS_MAKE_PLAN-PSMNG = LS_MAIN-PSAMG + LS_MAIN-PSMNG.
*단위
      GS_MAKE_PLAN-MEINS = LS_MAIN-GMEIN.

      IF GV_CHK_GO_JOJANG = ABAP_TRUE.
        READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = LS_MAIN-AUFNR.
        IF SY-SUBRC EQ 0.
          GS_MAKE_PLAN-GUBUN = '조장구성'.
          GS_MAKE_PLAN-CLENGTH = LS_2010-CLENGTH + LS_2010-SLENGTH + LS_2010-ADLENGTH.
          GS_MAKE_PLAN-QLENGTH = LS_2010-QLENGTH.

* 조장번호
          GS_MAKE_PLAN-GRPNR = LS_2010-GRPNR.

* 판매오더 정보 추가
* 해당 조장구성표의 오더번호 찾아가기
          CLEAR : LS_2010_CHECK.
          MOVE-CORRESPONDING LS_2010 TO LS_2010_CHECK.
          DO.
            IF LS_2010_CHECK-DMORDTY = 'SO' OR LS_2010_CHECK-DMORDTY = 'SM'.
              EXIT.
            ELSE.
              CLEAR LS_CHK_2010.
              LOOP AT GT_2010_FUL INTO LS_CHK_2010 WHERE GRPNR = LS_2010_CHECK-GRPNR
                                                                            AND ORDNR = LS_2010_CHECK-DMORD
                                                                            AND POSNR = LS_2010_CHECK-DMLINE
                                                                            AND ORDTY = LS_2010_CHECK-DMORDTY
                                                                            AND GONG_SEQ > LS_2010_CHECK-GONG_SEQ.
                CLEAR LS_2010_CHECK.
                MOVE-CORRESPONDING LS_CHK_2010 TO LS_2010_CHECK.
                EXIT.
              ENDLOOP.

              IF LS_CHK_2010 IS INITIAL.
                LV_CHK_ERR = ABAP_TRUE.
                EXIT.
              ENDIF.
            ENDIF.
          ENDDO.

          IF LV_CHK_ERR NE ABAP_TRUE.
            GS_MAKE_PLAN-ORDNO_DM = LS_2010_CHECK-DMORD.
            GS_MAKE_PLAN-POSNR_DM = LS_2010_CHECK-DMLINE.
          ENDIF.

        ELSE.
          GS_MAKE_PLAN-GUBUN = '수작업'.
        ENDIF.
      ELSE.
        READ TABLE GT_2340 INTO DATA(LS_2340) WITH KEY ORDNR = LS_MAIN-AUFNR.
        IF SY-SUBRC EQ 0.
          GS_MAKE_PLAN-GUBUN = '조장구성'.
          GS_MAKE_PLAN-CLENGTH = LS_2340-CLENGTH.
          GS_MAKE_PLAN-QLENGTH = LS_2340-QLENGTH.

* 판매오더 정보 추가
          SELECT SINGLE * FROM ZGTPPT2330
           WHERE WERKS = @LS_2340-WERKS
             AND SPGCD = @LS_2340-SPGCD
             AND RQMON = @LS_2340-RQMON
             AND ZWKREQ = @LS_2340-ZWKREQ
             AND DMORD IS NOT INITIAL
             AND GONG_SEQ = '01'
            INTO @DATA(LS_2330).

          IF SY-SUBRC EQ 0.
            GS_MAKE_PLAN-ORDNO_DM = LS_2330-DMORD.
            GS_MAKE_PLAN-POSNR_DM = LS_2330-DMLINE.
          ENDIF.

        ELSE.
* 분할오더 추가
          IF P_WERKS = '6600' AND P_SPGCD = 'GL' AND P_GONGCD = 'REW' AND
            LS_MAIN-KDAUF IS NOT INITIAL.
            SELECT SINGLE * FROM ZGTPPT2330
              INTO @DATA(LS_2330_CHK)
             WHERE DMORD = @LS_MAIN-KDAUF
               AND DMLINE = @LS_MAIN-KDPOS
               AND DMORDTY = 'SO'.
            IF SY-SUBRC EQ 0.
              GS_MAKE_PLAN-ORDNO_DM = LS_2330_CHK-DMORD.
              GS_MAKE_PLAN-POSNR_DM = LS_2330_CHK-DMLINE.
              GS_MAKE_PLAN-GUBUN = '분할오더'.
            ELSE.
              GS_MAKE_PLAN-GUBUN = '수작업'.
            ENDIF.
          ELSE.

            GS_MAKE_PLAN-GUBUN = '수작업'.
          ENDIF.
        ENDIF.
      ENDIF.

* 입고수량
      SELECT SINGLE SUM( CASE BWART WHEN '101' THEN MENGE
                                          WHEN '102' THEN MENGE * -1
                                          END ) AS MENGE
        FROM MSEG
       WHERE MATNR = @LS_MAIN-MATNR
         AND AUFNR = @LS_MAIN-AUFNR
         AND AUFPS = @LS_MAIN-POSNR
         AND BWART IN ('101', '102')
         AND CHARG NE 'GR_ZERO1'
       INTO @GS_MAKE_PLAN-MENGE01.

* 오더타입
      GS_MAKE_PLAN-AUART = LS_MAIN-AUART.
      APPEND GS_MAKE_PLAN TO GT_MAKE_PLAN.

    ENDLOOP.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CRT_TIME_DAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CRT_TIME_DAY .

* 생산 수립을 위해 일자별 설비별 가용시간 체크를 위한 관리테이블 생성
  DATA : LV_SEQNO TYPE I.
  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LV_GSUZP TYPE SY-UZEIT.
  DATA : LV_GLUZP TYPE SY-UZEIT.
  DATA : LV_AUFNR TYPE AUFNR.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : LV_CHK_DATE TYPE SY-DATUM.

  SORT GT_MAKE_PLAN BY SEQNO.

  DATA(LT_SORT) = GT_MAKE_PLAN.
  SORT LT_SORT BY ORDNR.
  DELETE ADJACENT DUPLICATES FROM LT_SORT COMPARING ORDNR.

  LT_AUFNR = VALUE #( FOR LW_SORT IN LT_SORT WHERE ( ORDNR IS NOT INITIAL )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = CONV #( LW_SORT-ORDNR ) ) ).

  LOOP AT LT_AUFNR ASSIGNING FIELD-SYMBOL(<LS_AUFNR>).
    __ALPHA_INPUT <LS_AUFNR>-LOW.
  ENDLOOP.
  SORT LT_AUFNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM  LT_AUFNR COMPARING LOW.

  SELECT DISTINCT *
    FROM ZGTPPT2390
   WHERE AUFNR IN @LT_AUFNR
    INTO TABLE @DATA(LT_EXISTS_DAY).

  LV_DATE = P_WEEKFR.
  DO.

    IF LV_DATE > P_WEEKTO.
      EXIT.
    ENDIF.

    LOOP AT GT_ARBPL INTO GS_ARBPL.
      CLEAR GS_WORKTIME_DAY.

      GS_WORKTIME_DAY-DATE = LV_DATE.
      GS_WORKTIME_DAY-GONG_CD = GS_ARBPL-GONG_CD.
      GS_WORKTIME_DAY-ARBPL = GS_ARBPL-ARBPL.

      REFRESH GT_ORDER_DAY_WORKING.
      CLEAR LV_SEQNO.
* 시작일 이후 연결되는 건부터 순차세팅
      LOOP AT LT_SORT INTO DATA(LS_SORT) WHERE ARBPL = GS_ARBPL-ARBPL
                                                                AND GSTRP < LV_DATE
                                                                AND GLTRP >= LV_DATE.
        CLEAR GS_ORDER_DAY_WORKING.
        LOOP AT GT_MAKE_PLAN INTO GS_MAKE_PLAN WHERE ORDNR = LS_SORT-ORDNR.
          GS_ORDER_DAY_WORKING-ORDNR = LS_SORT-ORDNR.
          ADD GS_MAKE_PLAN-WKCHH TO GS_ORDER_DAY_WORKING-WKCHH.
          ADD GS_MAKE_PLAN-ZWKLTH TO GS_ORDER_DAY_WORKING-ZWKLTH.
          ADD GS_MAKE_PLAN-ZWKLTH_B TO GS_ORDER_DAY_WORKING-ZWKLTH_B.
          ADD GS_MAKE_PLAN-RATE_OP_B TO GS_ORDER_DAY_WORKING-RATE_OP_B.
          ADD GS_MAKE_PLAN-RATE_OP TO GS_ORDER_DAY_WORKING-RATE_OP.
        ENDLOOP.

        ADD 1 TO LV_SEQNO.
        GS_ORDER_DAY_WORKING-SEQNO = LV_SEQNO.
* 시작일이 이전일자인경우 시간으로 가동시간계산
        IF LV_DATE = LS_SORT-GLTRP.
          CLEAR LV_GLUZP.
          CLEAR LV_AUFNR.
          LV_AUFNR = LS_SORT-ORDNR.
          __ALPHA_INPUT LV_AUFNR.
          SELECT SINGLE GLUZP FROM AFKO
            INTO LV_GLUZP
           WHERE AUFNR = LV_AUFNR.

          CLEAR GS_ORDER_DAY_WORKING-WKCHH.

          GS_ORDER_DAY_WORKING-CURRENT_TIME = LV_GLUZP+0(2) + ( LV_GLUZP+2(2) / 60 ).
          GS_ORDER_DAY_WORKING-ZWKLTH = GS_ORDER_DAY_WORKING-CURRENT_TIME.
        ELSE.
          LV_AUFNR = LS_SORT-ORDNR.
          __ALPHA_INPUT LV_AUFNR.

          " 중간일자의 경우 비가동일자 조회하여 비가동일의 경우 적재 제외
          READ TABLE LT_EXISTS_DAY INTO DATA(LS_EXISTS_DAY) WITH KEY AUFNR = LV_AUFNR
                                                                                           SKDAT = LV_DATE.
          IF SY-SUBRC EQ 0.
            CONTINUE.
          ELSE. " 비가동일자 아닐경우 풀타임 작업으로 계산
            CLEAR GS_ORDER_DAY_WORKING-WKCHH.
            GS_ORDER_DAY_WORKING-CURRENT_TIME = 24.
            GS_ORDER_DAY_WORKING-ZWKLTH = GS_ORDER_DAY_WORKING-CURRENT_TIME.
          ENDIF.
        ENDIF.

        APPEND GS_ORDER_DAY_WORKING TO GT_ORDER_DAY_WORKING.
      ENDLOOP.

* 시작일 세팅건
      LOOP AT LT_SORT INTO LS_SORT WHERE ARBPL = GS_ARBPL-ARBPL
                                                      AND GSTRP = LV_DATE.

        CLEAR GS_ORDER_DAY_WORKING.
        LOOP AT GT_MAKE_PLAN INTO GS_MAKE_PLAN WHERE ORDNR = LS_SORT-ORDNR.
          GS_ORDER_DAY_WORKING-ORDNR = LS_SORT-ORDNR.
          ADD GS_MAKE_PLAN-WKCHH TO GS_ORDER_DAY_WORKING-WKCHH.
          ADD GS_MAKE_PLAN-ZWKLTH TO GS_ORDER_DAY_WORKING-ZWKLTH.
          ADD GS_MAKE_PLAN-ZWKLTH_B TO GS_ORDER_DAY_WORKING-ZWKLTH_B.
          ADD GS_MAKE_PLAN-RATE_OP_B TO GS_ORDER_DAY_WORKING-RATE_OP_B.
          ADD GS_MAKE_PLAN-RATE_OP TO GS_ORDER_DAY_WORKING-RATE_OP.
        ENDLOOP.

        ADD 1 TO LV_SEQNO.
        GS_ORDER_DAY_WORKING-SEQNO = LV_SEQNO.

        IF LV_DATE = LS_SORT-GLTRP.
          GS_ORDER_DAY_WORKING-CURRENT_TIME = GS_ORDER_DAY_WORKING-WKCHH + GS_ORDER_DAY_WORKING-ZWKLTH.

        ELSE.
          CLEAR LV_GSUZP.
          LV_AUFNR = LS_SORT-ORDNR.
          __ALPHA_INPUT LV_AUFNR.
          SELECT SINGLE GSUZP FROM AFKO
            INTO LV_GSUZP
           WHERE AUFNR = LV_AUFNR.

          GS_ORDER_DAY_WORKING-CURRENT_TIME = GS_ORDER_DAY_WORKING-WKCHH +
                                                                      ( 24 - LV_GSUZP+0(2) ) +
                                                                      ( ( 60 - LV_GSUZP+2(2) ) / 60 ).
        ENDIF.

        APPEND GS_ORDER_DAY_WORKING TO GT_ORDER_DAY_WORKING.

      ENDLOOP.

      IF GT_ORDER_DAY_WORKING[] IS NOT INITIAL.
        MOVE-CORRESPONDING GT_ORDER_DAY_WORKING TO GS_WORKTIME_DAY-T_ORDNRS.

        LOOP AT GT_ORDER_DAY_WORKING INTO DATA(LS_DATA).
          ADD LS_DATA-CURRENT_TIME TO GS_WORKTIME_DAY-CURRENT_TIME.
        ENDLOOP.

      ENDIF.

      APPEND GS_WORKTIME_DAY TO GT_WORKTIME_DAY.

    ENDLOOP.

    ADD 1 TO LV_DATE.

  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_PLAN_DISP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_ORDSYVAL_PLANED
*&---------------------------------------------------------------------*
FORM MAKE_PLAN_DISP_DATA  TABLES   PT_MAIN STRUCTURE ZGTCVORDSYVAL.

  DATA : LV_SEQNO TYPE I.
  DATA : LT_MAIN TYPE TABLE OF ZGTCVORDSYVAL.
  DATA : LT_ORDNR TYPE RANGE OF ZGTPPT2390-AUFNR.
  DATA : LV_AUFNR TYPE AUFNR.

  SORT GT_MAKE_PLAN BY SEQNO.

  LT_MAIN = PT_MAIN[].

  LOOP AT  PT_MAIN.
    APPEND INITIAL LINE TO LT_ORDNR ASSIGNING FIELD-SYMBOL(<LS_ORDNR>).
    <LS_ORDNR>-SIGN = 'I'.
    <LS_ORDNR>-OPTION = 'EQ'.
    <LS_ORDNR>-LOW = PT_MAIN-AUFNR.
    __ALPHA_INPUT <LS_ORDNR>-LOW.
  ENDLOOP.

  SORT LT_ORDNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_ORDNR COMPARING LOW.

  SELECT DISTINCT *
    FROM ZGTPPT2390
    WHERE AUFNR IN  @LT_ORDNR
    INTO TABLE @DATA(LT_EXISTS_DAY).

  LOOP AT GT_ARBPL INTO GS_ARBPL.
    CLEAR GS_MAIN_DISP_101.

    GS_MAIN_DISP_101-GONG_CD = GS_ARBPL-GONG_CD.
    GS_MAIN_DISP_101-ARBPL = GS_ARBPL-ARBPL.
    GS_MAIN_DISP_101-GOBUN = 0.
    CONCATENATE GS_ARBPL-ARBPL GS_ARBPL-KTEXT INTO GS_MAIN_DISP_101-ORDNR SEPARATED BY SPACE.

    APPEND GS_MAIN_DISP_101 TO GT_MAIN_DISP_101.

    CLEAR LV_SEQNO.
* 시작일 이후 연결되는 건부터 순차세팅
    LOOP AT GT_MAKE_PLAN INTO GS_MAKE_PLAN WHERE ARBPL = GS_ARBPL-ARBPL
                                                                  AND GSTRP < GV_SELECTED_DAY
                                                                  AND GLTRP >= GV_SELECTED_DAY.

      LV_AUFNR = GS_MAKE_PLAN-ORDNR.
      __ALPHA_INPUT LV_AUFNR.
      READ TABLE LT_EXISTS_DAY INTO DATA(LS_EXISTS_DAY) WITH KEY AUFNR = LV_AUFNR
                                                                                 SKDAT = GV_SELECTED_DAY.
      IF SY-SUBRC EQ 0.
        CONTINUE.
      ENDIF.

      CLEAR GS_MAIN_DISP_101.
      MOVE-CORRESPONDING GS_MAKE_PLAN TO GS_MAIN_DISP_101.
      CLEAR : GS_MAIN_DISP_101-WKCHH.
      IF GS_MAKE_PLAN-GLTRP = GV_SELECTED_DAY.
        READ TABLE GT_ORDSYVAL_PLANED INTO DATA(LS_ORDERS) WITH KEY AUFNR = LV_AUFNR.
        IF SY-SUBRC EQ 0.
          GS_MAIN_DISP_101-ZWKLTH = LS_ORDERS-GLUZP+0(2) + ( LS_ORDERS-GLUZP+2(2)  / 60 ).
        ENDIF.
      ELSE.
        GS_MAIN_DISP_101-ZWKLTH = 24.
      ENDIF.

      GS_MAIN_DISP_101-GOBUN = 1.
      ADD 1 TO LV_SEQNO.
      GS_MAIN_DISP_101-SEQNO = LV_SEQNO.
      CLEAR GS_MAIN_DISP_101-ZZPRIORITY.

      APPEND GS_MAIN_DISP_101 TO GT_MAIN_DISP_101.
    ENDLOOP.

* 시작일 세팅건
    LOOP AT GT_MAKE_PLAN INTO GS_MAKE_PLAN WHERE ARBPL = GS_ARBPL-ARBPL
                                                                  AND GSTRP = GV_SELECTED_DAY.

      CLEAR GS_MAIN_DISP_101.
      MOVE-CORRESPONDING GS_MAKE_PLAN TO GS_MAIN_DISP_101.
      GS_MAIN_DISP_101-GOBUN = 2.
      ADD 1 TO LV_SEQNO.
      GS_MAIN_DISP_101-SEQNO = LV_SEQNO.
      GS_MAIN_DISP_101-ZZPRIORITY = LV_SEQNO + 0.

      APPEND GS_MAIN_DISP_101 TO GT_MAIN_DISP_101.
    ENDLOOP.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TOTAL_DISP_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_TOTAL_DISP_TABLE .


  DATA : LV_LSAT_LINE TYPE I..
  DATA : LV_INDEX TYPE I..
  DATA : LV_AUFNR TYPE AUFNR.
  CLEAR GV_CHK_OVER_MENGE.

  LOOP AT GT_MAIN_DISP_101 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) WHERE GOBUN = 0.
    READ TABLE GT_WORKTIME_DAY INTO GS_WORKTIME_DAY WITH KEY DATE = GV_SELECTED_DAY
                                                                                    ARBPL = <LS_MAIN>-ARBPL.
    IF SY-SUBRC EQ 0.
      CLEAR : <LS_MAIN>-WKCHH, <LS_MAIN>-ZWKLTH.

      LV_LSAT_LINE = LINES( GS_WORKTIME_DAY-T_ORDNRS ).
      CLEAR LV_INDEX.
      LOOP AT GS_WORKTIME_DAY-T_ORDNRS INTO GS_ORDER_DAY_WORKING.
        ADD GS_ORDER_DAY_WORKING-WKCHH TO <LS_MAIN>-ZWKLTH.
        ADD GS_ORDER_DAY_WORKING-ZWKLTH TO <LS_MAIN>-ZWKLTH.

        IF LV_LSAT_LINE = LV_INDEX AND <LS_MAIN>-ZWKLTH > 24 .
          LV_AUFNR = GS_ORDER_DAY_WORKING-ORDNR.
          __ALPHA_OUT LV_AUFNR.
          READ TABLE GT_MAIN_DISP_101 INTO DATA(LS_CHK_ORDER) WITH KEY ORDNR = LV_AUFNR.
          IF LS_CHK_ORDER-GLTRP NE GV_SELECTED_DAY.
            <LS_MAIN>-ZWKLTH = 24.
          ELSE.
            GV_CHK_OVER_MENGE = ABAP_TRUE.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  LOOP AT GT_MAIN_DISP_101 ASSIGNING <LS_MAIN> WHERE GOBUN NE 0.
    READ TABLE GT_WORKTIME_DAY INTO GS_WORKTIME_DAY WITH KEY DATE = GV_SELECTED_DAY
                                                                                    ARBPL = <LS_MAIN>-ARBPL.
    IF SY-SUBRC EQ 0.
      CLEAR : <LS_MAIN>-ZWKLTH.
      <LS_MAIN>-ZWKLTH = <LS_MAIN>-ZWKLTH_B / <LS_MAIN>-RATE_OP_B * <LS_MAIN>-RATE_OP.

    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_SCREEN .

  CASE ABAP_TRUE.
    WHEN P_DISP.
      CALL SCREEN '0200'.
    WHEN P_PLAN.
      CALL SCREEN '0100'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHECK_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CHECK_100 .

  DATA : LT_CELLS TYPE LVC_T_CENO.

  GO_GRID_0100->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_CELLS[] IS INITIAL.
    RETURN.
  ENDIF.

  SORT LT_CELLS BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CELLS COMPARING ROW_ID.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_MAIN_DISP_100 INTO DATA(LS_MAIN)  INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      LOOP AT GT_MAIN_DISP_100 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) WHERE ORDNR = LS_MAIN-ORDNR.
        <LS_MAIN>-CHECK = ABAP_TRUE.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID..

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
      GO_GRID_0100->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0100 ).
    WHEN GO_GRID_0101.
      PERFORM SET_CELL_ATTRIBUTE_GRID_0101.
      GO_GRID_0101->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0101 ).
*    WHEN GO_GRID_0200.
*      PERFORM SET_CELL_ATTRIBUTE_GRID_0200.
*      GO_GRID_0200->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0200 ).

  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
*     I_SOFT_REFRESH = 'X'
      IS_STABLE = LS_SCROLL.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
* 탑오브페이지 리프레쉬
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
    WHEN GO_GRID_0101.
** 탑오브페이지 리프레쉬
*      IF GO_DD_DOCU_0101 IS BOUND.
*        CALL METHOD GO_DD_DOCU_0101->INITIALIZE_DOCUMENT.
*      ELSE.
*        CREATE OBJECT GO_DD_DOCU_0101
*          EXPORTING
*            STYLE = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
*      ENDIF.
*
*      CALL METHOD GO_GRID_0101->LIST_PROCESSING_EVENTS
*        EXPORTING
*          I_EVENT_NAME = 'TOP_OF_PAGE'
*          I_DYNDOC_ID  = GO_DD_DOCU_0101.
  ENDCASE.

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
      SIDE                        = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_BOTTOM
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 3000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.
*화면 분할
  CREATE OBJECT GO_SPLITTER
    EXPORTING
      PARENT  = GO_DOCKING_0100
      ROWS    = 2
      COLUMNS = 1.

  GO_SPLITTER->SET_COLUMN_WIDTH(
    EXPORTING
      ID                =  1                " Column ID
      WIDTH          = 50 ).                " NPlWidth

* 위아래 컨테이너 분리
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_SPLITTER_0100.

  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_SPLITTER_0101.

* 왼쪽 화면 분할
*화면 분할
  CREATE OBJECT GO_SPLITTER2
    EXPORTING
      PARENT  = GO_SPLITTER_0100
      ROWS    = 2
      COLUMNS = 1.

  GO_SPLITTER2->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    28 ).             " Height

* 오른쪽 화면 분할
*화면 분할
**  CREATE OBJECT GO_SPLITTER3
**    EXPORTING
**      PARENT  = GO_SPLITTER_0101
**      ROWS    = 3
**      COLUMNS = 1.
**
**  GO_SPLITTER3->SET_ROW_HEIGHT(
**    EXPORTING
**      ID                =    1              " Row ID
**      HEIGHT            =    13 ).             " Height
**
**  GO_SPLITTER3->SET_ROW_HEIGHT(
**    EXPORTING
**      ID                =    2              " Row ID
**      HEIGHT            =    8 ).             " Height

* 왼쪽 화면 컨테이너 적용
* top 컨테이너(Title)
  CALL METHOD GO_SPLITTER2->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_TOP_0100.
* Grid
  CALL METHOD GO_SPLITTER2->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0100.


* 오른쪽 화면 컨테이너 적용

*** 타이틀 화면
**  CALL METHOD GO_SPLITTER3->GET_CONTAINER
**    EXPORTING
**      ROW       = 1
**      COLUMN    = 1
**    RECEIVING
**      CONTAINER = GO_CONTAIN_0101_TITLE.
**
*** 일자 컨트롤화면
**  CALL METHOD GO_SPLITTER3->GET_CONTAINER
**    EXPORTING
**      ROW       = 2
**      COLUMN    = 1
**    RECEIVING
**      CONTAINER = GO_CONTAIN_0101_TOP.
*** Grid
**  CALL METHOD GO_SPLITTER3->GET_CONTAINER
**    EXPORTING
**      ROW       = 3
**      COLUMN    = 1
**    RECEIVING
**      CONTAINER = GO_CONTAIN_0101.


* 그리드 적용
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

  CASE PO_GRID.
    WHEN GO_GRID_0100.
*// Event Handler ##
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.

    WHEN GO_GRID_0101_TOP.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
*      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
    WHEN GO_GRID_0101.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_CONTEXT_MENU          FOR PO_GRID.
    WHEN GO_GRID_0440.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
*    WHEN GO_GRID_0500.
*      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
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
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWMARK = ABAP_TRUE.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.
  GS_LAYOUT_0100-STYLEFNAME = 'CELLTAB'.

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
      I_INCLNAME             = 'ZGTPPR2280TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_100'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0100.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_100
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'CHECK'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'CHECK'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '선택'(f15).
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.
    <LS_FCAT>-EDIT = ABAP_TRUE.
    <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'SEQNO'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'SEQNO'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'GRPNR'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'GRPNR'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더'(f01).
    <LS_FCAT>-COL_POS = 3.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '20'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
  ENDIF.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'SEQNO' OR 'ORDNR' OR 'POSNR' OR 'ZWKREQ'.
        <LS_FCAT>-NO_OUT = 'X'.
      WHEN 'GRPNR'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'GCATG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '범주'(f02).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재번호'(f03).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'COLOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상'(f04).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재내역'(f05).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'GSMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산계획잔량'(f38).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'PSMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산계획량'(f06).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(f07).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INLENGTH'.
        IF GV_CHK_GO_JOJANG = ABAP_TRUE OR GV_CHK_GO_HALF = ABAP_TRUE.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '개별조장'(f37).
        ELSE.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '표준조장'(f08).
        ENDIF.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'INLENGTH2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수립조장'(f33).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
        IF GV_CHK_GO_HALF NE ABAP_TRUE.
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDIF.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산계획B/N'(f09).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'MENGE01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업지시량'(f10).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업지시B/N'(f11).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE03'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고량'(f12).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE04'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '현 재고량'(f13).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
        <LS_FCAT>-NO_OUT = 'X'.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수립B/N'(f14).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'CLENGTH'.
        IF NOT ( GV_CHK_GO_JOJANG = ABAP_TRUE OR GV_CHK_GO_HALF = ABAP_TRUE ).
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDIF.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'QLENGTH'.
        IF NOT ( GV_CHK_GO_JOJANG = ABAP_TRUE OR GV_CHK_GO_HALF = ABAP_TRUE ).
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDIF.
        <LS_FCAT>-DECIMALS_O = 0.

    ENDCASE.
  ENDLOOP.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    IF  P_GONGCD = 'REW'.
      CASE   <LS_FCAT>-FIELDNAME.
        WHEN 'MENGE' OR 'INLENGTH2' OR 'GSMNG'.
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        WHEN 'INLENGTH' .
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획조장'(f31).
      ENDCASE.
    ENDIF.

    IF GV_CHK_GO_JOJANG = ABAP_TRUE.
      CASE   <LS_FCAT>-FIELDNAME.
        WHEN 'MENGE' OR 'INLENGTH2' OR 'GCATG' OR 'GSMNG'.
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        WHEN 'GRPNR' .
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장구성표번호'(f34).
        WHEN 'ORDNR'.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더'(f35).
          CLEAR <LS_FCAT>-NO_OUT.
          <LS_FCAT>-JUST = 'C'.
          <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        WHEN 'POSNR'.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목번호'(f36).
          CLEAR <LS_FCAT>-NO_OUT.
          <LS_FCAT>-JUST = 'C'.
          <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      ENDCASE.

    ENDIF.

  ENDLOOP.

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


  LOOP AT GT_MAIN_DISP_100 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    REFRESH LT_CELLTAB.
    LOOP AT GT_FIELDCAT_0100 INTO DATA(LS_FCAT).
      CASE LS_FCAT-FIELDNAME.
        WHEN 'GRPNR' OR 'GCATG' OR 'MATNR' OR 'MAKTX' OR 'COLOR' OR
          'ORDNR' OR 'POSNR'.
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
          LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_KEY.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
        WHEN 'MENGE'.
          CASE P_GONGCD.
            WHEN 'REW'.
            WHEN OTHERS.
              IF GV_CHK_GO_JOJANG = ABAP_TRUE.
                CONTINUE.
              ENDIF.
              IF <LS_MAIN>-SEQNO = 0.
                CLEAR LS_CELLTAB.
                LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
                LS_CELLTAB-STYLE = ALV_STYLE_ENABLED.
                INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
              ENDIF.
          ENDCASE.
        WHEN 'INLENGTH2'.
          IF GV_CHK_GO_HALF = ABAP_TRUE.
            IF <LS_MAIN>-SEQNO = 0.
              CLEAR LS_CELLTAB.
              LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
              LS_CELLTAB-STYLE = ALV_STYLE_ENABLED.
              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    IF LT_CELLTAB IS NOT INITIAL.
      MOVE-CORRESPONDING LT_CELLTAB TO <LS_MAIN>-CELLTAB.
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

  REFRESH GT_EXCLUDE_0100.

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
                            USING : 1 'SEQNO' 'X' '' '',
                                       2 'GRPNR'  'X' '' '',
                                       3 'MATNR'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_TAB
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
      I_BYPASSING_BUFFER   = ABAP_TRUE
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_100
      IT_SORT              = GT_SORT_0100
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

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
*& Form SET_OBJECT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0101 .

  CREATE OBJECT GO_GRID_0101
    EXPORTING
      I_PARENT      = GO_SPLITTER_0101
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0101 .

  CLEAR GS_LAYOUT_0101.
  GS_LAYOUT_0101-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0101-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0101-SEL_MODE   = 'D'.
  GS_LAYOUT_0101-STYLEFNAME = 'CELLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0101 .

  REFRESH GT_EXCLUDE_0101.
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0101
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0101 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2280TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_101'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0101.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0101[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_101
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0101 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'CHECK'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'CHECK'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '선택'(f15).
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.
    <LS_FCAT>-EDIT = ABAP_TRUE.
    <LS_FCAT>-KEY = ABAP_TRUE.
    <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0101 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'GOBUN'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'GOBUN'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 4.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0101 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'SEQNO'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'SEQNO'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 5.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0101 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'ORDNR'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ORDNR'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더'(f17).
    <LS_FCAT>-COL_POS = 6.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-KEY = ABAP_TRUE.
    <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0101 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'ORD_STAT'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ORD_STAT'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더상태'(f18).
    <LS_FCAT>-COL_POS = 8.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-KEY = ABAP_TRUE.
    <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0101 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'TANDEM'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'TANDEM'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '탄뎀'(f43).
    <LS_FCAT>-COL_POS = 11.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '4'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-KEY = ABAP_TRUE.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.
    <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0101 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'CHK_CHG'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'CHK_CHG'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 31.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  LOOP AT GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'GONG_CD' OR 'ARBPL' OR 'GOBUN' OR 'SEQNO' OR 'CHK_DATE' OR 'CHK_CHG' OR 'ZWKLTH_B'.
        <LS_FCAT>-NO_OUT = 'X'.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더품목'(f19).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재코드'(f20).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'COLOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상'(f04).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재내역'(f05).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'WKCHH_B'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '교체시간 기준(H)'(f39).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'WKCHH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '교체시간(H)'(f21).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'ZWKLTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'LeadTime(H)'(f22).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'RATE_OP_B'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '가동율 기준'(f41).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'RATE_OP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '가동율'(f42).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'GSTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시작일(계획)'(f23).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GLTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '종료일(계획)'(f24).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZZPRIORITY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '우선순위'(f25).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'SNOTE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업특기사항'(f26).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(f07).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INLENGTH'.
        IF GV_CHK_GO_JOJANG = ABAP_TRUE OR GV_CHK_GO_HALF = ABAP_TRUE.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '개별조장'(f37).
        ELSE.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '표준조장'(f08).
        ENDIF.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업지시B/N'(f28).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'PSMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업지시량'(f29).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고량'(f30).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'GUBUN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구분'(f32).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'CLENGTH'.
        IF NOT ( GV_CHK_GO_JOJANG = ABAP_TRUE OR GV_CHK_GO_HALF = ABAP_TRUE ).
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDIF.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'QLENGTH'.
        IF NOT ( GV_CHK_GO_JOJANG = ABAP_TRUE OR GV_CHK_GO_HALF = ABAP_TRUE ).
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDIF.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'AUART'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GRPNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장구성표번호'(f34).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ORDNO_DM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매오더'(f44).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'POSNR_DM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매오더품목'(f45).
        <LS_FCAT>-JUST = 'C'.
    ENDCASE.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0101 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  DATA : LV_STYLE TYPE LVC_STYLE.


  LOOP AT GT_MAIN_DISP_101 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    REFRESH LT_CELLTAB.
    CASE <LS_MAIN>-GOBUN.
      WHEN 0.
        CLEAR LV_STYLE.

        IF <LS_MAIN>-ARBPL = GV_SELECTED_ARBPL.
          LV_STYLE = ALV_STYLE_COLOR_INT_POSITIVE.
        ELSE.
          LV_STYLE = ALV_STYLE_COLOR_TOTAL.
        ENDIF.

        LOOP AT GT_FIELDCAT_0101 INTO DATA(LS_FCAT).
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.

          CASE LS_FCAT-FIELDNAME.
            WHEN 'CHECK'.
              LS_CELLTAB-STYLE = LV_STYLE + ALV_STYLE_DISABLED.

            WHEN OTHERS.
              LS_CELLTAB-STYLE = LV_STYLE.
          ENDCASE.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
        ENDLOOP.

      WHEN OTHERS.
        LOOP AT GT_FIELDCAT_0101 INTO LS_FCAT.
          CASE LS_FCAT-FIELDNAME.
            WHEN 'CHECK'.
              CLEAR LS_CELLTAB.
              LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
              LS_CELLTAB-STYLE = ALV_STYLE_ENABLED.
              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
            WHEN 'ORDNR' OR 'POSNR' OR 'ORD_STAT' OR 'MATNR' OR 'COLOR'.
              CLEAR LS_CELLTAB.
              LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_KEY.
              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
            WHEN 'WKCHH' OR 'RATE_OP'.
              IF GV_SELECTED_DAY < SY-DATUM.
                CONTINUE.
              ENDIF.

              IF <LS_MAIN>-GSTRP = GV_SELECTED_DAY.
                CLEAR LS_CELLTAB.
                LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
                LS_CELLTAB-STYLE = ALV_STYLE_ENABLED.
                INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
              ENDIF.

          ENDCASE.
        ENDLOOP.

    ENDCASE.


    IF LT_CELLTAB IS NOT INITIAL.
      MOVE-CORRESPONDING LT_CELLTAB TO <LS_MAIN>-CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0101 .

  REFRESH GT_SORT_0101.

  PERFORM SET_SORT_TAB TABLES GT_SORT_0101
                            USING : 1 'GONG_CD' '' 'X' '',
                                       2 'ARBPL'  'X' '' '',
                                       3 'GOBUN'  'X' '' '',
                                       4 'SEQNO'  'X' '' ''.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0101_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0101_DISPLAY .

  CALL METHOD GO_GRID_0101->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0101
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0101
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_101
      IT_SORT              = GT_SORT_0101
      IT_FIELDCATALOG      = GT_FIELDCAT_0101.

  GO_GRID_0101->SET_READY_FOR_INPUT( 1 ).

** 인풋이벤트 추가
  CALL METHOD GO_GRID_0101->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0101->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.
*
*  IF GO_DD_DOCU_0101 IS BOUND.
*    CALL METHOD GO_DD_DOCU_0101->INITIALIZE_DOCUMENT.
*  ELSE.
*    CREATE OBJECT GO_DD_DOCU_0101
*      EXPORTING
*        STYLE = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
*  ENDIF.
*
*  CALL METHOD GO_GRID_0101->LIST_PROCESSING_EVENTS
*    EXPORTING
*      I_EVENT_NAME = 'TOP_OF_PAGE'
*      I_DYNDOC_ID  = GO_DD_DOCU_0101.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_0101_TOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_0101_TOP .

  REFRESH GT_EXCLUDE_0101_TOP.
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0101_TOP
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM ALV_TOP_OF_PAGE  USING    PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                               PV_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      PERFORM SET_TITLE_0100 CHANGING PV_DYNDOC_ID.
    WHEN GO_GRID_0101.
      PERFORM SET_TITLE_0101 CHANGING PV_DYNDOC_ID.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PV_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM SET_TITLE_0100  CHANGING PV_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  DATA : LV_TEXT(255) TYPE C.
  DATA : LV_FRDATE_C(10).
  DATA : LV_TODATE_C(10).
  DATA : LV_WEEKEND_DT TYPE SY-DATUM.

* 공정
  IF P_GONGNM IS INITIAL.
    SELECT SINGLE GONG_NM INTO P_GONGNM
         FROM ZEDT0011
        WHERE GONG_CD EQ P_GONGCD.
  ENDIF.

  LV_TEXT = P_GONGNM && '(' && P_GONGCD && ')'.

  CONCATENATE '공정 :' LV_TEXT INTO LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.


* 생산계획 주차
  CLEAR LV_TEXT.
  LV_FRDATE_C = P_WEEKFR+0(4) &&'.' && P_WEEKFR+4(2) &&'.' && P_WEEKFR+6(2).
  LV_TODATE_C = P_WEEKTO+0(4) &&'.' && P_WEEKTO+4(2) &&'.' && P_WEEKTO+6(2).

  LV_TEXT = '(' && LV_FRDATE_C &&' ~ ' && LV_TODATE_C && ')'.
  CONCATENATE '생산계획 주차 :' P_WEEK LV_TEXT INTO LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

* 작업설비
  CLEAR LV_TEXT.
  CLEAR GS_ARBPL.
  READ TABLE GT_ARBPL INTO GS_ARBPL WITH KEY ARBPL = GV_SELECTED_ARBPL.
  IF SY-SUBRC EQ 0.
    CONCATENATE '작업설비 :' GS_ARBPL-ARBPL GS_ARBPL-KTEXT INTO  LV_TEXT SEPARATED BY SPACE.
  ELSE.
    LV_TEXT = '작업설비 : 미지정'.
  ENDIF.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

* 주말일정 등록
  CLEAR LV_TEXT.
  IF GV_CHK_SKIP = ABAP_TRUE.
    LV_TEXT = '주말일정등록 : 가능'.
  ELSE.
    LV_TEXT = '주말일정등록 : 불가능'.
  ENDIF.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

* 수립일자
  CLEAR LV_TEXT.
  LV_TEXT = GV_SELECTED_DAY+0(4) && '.' && GV_SELECTED_DAY+4(2) && '.' && GV_SELECTED_DAY+6(2).
  CONCATENATE '수립일자 :' LV_TEXT INTO  LV_TEXT SEPARATED BY SPACE.
  IF GV_CHK_SKIP IS INITIAL.
    LV_WEEKEND_DT = P_WEEKTO - 1.
    CASE GV_SELECTED_DAY.
      WHEN LV_WEEKEND_DT OR P_WEEKTO.
        CONCATENATE LV_TEXT '(수립불가)' INTO  LV_TEXT.
    ENDCASE.
  ENDIF.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

  "위쪽에 추가한 텍스트 출력
  CALL METHOD GO_DD_DOCU_0100->DISPLAY_DOCUMENT
    EXPORTING
      PARENT             = GO_CONTAIN_TOP_0100
      REUSE_CONTROL      = ABAP_TRUE
      REUSE_REGISTRATION = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PV_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM SET_TITLE_0101  CHANGING PV_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  DATA : LV_TEXT(255) TYPE C.
  DATA : LV_FRDATE_C(10).
  DATA : LV_TODATE_C(10).
  DATA : LV_WEEKEND_DT TYPE SY-DATUM.

* 작업설비
  CLEAR LV_TEXT.
  CLEAR GS_ARBPL.
  READ TABLE GT_ARBPL INTO GS_ARBPL WITH KEY ARBPL = GV_SELECTED_ARBPL.
  IF SY-SUBRC EQ 0.
    CONCATENATE '선택설비 :' GS_ARBPL-ARBPL GS_ARBPL-KTEXT INTO  LV_TEXT SEPARATED BY SPACE.
  ELSE.
    LV_TEXT = '선택설비 : 미지정'.
  ENDIF.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

* 수립일자
  CLEAR LV_TEXT.
  LV_TEXT = GV_SELECTED_DAY+0(4) && '.' && GV_SELECTED_DAY+4(2) && '.' && GV_SELECTED_DAY+6(2).
  CONCATENATE '선택일자 :' LV_TEXT INTO  LV_TEXT SEPARATED BY SPACE.
  IF GV_CHK_SKIP IS INITIAL.
    LV_WEEKEND_DT = P_WEEKTO - 1.
    CASE GV_SELECTED_DAY.
      WHEN LV_WEEKEND_DT OR P_WEEKTO.
        CONCATENATE LV_TEXT '(수립불가)' INTO  LV_TEXT.
    ENDCASE.
  ENDIF.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

  "위쪽에 추가한 텍스트 출력
  CALL METHOD GO_DD_DOCU_0101->DISPLAY_DOCUMENT
    EXPORTING
      PARENT             = GO_CONTAIN_0101_TITLE
      REUSE_CONTROL      = ABAP_TRUE
      REUSE_REGISTRATION = ABAP_TRUE.

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

  DATA : LV_UCOMM TYPE SY-UCOMM.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_VALUE(10).



  CASE PO_SENDER.
    WHEN GO_GRID_0100.

      CHECK GV_CHK_PAST IS INITIAL.

      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                     USING : 'REGISTER' ICON_TREND_DOWN '일정등록' '일정등록' 0.

      IF GV_CHK_SKIP IS INITIAL.
        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                       USING : 'SKIP' ICON_BOOKING_STOP '주말일정 제외' '주말일정 제외' 0.
      ELSE.
        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                       USING : 'INCLUDE' ICON_BOOKING_OK '주말일정 등록' '주말일정 등록' 0.
      ENDIF.

      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                     USING :  '' '' '' '' 3,
                                 'ADD_GAMNG' ICON_SET_STATE '계획량추가' '계획량추가' 0,
                                 '' '' '' '' 3,
                                'CRT_ORDER1' ICON_CREATE '생산오더 생성' '생산오더 생성' 0,
                                'CRT_ORDER3' ICON_CREATE '재생산오더 생성' '재생산오더 생성' 0,
                                'CRT_ORDER2' ICON_CREATE '시작업오더 생성' '시작업오더 생성' 0.

      IF P_WERKS = '6600' AND P_SPGCD = 'GL' AND P_GONGCD = 'REW'.
        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                             USING : 'CRT_ORDER4' ICON_CREATE '분할오더 생성' '분할오더 생성' 0.
      ENDIF.

      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                     USING : '' '' '' '' 3,
                                'DELE' ICON_DELETE '오더삭제' '오더삭제' 0,
                                '' '' '' '' 3.

    WHEN GO_GRID_0101_TOP.
*      LV_VALUE = GV_SELECTED_DAY+0(4) && '.' && GV_SELECTED_DAY+4(2) && '.' && GV_SELECTED_DAY+6(2).
*      READ TABLE GT_WEEK_DISP INTO DATA(LS_WEEK) INDEX 1.
*
*      LOOP AT GT_FIELDCAT_0101_TOP INTO DATA(LS_FCAT).
*        CLEAR LV_UCOMM.
*        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
*                             USING LS_FCAT-FIELDNAME '' LS_WEEK-(LS_FCAT-FIELDNAME) LS_WEEK-(LS_FCAT-FIELDNAME) 0.
*
*        FIND  LV_VALUE IN LS_WEEK-(LS_FCAT-FIELDNAME).
*        IF SY-SUBRC EQ 0.
*          LV_FIELDNAME = LS_FCAT-FIELDNAME.
*        ENDIF.
*      ENDLOOP.
*
*      READ TABLE PO_OBJECT->MT_TOOLBAR ASSIGNING FIELD-SYMBOL(<LS_UI>) WITH KEY FUNCTION = LV_FIELDNAME.
*      IF SY-SUBRC EQ 0.
*        <LS_UI>-DISABLED = ABAP_TRUE.
*      ENDIF.

    WHEN GO_GRID_0101.

      LV_VALUE = GV_SELECTED_DAY+0(4) && '.' && GV_SELECTED_DAY+4(2) && '.' && GV_SELECTED_DAY+6(2).
      READ TABLE GT_WEEK_DISP INTO DATA(LS_WEEK) INDEX 1.

      LOOP AT GT_FIELDCAT_0101_TOP INTO DATA(LS_FCAT).
        CLEAR LV_UCOMM.
        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                             USING LS_FCAT-FIELDNAME '' LS_WEEK-(LS_FCAT-FIELDNAME) LS_WEEK-(LS_FCAT-FIELDNAME) 0.

        FIND  LV_VALUE IN LS_WEEK-(LS_FCAT-FIELDNAME).
        IF SY-SUBRC EQ 0.
          LV_FIELDNAME = LS_FCAT-FIELDNAME.
        ENDIF.
      ENDLOOP.

      READ TABLE PO_OBJECT->MT_TOOLBAR ASSIGNING FIELD-SYMBOL(<LS_UI>) WITH KEY FUNCTION = LV_FIELDNAME.
      IF SY-SUBRC EQ 0.
        <LS_UI>-DISABLED = ABAP_TRUE.
      ENDIF.

      IF  GV_CHK_PAST IS INITIAL.
        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                 USING : '' '' '' '' 3,
                            'CANCEL_WORKING' ICON_TREND_UP '일정취소' '일정취소' 0,
                            '' '' '' '' 3,
                             'SAVE' ICON_SYSTEM_SAVE '변경상태저장' '변경상태저장' 0,
                             '' '' '' '' 3,
                            'RELEASE' ICON_RELEASE '생산오더 릴리즈' '생산오더 릴리즈' 0,
                            '' '' '' '' 3.
*                          'REPLACE_DRUM' ICON_EXTRA '드럼 재지정' '드럼 재지정' 0.

        IF GV_CHK_PRD = ABAP_TRUE.
* 드럼 재지정 추가.
          PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                  USING : 'REPLACE_DRUM' ICON_MASS_CHANGE_DONE '드럼 재지정' '드럼 재지정' 0,
                             '' '' '' '' 3.
        ENDIF.
      ELSE.
        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
               USING : '' '' '' '' 3,
                          'CANCEL_WORKING' ICON_TREND_UP '일정취소' '일정취소' 0.
      ENDIF.

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
        WHEN 'REGISTER'.
          PERFORM PROC_REGISTER.
        WHEN 'CRT_ORDER1' OR 'CRT_ORDER2' OR 'CRT_ORDER3' OR 'CRT_ORDER4'.
          PERFORM PROC_CRT_ORDERS USING PV_UCOMM.
        WHEN 'DELE'.
          PERFORM DELETE_PRD_ORDER.
        WHEN 'SKIP' OR 'INCLUDE'.
          PERFORM SET_WEEKEND_SKIP USING PV_UCOMM.
        WHEN 'ADD_GAMNG'. " 계획량 추가
          PERFORM PROC_ADD_GSMNG.
      ENDCASE.

    WHEN GO_GRID_0101_TOP.

    WHEN GO_GRID_0101.
      CASE PV_UCOMM.
        WHEN 'CANCEL_WORKING'.
          PERFORM PROC_CANCEL_WORKING.
        WHEN 'RELEASE'.
          PERFORM RELEASE_PRD_ORDER.
        WHEN 'SAVE'.
          PERFORM PROC_SAVE.
        WHEN 'CHECK_LINE'.
          PERFORM PROCESS_CHECK_LINE_0101.
        WHEN 'DECHECK_LINE'.
          PERFORM PROCESS_DECHECK_LINE_0101.
        WHEN 'REPLACE_DRUM'.
          PERFORM PROCESS_REPLACE_DRUM.
        WHEN OTHERS.
          PERFORM SET_SCREEN_101 USING PV_UCOMM.
      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_WEEKEND_SKIP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_UCOMM
*&---------------------------------------------------------------------*
FORM SET_WEEKEND_SKIP  USING    PV_UCOMM.

  CASE PV_UCOMM.
    WHEN 'SKIP'.
      GV_CHK_SKIP = ABAP_TRUE.
    WHEN 'INCLUDE'.
      CLEAR GV_CHK_SKIP.
  ENDCASE.

  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SCREEN_101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_UCOMM
*&---------------------------------------------------------------------*
FORM SET_SCREEN_101  USING    PV_UCOMM.

  DATA : LV_FIELDNAME TYPE FIELDNAME.
  FIELD-SYMBOLS <LV_VALUE> TYPE ANY.

  IF GV_CHK_CHG_101 = ABAP_TRUE.
    CLEAR GV_ANSWER.
    PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
      ' '
      '변경된 일정 정보가 있습니다. 저장 없이 진행 하시겠습니까?'
      '변경확인'.
    IF GV_ANSWER NE 'J'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
      RETURN.
    ENDIF.

    REFRESH GT_ORDSYVAL_CHG.
    CLEAR GV_CHK_CHG_101.
  ENDIF.

  LV_FIELDNAME = PV_UCOMM.
  READ TABLE GT_WEEK_DISP INTO DATA(LS_WEEK) INDEX 1.

  ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE LS_WEEK TO <LV_VALUE>.

  CLEAR GV_SELECTED_DAY.
  GV_SELECTED_DAY = <LV_VALUE>+0(4) && <LV_VALUE>+5(2) && <LV_VALUE>+8(2).

*    해당 설비별 순번별 일자별 수립된 작업 시간 관리
  REFRESH GT_WORKTIME_DAY.
  PERFORM SET_CRT_TIME_DAY.

  REFRESH GT_MAIN_DISP_101.
  PERFORM MAKE_PLAN_DISP_DATA TABLES GT_ORDSYVAL_PLANED.

  PERFORM SET_TOTAL_DISP_TABLE.

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

*  PERFORM REFRESH_GRID USING GO_GRID_0101_TOP.
  PERFORM REFRESH_GRID USING GO_GRID_0101.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm_step
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_STEP  USING LP_OPT
                                  LP_TEXT1
                                  LP_TEXT2
                                  LP_TITLE.
  CLEAR GV_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      DEFAULTOPTION  = LP_OPT
      TEXTLINE1      = LP_TEXT1
      TEXTLINE2      = LP_TEXT2
      TITEL          = LP_TITLE
      CANCEL_DISPLAY = ''
    IMPORTING
      ANSWER         = GV_ANSWER.

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
  DATA : LV_CHK_ERR.
  DATA : LV_CALL_FUNC.
  DATA : LV_CALL_FUNC_CAL.
  DATA : LV_MENGE TYPE MENGE_D.

  DEFINE __SET_ERR_MSG.
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
      i_row_id     = &1                 " Row ID
      i_fieldname = &2                 " Field Name
      i_value       = &3 ).               " Value
  END-OF-DEFINITION.

  CASE P_SENDER.
    WHEN GO_GRID_0100 .
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'CHECK'.
            GV_CHK_LINE = LS_MOD_CELLS-ROW_ID.
            GV_CHK_VALUE = LS_MOD_CELLS-VALUE.
            GV_CHK_SCREEN = '0100'.
            LV_CALL_FUNC = ABAP_TRUE.
*          WHEN 'MENGE'.
*            READ TABLE GT_MAIN_DISP_100 INTO DATA(LS_MAIN_100) INDEX LS_MOD_CELLS-ROW_ID.
*            CLEAR LV_MENGE.
*            LV_MENGE = LS_MAIN_100-INLENGTH * LS_MOD_CELLS-VALUE.
*            __MODI_CELL LS_MOD_CELLS-ROW_ID 'MENGE01' LV_MENGE.
        ENDCASE.
      ENDLOOP.
    WHEN GO_GRID_0101 .
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'WKCHH'.
            READ TABLE GT_MAIN_DISP_101 INTO DATA(LS_MAIN) INDEX  LS_MOD_CELLS-ROW_ID.
            CLEAR LV_CHK_ERR.
            PERFORM CHK_CHG_TIME_WKCHH USING LS_MOD_CELLS-VALUE LS_MAIN-ARBPL LS_MAIN-ORDNR LS_MAIN-POSNR
                                                    CHANGING LV_CHK_ERR.
            IF LV_CHK_ERR IS INITIAL.
              __MODI_CELL LS_MOD_CELLS-ROW_ID 'CHK_CHG' 'X'.
              LV_CALL_FUNC_CAL = ABAP_TRUE.
            ELSE.
              __SET_ERR_MSG '작업 시간 초과로 일정에서 벗어나는 오더가 있습니다.' LS_MOD_CELLS-FIELDNAME.
              EXIT.
            ENDIF.

          WHEN 'ZWKLTH' .

*            READ TABLE GT_MAIN_DISP_101 INTO LS_MAIN INDEX  LS_MOD_CELLS-ROW_ID.
*            CLEAR LV_CHK_ERR.
*            PERFORM CHK_CHG_TIME_ZWKLTH USING LS_MOD_CELLS-VALUE LS_MAIN-ARBPL LS_MAIN-ORDNR LS_MAIN-POSNR
*                                                    CHANGING LV_CHK_ERR.
*            IF LV_CHK_ERR IS INITIAL.
*              __MODI_CELL LS_MOD_CELLS-ROW_ID 'CHK_CHG' 'X'.
*              LV_CALL_FUNC_CAL = ABAP_TRUE.
*            ELSE.
*              __SET_ERR_MSG '작업 시간 초과로 일정에서 벗어나는 오더가 있습니다.' LS_MOD_CELLS-FIELDNAME.
*              EXIT.
*            ENDIF.
          WHEN 'RATE_OP' .
            CLEAR LV_MENGE.
            LV_MENGE = LS_MOD_CELLS-VALUE.
            IF LV_MENGE = 0.
              LV_CHK_ERR = ABAP_TRUE.
              __SET_ERR_MSG '가동율이 0이면 작업시간을 계산할 수 없습니다.' LS_MOD_CELLS-FIELDNAME.
              EXIT.
            ENDIF.

            READ TABLE GT_MAIN_DISP_101 INTO LS_MAIN INDEX  LS_MOD_CELLS-ROW_ID.
            CLEAR LV_CHK_ERR.
            PERFORM CHK_CHG_TIME_RATE_OP USING LS_MOD_CELLS-VALUE LS_MAIN-ARBPL LS_MAIN-ORDNR LS_MAIN-POSNR
                                                    CHANGING LV_CHK_ERR.
            IF LV_CHK_ERR IS INITIAL.
              __MODI_CELL LS_MOD_CELLS-ROW_ID 'CHK_CHG' 'X'.
              LV_CALL_FUNC_CAL = ABAP_TRUE.
            ELSE.
              __SET_ERR_MSG '작업 시간 초과로 일정에서 벗어나는 오더가 있습니다.' LS_MOD_CELLS-FIELDNAME.
              EXIT.
            ENDIF.
        ENDCASE.
      ENDLOOP.


  ENDCASE.

  IF LV_CHK_ERR IS NOT INITIAL.
    PO_DATA_CHANGED->DISPLAY_PROTOCOL( ).
  ENDIF.

  IF LV_CALL_FUNC IS NOT INITIAL.
    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'SETCHECK'              " Function code
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
        OTHERS                 = 2.
    IF SY-SUBRC <> 0.
    ENDIF.
  ENDIF.

  IF LV_CALL_FUNC_CAL IS NOT INITIAL.
    GV_CHK_CHG_101 = ABAP_TRUE.
    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'CAL_MENG'              " Function code
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
        OTHERS                 = 2.
    IF SY-SUBRC <> 0.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_CHG_TIME_WKCHH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MOD_CELLS_VALUE
*&      --> LS_MAIN_ARBPL
*&      --> LS_MAIN_ORDNR
*&      --> LS_MAIN_POSNR
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_CHG_TIME_WKCHH  USING    PV_VALUE
                                  PV_ARBPL TYPE CRHD_V1-ARBPL
                                  PV_ORDNR
                                  PV_POSNR
                         CHANGING PV_CHK_ERR.

  DATA : LV_ORDNR TYPE ZGTPPT2010-ORDNR.
  DATA : LT_WORKTIME_DAY LIKE GT_WORKTIME_DAY.
  DATA : LV_CAL_WKCHH TYPE ZGTPPT2400-ZWKCHH.
  DATA : LV_LINES TYPE I.
  DATA : LV_INDEX TYPE I.
  DATA : LV_LAST_CURRENT_TIME TYPE ZGTPPT2400-ZWKCHH..

  DATA : BEGIN OF LS_CHG_AUFNR_INFOR,
           GSUZP TYPE AFKO-GSUZP,
           GLTRP TYPE AFKO-GLTRP,
           GLUZP TYPE AFKO-GLUZP,
         END OF LS_CHG_AUFNR_INFOR.

  DATA : LV_HOURS(2) TYPE N.
  DATA : LV_MINUTE(2) TYPE N.

  LV_ORDNR = PV_ORDNR.
  __ALPHA_INPUT LV_ORDNR.

  LT_WORKTIME_DAY = GT_WORKTIME_DAY.

  READ TABLE GT_WORKTIME_DAY ASSIGNING FIELD-SYMBOL(<LS_WORKTIME_DAY>) WITH KEY DATE = GV_SELECTED_DAY
                                                                                                                  ARBPL = PV_ARBPL.
  IF SY-SUBRC EQ 0.
    READ TABLE <LS_WORKTIME_DAY>-T_ORDNRS ASSIGNING FIELD-SYMBOL(<LS_ORDERS>) WITH KEY ORDNR = PV_ORDNR.
    IF SY-SUBRC EQ 0.
      CLEAR <LS_ORDERS>-WKCHH.
      LOOP AT GT_MAIN_DISP_101 INTO DATA(LS_PLAN) WHERE ORDNR = PV_ORDNR.

        IF LS_PLAN-POSNR = PV_POSNR.

* 복조장의 경우 여러라인 존재 가능 하므로 원본 라인의 작업변경시간 제외후 변경수량으로 적용
          <LS_ORDERS>-WKCHH = <LS_ORDERS>-WKCHH + PV_VALUE.
        ELSE..
          <LS_ORDERS>-WKCHH = <LS_ORDERS>-WKCHH + LS_PLAN-WKCHH.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  LV_LINES = LINES( <LS_WORKTIME_DAY>-T_ORDNRS ).

* 수량 반영후 체크
  CLEAR <LS_WORKTIME_DAY>-CURRENT_TIME.
  CLEAR LV_INDEX.
  LOOP AT <LS_WORKTIME_DAY>-T_ORDNRS ASSIGNING <LS_ORDERS>.
    ADD 1 TO LV_INDEX.
    IF LV_INDEX = LV_LINES.
      LV_LAST_CURRENT_TIME = <LS_ORDERS>-CURRENT_TIME.
    ENDIF.
* 가동율 포함하여 수량 계산
* 가동율 포함하여 수량 계산
    <LS_ORDERS>-ZWKLTH = <LS_ORDERS>-ZWKLTH_B / <LS_ORDERS>-RATE_OP_B * <LS_ORDERS>-RATE_OP.
    <LS_ORDERS>-CURRENT_TIME = <LS_ORDERS>-ZWKLTH + <LS_ORDERS>-WKCHH.
    ADD <LS_ORDERS>-CURRENT_TIME TO <LS_WORKTIME_DAY>-CURRENT_TIME.

    IF <LS_WORKTIME_DAY>-CURRENT_TIME > 24.
      IF LV_INDEX = LV_LINES. " 마지막 라인의 경우 수량 계산 적용.
        LV_ORDNR = <LS_ORDERS>-ORDNR.
        __ALPHA_INPUT LV_ORDNR.

        READ TABLE GT_ORDSYVAL_PLANED ASSIGNING FIELD-SYMBOL(<LS_ORDSYVAL>) WITH KEY AUFNR = LV_ORDNR.
        IF SY-SUBRC EQ 0.
          LS_CHG_AUFNR_INFOR-GSUZP = <LS_ORDSYVAL>-GSUZP.
          LS_CHG_AUFNR_INFOR-GLTRP = <LS_ORDSYVAL>-GLTRP.
          LS_CHG_AUFNR_INFOR-GLUZP = <LS_ORDSYVAL>-GLUZP.

          LV_CAL_WKCHH = 24 - ( <LS_WORKTIME_DAY>-CURRENT_TIME - <LS_ORDERS>-CURRENT_TIME ) .

          LV_HOURS = TRUNC( LV_CAL_WKCHH ).
          LV_MINUTE = FRAC( LV_CAL_WKCHH ) * 60.
          LS_CHG_AUFNR_INFOR-GSUZP = LV_HOURS && LV_MINUTE && '00'.
* 종료시간
          LV_CAL_WKCHH = <LS_WORKTIME_DAY>-CURRENT_TIME.
          IF TRUNC( LV_LAST_CURRENT_TIME / 24 ) = TRUNC( LV_CAL_WKCHH / 24 ).
            DO.
              IF LV_CAL_WKCHH < 24.
                EXIT.
              ENDIF.
              LV_CAL_WKCHH = LV_CAL_WKCHH - 24.
            ENDDO.

            LV_HOURS = TRUNC( LV_CAL_WKCHH ).
            LV_MINUTE = FRAC( LV_CAL_WKCHH ) * 60.
            LS_CHG_AUFNR_INFOR-GLUZP = LV_HOURS && LV_MINUTE && '00'.
          ELSE.

            DO.
              IF LV_CAL_WKCHH < 24.
                EXIT.
              ENDIF.
              LS_CHG_AUFNR_INFOR-GLTRP = LS_CHG_AUFNR_INFOR-GLTRP + 1.
              LV_CAL_WKCHH = LV_CAL_WKCHH - 24.
            ENDDO.

            LV_HOURS = TRUNC( LV_CAL_WKCHH ).
            LV_MINUTE = FRAC( LV_CAL_WKCHH ) * 60.
            LS_CHG_AUFNR_INFOR-GLUZP = LV_HOURS && LV_MINUTE && '00'.
          ENDIF.

          LOOP AT GT_ORDSYVAL_PLANED ASSIGNING <LS_ORDSYVAL> WHERE AUFNR = LV_ORDNR.
            MOVE LS_CHG_AUFNR_INFOR-GSUZP TO <LS_ORDSYVAL>-GSUZP.
            MOVE LS_CHG_AUFNR_INFOR-GLTRP TO <LS_ORDSYVAL>-GLTRP.
            MOVE LS_CHG_AUFNR_INFOR-GLUZP TO <LS_ORDSYVAL>-GLUZP.

            READ TABLE GT_ORDSYVAL_CHG ASSIGNING FIELD-SYMBOL(<LS_ORDSYVAL_CHG>) WITH KEY AUFNR = <LS_ORDSYVAL>-AUFNR
                                                                                                                                     POSNR = <LS_ORDSYVAL>-POSNR.
            IF SY-SUBRC EQ 0.
              MOVE-CORRESPONDING <LS_ORDSYVAL> TO <LS_ORDSYVAL_CHG>.
            ELSE.
              APPEND INITIAL LINE TO GT_ORDSYVAL_CHG ASSIGNING <LS_ORDSYVAL_CHG>.
              MOVE-CORRESPONDING <LS_ORDSYVAL> TO <LS_ORDSYVAL_CHG>.
            ENDIF.

          ENDLOOP.
        ELSE.
          PV_CHK_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.

      ELSE.
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_CHG_TIME_ZWKLTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MOD_CELLS_VALUE
*&      --> LS_MAIN_ARBPL
*&      --> LS_MAIN_ORDNR
*&      --> LS_MAIN_POSNR
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_CHG_TIME_ZWKLTH  USING   PV_VALUE
                                  PV_ARBPL TYPE CRHD_V1-ARBPL
                                  PV_ORDNR
                                  PV_POSNR
                         CHANGING PV_CHK_ERR.

  DATA : LV_ORDNR TYPE ZGTPPT2010-ORDNR.
  DATA : LT_WORKTIME_DAY LIKE GT_WORKTIME_DAY.
  DATA : LV_CAL_WKCHH TYPE ZGTPPT2400-ZWKCHH.
  DATA : LV_LINES TYPE I.
  DATA : LV_INDEX TYPE I.
  DATA : LV_LAST_CURRENT_TIME TYPE ZGTPPT2400-ZWKCHH..

  DATA : BEGIN OF LS_CHG_AUFNR_INFOR,
           GSUZP TYPE AFKO-GSUZP,
           GLTRP TYPE AFKO-GLTRP,
           GLUZP TYPE AFKO-GLUZP,
         END OF LS_CHG_AUFNR_INFOR.

  DATA : LV_HOURS(2) TYPE N.
  DATA : LV_MINUTE(2) TYPE N.

  LV_ORDNR = PV_ORDNR.
  __ALPHA_INPUT LV_ORDNR.

  LT_WORKTIME_DAY = GT_WORKTIME_DAY.

  READ TABLE LT_WORKTIME_DAY ASSIGNING FIELD-SYMBOL(<LS_WORKTIME_DAY>) WITH KEY DATE = GV_SELECTED_DAY
                                                                                                                  ARBPL = PV_ARBPL.
  IF SY-SUBRC EQ 0.
    READ TABLE <LS_WORKTIME_DAY>-T_ORDNRS ASSIGNING FIELD-SYMBOL(<LS_ORDERS>) WITH KEY ORDNR = PV_ORDNR.
    IF SY-SUBRC EQ 0.
      CLEAR <LS_ORDERS>-ZWKLTH.
      LOOP AT GT_MAIN_DISP_101 INTO DATA(LS_PLAN) WHERE ORDNR = PV_ORDNR.

        IF LS_PLAN-POSNR = PV_POSNR.

* 복조장의 경우 여러라인 존재 가능 하므로 원본 라인의 작업변경시간 제외후 변경수량으로 적용
          <LS_ORDERS>-ZWKLTH = <LS_ORDERS>-WKCHH + PV_VALUE.
        ELSE..
          <LS_ORDERS>-ZWKLTH = <LS_ORDERS>-ZWKLTH + LS_PLAN-ZWKLTH.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  LV_LINES = LINES( <LS_WORKTIME_DAY>-T_ORDNRS ).

* 수량 반영후 체크
  CLEAR <LS_WORKTIME_DAY>-CURRENT_TIME.
  CLEAR LV_INDEX.
  LOOP AT <LS_WORKTIME_DAY>-T_ORDNRS ASSIGNING <LS_ORDERS>.
    ADD 1 TO LV_INDEX.
    IF LV_INDEX = LV_LINES.
      LV_LAST_CURRENT_TIME = <LS_ORDERS>-CURRENT_TIME.
    ENDIF.

    <LS_ORDERS>-CURRENT_TIME = <LS_ORDERS>-WKCHH + <LS_ORDERS>-ZWKLTH.
    ADD <LS_ORDERS>-CURRENT_TIME TO <LS_WORKTIME_DAY>-CURRENT_TIME.

    IF <LS_WORKTIME_DAY>-CURRENT_TIME > 24.
      IF LV_INDEX = LV_LINES. " 마지막 라인의 경우 수량 계산 적용.
        LV_ORDNR = <LS_ORDERS>-ORDNR.
        __ALPHA_INPUT LV_ORDNR.

        READ TABLE GT_ORDSYVAL_PLANED ASSIGNING FIELD-SYMBOL(<LS_ORDSYVAL>) WITH KEY AUFNR = LV_ORDNR.
        IF SY-SUBRC EQ 0.
          LS_CHG_AUFNR_INFOR-GSUZP = <LS_ORDSYVAL>-GSUZP.
          LS_CHG_AUFNR_INFOR-GLTRP = <LS_ORDSYVAL>-GLTRP.
          LS_CHG_AUFNR_INFOR-GLUZP = <LS_ORDSYVAL>-GLUZP.

          LV_CAL_WKCHH = 24 - ( <LS_WORKTIME_DAY>-CURRENT_TIME - <LS_ORDERS>-CURRENT_TIME ) .

          LV_HOURS = TRUNC( LV_CAL_WKCHH ).
          LV_MINUTE = FRAC( LV_CAL_WKCHH ) * 60.
          LS_CHG_AUFNR_INFOR-GSUZP = LV_HOURS && LV_MINUTE && '00'.
* 종료시간
          LV_CAL_WKCHH = <LS_WORKTIME_DAY>-CURRENT_TIME.
          IF TRUNC( LV_LAST_CURRENT_TIME / 24 ) = TRUNC( LV_CAL_WKCHH / 24 ).
            DO.
              IF LV_CAL_WKCHH < 24.
                EXIT.
              ENDIF.
              LV_CAL_WKCHH = LV_CAL_WKCHH - 24.
            ENDDO.

            LV_HOURS = TRUNC( LV_CAL_WKCHH ).
            LV_MINUTE = FRAC( LV_CAL_WKCHH ) * 60.
            LS_CHG_AUFNR_INFOR-GLUZP = LV_HOURS && LV_MINUTE && '00'.
          ELSE.

            DO.
              IF LV_CAL_WKCHH < 24.
                EXIT.
              ENDIF.
              LS_CHG_AUFNR_INFOR-GLTRP = LS_CHG_AUFNR_INFOR-GLTRP + 1.
              LV_CAL_WKCHH = LV_CAL_WKCHH - 24.
            ENDDO.

            LV_HOURS = TRUNC( LV_CAL_WKCHH ).
            LV_MINUTE = FRAC( LV_CAL_WKCHH ) * 60.
            LS_CHG_AUFNR_INFOR-GLUZP = LV_HOURS && LV_MINUTE && '00'.
          ENDIF.

          LOOP AT GT_ORDSYVAL_PLANED ASSIGNING <LS_ORDSYVAL> WHERE AUFNR = LV_ORDNR.
            MOVE LS_CHG_AUFNR_INFOR-GSUZP TO <LS_ORDSYVAL>-GSUZP.
            MOVE LS_CHG_AUFNR_INFOR-GLTRP TO <LS_ORDSYVAL>-GLTRP.
            MOVE LS_CHG_AUFNR_INFOR-GLUZP TO <LS_ORDSYVAL>-GLUZP.

            READ TABLE GT_ORDSYVAL_CHG ASSIGNING FIELD-SYMBOL(<LS_ORDSYVAL_CHG>) WITH KEY AUFNR = <LS_ORDSYVAL>-AUFNR
                                                                                                                                     POSNR = <LS_ORDSYVAL>-POSNR.
            IF SY-SUBRC EQ 0.
              MOVE-CORRESPONDING <LS_ORDSYVAL> TO <LS_ORDSYVAL_CHG>.
            ELSE.
              APPEND INITIAL LINE TO GT_ORDSYVAL_CHG ASSIGNING <LS_ORDSYVAL_CHG>.
              MOVE-CORRESPONDING <LS_ORDSYVAL> TO <LS_ORDSYVAL_CHG>.
            ENDIF.

          ENDLOOP.
        ELSE.
          PV_CHK_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.

      ELSE.
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.

    ENDIF.

  ENDLOOP.

  GT_WORKTIME_DAY = LT_WORKTIME_DAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONTEXT_MENU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&---------------------------------------------------------------------*
FORM CONTEXT_MENU  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                         P_OBJECT TYPE REF TO CL_CTMENU.

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA: LT_STD_FCODES TYPE UI_FUNCTIONS,
        LT_OWN_FCODES TYPE UI_FUNCTIONS.
  DATA : LV_TEXT TYPE GUI_TEXT.
  DATA : LV_CHK_EXIST.

  CASE P_SENDER.
    WHEN GO_GRID_0101.

      GO_GRID_0101->GET_SELECTED_CELLS_ID(
        IMPORTING
         ET_CELLS = LT_CELLS ).                " Cell IDs

      IF LT_CELLS[] IS INITIAL.
        RETURN.
      ENDIF.

      P_OBJECT->CLEAR( ).

      LOOP AT LT_CELLS INTO DATA(LS_CELLS).
        READ TABLE GT_MAIN_DISP_101 INTO DATA(LS_MAIN) INDEX LS_CELLS-ROW_ID.
        IF LS_MAIN-CHECK = ABAP_TRUE.
          LV_CHK_EXIST = ABAP_TRUE.
        ENDIF.

      ENDLOOP.

      IF LV_CHK_EXIST = ABAP_TRUE.
        LV_TEXT = '선택해제'.
        CALL METHOD P_OBJECT->ADD_FUNCTION
          EXPORTING
            FCODE = 'DECHECK_LINE'
            TEXT  = LV_TEXT.
      ELSE.
        LV_TEXT = '선택'.
        CALL METHOD P_OBJECT->ADD_FUNCTION
          EXPORTING
            FCODE = 'CHECK_LINE'
            TEXT  = LV_TEXT.
      ENDIF.
      CALL METHOD P_OBJECT->SHOW_FUNCTIONS
        EXPORTING
          FCODES = LT_OWN_FCODES.

      CALL METHOD CL_GUI_CFW=>FLUSH.

    WHEN OTHERS.
      RETURN.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHECK_ALL_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CHECK_ALL_100 .

  LOOP AT GT_MAIN_DISP_100 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) .
    <LS_MAIN>-CHECK = ABAP_TRUE.
  ENDLOOP.
  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHECK_DESEL_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CHECK_DESEL_100 .

  LOOP AT GT_MAIN_DISP_100 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) .
    CLEAR <LS_MAIN>-CHECK.
  ENDLOOP.
  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SCREEN_100_CHECKED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SCREEN_100_CHECKED .

  READ TABLE GT_MAIN_DISP_100 INTO DATA(LS_MAIN)  INDEX GV_CHK_LINE.
  IF SY-SUBRC EQ 0.
    IF LS_MAIN-GCATG = '생산오더'.
      LOOP AT GT_MAIN_DISP_100 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) WHERE ORDNR = LS_MAIN-ORDNR.
        <LS_MAIN>-CHECK = GV_CHK_VALUE.
      ENDLOOP.
    ENDIF.
  ENDIF.

  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SCREEN_101_CHECKED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SCREEN_101_CHECKED .

  READ TABLE GT_MAIN_DISP_101 INTO DATA(LS_MAIN)  INDEX GV_CHK_LINE.
  IF SY-SUBRC EQ 0.
    LOOP AT GT_MAIN_DISP_101 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) WHERE ORDNR = LS_MAIN-ORDNR.
      <LS_MAIN>-CHECK = GV_CHK_VALUE.
    ENDLOOP.
  ENDIF.

  PERFORM REFRESH_GRID USING GO_GRID_0101.

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

  IF P_ROW-INDEX = 0.
    RETURN.
  ENDIF.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      READ TABLE GT_MAIN_DISP_100 INTO DATA(LS_MAIN_100) INDEX P_ROW-INDEX.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'GRPNR'.
          CASE LS_MAIN_100-GCATG.
            WHEN '계획오더'.
              SET PARAMETER ID 'PAF' FIELD LS_MAIN_100-ORDNR.
              CALL TRANSACTION 'MD13' AND SKIP FIRST SCREEN.
            WHEN '판매오더'.
              SET PARAMETER ID 'AUN' FIELD LS_MAIN_100-ORDNR.
              CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
              SET PARAMETER ID 'AUN' FIELD ''.
            WHEN 'SM오더'.
              PERFORM DISP_POPUP_SMORDER USING LS_MAIN_100-ORDNR LS_MAIN_100-POSNR.
            WHEN OTHERS.
              SET PARAMETER ID 'ANR' FIELD LS_MAIN_100-ORDNR.
              CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
              SET PARAMETER ID 'ANR' FIELD ''.
          ENDCASE.

        WHEN 'MATNR'.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'A'.
          SET PARAMETER ID 'MAT' FIELD LS_MAIN_100-MATNR.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'MXX' FIELD ' '.
          SET PARAMETER ID 'MAT' FIELD ' '.

        WHEN 'MENGE01' OR 'MENGE02'.
          IF GV_CHK_GO_JOJANG = ABAP_TRUE.
            RETURN.
          ENDIF.
          CASE LS_MAIN_100-GCATG.
            WHEN '생산오더'.
            WHEN OTHERS.
              IF LS_MAIN_100-MENGE02 NE 0.
                PERFORM DISP_POPUP_ORDERS USING LS_MAIN_100.
              ENDIF.
          ENDCASE.

      ENDCASE.


    WHEN GO_GRID_0101.
      READ TABLE GT_MAIN_DISP_101 INTO DATA(LS_MAIN_101) INDEX P_ROW-INDEX.
      IF LS_MAIN_101-GOBUN = 0.
        GV_SELECTED_ARBPL = LS_MAIN_101-ARBPL.


* 탑오브페이지 리프레쉬
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

* 탑오브페이지 리프레쉬
        IF GO_DD_DOCU_0101 IS BOUND.
          CALL METHOD GO_DD_DOCU_0101->INITIALIZE_DOCUMENT.
        ELSE.
          CREATE OBJECT GO_DD_DOCU_0101
            EXPORTING
              STYLE = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
        ENDIF.

        CALL METHOD GO_GRID_0101->LIST_PROCESSING_EVENTS
          EXPORTING
            I_EVENT_NAME = 'TOP_OF_PAGE'
            I_DYNDOC_ID  = GO_DD_DOCU_0101.

        PERFORM REFRESH_GRID USING GO_GRID_0101.

      ELSE.
        CASE P_COLUMN-FIELDNAME.
          WHEN 'ORDNR' OR 'POSNR'.
            SET PARAMETER ID 'ANR' FIELD LS_MAIN_101-ORDNR.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
            SET PARAMETER ID 'ANR' FIELD ''.

          WHEN 'MATNR' OR 'MAKTX'.

            SET PARAMETER ID 'WRK' FIELD P_WERKS.
            SET PARAMETER ID 'MXX' FIELD 'A'.
            SET PARAMETER ID 'MAT' FIELD LS_MAIN_101-MATNR.
            CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
            SET PARAMETER ID 'MXX' FIELD ' '.
            SET PARAMETER ID 'MAT' FIELD ' '.

          WHEN 'SNOTE'.
            PERFORM SET_AND_EDIT_TEXT USING LS_MAIN_101.
        ENDCASE.

      ENDIF.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_AND_EDIT_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_101
*&---------------------------------------------------------------------*
FORM SET_AND_EDIT_TEXT  USING    PS_MAIN_101 LIKE GS_MAIN_DISP_101.

  DATA : LV_AUFNR TYPE AUFNR.
  DATA : LS_THEAD LIKE THEAD.
  DATA : LT_TLINE LIKE TLINE OCCURS 0 WITH HEADER LINE .
  DATA : LT_TEXT TYPE TABLE OF CHAR255.

  LV_AUFNR = PS_MAIN_101-ORDNR.
  __ALPHA_INPUT LV_AUFNR.

  SELECT SINGLE LTEXT FROM AUFK
    INTO @DATA(LV_LTEXT)
    WHERE AUFNR = @LV_AUFNR.

  IF LV_LTEXT IS NOT INITIAL.
* 생산오더
    LS_THEAD-TDID     = 'KOPF'.
    LS_THEAD-TDSPRAS  = SY-LANGU.
    CONCATENATE SY-MANDT LV_AUFNR INTO LS_THEAD-TDNAME.
    LS_THEAD-TDOBJECT = 'AUFK' .

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        CLIENT                  = SY-MANDT
        ID                      = LS_THEAD-TDID
        LANGUAGE                = LS_THEAD-TDSPRAS
        NAME                    = LS_THEAD-TDNAME
        OBJECT                  = LS_THEAD-TDOBJECT
      TABLES
        LINES                   = LT_TLINE
      EXCEPTIONS
        ID                      = 1
        LANGUAGE                = 2
        NAME                    = 3
        NOT_FOUND               = 4
        OBJECT                  = 5
        REFERENCE_CHECK         = 6
        WRONG_ACCESS_TO_ARCHIVE = 7.

    LOOP AT LT_TLINE INTO DATA(LS_TLINE).
      APPEND INITIAL LINE TO LT_TEXT ASSIGNING FIELD-SYMBOL(<LS_TEXT>).
      <LS_TEXT> = LS_TLINE-TDLINE.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION 'ZGTPP_UTILL_TEXTEDIT'
    EXPORTING
      IV_MODE  = '2'
      IV_TITLE = '특기사항'
    CHANGING
      CT_TEXT  = LT_TEXT.

  IF LT_TEXT IS NOT INITIAL.
    REFRESH LT_TLINE.
    LOOP AT LT_TEXT INTO DATA(LS_TEXT).
      APPEND INITIAL LINE TO LT_TLINE ASSIGNING FIELD-SYMBOL(<LS_TLINE>).
      <LS_TLINE>-TDLINE = LS_TEXT.
    ENDLOOP.
  ENDIF.

  IF LV_LTEXT IS INITIAL.
    UPDATE AUFK SET LTEXT = SY-LANGU
     WHERE AUFNR = LV_AUFNR.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      HEADER          = LS_THEAD
      SAVEMODE_DIRECT = 'X'
    TABLES
      LINES           = LT_TLINE
    EXCEPTIONS
      ID              = 1
      LANGUAGE        = 2
      NAME            = 3
      OBIECT          = 4
      OTHERS          = 5.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_PRD_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELETE_PRD_ORDER .

  DATA : LT_ORDERS TYPE TABLE OF BAPI_ORDER_KEY.
  DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.
  DATA : LS_RETURN TYPE BAPIRET2.
  DATA : LV_SEQ_C(12).

  IF NOT LINE_EXISTS( GT_MAIN_DISP_100[ CHECK = 'X' ] ).
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 오더가 없습니다.'.
    RETURN.
  ENDIF.

  LOOP AT GT_MAIN_DISP_100 INTO GS_MAIN_DISP_100 WHERE CHECK = ABAP_TRUE.
    IF GS_MAIN_DISP_100-GCATG = '생산오더' OR GS_MAIN_DISP_100-GCATG = '분할오더'.
      APPEND INITIAL LINE TO LT_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDERS>).
      <LS_ORDERS>-ORDER_NUMBER = GS_MAIN_DISP_100-ORDNR.
      __ALPHA_INPUT <LS_ORDERS>-ORDER_NUMBER.
    ENDIF.
  ENDLOOP.

  IF LT_ORDERS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '삭제할 수 있는 오더가 없습니다.'.
    RETURN.
  ENDIF.


  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 오더가 삭제 됩니다. 계속 진행 하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
    IMPORTING
      RETURN        = LS_RETURN
    TABLES
      ORDERS        = LT_ORDERS
      DETAIL_RETURN = LT_DETAIL_RETURN.

  IF LS_RETURN-TYPE = 'E'.
    REFRESH GT_DEL_DISP.
    LOOP AT LT_DETAIL_RETURN INTO DATA(LS_DETAIL_RETURN).
      APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING FIELD-SYMBOL(<LS_DEL_DISP>).
      CASE LS_DETAIL_RETURN-TYPE.
        WHEN 'S'.
          <LS_DEL_DISP>-STATUS = ICON_LED_GREEN.
        WHEN 'W'.
          <LS_DEL_DISP>-STATUS = ICON_LED_YELLOW.
        WHEN 'E'.
          <LS_DEL_DISP>-STATUS = ICON_LED_RED.
      ENDCASE.

      <LS_DEL_DISP>-ORDNR = LS_DETAIL_RETURN-ORDER_NUMBER.
      <LS_DEL_DISP>-ORDTY = 'PRD'.
      <LS_DEL_DISP>-MESSAGE = LS_DETAIL_RETURN-MESSAGE.
    ENDLOOP.
    CALL SCREEN '0440' STARTING AT 10 5 ENDING AT 90 9.
  ENDIF.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = ABAP_TRUE.

  WAIT UP TO '0.1' SECONDS.



  LOOP AT LT_ORDERS INTO DATA(LS_ORDERS).
    DELETE GT_ORDSYVAL_PLANED WHERE AUFNR = LS_ORDERS-ORDER_NUMBER.

*    __ALPHA_OUT LS_ORDERS-ORDER_NUMBER.
    DELETE GT_MAIN_DISP_100 WHERE ORDNR = LS_ORDERS-ORDER_NUMBER.
  ENDLOOP.



  PERFORM REFRESH_GRID USING GO_GRID_0100.

  LV_SEQ_C = LINES( LT_ORDERS ).
  CONDENSE LV_SEQ_C.
  MESSAGE S006  WITH '생산오더' LV_SEQ_C '건 삭제되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CRT_ORDERS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_UCOMM
*&---------------------------------------------------------------------*
FORM PROC_CRT_ORDERS  USING    PV_UCOMM.

  DATA : LV_SEQ_C(12).
  DATA : LT_MOSU LIKE GT_MAIN_DISP_100.

  IF PV_UCOMM = 'CRT_ORDER4'.
    CLEAR GS_MAKE_ORDER2.
    LT_MOSU = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP_100 WHERE ( CHECK = ABAP_TRUE
                                                         AND   GCATG = '판매오더' )
                     ( CORRESPONDING #( LW_MAIN ) ) ).

    IF LT_MOSU IS INITIAL.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '분할오더 생성할 수 있는 라인이 없습니다.'(e43).
      RETURN.
    ENDIF.

    IF LINES( LT_MOSU ) > 1.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '분할오더는 1건씩 생성 가능합니다.'(e44).
      RETURN.
    ENDIF.

* 그외 체크사항은 차후 반영예정 현재는 제한이 없음
*
    READ TABLE LT_MOSU INTO DATA(LS_MOSU) INDEX 1.
    GS_MAKE_ORDER2-ORDNO = LS_MOSU-ORDNR.
    GS_MAKE_ORDER2-POSNR = LS_MOSU-POSNR.
    GS_MAKE_ORDER2-MATNR = LS_MOSU-MATNR.
    GS_MAKE_ORDER2-MAKTX = LS_MOSU-MAKTX.
    GS_MAKE_ORDER2-GSTRP = SY-DATUM.
    GS_MAKE_ORDER2-GLTRP = SY-DATUM.
    GS_MAKE_ORDER2-INFACTOR = LS_MOSU-INFACTOR.
    GS_MAKE_ORDER2-INFACTOR2 = 1.
    GS_MAKE_ORDER2-INLENGTH = LS_MOSU-INLENGTH.
    GS_MAKE_ORDER2-GMEIN = 'M'.

    REFRESH GT_TEXT.

    CALL SCREEN '0700' STARTING AT 5 5 ENDING AT 89 19.

  ELSE.
    CLEAR GS_MAKE_ORDER.
    GS_MAKE_ORDER-WERKS = P_WERKS.
    IF P_GONGNM IS INITIAL.
      SELECT SINGLE GONG_NM INTO P_GONGNM
               FROM ZEDT0011
              WHERE GONG_CD EQ P_GONGCD.
      GS_MAKE_ORDER-GONG_NM = P_GONGNM && '(' && P_GONGCD && ')'.
    ELSE.
      GS_MAKE_ORDER-GONG_NM = P_GONGNM && '(' && P_GONGCD && ')'.
    ENDIF.

    GS_MAKE_ORDER-GMEIN = 'M'.
    GS_MAKE_ORDER-INFACTOR = 1.
    GS_MAKE_ORDER-SEQ = 1.
    GS_MAKE_ORDER-GSTRP = SY-DATUM.
    GS_MAKE_ORDER-GLTRP = SY-DATUM.

    CLEAR GV_CHK_CREATE.
    CLEAR GV_CREATE_COMMAND.
    GV_CREATE_COMMAND = PV_UCOMM.

    REFRESH GT_TEXT.

    CALL SCREEN '0400' STARTING AT 5 5 ENDING AT 89 28.
  ENDIF.

  IF GV_CHK_CREATE = 'E'. " 메시지처리후 종료
    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E12.
  ELSEIF GV_CHK_CREATE = 'S'. "리프레쉬루 성공메시지처리
    WAIT UP TO '0.2' SECONDS.
    LV_SEQ_C = GS_MAKE_ORDER-SEQ.
    CONDENSE LV_SEQ_C.
    MESSAGE S006  WITH TEXT-E13 LV_SEQ_C TEXT-E14.
  ENDIF.

  PERFORM GET_MAIN_PROD_ORDER_INFOR.

*    수립가능한 오더 세팅
  PERFORM MAKE_ORDER_INFO.

  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_MATNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_MATNR INPUT.

  DATA : BEGIN OF LS_MATNR,
           MATNR TYPE MATNR,
           MAKTX TYPE MAKTX,
         END OF LS_MATNR.
  DATA : LT_MATNR LIKE TABLE OF LS_MATNR.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  SELECT MATNR MAKTX
     FROM ZGTCVMSTVAL
       INTO CORRESPONDING FIELDS OF TABLE LT_MATNR
     WHERE WERKS = P_WERKS
       AND PDCAPROCCODE = P_GONGCD
       AND SPG = P_SPGCD
       AND MMSTA = SPACE.

  SORT LT_MATNR BY MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING MATNR.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'MATNR'
*     DYNPPROG        = SY-CPROG                 "현재 프로그램명->ZTER0010
*     DYNPNR          = SY-DYNNR                 "현재 화면번호->0100
      DYNPROFIELD     = 'GS_MAKE_ORDER-MATNR'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '자재코드 조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      VALUE_TAB       = LT_MATNR                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT        = LS_RETURN_TAB-FIELDVAL
      IMPORTING
        OUTPUT       = GS_MAKE_ORDER-MATNR
      EXCEPTIONS
        LENGTH_ERROR = 1
        OTHERS       = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE LT_MATNR INTO LS_MATNR WITH KEY MATNR = GS_MAKE_ORDER-MATNR.
    GS_MAKE_ORDER-MAKTX = LS_MATNR-MAKTX.

    IF NOT ( GV_CHK_GO_JOJANG = ABAP_TRUE OR GV_CHK_GO_HALF = ABAP_TRUE ).
* 표준조장가져와서 보여주기. 해당 자재의 만권량.
      PERFORM GET_MATNR_INFOR USING GS_MAKE_ORDER-MATNR CHANGING GS_MAKE_ORDER-INLENGTH.

      CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
        EXPORTING
          FUNCTIONCODE           = 'ENTE'              " Function code
        EXCEPTIONS
          FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
          OTHERS                 = 2.
    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CALCULATE_GAMNG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CALCULATE_GAMNG INPUT.

  CLEAR GS_MAKE_ORDER-GAMNG.
  IF GV_CHK_GO_JOJANG = ABAP_TRUE OR GV_CHK_GO_HALF = ABAP_TRUE OR
     ( P_WERKS = '6600' AND P_SPGCD = 'GL' AND P_GONGCD = 'REW' ).
    GS_MAKE_ORDER-INLENGTH = GS_MAKE_ORDER-INLENGTH2.
  ENDIF.

  GS_MAKE_ORDER-GAMNG = ( GS_MAKE_ORDER-INLENGTH * GS_MAKE_ORDER-INFACTOR ) +
                                          GS_MAKE_ORDER-QLENGTH .

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0400 INPUT.

  CLEAR GV_OK_CODE3.
  GV_OK_CODE3 = SY-UCOMM.

  CASE GV_OK_CODE3.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      GO_CONTAINER_400->FREE( ).
      FREE : GO_CONTAINER_400, GO_TEXT_400.

      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      PERFORM CHECK_AND_CREATE.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form CHECK_AND_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_AND_CREATE .

  DATA : LV_MESSAGE(100).
  DATA : LV_CHK_ERR.
*  필드 빈값 체크
  CLEAR LV_MESSAGE.
  PERFORM SCREEN_400_CHK_INIT CHANGING LV_MESSAGE.
  IF LV_MESSAGE IS NOT INITIAL.
    MESSAGE I003 WITH LV_MESSAGE.
    RETURN.
  ENDIF.

  PERFORM SCREEN_400_CHK_VALIDATION  CHANGING LV_MESSAGE.
  IF LV_MESSAGE IS NOT INITIAL.
    MESSAGE I003 WITH LV_MESSAGE.
    RETURN.
  ENDIF.

  PERFORM CREATE_ORDERS CHANGING LV_CHK_ERR.
  IF LV_CHK_ERR IS NOT INITIAL.
    GV_CHK_CREATE = 'E'. " 실패
  ELSE.
    GV_CHK_CREATE = 'S'. " 성공
  ENDIF.

  GO_CONTAINER_400->FREE( ).
  FREE : GO_CONTAINER_400, GO_TEXT_400.
  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCREEN_400_CHK_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM SCREEN_400_CHK_INIT  CHANGING PV_MESSAGE.

  IF GS_MAKE_ORDER-MATNR IS INITIAL.
    PV_MESSAGE = TEXT-E02.
  ENDIF.

  IF GS_MAKE_ORDER-GAMNG IS INITIAL OR GS_MAKE_ORDER-GAMNG = 0.
    PV_MESSAGE = TEXT-E03.
  ENDIF.


  IF GS_MAKE_ORDER-GSTRP IS INITIAL OR GS_MAKE_ORDER-GSTRP = '00000000'.
    PV_MESSAGE = TEXT-E04.
  ENDIF.

  IF GS_MAKE_ORDER-GLTRP IS INITIAL OR GS_MAKE_ORDER-GLTRP = '00000000'.
    PV_MESSAGE = TEXT-E05.
  ENDIF.

  IF GV_CHK_GO_JOJANG = ABAP_TRUE OR GV_CHK_GO_HALF = ABAP_TRUE OR
          ( P_WERKS = '6600' AND P_SPGCD = 'GL' AND P_GONGCD = 'REW' ).
    IF GS_MAKE_ORDER-INLENGTH NE GS_MAKE_ORDER-INLENGTH2.
      GS_MAKE_ORDER-INLENGTH = GS_MAKE_ORDER-INLENGTH2.
    ENDIF.
  ENDIF.

  IF GS_MAKE_ORDER-INLENGTH IS INITIAL OR GS_MAKE_ORDER-INLENGTH = 0.
    PV_MESSAGE = TEXT-E06.
  ENDIF.

  IF GS_MAKE_ORDER-INFACTOR IS INITIAL OR GS_MAKE_ORDER-INFACTOR = 0.
    PV_MESSAGE = TEXT-E07.
  ENDIF.

  IF GS_MAKE_ORDER-SEQ IS INITIAL OR GS_MAKE_ORDER-SEQ = 0.
    PV_MESSAGE = TEXT-E08.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCREEN_400_CHK_VALIDATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM SCREEN_400_CHK_VALIDATION  CHANGING PV_MESSAGE.

  DATA LV_TOTAL TYPE GAMNG.

* 생산자재
  SELECT * FROM ZGTCVMSTVAL
       INTO TABLE @DATA(LT_MATNR)
     WHERE WERKS = @P_WERKS
       AND PDCAPROCCODE = @P_GONGCD
       AND MATNR = @GS_MAKE_ORDER-MATNR
       AND MMSTA = @SPACE.
  IF SY-SUBRC NE 0.
    PV_MESSAGE = TEXT-E09.
    RETURN.
  ENDIF.

  LV_TOTAL = ( GS_MAKE_ORDER-INLENGTH * GS_MAKE_ORDER-INFACTOR ).
  IF LV_TOTAL > GS_MAKE_ORDER-GAMNG.
    PV_MESSAGE = TEXT-E10.
    RETURN.
  ENDIF.

  IF GS_MAKE_ORDER-GSTRP > GS_MAKE_ORDER-GLTRP.
    PV_MESSAGE = TEXT-E11.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ORDERS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CREATE_ORDERS  CHANGING PV_CHK_ERR.

  DATA : LT_PRD_ORDERS TYPE TB_BAPI_ORDER_KEY.
  DATA : LS_ORDER TYPE BAPI_PP_ORDER_CREATE.
  DATA: LS_RETURN TYPE BAPIRET2.
  DATA : LV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.
  DATA: LT_TLINE LIKE TABLE OF TLINE.

  CALL METHOD GO_TEXT_400->GET_TEXT_AS_R3TABLE( EXPORTING ONLY_WHEN_MODIFIED = ' ' IMPORTING TABLE = GT_TEXT ).

  LOOP AT GT_TEXT INTO DATA(LS_TEXT).
    APPEND INITIAL LINE TO LT_TLINE ASSIGNING FIELD-SYMBOL(<LS_TLINE>).
    <LS_TLINE>-TDLINE = LS_TEXT.
  ENDLOOP.


  DO GS_MAKE_ORDER-SEQ TIMES.
    CLEAR : LS_ORDER, LS_RETURN, LV_ORDER_NUMBER.
*  오더 생성
    LS_ORDER-MATERIAL = GS_MAKE_ORDER-MATNR.
    LS_ORDER-PLANT = P_WERKS.
    CASE GV_CREATE_COMMAND.
      WHEN 'CRT_ORDER1'.
        LS_ORDER-ORDER_TYPE = 'PP01'.
      WHEN 'CRT_ORDER2'.
        LS_ORDER-ORDER_TYPE = 'PL01'.
      WHEN 'CRT_ORDER3'.
        LS_ORDER-ORDER_TYPE = 'RP01'.
    ENDCASE.

    LS_ORDER-BASIC_START_DATE = GS_MAKE_ORDER-GSTRP.
    LS_ORDER-BASIC_END_DATE = GS_MAKE_ORDER-GLTRP.
    LS_ORDER-QUANTITY = GS_MAKE_ORDER-GAMNG.
    LS_ORDER-BASIC_SCHEDULING_TYPE = '3'.

    CALL FUNCTION 'BAPI_PRODORD_CREATE'
      EXPORTING
        ORDERDATA    = LS_ORDER
      IMPORTING
        RETURN       = LS_RETURN
        ORDER_NUMBER = LV_ORDER_NUMBER.

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
          WAIT UP TO '0.5' SECONDS.
        ENDIF.
      ENDDO.

      PERFORM CHANG_BDC_JOJANG USING LV_ORDER_NUMBER PV_CHK_ERR.
      IF PV_CHK_ERR = ABAP_TRUE.
        PERFORM ROLLBACK_ORDES TABLES LT_PRD_ORDERS.
        RETURN.
      ENDIF.

      APPEND INITIAL LINE TO LT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDER>).
      <LS_ORDER>-ORDER_NUMBER =  LV_ORDER_NUMBER.
    ELSE.
      PERFORM ROLLBACK_ORDES TABLES LT_PRD_ORDERS.
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

  ENDDO.

* 오더 생산메모 입력
  IF LT_TLINE[] IS NOT INITIAL.
    PERFORM SAVE_TEXT_ORDER TABLES LT_PRD_ORDERS LT_TLINE.
  ENDIF.

  DATA : LT_ZPPTC002 TYPE TABLE OF ZPPTC002.
  LOOP AT LT_PRD_ORDERS INTO DATA(LS_PRD_ORDERS).
    APPEND INITIAL LINE TO LT_ZPPTC002 ASSIGNING FIELD-SYMBOL(<LS_SAVE_DATA>).
    <LS_SAVE_DATA>-AUFNR = LS_PRD_ORDERS-ORDER_NUMBER.
    <LS_SAVE_DATA>-POSNR = '0001'.
    <LS_SAVE_DATA>-PSAMG = GS_MAKE_ORDER-QLENGTH.
  ENDLOOP.

  IF LT_ZPPTC002[] IS NOT INITIAL.
    MODIFY ZPPTC002 FROM TABLE LT_ZPPTC002.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANG_BDC_JOJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ORDER_NUMBER
*&      --> PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHANG_BDC_JOJANG  USING   PV_AUFNR
                                                 PV_CHK_ERR.

  DATA : LV_INLENGTH TYPE I.
  DATA : LV_INLENGTH_C(10) TYPE C.
  DATA : LV_INFACTOR TYPE I.
  DATA : LV_INFACTOR_C(10) TYPE C.
  DATA : LV_TEST01 TYPE CABNT-ATBEZ.
  DATA : LV_TEST02 TYPE CABNT-ATBEZ.
  DATA : LV_TEST03 TYPE CABNT-ATBEZ.

  SELECT A~ATNAM, B~ATBEZ
    FROM CABN AS A
    INNER JOIN CABNT AS B ON B~ATINN = A~ATINN
  WHERE A~ATNAM IN ( 'SAP_MILLCA_LENGTH', 'SAP_MILLCA_FACTOR', 'PD_CA_PROC_NAME' )
    AND B~SPRAS = @SY-LANGU
   INTO TABLE @DATA(LT_CHAR_NAME).

  LOOP AT LT_CHAR_NAME INTO DATA(LS_CHAR_NAME).
    CASE LS_CHAR_NAME-ATNAM.
      WHEN 'SAP_MILLCA_LENGTH'.
        LV_TEST01 = LS_CHAR_NAME-ATBEZ.
      WHEN 'SAP_MILLCA_FACTOR'.
        LV_TEST02 = LS_CHAR_NAME-ATBEZ.
      WHEN 'PD_CA_PROC_NAME'.
        LV_TEST03 = LS_CHAR_NAME-ATBEZ.
    ENDCASE.
  ENDLOOP.


  REFRESH : GT_BDCDATA, GT_MESSTAB.

  LV_INLENGTH = GS_MAKE_ORDER-INLENGTH.
  LV_INLENGTH_C = LV_INLENGTH.
  CONDENSE LV_INLENGTH_C.

  LV_INFACTOR = GS_MAKE_ORDER-INFACTOR.
  LV_INFACTOR_C = LV_INFACTOR.
  CONDENSE LV_INFACTOR_C.

  __SETTING_BDC_PARAMS.

  __BDC_DYNPRO 'SAPLCOKO1' '0110'.
  __BDC_FIELD : 'CAUFVD-AUFNR' PV_AUFNR,
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
  __BDC_FIELD : 'RCTMS-MNAME(01)' LV_TEST01,
                      'RCTMS-MNAME(02)' LV_TEST02,
                      'RCTMS-MNAME(03)' LV_TEST03,
                      'RCTMS-MWERT(01)' LV_INLENGTH_C,
                      'RCTMS-MWERT(02)' LV_INFACTOR_C,
                      'RCTMS-MWERT(03)' P_GONGCD,
                      'BDC_OKCODE' '=BACK'.


  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD : 'BDC_OKCODE' '=BU'.

  __BDC_TRANSACTION 'CO02'.
  LOOP AT GT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'A'
                                                         OR MSGTYP = 'E'
                                                         OR MSGTYP = 'X'.
    PV_CHK_ERR = 'E'.
    RETURN.
  ENDLOOP.

  COMMIT WORK AND  WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ROLLBACK_ORDES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_PRD_ORDERS
*&---------------------------------------------------------------------*
FORM ROLLBACK_ORDES  TABLES   PT_PRD_ORDERS STRUCTURE BAPI_ORDER_KEY.

  DATA : LS_RETURN2 TYPE BAPIRET2.
  DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.

  CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
    IMPORTING
      RETURN        = LS_RETURN2
    TABLES
      ORDERS        = PT_PRD_ORDERS[]
      DETAIL_RETURN = LT_DETAIL_RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_TEXT_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_PRD_ORDERS
*&      --> LT_TLINE
*&---------------------------------------------------------------------*
FORM SAVE_TEXT_ORDER  TABLES   PT_PRD_ORDERS TYPE TB_BAPI_ORDER_KEY
                               PT_TLINE STRUCTURE TLINE.

  DATA: LS_THEAD LIKE THEAD.

  LOOP AT PT_PRD_ORDERS.
    UPDATE AUFK SET LTEXT = SY-LANGU
     WHERE AUFNR = PT_PRD_ORDERS-ORDER_NUMBER.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.

    CLEAR LS_THEAD.
* 생산오더
    LS_THEAD-TDID     = 'KOPF'.
    LS_THEAD-TDSPRAS  = SY-LANGU.
    CONCATENATE SY-MANDT PT_PRD_ORDERS-ORDER_NUMBER INTO LS_THEAD-TDNAME.
    LS_THEAD-TDOBJECT = 'AUFK' .

    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        HEADER          = LS_THEAD
        SAVEMODE_DIRECT = 'X'
      TABLES
        LINES           = PT_TLINE[]
      EXCEPTIONS
        ID              = 1
        LANGUAGE        = 2
        NAME            = 3
        OBIECT          = 4
        OTHERS          = 5.

  ENDLOOP.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MATNR_INFOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAKE_ORDER_MATNR
*&      <-- GS_MAKE_ORDER_INLENGTH
*&---------------------------------------------------------------------*
FORM GET_MATNR_INFOR  USING    PV_MATNR TYPE MATNR
                      CHANGING PV_INLENGTH .

  DATA : LS_TOPMAT TYPE CSTMAT.
  DATA : LT_STB TYPE TABLE OF STPOX.
  DATA : LT_CSCMAT TYPE TABLE OF CSCMAT.

  SELECT SINGLE /SAPMP/MAX_FERTL FROM ZGTCVROUTING
     WHERE WERKS = @P_WERKS
       AND MATNR = @PV_MATNR
       AND FLGAT = '0' "대표설비
    INTO @DATA(LV_INLENGTH).

  IF SY-SUBRC EQ 0 AND LV_INLENGTH NE 0.
    PV_INLENGTH = LV_INLENGTH.
    RETURN.
  ENDIF.

* 외주공정의 경우 표준만권량이 존재하지 않으므로
*  이전 공정중 외주공정이 아닌 자재가 있을경우 그자재의 만권량으로 표현해준다.
* BOM 하위전개
  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      AUMGB                 = ABAP_ON
      CAPID                 = 'PP01'
      DATUV                 = SY-DATUM
      EHNDL                 = '1'
      MKTLS                 = ABAP_ON
      MEHRS                 = ABAP_ON
      MMORY                 = '1'
      MTNRV                 = PV_MATNR
      WERKS                 = P_WERKS
    IMPORTING
      TOPMAT                = LS_TOPMAT
    TABLES
      STB                   = LT_STB
      MATCAT                = LT_CSCMAT
    EXCEPTIONS
      ALT_NOT_FOUND         = 1
      CALL_INVALID          = 2
      MATERIAL_NOT_FOUND    = 3
      MISSING_AUTHORIZATION = 4
      NO_BOM_FOUND          = 5
      NO_PLANT_DATA         = 6
      NO_SUITABLE_BOM_FOUND = 7
      CONVERSION_ERROR      = 8
      OTHERS                = 9.

  IF LT_CSCMAT[] IS NOT INITIAL.
    SELECT A~INDEX AS SEQNO, A~MATNR, B~MTART
      FROM @LT_CSCMAT AS A
      INNER JOIN MARA AS B
                            ON B~MATNR = A~MATNR
      INNER JOIN MARC AS C
                            ON C~MATNR = A~MATNR
                          AND C~WERKS = @P_WERKS
     WHERE B~MTART   IN ( 'MCFE', 'MCHF' )  " 완제품 반제품만 공정대상
       AND ( A~INDEX EQ 1
        OR ( A~INDEX NE 1
       AND  A~VERID IS NOT INITIAL ) )
      INTO TABLE @DATA(LT_SEQ_ROUTING).
  ENDIF.

  SORT LT_SEQ_ROUTING BY SEQNO.

  IF LT_SEQ_ROUTING[] IS NOT INITIAL.
    SELECT * FROM ZGTCVMSTVAL
       FOR ALL ENTRIES IN @LT_SEQ_ROUTING
      WHERE WERKS = @P_WERKS
      AND MATNR = @LT_SEQ_ROUTING-MATNR
      INTO TABLE @DATA(LT_MATNR_DETAIL).
  ENDIF.

  LOOP AT LT_SEQ_ROUTING INTO DATA(LS_SEQ_ROUTING).
    READ TABLE LT_MATNR_DETAIL INTO DATA(LS_MATNR_DETAIL) WITH KEY MATNR = LS_SEQ_ROUTING-MATNR.
    IF SY-SUBRC EQ 0.
      CASE LS_MATNR_DETAIL-BESKZ.
        WHEN 'E' OR 'X'.
          CLEAR LV_INLENGTH.
          SELECT SINGLE /SAPMP/MAX_FERTL FROM ZGTCVROUTING
             WHERE WERKS = @P_WERKS
               AND MATNR = @LS_SEQ_ROUTING-MATNR
               AND FLGAT = '0' "대표설비
            INTO @LV_INLENGTH.

          IF SY-SUBRC EQ 0 AND LV_INLENGTH NE 0.
            PV_INLENGTH = LV_INLENGTH.
            RETURN.
          ENDIF.

      ENDCASE.
    ENDIF.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GO_TEXT_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GO_TEXT_400 .

  CREATE OBJECT GO_CONTAINER_400
    EXPORTING
      CONTAINER_NAME = 'CONTAINER400'.

  CREATE OBJECT GO_TEXT_400
    EXPORTING
      WORDWRAP_MODE          = 2
      MAX_NUMBER_CHARS       = 255                         " maximum number of characters insertable into editor control
      PARENT                 = GO_CONTAINER_400                        " Parent Container
    EXCEPTIONS
      ERROR_CNTL_CREATE      = 1                        " Error while performing creation of TextEdit control!
      ERROR_CNTL_INIT        = 2                        " Error while initializing TextEdit control!
      ERROR_CNTL_LINK        = 3                        " Error while linking TextEdit control!
      ERROR_DP_CREATE        = 4                        " Error while creating DataProvider control!
      GUI_TYPE_NOT_SUPPORTED = 5                        " This type of GUI is not supported!
      OTHERS                 = 6.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GO_TEXT_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GO_TEXT_400 .

  GO_TEXT_400->SET_TOOLBAR_MODE( EXPORTING TOOLBAR_MODE = 0 ).

  GO_TEXT_400->SET_STATUSBAR_MODE( EXPORTING STATUSBAR_MODE = 0 ).

  GO_TEXT_400->SET_READONLY_MODE( EXPORTING READONLY_MODE = 0 ).

  GO_TEXT_400->SET_TEXT_AS_R3TABLE( EXPORTING TABLE = GT_TEXT ).

  CALL METHOD CL_GUI_CFW=>FLUSH
    EXCEPTIONS
      OTHERS = 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_CHECK_LINE_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_CHECK_LINE_0101 .

  DATA : LT_CELLS TYPE LVC_T_CENO.

  GO_GRID_0101->GET_SELECTED_CELLS_ID(
    IMPORTING
     ET_CELLS = LT_CELLS ).                " Cell IDs

  SORT LT_CELLS BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CELLS COMPARING ROW_ID.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_MAIN_DISP_101 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0 AND <LS_MAIN>-GOBUN NE 0.
      <LS_MAIN>-CHECK = ABAP_TRUE.
    ENDIF.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0101.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DECHECK_LINE_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_DECHECK_LINE_0101 .

  DATA : LT_CELLS TYPE LVC_T_CENO.

  GO_GRID_0101->GET_SELECTED_CELLS_ID(
    IMPORTING
     ET_CELLS = LT_CELLS ).                " Cell IDs

  SORT LT_CELLS BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CELLS COMPARING ROW_ID.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_MAIN_DISP_101 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0 AND <LS_MAIN>-GOBUN NE 0.
      CLEAR <LS_MAIN>-CHECK.
    ENDIF.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0101.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RELEASE_PRD_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RELEASE_PRD_ORDER .

  DATA : LT_MAIN LIKE GT_MAIN_DISP_101.
  DATA : LT_ORDERS TYPE TABLE OF BAPI_ORDER_KEY.
  DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.
  DATA : LS_RETURN TYPE BAPIRET2.
  DATA : LV_SEQ_C(12).

* 선택대상이 있는지 확인
  LT_MAIN = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP_101 WHERE ( CHECK = ABAP_TRUE
                                                                                   AND  ORD_STAT = '생성' )
                            ( CORRESPONDING #( LW_MAIN ) ) ).
  IF LT_MAIN[] IS INITIAL.
    MESSAGE S005 DISPLAY LIKE 'E' WITH '릴리즈할 오더를 선택해 주세요.'(e20).
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '릴리즈 진행합니다. 계속 진행 하시겠습니까?'
    '작업확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LOOP AT LT_MAIN INTO DATA(LS_MAIN).
    APPEND INITIAL LINE TO LT_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDERS>).
    <LS_ORDERS>-ORDER_NUMBER = LS_MAIN-ORDNR.
    __ALPHA_INPUT <LS_ORDERS>-ORDER_NUMBER.
  ENDLOOP.
  SORT LT_ORDERS BY ORDER_NUMBER.
  DELETE ADJACENT DUPLICATES FROM LT_ORDERS COMPARING ORDER_NUMBER.

  CALL FUNCTION 'BAPI_PRODORD_RELEASE'
    TABLES
      ORDERS        = LT_ORDERS
      DETAIL_RETURN = LT_DETAIL_RETURN.

  IF LS_RETURN-TYPE = 'E'.
    REFRESH GT_DEL_DISP.
    LOOP AT LT_DETAIL_RETURN INTO DATA(LS_DETAIL_RETURN).
      APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING FIELD-SYMBOL(<LS_DEL_DISP>).
      CASE LS_DETAIL_RETURN-TYPE.
        WHEN 'S'.
          <LS_DEL_DISP>-STATUS = ICON_LED_GREEN.
        WHEN 'W'.
          <LS_DEL_DISP>-STATUS = ICON_LED_YELLOW.
        WHEN 'E'.
          <LS_DEL_DISP>-STATUS = ICON_LED_RED.
      ENDCASE.

      <LS_DEL_DISP>-ORDNR = LS_DETAIL_RETURN-ORDER_NUMBER.
      <LS_DEL_DISP>-ORDTY = 'PRD'.
      <LS_DEL_DISP>-MESSAGE = LS_DETAIL_RETURN-MESSAGE.
    ENDLOOP.
    CALL SCREEN '0440' STARTING AT 10 5 ENDING AT 90 9.
  ENDIF.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = ABAP_TRUE.

  CALL FUNCTION 'MESSAGES_INITIALIZE'.
  CALL FUNCTION 'CO_IH_BUFFER_REFRESH'.
  CALL FUNCTION 'BAPI_PS_INITIALIZATION'.

  WAIT UP TO '0.5' SECONDS.

*  MTO 멀티오더 의 경우 조장구성표에 적용된 판매오더 번호 재적용
  PERFORM SET_MTO TABLES LT_ORDERS.

  LOOP AT LT_ORDERS INTO DATA(LS_ORDERS).
    DELETE GT_ORDSYVAL_PLANED WHERE AUFNR = LS_ORDERS-ORDER_NUMBER.
  ENDLOOP.

  SELECT * FROM ZGTCVORDSYVAL
    APPENDING TABLE GT_ORDSYVAL_PLANED
      FOR ALL ENTRIES IN LT_ORDERS
    WHERE WERKS = P_WERKS
      AND AUFNR = LT_ORDERS-ORDER_NUMBER.

*    해당 설비별 순번별 수립된 데이터 세팅
  REFRESH GT_MAKE_PLAN.
  PERFORM MAKE_PLAN_DATA TABLES GT_ORDSYVAL_PLANED.
*    해당 설비별 순번별 일자별 수립된 작업 시간 관리
  REFRESH GT_WORKTIME_DAY.
  PERFORM SET_CRT_TIME_DAY.

*    선댁된 일자로 설비별 순번별 수립된 데이터 세팅
  REFRESH GT_MAIN_DISP_101.
  PERFORM MAKE_PLAN_DISP_DATA TABLES GT_ORDSYVAL_PLANED.

  PERFORM REFRESH_GRID USING GO_GRID_0101.

  LV_SEQ_C = LINES( LT_MAIN ).
  CONDENSE LV_SEQ_C.
  MESSAGE S006 WITH '선택오더' LV_SEQ_C '건 릴리즈되었습니다'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MTO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ORDERS
*&---------------------------------------------------------------------*
FORM SET_MTO  TABLES   PT_ORDERS STRUCTURE BAPI_ORDER_KEY.

  DATA : LT_ORDERS TYPE TABLE OF BAPI_ORDER_KEY.
  MOVE-CORRESPONDING PT_ORDERS[] TO LT_ORDERS.

  SELECT DISTINCT A~*
    FROM ZGTPPT2010 AS A
    INNER JOIN @LT_ORDERS AS B ON B~ORDER_NUMBER = A~ORDNR
    INNER JOIN AUFK AS C ON C~AUFNR = B~ORDER_NUMBER
   WHERE A~ORDTY = 'PRD'
     AND A~DMORDTY = 'SO'
     AND C~FLG_MLTPS = 'X'
    INTO TABLE @DATA(LT_2010).

  LOOP AT LT_2010 INTO DATA(LS_2010).
    UPDATE AFPO SET KDAUF = LS_2010-DMORD
                      KDPOS = LS_2010-DMLINE
                      SOBKZ = 'E'
                      KZBWS = 'A'
              WHERE AUFNR = LS_2010-ORDNR
                  AND POSNR = LS_2010-POSNR+2(4).
  ENDLOOP.
  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0440
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0440 .


  CREATE OBJECT GO_CONTAIN_0440
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

  CREATE OBJECT GO_GRID_0440
    EXPORTING
      I_PARENT      = GO_CONTAIN_0440
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0440
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0440 .

  CLEAR GS_LAYOUT_0440.
  GS_LAYOUT_0440-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0440-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0440-NO_ROWMARK   = 'X'.
  GS_LAYOUT_0440-SEL_MODE   = 'C'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0440
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0440 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2280TOP'
      I_INTERNAL_TABNAME     = 'GS_DEL_DISP'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0440[]
    TABLES
      IT_DATA         = GT_DEL_DISP
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0440 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '상태'.
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ORDNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ORDTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더 타입'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '결과 메세지'.
        <LS_FCAT>-JUST = 'L'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0440
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0440 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0440
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0440_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0440_DISPLAY .

  CALL METHOD GO_GRID_0440->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0440
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0440
    CHANGING
      IT_OUTTAB            = GT_DEL_DISP
      IT_FIELDCATALOG      = GT_FIELDCAT_0440.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_REGISTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_REGISTER .

  DATA : LV_WEEKEND_DT TYPE SY-DATUM.
  DATA : LV_WEEKEND_DT2 TYPE SY-DATUM.
  DATA : LT_WORKING LIKE GT_ORDER_DAY_WORKING.
  DATA : LV_AVAILABLE_TIME TYPE ZGTPPT2400-ZWKLTH.
  DATA : LV_PLAN_TIME TYPE ZGTPPT2400-ZWKLTH.
  DATA : LT_MAIN LIKE GT_MAIN_DISP_100.
  DATA : LV_LAST_INDEX TYPE I.
  DATA : LV_INDEX TYPE I.
  DATA : LV_WKCHH TYPE ZGTPPT2400-ZWKCHH.
  DATA : LV_ZWKLTH TYPE ZGTPPT2400-ZWKLTH.
  DATA : LV_CAL_TIME TYPE ZGTPPT2400-ZWKLTH.
  DATA : LV_MENGE_IN TYPE EKPO-MENGE.
  DATA : LV_MENGE_OUT TYPE EKPO-MENGE.
  DATA : LV_MENGE TYPE EKPO-MENGE.
  DATA : LV_AUFNR TYPE AUFNR.
  DATA : LV_PLNUM TYPE PLNUM.
  DATA : LV_POSNR TYPE AFPO-POSNR.
  DATA : BEGIN OF LS_CHG_AUFNR_INFOR,
           AUFNR      TYPE AUFNR,
           PLNUM      TYPE PLNUM,
           GSTRP      TYPE AFKO-GSTRP,
           GSUZP      TYPE AFKO-GSUZP,
           GLTRP      TYPE AFKO-GLTRP,
           GLUZP      TYPE AFKO-GLUZP,
           INLENGTH   LIKE ZGTPPT2340-INLENGTH,
           INFACTOR   LIKE ZGTPPT2340-INFACTOR,
           ZZPRIORITY TYPE AUFK-ZZPRIORITY,
           MATNR      TYPE MATNR,
         END OF LS_CHG_AUFNR_INFOR.

  DATA : BEGIN OF LS_BEFORE_ORDER_INFOR,
           AUFNR      TYPE AUFNR,
           GSTRP      TYPE AFKO-GSTRP,
           GSUZP      TYPE AFKO-GSUZP,
           GLTRP      TYPE AFKO-GLTRP,
           GLUZP      TYPE AFKO-GLUZP,
           ZZPRIORITY TYPE AUFK-ZZPRIORITY,
           MATNR      TYPE MATNR,
         END OF  LS_BEFORE_ORDER_INFOR.

  DATA : LT_CHG_AUFNR_INFOR LIKE TABLE OF LS_CHG_AUFNR_INFOR.
  DATA : LT_CRT_AUFNR_INFOR LIKE TABLE OF LS_CHG_AUFNR_INFOR.
  DATA : LV_MAX_ZZPRIORITY TYPE AUFK-ZZPRIORITY.
  DATA : LV_HOURS(2) TYPE N.
  DATA : LV_MINUTE(2) TYPE N.
  DATA : LT_SAVE_2390 TYPE TABLE OF ZGTPPT2390.
  DATA : LV_CHK_ERR.
  DATA : LV_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.
  DATA : LS_ORDERDATA TYPE BAPI_PP_ORDER_CHANGE.
  DATA : LS_ORDERDATAX TYPE BAPI_PP_ORDER_CHANGEX.
  DATA : LS_RETURN TYPE BAPIRET2.
  DATA : LT_PRD_ORDERS TYPE TB_BAPI_ORDER_KEY. " 생성 오류시 롤백처리용
  DATA : LS_ORDER TYPE BAPI_PP_ORDER_CREATE.
  DATA : LT_2330_CHG TYPE TABLE OF ZGTPPT2330.
  DATA : LT_2340_CHG TYPE TABLE OF ZGTPPT2340.
  DATA : LS_2340 TYPE ZGTPPT2340.
  DATA : LT_PLAN_ORDERS TYPE MRPDS_PLONO. " 삭제용
  DATA : LT_PLAN_ORDERS_ROLLBACK TYPE MRPDS_PLONO." 오류시 삭제용
  DATA : LV_MATNR_CHK TYPE MATNR.
  DATA : LV_MESSAGE(100).
  DATA : LV_GSMNG TYPE GSMNG.
  DATA : LV_GSMNG_C(30).
  DATA : LV_CAL_GSMNG TYPE GSMNG.
  DATA : LV_CHK_INFACTOR TYPE ZGTPPT2330-INFACTOR.
  DATA : LV_ORDNR TYPE ZGTPPT2340-ORDNR.

  LV_WEEKEND_DT = P_WEEKTO - 1.
  LV_WEEKEND_DT2 = P_WEEKTO.

* 가용설비정보 확인
  IF GV_SELECTED_ARBPL IS INITIAL.
    MESSAGE S005 DISPLAY LIKE 'E' WITH '일정 등록할 설비를 설정해 주세요.'(e01).
    RETURN.
  ENDIF.

* 가용일자 확인
  IF GV_CHK_SKIP IS INITIAL.
    LV_WEEKEND_DT = P_WEEKTO - 1.
    CASE GV_SELECTED_DAY.
      WHEN LV_WEEKEND_DT OR P_WEEKTO.
        MESSAGE S005 DISPLAY LIKE 'E' WITH '수립가능한 일자가 선택되지 않았습니다.'(e15).
        RETURN.
    ENDCASE.
  ENDIF.

* 가용일자 확인(현재일보다 과거일경우 수립할수 없음)
  IF GV_SELECTED_DAY < SY-DATUM.
    MESSAGE S005 DISPLAY LIKE 'E' WITH '과거 일자로 작업 계획 할 수 없습니다. 선택 일자를 확인해 주세요.'(e29).
    RETURN.
  ENDIF.


* 선택대상이 있는지 확인
  LT_MAIN = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP_100 WHERE ( CHECK = ABAP_TRUE )
                            ( CORRESPONDING #( LW_MAIN ) ) ).
  IF LT_MAIN[] IS INITIAL.
    MESSAGE S005 DISPLAY LIKE 'E' WITH '일정 등록할 생산요청을 선택해 주세요.'(e17).
    RETURN.
  ENDIF.

  LOOP AT LT_MAIN INTO DATA(LS_CHK_MAIN) WHERE GCATG = '계획오더'.
    IF LS_CHK_MAIN-MENGE = 0.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '계획오더(' LS_CHK_MAIN-GRPNR ')의 수립B/N이 입력되지 않았습니다.'(e22).
      RETURN.
    ELSEIF LS_CHK_MAIN-INLENGTH2 = 0 AND GV_CHK_GO_HALF = ABAP_TRUE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '계획오더(' LS_CHK_MAIN-GRPNR ')의 수립조장이 입력되지 않았습니다.'(e32).
      RETURN.
    ELSE.
      IF GV_CHK_GO_HALF = ABAP_TRUE.

        CLEAR LV_PLNUM.
        LV_PLNUM = LS_CHK_MAIN-ORDNR.
        __ALPHA_INPUT LV_PLNUM.

        SELECT SINGLE GSMNG FROM PLAF
          INTO @DATA(LV_BDMNG)
         WHERE PLNUM = @LV_PLNUM.

        CLEAR LV_GSMNG.
        LV_GSMNG = LS_CHK_MAIN-INLENGTH2 * LS_CHK_MAIN-MENGE.
        IF LV_BDMNG < LV_GSMNG.
          LV_GSMNG_C = LV_BDMNG.
          CONCATENATE '계획오더(' LS_CHK_MAIN-GRPNR ')의 계획량' LV_GSMNG_C '보다 클수 없습니다.' INTO LV_MESSAGE SEPARATED BY SPACE.

          MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MESSAGE.
          RETURN.
        ENDIF.
      ELSE.
        CLEAR LV_CHK_INFACTOR.
        LV_CHK_INFACTOR = LS_CHK_MAIN-MENGE + LS_CHK_MAIN-MENGE02.
        IF LV_CHK_INFACTOR > LS_CHK_MAIN-INFACTOR.
          MESSAGE S006 DISPLAY LIKE 'E' WITH '계획오더(' LS_CHK_MAIN-GRPNR ')의 수립B/N이 생산계획B/N 초과합니다.'(e23).
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.


  CLEAR LV_MAX_ZZPRIORITY.
* 해당일자의 설비에 가용 시간이 존재하는지 확인
  READ TABLE GT_WORKTIME_DAY INTO GS_WORKTIME_DAY WITH KEY DATE = GV_SELECTED_DAY
                                                                                        ARBPL = GV_SELECTED_ARBPL.
  IF SY-SUBRC EQ 0.
    REFRESH LT_WORKING.
    LT_WORKING = GS_WORKTIME_DAY-T_ORDNRS.
    SORT LT_WORKING BY SEQNO DESCENDING.
    READ TABLE LT_WORKING INTO DATA(LS_WORKING) INDEX 1.
    IF SY-SUBRC EQ 0.
*     현재 테이블 적용된 오더의 생성시간 정보 들고 오기
      CLEAR : LS_BEFORE_ORDER_INFOR.
      READ TABLE GT_MAKE_PLAN INTO GS_MAKE_PLAN WITH KEY ORDNR = LS_WORKING-ORDNR.
      IF SY-SUBRC EQ 0.
        MOVE-CORRESPONDING GS_MAKE_PLAN TO LS_BEFORE_ORDER_INFOR.
        LS_BEFORE_ORDER_INFOR-AUFNR = GS_MAKE_PLAN-ORDNR.

        LV_MAX_ZZPRIORITY = GS_MAKE_PLAN-ZZPRIORITY.
        IF GS_MAKE_PLAN-GLTRP > GV_SELECTED_DAY.
          LV_AVAILABLE_TIME = 0.
        ELSE.
          LV_AVAILABLE_TIME = 24 - GS_WORKTIME_DAY-CURRENT_TIME.
        ENDIF.
      ENDIF.
    ELSE.
      LV_AVAILABLE_TIME = 24.
    ENDIF.
  ELSE.
    LV_AVAILABLE_TIME = 24.
  ENDIF.

  IF LV_AVAILABLE_TIME <= 0.
    MESSAGE S005 DISPLAY LIKE 'E' WITH '설비 가용시간이 없습니다.'(e16).
    RETURN.
  ENDIF.

  READ TABLE GT_ARBPL INTO DATA(LS_ARBPL) WITH KEY  ARBPL = GV_SELECTED_ARBPL.

  IF GV_CHK_CHG_101 = ABAP_TRUE.
    CLEAR GV_ANSWER.
    PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
      ' '
      '변경된 일정 정보가 있습니다. 저장 없이 진행 하시겠습니까?'
      '변경확인'.
    IF GV_ANSWER NE 'J'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
      RETURN.
    ENDIF.

    REFRESH GT_ORDSYVAL_CHG.
    CLEAR GV_CHK_CHG_101.
  ENDIF.

  LV_LAST_INDEX = LINES( LT_MAIN ).

  LOOP AT LT_MAIN INTO DATA(LS_MAIN).

    CLEAR LV_PLAN_TIME.
    CLEAR LS_CHG_AUFNR_INFOR.
    ADD 1 TO LV_INDEX.

    READ TABLE GT_ROUTING INTO DATA(LS_ROUTING) WITH KEY MATNR = LS_MAIN-MATNR
                                                                                   ARBPL = GV_SELECTED_ARBPL.
    IF SY-SUBRC NE 0.
      LV_MATNR_CHK = LS_MAIN-MATNR.
      __ALPHA_OUT LV_MATNR_CHK.
      LV_MESSAGE = |는 설비({ GV_SELECTED_ARBPL })에 표준 작업시간이 없습니다.|.

      MESSAGE S006 DISPLAY LIKE 'E' WITH '자재' LV_MATNR_CHK LV_MESSAGE.
      RETURN.
    ENDIF.

*    변경할 정보 세팅
    CLEAR LS_CHG_AUFNR_INFOR.

    IF LS_BEFORE_ORDER_INFOR IS NOT INITIAL.
      LS_CHG_AUFNR_INFOR-GSTRP = LS_BEFORE_ORDER_INFOR-GLTRP.
      LS_CHG_AUFNR_INFOR-GSUZP = LS_BEFORE_ORDER_INFOR-GLUZP.
      LS_CHG_AUFNR_INFOR-GLTRP = LS_BEFORE_ORDER_INFOR-GLTRP.
      LS_CHG_AUFNR_INFOR-GLUZP = LS_BEFORE_ORDER_INFOR-GLUZP.
    ELSE.
      LS_CHG_AUFNR_INFOR-GSTRP = GV_SELECTED_DAY.
      LS_CHG_AUFNR_INFOR-GSUZP = '000000'.
      LS_CHG_AUFNR_INFOR-GLTRP = GV_SELECTED_DAY.
      LS_CHG_AUFNR_INFOR-GLUZP = '240000'.
    ENDIF.
    ADD 1 TO LV_MAX_ZZPRIORITY.
    LS_CHG_AUFNR_INFOR-ZZPRIORITY = LV_MAX_ZZPRIORITY.
    LS_CHG_AUFNR_INFOR-MATNR = LS_MAIN-MATNR.

    IF LS_MAIN-GCATG = '계획오더'.
      CLEAR LV_PLNUM.
      LV_PLNUM = LS_MAIN-ORDNR.
      __ALPHA_INPUT LV_PLNUM.

      LS_CHG_AUFNR_INFOR-PLNUM = LV_PLNUM.
      IF GV_CHK_GO_HALF = ABAP_TRUE.
        LS_CHG_AUFNR_INFOR-INLENGTH = LS_MAIN-INLENGTH2.
      ELSE.
        LS_CHG_AUFNR_INFOR-INLENGTH = LS_MAIN-INLENGTH.
      ENDIF.
      LS_CHG_AUFNR_INFOR-INFACTOR = LS_MAIN-MENGE.
      LV_ORDNR = LV_PLNUM.
    ELSE.
      CLEAR LV_AUFNR.
      READ TABLE GT_2340 INTO DATA(LS_2340_CHK) WITH KEY ZWKREQ = LS_MAIN-ZWKREQ.
      IF SY-SUBRC EQ 0.
        CLEAR LV_AUFNR.
        LV_AUFNR = LS_2340_CHK-ORDNR.
      ELSE.
        LV_AUFNR = LS_MAIN-ORDNR.
      ENDIF.

      __ALPHA_INPUT LV_AUFNR.
      LS_CHG_AUFNR_INFOR-AUFNR = LV_AUFNR.
      LV_ORDNR = LV_AUFNR.
    ENDIF.

    LV_POSNR = LS_MAIN-POSNR + 0.

*    IF LS_MAIN-GCATG = '생산오더'.
    READ TABLE GT_ORDSYVAL INTO DATA(LS_ORDSYVAL) WITH KEY AUFNR = LV_AUFNR
                                                                                    POSNR = LV_POSNR.
*    ENDIF.
*    대기시간, 작업시간 계산후 더해준다.
*    prodchg(시간)
    CLEAR LV_WKCHH.
    IF LS_ROUTING-VGW01 NE 0.
      CLEAR : LV_MENGE_IN, LV_MENGE_OUT.
      LV_MENGE_IN = LS_ROUTING-VGW01.
      CASE LS_ROUTING-VGE01.
        WHEN 'MIN'.
          LV_MENGE_OUT = LS_ROUTING-VGW01 / 60.
        WHEN 'H'.
          LV_MENGE_OUT = LS_ROUTING-VGW01.
        WHEN 'D' OR '10'.
          LV_MENGE_OUT = LS_ROUTING-VGW01 * 24.
      ENDCASE.
      LV_WKCHH = LV_MENGE_OUT / LS_ARBPL-EQUCD_CNT.
    ENDIF.
* 최초 세팅시 작업 교체시간은 0으로 세팅 차후 변경적용
    LV_WKCHH = 0.

* LeadTime(시간)
    CLEAR LV_ZWKLTH.
    CLEAR : LV_MENGE_IN, LV_MENGE_OUT.
    IF P_WERKS = '6600' AND P_SPGCD = 'GL' AND P_GONGCD = 'PAR'. " 전주 랜 대연 공정은 기게 작업시간이 아닌 노무 시간으로 시간 적용

      IF LS_ROUTING-VGW06 NE 0.
        CASE LS_ROUTING-VGE06.
          WHEN 'MIN'.
            LV_MENGE_OUT = LS_ROUTING-BMSCH * ( 60 / LS_ROUTING-VGW06 ).
          WHEN 'H'.
            LV_MENGE_OUT = LS_ROUTING-BMSCH / LS_ROUTING-VGW06 .
          WHEN 'D' OR '10'.
            LV_MENGE_OUT = LS_ROUTING-BMSCH / ( LS_ROUTING-VGW06 * 24 ).
        ENDCASE.
      ELSE.
        IF LS_ROUTING-VGW02 NE 0.
          CASE LS_ROUTING-VGE02.
            WHEN 'MIN'.
              LV_MENGE_OUT = LS_ROUTING-BMSCH * ( 60 / LS_ROUTING-VGW02 ).
            WHEN 'H'.
              LV_MENGE_OUT = LS_ROUTING-BMSCH / LS_ROUTING-VGW02 .
            WHEN 'D' OR '10'.
              LV_MENGE_OUT = LS_ROUTING-BMSCH / ( LS_ROUTING-VGW02 * 24 ).
          ENDCASE.
        ENDIF.
      ENDIF.
    ELSE.
      IF LS_ROUTING-VGW02 NE 0.
        CASE LS_ROUTING-VGE02.
          WHEN 'MIN'.
            LV_MENGE_OUT = LS_ROUTING-BMSCH * ( 60 / LS_ROUTING-VGW02 ).
          WHEN 'H'.
            LV_MENGE_OUT = LS_ROUTING-BMSCH / LS_ROUTING-VGW02 .
          WHEN 'D' OR '10'.
            LV_MENGE_OUT = LS_ROUTING-BMSCH / ( LS_ROUTING-VGW02 * 24 ).
        ENDCASE.
      ENDIF.
    ENDIF.

    IF LV_MENGE_OUT NE 0.

      IF LS_MAIN-GCATG = '생산오더'.
        LV_MENGE_OUT = ( LS_ORDSYVAL-PSAMG + LS_ORDSYVAL-PSMNG ) / LV_MENGE_OUT.
      ELSEIF LS_MAIN-GCATG = '계획오더'.
        CLEAR LV_MENGE.
        IF GV_CHK_GO_HALF = ABAP_TRUE.
          LV_MENGE = LS_MAIN-MENGE * ( LS_MAIN-INLENGTH2 + LS_MAIN-CLENGTH + LS_MAIN-QLENGTH ).
        ELSE.
          LV_MENGE = LS_MAIN-MENGE * LS_MAIN-INLENGTH.
        ENDIF.
        LV_MENGE_OUT =  LV_MENGE / LV_MENGE_OUT.
      ELSE.
        LV_MENGE_OUT = ( LS_ORDSYVAL-PSAMG + LS_ORDSYVAL-PSMNG ) / LV_MENGE_OUT.
      ENDIF.

    ENDIF.

    LV_ZWKLTH = LV_MENGE_OUT / LS_ARBPL-EQUCD_CNT.

    LV_PLAN_TIME = LV_PLAN_TIME + LV_WKCHH + LV_ZWKLTH.

* 종료시간 세팅
    LV_CAL_TIME = 24 - LV_AVAILABLE_TIME + LV_PLAN_TIME.
    DO.
      IF LV_CAL_TIME > 24.
        LS_CHG_AUFNR_INFOR-GLTRP = LS_CHG_AUFNR_INFOR-GLTRP + 1.

        PERFORM CHECK_EXIST_ORDER USING  LS_CHG_AUFNR_INFOR-GLTRP CHANGING LV_CHK_ERR.
        IF LV_CHK_ERR = ABAP_TRUE.
          MESSAGE S006 DISPLAY LIKE 'E' WITH LS_CHG_AUFNR_INFOR-GLTRP '에 수립된 작업지시가 있어 일정 수립 할 수 없습니다.'(e24).
          RETURN.
        ENDIF.

        IF GV_CHK_SKIP IS INITIAL.
          CASE LS_CHG_AUFNR_INFOR-GLTRP.
            WHEN LV_WEEKEND_DT.
              APPEND INITIAL LINE TO LT_SAVE_2390 ASSIGNING FIELD-SYMBOL(<LS_SAVE_2390>).
              <LS_SAVE_2390>-AUFNR = LV_ORDNR.
              <LS_SAVE_2390>-POSNR = LS_MAIN-POSNR.
              <LS_SAVE_2390>-SKDAT = LV_WEEKEND_DT.
              APPEND INITIAL LINE TO LT_SAVE_2390 ASSIGNING <LS_SAVE_2390>.
              <LS_SAVE_2390>-AUFNR = LV_ORDNR.
              <LS_SAVE_2390>-POSNR = LS_MAIN-POSNR.
              <LS_SAVE_2390>-SKDAT = LV_WEEKEND_DT2.

              LS_CHG_AUFNR_INFOR-GLTRP = LS_CHG_AUFNR_INFOR-GLTRP + 2.
              LV_WEEKEND_DT = LV_WEEKEND_DT + 7.
              LV_WEEKEND_DT2 = LV_WEEKEND_DT2 + 7.

            WHEN  LV_WEEKEND_DT2.
              APPEND INITIAL LINE TO LT_SAVE_2390 ASSIGNING <LS_SAVE_2390>.
              <LS_SAVE_2390>-AUFNR = LV_ORDNR.
              <LS_SAVE_2390>-POSNR = LS_MAIN-POSNR.
              <LS_SAVE_2390>-SKDAT = LV_WEEKEND_DT2.

              LS_CHG_AUFNR_INFOR-GLTRP = LS_CHG_AUFNR_INFOR-GLTRP + 1.
              LV_WEEKEND_DT = LV_WEEKEND_DT + 7.
              LV_WEEKEND_DT2 = LV_WEEKEND_DT2 + 7.
          ENDCASE.
        ENDIF.

        LV_CAL_TIME = LV_CAL_TIME - 24.
      ELSE.
        LV_HOURS = TRUNC( LV_CAL_TIME ).
        LV_MINUTE = FRAC( LV_CAL_TIME ) * 60.
        LS_CHG_AUFNR_INFOR-GLUZP = LV_HOURS && LV_MINUTE && '00'.
        EXIT.
      ENDIF.
    ENDDO.


    LV_AVAILABLE_TIME = 24 - LV_CAL_TIME.

    CLEAR LS_BEFORE_ORDER_INFOR.
    MOVE-CORRESPONDING LS_CHG_AUFNR_INFOR TO LS_BEFORE_ORDER_INFOR.

    IF LV_AVAILABLE_TIME = 0.
      LS_BEFORE_ORDER_INFOR-GLTRP = LS_BEFORE_ORDER_INFOR-GLTRP + 1.
      LS_BEFORE_ORDER_INFOR-GLUZP = '00000000'.
    ENDIF.

    IF LV_AVAILABLE_TIME <= 0.
      LV_AVAILABLE_TIME = 24 + LV_AVAILABLE_TIME.
    ENDIF.

    IF LS_MAIN-GCATG = '계획오더'.
      APPEND LS_CHG_AUFNR_INFOR TO LT_CRT_AUFNR_INFOR.
    ELSE.
      APPEND LS_CHG_AUFNR_INFOR TO LT_CHG_AUFNR_INFOR.
    ENDIF.

  ENDLOOP.

  IF LT_CHG_AUFNR_INFOR IS INITIAL AND LT_CRT_AUFNR_INFOR IS INITIAL.
    RETURN.
  ENDIF.


*&---------------------------------------------------------------------*
* 생산오더  생성
*&---------------------------------------------------------------------*
  LOOP AT LT_CRT_AUFNR_INFOR ASSIGNING FIELD-SYMBOL(<LS_CHG_AUFNR_INFOR>).

    CLEAR : LS_ORDER, LS_RETURN, LV_NUMBER.
*  오더 생성
    LS_ORDER-MATERIAL = <LS_CHG_AUFNR_INFOR>-MATNR.
    LS_ORDER-PLANT = P_WERKS.
    LS_ORDER-ORDER_TYPE = 'PP01'.
    LS_ORDER-BASIC_START_DATE = <LS_CHG_AUFNR_INFOR>-GSTRP.
    LS_ORDER-BASIC_START_TIME = <LS_CHG_AUFNR_INFOR>-GSUZP.
    LS_ORDER-BASIC_END_DATE = <LS_CHG_AUFNR_INFOR>-GLTRP.
    LS_ORDER-BASIC_END_TIME = <LS_CHG_AUFNR_INFOR>-GLUZP.
    IF GV_CHK_GO_HALF = ABAP_TRUE.
      READ TABLE GT_2330 INTO DATA(LS_LC_CHK) WITH KEY PLNUM = <LS_CHG_AUFNR_INFOR>-PLNUM.
      IF SY-SUBRC EQ 0.
        LS_ORDER-QUANTITY = ( <LS_CHG_AUFNR_INFOR>-INLENGTH + LS_LC_CHK-CLENGTH + LS_LC_CHK-QLENGTH )
                                         * <LS_CHG_AUFNR_INFOR>-INFACTOR.
      ELSE.
        CLEAR LV_PLNUM.
        LV_PLNUM = <LS_CHG_AUFNR_INFOR>-PLNUM.
        __ALPHA_OUT LV_PLNUM.
        READ TABLE LT_MAIN INTO LS_MAIN WITH KEY GRPNR = LV_PLNUM
                                                              GCATG = '계획오더'.
        IF SY-SUBRC EQ 0.
          LS_ORDER-QUANTITY = ( <LS_CHG_AUFNR_INFOR>-INLENGTH + LS_MAIN-CLENGTH + LS_MAIN-QLENGTH )
                                          * <LS_CHG_AUFNR_INFOR>-INFACTOR.
        ENDIF.
      ENDIF.

    ELSE.
      LS_ORDER-QUANTITY = <LS_CHG_AUFNR_INFOR>-INLENGTH * <LS_CHG_AUFNR_INFOR>-INFACTOR.
    ENDIF.
    LS_ORDER-BASIC_SCHEDULING_TYPE = '7'.
* 일반 BOM구성 자재인지 탄뎀 구성자재인지 대체 BOM대상 인지 확인
    IF GV_SELECTED_ARBPL IN GT_TANDEM_ARBPL.
      LS_ORDER-EXPLOSION_DATE = SY-DATUM.
      LS_ORDER-PROD_VERSION = 'TD10'.
    ELSE.
      READ TABLE GT_REPLACE_ARBPL INTO DATA(LS_REPLACE_ARBPL) WITH KEY FLD_03 = GV_SELECTED_ARBPL.
      IF SY-SUBRC EQ 0.
        LS_ORDER-EXPLOSION_DATE = SY-DATUM.
        LS_ORDER-PROD_VERSION = LS_REPLACE_ARBPL-FLD_04.
      ENDIF.
    ENDIF.

    CALL FUNCTION 'BAPI_PRODORD_CREATE'
      EXPORTING
        ORDERDATA    = LS_ORDER
      IMPORTING
        RETURN       = LS_RETURN
        ORDER_NUMBER = LV_NUMBER.

    IF LS_RETURN-TYPE NE 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

*      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
      DO .
        SELECT SINGLE AUFNR, POSNR
          FROM AFPO
         WHERE AUFNR = @LV_NUMBER
          INTO @DATA(LS_AFPO).
        IF SY-SUBRC EQ 0.
          EXIT.
        ELSE.
          WAIT UP TO '0.5' SECONDS.
        ENDIF.
      ENDDO.

      UPDATE AUFK SET ZZPRIORITY = <LS_CHG_AUFNR_INFOR>-ZZPRIORITY
        WHERE AUFNR = LV_NUMBER.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.

      IF LS_ORDER-PROD_VERSION = 'TD10'.
        UPDATE AUFK SET ZZTANDEM = ABAP_TRUE
          WHERE AUFNR = LV_NUMBER.
        IF SY-SUBRC EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDIF.

      CLEAR GS_MAKE_ORDER.
      GS_MAKE_ORDER-INLENGTH = <LS_CHG_AUFNR_INFOR>-INLENGTH.
      GS_MAKE_ORDER-INFACTOR = <LS_CHG_AUFNR_INFOR>-INFACTOR.

      PERFORM CHANG_BDC_JOJANG USING LV_NUMBER LV_CHK_ERR.
      IF LV_CHK_ERR = ABAP_TRUE.
        PERFORM ROLLBACK_ORDES TABLES LT_PRD_ORDERS.
        RETURN.
      ENDIF.

* 생성 완료건에 대한 변경 처리
      <LS_CHG_AUFNR_INFOR>-AUFNR = LV_NUMBER.
      LOOP AT LT_SAVE_2390 ASSIGNING <LS_SAVE_2390> WHERE AUFNR = <LS_CHG_AUFNR_INFOR>-PLNUM.
        <LS_SAVE_2390>-AUFNR = LV_NUMBER.
      ENDLOOP.

      APPEND INITIAL LINE TO LT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDER>).
      <LS_ORDER>-ORDER_NUMBER =  LV_NUMBER.
    ELSE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH TEXT-E21 <LS_CHG_AUFNR_INFOR>-PLNUM TEXT-E19.
      PERFORM ROLLBACK_ORDES TABLES LT_PRD_ORDERS.
      RETURN.
    ENDIF.

  ENDLOOP.

  IF LT_CRT_AUFNR_INFOR IS NOT INITIAL.
    WAIT UP TO 1 SECONDS.
  ENDIF.

* 일정변경후 설비 등록
  LOOP AT LT_CRT_AUFNR_INFOR INTO LS_CHG_AUFNR_INFOR.
    PERFORM BDC_CHG_BATCH USING LS_CHG_AUFNR_INFOR-AUFNR GV_SELECTED_ARBPL LS_CHG_AUFNR_INFOR-MATNR
                                    CHANGING LV_CHK_ERR.
    IF LV_CHK_ERR IS NOT INITIAL.
      MESSAGE S006 DISPLAY LIKE 'E' WITH TEXT-E21 LS_CHG_AUFNR_INFOR-PLNUM TEXT-E19.
      RETURN.
    ENDIF.
  ENDLOOP.

* 생산오더 생선 완료후 랜 조장구성표에 작업지시 업데이트
  LOOP AT LT_CRT_AUFNR_INFOR INTO LS_CHG_AUFNR_INFOR.
    READ TABLE GT_2330 INTO DATA(LS_2330) WITH KEY PLNUM = LS_CHG_AUFNR_INFOR-PLNUM.
    IF SY-SUBRC EQ 0.
      CLEAR LS_2340.
      LS_2340-WERKS = P_WERKS.
      LS_2340-SPGCD = P_SPGCD.
      LS_2340-RQMON = P_SPMON.
      LS_2340-GONG_CD = LS_2330-GONG_CD.
      LS_2340-ZWKREQ = LS_2330-ZWKREQ.
      LS_2340-MATNR = LS_2330-MATNR.
      LS_2340-ORDNR = LS_CHG_AUFNR_INFOR-AUFNR.
      LS_2340-POSNR = 1.
      LS_2340-ORDTY = 'PRD'.
      LS_2340-INLENGTH = LS_CHG_AUFNR_INFOR-INLENGTH.
      LS_2340-INFACTOR = LS_CHG_AUFNR_INFOR-INFACTOR.
      LS_2340-QLENGTH = LS_2330-QLENGTH.
      LS_2340-CLENGTH = LS_2330-CLENGTH.
      LS_2340-GONG_SEQ = LS_2330-GONG_SEQ.
      APPEND LS_2340 TO LT_2340_CHG.

      IF LS_2330-PLNUM IS NOT INITIAL.
        APPEND LS_2330-PLNUM TO LT_PLAN_ORDERS.
        CLEAR LS_2330-PLNUM.
      ENDIF.

      CLEAR LV_CAL_GSMNG.
      LOOP AT GT_2340 INTO LS_2340_CHK WHERE ZWKREQ = LS_2330-ZWKREQ.
        LV_CAL_GSMNG = LV_CAL_GSMNG + ( LS_2340_CHK-INLENGTH * LS_2340_CHK-INFACTOR ).
      ENDLOOP.

      CLEAR LV_GSMNG.
      LV_GSMNG = LS_CHG_AUFNR_INFOR-INLENGTH * LS_CHG_AUFNR_INFOR-INFACTOR.
      ADD LV_GSMNG TO LV_CAL_GSMNG.
      IF LS_2330-GSMNG <= LV_CAL_GSMNG.
        APPEND LS_2330 TO LT_2330_CHG.
      ELSE.
        CLEAR LV_GSMNG.
        LV_GSMNG = LS_2330-GSMNG - LV_CAL_GSMNG.

        PERFORM MAKE_PLAN_ORDER CHANGING LS_2330 LV_GSMNG LV_CHK_ERR.

        IF LV_CHK_ERR = ABAP_TRUE.
          CLEAR LV_MESSAGE.
          CONCATENATE '공정코드' LS_2330-GONG_CD '의 반제품 자재' LS_2330-MATNR '계획오더 생성 중 오류가 발생했습니다.'
                      INTO LV_MESSAGE SEPARATED BY SPACE.
          MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MESSAGE.
          PERFORM ROLLBACK_PLAN_ORDER USING LT_PLAN_ORDERS_ROLLBACK.
          RETURN.
        ENDIF.
        APPEND LS_2330-PLNUM TO LT_PLAN_ORDERS_ROLLBACK.
      ENDIF.
      APPEND LS_2330 TO LT_2330_CHG.
    ENDIF.
  ENDLOOP.

  IF LT_PLAN_ORDERS[] IS NOT INITIAL.
    PERFORM ROLLBACK_PLAN_ORDER USING LT_PLAN_ORDERS.
  ENDIF.

*&---------------------------------------------------------------------*
* 생산오더 변경
*&---------------------------------------------------------------------*

* 일정변경
  LOOP AT LT_CHG_AUFNR_INFOR INTO LS_CHG_AUFNR_INFOR.
    LV_NUMBER = LS_CHG_AUFNR_INFOR-AUFNR.

    UPDATE AUFK SET ZZPRIORITY = LS_CHG_AUFNR_INFOR-ZZPRIORITY
      WHERE AUFNR = LV_NUMBER.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.

    CLEAR LS_ORDERDATA.
    CLEAR LS_ORDERDATAX.
    CLEAR LS_RETURN.

    LS_ORDERDATA-BASIC_START_DATE = LS_CHG_AUFNR_INFOR-GSTRP.
    LS_ORDERDATA-BASIC_START_TIME = LS_CHG_AUFNR_INFOR-GSUZP.
    LS_ORDERDATA-BASIC_END_DATE = LS_CHG_AUFNR_INFOR-GLTRP.
    LS_ORDERDATA-BASIC_END_TIME = LS_CHG_AUFNR_INFOR-GLUZP.
    LS_ORDERDATA-BASIC_SCHEDULING_TYPE = '7'.
    LS_ORDERDATAX-BASIC_START_DATE = 'X'.
    LS_ORDERDATAX-BASIC_END_DATE = 'X'.
    LS_ORDERDATAX-BASIC_SCHEDULING_TYPE = 'X'.

* 일반 BOM구성 자재인지 탄뎀 구성자재인지 대체 BOM대상 인지 확인
    IF GV_SELECTED_ARBPL IN GT_TANDEM_ARBPL.
      LS_ORDERDATA-EXPLOSION_DATE = SY-DATUM.
      LS_ORDERDATA-PROD_VERSION = 'TD10'.
      LS_ORDERDATAX-EXPLOSION_DATE = ABAP_TRUE.
      LS_ORDERDATAX-PROD_VERSION = ABAP_TRUE.

      UPDATE AUFK SET ZZTANDEM = ABAP_TRUE
        WHERE AUFNR = LV_NUMBER.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.

    ELSE.
      READ TABLE GT_REPLACE_ARBPL INTO LS_REPLACE_ARBPL WITH KEY FLD_03 = GV_SELECTED_ARBPL.
      IF SY-SUBRC EQ 0.
        LS_ORDERDATA-EXPLOSION_DATE = SY-DATUM.
        LS_ORDERDATA-PROD_VERSION = LS_REPLACE_ARBPL-FLD_04.
        LS_ORDERDATAX-EXPLOSION_DATE = ABAP_TRUE.
        LS_ORDERDATAX-PROD_VERSION = ABAP_TRUE.
      ENDIF.
    ENDIF.

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

    ELSE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH TEXT-E13 LV_NUMBER TEXT-E19.
      RETURN.
    ENDIF.

  ENDLOOP.

  IF LT_CHG_AUFNR_INFOR IS NOT INITIAL.
    WAIT UP TO 1 SECONDS.
  ENDIF.

* 일정변경후 설비 등록
  LOOP AT LT_CHG_AUFNR_INFOR INTO LS_CHG_AUFNR_INFOR.
    PERFORM BDC_CHG_BATCH USING LS_CHG_AUFNR_INFOR-AUFNR GV_SELECTED_ARBPL LS_CHG_AUFNR_INFOR-MATNR
                                    CHANGING LV_CHK_ERR.
    IF LV_CHK_ERR IS NOT INITIAL.
      MESSAGE S006 DISPLAY LIKE 'E' WITH TEXT-E13 LV_NUMBER TEXT-E19.
      RETURN.
    ENDIF.
  ENDLOOP.

*&---------------------------------------------------------------------*
* 작업 지시 완료 후 테이블 저장 및 화면 리프레쉬
  IF LT_SAVE_2390[] IS NOT INITIAL.
    MODIFY ZGTPPT2390 FROM TABLE LT_SAVE_2390.
  ENDIF.

  IF LT_2340_CHG IS NOT INITIAL.
    MODIFY ZGTPPT2340 FROM TABLE LT_2340_CHG.
  ENDIF.

  IF LT_2330_CHG IS NOT INITIAL.
    MODIFY ZGTPPT2330 FROM TABLE LT_2330_CHG.
  ENDIF.

  COMMIT WORK AND WAIT.

* 화면 초기화
  PERFORM GET_MAIN_PROD_ORDER_INFOR.

*    수립가능한 오더 세팅
  PERFORM MAKE_ORDER_INFO.
*    해당 설비별 순번별 수립된 데이터 세팅
  REFRESH GT_MAKE_PLAN.
  PERFORM MAKE_PLAN_DATA TABLES GT_ORDSYVAL_PLANED.
*    해당 설비별 순번별 일자별 수립된 작업 시간 관리
  REFRESH GT_WORKTIME_DAY.
  PERFORM SET_CRT_TIME_DAY.
  PERFORM RESET_ARBPL_MAIN.
*    선댁된 일자로 설비별 순번별 수립된 데이터 세팅
  REFRESH GT_MAIN_DISP_101.
  PERFORM MAKE_PLAN_DISP_DATA TABLES GT_ORDSYVAL_PLANED.

  PERFORM SET_TOTAL_DISP_TABLE.

**    선댁된 일자로 설비별 순번별 수립된 데이터 세팅
*  REFRESH GT_MAIN_DISP_101.
*  PERFORM MAKE_PLAN_DISP_DATA TABLES GT_ORDSYVAL_PLANED.
*
*  PERFORM SET_TOTAL_DISP_TABLE.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  PERFORM REFRESH_GRID USING GO_GRID_0101.

  DATA : LV_SEQNO_C(10).
  LV_SEQNO_C = LINES( LT_MAIN ).
  CONDENSE LV_SEQNO_C.
  MESSAGE S006 WITH '선택오더' LV_SEQNO_C '건 일정 등록되었습니다'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_CHG_BATCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_CHG_AUFNR_INFOR_AUFNR
*&      --> GV_SELECTED_ARBPL
*&      --> LS_CHG_AUFNR_INFOR_MATNR
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM BDC_CHG_BATCH  USING     PV_AUFNR TYPE AUFNR
                             PV_ARBPL TYPE ARBPL
                             PV_MATNR TYPE MATNR
                    CHANGING PV_CHK_ERR.

  DATA : LV_ORDER_NUMBER TYPE AUFNR.
  DATA : LT_OPERATION  TYPE COSE_T_OPERATION.
  DATA : LS_RESULT TYPE BAPIRET2.

  SELECT SINGLE A~ARBPL, B~BMSCH, B~VGW01, B~VGE01, B~VGW02, B~VGE02,
                     B~VGW03, B~VGE03, B~VGW04, B~VGE04 ,
                     B~VGW05, B~VGE05, B~VGW06, B~VGE06
    FROM MAPL AS M
    INNER JOIN PLPO AS B
                           ON B~PLNNR = M~PLNNR
                          AND B~PLNTY = M~PLNTY
    INNER JOIN CRHD AS A
                          ON A~OBJID = B~ARBID
    WHERE M~MATNR = @PV_MATNR
         AND M~WERKS = @P_WERKS
         AND M~PLNTY = 'N'
         AND A~OBJTY = 'A'
         AND A~ARBPL = @PV_ARBPL
        INTO @DATA(LS_SET_BATCH).

  CHECK SY-SUBRC EQ 0.

  LV_ORDER_NUMBER = PV_AUFNR.
  APPEND INITIAL LINE TO LT_OPERATION ASSIGNING FIELD-SYMBOL(<LS_OPERATION>).
  <LS_OPERATION>-OPERATION = '0010'.
* 설비
  <LS_OPERATION>-WORK_CENTER = PV_ARBPL.
  <LS_OPERATION>-WORK_CENTER_X = 'X'.
* 설비명
  READ TABLE GT_ARBPL INTO DATA(LS_ARBPL) WITH KEY ARBPL = PV_ARBPL.
  IF SY-SUBRC EQ 0.
    <LS_OPERATION>-SHORT_TEXT = LS_ARBPL-KTEXT.
    <LS_OPERATION>-SHORT_TEXT_X = 'X'.
  ENDIF.
* 기준수량
  <LS_OPERATION>-BASE_QUANTITY = LS_SET_BATCH-BMSCH.
  <LS_OPERATION>-BASE_QUANTITY_X = 'X'.
* 가동준비
  <LS_OPERATION>-STANDARD_VALUE_01 = LS_SET_BATCH-VGW01.
  <LS_OPERATION>-STANDARD_VALUE_01_UNIT = LS_SET_BATCH-VGE01.
  <LS_OPERATION>-STANDARD_VALUE_01_X = 'X'.
  <LS_OPERATION>-STANDARD_VALUE_01_UNIT_X = 'X'.
* 기계
  <LS_OPERATION>-STANDARD_VALUE_02 = LS_SET_BATCH-VGW02.
  <LS_OPERATION>-STANDARD_VALUE_02_UNIT = LS_SET_BATCH-VGE02.
  <LS_OPERATION>-STANDARD_VALUE_02_X = 'X'.
  <LS_OPERATION>-STANDARD_VALUE_02_UNIT_X = 'X'.
* 제조지원
  <LS_OPERATION>-STANDARD_VALUE_03 = LS_SET_BATCH-VGW03.
  <LS_OPERATION>-STANDARD_VALUE_03_UNIT = LS_SET_BATCH-VGE03.
  <LS_OPERATION>-STANDARD_VALUE_03_X = 'X'.
  <LS_OPERATION>-STANDARD_VALUE_03_UNIT_X = 'X'.
* 제조직접
  <LS_OPERATION>-STANDARD_VALUE_04 = LS_SET_BATCH-VGW04.
  <LS_OPERATION>-STANDARD_VALUE_04_UNIT = LS_SET_BATCH-VGE04.
  <LS_OPERATION>-STANDARD_VALUE_04_X = 'X'.
  <LS_OPERATION>-STANDARD_VALUE_04_UNIT_X = 'X'.
* 배부간접
  <LS_OPERATION>-STANDARD_VALUE_05 = LS_SET_BATCH-VGW05.
  <LS_OPERATION>-STANDARD_VALUE_05_UNIT = LS_SET_BATCH-VGE05.
  <LS_OPERATION>-STANDARD_VALUE_05_X = 'X'.
  <LS_OPERATION>-STANDARD_VALUE_05_UNIT_X = 'X'.
* 노무
  <LS_OPERATION>-STANDARD_VALUE_06 = LS_SET_BATCH-VGW06.
  <LS_OPERATION>-STANDARD_VALUE_06_UNIT = LS_SET_BATCH-VGE06.
  <LS_OPERATION>-STANDARD_VALUE_06_X = 'X'.
  <LS_OPERATION>-STANDARD_VALUE_06_UNIT_X = 'X'.


  CALL FUNCTION 'CO_SE_PRODORD_CHANGE'
    EXPORTING
      IV_ORDER_NUMBER = LV_ORDER_NUMBER
      IT_OPERATION    = LT_OPERATION
      IV_COMMIT       = 'X'
    IMPORTING
      ES_RETURN       = LS_RESULT.

  IF LS_RESULT-TYPE NE ' '.
    PV_CHK_ERR = ABAP_TRUE.
  ENDIF.

  WAIT UP TO '0.1' SECONDS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_POPUP_SMORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_100_ORDNR
*&      --> LS_MAIN_100_POSNR
*&---------------------------------------------------------------------*
FORM DISP_POPUP_SMORDER  USING    PV_ORDNO TYPE ZGTPPT2001-ORDNO
                                  PV_POSNR TYPE ZGTPPT2001-POSNR.

  CLEAR GS_MAKE_ORDER2.
  SELECT SINGLE ORDNO, POSNR, MATNR, GAMNG, MEINS AS GMEIN, GSTRP, GLTRP,
               INLENGTH, INFACTOR, ZPMAT AS COV_MATNR, ZZPRIORITY, SNOTE
    INTO CORRESPONDING FIELDS OF @GS_MAKE_ORDER2
    FROM ZGTPPT2001
   WHERE ORDNO = @PV_ORDNO
      AND POSNR = @PV_POSNR.

  IF SY-SUBRC NE 0.
    RETURN.
  ENDIF.

  REFRESH GT_TEXT.
  SPLIT GS_MAKE_ORDER2-SNOTE AT CL_ABAP_CHAR_UTILITIES=>NEWLINE INTO TABLE GT_TEXT.

  CALL SCREEN '0300' STARTING AT 5 5 ENDING AT 83 19.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GO_TEXT_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GO_TEXT_300 .

  CREATE OBJECT GO_CONTAINER_300
    EXPORTING
      CONTAINER_NAME = 'CONTAINER_300'.

  CREATE OBJECT GO_TEXT_300
    EXPORTING
      WORDWRAP_MODE          = 2
      MAX_NUMBER_CHARS       = 255                         " maximum number of characters insertable into editor control
      PARENT                 = GO_CONTAINER_300                        " Parent Container
    EXCEPTIONS
      ERROR_CNTL_CREATE      = 1                        " Error while performing creation of TextEdit control!
      ERROR_CNTL_INIT        = 2                        " Error while initializing TextEdit control!
      ERROR_CNTL_LINK        = 3                        " Error while linking TextEdit control!
      ERROR_DP_CREATE        = 4                        " Error while creating DataProvider control!
      GUI_TYPE_NOT_SUPPORTED = 5                        " This type of GUI is not supported!
      OTHERS                 = 6.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GO_TEXT_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GO_TEXT_300 .

  GO_TEXT_300->SET_TOOLBAR_MODE( EXPORTING TOOLBAR_MODE = 0 ).

  GO_TEXT_300->SET_STATUSBAR_MODE( EXPORTING STATUSBAR_MODE = 0 ).

  GO_TEXT_300->SET_READONLY_MODE( EXPORTING READONLY_MODE = 1 ).

  GO_TEXT_300->SET_TEXT_AS_R3TABLE( EXPORTING TABLE = GT_TEXT ).

  CALL METHOD CL_GUI_CFW=>FLUSH
    EXCEPTIONS
      OTHERS = 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CANCEL_WORKING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CANCEL_WORKING .

  DATA : LT_MAIN LIKE GT_MAIN_DISP_101.
  DATA : LT_MAIN_SORT LIKE GT_MAIN_DISP_101.
  DATA : LS_ORDERDATA TYPE BAPI_PP_ORDER_CHANGE.
  DATA : LS_ORDERDATAX TYPE BAPI_PP_ORDER_CHANGEX.
  DATA : LS_RETURN TYPE BAPIRET2.
  DATA : LT_ORDERS TYPE TABLE OF BAPI_ORDER_KEY.
  DATA : LT_DEL_ORDERS TYPE TABLE OF BAPI_ORDER_KEY.
  DATA : LV_SEQ_C(12).
  DATA : LV_AUFNR TYPE AUFNR.
  DATA : LV_ZZPRIORITY TYPE AUFK-ZZPRIORITY.
  DATA : LV_CHK_ERR.
  DATA : LT_CHG_2330 TYPE TABLE OF ZGTPPT2330.
  DATA : LV_GSMNG TYPE GSMNG.
  DATA : LV_CAL_GSMNG TYPE GSMNG.
  DATA : LT_PLAN_ORDERS TYPE MRPDS_PLONO. " 삭제용
  DATA : LT_PLAN_ORDERS_ROLLBACK TYPE MRPDS_PLONO." 오류시 삭제용
  DATA : LV_MESSAGE TYPE CHAR100.
  DATA : LT_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : LT_2010_SO TYPE TABLE OF ZGTPPT2010.
  DATA : LT_GUIDE_TEXT TYPE TCHAR255.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.

* 바피 object
  DATA : LS_RETURN_2 TYPE COXT_BAPIRETURN,
         LV_ERROR    TYPE FLAG.

* 선택대상이 있는지 확인
  LT_MAIN = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP_101 WHERE ( CHECK = ABAP_TRUE )
                            ( CORRESPONDING #( LW_MAIN ) ) ).
  IF LT_MAIN[] IS INITIAL.
    MESSAGE S005 DISPLAY LIKE 'E' WITH '생산 일정 취소할 오더를 선택해 주세요.'(E31).
    RETURN.
  ENDIF.

* 일정 취소 가능 여부 확인
  LOOP AT LT_MAIN INTO DATA(LS_MAIN).
    CASE LS_MAIN-ORD_STAT.
      WHEN '생성' OR '릴리즈'.
      WHEN OTHERS.
        MESSAGE S005 DISPLAY LIKE 'E' WITH '공정작업이 진행중 이거나 완료된 생산오더는 일정 취소할 수 없습니다.'(E30).
        RETURN.
    ENDCASE.
  ENDLOOP.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 오더의 생산일정 취소합니다. 계속 진행 하시겠습니까?'
    '취소확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LT_MAIN_SORT = LT_MAIN.
  SORT LT_MAIN_SORT BY ORDNR.
  DELETE ADJACENT DUPLICATES FROM LT_MAIN_SORT COMPARING ORDNR.

  LOOP AT LT_MAIN_SORT INTO LS_MAIN.

    APPEND INITIAL LINE TO LT_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDERS>).
    <LS_ORDERS>-ORDER_NUMBER = LS_MAIN-ORDNR.
    __ALPHA_INPUT <LS_ORDERS>-ORDER_NUMBER.

    READ TABLE GT_2340_DEL_CHK INTO DATA(LS_2340) WITH KEY ORDNR = <LS_ORDERS>-ORDER_NUMBER.
    IF SY-SUBRC EQ 0 AND
      ( ( P_SPGCD = 'GL' AND LS_2340-GONG_SEQ NE '01' ) OR
      ( P_SPGCD = 'GO' AND GV_CHK_GO_HALF = ABAP_TRUE ) ). " 권취 이외의 조장구성작업지시는 삭제
      APPEND INITIAL LINE TO LT_DEL_ORDERS ASSIGNING FIELD-SYMBOL(<LS_DEL_ORDERS>).
      <LS_DEL_ORDERS>-ORDER_NUMBER = <LS_ORDERS>-ORDER_NUMBER.

      DELETE FROM ZGTPPT2340 WHERE ORDNR = <LS_ORDERS>-ORDER_NUMBER.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
        DELETE GT_2340 WHERE ORDNR = <LS_ORDERS>-ORDER_NUMBER.
        READ TABLE LT_CHG_2330 TRANSPORTING NO FIELDS WITH KEY ZWKREQ = LS_2340-ZWKREQ.
        IF SY-SUBRC NE 0.
          SELECT SINGLE * FROM ZGTPPT2330
            INTO @DATA(LS_2330)
           WHERE ZWKREQ = @LS_2340-ZWKREQ
             AND RQMON = @LS_2340-RQMON.
          IF SY-SUBRC EQ 0.
            APPEND LS_2330 TO LT_CHG_2330.
          ENDIF.
        ENDIF.
      ENDIF.

    ELSE.

      SELECT A~ORDNR, A~POSNR, B~DMORD, B~DMLINE
        FROM ZGTPPT2340 AS A
        INNER JOIN ZGTPPT2330 AS B ON B~WERKS = A~WERKS
                                              AND B~SPGCD = A~SPGCD
                                              AND B~RQMON = A~RQMON
                                              AND B~ZWKREQ = A~ZWKREQ
        INTO TABLE @DATA(LT_CHK_SO)
       WHERE A~ORDNR = @<LS_ORDERS>-ORDER_NUMBER
         AND B~DMORDTY = 'SO'.

      REFRESH LT_2010.
      SELECT * FROM ZGTPPT2010
       WHERE ORDNR = @<LS_ORDERS>-ORDER_NUMBER
         AND MATNR_DM IS NOT INITIAL
         AND DMORDTY IN ( 'SO', 'SM' )
        INTO TABLE @LT_2010.
      IF SY-SUBRC EQ 0.
        APPEND INITIAL LINE TO LT_AUFNR ASSIGNING FIELD-SYMBOL(<LS_AUFNR>).
        <LS_AUFNR>-SIGN = 'I'.
        <LS_AUFNR>-OPTION = 'EQ'.
        <LS_AUFNR>-LOW = <LS_ORDERS>-ORDER_NUMBER.

      ENDIF.

      CLEAR : LS_ORDERDATA, LS_ORDERDATAX.
      LS_ORDERDATA-BASIC_SCHEDULING_TYPE = '3'.

      SELECT B~*
        FROM AFKO AS A
        INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
       WHERE A~AUFNR = @<LS_ORDERS>-ORDER_NUMBER
        APPENDING TABLE @DATA(LT_RESB).

      CASE LS_MAIN-ORD_STAT.
        WHEN '릴리즈'. " 구성품 수량이 변경되므로 백업본 들고 있기
          LS_ORDERDATA-EXPLODE_NEW = ABAP_TRUE.
          LS_ORDERDATA-PROD_VERSION = '1000'.
          LS_ORDERDATAX-PROD_VERSION = ABAP_TRUE.
      ENDCASE.
      LS_ORDERDATA-EXPLOSION_DATE = SY-DATUM.
      LS_ORDERDATAX-EXPLOSION_DATE = ABAP_TRUE.

      LS_ORDERDATAX-BASIC_SCHEDULING_TYPE = ABAP_TRUE.

      CALL FUNCTION 'BAPI_PRODORD_CHANGE'
        EXPORTING
          NUMBER     = <LS_ORDERS>-ORDER_NUMBER
          ORDERDATA  = LS_ORDERDATA
          ORDERDATAX = LS_ORDERDATAX
        IMPORTING
          RETURN     = LS_RETURN.

      IF LS_RETURN-TYPE NE 'E'.

        CLEAR : LS_RETURN_2, LV_ERROR.
        CALL FUNCTION 'CO_XT_ORDER_PREPARE_COMMIT'
          IMPORTING
            ES_BAPIRETURN    = LS_RETURN_2
            E_ERROR_OCCURRED = LV_ERROR.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.

        WAIT UP TO '0.1' SECONDS.

        CALL FUNCTION 'MESSAGES_INITIALIZE'.
        CALL FUNCTION 'CO_IH_BUFFER_REFRESH'.
        CALL FUNCTION 'BAPI_PS_INITIALIZATION'.

        UPDATE AUFK SET ZZTANDEM = ' '
         WHERE AUFNR = <LS_ORDERS>-ORDER_NUMBER.
        IF SY-SUBRC EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.

        IF LT_CHK_SO IS NOT INITIAL.
          LOOP AT LT_CHK_SO INTO DATA(LS_CHK_SO).
            UPDATE AFPO SET KDAUF = LS_CHK_SO-DMORD
                            KDPOS = LS_CHK_SO-DMLINE
                            SOBKZ = 'E'
                            KZBWS = 'A'
                WHERE AUFNR = LS_CHK_SO-ORDNR
                    AND POSNR = LS_CHK_SO-POSNR+2(4).
            IF SY-SUBRC EQ 0.
              COMMIT WORK AND WAIT.
            ENDIF.
          ENDLOOP.
          REFRESH LT_CHK_SO.
        ENDIF.

      ELSE.
        MESSAGE S006 DISPLAY LIKE 'E' WITH TEXT-E13 <LS_ORDERS>-ORDER_NUMBER TEXT-E34.
        RETURN.
      ENDIF.
    ENDIF.

    DELETE FROM ZGTPPT2400 WHERE AUFNR = <LS_ORDERS>-ORDER_NUMBER.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.

    DELETE FROM ZGTPPT2390 WHERE AUFNR = <LS_ORDERS>-ORDER_NUMBER.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDLOOP.

* 전주 랜조장 계획 정보 변경
  IF LT_CHG_2330[] IS NOT INITIAL.
    LOOP AT LT_CHG_2330 ASSIGNING FIELD-SYMBOL(<LS_2330>).
      IF <LS_2330>-PLNUM IS NOT INITIAL.
        APPEND <LS_2330>-PLNUM TO LT_PLAN_ORDERS.
        CLEAR <LS_2330>-PLNUM.
      ENDIF.

      CLEAR LV_CAL_GSMNG.
      SELECT * FROM ZGTPPT2340
        INTO TABLE @DATA(LT_2330_SUM)
        WHERE ZWKREQ = @LS_2340-ZWKREQ
             AND RQMON = @LS_2340-RQMON.

      LOOP AT LT_2330_SUM INTO DATA(LS_2340_CHK).
        LV_CAL_GSMNG = LV_CAL_GSMNG + ( LS_2340_CHK-INLENGTH * LS_2340_CHK-INFACTOR ).
      ENDLOOP.

      IF LV_CAL_GSMNG = 0.
        SELECT A~*
          FROM ZGTPPT2330 AS A
          INNER JOIN ZGTPPT2340 AS B ON B~ZWKREQ = A~ZWKREQ
          WHERE A~WERKS = @P_WERKS
            AND A~SPGCD = @P_SPGCD
            AND A~RQMON = @P_SPMON
            AND A~ZDISTRIB = '1'
            AND A~GONG_SEQ = '01'
          INTO TABLE @DATA(LT_REW).
        IF SY-SUBRC NE 0 AND LT_REW IS INITIAL.
          DELETE ZGTPPT2330 FROM <LS_2330>.
          COMMIT WORK AND WAIT.
          DELETE TABLE LT_CHG_2330 FROM <LS_2330>.
          CONTINUE.
        ENDIF.

      ENDIF.

      IF <LS_2330>-GSMNG <= LV_CAL_GSMNG.
        APPEND <LS_2330> TO LT_CHG_2330.
      ELSE.
        CLEAR LV_GSMNG.
        LV_GSMNG = <LS_2330>-GSMNG - LV_CAL_GSMNG.

        PERFORM MAKE_PLAN_ORDER CHANGING <LS_2330> LV_GSMNG LV_CHK_ERR.

        IF LV_CHK_ERR = ABAP_TRUE.
          CLEAR LV_MESSAGE.
          CONCATENATE '공정코드' LS_2330-GONG_CD '의 반제품 자재' LS_2330-MATNR '계획오더 생성 중 오류가 발생했습니다.'
                      INTO LV_MESSAGE SEPARATED BY SPACE.
          MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MESSAGE.
          PERFORM ROLLBACK_PLAN_ORDER USING LT_PLAN_ORDERS_ROLLBACK.
          RETURN.
        ENDIF.
        APPEND LS_2330-PLNUM TO LT_PLAN_ORDERS_ROLLBACK.
      ENDIF.
    ENDLOOP.

    IF LT_PLAN_ORDERS[] IS NOT INITIAL.
      PERFORM ROLLBACK_PLAN_ORDER USING LT_PLAN_ORDERS.
    ENDIF.

    MODIFY ZGTPPT2330 FROM TABLE LT_CHG_2330.
    COMMIT WORK AND WAIT.

  ENDIF.

  IF LT_DEL_ORDERS[] IS NOT INITIAL.
    PERFORM ROLLBACK_ORDES TABLES LT_DEL_ORDERS.
  ENDIF.

  WAIT UP TO 1 SECONDS.

  IF LT_AUFNR[] IS NOT INITIAL.
    SORT LT_AUFNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_AUFNR COMPARING LOW.

    SUBMIT ZGTPPR2330
                     WITH P_SLSORD = ' '
                     WITH P_PRDORD = 'X'
                     WITH S_AUFNR IN LT_AUFNR
                     WITH P_AUTO = ABAP_FALSE
                     WITH P_BATCH = ABAP_TRUE
                     AND RETURN.

    REFRESH LT_2010.
    SELECT * FROM ZGTPPT2010
     WHERE ORDNR IN @LT_AUFNR
       AND MATNR_DM IS INITIAL
       AND DMORDTY IN ( 'SO', 'SM' )
      INTO TABLE @LT_2010.
    IF SY-SUBRC EQ 0.
      REFRESH LT_GUIDE_TEXT.
      APPEND INITIAL LINE TO LT_GUIDE_TEXT ASSIGNING FIELD-SYMBOL(<LV_GUIDE_TEXT>).
      <LV_GUIDE_TEXT> = '완제품 일정 취소시 드럼정보 초기화 되었습니다.'.

      SORT LT_2010 BY ORDNR.
      DELETE ADJACENT DUPLICATES FROM LT_2010 COMPARING ORDNR.
      LOOP AT LT_2010 INTO DATA(LS_TEMP_2010).
        APPEND INITIAL LINE TO LT_GUIDE_TEXT ASSIGNING <LV_GUIDE_TEXT>.
        <LV_GUIDE_TEXT> = |　조장구성표번호/생산오더 - { LS_TEMP_2010-GRPNR }/{ LS_TEMP_2010-ORDNR }|.
      ENDLOOP.

      APPEND INITIAL LINE TO LT_GUIDE_TEXT ASSIGNING <LV_GUIDE_TEXT>.
      <LV_GUIDE_TEXT> = |★ 확인후 드럼 재지정 바랍니다.|.

      CALL FUNCTION 'ZGTPP_UTILL_DISP_WARNING'
        EXPORTING
          IV_TITLE = '안내사항'
        TABLES
          IT_TEXT  = LT_GUIDE_TEXT.

    ENDIF.

  ENDIF.

* 오더 가용시간 재계산후 적용.
  DELETE GT_MAIN_DISP_101 WHERE CHECK = ABAP_TRUE.

*  PERFORM RESET_TIME_TABLE_OF_ORDER.

  PERFORM GET_MAIN_PROD_ORDER_INFOR.
*    수립가능한 오더 세팅
  PERFORM MAKE_ORDER_INFO.
*    해당 설비별 순번별 수립된 데이터 세팅
  REFRESH GT_MAKE_PLAN.
  PERFORM MAKE_PLAN_DATA TABLES GT_ORDSYVAL_PLANED.
*    해당 설비별 순번별 일자별 수립된 작업 시간 관리
  REFRESH GT_WORKTIME_DAY.
  PERFORM SET_CRT_TIME_DAY.

  PERFORM RESET_ARBPL_MAIN.
*    선댁된 일자로 설비별 순번별 수립된 데이터 세팅
  REFRESH GT_MAIN_DISP_101.
  PERFORM MAKE_PLAN_DISP_DATA TABLES GT_ORDSYVAL_PLANED.

  LOOP AT GT_MAIN_DISP_101 INTO DATA(LS_CHG).
    LV_AUFNR = LS_CHG-ORDNR.
    __ALPHA_INPUT LV_AUFNR.
    CLEAR LV_ZZPRIORITY.
    SELECT SINGLE ZZPRIORITY FROM AUFK
      INTO LV_ZZPRIORITY
     WHERE AUFNR = LV_AUFNR.
    IF SY-SUBRC EQ 0 .
      IF LS_CHG-GSTRP = GV_SELECTED_DAY AND LV_ZZPRIORITY NE LS_CHG-ZZPRIORITY.
        UPDATE AUFK SET ZZPRIORITY = LS_CHG-ZZPRIORITY
          WHERE AUFNR = LV_AUFNR.
        IF SY-SUBRC EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

  PERFORM SET_TOTAL_DISP_TABLE.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  PERFORM REFRESH_GRID USING GO_GRID_0101.

  LV_SEQ_C = LINES( LT_MAIN ).
  CONDENSE LV_SEQ_C.
  MESSAGE S006 WITH '선택오더' LV_SEQ_C '건 생산일정 취소되었습니다'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_TIME_TABLE_OF_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RESET_TIME_TABLE_OF_ORDER .

  DATA : LV_WEEKEND_DT TYPE SY-DATUM.
  DATA : LT_WORKING LIKE GT_ORDER_DAY_WORKING.
  DATA : LV_AVAILABLE_TIME TYPE ZGTPPT2400-ZWKLTH.
  DATA : LV_PLAN_TIME TYPE ZGTPPT2400-ZWKLTH.
  DATA : LV_LAST_INDEX TYPE I.
  DATA : LV_INDEX TYPE I.
  DATA : LV_WKCHH TYPE ZGTPPT2400-ZWKCHH.
  DATA : LV_ZWKLTH TYPE ZGTPPT2400-ZWKLTH.
  DATA : LV_CAL_TIME TYPE ZGTPPT2400-ZWKLTH.
  DATA : LV_MENGE_IN TYPE EKPO-MENGE.
  DATA : LV_MENGE_OUT TYPE EKPO-MENGE.
  DATA : LV_AUFNR TYPE AUFNR.
  DATA : LV_POSNR TYPE AFPO-POSNR.
  DATA : BEGIN OF LS_CHG_AUFNR_INFOR,
           AUFNR      TYPE AUFNR,
           GSTRP      TYPE AFKO-GSTRP,
           GSUZP      TYPE AFKO-GSUZP,
           GLTRP      TYPE AFKO-GLTRP,
           GLUZP      TYPE AFKO-GLUZP,
           ZZPRIORITY TYPE AUFK-ZZPRIORITY,
           MATNR      TYPE MATNR,
         END OF LS_CHG_AUFNR_INFOR.

  DATA : BEGIN OF LS_BEFORE_ORDER_INFOR,
           AUFNR TYPE AUFNR,
           GSTRP TYPE AFKO-GSTRP,
           GSUZP TYPE AFKO-GSUZP,
           GLTRP TYPE AFKO-GLTRP,
           GLUZP TYPE AFKO-GLUZP,
         END OF  LS_BEFORE_ORDER_INFOR.

  DATA : LT_CHG_AUFNR_INFOR LIKE TABLE OF LS_CHG_AUFNR_INFOR.
  DATA : LV_HOURS(2) TYPE N.
  DATA : LV_MINUTE(2) TYPE N.
  DATA : LT_SAVE_2390 TYPE TABLE OF ZGTPPT2390.
  DATA : LT_MAIN_ARBPL LIKE GT_MAIN_DISP_101.
  DATA : LV_CHK_CHG.

  DATA(LT_MAIN) = GT_MAIN_DISP_101.
  SORT LT_MAIN BY ORDNR.
  DELETE ADJACENT DUPLICATES FROM LT_MAIN COMPARING ORDNR.

  LV_WEEKEND_DT = P_WEEKTO - 1.

  LOOP AT GT_ARBPL INTO GS_ARBPL.
    CLEAR LS_BEFORE_ORDER_INFOR.
    CLEAR LV_CAL_TIME.
    CLEAR LV_INDEX.
    LT_MAIN_ARBPL = VALUE #( FOR LW_MAIN IN LT_MAIN WHERE ( ARBPL = GS_ARBPL-ARBPL )
                                        ( CORRESPONDING #( LW_MAIN ) ) ).
    LV_LAST_INDEX = LINES( LT_MAIN_ARBPL ).

    LOOP AT LT_MAIN INTO GS_MAIN_DISP_101 WHERE GONG_CD = GS_ARBPL-GONG_CD
                                                                   AND ARBPL = GS_ARBPL-ARBPL.

      ADD 1 TO LV_INDEX.
      IF GS_MAIN_DISP_101-GSTRP = GV_SELECTED_DAY.

        CLEAR LV_AUFNR.
        LV_AUFNR = GS_MAIN_DISP_101-ORDNR.
        __ALPHA_INPUT LV_AUFNR.

*    변경할 정보 세팅
        CLEAR LS_CHG_AUFNR_INFOR.
        LS_CHG_AUFNR_INFOR-AUFNR = LV_AUFNR.
        IF LS_BEFORE_ORDER_INFOR IS NOT INITIAL.
          LS_CHG_AUFNR_INFOR-GSTRP = LS_BEFORE_ORDER_INFOR-GLTRP.
          LS_CHG_AUFNR_INFOR-GSUZP = LS_BEFORE_ORDER_INFOR-GLUZP.
          LS_CHG_AUFNR_INFOR-GLTRP = LS_BEFORE_ORDER_INFOR-GLTRP.
          LS_CHG_AUFNR_INFOR-GLUZP = LS_BEFORE_ORDER_INFOR-GLUZP.
        ELSE.
          LS_CHG_AUFNR_INFOR-GSTRP = GV_SELECTED_DAY.
          LS_CHG_AUFNR_INFOR-GSUZP = '000000'.
          LS_CHG_AUFNR_INFOR-GLTRP = GV_SELECTED_DAY.
          LS_CHG_AUFNR_INFOR-GLUZP = '240000'.
        ENDIF.

        LV_CAL_TIME = LS_CHG_AUFNR_INFOR-GSUZP+0(2) + ( LS_CHG_AUFNR_INFOR-GSUZP+2(2) / 60 ).
        LV_AVAILABLE_TIME = 24 - ( LS_CHG_AUFNR_INFOR-GSUZP+0(2) + ( LS_CHG_AUFNR_INFOR-GSUZP+2(2) / 60 ) ).

        CLEAR LV_PLAN_TIME.
        LOOP AT GT_MAIN_DISP_101 INTO DATA(LS_MAIN) WHERE ORDNR = GS_MAIN_DISP_101-ORDNR.
*    대기시간, 작업시간 더해준다.
          LV_PLAN_TIME = LV_PLAN_TIME + LS_MAIN-WKCHH + LS_MAIN-ZWKLTH.
        ENDLOOP.

* 종료시간 세팅
        LV_CAL_TIME = LV_CAL_TIME + LV_PLAN_TIME.
        DO.
          IF LV_CAL_TIME > 24.
            LS_CHG_AUFNR_INFOR-GLTRP = LS_CHG_AUFNR_INFOR-GLTRP + 1.
            IF GV_CHK_SKIP IS INITIAL.
              CASE LS_CHG_AUFNR_INFOR-GLTRP.
                WHEN LV_WEEKEND_DT.
                  APPEND INITIAL LINE TO LT_SAVE_2390 ASSIGNING FIELD-SYMBOL(<LS_SAVE_2390>).
                  <LS_SAVE_2390>-AUFNR = LV_AUFNR.
                  <LS_SAVE_2390>-POSNR = LS_MAIN-POSNR.
                  <LS_SAVE_2390>-SKDAT = LV_WEEKEND_DT.
                  APPEND INITIAL LINE TO LT_SAVE_2390 ASSIGNING <LS_SAVE_2390>.
                  <LS_SAVE_2390>-AUFNR = LV_AUFNR.
                  <LS_SAVE_2390>-POSNR = LS_MAIN-POSNR.
                  <LS_SAVE_2390>-SKDAT = P_WEEKTO.

                  LS_CHG_AUFNR_INFOR-GLTRP = LS_CHG_AUFNR_INFOR-GLTRP + 2.
                WHEN  P_WEEKTO.
                  APPEND INITIAL LINE TO LT_SAVE_2390 ASSIGNING <LS_SAVE_2390>.
                  <LS_SAVE_2390>-AUFNR = LV_AUFNR.
                  <LS_SAVE_2390>-POSNR = LS_MAIN-POSNR.
                  <LS_SAVE_2390>-SKDAT = P_WEEKTO.

                  LS_CHG_AUFNR_INFOR-GLTRP = LS_CHG_AUFNR_INFOR-GLTRP + 1.
              ENDCASE.
            ENDIF.

            LV_CAL_TIME = LV_CAL_TIME - 24.
          ELSE.
            LV_HOURS = TRUNC( LV_CAL_TIME ).
            LV_MINUTE = FRAC( LV_CAL_TIME ) * 60.
            LS_CHG_AUFNR_INFOR-GLUZP = LV_HOURS && LV_MINUTE && '00'.
            EXIT.
          ENDIF.
        ENDDO.

        CLEAR LS_BEFORE_ORDER_INFOR.
        MOVE-CORRESPONDING LS_CHG_AUFNR_INFOR TO LS_BEFORE_ORDER_INFOR.
        LS_BEFORE_ORDER_INFOR-AUFNR = GS_MAIN_DISP_101-ORDNR.
*      오더 상태에 따라 변경대상일지 스킵대상일지 구분(생성, 릴리즈만 변경)
        CASE GS_MAIN_DISP_101-ORD_STAT.
          WHEN '생성' OR '릴리즈'. "
* 대상건중 시간이 변경된 대상만 변경
            CLEAR LV_CHK_CHG.
            READ TABLE GT_MAKE_PLAN INTO GS_MAKE_PLAN WITH KEY ORDNR = GS_MAIN_DISP_101-ORDNR.
            IF SY-SUBRC EQ 0.
              IF GS_MAKE_PLAN-GSTRP NE LS_CHG_AUFNR_INFOR-GLTRP.
                LV_CHK_CHG = ABAP_TRUE.
              ENDIF.

              IF GS_MAKE_PLAN-GSUZP NE LS_CHG_AUFNR_INFOR-GSUZP.
                LV_CHK_CHG = ABAP_TRUE.
              ENDIF.

              IF GS_MAKE_PLAN-GLTRP NE LS_CHG_AUFNR_INFOR-GLTRP.
                LV_CHK_CHG = ABAP_TRUE.
              ENDIF.

              IF GS_MAKE_PLAN-GLUZP NE LS_CHG_AUFNR_INFOR-GLUZP.
                LV_CHK_CHG = ABAP_TRUE.
              ENDIF.

            ENDIF.
            IF LV_CHK_CHG = ABAP_TRUE.
              APPEND LS_CHG_AUFNR_INFOR TO LT_CHG_AUFNR_INFOR.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.

      ELSE. " 오더 시작일이 해당 일자가 아닐경우. 첫라인

        READ TABLE GT_MAKE_PLAN INTO GS_MAKE_PLAN WITH KEY ORDNR = GS_MAIN_DISP_101-ORDNR.
        IF SY-SUBRC EQ 0.
          CLEAR LS_BEFORE_ORDER_INFOR.
          MOVE-CORRESPONDING GS_MAKE_PLAN TO LS_BEFORE_ORDER_INFOR.
          LS_BEFORE_ORDER_INFOR-AUFNR = GS_MAKE_PLAN-ORDNR.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDLOOP.

*  시간 변경대상건 존재시 오더 변경
  IF LT_CHG_AUFNR_INFOR[] IS NOT INITIAL.
    DATA  LV_CHK_ERR.
    DATA : LV_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.
    DATA : LS_ORDERDATA TYPE BAPI_PP_ORDER_CHANGE.
    DATA : LS_ORDERDATAX TYPE BAPI_PP_ORDER_CHANGEX.
    DATA : LS_RETURN TYPE BAPIRET2.

* 일정변경
    LOOP AT LT_CHG_AUFNR_INFOR INTO LS_CHG_AUFNR_INFOR.
      LV_NUMBER = LS_CHG_AUFNR_INFOR-AUFNR.

      CLEAR LS_ORDERDATA.
      CLEAR LS_ORDERDATAX.

      LS_ORDERDATA-BASIC_START_DATE = LS_CHG_AUFNR_INFOR-GSTRP.
      LS_ORDERDATA-BASIC_START_TIME = LS_CHG_AUFNR_INFOR-GSUZP.
      LS_ORDERDATA-BASIC_END_DATE = LS_CHG_AUFNR_INFOR-GLTRP.
      LS_ORDERDATA-BASIC_END_TIME = LS_CHG_AUFNR_INFOR-GLUZP.
      LS_ORDERDATAX-BASIC_START_DATE = 'X'.
      LS_ORDERDATAX-BASIC_END_DATE = 'X'.

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

      ELSE.
        MESSAGE S006 DISPLAY LIKE 'E' WITH TEXT-E13 LV_NUMBER TEXT-E19.
        RETURN.
      ENDIF.

    ENDLOOP.

    WAIT UP TO 1 SECONDS.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATE_FOR_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DATE_FOR_DISPLAY .

  GV_BGN_DT = S_GSTRP-LOW.
  GV_END_DT = S_GSTRP-HIGH.

  REFRESH GT_DAY_ATTR.

  CALL FUNCTION 'DAY_ATTRIBUTES_GET'
    EXPORTING
      FACTORY_CALENDAR           = 'LG'   "LV_FACTORY_ID
      HOLIDAY_CALENDAR           = 'LG'     "LV_HOLIDAY_ID
      DATE_FROM                  = GV_BGN_DT
      DATE_TO                    = GV_END_DT
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

  SORT GT_DAY_ATTR BY DATE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_SCREEN_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_SCREEN_200 .

  PERFORM SET_FIELDCAT_0200.
  PERFORM MAKE_ITAB_FR_FCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_0200 .

  DATA : LV_CHK_DATE TYPE SY-DATUM.
  DATA : LV_COLPOS TYPE I.
  DATA : LV_REPTXT TYPE REPTXT.
  DATA : LV_REPTXT2 TYPE REPTXT.

  REFRESH GT_FIELDCAT_0200.

* 헤더와 라인 구분을 위해
  APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
  <LS_FCAT>-COL_POS = 1.
  <LS_FCAT>-FIELDNAME = 'GUBUN'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
  <LS_FCAT>-DATATYPE = 'INT'.
  <LS_FCAT>-DD_OUTLEN = '10'.
  <LS_FCAT>-NO_OUT = ABAP_TRUE.

* 라인별 순번정리를 위해
  APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-COL_POS = 2.
  <LS_FCAT>-FIELDNAME = 'ARBPL'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '설비'(f40).
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '30'.
  <LS_FCAT>-OUTPUTLEN = '16'.
  <LS_FCAT>-JUST = 'L'.
  <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.

* 라인별 순번정리를 위해
  APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-COL_POS = 3.
  <LS_FCAT>-FIELDNAME = 'SEQNO'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
  <LS_FCAT>-DATATYPE = 'INT'.
  <LS_FCAT>-DD_OUTLEN = '10'.
  <LS_FCAT>-NO_OUT = ABAP_TRUE.

* 라인별 순번정리를 위해
  APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-COL_POS = 4.
  <LS_FCAT>-FIELDNAME = 'LINE'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
  <LS_FCAT>-DATATYPE = 'INT'.
  <LS_FCAT>-DD_OUTLEN = '10'.
  <LS_FCAT>-NO_OUT = ABAP_TRUE.

  LV_COLPOS = 100.

  LV_CHK_DATE = GV_BGN_DT.

  DO.
    IF LV_CHK_DATE > GV_END_DT.
      EXIT.
    ENDIF.

    READ TABLE GT_DAY_ATTR INTO DATA(LS_DAY_ATTR) WITH KEY DATE = LV_CHK_DATE.
    CLEAR LV_REPTXT.
    LV_REPTXT = LV_CHK_DATE+0(4) && '-' && LV_CHK_DATE+4(2) && '-' && LV_CHK_DATE+6(2).
    CLEAR LV_REPTXT2.
    LV_REPTXT2 = '(' && LS_DAY_ATTR-WEEKDAY_S && ')'.

    CONCATENATE LV_REPTXT LV_REPTXT2 INTO LV_REPTXT SEPARATED BY SPACE.

    APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = LV_COLPOS.
    <LS_FCAT>-FIELDNAME = LV_CHK_DATE.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_REPTXT.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '100'.
    <LS_FCAT>-OUTPUTLEN = '30'.
    <LS_FCAT>-JUST = 'L'.

    ADD 1 TO LV_COLPOS.
    ADD 1 TO LV_CHK_DATE.
  ENDDO.

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

  FREE GT_SET_SCHEDULE.

  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
      I_STYLE_TABLE             = ABAP_TRUE
      IT_FIELDCATALOG           = GT_FIELDCAT_0200
    IMPORTING
      EP_TABLE                  = GT_SET_SCHEDULE
    EXCEPTIONS
      GENERATE_SUBPOOL_DIR_FULL = 1                " At Most 36 Subroutine Pools Can Be Generated Temporarily
      OTHERS                    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE S005 DISPLAY LIKE 'E' WITH 'At Most 36 Subroutine Pools' 'Can Be Generated Temporarily'.
    LEAVE LIST-PROCESSING..
  ENDIF.

  ASSIGN GT_SET_SCHEDULE->* TO <GT_SET_SCHEDULE>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_MAINTAIN_SCHEDULE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_MAINTAIN_SCHEDULE .

  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LV_NUMBER TYPE I.
  DATA : LV_MAX_NUMBER TYPE I.

  SORT GT_ORDSYVAL BY GSTRP ZZPRIORITY.
  REFRESH GT_MAINTAIN_SCHEDULE.

  IF GT_ORDSYVAL[] IS NOT INITIAL.
    SELECT DISTINCT *
      FROM ZGTPPT2390
        FOR ALL ENTRIES IN @GT_ORDSYVAL
     WHERE AUFNR = @GT_ORDSYVAL-AUFNR
      INTO TABLE @GT_EXISTS_DAY.
  ENDIF.

  LOOP AT GT_ARBPL INTO GS_ARBPL.

    CLEAR GS_MAINTAIN_SCHEDULE.
    GS_MAINTAIN_SCHEDULE-GONG_CD = GS_ARBPL-GONG_CD.
    GS_MAINTAIN_SCHEDULE-ARBPL = GS_ARBPL-ARBPL.
    GS_MAINTAIN_SCHEDULE-KTEXT = GS_ARBPL-KTEXT.

    CLEAR LV_DATE.
    LV_DATE = GV_BGN_DT.

    CLEAR LV_MAX_NUMBER.
    DO.
      IF LV_DATE > GV_END_DT.
        EXIT.
      ENDIF.

      CLEAR GS_DATE_LINE.
      CLEAR LV_NUMBER.
      PERFORM SET_DATE_LINE_200 USING GS_ARBPL-ARBPL LV_DATE
                                      CHANGING GS_DATE_LINE LV_NUMBER.

      IF LV_MAX_NUMBER < LV_NUMBER.
        LV_MAX_NUMBER = LV_NUMBER.
      ENDIF.
      APPEND GS_DATE_LINE TO GS_MAINTAIN_SCHEDULE-T_DATE.

      ADD 1 TO LV_DATE.

    ENDDO.
    GS_MAINTAIN_SCHEDULE-MAX_SEQNO = LV_MAX_NUMBER.
    APPEND GS_MAINTAIN_SCHEDULE TO GT_MAINTAIN_SCHEDULE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATE_LINE_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_ARBPL_ARBPL
*&      --> LV_DATE
*&      <-- GS_DATE_LINE
*&      <-- LV_NUMBER
*&---------------------------------------------------------------------*
FORM SET_DATE_LINE_200  USING    PV_ARBPL TYPE CRHD_V1-ARBPL
                                 PV_DATE TYPE SY-DATUM
                        CHANGING PS_DATE_LINE LIKE GS_DATE_LINE
                                 PV_NUMBER TYPE I.

  PS_DATE_LINE-DATE = PV_DATE.
  REFRESH GT_MATNR_KEY_LINE.

  LOOP AT GT_ORDSYVAL INTO DATA(LS_ORDSYVAL) WHERE ARBPL = PV_ARBPL
                                                              AND GSTRP < PV_DATE
                                                              AND GLTRP >= PV_DATE.

* 해당 날짜 작업 없는지 여부 확인
    READ TABLE GT_EXISTS_DAY TRANSPORTING NO FIELDS WITH KEY AUFNR = LS_ORDSYVAL-AUFNR
                                                                                       SKDAT = PV_DATE.
    IF SY-SUBRC EQ 0.
      CONTINUE.
    ENDIF.

    PERFORM SET_MATNR_KEY USING LS_ORDSYVAL LS_ORDSYVAL-MAKTX.


  ENDLOOP.



  LOOP AT GT_ORDSYVAL INTO LS_ORDSYVAL WHERE ARBPL = PV_ARBPL
                                                            AND GSTRP = PV_DATE.

    PERFORM SET_MATNR_KEY USING LS_ORDSYVAL LS_ORDSYVAL-MAKTX.

  ENDLOOP.

  IF GT_MATNR_KEY_LINE IS NOT INITIAL.
    PV_NUMBER = LINES( GT_MATNR_KEY_LINE ).
    APPEND LINES OF GT_MATNR_KEY_LINE TO PS_DATE_LINE-T_MATNR_KEY.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MATNR_KEY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_ORDSYVAL
*&      --> LS_2010_GRPNR
*&---------------------------------------------------------------------*
FORM SET_MATNR_KEY  USING    PS_ORDSYVAL TYPE ZGTCVORDSYVAL
                             PV_ORDNR_KEY.

  DATA : LS_ORDNR_KEY LIKE GS_MATNR_KEY_LINE.
  DATA : LS_MENGE_LINE LIKE GS_MENGE_LINE.

  READ TABLE GT_MATNR_KEY_LINE ASSIGNING FIELD-SYMBOL(<LS_MATNR_KEY_LINE>) WITH KEY MATNR = PS_ORDSYVAL-MATNR
                                                                                                                     ORDNR_KEY = PV_ORDNR_KEY.
  IF SY-SUBRC EQ 0.
    CLEAR LS_MENGE_LINE.
    LS_MENGE_LINE-GAMNG = PS_ORDSYVAL-PSAMG + PS_ORDSYVAL-PSMNG.
    LS_MENGE_LINE-NUMBERS = 1.

    READ TABLE <LS_MATNR_KEY_LINE>-T_MENGE ASSIGNING FIELD-SYMBOL(<LS_MENGE_LINE>) WITH KEY GAMNG = LS_MENGE_LINE-GAMNG.
    IF SY-SUBRC EQ 0.
      ADD 1 TO <LS_MENGE_LINE>-NUMBERS.
    ELSE.
      APPEND INITIAL LINE TO <LS_MATNR_KEY_LINE>-T_MENGE ASSIGNING <LS_MENGE_LINE>.
      <LS_MENGE_LINE>-GAMNG = PS_ORDSYVAL-PSAMG + PS_ORDSYVAL-PSMNG.
      <LS_MENGE_LINE>-NUMBERS = 1.
    ENDIF.

  ELSE.
    APPEND INITIAL LINE TO GT_MATNR_KEY_LINE ASSIGNING <LS_MATNR_KEY_LINE>.
    <LS_MATNR_KEY_LINE>-MATNR = PS_ORDSYVAL-MATNR.
    <LS_MATNR_KEY_LINE>-MAKTX = PS_ORDSYVAL-MAKTX.

    SELECT SINGLE * FROM ZGTCVMSTVAL
      INTO @DATA(LS_CVMSTVAL)
     WHERE WERKS = @P_WERKS
        AND MATNR = @<LS_MATNR_KEY_LINE>-MATNR.

    IF SY-SUBRC EQ 0.
      IF LS_CVMSTVAL-COLORBASE IS NOT INITIAL.
        <LS_MATNR_KEY_LINE>-COLOR = LS_CVMSTVAL-COLORBASE.
      ENDIF.
    ENDIF.

    <LS_MATNR_KEY_LINE>-ORDNR_KEY = PV_ORDNR_KEY.

    CLEAR LS_MENGE_LINE.
    LS_MENGE_LINE-GAMNG = PS_ORDSYVAL-PSAMG + PS_ORDSYVAL-PSMNG.
    LS_MENGE_LINE-NUMBERS = 1.
    APPEND LS_MENGE_LINE TO <LS_MATNR_KEY_LINE>-T_MENGE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DISP_TABLE_SCHEDULE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_DISP_TABLE_SCHEDULE .

  DATA : LO_LINE1 TYPE REF TO DATA.
  DATA : LO_LINE2 TYPE REF TO DATA.
  DATA : LO_TAB TYPE REF TO DATA.

  DATA : LV_TOTAL_IDX TYPE I.
  DATA : LV_TABIX TYPE I.
  DATA : LV_FIRSTROW_INDEX TYPE I.
  DATA : LV_SECOND_INDEX TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_MENGE_C(20).
  DATA : LV_SEQNO_C(10).
  DATA : LV_STRING TYPE STRING.
  DATA : LV_MATNR_C(40).

  FIELD-SYMBOLS : <LS_LINE01> TYPE ANY.
  FIELD-SYMBOLS : <LS_LINE02> TYPE ANY.
  FIELD-SYMBOLS : <LT_TAB> TYPE TABLE.

  FIELD-SYMBOLS : <LV_VALUE01> TYPE ANY,
                  <LV_VALUE02> TYPE ANY,
                  <LV_VALUE03> TYPE ANY.

  DEFINE __SET_FIELD_OF_LINE.
    IF <LV_VALUE01> IS ASSIGNED. UNASSIGN <LV_VALUE01>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <LS_LINE01> TO <LV_VALUE01>.
    IF <LV_VALUE02> IS ASSIGNED. UNASSIGN <LV_VALUE02>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <LS_LINE02> TO <LV_VALUE02>.
  END-OF-DEFINITION.

  DEFINE __GET_LINE_OF_TABLE.
    CLEAR : LV_FIRSTROW_INDEX, LV_SECOND_INDEX.
    LV_FIRSTROW_INDEX = ( LV_TABIX * 2 ) - 1.
    READ TABLE <LT_TAB> ASSIGNING <LS_LINE01> INDEX LV_FIRSTROW_INDEX.
    LV_SECOND_INDEX = LV_FIRSTROW_INDEX + 1.
    READ TABLE <LT_TAB> ASSIGNING <LS_LINE02> INDEX LV_SECOND_INDEX.

    __SET_FIELD_OF_LINE 'GUBUN'.
    IF <LV_VALUE01> IS INITIAL.
      <LV_VALUE01> = 1.
      <LV_VALUE02> = 1.
    ENDIF.

    __SET_FIELD_OF_LINE 'LINE'.
    IF <LV_VALUE01> IS INITIAL.
      <LV_VALUE01> = 1.
      <LV_VALUE02> = 2.
    ENDIF.

  __SET_FIELD_OF_LINE 'SEQNO'.
    IF <LV_VALUE01> IS INITIAL.
      <LV_VALUE01> = LV_TABIX.
      <LV_VALUE02> = LV_TABIX.
    ENDIF.

  END-OF-DEFINITION.

  CREATE DATA LO_LINE1 LIKE LINE OF <GT_SET_SCHEDULE>.
  CREATE DATA LO_LINE2 LIKE LINE OF <GT_SET_SCHEDULE>.
  CREATE DATA LO_TAB LIKE <GT_SET_SCHEDULE>.

  ASSIGN LO_LINE1->* TO <LS_LINE01>.
  ASSIGN LO_LINE2->* TO <LS_LINE02>.
  ASSIGN LO_TAB->* TO <LT_TAB>.

  REFRESH <GT_SET_SCHEDULE>.
* 첫라인 타이틀
*&---------------------------------------------------------------------*
  APPEND INITIAL LINE TO <GT_SET_SCHEDULE> ASSIGNING FIELD-SYMBOL(<LS_TITLE>).
  ASSIGN COMPONENT 'ARBPL' OF STRUCTURE <LS_TITLE> TO <LV_VALUE03>.
  IF <LV_VALUE03> IS ASSIGNED.
    <LV_VALUE03> = '설비'.
  ENDIF.
  LOOP AT GT_DAY_ATTR INTO DATA(LS_DAY_ATTR).
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = LS_DAY_ATTR-DATE.

    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_TITLE> TO <LV_VALUE03>.
    IF <LV_VALUE03> IS ASSIGNED.
      READ TABLE GT_FIELDCAT_0200 INTO DATA(LS_FCAT) WITH KEY FIELDNAME = LV_FIELDNAME.
      IF SY-SUBRC EQ 0.
        <LV_VALUE03> = LS_FCAT-REPTEXT.
      ENDIF.
    ENDIF.
  ENDLOOP.
  UNASSIGN <LS_TITLE>.
*&---------------------------------------------------------------------*

  LOOP AT GT_MAINTAIN_SCHEDULE INTO GS_MAINTAIN_SCHEDULE.
    REFRESH <LT_TAB>.
    CLEAR LV_TOTAL_IDX.
    LV_TOTAL_IDX = GS_MAINTAIN_SCHEDULE-MAX_SEQNO * 2.
    DO LV_TOTAL_IDX TIMES.
      APPEND INITIAL LINE TO <LT_TAB>.
    ENDDO.

    LOOP AT GS_MAINTAIN_SCHEDULE-T_DATE INTO GS_DATE_LINE.
      CLEAR LV_TABIX.
      LOOP AT GS_DATE_LINE-T_MATNR_KEY INTO GS_MATNR_KEY_LINE.
        ADD 1 TO LV_TABIX.
        __GET_LINE_OF_TABLE.

        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = GS_DATE_LINE-DATE.

        __SET_FIELD_OF_LINE 'ARBPL'.
        IF <LV_VALUE01> IS ASSIGNED.
          CONCATENATE GS_MAINTAIN_SCHEDULE-ARBPL GS_MAINTAIN_SCHEDULE-KTEXT INTO <LV_VALUE01> SEPARATED BY '-'.
          <LV_VALUE02> = <LV_VALUE01>.
        ENDIF.

        __SET_FIELD_OF_LINE LV_FIELDNAME.
* 첫번째 라인 (자재명 + 오더키)
        <LV_VALUE01> = '(' && GS_MATNR_KEY_LINE-ORDNR_KEY && ')'.

        CLEAR LV_MATNR_C.
        LV_MATNR_C = GS_MATNR_KEY_LINE-MATNR.
        __ALPHA_OUT LV_MATNR_C.
        CONCATENATE LV_MATNR_C <LV_VALUE01> INTO <LV_VALUE01> SEPARATED BY SPACE.

        IF GS_MATNR_KEY_LINE-COLOR IS NOT INITIAL.
          CLEAR LV_STRING.
          LV_STRING = '(' && GS_MATNR_KEY_LINE-COLOR && ')'.
          CONCATENATE LV_STRING <LV_VALUE01> INTO <LV_VALUE01> SEPARATED BY SPACE.
        ENDIF.

* 두번째 라인 ()
        LOOP AT GS_MATNR_KEY_LINE-T_MENGE INTO GS_MENGE_LINE.
          CLEAR : LV_STRING, LV_MENGE_C, LV_SEQNO_C.
          WRITE GS_MENGE_LINE-GAMNG TO LV_MENGE_C UNIT 'EA'.
          CONDENSE LV_MENGE_C.
          LV_SEQNO_C = GS_MENGE_LINE-NUMBERS.
          CONDENSE LV_SEQNO_C.
          LV_STRING = LV_MENGE_C && 'X' && LV_SEQNO_C.
          IF <LV_VALUE02> IS INITIAL.
            <LV_VALUE02> = LV_STRING.
          ELSE.
            CONCATENATE <LV_VALUE02> ',' INTO <LV_VALUE02>.
            CONCATENATE <LV_VALUE02> LV_STRING INTO <LV_VALUE02> SEPARATED BY SPACE.
          ENDIF.
        ENDLOOP.

        CONCATENATE '(' <LV_VALUE02> ')' INTO <LV_VALUE02>.
      ENDLOOP.

    ENDLOOP.

    IF <LT_TAB> IS NOT INITIAL.
      APPEND LINES OF <LT_TAB> TO <GT_SET_SCHEDULE>.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0200 .

  CREATE OBJECT GO_DOCKING_0200
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
      I_PARENT      = GO_DOCKING_0200
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
*  GS_LAYOUT_0200-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0200-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0200-NO_TOOLBAR = ABAP_TRUE.
  GS_LAYOUT_0200-NO_HEADERS = ABAP_TRUE.
  GS_LAYOUT_0200-SEL_MODE   = 'C'.
  GS_LAYOUT_0200-STYLEFNAME = 'XYZSTYLEZYX'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0200 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  DATA : LV_FIELDNNAME TYPE FIELDNAME.

  FIELD-SYMBOLS <LV_GUBUN> TYPE ANY.
  FIELD-SYMBOLS <LV_VALUE> TYPE ANY.
  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

  LOOP AT <GT_SET_SCHEDULE> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

    CLEAR LS_CELLTAB.
    REFRESH LT_CELLTAB.
    IF <LV_GUBUN> IS ASSIGNED. UNASSIGN <LV_GUBUN>. ENDIF.
    ASSIGN COMPONENT 'GUBUN' OF STRUCTURE <LS_MAIN> TO <LV_GUBUN>.
    CASE <LV_GUBUN>.
      WHEN 0.
        IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
        ASSIGN COMPONENT 'ARBPL' OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
        IF <LV_VALUE> IS ASSIGNED.
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = 'ARBPL'.
          LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_HEADING + ALV_STYLE_ALIGN_CENTER_CENTER.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
        ENDIF.

        LOOP AT GT_DAY_ATTR INTO DATA(LS_DAY_ATTR).
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = LS_DAY_ATTR-DATE.
          CASE LS_DAY_ATTR-WEEKDAY.
            WHEN '6' OR '7'.
              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_NEGATIVE + ALV_STYLE_ALIGN_CENTER_CENTER.
            WHEN OTHERS.
              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_HEADING + ALV_STYLE_ALIGN_CENTER_CENTER.
          ENDCASE.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
        ENDLOOP.

      WHEN OTHERS.
        IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
        ASSIGN COMPONENT 'ARBPL' OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
        IF <LV_VALUE> IS ASSIGNED.
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = 'ARBPL'.
          LS_CELLTAB-STYLE = ALV_STYLE_COLOR_KEY.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
        ENDIF.

        LOOP AT GT_DAY_ATTR INTO LS_DAY_ATTR.
          CLEAR LV_FIELDNNAME.
          LV_FIELDNNAME = LS_DAY_ATTR-DATE.
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT LV_FIELDNNAME OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
          IF <LV_VALUE> IS ASSIGNED AND <LV_VALUE> IS NOT INITIAL.
            CLEAR LS_CELLTAB.
            LS_CELLTAB-FIELDNAME = LS_DAY_ATTR-DATE.
            LS_CELLTAB-STYLE = ALV_STYLE_COLOR_POSITIVE.
            INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
          ENDIF.
        ENDLOOP.
    ENDCASE.


    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'XYZSTYLEZYX' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0200 .

  PERFORM SET_SORT_TAB TABLES GT_SORT_0200
                            USING : 1 'GUBUN' 'X' '' '',
                                       2 'ARBPL'  'X' '' '',
                                       3 'SEQNO'  'X' '' '',
                                       4 'LINE'  'X' '' ''.

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
      IS_LAYOUT       = GS_LAYOUT_0200
    CHANGING
      IT_OUTTAB       = <GT_SET_SCHEDULE>
      IT_SORT         = GT_SORT_0200
      IT_FIELDCATALOG = GT_FIELDCAT_0200.

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

  DATA : LT_2400 TYPE TABLE OF ZGTPPT2400.
  DATA : LV_AUFNR TYPE AUFNR.


  IF GV_CHK_CHG_101 IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '변경된 내용이 없습니다.'.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '변경된 정보가 저장됩니다. 계속 진행 하시겠습니까?'
    '저장확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LOOP AT GT_MAIN_DISP_101 INTO DATA(LS_MAIN) WHERE CHK_CHG = ABAP_TRUE.
    LV_AUFNR = LS_MAIN-ORDNR.
    __ALPHA_INPUT LV_AUFNR.
    APPEND INITIAL LINE TO LT_2400 ASSIGNING FIELD-SYMBOL(<LS_2400>).
    <LS_2400>-AUFNR = LV_AUFNR.
    <LS_2400>-POSNR = LS_MAIN-POSNR + 0.
    <LS_2400>-ZWKCHH = LS_MAIN-WKCHH.
    <LS_2400>-ZWKLTH = LS_MAIN-ZWKLTH.
    <LS_2400>-RATE_OP = LS_MAIN-RATE_OP.
  ENDLOOP.

  IF LT_2400[] IS NOT INITIAL.
    MODIFY ZGTPPT2400 FROM TABLE LT_2400.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

* 생산오더 일정 수정
  PERFORM RESET_TIME_TABLE_OF_ORDER.

* 화면 초기화
  CLEAR GV_CHK_CHG_101.

  REFRESH GT_ORDSYVAL_CHG.

  REFRESH GT_ORDSYVAL_PLANED.

  DATA : LV_DISPO TYPE MARC-DISPO.

* SPG 테이블 조회용 필드로 변경
  LV_DISPO = P_SPGCD && '%'. "
* 일정수립된 오더정보
  SELECT * FROM ZGTCVORDSYVAL
    INTO TABLE GT_ORDSYVAL_PLANED
   WHERE WERKS = P_WERKS
      AND DISPO LIKE LV_DISPO
      AND PDCAPROCCODE IN GT_GONGCD
      AND ( GSTRP IN GT_GSTRP
       OR   GLTRP IN GT_GSTRP )
      AND TERKZ = '7'
      AND DLFL = ''
      AND LKD = ''
      AND CLSD = ''
      AND TECO = ''.

  PERFORM GET_ETC_DATA.
*    해당 설비별 순번별 수립된 데이터 세팅
  REFRESH GT_MAKE_PLAN.
  PERFORM MAKE_PLAN_DATA TABLES GT_ORDSYVAL_PLANED.
*    해당 설비별 순번별 일자별 수립된 작업 시간 관리
  REFRESH GT_WORKTIME_DAY.
  PERFORM SET_CRT_TIME_DAY.

*    선댁된 일자로 설비별 순번별 수립된 데이터 세팅
  REFRESH GT_MAIN_DISP_101.
  PERFORM MAKE_PLAN_DISP_DATA TABLES GT_ORDSYVAL_PLANED.

  PERFORM SET_TOTAL_DISP_TABLE.

  PERFORM REFRESH_GRID USING GO_GRID_0101.


  MESSAGE S006 WITH '변경사항 저장 되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_PLAN_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_2330
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM MAKE_PLAN_ORDER  CHANGING PS_2330 TYPE ZGTPPT2330
                                            PV_GSMNG TYPE GSMNG
                                            PV_CHK_ERR.

  DATA : LS_HEADERDATA TYPE BAPIPLAF_I1.
  DATA : LV_PLANNEDORDER TYPE BAPI_PLDORD-PLDORD_NUM.
  DATA : LS_RETURN TYPE BAPIRETURN1.

  LS_HEADERDATA-PLDORD_PROFILE  = 'LA'.
  LS_HEADERDATA-ORDER_START_DATE = PS_2330-PSTTR.
  LS_HEADERDATA-ORDER_FIN_DATE = PS_2330-PEDTR.
  LS_HEADERDATA-MATERIAL = PS_2330-MATNR.
  LS_HEADERDATA-PLAN_PLANT = P_WERKS.
  LS_HEADERDATA-PROD_PLANT = P_WERKS.
  LS_HEADERDATA-FIRMING_IND = 'X'.
  LS_HEADERDATA-TOTAL_PLORD_QTY = PV_GSMNG.

  CLEAR : LV_PLANNEDORDER, LS_RETURN.
  CALL FUNCTION 'BAPI_PLANNEDORDER_CREATE'
    EXPORTING
      HEADERDATA   = LS_HEADERDATA
    IMPORTING
      RETURN       = LS_RETURN
      PLANNEDORDER = LV_PLANNEDORDER.

  IF LS_RETURN-TYPE NE 'S'. "성공건에 대해 후행 로직 진행
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    PS_2330-PLNUM = LV_PLANNEDORDER.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ROLLBACK_PLAN_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_PLAN_ORDERS_ROLLBACK
*&---------------------------------------------------------------------*
FORM ROLLBACK_PLAN_ORDER  USING    PT_PLAN_ORDERS TYPE MRPDS_PLONO.

  DATA : LS_RETURN TYPE BAPIRETURN1.

  LOOP AT PT_PLAN_ORDERS INTO DATA(LS_ORDERS).
    CALL FUNCTION 'BAPI_PLANNEDORDER_DELETE'
      EXPORTING
        PLANNEDORDER = LS_ORDERS
      IMPORTING
        RETURN       = LS_RETURN.
  ENDLOOP.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_EXIST_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_CHG_AUFNR_INFOR_GLTRP
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHECK_EXIST_ORDER  USING    PV_CHK_DATE TYPE SY-DATUM
                        CHANGING PV_CHK_ERR.

  DATA : LV_DISPO TYPE MARC-DISPO.
  DATA : LT_ORDSYVAL TYPE TABLE OF ZGTCVORDSYVAL.

* SPG 테이블 조회용 필드로 변경
  LV_DISPO = P_SPGCD && '%'. "

  SELECT * FROM ZGTCVORDSYVAL
      INTO TABLE LT_ORDSYVAL
     WHERE WERKS = P_WERKS
        AND DISPO LIKE LV_DISPO
        AND PDCAPROCCODE IN GT_GONGCD
        AND GSTRP EQ PV_CHK_DATE
        AND TERKZ = '7'
        AND DLFL = ''
        AND LKD = ''
        AND CLSD = ''
        AND TECO = ''
        AND ARBPL = GV_SELECTED_ARBPL.
  IF SY-SUBRC EQ 0.
    PV_CHK_ERR = ABAP_TRUE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_POPUP_ORDERS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_100
*&---------------------------------------------------------------------*
FORM DISP_POPUP_ORDERS  USING    PS_MAIN_100 LIKE GS_MAIN_DISP_100.

  DATA : LS_2330 TYPE ZGTPPT2330.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : LT_ORDSYVAL TYPE TABLE OF ZGTCVORDSYVAL.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_OBJNR TYPE JEST-OBJNR.
  DATA : LV_USER_LINE TYPE BSVX-STTXT.

  CLEAR LS_2330.
  CASE PS_MAIN_100-GCATG.
    WHEN '계획오더'.
      READ TABLE GT_2330 INTO LS_2330 WITH KEY PLNUM = PS_MAIN_100-ORDNR.
    WHEN '판매오더' OR 'SM오더'.
      READ TABLE GT_2330 INTO LS_2330 WITH KEY DMORD = PS_MAIN_100-ORDNR
                                                              DMLINE = PS_MAIN_100-POSNR.
  ENDCASE.

  IF SY-SUBRC EQ 0.
    LT_AUFNR = VALUE #( FOR LW_2340 IN GT_2340 WHERE ( ZWKREQ = LS_2330-ZWKREQ
                                                                     AND  ORDTY = 'PRD' )
                                ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2340-ORDNR ) ).

    SELECT DISTINCT * FROM ZGTCVORDSYVAL
      INTO TABLE LT_ORDSYVAL
      WHERE WERKS = P_WERKS
        AND AUFNR IN LT_AUFNR.
  ELSE.
    RETURN.
  ENDIF.

  IF LT_ORDSYVAL IS INITIAL.
    RETURN.
  ENDIF.

  REFRESH GT_POP_ORDERS.
  SORT LT_ORDSYVAL BY GSTRP GSUZP.

  CLEAR LV_SEQNO.
  LOOP AT LT_ORDSYVAL INTO DATA(LS_MAIN).
    CLEAR GS_POP_ORDERS.

    ADD 1 TO LV_SEQNO.
    GS_POP_ORDERS-SEQNO = LV_SEQNO.
*생산오더
    GS_POP_ORDERS-AUFNR = LS_MAIN-AUFNR.
    __ALPHA_OUT : GS_POP_ORDERS-AUFNR.
*오더품목
    GS_POP_ORDERS-POSNR = LS_MAIN-POSNR.
*오더상태
    IF LS_MAIN-DLV = ABAP_TRUE.
      GS_POP_ORDERS-ORD_STAT = '작업완료'.
    ELSEIF LS_MAIN-PDLV = ABAP_TRUE.
      GS_POP_ORDERS-ORD_STAT = '작업중'.
    ELSEIF LS_MAIN-REL = ABAP_TRUE.
      GS_POP_ORDERS-ORD_STAT = '릴리즈'.
    ELSE.
      GS_POP_ORDERS-ORD_STAT = '생성'.
    ENDIF.

* pay off상태 확인
    CASE GS_POP_ORDERS-ORD_STAT.
      WHEN '릴리즈' OR '생성'.
        LV_OBJNR = 'OR' && LS_MAIN-AUFNR.
        CALL FUNCTION 'STATUS_TEXT_EDIT'
          EXPORTING
            FLG_USER_STAT    = 'X'
            OBJNR            = LV_OBJNR
            ONLY_ACTIVE      = 'X'
            SPRAS            = SY-LANGU
            BYPASS_BUFFER    = 'X'
          IMPORTING
            USER_LINE        = LV_USER_LINE
          EXCEPTIONS
            OBJECT_NOT_FOUND = 1
            OTHERS           = 2.

        FIND ALL OCCURRENCES OF 'PAYO' IN LV_USER_LINE MATCH COUNT FINAL(LV_LINE).
        IF LV_LINE > 0. " Patoff 상태일지 작업중으로 변경
          GS_POP_ORDERS-ORD_STAT = '작업중'.
        ENDIF.
    ENDCASE.

*자재코드
    GS_POP_ORDERS-MATNR = LS_MAIN-MATNR.
*색상
    READ TABLE GT_CVMVAL INTO DATA(LS_CVMVAL) WITH KEY MATNR = LS_MAIN-MATNR.
    IF SY-SUBRC EQ 0.
      IF LS_CVMVAL-COLORBASE IS NOT INITIAL.
        GS_POP_ORDERS-COLOR = LS_CVMVAL-COLORBASE.
      ENDIF.
    ENDIF.

*자재내역
    GS_POP_ORDERS-MAKTX = LS_MAIN-MAKTX.

*시작일(계획)
    GS_POP_ORDERS-GSTRP = LS_MAIN-GSTRP.
    GS_POP_ORDERS-GSUZP = LS_MAIN-GSUZP.
*종료일(계획)
    GS_POP_ORDERS-GLTRP = LS_MAIN-GLTRP.
    GS_POP_ORDERS-GLUZP = LS_MAIN-GLUZP.
*우선순위
    GS_POP_ORDERS-ZZPRIORITY = LS_MAIN-ZZPRIORITY.
* 표준조장
    GS_POP_ORDERS-INLENGTH = LS_MAIN-MILLCALENGTH.
* 작업지시B/N
    GS_POP_ORDERS-INFACTOR = LS_MAIN-MILLCAFACTOR.
*지시수량
    GS_POP_ORDERS-PSMNG = LS_MAIN-PSAMG + LS_MAIN-PSMNG.
*단위
    GS_POP_ORDERS-MEINS = LS_MAIN-GMEIN.
    GS_POP_ORDERS-MENGE01 = LS_MAIN-WEMNG.

    APPEND GS_POP_ORDERS TO GT_POP_ORDERS.

  ENDLOOP.

  CALL SCREEN '0500' STARTING AT 5 5 ENDING AT 140 10.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0500 .

  CREATE OBJECT GO_CONTAIN_0500
    EXPORTING
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 3000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.

* 그리드 적용
  CREATE OBJECT GO_GRID_0500
    EXPORTING
      I_PARENT      = GO_CONTAIN_0500
      I_APPL_EVENTS = ABAP_TRUE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0500 .

  CLEAR GS_LAYOUT_0500.
  GS_LAYOUT_0500-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0500-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0500-NO_ROWMARK = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0500 .

  REFRESH GT_EXCLUDE_0500.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0500
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
*& Form SET_FIELDCAT_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0500 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2280TOP'
      I_INTERNAL_TABNAME     = 'GS_POP_ORDERS'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0500.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0500[]
    TABLES
      IT_DATA         = GT_POP_ORDERS
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0500 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'SEQNO'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0500 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'SEQNO'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0500 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'ORD_STAT'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0500 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ORD_STAT'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더상태'(f18).
    <LS_FCAT>-COL_POS = 4.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-KEY = ABAP_TRUE.
    <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
  ENDIF.

  LOOP AT GT_FIELDCAT_0500 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'SEQNO' OR 'GSUZP' OR 'GLUZP'.
        <LS_FCAT>-NO_OUT = 'X'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더'(f17).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더품목'(f19).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ORD_STAT'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재코드'(f20).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'COLOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상'(f04).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재내역'(f05).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'GSTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시작일(계획)'(f23).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GLTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '종료일(계획)'(f24).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZZPRIORITY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '우선순위'(f25).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(f07).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INLENGTH'.
        IF GV_CHK_GO_JOJANG = ABAP_TRUE OR GV_CHK_GO_HALF = ABAP_TRUE.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '개별조장'(f37).
        ELSE.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '표준조장'(f08).
        ENDIF.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업지시B/N'(f28).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'PSMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업지시량'(f29).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고량'(f30).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0500 .

  REFRESH GT_SORT_0500.

  PERFORM SET_SORT_TAB TABLES GT_SORT_0500
                            USING : 1 'SEQNO' '' 'X' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0500_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0500_DISPLAY .

  CALL METHOD GO_GRID_0500->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0500
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0500
    CHANGING
      IT_OUTTAB            = GT_POP_ORDERS
      IT_SORT              = GT_SORT_0500
      IT_FIELDCATALOG      = GT_FIELDCAT_0500.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_ARBPL_MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RESET_ARBPL_MAIN .

  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LT_CHK_2070 TYPE TABLE OF ZGTPPT2270.
  DATA : LT_1010 TYPE TABLE OF ZGTPPT1010.

  SELECT DISTINCT * FROM ZGTPPT2270
    INTO TABLE @DATA(LT_2070)
   WHERE WERKS = @P_WERKS.

* 탐뎀 구성을 위한 기준정보 추출
  SELECT * FROM ZGTPPT1010
    INTO TABLE LT_1010
   WHERE MODULE_KIND = 'PP'
     AND CODEGRP = '1060'
     AND FLD_02 = P_WERKS
     AND FLD_07 = 'Y'.

  REFRESH GT_TANDEM_ARBPL.
  GT_TANDEM_ARBPL = VALUE #( FOR LW_1010 IN LT_1010 WHERE ( FLD_04 IS NOT INITIAL )
                                           ( SIGN = 'I' OPTION = 'EQ' LOW = LW_1010-FLD_04 ) ).

  IF P_WERKS = '6600' AND P_SPGCD = 'GO' AND P_GONGCD = 'COL'.

    REFRESH GT_REPLACE_ARBPL.
* 탐뎀 구성을 위한 기준정보 추출
    SELECT * FROM ZGTPPT1010
      INTO TABLE GT_REPLACE_ARBPL
     WHERE MODULE_KIND = 'PP'
       AND CODEGRP = '2130'
       AND FLD_01 = P_WERKS
       AND FLD_02 = P_SPGCD.

  ENDIF.

  LOOP AT GT_MAIN_DISP_100 INTO GS_MAIN_DISP_100.
    APPEND INITIAL LINE TO LT_MATNR ASSIGNING FIELD-SYMBOL(<LS_MATNR>).
    <LS_MATNR>-SIGN = 'I'.
    <LS_MATNR>-OPTION = 'EQ'.
    <LS_MATNR>-LOW = GS_MAIN_DISP_100-MATNR.

  ENDLOOP.

  LOOP AT GT_MAKE_PLAN INTO GS_MAKE_PLAN.
    APPEND INITIAL LINE TO LT_MATNR ASSIGNING <LS_MATNR>.
    <LS_MATNR>-SIGN = 'I'.
    <LS_MATNR>-OPTION = 'EQ'.
    <LS_MATNR>-LOW = GS_MAKE_PLAN-MATNR.
  ENDLOOP.

* 자재별 설비정보 추출
  IF LT_MATNR IS NOT INITIAL.
    REFRESH GT_ROUTING.
    SELECT * FROM ZGTCVROUTING
      INTO TABLE GT_ROUTING
     WHERE MATNR IN LT_MATNR
        AND WERKS = P_WERKS.

    REFRESH GT_ARBPL.
    LOOP AT GT_ROUTING INTO DATA(LS_ROUTING).
      APPEND INITIAL LINE TO GT_ARBPL ASSIGNING FIELD-SYMBOL(<LS_ARBPL>).
      <LS_ARBPL>-GONG_CD = LS_ROUTING-ARBPL+0(3).
      <LS_ARBPL>-ARBPL = LS_ROUTING-ARBPL.
      <LS_ARBPL>-KTEXT = LS_ROUTING-KTEXT.

      REFRESH LT_CHK_2070.
      LT_CHK_2070 = VALUE #( FOR LW_2070 IN LT_2070 WHERE ( ARBPL = LS_ROUTING-ARBPL )
                                      ( CORRESPONDING #( LW_2070 ) ) ).
      <LS_ARBPL>-EQUCD_CNT = LINES( LT_CHK_2070 ).
      IF <LS_ARBPL>-EQUCD_CNT = 0.
        <LS_ARBPL>-EQUCD_CNT = 1.
      ENDIF.

    ENDLOOP.

    SORT GT_ARBPL BY GONG_CD ARBPL.
    DELETE ADJACENT DUPLICATES FROM GT_ARBPL COMPARING GONG_CD ARBPL.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_DECISION_MATNR_TYPE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_DECISION_MATNR_TYPE .

  DATA : LT_GONG_MANAGE LIKE TABLE OF GS_GONG_MANAGE.
  DATA : LV_CHK_EXIST.

  SELECT * FROM ZGTCVMSTVAL
    INTO TABLE @DATA(LT_MSTVAL)
   WHERE WERKS = @P_WERKS
     AND SPG = @P_SPGCD
     AND MTREF = 'FERT'.

  SELECT 'I' AS SIGN, 'EQ' AS OPTION,  FLD_02 AS LOW
    FROM ZGTPPT1010
    INTO CORRESPONDING FIELDS OF TABLE @GT_EXCEPT_GONG_CD
   WHERE MODULE_KIND = 'PP'
      AND CODEGRP = '2020'
      AND FLD_01 = @P_WERKS.

  LOOP AT LT_MSTVAL INTO DATA(LS_MSTVAL).
    REFRESH LT_GONG_MANAGE.
    PERFORM GET_GONG_MANAGE TABLES LT_GONG_MANAGE USING LS_MSTVAL-MATNR.
    IF LT_GONG_MANAGE[] IS NOT INITIAL.
      LOOP AT LT_GONG_MANAGE INTO DATA(LS_GONG_MANAGE) WHERE GONG_CD IN GT_GONGCD.
        LV_CHK_EXIST = ABAP_TRUE.
        EXIT.
      ENDLOOP.
    ENDIF.

    IF LV_CHK_EXIST = ABAP_TRUE.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF LV_CHK_EXIST = ABAP_TRUE.
    GV_CHK_GO_JOJANG = ABAP_TRUE.
  ELSE.
    GV_CHK_GO_HALF = ABAP_TRUE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_GONG_MANAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_GONG_MANAGE
*&      --> LS_MSTVAL_MATNR
*&---------------------------------------------------------------------*
FORM GET_GONG_MANAGE  TABLES   PT_GONG_MANAGE STRUCTURE GS_GONG_MANAGE
                      USING    PV_MATNR TYPE MATNR..

  DATA : LV_GONG_SEQ TYPE ZEDT1010-GONG_SEQ.

  REFRESH PT_GONG_MANAGE[].

  SELECT DISTINCT B~GONG_SEQ, B~GONG_CD, B~AFT_GONG_SEQ, B~BESKZ, C~HALB_YN
    FROM ZGTCVMSTVAL AS A
    INNER JOIN ZEDT1010 AS B ON B~SUL_NO = A~PDCADESIGNNO
                                      AND B~REV_SEQ = A~PDCADESIGNREVNO
    LEFT JOIN ZEDT0140 AS C ON C~WERKS = A~WERKS
                                     AND C~GONG_CD = B~GONG_CD
    LEFT JOIN ZPPT0107 AS D ON D~WERKS = A~WERKS
                                     AND D~SPART = C~SPART
   WHERE A~MATNR = @PV_MATNR
     AND A~WERKS = @P_WERKS
    INTO TABLE @DATA(LT_GONG_MANAGE).

  SORT LT_GONG_MANAGE BY GONG_SEQ.
  READ TABLE LT_GONG_MANAGE INTO DATA(LS_CHK_GONG) INDEX 1.
  LV_GONG_SEQ = LS_CHK_GONG-GONG_SEQ.

  DO.
    READ TABLE LT_GONG_MANAGE INTO LS_CHK_GONG WITH KEY GONG_SEQ = LV_GONG_SEQ.
    IF SY-SUBRC EQ 0.
      IF LS_CHK_GONG-GONG_CD IN GT_EXCEPT_GONG_CD.
      ELSE.
        IF LS_CHK_GONG-AFT_GONG_SEQ = 0 OR
            ( LS_CHK_GONG-AFT_GONG_SEQ NE 0 AND
              LS_CHK_GONG-HALB_YN = ABAP_TRUE ).

          MOVE-CORRESPONDING LS_CHK_GONG TO PT_GONG_MANAGE.
          APPEND PT_GONG_MANAGE.
        ENDIF.
      ENDIF.
*      CASE LS_CHK_GONG-GONG_CD.
*        WHEN 'BWD' OR 'CNF'.
*
*        WHEN OTHERS.
*          IF LS_CHK_GONG-AFT_GONG_SEQ = 0 OR
*            ( LS_CHK_GONG-AFT_GONG_SEQ NE 0 AND
*              LS_CHK_GONG-HALB_YN = ABAP_TRUE ).
*
*            MOVE-CORRESPONDING LS_CHK_GONG TO PT_GONG_MANAGE.
*            APPEND PT_GONG_MANAGE.
*          ENDIF.
*      ENDCASE.
      LV_GONG_SEQ = LS_CHK_GONG-AFT_GONG_SEQ.
      IF LV_GONG_SEQ = '00'.
        EXIT.
      ENDIF.

    ELSE.
      EXIT.
    ENDIF.
  ENDDO.


  SORT PT_GONG_MANAGE BY GONG_SEQ.
  DELETE ADJACENT DUPLICATES FROM PT_GONG_MANAGE COMPARING GONG_SEQ.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_CHG_TIME_RATE_OP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MOD_CELLS_VALUE
*&      --> LS_MAIN_ARBPL
*&      --> LS_MAIN_ORDNR
*&      --> LS_MAIN_POSNR
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_CHG_TIME_RATE_OP  USING    PV_VALUE
                                  PV_ARBPL TYPE CRHD_V1-ARBPL
                                  PV_ORDNR
                                  PV_POSNR
                         CHANGING PV_CHK_ERR.

  DATA : LV_ORDNR TYPE ZGTPPT2010-ORDNR.
  DATA : LT_WORKTIME_DAY LIKE GT_WORKTIME_DAY.
  DATA : LV_CAL_WKCHH TYPE ZGTPPT2400-ZWKCHH.
  DATA : LV_LINES TYPE I.
  DATA : LV_INDEX TYPE I.
  DATA : LV_LAST_CURRENT_TIME TYPE ZGTPPT2400-ZWKCHH..

  DATA : BEGIN OF LS_CHG_AUFNR_INFOR,
           GSUZP TYPE AFKO-GSUZP,
           GLTRP TYPE AFKO-GLTRP,
           GLUZP TYPE AFKO-GLUZP,
         END OF LS_CHG_AUFNR_INFOR.

  DATA : LV_HOURS(2) TYPE N.
  DATA : LV_MINUTE(2) TYPE N.

  LV_ORDNR = PV_ORDNR.
  __ALPHA_INPUT LV_ORDNR.

  LT_WORKTIME_DAY = GT_WORKTIME_DAY.

  READ TABLE GT_WORKTIME_DAY ASSIGNING FIELD-SYMBOL(<LS_WORKTIME_DAY>) WITH KEY DATE = GV_SELECTED_DAY
                                                                                                                  ARBPL = PV_ARBPL.
  IF SY-SUBRC EQ 0.
    READ TABLE <LS_WORKTIME_DAY>-T_ORDNRS ASSIGNING FIELD-SYMBOL(<LS_ORDERS>) WITH KEY ORDNR = PV_ORDNR.
    IF SY-SUBRC EQ 0.
      CLEAR <LS_ORDERS>-RATE_OP.
      <LS_ORDERS>-RATE_OP = PV_VALUE.
    ENDIF.
  ENDIF.

  LV_LINES = LINES( <LS_WORKTIME_DAY>-T_ORDNRS ).

* 수량 반영후 체크
  CLEAR <LS_WORKTIME_DAY>-CURRENT_TIME.
  CLEAR LV_INDEX.
  LOOP AT <LS_WORKTIME_DAY>-T_ORDNRS ASSIGNING <LS_ORDERS>.
    ADD 1 TO LV_INDEX.
    IF LV_INDEX = LV_LINES.
      LV_LAST_CURRENT_TIME = <LS_ORDERS>-CURRENT_TIME.
    ENDIF.
* 가동율 포함하여 수량 계산
    <LS_ORDERS>-ZWKLTH = <LS_ORDERS>-ZWKLTH_B / <LS_ORDERS>-RATE_OP_B * <LS_ORDERS>-RATE_OP.
    <LS_ORDERS>-CURRENT_TIME = <LS_ORDERS>-ZWKLTH + <LS_ORDERS>-WKCHH.
    ADD <LS_ORDERS>-CURRENT_TIME TO <LS_WORKTIME_DAY>-CURRENT_TIME.

    IF <LS_WORKTIME_DAY>-CURRENT_TIME > 24.
      IF LV_INDEX = LV_LINES. " 마지막 라인의 경우 수량 계산 적용.
        LV_ORDNR = <LS_ORDERS>-ORDNR.
        __ALPHA_INPUT LV_ORDNR.

        READ TABLE GT_ORDSYVAL_PLANED ASSIGNING FIELD-SYMBOL(<LS_ORDSYVAL>) WITH KEY AUFNR = LV_ORDNR.
        IF SY-SUBRC EQ 0.
          LS_CHG_AUFNR_INFOR-GSUZP = <LS_ORDSYVAL>-GSUZP.
          LS_CHG_AUFNR_INFOR-GLTRP = <LS_ORDSYVAL>-GLTRP.
          LS_CHG_AUFNR_INFOR-GLUZP = <LS_ORDSYVAL>-GLUZP.

          LV_CAL_WKCHH = 24 - ( <LS_WORKTIME_DAY>-CURRENT_TIME - <LS_ORDERS>-CURRENT_TIME ) .

          LV_HOURS = TRUNC( LV_CAL_WKCHH ).
          LV_MINUTE = FRAC( LV_CAL_WKCHH ) * 60.
          LS_CHG_AUFNR_INFOR-GSUZP = LV_HOURS && LV_MINUTE && '00'.
* 종료시간
          LV_CAL_WKCHH = <LS_WORKTIME_DAY>-CURRENT_TIME.
          IF TRUNC( LV_LAST_CURRENT_TIME / 24 ) = TRUNC( LV_CAL_WKCHH / 24 ).
            DO.
              IF LV_CAL_WKCHH < 24.
                EXIT.
              ENDIF.
              LV_CAL_WKCHH = LV_CAL_WKCHH - 24.
            ENDDO.

            LV_HOURS = TRUNC( LV_CAL_WKCHH ).
            LV_MINUTE = FRAC( LV_CAL_WKCHH ) * 60.
            LS_CHG_AUFNR_INFOR-GLUZP = LV_HOURS && LV_MINUTE && '00'.
          ELSE.

            DO.
              IF LV_CAL_WKCHH < 24.
                EXIT.
              ENDIF.
              LS_CHG_AUFNR_INFOR-GLTRP = LS_CHG_AUFNR_INFOR-GLTRP + 1.
              LV_CAL_WKCHH = LV_CAL_WKCHH - 24.
            ENDDO.

            LV_HOURS = TRUNC( LV_CAL_WKCHH ).
            LV_MINUTE = FRAC( LV_CAL_WKCHH ) * 60.
            LS_CHG_AUFNR_INFOR-GLUZP = LV_HOURS && LV_MINUTE && '00'.
          ENDIF.

          LOOP AT GT_ORDSYVAL_PLANED ASSIGNING <LS_ORDSYVAL> WHERE AUFNR = LV_ORDNR.
            MOVE LS_CHG_AUFNR_INFOR-GSUZP TO <LS_ORDSYVAL>-GSUZP.
            MOVE LS_CHG_AUFNR_INFOR-GLTRP TO <LS_ORDSYVAL>-GLTRP.
            MOVE LS_CHG_AUFNR_INFOR-GLUZP TO <LS_ORDSYVAL>-GLUZP.

            READ TABLE GT_ORDSYVAL_CHG ASSIGNING FIELD-SYMBOL(<LS_ORDSYVAL_CHG>) WITH KEY AUFNR = <LS_ORDSYVAL>-AUFNR
                                                                                                                                     POSNR = <LS_ORDSYVAL>-POSNR.
            IF SY-SUBRC EQ 0.
              MOVE-CORRESPONDING <LS_ORDSYVAL> TO <LS_ORDSYVAL_CHG>.
            ELSE.
              APPEND INITIAL LINE TO GT_ORDSYVAL_CHG ASSIGNING <LS_ORDSYVAL_CHG>.
              MOVE-CORRESPONDING <LS_ORDSYVAL> TO <LS_ORDSYVAL_CHG>.
            ENDIF.

          ENDLOOP.
        ELSE.
          PV_CHK_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.

      ELSE.
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_ADD_GSMNG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_ADD_GSMNG .

  DATA : LT_MAIN LIKE GT_MAIN_DISP_100.
  DATA : LT_MODI_2330 TYPE TABLE OF ZGTPPT2330.
  DATA : LS_HEADERDATA TYPE BAPIPLAF_I1.
  DATA : LV_PLANNEDORDER TYPE BAPI_PLDORD-PLDORD_NUM.
  DATA : LS_RETURN TYPE BAPIRETURN1.
  DATA : LS_CHG_HEADER TYPE BAPIPLAF_I2.
  DATA : LS_CHG_HEADERX TYPE BAPIPLAF_I2X.

* 선택대상이 있는지 확인
  LT_MAIN = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP_100 WHERE ( CHECK = ABAP_TRUE )
                            ( CORRESPONDING #( LW_MAIN ) ) ).
  IF LT_MAIN[] IS INITIAL.
    MESSAGE S005 DISPLAY LIKE 'E' WITH '계획량 추가할 계획오더 범주를 선택해 주세요.'(e35).
    RETURN.
  ENDIF.

  REFRESH LT_MAIN.
  LT_MAIN = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP_100 WHERE ( CHECK = ABAP_TRUE
                                                                                 AND   GCATG = '계획오더' )
                            ( CORRESPONDING #( LW_MAIN ) ) ).
  IF LT_MAIN[] IS INITIAL.
    MESSAGE S005 DISPLAY LIKE 'E' WITH '계획오더 범주만 수량을 추가 할 수 있습니다.'(e36).
    RETURN.
  ENDIF.

  IF LINES( LT_MAIN ) > 1.
    MESSAGE S005 DISPLAY LIKE 'E' WITH '수량 추가는 한건씩 진행가능합니다.'(e37).
    RETURN.
  ENDIF.

* 화면데이터 구성
  CLEAR GS_HEADER_600.

  READ TABLE LT_MAIN INTO DATA(LS_MAIN) INDEX 1.
  READ TABLE GT_2330 INTO DATA(LS_2330) WITH KEY ZWKREQ = LS_MAIN-ZWKREQ.
  IF SY-SUBRC EQ 0.
    SELECT SINGLE MEINS FROM MARA
      INTO GS_HEADER_600-MEINS01
     WHERE MATNR = LS_2330-MATNR.

    GS_HEADER_600-MEINS03 = GS_HEADER_600-MEINS02 = GS_HEADER_600-MEINS01.

    IF LS_2330-PLNUM IS INITIAL.
      GS_HEADER_600-MENGE02 = 0.
    ELSE.
      SELECT SINGLE GSMNG FROM PLAF
        INTO GS_HEADER_600-MENGE02
        WHERE PLNUM = LS_2330-PLNUM.
    ENDIF.

    IF P_WERKS = '6600' AND P_SPGCD = 'GL'. " 표준조장 대상
      GS_HEADER_600-MENGE01 = GS_HEADER_600-MENGE03 = LS_2330-INLENGTH.
    ENDIF.


    CALL SCREEN '0600' STARTING AT 5 5 ENDING AT 80 8.

    IF GS_HEADER_600-CHK_OKAY = ABAP_TRUE.

      APPEND INITIAL LINE TO LT_MODI_2330 ASSIGNING FIELD-SYMBOL(<LS_MODI_2330>).
      MOVE-CORRESPONDING LS_2330 TO <LS_MODI_2330>.
      <LS_MODI_2330>-GSMNG = <LS_MODI_2330>-GSMNG + GS_HEADER_600-MENGE03.
      <LS_MODI_2330>-ZADDMNG = <LS_MODI_2330>-ZADDMNG + GS_HEADER_600-MENGE03.

      IF LS_2330-PLNUM IS INITIAL.

        CLEAR LS_HEADERDATA.
        CLEAR LV_PLANNEDORDER.
        CLEAR LS_RETURN.

        LS_HEADERDATA-PLDORD_PROFILE  = 'LA'.
        LS_HEADERDATA-ORDER_START_DATE = LS_2330-PSTTR.
        LS_HEADERDATA-ORDER_FIN_DATE = LS_2330-PEDTR.
        LS_HEADERDATA-MATERIAL = LS_2330-MATNR.
        LS_HEADERDATA-PLAN_PLANT = LS_2330-WERKS.
        LS_HEADERDATA-PROD_PLANT = LS_2330-WERKS.
        LS_HEADERDATA-FIRMING_IND = 'X'.
        LS_HEADERDATA-TOTAL_PLORD_QTY = GS_HEADER_600-MENGE02 + GS_HEADER_600-MENGE03.

        CLEAR : LV_PLANNEDORDER, LS_RETURN.
        CALL FUNCTION 'BAPI_PLANNEDORDER_CREATE'
          EXPORTING
            HEADERDATA   = LS_HEADERDATA
          IMPORTING
            RETURN       = LS_RETURN
            PLANNEDORDER = LV_PLANNEDORDER.

        IF LS_RETURN-TYPE NE 'S'. "성공건에 대해 후행 로직 진행
* 오류 발생으로 테이블 저장 실패
          MESSAGE S005 DISPLAY LIKE 'E' WITH '수량 추가 실패 - 계획오더 생성'(e40).
          RETURN.

        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = ABAP_TRUE.

          <LS_MODI_2330>-PLNUM = LV_PLANNEDORDER.
        ENDIF.

      ELSE.

        LV_PLANNEDORDER = LS_2330-PLNUM.
        LS_CHG_HEADER-TOTAL_PLORD_QTY = GS_HEADER_600-MENGE02 + GS_HEADER_600-MENGE03.
        LS_CHG_HEADERX-TOTAL_PLORD_QTY = ABAP_TRUE.

        CALL FUNCTION 'BAPI_PLANNEDORDER_CHANGE'
          EXPORTING
            PLANNEDORDER = LV_PLANNEDORDER
            HEADERDATA   = LS_CHG_HEADER
            HEADERDATAX  = LS_CHG_HEADERX
          IMPORTING
            RETURN       = LS_RETURN.

        IF LS_RETURN-TYPE NE 'S'. "성공건에 대해 후행 로직 진행
          MESSAGE S005 DISPLAY LIKE 'E' WITH '수량 추가 실패 - 계획오더 수정'(e41).
          RETURN.
        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = ABAP_TRUE.
        ENDIF.
      ENDIF.

      IF LT_MODI_2330[] IS NOT INITIAL.
        MODIFY ZGTPPT2330 FROM TABLE LT_MODI_2330.
        COMMIT WORK AND WAIT.
      ENDIF.

* 화면 초기화
      PERFORM GET_MAIN_PROD_ORDER_INFOR.

*    수립가능한 오더 세팅
      PERFORM MAKE_ORDER_INFO.
*    해당 설비별 순번별 수립된 데이터 세팅
      REFRESH GT_MAKE_PLAN.
      PERFORM MAKE_PLAN_DATA TABLES GT_ORDSYVAL_PLANED.
*    해당 설비별 순번별 일자별 수립된 작업 시간 관리
      REFRESH GT_WORKTIME_DAY.
      PERFORM SET_CRT_TIME_DAY.
      PERFORM RESET_ARBPL_MAIN.
*    선댁된 일자로 설비별 순번별 수립된 데이터 세팅
      REFRESH GT_MAIN_DISP_101.
      PERFORM MAKE_PLAN_DISP_DATA TABLES GT_ORDSYVAL_PLANED.

      PERFORM SET_TOTAL_DISP_TABLE.

*    선댁된 일자로 설비별 순번별 수립된 데이터 세팅
      REFRESH GT_MAIN_DISP_101.
      PERFORM MAKE_PLAN_DISP_DATA TABLES GT_ORDSYVAL_PLANED.

      PERFORM SET_TOTAL_DISP_TABLE.

      PERFORM REFRESH_GRID USING GO_GRID_0100.
      PERFORM REFRESH_GRID USING GO_GRID_0101.

      MESSAGE S006 WITH '계획량 추가 되었습니다.'(e42).

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_ADD_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_ADD_PROC .

  DATA : LV_MENGE TYPE MENGE_D.
  DATA : LV_MENGE2 TYPE MENGE_D.

  IF GS_HEADER_600-MENGE03 = 0.
    MESSAGE I003 WITH '추가량이 입력되지 않았습니다.'(e38).
    RETURN.
  ENDIF.

  IF P_WERKS = '6600' AND P_SPGCD = 'GL'.
    LV_MENGE = GS_HEADER_600-MENGE03 / GS_HEADER_600-MENGE01.
    LV_MENGE2 = FRAC( LV_MENGE ).
    IF LV_MENGE2 > 0.
      MESSAGE I003 WITH '표준 조장 설정 공정으로 표준 조장 배수로 입력 할 수 있습니다.'(e39).
      RETURN.
    ENDIF.
  ENDIF.

  GS_HEADER_600-CHK_OKAY = ABAP_TRUE.

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_REPLACE_DRUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_REPLACE_DRUM .

  DATA : LT_MAIN LIKE GT_MAIN_DISP_101.
  DATA : LT_AUFNR TYPE RANGE OF  AUFNR.
  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LT_MATNR_PRD TYPE RANGE OF MATNR.


  IF NOT LINE_EXISTS( GT_MAIN_DISP_101[ CHECK = ABAP_TRUE ] ).
    MESSAGE S005 DISPLAY LIKE 'E' WITH '드럼 재지정 할 대상을 선택하세요.'(E31).
    RETURN.
  ENDIF.

* 선택대상이 있는지 확인
  LT_MAIN = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP_101 WHERE ( CHECK = ABAP_TRUE
                                                       AND   ( ORD_STAT = '생성'
                                                        OR      ORD_STAT = '릴리즈' ) )
                            ( CORRESPONDING #( LW_MAIN ) ) ).
  IF LT_MAIN[] IS INITIAL.
    MESSAGE S005 DISPLAY LIKE 'E' WITH '생산중인 오더는 드럼재지정 할 수 없습니다.'(E32).
    RETURN.
  ENDIF.

  LT_MATNR = VALUE #( FOR LW_MAIN IN LT_MAIN WHERE ( MATNR IS NOT INITIAL )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_MAIN-MATNR ) ).

  IF LT_MATNR IS NOT INITIAL.
    SELECT DISTINCT 'I' AS SIGN, 'EQ' AS OPTION, A~MATNR AS LOW
      FROM MARA AS A
      INNER JOIN T134 AS B ON B~MTART = A~MTART
      INTO CORRESPONDING FIELDS OF TABLE @LT_MATNR_PRD
     WHERE A~MATNR IN @LT_MATNR
       AND A~LVORM = ' '
       AND B~MTREF = 'FERT'.

    IF LT_MATNR_PRD IS NOT INITIAL. " 완제품 대상이 없다면 종료
      DELETE LT_MAIN WHERE MATNR NOT IN LT_MATNR_PRD.
    ELSE.
      REFRESH LT_MAIN.
    ENDIF.

    IF LT_MAIN[] IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '제품 생산오더만 드럼재지정 가능합니다.'(E33).
      RETURN.
    ENDIF.
  ENDIF.

  LOOP AT LT_MAIN INTO DATA(LS_MAIN).
    APPEND INITIAL LINE TO LT_AUFNR ASSIGNING FIELD-SYMBOL(<LS_AUFNR>).
    <LS_AUFNR>-SIGN = 'I'.
    <LS_AUFNR>-OPTION = 'EQ'.
    <LS_AUFNR>-LOW = LS_MAIN-ORDNR.
    __ALPHA_INPUT <LS_AUFNR>-LOW.
  ENDLOOP.

  SORT LT_AUFNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_AUFNR COMPARING LOW.

  SUBMIT ZGTPPR2330 VIA SELECTION-SCREEN
                 WITH P_SLSORD = ' '
                 WITH P_PRDORD = 'X'
                 WITH S_AUFNR IN LT_AUFNR
                 AND RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GO_TEXT_700
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GO_TEXT_700 .

  CREATE OBJECT GO_CONTAINER_700
    EXPORTING
      CONTAINER_NAME = 'CONTAINER_700'.

  CREATE OBJECT GO_TEXT_700
    EXPORTING
      WORDWRAP_MODE          = 2
      MAX_NUMBER_CHARS       = 9999                         " maximum number of characters insertable into editor control
      PARENT                 = GO_CONTAINER_700                        " Parent Container
    EXCEPTIONS
      ERROR_CNTL_CREATE      = 1                        " Error while performing creation of TextEdit control!
      ERROR_CNTL_INIT        = 2                        " Error while initializing TextEdit control!
      ERROR_CNTL_LINK        = 3                        " Error while linking TextEdit control!
      ERROR_DP_CREATE        = 4                        " Error while creating DataProvider control!
      GUI_TYPE_NOT_SUPPORTED = 5                        " This type of GUI is not supported!
      OTHERS                 = 6.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_AND_CREATE_700
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_AND_CREATE_700 .

  DATA : LV_MESSAGE(100).
  DATA : LV_CHK_ERR.

*  필드 빈값 체크
  CLEAR LV_MESSAGE.
  PERFORM SCREEN_700_CHK_INIT CHANGING LV_MESSAGE.
  IF LV_MESSAGE IS NOT INITIAL.
    MESSAGE I003 WITH LV_MESSAGE.
    RETURN.
  ENDIF.

  PERFORM SCREEN_700_CHK_VALIDATION  CHANGING LV_MESSAGE.
  IF LV_MESSAGE IS NOT INITIAL.
    MESSAGE I003 WITH LV_MESSAGE.
    RETURN.
  ENDIF.

  PERFORM CREATE_ORDERS_MTO CHANGING LV_CHK_ERR.
  IF LV_CHK_ERR IS NOT INITIAL.
    GV_CHK_CREATE = 'E'. " 실패
  ELSE.
    GV_CHK_CREATE = 'S'. " 성공
  ENDIF.

  GO_CONTAINER_700->FREE( ).
  FREE : GO_CONTAINER_700, GO_TEXT_700.
  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCREEN_700_CHK_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM SCREEN_700_CHK_INIT  CHANGING PV_MESSAGE.


  IF GS_MAKE_ORDER2-GSTRP IS INITIAL OR GS_MAKE_ORDER2-GSTRP = '00000000'.
    PV_MESSAGE = TEXT-E04.
  ENDIF.

  IF GS_MAKE_ORDER2-GLTRP IS INITIAL OR GS_MAKE_ORDER2-GLTRP = '00000000'.
    PV_MESSAGE = TEXT-E05.
  ENDIF.

  IF GS_MAKE_ORDER2-INFACTOR2 IS INITIAL OR GS_MAKE_ORDER2-INFACTOR2 = 0.
    PV_MESSAGE = TEXT-E07.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCREEN_700_CHK_VALIDATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM SCREEN_700_CHK_VALIDATION  CHANGING PV_MESSAGE.

  IF GS_MAKE_ORDER2-INFACTOR < GS_MAKE_ORDER2-INFACTOR.
    PV_MESSAGE = TEXT-E45.
    RETURN.
  ENDIF.

  IF GS_MAKE_ORDER2-GSTRP > GS_MAKE_ORDER2-GLTRP.
    PV_MESSAGE = TEXT-E11.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ORDERS_MTO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CREATE_ORDERS_MTO  CHANGING PV_CHK_ERR.

  DATA : LT_PRD_ORDERS TYPE TB_BAPI_ORDER_KEY.
  DATA : LS_ORDER TYPE BAPI_PP_ORDER_CREATE.
  DATA: LS_RETURN TYPE BAPIRET2.
  DATA : LV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.
  DATA: LT_TLINE LIKE TABLE OF TLINE.

  CALL METHOD GO_TEXT_700->GET_TEXT_AS_R3TABLE( EXPORTING ONLY_WHEN_MODIFIED = ' ' IMPORTING TABLE = GT_TEXT ).

  LOOP AT GT_TEXT INTO DATA(LS_TEXT).
    APPEND INITIAL LINE TO LT_TLINE ASSIGNING FIELD-SYMBOL(<LS_TLINE>).
    <LS_TLINE>-TDLINE = LS_TEXT.
  ENDLOOP.

  CLEAR : LS_ORDER, LS_RETURN, LV_ORDER_NUMBER.
*  오더 생성
  LS_ORDER-MATERIAL = GS_MAKE_ORDER2-MATNR.
  LS_ORDER-PLANT = P_WERKS.
  LS_ORDER-ORDER_TYPE = 'PP01'.
  LS_ORDER-BASIC_START_DATE = GS_MAKE_ORDER2-GSTRP.
  LS_ORDER-BASIC_END_DATE = GS_MAKE_ORDER2-GLTRP.
  LS_ORDER-QUANTITY = GS_MAKE_ORDER2-INLENGTH * GS_MAKE_ORDER2-INFACTOR2.
  LS_ORDER-BASIC_SCHEDULING_TYPE = '3'.
  LS_ORDER-SALES_ORDER = GS_MAKE_ORDER2-ORDNO.
  LS_ORDER-SALES_ORDER_ITEM = GS_MAKE_ORDER2-POSNR.

  CALL FUNCTION 'BAPI_PRODORD_CREATE'
    EXPORTING
      ORDERDATA    = LS_ORDER
    IMPORTING
      RETURN       = LS_RETURN
      ORDER_NUMBER = LV_ORDER_NUMBER.

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

    APPEND INITIAL LINE TO LT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDER>).
    <LS_ORDER>-ORDER_NUMBER =  LV_ORDER_NUMBER.

    READ TABLE GT_2330 INTO DATA(LS_CHK_2330) WITH KEY DMORD = GS_MAKE_ORDER2-ORDNO
                                                       DMLINE = GS_MAKE_ORDER2-POSNR.
    IF SY-SUBRC EQ 0.
      READ TABLE GT_2340 INTO DATA(LS_2340_CHK) WITH KEY ZWKREQ = LS_CHK_2330-ZWKREQ.
      IF SY-SUBRC EQ 0.
        DATA(LV_ZZORIGN)  = LS_2340_CHK-ORDNR.
        __ALPHA_OUT LV_ZZORIGN.
        UPDATE AUFK SET ZZORIGIN = LV_ZZORIGN
          WHERE AUFNR = LV_ORDER_NUMBER.
      ENDIF.
    ENDIF.
  ELSE.
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

* 오더 생산메모 입력
  IF LT_TLINE[] IS NOT INITIAL.
    PERFORM SAVE_TEXT_ORDER TABLES LT_PRD_ORDERS LT_TLINE.
  ENDIF.

  DATA : LT_ZPPTC002 TYPE TABLE OF ZPPTC002.
  LOOP AT LT_PRD_ORDERS INTO DATA(LS_PRD_ORDERS).
    APPEND INITIAL LINE TO LT_ZPPTC002 ASSIGNING FIELD-SYMBOL(<LS_SAVE_DATA>).
    <LS_SAVE_DATA>-AUFNR = LS_PRD_ORDERS-ORDER_NUMBER.
    <LS_SAVE_DATA>-POSNR = '0001'.
    <LS_SAVE_DATA>-PSAMG = 0.
  ENDLOOP.

  IF LT_ZPPTC002[] IS NOT INITIAL.
    MODIFY ZPPTC002 FROM TABLE LT_ZPPTC002.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

ENDFORM.
