*&---------------------------------------------------------------------*
*&  Include           ZNFR2240F01
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
        DYNAME     = 'ZNFR2240'
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
      DYNAME     = 'ZNFR2240'
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
    INTO TABLE GT_PRCTR
    FROM ZNFT0004
   WHERE KOKRS   =  P_BUKRS   "관리회계영역
     AND BDATU  >=  SY-DATLO  "효력만료일
     AND CFACTIV =  'X'.      "선물요청(활성)

  IF SY-SUBRC EQ 0.
    LOOP AT GT_PRCTR.
      PERFORM GET_PRCTR_DESC USING P_BUKRS
                                   GT_PRCTR-PRCTR
                                   GT_PRCTR-PTEXT.

      MODIFY GT_PRCTR.
    ENDLOOP.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '손익센터가 없습니다.'.
    EXIT.
  ENDIF.

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
       WITH '신규/청산 구분을 선택하시기 바랍니다.'.

    EXIT.
  ENDIF.

  IF S_NFUTN[] IS NOT INITIAL AND S_CFUTN[] IS INITIAL.
    CLEAR : P_CHK02.

    P_CHK01 = 'X'.
  ENDIF.

  IF S_CFUTN[] IS NOT INITIAL AND S_NFUTN[] IS INITIAL.
    CLEAR : P_CHK01.

    P_CHK02 = 'X'.
  ENDIF.

  IF S_NFUTN[] IS NOT INITIAL AND S_CFUTN[] IS NOT INITIAL.
    P_CHK01 = 'X'.
    P_CHK02 = 'X'.
  ENDIF.

  IF P_CHK01 IS INITIAL AND P_CHK02 IS INITIAL.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '신규/청산 구분을 선택하시기 바랍니다.'.

    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_CHECKBOX
*&---------------------------------------------------------------------*
*&      Form  GET_FUTURES_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_FUTURES_DATA .

  CLEAR   : GT_MAIN.
  REFRESH : GT_MAIN.

  IF P_CHK01 = 'X'.
*___신규선물집행
    PERFORM GET_ZNFT1020_DATA.
  ENDIF.

  IF P_CHK02 = 'X'.
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

  DATA: LV_ERROR.
  DATA: LV_SHFNO LIKE ZNFT1040-SHFNO.

  CLEAR   : GT_1020.
  REFRESH : GT_1020.

  SELECT *
    INTO TABLE GT_1020
    FROM ZNFT1020
   WHERE BUKRS EQ P_BUKRS
     AND NFUTN IN S_NFUTN
     AND FCM   IN S_FCM
     AND ENDAT IN S_ENDAT
     AND RUDAT IN S_RUDAT
     AND BY_SL IN S_BY_SL
     AND YNFIN EQ ' '
     AND CONFM IN ('3', '5', '7', '8'). "승인/수정생성/수정승인/수정반려

  LOOP AT GT_1020.
    CLEAR : GT_MAIN.

*   수정승인 이후 삭제된 건은 수정대상에서 제외
*   분할 & 만기이동에 의한 삭제건 제외
    IF ( GT_1020-YNCAN EQ 'X' AND GT_1020-CONFM EQ '7' ) OR
       ( GT_1020-YNCAN EQ 'X' AND GT_1020-CONFM EQ '3'
                              AND GT_1020-WHYCN NE ''  ).
      CONTINUE.
    ENDIF.

*   만기이동요청된 선물집행번호 제외
*   (2012/09/18 EDB03 Req.by박선아)
    SELECT SINGLE SHFNO
      INTO LV_SHFNO
      FROM ZNFT1040
     WHERE OFUTN = GT_1020-NFUTN
       AND YNCAN = ' '.

    IF SY-SUBRC = 0.
      CONTINUE.
    ENDIF.

    MOVE-CORRESPONDING GT_1020 TO GT_MAIN.

*___계약/선물요청 정보
    SELECT SINGLE A~CONNO   "계약번호
                  A~COTXT   "계약명
                  A~KUNNR   "고객코드
                  A~NCUST   "고객명
                  A~PRCTR   "손익센터
                  A~SALER   "영업담당자
                  B~ENDMM   "만기월
                  B~EMENG   "요청수량
                  B~MEINS   "단위
                  C~RQTYP   "요청유형
      INTO (GT_MAIN-CONNO, GT_MAIN-COTXT,
            GT_MAIN-KUNNR, GT_MAIN-NCUST,
            GT_MAIN-PRCTR, GT_MAIN-SALER,
            GT_MAIN-ENDMM, GT_MAIN-REQTY,
            GT_MAIN-REQME, GT_MAIN-RQTYP)
      FROM ZNFT1000 AS A
           INNER JOIN ZNFT1011 AS B
              ON A~CONNO EQ B~CONNO
           INNER JOIN ZNFT1010 AS C
              ON B~REQNO EQ C~REQNO
     WHERE A~BUKRS EQ P_BUKRS
       AND B~REQNO EQ GT_MAIN-REQNO
       AND B~H_NO1 EQ GT_MAIN-H_NO1.

    IF NOT GT_MAIN-PRCTR IN S_PRCTR.
      DELETE GT_1020.
      CONTINUE.
    ENDIF.

*   연결된 청산건 상태 점검 : 취소이면서 승인, 수정승인 제
    SELECT SINGLE CFUTN RUDAT CONFM
      INTO (GT_MAIN-NFUTN1, GT_MAIN-RUDAT1, GT_MAIN-CONFM1)
      FROM ZNFT1030
     WHERE BUKRS EQ P_BUKRS
       AND NFUTN EQ GT_1020-NFUTN
       AND ( YNCAN EQ SPACE OR ( CONFM NE '3' AND CONFM NE '7') ).

    IF SY-SUBRC EQ 0.

    ENDIF.

*___고객명
    IF GT_MAIN-KUNNR IS NOT INITIAL.
      PERFORM GET_KUNNR_DESC USING GT_MAIN-KUNNR
                                   GT_MAIN-NCUST.
    ENDIF.

*___FCM 명
    PERFORM GET_LIFNR_DESC USING GT_MAIN-FCM
                                 GT_MAIN-NAME1.

*___Buy/Sell
    PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                   GT_MAIN-BY_SL
                                   GT_MAIN-BY_SL_NM.

*___손익센터명
    PERFORM GET_PRCTR_DESC USING GV_KOKRS
                                 GT_MAIN-PRCTR
                                 GT_MAIN-PTEXT.

