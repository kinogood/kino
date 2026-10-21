*&---------------------------------------------------------------------*
*&  Include           ZNFR2650F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F4HELP_FCM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_FCM  USING    PV_FCM.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX, GV_INDEX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_FCM.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_FCM.

* 화면상의 회사코드를 읽는다.
  IF SY-DYNNR = '1000'.
    SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
    APPEND SCR_FIELDS.

    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        DYNAME     = 'ZNFR2650'
        DYNUMB     = '1000'
      TABLES
        DYNPFIELDS = SCR_FIELDS.

    READ TABLE SCR_FIELDS WITH KEY FIELDNAME = 'P_BUKRS'.
    P_BUKRS = SCR_FIELDS-FIELDVALUE.
  ENDIF.

  IF P_BUKRS IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '회사코드를 입력하시기 바랍니다.'.
    EXIT.
  ENDIF.

  SELECT A~LIFNR
         B~NAME1
    INTO TABLE GT_FCM
    FROM ZNFT0021 AS A
   INNER JOIN LFA1 AS B
      ON A~LIFNR = B~LIFNR
   WHERE A~BUKRS = P_BUKRS
     AND B~LOEVM = ' '.

  IF SY-SUBRC <> 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH 'FCM 정보가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

* 아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZNFT0021'.
  IT_FIELDS-FIELDNAME  = 'LIFNR'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'LFA1'.
  IT_FIELDS-FIELDNAME  = 'NAME1'.
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
      FULL_TABLE                   = GT_FCM
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_FCM INDEX LD_TABIX.
  IF SY-SUBRC = 0.
    PV_FCM = GT_FCM-LIFNR.
  ENDIF.

ENDFORM.                    " F4HELP_FCM

*&---------------------------------------------------------------------*
*&      Form  F4HELP_NFCTR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_NFCTR  USING    PV_NFCTR.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_NFCTR.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_NFCTR.

*___화면상의 회사코드를 읽는다.
  SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = 'ZNFR2650'
      DYNUMB     = '1000'
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  READ TABLE SCR_FIELDS WITH KEY FIELDNAME = 'P_BUKRS'.
  P_BUKRS = SCR_FIELDS-FIELDVALUE.

  IF P_BUKRS IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '회사코드를 입력하시기 바랍니다.'.
    EXIT.
  ENDIF.

  SELECT NFCTR
         NTEXT
    INTO TABLE GT_NFCTR
    FROM ZNFT0005
   WHERE BUKRS = P_BUKRS.   "회사코드

  IF SY-SUBRC <> 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '회사코드' P_BUKRS
            '에 해당하는 사업부가 없습니다.'.
    EXIT.
  ENDIF.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZNFT0005'.
  IT_FIELDS-FIELDNAME  = 'NFCTR'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT0005'.
  IT_FIELDS-FIELDNAME  = 'NTEXT'.
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
      FULL_TABLE                   = GT_NFCTR
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_NFCTR INDEX LD_TABIX.
  IF SY-SUBRC = 0.
    PV_NFCTR = GT_NFCTR-NFCTR.
  ENDIF.

ENDFORM.                    " F4HELP_NFCTR
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

  LR_NFCTR[] = S_NFCTR[].

*___화면상의 데이터를 읽는다.
  SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'S_NFCTR-LOW'.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'S_NFCTR-HIGH'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = 'ZNFR2650'
      DYNUMB     = '1000'
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  LOOP AT SCR_FIELDS.
    CASE SCR_FIELDS-FIELDNAME.
      WHEN 'P_BUKRS'.
        P_BUKRS      = SCR_FIELDS-FIELDVALUE.
      WHEN 'S_NFCTR-LOW'.
        LR_NFCTR-LOW  = SCR_FIELDS-FIELDVALUE.
        PERFORM CONVERSION_EXIT_ALPHA USING 'I' LR_NFCTR-LOW.
      WHEN 'S_NFCTR-HIGH'.
        LR_NFCTR-HIGH = SCR_FIELDS-FIELDVALUE.
        PERFORM CONVERSION_EXIT_ALPHA USING 'I' LR_NFCTR-HIGH.
    ENDCASE.
  ENDLOOP.

  READ TABLE LR_NFCTR INDEX 1 TRANSPORTING SIGN.
  IF SY-SUBRC = 0.
    IF LR_NFCTR-LOW  IS NOT INITIAL OR
       LR_NFCTR-HIGH IS NOT INITIAL.
      IF LR_NFCTR-HIGH IS NOT INITIAL.
        LR_NFCTR-OPTION = 'BT'.
      ELSE.
        LR_NFCTR-OPTION = 'EQ'.
      ENDIF.

      MODIFY LR_NFCTR INDEX 1.
    ELSE.
      DELETE LR_NFCTR INDEX 1.
    ENDIF.
  ELSE.
    IF LR_NFCTR-LOW  IS NOT INITIAL OR
       LR_NFCTR-HIGH IS NOT INITIAL.
      IF LR_NFCTR-HIGH IS NOT INITIAL.
        LR_NFCTR-SIGN   = 'I'.
        LR_NFCTR-OPTION = 'BT'.
        APPEND LR_NFCTR.
      ELSE.
        LR_NFCTR-SIGN   = 'I'.
        LR_NFCTR-OPTION = 'EQ'.
        APPEND LR_NFCTR.
      ENDIF.
    ENDIF.
  ENDIF.

  SELECT PRCTR
*         PTEXT
    INTO TABLE GT_PRCTR
    FROM ZNFT0004
   WHERE KOKRS   =  P_BUKRS   "관리회계영역
     AND NFCTR   IN LR_NFCTR  "사업부
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
*&      Form  CHECK_SELECTED_CHECKBOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_CHECKBOX  USING    PV_ERROR.

  CLEAR : PV_ERROR.

* 일반조회대상인 경우 신규&청산 집행 체크로직
  IF P_R01 EQ 'X'.
    IF P_CHK01 IS INITIAL AND P_CHK02 IS INITIAL.
      PV_ERROR = 'X'.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '신규/청산 구분을 선택하시기 바랍니다.'.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_CHECKBOX

*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_RADIOBTN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_RADIOBTN.

  CLEAR   : R_RQTYP.
  REFRESH : R_RQTYP.

  IF P_R01 = 'X'.
    CLEAR : P_VRSIO, P_SVDAT, P_SRNAM.
  ENDIF.

* 내부선물 제외
  IF P_R11 EQ 'X'.
