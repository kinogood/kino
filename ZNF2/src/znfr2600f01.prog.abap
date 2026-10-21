*&---------------------------------------------------------------------*
*&  Include           ZNFR2600F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F4HELP_FCM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_FCM  USING    PV_FCM.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX, LV_INDEX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_FCM.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_FCM.

*___화면상의 회사코드를 읽는다.
  IF SY-DYNNR = '1000'.
    SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
    APPEND SCR_FIELDS.

    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        DYNAME     = 'ZNFR2600'
        DYNUMB     = '1000'
      TABLES
        DYNPFIELDS = SCR_FIELDS.

    READ TABLE SCR_FIELDS WITH KEY FIELDNAME = 'P_BUKRS'.
    P_BUKRS = SCR_FIELDS-FIELDVALUE.
  ENDIF.

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
*&      Form  F4HELP_NFCTR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_NFCTR  USING    PV_NFCTR.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_NFCTR.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_NFCTR.

*___화면상의 회사코드를 읽는다.
  SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = 'ZNFR2600'
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

  SELECT NFCTR
         NTEXT
    INTO TABLE GT_NFCTR
    FROM ZNFT0005
   WHERE BUKRS = P_BUKRS.   "회사코드

  IF SY-SUBRC <> 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '회사코드' P_BUKRS
            '에 해당하는 사업부가 없습니다.'.
    EXIT.
  ENDIF.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZNFT0005'.
  IT_FIELDS-FIELDNAME  = 'NFCTR'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT0005'.
  IT_FIELDS-FIELDNAME  = 'NTEXT'.
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
      FULL_TABLE                   = GT_NFCTR
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_NFCTR INDEX LD_TABIX.
  IF SY-SUBRC = 0.
    PV_NFCTR = GT_NFCTR-NFCTR.
  ENDIF.

ENDFORM.                    " F4HELP_NFCTR
*&---------------------------------------------------------------------*
*&      Form  F4HELP_PRCTR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_PRCTR  USING    PV_PRCTR.
  RANGES: LR_NFCTR  FOR  ZNFT1000-NFCTR.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_PRCTR,
             LR_NFCTR.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_PRCTR,
            LR_NFCTR.

  LR_NFCTR[] = S_NFCTR[].

*___화면상의 데이터를 읽는다.
  SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'S_NFCTR-LOW'.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'S_NFCTR-HIGH'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = 'ZNFR2600'
      DYNUMB     = '1000'
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  LOOP AT SCR_FIELDS.
    CASE SCR_FIELDS-FIELDNAME.
      WHEN 'P_BUKRS'.
        P_BUKRS      = SCR_FIELDS-FIELDVALUE.
      WHEN 'S_NFCTR-LOW'.
        LR_NFCTR-LOW  = SCR_FIELDS-FIELDVALUE.
        PERFORM CONVERSION_EXIT_ALPHA USING 'I' LR_NFCTR-LOW.
      WHEN 'S_NFCTR-HIGH'.
        LR_NFCTR-HIGH = SCR_FIELDS-FIELDVALUE.
        PERFORM CONVERSION_EXIT_ALPHA USING 'I' LR_NFCTR-HIGH.
    ENDCASE.
  ENDLOOP.

  READ TABLE LR_NFCTR INDEX 1 TRANSPORTING SIGN.
  IF SY-SUBRC = 0.
    IF LR_NFCTR-LOW  IS NOT INITIAL OR
       LR_NFCTR-HIGH IS NOT INITIAL.
      IF LR_NFCTR-HIGH IS NOT INITIAL.
        LR_NFCTR-OPTION = 'BT'.
      ELSE.
        LR_NFCTR-OPTION = 'EQ'.
      ENDIF.

      MODIFY LR_NFCTR INDEX 1.
    ELSE.
      DELETE LR_NFCTR INDEX 1.
    ENDIF.
  ELSE.
    IF LR_NFCTR-LOW  IS NOT INITIAL OR
       LR_NFCTR-HIGH IS NOT INITIAL.
      IF LR_NFCTR-HIGH IS NOT INITIAL.
        LR_NFCTR-SIGN   = 'I'.
        LR_NFCTR-OPTION = 'BT'.
        APPEND LR_NFCTR.
      ELSE.
        LR_NFCTR-SIGN   = 'I'.
        LR_NFCTR-OPTION = 'EQ'.
        APPEND LR_NFCTR.
      ENDIF.
    ENDIF.
  ENDIF.

  SELECT PRCTR
*         PTEXT
    INTO CORRESPONDING FIELDS OF TABLE GT_PRCTR
    FROM ZNFT0004
   WHERE KOKRS   =  P_BUKRS   "관리회계영역
     AND NFCTR   IN LR_NFCTR  "사업부
     AND BDATU  >=  SY-DATLO  "효력만료일
     AND CFACTIV =  'X'.      "선물요청(활성)

  IF SY-SUBRC <> 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '손익센터가 없습니다.'.
    EXIT.
  ENDIF.

  LOOP AT GT_PRCTR.
    PERFORM GET_PRCTR_DESC USING P_BUKRS
                                 GT_PRCTR-PRCTR
                                 GT_PRCTR-PTEXT.
    MODIFY GT_PRCTR.
  ENDLOOP.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZNFT0004'.
  IT_FIELDS-FIELDNAME  = 'PRCTR'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT0004'.
  IT_FIELDS-FIELDNAME  = 'PTEXT'.
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
      FULL_TABLE                   = GT_PRCTR
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_PRCTR INDEX LD_TABIX.
  IF SY-SUBRC = 0.
    PV_PRCTR = GT_PRCTR-PRCTR.
  ENDIF.

ENDFORM.                    " F4HELP_PRCTR
*&---------------------------------------------------------------------*
*&      Form  F4HELP_VKGRP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_VKGRP  USING    PV_VKGRP.
  RANGES: LR_PRCTR  FOR  ZNFT1000-PRCTR.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_VKGRP,
            LR_PRCTR.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_VKGRP,
            LR_PRCTR.

  LR_PRCTR[] = S_PRCTR[].

*___화면상의 데이터를 읽는다.
  SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'S_PRCTR-LOW'.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'S_PRCTR-HIGH'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = 'ZNFR2600'
      DYNUMB     = '1000'
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  LOOP AT SCR_FIELDS.
    CASE SCR_FIELDS-FIELDNAME.
      WHEN 'P_BUKRS'.
        P_BUKRS       = SCR_FIELDS-FIELDVALUE.
      WHEN 'S_PRCTR-LOW'.
        LR_PRCTR-LOW  = SCR_FIELDS-FIELDVALUE.
        PERFORM CONVERSION_EXIT_ALPHA USING 'I' LR_PRCTR-LOW.
      WHEN 'S_PRCTR-HIGH'.
        LR_PRCTR-HIGH = SCR_FIELDS-FIELDVALUE.
        PERFORM CONVERSION_EXIT_ALPHA USING 'I' LR_PRCTR-HIGH.
    ENDCASE.
  ENDLOOP.

  READ TABLE LR_PRCTR INDEX 1 TRANSPORTING SIGN.
  IF SY-SUBRC = 0.
    IF LR_PRCTR-LOW  IS NOT INITIAL OR
       LR_PRCTR-HIGH IS NOT INITIAL.
      IF LR_PRCTR-HIGH IS NOT INITIAL.
        LR_PRCTR-OPTION = 'BT'.
      ELSE.
        LR_PRCTR-OPTION = 'EQ'.
      ENDIF.

      MODIFY LR_PRCTR INDEX 1.
    ELSE.
      DELETE LR_PRCTR INDEX 1.
    ENDIF.

  ELSE.
    IF LR_PRCTR-LOW  IS NOT INITIAL OR
       LR_PRCTR-HIGH IS NOT INITIAL.
      IF LR_PRCTR-HIGH IS NOT INITIAL.
        LR_PRCTR-SIGN   = 'I'.
        LR_PRCTR-OPTION = 'BT'.
        APPEND LR_PRCTR.
      ELSE.
        LR_PRCTR-SIGN   = 'I'.
        LR_PRCTR-OPTION = 'EQ'.
        APPEND LR_PRCTR.
      ENDIF.
    ENDIF.
  ENDIF.

  SELECT VKGRP
*         VTEXT
    INTO CORRESPONDING FIELDS OF TABLE GT_VKGRP
    FROM ZNFT0003
   WHERE KOKRS =  P_BUKRS    "회사코드
     AND PRCTR IN LR_PRCTR.  "손익센터

  IF SY-SUBRC <> 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '사업부가 없습니다.'.
    EXIT.
  ENDIF.

  LOOP AT GT_VKGRP.
    PERFORM GET_VKGRP_DESC USING P_BUKRS
                                 GT_VKGRP-VKGRP
                                 GT_VKGRP-VTEXT.

    MODIFY GT_VKGRP.
  ENDLOOP.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZNFT0003'.
  IT_FIELDS-FIELDNAME  = 'VKGRP'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT0003'.
  IT_FIELDS-FIELDNAME  = 'VTEXT'.
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
      FULL_TABLE                   = GT_VKGRP
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_VKGRP INDEX LD_TABIX.
  IF SY-SUBRC = 0.
    PV_VKGRP = GT_VKGRP-VKGRP.
  ENDIF.

