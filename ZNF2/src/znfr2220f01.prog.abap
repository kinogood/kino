*----------------------------------------------------------------------*
***INCLUDE ZNFR2220F01 .
*----------------------------------------------------------------------*
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
        DYNAME     = 'ZNFR2220'
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
      DYNAME     = 'ZNFR2220'
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
*&---------------------------------------------------------------------*
*&      Form  SET_RANGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_RANGES .

  CLEAR   : GR_BY_SL.
  REFRESH : GR_BY_SL.

  IF P_CHK01 = 'X'.
    APPEND_RANGES GR_BY_SL 'I' 'EQ' 'B' ' '.
  ENDIF.

  IF P_CHK02 = 'X'.
    APPEND_RANGES GR_BY_SL 'I' 'EQ' 'S' ' '.
  ENDIF.

ENDFORM.                    " SET_RANGES
*&---------------------------------------------------------------------*
*&      Form  GET_ZNFT1020_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ZNFT1020_DATA .
  DATA: LV_CFUTN    LIKE ZNFT1030-CFUTN.

  CLEAR   : GT_1020.
  REFRESH : GT_1020.

*--{기능개선_256766 - 수정
*  SELECT *
*    INTO CORRESPONDING FIELDS OF TABLE GT_1020
*    FROM ZNFT1020
*   WHERE BUKRS = P_BUKRS
*     AND NFUTN IN S_NFUTN
*     AND REQNO IN S_REQNO
*     AND NFKEY IN S_NFKEY
*     AND FCM   IN S_FCM
*     AND BY_SL IN GR_BY_SL
*     AND RUDAT IN S_RUDAT
*     AND ENDAT IN S_ENDAT
*     AND YNCAN =  ' '
*     AND YNFIN =  ' '
*     AND ( CONFM = '3' OR CONFM = '7' ).

  SELECT A~MANDT A~NFUTN A~BUKRS A~REQNO A~H_NO1 A~NFKEY A~RUDAT
         A~FCM   A~BY_SL A~ENDAT A~MITYP A~MISPD A~MIMON A~PRICE
         A~WAERS A~EMENG A~MEINS A~MISUS A~CONFM A~YNCAN A~WHYCN
         A~YNFIN A~ZEPRO A~YNNET A~OLDFT A~BIGO4 A~RESON A~CONAM
         A~CODAT A~COZET A~LCNAM A~LCDAT A~LCZET A~ERNAM A~ERDAT
         A~ERZET A~AENAM A~AEDAT A~AEZET A~BIGO4
         C~VKGRP
    INTO CORRESPONDING FIELDS OF TABLE GT_1020
    FROM ZNFT1020 AS A
   INNER JOIN ZNFT1011 AS B
      ON B~REQNO = A~REQNO
     AND B~H_NO1 = A~H_NO1
   INNER JOIN ZNFT1000 AS C
      ON C~CONNO = B~CONNO
   WHERE A~BUKRS = P_BUKRS
     AND A~NFUTN IN S_NFUTN
     AND A~REQNO IN S_REQNO
     AND A~NFKEY IN S_NFKEY
     AND A~FCM   IN S_FCM
     AND A~BY_SL IN GR_BY_SL
     AND A~RUDAT IN S_RUDAT
     AND A~ENDAT IN S_ENDAT
     AND A~YNCAN =  ' '
     AND A~YNFIN =  ' '
     AND ( A~CONFM = '3' OR A~CONFM = '7' )
     AND C~VKGRP IN S_VKGRP.

*--}기능개선_256766 - 2018.12.11

  LOOP AT GT_1020.
*___요청유형/계약정보
    SELECT SINGLE A~CONNO   "계약번호
                  B~RQTYP   "요청유형
                  C~COTXT   "계약명
                  C~KUNNR   "고객코드
                  C~NCUST   "고객명
                  C~PRCTR   "손익센터
      INTO (GT_1020-CONNO, GT_1020-RQTYP,
            GT_1020-COTXT, GT_1020-KUNNR,
            GT_1020-NCUST, GT_1020-PRCTR)
      FROM ZNFT1011 AS A
     INNER JOIN ZNFT1010 AS B
        ON A~REQNO = B~REQNO
     INNER JOIN ZNFT1000 AS C
        ON A~CONNO = C~CONNO
     WHERE A~REQNO = GT_1020-REQNO
       AND A~H_NO1 = GT_1020-H_NO1.

*___선물요청유형 점검
    IF NOT GT_1020-RQTYP IN S_RQTYP.
      DELETE GT_1020.
      CONTINUE.
    ENDIF.

