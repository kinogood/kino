*&---------------------------------------------------------------------*
*&  Include           ZNFR2320F01
*&---------------------------------------------------------------------*
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
        DYNAME     = 'ZNFR2320'
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
FORM F4HELP_MONTH  USING    PV_MONTH.

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
      DYNAME     = 'ZNFR2320'
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
      DYNAME     = 'ZNFR2320'
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
       WITH '영업그룹이 없습니다.'.
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

*___Buy/Sell 구분
  IF P_CHK01 = 'X'.
    APPEND_RANGES : GR_BY_SL 'I' 'EQ' 'B' ' '.
  ENDIF.

  IF P_CHK02 = 'X'.
    APPEND_RANGES : GR_BY_SL 'I' 'EQ' 'S' ' '.
  ENDIF.

ENDFORM.                    " SET_RANGES
*&---------------------------------------------------------------------*
*&      Form  GET_SHIFT_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_SHIFT_REQ_DATA .
  DATA: LV_FLAG.

  CLEAR   : GT_MAIN.
  REFRESH : GT_MAIN.

  SELECT A~BUKRS             "회사코드
         A~SHFNO             "만기이동요청번호
         B~H_NO1             "항번
         A~DRSTA             "만기이동결재상태
         A~ERDAT             "만기이동요청일
         A~YNCAN             "취소여부
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
         C~CONFM             "선물집행 결재상태
         C~YNCAN AS YNCAN1   "선물집행 취소여부
         C~YNFIN             "선물집행 정산여부
         C~YNNET             "선물집행 넷팅여부
         D~CONNO             "계약번호
         E~COTXT             "계약명
         E~PRCTR             "손익센터
         E~VKGRP             "영업그룹
         E~KUNNR             "고객코드
         E~NCUST             "고객명
         E~SALER                     "영업담당자
         B~GUBUN                   "생성구분
    INTO CORRESPONDING FIELDS OF TABLE GT_MAIN
    FROM ZNFT1040 AS A
   INNER JOIN ZNFT1041 AS B
      ON A~SHFNO =  B~SHFNO
   INNER JOIN ZNFT1020 AS C
      ON A~OFUTN =  C~NFUTN
   INNER JOIN ZNFT1011 AS D
      ON C~REQNO =  D~REQNO
     AND C~H_NO1 =  D~H_NO1
   INNER JOIN ZNFT1000 AS E
      ON D~CONNO =  E~CONNO
   WHERE A~BUKRS =  P_BUKRS
     AND A~SHFNO IN S_SHFNO
     AND A~DRSTA IN ('3', '4', '8')    "승인/접수/확인반려
     AND A~ERDAT IN S_ERDAT
     AND A~OFUTN IN S_NFUTN
     AND A~YNCAN =  ' '
     AND B~REMON IN S_REMON
     AND C~FCM   IN S_FCM
     AND C~NFKEY IN S_NFKEY
     AND C~ENDAT IN S_ENDAT
     AND C~BY_SL IN GR_BY_SL
     AND C~CONFM IN ('3', '7')    "승인/수정승인
*     AND C~YNCAN =  ' '
     AND C~YNFIN =  ' '
     AND C~YNNET =  ' '
     AND D~REQNO IN S_REQNO
     AND D~CONNO IN S_CONNO
     AND E~PRCTR IN S_PRCTR
     AND E~VKGRP IN S_VKGRP.

  SORT GT_MAIN BY SHFNO H_NO1.

  CLEAR : LV_FLAG.

  LOOP AT GT_MAIN.
*    IF GT_MAIN-DRSTA <> '4' AND GT_MAIN-YNCAN1 = 'X'.
*      DELETE GT_MAIN.
*      CONTINUE.
*    ENDIF.

    AT NEW SHFNO.
      LV_FLAG = 'X'.
    ENDAT.

    IF LV_FLAG = 'X'.
      CLEAR : LV_FLAG.
    ELSE.
      GT_MAIN-CHECK = '-'.
    ENDIF.

    PERFORM GET_OTHER_DATA.

    MODIFY GT_MAIN.
  ENDLOOP.

ENDFORM.                    " GET_SHIFT_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_LAYO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_LAYO .

*  gs_layout-grid_title = '~'.
*  gs_layout-smalltitle = 'X'.
*  gs_layout-NO_HEADERS = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
*  GS_LAYOUT-EDIT       = 'X'.
  GS_LAYOUT-ZEBRA      = 'X'.
  GS_LAYOUT-SMALLTITLE = 'X'.
  GS_LAYOUT-NO_ROWMARK = 'X'.
  GS_LAYOUT-SEL_MODE   = ' '.              "select multiple lines
  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT-CTAB_FNAME = 'F_COL'.

ENDFORM.                    " SET_GRID_LAYO
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_FCAT .

  CLEAR   : GS_FIELDCAT, GV_POS.
  REFRESH : GT_FIELDCAT.

  GV_ITAB = 'GT_MAIN'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT
                                  USING :

      'CHECK'    ' '      ' '     ' ' 'X' ' ' ' '    'X' ' ' ' ' 4
      '선택'         ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' 'X',

      'BUKRS'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      ' '              'BUKRS' 'ZNFT1040' ' ' ' '    'X' ' ' ' ' ' ',

      'SHFNO'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '              'SHFNO' 'ZNFT1040' ' ' ' '    'X' ' ' ' ' ' ',

      'H_NO1'    ' '      ' '     ' ' ' ' 'R' ' '    'X' ' ' ' ' 5
      ' '              'H_NO1' 'ZNFT1041' ' ' ' '    'X' ' ' ' ' ' ',

      'DRSTA'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '              'DRSTA' 'ZNFT1040' ' ' ' '    'X' ' ' ' ' ' ',

      'DRSTA_NM' ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '결재상태명'     ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ERDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '만기이동요청일' 'ERDAT' 'ZNFT1040' ' ' ' '    'X' ' ' ' ' ' ',

      'REMON'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '              'REMON' 'ZNFT1041' ' ' ' '    'X' ' ' ' ' ' ',

      'RMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '              'RMENG' 'ZNFT1041' ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'MEINS' 'ZNFT1041' ' ' ' '    'X' ' ' ' ' ' ',

      'BIGO4'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 100
      ' '              'BIGO4' 'ZNFT1040' 'L' ' '    'X' ' ' ' ' ' ',

      'RUDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '신규집행일'     'RUDAT' 'ZNFT1041' ' ' ' '    'X' ' ' ' ' 'X',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '신규만기일'     'ENDAT' 'ZNFT1041' ' ' ' '    'X' ' ' ' ' 'X',

      'MISPD'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '신규 Spread'    'MISPD' 'ZNFT1041' ' ' ' '    ' ' ' ' ' ' 'X',

      'PRICE'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '신규집행단가'   'PRICE' 'ZNFT1041' ' ' ' '    ' ' ' ' ' ' 'X',

      'WAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      ' '              'WAERS' 'ZNFT1041' ' ' ' '    'X' ' ' ' ' ' ',

      'OFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '                'OFUTN' 'ZNFT1040' ' ' ' '  'X' ' ' ' ' ' ', "신규선물집행(이동전)

      'NFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '신규선물집행번호' 'NFUTN' 'ZNFT1041' ' ' ' '  'X' ' ' ' ' ' ', "이동후

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

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'EMENG' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'PRCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'PRCTR' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'PTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '손익센터명'     'PTEXT' 'ZNFT0004' ' ' ' '    'X' ' ' ' ' ' ',

      'CONNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'CONNO' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' ',

      'COTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '              'COTXT' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'VKGRP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'VKGRP' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'VTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'VTEXT' 'ZNFT0003' ' ' ' '    'X' ' ' ' ' ' ',

      'SALER'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'SALER' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'CFUTN_O'  ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '청산선물집행번호(이동전)' 'CFUTN' 'ZNFT1030' ' ' ' '  'X' ' ' ' ' ' ',

      'CFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '청산선물집행번호' 'CFUTN' 'ZNFT1030' ' ' ' '  'X' ' ' ' ' ' '. "이동후


ENDFORM.                    " SET_GRID_FCAT
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FCAT_C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_FCAT_C .

  CLEAR   : GS_FIELDCAT, GV_POS.
  REFRESH : GT_FIELDCAT.

  GV_ITAB = 'GT_MAIN'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT
                                  USING :

      'CHECK'    ' '      ' '     ' ' 'X' ' ' ' '    'X' ' ' ' ' 4
      '선택'         ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' 'X',

      'BUKRS'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      ' '              'BUKRS' 'ZNFT1040' ' ' ' '    'X' ' ' ' ' ' ',

      'SHFNO'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '              'SHFNO' 'ZNFT1040' ' ' ' '    'X' ' ' ' ' ' ',

      'H_NO1'    ' '      ' '     ' ' ' ' 'R' ' '    'X' ' ' ' ' 5
      ' '              'H_NO1' 'ZNFT1041' ' ' ' '    'X' ' ' ' ' ' ',

      'DRSTA'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '              'DRSTA' 'ZNFT1040' ' ' ' '    'X' ' ' ' ' ' ',

      'DRSTA_NM' ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '결재상태명'     ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ERDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '만기이동요청일' 'ERDAT' 'ZNFT1040' ' ' ' '    'X' ' ' ' ' ' ',

      'REMON'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '              'REMON' 'ZNFT1041' ' ' ' '    'X' ' ' ' ' ' ',

      'RMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '              'RMENG' 'ZNFT1041' ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'MEINS' 'ZNFT1041' ' ' ' '    'X' ' ' ' ' ' ',

      'BIGO4'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 100
      ' '              'BIGO4' 'ZNFT1040' 'L' ' '    'X' ' ' ' ' ' ',

      'RUDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '신규집행일'     'RUDAT' 'ZNFT1041' ' ' ' '    'X' ' ' ' ' 'X',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '신규만기일'     'ENDAT' 'ZNFT1041' ' ' ' '    'X' ' ' ' ' 'X',

      'MISPD'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '신규 Spread'    'MISPD' 'ZNFT1041' ' ' ' '    ' ' ' ' ' ' 'X',

      'PRICE'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '신규집행단가'   'PRICE' 'ZNFT1041' ' ' ' '    ' ' ' ' ' ' 'X',

      'CRUDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '신규청산집행일'     'RUDAT' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' 'X',

      'CENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '신규청산만기일'     'ENDAT' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' 'X',

      'CMISPD'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '신규 청산Spread'    'MISPD' 'ZNFT1030' ' ' ' '    ' ' ' ' ' ' 'X',

      'CPRICE'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '신규청산집행단가'   'PRICE' 'ZNFT1030' ' ' ' '    ' ' ' ' ' ' 'X',

      'WAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      ' '              'WAERS' 'ZNFT1041' ' ' ' '    'X' ' ' ' ' ' ',

      'NFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '신규선물집행번호' 'NFUTN' 'ZNFT1041' ' ' ' '  'X' ' ' ' ' ' ',

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

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'EMENG' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'PRCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'PRCTR' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'PTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '손익센터명'     'PTEXT' 'ZNFT0004' ' ' ' '    'X' ' ' ' ' ' ',

      'CONNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'CONNO' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' ',

      'COTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '              'COTXT' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'VKGRP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'VKGRP' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'VTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'VTEXT' 'ZNFT0003' ' ' ' '    'X' ' ' ' ' ' ',

      'SALER'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'SALER' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'CFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '청산선물집행번호' 'CFUTN' 'ZNFT1030' ' ' ' '  'X' ' ' ' ' ' '.

ENDFORM.                    " SET_GRID_FCAT
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

  IF PV_FNAME = 'CONNO'.
    GS_FIELDCAT-F4AVAILABL   = 'X'.
  ENDIF.

  GS_FIELDCAT-TABNAME        = GV_ITAB.

  APPEND GS_FIELDCAT TO PT_FIELDCAT.

ENDFORM.                    " MAKE_LVC_FIELDCAT_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE .
  DATA: LT_CELLTAB TYPE LVC_T_STYL,
        LT_COLOR   TYPE LVC_T_SCOL.

*___각 Cell의 특성 제어
  CLEAR : GV_INT.

  LOOP AT GT_MAIN.
    AT NEW SHFNO.
      IF GV_INT IS INITIAL.
        GV_INT = 1.
      ELSE.
        CLEAR : GV_INT.
      ENDIF.
    ENDAT.

    CLEAR   : LT_CELLTAB, LT_COLOR.
    REFRESH : LT_CELLTAB, LT_COLOR.

    "Old HPC
    IF RB_1 EQ 'X'.   ">> Cell 제어
      PERFORM FILL_CELLTAB_C CHANGING LT_CELLTAB.

      "Market Carry & New HPC
    ELSE.
      PERFORM FILL_CELLTAB_M CHANGING LT_CELLTAB.
    ENDIF.

    PERFORM FILL_COLOR     CHANGING LT_COLOR.

    REFRESH : GT_MAIN-CELLTAB, GT_MAIN-F_COL.

    INSERT LINES OF LT_CELLTAB INTO TABLE GT_MAIN-CELLTAB.
    INSERT LINES OF LT_COLOR   INTO TABLE GT_MAIN-F_COL.

    MODIFY GT_MAIN.
  ENDLOOP.

