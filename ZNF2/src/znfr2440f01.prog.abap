*&---------------------------------------------------------------------*
*&  Include           ZNFR2440F01
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

  GV_ITAB = 'GT_HEAD'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT
                                  USING :
      'CHECK'    ' '      ' '     ' ' 'X' ' ' ' '    'X' ' ' ' ' 4
      '선택'           ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' 'X',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '              'ENDAT' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'PRCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '              'PRCTR' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'PTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '손익센터명'     ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'VKGRP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'VKGRP' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'VTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '영업그룹명'     ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'KUNNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '              'KUNNR' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'NAME1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '고객명'         ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'B_SUM'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 10
      ' '              'B_SUM' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

      'B_FEE'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 10
      ' '              'B_FEE' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

      'S_SUM'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'S_SUM' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

      'S_FEE'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'S_FEE' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

      'UPRLO'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'UPRLO' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

*--> [CHM2410-00483] 신규 필드 추가 - 20241210
      'UPRLO_B'   'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '정산금손익(USD)' 'UPRLO' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

      'UPRLO_S'   'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '수수료손익(USD)' 'UPRLO' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',
*<-- [CHM2410-00483] 신규 필드 추가 - 20241210

      'UAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'UAERS' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' ',

      'KPRLO'    'KAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'KPRLO' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

*--> [CHM2410-00483] 신규 필드 추가 - 20241210
      'KPRLO_B'  'KAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '정산금손익(KRW)' 'KPRLO' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

      'KPRLO_S'  'KAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '수수료손익(KRW)' 'KPRLO' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

*<-- [CHM2410-00483] 신규 필드 추가 - 20241210


      'KAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'KAERS' 'ZNFT1052' ' ' ' '    'X' ' ' ' ' ' '.

  CLEAR   : GS_FIELDCAT, GV_POS.
  REFRESH : GT_FIELDCAT2.

  GV_ITAB = 'GT_ITEM'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT2
                                  USING :
      'BFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      '매입집행번호'   'NFUTN' 'ZNFT1051' ' ' ' '    'X' ' ' ' ' ' ',

      'SFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      '매각집행번호'   'NFUTN' 'ZNFT1051' ' ' ' '    'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 2
      ' '              'NFKEY' 'ZNFT1051' ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 10
      ' '              'EMENG' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'MEINS' 'ZNFT1051' ' ' ' '    'X' ' ' ' ' ' ',

      'BYPRC'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 10
      'Buy 단가'      'NPRICE' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'BYSPD'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 10
      'Buy Spread'    'NMISPD' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'BYAMT'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      'Buy 총액'      'NPRICE' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'BYFEE'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      'Buy 수수료'     'N_FEE' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'SLPRC'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 10
      'Sell 단가'     'NPRICE' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'SLSPD'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 10
      'Sell Spread'   'NMISPD' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'SLAMT'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      'Sell 총액'     'NPRICE' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'SLFEE'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      'Sell 수수료'    'N_FEE' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'UPRLO'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'UPRLO' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',
*--> [CHM2410-00483] 신규 필드 추가 - 20241210
      'UPRLO_B'   'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '정산금손익(USD)' 'UPRLO' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',

      'UPRLO_S'   'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '수수료손익(USD)' 'UPRLO' 'ZNFT1052' ' ' ' '    ' ' ' ' ' ' ' ',
*<-- [CHM2410-00483] 신규 필드 추가 - 20241210

      'UAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'UAERS' 'ZNFT1051' ' ' ' '    'X' ' ' ' ' ' ',

      'KPRLO'    'KAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'KPRLO' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' 'X',

*--> [CHM2410-00483] 신규 필드 추가 - 20241210
      'KPRLO_B'  'KAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '정산금손익(KRW)' 'KPRLO' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' 'X',

      'KPRLO_S'  'KAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '수수료손익(KRW)' 'KPRLO' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' 'X',

*<-- [CHM2410-00483] 신규 필드 추가 - 20241210

      'KAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'KAERS' 'ZNFT1051' ' ' ' '    'X' ' ' ' ' ' ',

      'KURSF'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'KURSF' 'ZNFT1051' ' ' ' '    'X' ' ' ' ' ' ',

      'WWERT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'WWERT' 'ZNFT1051' ' ' ' '    'X' ' ' ' ' ' '.

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
      IT_OUTTAB            = GT_HEAD[].

  GS_VARIANT-HANDLE = '0003'.
  GS_VARIANT-REPORT = SY-REPID.

  CALL METHOD GC_ALV_GRID3->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = GS_VARIANT
      IS_LAYOUT            = GS_LAYOUT
      I_SAVE               = 'A'
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
    CHANGING
      IT_FIELDCATALOG      = GT_FIELDCAT2[]
      IT_SORT              = GT_SORT[]
      IT_OUTTAB            = GT_ITEM[].

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
  DATA: LV_TEXT(100),
        LV_FCM      LIKE ZNFT1020-FCM.

  PERFORM CHECK_SELECTED_ROWS.

  CHECK GV_ERROR IS INITIAL.

*___정산진행상태 최신표시
  PERFORM GET_PROCESSING_STATUS.

  PERFORM CHECK_PROCESSING_STATUS.

  CHECK GV_ERROR IS INITIAL.

  READ TABLE GT_MAIN WITH KEY FCM   = GV_FCM
                              CHECK = ' '.
  IF SY-SUBRC = 0.
    LV_FCM = GV_FCM.

    PERFORM CONVERSION_EXIT_ALPHA USING 'O' LV_FCM.

    CONCATENATE 'FCM' LV_FCM '에 대해 선택되지 않은'
                '손익정산 건이 존재합니다.'
                '별도의 손익전표로 생성하시겠습니까?'
           INTO LV_TEXT SEPARATED BY SPACE.

    PERFORM POPUP_TO_CONFIRM USING '확인'
                                   LV_TEXT
                                   '1'
                                   GV_ANSWER.
    IF GV_ANSWER <> '1'.
      GV_ERROR = 'X'.

      MESSAGE S007.
    ENDIF.
  ENDIF.

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
  DATA: LV_KURSF LIKE ZNFT1052-KURSF,
        LV_WWERT LIKE ZNFT1052-WWERT,
        LV_CNT   TYPE I,
        LV_FLAG.

  CLEAR : GV_FCM, LV_KURSF, LV_WWERT,
          LV_CNT, LV_FLAG,  GV_ERROR.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    IF GV_FCM IS INITIAL.
      GV_FCM = GT_MAIN-FCM.
    ENDIF.

    IF LV_KURSF IS INITIAL.
      LV_KURSF = GT_MAIN-KURSF.
    ENDIF.

    IF LV_WWERT IS INITIAL.
      LV_WWERT = GT_MAIN-WWERT.
    ENDIF.

    IF GV_FCM <> GT_MAIN-FCM.
      LV_FLAG = '1'.
      EXIT.
    ENDIF.

    IF LV_KURSF <> GT_MAIN-KURSF.
      LV_FLAG = '2'.
      EXIT.
    ENDIF.

    IF LV_WWERT <> GT_MAIN-WWERT.
      LV_FLAG = '3'.
      EXIT.
    ENDIF.

    LV_CNT = LV_CNT + 1.
  ENDLOOP.

  IF LV_FLAG IS NOT INITIAL.
    GV_ERROR = 'X'.

    CASE LV_FLAG.
      WHEN '1'.
        MESSAGE S001 DISPLAY LIKE 'E'
           WITH '동일한 FCM만 선택 가능합니다.'.

      WHEN '2'.
        MESSAGE S001 DISPLAY LIKE 'E'
           WITH '동일한 환율만 선택 가능합니다.'.

      WHEN '3'.
        MESSAGE S001 DISPLAY LIKE 'E'
           WITH '동일한 환산일만 선택 가능합니다.'.

    ENDCASE.
  ELSE.
    IF LV_CNT < 1.
      GV_ERROR = 'X'.

      MESSAGE S001 DISPLAY LIKE 'E'
         WITH '선택된 라인이 없습니다.'.
    ENDIF.
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
                              TRWON = '@5C@'.
  IF SY-SUBRC = 0.
    GV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선물손익 원화 반영되지 않은 건이 선택되었습니다.'.
    EXIT.
  ENDIF.

  READ TABLE GT_MAIN WITH KEY CHECK = 'X'
                              CREFI = '@5B@'.
  IF SY-SUBRC = 0.
    GV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '전표생성 완료된 건이 선택되었습니다.'.
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

  CLEAR   : GT_HEAD, GT_ITEM, GT_1051.
  REFRESH : GT_HEAD, GT_ITEM, GT_1051.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    LOOP AT GT_1052 WHERE FCM   = GT_MAIN-FCM
                      AND ENDAT = GT_MAIN-ENDAT.
      CLEAR : GT_HEAD.

      MOVE-CORRESPONDING GT_1052 TO GT_HEAD.

*___손익센터명
      PERFORM GET_PRCTR_DESC USING GV_KOKRS
                                   GT_HEAD-PRCTR
                                   GT_HEAD-PTEXT.

*___영업그룹명
      PERFORM GET_VKGRP_DESC USING GV_KOKRS
                                   GT_HEAD-VKGRP
                                   GT_HEAD-VTEXT.

*___고객명
      PERFORM GET_KUNNR_DESC USING GT_HEAD-KUNNR
                                   GT_HEAD-NAME1.

