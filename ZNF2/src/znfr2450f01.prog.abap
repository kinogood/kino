*&---------------------------------------------------------------------*
*&  Include           ZNFR2450F01
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

  CLEAR   : GT_MAIN, GT_1052.
  REFRESH : GT_MAIN, GT_1052.

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
*&      Form  GET_CONFIRM_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CONFIRM_DATA .
  DATA: LV_TABIX LIKE SY-TABIX,
        LV_FLAG.

*___선물손익 원화 확정 데이터
  SELECT *
    INTO TABLE GT_1052
    FROM ZNFT1052
   WHERE BUKRS = P_BUKRS
     AND ENDAT BETWEEN GV_FRDAT AND GV_TODAT.

  SORT GT_1052 BY FCM ENDAT.

  CLEAR : LV_FLAG.

  LOOP AT GT_1052.
    AT NEW ENDAT.
      LV_FLAG = 'X'.
    ENDAT.

    IF LV_FLAG = 'X'.
      CLEAR : GT_MAIN, LV_FLAG.

      GT_MAIN-BUKRS = GT_1052-BUKRS.     "회사코드
      GT_MAIN-ENDAT = GT_1052-ENDAT.     "만기일
      GT_MAIN-FCM   = GT_1052-FCM.       "FCM
      GT_MAIN-KURSF = GT_1052-KURSF.     "환율
      GT_MAIN-WWERT = GT_1052-WWERT.     "환산일
      GT_MAIN-BELNR = GT_1052-BELNR.     "회계전표
      GT_MAIN-GJAHR = GT_1052-GJAHR.     "회계년도

      GT_MAIN-BELNR_S = GT_1052-BELNR_S.  "회계전표(수수료) [CHM2410-00483]
      GT_MAIN-GJAHR_S = GT_1052-GJAHR_S.  "회계년도(수수료) [CHM2410-00483]

      APPEND GT_MAIN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_CONFIRM_DATA
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
*  GS_LAYOUT-EDIT       = 'X'.
*  GS_LAYOUT-CWIDTH_OPT = 'X'.
  GS_LAYOUT-ZEBRA      = 'X'.
  GS_LAYOUT-SMALLTITLE = 'X'.
  GS_LAYOUT-SEL_MODE   = 'A'.              "select multiple lines
*  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
*  GS_LAYOUT-CTAB_FNAME = 'F_COL'.

  IF SY-DYNNR = '0100'.
    GS_LAYOUT-BOX_FNAME  = 'CHECK'.
  ELSE.
    GS_LAYOUT-NO_ROWMARK = 'X'.
    GS_LAYOUT-CWIDTH_OPT = 'X'.
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
      ' '              'BUKRS' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '              'ENDAT' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'FCM'      ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '              'FCM'   'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'NAME1'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 35
      'FCM 명'         ' '     ' '        ' ' ' '    'X' ' ' ' ' ' ',

      'KURSF'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 10
      ' '              'KURSF' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'WWERT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'WWERT' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'NCCHK'    ' '      ' '     'X' ' ' 'C' ' '    ' ' ' ' ' ' 8
      '오류확인'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'NETIG'    ' '      ' '     'X' ' ' 'C' ' '    ' ' ' ' ' ' 8
      '넷팅생성'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'CONFM'    ' '      ' '     'X' ' ' 'C' ' '    ' ' ' ' ' ' 8
      '손익확정'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'TRWON'    ' '      ' '     'X' ' ' 'C' ' '    ' ' ' ' ' ' 8
      '원화환산'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'CREFI'    ' '      ' '     'X' ' ' 'C' ' '    ' ' ' ' ' ' 8
      '전표생성'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'BELNR'    ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 10
      '전표번호'          'BELNR' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'GJAHR'    ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 4
      '연도'              'GJAHR' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

*--> [CHM2410-00483] 정산금/수수료 분리
      'BELNR_S'  ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 10
      '전표 번호(수수료)' 'BELNR' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'GJAHR_S'  ' '      ' '     ' ' ' ' 'C' ' '    ' ' ' ' ' ' 4
      '연도(수수료)'      'GJAHR' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' '.