ENDFORM.                    " SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*&      Form  FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_CELLTAB_C  CHANGING PT_CELLTAB TYPE LVC_T_STYL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         L_MODE     TYPE RAW4.

  DATA : L_FIELDCAT TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT INTO L_FIELDCAT.
    LS_CELLTAB-FIELDNAME = L_FIELDCAT-FIELDNAME.

*___필드 활성화 여부
    IF L_FIELDCAT-EDIT = 'X'.
      IF GT_MAIN-MARK <> 'X'.
        IF LS_CELLTAB-FIELDNAME = 'CHECK'.
          IF GT_MAIN-CHECK = '-'.
            LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                             + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
          ELSE.
            LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*                             + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
          ENDIF.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                           + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        ENDIF.
      ELSE.
        IF ( GT_MAIN-GUBUN = '1' AND ( LS_CELLTAB-FIELDNAME <> 'CHECK' OR
             GT_MAIN-CHECK <> '-' ) ) OR
           ( LS_CELLTAB-FIELDNAME = 'CHECK' AND GT_MAIN-CHECK <> '-' ).
          IF GT_MAIN-MITYP = 'S' AND LS_CELLTAB-FIELDNAME = 'MISPD'.
            LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                             + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
          ELSE.
            LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*                             + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
          ENDIF.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                           + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        ENDIF.
      ENDIF.
    ELSE.
      LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                       + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
    ENDIF.

    INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
  ENDLOOP.

ENDFORM.                    " FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*&      Form  FILL_CELLTAB_M
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_CELLTAB_M  CHANGING PT_CELLTAB TYPE LVC_T_STYL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         L_MODE     TYPE RAW4.

  DATA : L_FIELDCAT TYPE LVC_S_FCAT.


  LOOP AT GT_FIELDCAT INTO L_FIELDCAT.
    LS_CELLTAB-FIELDNAME = L_FIELDCAT-FIELDNAME.

*___필드 활성화 여부
    IF L_FIELDCAT-EDIT = 'X'.
      IF GT_MAIN-MARK <> 'X'.
        IF LS_CELLTAB-FIELDNAME = 'CHECK'.
          IF GT_MAIN-CHECK = '-'.
            LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                             + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
          ELSE.
            LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*                             + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
          ENDIF.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                           + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        ENDIF.
      ELSE.
        IF ( GT_MAIN-GUBUN = '1' AND ( LS_CELLTAB-FIELDNAME <> 'CHECK' OR
             GT_MAIN-CHECK <> '-' ) ) OR
           ( LS_CELLTAB-FIELDNAME = 'CHECK' AND GT_MAIN-CHECK <> '-' ).
          IF GT_MAIN-MITYP = 'S' AND LS_CELLTAB-FIELDNAME = 'MISPD' OR
*> 청산신규 spread 의 경우 비활성화
              GT_MAIN-MITYP = 'S' AND LS_CELLTAB-FIELDNAME = 'CMISPD' .
            LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

          ELSE.
            LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*                             + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
          ENDIF.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                           + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        ENDIF.
      ENDIF.
    ELSE.
      LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                       + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
    ENDIF.

    INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
  ENDLOOP.

ENDFORM.                    " FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*&      Form  FILL_COLOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_COLOR  text
*----------------------------------------------------------------------*
FORM FILL_COLOR  CHANGING PT_COLOR TYPE LVC_T_SCOL.
  DATA: LS_CELLTAB TYPE LVC_S_STYL,
        LS_COLOR   TYPE LVC_S_SCOL,
        L_MODE     TYPE RAW4.

  DATA: L_FIELDCAT TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT INTO L_FIELDCAT.
    LS_COLOR-FNAME = L_FIELDCAT-FIELDNAME.

    IF  L_FIELDCAT-KEY = 'X'.
      IF LS_COLOR-FNAME <> 'CHECK' OR GT_MAIN-CHECK = '-'.
        LS_COLOR-COLOR-COL = 4.
        LS_COLOR-COLOR-INT = 1.

        INSERT LS_COLOR INTO TABLE PT_COLOR.
      ENDIF.
    ELSE.
      IF GT_MAIN-MARK = 'X'.
        IF L_FIELDCAT-EDIT IS INITIAL.
          LS_COLOR-COLOR-COL = 7.
          LS_COLOR-COLOR-INT = GV_INT.

          INSERT LS_COLOR INTO TABLE PT_COLOR.
        ELSE.
          IF GT_MAIN-GUBUN = '2' OR
           ( GT_MAIN-MITYP = 'S' AND LS_COLOR-FNAME = 'MISPD' OR
*> 청산 신규spread 의 경우 색 추가
             GT_MAIN-MITYP = 'S' AND LS_COLOR-FNAME = 'CMISPD').
            LS_COLOR-COLOR-COL = 7.
            LS_COLOR-COLOR-INT = GV_INT.

            INSERT LS_COLOR INTO TABLE PT_COLOR.
          ENDIF.
        ENDIF.
      ELSE.
        LS_COLOR-COLOR-COL = 2.
        LS_COLOR-COLOR-INT = GV_INT.

        INSERT LS_COLOR INTO TABLE PT_COLOR.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " FILL_COLOR
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
*  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_SORT_ASC.
*  APPEND LS_EXCLUDE TO PT_EXCLUDE.
*  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_SORT_DSC.
*  APPEND LS_EXCLUDE TO PT_EXCLUDE.
*  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_FILTER.
*  APPEND LS_EXCLUDE TO PT_EXCLUDE.

ENDFORM.                    " EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER .

  CALL METHOD GC_ALV_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

*___Event Handler 등록
  CREATE OBJECT GC_EVENT_HANDLER.

  SET HANDLER GC_EVENT_HANDLER->HANDLE_TOOLBAR       FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_DOUBLE_CLICK  FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_DATA_CHANGED  FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_DATA_CHANGED_FINISHED
          FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_USER_COMMAND  FOR GC_ALV_GRID.

ENDFORM.                    " EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*&      Form  SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_TABLE_FOR_FIRST_DISPLAY .

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

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SELECTED_ROWS .

  CALL METHOD GC_ALV_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROWS.

  CALL METHOD GC_ALV_GRID->GET_SELECTED_COLUMNS
    IMPORTING
      ET_INDEX_COLUMNS = GT_COLS.

ENDFORM.                    " GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  SET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SELECTED_ROWS .

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
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_ALL .

  LOOP AT GT_MAIN WHERE CHECK <> '-'.
    IF OK_SAVE = 'ASEL'.
      GT_MAIN-CHECK = 'X'.
    ELSE.
      CLEAR : GT_MAIN-CHECK.
    ENDIF.

    PERFORM ENQUEUE_DEQUEUE_ZNFT1040.
    PERFORM ENQUEUE_DEQUEUE_ZNFT1020 USING GT_MAIN-OFUTN.

    LOOP AT GT_MAIN INTO GS_MAIN WHERE SHFNO = GT_MAIN-SHFNO.
      IF GS_MAIN-NFUTN IS NOT INITIAL.
        PERFORM ENQUEUE_DEQUEUE_ZNFT1020 USING GS_MAIN-NFUTN.
      ENDIF.

      GS_MAIN-MARK = GT_MAIN-CHECK.

      MODIFY GT_MAIN FROM GS_MAIN.
    ENDLOOP.

    MODIFY GT_MAIN TRANSPORTING CHECK.
  ENDLOOP.

*___선택된 데이터 Refersh
  LOOP AT GT_MAIN WHERE MARK = 'X'.
    PERFORM SELECTED_DATA_REFRESH.

    MODIFY GT_MAIN.
  ENDLOOP.

ENDFORM.                    " SELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_DEQUEUE_ZNFT1020
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ENQUEUE_DEQUEUE_ZNFT1020 USING PV_NFUTN.
  DATA: LV_MSGV1    LIKE SY-MSGV1.

  IF GT_MAIN-CHECK IS INITIAL.
    CALL FUNCTION 'DEQUEUE_EZ_ZNFT1020'
      EXPORTING
        NFUTN = PV_NFUTN.
  ELSE.
    CALL FUNCTION 'ENQUEUE_EZ_ZNFT1020'
      EXPORTING
        NFUTN          = PV_NFUTN
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.

    IF SY-SUBRC <> 0.
      CLEAR : GT_MAIN-CHECK.
      LV_MSGV1 = SY-MSGV1.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '선물집행 번호' PV_NFUTN
              '이(가) 현재 처리중입니다. 사용자:' LV_MSGV1.
    ENDIF.
  ENDIF.

ENDFORM.                    " ENQUEUE_DEQUEUE_ZNFT1020
*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_DEQUEUE_ZNFT1040
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ENQUEUE_DEQUEUE_ZNFT1040 .
  DATA: LV_MSGV1    LIKE SY-MSGV1.

  IF GT_MAIN-CHECK IS INITIAL.
    CALL FUNCTION 'DEQUEUE_EZ_ZNFT1040'
      EXPORTING
        SHFNO = GT_MAIN-SHFNO.
  ELSE.
    CALL FUNCTION 'ENQUEUE_EZ_ZNFT1040'
      EXPORTING
        SHFNO          = GT_MAIN-SHFNO
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.

    IF SY-SUBRC <> 0.
      CLEAR : GT_MAIN-CHECK.
      LV_MSGV1 = SY-MSGV1.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '만기이동요청 번호' GT_MAIN-SHFNO
              '이(가) 현재 처리중입니다. 사용자:' LV_MSGV1.
    ENDIF.
  ENDIF.

ENDFORM.                    " ENQUEUE_DEQUEUE_ZNFT1040
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED  USING    E_MODIFIED
                                     ET_GOOD_CELLS TYPE LVC_T_MODI.
  DATA: LS_GOOD_CELLS TYPE LVC_S_MODI.

  DATA: LV_SHFNO    LIKE ZNFT1040-SHFNO.

  DATA: GL_ROW    TYPE I,
        GL_VALUE  TYPE C,
        GL_COL    TYPE I,
        GL_ROW_ID TYPE LVC_S_ROW,
        GL_COL_ID TYPE LVC_S_COL,
        GL_ROW_NO TYPE LVC_S_ROID.

  LOOP AT ET_GOOD_CELLS INTO LS_GOOD_CELLS.
    CASE LS_GOOD_CELLS-FIELDNAME.
      WHEN 'CHECK'.
        READ TABLE GT_MAIN INDEX LS_GOOD_CELLS-ROW_ID.
        IF SY-SUBRC = 0.
          PERFORM ENQUEUE_DEQUEUE_ZNFT1040.
          PERFORM ENQUEUE_DEQUEUE_ZNFT1020 USING GT_MAIN-OFUTN.

          LOOP AT GT_MAIN INTO GS_MAIN WHERE SHFNO = GT_MAIN-SHFNO.
            IF GS_MAIN-NFUTN IS NOT INITIAL.
              PERFORM ENQUEUE_DEQUEUE_ZNFT1020 USING GS_MAIN-NFUTN.
            ENDIF.

            GS_MAIN-MARK = GT_MAIN-CHECK.

            MODIFY GT_MAIN FROM GS_MAIN.
          ENDLOOP.

          MODIFY GT_MAIN INDEX LS_GOOD_CELLS-ROW_ID
                         TRANSPORTING CHECK.

*___선택된 데이터 Refersh
          IF GT_MAIN-CHECK = 'X'.
            LV_SHFNO = GT_MAIN-SHFNO.

            LOOP AT GT_MAIN WHERE SHFNO = LV_SHFNO.
              PERFORM SELECTED_DATA_REFRESH.

              MODIFY GT_MAIN.
            ENDLOOP.
          ENDIF.
        ENDIF.

    ENDCASE.

  ENDLOOP.

ENDFORM.                    " DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*&      Form  DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING  PS_ROW    TYPE LVC_S_ROW
                          PS_COLUMN TYPE LVC_S_COL.

  READ TABLE GT_MAIN INDEX PS_ROW-INDEX.
  IF SY-SUBRC = 0.
    CASE PS_COLUMN-FIELDNAME.
      WHEN 'SHFNO'.
        IF GT_MAIN-SHFNO IS NOT INITIAL.
          SET PARAMETER ID 'ZNFSHF' FIELD GT_MAIN-SHFNO.

          CALL TRANSACTION 'ZNF2M2303' AND SKIP FIRST SCREEN.
        ENDIF.

      WHEN 'CONNO'.
        IF GT_MAIN-CONNO IS NOT INITIAL.
          SET PARAMETER ID 'ZNFCON' FIELD GT_MAIN-CONNO.

          CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
        ENDIF.

      WHEN 'NFUTN'.
        IF GT_MAIN-NFUTN IS NOT INITIAL.
          PERFORM DISPLAY_FUTRUES_HISTORY USING GT_MAIN-NFUTN.
        ENDIF.

      WHEN 'OFUTN'.
        IF GT_MAIN-OFUTN IS NOT INITIAL.
          PERFORM DISPLAY_FUTRUES_HISTORY USING GT_MAIN-OFUTN.
        ENDIF.

    ENDCASE.
  ENDIF.

