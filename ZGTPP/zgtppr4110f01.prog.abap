*&---------------------------------------------------------------------*
*& Include          ZGTPPR4110F01
*&---------------------------------------------------------------------*
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
    CLEAR ZPPT0107.
    SELECT SINGLE DESCR INTO P_DESCR
             FROM ZPPT0107
            WHERE SPGCD EQ P_SPGCD.
  ELSE.
    CLEAR P_DESCR.
  ENDIF.

* 플랜트명
  IF NOT P_WERKS IS INITIAL.
    CLEAR T001W.
    SELECT SINGLE NAME1 INTO P_NAME1
             FROM T001W
            WHERE WERKS EQ P_WERKS.
  ELSE.
    CLEAR P_NAME1.
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
  ENDLOOP.

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

  TYPES: BEGIN OF TY_MCHA,
           WERKS    TYPE MARC-WERKS,
           MATNR    TYPE MCH1-MATNR,
           CHARG    TYPE MCH1-CHARG,
           CUOBJ_BM TYPE MCH1-CUOBJ_BM,
         END OF TY_MCHA,

         BEGIN OF TY_AUSP,
           OBJEK TYPE AUSP-OBJEK,
           ATINN TYPE AUSP-ATINN,
           ATWRT TYPE AUSP-ATWRT, "문자형 특성값
           ATFLV TYPE AUSP-ATFLV, "숫자형 특성값
         END OF TY_AUSP,

         BEGIN OF TY_CABN,
           ATNAM TYPE CABN-ATNAM, "특성 이름 (예: Z_PURITY)
           ATINN TYPE CABN-ATINN,
         END OF TY_CABN.

  DATA : LT_MCH1 TYPE TABLE OF TY_MCHA,
         LT_AUSP TYPE TABLE OF TY_AUSP,
         LT_CABN TYPE TABLE OF TY_CABN.

  DATA : LT_ATINN TYPE RANGE OF CABN-ATINN.

  DATA : LV_VALUE TYPE CHAR20.
  DATA : LV_MENGE TYPE MENGE_D.
  DATA : LV_MENGE2 TYPE MENGE_D.

  DATA : LV_CHK_ERR.

  GV_DISPO = P_SPGCD && '%'. "

  SELECT MATNR, WERKS FROM ZGTCVMSTVAL
    INTO TABLE @DATA(LT_MARC)
   WHERE WERKS = @P_WERKS
      AND DISPO LIKE @GV_DISPO
      AND MATNR IN @S_MATNR
      AND LVORMP <> 'X'
      AND DPCBT = 'A'
      AND PDCAPROCCODE IN @S_GONGCD.

  REFRESH GT_MAIN.
  CHECK LT_MARC IS NOT INITIAL.

* MCHB 대상
  SELECT DISTINCT B~WERKS, B~MATNR, B~CHARG
    FROM @LT_MARC AS A
    INNER JOIN MCHB AS B ON B~WERKS = A~WERKS
                        AND B~MATNR = A~MATNR
   WHERE B~CHARG IN @S_CHARG
    INTO TABLE @DATA(LT_MCHB).

  LOOP AT LT_MCHB INTO DATA(LS_MCHB).
    CLEAR LV_CHK_ERR.
    PERFORM CHECK_GAYONG_CHARG USING LS_MCHB-CHARG CHANGING LV_CHK_ERR.
    IF LV_CHK_ERR IS NOT INITIAL.
      CONTINUE.
    ENDIF.
    APPEND INITIAL LINE TO GT_MAIN ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    MOVE-CORRESPONDING LS_MCHB TO <LS_MAIN>.
  ENDLOOP.

* MSKA 대상
  SELECT DISTINCT B~WERKS, B~MATNR, B~CHARG
    FROM @LT_MARC AS A
    INNER JOIN MSKA AS B ON B~WERKS = A~WERKS
                        AND B~MATNR = A~MATNR
   WHERE B~CHARG IN @S_CHARG
    INTO TABLE @DATA(LT_MSKA).

  LOOP AT LT_MSKA INTO DATA(LS_MSKA).
    CLEAR LV_CHK_ERR.
    PERFORM CHECK_GAYONG_CHARG USING LS_MSKA-CHARG CHANGING LV_CHK_ERR.
    IF LV_CHK_ERR IS NOT INITIAL.
      CONTINUE.
    ENDIF.
    APPEND INITIAL LINE TO GT_MAIN ASSIGNING <LS_MAIN>.
    MOVE-CORRESPONDING LS_MSKA TO <LS_MAIN>.
  ENDLOOP.

* 해당 배치 특성값 조회후 배치 특성값과 다른 경우 대상으로 추출한다.
  SORT GT_MAIN BY WERKS MATNR CHARG.
  DELETE ADJACENT DUPLICATES FROM GT_MAIN COMPARING WERKS MATNR CHARG.

  IF GT_MAIN[] IS NOT INITIAL.
    SELECT DISTINCT ATNAM, ATINN
      FROM CABN
      INTO TABLE @LT_CABN
     WHERE ATNAM IN ( 'SAP_MILLCA_LENGTH_SUB', 'SAP_MILLCA_LENGTH' ).
    LT_ATINN = VALUE #( FOR LW_CABN IN LT_CABN WHERE ( ATINN IS NOT INITIAL )
                      ( SIGN = 'I' OPTION = 'EQ' LOW = LW_CABN-ATINN ) ).

