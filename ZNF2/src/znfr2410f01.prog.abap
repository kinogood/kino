*&---------------------------------------------------------------------*
*&  Include           ZNFR2410F01
*&---------------------------------------------------------------------*
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
    GV_TITLE = '생성 취소'.
  ELSE.
    GV_TRTYP = 'V'.
    GV_TITLE = '자동 생성'.
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
*  -->  p1        text
*  <--  p2        text
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

  PERFORM GET_CONFIRM_DATA.

  SORT GT_MAIN BY ENDAT FCM NFKEY.

*___정산진행상태
  PERFORM GET_PROCESSING_STATUS.

ENDFORM.                    " GET_SETTLEMENT_DATA
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
  IF SY-DYNNR <> '0100'.
    GS_LAYOUT-CWIDTH_OPT = 'X'.
  ENDIF.
*  GS_LAYOUT-EDIT       = 'X'.
  GS_LAYOUT-ZEBRA      = 'X'.
  GS_LAYOUT-SMALLTITLE = 'X'.
  GS_LAYOUT-SEL_MODE   = 'A'.              "select multiple lines

  IF SY-DYNNR = '0100'.
    GS_LAYOUT-NO_ROWMARK = 'X'.
    GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
    GS_LAYOUT-CTAB_FNAME = 'F_COL'.
  ENDIF.

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
      'CHECK'    ' '      ' '     ' ' 'X' ' ' ' '    'X' ' ' ' ' 4
      '선택'           ' '     ' '        ' ' ' '    'X' ' ' ' ' 'X',

      'BUKRS'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      ' '              'BUKRS' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '              'ENDAT' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'FCM'      ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '              'FCM'   'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'NAME1'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 35
      'FCM 명'         ' '     ' '        ' ' ' '    'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 8
      ' '              'NFKEY' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'NFCNT'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 8
      '신규건수'       ' '     ' '        ' ' 'INT4' ' ' ' ' ' ' ' ',

      'BMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      'Buy 수량'       'EMENG' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'SMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      'Sell 수량'      'EMENG' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

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
  DATA: LV_EDIT.

  CLEAR   : GS_FIELDCAT, GV_POS.
  REFRESH : GT_FIELDCAT2.

  IF GV_TRTYP = 'V'.
    LV_EDIT = 'X'.
  ELSE.
    CLEAR : LV_EDIT.
  ENDIF.

  GV_ITAB = 'GT_DETL'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT2
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

      'BY_SL1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      '청산 Buy/Sell'  'BY_SL' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

      'BSTXT1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '청산 Buy/Sell'  ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ENDAT1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '청산만기일'     'ENDAT' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

      'MITYP1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '청산집행유형'   'MITYP' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

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
      '청산수수료'     'MISUS' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' LV_EDIT,

      'PRCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'PRCTR' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'PTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'PTEXT' 'ZNFT0004' ' ' ' '    'X' ' ' ' ' ' ',

      'CONFM1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '청산결재상태'   'CONFM' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

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

  IF SY-DYNNR = '0200'.
    IF GV_TRTYP = 'V'.
      IF GS_FIELDCAT-FIX_COLUMN = 'X'.
        GS_FIELDCAT-STYLE = '00000001'.
      ELSE.
        IF GS_FIELDCAT-EDIT IS INITIAL.
          GS_FIELDCAT-STYLE = '00000005'.
        ENDIF.
      ENDIF.
    ENDIF.
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
    AT NEW FCM.
      IF GV_INT IS INITIAL.
        GV_INT = 1.
      ELSE.
        CLEAR : GV_INT.
      ENDIF.
    ENDAT.

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
      IF LS_CELLTAB-FIELDNAME = 'CHECK'.
        IF GT_MAIN-CHECK = '-'.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                           + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*                           + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        ENDIF.
      ELSE.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*                         + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
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

  IF SY-DYNNR = '0100'.
    LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_SORT_ASC.
    APPEND LS_EXCLUDE TO PT_EXCLUDE.
    LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_SORT_DSC.
    APPEND LS_EXCLUDE TO PT_EXCLUDE.
    LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_FILTER.
    APPEND LS_EXCLUDE TO PT_EXCLUDE.
  ENDIF.

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

  SET HANDLER GC_EVENT_HANDLER1->HANDLE_DATA_CHANGED_FINISHED
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

  SET HANDLER GC_EVENT_HANDLER2->HANDLE_DATA_CHANGED_FINISHED
          FOR GC_ALV_GRID2.
  SET HANDLER GC_EVENT_HANDLER2->HANDLE_DOUBLE_CLICK
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
      IT_FIELDCATALOG      = GT_FIELDCAT2[]
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
*&      Form  GET_CONFIRM_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CONFIRM_DATA .
  DATA: LV_TABIX    LIKE SY-TABIX.

