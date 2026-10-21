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

  CLEAR : GS_SORT. REFRESH GT_SORT.

  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'CFUTN'.
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
  'CFUTN'       '청산선물집행번호' '12'     'L'    ' '     ,
  'NFKEY'       '비철구분'         '10'     'C'    ' '     ,
  'AUDAT'       '승인요청일'       '10'     'C'    ' '     ,
  'RUDAT'       '청산집행일'       '10'     'C'    ' '     ,
  'FCM'         'FCM'              '5'      'C'    'ALPHA' ,
  'FCM_NM'      'FCM'              '10'     'L'    ' '     ,
  'BY_SL'       'Buy/Sell'         '10'     'C'    ' '     ,
  'BY_SL_NM'    'Buy/Sell'         '10'     'C'    ' '     ,
  'ENDAT'       '만기일'           '10'     'C'    ' '     ,
  'MITYP'       '집행유형'         '10'     'C'    ' '     ,
  'MISPD'       'Spread'           '10'     'R'    ' '     ,
  'MIMON'       '청산기준월'       '10'     'C'    ' '     ,
  'PRICE'       '청산집행단가'     '15'     'R'    ' '     ,
  'WAERS'       '통화'             '5'      'C'    ' '     ,
  'EMENG'       '청산집행수량'     '14'     'R'    ' '     ,
  'MEINS'       '단위'             '10'     'C'    ' '     ,
  'NFUTN'       '신규선물집행번호' '12'     'L'    ' '     ,
  'RUDAT1'      '신규집행일'       '10'     'C'    ' '     ,
  'FCM1'        '신규FCM'          '5'      'C'    'ALPHA' ,
  'FCM_NM1'     '신규FCM'          '10'     'L'    ' '     ,
  'ENDAT1'      '신규만기일'       '10'     'C'    ' '     ,
  'MITYP1'      '신규집행유형'     '10'     'C'    ' '     ,
  'MISPD1'      '신규Spread'       '10'     'R'    ' '     ,
  'MIMON1'      '신규기준월'       '10'     'C'    ' '     ,
  'PRICE1'      '신규집행단가'     '15'     'R'    ' '     ,
  'WAERS1'      '통화'             '5'      'C'    ' '     ,
  'PRCTR'       '손익센터'         '10'     'C'    'ALPHA' ,
  'PTEXT'       '손익센터명'       '10'     'C'    ' '     ,
  'EMENG1'      '신규집행수량'     '14'     'R'    ' '     ,
  'MEINS1'      '단위'             '10'     'C'    ' '     ,
  'ERDAT'       '요청일'           '10'     'C'    ' '     ,
  'ERZET'       '요청시간'         '6'      'C'    ' '     ,
  'ERNAM'       '요청자'           '10'     'C'    ' '     ,
  'ENAME'       '요청자명'         '10'     'C'    ' '     .

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
    WHEN 'BY_SL'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'PRICE'.
      GS_FIELDCAT-CFIELDNAME = 'WAERS'.
    WHEN 'EMENG'.
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
  DATA: LT_CELLTAB TYPE LVC_T_STYL,
        L_INDEX    TYPE I.

  LOOP AT GT_OUTTAB_E INTO GS_OUTTAB_E.
    L_INDEX = SY-TABIX.
    REFRESH LT_CELLTAB.
    CLEAR GS_OUTTAB_E-CELLTAB.
    PERFORM FILL_CELLTAB_C CHANGING LT_CELLTAB.
    INSERT LINES OF LT_CELLTAB INTO TABLE GS_OUTTAB_E-CELLTAB.
    MODIFY GT_OUTTAB_E FROM GS_OUTTAB_E INDEX L_INDEX.
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

** FieldName별 소트해서 APPEND
* GS_F4-FIELDNAME = 'NFUTN'.
* GS_F4-REGISTER  = 'X'.
* APPEND GS_F4 TO GT_F4.
*
* CALL METHOD GRF_GRID->REGISTER_F4_FOR_FIELDS
*   EXPORTING
*     IT_F4 = GT_F4.

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
      IT_OUTTAB                     = GT_OUTTAB_E
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

  DATA: LV_CNT TYPE I.

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

