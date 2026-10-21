*&---------------------------------------------------------------------*
*&  Include           ZNFR2250F01
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

  CASE SY-DYNNR.
    WHEN 1100.
*     Create Object : GRF_CONTAINER
      CREATE OBJECT GRF_CONTAINER
        EXPORTING
          CONTAINER_NAME = GRF_CONTAINER_NAME.

*     Create Object : GRF_GRID
      CREATE OBJECT GRF_GRID
        EXPORTING
          I_PARENT      = GRF_CONTAINER
          I_APPL_EVENTS = 'X'.
    WHEN 1200.
*     Create Object : GRF_CONTAINER_P
      CREATE OBJECT GRF_CONTAINER_P
        EXPORTING
          CONTAINER_NAME = GRF_CONTAINER_NAME_P.

*     Create Object : GRF_GRID_P
      CREATE OBJECT GRF_GRID_P
        EXPORTING
          I_PARENT      = GRF_CONTAINER_P
          I_APPL_EVENTS = 'X'.
  ENDCASE.

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

  CASE SY-DYNNR.
    WHEN 1100.
      GS_LAYOUT-SEL_MODE   = 'A'.
      GS_LAYOUT-ZEBRA      = 'X'.
      GS_LAYOUT-CWIDTH_OPT = 'X'.
      GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
      GS_LAYOUT-NO_ROWINS  = 'X'.
    WHEN 1200.
      GS_LAYOUT_P-SEL_MODE   = 'A'.
      GS_LAYOUT_P-ZEBRA      = 'X'.
      GS_LAYOUT_P-STYLEFNAME = 'CELLTAB'.
      GS_LAYOUT_P-NUMC_TOTAL = 'X'.
      GS_LAYOUT_P-NO_ROWINS  = 'X'.
      GS_LAYOUT_P-NUMC_TOTAL = 'X'.

*      GS_LAYOUT_P-NO_TOTLINE = 'X'.
*      GS_LAYOUT_P-CWIDTH_OPT = 'X'.
*      GS_LAYOUT_P-NO_UTSPLIT = 'X'.
  ENDCASE.

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

  CASE SY-DYNNR.
    WHEN 1100.

      CLEAR : GS_SORT, GT_SORT.
      REFRESH GT_SORT.

      GS_SORT-SPOS = 1.
      GS_SORT-FIELDNAME = 'NFUTN'.
      GS_SORT-UP = 'X'.
      GS_SORT-COMP = 'X'.
      GS_SORT-SUBTOT = 'X'.
      APPEND GS_SORT TO GT_SORT.

    WHEN 1200.

      CLEAR : GS_SORT_P, GT_SORT_P.
      REFRESH GT_SORT_P.

      GS_SORT_P-SPOS = 1.
      GS_SORT_P-FIELDNAME = 'SEQ'.
      GS_SORT_P-UP = 'X'.
      GS_SORT_P-COMP = 'X'.
*      GS_SORT_P-SUBTOT = 'X'.
      APPEND GS_SORT_P TO GT_SORT_P.

  ENDCASE.

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

  CASE SY-DYNNR.
    WHEN 1100.
      PERFORM SET_FIELDCAT USING:
        'CHECK'           '선택'            '10'     'C'    ' '     ,
        'BUKRS'           '회사코드'        '10'     'C'    ' '     ,
*        'BUKRS_NM'        '회사명'          '10'     'L'    ' '     ,
        'NFUTN'           '신규집행번호'    '10'     'C'    ' '     ,
        'RUDAT'           '집행일'          '10'     'C'    ' '     ,
        'FCM'             'FCM'             '10'     'C'    'ALPHA' ,
        'FCM_NM'          'FCM명'           '10'     'L'    ' '     ,
        'NFKEY'           '비철구분'        '10'     'C'    ' '     ,
*        'NFKEY_NM'        '비철구분'        '18'     'L'    ' '     ,
        'BY_SL'           'Buy/Sell'        '10'     'C'    ' '     ,
        'BY_SL_NM'        'Buy/Sell'        '10'     'L'    ' '     ,
        'ENDAT'           '만기일'          '10'     'C'    ' '     ,
        'MITYP'           '집행유형'        '10'     'C'    ' '     ,
*        'MITYP_NM'        '집행유형'        '10'     'C'    ' '     ,
        'MISPD'           'Spread'          '10'     'C'    ' '     ,
        'MIMON'           '기준월'          '10'     'C'    ' '     ,
        'PRICE'           '집행단가'        '15'     'R'    ' '     ,
        'WAERS'           '통화'            '5'      'C'    ' '     ,
        'EMENG'           '집행수량'        '14'     'R'    ' '     ,
        'MEINS'           '단위'            '10'     'C'    ' '     ,
        'MISUS'           '수수료여부'      '10'     'C'    ' '     ,