ENDFORM.                    " F4HELP_VKGRP
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_CHECKBOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_CHECKBOX  USING    PV_ERROR.

  CLEAR : PV_ERROR.

  IF S_NFUTN[] IS NOT INITIAL AND S_CFUTN[] IS INITIAL.
    CLEAR : P_CHK12.

    P_CHK11 = 'X'.
  ENDIF.

  IF S_CFUTN[] IS NOT INITIAL AND S_NFUTN[] IS INITIAL.
    CLEAR : P_CHK11.

    P_CHK12 = 'X'.
  ENDIF.

  IF S_NFUTN[] IS NOT INITIAL AND S_CFUTN[] IS NOT INITIAL.
    P_CHK11 = 'X'.
    P_CHK12 = 'X'.
  ENDIF.

  IF P_CHK01 IS INITIAL AND P_CHK02 IS INITIAL.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH 'Buy/Sell 구분을 선택하시기 바랍니다.'.

    EXIT.
  ENDIF.

  IF P_CHK11 IS INITIAL AND P_CHK12 IS INITIAL.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '신규/청산 구분을 선택하시기 바랍니다.'.

    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_CHECKBOX
*&---------------------------------------------------------------------*
*&      Form  SET_RANGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_RANGES .

  CLEAR   : GR_BY_SL, GR_YNCAN, GR_YNFIN.
  REFRESH : GR_BY_SL, GR_YNCAN, GR_YNFIN.

*___Buy/Sell 구분
  IF P_CHK01 = 'X'.
    APPEND_RANGES : GR_BY_SL 'I' 'EQ' 'B' ' '.
  ENDIF.

  IF P_CHK02 = 'X'.
    APPEND_RANGES : GR_BY_SL 'I' 'EQ' 'S' ' '.
  ENDIF.

*___취소여부
  CASE 'X'.
    WHEN P_R01.
      APPEND_RANGES : GR_YNCAN 'I' 'EQ' 'X' ' '.

    WHEN P_R02.
      APPEND_RANGES : GR_YNCAN 'I' 'EQ' ' ' ' '.

  ENDCASE.

*___정산여부
  CASE 'X'.
    WHEN P_R11.
      APPEND_RANGES : GR_YNFIN 'I' 'EQ' 'X' ' '.

    WHEN P_R12.
      APPEND_RANGES : GR_YNFIN 'I' 'EQ' ' ' ' '.

  ENDCASE.

*___넷팅여부
  CASE 'X'.
    WHEN P_R21.
      APPEND_RANGES : GR_YNNET 'I' 'EQ' 'X' ' '.

    WHEN P_R22.
      APPEND_RANGES : GR_YNNET 'I' 'EQ' ' ' ' '.

  ENDCASE.

ENDFORM.                    " SET_RANGES
*&---------------------------------------------------------------------*
*&      Form  GET_FUTURES_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FUTURES_DATA .

  CLEAR   : GT_MAIN.
  REFRESH : GT_MAIN.

  IF P_CHK11 = 'X' AND P_R21 <> 'X'.
*___신규선물집행
    PERFORM GET_ZNFT1020_DATA.
  ENDIF.

  IF P_CHK12 = 'X'.
*___청산선물집행
    PERFORM GET_ZNFT1030_DATA.
  ENDIF.

ENDFORM.                    " GET_FUTURES_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_ZNFT1020_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ZNFT1020_DATA .

  CLEAR   : GT_1020.
  REFRESH : GT_1020.

  SELECT *
    INTO TABLE GT_1020
    FROM ZNFT1020
   WHERE BUKRS =  P_BUKRS
     AND NFUTN IN S_NFUTN
     AND FCM   IN S_FCM
     AND RUDAT IN S_RUDAT
     AND ENDAT IN S_ENDAT
     AND NFKEY IN S_NFKEY
     AND BY_SL IN GR_BY_SL
     AND REQNO IN S_REQNO
     AND YNCAN IN GR_YNCAN
     AND YNFIN IN GR_YNFIN.

  LOOP AT GT_1020.
    CLEAR : GT_MAIN.

    MOVE-CORRESPONDING GT_1020 TO GT_MAIN.

    GT_MAIN-NCIND = '신규'.

*___계약/선물요청 정보
    PERFORM GET_CONTRACT_INFO USING GT_MAIN.

    IF NOT GT_MAIN-CONNO IN S_CONNO OR
       NOT GT_MAIN-NFCTR IN S_NFCTR OR
       NOT GT_MAIN-PRCTR IN S_PRCTR OR
       NOT GT_MAIN-VKGRP IN S_VKGRP.
      DELETE GT_1020.
      CONTINUE.
    ENDIF.

    PERFORM GET_OTHER_DATA USING GT_MAIN.

    APPEND GT_MAIN.
  ENDLOOP.

ENDFORM.                    " GET_ZNFT1020_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_PROFIT_FI_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_PROFIT_FI_DOC  USING    PV_NCIND
                                 PV_NFUTN
                                 PV_CFUTN
                                 PV_GJAHR
                                 PV_BELNR.
  DATA: LV_NFUTN LIKE ZNFT1051-NFUTN,
        LV_CFUTN LIKE ZNFT1051-CFUTN.

  CLEAR : PV_GJAHR, PV_BELNR.

  CHECK PV_NFUTN IS NOT INITIAL AND
        PV_CFUTN IS NOT INITIAL.

*--> [CHM2507-00010] GV_TYPE 구분
**** GV_TYPE = 연결이력조회 구분자 (N:신규, C:청산)
  IF GV_TYPE IS INITIAL.
    IF PV_NCIND = '신규'.
      LV_NFUTN = PV_NFUTN.
      LV_CFUTN = PV_CFUTN.
    ELSE.
      LV_NFUTN = PV_CFUTN.
      LV_CFUTN = PV_NFUTN.
    ENDIF.
  ELSE.
    LV_NFUTN = PV_NFUTN.
    LV_CFUTN = PV_CFUTN.
  ENDIF.
*<-- [CHM2507-00010] GV_TYPE 구분

  SELECT SINGLE GJAHR
                BELNR
    INTO (PV_GJAHR, PV_BELNR)
    FROM ZNFT1051
   WHERE NFUTN = LV_NFUTN
     AND CFUTN = LV_CFUTN.

ENDFORM.                    " GET_PROFIT_FI_DOC
*&---------------------------------------------------------------------*
*&      Form  GET_ZNFT1030_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ZNFT1030_DATA .
  DATA: LV_ERROR.

  CLEAR   : GT_1030.
  REFRESH : GT_1030.

  SELECT *
    INTO TABLE GT_1030
    FROM ZNFT1030
   WHERE BUKRS =  P_BUKRS
     AND CFUTN IN S_CFUTN
     AND FCM   IN S_FCM
     AND RUDAT IN S_RUDAT
     AND ENDAT IN S_ENDAT
     AND NFKEY IN S_NFKEY
     AND BY_SL IN GR_BY_SL
     AND YNCAN IN GR_YNCAN
     AND YNFIN IN GR_YNFIN
     AND YNNET IN GR_YNNET.

  LOOP AT GT_1030.
    CLEAR : GT_MAIN.

    MOVE-CORRESPONDING GT_1030 TO GT_MAIN.

    GT_MAIN-NCIND  = '청산'.
    GT_MAIN-NFUTN  = GT_1030-CFUTN.
    GT_MAIN-CFUTN  = GT_1030-NFUTN.

*___계약/선물요청 정보
    SELECT SINGLE C~CONNO   "계약번호
                  C~COTXT   "계약명
                  C~KUNNR   "고객코드
                  C~NCUST   "고객명
                  C~NFCTR   "사업부
                  C~PRCTR   "손익센터
                  C~VKGRP   "영업그룹
                  B~REQNO   "선물요청번호
                  B~H_NO1   "선물요청항번
                  B~ENDMM   "만기월
                  B~EMENG   "요청수량
                  B~MEINS   "단위
                  D~RQTYP   "요청유형
      INTO (GT_MAIN-CONNO,  GT_MAIN-COTXT,
            GT_MAIN-KUNNR,  GT_MAIN-NCUST,
            GT_MAIN-NFCTR,  GT_MAIN-PRCTR,
            GT_MAIN-VKGRP,  GT_MAIN-REQNO,
            GT_MAIN-H_NO1,  GT_MAIN-ENDMM,
            GT_MAIN-REQTY,  GT_MAIN-REQME,
            GT_MAIN-RQTYP)
      FROM ZNFT1020 AS A
     INNER JOIN ZNFT1011 AS B
        ON A~REQNO = B~REQNO
       AND A~H_NO1 = B~H_NO1
     INNER JOIN ZNFT1000 AS C
        ON B~CONNO = C~CONNO
     INNER JOIN ZNFT1010 AS D
        ON A~REQNO = D~REQNO
     WHERE A~NFUTN = GT_1030-NFUTN.

    IF NOT GT_MAIN-CONNO IN S_CONNO OR
       NOT GT_MAIN-REQNO IN S_REQNO OR
       NOT GT_MAIN-NFCTR IN S_NFCTR OR
       NOT GT_MAIN-PRCTR IN S_PRCTR OR
       NOT GT_MAIN-VKGRP IN S_VKGRP.
      DELETE GT_1030.
      CONTINUE.
    ENDIF.

    PERFORM GET_OTHER_DATA USING GT_MAIN.

    APPEND GT_MAIN.
  ENDLOOP.

