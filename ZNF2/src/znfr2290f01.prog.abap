*&---------------------------------------------------------------------*
*&  Include           ZNFR2290F01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&  Include           ZNFR2230F01
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

*___화면상의 회사코드를 읽는다.
  IF SY-DYNNR = '1000'.
    SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
    APPEND SCR_FIELDS.

    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        DYNAME     = 'ZNFR2290'
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

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
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

  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'NFUTN'.
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

  PERFORM SET_FIELDCAT USING:
    'CHECK'           '선택'            '10'     'C'    ' '     ,
    'BUKRS'           '회사코드'        '10'     'C'    ' '     ,
*    'BUKRS_NM'        '회사명'          '10'     'L'    ' '     ,
    'NFUTN'           '집행번호'        '10'     'C'    ' '     ,
    'FCM'             'FCM'             '10'     'C'    'ALPHA' ,
    'FCM_NM'          'FCM'             '10'     'L'    ' '     ,
    'RUDAT'           '집행일'          '10'     'C'    ' '     ,
    'GUBUN'           '구  분'          '10'     'C'    ' '     ,
    'GUBUN_NM'        '구  분'          '10'     'L'    ' '     ,
    'NFKEY'           '비철구분'        '10'     'C'    ' '     ,
    'BY_SL'           'Buy/Sell'        '10'     'C'    ' '     ,
    'BY_SL_NM'        'Buy/Sell'        '10'     'L'    ' '     ,
    'ENDAT'           '만기일'          '10'     'C'    ' '     ,
    'MITYP'           '집행유형'        '10'     'C'    ' '     ,
    'MITYP_NM'        '집행유형'        '10'     'L'    ' '     ,
    'MISPD'           'Spread'          '10'     'C'    ' '     ,
    'MISUS'           '수수료여부'      '10'     'C'    ' '     ,
    'MIMON'           '기준월'          '10'     'C'    ' '     ,
    'PRICE'           '집행단가'        '15'     'R'    ' '     ,
    'WAERS'           '통화'            '5'      'C'    ' '     ,
    'EMENG'           '집행수량'        '14'     'R'    ' '     ,
    'MEINS'           '단위'            '10'     'C'    ' '     ,
    'BIGO4'           '비고'            '20'     'L'    ' '     .

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
    WHEN 'PRICE'.
*      GS_FIELDCAT-EDIT       = 'X'.
      GS_FIELDCAT-CFIELDNAME = 'WAERS'.
    WHEN 'GUBUN'.
      GS_FIELDCAT-NO_OUT     = 'X'.
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
    PERFORM FILL_CELLTAB_C CHANGING LT_CELLTAB.
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

  CALL METHOD GRF_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CREATE OBJECT GRF_EVENT_RECEIVER.
  SET HANDLER :
    GRF_EVENT_RECEIVER->HANDLE_DATA_CHANGED FOR GRF_GRID.

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
  GS_F4-FIELDNAME = 'NFUTN'.
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
*&      Form  GET_FUTURES_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FUTURES_DATA.

  CLEAR : GV_INIT1, GV_INIT2, GV_ERROR.

* 신규집행건
  IF P_CHK01 EQ 'X'.
    PERFORM GET_DATA_ZNFT1020 USING GV_INIT1.
  ENDIF.

* 청산집행건
  IF P_CHK02 EQ 'X'.
    PERFORM GET_DATA_ZNFT1030 USING GV_INIT2.
  ENDIF.

  IF GV_INIT1 IS NOT INITIAL AND GV_INIT2 IS NOT INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택조건에 해당하는 데이터가 존재하지 않습니다.'.
  ELSE.
    PERFORM DATA_COLLECT.
  ENDIF.

* 평균단가 화폐단위 = USD
  GV_WAERS = 'USD'.

