*&---------------------------------------------------------------------*
*&  Include           ZNFR2690_F01
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
        DYNAME     = 'ZNFR2470'
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
        ENDIF.
      WHEN 'NFUTN'.
        IF NOT GS_OUTTAB-NFUTN IS INITIAL.
          PERFORM CALL_NFUTN_PGM USING GS_OUTTAB-NFUTN.
        ENDIF.
      WHEN 'CFUTN'.
        IF NOT GS_OUTTAB-CFUTN IS INITIAL.
          PERFORM CALL_CFUTN_PGM USING GS_OUTTAB-CFUTN.
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
    'BUKRS'        '회사코드'           '10'   'C'   ' '     ,
    'NFUTN'        '신규선물집행번호'   '10'   'L'   ' '     ,
    'N_NFKEY'      '신규비철구분'       '10'   'C'   ' '     ,
    'N_RUDAT'      '신규집행일'         '10'   'C'   ' '     ,
    'N_FCM'        '신규FCM'            '5'    'C'   'ALPHA' ,
    'N_FCM_NM'     '신규FCM명'          '20'   'L'   ' '     ,
    'N_BY_SL'      '신규Buy-Sell'       '10'   'C'   ' '     ,
    'N_BY_SL_NM'   '신규Buy-Sell'       '10'   'C'   ' '     ,
    'N_ENDAT'      '신규만기일'         '10'   'C'   ' '     ,
    'N_MITYP'      '신규집행유형'       '10'   'C'   ' '     ,
    'N_MITYP_NM'   '신규집행유형'       '10'   'C'   ' '     ,
    'N_MISPD'      '신규Spread'         '10'   'R'   ' '     ,
    'N_MIMON'      '신규매입기준월'     '8'    'C'   ' '     ,
    'N_PRICE'      '신규집행단가'       '10'   'R'   ' '     ,
    'N_WAERS'      '신규통화'           '5'    'C'   ' '     ,
    'N_EMENG'      '신규집행수량'       '10'   'R'   ' '     ,
    'N_MEINS'      '신규단위'           '10'   'C'   ' '     ,
    'N_MISUS'      '신규수수료'         '8'    'C'   ' '     ,
    'N_CONFM'      '신규결재상태'       '1'    'C'   ' '     ,
    'N_CFMTX'      '신규결재상태'       '10'   'C'   ' '     ,
    'CFUTN'        '청산선물집행번호'   '10'   'L'   ' '     ,
    'C_NFKEY'      '청산비철구분'       '10'   'C'   ' '     ,
    'C_RUDAT'      '청산집행일'         '10'   'C'   ' '     ,
    'C_FCM'        '청산FCM'            '5'    'C'   'ALPHA' ,
    'C_FCM_NM'     '청산FCM명'          '20'   'L'   ' '     ,
    'C_BY_SL'      '청산Buy-Sell'       '10'   'C'   ' '     ,
    'C_BY_SL_NM'   '청산Buy-Sell'       '10'   'C'   ' '     ,
    'C_ENDAT'      '청산만기일'         '10'   'C'   ' '     ,
    'C_MITYP'      '청산집행유형'       '10'   'C'   ' '     ,
    'C_MITYP_NM'   '청산집행유형'       '10'   'C'   ' '     ,
    'C_MISPD'      '청산Spread'         '10'   'R'   ' '     ,
    'C_MIMON'      '청산매입기준월'     '8'    'C'   ' '     ,
    'C_PRICE'      '청산집행단가'       '10'   'R'   ' '     ,
    'C_WAERS'      '청산통화'           '5'    'C'   ' '     ,
    'C_EMENG'      '청산집행수량'       '10'   'R'   ' '     ,
    'C_MEINS'      '청산단위'           '10'   'C'   ' '     ,
    'C_MISUS'      '청산수수료'         '8'    'C'   ' '     ,
    'C_CONFM'      '청산결재상태'       '1'    'C'   ' '     ,
    'C_CFMTX'      '청산결재상태'       '10'   'C'   ' '     ,
    'REQNO'        '선물요청번호'       '10'   'C'   ' '     ,
    'H_NO1'        '항번'               '10'   'C'   ' '     ,
    'ERDAT'        '요청일자'           '20'   'L'   ' '     ,
    'EMENG'        '요청수량'           '10'   'R'   ' '     ,
    'RQTYP'        '요청유형'           '10'   'C'   ' '     ,
    'RQTYP_NM'     '요청유형'           '10'   'C'   ' '     ,
    'RSTAT'        '요청결제상태'       '10'   'C'   ' '     ,
    'RSTAT_NM'     '요청결제상태'       '10'   'C'   ' '     ,
    'CONNO'        '계약번호'           '10'   'L'   ' '     ,
    'COTXT'        '계약명'             '10'   'L'   ' '     ,
    'COTYP'        '계약유형'           '10'   'C'   ' '     ,
    'COTYP_NM'     '계약유형'           '10'   'C'   ' '     ,
    'NFCTR'        '사업부'             '10'   'C'   'ALPHA' ,
    'NFCTR_NM'     '사업부명'           '10'   'L'   ' '     ,
    'PRCTR'        '손익센터'           '10'   'C'   'ALPHA' ,
    'PTEXT'        '손익센터명'         '20'   'L'   ' '     ,
    'VKGRP'        '영업그룹'           '10'   'C'   ' '     ,
    'VKGRP_NM'     '영업그룹명'         '10'   'L'   ' '     ,
    'KUNNR'        '고  객'             '10'   'C'   'ALPHA' ,
    'NCUST'        '고객명'             '20'   'L'   ' '     ,
    'SALER'        '영업담당자'         '10'   'C'   ' '     .

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

  GS_FIELDCAT-TABNAME    = 'GT_OUTTAB'.
  GS_FIELDCAT-FIELDNAME  = P_FIELDNAME .
  GS_FIELDCAT-COLTEXT    = P_COLTEXT   .
  GS_FIELDCAT-OUTPUTLEN  = P_OUTPUTLEN .
  GS_FIELDCAT-JUST       = P_JUST      .
  GS_FIELDCAT-CONVEXIT   = P_CONVEXIT  .

  CASE P_FIELDNAME.
    WHEN 'N_MITYP'OR 'N_BY_SL'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'C_MITYP'OR 'C_BY_SL'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'N_CONFM'OR 'C_CONFM'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'RQTYP'OR 'RSTAT' OR 'COTYP'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'N_PRICE' OR 'N_MISPD'.
      GS_FIELDCAT-CFIELDNAME = 'N_WAERS'.
      GS_FIELDCAT-DATATYPE   = 'CURR'.
    WHEN 'C_PRICE' OR 'C_MISPD'.
      GS_FIELDCAT-CFIELDNAME = 'C_WAERS'.
      GS_FIELDCAT-DATATYPE   = 'CURR'.
    WHEN 'N_EMENG'.
      GS_FIELDCAT-QFIELDNAME = 'N_MEINS'.
      GS_FIELDCAT-DATATYPE   = 'QUAN'.
    WHEN 'C_EMENG'.
      GS_FIELDCAT-QFIELDNAME = 'C_MEINS'.
      GS_FIELDCAT-DATATYPE   = 'QUAN'.
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

  DATA: LV_TABIX TYPE SY-TABIX.

  DATA: LV_REQLOG TYPE CHAR100,
        LV_EXELOG TYPE CHAR100.

  DATA: LV_RED_CHK TYPE CHAR01,
        LV_YLW_CHK TYPE CHAR01.

  IF S_CFUTN[] IS INITIAL.

    SELECT Z1~BUKRS AS BUKRS

           Z1~YNCAN AS N_YNCAN
           Z1~CONFM AS N_CONFM

           Z1~NFUTN AS NFUTN
           Z1~NFKEY AS N_NFKEY
           Z1~RUDAT AS N_RUDAT
           Z1~FCM   AS N_FCM
           Z1~BY_SL AS N_BY_SL
           Z1~ENDAT AS N_ENDAT
           Z1~MITYP AS N_MITYP
           Z1~MISPD AS N_MISPD
           Z1~MIMON AS N_MIMON
           Z1~PRICE AS N_PRICE
           Z1~WAERS AS N_WAERS
           Z1~EMENG AS N_EMENG
           Z1~MEINS AS N_MEINS
           Z1~MISUS AS N_MISUS

           Z2~REQNO AS REQNO
           Z3~H_NO1 AS H_NO1
           Z2~RQTYP AS RQTYP
           Z2~RSTAT AS RSTAT
           Z3~EMENG AS EMENG
           Z2~ERDAT AS ERDAT
           Z4~CONNO AS CONNO
           Z4~COTXT AS COTXT
           Z4~NFCTR AS NFCTR
           Z4~COTYP AS COTYP
           Z4~PRCTR AS PRCTR
           Z4~VKGRP AS VKGRP
           Z4~KUNNR AS KUNNR
           Z4~NCUST
           Z4~CSTAT
           Z4~SALER
           INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB
      FROM ZNFT1020 AS Z1
           INNER JOIN ZNFT1011 AS Z3
              ON Z3~REQNO EQ Z1~REQNO AND Z3~H_NO1 EQ Z1~H_NO1
           INNER JOIN ZNFT1010 AS Z2
              ON Z2~REQNO EQ Z3~REQNO
           INNER JOIN ZNFT1000 AS Z4
              ON Z4~CONNO EQ Z3~CONNO
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~NFUTN IN S_NFUTN
       AND Z1~FCM   IN S_FCM
       AND Z1~RUDAT IN S_RUDAT
       AND Z1~ENDAT IN S_ENDAT
       AND Z1~NFKEY IN S_NFKEY
       AND Z1~ENDAT IN S_ENDAT
       AND Z2~REQNO IN S_REQNO
       AND Z2~RQTYP IN R_RQTYP
       AND Z2~ERDAT IN S_ERDAT
       AND Z4~PRCTR IN S_PRCTR
       AND Z4~NFCTR IN S_NFCTR.

  ELSE.

    SELECT Z1~BUKRS AS BUKRS

           Z1~YNCAN AS N_YNCAN
           Z1~CONFM AS N_CONFM

           Z1~NFUTN AS NFUTN
           Z1~NFKEY AS N_NFKEY
           Z1~RUDAT AS N_RUDAT
           Z1~FCM   AS N_FCM
           Z1~BY_SL AS N_BY_SL
           Z1~ENDAT AS N_ENDAT
           Z1~MITYP AS N_MITYP
           Z1~MISPD AS N_MISPD
           Z1~MIMON AS N_MIMON
           Z1~PRICE AS N_PRICE
           Z1~WAERS AS N_WAERS
           Z1~EMENG AS N_EMENG
           Z1~MEINS AS N_MEINS
           Z1~MISUS AS N_MISUS

           Z2~REQNO AS REQNO
           Z3~H_NO1 AS H_NO1
           Z2~RQTYP AS RQTYP
           Z2~RSTAT AS RSTAT
           Z3~EMENG AS EMENG
           Z2~ERDAT AS ERDAT
           Z4~CONNO AS CONNO
           Z4~COTXT AS COTXT
           Z4~NFCTR AS NFCTR
           Z4~COTYP AS COTYP
           Z4~PRCTR AS PRCTR
           Z4~VKGRP AS VKGRP
           Z4~KUNNR AS KUNNR
           Z4~NCUST
           Z4~CSTAT
           Z4~SALER
           INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB
      FROM ZNFT1020 AS Z1
           INNER JOIN ZNFT1011 AS Z3
              ON Z3~REQNO EQ Z1~REQNO AND Z3~H_NO1 EQ Z1~H_NO1
           INNER JOIN ZNFT1010 AS Z2
              ON Z2~REQNO EQ Z3~REQNO
           INNER JOIN ZNFT1000 AS Z4
              ON Z4~CONNO EQ Z3~CONNO
           INNER JOIN ZNFT1030 AS Z5
              ON Z1~NFUTN EQ Z5~NFUTN
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~NFUTN IN S_NFUTN
       AND Z1~FCM   IN S_FCM
       AND Z1~RUDAT IN S_RUDAT
       AND Z1~ENDAT IN S_ENDAT
       AND Z1~NFKEY IN S_NFKEY
       AND Z1~ENDAT IN S_ENDAT
       AND Z2~RQTYP IN R_RQTYP
       AND Z5~CFUTN IN S_CFUTN
       AND Z2~REQNO IN S_REQNO
       AND Z2~ERDAT IN S_ERDAT
       AND Z4~PRCTR IN S_PRCTR
       AND Z4~NFCTR IN S_NFCTR.

  ENDIF.

  IF SY-SUBRC EQ 0 AND GT_OUTTAB IS NOT INITIAL.

