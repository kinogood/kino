*&---------------------------------------------------------------------*
*&  Include           ZNFR2430F01
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
    GV_TITLE = '반영 취소'.
  ELSE.
    GV_TRTYP = 'V'.
    GV_TITLE = '반영'.
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

  SORT GT_MAIN BY ENDAT FCM.

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
*  GS_LAYOUT-NO_ROWMARK = 'X'.
*  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
*  GS_LAYOUT-CTAB_FNAME = 'F_COL'.

  IF SY-DYNNR = '0100'.
    GS_LAYOUT-BOX_FNAME  = 'CHECK'.
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
      'BUKRS'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      ' '              'BUKRS' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '              'ENDAT' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'FCM'      ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '              'FCM'   'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'NAME1'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 35
      'FCM 명'         ' '     ' '        ' ' ' '    'X' ' ' ' ' ' ',

      'BYCNT'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 8
      'Buy 건수'       ' '     ' '        ' ' 'INT4' ' ' ' ' ' ' ' ',

      'SLCNT'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 8
      'Sell 건수'      ' '     ' '        ' ' 'INT4' ' ' ' ' ' ' ' ',

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
      '상태'           ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 3
      ' '              'NFKEY' 'ZNFT1051' ' ' ' '    'X' ' ' ' ' ' ',

      'MESSAGE'  ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 100
      '오류 Log'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'EMENG' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'MEINS' 'ZNFT1051' ' ' ' '    'X' ' ' ' ' ' ',

      'BFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '매입집행번호'   'NFUTN' 'ZNFT1051' ' ' ' '    'X' ' ' ' ' ' ',

      'SFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '매각집행번호'   'NFUTN' 'ZNFT1051' ' ' ' '    'X' ' ' ' ' ' ',

      'BYPRC'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      'Buy 단가'      'NPRICE' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'BYAMT'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      'Buy 총액'      'NPRICE' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'BYFEE'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      'Buy 총액'      'NPRICE' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'SLPRC'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      'Sell 단가'     'NPRICE' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'SLAMT'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      'Sell 총액'     'NPRICE' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'SLFEE'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      'Sell 총액'     'NPRICE' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'UPRLO'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '             'UPRLO'  'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'UAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      ' '             'UAERS'  'ZNFT1051' ' ' ' '    'X' ' ' ' ' ' ',

      'KPRLO'    'KAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '             'KPRLO'  'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'KAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      ' '             'KAERS'  'ZNFT1051' ' ' ' '    'X' ' ' ' ' ' ',

      'KURSF'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 10
      ' '             'KURSF'  'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'WWERT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '             'WWERT'  'ZNFT1051' ' ' ' '    'X' ' ' ' ' ' ',

      'PRCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'PRCTR' 'ZNFT1051' ' ' ' '    'X' ' ' ' ' ' ',

      'PTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'PTEXT' 'ZNFT0004' ' ' ' '    'X' ' ' ' ' ' ',

      'VKGRP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'VKGRP' 'ZNFT1051' ' ' ' '    'X' ' ' ' ' ' ',

      'VTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'VTEXT' 'ZNFT0003' ' ' ' '    'X' ' ' ' ' ' ',

      'KUNNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'KUNNR' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'NAME1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      '고객명'         'NAME1' 'KNA1'     ' ' ' '    'X' ' ' ' ' ' ',

      'CONNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'CONNO' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'COTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '              'COTXT' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

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

  SET HANDLER GC_EVENT_HANDLER2->HANDLE_DOUBLE_CLICK FOR GC_ALV_GRID2.

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
     AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) ).

*___청산선물집행
  SELECT *
    INTO TABLE GT_1030
    FROM ZNFT1030
   WHERE BUKRS = P_BUKRS
     AND ENDAT BETWEEN GV_FRDAT AND GV_TODAT
     AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) ).

