*----------------------------------------------------------------------*
***INCLUDE ZNFR2210F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_DEFAULT_PARAMETER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DEFAULT_PARAMETER .

ENDFORM.                    " SET_DEFAULT_PARAMETER
*&---------------------------------------------------------------------*
*&      Form  SET_RANGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_RANGES .

  CLEAR   : GR_RQTYP.
  REFRESH : GR_RQTYP.

*___요청유형
  IF P_CHK01 = 'X'.
    APPEND_RANGES GR_RQTYP 'I' 'EQ' '1' ' '.
  ENDIF.

  IF P_CHK02 = 'X'.
    APPEND_RANGES GR_RQTYP 'I' 'EQ' '2' ' '.
  ENDIF.

  IF P_CHK03 = 'X'.
    APPEND_RANGES GR_RQTYP 'I' 'EQ' '3' ' '.
  ENDIF.

  IF P_CHK04 = 'X'.
    APPEND_RANGES GR_RQTYP 'I' 'EQ' '4' ' '.
  ENDIF.

  IF P_CHK05 = 'X'.
    APPEND_RANGES GR_RQTYP 'I' 'EQ' '5' ' '.
  ENDIF.

ENDFORM.                    " SET_RANGES
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_CHECKBOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_CHECKBOX  USING    PV_ERROR.

  CLEAR : PV_ERROR.

  IF P_CHK01 IS INITIAL AND P_CHK02 IS INITIAL AND
     P_CHK03 IS INITIAL AND P_CHK04 IS INITIAL AND
     P_CHK05 IS INITIAL.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '요청유형을 선택하시기 바랍니다.'.

    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_CHECKBOX
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
      DYNAME     = 'ZNFR2210'
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
      DYNAME     = 'ZNFR2210'
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
      DYNAME     = 'ZNFR2210'
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
*&      Form  GET_FUTURES_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FUTURES_REQ_DATA .
  DATA: LV_ERROR.

  CLEAR   : GT_1011.
  REFRESH : GT_1011.

  SELECT A~BUKRS        "회사코드
         A~REQNO        "요청번호
         B~H_NO1        "항번
         A~ERDAT        "요청일
         B~NFKEY        "NF Key
         B~BY_SL        "Buy/Sell
         B~ENDMM        "만기월
         B~EMENG        "요청수량
         B~MEINS        "단위
         A~RQTYP        "요청유형
         B~CONNO        "계약번호
         B~BIGO4        "비고
    INTO CORRESPONDING FIELDS OF TABLE GT_1011
    FROM ZNFT1010 AS A
   INNER JOIN ZNFT1011 AS B
      ON A~REQNO =  B~REQNO
   WHERE A~BUKRS =  P_BUKRS
     AND A~REQNO IN S_REQNO
     AND A~RQTYP IN GR_RQTYP
     AND A~ERDAT IN S_ERDAT
     AND A~RSTAT IN ('4', '5', '6')
     AND B~NFKEY IN S_NFKEY
     AND B~YNFIN =  ' '.

  LOOP AT GT_1011.
*___계약정보
    SELECT SINGLE COTXT   "계약명
                  KUNNR   "고객코드
                  NCUST   "고객명
                  SALER   "영업담당자
                  NFCTR   "사업부
                  PRCTR   "손익센터
                  VKGRP   "영업그룹
*                 =============================
                  SUJUD
                  PRICE
                  WAERS
                  PRATE
                  SALER
                  ERATE
*                 =============================
      INTO (GT_1011-COTXT, GT_1011-KUNNR,
            GT_1011-NCUST, GT_1011-SALER,
            GT_1011-NFCTR, GT_1011-PRCTR,
            GT_1011-VKGRP,
*           ===================================
            GT_1011-SUJUD,
            GT_1011-PRICE,
            GT_1011-WAERS,
            GT_1011-PRATE,
            GT_1011-SALER,
            GT_1011-ERATE
*           ===================================
            )
      FROM ZNFT1000
     WHERE CONNO = GT_1011-CONNO.

    IF GT_1011-NFCTR NOT IN S_NFCTR OR
       GT_1011-PRCTR NOT IN S_PRCTR OR
       GT_1011-VKGRP NOT IN S_VKGRP.
      DELETE GT_1011.
      CONTINUE.
    ENDIF.

*___집행수량
    SELECT SUM( EMENG )
      INTO GT_1011-TMENG
      FROM ZNFT1020
     WHERE REQNO = GT_1011-REQNO
       AND H_NO1 = GT_1011-H_NO1
       AND ( YNCAN = ' ' OR ( YNCAN = 'X' AND ( CONFM = '5'
          OR CONFM = '6' OR CONFM = '8' ) ) ).

    IF GT_1011-TMENG >= GT_1011-EMENG.
      DELETE GT_1011.
      CONTINUE.
    ENDIF.

*___고객명
    IF GT_1011-KUNNR IS NOT INITIAL.
      PERFORM GET_KUNNR_DESC USING GT_1011-KUNNR
                                   GT_1011-NCUST.
    ENDIF.

*___사업부명
    PERFORM GET_NFCTR_DESC USING P_BUKRS
                                 GT_1011-NFCTR
                                 GT_1011-NTEXT.

*___손익센터명
    PERFORM GET_PRCTR_DESC USING GV_KOKRS
                                 GT_1011-PRCTR
                                 GT_1011-PTEXT.

*___영업그룹명
    PERFORM GET_VKGRP_DESC USING GV_KOKRS
                                 GT_1011-VKGRP
                                 GT_1011-VTEXT.

*___Buy/Sell 내역
    PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                   GT_1011-BY_SL
                                   GT_1011-BSTXT.

*___요청유형 내역
    PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                   GT_1011-RQTYP
                                   GT_1011-RQTXT.

