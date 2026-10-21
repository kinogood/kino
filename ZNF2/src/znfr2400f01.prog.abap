*----------------------------------------------------------------------*
***INCLUDE ZNFR2400F01 .
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

  IF SY-DATLO+4(2) = '01'.
    P_ENDMM(4)   = SY-DATLO(4) - 1.
    P_ENDMM+4(2) = '12'.
  ELSE.
    P_ENDMM = SY-DATLO(6) - 1.
  ENDIF.

  IF SY-TCODE = GC_TCODE2.
    GV_TRTYP = 'A'.
    GV_TITLE = '확정 취소'.
  ELSE.
    GV_TRTYP = 'V'.
    GV_TITLE = '확정'.
  ENDIF.

  SET TITLEBAR '100' WITH GV_TITLE.

ENDFORM.                    " SET_DEFAULT_PARAMETER
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
*&      Form  CHECK_ENDMM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_ENDMM .

  IF P_ENDMM IS NOT INITIAL AND
     ( P_ENDMM+4(2) < '01' OR P_ENDMM+4(2) > '12' ).
    MESSAGE E003 WITH '만기월을 점검하십시오.'.
  ENDIF.

ENDFORM.                    " CHECK_ENDMM
*&---------------------------------------------------------------------*
*&      Form  GET_SETTLEMENT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_SETTLEMENT_DATA .

  CLEAR   : GT_MAIN, GT_1020, GT_1030.
  REFRESH : GT_MAIN, GT_1020, GT_1030.

*___만기일 From ~ To
  GV_FRDAT(6)   = P_ENDMM.
  GV_FRDAT+6(2) = '01'.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = GV_FRDAT
    IMPORTING
      LAST_DAY_OF_MONTH = GV_TODAT
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.

*___신규선물집행
  SELECT *
    INTO TABLE GT_1020
    FROM ZNFT1020
   WHERE BUKRS = P_BUKRS
     AND ENDAT BETWEEN GV_FRDAT AND GV_TODAT
     AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) ).

*___청산선물집행
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_1030
    FROM ZNFT1030
   WHERE BUKRS = P_BUKRS
     AND ENDAT BETWEEN GV_FRDAT AND GV_TODAT
     AND YNNET   = ' '
     AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) ).

*___신규선물집행 데이터 집계
  LOOP AT GT_1020.
    CLEAR : GT_MAIN.

    GT_MAIN-BUKRS = GT_1020-BUKRS.     "회사코드
    GT_MAIN-ENDAT = GT_1020-ENDAT.     "만기일
    GT_MAIN-FCM   = GT_1020-FCM.       "FCM
    GT_MAIN-MEINS = GT_1020-MEINS.     "단위

    IF GT_1020-BY_SL = 'B'.
      GT_MAIN-NFBUY = 1.               "신규 Buy 건수
      GT_MAIN-NBMNG = GT_1020-EMENG.   "신규 Buy 수량
    ELSE.
      GT_MAIN-NFSEL = 1.               "신규 Sell 건수
      GT_MAIN-NSMNG = GT_1020-EMENG.   "신규 Sell 수량
    ENDIF.

    COLLECT GT_MAIN.
  ENDLOOP.

*___청산선물집행 데이터 집계
  LOOP AT GT_1030.
    CLEAR : GT_MAIN.

    GT_MAIN-BUKRS = GT_1030-BUKRS.     "회사코드
    GT_MAIN-ENDAT = GT_1030-ENDAT.     "만기일
    GT_MAIN-FCM   = GT_1030-FCM.       "FCM
    GT_MAIN-MEINS = GT_1030-MEINS.     "단위

    IF GT_1030-BY_SL = 'B'.
      GT_MAIN-CFBUY = 1.               "청산 Buy 건수
      GT_MAIN-CBMNG = GT_1030-EMENG.   "청산 Buy 수량
    ELSE.
      GT_MAIN-CFSEL = 1.               "청산 Sell 건수
      GT_MAIN-CSMNG = GT_1030-EMENG.   "청산 Sell 수량
    ENDIF.

    COLLECT GT_MAIN.
  ENDLOOP.

*___정산진행상태
  PERFORM GET_PROCESSING_STATUS.

  SORT GT_MAIN BY ENDAT FCM.

ENDFORM.                    " GET_SETTLEMENT_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_ICON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_ICON  USING    PV_STAT
                        PV_ICON.

  CLEAR : PV_ICON.

  IF PV_STAT = 'X'.
    PV_ICON = '@5B@'.
  ELSE.
    PV_ICON = '@5C@'.
  ENDIF.

