*&---------------------------------------------------------------------*
*&  Include           ZNFR2530F01
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
*&      Form  CREATE_OBJECT_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_OBJECT_1 .

* Create Object : GRF_CONTAINER
  CREATE OBJECT GRF_CONTAINER_1
    EXPORTING
      CONTAINER_NAME = GRF_CONTAINER_NAME_1.

* Create Object : GRF_GRID
  CREATE OBJECT GRF_GRID_1
    EXPORTING
      I_PARENT      = GRF_CONTAINER_1
      I_APPL_EVENTS = 'X'.

ENDFORM.                    " CREATE_OBJECT_1


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

  IF SY-DYNNR = '1200'.
    GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
  ENDIF.

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
  'PERNR'       '승인권한자사번'   '10'     'L'    ' '     ,
  'SNAME'       '승인권한자'       '10'     'L'    ' '     ,
  'ERNAM'       '요청자'           '10'     'L'    ' '     ,
  'AUDAT'       '승인요청일'       '10'     'C'    ' '     ,
  'REMON'       '요청만기월'       '10'     'C'    ' '     ,
  'RMENG_R'     '요청수량'         '14'     'R'    ' '     ,
  'MEINS_R'     '단위'             '10'     'C'    ' '     ,
  'NFUTN'       '선물집행번호'     '12'     'L'    ' '     ,
  'RUDAT'       '집행일'           '10'     'C'    ' '     ,
  'BY_SL'       'Buy/Sell'         '10'     'C'    ' '     ,
  'BY_SL_NM'    'Buy/Sell'         '10'     'C'    ' '     ,
  'ENDMM'       '만기월'           '10'     'C'    'PERI'  ,
  'EMENG'       '집행수량'         '14'     'R'    ' '     ,
  'MEINS'       '단위'             '10'     'C'    ' '     ,
  'MITYP'       '집행유형'         '10'     'C'    ' '     ,
  'MITYP_NM'    '집행유형'         '10'     'C'    ' '     ,
  'MISPD'       'Spread'           '10'     'R'    ' '     ,
  'MIMON'       '기준월'           '10'     'C'    ' '     ,
  'PRICE'       '집행단가'         '10'     'R'    ' '     ,
  'WAERS'       '통화'             '5'      'C'    ' '     ,
  'REQNO_R'     '선물요청번호'     '12'     'L'    ' '     ,
  'H_NO1_R'     '선물요청항번'     '12'     'C'    ' '     ,
  'CONNO'       '계약번호'         '10'     'C'    ' '     ,
  'COTXT'       '계약명'           '20'     'L'    ' '     .

ENDFORM.                    " SET_GRID_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_FIELDCATALOG_1 .

  CLEAR GT_FIELDCAT.   REFRESH GT_FIELDCAT.

  PERFORM SET_FIELDCAT USING:
  'NFKEY'       '비철구분'         '1'      'C'    ' '     ,
  'EMENG'       '집행수량'         '14'     'R'    ' '     ,
  'MEINS'       '단위'             '10'     'C'    ' '     ,
  'ENDAT'       '만기일'           '10'     'C'    ' '     ,
  'PRICE'       '집행단가'         '14'     'R'    ' '     ,
  'WAERS'       '통화    '         '5'      'C'    ' '     ,
  'NFUTN'       '선물집행번호'     '10'     'L'    ' '     ,
  'YNFIN'       '정산여부'         '1'      'C'    ' '     ,
  'UPRLO'       '청산손익'         '14'     'R'    ' '     ,
  'UAERS'       '통화    '         '5'      'C'    ' '     ,
  'CFUTN'       '청산집행번호'     '10'     'L'    ' '     .

ENDFORM.                    " SET_GRID_FIELDCATALOG_1

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
    WHEN 'BY_SL'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'PRICE' OR 'MISPD'.
      GS_FIELDCAT-CFIELDNAME = 'WAERS'.
    WHEN 'UPRLO'.
      GS_FIELDCAT-CFIELDNAME = 'UAERS'.
*    WHEN 'WAERS' OR 'UAERS'.
*      GS_FIELDCAT-DATATYPE   = 'CUKY'.
    WHEN 'EMENG'.
      GS_FIELDCAT-QFIELDNAME = 'MEINS'.
    WHEN 'RMENG_R'.
      GS_FIELDCAT-QFIELDNAME = 'MEINS_R'.
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

  LOOP AT GT_OUTTAB_B INTO GS_OUTTAB_B.
    L_INDEX = SY-TABIX.
    REFRESH LT_CELLTAB.
    CLEAR GS_OUTTAB_B-CELLTAB.
    PERFORM FILL_CELLTAB_C CHANGING LT_CELLTAB.
    INSERT LINES OF LT_CELLTAB INTO TABLE GS_OUTTAB_B-CELLTAB.
    MODIFY GT_OUTTAB_B FROM GS_OUTTAB_B INDEX L_INDEX.
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
*&      Form  SET_EVENT_HANDLER_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_EVENT_HANDLER_1.

  CALL METHOD GRF_GRID_1->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CREATE OBJECT GRF_EVENT_RECEIVER_1.
  SET HANDLER :
    GRF_EVENT_RECEIVER_1->HANDLE_DOUBLE_CLICK_1 FOR GRF_GRID_1.

