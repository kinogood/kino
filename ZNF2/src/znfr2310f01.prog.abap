*----------------------------------------------------------------------*
***INCLUDE ZNFR2310F01 .
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

  CLEAR : GV_TRTYP, GV_TITLE.

*___T-Code별 Transaction 유형
  IF SY-TCODE = GC_TCODE2.
    GV_TITLE = '변경'.
    GV_TRTYP = 'V'.      "변경

    CLEAR : P_CHK02, P_CHK03, P_CHK04,
            P_CHK05, P_CHK06, P_CHK07,
            P_CHK08.
  ELSE.
    GV_TITLE = 'List 조회'.
    GV_TRTYP = 'A'.      "조회

    CLEAR : P_CHK07, P_CHK08.
  ENDIF.

  SET TITLEBAR '100' WITH GV_TITLE.

ENDFORM.                    " SET_DEFAULT_PARAMETER
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
  IF SY-DYNNR = '1000'.
    SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
    APPEND SCR_FIELDS.

    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        DYNAME     = 'ZNFR2310'
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
*&      Form  F4HELP_MONTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_MONTH  USING  PV_MONTH.

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      ACTUAL_MONTH   = SY-DATLO(6)
    IMPORTING
      SELECTED_MONTH = PV_MONTH.

ENDFORM.                    " F4HELP_MONTH
*&---------------------------------------------------------------------*
*&      Form  F4HELP_PRCTR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_PRCTR  USING    PV_PRCTR.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_PRCTR.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_PRCTR.

*___화면상의 데이터를 읽는다.
  SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = 'ZNFR2310'
      DYNUMB     = '1000'
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  LOOP AT SCR_FIELDS.
    CASE SCR_FIELDS-FIELDNAME.
      WHEN 'P_BUKRS'.
        P_BUKRS      = SCR_FIELDS-FIELDVALUE.

    ENDCASE.
  ENDLOOP.

  SELECT PRCTR
*         PTEXT
    INTO CORRESPONDING FIELDS OF TABLE GT_PRCTR
    FROM ZNFT0004
   WHERE KOKRS   =  P_BUKRS   "관리회계영역
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
      DYNAME     = 'ZNFR2310'
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

  IF P_CHK01 IS INITIAL AND P_CHK02 IS INITIAL AND
     P_CHK03 IS INITIAL AND P_CHK04 IS INITIAL AND
     P_CHK05 IS INITIAL AND P_CHK06 IS INITIAL AND
     P_CHK07 IS INITIAL AND P_CHK08 IS INITIAL.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '결재상태를 선택하시기 바랍니다.'.

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

  CLEAR   : GR_DRSTA.
  REFRESH : GR_DRSTA.

*___결재상태
  IF P_CHK01 = 'X'.
    APPEND_RANGES GR_DRSTA 'I' 'EQ' '1' ' '.
  ENDIF.

  IF P_CHK02 = 'X'.
    APPEND_RANGES GR_DRSTA 'I' 'EQ' '2' ' '.
  ENDIF.

  IF P_CHK03 = 'X'.
    APPEND_RANGES GR_DRSTA 'I' 'EQ' '3' ' '.
  ENDIF.

  IF P_CHK04 = 'X'.
    APPEND_RANGES GR_DRSTA 'I' 'EQ' '4' ' '.
  ENDIF.

  IF P_CHK05 = 'X'.
    APPEND_RANGES GR_DRSTA 'I' 'EQ' '5' ' '.
  ENDIF.

  IF P_CHK06 = 'X'.
    APPEND_RANGES GR_DRSTA 'I' 'EQ' '6' ' '.
  ENDIF.

  IF P_CHK07 = 'X'.
    APPEND_RANGES GR_DRSTA 'I' 'EQ' '7' ' '.
  ENDIF.

  IF P_CHK08 = 'X'.
    APPEND_RANGES GR_DRSTA 'I' 'EQ' '8' ' '.
  ENDIF.