*        'MISUS_NM'        '수수료구분'      '10'     'C'    ' '     ,
*        'CONFM'           '결재상태'        '10'     'C'    ' '     ,
        'CONFM_NM'        '결재상태'        '10'     'L'    ' '     ,
        'BIGO4'           '비고'            '20'     'L'    ' '     ,
        'REQNO'           '선물요청번호'    '10'     'L'    ' '     ,
        'H_NO1'           '항번'            '10'     'C'    ' '     ,
        'ENDMM'           '만기월'          '10'     'C'    'PERI'  ,
        'EMENG_R'         '요청수량'        '10'     'R'    ' '     ,
        'MEINS_R'         '단위'            '10'     'C'    ' '     ,
*        'PRCTR'           '손익센터'        '10'     'C'    'ALPHA' ,
        'PTEXT'           '손익센터 명'     '10'     'L'    ' '     ,
        'CONNO'           '계약번호'        '10'     'C'    ' '     ,
        'COTXT'           '계약명'          '20'     'L'    ' '     ,
        'KUNNR'           '고  객'          '10'     'C'    'ALPHA' ,
        'NCUST'           '고객명'          '20'     'L'    ' '     ,
        'PRIND'           '가격구분'        '10'     'C'    ' '     ,
        'SUJUP'           '비철수주가'      '10'     'R'    ' '     .
    WHEN 1200.
      PERFORM SET_FIELDCAT_P USING:
        'CHECK'           '선택'            '4'      'C'    ' '     ,
        'NFTUN'           '신규집행번호'    '10'     'C'    ' '     ,
        'SEQ'             '순번'            '4'      'C'    ' '     ,
        'EMENG'           '집행수량'        '14'     'R'    ' '     ,
        'MEINS'           '단위'            '5'      'C'    ' '     ,
        'BIGO4'           '비고'            '35'     'L'    ' '     .
  ENDCASE.

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
      GS_FIELDCAT-CHECKBOX  = 'X'.
      GS_FIELDCAT-EDIT      = 'X'.
    WHEN 'BY_SL'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'PRICE'.
      GS_FIELDCAT-CFIELDNAME = 'WAERS'.
    WHEN 'EMENG'.
      GS_FIELDCAT-QFIELDNAME = 'MEINS'.
    WHEN 'EMENG_R'.
      GS_FIELDCAT-QFIELDNAME = 'MEINS_R'.
  ENDCASE.

  APPEND GS_FIELDCAT TO GT_FIELDCAT.

ENDFORM.                    " SET_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_P  USING  P_FIELDNAME
                            P_COLTEXT
                            P_OUTPUTLEN
                            P_JUST
                            P_CONVEXIT.

  CLEAR GS_FIELDCAT_P.

  GS_FIELDCAT_P-FIELDNAME  = P_FIELDNAME .
  GS_FIELDCAT_P-COLTEXT    = P_COLTEXT   .
  GS_FIELDCAT_P-OUTPUTLEN  = P_OUTPUTLEN .
  GS_FIELDCAT_P-JUST       = P_JUST      .
  GS_FIELDCAT_P-CONVEXIT   = P_CONVEXIT  .

  CASE P_FIELDNAME.
    WHEN 'CHECK'.
      GS_FIELDCAT_P-CHECKBOX   = 'X'.
      GS_FIELDCAT_P-EDIT       = 'X'.
    WHEN 'NFTUN'.
      GS_FIELDCAT_P-NO_OUT     = 'X'.
    WHEN 'EMENG'.
      GS_FIELDCAT_P-EDIT       = 'X'.
      GS_FIELDCAT_P-QFIELDNAME = 'MEINS'.
      GS_FIELDCAT_P-REF_TABLE  = 'ZNFT1020'.
      GS_FIELDCAT_P-REF_FIELD  = 'EMENG'.
      GS_FIELDCAT_P-DO_SUM     = 'X'.
    WHEN 'BIGO4'.
      GS_FIELDCAT_P-EDIT       = 'X'.
  ENDCASE.

  APPEND GS_FIELDCAT_P TO GT_FIELDCAT_P.

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

  CASE SY-DYNNR.
    WHEN 1100.
      LOOP AT GT_OUTTAB INTO GS_OUTTAB.
        L_INDEX = SY-TABIX.
        REFRESH LT_CELLTAB.
        CLEAR GS_OUTTAB-CELLTAB.
        INSERT LINES OF LT_CELLTAB INTO TABLE GS_OUTTAB-CELLTAB.
        MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX L_INDEX.
      ENDLOOP.
    WHEN 1200.
      LOOP AT GT_DISTRIBUTE INTO GS_DISTRIBUTE.
        L_INDEX = SY-TABIX.
        REFRESH LT_CELLTAB.
        CLEAR GS_DISTRIBUTE-CELLTAB.
        INSERT LINES OF LT_CELLTAB INTO TABLE GS_DISTRIBUTE-CELLTAB.
        MODIFY GT_DISTRIBUTE FROM GS_DISTRIBUTE INDEX L_INDEX.
      ENDLOOP.
  ENDCASE.

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

  CASE SY-DYNNR.
    WHEN 1100.

      CALL METHOD GRF_GRID->REGISTER_EDIT_EVENT
        EXPORTING
          I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

      CREATE OBJECT GRF_EVENT_RECEIVER.
      SET HANDLER :
        GRF_EVENT_RECEIVER->HANDLE_DATA_CHANGED FOR GRF_GRID,
        GRF_EVENT_RECEIVER->HANDLE_DOUBLE_CLICK FOR GRF_GRID.

    WHEN 1200.

      CALL METHOD GRF_GRID_P->REGISTER_EDIT_EVENT
        EXPORTING
          I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

      CREATE OBJECT GRF_EVENT_RECEIVER_P.
      SET HANDLER :
        GRF_EVENT_RECEIVER_P->HANDLE_DATA_CHANGED FOR GRF_GRID_P.

  ENDCASE.

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

  CASE SY-DYNNR.
    WHEN 1100.