ENDFORM.                    " GET_FUTURES_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_ZNFT1020
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_ZNFT1020 USING PV_INIT.

  SELECT Z1~BUKRS
         Z1~NFUTN
         Z1~FCM
         L1~NAME1 AS FCM_NM
         Z1~ENDAT
         Z1~RUDAT
         Z1~BY_SL
         Z1~ENDAT
         Z1~MITYP
         " MITYP_NM
         Z1~MISPD
         Z1~MIMON
         Z1~PRICE
         Z1~WAERS
         Z1~EMENG
         Z1~MEINS
         Z1~MISUS
         Z1~BIGO4
         Z1~NFKEY
         Z1~BY_SL
         Z1~YNCAN
         Z1~CONFM
         INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB_N
    FROM ZNFT1020 AS Z1
         INNER JOIN LFA1 AS L1
            ON L1~LIFNR EQ Z1~FCM
   WHERE Z1~BUKRS EQ P_BUKRS
     AND Z1~ENDAT IN S_ENDAT
     AND Z1~RUDAT IN S_RUDAT
     AND Z1~FCM   IN S_FCM
     AND Z1~NFKEY IN S_NFKEY
     AND Z1~MIMON IN S_MIMON
     AND Z1~NFUTN IN S_NFUTN
     AND Z1~BY_SL IN S_BY_SL
     AND Z1~YNFIN NE 'X'
     AND Z1~YNNET NE 'X'
     AND Z1~MITYP EQ 'A'.

  IF GT_OUTTAB_N[] IS INITIAL.
    PV_INIT = 'X'.
  ENDIF.

ENDFORM.                    " GET_DATA_ZNFT1020
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_ZNFT1030
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_ZNFT1030 USING PV_INIT.

  SELECT Z1~BUKRS
         Z1~CFUTN
         Z1~FCM
         L1~NAME1 AS FCM_NM
         Z1~ENDAT
         Z1~RUDAT
         Z1~BY_SL
         Z1~ENDAT
         Z1~MITYP
         " MITYP_NM
         Z1~MISPD
         Z1~MIMON
         Z1~PRICE
         Z1~WAERS
         Z1~EMENG
         Z1~MEINS
         Z1~MISUS
         Z1~BIGO4
         Z1~NFKEY
         Z1~BY_SL
         Z1~YNCAN
         Z1~CONFM
         INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB_C
    FROM ZNFT1030 AS Z1
         INNER JOIN LFA1 AS L1
            ON L1~LIFNR EQ Z1~FCM
   WHERE Z1~BUKRS EQ P_BUKRS
     AND Z1~ENDAT IN S_ENDAT
     AND Z1~RUDAT IN S_RUDAT
     AND Z1~FCM   IN S_FCM
     AND Z1~NFKEY IN S_NFKEY
     AND Z1~MIMON IN S_MIMON
     AND Z1~CFUTN IN S_CFUTN
     AND Z1~BY_SL IN S_BY_SL
     AND Z1~YNFIN NE 'X'
     AND Z1~YNNET NE 'X'
     AND Z1~MITYP EQ 'A'.

  IF GT_OUTTAB_C[] IS INITIAL.
    PV_INIT = 'X'.
  ENDIF.

ENDFORM.                    " GET_DATA_ZNFT1030

*&---------------------------------------------------------------------*
*&      Form  DATA_COLLECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_COLLECT .

  CLEAR GS_OUTTAB. REFRESH GT_OUTTAB.

  IF P_CHK01 EQ 'X' AND GT_OUTTAB_N[] IS NOT INITIAL.
    SORT GT_OUTTAB_N BY NFUTN.
    LOOP AT GT_OUTTAB_N INTO GS_OUTTAB_N.
      MOVE-CORRESPONDING GS_OUTTAB_N TO GS_OUTTAB.

      GS_OUTTAB-GUBUN    = 'N'.
      GS_OUTTAB-GUBUN_NM = '신규'.

*   - 회사코드
      PERFORM GET_BUKRS_DESC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-BUKRS_NM.

*     - Buy-Sell 구분
      IF GS_OUTTAB-BY_SL IS NOT INITIAL.
        PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                       GS_OUTTAB-BY_SL
                                       GS_OUTTAB-BY_SL_NM.
      ENDIF.

*     - 집행유형
      IF GS_OUTTAB-MITYP IS NOT INITIAL.
        PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                       GS_OUTTAB-MITYP
                                       GS_OUTTAB-MITYP_NM.
      ENDIF.