*___결재상태내역
    PERFORM DOMAIN_VALUE_GET USING 'ZCONFM3'
                                   GT_MAIN-CONFM
                                   GT_MAIN-CFMTX.

*___요청유형내역
    PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                   GT_MAIN-RQTYP
                                   GT_MAIN-RQTPT.

*___가격구분/비철수주가
    PERFORM PRICE_CLASSIFICATION USING GT_MAIN-CONNO
                                       GT_MAIN-NFKEY
                                       GT_MAIN-PRIND
                                       GT_MAIN-SUJUP
                                       LV_ERROR.

    GT_MAIN-NCIND = 'N'.
    GT_MAIN-NCTXT = '신규'.

    APPEND GT_MAIN.
  ENDLOOP.

ENDFORM.                    " GET_ZNFT1020_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_ZNFT1030_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_ZNFT1030_DATA .

  DATA: LV_ERROR.
  DATA: LV_SHFNO LIKE ZNFT1040-SHFNO.

  CLEAR   : GT_1030.
  REFRESH : GT_1030.

  SELECT *
    INTO TABLE GT_1030
    FROM ZNFT1030
   WHERE BUKRS EQ P_BUKRS
     AND CFUTN IN S_CFUTN
     AND FCM   IN S_FCM
     AND ENDAT IN S_ENDAT
     AND RUDAT IN S_RUDAT
     AND BY_SL IN S_BY_SL
     AND YNFIN EQ ' '
     AND YNNET EQ ' '
     AND CONFM IN ('3', '5', '7', '8'). "승인/수정생성/수정승인/수정반려

  LOOP AT GT_1030.
    CLEAR : GT_MAIN.

*   수정승인 이후 삭제된 건은 수정대상에서 제외
*   분할 & 만기이동에 의한 삭제건 제외
    IF ( GT_1030-YNCAN EQ 'X' AND GT_1030-CONFM EQ '7' ) OR
       ( GT_1030-YNCAN EQ 'X' AND GT_1030-CONFM EQ '3'
                              AND GT_1030-WHYCN NE ''  ).
      CONTINUE.
    ENDIF.

**   만기이동요청된 선물집행번호 제외
**   (2012/09/18 EDB03 Req.by박선아)
*    SELECT SINGLE SHFNO
*      INTO LV_SHFNO
*      FROM ZNFT1040
*     WHERE OFUTN = GT_1030-NFUTN
*       AND YNCAN = ' '.
*
*    IF SY-SUBRC = 0.
*      CONTINUE.
*    ENDIF.

    MOVE-CORRESPONDING GT_1030 TO GT_MAIN.

    GT_MAIN-NFUTN  = GT_1030-CFUTN.
    GT_MAIN-NFUTN1 = GT_1030-NFUTN.

*___계약/선물요청 정보
    SELECT SINGLE A~NFUTN   "신규선물집행번호
                  A~RUDAT   "신규선물집행일
                  A~CONFM   "신규선물집행 결재상태
                  C~CONNO   "계약번호
                  C~COTXT   "계약명
                  C~KUNNR   "고객코드
                  C~NCUST   "고객명
                  C~PRCTR   "손익센터
                  C~SALER   "영업담당자
                  B~REQNO   "선물요청번호
                  B~H_NO1   "선물요청항번
                  B~ENDMM   "만기월
                  B~EMENG   "요청수량
                  B~MEINS   "단위
                  D~RQTYP   "요청유형
      INTO (GT_MAIN-NFUTN1, GT_MAIN-RUDAT1,
            GT_MAIN-CONFM1, GT_MAIN-CONNO,
            GT_MAIN-COTXT,  GT_MAIN-KUNNR,
            GT_MAIN-NCUST,  GT_MAIN-PRCTR,
            GT_MAIN-SALER,  GT_MAIN-REQNO,
            GT_MAIN-H_NO1,  GT_MAIN-ENDMM,
            GT_MAIN-REQTY,  GT_MAIN-REQME,
            GT_MAIN-RQTYP)
      FROM ZNFT1020 AS A
           INNER JOIN ZNFT1011 AS B
              ON A~REQNO EQ B~REQNO AND A~H_NO1 EQ B~H_NO1
           INNER JOIN ZNFT1000 AS C
              ON B~CONNO EQ C~CONNO
           INNER JOIN ZNFT1010 AS D
              ON A~REQNO EQ D~REQNO
     WHERE A~BUKRS EQ P_BUKRS
       AND A~NFUTN EQ GT_1030-NFUTN.

    IF SY-SUBRC EQ 0.
*      DELETE GT_1030.
*      CONTINUE.
    ENDIF.

    IF NOT GT_MAIN-PRCTR IN S_PRCTR.
      DELETE GT_1030.
      CONTINUE.
    ENDIF.

*___고객명
    IF GT_MAIN-KUNNR IS NOT INITIAL.
      PERFORM GET_KUNNR_DESC USING GT_MAIN-KUNNR
                                   GT_MAIN-NCUST.
    ENDIF.

*___FCM 명
    PERFORM GET_LIFNR_DESC USING GT_MAIN-FCM
                                 GT_MAIN-NAME1.

*___Buy/Sell
    PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                   GT_MAIN-BY_SL
                                   GT_MAIN-BY_SL_NM.

*___손익센터명
    PERFORM GET_PRCTR_DESC USING GV_KOKRS
                                 GT_MAIN-PRCTR
                                 GT_MAIN-PTEXT.

*___결재상태내역
    PERFORM DOMAIN_VALUE_GET USING 'ZCONFM3'
                                   GT_MAIN-CONFM
                                   GT_MAIN-CFMTX.

*___요청유형내역
    PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                   GT_MAIN-RQTYP
                                   GT_MAIN-RQTPT.

*___가격구분/비철수주가
    PERFORM PRICE_CLASSIFICATION USING GT_MAIN-CONNO
                                       GT_MAIN-NFKEY
                                       GT_MAIN-PRIND
                                       GT_MAIN-SUJUP
                                       LV_ERROR.

    GT_MAIN-NCIND  = 'C'.
    GT_MAIN-NCTXT  = '청산'.

    APPEND GT_MAIN.
  ENDLOOP.

