*&---------------------------------------------------------------------*
*& Include          ZGTPPR3120F01
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

  LOOP AT SCREEN.

    CASE SCREEN-NAME.
      WHEN 'P_YEAR' OR 'S_WEEK-LOW' OR 'S_DAY-LOW'.
        SCREEN-REQUIRED = 2.
        MODIFY SCREEN.
      WHEN 'P_NAME1'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
    ENDCASE.

    IF P_CW EQ ABAP_TRUE.
      IF SCREEN-GROUP1 = 'S2'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF P_CD EQ ABAP_TRUE.
      IF SCREEN-GROUP1 = 'S1'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

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

* 플랜트명
  IF P_WERKS IS NOT INITIAL.
    CLEAR: T001W, P_NAME1.
    SELECT SINGLE NAME1
      FROM T001W
     WHERE WERKS EQ @P_WERKS
      INTO @P_NAME1.
  ELSE.
    CLEAR P_NAME1.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_WEEK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> S_WEEK_LOW
*&---------------------------------------------------------------------*
FORM F4_WEEK  USING    P_WEEK.

  DATA: LT_RETURN     TYPE TABLE OF DDSHRETVAL WITH HEADER LINE,
        LT_DYNPFIELDS TYPE TABLE OF DYNPREAD WITH HEADER LINE.

  DATA: LT_FIELDS TYPE TABLE OF DFIES,
        LS_FIELD  TYPE DFIES.
  DATA: LV_WERKS TYPE WERKS_D.

  DATA: BEGIN OF LS_WEEK,
          WEEK(2),
        END OF LS_WEEK,
        LT_WEEK LIKE TABLE OF LS_WEEK.

  CLEAR: LT_WEEK.
  DO 53 TIMES.
    LS_WEEK-WEEK = LS_WEEK-WEEK + 1.
    APPEND LS_WEEK TO LT_WEEK.
  ENDDO.

  CLEAR: LT_FIELDS.
  LS_FIELD-FIELDNAME = 'WEEK'.
  LS_FIELD-LANGU = SY-LANGU.
  LS_FIELD-POSITION = 1.
  LS_FIELD-OFFSET = 0.
  LS_FIELD-LENG = 10.
  LS_FIELD-INTLEN = 20.
  LS_FIELD-OUTPUTLEN = 20.
  LS_FIELD-DATATYPE = 'CHAR'.
  LS_FIELD-INTTYPE = 'C'.
  LS_FIELD-DYNPFLD = 'X'.
  LS_FIELD-COMPTYPE = 'E'.
  LS_FIELD-LFIELDNAME = 'WEEK'.
  LS_FIELD-SCRTEXT_S = '주차'.
  LS_FIELD-SCRTEXT_M = '주차'.
  LS_FIELD-SCRTEXT_L = '주차'.
  LS_FIELD-REPTEXT   = '주차'.
  APPEND LS_FIELD TO LT_FIELDS.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'WEEK'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      VALUE_ORG       = 'S'
      WINDOW_TITLE    = '주차'
    TABLES
      VALUE_TAB       = LT_WEEK
      FIELD_TAB       = LT_FIELDS
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN INDEX 1.

  P_WEEK = LT_RETURN-FIELDVAL.

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

*& 플랜트에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
  ID 'WERKS'  FIELD P_WERKS.

  IF SY-SUBRC <> 0.
    "플랜트[P_WERKS] 작업권한을 확인하세요.
    MESSAGE E006 WITH TEXT-M01 P_WERKS TEXT-M03.
  ELSE.
*& MRP관리자에 대한 권한체크
    AUTHORITY-CHECK OBJECT 'ZPP_DISPO'
    ID 'WERKS'  FIELD P_WERKS
    ID 'DISPO'  FIELD S_DISPO-LOW.

    IF SY-SUBRC <> 0.
      "MRP관리자[S_DISPO-LOW] 작업권한을 확인하세요.
      MESSAGE E006 WITH TEXT-M02 S_DISPO-LOW TEXT-M03.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_DATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_DATE .
  DATA: LV_WEEK15 TYPE CHAR10,
        LV_DAYS   TYPE VTBBEWE-ATAGE.

  IF P_CW EQ ABAP_TRUE.
    IF P_YEAR IS INITIAL.
      SET CURSOR FIELD 'P_YEAR'.
      MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M08.
      LEAVE LIST-PROCESSING.
    ENDIF.

    IF S_WEEK-LOW IS INITIAL..
      SET CURSOR FIELD 'S_WEEK-LOW'.
      MESSAGE E000 DISPLAY LIKE 'E' WITH TEXT-M06.
      LEAVE LIST-PROCESSING.
    ENDIF.

    CLEAR: LV_WEEK15.

    LV_WEEK15 = S_WEEK-HIGH - S_WEEK-LOW + 1.

    IF LV_WEEK15 GT 15.
      MESSAGE S000 DISPLAY LIKE 'E' WITH '15주를 넘을 수 없습니다.'.
      LEAVE LIST-PROCESSING.
    ENDIF.

  ELSEIF P_CD EQ ABAP_TRUE.

    IF S_DAY-LOW IS INITIAL.
      SET CURSOR FIELD 'S_DAY-LOW'.
      MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M09.
      LEAVE LIST-PROCESSING.
    ENDIF.

    CLEAR: LV_DAYS.
    CALL FUNCTION 'FIMA_DAYS_AND_MONTHS_AND_YEARS'
      EXPORTING
        I_DATE_FROM = S_DAY-LOW
        I_DATE_TO   = S_DAY-HIGH
      IMPORTING
        E_DAYS      = LV_DAYS.

    IF LV_DAYS GT 105.
      MESSAGE S000 DISPLAY LIKE 'E' WITH '105일을 넘을 수 없습니다.'.
      LEAVE LIST-PROCESSING.
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

  PERFORM SELECTION_WEEK_TO_DATE.   "조회주차->일자변환
  PERFORM SET_GBN_PLAN.
  PERFORM SET_DISP_TABLE.
  PERFORM CREATE_DYNAMIC_TABLE.
  PERFORM SET_EKORG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_WEEK_TO_DATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_WEEK_TO_DATE .

  DATA : LV_DATE LIKE SCAL-DATE.
  DATA : LV_WEEK_CHK LIKE SCAL-WEEK.
  DATA : LV_CONFIRM_WEEK LIKE SCAL-WEEK.
  DATA : LV_WEEK_FR LIKE SCAL-WEEK.
  DATA : LV_WEEK_TO LIKE SCAL-WEEK.
  DATA : LV_CNT  TYPE I.
  DATA : LV_YEAR TYPE MATDOC-YEAR_BUDAT.
  DATA : LV_CAL_WEEK TYPE MATDOC-WEEK_BUDAT.

  REFRESH GR_DATE[].
  REFRESH GT_WEEK.

  IF P_CW EQ ABAP_TRUE.
    IF S_WEEK-HIGH IS INITIAL.
      GR_DATE-SIGN = 'I'.
      GR_DATE-OPTION = 'BT'.

      LV_WEEK_FR = P_YEAR && S_WEEK-LOW.

*-FROM 주차의 월요일 일자
      CLEAR: LV_DATE.
      CALL FUNCTION 'WEEK_GET_FIRST_DAY'
        EXPORTING
          WEEK         = LV_WEEK_FR
        IMPORTING
          DATE         = GR_DATE-LOW
        EXCEPTIONS
          WEEK_INVALID = 1
          OTHERS       = 2.

*-FROM읠 월요일 일자의 일요일 일자
      CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
        EXPORTING
          DATE   = GR_DATE-LOW
        IMPORTING
          SUNDAY = GR_DATE-HIGH.

      APPEND GR_DATE.

*    주단위 디스플레이시 주간별 정렬된 테이블
      APPEND INITIAL LINE TO GT_WEEK ASSIGNING FIELD-SYMBOL(<LS_WEEK>).
      <LS_WEEK>-WEEK = LV_WEEK_FR.
      <LS_WEEK>-FDAY = GR_DATE-LOW.
      <LS_WEEK>-TDAY = GR_DATE-HIGH.

    ELSE.
      GR_DATE-SIGN = 'I'.
      GR_DATE-OPTION = 'BT'.

      LV_WEEK_FR = P_YEAR && S_WEEK-LOW.

* 주차가 52보다 크면 연도 바꾸서 재계산
      IF S_WEEK-HIGH > 52.
*      우선 52주 가능여부 체크후
        CLEAR LV_WEEK_CHK.
        LV_WEEK_CHK = P_YEAR && '53'.
        CALL FUNCTION 'WEEK_GET_FIRST_DAY'
          EXPORTING
            WEEK         = LV_WEEK_CHK
          IMPORTING
            DATE         = LV_DATE
          EXCEPTIONS
            WEEK_INVALID = 1
            OTHERS       = 2.
        IF SY-SUBRC <> 0.
          LV_CAL_WEEK = S_WEEK-HIGH - 52.
          LV_CONFIRM_WEEK = 52.
        ELSE.
          LV_CAL_WEEK = S_WEEK-HIGH - 53.
          LV_CONFIRM_WEEK = 53.
        ENDIF.

        IF  LV_CAL_WEEK  = 0.
          LV_WEEK_TO = P_YEAR && S_WEEK-HIGH.
        ELSE.
          LV_YEAR = P_YEAR + 1.
          LV_WEEK_TO = LV_YEAR && LV_CAL_WEEK.
        ENDIF.

      ELSE.
        LV_WEEK_TO = P_YEAR && S_WEEK-HIGH.
      ENDIF.

*-FROM 주차의 월요일 일자
      CALL FUNCTION 'WEEK_GET_FIRST_DAY'
        EXPORTING
          WEEK         = LV_WEEK_FR
        IMPORTING
          DATE         = GR_DATE-LOW
        EXCEPTIONS
          WEEK_INVALID = 1
          OTHERS       = 2.

*-TO 주차의 월요일 일자
      CLEAR: LV_DATE.
      CALL FUNCTION 'WEEK_GET_FIRST_DAY'
        EXPORTING
          WEEK         = LV_WEEK_TO
        IMPORTING
          DATE         = LV_DATE
        EXCEPTIONS
          WEEK_INVALID = 1
          OTHERS       = 2.

*-TO 주차의 일요일 일자
      CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
        EXPORTING
          DATE   = LV_DATE
        IMPORTING
          SUNDAY = GR_DATE-HIGH.

      APPEND GR_DATE.

*    주단위 디스플레이시 주간별 정렬된 테이블
      LV_CNT = S_WEEK-HIGH - S_WEEK-LOW.

      CLEAR GS_WEEK.
      GS_WEEK-WEEK = LV_WEEK_FR.
      APPEND GS_WEEK TO GT_WEEK.

      DO LV_CNT TIMES.
        GS_WEEK-WEEK = GS_WEEK-WEEK + 1.

        IF GS_WEEK-WEEK+4(2) >= 53. "52가 마지막이거나 53주차가 마지막일수 있으므로 확인작업
*      우선 52주 가능여부 체크후
          CLEAR LV_WEEK_CHK.
          LV_WEEK_CHK = GS_WEEK-WEEK.
          CALL FUNCTION 'WEEK_GET_FIRST_DAY'
            EXPORTING
              WEEK         = LV_WEEK_CHK
            IMPORTING
              DATE         = LV_DATE
            EXCEPTIONS
              WEEK_INVALID = 1
              OTHERS       = 2.
          IF SY-SUBRC <> 0.
            LV_YEAR = P_YEAR + 1.
            GS_WEEK-WEEK = LV_YEAR && '01'.
          ENDIF.
        ENDIF.
        ADD 1 TO GS_WEEK-LCNT.

        APPEND GS_WEEK TO GT_WEEK.
      ENDDO.

      LOOP AT GT_WEEK ASSIGNING FIELD-SYMBOL(<FS>).
        CALL FUNCTION 'WEEK_GET_FIRST_DAY'
          EXPORTING
            WEEK         = <FS>-WEEK
          IMPORTING
            DATE         = <FS>-FDAY
          EXCEPTIONS
            WEEK_INVALID = 1
            OTHERS       = 2.

        CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
          EXPORTING
            DATE   = <FS>-FDAY
          IMPORTING
            SUNDAY = <FS>-TDAY.

      ENDLOOP.
    ENDIF.

  ELSEIF P_CD EQ ABAP_TRUE.
    APPEND LINES OF S_DAY TO GR_DATE.

    READ TABLE GR_DATE ASSIGNING FIELD-SYMBOL(<LS_DATE>) INDEX 1.
    IF <LS_DATE>-HIGH IS INITIAL OR <LS_DATE>-HIGH = '00000000'.
      <LS_DATE>-HIGH = <LS_DATE>-LOW.
    ENDIF.

  ENDIF.

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

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LV_COL_POS TYPE I.
  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LV_TEXT(100).

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = 'GS_DATA'
      I_INCLNAME         = 'ZGTPPR3120TOP'
      I_BYPASSING_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT        = LT_FCAT.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_DATA.

  APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
  <LS_FCAT>-COL_POS = 14.
  <LS_FCAT>-FIELDNAME = 'BSTMI'.
  <LS_FCAT>-COLTEXT = 'BSTMI'.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-COL_POS = 15.
  <LS_FCAT>-FIELDNAME = 'BSTRF'.
  <LS_FCAT>-COLTEXT = 'BSTRF'.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-COL_POS = 16.
  <LS_FCAT>-FIELDNAME = 'PLIFZ'.
  <LS_FCAT>-COLTEXT = 'PLIFZ'.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-COL_POS = 17.
  <LS_FCAT>-FIELDNAME = 'EISBE'.
  <LS_FCAT>-COLTEXT = 'EISBE'.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-COL_POS = 18.
  <LS_FCAT>-FIELDNAME = 'STOCK'.
  <LS_FCAT>-COLTEXT = 'STOCK'.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-COL_POS = 19.
  <LS_FCAT>-FIELDNAME = 'LABST'.
  <LS_FCAT>-COLTEXT = 'LABST'.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.

  LV_COL_POS = LINES( GT_FIELDCAT_0100 ).

  APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
  ADD 1 TO LV_COL_POS.
  <LS_FCAT>-COL_POS = LV_COL_POS.
  <LS_FCAT>-FIELDNAME = 'SEQNO'.
  <LS_FCAT>-COLTEXT = '순번'.
  <LS_FCAT>-DATATYPE = 'INT4'.
  <LS_FCAT>-DD_OUTLEN = '10'.
  <LS_FCAT>-NO_OUT = ABAP_TRUE.

  APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
  ADD 1 TO LV_COL_POS.
  <LS_FCAT>-COL_POS = LV_COL_POS.
  <LS_FCAT>-FIELDNAME = 'GBTXT'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구분'.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '10'.


  CASE ABAP_TRUE.
    WHEN P_CW. " 주차

      LOOP AT GT_WEEK INTO GS_WEEK.
        APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
        ADD 1 TO LV_COL_POS.
        <LS_FCAT>-COL_POS = LV_COL_POS.
        <LS_FCAT>-FIELDNAME = GS_WEEK-WEEK.
        CLEAR LV_TEXT.
        LV_TEXT = GS_WEEK-WEEK+0(4) && |.| && GS_WEEK-WEEK+4(2) && '주차' && '(' && GS_WEEK-FDAY+4(2) && '.' && GS_WEEK-FDAY+6(2) && '~' && GS_WEEK-TDAY+4(2) && '.' && GS_WEEK-TDAY+6(2)  && ')'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_TEXT.
        <LS_FCAT>-DATATYPE = 'CHAR'.
        <LS_FCAT>-DD_OUTLEN = '30'.
        <LS_FCAT>-JUST = 'R'.


        APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
        ADD 1 TO LV_COL_POS.
        <LS_FCAT>-COL_POS = LV_COL_POS.
        <LS_FCAT>-FIELDNAME = GS_WEEK-WEEK && '_CHK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
        <LS_FCAT>-DATATYPE = 'CHAR'.
        <LS_FCAT>-DD_OUTLEN = '1'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.

      ENDLOOP.

    WHEN P_CD. " 일간
      APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
      ADD 1 TO LV_COL_POS.
      <LS_FCAT>-COL_POS = LV_COL_POS.
      <LS_FCAT>-FIELDNAME = 'BDTXT'.
      <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획요소'.
      <LS_FCAT>-DATATYPE = 'CHAR'.
      <LS_FCAT>-DD_OUTLEN = '20'.
      <LS_FCAT>-JUST = 'C'.

      APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
      ADD 1 TO LV_COL_POS.
      <LS_FCAT>-COL_POS = LV_COL_POS.
      <LS_FCAT>-FIELDNAME = 'GBNCD'.
      <LS_FCAT>-COLTEXT = '구분코드'.
      <LS_FCAT>-DATATYPE = 'CHAR'.
      <LS_FCAT>-DD_OUTLEN = '2'.
      <LS_FCAT>-NO_OUT = ABAP_TRUE.

*    Overdue : 구매제안 처리를 담아주기 위한 필드
      APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
      ADD 1 TO LV_COL_POS.
      <LS_FCAT>-COL_POS = LV_COL_POS.
      <LS_FCAT>-FIELDNAME = 'DUEDATE'.
      <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'OVERDUE'.
      <LS_FCAT>-COLTEXT = 'Overdue'.
      <LS_FCAT>-DATATYPE = 'CHAR'.
      <LS_FCAT>-DD_OUTLEN = '30'.
      <LS_FCAT>-JUST = 'R'.

      READ TABLE GR_DATE INDEX 1.
      LV_DATE = GR_DATE-LOW.
      DO .

        APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
        ADD 1 TO LV_COL_POS.
        <LS_FCAT>-COL_POS = LV_COL_POS.
        <LS_FCAT>-FIELDNAME = LV_DATE.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_DATE+2(2) && '.' && LV_DATE+4(2) && '.' && LV_DATE+6(2).
        <LS_FCAT>-DATATYPE = 'CHAR'.
        <LS_FCAT>-DD_OUTLEN = '30'.
        <LS_FCAT>-JUST = 'R'.

        APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
        ADD 1 TO LV_COL_POS.
        <LS_FCAT>-COL_POS = LV_COL_POS.
        <LS_FCAT>-FIELDNAME = LV_DATE && '_CHK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
        <LS_FCAT>-DATATYPE = 'CHAR'.
        <LS_FCAT>-DD_OUTLEN = '1'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.

        IF GR_DATE-HIGH = LV_DATE.
          EXIT.
        ENDIF.

        ADD 1 TO LV_DATE.
      ENDDO.
  ENDCASE.

* 필드명 서술
  LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ID'.
*        IF P_CW EQ ABAP_TRUE.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '상태'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-KEY = ABAP_TRUE.
*        ELSEIF P_CD EQ ABAP_TRUE.
*          <LS_FCAT>-NO_OUT = ABAP_TRUE.
*        ENDIF.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재코드'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재내역'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재유형'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'SPART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품군'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재그룹'.
        <LS_FCAT>-JUST = 'C'.
*      WHEN 'WGBEZ'.
*        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재그룹내역'.
*        <FS>-JUST = 'L'.
      WHEN 'DISPO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'MRP관리자'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'EKGRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매그룹'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'EKNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매그룹내역'.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'DISLS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Lot Size'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'BSTMI'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '최소로트크기'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'BSTRF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '반올림값'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 1.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'PLIFZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Lead Time(일)'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'EISBE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '안전재고'.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'STOCK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '적정재고'.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'LABST'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '현재고'.
        <LS_FCAT>-JUST = 'R'.
    ENDCASE.
  ENDLOOP.

  SORT GT_FIELDCAT_0100 BY COL_POS.

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
      CASE ABAP_TRUE.
        WHEN P_CW.
          PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                         USING : 'REFRESH' ICON_REFRESH 'Refresh' 'Refresh' 0.
        WHEN P_CD.
          PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                         USING : 'REFRESH' ICON_REFRESH 'Refresh' 'Refresh' 0,
                                    '' '' '' '' 3,
                                    'CREATE_REQ' ICON_CREATE '구매요청 생성' '구매요청 생성' 0,
                                    '' '' '' '' 3,
                                    'CREATE_ORD' ICON_CREATE '구매오더 생성' '구매오더 생성' 0.
      ENDCASE.
    WHEN GO_GRID_0300.
      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                               USING : 'DEL_REQ' ICON_DELETE '구매요청 삭제' '구매요청 삭제' 0,
*                                          'CHANGE' ICON_SET_STATE '구매오더 전환' '구매오더 전환' 0,
                                          '' '' '' '' 3,
                                          'DEL_ORD' ICON_DELETE '구매오더 삭제' '구매오더 삭제' 0.

    WHEN GO_GRID_0400.
      CASE GV_MODE.
        WHEN 'X'. " 수정모드
          PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                   USING : 'ADD' ICON_INSERT_ROW '' '라인 추가' 0,
                                              'DELE' ICON_DELETE_ROW '' '라인 삭제' 0,
                                              '' '' '' '' 3,
                                              'CONFIRM' ICON_CREATE '구매요청 생성' '구매요청 생성' 0.
        WHEN 'C'. " 완료상태

        WHEN OTHERS. " 선택데이터 처리모드
          PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                             USING : 'CONFIRM' ICON_CREATE '구매요청 생성' '구매요청 생성' 0.

      ENDCASE.
    WHEN GO_GRID_0500.
      CASE GV_MODE.
        WHEN 'X'. " 수정모드
          PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                   USING : 'ADD' ICON_INSERT_ROW '' '라인 추가' 0,
                                              'DELE' ICON_DELETE_ROW '' '라인 삭제' 0,
                                              '' '' '' '' 3,
                                              'CONFIRM' ICON_CREATE '구매오더 생성' '구매오더 생성' 0.
        WHEN 'C'. " 완료상태

        WHEN OTHERS. " 선택데이터 처리모드
          PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                             USING : 'CONFIRM' ICON_CREATE '구매오더 생성' '구매오더 생성' 0.

      ENDCASE.
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
        WHEN 'REFRESH'. " Refresh
          PERFORM REFRESH_DATA..
        WHEN 'CREATE_REQ'. " Refresh
          PERFORM PROC_CREATE_REQ USING PO_SENDER.
        WHEN 'CREATE_ORD'. " Refresh
          PERFORM PROC_CREATE_ORD USING PO_SENDER.
      ENDCASE.
    WHEN GO_GRID_0300.
      CASE PV_UCOMM.
        WHEN 'DEL_REQ'. " 구매요청 삭제
          PERFORM PROC_DEL_REQ USING PO_SENDER.
        WHEN 'DEL_ORD'. " 구매오더 삭제
          PERFORM PROC_DEL_ORD USING PO_SENDER.
      ENDCASE.

    WHEN GO_GRID_0400.
      CASE PV_UCOMM.
        WHEN 'ADD'. " 어팬드라인
          PERFORM ADD_LINE_0400 USING PO_SENDER.
        WHEN 'DELE'. " 라인삭제
          PERFORM DELETE_LINE_0400 USING PO_SENDER.
        WHEN 'CONFIRM'. " 구매요청 생성
          PERFORM PROC_CREATE_REQ_0400 USING PO_SENDER.

      ENDCASE.

    WHEN GO_GRID_0500.
      CASE PV_UCOMM.
        WHEN 'ADD'. " 어팬드라인
          PERFORM ADD_LINE_0500 USING PO_SENDER.
        WHEN 'DELE'. " 라인삭제
          PERFORM DELETE_LINE_0500 USING PO_SENDER.
        WHEN 'CONFIRM'. " 구매오더 생성
          PERFORM PROC_CREATE_ORD_0500 USING PO_SENDER.

      ENDCASE.

  ENDCASE.

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

  DATA : LS_MOD_CELLS TYPE LVC_S_MODI.
  DATA : LV_MATNR TYPE MATNR.
  DATA : LV_CHK_ERR.
  DATA : LV_MAKTX TYPE MAKTX.
  DATA : LV_LGORT TYPE LGORT_D.
  DATA : LV_MEINS TYPE MEINS.

  DEFINE __SET_ERR_MSG.
    lv_chk_err = abap_true.
    po_data_changed->add_protocol_entry(
        i_msgid     = 'ZGTPP00'                 " Message ID
        i_msgty     = 'E'                 " Message Type
        i_msgno     =  '006'                " Message No.
        i_msgv1     =  &1                " Message Variable1
        i_msgv2     =  &2                " Message Variable2
        i_msgv3     =  &3                " Message Variable3
        i_fieldname =  &4                " Field Name
        i_row_id    =  ls_mod_cells-row_id ).                " RowID
  END-OF-DEFINITION.

  DEFINE __MODI_CELL.
    PO_DATA_CHANGED->MODIFY_CELL(
      I_ROW_ID     = &1                 " Row ID
      I_FIELDNAME = &2                 " Field Name
      I_VALUE       = &3 ).               " Value
  END-OF-DEFINITION.

  LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.

    CASE P_SENDER.
      WHEN  GO_GRID_0400 OR GO_GRID_0500.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'MATNR'.
            CLEAR LV_MATNR.
            CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
              EXPORTING
                INPUT        = LS_MOD_CELLS-VALUE
              IMPORTING
                OUTPUT       = LV_MATNR
              EXCEPTIONS
                LENGTH_ERROR = 1
                OTHERS       = 2.
            IF SY-SUBRC <> 0.
              __SET_ERR_MSG : TEXT-E03 TEXT-002 TEXT-E04 'MATNR'.
              LV_CHK_ERR = ABAP_TRUE.
              CONTINUE.
            ENDIF.

            CLEAR LV_MEINS.
            SELECT SINGLE MATNR, MEINS FROM MARA
              INTO ( @DATA(LV_MATNR_CHK), @LV_MEINS )
              WHERE MATNR = @LV_MATNR.
            IF SY-SUBRC NE 0.
              LV_CHK_ERR = ABAP_TRUE.
              __SET_ERR_MSG : TEXT-E03 TEXT-002 TEXT-E04 'MATNR'.
              CONTINUE.
            ELSE.
*            자재에 오류 정보가 없다면 자재 기본단위, 저장위치, 내역 업데이트
*             내역
              CLEAR LV_MAKTX.
              LV_MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LV_MATNR ).
              __MODI_CELL LS_MOD_CELLS-ROW_ID 'MAKTX' LV_MAKTX.
*            기본단위
              __MODI_CELL LS_MOD_CELLS-ROW_ID 'MEINS' LV_MEINS.
