
*&---------------------------------------------------------------------*
*&      Form  F4HELP_PRCTR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_PRCTR  USING    PV_PRCTR.

  RANGES: LR_NFCTR  FOR  ZNFT1000-NFCTR.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_PRCTR,
             LR_NFCTR.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_PRCTR,
            LR_NFCTR.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = 'ZNFR2580'
      DYNUMB     = '1000'
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  LOOP AT SCR_FIELDS.
    CASE SCR_FIELDS-FIELDNAME.
      WHEN 'P_BUKRS'.
        P_BUKRS      = SCR_FIELDS-FIELDVALUE.
    ENDCASE.
  ENDLOOP.

  SELECT PRCTR
*         PTEXT
    INTO TABLE GT_PRCTR
    FROM ZNFT0004
   WHERE KOKRS   =  P_BUKRS   "관리회계영역
     AND BDATU  >=  SY-DATLO  "효력만료일
     AND CFACTIV =  'X'.      "선물요청(활성)

  IF SY-SUBRC EQ 0.
    LOOP AT GT_PRCTR.
      PERFORM GET_PRCTR_DESC USING P_BUKRS
                                   GT_PRCTR-PRCTR
                                   GT_PRCTR-PTEXT.

      MODIFY GT_PRCTR.
    ENDLOOP.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '손익센터가 없습니다.'.
    EXIT.
  ENDIF.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZNFT0004'.
  IT_FIELDS-FIELDNAME  = 'PRCTR'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT0004'.
  IT_FIELDS-FIELDNAME  = 'PTEXT'.
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
      FULL_TABLE                   = GT_PRCTR
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_PRCTR INDEX LD_TABIX.
  IF SY-SUBRC = 0.
    PV_PRCTR = GT_PRCTR-PRCTR.
  ENDIF.

ENDFORM.                    " F4HELP_PRCTR

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

  GS_LAYOUT-SEL_MODE   = 'A'.
  GS_LAYOUT-ZEBRA      = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT-CTAB_FNAME = 'COLINFO'.
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

  CLEAR : GS_SORT, GT_SORT.
  REFRESH GT_SORT.

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

  PERFORM SET_FIELDCAT USING:
    'CHECK'    '선택'             '6'    'C'   ' '     ,
    'BUKRS'    '회사코드'         '10'   'C'   ' '     ,
    'SUBTOT'   '소계기준'         '15'   'C'   ' '     ,
    'CODAT'    '확인요청일'       '10'   'C'   ' '     ,
    'NFUTN'    '집행번호'         '15'   'C'   ' '     ,
    'RUDAT'    '선물집행일'       '10'   'C'   ' '     ,
    'FCM'      'FCM'              '10'   'C'   'ALPHA' ,
    'NAME1'    'FCM 명'           '35'   'L'   ' '     ,
    'NFKEY'    '비철구분'         '10'   'C'   ' '     ,
    'BY_SL'    'Buy/Sell'         '1'    'C'   ' '     ,
    'BSTXT'    'Buy/Sell'         '10'   'C'   ' '     ,
    'GUBUN_NM' '구분'             '10'   'C'   ' '     ,
    'ENDAT'    '만기일'           '10'   'C'   ' '     ,
    'EMENG_R'  '집행량'           '10'   'R'   ' '     ,
    'MEINS_R'  '단위'             '10'   'C'   ' '     ,
    'MITYP'    '집행유형'         '10'   'C'   ' '     ,
    'MITYP_NM' '집행유형'         '10'   'C'   ' '     ,
    'MISPD'    'Spread'           '12'   'R'   ' '     ,
    'PRICE_R'  '집행단가'         '15'   'R'   ' '     ,
    'WAERS_R'  '통화'             '5'    'C'   ' '     ,
    'PRCTR'    '손익센터'         '10'   'C'   'ALPHA' ,
    'PRCTR_NM' '손익센터명'       '10'   'L'   ' '     ,
    'ERDAT'    '선물요청일'       '10'   'C'   ' '     ,
    'R_EMENG'  '요청량'           '10'   'R'   ' '     ,
    'R_MEINS'  '단위'             '10'   'C'   ' '     ,
    'RQTYP'    '요청유형'         '10'   'C'   ' '     ,
    'RQTYP_NM' '요청유형'         '10'   'L'   ' '     ,
    'CONNO'    '계약번호'         '10'   'L'   ' '     ,
    'COTXT'    '계약명'           '10'   'L'   ' '     ,
    'KUNNR'    '고  객'           '10'   'C'   'ALPHA' ,
    'NCUST'    '고객명'           '20'   'L'   ' '     ,
    'SUJUD'    '수주일'           '10'   'C'   ' '     ,
    'EMENG_C'  '수주량'           '10'   'R'   ' '     ,
    'MEINS_C'  '단위'             '10'   'C'   ' '     ,
    'PRIND'    '가격구분'         '10'   'C'   ' '     ,
    'SUJUP'    '비철수주가'       '10'   'R'   ' '     ,
    'PRICE_C'  '수주금액'         '15'   'R'   ' '     ,
    'WAERS_C'  '통화'             '5'    'C'   ' '     ,
    'PRATE'    '영업이익률(%)'    '12'   'R'   ' '     ,
    'ERATE'    '환율'             '10'   'R'   ' '     ,
    'CONFM_YN' '확인여부'         '10'   'C'   ' '     .

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
      GS_FIELDCAT-FIX_COLUMN = 'X'.
    WHEN 'BUKRS' OR 'GBSTA' OR 'ABGRU'  OR 'MATNR' OR 'RQTYP'
                 OR 'MITYP' OR 'SUBTOT' OR 'BY_SL'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'PRICE_C'.
      GS_FIELDCAT-CFIELDNAME = 'WAERS_C'.
    WHEN 'PRICE_R' OR 'MISPD'.
      GS_FIELDCAT-CFIELDNAME = 'WAERS_R'.
    WHEN 'EMENG_C'.
      GS_FIELDCAT-QFIELDNAME = 'MEINS_C'.
    WHEN 'R_EMENG'.
      GS_FIELDCAT-QFIELDNAME = 'R_MEINS'.
    WHEN 'EMENG_R'.
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
  DATA: LT_CELLTAB TYPE LVC_T_STYL,
        LT_COLOR   TYPE LVC_T_SCOL,
        LV_INDEX   TYPE I.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB." WHERE SUB_TYP EQ 'X'.
    LV_INDEX = SY-TABIX.

    REFRESH : LT_CELLTAB.  REFRESH GS_OUTTAB-CELLTAB.
    REFRESH : LT_COLOR.    REFRESH GS_OUTTAB-COLINFO.

    PERFORM FILL_CELLTAB_C CHANGING LT_CELLTAB.