*    CLEAR : P_VRSIO, P_SVDAT, P_SRNAM.
  ELSE.
    R_RQTYP-LOW    = '4'.
    R_RQTYP-HIGH   = SPACE.
    R_RQTYP-SIGN   = 'E'.
    R_RQTYP-OPTION = 'EQ'.
    APPEND R_RQTYP.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_RADIOBTN

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

*  GS_SORT-SPOS = 1.
*  GS_SORT-FIELDNAME = 'GUBUN'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.

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

  IF P_R01 EQ 'X'.
    PERFORM SET_FIELDCAT USING:
      'CHECK'    '선택'             '4'    'C'   ' '     ,
      'ICON'     '상태'             '10'   'C'   ' '     ,
      'O_CASH'   '현재시세'         '10'   'R'   ' '     ,
      'NE_CO'    '신규/청산'        '10'   'C'   ' '     ,
      'NC_NM'    '신규/청산'        '10'   'C'   ' '     ,
      'BUKRS'    '회사코드'         '10'   'C'   ' '     ,
      'NFUTN'    '선물집행번호'     '10'   'L'   ' '     ,
      'SHFCNT'   '만기이동차수'     '5'    'C'   ' '  ,"기능개선 107383
      'FCM'      'FCM'              '5'    'C'   'ALPHA' ,
      'FCM_NM'   'FCM명'            '20'   'L'   ' '     ,
      'RUDAT'    '집행일'           '10'   'C'   ' '     ,
      'NFKEY'    '비철구분'         '10'   'C'   ' '     ,
      'BY_SL'    'Buy-Sell'         '10'   'C'   ' '     ,
      'BY_SL_NM' 'Buy-Sell'         '10'   'C'   ' '     ,
      'ENDAT'    '만기일'           '10'   'C'   ' '     ,
      'MITYP'    '집행유형'         '10'   'C'   ' '     ,
      'MITYP_NM' '집행유형'         '10'   'C'   ' '     ,
      'MISPD'    'Spread'           '10'   'R'   ' '     ,
      'MIMON'    '기준월'           '8'    'C'   ' '     ,
      'PRICE'    '집행단가'         '10'   'R'   ' '     ,
      'WAERS'    '통화'             '5'    'C'   ' '     ,
      'EMENG'    '집행수량'         '10'   'R'   ' '     ,
      'MEINS'    '단위'             '10'   'C'   ' '     ,
      'N_AMT'    '집행금액'         '10'   'R'   ' '     ,
      'CONFM'    '결재상태'         '10'   'C'   ' '     ,
      'CONFM_NM' '결재상태'         '10'   'C'   ' '     ,
      'NFCTR'    '사업부'           '10'   'C'   'ALPHA' ,
      'NFCTR_NM' '사업부명'         '10'   'L'   ' '     ,
      'PRCTR'    '손익센터'         '10'   'C'   'ALPHA' ,
      'PRCTR_NM' '손익센터명'       '10'   'L'   ' '     ,
      'VKGRP'    '영업그룹'         '10'   'C'   'ALPHA' ,
      'VKGRP_NM' '영업그룹명'       '20'   'C'   ' '     ,
      'RQTYP'    '요청유형'         '10'   'C'   ' '     ,
      'RQTYP_NM' '요청유형'         '10'   'C'   ' '     ,
      'REQNO'    '선물요청번호'     '10'   'L'   ' '     ,
      'ERDAT'    '선물요청일'       '10'   'C'   ' '     ,
      'CONNO'    '계약번호'         '10'   'L'   ' '     ,
      'COTXT'    '계약명'           '10'   'L'   ' '     ,
      'CSTAT'    '계약상태'         '10'   'C'   ' '     ,
      'CSTAT_NM' '계약상태'         '10'   'C'   ' '     ,
*-{기능개선 103161 - 고객 필드 추가
      'KUNNR'    '고객'             '10'   'C'   'ALPHA ',
      'NCUST'    '고객명'           '20'   'C'   ' '     .
*-}기능개선 103161
  ELSE.
    PERFORM SET_FIELDCAT USING:
      'BUKRS'    '회사코드'         '10'   'C'   ' '     ,
      'ICON'     '상태'             '10'   'C'   ' '     ,
      'O_CASH'   '현재시세'         '10'   'R'   ' '     ,
      'ERDAT'    '저장일'           '10'   'R'   ' '     ,
      'VRSIO'    '저장버전'         '10'   'R'   ' '     ,
      'ERNAM'    '저장실행자'       '10'   'R'   ' '     ,
      'NE_CO'    '신규/청산'        '10'   'C'   ' '     ,
      'NC_NM'    '신규/청산'        '10'   'C'   ' '     ,
      'OPNFN'    '선물집행번호'     '10'   'L'   ' '     ,
      'FCM'      'FCM'              '5'    'C'   'ALPHA' ,
      'FCM_NM'   'FCM명'            '20'   'L'   ' '     ,
      'RUDAT'    '집행일'           '10'   'C'   ' '     ,
      'NFKEY'    '비철구분'         '10'   'C'   ' '     ,
      'BY_SL'    'Buy-Sell'         '10'   'C'   ' '     ,
      'BY_SL_NM' 'Buy-Sell'         '10'   'C'   ' '     ,
      'ENDAT'    '만기일'           '10'   'C'   ' '     ,
      'MITYP'    '집행유형'         '10'   'C'   ' '     ,
      'MITYP_NM' '집행유형'         '10'   'C'   ' '     ,
      'MISPD'    'Spread'           '10'   'R'   ' '     ,
      'MIMON'    '기준월'           '8'    'C'   ' '     ,
      'PRICE'    '집행단가'         '10'   'R'   ' '     ,
      'WAERS'    '통화'             '5'    'C'   ' '     ,
      'EMENG'    '집행수량'         '10'   'R'   ' '     ,
      'MEINS'    '단위'             '10'   'C'   ' '     ,
      'N_AMT'    '집행금액'         '10'   'R'   ' '     ,
      'CONFM'    '결재상태'         '10'   'C'   ' '     ,
      'CONFM_NM' '결재상태'         '10'   'C'   ' '     ,
      'NFCTR'    '사업부'           '10'   'C'   'ALPHA' ,
      'NFCTR_NM' '사업부명'         '10'   'L'   ' '     ,
      'PRCTR'    '손익센터'         '10'   'C'   'ALPHA' ,
      'PRCTR_NM' '손익센터명'       '10'   'L'   ' '     ,
      'RQTYP'    '요청유형'         '10'   'C'   ' '     ,
      'RQTYP_NM' '요청유형'         '10'   'C'   ' '     ,
      'REQNO'    '선물요청번호'     '10'   'L'   ' '     ,
      'RQDAT'    '선물요청일'       '10'   'C'   ' '     ,
      'CONNO'    '계약번호'         '10'   'L'   ' '     ,
      'COTXT'    '계약명'           '10'   'L'   ' '     ,
      'CSTAT'    '계약상태'         '10'   'C'   ' '     ,
      'CSTAT_NM' '계약상태'         '10'   'C'   ' '     .
  ENDIF.

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
      GS_FIELDCAT-EDIT       = 'X'.
      GS_FIELDCAT-CHECKBOX   = 'X'.
      IF GV_TCODE EQ 'ZNF2R2650A'.
        GS_FIELDCAT-NO_OUT   = 'X'.
      ENDIF.
    WHEN 'BUKRS' OR 'MITYP' OR 'RQTYP' OR 'CSTAT' OR 'NE_CO' OR 'BY_SL'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'PRICE' OR 'MISPD' OR 'N_AMT'.
      GS_FIELDCAT-CFIELDNAME = 'WAERS'.
    WHEN 'EMENG'.
      GS_FIELDCAT-QFIELDNAME = 'MEINS'.
    WHEN 'ICON'.
      GS_FIELDCAT-ICON       = 'X'.