*             저장위치
              SELECT SINGLE LGFSB FROM MARC
                INTO LV_LGORT
               WHERE MATNR = LV_MATNR
                   AND WERKS = P_WERKS.

              IF SY-SUBRC EQ 0.
                __MODI_CELL LS_MOD_CELLS-ROW_ID 'LGORT' LV_LGORT.
              ENDIF.

            ENDIF.

          WHEN 'WERKS'.
            SELECT SINGLE WERKS FROM T001W
              INTO @DATA(LV_CHK_WERKS)
             WHERE WERKS = @LS_MOD_CELLS-VALUE.
            IF SY-SUBRC NE 0.
              LV_CHK_ERR = ABAP_TRUE.
              __SET_ERR_MSG : TEXT-E03 TEXT-013 TEXT-E04 'WERKS'.
              CONTINUE.
            ENDIF.
        ENDCASE.
      WHEN OTHERS.

    ENDCASE.
  ENDLOOP.

  IF LV_CHK_ERR IS NOT INITIAL.
    PO_DATA_CHANGED->DISPLAY_PROTOCOL( ).
  ENDIF.


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

  RANGES : LR_DATE FOR SY-DATUM.
  DATA : LT_BDART TYPE RANGE OF BDART.
  DATA : LT_CVDATA LIKE TABLE OF GS_CVDATA.
  DATA : LV_MODE(2).
  DATA : LV_FRDATE TYPE SY-DATUM.
  DATA : LV_TODATE TYPE SY-DATUM.
  DATA : LV_STRING TYPE STRING.
  DATA : LV_MATNR(40).
  DATA : LV_MAKTX TYPE MAKTX.
  DATA : LV_CHK_ALL_DATA.
  FIELD-SYMBOLS : <LV_MATNR> TYPE ANY.
  FIELD-SYMBOLS : <LV_GBNCD> TYPE ANY.
  FIELD-SYMBOLS : <LV_GBTXT> TYPE ANY.

  CLEAR : GV_TITLE_MATNR, GV_TITLE_DATE.

  CHECK P_ROW-INDEX > 0.
  CLEAR LV_MODE.
  CASE P_SENDER.
    WHEN GO_GRID_0100.
      READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_DATA>) INDEX P_ROW-INDEX.
      IF <LV_MATNR> IS ASSIGNED. UNASSIGN <LV_MATNR>. ENDIF.
      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <LS_DATA> TO <LV_MATNR>.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          INPUT  = <LV_MATNR>
        IMPORTING
          OUTPUT = LV_MATNR.

      GV_TITLE_MATNR = LV_MATNR &&','.
      LV_MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = <LV_MATNR> ).
      CONCATENATE '자재 :' GV_TITLE_MATNR LV_MAKTX INTO GV_TITLE_MATNR SEPARATED BY SPACE.
      GV_MATNR = <LV_MATNR>.

      READ TABLE GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = P_COLUMN-FIELDNAME.
      CASE <LS_FCAT>-FIELDNAME.
        WHEN 'GBTXT' OR 'GBNCD' OR 'BDTXT'.

          CASE ABAP_TRUE.
            WHEN P_CW.
              IF <LV_GBTXT> IS ASSIGNED. UNASSIGN <LV_GBTXT>. ENDIF.
              ASSIGN COMPONENT 'GBTXT' OF STRUCTURE <LS_DATA> TO <LV_GBTXT>.
              IF <LV_GBTXT> = '소요예정랑'.
                LV_MODE = 'DM'.
              ELSEIF <LV_GBTXT> = '입고계획'.
                LV_MODE = 'RS'.
              ENDIF.
            WHEN   P_CD.
              IF <LV_GBNCD> IS ASSIGNED. UNASSIGN <LV_GBNCD>. ENDIF.
              ASSIGN COMPONENT 'GBNCD' OF STRUCTURE <LS_DATA> TO <LV_GBNCD>.
              IF <LV_GBNCD> = 'DM'.
                LV_MODE = 'DM'.
              ELSEIF <LV_GBNCD> = 'RS'.
                LV_MODE = 'RS'.
              ENDIF.
          ENDCASE.

          CONCATENATE '선택일자 :' '조회대상 전체' INTO GV_TITLE_DATE SEPARATED BY SPACE.

          LOOP AT GT_GBN_PLAN INTO GS_GBN_PLAN WHERE GBNCD = LV_MODE.
            APPEND INITIAL LINE TO LT_BDART ASSIGNING FIELD-SYMBOL(<LS_BDART>).
            <LS_BDART>-SIGN = 'I'.
            <LS_BDART>-OPTION = 'EQ'.
            <LS_BDART>-LOW = GS_GBN_PLAN-BDART.
          ENDLOOP.

          LOOP AT GT_CVDATA ASSIGNING FIELD-SYMBOL(<LS_TEMP>) WHERE MATNR = GV_MATNR
                                                                                                  AND BDART IN LT_BDART.
            APPEND INITIAL LINE TO LT_CVDATA ASSIGNING FIELD-SYMBOL(<LS_CVDATA>).
            MOVE-CORRESPONDING <LS_TEMP> TO <LS_CVDATA>.
          ENDLOOP.

          CASE LV_MODE.
            WHEN 'DM'. " 수요정보 팝업
              IF LT_CVDATA[] IS NOT INITIAL.
                PERFORM DISP_DM TABLES LT_CVDATA.
              ENDIF.
            WHEN 'RS'. "공급정보 팝업
              IF LT_CVDATA[] IS NOT INITIAL.
                PERFORM DISP_RS TABLES LT_CVDATA.
              ENDIF.
          ENDCASE.

        WHEN OTHERS.

          CASE ABAP_TRUE.
            WHEN P_CW.
              IF <LV_GBTXT> IS ASSIGNED. UNASSIGN <LV_GBTXT>. ENDIF.
              ASSIGN COMPONENT 'GBTXT' OF STRUCTURE <LS_DATA> TO <LV_GBTXT>.
              IF <LV_GBTXT> = '소요예정랑'.
                LV_MODE = 'DM'.
              ELSEIF <LV_GBTXT> = '입고계획'.
                LV_MODE = 'RS'.
              ENDIF.

              READ TABLE GT_WSUM INTO DATA(LS_WSUM) WITH KEY MATNR = <LV_MATNR>
                                                                                         GBNCD = LV_MODE
                                                                                         WEEK   = P_COLUMN-FIELDNAME.
              IF SY-SUBRC EQ 0.

                READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = P_COLUMN-FIELDNAME.
                CONCATENATE '선택일자 :' <LS_FCAT>-REPTEXT INTO GV_TITLE_DATE SEPARATED BY SPACE.

                CLEAR : LV_FRDATE, LV_TODATE.
                CALL FUNCTION 'WEEK_GET_FIRST_DAY'
                  EXPORTING
                    WEEK         = LS_WSUM-WEEK
                  IMPORTING
                    DATE         = LV_FRDATE
                  EXCEPTIONS
                    WEEK_INVALID = 1
                    OTHERS       = 2.

                CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
                  EXPORTING
                    DATE   = LV_FRDATE
                  IMPORTING
                    SUNDAY = LV_TODATE.

                READ TABLE GT_WSUM INTO DATA(LS_FIRST_WEEK) INDEX 1.
                IF LS_WSUM-WEEK = LS_FIRST_WEEK-WEEK." 첫번째시 날짜적용
                  APPEND INITIAL LINE TO LR_DATE[] ASSIGNING FIELD-SYMBOL(<LS_DATE>).
                  <LS_DATE>-SIGN = 'I'.
                  <LS_DATE>-OPTION = 'LE'.
                  <LS_DATE>-LOW = LV_TODATE.
                ELSE. " 기본구간 날짜 적용
                  APPEND INITIAL LINE TO LR_DATE[] ASSIGNING <LS_DATE>.
                  <LS_DATE>-SIGN = 'I'.
                  <LS_DATE>-OPTION = 'BT'.
                  <LS_DATE>-LOW = LV_FRDATE.
                  <LS_DATE>-HIGH = LV_TODATE.
                ENDIF.

              ELSE.
                RETURN.
              ENDIF.

            WHEN P_CD.
              IF <LV_GBNCD> IS ASSIGNED. UNASSIGN <LV_GBNCD>. ENDIF.
              ASSIGN COMPONENT 'GBNCD' OF STRUCTURE <LS_DATA> TO <LV_GBNCD>.
              IF <LV_GBNCD> = 'DM'.
                LV_MODE = 'DM'.
              ELSEIF <LV_GBNCD> = 'RS'.
                LV_MODE = 'RS'.
              ENDIF.

              CASE P_COLUMN-FIELDNAME.
                WHEN 'DUEDATE'.
                  CONCATENATE '선택일자 :' SY-DATUM '이전'  INTO GV_TITLE_DATE SEPARATED BY SPACE.
                WHEN OTHERS.

                  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = P_COLUMN-FIELDNAME.
                  CONCATENATE '선택일자 :' <LS_FCAT>-REPTEXT INTO GV_TITLE_DATE SEPARATED BY SPACE.

                  READ TABLE GT_DSUM INTO DATA(LS_DSUM) WITH KEY MATNR = <LV_MATNR>
                                                                                            GBNCD = LV_MODE
                                                                                            DAY     = P_COLUMN-FIELDNAME.
                  IF SY-SUBRC EQ 0.
                    IF LS_DSUM-DAY = GR_DATE-LOW.
                      APPEND INITIAL LINE TO LR_DATE[] ASSIGNING <LS_DATE>.
                      <LS_DATE>-SIGN = 'I'.
                      <LS_DATE>-OPTION = 'LE'.
                      <LS_DATE>-LOW = GR_DATE-LOW.
                    ELSE.
                      APPEND INITIAL LINE TO LR_DATE[] ASSIGNING <LS_DATE>.
                      <LS_DATE>-SIGN = 'I'.
                      <LS_DATE>-OPTION = 'EQ'.
                      <LS_DATE>-LOW = LS_DSUM-DAY.
                    ENDIF.
                  ELSE.
                    RETURN.
                  ENDIF.
              ENDCASE.
          ENDCASE.

          IF LV_MODE IS NOT INITIAL AND LR_DATE[] IS NOT INITIAL.
            LOOP AT GT_GBN_PLAN INTO GS_GBN_PLAN WHERE GBNCD = LV_MODE.
              APPEND INITIAL LINE TO LT_BDART ASSIGNING <LS_BDART>.
              <LS_BDART>-SIGN = 'I'.
              <LS_BDART>-OPTION = 'EQ'.
              <LS_BDART>-LOW = GS_GBN_PLAN-BDART.
            ENDLOOP.

            LOOP AT GT_CVDATA ASSIGNING <LS_TEMP> WHERE MATNR = <LV_MATNR>
                                                                                AND BDTER IN LR_DATE
                                                                                AND BDART IN LT_BDART.
              APPEND INITIAL LINE TO LT_CVDATA ASSIGNING <LS_CVDATA>.
              MOVE-CORRESPONDING <LS_TEMP> TO <LS_CVDATA>.
            ENDLOOP.

            SORT LT_CVDATA BY BDART.

            CASE LV_MODE.
              WHEN 'DM'. " 수요정보 팝업
                IF LT_CVDATA[] IS NOT INITIAL.
                  PERFORM DISP_DM TABLES LT_CVDATA.
                ENDIF.
              WHEN 'RS'. "공급정보 팝업
                IF LT_CVDATA[] IS NOT INITIAL.
                  PERFORM DISP_RS TABLES LT_CVDATA.
                ENDIF.
            ENDCASE.

          ENDIF.

          IF LV_MODE = 'DM' AND P_COLUMN-FIELDNAME = 'DUEDATE'.
            LOOP AT GT_GBN_PLAN INTO GS_GBN_PLAN WHERE GBNCD = LV_MODE.
              APPEND INITIAL LINE TO LT_BDART ASSIGNING <LS_BDART>.
              <LS_BDART>-SIGN = 'I'.
              <LS_BDART>-OPTION = 'EQ'.
              <LS_BDART>-LOW = GS_GBN_PLAN-BDART.
            ENDLOOP.

            LOOP AT GT_PRE_CVDATA ASSIGNING <LS_TEMP> WHERE MATNR = <LV_MATNR>
                                                                                      AND BDART IN LT_BDART.
              APPEND INITIAL LINE TO LT_CVDATA ASSIGNING <LS_CVDATA>.
              MOVE-CORRESPONDING <LS_TEMP> TO <LS_CVDATA>.
            ENDLOOP.

            IF LT_CVDATA[] IS NOT INITIAL.
              PERFORM DISP_DM TABLES LT_CVDATA.
            ENDIF.
          ENDIF.
      ENDCASE.
  ENDCASE.

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
    WHEN GO_GRID_0200.
      PERFORM SET_TITLE_0200 CHANGING PV_DYNDOC_ID.
    WHEN GO_GRID_0300.
      PERFORM SET_TITLE_0300 CHANGING PV_DYNDOC_ID.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GBN_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GBN_PLAN .

  DEFINE __SET_GBN_PLAN.
    CLEAR: &1.
    &1-SEQNO = &3.
    &1-GBNCD = &4.
    &1-BDART = &5.
    &1-GBTXT = &6.
    &1-BDTXT = &7.
    APPEND &1 TO &2.
  END-OF-DEFINITION.

  __SET_GBN_PLAN: GS_GBN_PLAN GT_GBN_PLAN '1'  'DM' 'D1' '소요' '생산오더소요'.
  __SET_GBN_PLAN: GS_GBN_PLAN GT_GBN_PLAN '2'  'DM' 'D2' '소요' '생산계획소요'.
  __SET_GBN_PLAN: GS_GBN_PLAN GT_GBN_PLAN '3'  'DM' 'D3' '소요' '외주구매오더소요'.
  __SET_GBN_PLAN: GS_GBN_PLAN GT_GBN_PLAN '4'  'DM' 'D4' '소요' '외주구매요청소요'.
  __SET_GBN_PLAN: GS_GBN_PLAN GT_GBN_PLAN '5'  'DM' 'D5' '소요' '외주구매계획소요'.
  __SET_GBN_PLAN: GS_GBN_PLAN GT_GBN_PLAN '6'  'DM' 'D6' '소요' '사내이체요청소요'.
  __SET_GBN_PLAN: GS_GBN_PLAN GT_GBN_PLAN '7'  'DM' 'D7' '소요' '사내이체오더소요'.
  __SET_GBN_PLAN: GS_GBN_PLAN GT_GBN_PLAN '8'  'DM' 'D8' '소요' '월간계획확정소요'.
  __SET_GBN_PLAN: GS_GBN_PLAN GT_GBN_PLAN '9'  'RS' 'R1' '공급' '구매요청공급'.
  __SET_GBN_PLAN: GS_GBN_PLAN GT_GBN_PLAN '10'  'RS' 'R2' '공급' '구매오더공급'.
  __SET_GBN_PLAN: GS_GBN_PLAN GT_GBN_PLAN '11' 'RS' 'R3' '공급' '사내이체요청공급'.
  __SET_GBN_PLAN: GS_GBN_PLAN GT_GBN_PLAN '12' 'RS' 'R4' '공급' '사내이체오더공급'.
  __SET_GBN_PLAN: GS_GBN_PLAN GT_GBN_PLAN '13' 'Z1' 'Z1' ''     '예상재고'.
  __SET_GBN_PLAN: GS_GBN_PLAN GT_GBN_PLAN '14' 'Z2' 'Z2' ''     '구매제안'.

  SORT GT_GBN_PLAN BY SEQNO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DISPLAY .

  IF <GT_MAIN_DISP_100> IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE S001 DISPLAY LIKE 'E'.
  ENDIF.

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
      HEIGHT            =    10 ).             " Height

* top 컨테이너
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
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
    WHEN GO_GRID_0200.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE          FOR PO_GRID.
    WHEN GO_GRID_0300.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
    WHEN GO_GRID_0400.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
    WHEN GO_GRID_0500.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
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
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0100-STYLEFNAME = 'XYZSTYLEZYX'.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.

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
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

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
*& Form SET_TITLE_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PV_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM SET_TITLE_0100  CHANGING PV_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  DATA : LV_TEXT(255) TYPE C.
  DATA : LV_NAME1 TYPE T001W-NAME1.

* 프로젝트명
  IF P_WERKS IS NOT INITIAL.
    SELECT SINGLE NAME1
      FROM T001W
     WHERE WERKS EQ @P_WERKS
      INTO @LV_NAME1.
  ENDIF.

  CONCATENATE '플랜트 :' P_WERKS ', ' LV_NAME1 INTO LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

*-조회구분
  CLEAR: LV_TEXT.
  IF P_CW EQ ABAP_TRUE.
    CONCATENATE '조회구분 :' ' 주단위' INTO LV_TEXT SEPARATED BY SPACE.
  ELSEIF P_CD EQ ABAP_TRUE.
    CONCATENATE '조회구분 :' ' 일단위' INTO LV_TEXT SEPARATED BY SPACE.
  ENDIF.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

*-조회기간
  CLEAR: LV_TEXT.
  IF P_CW EQ ABAP_TRUE.
    CONCATENATE '조회기간 :' GR_DATE-LOW+0(4)  '.' GR_DATE-LOW+4(2)  '.' GR_DATE-LOW+6(2) '~'
                             GR_DATE-HIGH+0(4) '.' GR_DATE-HIGH+4(2) '.' GR_DATE-HIGH+6(2)
           INTO LV_TEXT SEPARATED BY SPACE.
  ELSEIF P_CD EQ ABAP_TRUE.
    IF GR_DATE-LOW = GR_DATE-HIGH.
      CONCATENATE '조회기간 :' GR_DATE-LOW+0(4)  '.' GR_DATE-LOW+4(2)  '.' GR_DATE-LOW+6(2)
                 INTO LV_TEXT SEPARATED BY SPACE.
    ELSE.
      CONCATENATE '조회기간 :' GR_DATE-LOW+0(4)  '.' GR_DATE-LOW+4(2)  '.' GR_DATE-LOW+6(2) '~'
                               GR_DATE-HIGH+0(4) '.' GR_DATE-HIGH+4(2) '.' GR_DATE-HIGH+6(2)
             INTO LV_TEXT SEPARATED BY SPACE.
    ENDIF.
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
      PARENT = GO_CONTAIN_TOP_0100.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_DYNAMIC_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_DYNAMIC_TABLE .

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
*& Form CHECK_AVAILABLE_WEEK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> START_OF_SELECTION
*&---------------------------------------------------------------------*
FORM CHECK_AVAILABLE_WEEK  USING    PV_FIELDNAME TYPE DYNPREAD-FIELDNAME.

  CHECK  P_CW = ABAP_TRUE.

  DATA : LV_VALUE TYPE N LENGTH 2.
  DATA : LV_WEEK TYPE SCAL-WEEK.
  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LV_MESSAGE(30).

  CALL FUNCTION 'GET_DYNP_VALUE'
    EXPORTING
      I_FIELD = PV_FIELDNAME
      I_REPID = SY-REPID
      I_DYNNR = SY-DYNNR
    CHANGING
      O_VALUE = LV_VALUE.

  IF LV_VALUE = '00' OR LV_VALUE IS INITIAL.
    SET CURSOR FIELD PV_FIELDNAME.
    MESSAGE E006 WITH TEXT-M06 .
  ENDIF.

  LV_WEEK = P_YEAR && LV_VALUE.

  CALL FUNCTION 'WEEK_GET_FIRST_DAY'
    EXPORTING
      WEEK         = LV_WEEK
    IMPORTING
      DATE         = LV_DATE
    EXCEPTIONS
      WEEK_INVALID = 1
      OTHERS       = 2.

  IF SY-SUBRC NE 0.
    SET CURSOR FIELD PV_FIELDNAME.
    CONCATENATE TEXT-M07 LV_VALUE INTO LV_MESSAGE SEPARATED BY SPACE.
    LV_MESSAGE = LV_MESSAGE && TEXT-M05.
    MESSAGE E000 WITH LV_MESSAGE P_YEAR TEXT-M04.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_GET_DATA .

  PERFORM GET_CVDATA.
  PERFORM COLLECT_DATA.
  PERFORM ETC_DATA.

  PERFORM MAKE_DISP_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CVDATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_CVDATA .

  DATA: LT_CVDATA LIKE TABLE OF GS_CVDATA.
  DATA : BEGIN OF LS_CHK_MATNR,
           MATNR TYPE MATNR,
         END OF LS_CHK_MATNR.
  DATA : LT_CHK_MATNR LIKE TABLE OF LS_CHK_MATNR.

  DATA: LV_PSTYP TYPE PSTYP,
        LV_PLIFZ TYPE PLIFZ,
        LV_WEBAZ TYPE WEBAZ.

  RANGES : LR_MTART FOR MARA-MTART.
  IF S_MTART[] IS NOT INITIAL.
    MOVE-CORRESPONDING S_MTART[] TO LR_MTART[].
  ELSE.
    MOVE-CORRESPONDING GR_MTART[] TO LR_MTART[].
  ENDIF.

*-수요 정보(생산오더 소요, 생산 계획 소요, 외주 구매오더 소요 등) +
*-공급 정보(구매요청, 구매오더)
  REFRESH GT_CVDATA.
  FREE GT_CVDATA.

  SELECT A~PLANT AS WERKS,
         A~MATERIAL AS MATNR,
         A~REQDATE AS BDTER,
         A~RESRVATIONNO AS RSNUM,
         A~RESRVATIONITEM AS RSPOS,
         A~AUFNR,
         A~DIVISION AS SPART,
         A~MATERIALGROUP AS MATKL,
         A~MATGROUPTEXT AS WGBEZ,
         A~MATERIALTYPE AS MTART,
         A~MRPCONTROLLER AS DISPO,
         A~PURCHASINGGROUP AS EKGRP,
         A~PURCHAGRPTEXT AS EKNAM,
         A~DELETEFLAG AS XLOEK,
         A~MOVEALLOW AS XWAOK,
         A~COMPLETED AS KZEAR,
         A~PURREQNO AS BANFN,
         A~PURREQITEM AS BNFPO,
         A~PURORDNO AS EBELN,
         A~PURORDITEM AS EBELP,
         A~PLDORDNO AS PLNUM,
         A~REQUIREMENTTYPE AS BDART,
         A~BDTXT,
         A~MRPUNIT AS MEINS,
         A~DEMANDQTY AS DMQTY,
         A~GIQTY AS GIQTY,
         A~REMAINQTY AS RMQTY,
         B~MAKTX,
         C~VTEXT,
         D~MTBEZ,
         E~DSNAM
    FROM ZGTPP_CV_MRP_DAY AS A
    LEFT OUTER JOIN MAKT  AS B ON B~MATNR EQ A~MATERIAL
                              AND B~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN TSPAT AS C ON C~SPRAS EQ @SY-LANGU
                              AND C~SPART EQ A~DIVISION
    LEFT OUTER JOIN T134T AS D ON D~SPRAS EQ @SY-LANGU
                              AND D~MTART EQ A~MATERIALTYPE
    LEFT OUTER JOIN T024D AS E ON E~WERKS EQ A~PLANT
                              AND E~DISPO EQ A~MRPCONTROLLER
   WHERE A~PLANT           EQ @P_WERKS
     AND A~MATERIAL        IN @S_MATNR
     AND A~REQDATE         IN @GR_DATE
*     AND A~DIVISION        IN @S_SPART
     AND A~MATERIALTYPE    IN @LR_MTART
     AND A~MRPCONTROLLER   IN @S_DISPO
     AND A~PURCHASINGGROUP IN @S_EKGRP
     AND A~DELETEFLAG      EQ @SPACE
     AND A~COMPLETED       EQ @SPACE
     AND A~REMAINQTY       GT 0
    INTO CORRESPONDING FIELDS OF TABLE @GT_CVDATA.

*-사내이체요청소요, 사내이체오더소요
  CLEAR: LT_CVDATA.
  SELECT A~PLANT AS WERKS,
         A~MATERIAL AS MATNR,
         A~REQDATE AS BDTER,
         A~DIVISION AS SPART,
         A~MATERIALGROUP AS MATKL,
         A~MATGROUPTEXT AS WGBEZ,
         A~MATERIALTYPE AS MTART,
         A~MRPCONTROLLER AS DISPO,
         A~PURCHASINGGROUP AS EKGRP,
         A~PURCHAGRPTEXT AS EKNAM,
         A~PURREQNO AS BANFN,
         A~PURREQITEM AS BNFPO,
         A~PURORDNO AS EBELN,
         A~PURORDITEM AS EBELP,
         A~REQUIREMENTTYPE AS BDART,
         A~BDTXT,
         A~MRPUNIT AS MEINS,
         A~DEMANDQTY AS DMQTY,
         A~GIQTY AS GIQTY,
         A~REMAINQTY AS RMQTY,
         B~MAKTX,
         C~VTEXT,
         D~MTBEZ,
         E~DSNAM
    FROM ZGTPP_CV_STO_DEMAND AS A
    LEFT OUTER JOIN MAKT  AS B ON B~MATNR EQ A~MATERIAL
                              AND B~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN TSPAT AS C ON C~SPRAS EQ @SY-LANGU
                              AND C~SPART EQ A~DIVISION
    LEFT OUTER JOIN T134T AS D ON D~SPRAS EQ @SY-LANGU
                              AND D~MTART EQ A~MATERIALTYPE
    LEFT OUTER JOIN T024D AS E ON E~WERKS EQ A~PLANT
                              AND E~DISPO EQ A~MRPCONTROLLER
   WHERE A~PLANT           EQ @P_WERKS
     AND A~MATERIAL        IN @S_MATNR
     AND A~REQDATE         IN @GR_DATE
*     AND A~DIVISION        IN @S_SPART
     AND A~MATERIALTYPE    IN @LR_MTART
     AND A~MRPCONTROLLER   IN @S_DISPO
     AND A~PURCHASINGGROUP IN @S_EKGRP
     AND A~REMAINQTY       GT 0
    INTO CORRESPONDING FIELDS OF TABLE @LT_CVDATA.

  LOOP AT LT_CVDATA INTO DATA(LS_CV).
    MOVE-CORRESPONDING LS_CV TO GS_CVDATA.
    APPEND GS_CVDATA TO GT_CVDATA.
    CLEAR: GS_CVDATA.
  ENDLOOP.

  REFRESH LT_CVDATA.

  PERFORM GET_D8_BDART TABLES LT_CVDATA.

  IF LT_CVDATA[] IS NOT INITIAL.
    LOOP AT LT_CVDATA INTO LS_CV.
      MOVE-CORRESPONDING LS_CV TO GS_CVDATA.
      APPEND GS_CVDATA TO GT_CVDATA.
      CLEAR: GS_CVDATA.
    ENDLOOP.
  ENDIF.


  LOOP AT GT_CVDATA ASSIGNING FIELD-SYMBOL(<FS_CV>).

*    IF P_CD = ABAP_TRUE.
    CLEAR LS_CHK_MATNR.
    LS_CHK_MATNR-MATNR = <FS_CV>-MATNR.
    COLLECT LS_CHK_MATNR INTO LT_CHK_MATNR.