*     FieldName별 소트해서 APPEND
      GS_F4-FIELDNAME = 'NFUTN'.
      GS_F4-REGISTER  = 'X'.
      APPEND GS_F4 TO GT_F4.

      CALL METHOD GRF_GRID->REGISTER_F4_FOR_FIELDS
        EXPORTING
          IT_F4 = GT_F4.
    WHEN 1200.
*     FieldName별 소트해서 APPEND
      GS_F4_P-FIELDNAME = 'NFUTN'.
      GS_F4_P-REGISTER  = 'X'.
      APPEND GS_F4_P TO GT_F4_P.

      CALL METHOD GRF_GRID_P->REGISTER_F4_FOR_FIELDS
        EXPORTING
          IT_F4 = GT_F4_P.
  ENDCASE.


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

  CASE SY-DYNNR.
    WHEN 1100.

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

    WHEN 1200.

      GS_VARIANT_P-HANDLE = '0002'.
      GS_VARIANT_P-REPORT = SY-REPID.

      CALL METHOD GRF_GRID_P->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_VARIANT                    = GS_VARIANT_P
          IS_LAYOUT                     = GS_LAYOUT_P
          I_SAVE                        = 'A'
          I_DEFAULT                     = 'X'
          IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE_P
        CHANGING
          IT_FIELDCATALOG               = GT_FIELDCAT_P[]
          IT_SORT                       = GT_SORT_P[]
          IT_OUTTAB                     = GT_DISTRIBUTE[]
          IT_FILTER                     = GT_FILTER_P
        EXCEPTIONS
          INVALID_PARAMETER_COMBINATION = 1
          PROGRAM_ERROR                 = 2
          TOO_MANY_LINES                = 3
          OTHERS                        = 4.

      CALL METHOD GRF_GRID_P->REGISTER_EDIT_EVENT
        EXPORTING
          I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  ENDCASE.

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY

*&---------------------------------------------------------------------*
*&  Include           ZNFR2250F01
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
        DYNAME     = 'ZNFR2250'
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
*&      Form  F4HELP_PRCTR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_PRCTR  USING    PV_PRCTR.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_PRCTR.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_PRCTR.