*--> [CHM2410-00483] 정산금/수수료 분리
      " 정산금손익(KRW)
      CLEAR : GT_HEAD-UPRLO_B.
      GT_HEAD-UPRLO_B = GT_HEAD-S_SUM - GT_HEAD-B_SUM.
      CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
        EXPORTING
          DATE             = GT_MAIN-WWERT
          FOREIGN_AMOUNT   = GT_HEAD-UPRLO_B
          FOREIGN_CURRENCY = GT_HEAD-UAERS
          LOCAL_CURRENCY   = GT_HEAD-KAERS
          RATE             = GT_MAIN-KURSF
        IMPORTING
          LOCAL_AMOUNT     = GT_HEAD-KPRLO_B
        EXCEPTIONS
          NO_RATE_FOUND    = 1
          OVERFLOW         = 2
          NO_FACTORS_FOUND = 3
          NO_SPREAD_FOUND  = 4
          DERIVED_2_TIMES  = 5
          OTHERS           = 6.
      " 환산금손익(KRW)
      CLEAR : GT_HEAD-UPRLO_S.
      GT_HEAD-UPRLO_S = GT_HEAD-B_FEE + GT_HEAD-S_FEE.
      CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
        EXPORTING
          DATE             = GT_MAIN-WWERT
          FOREIGN_AMOUNT   = GT_HEAD-UPRLO_S
          FOREIGN_CURRENCY = GT_HEAD-UAERS
          LOCAL_CURRENCY   = GT_HEAD-KAERS
          RATE             = GT_MAIN-KURSF
        IMPORTING
          LOCAL_AMOUNT     = GT_HEAD-KPRLO_S
        EXCEPTIONS
          NO_RATE_FOUND    = 1
          OVERFLOW         = 2
          NO_FACTORS_FOUND = 3
          NO_SPREAD_FOUND  = 4
          DERIVED_2_TIMES  = 5
          OTHERS           = 6.

*<-- [CHM2410-00483] 정산금/수수료 분리
      APPEND GT_HEAD.
    ENDLOOP.

    SELECT *
      APPENDING CORRESPONDING FIELDS OF TABLE GT_1051
      FROM ZNFT1051
     WHERE ENDAT = GT_MAIN-ENDAT
       AND FCM   = GT_MAIN-FCM.
  ENDLOOP.

  PERFORM CALC_PROFIT_SUM.

ENDFORM.                    " GET_DETAIL_DATA
*&---------------------------------------------------------------------*
*&      Form  CREATE_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_CONTAINER .

  CREATE OBJECT GC_CUSTOM_CONTAINER2
    EXPORTING
      CONTAINER_NAME = GC_CONTAINER_NAME2.

  CREATE OBJECT SPLITTER
    EXPORTING
      PARENT  = GC_CUSTOM_CONTAINER2
      ROWS    = 2
      COLUMNS = 1.

  CALL METHOD SPLITTER->SET_ROW_HEIGHT
    EXPORTING
      ID     = 1
      HEIGHT = 50.

  CALL METHOD SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GC_CONTAINER_2.

  CALL METHOD SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GC_CONTAINER_3.

  CREATE OBJECT GC_ALV_GRID2
    EXPORTING
      I_PARENT      = GC_CONTAINER_2
      I_APPL_EVENTS = 'X'.

  CREATE OBJECT GC_ALV_GRID3
    EXPORTING
      I_PARENT      = GC_CONTAINER_3
      I_APPL_EVENTS = 'X'.

ENDFORM.                    " CREATE_CONTAINER
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

  SET HANDLER GC_EVENT_HANDLER2->HANDLE_DATA_CHANGED_FINISHED_1
          FOR GC_ALV_GRID2.

  CALL METHOD GC_ALV_GRID3->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

*___Event Handler 등록
  CREATE OBJECT GC_EVENT_HANDLER3.

  SET HANDLER GC_EVENT_HANDLER3->HANDLE_DATA_CHANGED_FINISHED_2
          FOR GC_ALV_GRID3.
  SET HANDLER GC_EVENT_HANDLER3->HANDLE_DOUBLE_CLICK
          FOR GC_ALV_GRID3.

ENDFORM.                    " EVENT_HANDLER_REGISTER_2
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED  USING  E_FLAG
                                   E_MODIFIED
                                   ET_GOOD_CELLS TYPE LVC_T_MODI.
  DATA: LS_GOOD_CELLS TYPE LVC_S_MODI.

  IF E_FLAG = '1'.   "헤더 변경 시
    PERFORM GET_ZNFT1051_DATA.
  ELSE.              "품목 변경 시
    LOOP AT ET_GOOD_CELLS INTO LS_GOOD_CELLS.
*--> [CHM2410-00483] 정산금/수수료 분리
*      PERFORM APPLY_CHANGED_PROFIT.
      PERFORM APPLY_CHANGED_PROFIT_N USING LS_GOOD_CELLS-FIELDNAME.
    ENDLOOP.
*<-- [CHM2410-00483] 정산금/수수료 분리
    PERFORM CALC_PROFIT_SUM.
  ENDIF.

ENDFORM.                    " DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*&      Form  GET_ZNFT1051_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ZNFT1051_DATA .

  CLEAR   : GT_ITEM.
  REFRESH : GT_ITEM.

  LOOP AT GT_HEAD WHERE CHECK = 'X'.
    LOOP AT GT_1051 WHERE ENDAT = GT_HEAD-ENDAT
                      AND FCM   = GT_HEAD-FCM
                      AND PRCTR = GT_HEAD-PRCTR
                      AND VKGRP = GT_HEAD-VKGRP
                      AND KUNNR = GT_HEAD-KUNNR.
      CLEAR : GT_ITEM.

      MOVE-CORRESPONDING GT_1051 TO GT_ITEM.

      IF GT_1051-NBY_SL = 'B'.
        GT_ITEM-BFUTN = GT_1051-NFUTN.   "매입집행번호
        GT_ITEM-SFUTN = GT_1051-CFUTN.   "매각집행번호
        GT_ITEM-BYPRC = GT_1051-NPRICE.  "Buy 단가
        GT_ITEM-BYSPD = GT_1051-NMISPD.  "Buy Spread
        GT_ITEM-BYFEE = GT_1051-N_FEE.   "Buy 수수료
        GT_ITEM-SLPRC = GT_1051-CPRICE.  "Sell 단가
        GT_ITEM-SLSPD = GT_1051-CMISPD.  "Sell Spread
        GT_ITEM-SLFEE = GT_1051-C_FEE.   "Sell 수수료
      ELSE.
        GT_ITEM-BFUTN = GT_1051-CFUTN.   "매입집행번호
        GT_ITEM-SFUTN = GT_1051-NFUTN.   "매각집행번호
        GT_ITEM-BYPRC = GT_1051-CPRICE.  "Buy 단가
        GT_ITEM-BYSPD = GT_1051-CMISPD.  "Buy Spread
        GT_ITEM-BYFEE = GT_1051-C_FEE.   "Buy 수수료
        GT_ITEM-SLPRC = GT_1051-NPRICE.  "Sell 단가
        GT_ITEM-SLSPD = GT_1051-NMISPD.  "Sell Spread
        GT_ITEM-SLFEE = GT_1051-N_FEE.   "Sell 수수료
      ENDIF.

*___Buy 총액
      GT_ITEM-BYAMT = ( GT_ITEM-BYPRC + GT_ITEM-BYSPD )
                      * GT_ITEM-EMENG.

*___Sell 총액
      GT_ITEM-SLAMT = ( GT_ITEM-SLPRC + GT_ITEM-SLSPD )
                      * GT_ITEM-EMENG.

*--> [CHM2410-00483] 정산금/수수료 분리
      " 정산금손익(KRW)
      CLEAR : GT_ITEM-UPRLO_B.
      GT_ITEM-UPRLO_B = GT_ITEM-SLAMT - GT_ITEM-BYAMT.
      CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
        EXPORTING
          DATE             = GT_MAIN-WWERT
          FOREIGN_AMOUNT   = GT_ITEM-UPRLO_B
          FOREIGN_CURRENCY = GT_HEAD-UAERS
          LOCAL_CURRENCY   = GT_HEAD-KAERS
          RATE             = GT_MAIN-KURSF
        IMPORTING
          LOCAL_AMOUNT     = GT_ITEM-KPRLO_B
        EXCEPTIONS
          NO_RATE_FOUND    = 1
          OVERFLOW         = 2
          NO_FACTORS_FOUND = 3
          NO_SPREAD_FOUND  = 4
          DERIVED_2_TIMES  = 5
          OTHERS           = 6.
      " 환산금손익(KRW)
      CLEAR : GT_ITEM-UPRLO_S.
      GT_ITEM-UPRLO_S = GT_ITEM-BYFEE + GT_ITEM-SLFEE.
      CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
        EXPORTING
          DATE             = GT_MAIN-WWERT
          FOREIGN_AMOUNT   = GT_ITEM-UPRLO_S
          FOREIGN_CURRENCY = GT_HEAD-UAERS
          LOCAL_CURRENCY   = GT_HEAD-KAERS
          RATE             = GT_MAIN-KURSF
        IMPORTING
          LOCAL_AMOUNT     = GT_ITEM-KPRLO_S
        EXCEPTIONS
          NO_RATE_FOUND    = 1
          OVERFLOW         = 2
          NO_FACTORS_FOUND = 3
          NO_SPREAD_FOUND  = 4
          DERIVED_2_TIMES  = 5
          OTHERS           = 6.