*___가격구분/비철수주가
    PERFORM PRICE_CLASSIFICATION USING GT_1011-CONNO
                                       GT_1011-NFKEY
                                       GT_1011-PRIND
                                       GT_1011-SUJUP
                                       LV_ERROR.

*___계약서 첨부파일 유무

    SELECT SINGLE *
     FROM ZNFT1002
    WHERE CONNO = GT_1011-CONNO.

    IF SY-SUBRC EQ 0.
      GT_1011-FILE_YN = 'Y'.
    ELSE.
      GT_1011-FILE_YN = 'N'.
    ENDIF.

    MODIFY GT_1011.
  ENDLOOP.

ENDFORM.                    " GET_FUTURES_REQ_DATA
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

  IF SY-DYNNR = '0200'.
    GS_LAYOUT-GRID_TITLE = '< 선물집행현황 >'.
    GS_LAYOUT-SMALLTITLE = 'X'.
  ELSE.
    GS_LAYOUT-CWIDTH_OPT = 'X'.
  ENDIF.

*  gs_layout-NO_HEADERS = 'X'.
*  GS_LAYOUT-EDIT       = 'X'.
  GS_LAYOUT-ZEBRA      = 'X'.
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
FORM SET_GRID_FCAT_1.

  CLEAR   : GS_FIELDCAT, GV_POS.
  REFRESH : GT_FIELDCAT.

  GV_ITAB = 'GT_1011'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT
                                  USING :
      'BUKRS'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      ' '            'BUKRS'  'ZNFT1010'  ' ' ' '    'X' ' ' ' ' ' ',

      'REQNO'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '            'REQNO'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'H_NO1'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      ' '            'H_NO1'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'ERDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '요청일'       'ERDAT'  'ZNFT1010'  ' ' ' '    'X' ' ' ' ' ' ',

      'NFCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'NFCTR'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'NTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '            'NTEXT'  'ZNFT0005'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'PRCTR'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'PTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '손익센터명'   'PTEXT'  'ZNFT0004'  ' ' ' '    'X' ' ' ' ' ' ',

      'VKGRP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 4
      ' '            'VKGRP'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'VTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 20
      ' '            'VTEXT'  'ZNFT0003'  ' ' ' '    'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      '비철구분'     'NFKEY'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'BY_SL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 6
      ' '            'BY_SL'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'BSTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      'Buy/Sell'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ENDMM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '            'ENDMM'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'MEINS'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '            'EMENG'  'ZNFT1011'  ' ' ' '    ' ' ' ' ' ' ' ',

      'TMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '            'EMENG'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' ' ',

      'RQTYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'RQTYP'  'ZNFT1010'  ' ' ' '    'X' ' ' ' ' ' ',

      'RQTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '요청유형내역' ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'CONNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'CONNO'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'COTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '            'COTXT'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'KUNNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 10
      ' '            'KUNNR'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'NCUST'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '            'NCUST'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'SUJUD'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'SUJUD'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRICE'    ' '     'WAERS'  ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'PRICE'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'WAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'WAERS'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRATE'    ' '  'WAERS'     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'PRATE'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'SALER'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'SALER'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'ERATE'    ' ' 'WAERS'      ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'ERATE'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRIND'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 15
      '가격구분'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'SUJUP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 12
      '비철수주가'   ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'BIGO4'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      ' '            'BIGO4'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'FILE_YN'  ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '파일첨부' ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' '.


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

  GV_ITAB = 'GT_1020'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT
                                  USING :
      'NFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '            'NFUTN'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      '비철구분'     'NFKEY'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'CONFM'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 1
      ' '            'CONFM'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'CFMTX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 6
      '결재상태내역' ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'YNCAN'    ' '      ' '     ' ' 'X' ' ' ' '    ' ' ' ' ' ' 4
      ' '            'YNCAN'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'RUDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'RUDAT'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'FCM'      ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '            'FCM'    'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'NAME1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      'FCM 명'       'NAME1'  'LFA1'      ' ' ' '    'X' ' ' ' ' ' ',

      'BY_SL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      ' '            'BY_SL'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'BSTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      'Buy/Sell'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'ENDAT'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'MITYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'MITYP'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'MITPT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '집행유형내역' ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'MISPD'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 10
      ' '            'MISPD'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' ' ',

      'MIMON'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '            'MIMON'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRICE'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 10
      ' '            'PRICE'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' ' ',

      'WAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'WAERS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 10
      ' '            'EMENG'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'MEINS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'MISUS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'MISUS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'ZEPRO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'ZEPRO'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'BIGO4'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '            'BIGO4'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' '.

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
*&      Form  EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_EXCLUDE  text
*----------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.
  DATA : LS_EXCLUDE TYPE UI_FUNC.

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

ENDFORM.                    " EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_1 .

  CALL METHOD GC_ALV_GRID1->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

*___Event Handler 등록
  CREATE OBJECT GC_EVENT_HANDLER1.

  SET HANDLER GC_EVENT_HANDLER1->HANDLE_DOUBLE_CLICK_1
              FOR GC_ALV_GRID1.

ENDFORM.                    " EVENT_HANDLER_REGISTER_1
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_2 .

  CALL METHOD GC_ALV_GRID2->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