ENDFORM.                    " SET_ICON
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

  IF LV_CNT < 1.
    GV_ERROR = 'X'.

    MESSAGE S001 DISPLAY LIKE 'E'
       WITH '선택된 라인이 없습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_ROWS
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
*  IF SY-DYNNR <> '0100'.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
*  ENDIF.
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
FORM SET_GRID_FCAT_1.

  CLEAR   : GS_FIELDCAT, GV_POS.
  REFRESH : GT_FIELDCAT.

  GV_ITAB = 'GT_MAIN'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT
                                  USING :
      'BUKRS'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      ' '              'BUKRS' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '              'ENDAT' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'FCM'      ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '              'FCM'   'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'NAME1'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 35
      'FCM 명'         ' '     ' '        ' ' ' '    'X' ' ' ' ' ' ',

      'NFBUY'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 8
      '신규 Buy 건수'  ' '     ' '        ' ' 'INT4' ' ' ' ' ' ' ' ',

      'NFSEL'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 8
      '신규 Sell 건수' ' '     ' '        ' ' 'INT4' ' ' ' ' ' ' ' ',

      'CFBUY'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 8
      '청산 Buy 건수'  ' '     ' '        ' ' 'INT4' ' ' ' ' ' ' ' ',

      'CFSEL'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 8
      '청산 Sell 건수' ' '     ' '        ' ' 'INT4' ' ' ' ' ' ' ' ',

      'NBMNG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '신규 Buy 수량'  'EMENG' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'NSMNG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '신규 Sell 수량' 'EMENG' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'CBMNG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '청산 Buy 수량'  'EMENG' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'CSMNG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '청산 Sell 수량' 'EMENG' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      ' '              'MEINS' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'NCCHK'    ' '      ' '     'X' ' ' 'C' ' '    ' ' ' ' ' ' 8
      '오류확인'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'NETIG'    ' '      ' '     'X' ' ' 'C' ' '    ' ' ' ' ' ' 8
      '넷팅생성'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'CONFM'    ' '      ' '     'X' ' ' 'C' ' '    ' ' ' ' ' ' 8
      '손익확정'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'TRWON'    ' '      ' '     'X' ' ' 'C' ' '    ' ' ' ' ' ' 8
      '원화환산'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'CREFI'    ' '      ' '     'X' ' ' 'C' ' '    ' ' ' ' ' ' 8
      '전표생성'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' '.

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

  GV_ITAB = 'GT_DETL'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT
                                  USING :
      'ICON'     ' '      ' '     'X' ' ' ' ' ' '    'X' ' ' ' ' 4
      '상태'           ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'BUKRS'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      ' '              'BUKRS' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'MESSAGE'  ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 200
      '메시지'         ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'CONNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'CONNO' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'COTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '              'COTXT' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'COTYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      ' '              'COTYP' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'COTPT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '계약유형'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'CSTAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      ' '              'CSTAT' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'CSTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '계약상태'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'KUNNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'KUNNR' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'NAMAG'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      '고객명'         'NAME1' 'KNA1'     ' ' ' '    'X' ' ' ' ' ' ',

      'REQNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'REQNO' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'H_NO1'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 3
      ' '              'H_NO1' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'NFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '신규집행번호'   'NFUTN' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      '신규비철구분'   'NFKEY' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'RUDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '신규집행일'     'RUDAT' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'FCM'      ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '신규 FCM'       'FCM'   'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'NAMLF'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      '신규 FCM 명'    'NAME1' 'LFA1'     ' ' ' '    'X' ' ' ' ' ' ',

      'BY_SL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      '신규 Buy/Sell'  'BY_SL' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'BSTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '신규 Buy/Sell'  ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '신규만기일'     'ENDAT' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'MITYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '신규집행유형'   'MITYP' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'MITPT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '신규집행유형내역' ' '   ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'MISPD'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '신규 Spread'    'MISPD' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'MIMON'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      '신규매입기준월' 'MIMON' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'PRICE'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '신규집행단가'   'PRICE' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'WAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      '신규집행통화'   'WAERS' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '신규집행수량'   'EMENG' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      '신규집행단위'   'MEINS' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'MISUS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '신규수수료'     'MISUS' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'CONFM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '신규결재상태'   'CONFM' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'CFMTX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '신규결재상태내역' ' '   ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'YNCAN'    ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 1
      '신규취소여부'   'YNCAN' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'YNFIN'    ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 1
      '신규정산여부'   'YNFIN' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'CFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '청산집행번호'   'CFUTN' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

      'NFKEY1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      '청산비철구분'   'NFKEY' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

      'RUDAT1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '청산집행일'     'RUDAT' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

      'FCM1'     ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '청산 FCM'       'FCM'   'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

      'NAMLF1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      '청산 FCM 명'    'NAME1' 'LFA1'     ' ' ' '    'X' ' ' ' ' ' ',

      'BY_SL1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      '청산 Buy/Sell'  'BY_SL' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

      'BSTXT1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '청산 Buy/Sell'  ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ENDAT1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '청산만기일'     'ENDAT' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

      'MITYP1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '청산집행유형'   'MITYP' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

      'MITPT1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '청산집행유형내역' ' '   ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'MISPD1'   'WAERS1' ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '청산 Spread'    'MIPSD' 'ZNFT1030' ' ' ' '    ' ' ' ' ' ' ' ',

      'MIMON1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      '청산매입기준월' 'MIMON' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

      'PRICE1'   'WAERS1' ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '청산집행단가'   'PRICE' 'ZNFT1030' ' ' ' '    ' ' ' ' ' ' ' ',

      'WAERS1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      '청산집행통화'   'WAERS' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG1'   ' '     'MEINS1' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '청산집행수량'   'EMENG' 'ZNFT1030' ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      '청산집행단위'   'MEINS' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

      'MISUS1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '청산수수료'     'MISUS' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

      'CONFM1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '청산결재상태'   'CONFM' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

      'CFMTX1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '청산결재상태내역' ' '   ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'YNCAN1'   ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 1
      '청산취소여부'   'YNCAN' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

      'YNFIN1'   ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 1
      '청산정산여부'   'YNFIN' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' '.

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

  IF PV_FNAME = 'CONNO'.
    GS_FIELDCAT-F4AVAILABL   = 'X'.
  ENDIF.

  IF PV_FNAME = 'NFBUY' OR PV_FNAME = 'NFSEL' OR
     PV_FNAME = 'NBMNG' OR PV_FNAME = 'NSMNG'.
    GS_FIELDCAT-STYLE = '00000004'.
  ENDIF.

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

  SET HANDLER GC_EVENT_HANDLER2->HANDLE_DOUBLE_CLICK  FOR GC_ALV_GRID2.

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
      IT_OUTTAB            = GT_DETL[].

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY_2
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

  CALL METHOD GC_ALV_GRID1->GET_SELECTED_COLUMNS
    IMPORTING
      ET_INDEX_COLUMNS = GT_COLS.

