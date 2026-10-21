*&---------------------------------------------------------------------*
*&  Include           ZNFR2620F01
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
        DYNAME     = 'ZNFR2620'
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

  PERFORM SET_FIELDCAT USING:
    'BUKRS'    '회사코드'         '10'   'C'   ' '     ,
    'SHFNO'    '만기이동요청번호' '10'   'L'   ' '     ,
    'H_NO1'    '항번'             '10'   'C'   ' '     ,
    'SHFCNT'   '만기이동차수'     '5'    'C'   ' '     ,
    'DRSTA'    '결재상태'         '10'   'C'   ' '     ,
    'DRSTA_NM' '결재상태'         '10'   'C'   ' '     ,
    'ERDAT'    '요청일'           '10'   'C'   ' '     ,
    'REMON'    '요청만기월'       '8'    'C'   ' '     ,
    'RMENG'    '요청수량'         '10'   'R'   ' '     ,
    'MEINS'    '단위'             '10'   'C'   ' '     ,
    'NFUTN'    '집행번호(이동후)' '10'   'L'   ' '     ,
    'CFUTN'    '청산선물(이동후)' '10'   'L'   ' '     , "--> [CHM2507-00010] 청산선물컬럼 추가
    'RUDAT'    '신규집행일'       '10'   'C'   ' '     ,
    'ENDAT'    '신규만기일'       '10'   'C'   ' '     ,
    'MISPD'    '신규Spread'       '10'   'R'   ' '     ,
    'PRICE'    '신규단가'         '10'   'R'   ' '     ,
    'WAERS'    '통화'             '5'    'C'   ' '     ,
    'GUBUN'    '생성구분'         '5'    'C'   ' '     ,
    'GUBUN_NM' '생성구분'         '14'   'L'   ' '     ,
    'FCM'      'FCM'              '5'    'C'   'ALPHA' ,
    'FCM_NM'   'FCM명'            '20'   'L'   ' '     ,
    'OFUTN'    '집행번호(이동전)' '10'   'L'   ' '     ,
    'CFUTN_O'  '청산선물(이동전)' '10'   'L'   ' '     , "--> [CHM2507-00010] 청산선물컬럼 추가
    'RUDAT1'   '집행일'           '10'   'C'   ' '     ,
    'NFKEY'    '비철구분'         '10'   'C'   ' '     ,
    'BY_SL'    'Buy-Sell'         '10'   'C'   ' '     ,
    'BY_SL_NM' 'Buy-Sell'         '10'   'C'   ' '     ,
    'ENDAT1'   '만기일'           '10'   'C'   ' '     ,
    'MITYP'    '집행유형'         '10'   'C'   ' '     ,
    'MITYP_NM' '집행유형'         '10'   'C'   ' '     ,
    'MISPD1'   'Spread'           '10'   'R'   ' '     ,
    'MIMON'    '기준월'           '8'    'C'   ' '     ,
    'PRICE1'   '신규단가'         '10'   'R'   ' '     ,
    'WAERS1'   '통화'             '5'    'C'   ' '     ,
    'EMENG'    '집행수량'         '10'   'R'   ' '     ,
    'MEINS'    '단위'             '10'   'C'   ' '     ,
    'PRCTR'    '손익센터'         '10'   'C'   'ALPHA' ,
    'PRCTR_NM' '손익센터명'       '10'   'L'   ' '     ,
    'VKGRP'    '영업그룹'         '10'   'L'   ' '     ,
    'VKGRP_NM' '영업그룹명'       '10'   'L'   ' '     ,
    'CONNO'    '계약번호'         '10'   'L'   ' '     ,
    'COTXT'    '계약명'           '10'   'L'   ' '     .

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
    WHEN 'BUKRS' OR 'MITYP' OR 'DRSTA' OR 'GUBUN' OR 'BY_SL'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'PRICE' OR 'MISPD'.
      GS_FIELDCAT-CFIELDNAME = 'WAERS'.
    WHEN 'PRICE1' OR 'MISPD1'.
      GS_FIELDCAT-CFIELDNAME = 'WAERS1'.
    WHEN 'RMENG'.
      GS_FIELDCAT-QFIELDNAME = 'MEINS'.
    WHEN 'EMENG'.
      GS_FIELDCAT-QFIELDNAME = 'MEINS1'.
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

  IF P_CHK01 IS INITIAL AND P_CHK02 IS INITIAL.
    PV_ERROR = 'X'.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH 'Buy/Sell 구분을 선택하시기 바랍니다.'.
    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_CHECKBOX
*&---------------------------------------------------------------------*
*&      Form  SET_RANGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_RANGES .

  CLEAR   : S_BY_SL.
  REFRESH : S_BY_SL.