* --------------------------------------------------------------------
* 'E' = 청산선물집행승인
* --------------------------------------------------------------------
  CLEAR : GS_NFNUM. REFRESH : GT_NFNUM_E.
  CLEAR : LV_CNT.

  IF GT_PERNR[] IS NOT INITIAL.
    SELECT COUNT(*) INTO LV_CNT
      FROM ZNFT1090 AS Z1
           FOR ALL ENTRIES IN GT_PERNR
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~PERNR EQ GT_PERNR-PERNR
       AND Z1~CONGB EQ '4'
       AND Z1~CONSQ EQ 1
       AND Z1~LVORM NE 'X'.

    IF SY-SUBRC EQ 0 AND LV_CNT GE 1.
      CLEAR GV_H_CNT.
      SELECT COUNT(*) INTO GV_H_CNT
        FROM ZNFT1030
       WHERE BUKRS EQ P_BUKRS
         AND CONFM EQ '2'
         AND OLDFT EQ SPACE
         AND YNCAN NE 'X'
         AND YNFIN NE 'X'
         AND YNNET NE 'X'.

      IF SY-SUBRC NE 0.
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
    ELSE.
      GV_ERROR = 'X'.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH GV_UNAME '에 대한 승인권한이 없습니다.'.
    ENDIF.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH GV_UNAME '에 대한 사번정보가 존재하지 않습니다.'.
    EXIT.
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

  CLEAR GS_OUTTAB_E.
  LOOP AT P_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    LV_INDEX = LS_MOD_CELLS-ROW_ID.
*       Data 가공용 Structure
    READ TABLE GT_OUTTAB_E INTO GS_OUTTAB_E INDEX LV_INDEX.
    IF SY-SUBRC EQ 0.
      CASE LS_MOD_CELLS-FIELDNAME.
        WHEN 'CHECK'.
          IF LS_MOD_CELLS-VALUE EQ 'X'.
            GS_OUTTAB_E-CHECK = 'X'.
            MODIFY GT_OUTTAB_E FROM GS_OUTTAB_E INDEX LV_INDEX
                               TRANSPORTING CHECK.
          ELSE.
            GS_OUTTAB_E-CHECK = SPACE.
            MODIFY GT_OUTTAB_E FROM GS_OUTTAB_E INDEX LV_INDEX
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

  READ TABLE GT_OUTTAB_E INTO GS_OUTTAB_E INDEX P_ES_ROW_NO-ROW_ID.

  IF SY-SUBRC EQ 0.
    CASE P_E_COLUMN.
      WHEN 'CFUTN'.
        PERFORM CALL_CFUTN_PGM USING GS_OUTTAB_E-CFUTN.
      WHEN 'NFUTN'.
        PERFORM CALL_NFUTN_PGM USING GS_OUTTAB_E-NFUTN.
    ENDCASE.
  ENDIF.

ENDFORM.                    " ALV_EVENT_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  DATA_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LIST_REQ_TYPE  text
*----------------------------------------------------------------------*
FORM DATA_SELECT.

  PERFORM GET_REQNO_E.

ENDFORM.                    " DATA_SELECT