ENDFORM.                    " SET_EVENT_HANDLER_1
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
      IT_OUTTAB                     = GT_OUTTAB_B[]
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
*&      Form  SET_TABLE_FOR_FIRST_DISPLAY_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_TABLE_FOR_FIRST_DISPLAY_1 .

  GS_VARIANT-HANDLE = '0002'.
  GS_VARIANT-REPORT = SY-REPID.

  CLEAR   : GT_SORT.
  REFRESH : GT_SORT.

  CALL METHOD GRF_GRID_1->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT                    = GS_VARIANT
      IS_LAYOUT                     = GS_LAYOUT
      I_SAVE                        = 'A'
      I_DEFAULT                     = 'X'
      IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE
    CHANGING
      IT_FIELDCATALOG               = GT_FIELDCAT[]
      IT_SORT                       = GT_SORT[]
      IT_OUTTAB                     = GT_1020[]
      IT_FILTER                     = GT_FILTER
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY_1
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

  CLEAR : GV_ERROR.
  CLEAR : GV_PERNR, GV_UNAME.
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
       AND CONSQ EQ 1.

    IF SY-SUBRC EQ 0 AND LV_CNT GE 1.
    ELSE.
      GV_ERROR = 'X'.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH GV_UNAME '에 대한 요청권한이 없습니다.'.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH GV_UNAME '에 대한 사번정보가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

* --------------------------------------------------------------------
* 'B' = 만기이동요청승인
* --------------------------------------------------------------------
* CONSQ = 1 인경우는
* ZNFT1090-PERNR 과 ZNFT1091-PERNR이 명시적으로
* 같은 경우 데이터를 가져온다.

  DATA  : LT_NFNUM_B LIKE TABLE OF GS_NFNUM.
  CLEAR : GS_NFNUM. REFRESH : GT_NFNUM_B.

  IF GT_PERNR[] IS NOT INITIAL.
    SELECT Z1~NFNUM INTO CORRESPONDING FIELDS OF TABLE GT_NFNUM_B
      FROM ZNFT1091 AS Z1
           INNER JOIN ZNFT1090 AS Z2
              ON Z2~BUKRS EQ Z1~BUKRS AND Z2~CONGB EQ Z1~CONGB
             AND Z2~CONSQ EQ Z1~CONSQ AND Z2~PERNR EQ Z1~PERNR
           FOR ALL ENTRIES IN GT_PERNR
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~CONGB EQ '5'
       AND Z1~CONST EQ 'B'
       AND Z1~CONSQ EQ 1
       AND Z2~PERNR EQ GT_PERNR-PERNR
       AND Z2~LVORM NE 'X'.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH GV_UNAME '에 대한 사번정보가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

  IF GT_NFNUM_B IS NOT INITIAL.
    SORT GT_NFNUM_B BY NFNUM.
    CLEAR GV_H_CNT.
    SELECT COUNT(*) INTO GV_H_CNT
      FROM ZNFT1040
           FOR ALL ENTRIES IN GT_NFNUM_B
     WHERE BUKRS EQ P_BUKRS
       AND SHFNO EQ GT_NFNUM_B-NFNUM.
  ELSE.
    IF OK_SAVE EQ 'ALLOW' OR OK_SAVE EQ 'REJECT' OR
       OK_SAVE EQ 'CONF'  OR OK_SAVE EQ 'CANC'.
      GV_ERROR = 'X'.
    ELSE.
      GV_ERROR = 'X'.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH GV_UNAME
              '에 대한 승인요청데이터가 존재하지 않습니다.'.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_REQ_LIST

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

  READ TABLE GT_OUTTAB_B INTO GS_OUTTAB_B INDEX P_ES_ROW_NO-ROW_ID.

  IF SY-SUBRC EQ 0.

    CASE P_E_COLUMN.
      WHEN 'SHFNO'.
        IF NOT GS_OUTTAB_B-CONNO IS INITIAL.
          SET PARAMETER ID 'ZNFSHF' FIELD GS_OUTTAB_B-SHFNO.
          CALL TRANSACTION 'ZNF2M2303' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE '만기이동번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN 'REQNO_R'.
        IF NOT GS_OUTTAB_B-REQNO_R IS INITIAL.
          SET PARAMETER ID 'ZNFREQ' FIELD GS_OUTTAB_B-REQNO_R.
          CALL TRANSACTION 'ZNF2M2103' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE '선물요청번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN 'CONNO'.
        IF NOT GS_OUTTAB_B-CONNO IS INITIAL.
          SET PARAMETER ID 'ZNFCON' FIELD GS_OUTTAB_B-CONNO.
          CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE '계약번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
    ENDCASE.

  ENDIF.

ENDFORM.                    " ALV_EVENT_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  ALV_EVENT_DOUBLE_CLICK_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW  text
*      -->P_E_COLUMN  text
*      -->P_ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM ALV_EVENT_DOUBLE_CLICK_1 USING P_E_ROW     TYPE LVC_S_ROW
                                    P_E_COLUMN  TYPE LVC_S_COL
                                    P_ES_ROW_NO TYPE LVC_S_ROID.

  READ TABLE GT_1020 INDEX P_ES_ROW_NO-ROW_ID.

  IF SY-SUBRC EQ 0.
    CASE P_E_COLUMN.
      WHEN 'NFUTN'.
        PERFORM DISPLAY_FUTRUES_HISTORY USING 'N'
                                              GT_1020-NFUTN.

      WHEN 'CFUTN'.
        PERFORM DISPLAY_FUTRUES_HISTORY USING 'C'
                                              GT_1020-CFUTN.

    ENDCASE.

  ENDIF.

ENDFORM.                    " ALV_EVENT_DOUBLE_CLICK_1

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

  CLEAR GS_OUTTAB_B.
  LOOP AT P_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    LV_INDEX = LS_MOD_CELLS-ROW_ID.