*___Buy/Sell 구분
  IF P_CHK01 = 'X'.
    APPEND_RANGES : S_BY_SL 'I' 'EQ' 'B' ' '.
  ENDIF.
  IF P_CHK02 = 'X'.
    APPEND_RANGES : S_BY_SL 'I' 'EQ' 'S' ' '.
  ENDIF.

ENDFORM.                    " SET_RANGES

*&---------------------------------------------------------------------*
*&      Form  DATA_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SELECT .

  SELECT Z1~BUKRS AS BUKRS
         Z1~SHFNO AS SHFNO
         Z2~H_NO1 AS H_NO1
         Z2~ERDAT AS ERDAT
         Z2~REMON AS REMON
         Z2~RMENG AS RMENG
         Z2~MEINS AS MEINS
         Z2~RUDAT AS RUDAT
         Z2~ENDAT AS ENDAT
         Z2~MISPD AS MISPD
         Z2~PRICE AS PRICE
         Z2~WAERS AS WAERS
         Z1~OFUTN AS OFUTN
         Z3~FCM   AS FCM
*        FCM_NM
         Z3~RUDAT AS RUDAT1
         Z3~NFKEY AS NFKEY
         Z3~BY_SL AS BY_SL
         Z3~ENDAT AS ENDAT1
         Z3~MITYP AS MITYP
*        MITYP_NM
         Z3~MISPD AS MISPD1
         Z3~MIMON AS MIMON
         Z3~PRICE AS PRICE1
         Z3~WAERS AS WAERS1
         Z3~EMENG AS EMENG
         Z3~MEINS AS MEINS1
         Z5~PRCTR AS PRCTR
*        PRCTR_NM
         Z5~CONNO AS CONNO
         Z5~COTXT AS COTXT
         Z5~VKGRP AS VKGRP
         Z1~DRSTA AS DRSTA
         Z3~MCTYP AS MCTYP
*        DRSTA_NM
         INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB
    FROM ZNFT1040 AS Z1
         INNER JOIN ZNFT1041 AS Z2
            ON Z2~SHFNO EQ Z1~SHFNO
         INNER JOIN ZNFT1020 AS Z3
            ON Z3~NFUTN EQ Z1~OFUTN
         INNER JOIN ZNFT1011 AS Z4
            ON Z4~REQNO EQ Z3~REQNO AND Z4~H_NO1 EQ Z3~H_NO1
         INNER JOIN ZNFT1000 AS Z5
            ON Z5~CONNO EQ Z4~CONNO
   WHERE Z1~BUKRS EQ P_BUKRS
     AND Z1~SHFNO IN S_SHFNO
     AND Z1~ERDAT IN S_ERDAT
     AND Z3~FCM   IN S_FCM
     AND Z3~BY_SL IN S_BY_SL
     AND Z4~ENDMM IN S_ENDMM   " 만기월 - 이동전
     AND Z4~NFKEY IN S_NFKEY
     AND Z5~PRCTR IN S_PRCTR
     AND Z5~VKGRP IN S_VKGRP
     AND Z2~REMON IN S_REMON   " 만기월 - 이동
     AND Z2~RUDAT IN S_RUDAT   " 만기이동집행일
     AND Z3~RUDAT IN S_NFDAT   " 선물집행일   ZNFT1020-RUDAT
     AND Z1~OFUTN IN S_OFUTN   " 선물집행번호 (이동전)
     AND Z1~DRSTA IN ('3','4','5','6')
     AND Z1~YNCAN EQ SPACE.

  IF SY-SUBRC EQ 0.
    DATA: LV_TABIX TYPE SY-TABIX.
    CLEAR GS_OUTTAB.
    LOOP AT GT_OUTTAB INTO GS_OUTTAB.
      LV_TABIX = SY-TABIX.

*     손익센터
      PERFORM GET_PRCTR_DESC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-PRCTR
                                   GS_OUTTAB-PRCTR_NM.

*     영업그룹
      PERFORM GET_VKGRP_DESC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-VKGRP
                                   GS_OUTTAB-VKGRP_NM.

*     선물집행번호(이동후) & 생성구분
      SELECT SINGLE NFUTN GUBUN INTO (GS_OUTTAB-NFUTN, GS_OUTTAB-GUBUN)
        FROM ZNFT1041
       WHERE SHFNO EQ GS_OUTTAB-SHFNO
         AND H_NO1 EQ GS_OUTTAB-H_NO1.


*     Buy / Sell
      PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                     GS_OUTTAB-BY_SL
                                     GS_OUTTAB-BY_SL_NM.

*     생성구분
      PERFORM DOMAIN_VALUE_GET USING 'ZGUBUN_4'
                                     GS_OUTTAB-GUBUN
                                     GS_OUTTAB-GUBUN_NM.

*     FCM
      PERFORM GET_LIFNR_DESC USING GS_OUTTAB-FCM
                                   GS_OUTTAB-FCM_NM.

*     집행유형
      PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                     GS_OUTTAB-MITYP
                                     GS_OUTTAB-MITYP_NM.