*<-- [CHM2410-00483] 정산금/수수료 분리

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
      'BUKRS'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      ' '              'BUKRS' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'GJAHR'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      ' '              'GJAHR' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'BELNR'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '              'BELNR' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'ZTYPE'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      '구분'           'NAME1' 'LFA1'     ' ' ' '    'X' ' ' ' ' ' ',

      'FCM'      ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'FCM'   'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'NAMLF'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      'FCM 명'         'NAME1' 'LFA1'     ' ' ' '    'X' ' ' ' ' ' ',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'ENDAT' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'PRCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'PRCTR' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'PTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'PTEXT' 'ZNFT0004' ' ' ' '    'X' ' ' ' ' ' ',

      'VKGRP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'VKGRP' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'VTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'VTEXT' 'ZNFT0003' ' ' ' '    'X' ' ' ' ' ' ',

      'KUNNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'KUNNR' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'NAMAG'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      '고객명'         'NAME1' 'KNA1'     ' ' ' '    'X' ' ' ' ' ' ',

      'B_SUM'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '              'B_SUM' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

      'B_FEE'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '              'B_FEE' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

      'S_SUM'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '              'S_SUM' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

      'S_FEE'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '              'S_FEE' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

      'UPRLO'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'UPRLO' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

      'UPRLO_B'  'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '정산금(USD)'    'UPRLO_B' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

      'UPRLO_S'  'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '수수료(USD)'    'UPRLO_S' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

      'UAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'UAERS' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'WWERT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'WWERT' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'KURSF'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'KURSF' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'KPRLO'    'KAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'KPRLO' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

      'KPRLO_B'    'KAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '정산금(KRW)'    'KPRLO_B' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

      'KPRLO_S'    'KAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '수수료(KRW)'    'KPRLO_S' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

      'KAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'KAERS' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'AENAM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 12
      '전표생성인'     'AENAM' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'AEDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '전표생성일'     'AEDAT' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'AEZET'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 8
      '전표생성시간'   'AEZET' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' '.

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

  IF SY-DYNNR = '0200' AND GS_FIELDCAT-FIELDNAME <> 'CHECK' AND
     GS_FIELDCAT-FIELDNAME <> 'KPRLO'.
    IF PV_FIX = 'X'.
      GS_FIELDCAT-STYLE = '00000002'.
    ELSE.
*      GS_FIELDCAT-STYLE = '00000002'.
    ENDIF.
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

  CALL SCREEN 0200.

ENDFORM.                    " DISPLAY_SELECTED_DATA
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

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택된 라인이 없습니다.'.
  ELSEIF LV_CNT > 1.
    GV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '한 라인만 선택하시기 바랍니다.'.
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
                              CREFI = '@5C@'.
  IF SY-SUBRC = 0.
    GV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '전표생성되지 않은 건이 선택되었습니다.'.
    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_PROCESSING_STATUS
*&---------------------------------------------------------------------*
*&      Form  GET_DETAIL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DETAIL_DATA .

  CLEAR   : GT_DETL.
  REFRESH : GT_DETL.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    LOOP AT GT_1052 WHERE FCM   = GT_MAIN-FCM
                      AND BELNR = GT_MAIN-BELNR
                      AND GJAHR = GT_MAIN-GJAHR.
      CLEAR : GT_DETL.

      MOVE-CORRESPONDING GT_1052 TO GT_DETL.

*___FCM 명
      PERFORM GET_LIFNR_DESC USING GT_DETL-FCM
                                   GT_DETL-NAMLF.

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
                                   GT_DETL-NAMAG.

      IF GT_1052-BELNR_S IS INITIAL.
        GT_DETL-ZTYPE = '손익'.
      ELSE.
        GT_DETL-ZTYPE = '정산금'.
      ENDIF.
      APPEND GT_DETL.
    ENDLOOP.
  ENDLOOP.

*--> [CHM2410-00483] 수수료 전표 추가
  LOOP AT GT_MAIN WHERE CHECK = 'X'
                     AND BELNR_S <> ' '.
    LOOP AT GT_1052 WHERE FCM   = GT_MAIN-FCM
                      AND BELNR_S = GT_MAIN-BELNR_S
                      AND GJAHR_S = GT_MAIN-GJAHR_S.
      CLEAR : GT_DETL.

      MOVE-CORRESPONDING GT_1052 TO GT_DETL.
      MOVE : GT_1052-BELNR_S TO GT_DETL-BELNR.
      MOVE : GT_1052-GJAHR_S TO GT_DETL-GJAHR.

*___FCM 명
      PERFORM GET_LIFNR_DESC USING GT_DETL-FCM
                                   GT_DETL-NAMLF.

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
                                   GT_DETL-NAMAG.

      GT_DETL-ZTYPE = '수수료'.
      APPEND GT_DETL.
    ENDLOOP.
  ENDLOOP.