*___신규선물집행
  SELECT *
    INTO TABLE GT_1020
    FROM ZNFT1020
   WHERE BUKRS = P_BUKRS
     AND ENDAT BETWEEN GV_FRDAT AND GV_TODAT
*     AND YNFIN = ' '
     AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) ).

*___청산선물집행
  SELECT *
    INTO TABLE GT_1030
    FROM ZNFT1030
   WHERE BUKRS = P_BUKRS
     AND ENDAT BETWEEN GV_FRDAT AND GV_TODAT
*     AND YNFIN = ' '
     AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) ).

*___신규선물집행 데이터 집계
  LOOP AT GT_1020.
    READ TABLE GT_MAIN WITH KEY BUKRS = GT_1020-BUKRS
                                ENDAT = GT_1020-ENDAT
                                FCM   = GT_1020-FCM
                                NFKEY = GT_1020-NFKEY.
    IF SY-SUBRC = 0.
      LV_TABIX = SY-TABIX.

      READ TABLE GT_1030 WITH KEY NFUTN = GT_1020-NFUTN
                                  YNNET = ' '.
      IF SY-SUBRC <> 0.
        SELECT SINGLE *
          FROM ZNFT1030
         WHERE NFUTN = GT_1020-NFUTN
           AND YNNET = ' '
           AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) ).

        IF SY-SUBRC <> 0.
          GT_MAIN-NFCNT = GT_MAIN-NFCNT + 1.                 "신규건수

          IF GT_1020-BY_SL = 'B'.
            GT_MAIN-BMENG = GT_MAIN-BMENG + GT_1020-EMENG.   "Buy 수량
          ELSE.
            GT_MAIN-SMENG = GT_MAIN-SMENG + GT_1020-EMENG.   "Sell 수량
          ENDIF.
        ENDIF.
      ENDIF.

      MODIFY GT_MAIN INDEX LV_TABIX.
    ELSE.
      CLEAR : GT_MAIN.

      GT_MAIN-BUKRS = GT_1020-BUKRS.     "회사코드
      GT_MAIN-ENDAT = GT_1020-ENDAT.     "만기일
      GT_MAIN-FCM   = GT_1020-FCM.       "FCM
      GT_MAIN-NFKEY = GT_1020-NFKEY.     "비철구분
      GT_MAIN-MEINS = GT_1020-MEINS.     "단위

*      IF GT_1020-YNFIN = ' '.
      READ TABLE GT_1030 WITH KEY NFUTN = GT_1020-NFUTN
                                  YNNET = ' '.
      IF SY-SUBRC <> 0.
        SELECT SINGLE *
          FROM ZNFT1030
         WHERE NFUTN = GT_1020-NFUTN
           AND YNNET = ' '
           AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) ).

        IF SY-SUBRC <> 0.
          GT_MAIN-NFCNT = 1.                 "신규건수

          IF GT_1020-BY_SL = 'B'.
            GT_MAIN-BMENG = GT_1020-EMENG.   "Buy 수량
          ELSE.
            GT_MAIN-SMENG = GT_1020-EMENG.   "Sell 수량
          ENDIF.
        ENDIF.
      ENDIF.
