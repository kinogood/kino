*----------------------------------------------------------------------*
***INCLUDE ZNFR2100F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  INIT_VARIABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_VARIABLE .

  CLEAR   : GT_1011, YGT_1011, ZNFT1010, YZNFT1010, GV_SAVE.
  REFRESH : GT_1011, YGT_1011.

  CASE 'X'.
    WHEN P_R01.
      GV_RQTYP = '1'.
    WHEN P_R02.
      GV_RQTYP = '2'.
    WHEN P_R03.
      GV_RQTYP = '3'.
    WHEN P_R04.
      GV_RQTYP = '4'.
    WHEN P_R05.
      GV_RQTYP = '5'.
  ENDCASE.

*___요청유형내역
  PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                 GV_RQTYP
                                 GV_RQTXT.

  CLEAR : GT_1011.

  GT_1011-H_NO1 = '1'.       "항번

  IF GV_RQTYP = '5'.           "재고헷지인 경우 기본값 'S'
    GT_1011-BY_SL = 'S'.       "Buy/Sell
  ELSE.
    GT_1011-BY_SL = 'B'.       "Buy/Sell
  ENDIF.

  "--> 비철 CME 관리 위한 주석
*  GT_1011-MEINS = 'TON'.     "단위
  GT_1011-WAERS = 'USD'.     "통화

  APPEND GT_1011.

ENDFORM.                    " INIT_VARIABLE
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_LAYO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_LAYO .

  GS_LAYOUT-GRID_TITLE = '< 항번정보 >'.
  GS_LAYOUT-SMALLTITLE = 'X'.
*  gs_layout-NO_HEADERS = 'X'.
*  GS_LAYOUT-CWIDTH_OPT = 'X'.
*  GS_LAYOUT-EDIT       = 'X'.
  GS_LAYOUT-ZEBRA      = 'X'.
  GS_LAYOUT-SMALLTITLE = 'X'.
  GS_LAYOUT-SEL_MODE   = 'A'.              "select multiple lines
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

  GV_ITAB = 'GT_1011'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT
                                  USING :
      'H_NO1'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      ' '            'H_NO1'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      '비철구분'     'NFKEY'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' 'X',

      'BY_SL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 6
      ' '            'BY_SL'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' 'X',

*.....사용자 혼돈 방지를 위해 '만기월' -> '최초요청만기월'로 변경
*     (C20121205_29599 Req.by 박선아 2012/12/27)
      'ENDMM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      '최초요청만기월' 'ENDMM' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' 'X',

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '            'EMENG'  'ZNFT1011'  ' ' ' '    ' ' ' ' ' ' 'X',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'MEINS'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'CONNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'CONNO'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' 'X',

      'COTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '            'COTXT'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'NFCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 10
      ' '            'NFCTR'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'NTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '사업부'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'PRCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 10
      ' '            'PRCTR'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'PTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '손익센터'   ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'VKGRP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 4
      ' '            'VKGRP'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'VTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '영업그룹'   ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'KUNNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'KUNNR'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'NCUST'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '            'NCUST'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'SALER'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'SALER'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRIND'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 15
      '가격구분'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'SUJUP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 12
      '비철수주가'   ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'WAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      ' '            'WAERS'  'ZNFT1001'  ' ' ' '    'X' ' ' ' ' ' ',

      'BIGO4'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      ' '            'BIGO4'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' 'X'.

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

  IF PV_FNAME = 'ENDMM' OR PV_FNAME = 'CONNO'.
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
  LOOP AT GT_1011.
    CLEAR   : LT_CELLTAB, LT_COLOR.
    REFRESH : LT_CELLTAB, LT_COLOR.

    PERFORM FILL_CELLTAB_C CHANGING LT_CELLTAB.
    PERFORM FILL_COLOR     CHANGING LT_COLOR.

    REFRESH : GT_1011-CELLTAB, GT_1011-F_COL.

    INSERT LINES OF LT_CELLTAB INTO TABLE GT_1011-CELLTAB.
    INSERT LINES OF LT_COLOR   INTO TABLE GT_1011-F_COL.

    MODIFY GT_1011.
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
      IF GV_SAVE = 'X'.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                         + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
      ELSE.
*        IF ( GV_RQTYP <> '4' AND GV_RQTYP <> '5' ) AND
*           LS_CELLTAB-FIELDNAME = 'BY_SL'.
*          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
**                           + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
*        ELSE.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*                           + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
*        ENDIF.
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
      IF L_FIELDCAT-EDIT IS INITIAL OR GV_SAVE = 'X'.
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

  SET HANDLER GC_EVENT_HANDLER->HANDLE_TOOLBAR       FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_DOUBLE_CLICK  FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_DATA_CHANGED  FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_DATA_CHANGED_FINISHED
          FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_USER_COMMAND  FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_ONF4          FOR GC_ALV_GRID.

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
      IT_OUTTAB            = GT_1011[].

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

  CLEAR : GT_1011-CHECK.
  MODIFY GT_1011 TRANSPORTING CHECK
                 WHERE H_NO1 IS NOT INITIAL.

  LOOP AT GT_ROWS INTO GS_ROWS.
    READ TABLE GT_1011 INDEX GS_ROWS-INDEX.
    IF SY-SUBRC = 0.
      GT_1011-CHECK = 'X'.
      MODIFY GT_1011 INDEX GS_ROWS-INDEX.
    ENDIF.
  ENDLOOP.

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

  REFRESH : GT_ROWS.

  LOOP AT GT_1011.
    IF GT_1011-CHECK = 'X'.
      CLEAR : GS_ROWS.
      GS_ROWS-INDEX = SY-TABIX.
      APPEND GS_ROWS TO GT_ROWS.
    ENDIF.
  ENDLOOP.

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

*___행추가
  CLEAR LS_TOOLBAR.
  MOVE 'RADD'                TO   LS_TOOLBAR-FUNCTION.
  MOVE '@17@'                TO   LS_TOOLBAR-ICON.
  MOVE '행추가'              TO   LS_TOOLBAR-QUICKINFO.
  MOVE ' 행추가'             TO   LS_TOOLBAR-TEXT.
  MOVE ' '                   TO   LS_TOOLBAR-DISABLED.
  APPEND LS_TOOLBAR          TO   R_OBJECT->MT_TOOLBAR.

*___행삭제
  CLEAR LS_TOOLBAR.
  MOVE 'RDEL'                TO   LS_TOOLBAR-FUNCTION.
  MOVE '@18@'                TO   LS_TOOLBAR-ICON.
  MOVE '행삭제'              TO   LS_TOOLBAR-QUICKINFO.
  MOVE ' 행삭제'             TO   LS_TOOLBAR-TEXT.
  MOVE ' '                   TO   LS_TOOLBAR-DISABLED.
  APPEND LS_TOOLBAR          TO   R_OBJECT->MT_TOOLBAR.

