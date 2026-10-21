*&---------------------------------------------------------------------*
*&  Include           ZNFR2420F01
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
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SETTLEMENT_DATA .

  CLEAR   : GT_MAIN, GT_1020, GT_1030, GT_1051.
  REFRESH : GT_MAIN, GT_1020, GT_1030, GT_1051.

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

*___정산진행상태 최신표시
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
  GS_LAYOUT-NO_ROWMARK = 'X'.
  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT-CTAB_FNAME = 'F_COL'.

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

      'CFCNT'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 8
      '청산건수'       ' '     ' '        ' ' 'INT4' ' ' ' ' ' ' ' ',

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

  CLEAR   : GS_FIELDCAT, GV_POS.
  REFRESH : GT_FIELDCAT2.

  GV_ITAB = 'GT_DETL'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT2
                                  USING :
      'ICON'     ' '      ' '     'X' ' ' ' ' ' '    'X' ' ' ' ' 4
      '상태'           ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' '.

  IF GV_TRTYP = 'V'.
    PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT2
                                    USING :
      'BUY'      ' '      ' '     ' ' 'X' ' ' ' '    'X' ' ' ' ' 4
      'Buy 수수료'     ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' 'X',

      'SELL'     ' '      ' '     ' ' 'X' ' ' ' '    'X' ' ' ' ' 4
      'Sell 수수료'    ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' 'X'.
  ENDIF.

  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT2
                                  USING :
      'MESSAGE'  ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 100
      '오류 Log'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'ENDAT' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'FCM'      ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'FCM'   'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'NAMLF'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      'FCM 명'         'NAME1' 'LFA1'     ' ' ' '    'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'NFKEY' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'MEINS' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'MCNT'     ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 2
      '차수'              ' '      ' '    ' ' ' '    'X' ' ' ' ' ' ',

      'N_FEE'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      'Buy 수수료'     'N_FEE' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' 'X',

      'C_FEE'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      'Sell 수수료'    'N_FEE' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' 'X',

      'FUTNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '매입집행번호'   'NFUTN' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'TRIND'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '매입구분'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'MITYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '매입유형'       'MITYP' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'MITPT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '매입유형내역'   ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'PRICE'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      'Buy 단가'       'PRICE' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'MISPD'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      'Buy Spread'     'MISPD' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      'Buy 수량'       'EMENG' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'WRBTR'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      'Buy 총액'       'PRICE' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'WAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      'Buy 통화'       'WAERS' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'MISUS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      'Buy 수수료여부' 'MISUS' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'NETNG'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      'Buy 넷팅여부'   ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'MFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '매각집행번호'   'NFUTN' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'MGIND'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '매각구분'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'MITYP1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '매각유형'       'MITYP' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'MITPT1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '매각유형내역'   ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'PRICE1'   'WAERS1' ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      'Sell 단가'      'PRICE' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'MISPD1'   'WAERS1' ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      'Sell Spread'    'MISPD' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'EMENG1'   ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      'Sell 수량'      'EMENG' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'WRBTR1'   'WAERS1' ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      'Sell 총액'      'PRICE' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'WAERS1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      'Sell 통화'      'WAERS' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'MISUS1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      'Sell 수수료여부' 'MISUS' 'ZNFT1020' ' ' ' '   'X' ' ' ' ' ' ',

      'NETNG1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      'Sell 넷팅여부'  ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'PRFIT'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '선물손익'       'PRICE' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'CONNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'CONNO' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'COTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '              'COTXT' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'KUNNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'KUNNR' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'NAMAG'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      '고객명'         'NAME1' 'KNA1'     ' ' ' '    'X' ' ' ' ' ' ',

      'NFCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'NFCTR' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'NTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'NTEXT' 'ZNFT0005' ' ' ' '    'X' ' ' ' ' ' ',

      'PRCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'PRCTR' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'PTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'PTEXT' 'ZNFT0004' ' ' ' '    'X' ' ' ' ' ' ',

      'VKGRP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      ' '              'VKGRP' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'VTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'VTEXT' 'ZNFT0003' ' ' ' '    'X' ' ' ' ' ' ',

      'REQNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'REQNO' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' ',

      'H_NO1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'H_NO1' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' ',

      'CONFM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '신규결재상태'   'CONFM' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'CFMTX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '신규결재상태내역' ' '   ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'CONFM1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '청산결재상태'   'CONFM' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

      'CFMTX1'   ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '청산결재상태내역' ' '   ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'YNCAN'    ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 1
      '신규취소여부'   'YNCAN' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'YNCAN1'   ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 1
      '청산취소여부'   'YNCAN' 'ZNFT1030' ' ' ' '    'X' ' ' ' ' ' ',

      'YNFIN'    ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 1
      '신규정산여부'   'YNFIN' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

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
*&      Form  SET_CELL_ATTRIBUTE_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_2.
  DATA: LT_CELLTAB TYPE LVC_T_STYL,
        LT_COLOR   TYPE LVC_T_SCOL.

*___각 Cell의 특성 제어
  LOOP AT GT_DETL.
    CLEAR   : LT_CELLTAB, LT_COLOR.
    REFRESH : LT_CELLTAB, LT_COLOR.

    PERFORM FILL_CELLTAB_C_2 CHANGING LT_CELLTAB.
    PERFORM FILL_COLOR_2     CHANGING LT_COLOR.

    REFRESH : GT_DETL-CELLTAB, GT_DETL-F_COL.

    INSERT LINES OF LT_CELLTAB INTO TABLE GT_DETL-CELLTAB.
    INSERT LINES OF LT_COLOR   INTO TABLE GT_DETL-F_COL.

    MODIFY GT_DETL.
  ENDLOOP.

ENDFORM.                    " SET_CELL_ATTRIBUTE_2
*&---------------------------------------------------------------------*
*&      Form  FILL_CELLTAB_C_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_CELLTAB_C_2 CHANGING PT_CELLTAB TYPE LVC_T_STYL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         L_MODE     TYPE RAW4.

  DATA : L_FIELDCAT TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT2 INTO L_FIELDCAT.
    LS_CELLTAB-FIELDNAME = L_FIELDCAT-FIELDNAME.

*___필드 활성화 여부
    IF L_FIELDCAT-EDIT = 'X'.
      IF GV_TRTYP = 'V'.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*                         + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
      ELSE.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                         + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
      ENDIF.
    ELSE.
      LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                       + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
    ENDIF.

    INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
  ENDLOOP.

