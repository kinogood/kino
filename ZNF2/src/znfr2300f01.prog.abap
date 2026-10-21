*&---------------------------------------------------------------------*
*&  Include           ZNFR2300F01
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
        DYNAME     = 'ZNFR2300'
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
      DYNAME     = 'ZNFR2300'
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
      DYNAME     = 'ZNFR2300'
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
*&      Form  GET_ZNFT1020_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ZNFT1020_DATA .
  DATA: LV_SHFNO LIKE ZNFT1040-SHFNO,
        LV_EMENG LIKE ZNFT1030-EMENG,
        LV_ERROR.

  DATA: LT_1030 LIKE TABLE OF ZNFT1030 WITH HEADER LINE.


  CLEAR   : GT_1020.
  REFRESH : GT_1020.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_1020
    FROM ZNFT1020
   WHERE BUKRS =  P_BUKRS
     AND NFUTN IN S_NFUTN
     AND REQNO IN S_REQNO
     AND FCM   IN S_FCM
     AND RUDAT IN S_RUDAT
     AND BY_SL IN GR_BY_SL
     AND ENDAT IN S_ENDAT
     AND NFKEY IN S_NFKEY
     AND YNCAN =  ' '
     AND YNFIN =  ' '
     AND YNNET =  ' '
     AND CONFM IN ('3', '7').

* 청산번호 추가 / 박우진 2026.09.15
  IF GT_1020[] IS NOT INITIAL.
    SELECT CFUTN, NFUTN
      INTO CORRESPONDING FIELDS OF TABLE @LT_1030
      FROM ZNFT1030
      FOR ALL ENTRIES IN @GT_1020
      WHERE NFUTN = @GT_1020-NFUTN.
  ENDIF.

  LOOP AT GT_1020.
*___만기이동요청된 선물집행번호 제외
    SELECT SINGLE SHFNO
      INTO LV_SHFNO
      FROM ZNFT1040
     WHERE OFUTN = GT_1020-NFUTN
       AND YNCAN = ' '.

    IF SY-SUBRC = 0.
      DELETE GT_1020.
      CONTINUE.
    ENDIF.

*___선물요청/계약정보
    SELECT SINGLE A~YNFIN     "마감여부
                  A~ENDMM     "만기월
                  A~EMENG     "요청수량
                  A~MEINS     "단위
                  B~RQTYP     "요청유형
                  A~CONNO     "계약번호
                  C~COTXT     "계약명
                  C~PRCTR     "손익센터
                  C~VKGRP     "영업그룹
                  C~KUNNR     "고객코드
                  C~NCUST     "고객명
                  C~ZPJNO     "Project NO
      INTO (GT_1020-YNFIN1, GT_1020-ENDMM,
            GT_1020-EMENG1, GT_1020-MEINS1,
            GT_1020-RQTYP,  GT_1020-CONNO,
            GT_1020-COTXT,  GT_1020-PRCTR,
            GT_1020-VKGRP,  GT_1020-KUNNR,
            GT_1020-NCUST,  GT_1020-ZPJNO)
      FROM ZNFT1011 AS A
     INNER JOIN ZNFT1010 AS B
        ON A~REQNO = B~REQNO
     INNER JOIN ZNFT1000 AS C
        ON A~CONNO = C~CONNO
     WHERE A~REQNO = GT_1020-REQNO
       AND A~H_NO1 = GT_1020-H_NO1.

    IF NOT GT_1020-PRCTR IN S_PRCTR OR
       NOT GT_1020-VKGRP IN S_VKGRP OR
       NOT GT_1020-CONNO IN S_CONNO OR
       NOT GT_1020-ZPJNO IN S_ZPJNO.
      DELETE GT_1020.
      CONTINUE.
    ENDIF.

    IF GT_1020-KUNNR IS NOT INITIAL.
*___고객명
      PERFORM GET_KUNNR_DESC USING GT_1020-KUNNR
                                   GT_1020-NCUST.
    ENDIF.

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

*___요청유형 내역
    PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                   GT_1020-RQTYP
                                   GT_1020-RQTXT.

*___손익센터명
    PERFORM GET_PRCTR_DESC USING GV_KOKRS
                                 GT_1020-PRCTR
                                 GT_1020-PTEXT.

*...영업그룹
    PERFORM GET_VKGRP_DESC USING GT_1020-BUKRS
                                 GT_1020-VKGRP
                                 GT_1020-VKTXT.

*___가격구분/비철수주가
    PERFORM PRICE_CLASSIFICATION USING GT_1020-CONNO
                                       GT_1020-NFKEY
                                       GT_1020-PRIND
                                       GT_1020-SUJUP
                                       LV_ERROR.

* [S] 청산집행번호 추가 / 박우진 2026.09.15



    GT_1020-CFUTN = VALUE #( LT_1030[ NFUTN = GT_1020-NFUTN ]-CFUTN OPTIONAL ).
* [E] 청산집행번호 추가 / 박우진 2026.09.15



*___청산입력여부
    CLEAR : LV_EMENG.

    SELECT SUM( EMENG )
      INTO LV_EMENG
      FROM ZNFT1030
     WHERE BUKRS = P_BUKRS
       AND NFUTN = GT_1020-NFUTN
       AND YNCAN = ' '
       AND YNNET = ' '.

    IF LV_EMENG IS INITIAL.
      GT_1020-SETTL = '미청산'.
    ELSEIF LV_EMENG >= GT_1020-EMENG.
      GT_1020-SETTL = '청산완료'.
    ELSE.
      GT_1020-SETTL = '부분청산'.
    ENDIF.

    MODIFY GT_1020.
  ENDLOOP.