ENDFORM.                    " GET_ZNFT1030_DATA
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
      '회사코드'     'BUKRS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'NCTXT'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      '구분'         ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'NFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      '집행번호'     'NFUTN'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'RESON'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 100
      '변경사유'     'RESON'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' 'X',

      'YNCAN'    ' '      ' '     ' ' 'X' ' ' ' '    ' ' ' ' ' ' 8
      '삭제여부'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' 'X',

      'RUDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '집행일'       'RUDAT'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' 'X',

      'FCM'      ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'FCM'    'ZNFT1020'  ' ' ' '    'X' ' ' ' ' 'X',

      'NAME1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      'FCM 명'       'NAME1'  'LFA1'      ' ' ' '    'X' ' ' ' ' ' ',

      'BY_SL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 8
      'Buy-Sell'     'BY_SL'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'BY_SL_NM'  ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 8
      'Buy-Sell'     'BY_SL'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '만기일'       'ENDAT'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' 'X',

      'MITYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 8
      '집행유형'     'MITYP'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' 'X',

      'MISPD'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      'Spread'       'MISPD'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' 'X',

      'MIMON'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      '기준월'       'MIMON'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' 'X',

      'PRICE'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '집행단가'     'PRICE'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' 'X',

      'WAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      '통화'         'WAERS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '집행수량'     'EMENG'  'ZNFT1020'  ' ' ' '    ' ' ' ' ' ' 'X',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      '단위'         'MEINS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'MISUS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '수수료'       'MISUS'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' 'X',

      'CONFM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      '결재상태'     'CONFM'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'CFMTX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '결재상태'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      '비철구분'     'NFKEY'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'NFUTN1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 16
      '연결선물집행번호' 'NFUTN' 'ZNFT1020' ' ' ' '  'X' ' ' ' ' ' ',

      'RUDAT1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 14
      '연결선물집행일' 'RUDAT' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

*      'CONFM1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
*      '연결상태'       'CONFM' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'REQNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 12
      '요청번호'     'REQNO'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'H_NO1'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 5
      '요청항번'     'H_NO1'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' ' ',

      'ENDMM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      '만기월'       'ENDMM'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'REQTY'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '요청수량'     'EMENG'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'REQME'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      '단위'         'MEINS'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'RQTYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      '요청유형'     'RQTYP'  'ZNFT1010'  ' ' ' '    'X' ' ' ' ' ' ',

      'RQTPT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '요청유형'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'PTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '손익센터명'   'PTEXT' 'ZNFT0004' ' ' ' '    'X' ' ' ' ' ' ',

      'CONNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '계약번호'     'CONNO'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'COTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '계약명'       'COTXT'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'NCUST'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '고객명'       'NCUST'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'SALER'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'SALER'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRIND'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 15
      '가격구분'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'SUJUP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 12
      '비철수주가'   ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'BIGO4'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      ' '            'BIGO4'  'ZNFT1020'  ' ' ' '    'X' ' ' ' ' 'X'.

*     변경사유필드 추가예정

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

  GS_FIELDCAT-TABNAME        = GV_ITAB.

  IF PV_FNAME = 'FCM' OR PV_FNAME = 'MIMON'.
    GS_FIELDCAT-F4AVAILABL   = 'X'.
  ENDIF.

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
  LOOP AT GT_MAIN.
    CLEAR   : LT_CELLTAB, LT_COLOR.
    REFRESH : LT_CELLTAB, LT_COLOR.

    PERFORM FILL_CELLTAB_C CHANGING LT_CELLTAB.
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
      IF GT_MAIN-CHECK IS INITIAL.
        IF LS_CELLTAB-FIELDNAME = 'CHECK'.

*         선택필드 제어 조건 : 신규나 청산인 경우
*         승인된 데이터는 변경불가
          IF GT_MAIN-NCIND EQ 'N'.
            IF GT_MAIN-CONFM1 NE '3' AND GT_MAIN-CONFM1 NE '7'
                                     AND GT_MAIN-CONFM1 NE SPACE.
              LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
            ELSE.
              LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
            ENDIF.
          ELSE.
            IF GT_MAIN-CONFM1 NE '3' AND GT_MAIN-CONFM1 NE '7'
                                     AND GT_MAIN-CONFM1 NE SPACE.
              LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
            ELSE.
              LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
            ENDIF.
          ENDIF.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                           + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        ENDIF.

      ELSE.

        IF ( GT_MAIN-NCIND = 'C' AND LS_CELLTAB-FIELDNAME = 'EMENG' ) OR
           ( GT_MAIN-MITYP = 'S' AND LS_CELLTAB-FIELDNAME = 'MIMON' ) OR
           ( GT_MAIN-MITYP = 'S' AND LS_CELLTAB-FIELDNAME = 'MISPD' ) OR
           ( GT_MAIN-NCIND = 'N' AND LS_CELLTAB-FIELDNAME = 'EMENG' ).
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                           + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
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
      IF LS_COLOR-FNAME <> 'CHECK'.
        LS_COLOR-COLOR-COL = 4.
        LS_COLOR-COLOR-INT = 1.

        INSERT LS_COLOR INTO TABLE PT_COLOR.
      ENDIF.
    ELSE.
      IF GT_MAIN-CHECK = 'X'.
        IF L_FIELDCAT-EDIT IS INITIAL OR
           ( GT_MAIN-NCIND = 'C' AND LS_COLOR-FNAME = 'EMENG' ) OR
           ( GT_MAIN-MITYP = 'S' AND LS_COLOR-FNAME = 'MIMON' ) OR
           ( GT_MAIN-MITYP = 'S' AND LS_COLOR-FNAME = 'MISPD' ) OR
           ( GT_MAIN-NCIND = 'N' AND LS_COLOR-FNAME = 'EMENG' ).
          LS_COLOR-COLOR-COL = 7.
          LS_COLOR-COLOR-INT = 1.
          INSERT LS_COLOR INTO TABLE PT_COLOR.
        ENDIF.
      ELSE.
        LS_COLOR-COLOR-COL = 2.
        LS_COLOR-COLOR-INT = 0.
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

*  SET HANDLER GC_EVENT_HANDLER->HANDLE_TOOLBAR       FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_DOUBLE_CLICK  FOR GC_ALV_GRID.
*  SET HANDLER GC_EVENT_HANDLER->HANDLE_DATA_CHANGED  FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_DATA_CHANGED_FINISHED
          FOR GC_ALV_GRID.
*  SET HANDLER GC_EVENT_HANDLER->HANDLE_USER_COMMAND  FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_ONF4          FOR GC_ALV_GRID.

ENDFORM.                    " EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*&      Form  SET_F4HELP_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_F4HELP_FIELD .

  CLEAR   : GS_F4.
  REFRESH : GT_F4.