*   Data 가공용 Structure
    READ TABLE GT_OUTTAB_B INTO GS_OUTTAB_B INDEX LV_INDEX.
    IF SY-SUBRC EQ 0.
      CASE LS_MOD_CELLS-FIELDNAME.
        WHEN 'CHECK'.
          IF LS_MOD_CELLS-VALUE EQ 'X'.
            GS_OUTTAB_B-CHECK = 'X'.
            MODIFY GT_OUTTAB_B FROM GS_OUTTAB_B INDEX LV_INDEX
                               TRANSPORTING CHECK.
          ELSE.
            GS_OUTTAB_B-CHECK = SPACE.
            MODIFY GT_OUTTAB_B FROM GS_OUTTAB_B INDEX LV_INDEX
                               TRANSPORTING CHECK.
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " ALV_EVENT_DATA_CHANGED

*&---------------------------------------------------------------------*
*&      Form  DATA_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LIST_REQ_TYPE  text
*----------------------------------------------------------------------*
FORM DATA_SELECT.

  PERFORM GET_REQNO_B.

ENDFORM.                    " DATA_SELECT

*&---------------------------------------------------------------------*
*&      Form  GET_REQNO_B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_REQNO_B .

  DATA: LV_FLAG TYPE CHAR01.
  DATA: LV_TABIX TYPE SY-TABIX.

  SELECT Z2~BUKRS
         Z1~SHFNO
         Z1~H_NO1
         Z6~PERNR
*        PA0001-SNAME
         Z6~ERNAM
         Z6~ERDAT AS AUDAT
         Z3~NFUTN
         Z3~NFKEY
         Z4~REQNO AS REQNO_R
         Z4~H_NO1 AS H_NO1_R
         Z2~OFUTN
         Z5~CONNO
         Z5~COTXT
         Z3~RUDAT
         Z3~BY_SL
         Z4~ENDMM
         Z3~EMENG
         Z3~MEINS
         Z3~MITYP
         Z3~MISPD
         Z3~MIMON
         Z3~PRICE
         Z3~WAERS
         Z1~REMON
         Z1~RMENG AS RMENG_R
         Z1~MEINS AS MEINS_R
         INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB_B
    FROM ZNFT1041 AS Z1
         INNER JOIN ZNFT1040 AS Z2
           ON Z2~SHFNO EQ Z1~SHFNO
         INNER JOIN ZNFT1020 AS Z3
           ON Z3~NFUTN EQ Z2~OFUTN
         INNER JOIN ZNFT1011 AS Z4
           ON Z4~REQNO EQ Z3~REQNO AND Z4~H_NO1 EQ Z3~H_NO1
         INNER JOIN ZNFT1000 AS Z5
           ON Z5~CONNO EQ Z4~CONNO
         LEFT OUTER JOIN ZNFT1091 AS Z6
           ON Z6~NFNUM EQ Z1~SHFNO AND Z6~CONGB EQ '5' AND
              Z6~CONSQ EQ '1'
         FOR ALL ENTRIES IN GT_NFNUM_B
   WHERE Z2~SHFNO EQ GT_NFNUM_B-NFNUM
     AND Z1~GUBUN EQ '1'.

  IF SY-SUBRC EQ 0 AND GT_OUTTAB_B IS NOT INITIAL.
    SORT GT_OUTTAB_B BY BUKRS SHFNO H_NO1.
    CLEAR: LV_TABIX, GS_OUTTAB_B.
    LOOP AT GT_OUTTAB_B INTO GS_OUTTAB_B.
      LV_TABIX = SY-TABIX.

      AT NEW SHFNO.
        LV_FLAG = 'X'.
      ENDAT.

      IF LV_FLAG = 'X'.
        CLEAR : LV_FLAG.
      ELSE.
        GS_OUTTAB_B-CHECK = '-'.
      ENDIF.

*     BUY/SELL
      PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                     GS_OUTTAB_B-BY_SL
                                     GS_OUTTAB_B-BY_SL_NM.

*     집행유형
      PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                     GS_OUTTAB_B-MITYP
                                     GS_OUTTAB_B-MITYP_NM.

      PERFORM GET_PERNR_DESC USING GS_OUTTAB_B-PERNR
                                   GS_OUTTAB_B-SNAME.

*___만기이동차수
      PERFORM GET_SHIFT_COUNT(ZNFR2310) USING GS_OUTTAB_B-OFUTN
                                              GS_OUTTAB_B-SHFCNT.

      MODIFY GT_OUTTAB_B FROM GS_OUTTAB_B INDEX LV_TABIX.
      CLEAR: LV_TABIX, GS_OUTTAB_B.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " GET_REQNO_B

*&---------------------------------------------------------------------*
*&      Form  DATA_ALLOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_ALLOW .

* 만기이동요청승인
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
*  SELECT SINGLE * FROM PA0105
*   WHERE USRTY EQ '9001'
*     AND USRID EQ GV_UNAME
*     AND ENDDA GE SY-DATLO
*     AND BEGDA LE SY-DATLO.

*- [MM] HR 테이블 대체 추가
  SELECT SINGLE * FROM ZPA0105
   WHERE USRTY EQ '9001'
     AND USRID EQ GV_UNAME
     AND ENDDA GE SY-DATLO
     AND BEGDA LE SY-DATLO.
*- [MM] HR 테이블 대체 추가
  IF SY-SUBRC EQ 0.
    CALL SCREEN 1210 STARTING AT 10 03
                     ENDING   AT 55 06.
    CHECK GV_ERROR NE 'X'.
  ENDIF.


  PERFORM DATA_ALLOW_B.

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

  DATA: LS_OUTTAB_B LIKE GS_OUTTAB_B,
        LT_OUTTAB_B LIKE TABLE OF LS_OUTTAB_B.