ENDFORM.                    " GET_SELECTED_ROWS_1
*&---------------------------------------------------------------------*
*&      Form  SET_SELECTED_ROWS_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SELECTED_ROWS_1 .

  REFRESH : GT_ROWS.

  LOOP AT GT_MAIN.
    IF GT_MAIN-CHECK = 'X'.
      CLEAR : GS_ROWS.
      GS_ROWS-INDEX = SY-TABIX.
      APPEND GS_ROWS TO GT_ROWS.
    ENDIF.
  ENDLOOP.

  IF GT_ROWS[] IS NOT INITIAL.
    CALL METHOD GC_ALV_GRID1->SET_SELECTED_ROWS
      EXPORTING
        IT_INDEX_ROWS = GT_ROWS.
  ENDIF.

  IF GT_COLS[] IS NOT INITIAL.
    CALL METHOD GC_ALV_GRID1->SET_SELECTED_COLUMNS
      EXPORTING
        IT_COL_TABLE = GT_COLS.
  ENDIF.

ENDFORM.                    " SET_SELECTED_ROWS_1
*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_ALL .

  IF OK_SAVE = 'ASEL'.
    GT_MAIN-CHECK = 'X'.
  ELSE.
    CLEAR : GT_MAIN-CHECK.
  ENDIF.

  MODIFY GT_MAIN TRANSPORTING CHECK
                 WHERE BUKRS IS NOT INITIAL.

ENDFORM.                    " SELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_DATA .

  PERFORM CHECK_SELECTED_ROWS.

  CHECK GV_ERROR IS INITIAL.

*___정산진행상태 최신표시
  PERFORM GET_PROCESSING_STATUS.

  PERFORM CHECK_PROCESSING_STATUS.

  CHECK GV_ERROR IS INITIAL.

  PERFORM GET_DETAIL_DATA.

  IF GT_DETL[] IS NOT INITIAL.
    CALL SCREEN 0200.
  ELSE.
*___정산대상 확정 데이터가 없는 경우
    PERFORM SETTLEMENT_CONFIRM USING ' '.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_DATA
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_SELECTED_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_SELECTED_DATA .

  PERFORM CHECK_SELECTED_ROWS.

  CHECK GV_ERROR IS INITIAL.

*___정산진행상태 최신표시
  PERFORM GET_PROCESSING_STATUS.

  PERFORM CHECK_PROCESSING_STATUS.

  CHECK GV_ERROR IS INITIAL.

  PERFORM GET_DETAIL_DATA.

  IF GT_DETL[] IS NOT INITIAL.
    CALL SCREEN 0200.
  ELSE.
*___정산대상 확정 데이터가 없는 경우
    PERFORM SETTLEMENT_CONFIRM USING 'C'.
  ENDIF.

ENDFORM.                    " DISPLAY_SELECTED_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_DETAIL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DETAIL_DATA.
  DATA: LS_1002     LIKE ZNFT1002.

  CLEAR   : GT_DETL.
  REFRESH : GT_DETL.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
*___신규선물집행 정보
    LOOP AT GT_1020 WHERE BUKRS = GT_MAIN-BUKRS
                      AND ENDAT = GT_MAIN-ENDAT
                      AND FCM   = GT_MAIN-FCM.
      CLEAR : GT_DETL, GT_1030.

      MOVE-CORRESPONDING GT_1020 TO GT_DETL.

      READ TABLE GT_1030 WITH KEY NFUTN = GT_1020-NFUTN.
      IF SY-SUBRC = 0.
        GT_DETL-CFUTN  = GT_1030-CFUTN.     "청산 선물집행번호
        GT_DETL-NFKEY1 = GT_1030-NFKEY.     "청산 비철구분
        GT_DETL-RUDAT1 = GT_1030-RUDAT.     "청산 집행일
        GT_DETL-FCM1   = GT_1030-FCM.       "청산 FCM
        GT_DETL-BY_SL1 = GT_1030-BY_SL.     "청산 Buy/Sell
        GT_DETL-ENDAT1 = GT_1030-ENDAT.     "청산 만기일
        GT_DETL-MITYP1 = GT_1030-MITYP.     "청산 집행유형
        GT_DETL-MISPD1 = GT_1030-MISPD.     "청산 Spread
        GT_DETL-MIMON1 = GT_1030-MIMON.     "청산 매입기준월
        GT_DETL-PRICE1 = GT_1030-PRICE.     "청산 집행단가
        GT_DETL-WAERS1 = GT_1030-WAERS.     "청산 통화
        GT_DETL-EMENG1 = GT_1030-EMENG.     "청산 집행수량
        GT_DETL-MEINS1 = GT_1030-MEINS.     "청산 단위
        GT_DETL-MISUS1 = GT_1030-MISUS.     "청산 수수료여부
        GT_DETL-CONFM1 = GT_1030-CONFM.     "청산 결재상태
        GT_DETL-YNCAN1 = GT_1030-YNCAN.     "청산 취소여부
        GT_DETL-YNFIN1 = GT_1030-YNFIN.     "청산 마감여부

        GT_1030-CHECK = 'X'.
        MODIFY GT_1030 INDEX SY-TABIX.
      ELSE.