*___F4 FIELD 등록 - 필드명을 ABC순으로 기술하여야 함
  GS_F4-FIELDNAME = 'FCM'.    "FCM
  GS_F4-REGISTER  = 'X'.
  APPEND GS_F4 TO GT_F4.

  GS_F4-FIELDNAME = 'MIMON'.  "기준월
  GS_F4-REGISTER  = 'X'.
  APPEND GS_F4 TO GT_F4.

  CALL METHOD GC_ALV_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = GT_F4.

ENDFORM.                    " SET_F4HELP_FIELD
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
*&      Form  DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED  USING    E_MODIFIED
                                     ET_GOOD_CELLS TYPE LVC_T_MODI.

  DATA: LS_GOOD_CELLS TYPE LVC_S_MODI.

  LOOP AT ET_GOOD_CELLS INTO LS_GOOD_CELLS.
    READ TABLE GT_MAIN INDEX LS_GOOD_CELLS-ROW_ID.
    IF SY-SUBRC = 0.
      CASE LS_GOOD_CELLS-FIELDNAME.
        WHEN 'CHECK'.
          IF GT_MAIN-NCIND = 'N'.  "신규
            PERFORM ENQUEUE_DEQUEUE_ZNFT1020.
          ELSE.                    "청산
            PERFORM ENQUEUE_DEQUEUE_ZNFT1030.
          ENDIF.

*       삭제여부
        WHEN 'YNCAN'.
          IF LS_GOOD_CELLS-VALUE = 'X'.
            GT_MAIN-YNCAN = 'X'.
          ELSE.
            CLEAR GT_MAIN-YNCAN.
          ENDIF.

        WHEN 'MITYP'.
          IF GT_MAIN-MITYP = 'S'.
            CLEAR : GT_MAIN-MIMON.
          ENDIF.

        WHEN 'MIMON'.
          IF GT_MAIN-MIMON+4(2) < '01' OR GT_MAIN-MIMON+4(2) > '12'.
            MESSAGE I001 DISPLAY LIKE 'E'
               WITH '기준월을 점검하시기 바랍니다.'.

            CLEAR : GT_MAIN-MIMON.
          ENDIF.

        WHEN 'FCM'.
          PERFORM CHECK_FCM.

        WHEN 'EMENG'.
          PERFORM CHECK_REMAIN_QTY USING GV_ERROR.

      ENDCASE.

      MODIFY GT_MAIN INDEX LS_GOOD_CELLS-ROW_ID.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_DEQUEUE_ZNFT1020
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ENQUEUE_DEQUEUE_ZNFT1020 .
  DATA: LV_MSGV1    LIKE SY-MSGV1.

  IF GT_MAIN-CHECK IS INITIAL.
    CALL FUNCTION 'DEQUEUE_EZ_ZNFT1020'
      EXPORTING
        NFUTN = GT_MAIN-NFUTN.
  ELSE.
    CALL FUNCTION 'ENQUEUE_EZ_ZNFT1020'
      EXPORTING
        NFUTN          = GT_MAIN-NFUTN
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.

    IF SY-SUBRC <> 0.
      CLEAR : GT_MAIN-CHECK.
      LV_MSGV1 = SY-MSGV1.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '신규선물집행 번호' GT_MAIN-NFUTN
              '이(가) 현재 처리중입니다. 사용자:' LV_MSGV1.
    ENDIF.
  ENDIF.

ENDFORM.                    " ENQUEUE_DEQUEUE_ZNFT1020
*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_DEQUEUE_ZNFT1030
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ENQUEUE_DEQUEUE_ZNFT1030 .
  DATA: LV_MSGV1    LIKE SY-MSGV1.

  IF GT_MAIN-CHECK IS INITIAL.
    CALL FUNCTION 'DEQUEUE_EZ_ZNFT1030'
      EXPORTING
        CFUTN = GT_MAIN-NFUTN.
  ELSE.
    CALL FUNCTION 'ENQUEUE_EZ_ZNFT1030'
      EXPORTING
        CFUTN          = GT_MAIN-NFUTN
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.

    IF SY-SUBRC <> 0.
      CLEAR : GT_MAIN-CHECK.
      LV_MSGV1 = SY-MSGV1.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '청산선물집행 번호' GT_MAIN-NFUTN
              '이(가) 현재 처리중입니다. 사용자:' LV_MSGV1.
    ENDIF.
  ENDIF.

ENDFORM.                    " ENQUEUE_DEQUEUE_ZNFT1030
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
        READ TABLE GT_MAIN INDEX E_ROW-INDEX.
        IF SY-SUBRC = 0 AND GT_MAIN-REQNO IS NOT INITIAL.
          SET PARAMETER ID 'ZNFREQ' FIELD GT_MAIN-REQNO.
          CALL TRANSACTION 'ZNF2M2103' AND SKIP FIRST SCREEN.
        ENDIF.
      WHEN 'NFUTN'.
        IF GT_MAIN-NCIND EQ 'N'.
          PERFORM CALL_NFUTN_PGM USING GT_MAIN-NFUTN.
        ELSE.
          PERFORM CALL_CFUTN_PGM USING GT_MAIN-NFUTN.
        ENDIF.
      WHEN 'NFUTN1'.
        IF GT_MAIN-NCIND EQ 'N'.
          IF GT_MAIN-NFUTN1 IS NOT INITIAL.
            PERFORM CALL_CFUTN_PGM USING GT_MAIN-NFUTN1.
          ENDIF.
        ELSE.
          IF GT_MAIN-NFUTN1 IS NOT INITIAL.
            PERFORM CALL_NFUTN_PGM USING GT_MAIN-NFUTN1.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDIF.

ENDFORM.                    " DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_ALL .

  LOOP AT GT_MAIN.
    CHECK GT_MAIN-CONFM1 = '3' OR GT_MAIN-CONFM1 = '7' OR
          GT_MAIN-CONFM1 IS INITIAL.

    IF OK_SAVE = 'ASEL'.
      GT_MAIN-CHECK = 'X'.
    ELSE.
      CLEAR : GT_MAIN-CHECK.
    ENDIF.

    IF GT_MAIN-NCIND = 'N'.
      PERFORM ENQUEUE_DEQUEUE_ZNFT1020.
    ELSE.
      PERFORM ENQUEUE_DEQUEUE_ZNFT1030.
    ENDIF.

    MODIFY GT_MAIN.
  ENDLOOP.