*___Separator Line
  CLEAR LS_TOOLBAR.
  MOVE   3                  TO   LS_TOOLBAR-BUTN_TYPE.
  APPEND LS_TOOLBAR         TO   R_OBJECT->MT_TOOLBAR.

*___일괄적용
  CLEAR LS_TOOLBAR.
  MOVE 'APLY'                TO   LS_TOOLBAR-FUNCTION.
  MOVE '@HB@'                TO   LS_TOOLBAR-ICON.
  MOVE '일괄적용'            TO   LS_TOOLBAR-QUICKINFO.
  MOVE ' 일괄적용'           TO   LS_TOOLBAR-TEXT.
  MOVE ' '                   TO   LS_TOOLBAR-DISABLED.
  APPEND LS_TOOLBAR          TO   R_OBJECT->MT_TOOLBAR.

*___Separator Line
  CLEAR LS_TOOLBAR.
  MOVE   3                  TO   LS_TOOLBAR-BUTN_TYPE.
  APPEND LS_TOOLBAR         TO   R_OBJECT->MT_TOOLBAR.

*___전체선택
  CLEAR LS_TOOLBAR.
  MOVE 'ASEL'                TO   LS_TOOLBAR-FUNCTION.
  MOVE '@4B@'                TO   LS_TOOLBAR-ICON.
  MOVE '전체선택'            TO   LS_TOOLBAR-QUICKINFO.
  MOVE ' '                   TO   LS_TOOLBAR-TEXT.
  MOVE ' '                   TO   LS_TOOLBAR-DISABLED.
  APPEND LS_TOOLBAR          TO   R_OBJECT->MT_TOOLBAR.

*___선택해제
  CLEAR LS_TOOLBAR.
  MOVE 'DSEL'                TO   LS_TOOLBAR-FUNCTION.
  MOVE '@4D@'                TO   LS_TOOLBAR-ICON.
  MOVE '전체선택해제'        TO   LS_TOOLBAR-QUICKINFO.
  MOVE ' '                   TO   LS_TOOLBAR-TEXT.
  MOVE ' '                   TO   LS_TOOLBAR-DISABLED.
  APPEND LS_TOOLBAR          TO   R_OBJECT->MT_TOOLBAR.

ENDFORM.                    " TOOLBAR_PROS
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
  GS_F4-FIELDNAME = 'CONNO'.  "계약번호
  GS_F4-REGISTER  = 'X'.
  APPEND GS_F4 TO GT_F4.

  GS_F4-FIELDNAME = 'ENDMM'.  "만기월
  GS_F4-REGISTER  = 'X'.
  APPEND GS_F4 TO GT_F4.

  CALL METHOD GC_ALV_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = GT_F4.

ENDFORM.                    " SET_F4HELP_FIELD
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

  IF GC_ALV_GRID->IS_READY_FOR_INPUT( ) = 0.  "조회모드
    EXIT.
  ENDIF.

  CASE E_FIELDNAME.
    WHEN 'CONNO'.  "계약번호
      READ TABLE GT_1011 INDEX ES_ROW_NO-ROW_ID.
      IF SY-SUBRC = 0.
        PERFORM F4HELP_CONNO.
        PERFORM GET_CONTRACT_DETAIL USING ' '
                                          GV_ERROR.

        MODIFY GT_1011 INDEX ES_ROW_NO-ROW_ID.
      ENDIF.

    WHEN 'ENDMM'.  "만기월
      CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
        EXPORTING
          ACTUAL_MONTH   = SY-DATLO(6)
        IMPORTING
          SELECTED_MONTH = GT_1011-ENDMM.

      IF GT_1011-ENDMM < SY-DATLO(6).
        MESSAGE I001 DISPLAY LIKE 'E'
           WITH '만기월은 당월 이후로 입력해야 합니다.'.
      ELSE.
        MODIFY GT_1011 INDEX ES_ROW_NO-ROW_ID TRANSPORTING ENDMM.
      ENDIF.

  ENDCASE.

** To avoid standard f4-help.
  ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.

ENDFORM.                                                    " ON_F4
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_PROS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM USER_COMMAND_PROS  USING  E_UCOMM.

  CASE E_UCOMM.
    WHEN 'RADD'.     "행추가
      PERFORM ADD_ROW.

    WHEN 'RDEL'.     "행삭제
      PERFORM DEL_ROW.

    WHEN 'APLY'.     "일괄적용
      PERFORM APPLY_ALL.

    WHEN 'ASEL' OR 'DSEL'.
      IF E_UCOMM = 'ASEL'.
        GT_1011-CHECK = 'X'.
      ELSE.
        CLEAR : GT_1011-CHECK.
      ENDIF.

      MODIFY GT_1011 TRANSPORTING CHECK
                     WHERE H_NO1 IS NOT INITIAL.

  ENDCASE.

ENDFORM.                    " USER_COMMAND_PROS
*&---------------------------------------------------------------------*
*&      Form  ADD_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ADD_ROW .
  DATA: LV_H_NO1    LIKE ZNFT1011-H_NO1.

  IF GV_SAVE = 'X'.
    MESSAGE S003 WITH '저장 후에는 사용할 수 없습니다.'.
    EXIT.
  ENDIF.

  SORT GT_1011 BY H_NO1 DESCENDING.

  CLEAR : GT_1011.

  READ TABLE GT_1011 INDEX 1.

  LV_H_NO1 = GT_1011-H_NO1 + 1.

  SORT GT_1011 BY H_NO1.

  CLEAR : GT_1011.

  GT_1011-H_NO1 = LV_H_NO1.  "항번

  IF GV_RQTYP = '5'.           "재고헷지인 경우 기본값 'S'
    GT_1011-BY_SL = 'S'.       "Buy/Sell
  ELSE.
    GT_1011-BY_SL = 'B'.       "Buy/Sell
  ENDIF.

  "--> 비철 CME 관리 위한 주석
*  GT_1011-MEINS = 'TON'.     "단위
  GT_1011-WAERS = 'USD'.     "통화

  APPEND GT_1011.

ENDFORM.                    " ADD_ROW
*&---------------------------------------------------------------------*
*&      Form  DEL_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEL_ROW .

  IF GV_SAVE = 'X'.
    MESSAGE S003 WITH '저장 후에는 사용할 수 없습니다.'.
    EXIT.
  ENDIF.

  READ TABLE GT_1011 WITH KEY CHECK = 'X'.
  IF SY-SUBRC = 0.
    PERFORM POPUP_TO_CONFIRM USING '삭제'
                                   '선택한 라인을 삭제하시겠습니까?'
                                   '2'
                                   GV_ANSWER.
    IF GV_ANSWER = '1'.
      DELETE GT_1011 WHERE CHECK = 'X'.

      MESSAGE S003 WITH '삭제되었습니다.'.
    ELSE.
      MESSAGE S003 WITH '작업이 취소되었습니다.'.
    ENDIF.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택된 라인이 없습니다.'.
  ENDIF.