ENDFORM.                    " DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  SELECTED_DATA_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECTED_DATA_REFRESH .

  SELECT SINGLE A~BUKRS             "회사코드
                A~SHFNO             "만기이동요청번호
                B~H_NO1             "항번
                A~DRSTA             "만기이동결재상태
                A~YNCAN             "취소여부
                B~REMON             "요청만기월
                B~RMENG             "요청수량
                B~MEINS             "단위
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
                C~CONFM             "선물집행 결재상태
                C~YNCAN AS YNCAN1   "선물집행 취소여부
                C~YNFIN             "선물집행 정산여부
                C~YNNET             "선물집행 넷팅여부
                D~CONNO             "계약번호
                E~COTXT             "계약명
                E~PRCTR             "손익센터
                E~VKGRP             "영업그룹
                E~KUNNR             "고객코드
                E~NCUST             "고객명
                B~GUBUN             "생성구분
    INTO CORRESPONDING FIELDS OF GT_MAIN
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
   WHERE B~SHFNO = GT_MAIN-SHFNO
     AND B~H_NO1 = GT_MAIN-H_NO1.

  "--> 신규청산만기일 직접 입력 위한 참조 - 유주수D 요청
*  IF RB_2 = 'X'.
  IF RB_2 = 'X' OR RB_3 = 'X'.
    GT_MAIN-CENDAT = GT_MAIN-ENDAT1.
  ENDIF.

  PERFORM GET_OTHER_DATA.

  IF GT_MAIN-DRSTA <> '3' AND GT_MAIN-DRSTA <> '4' AND
     GT_MAIN-DRSTA <> '8'.
    IF GT_MAIN-CHECK = 'X'.
      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '만기이동요청' GT_MAIN-SHFNO
              '의 결재상태를 확인하시기 바랍니다.'.
    ENDIF.

    IF GT_MAIN-CHECK <> '-'.
      CLEAR : GT_MAIN-CHECK.

      PERFORM ENQUEUE_DEQUEUE_ZNFT1040.
      PERFORM ENQUEUE_DEQUEUE_ZNFT1020 USING GT_MAIN-OFUTN.
    ENDIF.

    CLEAR : GT_MAIN-MARK.

    IF GT_MAIN-NFUTN IS NOT INITIAL.
      PERFORM ENQUEUE_DEQUEUE_ZNFT1020 USING GT_MAIN-NFUTN.
    ENDIF.
  ENDIF.

*  IF GT_MAIN-YNCAN1 = 'X' OR GT_MAIN-YNFIN = 'X' OR
  IF GT_MAIN-YNFIN = 'X' OR GT_MAIN-YNNET  = 'X'.
    IF GT_MAIN-CHECK = 'X'.
      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '만기이동요청' GT_MAIN-SHFNO
              '의 정산 여부를 확인하시기 바랍니다.'.
*              '의 취소/정산/넷팅 여부를 확인하시기 바랍니다.'.
    ENDIF.

    IF GT_MAIN-CHECK <> '-'.
      CLEAR : GT_MAIN-CHECK.

      PERFORM ENQUEUE_DEQUEUE_ZNFT1040.
      PERFORM ENQUEUE_DEQUEUE_ZNFT1020 USING GT_MAIN-OFUTN.
    ENDIF.

    CLEAR : GT_MAIN-MARK.

    IF GT_MAIN-NFUTN IS NOT INITIAL.
      PERFORM ENQUEUE_DEQUEUE_ZNFT1020 USING GT_MAIN-NFUTN.
    ENDIF.
  ENDIF.

  IF GT_MAIN-YNCAN = 'X'.
    IF GT_MAIN-CHECK = 'X'.
      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '만기이동요청' GT_MAIN-SHFNO
              '의 취소여부를 확인하시기 바랍니다.'.
    ENDIF.

    IF GT_MAIN-CHECK <> '-'.
      CLEAR : GT_MAIN-CHECK.

      PERFORM ENQUEUE_DEQUEUE_ZNFT1040.
      PERFORM ENQUEUE_DEQUEUE_ZNFT1020 USING GT_MAIN-OFUTN.
    ENDIF.

    CLEAR : GT_MAIN-MARK.

    IF GT_MAIN-NFUTN IS NOT INITIAL.
      PERFORM ENQUEUE_DEQUEUE_ZNFT1020 USING GT_MAIN-NFUTN.
    ENDIF.
  ENDIF.

  IF GT_MAIN-CONFM <> '3' AND GT_MAIN-CONFM <> '7'.
    IF GT_MAIN-CHECK = 'X'.
      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '만기이동요청' GT_MAIN-SHFNO
              '의 선물집행번호의 결재상태를 확인하시기 바랍니다.'.
    ENDIF.

    IF GT_MAIN-CHECK <> '-'.
      CLEAR : GT_MAIN-CHECK.

      PERFORM ENQUEUE_DEQUEUE_ZNFT1040.
      PERFORM ENQUEUE_DEQUEUE_ZNFT1020 USING GT_MAIN-OFUTN.
    ENDIF.

    CLEAR : GT_MAIN-MARK.

    IF GT_MAIN-NFUTN IS NOT INITIAL.
      PERFORM ENQUEUE_DEQUEUE_ZNFT1020 USING GT_MAIN-NFUTN.
    ENDIF.
  ENDIF.

ENDFORM.                    " SELECTED_DATA_REFRESH
*&---------------------------------------------------------------------*
*&      Form  GET_OTHER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_OTHER_DATA .

  "--> [CHM2507-00010] 조회 기준 수정
**** 원본 BK - START
**___기존신규건에 대한 청산선물집행번호
*  CLEAR : GT_MAIN-CFUTN.
*
**___청산정보 불러오기
*  SELECT SINGLE CFUTN RUDAT ENDAT PRICE MISPD
*    INTO (GT_MAIN-CFUTN, GT_MAIN-CRUDAT, GT_MAIN-CENDAT,
*              GT_MAIN-CPRICE, GT_MAIN-CMISPD)
*    FROM ZNFT1030
*   WHERE NFUTN = GT_MAIN-NFUTN
*     AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) ).
**** 원본 BK - END

  "--> 신규선물집행번호(이동후)에 대한 청산선물
  CLEAR : GT_MAIN-CFUTN.
  SELECT SINGLE CFUTN RUDAT ENDAT PRICE MISPD
    INTO (GT_MAIN-CFUTN, GT_MAIN-CRUDAT, GT_MAIN-CENDAT,
          GT_MAIN-CPRICE, GT_MAIN-CMISPD)
    FROM ZNFT1030
   WHERE NFUTN = GT_MAIN-NFUTN
     AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) ).

  "--> 신규선물집행번호(이동전)에 대한 청산선물
  CLEAR : GT_MAIN-CFUTN_O.
  SELECT SINGLE CFUTN
    INTO GT_MAIN-CFUTN_O
    FROM ZNFT1030
   WHERE NFUTN = GT_MAIN-OFUTN
     AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) ).
  "<-- [CHM2507-00010] 조회 기준 수정

*___자동생성된 만기이동 데이터인 경우
  IF GT_MAIN-GUBUN = '2'.
    SELECT SINGLE RUDAT   "신규집행일
                  ENDAT   "신규만기일
                  PRICE   "신규집행단가
                  MISPD   "신규Spread
      INTO (GT_MAIN-RUDAT, GT_MAIN-ENDAT,
            GT_MAIN-PRICE, GT_MAIN-MISPD)
      FROM ZNFT1020
     WHERE NFUTN = GT_MAIN-OFUTN.
  ENDIF.

*___만기이동 결재상태 내역
  PERFORM DOMAIN_VALUE_GET USING 'ZDRSTA'
                                 GT_MAIN-DRSTA
                                 GT_MAIN-DRSTA_NM.

*___Buy/Sell 내역
  PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                 GT_MAIN-BY_SL
                                 GT_MAIN-BSTXT.

*___FCM 명
  PERFORM GET_LIFNR_DESC USING GT_MAIN-FCM
                               GT_MAIN-NAME1.

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

ENDFORM.                    " GET_OTHER_DATA
*&---------------------------------------------------------------------*
*&      Form  SAVE_SHIFT_APPROVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_SHIFT_APPROVAL  USING  PV_FLAG.
  DATA: LV_TEXT(100).

  CALL METHOD GC_ALV_GRID->CHECK_CHANGED_DATA.

  PERFORM CHECK_SELECTED_LINE USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  PERFORM CHECK_SHIFT_APPOVAL USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

*  IF GV_COMM IS INITIAL.
**___공용 ID로 실행한 경우 사번과 비밀번호 점검
*    CLEAR : GV_PERNR, GV_PASWD, GV_ENAME.
*
*    CALL SCREEN 0200 STARTING AT 20 5.
*
*    CHECK OK_CODE = 'CONT'.
*  ENDIF.

  CLEAR : LV_TEXT.

  IF GV_FLAG = 'X'.
    CONCATENATE '요청만기월과 신규만기일의'
                '월이 다른 건이 존재합니다.'
           INTO LV_TEXT SEPARATED BY SPACE.
  ENDIF.

  IF PV_FLAG IS INITIAL.
    CONCATENATE LV_TEXT '만기이동을 저장 하시겠습니까?'
           INTO LV_TEXT SEPARATED BY SPACE.
  ELSE.
    CONCATENATE LV_TEXT '만기이동을 결재요청 하시겠습니까?'
           INTO LV_TEXT SEPARATED BY SPACE.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING '저장'
                                 LV_TEXT
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
    PERFORM SAVE_SHIFT_REQ USING PV_FLAG.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " SAVE_SHIFT_APPROVAL
*&---------------------------------------------------------------------*
*&      Form  REJECT_SHIFT_APPROVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REJECT_SHIFT_APPROVAL .

  PERFORM CHECK_SELECTED_LINE USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  PERFORM CHECK_REJECT_DATA USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM
    USING '반려'
          '선택하신 만기이동요청을 반려처리 하시겠습니까?'
          '2'
          GV_ANSWER.
  IF GV_ANSWER = '1'.
    PERFORM REJECT_SHIFT_REQ.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " REJECT_SHIFT_APPROVAL
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_LINE  USING  PV_ERROR.
  DATA: LV_CNT      TYPE I.

  CLEAR : PV_ERROR, LV_CNT.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    LV_CNT = LV_CNT + 1.
  ENDLOOP.

  IF LV_CNT < 1.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택된 라인이 없습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_LINE
*&---------------------------------------------------------------------*
*&      Form  CHECK_REJECT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_REJECT_DATA  USING  PV_ERROR.
  DATA: LS_MAIN     LIKE GT_MAIN.

  DATA: LV_FLAG.

  CLEAR : PV_ERROR, LV_FLAG.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    IF GT_MAIN-DRSTA <> '3'.
      LV_FLAG = '1'.
      EXIT.
    ENDIF.

    LOOP AT GT_MAIN INTO LS_MAIN WHERE SHFNO = GT_MAIN-SHFNO.
      IF LS_MAIN-NFUTN IS NOT INITIAL.
        LV_FLAG = '2'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF LV_FLAG IS NOT INITIAL.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF LV_FLAG IS NOT INITIAL.
    PV_ERROR = 'X'.

    CASE LV_FLAG.
      WHEN '1'.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '만기이동요청번호' GT_MAIN-SHFNO
                '의 결재상태가 ''승인''이 아닙니다.'.

      WHEN '2'.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '만기이동요청번호' GT_MAIN-SHFNO
                '은(는) 이미 접수되어 만기이동 되었으므로'
                '반려가 불가능합니다.'.

    ENDCASE.
  ENDIF.