*      ENDIF.

      APPEND GT_MAIN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_CONFIRM_DATA
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED  USING    E_MODIFIED
                                     ET_GOOD_CELLS TYPE LVC_T_MODI.
  DATA: LS_GOOD_CELLS TYPE LVC_S_MODI.

  LOOP AT ET_GOOD_CELLS INTO LS_GOOD_CELLS.
    CASE LS_GOOD_CELLS-FIELDNAME.
      WHEN 'CHECK'.
        READ TABLE GT_MAIN INDEX LS_GOOD_CELLS-ROW_ID.
        IF SY-SUBRC = 0.
          LOOP AT GT_MAIN INTO GS_MAIN WHERE BUKRS = GT_MAIN-BUKRS
                                         AND ENDAT = GT_MAIN-ENDAT
                                         AND FCM   = GT_MAIN-FCM.
            GS_MAIN-MARK = GT_MAIN-CHECK.

            MODIFY GT_MAIN FROM GS_MAIN.
          ENDLOOP.

          MODIFY GT_MAIN INDEX LS_GOOD_CELLS-ROW_ID
                         TRANSPORTING CHECK.
        ENDIF.

    ENDCASE.
  ENDLOOP.

ENDFORM.                    " DATA_CHANGED_FINISHED
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

    LOOP AT GT_MAIN INTO GS_MAIN WHERE BUKRS = GT_MAIN-BUKRS
                                   AND ENDAT = GT_MAIN-ENDAT
                                   AND FCM   = GT_MAIN-FCM.
      GS_MAIN-MARK = GT_MAIN-CHECK.

      MODIFY GT_MAIN FROM GS_MAIN.
    ENDLOOP.

    MODIFY GT_MAIN TRANSPORTING CHECK.
  ENDLOOP.

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

  CLEAR : GV_CUPRC, GV_ALPRC, GV_PBPRC, GV_NIPRC, GV_SNPRC.
  GV_WAERS = 'USD'.

  IF GT_DETL[] IS NOT INITIAL.
    CALL SCREEN 0200.
  ELSE.
*___넷팅 자동 생성 데이터가 없는 경우
    PERFORM CREATE_NETTING_DATA.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_DATA
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
*&      Form  CHECK_PROCESSING_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_PROCESSING_STATUS .

  READ TABLE GT_MAIN WITH KEY CHECK = 'X'
                              NCCHK = '@5C@'.
  IF SY-SUBRC = 0.
    GV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '오류확인 완료되지 않은 건이 선택되었습니다.'.
    EXIT.
  ENDIF.

  IF GV_TRTYP = 'V'.
    READ TABLE GT_MAIN WITH KEY CHECK = 'X'
                                NETIG = '@5B@'.
    IF SY-SUBRC = 0.
      GV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '넷팅생성 완료된 건이 선택되었습니다.'.
      EXIT.
    ENDIF.
  ELSE.
    READ TABLE GT_MAIN WITH KEY CHECK = 'X'
                                NETIG = '@5C@'.
    IF SY-SUBRC = 0.
      GV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '넷팅생성 완료되지 않은 건이 선택되었습니다.'.
      EXIT.
    ENDIF.
  ENDIF.

  READ TABLE GT_MAIN WITH KEY CHECK = 'X'
                              CONFM = '@5B@'.
  IF SY-SUBRC = 0.
    GV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '손익확정 완료된 건이 선택되었습니다.'.
    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_PROCESSING_STATUS
*&---------------------------------------------------------------------*
*&      Form  GET_DETAIL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DETAIL_DATA .
  DATA: LS_1002  LIKE ZNFT1002,
        LV_PRCTR LIKE ZNFT1000-PRCTR.

  CLEAR   : GT_DETL, GV_EFLAG.
  REFRESH : GT_DETL.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    LOOP AT GT_1020 WHERE BUKRS = GT_MAIN-BUKRS
                      AND ENDAT = GT_MAIN-ENDAT
                      AND FCM   = GT_MAIN-FCM.
*___청산집행된 신규집행 건 제외
      READ TABLE GT_1030 WITH KEY NFUTN = GT_1020-NFUTN
                                  YNNET = ' '
                                  YNCAN = ' '.
      IF SY-SUBRC = 0.
        CONTINUE.
      ELSE.
        SELECT SINGLE *
          FROM ZNFT1030
         WHERE NFUTN = GT_1020-NFUTN
           AND YNNET = ' '
           AND YNCAN = ' '.

        IF SY-SUBRC = 0.
          CONTINUE.
        ENDIF.
      ENDIF.

      MOVE-CORRESPONDING GT_1020 TO GT_DETL.

*> SRM2106-01348 Netting포지션의 수수료 부과 기준 변경