*    ENDIF.

    CLEAR: LV_PSTYP.
    "공급의 구매요청 정보의 PSTYP = 7이면 R1->R3 (사내이체요청공급)
    IF <FS_CV>-BDART EQ 'R1'.
      SELECT SINGLE PSTYP
        FROM EBAN
       WHERE BANFN EQ @<FS_CV>-BANFN
         AND BNFPO EQ @<FS_CV>-BNFPO
        INTO @LV_PSTYP.

      IF LV_PSTYP EQ '7'.
        <FS_CV>-BDART = 'R3'.
      ENDIF.
      "공급의 구매오더 정보의 PSTYP = 7이면 R2->R4 (사내이체오더공급)
    ELSEIF <FS_CV>-BDART EQ 'R2'.
      SELECT SINGLE PSTYP
        FROM EKPO
       WHERE EBELN EQ @<FS_CV>-EBELN
         AND EBELP EQ @<FS_CV>-EBELP
        INTO @LV_PSTYP.

      IF LV_PSTYP EQ '7'.
        <FS_CV>-BDART = 'R4'.
      ENDIF.
    ENDIF.

***    "소요유형이 D3, D4, D5인 경우 상위 외주품목의 L/T 만큼 소요일을 앞당김
***    IF <FS_CV>-BDART EQ 'D3' OR
***       <FS_CV>-BDART EQ 'D4' OR
***       <FS_CV>-BDART EQ 'D5'.
***      CLEAR: LV_PLIFZ, LV_WEBAZ.
***      SELECT SINGLE A~PLIFZ, A~WEBAZ
***        FROM MARC AS A
***       INNER JOIN RESB AS B ON B~BAUGR EQ A~MATNR
***       WHERE A~WERKS EQ @<FS_CV>-WERKS
***         AND B~RSNUM EQ @<FS_CV>-RSNUM
***         AND B~RSPOS EQ @<FS_CV>-RSPOS
***        INTO (@LV_PLIFZ, @LV_WEBAZ).
***
***      DATA: LV_LT TYPE DLYDY.
***      CLEAR: LV_LT.
***      LV_LT = LV_PLIFZ + LV_WEBAZ.
***
***      CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
***        EXPORTING
***          DATE      = <FS_CV>-BDTER
***          DAYS      = LV_LT
***          MONTHS    = '00'
***          SIGNUM    = '-'
***          YEARS     = '00'
***        IMPORTING
***          CALC_DATE = <FS_CV>-BDTER.
***    ENDIF.

*-구분코드
    IF <FS_CV>-BDART EQ 'D1' OR
       <FS_CV>-BDART EQ 'D2' OR
       <FS_CV>-BDART EQ 'D3' OR
       <FS_CV>-BDART EQ 'D4' OR
       <FS_CV>-BDART EQ 'D5' OR
       <FS_CV>-BDART EQ 'D6' OR
       <FS_CV>-BDART EQ 'D7' OR
       <FS_CV>-BDART EQ 'D8'.
      <FS_CV>-GBNCD = 'DM'.
    ENDIF.

    IF <FS_CV>-BDART EQ 'R1' OR
       <FS_CV>-BDART EQ 'R2' OR
       <FS_CV>-BDART EQ 'R3' OR
       <FS_CV>-BDART EQ 'R4'.
      <FS_CV>-GBNCD = 'RS'.
    ENDIF.
  ENDLOOP.

  DELETE GT_CVDATA WHERE GBNCD IS INITIAL.

  IF LT_CHK_MATNR[] IS NOT INITIAL.
    REFRESH GT_CHK_MEINS.
    SELECT MATNR MEINS FROM MARA
      INTO TABLE GT_CHK_MEINS
      FOR ALL ENTRIES IN LT_CHK_MATNR
     WHERE MATNR = LT_CHK_MATNR-MATNR.

    SORT GT_CHK_MEINS BY MATNR.
    DELETE ADJACENT DUPLICATES FROM GT_CHK_MEINS COMPARING MATNR.
  ENDIF.

  REFRESH GT_PRE_CVDATA.
  FREE GT_PRE_CVDATA.
  IF P_CD = ABAP_TRUE AND LT_CHK_MATNR[] IS NOT INITIAL. " 과거 정보 확인을 위해

    READ TABLE GR_DATE INDEX 1.

    SELECT A~PLANT AS WERKS,
           A~MATERIAL AS MATNR,
           A~REQDATE AS BDTER,
           A~RESRVATIONNO AS RSNUM,
           A~RESRVATIONITEM AS RSPOS,
           A~AUFNR,
           A~DIVISION AS SPART,
           A~MATERIALGROUP AS MATKL,
           A~MATGROUPTEXT AS WGBEZ,
           A~MATERIALTYPE AS MTART,
           A~MRPCONTROLLER AS DISPO,
           A~PURCHASINGGROUP AS EKGRP,
           A~PURCHAGRPTEXT AS EKNAM,
           A~DELETEFLAG AS XLOEK,
           A~MOVEALLOW AS XWAOK,
           A~COMPLETED AS KZEAR,
           A~PURREQNO AS BANFN,
           A~PURREQITEM AS BNFPO,
           A~PURORDNO AS EBELN,
           A~PURORDITEM AS EBELP,
           A~PLDORDNO AS PLNUM,
           A~REQUIREMENTTYPE AS BDART,
           A~BDTXT,
           A~MRPUNIT AS MEINS,
           A~DEMANDQTY AS DMQTY,
           A~GIQTY AS GIQTY,
           A~REMAINQTY AS RMQTY,
           B~MAKTX,
           C~VTEXT,
           D~MTBEZ,
           E~DSNAM
      FROM ZGTPP_CV_MRP_DAY AS A
      LEFT OUTER JOIN MAKT  AS B ON B~MATNR EQ A~MATERIAL
                                AND B~SPRAS EQ @SY-LANGU
      LEFT OUTER JOIN TSPAT AS C ON C~SPRAS EQ @SY-LANGU
                                AND C~SPART EQ A~DIVISION
      LEFT OUTER JOIN T134T AS D ON D~SPRAS EQ @SY-LANGU
                                AND D~MTART EQ A~MATERIALTYPE
      LEFT OUTER JOIN T024D AS E ON E~WERKS EQ A~PLANT
                                AND E~DISPO EQ A~MRPCONTROLLER
      FOR ALL ENTRIES IN @LT_CHK_MATNR
     WHERE A~PLANT           EQ @P_WERKS
       AND A~MATERIAL        = @LT_CHK_MATNR-MATNR
       AND A~REQDATE         < @GR_DATE-LOW
*       AND A~DIVISION        IN @S_SPART
       AND A~MATERIALTYPE    IN @LR_MTART
       AND A~MRPCONTROLLER   IN @S_DISPO
       AND A~PURCHASINGGROUP IN @S_EKGRP
       AND A~DELETEFLAG      EQ @SPACE
       AND A~COMPLETED       EQ @SPACE
       AND A~REQUIREMENTTYPE IN ( 'D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7' )
       AND A~REMAINQTY       GT 0
      INTO CORRESPONDING FIELDS OF TABLE @GT_PRE_CVDATA.
  ENDIF.

  REFRESH GT_DATA.
  LOOP AT GT_CVDATA INTO GS_CVDATA.
    CLEAR GS_DATA.
    MOVE-CORRESPONDING GS_CVDATA TO GS_DATA.

    READ TABLE GT_CHK_MEINS INTO DATA(LS_CHK_MEINS) WITH KEY MATNR = GS_DATA-MATNR.
    IF SY-SUBRC EQ 0.
      GS_DATA-MEINS = LS_CHK_MEINS-MEINS.
    ENDIF.

    COLLECT GS_DATA INTO GT_DATA.
    CLEAR: GS_DATA.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form COLLECT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM COLLECT_DATA .

  DATA: LS_CV LIKE GS_CVDATA.
  DATA: L_WEEK LIKE SCAL-WEEK.

  REFRESH : GT_MATNR, GT_WSUM, GT_DSUM, GT_Z1, GT_PRE_DSUM.

  CASE ABAP_TRUE.
    WHEN P_CW.
      LOOP AT GT_CVDATA INTO LS_CV.
        MOVE-CORRESPONDING LS_CV TO GS_WSUM.

        CALL FUNCTION 'DATE_GET_WEEK'
          EXPORTING
            DATE = LS_CV-BDTER
          IMPORTING
            WEEK = GS_WSUM-WEEK.

*  외주품목의 경우 소요일자가 조회기간 이전으로 변경될 수 있으므로 첫날짜로 변경
        READ TABLE GT_WEEK TRANSPORTING NO FIELDS WITH KEY WEEK = GS_WSUM-WEEK.
        IF SY-SUBRC NE 0.
          READ TABLE GT_WEEK INTO DATA(LS_WEEK) INDEX 1.
          GS_WSUM-WEEK = LS_WEEK-WEEK.
        ENDIF.

*  단위수량 일치화
        READ TABLE GT_CHK_MEINS INTO DATA(LS_CHK_MEINS) WITH KEY MATNR = LS_CV-MATNR.
        IF SY-SUBRC = 0 AND LS_CHK_MEINS-MEINS NE LS_CV-MEINS.
          PERFORM TRANSLATE_UNIT USING LS_CV-MATNR LS_CHK_MEINS-MEINS LS_CV-MEINS
                                          CHANGING : GS_WSUM-DMQTY, GS_WSUM-GIQTY, GS_WSUM-RMQTY.
        ENDIF.

        COLLECT GS_WSUM INTO GT_WSUM.
        CLEAR: GS_WSUM.

*-자재 COLLECT
        MOVE: LS_CV-MATNR TO GS_MATNR-MATNR.

        COLLECT GS_MATNR INTO GT_MATNR.
        CLEAR: GS_MATNR, LS_CV.
      ENDLOOP.
    WHEN P_CD.
      LOOP AT GT_CVDATA INTO LS_CV.
        MOVE-CORRESPONDING LS_CV TO GS_DSUM.

        MOVE: LS_CV-BDTER TO GS_DSUM-DAY.

*  외주품목의 경우 소요일자가 조회기간 이전으로 변경될 수 있으므로 첫날짜로 변경
        IF GS_DSUM-DAY NOT IN GR_DATE.
          READ TABLE GR_DATE INDEX 1.
          GS_DSUM-DAY = GR_DATE-LOW.
        ENDIF.

*  단위수량 일치화
        READ TABLE GT_CHK_MEINS INTO LS_CHK_MEINS WITH KEY MATNR = LS_CV-MATNR.
        IF SY-SUBRC = 0 AND LS_CHK_MEINS-MEINS NE LS_CV-MEINS.
          PERFORM TRANSLATE_UNIT USING LS_CV-MATNR LS_CHK_MEINS-MEINS LS_CV-MEINS
                                          CHANGING : GS_DSUM-DMQTY, GS_DSUM-GIQTY, GS_DSUM-RMQTY.
        ENDIF.

        COLLECT GS_DSUM INTO GT_DSUM.
        CLEAR: GS_DSUM.

*-자재 COLLECT
        MOVE: LS_CV-MATNR TO GS_MATNR-MATNR.

        COLLECT GS_MATNR INTO GT_MATNR.
        CLEAR: GS_MATNR, LS_CV.
      ENDLOOP.

      LOOP AT GT_PRE_CVDATA INTO LS_CV.
* 이전 소요이력 SUM
        MOVE-CORRESPONDING LS_CV TO GS_PRE_DSUM.
        COLLECT GS_PRE_DSUM INTO GT_PRE_DSUM.
        CLEAR GS_PRE_DSUM.
      ENDLOOP.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ETC_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ETC_DATA .

  IF GT_MATNR IS NOT INITIAL.
    SORT GT_MATNR BY MATNR.

*-현재고
    CLEAR: GT_STOCK.
    SELECT MATNR, LABST, INSME
      FROM ZGTMM_CV_GET_STOCKLIST
       FOR ALL ENTRIES IN @GT_MATNR
     WHERE MATNR EQ @GT_MATNR-MATNR
       AND WERKS EQ @P_WERKS
      INTO CORRESPONDING FIELDS OF TABLE @GT_STOCK.

    LOOP AT GT_STOCK ASSIGNING FIELD-SYMBOL(<FS_S>).
      <FS_S>-STSUM = <FS_S>-LABST + <FS_S>-INSME.
    ENDLOOP.

*-적정재고 정보
    CLEAR: GT_SUIT.
    SELECT WERKS, MATNR, SU_QTY_P, SU_QTY_F, MEINS, ERDAT
      FROM ZGTMM_CV_SUITSTOCK_DAILY
       FOR ALL ENTRIES IN @GT_MATNR
     WHERE MATNR EQ @GT_MATNR-MATNR
       AND WERKS EQ @P_WERKS
       AND ERDAT EQ ( SELECT MAX( ERDAT )
                        FROM ZGTMM_CV_SUITSTOCK_DAILY
                       WHERE MATNR EQ @GT_MATNR-MATNR
                         AND WERKS EQ @P_WERKS )
      INTO CORRESPONDING FIELDS OF TABLE @GT_SUIT.

*-자재 기타 정보
    CLEAR: GT_ETC.
    SELECT MATNR, DISLS, BSTMI, BSTRF,
           PLIFZ, WEBAZ,
           EISBE, EISLO
      FROM MARC
       FOR ALL ENTRIES IN @GT_MATNR
     WHERE MATNR EQ @GT_MATNR-MATNR
       AND WERKS EQ @P_WERKS
      INTO CORRESPONDING FIELDS OF TABLE @GT_ETC.

    LOOP AT GT_ETC ASSIGNING FIELD-SYMBOL(<FS_E>).
      ADD <FS_E>-WEBAZ TO <FS_E>-PLIFZ.

      IF <FS_E>-EISBE LT <FS_E>-EISLO.
        <FS_E>-EISBE = <FS_E>-EISLO.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DISP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_DISP_DATA .

  DATA : LS_DATA TYPE REF TO DATA.
  DATA : LS_DATA2 TYPE REF TO DATA.
  DATA : LS_DATA3 TYPE REF TO DATA.
  DATA : LT_DATA TYPE REF TO DATA.
  DATA : LV_FDAY TYPE CHAR10.
  DATA : LV_TDAY TYPE CHAR10.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_FIELDNAME2 TYPE FIELDNAME.
  DATA : LV_CHK_MINUS.
  DATA : LV_CHK_USE.
  DATA : LV_UINT LIKE ZGTMMT4210-PSTOCK.
  DATA : LV_EISBE LIKE ZGTMMT4210-PSTOCK.
  DATA : LV_STOCK LIKE ZGTMMT4210-PSTOCK.
  DATA : LV_VALID LIKE ZGTMMT4210-PSTOCK.
  DATA : LV_VALID_CHK LIKE ZGTMMT4210-PSTOCK.
  DATA : LV_VALID_DISP LIKE ZGTMMT4210-PSTOCK.
  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LV_DATE_CHK TYPE SY-DATUM.
  DATA : LV_DUEDATE_SUM TYPE ZGTMMT4210-PSTOCK.
  DATA : LV_CHK_DM. "예상재고 - 제품여부 확인.
  FIELD-SYMBOLS <LS_LINE> TYPE ANY. " 라인정보
  FIELD-SYMBOLS <LS_LINE2> TYPE ANY. " 라인정보
  FIELD-SYMBOLS <LS_LINE3> TYPE ANY. " 라인정보
  FIELD-SYMBOLS <LT_LINE> TYPE TABLE. " 라인정보
  FIELD-SYMBOLS <LS_MAIN> TYPE ANY. " 라인정보
  FIELD-SYMBOLS <LV_FIELD> TYPE ANY.
  FIELD-SYMBOLS <LV_FIELD2> TYPE ANY.
  FIELD-SYMBOLS <LV_GBNCD> TYPE ANY.
  FIELD-SYMBOLS <LV_GBNCD2> TYPE ANY.
  FIELD-SYMBOLS <LV_STOCK> TYPE ANY.
  FIELD-SYMBOLS <LV_STOCK_CHK> TYPE ANY.
  FIELD-SYMBOLS <LV_VALID> TYPE ANY.


  DEFINE __ASSIGN_FIELD.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = &1.
    IF <LV_FIELD> IS ASSIGNED. UNASSIGN <LV_FIELD>. ENDIF.
    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_FIELD>.
  END-OF-DEFINITION.

  DEFINE __ASSIGN_FIELD_2.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = &1.
    IF <LV_FIELD2> IS ASSIGNED. UNASSIGN <LV_FIELD2>. ENDIF.
    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_FIELD2>.
  END-OF-DEFINITION.

  DEFINE __ASSIGN_FIELD_LINE2.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = &1.
    IF <LV_FIELD2> IS ASSIGNED. UNASSIGN <LV_FIELD2>. ENDIF.
    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_LINE2> TO <LV_FIELD2>.
  END-OF-DEFINITION.

  DEFINE __ASSIGN_FIELD2.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = &1.
    IF <LV_FIELD> IS ASSIGNED. UNASSIGN <LV_FIELD>. ENDIF.
    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_SUM_LINE> TO <LV_FIELD>.
  END-OF-DEFINITION.

  DEFINE __ASSIGN_FIELD2_2.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = &1.
    IF <LV_FIELD2> IS ASSIGNED. UNASSIGN <LV_FIELD2>. ENDIF.
    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_SUM_LINE> TO <LV_FIELD2>.
  END-OF-DEFINITION.

  REFRESH <GT_MAIN_DISP_100>.

  SELECT SINGLE EKORG FROM T024W
    WHERE WERKS = @P_WERKS
     INTO @DATA(LV_EKORG).

  CREATE DATA LS_DATA LIKE LINE OF <GT_MAIN_DISP_100>.
  ASSIGN LS_DATA->* TO <LS_LINE>.
  CREATE DATA LS_DATA LIKE LINE OF <GT_MAIN_DISP_100>.
  ASSIGN LS_DATA2->* TO <LS_LINE2>.
  CREATE DATA LS_DATA LIKE LINE OF <GT_MAIN_DISP_100>.
  ASSIGN LS_DATA3->* TO <LS_LINE3>.
  CREATE DATA LT_DATA LIKE <GT_MAIN_DISP_100>.
  ASSIGN LT_DATA->* TO <LT_LINE>.


  SORT : GT_WSUM BY MATNR WEEK GBNCD,
             GT_DSUM BY MATNR DAY BDART.

  SORT GT_PRE_DSUM BY MATNR BDART.

  LOOP AT GT_DATA INTO GS_DATA.
*   숫자 필드 초기값 세팅
    GS_DATA-BSTMI = 0.
    GS_DATA-PLIFZ = 0.
    GS_DATA-BSTRF = 0.
    GS_DATA-EISBE = 0.
    GS_DATA-STOCK = 0.
    GS_DATA-LABST = 0.

    CLEAR LV_EISBE.
    READ TABLE GT_ETC INTO DATA(LS_ETC) WITH KEY MATNR = GS_DATA-MATNR.
    IF SY-SUBRC EQ 0.
      GS_DATA-DISLS = LS_ETC-DISLS.
      GS_DATA-BSTMI = LS_ETC-BSTMI.
      GS_DATA-BSTRF = LS_ETC-BSTRF.
*      GS_DATA-PLIFZ = LS_ETC-PLIFZ.
      GS_DATA-EISBE = LS_ETC-EISBE.
    ENDIF.

    SELECT SINGLE MIN( B~APLFZ ) AS APLFZ INTO @DATA(LV_APLFZ)
      FROM EINA AS A
      INNER JOIN EINE AS B ON A~INFNR = B~INFNR
     WHERE A~MATNR = @GS_DATA-MATNR
       AND B~EKORG = @LV_EKORG
       AND B~WERKS = @P_WERKS.

    IF SY-SUBRC EQ 0.
      GS_DATA-PLIFZ = LV_APLFZ.
    ENDIF.

    READ TABLE GT_STOCK INTO DATA(LS_STOCK) WITH KEY MATNR = GS_DATA-MATNR.
    IF SY-SUBRC EQ 0.
      GS_DATA-LABST = LS_STOCK-STSUM.
    ENDIF.

    CLEAR LV_STOCK.
    CLEAR LV_UINT.
    LV_UINT = GS_DATA-LABST.
    LV_STOCK = GS_DATA-LABST.
    WRITE LV_UINT TO GS_DATA-LABST UNIT GS_DATA-MEINS.


    READ TABLE GT_SUIT INTO DATA(LS_SUIT) WITH KEY MATNR = GS_DATA-MATNR.
    IF SY-SUBRC EQ 0.
      CASE ABAP_TRUE.
        WHEN P_CP.
          GS_DATA-STOCK = LS_SUIT-SU_QTY_P.
        WHEN P_CF.
          GS_DATA-STOCK = LS_SUIT-SU_QTY_F.
      ENDCASE.
    ENDIF.

    IF GS_DATA-STOCK = 0.
      LV_EISBE = GS_DATA-EISBE.
    ELSE.
      LV_EISBE = GS_DATA-STOCK.
    ENDIF.

    CLEAR LV_UINT.
    LV_UINT = GS_DATA-STOCK.
    WRITE LV_UINT TO GS_DATA-STOCK UNIT GS_DATA-MEINS.

    CLEAR LV_UINT.
    LV_UINT = GS_DATA-EISBE.
    WRITE LV_UINT TO GS_DATA-EISBE UNIT GS_DATA-MEINS.

    CONDENSE : GS_DATA-BSTMI,
                GS_DATA-BSTRF,
                GS_DATA-PLIFZ,
                GS_DATA-LABST,
                GS_DATA-EISBE,
                GS_DATA-LABST,
                GS_DATA-STOCK.

    CLEAR <LS_LINE>.
    MOVE-CORRESPONDING GS_DATA TO <LS_LINE>.
    CLEAR LV_CHK_MINUS. " 신호등 처리를 위한 변수
    CLEAR LV_DUEDATE_SUM.
    CLEAR LV_VALID_CHK.
    CLEAR : LV_CHK_DM.
* 기간별 정렬
    CASE ABAP_TRUE.
      WHEN  P_CW. " 주차별
        REFRESH <LT_LINE>.

* 소요예정랑
        APPEND INITIAL LINE TO <LT_LINE> ASSIGNING <LS_MAIN>.
        MOVE-CORRESPONDING <LS_LINE> TO <LS_MAIN>.
        __ASSIGN_FIELD 'SEQNO'.
        <LV_FIELD> = 1.
        __ASSIGN_FIELD 'GBTXT'.
        <LV_FIELD> = '소요예정랑'.
        LOOP AT GT_WSUM INTO DATA(LS_WSUM) WHERE MATNR = GS_DATA-MATNR
                                                                      AND GBNCD = 'DM'.
          __ASSIGN_FIELD LS_WSUM-WEEK.
          CLEAR LV_UINT.
          LV_UINT = <LV_FIELD>.
          LV_UINT = LV_UINT + LS_WSUM-DMQTY.
          <LV_FIELD> = LV_UINT.
        ENDLOOP.

* 입고계획
        APPEND INITIAL LINE TO <LT_LINE> ASSIGNING <LS_MAIN>.
        MOVE-CORRESPONDING <LS_LINE> TO <LS_MAIN>.
        __ASSIGN_FIELD 'SEQNO'.
        <LV_FIELD> = 2.
        __ASSIGN_FIELD 'GBTXT'.
        <LV_FIELD> = '입고계획'.
        LOOP AT GT_WSUM INTO LS_WSUM WHERE MATNR = GS_DATA-MATNR
                                                              AND GBNCD = 'RS'.
          __ASSIGN_FIELD LS_WSUM-WEEK.
          CLEAR LV_UINT.
          LV_UINT = <LV_FIELD>.
          LV_UINT = LV_UINT + LS_WSUM-RMQTY.
          <LV_FIELD> = LV_UINT.
        ENDLOOP.

* 예상재고
        APPEND INITIAL LINE TO <LT_LINE> ASSIGNING <LS_MAIN>.
        MOVE-CORRESPONDING <LS_LINE> TO <LS_MAIN>.
        __ASSIGN_FIELD 'SEQNO'.
        <LV_FIELD> = 3.
        __ASSIGN_FIELD 'GBTXT'.
        <LV_FIELD> = '예상재고'.

        LOOP AT GT_WEEK INTO GS_WEEK.
          LOOP AT <LT_LINE> ASSIGNING FIELD-SYMBOL(<LS_SUM_LINE>).
            ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_SUM_LINE> TO FIELD-SYMBOL(<LV_SEQNO>).
            __ASSIGN_FIELD2 GS_WEEK-WEEK.
            CASE <LV_SEQNO>.
              WHEN 1.
                LV_STOCK = LV_STOCK - <LV_FIELD>.
              WHEN 2.
                LV_STOCK = LV_STOCK + <LV_FIELD>.
            ENDCASE.
            CLEAR LV_UINT.
            LV_UINT = <LV_FIELD>.
            WRITE LV_UINT TO <LV_FIELD> UNIT GS_DATA-MEINS.
            CONDENSE <LV_FIELD>.

          ENDLOOP.

          __ASSIGN_FIELD GS_WEEK-WEEK.
          WRITE LV_STOCK TO <LV_FIELD> UNIT GS_DATA-MEINS.
          PERFORM CHK_AND_SET_NUM_TO_CHAR CHANGING <LV_FIELD>.

          IF LV_STOCK < LV_EISBE. " 재고가 안전재고보다 작다면 붉은색 처리를 위해_CHK사용
            CLEAR LV_FIELDNAME2.
            LV_FIELDNAME2 = GS_WEEK-WEEK && '_CHK'.
            __ASSIGN_FIELD LV_FIELDNAME2.
            <LV_FIELD> = ABAP_TRUE.
            LV_CHK_DM = ABAP_TRUE.
            LV_CHK_MINUS = ABAP_TRUE.
          ENDIF.
        ENDLOOP.