*     만기이동 결제상태
      PERFORM DOMAIN_VALUE_GET USING 'ZDRSTA'
                                     GS_OUTTAB-DRSTA
                                     GS_OUTTAB-DRSTA_NM.

*___만기이동차수
      PERFORM GET_SHIFT_COUNT(ZNFR2310) USING GS_OUTTAB-OFUTN
                                              GS_OUTTAB-SHFCNT.

      IF GS_OUTTAB-MCTYP EQ 'M'.
        GS_OUTTAB-SHFCNT = '0'.
      ENDIF.

*--> [CHM2507-00010] 청산선물집행번호 컬럼 추가
      "--> 만기이동 후 청산선물
      SELECT SINGLE CFUTN
        INTO GS_OUTTAB-CFUTN
        FROM ZNFT1030
       WHERE NFUTN = GS_OUTTAB-NFUTN.
      "--> 만기이동 전 청산선물
      SELECT SINGLE CFUTN
        INTO GS_OUTTAB-CFUTN_O
        FROM ZNFT1030
       WHERE NFUTN = GS_OUTTAB-OFUTN.
*<-- [CHM2507-00010] 청산선물집행번호 컬럼 추가

      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.
      CLEAR : LV_TABIX, GS_OUTTAB.
    ENDLOOP.
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
      WHEN 'SHFNO'.
        IF NOT GS_OUTTAB-SHFNO IS INITIAL.
          SET PARAMETER: ID 'ZNFSHF' FIELD GS_OUTTAB-SHFNO.
          CALL TRANSACTION 'ZNF2M2303' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE '만기이동요청번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN 'CONNO'.
        IF NOT GS_OUTTAB-CONNO IS INITIAL.
          SET PARAMETER ID 'ZNFCON' FIELD GS_OUTTAB-CONNO.
          CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE '계약번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN 'OFUTN'.
        IF NOT GS_OUTTAB-OFUTN IS INITIAL.
          PERFORM DISPLAY_FUTRUES_HISTORY USING GS_OUTTAB-OFUTN.
        ELSE.
          MESSAGE '선물집행번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN 'NFUTN'.
        IF NOT GS_OUTTAB-NFUTN IS INITIAL.
          PERFORM DISPLAY_FUTRUES_HISTORY USING GS_OUTTAB-NFUTN.
        ELSE.
          MESSAGE '선물집행번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
*--> [CHM2507-00010] 청산선물 변경이력 연동
      WHEN 'CFUTN'.
        IF NOT GS_OUTTAB-CFUTN IS INITIAL.
          PERFORM DISPLAY_FUTRUES_HISTORY_2 USING GS_OUTTAB-CFUTN.
        ELSE.
          MESSAGE '선물집행번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN 'CFUTN_O'.
        IF NOT GS_OUTTAB-CFUTN_O IS INITIAL.
          PERFORM DISPLAY_FUTRUES_HISTORY_2 USING GS_OUTTAB-CFUTN_O.
        ELSE.
          MESSAGE '선물집행번호가 존재하지 않습니다.'
             TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
*<-- [CHM2507-00010] 청산선물 변경이력 연동
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

  CLEAR   : LT_RSPAR.  REFRESH : LT_RSPAR.

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

ENDFORM.                    " DISPLAY_FUTRUES_HISTORY

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

  IF S_ENDMM-LOW IS NOT INITIAL AND
     ( S_ENDMM-LOW+4(2) < '01' OR S_ENDMM-LOW+4(2) > '12' ).
    MESSAGE E003 WITH '만기월(이동전)을 점검하십시오.'.
  ENDIF.

ENDFORM.                    " CHECK_ENDMM

*&---------------------------------------------------------------------*
*&      Form  CHECK_ENDMM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_REMON .

  IF S_REMON-LOW IS NOT INITIAL AND
     ( S_REMON-LOW+4(2) < '01' OR S_REMON-LOW+4(2) > '12' ).
    MESSAGE E003 WITH '만기월(이동후)을 점검하십시오.'.
  ENDIF.

ENDFORM.                    " CHECK_ENDMM
*&---------------------------------------------------------------------*
*& Form DISPLAY_FUTRUES_HISTORY_2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_OUTTAB_CFUTN
*&---------------------------------------------------------------------*
FORM DISPLAY_FUTRUES_HISTORY_2 USING PV_CFUTN.

  DATA: LT_RSPAR LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

  CLEAR   : LT_RSPAR.  REFRESH : LT_RSPAR.

  APPEND_PARAM : LT_RSPAR 'P_BUKRS' 'P' ' ' ' '  P_BUKRS       ' ',
                 LT_RSPAR 'S_CFUTN' 'S' 'I' 'EQ' PV_CFUTN      ' ',
                 LT_RSPAR 'P_CHK11' 'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_CHK12' 'P' ' ' ' '  'X'           ' ',
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

ENDFORM.