*___계약번호/계약명/계약유형/계약상태/고객코드/손익센터
      SELECT SINGLE C~CONNO
                    C~COTXT
                    C~COTYP
                    C~CSTAT
                    C~KUNNR
                    C~PRCTR
                    A~MISUS
        INTO (GT_DETL-CONNO, GT_DETL-COTXT,
              GT_DETL-COTYP, GT_DETL-CSTAT,
              GT_DETL-KUNNR, GT_DETL-PRCTR, GT_DETL-MISUS1)
        FROM ZNFT1020 AS A
       INNER JOIN ZNFT1011 AS B
          ON A~REQNO = B~REQNO
         AND A~H_NO1 = B~H_NO1
       INNER JOIN ZNFT1000 AS C
          ON B~CONNO = C~CONNO
       WHERE A~NFUTN = GT_1020-NFUTN.

*> SRM2106-01348 Netting포지션의 수수료 부과 기준 변경

      IF GV_TRTYP = 'V'.
        GT_DETL-NFKEY1 = GT_1020-NFKEY.    "청산비철구분
        GT_DETL-RUDAT1 = GV_FRDAT.         "청산집행일
        GT_DETL-FCM1   = GT_1020-FCM.      "청산FCM
        GT_DETL-ENDAT1 = GT_1020-ENDAT.    "청산만기일
        GT_DETL-MITYP1 = 'A'.              "청산집행유형
        GT_DETL-MIMON1 = P_ENDMM.          "청산매입기준월
        GT_DETL-WAERS1 = GT_1020-WAERS.    "청산통화
        GT_DETL-EMENG1 = GT_1020-EMENG.    "청산집행수량
        GT_DETL-MEINS1 = GT_1020-MEINS.    "청산단위
        GT_DETL-CONFM1 = '3'.              "청산결재상태

        IF GT_1020-BY_SL = 'S'.
          GT_DETL-BY_SL1 = 'B'.            "청산 Buy/Sell
        ELSE.
          GT_DETL-BY_SL1 = 'S'.
        ENDIF.

*> SRM2106-01348 Netting포지션의 수수료 부과 기준 변경으로
*>                                   기존 로직 삭제
*        IF GT_DETL-PRCTR = GC_PRCTR.
*          GT_DETL-MISUS1 = 'N'.    "청산수수료여부
*        ELSE.
*          GT_DETL-MISUS1 = 'Y'.    "청산수수료여부
*        ENDIF.
*> SRM2106-01348 Netting포지션의 수수료 부과 기준 변경으로
*> 기존 로직 삭제
      ELSE.
        READ TABLE GT_1030 WITH KEY NFUTN = GT_1020-NFUTN
                                    YNNET = 'X'
                                    YNCAN = ' '.
        IF SY-SUBRC = 0.
          GT_DETL-CFUTN  = GT_1030-CFUTN.    "청산선물집행번호
          GT_DETL-NFKEY1 = GT_1030-NFKEY.    "청산비철구분
          GT_DETL-RUDAT1 = GT_1030-RUDAT.    "청산집행일
          GT_DETL-FCM1   = GT_1030-FCM.      "청산FCM
          GT_DETL-BY_SL1 = GT_1030-BY_SL.    "청산 Buy/Sell
          GT_DETL-ENDAT1 = GT_1030-ENDAT.    "청산만기일
          GT_DETL-MITYP1 = GT_1030-MITYP.    "청산집행유형
          GT_DETL-MIMON1 = GT_1030-MIMON.    "청산매입기준월
          GT_DETL-PRICE1 = GT_1030-PRICE.    "청산집행단가
          GT_DETL-WAERS1 = GT_1030-WAERS.    "청산통화
          GT_DETL-EMENG1 = GT_1030-EMENG.    "청산집행수량
          GT_DETL-MEINS1 = GT_1030-MEINS.    "청산단위
          GT_DETL-MISUS1 = GT_1030-MISUS.    "청산수수료여부
          GT_DETL-CONFM1 = GT_1030-CONFM.    "청산결재상태
          GT_DETL-YNCAN1 = GT_1030-YNCAN.    "청산취소여부
          GT_DETL-YNFIN1 = GT_1030-YNFIN.    "청산정산여부
        ENDIF.
      ENDIF.

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
              LS_1002-LINK10 IS NOT INITIAL )  ).
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