*___화면상의 데이터를 읽는다.
  SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = 'ZNFR2250'
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
*&      Form  GET_FUTURES_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FUTURES_DATA .

  DATA: LV_ERROR TYPE CHAR01,
        LV_TABIX TYPE SY-TABIX.

  DATA: LV_YNCAN TYPE ZYNCAN,
        LV_CONFM TYPE ZCONFM3.

  DATA: LV_DRSTA TYPE ZDRSTA.

  SELECT
        A~BUKRS
        A~NFUTN
        A~RUDAT
        A~FCM
        A~NFKEY
        A~BY_SL
        A~ENDAT
        A~MITYP
        A~MISPD
        A~MIMON
        A~PRICE
        A~WAERS
        A~EMENG
        A~MEINS
        A~MISUS
        A~CONFM
        A~BIGO4
        C~REQNO
        C~H_NO1
        C~ENDMM
        D~PRCTR
        C~EMENG AS EMENG_R
        C~MEINS AS MEINS_R
        B~RQTYP
        D~CONNO
        D~COTXT
        D~KUNNR
        D~NCUST
        INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB
   FROM ZNFT1020 AS A
        INNER JOIN ZNFT1011 AS C
           ON C~REQNO EQ A~REQNO AND C~H_NO1 EQ A~H_NO1
        INNER JOIN ZNFT1010 AS B
           ON B~REQNO EQ C~REQNO
        INNER JOIN ZNFT1000 AS D
           ON D~CONNO EQ C~CONNO
  WHERE A~BUKRS EQ P_BUKRS
    AND A~NFUTN IN S_NFUTN
    AND A~FCM   IN S_FCM
    AND A~RUDAT IN S_RUDAT
    AND A~NFKEY IN S_NFKEY
    AND A~BY_SL IN S_BY_SL
    AND A~ENDAT IN S_ENDAT
    AND D~PRCTR IN S_PRCTR
    AND A~CONFM IN ('3','7')
    AND A~YNCAN NE 'X'
    AND A~YNNET NE 'X'
    AND A~YNFIN NE 'X'.

  IF GT_OUTTAB IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'S'
       WITH '선택조건에 해당하는 데이터가 존재하지 않습니다.'.
  ELSE.
    CLEAR   GS_OUTTAB.
    LOOP AT GT_OUTTAB INTO GS_OUTTAB.

      LV_TABIX = SY-TABIX.
      PERFORM GET_LIFNR_DESC USING GS_OUTTAB-FCM
                                   GS_OUTTAB-FCM_NM.

*     청산계약(ZNFT1030)에 입력된건 제외
      CLEAR : LV_YNCAN, LV_CONFM.
      SELECT SINGLE YNCAN CONFM INTO (LV_YNCAN, LV_CONFM)
         FROM ZNFT1030
        WHERE NFUTN EQ GS_OUTTAB-NFUTN.

      IF SY-SUBRC EQ 0.
        IF LV_YNCAN EQ 'X' AND ( LV_CONFM EQ '3' OR LV_CONFM EQ '7').
*         삭제된 건중에 승인 또는 수정승인인건은 사용가능
        ELSE.
          DELETE GT_OUTTAB INDEX LV_TABIX.
          CONTINUE.
        ENDIF.
      ENDIF.

*     만기이동 진행상태건(ZNFT1040)에 입력된건 제외
      CLEAR : LV_YNCAN, LV_DRSTA.
      SELECT SINGLE DRSTA YNCAN INTO (LV_DRSTA, LV_YNCAN)
         FROM ZNFT1040
        WHERE OFUTN EQ GS_OUTTAB-NFUTN.

      IF SY-SUBRC EQ 0.
        IF LV_YNCAN EQ 'X' OR LV_DRSTA EQ '7' OR LV_DRSTA EQ '8'.
*         삭제되었거나, 반려, 최종확인된건은 분할가능.
        ELSE.
          DELETE GT_OUTTAB INDEX LV_TABIX.
          CONTINUE.
        ENDIF.
      ENDIF.

*   - 회사코드
      PERFORM GET_BUKRS_DESC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-BUKRS_NM.

*   - 비철구분
      IF GS_OUTTAB-NFKEY IS NOT INITIAL.
        PERFORM DOMAIN_VALUE_GET USING 'ZNFKEY_1'
                                       GS_OUTTAB-NFKEY
                                       GS_OUTTAB-NFKEY_NM.
      ENDIF.

*   - Buy-Sell 구분
      IF GS_OUTTAB-BY_SL IS NOT INITIAL.
        PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                       GS_OUTTAB-BY_SL
                                       GS_OUTTAB-BY_SL_NM.
      ENDIF.

*   - 집행유형
      IF GS_OUTTAB-MITYP IS NOT INITIAL.
        PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                       GS_OUTTAB-MITYP
                                       GS_OUTTAB-MITYP_NM.
      ENDIF.

*   - 매입 수수료 여부
      IF GS_OUTTAB-MISUS IS NOT INITIAL.
        PERFORM DOMAIN_VALUE_GET USING 'ZMISUS'
                                       GS_OUTTAB-MISUS
                                       GS_OUTTAB-MISUS_NM.
      ENDIF.

*   - 결재상태
      IF GS_OUTTAB-CONFM IS NOT INITIAL.
        PERFORM DOMAIN_VALUE_GET USING 'ZCONFM3'
                                       GS_OUTTAB-CONFM
                                       GS_OUTTAB-CONFM_NM.
      ENDIF.