*___청산건이 만기일에 들어오지 않는 신규건
        CLEAR : ZNFT1030.

        SELECT SINGLE *
          FROM ZNFT1030
         WHERE NFUTN = GT_1020-NFUTN
           AND YNNET   = ' '
           AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) ).

        IF SY-SUBRC = 0.
          GT_DETL-CFUTN  = ZNFT1030-CFUTN.     "청산 선물집행번호
          GT_DETL-NFKEY1 = ZNFT1030-NFKEY.     "청산 비철구분
          GT_DETL-RUDAT1 = ZNFT1030-RUDAT.     "청산 집행일
          GT_DETL-FCM1   = ZNFT1030-FCM.       "청산 FCM
          GT_DETL-BY_SL1 = ZNFT1030-BY_SL.     "청산 Buy/Sell
          GT_DETL-ENDAT1 = ZNFT1030-ENDAT.     "청산 만기일
          GT_DETL-MITYP1 = ZNFT1030-MITYP.     "청산 집행유형
          GT_DETL-MISPD1 = ZNFT1030-MISPD.     "청산 Spread
          GT_DETL-MIMON1 = ZNFT1030-MIMON.     "청산 매입기준월
          GT_DETL-PRICE1 = ZNFT1030-PRICE.     "청산 집행단가
          GT_DETL-WAERS1 = ZNFT1030-WAERS.     "청산 통화
          GT_DETL-EMENG1 = ZNFT1030-EMENG.     "청산 집행수량
          GT_DETL-MEINS1 = ZNFT1030-MEINS.     "청산 단위
          GT_DETL-MISUS1 = ZNFT1030-MISUS.     "청산 수수료여부
          GT_DETL-CONFM1 = ZNFT1030-CONFM.     "청산 결재상태
          GT_DETL-YNCAN1 = ZNFT1030-YNCAN.     "청산 취소여부
          GT_DETL-YNFIN1 = ZNFT1030-YNFIN.     "청산 마감여부
        ELSE.
*___Netting 대상
          CONTINUE.
        ENDIF.
      ENDIF.

*___계약정보
      SELECT SINGLE A~CONNO
                    A~COTXT
                    A~COTYP
                    A~CSTAT
                    A~KUNNR
        INTO (GT_DETL-CONNO, GT_DETL-COTXT,
              GT_DETL-COTYP, GT_DETL-CSTAT,
              GT_DETL-KUNNR)
        FROM ZNFT1000 AS A
       INNER JOIN ZNFT1011 AS B
          ON A~CONNO = B~CONNO
       WHERE B~REQNO = GT_DETL-REQNO
         AND B~H_NO1 = GT_DETL-H_NO1.

      IF GT_DETL-CONNO IS NOT INITIAL.
*___계약-비철구분
        SELECT SINGLE NFKEY
          INTO GT_DETL-NFKEY2
          FROM ZNFT1001
         WHERE CONNO = GT_DETL-CONNO
           AND NFKEY = GT_DETL-NFKEY.

*___계약-파일첨부여부
        CLEAR : LS_1002.

        SELECT SINGLE *
          INTO LS_1002
          FROM ZNFT1002
         WHERE CONNO = GT_DETL-CONNO.

        IF SY-SUBRC = 0 AND
          ( ( LS_1002-FILE1 IS NOT INITIAL AND
              LS_1002-LINK1 IS NOT INITIAL ) OR
            ( LS_1002-FILE2 IS NOT INITIAL AND
              LS_1002-LINK2 IS NOT INITIAL ) OR
            ( LS_1002-FILE3 IS NOT INITIAL AND
              LS_1002-LINK3 IS NOT INITIAL ) OR
            ( LS_1002-FILE4 IS NOT INITIAL AND
              LS_1002-LINK4 IS NOT INITIAL ) OR
            ( LS_1002-FILE5 IS NOT INITIAL AND
              LS_1002-LINK5 IS NOT INITIAL ) OR
            ( LS_1002-FILE6 IS NOT INITIAL AND
              LS_1002-LINK6 IS NOT INITIAL ) OR
            ( LS_1002-FILE7 IS NOT INITIAL AND
              LS_1002-LINK7 IS NOT INITIAL ) OR
            ( LS_1002-FILE8 IS NOT INITIAL AND
              LS_1002-LINK8 IS NOT INITIAL ) OR
            ( LS_1002-FILE9 IS NOT INITIAL AND
              LS_1002-LINK9 IS NOT INITIAL ) OR
            ( LS_1002-FILE10 IS NOT INITIAL AND
              LS_1002-LINK10 IS NOT INITIAL ) ).
          GT_DETL-FILE = 'X'.
        ENDIF.
      ENDIF.

*___Buy/Sell 내역
      PERFORM DOMAIN_VALUE_GET USING : 'ZBY_SL'
                                       GT_DETL-BY_SL
                                       GT_DETL-BSTXT,

                                       'ZBY_SL'
                                       GT_DETL-BY_SL1
                                       GT_DETL-BSTXT1.

*___고객명
      PERFORM GET_KUNNR_DESC USING GT_DETL-KUNNR
                                   GT_DETL-NAMAG.


*___FCM명
      PERFORM GET_LIFNR_DESC USING: GT_DETL-FCM  GT_DETL-NAMLF,
                                    GT_DETL-FCM1 GT_DETL-NAMLF1.

*___계약유형/계약상태/집행유형/결재상태 내역
      PERFORM DOMAIN_VALUE_GET USING: 'ZCOTYP'
                                      GT_DETL-COTYP
                                      GT_DETL-COTPT,

                                      'ZCSTAT'
                                      GT_DETL-CSTAT
                                      GT_DETL-CSTXT,

                                      'ZMITYP_1'
                                      GT_DETL-MITYP
                                      GT_DETL-MITPT,

                                      'ZMITYP_1'
                                      GT_DETL-MITYP1
                                      GT_DETL-MITPT1,

                                      'ZCONFM3'
                                      GT_DETL-CONFM
                                      GT_DETL-CFMTX,

                                      'ZCONFM3'
                                      GT_DETL-CONFM1
                                      GT_DETL-CFMTX1.

      APPEND GT_DETL.
    ENDLOOP.