*___선물손익 확정 데이터
  IF GT_1020[] IS NOT INITIAL.
    SELECT *
      INTO TABLE GT_1051
      FROM ZNFT1051
       FOR ALL ENTRIES IN GT_1020
     WHERE BUKRS = P_BUKRS
       AND NFUTN = GT_1020-NFUTN.
  ENDIF.

*___신규선물집행 데이터 집계
  LOOP AT GT_1020.
    READ TABLE GT_MAIN WITH KEY BUKRS = GT_1020-BUKRS
                                ENDAT = GT_1020-ENDAT
                                FCM   = GT_1020-FCM.
    IF SY-SUBRC = 0.
      LV_TABIX = SY-TABIX.

      IF GT_1020-BY_SL = 'B'.
        GT_MAIN-BYCNT = GT_MAIN-BYCNT + 1.               "Buy 건수
        GT_MAIN-BMENG = GT_MAIN-BMENG + GT_1020-EMENG.   "Buy 수량
      ELSE.
        GT_MAIN-SLCNT = GT_MAIN-SLCNT + 1.               "Sell 건수
        GT_MAIN-SMENG = GT_MAIN-SMENG + GT_1020-EMENG.   "Sell 수량
      ENDIF.

      MODIFY GT_MAIN INDEX LV_TABIX.
    ELSE.
      CLEAR : GT_MAIN.

      GT_MAIN-BUKRS = GT_1020-BUKRS.     "회사코드
      GT_MAIN-ENDAT = GT_1020-ENDAT.     "만기일
      GT_MAIN-FCM   = GT_1020-FCM.       "FCM
      GT_MAIN-MEINS = GT_1020-MEINS.     "단위

      IF GT_1020-BY_SL = 'B'.
        GT_MAIN-BYCNT = 1.               "Buy 건수
        GT_MAIN-BMENG = GT_1020-EMENG.   "Buy 수량
      ELSE.
        GT_MAIN-SLCNT = 1.               "Sell 건수
        GT_MAIN-SMENG = GT_1020-EMENG.   "Sell 수량
      ENDIF.

      APPEND GT_MAIN.
    ENDIF.
  ENDLOOP.