*___Event Handler 등록
  CREATE OBJECT GC_EVENT_HANDLER2.

  SET HANDLER GC_EVENT_HANDLER2->HANDLE_DOUBLE_CLICK_2
              FOR GC_ALV_GRID2.

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

  CALL METHOD GC_ALV_GRID1->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = GS_VARIANT
      IS_LAYOUT            = GS_LAYOUT
      I_SAVE               = 'A'
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
    CHANGING
      IT_FIELDCATALOG      = GT_FIELDCAT[]
      IT_SORT              = GT_SORT[]
      IT_OUTTAB            = GT_1011[].

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

  GS_VARIANT-HANDLE = '0002'.
  GS_VARIANT-REPORT = SY-REPID.

  CALL METHOD GC_ALV_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = GS_VARIANT
      IS_LAYOUT            = GS_LAYOUT
      I_SAVE               = 'A'
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
    CHANGING
      IT_FIELDCATALOG      = GT_FIELDCAT[]
      IT_SORT              = GT_SORT[]
      IT_OUTTAB            = GT_1020[].

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY_2
*&---------------------------------------------------------------------*
*&      Form  SET_SELECTED_ROWS_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SELECTED_ROWS_1 .

  CLEAR   : GS_ROWS.
  REFRESH : GT_ROWS.

  LOOP AT GT_1011 WHERE CHECK = 'X'.
    CLEAR : GS_ROWS.

    GS_ROWS-INDEX = SY-TABIX.

    APPEND GS_ROWS TO GT_ROWS.
  ENDLOOP.

  CALL METHOD GC_ALV_GRID1->SET_SELECTED_ROWS
    EXPORTING
      IT_INDEX_ROWS = GT_ROWS.

  IF GT_COLS[] IS NOT INITIAL.
    CALL METHOD GC_ALV_GRID1->SET_SELECTED_COLUMNS
      EXPORTING
        IT_COL_TABLE = GT_COLS.
  ENDIF.

ENDFORM.                    " SET_SELECTED_ROWS_1
*&---------------------------------------------------------------------*
*&      Form  SET_SELECTED_ROWS_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SELECTED_ROWS_2 .

  CLEAR   : GS_ROWS.
  REFRESH : GT_ROWS.

  LOOP AT GT_1020 WHERE CHECK = 'X'.
    CLEAR : GS_ROWS.

    GS_ROWS-INDEX = SY-TABIX.

    APPEND GS_ROWS TO GT_ROWS.
  ENDLOOP.

  CALL METHOD GC_ALV_GRID2->SET_SELECTED_ROWS
    EXPORTING
      IT_INDEX_ROWS = GT_ROWS.

  IF GT_COLS[] IS NOT INITIAL.
    CALL METHOD GC_ALV_GRID2->SET_SELECTED_COLUMNS
      EXPORTING
        IT_COL_TABLE = GT_COLS.
  ENDIF.

ENDFORM.                    " SET_SELECTED_ROWS_2
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_ROWS_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SELECTED_ROWS_1 .

  CALL METHOD GC_ALV_GRID1->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROWS.

  CALL METHOD GC_ALV_GRID1->GET_SELECTED_COLUMNS
    IMPORTING
      ET_INDEX_COLUMNS = GT_COLS.

  CLEAR : GT_1011-CHECK.

  MODIFY GT_1011 TRANSPORTING CHECK
                 WHERE REQNO IS NOT INITIAL.

  LOOP AT GT_ROWS INTO GS_ROWS.
    READ TABLE GT_1011 INDEX GS_ROWS-INDEX.
    IF SY-SUBRC = 0.
      GT_1011-CHECK = 'X'.

      MODIFY GT_1011 INDEX GS_ROWS-INDEX.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_SELECTED_ROWS_1
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_ROWS_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SELECTED_ROWS_2 .

  CALL METHOD GC_ALV_GRID2->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROWS.

  CALL METHOD GC_ALV_GRID2->GET_SELECTED_COLUMNS
    IMPORTING
      ET_INDEX_COLUMNS = GT_COLS.

  CLEAR : GT_1020-CHECK.

  MODIFY GT_1020 TRANSPORTING CHECK
                 WHERE NFUTN IS NOT INITIAL.

  LOOP AT GT_ROWS INTO GS_ROWS.
    READ TABLE GT_1020 INDEX GS_ROWS-INDEX.
    IF SY-SUBRC = 0.
      GT_1020-CHECK = 'X'.

      MODIFY GT_1020 INDEX GS_ROWS-INDEX.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_SELECTED_ROWS_2
*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN_0200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_SCREEN_0200 .

  PERFORM CHECK_SELECTED_ROWS1 USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  PERFORM GET_FUTURES_TRADING_DATA.

  REFRESH : GT_COLS.

  CALL SCREEN 0200.

  PERFORM GET_FUTURES_REQ_DATA.

ENDFORM.                    " CALL_SCREEN_0200
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_ROWS1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_ROWS1  USING    PV_ERROR.
  DATA: LV_CNT      TYPE I.

  CLEAR : PV_ERROR, LV_CNT.

  LOOP AT GT_1011 WHERE CHECK = 'X'.
    LV_CNT = LV_CNT + 1.
  ENDLOOP.

  IF LV_CNT > 1.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '한 라인만 선택하시기 바랍니다.'.
  ELSEIF LV_CNT < 1.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택한 라인이 없습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_ROWS1
*&---------------------------------------------------------------------*
*&      Form  GET_FUTURES_TRADING_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FUTURES_TRADING_DATA .

  CLEAR   : GT_1020.
  REFRESH : GT_1020.

*___취소되지 않았거나 취소 결재상태가 승인되지 않은건
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_1020
    FROM ZNFT1020
   WHERE REQNO = GT_1011-REQNO
     AND H_NO1 = GT_1011-H_NO1
     AND ( YNCAN = ' ' OR ( YNCAN = 'X' AND ( CONFM = '5'
        OR CONFM = '6' OR CONFM = '8' ) ) ).

  LOOP AT GT_1020.
*___FCM 명
    PERFORM GET_LIFNR_DESC USING GT_1020-FCM
                                 GT_1020-NAME1.

*___Buy/Sell 내역
    PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                   GT_1020-BY_SL
                                   GT_1020-BSTXT.

*___집행유형 내역
    PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                   GT_1020-MITYP
                                   GT_1020-MITPT.