ENDFORM.                    " SET_RANGES
*&---------------------------------------------------------------------*
*&      Form  GET_SHIFT_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SHIFT_REQ_DATA .

  CLEAR   : GT_MAIN.
  REFRESH : GT_MAIN.

  SELECT A~BUKRS             "회사코드
         A~SHFNO             "만기이동요청번호
         A~DRSTA             "결재상태
         B~H_NO1             "항번
         A~ERDAT             "만기이동요청일
         B~REMON             "요청만기월
         B~RMENG             "요청수량
         B~MEINS             "단위
         A~BIGO4             "만기이동요청사유
         B~NFUTN             "신규선물집행번호
         B~RUDAT             "신규집행일
         B~ENDAT             "신규만기일
         B~PRICE             "신규집행단가
         B~MISPD             "신규Spread
         B~WAERS             "통화
         A~OFUTN             "선물집행번호
         C~FCM               "FCM
         C~RUDAT AS RUDAT1   "집행일
         C~NFKEY             "비철구분
         C~BY_SL             "Buy/Sell
         C~ENDAT AS ENDAT1   "만기일
         C~MITYP             "집행유형
         C~MISPD AS MISPD1   "Spread
         C~MIMON             "기준월
         C~PRICE AS PRICE1   "집행단가
         C~EMENG             "집행수량
         C~REQNO             "선물요청번호
         C~H_NO1 AS H_NO2    "선물요청항번
         D~CONNO             "계약번호
         E~COTXT             "계약명
         E~PRCTR             "손익센터
         E~VKGRP             "영업그룹
         E~KUNNR             "고객코드
         E~NCUST             "고객명
         E~SALER             "영업담당자
         E~ZPJNO             "Project NO
    INTO CORRESPONDING FIELDS OF TABLE GT_MAIN
    FROM ZNFT1040 AS A
   INNER JOIN ZNFT1041 AS B
      ON A~SHFNO = B~SHFNO
   INNER JOIN ZNFT1020 AS C
      ON A~OFUTN = C~NFUTN
   INNER JOIN ZNFT1011 AS D
      ON C~REQNO = D~REQNO
     AND C~H_NO1 = D~H_NO1
   INNER JOIN ZNFT1000 AS E
      ON D~CONNO = E~CONNO
   WHERE A~BUKRS =  P_BUKRS
     AND A~DRSTA IN GR_DRSTA
     AND A~SHFNO IN S_SHFNO
     AND A~ERDAT IN S_ERDAT
     AND A~OFUTN IN S_NFUTN
     AND B~REMON IN S_REMON
     AND B~GUBUN =  '1'
     AND C~FCM   IN S_FCM
     AND C~NFKEY IN S_NFKEY
     AND D~REQNO IN S_REQNO
     AND D~CONNO IN S_CONNO
     AND E~ZPJNO IN S_ZPJNO
     AND E~PRCTR IN S_PRCTR
     AND E~VKGRP IN S_VKGRP.

  LOOP AT GT_MAIN.
*___최초만기월 점검
    IF NOT GT_MAIN-ENDAT1(6) IN S_ENDMM.
      DELETE GT_MAIN.
      CONTINUE.
    ENDIF.

*___승인자사번
    SELECT SINGLE PERNR
      INTO GT_MAIN-PERNR
      FROM ZNFT1091
     WHERE NFNUM = GT_MAIN-SHFNO
       AND CONSQ = '1'.

*...청산선물집행번호
    IF GT_MAIN-NFUTN IS INITIAL.
      IF GT_MAIN-OFUTN IS NOT INITIAL.
        SELECT SINGLE CFUTN
          INTO GT_MAIN-CFUTN
          FROM ZNFT1030
         WHERE BUKRS = P_BUKRS
           AND NFUTN = GT_MAIN-OFUTN
           AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) )
           AND YNNET = ' '.
      ENDIF.
    ELSE.
      SELECT SINGLE CFUTN
        INTO GT_MAIN-CFUTN
        FROM ZNFT1030
       WHERE BUKRS = P_BUKRS
         AND NFUTN = GT_MAIN-NFUTN
         AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) )
         AND YNNET = ' '.
    ENDIF.