*     삭제이면서 결재상태가 승인 또는 수정승인인 건은 제외
      IF GS_OUTTAB_N-YNCAN EQ 'X' AND
          ( GS_OUTTAB_N-CONFM EQ '3' OR GS_OUTTAB_N-CONFM EQ '7' ).
        CONTINUE.
      ELSE.
        APPEND GS_OUTTAB TO GT_OUTTAB.
      ENDIF.

    ENDLOOP.
  ENDIF.

  IF P_CHK02 EQ 'X' AND GT_OUTTAB_C[] IS NOT INITIAL.
    SORT GT_OUTTAB_C BY CFUTN.
    LOOP AT GT_OUTTAB_C INTO GS_OUTTAB_C.
      MOVE-CORRESPONDING GS_OUTTAB_C TO GS_OUTTAB.

      GS_OUTTAB-GUBUN    = 'C'.
      GS_OUTTAB-GUBUN_NM = '청산'.

      GS_OUTTAB-NFUTN = GS_OUTTAB_C-CFUTN.

*   - 회사코드
      PERFORM GET_BUKRS_DESC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-BUKRS_NM.

*     - Buy-Sell 구분
      IF GS_OUTTAB-BY_SL IS NOT INITIAL.
        PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                       GS_OUTTAB-BY_SL
                                       GS_OUTTAB-BY_SL_NM.
      ENDIF.

*     - 집행유형
      IF GS_OUTTAB-MITYP IS NOT INITIAL.
        PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                       GS_OUTTAB-MITYP
                                       GS_OUTTAB-MITYP_NM.
      ENDIF.

*     삭제이면서 결재상태가 승인 또는 수정승인인 건은 제외
      IF GS_OUTTAB_C-YNCAN EQ 'X' AND
          ( GS_OUTTAB_C-CONFM EQ '3' OR GS_OUTTAB_C-CONFM EQ '7' ).
        CONTINUE.
      ELSE.
        APPEND GS_OUTTAB TO GT_OUTTAB.
      ENDIF.

    ENDLOOP.
  ENDIF.

ENDFORM.                    " DATA_COLLECT


*&---------------------------------------------------------------------*
*&      Form  FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_CELLTAB_C CHANGING PT_CELLTAB TYPE LVC_T_STYL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         L_MODE     TYPE RAW4.

  DATA : L_FIELDCAT TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT INTO L_FIELDCAT.
    LS_CELLTAB-FIELDNAME = L_FIELDCAT-FIELDNAME.

*   필드 활성화 여부
    CASE LS_CELLTAB-FIELDNAME.
      WHEN 'CHECK'.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*      WHEN 'PRICE'.
*        IF GS_OUTTAB-CHECK EQ 'X'.
*          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*        ELSE.
*          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*        ENDIF.
      WHEN OTHERS.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    ENDCASE.
    INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
  ENDLOOP.

ENDFORM.                    " FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*&      Form  CHECK_SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM CHECK_SAVE_DATA USING PV_ERROR.

  IF GV_PRICE IS INITIAL OR GV_PRICE EQ 0 OR GV_PRICE EQ SPACE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '평균단가를 입력하십시오.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

  READ TABLE GT_OUTTAB INTO GS_OUTTAB WITH KEY CHECK = 'X'.
  IF SY-SUBRC NE 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '평균단가를 적용할 데이터를 선택하십시오.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_SAVE_DATA