ENDFORM.                    " FILL_CELLTAB_C_2
*&---------------------------------------------------------------------*
*&      Form  FILL_COLOR_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_COLOR  text
*----------------------------------------------------------------------*
FORM FILL_COLOR_2 CHANGING PT_COLOR TYPE LVC_T_SCOL.
  DATA: LS_CELLTAB TYPE LVC_S_STYL,
        LS_COLOR   TYPE LVC_S_SCOL,
        L_MODE     TYPE RAW4.

  DATA: L_FIELDCAT TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT2 INTO L_FIELDCAT.
    LS_COLOR-FNAME = L_FIELDCAT-FIELDNAME.

    IF  L_FIELDCAT-KEY = 'X'.
      IF LS_COLOR-FNAME <> 'BUY' AND LS_COLOR-FNAME <> 'SELL'.
        LS_COLOR-COLOR-COL = 4.
        LS_COLOR-COLOR-INT = 1.

        INSERT LS_COLOR INTO TABLE PT_COLOR.
      ENDIF.
    ELSE.
      IF L_FIELDCAT-EDIT <> 'X' OR GV_TRTYP <> 'V'.
        LS_COLOR-COLOR-COL = 2.
        LS_COLOR-COLOR-INT = 0.

        INSERT LS_COLOR INTO TABLE PT_COLOR.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " FILL_COLOR_2
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

  SET HANDLER GC_EVENT_HANDLER1->HANDLE_DATA_CHANGED_FINISHED_1
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

  SET HANDLER GC_EVENT_HANDLER2->HANDLE_TOOLBAR      FOR GC_ALV_GRID2.
  SET HANDLER GC_EVENT_HANDLER2->HANDLE_USER_COMMAND FOR GC_ALV_GRID2.
  SET HANDLER GC_EVENT_HANDLER2->HANDLE_DOUBLE_CLICK FOR GC_ALV_GRID2.
  SET HANDLER GC_EVENT_HANDLER2->HANDLE_DATA_CHANGED_FINISHED_2
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

  IF GV_TRTYP = 'V'.
    GS_VARIANT-HANDLE = '0002'.
  ELSE.
    GS_VARIANT-HANDLE = '0003'.
  ENDIF.

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

  IF GT_1020[] IS NOT INITIAL.
*___선물손익 확정
    SELECT *
      INTO TABLE GT_1051
      FROM ZNFT1051
       FOR ALL ENTRIES IN GT_1020
     WHERE NFUTN = GT_1020-NFUTN.
  ENDIF.

*___신규선물집행 데이터 집계
  LOOP AT GT_1020.
    READ TABLE GT_MAIN WITH KEY BUKRS = GT_1020-BUKRS
                                ENDAT = GT_1020-ENDAT
                                FCM   = GT_1020-FCM
                                NFKEY = GT_1020-NFKEY.
    IF SY-SUBRC = 0.
      LV_TABIX = SY-TABIX.

      GT_MAIN-NFCNT = GT_MAIN-NFCNT + 1.                 "신규건수

      IF GT_1020-BY_SL = 'B'.
        GT_MAIN-BMENG = GT_MAIN-BMENG + GT_1020-EMENG.   "Buy 수량
      ELSE.
        GT_MAIN-SMENG = GT_MAIN-SMENG + GT_1020-EMENG.   "Sell 수량
      ENDIF.

      READ TABLE GT_1030 WITH KEY NFUTN = GT_1020-NFUTN.
      IF SY-SUBRC = 0.
        GT_MAIN-CFCNT = GT_MAIN-CFCNT + 1.               "청산건수

        IF GT_1030-BY_SL = 'B'.
          GT_MAIN-BMENG = GT_MAIN-BMENG + GT_1030-EMENG. "Buy 수량
        ELSE.
          GT_MAIN-SMENG = GT_MAIN-SMENG + GT_1030-EMENG. "Sell 수량
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
      GT_MAIN-NFCNT = 1.                 "신규건수

      IF GT_1020-BY_SL = 'B'.
        GT_MAIN-BMENG = GT_1020-EMENG.   "Buy 수량
      ELSE.
        GT_MAIN-SMENG = GT_1020-EMENG.   "Sell 수량
      ENDIF.

      READ TABLE GT_1030 WITH KEY NFUTN = GT_1020-NFUTN.
      IF SY-SUBRC = 0.
        GT_MAIN-CFCNT = 1.               "청산건수

        IF GT_1030-BY_SL = 'B'.
          GT_MAIN-BMENG = GT_MAIN-BMENG + GT_1030-EMENG.   "Buy 수량
        ELSE.
          GT_MAIN-SMENG = GT_MAIN-SMENG + GT_1030-EMENG.   "Sell 수량
        ENDIF.
      ENDIF.

      APPEND GT_MAIN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_CONFIRM_DATA
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED  USING    E_FLAG
                                     E_MODIFIED
                                     ET_GOOD_CELLS TYPE LVC_T_MODI.
  DATA: LS_GOOD_CELLS TYPE LVC_S_MODI.

  DATA: BEGIN OF LT_FCM OCCURS 0,
          FCM       LIKE ZNFT1020-FCM,
        END   OF LT_FCM.

  DATA: LV_CNT      TYPE I.

  IF E_FLAG = '1'.
    LOOP AT ET_GOOD_CELLS INTO LS_GOOD_CELLS.
      CASE LS_GOOD_CELLS-FIELDNAME.
        WHEN 'CHECK'.
          CLEAR   : LT_FCM, LV_CNT.
          REFRESH : LT_FCM.

          LOOP AT GT_MAIN WHERE CHECK = 'X'.
            LT_FCM-FCM = GT_MAIN-FCM.
            COLLECT LT_FCM.
          ENDLOOP.

          DESCRIBE TABLE LT_FCM LINES LV_CNT.

          READ TABLE GT_MAIN INDEX LS_GOOD_CELLS-ROW_ID.
          IF SY-SUBRC = 0.
            IF GT_MAIN-CHECK = 'X' AND LV_CNT > 1.
              MESSAGE I003 DISPLAY LIKE 'E'
                 WITH '서로 다른 FCM은 선택할 수 없습니다.'.

              CLEAR : GT_MAIN-CHECK.
              MODIFY GT_MAIN INDEX LS_GOOD_CELLS-ROW_ID
                             TRANSPORTING CHECK.
              EXIT.
            ENDIF.

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
  ELSE.
    PERFORM CALC_CHARGE_TOTAL.
  ENDIF.

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
                              NETIG = '@5C@'.
  IF SY-SUBRC = 0.
    GV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH 'Netting 자동생성 완료되지 않은 건이 선택되었습니다.'.
    EXIT.
  ENDIF.

  IF GV_TRTYP = 'V'.
    READ TABLE GT_MAIN WITH KEY CHECK = 'X'
                                CONFM = '@5B@'.
    IF SY-SUBRC = 0.
      GV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '손익확정 완료된 건이 선택되었습니다.'.
      EXIT.
    ENDIF.
  ELSE.
    READ TABLE GT_MAIN WITH KEY CHECK = 'X'
                                CONFM = '@5C@'.
    IF SY-SUBRC = 0.
      GV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '손익확정 완료되지 않은 건이 선택되었습니다.'.
      EXIT.
    ENDIF.
  ENDIF.

  READ TABLE GT_MAIN WITH KEY CHECK = 'X'
                              TRWON = '@5B@'.
  IF SY-SUBRC = 0.
    GV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '원화환산 완료된 건이 선택되었습니다.'.
    EXIT.
  ENDIF.

  IF GV_TRTYP = 'V'.
    LOOP AT GT_MAIN WHERE MARK = 'X'.
      IF GT_MAIN-BMENG <> GT_MAIN-SMENG.
        GV_ERROR = 'X'.

        MESSAGE S003 DISPLAY LIKE 'E'
           WITH 'Buy/Sell 수량이 일치하지 않는 건이 존재합니다.'.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " CHECK_PROCESSING_STATUS
