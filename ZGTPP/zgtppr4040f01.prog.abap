*&---------------------------------------------------------------------*
*& Include          ZGTPPR4040F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_PARAMETER_DESCRIPTION
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
*& Form modify_first_screen
*&---------------------------------------------------------------------*
FORM MODIFY_FIRST_SCREEN .

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'M1'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.


    IF SCREEN-GROUP1 = 'NBW'.
      SCREEN-ACTIVE = COND #( WHEN P_BWD EQ ABAP_TRUE THEN 0 ELSE 1 ) .
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_popup_to_select_month
*&---------------------------------------------------------------------*
FORM F4_POPUP_TO_SELECT_MONTH .

  DATA : LT_DYNPFIELDS TYPE STANDARD TABLE OF DYNPREAD,
         LS_DYNPFIELDS TYPE DYNPREAD,
         L_SUBRC       TYPE SY-SUBRC,
         L_MONTH       TYPE ISELLIST-MONTH,
         L_DYNAME      TYPE SY-CPROG.
  FIELD-SYMBOLS : <MONTH> TYPE ANY.
  DATA : LV_LINE        LIKE SY-STEPL,
         LT_DYNPFIELDS2 LIKE TABLE OF DYNPREAD.
  DATA : LV_DATE TYPE SY-DATUM.
* value of screen reading
  GET CURSOR FIELD LS_DYNPFIELDS-FIELDNAME.
  APPEND LS_DYNPFIELDS TO LT_DYNPFIELDS. CLEAR LS_DYNPFIELDS.
  L_DYNAME = SY-CPROG.

  DO 2 TIMES.

    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        DYNAME               = L_DYNAME
        DYNUMB               = SY-DYNNR
      TABLES
        DYNPFIELDS           = LT_DYNPFIELDS
      EXCEPTIONS
        INVALID_ABAPWORKAREA = 01
        INVALID_DYNPROFIELD  = 02
        INVALID_DYNPRONAME   = 03
        INVALID_DYNPRONUMMER = 04
        INVALID_REQUEST      = 05
        NO_FIELDDESCRIPTION  = 06
        UNDEFIND_ERROR       = 07.

    IF SY-SUBRC = 3.
*     current screen image is set of values
      L_DYNAME = 'SAPLALDB'.
    ELSE.
      READ TABLE LT_DYNPFIELDS INTO LS_DYNPFIELDS INDEX 1.
*     underscores replaced with blanks
      TRANSLATE LS_DYNPFIELDS-FIELDVALUE USING '_ '.
      EXIT.
    ENDIF.

  ENDDO.

  IF SY-SUBRC = 0.
*   conversion to internal format
    CALL FUNCTION 'CONVERSION_EXIT_PERI_INPUT'
      EXPORTING
        INPUT  = LS_DYNPFIELDS-FIELDVALUE
      IMPORTING
        OUTPUT = L_MONTH.

    IF L_MONTH IS INITIAL.
*     month, initial => default value from act. date derived
      L_MONTH = SY-DATLO+0(6).
    ENDIF.

    CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
      EXPORTING
        ACTUAL_MONTH               = L_MONTH
      IMPORTING
        SELECTED_MONTH             = L_MONTH
        RETURN_CODE                = L_SUBRC
      EXCEPTIONS
        FACTORY_CALENDAR_NOT_FOUND = 1
        HOLIDAY_CALENDAR_NOT_FOUND = 2
        MONTH_NOT_FOUND            = 3
        OTHERS                     = 4.

    IF SY-SUBRC = 0 AND L_SUBRC = 0.
      ASSIGN (LS_DYNPFIELDS-FIELDNAME) TO <MONTH>.
      <MONTH> = L_MONTH.

      PERFORM GET_STEPL USING LV_LINE.

      LV_DATE = <MONTH> && '01'.
      PERFORM GET_LAST_DAY_OF_MONTH CHANGING LV_DATE.

      REFRESH LT_DYNPFIELDS2.
      APPEND INITIAL LINE TO LT_DYNPFIELDS2 ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
      <LS_DYNPFIELDS>-FIELDNAME = 'P_BUDAT'.
      <LS_DYNPFIELDS>-STEPL = LV_LINE.
      WRITE LV_DATE TO <LS_DYNPFIELDS>-FIELDVALUE.


      CALL FUNCTION 'DYNP_VALUES_UPDATE'
        EXPORTING
          DYNAME               = SY-CPROG
          DYNUMB               = SY-DYNNR
        TABLES
          DYNPFIELDS           = LT_DYNPFIELDS2
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
*& Form authority_checking_proc
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECKING_PROC .
*& 플랜트에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
  ID 'WERKS'  FIELD P_WERKS.

  IF SY-SUBRC <> 0.
    MESSAGE E006 WITH TEXT-010 P_WERKS TEXT-013.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM GET_DATA .

  DATA : LT_STOCK TYPE TABLE OF ZGTCV_STOCKVAL.
  DATA : LS_STOCK TYPE ZGTCV_STOCKVAL.

  REFRESH GT_DISP.

  IF P_BWD = ABAP_TRUE.
    IF P_WERKS NE '6500'.
      RETURN.
    ENDIF.

    SELECT DISTINCT * FROM ZGTCVMSTVAL
      INTO TABLE @DATA(LT_MSTVAL)
     WHERE WERKS = @P_WERKS
      AND MATNR IN @S_MATNR1
      AND PDCAPROCCODE = 'BWD'
      AND SPG = @P_SPGCD
      AND LVORMC = ''
      AND LVORMP = ''.

    REFRESH GT_STOCK.
    IF LT_MSTVAL[] IS NOT INITIAL.
      SELECT DISTINCT *
        INTO CORRESPONDING FIELDS OF TABLE @GT_STOCK
        FROM ZGTCV_STOCKVAL
        FOR ALL ENTRIES IN @LT_MSTVAL
        WHERE MATNR EQ @LT_MSTVAL-MATNR
          AND WERKS EQ @LT_MSTVAL-WERKS
          AND LGORT IN @S_LGORT.
    ENDIF.

    REFRESH GT_DISP.

    LOOP AT LT_MSTVAL INTO DATA(LS_MSTVAL).
      CLEAR GS_DISP.
      GS_DISP-MATNR = LS_MSTVAL-MATNR. "자재 코드
      GS_DISP-MAKTX = LS_MSTVAL-MAKTX.
      GS_DISP-LGORT = GS_0600-LGORT. "저장위치
      GS_DISP-BTEXT = TEXT-005. "재고 유형
      GS_DISP-ICON = ICON_LED_INACTIVE.

      SELECT SINGLE MEINS FROM MARA
        INTO GS_DISP-MEINS
       WHERE MATNR = LS_MSTVAL-MATNR.

      REFRESH LT_STOCK.
      LOOP AT GT_STOCK INTO GS_STOCK WHERE  MATNR = LS_MSTVAL-MATNR.
        CLEAR LS_STOCK.
        LS_STOCK-MATNR = GS_STOCK-MATNR.
        LS_STOCK-LGORT = GS_STOCK-LGORT.

        IF GS_DISP-MEINS NE GS_STOCK-MEINS.
          CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
            EXPORTING
              I_MATNR  = GS_STOCK-MATNR "BAPI 투입 처리하고자하는 자재
              I_IN_ME  = GS_STOCK-MEINS "BAPI 투입 처리하고자하는 단위
              I_OUT_ME = GS_DISP-MEINS "생산 오더 예약 정보 단위
              I_MENGE  = GS_STOCK-LABST "BAPI 투입 처리하고자하는 수량
            IMPORTING
              E_MENGE  = GS_STOCK-LABST. "BAPI 투입 처리 대상 수량
        ENDIF.
        LS_STOCK-LABST = GS_STOCK-LABST.

        COLLECT LS_STOCK INTO LT_STOCK.

      ENDLOOP.

      LOOP AT LT_STOCK INTO LS_STOCK.
        GS_DISP-JEGO = LS_STOCK-LABST. "재고 수량
        GS_DISP-LGORT = LS_STOCK-LGORT. "재고 수량
        APPEND GS_DISP TO GT_DISP.
      ENDLOOP.

    ENDLOOP.


  ELSE.

    CLEAR : GS_0600, GT_0600, GT_0600_1, GS_STOCK, GT_STOCK,
            GS_DISP, GT_DISP.
*- 실사 데이터 확인
    SELECT A~*
      INTO CORRESPONDING FIELDS OF TABLE @GT_0600
      FROM ZPPT0600 AS A INNER JOIN MARA AS B
        ON A~MATNR EQ B~MATNR
        INNER JOIN T134 AS C
        ON B~MTART EQ C~MTART
      WHERE A~INSMM EQ @P_MONTH
        AND A~WERKS EQ @P_WERKS
*          AND A~SPGCD EQ @P_SPGCD
        AND A~MATNR IN @S_MATNR1
        AND A~LGORT IN @S_LGORT
