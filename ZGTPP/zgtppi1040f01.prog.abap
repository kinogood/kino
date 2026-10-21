*&---------------------------------------------------------------------*
*& Include          ZGTPPI1040F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

  IF GT_TARGET[] IS INITIAL.

    SELECT * FROM ZGTPPT1010
      INTO CORRESPONDING FIELDS OF TABLE GT_TARGET
     WHERE MODULE_KIND = 'PP'
        AND CODEGRP = '0010'.

  ENDIF.

*  IF S_DATE IS INITIAL.
*    S_DATE-LOW = SY-DATUM - 1.
*    S_DATE-HIGH = SY-DATUM - 1.
*    APPEND S_DATE.
*  ENDIF.

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
    IF P_SEND = ABAP_TRUE.
      CASE SCREEN-NAME.
        WHEN 'P_TARGET' .
          SCREEN-REQUIRED = 2.
          MODIFY SCREEN.
      ENDCASE.

      IF SCREEN-GROUP1 = 'S1'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSE.
      CASE SCREEN-NAME.
        WHEN 'S_TARGET-LOW' OR 'S_IFDATE-LOW'.
          SCREEN-REQUIRED = 2.
          MODIFY SCREEN.
      ENDCASE.

      IF SCREEN-GROUP1 = 'S2'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_TARGET
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_TARGET  USING  PV_DYNPROFLD TYPE HELP_INFO-DYNPROFLD .

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LV_OFFSET(6) TYPE N.
  DATA : LO_FLIEF TYPE REF TO DATA.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

  FREE LO_FLIEF.
  CREATE DATA LO_FLIEF LIKE GS_TARGET.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).

    CASE <LS_FIELD_TAB>-FIELDNAME.
      WHEN 'FLD_01'.
        <LS_FIELD_TAB>-REPTEXT  = '시스템 ID'.
      WHEN 'FLD_02'.
        <LS_FIELD_TAB>-REPTEXT  = '시스템 내역'.
      WHEN 'FLD_03'.
        <LS_FIELD_TAB>-REPTEXT  = '플랜트'.
      WHEN 'FLD_04'.
        <LS_FIELD_TAB>-REPTEXT  = 'SPG(사업부)'.
    ENDCASE.

    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'FLD_01'
      DYNPROFIELD     = PV_DYNPROFLD           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '송신대상 시스템 조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = GT_TARGET                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.

    REFRESH LT_DYNPFIELDS.
    PERFORM GET_STEPL USING LV_LINE.

*      시뮬레이션 번호
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
    <LS_DYNPFIELDS>-FIELDNAME = PV_DYNPROFLD.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_RETURN_TAB-FIELDVAL.

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
*& Form CHK_VALIDATION_P_TARGET
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_VALIDATION_P_TARGET .

  IF P_SEND = ABAP_TRUE AND P_TARGET IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '필수필드 "송신대상 시스템" 에 입력하십시오.'.
    LEAVE LIST-PROCESSING.
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

  IF P_SEND EQ ABAP_TRUE.
    PERFORM GET_TABLE_RECORD.
  ELSE.
    PERFORM GET_HISTORY_OF_SEND.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESSING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESSING .

  DATA : LV_LINES_C TYPE C LENGTH 10.

  IF P_SEND EQ ABAP_TRUE.
    IF P_BATCH EQ ABAP_TRUE. " 배치수행, 화면 출력없이 전송
      PERFORM CALL_RFC TABLES GT_SEND.

      IF LINE_EXISTS( GT_SEND[ ZSTAT = '00' ] ) OR
          LINE_EXISTS( GT_SEND[ ZSTAT = '0' ] ). " 성공시
        DATA(LV_INDEX) = LINES( GT_SEND ) .
        LV_LINES_C = LV_INDEX.
        CONDENSE LV_LINES_C.
        MESSAGE S000 WITH LV_LINES_C '건의 코드마스터(Key Data)가 전송되었습니다.'.
      ELSE.
        MESSAGE S003 WITH '전송 데이터가 없습니다.' DISPLAY LIKE 'E'.
        "전송 데이터가 없습니다.
      ENDIF.

    ELSE. " 화면 구성 및 화면 출력
      MOVE-CORRESPONDING GT_SEND TO GT_OT_ITAB.
      PERFORM SET_DISP_DATA.
      CLEAR LV_INDEX.
      LV_INDEX =  LINES( GT_OT_ITAB ).
      LV_LINES_C = LV_INDEX.
      CONDENSE LV_LINES_C.

      MESSAGE S002 WITH LV_LINES_C.

      CALL SCREEN 0100.
    ENDIF.

  ELSE. " 화면데이터 구성후 화면출력
    PERFORM SET_DISP_DATA2.
    CALL SCREEN 0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_OBJCT_TYPE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_OBJCT_TYPE  USING    PV_DYNPROFLD TYPE HELP_INFO-DYNPROFLD .

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LV_OFFSET(6) TYPE N.
  DATA : LO_FLIEF TYPE REF TO DATA.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

  REFRESH GT_OBJTY.

  PERFORM GET_DYNP_VALUE USING 'P_TARGET'.

  IF P_TARGET IS NOT INITIAL.
    SELECT * FROM ZGTPPT1010
      INTO CORRESPONDING FIELDS OF TABLE GT_OBJTY
     WHERE MODULE_KIND = 'PP'
        AND CODEGRP = '1020'
        AND FLD_01 = P_TARGET
        AND FLD_04 = 'Y'.
  ELSE.
    SELECT * FROM ZGTPPT1010
      INTO CORRESPONDING FIELDS OF TABLE GT_OBJTY
     WHERE MODULE_KIND = 'PP'
        AND CODEGRP = '1020'
        AND FLD_04 = 'Y'.
  ENDIF.

  FREE LO_FLIEF.
  CREATE DATA LO_FLIEF LIKE GS_OBJTY.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).

    CASE <LS_FIELD_TAB>-FIELDNAME.
      WHEN 'FLD_01'.
        <LS_FIELD_TAB>-REPTEXT  = '송신 대상 시스템'.
      WHEN 'FLD_02'.
        <LS_FIELD_TAB>-REPTEXT  = '오브젝트 유형'.
      WHEN 'FLD_03'.
        <LS_FIELD_TAB>-REPTEXT  = '유형 내역'.
      WHEN 'FLD_04'.
        <LS_FIELD_TAB>-REPTEXT  = '활성화 여부'.
    ENDCASE.

    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'FLD_02'
      DYNPROFIELD     = PV_DYNPROFLD           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '오브젝트 유형조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = GT_OBJTY
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.

    REFRESH LT_DYNPFIELDS.
    PERFORM GET_STEPL USING LV_LINE.