*   - 요청유형
      IF GS_OUTTAB-RQTYP IS NOT INITIAL.
        PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                       GS_OUTTAB-RQTYP
                                       GS_OUTTAB-RQTYP_NM.
      ENDIF.

*   - 고객
      IF GS_OUTTAB-KUNNR IS NOT INITIAL.
        PERFORM GET_KUNNR_DESC USING GS_OUTTAB-KUNNR
                                     GS_OUTTAB-NCUST.
      ENDIF.

*     손익센터
      PERFORM GET_PRCTR_DESC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-PRCTR
                                   GS_OUTTAB-PTEXT.

*   - 가격구분/비철수주가
      PERFORM PRICE_CLASSIFICATION USING GS_OUTTAB-CONNO
                                         GS_OUTTAB-NFKEY
                                         GS_OUTTAB-PRIND
                                         GS_OUTTAB-SUJUP
                                         LV_ERROR.

      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " GET_FUTURES_DATA
*&---------------------------------------------------------------------*
*&      Form  DATA_CHECK_DISTRIBUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_CHECK_DISTRIBUTE USING PV_ERROR.

  DATA: LV_CNT    TYPE I,
        LV_EMENG1 TYPE ZEMENG2,
        LV_EMENG2 TYPE ZEMENG2.

  DATA: LS_OUTTAB LIKE GS_OUTTAB,
        LT_OUTTAB LIKE TABLE OF GS_OUTTAB.

  IF GT_OUTTAB[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '데이터가 존재하지 않습니다.'.
    PV_ERROR = 'X'.
  ELSE.
    CLEAR : LS_OUTTAB. REFRESH : LT_OUTTAB.
    LT_OUTTAB[] = GT_OUTTAB[].

    DELETE LT_OUTTAB WHERE CHECK NE 'X'.

    LV_CNT = LINES( LT_OUTTAB[] ).
    CASE LV_CNT.
      WHEN 0.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '데이터를 선택하십시오'.
        PV_ERROR = 'X'.
      WHEN 1.
        CLEAR GS_DISTRIBUTE. REFRESH GT_DISTRIBUTE.
        READ TABLE LT_OUTTAB INTO LS_OUTTAB INDEX 1.
        IF SY-SUBRC EQ 0.
          MOVE-CORRESPONDING LS_OUTTAB TO GS_DISTRIBUTE.

*           Default 2개의 라인만큼 생성
*             - 1번 라인
          GS_DISTRIBUTE-SEQ   = 1.
          GS_DISTRIBUTE-EMENG = 0.
          APPEND GS_DISTRIBUTE TO GT_DISTRIBUTE.
*             - 2번 라인
          GS_DISTRIBUTE-SEQ   = 2.
          GS_DISTRIBUTE-EMENG = 0.
          APPEND GS_DISTRIBUTE TO GT_DISTRIBUTE.
        ENDIF.

      WHEN OTHERS.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '데이터를 한건만 선택하십시오'.
        PV_ERROR = 'X'.
    ENDCASE.

  ENDIF.

ENDFORM.                    " DATA_CHECK_DISTRIBUTE

*&---------------------------------------------------------------------*
*&      Form  DATA_DISTRIBUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_DISTRIBUTE .

  CALL SCREEN 1200 STARTING AT  10 03
                   ENDING   AT 110 18.

ENDFORM.                    " DATA_DISTRIBUTE

*&---------------------------------------------------------------------*
*&      Form  DATA_ADD_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_ADD_ROW .

  DATA: LV_CNT TYPE I.

  READ TABLE GT_DISTRIBUTE INTO GS_DISTRIBUTE INDEX 1.

  LV_CNT = LINES( GT_DISTRIBUTE[] ) + 1.

  GS_DISTRIBUTE-SEQ   = LV_CNT.
  GS_DISTRIBUTE-EMENG = 0.
  APPEND GS_DISTRIBUTE TO GT_DISTRIBUTE.

ENDFORM.                    " DATA_ADD_ROW
*&---------------------------------------------------------------------*
*&      Form  DATA_DEL_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_DEL_ROW .

  DATA: LV_TABIX TYPE SY-TABIX.

  READ TABLE GT_DISTRIBUTE INTO GS_DISTRIBUTE WITH KEY CHECK = 'X'.

  IF SY-SUBRC EQ 0.
    PERFORM POPUP_TO_CONFIRM USING '삭제'
                                   '선택한 라인을 삭제하시겠습니까?'
                                   '2'
                                   GV_ANSWER.
    IF GV_ANSWER = '1'.
      DELETE GT_DISTRIBUTE WHERE CHECK = 'X'.
      MESSAGE S003 WITH '삭제되었습니다.'.
*     의미없는 순번 재계산
      LOOP AT GT_DISTRIBUTE INTO GS_DISTRIBUTE.
        LV_TABIX = SY-TABIX.
        GS_DISTRIBUTE-SEQ = LV_TABIX.
        MODIFY GT_DISTRIBUTE FROM GS_DISTRIBUTE INDEX LV_TABIX.
      ENDLOOP.
    ELSE.
      MESSAGE S003 WITH '작업이 취소되었습니다.'.
    ENDIF.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 라인이 없습니다.'.
  ENDIF.

ENDFORM.                    " DATA_DEL_ROW
*&---------------------------------------------------------------------*
*&      Form  DATA_SAVE_DISTRIBUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SAVE_DISTRIBUTE .

  DATA: LS_ZNFT1020   TYPE ZNFT1020,
        LS_ZNFT1020_N TYPE ZNFT1020,
        LS_ZNFT1020_O TYPE ZNFT1020,
        LS_ZNFT1020_C TYPE ZNFT1020,
        LT_ZNFT1020   LIKE TABLE OF LS_ZNFT1020.

  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND,
        LV_UPD_ICDTXT      TYPE CHAR1,
        LV_CONFM           TYPE ZCONFM,
        LV_NFUTN_LOW       TYPE ZFUTNO,
        LV_NFUTN_HIGH      TYPE ZFUTNO,
        LV_CNT             TYPE I,
        LV_RTN_MSG         TYPE CHAR100.

* 신규선물집행-분할 데이터 삭제로직
  SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZNFT1020_O
    FROM ZNFT1020
   WHERE NFUTN EQ GS_DISTRIBUTE-NFUTN.

  IF SY-SUBRC EQ 0.
    MOVE-CORRESPONDING LS_ZNFT1020_O TO LS_ZNFT1020_N.

    LV_CONFM = LS_ZNFT1020_O-CONFM.
    LS_ZNFT1020_N-YNCAN = 'X'.
    LS_ZNFT1020_N-WHYCN = '2'.
    LS_ZNFT1020_N-CONFM = '7'.
    LS_ZNFT1020_N-AENAM = SY-UNAME.
    LS_ZNFT1020_N-AEDAT = SY-DATLO.
    LS_ZNFT1020_N-AEZET = SY-TIMLO.
  ENDIF.

  MODIFY ZNFT1020 FROM LS_ZNFT1020_N.

  IF SY-SUBRC EQ 0.

*   신규선물집행-분할 데이터 생성
    LOOP AT GT_DISTRIBUTE INTO GS_DISTRIBUTE.
      CLEAR : LS_ZNFT1020.
      MOVE-CORRESPONDING LS_ZNFT1020_O TO LS_ZNFT1020.
      PERFORM GET_SNRO_OBJECT_NO USING '10'
                                       'ZNF2_00003'
                                       LS_ZNFT1020-NFUTN.
      LS_ZNFT1020-YNCAN = ''.
      LS_ZNFT1020-WHYCN = ''.
      LS_ZNFT1020-CONFM = LV_CONFM.
      LS_ZNFT1020-EMENG = GS_DISTRIBUTE-EMENG.
      LS_ZNFT1020-MEINS = GS_DISTRIBUTE-MEINS.
*     이력번호
      LS_ZNFT1020-OLDFT = GS_DISTRIBUTE-NFUTN.
      LS_ZNFT1020-BIGO4 = GS_DISTRIBUTE-BIGO4.
      LS_ZNFT1020-ERNAM = SY-UNAME.
      LS_ZNFT1020-ERDAT = SY-DATLO.
      LS_ZNFT1020-ERZET = SY-TIMLO.
      LS_ZNFT1020-AENAM = SY-UNAME.
      LS_ZNFT1020-AEDAT = SY-DATLO.
      LS_ZNFT1020-AEZET = SY-TIMLO.
      APPEND LS_ZNFT1020 TO LT_ZNFT1020.
    ENDLOOP.

    MODIFY ZNFT1020 FROM TABLE LT_ZNFT1020.

    IF SY-SUBRC EQ 0.
      COMMIT WORK.
*     ==================================================================
*      - 1. 삭제데이터 변경이력 반영
*      - 2. 신규데이터 변경이력 반영
*     ==================================================================
*     1.기존 데이터 삭제
      LV_OBJECTID        = GS_DISTRIBUTE-NFUTN.
      LV_TCODE           = SY-TCODE.
      LV_CDOC_UPD_OBJECT = 'D'.

      CALL FUNCTION 'ZNFT1020CHDOC_WRITE_DOCUMENT'
        EXPORTING
          OBJECTID     = LV_OBJECTID
          TCODE        = LV_TCODE
          UTIME        = SY-TIMLO
          UDATE        = SY-DATLO
          USERNAME     = SY-UNAME
          N_ZNFT1020   = LS_ZNFT1020_N
          O_ZNFT1020   = LS_ZNFT1020_O
          UPD_ZNFT1020 = LV_CDOC_UPD_OBJECT.

      IF SY-SUBRC EQ 0.
      ENDIF.

*     2.분할수량 신규생성로그
      CLEAR : LS_ZNFT1020, LS_ZNFT1020_C.
      LOOP AT LT_ZNFT1020 INTO LS_ZNFT1020.

        LV_OBJECTID        = LS_ZNFT1020-NFUTN.
        LV_TCODE           = SY-TCODE.
        LV_CDOC_UPD_OBJECT = 'I'.

        CALL FUNCTION 'ZNFT1020CHDOC_WRITE_DOCUMENT'
          EXPORTING
            OBJECTID     = LV_OBJECTID
            TCODE        = LV_TCODE
            UTIME        = SY-TIMLO
            UDATE        = SY-DATLO
            USERNAME     = SY-UNAME
            N_ZNFT1020   = LS_ZNFT1020
            O_ZNFT1020   = LS_ZNFT1020_C
            UPD_ZNFT1020 = LV_CDOC_UPD_OBJECT.

        IF SY-SUBRC EQ 0.
        ENDIF.

      ENDLOOP.

*     ==================================================================
      READ TABLE LT_ZNFT1020 INTO LS_ZNFT1020 INDEX 1.
      IF SY-SUBRC EQ 0.
        LV_NFUTN_LOW = LS_ZNFT1020-NFUTN.
      ENDIF.

      LV_CNT = LINES( LT_ZNFT1020 ).
      READ TABLE LT_ZNFT1020 INTO LS_ZNFT1020 INDEX LV_CNT.
      IF SY-SUBRC EQ 0.
        LV_NFUTN_HIGH = LS_ZNFT1020-NFUTN.
      ENDIF.
      CONCATENATE '[' LV_NFUTN_LOW ' ~ ' LV_NFUTN_HIGH ']'
                  ' 번호로 분할되었습니다.'
             INTO LV_RTN_MSG.

      CLEAR LV_CNT.
      LV_CNT = LINES( GT_OUTTAB ).
      IF LV_CNT EQ 1.
        MESSAGE I003 DISPLAY LIKE 'S' WITH LV_RTN_MSG.
      ELSE.
        MESSAGE S003 DISPLAY LIKE 'S' WITH LV_RTN_MSG.
      ENDIF.
      GV_SAVED = 'X'.
    ELSE.
      ROLLBACK WORK.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '데이터저장에 실패하였습니다.'.
      EXIT.
    ENDIF.

  ENDIF.

ENDFORM.                    " DATA_SAVE_DISTRIBUTE

*&---------------------------------------------------------------------*
*&      Form  CHECK_SUM_QTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_DISTRIBUTE_NFUTN  text
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM CHECK_SUM_QTY  USING  PV_NFUTN
                           PV_ERROR1.

  DATA: LV_UNIT    TYPE MEINS,
        LV_QTY     TYPE ZEMENG2,
        LV_QTY_C   TYPE CHAR15,
        LV_SUM_QTY TYPE ZEMENG2,
        LV_SUM_C   TYPE CHAR15,
        LV_RTN_MSG TYPE CHAR100.

* ==========================================================
* 1. 수량이 0인건 체크
* ==========================================================
  READ TABLE GT_DISTRIBUTE INTO GS_DISTRIBUTE WITH KEY EMENG = 0.
  IF SY-SUBRC EQ 0.
    MESSAGE I003 DISPLAY LIKE 'E'
                 WITH '순번' GS_DISTRIBUTE-SEQ '의 수량이 0입니다'.
    PV_ERROR1 = 'X'.
    EXIT.
  ENDIF.

* ==========================================================
* 2. 집행수량 = 분할총수량 체크
* ==========================================================
  CLEAR : LV_QTY, LV_SUM_QTY.
  LOOP AT GT_DISTRIBUTE INTO GS_DISTRIBUTE.
    ADD GS_DISTRIBUTE-EMENG TO LV_SUM_QTY.
  ENDLOOP.

  SELECT SINGLE EMENG MEINS INTO (LV_QTY, LV_UNIT)
    FROM ZNFT1020
   WHERE NFUTN EQ PV_NFUTN.

  IF LV_QTY NE LV_SUM_QTY.
    CLEAR LV_RTN_MSG.
*   소숫점제거
    WRITE : LV_QTY      UNIT LV_UNIT TO LV_QTY_C,
            LV_SUM_QTY  UNIT LV_UNIT TO LV_SUM_C.
    CONDENSE: LV_QTY_C NO-GAPS,
              LV_SUM_C NO-GAPS.
    CONCATENATE '집행수량(' LV_QTY_C ')과 분할수량총합('
                            LV_SUM_C ')이 다릅니다.'
                INTO LV_RTN_MSG.
    MESSAGE I003 DISPLAY LIKE 'E'  WITH LV_RTN_MSG.
    PV_ERROR1 = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_SUM_QTY

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
  LOOP AT P_DATA_CHANGED->MT_MOD_CELLS INTO LS_MOD_CELLS.
    LV_INDEX = LS_MOD_CELLS-ROW_ID.

*   Data 가공용 Structure
    CASE SY-DYNNR.
      WHEN '1100'.
        READ TABLE GT_OUTTAB     INTO GS_OUTTAB     INDEX LV_INDEX.

        IF SY-SUBRC EQ 0.
          CASE LS_MOD_CELLS-FIELDNAME.
            WHEN 'CHECK'.
              IF LS_MOD_CELLS-VALUE EQ 'X'.
                GS_OUTTAB-CHECK = 'X'.
              ELSE.
                GS_OUTTAB-CHECK = ''.
              ENDIF.
              MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX
                               TRANSPORTING CHECK.
          ENDCASE.
        ENDIF.

      WHEN '1200'.
        READ TABLE GT_DISTRIBUTE INTO GS_DISTRIBUTE INDEX LV_INDEX.

        IF SY-SUBRC EQ 0.
          CASE LS_MOD_CELLS-FIELDNAME.
            WHEN 'EMENG'.
*             소수점 체크
              IF LS_MOD_CELLS-VALUE CA '.'.
                MESSAGE I003 DISPLAY LIKE 'E'
                   WITH '소수점은 입력하실 수 없습니다.'.
                EXIT.
              ENDIF.

*             분할수량값 체크
              IF LS_MOD_CELLS-VALUE LE 0.
                MESSAGE S003 DISPLAY LIKE 'E'
                   WITH '분할수량이 0보다 작습니다.'.
                EXIT.
              ENDIF.
              GS_DISTRIBUTE-EMENG = LS_MOD_CELLS-VALUE.
              MODIFY GT_DISTRIBUTE FROM GS_DISTRIBUTE INDEX LV_INDEX
                                   TRANSPORTING EMENG.
            WHEN 'BIGO4'.
              GS_DISTRIBUTE-BIGO4 = LS_MOD_CELLS-VALUE.
              MODIFY GT_DISTRIBUTE FROM GS_DISTRIBUTE INDEX LV_INDEX
                                   TRANSPORTING BIGO4.
          ENDCASE.
        ENDIF.

    ENDCASE.

  ENDLOOP.

ENDFORM.                    "ALV_EVENT_DATA_CHANGED

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
        ENDIF.
      WHEN 'REQNO'.
        IF NOT GS_OUTTAB-REQNO IS INITIAL.
          SET PARAMETER ID 'ZNFREQ' FIELD GS_OUTTAB-REQNO.
          CALL TRANSACTION 'ZNF2M2103' AND SKIP FIRST SCREEN.
        ENDIF.
      WHEN 'NFUTN'.
        IF NOT GS_OUTTAB-NFUTN IS INITIAL.
          PERFORM CALL_NFUTN_PGM USING GS_OUTTAB-NFUTN.
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
*&      Form  DATA_CHECK_DISTRIBUTE_POPUP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM DATA_CHECK_DISTRIBUTE_POPUP  USING  PV_ERROR.

  CALL METHOD GRF_GRID_P->CHECK_CHANGED_DATA.

  READ TABLE GT_DISTRIBUTE INTO GS_DISTRIBUTE WITH KEY CHECK = 'X'.

* 원본 수량 & 분할수량 SUM값 체크
  CLEAR PV_ERROR.
  PERFORM CHECK_SUM_QTY USING GS_DISTRIBUTE-NFUTN
                              PV_ERROR.

ENDFORM.                    " DATA_CHECK_DISTRIBUTE_POPUP
*&---------------------------------------------------------------------*
*&      Form  GET_SNRO_OBJECT_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_SNRO_OBJECT_NO USING PV_NUM_RANGE
                              PV_OBJECT
                              PV_NUMBER.

  CLEAR : PV_NUMBER.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = PV_NUM_RANGE
      OBJECT                  = PV_OBJECT
    IMPORTING
      NUMBER                  = PV_NUMBER
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

ENDFORM.                    " GET_SNRO_OBJECT_NO