*      AND a~charg NE @space " 20260722 주석처리
*// Modified by ZGODEV06 on 2026-06-04 {
*     AND  c~flref IN ('ROH', 'MCRO'
        AND ( C~FLREF IN ('ROH', 'MCRO' ) OR
              C~MTREF = 'HALB' )
*// }
        AND A~IBLNR EQ @SPACE
        AND A~MBLNR EQ @SPACE.

*- 재고 확인
* 실사 데이터 "가용"만 조정 가능.
    GT_0600_1[] = GT_0600.
    IF P_WERKS+0(1) EQ '6'.
    ELSE.
      DELETE GT_0600_1 WHERE BSTAR NE '1'.
    ENDIF.
    SORT GT_0600_1 BY MATNR WERKS LGORT CHARG SPGCD.
    DELETE ADJACENT DUPLICATES FROM GT_0600_1
                          COMPARING MATNR WERKS LGORT CHARG SPGCD.

    IF GT_0600_1[] IS NOT INITIAL.

      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE @GT_STOCK
        FROM ZGTCV_STOCKVAL
        FOR ALL ENTRIES IN @GT_0600_1
        WHERE MATNR EQ @GT_0600_1-MATNR
          AND WERKS EQ @GT_0600_1-WERKS
          AND LGORT EQ @GT_0600_1-LGORT
          AND CHARG EQ @GT_0600_1-CHARG.
*        AND SPG   EQ @GT_0600_1-SPGCD.

    ENDIF.

*- 실사수량확인
* 실사 데이터를 기준으로 재고 수량과 비교하여 차이량 계산 후 ALV 출력
    LOOP AT GT_0600 INTO GS_0600.

      CLEAR GS_DISP.
      GS_DISP-MATNR = GS_0600-MATNR. "자재 코드
      GS_DISP-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX(
        IV_MATNR = GS_DISP-MATNR ). "자재 내역
      GS_DISP-CHARG = GS_0600-CHARG. "배치 번호
      GS_DISP-LGORT = GS_0600-LGORT. "저장위치
      GS_DISP-BTEXT = TEXT-005. "재고 유형
      GS_DISP-MEINS = GS_0600-MEINS. "단위
      GS_DISP-SILSA = GS_0600-MENGE + GS_0600-MENGE_DIF. "실사 수량

      CLEAR GS_STOCK.
      READ TABLE GT_STOCK INTO GS_STOCK WITH KEY MATNR = GS_0600-MATNR
                                                 CHARG = GS_0600-CHARG
                                                 LGORT = GS_0600-LGORT.

      IF SY-SUBRC = 0.
* 재고 단위와 실사 단위가 다른 경우 실사 단위로 재고 수량 단위 변환 필요
        IF GS_STOCK-MEINS NE GS_0600-MEINS.

          CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
            EXPORTING
              I_MATNR  = GS_0600-MATNR "BAPI 투입 처리하고자하는 자재
              I_IN_ME  = GS_STOCK-MEINS "BAPI 투입 처리하고자하는 단위
              I_OUT_ME = GS_0600-MEINS "생산 오더 예약 정보 단위
              I_MENGE  = GS_STOCK-LABST "BAPI 투입 처리하고자하는 수량
            IMPORTING
              E_MENGE  = GS_STOCK-LABST. "BAPI 투입 처리 대상 수량

        ENDIF.

        GS_DISP-JEGO = GS_STOCK-LABST. "재고 수량

*// Modified by ZGODEV06 on 2026-06-04 {
*      gs_disp-chai = gs_disp-jego - gs_disp-silsa. "차이량

        IF P_WERKS+0(1) EQ '6'.
          GS_DISP-CHAI = GS_DISP-SILSA.                "차이량
          GS_DISP-SILSA = GS_DISP-JEGO + GS_DISP-SILSA.  " 20260722 추가
        ELSE.
          GS_DISP-CHAI = GS_DISP-JEGO - GS_DISP-SILSA. "차이량
        ENDIF.
      ELSE.
        IF P_WERKS+0(1) EQ '6'.
          GS_DISP-CHAI = GS_DISP-SILSA.                "차이량
          GS_DISP-SILSA = GS_DISP-JEGO + GS_DISP-SILSA.  " 20260722 추가
        ENDIF.
*// }
      ENDIF.

      IF GS_DISP-CHAI IS INITIAL.
        GS_DISP-ICON = ICON_LED_GREEN.
      ELSE.
        GS_DISP-ICON = ICON_LED_RED.
      ENDIF. "상태

      APPEND GS_DISP TO GT_DISP.

    ENDLOOP.

    SORT GT_DISP BY MATNR CHARG.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm_step
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_STEP USING LP_OPT LP_TEXT1 LP_TEXT2 LP_TITLE.

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
*& Form select_line_check
*&---------------------------------------------------------------------*
FORM SELECT_LINE_CHECK .

  IF GT_ROW[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E01.
    RETURN.
  ENDIF.

  IF P_BWD = ABAP_TRUE AND LINES( GT_ROW ) > 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E06.
    RETURN.
  ENDIF.

* 만약, 차이량이 없는 건 선택 시 에러 메시지 출력 후 진행 중단
  CLEAR : GV_EXIT, GS_MSEG, GT_MSEG, GS_SILSA, GT_SILSA, GT_DISP_1.
  LOOP AT GT_ROW INTO GS_ROW.

    READ TABLE GT_DISP INTO GS_DISP INDEX GS_ROW-INDEX.

    IF P_BWD = ABAP_TRUE.

      IF GS_DISP-ICON NE ICON_LED_GREEN.
        MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E02.
        GV_EXIT = ABAP_TRUE.
        EXIT.
      ELSE.
        APPEND GS_DISP TO GT_DISP_1. "차이량 차감용
        CLEAR GS_SILSA.
        GS_SILSA-MATNR = GS_DISP-MATNR.
        APPEND GS_SILSA TO GT_SILSA.
      ENDIF.
    ELSE.

      IF GS_DISP-ICON EQ ICON_LED_GREEN.
        MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E02.
        GV_EXIT = ABAP_TRUE.
        EXIT.
* 배부 대상 건일 경우 실사 자재 취합
      ELSE.
        APPEND GS_DISP TO GT_DISP_1. "차이량 차감용
        CLEAR GS_SILSA.
        GS_SILSA-MATNR = GS_DISP-MATNR.
        APPEND GS_SILSA TO GT_SILSA.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF P_ALL = ABAP_TRUE AND LINES( GT_ROW ) > 1.
    SELECT DISTINCT A~* FROM MARA AS A
      INNER JOIN @GT_SILSA AS B ON B~MATNR = A~MATNR
      INTO TABLE @DATA(LT_MARA).

    IF LINES( LT_MARA ) = 1. " 한건의 오더만 조회시 여러개 선택가능
    ELSE.
      REFRESH GT_SILSA.
      GV_EXIT = ABAP_TRUE.
      MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E05.
      RETURN.
    ENDIF.
  ENDIF.

  CHECK GV_EXIT IS INITIAL.

  SORT GT_SILSA BY MATNR.
  DELETE ADJACENT DUPLICATES FROM GT_SILSA COMPARING MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_from_mseg
*&---------------------------------------------------------------------*
FORM GET_DATA_FROM_MSEG .

  DATA : LV_DISPO(3),
         LT_TJ02T LIKE TJ02T OCCURS 0 WITH HEADER LINE.
  DATA : LT_MSEG LIKE TABLE OF GS_MSEG.

  CLEAR : GS_MSEG, GT_MSEG, GT_MSEG2, LV_DISPO, GV_AUFNR.
  CONCATENATE P_SPGCD '%' INTO LV_DISPO.
*- 투입 정보
  SELECT A~*, C~MATNR AS MATNR2, C~PDCAPROCCODE, C~ARBPL
    INTO CORRESPONDING FIELDS OF TABLE @GT_MSEG2
    FROM MSEG AS A INNER JOIN MARC AS B
      ON  A~MATNR EQ B~MATNR
      AND A~WERKS EQ B~WERKS
      INNER JOIN ZGTCVORDSYVAL AS C
      ON  A~AUFNR EQ C~AUFNR
      FOR ALL ENTRIES IN @GT_SILSA
      WHERE A~WERKS EQ @P_WERKS "플랜트
        AND A~MATNR EQ @GT_SILSA-MATNR
        AND A~BWART IN ( '261', '262' )
*        AND b~dispo LIKE @lv_dispo
        AND A~AUFNR <> @SPACE
        AND A~BUDAT_MKPF >= @GV_START_DAY
        AND A~BUDAT_MKPF <= @GV_END_DAY
        AND C~MATNR IN @S_MATNR
        AND C~PDCAPROCCODE IN @S_GONG
        AND C~ARBPL IN @S_ARBPL.
* 생산 오더 상태 TECO, DLFL, CLSD 대상 제외
  LOOP AT GT_MSEG2 INTO GS_MSEG.

    GV_TABIX = SY-TABIX.
    IF P_ALL = ABAP_TRUE.
      GS_MSEG-CHARG = ''.
      MODIFY GT_MSEG2 FROM GS_MSEG INDEX SY-TABIX.
    ENDIF.


    IF GV_AUFNR IS INITIAL OR
      GV_AUFNR NE GS_MSEG-AUFNR.
      CLEAR : GV_EXIT.
      GV_AUFNR = GS_MSEG-AUFNR.
    ENDIF.

    IF GV_EXIT IS INITIAL.

      CLEAR : LT_TJ02T, LT_TJ02T[].
      CALL FUNCTION 'Z_PP_RETURN_ORDER_STATUS'
        EXPORTING
          IM_AUFNR        = GV_AUFNR
        TABLES
          ET_STTXT        = LT_TJ02T
        EXCEPTIONS
          NO_SELECTION    = 1
          NOT_FOUND_OBJNR = 2
          OTHERS          = 3.

      LOOP AT LT_TJ02T.

        CASE LT_TJ02T-TXT04.
          WHEN 'TECO' OR 'DLFL' OR 'CLSD'.
            GV_EXIT = ABAP_TRUE.
            EXIT.
          WHEN OTHERS.
        ENDCASE.

      ENDLOOP.

    ENDIF.

    IF GV_EXIT IS NOT INITIAL.
      DELETE GT_MSEG2 INDEX GV_TABIX.
    ENDIF.

  ENDLOOP.
*- 입고 정보
  IF GT_MSEG2[] IS NOT INITIAL.

    LT_MSEG[] = GT_MSEG2[].
    SORT LT_MSEG BY AUFNR.
    DELETE ADJACENT DUPLICATES FROM LT_MSEG COMPARING AUFNR.

    DATA : LT_BUDAT TYPE RANGE OF BUDAT.
    APPEND INITIAL LINE TO LT_BUDAT ASSIGNING FIELD-SYMBOL(<LS_BUDAT>).
    <LS_BUDAT>-SIGN = 'I'.
    <LS_BUDAT>-OPTION = 'BT'.
    <LS_BUDAT>-LOW = P_MONTH && '01'.
    <LS_BUDAT>-HIGH = <LS_BUDAT>-LOW.
    PERFORM GET_LAST_DAY_OF_MONTH CHANGING <LS_BUDAT>-HIGH.

    SELECT DISTINCT AUFNR FROM MATDOC
      INTO TABLE @DATA(LT_AUFNR)
      FOR ALL ENTRIES IN @LT_MSEG
     WHERE AUFNR = @LT_MSEG-AUFNR
       AND CANCELLED = ''
       AND BUDAT NOT IN @LT_BUDAT.
    IF SY-SUBRC EQ 0.
      LOOP AT LT_AUFNR INTO DATA(LS_AUFNR).
        DELETE GT_MSEG2 WHERE AUFNR = LS_AUFNR-AUFNR.
      ENDLOOP.


      SELECT A~*, C~MATNR AS MATNR2, C~PDCAPROCCODE, C~ARBPL
        INTO CORRESPONDING FIELDS OF TABLE @GT_MSEG
        FROM MSEG AS A INNER JOIN MARC AS B
          ON  A~MATNR EQ B~MATNR
          AND A~WERKS EQ B~WERKS
          INNER JOIN ZGTCVORDSYVAL AS C
          ON  A~AUFNR EQ C~AUFNR
          FOR ALL ENTRIES IN @LT_AUFNR
          WHERE A~WERKS EQ @P_WERKS "플랜트
            AND A~BWART IN ( '101', '102' )
            AND B~DISPO LIKE @LV_DISPO
            AND A~AUFNR EQ @LT_AUFNR-AUFNR
            AND A~BUDAT_MKPF >= @GV_START_DAY
            AND A~BUDAT_MKPF <= @GV_END_DAY
            AND C~MATNR IN @S_MATNR
            AND C~PDCAPROCCODE IN @S_GONG
            AND C~ARBPL IN @S_ARBPL.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_init_and_last_date
*&---------------------------------------------------------------------*
FORM GET_INIT_AND_LAST_DATE .

  CLEAR : GV_START_DAY, GV_END_DAY.
  GV_START_DAY = P_MONTH && '01'.
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = GV_START_DAY
    IMPORTING
      LAST_DAY_OF_MONTH = GV_END_DAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form collec_prod_order_adjustment
*&---------------------------------------------------------------------*
FORM COLLEC_PROD_ORDER_ADJUSTMENT .

  CLEAR : GS_DISP2, GT_DISP2.
*- 우선, 투입 정보부터 취합
  LOOP AT GT_MSEG2 INTO GS_MSEG.

    IF GS_MSEG-BWART = '262'.
      GS_MSEG-MENGE = GS_MSEG-MENGE * -1.
    ENDIF.

    CLEAR GS_DISP2.
    READ TABLE GT_DISP2 INTO GS_DISP2
                        WITH KEY AUFNR  = GS_MSEG-AUFNR
                                 MATNR2 = GS_MSEG-MATNR
                                 CHARG2 = GS_MSEG-CHARG.

    IF SY-SUBRC = 0.

      GS_DISP2-ERFMG2 = GS_DISP2-ERFMG2 + GS_MSEG-MENGE. "투입량
      MODIFY GT_DISP2 FROM GS_DISP2 INDEX SY-TABIX.

    ELSE.

      GS_DISP2-WERKS        = P_WERKS. "플랜트
      GS_DISP2-PDCAPROCCODE = GS_MSEG-PDCAPROCCODE. "공정 코드
      GS_DISP2-ARBPL        = GS_MSEG-ARBPL. "설비 코드
      GS_DISP2-AUFNR        = GS_MSEG-AUFNR. "생산 오더
      GS_DISP2-MATNR        = GS_MSEG-MATNR2."생산(반)제품
      GS_DISP2-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX(
        IV_MATNR = GS_DISP2-MATNR ). "내역
      GS_DISP2-MATNR2       = GS_MSEG-MATNR. "투입 자재
      GS_DISP2-MAKTX2 = ZGTPP_CL_COMMON=>GET_MAKTX(
        IV_MATNR = GS_DISP2-MATNR2 ). "내역
      GS_DISP2-CHARG2       = GS_MSEG-CHARG. "투입 배치
      GS_DISP2-LGORT2       = GS_MSEG-LGORT. "투입 저장위치
      GS_DISP2-ERFMG2       = GS_MSEG-MENGE. "투입량
      GS_DISP2-ERFME2       = GS_MSEG-MEINS. "투입 단위
      APPEND GS_DISP2 TO GT_DISP2.

    ENDIF.

  ENDLOOP.

  CHECK GT_DISP2[] IS NOT INITIAL.
*- 입고 정보 취합
  LOOP AT GT_DISP2 INTO GS_DISP2.

    GV_TABIX = SY-TABIX.

    LOOP AT GT_MSEG INTO GS_MSEG WHERE AUFNR EQ GS_DISP2-AUFNR.

      IF GS_MSEG-BWART = '102'.
        GS_MSEG-MENGE = GS_MSEG-MENGE * -1.
      ENDIF.

      GS_DISP2-MENGE1 = GS_DISP2-MENGE1 + GS_MSEG-MENGE. "입고량
      GS_DISP2-MEINS1 = GS_MSEG-MEINS. "입고 단위

    ENDLOOP.

    MODIFY GT_DISP2 FROM GS_DISP2 INDEX GV_TABIX.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form calculate_final_data
*&---------------------------------------------------------------------*
FORM CALCULATE_FINAL_DATA .

  DATA : LV_ERFMG LIKE MSEG-ERFMG. "차이량 반영용

  CHECK GT_DISP2[] IS NOT INITIAL.

  CLEAR : GS_DISP2_1, GT_DISP2_1[], GS_DISP2_2, GT_DISP2_2[].

  GT_DISP2_1[] = GT_DISP2[]. "총 입고량, 총 투입량.
  GT_DISP2_2[] = GT_DISP2[].
  CLEAR : GS_DISP2, GT_DISP2[].
* 생산 오더 투입량 조정 리스트 취합
  LOOP AT GT_ROW INTO GS_ROW.

    CLEAR : GS_DISP.
    READ TABLE GT_DISP INTO GS_DISP INDEX GS_ROW-INDEX.
* 차이량 음수일 때는 자재&배치 기준. 양수일 때는 자재 기준
    IF P_BWD = ABAP_TRUE.
      PERFORM CALCULATE_WITH_PLUS_BWD.
    ELSE.

      IF GS_DISP-CHAI < 0. "음수

        CASE ABAP_TRUE.
          WHEN P_SEL_B.
            PERFORM CALCULATE_WITH_MINUS.
          WHEN P_ALL.
            PERFORM CALCULATE_WITH_MINUS_ALL.
        ENDCASE.

      ELSEIF GS_DISP-CHAI > 0. "양수

        CASE ABAP_TRUE.
          WHEN P_SEL_B.
            PERFORM CALCULATE_WITH_PLUS.
          WHEN P_ALL.
            PERFORM CALCULATE_WITH_PLUS_ALL.
        ENDCASE.

      ENDIF.
    ENDIF.

  ENDLOOP.

  DELETE GT_DISP_1 WHERE CHAI = 0.
* 차이 잔여량 반영 및 상태값 업데이트
  LOOP AT GT_DISP2 INTO GS_DISP2.

    GV_TABIX = SY-TABIX.
* 차이 잔여량 반영( 계산 투입량 존재시에만 )
    IF GS_DISP2-MENGE4 NE 0.

      IF P_BWD = ABAP_TRUE.
        IF GT_DISP_1[] IS NOT INITIAL.
          CLEAR : GS_DISP_1, LV_ERFMG.
          READ TABLE GT_DISP_1 INTO GS_DISP_1 INDEX 1.
          LV_ERFMG = GS_DISP2-ERFMG5 + GS_DISP_1-CHAI.
          IF GS_DISP2-ERFMG2 < LV_ERFMG.
            LV_ERFMG = GS_DISP2-ERFMG5.
          ELSE.
            REFRESH GT_DISP_1.
          ENDIF.
        ELSE.
          LV_ERFMG = GS_DISP2-ERFMG5.
        ENDIF.
      ELSE.
        CASE ABAP_TRUE.
          WHEN P_SEL_B.
            CLEAR : GS_DISP_1, LV_ERFMG.
            READ TABLE GT_DISP_1 INTO GS_DISP_1 WITH KEY MATNR = GS_DISP2-MATNR2
                                                         CHARG = GS_DISP2-CHARG2.

            IF GS_DISP_1 IS NOT INITIAL.
              LV_ERFMG = GS_DISP2-ERFMG5 + GS_DISP_1-CHAI.
              DELETE GT_DISP_1 INDEX SY-TABIX.
            ELSE.
              LV_ERFMG = GS_DISP2-ERFMG5.
            ENDIF.

          WHEN P_ALL.
            IF LINE_EXISTS( GT_DISP_1[ CHARG = GS_DISP2-CHARG5 ] ).
              CLEAR : GS_DISP_1, LV_ERFMG.
              READ TABLE GT_DISP_1 INTO GS_DISP_1 WITH KEY CHARG = GS_DISP2-CHARG5.
              LV_ERFMG = GS_DISP2-ERFMG5 + GS_DISP_1-CHAI.
              DELETE GT_DISP_1 WHERE CHARG = GS_DISP2-CHARG5.
            ELSE.
              LV_ERFMG = GS_DISP2-ERFMG5.
            ENDIF.
        ENDCASE.
      ENDIF.

    ELSE.
      LV_ERFMG = GS_DISP2-ERFMG5.
    ENDIF.
* 상태값 업데이트
* 음수 : 투입량 초과 또는 동일 시 에러 표시.
    IF LV_ERFMG < 0.

      IF P_WERKS+0(1) NE '6'.
        LV_ERFMG = LV_ERFMG * -1.
        IF GS_DISP2-ERFMG2 =< LV_ERFMG.
          GS_DISP2-ICON = ICON_LED_RED.
        ENDIF.
        LV_ERFMG = LV_ERFMG * -1.
      ENDIF.
    ENDIF.

    IF LV_ERFMG NE 0.
      GS_DISP2-ERFMG5 = LV_ERFMG.
    ENDIF.
* 조정량이 비어있으면 상태값 빨간불 표시
    IF P_BWD = ABAP_TRUE AND GS_DISP2-MENGE4 EQ 0.
      GS_DISP2-ICON = ICON_LED_RED.
    ENDIF.

    IF GS_DISP2-ERFMG5 EQ 0.
      GS_DISP2-ICON = ICON_LED_RED.
    ENDIF.
* 상태값이 비었을 경우 준비 완료로 판단
    IF GS_DISP2-ICON IS INITIAL.
      GS_DISP2-ICON = ICON_LED_INACTIVE.
    ENDIF.

    MODIFY GT_DISP2 FROM GS_DISP2 INDEX GV_TABIX.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_line_check2
*&---------------------------------------------------------------------*
FORM SELECT_LINE_CHECK2 .

  IF GT_ROW[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E01.
    RETURN.
  ENDIF.
* 만약, 에러 건 선택 시 에러 메시지 출력 후 진행 중단
  CLEAR GV_EXIT.
  LOOP AT GT_ROW INTO GS_ROW.

    READ TABLE GT_DISP2 INTO GS_DISP2 INDEX GS_ROW-INDEX.
    IF GS_DISP2-ICON NE ICON_LED_INACTIVE.
      MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E04.
      GV_EXIT = ABAP_TRUE.
      EXIT.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form adjust_gi_prod_order
*&---------------------------------------------------------------------*
FORM ADJUST_GI_PROD_ORDER .

  DATA : LS_HEADER   TYPE BAPI2017_GM_HEAD_01,
         LV_CODE     TYPE BAPI2017_GM_CODE VALUE '03',
         LT_ITEM     TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
         LS_ITEM     TYPE BAPI2017_GM_ITEM_CREATE,
         LV_DOCUMENT TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
         LV_YEAR     TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
         LT_RETURN   TYPE TABLE OF BAPIRET2.

  DATA : LT_CHG_0600 TYPE TABLE OF ZPPT0600.
  DATA : LT_CHK_CHG_0600 TYPE TABLE OF ZPPT0600.
  DATA : LT_0600 TYPE TABLE OF ZPPT0600.


  DATA : LV_BWART        TYPE BWART,
         LV_MESSAGE(100),
         LV_ICON(4).

  DATA : LV_ERFMG LIKE GS_DISP2-ERFMG5.

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  CLEAR : LV_MESSAGE, LV_DOCUMENT, LV_YEAR, LT_RETURN,
          LS_ITEM, LT_ITEM, LS_HEADER, LV_ICON.
  REFRESH LT_CELLTAB.

  LT_0600 = GT_0600.

  LS_HEADER = VALUE #( PSTNG_DATE = GV_END_DAY
                       DOC_DATE   = GV_END_DAY
                       PR_UNAME   = SY-UNAME
                       HEADER_TXT = TEXT-007 ).

  LOOP AT GT_ROW INTO GS_ROW.

    READ TABLE GT_DISP2 INTO GS_DISP2 INDEX GS_ROW-INDEX.

    CLEAR LV_BWART.
    IF GS_DISP2-ERFMG5 < 0.

      IF P_WERKS+0(1) = '6'.
        LV_BWART = '261'.
        LV_ERFMG = GS_DISP2-ERFMG5 * -1.

        READ TABLE LT_0600 INTO DATA(LS_MENGE_DIFF) WITH KEY MATNR = GS_DISP2-MATNR2
                                                             LGORT = GS_DISP2-LGORT5
                                                             CHARG = GS_DISP2-CHARG5.
        IF SY-SUBRC EQ 0.
          LS_MENGE_DIFF-MENGE_DIF = LV_ERFMG.
          APPEND LS_MENGE_DIFF TO LT_CHK_CHG_0600.
        ENDIF.

      ELSE.
        LV_BWART = '262'.
        LV_ERFMG = GS_DISP2-ERFMG5 * -1.
      ENDIF.
    ELSE.
      IF P_WERKS+0(1) = '6'.
        LV_BWART = '262'.
        LV_ERFMG = GS_DISP2-ERFMG5.

        READ TABLE LT_0600 INTO LS_MENGE_DIFF WITH KEY MATNR = GS_DISP2-MATNR2
                                                       LGORT = GS_DISP2-LGORT5
                                                       CHARG = GS_DISP2-CHARG5.
        IF SY-SUBRC EQ 0.
          LS_MENGE_DIFF-MENGE_DIF = LV_ERFMG * -1.
          APPEND LS_MENGE_DIFF TO LT_CHK_CHG_0600.
        ENDIF.

      ELSE.
        LV_BWART = '261'.
        LV_ERFMG = GS_DISP2-ERFMG5.
      ENDIF.
    ENDIF.

    APPEND VALUE #( MATERIAL   = GS_DISP2-MATNR2
                    PLANT      = GS_DISP2-WERKS
                    STGE_LOC   = GS_DISP2-LGORT5
                    BATCH      = GS_DISP2-CHARG5
                    MOVE_TYPE  = LV_BWART
                    ENTRY_QNT  = LV_ERFMG
                    ENTRY_UOM  = GS_DISP2-ERFME2
                    ORDERID    = GS_DISP2-AUFNR
                    ORDER_ITNO = '0001' ) TO LT_ITEM.

  ENDLOOP.
*- 투입 처리 (펑션 호출)
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = LS_HEADER
      GOODSMVT_CODE    = LV_CODE
    IMPORTING
      MATERIALDOCUMENT = LV_DOCUMENT
      MATDOCUMENTYEAR  = LV_YEAR
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
      RETURN           = LT_RETURN.
*- 실패
  IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    LV_MESSAGE = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
    LV_ICON    = ICON_LED_RED.
*- 성공
    IF P_WERKS+0(1) = '6'.
      REFRESH LT_CHK_CHG_0600.
    ENDIF.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
    LV_MESSAGE = TEXT-008 && LV_DOCUMENT.
    MESSAGE S003 WITH LV_MESSAGE.
    LV_ICON    = ICON_LED_GREEN.
  ENDIF.
* 결과 반영
  LOOP AT GT_ROW INTO GS_ROW.

    READ TABLE GT_DISP2 INTO GS_DISP2 INDEX GS_ROW-INDEX.

    GS_DISP2-MESSAGE = LV_MESSAGE.
    GS_DISP2-ICON    = LV_ICON.
    IF LV_ICON = ICON_LED_GREEN.
      CLEAR LS_CELLTAB.
      LS_CELLTAB-FIELDNAME = 'ERFMG5'.
      LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
      INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
      GS_DISP2-CELLTAB = LT_CELLTAB.
    ENDIF.
    MODIFY GT_DISP2 FROM GS_DISP2 INDEX GS_ROW-INDEX.

  ENDLOOP.

* 이동처리한 수량 섬.
  IF P_WERKS+0(1) = '6'.
    LT_CHG_0600 = LT_CHK_CHG_0600.
    SORT LT_CHG_0600 BY INSMM WERKS LGORT SEQNO MATNR CHARG TAGNR.
    DELETE ADJACENT DUPLICATES FROM LT_CHG_0600 COMPARING INSMM WERKS SEQNO LGORT MATNR CHARG TAGNR.

    LOOP AT LT_CHG_0600 INTO DATA(LS_CHG_0600).
*  저장데이터 전기된 차이수량
      READ TABLE LT_0600 INTO DATA(LS_ORIGN_0600) WITH KEY MATNR = LS_CHG_0600-MATNR
                                                             LGORT = LS_CHG_0600-LGORT
                                                             CHARG = LS_CHG_0600-CHARG.
      IF SY-SUBRC EQ 0.
        LOOP AT LT_CHK_CHG_0600 INTO DATA(LS_DIFF) WHERE MATNR = LS_CHG_0600-MATNR
                                                     AND LGORT = LS_CHG_0600-LGORT
                                                     AND CHARG = LS_CHG_0600-CHARG.
          ADD LS_DIFF-MENGE_DIF TO LS_ORIGN_0600-MENGE_DIF.
        ENDLOOP.

        UPDATE ZPPT0600 SET MENGE_DIF = LS_ORIGN_0600-MENGE_DIF
         WHERE INSMM = LS_CHG_0600-INSMM
           AND WERKS = LS_CHG_0600-WERKS
           AND LGORT = LS_CHG_0600-LGORT
           AND SEQNO = LS_CHG_0600-SEQNO
           AND MATNR = LS_CHG_0600-MATNR
           AND CHARG = LS_CHG_0600-CHARG
           AND TAGNR = LS_CHG_0600-TAGNR.
        COMMIT WORK AND WAIT.

      ENDIF.
    ENDLOOP.

  ENDIF.
* 실사 수량 정보 갱신
  PERFORM GET_DATA.

  PERFORM REFRESH_DISPLAY_ALL_ALV.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALCULATE_WITH_MINUS
*&---------------------------------------------------------------------*
FORM CALCULATE_WITH_MINUS .
* 총 입고량, 투입량 취합
  CLEAR : GV_MENGE, GV_ERFMG.
  LOOP AT GT_DISP2_1 INTO GS_DISP2_1
               WHERE MATNR2 EQ GS_DISP-MATNR
                  AND CHARG2 EQ GS_DISP-CHARG.

    GV_MENGE = GV_MENGE + GS_DISP2_1-MENGE1. "총 입고량
    GV_ERFMG = GV_ERFMG + GS_DISP2_1-ERFMG2. "총 투입량

  ENDLOOP.

  LOOP AT GT_DISP2_2 INTO GS_DISP2_2
                     WHERE MATNR2 EQ GS_DISP-MATNR
                       AND CHARG2 EQ GS_DISP-CHARG.

    CLEAR GS_DISP2.
    MOVE-CORRESPONDING GS_DISP2_2 TO GS_DISP2.
* 가중치(%) 계산 : ( 입고량 / 총 입고량[ 자재, 배치 기준 합산] ) * 100
    IF P_INPUT = ABAP_TRUE. " 입고량기준
      IF GS_DISP2-MENGE1 NE 0 AND GV_MENGE NE 0.
        GS_DISP2-MENGE3 = ( GS_DISP2-MENGE1 / GV_MENGE ) * 100.
      ENDIF.
    ELSE. " 투입량 기준
      IF GS_DISP2-ERFMG2 NE 0 AND GV_ERFMG NE 0.
        GS_DISP2-MENGE3 = ( GS_DISP2-ERFMG2 / GV_ERFMG ) * 100.
      ENDIF.
    ENDIF.
* 계산 투입량 계산 : ( 총 투입량 + 실사 차이량 ) * ( 가중치(%) / 100 )
    IF GS_DISP2-MENGE3 NE 0.
      GS_DISP2-MENGE4 = ( GV_ERFMG + GS_DISP-CHAI ) *
                        ( GS_DISP2-MENGE3 / 100 ).
    ENDIF.
* 조정량 계산 : 계산 투입량 - 투입량
    GS_DISP2-ERFMG5 = GS_DISP2-MENGE4 - GS_DISP2-ERFMG2.
* 차이량에서 조정량을 반영하여 차감( 계산 투입량 존재시에만 )
    IF GS_DISP2-MENGE4 NE 0.

      CLEAR GS_DISP_1.
      READ TABLE GT_DISP_1 INTO GS_DISP_1
                           WITH KEY MATNR = GS_DISP-MATNR
                                    CHARG = GS_DISP-CHARG.
      IF SY-SUBRC = 0.
        GS_DISP_1-CHAI = GS_DISP_1-CHAI - GS_DISP2-ERFMG5.
        MODIFY GT_DISP_1 FROM GS_DISP_1 INDEX SY-TABIX.
      ENDIF.

    ENDIF.

    GS_DISP2-CHARG5 = GS_DISP-CHARG.
    GS_DISP2-LGORT5 = GS_DISP-LGORT.
    APPEND GS_DISP2 TO GT_DISP2.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form calculate_with_plus
*&---------------------------------------------------------------------*
FORM CALCULATE_WITH_PLUS .

  DATA : LV_AUFNR LIKE MSEG-AUFNR.
* 총 입고량, 투입량 취합
  CLEAR : GV_MENGE, GV_ERFMG, LV_AUFNR.
  LOOP AT GT_DISP2_1 INTO GS_DISP2_1
               WHERE MATNR2 EQ GS_DISP-MATNR.

    GV_MENGE = GV_MENGE + GS_DISP2_1-MENGE1. "총 입고량
    GV_ERFMG = GV_ERFMG + GS_DISP2_1-ERFMG2. "총 투입량

  ENDLOOP.

  LOOP AT GT_DISP2_2 INTO GS_DISP2_2
                     WHERE MATNR2 EQ GS_DISP-MATNR.

    CLEAR GS_DISP2.
    MOVE-CORRESPONDING GS_DISP2_2 TO GS_DISP2.
* 가중치(%) 계산 : ( 입고량 / 총 입고량[ 자재, 배치 기준 합산] ) * 100
    IF P_INPUT = ABAP_TRUE. " 입고량기준
      IF GS_DISP2-MENGE1 NE 0 AND GV_MENGE NE 0.
        GS_DISP2-MENGE3 = ( GS_DISP2-MENGE1 / GV_MENGE ) * 100.
      ENDIF.
    ELSE. " 투입량 기준
      IF GS_DISP2-ERFMG2 NE 0 AND GV_ERFMG NE 0.
        GS_DISP2-MENGE3 = ( GS_DISP2-ERFMG2 / GV_ERFMG ) * 100.
      ENDIF.
    ENDIF.
* 계산 투입량 계산 : ( 총 투입량 + 실사 차이량 ) * ( 가중치(%) / 100 )
    IF GS_DISP2-MENGE3 NE 0.
      GS_DISP2-MENGE4 = ( GV_ERFMG + GS_DISP-CHAI ) *
                        ( GS_DISP2-MENGE3 / 100 ).
    ENDIF.
* 조정량 계산 : 계산 투입량 - 투입량
    GS_DISP2-ERFMG5 = GS_DISP2-MENGE4 - GS_DISP2-ERFMG2.
* 차이량에서 조정량을 반영하여 차감( 계산 투입량 존재시에만 )
    IF GS_DISP2-MENGE4 NE 0.

      CLEAR GS_DISP_1.
      READ TABLE GT_DISP_1 INTO GS_DISP_1
                           WITH KEY MATNR = GS_DISP-MATNR
                                    CHARG = GS_DISP-CHARG.
      IF SY-SUBRC = 0.
        GS_DISP_1-CHAI = GS_DISP_1-CHAI - GS_DISP2-ERFMG5.
        MODIFY GT_DISP_1 FROM GS_DISP_1 INDEX SY-TABIX.
      ENDIF.

    ENDIF.

    GS_DISP2-CHARG5 = GS_DISP-CHARG.
    GS_DISP2-LGORT5 = GS_DISP-LGORT.
    APPEND GS_DISP2 TO GT_DISP2.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALCULATE_WITH_MINUS_ALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALCULATE_WITH_MINUS_ALL .

* 총 입고량, 투입량 취합
  CLEAR : GV_MENGE, GV_ERFMG.
  LOOP AT GT_DISP2_1 INTO GS_DISP2_1
               WHERE MATNR2 EQ GS_DISP-MATNR.

    GV_MENGE = GV_MENGE + GS_DISP2_1-MENGE1. "총 입고량
    GV_ERFMG = GV_ERFMG + GS_DISP2_1-ERFMG2. "총 투입량

  ENDLOOP.

  LOOP AT GT_DISP2_2 INTO GS_DISP2_2
                     WHERE MATNR2 EQ GS_DISP-MATNR.

    CLEAR GS_DISP2.
    MOVE-CORRESPONDING GS_DISP2_2 TO GS_DISP2.
* 가중치(%) 계산 : ( 입고량 / 총 입고량[ 자재, 배치 기준 합산] ) * 100
    IF P_INPUT = ABAP_TRUE. " 입고량기준
      IF GS_DISP2-MENGE1 NE 0 AND GV_MENGE NE 0.
        GS_DISP2-MENGE3 = ( GS_DISP2-MENGE1 / GV_MENGE ) * 100.
      ENDIF.
    ELSE. " 투입량 기준
      IF GS_DISP2-ERFMG2 NE 0 AND GV_ERFMG NE 0.
        GS_DISP2-MENGE3 = ( GS_DISP2-ERFMG2 / GV_ERFMG ) * 100.
      ENDIF.
    ENDIF.
* 계산 투입량 계산 : ( 총 투입량 + 실사 차이량 ) * ( 가중치(%) / 100 )
    IF GS_DISP2-MENGE3 NE 0.
      GS_DISP2-MENGE4 = GS_DISP-CHAI * ( GS_DISP2-MENGE3 / 100 ).
    ENDIF.
* 조정량 계산 : 계산 투입량 - 투입량
    GS_DISP2-ERFMG5 = GS_DISP2-MENGE4.
* 차이량에서 조정량을 반영하여 차감( 계산 투입량 존재시에만 )
    IF GS_DISP2-MENGE4 NE 0.

      CLEAR GS_DISP_1.
      READ TABLE GT_DISP_1 ASSIGNING FIELD-SYMBOL(<LS_DISP>)
                           WITH KEY MATNR = GS_DISP-MATNR
                                    CHARG = GS_DISP-CHARG.
      IF SY-SUBRC = 0.
        <LS_DISP>-CHAI = <LS_DISP>-CHAI - GS_DISP2-ERFMG5.
      ENDIF.

    ENDIF.

    GS_DISP2-CHARG5 = GS_DISP-CHARG.
    GS_DISP2-LGORT5 = GS_DISP-LGORT.
    APPEND GS_DISP2 TO GT_DISP2.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALCULATE_WITH_PLUS_ALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALCULATE_WITH_PLUS_ALL .

  DATA : LV_AUFNR LIKE MSEG-AUFNR.
* 총 입고량, 투입량 취합
  CLEAR : GV_MENGE, GV_ERFMG, LV_AUFNR.
  LOOP AT GT_DISP2_1 INTO GS_DISP2_1
               WHERE MATNR2 EQ GS_DISP-MATNR.

    GV_MENGE = GV_MENGE + GS_DISP2_1-MENGE1. "총 입고량
    GV_ERFMG = GV_ERFMG + GS_DISP2_1-ERFMG2. "총 투입량

  ENDLOOP.

  LOOP AT GT_DISP2_2 INTO GS_DISP2_2
                     WHERE MATNR2 EQ GS_DISP-MATNR.

    CLEAR GS_DISP2.
    MOVE-CORRESPONDING GS_DISP2_2 TO GS_DISP2.
* 가중치(%) 계산 : ( 입고량 / 총 입고량[ 자재, 배치 기준 합산] ) * 100
    IF P_INPUT = ABAP_TRUE. " 입고량기준
      IF GS_DISP2-MENGE1 NE 0 AND GV_MENGE NE 0.
        GS_DISP2-MENGE3 = ( GS_DISP2-MENGE1 / GV_MENGE ) * 100.
      ENDIF.
    ELSE. " 투입량 기준
      IF GS_DISP2-ERFMG2 NE 0 AND GV_ERFMG NE 0.
        GS_DISP2-MENGE3 = ( GS_DISP2-ERFMG2 / GV_ERFMG ) * 100.
      ENDIF.
    ENDIF.
* 계산 투입량 계산 : ( 총 투입량 + 실사 차이량 ) * ( 가중치(%) / 100 )
    IF GS_DISP2-MENGE3 NE 0.
      GS_DISP2-MENGE4 = GS_DISP-CHAI * ( GS_DISP2-MENGE3 / 100 ).
    ENDIF.
* 조정량 계산 : 계산 투입량 - 투입량
    GS_DISP2-ERFMG5 = GS_DISP2-MENGE4.
* 차이량에서 조정량을 반영하여 차감( 계산 투입량 존재시에만 )
    IF GS_DISP2-MENGE4 NE 0.
      CLEAR GS_DISP_1.
      READ TABLE GT_DISP_1 INTO GS_DISP_1
                           WITH KEY MATNR = GS_DISP-MATNR
                                    CHARG = GS_DISP-CHARG.
      IF SY-SUBRC = 0.
        GS_DISP_1-CHAI = GS_DISP_1-CHAI - GS_DISP2-ERFMG5.
        MODIFY GT_DISP_1 FROM GS_DISP_1 INDEX SY-TABIX.
      ENDIF.

    ENDIF.

    IF P_BWD = ABAP_TRUE.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          INPUT  = GS_DISP-MATNR
        IMPORTING
          OUTPUT = GS_DISP2-CHARG5.
    ELSE.
      GS_DISP2-CHARG5 = GS_DISP-CHARG.
    ENDIF.
    GS_DISP2-LGORT5 = GS_DISP-LGORT.
    APPEND GS_DISP2 TO GT_DISP2.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADJUST_GI_PROD_ORDER_GAON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ADJUST_GI_PROD_ORDER_GAON .

  DATA : LS_HEADER   TYPE BAPI2017_GM_HEAD_01,
         LV_CODE     TYPE BAPI2017_GM_CODE VALUE '03',
         LT_ITEM_FUL TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
         LT_ITEM     TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
         LS_ITEM     TYPE BAPI2017_GM_ITEM_CREATE,
         LV_DOCUMENT TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
         LV_YEAR     TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
         LT_RETURN   TYPE TABLE OF BAPIRET2.
  DATA : LV_BUDAT TYPE BUDAT.

  DATA : LT_CHK_CHG_0600 TYPE TABLE OF ZPPT0600.
  DATA : LT_0600 TYPE TABLE OF ZPPT0600.

  DATA : LV_BWART        TYPE BWART,
         LV_MESSAGE(100),
         LV_ICON(4).

  DATA : BEGIN OF LS_SORT_BATCH,
           BATCH    TYPE BAPI2017_GM_ITEM_CREATE-BATCH,
           ERR_TYPE TYPE C,
         END OF LS_SORT_BATCH.
  DATA : LT_SORT_BATCH LIKE TABLE OF LS_SORT_BATCH.

  DATA : LV_ERFMG LIKE GS_DISP2-ERFMG5.

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  CLEAR : LV_MESSAGE, LV_DOCUMENT, LV_YEAR, LT_RETURN,
          LS_ITEM, LT_ITEM, LS_HEADER, LV_ICON.
  REFRESH LT_CELLTAB.

  LT_0600 = GT_0600.

  IF P_BUDAT IS INITIAL OR P_BUDAT = '00000000'.
    LV_BUDAT = GV_END_DAY.
  ELSE.
    LV_BUDAT = P_BUDAT.
  ENDIF.


  LS_HEADER = VALUE #( PSTNG_DATE = LV_BUDAT
                       DOC_DATE   = LV_BUDAT
                       PR_UNAME   = SY-UNAME
                       HEADER_TXT = TEXT-007 ).

  LOOP AT GT_ROW INTO GS_ROW.

    READ TABLE GT_DISP2 INTO GS_DISP2 INDEX GS_ROW-INDEX.

    CLEAR LV_BWART.
    IF GS_DISP2-ERFMG5 < 0.

      LV_BWART = '261'.
      LV_ERFMG = GS_DISP2-ERFMG5 * -1.

      READ TABLE LT_0600 INTO DATA(LS_MENGE_DIFF) WITH KEY MATNR = GS_DISP2-MATNR2
                                                           LGORT = GS_DISP2-LGORT5
                                                           CHARG = GS_DISP2-CHARG5.
      IF SY-SUBRC EQ 0.
        LS_MENGE_DIFF-MENGE_DIF = LV_ERFMG.
        APPEND LS_MENGE_DIFF TO LT_CHK_CHG_0600.

        CLEAR LS_SORT_BATCH.
        LS_SORT_BATCH-BATCH = LS_MENGE_DIFF-CHARG.
        COLLECT LS_SORT_BATCH INTO LT_SORT_BATCH.

      ENDIF.

    ELSE.
      LV_BWART = '262'.
      LV_ERFMG = GS_DISP2-ERFMG5.

      READ TABLE LT_0600 INTO LS_MENGE_DIFF WITH KEY MATNR = GS_DISP2-MATNR2
                                                     LGORT = GS_DISP2-LGORT5
                                                     CHARG = GS_DISP2-CHARG5.
      IF SY-SUBRC EQ 0.
        LS_MENGE_DIFF-MENGE_DIF = LV_ERFMG * -1.
        APPEND LS_MENGE_DIFF TO LT_CHK_CHG_0600.

        CLEAR LS_SORT_BATCH.
        LS_SORT_BATCH-BATCH = LS_MENGE_DIFF-CHARG.
        COLLECT LS_SORT_BATCH INTO LT_SORT_BATCH.

      ENDIF.

    ENDIF.

    APPEND VALUE #( MATERIAL   = GS_DISP2-MATNR2
                    PLANT      = GS_DISP2-WERKS
                    STGE_LOC   = GS_DISP2-LGORT5
                    BATCH      = GS_DISP2-CHARG5
                    MOVE_TYPE  = LV_BWART
                    ENTRY_QNT  = LV_ERFMG
                    ENTRY_UOM  = GS_DISP2-ERFME2
                    ORDERID    = GS_DISP2-AUFNR
                    ORDER_ITNO = '0001' ) TO LT_ITEM_FUL.

  ENDLOOP.

  LOOP AT LT_SORT_BATCH INTO LS_SORT_BATCH.

    CLEAR : LV_DOCUMENT, LV_YEAR.
    REFRESH  LT_RETURN.

    REFRESH LT_ITEM.
    LT_ITEM = VALUE #( FOR LW_ITEM IN LT_ITEM_FUL WHERE ( BATCH = LS_SORT_BATCH-BATCH )
                     ( CORRESPONDING #( LW_ITEM ) ) ).

*- 투입 처리 (펑션 호출)
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = LS_HEADER
        GOODSMVT_CODE    = LV_CODE
      IMPORTING
        MATERIALDOCUMENT = LV_DOCUMENT
        MATDOCUMENTYEAR  = LV_YEAR
      TABLES
        GOODSMVT_ITEM    = LT_ITEM
        RETURN           = LT_RETURN.
*- 실패
    IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      LV_MESSAGE = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
      LV_ICON    = ICON_LED_RED.

      DELETE LT_CHK_CHG_0600 WHERE CHARG = LS_SORT_BATCH-BATCH.
      LS_SORT_BATCH-ERR_TYPE = 'E'.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
      LV_MESSAGE = TEXT-008 && LV_DOCUMENT.
      MESSAGE S003 WITH LV_MESSAGE.
      LV_ICON    = ICON_LED_GREEN.
    ENDIF.
* 결과 반영
    LOOP AT GT_ROW INTO GS_ROW.

      READ TABLE GT_DISP2 INTO GS_DISP2 INDEX GS_ROW-INDEX.

      IF GS_DISP2-CHARG5 = LS_SORT_BATCH-BATCH.
        GS_DISP2-MESSAGE = LV_MESSAGE.
        GS_DISP2-ICON    = LV_ICON.
        IF LV_ICON = ICON_LED_GREEN.
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = 'ERFMG5'.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
          GS_DISP2-CELLTAB = LT_CELLTAB.
        ENDIF.
        MODIFY GT_DISP2 FROM GS_DISP2 INDEX GS_ROW-INDEX.
      ENDIF.
    ENDLOOP.

* 이동처리한 수량 섬.
    IF P_WERKS+0(1) = '6'.
*  저장데이터 전기된 차이수량
      READ TABLE LT_0600 INTO DATA(LS_ORIGN_0600) WITH KEY CHARG = LS_SORT_BATCH-BATCH.
      IF SY-SUBRC EQ 0.
        LOOP AT LT_CHK_CHG_0600 INTO DATA(LS_DIFF) WHERE CHARG = LS_SORT_BATCH-BATCH.
          ADD LS_DIFF-MENGE_DIF TO LS_ORIGN_0600-MENGE_DIF.
        ENDLOOP.

        UPDATE ZPPT0600 SET MENGE_DIF = LS_ORIGN_0600-MENGE_DIF
         WHERE INSMM = LS_ORIGN_0600-INSMM
           AND WERKS = LS_ORIGN_0600-WERKS
           AND LGORT = LS_ORIGN_0600-LGORT
           AND SEQNO = LS_ORIGN_0600-SEQNO
           AND MATNR = LS_ORIGN_0600-MATNR
           AND CHARG = LS_ORIGN_0600-CHARG
           AND TAGNR = LS_ORIGN_0600-TAGNR.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.

  ENDLOOP.
* 실사 수량 정보 갱신
  PERFORM GET_DATA.

  PERFORM REFRESH_DISPLAY_ALL_ALV.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADJUST_GI_PROD_ORDER_BWD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ADJUST_GI_PROD_ORDER_BWD .

  DATA : LS_HEADER    TYPE BAPI2017_GM_HEAD_01,
         LV_CODE      TYPE BAPI2017_GM_CODE VALUE '03',
         LV_CODE_CONV TYPE BAPI2017_GM_CODE VALUE '04',
         LT_ITEM      TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
         LS_ITEM      TYPE BAPI2017_GM_ITEM_CREATE,
         LV_DOCUMENT  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
         LV_YEAR      TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
         LT_RETURN    TYPE TABLE OF BAPIRET2.

  DATA : LV_BWART        TYPE BWART,
         LV_MESSAGE(100),
         LV_ICON(4).
  DATA : LV_CHK_ERR.
  DATA : LV_BUDAT TYPE BUDAT.

  DATA : BEGIN OF LS_MOVE_HISTORY,
           AUFNR            TYPE AUFNR,
           CHARG            LIKE MSEG-CHARG, "투입 배치
           LGORT            LIKE MSEG-LGORT, "투입 저장위치
           262_MOVE         TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
           262_MOVE_YEAR    TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
           262_ROLL_MESSAGE TYPE CHAR100,
           311_CONV         TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
           311_CONV_YEAR    TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
           311_ROLL_MESSAGE TYPE CHAR100,
         END OF LS_MOVE_HISTORY.
  DATA : LT_MOVE_HISTORY LIKE TABLE OF LS_MOVE_HISTORY.

  DATA : LV_ERFMG LIKE GS_DISP2-ERFMG5.

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  CLEAR : LV_MESSAGE, LV_DOCUMENT, LV_YEAR, LT_RETURN,
          LS_ITEM, LT_ITEM, LS_HEADER, LV_ICON.

  REFRESH LT_CELLTAB.

  IF P_BUDAT IS INITIAL OR P_BUDAT = '00000000'.
    LV_BUDAT = GV_END_DAY.
  ELSE.
    LV_BUDAT = P_BUDAT.
  ENDIF.


  LS_HEADER = VALUE #( PSTNG_DATE = LV_BUDAT
                       DOC_DATE   = LV_BUDAT
                       PR_UNAME   = SY-UNAME
                       HEADER_TXT = TEXT-007 ).

  LOOP AT GT_ROW INTO GS_ROW.

    READ TABLE GT_DISP2 ASSIGNING FIELD-SYMBOL(<LS_DISP2>) INDEX GS_ROW-INDEX.

    CLEAR LV_BWART.
    LV_BWART = '262'.
    LV_ERFMG = <LS_DISP2>-ERFMG5.

    REFRESH LT_ITEM.
    APPEND VALUE #( MATERIAL   = <LS_DISP2>-MATNR2
                    PLANT      = <LS_DISP2>-WERKS
                    STGE_LOC   = <LS_DISP2>-LGORT2
                    BATCH      = <LS_DISP2>-CHARG2
                    MOVE_TYPE  = LV_BWART
                    ENTRY_QNT  = LV_ERFMG
                    ENTRY_UOM  = <LS_DISP2>-ERFME2
                    ORDERID    = <LS_DISP2>-AUFNR
                    ORDER_ITNO = '0001' ) TO LT_ITEM.

    APPEND INITIAL LINE TO LT_MOVE_HISTORY ASSIGNING FIELD-SYMBOL(<LS_HISTORY>).
    <LS_HISTORY>-AUFNR = <LS_DISP2>-AUFNR.
    <LS_HISTORY>-CHARG = <LS_DISP2>-CHARG2.
    <LS_HISTORY>-LGORT = <LS_DISP2>-LGORT2.