ENDFORM.                    " GET_ZNFT1030_DATA
*&---------------------------------------------------------------------*
*&      Form  DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING  E_ROW    TYPE LVC_S_ROW
                          E_COLUMN TYPE LVC_S_COL.

  READ TABLE GT_MAIN INDEX E_ROW-INDEX.
  IF SY-SUBRC = 0.
    CASE E_COLUMN-FIELDNAME.
      WHEN 'CONNO'.
        IF GT_MAIN-CONNO IS NOT INITIAL.
          SET PARAMETER ID 'ZNFCON' FIELD GT_MAIN-CONNO.

          CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
        ENDIF.

      WHEN 'REQNO'.
        IF GT_MAIN-REQNO IS NOT INITIAL.
          SET PARAMETER ID 'ZNFREQ' FIELD GT_MAIN-REQNO.

          CALL TRANSACTION 'ZNF2M2103' AND SKIP FIRST SCREEN.
        ENDIF.

      WHEN 'GJAHR' OR 'BELNR'.
        IF GT_MAIN-GJAHR IS NOT INITIAL AND
           GT_MAIN-BELNR IS NOT INITIAL.
          SET PARAMETER ID 'BLN' FIELD GT_MAIN-BELNR.
          SET PARAMETER ID 'BUK' FIELD GT_MAIN-BUKRS.
          SET PARAMETER ID 'GJR' FIELD GT_MAIN-GJAHR.

          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
        ENDIF.

      WHEN 'CFUTN'.
        IF GT_MAIN-CFUTN IS NOT INITIAL.
          PERFORM DISPLAY_FUTRUES_HISTORY.
        ENDIF.

    ENDCASE.
  ENDIF.

ENDFORM.                    " DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_LAYO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_LAYO .

  CLEAR : GS_LAYOUT.

*  gs_layout-grid_title = '~'.
*  gs_layout-smalltitle = 'X'.
*  gs_layout-NO_HEADERS = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
*  GS_LAYOUT-EDIT       = 'X'.
  GS_LAYOUT-ZEBRA      = 'X'.
  GS_LAYOUT-SMALLTITLE = 'X'.
  GS_LAYOUT-SEL_MODE   = 'A'.              "select multiple lines
*  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
*  GS_LAYOUT-CTAB_FNAME = 'F_COL'.

ENDFORM.                    " SET_GRID_LAYO
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FCAT_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_FCAT_1 .

  CLEAR   : GS_FIELDCAT, GV_POS.
  REFRESH : GT_FIELDCAT.

  GV_ITAB = 'GT_MAIN'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT
                                  USING :
      'BUKRS'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      ' '            'BUKRS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'NFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '            'NFUTN'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

***
      'MCTYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '만기이동'     ' '      ' '         ' ' ' ' 'X' ' ' ' ' ' ',
***
      'NCIND'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      '구분'         ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'YNCAN'    ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 4
      ' '            'YNCAN'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'WHYCN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'WHYCN'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'WHYTX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '취소사유내역' ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'CONFM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      ' '            'CONFM'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'CFMTX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '결재상태내역' ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'YNFIN'    ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 1
      ' '            'YNFIN'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'YNNET'    ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 1
      ' '            'YNNET'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'GJAHR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      ' '            'GJAHR'  'ZNFT1051'  ' ' ' '    'X' ' ' ' ' ' ',

      'BELNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '손익전표번호' 'BELNR'  'ZNFT1051'  ' ' ' '    'X' ' ' ' ' ' ',

      'RUDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'RUDAT'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'FCM'      ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'FCM'    'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'NAME1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      'FCM 명'       'NAME1'  'LFA1'      ' ' ' '    'X' ' ' ' ' ' ',

      'BY_SL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      ' '            'BY_SL'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'BSTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      'Buy/Sell'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'ENDAT'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'MITYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      ' '            'MITYP'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'MITPT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '집행유형'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'MISPD'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '            'MISPD'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' ' ',

      'MIMON'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '            'MIMON'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRICE'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '            'PRICE'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' ' ',

      'TOTAL'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '집행금액'     'PRICE'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' ' ',

      'WAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      ' '            'WAERS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '            'EMENG'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'MEINS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'MISUS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'MISUS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'NFKEY'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'CFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '연결선물집행번호' 'NFUTN' 'ZNFT1020' ' ' ' '  'X' ' ' ' ' ' ',

      'REQNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'REQNO'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'H_NO1'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 5
      ' '            'H_NO1'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'ENDMM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '            'ENDMM'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'REQTY'    ' '      'REQME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '            'EMENG'  'ZNFT1011'  ' ' ' '    ' ' ' ' ' ' ' ',

      'REQME'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'MEINS'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'RQTYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      ' '            'RQTYP'  'ZNFT1010'  ' ' ' '    'X' ' ' ' ' ' ',

      'RQTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '요청유형'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'CONNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'CONNO'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'COTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '            'COTXT'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'NFCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 10
      ' '            'NFCTR'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'NTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 20
      ' '            'NTEXT'  'ZNFT0005'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 10
      ' '            'PRCTR'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'PTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '손익센터명'   'PTEXT'  'ZNFT0004'  ' ' ' '    'X' ' ' ' ' ' ',

      'VKGRP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 3
      ' '            'VKGRP'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'VTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 20
      ' '            'VTEXT'  'ZNFT0003'  ' ' ' '    'X' ' ' ' ' ' ',

      'KUNNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 10
      ' '            'KUNNR'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'NCUST'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '            'NCUST'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRIND'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 15
      '가격구분'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'SUJUP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 12
      '비철수주가'   ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' '.

ENDFORM.                    " SET_GRID_FCAT_1
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FCAT_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_FCAT_2.

  CLEAR   : GS_FIELDCAT, GV_POS.
  REFRESH : GT_FIELDCAT.

  GV_ITAB = 'GT_HIST'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT
                                  USING :
*      'NFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
*      '신규선물집행번호' 'NFUTN' 'ZNFT1020' ' ' ' '  'X' ' ' ' ' ' ',

***박우진
      'MCTYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '만기이동'            'MCTYP'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

*** 박우진


      'YNCAN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      ' '            'YNCAN'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'WHYCN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'WHYCN'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'WHYTX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '취소사유내역' ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'CONFM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'CONFM'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'CFMTX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '결재상태내역' ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'YNFIN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'YNFIN'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'GJAHR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      ' '            'GJAHR'  'ZNFT1051'  ' ' ' '    'X' ' ' ' ' ' ',

      'BELNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '손익전표번호' 'BELNR'  'ZNFT1051'  ' ' ' '    'X' ' ' ' ' ' ',

      'RUDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'RUDAT'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'FCM'      ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'FCM'    'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'NAME1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      'FCM 명'       'NAME1'  'LFA1'      ' ' ' '    'X' ' ' ' ' ' ',

      'BY_SL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'BY_SL'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'ENDAT'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'MITYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'MITYP'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'MISPD'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '            'MISPD'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' ' ',

      'MIMON'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '            'MIMON'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRICE'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '            'PRICE'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' ' ',

      'WAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      ' '            'WAERS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '            'EMENG'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'MEINS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'MISUS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'MISUS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'NFKEY'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'CFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '청산선물집행번호' 'NFUTN' 'ZNFT1020' ' ' ' '  'X' ' ' ' ' ' ',

      'REQNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'REQNO'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'H_NO1'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 5
      ' '            'H_NO1'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'ENDMM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '            'ENDMM'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'REQTY'    ' '      'REQME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '            'EMENG'  'ZNFT1011'  ' ' ' '    ' ' ' ' ' ' ' ',

      'REQME'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'MEINS'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'RQTYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'RQTYP'  'ZNFT1010'  ' ' ' '    'X' ' ' ' ' ' ',

      'CONNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'CONNO'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'COTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '            'COTXT'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'KUNNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 10
      ' '            'KUNNR'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'NCUST'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '            'NCUST'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRIND'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 15
      '가격구분'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'SUJUP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 12
      '비철수주가'   ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' '.

ENDFORM.                    " SET_GRID_FCAT_2
*&---------------------------------------------------------------------*
*&      Form  MAKE_LVC_FIELDCAT_DATA
*&---------------------------------------------------------------------*
* 필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
* TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
*----------------------------------------------------------------------*
FORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT TYPE LVC_T_FCAT
                             USING PV_FNAME
                                   PV_CURK
                                   PV_UNIT
                                   PV_ICON
                                   PV_CHECK
                                   PV_JUST
                                   PV_EMPHA
                                   PV_FIX
                                   PV_NOOUT
                                   PV_NOZERO
                                   PV_LENGTH
                                   PV_TEXT
                                   PV_REFF
                                   PV_REFT
                                   PV_TECH
                                   PV_TYPE
                                   PV_NOSUM
                                   PV_DOSUM
                                   PV_HOTSPOT
                                   PV_EDIT.

  CLEAR : GS_FIELDCAT.

  GV_POS = GV_POS + 1.

  GS_FIELDCAT-COL_POS        = GV_POS.
  GS_FIELDCAT-FIELDNAME      = PV_FNAME.
  GS_FIELDCAT-CFIELDNAME     = PV_CURK.
  GS_FIELDCAT-QFIELDNAME     = PV_UNIT.
  GS_FIELDCAT-ICON           = PV_ICON.
  GS_FIELDCAT-CHECKBOX       = PV_CHECK.
  GS_FIELDCAT-JUST           = PV_JUST.
  GS_FIELDCAT-EMPHASIZE      = PV_EMPHA.
  GS_FIELDCAT-FIX_COLUMN     = PV_FIX.
  GS_FIELDCAT-KEY            = PV_FIX.
  GS_FIELDCAT-NO_OUT         = PV_NOOUT.
  GS_FIELDCAT-NO_ZERO        = PV_NOZERO.
  GS_FIELDCAT-OUTPUTLEN      = PV_LENGTH.
  GS_FIELDCAT-COLTEXT        = PV_TEXT.
  GS_FIELDCAT-SCRTEXT_S      = PV_TEXT.
  GS_FIELDCAT-SCRTEXT_M      = PV_TEXT.
  GS_FIELDCAT-SCRTEXT_L      = PV_TEXT.
  GS_FIELDCAT-REPTEXT        = PV_TEXT.
  GS_FIELDCAT-REF_FIELD      = PV_REFF.
  GS_FIELDCAT-REF_TABLE      = PV_REFT.
  GS_FIELDCAT-TECH           = PV_TECH.
  GS_FIELDCAT-DATATYPE       = PV_TYPE.
  GS_FIELDCAT-NO_SUM         = PV_NOSUM.
  GS_FIELDCAT-DO_SUM         = PV_DOSUM.
  GS_FIELDCAT-HOTSPOT        = PV_HOTSPOT.
  GS_FIELDCAT-EDIT           = PV_EDIT.

  GS_FIELDCAT-TABNAME        = GV_ITAB.

  APPEND GS_FIELDCAT TO PT_FIELDCAT.