*___손익센터 점검
    IF NOT GT_1020-PRCTR IN S_PRCTR.
      DELETE GT_1020.
      CONTINUE.
    ENDIF.

*___청산데이터 존재여부
    SELECT SINGLE CFUTN
      INTO LV_CFUTN
      FROM ZNFT1030
     WHERE BUKRS = P_BUKRS
       AND NFUTN = GT_1020-NFUTN
       AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) )
       AND YNNET = ' '.

    IF SY-SUBRC = 0.
      DELETE GT_1020.
      CONTINUE.
    ENDIF.

*___FCM 명
    PERFORM GET_LIFNR_DESC USING GT_1020-FCM
                                 GT_1020-NAME1.

*___손익센터명
    PERFORM GET_PRCTR_DESC USING GV_KOKRS
                                 GT_1020-PRCTR
                                 GT_1020-PTEXT.

*___Buy/Sell 내역
    PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                   GT_1020-BY_SL
                                   GT_1020-BSTXT.

*___요청유형 내역
    PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                   GT_1020-RQTYP
                                   GT_1020-RQTXT.

*___집행유형 내역
    PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                   GT_1020-MITYP
                                   GT_1020-MITPT.

*--{기능개선_256766 - 추가
*___영업그룹명
    SELECT SINGLE BEZEI
             FROM TVGRT
             INTO GT_1020-BEZEI
            WHERE VKGRP = GT_1020-VKGRP
              AND SPRAS = '3'.
*--}기능개선_256766 - 2018.12.12

    MODIFY GT_1020.

  ENDLOOP.

ENDFORM.                    " GET_ZNFT1020_DATA
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
  ENDIF.

*  gs_layout-NO_HEADERS = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
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

  GV_ITAB = 'GT_1020'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT
                                  USING :
      'NFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '            'NFUTN'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'RUDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'RUDAT'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'FCM'      ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'FCM'    'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'NAME1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      'FCM 명'       'NAME1'  'LFA1'      ' ' ' '    'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      '비철구분'     'NFKEY'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

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

      'MISPD'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '            'MISPD'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'MIMON'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '            'MIMON'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRICE'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '            'PRICE'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'WAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      ' '            'WAERS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '            'EMENG'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'MEINS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'PRCTR'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'PTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '손익센터 명'  'PTEXT'  'ZNFT0004'  ' ' ' '    'X' ' ' ' ' ' ',

      'REQNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'REQNO'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'H_NO1'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 3
      ' '            'H_NO1'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

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
*--{기능개선_256766 - 추가
      'VKGRP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'VKGRP'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'BIGO4'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      ' '            'BIGO4'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',


      'BEZEI'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '            'BEZEI'  'TVGRT'  ' ' ' '    'X' ' ' ' ' ' '.
*--}기능개선_256766 - 2018.12.11
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

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 3
      '비철구분'     'NFKEY'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'CONFM'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 1
      ' '            'CONFM'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'CFMTX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '결재상태내역' ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

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

      'MITPT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '집행유형 내역' ' '     ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

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

      'ZEPRO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'ZEPRO'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'BIGO4'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
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

  SET HANDLER GC_EVENT_HANDLER1->HANDLE_DOUBLE_CLICK
              FOR GC_ALV_GRID1.

ENDFORM.                    " EVENT_HANDLER_REGISTER_1
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
      IT_OUTTAB            = GT_1020[].

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

*  GS_VARIANT-HANDLE = '0002'.
*  GS_VARIANT-REPORT = SY-REPID.
*
*  CALL METHOD GC_ALV_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
*    EXPORTING
*      IS_VARIANT           = GS_VARIANT
*      IS_LAYOUT            = GS_LAYOUT
*      I_SAVE               = 'A'
*      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
*    CHANGING
*      IT_FIELDCATALOG      = GT_FIELDCAT[]
*      IT_SORT              = GT_SORT[]
*      IT_OUTTAB            = GT_1020[].

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

  LOOP AT GT_1020 WHERE CHECK = 'X'.
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

*  LOOP AT GT_1020 WHERE CHECK = 'X'.
*    CLEAR : GS_ROWS.
*
*    GS_ROWS-INDEX = SY-TABIX.
*
*    APPEND GS_ROWS TO GT_ROWS.
*  ENDLOOP.

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

*  CLEAR : GT_1020-CHECK.
*
*  MODIFY GT_1020 TRANSPORTING CHECK
*                 WHERE NFUTN IS NOT INITIAL.
*
*  LOOP AT GT_ROWS INTO GS_ROWS.
*    READ TABLE GT_1020 INDEX GS_ROWS-INDEX.
*    IF SY-SUBRC = 0.
*      GT_1020-CHECK = 'X'.
*
*      MODIFY GT_1020 INDEX GS_ROWS-INDEX.
*    ENDIF.
*  ENDLOOP.