*___만기이동차수
    PERFORM GET_SHIFT_COUNT USING GT_MAIN-OFUTN
                                  GT_MAIN-SHFCNT.

*___승인자명
    PERFORM GET_PERNR_DESC USING GT_MAIN-PERNR
                                 GT_MAIN-ENAME.

*___FCM 명
    PERFORM GET_LIFNR_DESC USING GT_MAIN-FCM
                                 GT_MAIN-NAME1.

*___Buy/Sell 내역
    PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                   GT_MAIN-BY_SL
                                   GT_MAIN-BSTXT.
*___결재상태내역
    PERFORM DOMAIN_VALUE_GET USING 'ZDRSTA'
                                   GT_MAIN-DRSTA
                                   GT_MAIN-DRTXT.

*___집행유형 내역
    PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                   GT_MAIN-MITYP
                                   GT_MAIN-MITPT.

*___손익센터명
    PERFORM GET_PRCTR_DESC USING GV_KOKRS
                                 GT_MAIN-PRCTR
                                 GT_MAIN-PTEXT.

*___영업그룹명
    PERFORM GET_VKGRP_DESC USING GV_KOKRS
                                 GT_MAIN-VKGRP
                                 GT_MAIN-VTEXT.

    MODIFY GT_MAIN.
  ENDLOOP.

ENDFORM.                    " GET_SHIFT_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_RESULT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_RESULT .

  PERFORM CREATE_FIELD_CATEGORY.

  PERFORM DISPLAY_ALV_LIST.