*<-- [CHM2410-00483] 수수료 전표 추가

ENDFORM.                    " GET_DETAIL_DATA
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
*&      Form  REVERSE_FI_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REVERSE_FI_DOC.
  DATA: LV_TEXT(100).
  DATA: LV_CNT TYPE I.

*  LOOP AT GT_MAIN TRANSPORTING NO FIELDS
*                  WHERE ENDAT <> GT_MAIN-ENDAT
*                    AND FCM   =  GT_MAIN-FCM
*                    AND BELNR =  GT_MAIN-BELNR
*                    AND GJAHR =  GT_MAIN-GJAHR.
*    EXIT.
*  ENDLOOP.
*
*  IF SY-SUBRC = 0.
*    CONCATENATE '전표번호가 동일한 건들은 모두 역분개됩니다.'
*                '계속하시겠습니까?'
*           INTO LV_TEXT SEPARATED BY SPACE.
*  ELSE.
*    LV_TEXT = '선물손익 전표를 역분개 하시겠습니까?'.
*  ENDIF.
*
*  IF SY-SUBRC = 0.
*    CONCATENATE '전표번호가 동일한 건들은 모두 역분개됩니다.'
*                '계속하시겠습니까?'
*           INTO LV_TEXT SEPARATED BY SPACE.
*  ELSE.
*    LV_TEXT = '선물손익 전표를 역분개 하시겠습니까?'.
*  ENDIF.

*--> [CHM2410-00483] 정산금/수수료 분리
  LV_CNT = 0.
  LOOP AT GT_MAIN TRANSPORTING NO FIELDS
                  WHERE ENDAT <> GT_MAIN-ENDAT
                    AND FCM   =  GT_MAIN-FCM
                    AND BELNR =  GT_MAIN-BELNR
                    AND GJAHR =  GT_MAIN-GJAHR.
    LV_CNT = LV_CNT + 1.
    EXIT.
  ENDLOOP.
  IF GT_MAIN-BELNR_S IS NOT INITIAL.
    LOOP AT GT_MAIN TRANSPORTING NO FIELDS
                    WHERE ENDAT <> GT_MAIN-ENDAT
                      AND FCM   =  GT_MAIN-FCM
                      AND BELNR_S =  GT_MAIN-BELNR_S
                      AND GJAHR_S =  GT_MAIN-GJAHR_S.
      LV_CNT = LV_CNT + 1.
      EXIT.
    ENDLOOP.
  ENDIF.

  IF LV_CNT > 0.
    CONCATENATE '전표번호가 동일한 건들은 모두 역분개됩니다.'
                '계속하시겠습니까?'
           INTO LV_TEXT SEPARATED BY SPACE.
  ELSE.
    LV_TEXT = '선물손익 전표를 역분개 하시겠습니까?'.
  ENDIF.
*<-- [CHM2410-00483] 정산금/수수료 분리

  PERFORM POPUP_TO_CONFIRM USING '확인'
                                 LV_TEXT
                                 '2'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.

    PERFORM CANCEL_FI_DOC.
    CHECK GV_ERROR IS INITIAL.

    IF GT_MAIN-BELNR_S IS NOT INITIAL.
      PERFORM CANCEL_FI_DOC_BS.
    ENDIF.

    CHECK GV_ERROR IS INITIAL.

*    PERFORM UPDATE_RESULT.
    PERFORM UPDATE_RESULT_BS.

    PERFORM GET_SETTLEMENT_DATA.

    LEAVE TO SCREEN 0.

  ELSE.
    MESSAGE S007.
  ENDIF.

ENDFORM.                    " REVERSE_FI_DOC
*&---------------------------------------------------------------------*
*&      Form  DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DYNPRO  USING  PV_DYNBEGIN
                    PV_FNAM
                    PV_FVAL.

  CLEAR : GT_BDCTAB.

  IF  PV_DYNBEGIN =  'X'.
    GT_BDCTAB-DYNBEGIN  =  'X'.
    GT_BDCTAB-PROGRAM   =  PV_FNAM.
    GT_BDCTAB-DYNPRO    =  PV_FVAL.
    APPEND GT_BDCTAB.
  ELSE.
    GT_BDCTAB-FNAM      =  PV_FNAM.
    GT_BDCTAB-FVAL      =  PV_FVAL.
    APPEND GT_BDCTAB.
  ENDIF.