ENDFORM.                    " SELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  ON_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ON_F4  USING SENDER         TYPE REF TO CL_GUI_ALV_GRID
                  E_FIELDNAME    TYPE LVC_FNAME
                  E_FIELDVALUE   TYPE LVC_VALUE
                  ES_ROW_NO      TYPE LVC_S_ROID
                  ER_EVENT_DATA  TYPE REF TO CL_ALV_EVENT_DATA
                  ET_BAD_CELLS   TYPE LVC_T_MODI
                  E_DISPLAY      TYPE CHAR01.
  DATA: LV_FCM      LIKE ZNFT1020-FCM.

  IF GC_ALV_GRID->IS_READY_FOR_INPUT( ) = 0.  "조회모드
    EXIT.
  ENDIF.

  READ TABLE GT_MAIN INDEX ES_ROW_NO-ROW_ID.
  IF GT_MAIN-CHECK IS INITIAL.
    EXIT.
  ENDIF.

  CASE E_FIELDNAME.
    WHEN 'FCM'.     "FCM
      READ TABLE GT_MAIN INDEX ES_ROW_NO-ROW_ID.
      IF SY-SUBRC = 0.
        PERFORM F4HELP_FCM USING GT_MAIN-FCM.

        PERFORM GET_LIFNR_DESC USING GT_MAIN-FCM
                                     GT_MAIN-NAME1.

        IF GT_MAIN-NCIND = 'C'.
*___청산인 경우 신규선물집행의 FCM과 비교
          PERFORM CHECK_NEW_FUTURES_FCM.
        ENDIF.

        MODIFY GT_MAIN INDEX ES_ROW_NO-ROW_ID.
      ENDIF.

    WHEN 'MIMON'.   "기준월
      READ TABLE GT_MAIN INDEX ES_ROW_NO-ROW_ID.
      IF SY-SUBRC = 0.
        CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
          EXPORTING
            ACTUAL_MONTH   = SY-DATLO(6)
          IMPORTING
            SELECTED_MONTH = GT_MAIN-MIMON.

        IF GT_MAIN-MITYP = 'A'.
          MODIFY GT_MAIN INDEX ES_ROW_NO-ROW_ID.
        ENDIF.
      ENDIF.

  ENDCASE.

** To avoid standard f4-help.
  ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.

ENDFORM.                                                    " ON_F4
*&---------------------------------------------------------------------*
*&      Form  CHECK_FCM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_FCM .

  CLEAR : GT_MAIN-NAME1.

  CHECK GT_MAIN-FCM IS NOT INITIAL.

  SELECT SINGLE B~NAME1
    INTO GT_MAIN-NAME1
    FROM ZNFT0021 AS A
   INNER JOIN LFA1 AS B
      ON A~LIFNR = B~LIFNR
   WHERE A~BUKRS = GT_MAIN-BUKRS
     AND A~LIFNR = GT_MAIN-FCM
     AND B~LOEVM = ' '.

  IF SY-SUBRC <> 0.
    MESSAGE I003 DISPLAY LIKE 'E'
       WITH 'FCM' GT_MAIN-FCM
            '이(가) 존재하지 않습니다.'.

    CLEAR : GT_MAIN-FCM.

    EXIT.
  ENDIF.

  IF GT_MAIN-NCIND = 'C'.
*___청산인 경우 신규선물집행의 FCM과 비교
    PERFORM CHECK_NEW_FUTURES_FCM.
  ENDIF.

ENDFORM.                    " CHECK_FCM
*&---------------------------------------------------------------------*
*&      Form  SAVE_FUTURES_TRADE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_FUTURES_TRADE  USING PV_FLAG.
  DATA: LV_TITLE(50),
        LV_TEXT      TYPE STRING,
        LV_CNT       TYPE I,
        LV_FCMCNT(5).

  CALL METHOD GC_ALV_GRID->CHECK_CHANGED_DATA.

  PERFORM CHECK_SELECTED_ROWS USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  CASE PV_FLAG.
    WHEN 'S'.
      LV_TITLE = '저장'.
      LV_TEXT  = '선물집행 정보를 저장 하시겠습니까?'.
    WHEN 'R'.
      LV_TITLE = '결재요청'.
      LV_TEXT  = '선물집행 정보를 결재요청 하시겠습니까?'.
  ENDCASE.

  IF PV_FLAG <> 'D'.

    PERFORM CHECK_FUTURES_TRADE USING GV_ERROR.

    CHECK GV_ERROR IS INITIAL.

    PERFORM COMPARE_FCM USING LV_FCMCNT.

    IF LV_FCMCNT IS NOT INITIAL.
      CONCATENATE LV_FCMCNT '건의 청산계약의 FCM이'
                  '신규계약의 FCM과 다릅니다.' LV_TEXT
             INTO LV_TEXT SEPARATED BY SPACE.
    ENDIF.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING LV_TITLE
                                 LV_TEXT
                                 '1'
                                 GV_ANSWER.

  IF GV_ANSWER = '1'.

**___잔량점검
*    LOOP AT GT_MAIN WHERE CHECK = 'X'.
*      PERFORM CHECK_REMAIN_QTY USING GV_ERROR.
*
*      IF GV_ERROR IS NOT INITIAL.
*        EXIT.
*      ENDIF.
*    ENDLOOP.
*

    CHECK GV_ERROR IS INITIAL.

    CLEAR : LV_CNT, GV_ERROR.

    LOOP AT GT_MAIN WHERE CHECK = 'X'.
      CLEAR : ZNFT1020, ZNFT1030, YZNFT1020, YZNFT1030.

      LV_CNT = LV_CNT + 1.

*     선물 - 신규집행
      IF GT_MAIN-NCIND = 'N'.
        SELECT SINGLE *
          INTO YZNFT1020
          FROM ZNFT1020
         WHERE NFUTN = GT_MAIN-NFUTN.

        IF SY-SUBRC = 0.
          ZNFT1020 = YZNFT1020.
        ELSE.
          GV_ERROR = 'X'.
          EXIT.
        ENDIF.

*     선물 - 청산집행
      ELSE.
        SELECT SINGLE *
          INTO YZNFT1030
          FROM ZNFT1030
         WHERE CFUTN = GT_MAIN-NFUTN.

        IF SY-SUBRC = 0.
          ZNFT1030 = YZNFT1030.
        ELSE.
          GV_ERROR = 'X'.
          EXIT.
        ENDIF.
      ENDIF.

      CASE PV_FLAG.

        WHEN 'S'.
          IF GT_MAIN-NCIND = 'N'.
            PERFORM SAVE_ZNFT1020 USING 'S'.
          ELSE.
            PERFORM SAVE_ZNFT1030 USING 'S'.
          ENDIF.

        WHEN 'R'.
          IF GT_MAIN-NCIND = 'N'.
            PERFORM SAVE_ZNFT1020 USING 'R'.
          ELSE.
            PERFORM SAVE_ZNFT1030 USING 'R'.
          ENDIF.

      ENDCASE.

      IF GV_ERROR IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF GV_ERROR IS INITIAL.
      COMMIT WORK.