*&---------------------------------------------------------------------*
*&      Form  GET_REQNO_E
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_REQNO_E .

  DATA: LV_FLAG TYPE CHAR01.
  DATA: LV_TABIX TYPE SY-TABIX.

  SELECT Z1~CFUTN          " 청산선물 집행번호
         Z1~AEDAT AS AUDAT " 승인요청일
         Z1~NFKEY
         Z1~RUDAT
         Z1~FCM
         Z1~BY_SL
         Z1~ENDAT
         Z1~MITYP
         Z1~MISPD
         Z1~MIMON
         Z1~PRICE
         Z1~WAERS
         Z1~EMENG
         Z1~MEINS
         Z2~NFUTN   " 선물집행번호
         Z2~RUDAT AS RUDAT1
         Z2~FCM   AS FCM1
         Z2~ENDAT AS ENDAT1
         Z2~MITYP AS MITYP1
         Z2~MISPD AS MISPD1
         Z2~MIMON AS MIMON1
         Z2~PRICE AS PRICE1
         Z2~WAERS AS WAERS1
         Z2~EMENG AS EMENG1
         Z2~MEINS AS MEINS1
         Z4~PRCTR
         Z1~ERDAT
         Z1~ERZET
         Z1~ERNAM
         INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB_E
    FROM ZNFT1030 AS Z1
         INNER JOIN ZNFT1020 AS Z2
            ON Z2~NFUTN EQ Z1~NFUTN AND Z2~BUKRS EQ Z1~BUKRS
         INNER JOIN ZNFT1011 AS Z3
            ON Z3~REQNO EQ Z2~REQNO AND Z3~H_NO1 EQ Z2~H_NO1
         INNER JOIN ZNFT1000 AS Z4
            ON Z4~CONNO EQ Z3~CONNO
    WHERE Z1~BUKRS EQ P_BUKRS
      AND Z1~CONFM EQ '2'
      AND Z1~OLDFT EQ SPACE
      AND Z1~YNCAN NE 'X'
      AND Z1~YNFIN NE 'X'
      AND Z1~YNNET NE 'X'.

  IF SY-SUBRC EQ 0 AND GT_OUTTAB_E IS NOT INITIAL.
    SORT GT_OUTTAB_E BY CFUTN NFKEY.
    CLEAR: LV_TABIX, GS_OUTTAB_E.
    LOOP AT GT_OUTTAB_E INTO GS_OUTTAB_E.
      LV_TABIX = SY-TABIX.

      AT NEW CFUTN.
        LV_FLAG = 'X'.
      ENDAT.

      IF LV_FLAG = 'X'.
        CLEAR : LV_FLAG.
      ELSE.
        GS_OUTTAB_E-CHECK = '-'.
      ENDIF.

      PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                     GS_OUTTAB_E-BY_SL
                                     GS_OUTTAB_E-BY_SL_NM.

      PERFORM GET_PRCTR_DESC USING P_BUKRS
                                   GS_OUTTAB_E-PRCTR
                                   GS_OUTTAB_E-PTEXT.

*     FCM
      PERFORM GET_LIFNR_DESC USING GS_OUTTAB_E-FCM
                                   GS_OUTTAB_E-FCM_NM.

*     신규FCM
      PERFORM GET_LIFNR_DESC USING GS_OUTTAB_E-FCM1
                                   GS_OUTTAB_E-FCM_NM1.

*___생성인이름
      PERFORM GET_SAPID_NAME USING GS_OUTTAB_E-ERNAM
                                   GS_OUTTAB_E-ENAME.

      MODIFY GT_OUTTAB_E FROM GS_OUTTAB_E INDEX LV_TABIX.

      CLEAR: LV_TABIX, GS_OUTTAB_E.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " GET_REQNO_E

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
  PERFORM DATA_CHECK USING GV_ERROR.
  CHECK GV_ERROR NE 'X'.

*     진행상황 체크
  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM
    USING '승인'
          '해당 데이터를 승인하시겠습니까?'
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


  PERFORM DATA_ALLOW_E.

ENDFORM.                    " DATA_ALLOW

*&---------------------------------------------------------------------*
*&      Form  DATA_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_CHECK USING PV_ERROR.

  DATA: LS_OUTTAB_E LIKE GS_OUTTAB_E,
        LT_OUTTAB_E LIKE TABLE OF LS_OUTTAB_E.

  LOOP AT GT_OUTTAB_E INTO GS_OUTTAB_E WHERE CHECK EQ 'X'.
    MOVE-CORRESPONDING GS_OUTTAB_E TO LS_OUTTAB_E.
    APPEND LS_OUTTAB_E TO LT_OUTTAB_E.
  ENDLOOP.

  IF LT_OUTTAB_E IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '승인하실 데이터를 선택하십시오.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

* 개인아이디인 경우 인터널테이블에서 읽어오기
  IF GV_PERNR IS INITIAL AND LINES( GT_PERNR ) EQ 1.
    READ TABLE GT_PERNR INDEX 1.
    IF SY-SUBRC EQ 0.
      GV_PERNR = GT_PERNR-PERNR.
    ENDIF.
  ENDIF.

* ==========================================================
*   승인권한 점검
* ==========================================================
  DATA: LV_CNT TYPE I.
  CLEAR LV_CNT.

  IF GT_PERNR[] IS NOT INITIAL.
    SELECT COUNT(*) INTO LV_CNT
      FROM ZNFT1090 AS Z2
           FOR ALL ENTRIES IN GT_PERNR
     WHERE Z2~PERNR EQ GT_PERNR-PERNR
       AND Z2~BUKRS EQ P_BUKRS
       AND Z2~CONGB EQ '4'
       AND Z2~CONSQ EQ 1
       AND Z2~LVORM NE 'X'.

    IF SY-SUBRC NE 0 OR LV_CNT EQ 0.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '승인권한이 없습니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH GV_UNAME '에 대한 사번정보가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