*      신호등 처리
        LOOP AT <LT_LINE> ASSIGNING <LS_SUM_LINE>.
          __ASSIGN_FIELD2 'ID'.
          IF LV_CHK_MINUS = ABAP_TRUE.
            <LV_FIELD> = ICON_LED_RED.
          ELSE.
            <LV_FIELD> = ICON_LED_GREEN.
          ENDIF.
        ENDLOOP.

        IF LV_CHK_DM = ABAP_FALSE AND P_DM = ABAP_TRUE.
          CONTINUE.
        ENDIF.

        APPEND LINES OF <LT_LINE> TO <GT_MAIN_DISP_100>.

      WHEN  P_CD. " 일별
        REFRESH <LT_LINE>.

        LOOP AT GT_GBN_PLAN INTO GS_GBN_PLAN.
          APPEND INITIAL LINE TO <LT_LINE> ASSIGNING <LS_MAIN>.
          MOVE-CORRESPONDING <LS_LINE> TO <LS_MAIN>.
          __ASSIGN_FIELD 'SEQNO'.
          <LV_FIELD> = GS_GBN_PLAN-SEQNO.
          __ASSIGN_FIELD 'GBTXT'.
          <LV_FIELD> = GS_GBN_PLAN-GBTXT.
          __ASSIGN_FIELD 'BDTXT'.
          <LV_FIELD> = GS_GBN_PLAN-BDTXT.
          __ASSIGN_FIELD 'GBNCD'.
          <LV_FIELD> = GS_GBN_PLAN-GBNCD.

          CLEAR LV_CHK_USE.
          LOOP AT GT_DSUM INTO DATA(LS_DSUM) WHERE MATNR = GS_DATA-MATNR
                                                                        AND BDART = GS_GBN_PLAN-BDART.
            __ASSIGN_FIELD LS_DSUM-DAY.
            CLEAR LV_UINT.
            LV_UINT = <LV_FIELD>.
            CASE LS_DSUM-BDART.
              WHEN 'R1' OR 'R2' OR 'R3' OR 'R4'.
                LV_UINT = LV_UINT + LS_DSUM-RMQTY.
              WHEN OTHERS.
                LV_UINT = LV_UINT + LS_DSUM-DMQTY.
            ENDCASE.
            <LV_FIELD> = LV_UINT.
            LV_CHK_USE = ABAP_TRUE.
          ENDLOOP.

*        각 자재의 이전 소요량 확인
          READ TABLE GT_PRE_DSUM INTO GS_PRE_DSUM WITH KEY MATNR = GS_DATA-MATNR
                                                                                  BDART = GS_GBN_PLAN-BDART BINARY SEARCH.
          IF SY-SUBRC EQ 0.
            __ASSIGN_FIELD 'DUEDATE'.
            CLEAR LV_UINT.
            LV_UINT = GS_PRE_DSUM-DMQTY.
            WRITE LV_UINT TO <LV_FIELD> UNIT GS_DATA-MEINS.
            CONDENSE <LV_FIELD>.
            LV_CHK_USE = ABAP_TRUE.
          ENDIF.

          IF LV_CHK_USE IS INITIAL.
            DATA(LV_TABIX) = LINES( <LT_LINE> ).
            DELETE <LT_LINE> INDEX LV_TABIX.
          ENDIF.
        ENDLOOP.

* 예상재고
        APPEND INITIAL LINE TO <LT_LINE> ASSIGNING <LS_MAIN>.
        MOVE-CORRESPONDING <LS_LINE> TO <LS_MAIN>.

        READ TABLE GT_GBN_PLAN INTO GS_GBN_PLAN WITH KEY GBNCD = 'Z1'.

        __ASSIGN_FIELD 'SEQNO'.
        <LV_FIELD> = GS_GBN_PLAN-SEQNO.
        __ASSIGN_FIELD 'GBTXT'.
        <LV_FIELD> = GS_GBN_PLAN-GBTXT.
        __ASSIGN_FIELD 'BDTXT'.
        <LV_FIELD> = GS_GBN_PLAN-BDTXT.
        __ASSIGN_FIELD 'GBNCD'.
        <LV_FIELD> = GS_GBN_PLAN-GBNCD.

* 구매제안
* 예상재고 - 안전재고 결과로 구매제안 작성
*&---------------------------------------------------------------------*
        APPEND INITIAL LINE TO <LT_LINE> ASSIGNING <LS_LINE2>.
        MOVE-CORRESPONDING <LS_LINE> TO <LS_LINE2>.

        READ TABLE GT_GBN_PLAN INTO GS_GBN_PLAN WITH KEY GBNCD = 'Z2'.

        __ASSIGN_FIELD_LINE2 'SEQNO'.
        <LV_FIELD2> = GS_GBN_PLAN-SEQNO.
        __ASSIGN_FIELD_LINE2 'GBTXT'.
        <LV_FIELD2> = GS_GBN_PLAN-GBTXT.
        __ASSIGN_FIELD_LINE2 'BDTXT'.
        <LV_FIELD2> = GS_GBN_PLAN-BDTXT.
        __ASSIGN_FIELD_LINE2 'GBNCD'.
        <LV_FIELD2> = GS_GBN_PLAN-GBNCD.
*&---------------------------------------------------------------------*

        READ TABLE GR_DATE INDEX 1.
        LV_DATE = GR_DATE-LOW.

        DO .
          LOOP AT <LT_LINE> ASSIGNING <LS_SUM_LINE>.
            __ASSIGN_FIELD2 'GBNCD'.
            __ASSIGN_FIELD2_2 LV_DATE.
            CASE <LV_FIELD>.
              WHEN 'DM'.
                LV_STOCK = LV_STOCK - <LV_FIELD2>.
              WHEN 'RS'.
                LV_STOCK = LV_STOCK + <LV_FIELD2>.
              WHEN OTHERS.
                CONTINUE.
            ENDCASE.
            CLEAR LV_UINT.
            LV_UINT = <LV_FIELD2>.
            WRITE LV_UINT TO <LV_FIELD2> UNIT GS_DATA-MEINS.
            CONDENSE <LV_FIELD2>.
          ENDLOOP.
* 해당 날짜별 예상재고량 세팅
          CLEAR LV_FIELDNAME.
          LV_FIELDNAME = LV_DATE.
          IF <LV_STOCK> IS ASSIGNED. UNASSIGN <LV_STOCK>. ENDIF.
          ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_STOCK>.
          WRITE LV_STOCK TO <LV_STOCK> UNIT GS_DATA-MEINS.
          PERFORM CHK_AND_SET_NUM_TO_CHAR CHANGING <LV_STOCK>.

          IF LV_STOCK < LV_EISBE. " 재고가 안전재고보다 작다면 붉은색 처리를 위해_CHK사용
            CLEAR : LV_VALID, LV_VALID_DISP.
            CLEAR LV_FIELDNAME.
            LV_FIELDNAME = LV_DATE && '_CHK'.
            IF <LV_STOCK_CHK> IS ASSIGNED. UNASSIGN <LV_STOCK_CHK>. ENDIF.
            ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_STOCK_CHK>.
            <LV_STOCK_CHK> = ABAP_TRUE.
            LV_CHK_DM = ABAP_TRUE.
            LV_CHK_MINUS = ABAP_TRUE.

            LV_VALID = LV_STOCK - LV_EISBE.
            CLEAR LV_DATE_CHK.
            LV_DATE_CHK = LV_DATE - GS_DATA-PLIFZ.

            IF LV_VALID_CHK IS INITIAL.
              LV_VALID_CHK =  LV_VALID.
              LV_VALID_DISP = LV_VALID.
              IF LV_VALID_DISP < 0.
                LV_VALID_DISP = LV_VALID_DISP * -1.
              ENDIF.

*            조회시작일보다 작다면 DUEDATE로 처리후 계산
              IF LV_DATE_CHK < GR_DATE-LOW.
                IF LV_DUEDATE_SUM > LV_VALID.
                  LV_DUEDATE_SUM = LV_VALID.
                ENDIF.
              ELSE.
                __ASSIGN_FIELD_LINE2  LV_DATE_CHK.
                WRITE LV_VALID_DISP TO <LV_FIELD2> UNIT GS_DATA-MEINS.
                PERFORM CHK_AND_SET_NUM_TO_CHAR CHANGING <LV_FIELD2>.
              ENDIF.

            ELSEIF LV_VALID_CHK IS NOT INITIAL.
              IF LV_VALID_CHK > LV_VALID.
                LV_VALID_DISP = LV_VALID - LV_VALID_CHK.
                LV_VALID_CHK = LV_VALID.
                IF LV_VALID_DISP < 0.
                  LV_VALID_DISP = LV_VALID_DISP * -1.
                ENDIF.
                IF LV_DATE_CHK < GR_DATE-LOW.
                  IF LV_DUEDATE_SUM > LV_VALID.
                    LV_DUEDATE_SUM = LV_VALID.
                  ENDIF.
                ELSE.
                  __ASSIGN_FIELD_LINE2  LV_DATE_CHK.
                  WRITE LV_VALID_DISP TO <LV_FIELD2> UNIT GS_DATA-MEINS.
                  PERFORM CHK_AND_SET_NUM_TO_CHAR CHANGING <LV_FIELD2>.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.

          IF GR_DATE-HIGH = LV_DATE.
            EXIT.
          ENDIF.

          ADD 1 TO LV_DATE.
        ENDDO.

        IF LV_DUEDATE_SUM NE 0.
          __ASSIGN_FIELD_LINE2  'DUEDATE'.
          LV_DUEDATE_SUM = LV_DUEDATE_SUM * -1.
          WRITE LV_DUEDATE_SUM TO <LV_FIELD2> UNIT GS_DATA-MEINS.
          PERFORM CHK_AND_SET_NUM_TO_CHAR CHANGING <LV_FIELD2>.
        ENDIF.

*      신호등 처리
        LOOP AT <LT_LINE> ASSIGNING <LS_SUM_LINE>.
          __ASSIGN_FIELD2 'ID'.
          IF LV_CHK_MINUS = ABAP_TRUE.
            <LV_FIELD> = ICON_LED_RED.
          ELSE.
            <LV_FIELD> = ICON_LED_GREEN.
          ENDIF.
        ENDLOOP.

        IF LV_CHK_DM = ABAP_FALSE AND P_DM = ABAP_TRUE.
          CONTINUE.
        ENDIF.

        APPEND LINES OF <LT_LINE> TO <GT_MAIN_DISP_100>.

    ENDCASE.


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
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_FIELDNAME2 TYPE FIELDNAME.
  DATA : LV_STYLE01  TYPE LVC_STYLE.
  DATA : LV_DATE TYPE SY-DATUM.
  FIELD-SYMBOLS <LV_FIELD> TYPE ANY.
  FIELD-SYMBOLS <LV_FIELD2> TYPE ANY.
  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

  DEFINE __ASSIGN_FIELD.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = &1.
    IF <LV_FIELD> IS ASSIGNED. UNASSIGN <LV_FIELD>. ENDIF.
    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_DATA> TO <LV_FIELD>.
  END-OF-DEFINITION.

  DEFINE __ASSIGN_FIELD2.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = &1.
    IF <LV_FIELD2> IS ASSIGNED. UNASSIGN <LV_FIELD2>. ENDIF.
    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_DATA> TO <LV_FIELD2>.
  END-OF-DEFINITION.

  DEFINE __SET_STYLE.
    CLEAR LS_CELLTAB.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = &1.
    LS_CELLTAB-FIELDNAME = LV_FIELDNAME.
    LS_CELLTAB-STYLE = CONV #( &2 ).
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  END-OF-DEFINITION.

  LOOP AT <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_DATA>).
    REFRESH LT_CELLTAB.
    LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FACT>).
      CASE <LS_FACT>-FIELDNAME.
        WHEN 'ID' OR 'WERKS' OR 'MATNR' OR 'MAKTX' OR 'MTART' OR 'SPART' OR 'MATKL' OR 'WGBEZ'
            OR 'DISPO' OR 'EKGRP' OR 'EKNAM'.
          __SET_STYLE <LS_FACT>-FIELDNAME ALV_STYLE_COLOR_INT_KEY.
        WHEN 'DISLS' OR 'MEINS' OR 'BSTMI' OR 'BSTRF' OR 'PLIFZ' OR 'EISBE' OR 'STOCK' OR 'LABST'.
          __SET_STYLE <LS_FACT>-FIELDNAME ALV_STYLE_COLOR_KEY.
      ENDCASE.
    ENDLOOP.

    CASE ABAP_TRUE.
      WHEN P_CW.
        __ASSIGN_FIELD 'SEQNO'.
        CASE <LV_FIELD>.
          WHEN 1 OR 2.
            CASE <LV_FIELD>.
              WHEN 1.
                LV_STYLE01 = ALV_STYLE_COLOR_GROUP.
              WHEN 2.
                LV_STYLE01 = ALV_STYLE_COLOR_POSITIVE.
            ENDCASE.

            __SET_STYLE 'GBTXT' LV_STYLE01.

            LOOP AT GT_WEEK INTO GS_WEEK.
              __SET_STYLE GS_WEEK-WEEK LV_STYLE01.
            ENDLOOP.
          WHEN 3.
            LOOP AT GT_WEEK INTO GS_WEEK.
              CLEAR LV_FIELDNAME2.
              LV_FIELDNAME2 = GS_WEEK-WEEK && '_CHK'.
              __ASSIGN_FIELD2 LV_FIELDNAME2.
              IF <LV_FIELD2> = ABAP_TRUE.
                __SET_STYLE GS_WEEK-WEEK ALV_STYLE_COLOR_INV_NEGATIVE.
              ENDIF.
            ENDLOOP.
        ENDCASE.

      WHEN P_CD.
        __ASSIGN_FIELD 'GBNCD'.
        CASE <LV_FIELD>.
          WHEN 'DM' OR 'RS'.
            CASE <LV_FIELD>.
              WHEN 'DM'.
                LV_STYLE01 = ALV_STYLE_COLOR_GROUP.
              WHEN 'RS'.
                LV_STYLE01 = ALV_STYLE_COLOR_POSITIVE.
            ENDCASE.
            __SET_STYLE 'GBTXT' LV_STYLE01.
            __SET_STYLE 'BDTXT' LV_STYLE01.
            __SET_STYLE 'DUEDATE' LV_STYLE01.

            READ TABLE GR_DATE INDEX 1.
            LV_DATE = GR_DATE-LOW.
            DO .
              __SET_STYLE LV_DATE LV_STYLE01.
              IF GR_DATE-HIGH = LV_DATE.
                EXIT.
              ENDIF.

              ADD 1 TO LV_DATE.
            ENDDO.
          WHEN 'Z1'.
            READ TABLE GR_DATE INDEX 1.
            LV_DATE = GR_DATE-LOW.
            DO .
              CLEAR LV_FIELDNAME2.
              LV_FIELDNAME2 = LV_DATE && '_CHK'.
              __ASSIGN_FIELD2 LV_FIELDNAME2.
              IF <LV_FIELD2> = ABAP_TRUE.
                __SET_STYLE LV_DATE ALV_STYLE_COLOR_INV_NEGATIVE.
              ENDIF.
              IF GR_DATE-HIGH = LV_DATE.
                EXIT.
              ENDIF.

              ADD 1 TO LV_DATE.
            ENDDO.

          WHEN 'Z2'.
            __SET_STYLE 'GBTXT' ALV_STYLE_COLOR_HEADING.
            __SET_STYLE 'BDTXT' ALV_STYLE_COLOR_HEADING.
            CLEAR LV_FIELDNAME2.
            LV_FIELDNAME2 = 'DUEDATE'.
            __ASSIGN_FIELD2 LV_FIELDNAME2.
            IF <LV_FIELD2> IS INITIAL.
              __SET_STYLE 'DUEDATE' ALV_STYLE_COLOR_HEADING.
            ELSE.
              __SET_STYLE 'DUEDATE' ALV_STYLE_COLOR_INT_NEGATIVE.
            ENDIF.
            READ TABLE GR_DATE INDEX 1.
            LV_DATE = GR_DATE-LOW.
            DO .
              CLEAR LV_FIELDNAME2.
              LV_FIELDNAME2 = LV_DATE.
              __ASSIGN_FIELD2 LV_FIELDNAME2.
              IF <LV_FIELD2> IS INITIAL.
                __SET_STYLE LV_DATE ALV_STYLE_COLOR_HEADING.
              ELSE.
                __SET_STYLE LV_DATE ALV_STYLE_COLOR_INT_NEGATIVE.
              ENDIF.
              IF GR_DATE-HIGH = LV_DATE.
                EXIT.
              ENDIF.

              ADD 1 TO LV_DATE.
            ENDDO.

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
*& Form SET_SORTTAB_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0100 .

  REFRESH GT_SORT_0100.

  CASE ABAP_TRUE.
    WHEN P_MATNR.
      PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                                USING : 1 'WERKS'  'X' '' '',
                                           2 'MATNR'  'X' '' '',
                                           3 'MAKTX'  'X' '' '',
                                           4 'SEQNO'  'X' '' '',
                                           5 'ID'  'X' '' '',
                                           6 'MTART'  'X' '' '',
                                           7 'SPART'  'X' '' '',
                                           8 'MATKL'  'X' '' '',
                                           9 'WGBEZ'  'X' '' '',
                                           10 'DISPO'  'X' '' '',
                                           11 'EKGRP'  'X' '' '',
                                           12 'EKNAM'  'X' '' '',
                                           13 'DISLS'  'X' '' '',
                                           14 'MEINS'  'X' '' '',
                                           15 'BSTMI'  'X' '' '',
                                           16 'BSTRF'  'X' '' '',
                                           17 'PLIFZ'  'X' '' '',
                                           18 'EISBE'  'X' '' '',
                                           19 'STOCK'  'X' '' '',
                                           20 'LABST'  'X' '' ''.
    WHEN P_MTART.
      PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                                USING : 1 'WERKS'  'X' '' '',
                                           2 'MTART'  'X' '' '',
                                           3 'MATNR'  'X' '' '',
                                           4 'MAKTX'  'X' '' '',
                                           5 'SEQNO'  'X' '' '',
                                           6 'ID'  'X' '' '',
                                           7 'SPART'  'X' '' '',
                                           8 'MATKL'  'X' '' '',
                                           9 'WGBEZ'  'X' '' '',
                                           10 'DISPO'  'X' '' '',
                                           11 'EKGRP'  'X' '' '',
                                           12 'EKNAM'  'X' '' '',
                                           13 'DISLS'  'X' '' '',
                                           14 'MEINS'  'X' '' '',
                                           15 'BSTMI'  'X' '' '',
                                           16 'BSTRF'  'X' '' '',
                                           17 'PLIFZ'  'X' '' '',
                                           18 'EISBE'  'X' '' '',
                                           19 'STOCK'  'X' '' '',
                                           20 'LABST'  'X' '' ''.
    WHEN P_DISPO.
      PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                                USING : 1 'WERKS'  'X' '' '',
                                           2 'DISPO'  'X' '' '',
                                           3 'MATNR'  'X' '' '',
                                           4 'MAKTX'  'X' '' '',
                                           5 'SEQNO'  'X' '' '',
                                           6 'ID'  'X' '' '',
                                           7 'MTART'  'X' '' '',
                                           8 'SPART'  'X' '' '',
                                           9 'MATKL'  'X' '' '',
                                           10 'WGBEZ'  'X' '' '',
                                           11 'EKGRP'  'X' '' '',
                                           12 'EKNAM'  'X' '' '',
                                           13 'DISLS'  'X' '' '',
                                           14 'MEINS'  'X' '' '',
                                           15 'BSTMI'  'X' '' '',
                                           16 'BSTRF'  'X' '' '',
                                           17 'PLIFZ'  'X' '' '',
                                           18 'EISBE'  'X' '' '',
                                           19 'STOCK'  'X' '' '',
                                           20 'LABST'  'X' '' ''.
    WHEN P_EKGRP.
      PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                                USING : 1 'WERKS'  'X' '' '',
                                           2 'EKGRP'  'X' '' '',
                                           3 'MATNR'  'X' '' '',
                                           4 'MAKTX'  'X' '' '',
                                           5 'SEQNO'  'X' '' '',
                                           6 'ID'  'X' '' '',
                                           7 'MTART'  'X' '' '',
                                           8 'SPART'  'X' '' '',
                                           9 'MATKL'  'X' '' '',
                                           10 'WGBEZ'  'X' '' '',
                                           11 'DISPO'  'X' '' '',
                                           12 'EKNAM'  'X' '' '',
                                           13 'DISLS'  'X' '' '',
                                           14 'MEINS'  'X' '' '',
                                           15 'BSTMI'  'X' '' '',
                                           16 'BSTRF'  'X' '' '',
                                           17 'PLIFZ'  'X' '' '',
                                           18 'EISBE'  'X' '' '',
                                           19 'STOCK'  'X' '' '',
                                           20 'LABST'  'X' '' ''.
  ENDCASE.

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
*& Form CHK_AND_SET_NUM_TO_CHAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LV_FIELD2>
*&---------------------------------------------------------------------*
FORM CHK_AND_SET_NUM_TO_CHAR  CHANGING PV_VALUE.

  FIND '-' IN PV_VALUE.
  IF SY-SUBRC EQ 0.
    SPLIT  PV_VALUE AT '-' INTO DATA(LV_STRING1) DATA(LV_STRING2).
    CONDENSE LV_STRING1.
    LV_STRING1 = '-' && LV_STRING1.
    PV_VALUE = LV_STRING1.
  ELSE.
    CONDENSE PV_VALUE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_DATA .

  PERFORM PROC_GET_DATA.
  PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID..

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_DM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_CVDATA
*&---------------------------------------------------------------------*
FORM DISP_DM  TABLES   PT_CVDATA STRUCTURE GS_CVDATA.

  REFRESH GT_DM_INFO.

  LOOP AT PT_CVDATA INTO DATA(LS_CV_DATA).

    READ TABLE GT_GBN_PLAN INTO DATA(LS_GBN_PLAN) WITH KEY BDART = LS_CV_DATA-BDART.
    APPEND INITIAL LINE TO GT_DM_INFO ASSIGNING FIELD-SYMBOL(<LS_INPUT>).

    <LS_INPUT>-BDART = LS_CV_DATA-BDART.
    <LS_INPUT>-BDTXT = LS_GBN_PLAN-BDTXT.

    CASE LS_CV_DATA-BDART.
      WHEN 'D1'.
        <LS_INPUT>-ORDER = LS_CV_DATA-AUFNR.
      WHEN 'D2'.
        <LS_INPUT>-ORDER = LS_CV_DATA-PLNUM.
      WHEN 'D3'.
        <LS_INPUT>-ORDER = LS_CV_DATA-EBELN.
        <LS_INPUT>-ITMNO = LS_CV_DATA-EBELP.
      WHEN 'D4'.
        <LS_INPUT>-ORDER = LS_CV_DATA-BANFN.
        <LS_INPUT>-ITMNO = LS_CV_DATA-BNFPO.
      WHEN 'D5'.
        <LS_INPUT>-ORDER = LS_CV_DATA-PLNUM.
      WHEN 'D6'.
        <LS_INPUT>-ORDER = LS_CV_DATA-BANFN.
        <LS_INPUT>-ITMNO = LS_CV_DATA-BNFPO.
      WHEN 'D7'.
        <LS_INPUT>-ORDER = LS_CV_DATA-EBELN.
        <LS_INPUT>-ITMNO = LS_CV_DATA-EBELP.
    ENDCASE.
    <LS_INPUT>-BDTER = LS_CV_DATA-BDTER.
    <LS_INPUT>-DMQTY = LS_CV_DATA-DMQTY * -1.
    <LS_INPUT>-GIQTY = LS_CV_DATA-GIQTY * -1.
    <LS_INPUT>-RMQTY = LS_CV_DATA-RMQTY * -1.
    <LS_INPUT>-MEINS = LS_CV_DATA-MEINS.
    <LS_INPUT>-RSNUM = LS_CV_DATA-RSNUM.
    <LS_INPUT>-RSPOS = LS_CV_DATA-RSPOS.
  ENDLOOP.

  IF GT_DM_INFO[] IS NOT INITIAL.
    CALL SCREEN '0200' STARTING AT 5 5 ENDING AT 205 25.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_RS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_CVDATA
*&---------------------------------------------------------------------*
FORM DISP_RS  TABLES   PT_CVDATA STRUCTURE GS_CVDATA.

  DATA : BEGIN OF LS_CHK_EBAN,
           BANFN TYPE EBAN-BANFN,
           BNFPO TYPE EBAN-BNFPO,
         END OF LS_CHK_EBAN.
  DATA : LT_CHK_EBAN LIKE TABLE OF LS_CHK_EBAN.
  DATA : BEGIN OF LS_CHK_EKKO,
           EBELN TYPE EKKO-EBELN,
           EBELP TYPE EKPO-EBELP,
         END OF LS_CHK_EKKO.
  DATA : LT_CHK_EKKO LIKE TABLE OF LS_CHK_EKKO.
  REFRESH GT_RS_INFO.

  LT_CHK_EBAN = VALUE #( FOR WA_CVDATA IN PT_CVDATA[] WHERE ( ( BDART EQ 'R1'
                                                                                           OR  BDART EQ 'R3' )
                                                                                        AND  BANFN IS NOT INITIAL )
                                   ( BANFN = WA_CVDATA-BANFN BNFPO = WA_CVDATA-BNFPO ) ).

  LT_CHK_EKKO = VALUE #( FOR WA_CVDATA IN PT_CVDATA[] WHERE ( ( BDART EQ 'R2'
                                                                                           OR  BDART EQ 'R4' )
                                                                                        AND  EBELN IS NOT INITIAL )
                                   ( EBELN = WA_CVDATA-EBELN EBELP = WA_CVDATA-EBELP ) ).