*<-- [CHM2410-00483] 정산금/수수료 분리
      APPEND GT_ITEM.
    ENDLOOP.
  ENDLOOP.

  PERFORM CALC_PROFIT_SUM.

ENDFORM.                    " GET_ZNFT1051_DATA
*&---------------------------------------------------------------------*
*&      Form  CALC_PROFIT_SUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALC_PROFIT_SUM .

  CLEAR : GV_UPRLO,     "전체손익(USD)
          GV_UAERS,     "통화(USD)
          GV_KPRLO,     "개별손익(KRW)
          GV_KAERS,     "통화(KRW)
          GV_LPRLO,     "환산손익(KRW)
          GV_DIFFR.     "차이(KRW)

*--> [CHM2410-00483] 정산금/수수료 분할처리
  " 정산금
  CLEAR : GV_UPRLO_B,     "전체손익(USD)
          GV_UAERS_B,     "통화(USD)
          GV_KPRLO_B,     "개별손익(KRW)
          GV_KAERS_B,     "통화(KRW)
          GV_LPRLO_B,     "환산손익(KRW)
          GV_DIFFR_B.     "차이(KRW)
  " 수수료
  CLEAR : GV_UPRLO_S,     "전체손익(USD)
          GV_UAERS_S,     "통화(USD)
          GV_KPRLO_S,     "개별손익(KRW)
          GV_KAERS_S,     "통화(KRW)
          GV_LPRLO_S,     "환산손익(KRW)
          GV_DIFFR_S.     "차이(KRW)
*<-- [CHM2410-00483] 정산금/수수료 분할처리

  LOOP AT GT_HEAD.
    GV_UPRLO = GV_UPRLO + GT_HEAD-UPRLO.
    GV_KPRLO = GV_KPRLO + GT_HEAD-KPRLO.

    IF GV_UAERS IS INITIAL.
      GV_UAERS = GT_HEAD-UAERS.
    ENDIF.

    IF GV_KAERS IS INITIAL.
      GV_KAERS = GT_HEAD-KAERS.
    ENDIF.

*--> [CHM2410-00483] 정산금/수수료 분할처리
    GV_UPRLO_B = GV_UPRLO_B + GT_HEAD-UPRLO_B.
    GV_KPRLO_B = GV_KPRLO_B + GT_HEAD-KPRLO_B.
    GV_UPRLO_S = GV_UPRLO_S + GT_HEAD-UPRLO_S.
    GV_KPRLO_S = GV_KPRLO_S + GT_HEAD-KPRLO_S.

    IF GV_UAERS_B IS INITIAL.
      GV_UAERS_B = GT_HEAD-UAERS.
    ENDIF.

    IF GV_KAERS_B IS INITIAL.
      GV_KAERS_B = GT_HEAD-KAERS.
    ENDIF.

    IF GV_UAERS_S IS INITIAL.
      GV_UAERS_S = GT_HEAD-UAERS.
    ENDIF.

    IF GV_KAERS_S IS INITIAL.
      GV_KAERS_S = GT_HEAD-KAERS.
    ENDIF.
*<-- [CHM2410-00483] 정산금/수수료 분할처리

  ENDLOOP.

  CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
    EXPORTING
      DATE             = GT_MAIN-WWERT
      FOREIGN_AMOUNT   = GV_UPRLO
      FOREIGN_CURRENCY = GV_UAERS
      LOCAL_CURRENCY   = GV_KAERS
      RATE             = GT_MAIN-KURSF
    IMPORTING
      LOCAL_AMOUNT     = GV_LPRLO
    EXCEPTIONS
      NO_RATE_FOUND    = 1
      OVERFLOW         = 2
      NO_FACTORS_FOUND = 3
      NO_SPREAD_FOUND  = 4
      DERIVED_2_TIMES  = 5
      OTHERS           = 6.

  GV_DIFFR = GV_LPRLO - GV_KPRLO.

*>-- [CHM2410-00483] 정산금/수수료 분할처리
  CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
    EXPORTING
      DATE             = GT_MAIN-WWERT
      FOREIGN_AMOUNT   = GV_UPRLO_B
      FOREIGN_CURRENCY = GV_UAERS_B
      LOCAL_CURRENCY   = GV_KAERS_B
      RATE             = GT_MAIN-KURSF
    IMPORTING
      LOCAL_AMOUNT     = GV_LPRLO_B
    EXCEPTIONS
      NO_RATE_FOUND    = 1
      OVERFLOW         = 2
      NO_FACTORS_FOUND = 3
      NO_SPREAD_FOUND  = 4
      DERIVED_2_TIMES  = 5
      OTHERS           = 6.

  GV_DIFFR_B = GV_LPRLO_B - GV_KPRLO_B.

  CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
    EXPORTING
      DATE             = GT_MAIN-WWERT
      FOREIGN_AMOUNT   = GV_UPRLO_S
      FOREIGN_CURRENCY = GV_UAERS_S
      LOCAL_CURRENCY   = GV_KAERS_S
      RATE             = GT_MAIN-KURSF
    IMPORTING
      LOCAL_AMOUNT     = GV_LPRLO_S
    EXCEPTIONS
      NO_RATE_FOUND    = 1
      OVERFLOW         = 2
      NO_FACTORS_FOUND = 3
      NO_SPREAD_FOUND  = 4
      DERIVED_2_TIMES  = 5
      OTHERS           = 6.

  GV_DIFFR_S = GV_LPRLO_S - GV_KPRLO_S.
*<-- [CHM2410-00483] 정산금/수수료 분할처리

ENDFORM.                    " CALC_PROFIT_SUM
*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN_0300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_SCREEN_0300.

  PERFORM CHECK_SELECTED_DATA.

  CHECK GV_ERROR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '확인'
                                 '선물손익 전표를 생성하시겠습니까?'
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
    CLEAR : CTU_PARAMS.

    CTU_PARAMS-DISMODE  =  'E'.
    CTU_PARAMS-UPDMODE  =  'S'.
*    CTU_PARAMS-DEFSIZE  =  'X'.
    CTU_PARAMS-RACOMMIT =  'X'.

    GV_BLDAT = SY-DATLO.
    GV_BUDAT = SY-DATLO.

    CALL SCREEN 0300 STARTING AT 20 5.

    IF OK_SAVE = 'CONT' AND GV_ERROR IS INITIAL.
      PERFORM GET_SETTLEMENT_DATA.

      LEAVE TO SCREEN 0.
    ENDIF.
  ELSE.
    MESSAGE S007.
  ENDIF.

ENDFORM.                    " CALL_SCREEN_0300
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_DATA .

  CALL METHOD GC_ALV_GRID3->CHECK_CHANGED_DATA.

  CLEAR : GV_ERROR.

  IF GV_DIFFR IS NOT INITIAL.
    GV_ERROR = 'X'.

    MESSAGE I003 DISPLAY LIKE 'E'
       WITH '환산손익과 개별손익에서 차이가 발생합니다.'.

    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_DATA
*&---------------------------------------------------------------------*
*&      Form  APPLY_CHANGED_PROFIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM APPLY_CHANGED_PROFIT .
  DATA: LV_NFUTN LIKE ZNFT1051-NFUTN,
        LV_CFUTN LIKE ZNFT1051-CFUTN.

  CLEAR : GT_HEAD-KPRLO.

  MODIFY GT_HEAD TRANSPORTING KPRLO
                 WHERE CHECK = 'X'.

  LOOP AT GT_ITEM.
    READ TABLE GT_HEAD WITH KEY ENDAT = GT_ITEM-ENDAT
                                FCM   = GT_ITEM-FCM
                                PRCTR = GT_ITEM-PRCTR
                                VKGRP = GT_ITEM-VKGRP
                                KUNNR = GT_ITEM-KUNNR.
    IF SY-SUBRC = 0.
      GT_HEAD-KPRLO = GT_HEAD-KPRLO + GT_ITEM-KPRLO.
      MODIFY GT_HEAD INDEX SY-TABIX.
    ENDIF.

    IF GT_ITEM-NBY_SL = 'B'.
      LV_NFUTN = GT_ITEM-BFUTN.
      LV_CFUTN = GT_ITEM-SFUTN.
    ELSE.
      LV_NFUTN = GT_ITEM-SFUTN.
      LV_CFUTN = GT_ITEM-BFUTN.
    ENDIF.

    READ TABLE GT_1051 WITH KEY NFUTN = LV_NFUTN
                                CFUTN = LV_CFUTN.
    IF SY-SUBRC = 0.
      GT_1051-KPRLO = GT_ITEM-KPRLO.

      MODIFY GT_1051 INDEX SY-TABIX.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " APPLY_CHANGED_PROFIT
*&---------------------------------------------------------------------*
*&      Form  CREATE_FI_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_FI_DOC .

*<<< FI 기표 BDC -> 펑션으로 수정 / ZITCS4HDEV10  2023.07.18
  PERFORM MAKE_BDC_DATA_NEW.