*___신규건이 만기일 기간에 들어오지 않는 청산건
    LOOP AT GT_1030 WHERE BUKRS = GT_MAIN-BUKRS
                      AND ENDAT = GT_MAIN-ENDAT
                      AND FCM   = GT_MAIN-FCM
                      AND CHECK = ' '.
      CLEAR : GT_DETL, ZNFT1020.

      SELECT SINGLE *
        FROM ZNFT1020
       WHERE NFUTN = GT_1030-NFUTN.

      IF SY-SUBRC = 0.
        MOVE-CORRESPONDING ZNFT1020 TO GT_DETL.
      ENDIF.

      GT_DETL-CFUTN  = GT_1030-CFUTN.     "청산 선물집행번호
      GT_DETL-NFKEY1 = GT_1030-NFKEY.     "청산 비철구분
      GT_DETL-RUDAT1 = GT_1030-RUDAT.     "청산 집행일
      GT_DETL-FCM1   = GT_1030-FCM.       "청산 FCM
      GT_DETL-BY_SL1 = GT_1030-BY_SL.     "청산 Buy/Sell
      GT_DETL-ENDAT1 = GT_1030-ENDAT.     "청산 만기일
      GT_DETL-MITYP1 = GT_1030-MITYP.     "청산 집행유형
      GT_DETL-MISPD1 = GT_1030-MISPD.     "청산 Spread
      GT_DETL-MIMON1 = GT_1030-MIMON.     "청산 매입기준월
      GT_DETL-PRICE1 = GT_1030-PRICE.     "청산 집행단가
      GT_DETL-WAERS1 = GT_1030-WAERS.     "청산 통화
      GT_DETL-EMENG1 = GT_1030-EMENG.     "청산 집행수량
      GT_DETL-MEINS1 = GT_1030-MEINS.     "청산 단위
      GT_DETL-MISUS1 = GT_1030-MISUS.     "청산 수수료여부
      GT_DETL-CONFM1 = GT_1030-CONFM.     "청산 결재상태
      GT_DETL-YNCAN1 = GT_1030-YNCAN.     "청산 취소여부
      GT_DETL-YNFIN1 = GT_1030-YNFIN.     "청산 마감여부

*___계약정보
      SELECT SINGLE A~CONNO
                    A~COTXT
                    A~COTYP
                    A~CSTAT
                    A~KUNNR
        INTO (GT_DETL-CONNO, GT_DETL-COTXT,
              GT_DETL-COTYP, GT_DETL-CSTAT,
              GT_DETL-KUNNR)
        FROM ZNFT1000 AS A
       INNER JOIN ZNFT1011 AS B
          ON A~CONNO = B~CONNO
       WHERE B~REQNO = GT_DETL-REQNO
         AND B~H_NO1 = GT_DETL-H_NO1.

*___계약-비철구분
      IF GT_DETL-CONNO IS NOT INITIAL.
        SELECT SINGLE NFKEY
          INTO GT_DETL-NFKEY2
          FROM ZNFT1001
         WHERE CONNO = GT_DETL-CONNO
           AND NFKEY = GT_DETL-NFKEY.

*___계약-파일첨부여부
        CLEAR : LS_1002.

        SELECT SINGLE *
          INTO LS_1002
          FROM ZNFT1002
         WHERE CONNO = GT_DETL-CONNO.

        IF SY-SUBRC = 0 AND
          ( ( LS_1002-FILE1 IS NOT INITIAL AND
              LS_1002-LINK1 IS NOT INITIAL ) OR
            ( LS_1002-FILE2 IS NOT INITIAL AND
              LS_1002-LINK2 IS NOT INITIAL ) OR
            ( LS_1002-FILE3 IS NOT INITIAL AND
              LS_1002-LINK3 IS NOT INITIAL ) OR
            ( LS_1002-FILE4 IS NOT INITIAL AND
              LS_1002-LINK4 IS NOT INITIAL ) OR
            ( LS_1002-FILE5 IS NOT INITIAL AND
              LS_1002-LINK5 IS NOT INITIAL ) OR
*--> FILE6~10 추가. 2024.07.04 - ZLSGMM3
            ( LS_1002-FILE6 IS NOT INITIAL AND
              LS_1002-LINK6 IS NOT INITIAL ) OR
            ( LS_1002-FILE7 IS NOT INITIAL AND
              LS_1002-LINK7 IS NOT INITIAL ) OR
            ( LS_1002-FILE8 IS NOT INITIAL AND
              LS_1002-LINK8 IS NOT INITIAL ) OR
            ( LS_1002-FILE9 IS NOT INITIAL AND
              LS_1002-LINK9 IS NOT INITIAL ) OR
            ( LS_1002-FILE10 IS NOT INITIAL AND
              LS_1002-LINK10 IS NOT INITIAL ) ).
*<-- FILE6~10 추가. 2024.07.04 - ZLSGMM3
          GT_DETL-FILE = 'X'.
        ENDIF.
      ENDIF.

*___Buy/Sell 내역
      PERFORM DOMAIN_VALUE_GET USING : 'ZBY_SL'
                                       GT_DETL-BY_SL
                                       GT_DETL-BSTXT,

                                       'ZBY_SL'
                                       GT_DETL-BY_SL1
                                       GT_DETL-BSTXT1.

*___고객명
      PERFORM GET_KUNNR_DESC USING GT_DETL-KUNNR
                                   GT_DETL-NAMAG.


*___FCM명
      PERFORM GET_LIFNR_DESC USING: GT_DETL-FCM  GT_DETL-NAMLF,
                                    GT_DETL-FCM1 GT_DETL-NAMLF1.

*___계약유형/계약상태/집행유형/결재상태 내역
      PERFORM DOMAIN_VALUE_GET USING: 'ZCOTYP'
                                      GT_DETL-COTYP
                                      GT_DETL-COTPT,

                                      'ZCSTAT'
                                      GT_DETL-CSTAT
                                      GT_DETL-CSTXT,

                                      'ZMITYP_1'
                                      GT_DETL-MITYP
                                      GT_DETL-MITPT,

                                      'ZMITYP_1'
                                      GT_DETL-MITYP1
                                      GT_DETL-MITPT1,

                                      'ZCONFM3'
                                      GT_DETL-CONFM
                                      GT_DETL-CFMTX,

                                      'ZCONFM3'
                                      GT_DETL-CONFM1
                                      GT_DETL-CFMTX1.

      APPEND GT_DETL.
    ENDLOOP.
  ENDLOOP.