* 선택한 동일-사번체크 (공용인 경우 로그인한 사번의 데이터만 처리가능)
  DATA: BEGIN OF LT_PERNR OCCURS 0,
*          PERNR LIKE PA0105-PERNR,
          PERNR LIKE ZPA0105-PERNR, " [MM] HR 테이블 대체 추가
        END   OF LT_PERNR,
        LV_CHECK_CNT TYPE I.

  LOOP AT GT_OUTTAB_B INTO GS_OUTTAB_B WHERE CHECK EQ 'X'.
    MOVE-CORRESPONDING GS_OUTTAB_B TO LS_OUTTAB_B.
    APPEND LS_OUTTAB_B TO LT_OUTTAB_B.
  ENDLOOP.

  IF LT_OUTTAB_B IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '승인하실 데이터를 선택하십시오.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

* ### 로그인ID => 사번 가져오기
  DATA: LV_NFNUM TYPE ZNFNUM.
  DATA: LV_CONSQ TYPE ZCONSQ,
        LV_CNT   TYPE I.

  LOOP AT LT_OUTTAB_B INTO LS_OUTTAB_B.
*   ==========================================================
*     승인권한 점검
*   ==========================================================
    CLEAR LV_CONSQ.
    SELECT SINGLE CONSQ INTO LV_CONSQ
      FROM ZNFT1091
     WHERE BUKRS EQ P_BUKRS
       AND NFNUM EQ LS_OUTTAB_B-SHFNO
       AND CONGB EQ '5'
       AND CONST EQ 'B'.

    IF SY-SUBRC NE 0.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '승인전 데이터가 없습니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

    IF LV_CONSQ EQ 1.
*     GV_CONSQ = 1 인경우는
*     ZNFT1090-PERNR 과 ZNFT1091-PERNR이 명시적으로
*     같은 경우 데이터를 가져온다.
      CLEAR LV_CNT.
      IF GT_PERNR[] IS NOT INITIAL.
        SELECT COUNT(*) INTO LV_CNT
          FROM ZNFT1091 AS Z1
               INNER JOIN ZNFT1090 AS Z2
                  ON Z2~BUKRS EQ Z1~BUKRS AND Z2~CONSQ EQ Z1~CONSQ
                 AND Z2~CONGB EQ Z1~CONGB AND Z2~PERNR EQ Z1~PERNR
               FOR ALL ENTRIES IN GT_PERNR
         WHERE Z1~BUKRS EQ P_BUKRS
           AND Z1~CONST EQ 'B'
           AND Z1~NFNUM EQ LS_OUTTAB_B-SHFNO
           AND Z2~CONGB EQ '5'
           AND Z2~CONSQ EQ 1
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
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '승인권한이 없습니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " DATA_CHECK_A

*&---------------------------------------------------------------------*
*&      Form  DATA_ALLOW_B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_ALLOW_B .

  DATA: LS_ZNFT1040 TYPE ZNFT1040,
        LT_ZNFT1040 LIKE TABLE OF LS_ZNFT1040.

  DATA: LS_ZNFT1091  TYPE ZNFT1091,
        LT_ZNFT1091  LIKE TABLE OF LS_ZNFT1091,
        LS_ZNFT1091N TYPE ZNFT1091,
        LT_ZNFT1091N LIKE TABLE OF LS_ZNFT1091,
        LS_ZNFT1091Y TYPE ZNFT1091.

  CLEAR GS_OUTTAB_B.
  CLEAR LS_ZNFT1040.  REFRESH LT_ZNFT1040.
  CLEAR LS_ZNFT1091.  REFRESH LT_ZNFT1091.
  CLEAR LS_ZNFT1091N. REFRESH LT_ZNFT1091N.
  CLEAR GS_ZNFT1040.  REFRESH GT_ZNFT1040.

* 개인아이디인 경우 인터널테이블에서 읽어오기
  IF GV_PERNR IS INITIAL AND LINES( GT_PERNR ) EQ 1.
    READ TABLE GT_PERNR INDEX 1.
    IF SY-SUBRC EQ 0.
      GV_PERNR = GT_PERNR-PERNR.
    ENDIF.
  ENDIF.

  LOOP AT GT_OUTTAB_B INTO GS_OUTTAB_B WHERE CHECK EQ 'X'.

* =================================================
* GV_CONSQ : DATA_CHECK_B 로직에서 가져옴
* =================================================

*   ZNFT1040 데이터 변경 INTERNAL TABLE
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1040
      FROM ZNFT1040
     WHERE BUKRS EQ GS_OUTTAB_B-BUKRS
       AND SHFNO EQ GS_OUTTAB_B-SHFNO.

    IF SY-SUBRC EQ 0.

*     ### 문서변경이력관리용 ###
      APPEND LS_ZNFT1040 TO GT_ZNFT1040.

      LS_ZNFT1040-DRSTA = '3'.
      LS_ZNFT1040-AENAM = GV_UNAME.
      LS_ZNFT1040-AEDAT = SY-DATLO.
      LS_ZNFT1040-AEZET = SY-TIMLO.
      APPEND LS_ZNFT1040 TO LT_ZNFT1040.
      CLEAR  LS_ZNFT1040.
    ENDIF.