*&---------------------------------------------------------------------*
*&      Form  DATA_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SAVE .

  DATA: LS_ZNFT1020N TYPE ZNFT1020,
        LT_ZNFT1020N LIKE TABLE OF LS_ZNFT1020N,
        LS_ZNFT1030N TYPE ZNFT1030,
        LT_ZNFT1030N LIKE TABLE OF LS_ZNFT1030N,
        LS_ZNFT1020Y TYPE ZNFT1020,
        LT_ZNFT1020Y LIKE TABLE OF LS_ZNFT1020Y,
        LS_ZNFT1030Y TYPE ZNFT1030,
        LT_ZNFT1030Y LIKE TABLE OF LS_ZNFT1030Y.

  DATA: LV_OBJECTID             TYPE CDHDR-OBJECTID,
        LV_TCODE                TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT      TYPE CDHDR-CHANGE_IND,
        LV_UPD_ICDTXT           TYPE CHAR1.

  DATA: LV_CNT TYPE I,
        LV_TABIX TYPE SY-TABIX.

  CLEAR   : LS_ZNFT1020N, LS_ZNFT1030N,
            LS_ZNFT1020Y, LS_ZNFT1030Y,
            GV_CNT.
  REFRESH : LT_ZNFT1020N, LT_ZNFT1030N,
            LT_ZNFT1020Y, LT_ZNFT1030Y.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE CHECK EQ 'X'.

    CASE GS_OUTTAB-GUBUN.
      WHEN 'N'.
        SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1020Y
          FROM ZNFT1020
         WHERE NFUTN EQ GS_OUTTAB-NFUTN.

        APPEND LS_ZNFT1020Y TO LT_ZNFT1020Y.
      WHEN 'C'.
        SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1030Y
          FROM ZNFT1030
         WHERE CFUTN EQ GS_OUTTAB-NFUTN.

        APPEND LS_ZNFT1030Y TO LT_ZNFT1030Y.
    ENDCASE.

  ENDLOOP.

* ----------------------------------------------------------------------
* 신규집행 평균단가 UPDATE 및 SAVE CHANGE DOCUMENT 생성
* ----------------------------------------------------------------------
  IF LT_ZNFT1020Y IS NOT  INITIAL.
    CLEAR: LS_ZNFT1020Y, LV_CNT.
    LOOP AT LT_ZNFT1020Y INTO LS_ZNFT1020Y.
      MOVE-CORRESPONDING LS_ZNFT1020Y TO LS_ZNFT1020N.
      LS_ZNFT1020N-PRICE = GV_PRICE.
      LS_ZNFT1020N-AENAM = SY-UNAME.
      LS_ZNFT1020N-AEDAT = SY-DATLO.
      LS_ZNFT1020N-AEZET = SY-TIMLO.
      APPEND LS_ZNFT1020N TO LT_ZNFT1020N.
    ENDLOOP.
    LV_CNT = LINES( LT_ZNFT1020N ).
    ADD LV_CNT TO GV_CNT.
  ENDIF.

  SORT LT_ZNFT1020N BY NFUTN.
  SORT LT_ZNFT1020Y BY NFUTN.

  MODIFY ZNFT1020 FROM TABLE LT_ZNFT1020N.
  IF SY-SUBRC EQ 0.
    COMMIT WORK.
    LOOP AT LT_ZNFT1020N INTO LS_ZNFT1020N.
      LV_TABIX = SY-TABIX.
      LV_CDOC_UPD_OBJECT = 'U'.
      LV_OBJECTID = LS_ZNFT1020N-NFUTN.
      LV_TCODE    = SY-TCODE.
      READ TABLE LT_ZNFT1020Y INTO LS_ZNFT1020Y INDEX LV_TABIX.
      IF SY-SUBRC EQ 0.
        CALL FUNCTION 'ZNFT1020CHDOC_WRITE_DOCUMENT'
          EXPORTING
            OBJECTID     = LV_OBJECTID
            TCODE        = LV_TCODE
            UTIME        = SY-TIMLO
            UDATE        = SY-DATLO
            USERNAME     = SY-UNAME
            N_ZNFT1020   = LS_ZNFT1020N
            O_ZNFT1020   = LS_ZNFT1020Y
            UPD_ZNFT1020 = LV_CDOC_UPD_OBJECT.
      ENDIF.
    ENDLOOP.
  ELSE.
    ROLLBACK WORK.
    EXIT.
  ENDIF.