ENDFORM.                    " CHECK_REJECT_DATA
*&---------------------------------------------------------------------*
*&      Form  REJECT_SHIFT_REQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REJECT_SHIFT_REQ .
  DATA: LV_CNT  TYPE I,
        LV_FLAG.

  CLEAR   : GT_1040, LV_CNT, LV_FLAG.
  REFRESH : GT_1040.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    CLEAR : GT_1040.

    SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF GT_1040
      FROM ZNFT1040
     WHERE SHFNO = GT_MAIN-SHFNO.

    IF SY-SUBRC = 0.
      GT_1040-UPDKZ = 'O'.

      APPEND GT_1040.
    ENDIF.

    UPDATE ZNFT1040 SET DRSTA = '7'    "승인반려
                        YNCAN = 'X'
                        AENAM = SY-UNAME
                        AEDAT = SY-DATLO
                        AEZET = SY-TIMLO
                  WHERE SHFNO = GT_MAIN-SHFNO.
    IF SY-SUBRC = 0.
      LV_CNT = LV_CNT + 1.

      GT_1040-UPDKZ = 'N'.
      GT_1040-DRSTA = '7'.
      GT_1040-YNCAN = 'X'.
      GT_1040-AENAM = SY-UNAME.
      GT_1040-AEDAT = SY-DATLO.
      GT_1040-AEZET = SY-TIMLO.

      APPEND GT_1040.
    ELSE.
      LV_FLAG = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF LV_FLAG IS INITIAL.
    LOOP AT GT_MAIN WHERE CHECK = 'X'.
      PERFORM SAVE_ZNFT1040_CHDOC.
    ENDLOOP.

    COMMIT WORK.

    MESSAGE S003 WITH '만기이동요청' LV_CNT
                      '건이 반려(취소) 되었습니다.'.

    PERFORM DEQUEUE_ZNFT1040.

    PERFORM GET_SHIFT_REQ_DATA.
  ELSE.
    ROLLBACK WORK.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '만기이동요청 반려처리 시'
            '에러가 발생하였습니다.'.
  ENDIF.

ENDFORM.                    " REJECT_SHIFT_REQ
*&---------------------------------------------------------------------*
*&      Form  SAVE_SHIFT_REQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_SHIFT_REQ  USING  PV_FLAG.
  DATA: LV_CNT      TYPE I.

  CLEAR   : GT_1020, GT_1040, GT_1041, GV_ERROR.
  REFRESH : GT_1020, GT_1040, GT_1041.

***********************  Old HPC  **************************
  IF RB_1 EQ 'X'.   ">>Main Process Logic
    LOOP AT GT_MAIN WHERE MARK = 'X'.
      "--> 이동후 신규선물집행 생성
      IF GT_MAIN-NFUTN IS INITIAL.
        PERFORM CREATE_NEW_FUTRUES_TRADING USING PV_FLAG.

        IF GV_ERROR IS NOT INITIAL.
          EXIT.
        ENDIF.

        GT_MAIN-NFUTN = ZNFT1020-NFUTN.

        "--> 이동전 신규선물집행 삭제
        IF GT_MAIN-CHECK = 'X'.
          PERFORM DELETE_OLD_FUTURES_TRADING.

          IF GV_ERROR IS NOT INITIAL.
            EXIT.
          ENDIF.
        ENDIF.
      ELSE.
        PERFORM UPDATE_NEW_FUTRUES_TRADING USING PV_FLAG.
      ENDIF.

*--> [CHM2507-00010] 이동후 신규선물에 대한 청산선물 처리
      IF GT_MAIN-CFUTN_O IS NOT INITIAL. "--> 이동전 청산선물 존재 시에만
        IF GT_MAIN-CFUTN IS INITIAL.
          "--> 이동후 청산선물집행 생성
          PERFORM CREATE_NEW_FUTRUES_TRADING_2 USING PV_FLAG.

          IF GV_ERROR IS NOT INITIAL.
            EXIT.
          ENDIF.

          GT_MAIN-CFUTN = ZNFT1030-CFUTN.

          "--> 이동전 청산선물집행 삭제
          IF GT_MAIN-CHECK = 'X'.
            PERFORM DELETE_OLD_FUTURES_TRADING_2.

            IF GV_ERROR IS NOT INITIAL.
              EXIT.
            ENDIF.
          ENDIF.
        ELSE.
          PERFORM UPDATE_NEW_FUTRUES_TRADING_2 USING PV_FLAG.
        ENDIF.
      ENDIF.
*<-- [CHM2507-00010] 이동후 신규선물에 대한 청산선물 처리

*___3. 만기이동요청 변경
      IF GT_MAIN-CHECK = 'X'.
        PERFORM UPDATE_SHIFT_REQ USING PV_FLAG.
      ENDIF.

*___4. 만기이동요청 품목 Update
      PERFORM UPDATE_SHIFT_ITEM.

*___5. 결재이력 저장
      IF GT_MAIN-CHECK = 'X'.
        PERFORM SAVE_APPROVE_REQUEST  USING PV_FLAG.
      ENDIF.

      MODIFY GT_MAIN.
    ENDLOOP.

*********************** Market Carry **************************
  ELSEIF RB_2 EQ 'X'.   ">> Main Process Logic

    LOOP AT GT_MAIN WHERE MARK = 'X'.

      IF SY-SUBRC = 0.
*___1. 신규선물집행 생성
        IF GT_MAIN-NFUTN IS INITIAL.
          PERFORM CREATE_NEW_FUTRUES_TRADING_M USING PV_FLAG.
          IF GV_ERROR IS NOT INITIAL.
            EXIT.
          ENDIF.

          IF GT_MAIN-GUBUN EQ '1'.
            GT_MAIN-NFUTN = ZNFT1020-NFUTN - 1.
          ELSE.
            GT_MAIN-NFUTN = ZNFT1020-NFUTN.
          ENDIF.
*___2. 구 선물집행 삭제처리
          IF GT_MAIN-CHECK = 'X'.
            PERFORM DELETE_OLD_FUTURES_TRADING.

            IF GV_ERROR IS NOT INITIAL.
              EXIT.
            ENDIF.
          ENDIF.
        ELSE.
          PERFORM UPDATE_NEW_FUTRUES_TRADING USING PV_FLAG.
          AT LAST .
            GT_MAIN-NFUTN = GT_MAIN-NFUTN - 1.
          ENDAT.
        ENDIF.

*___3. 만기이동요청 변경
        IF GT_MAIN-CHECK = 'X'.
          PERFORM UPDATE_SHIFT_REQ USING PV_FLAG.
        ENDIF.

*___4. 만기이동요청 품목 Update
        PERFORM UPDATE_SHIFT_ITEM_M.

*___5. 결재이력 저장
        IF GT_MAIN-CHECK = 'X'.
          PERFORM SAVE_APPROVE_REQUEST  USING PV_FLAG.
        ENDIF.

        MODIFY GT_MAIN.
      ENDIF.

    ENDLOOP.

*********************** New HPC **************************
  ELSEIF RB_3 EQ 'X'.   "  >>Process Logic
    LOOP AT GT_MAIN WHERE MARK = 'X'.

      IF SY-SUBRC = 0.
*___1. 신규선물집행 생성
        IF GT_MAIN-NFUTN IS INITIAL.
*          PERFORM CREATE_NEW_FUTRUES_TRADING_M USING PV_FLAG.
          PERFORM CREATE_NEW_FUTRUES_TRADING_H USING PV_FLAG.

          IF GV_ERROR IS NOT INITIAL.
            EXIT.
          ENDIF.

          IF GT_MAIN-GUBUN EQ '1'.
            GT_MAIN-NFUTN = ZNFT1020-NFUTN - 1.
          ELSE.
            GT_MAIN-NFUTN = ZNFT1020-NFUTN.
          ENDIF.
*___2. 구 선물집행 삭제처리
          IF GT_MAIN-CHECK = 'X'.
            PERFORM DELETE_OLD_FUTURES_TRADING.

            IF GV_ERROR IS NOT INITIAL.
              EXIT.
            ENDIF.
          ENDIF.
        ELSE.
          "1020 Old Number Deletion Flag.
          PERFORM UPDATE_NEW_FUTRUES_TRADING USING PV_FLAG.
          AT LAST .
            GT_MAIN-NFUTN = GT_MAIN-NFUTN - 1.
          ENDAT.
        ENDIF.

*___3. 만기이동요청 변경
        IF GT_MAIN-CHECK = 'X'.
          PERFORM UPDATE_SHIFT_REQ USING PV_FLAG.
        ENDIF.

*___4. 만기이동요청 품목 Update
        PERFORM UPDATE_SHIFT_ITEM_M.

*___5. 결재이력 저장
        IF GT_MAIN-CHECK = 'X'.
          PERFORM SAVE_APPROVE_REQUEST  USING PV_FLAG.
        ENDIF.

        MODIFY GT_MAIN.
      ENDIF.

    ENDLOOP.
  ENDIF.


************** 변경이력 저장 및 Table 저장 ******************
  IF GV_ERROR IS INITIAL.
    CLEAR : LV_CNT.

    LOOP AT GT_MAIN WHERE MARK = 'X'.
*___6. 신규선물집행 생성 이력 저장
      PERFORM SAVE_ZNFT1020_CHDOC USING 'N'.

*--> [CHM2507-00010] 이동후 신규선물에 대한 청산선물 처리
      IF RB_1 EQ 'X'. ">>1030 Change Management. HPC Only
        IF GT_MAIN-CFUTN_O IS NOT INITIAL.
          PERFORM SAVE_ZNFT1030_CHDOC USING 'N'.
        ENDIF.
      ENDIF.
*<-- [CHM2507-00010] 이동후 신규선물에 대한 청산선물 처리

      "MC 청산처리
      IF  GT_MAIN-GUBUN EQ '1' AND
         ( RB_2 EQ 'X' OR RB_3 EQ 'X' ). ">> MC, New HPC: 1030 Table Log.

*___9. 청산이동요청 이력 저장 New
        PERFORM SAVE_ZNFT1030.
      ENDIF.

      IF GT_MAIN-CHECK = 'X'.
*___7. 구 선물집행 생성 이력 저장
        PERFORM SAVE_ZNFT1020_CHDOC USING 'O'.

*--> [CHM2507-00010] 이동후 신규선물에 대한 청산선물 처리
        IF RB_1 EQ 'X'.   ">> 1030 Change Management
          IF GT_MAIN-CFUTN_O IS NOT INITIAL.
            PERFORM SAVE_ZNFT1030_CHDOC USING 'O'.
          ENDIF.
        ENDIF.
*<-- [CHM2507-00010] 이동후 신규선물에 대한 청산선물 처리

*___8. 만기이동요청 이력 저장
        PERFORM SAVE_ZNFT1040_CHDOC.

        LV_CNT = LV_CNT + 1.
      ENDIF.
    ENDLOOP.

    COMMIT WORK.

*--- 간편결재 전송.
    IF PV_FLAG IS NOT INITIAL.
      LOOP AT GT_MAIN WHERE MARK = 'X'.
        PERFORM SEND_SIMPLE_APPROVAL
        USING GT_MAIN-SHFNO
              GT_MAIN-BUKRS
              '2C'.
      ENDLOOP.
    ENDIF.

    IF PV_FLAG IS INITIAL.
      MESSAGE S003 WITH '만기이동' LV_CNT
                        '건이 저장 되었습니다.'.
    ELSE.
      MESSAGE S003 WITH '만기이동' LV_CNT
                        '건이 결재요청 되었습니다.'.
    ENDIF.

    PERFORM DEQUEUE_ZNFT1040.

    PERFORM GET_SHIFT_REQ_DATA.
  ELSE.
    ROLLBACK WORK.

    CASE GV_ERROR.
      WHEN '1'.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '신규선물집행 생성/변경 시 에러발생!'.

      WHEN '2'.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '구 선물집행 변경 시 에러발생!'.

      WHEN '3'.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '만기이동 결재상태 변경 시 에러발생!'.

      WHEN '4'.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '만기이동요청 품목 변경 시 에러발생!'.

      WHEN '5'.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '만기이동 결재요청 시 에러발생!'.

    ENDCASE.
  ENDIF.

ENDFORM.                    " SAVE_SHIFT_REQ
*&---------------------------------------------------------------------*
*&      Form  CREATE_NEW_FUTRUES_TRADING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_NEW_FUTRUES_TRADING USING PV_FLAG.

  "HPC처리 로직

  CLEAR : ZNFT1020.

  SELECT SINGLE *
    FROM ZNFT1020
   WHERE NFUTN = GT_MAIN-OFUTN.

  PERFORM GET_TRADING_NO.

  ZNFT1020-RUDAT = GT_MAIN-RUDAT.
  ZNFT1020-ENDAT = GT_MAIN-ENDAT.
  ZNFT1020-PRICE = GT_MAIN-PRICE.
  ZNFT1020-MISPD = GT_MAIN-MISPD.
  ZNFT1020-EMENG = GT_MAIN-RMENG.
  ZNFT1020-OLDFT = GT_MAIN-OFUTN.