ENDFORM.                    " DYNPRO
*&---------------------------------------------------------------------*
*&      Form  UPDATE_RESULT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_RESULT .
  DATA: LV_FLAG.

*___선물손익 확정 데이터 Update
  UPDATE ZNFT1051 SET BELNR = ' '
                      GJAHR = '0000'
                      AENAM = SY-UNAME
                      AEDAT = SY-DATLO
                      AEZET = SY-TIMLO
                WHERE BUKRS = GT_MAIN-BUKRS
                  AND FCM   = GT_MAIN-FCM
                  AND BELNR = GT_MAIN-BELNR
                  AND GJAHR = GT_MAIN-GJAHR.

  IF SY-SUBRC = 0.
    UPDATE ZNFT1052 SET GJAHR = '0000'
                        BELNR = ' '
                        AEDAT = SY-DATLO
                        AEZET = SY-TIMLO
                        AENAM = SY-UNAME
                  WHERE FCM   = GT_MAIN-FCM
                    AND BUKRS = GT_MAIN-BUKRS
                    AND GJAHR = GT_MAIN-GJAHR
                    AND BELNR = GT_MAIN-BELNR.

    IF SY-SUBRC = 0.
      PERFORM UPDATE_PROCESSING_STATUS USING LV_FLAG.
      IF LV_FLAG IS INITIAL.
        COMMIT WORK.

        MESSAGE S003 WITH '선물손익전표'
                          GT_MAIN-BELNR
                          '이(가) 역분개되었습니다. 역분개전표:'
                          GV_BELNR.
      ELSE.
        ROLLBACK WORK.

        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '정산진행상태 저장 에러!'.
      ENDIF.
    ELSE.
      ROLLBACK WORK.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '선물손익 정산 테이블 Update Error!'.
    ENDIF.
  ELSE.
    ROLLBACK WORK.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선물손익 확정 테이블 Update Error!'.
  ENDIF.

ENDFORM.                    " UPDATE_RESULT
*&---------------------------------------------------------------------*
*&      Form  CANCEL_FI_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANCEL_FI_DOC .

  CLEAR   : GT_BDCTAB, GT_RETMSG, GV_BELNR, GV_ERROR.
  REFRESH : GT_BDCTAB, GT_RETMSG.

  PERFORM DYNPRO USING :
                 'X' 'SAPMF05A'          '0105',
                 ' ' 'BDC_OKCODE'        '=BU',
                 ' ' 'RF05A-BELNS'       GT_MAIN-BELNR,
                 ' ' 'BKPF-BUKRS'        GT_MAIN-BUKRS,
                 ' ' 'RF05A-GJAHS'       GT_MAIN-GJAHR,
                 ' ' 'UF05A-STGRD'       '01'.

  CLEAR : CTU_PARAMS.

  CTU_PARAMS-DISMODE  =  'N'.
  CTU_PARAMS-UPDMODE  =  'S'.
*  CTU_PARAMS-DEFSIZE  =  'X'.
  CTU_PARAMS-RACOMMIT =  'X'.

  CALL TRANSACTION 'FB08' USING         GT_BDCTAB
                          OPTIONS  FROM CTU_PARAMS
                          MESSAGES INTO GT_RETMSG.

  READ TABLE GT_RETMSG WITH KEY MSGTYP = 'S'
                                MSGID  = 'F5'
                                MSGNR  = '312'.
  IF SY-SUBRC = 0.
    GV_BELNR = GT_RETMSG-MSGV1.
  ELSE.
    GV_ERROR = 'X'.

    READ TABLE GT_RETMSG WITH KEY MSGTYP = 'A'.
    IF SY-SUBRC <> 0.
      READ TABLE GT_RETMSG WITH KEY MSGTYP = 'E'.
      IF SY-SUBRC <> 0.
        READ TABLE GT_RETMSG WITH KEY MSGTYP = 'W'.
        IF SY-SUBRC <> 0.
          READ TABLE GT_RETMSG WITH KEY MSGTYP = 'I'.
          IF SY-SUBRC <> 0.
            READ TABLE GT_RETMSG INDEX 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF SY-SUBRC = 0.
      MESSAGE ID     GT_RETMSG-MSGID
              TYPE   'S'
              NUMBER GT_RETMSG-MSGNR
              WITH   GT_RETMSG-MSGV1
                     GT_RETMSG-MSGV2
                     GT_RETMSG-MSGV3
                     GT_RETMSG-MSGV4
              DISPLAY LIKE GT_RETMSG-MSGTYP.
    ENDIF.
  ENDIF.