ENDFORM.                    " MAKE_LVC_FIELDCAT_DATA
*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS_1 CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.
  DATA : LS_EXCLUDE TYPE UI_FUNC.

  REFRESH : PT_EXCLUDE.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.

ENDFORM.                    " EXCLUDE_TB_FUNCTIONS_1
*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS_2 CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.
  DATA : LS_EXCLUDE TYPE UI_FUNC.

  REFRESH : PT_EXCLUDE.

  LS_EXCLUDE = CL_GUI_ALV_TREE=>MC_FC_CALCULATE.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.

ENDFORM.                    " EXCLUDE_TB_FUNCTIONS_2
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_1.

  CALL METHOD GC_ALV_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

*___Event Handler 등록
  CREATE OBJECT GC_EVENT_HANDLER.

  SET HANDLER GC_EVENT_HANDLER->HANDLE_DOUBLE_CLICK  FOR GC_ALV_GRID.

ENDFORM.                    " EVENT_HANDLER_REGISTER_1
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_2.
  DATA: LT_EVENTS TYPE CNTL_SIMPLE_EVENTS,
        LS_EVENT  TYPE CNTL_SIMPLE_EVENT.

  CALL METHOD GC_ALV_TREE->GET_REGISTERED_EVENTS
    IMPORTING
      EVENTS = LT_EVENTS.

  LS_EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_ITEM_DOUBLE_CLICK.
  APPEND LS_EVENT TO LT_EVENTS.

  CALL METHOD GC_ALV_TREE->SET_REGISTERED_EVENTS
    EXPORTING
      EVENTS                    = LT_EVENTS
    EXCEPTIONS
      CNTL_ERROR                = 1
      CNTL_SYSTEM_ERROR         = 2
      ILLEGAL_EVENT_COMBINATION = 3.

  IF SY-SUBRC <> 0.
    MESSAGE X208(00) WITH 'ERROR'.                          "#EC NOTEXT
  ENDIF.

*___Event Handler 등록
  CREATE OBJECT GC_TREE_EVENT_HANDLER.

  SET HANDLER GC_TREE_EVENT_HANDLER->HANDLE_ITEM_DOUBLE_CLICK
          FOR GC_ALV_TREE.

  "박우진 추가 (Tree ALV Excel Download 버튼용)
  SET HANDLER GC_TREE_EVENT_HANDLER->HANDLE_FUNCTION_SELECTED
        FOR GO_TOOLBAR.

ENDFORM.                    " EVENT_HANDLER_REGISTER_2
*&---------------------------------------------------------------------*
*&      Form  SET_TABLE_FOR_FIRST_DISPLAY_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_TABLE_FOR_FIRST_DISPLAY_1 .

  GS_VARIANT-HANDLE = '0001'.
  GS_VARIANT-REPORT = SY-REPID.

  CALL METHOD GC_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = GS_VARIANT
      IS_LAYOUT            = GS_LAYOUT
      I_SAVE               = 'A'
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
    CHANGING
      IT_FIELDCATALOG      = GT_FIELDCAT[]
      IT_SORT              = GT_SORT[]
      IT_OUTTAB            = GT_MAIN[].

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY_1
*&---------------------------------------------------------------------*
*&      Form  SET_TABLE_FOR_FIRST_DISPLAY_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_TABLE_FOR_FIRST_DISPLAY_2 .

  CLEAR : GS_VARIANT.

  GS_VARIANT-HANDLE = '0002'.
  GS_VARIANT-REPORT = SY-REPID.

  CALL METHOD GC_ALV_TREE->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_HIERARCHY_HEADER  = GS_HIERARCHY_HEADER
*     IT_LIST_COMMENTARY   = GT_LIST_COMMENTARY
      I_BACKGROUND_ID      = 'ALV_BACKGROUND'
      I_SAVE               = 'A'
      IS_VARIANT           = GS_VARIANT
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
    CHANGING
      IT_OUTTAB            = GT_HIST[]         "table must be empty !!
      IT_FIELDCATALOG      = GT_FIELDCAT[].

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY_2
*&---------------------------------------------------------------------*
*&      Form  SET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SELECTED_ROWS .

  REFRESH : GT_ROWS.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    CLEAR : GS_ROWS.
    GS_ROWS-INDEX = SY-TABIX.
    APPEND GS_ROWS TO GT_ROWS.
  ENDLOOP.

  IF GT_ROWS[] IS NOT INITIAL.
    CALL METHOD GC_ALV_GRID->SET_SELECTED_ROWS
      EXPORTING
        IT_INDEX_ROWS = GT_ROWS.
  ENDIF.

  IF GT_COLS[] IS NOT INITIAL.
    CALL METHOD GC_ALV_GRID->SET_SELECTED_COLUMNS
      EXPORTING
        IT_COL_TABLE = GT_COLS.
  ENDIF.

ENDFORM.                    " SET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_SELECTED_ROWS .

  CALL METHOD GC_ALV_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROWS.

  CLEAR : GT_MAIN-CHECK.
  MODIFY GT_MAIN TRANSPORTING CHECK
                 WHERE BUKRS IS NOT INITIAL.

  LOOP AT GT_ROWS INTO GS_ROWS.
    READ TABLE GT_MAIN INDEX GS_ROWS-INDEX.
    IF SY-SUBRC = 0.
      GT_MAIN-CHECK = 'X'.
      MODIFY GT_MAIN INDEX GS_ROWS-INDEX.
    ENDIF.
  ENDLOOP.

  CALL METHOD GC_ALV_GRID->GET_SELECTED_COLUMNS
    IMPORTING
      ET_INDEX_COLUMNS = GT_COLS.

ENDFORM.                    " GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_CHANGE_HISTORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_CHANGE_HISTORY .
  DATA: LT_RSPAR    LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

  DATA: LV_OBJCLS   LIKE CDHDR-OBJECTCLAS.

  PERFORM CHECK_SELECTED_ROWS USING 'S'
                                    GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  IF GT_MAIN-NCIND = '신규'.
    LV_OBJCLS = 'ZNFT1020CHDOC'.
  ELSE.
    LV_OBJCLS = 'ZNFT1030CHDOC'.
  ENDIF.

  SELECT SINGLE OBJECTCLAS
    INTO LV_OBJCLS
    FROM CDHDR
   WHERE OBJECTCLAS = LV_OBJCLS
     AND OBJECTID   = GT_MAIN-NFUTN.

  IF SY-SUBRC <> 0.
    MESSAGE S002 DISPLAY LIKE 'E'
       WITH '변경이력이 없습니다.'.

    EXIT.
  ENDIF.

  CLEAR   : LT_RSPAR.
  REFRESH : LT_RSPAR.

  LT_RSPAR-SELNAME = 'OBJEKT'.
  LT_RSPAR-KIND    = 'P'.
  LT_RSPAR-LOW     = LV_OBJCLS.
  APPEND LT_RSPAR.

  CLEAR : LT_RSPAR.
  LT_RSPAR-SELNAME = 'OBJEKTID'.
  LT_RSPAR-KIND    = 'P'.
  LT_RSPAR-LOW     = GT_MAIN-NFUTN.
  APPEND LT_RSPAR.

  CLEAR : LT_RSPAR.
  LT_RSPAR-SELNAME = 'AENDERER'.
  LT_RSPAR-KIND    = 'P'.
  LT_RSPAR-LOW     = ' '.
  APPEND LT_RSPAR.

  CLEAR : LT_RSPAR.
  LT_RSPAR-SELNAME = 'DATUM'.
  LT_RSPAR-KIND    = 'P'.
  LT_RSPAR-LOW     = ' '.
  APPEND LT_RSPAR.

*- 2023.11.28 ZLSGMM4, 변경이력 조회 Call 수정
*  SUBMIT RCS00120 WITH SELECTION-TABLE LT_RSPAR
*                   AND RETURN.

  SUBMIT RC1CD100 WITH SELECTION-TABLE LT_RSPAR
                  AND RETURN.