*- 262처리 (펑션 호출)
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = LS_HEADER
        GOODSMVT_CODE    = LV_CODE
      IMPORTING
        MATERIALDOCUMENT = LV_DOCUMENT
        MATDOCUMENTYEAR  = LV_YEAR
      TABLES
        GOODSMVT_ITEM    = LT_ITEM
        RETURN           = LT_RETURN.
*- 실패
    IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      LV_MESSAGE = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
      DELETE LT_MOVE_HISTORY.
      LV_CHK_ERR = ABAP_TRUE.
      EXIT.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
      <LS_HISTORY>-262_MOVE = LV_DOCUMENT.
      <LS_HISTORY>-262_MOVE_YEAR = LV_YEAR.

    ENDIF.

    REFRESH LT_ITEM.
    APPEND VALUE #( MATERIAL   = <LS_DISP2>-MATNR2
                    PLANT      = <LS_DISP2>-WERKS
                    STGE_LOC   = <LS_DISP2>-LGORT2
                    BATCH      = <LS_DISP2>-CHARG2
                    MOVE_TYPE  = '311'
                    ENTRY_QNT  = LV_ERFMG
                    ENTRY_UOM  = <LS_DISP2>-ERFME2
                    MOVE_MAT = <LS_DISP2>-MATNR2
                    MOVE_PLANT = <LS_DISP2>-WERKS
                    MOVE_STLOC = <LS_DISP2>-LGORT5
                    MOVE_BATCH = <LS_DISP2>-CHARG5
                    ORDER_ITNO = '0001' ) TO LT_ITEM.

    CLEAR : LV_DOCUMENT, LV_YEAR.
    REFRESH : LT_RETURN.

