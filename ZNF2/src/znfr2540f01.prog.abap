*&---------------------------------------------------------------------*
*&  Include           ZNFR2510F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  CREATE_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_OBJECT .

* Create Object : GRF_CONTAINER
  CREATE OBJECT GRF_CONTAINER
    EXPORTING
      CONTAINER_NAME = GRF_CONTAINER_NAME.

* Create Object : GRF_GRID
  CREATE OBJECT GRF_GRID
    EXPORTING
      I_PARENT      = GRF_CONTAINER
      I_APPL_EVENTS = 'X'.

ENDFORM.                    " CREATE_OBJECT


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
*&      Form  SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_LAYOUT .

  CLEAR GS_LAYOUT.
  GS_LAYOUT-SEL_MODE   = 'A'.
  GS_LAYOUT-ZEBRA      = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT-NO_ROWINS  = 'X'.

ENDFORM.                    " SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_SORT .

  CLEAR GS_SORT. REFRESH GT_SORT.

  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'SHFNO'.
  GS_SORT-UP = 'X'.
  GS_SORT-COMP = 'X'.
  GS_SORT-SUBTOT = 'X'.
  APPEND GS_SORT TO GT_SORT.

  GS_SORT-SPOS = 2.
  GS_SORT-FIELDNAME = 'H_NO1'.
  GS_SORT-UP = 'X'.
  GS_SORT-COMP = 'X'.
  GS_SORT-SUBTOT = 'X'.
  APPEND GS_SORT TO GT_SORT.

ENDFORM.                    " SET_GRID_SORT

*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_FIELDCATALOG .

  CLEAR GT_FIELDCAT.   REFRESH GT_FIELDCAT.

  PERFORM SET_FIELDCAT USING:
  'CHECK'       '선택'             '10'     'C'    ' '     ,
  'SHFNO'       '만기이동요청번호' '10'     'L'    ' '     ,
  'H_NO1'       '항번'             '10'     'C'    ' '     ,
  'SHFCNT'      '만기이동차수'     '5'      'C'    ' '     ,
  'GUBUN'       '요청유형'         '10'     'C'    ' '     ,
  'GUBUN_NM'    '요청유형'         '10'     'C'    ' '     ,
  'REMON'       '요청만기월'       '10'     'C'    ' '     ,
  'RMENG'       '요청수량'         '14'     'R'    ' '     ,
  'MEINS'       '단위'             '10'     'C'    ' '     ,
  'AUDAT'       '승인요청일'       '10'     'C'    ' '     ,
  'RUDAT'       '집행일'           '10'     'C'    ' '     ,
  'ENDAT'       '신규만기일'       '10'     'C'    ' '     ,
  'MISPD'       '신규Spread'       '10'     'R'    ' '     ,
  'PRICE'       '신규단가'         '15'     'R'    ' '     ,
  'CFUTN'       '청산집행번호'           '10'     'C'    ' '     ,
  'CRUDAT'       '청산집행일'           '10'     'C'    ' '     ,
  'CENDAT'       '청산신규만기일'       '10'     'C'    ' '     ,
  'CMISPD'       '청산신규Spread'       '10'     'R'    ' '     ,
  'CPRICE'       '청산신규단가'         '15'     'R'    ' '     ,
  'WAERS'       '통화'             '5'      'C'    ' '     ,
  'OFUTN'       '이동전 집행번호'  '10'     'L'    ' '     ,
  'NFUTN'       '이동후 집행번호'  '10'     'L'    ' '     ,
  'FCM'         'FCM'              '5'      'C'    'ALPHA' ,
  'FCM_NM'      'FCM명'            '10'     'L'    'ALPHA' ,
  'RUDAT1'      '집행일'           '10'     'C'    ' '     ,
  'NFKEY'       '비철구분'         '10'     'C'    ' '     ,
  'BY_SL'       'Buy/Sell'         '10'     'C'    ' '     ,
  'BY_SL_NM'    'Buy/Sell'         '10'     'C'    ' '     ,
  'ENDAT1'      '만기일'           '10'     'C'    ' '     ,
  'MITYP'       '집행유형'         '10'     'C'    ' '     ,
  'MISPD1'      'Spread'           '10'     'R'    ' '     ,
  'MIMON'       '기준월'           '10'     'C'    ' '     ,
  'PRICE1'      '집행단가'         '15'     'R'    ' '     ,
  'WAERS1'      '통화'             '5'      'C'    ' '     ,
  'EMENG1'      '집행수량'         '14'     'R'    ' '     ,
  'MEINS1'      '단위'             '10'     'C'    ' '     ,
  'PRCTR'       '손익센터'         '10'     'C'    'ALPHA' ,
  'PRCTR_NM'    '손익센터명'       '10'     'L'    ' '     ,
  'CONNO'       '계약번호'         '10'     'C'    ' '     .

ENDFORM.                    " SET_GRID_FIELDCATALOG

*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT  USING  P_FIELDNAME
                          P_COLTEXT
                          P_OUTPUTLEN
                          P_JUST
                          P_CONVEXIT.

  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME  = P_FIELDNAME .
  GS_FIELDCAT-COLTEXT    = P_COLTEXT   .
  GS_FIELDCAT-OUTPUTLEN  = P_OUTPUTLEN .
  GS_FIELDCAT-JUST       = P_JUST      .
  GS_FIELDCAT-CONVEXIT   = P_CONVEXIT  .

  CASE P_FIELDNAME.
    WHEN 'CHECK'.
      GS_FIELDCAT-CHECKBOX   = 'X'.
      GS_FIELDCAT-EDIT       = 'X'.
    WHEN 'BY_SL' OR 'GUBUN'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'PRICE'.
      GS_FIELDCAT-CFIELDNAME = 'WEARS'.
    WHEN 'EMENG1'.
      GS_FIELDCAT-QFIELDNAME = 'MEINS1'.
    WHEN 'RMENG'.
      GS_FIELDCAT-QFIELDNAME = 'MEINS'.
  ENDCASE.

  APPEND GS_FIELDCAT TO GT_FIELDCAT.

ENDFORM.                    " SET_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE .

* 각 셀의 특성 제어
  DATA : LT_CELLTAB TYPE LVC_T_STYL,
         L_INDEX    TYPE I.

  LOOP AT GT_OUTTAB_C INTO GS_OUTTAB_C.
    L_INDEX = SY-TABIX.
    REFRESH LT_CELLTAB.
    CLEAR GS_OUTTAB_C-CELLTAB.
    PERFORM FILL_CELLTAB_C CHANGING LT_CELLTAB.
    INSERT LINES OF LT_CELLTAB INTO TABLE GS_OUTTAB_C-CELLTAB.
    MODIFY GT_OUTTAB_C FROM GS_OUTTAB_C INDEX L_INDEX.
  ENDLOOP.