* 세부정보 추출을 위한 데이터 조회
  SORT LT_CHK_EBAN BY BANFN BNFPO.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_EBAN COMPARING BANFN BNFPO.
  IF LT_CHK_EBAN[] IS NOT INITIAL.
    SELECT BANFN, BNFPO, LFDAT, MENGE, BSMNG, MEINS, LIFNR, FLIEF, LGORT
      FROM EBAN
        FOR ALL ENTRIES IN @LT_CHK_EBAN
     WHERE BANFN = @LT_CHK_EBAN-BANFN
        AND BNFPO = @LT_CHK_EBAN-BNFPO
        INTO TABLE @DATA(LT_EBAN).
  ENDIF.

  SORT LT_CHK_EKKO BY EBELN EBELP.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_EKKO COMPARING EBELN EBELP.
  IF LT_CHK_EKKO[] IS NOT INITIAL.
    SELECT B~EBELN, B~EBELP, C~EINDT, C~MENGE, C~WEMNG, B~MEINS, A~LIFNR, A~RESWK, B~LGORT
      FROM EKKO AS A
       INNER JOIN  EKPO AS B
                               ON B~EBELN = A~EBELN
       INNER JOIN  EKET AS C
                              ON C~EBELN = A~EBELN
                            AND C~EBELP = B~EBELP
      FOR ALL ENTRIES IN @LT_CHK_EKKO
     WHERE A~EBELN = @LT_CHK_EKKO-EBELN
        AND B~EBELP = @LT_CHK_EKKO-EBELP
      INTO TABLE @DATA(LT_EKKO).
  ENDIF.

  LOOP AT PT_CVDATA INTO DATA(LS_CV_DATA).

    READ TABLE GT_GBN_PLAN INTO DATA(LS_GBN_PLAN) WITH KEY BDART = LS_CV_DATA-BDART.
    APPEND INITIAL LINE TO GT_RS_INFO ASSIGNING FIELD-SYMBOL(<LS_INPUT>).

    <LS_INPUT>-BDART = LS_CV_DATA-BDART.
    <LS_INPUT>-BDTXT = LS_GBN_PLAN-BDTXT.

    CASE LS_CV_DATA-BDART.
      WHEN 'R1' OR 'R3'.
        READ TABLE LT_EBAN INTO DATA(LS_EBAN) WITH KEY BANFN = LS_CV_DATA-BANFN
                                                                                BNFPO = LS_CV_DATA-BNFPO.
        <LS_INPUT>-ORDER = LS_EBAN-BANFN.
        <LS_INPUT>-ITMNO = LS_EBAN-BNFPO.
        <LS_INPUT>-MENGE = LS_EBAN-MENGE.
        <LS_INPUT>-BSMNG = LS_EBAN-BSMNG.
        <LS_INPUT>-RSMNG = LS_EBAN-MENGE - LS_EBAN-BSMNG.
        <LS_INPUT>-MEINS = LS_EBAN-MEINS.
        <LS_INPUT>-LFDAT = LS_EBAN-LFDAT.
        <LS_INPUT>-LGORT = LS_EBAN-LGORT.
        IF LS_EBAN-LIFNR IS NOT INITIAL.
          <LS_INPUT>-LIFNR = LS_EBAN-LIFNR.
          SELECT SINGLE NAME1
            FROM LFA1
            WHERE LIFNR = @LS_EBAN-LIFNR
            INTO @<LS_INPUT>-LIFNRT.
        ELSE.
          <LS_INPUT>-LIFNR = LS_EBAN-FLIEF.
          SELECT SINGLE NAME1
            FROM LFA1
            WHERE LIFNR = @LS_EBAN-FLIEF
            INTO @<LS_INPUT>-LIFNRT.
        ENDIF.

      WHEN 'R2' OR 'R4'.
        READ TABLE LT_EKKO INTO DATA(LS_EKKO) WITH KEY EBELN = LS_CV_DATA-EBELN
                                                                                EBELP = LS_CV_DATA-EBELP.
        <LS_INPUT>-ORDER = LS_EKKO-EBELN.
        <LS_INPUT>-ITMNO = LS_EKKO-EBELP.
        <LS_INPUT>-MENGE = LS_EKKO-MENGE.
        <LS_INPUT>-BSMNG = LS_EKKO-WEMNG.
        <LS_INPUT>-RSMNG = LS_EKKO-MENGE - LS_EKKO-WEMNG.
        <LS_INPUT>-MEINS = LS_EKKO-MEINS.
        <LS_INPUT>-LFDAT = LS_EKKO-EINDT.
        <LS_INPUT>-LGORT = LS_EKKO-LGORT.

        IF LS_CV_DATA-BDART = 'R2'.
          <LS_INPUT>-LIFNR = LS_EKKO-LIFNR.
          SELECT SINGLE NAME1
            FROM LFA1
            WHERE LIFNR = @LS_EKKO-LIFNR
            INTO @<LS_INPUT>-LIFNRT.
        ELSEIF LS_CV_DATA-BDART = 'R4'.
          SELECT SINGLE NAME1
             FROM T001W
           WHERE WERKS = @LS_EKKO-RESWK
             INTO @<LS_INPUT>-LIFNRT.
        ENDIF.
    ENDCASE.

  ENDLOOP.

  IF GT_RS_INFO[] IS NOT INITIAL.
    CALL SCREEN '0300' STARTING AT 5 5 ENDING AT 205 25.
  ENDIF.

  PERFORM REFRESH_DATA.

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
*화면 분할
  CREATE OBJECT GO_SPLITTER_0200
    EXPORTING
      PARENT  = GO_DOCKING_0200
      ROWS    = 2
      COLUMNS = 1.

  GO_SPLITTER_0200->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    10 ).             " Height

* top 컨테이너
  CALL METHOD GO_SPLITTER_0200->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_TOP_0200.
* bottom 컨테이너
  CALL METHOD GO_SPLITTER_0200->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0200.


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
  GS_LAYOUT_0200-SEL_MODE   = 'C'.

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

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3120TOP'
      I_INTERNAL_TABNAME     = 'GS_DM_INFO'
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
      IT_DATA         = GT_DM_INFO
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0200 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'BDART'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    <LS_FCAT>-FIELDNAME = 'BDART'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획요소'.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '2'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0200 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'BDTXT'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'BDTXT'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획요소내역'.
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '20'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0200 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'ORDER'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ORDER'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'.
    <LS_FCAT>-COL_POS = 3.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '20'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0200 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'ITMNO'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ITMNO'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목번호'.
    <LS_FCAT>-COL_POS = 4.
    <LS_FCAT>-DATATYPE = 'NUMC'.
    <LS_FCAT>-DD_OUTLEN = '5'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  LOOP AT GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'BDART'.
        <LS_FCAT>-NO_OUT = 'X'.
      WHEN 'BDTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획요소내역'.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'ORDER'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-CONVEXIT = 'ALPHA'.
      WHEN 'ITMNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목번호'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'BDTER'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '소요일자'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'DMQTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '예정소요량'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = 'X'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'GIQTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '출고수량'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = 'X'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'RMQTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '잔여소요량'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = 'X'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'RSNUM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '예약번호'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'RSPOS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '예약품목'.
        <LS_FCAT>-JUST = 'C'.
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
      IT_OUTTAB            = GT_DM_INFO
      IT_SORT              = GT_SORT_0200
      IT_FIELDCATALOG      = GT_FIELDCAT_0200.

  IF GO_DD_DOCU_0200 IS BOUND.
    CALL METHOD GO_DD_DOCU_0200->INITIALIZE_DOCUMENT.
  ELSE.
    CREATE OBJECT GO_DD_DOCU_0200
      EXPORTING
        STYLE = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD GO_GRID_0200->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DD_DOCU_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PV_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM SET_TITLE_0200  CHANGING PV_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  DATA : LV_TEXT(255) TYPE C.

* 자재
  CLEAR LV_TEXT.
  LV_TEXT = GV_TITLE_MATNR.
  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

*-선택일자
  CLEAR: LV_TEXT.
  LV_TEXT = GV_TITLE_DATE.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

  "위쪽에 추가한 텍스트 출력
  CALL METHOD GO_DD_DOCU_0200->DISPLAY_DOCUMENT
    EXPORTING
      PARENT = GO_CONTAIN_TOP_0200.

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
      HEIGHT            =    10 ).             " Height

* top 컨테이너
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
  GS_LAYOUT_0300-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0300-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0300-NO_ROWMARK   = ABAP_TRUE.

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

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3120TOP'
      I_INTERNAL_TABNAME     = 'GS_RS_INFO'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0300.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0300[]
    TABLES
      IT_DATA         = GT_RS_INFO
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0300 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'BDART'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0300 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    <LS_FCAT>-FIELDNAME = 'BDART'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획요소'.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '2'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0300 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'BDTXT'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0300 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'BDTXT'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획요소내역'.
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '20'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0300 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'ORDER'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0300 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ORDER'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'.
    <LS_FCAT>-COL_POS = 3.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '20'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0300 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'ITMNO'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0300 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ITMNO'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목번호'.
    <LS_FCAT>-COL_POS = 4.
    <LS_FCAT>-DATATYPE = 'NUMC'.
    <LS_FCAT>-DD_OUTLEN = '5'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0300 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'LIFNR'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0300 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'LIFNR'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공급업체'.
    <LS_FCAT>-COL_POS = 10.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '20'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0300 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'LIFNRT'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0300 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'LIFNRT'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '업체내역'.
    <LS_FCAT>-COL_POS = 11.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '20'.
    <LS_FCAT>-JUST = 'L'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0300 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'RTMSG'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0300 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'RTMSG'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '메시지'.
    <LS_FCAT>-COL_POS = 13.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '100'.
    <LS_FCAT>-JUST = 'L'.
  ENDIF.

  LOOP AT GT_FIELDCAT_0300 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'BDART'.
        <LS_FCAT>-NO_OUT = 'X'.
      WHEN 'BDTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획요소내역'.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'ORDER'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-CONVEXIT = 'ALPHA'.
      WHEN 'ITMNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목번호'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'LFDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품일'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '발주수량'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = 'X'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'BSMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고수량'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = 'X'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'RSMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고예정수량'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = 'X'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Status'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'RTMSG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '메시지'.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'LGORT'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

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
      IT_OUTTAB            = GT_RS_INFO
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PV_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM SET_TITLE_0300  CHANGING PV_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  DATA : LV_TEXT(255) TYPE C.

* 자재
  CLEAR LV_TEXT.
  LV_TEXT = GV_TITLE_MATNR.
  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

*-선택일자
  CLEAR: LV_TEXT.
  LV_TEXT = GV_TITLE_DATE.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

  "위쪽에 추가한 텍스트 출력
  CALL METHOD GO_DD_DOCU_0300->DISPLAY_DOCUMENT
    EXPORTING
      PARENT = GO_CONTAIN_TOP_0300.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DEL_REQ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_SENDER
*&---------------------------------------------------------------------*
FORM PROC_DEL_REQ  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LT_RS_INFOR_CHK LIKE TABLE OF GS_RS_INFO.
  DATA : LV_NUMBER TYPE BAPIMEREQHEADER-PREQ_NO.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LT_PRITEM TYPE TABLE OF BAPIMEREQITEMIMP.
  DATA : LT_PRITEMX TYPE TABLE OF BAPIMEREQITEMX.

  CALL METHOD PO_SENDER->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  LOOP AT LT_ROW INTO LS_ROW.
    READ TABLE GT_RS_INFO INTO GS_RS_INFO INDEX LS_ROW-INDEX.
    IF SY-SUBRC EQ 0 AND ( GS_RS_INFO-BDART = 'R1' OR  GS_RS_INFO-BDART =  'R3' ).
      IF GS_RS_INFO-ID NE ICON_DELETE.
        APPEND GS_RS_INFO TO LT_RS_INFOR_CHK.
      ENDIF.
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E01.
      RETURN.
    ENDIF.
  ENDLOOP.

  CHECK LT_RS_INFOR_CHK[] IS NOT INITIAL.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 구매요청이 삭제 됩니다. 계속 진행 하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LOOP AT LT_RS_INFOR_CHK INTO DATA(LS_CHK).
    CLEAR LV_NUMBER.
    REFRESH : LT_RETURN, LT_PRITEM, LT_PRITEMX.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LS_CHK-ORDER
      IMPORTING
        OUTPUT = LV_NUMBER.

    APPEND INITIAL LINE TO LT_PRITEM ASSIGNING FIELD-SYMBOL(<LS_PRITEM>).
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LS_CHK-ITMNO
      IMPORTING
        OUTPUT = <LS_PRITEM>-PREQ_ITEM.
    <LS_PRITEM>-DELETE_IND = ABAP_TRUE.

    APPEND INITIAL LINE TO LT_PRITEMX ASSIGNING FIELD-SYMBOL(<LS_PRITEMX>).
    <LS_PRITEMX>-PREQ_ITEM = <LS_PRITEM>-PREQ_ITEM.
    <LS_PRITEMX>-PREQ_ITEMX = ABAP_TRUE.
    <LS_PRITEMX>-DELETE_IND = ABAP_TRUE.

    CALL FUNCTION 'BAPI_PR_CHANGE'
      EXPORTING
        NUMBER  = LV_NUMBER
*       TESTRUN = ABAP_TRUE " 테스트를 위한 플레그 이관시 삭제예정
      TABLES
        RETURN  = LT_RETURN
        PRITEM  = LT_PRITEM
        PRITEMX = LT_PRITEMX.

    IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ) .
      READ TABLE LT_RETURN INTO DATA(LS_RETURN) INDEX 1.
      LS_CHK-ID = ICON_LED_RED.
      LS_CHK-RTMSG = LS_RETURN-MESSAGE.
    ELSEIF LINE_EXISTS( LT_RETURN[ TYPE = 'A' ] ) .
      READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.
      LS_CHK-ID = ICON_LED_RED.
      LS_CHK-RTMSG = LS_RETURN-MESSAGE.
    ELSE.
      LS_CHK-ID = ICON_LED_GREEN.
      LS_CHK-RTMSG = TEXT-M10.
    ENDIF.


    IF LS_CHK-ID = ICON_LED_GREEN.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.
* 처리결과 로그테이블 저장 처리
      PERFORM SET_LOG_3260 USING 'D' LS_CHK.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
* 처리결과 로그테이블 저장 처리 없음(현재 성공건만 저장)
**      PERFORM SET_LOG_3260 USING 'D' LS_CHK.
    ENDIF.
    WAIT UP TO '0.5' SECONDS.

* 화면 처리결과 업데이트
    READ TABLE GT_RS_INFO ASSIGNING FIELD-SYMBOL(<LS_DISP>) WITH KEY BDART = LS_CHK-BDART
                                                                                                        ORDER = LS_CHK-ORDER
                                                                                                        ITMNO = LS_CHK-ITMNO.
    IF SY-SUBRC EQ 0.
      MOVE-CORRESPONDING LS_CHK TO <LS_DISP>.
    ENDIF.

  ENDLOOP.

  PERFORM REFRESH_GRID USING PO_SENDER.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DEL_ORD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_SENDER
*&---------------------------------------------------------------------*
FORM PROC_DEL_ORD  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LT_RS_INFOR_CHK LIKE TABLE OF GS_RS_INFO.
  DATA : LV_NUMBER TYPE BAPIMEPOHEADER-PO_NUMBER.
  DATA: LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA: LT_POITEM TYPE TABLE OF BAPIMEPOITEM.
  DATA: LT_POITEMX TYPE TABLE OF BAPIMEPOITEMX.
*  data : lt_3250 type TABLE of zgtppt3250.

  CALL METHOD PO_SENDER->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  LOOP AT LT_ROW INTO LS_ROW.
    READ TABLE GT_RS_INFO INTO GS_RS_INFO INDEX LS_ROW-INDEX.
    IF SY-SUBRC EQ 0 AND ( GS_RS_INFO-BDART = 'R2' OR  GS_RS_INFO-BDART =  'R4' ).
      IF GS_RS_INFO-ID NE ICON_DELETE.
        APPEND GS_RS_INFO TO LT_RS_INFOR_CHK.
      ENDIF.
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E02.
      RETURN.
    ENDIF.
  ENDLOOP.

  CHECK LT_RS_INFOR_CHK[] IS NOT INITIAL.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 구매오더가 삭제 됩니다. 계속 진행 하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LOOP AT LT_RS_INFOR_CHK INTO DATA(LS_CHK).
    CLEAR LV_NUMBER.
    REFRESH : LT_RETURN, LT_POITEM, LT_POITEMX.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LS_CHK-ORDER
      IMPORTING
        OUTPUT = LV_NUMBER.

    APPEND INITIAL LINE TO LT_POITEM ASSIGNING FIELD-SYMBOL(<LS_POITEM>).
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LS_CHK-ITMNO
      IMPORTING
        OUTPUT = <LS_POITEM>-PO_ITEM.
    <LS_POITEM>-DELETE_IND = ABAP_TRUE.

    APPEND INITIAL LINE TO LT_POITEMX ASSIGNING FIELD-SYMBOL(<LS_POITEMX>).
    <LS_POITEMX>-PO_ITEM = <LS_POITEM>-PO_ITEM.
    <LS_POITEMX>-PO_ITEMX = ABAP_TRUE.
    <LS_POITEMX>-DELETE_IND = ABAP_TRUE.

    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        PURCHASEORDER = LV_NUMBER
*       TESTRUN       = ABAP_TRUE
      TABLES
        RETURN        = LT_RETURN
        POITEM        = LT_POITEM
        POITEMX       = LT_POITEMX.

    IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ) .
      READ TABLE LT_RETURN INTO DATA(LS_RETURN) INDEX 1.
      LS_CHK-ID = ICON_LED_RED.
      LS_CHK-RTMSG = LS_RETURN-MESSAGE.
    ELSEIF LINE_EXISTS( LT_RETURN[ TYPE = 'A' ] ) .
      READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.
      LS_CHK-ID = ICON_LED_RED.
      LS_CHK-RTMSG = LS_RETURN-MESSAGE.
    ELSE.
      LS_CHK-ID = ICON_LED_GREEN.
      LS_CHK-RTMSG = TEXT-M10.
    ENDIF.


    IF LS_CHK-ID = ICON_LED_GREEN.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ENDIF.
    WAIT UP TO '0.5' SECONDS.

* 처리결과 로그테이블 저장 처리 (현재 로그테이블 없음)
    PERFORM SET_LOG_3260 USING 'D' LS_CHK.

* 화면 처리결과 업데이트
    READ TABLE GT_RS_INFO ASSIGNING FIELD-SYMBOL(<LS_DISP>) WITH KEY BDART = LS_CHK-BDART
                                                                                                  ORDER = LS_CHK-ORDER
                                                                                                  ITMNO = LS_CHK-ITMNO.
    IF SY-SUBRC EQ 0.
      MOVE-CORRESPONDING LS_CHK TO <LS_DISP>.
    ENDIF.

  ENDLOOP.

  PERFORM REFRESH_GRID USING PO_SENDER.

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
*& Form SET_LOG_3260
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> LS_CHK
*&---------------------------------------------------------------------*
FORM SET_LOG_3260  USING    PV_GUPUN
                                           PS_CHK LIKE GS_RS_INFO.

  DATA : LS_3260 TYPE ZGTPPT3260.

  GET TIME STAMP FIELD LS_3260-TIMESTAMPL.
  CASE PS_CHK-BDART.
    WHEN 'R1' OR 'R3'.
      LS_3260-BANFN = PS_CHK-ORDER.
      LS_3260-BNFPO = PS_CHK-ITMNO + 0.
    WHEN 'R2' OR 'R4'.
      LS_3260-EBELN = PS_CHK-ORDER.
      LS_3260-EBELP = PS_CHK-ITMNO + 0.
  ENDCASE.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT  = GV_MATNR
    IMPORTING
      OUTPUT = LS_3260-MATNR.

  LS_3260-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = GV_MATNR ).
  LS_3260-WERKS = P_WERKS.
  LS_3260-MENGE = PS_CHK-MENGE.
  LS_3260-MEINS = PS_CHK-MEINS.
  LS_3260-EINDT = PS_CHK-LFDAT.
  LS_3260-LGORT = PS_CHK-LGORT.

  IF PV_GUPUN = 'D'.
    LS_3260-LOEKZ = ABAP_TRUE.
  ENDIF.

  MOVE : SY-UNAME TO LS_3260-CRNAM,
            SY-DATUM TO LS_3260-CRDAT,
            SY-UZEIT TO LS_3260-CRTIM,
            SY-UNAME TO LS_3260-CHNAM,
            SY-DATUM TO LS_3260-CHDAT,
            SY-UZEIT TO LS_3260-CHTIM.

  MODIFY ZGTPPT3260 FROM LS_3260.
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CREATE_REQ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_SENDER
*&---------------------------------------------------------------------*
FORM PROC_CREATE_REQ  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_DATE_CHK TYPE SY-DATUM.
  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_FIELDNAME2 TYPE FIELDNAME.
  DATA : LV_POSNR(5) TYPE N.
  DATA : LV_UNIT TYPE ZGTMMT4210-PSTOCK.
  DATA : LV_LIFNR TYPE LIFNR.

  FIELD-SYMBOLS <LV_FIELD> TYPE ANY.
  FIELD-SYMBOLS <LV_FIELD2> TYPE ANY.

  DEFINE __ASSIGN_FIELD.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = &1.
    IF <LV_FIELD> IS ASSIGNED. UNASSIGN <LV_FIELD>. ENDIF.
    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_FIELD>.
  END-OF-DEFINITION.

  DEFINE __ASSIGN_FIELD2.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = &1.
    IF <LV_FIELD2> IS ASSIGNED. UNASSIGN <LV_FIELD2>. ENDIF.
    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN2> TO <LV_FIELD2>.
  END-OF-DEFINITION.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      IF P_CD = ABAP_TRUE.
        PO_SENDER->GET_SELECTED_CELLS_ID(
            IMPORTING
             ET_CELLS = LT_CELLS ).                " Cell IDs
      ELSE.
        RETURN.
      ENDIF.
    WHEN OTHERS.
      RETURN.
  ENDCASE.

  REFRESH GT_DISP_400.
  CLEAR LV_POSNR.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).

    READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_CELLS-ROW_ID.
    __ASSIGN_FIELD 'GBNCD'.
    IF <LV_FIELD> NE 'Z2'.
      CONTINUE.
    ENDIF.

    READ TABLE GT_FIELDCAT_0100 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.
      IF LS_FCAT-FIELDNAME = 'DUEDATE'.
        __ASSIGN_FIELD 'DUEDATE'.
        IF <LV_FIELD> IS INITIAL.
          CONTINUE.
        ENDIF.

        APPEND INITIAL LINE TO GT_DISP_400 ASSIGNING FIELD-SYMBOL(<LS_DISP>).

*      순번
        ADD 10 TO LV_POSNR.
        <LS_DISP>-BNFPO = LV_POSNR.
*      자재, 자재내역
        __ASSIGN_FIELD 'MATNR'.
        <LS_DISP>-MATNR = <LV_FIELD>.
        <LS_DISP>-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = <LS_DISP>-MATNR ).

*      납품일
        LOOP AT <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN2>).
          __ASSIGN_FIELD2 'MATNR'.
          IF <LV_FIELD2> = <LS_DISP>-MATNR.
            __ASSIGN_FIELD2 'GBNCD'.
            IF <LV_FIELD2> = 'Z1'.
              READ TABLE GR_DATE INDEX 1.
              LV_DATE = GR_DATE-LOW.
              DO .
                CLEAR LV_FIELDNAME2.
                LV_FIELDNAME2 = LV_DATE && '_CHK'.
                __ASSIGN_FIELD2 LV_FIELDNAME2.
                IF <LV_FIELD2> = ABAP_TRUE.
                  <LS_DISP>-LFDAT = LV_DATE.
                  EXIT.
                ENDIF.

                IF GR_DATE-HIGH = LV_DATE.
                  EXIT.
                ENDIF.

                LV_DATE = LV_DATE + 1.
              ENDDO.

            ENDIF.
          ENDIF.
        ENDLOOP.


*      요청수량 - 구매제안 수량은 전부 +
        __ASSIGN_FIELD 'DUEDATE'.
        REPLACE ALL OCCURRENCES OF ',' IN <LV_FIELD> WITH ''.
        REPLACE ALL OCCURRENCES OF '-' IN <LV_FIELD> WITH ''.
        CONDENSE <LV_FIELD>.
        LV_UNIT = <LV_FIELD>.

        <LS_DISP>-MENGE = LV_UNIT.
*      단위
        __ASSIGN_FIELD 'MEINS'.
        <LS_DISP>-MEINS = <LV_FIELD>.
*      플랜트
        <LS_DISP>-WERKS = P_WERKS.
*      저장소
        PERFORM GET_LGORT USING <LS_DISP>-MATNR CHANGING <LS_DISP>-LGORT.

      ELSE.
        LV_DATE_CHK = LS_FCAT-FIELDNAME.
        IF LV_DATE_CHK NOT IN GR_DATE.
          CONTINUE.
        ENDIF.

        __ASSIGN_FIELD LV_DATE_CHK.
        IF <LV_FIELD> IS INITIAL OR <LV_FIELD> = '0'.
          CONTINUE.
        ENDIF.


        APPEND INITIAL LINE TO GT_DISP_400 ASSIGNING <LS_DISP>.
*      순번
        ADD 10 TO LV_POSNR.
        <LS_DISP>-BNFPO = LV_POSNR.
*      자재, 자재내역
        __ASSIGN_FIELD 'MATNR'.
        <LS_DISP>-MATNR = <LV_FIELD>.
        <LS_DISP>-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = <LS_DISP>-MATNR ).

*      납품일
        __ASSIGN_FIELD 'PLIFZ'.
        <LS_DISP>-LFDAT = LV_DATE_CHK + <LV_FIELD>.

*      요청수량 - 구매제안 수량은 전부 -
        __ASSIGN_FIELD LV_DATE_CHK.
        REPLACE ALL OCCURRENCES OF ',' IN <LV_FIELD> WITH ''.
        REPLACE ALL OCCURRENCES OF '-' IN <LV_FIELD> WITH ''.
        CONDENSE <LV_FIELD>.
        LV_UNIT = <LV_FIELD>.

        <LS_DISP>-MENGE = LV_UNIT.
*      단위
        __ASSIGN_FIELD 'MEINS'.
        <LS_DISP>-MEINS = <LV_FIELD>.
*      플랜트
        <LS_DISP>-WERKS = P_WERKS.
*      저장소
        PERFORM GET_LGORT USING <LS_DISP>-MATNR CHANGING <LS_DISP>-LGORT.

      ENDIF.
    ENDIF.
  ENDLOOP.

*  헤더세팅
  CLEAR GS_REQ_DISP.
*  구매요청유형
  GS_REQ_DISP-BSART = 'NB'. " 디폴드값 세팅
  GS_REQ_DISP-BSTYP = 'B'. " 디폴드값 세팅

  READ TABLE GT_MASTER_EKORG INTO DATA(LS_EKORG) INDEX 1.
  GS_REQ_DISP-EKORG = LS_EKORG-EKORG.
  GS_REQ_DISP-EKOTX = LS_EKORG-EKOTX.

*  구매요청유형 Text
  PERFORM GET_TEXT_BSART USING GS_REQ_DISP-BSART 'B' CHANGING GS_REQ_DISP-BATXT.
*  구매요청유형 Text
  PERFORM GET_TEXT_FLIEF USING GS_REQ_DISP-FLIEF CHANGING GS_REQ_DISP-NAME1.