ENDFORM.                    " GET_ZNFT1020_DATA
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

  GV_ITAB = 'GT_1020'.

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
      ' '              'BUKRS' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'NFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '              'NFUTN' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

*[S] 청산집행번호 추가 / 2026.09.15 박우진
      'CFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '청산집행번호'              'CFUTN' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

*[E] 청산집행번호 추가 / 2026.09.15 박우진



      'RUDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'RUDAT' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'FCM'      ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'FCM'   'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'NAME1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      'FCM 명'         'NAME1' 'LFA1'     ' ' ' '    'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'NFKEY' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'BY_SL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      ' '              'BY_SL' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'BSTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      'Buy/Sell'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'ENDAT' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'MITYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      ' '              'MITYP' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'MITPT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '집행유형내역'   ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'MISPD'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '              'MISPD' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'MIMON'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '              'MIMON' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'PRICE'    'WARES'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'PRICE' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'WAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      ' '              'WAERS' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '              'EMENG' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'MEINS' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'REQNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'REQNO' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'H_NO1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'H_NO1' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'YNFIN1'   ' '      ' '     ' ' 'X' ' ' ' '    ' ' ' ' ' ' 1
      ' '              'YNFIN' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' ',

*.....사용자 혼돈 방지를 위해 '만기월' -> '최초요청만기월'로 변경
*     (C20121205_29599 Req.by 박선아 2012/12/27)
      'ENDMM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      '최초요청만기월' 'ENDMM' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG1'   ' '     'MEINS1' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '              'EMENG' 'ZNFT1011' ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'MEINS' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' ',

      'RQTYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      ' '              'RQTYP' 'ZNFT1010' ' ' ' '    'X' ' ' ' ' ' ',

      'RQTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '요청유형내역'   ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'PTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '손익센터 명'    'PTEXT' 'ZNFT0004' ' ' ' '    'X' ' ' ' ' ' ',

      'CONNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'CONNO' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' ',

      'COTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '              'COTXT' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'KUNNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'KUNNR' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'NCUST'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'NCUST' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'VKGRP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'VKGRP' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'ZPJNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'ZPJNO' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'VKTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'VTEXT' 'ZNFT0003' ' ' ' '    'X' ' ' ' ' ' ',

      'PRIND'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '가격구분'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'SUJUP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '비철수주가'     ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'SETTL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '청산상태'   ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' '.

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
  GS_VARIANT-HANDLE  = '0001'.

  GV_REPID = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_USER_COMMAND  = GV_USER_COMMAND
      I_CALLBACK_PF_STATUS_SET = GV_STATUS_SET
*     I_CALLBACK_TOP_OF_PAGE   = GV_TOP_OF_PAGE
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
      T_OUTTAB                 = GT_1020
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

  SET PF-STATUS 'STANDARD' EXCLUDING  EXTAB .

ENDFORM.                " PF_STATUS_SET
*&---------------------------------------------------------------------
*& Form USER_COMMAND
*&---------------------------------------------------------------------
FORM USER_COMMAND USING PV_UCOMM
                        PS_SELFIELD TYPE SLIS_SELFIELD.
  CASE PV_UCOMM.
    WHEN 'CREA'.
      PERFORM CHECK_SELECTED_ROWS.

      IF GV_ERROR IS INITIAL AND GT_1020-NFUTN IS NOT INITIAL.
*        IF GT_1020-SETTL = '청산완료'.
*          PERFORM POPUP_TO_CONFIRM
*            USING '확인'
*                  '청산이 완료된 건입니다. 계속하시겠습니까?'
*                  '1'
*                  GV_ANSWER.
*
*          IF GV_ANSWER <> '1'.
*            GV_ERROR = 'X'.
*          ENDIF.
*        ENDIF.

        IF GV_ERROR IS INITIAL.
          SET PARAMETER ID 'BUK'    FIELD GT_1020-BUKRS.
          SET PARAMETER ID 'ZNFNFT' FIELD GT_1020-NFUTN.

          CALL TRANSACTION 'ZNF2M2301' AND SKIP FIRST SCREEN.

          PERFORM GET_ZNFT1020_DATA.
        ENDIF.
      ENDIF.

    WHEN 'RFSH'.
      PERFORM GET_ZNFT1020_DATA.

    WHEN '&IC1'.
      CASE PS_SELFIELD-FIELDNAME.
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

        WHEN 'NFUTN'.
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
FORM CHECK_SELECTED_ROWS .
  DATA: LV_CNT      TYPE I.

  CLEAR : LV_CNT, GV_ERROR.

  LOOP AT GT_1020 WHERE CHECK = 'X'.
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

* 청산집행번호 Assign된 집행번호는 만기이동등록 불가 (2026.09.15 / 박우진)
  IF GT_1020-CFUTN IS NOT INITIAL.

    GV_ERROR = 'X'.

    MESSAGE S001 DISPLAY LIKE 'E'
       WITH '청산집행번호가 존재합니다. 만기이동요청을 진행할 수 없습니다'.

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