*___청산선물집행 데이터 집계
  LOOP AT GT_1030.
    READ TABLE GT_MAIN WITH KEY BUKRS = GT_1030-BUKRS
                                ENDAT = GT_1030-ENDAT
                                FCM   = GT_1030-FCM.
    IF SY-SUBRC = 0.
      LV_TABIX = SY-TABIX.

      IF GT_1030-BY_SL = 'B'.
        GT_MAIN-BYCNT = GT_MAIN-BYCNT + 1.               "Buy 건수
        GT_MAIN-BMENG = GT_MAIN-BMENG + GT_1030-EMENG.   "Buy 수량
      ELSE.
        GT_MAIN-SLCNT = GT_MAIN-SLCNT + 1.               "Sell 건수
        GT_MAIN-SMENG = GT_MAIN-SMENG + GT_1030-EMENG.   "Sell 수량
      ENDIF.

      MODIFY GT_MAIN INDEX LV_TABIX.
    ELSE.
      CLEAR : GT_MAIN.

      GT_MAIN-BUKRS = GT_1030-BUKRS.     "회사코드
      GT_MAIN-ENDAT = GT_1030-ENDAT.     "만기일
      GT_MAIN-FCM   = GT_1030-FCM.       "FCM
      GT_MAIN-MEINS = GT_1030-MEINS.     "단위

      IF GT_1030-BY_SL = 'B'.
        GT_MAIN-BYCNT = 1.               "Buy 건수
        GT_MAIN-BMENG = GT_1030-EMENG.   "Buy 수량
      ELSE.
        GT_MAIN-SLCNT = 1.               "Sell 건수
        GT_MAIN-SMENG = GT_1030-EMENG.   "Sell 수량
      ENDIF.

      APPEND GT_MAIN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_CONFIRM_DATA
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
                              CONFM = '@5C@'.
  IF SY-SUBRC = 0.
    GV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선물손익 확정되지 않은 건이 선택되었습니다.'.
    EXIT.
  ENDIF.

  IF GV_TRTYP = 'V'.
    READ TABLE GT_MAIN WITH KEY CHECK = 'X'
                                TRWON = '@5B@'.
    IF SY-SUBRC = 0.
      GV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '원화반영 완료된 건이 선택되었습니다.'.
      EXIT.
    ENDIF.
  ELSE.
    READ TABLE GT_MAIN WITH KEY CHECK = 'X'
                                TRWON = '@5C@'.
    IF SY-SUBRC = 0.
      GV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '원화반영 완료되지 않은 건이 선택되었습니다.'.
      EXIT.
    ENDIF.
  ENDIF.

  READ TABLE GT_MAIN WITH KEY CHECK = 'X'
                              CREFI = '@5B@'.
  IF SY-SUBRC = 0.
    GV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '전표생성 완료된 건이 선택되었습니다.'.
    EXIT.
  ENDIF.

  IF GV_TRTYP = 'V'.
    LOOP AT GT_MAIN WHERE CHECK = 'X'.
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

  CLEAR   : GT_DETL.
  REFRESH : GT_DETL.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    LOOP AT GT_1051 WHERE BUKRS = GT_MAIN-BUKRS
                      AND ENDAT = GT_MAIN-ENDAT
                      AND FCM   = GT_MAIN-FCM.
      CLEAR : GT_DETL.

      MOVE-CORRESPONDING GT_1051 TO GT_DETL.

      IF GT_1051-NBY_SL = 'B'.
        GT_DETL-BFUTN = GT_1051-NFUTN.
        GT_DETL-SFUTN = GT_1051-CFUTN.
        GT_DETL-BYPRC = GT_1051-NPRICE + GT_1051-NMISPD.
        GT_DETL-BYFEE = GT_1051-N_FEE.
        GT_DETL-SLPRC = GT_1051-CPRICE + GT_1051-CMISPD.
        GT_DETL-SLFEE = GT_1051-C_FEE.
      ELSE.
        GT_DETL-BFUTN = GT_1051-CFUTN.
        GT_DETL-SFUTN = GT_1051-NFUTN.
        GT_DETL-BYPRC = GT_1051-CPRICE + GT_1051-CMISPD.
        GT_DETL-BYFEE = GT_1051-C_FEE.
        GT_DETL-SLPRC = GT_1051-NPRICE + GT_1051-NMISPD.
        GT_DETL-SLFEE = GT_1051-N_FEE.
      ENDIF.

      GT_DETL-BYAMT = GT_DETL-BYPRC * GT_DETL-EMENG.
      GT_DETL-SLAMT = GT_DETL-SLPRC * GT_DETL-EMENG.

*___계약명
      SELECT SINGLE COTXT
        INTO GT_DETL-COTXT
        FROM ZNFT1000
       WHERE CONNO = GT_DETL-CONNO.

*___신규 결재상태/취소여부/정산여부
      SELECT SINGLE CONFM
                    YNCAN
                    YNFIN
        INTO (GT_DETL-CONFM, GT_DETL-YNCAN,
              GT_DETL-YNFIN)
        FROM ZNFT1020
       WHERE NFUTN = GT_1051-NFUTN.

*___청산 결재상태/취소여부/정산여부
      SELECT SINGLE CONFM
                    YNCAN
                    YNFIN
        INTO (GT_DETL-CONFM1, GT_DETL-YNCAN1,
              GT_DETL-YNFIN1)
        FROM ZNFT1030
       WHERE CFUTN = GT_1051-CFUTN.

*___결재상태내역
      PERFORM DOMAIN_VALUE_GET USING : 'ZCONFM3'
                                       GT_DETL-CONFM
                                       GT_DETL-CFMTX,

                                       'ZCONFM3'
                                       GT_DETL-CONFM1
                                       GT_DETL-CFMTX1.