*___데이터 점검
  LOOP AT GT_DETL.
    IF GV_TRTYP = 'V'.     "확정
      PERFORM CHECK_CONFIRM_DATA.
    ELSE.                  "확정취소
      PERFORM CHECK_CANCEL_DATA.
    ENDIF.

    IF GT_DETL-MESSAGE IS INITIAL.
      GT_DETL-ICON = '@5B@'.   "ICON_LED_GREEN
    ELSE.
      REPLACE '/' IN GT_DETL-MESSAGE WITH ' '.
      CONDENSE GT_DETL-MESSAGE.

      GT_DETL-ICON = '@5C@'.   "ICON_LED_RED
    ENDIF.

    MODIFY GT_DETL.
  ENDLOOP.

ENDFORM.                    " GET_DETAIL_DATA
*&---------------------------------------------------------------------*
*&      Form  CHECK_CONFIRM_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_CONFIRM_DATA .

*___만기일/FCM/비철구분/집행수량
  IF GT_DETL-ENDAT <> GT_DETL-ENDAT1.
    CONCATENATE GT_DETL-MESSAGE '/만기일'
       INTO GT_DETL-MESSAGE.
  ENDIF.

  IF GT_DETL-FCM <> GT_DETL-FCM1.
    CONCATENATE GT_DETL-MESSAGE '/FCM'
       INTO GT_DETL-MESSAGE.
  ENDIF.

  IF GT_DETL-NFKEY <> GT_DETL-NFKEY1.
    CONCATENATE GT_DETL-MESSAGE '/비철구분'
       INTO GT_DETL-MESSAGE.
  ENDIF.

  IF GT_DETL-EMENG <> GT_DETL-EMENG1.
    CONCATENATE GT_DETL-MESSAGE '/집행수량'
       INTO GT_DETL-MESSAGE.
  ENDIF.

*___Position
  IF ( GT_DETL-BY_SL = 'S' AND GT_DETL-BY_SL1 <> 'B' ) OR
     ( GT_DETL-BY_SL = 'B' AND GT_DETL-BY_SL1 <> 'S' ).
    CONCATENATE GT_DETL-MESSAGE '/Position'
       INTO GT_DETL-MESSAGE.
  ENDIF.

*___신규결재상태
  IF GT_DETL-CONFM <> '3' AND GT_DETL-CONFM <> '7'.
    CONCATENATE GT_DETL-MESSAGE '/신규집행결재상태'
       INTO GT_DETL-MESSAGE.
  ENDIF.

*___신규취소여부
  IF GT_DETL-YNCAN = 'X'.
    CONCATENATE GT_DETL-MESSAGE '/신규집행취소여부'
       INTO GT_DETL-MESSAGE.
  ENDIF.

*___신규정산여부
  IF GT_DETL-YNFIN = 'X'.
    CONCATENATE GT_DETL-MESSAGE '/신규집행정산여부'
       INTO GT_DETL-MESSAGE.
  ENDIF.

*___신규집행단가
  IF GT_DETL-PRICE IS INITIAL.
    CONCATENATE GT_DETL-MESSAGE '/신규집행단가'
       INTO GT_DETL-MESSAGE.
  ENDIF.

*___청산결재상태
  IF GT_DETL-CONFM1 <> '3' AND GT_DETL-CONFM1 <> '7'.
    CONCATENATE GT_DETL-MESSAGE '/청산집행결재상태'
       INTO GT_DETL-MESSAGE.
  ENDIF.

*___청산취소여부
  IF GT_DETL-YNCAN1 = 'X'.
    CONCATENATE GT_DETL-MESSAGE '/청산집행취소여부'
       INTO GT_DETL-MESSAGE.
  ENDIF.

*___청산정산여부
  IF GT_DETL-YNFIN1 = 'X'.
    CONCATENATE GT_DETL-MESSAGE '/청산집행정산여부'
       INTO GT_DETL-MESSAGE.
  ENDIF.

*___청산집행단가
  IF GT_DETL-PRICE1 IS INITIAL.
    CONCATENATE GT_DETL-MESSAGE '/청산집행단가'
       INTO GT_DETL-MESSAGE.
  ENDIF.

*___선물요청번호
  IF GT_DETL-REQNO IS INITIAL OR GT_DETL-H_NO1 IS INITIAL.
    CONCATENATE GT_DETL-MESSAGE '/선물요청번호'
       INTO GT_DETL-MESSAGE.
  ENDIF.

*___계약번호
  IF GT_DETL-CONNO IS INITIAL.
    CONCATENATE GT_DETL-MESSAGE '/계약번호'
       INTO GT_DETL-MESSAGE.
  ENDIF.

*___계약-비철구분
  IF GT_DETL-NFKEY2 IS INITIAL.
    CONCATENATE GT_DETL-MESSAGE '/계약-비철구분'
       INTO GT_DETL-MESSAGE.
  ENDIF.

*___계약상태-계약유형-고객코드
  IF ( GT_DETL-COTYP = '1' OR GT_DETL-COTYP = '2' ) AND
     GT_DETL-CSTAT <> 'C' AND GT_DETL-KUNNR IS INITIAL.
    CONCATENATE GT_DETL-MESSAGE '/계약-고객코드'
       INTO GT_DETL-MESSAGE.
  ENDIF.

*___계약-첨부파일
  IF ( GT_DETL-COTYP =  '1' OR GT_DETL-COTYP = '2' ) AND
       GT_DETL-FILE  IS INITIAL.
    CONCATENATE GT_DETL-MESSAGE '/계약-첨부파일'
       INTO GT_DETL-MESSAGE.
  ENDIF.