*   ZNFT1091 데이터 변경 : 해당 결재순번의 요청승인상태 = 'A'로 변경
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1091
      FROM ZNFT1091
     WHERE BUKRS EQ GS_OUTTAB_B-BUKRS
       AND NFNUM EQ GS_OUTTAB_B-SHFNO
       AND CONGB EQ '5'
       AND CONSQ EQ 1.

    IF SY-SUBRC EQ 0.
      LS_ZNFT1091-CONST = 'A'.
      LS_ZNFT1091-PERNR = GV_PERNR.
      LS_ZNFT1091-USRID = GV_UNAME.
      LS_ZNFT1091-AENAM = GV_UNAME.
      LS_ZNFT1091-AEDAT = SY-DATLO.
      LS_ZNFT1091-AEZET = SY-TIMLO.
      APPEND LS_ZNFT1091 TO LT_ZNFT1091.

*     데이터 신규 생성 : 다음 결재순번의 데이터를 생성
*                        요청승인상태 = 'B'
      LS_ZNFT1091N-BUKRS = LS_ZNFT1091-BUKRS.
      LS_ZNFT1091N-NFNUM = LS_ZNFT1091-NFNUM.

      SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1091Y
        FROM ZNFT1091
       WHERE BUKRS EQ LS_ZNFT1091N-BUKRS
         AND NFNUM EQ LS_ZNFT1091N-NFNUM
         AND CONSQ EQ 2.

      IF SY-SUBRC EQ 0.
        MOVE-CORRESPONDING LS_ZNFT1091Y TO LS_ZNFT1091N.
        LS_ZNFT1091N-CONGB = '5'.
        LS_ZNFT1091N-CONSQ = 2.
        LS_ZNFT1091N-CONST = 'B'.
*        LS_ZNFT1091N-PERNR = GV_PERNR.
        LS_ZNFT1091N-PERNR = SPACE.
*        LS_ZNFT1091N-USRID = GV_UNAME.
        LS_ZNFT1091N-USRID = SPACE.
        LS_ZNFT1091N-AENAM = GV_UNAME.
        LS_ZNFT1091N-AEDAT = SY-DATLO.
        LS_ZNFT1091N-AEZET = SY-TIMLO.
      ELSE.
        LS_ZNFT1091N-CONGB = '5'.
        LS_ZNFT1091N-CONSQ = 2.
        LS_ZNFT1091N-CONST = 'B'.
*        LS_ZNFT1091N-PERNR = GV_PERNR.
        LS_ZNFT1091N-PERNR = SPACE.
*        LS_ZNFT1091N-USRID = GV_UNAME.
        LS_ZNFT1091N-USRID = SPACE.
        LS_ZNFT1091N-ERNAM = GV_UNAME.
        LS_ZNFT1091N-ERDAT = SY-DATLO.
        LS_ZNFT1091N-ERZET = SY-TIMLO.
        LS_ZNFT1091N-AENAM = GV_UNAME.
        LS_ZNFT1091N-AEDAT = SY-DATLO.
        LS_ZNFT1091N-AEZET = SY-TIMLO.
      ENDIF.
      APPEND LS_ZNFT1091N TO LT_ZNFT1091N.
    ENDIF.
    CLEAR : LS_ZNFT1091, LS_ZNFT1091N, LS_ZNFT1091Y.
  ENDLOOP.

  DATA: LV_DBCNT TYPE I.
  CLEAR LV_DBCNT.

  LV_DBCNT = LINES( LT_ZNFT1040 ).

* ZNFT1040 - 변경
  MODIFY ZNFT1040 FROM TABLE LT_ZNFT1040.
  IF SY-SUBRC EQ 0.
*   ZNFT1091 - 변경
    MODIFY ZNFT1091 FROM TABLE LT_ZNFT1091.
    IF SY-SUBRC EQ 0.
*     ZNFT1091 - 신규
      MODIFY ZNFT1091 FROM TABLE LT_ZNFT1091N.
      IF SY-SUBRC EQ 0.
        PERFORM SAVE_CHANGE_DOC_ZNFT1040.
        MESSAGE S003 DISPLAY LIKE 'S'
           WITH LV_DBCNT '건이 승인 완료되었습니다.'.

        COMMIT WORK.
*--- 간편결재 전송.
        LOOP AT LT_ZNFT1040 INTO LS_ZNFT1040.
          PERFORM SEND_SIMPLE_APPROVAL
          USING LS_ZNFT1040-SHFNO
                    LS_ZNFT1040-BUKRS
                    '2B'.
        ENDLOOP.
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

ENDFORM.                    " DATA_ALLOW_B

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

* 진행상황 체크
  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM
    USING '확인'
          '반려처리 하시겠습니까?'
          '1'
          GV_ANSWER.
  CHECK GV_ANSWER EQ '1'.

* 공용아이디 체크로직
*  SELECT SINGLE * FROM PA0105
*   WHERE USRTY EQ '9001'
*     AND USRID EQ GV_UNAME
*     AND ENDDA GE SY-DATLO
*     AND BEGDA LE SY-DATLO.

*- [MM] HR 테이블 대체 추가
  SELECT SINGLE * FROM ZPA0105
   WHERE USRTY EQ '9001'
     AND USRID EQ GV_UNAME
     AND ENDDA GE SY-DATLO
     AND BEGDA LE SY-DATLO.
*- [MM] HR 테이블 대체 추가

  IF SY-SUBRC EQ 0.
    CALL SCREEN 1210 STARTING AT 10 03
                     ENDING   AT 55 06.
    CHECK GV_ERROR NE 'X'.
  ENDIF.


  PERFORM DATA_REJECT_B.

ENDFORM.                    " DATA_REJECT