*      시뮬레이션 번호
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
    <LS_DYNPFIELDS>-FIELDNAME = PV_DYNPROFLD.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_RETURN_TAB-FIELDVAL.

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
*& Form GET_DYNP_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_DYNP_VALUE  USING    PV_FIELDNAME TYPE DYNPREAD-FIELDNAME.

  ASSIGN (PV_FIELDNAME) TO FIELD-SYMBOL(<LV_VALUE>).

  CALL FUNCTION 'GET_DYNP_VALUE'
    EXPORTING
      I_FIELD = PV_FIELDNAME
      I_REPID = SY-CPROG
      I_DYNNR = SY-DYNNR
    CHANGING
      O_VALUE = <LV_VALUE>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_VALIDATION_S_OBGTY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_VALIDATION_S_OBGTY .

  SELECT * FROM ZGTPPT1010
    INTO CORRESPONDING FIELDS OF TABLE GT_OBJTY
   WHERE MODULE_KIND = 'PP'
      AND CODEGRP = '1020'
      AND FLD_01 = P_TARGET
      AND FLD_02 IN S_OBGTY
      AND FLD_04 = 'Y'.
  IF SY-SUBRC NE 0.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '해당 송신시스템에 등록된 송신오브젝트 유형이 없습니다.'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_SEND
*&---------------------------------------------------------------------*
FORM GET_WERKS.

  LOOP AT GT_TARGET INTO GS_TARGET WHERE FLD_01 = P_TARGET.
    APPEND INITIAL LINE TO GT_WERKS ASSIGNING FIELD-SYMBOL(<LS_WERKS>).
    <LS_WERKS>-SIGN = 'I'.
    <LS_WERKS>-OPTION = 'EQ'.
    <LS_WERKS>-LOW = GS_TARGET-FLD_03.
  ENDLOOP.

  SORT GT_WERKS BY LOW.
  DELETE ADJACENT DUPLICATES FROM GT_WERKS COMPARING LOW.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_SEND
*&---------------------------------------------------------------------*
FORM SET_WERKS  TABLES PT_SEND STRUCTURE ZGTPPT1070
                     USING PV_OBJ_TYPE.


  DATA : LS_SEND TYPE ZGTPPT1070.
  DATA : LV_IDX(4) TYPE N.

  SELECT DISTINCT WERKS, NAME1 INTO TABLE @DATA(LT_T001W)
    FROM T001W
   WHERE WERKS IN @GT_WERKS.

  READ TABLE GT_OBJTY INTO GS_OBJTY WITH KEY FLD_01 = P_TARGET
                                                              FLD_02 = PV_OBJ_TYPE.

  LOOP AT LT_T001W INTO DATA(LS_T001W).
    ADD 1 TO LV_IDX.
    CLEAR LS_SEND.
    LS_SEND-SEQ_NO = LV_IDX.
    LS_SEND-OBJ_TYPE = PV_OBJ_TYPE.
    LS_SEND-OBJ_DESC = GS_OBJTY-FLD_03.
    LS_SEND-WERKS = LS_T001W-WERKS.
    LS_SEND-FLD_01 = LS_T001W-WERKS.
    LS_SEND-FLD_02 = LS_T001W-NAME1.

    APPEND LS_SEND TO PT_SEND.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LGORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      <-- LT_SEND