*___손익센터명
      PERFORM GET_PRCTR_DESC USING GV_KOKRS
                                   GT_DETL-PRCTR
                                   GT_DETL-PTEXT.

*___영업그룹명
      PERFORM GET_VKGRP_DESC USING GV_KOKRS
                                   GT_DETL-VKGRP
                                   GT_DETL-VTEXT.

*___고객명
      PERFORM GET_KUNNR_DESC USING GT_DETL-KUNNR
                                   GT_DETL-NAME1.

      APPEND GT_DETL.
    ENDLOOP.
  ENDLOOP.

*___데이터 점검
  PERFORM CHECK_FUTURES_PROFIT_DATA.

ENDFORM.                    " GET_DETAIL_DATA
*&---------------------------------------------------------------------*
*&      Form  CREATE_EXCHANGE_RATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_EXCHANGE_RATE.

  READ TABLE GT_DETL WITH KEY ICON = '@5C@'.
  IF SY-SUBRC = 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선물손익 원화 반영 대상의 상태를 확인하십시오.'.
    EXIT.
  ENDIF.

  READ TABLE GT_DETL WITH KEY WWERT = '00000000'.
  IF SY-SUBRC = 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '환율(환산일)이 반영되지 않은 데이터가 존재합니다.'.
    EXIT.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING '확인'
                                 '선물손익의 환율을 저장 하시겠습니까?'
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
    PERFORM CREATE_ZNFT1051_DATA.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " CREATE_EXCHANGE_RATE
*&---------------------------------------------------------------------*
*&      Form  CREATE_ZNFT1051_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_ZNFT1051_DATA .
  DATA: LV_NFUTN    LIKE ZNFT1051-NFUTN,
        LV_CFUTN    LIKE ZNFT1051-CFUTN,
        LV_FLAG.

  CLEAR   : GT_1052.
  REFRESH : GT_1052.

  LOOP AT GT_DETL.
    IF GT_DETL-NBY_SL = 'B'.
      LV_NFUTN = GT_DETL-BFUTN.
      LV_CFUTN = GT_DETL-SFUTN.
    ELSE.
      LV_NFUTN = GT_DETL-SFUTN.
      LV_CFUTN = GT_DETL-BFUTN.
    ENDIF.

    READ TABLE GT_1051 WITH KEY NFUTN = LV_NFUTN
                                CFUTN = LV_CFUTN.
    IF SY-SUBRC = 0.
      GT_1051-KURSF = GT_DETL-KURSF.  "환율
      GT_1051-WWERT = GT_DETL-WWERT.  "환산일
      GT_1051-KPRLO = GT_DETL-KPRLO.  "선물손익(KRW)
      GT_1051-KAERS = GT_DETL-KAERS.  "현지통화의 통화키
      GT_1051-AEDAT = SY-DATLO.
      GT_1051-AEZET = SY-TIMLO.
      GT_1051-AENAM = SY-UNAME.

      MODIFY GT_1051 INDEX SY-TABIX.
    ELSE.
      MESSAGE E003 WITH 'Internal Error!(GT_1051)'.
    ENDIF.

    CLEAR : GT_1052.

    MOVE-CORRESPONDING GT_1051 TO GT_1052.

    GT_1052-B_SUM = GT_DETL-BYAMT.
    GT_1052-B_FEE = GT_DETL-BYFEE.
    GT_1052-S_SUM = GT_DETL-SLAMT.
    GT_1052-S_FEE = GT_DETL-SLFEE.

    CLEAR : GT_1052-KURSF, GT_1052-GJAHR, GT_1052-BELNR,
            GT_1052-ERDAT, GT_1052-ERZET, GT_1052-ERNAM.

    COLLECT GT_1052.
  ENDLOOP.

  GT_1052-KURSF = GV_UKURS.
  GT_1052-ERDAT = SY-DATLO.
  GT_1052-ERZET = SY-TIMLO.
  GT_1052-ERNAM = SY-UNAME.
  GT_1052-AEDAT = SY-DATLO.
  GT_1052-AEZET = SY-TIMLO.
  GT_1052-AENAM = SY-UNAME.

  MODIFY GT_1052 TRANSPORTING KURSF ERDAT ERZET ERNAM
                              AEDAT AEZET AENAM
                 WHERE FCM IS NOT INITIAL.

  MODIFY ZNFT1051 FROM TABLE GT_1051.
  IF SY-SUBRC = 0.
    MODIFY ZNFT1052 FROM TABLE GT_1052.
    IF SY-SUBRC = 0.
      PERFORM UPDATE_PROCESSING_STATUS USING LV_FLAG.

      IF LV_FLAG IS INITIAL.
        COMMIT WORK.

        MESSAGE S003 WITH '선물손익에 원화(환율)이 반영 되었습니다.'.

        PERFORM GET_SETTLEMENT_DATA.

        LEAVE TO SCREEN 0.
      ELSE.
        ROLLBACK WORK.

        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '정산진행상태 저장 에러!'.
      ENDIF.
    ELSE.
      ROLLBACK WORK.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '선물손익 원화 반영 집계 데이터 저장 Error!'.
    ENDIF.
  ELSE.
    ROLLBACK WORK.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선물손익 원화 반영 데이터 저장 Error!'.
  ENDIF.