*--- 간편결재 전송.
      IF PV_FLAG = 'R'.
        LOOP AT GT_MAIN WHERE CHECK = 'X'.
          IF GT_MAIN-NCIND = 'N'.
            PERFORM SEND_SIMPLE_APPROVAL
            USING ZNFT1020-NFUTN
                  ZNFT1020-BUKRS
                  '2F'.
          ELSE.
            PERFORM SEND_SIMPLE_APPROVAL
            USING ZNFT1030-CFUTN
                  ZNFT1030-BUKRS
                  '2F'.
          ENDIF.
        ENDLOOP.
      ENDIF.

      MESSAGE S003 WITH LV_CNT   '건의 선물집행 데이터가'
                        LV_TITLE '되었습니다.'.

      LOOP AT GT_MAIN WHERE CHECK = 'X'.
        CLEAR : GT_MAIN-CHECK.

        IF GT_MAIN-NCIND = 'N'.
          PERFORM ENQUEUE_DEQUEUE_ZNFT1020.
        ELSE.
          PERFORM ENQUEUE_DEQUEUE_ZNFT1030.
        ENDIF.
      ENDLOOP.

      PERFORM GET_FUTURES_DATA.
    ELSE.
      ROLLBACK WORK.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '선물집행 데이터 Update Error!'.
    ENDIF.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " SAVE_FUTURES_TRADE
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_ROWS  USING    PV_ERROR.
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

ENDFORM.                    " CHECK_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  CHECK_FUTURES_TRADE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_FUTURES_TRADE USING PV_ERROR.

  DATA: LV_NETIG LIKE ZNFT1050-NETIG,
        LV_EMENG TYPE ZEMENG_1,
        LV_EMSG1 TYPE CHAR50,
        LV_EMSG2 TYPE CHAR50.

  CLEAR : PV_ERROR.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.

**___신규선물이면서 청산연결되지 않은 데이터의
**___해당요청번호의 항번에 대한 요청수량과 각각의 연결된 계약수량의
**___총합을 비교하여 SUM(계약수량) > 요청수량인 경우 ERROR 메시지 출력
*    IF GT_MAIN-NCIND EQ 'N'.
*      IF GT_MAIN-NFUTN1 IS INITIAL.
*
*        CLEAR: LV_EMENG, LV_EMSG1, LV_EMSG2.
*        SELECT SUM( Z4~EMENG ) INTO LV_EMENG
*          FROM ZNFT1020 AS Z1
*               INNER JOIN ZNFT1011 AS Z2
*                  ON Z2~REQNO EQ Z1~REQNO AND Z2~H_NO1 EQ Z1~H_NO1
*               INNER JOIN ZNFT1000 AS Z3
*                  ON Z3~CONNO EQ Z2~CONNO
*               INNER JOIN ZNFT1001 AS Z4
*                  ON Z4~CONNO EQ Z3~CONNO
*         WHERE Z1~BUKRS EQ P_BUKRS
*           AND Z1~NFUTN EQ GT_MAIN-NFUTN
*         AND ( Z1~YNCAN EQ SPACE AND ( Z1~CONFM NOT IN ('3', '7' ) ) ).
*
*        IF SY-SUBRC EQ 0.
*          IF LV_EMENG GT GT_MAIN-REQTY.
*            CONCATENATE '선물계약-'  GT_MAIN-CONNO
*                        INTO LV_EMSG1.
*            CONCATENATE '선물요청-' GT_MAIN-REQNO '-'
*                        GT_MAIN-H_NO1 '(항번)'
*                        INTO LV_EMSG2.
*            PV_ERROR = 'X'.
*            MESSAGE S003 DISPLAY LIKE 'E'
*               WITH LV_EMSG1 '의 수량이 '
*                    LV_EMSG2 '의 수량을 초과하였습니다'.
*            EXIT.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.

*___변경사유 체크
    IF GT_MAIN-RESON IS INITIAL.
      PV_ERROR = 'X'.
      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '변경사유를 입력하십시오. 선물집행:'
              GT_MAIN-NFUTN.
      EXIT.
    ENDIF.

*___신규선물 삭제시 청산데이터 존재여부 체크
    IF GT_MAIN-NCIND EQ 'N' AND GT_MAIN-YNCAN EQ 'X'.
      IF GT_MAIN-NFUTN1 IS NOT INITIAL.
        CLEAR: LV_EMSG1, LV_EMSG2.
        CONCATENATE '신규선물-' GT_MAIN-NFUTN  INTO LV_EMSG1.
        CONCATENATE '청산선물-' GT_MAIN-NFUTN1 INTO LV_EMSG2.
        PV_ERROR = 'X'.
        MESSAGE I003 DISPLAY LIKE 'E'
           WITH LV_EMSG1 '에 대해' LV_EMSG2 '이 존재합니다'.
        EXIT.
      ENDIF.
    ENDIF.

*___집행일
    IF GT_MAIN-RUDAT IS INITIAL.
      PV_ERROR = 'X'.
      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '집행일이 입력되지 않았습니다. 선물집행:'
              GT_MAIN-NFUTN.
      EXIT.
    ENDIF.

*___FCM
    IF GT_MAIN-FCM IS INITIAL.
      PV_ERROR = 'X'.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH 'FCM이 입력되지 않았습니다. 선물집행:'
              GT_MAIN-NFUTN.
      EXIT.
    ENDIF.

*___만기일
    IF GT_MAIN-ENDAT IS INITIAL.
      PV_ERROR = 'X'.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '만기일이 입력되지 않았습니다. 선물집행:'
              GT_MAIN-NFUTN.
      EXIT.
    ENDIF.

*___신규건(넷팅대상) 만기일/FCM별 정산진행여부 점검
    IF GT_MAIN-NCIND = 'N'.
      SELECT SINGLE *
        FROM ZNFT1030
       WHERE NFUTN = GT_MAIN-NFUTN
         AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) ).

      IF SY-SUBRC <> 0.
        CLEAR : LV_NETIG.

        SELECT SINGLE NETIG
          INTO LV_NETIG
          FROM ZNFT1050
         WHERE BUKRS = P_BUKRS
           AND ENDAT = GT_MAIN-ENDAT
           AND FCM   = GT_MAIN-FCM.

        IF LV_NETIG = 'X'.
          PV_ERROR = 'X'.

          MESSAGE I003 DISPLAY LIKE 'E'
             WITH '만기일/FCM' GT_MAIN-ENDAT GT_MAIN-FCM
                  '에 대한 넷팅이 진행되었습니다.'.

          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.