ENDFORM.                    " CANCEL_FI_DOC
*&---------------------------------------------------------------------*
*&      Form  UPDATE_PROCESSING_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPDATE_PROCESSING_STATUS  USING    PV_FLAG.
  DATA: LV_ENDAT LIKE ZNFT1050-ENDAT,
        LS_MAIN  LIKE GT_MAIN.

  CLEAR : PV_FLAG.

  LOOP AT GT_MAIN INTO LS_MAIN
                  WHERE BUKRS = GT_MAIN-BUKRS
                    AND FCM   = GT_MAIN-FCM
                    AND BELNR = GT_MAIN-BELNR
                    AND GJAHR = GT_MAIN-GJAHR.
    UPDATE ZNFT1050 SET CREFI = ' '
                        AENAM = SY-UNAME
                        AEDAT = SY-DATLO
                        AEZET = SY-TIMLO
                  WHERE BUKRS = GT_MAIN-BUKRS
                    AND ENDAT = LS_MAIN-ENDAT
                    AND FCM   = GT_MAIN-FCM.
    IF SY-SUBRC <> 0.
      PV_FLAG = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " UPDATE_PROCESSING_STATUS
*&---------------------------------------------------------------------*
*&      Form  DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING  PV_FLAG
                          PS_ROW    TYPE LVC_S_ROW
                          PS_COLUMN TYPE LVC_S_COL.

  IF PV_FLAG = '1'.
    READ TABLE GT_MAIN INDEX PS_ROW-INDEX.
    IF SY-SUBRC = 0.
      CASE PS_COLUMN-FIELDNAME.
        WHEN 'BELNR' OR 'GJAHR'.
          IF GT_MAIN-BELNR IS NOT INITIAL.
            SET PARAMETER ID 'BLN' FIELD GT_MAIN-BELNR.
            SET PARAMETER ID 'BUK' FIELD GT_MAIN-BUKRS.
            SET PARAMETER ID 'GJR' FIELD GT_MAIN-GJAHR.

            CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
          ENDIF.

      ENDCASE.
    ENDIF.
  ELSE.
    READ TABLE GT_DETL INDEX PS_ROW-INDEX.
    IF SY-SUBRC = 0.
      CASE PS_COLUMN-FIELDNAME.
        WHEN 'BELNR' OR 'GJAHR'.
          IF GT_DETL-BELNR IS NOT INITIAL.
            SET PARAMETER ID 'BLN' FIELD GT_DETL-BELNR.
            SET PARAMETER ID 'BUK' FIELD GT_DETL-BUKRS.
            SET PARAMETER ID 'GJR' FIELD GT_DETL-GJAHR.

            CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
          ENDIF.

      ENDCASE.
    ENDIF.
  ENDIF.

ENDFORM.                    " DOUBLE_CLICK
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
*&---------------------------------------------------------------------*
*& Form CANCEL_FI_DOC_BS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CANCEL_FI_DOC_BS .

  " 수수료
  CLEAR   : GT_BDCTAB, GT_RETMSG, GV_BELNR_S, GV_ERROR.
  REFRESH : GT_BDCTAB, GT_RETMSG.

  PERFORM DYNPRO USING :
                 'X' 'SAPMF05A'          '0105',
                 ' ' 'BDC_OKCODE'        '=BU',
                 ' ' 'RF05A-BELNS'       GT_MAIN-BELNR_S,
                 ' ' 'BKPF-BUKRS'        GT_MAIN-BUKRS,
                 ' ' 'RF05A-GJAHS'       GT_MAIN-GJAHR_S,
                 ' ' 'UF05A-STGRD'       '01'.

  CLEAR : CTU_PARAMS.

  CTU_PARAMS-DISMODE  =  'N'.
  CTU_PARAMS-UPDMODE  =  'S'.