*- 311처리 (펑션 호출)
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = LS_HEADER
        GOODSMVT_CODE    = '04'
      IMPORTING
        MATERIALDOCUMENT = LV_DOCUMENT
        MATDOCUMENTYEAR  = LV_YEAR
      TABLES
        GOODSMVT_ITEM    = LT_ITEM
        RETURN           = LT_RETURN.
*- 실패
    IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      LV_MESSAGE = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
      LV_CHK_ERR = ABAP_TRUE.
      EXIT.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
      <LS_HISTORY>-311_CONV = LV_DOCUMENT.
      <LS_HISTORY>-311_CONV_YEAR = LV_YEAR.
      LV_MESSAGE = TEXT-008 && LV_DOCUMENT.
      <LS_DISP2>-MESSAGE = LV_MESSAGE.
    ENDIF.

  ENDLOOP.

  IF LV_CHK_ERR IS NOT INITIAL.
    LOOP AT LT_MOVE_HISTORY ASSIGNING <LS_HISTORY>.
      IF <LS_HISTORY>-311_CONV IS NOT INITIAL.
        REFRESH LT_RETURN.
        CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
          EXPORTING
            MATERIALDOCUMENT    = <LS_HISTORY>-311_CONV
            MATDOCUMENTYEAR     = <LS_HISTORY>-311_CONV_YEAR
            GOODSMVT_PSTNG_DATE = SY-DATUM  "sy-datum
          TABLES
            RETURN              = LT_RETURN.

        READ TABLE LT_RETURN TRANSPORTING NO FIELDS WITH KEY TYPE = 'E'.
        IF SY-SUBRC = 0.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          <LS_HISTORY>-311_ROLL_MESSAGE = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
          CONTINUE.
        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = 'X'.
        ENDIF.
      ENDIF.

      IF <LS_HISTORY>-262_MOVE IS NOT INITIAL.
        REFRESH LT_RETURN.
        CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
          EXPORTING
            MATERIALDOCUMENT    = <LS_HISTORY>-262_MOVE
            MATDOCUMENTYEAR     = <LS_HISTORY>-262_MOVE_YEAR
            GOODSMVT_PSTNG_DATE = SY-DATUM  "sy-datum
          TABLES
            RETURN              = LT_RETURN.

        READ TABLE LT_RETURN TRANSPORTING NO FIELDS WITH KEY TYPE = 'E'.
        IF SY-SUBRC = 0.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          <LS_HISTORY>-262_ROLL_MESSAGE = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
          CONTINUE.
        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = 'X'.
        ENDIF.
      ENDIF.
    ENDLOOP.