*&---------------------------------------------------------------------*
*&      Form  DATA_CHECK_R
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM DATA_CHECK_R  USING  PV_ERROR.


  DATA: LV_DBCNT TYPE I.
  DATA: LS_OUTTAB_B LIKE GS_OUTTAB_B,
        LT_OUTTAB_B LIKE TABLE OF LS_OUTTAB_B.

* 선택한 동일-사번체크 (공용인 경우 로그인한 사번의 데이터만 처리가능)
  DATA: BEGIN OF LT_PERNR OCCURS 0,
*          PERNR LIKE PA0105-PERNR,
          PERNR LIKE ZPA0105-PERNR,  " [MM] HR 테이블 대체 추가
        END   OF LT_PERNR,
        LV_CHECK_CNT TYPE I.

  LOOP AT GT_OUTTAB_B INTO GS_OUTTAB_B WHERE CHECK EQ 'X'.
    MOVE-CORRESPONDING GS_OUTTAB_B TO LS_OUTTAB_B.
    APPEND LS_OUTTAB_B TO LT_OUTTAB_B.
  ENDLOOP.

  IF LT_OUTTAB_B IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '승인하실 데이터를 선택하십시오.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

* ### 로그인ID => 사번 가져오기
  DATA: LV_NFNUM TYPE ZNFNUM,
        LV_RSTAT TYPE ZRSTAT.

  DATA: LV_CONSQ TYPE ZCONSQ,
        LV_CNT   TYPE I.

  LOOP AT LT_OUTTAB_B INTO LS_OUTTAB_B.
*   ==========================================================
*     승인권한 점검
*   ==========================================================
    CLEAR LV_CONSQ.
    SELECT SINGLE CONSQ INTO LV_CONSQ
      FROM ZNFT1091
     WHERE BUKRS EQ P_BUKRS
       AND NFNUM EQ LS_OUTTAB_B-SHFNO
       AND CONGB EQ '5'
       AND CONST EQ 'B'.

    IF SY-SUBRC NE 0.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '승인전 데이터가 없습니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

    IF LV_CONSQ EQ 1.
      CLEAR LV_CNT.
      IF GT_PERNR[] IS NOT INITIAL.
        SELECT COUNT(*) INTO LV_CNT
          FROM ZNFT1091 AS Z1
               INNER JOIN ZNFT1090 AS Z2
                  ON Z2~BUKRS EQ Z1~BUKRS AND Z2~CONSQ EQ Z1~CONSQ
                 AND Z2~CONGB EQ Z1~CONGB AND Z2~PERNR EQ Z1~PERNR
               FOR ALL ENTRIES IN GT_PERNR
         WHERE Z1~BUKRS EQ P_BUKRS
           AND Z1~CONST EQ 'B'
           AND Z1~NFNUM EQ LS_OUTTAB_B-SHFNO
           AND Z2~CONGB EQ '5'
           AND Z2~CONSQ EQ 1
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
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '승인권한이 없습니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " DATA_CHECK_R

*&---------------------------------------------------------------------*
*&      Form  DATA_REJECT_B
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_REJECT_B .


  DATA: LS_ZNFT1040 TYPE ZNFT1040,
        LT_ZNFT1040 LIKE TABLE OF LS_ZNFT1040.

  DATA: LS_ZNFT1091 TYPE ZNFT1091,
        LT_ZNFT1091 LIKE TABLE OF LS_ZNFT1091.

  CLEAR GS_OUTTAB_B.
  CLEAR LS_ZNFT1040.  REFRESH LT_ZNFT1040.
  CLEAR LS_ZNFT1091.  REFRESH LT_ZNFT1091.
  CLEAR GS_ZNFT1040.  REFRESH GT_ZNFT1040.

* 개인아이디인 경우 인터널테이블에서 읽어오기
  IF GV_PERNR IS INITIAL AND LINES( GT_PERNR ) EQ 1.
    READ TABLE GT_PERNR INDEX 1.
    IF SY-SUBRC EQ 0.
      GV_PERNR = GT_PERNR-PERNR.
    ENDIF.
  ENDIF.

  LOOP AT GT_OUTTAB_B INTO GS_OUTTAB_B WHERE CHECK EQ 'X'.

*   ZNFT1040 데이터 변경 INTERNAL TABLE
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1040
      FROM ZNFT1040
     WHERE BUKRS EQ GS_OUTTAB_B-BUKRS
       AND SHFNO EQ GS_OUTTAB_B-SHFNO.

    IF SY-SUBRC EQ 0.

*     ### 문서변경이력관리용 ###
      APPEND LS_ZNFT1040 TO GT_ZNFT1040.

      LS_ZNFT1040-DRSTA = '7'.
      LS_ZNFT1040-AENAM = GV_UNAME.
      LS_ZNFT1040-AEDAT = SY-DATLO.
      LS_ZNFT1040-AEZET = SY-TIMLO.
      APPEND LS_ZNFT1040 TO LT_ZNFT1040.
    ENDIF.