*&---------------------------------------------------------------------*
FORM SET_LGORT  TABLES PT_SEND STRUCTURE ZGTPPT1070
                     USING PV_OBJ_TYPE.

  DATA : LS_SEND TYPE ZGTPPT1070.
  DATA : LV_IDX(4) TYPE N.

  SELECT DISTINCT WERKS, LGORT, LGOBE INTO TABLE @DATA(LT_T001L)
    FROM T001L
   WHERE WERKS IN @GT_WERKS.

  SORT LT_T001L BY WERKS LGORT.

  READ TABLE GT_OBJTY INTO GS_OBJTY WITH KEY FLD_01 = P_TARGET
                                                              FLD_02 = PV_OBJ_TYPE.

  LOOP AT GT_WERKS INTO DATA(LS_WERKS).
    CLEAR LV_IDX.
    LOOP AT LT_T001L INTO DATA(LS_T001L) WHERE WERKS = LS_WERKS-LOW.
      ADD 1 TO LV_IDX.
      CLEAR LS_SEND.
      LS_SEND-SEQ_NO = LV_IDX.
      LS_SEND-OBJ_TYPE = PV_OBJ_TYPE.
      LS_SEND-OBJ_DESC = GS_OBJTY-FLD_03.
      LS_SEND-WERKS = LS_T001L-WERKS.
      LS_SEND-FLD_01 = LS_T001L-LGORT.
      LS_SEND-FLD_02 = LS_T001L-LGOBE.

      APPEND LS_SEND TO PT_SEND.

    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MTART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SEND
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_MTART  TABLES PT_SEND STRUCTURE ZGTPPT1070
                     USING PV_OBJ_TYPE.

  DATA : LS_SEND TYPE ZGTPPT1070.
  DATA : LV_IDX(4) TYPE N.

  SELECT DISTINCT A~MTART, B~MTBEZ, A~MTREF INTO TABLE @DATA(LT_T134)
    FROM T134 AS A
    INNER JOIN T134T AS B ON B~MTART = A~MTART
    WHERE B~SPRAS = @SY-LANGU.

  SORT LT_T134 BY MTART.

  READ TABLE GT_OBJTY INTO GS_OBJTY WITH KEY FLD_01 = P_TARGET
                                                              FLD_02 = PV_OBJ_TYPE.


  LOOP AT LT_T134 INTO DATA(LS_T134).
    ADD 1 TO LV_IDX.
    CLEAR LS_SEND.
    LS_SEND-SEQ_NO = LV_IDX.
    LS_SEND-OBJ_TYPE = PV_OBJ_TYPE.
    LS_SEND-OBJ_DESC = GS_OBJTY-FLD_03.
    LS_SEND-FLD_01 = LS_T134-MTART.
    LS_SEND-FLD_02 = LS_T134-MTBEZ.
    LS_SEND-FLD_03 = LS_T134-MTREF.

    APPEND LS_SEND TO PT_SEND.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_AUART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SEND
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_AUART  TABLES   PT_SEND STRUCTURE ZGTPPT1070
                     USING PV_OBJ_TYPE.

  DATA : LS_SEND TYPE ZGTPPT1070.
  DATA : LV_IDX(4) TYPE N.

  SELECT DISTINCT * FROM ZGTPPT1010
    INTO TABLE @DATA(LT_1010)
   WHERE MODULE_KIND = 'PP'
      AND CODEGRP = '1050'.

  SORT LT_1010 BY CODEID.

  READ TABLE GT_OBJTY INTO GS_OBJTY WITH KEY FLD_01 = P_TARGET
                                                              FLD_02 = PV_OBJ_TYPE.


  LOOP AT LT_1010 INTO DATA(LS_1010).
    ADD 1 TO LV_IDX.
    CLEAR LS_SEND.
    LS_SEND-SEQ_NO = LV_IDX.
    LS_SEND-OBJ_TYPE = PV_OBJ_TYPE.
    LS_SEND-OBJ_DESC = GS_OBJTY-FLD_03.
    LS_SEND-FLD_01 = LS_1010-FLD_01.
    LS_SEND-FLD_02 = LS_1010-FLD_02.

    APPEND LS_SEND TO PT_SEND.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SPGCD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SEND
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SPGCD  TABLES   PT_SEND STRUCTURE ZGTPPT1070
                     USING PV_OBJ_TYPE.

  DATA : LS_SEND TYPE ZGTPPT1070.
  DATA : LV_IDX(4) TYPE N.

  SELECT DISTINCT WERKS, SPGCD, DESCR, SPART INTO TABLE @DATA(LT_ZPPT0107)
    FROM ZPPT0107
   WHERE WERKS IN @GT_WERKS
     AND DESCR NE ' '.

  SORT LT_ZPPT0107 BY WERKS SPGCD.

  READ TABLE GT_OBJTY INTO GS_OBJTY WITH KEY FLD_01 = P_TARGET
                                                              FLD_02 = PV_OBJ_TYPE.

  LOOP AT GT_WERKS INTO DATA(LS_WERKS).
    CLEAR LV_IDX.
    LOOP AT LT_ZPPT0107 INTO DATA(LS_ZPPT0107) WHERE WERKS = LS_WERKS-LOW.
      ADD 1 TO LV_IDX.
      CLEAR LS_SEND.
      LS_SEND-SEQ_NO = LV_IDX.
      LS_SEND-OBJ_TYPE = PV_OBJ_TYPE.
      LS_SEND-OBJ_DESC = GS_OBJTY-FLD_03.
      LS_SEND-WERKS = LS_ZPPT0107-WERKS.
      LS_SEND-FLD_01 = LS_ZPPT0107-SPGCD.
      LS_SEND-FLD_02 = LS_ZPPT0107-DESCR.
      LS_SEND-FLD_03 = LS_ZPPT0107-SPART.

      APPEND LS_SEND TO PT_SEND.

    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FEVOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SEND
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FEVOR  TABLES   PT_SEND STRUCTURE ZGTPPT1070
                     USING PV_OBJ_TYPE.

  DATA : LS_SEND TYPE ZGTPPT1070.
  DATA : LV_IDX(4) TYPE N.

  SELECT DISTINCT WERKS, FEVOR, TXT INTO TABLE @DATA(LT_T024F)
    FROM T024F
   WHERE WERKS IN @GT_WERKS.

  SORT LT_T024F BY WERKS FEVOR.

  READ TABLE GT_OBJTY INTO GS_OBJTY WITH KEY FLD_01 = P_TARGET
                                                              FLD_02 = PV_OBJ_TYPE.

  LOOP AT GT_WERKS INTO DATA(LS_WERKS).
    CLEAR LV_IDX.
    LOOP AT LT_T024F INTO DATA(LS_T024F) WHERE WERKS = LS_WERKS-LOW.
      ADD 1 TO LV_IDX.
      CLEAR LS_SEND.
      LS_SEND-SEQ_NO = LV_IDX.
      LS_SEND-OBJ_TYPE = PV_OBJ_TYPE.
      LS_SEND-OBJ_DESC = GS_OBJTY-FLD_03.
      LS_SEND-WERKS = LS_T024F-WERKS.
      LS_SEND-FLD_01 = LS_T024F-FEVOR.
      LS_SEND-FLD_02 = LS_T024F-TXT.

      APPEND LS_SEND TO PT_SEND.

    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISPO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SEND
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_DISPO  TABLES   PT_SEND STRUCTURE ZGTPPT1070
                     USING PV_OBJ_TYPE.

  DATA : LS_SEND TYPE ZGTPPT1070.
  DATA : LV_IDX(4) TYPE N.

  SELECT DISTINCT WERKS, DISPO, DSNAM INTO TABLE @DATA(LT_T024D)
    FROM T024D
   WHERE WERKS IN @GT_WERKS.

  SORT LT_T024D BY WERKS DISPO.

  READ TABLE GT_OBJTY INTO GS_OBJTY WITH KEY FLD_01 = P_TARGET
                                                              FLD_02 = PV_OBJ_TYPE.

  LOOP AT GT_WERKS INTO DATA(LS_WERKS).
    CLEAR LV_IDX.
    LOOP AT LT_T024D INTO DATA(LS_T024D) WHERE WERKS = LS_WERKS-LOW.
      ADD 1 TO LV_IDX.
      CLEAR LS_SEND.
      LS_SEND-SEQ_NO = LV_IDX.
      LS_SEND-OBJ_TYPE = PV_OBJ_TYPE.
      LS_SEND-OBJ_DESC = GS_OBJTY-FLD_03.
      LS_SEND-WERKS = LS_T024D-WERKS.
      LS_SEND-FLD_01 = LS_T024D-DISPO.
      LS_SEND-FLD_02 = LS_T024D-DSNAM.

      APPEND LS_SEND TO PT_SEND.

    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GONG_CD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SEND
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_GONG_CD  TABLES   PT_SEND STRUCTURE ZGTPPT1070
                     USING PV_OBJ_TYPE.

  DATA : LS_SEND TYPE ZGTPPT1070.
  DATA : LV_IDX(4) TYPE N.

  SELECT DISTINCT A~BWKEY AS WERKS, B~SPART, D~VTEXT, B~GONG_CD, C~GONG_NM
    INTO TABLE @DATA(LT_GONG_CD)
    FROM T001K AS A
    INNER JOIN ZEDT0010 AS B ON B~BUKRS = A~BUKRS
    INNER JOIN ZEDT0011 AS C ON C~GONG_CD = B~GONG_CD
    INNER JOIN TSPAT AS D ON D~SPART = B~SPART
    INNER JOIN ZPPT0107 AS E ON E~SPART = B~SPART
                                     AND E~WERKS = A~BWKEY
   WHERE A~BWKEY IN @GT_WERKS
      AND D~SPRAS = @SY-LANGU.


  SORT LT_GONG_CD BY WERKS SPART GONG_CD.

  READ TABLE GT_OBJTY INTO GS_OBJTY WITH KEY FLD_01 = P_TARGET
                                                              FLD_02 = PV_OBJ_TYPE.

  LOOP AT GT_WERKS INTO DATA(LS_WERKS).
    CLEAR LV_IDX.
    LOOP AT LT_GONG_CD INTO DATA(LS_GONG_CD) WHERE WERKS = LS_WERKS-LOW.
      ADD 1 TO LV_IDX.
      CLEAR LS_SEND.
      LS_SEND-SEQ_NO = LV_IDX.
      LS_SEND-OBJ_TYPE = PV_OBJ_TYPE.
      LS_SEND-OBJ_DESC = GS_OBJTY-FLD_03.
      LS_SEND-WERKS = LS_GONG_CD-WERKS.
      LS_SEND-FLD_01 = LS_GONG_CD-SPART.
      LS_SEND-FLD_02 = LS_GONG_CD-VTEXT.
      LS_SEND-FLD_03 = LS_GONG_CD-GONG_CD.
      LS_SEND-FLD_04 = LS_GONG_CD-GONG_NM.

      APPEND LS_SEND TO PT_SEND.

    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BWART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SEND
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_BWART  TABLES   PT_SEND STRUCTURE ZGTPPT1070
                     USING PV_OBJ_TYPE.

  DATA : LS_SEND TYPE ZGTPPT1070.
  DATA : LV_IDX(4) TYPE N.

  SELECT DISTINCT BWART, BTEXT INTO TABLE @DATA(LT_T156HT)
    FROM T156HT
    WHERE SPRAS = @SY-LANGU.

  SORT LT_T156HT BY BWART.

  READ TABLE GT_OBJTY INTO GS_OBJTY WITH KEY FLD_01 = P_TARGET
                                                              FLD_02 = PV_OBJ_TYPE.


  LOOP AT LT_T156HT INTO DATA(LS_T156HT).
    ADD 1 TO LV_IDX.
    CLEAR LS_SEND.
    LS_SEND-SEQ_NO = LV_IDX.
    LS_SEND-OBJ_TYPE = PV_OBJ_TYPE.
    LS_SEND-OBJ_DESC = GS_OBJTY-FLD_03.
    LS_SEND-FLD_01 = LS_T156HT-BWART.
    LS_SEND-FLD_02 = LS_T156HT-BTEXT.

    APPEND LS_SEND TO PT_SEND.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PSTAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SEND
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_PSTAT  TABLES   PT_SEND STRUCTURE ZGTPPT1070
                     USING PV_OBJ_TYPE.

  DATA : LS_SEND TYPE ZGTPPT1070.
  DATA : LV_IDX(4) TYPE N.


  SELECT DISTINCT TXT04, TXT30 INTO TABLE @DATA(LT_TJ02T)
    FROM TJ02T
    WHERE SPRAS = @SY-LANGU
     AND TXT04 IN ('CRTD', 'REL', 'CNF', 'PCNF', 'PDLV' ,'DLV', 'DLT', 'LKD', 'TECO', 'CLSD', 'DLFL').

  SELECT DISTINCT TXT04 TXT30 FROM TJ30T
    APPENDING CORRESPONDING FIELDS OF TABLE LT_TJ02T
    WHERE STSMA = 'PPGT0001'
      AND ESTAT = 'E0001'
      AND SPRAS = SY-LANGU.

  SORT LT_TJ02T BY TXT04.
  DELETE ADJACENT DUPLICATES FROM LT_TJ02T COMPARING TXT04.

  READ TABLE GT_OBJTY INTO GS_OBJTY WITH KEY FLD_01 = P_TARGET
                                                              FLD_02 = PV_OBJ_TYPE.

  LOOP AT LT_TJ02T INTO DATA(LS_TJ02T).
    ADD 1 TO LV_IDX.
    CLEAR LS_SEND.
    LS_SEND-SEQ_NO = LV_IDX.
    LS_SEND-OBJ_TYPE = PV_OBJ_TYPE.
    LS_SEND-OBJ_DESC = GS_OBJTY-FLD_03.
    LS_SEND-FLD_01 = LS_TJ02T-TXT04.
    LS_SEND-FLD_02 = LS_TJ02T-TXT30.

    APPEND LS_SEND TO PT_SEND.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TABLE_RECORD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_TABLE_RECORD .

  DATA : LT_SEND TYPE TABLE OF ZGTPPT1070.

  PERFORM GET_WERKS.

  LOOP AT GT_OBJTY INTO GS_OBJTY.

    REFRESH LT_SEND.

    CASE GS_OBJTY-FLD_02. " 오브젝트 유형
      WHEN 'WERKS'. " 플랜트
        PERFORM SET_WERKS TABLES LT_SEND USING 'WERKS'.
      WHEN 'LGORT'. " 저장위치
        PERFORM SET_LGORT TABLES LT_SEND USING 'LGORT'.
      WHEN 'MTART'. " 자재유형
        PERFORM SET_MTART TABLES LT_SEND USING 'MTART'.
      WHEN 'AUART'. " 생산오더 유형
        PERFORM SET_AUART TABLES LT_SEND USING 'AUART'.
      WHEN 'SPGCD'. " SPG 코드
        PERFORM SET_SPGCD TABLES LT_SEND USING 'SPGCD'.
      WHEN 'FEVOR'. " 생산감독자
        PERFORM SET_FEVOR TABLES LT_SEND USING 'FEVOR'.
      WHEN 'DISPO'. " MRP관리자
        PERFORM SET_DISPO TABLES LT_SEND USING 'DISPO'.
      WHEN 'GONG_CD'. "  공정코드
        PERFORM SET_GONG_CD TABLES LT_SEND USING 'GONG_CD'.
      WHEN 'BWART'. " 이동유형
        PERFORM SET_BWART TABLES LT_SEND USING 'BWART'.
      WHEN 'PSTAT'. " 생산오더 상태
        PERFORM SET_PSTAT TABLES LT_SEND USING 'PSTAT'.
      WHEN 'JACK_CD'. "작업코드
        PERFORM SET_JACK_CD TABLES LT_SEND USING 'JACK_CD'.
      WHEN 'ZGTDORDTY'. " Demand 오더유형
        PERFORM SET_ZGTDORDTY TABLES LT_SEND USING 'ZGTDORDTY'.
      WHEN 'JACK_ATTR'. " 작업상세속성
        PERFORM SET_JACK_ATTR TABLES LT_SEND USING 'JACK_ATTR'.
      WHEN 'MATKL'. " 자재그룹
        PERFORM SET_MATKL TABLES LT_SEND USING 'MATKL'.
    ENDCASE.

    IF LT_SEND[] IS NOT INITIAL.
      APPEND LINES OF LT_SEND TO GT_SEND.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_HISTORY_OF_SEND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_HISTORY_OF_SEND .

  REFRESH GT_SEND.

  SELECT *
    INTO TABLE @GT_SEND
    FROM ZGTPPT1070
    WHERE OBJ_TYPE  IN @S_OBGTY
      AND ZSYSTEM_ID EQ @P_TARGE2
      AND IFDAT IN @S_IFDATE.

  CASE ABAP_TRUE.
    WHEN P_ALL. " 모든조건 추출
    WHEN P_SUC." 성공건만 추출
      DELETE GT_SEND WHERE ZSTAT EQ SPACE.
    WHEN P_FAIL. " 실패건만 추출
      DELETE GT_SEND WHERE ( ZSTAT EQ '0'
                                      OR ZSTAT EQ '00' ).

  ENDCASE.

  IF GT_SEND[] IS INITIAL.
    MESSAGE S003 WITH TEXT-E04 DISPLAY LIKE 'E'. " 조회된 데이터가 없습니다.
    LEAVE TO LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_RFC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SEND