ENDFORM.                    " DISPLAY_CHANGE_HISTORY
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_ROWS  USING  PV_FLAG
                                 PV_ERROR.
  DATA: LV_CNT      TYPE I.

  CLEAR : PV_ERROR, LV_CNT.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    LV_CNT = LV_CNT + 1.
  ENDLOOP.

  IF LV_CNT > 1.
    IF PV_FLAG = 'S'.
      PV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '한 라인만 선택하시기 바랍니다.'.
    ENDIF.
  ELSEIF LV_CNT < 1.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택된 라인이 없습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ASSIGN_HISTORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_ASSIGN_HISTORY .

  PERFORM CHECK_SELECTED_ROWS USING 'M'
                                    GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

*--> [CHM2507-00010] 청산선물 변경이력 조회 추가
**** 원본 BK - START
*  READ TABLE GT_MAIN WITH KEY NCIND = '청산'
*                              CHECK = 'X'.
*  IF SY-SUBRC = 0.
*    MESSAGE S003 DISPLAY LIKE 'E'
*       WITH '연결이력 조회는 신규선물집행번호만'
*            '가능합니다.'.
*    EXIT.
*  ENDIF.
*
*  PERFORM GET_ASSIGN_HISTORY.
**** 원본 BK - END

  DATA : LV_CNT_N TYPE I.
  DATA : LV_CNT_C TYPE I.

  READ TABLE GT_MAIN WITH KEY NCIND = '신규'
                              CHECK = 'X'.
  IF SY-SUBRC = 0.
    LV_CNT_N = 1.
  ENDIF.

  READ TABLE GT_MAIN WITH KEY NCIND = '청산'
                              CHECK = 'X'.
  IF SY-SUBRC = 0.
    LV_CNT_C = 1.
  ENDIF.

  IF LV_CNT_N = 1 AND LV_CNT_C = 1.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '신규&청산 같이 연결조회 불가'.
    EXIT.
  ENDIF.

  PERFORM GET_ASSIGN_HISTORY_NEW USING LV_CNT_N LV_CNT_C.
*<-- [CHM2507-00010] 청산선물 변경이력 조회 추가

ENDFORM.                    " DISPLAY_ASSIGN_HISTORY
*&---------------------------------------------------------------------*
*&      Form  GET_ASSIGN_HISTORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ASSIGN_HISTORY .

  CLEAR   : GT_HIST, GT_1020, GT_NFUTN.
  REFRESH : GT_HIST, GT_1020, GT_NFUTN.

*___최초 신규선물집행번호
  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    CLEAR : GT_NFUTN.

    PERFORM GET_PREVIOUS_FUTURES_NO USING GT_MAIN-NFUTN
                                          GT_NFUTN-NFUTN.

    COLLECT GT_NFUTN.
  ENDLOOP.

  LOOP AT GT_NFUTN.
*___최초 신규선물집행번호 데이터
    SELECT *
      APPENDING TABLE GT_1020
      FROM ZNFT1020
     WHERE NFUTN = GT_NFUTN-NFUTN.

*___최초 신규선물집행번호와 연결된 신규선물집행번호
    PERFORM GET_FUTURES_HISTORY_DATA USING GT_NFUTN-NFUTN.
  ENDLOOP.

  CALL SCREEN 0200.

ENDFORM.                    " GET_ASSIGN_HISTORY
*&---------------------------------------------------------------------*
*&      Form  GET_PREVIOUS_FUTURES_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_PREVIOUS_FUTURES_NO  USING    PV_NFUTN
                                       PV_OLDFT.
  DATA: LV_NFUTN LIKE ZNFT1020-NFUTN.

  CLEAR : PV_OLDFT, LV_NFUTN.

  SELECT SINGLE OLDFT
    INTO LV_NFUTN
    FROM ZNFT1020
   WHERE NFUTN = PV_NFUTN.

  IF LV_NFUTN IS NOT INITIAL.
    PERFORM GET_PREVIOUS_FUTURES_NO USING LV_NFUTN
                                          PV_OLDFT.
  ELSE.
    PV_OLDFT = PV_NFUTN.
  ENDIF.

ENDFORM.                    " GET_PREVIOUS_FUTURES_NO
*&---------------------------------------------------------------------*
*&      Form  GET_FUTURES_HISTORY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_FUTURES_HISTORY_DATA USING PV_OLDFT.

  DATA: LT_1020 LIKE ZNFT1020 OCCURS 0 WITH HEADER LINE.

  CLEAR   : LT_1020.
  REFRESH : LT_1020.

  SELECT *
    INTO TABLE LT_1020
    FROM ZNFT1020
   WHERE OLDFT = PV_OLDFT.

  LOOP AT LT_1020.
    CLEAR : GT_1020.
    GT_1020 = LT_1020.
    APPEND GT_1020.
    PERFORM GET_FUTURES_HISTORY_DATA USING LT_1020-NFUTN.
  ENDLOOP.

ENDFORM.                    " GET_FUTURES_HISTORY_DATA
*&---------------------------------------------------------------------*
*&      Form  CREATE_DISPLAY_ALV_TREE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_DISPLAY_ALV_TREE .

  CREATE OBJECT GC_ALV_TREE
    EXPORTING
      PARENT              = GC_CUSTOM_CONTAINER2
      NODE_SELECTION_MODE = CL_GUI_COLUMN_TREE=>NODE_SEL_MODE_MULTIPLE
      ITEM_SELECTION      = 'X'
      NO_HTML_HEADER      = 'X'
      NO_TOOLBAR          = ' '.

  IF GV_TYPE = 'N'. "--> 신규선물 이력조회
    PERFORM SET_GRID_FCAT_2.
  ELSEIF GV_TYPE = 'C'. "--> 청산선물 이력조회
    PERFORM SET_GRID_FCAT_3.
  ENDIF.

*___Create Hierarchy-header
  PERFORM BUILD_HIERARCHY_HEADER.

*___필요한 function만 삽입
  PERFORM EXCLUDE_TB_FUNCTIONS_2 CHANGING GT_EXCLUDE.

  PERFORM SET_TABLE_FOR_FIRST_DISPLAY_2.

  PERFORM CREATE_HIERARCHY.

** 박우진 추가 (2026.09.29)
  PERFORM CHANGE_TOOLBAR.
** 박우진 추가 (2026.09.29)



*___Edit Event 및  Event Handler 등록
  PERFORM EVENT_HANDLER_REGISTER_2.

*___calculate totals
  CALL METHOD GC_ALV_TREE->UPDATE_CALCULATIONS.

*___this method must be called to send the data to the frontend
  CALL METHOD GC_ALV_TREE->FRONTEND_UPDATE.

  CALL METHOD GC_ALV_TREE->EXPAND_NODES
    EXPORTING
      IT_NODE_KEY = GT_NODE_EXP[].

  CALL METHOD GC_ALV_TREE->COLUMN_OPTIMIZE.

ENDFORM.                    " CREATE_DISPLAY_ALV_TREE
*&---------------------------------------------------------------------*
*&      Form  BUILD_HIERARCHY_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_HIERARCHY_HEADER .

  CLEAR : GS_HIERARCHY_HEADER.

  IF GV_TYPE = 'N'.
    GS_HIERARCHY_HEADER-HEADING   = '신규선물집행번호'.
    GS_HIERARCHY_HEADER-TOOLTIP   = '신규선물집행번호'.
    GS_HIERARCHY_HEADER-WIDTH     = 40.
    GS_HIERARCHY_HEADER-WIDTH_PIX = ' '.
  ELSEIF GV_TYPE = 'C'.
    GS_HIERARCHY_HEADER-HEADING   = '청산선물집행번호'.
    GS_HIERARCHY_HEADER-TOOLTIP   = '청산선물집행번호'.
    GS_HIERARCHY_HEADER-WIDTH     = 40.
    GS_HIERARCHY_HEADER-WIDTH_PIX = ' '.
  ENDIF.
ENDFORM.                    " BUILD_HIERARCHY_HEADER
*&---------------------------------------------------------------------*
*&      Form  CREATE_HIERARCHY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_HIERARCHY .
  DATA : LV_NODE_KEY TYPE LVC_NKEY.

  CLEAR   : GT_NODE_KEY, GT_NODE_EXP, LV_NODE_KEY.
  REFRESH : GT_NODE_KEY, GT_NODE_EXP.

  IF GV_TYPE = 'N'. "--> 신규선물이력
    LOOP AT GT_1020 WHERE OLDFT IS INITIAL.
*___최초 라인 추가
      PERFORM ADD_LEVEL_LINE USING    GT_1020
                                      ' '
                             CHANGING LV_NODE_KEY.

      GT_NODE_KEY = LV_NODE_KEY.
      APPEND GT_NODE_KEY.

*___현재라인으로 생성된 이력 추가
      PERFORM APPEND_NEXT_LEVEL USING GT_1020-NFUTN
                                      LV_NODE_KEY.
    ENDLOOP.
  ELSEIF GV_TYPE = 'C'. "--> 청산선물이력
    LOOP AT GT_1030 WHERE OLDFT IS INITIAL.
*___최초 라인 추가
      PERFORM ADD_LEVEL_LINE_2 USING  GT_1030
                                      ' '
                               CHANGING LV_NODE_KEY.

      GT_NODE_KEY = LV_NODE_KEY.
      APPEND GT_NODE_KEY.

*___현재라인으로 생성된 이력 추가
      PERFORM APPEND_NEXT_LEVEL_2 USING GT_1030-CFUTN
                                        LV_NODE_KEY.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " CREATE_HIERARCHY