* ----------------------------------------------------------------------
* 청산집행 평균단가 UPDATE 및 SAVE CHANGE DOCUMENT 생성
* ----------------------------------------------------------------------
  IF LT_ZNFT1030Y IS NOT  INITIAL.
    CLEAR: LS_ZNFT1030Y, LV_CNT.
    LOOP AT LT_ZNFT1030Y INTO LS_ZNFT1030Y.
      MOVE-CORRESPONDING LS_ZNFT1030Y TO LS_ZNFT1030N.
      LS_ZNFT1030N-PRICE = GV_PRICE.
      LS_ZNFT1030N-AENAM = SY-UNAME.
      LS_ZNFT1030N-AEDAT = SY-DATLO.
      LS_ZNFT1030N-AEZET = SY-TIMLO.
      APPEND LS_ZNFT1030N TO LT_ZNFT1030N.
    ENDLOOP.
    ADD LV_CNT TO GV_CNT.
  ENDIF.

  SORT LT_ZNFT1030N BY CFUTN.
  SORT LT_ZNFT1030Y BY CFUTN.

  MODIFY ZNFT1030 FROM TABLE LT_ZNFT1030N.
  IF SY-SUBRC EQ 0.
    COMMIT WORK.
    LOOP AT LT_ZNFT1030N INTO LS_ZNFT1030N.
      LV_TABIX = SY-TABIX.
      LV_CDOC_UPD_OBJECT = 'U'.
      LV_OBJECTID = LS_ZNFT1030N-CFUTN.
      LV_TCODE    = SY-TCODE.
      READ TABLE LT_ZNFT1030Y INTO LS_ZNFT1030Y INDEX LV_TABIX.
      IF SY-SUBRC EQ 0.
        CALL FUNCTION 'ZNFT1030CHDOC_WRITE_DOCUMENT'
          EXPORTING
            OBJECTID     = LV_OBJECTID
            TCODE        = LV_TCODE
            UTIME        = SY-TIMLO
            UDATE        = SY-DATLO
            USERNAME     = SY-UNAME
            N_ZNFT1030   = LS_ZNFT1030N
            O_ZNFT1030   = LS_ZNFT1030N
            UPD_ZNFT1030 = LV_CDOC_UPD_OBJECT.
      ENDIF.
    ENDLOOP.
  ELSE.
    ROLLBACK WORK.
    EXIT.
  ENDIF.

  MESSAGE S003 DISPLAY LIKE 'S'
     WITH GV_CNT '건의 선물집행 평균가가 입력되었습니다.'.

  PERFORM DATA_RELOAD.

ENDFORM.                    " DATA_SAVE

*&---------------------------------------------------------------------*
*&      Form  DATA_RELOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_RELOAD .

  PERFORM GET_FUTURES_DATA.

*  GS_STBL-ROW = 'X'.
*  GS_STBL-COL = 'X'.
*
*  CALL METHOD GRF_GRID->REFRESH_TABLE_DISPLAY
*    EXPORTING
*      I_SOFT_REFRESH = ' '
*      IS_STABLE      = GS_STBL.     "화면 라인 Refresh

ENDFORM.                    " DATA_RELOAD

*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN_CHECKBOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_SCREEN_CHECKBOX USING PV_ERROR.

* 신규집행번호만 입력한경우
  IF S_NFUTN[] IS NOT INITIAL AND S_CFUTN[] IS INITIAL.
    P_CHK01 = 'X'.
    P_CHK02 = ''.
  ENDIF.

* 청산집행번호만 입력한경우
  IF S_NFUTN[] IS INITIAL AND S_CFUTN[] IS NOT INITIAL.
    P_CHK01 = ''.
    P_CHK02 = 'X'.
  ENDIF.

* 신규&청산 집행번호 모두입력한경우
  IF S_NFUTN[] IS NOT INITIAL AND S_CFUTN[] IS NOT INITIAL.
    P_CHK01 = 'X'.
    P_CHK02 = 'X'.
  ENDIF.

  IF P_CHK01 IS INITIAL AND P_CHK02 IS INITIAL.
    PV_ERROR = 'X'.
  ENDIF.


  IF PV_ERROR IS NOT INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '신규/청산구분을 선택하십시오.'.
  ENDIF.

ENDFORM.                    " MODIFY_SCREEN_CHECKBOX

*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_ALL .

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    IF OK_SAVE = 'ASEL'.
      GS_OUTTAB-CHECK = 'X'.
    ELSE.
      CLEAR : GS_OUTTAB-CHECK.
    ENDIF.
    MODIFY GT_OUTTAB FROM GS_OUTTAB TRANSPORTING CHECK.
  ENDLOOP.

ENDFORM.                    " SELECT_ALL