*&---------------------------------------------------------------------*
FORM CALL_RFC  TABLES   PT_SENDTAB STRUCTURE ZGTPPT1070.

  DATA : LT_OT_TAB LIKE GT_OT_ITAB.
  DATA : LS_OT_TAB LIKE LINE OF GT_OT_ITAB.
  MOVE-CORRESPONDING PT_SENDTAB[] TO LT_OT_TAB[].
  LS_OT_TAB-WERKS = 'COMM'.
  MODIFY LT_OT_TAB FROM LS_OT_TAB TRANSPORTING WERKS
   WHERE WERKS IS INITIAL.


  DATA : LV_DEST TYPE ZIFDEST-DEST.
  DATA : LV_ZSYSTEM_ID   TYPE ZGTPPT1050-ZSYSTEM_ID.
  DATA : LV_MESSAGE TYPE STRING.
  CLEAR: GV_RESULT, GV_MESSAGE, LV_DEST.


*- Destination 가져오기
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      GUBUN                 = 'P1'    "Destination 점검
    IMPORTING
      DEST_NAME             = LV_DEST
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.

  LV_ZSYSTEM_ID = P_TARGET.

*- RFC 전송
  TRY.
      CALL FUNCTION 'ZGTPP_IF_O_KEY_DATA' DESTINATION LV_DEST
        EXPORTING
          I_SYSTEM_ID = LV_ZSYSTEM_ID
        IMPORTING
          ZO_RESULT   = GV_RESULT
          ZO_MESSAGE  = GV_MESSAGE
        TABLES
          IT_DATA     = LT_OT_TAB.
    CATCH CX_ROOT INTO DATA(LO_ROOT).
      LV_MESSAGE = LO_ROOT->GET_LONGTEXT( ).
  ENDTRY.