*-{기능개선 107383 - 청산선물집행만 선택 시 조회안되게
    WHEN 'SHFCNT'.
      IF P_CHK01 IS INITIAL AND P_CHK02 IS NOT INITIAL.
        GS_FIELDCAT-NO_OUT   = 'X'.
      ENDIF.
*-}기능개선 107383.
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

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    L_INDEX = SY-TABIX.
    REFRESH LT_CELLTAB.
    CLEAR GS_OUTTAB-CELLTAB.
    INSERT LINES OF LT_CELLTAB INTO TABLE GS_OUTTAB-CELLTAB.
    MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX L_INDEX.
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

* DATA가 변경될 경우
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

  CLEAR : GS_F4.  REFRESH : GT_F4.

** FieldName별 소트해서 APPEND
*  GS_F4-FIELDNAME = 'CONNO'.
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

  GS_VARIANT-REPORT = SY-REPID.

  IF P_R01 EQ 'X'.
    GS_VARIANT-HANDLE = '0001'.

    CALL METHOD GRF_GRID->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT                    = GS_VARIANT
        IS_LAYOUT                     = GS_LAYOUT
        I_SAVE                        = 'A'
        I_DEFAULT                     = 'X'
        IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE
      CHANGING
        IT_FIELDCATALOG               = GT_FIELDCAT
        IT_SORT                       = GT_SORT
        IT_OUTTAB                     = GT_OUTTAB
        IT_FILTER                     = GT_FILTER
      EXCEPTIONS
        INVALID_PARAMETER_COMBINATION = 1
        PROGRAM_ERROR                 = 2
        TOO_MANY_LINES                = 3
        OTHERS                        = 4.

    CALL METHOD GRF_GRID->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  ELSE.
    GS_VARIANT-HANDLE = '0002'.

    CALL METHOD GRF_GRID->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT                    = GS_VARIANT
        IS_LAYOUT                     = GS_LAYOUT
        I_SAVE                        = 'A'
        I_DEFAULT                     = 'X'
        IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE
      CHANGING
        IT_FIELDCATALOG               = GT_FIELDCAT
        IT_SORT                       = GT_SORT
        IT_OUTTAB                     = GT_OUTTAB_LIST
        IT_FILTER                     = GT_FILTER
      EXCEPTIONS
        INVALID_PARAMETER_COMBINATION = 1
        PROGRAM_ERROR                 = 2
        TOO_MANY_LINES                = 3
        OTHERS                        = 4.

    CALL METHOD GRF_GRID->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  ENDIF.

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  DATA_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SELECT .

  DATA: LV_TABIX TYPE SY-TABIX,
        LV_INDAT TYPE SY-DATUM.

  DATA: LS_OUTTAB1 LIKE GS_OUTTAB,
        LT_OUTTAB1 LIKE TABLE OF LS_OUTTAB1,
        LS_OUTTAB2 LIKE GS_OUTTAB,
        LT_OUTTAB2 LIKE TABLE OF LS_OUTTAB2.

  IF P_CHK01 EQ 'X'.
    SELECT Z1~BUKRS
           Z1~NFUTN
           Z1~FCM
           Z1~RUDAT
           Z1~NFKEY
           Z1~BY_SL
           Z1~ENDAT
           Z1~MITYP
           Z1~MISPD
           Z1~MIMON
           Z1~PRICE
           Z1~WAERS
           Z1~EMENG
           Z1~MEINS
           Z4~NFCTR
           Z4~PRCTR
           Z4~VKGRP
           Z3~RQTYP
           Z3~REQNO
           Z2~H_NO1
           Z2~ERDAT
           Z4~CONNO
           Z4~COTXT
           Z4~CSTAT
           " ### DB 저장용 ###
           Z1~MISUS
           Z1~CONFM
           Z1~YNCAN
           Z1~YNFIN
           Z1~ZEPRO
           Z1~YNNET
           Z1~OLDFT
           Z4~COTYP
           Z4~KUNNR
           Z4~NCUST
           Z5~BIGO4
           " ### DB 저장용 ###
           INTO CORRESPONDING FIELDS OF TABLE LT_OUTTAB1
      FROM ZNFT1020 AS Z1
           INNER JOIN ZNFT1011 AS Z2
             ON Z2~REQNO EQ Z1~REQNO AND Z2~H_NO1 EQ Z1~H_NO1
           INNER JOIN ZNFT1010 AS Z3
             ON Z3~REQNO EQ Z1~REQNO
           INNER JOIN ZNFT1000 AS Z4
             ON Z4~CONNO EQ Z2~CONNO
           INNER JOIN ZNFT1001 AS Z5
             ON Z5~CONNO EQ Z2~CONNO AND Z5~NFKEY EQ Z2~NFKEY
     WHERE Z1~YNCAN NE 'X'
       AND Z1~YNFIN NE 'X'