**  PERFORM MAKE_BDC_DATA.
**  PERFORM BDC_EXECUTION.
*>>>
  IF GV_ERROR IS INITIAL.
    PERFORM UPDATE_RESULT.
  ENDIF.

  LEAVE TO SCREEN 0.

ENDFORM.                    " CREATE_FI_DOC
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
*&      Form  MAKE_BDC_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_BDC_DATA .
  DATA: LV_GSBER     LIKE BSEG-GSBER,
        LV_KUNNR     LIKE ZNFT0021-KUNNR,
        LV_PRCTR     LIKE ZNFT1052-PRCTR,  "손익센터
        LV_VKGRP     LIKE ZNFT1052-VKGRP,  "영업그룹
        LV_KURSF(12),
        LV_UPRLO(20),
        LV_KPRLO(20),
        LV_FLAG,
        LV_TABIX     LIKE SY-TABIX.

  CLEAR   : GT_BDCTAB, GT_RETMSG.
  REFRESH : GT_BDCTAB, GT_RETMSG.

*___환율
  LV_KURSF = GT_MAIN-KURSF.

*___선물손익
  WRITE : GV_UPRLO TO LV_UPRLO CURRENCY GV_UAERS NO-GROUPING,
          GV_KPRLO TO LV_KPRLO CURRENCY GV_KAERS NO-GROUPING.

  LV_UPRLO = ABS( LV_UPRLO ).
  LV_KPRLO = ABS( LV_KPRLO ).

  CONDENSE : LV_UPRLO, LV_KPRLO.

*___사업영역
  IF P_BUKRS = '1000'.
    LV_GSBER = '1200'.
  ELSEIF P_BUKRS = '2000'.
    LV_GSBER = '2900'.
  ENDIF.

*___고객송장 입력: 헤더데이타
  PERFORM DYNPRO USING :
                'X' 'SAPMF05A'           '0100',
                ' ' 'BDC_OKCODE'         '/00',            "Enter
                ' ' 'BKPF-BLDAT'         GV_BLDAT,         "증빙일
                ' ' 'BKPF-BLART'         'SZ',             "전표유형
                ' ' 'BKPF-BUKRS'         GT_MAIN-BUKRS,    "회사코드
                ' ' 'BKPF-BUDAT'         GV_BUDAT,         "전기일
                ' ' 'BKPF-MONAT'         GV_BUDAT+4(2),    "전기기간
                ' ' 'BKPF-WAERS'         GV_UAERS,         "통화
                ' ' 'BKPF-KURSF'         LV_KURSF,         "환율
                ' ' 'BKPF-WWERT'         GT_MAIN-WWERT.    "환산일

  CLEAR : LV_KUNNR,
          LV_PRCTR,
          LV_VKGRP.

*___첫 번째 개별 항목
  IF GV_UPRLO > 0.  "선물손익(USD)
    SELECT SINGLE KUNNR          "고객
      INTO LV_KUNNR
      FROM ZNFT0021              "선물 거래처 관리
     WHERE BUKRS = GT_MAIN-BUKRS "회사코드
       AND LIFNR = GT_MAIN-FCM.  "공급업체-FCM(거래선)

    PERFORM DYNPRO USING :
                ' ' 'RF05A-NEWBS'        '01',      "전기키-수금
                ' ' 'RF05A-NEWKO'        LV_KUNNR.  "계정-고객

*___항목 1 / 송장
    PERFORM DYNPRO USING :
                'X' 'SAPMF05A'           '0301'.
  ELSE.
    PERFORM DYNPRO USING :
                ' ' 'RF05A-NEWBS'        '31',         "전기키-지급
                ' ' 'RF05A-NEWKO'        GT_MAIN-FCM.  "계정-FCM(거래선)

*   항목 1 / 송장
    PERFORM DYNPRO USING :
                'X' 'SAPMF05A'           '0302'.
  ENDIF.

  PERFORM DYNPRO USING :
                ' ' 'BDC_OKCODE'         '/00',     "Enter
                ' ' 'BSEG-WRBTR'         LV_UPRLO,  "금액(USD)
                ' ' 'BSEG-DMBTR'         LV_KPRLO,  "현지통화금액(KRW)
                ' ' 'BSEG-GSBER'         LV_GSBER.  "사업영역

  IF LV_KUNNR > '0000300000' AND LV_KUNNR < '0000400000'.
    PERFORM DYNPRO USING :
                ' ' 'BSEG-SGTXT'         '10001090'.
  ENDIF.

  CLEAR : LV_FLAG.

  LOOP AT GT_HEAD.
    LV_TABIX = SY-TABIX.

    WRITE : GT_HEAD-UPRLO TO LV_UPRLO CURRENCY GT_HEAD-UAERS
                                      NO-GROUPING,
            GT_HEAD-KPRLO TO LV_KPRLO CURRENCY GT_HEAD-KAERS
                                      NO-GROUPING.

    LV_UPRLO = ABS( LV_UPRLO ).
    LV_KPRLO = ABS( LV_KPRLO ).

    CONDENSE : LV_UPRLO, LV_KPRLO.

    IF GT_HEAD-UPRLO > 0.  "선물손익(USD)
*___다음 개별 항목
      PERFORM DYNPRO USING :
                ' ' 'RF05A-NEWBS'        '50',       "전기키
*               ' ' 'RF05A-NEWKO'        '7240105'.  "계정
                ' ' 'RF05A-NEWKO'        '5150901'.  "계정
    ELSE.
*___다음 개별 항목
      PERFORM DYNPRO USING :
                ' ' 'RF05A-NEWBS'        '40',       "전기키
*               ' ' 'RF05A-NEWKO'        '7480105'.  "계정
                ' ' 'RF05A-NEWKO'        '5150901'.  "계정
    ENDIF.

    IF LV_TABIX > 1.
      PERFORM DYNPRO USING :
                'X' 'SAPLKACB'           '0002',
                ' ' 'BDC_OKCODE'         '=COBL_XERGO',

                'X' 'SAPLKEAK'           '0300',
                ' ' 'BDC_OKCODE'         '=P+',         "계속
                ' ' 'RKEAK-FIELD(01)'    LV_KUNNR,
*                ' ' 'RKEAK-FIELD(04)'    GT_HEAD-VBELN, "판매오더
*                ' ' 'RKEAK-FIELD(05)'    GT_HEAD-POSNR, "품목
                ' ' 'RKEAK-FIELD(13)'    LV_PRCTR, "손익센터

                'X' 'SAPLKEAK'           '0300',
                ' ' 'BDC_OKCODE'         '=WEIT',
                ' ' 'RKEAK-FIELD(02)'    LV_VKGRP,

                'X' 'SAPLKACB'           '0002',
                ' ' 'BDC_OKCODE'         '=ENTE'.       "Enter
    ENDIF.

    LV_PRCTR = GT_HEAD-PRCTR.        "손익센터
    LV_VKGRP = GT_HEAD-VKGRP.        "영업그룹
    LV_KUNNR = GT_HEAD-KUNNR.        "고객

    AT LAST.
      LV_FLAG = 'X'.
    ENDAT.

    IF LV_FLAG = 'X'.
      PERFORM DYNPRO USING :
                'X' 'SAPMF05A'           '0300',
                ' ' 'BDC_OKCODE'         '=BU',     "저장
                ' ' 'BSEG-WRBTR'         LV_UPRLO,  "금액(USD)
                ' ' 'BSEG-DMBTR'         LV_KPRLO,  "현지통화금액(KRW)

*___수익성세그멘트
                'X' 'SAPLKACB'           '0002',
                ' ' 'BDC_OKCODE'         '=COBL_XERGO',

                'X' 'SAPLKEAK'           '0300',
                ' ' 'BDC_OKCODE'         '=P+',          "계속
                ' ' 'RKEAK-FIELD(01)'    LV_KUNNR,
*                ' ' 'RKEAK-FIELD(04)'    lv_vbeln,       "판매오더
*                ' ' 'RKEAK-FIELD(05)'    lv_posnr,       "품목
                ' ' 'RKEAK-FIELD(13)'    LV_PRCTR,  "손익센터

                'X' 'SAPLKEAK'           '0300',
                ' ' 'BDC_OKCODE'         '=WEIT',
                ' ' 'RKEAK-FIELD(02)'    LV_VKGRP,

                'X' 'SAPLKACB'           '0002',
                ' ' 'BDC_OKCODE'         '=ENTE'.        "Enter
    ELSE.
      PERFORM DYNPRO USING :
                'X' 'SAPMF05A'           '0300',
                ' ' 'BDC_OKCODE'         '/00',     "Enter
                ' ' 'BSEG-WRBTR'         LV_UPRLO,  "금액(USD)
                ' ' 'BSEG-DMBTR'         LV_KPRLO.  "현지통화금액(KRW)
    ENDIF.
  ENDLOOP.

ENDFORM.                    " MAKE_BDC_DATA
*&---------------------------------------------------------------------*
*&      Form  BDC_EXECUTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BDC_EXECUTION .

  CLEAR : GV_ERROR, GV_BELNR.

*___채권 -> 전표 입력 -> 송장 - 일반
  CALL TRANSACTION 'F-22' USING         GT_BDCTAB
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

ENDFORM.                    " BDC_EXECUTION
*&---------------------------------------------------------------------*
*&      Form  MAKE_BDC_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_BDC_DATA_NEW .