*___손익센터명
      PERFORM GET_PRCTR_DESC USING GV_KOKRS
                                   GT_DETL-PRCTR
                                   GT_DETL-PTEXT.

*___고객명
      PERFORM GET_KUNNR_DESC USING GT_DETL-KUNNR
                                   GT_DETL-NAMAG.

*___FCM명
      PERFORM GET_LIFNR_DESC USING GT_DETL-FCM
                                   GT_DETL-NAMLF.

*___계약유형/계약상태/집행유형/결재상태 내역
      PERFORM DOMAIN_VALUE_GET USING : 'ZCOTYP'
                                       GT_DETL-COTYP
                                       GT_DETL-COTPT,

                                       'ZCSTAT'
                                       GT_DETL-CSTAT
                                       GT_DETL-CSTXT,

                                       'ZMITYP_1'
                                       GT_DETL-MITYP
                                       GT_DETL-MITPT,

                                       'ZCONFM3'
                                       GT_DETL-CONFM
                                       GT_DETL-CFMTX.

      APPEND GT_DETL.
    ENDLOOP.
  ENDLOOP.

*___데이터 점검
  LOOP AT GT_DETL.
    IF GV_TRTYP = 'V'.     "생성
      PERFORM CHECK_CONFIRM_DATA.
    ELSE.
      PERFORM CHECK_CANCEL_DATA.
    ENDIF.

    IF GT_DETL-MESSAGE IS INITIAL.
      GT_DETL-ICON = '@5B@'.   "ICON_LED_GREEN
    ELSE.
      REPLACE '/' IN GT_DETL-MESSAGE WITH ' '.
      CONDENSE GT_DETL-MESSAGE.

      GT_DETL-ICON = '@5C@'.   "ICON_LED_RED
      GV_EFLAG     = 'X'.
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

*___Buy/Sell 수량
  READ TABLE GT_MAIN WITH KEY BUKRS = GT_DETL-BUKRS
                              ENDAT = GT_DETL-ENDAT
                              FCM   = GT_DETL-FCM
                              NFKEY = GT_DETL-NFKEY.
  IF SY-SUBRC = 0.
    IF GT_MAIN-BMENG <> GT_MAIN-SMENG.
      CONCATENATE GT_DETL-MESSAGE '/Buy-Sell수량'
             INTO GT_DETL-MESSAGE.
    ENDIF.
  ENDIF.

*___결재상태
  IF GT_DETL-CONFM <> '3' AND GT_DETL-CONFM <> '7'.
    CONCATENATE GT_DETL-MESSAGE '/결재상태'
           INTO GT_DETL-MESSAGE.
  ENDIF.

*___신규취소여부
  IF GT_DETL-YNCAN = 'X'.
    CONCATENATE GT_DETL-MESSAGE '/취소여부'
           INTO GT_DETL-MESSAGE.
  ENDIF.

*___신규정산여부
  IF GT_DETL-YNFIN = 'X'.
    CONCATENATE GT_DETL-MESSAGE '/정산여부'
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

*___자동생성 청산 데이터
  IF GT_DETL-CFUTN IS INITIAL.
    CONCATENATE GT_DETL-MESSAGE
                '/자동생성된 청산집행을 찾지 못했습니다.'
           INTO GT_DETL-MESSAGE.
  ENDIF.

ENDFORM.                    " CHECK_CANCEL_DATA
*&---------------------------------------------------------------------*
*&      Form  CREATE_NETTING_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_NETTING_DATA .

  READ TABLE GT_DETL WITH KEY ICON = '@5C@'.
  IF SY-SUBRC = 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH 'Netting 자동생성 대상의 상태를 확인하십시오.'.
    EXIT.
  ENDIF.

  LOOP AT GT_DETL WHERE PRICE1 IS INITIAL.
    EXIT.
  ENDLOOP.

  IF SY-SUBRC = 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '생성기준가가 입력되지 않은 건이 존재합니다.'.
    EXIT.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING '확인'
                                 'Netting 자동 생성을 실행하시겠습니까?'
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
    PERFORM CREATE_FUTURE_TRANSACTION.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " CREATE_NETTING_DATA