*......결재상태에 관계없이 입력된 모든 data를 open position으로 봄.
*      (R.by구영헌/12.07.30)
*       AND Z1~CONFM IN ('3', '7')
       AND Z1~BUKRS EQ P_BUKRS
       AND Z1~FCM   IN S_FCM
       AND Z1~RUDAT IN S_RUDAT
       AND Z3~RQTYP IN S_RQTYP
       AND Z3~RQTYP IN R_RQTYP
       AND Z1~BY_SL IN S_BY_SL
       AND Z1~ENDAT IN S_ENDAT
       AND Z1~NFKEY IN S_NFKEY
       AND Z4~PRCTR IN S_PRCTR
       AND Z4~NFCTR IN S_NFCTR
       AND Z4~VKGRP IN S_VKGRP
       AND Z2~REQNO IN S_REQNO
       AND Z2~ERDAT IN S_ERDAT
       AND Z4~KUNNR IN S_KUNNR. "기능개선 103161 추가

    IF LT_OUTTAB1 IS NOT INITIAL.
      SORT LT_OUTTAB1 BY BUKRS NFUTN.
      LS_OUTTAB1-NE_CO = 'N'.
      MODIFY LT_OUTTAB1 FROM LS_OUTTAB1 TRANSPORTING NE_CO
                       WHERE NFUTN NE SPACE.
      APPEND LINES OF LT_OUTTAB1 TO GT_OUTTAB.
    ENDIF.

  ENDIF.

  IF P_CHK02 EQ 'X'.
    SELECT Z1~BUKRS
           Z1~CFUTN AS NFUTN
           Z1~FCM
           Z1~RUDAT
           Z1~NFKEY
           Z1~BY_SL
           Z1~ENDAT
           Z1~MITYP
           Z1~MISPD
           Z1~MIMON
           Z1~PRICE
           Z1~WAERS
           Z1~EMENG
           Z1~MEINS
           Z4~NFCTR
           Z4~PRCTR
           Z4~VKGRP
           Z3~RQTYP
           Z3~REQNO
           Z2~H_NO1
           Z2~ERDAT
           Z4~CONNO
           Z4~COTXT
           Z4~CSTAT
           " ### DB 저장용 ###
           Z1~MISUS
           Z1~CONFM
           Z1~YNCAN
           Z1~YNFIN
           Z1~ZEPRO
           Z1~YNNET
           Z1~OLDFT
           Z4~COTYP
           Z4~KUNNR
           Z4~NCUST
           Z6~BIGO4
           " ### DB 저장용 ###
           INTO CORRESPONDING FIELDS OF TABLE LT_OUTTAB2
      FROM ZNFT1030 AS Z1
           INNER JOIN ZNFT1020 AS Z5
             ON Z5~NFUTN EQ Z1~NFUTN AND Z5~BUKRS EQ Z1~BUKRS
           INNER JOIN ZNFT1011 AS Z2
             ON Z2~REQNO EQ Z5~REQNO AND Z2~H_NO1 EQ Z5~H_NO1
           INNER JOIN ZNFT1010 AS Z3
             ON Z3~REQNO EQ Z2~REQNO
           INNER JOIN ZNFT1000 AS Z4
             ON Z4~CONNO EQ Z2~CONNO
           INNER JOIN ZNFT1001 AS Z6
             ON Z6~CONNO EQ Z2~CONNO AND Z6~NFKEY EQ Z2~NFKEY
     WHERE Z1~YNCAN NE 'X'
       AND Z1~YNFIN NE 'X'
       AND Z1~BUKRS EQ P_BUKRS
       AND Z1~FCM   IN S_FCM
       AND Z1~RUDAT IN S_RUDAT
*......결재상태에 관계없이 입력된 모든 data를 open position으로 봄.
*      (R.by구영헌/12.07.30)
*       AND Z1~CONFM IN ('3', '7')
       AND Z3~RQTYP IN S_RQTYP
       AND Z3~RQTYP IN R_RQTYP
       AND Z1~BY_SL IN S_BY_SL
       AND Z1~ENDAT IN S_ENDAT
       AND Z1~NFKEY IN S_NFKEY
       AND Z4~PRCTR IN S_PRCTR
       AND Z4~NFCTR IN S_NFCTR
       AND Z4~VKGRP IN S_VKGRP
       AND Z2~REQNO IN S_REQNO
       AND Z2~ERDAT IN S_ERDAT
       AND Z4~KUNNR IN S_KUNNR. "기능개선 103161 추가

    IF LT_OUTTAB2 IS NOT INITIAL.
      SORT LT_OUTTAB2 BY BUKRS NFUTN.
      LS_OUTTAB2-NE_CO = 'C'.
      MODIFY LT_OUTTAB2 FROM LS_OUTTAB2 TRANSPORTING NE_CO
                       WHERE NFUTN NE SPACE.
      APPEND LINES OF LT_OUTTAB2 TO GT_OUTTAB.
    ENDIF.

  ENDIF.

  CLEAR: LV_TABIX, LV_INDAT.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      DATE      = SY-DATUM
      DAYS      = '01'
      MONTHS    = '00'
      SIGNUM    = '-'
      YEARS     = '00'
    IMPORTING
      CALC_DATE = LV_INDAT.

  CHECK LV_INDAT IS NOT INITIAL.

  DATA: LV_NFKEY TYPE ZNFKEY,
        LV_CASH  TYPE ZCASH_O,
        LV_PRICE TYPE ZPRICE2,
        LV_RATE  TYPE ZPRICE2.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    LV_TABIX = SY-TABIX.

*   ZNFT0001 조회용 NFKEY
    CONCATENATE GS_OUTTAB-NFKEY '1' INTO LV_NFKEY.

*   LV_PRICE : PRICE + Spread
    LV_PRICE = GS_OUTTAB-PRICE + GS_OUTTAB-MISPD.

*   현재시세
    SELECT SINGLE O_CASH INTO LV_CASH
      FROM ZNFT0001
     WHERE INDAT EQ LV_INDAT
       AND NFKEY EQ LV_NFKEY.

    IF SY-SUBRC NE 0.
*     없을 경우 가장 최근날짜의 시세를 가져온다.
      SELECT MAX( INDAT ) INTO LV_INDAT
        FROM ZNFT0001
       WHERE NFKEY EQ LV_NFKEY.
      IF SY-SUBRC EQ 0.
        SELECT SINGLE O_CASH INTO LV_CASH
          FROM ZNFT0001
         WHERE INDAT EQ LV_INDAT
           AND NFKEY EQ LV_NFKEY.
      ENDIF.
    ENDIF.