*___결재상태 내역
    PERFORM DOMAIN_VALUE_GET USING 'ZCONFM3'
                                   GT_1020-CONFM
                                   GT_1020-CFMTX.

    MODIFY GT_1020.
  ENDLOOP.

ENDFORM.                    " GET_FUTURES_TRADING_DATA
*&---------------------------------------------------------------------*
*&      Form  DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING    PV_FLAG
                            PS_ROW    TYPE LVC_S_ROW
                            PS_COLUMN TYPE LVC_S_COL.

  CASE PV_FLAG.
    WHEN '1'.
      READ TABLE GT_1011 INDEX PS_ROW-INDEX.
      IF SY-SUBRC = 0.
        CASE PS_COLUMN-FIELDNAME.
          WHEN 'CONNO'.
            PERFORM DISPLAY_CONNO.

          WHEN 'REQNO'.
            PERFORM DISPLAY_REQNO.

        ENDCASE.
      ENDIF.

    WHEN '2'.
      READ TABLE GT_1020 INDEX PS_ROW-INDEX.
      IF SY-SUBRC = 0.
        PERFORM DISPLAY_FUTRUES_HISTORY.
      ENDIF.

  ENDCASE.

ENDFORM.                    " DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN_0300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_SCREEN_0300 .
  DATA: LT_RETURN   LIKE CASDAYATTR OCCURS 0 WITH HEADER LINE.

  CLEAR   : GT_1020N.
  REFRESH : GT_1020N.

  GT_1020N-NFKEY = GT_1011-NFKEY.
  GT_1020N-BY_SL = GT_1011-BY_SL.

  GT_1020N-RUDAT = SY-DATLO.        "집행일

  DO 30 TIMES.
    GT_1020N-RUDAT = GT_1020N-RUDAT - 1.

    CLEAR   : LT_RETURN.
    REFRESH : LT_RETURN.

    CALL FUNCTION 'DAY_ATTRIBUTES_GET'
      EXPORTING
        FACTORY_CALENDAR           = 'L3'
        HOLIDAY_CALENDAR           = 'LS'
        DATE_FROM                  = GT_1020N-RUDAT
        DATE_TO                    = GT_1020N-RUDAT
        LANGUAGE                   = SY-LANGU
      TABLES
        DAY_ATTRIBUTES             = LT_RETURN
      EXCEPTIONS
        FACTORY_CALENDAR_NOT_FOUND = 1
        HOLIDAY_CALENDAR_NOT_FOUND = 2
        DATE_HAS_INVALID_FORMAT    = 3
        DATE_INCONSISTENCY         = 4
        OTHERS                     = 5.

    READ TABLE LT_RETURN INDEX 1.
    IF LT_RETURN-FREEDAY NE 'X'. "휴일아님
      EXIT.
    ENDIF.
  ENDDO.

  APPEND GT_1020N.

  GV_CURSOR = 'GT_1020N-RUDAT'.
  GV_CURLIN = 1.

  CALL SCREEN 0300 STARTING AT 10 16.

  IF GV_FLAG = 'X'.
*___신규선물집행 등록에서 결재요청한 경우
    PERFORM GET_FUTURES_REQ_DATA.

    LEAVE TO SCREEN 0.
  ENDIF.

ENDFORM.                    " CALL_SCREEN_0300
*&---------------------------------------------------------------------*
*&      Form  MOVE_TC1_TO_ITAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MOVE_TC1_TO_ITAB USING PV_FLAG.

  IF GV_CHANGE = 'X'.
    CLEAR : GV_CHANGE.
  ENDIF.

  IF PV_FLAG = 'I'.
    GS_1020-BUKRS = GT_1011-BUKRS.
    GS_1020-REQNO = GT_1011-REQNO.
    GS_1020-H_NO1 = GT_1011-H_NO1.
    GS_1020-NFKEY = GT_1011-NFKEY.
    GS_1020-BY_SL = GT_1011-BY_SL.
    GS_1020-WAERS = 'USD'.
*    GS_1020-MEINS = 'TON'. " CME 관리 주석
  ENDIF.

  GS_1020-CHECK = GT_1020N-CHECK.
  GS_1020-RUDAT = GT_1020N-RUDAT.
  GS_1020-FCM   = GT_1020N-FCM.
  GS_1020-ENDAT = GT_1020N-ENDAT.
  GS_1020-MITYP = GT_1020N-MITYP.
  GS_1020-MISPD = GT_1020N-MISPD.
  GS_1020-MIMON = GT_1020N-MIMON.
  GS_1020-PRICE = GT_1020N-PRICE.
  GS_1020-EMENG = GT_1020N-EMENG.
  GS_1020-MISUS = GT_1020N-MISUS.
  GS_1020-ZEPRO = GT_1020N-ZEPRO.
  GS_1020-BIGO4 = GT_1020N-BIGO4.
  GS_1020-MEINS = GT_1020N-MEINS. " CME 관리 추가

  IF GS_1020-MITYP = 'S'.
    CLEAR : GS_1020-MISPD, GS_1020-MIMON.
  ENDIF.

*___FCM 명
  PERFORM GET_LIFNR_DESC USING GS_1020-FCM
                               GS_1020-NAME1.

*--> 비철 CME 관리 추가
  IF GS_1020-MEINS IS NOT INITIAL.
    IF GS_1020-MEINS <> 'TON' AND GS_1020-MEINS <> 'LB'.
      MESSAGE E003 WITH '단위는 TON or LB만 입력 가능합니다.'.
    ENDIF.
  ENDIF.