*&---------------------------------------------------------------------*
*&      Form  GET_DETAIL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DETAIL_DATA .

  CLEAR   : GV_PRFIT, GV_FEE,   GV_BMENG, GV_SMENG,
            GV_BMENG_LB, GV_SMENG_LB,
            GV_BYAMT, GV_SLAMT, GV_BYFEE, GV_SLFEE,
            GT_DETL, GV_CNT, GV_SHFNO.
  REFRESH : GT_DETL.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    LOOP AT GT_1020 WHERE BUKRS = GT_MAIN-BUKRS
                      AND ENDAT = GT_MAIN-ENDAT
                      AND FCM   = GT_MAIN-FCM.
      CLEAR : GT_DETL, GT_1030.

*___청산선물집행 Read
      READ TABLE GT_1030 WITH KEY NFUTN = GT_1020-NFUTN.

      GT_DETL-ENDAT  = GT_1020-ENDAT.   "신규만기일
      GT_DETL-FCM    = GT_1020-FCM.     "신규FCM
      GT_DETL-NFKEY  = GT_1020-NFKEY.   "신규비철구분
      GT_DETL-BY_SL  = GT_1020-BY_SL.   "신규Buy/Sell
      GT_DETL-ENDAT1 = GT_1030-ENDAT.   "청산만기일
      GT_DETL-FCM1   = GT_1030-FCM.     "청산FCM
      GT_DETL-NFKEY1 = GT_1030-NFKEY.   "청산비철구분
      GT_DETL-BY_SL1 = GT_1030-BY_SL.   "청산Buy/Sell
      GT_DETL-MEINS  = GT_1020-MEINS.   "단위
      GT_DETL-REQNO  = GT_1020-REQNO.   "선물요청번호
      GT_DETL-H_NO1  = GT_1020-H_NO1.   "선물요청항번
      GT_DETL-CONFM  = GT_1020-CONFM.   "신규결재상태
      GT_DETL-CONFM1 = GT_1030-CONFM.   "청산결재상태
      GT_DETL-YNCAN  = GT_1020-YNCAN.   "신규취소여부
      GT_DETL-YNCAN1 = GT_1030-YNCAN.   "청산취소여부
      GT_DETL-YNFIN  = GT_1020-YNFIN.   "신규정산여부
      GT_DETL-YNFIN1 = GT_1030-YNFIN.   "청산정산여부

      IF GT_1020-BY_SL = 'B'.
        GT_DETL-FUTNO  = GT_1020-NFUTN.  "매입집행번호
        GT_DETL-TRIND  = '신규'.         "매입구분
        GT_DETL-MITYP  = GT_1020-MITYP.  "매입유형
        GT_DETL-PRICE  = GT_1020-PRICE.  "Buy 단가
        GT_DETL-MISPD  = GT_1020-MISPD.  "Buy Spread
        GT_DETL-EMENG  = GT_1020-EMENG.  "Buy 수량
        GT_DETL-WAERS  = GT_1020-WAERS.  "Buy 통화
        GT_DETL-MISUS  = GT_1020-MISUS.  "Buy 수수료여부
        GT_DETL-NETNG  = 'No'.           "Buy Netting 여부

        GT_DETL-MFUTN  = GT_1030-CFUTN.  "매각집행번호
        GT_DETL-MGIND  = '청산'.         "매각구분
        GT_DETL-MITYP1 = GT_1030-MITYP.  "매각집행유형
        GT_DETL-PRICE1 = GT_1030-PRICE.  "Sell 단가
        GT_DETL-MISPD1 = GT_1030-MISPD.  "Sell Spread
        GT_DETL-EMENG1 = GT_1030-EMENG.  "Sell 집행수량
        GT_DETL-WAERS1 = GT_1030-WAERS.  "통화
        GT_DETL-MISUS1 = GT_1030-MISUS.  "Sell 수수료여부

        IF GT_1030-YNNET = 'X'.          "Sell Netting 여부
          GT_DETL-NETNG1 = 'Yes'.
        ELSE.
          GT_DETL-NETNG1 = 'No'.
        ENDIF.
      ELSE.
        GT_DETL-FUTNO = GT_1030-CFUTN.  "매입집행번호
        GT_DETL-TRIND = '청산'.         "매입구분
        GT_DETL-MITYP = GT_1030-MITYP.  "매입유형
        GT_DETL-PRICE = GT_1030-PRICE.  "Buy 단가
        GT_DETL-MISPD = GT_1030-MISPD.  "Buy Spread
        GT_DETL-EMENG = GT_1030-EMENG.  "Buy 수량
        GT_DETL-WAERS = GT_1030-WAERS.  "Buy 통화
        GT_DETL-MISUS = GT_1030-MISUS.  "Buy 수수료여부

        IF GT_1030-YNNET = 'X'.         "Buy Netting 여부
          GT_DETL-NETNG = 'Yes'.
        ELSE.
          GT_DETL-NETNG = 'No'.
        ENDIF.

        GT_DETL-MFUTN  = GT_1020-NFUTN.  "매각집행번호
        GT_DETL-MGIND  = '신규'.         "매각구분
        GT_DETL-MITYP1 = GT_1020-MITYP.  "매각집행유형
        GT_DETL-PRICE1 = GT_1020-PRICE.  "Sell 단가
        GT_DETL-MISPD1 = GT_1020-MISPD.  "Sell Spread
        GT_DETL-EMENG1 = GT_1020-EMENG.  "Sell 집행수량
        GT_DETL-WAERS1 = GT_1020-WAERS.  "통화
        GT_DETL-MISUS1 = GT_1020-MISUS.  "Sell 수수료여부
        GT_DETL-NETNG1 = 'No'.           "Sell Netting 여부
      ENDIF.