*&---------------------------------------------------------------------*
*&      Form  CREATE_FUTURE_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_FUTURE_TRANSACTION .
  DATA: LV_FLAG.

  CLEAR   : GT_1030N, LV_FLAG.
  REFRESH : GT_1030N.

  LOOP AT GT_DETL.
    CLEAR : GT_1030N.

    PERFORM GET_TRADING_NO.

    GT_1030N-BUKRS = GT_DETL-BUKRS.
    GT_1030N-NFUTN = GT_DETL-NFUTN.
    GT_1030N-NFKEY = GT_DETL-NFKEY1.
    GT_1030N-RUDAT = GT_DETL-RUDAT1.
    GT_1030N-FCM   = GT_DETL-FCM1.
    GT_1030N-BY_SL = GT_DETL-BY_SL1.
    GT_1030N-ENDAT = GT_DETL-ENDAT1.
    GT_1030N-MITYP = GT_DETL-MITYP1.
    GT_1030N-MIMON = GT_DETL-MIMON1.
    GT_1030N-PRICE = GT_DETL-PRICE1.
    GT_1030N-WAERS = GT_DETL-WAERS1.
    GT_1030N-EMENG = GT_DETL-EMENG1.
    GT_1030N-MEINS = GT_DETL-MEINS1.
    GT_1030N-MISUS = GT_DETL-MISUS1.
    GT_1030N-CONFM = GT_DETL-CONFM1.
    GT_1030N-YNFIN = 'X'.
    GT_1030N-YNNET = 'X'.
    GT_1030N-BIGO4 = 'Netting 자동생성'.
    GT_1030N-ERNAM = SY-UNAME.
    GT_1030N-ERDAT = SY-DATLO.
    GT_1030N-ERZET = SY-TIMLO.
    GT_1030N-AENAM = SY-UNAME.
    GT_1030N-AEDAT = SY-DATLO.
    GT_1030N-AEZET = SY-TIMLO.

    APPEND GT_1030N.

    UPDATE ZNFT1020 SET YNFIN = 'X'
*                        YNNET = 'X'
                        AENAM = SY-UNAME
                        AEDAT = SY-DATLO
                        AEZET = SY-TIMLO
                  WHERE NFUTN = GT_DETL-NFUTN.
    IF SY-SUBRC <> 0.
      LV_FLAG = 'X'.
      EXIT.
    ENDIF.

    GT_DETL-CFUTN = GT_1030N-CFUTN.

    MODIFY GT_DETL.
  ENDLOOP.

  IF LV_FLAG IS INITIAL.
    MODIFY ZNFT1030 FROM TABLE GT_1030N.
    IF SY-SUBRC = 0.
      PERFORM UPDATE_PROCESSING_STATUS USING LV_FLAG.

      IF LV_FLAG IS INITIAL.
        PERFORM SAVE_CHANGE_DOC.

        COMMIT WORK.

        MESSAGE S003 WITH 'Netting 자동 생성이 완료되었습니다.'.

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

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH 'Netting 청산데이터 저장 Error!'.
    ENDIF.
  ELSE.
    ROLLBACK WORK.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '신규선물집행 Update Error!'.
  ENDIF.

ENDFORM.                    " CREATE_FUTURE_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  GET_TRADING_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_TRADING_NO .

  CLEAR : GT_1030N-CFUTN.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '10'
      OBJECT                  = 'ZNF2_00004'
    IMPORTING
      NUMBER                  = GT_1030N-CFUTN
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
FORM SAVE_CHANGE_DOC .
  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND.

  LOOP AT GT_DETL.
    CLEAR : ZNFT1020, YZNFT1020,
            ZNFT1030, YZNFT1030.

*___신규선물집행 이력
    SELECT SINGLE *
      FROM ZNFT1020
     WHERE NFUTN = GT_DETL-NFUTN.

    YZNFT1020 = ZNFT1020.

    IF GV_TRTYP = 'A'.
      YZNFT1020-YNFIN = 'X'.
*      YZNFT1020-YNNET = 'X'.
    ELSE.
      CLEAR : YZNFT1020-YNFIN. "YZNFT1020-YNNET.
    ENDIF.

    LV_CDOC_UPD_OBJECT = 'U'.
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
        UPD_ZNFT1020 = LV_CDOC_UPD_OBJECT.