ENDFORM.                    " DISPLAY_RESULT
*&---------------------------------------------------------------------*
*&      Form  CREATE_FIELD_CATEGORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_FIELD_CATEGORY .

  CLEAR   : GS_LAYOUT, GV_POS.

  GV_ITAB = 'GT_MAIN'.

  GS_LAYOUT-ZEBRA             = 'X'.
  GS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  GS_LAYOUT-BOX_FIELDNAME     = 'CHECK'.

  CLEAR   : GS_FIELDCAT.
  REFRESH : GT_FIELDCAT.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_FIELDCAT_DATA TABLES GT_FIELDCAT
                              USING :
      'BUKRS'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      ' '              'BUKRS' 'ZNFT1040' ' ' ' '    'X' ' ' ' ' ' ',

      'SHFNO'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '              'SHFNO' 'ZNFT1040' ' ' ' '    'X' ' ' ' ' ' ',

      'H_NO1'    ' '      ' '     ' ' ' ' 'R' ' '    'X' ' ' ' ' 5
      ' '              'H_NO1' 'ZNFT1041' ' ' ' '    'X' ' ' ' ' ' ',

      'SHFCNT'   ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 5
      '만기이동차수'   ' '     ' '        ' ' 'INT4' 'X' ' ' ' ' ' ',

      'DRSTA'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '              'DRSTA' 'ZNFT1040' ' ' ' '    'X' ' ' ' ' ' ',

      'DRTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '결재상태내역'   ' '     ' '        ' ' ' '    'X' ' ' ' ' ' ',

      'PERNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 8
      '승인자사번'     'PERNR' 'ZNFT1091' ' ' ' '    'X' ' ' ' ' ' ',

      'ENAME'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '승인자명'       'ENAME' 'PA0001'   ' ' ' '    'X' ' ' ' ' ' ',

      'ERDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '만기이동요청일' 'ERDAT' 'ZNFT1040' ' ' ' '    'X' ' ' ' ' ' ',

      'REMON'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '              'REMON' 'ZNFT1041' ' ' ' '    'X' ' ' ' ' ' ',

      'RMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '              'RMENG' 'ZNFT1041' ' ' ' '    ' ' ' ' ' ' ' ',

      'BIGO4'    ' '      ''      ' ' ' ' 'L' ' '    ' ' ' ' ' ' 100
      ' '              'BIGO4' 'ZNFT1040' ' ' ' '    ' ' ' ' ' ' ' '.

  IF GV_TRTYP = 'A'.
    PERFORM MAKE_FIELDCAT_DATA TABLES GT_FIELDCAT
                                USING :
      'NFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '신규선물집행번호' 'NFUTN' 'ZNFT1041' ' ' ' '  'X' ' ' ' ' ' ',

      'RUDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '신규집행일'     'RUDAT' 'ZNFT1041' ' ' ' '    'X' ' ' ' ' ' ',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '신규만기일'     'ENDAT' 'ZNFT1041' ' ' ' '    'X' ' ' ' ' ' ',

      'MISPD'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '신규 Spread'    'MISPD' 'ZNFT1041' ' ' ' '    ' ' ' ' ' ' ' ',

      'PRICE'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '신규집행단가'   'PRICE' 'ZNFT1041' ' ' ' '    ' ' ' ' ' ' ' '.
  ENDIF.

  PERFORM MAKE_FIELDCAT_DATA TABLES GT_FIELDCAT
                              USING :
      'OFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'OFUTN' 'ZNFT1040' ' ' ' '    'X' ' ' ' ' ' ',

      'FCM'      ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'FCM'   'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'NAME1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      'FCM 명'         'NAME1' 'LFA1'     ' ' ' '    'X' ' ' ' ' ' ',

      'RUDAT1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'RUDAT' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'NFKEY' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'BY_SL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      ' '              'BY_SL' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'BSTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      'Buy/Sell'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ENDAT1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'ENDAT' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'MITYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '              'MITYP' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'MITPT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '집행유형내역'   ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'MISPD1'   'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '              'MISPD' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'MIMON'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '              'MIMON' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'PRICE1'   'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '              'PRICE' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'WAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      ' '              'WAERS' 'ZNFT1041' ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'EMENG' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'MEINS' 'ZNFT1041' ' ' ' '    'X' ' ' ' ' ' ',

      'REQNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'REQNO' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'H_NO2'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 5
      ' '              'H_NO1' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'CONNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'CONNO' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' ',

      'COTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '              'COTXT' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'PRCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'PRCTR' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'PTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '손익센터명'     'PTEXT' 'ZNFT0004' ' ' ' '    'X' ' ' ' ' ' ',

      'ZPJNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'ZPJNO' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'KUNNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'KUNNR' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'NCUST'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '              'NCUST' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'VKGRP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'VKGRP' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'VTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'VTEXT' 'ZNFT0003' ' ' ' '    'X' ' ' ' ' ' ',

      'SALER'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '            'SALER'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'CFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '청산선물집행번호' 'CFUTN' 'ZNFT1030' ' ' ' '  'X' ' ' ' ' ' '.