*   ZNFT1091 데이터 변경 : 해당 결재순번의 요청승인상태 = 'A'로 변경
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1091
      FROM ZNFT1091
     WHERE BUKRS EQ GS_OUTTAB_B-BUKRS
       AND NFNUM EQ GS_OUTTAB_B-SHFNO
       AND CONGB EQ '5'
       AND CONSQ EQ 1.

    LS_ZNFT1091-CONST = 'R'.
    LS_ZNFT1091-AENAM = GV_UNAME.
    LS_ZNFT1091-AEDAT = SY-DATLO.
    LS_ZNFT1091-AEZET = SY-TIMLO.
    APPEND LS_ZNFT1091 TO LT_ZNFT1091.

    CLEAR : LS_ZNFT1040, LS_ZNFT1091.
  ENDLOOP.

  DATA: LV_DBCNT TYPE I.
  CLEAR LV_DBCNT.

  LV_DBCNT = LINES( LT_ZNFT1091 ).

  MODIFY ZNFT1040 FROM TABLE LT_ZNFT1040.
  IF SY-SUBRC EQ 0.
    MODIFY ZNFT1091 FROM TABLE LT_ZNFT1091.
    IF SY-SUBRC EQ 0.
      PERFORM SAVE_CHANGE_DOC_ZNFT1040.
      MESSAGE S003 DISPLAY LIKE 'S'
         WITH '선물요청-' LV_DBCNT '건이 반려되었습니다.'.

      COMMIT WORK.

*--- 간편결재 전송.
      LOOP AT LT_ZNFT1040 INTO LS_ZNFT1040.
        PERFORM SEND_SIMPLE_APPROVAL
        USING LS_ZNFT1040-SHFNO
                  LS_ZNFT1040-BUKRS
                  '2B'.
      ENDLOOP.
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

ENDFORM.                    " DATA_REJECT_B
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

  DATA: YZNFT1040 LIKE ZNFT1040,
        XGT_1041  LIKE YZNFT1041 OCCURS 0 WITH HEADER LINE,
        YGT_1041  LIKE YZNFT1041 OCCURS 0 WITH HEADER LINE.

  CLEAR  :XGT_1041, YGT_1041, LS_ZNFT1040N, LS_ZNFT1040Y.
  REFRESH:XGT_1041, YGT_1041.

  CHECK GT_ZNFT1040 IS NOT INITIAL.

* 승인&반려 전에 기존 선물요청데이터를 가지고 COMMIT 이후의
* 변경데이터를 다시 SELECT해서 변경이력을 생성한다.

  CLEAR GS_ZNFT1040.
  LOOP AT  GT_ZNFT1040 INTO GS_ZNFT1040.

*   변경전 데이터 : GT_ZNFT1040에 저장됨
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
        O_ZNFT1040   = LS_ZNFT1040Y
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

  CLEAR  : GS_NFNUM,   GS_OUTTAB_B.
  REFRESH: GT_NFNUM_B, GT_OUTTAB_B.

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
        IF GS_OUTTAB_B-CHECK = '-'.
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

  LOOP AT GT_OUTTAB_B INTO GS_OUTTAB_B WHERE CHECK NE '-'.
    IF OK_SAVE = 'ASEL'.
      GS_OUTTAB_B-CHECK = 'X'.
    ELSE.
      CLEAR : GS_OUTTAB_B-CHECK.
    ENDIF.
    MODIFY GT_OUTTAB_B FROM GS_OUTTAB_B TRANSPORTING CHECK.
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
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DETAIL .

  PERFORM CHECK_SELECTED_ROWS USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  PERFORM GET_DETAIL_DATA USING GV_ERROR.

  CHECK GV_ERROR IS INITIAL.

  CALL SCREEN 1220 STARTING AT 10 1.

ENDFORM.                    " DISPLAY_DETAIL
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_ROWS  USING PV_ERROR.
  DATA: LV_CNT      TYPE I.

  CLEAR : LV_CNT, PV_ERROR.

  LOOP AT GT_OUTTAB_B INTO GS_OUTTAB_B WHERE CHECK EQ 'X'.
    LV_CNT = LV_CNT + 1.
  ENDLOOP.

  IF LV_CNT > 1.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '한 라인만 선택한 후 실행하십시오.'.

    EXIT.
  ELSEIF LV_CNT < 1.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택된 라인이 없습니다.'.

    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  GET_DETAIL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DETAIL_DATA  USING PV_ERROR.

  CLEAR   : ZNFT1000, GV_NTEXT, GV_PTEXT, GV_VTEXT, PV_ERROR,
            GT_1020.
  REFRESH : GT_1020.

*___계약정보
  SELECT SINGLE *
    FROM ZNFT1000
   WHERE CONNO = GS_OUTTAB_B-CONNO.

  IF SY-SUBRC <> 0.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '존재하지 않는 계약번호입니다.'.

    EXIT.
  ENDIF.

*___고객명
  IF ZNFT1000-KUNNR IS NOT INITIAL.
    PERFORM GET_KUNNR_DESC USING ZNFT1000-KUNNR
                                 ZNFT1000-NCUST.
  ENDIF.

*___사업부명
  PERFORM GET_NFCTR_DESC USING P_BUKRS
                               ZNFT1000-NFCTR
                               GV_NTEXT.

*___손익센터명
  PERFORM GET_PRCTR_DESC USING P_BUKRS
                               ZNFT1000-PRCTR
                               GV_PTEXT.

*___영업그룹명
  PERFORM GET_VKGRP_DESC USING P_BUKRS
                               ZNFT1000-VKGRP
                               GV_VTEXT.

*___계약품목정보
  PERFORM SET_CONNO_ITEM_DATA.

*___선물집행정보
  SELECT B~NFUTN
         B~NFKEY
         B~BY_SL
         B~EMENG
         B~MEINS
         B~ENDAT
         B~PRICE
         B~MISPD
         B~WAERS
         B~YNFIN
    INTO CORRESPONDING FIELDS OF TABLE GT_1020
    FROM ZNFT1011 AS A
   INNER JOIN ZNFT1020 AS B
      ON A~REQNO = B~REQNO
     AND A~H_NO1 = B~H_NO1
   WHERE A~CONNO = ZNFT1000-CONNO
     AND ( B~YNCAN = ' ' OR ( B~CONFM <> '3' AND B~CONFM <> '7' ) ).

  LOOP AT GT_1020.