** 요청자
  PERFORM GET_USER_NAME CHANGING GS_REQ_DISP-AFNAM.



  CLEAR GV_MODE.

  IF GT_DISP_400[] IS INITIAL.
    GV_MODE = ABAP_TRUE. " 조회된 데이터가 없으면 변경모드로 적용
  ENDIF.

  CALL SCREEN '0400' STARTING AT 5 5 ENDING AT 135 25.


  PERFORM REFRESH_DATA..

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

  CREATE OBJECT GO_CONTAIN_0400
    EXPORTING
      CONTAINER_NAME              = 'GV_CONTAIN_0400'                " Name of the Screen CustCtrl Name to Link Container To
    EXCEPTIONS
      CNTL_ERROR                  = 1                " CNTL_ERROR
      CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
      CREATE_ERROR                = 3                " CREATE_ERROR
      LIFETIME_ERROR              = 4                " LIFETIME_ERROR
      LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.


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
*  GS_LAYOUT_0400-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0400-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0400-NO_ROWMARK   = ABAP_TRUE.
  GS_LAYOUT_0400-STYLEFNAME = 'CELLTAB'.

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

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3120TOP'
      I_INTERNAL_TABNAME     = 'GS_DISP_400'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0400.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0400[]
    TABLES
      IT_DATA         = GT_DISP_400
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0400 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'MESSAGE'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0400 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    <LS_FCAT>-FIELDNAME = 'MESSAGE'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '메시지'.
    <LS_FCAT>-COL_POS = 12.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '100'.
  ENDIF.

  LOOP AT GT_FIELDCAT_0400 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'BNFPO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목번호'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재코드'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-OUTPUTLEN = 12.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재내역'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'LFDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품일'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '요청수량'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = 'X'.
        <LS_FCAT>-QUANTITY = 'MEINS'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '저장위치'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'STATUS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '상태'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PREQ_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매요청번호'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'BNFPO2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매요청품목'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_ZERO = ABAP_TRUE.
      WHEN 'MESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '메시지'.
        <LS_FCAT>-JUST = 'L'.
    ENDCASE.
  ENDLOOP.

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

  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

  DEFINE __SET_STYLE.
    CLEAR LS_CELLTAB.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = &1.
    LS_CELLTAB-FIELDNAME = LV_FIELDNAME.
    LS_CELLTAB-STYLE = CONV #( &2 ).
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  END-OF-DEFINITION.

  LOOP AT GT_DISP_400 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    REFRESH LT_CELLTAB.

    __SET_STYLE : 'STATUS' ALV_STYLE_COLOR_POSITIVE,
                          'PREQ_NO' ALV_STYLE_COLOR_POSITIVE,
                          'BNFPO2' ALV_STYLE_COLOR_POSITIVE,
                          'MESSAGE' ALV_STYLE_COLOR_POSITIVE.
    IF GV_MODE = ABAP_TRUE.
      __SET_STYLE : 'MATNR' ALV_STYLE_ENABLED.
      __SET_STYLE : 'LFDAT' ALV_STYLE_ENABLED.
      __SET_STYLE : 'MENGE' ALV_STYLE_ENABLED.
      __SET_STYLE : 'MEINS' ALV_STYLE_ENABLED.
      __SET_STYLE : 'LGORT' ALV_STYLE_ENABLED.
    ELSE.
      __SET_STYLE : 'LFDAT' ALV_STYLE_ENABLED.
      __SET_STYLE : 'MENGE' ALV_STYLE_ENABLED.
      __SET_STYLE : 'MEINS' ALV_STYLE_ENABLED.
      __SET_STYLE : 'LGORT' ALV_STYLE_ENABLED.
    ENDIF.

    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.
  ENDLOOP.

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
      IT_OUTTAB            = GT_DISP_400
      IT_FIELDCATALOG      = GT_FIELDCAT_0400.

  GO_GRID_0400->SET_READY_FOR_INPUT( 1 ).

  CALL METHOD GO_GRID_0400->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0400->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

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

  DATA : LS_MTART_RANGE LIKE LINE OF GR_MTART.

  DEFINE __SET_AVAILABLE_MTART.
    CLEAR LS_MTART_RANGE.
    LS_MTART_RANGE-SIGN = 'I'.
    LS_MTART_RANGE-OPTION = 'EQ'.
    LS_MTART_RANGE-LOW = &1.
    COLLECT LS_MTART_RANGE INTO GR_MTART.
  END-OF-DEFINITION.

  IF GR_MTART[] IS INITIAL.
    __SET_AVAILABLE_MTART : 'HALB', 'ROH1', 'ROH2', 'MCRO', 'MRM1', 'MRM2', 'MRM3'.
  ENDIF.

  MOVE-CORRESPONDING GR_MTART[] TO S_MTART[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TEXT_BSART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_REQ_DISP_BSART
*&      --> P_
*&      <-- GS_REQ_DISP_BATXT
*&---------------------------------------------------------------------*
FORM GET_TEXT_BSART  USING    PV_BSART
                                               PV_BSTYP
                              CHANGING    PV_BATXT.

  SELECT SINGLE BATXT FROM T161T
      INTO PV_BATXT
   WHERE BSART = PV_BSART
       AND BSTYP = PV_BSTYP
       AND SPRAS = SY-LANGU.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_USER_NAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_REQ_DISP_AFNAM
*&---------------------------------------------------------------------*
FORM GET_USER_NAME  CHANGING PV_AFNAM.

  DATA : LS_USER_ADDR  TYPE USER_ADDR.

  CALL FUNCTION 'FKK_GET_USER_NAME'
    EXPORTING
      I_UNAME     = SY-UNAME
    IMPORTING
      E_USER_ADDR = LS_USER_ADDR.
  IF LS_USER_ADDR IS NOT INITIAL.
    PV_AFNAM = LS_USER_ADDR-NAME_TEXTC.
  ENDIF.
  .


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_lgort
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_DISP>_MATNR
*&      <-- <LS_DISP>_LGORT
*&---------------------------------------------------------------------*
FORM GET_LGORT  USING    PV_MATNR TYPE MATNR
                      CHANGING    PV_LGORT TYPE LGORT_D.

  SELECT SINGLE LGFSB FROM MARC
    INTO PV_LGORT
   WHERE WERKS = P_WERKS
       AND MATNR = PV_MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_LINE_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_SENDER
*&---------------------------------------------------------------------*
FORM ADD_LINE_0400  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LV_POSNR(5) TYPE N.
  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  DATA : LV_FIELDNAME TYPE FIELDNAME.

  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

  DEFINE __SET_STYLE.
    CLEAR LS_CELLTAB.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = &1.
    LS_CELLTAB-FIELDNAME = LV_FIELDNAME.
    LS_CELLTAB-STYLE = CONV #( &2 ).
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  END-OF-DEFINITION.

  LV_POSNR = LINES( GT_DISP_400 ) + 1.
  LV_POSNR = LV_POSNR * 10.

  APPEND INITIAL LINE TO GT_DISP_400 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

* 초기값 세팅
*  순번
  <LS_MAIN>-BNFPO = LV_POSNR.
  <LS_MAIN>-WERKS = P_WERKS.
* 스타일 세팅
  REFRESH LT_CELLTAB.

  __SET_STYLE : 'STATUS' ALV_STYLE_COLOR_POSITIVE,
                        'PREQ_NO' ALV_STYLE_COLOR_POSITIVE,
                        'BNFPO2' ALV_STYLE_COLOR_POSITIVE,
                        'MESSAGE' ALV_STYLE_COLOR_POSITIVE.

  __SET_STYLE : 'MATNR' ALV_STYLE_ENABLED.
  __SET_STYLE : 'LFDAT' ALV_STYLE_ENABLED.
  __SET_STYLE : 'MENGE' ALV_STYLE_ENABLED.
  __SET_STYLE : 'MEINS' ALV_STYLE_ENABLED.
  __SET_STYLE : 'LGORT' ALV_STYLE_ENABLED.

  IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
  ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
  IF <LT_CELLTAB> IS ASSIGNED.
    <LT_CELLTAB> = LT_CELLTAB.
  ENDIF.

  PERFORM REFRESH_GRID USING PO_SENDER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_LINE_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_SENDER
*&---------------------------------------------------------------------*
FORM DELETE_LINE_0400  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LV_POSNR(5) TYPE N.
  DATA : LV_TABIX TYPE I..

  CALL METHOD PO_SENDER->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  IF LT_ROW[] IS NOT INITIAL. " 선택열 삭제
    SORT LT_ROW BY INDEX DESCENDING. " 삭제시 순차삭제를 위해 역순 소트
    LOOP AT LT_ROW INTO LS_ROW.
      DELETE GT_DISP_400 INDEX LS_ROW-INDEX.
    ENDLOOP.

*  순재 재세팅
    LOOP AT GT_DISP_400 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
      ADD 10 TO LV_POSNR.
      <LS_MAIN>-BNFPO = LV_POSNR.
    ENDLOOP.
  ELSE. " 마지막라인 삭제
    LV_TABIX = LINES( GT_DISP_400 ) .
    DELETE GT_DISP_400 INDEX LV_TABIX.
  ENDIF.

  PERFORM REFRESH_GRID USING PO_SENDER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CREATE_REQ_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_SENDER
*&---------------------------------------------------------------------*
FORM PROC_CREATE_REQ_0400  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LV_ERR.
  DATA : LS_PRHEADER TYPE BAPIMEREQHEADER.
  DATA : LS_PRHEADERX TYPE BAPIMEREQHEADERX.
  DATA : LS_PRHEADEREXP TYPE BAPIMEREQHEADER.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LT_PRITEM TYPE TABLE OF BAPIMEREQITEMIMP.
  DATA : LT_PRITEMX TYPE  TABLE OF BAPIMEREQITEMX.
  DATA : LT_DISP_MESSAGE TYPE TABLE OF ZTESMESSAGE.
  DATA : LV_SEQ(6) TYPE N.

  PERFORM CHECK_REQ CHANGING LV_ERR. "구매요청 생성전 점검

  IF LV_ERR EQ ABAP_TRUE.
    RETURN.
  ENDIF.

  CHECK GT_DISP_400[] IS NOT INITIAL.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '해당 정보로 구매요청이 생성됩니다. 진행하시겠습니까?'
    '생성확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

* Bapi 정보 구성
  LS_PRHEADER-PR_TYPE = GS_REQ_DISP-BSART.
  LS_PRHEADERX-PR_TYPE = ABAP_TRUE.

  LOOP AT GT_DISP_400 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    APPEND INITIAL LINE TO LT_PRITEM ASSIGNING FIELD-SYMBOL(<LS_PRITEM>).
    <LS_PRITEM>-PREQ_ITEM = <LS_MAIN>-BNFPO.
    <LS_PRITEM>-PREQ_NAME = GS_REQ_DISP-AFNAM.
    <LS_PRITEM>-MATERIAL = <LS_MAIN>-MATNR.
    <LS_PRITEM>-PLANT = <LS_MAIN>-WERKS.
    <LS_PRITEM>-STORE_LOC = <LS_MAIN>-LGORT.
    <LS_PRITEM>-QUANTITY = <LS_MAIN>-MENGE.
    <LS_PRITEM>-UNIT = <LS_MAIN>-MEINS.
    <LS_PRITEM>-PURCH_ORG = GS_REQ_DISP-EKORG.
    <LS_PRITEM>-DELIV_DATE = <LS_MAIN>-LFDAT.
    CASE GS_REQ_DISP-CHECK.
      WHEN ''.
        <LS_PRITEM>-FIXED_VEND = GS_REQ_DISP-FLIEF.
      WHEN ABAP_TRUE.
        <LS_PRITEM>-SUPPL_PLNT = GS_REQ_DISP-RESWK.
        <LS_PRITEM>-ITEM_CAT = '7'.
    ENDCASE.

    APPEND INITIAL LINE TO LT_PRITEMX ASSIGNING FIELD-SYMBOL(<LS_PRITEMX>).
    <LS_PRITEMX>-PREQ_ITEM = <LS_MAIN>-BNFPO.
    <LS_PRITEMX>-PREQ_ITEMX = ABAP_TRUE.
    <LS_PRITEMX>-PREQ_NAME = ABAP_TRUE.
    <LS_PRITEMX>-MATERIAL = ABAP_TRUE.
    <LS_PRITEMX>-PLANT = ABAP_TRUE.
    <LS_PRITEMX>-STORE_LOC = ABAP_TRUE.
    <LS_PRITEMX>-QUANTITY = ABAP_TRUE.
    <LS_PRITEMX>-UNIT = ABAP_TRUE.
    <LS_PRITEMX>-PURCH_ORG = ABAP_TRUE.
    <LS_PRITEMX>-DELIV_DATE = ABAP_TRUE.
    CASE GS_REQ_DISP-CHECK.
      WHEN ''.
        <LS_PRITEMX>-FIXED_VEND = ABAP_TRUE.
      WHEN ABAP_TRUE.
        <LS_PRITEMX>-SUPPL_PLNT = ABAP_TRUE.
        <LS_PRITEMX>-ITEM_CAT = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

* Bapi 실행
  CALL FUNCTION 'BAPI_PR_CREATE'
    EXPORTING
      PRHEADER    = LS_PRHEADER
      PRHEADERX   = LS_PRHEADERX
    IMPORTING
      PRHEADEREXP = LS_PRHEADEREXP
    TABLES
      RETURN      = LT_RETURN
      PRITEM      = LT_PRITEM
      PRITEMX     = LT_PRITEMX.

  READ TABLE LT_RETURN INTO DATA(LS_RETURN) WITH KEY TYPE = 'E'.
  IF SY-SUBRC EQ 0. " 에러건 존재시

    LOOP AT GT_DISP_400 ASSIGNING <LS_MAIN>.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      IF LS_RETURN-MESSAGE IS NOT INITIAL.
        <LS_MAIN>-MESSAGE = LS_RETURN-MESSAGE.
      ELSE.
        MESSAGE ID LS_RETURN-ID TYPE 'S'  NUMBER LS_RETURN-NUMBER INTO <LS_MAIN>-MESSAGE .
      ENDIF.
    ENDLOOP.

    REFRESH LT_DISP_MESSAGE.
    CLEAR LV_SEQ.
    LOOP AT LT_RETURN INTO LS_RETURN.
      APPEND INITIAL LINE TO LT_DISP_MESSAGE ASSIGNING FIELD-SYMBOL(<LS_DISP_MESSAGE>).
      ADD 1 TO LV_SEQ.
      <LS_DISP_MESSAGE>-MSGSQ = LV_SEQ .
      <LS_DISP_MESSAGE>-MSGID = LS_RETURN-ID.
      <LS_DISP_MESSAGE>-MSGNO = LS_RETURN-NUMBER..
      <LS_DISP_MESSAGE>-MSGTY = LS_RETURN-TYPE.
      <LS_DISP_MESSAGE>-MSGV1 = LS_RETURN-MESSAGE_V1.
      <LS_DISP_MESSAGE>-MSGV2 = LS_RETURN-MESSAGE_V2.
      <LS_DISP_MESSAGE>-MSGV3 = LS_RETURN-MESSAGE_V3.
      <LS_DISP_MESSAGE>-MSGV4 = LS_RETURN-MESSAGE_V4.
      <LS_DISP_MESSAGE>-MSGTX = LS_RETURN-MESSAGE.
    ENDLOOP.

    CALL FUNCTION 'Z_TE_POPUP_TO_ERROR_MESSAGE'
      TABLES
        XMSG = LT_DISP_MESSAGE.

  ELSE. " 성공시
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    LOOP AT GT_DISP_400 ASSIGNING <LS_MAIN>.
      <LS_MAIN>-STATUS = ICON_LED_GREEN.
      <LS_MAIN>-PREQ_NO = LS_PRHEADEREXP-PREQ_NO.
      <LS_MAIN>-BNFPO2 = <LS_MAIN>-BNFPO.
      <LS_MAIN>-MESSAGE = TEXT-M11.

      PERFORM SET_LOG_CREATE_REQ USING <LS_MAIN>.
    ENDLOOP.

    GV_MODE = 'C'.

  ENDIF.



  PERFORM REFRESH_GRID USING PO_SENDER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_REQ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ERR
*&---------------------------------------------------------------------*
FORM CHECK_REQ  CHANGING PV_ERR.

* 구매요청 유형
  IF GS_REQ_DISP-BSART IS NOT INITIAL.
    SELECT SINGLE BSART FROM T161T
      INTO @DATA(LV_BSART)
      WHERE BSTYP = 'B'
         AND BSART = @GS_REQ_DISP-BSART .
    IF SY-SUBRC NE 0.
      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E03 TEXT-E05 TEXT-E04.
      PV_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

  ELSE.
    PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E05 TEXT-E08 ' '.
    PV_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

* 구매조직
  IF GS_REQ_DISP-EKORG IS NOT INITIAL.
    READ TABLE GT_MASTER_EKORG INTO DATA(LS_EKORG) WITH KEY EKORG = GS_REQ_DISP-EKORG.
    IF SY-SUBRC NE 0.
      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E03 TEXT-E06 TEXT-E04.
      PV_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

  ELSE.
    PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E06 TEXT-E08 ' '.
    PV_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

* 공급업체
  CASE GS_REQ_DISP-CHECK.
    WHEN ' '. " 재고 이전요청 체크 아닐시 공급업체 유효성
      IF GS_REQ_DISP-FLIEF IS NOT INITIAL.
        SELECT SINGLE  NAME1
           FROM LFA1
             INTO @DATA(NAME1)
           WHERE LIFNR = @GS_REQ_DISP-FLIEF.
        IF SY-SUBRC NE 0.
          PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E03 TEXT-E07 TEXT-E04.
          PV_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.

      ELSE.
        PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E07 TEXT-E08 ' '.
        PV_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    WHEN ABAP_TRUE. " 재고 이전요청 체크시 공급플랜트 유효성
      IF GS_REQ_DISP-RESWK IS NOT INITIAL.
        SELECT SINGLE  NAME1
           FROM T001W
             INTO @DATA(WNAME1)
           WHERE WERKS = @GS_REQ_DISP-RESWK.
        IF SY-SUBRC NE 0.
          PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E03 TEXT-E17 TEXT-E04.
          PV_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.

      ELSE.
        PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E17 TEXT-E08 ' '.
        PV_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
  ENDCASE.


  IF GS_REQ_DISP-AFNAM IS INITIAL.
    PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E09 TEXT-E08 ' '.
    PV_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT GT_DISP_400 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

*   플랜트
    IF <LS_MAIN>-WERKS IS INITIAL.
      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-013 TEXT-E08 ' '.
      PV_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
*    자재코드
    IF <LS_MAIN>-MATNR IS NOT INITIAL.
      SELECT SINGLE MATNR FROM MARC
        INTO @DATA(LV_MATNR)
        WHERE MATNR = @<LS_MAIN>-MATNR
           AND WERKS = @<LS_MAIN>-WERKS.
      IF SY-SUBRC NE 0.
        PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E03 TEXT-002 TEXT-E04.
        PV_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ELSE.
      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-002 TEXT-E08 ' '.
      PV_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

*  소요일자
    IF <LS_MAIN>-LFDAT IS INITIAL OR <LS_MAIN>-LFDAT = '00000000'.
      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E10 TEXT-E08 ' '.
      PV_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

* 요청수량
    IF <LS_MAIN>-MENGE = 0.
      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E11 TEXT-E08 ' '.
      PV_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

* 단위
    IF <LS_MAIN>-MEINS IS INITIAL.
      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E12 TEXT-E08 ' '.
      PV_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

* 저장위치
    IF <LS_MAIN>-LGORT IS INITIAL.
      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E13 TEXT-E08 ' '.
      PV_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TEXT_FLIEF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_REQ_DISP_FLIEF
*&      <-- GS_REQ_DISP_NAME1
*&---------------------------------------------------------------------*
FORM GET_TEXT_FLIEF  USING    PV_FLIEF TYPE LIFNR
                            CHANGING    PV_NAME1.

  SELECT SINGLE NAME1 FROM LFA1
    INTO PV_NAME1
   WHERE LIFNR = PV_FLIEF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LOG_CREATE_REQ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_MAIN
*&---------------------------------------------------------------------*
FORM SET_LOG_CREATE_REQ  USING    PS_MAIN LIKE GS_DISP_400.

  DATA : LS_3260 TYPE ZGTPPT3260.

  GET TIME STAMP FIELD LS_3260-TIMESTAMPL.

  LS_3260-BANFN = PS_MAIN-PREQ_NO.
  LS_3260-BNFPO = PS_MAIN-BNFPO2 + 0.

  LS_3260-MATNR = PS_MAIN-MATNR.
  LS_3260-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = PS_MAIN-MATNR ).
  LS_3260-WERKS = PS_MAIN-WERKS.
  LS_3260-MENGE = PS_MAIN-MENGE.
  LS_3260-MEINS = PS_MAIN-MEINS.
  LS_3260-EINDT = PS_MAIN-LFDAT.
  LS_3260-LGORT = PS_MAIN-LGORT.

  MOVE : SY-UNAME TO LS_3260-CRNAM,
            SY-DATUM TO LS_3260-CRDAT,
            SY-UZEIT TO LS_3260-CRTIM,
            SY-UNAME TO LS_3260-CHNAM,
            SY-DATUM TO LS_3260-CHDAT,
            SY-UZEIT TO LS_3260-CHTIM.

  MODIFY ZGTPPT3260 FROM LS_3260.
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0500 OUTPUT.

  IF GO_GRID_0500 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0500.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0500.
    PERFORM SET_LAYOUT_GRID_0500.
    PERFORM SET_FIELDCAT_GRID_0500.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0500.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0500.
    PERFORM CALL_GRID_0500_DISPLAY.
  ENDIF.

ENDMODULE.
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
      CONTAINER_NAME              = 'GV_CONTAIN_0500'                " Name of the Screen CustCtrl Name to Link Container To
    EXCEPTIONS
      CNTL_ERROR                  = 1                " CNTL_ERROR
      CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
      CREATE_ERROR                = 3                " CREATE_ERROR
      LIFETIME_ERROR              = 4                " LIFETIME_ERROR
      LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.


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
*  GS_LAYOUT_0500-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0500-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0500-SEL_MODE   = 'D'.
  GS_LAYOUT_0500-STYLEFNAME = 'CELLTAB'.

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
      I_INCLNAME             = 'ZGTPPR3120TOP'
      I_INTERNAL_TABNAME     = 'GS_DISP_500'
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
      IT_DATA         = GT_DISP_500
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0500 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'MESSAGE'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0500 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    <LS_FCAT>-FIELDNAME = 'MESSAGE'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '메시지'.
    <LS_FCAT>-COL_POS = 14.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '100'.
  ENDIF.

  LOOP AT GT_FIELDCAT_0500 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'BNFPO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목번호'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재코드'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-OUTPUTLEN = 12.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재내역'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-COL_OPT = ABAP_TRUE.
      WHEN 'LFDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품일'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '요청수량'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = 'X'.
        <LS_FCAT>-QUANTITY = 'MEINS'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '저장위치'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'STATUS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '상태'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PREQ_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매요청번호'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'BNFPO2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매요청품목'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_ZERO = ABAP_TRUE.
      WHEN 'MESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '메시지'.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'EBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매오더번호'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'EBELP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매오더품목'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_ZERO = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0500 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  DATA : LV_FIELDNAME TYPE FIELDNAME.

  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

  DEFINE __SET_STYLE.
    CLEAR LS_CELLTAB.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = &1.
    LS_CELLTAB-FIELDNAME = LV_FIELDNAME.
    LS_CELLTAB-STYLE = CONV #( &2 ).
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  END-OF-DEFINITION.

  LOOP AT GT_DISP_500 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    REFRESH LT_CELLTAB.

    __SET_STYLE : 'PREQ_NO' ALV_STYLE_COLOR_HEADING,
                          'BNFPO2' ALV_STYLE_COLOR_HEADING.

    __SET_STYLE : 'STATUS' ALV_STYLE_COLOR_POSITIVE,
                          'EBELN' ALV_STYLE_COLOR_POSITIVE,
                          'EBELP' ALV_STYLE_COLOR_POSITIVE,
                          'MESSAGE' ALV_STYLE_COLOR_POSITIVE.
    IF GV_MODE = ABAP_TRUE.
      __SET_STYLE : 'MATNR' ALV_STYLE_ENABLED.
      __SET_STYLE : 'LFDAT' ALV_STYLE_ENABLED.
      __SET_STYLE : 'MENGE' ALV_STYLE_ENABLED.
      __SET_STYLE : 'MEINS' ALV_STYLE_ENABLED.
      __SET_STYLE : 'WERKS' ALV_STYLE_ENABLED.
      __SET_STYLE : 'LGORT' ALV_STYLE_ENABLED.
    ELSE.
      __SET_STYLE : 'LFDAT' ALV_STYLE_ENABLED.
      __SET_STYLE : 'MENGE' ALV_STYLE_ENABLED.
      __SET_STYLE : 'LGORT' ALV_STYLE_ENABLED.
    ENDIF.

    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.
  ENDLOOP.

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

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0500
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

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
      IT_OUTTAB            = GT_DISP_500
      IT_FIELDCATALOG      = GT_FIELDCAT_0500.

  GO_GRID_0500->SET_READY_FOR_INPUT( 1 ).

  CALL METHOD GO_GRID_0500->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0500->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_BSART_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_BSART_0500 INPUT.

  REFRESH : LT_BSART, LT_RETURN_TAB.

  SELECT BSART BATXT
     FROM T161T
       INTO CORRESPONDING FIELDS OF TABLE LT_BSART
     WHERE BSTYP = GS_ORD_DISP-BSTYP.

  SORT LT_BSART BY BSART.
  DELETE ADJACENT DUPLICATES FROM LT_BSART COMPARING BSART.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'BSART'
      DYNPROFIELD     = 'GS_ORD_DISP-BSART'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '구매요청 유형'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      VALUE_TAB       = LT_BSART                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    GS_ORD_DISP-BSART = LS_RETURN_TAB-FIELDVAL.
    READ TABLE LT_BSART INTO LS_BSART WITH KEY BSART = LS_RETURN_TAB-FIELDVAL.
    GS_ORD_DISP-BATXT = LS_BSART-BATXT.

    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'ENTE'              " Function code
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
        OTHERS                 = 2.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_CHAIN_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_CHAIN_0500 INPUT.

  CLEAR : GS_ORD_DISP-BATXT,
             GS_ORD_DISP-EKOTX,
             GS_ORD_DISP-EKNAM,
             GS_ORD_DISP-BUTXT,
             GS_ORD_DISP-NAME1,
             GS_ORD_DISP-BEZEI.

  IF GS_ORD_DISP-BSART_NB = ABAP_TRUE.
    GS_ORD_DISP-BSART = 'NB'.
  ELSEIF GS_ORD_DISP-BSART_UB = ABAP_TRUE.
    GS_ORD_DISP-BSART = 'UB'.
  ENDIF.

  IF GS_ORD_DISP-BSART IS NOT INITIAL.
    SELECT SINGLE  BATXT
       FROM T161T
         INTO GS_ORD_DISP-BATXT
       WHERE BSTYP = GS_ORD_DISP-BSTYP
           AND BSART = GS_ORD_DISP-BSART
           AND SPRAS = SY-LANGU.
  ENDIF.

  IF GS_ORD_DISP-EKORG IS NOT INITIAL.
    SELECT SINGLE  EKOTX
       FROM T024E
         INTO GS_ORD_DISP-EKOTX
       WHERE EKORG = GS_ORD_DISP-EKORG.
  ENDIF.

  IF GS_ORD_DISP-EKGRP IS NOT INITIAL.
    SELECT SINGLE  EKNAM
       FROM T024
         INTO GS_ORD_DISP-EKNAM
       WHERE EKGRP = GS_ORD_DISP-EKGRP.
  ENDIF.

  IF GS_ORD_DISP-BUKRS IS NOT INITIAL.
    SELECT SINGLE  BUTXT
       FROM T001
         INTO GS_ORD_DISP-BUTXT
       WHERE BUKRS = GS_ORD_DISP-BUKRS.
  ENDIF.

  IF GS_ORD_DISP-INCO1 IS NOT INITIAL.
    SELECT SINGLE  BEZEI
       FROM TINCT
         INTO GS_ORD_DISP-BEZEI
       WHERE INCO1 = GS_ORD_DISP-INCO1
           AND SPRAS = SY-LANGU.
  ENDIF.

  IF GS_ORD_DISP-FLIEF IS NOT INITIAL AND GS_ORD_DISP-BSART_NB = ABAP_TRUE.
    SELECT SINGLE  NAME1
     FROM LFA1
       INTO GS_ORD_DISP-NAME1
     WHERE LIFNR = GS_ORD_DISP-FLIEF.
  ENDIF.

  IF GS_ORD_DISP-RESWK IS NOT INITIAL AND GS_ORD_DISP-BSART_UB = ABAP_TRUE.
    SELECT SINGLE  NAME1
     FROM T001W
       INTO GS_ORD_DISP-WNAME1
     WHERE WERKS = GS_ORD_DISP-RESWK.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form PROC_CREATE_ORD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_SENDER