*   현재시세의 비율 : -10% 이하인경우 GREEN
*                          이상인경우 RED
*   BUY  : ( 현재시세 - ( PRICE + SPREAD ) / 현재시세 ) * 100
*   SELL : ( ( PRICE + SPREAD ) - 현재시세 / 현재시세 ) * 100
    IF GS_OUTTAB-PRICE IS NOT INITIAL.
      IF GS_OUTTAB-BY_SL EQ 'B'. " BUY
        IF LV_CASH EQ 0 OR LV_CASH IS INITIAL.
          LV_RATE = 0.
        ELSE.
          LV_RATE = ( ( LV_CASH - LV_PRICE ) / LV_CASH ) * 100.
        ENDIF.
        IF LV_RATE LE -10.
          GS_OUTTAB-ICON = '@0A@'.   "'@S_TL_R@'.
        ELSE.
          GS_OUTTAB-ICON = '@08@'.   "'@S_TL_G@'.
        ENDIF.
      ELSE.
        IF LV_CASH EQ 0 OR LV_CASH IS INITIAL.
          LV_RATE = 0.
        ELSE.
          LV_RATE = ( ( LV_PRICE - LV_CASH ) / LV_CASH ) * 100.
        ENDIF.
        IF LV_RATE LE -10.
          GS_OUTTAB-ICON = '@0A@'.    "'@S_TL_R@'.
        ELSE.
          GS_OUTTAB-ICON = '@08@'.    "'@S_TL_G@'.
        ENDIF.
      ENDIF.
    ELSE.
      GS_OUTTAB-ICON = '@08@'.    "'@S_TL_G@'.
    ENDIF.

    GS_OUTTAB-O_CASH = LV_CASH.

*   신규/청산
    PERFORM DOMAIN_VALUE_GET USING 'ZNE_CO'
                                   GS_OUTTAB-NE_CO
                                   GS_OUTTAB-NC_NM.

*   사업부
    PERFORM GET_NFCTR_DESC USING GS_OUTTAB-BUKRS
                                 GS_OUTTAB-NFCTR
                                 GS_OUTTAB-NFCTR_NM.

*   손익센터
    PERFORM GET_PRCTR_DESC USING GS_OUTTAB-BUKRS
                                 GS_OUTTAB-PRCTR
                                 GS_OUTTAB-PRCTR_NM.

*   영업그룹
    PERFORM GET_VKGRP_DESC USING GS_OUTTAB-BUKRS
                                 GS_OUTTAB-VKGRP
                                 GS_OUTTAB-VKGRP_NM.

*   Buy / Sell
    PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                   GS_OUTTAB-BY_SL
                                   GS_OUTTAB-BY_SL_NM.

*   FCM
    PERFORM GET_LIFNR_DESC USING GS_OUTTAB-FCM
                                 GS_OUTTAB-FCM_NM.

*   집행유형
    PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                   GS_OUTTAB-MITYP
                                   GS_OUTTAB-MITYP_NM.

*   요청유형
    PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                   GS_OUTTAB-RQTYP
                                   GS_OUTTAB-RQTYP_NM.

*   계약상태
    PERFORM DOMAIN_VALUE_GET USING 'ZCSTAT'
                                   GS_OUTTAB-CSTAT
                                   GS_OUTTAB-CSTAT_NM.

*   결재상태
    PERFORM DOMAIN_VALUE_GET USING 'ZCONFM3'
                                   GS_OUTTAB-CONFM
                                   GS_OUTTAB-CONFM_NM.

*   집행금액
    GS_OUTTAB-N_AMT = GS_OUTTAB-EMENG *
                    ( GS_OUTTAB-PRICE + GS_OUTTAB-MISPD ).

*-{기능개선 107383 - 만기이동 차수 조회 / 청산선물집행은 0
    IF GS_OUTTAB-NE_CO EQ 'N'.
      PERFORM GET_SHIFT_COUNT(ZNFR2310) USING GS_OUTTAB-NFUTN
                                              GS_OUTTAB-SHFCNT.
    "이동후 집행번호 기준으로 가져왔기 때문에  -1 해줌
      GS_OUTTAB-SHFCNT = GS_OUTTAB-SHFCNT - 1.
    ENDIF.
*-}기능개선 107383

    MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.
    CLEAR : LV_TABIX, GS_OUTTAB.
  ENDLOOP.

ENDFORM.                    " DATA_SELECT

*&---------------------------------------------------------------------*
*&      Form  DATA_SAVE_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SAVE_LIST .

  DATA: LV_INDAT TYPE SY-DATUM,
        LV_TABIX TYPE SY-TABIX,
        LV_NFKEY TYPE ZNFKEY,
        LV_CASH  TYPE ZCASH_O,
        LV_PRICE TYPE ZPRICE2,
        LV_RATE  TYPE ZPRICE2.

  CLEAR GS_OUTTAB_LIST. REFRESH GT_OUTTAB_LIST.

  SELECT Z1~BUKRS
         Z1~O_CASH
         Z1~ERDAT
         Z1~VRSIO
         Z1~ERNAM
         Z1~NE_CO
         Z1~OPNFN
         Z1~FCM
         Z1~RUDAT
         Z1~NFKEY
         Z1~BY_SL
         Z1~ENDAT
         Z1~MITYP
         Z1~MISPD
         Z1~MIMON
         Z1~PRICE
         Z1~WAERS
         Z1~EMENG
         Z1~MEINS
         Z1~CONFM
         Z1~NFCTR
         Z1~PRCTR
         Z1~RQTYP
         Z1~REQNO
         Z1~H_NO1
         Z1~RQDAT
         Z1~CONNO
         Z1~COTXT
         Z1~CSTAT
         INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB_LIST
    FROM ZNFT1054 AS Z1
   WHERE Z1~BUKRS EQ P_BUKRS
     AND Z1~VRSIO EQ P_VRSIO
     AND Z1~ERDAT EQ P_SVDAT
     AND Z1~ERNAM EQ P_SRNAM.
*     AND Z1~VRSIO IN R_VRSIO
*     AND Z1~ERDAT IN R_SVDAT
*     AND Z1~ERNAM IN R_SRNAM.

  IF GT_OUTTAB_LIST IS NOT INITIAL.
    SORT GT_OUTTAB_LIST BY BUKRS ERDAT VRSIO ERNAM.

    CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
      EXPORTING
        DATE      = SY-DATUM
        DAYS      = '01'
        MONTHS    = '00'
        SIGNUM    = '-'
        YEARS     = '00'
      IMPORTING
        CALC_DATE = LV_INDAT.

    LOOP AT GT_OUTTAB_LIST INTO GS_OUTTAB_LIST.
      LV_TABIX = SY-TABIX.