*  ZNFT1020-BIGO4 = '만기이동'.   "하드코딩 제거
  ZNFT1020-BIGO4 = ZNFT1020-BIGO4. "기존 비고정보 유지 (20260818/박우진)
  ZNFT1020-MCTYP = 'H'.
  ZNFT1020-ERNAM = SY-UNAME.
  ZNFT1020-ERDAT = SY-DATLO.
  ZNFT1020-ERZET = SY-TIMLO.
  ZNFT1020-AENAM = SY-UNAME.
  ZNFT1020-AEDAT = SY-DATLO.
  ZNFT1020-AEZET = SY-TIMLO.

  IF PV_FLAG IS INITIAL.
    ZNFT1020-CONFM = '1'.
  ELSE.
    ZNFT1020-CONFM = '2'.
  ENDIF.

  CLEAR : ZNFT1020-WHYCN, ZNFT1020-YNFIN,
          ZNFT1020-ZEPRO, ZNFT1020-YNNET,
          ZNFT1020-RESON, ZNFT1020-CODAT,
          ZNFT1020-COZET, ZNFT1020-CONAM,
          ZNFT1020-YNCAN.

  INSERT ZNFT1020 FROM ZNFT1020.

  IF SY-SUBRC = 0.
    CLEAR : GT_1020.

    MOVE-CORRESPONDING ZNFT1020 TO GT_1020.

    GT_1020-UPDKZ = 'N'.

    APPEND GT_1020.
  ELSE.
    GV_ERROR = '1'.
  ENDIF.

ENDFORM.                    " CREATE_NEW_FUTRUES_TRADING
*&---------------------------------------------------------------------*
*&      Form  CREATE_NEW_FUTRUES_TRADING_M
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_NEW_FUTRUES_TRADING_M USING PV_FLAG.
  DATA: LV_CNT TYPE I.
  DATA: LV_SHFNO LIKE ZNFT1041-SHFNO,
        LV_H_NO1 LIKE  ZNFT1041-H_NO1.
  DATA: LV_FUTNO TYPE ZFUTNO.   "박우진 추가(2026.08.02)

  CLEAR : ZNFT1020.


  IF GT_MAIN-GUBUN EQ '1'.
*> Markey Carry의 경우 두 번 생성함.
    DO 2 TIMES.

      ADD 1 TO LV_CNT.

      "만기이동 채번 이후(a), 신규 선물집행번호(b) 생성
      IF LV_CNT EQ '2'.

        PERFORM GET_TRADING_NO.

        ZNFT1020-BUKRS = GT_MAIN-BUKRS.
        ZNFT1020-CONFM = '2'.
*        ZNFT1020-BIGO4 = ''.    "비고 빈값처리
        ZNFT1020-MCTYP = 'N'.
        ZNFT1020-ERNAM = SY-UNAME.
        ZNFT1020-ERDAT = SY-DATLO.
        ZNFT1020-ERZET = SY-TIMLO.
        ZNFT1020-AENAM = SY-UNAME.
        ZNFT1020-AEDAT = SY-DATLO.
        ZNFT1020-AEZET = SY-TIMLO.
        ZNFT1020-RUDAT = GT_MAIN-RUDAT.
        ZNFT1020-ENDAT = GT_MAIN-ENDAT.
        ZNFT1020-PRICE = GT_MAIN-PRICE.
        ZNFT1020-MISPD = GT_MAIN-MISPD.
* [S] 만기이동 채번(a)과 신규 선물집행번호 연결 (2026.08.02 박우진)
* 유주수 대리 요청
*        ZNFT1020-OLDFT = ''.    기존 연결 Disconnection 원인.
        ZNFT1020-OLDFT = LV_FUTNO.

* [E] 만기이동 채번(a)과 신규 선물집행번호 연결

        SELECT SINGLE REQNO H_NO1
          INTO  (ZNFT1020-REQNO, ZNFT1020-H_NO1 )
          FROM   ZNFT1020
         WHERE  NFUTN EQ GT_MAIN-OFUTN.

        INSERT ZNFT1020 FROM ZNFT1020.

        IF SY-SUBRC EQ 0.
          COMMIT WORK.
        ENDIF.
*< Market Carry 만기이동 연결 (신규집행)

*> Market Carry Item Line의 만기이동 번호 찾기
        SELECT SINGLE MAX( H_NO1 )
          INTO    LV_H_NO1
          FROM  ZNFT1041
         WHERE SHFNO EQ GT_MAIN-SHFNO.

        LV_H_NO1 = LV_H_NO1 + 1.

        ZNFT1041-SHFNO = GT_MAIN-SHFNO. "만기이동요청번호
        ZNFT1041-H_NO1 = LV_H_NO1.   "항번
        ZNFT1041-NFUTN    = ZNFT1020-NFUTN.
        ZNFT1041-REMON  = GT_MAIN-REMON.
        ZNFT1041-RUDAT    = GT_MAIN-RUDAT.
        ZNFT1041-ENDAT    = GT_MAIN-ENDAT.
        ZNFT1041-PRICE     = GT_MAIN-PRICE.
        ZNFT1041-MISPD     = GT_MAIN-MISPD.
        ZNFT1041-MEINS   = GT_MAIN-MEINS.
        ZNFT1041-RMENG = GT_MAIN-RMENG.
        ZNFT1041-WAERS = GT_MAIN-WAERS.
        ZNFT1041-GUBUN =  '1'.
        ZNFT1041-ERNAM = SY-UNAME.
        ZNFT1041-ERDAT  = SY-DATLO.
        ZNFT1041-ERZET  = SY-TIMLO.
        ZNFT1041-AENAM = SY-UNAME.
        ZNFT1041-AEDAT  = SY-DATLO.
        ZNFT1041-AEZET  = SY-TIMLO.

        INSERT ZNFT1041 FROM ZNFT1041.

        IF SY-SUBRC EQ 0.
          COMMIT WORK.
          CLEAR : LV_SHFNO.
          CONTINUE.
        ENDIF.

      ELSE.
        "만기이동 번호 신규채번(a) (순서상 먼저 발생함).
        SELECT SINGLE *
          FROM ZNFT1020
         WHERE NFUTN = GT_MAIN-OFUTN.

        PERFORM GET_TRADING_NO.

* [S] 만기이동 채번(a)과 신규 선물집행번호 연결 (2026.08.02 박우진)
        CLEAR: LV_FUTNO.
        LV_FUTNO = ZNFT1020-NFUTN.
* [E] 만기이동 채번(a)과 신규 선물집행번호 연결 (2026.08.02 박우진)


*        ZNFT1020-RUDAT = GT_MAIN-RUDAT.
        "--> MCTYP = M은 RUDAT1(기존 집행일)로 반영되어야 함
        "--> MCTYP = N만 RUDAT(입력한 신규집행일)
        ZNFT1020-RUDAT = GT_MAIN-RUDAT1.
        ZNFT1020-ENDAT = GT_MAIN-ENDAT1.
        ZNFT1020-PRICE = GT_MAIN-PRICE1.
        ZNFT1020-MISPD = GT_MAIN-MISPD1.
        ZNFT1020-EMENG = GT_MAIN-RMENG.
        ZNFT1020-OLDFT = GT_MAIN-OFUTN.
*        ZNFT1020-BIGO4 = '만기이동'.   "유주수 비고란 Update비활성화요청(20260818/박우진)
        ZNFT1020-MCTYP = 'M'.
        ZNFT1020-ERNAM = SY-UNAME.
        ZNFT1020-ERDAT = SY-DATLO.
        ZNFT1020-ERZET = SY-TIMLO.
        ZNFT1020-AENAM = SY-UNAME.
        ZNFT1020-AEDAT = SY-DATLO.
        ZNFT1020-AEZET = SY-TIMLO.

        IF PV_FLAG IS INITIAL.
          ZNFT1020-CONFM = '1'.
        ELSE.
          ZNFT1020-CONFM = '2'.
        ENDIF.

        CLEAR : ZNFT1020-WHYCN, ZNFT1020-YNFIN,
                ZNFT1020-ZEPRO, ZNFT1020-YNNET,
                ZNFT1020-RESON, ZNFT1020-CODAT,
                ZNFT1020-COZET, ZNFT1020-CONAM,
                ZNFT1020-YNCAN.

        INSERT ZNFT1020 FROM ZNFT1020.

        IF SY-SUBRC = 0.
          CLEAR : GT_1020.

          MOVE-CORRESPONDING ZNFT1020 TO GT_1020.

          GT_1020-UPDKZ = 'N'.

          APPEND GT_1020.
        ELSE.
          GV_ERROR = '1'.
        ENDIF.

      ENDIF.

    ENDDO.

  ELSE.
    "생성구분(1: 신규 2: 잔량)

    SELECT SINGLE *
      FROM ZNFT1020
     WHERE NFUTN = GT_MAIN-OFUTN.

    PERFORM GET_TRADING_NO.

    ZNFT1020-RUDAT = GT_MAIN-RUDAT.
    ZNFT1020-ENDAT = GT_MAIN-ENDAT.
    ZNFT1020-PRICE = GT_MAIN-PRICE.
    ZNFT1020-MISPD = GT_MAIN-MISPD.
    ZNFT1020-EMENG = GT_MAIN-RMENG.
    ZNFT1020-OLDFT = GT_MAIN-OFUTN.
*    ZNFT1020-BIGO4 = '만기이동'.
    ZNFT1020-MCTYP = 'N'.
    ZNFT1020-ERNAM = SY-UNAME.
    ZNFT1020-ERDAT = SY-DATLO.
    ZNFT1020-ERZET = SY-TIMLO.
    ZNFT1020-AENAM = SY-UNAME.
    ZNFT1020-AEDAT = SY-DATLO.
    ZNFT1020-AEZET = SY-TIMLO.

    IF PV_FLAG IS INITIAL.
      ZNFT1020-CONFM = '1'.
    ELSE.
      ZNFT1020-CONFM = '2'.
    ENDIF.

    CLEAR : ZNFT1020-WHYCN, ZNFT1020-YNFIN,
            ZNFT1020-ZEPRO, ZNFT1020-YNNET,
            ZNFT1020-RESON, ZNFT1020-CODAT,
            ZNFT1020-COZET, ZNFT1020-CONAM,
            ZNFT1020-YNCAN.

    INSERT ZNFT1020 FROM ZNFT1020.

    IF SY-SUBRC = 0.
      CLEAR : GT_1020.

      MOVE-CORRESPONDING ZNFT1020 TO GT_1020.

      GT_1020-UPDKZ = 'N'.

      APPEND GT_1020.
    ELSE.
      GV_ERROR = '1'.
    ENDIF.

  ENDIF.

ENDFORM.                    " CREATE_NEW_FUTRUES_TRADING

*&---------------------------------------------------------------------*
*&      Form  GET_TRADING_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_TRADING_NO .

  CLEAR : ZNFT1020-NFUTN.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '10'
      OBJECT                  = 'ZNF2_00003'
    IMPORTING
      NUMBER                  = ZNFT1020-NFUTN
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
*&      Form  GET_TRADING_NO_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_TRADING_NO_NEW .

  DATA: LV_NFUTN    LIKE ZNFT1020-NFUTN.

  CLEAR : LV_NFUTN.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '10'
      OBJECT                  = 'ZNF2_00003'
    IMPORTING
      NUMBER                  = LV_NFUTN
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
*&      Form  UPDATE_NEW_FUTRUES_TRADING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPDATE_NEW_FUTRUES_TRADING  USING PV_FLAG.

  DATA: LV_CONFM LIKE ZNFT1020-CONFM.
  CLEAR : GT_1020.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF GT_1020
    FROM ZNFT1020
   WHERE NFUTN = GT_MAIN-NFUTN.

  IF SY-SUBRC = 0.
    GT_1020-UPDKZ = 'O'.

    APPEND GT_1020.
  ENDIF.

  IF PV_FLAG IS INITIAL.
    LV_CONFM = '1'.
  ELSE.
    LV_CONFM = '2'.
  ENDIF.

  UPDATE ZNFT1020 SET RUDAT = GT_MAIN-RUDAT
                      ENDAT = GT_MAIN-ENDAT
                      PRICE = GT_MAIN-PRICE
                      MISPD = GT_MAIN-MISPD
                      YNCAN = ' '
                      CONFM = LV_CONFM
                      AENAM = SY-UNAME
                      AEDAT = SY-DATLO
                      AEZET = SY-TIMLO
                WHERE NFUTN = GT_MAIN-NFUTN.

  IF SY-SUBRC = 0.
    GT_1020-UPDKZ = 'N'.
    GT_1020-RUDAT = GT_MAIN-RUDAT.
    GT_1020-ENDAT = GT_MAIN-ENDAT.
    GT_1020-PRICE = GT_MAIN-PRICE.
    GT_1020-MISPD = GT_MAIN-MISPD.
    GT_1020-YNCAN = ' '.
    GT_1020-CONFM = LV_CONFM.
    GT_1020-AENAM = SY-UNAME.
    GT_1020-AEDAT = SY-DATLO.
    GT_1020-AEZET = SY-TIMLO.

    APPEND GT_1020.
  ELSE.
    GV_ERROR = '1'.
  ENDIF.