ENDFORM.                    " CREATE_ZNFT1051_DATA
*&---------------------------------------------------------------------*
*&      Form  UPDATE_PROCESSING_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPDATE_PROCESSING_STATUS  USING    PV_FLAG.
  DATA: LV_TRWON    LIKE ZNFT1050-TRWON.

  CLEAR : PV_FLAG.

  IF GV_TRTYP = 'V'.
    LV_TRWON = 'X'.
  ELSE.
    CLEAR : LV_TRWON.
  ENDIF.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    UPDATE ZNFT1050 SET TRWON = LV_TRWON
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

  CLEAR : GV_DATUM, GV_UKURS.

  PERFORM GET_DETAIL_DATA.

  CALL SCREEN 0200.

ENDFORM.                    " DISPLAY_SELECTED_DATA
*&---------------------------------------------------------------------*
*&      Form  APPLY_EXCHANGE_RATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM APPLY_EXCHANGE_RATE.
  DATA: LV_AMOUNT   LIKE ZNFT1051-N_FEE.

  IF GV_DATUM IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '환산일이 입력되지 않았습니다.'.
    EXIT.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING '확인'
                                 '환율을 반영하시겠습니까?'
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
    LOOP AT GT_DETL.
      GT_DETL-KAERS = GV_WAERS.
      GT_DETL-KURSF = GV_UKURS.
      GT_DETL-WWERT = GV_DATUM.

      CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
        EXPORTING
          DATE                    = GT_DETL-WWERT
          FOREIGN_AMOUNT          = GT_DETL-UPRLO
          FOREIGN_CURRENCY        = GT_DETL-UAERS
          LOCAL_CURRENCY          = GT_DETL-KAERS
          RATE                    = GT_DETL-KURSF
        IMPORTING
          LOCAL_AMOUNT            = GT_DETL-KPRLO
       EXCEPTIONS
          NO_RATE_FOUND           = 1
          OVERFLOW                = 2
          NO_FACTORS_FOUND        = 3
          NO_SPREAD_FOUND         = 4
          DERIVED_2_TIMES         = 5
          OTHERS                  = 6.

      MODIFY GT_DETL.
    ENDLOOP.

    MESSAGE S003 WITH '환율이 반영되었습니다.'.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " APPLY_EXCHANGE_RATE
*&---------------------------------------------------------------------*
*&      Form  CANCEL_EXCHANGE_RATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANCEL_EXCHANGE_RATE .

  READ TABLE GT_DETL WITH KEY ICON = '@5C@'.
  IF SY-SUBRC = 0.
    MESSAGE I003 DISPLAY LIKE 'E'
       WITH '선물손익 원화 반영 취소 가능 상태를 확인하십시오.'.
    EXIT.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM
    USING '확인'
          '선물손익 원화 반영을 취소하시겠습니까?'
          '1'
          GV_ANSWER.
  IF GV_ANSWER = '1'.
    PERFORM CANCEL_ZNFT1051_DATA.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " EXCHANGE_RATE
