*&---------------------------------------------------------------------*
*&  Include           ZNFR2200F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_RANGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_RANGES .

  CLEAR   : GR_ZFLAG, GR_BY_SL.
  REFRESH : GR_ZFLAG, GR_BY_SL.

*___Buy/Sell 구분
  IF P_CHK01 = 'X'.
    APPEND_RANGES GR_BY_SL 'I' 'EQ' 'B' ' '.
  ENDIF.

  IF P_CHK02 = 'X'.
    APPEND_RANGES GR_BY_SL 'I' 'EQ' 'S' ' '.
  ENDIF.

*___확인/미확인 구분
  CASE 'X'.
    WHEN P_R01.     "미확인
      APPEND_RANGES : GR_ZFLAG 'I' 'EQ' 'F' ' '.

    WHEN P_R02.     "확인
      APPEND_RANGES : GR_ZFLAG 'I' 'EQ' 'Y' ' '.

    WHEN P_R03.     "전체

  ENDCASE.

ENDFORM.                    " SET_RANGES
*&---------------------------------------------------------------------*
*&      Form  GET_EPRO_IF_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_EPRO_IF_DATA .

  CLEAR   : GT_MAIN, GT_0074, GT_1021.
  REFRESH : GT_MAIN, GT_0074, GT_1021.

*___e-Pro I/F 데이터
  IF P_R02 <> 'X'.
    SELECT *
      INTO TABLE GT_0074
      FROM ZNFT0074
     WHERE BUKRS =  P_BUKRS
       AND FCM   IN S_FCM
       AND RUDAT IN S_RUDAT
       AND BY_SL IN GR_BY_SL
       AND NFKEY IN S_NFKEY
       AND ZFLAG IN GR_ZFLAG.
  ENDIF.

*___확인된 데이터
  IF P_R01 <> 'X'.
    SELECT *
      INTO TABLE GT_1021
      FROM ZNFT1021
     WHERE BUKRS =  P_BUKRS
       AND FCM   IN S_FCM
       AND RUDAT IN S_RUDAT
       AND BY_SL IN GR_BY_SL
       AND NFKEY IN S_NFKEY.
  ENDIF.

  CASE 'X'.
    WHEN P_R01.            "미확인
      LOOP AT GT_0074.
        CLEAR : GT_MAIN.

        MOVE-CORRESPONDING GT_0074 TO GT_MAIN.

        APPEND GT_MAIN.
      ENDLOOP.

    WHEN P_R02.            "확인
      LOOP AT GT_1021.
        CLEAR : GT_MAIN.

        MOVE-CORRESPONDING GT_1021 TO GT_MAIN.

        GT_MAIN-ZFLAG = 'Y'.

        APPEND GT_MAIN.
      ENDLOOP.

    WHEN P_R03.            "전체
      LOOP AT GT_0074.
        CLEAR : GT_MAIN.

        IF GT_0074-ZFLAG = 'Y'.
*___확인된 데이터인 경우
          READ TABLE GT_1021 WITH KEY BUKRS = GT_0074-BUKRS
                                      ZEPRO = GT_0074-ZEPRO.
          IF SY-SUBRC = 0.
            MOVE-CORRESPONDING GT_1021 TO GT_MAIN.

            GT_MAIN-ZFLAG = 'Y'.
          ELSE.
            MOVE-CORRESPONDING GT_0074 TO GT_MAIN.
          ENDIF.
        ELSE.
          MOVE-CORRESPONDING GT_0074 TO GT_MAIN.
        ENDIF.

        APPEND GT_MAIN.
      ENDLOOP.

  ENDCASE.

  LOOP AT GT_MAIN.
    IF GT_MAIN-WAERS IS INITIAL.
      GT_MAIN-WAERS = 'USD'.
    ENDIF.

    IF GT_MAIN-MEINS IS INITIAL.
      GT_MAIN-MEINS = 'TON'.
    ENDIF.

*___처리유형 텍스트
    IF GT_MAIN-ZFLAG = 'Y'.
      GT_MAIN-ZCOMP = '확인'.
    ELSE.
      GT_MAIN-ZCOMP = '미확인'.
    ENDIF.

*___FCM 명
    PERFORM GET_LIFNR_DESC USING GT_MAIN-FCM
                                 GT_MAIN-NAME1.

    MODIFY GT_MAIN.
  ENDLOOP.

  GV_CURSOR    = 'GT_MAIN-BY_SL'.
  GV_CURLIN    = 1.
  TC1-TOP_LINE = 1.

ENDFORM.                    " GET_EPRO_IF_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SELECT_ALL .

  IF OK_SAVE = 'ASEL'.
    GT_MAIN-CHECK = 'X'.
  ELSE.
    CLEAR : GT_MAIN-CHECK.
  ENDIF.

  MODIFY GT_MAIN TRANSPORTING CHECK
                 WHERE ZFLAG <> 'Y'.