ENDFORM.                    " GET_SELECTED_ROWS_2
*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_ALL .

  IF SY-DYNNR = '0100'.
    IF OK_SAVE = 'ASEL'.
      GT_1020-CHECK = 'X'.
    ELSE.
      CLEAR : GT_1020-CHECK.
    ENDIF.

    MODIFY GT_1020 TRANSPORTING CHECK
                   WHERE NFUTN IS NOT INITIAL.
  ELSE.
    IF OK_SAVE = 'ASEL'.
      GT_TRAN-CHECK = 'X'.
    ELSE.
      CLEAR : GT_TRAN-CHECK.
    ENDIF.

    MODIFY GT_TRAN TRANSPORTING CHECK
                   WHERE NCIND = 'C'.
  ENDIF.

ENDFORM.                    " SELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN_0200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_SCREEN_0200 .
  DATA: LT_RETURN   LIKE CASDAYATTR OCCURS 0 WITH HEADER LINE.

  PERFORM CHECK_SELECTED_ROWS_1 USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  CLEAR   : GT_TRAN, GV_SAVE.
  REFRESH : GT_TRAN.

  LOOP AT GT_1020 WHERE CHECK = 'X'.
    CLEAR : GT_TRAN.

    MOVE-CORRESPONDING GT_1020 TO GT_TRAN.

    CLEAR : GT_TRAN-CHECK, GT_TRAN-NFUTN.

    GT_TRAN-NCIND  = 'N'.             "신규
    GT_TRAN-CFUTN  = GT_1020-NFUTN.   "선물집행번호

    APPEND GT_TRAN.

*___청산기본데이터
    CLEAR : GT_TRAN.

    GT_TRAN-NCIND  = 'C'.             "청산

    GT_TRAN-NFUTN  = GT_1020-NFUTN.   "신규선물집행번호
    GT_TRAN-RUDAT  = SY-DATLO.        "집행일

    DO 30 TIMES.
      GT_TRAN-RUDAT = GT_TRAN-RUDAT - 1.

      CLEAR   : LT_RETURN.
      REFRESH : LT_RETURN.

      CALL FUNCTION 'DAY_ATTRIBUTES_GET'
        EXPORTING
          FACTORY_CALENDAR           = 'L3'
          HOLIDAY_CALENDAR           = 'LS'
          DATE_FROM                  = GT_TRAN-RUDAT
          DATE_TO                    = GT_TRAN-RUDAT
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

*    2012.05.30 수정 : Default Setting에서 제외
*    GT_TRAN-FCM    = GT_1020-FCM.     "FCM(거래선)
*    GT_TRAN-NAME1  = GT_1020-NAME1.   "FCM 명

    GT_TRAN-NFKEY  = GT_1020-NFKEY.   "비철구분
    GT_TRAN-EMENG  = GT_1020-EMENG.   "집행수량
    GT_TRAN-WAERS  = GT_1020-WAERS.   "통화 키
    GT_TRAN-MEINS  = GT_1020-MEINS.   "기본 단위

    IF GT_1020-BY_SL = 'B'.          "Buy/Sell
      GT_TRAN-BY_SL = 'S'.
    ELSE.
      GT_TRAN-BY_SL = 'B'.
    ENDIF.

    APPEND GT_TRAN.
  ENDLOOP.

  GV_CURSOR = 'GT_TRAN-RUDAT'.
  GV_CURLIN = 2.

  CALL SCREEN 0200 STARTING AT 10 2.

ENDFORM.                    " CALL_SCREEN_0200
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_ROWS_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_ROWS_1  USING    PV_ERROR.
  DATA: LV_CNT      TYPE I.

  CLEAR : PV_ERROR, LV_CNT.

  LOOP AT GT_1020 WHERE CHECK = 'X'.
    LV_CNT = LV_CNT + 1.
  ENDLOOP.

  IF LV_CNT < 1.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택한 라인이 없습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_ROWS_1