*<-- 비철 CME 관리 추가
ENDFORM.                    " MOVE_TC1_TO_ITAB
*&---------------------------------------------------------------------*
*&      Form  CHECK_EPRO_REMAIN_QUANTITY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_EPRO_REMAIN_QUANTITY  USING    PV_BUKRS
                                          PV_ZEPRO
                                          PV_TABIX
                                          PV_EMENG
                                          PV_ERROR.
  DATA: LV_EMENG1 LIKE ZNFT1021-EMENG,   "e-Pro 수량
        LV_EMENG2 LIKE ZNFT1020-EMENG,   "신규선물집행수량
        LV_EMENG3 LIKE ZNFT1030-EMENG,   "청산선물집행수량
        LV_EMENG4 LIKE ZNFT1020-EMENG.   "현재 작업중인 수량

  CLEAR : LV_EMENG1, LV_EMENG2, LV_EMENG3,
          LV_EMENG4, PV_ERROR,  PV_EMENG.

*___e-Pro 수량
  SELECT SINGLE EMENG
    INTO LV_EMENG1
    FROM ZNFT1021
   WHERE BUKRS = PV_BUKRS
     AND ZEPRO = PV_ZEPRO.

*___신규집행수량
  SELECT SUM( EMENG )
    INTO LV_EMENG2
    FROM ZNFT1020
   WHERE ZEPRO = PV_ZEPRO
     AND ( YNCAN = ' ' OR ( YNCAN = 'X' AND ( CONFM = '5'
        OR CONFM = '6' OR CONFM = '8' ) ) ).

*___청산집행수량
  SELECT SUM( EMENG )
    INTO LV_EMENG3
    FROM ZNFT1030
   WHERE ZEPRO = PV_ZEPRO
     AND ( YNCAN = ' ' OR ( YNCAN = 'X' AND ( CONFM = '5'
        OR CONFM = '6' OR CONFM = '8' ) ) ).

*___현재 작업중인 화면 수량
  LOOP AT GT_1020N INTO GS_1020 WHERE ZEPRO = PV_ZEPRO.
    IF SY-TABIX <> PV_TABIX.
      LV_EMENG4 = LV_EMENG4 + GS_1020-EMENG.
    ENDIF.
  ENDLOOP.

  LV_EMENG2 = LV_EMENG2 + LV_EMENG3 + LV_EMENG4.

  IF LV_EMENG2 >= LV_EMENG1.
    PV_ERROR = 'X'.
  ELSE.
    PV_EMENG = LV_EMENG1 - LV_EMENG2.
  ENDIF.

ENDFORM.                    " CHECK_EPRO_REMAIN_QUANTITY
*&---------------------------------------------------------------------*
*&      Form  F4HELP_FCM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_FCM  USING    PV_LIFNR.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX, GV_INDEX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_FCM.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_FCM.

  GET CURSOR LINE GV_LINE.

  SELECT A~LIFNR
         B~NAME1
    INTO TABLE GT_FCM
    FROM ZNFT0021 AS A
   INNER JOIN LFA1 AS B
      ON A~LIFNR = B~LIFNR
   WHERE A~BUKRS = GT_1011-BUKRS
     AND B~LOEVM = ' '.

  IF SY-SUBRC <> 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH 'FCM 정보가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD     = 'LIFNR'
      DYNPPROG     = SY-CPROG
      DYNPNR       = SY-DYNNR
      STEPL        = GV_LINE
      DYNPROFIELD  = 'GT_1020N-FCM'
      WINDOW_TITLE = 'FCM'
      VALUE_ORG    = 'S'
    TABLES
      VALUE_TAB    = GT_FCM.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID
          TYPE SY-MSGTY
        NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " F4HELP_FCM