*___연결된 청산건 상태 점검
    SELECT SINGLE CFUTN
                  PRICE
                  MISPD
      INTO (GT_1020-CFUTN,  GT_1020-PRICE_C,
            GT_1020-MISPD_C)
      FROM ZNFT1030
     WHERE NFUTN = GT_1020-NFUTN
       AND ( YNCAN = ' ' OR ( CONFM <> '3' AND CONFM <> '7' ) ).

    IF SY-SUBRC = 0 AND GT_1020-YNFIN = 'X'.
      IF GT_1020-BY_SL = 'B'.
        GT_1020-UPRLO = ( GT_1020-PRICE_C + GT_1020-MISPD_C
                        - GT_1020-PRICE   - GT_1020-MISPD )
                        * GT_1020-EMENG.
      ELSE.
        GT_1020-UPRLO = ( GT_1020-PRICE   + GT_1020-MISPD
                        - GT_1020-PRICE_C - GT_1020-MISPD_C )
                        * GT_1020-EMENG.
      ENDIF.

      GT_1020-UAERS = 'USD'.
    ENDIF.

    MODIFY GT_1020.
  ENDLOOP.

  SORT GT_1020 BY NFKEY NFUTN.

ENDFORM.                    " GET_DETAIL_DATA
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_FUTRUES_HISTORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_FUTRUES_HISTORY  USING PV_FLAG
                                    PV_NFUTN.
  DATA: LT_RSPAR LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

  CLEAR   : LT_RSPAR.
  REFRESH : LT_RSPAR.

  APPEND_PARAM : LT_RSPAR 'P_BUKRS' 'P' ' ' ' '  P_BUKRS       ' '.

  IF PV_FLAG = 'N'.
    APPEND_PARAM : LT_RSPAR 'S_NFUTN' 'S' 'I' 'EQ' PV_NFUTN      ' ',
                   LT_RSPAR 'P_CHK11' 'P' ' ' ' '  'X'           ' ',
                   LT_RSPAR 'P_CHK12' 'P' ' ' ' '  ' '           ' '.
  ELSE.
    APPEND_PARAM : LT_RSPAR 'S_CFUTN' 'S' 'I' 'EQ' PV_NFUTN      ' ',
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
*&      Form  SET_CONNO_ITEM_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CONNO_ITEM_DATA .
  DATA: LV_ERROR.

  CLEAR   : GV_NFKEY_CU, GV_EMENG_CU, GV_MEINS_CU,
            GV_PRIND_CU, GV_SUJUP_CU,
            GV_NFKEY_AL, GV_EMENG_AL, GV_MEINS_AL,
            GV_PRIND_AL, GV_SUJUP_AL,
            GV_NFKEY_PB, GV_EMENG_PB, GV_MEINS_PB,
            GV_PRIND_PB, GV_SUJUP_PB,
            GV_NFKEY_NI, GV_EMENG_NI, GV_MEINS_NI,
            GV_PRIND_NI, GV_SUJUP_NI,
            GT_1001.
  REFRESH : GT_1001.

*___계약품목 정보
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_1001
    FROM ZNFT1001
   WHERE CONNO = ZNFT1000-CONNO.

  LOOP AT GT_1001.
*___가격구분/비철수주가
    PERFORM PRICE_CLASSIFICATION USING GT_1001-CONNO
                                       GT_1001-NFKEY
                                       GT_1001-PRIND
                                       GT_1001-SUJUP
                                       LV_ERROR.

    MODIFY GT_1001.

    CASE GT_1001-NFKEY.
      WHEN 'CU'.
        GV_NFKEY_CU = GT_1001-NFKEY.
        GV_EMENG_CU = GT_1001-EMENG.
        GV_MEINS_CU = GT_1001-MEINS.
        GV_PRIND_CU = GT_1001-PRIND.
        GV_SUJUP_CU = GT_1001-SUJUP.
      WHEN 'AL'.
        GV_NFKEY_AL = GT_1001-NFKEY.
        GV_EMENG_AL = GT_1001-EMENG.
        GV_MEINS_AL = GT_1001-MEINS.
        GV_PRIND_AL = GT_1001-PRIND.
        GV_SUJUP_AL = GT_1001-SUJUP.
      WHEN 'PB'.
        GV_NFKEY_PB = GT_1001-NFKEY.
        GV_EMENG_PB = GT_1001-EMENG.
        GV_MEINS_PB = GT_1001-MEINS.
        GV_PRIND_PB = GT_1001-PRIND.
        GV_SUJUP_PB = GT_1001-SUJUP.
      WHEN 'NI'.
        GV_NFKEY_NI = GT_1001-NFKEY.
        GV_EMENG_NI = GT_1001-EMENG.
        GV_MEINS_NI = GT_1001-MEINS.
        GV_PRIND_NI = GT_1001-PRIND.
        GV_SUJUP_NI = GT_1001-SUJUP.
    ENDCASE.
  ENDLOOP.


ENDFORM.                    " SET_CONNO_ITEM_DATA
FORM SEND_SIMPLE_APPROVAL  USING    p_EXENO
                                    P_BUKRS
                                    P_TYPE TYPE ZESAZTYPE.


  CALL FUNCTION 'ZSA1_MM_MAKE_SEND_DATA'
    EXPORTING
      I_BUKRS = P_BUKRS
      I_EXENO = P_EXENO
      I_EXTYP = P_TYPE.

ENDFORM.