* 전표 BDC 전기를 위한 변수
  DATA: LT_BBKPF LIKE STANDARD TABLE OF BBKPF WITH HEADER LINE,
        LT_BBSEG LIKE STANDARD TABLE OF BBSEG WITH HEADER LINE.
  DATA: LV_MSG(100),
        LV_BELNR    TYPE  BELNR_D,
        LV_MODE     TYPE CTU_PARAMS-DISMODE.


  DATA: LV_GSBER     LIKE BSEG-GSBER,
        LV_KUNNR     LIKE ZNFT0021-KUNNR,
        LV_PRCTR     LIKE ZNFT1052-PRCTR,  "손익센터
        LV_VKGRP     LIKE ZNFT1052-VKGRP,  "영업그룹
        LV_KURSF(12),
        LV_UPRLO(20),
        LV_KPRLO(20),
        LV_FLAG,
        LV_TABIX     LIKE SY-TABIX.

  CLEAR   : GT_BDCTAB, GT_RETMSG.
  REFRESH : GT_BDCTAB, GT_RETMSG.

  CLEAR: LT_BBKPF[], LT_BBKPF, LT_BBSEG[], LT_BBSEG.

*___환율
  LV_KURSF = GT_MAIN-KURSF.

*___선물손익
  WRITE : GV_UPRLO TO LV_UPRLO CURRENCY GV_UAERS NO-GROUPING,
          GV_KPRLO TO LV_KPRLO CURRENCY GV_KAERS NO-GROUPING.

  LV_UPRLO = ABS( LV_UPRLO ).
  LV_KPRLO = ABS( LV_KPRLO ).

  CONDENSE : LV_UPRLO, LV_KPRLO.

*___사업영역
  IF P_BUKRS = '1000'.
    LV_GSBER = '1200'.
  ELSEIF P_BUKRS = '2000'.
    LV_GSBER = '2900'.
  ENDIF.

*___고객송장 입력: 헤더데이타
  LT_BBKPF-TCODE = 'FB01'.
  LT_BBKPF-BLDAT = GV_BLDAT     .  "증빙일
  LT_BBKPF-BLART = 'SZ'         .  "전표유형
  LT_BBKPF-BUKRS = GT_MAIN-BUKRS.  "회사코드
  LT_BBKPF-BUDAT = GV_BUDAT     .  "전기일
  LT_BBKPF-MONAT = GV_BUDAT+4(2).  "전기기간
  LT_BBKPF-WAERS = GV_UAERS     .  "통화
  LT_BBKPF-KURSF = LV_KURSF     .  "환율
  LT_BBKPF-WWERT = GT_MAIN-WWERT.  "환산일
  APPEND LT_BBKPF.

  CLEAR : LV_KUNNR,
          LV_PRCTR,
          LV_VKGRP.

*___첫 번째 개별 항목
  IF GV_UPRLO > 0.  "선물손익(USD)
    SELECT SINGLE KUNNR          "고객
      INTO LV_KUNNR
      FROM ZNFT0021              "선물 거래처 관리
     WHERE BUKRS = GT_MAIN-BUKRS "회사코드
       AND LIFNR = GT_MAIN-FCM.  "공급업체-FCM(거래선)

    LT_BBSEG-NEWBS = '01'.      "전기키-수금
    LT_BBSEG-NEWKO = LV_KUNNR.  "계정-고객
  ELSE.
    LT_BBSEG-NEWBS = '31'.         "전기키-지급
    LT_BBSEG-NEWKO = GT_MAIN-FCM.  "계정-FCM(거래선)
  ENDIF.

  LT_BBSEG-WRBTR = LV_UPRLO.  "금액(USD)
  LT_BBSEG-DMBTR = LV_KPRLO.  "현지통화금액(KRW)
  LT_BBSEG-GSBER = LV_GSBER.  "사업영역
  IF LV_KUNNR > '0000300000' AND LV_KUNNR < '0000400000'.
    LT_BBSEG-SGTXT = '10001090'.
  ENDIF.
  APPEND LT_BBSEG. CLEAR LT_BBSEG.


  CLEAR : LV_FLAG.

  LOOP AT GT_HEAD.
    LV_TABIX = SY-TABIX.

    WRITE : GT_HEAD-UPRLO TO LV_UPRLO CURRENCY GT_HEAD-UAERS
                                      NO-GROUPING,
            GT_HEAD-KPRLO TO LV_KPRLO CURRENCY GT_HEAD-KAERS
                                      NO-GROUPING.

    LV_UPRLO = ABS( LV_UPRLO ).
    LV_KPRLO = ABS( LV_KPRLO ).

    CONDENSE : LV_UPRLO, LV_KPRLO.

*___다음 개별 항목
    IF GT_HEAD-UPRLO > 0.  "선물손익(USD)
      LT_BBSEG-NEWBS = '50'.          "전기키
    ELSE.
      LT_BBSEG-NEWBS = '40'.          "전기키
    ENDIF.
    LT_BBSEG-NEWKO = '0005150901'.    "계정-동선물정산손익

*->2024.02.02 ZITCS4HDEV01 기존로직 주석 후 추가
*    IF LV_TABIX > 1.
*      LT_BBSEG-RKE_BUKRS      = GT_MAIN-BUKRS.
*      LT_BBSEG-RKE_KNDNR      = LV_KUNNR .      "고객
*      LT_BBSEG-RKE_PRCTR      = LV_PRCTR .      "손익센터
*      LT_BBSEG-RKE_KMVKGR     = LV_VKGRP .      "영업그룹
*    ENDIF.
*
*    LV_KUNNR = GT_HEAD-KUNNR.        "고객
*    LV_PRCTR = GT_HEAD-PRCTR.        "손익센터
*    LV_VKGRP = GT_HEAD-VKGRP.        "영업그룹
*
*    LT_BBSEG-WRBTR = LV_UPRLO.  "금액(USD)
*    LT_BBSEG-DMBTR = LV_KPRLO.  "현지통화금액(KRW)
*    LT_BBSEG-PRCTR = LV_PRCTR.  "손익센터
*
*    AT LAST.
*      LV_FLAG = 'X'.
*    ENDAT.
*
*    IF LV_FLAG = 'X'.
**___수익성세그멘트
*      LT_BBSEG-RKE_BUKRS      = GT_MAIN-BUKRS.
*      LT_BBSEG-RKE_KNDNR      = LV_KUNNR .      "고객
*      LT_BBSEG-RKE_PRCTR      = LV_PRCTR .      "손익센터
*      LT_BBSEG-RKE_KMVKGR     = LV_VKGRP .      "영업그룹
*    ENDIF.

    LV_KUNNR = GT_HEAD-KUNNR.        "고객
    LV_PRCTR = GT_HEAD-PRCTR.        "손익센터
    LV_VKGRP = GT_HEAD-VKGRP.        "영업그룹

    LT_BBSEG-RKE_BUKRS      = GT_MAIN-BUKRS.
    LT_BBSEG-RKE_KNDNR      = LV_KUNNR .      "고객
    LT_BBSEG-RKE_PRCTR      = LV_PRCTR .      "손익센터
    LT_BBSEG-RKE_KMVKGR     = LV_VKGRP .      "영업그룹


    LT_BBSEG-WRBTR = LV_UPRLO.  "금액(USD)
    LT_BBSEG-DMBTR = LV_KPRLO.  "현지통화금액(KRW)
    LT_BBSEG-PRCTR = LV_PRCTR.  "손익센터
*<-

    APPEND LT_BBSEG. CLEAR LT_BBSEG.
  ENDLOOP.

* 전표생성 펑션 Call
  CLEAR: LV_BELNR, LV_MSG.
  LV_MODE = CTU_PARAMS-DISMODE.
  CALL FUNCTION 'ZFI_DOCUMENT_POSTING'
    EXPORTING
      I_BDC_MODE  = LV_MODE
      I_MESSAGE   = ''
    IMPORTING
      E_BELNR     = LV_BELNR
      E_RESULTMSG = LV_MSG
    TABLES
      T_BBKPF     = LT_BBKPF
      T_BBSEG     = LT_BBSEG.

  IF NOT LV_BELNR IS INITIAL.
    GV_BELNR = LV_BELNR.
  ELSE.
    GV_ERROR = 'X'.
    MESSAGE S000 WITH LV_MSG.
  ENDIF.

ENDFORM.                    " MAKE_BDC_DATA_NEW
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