*   ZNFT1020(신규)건이 삭제이면서 승인된건 제외
    DELETE GT_OUTTAB
     WHERE ( N_YNCAN EQ 'X' AND ( N_CONFM EQ '3' OR N_CONFM EQ '7' ) ).

    SORT GT_OUTTAB BY NFUTN.

    CLEAR : LV_REQLOG,  LV_EXELOG.
    CLEAR : LV_RED_CHK, LV_YLW_CHK.

    LOOP AT GT_OUTTAB INTO GS_OUTTAB.

      LV_TABIX = SY-TABIX.

*.....신규집행내역으로 청산집행내역조회시 유효한 청산내역을 가져오도록
*     check하는 SQL 조건절 수정(EDB03)
*     (C20120831_74728/Req.by박선아-2012/09/03)
      SELECT SINGLE
             CFUTN
             NFKEY
             RUDAT
             FCM
             BY_SL
             ENDAT
             MITYP
             MISPD
             MIMON
             PRICE
             WAERS
             EMENG
             MEINS
             MISUS
             YNCAN
             CONFM
        INTO (GS_OUTTAB-CFUTN,
              GS_OUTTAB-C_NFKEY,
              GS_OUTTAB-C_RUDAT,
              GS_OUTTAB-C_FCM,
              GS_OUTTAB-C_BY_SL,
              GS_OUTTAB-C_ENDAT,
              GS_OUTTAB-C_MITYP,
              GS_OUTTAB-C_MISPD,
              GS_OUTTAB-C_MIMON,
              GS_OUTTAB-C_PRICE,
              GS_OUTTAB-C_WAERS,
              GS_OUTTAB-C_EMENG,
              GS_OUTTAB-C_MEINS,
              GS_OUTTAB-C_MISUS,
              GS_OUTTAB-C_YNCAN,
              GS_OUTTAB-C_CONFM)
         FROM ZNFT1030
        WHERE BUKRS EQ GS_OUTTAB-BUKRS
          AND NFUTN EQ GS_OUTTAB-NFUTN
          AND ( YNCAN NE 'X' OR ( CONFM NE '3' AND CONFM NE '7' ) )
          AND YNNET IN R_YNNET.

      IF SY-SUBRC <> 0.
        CLEAR : GS_OUTTAB-CFUTN,
                GS_OUTTAB-C_RUDAT,
                GS_OUTTAB-C_FCM,
                GS_OUTTAB-C_BY_SL,
                GS_OUTTAB-C_ENDAT,
                GS_OUTTAB-C_MITYP,
                GS_OUTTAB-C_MISPD,
                GS_OUTTAB-C_MIMON,
                GS_OUTTAB-C_PRICE,
                GS_OUTTAB-C_WAERS,
                GS_OUTTAB-C_EMENG,
                GS_OUTTAB-C_MEINS,
                GS_OUTTAB-C_MISUS,
                GS_OUTTAB-C_YNCAN,
                GS_OUTTAB-C_CONFM.
      ENDIF.