ENDFORM.                    " CHECK_CONFIRM_DATA
*&---------------------------------------------------------------------*
*&      Form  CHECK_CANCEL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_CANCEL_DATA .

  IF GT_DETL-YNFIN = ' '.
    CONCATENATE GT_DETL-MESSAGE '/신규집행마감여부'
           INTO GT_DETL-MESSAGE.
  ENDIF.

  IF GT_DETL-YNFIN1 = ' '.
    CONCATENATE GT_DETL-MESSAGE '/청산집행마감여부'
           INTO GT_DETL-MESSAGE.
  ENDIF.

ENDFORM.                    " CHECK_CANCEL_DATA
*&---------------------------------------------------------------------*
*&      Form  SETTLEMENT_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SETTLEMENT_CONFIRM USING PV_FLAG.
  DATA: LV_NCCHK     LIKE ZNFT1050-NCCHK,
        LV_TITLE(20),
        LV_TEXT(50),
        LV_FLAG.

  READ TABLE GT_DETL WITH KEY ICON = '@5C@'.
  IF SY-SUBRC = 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '확정 대상 데이터의 상태를 확인하십시오.'.
    EXIT.
  ENDIF.

  IF PV_FLAG IS INITIAL.
    LV_TITLE = '확정'.
    LV_TEXT  = '정산대상을 확정 하시겠습니까?'.
    LV_NCCHK = 'X'.
  ELSE.
    LV_TITLE = '확정취소'.
    LV_TEXT  = '정산대상을 확정취소 하시겠습니까?'.
    CLEAR : LV_NCCHK.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING LV_TITLE
                                 LV_TEXT
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
    PERFORM UPDATE_FUTURES_TRADING USING LV_FLAG
                                         LV_NCCHK.

    IF LV_FLAG IS INITIAL.
      PERFORM UPDATE_PROCESSING_STATUS USING LV_FLAG
                                             LV_NCCHK.

      IF LV_FLAG IS INITIAL.
        PERFORM SAVE_CHANGE_DOC USING PV_FLAG.

        COMMIT WORK.

        MESSAGE S003 WITH '정산대상을' LV_TITLE
                          '하였습니다.'.

        PERFORM GET_SETTLEMENT_DATA.

        IF GT_DETL[] IS NOT INITIAL.
          LEAVE TO SCREEN 0.
        ENDIF.
      ELSE.
        ROLLBACK WORK.

        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '정산진행상태 저장 에러!'.
      ENDIF.
    ELSE.
      ROLLBACK WORK.

      IF LV_FLAG = 'N'.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '신규선물집행 저장 에러!'.
      ELSE.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '청산선물집행 저장 에러!'.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " SETTLEMENT_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  UPDATE_FUTURES_TRADING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPDATE_FUTURES_TRADING  USING    PV_FLAG
                                      PV_VALUE.

  CLEAR : PV_FLAG.

  LOOP AT GT_DETL.
    UPDATE ZNFT1020 SET YNFIN = PV_VALUE
                        AENAM = SY-UNAME
                        AEDAT = SY-DATLO
                        AEZET = SY-TIMLO
                  WHERE NFUTN = GT_DETL-NFUTN.
    IF SY-SUBRC <> 0.
      PV_FLAG = 'N'.
      EXIT.
    ENDIF.

    UPDATE ZNFT1030 SET YNFIN = PV_VALUE
                        AENAM = SY-UNAME
                        AEDAT = SY-DATLO
                        AEZET = SY-TIMLO
                  WHERE CFUTN = GT_DETL-CFUTN.
    IF SY-SUBRC <> 0.
      PV_FLAG = 'C'.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " UPDATE_FUTURES_TRADING
*&---------------------------------------------------------------------*
*&      Form  UPDATE_PROCESSING_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPDATE_PROCESSING_STATUS  USING  PV_FLAG
                                      PV_NCCHK.
  CLEAR : PV_FLAG.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    READ TABLE GT_1050 WITH KEY BUKRS = GT_MAIN-BUKRS
                                ENDAT = GT_MAIN-ENDAT
                                FCM   = GT_MAIN-FCM.
    IF SY-SUBRC = 0.
      IF GT_MAIN-NFBUY IS INITIAL AND
         GT_MAIN-NFSEL IS INITIAL AND
         GT_MAIN-CFBUY IS INITIAL AND
         GT_MAIN-CFSEL IS INITIAL AND
         PV_NCCHK      IS INITIAL.
        DELETE GT_1050 INDEX SY-TABIX.
      ELSE.
        GT_1050-NCCHK = PV_NCCHK.
        GT_1050-AENAM = SY-UNAME.
        GT_1050-AEDAT = SY-DATLO.
        GT_1050-AEZET = SY-TIMLO.

        MODIFY GT_1050 INDEX SY-TABIX.
      ENDIF.
    ENDIF.
  ENDLOOP.

*___정산진행상태 삭제 후 재생성
  DELETE FROM ZNFT1050 WHERE BUKRS = P_BUKRS
                         AND ENDAT BETWEEN GV_FRDAT AND GV_TODAT.

  MODIFY ZNFT1050 FROM TABLE GT_1050.
  IF SY-SUBRC <> 0.
    PV_FLAG = 'X'.
  ENDIF.

ENDFORM.                    " UPDATE_PROCESSING_STATUS
*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_CHANGE_DOC  USING  PV_FLAG.
  DATA: LV_OBJECTID TYPE CDHDR-OBJECTID,
        LV_TCODE    TYPE CDHDR-TCODE.

  LOOP AT GT_DETL.
    CLEAR : ZNFT1020, YZNFT1020,
            ZNFT1030, YZNFT1030.

*___신규선물집행 이력
    SELECT SINGLE *
      FROM ZNFT1020
     WHERE NFUTN = GT_DETL-NFUTN.

    YZNFT1020 = ZNFT1020.

    IF PV_FLAG IS INITIAL.
      CLEAR : YZNFT1020-YNFIN.
    ELSE.
      YZNFT1020-YNFIN = 'X'.
    ENDIF.

    LV_OBJECTID        = GT_DETL-NFUTN.
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
        UPD_ZNFT1020 = 'U'.