ENDFORM.                    " UPDATE_NEW_FUTRUES_TRADING
*&---------------------------------------------------------------------*
*&      Form  DELETE_OLD_FUTURES_TRADING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DELETE_OLD_FUTURES_TRADING .

  CLEAR : GT_1020.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF GT_1020
    FROM ZNFT1020
   WHERE NFUTN = GT_MAIN-OFUTN.

  IF SY-SUBRC = 0.
    GT_1020-UPDKZ = 'O'.

    APPEND GT_1020.
  ENDIF.

  UPDATE ZNFT1020 SET YNCAN = 'X'
                      WHYCN = '1'
                      AENAM = SY-UNAME
                      AEDAT = SY-DATLO
                      AEZET = SY-TIMLO
                WHERE NFUTN = GT_MAIN-OFUTN.

  IF SY-SUBRC = 0.
    GT_1020-UPDKZ = 'N'.
    GT_1020-YNCAN = 'X'.
    GT_1020-WHYCN = '1'.
    GT_1020-AENAM = SY-UNAME.
    GT_1020-AEDAT = SY-DATLO.
    GT_1020-AEZET = SY-TIMLO.

    APPEND GT_1020.
  ELSE.
    GV_ERROR = '2'.
  ENDIF.

ENDFORM.                    " DELETE_OLD_FUTURES_TRADING
*&---------------------------------------------------------------------*
*&      Form  UPDATE_SHIFT_REQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPDATE_SHIFT_REQ  USING    PV_FLAG.
  DATA: LV_DRSTA    LIKE ZNFT1040-DRSTA.

  CLEAR : GT_1040.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF GT_1040
    FROM ZNFT1040
   WHERE SHFNO = GT_MAIN-SHFNO.

  IF SY-SUBRC = 0.
    GT_1040-UPDKZ = 'O'.

    APPEND GT_1040.
  ENDIF.

  IF PV_FLAG IS INITIAL.
    LV_DRSTA = '4'.    "접수
  ELSE.
    LV_DRSTA = '5'.    "확인대기
  ENDIF.

  UPDATE ZNFT1040 SET DRSTA = LV_DRSTA
                      AENAM = SY-UNAME
                      AEDAT = SY-DATLO
                      AEZET = SY-TIMLO
                WHERE SHFNO = GT_MAIN-SHFNO.

  IF SY-SUBRC = 0.
    GT_1040-UPDKZ = 'N'.
    GT_1040-DRSTA = LV_DRSTA.
    GT_1040-AENAM = SY-UNAME.
    GT_1040-AEDAT = SY-DATLO.
    GT_1040-AEZET = SY-TIMLO.

    APPEND GT_1040.
  ELSE.
    GV_ERROR = '3'.
  ENDIF.

ENDFORM.                    " UPDATE_SHIFT_REQ
*&---------------------------------------------------------------------*
*&      Form  SAVE_ZNFT1020_CHDOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_ZNFT1020_CHDOC  USING  PV_FLAG.
  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND.

  DATA: LV_NFUTN    LIKE ZNFT1020-NFUTN.

  CLEAR : ZNFT1020, YZNFT1020.

  IF PV_FLAG = 'N'.   "신규선물집행
    LV_NFUTN = GT_MAIN-NFUTN.
  ELSE.               "구 선물집행
    LV_NFUTN = GT_MAIN-OFUTN.
  ENDIF.

  READ TABLE GT_1020 WITH KEY UPDKZ = 'O'
                              NFUTN = LV_NFUTN.
  IF SY-SUBRC = 0.
    MOVE-CORRESPONDING GT_1020 TO YZNFT1020.

    LV_CDOC_UPD_OBJECT = 'U'.
  ELSE.
    IF PV_FLAG = 'N'.
      LV_CDOC_UPD_OBJECT = 'I'.
    ELSE.
      EXIT.
    ENDIF.
  ENDIF.

  READ TABLE GT_1020 WITH KEY UPDKZ = 'N'
                              NFUTN = LV_NFUTN.
  IF SY-SUBRC = 0.
    MOVE-CORRESPONDING GT_1020 TO ZNFT1020.
  ENDIF.

  LV_OBJECTID = LV_NFUTN.
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

ENDFORM.                    " SAVE_ZNFT1020_CHDOC
*&---------------------------------------------------------------------*
*&      Form  SAVE_ZNFT1040_CHDOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_ZNFT1040_CHDOC .
  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND.

  CLEAR   : XGT_1041, YGT_1041, ZNFT1040, YZNFT1040.
  REFRESH : XGT_1041, YGT_1041.

  READ TABLE GT_1040 WITH KEY UPDKZ = 'O'
                              SHFNO = GT_MAIN-SHFNO.
  IF SY-SUBRC = 0.
    MOVE-CORRESPONDING GT_1040 TO YZNFT1040.

    LV_CDOC_UPD_OBJECT = 'U'.
  ENDIF.

  LOOP AT GT_1041 WHERE UPDKZ = 'O'
                    AND SHFNO = GT_MAIN-SHFNO
                    AND GUBUN = '1'.
    CLEAR : YGT_1041.

    MOVE-CORRESPONDING GT_1041 TO YGT_1041.

    APPEND YGT_1041.
  ENDLOOP.

  READ TABLE GT_1040 WITH KEY UPDKZ = 'N'
                              SHFNO = GT_MAIN-SHFNO.
  IF SY-SUBRC = 0.
    MOVE-CORRESPONDING GT_1040 TO ZNFT1040.
  ENDIF.

  LOOP AT GT_1041 WHERE UPDKZ = 'N'
                    AND SHFNO = GT_MAIN-SHFNO
                    AND GUBUN = '1'.
    CLEAR : XGT_1041.

    MOVE-CORRESPONDING GT_1041 TO XGT_1041.

    XGT_1041-KZ = 'U'.

    APPEND XGT_1041.
  ENDLOOP.

  LV_OBJECTID = GT_MAIN-SHFNO.
  LV_TCODE    = SY-TCODE.

  CALL FUNCTION 'ZNFT1040CHDOC_WRITE_DOCUMENT'
    EXPORTING
      OBJECTID     = LV_OBJECTID
      TCODE        = LV_TCODE
      UTIME        = SY-TIMLO
      UDATE        = SY-DATLO
      USERNAME     = SY-UNAME
      N_ZNFT1040   = ZNFT1040
      O_ZNFT1040   = YZNFT1040
      UPD_ZNFT1040 = LV_CDOC_UPD_OBJECT
      UPD_ZNFT1041 = LV_CDOC_UPD_OBJECT
    TABLES
      XZNFT1041    = XGT_1041
      YZNFT1041    = YGT_1041.

ENDFORM.                    " SAVE_ZNFT1040_CHDOC
*&---------------------------------------------------------------------*
*&      Form  CHECK_SHIFT_APPOVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SHIFT_APPOVAL  USING    PV_ERROR.
  DATA: LV_NCCHK    LIKE ZNFT1050-NCCHK.

  CLEAR : PV_ERROR, GV_FLAG.

  LOOP AT GT_MAIN WHERE MARK = 'X'.
*--> [CHM2507-00010] 만기이동 기능개선
**** 청산선물 연결 위한 ALL 주석 처리
**** MARKET CURRY 일 시는 체크해야 함
    IF RB_2 IS NOT INITIAL OR
        RB_3 IS NOT INITIAL.      "박우진 추가 (2026.09.17)
      IF GT_MAIN-CFUTN IS NOT INITIAL.
        PV_ERROR = 'X'.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '청산된 선물집행번호입니다.'
                '만기이동할 수 없습니다.'.
        EXIT.
      ENDIF.
    ENDIF.
*<-- [CHM2507-00010] 만기이동 기능개선

    IF GT_MAIN-RUDAT IS INITIAL AND GT_MAIN-CHECK EQ 'X'.
      PV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '만기이동요청번호-항번' GT_MAIN-SHFNO GT_MAIN-H_NO1
              '의 집행일이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

    IF GT_MAIN-ENDAT IS INITIAL AND GT_MAIN-CHECK EQ 'X'.
      PV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '만기이동요청번호-항번' GT_MAIN-SHFNO GT_MAIN-H_NO1
              '의 만기일이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

*___만기일/FCM별 정산진행여부 점검
    CLEAR : LV_NCCHK.

    SELECT SINGLE NCCHK
      INTO LV_NCCHK
      FROM ZNFT1050
     WHERE BUKRS = P_BUKRS
       AND ENDAT = GT_MAIN-ENDAT
       AND FCM   = GT_MAIN-FCM.

    IF LV_NCCHK = 'X'.
      PV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '만기일/FCM' GT_MAIN-ENDAT GT_MAIN-FCM
              '에 대한 정산이 진행되었습니다.'.

      EXIT.
    ENDIF.

    IF GT_MAIN-MITYP <> 'A' AND GT_MAIN-PRICE IS INITIAL
                                             AND GT_MAIN-CHECK EQ 'X'.
      PV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '만기이동요청번호-항번' GT_MAIN-SHFNO GT_MAIN-H_NO1
              '의 집행단가가 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

*___요청만기월과 신규만기일의 월이 다른 경우
    IF GT_MAIN-REMON <> GT_MAIN-ENDAT(6).
      GV_FLAG = 'X'.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " CHECK_SHIFT_APPOVAL
*&---------------------------------------------------------------------*
*&      Form  UPDATE_SHIFT_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_SHIFT_ITEM .

  CLEAR : GT_1041.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF GT_1041
    FROM ZNFT1041
   WHERE SHFNO = GT_MAIN-SHFNO
     AND H_NO1 = GT_MAIN-H_NO1.

  IF SY-SUBRC = 0.
    GT_1041-UPDKZ = 'O'.

    APPEND GT_1041.
  ENDIF.

  UPDATE ZNFT1041 SET NFUTN = GT_MAIN-NFUTN
                      RUDAT = GT_MAIN-RUDAT
                      ENDAT = GT_MAIN-ENDAT
                      PRICE = GT_MAIN-PRICE
                      MISPD = GT_MAIN-MISPD
                      AENAM = SY-UNAME
                      AEDAT = SY-DATLO
                      AEZET = SY-TIMLO
                WHERE SHFNO = GT_MAIN-SHFNO
                  AND H_NO1 = GT_MAIN-H_NO1.

  IF SY-SUBRC = 0.
    GT_1041-UPDKZ = 'N'.
    GT_1041-NFUTN = GT_MAIN-NFUTN.
    GT_1041-RUDAT = GT_MAIN-RUDAT.
    GT_1041-ENDAT = GT_MAIN-ENDAT.
    GT_1041-PRICE = GT_MAIN-PRICE.
    GT_1041-MISPD = GT_MAIN-MISPD.
    GT_1041-AENAM = SY-UNAME.
    GT_1041-AEDAT = SY-DATLO.
    GT_1041-AEZET = SY-TIMLO.

    APPEND GT_1041.
  ELSE.
    GV_ERROR = '4'.
  ENDIF.

ENDFORM.                    " UPDATE_SHIFT_ITEM
*&---------------------------------------------------------------------*
*&      Form  UPDATE_SHIFT_ITEM_M
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_SHIFT_ITEM_M .

  CLEAR : GT_1041.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF GT_1041
    FROM ZNFT1041
   WHERE SHFNO = GT_MAIN-SHFNO
     AND H_NO1 = GT_MAIN-H_NO1.

  IF SY-SUBRC = 0.
    GT_1041-UPDKZ = 'O'.

    APPEND GT_1041.
  ENDIF.

  UPDATE ZNFT1041 SET NFUTN = GT_MAIN-NFUTN
                      RUDAT = GT_MAIN-RUDAT1
                      ENDAT = GT_MAIN-ENDAT1
                      PRICE = GT_MAIN-PRICE1
                      MISPD = GT_MAIN-MISPD1
                      AENAM = SY-UNAME
                      AEDAT = SY-DATLO
                      AEZET = SY-TIMLO
                WHERE SHFNO = GT_MAIN-SHFNO
                  AND H_NO1 = GT_MAIN-H_NO1.

  IF SY-SUBRC = 0.
    GT_1041-UPDKZ = 'N'.
    GT_1041-NFUTN = GT_MAIN-NFUTN.
    GT_1041-RUDAT = GT_MAIN-RUDAT1.
    GT_1041-ENDAT = GT_MAIN-ENDAT1.
    GT_1041-PRICE = GT_MAIN-PRICE1.
    GT_1041-MISPD = GT_MAIN-MISPD1.
    GT_1041-AENAM = SY-UNAME.
    GT_1041-AEDAT = SY-DATLO.
    GT_1041-AEZET = SY-TIMLO.

    APPEND GT_1041.
  ELSE.
    GV_ERROR = '4'.
  ENDIF.