*&---------------------------------------------------------------------*
*&      Form  F4HELP_ZEPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_ZEPRO  USING  PV_ZEPRO.

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
      DYNPROFIELD  = 'GT_TRAN-ZEPRO'
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
  SCR_FIELDS-FIELDNAME = 'GT_TRAN-NFKEY'.
  SCR_FIELDS-STEPL     = GV_LINE.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'GT_TRAN-BY_SL'.
  SCR_FIELDS-STEPL     = GV_LINE.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'GT_TRAN-RUDAT'.
  SCR_FIELDS-STEPL     = GV_LINE.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'GT_TRAN-FCM'.
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
      WHEN 'GT_TRAN-RUDAT'.
        REPLACE ALL OCCURRENCES OF:
                '.' IN SCR_FIELDS-FIELDVALUE WITH '',
                '/' IN SCR_FIELDS-FIELDVALUE WITH '',
                '-' IN SCR_FIELDS-FIELDVALUE WITH ''.
        CONDENSE SCR_FIELDS-FIELDVALUE.
        GT_TRAN-RUDAT = SCR_FIELDS-FIELDVALUE.
      WHEN 'GT_TRAN-FCM'.
        GT_TRAN-FCM   = SCR_FIELDS-FIELDVALUE.
        PERFORM CONVERSION_EXIT_ALPHA USING 'I' GT_TRAN-FCM.
      WHEN 'GT_TRAN-NFKEY'.
        GT_TRAN-NFKEY = SCR_FIELDS-FIELDVALUE.
      WHEN 'GT_TRAN-BY_SL'.
        GT_TRAN-BY_SL = SCR_FIELDS-FIELDVALUE.
    ENDCASE.
  ENDLOOP.

  IF GT_TRAN-BY_SL IS NOT INITIAL.
    CONCATENATE WHERE_CLAUSE ' AND BY_SL = ''' GT_TRAN-BY_SL ''''
           INTO WHERE_CLAUSE.
  ENDIF.

  IF GT_TRAN-FCM IS NOT INITIAL.
    CONCATENATE WHERE_CLAUSE ' AND FCM = ''' GT_TRAN-FCM ''''
           INTO WHERE_CLAUSE.
  ENDIF.

  IF GT_TRAN-RUDAT IS NOT INITIAL AND
     GT_TRAN-RUDAT <> ' '.
    CONCATENATE WHERE_CLAUSE ' AND RUDAT = ''' GT_TRAN-RUDAT ''''
           INTO WHERE_CLAUSE.
  ENDIF.

  REPLACE 'AND' IN WHERE_CLAUSE WITH ''.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_EPRO
    FROM ZNFT1021
   WHERE BUKRS = P_BUKRS
     AND NFKEY = GT_TRAN-NFKEY
     AND (WHERE_CLAUSE).

  LOOP AT GT_EPRO.
*___FCM명
    PERFORM GET_LIFNR_DESC USING GT_EPRO-FCM
                                 GT_EPRO-NAME1.

*___잔량
    PERFORM CHECK_EPRO_REMAIN_QUANTITY USING P_BUKRS
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
*&      Form  CHECK_EPRO_REMAIN_QUANTITY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_EPRO_REMAIN_QUANTITY  USING    PV_BUKRS
                                          PV_ZEPRO
                                          PV_TABIX
                                          PV_EMENG
                                          PV_ERROR.
  DATA: LS_TRAN     LIKE GT_TRAN.

  DATA: LV_EMENG1   LIKE ZNFT1021-EMENG,   "e-Pro 수량
        LV_EMENG2   LIKE ZNFT1020-EMENG,   "신규선물집행수량
        LV_EMENG3   LIKE ZNFT1030-EMENG,   "청산선물집행수량
        LV_EMENG4   LIKE ZNFT1020-EMENG.   "현재 작업중인 수량

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
  LOOP AT GT_TRAN INTO LS_TRAN WHERE ZEPRO = PV_ZEPRO.
    IF SY-TABIX <> PV_TABIX.
      LV_EMENG4 = LV_EMENG4 + LS_TRAN-EMENG.
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
*&      Form  SAVE_FUTURE_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_FUTURE_TRANSACTION  USING PV_FLAG.
  DATA: LV_CNT      TYPE I,
        LV_TEXT(100).

  PERFORM CHECK_FUTURES_TRADING USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  IF PV_FLAG IS INITIAL.
    LV_TEXT = '청산선물집행을 저장하시겠습니까?'.
  ELSE.
    LV_TEXT = '청산선물집행을 결재요청 하시겠습니까?'.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING '저장'
                                 LV_TEXT
                                 '1'
                                 GV_ANSWER.

  IF GV_ANSWER = '1'.
    CLEAR   : GT_1030, GT_1030O, LV_CNT.
    REFRESH : GT_1030, GT_1030O.

    LOOP AT GT_TRAN WHERE NCIND = 'C'.
      CLEAR : GT_1030, GT_1030O.

*___이미 저장된 경우 변경전 데이터
      IF GV_SAVE = 'X'.
        SELECT SINGLE *
          INTO GT_1030O
          FROM ZNFT1030
         WHERE CFUTN = GT_TRAN-CFUTN.

        IF SY-SUBRC = 0.
          APPEND GT_1030O.
        ENDIF.
      ENDIF.

      MOVE-CORRESPONDING GT_TRAN TO GT_1030.

      IF GT_1030-CFUTN IS INITIAL.
        PERFORM GET_TRADING_NO.

        GT_TRAN-CFUTN = GT_1030-CFUTN.
      ENDIF.

      GT_1030-BUKRS = P_BUKRS.
      GT_1030-ERDAT = SY-DATLO.
      GT_1030-ERZET = SY-TIMLO.
      GT_1030-ERNAM = SY-UNAME.
      GT_1030-AEDAT = SY-DATLO.
      GT_1030-AEZET = SY-TIMLO.
      GT_1030-AENAM = SY-UNAME.

      IF PV_FLAG IS INITIAL.
        GT_1030-CONFM = '1'.   "생성
      ELSE.
        GT_1030-CONFM = '2'.   "승인요청
      ENDIF.

      LV_CNT = LV_CNT + 1.

      APPEND GT_1030.
      MODIFY GT_TRAN.
    ENDLOOP.

    MODIFY ZNFT1030 FROM TABLE GT_1030.
    IF SY-SUBRC = 0.
*___청산선물집행 변경이력 저장
      LOOP AT GT_1030.
        PERFORM SAVE_CHANGE_DOC.
      ENDLOOP.

      COMMIT WORK.

*___간편결재 전송
      " 결재요청 시에만 전송
      IF PV_FLAG IS NOT INITIAL.
        LOOP AT GT_1030.
          PERFORM SEND_SIMPLE_APPROVAL
          USING GT_1030-CFUTN
                GT_1030-BUKRS
                '2E'.
        ENDLOOP.
      ENDIF.

      GV_SAVE = 'X'.

      WRITE : LV_CNT TO LV_TEXT LEFT-JUSTIFIED.
      CONCATENATE LV_TEXT '건'
             INTO LV_TEXT SEPARATED BY SPACE.

      IF SY-BINPT IS INITIAL.
        IF PV_FLAG IS INITIAL.
          MESSAGE S010 WITH '청산선물집행 정보'
                            LV_TEXT.
        ELSE.
          MESSAGE S011 WITH '청산선물집행 정보'
                            LV_TEXT.

          PERFORM GET_ZNFT1020_DATA.
        ENDIF.
      ELSE.
        IF PV_FLAG IS INITIAL.
          MESSAGE S010 WITH '청산선물집행 정보'
                            GT_1030-CFUTN.
        ELSE.
          MESSAGE S011 WITH '청산선물집행 정보'
                            GT_1030-CFUTN.

          PERFORM GET_ZNFT1020_DATA.
        ENDIF.
      ENDIF.

      IF PV_FLAG = 'X' OR SY-BINPT = 'X'.
        LEAVE TO SCREEN 0.
      ENDIF.
    ELSE.
      ROLLBACK WORK.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '청산선물집행 정보 저장 에러!'.
    ENDIF.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " SAVE_FUTURE_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  CHECK_FUTURES_TRADING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_FUTURES_TRADING  USING    PV_ERROR.
  DATA: LS_TRAN     LIKE GT_TRAN,
        LV_TABIX    LIKE SY-TABIX,
        LV_ENDAT,
        LV_FCM,
        LV_TEXT(50).

  CLEAR : PV_ERROR, LV_TEXT, LV_ENDAT, LV_FCM.

  LOOP AT GT_TRAN WHERE NCIND = 'C'.
    LV_TABIX = SY-TABIX - 1.

    CLEAR : LS_TRAN.

    READ TABLE GT_TRAN INTO LS_TRAN
                       WITH KEY CFUTN = GT_TRAN-NFUTN.
    IF SY-SUBRC <> 0.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = LV_TABIX.
      GV_CURSOR    = 'GT_TRAN-RUDAT'.
      GV_CURLIN    = 2.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '해당 청산집행의 신규집행 정보를 찾지못했습니다.'.
      EXIT.
    ENDIF.

*___만기일/FCM 비교
    IF GT_TRAN-ENDAT <> LS_TRAN-ENDAT AND
       LV_ENDAT IS INITIAL.
      LV_ENDAT = 'X'.
    ENDIF.

    IF GT_TRAN-FCM <> LS_TRAN-FCM AND
       LV_FCM IS INITIAL.
      LV_FCM = 'X'.
    ENDIF.

*___집행일
    IF GT_TRAN-RUDAT IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = LV_TABIX.
      GV_CURSOR    = 'GT_TRAN-RUDAT'.
      GV_CURLIN    = 2.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '청산집행일이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

*___만기일
    IF GT_TRAN-ENDAT IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = LV_TABIX.
      GV_CURSOR    = 'GT_TRAN-ENDAT'.
      GV_CURLIN    = 2.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '청산만기일이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

*___FCM
    IF GT_TRAN-FCM IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = LV_TABIX.
      GV_CURSOR    = 'GT_TRAN-FCM'.
      GV_CURLIN    = 2.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '청산 FCM이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

*___비철구분
    IF GT_TRAN-NFKEY <> LS_TRAN-NFKEY.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = LV_TABIX.
      GV_CURSOR    = 'GT_TRAN-NFKEY'.
      GV_CURLIN    = 2.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '비철구분을 확인하시기 바랍니다.'.
      EXIT.
    ENDIF.

*___Buy/Sell
    IF GT_TRAN-BY_SL = LS_TRAN-BY_SL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = LV_TABIX.
      GV_CURSOR    = 'GT_TRAN-BY_SL'.
      GV_CURLIN    = 2.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH 'Buy/Sell을 확인하시기 바랍니다.'.
      EXIT.
    ENDIF.

*___청산집행유형
    IF GT_TRAN-MITYP IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = LV_TABIX.
      GV_CURSOR    = 'GT_TRAN-MITYP'.
      GV_CURLIN    = 2.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '청산집행유형이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

*___기준월 - 집행유형 'A'인 경우 필수
    IF GT_TRAN-MITYP = 'A' AND GT_TRAN-MIMON IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = LV_TABIX.
      GV_CURSOR    = 'GT_TRAN-MIMON'.
      GV_CURLIN    = 2.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '청산기준월이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

*___집행단가
    IF GT_TRAN-MITYP <> 'A' AND GT_TRAN-PRICE IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = LV_TABIX.
      GV_CURSOR    = 'GT_TRAN-PRICE'.
      GV_CURLIN    = 2.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '청산집행단가가 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

*___집행수량
    IF GT_TRAN-EMENG IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = LV_TABIX.
      GV_CURSOR    = 'GT_TRAN-EMENG'.
      GV_CURLIN    = 2.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '청산집행수량이 입력되지 않았습니다.'.
      EXIT.
    ELSEIF GT_TRAN-EMENG <> LS_TRAN-EMENG.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = LV_TABIX.
      GV_CURSOR    = 'GT_TRAN-EMENG'.
      GV_CURLIN    = 2.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '신규집행수량과 청산집행수량이 다릅니다.'.
      EXIT.
    ENDIF.

*___수수료여부
    IF GT_TRAN-MISUS IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = LV_TABIX.
      GV_CURSOR    = 'GT_TRAN-MISUS'.
      GV_CURLIN    = 2.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '수수료여부가 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

*--> 단위 체크
    IF GT_TRAN-MEINS IS INITIAL.
      PV_ERROR     = 'X'.
      TC1-TOP_LINE = LV_TABIX.
      GV_CURSOR    = 'GT_TRAN-MEINS'.
      GV_CURLIN    = 2.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '단위(TON or LB)를 입력하세요'.
      EXIT.
    ENDIF.
*<-- 단위 체크
  ENDLOOP.

  IF SY-SUBRC <> 0.
    PV_ERROR = 'X'.

    MESSAGE I003 DISPLAY LIKE 'E'
       WITH '선택된 라인이 없습니다.'.
  ENDIF.

  CHECK PV_ERROR IS INITIAL.

  IF LV_ENDAT IS NOT INITIAL.
    LV_TEXT = '/만기일'.
  ENDIF.

  IF LV_FCM IS NOT INITIAL.
    CONCATENATE LV_TEXT '/FCM' INTO LV_TEXT.
  ENDIF.

  IF LV_TEXT IS NOT INITIAL.
    REPLACE '/' WITH '' INTO LV_TEXT.

    MESSAGE I003 DISPLAY LIKE 'W'
       WITH '신규-청산 선물집행의' LV_TEXT
            '이 다른 건이 존재합니다.'.
  ENDIF.

ENDFORM.                    " CHECK_FUTURES_TRADING
*&---------------------------------------------------------------------*
*&      Form  GET_TRADING_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_TRADING_NO .

  CLEAR : GT_1030-CFUTN.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '10'
      OBJECT                  = 'ZNF2_00004'
    IMPORTING
      NUMBER                  = GT_1030-CFUTN
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
*&      Form  DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING    PS_ROW    TYPE LVC_S_ROW
                            PS_COLUMN TYPE LVC_S_COL.

  READ TABLE GT_1020 INDEX PS_ROW-INDEX.
  IF SY-SUBRC = 0.
    CASE PS_COLUMN-FIELDNAME.
      WHEN 'CONNO'.
        IF GT_1020-CONNO IS NOT INITIAL.
          SET PARAMETER ID 'ZNFCON' FIELD GT_1020-CONNO.

          CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
        ENDIF.

      WHEN 'REQNO'.
        IF GT_1020-REQNO IS NOT INITIAL.
          SET PARAMETER ID 'ZNFREQ' FIELD GT_1020-REQNO.

          CALL TRANSACTION 'ZNF2M2103' AND SKIP FIRST SCREEN.
        ENDIF.

      WHEN 'NFUTN'.
        IF GT_1020-NFUTN IS NOT INITIAL.
          PERFORM DISPLAY_FUTRUES_HISTORY.
        ENDIF.

    ENDCASE.
  ENDIF.

ENDFORM.                    " DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_CHANGE_DOC .
  DATA: LV_OBJECTID             TYPE CDHDR-OBJECTID,
        LV_TCODE                TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT      TYPE CDHDR-CHANGE_IND,
        LV_UPD_ICDTXT           TYPE CHAR1.

  CLEAR : ZNFT1030, YZNFT1030.

  IF GV_SAVE = 'X'.
    LV_CDOC_UPD_OBJECT = 'U'.
  ELSE.
    LV_CDOC_UPD_OBJECT = 'I'.
  ENDIF.

  LV_OBJECTID        = GT_1030-CFUTN.
  LV_TCODE           = SY-TCODE.

*___변경전 데이터
  READ TABLE GT_1030O WITH KEY CFUTN = GT_1030-CFUTN.
  IF SY-SUBRC = 0.
    MOVE-CORRESPONDING GT_1030O TO YZNFT1030.
  ENDIF.

*___변경후 데이터
  MOVE-CORRESPONDING GT_1030 TO ZNFT1030.

  CALL FUNCTION 'ZNFT1030CHDOC_WRITE_DOCUMENT'
    EXPORTING
      OBJECTID     = LV_OBJECTID
      TCODE        = LV_TCODE
      UTIME        = SY-TIMLO
      UDATE        = SY-DATLO
      USERNAME     = SY-UNAME
      N_ZNFT1030   = ZNFT1030
      O_ZNFT1030   = YZNFT1030
      UPD_ZNFT1030 = LV_CDOC_UPD_OBJECT.

ENDFORM.                    " SAVE_CHANGE_DOC
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELLEMENT_FCM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_SELLEMENT_FCM .
  DATA: LV_NCCHK    LIKE ZNFT1050-NCCHK.

  CLEAR : LV_NCCHK.

  CHECK GT_TRAN-ENDAT IS NOT INITIAL AND
        GT_TRAN-FCM   IS NOT INITIAL.

  SELECT SINGLE NCCHK
    INTO LV_NCCHK
    FROM ZNFT1050
   WHERE BUKRS = P_BUKRS
     AND ENDAT = GT_TRAN-ENDAT
     AND FCM   = GT_TRAN-FCM.

  IF LV_NCCHK = 'X'.
    MESSAGE E003 WITH '만기일/FCM' GT_TRAN-ENDAT GT_TRAN-FCM
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
*&      Form  GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       CHM2102-00042 - 추가
*----------------------------------------------------------------------*
FORM GET_SELECTED_ROWS .

  CALL METHOD GC_ALV_GRID1->CHECK_CHANGED_DATA.

  CALL METHOD GC_ALV_GRID1->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROWS.

  CLEAR : GT_1020-CHECK.
  MODIFY GT_1020 TRANSPORTING CHECK
                 WHERE NFUTN IS NOT INITIAL.

*  LOOP AT GT_ROWS INTO GS_ROWS.
  LOOP AT GT_TRAN.

      IF GT_TRAN-CFUTN IS INITIAL.
        GT_TRAN-CHECK = 'X'.
      ENDIF.

    MODIFY GT_TRAN  TRANSPORTING CHECK.

  ENDLOOP.

  CALL METHOD GC_ALV_GRID1->GET_SELECTED_COLUMNS
    IMPORTING
      ET_INDEX_COLUMNS = GT_COLS.

ENDFORM.                    " GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  EXEC_MASS_INPUT
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM EXEC_MASS_INPUT .

  CHECK GV_CHK1 IS NOT INITIAL OR
             GV_CHK2 IS NOT INITIAL OR
             GV_CHK3 IS NOT INITIAL OR
             GV_CHK4 IS NOT INITIAL OR
             GV_CHK5 IS NOT INITIAL OR
             GV_CHK6 IS NOT INITIAL OR
             GV_CHK7 IS NOT INITIAL OR
             GV_CHK8 IS NOT INITIAL .

*  GT_1030-AEDAT = SY-DATLO.
*  GT_1030-AEZET = SY-TIMLO.
*  GT_1030-AENAM = SY-UNAME.

IF GV_MITYP EQ 'A' .
  IF GV_CHK1 = 'X'.
    GT_TRAN-RUDAT = GV_RUDAT.

    MODIFY GT_TRAN TRANSPORTING RUDAT
                     WHERE CHECK = 'X'.
  ENDIF.

  IF GV_CHK2 = 'X'.
    GT_TRAN-FCM = GV_FCM.

    MODIFY GT_TRAN TRANSPORTING FCM
                     WHERE CHECK = 'X'.
  ENDIF.

  IF GV_CHK3 = 'X'.
    GT_TRAN-ENDAT = GV_ENDAT.

    MODIFY GT_TRAN  TRANSPORTING ENDAT
                     WHERE CHECK = 'X'.
  ENDIF.

  IF GV_CHK4 = 'X'.
    GT_TRAN-MITYP = GV_MITYP.

    MODIFY GT_TRAN TRANSPORTING MITYP
                     WHERE CHECK = 'X'.
  ENDIF.

  IF GV_CHK5 = 'X'.
    GT_TRAN-MISPD = GV_MISPD.

    MODIFY GT_TRAN TRANSPORTING MISPD
                     WHERE CHECK = 'X'.
  ENDIF.

  IF GV_CHK6 = 'X'.
    GT_TRAN-MIMON = GV_MIMON.

    MODIFY GT_TRAN  TRANSPORTING MIMON
                     WHERE CHECK = 'X'.
  ENDIF.

  IF GV_CHK7 = 'X'.
    GT_TRAN-PRICE = GV_PRICE.

    MODIFY GT_TRAN TRANSPORTING PRICE
                     WHERE CHECK = 'X'.
  ENDIF.

  IF GV_CHK8 = 'X'.
    GT_TRAN-MISUS = GV_MISUS.

    MODIFY GT_TRAN  TRANSPORTING MISUS
                     WHERE CHECK = 'X'.
  ENDIF.

  ELSE.

  IF GV_CHK1 = 'X'.
    GT_TRAN-RUDAT = GV_RUDAT.

    MODIFY GT_TRAN TRANSPORTING RUDAT
                     WHERE CHECK = 'X'.
  ENDIF.

  IF GV_CHK2 = 'X'.
    GT_TRAN-FCM = GV_FCM.

    MODIFY GT_TRAN TRANSPORTING FCM
                     WHERE CHECK = 'X'.
  ENDIF.

  IF GV_CHK3 = 'X'.
    GT_TRAN-ENDAT = GV_ENDAT.

    MODIFY GT_TRAN  TRANSPORTING ENDAT
                     WHERE CHECK = 'X'.
  ENDIF.

  IF GV_CHK4 = 'X'.
    GT_TRAN-MITYP = GV_MITYP.

    MODIFY GT_TRAN TRANSPORTING MITYP
                     WHERE CHECK = 'X'.
  ENDIF.

*  IF GV_CHK5 = 'X'.
*    GT_TRAN-MISPD = GV_MISPD.
*
*    MODIFY GT_TRAN TRANSPORTING MISPD
*                     WHERE CHECK = 'X'.
*  ENDIF.
*
*  IF GV_CHK6 = 'X'.
*    GT_TRAN-MIMON = GV_MIMON.
*
*    MODIFY GT_TRAN  TRANSPORTING MIMON
*                     WHERE CHECK = 'X'.
*  ENDIF.

  IF GV_CHK7 = 'X'.
    GT_TRAN-PRICE = GV_PRICE.

    MODIFY GT_TRAN TRANSPORTING PRICE
                     WHERE CHECK = 'X'.
  ENDIF.

  IF GV_CHK8 = 'X'.
    GT_TRAN-MISUS = GV_MISUS.

    MODIFY GT_TRAN  TRANSPORTING MISUS
                     WHERE CHECK = 'X'.
  ENDIF.
 ENDIF.

  SET SCREEN 0.

ENDFORM.                    " EXEC_MASS_INPUT
*&---------------------------------------------------------------------*
*& Form SEND_SIMPLE_APPROVAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_1030_CFUTN
*&      --> GT_1030_BUKRS
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