*  CTU_PARAMS-DEFSIZE  =  'X'.
  CTU_PARAMS-RACOMMIT =  'X'.

  CALL TRANSACTION 'FB08' USING         GT_BDCTAB
                          OPTIONS  FROM CTU_PARAMS
                          MESSAGES INTO GT_RETMSG.

  READ TABLE GT_RETMSG WITH KEY MSGTYP = 'S'
                                MSGID  = 'F5'
                                MSGNR  = '312'.
  IF SY-SUBRC = 0.
    GV_BELNR_S = GT_RETMSG-MSGV1.
  ELSE.
    GV_ERROR = 'X'.

    READ TABLE GT_RETMSG WITH KEY MSGTYP = 'A'.
    IF SY-SUBRC <> 0.
      READ TABLE GT_RETMSG WITH KEY MSGTYP = 'E'.
      IF SY-SUBRC <> 0.
        READ TABLE GT_RETMSG WITH KEY MSGTYP = 'W'.
        IF SY-SUBRC <> 0.
          READ TABLE GT_RETMSG WITH KEY MSGTYP = 'I'.
          IF SY-SUBRC <> 0.
            READ TABLE GT_RETMSG INDEX 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF SY-SUBRC = 0.
      MESSAGE ID     GT_RETMSG-MSGID
              TYPE   'S'
              NUMBER GT_RETMSG-MSGNR
              WITH   GT_RETMSG-MSGV1
                     GT_RETMSG-MSGV2
                     GT_RETMSG-MSGV3
                     GT_RETMSG-MSGV4
              DISPLAY LIKE GT_RETMSG-MSGTYP.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_RESULT_BS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM UPDATE_RESULT_BS .

  DATA: LV_FLAG.
  DATA: LV_TEXT(100).

*___선물손익 확정 데이터 Update
  UPDATE ZNFT1051 SET BELNR = ' '
                      GJAHR = '0000'
                      AENAM = SY-UNAME
                      AEDAT = SY-DATLO
                      AEZET = SY-TIMLO
                WHERE BUKRS = GT_MAIN-BUKRS
                  AND FCM   = GT_MAIN-FCM
                  AND BELNR = GT_MAIN-BELNR
                  AND GJAHR = GT_MAIN-GJAHR.

  IF SY-SUBRC = 0.
    " 수수료전표 GV_BELNR_S 존재 시 반영
    IF GV_BELNR_S IS INITIAL.
      UPDATE ZNFT1052 SET GJAHR = '0000'
                          BELNR = ' '
                          AEDAT = SY-DATLO
                          AEZET = SY-TIMLO
                          AENAM = SY-UNAME
                    WHERE FCM   = GT_MAIN-FCM
                      AND BUKRS = GT_MAIN-BUKRS
                      AND GJAHR = GT_MAIN-GJAHR
                      AND BELNR = GT_MAIN-BELNR.
    ELSE.
      UPDATE ZNFT1052 SET GJAHR = '0000'
                          BELNR = ' '
                          GJAHR_S = '0000'
                          BELNR_S = ' '
                          AEDAT = SY-DATLO
                          AEZET = SY-TIMLO
                          AENAM = SY-UNAME
                    WHERE FCM   = GT_MAIN-FCM
                      AND BUKRS = GT_MAIN-BUKRS
                      AND GJAHR = GT_MAIN-GJAHR
                      AND BELNR = GT_MAIN-BELNR
                      AND GJAHR_S = GT_MAIN-GJAHR_S
                      AND BELNR_S = GT_MAIN-BELNR_S.
    ENDIF.

    IF SY-SUBRC = 0.
      PERFORM UPDATE_PROCESSING_STATUS USING LV_FLAG.
      IF LV_FLAG IS INITIAL.
        COMMIT WORK.
        " 수수료전표 GV_BELNR_S 존재 시 메시지 수정
        IF GV_BELNR_S IS INITIAL.
          MESSAGE S003 WITH '선물손익전표'
                            GT_MAIN-BELNR
                            '이(가) 역분개되었습니다. 역분개전표:'
                            GV_BELNR.
        ELSE.
          CONCATENATE '정산금역분개' GV_BELNR
                      ', 수수료역분개' GV_BELNR_S
                      '전표 생성 완료' INTO LV_TEXT SEPARATED BY SPACE.
          MESSAGE S003 WITH LV_TEXT.
        ENDIF.
      ELSE.
        ROLLBACK WORK.

        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '정산진행상태 저장 에러!'.
      ENDIF.
    ELSE.
      ROLLBACK WORK.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '선물손익 정산 테이블 Update Error!'.
    ENDIF.
  ELSE.
    ROLLBACK WORK.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선물손익 확정 테이블 Update Error!'.
  ENDIF.

ENDFORM.