ENDFORM.                    " CREATE_FIELD_CATEGORY
*&---------------------------------------------------------------------*
*&      Form  MAKE_FIELDCAT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MAKE_FIELDCAT_DATA  TABLES PT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV
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

  DATA : LS_FIELDCAT          TYPE SLIS_FIELDCAT_ALV.

  CLEAR : LS_FIELDCAT.

  GV_POS = GV_POS + 1.

  LS_FIELDCAT-COL_POS        = GV_POS.
  LS_FIELDCAT-FIELDNAME      = PV_FNAME.
  LS_FIELDCAT-CFIELDNAME     = PV_CURK.
  LS_FIELDCAT-QFIELDNAME     = PV_UNIT.
  LS_FIELDCAT-ICON           = PV_ICON.
  LS_FIELDCAT-CHECKBOX       = PV_CHECK.
  LS_FIELDCAT-JUST           = PV_JUST.
  LS_FIELDCAT-EMPHASIZE      = PV_EMPHA.
  LS_FIELDCAT-FIX_COLUMN     = PV_FIX.
  LS_FIELDCAT-KEY            = PV_FIX.
  LS_FIELDCAT-NO_OUT         = PV_NOOUT.
  LS_FIELDCAT-NO_ZERO        = PV_NOZERO.
  LS_FIELDCAT-OUTPUTLEN      = PV_LENGTH.
  LS_FIELDCAT-SELTEXT_S      = PV_TEXT.
  LS_FIELDCAT-SELTEXT_M      = PV_TEXT.
  LS_FIELDCAT-SELTEXT_L      = PV_TEXT.
  LS_FIELDCAT-REPTEXT_DDIC   = PV_TEXT.
  LS_FIELDCAT-REF_FIELDNAME  = PV_REFF.
  LS_FIELDCAT-REF_TABNAME    = PV_REFT.
  LS_FIELDCAT-TECH           = PV_TECH.
  LS_FIELDCAT-DATATYPE       = PV_TYPE.
  LS_FIELDCAT-NO_SUM         = PV_NOSUM.
  LS_FIELDCAT-DO_SUM         = PV_DOSUM.
  LS_FIELDCAT-HOTSPOT        = PV_HOTSPOT.
  LS_FIELDCAT-EDIT           = PV_EDIT.

  LS_FIELDCAT-TABNAME        = GV_ITAB.

  APPEND LS_FIELDCAT TO PT_FIELDCAT.

ENDFORM.                    " MAKE_FIELDCAT_DATA
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_ALV_LIST.

  GS_VARIANT-REPORT  = SY-REPID.

  IF GV_TRTYP = 'A'.
    GS_VARIANT-HANDLE  = '0001'.
  ELSE.
    GS_VARIANT-HANDLE  = '0002'.
  ENDIF.

  GV_REPID = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_USER_COMMAND  = GV_USER_COMMAND
      I_CALLBACK_PF_STATUS_SET = GV_STATUS_SET
*      I_CALLBACK_TOP_OF_PAGE   = GV_TOP_OF_PAGE
      I_CALLBACK_PROGRAM       = GV_REPID
      I_GRID_SETTINGS          = GV_GRID_SETTINGS
      IS_LAYOUT                = GS_LAYOUT
      IT_FIELDCAT              = GT_FIELDCAT
      IT_SORT                  = GT_SORT
      I_SAVE                   = 'A'
      IS_VARIANT               = GS_VARIANT
      IT_EVENTS                = GT_EVENTS
      IT_EVENT_EXIT            = GT_EVENTS_EXIT
    TABLES
      T_OUTTAB                 = GT_MAIN
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

  IF SY-SUBRC <> 0.
    MESSAGE E003 WITH 'Grid Display Error!'.
  ENDIF.

ENDFORM.                    " DISPLAY_ALV_LIST
*&---------------------------------------------------------------------
*& Form PF_STATUS_SET
*&---------------------------------------------------------------------
FORM PF_STATUS_SET USING  EXTAB  TYPE  SLIS_T_EXTAB.
  DATA: LS_EXTAB  TYPE SLIS_EXTAB.

  IF GV_TRTYP = 'A'.
    LS_EXTAB-FCODE = 'CHNG'.
    APPEND LS_EXTAB TO EXTAB.
  ENDIF.

  SET PF-STATUS 'STANDARD' EXCLUDING  EXTAB .
  SET TITLEBAR  '100'      WITH GV_TITLE.