*     손익센터
      PERFORM GET_PRCTR_DESC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-PRCTR
                                   GS_OUTTAB-PTEXT.

*     FCM
      PERFORM GET_LIFNR_DESC USING GS_OUTTAB-N_FCM
                                   GS_OUTTAB-N_FCM_NM.

      PERFORM GET_LIFNR_DESC USING GS_OUTTAB-C_FCM
                                   GS_OUTTAB-C_FCM_NM.

*     Buy / Sell
      PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                     GS_OUTTAB-N_BY_SL
                                     GS_OUTTAB-N_BY_SL_NM.

*     Buy / Sell
      PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                     GS_OUTTAB-C_BY_SL
                                     GS_OUTTAB-C_BY_SL_NM.

*     집행유형
      PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                     GS_OUTTAB-N_MITYP
                                     GS_OUTTAB-N_MITYP_NM.

      PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                     GS_OUTTAB-C_MITYP
                                     GS_OUTTAB-C_MITYP_NM.

*     요청유형
      PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                     GS_OUTTAB-RQTYP
                                     GS_OUTTAB-RQTYP_NM.

*     요청-결재상태
      PERFORM DOMAIN_VALUE_GET USING 'ZRSTAT'
                                     GS_OUTTAB-RSTAT
                                     GS_OUTTAB-RSTAT_NM.