* 테이블 에러처리
* 결과 반영
    LOOP AT GT_ROW INTO GS_ROW.

      READ TABLE GT_DISP2 ASSIGNING <LS_DISP2> INDEX GS_ROW-INDEX.

      <LS_DISP2>-ICON = ICON_LED_RED.
      READ TABLE LT_MOVE_HISTORY INTO LS_MOVE_HISTORY WITH KEY AUFNR = <LS_DISP2>-AUFNR
                                                               LGORT = <LS_DISP2>-LGORT2
                                                               CHARG = <LS_DISP2>-CHARG2.
      IF SY-SUBRC EQ 0.
        IF LS_MOVE_HISTORY-311_ROLL_MESSAGE IS NOT INITIAL.
          <LS_DISP2>-MESSAGE = LS_MOVE_HISTORY-311_ROLL_MESSAGE.
        ELSEIF LS_MOVE_HISTORY-262_ROLL_MESSAGE IS NOT INITIAL.
          <LS_DISP2>-MESSAGE = LS_MOVE_HISTORY-262_ROLL_MESSAGE.
        ELSE.
          <LS_DISP2>-MESSAGE = LV_MESSAGE.
        ENDIF.
      ELSE.
        <LS_DISP2>-MESSAGE = LV_MESSAGE.
      ENDIF.