*___ZLST1051 Update
  LOOP AT GT_1051.
    GT_1051-BELNR = GV_BELNR.
    GT_1051-GJAHR = GV_BUDAT(4).
    GT_1051-AENAM = SY-UNAME.
    GT_1051-AEDAT = SY-DATLO.
    GT_1051-AEZET = SY-TIMLO.

    MODIFY GT_1051.
  ENDLOOP.

  MODIFY ZNFT1051 FROM TABLE GT_1051.
  IF SY-SUBRC = 0.
    CLEAR : LV_FLAG.

    LOOP AT GT_HEAD.
      UPDATE ZNFT1052 SET KPRLO = GT_HEAD-KPRLO
                          GJAHR = GV_BUDAT(4)
                          BELNR = GV_BELNR
                          AEDAT = SY-DATLO
                          AEZET = SY-TIMLO
                          AENAM = SY-UNAME
                    WHERE FCM   = GT_HEAD-FCM
                      AND ENDAT = GT_HEAD-ENDAT
                      AND PRCTR = GT_HEAD-PRCTR
                      AND VKGRP = GT_HEAD-VKGRP
                      AND KUNNR = GT_HEAD-KUNNR.
      IF SY-SUBRC <> 0.
        LV_FLAG = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF LV_FLAG IS INITIAL.
      PERFORM UPDATE_PROCESSING_STATUS USING LV_FLAG.
      IF LV_FLAG IS INITIAL.
        COMMIT WORK.

        MESSAGE S003 WITH '선물손익전표'
                          GV_BELNR
                          '을(를) 생성하였습니다.'.
      ELSE.
        ROLLBACK WORK.

        PERFORM CANCEL_FI_DOC.

        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '정산진행상태 저장 에러!'.
      ENDIF.
    ELSE.
      ROLLBACK WORK.

      PERFORM CANCEL_FI_DOC.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '선물손익 정산 테이블 Update Error!'.
    ENDIF.
  ELSE.
    ROLLBACK WORK.

    PERFORM CANCEL_FI_DOC.

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

  CHECK GV_BELNR IS NOT INITIAL.

  CLEAR   : GT_BDCTAB, GT_RETMSG.
  REFRESH : GT_BDCTAB, GT_RETMSG.

  PERFORM DYNPRO USING :
                 'X' 'SAPMF05A'          '0105',
                 ' ' 'BDC_OKCODE'        '=BU',
                 ' ' 'RF05A-BELNS'       GV_BELNR,
                 ' ' 'BKPF-BUKRS'        P_BUKRS,
                 ' ' 'RF05A-GJAHS'       GV_BUDAT(4),
                 ' ' 'UF05A-STGRD'       '01'.

  CALL TRANSACTION 'FB08' USING         GT_BDCTAB
                          OPTIONS  FROM CTU_PARAMS
                          MESSAGES INTO GT_RETMSG.

ENDFORM.                    " CANCEL_FI_DOC
*&---------------------------------------------------------------------*
*&      Form  UPDATE_PROCESSING_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPDATE_PROCESSING_STATUS  USING    PV_FLAG.

  CLEAR : PV_FLAG.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    UPDATE ZNFT1050 SET CREFI = 'X'
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
*&      Form  DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING  PS_ROW    TYPE LVC_S_ROW
                          PS_COLUMN TYPE LVC_S_COL.

  READ TABLE GT_ITEM INDEX PS_ROW-INDEX.
  IF SY-SUBRC = 0.
    CASE PS_COLUMN-FIELDNAME.
      WHEN 'BFUTN' OR 'SFUTN'.
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

  APPEND_PARAM : LT_RSPAR 'P_BUKRS' 'P' ' ' ' '  P_BUKRS       ' '.

  IF ( PV_FNAME = 'BFUTN' AND GT_ITEM-NBY_SL = 'B' ) OR
     ( PV_FNAME = 'SFUTN' AND GT_ITEM-NBY_SL = 'S' ).
    LT_RSPAR-SELNAME = 'S_NFUTN'.
    LT_RSPAR-KIND    = 'S'.
    LT_RSPAR-SIGN    = 'I'.
    LT_RSPAR-OPTION  = 'EQ'.

    IF GT_ITEM-NBY_SL = 'B'.
      LT_RSPAR-LOW     = GT_ITEM-BFUTN.
    ELSE.
      LT_RSPAR-LOW     = GT_ITEM-SFUTN.
    ENDIF.

    APPEND LT_RSPAR.

    APPEND_PARAM : LT_RSPAR 'P_CHK11' 'P' ' ' ' '  'X'           ' ',
                   LT_RSPAR 'P_CHK12' 'P' ' ' ' '  ' '           ' '.
  ELSE.
    LT_RSPAR-SELNAME = 'S_CFUTN'.
    LT_RSPAR-KIND    = 'S'.
    LT_RSPAR-SIGN    = 'I'.
    LT_RSPAR-OPTION  = 'EQ'.

    IF GT_ITEM-NBY_SL = 'B'.
      LT_RSPAR-LOW     = GT_ITEM-SFUTN.
    ELSE.
      LT_RSPAR-LOW     = GT_ITEM-BFUTN.
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

  LT_RSPAR-SELNAME = 'P_BUKRS'.
  LT_RSPAR-KIND    = 'P'.
  LT_RSPAR-LOW     = P_BUKRS.
  APPEND LT_RSPAR.

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
*&---------------------------------------------------------------------*
*& Form APPLY_CHANGED_PROFIT_N
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM APPLY_CHANGED_PROFIT_N USING PV_FIELDNAME.
  DATA: LV_NFUTN LIKE ZNFT1051-NFUTN,
        LV_CFUTN LIKE ZNFT1051-CFUTN.

  IF PV_FIELDNAME = 'KPRLO'.
    CLEAR : GT_HEAD-KPRLO.
    MODIFY GT_HEAD TRANSPORTING KPRLO
                   WHERE CHECK = 'X'.
  ELSEIF PV_FIELDNAME = 'KPRLO_B'.
    CLEAR : GT_HEAD-KPRLO_B.
    MODIFY GT_HEAD TRANSPORTING KPRLO_B
                   WHERE CHECK = 'X'.
  ELSEIF PV_FIELDNAME = 'KPRLO_S'.
    CLEAR : GT_HEAD-KPRLO_S.
    MODIFY GT_HEAD TRANSPORTING KPRLO_S
                   WHERE CHECK = 'X'.
  ENDIF.

  LOOP AT GT_ITEM.
    READ TABLE GT_HEAD WITH KEY ENDAT = GT_ITEM-ENDAT
                                FCM   = GT_ITEM-FCM
                                PRCTR = GT_ITEM-PRCTR
                                VKGRP = GT_ITEM-VKGRP
                                KUNNR = GT_ITEM-KUNNR.
    IF SY-SUBRC = 0.
      IF PV_FIELDNAME = 'KPRLO'.
        GT_HEAD-KPRLO = GT_HEAD-KPRLO + GT_ITEM-KPRLO.
      ELSEIF PV_FIELDNAME = 'KPRLO_B'.
        GT_HEAD-KPRLO_B = GT_HEAD-KPRLO_B + GT_ITEM-KPRLO_B.
      ELSEIF PV_FIELDNAME = 'KPRLO_S'.
        GT_HEAD-KPRLO_S = GT_HEAD-KPRLO_S + GT_ITEM-KPRLO_S.
      ENDIF.
      MODIFY GT_HEAD INDEX SY-TABIX.
    ENDIF.

    IF GT_ITEM-NBY_SL = 'B'.
      LV_NFUTN = GT_ITEM-BFUTN.
      LV_CFUTN = GT_ITEM-SFUTN.
    ELSE.
      LV_NFUTN = GT_ITEM-SFUTN.
      LV_CFUTN = GT_ITEM-BFUTN.
    ENDIF.

    READ TABLE GT_1051 WITH KEY NFUTN = LV_NFUTN
                                CFUTN = LV_CFUTN.
    IF SY-SUBRC = 0.
      GT_1051-KPRLO = GT_ITEM-KPRLO.

      MODIFY GT_1051 INDEX SY-TABIX.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_SCREEN_0310
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_SCREEN_0310.

  PERFORM CHECK_SELECTED_DATA.

  CHECK GV_ERROR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '확인'
                                 '선물손익 전표를 생성하시겠습니까?'
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
    CLEAR : CTU_PARAMS.

    CTU_PARAMS-DISMODE  =  'E'.
    CTU_PARAMS-UPDMODE  =  'S'.
*    CTU_PARAMS-DEFSIZE  =  'X'.
    CTU_PARAMS-RACOMMIT =  'X'.

    GV_BLDAT_BS = SY-DATLO.
    GV_BUDAT_BS = SY-DATLO.

    CALL SCREEN 0310 STARTING AT 20 5.

    IF OK_SAVE = 'CONT' AND GV_ERROR IS INITIAL.
      PERFORM GET_SETTLEMENT_DATA.

      LEAVE TO SCREEN 0.
    ENDIF.
  ELSE.
    MESSAGE S007.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_FI_DOC_BS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_FI_DOC_BS.

**<<< FI 기표 BDC -> 펑션으로 수정 / ZITCS4HDEV10  2023.07.18
*  PERFORM MAKE_BDC_DATA_NEW.
***  PERFORM MAKE_BDC_DATA.
***  PERFORM BDC_EXECUTION.
**>>>
*  IF GV_ERROR IS INITIAL.
*    PERFORM UPDATE_RESULT.
*  ENDIF.

*--> [CHM2410-00483] 정산금/수수료 분리
  PERFORM MAKE_BDC_DATA_NEW_BS.
  IF GV_ERROR IS INITIAL.
    PERFORM UPDATE_RESULT_BS.
  ENDIF.
*<-- [CHM2410-00483] 정산금/수수료 분리

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_BDC_DATA_NEW_BS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_BDC_DATA_NEW_BS .