ENDFORM.                    " DEL_ROW
*&---------------------------------------------------------------------*
*&      Form  APPLY_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM APPLY_ALL .
  DATA: LV_LINE     TYPE I.

  IF GV_SAVE = 'X'.
    MESSAGE S003 WITH '저장 후에는 사용할 수 없습니다.'.
    EXIT.
  ENDIF.

  CLEAR : LV_LINE, GV_ERROR.

  DESCRIBE TABLE GT_1011 LINES LV_LINE.
  IF LV_LINE < 2.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '라인이 두줄 이상인 경우'
            '사용 가능합니다.'.
    EXIT.
  ENDIF.

  DESCRIBE TABLE GT_COLS LINES LV_LINE.

  IF LV_LINE < 1.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택된 열이 없습니다.'.
    EXIT.
*  ELSEIF LV_LINE > 1.
*    MESSAGE S003 DISPLAY LIKE 'E'
*       WITH '하나의 열만 선택하시기 바랍니다.'.
*    EXIT.
  ELSE.
    LOOP AT GT_COLS INTO GS_COLS.
      IF GS_COLS-FIELDNAME <> 'NFKEY' AND
         GS_COLS-FIELDNAME <> 'BY_SL' AND
         GS_COLS-FIELDNAME <> 'CONNO' AND
         GS_COLS-FIELDNAME <> 'BIGO4'.
        GV_ERROR = 'X'.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '일괄적용 대상이 아닌 열이 선택되었습니다.'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF GV_ERROR IS NOT INITIAL.
      EXIT.
    ENDIF.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM
    USING '확인'
          '선택된 열의 첫라인 값을 모든 라인에 적용하시겠습니까?'
          '2'
          GV_ANSWER.
  IF GV_ANSWER = '1'.
    READ TABLE GT_1011 INDEX 1.
    IF SY-SUBRC = 0.
      LOOP AT GT_COLS INTO GS_COLS.
        MODIFY GT_1011 TRANSPORTING (GS_COLS-FIELDNAME)
                       WHERE H_NO1 IS NOT INITIAL.
      ENDLOOP.

      LOOP AT GT_1011.
        PERFORM GET_CONTRACT_DETAIL USING ' '
                                          GV_ERROR.

        MODIFY GT_1011.
      ENDLOOP.

      MESSAGE S003 WITH '일괄적용하였습니다.'.
    ENDIF.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " APPLY_ALL
*&---------------------------------------------------------------------*
*&      Form  F4HELP_CONNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F4HELP_CONNO .

  PERFORM GET_CONTRACT_INFO.

  CHECK GT_CONNO[] IS NOT INITIAL.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'BUKRS'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'COTYP'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFS1000'.
  IT_FIELDS-FIELDNAME  = 'COTYP_NM'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'NFCTR'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT0005'.
  IT_FIELDS-FIELDNAME  = 'NTEXT'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'PRCTR'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT0004'.
  IT_FIELDS-FIELDNAME  = 'PTEXT'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'VKGRP'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT0003'.
  IT_FIELDS-FIELDNAME  = 'VTEXT'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'CONNO'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'ERDAT'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'COTXT'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'KUNNR'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'NCUST'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'SUJUD'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'SALER'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1001'.
  IT_FIELDS-FIELDNAME  = 'NFKEY'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFS1001'.
  IT_FIELDS-FIELDNAME  = 'PRIND'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFS1001'.
  IT_FIELDS-FIELDNAME  = 'SUJUP'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFS1001'.
  IT_FIELDS-FIELDNAME  = 'SUJUQ'.
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
      FULL_TABLE                   = GT_CONNO
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_CONNO INDEX LD_TABIX.
  IF SY-SUBRC = 0.
    GT_1011-BUKRS = GT_CONNO-BUKRS.
    GT_1011-CONNO = GT_CONNO-CONNO.
  ENDIF.

ENDFORM.                    " F4HELP_CONNO
*&---------------------------------------------------------------------*
*&      Form  GET_CONTRACT_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CONTRACT_INFO .
  DATA: WHERE_CLAUSE(200).

  RANGES: LR_COTYP  FOR ZNFT1000-COTYP.
  RANGES: LR_CDATE  FOR ZNFT1000-ERDAT.

  CLEAR   : GT_CONNO, LR_COTYP, LR_CDATE, WHERE_CLAUSE.
  REFRESH : GT_CONNO, LR_COTYP, LR_CDATE.

  LR_COTYP-SIGN   = 'I'.
  LR_COTYP-OPTION = 'EQ'.
  LR_COTYP-LOW    = GV_RQTYP.
  APPEND LR_COTYP.

*.최근 한달내에 생성된 계약건만 조회.
  LR_CDATE-SIGN   = 'I'.
  LR_CDATE-OPTION = 'BT'.
  LR_CDATE-LOW    = SY-DATUM - 30.
  LR_CDATE-HIGH   = SY-DATUM.
  APPEND LR_CDATE.