*___집행유형
    IF GT_MAIN-MITYP IS INITIAL.
      PV_ERROR = 'X'.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '집행유형이 입력되지 않았습니다. 선물집행:'
              GT_MAIN-NFUTN.
      EXIT.
    ENDIF.

*___기준월
    IF GT_MAIN-MITYP = 'A' AND GT_MAIN-MIMON IS INITIAL.
      PV_ERROR = 'X'.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '기준월이 입력되지 않았습니다. 선물집행:'
              GT_MAIN-NFUTN.
      EXIT.
    ENDIF.

*___만기일/기준월
    IF GT_MAIN-MITYP = 'A' AND GT_MAIN-MIMON > GT_MAIN-ENDAT(6).
      PV_ERROR = 'X'.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '만기일은 기준월과 동월이거나'
              '이후여야 합니다. 선물집행:'
              GT_MAIN-NFUTN.
      EXIT.
    ENDIF.

*___집행단가 ( 집행유형:Average 인경우 필수아님 )
    IF GT_MAIN-PRICE IS INITIAL.
      IF GT_MAIN-MITYP NE 'A'.
        PV_ERROR = 'X'.
        MESSAGE I003 DISPLAY LIKE 'E'
           WITH '집행단가가 입력되지 않았습니다. 선물집행:'
                GT_MAIN-NFUTN.
        EXIT.
      ENDIF.
    ENDIF.

*___집행수량
    IF GT_MAIN-EMENG IS INITIAL.
      PV_ERROR = 'X'.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '집행수량이 입력되지 않았습니다. 선물집행:'
              GT_MAIN-NFUTN.
      EXIT.
    ENDIF.

*___수수료여부
    IF GT_MAIN-MISUS IS INITIAL.
      PV_ERROR = 'X'.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '수수료여부가 입력되지 않았습니다. 선물집행:'
              GT_MAIN-NFUTN.
      EXIT.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " CHECK_FUTURES_TRADE
*&---------------------------------------------------------------------*
*&      Form  COMPARE_FCM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM COMPARE_FCM  USING  PV_CNT.
  DATA: LV_FCM      LIKE ZNFT1020-FCM.

  CLEAR : PV_CNT.

  LOOP AT GT_MAIN WHERE CHECK = 'X'
                    AND NCIND = 'C'.
*___청산 - 신규선물집행 정보의 FCM을 찾아 청산의 FCM과 비교
    CLEAR : LV_FCM.

    SELECT SINGLE FCM
      INTO LV_FCM
      FROM ZNFT1020
     WHERE NFUTN = GT_MAIN-NFUTN1.

    IF SY-SUBRC = 0 AND LV_FCM <> GT_MAIN-FCM.
      PV_CNT = PV_CNT + 1.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " COMPARE_FCM
*&---------------------------------------------------------------------*
*&      Form  SAVE_ZNFT1020
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_ZNFT1020  USING  PV_FLAG.

  CASE PV_FLAG.
    WHEN 'S'.
      ZNFT1020-CONFM = '5'.   "생성
    WHEN 'R'.
      ZNFT1020-CONFM = '6'.   "요청
  ENDCASE.

  ZNFT1020-RUDAT = GT_MAIN-RUDAT.  "집행일
  ZNFT1020-FCM   = GT_MAIN-FCM.    "FCM
  ZNFT1020-ENDAT = GT_MAIN-ENDAT.  "만기일
  ZNFT1020-MITYP = GT_MAIN-MITYP.  "집행유형
  ZNFT1020-MISPD = GT_MAIN-MISPD.  "Spread
  ZNFT1020-MIMON = GT_MAIN-MIMON.  "기준월
  ZNFT1020-PRICE = GT_MAIN-PRICE.  "집행단가
  ZNFT1020-EMENG = GT_MAIN-EMENG.  "집행수량
  ZNFT1020-MISUS = GT_MAIN-MISUS.  "수수료여부
  ZNFT1020-YNCAN = GT_MAIN-YNCAN.  "삭제여부
  ZNFT1020-RESON = GT_MAIN-RESON.  "변경사유
  ZNFT1020-BIGO4 = GT_MAIN-BIGO4.  "비고
  ZNFT1020-AEDAT = SY-DATLO.
  ZNFT1020-AEZET = SY-TIMLO.
  ZNFT1020-AENAM = SY-UNAME.

  IF PV_FLAG = 'D'.
    DELETE FROM ZNFT1020 WHERE NFUTN = ZNFT1020-NFUTN.
    IF SY-SUBRC = 0.
      PERFORM SAVE_ZNFT1020_CHANGE_DOC USING 'D'.
    ELSE.
      GV_ERROR = 'X'.
    ENDIF.
  ELSE.
    MODIFY ZNFT1020 FROM ZNFT1020.
    IF SY-SUBRC = 0.
      PERFORM SAVE_ZNFT1020_CHANGE_DOC USING 'U'.
    ELSE.
      GV_ERROR = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    " SAVE_ZNFT1020
*&---------------------------------------------------------------------*
*&      Form  SAVE_ZNFT1030
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_ZNFT1030  USING  PV_FLAG.

  CASE PV_FLAG.
    WHEN 'S'.
      ZNFT1030-CONFM = '5'.   "생성
    WHEN 'R'.
      ZNFT1030-CONFM = '6'.   "요청
  ENDCASE.

  ZNFT1030-RUDAT = GT_MAIN-RUDAT.  "집행일
  ZNFT1030-FCM   = GT_MAIN-FCM.    "FCM
  ZNFT1030-ENDAT = GT_MAIN-ENDAT.  "만기일
  ZNFT1030-MITYP = GT_MAIN-MITYP.  "집행유형
  ZNFT1030-MISPD = GT_MAIN-MISPD.  "Spread
  ZNFT1030-MIMON = GT_MAIN-MIMON.  "기준월
  ZNFT1030-PRICE = GT_MAIN-PRICE.  "집행단가