ENDFORM.                " PF_STATUS_SET
*&---------------------------------------------------------------------
*& Form USER_COMMAND
*&---------------------------------------------------------------------
FORM USER_COMMAND USING PV_UCOMM
                        PS_SELFIELD TYPE SLIS_SELFIELD.
  CASE PV_UCOMM.
    WHEN 'CHNG'.
      PERFORM CHECK_SELECTED_ROWS.
      IF GV_ERROR IS INITIAL AND GT_MAIN-SHFNO IS NOT INITIAL.
        SET PARAMETER ID 'ZNFSHF' FIELD GT_MAIN-SHFNO.

        CALL TRANSACTION 'ZNF2M2302' AND SKIP FIRST SCREEN.

        PERFORM GET_SHIFT_REQ_DATA.
      ENDIF.

    WHEN 'RFSH'.
      PERFORM GET_SHIFT_REQ_DATA.

    WHEN '&IC1'.
      CASE PS_SELFIELD-FIELDNAME.
        WHEN 'SHFNO'.
          IF PS_SELFIELD-VALUE IS NOT INITIAL.
            SET PARAMETER ID 'ZNFSHF' FIELD PS_SELFIELD-VALUE.

            CALL TRANSACTION 'ZNF2M2303' AND SKIP FIRST SCREEN.
          ENDIF.

        WHEN 'CONNO'.
          IF PS_SELFIELD-VALUE IS NOT INITIAL.
            SET PARAMETER ID 'ZNFCON' FIELD PS_SELFIELD-VALUE.

            CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
          ENDIF.

        WHEN 'REQNO'.
          IF PS_SELFIELD-VALUE IS NOT INITIAL.
            SET PARAMETER ID 'ZNFREQ' FIELD PS_SELFIELD-VALUE.

            CALL TRANSACTION 'ZNF2M2103' AND SKIP FIRST SCREEN.
          ENDIF.

        WHEN 'NFUTN' OR 'OFUTN'.
          IF PS_SELFIELD-VALUE IS NOT INITIAL.
            PERFORM DISPLAY_FUTRUES_HISTORY USING PS_SELFIELD-VALUE.
          ENDIF.

      ENDCASE.
  ENDCASE.

  PS_SELFIELD-REFRESH    = 'X'.
  PS_SELFIELD-COL_STABLE = 'X'.
  PS_SELFIELD-ROW_STABLE = 'X'.

ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_ROWS .
  DATA: LV_CNT      TYPE I.

  CLEAR : LV_CNT, GV_ERROR.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    LV_CNT = LV_CNT + 1.
  ENDLOOP.

  IF LV_CNT > 1.
    GV_ERROR = 'X'.

    MESSAGE S001 DISPLAY LIKE 'E'
       WITH '한 라인만 선택하시기 바랍니다.'.
  ELSEIF LV_CNT < 1.
    GV_ERROR = 'X'.

    MESSAGE S001 DISPLAY LIKE 'E'
       WITH '선택된 라인이 없습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_FUTRUES_HISTORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_FUTRUES_HISTORY USING PV_NFUTN.
  DATA: LT_RSPAR LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

  CLEAR   : LT_RSPAR.
  REFRESH : LT_RSPAR.

  APPEND_PARAM : LT_RSPAR 'P_BUKRS' 'P' ' ' ' '  P_BUKRS       ' ',
                 LT_RSPAR 'S_NFUTN' 'S' 'I' 'EQ' PV_NFUTN      ' ',
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
*&      Form  GET_SHIFT_COUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_SHIFT_COUNT  USING  PV_NFUTN
                             PV_SHFCNT.
  DATA: LV_NFUTN    LIKE ZNFT1020-NFUTN,
        LV_WHYCN    LIKE ZNFT1020-WHYCN.

  CLEAR : PV_SHFCNT.

  CHECK PV_NFUTN IS NOT INITIAL.

  LV_NFUTN = PV_NFUTN.

  PV_SHFCNT = PV_SHFCNT + 1.

  DO.
    SELECT SINGLE OLDFT
      INTO LV_NFUTN
      FROM ZNFT1020
     WHERE NFUTN = LV_NFUTN.

    IF SY-SUBRC <> 0 OR LV_NFUTN IS INITIAL.
      EXIT.
    ENDIF.

    CLEAR : LV_WHYCN.

    SELECT SINGLE WHYCN
      INTO LV_WHYCN
      FROM ZNFT1020
     WHERE NFUTN = LV_NFUTN.

    IF LV_WHYCN = '1'.
      PV_SHFCNT = PV_SHFCNT + 1.
    ENDIF.
  ENDDO.

ENDFORM.                    " GET_SHIFT_COUNT