ENDFORM.                    " SET_SELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  SAVE_CONFIRM_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_CONFIRM_DATA .
  DATA: LV_FLAG.

  PERFORM CHECK_CONFIRM_DATA USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '저장'
                                 '저장하시겠습니까?'
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
    CLEAR   : GT_1021.
    REFRESH : GT_1021.

    LOOP AT GT_MAIN WHERE CHECK = 'X'.
      CLEAR : GT_1021.

      MOVE-CORRESPONDING GT_MAIN TO GT_1021.

      GT_1021-ERNAM = SY-UNAME.
      GT_1021-ERDAT = SY-DATLO.
      GT_1021-ERZET = SY-TIMLO.
      GT_1021-AENAM = SY-UNAME.
      GT_1021-AEDAT = SY-DATLO.
      GT_1021-AEZET = SY-TIMLO.

      APPEND GT_1021.
    ENDLOOP.

    INSERT ZNFT1021 FROM TABLE GT_1021.
    IF SY-SUBRC = 0.
      CLEAR : LV_FLAG.

      LOOP AT GT_1021.
        UPDATE ZNFT0074 SET ZFLAG = 'Y'
                            AENAM = SY-UNAME
                            AEDAT = SY-DATLO
                            AEZET = SY-TIMLO
                      WHERE BUKRS = GT_1021-BUKRS
                        AND ZEPRO = GT_1021-ZEPRO.
        IF SY-SUBRC <> 0.
          LV_FLAG = 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LV_FLAG IS INITIAL.
        COMMIT WORK.

        MESSAGE S003 WITH '저장되었습니다.'.

        PERFORM GET_EPRO_IF_DATA.
      ELSE.
        ROLLBACK WORK.

        MESSAGE S003 DISPLAY LIKE 'E'
           WITH 'e-Pro I/F Data Update Error!'.
      ENDIF.
    ELSE.
      ROLLBACK WORK.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '선물집행정보 Insert Error!'.
    ENDIF.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " SAVE_CONFIRM_DATA
*&---------------------------------------------------------------------*
*&      Form  CHECK_CONFIRM_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_CONFIRM_DATA  USING    PV_ERROR.

  CLEAR : PV_ERROR.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    IF GT_MAIN-MITYP = 'A' AND GT_MAIN-MIMON IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_MAIN-MIMON'.
      GV_CURLIN    = 1.

      MESSAGE S001 DISPLAY LIKE 'E'
         WITH '집행유형이 ''A''인 경우 기준월을 입력해야 합니다.'.

      EXIT.
    ENDIF.

    IF GT_MAIN-MITYP = 'S' AND GT_MAIN-PRICE IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_MAIN-PRICE'.
      GV_CURLIN    = 1.

      MESSAGE S001 DISPLAY LIKE 'E'
         WITH '집행유형이 ''S''인 경우 집행단가를 입력해야 합니다.'.

      EXIT.
    ENDIF.
  ENDLOOP.

  IF SY-SUBRC <> 0.
    PV_ERROR = 'X'.

    MESSAGE S001 DISPLAY LIKE 'E'
       WITH '선택된 라인이 없습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_CONFIRM_DATA
*&---------------------------------------------------------------------*
*&      Form  F4HELP_FCM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_FCM  USING    PV_FCM.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX, GV_INDEX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_FCM.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_FCM.

*___화면상의 회사코드를 읽는다.
  SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = 'ZNFR2200'
      DYNUMB     = '1000'
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  READ TABLE SCR_FIELDS WITH KEY FIELDNAME = 'P_BUKRS'.
  P_BUKRS = SCR_FIELDS-FIELDVALUE.

  IF P_BUKRS IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '회사코드를 입력하시기 바랍니다.'.
    EXIT.
  ENDIF.

  SELECT A~LIFNR
         B~NAME1
    INTO TABLE GT_FCM
    FROM ZNFT0021 AS A
   INNER JOIN LFA1 AS B
      ON A~LIFNR = B~LIFNR
   WHERE A~BUKRS = P_BUKRS
     AND B~LOEVM = ' '.

  IF SY-SUBRC <> 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH 'FCM 정보가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZNFT0021'.
  IT_FIELDS-FIELDNAME  = 'LIFNR'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'LFA1'.
  IT_FIELDS-FIELDNAME  = 'NAME1'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD                  = SELECTFIELD
    IMPORTING
      IND                          = LD_TABIX
      SELECT_VALUE                 = SELECT_VALUE
    TABLES
      FIELDS                       = IT_FIELDS
      FULL_TABLE                   = GT_FCM
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_FCM INDEX LD_TABIX.
  IF SY-SUBRC = 0.
    PV_FCM = GT_FCM-LIFNR.
  ENDIF.

ENDFORM.                    " F4HELP_FCM
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_CHECKBOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_CHECKBOX  USING    PV_ERROR.

  CLEAR : PV_ERROR.

  IF P_CHK01 IS INITIAL AND P_CHK02 IS INITIAL.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH 'Buy/Sell 구분을 선택하시기 바랍니다.'.

    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_CHECKBOX