ENDFORM.                    " DATA_CHECK

*&---------------------------------------------------------------------*
*&      Form  DATA_ALLOW_E
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_ALLOW_E .

  DATA: LS_ZNFT1030 TYPE ZNFT1030,
        LT_ZNFT1030 LIKE TABLE OF LS_ZNFT1030.

  CLEAR GS_OUTTAB_E.
  CLEAR LS_ZNFT1030.  REFRESH LT_ZNFT1030.
  CLEAR GS_ZNFT1030.  REFRESH GT_ZNFT1030.

* 개인아이디인 경우 인터널테이블에서 읽어오기
  IF GV_PERNR IS INITIAL AND LINES( GT_PERNR ) EQ 1.
    READ TABLE GT_PERNR INDEX 1.
    IF SY-SUBRC EQ 0.
      GV_PERNR = GT_PERNR-PERNR.
    ENDIF.
  ENDIF.

  LOOP AT GT_OUTTAB_E INTO GS_OUTTAB_E WHERE CHECK EQ 'X'.

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1030
      FROM ZNFT1030
     WHERE CFUTN EQ GS_OUTTAB_E-CFUTN.

    IF SY-SUBRC EQ 0.
*     ### 문서변경이력관리용 ###
      APPEND LS_ZNFT1030 TO GT_ZNFT1030.

      LS_ZNFT1030-CONFM = '3'.
      LS_ZNFT1030-CONAM = SY-UNAME. " 결재자 정보
      LS_ZNFT1030-CODAT = SY-DATLO. " 결재자 정보
      LS_ZNFT1030-COZET = SY-TIMLO. " 결재자 정보
      LS_ZNFT1030-AENAM = SY-UNAME.
      LS_ZNFT1030-AEDAT = SY-DATLO.
      LS_ZNFT1030-AEZET = SY-TIMLO.
      APPEND LS_ZNFT1030 TO LT_ZNFT1030.
    ENDIF.

  ENDLOOP.

  DATA: LV_DBCNT TYPE I.
  CLEAR LV_DBCNT.

  LV_DBCNT = LINES( LT_ZNFT1030 ).

  MODIFY ZNFT1030 FROM TABLE LT_ZNFT1030.

  IF SY-SUBRC EQ 0.
    PERFORM SAVE_CHANGE_DOC_ZNFT1030.
    MESSAGE S003 DISPLAY LIKE 'S'
       WITH LV_DBCNT '건이 승인 완료되었습니다.'.
    COMMIT WORK.
*--- 간편결재 전송.
    PERFORM SEND_SIMPLE_APV.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '승인시 저장오류입니다.'.
    ROLLBACK WORK.
    EXIT.
  ENDIF.

ENDFORM.                    " DATA_ALLOW_E

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
  PERFORM DATA_CHECK USING GV_ERROR.
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

  PERFORM DATA_REJECT_E.

ENDFORM.                    " DATA_REJECT

*&---------------------------------------------------------------------*
*&      Form  DATA_REJECT_E
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_REJECT_E .

  DATA: LS_ZNFT1030 TYPE ZNFT1030,
        LT_ZNFT1030 LIKE TABLE OF LS_ZNFT1030.

  CLEAR GS_OUTTAB_E.
  CLEAR LS_ZNFT1030.  REFRESH LT_ZNFT1030.
  CLEAR GS_ZNFT1030.  REFRESH GT_ZNFT1030.

* 개인아이디인 경우 인터널테이블에서 읽어오기
  IF GV_PERNR IS INITIAL AND LINES( GT_PERNR ) EQ 1.
    READ TABLE GT_PERNR INDEX 1.
    IF SY-SUBRC EQ 0.
      GV_PERNR = GT_PERNR-PERNR.
    ENDIF.
  ENDIF.

  LOOP AT GT_OUTTAB_E INTO GS_OUTTAB_E WHERE CHECK EQ 'X'.

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1030
      FROM ZNFT1030
     WHERE CFUTN EQ GS_OUTTAB_E-CFUTN.

    IF SY-SUBRC EQ 0.