*&---------------------------------------------------------------------*
*&      Form  CANCEL_ZNFT1051_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANCEL_ZNFT1051_DATA .
  DATA: LV_NFUTN    LIKE ZNFT1051-NFUTN,
        LV_CFUTN    LIKE ZNFT1051-CFUTN,
        LV_FLAG.

  CLEAR   : GT_1052.
  REFRESH : GT_1052.

  LOOP AT GT_DETL.
    IF GT_DETL-NBY_SL = 'B'.
      LV_NFUTN = GT_DETL-BFUTN.
      LV_CFUTN = GT_DETL-SFUTN.
    ELSE.
      LV_NFUTN = GT_DETL-SFUTN.
      LV_CFUTN = GT_DETL-BFUTN.
    ENDIF.

    READ TABLE GT_1051 WITH KEY NFUTN = LV_NFUTN
                                CFUTN = LV_CFUTN.
    IF SY-SUBRC = 0.
      CLEAR : GT_1051-KURSF, GT_1051-WWERT,
              GT_1051-KPRLO, GT_1051-KAERS.

      GT_1051-AEDAT = SY-DATLO.
      GT_1051-AEZET = SY-TIMLO.
      GT_1051-AENAM = SY-UNAME.

      MODIFY GT_1051 INDEX SY-TABIX.
    ELSE.
      MESSAGE E003 WITH 'Internal Error!(GT_1051)'.
    ENDIF.

    CLEAR : GT_1052.

    GT_1052-FCM   = GT_1051-FCM.
    GT_1052-ENDAT = GT_1051-ENDAT.
    GT_1052-PRCTR = GT_1051-PRCTR.
    GT_1052-VKGRP = GT_1051-VKGRP.
    GT_1052-KUNNR = GT_1051-KUNNR.

    COLLECT GT_1052.
  ENDLOOP.

  MODIFY ZNFT1051 FROM TABLE GT_1051.
  IF SY-SUBRC = 0.
    DELETE ZNFT1052 FROM TABLE GT_1052.
    IF SY-SUBRC = 0.
      PERFORM UPDATE_PROCESSING_STATUS USING LV_FLAG.

      IF LV_FLAG IS INITIAL.
        COMMIT WORK.

        MESSAGE S003 WITH '선물손익 원화 반영이 취소 되었습니다.'.

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
         WITH '선물손익 원화반영 집계 데이터 삭제 Error!'.
    ENDIF.
  ELSE.
    ROLLBACK WORK.

    MESSAGE I003 DISPLAY LIKE 'E'
       WITH '선물손익 원화 반영 데이터 삭제 Error!'.
  ENDIF.