ENDFORM.                    " SET_CELL_ATTRIBUTE

*&---------------------------------------------------------------------*
*&      Form  SET_EVENT_HANDLER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_EVENT_HANDLER .

  CALL METHOD GRF_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CREATE OBJECT GRF_EVENT_RECEIVER.
  SET HANDLER :
    GRF_EVENT_RECEIVER->HANDLE_DATA_CHANGED FOR GRF_GRID,
    GRF_EVENT_RECEIVER->HANDLE_DOUBLE_CLICK FOR GRF_GRID.

ENDFORM.                    " SET_EVENT_HANDLER


*&---------------------------------------------------------------------*
*&      Form  SET_F4_HELP_REGISTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_F4_HELP_REGISTER .

  CLEAR   : GS_F4.
  REFRESH : GT_F4.

* FieldName별 소트해서 APPEND
*  GS_F4-FIELDNAME = 'NFUTN'.
*  GS_F4-REGISTER  = 'X'.
*  APPEND GS_F4 TO GT_F4.
*
*  CALL METHOD GRF_GRID->REGISTER_F4_FOR_FIELDS
*    EXPORTING
*      IT_F4 = GT_F4.

ENDFORM.                    " SET_F4_HELP_REGISTER

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


  CALL METHOD GRF_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT                    = GS_VARIANT
      IS_LAYOUT                     = GS_LAYOUT
      I_SAVE                        = 'A'
      I_DEFAULT                     = 'X'
      IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE
    CHANGING
      IT_FIELDCATALOG               = GT_FIELDCAT[]
      IT_SORT                       = GT_SORT[]
      IT_OUTTAB                     = GT_OUTTAB_C
      IT_FILTER                     = GT_FILTER
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.

  CALL METHOD GRF_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  GET_REQ_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_REQ_LIST .

*   =========================================
*   REQ_TYPE 코드값(Hotsopt용 구분값)
*   =========================================
*   'A' = 선물요청승인
*   'B' = 만기이동요청승인
*   'C' = 만기이동집행승인
*   'D' = 신규선물집행승인
*   'E' = 청산선물집행승인
*   'F' = 신규/청산선물집행수정승인
*   =========================================

  DATA : LV_CNT TYPE I.

  CLEAR : GV_PERNR, GV_UNAME, GV_ERROR.
  CLEAR : GT_PERNR. REFRESH GT_PERNR[].

  IF P_UNAME IS NOT INITIAL.
    GV_UNAME = P_UNAME.
  ELSE.
    GV_UNAME = SY-UNAME.
  ENDIF.

  PERFORM GET_USRID_PER_SAPID TABLES GT_PERNR
                               USING GV_UNAME
                                     GV_PERNR.