*  CASE GV_RQTYP.
*    WHEN '1' OR '2'.      "Firm Price/고객요청
*      LR_COTYP-LOW = '1'.  APPEND LR_COTYP.
*      LR_COTYP-LOW = '2'.  APPEND LR_COTYP.
*
*    WHEN '3'.      "경상선물
*      LR_COTYP-LOW = '1'.  APPEND LR_COTYP.
*      LR_COTYP-LOW = '2'.  APPEND LR_COTYP.
*      LR_COTYP-LOW = '3'.  APPEND LR_COTYP.
*
*    WHEN '4'.      "내부선물
*      LR_COTYP-LOW = '4'.  APPEND LR_COTYP.
*
*    WHEN '5'.      "재고헷지
*      LR_COTYP-LOW = '5'.  APPEND LR_COTYP.
*
*  ENDCASE.

  IF GV_NFCTR IS NOT INITIAL.
    IF WHERE_CLAUSE IS INITIAL.
      CONCATENATE 'A~NFCTR = ''' GV_NFCTR ''''
             INTO WHERE_CLAUSE.
    ELSE.
      CONCATENATE WHERE_CLAUSE 'AND A~NFCTR = ''' GV_NFCTR ''''
             INTO WHERE_CLAUSE.
    ENDIF.
  ENDIF.

  IF GV_PRCTR IS NOT INITIAL.
    IF WHERE_CLAUSE IS INITIAL.
      CONCATENATE 'A~PRCTR = ''' GV_PRCTR ''''
             INTO WHERE_CLAUSE.
    ELSE.
      CONCATENATE WHERE_CLAUSE 'AND A~PRCTR = ''' GV_PRCTR ''''
             INTO WHERE_CLAUSE.
    ENDIF.
  ENDIF.

  IF GV_VKGRP IS NOT INITIAL.
    IF WHERE_CLAUSE IS INITIAL.
      CONCATENATE 'A~VKGRP = ''' GV_VKGRP ''''
             INTO WHERE_CLAUSE.
    ELSE.
      CONCATENATE WHERE_CLAUSE 'AND A~VKGRP = ''' GV_VKGRP ''''
             INTO WHERE_CLAUSE.
    ENDIF.
  ENDIF.

  IF GT_1011-NFKEY IS NOT INITIAL.
    IF WHERE_CLAUSE IS INITIAL.
      CONCATENATE 'B~NFKEY = ''' GT_1011-NFKEY ''''
             INTO WHERE_CLAUSE.
    ELSE.
      CONCATENATE WHERE_CLAUSE 'AND B~NFKEY = ''' GT_1011-NFKEY ''''
             INTO WHERE_CLAUSE.
    ENDIF.
  ENDIF.

  SELECT A~BUKRS  "회사코드
         A~COTYP  "계약유형
         A~NFCTR  "사업부
         A~PRCTR  "손익센터
         A~VKGRP  "영업그룹
         A~CONNO  "계약번호
         A~ERDAT  "생성일
         A~COTXT  "계약명(PJT명)
         A~KUNNR  "고객코드
         A~NCUST  "고객명
         A~SUJUD  "수주일
         A~SALER  "영업담당자
         B~NFKEY  "비철구분
         B~EMENG  "수주량
         B~MEINS  "단위
    INTO CORRESPONDING FIELDS OF TABLE GT_CONNO
    FROM ZNFT1000 AS A
   INNER JOIN ZNFT1001 AS B
      ON A~CONNO = B~CONNO
   WHERE A~CSTAT = 'L'
     AND A~COTYP IN LR_COTYP
     AND A~ERDAT IN LR_CDATE
     AND (WHERE_CLAUSE).

  IF SY-SUBRC <> 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '조건에 해당하는 계약이 존재하지 않습니다.'.
  ENDIF.

  LOOP AT GT_CONNO.
*___가격구분/비철수주가격
    PERFORM PRICE_CLASSIFICATION USING GT_CONNO-CONNO
                                       GT_CONNO-NFKEY
                                       GT_CONNO-PRIND
                                       GT_CONNO-SUJUP
                                       GV_ERROR.

*   - 계약유형 : FIC23 & 2012.05.30
    PERFORM DOMAIN_VALUE_GET USING 'ZCOTYP'
                                   GT_CONNO-COTYP
                                   GT_CONNO-COTYP_NM.

*   - 사업부
    PERFORM GET_NFCTR_DESC USING GT_CONNO-BUKRS
                                 GT_CONNO-NFCTR
                                 GT_CONNO-NTEXT.

*   - 손익센터
    PERFORM GET_PRCTR_DESC USING GT_CONNO-BUKRS
                                 GT_CONNO-PRCTR
                                 GT_CONNO-PTEXT.

*   - 영업그룹
    PERFORM GET_VKGRP_DESC USING GT_CONNO-BUKRS
                                 GT_CONNO-VKGRP
                                 GT_CONNO-VTEXT.

*___수주량
    WRITE : GT_CONNO-EMENG TO GT_CONNO-SUJUQ UNIT GT_CONNO-MEINS.

    MODIFY GT_CONNO.
  ENDLOOP.

ENDFORM.                    " GET_CONTRACT_INFO
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED  USING   E_MODIFIED
                                    ET_GOOD_CELLS TYPE LVC_T_MODI.
  DATA: LS_GOOD_CELLS TYPE LVC_S_MODI.

  DATA: LV_DEC  TYPE P DECIMALS 3.

  LOOP AT ET_GOOD_CELLS INTO LS_GOOD_CELLS.
    CASE LS_GOOD_CELLS-FIELDNAME.
      WHEN 'NFKEY' OR 'CONNO'.
        READ TABLE GT_1011 INDEX LS_GOOD_CELLS-ROW_ID.
        IF SY-SUBRC = 0.
          PERFORM GET_CONTRACT_DETAIL USING ' '
                                            GV_ERROR.

          MODIFY GT_1011 INDEX LS_GOOD_CELLS-ROW_ID.
        ENDIF.

      WHEN 'EMENG'.
        CLEAR : LV_DEC.

        LV_DEC = FRAC( LS_GOOD_CELLS-VALUE ).

        IF LV_DEC IS NOT INITIAL.
          MESSAGE I001 DISPLAY LIKE 'E'
             WITH '요청량은 정수로 입력해야 합니다.'.

          CLEAR : GT_1011-EMENG.

          MODIFY GT_1011 INDEX LS_GOOD_CELLS-ROW_ID TRANSPORTING EMENG.
        ENDIF.

      WHEN 'ENDMM'.
        CHECK LS_GOOD_CELLS-VALUE IS NOT INITIAL AND
              LS_GOOD_CELLS-VALUE <> '000000'.

        IF LS_GOOD_CELLS-VALUE < SY-DATLO(6).
          MESSAGE I001 DISPLAY LIKE 'E'
             WITH '만기월은 당월 이후로 입력해야 합니다.'.

          CLEAR : GT_1011-ENDMM.

          MODIFY GT_1011 INDEX LS_GOOD_CELLS-ROW_ID TRANSPORTING ENDMM.
        ENDIF.

        IF LS_GOOD_CELLS-VALUE+4(2) < '01' OR
           LS_GOOD_CELLS-VALUE+4(2) > '12'.
          MESSAGE I001 DISPLAY LIKE 'E'
             WITH '만기월을 점검하시기 바랍니다.'.

          CLEAR : GT_1011-ENDMM.

          MODIFY GT_1011 INDEX LS_GOOD_CELLS-ROW_ID TRANSPORTING ENDMM.
        ENDIF.

    ENDCASE.
  ENDLOOP.

ENDFORM.                    " DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*&      Form  GET_CONTRACT_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CONTRACT_DETAIL USING PV_FLAG
                               PV_ERROR.
  DATA: LV_CSTAT LIKE ZNFT1000-CSTAT,
        LV_COTYP LIKE ZNFT1000-COTYP.

  CLEAR : GT_1011-COTXT, GT_1011-NFCTR, GT_1011-PRCTR,
          GT_1011-VKGRP, GT_1011-KUNNR, GT_1011-NCUST,
          GT_1011-SALER, GT_1011-PRIND, GT_1011-SUJUP,
          LV_CSTAT,      LV_COTYP,      PV_ERROR.

  CHECK GT_1011-CONNO IS NOT INITIAL.

  SELECT SINGLE BUKRS
                COTXT
                NFCTR
                PRCTR
                VKGRP
                KUNNR
                NCUST
                SALER
                CSTAT
                COTYP
    INTO (GT_1011-BUKRS,
          GT_1011-COTXT, GT_1011-NFCTR,
          GT_1011-PRCTR, GT_1011-VKGRP,
          GT_1011-KUNNR, GT_1011-NCUST,
          GT_1011-SALER, LV_CSTAT,
          LV_COTYP)
    FROM ZNFT1000
   WHERE CONNO = GT_1011-CONNO.

  IF SY-SUBRC <> 0.
    PV_ERROR = 'X'.
  ELSEIF LV_CSTAT <> 'L'.
    PV_ERROR = '1'.
  ELSE.
    IF GV_RQTYP <> LV_COTYP.
      PV_ERROR = '2'.
    ENDIF.

*    CASE GV_RQTYP.
*      WHEN '1' OR '2'.
*        IF LV_COTYP <> '1' AND LV_COTYP <> '2'.
*          PV_ERROR = '2'.
*        ENDIF.
*
*      WHEN '3'.
*        IF LV_COTYP <> '1' AND LV_COTYP <> '2' AND
*           LV_COTYP <> '3'.
*          PV_ERROR = '2'.
*        ENDIF.
*
*      WHEN '4'.
*        IF LV_COTYP <> '4'.
*          PV_ERROR = '2'.
*        ENDIF.
*
*      WHEN '5'.
*        IF LV_COTYP <> '5'.
*          PV_ERROR = '2'.
*        ENDIF.
*
*    ENDCASE.
  ENDIF.

  IF PV_ERROR IS NOT INITIAL.
    IF PV_FLAG IS INITIAL.
      IF PV_ERROR = 'X'.
        MESSAGE I003 DISPLAY LIKE 'E'
           WITH '계약번호' GT_1011-CONNO
                '은(는) 존재하지 않습니다.'.
      ELSEIF PV_ERROR = '1'.
        MESSAGE I003 DISPLAY LIKE 'E'
           WITH '계약번호' GT_1011-CONNO
                '은(는) 취소되거나 마감된'
                '계약번호입니다.'.
      ELSE.
        MESSAGE I003 DISPLAY LIKE 'E'
           WITH '선물요청유형과 계약유형을'
                '확인하시기 바랍니다.'.
      ENDIF.
    ENDIF.

    CLEAR : GT_1011-BUKRS,
            GT_1011-CONNO, GT_1011-COTXT, GT_1011-NFCTR,
            GT_1011-PRCTR, GT_1011-VKGRP, GT_1011-KUNNR,
            GT_1011-NCUST, GT_1011-SALER, GT_1011-PRIND,
            GT_1011-SUJUP.

    EXIT.
  ENDIF.

  IF GT_1011-KUNNR IS NOT INITIAL.
    PERFORM GET_KUNNR_DESC USING GT_1011-KUNNR
                                 GT_1011-NCUST.
  ENDIF.

  IF GT_1011-NFCTR IS NOT INITIAL.
*   - 사업부 : FIC23 & 2012.05.30
    PERFORM GET_NFCTR_DESC USING GT_1011-BUKRS
                                 GT_1011-NFCTR
                                 GT_1011-NTEXT.
  ENDIF.

  IF GT_1011-PRCTR IS NOT INITIAL.
*   - 손익센터 : FIC23 & 2012.05.30
    PERFORM GET_PRCTR_DESC USING GT_1011-BUKRS
                                 GT_1011-PRCTR
                                 GT_1011-PTEXT.
  ENDIF.

  IF GT_1011-VKGRP IS NOT INITIAL.
*   - 영업그룹 : FIC23 & 2012.05.30
    PERFORM GET_VKGRP_DESC USING GT_1011-BUKRS
                                 GT_1011-VKGRP
                                 GT_1011-VTEXT.
  ENDIF.

  IF GT_1011-NFKEY IS NOT INITIAL.
*___가격구분/비철수주가
    PERFORM PRICE_CLASSIFICATION USING GT_1011-CONNO
                                       GT_1011-NFKEY
                                       GT_1011-PRIND
                                       GT_1011-SUJUP
                                       PV_ERROR.

*___2012.08.06 by SDC24(구영헌C 요청)
*   계약수량 기본값을 가져오지 않도록 수정
**   2012.05.30 BY 엄기희
**   계약번호 & 비철구분에 해당하는 수주량을 기본적으로 세팅
*    SELECT SINGLE EMENG INTO GT_1011-EMENG
*      FROM ZNFT1001
*     WHERE CONNO EQ GT_1011-CONNO
*       AND NFKEY EQ GT_1011-NFKEY.
*
*    IF PV_ERROR IS NOT INITIAL AND PV_FLAG IS INITIAL.
*      MESSAGE I003 DISPLAY LIKE 'E'
*         WITH '계약번호-비철구분' GT_1011-CONNO GT_1011-NFKEY
*              '이(가) 존재하지 않습니다.'.
*    ENDIF.
  ENDIF.

"--> 비철 CME 관리 추가
**** TON 고정 아닌 계약 단위를 읽어와야 함
  SELECT SINGLE MEINS
    INTO GT_1011-MEINS
    FROM ZNFT1001
   WHERE CONNO = GT_1011-CONNO.
"<-- 비철 CME 관리 추가

ENDFORM.                    " GET_CONTRACT_DETAIL
*&---------------------------------------------------------------------*
*&      Form  SAVE_FUTURES_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_FUTURES_REQUEST USING PV_FLAG.

  PERFORM CHECK_FUTURES_REQ_DATA USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  IF PV_FLAG IS INITIAL.
    PERFORM POPUP_TO_CONFIRM USING '저장'
                                   '선물요청을 저장하시겠습니까?'
                                   '1'
                                   GV_ANSWER.
  ELSE.
    PERFORM POPUP_TO_CONFIRM
      USING '저장'
            '선물요청을 결재요청 하시겠습니까?'
            '1'
            GV_ANSWER.
  ENDIF.

  IF GV_ANSWER = '1'.
    IF PV_FLAG IS NOT INITIAL.
      CLEAR : GV_PERNR, GV_ENAME.

      CALL SCREEN 0200 STARTING AT 20 5.

      IF OK_SAVE = 'CANC'.
        MESSAGE S003 WITH '작업이 취소되었습니다.'.
        EXIT.
      ENDIF.
    ENDIF.

    PERFORM SAVE_FUTURES_REQ_DATA USING PV_FLAG.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.


ENDFORM.                    " SAVE_FUTURES_REQUEST
*&---------------------------------------------------------------------*
*&      Form  CHECK_FUTURES_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_FUTURES_REQ_DATA USING PV_ERROR.
  DATA: LV_FLAG.

  CLEAR : PV_ERROR.

  IF GT_1011[] IS INITIAL.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선물요청정보가 없습니다.'.
    EXIT.
  ENDIF.

  LOOP AT GT_1011 WHERE NFKEY IS NOT INITIAL
                     OR ENDMM IS NOT INITIAL
                     OR EMENG IS NOT INITIAL
                     OR CONNO IS NOT INITIAL.
    IF GT_1011-NFKEY IS INITIAL.
      PV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '항번' GT_1011-H_NO1
              '의 비철구분이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

    IF GT_1011-CONNO IS INITIAL.
      PV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '항번' GT_1011-H_NO1
              '의 계약번호가 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

    PERFORM GET_CONTRACT_DETAIL USING 'X'
                                      LV_FLAG.

    IF LV_FLAG IS NOT INITIAL.
      PV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '항번' GT_1011-H_NO1
              '의 계약번호와 비철구분을 확인하시기 바랍니다.'.
      EXIT.
    ENDIF.

    IF GT_1011-BY_SL IS INITIAL.
      PV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '항번' GT_1011-H_NO1
              '의 Buy/Sell 값이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.

    IF GT_1011-ENDMM IS INITIAL.
      PV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '항번' GT_1011-H_NO1
              '의 만기월이 입력되지 않았습니다.'.
      EXIT.
    ELSE.
      IF GT_1011-ENDMM < SY-DATLO(6).
        PV_ERROR = 'X'.

        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '항번' GT_1011-H_NO1
                '의 만기월이 당월 이전입니다.'.
        EXIT.
      ENDIF.
    ENDIF.

    IF GT_1011-EMENG IS INITIAL.
      PV_ERROR = 'X'.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '항번' GT_1011-H_NO1
              '의 요청수량이 입력되지 않았습니다.'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF SY-SUBRC <> 0.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선물요청정보가 없습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_FUTURES_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  SAVE_FUTURES_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_FUTURES_REQ_DATA USING PV_FLAG.
  DATA: LV_CONNO    LIKE ZNFT1011-CONNO,
        LV_H_NO1    LIKE ZNFT1011-H_NO1,
        LV_REQNO1   LIKE ZNFT1010-REQNO,
        LV_REQNO2   LIKE ZNFT1010-REQNO,
        LV_TEXT(50),
        LV_FLAG.

  CLEAR   : GT_1010N, GT_1011N, LV_CONNO, LV_H_NO1, LV_FLAG.
  REFRESH : GT_1010N, GT_1011N.

  SORT GT_1011 BY CONNO H_NO1.

  LOOP AT GT_1011 WHERE NFKEY IS NOT INITIAL
                     OR ENDMM IS NOT INITIAL
                     OR EMENG IS NOT INITIAL
                     OR CONNO IS NOT INITIAL.
    IF LV_CONNO <> GT_1011-CONNO.
*___헤더정보 생성
      CLEAR : GT_1010N, LV_H_NO1.

      PERFORM GET_REQUEST_NO.

      GT_1010N-BUKRS = P_BUKRS.
      GT_1010N-RQTYP = GV_RQTYP.
*      GT_1010N-REQER = SY-UNAME.   "요청자

      IF PV_FLAG = 'X'.
        GT_1010N-RSTAT = '2'.   "승인대기
      ELSE.
        GT_1010N-RSTAT = '1'.   "입력
      ENDIF.

      GT_1010N-ERDAT = SY-DATLO.
      GT_1010N-ERZET = SY-TIMLO.
      GT_1010N-ERNAM = SY-UNAME.
      GT_1010N-AEDAT = SY-DATLO.
      GT_1010N-AEZET = SY-TIMLO.
      GT_1010N-AENAM = SY-UNAME.

      APPEND GT_1010N.

      IF LV_CONNO IS INITIAL.
        LV_REQNO1 = GT_1010N-REQNO.
        LV_REQNO2 = GT_1010N-REQNO.
      ELSE.
        LV_REQNO2 = GT_1010N-REQNO.
      ENDIF.

      LV_CONNO = GT_1011-CONNO.
    ENDIF.

    CLEAR : GT_1011N.

    LV_H_NO1 = LV_H_NO1 + 1.

    MOVE-CORRESPONDING GT_1011 TO GT_1011N.

    GT_1011N-REQNO = GT_1010N-REQNO.
    GT_1011N-H_NO1 = LV_H_NO1.
    GT_1011N-ERDAT = SY-DATLO.
    GT_1011N-ERZET = SY-TIMLO.
    GT_1011N-ERNAM = SY-UNAME.
    GT_1011N-AEDAT = SY-DATLO.
    GT_1011N-AEZET = SY-TIMLO.
    GT_1011N-AENAM = SY-UNAME.

    APPEND GT_1011N.
  ENDLOOP.

  INSERT ZNFT1010 FROM TABLE GT_1010N.
  IF SY-SUBRC = 0.
    INSERT ZNFT1011 FROM TABLE GT_1011N.
    IF SY-SUBRC = 0.
*___변경이력 저장
      PERFORM SAVE_CHANGE_DOC USING 'I'.

      IF PV_FLAG = 'X'.
*___선물요청 메일 전송
        PERFORM SEND_EMAIL USING LV_FLAG.
*___승인요청정보
        PERFORM SAVE_APPROVE_REQUEST USING GV_ERROR.

        IF GV_ERROR IS NOT INITIAL.
          EXIT.
        ENDIF.
      ELSE.
        COMMIT WORK.
      ENDIF.

      GV_SAVE = 'X'.

      IF LV_FLAG = 'X'.
        MESSAGE I003 WITH '결재요청 메일전송을 실패하였습니다.'.
      ENDIF.

      IF LV_REQNO1 = LV_REQNO2.
        IF PV_FLAG IS INITIAL.
          MESSAGE I003 WITH '선물요청번호' LV_REQNO1
                            '이(가) 저장 되었습니다.'.
        ELSE.
          MESSAGE S003 WITH '선물요청번호' LV_REQNO1
                            '이(가) 결재요청 되었습니다.'.

          LEAVE TO SCREEN 0.
        ENDIF.
      ELSE.
        CONCATENATE LV_REQNO1 '부터' LV_REQNO2
               INTO LV_TEXT SEPARATED BY SPACE.

        IF PV_FLAG IS INITIAL.
          MESSAGE I003 WITH '선물요청번호' LV_TEXT
                            '까지 저장 되었습니다.'.
        ELSE.
          MESSAGE S003 WITH '선물요청번호' LV_TEXT
                            '까지 결재요청 되었습니다.'.

          LEAVE TO SCREEN 0.
        ENDIF.
      ENDIF.
    ELSE.
      ROLLBACK WORK.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '선물요청 품목 정보 저장 에러!'.
    ENDIF.
  ELSE.
    ROLLBACK WORK.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선물요청 헤더 정보 저장 에러!'.
  ENDIF.

  SORT GT_1011 BY H_NO1.

ENDFORM.                    " SAVE_FUTURES_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_REQUEST_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_REQUEST_NO .

  CLEAR : GT_1010N-REQNO.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '10'
      OBJECT                  = 'ZNF2_00002'
    IMPORTING
      NUMBER                  = GT_1010N-REQNO
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

ENDFORM.                    " GET_REQUEST_NO
*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_CHANGE_DOC USING PV_UPDKZ.
  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND,
        LV_UPD_ICDTXT      TYPE CHAR1.

  LV_CDOC_UPD_OBJECT = PV_UPDKZ.

  LOOP AT GT_1010N.
    CLEAR   : XGT_1011, YGT_1011, ZNFT1010, YZNFT1010.
    REFRESH : XGT_1011, YGT_1011.

    MOVE-CORRESPONDING GT_1010N TO ZNFT1010.

    IF PV_UPDKZ = 'U'.
      YZNFT1010 = ZNFT1010.

      ZNFT1010-RSTAT = '2'.
    ENDIF.

    LOOP AT GT_1011N WHERE REQNO = GT_1010N-REQNO.
      CLEAR : XGT_1011, YGT_1011.

      MOVE-CORRESPONDING GT_1011N TO XGT_1011.

      XGT_1011-KZ = PV_UPDKZ.

      APPEND XGT_1011.

      IF PV_UPDKZ = 'U'.
        YGT_1011 = XGT_1011.

        APPEND YGT_1011.
      ENDIF.
    ENDLOOP.

    LV_OBJECTID = GT_1010N-REQNO.
    LV_TCODE    = SY-TCODE.

    CALL FUNCTION 'ZNFT1010CHDOC_WRITE_DOCUMENT'
      EXPORTING
        OBJECTID     = LV_OBJECTID
        TCODE        = LV_TCODE
        UTIME        = SY-TIMLO
        UDATE        = SY-DATLO
        USERNAME     = SY-UNAME
*       PLANNED_CHANGE_NUMBER         = ' '
*       OBJECT_CHANGE_INDICATOR       = 'U'
*       PLANNED_OR_REAL_CHANGES       = ' '
*       NO_CHANGE_POINTERS            = ' '
        N_ZNFT1010   = ZNFT1010
        O_ZNFT1010   = YZNFT1010
        UPD_ZNFT1010 = LV_CDOC_UPD_OBJECT
        UPD_ZNFT1011 = LV_CDOC_UPD_OBJECT
      TABLES
        XZNFT1011    = XGT_1011
        YZNFT1011    = YGT_1011.
  ENDLOOP.

ENDFORM.                    " SAVE_CHANGE_DOC
*&---------------------------------------------------------------------*
*&      Form  CHECK_APPLOVAL_USER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_APPLOVAL_USER  USING    PV_PERNR.
  DATA: LV_USRID LIKE ZPA0105-USRID, " PA0105 테이블 대체
*        LV_USRID LIKE PA0105-USRID,
        LV_COMM.

*___사번 존재여부
*  SELECT SINGLE ENAME
*    INTO GV_ENAME
*    FROM PA0001
*   WHERE PERNR = PV_PERNR
*     AND ENDDA >= SY-DATLO
*     AND BEGDA <= SY-DATLO.

*- [MM] PA0001 테이블 대체
  SELECT SINGLE ENAME
    INTO GV_ENAME
    FROM ZZPA0001
   WHERE PERNR = PV_PERNR
     AND ENDDA >= SY-DATLO
     AND BEGDA <= SY-DATLO.
*- [MM] PA0001 테이블 대체

  IF SY-SUBRC <> 0.
    MESSAGE E003 WITH '결재자 사번이 존재하지 않습니다.'.
  ENDIF.

*___결재자 사번의 SAP ID 점검
  PERFORM GET_SAPID_PER_USRID  USING PV_PERNR
                                     LV_USRID
                                     LV_COMM.
  IF LV_USRID IS INITIAL.
    MESSAGE E003 WITH '결재자 사번의 SAP ID를 찾지 못했습니다.'.
  ENDIF.

*___사번의 권한 점검
  CLEAR : ZNFT1090.

  SELECT SINGLE *
    FROM ZNFT1090
   WHERE BUKRS = P_BUKRS
     AND CONGB = '2'
     AND CONSQ = '1'
     AND PERNR = PV_PERNR
     AND LVORM = ' '.

  IF SY-SUBRC <> 0.
    MESSAGE E003 WITH '결재자 사번이 권한 마스터에'
                      '존재하지 않습니다.'.
*  ELSE.
*    IF ZNFT1090-CONGB <> '2' OR ZNFT1090-CONSQ <> '1'.
*      MESSAGE E003 WITH '선물요청 1단계 결재자 사번이 아닙니다.'.
*    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_APPLOVAL_USER
*&---------------------------------------------------------------------*
*&      Form  SAVE_APPROVE_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_APPROVE_REQUEST USING PV_ERROR.
  DATA: LV_FLAG,
        LV_COMM.

  CLEAR   : GT_1091, PV_ERROR.
  REFRESH : GT_1091.

  LOOP AT GT_1010N.
    CLEAR : GT_1091.

    GT_1091-NFNUM = GT_1010N-REQNO.
    GT_1091-CONSQ = '1'.
    GT_1091-CONGB = '2'.
    GT_1091-BUKRS = GT_1010N-BUKRS.
    GT_1091-PERNR = GV_PERNR.
    GT_1091-CONST = 'B'.
    GT_1091-ERDAT = SY-DATLO.
    GT_1091-ERZET = SY-TIMLO.
    GT_1091-ERNAM = SY-UNAME.
    GT_1091-AEDAT = SY-DATLO.
    GT_1091-AEZET = SY-TIMLO.
    GT_1091-AENAM = SY-UNAME.

*___사용자 ID
    PERFORM GET_SAPID_PER_USRID USING GT_1091-PERNR
                                      GT_1091-USRID
                                      LV_COMM.

    IF GT_1091-USRID IS INITIAL.
      MESSAGE E003 WITH '사용자 ID를 찾지 못했습니다.'.
    ENDIF.

    APPEND GT_1091.
  ENDLOOP.

  INSERT ZNFT1091 FROM TABLE GT_1091.
  IF SY-SUBRC = 0.
    COMMIT WORK.

    LOOP AT GT_1091.
*--- 간편결재 전송.
      PERFORM SEND_SIMPLE_APPROVAL
      USING GT_1091-NFNUM
            GT_1091-BUKRS
            '2A'.
    ENDLOOP.
  ELSE.
    ROLLBACK WORK.

    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선물 승인요청 저장 에러!'.
  ENDIF.

ENDFORM.                    " SAVE_APPROVE_REQUEST
*&---------------------------------------------------------------------*
*&      Form  APPROVE_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM APPROVE_REQUEST .
  DATA: LV_REQNO1   LIKE ZNFT1010-REQNO,
        LV_REQNO2   LIKE ZNFT1010-REQNO,
        LV_TEXT(50),
        LV_FLAG,
        LV_FIRST.

  PERFORM POPUP_TO_CONFIRM
    USING '저장'
          '선물요청을 결재요청 하시겠습니까?'
          '1'
          GV_ANSWER.

  IF GV_ANSWER = '1'.
    CLEAR : GV_PERNR,  GV_ENAME, LV_FLAG, LV_FIRST,
            LV_REQNO1, LV_REQNO2.

    CALL SCREEN 0200 STARTING AT 20 5.

    IF OK_SAVE = 'CANC'.
      MESSAGE S003 WITH '작업이 취소되었습니다.'.
      EXIT.
    ENDIF.

    LOOP AT GT_1010N.
      AT FIRST.
        LV_FIRST = 'X'.
      ENDAT.

      IF LV_FIRST = 'X'.
        CLEAR : LV_FIRST.

        LV_REQNO1 = GT_1010N-REQNO.
        LV_REQNO2 = GT_1010N-REQNO.
      ENDIF.

      LV_REQNO2 = GT_1010N-REQNO.

      UPDATE ZNFT1010 SET RSTAT = '2'
                          AEDAT = SY-DATLO
                          AEZET = SY-TIMLO
                          AENAM = SY-UNAME
                    WHERE REQNO = GT_1010N-REQNO.
      IF SY-SUBRC <> 0.
        LV_FLAG = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF LV_FLAG IS INITIAL.
*___선물요청 메일 전송
      PERFORM SEND_EMAIL USING LV_FLAG.
*___변경이력 저장
      PERFORM SAVE_CHANGE_DOC USING 'U'.

*___승인요청정보
      PERFORM SAVE_APPROVE_REQUEST USING GV_ERROR.

      IF GV_ERROR IS INITIAL.
        IF LV_FLAG = 'X'.
          MESSAGE I003 WITH '결재요청 메일전송을 실패하였습니다.'.
        ENDIF.

        IF LV_REQNO1 = LV_REQNO2.
          MESSAGE S003 WITH '선물요청번호' LV_REQNO1
                            '이(가) 결재요청 되었습니다.'.
        ELSE.
          CONCATENATE LV_REQNO1 '부터' LV_REQNO2
               INTO LV_TEXT SEPARATED BY SPACE.

          MESSAGE S003 WITH '선물요청번호' LV_TEXT
                            '까지 결재요청 되었습니다.'.
        ENDIF.

        LEAVE TO SCREEN 0.
      ENDIF.
    ELSE.
      ROLLBACK WORK.

      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '선물요청 상태 Update Error!'.
    ENDIF.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " APPROVE_REQUEST
*&---------------------------------------------------------------------*
*&      Form  SEND_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SEND_EMAIL  USING    PV_FLAG.
  DATA: RESULT_TAB  TYPE MATCH_RESULT_TAB.

  CLEAR : PV_FLAG.

  PERFORM FILL_EMAIL_CONTENTS.

  IF GV_ADDRESS IS INITIAL.
    PV_FLAG = 'X'.
    EXIT.
  ENDIF.

  TRY.
      GC_EMAIL = CL_BCS=>CREATE_PERSISTENT( ).

      GC_EMAIL_BODY = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                                            I_TYPE    = 'HTM'
                                            I_TEXT    = GT_MESSAGE
                                            I_SUBJECT = GV_SUBJECT ).

*     첨부
*      PERFORM add_attachment USING g_email_body.

      GC_EMAIL->SET_DOCUMENT( GC_EMAIL_BODY ).

      GF_RECEIVER =
      CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( GV_ADDRESS ).

      GC_EMAIL->ADD_RECIPIENT( I_RECIPIENT = GF_RECEIVER
                               I_EXPRESS   = 'X' ).

      GC_EMAIL->SET_SEND_IMMEDIATELY( 'X' ).

      GC_EMAIL->SEND( EXPORTING I_WITH_ERROR_SCREEN = 'X'
                      RECEIVING RESULT              = GV_SEND_RESULT ).

    CATCH CX_BCS INTO GC_EXCEPTION.
      PV_FLAG = 'X'.

  ENDTRY.

ENDFORM.                    " SEND_EMAIL
*&---------------------------------------------------------------------*
*&      Form  FILL_EMAIL_CONTENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILL_EMAIL_CONTENTS .
  DATA: LS_MESSAGE  LIKE SOLI.

  DATA: LV_COTXT    LIKE ZNFT1000-COTXT.

*___수신자
  CLEAR : GV_ADDRESS.

  IF SY-SYSID = 'R3T'.
    GV_ADDRESS = 'jhyukim@lscns.com'.
  ELSE.
*    SELECT SINGLE USRID
*      INTO GV_ADDRESS
*      FROM PA0105
*     WHERE PERNR = GV_PERNR
*       AND SUBTY = '0007'
*       AND ENDDA >= SY-DATLO
*       AND BEGDA <= SY-DATLO.

*- [MM] PA0105 테이블 대체
    SELECT SINGLE USRID
      INTO GV_ADDRESS
      FROM ZPA0105
     WHERE PERNR = GV_PERNR
       AND SUBTY = '0007'
       AND ENDDA >= SY-DATLO
       AND BEGDA <= SY-DATLO.
*- [MM] PA0105 테이블 대체
  ENDIF.

  CHECK GV_ADDRESS IS NOT INITIAL.

*___메일 제목
  GV_SUBJECT = '선물요청에 대한 승인요청'.

  CLEAR   : LS_MESSAGE.
  REFRESH : GT_MESSAGE.

*___메일 내용
  PERFORM APPEND_MESSAGE USING : '<html>',
                                 '<body>',
                                 '선물요청<br>',
                                 '<br>'.

  LOOP AT GT_1010N.
    CLEAR : GT_1011N.

    READ TABLE GT_1011N WITH KEY REQNO = GT_1010N-REQNO.

    CLEAR : LV_COTXT.

    SELECT SINGLE COTXT
      INTO LV_COTXT
      FROM ZNFT1000
     WHERE CONNO = GT_1011N-CONNO.

    CONCATENATE GT_1010N-REQNO '(계약명:' LV_COTXT ')<br>'
           INTO LS_MESSAGE.

    PERFORM APPEND_MESSAGE USING : LS_MESSAGE.
  ENDLOOP.

  PERFORM APPEND_MESSAGE USING : '<br>',
                                 '에 대해 승인바랍니다.',
                                 '<br>',
                                 '<br>',
                                 '감사합니다.<br>',
                                 '</body>',
                                 '</html>'.

ENDFORM.                    " FILL_EMAIL_CONTENTS
*&---------------------------------------------------------------------*
*&      Form  APPEND_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM APPEND_MESSAGE  USING    PS_MESSAGE.

  APPEND PS_MESSAGE TO GT_MESSAGE.

ENDFORM.                    " APPEND_MESSAGE
*&---------------------------------------------------------------------*
*& Form SEND_SIMPLE_APPROVAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ZMMT0145M_EXENO
*&      --> ZMMT0145M_BUKRS
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