* 특성값 조회를 위한 데이터 추출
    SELECT A~WERKS, B~MATNR, B~CHARG, B~CUOBJ_BM
      FROM @GT_MAIN AS A
      INNER JOIN MCH1 AS B ON B~MATNR = A~MATNR
                          AND B~CHARG = A~CHARG
     WHERE B~CUOBJ_BM <> @SPACE
      INTO TABLE @LT_MCH1.

* 특성값 조회
    SELECT B~OBJEK, B~ATINN, B~ATWRT, B~ATFLV
      FROM @LT_MCH1 AS A
      INNER JOIN AUSP AS B ON B~OBJEK = A~CUOBJ_BM
     WHERE B~ATINN IN @LT_ATINN
       AND B~KLART = '023'
      INTO TABLE @LT_AUSP. "

  ENDIF.

  REFRESH GT_MAIN.

  SORT LT_AUSP BY OBJEK.
  SORT LT_CABN BY ATINN.

  LOOP AT LT_MCH1 INTO DATA(LS_MCH1).
    READ TABLE LT_AUSP TRANSPORTING NO FIELDS WITH KEY OBJEK = LS_MCH1-CUOBJ_BM BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      LOOP AT LT_AUSP INTO DATA(LS_AUSP) FROM SY-TABIX.
        IF LS_AUSP-OBJEK NE LS_MCH1-CUOBJ_BM.
          EXIT.
        ENDIF.

        READ TABLE LT_CABN INTO DATA(LS_CABN) WITH KEY ATINN = LS_AUSP-ATINN BINARY SEARCH.
        IF SY-SUBRC EQ 0.
          CASE LS_CABN-ATNAM.
            WHEN 'SAP_MILLCA_LENGTH_SUB'.
              CLEAR : LV_VALUE, LV_MENGE.

              CALL FUNCTION 'FLTP_CHAR_CONVERSION'
                EXPORTING
                  DECIM = 3
                  INPUT = LS_AUSP-ATFLV
                IMPORTING
                  FLSTR = LV_VALUE.

              LV_MENGE = LV_VALUE.
              IF LV_MENGE NE 0.
                APPEND INITIAL LINE TO GT_MAIN ASSIGNING <LS_MAIN>.
                MOVE-CORRESPONDING LS_MCH1 TO <LS_MAIN>.
                CONTINUE.
              ENDIF.

            WHEN 'SAP_MILLCA_LENGTH'.

              CLEAR : LV_VALUE, LV_MENGE, LV_MENGE2.

              CALL FUNCTION 'FLTP_CHAR_CONVERSION'
                EXPORTING
                  DECIM = 3
                  INPUT = LS_AUSP-ATFLV
                IMPORTING
                  FLSTR = LV_VALUE.

              LV_MENGE = LV_VALUE.
              LV_MENGE2 = LS_MCH1-CHARG.
              IF LV_MENGE NE LV_MENGE2.
                APPEND INITIAL LINE TO GT_MAIN ASSIGNING <LS_MAIN>.
                MOVE-CORRESPONDING LS_MCH1 TO <LS_MAIN>.
                CONTINUE.
              ENDIF.
          ENDCASE.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DISP .

  DATA : LT_OUTPUT TYPE ZGTPPY0009.
  DATA : LV_MESSAGE TYPE CHAR100.

  IF GT_MAIN IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'S' WITH '특성 업데이트 대상이 없습니다.'.
  ELSE.
    CALL FUNCTION 'ZGTPP_FACTOR_BATCH_CHAR_UPDATE'
      TABLES
        T_INPUT  = GT_MAIN
        T_OUTPUT = LT_OUTPUT.

    WRITE : '처리결과'.

    LOOP AT LT_OUTPUT INTO DATA(LS_OUTPUT).
      CLEAR LV_MESSAGE.
      LV_MESSAGE = | { LS_OUTPUT-MATNR } // { LS_OUTPUT-MATNR } // { LS_OUTPUT-CHARG } // |.
      CASE LS_OUTPUT-ZO_RESULT.
        WHEN 'S'.
          WRITE : /, LV_MESSAGE NO-GAP, '특성값 업데이트 성공'.
        WHEN 'E'.
          WRITE : /, LV_MESSAGE NO-GAP, '특성값 업데이트 실패'.
      ENDCASE.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_GAYONG_CHARG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MCHB_CHARG
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHECK_GAYONG_CHARG  USING    PV_CHARG TYPE MCHB-CHARG
                         CHANGING PV_CHK_ERR.

* 배치가 숫자일 경우만 포함한다.
  FIND REGEX '[^0-9]' IN PV_CHARG.
  IF SY-SUBRC EQ 0.
    IF STRLEN( PV_CHARG ) > 6.
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
  ELSE.
* 소숫점이 들어갈 경우 대상건으로 본다. 소숫점이 없을경우 6자리까지만 허용
    IF PV_CHARG CO '.'.
      " 문자열이 모두 숫자임, 소숫점포함
    ELSE.
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
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
    ASSIGN (PV_DYNPROFLD) TO FIELD-SYMBOL(<LV_FIELD>).
    <LV_FIELD> = LS_RETURN_TAB-FIELDVAL.

  ENDIF.

ENDFORM.