*   개인아이디 : GV_PERNR // 공용아이디 : GT_PERNR
*   GV_PERNR 과 GT_PERNR은 둘다 가질수 없음
  IF GV_PERNR IS NOT INITIAL.
    GT_PERNR-PERNR = GV_PERNR.
    APPEND GT_PERNR.
  ENDIF.

  IF GT_PERNR[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH GV_UNAME '에 대한 사번정보가 존재하지 않습니다.'.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.

* ZNFT1090에 대한 권한유무 체크
  IF GT_PERNR[] IS NOT INITIAL.
    CLEAR: LV_CNT.
    SELECT COUNT(*) INTO LV_CNT
      FROM ZNFT1090
           FOR ALL ENTRIES IN GT_PERNR
     WHERE PERNR EQ GT_PERNR-PERNR
       AND BUKRS EQ P_BUKRS
       AND CONGB EQ '5'
       AND CONSQ EQ 3.

    IF SY-SUBRC EQ 0 AND LV_CNT GE 1.
    ELSE.
      GV_ERROR = 'X'.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH GV_UNAME '에 대한 승인권한이 없습니다.'.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH GV_UNAME '에 대한 사번정보가 존재하지 않습니다.'.
    EXIT.
  ENDIF.


* --------------------------------------------------------------------
* 'C' = 만기이동집행승인
* --------------------------------------------------------------------
  CLEAR : GS_NFNUM. REFRESH : GT_NFNUM_C.

  IF GT_PERNR[] IS NOT INITIAL.
    SELECT Z1~NFNUM INTO CORRESPONDING FIELDS OF TABLE GT_NFNUM_C
      FROM ZNFT1091 AS Z1
           INNER JOIN ZNFT1090 AS Z2
              ON Z2~BUKRS EQ Z1~BUKRS AND Z2~CONGB EQ Z1~CONGB
             AND Z2~CONSQ EQ Z1~CONSQ
           FOR ALL ENTRIES IN GT_PERNR
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~CONGB EQ '5'
       AND Z1~CONST EQ 'B'
       AND Z1~CONSQ EQ 3
       AND Z2~PERNR EQ GT_PERNR-PERNR
       AND Z2~LVORM NE 'X'.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH GV_UNAME '에 대한 사번정보가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

  IF SY-SUBRC EQ 0 AND GT_NFNUM_C IS NOT INITIAL.
    SORT GT_NFNUM_C BY NFNUM.
    CLEAR GV_H_CNT.
    SELECT COUNT(*) INTO GV_H_CNT
      FROM ZNFT1040
           FOR ALL ENTRIES IN GT_NFNUM_C
     WHERE SHFNO EQ GT_NFNUM_C-NFNUM
       AND BUKRS EQ P_BUKRS
       AND DRSTA EQ '5'.
  ELSE.
    IF OK_SAVE EQ 'ALLOW' OR OK_SAVE EQ 'REJECT' OR
       OK_SAVE EQ 'CONF'  OR OK_SAVE EQ 'CANC'.
      GV_ERROR = 'X'.
    ELSE.
      GV_ERROR = 'X'.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH GV_UNAME
              '에 대한 집행승인데이터가 존재하지 않습니다.'.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_REQ_LIST

*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM ALV_EVENT_DATA_CHANGED USING
            P_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI,
        LV_INDEX     TYPE I,
        LV_TABIX     TYPE I.

  DATA: LT_LVC_STYL TYPE LVC_T_STYL,
        LS_LVC_STYL TYPE LVC_S_STYL.

  DATA: LV_CSTAT LIKE ZNFT1000-CSTAT,
        LV_CDATE LIKE ZNFT1000-CDATE.

  FIELD-SYMBOLS : <FS_ITAB> TYPE ANY TABLE.

  CLEAR:LV_CSTAT, LV_CDATE.
  CLEAR LT_LVC_STYL. REFRESH LT_LVC_STYL.
  CLEAR LV_INDEX.

  CLEAR GS_OUTTAB_C.
  LOOP AT P_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    LV_INDEX = LS_MOD_CELLS-ROW_ID.
*       Data 가공용 Structure
    READ TABLE GT_OUTTAB_C INTO GS_OUTTAB_C INDEX LV_INDEX.
    IF SY-SUBRC EQ 0.
      CASE LS_MOD_CELLS-FIELDNAME.
        WHEN 'CHECK'.
          IF LS_MOD_CELLS-VALUE EQ 'X'.
            GS_OUTTAB_C-CHECK = 'X'.
            MODIFY GT_OUTTAB_C FROM GS_OUTTAB_C INDEX LV_INDEX
                               TRANSPORTING CHECK.
          ELSE.
            GS_OUTTAB_C-CHECK = SPACE.
            MODIFY GT_OUTTAB_C FROM GS_OUTTAB_C INDEX LV_INDEX
                               TRANSPORTING CHECK.
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " ALV_EVENT_DATA_CHANGED

*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW  text
*      -->P_E_COLUMN  text
*      -->P_ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM ALV_EVENT_DOUBLE_CLICK USING P_E_ROW     TYPE LVC_S_ROW
                                  P_E_COLUMN  TYPE LVC_S_COL
                                  P_ES_ROW_NO TYPE LVC_S_ROID.

  READ TABLE GT_OUTTAB_C INTO GS_OUTTAB_C INDEX P_ES_ROW_NO-ROW_ID.

  IF SY-SUBRC EQ 0.

    CASE P_E_COLUMN.
      WHEN 'CONNO'.
        IF NOT GS_OUTTAB_C-CONNO IS INITIAL.
          SET PARAMETER ID 'ZNFCON' FIELD GS_OUTTAB_C-CONNO.
          CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE '계약번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN 'OFUTN'.
        PERFORM CALL_NFUTN_PGM USING GS_OUTTAB_C-OFUTN.
      WHEN 'NFUTN'.
        PERFORM CALL_NFUTN_PGM USING GS_OUTTAB_C-NFUTN.
    ENDCASE.

  ENDIF.

ENDFORM.                    " ALV_EVENT_DOUBLE_CLICK

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
*&      Form  DATA_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LIST_REQ_TYPE  text
*----------------------------------------------------------------------*
FORM DATA_SELECT.

  PERFORM GET_REQNO_C.

ENDFORM.                    " DATA_SELECT

*&---------------------------------------------------------------------*
*&      Form  GET_REQNO_C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_REQNO_C .

  DATA: LV_FLAG TYPE CHAR01.
  DATA: LV_TABIX TYPE SY-TABIX.

  SELECT Z2~BUKRS
         Z1~SHFNO  " 만기이동 요청번호
         Z1~H_NO1
         Z1~REMON  "
         Z1~RMENG  " 요청수량
         Z1~MEINS  " 단위
         Z1~RUDAT
         Z1~ENDAT
         Z1~PRICE
         Z1~WAERS
         Z1~MISPD
         Z2~OFUTN  " 이동전 집행번호
         Z1~NFUTN  " 이동후 집행번호
         Z1~GUBUN
         Z3~FCM
         Z3~RUDAT AS RUDAT1
         Z3~NFKEY
         Z3~BY_SL
         Z3~ENDAT AS ENDAT1
         Z3~MITYP
         Z3~MISPD AS MISPD1
         Z3~MIMON
         Z3~PRICE AS PRICE1
         Z3~WAERS AS WAERS1
         Z3~EMENG AS EMENG1
         Z3~MEINS AS MEINS1
         Z5~PRCTR
*        ZNFT0004-PTEXT
         Z5~CONNO
         INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB_C
    FROM ZNFT1041 AS Z1
         INNER JOIN ZNFT1040 AS Z2
           ON Z2~SHFNO EQ Z1~SHFNO
         INNER JOIN ZNFT1020 AS Z3
           ON Z3~NFUTN EQ Z2~OFUTN
         INNER JOIN ZNFT1011 AS Z4
           ON Z4~REQNO EQ Z3~REQNO AND Z4~H_NO1 EQ Z3~H_NO1
         INNER JOIN ZNFT1000 AS Z5
           ON Z5~CONNO EQ Z4~CONNO
         FOR ALL ENTRIES IN GT_NFNUM_C
   WHERE Z1~GUBUN EQ '1'               " 신규생성건(만기이동요청건)
     AND Z2~SHFNO EQ GT_NFNUM_C-NFNUM.


  IF SY-SUBRC EQ 0 AND GT_OUTTAB_C IS NOT INITIAL.
    SORT GT_OUTTAB_C BY BUKRS SHFNO H_NO1.
    CLEAR: LV_TABIX, GS_OUTTAB_C.
    LOOP AT GT_OUTTAB_C INTO GS_OUTTAB_C.
      LV_TABIX = SY-TABIX.

      AT NEW SHFNO.
        LV_FLAG = 'X'.
      ENDAT.

      IF LV_FLAG = 'X'.
        CLEAR : LV_FLAG.
      ELSE.
        GS_OUTTAB_C-CHECK = '-'.
      ENDIF.

*     FCM
      PERFORM GET_LIFNR_DESC USING GS_OUTTAB_C-FCM
                                   GS_OUTTAB_C-FCM_NM.

*     생성구분
      PERFORM DOMAIN_VALUE_GET USING 'ZGUBUN_4'
                                     GS_OUTTAB_C-GUBUN
                                     GS_OUTTAB_C-GUBUN_NM.

*     BUY & SELL
      PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                     GS_OUTTAB_C-BY_SL
                                     GS_OUTTAB_C-BY_SL_NM.

      SELECT SINGLE AEDAT INTO GS_OUTTAB_C-AUDAT
        FROM ZNFT1091
       WHERE NFNUM EQ GS_OUTTAB_C-SHFNO
         AND CONGB EQ '5'
         AND CONST EQ 'B'
         AND CONSQ EQ '3'.

      PERFORM GET_PRCTR_DESC USING GS_OUTTAB_C-BUKRS
                                   GS_OUTTAB_C-PRCTR
                                   GS_OUTTAB_C-PRCTR_NM.

*___만기이동차수
      PERFORM GET_SHIFT_COUNT(ZNFR2310) USING GS_OUTTAB_C-OFUTN
                                              GS_OUTTAB_C-SHFCNT.

      IF GS_OUTTAB_C-NFUTN IS NOT INITIAL.
        SELECT SINGLE CFUTN PRICE RUDAT ENDAT MISPD
                         INTO (GS_OUTTAB_C-CFUTN, GS_OUTTAB_C-CPRICE,
                                 GS_OUTTAB_C-CRUDAT, GS_OUTTAB_C-CENDAT,
                                   GS_OUTTAB_C-CMISPD)
          FROM ZNFT1030
         WHERE NFUTN EQ GS_OUTTAB_C-NFUTN.

      ENDIF.

      MODIFY GT_OUTTAB_C FROM GS_OUTTAB_C INDEX LV_TABIX.
      CLEAR: LV_TABIX, GS_OUTTAB_C.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " GET_REQNO_C

*&---------------------------------------------------------------------*
*&      Form  DATA_ALLOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_ALLOW .

* 데이터 체크
  CLEAR GV_ERROR.
  PERFORM DATA_CHECK_A USING GV_ERROR.
  CHECK GV_ERROR NE 'X'.

* 진행상황 체크
  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM
    USING '확인'
          '승인처리 하시겠습니까?'
          '1'
          GV_ANSWER.
  CHECK GV_ANSWER EQ '1'.

* 공용아이디 체크로직
  SELECT SINGLE * FROM PA0105
   WHERE USRTY EQ '9001'
     AND USRID EQ GV_UNAME
     AND ENDDA GE SY-DATLO
     AND BEGDA LE SY-DATLO.

  IF SY-SUBRC EQ 0.
    CALL SCREEN 1210 STARTING AT 10 03
                     ENDING   AT 55 06.
    CHECK GV_ERROR NE 'X'.
  ENDIF.


  PERFORM DATA_ALLOW_C.

ENDFORM.                    " DATA_ALLOW

*&---------------------------------------------------------------------*
*&      Form  DATA_CHECK_A
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_CHECK_A USING PV_ERROR.

  DATA: LS_OUTTAB_C LIKE GS_OUTTAB_C,
        LT_OUTTAB_C LIKE TABLE OF LS_OUTTAB_C.

  LOOP AT GT_OUTTAB_C INTO GS_OUTTAB_C WHERE CHECK EQ 'X'.
    MOVE-CORRESPONDING GS_OUTTAB_C TO LS_OUTTAB_C.
    APPEND LS_OUTTAB_C TO LT_OUTTAB_C.
  ENDLOOP.

  IF LT_OUTTAB_C IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '승인하실 데이터를 선택하십시오.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

  DATA: LV_CNT TYPE I.

  LOOP AT LT_OUTTAB_C INTO LS_OUTTAB_C.
*   ==========================================================
*     승인권한 점검
*   ==========================================================
    CLEAR LV_CNT.

    IF GT_PERNR[] IS NOT INITIAL.
      SELECT COUNT(*) INTO LV_CNT
        FROM ZNFT1091 AS Z1
             INNER JOIN ZNFT1090 AS Z2
                ON Z2~BUKRS EQ Z1~BUKRS AND Z2~CONSQ EQ Z1~CONSQ
               AND Z2~CONGB EQ Z1~CONGB
             FOR ALL ENTRIES IN GT_PERNR
       WHERE Z1~BUKRS EQ P_BUKRS
         AND Z1~CONST EQ 'B'
         AND Z1~NFNUM EQ LS_OUTTAB_C-SHFNO
         AND Z2~CONGB EQ '5'
         AND Z2~CONSQ EQ 3
         AND Z2~PERNR EQ GT_PERNR-PERNR
         AND Z2~LVORM NE 'X'.
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH GV_UNAME '에 대한 사번정보가 존재하지 않습니다.'.
      EXIT.
    ENDIF.

    IF SY-SUBRC EQ 0.
      IF LV_CNT LT 1.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '승인권한이 없습니다.'.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '승인권한이 없습니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " DATA_CHECK_A

*&---------------------------------------------------------------------*
*&      Form  DATA_ALLOW_C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_ALLOW_C .

  DATA: BEGIN OF LS_NFUTN,
          NFUTN LIKE ZNFT1020-NFUTN,
        END OF LS_NFUTN.
  DATA: LT_NFUTN LIKE TABLE OF LS_NFUTN.

  "--> 청산선물 상태변경 추가
  DATA: BEGIN OF LS_CFUTN,
          CFUTN LIKE ZNFT1030-CFUTN,
        END OF LS_CFUTN.
  DATA: LT_CFUTN LIKE TABLE OF LS_CFUTN.

  DATA: LS_ZNFT1040 TYPE ZNFT1040,
        LT_ZNFT1040 LIKE TABLE OF LS_ZNFT1040.

  DATA: LS_ZNFT1020 TYPE ZNFT1020,
        LT_ZNFT1020 LIKE TABLE OF LS_ZNFT1020.

  DATA: LS_ZNFT1030 TYPE ZNFT1030,
        LT_ZNFT1030 LIKE TABLE OF LS_ZNFT1030.

  DATA: LS_ZNFT1091  TYPE ZNFT1091,
        LT_ZNFT1091  LIKE TABLE OF LS_ZNFT1091,
        LS_ZNFT1091N TYPE ZNFT1091,
        LT_ZNFT1091N LIKE TABLE OF LS_ZNFT1091,
        LS_ZNFT1091Y TYPE ZNFT1091.

  CLEAR GS_OUTTAB_C.
  CLEAR LS_ZNFT1020.  REFRESH LT_ZNFT1020.
  CLEAR GS_ZNFT1020.  REFRESH GT_ZNFT1020.
  CLEAR LS_ZNFT1030.  REFRESH LT_ZNFT1030.
  CLEAR GS_ZNFT1030.  REFRESH GT_ZNFT1030.
  CLEAR LS_ZNFT1040.  REFRESH LT_ZNFT1040.
  CLEAR GS_ZNFT1040.  REFRESH GT_ZNFT1040.
  CLEAR LS_ZNFT1091.  REFRESH LT_ZNFT1091.
  CLEAR LS_ZNFT1091N. REFRESH LT_ZNFT1091N.

  CLEAR GS_NFUTN.     REFRESH GT_NFUTN.

* 개인아이디인 경우 인터널테이블에서 읽어오기
  IF GV_PERNR IS INITIAL AND LINES( GT_PERNR ) EQ 1.
    READ TABLE GT_PERNR INDEX 1.
    IF SY-SUBRC EQ 0.
      GV_PERNR = GT_PERNR-PERNR.
    ENDIF.
  ENDIF.

  LOOP AT GT_OUTTAB_C INTO GS_OUTTAB_C WHERE CHECK EQ 'X'.

*   ZNFT1040 데이터 변경 INTERNAL TABLE
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1040
      FROM ZNFT1040
     WHERE BUKRS EQ GS_OUTTAB_C-BUKRS
       AND SHFNO EQ GS_OUTTAB_C-SHFNO.

    IF SY-SUBRC EQ 0.

*     ### 문서변경이력관리용 ###
      APPEND LS_ZNFT1040 TO GT_ZNFT1040.

      LS_ZNFT1040-DRSTA = '6'.
      LS_ZNFT1040-AENAM = GV_UNAME.
      LS_ZNFT1040-AEDAT = SY-DATLO.
      LS_ZNFT1040-AEZET = SY-TIMLO.
      APPEND LS_ZNFT1040 TO LT_ZNFT1040.
      CLEAR  LS_ZNFT1040.
    ENDIF.

*   ZNFT1091 데이터 변경 : 해당 결재순번의 요청승인상태 = 'A'로 변경
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1091
      FROM ZNFT1091
     WHERE BUKRS EQ GS_OUTTAB_C-BUKRS
       AND NFNUM EQ GS_OUTTAB_C-SHFNO
       AND CONGB EQ '5'
       AND CONSQ EQ 3.

    IF SY-SUBRC EQ 0.
      LS_ZNFT1091-CONST = 'A'.
      LS_ZNFT1091-PERNR = GV_PERNR.
      LS_ZNFT1091-USRID = GV_UNAME.
      LS_ZNFT1091-AENAM = GV_UNAME.
      LS_ZNFT1091-AEDAT = SY-DATLO.
      LS_ZNFT1091-AEZET = SY-TIMLO.
      APPEND LS_ZNFT1091 TO LT_ZNFT1091.

*     ZNFT1020의 CONFM의 상태값 변경
      CLEAR LS_NFUTN.     REFRESH LT_NFUTN.
      SELECT NFUTN INTO CORRESPONDING FIELDS OF TABLE LT_NFUTN
        FROM ZNFT1041
       WHERE SHFNO EQ GS_OUTTAB_C-SHFNO.

      IF SY-SUBRC EQ 0.
*       각각의 만기이동요청번호에 해당하는 집행번호를 집계한후
*       일괄적으로 CONFM의 값을 변경한다.
        APPEND LINES OF LT_NFUTN TO GT_NFUTN.
      ENDIF.

*--> 청산선물 상태변경 추가
      IF GT_NFUTN[] IS NOT INITIAL.
        CLEAR LS_CFUTN.
        REFRESH LT_CFUTN.
        SELECT CFUTN INTO CORRESPONDING FIELDS OF TABLE LT_CFUTN
          FROM ZNFT1030
           FOR ALL ENTRIES IN GT_NFUTN
         WHERE NFUTN EQ GT_NFUTN-NFUTN.

        IF SY-SUBRC EQ 0.
          APPEND LINES OF LT_CFUTN TO GT_CFUTN.
          DELETE ADJACENT DUPLICATES FROM GT_CFUTN COMPARING CFUTN.
        ENDIF.
      ENDIF.
*<-- 청산선물 상태변경 추가
    ENDIF.
    CLEAR : LS_ZNFT1091, LS_ZNFT1091Y.
  ENDLOOP.

  IF GT_NFUTN IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_ZNFT1020
      FROM ZNFT1020
           FOR ALL ENTRIES IN GT_NFUTN
     WHERE NFUTN EQ GT_NFUTN-NFUTN.

    IF SY-SUBRC EQ 0.
      GT_ZNFT1020 = LT_ZNFT1020.
    ENDIF.
  ENDIF.

*--> 청산선물 상태변경 추가
  IF GT_CFUTN IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_ZNFT1030
      FROM ZNFT1030
           FOR ALL ENTRIES IN GT_CFUTN
     WHERE CFUTN EQ GT_CFUTN-CFUTN.

    IF SY-SUBRC EQ 0.
      GT_ZNFT1030 = LT_ZNFT1030.
    ENDIF.
  ENDIF.
*<-- 청산선물 상태변경 추가

  DATA: LV_DBCNT TYPE I.
  CLEAR LV_DBCNT.

  LV_DBCNT = LINES( LT_ZNFT1040 ).

* ZNFT1040
  MODIFY ZNFT1040 FROM TABLE LT_ZNFT1040.
  IF SY-SUBRC EQ 0.
*   ZNFT1091 - 신규
    MODIFY ZNFT1091 FROM TABLE LT_ZNFT1091.
    IF SY-SUBRC EQ 0.
      LS_ZNFT1020-CONFM = '3'.
      LS_ZNFT1020-CONAM = GV_UNAME. " 결재자 정보
      LS_ZNFT1020-CODAT = SY-DATLO. " 결재자 정보
      LS_ZNFT1020-COZET = SY-TIMLO. " 결재자 정보
      LS_ZNFT1020-AENAM = GV_UNAME.
      LS_ZNFT1020-AEDAT = SY-DATLO.
      LS_ZNFT1020-AEZET = SY-TIMLO.

*     인터널테이블 전체 적용(INDEX단위가 아님)
      MODIFY LT_ZNFT1020 FROM LS_ZNFT1020
             TRANSPORTING CONFM CONAM CODAT COZET AENAM AEDAT AEZET
             WHERE NFUTN NE SPACE.

*--> 청산선물 상태변경 추가
      IF LT_ZNFT1030[] IS NOT INITIAL.
        LS_ZNFT1030-CONFM = '3'.
        LS_ZNFT1030-CONAM = GV_UNAME. " 결재자 정보
        LS_ZNFT1030-CODAT = SY-DATLO. " 결재자 정보
        LS_ZNFT1030-COZET = SY-TIMLO. " 결재자 정보
        LS_ZNFT1030-AENAM = GV_UNAME.
        LS_ZNFT1030-AEDAT = SY-DATLO.
        LS_ZNFT1030-AEZET = SY-TIMLO.

        MODIFY LT_ZNFT1030 FROM LS_ZNFT1030
               TRANSPORTING CONFM CONAM CODAT COZET AENAM AEDAT AEZET
               WHERE CFUTN NE SPACE.
      ENDIF.
*<-- 청산선물 상태변경 추가

      IF SY-SUBRC EQ 0.
        MODIFY ZNFT1020 FROM TABLE LT_ZNFT1020.
        COMMIT WORK AND WAIT.
        IF LT_ZNFT1030[] IS NOT INITIAL. "--> 청산선물 상태변경 추가
          MODIFY ZNFT1030 FROM TABLE LT_ZNFT1030.
          COMMIT WORK AND WAIT.
        ENDIF.
        IF SY-SUBRC EQ 0.
          PERFORM SAVE_CHANGE_DOC_ZNFT1020.
          PERFORM SAVE_CHANGE_DOC_ZNFT1040.
          IF LT_ZNFT1030[] IS NOT INITIAL. "--> 청산선물 상태변경 추가
            PERFORM SAVE_CHANGE_DOC_ZNFT1030.
          ENDIF.
          MESSAGE S003 DISPLAY LIKE 'S'
             WITH LV_DBCNT '건이 승인 완료되었습니다.'.

          COMMIT WORK.
*--- 간편결재 전송.
          LOOP AT LT_ZNFT1040 INTO LS_ZNFT1040.
            PERFORM SEND_SIMPLE_APPROVAL
            USING LS_ZNFT1040-SHFNO
                      P_BUKRS
                      '2C'.
          ENDLOOP.
        ENDIF.
      ELSE.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '저장시 오류입니다.'.
        ROLLBACK WORK.
        EXIT.
      ENDIF.
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '저장시 오류입니다.'.
      ROLLBACK WORK.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '저장시 오류입니다.'.
    ROLLBACK WORK.
    EXIT.
  ENDIF.

ENDFORM.                    " DATA_ALLOW_C

*&---------------------------------------------------------------------*
*&      Form  DATA_REJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_REJECT .

* 반려관련 데이터 체크
  CLEAR GV_ERROR.
  PERFORM DATA_CHECK_R USING GV_ERROR.
  CHECK GV_ERROR NE 'X'.

*   진행상황 체크
  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM
    USING '반려'
          '해당 데이터를 반려하시겠습니까?'
          '1'
          GV_ANSWER.
  CHECK GV_ANSWER EQ '1'.

* 공용아이디 체크로직
  SELECT SINGLE * FROM PA0105
   WHERE USRTY EQ '9001'
     AND USRID EQ GV_UNAME
     AND ENDDA GE SY-DATLO
     AND BEGDA LE SY-DATLO.

  IF SY-SUBRC EQ 0.
    CALL SCREEN 1210 STARTING AT 10 03
                     ENDING   AT 55 06.
    CHECK GV_ERROR NE 'X'.
  ENDIF.


  PERFORM DATA_REJECT_C.

ENDFORM.                    " DATA_REJECT

*&---------------------------------------------------------------------*
*&      Form  DATA_CHECK_R
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM DATA_CHECK_R  USING  PV_ERROR.

  DATA: LS_OUTTAB_C LIKE GS_OUTTAB_C,
        LT_OUTTAB_C LIKE TABLE OF LS_OUTTAB_C.

  LOOP AT GT_OUTTAB_C INTO GS_OUTTAB_C WHERE CHECK EQ 'X'.
    MOVE-CORRESPONDING GS_OUTTAB_C TO LS_OUTTAB_C.
    APPEND LS_OUTTAB_C TO LT_OUTTAB_C.
  ENDLOOP.

  IF LT_OUTTAB_C IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '승인하실 데이터를 선택하십시오.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

  DATA: LV_CNT TYPE I.

  LOOP AT LT_OUTTAB_C INTO LS_OUTTAB_C.
*   ==========================================================
*     승인권한 점검
*   ==========================================================
    CLEAR LV_CNT.
    IF GT_PERNR[] IS NOT INITIAL.
      SELECT COUNT(*) INTO LV_CNT
        FROM ZNFT1091 AS Z1
             INNER JOIN ZNFT1090 AS Z2
                ON Z2~BUKRS EQ Z1~BUKRS AND Z2~CONSQ EQ Z1~CONSQ
               AND Z2~CONGB EQ Z1~CONGB
             FOR ALL ENTRIES IN GT_PERNR
       WHERE Z1~BUKRS EQ P_BUKRS
         AND Z1~CONST EQ 'B'
         AND Z1~NFNUM EQ LS_OUTTAB_C-SHFNO
         AND Z2~CONGB EQ '5'
         AND Z2~CONSQ EQ 3
         AND Z2~PERNR EQ GT_PERNR-PERNR
         AND Z2~LVORM NE 'X'.
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH GV_UNAME '에 대한 사번정보가 존재하지 않습니다.'.
      EXIT.
    ENDIF.

    IF SY-SUBRC EQ 0.
      IF LV_CNT LT 1.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '승인권한이 없습니다.'.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '승인권한이 없습니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " DATA_CHECK_R

*&---------------------------------------------------------------------*
*&      Form  DATA_REJECT_C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_REJECT_C .

  DATA: BEGIN OF LS_NFUTN,
          NFUTN LIKE ZNFT1020-NFUTN,
        END OF LS_NFUTN.
  DATA: LT_NFUTN LIKE TABLE OF LS_NFUTN.

  DATA: LS_ZNFT1040 TYPE ZNFT1040,
        LT_ZNFT1040 LIKE TABLE OF LS_ZNFT1040.

  DATA: LS_ZNFT1020 TYPE ZNFT1020,
        LT_ZNFT1020 LIKE TABLE OF LS_ZNFT1020.

  DATA: LS_ZNFT1091  TYPE ZNFT1091,
        LT_ZNFT1091  LIKE TABLE OF LS_ZNFT1091,
        LS_ZNFT1091N TYPE ZNFT1091,
        LT_ZNFT1091N LIKE TABLE OF LS_ZNFT1091,
        LS_ZNFT1091Y TYPE ZNFT1091.

  CLEAR GS_OUTTAB_C.
  CLEAR LS_ZNFT1020.  REFRESH LT_ZNFT1020.
  CLEAR GS_ZNFT1020.  REFRESH GT_ZNFT1020.
  CLEAR LS_ZNFT1040.  REFRESH LT_ZNFT1040.
  CLEAR GS_ZNFT1040.  REFRESH GT_ZNFT1040.
  CLEAR GS_NFUTN.     REFRESH GT_NFUTN.

* 개인아이디인 경우 인터널테이블에서 읽어오기
  IF GV_PERNR IS INITIAL AND LINES( GT_PERNR ) EQ 1.
    READ TABLE GT_PERNR INDEX 1.
    IF SY-SUBRC EQ 0.
      GV_PERNR = GT_PERNR-PERNR.
    ENDIF.
  ENDIF.

  LOOP AT GT_OUTTAB_C INTO GS_OUTTAB_C WHERE CHECK EQ 'X'.

*   ZNFT1040 데이터 변경 INTERNAL TABLE
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1040
      FROM ZNFT1040
     WHERE BUKRS EQ GS_OUTTAB_C-BUKRS
       AND SHFNO EQ GS_OUTTAB_C-SHFNO.

    IF SY-SUBRC EQ 0.

*     ### 문서변경이력관리용 ###
      APPEND LS_ZNFT1040 TO GT_ZNFT1040.

      LS_ZNFT1040-DRSTA = '8'.
      LS_ZNFT1040-AENAM = GV_UNAME.
      LS_ZNFT1040-AEDAT = SY-DATLO.
      LS_ZNFT1040-AEZET = SY-TIMLO.
      APPEND LS_ZNFT1040 TO LT_ZNFT1040.
      CLEAR  LS_ZNFT1040.
    ENDIF.

*   ZNFT1091 데이터 변경 : 해당 결재순번의 요청승인상태 = 'A'로 변경
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1091
      FROM ZNFT1091
     WHERE BUKRS EQ GS_OUTTAB_C-BUKRS
       AND NFNUM EQ GS_OUTTAB_C-SHFNO
       AND CONGB EQ '5'
       AND CONSQ EQ 3.

    IF SY-SUBRC EQ 0.
      LS_ZNFT1091-CONST = 'R'.
      LS_ZNFT1091-PERNR = GV_PERNR.
      LS_ZNFT1091-USRID = GV_UNAME.
      LS_ZNFT1091-AENAM = GV_UNAME.
      LS_ZNFT1091-AEDAT = SY-DATLO.
      LS_ZNFT1091-AEZET = SY-TIMLO.
      APPEND LS_ZNFT1091 TO LT_ZNFT1091.

*     ZNFT1020의 CONFM의 상태값 변경
      CLEAR LS_NFUTN.     REFRESH LT_NFUTN.
      SELECT NFUTN INTO CORRESPONDING FIELDS OF TABLE LT_NFUTN
        FROM ZNFT1041
       WHERE SHFNO EQ GS_OUTTAB_C-SHFNO.

      IF SY-SUBRC EQ 0.
*       각각의 만기이동요청번호에 해당하는 집행번호를 집계한후
*       일괄적으로 CONFM의 값을 변경한다.
        APPEND LINES OF LT_NFUTN TO GT_NFUTN.
      ENDIF.
    ENDIF.
    CLEAR : LS_ZNFT1091, LS_ZNFT1091Y.
  ENDLOOP.


  IF GT_NFUTN IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_ZNFT1020
      FROM ZNFT1020
           FOR ALL ENTRIES IN GT_NFUTN
     WHERE NFUTN EQ GT_NFUTN-NFUTN.

    IF SY-SUBRC EQ 0.
      GT_ZNFT1020 = LT_ZNFT1020.
    ENDIF.
  ENDIF.

  DATA: LV_DBCNT TYPE I.
  CLEAR LV_DBCNT.

  LV_DBCNT = LINES( LT_ZNFT1040 ).

*   ZNFT1040
  MODIFY ZNFT1040 FROM TABLE LT_ZNFT1040.
  IF SY-SUBRC EQ 0.
*     ZNFT1091 - 신규
    MODIFY ZNFT1091 FROM TABLE LT_ZNFT1091.
    IF SY-SUBRC EQ 0.

      LS_ZNFT1020-CONFM = '4'.
      LS_ZNFT1020-CONAM = GV_UNAME. " 결재자 정보
      LS_ZNFT1020-CODAT = SY-DATLO. " 결재자 정보
      LS_ZNFT1020-COZET = SY-TIMLO. " 결재자 정보
      LS_ZNFT1020-AENAM = GV_UNAME.
      LS_ZNFT1020-AEDAT = SY-DATLO.
      LS_ZNFT1020-AEZET = SY-TIMLO.

*     인터널테이블 전체 적용(INDEX단위가 아님)
      MODIFY LT_ZNFT1020 FROM LS_ZNFT1020
             TRANSPORTING CONFM CONAM CODAT COZET AENAM AEDAT AEZET
             WHERE NFUTN NE SPACE.

      MODIFY ZNFT1020 FROM TABLE LT_ZNFT1020.

      IF SY-SUBRC EQ 0.
        PERFORM SAVE_CHANGE_DOC_ZNFT1020.
        PERFORM SAVE_CHANGE_DOC_ZNFT1040.

        "Market Carry의 경우 반려시 청산번호 삭제
        IF GS_OUTTAB_C-CFUTN IS NOT INITIAL.
          DELETE FROM ZNFT1030 WHERE CFUTN  = GS_OUTTAB_C-CFUTN.
          IF SY-SUBRC = 0.
            COMMIT WORK.
          ENDIF.
        ENDIF.

        MESSAGE S003 DISPLAY LIKE 'S'
           WITH LV_DBCNT '건이 반려되었습니다.'.

        COMMIT WORK.
*--- 간편결재 전송.
        LOOP AT LT_ZNFT1040 INTO LS_ZNFT1040.
          PERFORM SEND_SIMPLE_APPROVAL
          USING LS_ZNFT1040-SHFNO
                    P_BUKRS
                    '2C'.
        ENDLOOP.
      ENDIF.
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '저장시 오류입니다.'.
      ROLLBACK WORK.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '저장시 오류입니다.'.
    ROLLBACK WORK.
    EXIT.
  ENDIF.

ENDFORM.                    " DATA_REJECT_C

*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGE_DOC_ZNFT1020
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_CHANGE_DOC_ZNFT1020 .

  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND.

  DATA: LS_ZNFT1020N TYPE ZNFT1020,
        LT_ZNFT1020N LIKE TABLE OF LS_ZNFT1020N,
        LS_ZNFT1020Y TYPE ZNFT1020,
        LT_ZNFT1020Y LIKE TABLE OF LS_ZNFT1020Y.

  LV_CDOC_UPD_OBJECT = 'U'.
  LV_TCODE    = SY-TCODE.

  CLEAR GS_ZNFT1020.
  LOOP AT GT_ZNFT1020 INTO GS_ZNFT1020.

*   변경전 데이터
    MOVE-CORRESPONDING GS_ZNFT1020 TO LS_ZNFT1020Y.

*   변경후 데이터
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1020N
      FROM ZNFT1020
     WHERE NFUTN EQ GS_ZNFT1020-NFUTN.

    LV_OBJECTID = GS_ZNFT1020-NFUTN.

    CALL FUNCTION 'ZNFT1020CHDOC_WRITE_DOCUMENT'
      EXPORTING
        OBJECTID     = LV_OBJECTID
        TCODE        = LV_TCODE
        UTIME        = SY-TIMLO
        UDATE        = SY-DATLO
        USERNAME     = SY-UNAME
        N_ZNFT1020   = LS_ZNFT1020N        " 변경후 데이터
        O_ZNFT1020   = LS_ZNFT1020Y        " 변경전 데이터
        UPD_ZNFT1020 = LV_CDOC_UPD_OBJECT.

  ENDLOOP.

ENDFORM.                    " SAVE_CHANGE_DOC_ZNFT1020

*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGE_DOC_ZNFT1040
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_CHANGE_DOC_ZNFT1040 .

  DATA: LS_ZNFT1040Y TYPE ZNFT1040,
        LS_ZNFT1040N TYPE ZNFT1040.

  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND.

  DATA: XGT_1041 LIKE YZNFT1041 OCCURS 0 WITH HEADER LINE,
        YGT_1041 LIKE YZNFT1041 OCCURS 0 WITH HEADER LINE.

  CLEAR  :XGT_1041, YGT_1041, LS_ZNFT1040N, LS_ZNFT1040Y.
  REFRESH:XGT_1041, YGT_1041.

  CHECK GT_ZNFT1040 IS NOT INITIAL.

* 승인&반려 전에 기존 선물요청데이터를 가지고 COMMIT 이후의
* 변경데이터를 다시 SELECT해서 변경이력을 생성한다.

  CLEAR GS_ZNFT1040.
  LOOP AT  GT_ZNFT1040 INTO GS_ZNFT1040.

    MOVE-CORRESPONDING GS_ZNFT1040 TO LS_ZNFT1040Y.

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1040N
      FROM ZNFT1040
     WHERE BUKRS EQ GS_ZNFT1040-BUKRS
       AND SHFNO EQ GS_ZNFT1040-SHFNO.

    LV_OBJECTID        = GS_ZNFT1040-SHFNO..
    LV_TCODE           = SY-TCODE.
    LV_CDOC_UPD_OBJECT = 'U'.

    CALL FUNCTION 'ZNFT1040CHDOC_WRITE_DOCUMENT'
      EXPORTING
        OBJECTID     = LV_OBJECTID
        TCODE        = LV_TCODE
        UTIME        = SY-TIMLO
        UDATE        = SY-DATLO
        USERNAME     = SY-UNAME
        N_ZNFT1040   = LS_ZNFT1040N
        O_ZNFT1040   = LS_ZNFT1040N
        UPD_ZNFT1040 = LV_CDOC_UPD_OBJECT
        UPD_ZNFT1041 = SPACE
      TABLES
        XZNFT1041    = XGT_1041
        YZNFT1041    = YGT_1041.

  ENDLOOP.

ENDFORM.                    " SAVE_CHANGE_DOC_ZNFT1040

*&---------------------------------------------------------------------*
*&      Form  DATA_RELOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_RELOAD.

  CLEAR  : GS_NFNUM,   GS_OUTTAB_C.
  REFRESH: GT_NFNUM_C, GT_OUTTAB_C.

  PERFORM GET_REQ_LIST.
  CHECK GV_ERROR IS INITIAL.
  PERFORM DATA_SELECT.

*  GS_STBL-ROW = 'X'.
*  GS_STBL-COL = 'X'.
*
*  CALL METHOD GRF_GRID->REFRESH_TABLE_DISPLAY
*    EXPORTING
*      I_SOFT_REFRESH = ' '
*      IS_STABLE      = GS_STBL.     "화면 라인 Refresh

ENDFORM.                    " DATA_RELOAD

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

*  필드 활성화 여부
    IF L_FIELDCAT-EDIT = 'X'.
      IF LS_CELLTAB-FIELDNAME = 'CHECK'.
        IF GS_OUTTAB_C-CHECK = '-'.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
        ENDIF.
      ELSE.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
      ENDIF.
    ELSE.
      LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    ENDIF.
    INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
  ENDLOOP.

ENDFORM.                    " FILL_CELLTAB_C

*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_ALL .

  LOOP AT GT_OUTTAB_C INTO GS_OUTTAB_C WHERE CHECK NE '-'.
    IF OK_SAVE = 'ASEL'.
      GS_OUTTAB_C-CHECK = 'X'.
    ELSE.
      CLEAR : GS_OUTTAB_C-CHECK.
    ENDIF.
    MODIFY GT_OUTTAB_C FROM GS_OUTTAB_C TRANSPORTING CHECK.
  ENDLOOP.

ENDFORM.                    " SELECT_ALL

*&---------------------------------------------------------------------*
*&      Form  PASWD_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM PASWD_CHECK  USING    PV_ERROR.

  IF GV_PASSWD IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '비밀번호를 입력하십시오.'.
    PV_ERROR = 'X'.
  ENDIF.

ENDFORM.                    " PASWD_CHECK

*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_SCREEN .

  IF NOT ( SY-UNAME EQ 'ZERPMM'  OR SY-UNAME EQ 'ZLSGMM2' OR
           SY-UNAME EQ 'ZLSGMM'  OR SY-UNAME EQ 'ZLSGLSC' OR
           SY-UNAME EQ 'ZLSGLSM' OR SY-UNAME EQ 'ZTEST07').
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'P_UNAME' OR
        SCREEN-NAME  = '%_P_UNAME_%_APP_%-TEXT'.
        SCREEN-INPUT     = 0.
        SCREEN-INVISIBLE = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " MODIFY_SCREEN

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
*& Form SAVE_CHANGE_DOC_ZNFT1030
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_CHANGE_DOC_ZNFT1030 .

  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND.

  DATA: LS_ZNFT1030N TYPE ZNFT1030,
        LT_ZNFT1030N LIKE TABLE OF LS_ZNFT1030N,
        LS_ZNFT1030Y TYPE ZNFT1030,
        LT_ZNFT1030Y LIKE TABLE OF LS_ZNFT1030Y.

  LV_CDOC_UPD_OBJECT = 'U'.
  LV_TCODE    = SY-TCODE.

  CLEAR GS_ZNFT1030.
  LOOP AT GT_ZNFT1030 INTO GS_ZNFT1030.

*   변경전 데이터
    MOVE-CORRESPONDING GS_ZNFT1030 TO LS_ZNFT1030Y.

*   변경후 데이터
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1030N
      FROM ZNFT1030
     WHERE CFUTN EQ GS_ZNFT1030-CFUTN.

    LV_OBJECTID = GS_ZNFT1030-CFUTN.

    CALL FUNCTION 'ZNFT1030CHDOC_WRITE_DOCUMENT'
      EXPORTING
        OBJECTID     = LV_OBJECTID
        TCODE        = LV_TCODE
        UTIME        = SY-TIMLO
        UDATE        = SY-DATLO
        USERNAME     = SY-UNAME
        N_ZNFT1030   = LS_ZNFT1030N        " 변경후 데이터
        O_ZNFT1030   = LS_ZNFT1030Y        " 변경전 데이터
        UPD_ZNFT1030 = LV_CDOC_UPD_OBJECT.

  ENDLOOP.

ENDFORM.