*  ZNFT1030-EMENG = GT_MAIN-EMENG.  "집행수량
  ZNFT1030-MISUS = GT_MAIN-MISUS.  "수수료여부
  ZNFT1030-YNCAN = GT_MAIN-YNCAN.  "삭제여부
  ZNFT1030-RESON = GT_MAIN-RESON.  "변경사유
  ZNFT1030-BIGO4 = GT_MAIN-BIGO4.  "비고
  ZNFT1030-AEDAT = SY-DATLO.
  ZNFT1030-AEZET = SY-TIMLO.
  ZNFT1030-AENAM = SY-UNAME.

  IF PV_FLAG = 'D'.
    DELETE FROM ZNFT1030 WHERE CFUTN = ZNFT1030-CFUTN.
    IF SY-SUBRC = 0.
      PERFORM SAVE_ZNFT1030_CHANGE_DOC USING 'D'.
    ELSE.
      GV_ERROR = 'X'.
    ENDIF.
  ELSE.
    MODIFY ZNFT1030 FROM ZNFT1030.
    IF SY-SUBRC = 0.
      PERFORM SAVE_ZNFT1030_CHANGE_DOC USING 'U'.
    ELSE.
      GV_ERROR = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    " SAVE_ZNFT1030
*&---------------------------------------------------------------------*
*&      Form  SAVE_ZNFT1020_CHANGE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_ZNFT1020_CHANGE_DOC USING PV_FLAG.
  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND,
        LV_UPD_ICDTXT      TYPE CHAR1.

  LV_CDOC_UPD_OBJECT = PV_FLAG.
  LV_OBJECTID        = GT_MAIN-NFUTN.
  LV_TCODE           = SY-TCODE.

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

ENDFORM.                    " SAVE_ZNFT1020_CHANGE_DOC
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
*&      Form  CHECK_REMAIN_QTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_REMAIN_QTY USING PV_ERROR.
  DATA: LV_REQTY     LIKE ZNFT1011-EMENG,
        LV_EMENG1    LIKE ZNFT1020-EMENG,
        LV_EMENG2    LIKE ZNFT1020-EMENG,
        LV_TEXT1(50),
        LV_TEXT2(50),
        LV_TEXT3(50).

  RANGES: LR_NFUTN  FOR ZNFT1020-NFUTN.

  CHECK GT_MAIN-NCIND = 'N'.

  CLEAR   : LR_NFUTN, LV_REQTY, LV_EMENG1, LV_EMENG2, PV_ERROR.
  REFRESH : LR_NFUTN.

*___선물요청수량
  SELECT SINGLE EMENG
    INTO LV_REQTY
    FROM ZNFT1011
   WHERE REQNO = GT_MAIN-REQNO
     AND H_NO1 = GT_MAIN-H_NO1.

*___현재 화면에서 작업중인 신규선물집행 수량
  LOOP AT GT_MAIN INTO GS_MAIN WHERE CHECK = 'X'
                                 AND NCIND = 'N'
                                 AND REQNO = GT_MAIN-REQNO
                                 AND H_NO1 = GT_MAIN-H_NO1.
    LR_NFUTN-SIGN   = 'E'.
    LR_NFUTN-OPTION = 'EQ'.
    LR_NFUTN-LOW    = GS_MAIN-NFUTN.
    APPEND LR_NFUTN.

    CHECK GS_MAIN-NFUTN <> GT_MAIN-NFUTN.

    LV_EMENG1 = LV_EMENG1 + GS_MAIN-EMENG.
  ENDLOOP.

*___현재 작업대상이 아닌 신규선물집행 수량
  SELECT SUM( EMENG )
    INTO LV_EMENG2
    FROM ZNFT1020
   WHERE NFUTN IN LR_NFUTN
     AND REQNO =  GT_MAIN-REQNO
     AND H_NO1 =  GT_MAIN-H_NO1
     AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) ).

  LV_REQTY = LV_REQTY - LV_EMENG1 - LV_EMENG2.

  IF GT_MAIN-EMENG > LV_REQTY.
    PV_ERROR = 'X'.

    CLEAR : GT_MAIN-EMENG.

    WRITE: LV_REQTY TO LV_TEXT3 UNIT GT_MAIN-MEINS LEFT-JUSTIFIED.

    CONCATENATE '선물계약' GT_MAIN-NFUTN '의 수량이 선물요청'
           INTO LV_TEXT1 SEPARATED BY SPACE.
    CONCATENATE GT_MAIN-REQNO '-' GT_MAIN-H_NO1
                '의 수량을 초과하였습니다.'
           INTO LV_TEXT2 SEPARATED BY SPACE.
    CONCATENATE '잔량 :' LV_TEXT3 GT_MAIN-MEINS
           INTO LV_TEXT3 SEPARATED BY SPACE.

    MESSAGE I003 DISPLAY LIKE 'E'
       WITH LV_TEXT1 LV_TEXT2 LV_TEXT3.
  ENDIF.

ENDFORM.                    " CHECK_REMAIN_QTY
*&---------------------------------------------------------------------*
*&      Form  CHECK_NEW_FUTURES_FCM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_NEW_FUTURES_FCM .
  DATA: LV_FCM      LIKE ZNFT1020-FCM.

  CLEAR : LV_FCM.

  SELECT SINGLE FCM
    INTO LV_FCM
    FROM ZNFT1020
   WHERE NFUTN = GT_MAIN-NFUTN1.

  IF SY-SUBRC = 0 AND LV_FCM <> GT_MAIN-FCM.
    MESSAGE I003 WITH '입력된 FCM이 신규선물집행의 FCM(' LV_FCM
                      ')과 다릅니다.'.
  ENDIF.

ENDFORM.                    " CHECK_NEW_FUTURES_FCM

*&---------------------------------------------------------------------*
*&      Form  CALL_NFUTN_PGM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_OUTTAB_D_NFUTN  text
*----------------------------------------------------------------------*
FORM CALL_NFUTN_PGM  USING    PV_NFUTN.

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

ENDFORM.                    " CALL_NFUTN_PGM

*&---------------------------------------------------------------------*
*&      Form  CALL_CFUTN_PGM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_OUTTAB_D_CFUTN  text
*----------------------------------------------------------------------*
FORM CALL_CFUTN_PGM  USING    PV_CFUTN.

  DATA: LT_RSPAR LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

  CLEAR   : LT_RSPAR.
  REFRESH : LT_RSPAR.

  APPEND_PARAM : LT_RSPAR 'P_BUKRS' 'P' ' ' ' '  P_BUKRS       ' ',
                 LT_RSPAR 'S_CFUTN' 'S' 'I' 'EQ' PV_CFUTN      ' ',
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

ENDFORM.                    " CALL_CFUTN_PGM
*&---------------------------------------------------------------------*
*& Form SEND_SIMPLE_APPROVAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ZNFT1020_NFUTN
*&      --> ZNFT1020_BUKRS
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