*- History_Table에 저장
  IF GV_RESULT = '00' OR GV_RESULT = '0'.
    IF GV_MESSAGE IS INITIAL.
      GV_MESSAGE    = |전송성공|.
    ENDIF.
  ELSE.
    IF GV_MESSAGE IS INITIAL.
      GV_MESSAGE = |전송실패|.
    ENDIF.
  ENDIF.

  PERFORM SAVE_HISTORY_TABLE TABLES PT_SENDTAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_HISTORY_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_SENDTAB
*&---------------------------------------------------------------------*
FORM SAVE_HISTORY_TABLE  TABLES   PT_SENDTAB STRUCTURE ZGTPPT1070.

  DATA : LV_SEQNO_N TYPE N LENGTH 10.
  DATA : LV_TIMESTAMP TYPE TIMESTAMPL.

  LV_SEQNO_N = 1.

  GET TIME STAMP FIELD LV_TIMESTAMP.
  SORT PT_SENDTAB BY OBJ_TYPE WERKS.
  LOOP AT PT_SENDTAB ASSIGNING FIELD-SYMBOL(<LS_SDENTAB>).
    <LS_SDENTAB>-ZIFKEY = LV_TIMESTAMP.
    <LS_SDENTAB>-ZSEQNO = LV_SEQNO_N.
    <LS_SDENTAB>-ZSYSTEM_ID = P_TARGET.

    <LS_SDENTAB>-ZSTAT = GV_RESULT.
    <LS_SDENTAB>-ZMESSAGE = GV_MESSAGE.
    <LS_SDENTAB>-IFDAT = SY-DATUM.
    <LS_SDENTAB>-IFTIM = SY-UZEIT.
    <LS_SDENTAB>-IFNAM = SY-UNAME.

    ADD 1 TO LV_SEQNO_N.
  ENDLOOP.

  MODIFY ZGTPPT1070 FROM TABLE PT_SENDTAB[].
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DISP_DATA .

  REFRESH GT_MAIN_DISP.

  LOOP AT GT_OT_ITAB INTO DATA(LS_MAIN).
    APPEND INITIAL LINE TO GT_MAIN_DISP
                           ASSIGNING FIELD-SYMBOL(<LS_MAIN_DISP>).
    MOVE-CORRESPONDING LS_MAIN TO <LS_MAIN_DISP>.