*     ZNFT0001 조회용 NFKEY
      CONCATENATE GS_OUTTAB_LIST-NFKEY '1' INTO LV_NFKEY.

*     LV_PRICE : PRICE + Spread
      LV_PRICE = GS_OUTTAB_LIST-PRICE + GS_OUTTAB_LIST-MISPD.

*     현재시세
      SELECT SINGLE O_CASH INTO LV_CASH
        FROM ZNFT0001
       WHERE INDAT EQ LV_INDAT
         AND NFKEY EQ LV_NFKEY.
      IF SY-SUBRC NE 0.
*       없을 경우 가장 최근날짜의 시세를 가져온다.
        SELECT MAX( INDAT ) INTO LV_INDAT
          FROM ZNFT0001
         WHERE NFKEY EQ LV_NFKEY.
        IF SY-SUBRC EQ 0.
          SELECT SINGLE O_CASH INTO LV_CASH
            FROM ZNFT0001
           WHERE INDAT EQ LV_INDAT
             AND NFKEY EQ LV_NFKEY.
        ENDIF.
      ENDIF.

*     현재시세의 비율 : -10% 이하인경우 GREEN
*                            이상인경우 RED
*     BUY  : ( 현재시세 - ( PRICE + SPREAD ) / 현재시세 ) * 100
*     SELL : ( ( PRICE + SPREAD ) - 현재시세 / 현재시세 ) * 100
      IF GS_OUTTAB_LIST-PRICE IS NOT INITIAL.
        IF GS_OUTTAB_LIST-BY_SL EQ 'B'. " BUY
          IF LV_CASH EQ 0 OR LV_CASH IS INITIAL.
            LV_RATE = 0.
          ELSE.
            LV_RATE = ( ( LV_CASH - LV_PRICE ) / LV_CASH ) * 100.
          ENDIF.
          IF LV_RATE LE -10.
            GS_OUTTAB_LIST-ICON = '@0A@'.   "'@S_TL_R@'.
          ELSE.
            GS_OUTTAB_LIST-ICON = '@08@'.   "'@S_TL_G@'.
          ENDIF.
        ELSE.
          IF LV_CASH EQ 0 OR LV_CASH IS INITIAL.
            LV_RATE = 0.
          ELSE.
            LV_RATE = ( ( LV_PRICE - LV_CASH ) / LV_CASH ) * 100.
          ENDIF.
          IF LV_RATE LE -10.
            GS_OUTTAB_LIST-ICON = '@0A@'.   "'@S_TL_R@'.
          ELSE.
            GS_OUTTAB_LIST-ICON = '@08@'.   "'@S_TL_G@'.
          ENDIF.
        ENDIF.
      ELSE.
        GS_OUTTAB_LIST-ICON = '@08@'.   "'@S_TL_G@'.
      ENDIF.

*     집행금액
      GS_OUTTAB_LIST-N_AMT = GS_OUTTAB_LIST-EMENG *
      ( GS_OUTTAB_LIST-PRICE + GS_OUTTAB_LIST-MISPD ).

*   Buy / Sell
      PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                     GS_OUTTAB_LIST-BY_SL
                                     GS_OUTTAB_LIST-BY_SL_NM.

*     신규/청산
      PERFORM DOMAIN_VALUE_GET USING 'ZNE_CO'
                                     GS_OUTTAB_LIST-NE_CO
                                     GS_OUTTAB_LIST-NC_NM.

*     FCM
      PERFORM GET_LIFNR_DESC USING GS_OUTTAB_LIST-FCM
                                   GS_OUTTAB_LIST-FCM_NM.

*     사업부
      PERFORM GET_NFCTR_DESC USING GS_OUTTAB_LIST-BUKRS
                                   GS_OUTTAB_LIST-NFCTR
                                   GS_OUTTAB_LIST-NFCTR_NM.

*     손익센터
      PERFORM GET_PRCTR_DESC USING GS_OUTTAB_LIST-BUKRS
                                   GS_OUTTAB_LIST-PRCTR
                                   GS_OUTTAB_LIST-PRCTR_NM.

*     집행유형
      PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                     GS_OUTTAB_LIST-MITYP
                                     GS_OUTTAB_LIST-MITYP_NM.

*     요청유형
      PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                     GS_OUTTAB_LIST-RQTYP
                                     GS_OUTTAB_LIST-RQTYP_NM.

*     계약상태
      PERFORM DOMAIN_VALUE_GET USING 'ZCSTAT'
                                     GS_OUTTAB_LIST-CSTAT
                                     GS_OUTTAB_LIST-CSTAT_NM.

*     결재상태
      PERFORM DOMAIN_VALUE_GET USING 'ZCONFM3'
                                     GS_OUTTAB_LIST-CONFM
                                     GS_OUTTAB_LIST-CONFM_NM.

      MODIFY GT_OUTTAB_LIST FROM GS_OUTTAB_LIST INDEX LV_TABIX.
      CLEAR : LV_TABIX, GS_OUTTAB_LIST.

    ENDLOOP.
  ENDIF.

ENDFORM.                    " DATA_SAVE_LIST

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
        LV_INDEX TYPE I,
        LV_TABIX TYPE I.

  CLEAR LV_INDEX.
  LOOP AT P_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    LV_INDEX = LS_MOD_CELLS-ROW_ID.

*   Data 가공용 Structure
    READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX LV_INDEX.

    IF SY-SUBRC EQ 0.
      CASE LS_MOD_CELLS-FIELDNAME.
        WHEN 'CHECK'.
          IF LS_MOD_CELLS-VALUE EQ 'X'.
            GS_OUTTAB-CHECK = 'X'.
          ELSE.
            GS_OUTTAB-CHECK = SPACE.
          ENDIF.
          MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX.
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
      WHEN 'REQNO'.
        IF NOT GS_OUTTAB-REQNO IS INITIAL.
          SET PARAMETER ID 'ZNFREQ' FIELD GS_OUTTAB-REQNO.
          CALL TRANSACTION 'ZNF2M2103' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE '선물요청번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN 'NFUTN'.
        IF GS_OUTTAB-NE_CO EQ 'N'.
          PERFORM CALL_NFUTN_PGM USING GS_OUTTAB-NFUTN.
        ELSE.
          PERFORM CALL_CFUTN_PGM USING GS_OUTTAB-NFUTN.
        ENDIF.
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
*&      Form  F4HELP_SAVE_VER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_S_SVDAT_LOW  text
*      -->P_S_SRNAM_LOW  text
*----------------------------------------------------------------------*
FORM F4HELP_SAVE_VER  USING  PV_VRSIO
                             PV_SVDAT
                             PV_SRNAM.

  CHECK P_R02 EQ 'X'.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX, GV_INDEX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_SAVE.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_SAVE.