*___차수 정보
      PERFORM GET_SHFNO_CNT USING GT_1020-BY_SL
                                  GT_DETL-FUTNO
                                  GT_DETL-MFUTN
                                  GV_CNT.

      GT_DETL-MCNT   = GV_CNT.          "차수
      CLEAR : GV_CNT.

*___계약 정보
      SELECT SINGLE B~CONNO
                    B~COTXT
                    B~KUNNR
                    B~NFCTR
                    B~PRCTR
                    B~VKGRP
        INTO (GT_DETL-CONNO, GT_DETL-COTXT,
              GT_DETL-KUNNR, GT_DETL-NFCTR,
              GT_DETL-PRCTR, GT_DETL-VKGRP)
        FROM ZNFT1011 AS A
       INNER JOIN ZNFT1000 AS B
          ON A~CONNO = B~CONNO
       WHERE A~REQNO = GT_DETL-REQNO
         AND A~H_NO1 = GT_DETL-H_NO1.

*___Buy 총액
      GT_DETL-WRBTR = ( GT_DETL-PRICE + GT_DETL-MISPD )
                      * GT_DETL-EMENG.

*___Buy 수수료
      IF GV_TRTYP = 'V'.
        IF GT_DETL-MISUS = 'Y'.
          PERFORM CALC_CHARGE_AMOUNT USING GT_DETL-FCM
                                           GT_DETL-WRBTR
                                           GT_DETL-N_FEE
                                           GT_DETL-MCNT.
        ELSE.
          CLEAR : GT_DETL-N_FEE.
        ENDIF.
      ELSE.
        READ TABLE GT_1051 WITH KEY NFUTN = GT_1020-NFUTN
                                    CFUTN = GT_1030-CFUTN.
        IF SY-SUBRC = 0.
          GT_DETL-DBCHK = 'X'.

          IF GT_1020-BY_SL = 'B'.
            GT_DETL-N_FEE = GT_1051-N_FEE.
          ELSE.
            GT_DETL-N_FEE = GT_1051-C_FEE.
          ENDIF.
        ENDIF.
      ENDIF.

*___Sell 총액
      GT_DETL-WRBTR1 = ( GT_DETL-PRICE1 + GT_DETL-MISPD1 )
                       * GT_DETL-EMENG1.

*___Sell 수수료
      IF GV_TRTYP = 'V'.
        IF GT_DETL-MISUS1 = 'Y'.
          PERFORM CALC_CHARGE_AMOUNT_2ND USING GT_DETL-FCM
                                               GT_DETL-WRBTR1
                                               GT_DETL-C_FEE
                                               GT_DETL-MCNT.
        ELSE.
          CLEAR : GT_DETL-C_FEE.
        ENDIF.
      ELSE.
        READ TABLE GT_1051 WITH KEY NFUTN = GT_1020-NFUTN
                                    CFUTN = GT_1030-CFUTN.
        IF SY-SUBRC = 0.
          GT_DETL-DBCHK = 'X'.

          IF GT_1020-BY_SL = 'S'.
            GT_DETL-C_FEE = GT_1051-N_FEE.
          ELSE.
            GT_DETL-C_FEE = GT_1051-C_FEE.
          ENDIF.
        ENDIF.
      ENDIF.

*___선물손익
      GT_DETL-PRFIT = GT_DETL-WRBTR1 - GT_DETL-WRBTR
                    - GT_DETL-C_FEE  - GT_DETL-N_FEE.

*___FCM 명
      PERFORM GET_LIFNR_DESC USING GT_DETL-FCM
                                   GT_DETL-NAMLF.

*___고객명
      PERFORM GET_KUNNR_DESC USING GT_DETL-KUNNR
                                   GT_DETL-NAMAG.

*___사업부명
      PERFORM GET_NFCTR_DESC USING GT_MAIN-BUKRS
                                   GT_DETL-NFCTR
                                   GT_DETL-NTEXT.

*___손익센터명
      PERFORM GET_PRCTR_DESC USING GV_KOKRS
                                   GT_DETL-PRCTR
                                   GT_DETL-PTEXT.

*___영업그룹명
      PERFORM GET_VKGRP_DESC USING GV_KOKRS
                                   GT_DETL-VKGRP
                                   GT_DETL-VTEXT.

*___매입/매각 집행유형내역
      PERFORM DOMAIN_VALUE_GET USING : 'ZMITYP_1'
                                       GT_DETL-MITYP
                                       GT_DETL-MITPT,

                                       'ZMITYP_1'
                                       GT_DETL-MITYP1
                                       GT_DETL-MITPT1.

*___결재상태내역
      PERFORM DOMAIN_VALUE_GET USING : 'ZCONFM3'
                                       GT_DETL-CONFM
                                       GT_DETL-CFMTX,

                                       'ZCONFM3'
                                       GT_DETL-CONFM1
                                       GT_DETL-CFMTX1.

*___Buy/Sell 수량 집계
*--> 비철 CME 관리
**** 원본 주석 START
*      GV_BMENG = GV_BMENG + GT_DETL-EMENG.
*      GV_SMENG = GV_SMENG + GT_DETL-EMENG1.
**** 원본 주석 END
      IF GT_DETL-MEINS = 'TON'.
        GV_BMENG = GV_BMENG + GT_DETL-EMENG.
        GV_SMENG = GV_SMENG + GT_DETL-EMENG1.
      ELSEIF GT_DETL-MEINS = 'LB'.
        GV_BMENG_LB = GV_BMENG_LB + GT_DETL-EMENG.
        GV_SMENG_LB = GV_SMENG_LB + GT_DETL-EMENG1.
      ENDIF.
*<-- 비철 CME 관리

*___Buy/Sell 수수료 집계
      GV_BYFEE = GV_BYFEE + GT_DETL-N_FEE.
      GV_SLFEE = GV_SLFEE + GT_DETL-C_FEE.

*___Buy/Sell 총액 집계
      GV_BYAMT = GV_BYAMT + GT_DETL-WRBTR.
      GV_SLAMT = GV_SLAMT + GT_DETL-WRBTR1.

*___선물손익 집계
      GV_PRFIT = GV_PRFIT + GT_DETL-PRFIT.

      APPEND GT_DETL.
    ENDLOOP.
  ENDLOOP.

*___데이터 점검
  PERFORM CHECK_FUTURES_PROFIT_DATA.

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

*___만기일
  IF GT_DETL-ENDAT <> GT_DETL-ENDAT1.
    CONCATENATE GT_DETL-MESSAGE '/만기일'
           INTO GT_DETL-MESSAGE.
  ENDIF.

*___FCM
  IF GT_DETL-FCM <> GT_DETL-FCM1.
    CONCATENATE GT_DETL-MESSAGE '/FCM'
           INTO GT_DETL-MESSAGE.
  ENDIF.