*   초기 상태값  없음 표시
    <LS_MAIN_DISP>-STATUS = ICON_LED_INACTIVE.
* 수신시스템
    <LS_MAIN_DISP>-ZSYSTEM_ID = P_TARGET.
*   시스템 내역
    <LS_MAIN_DISP>-DDTEXT = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
                             IV_DOMNAME  = 'ZGTDTARGET'  " 도메인이름
                             IV_DOMVALUE = CONV #( <LS_MAIN_DISP>-ZSYSTEM_ID ) ).
    " 도메인에 대한 값: 단일값/상한 * 플랜트 내역
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP_DATA2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DISP_DATA2 .

  REFRESH GT_MAIN_DISP.

  LOOP AT GT_SEND INTO DATA(LS_SEND).

    APPEND INITIAL LINE TO GT_MAIN_DISP
                            ASSIGNING FIELD-SYMBOL(<LS_MAIN_DISP>).
    MOVE-CORRESPONDING LS_SEND TO <LS_MAIN_DISP>.
*   전송 결과에 따른 상태 설정
    CASE <LS_MAIN_DISP>-ZSTAT.
      WHEN '00' OR '0'.
        <LS_MAIN_DISP>-STATUS = ICON_LED_GREEN.
      WHEN OTHERS.
        <LS_MAIN_DISP>-STATUS = ICON_LED_RED.
    ENDCASE.

*   시스템 내역
    <LS_MAIN_DISP>-DDTEXT = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
                              IV_DOMNAME  = 'ZGTDTARGET'
 " 도메인이름
                              IV_DOMVALUE = CONV #(
<LS_MAIN_DISP>-ZSYSTEM_ID ) ).                 " 도메인에 대한 값: 단일값/상한

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_SEND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_SEND .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LT_SEND TYPE TABLE OF ZGTPPT1070.
  DATA : LS_ERR_LINE LIKE GS_MAIN_DISP.
  DATA : LV_MESSAGE(50).

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.
  IF LT_ROW[] IS INITIAL.
    MESSAGE S003 WITH '전송 데이터가 없습니다.' DISPLAY LIKE 'E'. "전송 데이터가 없습니다.
    RETURN.
  ENDIF.

  LOOP AT LT_ROW INTO LS_ROW.
    READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_ROW-INDEX.

    APPEND INITIAL LINE TO LT_SEND ASSIGNING FIELD-SYMBOL(<LS_SEND>).
    MOVE-CORRESPONDING <LS_MAIN> TO <LS_SEND>.
  ENDLOOP.

  PERFORM CALL_RFC TABLES LT_SEND.

  READ TABLE LT_SEND INTO DATA(LS_SEND) INDEX 1.

  LOOP AT LT_ROW INTO LS_ROW.
    READ TABLE GT_MAIN_DISP ASSIGNING <LS_MAIN> INDEX LS_ROW-INDEX.