*___청산선물집행 이력
    IF GV_TRTYP = 'A'.
      LV_CDOC_UPD_OBJECT = 'U'.

      SELECT SINGLE *
        FROM ZNFT1030
       WHERE NFUTN = GT_DETL-CFUTN.

      YZNFT1030 = ZNFT1030.

      YZNFT1030-YNCAN = ' '.
      YZNFT1030-YNFIN = 'X'.
      YZNFT1030-WHYCN = ' '.
    ELSE.
      LV_CDOC_UPD_OBJECT = 'I'.

      READ TABLE GT_1030N WITH KEY CFUTN = GT_DETL-CFUTN.
      IF SY-SUBRC = 0.
        MOVE-CORRESPONDING GT_1030N TO ZNFT1030.
      ENDIF.
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
        UPD_ZNFT1030 = LV_CDOC_UPD_OBJECT.
  ENDLOOP.

ENDFORM.                    " SAVE_CHANGE_DOC
*&---------------------------------------------------------------------*
*&      Form  UPDATE_PROCESSING_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPDATE_PROCESSING_STATUS  USING    PV_FLAG.
  DATA: LV_NETIG    LIKE ZNFT1050-NETIG.

  CLEAR : PV_FLAG.

  IF GV_TRTYP = 'V'.
    LV_NETIG = 'X'.
  ELSE.
    CLEAR : LV_NETIG.
  ENDIF.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    UPDATE ZNFT1050 SET NETIG = LV_NETIG
                        AENAM = SY-UNAME
                        AEDAT = SY-DATLO
                        AEZET = SY-TIMLO
                  WHERE BUKRS = GT_MAIN-BUKRS
                    AND ENDAT = GT_MAIN-ENDAT
                    AND FCM   = GT_MAIN-FCM.
    IF SY-SUBRC <> 0.
      PV_FLAG = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " UPDATE_PROCESSING_STATUS
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

  CLEAR : GV_CUPRC, GV_ALPRC, GV_PBPRC, GV_NIPRC, GV_SNPRC.
  GV_WAERS = 'USD'.

  IF GT_DETL[] IS NOT INITIAL.
    CALL SCREEN 0200.
  ELSE.
*___넷팅 자동 생성 데이터가 없는 경우
    PERFORM CANCEL_NETTING_DATA.
  ENDIF.

ENDFORM.                    " DISPLAY_SELECTED_DATA
*&---------------------------------------------------------------------*
*&      Form  APPLY_BASE_PRICE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM APPLY_BASE_PRICE .

  IF GV_CUPRC IS INITIAL AND GV_ALPRC IS INITIAL AND
     GV_PBPRC IS INITIAL AND GV_NIPRC IS INITIAL AND
     GV_SNPRC IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '생성 기준가가 입력되지 않았습니다.'.
    EXIT.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING '확인'
                                 '입력한 생성기준가를 적용하시겠습니까?'
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
*___CU 단가
    IF GV_CUPRC IS NOT INITIAL.
      PERFORM APPLY_NF_PRICE USING 'CU'
                                   GV_CUPRC.
    ENDIF.

*___AL 단가
    IF GV_ALPRC IS NOT INITIAL.
      PERFORM APPLY_NF_PRICE USING 'AL'
                                   GV_ALPRC.
    ENDIF.

*___PB 단가
    IF GV_PBPRC IS NOT INITIAL.
      PERFORM APPLY_NF_PRICE USING 'PB'
                                   GV_PBPRC.
    ENDIF.

*___NI 단가
    IF GV_NIPRC IS NOT INITIAL.
      PERFORM APPLY_NF_PRICE USING 'NI'
                                   GV_NIPRC.
    ENDIF.

*___SN 단가    "기능개선 189023 추가
    IF GV_SNPRC IS NOT INITIAL.
      PERFORM APPLY_NF_PRICE USING 'SN'
                                   GV_SNPRC.
    ENDIF.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " APPLY_BASE_PRICE