ENDFORM.                    " CANCEL_ZNFT1051_DATA
*&---------------------------------------------------------------------*
*&      Form  CALC_CHARGE_AMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALC_CHARGE_AMOUNT USING PV_LIFNR
                              PV_WRBTR
                              PV_FEE.
  DATA: LV_FEERT1   LIKE ZNFT0021-FEERT1,
        LV_FEERT2   LIKE ZNFT0021-FEERT2.

  CLEAR : LV_FEERT1, LV_FEERT2.

  SELECT SINGLE FEERT1    "수수료율-분자
                FEERT2    "수수료율-분모
    INTO (LV_FEERT1, LV_FEERT2)
    FROM ZNFT0021
   WHERE BUKRS = P_BUKRS
     AND LIFNR = PV_LIFNR.

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
    IF GT_DETL-PRCTR IS INITIAL.
      CONCATENATE GT_DETL-MESSAGE
                  '/손익센터 누락'
             INTO GT_DETL-MESSAGE.
    ENDIF.

    IF GT_DETL-CONFM <> '3' AND GT_DETL-CONFM <> '7'.
      CONCATENATE GT_DETL-MESSAGE
                  '/신규결재상태 오류'
             INTO GT_DETL-MESSAGE.
    ENDIF.

    IF GT_DETL-CONFM1 <> '3' AND GT_DETL-CONFM1 <> '7'.
      CONCATENATE GT_DETL-MESSAGE
                  '/청산결재상태 오류'
             INTO GT_DETL-MESSAGE.
    ENDIF.

    IF GT_DETL-YNCAN IS NOT INITIAL.
      CONCATENATE GT_DETL-MESSAGE
                  '/신규취소상태 오류'
             INTO GT_DETL-MESSAGE.
    ENDIF.

    IF GT_DETL-YNCAN1 IS NOT INITIAL.
      CONCATENATE GT_DETL-MESSAGE
                  '/청산취소상태 오류'
             INTO GT_DETL-MESSAGE.
    ENDIF.

    IF GT_DETL-YNFIN IS INITIAL.
      CONCATENATE GT_DETL-MESSAGE
                  '/신규정산상태 오류'
             INTO GT_DETL-MESSAGE.
    ENDIF.

    IF GT_DETL-YNFIN1 IS INITIAL.
      CONCATENATE GT_DETL-MESSAGE
                  '/청산정산상태 오류'
             INTO GT_DETL-MESSAGE.
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

      WHEN 'BFUTN' OR 'SFUTN'.
        PERFORM DISPLAY_FUTRUES_HISTORY USING PS_COLUMN-FIELDNAME.

    ENDCASE.
  ENDIF.

ENDFORM.                    " DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  F4HELP_DATUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F4HELP_DATUM .
  DATA: LT_TCURR    LIKE TCURR OCCURS 0 WITH HEADER LINE.

  DATA: LV_DATUM    LIKE SY-DATUM,
        LV_GDATU    LIKE TCURR-GDATU,
        LV_GDATC(10).

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_EXCH, LT_TCURR.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_EXCH, LT_TCURR.

  LV_DATUM = SY-DATLO - 30.

  CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'
    EXPORTING
      INPUT  = LV_DATUM
    IMPORTING
      OUTPUT = LV_GDATU.

  SELECT *
    INTO TABLE LT_TCURR
    FROM TCURR               "환율
   WHERE KURST  = 'M'        "환율유형
     AND FCURR  = 'USD'      "원시통화
     AND TCURR  = 'KRW'      "대상통화
     AND GDATU <= LV_GDATU.  "환율 효력발생일-환산일

  IF SY-SUBRC <> 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '환율정보를 찾지 못했습니다.'.
    EXIT.
  ENDIF.

  LOOP AT LT_TCURR.
    CLEAR : GT_EXCH.

    CALL FUNCTION 'CONVERSION_EXIT_INVDT_OUTPUT'
      EXPORTING
        INPUT  = LT_TCURR-GDATU
      IMPORTING
        OUTPUT = LV_GDATC.

    REPLACE ALL OCCURRENCES OF : '.' IN LV_GDATC WITH '',
                                 '/' IN LV_GDATC WITH '',
                                 '-' IN LV_GDATC WITH ''.

    CONDENSE LV_GDATC NO-GAPS.

    GT_EXCH-WWERT = LV_GDATC.

    WRITE LT_TCURR-UKURS TO GT_EXCH-KURSF.

    APPEND GT_EXCH.
  ENDLOOP.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZNFT1051'.
  IT_FIELDS-FIELDNAME  = 'WWERT'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'E1EDK23'.
  IT_FIELDS-FIELDNAME  = 'KURS'.   "환율
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
      FULL_TABLE                   = GT_EXCH
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_EXCH INDEX LD_TABIX.
  IF SY-SUBRC = 0.