* 전표 BDC 전기를 위한 변수
  DATA: LT_BBKPF LIKE STANDARD TABLE OF BBKPF WITH HEADER LINE,
        LT_BBSEG LIKE STANDARD TABLE OF BBSEG WITH HEADER LINE.
  DATA: LV_MSG(100),
        LV_BELNR    TYPE BELNR_D,
        LV_MODE     TYPE CTU_PARAMS-DISMODE.


  DATA: LV_GSBER     LIKE BSEG-GSBER,
        LV_KUNNR     LIKE ZNFT0021-KUNNR,
        LV_PRCTR     LIKE ZNFT1052-PRCTR,  "손익센터
        LV_VKGRP     LIKE ZNFT1052-VKGRP,  "영업그룹
        LV_KURSF(12),
        LV_UPRLO(20),
        LV_KPRLO(20),
        LV_FLAG,
        LV_TABIX     LIKE SY-TABIX.

*--> 1. 정산금 처리

  CLEAR   : GT_BDCTAB, GT_RETMSG.
  REFRESH : GT_BDCTAB, GT_RETMSG.

  CLEAR: LT_BBKPF[], LT_BBKPF, LT_BBSEG[], LT_BBSEG.

*___환율
  LV_KURSF = GT_MAIN-KURSF.

*___정산금손익
  WRITE : GV_UPRLO_B TO LV_UPRLO CURRENCY GV_UAERS NO-GROUPING,
          GV_KPRLO_B TO LV_KPRLO CURRENCY GV_KAERS NO-GROUPING.

  LV_UPRLO = ABS( LV_UPRLO ).
  LV_KPRLO = ABS( LV_KPRLO ).

  CONDENSE : LV_UPRLO, LV_KPRLO.

*___사업영역
  IF P_BUKRS = '1000'.
    LV_GSBER = '1200'.
  ELSEIF P_BUKRS = '2000'.
    LV_GSBER = '2900'.
  ENDIF.

*___고객송장 입력: 헤더데이타
  LT_BBKPF-TCODE = 'FB01'.
  LT_BBKPF-BLDAT = GV_BLDAT_BS  .     "증빙일
  LT_BBKPF-BLART = 'SZ'         .     "전표유형
  LT_BBKPF-BUKRS = GT_MAIN-BUKRS.     "회사코드
  LT_BBKPF-BUDAT = GV_BUDAT_BS  .     "전기일
  LT_BBKPF-MONAT = GV_BUDAT_BS+4(2).  "전기기간
  LT_BBKPF-WAERS = GV_UAERS     .     "통화
  LT_BBKPF-KURSF = LV_KURSF     .     "환율
  LT_BBKPF-WWERT = GT_MAIN-WWERT.     "환산일
  APPEND LT_BBKPF.

  CLEAR : LV_KUNNR,
          LV_PRCTR,
          LV_VKGRP.

*___첫 번째 개별 항목
  IF GV_UPRLO_B > 0. " 정산금손익
    SELECT SINGLE KUNNR          "고객
      INTO LV_KUNNR
      FROM ZNFT0021              "선물 거래처 관리
     WHERE BUKRS = GT_MAIN-BUKRS "회사코드
       AND LIFNR = GT_MAIN-FCM.  "공급업체-FCM(거래선)

    LT_BBSEG-NEWBS = '01'.      "전기키-수금
    LT_BBSEG-NEWKO = LV_KUNNR.  "계정-고객
  ELSE.
    LT_BBSEG-NEWBS = '31'.         "전기키-지급
    LT_BBSEG-NEWKO = GT_MAIN-FCM.  "계정-FCM(거래선)
  ENDIF.

  LT_BBSEG-WRBTR = LV_UPRLO.  "금액(USD)
  LT_BBSEG-DMBTR = LV_KPRLO.  "현지통화금액(KRW)
  LT_BBSEG-GSBER = LV_GSBER.  "사업영역
  IF LV_KUNNR > '0000300000' AND LV_KUNNR < '0000400000'.
    LT_BBSEG-SGTXT = '10001090'.
  ENDIF.
  APPEND LT_BBSEG. CLEAR LT_BBSEG.


  CLEAR : LV_FLAG.

  LOOP AT GT_HEAD.
    LV_TABIX = SY-TABIX.

    WRITE : GT_HEAD-UPRLO_B TO LV_UPRLO CURRENCY GT_HEAD-UAERS
                                      NO-GROUPING,
            GT_HEAD-KPRLO_B TO LV_KPRLO CURRENCY GT_HEAD-KAERS
                                      NO-GROUPING.

    LV_UPRLO = ABS( LV_UPRLO ).
    LV_KPRLO = ABS( LV_KPRLO ).

    CONDENSE : LV_UPRLO, LV_KPRLO.

*___다음 개별 항목
    IF GT_HEAD-UPRLO_B > 0. " 정산금손익
      LT_BBSEG-NEWBS = '50'.          "전기키
    ELSE.
      LT_BBSEG-NEWBS = '40'.          "전기키
    ENDIF.
    LT_BBSEG-NEWKO = '0005150901'.    "계정-동선물정산손익

    LV_KUNNR = GT_HEAD-KUNNR.        "고객
    LV_PRCTR = GT_HEAD-PRCTR.        "손익센터
    LV_VKGRP = GT_HEAD-VKGRP.        "영업그룹

    LT_BBSEG-RKE_BUKRS      = GT_MAIN-BUKRS.
    LT_BBSEG-RKE_KNDNR      = LV_KUNNR .      "고객
    LT_BBSEG-RKE_PRCTR      = LV_PRCTR .      "손익센터
    LT_BBSEG-RKE_KMVKGR     = LV_VKGRP .      "영업그룹


    LT_BBSEG-WRBTR = LV_UPRLO.  "금액(USD)
    LT_BBSEG-DMBTR = LV_KPRLO.  "현지통화금액(KRW)
    LT_BBSEG-PRCTR = LV_PRCTR.  "손익센터
*<-

    APPEND LT_BBSEG. CLEAR LT_BBSEG.
  ENDLOOP.

* 전표생성 펑션 Call
  CLEAR: LV_BELNR, LV_MSG.
  LV_MODE = CTU_PARAMS-DISMODE.
  CALL FUNCTION 'ZFI_DOCUMENT_POSTING'
    EXPORTING
      I_BDC_MODE  = LV_MODE
      I_MESSAGE   = ''
    IMPORTING
      E_BELNR     = LV_BELNR
      E_RESULTMSG = LV_MSG
    TABLES
      T_BBKPF     = LT_BBKPF
      T_BBSEG     = LT_BBSEG.

  IF NOT LV_BELNR IS INITIAL.
    GV_BELNR_B = LV_BELNR.
  ELSE.
    GV_ERROR = 'X'.
    MESSAGE S000 WITH LV_MSG.
  ENDIF.
*--> 1. 정산금 처리

*--> 2. 수수료 처리
  IF GV_ERROR <> 'X'.

    CLEAR   : GT_BDCTAB, GT_RETMSG.
    REFRESH : GT_BDCTAB, GT_RETMSG.

    CLEAR: LT_BBKPF[], LT_BBKPF, LT_BBSEG[], LT_BBSEG.
    CLEAR : LV_MSG, LV_BELNR, LV_MODE, LV_GSBER, LV_KUNNR, LV_PRCTR,
            LV_VKGRP, LV_KURSF, LV_UPRLO, LV_KPRLO, LV_FLAG, LV_TABIX.

*___환율
    LV_KURSF = GT_MAIN-KURSF.

*___수수료손익
    WRITE : GV_UPRLO_S TO LV_UPRLO CURRENCY GV_UAERS NO-GROUPING,
            GV_KPRLO_S TO LV_KPRLO CURRENCY GV_KAERS NO-GROUPING.

    LV_UPRLO = ABS( LV_UPRLO ).
    LV_KPRLO = ABS( LV_KPRLO ).

    CONDENSE : LV_UPRLO, LV_KPRLO.

*___사업영역
    IF P_BUKRS = '1000'.
      LV_GSBER = '1200'.
    ELSEIF P_BUKRS = '2000'.
      LV_GSBER = '2900'.
    ENDIF.

*___고객송장 입력: 헤더데이타
    LT_BBKPF-TCODE = 'FB01'.
    LT_BBKPF-BLDAT = GV_BLDAT_BS  .     "증빙일
    LT_BBKPF-BLART = 'SZ'         .     "전표유형
    LT_BBKPF-BUKRS = GT_MAIN-BUKRS.     "회사코드
    LT_BBKPF-BUDAT = GV_BUDAT_BS  .     "전기일
    LT_BBKPF-MONAT = GV_BUDAT_BS+4(2).  "전기기간
    LT_BBKPF-WAERS = GV_UAERS     .     "통화
    LT_BBKPF-KURSF = LV_KURSF     .     "환율
    LT_BBKPF-WWERT = GT_MAIN-WWERT.     "환산일
    APPEND LT_BBKPF.

    CLEAR : LV_KUNNR,
            LV_PRCTR,
            LV_VKGRP.

*___첫 번째 개별 항목
    IF GV_UPRLO_S < 0. " 수수료손익. 수수료는 항상 지불하기에 정산금과 반대
      LV_KUNNR = GV_KUNNR_BS.     "팝업에서 입력한 수수료고객
      LT_BBSEG-NEWBS = '01'.      "전기키-수금
      LT_BBSEG-NEWKO = LV_KUNNR.  "계정-고객
    ELSE.
      LT_BBSEG-NEWBS = '31'.         "전기키-지급