*  전송결과 적용
    IF LINE_EXISTS( LT_SEND[ ZSTAT = '00' ] ) OR
      LINE_EXISTS( LT_SEND[ ZSTAT = '0' ] ). " 성공시
      <LS_MAIN>-STATUS = ICON_LED_GREEN.
    ELSE.
      <LS_MAIN>-STATUS = ICON_LED_RED.
    ENDIF.
    <LS_MAIN>-ZMESSAGE = LS_SEND-ZMESSAGE.

    CASE ABAP_TRUE.
      WHEN P_DISP.
        <LS_MAIN>-ZIFKEY = LS_SEND-ZIFKEY.
        <LS_MAIN>-IFDAT = LS_SEND-IFDAT.
        <LS_MAIN>-IFTIM = LS_SEND-IFTIM.
        <LS_MAIN>-IFNAM = LS_SEND-IFNAM.
    ENDCASE.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0101
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
*     I_SOFT_REFRESH = 'X'
      IS_STABLE = LS_SCROLL.

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

  CREATE OBJECT GO_CONTAIN_0100
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

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.


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
  GS_LAYOUT_0100-SEL_MODE   = 'D'.

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
      I_INCLNAME             = 'ZGTPPI1040TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP'
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
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_MAIN_DISP
    EXCEPTIONS
      OTHERS          = 1.


  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'ZIFKEY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP =
'인터페이스 키'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZSEQNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '순번'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'STATUS'.
        CASE ABAP_TRUE.
          WHEN P_SEND.
            <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP =
'전송 상태'.
          WHEN P_DISP.
            <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP =
'전송 결과'.
        ENDCASE.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = 'X'.
      WHEN 'ZMESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT
                                          = <LS_FCAT>-TOOLTIP = '결과메시지'(F01).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'ZSYSTEM_ID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT
                                          = <LS_FCAT>-TOOLTIP = '수신시스템'(F02).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'DDTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시스템 내역'(F03).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'(F20).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'OBJ_TYPE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오브젝트 유형'(F04).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'OBJ_DESC'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오브젝트 유형 내역'(F05).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'SEQ_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '코드순번'(F06).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'FLD_01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '필드값1'(F07).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'FLD_02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '필드값2'(F08).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'FLD_03'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '필드값3'(F09).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'FLD_04'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '필드값4'(F10).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'FLD_05'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '필드값5'(F11).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'FLD_06'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '필드값6'(F12).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'FLD_07'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '필드값7'(F13).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'FLD_08'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '필드값8'(F14).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'FLD_09'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '필드값9'(F15).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'FLD_10'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '필드값10'(F16).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'IFDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '전송일자'(F17).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'IFTIM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '전송시간'(F18).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'IFNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '전송자'(F19).
        <LS_FCAT>-JUST = 'C'.
    ENDCASE.


    CASE ABAP_TRUE.
      WHEN P_SEND.
        CASE <LS_FCAT>-FIELDNAME.
          WHEN 'ZIFKEY' OR 'ZSEQNO' OR 'ZSTAT' OR 'IFDAT' OR 'IFTIM' OR 'IFNAM'.
            <LS_FCAT>-NO_OUT = 'X'.
        ENDCASE.
      WHEN P_DISP.
        CASE <LS_FCAT>-FIELDNAME.
          WHEN 'ZSTAT'.
            <LS_FCAT>-NO_OUT = 'X'.
        ENDCASE.
    ENDCASE.

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
      IT_OUTTAB            = GT_MAIN_DISP
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_JACK_CD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SEND
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_JACK_CD  TABLES   PT_SEND STRUCTURE ZGTPPT1070
                     USING PV_OBJ_TYPE.

  DATA : LS_SEND TYPE ZGTPPT1070.
  DATA : LV_IDX(4) TYPE N.


  SELECT DISTINCT A~BWKEY AS WERKS, B~SPART, D~VTEXT,
                          B~GONG_CD, B~JACK_CD, C~JACK_NM, C~JACK_DESC
    INTO TABLE @DATA(LT_JACK_CD)
    FROM T001K AS A
    INNER JOIN ZEDT0012 AS B ON B~BUKRS = A~BUKRS
    INNER JOIN ZEDT0021 AS C ON C~JACK_CD = B~JACK_CD
    INNER JOIN TSPAT AS D ON D~SPART = B~SPART
    INNER JOIN ZPPT0107 AS E ON E~SPART = B~SPART
                                     AND E~WERKS = A~BWKEY
   WHERE A~BWKEY IN @GT_WERKS
    AND D~SPRAS = @SY-LANGU.


  SORT LT_JACK_CD BY WERKS SPART GONG_CD JACK_CD.

  READ TABLE GT_OBJTY INTO GS_OBJTY WITH KEY FLD_01 = P_TARGET
                                                              FLD_02 = PV_OBJ_TYPE.

  LOOP AT GT_WERKS INTO DATA(LS_WERKS).
    CLEAR LV_IDX.
    LOOP AT LT_JACK_CD INTO DATA(LS_JACK_CD) WHERE WERKS = LS_WERKS-LOW.
      ADD 1 TO LV_IDX.
      CLEAR LS_SEND.
      LS_SEND-SEQ_NO = LV_IDX.
      LS_SEND-OBJ_TYPE = PV_OBJ_TYPE.
      LS_SEND-OBJ_DESC = GS_OBJTY-FLD_03.
      LS_SEND-WERKS = LS_JACK_CD-WERKS.
      LS_SEND-FLD_01 = LS_JACK_CD-SPART.
      LS_SEND-FLD_02 = LS_JACK_CD-VTEXT.
      LS_SEND-FLD_03 = LS_JACK_CD-GONG_CD.
      LS_SEND-FLD_04 = LS_JACK_CD-JACK_CD.
      LS_SEND-FLD_05 = LS_JACK_CD-JACK_NM.
      LS_SEND-FLD_06 = LS_JACK_CD-JACK_DESC.

      APPEND LS_SEND TO PT_SEND.

    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ZGTDORDTY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SEND
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_ZGTDORDTY  TABLES   PT_SEND STRUCTURE ZGTPPT1070
                     USING PV_OBJ_TYPE.

  DATA : LS_SEND TYPE ZGTPPT1070.
  DATA : LV_IDX(4) TYPE N.
  DATA : LT_DD07V TYPE TABLE OF DD07V.

  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      DOMNAME       = 'ZGTDORDTY'
      TEXT          = 'X'
      LANGU         = SY-LANGU
      BYPASS_BUFFER = 'X'
    TABLES
      DD07V_TAB     = LT_DD07V.

  DELETE LT_DD07V WHERE DOMVALUE_L = ' '.

  READ TABLE GT_OBJTY INTO GS_OBJTY WITH KEY FLD_01 = P_TARGET
                                                              FLD_02 = PV_OBJ_TYPE.

  LOOP AT LT_DD07V INTO DATA(LS_DD07V).
    ADD 1 TO LV_IDX.
    CLEAR LS_SEND.
    LS_SEND-SEQ_NO = LV_IDX.
    LS_SEND-OBJ_TYPE = PV_OBJ_TYPE.
    LS_SEND-OBJ_DESC = GS_OBJTY-FLD_03.
    LS_SEND-FLD_01 = LS_DD07V-DOMVALUE_L.
    LS_SEND-FLD_02 = LS_DD07V-DDTEXT.
    APPEND LS_SEND TO PT_SEND.
  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_JACK_ATTR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SEND
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_JACK_ATTR  TABLES   PT_SEND STRUCTURE ZGTPPT1070
                     USING PV_OBJ_TYPE.

  DATA : LS_SEND TYPE ZGTPPT1070.
  DATA : LV_IDX(4) TYPE N.

  SELECT DISTINCT B~WERKS, B~SPART, C~JACK_CD, C~ATTRIBUTE, C~ATTRIBUTE_NO, C~GROUP_NAME,
             C~TITLE_NAME, C~ZCOMMENT
    FROM T001K AS A
    INNER JOIN ZPPT0107 AS B ON B~WERKS = A~BWKEY
    INNER JOIN ZEDT0000 AS C ON C~BUKRS = A~BUKRS
                                     AND C~SPART = B~SPART
   WHERE A~BWKEY IN @GT_WERKS
    INTO TABLE @DATA(LT_JACK_ATTR).

  READ TABLE GT_OBJTY INTO GS_OBJTY WITH KEY FLD_01 = P_TARGET
                                                              FLD_02 = PV_OBJ_TYPE.

  LOOP AT LT_JACK_ATTR INTO DATA(LS_JACK_ATTR).
    ADD 1 TO LV_IDX.
    CLEAR LS_SEND.
    LS_SEND-SEQ_NO = LV_IDX.
    LS_SEND-OBJ_TYPE = PV_OBJ_TYPE.
    LS_SEND-OBJ_DESC = GS_OBJTY-FLD_03.
    LS_SEND-FLD_01 = LS_JACK_ATTR-SPART.
    LS_SEND-FLD_02 = LS_JACK_ATTR-JACK_CD.
    LS_SEND-FLD_03 = LS_JACK_ATTR-ATTRIBUTE.
    LS_SEND-FLD_04 = LS_JACK_ATTR-ATTRIBUTE_NO.
    LS_SEND-FLD_05 = LS_JACK_ATTR-GROUP_NAME.
    LS_SEND-FLD_06 = LS_JACK_ATTR-TITLE_NAME.
    LS_SEND-FLD_07 = LS_JACK_ATTR-ZCOMMENT.
    APPEND LS_SEND TO PT_SEND.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MATKL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_SEND
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_MATKL  TABLES   PT_SEND STRUCTURE ZGTPPT1070
                     USING PV_OBJ_TYPE.

  DATA : LS_SEND TYPE ZGTPPT1070.
  DATA : LV_IDX(4) TYPE N.

  SELECT DISTINCT MATKL, WGBEZ
    FROM T023T
   WHERE SPRAS = @SY-LANGU
    INTO TABLE @DATA(LT_MATKL).

  READ TABLE GT_OBJTY INTO GS_OBJTY WITH KEY FLD_01 = P_TARGET
                                                              FLD_02 = PV_OBJ_TYPE.

  LOOP AT LT_MATKL INTO DATA(LS_MATKL).
    ADD 1 TO LV_IDX.
    CLEAR LS_SEND.
    LS_SEND-SEQ_NO = LV_IDX.
    LS_SEND-OBJ_TYPE = PV_OBJ_TYPE.
    LS_SEND-OBJ_DESC = GS_OBJTY-FLD_03.
    LS_SEND-FLD_01 = LS_MATKL-MATKL.
    LS_SEND-FLD_02 = LS_MATKL-WGBEZ.
    APPEND LS_SEND TO PT_SEND.
  ENDLOOP.

ENDFORM.