*___비철구분
  IF GT_DETL-NFKEY <> GT_DETL-NFKEY1.
    CONCATENATE GT_DETL-MESSAGE '/비철구분'
           INTO GT_DETL-MESSAGE.
  ENDIF.

*___집행수량
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

*___결재상태
  IF GT_DETL-CONFM <> '3' AND GT_DETL-CONFM <> '7'.
    CONCATENATE GT_DETL-MESSAGE '/신규결재상태'
           INTO GT_DETL-MESSAGE.
  ENDIF.

  IF GT_DETL-CONFM1 <> '3' AND GT_DETL-CONFM1 <> '7'.
    CONCATENATE GT_DETL-MESSAGE '/청산결재상태'
           INTO GT_DETL-MESSAGE.
  ENDIF.

*___취소여부
  IF GT_DETL-YNCAN = 'X'.
    CONCATENATE GT_DETL-MESSAGE '/신규취소여부'
           INTO GT_DETL-MESSAGE.
  ENDIF.

  IF GT_DETL-YNCAN1 = 'X'.
    CONCATENATE GT_DETL-MESSAGE '/청산취소여부'
           INTO GT_DETL-MESSAGE.
  ENDIF.

*___정산여부
  IF GT_DETL-YNFIN IS INITIAL.
    CONCATENATE GT_DETL-MESSAGE '/신규정산여부'
           INTO GT_DETL-MESSAGE.
  ENDIF.

  IF GT_DETL-YNFIN1 IS INITIAL.
    CONCATENATE GT_DETL-MESSAGE '/청산정산여부'
           INTO GT_DETL-MESSAGE.
  ENDIF.

*___계약번호
  IF GT_DETL-CONNO IS INITIAL.
    CONCATENATE GT_DETL-MESSAGE '/계약번호'
           INTO GT_DETL-MESSAGE.
  ENDIF.

*___청산연결
  IF ( GT_DETL-BY_SL = 'B' AND GT_DETL-MFUTN IS INITIAL ) OR
     ( GT_DETL-BY_SL = 'S' AND GT_DETL-FUTNO IS INITIAL ).
    CONCATENATE GT_DETL-MESSAGE '/청산연결'
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

*___손익확정 데이터
  IF GT_DETL-DBCHK IS INITIAL.
    CONCATENATE GT_DETL-MESSAGE
                '/손익확정 데이터를 찾지 못했습니다.'
           INTO GT_DETL-MESSAGE.
  ENDIF.

ENDFORM.                    " CHECK_CANCEL_DATA
*&---------------------------------------------------------------------*
*&      Form  CREATE_FUTURES_PROFIT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_FUTURES_PROFIT_DATA .

  READ TABLE GT_DETL WITH KEY ICON = '@5C@'.
  IF SY-SUBRC = 0.
    MESSAGE I003 DISPLAY LIKE 'E'
       WITH '선물손익 확정 대상의 상태를 확인하십시오.'.
    EXIT.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING '확인'
                                 '선물손익을 확정 하시겠습니까?'
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
    PERFORM CREATE_ZNFT1051_DATA.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " CREATE_FUTURES_PROFIT_DATA
*&---------------------------------------------------------------------*
*&      Form  CREATE_ZNFT1051_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_ZNFT1051_DATA .
  DATA: LV_FLAG.

  CLEAR   : GT_1051N, LV_FLAG.
  REFRESH : GT_1051N.

  LOOP AT GT_DETL.
    CLEAR : GT_1051N.

    IF GT_DETL-TRIND = '신규'.
      GT_1051N-NFUTN  = GT_DETL-FUTNO.    "신규선물집행번호
      GT_1051N-CFUTN  = GT_DETL-MFUTN.    "선물집행번호
      GT_1051N-NBY_SL = 'B'.              "Buy/Sell
      GT_1051N-NMITYP = GT_DETL-MITYP.    "집행유형
      GT_1051N-CMITYP = GT_DETL-MITYP1.   "집행유형
      GT_1051N-NPRICE = GT_DETL-PRICE.    "집행단가
      GT_1051N-CPRICE = GT_DETL-PRICE1.   "집행단가
      GT_1051N-NMISPD = GT_DETL-MISPD.    "매입Spread
      GT_1051N-CMISPD = GT_DETL-MISPD1.   "매입Spread
      GT_1051N-N_FEE  = GT_DETL-N_FEE.    "신규수수료
      GT_1051N-C_FEE  = GT_DETL-C_FEE.    "청산수수료
    ELSE.
      GT_1051N-NFUTN  = GT_DETL-MFUTN.    "신규선물집행번호
      GT_1051N-CFUTN  = GT_DETL-FUTNO.    "선물집행번호
      GT_1051N-NBY_SL = 'S'.              "Buy/Sell
      GT_1051N-NMITYP = GT_DETL-MITYP1.   "집행유형
      GT_1051N-CMITYP = GT_DETL-MITYP.    "집행유형
      GT_1051N-NPRICE = GT_DETL-PRICE1.   "집행단가
      GT_1051N-CPRICE = GT_DETL-PRICE.    "집행단가
      GT_1051N-NMISPD = GT_DETL-MISPD1.   "매입Spread
      GT_1051N-CMISPD = GT_DETL-MISPD.    "매입Spread
      GT_1051N-N_FEE  = GT_DETL-C_FEE.    "신규수수료
      GT_1051N-C_FEE  = GT_DETL-N_FEE.    "청산수수료
    ENDIF.

    GT_1051N-BUKRS  = P_BUKRS.          "회사 코드
    GT_1051N-REQNO  = GT_DETL-REQNO.    "선물요청번호
    GT_1051N-H_NO1  = GT_DETL-H_NO1.    "항번
    GT_1051N-CONNO  = GT_DETL-CONNO.    "계약번호
    GT_1051N-NFKEY  = GT_DETL-NFKEY.    "비철구분
    GT_1051N-FCM    = GT_DETL-FCM.      "FCM(거래선)
    GT_1051N-ENDAT  = GT_DETL-ENDAT.    "만기일
    GT_1051N-EMENG  = GT_DETL-EMENG.    "집행수량
    GT_1051N-MEINS  = GT_DETL-MEINS.    "기본 단위
    GT_1051N-WAERS  = GT_DETL-WAERS.    "통화 키
    GT_1051N-UPRLO  = GT_DETL-PRFIT.    "선물손익(USD)
    GT_1051N-UAERS  = GV_WAERS.         "통화 키
    GT_1051N-ERNAM  = SY-UNAME.
    GT_1051N-ERDAT  = SY-DATLO.
    GT_1051N-ERZET  = SY-TIMLO.
    GT_1051N-AENAM  = SY-UNAME.
    GT_1051N-AEDAT  = SY-DATLO.
    GT_1051N-AEZET  = SY-TIMLO.