*&---------------------------------------------------------------------*
*&      Form  ADD_LEVEL_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ADD_LEVEL_LINE  USING     PS_1020      LIKE GT_1020
                               PV_RELAT_KEY TYPE LVC_NKEY
                     CHANGING  PV_NODE_KEY  TYPE LVC_NKEY.

  DATA: LV_NODE_TEXT TYPE LVC_VALUE,
        LS_HIST      LIKE GT_HIST.

  DATA: LT_ITEM_LAYOUT TYPE LVC_T_LAYI,
        LS_ITEM_LAYOUT TYPE LVC_S_LAYI.

  CLEAR   : LS_ITEM_LAYOUT, LS_HIST.
  REFRESH : LT_ITEM_LAYOUT.

  MOVE-CORRESPONDING PS_1020 TO LS_HIST.

  LS_HIST-NCIND = '신규'.

*___계약/선물요청 정보
  PERFORM GET_CONTRACT_INFO USING LS_HIST.

  PERFORM GET_OTHER_DATA USING LS_HIST.

  LV_NODE_TEXT = PS_1020-NFUTN.

*___선택된 라인의 선물집행번호인 경우 강조표시
  READ TABLE GT_MAIN WITH KEY NFUTN = PS_1020-NFUTN
                              CHECK = 'X'.
  IF SY-SUBRC = 0.
*    LS_ITEM_LAYOUT-T_IMAGE   = '@01@'.
    LS_ITEM_LAYOUT-FIELDNAME = GC_ALV_TREE->C_HIERARCHY_COLUMN_NAME.
*    LS_ITEM_LAYOUT-STYLE     = CL_GUI_COLUMN_TREE=>STYLE_INTENSIFIED.
    LS_ITEM_LAYOUT-STYLE =
              CL_GUI_COLUMN_TREE=>STYLE_EMPHASIZED_NEGATIVE.

    APPEND LS_ITEM_LAYOUT TO LT_ITEM_LAYOUT.
  ENDIF.

*___노드를 추가하면 'GT_HIST' Internal Table에 라인이 추가됨.
  CALL METHOD GC_ALV_TREE->ADD_NODE
    EXPORTING
      I_RELAT_NODE_KEY = PV_RELAT_KEY
      I_RELATIONSHIP   = CL_GUI_COLUMN_TREE=>RELAT_LAST_CHILD
      I_NODE_TEXT      = LV_NODE_TEXT
      IS_OUTTAB_LINE   = LS_HIST
      IT_ITEM_LAYOUT   = LT_ITEM_LAYOUT
    IMPORTING
      E_NEW_NODE_KEY   = PV_NODE_KEY.

*___트리에서 더블클릭했을 경우를 위해 노드키 저장
  READ TABLE GT_HIST WITH KEY NFUTN = PS_1020-NFUTN.
  IF SY-SUBRC = 0.
    GT_HIST-NODE_KEY = PV_NODE_KEY.

    MODIFY GT_HIST INDEX SY-TABIX.
  ENDIF.

ENDFORM.                    " ADD_LEVEL_LINE
*&---------------------------------------------------------------------*
*&      Form  APPEND_NEXT_LEVEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM APPEND_NEXT_LEVEL  USING    PV_NFUTN
                                 PV_NODE_KEY.
  DATA : LS_1020     LIKE GT_1020,
         LV_NODE_KEY TYPE LVC_NKEY.

  LOOP AT GT_1020 INTO LS_1020 WHERE OLDFT = PV_NFUTN.
    CLEAR : LV_NODE_KEY.

*___현재라인 추가
    PERFORM ADD_LEVEL_LINE USING    LS_1020
                                    PV_NODE_KEY
                           CHANGING LV_NODE_KEY.

    GT_NODE_KEY = LV_NODE_KEY.
    APPEND GT_NODE_KEY.

*___현재라인으로 생성된 이력 추가
    PERFORM APPEND_NEXT_LEVEL USING LS_1020-NFUTN
                                    LV_NODE_KEY.
  ENDLOOP.

*___노드 펼치기를 위해 노드키 저장
  IF SY-SUBRC = 0.
    GT_NODE_EXP = PV_NODE_KEY.
    APPEND GT_NODE_EXP.
  ENDIF.

ENDFORM.                    " APPEND_NEXT_LEVEL
*&---------------------------------------------------------------------*
*&      Form  GET_OTHER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_OTHER_DATA  USING PS_MAIN LIKE GT_MAIN.
  DATA: LV_ERROR.

*___집행금액
  PS_MAIN-TOTAL = ( PS_MAIN-MISPD + PS_MAIN-PRICE ) * PS_MAIN-EMENG.

*___취소사유 내역
  IF PS_MAIN-YNCAN IS NOT INITIAL.
    PERFORM DOMAIN_VALUE_GET USING 'ZWHYCN'
                                   PS_MAIN-WHYCN
                                   PS_MAIN-WHYTX.
  ENDIF.

*___Buy/Sell 내역
  PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                 PS_MAIN-BY_SL
                                 PS_MAIN-BSTXT.

*___결재상태 내역
  PERFORM DOMAIN_VALUE_GET USING 'ZCONFM3'
                                 PS_MAIN-CONFM
                                 PS_MAIN-CFMTX.

*___집행유형 내역
  PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                 PS_MAIN-MITYP
                                 PS_MAIN-MITPT.

*___요청유형 내역
  PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                 PS_MAIN-RQTYP
                                 PS_MAIN-RQTXT.

*___사업부명
  PERFORM GET_NFCTR_DESC USING P_BUKRS
                               PS_MAIN-NFCTR
                               PS_MAIN-NTEXT.

*___손익센터명
  PERFORM GET_PRCTR_DESC USING GV_KOKRS
                               PS_MAIN-PRCTR
                               PS_MAIN-PTEXT.

*___영업그룹명
  PERFORM GET_VKGRP_DESC USING GV_KOKRS
                               PS_MAIN-VKGRP
                               PS_MAIN-VTEXT.

*___고객명
  IF PS_MAIN-KUNNR IS NOT INITIAL.
    PERFORM GET_KUNNR_DESC USING PS_MAIN-KUNNR
                                 PS_MAIN-NCUST.
  ENDIF.

*___FCM 명
  PERFORM GET_LIFNR_DESC USING PS_MAIN-FCM
                               PS_MAIN-NAME1.

*___가격구분/비철수주가
  PERFORM PRICE_CLASSIFICATION USING PS_MAIN-CONNO
                                     PS_MAIN-NFKEY
                                     PS_MAIN-PRIND
                                     PS_MAIN-SUJUP
                                     LV_ERROR.

*___손익전표
  PERFORM GET_PROFIT_FI_DOC USING PS_MAIN-NCIND
                                  PS_MAIN-NFUTN
                                  PS_MAIN-CFUTN
                                  PS_MAIN-GJAHR
                                  PS_MAIN-BELNR.

ENDFORM.                    " GET_OTHER_DATA
*&---------------------------------------------------------------------*
*&      Form  DOUBLE_CLICK_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK_1  USING    E_FIELDNAME TYPE LVC_FNAME
                              E_NODE_KEY  TYPE LVC_NKEY.

  READ TABLE GT_HIST WITH KEY NODE_KEY = E_NODE_KEY.
  IF SY-SUBRC = 0.
    CASE E_FIELDNAME.
      WHEN 'CONNO'.
        IF GT_HIST-CONNO IS NOT INITIAL.
          SET PARAMETER ID 'ZNFCON' FIELD GT_HIST-CONNO.

          CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
        ENDIF.

      WHEN 'REQNO'.
        IF GT_HIST-REQNO IS NOT INITIAL.
          SET PARAMETER ID 'ZNFREQ' FIELD GT_HIST-REQNO.

          CALL TRANSACTION 'ZNF2M2103' AND SKIP FIRST SCREEN.
        ENDIF.

      WHEN 'GJAHR' OR 'BELNR'.
        IF GT_HIST-GJAHR IS NOT INITIAL AND
           GT_HIST-BELNR IS NOT INITIAL.
          SET PARAMETER ID 'BLN' FIELD GT_HIST-BELNR.
          SET PARAMETER ID 'BUK' FIELD GT_HIST-BUKRS.
          SET PARAMETER ID 'GJR' FIELD GT_HIST-GJAHR.

          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
        ENDIF.

    ENDCASE.
  ENDIF.

ENDFORM.                    " DOUBLE_CLICK_1
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_FUTRUES_HISTORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_FUTRUES_HISTORY .
  DATA: LT_RSPAR LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

  CLEAR   : LT_RSPAR.
  REFRESH : LT_RSPAR.

  APPEND_PARAM : LT_RSPAR 'P_BUKRS' 'P' ' ' ' '  P_BUKRS       ' '.

  IF GT_MAIN-NCIND = '청산'.
    APPEND_PARAM : LT_RSPAR 'S_NFUTN' 'S' 'I' 'EQ' GT_MAIN-CFUTN ' ',
                   LT_RSPAR 'P_CHK11' 'P' ' ' ' '  'X'           ' ',
                   LT_RSPAR 'P_CHK12' 'P' ' ' ' '  ' '           ' '.
  ELSE.
    APPEND_PARAM : LT_RSPAR 'S_CFUTN' 'S' 'I' 'EQ' GT_MAIN-CFUTN ' ',
                   LT_RSPAR 'P_CHK11' 'P' ' ' ' '  ' '           ' ',
                   LT_RSPAR 'P_CHK12' 'P' ' ' ' '  'X'           ' '.
  ENDIF.

  APPEND_PARAM : LT_RSPAR 'P_R01'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R02'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R03'   'P' ' ' ' '  'X'           ' ',
                 LT_RSPAR 'P_R11'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R12'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R13'   'P' ' ' ' '  'X'           ' ',
                 LT_RSPAR 'P_R21'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R22'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R23'   'P' ' ' ' '  'X'           ' '.

  SUBMIT ZNFR2600 WITH SELECTION-TABLE LT_RSPAR
                   AND RETURN.