*    PERFORM FILL_COLOR CHANGING LT_COLOR.

    INSERT LINES OF LT_CELLTAB INTO TABLE GS_OUTTAB-CELLTAB.
    INSERT LINES OF LT_COLOR   INTO TABLE GS_OUTTAB-COLINFO.

    MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX.
  ENDLOOP.

ENDFORM.                    " SET_CELL_ATTRIBUTE

**&---------------------------------------------------------------------
*
**&      Form  FILL_CELLTAB_C
**&---------------------------------------------------------------------
*
**       text
**----------------------------------------------------------------------
*
*FORM FILL_CELLTAB_C  CHANGING PT_CELLTAB TYPE LVC_T_STYL.
*
*  DATA : LS_CELLTAB TYPE LVC_S_STYL,
*         L_MODE     TYPE RAW4.
*
*  DATA : L_FIELDCAT TYPE LVC_S_FCAT.
*
*  LOOP AT GT_FIELDCAT INTO L_FIELDCAT.
*    LS_CELLTAB-FIELDNAME = L_FIELDCAT-FIELDNAME.
**___필드 활성화 여부
*    IF L_FIELDCAT-EDIT = 'X'.
*      LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
**                       + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
*    ENDIF.
*    INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
*  ENDLOOP.
*
*ENDFORM.                    " FILL_CELLTAB_C
*
**&---------------------------------------------------------------------
*
**&      Form  FILL_COLOR
**&---------------------------------------------------------------------
*
**       text
**----------------------------------------------------------------------
*
**      <--P_LT_COLOR  text
**----------------------------------------------------------------------
*
*FORM FILL_COLOR  CHANGING PT_COLOR TYPE LVC_T_SCOL.
*
*  DATA: LS_CELLTAB TYPE LVC_S_STYL,
*        LS_COLOR   TYPE LVC_S_SCOL,
*        L_MODE     TYPE RAW4.
*
*  DATA: L_FIELDCAT TYPE LVC_S_FCAT.
*
*  LOOP AT GT_FIELDCAT INTO L_FIELDCAT.
*    LS_COLOR-FNAME = L_FIELDCAT-FIELDNAME.
*    LS_COLOR-COLOR-COL = 7.
*    LS_COLOR-COLOR-INT = 0.
*    INSERT LS_COLOR INTO TABLE PT_COLOR.
*  ENDLOOP.
*
*ENDFORM.                    " FILL_COLOR

*&---------------------------------------------------------------------*
*&      Form  SET_EVENT_HANDLER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_EVENT_HANDLER .

* DATA가 변경될 경우
  CALL METHOD GRF_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CREATE OBJECT GRF_EVENT_RECEIVER.
  SET HANDLER :
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
  GS_F4-FIELDNAME = 'CONNO'.
  GS_F4-REGISTER  = 'X'.
  APPEND GS_F4 TO GT_F4.

  CALL METHOD GRF_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = GT_F4.

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
      IT_OUTTAB                     = GT_OUTTAB[]
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
*&      Form  CHECK_SELECTED_CHECKBOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_CHECKBOX  USING    PV_ERROR.

  CLEAR : PV_ERROR.

  IF P_CHK11 IS INITIAL AND P_CHK12 IS INITIAL.
    PV_ERROR = 'X'.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '신규/청산 구분을 선택하시기 바랍니다.'.
    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_CHECKBOX

*&---------------------------------------------------------------------*
*&      Form  DATA_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SELECT .
  DATA: LS_OUTTAB_N LIKE GS_OUTTAB,
        LT_OUTTAB_N LIKE TABLE OF GS_OUTTAB,
        LS_OUTTAB_C LIKE GS_OUTTAB,
        LT_OUTTAB_C LIKE TABLE OF GS_OUTTAB,