*___손익센터/영업그룹/고객
    SELECT SINGLE PRCTR
                  VKGRP
                  KUNNR
      INTO (GT_1051N-PRCTR, GT_1051N-VKGRP,
            GT_1051N-KUNNR)
      FROM ZNFT1000
     WHERE CONNO = GT_DETL-CONNO.

    APPEND GT_1051N.
  ENDLOOP.

  MODIFY ZNFT1051 FROM TABLE GT_1051N.
  IF SY-SUBRC = 0.
    PERFORM UPDATE_PROCESSING_STATUS USING LV_FLAG.

    IF LV_FLAG IS INITIAL.
      COMMIT WORK.

      MESSAGE S003 WITH '선물손익이 확정 되었습니다.'.

      PERFORM GET_SETTLEMENT_DATA.

      LEAVE TO SCREEN 0.
    ELSE.
      ROLLBACK WORK.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '정산진행상태 저장 에러!'.
    ENDIF.
  ELSE.
    ROLLBACK WORK.

    MESSAGE I003 DISPLAY LIKE 'E'
       WITH '선물손익 확정 데이터 저장 Error!'.
  ENDIF.

ENDFORM.                    " CREATE_ZNFT1051_DATA
*&---------------------------------------------------------------------*
*&      Form  UPDATE_PROCESSING_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPDATE_PROCESSING_STATUS  USING    PV_FLAG.
  DATA: LV_CONFM    LIKE ZNFT1050-CONFM.

  CLEAR : PV_FLAG.

  IF GV_TRTYP = 'V'.
    LV_CONFM = 'X'.
  ELSE.
    CLEAR : LV_CONFM.
  ENDIF.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    UPDATE ZNFT1050 SET CONFM = LV_CONFM
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

  CLEAR : GV_PRFIT,  GV_FEE,   GV_BMENG, GV_SMENG,
          GV_BYAMT,  GV_SLAMT, GV_BYFEE, GV_SLFEE,
          GV_BYAMT1, GV_SLAMT1.

  GV_WAERS = 'USD'.
  GV_MEINS = 'TON'.
  GV_MEINS_LB = 'LB'.

  PERFORM GET_DETAIL_DATA.

  CALL SCREEN 0200.

ENDFORM.                    " DISPLAY_SELECTED_DATA
*&---------------------------------------------------------------------*
*&      Form  APPLY_CHARGE_DISTRIBUTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM APPLY_CHARGE_DISTRIBUTION.
  DATA: LV_AMOUNT   LIKE ZNFT1051-N_FEE.

  IF GV_FEE IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '조정수수료가 입력되지 않았습니다.'.
    EXIT.
  ENDIF.

  LOOP AT GT_DETL WHERE BUY  = 'X'
                     OR SELL = 'X'.
    EXIT.
  ENDLOOP.

  IF SY-SUBRC <> 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '조정수수료를 적용할 라인이'
            '선택되지 않았습니다.'.
    EXIT.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING '확인'
                                 '입력한 조정수수료를 배부하시겠습니까?'
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
*___선택된 라인의 Buy/Sell 총액 집계
    CLEAR : GV_BYAMT1, GV_SLAMT1.

    LOOP AT GT_DETL WHERE BUY  = 'X'
                       OR SELL = 'X'.
      IF GT_DETL-BUY = 'X'.
        GV_BYAMT1 = GV_BYAMT1 + GT_DETL-WRBTR.
      ENDIF.

      IF GT_DETL-SELL = 'X'.
        GV_SLAMT1 = GV_SLAMT1 + GT_DETL-WRBTR1.
      ENDIF.
    ENDLOOP.

*___조정수수료 배부
    LOOP AT GT_DETL WHERE BUY  = 'X'
                       OR SELL = 'X'.
      IF GT_DETL-BUY = 'X'.
        LV_AMOUNT = ( GV_FEE * GT_DETL-WRBTR )
                  / ( GV_BYAMT1 + GV_SLAMT1 ).

        GT_DETL-N_FEE = GT_DETL-N_FEE + LV_AMOUNT.
      ENDIF.

      IF GT_DETL-SELL = 'X'.
        LV_AMOUNT = ( GV_FEE * GT_DETL-WRBTR1 )
                  / ( GV_BYAMT1 + GV_SLAMT1 ).

        GT_DETL-C_FEE = GT_DETL-C_FEE + LV_AMOUNT.
      ENDIF.

      CLEAR : GT_DETL-BUY, GT_DETL-SELL.

      MODIFY GT_DETL.
    ENDLOOP.

    PERFORM CALC_CHARGE_TOTAL.

    MESSAGE S003 WITH '조정수수료가 배부되었습니다.'.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " APPLY_CHARGE_DISTRIBUTION
*&---------------------------------------------------------------------*
*&      Form  CANCEL_FUTURES_PROFIT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANCEL_FUTURES_PROFIT_DATA .

  READ TABLE GT_DETL WITH KEY ICON = '@5C@'.
  IF SY-SUBRC = 0.
    MESSAGE I003 DISPLAY LIKE 'E'
       WITH '선물손익 확정 취소 가능 상태를 확인하십시오.'.
    EXIT.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING '확인'
                                 '선물손익 확정을 취소하시겠습니까?'
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
    PERFORM CANCEL_ZNFT1051_DATA.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " CANCEL_FUTURES_PROFIT_DATA
*&---------------------------------------------------------------------*
*&      Form  CANCEL_ZNFT1051_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANCEL_ZNFT1051_DATA .
  DATA: LV_FLAG.

  CLEAR   : GT_1051N, LV_FLAG.
  REFRESH : GT_1051N.

  LOOP AT GT_DETL.
    CLEAR : GT_1051N.

    IF GT_DETL-TRIND = '신규'.
      GT_1051N-NFUTN  = GT_DETL-FUTNO.    "신규선물집행번호
      GT_1051N-CFUTN  = GT_DETL-MFUTN.    "선물집행번호
    ELSE.
      GT_1051N-NFUTN  = GT_DETL-MFUTN.    "신규선물집행번호
      GT_1051N-CFUTN  = GT_DETL-FUTNO.    "선물집행번호
    ENDIF.

    APPEND GT_1051N.
  ENDLOOP.

  DELETE ZNFT1051 FROM TABLE GT_1051N.
  IF SY-SUBRC = 0.
    PERFORM UPDATE_PROCESSING_STATUS USING LV_FLAG.

    IF LV_FLAG IS INITIAL.
      COMMIT WORK.

      MESSAGE S003 WITH '선물손익 확정이 취소 되었습니다.'.

      PERFORM GET_SETTLEMENT_DATA.

      LEAVE TO SCREEN 0.
    ELSE.
      ROLLBACK WORK.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '정산진행상태 저장 에러!'.
    ENDIF.
  ELSE.
    ROLLBACK WORK.

    MESSAGE I003 DISPLAY LIKE 'E'
       WITH '선물손익 확정 데이터 삭제 Error!'.
  ENDIF.