*&---------------------------------------------------------------------*
FORM PROC_CREATE_ORD  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_DATE_CHK TYPE SY-DATUM.
  RANGES : LR_DATE FOR SY-DATUM.
  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_FIELDNAME2 TYPE FIELDNAME.
  DATA : LV_POSNR(5) TYPE N.
  DATA : LV_UNIT TYPE ZGTMMT4210-PSTOCK.
  DATA : LV_CHK_BDART(2) TYPE C.

  FIELD-SYMBOLS <LV_FIELD> TYPE ANY.
  FIELD-SYMBOLS <LV_FIELD2> TYPE ANY.

  DEFINE __ASSIGN_FIELD.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = &1.
    IF <LV_FIELD> IS ASSIGNED. UNASSIGN <LV_FIELD>. ENDIF.
    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_FIELD>.
  END-OF-DEFINITION.

  DEFINE __ASSIGN_FIELD2.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = &1.
    IF <LV_FIELD2> IS ASSIGNED. UNASSIGN <LV_FIELD2>. ENDIF.
    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN2> TO <LV_FIELD2>.
  END-OF-DEFINITION.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      IF P_CD = ABAP_TRUE.
        PO_SENDER->GET_SELECTED_CELLS_ID(
            IMPORTING
             ET_CELLS = LT_CELLS ).                " Cell IDs
      ELSE.
        RETURN.
      ENDIF.
    WHEN OTHERS.
      RETURN.
  ENDCASE.

  REFRESH GT_DISP_500.
  CLEAR LV_POSNR.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).

    READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_CELLS-ROW_ID.
    __ASSIGN_FIELD 'SEQNO'.
    CLEAR LV_CHK_BDART.
    CASE <LV_FIELD>.
      WHEN 9.
        LV_CHK_BDART = 'R1'.
      WHEN 11. "요청정보 순번
        LV_CHK_BDART = 'R3'.
      WHEN 14. " 구매제안
        PERFORM SET_DATA_FOR_ORDER USING LS_CELLS .
        CONTINUE.
      WHEN OTHERS.
        CONTINUE.
    ENDCASE.

    READ TABLE GT_FIELDCAT_0100 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.
      LV_DATE_CHK = LS_FCAT-FIELDNAME.
      IF LV_DATE_CHK NOT IN GR_DATE.
        CONTINUE.
      ENDIF.

      __ASSIGN_FIELD LV_DATE_CHK.
      IF <LV_FIELD> IS INITIAL OR <LV_FIELD> = '0'.
        CONTINUE.
      ENDIF.

*    조회대상 날짜 세팅
      READ TABLE GR_DATE INDEX 1.
      IF LV_DATE_CHK = GR_DATE-LOW.
        APPEND INITIAL LINE TO LR_DATE[] ASSIGNING FIELD-SYMBOL(<LS_DATE>).
        <LS_DATE>-SIGN = 'I'.
        <LS_DATE>-OPTION = 'LE'.
        <LS_DATE>-LOW = GR_DATE-LOW.
      ELSE.
        APPEND INITIAL LINE TO LR_DATE[] ASSIGNING <LS_DATE>.
        <LS_DATE>-SIGN = 'I'.
        <LS_DATE>-OPTION = 'EQ'.
        <LS_DATE>-LOW = LV_DATE_CHK.
      ENDIF.

      __ASSIGN_FIELD 'MATNR'.
      LOOP AT GT_CVDATA ASSIGNING FIELD-SYMBOL(<LS_TEMP>) WHERE MATNR = <LV_FIELD>
                                                                                              AND BDTER IN LR_DATE
                                                                                              AND BDART = LV_CHK_BDART.

        APPEND INITIAL LINE TO GT_DISP_500 ASSIGNING FIELD-SYMBOL(<LS_DISP>).
*      순번
        ADD 10 TO LV_POSNR.
        <LS_DISP>-BNFPO = LV_POSNR.
*      자재, 자재내역
        __ASSIGN_FIELD 'MATNR'.
        <LS_DISP>-MATNR = <LS_TEMP>-MATNR.
        <LS_DISP>-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = <LS_DISP>-MATNR ).

*      납품일
        <LS_DISP>-LFDAT = LV_DATE_CHK.

*      요청수량 - 구매제안 수량은 전부 -
        <LS_DISP>-MENGE = <LS_TEMP>-RMQTY.
*      단위
        <LS_DISP>-MEINS = <LS_TEMP>-MEINS.
*      플랜트
        <LS_DISP>-WERKS = <LS_TEMP>-WERKS.
*      요청오더번호
        <LS_DISP>-PREQ_NO = <LS_TEMP>-BANFN.
*      요청오더품목
        <LS_DISP>-BNFPO2 = <LS_TEMP>-BNFPO.
*      저장소
        PERFORM GET_LGORT_FROM_REQ USING <LS_DISP> CHANGING <LS_DISP>-LGORT.

      ENDLOOP.

    ENDIF.
  ENDLOOP.

*  헤더세팅
  CLEAR GS_ORD_DISP.
*  구매요청유형
  GS_ORD_DISP-BSART = 'NB'. " 디폴드값 세팅
  GS_ORD_DISP-BSART_NB = ABAP_TRUE.
  GS_ORD_DISP-BSTYP = 'F'. " 디폴드값 세팅
*  GS_ORD_DISP-INCO1 = 'CIF'.

  IF GT_DISP_500[] IS NOT INITIAL.
    READ TABLE GT_DISP_500 INTO DATA(LS_MAIN) INDEX 1.

    IF LS_MAIN-PREQ_NO IS NOT INITIAL.
      SELECT SINGLE BANFN, BNFPO, LIFNR, FLIEF, EKORG, EKGRP
         FROM EBAN
         INTO @DATA(LS_EBAN)
       WHERE BANFN = @LS_MAIN-PREQ_NO
           AND BNFPO = @LS_MAIN-BNFPO.

      IF LS_EBAN-FLIEF IS NOT INITIAL.
        GS_ORD_DISP-FLIEF = LS_EBAN-FLIEF. " 디폴드값 세팅
      ELSE.
        GS_ORD_DISP-FLIEF = LS_EBAN-LIFNR. " 디폴드값 세팅
      ENDIF.

      GS_ORD_DISP-EKORG = LS_EBAN-EKORG. " 디폴드값 세팅
      GS_ORD_DISP-EKGRP = LS_EBAN-EKGRP. " 디폴드값 세팅

    ELSE.
      READ TABLE GT_MASTER_EKORG INTO DATA(LS_EKORG) INDEX 1.
      GS_ORD_DISP-EKORG = LS_EKORG-EKORG.

    ENDIF.

*  공급업체
    PERFORM GET_TEXT_FLIEF USING GS_ORD_DISP-FLIEF CHANGING GS_ORD_DISP-NAME1.
*   구매조직 infor
    PERFORM GET_TEXT_EKORG USING GS_ORD_DISP-EKORG CHANGING GS_ORD_DISP-EKOTX GS_ORD_DISP-BUKRS GS_ORD_DISP-BUTXT.
*   구매그룹 text
    PERFORM GET_TEXT_EKGRP USING GS_ORD_DISP-EKGRP CHANGING GS_ORD_DISP-EKNAM.
  ELSE.
    READ TABLE GT_MASTER_EKORG INTO LS_EKORG INDEX 1.
    GS_ORD_DISP-EKORG = LS_EKORG-EKORG.

*   구매조직 infor
    PERFORM GET_TEXT_EKORG USING GS_ORD_DISP-EKORG CHANGING GS_ORD_DISP-EKOTX GS_ORD_DISP-BUKRS GS_ORD_DISP-BUTXT.
  ENDIF.

*  구매요청유형 Text
  PERFORM GET_TEXT_BSART USING GS_ORD_DISP-BSART GS_ORD_DISP-BSTYP CHANGING GS_ORD_DISP-BATXT.
*   인코텀스 text
*  PERFORM GET_TEXT_INCO1 USING GS_ORD_DISP-INCO1 CHANGING GS_ORD_DISP-BEZEI.

  CLEAR GV_MODE.

  IF GT_DISP_500[] IS INITIAL.
    GV_MODE = ABAP_TRUE. " 조회된 데이터가 없으면 변경모드로 적용
  ENDIF.

  CALL SCREEN '0500' STARTING AT 5 5 ENDING AT 135 25.


  PERFORM REFRESH_DATA..

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LGORT_FROM_REQ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_DISP>
*&      <-- <LS_DISP>_LGORT
*&---------------------------------------------------------------------*
FORM GET_LGORT_FROM_REQ  USING    PS_IMPORT LIKE GS_DISP_500
                                      CHANGING    PV_LGORT.

  SELECT SINGLE LGORT
     FROM EBAN
      INTO PV_LGORT
   WHERE BANFN = PS_IMPORT-PREQ_NO
       AND BNFPO = PS_IMPORT-BNFPO2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TEXT_EKORG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_ORD_DISP_EKORG
*&      <-- GS_ORD_DISP_EKOTX
*&      <-- GS_ORD_DISP_BUKRS
*&---------------------------------------------------------------------*
FORM GET_TEXT_EKORG  USING    PV_EKORG
                              CHANGING    PV_EKOTX
                                               PV_BUKRS
                                               PV_BUTXT.

  SELECT SINGLE EKOTX, BUKRS FROM T024E
      INTO ( @PV_EKOTX, @PV_BUKRS )
   WHERE EKORG = @PV_EKORG.

  IF PV_BUKRS IS NOT INITIAL.
    SELECT SINGLE  BUTXT
       FROM T001
         INTO PV_BUTXT
       WHERE BUKRS = PV_BUKRS.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TEXT_EKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_ORD_DISP_EKGRP
*&      <-- GS_ORD_DISP_EKNAM
*&---------------------------------------------------------------------*
FORM GET_TEXT_EKGRP  USING    PV_EKGRP
                     CHANGING PV_EKNAM.

  SELECT SINGLE  EKNAM
     FROM T024
       INTO PV_EKNAM
   WHERE EKGRP = PV_EKGRP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TEXT_INCO1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_ORD_DISP_INCO1
*&      <-- GS_ORD_DISP_BEZEI
*&---------------------------------------------------------------------*
FORM GET_TEXT_INCO1  USING    PV_INCO1
                     CHANGING PV_BEZEI.

  SELECT SINGLE  BEZEI
     FROM TINCT
       INTO PV_BEZEI
     WHERE INCO1 = PV_INCO1
         AND SPRAS = SY-LANGU.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_LINE_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_SENDER
*&---------------------------------------------------------------------*
FORM ADD_LINE_0500  USING   PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LV_POSNR(5) TYPE N.
  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  DATA : LV_FIELDNAME TYPE FIELDNAME.

  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

  DEFINE __SET_STYLE.
    CLEAR LS_CELLTAB.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = &1.
    LS_CELLTAB-FIELDNAME = LV_FIELDNAME.
    LS_CELLTAB-STYLE = CONV #( &2 ).
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  END-OF-DEFINITION.

  LV_POSNR = LINES( GT_DISP_500 ) + 1.
  LV_POSNR = LV_POSNR * 10.

  APPEND INITIAL LINE TO GT_DISP_500 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

* 초기값 세팅
*  순번
  <LS_MAIN>-BNFPO = LV_POSNR.
  <LS_MAIN>-WERKS = P_WERKS.
* 스타일 세팅
  REFRESH LT_CELLTAB.

  __SET_STYLE : 'PREQ_NO' ALV_STYLE_COLOR_HEADING,
                        'BNFPO2' ALV_STYLE_COLOR_HEADING.

  __SET_STYLE : 'STATUS' ALV_STYLE_COLOR_POSITIVE,
                        'EBELN' ALV_STYLE_COLOR_POSITIVE,
                        'EBELP' ALV_STYLE_COLOR_POSITIVE,
                        'MESSAGE' ALV_STYLE_COLOR_POSITIVE.

  __SET_STYLE : 'MATNR' ALV_STYLE_ENABLED.
  __SET_STYLE : 'LFDAT' ALV_STYLE_ENABLED.
  __SET_STYLE : 'MENGE' ALV_STYLE_ENABLED.
  __SET_STYLE : 'MEINS' ALV_STYLE_ENABLED.
*  __SET_STYLE : 'WERKS' ALV_STYLE_ENABLED.
  __SET_STYLE : 'LGORT' ALV_STYLE_ENABLED.

  IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
  ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
  IF <LT_CELLTAB> IS ASSIGNED.
    <LT_CELLTAB> = LT_CELLTAB.
  ENDIF.

  PERFORM REFRESH_GRID USING PO_SENDER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_LINE_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_SENDER
*&---------------------------------------------------------------------*
FORM DELETE_LINE_0500  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LV_POSNR(5) TYPE N.
  DATA : LV_TABIX TYPE I..

  CALL METHOD PO_SENDER->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  IF LT_ROW[] IS NOT INITIAL. " 선택열 삭제
    SORT LT_ROW BY INDEX DESCENDING. " 삭제시 순차삭제를 위해 역순 소트
    LOOP AT LT_ROW INTO LS_ROW.
      DELETE GT_DISP_500 INDEX LS_ROW-INDEX.
    ENDLOOP.

*  순재 재세팅
    LOOP AT GT_DISP_500 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
      ADD 10 TO LV_POSNR.
      <LS_MAIN>-BNFPO = LV_POSNR.
    ENDLOOP.
  ELSE. " 마지막라인 삭제
    LV_TABIX = LINES( GT_DISP_500 ) .
    DELETE GT_DISP_500 INDEX LV_TABIX.
  ENDIF.

  PERFORM REFRESH_GRID USING PO_SENDER.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CREATE_ORD_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_SENDER
*&---------------------------------------------------------------------*
FORM PROC_CREATE_ORD_0500  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LV_ERR.
  DATA : LS_POHEADER TYPE BAPIMEPOHEADER.
  DATA : LS_POHEADERX TYPE BAPIMEPOHEADERX.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LT_POITEM TYPE TABLE OF BAPIMEPOITEM.
  DATA : LT_POITEMX TYPE TABLE OF BAPIMEPOITEMX.
  DATA : LT_POSCHEDULE TYPE TABLE OF BAPIMEPOSCHEDULE.
  DATA : LT_POSCHEDULEX TYPE TABLE OF BAPIMEPOSCHEDULX.
  DATA : LV_EXPPURCHASEORDER TYPE BAPIMEPOHEADER-PO_NUMBER.
  DATA : LS_EXPHEADER TYPE BAPIMEPOHEADER.
  DATA : LS_EXPPOEXPIMPHEADER TYPE BAPIEIKP.
  DATA : LT_DISP_MESSAGE TYPE TABLE OF ZTESMESSAGE.
  DATA : LV_SEQ(6) TYPE N.
  DATA : LT_LOW TYPE LVC_T_ROW.
  DATA : LT_DATA LIKE TABLE OF GS_DISP_500.

  GO_GRID_0500->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS =  LT_LOW ).

  DELETE LT_LOW WHERE INDEX = 0.

  IF LT_LOW IS NOT INITIAL.
    LOOP AT LT_LOW INTO DATA(LS_LOW).
      READ TABLE GT_DISP_500 INTO GS_DISP_500 INDEX LS_LOW-INDEX.
      IF SY-SUBRC EQ 0.
        APPEND INITIAL LINE TO LT_DATA ASSIGNING FIELD-SYMBOL(<LS_DATA>).
        MOVE-CORRESPONDING GS_DISP_500 TO <LS_DATA>.
      ENDIF.
    ENDLOOP.
  ELSE.
    MOVE-CORRESPONDING GT_DISP_500 TO LT_DATA.
  ENDIF.

  PERFORM CHECK_BEFORE_ORD TABLES LT_DATA CHANGING LV_ERR. "구매요청 생성전 점검

  IF LV_ERR EQ ABAP_TRUE.
    RETURN.
  ENDIF.

  CHECK GT_DISP_500[] IS NOT INITIAL.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '해당 정보로 구매오더가 생성됩니다. 진행하시겠습니까?'
    '생성확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

*  POHEADER
  LS_POHEADER-COMP_CODE = GS_ORD_DISP-BUKRS.
  LS_POHEADER-PURCH_ORG = GS_ORD_DISP-EKORG.
  LS_POHEADER-PUR_GROUP = GS_ORD_DISP-EKGRP.
  LS_POHEADER-INCOTERMS1 = GS_ORD_DISP-INCO1.

  CASE ABAP_TRUE.
    WHEN GS_ORD_DISP-BSART_NB.
      LS_POHEADER-DOC_TYPE = 'NB'.
      LS_POHEADER-VENDOR = GS_ORD_DISP-FLIEF.
    WHEN GS_ORD_DISP-BSART_UB.
      LS_POHEADER-DOC_TYPE = 'UB'.
      LS_POHEADER-SUPPL_PLNT = GS_ORD_DISP-RESWK.
  ENDCASE.
*  POHEADERX
  LS_POHEADERX-COMP_CODE = ABAP_TRUE.
  LS_POHEADERX-DOC_TYPE = ABAP_TRUE.
  LS_POHEADERX-PURCH_ORG = ABAP_TRUE.
  LS_POHEADERX-PUR_GROUP = ABAP_TRUE.
  LS_POHEADERX-INCOTERMS1 = ABAP_TRUE.
  CASE ABAP_TRUE.
    WHEN GS_ORD_DISP-BSART_NB.
      LS_POHEADERX-VENDOR = ABAP_TRUE.
    WHEN GS_ORD_DISP-BSART_UB.
      LS_POHEADERX-SUPPL_PLNT = ABAP_TRUE.
  ENDCASE.



  LOOP AT LT_DATA ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
* POITEM
    APPEND INITIAL LINE TO LT_POITEM ASSIGNING FIELD-SYMBOL(<LS_POITEM>).
    <LS_POITEM>-PO_ITEM = <LS_MAIN>-BNFPO.
    <LS_POITEM>-MATERIAL = <LS_MAIN>-MATNR.
    <LS_POITEM>-PLANT = <LS_MAIN>-WERKS.
    <LS_POITEM>-STGE_LOC = <LS_MAIN>-LGORT.
    <LS_POITEM>-QUANTITY = <LS_MAIN>-MENGE..
    <LS_POITEM>-PO_UNIT = <LS_MAIN>-MEINS.
    IF <LS_MAIN>-PREQ_NO IS NOT INITIAL.
      <LS_POITEM>-PREQ_NO = <LS_MAIN>-PREQ_NO.
      <LS_POITEM>-PREQ_ITEM = <LS_MAIN>-BNFPO2.
    ENDIF.

* POITEMX
    APPEND INITIAL LINE TO LT_POITEMX ASSIGNING FIELD-SYMBOL(<LS_POITEMX>).
    <LS_POITEMX>-PO_ITEM = <LS_MAIN>-BNFPO.
    <LS_POITEMX>-PO_ITEMX = ABAP_TRUE.
    <LS_POITEMX>-MATERIAL = ABAP_TRUE.
    <LS_POITEMX>-PLANT = ABAP_TRUE.
    <LS_POITEMX>-STGE_LOC = ABAP_TRUE.
    <LS_POITEMX>-QUANTITY = ABAP_TRUE.
    <LS_POITEMX>-PO_UNIT = ABAP_TRUE.
    IF <LS_MAIN>-PREQ_NO IS NOT INITIAL.
      <LS_POITEMX>-PREQ_NO = ABAP_TRUE.
      <LS_POITEMX>-PREQ_ITEM = ABAP_TRUE.
    ENDIF.

*  POSCHEDULE
    APPEND INITIAL LINE TO LT_POSCHEDULE ASSIGNING FIELD-SYMBOL(<LS_POSCHEDULE>).
    <LS_POSCHEDULE>-PO_ITEM = <LS_MAIN>-BNFPO.
    <LS_POSCHEDULE>-SCHED_LINE = '0001'.
    <LS_POSCHEDULE>-DEL_DATCAT_EXT = 'D'.
    <LS_POSCHEDULE>-DELIVERY_DATE = <LS_MAIN>-LFDAT.
    <LS_POSCHEDULE>-QUANTITY = <LS_MAIN>-MENGE.
    <LS_POSCHEDULE>-STAT_DATE = <LS_MAIN>-LFDAT.

*  POSCHEDULEX
    APPEND INITIAL LINE TO LT_POSCHEDULEX ASSIGNING FIELD-SYMBOL(<LS_POSCHEDULEX>).
    <LS_POSCHEDULEX>-PO_ITEM = <LS_MAIN>-BNFPO.
    <LS_POSCHEDULEX>-SCHED_LINE = '0001'.
    <LS_POSCHEDULEX>-PO_ITEMX = ABAP_TRUE.
    <LS_POSCHEDULEX>-SCHED_LINEX = ABAP_TRUE.
    <LS_POSCHEDULEX>-DEL_DATCAT_EXT = ABAP_TRUE.
    <LS_POSCHEDULEX>-DELIVERY_DATE = ABAP_TRUE.
    <LS_POSCHEDULEX>-QUANTITY = ABAP_TRUE.
    <LS_POSCHEDULEX>-STAT_DATE = ABAP_TRUE.
  ENDLOOP.

  CALL FUNCTION 'BAPI_PO_CREATE1'
    EXPORTING
      POHEADER          = LS_POHEADER
      POHEADERX         = LS_POHEADERX
      NO_AUTHORITY      = ABAP_TRUE
    IMPORTING
      EXPPURCHASEORDER  = LV_EXPPURCHASEORDER
      EXPHEADER         = LS_EXPHEADER
      EXPPOEXPIMPHEADER = LS_EXPPOEXPIMPHEADER
    TABLES
      RETURN            = LT_RETURN
      POITEM            = LT_POITEM
      POITEMX           = LT_POITEMX
      POSCHEDULE        = LT_POSCHEDULE
      POSCHEDULEX       = LT_POSCHEDULEX.

  READ TABLE LT_RETURN INTO DATA(LS_RETURN) WITH KEY TYPE = 'E'.
  IF SY-SUBRC EQ 0. " 에러건 존재시
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    LOOP AT GT_DISP_500 ASSIGNING <LS_MAIN>.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      IF LS_RETURN-MESSAGE IS NOT INITIAL.
        <LS_MAIN>-MESSAGE = LS_RETURN-MESSAGE.
      ELSE.
        MESSAGE ID LS_RETURN-ID TYPE 'S'  NUMBER LS_RETURN-NUMBER INTO <LS_MAIN>-MESSAGE .
      ENDIF.
    ENDLOOP.

    REFRESH LT_DISP_MESSAGE.
    CLEAR LV_SEQ.
    LOOP AT LT_RETURN INTO LS_RETURN.
      APPEND INITIAL LINE TO LT_DISP_MESSAGE ASSIGNING FIELD-SYMBOL(<LS_DISP_MESSAGE>).
      ADD 1 TO LV_SEQ.
      <LS_DISP_MESSAGE>-MSGSQ = LV_SEQ .
      <LS_DISP_MESSAGE>-MSGID = LS_RETURN-ID.
      <LS_DISP_MESSAGE>-MSGNO = LS_RETURN-NUMBER..
      <LS_DISP_MESSAGE>-MSGTY = LS_RETURN-TYPE.
      <LS_DISP_MESSAGE>-MSGV1 = LS_RETURN-MESSAGE_V1.
      <LS_DISP_MESSAGE>-MSGV2 = LS_RETURN-MESSAGE_V2.
      <LS_DISP_MESSAGE>-MSGV3 = LS_RETURN-MESSAGE_V3.
      <LS_DISP_MESSAGE>-MSGV4 = LS_RETURN-MESSAGE_V4.
      <LS_DISP_MESSAGE>-MSGTX = LS_RETURN-MESSAGE.
    ENDLOOP.

    CALL FUNCTION 'Z_TE_POPUP_TO_ERROR_MESSAGE'
      TABLES
        XMSG = LT_DISP_MESSAGE.
  ELSE. " 성공시
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
    LOOP AT GT_DISP_500 ASSIGNING <LS_MAIN>.
      READ TABLE LT_DATA INTO DATA(LS_DATA) WITH KEY BNFPO = <LS_MAIN>-BNFPO.
      IF SY-SUBRC EQ 0.
        <LS_MAIN>-STATUS = ICON_LED_GREEN.
        <LS_MAIN>-EBELN = LV_EXPPURCHASEORDER.
        <LS_MAIN>-EBELP = <LS_MAIN>-BNFPO.
        <LS_MAIN>-MESSAGE = TEXT-M12.
        PERFORM SET_LOG_CREATE_ORD USING <LS_MAIN>.
        WAIT UP TO '0.1' SECONDS.
      ENDIF.
    ENDLOOP.

    GV_MODE = 'C'.
  ENDIF.

  PERFORM REFRESH_GRID USING PO_SENDER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BEFORE_ORD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ERR
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_ORD  TABLES PT_DATA STRUCTURE GS_DISP_500
                                       CHANGING PV_ERR.