*___청산선물집행 이력
    SELECT SINGLE *
      FROM ZNFT1030
     WHERE CFUTN = GT_DETL-CFUTN.

    YZNFT1030 = ZNFT1030.

    IF PV_FLAG IS INITIAL.
      CLEAR : YZNFT1030-YNFIN.
    ELSE.
      YZNFT1030-YNFIN = 'X'.
    ENDIF.

    LV_OBJECTID        = GT_DETL-CFUTN.
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
        UPD_ZNFT1030 = 'U'.
  ENDLOOP.

ENDFORM.                    " SAVE_CHANGE_DOC
*&---------------------------------------------------------------------*
*&      Form  DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING  PS_ROW    TYPE LVC_S_ROW
                          PS_COLUMN TYPE LVC_S_COL.

  READ TABLE GT_DETL INDEX PS_ROW-INDEX.
  IF SY-SUBRC = 0.
    CASE PS_COLUMN-FIELDNAME.
      WHEN 'CONNO'.
        IF GT_DETL-CONNO IS NOT INITIAL.
          SET PARAMETER ID 'ZNFCON' FIELD GT_DETL-CONNO.

          CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
        ENDIF.

      WHEN 'REQNO'.
        IF GT_DETL-REQNO IS NOT INITIAL.
          SET PARAMETER ID 'ZNFREQ' FIELD GT_DETL-REQNO.

          CALL TRANSACTION 'ZNF2M2103' AND SKIP FIRST SCREEN.
        ENDIF.

      WHEN 'NFUTN' OR 'CFUTN'.
        PERFORM DISPLAY_FUTRUES_HISTORY USING PS_COLUMN-FIELDNAME.

    ENDCASE.
  ENDIF.

ENDFORM.                    " DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  CHECK_PROCESSING_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_PROCESSING_STATUS .

  IF GV_TRTYP = 'V'.
    READ TABLE GT_MAIN WITH KEY CHECK = 'X'
                                NCCHK = '@5B@'.
    IF SY-SUBRC = 0.
      GV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '오류확인 완료된 건이 선택되었습니다.'.
      EXIT.
    ENDIF.
  ELSE.
    READ TABLE GT_MAIN WITH KEY CHECK = 'X'
                                NCCHK = '@5C@'.
    IF SY-SUBRC = 0.
      GV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '오류확인 완료되지 않은 건이 선택되었습니다.'.
      EXIT.
    ENDIF.
  ENDIF.

  READ TABLE GT_MAIN WITH KEY CHECK = 'X'
                              NETIG = '@5B@'.
  IF SY-SUBRC = 0.
    GV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '넷팅생성 완료된 건이 선택되었습니다.'.
    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_PROCESSING_STATUS
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_FUTRUES_HISTORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_FUTRUES_HISTORY USING PV_FNAME.
  DATA: LT_RSPAR LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

  CLEAR   : LT_RSPAR.
  REFRESH : LT_RSPAR.

  CHECK ( PV_FNAME = 'NFUTN' AND GT_DETL-NFUTN IS NOT INITIAL ) OR
        ( PV_FNAME = 'CFUTN' AND GT_DETL-CFUTN IS NOT INITIAL ).

  APPEND_PARAM : LT_RSPAR 'P_BUKRS' 'P' ' ' ' '  GT_DETL-BUKRS ' '.

  IF PV_FNAME = 'NFUTN'.
    APPEND_PARAM : LT_RSPAR 'S_NFUTN' 'S' 'I' 'EQ' GT_DETL-NFUTN ' ',
                   LT_RSPAR 'P_CHK11' 'P' ' ' ' '  'X'           ' ',
                   LT_RSPAR 'P_CHK12' 'P' ' ' ' '  ' '           ' '.
  ELSE.
    APPEND_PARAM : LT_RSPAR 'S_CFUTN' 'S' 'I' 'EQ' GT_DETL-CFUTN ' ',
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
*&      Form  GET_PROCESSING_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PROCESSING_STATUS .

  CLEAR   : GT_1050.
  REFRESH : GT_1050.

*___정산진행상태
  SELECT *
    INTO TABLE GT_1050
    FROM ZNFT1050
   WHERE BUKRS = P_BUKRS
     AND ENDAT BETWEEN GV_FRDAT AND GV_TODAT.

  LOOP AT GT_MAIN.
    PERFORM GET_LIFNR_DESC USING GT_MAIN-FCM
                                 GT_MAIN-NAME1.

    READ TABLE GT_1050 WITH KEY ENDAT = GT_MAIN-ENDAT
                                FCM   = GT_MAIN-FCM.
    IF SY-SUBRC <> 0.
      CLEAR : GT_1050.

      GT_1050-BUKRS = GT_MAIN-BUKRS.
      GT_1050-ENDAT = GT_MAIN-ENDAT.
      GT_1050-FCM   = GT_MAIN-FCM.
      GT_1050-ERNAM = SY-UNAME.
      GT_1050-ERDAT = SY-DATLO.
      GT_1050-ERZET = SY-TIMLO.
      GT_1050-AENAM = SY-UNAME.
      GT_1050-AEDAT = SY-DATLO.
      GT_1050-AEZET = SY-TIMLO.

      APPEND GT_1050.
    ENDIF.

    PERFORM SET_ICON USING: GT_1050-NCCHK GT_MAIN-NCCHK,
                            GT_1050-NETIG GT_MAIN-NETIG,
                            GT_1050-CONFM GT_MAIN-CONFM,
                            GT_1050-TRWON GT_MAIN-TRWON,
                            GT_1050-CREFI GT_MAIN-CREFI.

    MODIFY GT_MAIN.
  ENDLOOP.

ENDFORM.                    " GET_PROCESSING_STATUS