ENDFORM.                    " CANCEL_ZNFT1051_DATA
*&---------------------------------------------------------------------*
*&      Form  CALC_CHARGE_AMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALC_CHARGE_AMOUNT USING PV_LIFNR
                              PV_WRBTR
                              PV_FEE
                              PV_MCNT.
  DATA: LV_FEERT1   LIKE ZNFT0021-FEERT1,
        LV_FEERT2   LIKE ZNFT0021-FEERT2.

  CLEAR : LV_FEERT1, LV_FEERT2.

  SELECT SINGLE FEERT1    "수수료율-분자
                FEERT2    "수수료율-분모
    INTO (LV_FEERT1, LV_FEERT2)
    FROM ZNFT0021
   WHERE BUKRS = P_BUKRS
     AND LIFNR = PV_LIFNR.

*.수수료 배분방법 변경 = 기존* (만기이동 차수+1)
* (C20121121_21491 Req.by박선아 2013/02/01)
  IF LV_FEERT2 IS NOT INITIAL.
    PV_FEE = PV_WRBTR * ( LV_FEERT1 / LV_FEERT2 ) * ( PV_MCNT + 1 ).
  ENDIF.

ENDFORM.                    " CALC_CHARGE_AMOUNT
*&---------------------------------------------------------------------*
*&      Form  CALC_CHARGE_AMOUNT_2ND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALC_CHARGE_AMOUNT_2ND USING PV_LIFNR
                                  PV_WRBTR
                                  PV_FEE
                                  PV_MCNT.
  DATA: LV_FEERT1   LIKE ZNFT0021-FEERT1,
        LV_FEERT2   LIKE ZNFT0021-FEERT2.

  CLEAR : LV_FEERT1, LV_FEERT2.

  SELECT SINGLE FEERT1    "수수료율-분자
                FEERT2    "수수료율-분모
    INTO (LV_FEERT1, LV_FEERT2)
    FROM ZNFT0021
   WHERE BUKRS = P_BUKRS
     AND LIFNR = PV_LIFNR.
*___수수료 배분방법 변경 = 기존
  IF LV_FEERT2 IS NOT INITIAL.
    PV_FEE = PV_WRBTR * ( LV_FEERT1 / LV_FEERT2 ).
  ENDIF.

ENDFORM.                    " CALC_CHARGE_AMOUNT
*&---------------------------------------------------------------------*
*&      Form  CHECK_FUTURES_PROFIT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_FUTURES_PROFIT_DATA .

  LOOP AT GT_DETL.
    IF GV_TRTYP = 'V'.     "확정
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
    ENDIF.

    MODIFY GT_DETL.
  ENDLOOP.

ENDFORM.                    " CHECK_FUTURES_PROFIT_DATA
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
      WHEN 'REQNO'.
        IF GT_DETL-REQNO IS NOT INITIAL.
          SET PARAMETER ID 'ZNFREQ' FIELD GT_DETL-REQNO.

          CALL TRANSACTION 'ZNF2M2103' AND SKIP FIRST SCREEN.
        ENDIF.

      WHEN 'CONNO'.
        IF GT_DETL-CONNO IS NOT INITIAL.
          SET PARAMETER ID 'ZNFCON' FIELD GT_DETL-CONNO.

          CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
        ENDIF.

      WHEN 'FUTNO' OR 'MFUTN'.
        PERFORM DISPLAY_FUTRUES_HISTORY USING PS_COLUMN-FIELDNAME.

    ENDCASE.
  ENDIF.

ENDFORM.                    " DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  CALC_CHARGE_TOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALC_CHARGE_TOTAL .

  CLEAR : GV_BYFEE, GV_SLFEE, GV_PRFIT.

  LOOP AT GT_DETL.
    GT_DETL-PRFIT = GT_DETL-WRBTR1 - GT_DETL-WRBTR
                  - GT_DETL-N_FEE  - GT_DETL-C_FEE.

    GV_BYFEE = GV_BYFEE + GT_DETL-N_FEE.
    GV_SLFEE = GV_SLFEE + GT_DETL-C_FEE.
    GV_PRFIT = GV_PRFIT + GT_DETL-PRFIT.

    MODIFY GT_DETL.
  ENDLOOP.

ENDFORM.                    " CALC_CHARGE_TOTAL
*&---------------------------------------------------------------------*
*&      Form  TOOLBAR_PROS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM TOOLBAR_PROS  USING R_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                         R_INTERACTIVE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

*___Separator Line
  CLEAR LS_TOOLBAR.
  MOVE   3                  TO   LS_TOOLBAR-BUTN_TYPE.
  APPEND LS_TOOLBAR         TO   R_OBJECT->MT_TOOLBAR.

*___Buy 전체선택
  CLEAR LS_TOOLBAR.
  MOVE 'BASEL'               TO   LS_TOOLBAR-FUNCTION.
  MOVE '@4B@'                TO   LS_TOOLBAR-ICON.
  MOVE 'Buy 전체선택'        TO   LS_TOOLBAR-QUICKINFO.
  MOVE ' Buy'                TO   LS_TOOLBAR-TEXT.
  MOVE ' '                   TO   LS_TOOLBAR-DISABLED.
  APPEND LS_TOOLBAR          TO   R_OBJECT->MT_TOOLBAR.

*___Buy 선택해제
  CLEAR LS_TOOLBAR.
  MOVE 'BDSEL'               TO   LS_TOOLBAR-FUNCTION.
  MOVE '@4D@'                TO   LS_TOOLBAR-ICON.
  MOVE 'Buy 전체선택해제'    TO   LS_TOOLBAR-QUICKINFO.
  MOVE ' Buy'                TO   LS_TOOLBAR-TEXT.
  MOVE ' '                   TO   LS_TOOLBAR-DISABLED.
  APPEND LS_TOOLBAR          TO   R_OBJECT->MT_TOOLBAR.

*___Separator Line
  CLEAR LS_TOOLBAR.
  MOVE   3                  TO   LS_TOOLBAR-BUTN_TYPE.
  APPEND LS_TOOLBAR         TO   R_OBJECT->MT_TOOLBAR.