ENDFORM.                    " DISPLAY_FUTRUES_HISTORY
*&---------------------------------------------------------------------*
*&      Form  GET_CONTRACT_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_CONTRACT_INFO  USING    PS_MAIN LIKE GT_MAIN.

*--> [CHM2507-00010] 청산연결이력 선물요청 누락 읽어오기
  IF PS_MAIN-REQNO IS INITIAL.
    SELECT SINGLE REQNO H_NO1
      INTO (PS_MAIN-REQNO, PS_MAIN-H_NO1)
      FROM ZNFT1020
     WHERE NFUTN = PS_MAIN-NFUTN.
  ENDIF.
*<-- [CHM2507-00010] 청산연결이력 선물요청 누락 읽어오기

  SELECT SINGLE A~CONNO   "계약번호
                A~COTXT   "계약명
                A~KUNNR   "고객코드
                A~NCUST   "고객명
                A~NFCTR   "사업부
                A~PRCTR   "손익센터
                A~VKGRP   "영업그룹
                B~ENDMM   "만기월
                B~EMENG   "요청수량
                B~MEINS   "단위
                C~RQTYP   "요청유형
    INTO (PS_MAIN-CONNO, PS_MAIN-COTXT,
          PS_MAIN-KUNNR, PS_MAIN-NCUST,
          PS_MAIN-NFCTR, PS_MAIN-PRCTR,
          PS_MAIN-VKGRP, PS_MAIN-ENDMM,
          PS_MAIN-REQTY, PS_MAIN-REQME,
          PS_MAIN-RQTYP)
    FROM ZNFT1000 AS A
   INNER JOIN ZNFT1011 AS B
      ON A~CONNO = B~CONNO
   INNER JOIN ZNFT1010 AS C
      ON B~REQNO = C~REQNO
   WHERE B~REQNO = PS_MAIN-REQNO
     AND B~H_NO1 = PS_MAIN-H_NO1.

*___연결된 청산건
  "--> 이상데이터 강제 예외처리 - 20251029 유주수D 요청
  IF PS_MAIN-NFUTN = '3000075060' OR
     PS_MAIN-NFUTN = '3000074949' OR
     PS_MAIN-NFUTN = '3000074950'.
  ELSE.
    SELECT SINGLE CFUTN
      INTO PS_MAIN-CFUTN
      FROM ZNFT1030
     WHERE NFUTN = PS_MAIN-NFUTN.
    "--> 상태 무시 연결된 청산 모두 읽어오기
*     AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) ).
  ENDIF.
ENDFORM.                    " GET_CONTRACT_INFO
*&---------------------------------------------------------------------*
*& Form GET_ASSIGN_HISTORY_NEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ASSIGN_HISTORY_NEW USING PV_CNT_N PV_CNT_C.

  CLEAR   : GT_HIST, GT_1020, GT_1030, GT_NFUTN, GT_CFUTN.
  REFRESH : GT_HIST, GT_1020, GT_1030, GT_NFUTN, GT_CFUTN.
  CLEAR : GV_TYPE. "--> 필드카탈로그 구분자

  IF PV_CNT_N = 1. "--> 신규선물 조회
    GV_TYPE = 'N'.
    LOOP AT GT_MAIN WHERE CHECK = 'X'
                      AND NCIND = '신규'.
      CLEAR : GT_NFUTN.
      PERFORM GET_PREVIOUS_FUTURES_NO USING GT_MAIN-NFUTN
                                            GT_NFUTN-NFUTN.
      COLLECT GT_NFUTN.
    ENDLOOP.

    LOOP AT GT_NFUTN.
      SELECT *
      APPENDING TABLE GT_1020
        FROM ZNFT1020
       WHERE NFUTN = GT_NFUTN-NFUTN.

      PERFORM GET_FUTURES_HISTORY_DATA USING GT_NFUTN-NFUTN.
    ENDLOOP.

  ELSEIF PV_CNT_C = 1. "--> 청산선물 조회
    GV_TYPE = 'C'.
    LOOP AT GT_MAIN WHERE CHECK = 'X'
                      AND NCIND = '청산'.
      CLEAR : GT_CFUTN.
      PERFORM GET_PREVIOUS_FUTURES_NO_2 USING GT_MAIN-NFUTN
                                              GT_CFUTN-CFUTN.
      COLLECT GT_CFUTN.
    ENDLOOP.

    LOOP AT GT_CFUTN.
      SELECT *
      APPENDING TABLE GT_1030
        FROM ZNFT1030
       WHERE CFUTN = GT_CFUTN-CFUTN.

      PERFORM GET_FUTURES_HISTORY_DATA_2 USING GT_CFUTN-CFUTN.
    ENDLOOP.

  ENDIF.

  CALL SCREEN 0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PREVIOUS_FUTURES_NO_2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MAIN_NFUTN
*&      --> GT_CFUTN_NFUTN
*&---------------------------------------------------------------------*
FORM GET_PREVIOUS_FUTURES_NO_2 USING PV_CFUTN
                                     PV_OLDFT.
  DATA: LV_CFUTN LIKE ZNFT1030-CFUTN.

  CLEAR : PV_OLDFT, LV_CFUTN.

  SELECT SINGLE OLDFT
    INTO LV_CFUTN
    FROM ZNFT1030
   WHERE CFUTN = PV_CFUTN.

  IF LV_CFUTN IS NOT INITIAL.
    PERFORM GET_PREVIOUS_FUTURES_NO_2 USING LV_CFUTN
                                            PV_OLDFT.
  ELSE.
    PV_OLDFT = PV_CFUTN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FUTURES_HISTORY_DATA_2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_CFUTN_CFUTN
*&---------------------------------------------------------------------*
FORM GET_FUTURES_HISTORY_DATA_2 USING PV_OLDFT.

  DATA: LT_1030 LIKE ZNFT1030 OCCURS 0 WITH HEADER LINE.

  CLEAR   : LT_1030.
  REFRESH : LT_1030.

  SELECT *
    INTO TABLE LT_1030
    FROM ZNFT1030
   WHERE OLDFT = PV_OLDFT.

  LOOP AT LT_1030.
    CLEAR : GT_1030.
    GT_1030 = LT_1030.
    APPEND GT_1030.
    PERFORM GET_FUTURES_HISTORY_DATA_2 USING LT_1030-CFUTN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GRID_FCAT_3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GRID_FCAT_3 .

  CLEAR   : GS_FIELDCAT, GV_POS.
  REFRESH : GT_FIELDCAT.

  GV_ITAB = 'GT_HIST'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT
                                  USING :
*      'NFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
*      '신규선물집행번호' 'NFUTN' 'ZNFT1020' ' ' ' '  'X' ' ' ' ' ' ',

      'YNCAN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      ' '            'YNCAN'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'WHYCN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'WHYCN'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'WHYTX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '취소사유내역' ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'CONFM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'CONFM'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'CFMTX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '결재상태내역' ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'YNFIN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'YNFIN'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'GJAHR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      ' '            'GJAHR'  'ZNFT1051'  ' ' ' '    'X' ' ' ' ' ' ',

      'BELNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '손익전표번호' 'BELNR'  'ZNFT1051'  ' ' ' '    'X' ' ' ' ' ' ',

      'RUDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'RUDAT'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'FCM'      ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'FCM'    'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'NAME1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      'FCM 명'       'NAME1'  'LFA1'      ' ' ' '    'X' ' ' ' ' ' ',

      'BY_SL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'BY_SL'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'ENDAT'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'MITYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'MITYP'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'MISPD'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '            'MISPD'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' ' ',

      'MIMON'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '            'MIMON'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRICE'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '            'PRICE'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' ' ',

      'WAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      ' '            'WAERS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '            'EMENG'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'MEINS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'MISUS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'MISUS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'NFKEY'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'NFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '신규선물집행번호' 'NFUTN' 'ZNFT1030' ' ' ' '  'X' ' ' ' ' ' ',

      'REQNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'REQNO'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'H_NO1'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 5
      ' '            'H_NO1'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'ENDMM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '            'ENDMM'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'REQTY'    ' '      'REQME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '            'EMENG'  'ZNFT1011'  ' ' ' '    ' ' ' ' ' ' ' ',

      'REQME'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'MEINS'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'RQTYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'RQTYP'  'ZNFT1010'  ' ' ' '    'X' ' ' ' ' ' ',

      'CONNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'CONNO'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'COTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '            'COTXT'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'KUNNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 10
      ' '            'KUNNR'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'NCUST'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '            'NCUST'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRIND'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 15
      '가격구분'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'SUJUP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 12
      '비철수주가'   ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' '.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_LEVEL_LINE_2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_1030