ENDFORM.                    " UPDATE_SHIFT_ITEM_M
*&---------------------------------------------------------------------*
*&      Form  SAVE_APPROVE_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_APPROVE_REQUEST  USING    PV_FLAG.

  DELETE FROM ZNFT1091 WHERE NFNUM = GT_MAIN-SHFNO
                         AND CONSQ > '2'.

  UPDATE ZNFT1091 SET PERNR = GV_PERNR
                      USRID = SY-UNAME
                      CONST = 'A'
                      AEDAT = SY-DATLO
                      AEZET = SY-TIMLO
                      AENAM = SY-UNAME
                WHERE NFNUM = GT_MAIN-SHFNO
                  AND CONSQ = '2'
                  AND CONGB = '5'.

  IF SY-SUBRC = 0.
    IF PV_FLAG = 'X'.
      CLEAR : ZNFT1091.

      ZNFT1091-NFNUM = GT_MAIN-SHFNO.
      ZNFT1091-CONSQ = '3'.
      ZNFT1091-CONGB = '5'.
      ZNFT1091-BUKRS = GT_MAIN-BUKRS.
*      ZNFT1091-USRID = SY-UNAME.
      ZNFT1091-CONST = 'B'.
      ZNFT1091-ERDAT = SY-DATLO.
      ZNFT1091-ERZET = SY-TIMLO.
      ZNFT1091-ERNAM = SY-UNAME.
      ZNFT1091-AEDAT = SY-DATLO.
      ZNFT1091-AEZET = SY-TIMLO.
      ZNFT1091-AENAM = SY-UNAME.

      INSERT ZNFT1091 FROM ZNFT1091.

      IF SY-SUBRC <> 0.
        GV_ERROR = '5'.
      ENDIF.
    ENDIF.
  ELSE.
    GV_ERROR = '5'.
  ENDIF.

ENDFORM.                    " SAVE_APPROVE_REQUEST
*&---------------------------------------------------------------------*
*&      Form  DEQUEUE_ZNFT1040
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DEQUEUE_ZNFT1040 .

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    CLEAR : GT_MAIN-CHECK.

    PERFORM ENQUEUE_DEQUEUE_ZNFT1040.
    PERFORM ENQUEUE_DEQUEUE_ZNFT1020 USING GT_MAIN-OFUTN.

    LOOP AT GT_MAIN INTO GS_MAIN WHERE SHFNO = GT_MAIN-SHFNO.
      IF GS_MAIN-NFUTN IS NOT INITIAL.
        PERFORM ENQUEUE_DEQUEUE_ZNFT1020 USING GS_MAIN-NFUTN.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " DEQUEUE_ZNFT1040
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
*&      Form  CHECK_AUTHORIZATION_SHIFT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_AUTHORIZATION_SHIFT  USING    PV_ERROR.

  CLEAR :  PV_ERROR, GV_COMM.

  PERFORM GET_USRID_PER_SAPID TABLES GT_PERNR
                              USING  SY-UNAME
                                     GV_PERNR.

  IF GV_PERNR IS NOT INITIAL.
    SELECT SINGLE PERNR
      INTO GV_PERNR
      FROM ZNFT1090
     WHERE BUKRS = P_BUKRS
       AND CONGB = '5'
       AND CONSQ = '2'
       AND PERNR = GV_PERNR
       AND LVORM = ' '.

    IF SY-SUBRC = 0.
      GV_COMM = 'X'.
    ELSE.
      PV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '만기이동 권한이 없습니다. User ID:' SY-UNAME.
    ENDIF.
  ELSE.
    PV_ERROR = 'X'.

    LOOP AT GT_PERNR.
      SELECT SINGLE PERNR
        INTO GT_PERNR-PERNR
        FROM ZNFT1090
       WHERE BUKRS = P_BUKRS
         AND CONGB = '5'
         AND CONSQ = '2'
         AND PERNR = GT_PERNR-PERNR
         AND LVORM = ' '.

      IF SY-SUBRC = 0.
        CLEAR : PV_ERROR.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF PV_ERROR IS NOT INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '만기이동 권한이 없습니다. User ID:' SY-UNAME.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_AUTHORIZATION_SHIFT
*&---------------------------------------------------------------------*
*&      Form  CHECK_PASSWORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_PASSWORD .
  DATA: LV_PASWD.

  CLEAR : LV_PASWD.

  SELECT SINGLE PASWD
    INTO LV_PASWD
    FROM ZNFT1090
   WHERE BUKRS = P_BUKRS
     AND CONGB = '5'
     AND CONSQ = '2'
     AND PERNR = GV_PERNR.

  IF SY-SUBRC = 0.
    IF LV_PASWD = GV_PASWD.
      LEAVE TO SCREEN 0.
    ELSE.
      CLEAR : GV_PASWD.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '비밀번호를 잘못 입력하셨습니다.'.
    ENDIF.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '만기이동 권한이 없습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_PASSWORD
*&---------------------------------------------------------------------*
*&      Form  SAVE_ZNFT1030
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_ZNFT1030.

  IF GT_MAIN-GUBUN EQ '1'.
    IF GT_MAIN-CFUTN IS INITIAL .

      PERFORM GET_TRADING_NO_1030.

      ZNFT1030-CFUTN = GT_MAIN-CFUTN. "신규 청산번호
      ZNFT1030-NFUTN = GT_MAIN-NFUTN.
      ZNFT1030-BUKRS = P_BUKRS.
      ZNFT1030-ERDAT = SY-DATLO.
      ZNFT1030-ERZET = SY-TIMLO.
      ZNFT1030-ERNAM = SY-UNAME.
      ZNFT1030-AEDAT = SY-DATLO.
      ZNFT1030-AEZET = SY-TIMLO.
      ZNFT1030-AENAM = SY-UNAME.

*      ZNFT1030-RUDAT = GT_MAIN-RUDAT1.  "집행일
      "--> 마켓캐리 청산선물은 RUDAT(입력한 신규집행일)로 반영
      ZNFT1030-RUDAT = GT_MAIN-RUDAT.  "신규집행일
      ZNFT1030-FCM   = GT_MAIN-FCM.     "FCM
      ZNFT1030-ENDAT = GT_MAIN-ENDAT1.  "만기일
      ZNFT1030-MITYP = GT_MAIN-MITYP.   "집행유형
      ZNFT1030-MISPD = GT_MAIN-CMISPD.  "Spread
      ZNFT1030-MIMON = GT_MAIN-MIMON.   "기준월
      ZNFT1030-PRICE = GT_MAIN-CPRICE.  "집행단가
      ZNFT1030-EMENG = GT_MAIN-RMENG.   "집행수량은 요청수량으로...
      ZNFT1030-MISUS  =  'Y'.           "수수료여부

*--> 마켓커리 BUY/SELL 로직 수정
**** 기존 선물집행 BUY/SELL의 반대로 청산선물 BUY/SELL 반영 필요
*      ZNFT1030-BY_SL  =  'S'.           "Buy/Sell
      IF GT_MAIN-BY_SL = 'B'.
        ZNFT1030-BY_SL = 'S'.
      ELSEIF GT_MAIN-BY_SL = 'S'.
        ZNFT1030-BY_SL = 'B'.
      ENDIF.
*<-- 마켓커리 BUY/SELL 로직 수정
      ZNFT1030-CONFM = '3'.             "결재상태
**[S]MC 대상 집행번호의 청산번호 확인 후, 비고 값 이동 ** 박우진 (20260904)
*      ZNFT1030-BIGO4   = '만기이동'.    "비고

      SELECT SINGLE CFUTN, NFUTN, BIGO4
        INTO @DATA(LS_NFT1030)
        FROM  ZNFT1030
        WHERE NFUTN EQ @GT_MAIN-OFUTN.

      IF SY-SUBRC EQ 0.
        ZNFT1030-BIGO4   = LS_NFT1030-BIGO4.

      ENDIF.

**[E]MC 대상 집행번호의 청산번호 확인 후, 비고 값 이동 ** 박우진 (20260904)


      ZNFT1030-NFKEY   = GT_MAIN-NFKEY. "비철구분
      ZNFT1030-WAERS = GT_MAIN-WAERS.   "통화
      ZNFT1030-MEINS   = GT_MAIN-MEINS. "단위


      INSERT ZNFT1030 FROM ZNFT1030.
      IF SY-SUBRC = 0.
        COMMIT WORK.
      ELSE.
        GV_ERROR = 'X'.
      ENDIF.

    ENDIF.
  ENDIF.

ENDFORM.                    " SAVE_ZNFT1030
*&---------------------------------------------------------------------*
*&      Form  SAVE_ZNFT1030_CHANGE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_ZNFT1030_CHANGE_DOC USING PV_FLAG.
  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND,
        LV_UPD_ICDTXT      TYPE CHAR1.

  LV_CDOC_UPD_OBJECT = PV_FLAG.
  LV_OBJECTID        = GT_MAIN-NFUTN.
  LV_TCODE           = SY-TCODE.

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

ENDFORM.                    " SAVE_ZNFT1030_CHANGE_DOC
*&---------------------------------------------------------------------*
*&      Form  GET_TRADING_NO_1030
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_TRADING_NO_1030 .

  CLEAR : GT_MAIN-CFUTN.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '10'
      OBJECT                  = 'ZNF2_00004'
    IMPORTING
      NUMBER                  = GT_MAIN-CFUTN
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
*&      Form  GET_SHIFT_REQUEST_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SHIFT_REQUEST_NO .

  DATA:  LV_SHFNO LIKE ZNFT1041-SHFNO.
  CLEAR : ZNFT1041-SHFNO.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '10'
      OBJECT                  = 'ZNF2_00005'
    IMPORTING
      NUMBER                  = ZNFT1041-SHFNO
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

ENDFORM.                    " GET_SHIFT_REQUEST_NO
*&---------------------------------------------------------------------*
*& Form SEND_SIMPLE_APPROVAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MAIN_SHFNO
*&      --> GT_MAIN_BUKRS
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
*&---------------------------------------------------------------------*
*& Form CREATE_NEW_FUTRUES_TRADING_2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_FLAG
*&---------------------------------------------------------------------*
FORM CREATE_NEW_FUTRUES_TRADING_2 USING PV_FLAG.

  CLEAR : ZNFT1030.

  SELECT SINGLE *
    FROM ZNFT1030
   WHERE CFUTN = GT_MAIN-CFUTN_O.

  PERFORM GET_TRADING_NO_2.

  ZNFT1030-NFUTN = GT_MAIN-NFUTN.
  "--> UI 입력값 아닌 이동전 청산선물 정보로 반영해야 함
*  ZNFT1030-RUDAT = GT_MAIN-RUDAT.
*  ZNFT1030-ENDAT = GT_MAIN-ENDAT.
*  ZNFT1030-PRICE = GT_MAIN-PRICE.
*  ZNFT1030-MISPD = GT_MAIN-MISPD.
  ZNFT1030-EMENG = GT_MAIN-RMENG. "--> 수량은 분할 수량으로
*  ZNFT1030-MITYP = GT_MAIN-MITYP.
  ZNFT1030-OLDFT = GT_MAIN-CFUTN_O.
*  ZNFT1030-BIGO4 = '만기이동'.   "기존 비고값 보존
  ZNFT1030-ERNAM = SY-UNAME.
  ZNFT1030-ERDAT = SY-DATLO.
  ZNFT1030-ERZET = SY-TIMLO.
  ZNFT1030-AENAM = SY-UNAME.
  ZNFT1030-AEDAT = SY-DATLO.
  ZNFT1030-AEZET = SY-TIMLO.

  IF PV_FLAG IS INITIAL.
    ZNFT1030-CONFM = '1'.
  ELSE.
    ZNFT1030-CONFM = '2'.
  ENDIF.

  CLEAR : ZNFT1030-WHYCN, ZNFT1030-YNFIN,
          ZNFT1030-ZEPRO, ZNFT1030-YNNET,
          ZNFT1030-RESON, ZNFT1030-CODAT,
          ZNFT1030-COZET, ZNFT1030-CONAM,
          ZNFT1030-YNCAN.

  INSERT ZNFT1030 FROM ZNFT1030.

  IF SY-SUBRC = 0.
    CLEAR : GT_1030.

    MOVE-CORRESPONDING ZNFT1030 TO GT_1030.

    GT_1030-UPDKZ = 'N'.

    APPEND GT_1030.
  ELSE.
    GV_ERROR = '1'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_OLD_FUTURES_TRADING_2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELETE_OLD_FUTURES_TRADING_2 .

  CLEAR : GT_1030.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF GT_1030
    FROM ZNFT1030
   WHERE CFUTN = GT_MAIN-CFUTN_O.

  IF SY-SUBRC = 0.
    GT_1030-UPDKZ = 'O'.
    APPEND GT_1030.
  ENDIF.

  UPDATE ZNFT1030 SET YNCAN = 'X'
                      WHYCN = '1'
                      AENAM = SY-UNAME
                      AEDAT = SY-DATLO
                      AEZET = SY-TIMLO
                WHERE CFUTN = GT_MAIN-CFUTN_O.

  IF SY-SUBRC = 0.
    GT_1030-UPDKZ = 'N'.
    GT_1030-YNCAN = 'X'.
    GT_1030-WHYCN = '1'.
    GT_1030-AENAM = SY-UNAME.
    GT_1030-AEDAT = SY-DATLO.
    GT_1030-AEZET = SY-TIMLO.
    APPEND GT_1030.
  ELSE.
    GV_ERROR = '2'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TRADING_NO_2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_TRADING_NO_2 .

  CLEAR : ZNFT1030-CFUTN.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '10'
      OBJECT                  = 'ZNF2_00004'
    IMPORTING
      NUMBER                  = ZNFT1030-CFUTN
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_NEW_FUTRUES_TRADING_2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_FLAG
*&---------------------------------------------------------------------*
FORM UPDATE_NEW_FUTRUES_TRADING_2 USING PV_FLAG.

  DATA: LV_CONFM LIKE ZNFT1020-CONFM.
  CLEAR : GT_1030.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF GT_1030
    FROM ZNFT1030
   WHERE CFUTN = GT_MAIN-CFUTN.

  IF SY-SUBRC = 0.
    GT_1030-UPDKZ = 'O'.
    APPEND GT_1030.
  ENDIF.

  IF PV_FLAG IS INITIAL.
    LV_CONFM = '1'.
  ELSE.
    LV_CONFM = '2'.
  ENDIF.

  UPDATE ZNFT1030 SET