**      IF <LS_DISP2>-ICON = ICON_LED_GREEN.
**        CLEAR LS_CELLTAB.
**        LS_CELLTAB-FIELDNAME = 'ERFMG5'.
**        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
**        INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
**        <LS_DISP2>-CELLTAB = LT_CELLTAB.
**      ENDIF.
    ENDLOOP.

  ELSE.
* 결과 반영
    LOOP AT GT_ROW INTO GS_ROW.

      READ TABLE GT_DISP2 ASSIGNING <LS_DISP2> INDEX GS_ROW-INDEX.

      <LS_DISP2>-ICON = ICON_LED_GREEN.

      IF <LS_DISP2>-ICON = ICON_LED_GREEN.
        CLEAR LS_CELLTAB.
        LS_CELLTAB-FIELDNAME = 'ERFMG5'.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
        INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
        <LS_DISP2>-CELLTAB = LT_CELLTAB.
      ENDIF.
    ENDLOOP.

  ENDIF.

* 실사 수량 정보 갱신
*  PERFORM GET_DATA.

  PERFORM REFRESH_DISPLAY_ALL_ALV.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALCULATE_WITH_PLUS_BWD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALCULATE_WITH_PLUS_BWD .

  DATA : LV_AUFNR LIKE MSEG-AUFNR.