*&---------------------------------------------------------------------*
*&      Form  CANCEL_NETTING_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANCEL_NETTING_DATA .

  READ TABLE GT_DETL WITH KEY ICON = '@5C@'.
  IF SY-SUBRC = 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH 'Netting 자동생성 취소 가능 상태를 확인하십시오.'.
    EXIT.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING '확인'
                                 'Netting 자동 생성을 취소하시겠습니까?'
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
    PERFORM CANCEL_FUTURE_TRANSACTION.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " CANCEL_NETTING_DATA
*&---------------------------------------------------------------------*
*&      Form  CANCEL_FUTURE_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANCEL_FUTURE_TRANSACTION .
  DATA: LV_FLAG.

  LOOP AT GT_DETL.
*___신규선물집행 Update
    UPDATE ZNFT1020 SET YNFIN = ' '
*                        YNNET = ' '
                        AENAM = SY-UNAME
                        AEDAT = SY-DATLO
                        AEZET = SY-TIMLO
                  WHERE NFUTN = GT_DETL-NFUTN.
    IF SY-SUBRC <> 0.
      LV_FLAG = '1'.
      EXIT.
    ENDIF.

    UPDATE ZNFT1030 SET YNCAN = 'X'
                        YNFIN = ' '
                        WHYCN = '3'     "Netting 취소
                        AENAM = SY-UNAME
                        AEDAT = SY-DATLO
                        AEZET = SY-TIMLO
                  WHERE CFUTN = GT_DETL-CFUTN.
    IF SY-SUBRC <> 0.
      LV_FLAG = '2'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF LV_FLAG IS INITIAL.
    PERFORM UPDATE_PROCESSING_STATUS USING LV_FLAG.

    IF LV_FLAG IS INITIAL.
      PERFORM SAVE_CHANGE_DOC.

      COMMIT WORK.

      MESSAGE S003 WITH 'Netting 자동 생성 취소가 완료되었습니다.'.

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

    IF LV_FLAG = '1'.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '신규선물집행 Update Error!'.
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '청산선물집행 Update Error!'.
    ENDIF.
  ENDIF.

ENDFORM.                    " CANCEL_FUTURE_TRANSACTION
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
  DATA: LV_FLAG.

  CLEAR   : GT_1050, LV_FLAG.
  REFRESH : GT_1050.

*___정산진행상태
  SELECT *
    INTO TABLE GT_1050
    FROM ZNFT1050
   WHERE BUKRS = P_BUKRS
     AND ENDAT BETWEEN GV_FRDAT AND GV_TODAT.

  LOOP AT GT_MAIN.
    AT NEW FCM.
      LV_FLAG = 'X'.
    ENDAT.

    IF LV_FLAG = 'X'.
      CLEAR : LV_FLAG.
    ELSE.
      GT_MAIN-CHECK = '-'.
    ENDIF.

    PERFORM GET_LIFNR_DESC USING GT_MAIN-FCM
                                 GT_MAIN-NAME1.

    CLEAR : GT_1050.

    READ TABLE GT_1050 WITH KEY ENDAT = GT_MAIN-ENDAT
                                FCM   = GT_MAIN-FCM.

    PERFORM SET_ICON(ZNFR2400) USING: GT_1050-NCCHK GT_MAIN-NCCHK,
                                      GT_1050-NETIG GT_MAIN-NETIG,
                                      GT_1050-CONFM GT_MAIN-CONFM,
                                      GT_1050-TRWON GT_MAIN-TRWON,
                                      GT_1050-CREFI GT_MAIN-CREFI.

    MODIFY GT_MAIN.
  ENDLOOP.

ENDFORM.                    " GET_PROCESSING_STATUS
*&---------------------------------------------------------------------*
*&      Form  APPLY_NF_PRICE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM APPLY_NF_PRICE  USING  PV_NFKEY
                            PV_PRICE.

  READ TABLE GT_DETL WITH KEY NFKEY = PV_NFKEY.
  IF SY-SUBRC = 0.
    GT_DETL-PRICE1 = PV_PRICE.

    MODIFY GT_DETL TRANSPORTING PRICE1
                   WHERE NFKEY = PV_NFKEY.
    IF SY-SUBRC = 0.
      MESSAGE S003 WITH '생성기준가가 적용되었습니다.'.
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH PV_NFKEY '생성기준가 적용 시 에러가 발생하였습니다.'.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    " APPLY_NF_PRICE