* 구매요청 유형
  IF GS_ORD_DISP-BSART IS NOT INITIAL.
    SELECT SINGLE BSART FROM T161T
      INTO @DATA(LV_BSART)
      WHERE BSTYP = 'F'
         AND BSART = @GS_ORD_DISP-BSART .
    IF SY-SUBRC NE 0.
      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E03 TEXT-E05 TEXT-E04.
      PV_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

  ELSE.
    PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E05 TEXT-E08 ' '.
    PV_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

* 구매조직
  IF GS_ORD_DISP-EKORG IS NOT INITIAL.
    READ TABLE GT_MASTER_EKORG INTO DATA(LS_EKORG) WITH KEY EKORG = GS_ORD_DISP-EKORG.
    IF SY-SUBRC NE 0.
      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E03 TEXT-E06 TEXT-E04.
      PV_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

  ELSE.
    PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E06 TEXT-E08 ' '.
    PV_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

* 공급업체
  CASE ABAP_TRUE.
    WHEN GS_ORD_DISP-BSART_NB.
      IF GS_ORD_DISP-FLIEF IS NOT INITIAL.
        SELECT SINGLE  NAME1
           FROM LFA1
             INTO @DATA(NAME1)
           WHERE LIFNR = @GS_ORD_DISP-FLIEF.
        IF SY-SUBRC NE 0.
          PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E03 TEXT-E07 TEXT-E04.
          PV_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.

      ELSE.
        PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E07 TEXT-E08 ' ' .
        PV_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    WHEN GS_ORD_DISP-BSART_UB.
      IF GS_ORD_DISP-RESWK IS NOT INITIAL.
        SELECT SINGLE  NAME1
           FROM T001W
             INTO @DATA(WNAME1)
           WHERE WERKS = @GS_ORD_DISP-RESWK.
        IF SY-SUBRC NE 0.
          PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E03 TEXT-E17 TEXT-E04.
          PV_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.

      ELSE.
        PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E17 TEXT-E08 ' '.
        PV_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.

  ENDCASE.

* 구매그룹
  IF GS_ORD_DISP-EKGRP IS NOT INITIAL.
    SELECT SINGLE  EKNAM
       FROM T024
         INTO @DATA(LV_EKNAM)
       WHERE EKGRP = @GS_ORD_DISP-EKGRP.
    IF SY-SUBRC NE 0.
      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E03 TEXT-E14 TEXT-E04.
      PV_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

  ELSE.
    PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E14 TEXT-E08 ' '.
    PV_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

* 회사코드
  IF GS_ORD_DISP-BUKRS IS NOT INITIAL.
    SELECT SINGLE  BUTXT
       FROM T001
         INTO @DATA(LV_BUTXT)
       WHERE BUKRS = @GS_ORD_DISP-BUKRS.
    IF SY-SUBRC NE 0.
      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E03 TEXT-E15 TEXT-E04.
      PV_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

  ELSE.
    PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E15 TEXT-E08 ' '.
    PV_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

* 인코텀스
*  IF GS_ORD_DISP-INCO1 IS NOT INITIAL.
*    SELECT SINGLE  BEZEI
*       FROM TINCT
*         INTO @DATA(LV_BEZEI)
*       WHERE INCO1 = @GS_ORD_DISP-INCO1
*           AND SPRAS = @SY-LANGU.
*    IF SY-SUBRC NE 0.
*      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E03 TEXT-E16 TEXT-E04.
*      PV_ERR = ABAP_TRUE.
*      RETURN.
*    ENDIF.
*
*  ELSE.
*    PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E16 TEXT-E08 ' '.
*    PV_ERR = ABAP_TRUE.
*    RETURN.
*  ENDIF.

  LOOP AT PT_DATA ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

*   플랜트
    IF <LS_MAIN>-WERKS IS INITIAL.
      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-013 TEXT-E08 ' '.
      PV_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
*    자재코드
    IF <LS_MAIN>-MATNR IS NOT INITIAL.
      SELECT SINGLE MATNR FROM MARC
        INTO @DATA(LV_MATNR)
        WHERE MATNR = @<LS_MAIN>-MATNR
           AND WERKS = @<LS_MAIN>-WERKS.
      IF SY-SUBRC NE 0.
        PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E03 TEXT-002 TEXT-E04.
        PV_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ELSE.
      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-002 TEXT-E08 ' '.
      PV_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

*  소요일자
    IF <LS_MAIN>-LFDAT IS INITIAL OR <LS_MAIN>-LFDAT = '00000000'.
      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E10 TEXT-E08 ' '.
      PV_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

* 요청수량
    IF <LS_MAIN>-MENGE = 0.
      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E11 TEXT-E08 ' '.
      PV_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

* 단위
    IF <LS_MAIN>-MEINS IS INITIAL.
      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E12 TEXT-E08 ' '.
      PV_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

* 저장위치
    IF <LS_MAIN>-LGORT IS INITIAL.
      PERFORM POPUP_TO_DISP_MESSAGE USING TEXT-E13 TEXT-E08 ' '.
      PV_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LOG_CREATE_ORD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAIN>
*&---------------------------------------------------------------------*
FORM SET_LOG_CREATE_ORD  USING    PS_MAIN LIKE GS_DISP_500.

  DATA : LS_3260 TYPE ZGTPPT3260.

  GET TIME STAMP FIELD LS_3260-TIMESTAMPL.

  LS_3260-EBELN = PS_MAIN-EBELN.
  LS_3260-EBELP = PS_MAIN-EBELP + 0.

  LS_3260-MATNR = PS_MAIN-MATNR.
  LS_3260-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = PS_MAIN-MATNR ).
  LS_3260-WERKS = PS_MAIN-WERKS.
  LS_3260-MENGE = PS_MAIN-MENGE.
  LS_3260-MEINS = PS_MAIN-MEINS.
  LS_3260-EINDT = PS_MAIN-LFDAT.
  LS_3260-LGORT = PS_MAIN-LGORT.

  MOVE : SY-UNAME TO LS_3260-CRNAM,
            SY-DATUM TO LS_3260-CRDAT,
            SY-UZEIT TO LS_3260-CRTIM,
            SY-UNAME TO LS_3260-CHNAM,
            SY-DATUM TO LS_3260-CHDAT,
            SY-UZEIT TO LS_3260-CHTIM.

  MODIFY ZGTPPT3260 FROM LS_3260.
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form TRANSLATE_UNIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_CHK_MEINS_MEINS
*&      --> LS_CV_MEINS
*&      <-- GS_WSUM_DMQTY
*&      <-- GS_WSUM_GIQTY
*&      <-- GS_WSUM_RMQTY
*&---------------------------------------------------------------------*
FORM TRANSLATE_UNIT  USING    PV_MATNR TYPE MATNR
                                             PV_ORING_MEINS TYPE MEINS
                                             PV_ORDER_MEINS TYPE MEINS
                             CHANGING   PV_QTY.



  DATA : LV_QTY TYPE EKPO-MENGE.
  LV_QTY = PV_QTY.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      I_MATNR              = PV_MATNR    " <-- 해당 자재코드
      I_IN_ME              = PV_ORDER_MEINS  "<-- 현 수량의 단위
      I_OUT_ME             = PV_ORING_MEINS " <-- 변경되어질 수량의 단위
      I_MENGE              = LV_QTY " <-- 현 수량 변수
    IMPORTING
      E_MENGE              = LV_QTY " <-- 변경되어질 수량변수
    EXCEPTIONS
      ERROR_IN_APPLICATION = 1
      ERROR                = 2
      OTHERS               = 3.

  PV_QTY = LV_QTY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EKORG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EKORG .

  REFRESH GT_MASTER_EKORG. " 유효한 구매조직

  SELECT A~EKORG, B~EKOTX
    FROM T024W AS A
    INNER JOIN T024E AS B
                            ON B~EKORG = A~EKORG
    WHERE A~WERKS = @P_WERKS
    INTO CORRESPONDING FIELDS OF TABLE @GT_MASTER_EKORG.

  SORT GT_MASTER_EKORG BY EKORG.
  DELETE ADJACENT DUPLICATES FROM GT_MASTER_EKORG COMPARING EKORG.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_EKORG_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_EKORG_0500 INPUT.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'EKORG'
      DYNPROFIELD     = 'GS_ORD_DISP-EKORG'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '구매조직'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      VALUE_TAB       = GT_MASTER_EKORG                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    GS_ORD_DISP-EKORG = LS_RETURN_TAB-FIELDVAL.
    CLEAR LS_MASTER.
    READ TABLE GT_MASTER_EKORG INTO LS_MASTER WITH KEY EKORG = LS_RETURN_TAB-FIELDVAL.
    GS_ORD_DISP-EKOTX = LS_MASTER-EKOTX.

    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'ENTE'              " Function code
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
        OTHERS                 = 2.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form popup_to_disp_message
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TEXT_E03
*&      --> TEXT_E05
*&      --> TEXT_E04
*&---------------------------------------------------------------------*
FORM POPUP_TO_DISP_MESSAGE  USING    PV_TEXT01
                                                           PV_TEXT02
                                                           PV_TEXT03.
  DATA : LS_MESSSAGE TYPE J1UIF_MESSSAGE.

  MESSAGE S006 WITH PV_TEXT01 PV_TEXT02 PV_TEXT03 INTO LS_MESSSAGE-TEXT.

  CALL FUNCTION '/ATL/POPUP_SINGLE_MESSAGE'
    EXPORTING
      MODE      = 'E'
      I_MESSAGE = LS_MESSSAGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_MTART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> S_MTART_LOW
*&---------------------------------------------------------------------*
FORM F4_MTART  USING    PV_DYNPROFLD TYPE HELP_INFO-DYNPROFLD .

  DATA : BEGIN OF LS_MTART,
           MTART TYPE T134T-MTART, "구매요청 유형
           MTBEZ TYPE T134T-MTBEZ, "내역
         END OF LS_MTART.
  DATA : LT_MTART LIKE TABLE OF LS_MTART.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  IF LT_MTART IS INITIAL.
    SELECT MTART MTBEZ
       FROM T134T
         INTO CORRESPONDING FIELDS OF TABLE LT_MTART
       WHERE SPRAS = SY-LANGU
         AND MTART IN GR_MTART.
  ENDIF.

  SORT LT_MTART BY MTART.
  DELETE ADJACENT DUPLICATES FROM LT_MTART COMPARING MTART.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'MTART'
      DYNPROFIELD     = PV_DYNPROFLD           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '자재유형 내역'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      VALUE_TAB       = LT_MTART                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    ASSIGN (PV_DYNPROFLD) TO FIELD-SYMBOL(<LV_VALUE>).
    <LV_VALUE> = LS_RETURN_TAB-FIELDVAL.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_init_date
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_INIT_DATE .

* 현재일 기준으로 조회 기준일 세팅
  DATA : GV_WEEK TYPE SCAL-WEEK.

  P_YEAR = SY-DATUM+0(4).

  CLEAR GV_WEEK.
  CALL FUNCTION 'DATE_GET_WEEK'
    EXPORTING
      DATE         = SY-DATUM
    IMPORTING
      WEEK         = GV_WEEK
    EXCEPTIONS
      DATE_INVALID = 1
      OTHERS       = 2.

  CLEAR S_WEEK.
  REFRESH S_WEEK[].

  S_WEEK-SIGN = 'I'.
  S_WEEK-OPTION = 'BT'.
  S_WEEK-LOW = GV_WEEK+4(2).
  GV_WEEK = GV_WEEK + 14.
  S_WEEK-HIGH = GV_WEEK+4(2).

  IF S_WEEK[] IS INITIAL.
    APPEND S_WEEK.
  ENDIF.

  CLEAR S_DAY.
  REFRESH S_DAY[].

  S_DAY-SIGN = 'I'.
  S_DAY-OPTION = 'BT'.
  S_DAY-LOW = SY-DATUM.
  S_DAY-HIGH = SY-DATUM + 104.
  IF S_DAY[] IS INITIAL.
    APPEND S_DAY.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4HELP_FLIEF_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4HELP_FLIEF_0400 .

  DATA : LR_MATNR TYPE RANGE OF MATNR.
  DATA : LS_MATNR LIKE LINE OF LR_MATNR.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : BEGIN OF LS_FLIEF,
           MATNR  TYPE EINA-MATNR,
           WERKS  TYPE EINE-WERKS,
           LIFNR  TYPE EINA-LIFNR,
           NAME1  TYPE LFA1-NAME1,
           INFNR  TYPE EINA-INFNR,
           ESOKZ  TYPE EINE-ESOKZ,
           DDTEXT TYPE DD07T-DDTEXT,
         END OF LS_FLIEF.
  DATA : LT_FLIEF LIKE TABLE OF LS_FLIEF.
  DATA : LV_POSION(4) TYPE N.
  DATA : LV_OFFSET(6) TYPE N.

  DATA : LO_FLIEF TYPE REF TO DATA.

  CREATE DATA LO_FLIEF LIKE LS_FLIEF.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  LOOP AT GT_DISP_400 INTO GS_DISP_400.
    CLEAR LS_MATNR.
    IF GS_DISP_400-MATNR IS NOT INITIAL.
      LS_MATNR-SIGN = 'I'.
      LS_MATNR-OPTION = 'EQ'.
      LS_MATNR-LOW = GS_DISP_400-MATNR.
      COLLECT LS_MATNR INTO LR_MATNR.
    ENDIF.
  ENDLOOP.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_POSION.
  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).
    IF <LS_FIELD_TAB>-FIELDNAME = 'LIFNR'.
      <LS_FIELD_TAB>-KEYFLAG = ABAP_TRUE.
    ENDIF.

    <LS_FIELD_TAB>-REPTEXT  = <LS_FIELD_TAB>-SCRTEXT_M.
    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.
*    ADD 1 TO LV_POSION.
*    <LS_FIELD_TAB>-POSITION = LV_POSION.
  ENDLOOP.

  SELECT A~MATNR, B~WERKS, A~LIFNR, C~NAME1, A~INFNR, B~ESOKZ, D~DDTEXT
    FROM EINA AS A
    INNER JOIN EINE AS B ON B~INFNR = A~INFNR
    INNER JOIN LFA1 AS C ON C~LIFNR = A~LIFNR
    LEFT JOIN DD07T AS D ON D~DOMVALUE_L = B~ESOKZ
                          AND D~DDLANGUAGE = @SY-LANGU
                          AND D~DOMNAME = 'ESOKZ'
   WHERE A~MATNR IN @LR_MATNR
      AND B~EKORG  = @GS_REQ_DISP-EKORG
      AND B~WERKS  = @P_WERKS
      AND A~LOEKZ   = ' '
      AND B~LOEKZ   = ' '
     INTO CORRESPONDING FIELDS OF TABLE @LT_FLIEF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'LIFNR'
      DYNPROFIELD     = 'GS_REQ_DISP-FLIEF'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '공급업체'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = LT_FLIEF                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    GS_REQ_DISP-FLIEF = LS_RETURN_TAB-FIELDVAL.
    READ TABLE LT_FLIEF INTO LS_FLIEF WITH KEY LIFNR = GS_REQ_DISP-FLIEF.
    IF SY-SUBRC EQ 0.
      GS_REQ_DISP-NAME1 = LS_FLIEF-NAME1.
    ENDIF.

    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'ENTE'              " Function code
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
        OTHERS                 = 2.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_FLIEF_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_FLIEF_0500 INPUT.

  PERFORM F4HELP_FLIEF_0500.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form F4HELP_FLIEF_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4HELP_FLIEF_0500 .

  DATA : LR_MATNR TYPE RANGE OF MATNR.
  DATA : LS_MATNR LIKE LINE OF LR_MATNR.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : BEGIN OF LS_FLIEF,
           MATNR  TYPE EINA-MATNR,
           WERKS  TYPE EINE-WERKS,
           LIFNR  TYPE EINA-LIFNR,
           NAME1  TYPE LFA1-NAME1,
           INFNR  TYPE EINA-INFNR,
           ESOKZ  TYPE EINE-ESOKZ,
           DDTEXT TYPE DD07T-DDTEXT,
         END OF LS_FLIEF.
  DATA : LT_FLIEF LIKE TABLE OF LS_FLIEF.
  DATA : LV_POSION(4) TYPE N.
  DATA : LV_OFFSET(6) TYPE N.

  DATA : LO_FLIEF TYPE REF TO DATA.

  CREATE DATA LO_FLIEF LIKE LS_FLIEF.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  LOOP AT GT_DISP_500 INTO GS_DISP_500.
    CLEAR LS_MATNR.
    IF GS_DISP_500-MATNR IS NOT INITIAL.
      LS_MATNR-SIGN = 'I'.
      LS_MATNR-OPTION = 'EQ'.
      LS_MATNR-LOW = GS_DISP_500-MATNR.
      COLLECT LS_MATNR INTO LR_MATNR.
    ENDIF.
  ENDLOOP.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_POSION.
  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).
    IF <LS_FIELD_TAB>-FIELDNAME = 'LIFNR'.
      <LS_FIELD_TAB>-KEYFLAG = ABAP_TRUE.
    ENDIF.

    <LS_FIELD_TAB>-REPTEXT  = <LS_FIELD_TAB>-SCRTEXT_M.
    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.
*    ADD 1 TO LV_POSION.
*    <LS_FIELD_TAB>-POSITION = LV_POSION.
  ENDLOOP.

  SELECT A~MATNR, B~WERKS, A~LIFNR, C~NAME1, A~INFNR, B~ESOKZ, D~DDTEXT
    FROM EINA AS A
    INNER JOIN EINE AS B ON B~INFNR = A~INFNR
    INNER JOIN LFA1 AS C ON C~LIFNR = A~LIFNR
    LEFT JOIN DD07T AS D ON D~DOMVALUE_L = B~ESOKZ
                          AND D~DDLANGUAGE = @SY-LANGU
                          AND D~DOMNAME = 'ESOKZ'
   WHERE A~MATNR IN @LR_MATNR
      AND B~EKORG  = @GS_ORD_DISP-EKORG
      AND B~WERKS  = @P_WERKS
      AND A~LOEKZ   = ' '
      AND B~LOEKZ   = ' '
     INTO CORRESPONDING FIELDS OF TABLE @LT_FLIEF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'LIFNR'
      DYNPROFIELD     = 'GS_ORD_DISP-FLIEF'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '공급업체'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = LT_FLIEF                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    GS_ORD_DISP-FLIEF = LS_RETURN_TAB-FIELDVAL.
    READ TABLE LT_FLIEF INTO LS_FLIEF WITH KEY LIFNR = GS_ORD_DISP-FLIEF.
    IF SY-SUBRC EQ 0.
      GS_ORD_DISP-NAME1 = LS_FLIEF-NAME1.
    ENDIF.

    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'ENTE'              " Function code
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
        OTHERS                 = 2.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DATA_FOR_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_DISP_500
*&      --> LS_CELLS
*&---------------------------------------------------------------------*
FORM SET_DATA_FOR_ORDER  USING    PS_CELLS TYPE LVC_S_CENO.

  DATA : LV_DATE_CHK TYPE SY-DATUM.
  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_FIELDNAME2 TYPE FIELDNAME.
  DATA : LV_POSNR(5) TYPE N.
  FIELD-SYMBOLS <LV_FIELD> TYPE ANY.
  FIELD-SYMBOLS <LV_FIELD2> TYPE ANY.

  DEFINE __ASSIGN_FIELD.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = &1.
    IF <LV_FIELD> IS ASSIGNED. UNASSIGN <LV_FIELD>. ENDIF.
    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_FIELD>.
  END-OF-DEFINITION.

  DEFINE __ASSIGN_FIELD2.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = &1.
    IF <LV_FIELD2> IS ASSIGNED. UNASSIGN <LV_FIELD2>. ENDIF.
    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN2> TO <LV_FIELD2>.
  END-OF-DEFINITION.

  READ TABLE <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX PS_CELLS-ROW_ID.

  READ TABLE GT_FIELDCAT_0100 INTO DATA(LS_FCAT) INDEX PS_CELLS-COL_ID.
  IF SY-SUBRC EQ 0.
    CASE LS_FCAT-FIELDNAME.
      WHEN 'DUEDATE'.
        __ASSIGN_FIELD 'DUEDATE'.
      WHEN OTHERS.
        LV_DATE_CHK = LS_FCAT-FIELDNAME.
        IF LV_DATE_CHK NOT IN GR_DATE.
          RETURN.
        ENDIF.
        __ASSIGN_FIELD LV_DATE_CHK.
    ENDCASE.

    IF <LV_FIELD> IS INITIAL.
      RETURN.
    ENDIF.

    APPEND INITIAL LINE TO GT_DISP_500[] ASSIGNING FIELD-SYMBOL(<LS_DISP>).

    ADD 10 TO LV_POSNR.
    <LS_DISP>-BNFPO = LV_POSNR.

*      요청수량
    REPLACE ALL OCCURRENCES OF ',' IN <LV_FIELD> WITH ''.
    REPLACE ALL OCCURRENCES OF '-' IN <LV_FIELD> WITH ''.
    CONDENSE <LV_FIELD>.

    <LS_DISP>-MENGE = <LV_FIELD>.

*      단위
    __ASSIGN_FIELD 'MEINS'.
    <LS_DISP>-MEINS = <LV_FIELD>.
* 자재코드
    __ASSIGN_FIELD 'MATNR'.
    <LS_DISP>-MATNR = <LV_FIELD>.
*    자재코드 내역
    __ASSIGN_FIELD 'MAKTX'.
    <LS_DISP>-MAKTX = <LV_FIELD>.

*      플랜트
    <LS_DISP>-WERKS = P_WERKS.
*      저장소
    PERFORM GET_LGORT USING <LS_DISP>-MATNR CHANGING <LS_DISP>-LGORT.

    CASE LS_FCAT-FIELDNAME.
      WHEN 'DUEDATE'.
*      납품일
        LOOP AT <GT_MAIN_DISP_100> ASSIGNING FIELD-SYMBOL(<LS_MAIN2>).
          __ASSIGN_FIELD2 'MATNR'.
          IF <LV_FIELD2> = <LS_DISP>-MATNR.
            __ASSIGN_FIELD2 'GBNCD'.
            IF <LV_FIELD2> = 'Z1'.
              READ TABLE GR_DATE INDEX 1.
              LV_DATE = GR_DATE-LOW.
              DO .
                CLEAR LV_FIELDNAME2.
                LV_FIELDNAME2 = LV_DATE && '_CHK'.
                __ASSIGN_FIELD2 LV_FIELDNAME2.
                IF <LV_FIELD2> = ABAP_TRUE.
                  EXIT.
                ENDIF.

                IF GR_DATE-HIGH = LV_DATE.
                  EXIT.
                ENDIF.

                LV_DATE = LV_DATE + 1.
              ENDDO.

            ENDIF.
          ENDIF.
        ENDLOOP.
      WHEN OTHERS.
        __ASSIGN_FIELD 'PLIFZ'.
        LV_DATE = LV_DATE_CHK + <LV_FIELD>.
    ENDCASE.

    <LS_DISP>-LFDAT = LV_DATE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_D8_BDART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_CVDATA
*&---------------------------------------------------------------------*
FORM GET_D8_BDART  TABLES   PT_CVDATA STRUCTURE GS_CVDATA.

  RANGES : LR_SPGCD FOR ZPPT0107-SPGCD.
  RANGES : LR_DATE FOR SY-DATUM.

* 생산계획수량의 경우 각 생성품의 실제 조장 기간과 겹치지 않게 일자를 뒤로 조절해서 보여준다.
  READ TABLE GR_DATE INDEX 1.
  MOVE-CORRESPONDING GR_DATE TO LR_DATE.
  LR_DATE-LOW+4(2) = LR_DATE-LOW+4(2) + 1.
  LR_DATE-LOW = LR_DATE-LOW+0(6) && '01'.

  APPEND LR_DATE.

  IF S_DISPO[] IS NOT INITIAL.
    LR_SPGCD-SIGN = 'I'.
    LR_SPGCD-OPTION = 'EQ'.
    LR_SPGCD-LOW = S_DISPO-LOW+0(2).
  ENDIF.

  SELECT SINGLE * FROM ZGTPPT1010
    INTO @DATA(LS_1010)
   WHERE MODULE_KIND = 'PP'
     AND CODEGRP = '3060'
     AND FLD_01 = @P_WERKS
     AND FLD_02 IN @LR_SPGCD.

  IF SY-SUBRC EQ 0.
    READ TABLE LR_DATE ASSIGNING FIELD-SYMBOL(<LR_DATE>) INDEX 1.
*  현재월은 제외
    <LR_DATE>-LOW+4(2) = <LR_DATE>-LOW+4(2) + LS_1010-FLD_04.
    <LR_DATE>-LOW = <LR_DATE>-LOW+0(6) && '01'.

  ENDIF.

  SELECT A~WERKS,
             A~IDNRK AS MATNR,
             B~SPART,
             B~MATKL,
             D~WGBEZ,
             B~MTART,
             C~DISPO,
             C~EKGRP,
             E~EKNAM,
             CAST( 'D8' AS CHAR ) AS BDART,
             CAST( '월간계획확정소요' AS CHAR ) AS BDTXT,
             F~MAKTX,
             G~VTEXT,
             H~MTBEZ,
             I~DSNAM,
             A~BDMNG AS DMQTY,
             A~MEINS,
             A~BDTER
    FROM ZGTPPT2101 AS A
    INNER JOIN  MARA AS B ON B~MATNR = A~IDNRK
    INNER JOIN T023T AS D ON D~MATKL = B~MATKL
                            AND D~SPRAS = @SY-LANGU
    INNER JOIN  MARC AS C ON C~MATNR = A~IDNRK AND C~WERKS = A~WERKS
    INNER JOIN T024 AS E ON E~EKGRP = C~EKGRP
    LEFT OUTER JOIN MAKT  AS F ON F~MATNR EQ A~IDNRK
                              AND F~SPRAS EQ @SY-LANGU
    LEFT OUTER JOIN TSPAT AS G ON G~SPRAS EQ @SY-LANGU
                              AND G~SPART EQ B~SPART
    LEFT OUTER JOIN T134T AS H ON H~SPRAS EQ @SY-LANGU
                              AND H~MTART EQ B~MTART
    LEFT OUTER JOIN T024D AS I ON I~WERKS EQ A~WERKS
                              AND I~DISPO EQ C~DISPO
     WHERE A~WERKS = @P_WERKS
        AND C~DISPO IN @S_DISPO
        AND B~MTART IN @S_MTART
        AND C~EKGRP  IN @S_EKGRP
        AND A~IDNRK IN @S_MATNR
        AND A~BDTER  IN @LR_DATE
        AND A~BDMNG > 0
      INTO CORRESPONDING FIELDS OF TABLE @PT_CVDATA.

ENDFORM.