*&      --> P_
*&      <-- LV_NODE_KEY
*&---------------------------------------------------------------------*
FORM ADD_LEVEL_LINE_2  USING   PS_1030      LIKE GT_1030
                               PV_RELAT_KEY TYPE LVC_NKEY
                     CHANGING  PV_NODE_KEY  TYPE LVC_NKEY.

  DATA: LV_NODE_TEXT TYPE LVC_VALUE,
        LS_HIST      LIKE GT_HIST.

  DATA: LT_ITEM_LAYOUT TYPE LVC_T_LAYI,
        LS_ITEM_LAYOUT TYPE LVC_S_LAYI.

  CLEAR   : LS_ITEM_LAYOUT, LS_HIST.
  REFRESH : LT_ITEM_LAYOUT.

  MOVE-CORRESPONDING PS_1030 TO LS_HIST.

  LS_HIST-NCIND = '청산'.

*___계약/선물요청 정보
  PERFORM GET_CONTRACT_INFO USING LS_HIST.

  PERFORM GET_OTHER_DATA USING LS_HIST.

  LV_NODE_TEXT = PS_1030-CFUTN.

*___선택된 라인의 선물집행번호인 경우 강조표시
  READ TABLE GT_MAIN WITH KEY NFUTN = PS_1030-CFUTN
                              CHECK = 'X'.
  IF SY-SUBRC = 0.
*    LS_ITEM_LAYOUT-T_IMAGE   = '@01@'.
    LS_ITEM_LAYOUT-FIELDNAME = GC_ALV_TREE->C_HIERARCHY_COLUMN_NAME.
*    LS_ITEM_LAYOUT-STYLE     = CL_GUI_COLUMN_TREE=>STYLE_INTENSIFIED.
    LS_ITEM_LAYOUT-STYLE =
              CL_GUI_COLUMN_TREE=>STYLE_EMPHASIZED_NEGATIVE.

    APPEND LS_ITEM_LAYOUT TO LT_ITEM_LAYOUT.
  ENDIF.

*___노드를 추가하면 'GT_HIST' Internal Table에 라인이 추가됨.
  CALL METHOD GC_ALV_TREE->ADD_NODE
    EXPORTING
      I_RELAT_NODE_KEY = PV_RELAT_KEY
      I_RELATIONSHIP   = CL_GUI_COLUMN_TREE=>RELAT_LAST_CHILD
      I_NODE_TEXT      = LV_NODE_TEXT
      IS_OUTTAB_LINE   = LS_HIST
      IT_ITEM_LAYOUT   = LT_ITEM_LAYOUT
    IMPORTING
      E_NEW_NODE_KEY   = PV_NODE_KEY.

*___트리에서 더블클릭했을 경우를 위해 노드키 저장
  READ TABLE GT_HIST WITH KEY NFUTN = PS_1030-CFUTN.
  IF SY-SUBRC = 0.
    GT_HIST-NODE_KEY = PV_NODE_KEY.

    MODIFY GT_HIST INDEX SY-TABIX.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_NEXT_LEVEL_2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_1030_CFUTN
*&      --> LV_NODE_KEY
*&---------------------------------------------------------------------*
FORM APPEND_NEXT_LEVEL_2  USING  PV_CFUTN
                                 PV_NODE_KEY.
  DATA : LS_1030     LIKE GT_1030,
         LV_NODE_KEY TYPE LVC_NKEY.

  LOOP AT GT_1030 INTO LS_1030 WHERE OLDFT = PV_CFUTN.
    CLEAR : LV_NODE_KEY.

*___현재라인 추가
    PERFORM ADD_LEVEL_LINE_2 USING  LS_1030
                                    PV_NODE_KEY
                             CHANGING LV_NODE_KEY.

    GT_NODE_KEY = LV_NODE_KEY.
    APPEND GT_NODE_KEY.

*___현재라인으로 생성된 이력 추가
    PERFORM APPEND_NEXT_LEVEL_2 USING LS_1030-NFUTN
                                      LV_NODE_KEY.
  ENDLOOP.

*___노드 펼치기를 위해 노드키 저장
  IF SY-SUBRC = 0.
    GT_NODE_EXP = PV_NODE_KEY.
    APPEND GT_NODE_EXP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_TOOLBAR
*&---------------------------------------------------------------------*
FORM CHANGE_TOOLBAR .

  CALL METHOD GC_ALV_TREE->GET_TOOLBAR_OBJECT
    IMPORTING
      ER_TOOLBAR = GO_TOOLBAR.

  CHECK GO_TOOLBAR IS BOUND.

* 구분선
  CALL METHOD GO_TOOLBAR->ADD_BUTTON
    EXPORTING
      FCODE     = ''
      ICON      = ''
      BUTN_TYPE = CNTB_BTYPE_SEP.

* 사용자 버튼
  CALL METHOD GO_TOOLBAR->ADD_BUTTON
    EXPORTING
      FCODE     = 'ZEXCEL'
      ICON      = ICON_XLS
      BUTN_TYPE = CNTB_BTYPE_BUTTON
      TEXT      = '엑셀'
      QUICKINFO = '엑셀 다운로드'.

*  CALL METHOD GO_TOOLBAR->ADD_BUTTON
*    EXPORTING
*      FCODE     = 'ZEXPAND'
*      ICON      = ICON_EXPAND_ALL
*      BUTN_TYPE = CNTB_BTYPE_BUTTON
*      TEXT      = ''
*      QUICKINFO = '전체 펼치기'.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOWNLOAD_EXCEL
*&---------------------------------------------------------------------*
FORM DOWNLOAD_EXCEL .


  DATA: LT_FCAT     TYPE LVC_T_FCAT,
        LS_FCAT     TYPE LVC_S_FCAT,
        LR_DATA     TYPE REF TO DATA,
        LO_RESULT   TYPE REF TO CL_SALV_EX_RESULT_DATA_TABLE,
        LV_XSTRING  TYPE XSTRING,
        LT_BIN      TYPE SOLIX_TAB,
        LV_SIZE     TYPE I,
        LV_FILENAME TYPE STRING,
        LV_PATH     TYPE STRING,
        LV_FULLPATH TYPE STRING,
        LV_ACTION   TYPE I.

  IF GT_HIST[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '다운로드할 데이터가 없습니다.'.
    EXIT.
  ENDIF.

*___1. 필드카탈로그 복사 (숨김/기술필드 제외)
  LT_FCAT = GT_FIELDCAT[].
  DELETE LT_FCAT WHERE NO_OUT = 'X' OR TECH = 'X'.

*___2. 계층 컬럼(선물집행번호)은 FCAT에 없으므로 맨 앞에 추가
  CLEAR LS_FCAT.
  LS_FCAT-REF_TABLE = 'ZNFT1020'.
  LS_FCAT-REF_FIELD = 'NFUTN'.
  IF GV_TYPE = 'N'.
    LS_FCAT-FIELDNAME = 'NFUTN'.
    LS_FCAT-COLTEXT   = '신규선물집행번호'.
  ELSE.
    LS_FCAT-FIELDNAME = 'CFUTN'.
    LS_FCAT-COLTEXT   = '청산선물집행번호'.
  ENDIF.
  LS_FCAT-SCRTEXT_S = LS_FCAT-SCRTEXT_M =
  LS_FCAT-SCRTEXT_L = LS_FCAT-REPTEXT   = LS_FCAT-COLTEXT.
  INSERT LS_FCAT INTO LT_FCAT INDEX 1.

*___3. GT_HIST → XLSX(xstring) 변환
  GET REFERENCE OF GT_HIST[] INTO LR_DATA.

  LO_RESULT = CL_SALV_EX_UTIL=>FACTORY_RESULT_DATA_TABLE(
                R_DATA         = LR_DATA
                T_FIELDCATALOG = LT_FCAT ).

  CL_SALV_BS_LEX=>EXPORT_FROM_RESULT_DATA_TABLE(
    EXPORTING
      IS_FORMAT            = IF_SALV_BS_LEX_FORMAT=>MC_FORMAT_XLSX
      IR_RESULT_DATA_TABLE = LO_RESULT
    IMPORTING
      ER_RESULT_FILE       = LV_XSTRING ).

*___4. 저장 경로 선택
  CONCATENATE '선물집행이력_' SY-DATUM '.xlsx' INTO LV_FILENAME.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
      WINDOW_TITLE      = '엑셀 다운로드'
      DEFAULT_EXTENSION = 'xlsx'
      DEFAULT_FILE_NAME = LV_FILENAME
      FILE_FILTER       = 'Excel 파일 (*.xlsx)|*.xlsx'
    CHANGING
      FILENAME          = LV_FILENAME
      PATH              = LV_PATH
      FULLPATH          = LV_FULLPATH
      USER_ACTION       = LV_ACTION
    EXCEPTIONS
      OTHERS            = 1.

  IF SY-SUBRC <> 0 OR
     LV_ACTION <> CL_GUI_FRONTEND_SERVICES=>ACTION_OK.
    EXIT.          "취소
  ENDIF.

*___5. xstring → binary 후 다운로드
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      BUFFER        = LV_XSTRING
    IMPORTING
      OUTPUT_LENGTH = LV_SIZE
    TABLES
      BINARY_TAB    = LT_BIN.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
      BIN_FILESIZE = LV_SIZE
      FILENAME     = LV_FULLPATH
      FILETYPE     = 'BIN'
    CHANGING
      DATA_TAB     = LT_BIN
    EXCEPTIONS
      OTHERS       = 1.

  IF SY-SUBRC = 0.
    MESSAGE S003 WITH '엑셀 다운로드가 완료되었습니다.'.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '엑셀 다운로드 중 오류가 발생했습니다.'.
  ENDIF.

ENDFORM.