*                      RUDAT = GT_MAIN-RUDAT
*                      ENDAT = GT_MAIN-ENDAT
*                      PRICE = GT_MAIN-PRICE
*                      MISPD = GT_MAIN-MISPD
                      YNCAN = ' '
                      CONFM = LV_CONFM
                      AENAM = SY-UNAME
                      AEDAT = SY-DATLO
                      AEZET = SY-TIMLO
                WHERE CFUTN = GT_MAIN-CFUTN.

  IF SY-SUBRC = 0.
    GT_1030-UPDKZ = 'N'.
*    GT_1030-RUDAT = GT_MAIN-RUDAT.
*    GT_1030-ENDAT = GT_MAIN-ENDAT.
*    GT_1030-PRICE = GT_MAIN-PRICE.
*    GT_1030-MISPD = GT_MAIN-MISPD.
    GT_1030-YNCAN = ' '.
    GT_1030-CONFM = LV_CONFM.
    GT_1030-AENAM = SY-UNAME.
    GT_1030-AEDAT = SY-DATLO.
    GT_1030-AEZET = SY-TIMLO.

    APPEND GT_1030.
  ELSE.
    GV_ERROR = '1'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZNFT1030_CHDOC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SAVE_ZNFT1030_CHDOC USING  PV_FLAG.

  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND.

  DATA: LV_CFUTN LIKE ZNFT1030-CFUTN.

  CLEAR : ZNFT1030, YZNFT1030.

  IF PV_FLAG = 'N'. "--> 이동후 청산선물집행
    LV_CFUTN = GT_MAIN-CFUTN.
  ELSE.             "--> 이동전 청산선물집행
    LV_CFUTN = GT_MAIN-CFUTN_O.
  ENDIF.

  READ TABLE GT_1030 WITH KEY UPDKZ = 'O'
                              NFUTN = LV_CFUTN.
  IF SY-SUBRC = 0.
    MOVE-CORRESPONDING GT_1030 TO YZNFT1030.
    LV_CDOC_UPD_OBJECT = 'U'.
  ELSE.
    IF PV_FLAG = 'N'.
      LV_CDOC_UPD_OBJECT = 'I'.
    ELSE.
      EXIT.
    ENDIF.
  ENDIF.

  READ TABLE GT_1030 WITH KEY UPDKZ = 'N'
                              CFUTN = LV_CFUTN.
  IF SY-SUBRC = 0.
    MOVE-CORRESPONDING GT_1030 TO ZNFT1030.
  ENDIF.

  LV_OBJECTID = LV_CFUTN.
  LV_TCODE    = SY-TCODE.

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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_NEW_FUTRUES_TRADING_H
*&---------------------------------------------------------------------*
FORM CREATE_NEW_FUTRUES_TRADING_H USING PV_FLAG.
  DATA: LV_CNT TYPE I.
  DATA: LV_SHFNO LIKE ZNFT1041-SHFNO,
        LV_H_NO1 LIKE  ZNFT1041-H_NO1.
  DATA: LV_FUTNO TYPE ZFUTNO.   "박우진 추가(2026.08.02)

  CLEAR : ZNFT1020.


  IF GT_MAIN-GUBUN EQ '1'.
*> Markey Carry의 경우 두 번 생성함.
    DO 2 TIMES.

      ADD 1 TO LV_CNT.

      "만기이동 채번 이후(a), 신규 선물집행번호(b) 생성
      IF LV_CNT EQ '2'.

        PERFORM GET_TRADING_NO.

        ZNFT1020-BUKRS = GT_MAIN-BUKRS.
        ZNFT1020-CONFM = '2'.
*        ZNFT1020-BIGO4 = ''.    "비고 빈값처리
        ZNFT1020-MCTYP = 'N'.
        ZNFT1020-ERNAM = SY-UNAME.
        ZNFT1020-ERDAT = SY-DATLO.
        ZNFT1020-ERZET = SY-TIMLO.
        ZNFT1020-AENAM = SY-UNAME.
        ZNFT1020-AEDAT = SY-DATLO.
        ZNFT1020-AEZET = SY-TIMLO.
        ZNFT1020-RUDAT = GT_MAIN-RUDAT.
        ZNFT1020-ENDAT = GT_MAIN-ENDAT.
        ZNFT1020-PRICE = GT_MAIN-PRICE.
        ZNFT1020-MISPD = GT_MAIN-MISPD.
* [S] 만기이동 채번(a)과 신규 선물집행번호 연결 (2026.08.02 박우진)
* 유주수 대리 요청
*        ZNFT1020-OLDFT = ''.    기존 연결 Disconnection 원인.
        ZNFT1020-OLDFT = LV_FUTNO.

* [E] 만기이동 채번(a)과 신규 선물집행번호 연결

        SELECT SINGLE REQNO H_NO1
          INTO  (ZNFT1020-REQNO, ZNFT1020-H_NO1 )
          FROM   ZNFT1020
         WHERE  NFUTN EQ GT_MAIN-OFUTN.

        INSERT ZNFT1020 FROM ZNFT1020.

        IF SY-SUBRC EQ 0.
          COMMIT WORK.
        ENDIF.
*< Market Carry 만기이동 연결 (신규집행)

*> Market Carry Item Line의 만기이동 번호 찾기
        SELECT SINGLE MAX( H_NO1 )
          INTO    LV_H_NO1
          FROM  ZNFT1041
         WHERE SHFNO EQ GT_MAIN-SHFNO.

        LV_H_NO1 = LV_H_NO1 + 1.

        ZNFT1041-SHFNO = GT_MAIN-SHFNO. "만기이동요청번호
        ZNFT1041-H_NO1 = LV_H_NO1.   "항번
        ZNFT1041-NFUTN    = ZNFT1020-NFUTN.
        ZNFT1041-REMON  = GT_MAIN-REMON.
        ZNFT1041-RUDAT    = GT_MAIN-RUDAT.
        ZNFT1041-ENDAT    = GT_MAIN-ENDAT.
        ZNFT1041-PRICE     = GT_MAIN-PRICE.
        ZNFT1041-MISPD     = GT_MAIN-MISPD.
        ZNFT1041-MEINS   = GT_MAIN-MEINS.
        ZNFT1041-RMENG = GT_MAIN-RMENG.
        ZNFT1041-WAERS = GT_MAIN-WAERS.
        ZNFT1041-GUBUN =  '1'.
        ZNFT1041-ERNAM = SY-UNAME.
        ZNFT1041-ERDAT  = SY-DATLO.
        ZNFT1041-ERZET  = SY-TIMLO.
        ZNFT1041-AENAM = SY-UNAME.
        ZNFT1041-AEDAT  = SY-DATLO.
        ZNFT1041-AEZET  = SY-TIMLO.

        INSERT ZNFT1041 FROM ZNFT1041.

        IF SY-SUBRC EQ 0.
          COMMIT WORK.
          CLEAR : LV_SHFNO.
          CONTINUE.
        ENDIF.

      ELSE.
        "만기이동 번호 신규채번(a) (순서상 먼저 발생함).
        SELECT SINGLE *
          FROM ZNFT1020
         WHERE NFUTN = GT_MAIN-OFUTN.

        PERFORM GET_TRADING_NO.

* [S] 만기이동 채번(a)과 신규 선물집행번호 연결 (2026.08.02 박우진)
        CLEAR: LV_FUTNO.
        LV_FUTNO = ZNFT1020-NFUTN.
* [E] 만기이동 채번(a)과 신규 선물집행번호 연결 (2026.08.02 박우진)


*        ZNFT1020-RUDAT = GT_MAIN-RUDAT.
        "--> MCTYP = M은 RUDAT1(기존 집행일)로 반영되어야 함
        "--> MCTYP = N만 RUDAT(입력한 신규집행일)
        ZNFT1020-RUDAT = GT_MAIN-RUDAT1.
        ZNFT1020-ENDAT = GT_MAIN-ENDAT1.
        ZNFT1020-PRICE = GT_MAIN-PRICE1.
        ZNFT1020-MISPD = GT_MAIN-MISPD1.
        ZNFT1020-EMENG = GT_MAIN-RMENG.
        ZNFT1020-OLDFT = GT_MAIN-OFUTN.
*        ZNFT1020-BIGO4 = '만기이동'.   "유주수 비고란 Update비활성화요청(20260818/박우진)
        ZNFT1020-MCTYP = 'H'.   "HPC
        ZNFT1020-ERNAM = SY-UNAME.
        ZNFT1020-ERDAT = SY-DATLO.
        ZNFT1020-ERZET = SY-TIMLO.
        ZNFT1020-AENAM = SY-UNAME.
        ZNFT1020-AEDAT = SY-DATLO.
        ZNFT1020-AEZET = SY-TIMLO.

        IF PV_FLAG IS INITIAL.
          ZNFT1020-CONFM = '1'.
        ELSE.
          ZNFT1020-CONFM = '2'.
        ENDIF.

        CLEAR : ZNFT1020-WHYCN, ZNFT1020-YNFIN,
                ZNFT1020-ZEPRO, ZNFT1020-YNNET,
                ZNFT1020-RESON, ZNFT1020-CODAT,
                ZNFT1020-COZET, ZNFT1020-CONAM,
                ZNFT1020-YNCAN.

        INSERT ZNFT1020 FROM ZNFT1020.

        IF SY-SUBRC = 0.
          CLEAR : GT_1020.

          MOVE-CORRESPONDING ZNFT1020 TO GT_1020.

          GT_1020-UPDKZ = 'N'.

          APPEND GT_1020.
        ELSE.
          GV_ERROR = '1'.
        ENDIF.

      ENDIF.

    ENDDO.

  ELSE.
    "생성구분(1: 신규 2: 잔량)

    SELECT SINGLE *
      FROM ZNFT1020
     WHERE NFUTN = GT_MAIN-OFUTN.

    PERFORM GET_TRADING_NO.

    ZNFT1020-RUDAT = GT_MAIN-RUDAT.
    ZNFT1020-ENDAT = GT_MAIN-ENDAT.
    ZNFT1020-PRICE = GT_MAIN-PRICE.
    ZNFT1020-MISPD = GT_MAIN-MISPD.
    ZNFT1020-EMENG = GT_MAIN-RMENG.
    ZNFT1020-OLDFT = GT_MAIN-OFUTN.
*    ZNFT1020-BIGO4 = '만기이동'.
    ZNFT1020-MCTYP = 'N'.
    ZNFT1020-ERNAM = SY-UNAME.
    ZNFT1020-ERDAT = SY-DATLO.
    ZNFT1020-ERZET = SY-TIMLO.
    ZNFT1020-AENAM = SY-UNAME.
    ZNFT1020-AEDAT = SY-DATLO.
    ZNFT1020-AEZET = SY-TIMLO.

    IF PV_FLAG IS INITIAL.
      ZNFT1020-CONFM = '1'.
    ELSE.
      ZNFT1020-CONFM = '2'.
    ENDIF.

    CLEAR : ZNFT1020-WHYCN, ZNFT1020-YNFIN,
            ZNFT1020-ZEPRO, ZNFT1020-YNNET,
            ZNFT1020-RESON, ZNFT1020-CODAT,
            ZNFT1020-COZET, ZNFT1020-CONAM,
            ZNFT1020-YNCAN.

    INSERT ZNFT1020 FROM ZNFT1020.

    IF SY-SUBRC = 0.
      CLEAR : GT_1020.

      MOVE-CORRESPONDING ZNFT1020 TO GT_1020.

      GT_1020-UPDKZ = 'N'.

      APPEND GT_1020.
    ELSE.
      GV_ERROR = '1'.
    ENDIF.

  ENDIF.

ENDFORM.                    " CREATE_NEW_FUTRUES_TRADING