*___Sell 전체선택
  CLEAR LS_TOOLBAR.
  MOVE 'SASEL'               TO   LS_TOOLBAR-FUNCTION.
  MOVE '@4B@'                TO   LS_TOOLBAR-ICON.
  MOVE 'Sell 전체선택'       TO   LS_TOOLBAR-QUICKINFO.
  MOVE ' Sell'               TO   LS_TOOLBAR-TEXT.
  MOVE ' '                   TO   LS_TOOLBAR-DISABLED.
  APPEND LS_TOOLBAR          TO   R_OBJECT->MT_TOOLBAR.

*___Sell 선택해제
  CLEAR LS_TOOLBAR.
  MOVE 'SDSEL'               TO   LS_TOOLBAR-FUNCTION.
  MOVE '@4D@'                TO   LS_TOOLBAR-ICON.
  MOVE 'Sell 전체선택해제'   TO   LS_TOOLBAR-QUICKINFO.
  MOVE ' Sell'               TO   LS_TOOLBAR-TEXT.
  MOVE ' '                   TO   LS_TOOLBAR-DISABLED.
  APPEND LS_TOOLBAR          TO   R_OBJECT->MT_TOOLBAR.

ENDFORM.                    " TOOLBAR_PROS
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_PROS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_PROS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM USER_COMMAND_PROS  USING  E_UCOMM.

  CASE E_UCOMM.
    WHEN 'BASEL' OR 'BDSEL'.    "Buy 전체선택/해제
      IF E_UCOMM = 'BASEL'.
        GT_DETL-BUY = 'X'.
      ELSE.
        CLEAR : GT_DETL-BUY.
      ENDIF.

      MODIFY GT_DETL TRANSPORTING BUY
                     WHERE ICON IS NOT INITIAL.

    WHEN 'SASEL' OR 'SDSEL'.    "Sell 전체선택/해제
      IF E_UCOMM = 'SASEL'.
        GT_DETL-SELL = 'X'.
      ELSE.
        CLEAR : GT_DETL-SELL.
      ENDIF.

      MODIFY GT_DETL TRANSPORTING SELL
                     WHERE ICON IS NOT INITIAL.

  ENDCASE.

ENDFORM.                    " USER_COMMAND_PROS
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

  APPEND_PARAM : LT_RSPAR 'P_BUKRS' 'P' ' ' ' '  P_BUKRS       ' '.

  IF ( PV_FNAME = 'FUTNO' AND GT_DETL-BY_SL = 'B' ) OR
     ( PV_FNAME = 'MFUTN' AND GT_DETL-BY_SL = 'S' ).
    LT_RSPAR-SELNAME = 'S_NFUTN'.
    LT_RSPAR-KIND    = 'S'.
    LT_RSPAR-SIGN    = 'I'.
    LT_RSPAR-OPTION  = 'EQ'.

    IF GT_DETL-BY_SL = 'B'.
      LT_RSPAR-LOW     = GT_DETL-FUTNO.
    ELSE.
      LT_RSPAR-LOW     = GT_DETL-MFUTN.
    ENDIF.

    APPEND LT_RSPAR.

    APPEND_PARAM : LT_RSPAR 'P_CHK11' 'P' ' ' ' '  'X'           ' ',
                   LT_RSPAR 'P_CHK12' 'P' ' ' ' '  ' '           ' '.
  ELSE.
    LT_RSPAR-SELNAME = 'S_CFUTN'.
    LT_RSPAR-KIND    = 'S'.
    LT_RSPAR-SIGN    = 'I'.
    LT_RSPAR-OPTION  = 'EQ'.

    IF GT_DETL-BY_SL = 'B'.
      LT_RSPAR-LOW     = GT_DETL-MFUTN.
    ELSE.
      LT_RSPAR-LOW     = GT_DETL-FUTNO.
    ENDIF.

    APPEND LT_RSPAR.

    APPEND_PARAM : LT_RSPAR 'P_CHK11' 'P' ' ' ' '  ' '           ' ',
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

*___정산진행상태
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
*&      Form  GET_SHFNO_CNT
*&---------------------------------------------------------------------*
*      만기이동차수계산(만기일이 연기되었을 경우만 count)
*      (C20121121_21491 Req.by박선아 2013/02/01)
*----------------------------------------------------------------------*
*      -->P_GT_1020_BY_SL  text
*      -->P_GV_CNT  text
*----------------------------------------------------------------------*
FORM GET_SHFNO_CNT  USING    GT_1020_BY_SL
                             GT_DETL-FUTNO
                             GT_DETL-MFUTN
                             GV_CNT.

  DATA: LV_ENDAT     LIKE ZNFT1041-ENDAT,
        LV_ENDAT_1   LIKE ZNFT1020-ENDAT,
        LV_OFUTN     LIKE ZNFT1040-OFUTN.

  CLEAR : GV_SHFNO, LV_ENDAT, LV_OFUTN, LV_ENDAT_1.

  IF GT_1020_BY_SL = 'B'.
    SELECT SINGLE SHFNO ENDAT
      INTO (GV_SHFNO, LV_ENDAT)
      FROM ZNFT1041
      WHERE NFUTN = GT_DETL-FUTNO.

    IF GV_SHFNO IS NOT INITIAL.         " 만기이동전 이력
      SELECT SINGLE A~OFUTN B~ENDAT
        INTO (LV_OFUTN, LV_ENDAT_1)
        FROM ZNFT1040 AS A
        INNER JOIN ZNFT1020 AS B
          ON A~OFUTN = B~NFUTN
          WHERE SHFNO = GV_SHFNO.

      IF SY-SUBRC = 0.
        IF LV_ENDAT NE LV_ENDAT_1.
          GV_CNT = GV_CNT + 1.

          PERFORM GET_SHFNO_CNT USING GT_1020-BY_SL
                                      LV_OFUTN
                                      GT_DETL-MFUTN
                                      GV_CNT.
        ENDIF.
      ENDIF.
    ENDIF.

  ELSE.

    SELECT SINGLE SHFNO ENDAT
          INTO (GV_SHFNO, LV_ENDAT)
          FROM ZNFT1041
          WHERE NFUTN = GT_DETL-MFUTN.

    IF GV_SHFNO IS NOT INITIAL.         " 만기이동전 이력
      SELECT SINGLE A~OFUTN B~ENDAT
        INTO (LV_OFUTN, LV_ENDAT_1)
        FROM ZNFT1040 AS A
        INNER JOIN ZNFT1020 AS B
          ON A~OFUTN = B~NFUTN
          WHERE SHFNO = GV_SHFNO.

      IF SY-SUBRC = 0.
        IF LV_ENDAT NE LV_ENDAT_1.
          GV_CNT = GV_CNT + 1.

          PERFORM GET_SHFNO_CNT USING GT_1020-BY_SL
                                      GT_DETL-FUTNO
                                      LV_OFUTN
                                      GV_CNT.

        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_SHFNO_CNT