*       요일별 소계
        LS_OUTTAB_T LIKE GS_OUTTAB,
        LT_OUTTAB_T LIKE TABLE OF GS_OUTTAB.

  DATA: LV_TABIX TYPE SY-TABIX.

  DATA: WHERE_TAB   TYPE TABLE OF EDPLINE,
        SOURCE_LINE TYPE EDPLINE.

  CLEAR   : GS_OUTTAB.
  REFRESH : GT_OUTTAB.

  IF P_CHK01 EQ 'X' AND P_CHK02 EQ 'X'.
    CLEAR SOURCE_LINE.
    CONCATENATE 'Z1~BUKRS EQ ''' P_BUKRS '''' INTO SOURCE_LINE.
    APPEND SOURCE_LINE TO WHERE_TAB.
  ELSE.
    IF P_CHK01 EQ 'X'.
      CLEAR SOURCE_LINE.
      CONCATENATE 'Z1~BUKRS EQ ''' P_BUKRS '''' INTO SOURCE_LINE.
      APPEND SOURCE_LINE TO WHERE_TAB.

*     확인인 경우
      CLEAR SOURCE_LINE.
      CONCATENATE 'AND Z1~LCNAM NE SPACE' '' INTO SOURCE_LINE.
      APPEND SOURCE_LINE TO WHERE_TAB.

    ELSE.
      CLEAR SOURCE_LINE.
      CONCATENATE 'Z1~BUKRS EQ ''' P_BUKRS '''' INTO SOURCE_LINE.
      APPEND SOURCE_LINE TO WHERE_TAB.

*     미확인 경우
      CLEAR SOURCE_LINE.
      CONCATENATE 'AND Z1~LCNAM EQ SPACE' '' INTO SOURCE_LINE.
      APPEND SOURCE_LINE TO WHERE_TAB.
    ENDIF.
  ENDIF.

  IF P_CHK11 EQ 'X'.

    SELECT Z1~BUKRS
           Z4~PRCTR   " 손익센터
           Z1~ENDAT   " 만기일
           Z1~FCM     " FCM
           Z1~NFKEY   " 비철구분
           Z1~BY_SL   " Buy/Sell
           Z2~RQTYP   " 요청유형
           Z4~CONNO   " 계약번호
           Z4~COTXT   " 계약명
           Z4~KUNNR   " 고객
           Z4~NCUST
           Z4~SUJUD   " 수주일
           Z5~EMENG AS EMENG_C " 수주량
           Z5~MEINS AS MEINS_C " 단위
           Z4~PRICE AS PRICE_C " 수주금액
           Z4~WAERS AS WAERS_C " 통화
           Z4~PRATE   " 영업이익률
           Z4~ERATE   " 환율
           Z3~ERDAT   " 선물요청일
           Z1~NFUTN
           Z1~RUDAT   " 선물집행일
           Z1~EMENG AS EMENG_R " 집행수량
           Z1~MEINS AS MEINS_R " 단위
           Z1~MITYP   " 집행유형
           Z1~MISPD   " Spread
           Z1~PRICE AS PRICE_R " 집행단가
           Z1~WAERS AS WAERS_R " 통화
           Z1~CONAM
           Z1~CODAT
           Z1~COZET
           Z1~LCNAM
           Z1~LCDAT
           Z1~LCZET
           Z3~EMENG AS R_EMENG
           Z3~MEINS AS R_MEINS
           INTO CORRESPONDING FIELDS OF TABLE LT_OUTTAB_N
      FROM ZNFT1020 AS Z1
           INNER JOIN ZNFT1011 AS Z3
              ON Z3~REQNO EQ Z1~REQNO AND Z3~H_NO1 EQ Z1~H_NO1
           INNER JOIN ZNFT1010 AS Z2
              ON Z2~REQNO EQ Z3~REQNO
           INNER JOIN ZNFT1000 AS Z4
              ON Z4~CONNO EQ Z3~CONNO
           INNER JOIN ZNFT1001 AS Z5
              ON Z5~CONNO EQ Z4~CONNO AND Z5~NFKEY EQ Z3~NFKEY
*     WHERE Z1~BUKRS EQ P_BUKRS
     WHERE (WHERE_TAB)
       AND Z1~NFKEY IN S_NFKEY
       AND Z1~RUDAT IN S_RUDAT
       AND Z3~ERDAT IN S_ERDAT
       AND Z4~SUJUD IN S_SUJUD
       AND Z4~PRCTR IN S_PRCTR
       AND Z1~CONFM IN ('3', '7')
       AND Z1~YNCAN EQ SPACE
       AND Z1~YNNET EQ SPACE
       AND Z4~COTYP NE '4'.

    IF LT_OUTTAB_N IS NOT INITIAL.
      SORT LT_OUTTAB_N BY BUKRS PRCTR NFKEY CONNO ERDAT RUDAT.
      APPEND LINES OF LT_OUTTAB_N TO LT_OUTTAB_T.
    ENDIF.

  ENDIF.

  IF P_CHK12 EQ 'X'.

    SELECT Z1~BUKRS
           Z5~PRCTR   " 손익센터
           Z1~ENDAT   " 만기일
           Z1~FCM     " FCM
           Z1~NFKEY   " 비철구분
           Z1~BY_SL   " Buy/Sell
           Z3~RQTYP   " 요청유형
           Z5~CONNO   " 계약번호
           Z5~COTXT   " 계약명
           Z5~KUNNR   " 고객
           Z5~NCUST
           Z5~SUJUD   " 수주일
           Z6~EMENG AS EMENG_C " 수주량
           Z6~MEINS AS MEINS_C " 단위
           Z5~PRICE AS PRICE_C " 수주금액
           Z5~WAERS AS WAERS_C " 통화
           Z5~PRATE   " 영업이익률
           Z5~ERATE   " 환율
           Z4~ERDAT   " 선물요청일
           Z1~CFUTN AS NFUTN
           Z1~RUDAT   " 선물집행일
           Z1~EMENG AS EMENG_R " 집행수량
           Z1~MEINS AS MEINS_R " 단위
           Z1~MITYP   " 집행유형
           Z1~MISPD   " Spread
           Z1~PRICE AS PRICE_R " 집행단가
           Z1~WAERS AS WAERS_R " 통화
           Z1~CONAM
           Z1~CODAT
           Z1~COZET
           Z1~LCNAM
           Z1~LCDAT
           Z1~LCZET
           Z4~EMENG AS R_EMENG
           Z4~MEINS AS R_MEINS
           INTO CORRESPONDING FIELDS OF TABLE LT_OUTTAB_C
      FROM ZNFT1030 AS Z1
           INNER JOIN ZNFT1020 AS Z2
             ON Z2~NFUTN EQ Z1~NFUTN AND Z2~BUKRS EQ Z1~BUKRS
           INNER JOIN ZNFT1011 AS Z4
              ON Z4~REQNO EQ Z2~REQNO AND Z4~H_NO1 EQ Z2~H_NO1
           INNER JOIN ZNFT1010 AS Z3
              ON Z3~REQNO EQ Z4~REQNO
           INNER JOIN ZNFT1000 AS Z5
              ON Z5~CONNO EQ Z4~CONNO
           INNER JOIN ZNFT1001 AS Z6
              ON Z6~CONNO EQ Z4~CONNO AND Z6~NFKEY EQ Z4~NFKEY
*     WHERE Z1~BUKRS EQ P_BUKRS
     WHERE (WHERE_TAB)
       AND Z1~NFKEY IN S_NFKEY
       AND Z1~RUDAT IN S_RUDAT
       AND Z4~ERDAT IN S_ERDAT
       AND Z5~SUJUD IN S_SUJUD
       AND Z5~PRCTR IN S_PRCTR
       AND Z1~CONFM IN ('3', '7')
       AND Z1~YNCAN EQ SPACE
       AND Z1~YNNET EQ SPACE
       AND Z5~COTYP NE '4'.

    IF LT_OUTTAB_C IS NOT INITIAL.
      SORT LT_OUTTAB_C BY BUKRS PRCTR NFKEY CONNO ERDAT RUDAT.
      APPEND LINES OF LT_OUTTAB_C TO LT_OUTTAB_T.
    ENDIF.

  ENDIF.

  IF LT_OUTTAB_T IS NOT INITIAL.
    SORT LT_OUTTAB_T BY RUDAT NFKEY.

    CLEAR : LS_OUTTAB_T.
    LOOP AT LT_OUTTAB_T INTO LS_OUTTAB_T.
      LV_TABIX = SY-TABIX.

      CASE LS_OUTTAB_T-NFUTN+0(1).
        WHEN '3'.
          LS_OUTTAB_T-GUBUN = 'N'.
          LS_OUTTAB_T-GUBUN_NM = '신규'.
        WHEN '4'.
          LS_OUTTAB_T-GUBUN = 'C'.
          LS_OUTTAB_T-GUBUN_NM = '청산'.
      ENDCASE.

*     Subtotal 데이터 생성
      CONCATENATE LS_OUTTAB_T-RUDAT+4(2) '월'
                  LS_OUTTAB_T-RUDAT+6(2) '일 :'
                  LS_OUTTAB_T-NFKEY '계'
                  INTO LS_OUTTAB_T-SUBTOT.

*     손익센터
      PERFORM GET_PRCTR_DESC USING LS_OUTTAB_T-BUKRS
                                   LS_OUTTAB_T-PRCTR
                                   LS_OUTTAB_T-PRCTR_NM.

*     Buy/Sell
      PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                     LS_OUTTAB_T-BY_SL
                                     LS_OUTTAB_T-BSTXT.

*     요청유형
      PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                     LS_OUTTAB_T-RQTYP
                                     LS_OUTTAB_T-RQTYP_NM.

*     집행유형
      PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                     LS_OUTTAB_T-MITYP
                                     LS_OUTTAB_T-MITYP_NM.

*     FCM 명
      PERFORM GET_LIFNR_DESC USING LS_OUTTAB_T-FCM
                                   LS_OUTTAB_T-NAME1.

*     고객명
      IF LS_OUTTAB_T-KUNNR IS NOT INITIAL.
        PERFORM GET_KUNNR_DESC USING LS_OUTTAB_T-KUNNR
                                     LS_OUTTAB_T-NCUST.
      ENDIF.

*     가격구분/비철수주가
      PERFORM PRICE_CLASSIFICATION1 USING LS_OUTTAB_T-CONNO
                                          LS_OUTTAB_T-NFKEY
                                          LS_OUTTAB_T-PRIND
                                          LS_OUTTAB_T-SUJUP
                                          LS_OUTTAB_T-EMENG_C
                                          GV_ERROR.

*     확인여부
      IF LS_OUTTAB_T-LCDAT IS INITIAL.
        LS_OUTTAB_T-CONFM_YN = 'N'.
      ELSE.
        LS_OUTTAB_T-CONFM_YN = 'Y'.
      ENDIF.

      MODIFY LT_OUTTAB_T FROM LS_OUTTAB_T INDEX LV_TABIX.
      CLEAR : LV_TABIX.
    ENDLOOP.

    SORT LT_OUTTAB_T BY SUBTOT.

*   집행일 & 비철구분별 소계생성을 위한 LOOP.
    CLEAR : LS_OUTTAB_T, LS_OUTTAB_T.

*    DATA: LV_SUBTOT  LIKE ZNFT1000-COTXT,
*          LV_EMENG_C LIKE ZNFT1001-EMENG,  " 수주량 SUM
*          LV_MEINS_C LIKE ZNFT1001-MEINS,
*          LV_PRICE_C LIKE ZNFT1000-PRICE,
*          LV_EMENG_S LIKE ZNFT1001-EMENG,
*          LV_PRICE_S LIKE ZNFT1000-PRICE,
*          LV_PRIND   LIKE ZNFT1000-PRICE,
**         ===============================
*          LV_EMENG_R LIKE ZNFT1020-EMENG,  " 집행량 SUM
*          LV_MEINS_R LIKE ZNFT1020-MEINS,
*          LV_PRICE_R LIKE ZNFT1020-PRICE,
*          LV_EMENG_T LIKE ZNFT1020-EMENG,
*          LV_PRICE_T LIKE ZNFT1020-PRICE,
**         ===============================
*          LV_PRICE_TMP LIKE ZNFT1000-PRICE.

    LOOP AT LT_OUTTAB_T INTO LS_OUTTAB_T.
      LV_TABIX = SY-TABIX.

      MOVE-CORRESPONDING LS_OUTTAB_T TO GS_OUTTAB.
      APPEND GS_OUTTAB TO GT_OUTTAB.

*      LV_SUBTOT = LS_OUTTAB_T-SUBTOT.
*
**     수주량 SUM
*      ADD LS_OUTTAB_T-EMENG_C TO LV_EMENG_C.
*      LV_MEINS_C = LS_OUTTAB_T-MEINS_C.
*
**     집행량 SUM
*      ADD LS_OUTTAB_T-EMENG_R TO LV_EMENG_R.
*      LV_MEINS_R = LS_OUTTAB_T-MEINS_R.
*
**     수주단가 가중 Average 계산로직
*      CLEAR LV_PRICE_TMP.
*      IF LS_OUTTAB_T-PRIND NE 'Average Price'.
*        IF LS_OUTTAB_T-PRIND EQ 'Official Price'.  " Official인 경우
*          ADD LS_OUTTAB_T-EMENG_R TO LV_EMENG_S.   " 집행량 * 집행단가
*          LV_PRICE_TMP = LS_OUTTAB_T-EMENG_R * LS_OUTTAB_T-PRICE_R.
*        ELSE.                                      " Fix인 경우
*          ADD LS_OUTTAB_T-EMENG_C TO LV_EMENG_S.   " 수주량 * 수주단가
*          LV_PRICE_TMP = LS_OUTTAB_T-EMENG_C * LS_OUTTAB_T-PRICE_C.
*        ENDIF.
*        ADD LV_PRICE_TMP TO LV_PRICE_S.
*      ENDIF.
*
**     집행단가 가중 Average 계산로직
*      CLEAR LV_PRICE_TMP.
*      IF LS_OUTTAB_T-MITYP EQ 'S'.               " Spot인 경우의
*        ADD LS_OUTTAB_T-EMENG_R TO LV_EMENG_T.   " 집행량 * 집행단가
*        LV_PRICE_TMP = LS_OUTTAB_T-EMENG_R * LS_OUTTAB_T-PRICE_R.
*        ADD LV_PRICE_TMP TO LV_PRICE_T.
*      ENDIF.
*
*      AT END OF SUBTOT.
*        CLEAR LS_OUTTAB_T.
*        LS_OUTTAB_T-SUB_TYP = 'X'.
*        LS_OUTTAB_T-SUBTOT  = LV_SUBTOT.
*        LS_OUTTAB_T-COTXT   = LV_SUBTOT.
*
**       수주단가 가중 Average
*        LS_OUTTAB_T-EMENG_C = LV_EMENG_C.
*        LS_OUTTAB_T-MEINS_C = LV_MEINS_C.
*        IF LV_EMENG_S NE 0.
*          LV_PRIND = LV_PRICE_S / LV_EMENG_S.
*
*          WRITE : LV_PRIND TO LS_OUTTAB_T-SUJUP
*                  CURRENCY GS_OUTTAB-WAERS_C LEFT-JUSTIFIED.
*        ELSE.
*          LS_OUTTAB_T-SUJUP = 0.
*        ENDIF.
*
**       집행단가 가중 Average
*        LS_OUTTAB_T-EMENG_R = LV_EMENG_R.
*        LS_OUTTAB_T-MEINS_R = LV_MEINS_R.
*        IF LV_EMENG_T NE 0.
*          LS_OUTTAB_T-PRICE_R = LV_PRICE_T / LV_EMENG_T.
*        ELSE.
*          LS_OUTTAB_T-PRICE_R = 0.
*        ENDIF.
*
*        APPEND LS_OUTTAB_T TO GT_OUTTAB.
*
*        CLEAR: LV_EMENG_C, LV_MEINS_R.
*        CLEAR: LV_PRICE_S, LV_EMENG_S.
*        CLEAR: LV_PRICE_T, LV_EMENG_T.
*        CLEAR: LV_PRIND.
*      ENDAT.
    ENDLOOP.

    GV_CNT = LINES( LT_OUTTAB_T ).

  ENDIF.

ENDFORM.                    " DATA_SELECT

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

  READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX P_ES_ROW_NO-ROW_ID.

  IF SY-SUBRC EQ 0.
    CASE P_E_COLUMN.
      WHEN 'CONNO'.
        IF NOT GS_OUTTAB-CONNO IS INITIAL.
          SET PARAMETER ID 'ZNFCON' FIELD GS_OUTTAB-CONNO.
          CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE '계약번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN 'NFUTN'.
        IF NOT GS_OUTTAB-NFUTN IS INITIAL.
          PERFORM DISPLAY_FUTRUES_HISTORY USING GS_OUTTAB-NFUTN.
        ELSE.
          MESSAGE '선물집행번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
    ENDCASE.
  ENDIF.

ENDFORM.                    " ALV_EVENT_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_FUTRUES_HISTORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_FUTRUES_HISTORY USING PV_NFUTN.
  DATA: LT_RSPAR LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

  CLEAR   : LT_RSPAR.
  REFRESH : LT_RSPAR.

  APPEND_PARAM : LT_RSPAR 'P_BUKRS' 'P' ' ' ' '  P_BUKRS       ' '.

  IF GS_OUTTAB-GUBUN = 'N'.
    APPEND_PARAM : LT_RSPAR 'S_NFUTN' 'S' 'I' 'EQ' GS_OUTTAB-NFUTN ' ',
                   LT_RSPAR 'P_CHK11' 'P' ' ' ' '  'X'             ' ',
                   LT_RSPAR 'P_CHK12' 'P' ' ' ' '  ' '             ' '.
  ELSE.
    APPEND_PARAM : LT_RSPAR 'S_CFUTN' 'S' 'I' 'EQ' GS_OUTTAB-NFUTN ' ',
                   LT_RSPAR 'P_CHK11' 'P' ' ' ' '  ' '             ' ',
                   LT_RSPAR 'P_CHK12' 'P' ' ' ' '  'X'             ' '.
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
*&      Form  DATA_OKAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_OKAY .

  CALL METHOD GRF_GRID->CHECK_CHANGED_DATA.

  DATA: LS_ZNFT1020 TYPE ZNFT1020,
        LS_ZNFT1030 TYPE ZNFT1030,
        LT_ZNFT1020 TYPE TABLE OF ZNFT1020,
        LT_ZNFT1030 TYPE TABLE OF ZNFT1030,
        LT_ZNFT1020Y TYPE TABLE OF ZNFT1020,
        LT_ZNFT1030Y TYPE TABLE OF ZNFT1030.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE GUBUN EQ 'N'
                                     AND CHECK EQ 'X'.
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1020
      FROM ZNFT1020
     WHERE NFUTN EQ GS_OUTTAB-NFUTN.
    IF SY-SUBRC EQ 0.

      APPEND LS_ZNFT1020 TO LT_ZNFT1020Y.

      LS_ZNFT1020-LCNAM = SY-UNAME.
      LS_ZNFT1020-LCDAT = SY-DATLO.
      LS_ZNFT1020-LCZET = SY-TIMLO.
      LS_ZNFT1020-AENAM = SY-UNAME.
      LS_ZNFT1020-AEDAT = SY-DATLO.
      LS_ZNFT1020-AEZET = SY-TIMLO.
      APPEND LS_ZNFT1020 TO LT_ZNFT1020.
    ENDIF.
  ENDLOOP.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE GUBUN EQ 'C'
                                     AND CHECK EQ 'X'.

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1030
      FROM ZNFT1030
     WHERE CFUTN EQ GS_OUTTAB-NFUTN.
    IF SY-SUBRC EQ 0.

      APPEND LS_ZNFT1030 TO LT_ZNFT1030Y.

      LS_ZNFT1030-LCNAM = SY-UNAME.
      LS_ZNFT1030-LCDAT = SY-DATLO.
      LS_ZNFT1030-LCZET = SY-TIMLO.
      LS_ZNFT1030-AENAM = SY-UNAME.
      LS_ZNFT1030-AEDAT = SY-DATLO.
      LS_ZNFT1030-AEZET = SY-TIMLO.
      APPEND LS_ZNFT1030 TO LT_ZNFT1030.
    ENDIF.
  ENDLOOP.

  DATA: LV_FLAG TYPE CHAR01.
  CLEAR LV_FLAG.

  IF LT_ZNFT1020 IS NOT INITIAL AND LV_FLAG NE 'E'.
    MODIFY ZNFT1020 FROM TABLE LT_ZNFT1020.
    IF SY-SUBRC EQ 0.
      PERFORM SAVE_ZNFT1020_CHANGE_DOC TABLES LT_ZNFT1020
                                              LT_ZNFT1020Y
                                       USING 'U'.
      LV_FLAG = 'S'.
    ELSE.
      LV_FLAG = 'E'.
    ENDIF.
  ENDIF.

  IF LT_ZNFT1030 IS NOT INITIAL AND LV_FLAG NE 'E'.
    MODIFY ZNFT1030 FROM TABLE LT_ZNFT1030.
    IF SY-SUBRC EQ 0.
      PERFORM SAVE_ZNFT1030_CHANGE_DOC TABLES LT_ZNFT1030
                                              LT_ZNFT1030Y
                                       USING 'U'.
      LV_FLAG = 'S'.
    ELSE.
      LV_FLAG = 'E'.
    ENDIF.
  ENDIF.

  IF LV_FLAG EQ 'S'.
    COMMIT WORK.
    MESSAGE S003 DISPLAY LIKE 'S'
         WITH '데이터 저장에 성공하였습니다.'.
  ELSE.
    ROLLBACK WORK.
    MESSAGE S003 DISPLAY LIKE 'E'
         WITH '데이터 저장에 실패하였습니다.'.
  ENDIF.

ENDFORM.                    " DATA_OKAY
*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_ALL .
  DATA : LT_FILTER  TYPE LVC_T_FILT,
         LS_FILTER  TYPE LVC_S_FILT.

  DATA : BEGIN OF LT_OPT OCCURS 0,
           SIGN(1),
           OPTION(2),
           LOW(50),
           HIGH(50),
         END   OF LT_OPT.

  FIELD-SYMBOLS : <FLD> TYPE ANY.

  DATA : LT_ITAB LIKE GS_OUTTAB OCCURS 0 WITH HEADER LINE,
         LV_FNAME(40).

*___ALV Filter에 따라 선택된 데이터만 전체선택한다.
  CLEAR   : LS_FILTER.
  REFRESH : LT_FILTER.

  LT_ITAB[] = GT_OUTTAB[].

  CALL METHOD GRF_GRID->GET_FILTER_CRITERIA
         IMPORTING
           ET_FILTER = LT_FILTER.

  IF NOT LT_FILTER[] IS INITIAL.
    SORT LT_FILTER BY FIELDNAME.

    LOOP AT LT_FILTER INTO LS_FILTER.
      AT NEW FIELDNAME.
        CLEAR   : LT_OPT, LV_FNAME.
        REFRESH : LT_OPT.

        CONCATENATE 'LT_ITAB-' LS_FILTER-FIELDNAME
               INTO LV_FNAME.
        ASSIGN (LV_FNAME) TO <FLD>.
      ENDAT.

      LT_OPT-SIGN   = LS_FILTER-SIGN.
      LT_OPT-OPTION = LS_FILTER-OPTION.
      LT_OPT-LOW    = LS_FILTER-LOW.
      LT_OPT-HIGH   = LS_FILTER-HIGH.
      APPEND LT_OPT.

      AT END OF FIELDNAME.
        LOOP AT LT_ITAB.
          IF <FLD> NOT IN LT_OPT.
            DELETE LT_ITAB.
          ENDIF.
        ENDLOOP.
      ENDAT.
    ENDLOOP.
  ENDIF.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE CONFM_YN = 'N'.
    READ TABLE LT_ITAB WITH KEY NFUTN = GS_OUTTAB-NFUTN.

    IF SY-SUBRC = 0.
      IF GV_CODE = 'ASEL'.
        GS_OUTTAB-CHECK = 'X'.
      ELSE.
        CLEAR : GS_OUTTAB-CHECK.
      ENDIF.

      MODIFY GT_OUTTAB FROM GS_OUTTAB.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " SELECT_ALL

*&---------------------------------------------------------------------*
*&      Form  DATA_CHECK_SELECTED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_CHECK_SELECTED USING PV_ERROR.

  CLEAR PV_ERROR.

  READ TABLE GT_OUTTAB INTO GS_OUTTAB WITH KEY CHECK = 'X'.
  IF SY-SUBRC NE 0.
    MESSAGE S003 DISPLAY LIKE 'E'
         WITH '데이터를 선택하십시오.'.
    PV_ERROR = 'X'.
  ENDIF.

ENDFORM.                    " DATA_CHECK_SELECTED

*&---------------------------------------------------------------------*
*&      Form  DATA_RELOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_RELOAD .

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
*&      Form  SAVE_ZNFT1020_CHANGE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1725   text
*      -->P_LT_ZNFT1020  text
*      -->P_LT_ZNFT1020Y  text
*----------------------------------------------------------------------*
FORM SAVE_ZNFT1020_CHANGE_DOC  TABLES   PT_ZNFT1020_NEW
                                        PT_ZNFT1020_OLD
                               USING    PV_FLAG.

  DATA: LV_OBJECTID             TYPE CDHDR-OBJECTID,
        LV_TCODE                TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT      TYPE CDHDR-CHANGE_IND,
        LV_UPD_ICDTXT           TYPE CHAR1.

  DATA: LV_CNT TYPE I,
        LV_INDEX TYPE SY-INDEX.

  DATA: O_ZNFT1020S TYPE ZNFT1020,
        N_ZNFT1020S TYPE ZNFT1020.

  LV_CNT = LINES( PT_ZNFT1020_NEW ).

  DO LV_CNT TIMES.

    LV_INDEX = SY-INDEX.

    READ TABLE PT_ZNFT1020_NEW INTO N_ZNFT1020S INDEX  LV_INDEX.

    READ TABLE PT_ZNFT1020_OLD INTO O_ZNFT1020S INDEX  LV_INDEX.

    LV_CDOC_UPD_OBJECT = PV_FLAG.
    LV_OBJECTID        = N_ZNFT1020S-NFUTN.
    LV_TCODE           = SY-TCODE.

    CALL FUNCTION 'ZNFT1020CHDOC_WRITE_DOCUMENT'
      EXPORTING
        OBJECTID     = LV_OBJECTID
        TCODE        = LV_TCODE
        UTIME        = SY-TIMLO
        UDATE        = SY-DATLO
        USERNAME     = SY-UNAME
        N_ZNFT1020   = N_ZNFT1020S
        O_ZNFT1020   = O_ZNFT1020S
        UPD_ZNFT1020 = LV_CDOC_UPD_OBJECT.

    CLEAR : N_ZNFT1020S, O_ZNFT1020S,
            LV_INDEX.
  ENDDO.


ENDFORM.                    " SAVE_ZNFT1020_CHANGE_DOC
*&---------------------------------------------------------------------*
*&      Form  SAVE_ZNFT1030_CHANGE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1763   text
*      -->P_LT_ZNFT1020  text
*      -->P_LT_ZNFT1020Y  text
*----------------------------------------------------------------------*
FORM SAVE_ZNFT1030_CHANGE_DOC  TABLES   PT_ZNFT1030_NEW
                                        PT_ZNFT1030_OLD
                               USING    PV_FLAG.

  DATA: LV_OBJECTID             TYPE CDHDR-OBJECTID,
        LV_TCODE                TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT      TYPE CDHDR-CHANGE_IND,
        LV_UPD_ICDTXT           TYPE CHAR1.

  DATA: LV_CNT TYPE I,
        LV_INDEX TYPE SY-INDEX.

  DATA: O_ZNFT1030S TYPE ZNFT1030,
        N_ZNFT1030S TYPE ZNFT1030.

  LV_CNT = LINES( PT_ZNFT1030_NEW ).

  DO LV_CNT TIMES.

    LV_INDEX = SY-INDEX.

    READ TABLE PT_ZNFT1030_NEW INTO N_ZNFT1030S INDEX  LV_INDEX.

    READ TABLE PT_ZNFT1030_OLD INTO O_ZNFT1030S INDEX  LV_INDEX.

    LV_CDOC_UPD_OBJECT = PV_FLAG.
    LV_OBJECTID        = N_ZNFT1030S-NFUTN.
    LV_TCODE           = SY-TCODE.

    CALL FUNCTION 'ZNFT1030CHDOC_WRITE_DOCUMENT'
      EXPORTING
        OBJECTID     = LV_OBJECTID
        TCODE        = LV_TCODE
        UTIME        = SY-TIMLO
        UDATE        = SY-DATLO
        USERNAME     = SY-UNAME
        N_ZNFT1030   = N_ZNFT1030S
        O_ZNFT1030   = O_ZNFT1030S
        UPD_ZNFT1030 = LV_CDOC_UPD_OBJECT.

    CLEAR : N_ZNFT1030S, O_ZNFT1030S,
            LV_INDEX.

  ENDDO.

ENDFORM.                    " SAVE_ZNFT1030_CHANGE_DOC
*&---------------------------------------------------------------------*
*&      Form  FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_CELLTAB_C   CHANGING PT_CELLTAB TYPE LVC_T_STYL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         L_MODE     TYPE RAW4.

  DATA : L_FIELDCAT TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT INTO L_FIELDCAT.
    LS_CELLTAB-FIELDNAME = L_FIELDCAT-FIELDNAME.

*___필드 활성화 여부
    IF L_FIELDCAT-EDIT = 'X'.
      IF GS_OUTTAB-CONFM_YN = 'N'.
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

ENDFORM.                    " FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_COLS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SELECTED_COLS .

  CALL METHOD GRF_GRID->GET_SELECTED_COLUMNS
    IMPORTING
      ET_INDEX_COLUMNS = GT_COLS.

ENDFORM.                    " GET_SELECTED_COLS
*&---------------------------------------------------------------------*
*&      Form  SET_SELECTED_COLS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SELECTED_COLS .

  IF GT_COLS[] IS NOT INITIAL.
    CALL METHOD GRF_GRID->SET_SELECTED_COLUMNS
      EXPORTING
        IT_COL_TABLE = GT_COLS.
  ENDIF.

ENDFORM.                    " SET_SELECTED_COLS