*___화면상의 회사코드를 읽는다.
  IF SY-DYNNR = '1000'.
    SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
    APPEND SCR_FIELDS.

    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        DYNAME     = 'ZNFR2650'
        DYNUMB     = '1000'
      TABLES
        DYNPFIELDS = SCR_FIELDS.

    READ TABLE SCR_FIELDS WITH KEY FIELDNAME = 'P_BUKRS'.
    P_BUKRS = SCR_FIELDS-FIELDVALUE.
  ENDIF.

  IF P_BUKRS IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '회사코드를 입력하시기 바랍니다.'.
    EXIT.
  ENDIF.

  IF SY-DYNNR = '1000'.
    SCR_FIELDS-FIELDNAME = 'P_VRSIO'.
    APPEND SCR_FIELDS.

    SCR_FIELDS-FIELDNAME = 'P_SVDAT'.
    APPEND SCR_FIELDS.

    SCR_FIELDS-FIELDNAME = 'P_SRNAM'.
    APPEND SCR_FIELDS.

    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        DYNAME     = 'ZNFR2650'
        DYNUMB     = '1000'
      TABLES
        DYNPFIELDS = SCR_FIELDS.

    READ TABLE SCR_FIELDS WITH KEY FIELDNAME = 'P_VRSIO'.
    P_VRSIO = SCR_FIELDS-FIELDVALUE.

    READ TABLE SCR_FIELDS WITH KEY FIELDNAME = 'P_SVDAT'.
    IF SCR_FIELDS-FIELDVALUE IS NOT INITIAL.
      REPLACE ALL OCCURRENCES OF : '.' IN SCR_FIELDS-FIELDVALUE WITH '',
                                   '/' IN SCR_FIELDS-FIELDVALUE WITH '',
                                   '-' IN SCR_FIELDS-FIELDVALUE WITH ''.
      CONDENSE SCR_FIELDS-FIELDVALUE NO-GAPS.
      P_SVDAT = SCR_FIELDS-FIELDVALUE.
    ELSE.
      CLEAR : P_SVDAT.
    ENDIF.

    READ TABLE SCR_FIELDS WITH KEY FIELDNAME = 'P_SRNAM'.
    P_SRNAM = SCR_FIELDS-FIELDVALUE.

  ENDIF.

  DATA: WHERE_TAB   TYPE TABLE OF EDPLINE,
        SOURCE_LINE TYPE EDPLINE.

  CLEAR SOURCE_LINE.
  CONCATENATE 'BUKRS EQ ''' P_BUKRS '''' INTO SOURCE_LINE.
  APPEND SOURCE_LINE TO WHERE_TAB.

  IF P_VRSIO IS NOT INITIAL.
    CLEAR SOURCE_LINE.
    CONCATENATE 'AND VRSIO EQ ''' P_VRSIO '''' INTO SOURCE_LINE.
    APPEND SOURCE_LINE TO WHERE_TAB.
  ENDIF.

  CONDENSE P_SVDAT NO-GAPS.
  DATA: LV_LEN TYPE I.
  LV_LEN = STRLEN( P_SVDAT ).
  IF P_SVDAT IS NOT INITIAL." AND P_SVDAT > '20000101'.
    CLEAR SOURCE_LINE.
    CONCATENATE 'AND ERDAT EQ ''' P_SVDAT '''' INTO SOURCE_LINE.
    APPEND SOURCE_LINE TO WHERE_TAB.
  ENDIF.

  CONDENSE P_SRNAM NO-GAPS.
  IF P_SRNAM IS NOT INITIAL.
    CLEAR SOURCE_LINE.
    CONCATENATE 'AND ERNAM EQ ''' P_SRNAM '''' INTO SOURCE_LINE.
    APPEND SOURCE_LINE TO WHERE_TAB.
  ENDIF.

  SELECT VRSIO ERNAM ERDAT
         INTO CORRESPONDING FIELDS OF TABLE GT_SAVE
    FROM ZNFT1054
   WHERE (WHERE_TAB).

  IF SY-SUBRC EQ 0.
    SORT GT_SAVE BY ERDAT DESCENDING
                    VRSIO DESCENDING.
    DELETE ADJACENT DUPLICATES FROM GT_SAVE.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '저장버전 정보가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZNFT1054'.
  IT_FIELDS-FIELDNAME  = 'ERDAT'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1054'.
  IT_FIELDS-FIELDNAME  = 'ERNAM'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1054'.
  IT_FIELDS-FIELDNAME  = 'VRSIO'.
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
      FULL_TABLE                   = GT_SAVE
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_SAVE INDEX LD_TABIX.
  IF SY-SUBRC = 0.
*   ###### 저장버전 ######
    FELD_TABLE-FIELDNAME  = 'P_VRSIO'.
    FELD_TABLE-FIELDVALUE = GT_SAVE-VRSIO.
    APPEND FELD_TABLE.

*   ###### 저장일자 ######
    FELD_TABLE-FIELDNAME  = 'P_SVDAT'.
    FELD_TABLE-FIELDVALUE = GT_SAVE-ERDAT.
    APPEND FELD_TABLE.

*   ###### 저장자 ######
    FELD_TABLE-FIELDNAME  = 'P_SRNAM'.
    FELD_TABLE-FIELDVALUE = GT_SAVE-ERNAM.
    APPEND FELD_TABLE.

*   ##### 화면에 세팅 #####
    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME     = 'ZNFR2650'
        DYNUMB     = '1000'
      TABLES
        DYNPFIELDS = FELD_TABLE.
  ENDIF.

ENDFORM.                    " F4HELP_SAVE_VER

*&---------------------------------------------------------------------*
*&      Form  DATA_SAVE_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM DATA_SAVE_CHECK  USING  PV_ERROR.

  CLEAR PV_ERROR.

  READ TABLE GT_OUTTAB INTO GS_OUTTAB WITH KEY CHECK = 'X'.
  IF SY-SUBRC NE 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '저장하실 데이터를 선택하십시오.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    " DATA_SAVE_CHECK

*&---------------------------------------------------------------------*
*&      Form  DATA_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SAVE .

  DATA: LS_ZNFT1054 TYPE ZNFT1054,
        LT_ZNFT1054 TYPE TABLE OF ZNFT1054.

  DATA: LV_VER_CNT TYPE ZVRSIO,
        LV_RTN_MSG TYPE CHAR50.

  CLEAR LS_ZNFT1054. REFRESH LT_ZNFT1054.

  CLEAR : LV_VER_CNT.

* 저장버전 채번
  SELECT SINGLE MAX( VRSIO ) AS VRSIO INTO LV_VER_CNT
    FROM ZNFT1054
   WHERE BUKRS EQ P_BUKRS
*   AND OPNFN EQ GS_OUTTAB-NFUTN
     AND ERNAM EQ SY-UNAME
     AND ERDAT EQ SY-DATLO.

  LV_VER_CNT = LV_VER_CNT + 1.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE CHECK EQ 'X'.
    MOVE-CORRESPONDING GS_OUTTAB TO LS_ZNFT1054.

    LS_ZNFT1054-VRSIO = LV_VER_CNT.
    LS_ZNFT1054-RQDAT = GS_OUTTAB-ERDAT.
    LS_ZNFT1054-OPNFN = GS_OUTTAB-NFUTN.
    LS_ZNFT1054-ERNAM = SY-UNAME.
    LS_ZNFT1054-ERDAT = SY-DATLO.
    LS_ZNFT1054-ERZET = SY-TIMLO.
    LS_ZNFT1054-AENAM = SY-UNAME.
    LS_ZNFT1054-AEDAT = SY-DATLO.
    LS_ZNFT1054-AEZET = SY-TIMLO.
    APPEND LS_ZNFT1054 TO LT_ZNFT1054.
  ENDLOOP.

  IF LT_ZNFT1054 IS NOT INITIAL.
    MODIFY ZNFT1054 FROM TABLE LT_ZNFT1054.
    IF SY-SUBRC EQ 0.
      COMMIT WORK.

      CONCATENATE LV_VER_CNT SY-DATLO SY-UNAME INTO LV_RTN_MSG
             SEPARATED BY ' / '.

      MESSAGE S003 DISPLAY LIKE 'S'
         WITH LV_RTN_MSG
              ': 데이터 저장에 성공하였습니다.'.
    ELSE.
      ROLLBACK WORK.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '데이터 저장에 실패하였습니다.'.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    " DATA_SAVE

*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_ALL .

  DATA: LV_INDEX TYPE SY-TABIX.

  CLEAR LV_INDEX.
  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    LV_INDEX = SY-TABIX.
    IF GV_CODE EQ 'ASEL'.
      GS_OUTTAB-CHECK = 'X'.
    ELSE.
      CLEAR GS_OUTTAB-CHECK.
    ENDIF.
    MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX TRANSPORTING CHECK.
  ENDLOOP.

ENDFORM.                    " SELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  INITIAL_SETTING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INITIAL_SETTING .

  GV_TCODE = SY-TCODE.

*  IF P_R01 EQ 'X'.
*    LOOP AT SCREEN.
*      IF SCREEN-NAME EQ 'P_VRSIO' OR
*         SCREEN-NAME EQ 'P_SVDAT' OR
*         SCREEN-NAME EQ 'P_SRNAM'.
*        SCREEN-INPUT = 0.
*      ENDIF.
*      MODIFY SCREEN.
*    ENDLOOP.
*  ELSE.
*  ENDIF.

  IF GV_TCODE EQ 'ZNF2R2650A'.
    GV_TITLE = '내역조회'.
  ELSE.
    GV_TITLE = '내역관리'.
  ENDIF.

  SET TITLEBAR '1000' WITH GV_TITLE.

ENDFORM.                    " INITIAL_SETTING

*&---------------------------------------------------------------------*
*&      Form  MODIF_SCREEN_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIF_SCREEN_1000 .

  LOOP AT SCREEN.
    IF ( P_R01 = 'X' AND SCREEN-GROUP1 = 'MD2' ) OR
       ( P_R02 = 'X' AND SCREEN-GROUP1 = 'MD1' ).
      SCREEN-INPUT = 0.

      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

** INPUT = 0 : 입력 비활성화
** INPUT = 1 : 입력   활성화
*  IF P_R01 EQ 'X'.
*    LOOP AT SCREEN.
*      CASE SCREEN-NAME.
*        WHEN 'P_VRSIO' OR 'P_SVDAT' OR 'P_SRNAM'.
*          SCREEN-INPUT = 0.
*        WHEN OTHERS.
*          SCREEN-INPUT = 1.
*      ENDCASE.
*      MODIFY SCREEN.
*    ENDLOOP.
*  ELSE.
**    LOOP AT SCREEN.
**      IF SCREEN-NAME EQ 'P_VRSIO' OR
**         SCREEN-NAME EQ 'P_SVDAT' OR
**         SCREEN-NAME EQ 'P_SRNAM'.
**        SCREEN-INPUT = 1.
**        MODIFY SCREEN.
**      ENDIF.
**    ENDLOOP.
*
*    LOOP AT SCREEN.
*      CASE SCREEN-NAME.
*        WHEN 'P_BUKRS' OR 'P_R01' OR 'P_R02' OR
*             'P_VRSIO' OR 'P_SVDAT' OR 'P_SRNAM'.
*          SCREEN-INPUT = 1.
*        WHEN OTHERS.
*          SCREEN-INPUT = 0.
*      ENDCASE.
*      MODIFY SCREEN.
*    ENDLOOP.
*
*  ENDIF.

ENDFORM.                    " MODIF_SCREEN_1000
*&---------------------------------------------------------------------*
*&      Form  CHECK_R02_CONDI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_R02_CONDI USING PV_ERROR.

* 필수입력 체크
  IF P_VRSIO IS INITIAL OR P_SVDAT IS INITIAL OR P_SRNAM IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '저장조건은 필수입력 조건입니다.'.
    PV_ERROR = 'X'.
  ENDIF.

ENDFORM.                    " CHECK_R02_CONDI
*&---------------------------------------------------------------------*
*&      Form  MAKE_RANGES_VAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_RANGES_VAR .

  CLEAR   : R_VRSIO, R_SVDAT, R_SRNAM.
  REFRESH : R_VRSIO, R_SVDAT, R_SRNAM.

  APPEND_RANGES : R_VRSIO 'I' 'EQ' P_VRSIO SPACE,
                  R_SVDAT 'I' 'EQ' P_SVDAT SPACE,
                  R_SRNAM 'I' 'EQ' P_SRNAM SPACE.

ENDFORM.                    " MAKE_RANGES_VAR