*___아래 부분이 선택된 값들을 화면 필드에 뿌려준다.
    SCR_FIELDS-FIELDNAME  = 'GV_DATUM'.
    SCR_FIELDS-FIELDVALUE = GT_EXCH-WWERT.
    APPEND SCR_FIELDS.

    SCR_FIELDS-FIELDNAME  = 'GV_UKURS'.
    SCR_FIELDS-FIELDVALUE = GT_EXCH-KURSF.
    APPEND SCR_FIELDS.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME               = SY-CPROG
        DYNUMB               = SY-DYNNR
      TABLES
        DYNPFIELDS           = SCR_FIELDS
      EXCEPTIONS
        INVALID_ABAPWORKAREA = 1
        INVALID_DYNPROFIELD  = 2
        INVALID_DYNPRONAME   = 3
        INVALID_DYNPRONUMMER = 4
        INVALID_REQUEST      = 5
        NO_FIELDDESCRIPTION  = 6
        UNDEFIND_ERROR       = 7
        OTHERS               = 8.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDFORM.                    " F4HELP_DATUM
*&---------------------------------------------------------------------*
*&      Form  GET_EXCHANGE_RATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_EXCHANGE_RATE .
  DATA: LV_GDATU    LIKE TCURR-GDATU.

  CLEAR : GV_UKURS.

  CHECK GV_DATUM IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'
    EXPORTING
      INPUT  = GV_DATUM
    IMPORTING
      OUTPUT = LV_GDATU.

  SELECT SINGLE UKURS
    INTO GV_UKURS
    FROM TCURR              "환율
   WHERE KURST = 'M'        "환율유형
     AND FCURR = 'USD'      "원시통화
     AND TCURR = 'KRW'      "대상통화
     AND GDATU = LV_GDATU.  "환율 효력발생일-환산일

  IF SY-SUBRC <> 0.
    MESSAGE E003 WITH '해당일자의 환율정보를 찾지 못했습니다.'.
  ENDIF.

ENDFORM.                    " GET_EXCHANGE_RATE
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

  IF ( PV_FNAME = 'BFUTN' AND GT_DETL-NBY_SL = 'B' ) OR
     ( PV_FNAME = 'SFUTN' AND GT_DETL-NBY_SL = 'S' ).
    LT_RSPAR-SELNAME = 'S_NFUTN'.
    LT_RSPAR-KIND    = 'S'.
    LT_RSPAR-SIGN    = 'I'.
    LT_RSPAR-OPTION  = 'EQ'.

    IF GT_DETL-NBY_SL = 'B'.
      LT_RSPAR-LOW     = GT_DETL-BFUTN.
    ELSE.
      LT_RSPAR-LOW     = GT_DETL-SFUTN.
    ENDIF.

    APPEND LT_RSPAR.

    APPEND_PARAM : LT_RSPAR 'P_CHK11' 'P' ' ' ' '  'X'           ' ',
                   LT_RSPAR 'P_CHK12' 'P' ' ' ' '  ' '           ' '.
  ELSE.
    LT_RSPAR-SELNAME = 'S_CFUTN'.
    LT_RSPAR-KIND    = 'S'.
    LT_RSPAR-SIGN    = 'I'.
    LT_RSPAR-OPTION  = 'EQ'.

    IF GT_DETL-NBY_SL = 'B'.
      LT_RSPAR-LOW     = GT_DETL-SFUTN.
    ELSE.
      LT_RSPAR-LOW     = GT_DETL-BFUTN.
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

  CLEAR   : GT_1050.
  REFRESH : GT_1050.

*___정산진행상태
  SELECT *
    INTO TABLE GT_1050
    FROM ZNFT1050
   WHERE BUKRS = P_BUKRS
     AND ENDAT BETWEEN GV_FRDAT AND GV_TODAT.

  LOOP AT GT_MAIN.
*___FCM 명
    PERFORM GET_LIFNR_DESC USING GT_MAIN-FCM
                                 GT_MAIN-NAME1.

*___정산진행상태
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