*      LT_BBSEG-NEWKO = GT_MAIN-FCM.  "계정-FCM(거래선)
      LT_BBSEG-NEWKO = GV_KUNNR_BS. "팝업에서 입력한 수수료고객
    ENDIF.

    LT_BBSEG-WRBTR = LV_UPRLO.  "금액(USD)
    LT_BBSEG-DMBTR = LV_KPRLO.  "현지통화금액(KRW)
    LT_BBSEG-GSBER = LV_GSBER.  "사업영역
    IF LV_KUNNR > '0000300000' AND LV_KUNNR < '0000400000'.
      LT_BBSEG-SGTXT = '10001090'.
    ENDIF.
    APPEND LT_BBSEG. CLEAR LT_BBSEG.


    CLEAR : LV_FLAG.

    LOOP AT GT_HEAD.
      LV_TABIX = SY-TABIX.

      WRITE : GT_HEAD-UPRLO_S TO LV_UPRLO CURRENCY GT_HEAD-UAERS
                                        NO-GROUPING,
              GT_HEAD-KPRLO_S TO LV_KPRLO CURRENCY GT_HEAD-KAERS
                                        NO-GROUPING.

      LV_UPRLO = ABS( LV_UPRLO ).
      LV_KPRLO = ABS( LV_KPRLO ).

      CONDENSE : LV_UPRLO, LV_KPRLO.

*___다음 개별 항목
      IF GT_HEAD-UPRLO_S > 0. " 수수료손익. 수수료는 항상 지불하기에 정산금과 반대
        LT_BBSEG-NEWBS = '40'. "전기키 - 정산금과 반대
      ELSE.
        LT_BBSEG-NEWBS = '50'. "전기키 - 정산금과 반대
      ENDIF.
      LT_BBSEG-NEWKO = '0005150901'.    "계정-동선물정산손익

      LV_KUNNR = GT_HEAD-KUNNR.        "고객
      LV_PRCTR = GT_HEAD-PRCTR.        "손익센터
      LV_VKGRP = GT_HEAD-VKGRP.        "영업그룹

      LT_BBSEG-RKE_BUKRS      = GT_MAIN-BUKRS.
      LT_BBSEG-RKE_KNDNR      = LV_KUNNR .      "고객
      LT_BBSEG-RKE_PRCTR      = LV_PRCTR .      "손익센터
      LT_BBSEG-RKE_KMVKGR     = LV_VKGRP .      "영업그룹


      LT_BBSEG-WRBTR = LV_UPRLO.  "금액(USD)
      LT_BBSEG-DMBTR = LV_KPRLO.  "현지통화금액(KRW)
      LT_BBSEG-PRCTR = LV_PRCTR.  "손익센터
*<-

      APPEND LT_BBSEG. CLEAR LT_BBSEG.
    ENDLOOP.

* 전표생성 펑션 Call
    CLEAR: LV_BELNR, LV_MSG.
    LV_MODE = CTU_PARAMS-DISMODE.
    CALL FUNCTION 'ZFI_DOCUMENT_POSTING'
      EXPORTING
        I_BDC_MODE  = LV_MODE
        I_MESSAGE   = ''
      IMPORTING
        E_BELNR     = LV_BELNR
        E_RESULTMSG = LV_MSG
      TABLES
        T_BBKPF     = LT_BBKPF
        T_BBSEG     = LT_BBSEG.

    IF NOT LV_BELNR IS INITIAL.
      GV_BELNR_S = LV_BELNR.
    ELSE.
      GV_ERROR = 'X'.
      MESSAGE S000 WITH LV_MSG.
    ENDIF.
  ENDIF.
*<-- 2. 수수료 처리

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

*___ZLST1051 Update
  LOOP AT GT_1051.
    GT_1051-BELNR = GV_BELNR_B. " 1051에는 정산금 전표만 기입
    GT_1051-GJAHR = GV_BUDAT_BS(4).
    GT_1051-AENAM = SY-UNAME.
    GT_1051-AEDAT = SY-DATLO.
    GT_1051-AEZET = SY-TIMLO.

    MODIFY GT_1051.
  ENDLOOP.

  MODIFY ZNFT1051 FROM TABLE GT_1051.
  IF SY-SUBRC = 0.
    CLEAR : LV_FLAG.

    LOOP AT GT_HEAD.
      UPDATE ZNFT1052 SET KPRLO = GT_HEAD-KPRLO
                          UPRLO_B = GT_HEAD-UPRLO_B " 정산금손익(USD)
                          UPRLO_S = GT_HEAD-UPRLO_S " 수수료손익(USD)
                          KPRLO_B = GT_HEAD-KPRLO_B " 정산금손익(KRW)
                          KPRLO_S = GT_HEAD-KPRLO_S " 수수료손익(KRW)
                          GJAHR = GV_BUDAT_BS(4) " 기존 필드 = 정산금
                          BELNR = GV_BELNR_B     " 기존 필드 = 정산금
                          GJAHR_S = GV_BUDAT_BS(4) " 신규 필드 = 수수료
                          BELNR_S = GV_BELNR_S     " 신규 필드 = 수수료
                          AEDAT = SY-DATLO
                          AEZET = SY-TIMLO
                          AENAM = SY-UNAME
                    WHERE FCM   = GT_HEAD-FCM
                      AND ENDAT = GT_HEAD-ENDAT
                      AND PRCTR = GT_HEAD-PRCTR
                      AND VKGRP = GT_HEAD-VKGRP
                      AND KUNNR = GT_HEAD-KUNNR.
      IF SY-SUBRC <> 0.
        LV_FLAG = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF LV_FLAG IS INITIAL.
      PERFORM UPDATE_PROCESSING_STATUS USING LV_FLAG.
      IF LV_FLAG IS INITIAL.
        COMMIT WORK.
        CONCATENATE '정산금전표' GV_BELNR_B
                    ', 수수료전표' GV_BELNR_S
                    '생성 완료' INTO LV_TEXT SEPARATED BY SPACE.
        MESSAGE S003 WITH LV_TEXT.
      ELSE.
        ROLLBACK WORK.

*        PERFORM CANCEL_FI_DOC.
        PERFORM CANCEL_FI_DOC_BS.

        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '정산진행상태 저장 에러!'.
      ENDIF.
    ELSE.
      ROLLBACK WORK.

*      PERFORM CANCEL_FI_DOC.
      PERFORM CANCEL_FI_DOC_BS.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '선물손익 정산 테이블 Update Error!'.
    ENDIF.
  ELSE.
    ROLLBACK WORK.

*    PERFORM CANCEL_FI_DOC.
    PERFORM CANCEL_FI_DOC_BS.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선물손익 확정 테이블 Update Error!'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_KUNNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_KUNNR_BS
*&---------------------------------------------------------------------*
FORM CHECK_KUNNR  USING    PV_KUNNR_BS.
  DATA : LV_KUNNR_BS LIKE ZNFT0021-KUNNR.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
       EXPORTING
            INPUT  = PV_KUNNR_BS
       IMPORTING
            OUTPUT = PV_KUNNR_BS.

  SELECT SINGLE KUNNR
    INTO LV_KUNNR_BS
    FROM KNA1
   WHERE KUNNR  = PV_KUNNR_BS.

  IF SY-SUBRC <> 0.
    SELECT SINGLE LIFNR
      INTO LV_KUNNR_BS
      FROM LFA1
     WHERE LIFNR = PV_KUNNR_BS.

    IF SY-SUBRC <> 0.
      MESSAGE E003 WITH '존재하지 않는 수수료업체입니다.'.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CANCEL_FI_DOC_BS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CANCEL_FI_DOC_BS .

  " 1. 정산금
  CHECK GV_BELNR_B IS NOT INITIAL.

  CLEAR   : GT_BDCTAB, GT_RETMSG.
  REFRESH : GT_BDCTAB, GT_RETMSG.

  PERFORM DYNPRO USING :
                 'X' 'SAPMF05A'          '0105',
                 ' ' 'BDC_OKCODE'        '=BU',
                 ' ' 'RF05A-BELNS'       GV_BELNR_B,
                 ' ' 'BKPF-BUKRS'        P_BUKRS,
                 ' ' 'RF05A-GJAHS'       GV_BUDAT_BS(4),
                 ' ' 'UF05A-STGRD'       '01'.

  CALL TRANSACTION 'FB08' USING         GT_BDCTAB
                          OPTIONS  FROM CTU_PARAMS
                          MESSAGES INTO GT_RETMSG.

  " 2. 수수료
  CHECK GV_BELNR_S IS NOT INITIAL.

  CLEAR   : GT_BDCTAB, GT_RETMSG.
  REFRESH : GT_BDCTAB, GT_RETMSG.

  PERFORM DYNPRO USING :
                 'X' 'SAPMF05A'          '0105',
                 ' ' 'BDC_OKCODE'        '=BU',
                 ' ' 'RF05A-BELNS'       GV_BELNR_S,
                 ' ' 'BKPF-BUKRS'        P_BUKRS,
                 ' ' 'RF05A-GJAHS'       GV_BUDAT_BS(4),
                 ' ' 'UF05A-STGRD'       '01'.

  CALL TRANSACTION 'FB08' USING         GT_BDCTAB
                          OPTIONS  FROM CTU_PARAMS
                          MESSAGES INTO GT_RETMSG.

ENDFORM.