* 총 입고량, 투입량 취합
  CLEAR : GV_MENGE, GV_ERFMG, LV_AUFNR.
  LOOP AT GT_DISP2_1 INTO GS_DISP2_1
               WHERE MATNR2 EQ GS_DISP-MATNR
                  AND ERFMG2 > 0.

    GV_MENGE = GV_MENGE + GS_DISP2_1-MENGE1. "총 입고량
    GV_ERFMG = GV_ERFMG + GS_DISP2_1-ERFMG2. "총 투입량

  ENDLOOP.

  LOOP AT GT_DISP2_2 INTO GS_DISP2_2
                     WHERE MATNR2 EQ GS_DISP-MATNR
                      AND ERFMG2 > 0.

    CLEAR GS_DISP2.
    MOVE-CORRESPONDING GS_DISP2_2 TO GS_DISP2.
* 가중치(%) 계산 : ( 입고량 / 총 입고량[ 자재, 배치 기준 합산] ) * 100
    IF GS_DISP2-MENGE1 NE 0 AND GV_MENGE NE 0.
      IF GS_DISP2-CHARG2 NE GS_DISP2-CHARG5.
        GS_DISP2-MENGE3 = ( GS_DISP2-MENGE1 / GV_MENGE ) * 100.
      ENDIF.
    ENDIF.