*     계약유형
      PERFORM DOMAIN_VALUE_GET USING 'ZCOTYP'
                                     GS_OUTTAB-COTYP
                                     GS_OUTTAB-COTYP_NM.

*     고객
      IF GS_OUTTAB-KUNNR IS NOT INITIAL.
        PERFORM GET_KUNNR_DESC USING GS_OUTTAB-KUNNR
                                     GS_OUTTAB-NCUST.
      ENDIF.

*   - 사업부
      PERFORM GET_NFCTR_DESC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-NFCTR
                                   GS_OUTTAB-NFCTR_NM.

*   - 영업그룹
      PERFORM GET_VKGRP_DESC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-VKGRP
                                   GS_OUTTAB-VKGRP_NM.

*     결재상태
      PERFORM DOMAIN_VALUE_GET USING: 'ZCONFM3'
                                      GS_OUTTAB-N_CONFM
                                      GS_OUTTAB-N_CFMTX,

                                      'ZCONFM3'
                                      GS_OUTTAB-C_CONFM
                                      GS_OUTTAB-C_CFMTX.

*     변경사항 저장
      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.

      CLEAR : LV_TABIX,
              LV_REQLOG,  LV_EXELOG,
              LV_RED_CHK, LV_YLW_CHK,
              GS_OUTTAB.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " DATA_SELECT
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SELECTED_ROWS .

  CALL METHOD GRF_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROWS.

  CALL METHOD GRF_GRID->GET_SELECTED_COLUMNS
    IMPORTING
      ET_INDEX_COLUMNS = GT_COLS.

ENDFORM.                    " GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECT_RADIO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_SELECT_RADIO .

  CLEAR : R_RQTYP. REFRESH R_RQTYP.
  CLEAR : R_YNNET. REFRESH R_YNNET.

  IF P_R02 EQ 'X'.
    R_RQTYP-LOW    = '4'.
    R_RQTYP-HIGH   = SPACE.
    R_RQTYP-SIGN   = 'E'.
    R_RQTYP-OPTION = 'EQ'.
    APPEND R_RQTYP.
  ENDIF.

  IF P_R12 EQ 'X'.
    R_YNNET-LOW    = 'X'.
    R_YNNET-HIGH   = SPACE.
    R_YNNET-SIGN   = 'E'.
    R_YNNET-OPTION = 'EQ'.
    APPEND R_YNNET.
  ENDIF.

ENDFORM.                    " CHECK_SELECT_RADIO