*     ### 문서변경이력관리용 ###
      APPEND LS_ZNFT1030 TO GT_ZNFT1030.

      LS_ZNFT1030-CONFM = '4'.
      LS_ZNFT1030-CONAM = SY-UNAME. " 결재자 정보
      LS_ZNFT1030-CODAT = SY-DATLO. " 결재자 정보
      LS_ZNFT1030-COZET = SY-TIMLO. " 결재자 정보
      LS_ZNFT1030-AENAM = SY-UNAME.
      LS_ZNFT1030-AEDAT = SY-DATLO.
      LS_ZNFT1030-AEZET = SY-TIMLO.
      APPEND LS_ZNFT1030 TO LT_ZNFT1030.
    ENDIF.

  ENDLOOP.

  DATA: LV_DBCNT TYPE I.
  CLEAR LV_DBCNT.

  LV_DBCNT = LINES( LT_ZNFT1030 ).

  MODIFY ZNFT1030 FROM TABLE LT_ZNFT1030.

  IF SY-SUBRC EQ 0.
    PERFORM SAVE_CHANGE_DOC_ZNFT1030.
    MESSAGE S003 DISPLAY LIKE 'S'
       WITH LV_DBCNT '건이 반려되었습니다.'.
    COMMIT WORK.
*--- 간편결재 전송.
    PERFORM SEND_SIMPLE_APV.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '반려시 저장오류입니다.'.
    ROLLBACK WORK.
    EXIT.
  ENDIF.

ENDFORM.                    " DATA_REJECT_E

*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGE_DOC_ZNFT1030
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_CHANGE_DOC_ZNFT1030 .

  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND.

  DATA: LS_ZNFT1030N TYPE ZNFT1030,
        LS_ZNFT1030Y TYPE ZNFT1030.

  LV_CDOC_UPD_OBJECT = 'U'.
  LV_TCODE    = SY-TCODE.

  CLEAR GS_ZNFT1030.
  LOOP AT GT_ZNFT1030 INTO GS_ZNFT1030.

*   변경전 데이터
    MOVE-CORRESPONDING GS_ZNFT1030 TO LS_ZNFT1030Y.

*   변경후 데이터
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1030N
      FROM ZNFT1030
     WHERE NFUTN EQ GS_ZNFT1030-NFUTN.

    LV_OBJECTID = GS_ZNFT1030-CFUTN.

    CALL FUNCTION 'ZNFT1030CHDOC_WRITE_DOCUMENT'
      EXPORTING
        OBJECTID     = LV_OBJECTID
        TCODE        = LV_TCODE
        UTIME        = SY-TIMLO
        UDATE        = SY-DATLO
        USERNAME     = SY-UNAME
        N_ZNFT1030   = LS_ZNFT1030N
        O_ZNFT1030   = LS_ZNFT1030Y
        UPD_ZNFT1030 = LV_CDOC_UPD_OBJECT.

  ENDLOOP.

ENDFORM.                    " SAVE_CHANGE_DOC_ZNFT1030

*&---------------------------------------------------------------------*
*&      Form  DATA_RELOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_RELOAD.

  CLEAR  : GS_NFNUM,   GS_OUTTAB_E.
  REFRESH: GT_NFNUM_E, GT_OUTTAB_E.

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
        IF GS_OUTTAB_E-CHECK = '-'.
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

  LOOP AT GT_OUTTAB_E INTO GS_OUTTAB_E WHERE CHECK NE '-'.
    IF OK_SAVE = 'ASEL'.
      GS_OUTTAB_E-CHECK = 'X'.
    ELSE.
      CLEAR : GS_OUTTAB_E-CHECK.
    ENDIF.
    MODIFY GT_OUTTAB_E FROM GS_OUTTAB_E TRANSPORTING CHECK.
  ENDLOOP.

ENDFORM.                    " SELECT_ALL

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
*& Form SEND_SIMPLE_APV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_SIMPLE_APV .
  CLEAR : GS_ZNFT1030.
  LOOP AT GT_ZNFT1030 INTO GS_ZNFT1030.
    PERFORM SEND_SIMPLE_APPROVAL
    USING GS_ZNFT1030-CFUTN
          GS_ZNFT1030-BUKRS
          '2E'.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_SIMPLE_APPROVAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_ZNFT1030_CFUTN
*&      --> GS_ZNFT1030_BUKRS
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