*&---------------------------------------------------------------------*
*&      Form  F4HELP_ZEPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_ZEPRO  USING    PV_ZEPRO.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX, GV_INDEX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_EPRO.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_EPRO.

  GET CURSOR LINE GV_LINE.

  PERFORM GET_F4HELP_ZEPRO.

  CHECK GT_EPRO[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD     = 'ZEPRO'
      DYNPPROG     = SY-CPROG
      DYNPNR       = SY-DYNNR
      STEPL        = GV_LINE
      DYNPROFIELD  = 'GT_1020N-ZEPRO'
      WINDOW_TITLE = 'e-Pro 번호 선택'
      VALUE_ORG    = 'S'
    TABLES
      VALUE_TAB    = GT_EPRO.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID
          TYPE SY-MSGTY
        NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " F4HELP_ZEPRO
*&---------------------------------------------------------------------*
*&      Form  GET_F4HELP_ZEPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_F4HELP_ZEPRO .
  DATA: WHERE_CLAUSE(100).

  CLEAR : WHERE_CLAUSE.

*___현재라인의 집행일, FCM을 읽는다.
  SCR_FIELDS-FIELDNAME = 'GT_1020N-RUDAT'.
  SCR_FIELDS-STEPL     = GV_LINE.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'GT_1020N-FCM'.
  SCR_FIELDS-STEPL     = GV_LINE.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = SY-CPROG
      DYNUMB     = SY-DYNNR
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  LOOP AT SCR_FIELDS.
    CASE SCR_FIELDS-FIELDNAME.
      WHEN 'GT_1020N-RUDAT'.
        REPLACE ALL OCCURRENCES OF:
                '.' IN SCR_FIELDS-FIELDVALUE WITH '',
                '/' IN SCR_FIELDS-FIELDVALUE WITH '',
                '-' IN SCR_FIELDS-FIELDVALUE WITH ''.
        CONDENSE SCR_FIELDS-FIELDVALUE.
        GT_1020N-RUDAT = SCR_FIELDS-FIELDVALUE.
      WHEN 'GT_1020N-FCM'.
        GT_1020N-FCM   = SCR_FIELDS-FIELDVALUE.
        PERFORM CONVERSION_EXIT_ALPHA USING 'I' GT_1020N-FCM.
    ENDCASE.
  ENDLOOP.

  IF GT_1020N-FCM IS NOT INITIAL.
    CONCATENATE WHERE_CLAUSE ' AND FCM = ''' GT_1020N-FCM ''''
           INTO WHERE_CLAUSE.
  ENDIF.

  IF GT_1020N-RUDAT IS NOT INITIAL AND
     GT_1020N-RUDAT <> ' '.
    CONCATENATE WHERE_CLAUSE ' AND RUDAT = ''' GT_1020N-RUDAT ''''
           INTO WHERE_CLAUSE.
  ENDIF.

  REPLACE 'AND' IN WHERE_CLAUSE WITH ''.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_EPRO
    FROM ZNFT1021
   WHERE BUKRS = GT_1011-BUKRS
     AND BY_SL = GT_1011-BY_SL
     AND NFKEY = GT_1011-NFKEY
     AND (WHERE_CLAUSE).

  LOOP AT GT_EPRO.
*___FCM명
    PERFORM GET_LIFNR_DESC USING GT_EPRO-FCM
                                 GT_EPRO-NAME1.

*___잔량
    PERFORM CHECK_EPRO_REMAIN_QUANTITY USING GT_1011-BUKRS
                                             GT_EPRO-ZEPRO
                                             GV_LINE
                                             GT_EPRO-REMQTY
                                             GV_ERROR.
    IF GV_ERROR IS NOT INITIAL.
      DELETE GT_EPRO.
      CONTINUE.
    ENDIF.

    MODIFY GT_EPRO.
  ENDLOOP.

  IF GT_EPRO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '해당 e-Pro 정보가 존재하지 않습니다.'.
  ENDIF.

ENDFORM.                    " GET_F4HELP_ZEPRO
*&---------------------------------------------------------------------*
*&      Form  DELETE_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELETE_ROW .

  PERFORM CHECK_SELECTE_ROW USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '삭제'
                                 '선택한 라인을 삭제하시겠습니까?'
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
    DELETE GT_1020N WHERE CHECK = 'X'.

    MESSAGE S001 WITH '삭제되었습니다.'.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " DELETE_ROW
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTE_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTE_ROW  USING    PV_ERROR.
  DATA: LV_CNT      TYPE I.

  CLEAR : PV_ERROR, LV_CNT.

  LOOP AT GT_1020N WHERE CHECK = 'X'.
    LV_CNT = LV_CNT + 1.
  ENDLOOP.

  IF LV_CNT < 1.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택된 라인이 없습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_SELECTE_ROW
*&---------------------------------------------------------------------*
*&      Form  SAVE_FUTURES_TRADING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_FUTURES_TRADING  USING PV_FLAG.
  DATA: LV_CNT       TYPE I,
        LV_TEXT(100).

  PERFORM CHECK_FUTURES_TRADING USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  IF PV_FLAG IS INITIAL.
    LV_TEXT = '신규선물집행을 저장하시겠습니까?'.
  ELSE.
    LV_TEXT = '신규선물집행을 결재요청 하시겠습니까?'.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING '저장'
                                 LV_TEXT
                                 '1'
                                 GV_ANSWER.

  IF GV_ANSWER = '1'.
    CLEAR : LV_CNT, GV_FLAG.

    LOOP AT GT_1020N.
      PERFORM GET_TRADING_NO.

      GT_1020N-ERDAT = SY-DATLO.
      GT_1020N-ERZET = SY-TIMLO.
      GT_1020N-ERNAM = SY-UNAME.
      GT_1020N-AEDAT = SY-DATLO.
      GT_1020N-AEZET = SY-TIMLO.
      GT_1020N-AENAM = SY-UNAME.

      IF PV_FLAG IS INITIAL.
        GT_1020N-CONFM = '1'.   "생성
      ELSE.
        GT_1020N-CONFM = '2'.   "승인요청
      ENDIF.

      LV_CNT = LV_CNT + 1.

      MODIFY GT_1020N.
    ENDLOOP.

    MODIFY ZNFT1020 FROM TABLE GT_1020N.
    IF SY-SUBRC = 0.
*___신규선물집행 변경이력 저장
      LOOP AT GT_1020N INTO GS_1020.
        PERFORM SAVE_CHANGE_DOC USING ' '.
      ENDLOOP.

      COMMIT WORK.

      IF PV_FLAG IS INITIAL.
        MESSAGE S003 WITH '신규선물집행 정보가'
                          LV_CNT '건 저장되었습니다.'.
      ELSE.
        GV_FLAG = 'X'.

        MESSAGE S003 WITH '신규선물집행 정보가'
                          LV_CNT '건 결재요청되었습니다.'.
      ENDIF.

      PERFORM GET_FUTURES_TRADING_DATA.

      LEAVE TO SCREEN 0.
    ELSE.
      ROLLBACK WORK.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '신규선물집행 정보 저장 에러!'.
    ENDIF.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " SAVE_FUTURES_TRADING
*&---------------------------------------------------------------------*
*&      Form  CHECK_FUTURES_TRADING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_FUTURES_TRADING  USING    PV_ERROR.

  CLEAR : PV_ERROR.

  LOOP AT GT_1020N.
*___집행일
    IF GT_1020N-RUDAT IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_1020N-RUDAT'.
      GV_CURLIN    = 1.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '집행일이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

*___FCM
    IF GT_1020N-FCM IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_1020N-FCM'.
      GV_CURLIN    = 1.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH 'FCM이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

*___만기일
    IF GT_1020N-ENDAT IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_1020N-ENDAT'.
      GV_CURLIN    = 1.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '만기일이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

*___집행유형
    IF GT_1020N-MITYP IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_1020N-MITYP'.
      GV_CURLIN    = 1.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '집행유형이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

*___기준월 - 집행유형 'A'인 경우 필수
    IF GT_1020N-MITYP = 'A' AND GT_1020N-MIMON IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_1020N-MIMON'.
      GV_CURLIN    = 1.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '기준월이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

*___집행단가
    IF GT_1020N-MITYP = 'S' AND GT_1020N-PRICE IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_1020N-PRICE'.
      GV_CURLIN    = 1.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '집행단가가 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

*___집행수량
    IF GT_1020N-EMENG IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_1020N-EMENG'.
      GV_CURLIN    = 1.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '집행수량이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

*___수수료여부
    IF GT_1020N-MISUS IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_1020N-MISUS'.
      GV_CURLIN    = 1.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '수수료여부가 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

*--> 단위 체크
    IF GT_1020N-MEINS IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = SY-TABIX.
      GV_CURSOR    = 'GT_1020N-MEINS'.
      GV_CURLIN    = 1.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '단위(TON or LB)를 입력하세요.'.
      EXIT.
    ENDIF.
*<-- 단위 체크
  ENDLOOP.

  IF SY-SUBRC <> 0.
    PV_ERROR = 'X'.

    MESSAGE I003 DISPLAY LIKE 'E'
       WITH '입력된 신규선물집행이 없습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_FUTURES_TRADING
*&---------------------------------------------------------------------*
*&      Form  GET_TRADING_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_TRADING_NO .

  CLEAR : GT_1020N-NFUTN.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '10'
      OBJECT                  = 'ZNF2_00003'
    IMPORTING
      NUMBER                  = GT_1020N-NFUTN
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " GET_TRADING_NO
*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_CHANGE_DOC USING PV_FLAG.
  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND,
        LV_UPD_ICDTXT      TYPE CHAR1.

  IF PV_FLAG = 'X'.
    LV_CDOC_UPD_OBJECT = 'U'.
  ELSE.
    LV_CDOC_UPD_OBJECT = 'I'.
  ENDIF.

  CLEAR : ZNFT1020, YZNFT1020.

  IF PV_FLAG IS NOT INITIAL.
    SELECT SINGLE *
      INTO YZNFT1020
      FROM ZNFT1020
     WHERE NFUTN = GS_1020-NFUTN.

    ZNFT1020-CONFM = '1'.
  ENDIF.

  MOVE-CORRESPONDING GS_1020 TO ZNFT1020.

  LV_OBJECTID = GS_1020-NFUTN.
  LV_TCODE    = SY-TCODE.

  CALL FUNCTION 'ZNFT1020CHDOC_WRITE_DOCUMENT'
    EXPORTING
      OBJECTID     = LV_OBJECTID
      TCODE        = LV_TCODE
      UTIME        = SY-TIMLO
      UDATE        = SY-DATLO
      USERNAME     = SY-UNAME
      N_ZNFT1020   = ZNFT1020
      O_ZNFT1020   = YZNFT1020
      UPD_ZNFT1020 = LV_CDOC_UPD_OBJECT.

ENDFORM.                    " SAVE_CHANGE_DOC
*&---------------------------------------------------------------------*
*&      Form  CONFIRM_REQEUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONFIRM_REQEUST .
  DATA: LV_CNT  TYPE I,
        LV_FLAG.

  CLEAR : LV_FLAG.

  LOOP AT GT_1020 WHERE CHECK = 'X'.
    IF GT_1020-CONFM <> '1'.
      LV_FLAG = 'X'.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '선택된 라인의 상태를 확인하세요. 집행번호:'
              GT_1020-NFUTN.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF SY-SUBRC <> 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택된 라인이 없습니다.'.
    EXIT.
  ENDIF.

  CHECK LV_FLAG IS INITIAL.

  PERFORM POPUP_TO_CONFIRM
    USING '저장'
          '신규선물집행을 결재요청 하시겠습니까?'
          '1'
          GV_ANSWER.

  IF GV_ANSWER = '1'.
    CLEAR : LV_CNT, LV_FLAG.

    LOOP AT GT_1020 WHERE CHECK = 'X'.
      GT_1020-CONFM = '2'.

      UPDATE ZNFT1020 SET CONFM = GT_1020-CONFM
                          AEDAT = SY-DATLO
                          AEZET = SY-TIMLO
                          AENAM = SY-UNAME
                    WHERE NFUTN = GT_1020-NFUTN.

      IF SY-SUBRC <> 0.
        LV_FLAG = 'X'.
        EXIT.
      ENDIF.

      LV_CNT = LV_CNT + 1.

      MODIFY GT_1020.
    ENDLOOP.

    IF LV_FLAG IS INITIAL.
*___신규선물집행 변경이력 저장
      LOOP AT GT_1020 INTO GS_1020.
        PERFORM SAVE_CHANGE_DOC USING 'X'.
      ENDLOOP.

      COMMIT WORK.

      MESSAGE S003 WITH '신규선물집행 정보가'
                        LV_CNT '건 결재요청되었습니다.'.

      CLEAR : GS_1020.
      LOOP AT GT_1020 INTO GS_1020 WHERE CHECK = 'X'.
*--- 간편결재 전송.
        PERFORM SEND_SIMPLE_APPROVAL
        USING GS_1020-NFUTN
              GS_1020-BUKRS
              '2D'.
      ENDLOOP.

*      PERFORM GET_FUTURES_TRADING_DATA.
      PERFORM GET_FUTURES_REQ_DATA.

      LEAVE TO SCREEN 0.
    ELSE.
      ROLLBACK WORK.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '신규선물집행 정보 저장 에러!'.
    ENDIF.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " CONFIRM_REQEUST
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_CONNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_CONNO .

  IF GT_1011-CONNO IS NOT INITIAL.
    SET PARAMETER ID 'ZNFCON' FIELD GT_1011-CONNO.

    CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
  ENDIF.

ENDFORM.                    " DISPLAY_CONNO
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_REQNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_REQNO .

  IF GT_1011-REQNO IS NOT INITIAL.
    SET PARAMETER ID 'ZNFREQ' FIELD GT_1011-REQNO.

    CALL TRANSACTION 'ZNF2M2103' AND SKIP FIRST SCREEN.
  ENDIF.

ENDFORM.                    " DISPLAY_REQNO
*&---------------------------------------------------------------------*
*&      Form  INSERT_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_ROW .
  DATA: LT_RETURN   LIKE CASDAYATTR OCCURS 0 WITH HEADER LINE.

  CLEAR : GT_1020N.

  GT_1020N-NFKEY = GT_1011-NFKEY.
  GT_1020N-BY_SL = GT_1011-BY_SL.

  GT_1020N-RUDAT = SY-DATLO.        "집행일

  DO 30 TIMES.
    GT_1020N-RUDAT = GT_1020N-RUDAT - 1.

    CLEAR   : LT_RETURN.
    REFRESH : LT_RETURN.

    CALL FUNCTION 'DAY_ATTRIBUTES_GET'
      EXPORTING
        FACTORY_CALENDAR           = 'L3'
        HOLIDAY_CALENDAR           = 'LS'
        DATE_FROM                  = GT_1020N-RUDAT
        DATE_TO                    = GT_1020N-RUDAT
        LANGUAGE                   = SY-LANGU
      TABLES
        DAY_ATTRIBUTES             = LT_RETURN
      EXCEPTIONS
        FACTORY_CALENDAR_NOT_FOUND = 1
        HOLIDAY_CALENDAR_NOT_FOUND = 2
        DATE_HAS_INVALID_FORMAT    = 3
        DATE_INCONSISTENCY         = 4
        OTHERS                     = 5.

    READ TABLE LT_RETURN INDEX 1.
    IF LT_RETURN-FREEDAY NE 'X'. "휴일아님
      EXIT.
    ENDIF.
  ENDDO.

  APPEND GT_1020N.

  GV_CURSOR = 'GT_1020N-RUDAT'.

  IF TC1-LINES IS INITIAL.
    TC1-TOP_LINE = 1.
    GV_CURLIN = 1.
  ELSE.
    IF TC1-LINES >= GV_LOOPC.
      TC1-TOP_LINE = TC1-LINES - GV_LOOPC + 2.

      GV_CURLIN    = GV_LOOPC.
    ELSE.
      TC1-TOP_LINE = 1.

      GV_CURLIN    = TC1-LINES + 1.
    ENDIF.
  ENDIF.

ENDFORM.                    " INSERT_ROW
*&---------------------------------------------------------------------*
*&      Form  CHECK_REQ_REMAIN_QUANTITY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_REQ_REMAIN_QUANTITY .
  DATA: LV_EMENG    LIKE ZNFT1020-EMENG.

  CLEAR : LV_EMENG.

*___기 등록된 선물집행 수량
  LOOP AT GT_1020.
    LV_EMENG = LV_EMENG + GT_1020-EMENG.
  ENDLOOP.

*___현재 화면상의 선물집행 수량
  LOOP AT GT_1020N INTO GS_1020.
    IF SY-TABIX <> TC1-CURRENT_LINE.
      LV_EMENG = LV_EMENG + GS_1020-EMENG.
    ENDIF.
  ENDLOOP.

*___요청잔량
  LV_EMENG = GT_1011-EMENG - LV_EMENG.

  IF GT_1020N-EMENG > LV_EMENG.
    CLEAR : GT_1020N-EMENG.

    MESSAGE E003 WITH '집행수량이 선물요청 잔량을 초과하였습니다.'
                      '선물요청잔량 :' LV_EMENG 'Ton'.
  ENDIF.

ENDFORM.                    " CHECK_REQ_REMAIN_QUANTITY
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELLEMENT_FCM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELLEMENT_FCM.
  DATA: LV_NCCHK    LIKE ZNFT1050-NCCHK.

  CLEAR : LV_NCCHK.

  SELECT SINGLE NCCHK
    INTO LV_NCCHK
    FROM ZNFT1050
   WHERE BUKRS = P_BUKRS
     AND ENDAT = GT_1020N-ENDAT
     AND FCM   = GT_1020N-FCM.

  IF LV_NCCHK = 'X'.
    MESSAGE E003 WITH '만기일/FCM' GT_1020N-ENDAT GT_1020N-FCM
                      '에 대한 정산이 진행되었습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_SELLEMENT_FCM
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_FUTRUES_HISTORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_FUTRUES_HISTORY.
  DATA: LT_RSPAR LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

  CLEAR   : LT_RSPAR.
  REFRESH : LT_RSPAR.

  APPEND_PARAM : LT_RSPAR 'P_BUKRS' 'P' ' ' ' '  P_BUKRS       ' ',
                 LT_RSPAR 'S_NFUTN' 'S' 'I' 'EQ' GT_1020-NFUTN ' ',
                 LT_RSPAR 'P_CHK11' 'P' ' ' ' '  'X'           ' ',
                 LT_RSPAR 'P_CHK12' 'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R01'   'P' ' ' ' '  ' '           ' ',
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
*& Form SEND_SIMPLE_APPROVAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_1020_NFUTN
*&      --> GS_1020_BUKRS
*&      --> P_
*&---------------------------------------------------------------------*
FORM SEND_SIMPLE_APPROVAL  USING    P_EXENO
                                    P_BUKRS
                                    P_TYPE TYPE ZESAZTYPE.

  CALL FUNCTION 'ZSA1_MM_MAKE_SEND_DATA'
    EXPORTING
      I_BUKRS = P_BUKRS
      I_EXENO = P_EXENO
      I_EXTYP = P_TYPE.


ENDFORM.