* 계산 투입량 계산 : ( 총 투입량 + 실사 차이량 ) * ( 가중치(%) / 100 )
    IF GS_DISP2-MENGE3 NE 0.
      GS_DISP2-MENGE4 = GS_DISP-CHAI * ( GS_DISP2-MENGE3 / 100 ).
    ENDIF.
* 조정량 계산 : 계산 투입량 - 투입량
    IF GS_DISP2-ERFMG2 < GS_DISP2-MENGE4.
      GS_DISP2-ERFMG5 = GS_DISP2-ERFMG2.
    ELSE.
      GS_DISP2-ERFMG5 = GS_DISP2-MENGE4.
    ENDIF.
* 차이량에서 조정량을 반영하여 차감( 계산 투입량 존재시에만 )
    IF GS_DISP2-MENGE4 NE 0.
      CLEAR GS_DISP_1.
      READ TABLE GT_DISP_1 INTO GS_DISP_1
                           WITH KEY MATNR = GS_DISP-MATNR
                                    CHARG = GS_DISP-CHARG.
      IF SY-SUBRC = 0.
        GS_DISP_1-CHAI = GS_DISP_1-CHAI - GS_DISP2-ERFMG5.
        MODIFY GT_DISP_1 FROM GS_DISP_1 INDEX SY-TABIX.
      ENDIF.

    ENDIF.

    IF P_BWD = ABAP_TRUE.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          INPUT  = GS_DISP-MATNR
        IMPORTING
          OUTPUT = GS_DISP2-CHARG5.
    ELSE.
      GS_DISP2-CHARG5 = GS_DISP-CHARG.
    ENDIF.
    GS_DISP2-LGORT5 = GS_DISP-LGORT.
    APPEND GS_DISP2 TO GT_DISP2.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LAST_DAY_OF_MONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_BUDAT
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
*& Form set_budat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BUDAT .

  IF P_MONTH IS NOT INITIAL.
    P_BUDAT = P_MONTH && '01'.
    PERFORM GET_LAST_DAY_OF_MONTH CHANGING P_BUDAT.
  ENDIF.

ENDFORM.
