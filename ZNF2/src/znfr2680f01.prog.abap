*&---------------------------------------------------------------------*
*&  Include           ZNFR2680F01
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
    'BUKRS'    '회사코드'         '10'   'C'   ' '     ,
    'GUBUN'    '평가구분'         '12'   'C'   ' '     ,
    'PRCTR'    '손익센터'         '10'   'C'   'ALPHA' ,
    'PRCTR_NM' '손익센터명'       '10'   'L'   ' '     ,
    'CSTAT'    '계약상태'         '10'   'C'   ' '     ,
    'CSTAT_NM' '계약상태'         '10'   'C'   ' '     ,
    'RQTYP'    '요청유형'         '10'   'C'   ' '     ,
    'RQTYP_NM' '요청유형'         '10'   'C'   ' '     ,
    'NFKEY'    '비철구분'         '10'   'C'   ' '     ,
    'CONNO'    '계약번호'         '10'   'L'   ' '     ,
    'COTXT'    '계약명'           '10'   'L'   ' '     ,
    'BY_SL'    'Buy-Sell'         '10'   'C'   ' '     ,
    'BY_SL_NM' 'Buy-Sell'         '10'   'C'   ' '     ,
    'NFUTN'    '선물집행번호'     '10'   'C'   ' '     ,
    'RUDAT'    '집행일'           '10'   'C'   ' '     ,
    'FCM'      'FCM'              '10'   'C'   'ALPHA' ,
    'NAME1'    'FCM 명'           '35'   'L'   ' '     ,
    'ENDAT'    '만기일'           '10'   'C'   ' '     ,
    'GUBUN1'   '신규/청산'        '10'   'C'   ' '     ,
    'MITYP'    '집행유형'         '10'   'C'   ' '     ,
    'MITYP_NM' '집행유형'         '10'   'C'   ' '     ,
    'MISPD'    'Spread'           '10'   'R'   ' '     ,
    'PRICE'    '집행단가'         '10'   'R'   ' '     ,
    'WAERS'    '통화'             '5'    'C'   ' '     ,
    'EMENG'    '집행수량'         '10'   'R'   ' '     ,
    'MEINS'    '단위'             '10'   'C'   ' '     ,
    'AMT_T'    '집행금액'         '10'   'R'   ' '     ,
    'AMT_S'    '시뮬레이션단가'   '10'   'R'   ' '     ,
    'AMT_C'    '선물평가손익'     '10'   'R'   ' '     .

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
    WHEN 'BUKRS' OR 'BY_SL' OR 'CSTAT' OR 'RQTYP' OR 'MITYP'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'PRICE' OR 'MISPD' OR 'AMT_T' OR
         'AMT_S' OR 'AMT_C'.
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
*&      Form  DATA_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SELECT .

  CLEAR GS_OUTTAB. REFRESH GT_OUTTAB.

  DATA: LS_OUTTAB1 LIKE GS_OUTTAB,
        LT_OUTTAB1 LIKE TABLE OF LS_OUTTAB1,
        LS_OUTTAB2 LIKE GS_OUTTAB,
        LT_OUTTAB2 LIKE TABLE OF LS_OUTTAB2.

  SELECT Z1~BUKRS
         Z4~PRCTR
         Z2~RQTYP
         Z1~NFKEY
         Z4~CONNO
         Z4~COTXT
         Z1~BY_SL
         Z1~NFUTN
         Z1~RUDAT
         Z1~FCM
         Z1~ENDAT
         Z1~MITYP
         Z1~MISPD
         Z1~PRICE
         Z1~WAERS
         Z1~EMENG
         Z1~MEINS
         Z4~CSTAT
         INTO CORRESPONDING FIELDS OF TABLE LT_OUTTAB1
    FROM ZNFT1020 AS Z1
         INNER JOIN ZNFT1011 AS Z3
            ON Z3~REQNO EQ Z1~REQNO AND Z3~H_NO1 EQ Z1~H_NO1
         INNER JOIN ZNFT1010 AS Z2
            ON Z2~REQNO EQ Z3~REQNO
         INNER JOIN ZNFT1000 AS Z4
            ON Z4~CONNO EQ Z3~CONNO
   WHERE Z1~BUKRS EQ GV_BUKRS
     AND Z1~ENDAT IN S_ENDAT
     AND Z1~CONFM IN ('3', '7')
     AND Z1~YNCAN EQ SPACE
     AND Z1~YNNET EQ SPACE
     AND Z1~YNFIN EQ SPACE.

  IF LT_OUTTAB1 IS NOT INITIAL.
    SORT LT_OUTTAB1 BY BUKRS NFUTN.
    LS_OUTTAB1-GUBUN1 = '신규'.
    MODIFY LT_OUTTAB1 FROM LS_OUTTAB1 TRANSPORTING GUBUN1
                     WHERE NFUTN NE SPACE.
    APPEND LINES OF LT_OUTTAB1 TO GT_OUTTAB.
  ENDIF.

  SELECT Z1~BUKRS
         Z5~PRCTR
         Z3~RQTYP
         Z1~NFKEY
         Z5~CONNO
         Z5~COTXT
         Z1~BY_SL
         Z1~CFUTN AS NFUTN
         Z1~RUDAT
         Z1~FCM
         Z1~ENDAT
         Z1~MITYP
         Z1~MISPD
         Z1~PRICE
         Z1~WAERS
         Z1~EMENG
         Z1~MEINS
         Z5~CSTAT
         INTO CORRESPONDING FIELDS OF TABLE LT_OUTTAB2
    FROM ZNFT1030 AS Z1
         INNER JOIN ZNFT1020 AS Z2
           ON Z2~NFUTN EQ Z1~NFUTN AND Z2~BUKRS EQ Z1~BUKRS
         INNER JOIN ZNFT1011 AS Z4
            ON Z4~REQNO EQ Z2~REQNO AND Z4~H_NO1 EQ Z2~H_NO1
         INNER JOIN ZNFT1010 AS Z3
            ON Z3~REQNO EQ Z4~REQNO
         INNER JOIN ZNFT1000 AS Z5
            ON Z5~CONNO EQ Z4~CONNO
   WHERE Z1~BUKRS EQ GV_BUKRS
     AND Z1~ENDAT IN S_ENDAT
     AND Z1~CONFM IN ('3', '7')
     AND Z1~YNCAN EQ SPACE
     AND Z1~YNNET EQ SPACE
     AND Z1~YNFIN EQ SPACE.

  IF LT_OUTTAB2 IS NOT INITIAL.
    SORT LT_OUTTAB2 BY BUKRS NFUTN.
    LS_OUTTAB2-GUBUN1 = '청산'.
    MODIFY LT_OUTTAB2 FROM LS_OUTTAB2 TRANSPORTING GUBUN1
                     WHERE NFUTN NE SPACE.
    APPEND LINES OF LT_OUTTAB2 TO GT_OUTTAB.
  ENDIF.

  IF GT_OUTTAB IS NOT INITIAL.

    DATA: LV_TABIX TYPE SY-TABIX,
          LV_PRICE TYPE ZCASH_O.

    CLEAR GS_OUTTAB.

    LOOP AT GT_OUTTAB INTO GS_OUTTAB.

      LV_TABIX = SY-TABIX.

      IF GV_R01 EQ 'X'.
        GS_OUTTAB-GUBUN = '고정비철가격'.
      ELSE.
        IF ( ( GS_OUTTAB-RQTYP EQ '1' OR GS_OUTTAB-RQTYP EQ '2') AND
               GS_OUTTAB-CSTAT NE 'C' ).
          GS_OUTTAB-GUBUN = '고정비철가격'.
        ELSE.
          GS_OUTTAB-GUBUN = '회계기준'.
        ENDIF.
      ENDIF.

*     손익센터
      PERFORM GET_PRCTR_DESC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-PRCTR
                                   GS_OUTTAB-PRCTR_NM.

*     요청유형
      PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                     GS_OUTTAB-RQTYP
                                     GS_OUTTAB-RQTYP_NM.

*     Buy / Sell
      PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                     GS_OUTTAB-BY_SL
                                     GS_OUTTAB-BY_SL_NM.

*     계약상태
      PERFORM DOMAIN_VALUE_GET USING 'ZCSTAT'
                                     GS_OUTTAB-CSTAT
                                     GS_OUTTAB-CSTAT_NM.

*     집행유형
      PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                     GS_OUTTAB-MITYP
                                     GS_OUTTAB-MITYP_NM.

*     FCM 명
      PERFORM GET_LIFNR_DESC USING GS_OUTTAB-FCM
                                   GS_OUTTAB-NAME1.

*     집행금액
      GS_OUTTAB-AMT_T
            = ( GS_OUTTAB-PRICE + GS_OUTTAB-MISPD ) * GS_OUTTAB-EMENG.

*     집행유형 : Average 인 건중에 집행단가=0 인건은 제외
*     집행유형 : Average 인 건은 Spread를 감안해서 평가함
      IF GS_OUTTAB-MITYP EQ 'A' AND GS_OUTTAB-PRICE NE 0.
        LV_PRICE = GS_OUTTAB-PRICE + GS_OUTTAB-MISPD.
      ELSE.
        LV_PRICE = GS_OUTTAB-PRICE.
      ENDIF.

*     ##################################################################
*     시뮬레이션 단가
*     ##################################################################
*     평가구분 : 고정비철가격일 경우 : 시뮬레이션 조건의 값을 가져온다
      IF GV_R01 EQ 'X'.
        CASE GS_OUTTAB-NFKEY.
          WHEN 'CU'.
            GS_OUTTAB-AMT_S = GV_CU_PRICE_S.
          WHEN 'AL'.
            GS_OUTTAB-AMT_S = GV_AL_PRICE_S.
          WHEN 'PB'.
            GS_OUTTAB-AMT_S = GV_PB_PRICE_S.
          WHEN 'NI'.
            GS_OUTTAB-AMT_S = GV_NI_PRICE_S.
        ENDCASE.
      ELSE.
*       ================================================================
*       - 요청유형 : 수주선물 & 고객요청이면서 계약상태가 취소인 경우는
*                    시뮬레이션가격으로 선물평가손익을 계산한다
*       ================================================================
        IF ( ( GS_OUTTAB-RQTYP EQ '1' OR GS_OUTTAB-RQTYP EQ '2') AND
               GS_OUTTAB-CSTAT NE 'C' ).
          CASE GS_OUTTAB-NFKEY.
            WHEN 'CU'.
              GS_OUTTAB-AMT_S = GV_CU_PRICE_S.
            WHEN 'AL'.
              GS_OUTTAB-AMT_S = GV_AL_PRICE_S.
            WHEN 'PB'.
              GS_OUTTAB-AMT_S = GV_PB_PRICE_S.
            WHEN 'NI'.
              GS_OUTTAB-AMT_S = GV_NI_PRICE_S.
          ENDCASE.
        ELSE.
          CASE GS_OUTTAB-NFKEY.
            WHEN 'CU'.
              GS_OUTTAB-AMT_S = GV_CU_PRICE_O.
            WHEN 'AL'.
              GS_OUTTAB-AMT_S = GV_AL_PRICE_O.
            WHEN 'PB'.
              GS_OUTTAB-AMT_S = GV_PB_PRICE_O.
            WHEN 'NI'.
              GS_OUTTAB-AMT_S = GV_NI_PRICE_O.
          ENDCASE.
        ENDIF.
      ENDIF.

*     ##################################################################
*     선물평가손익
*     ##################################################################
*     선물평가손익 - 평가구분 : 고정비철구분
      IF GV_R01 EQ 'X'.
        IF GS_OUTTAB-BY_SL EQ 'B'.
          CASE GS_OUTTAB-NFKEY.
            WHEN 'CU'.
              GS_OUTTAB-AMT_C = ( GV_CU_PRICE_S - LV_PRICE )
                                * GS_OUTTAB-EMENG.
            WHEN 'AL'.
              GS_OUTTAB-AMT_C = ( GV_AL_PRICE_S - LV_PRICE )
                                * GS_OUTTAB-EMENG.
            WHEN 'PB'.
              GS_OUTTAB-AMT_C = ( GV_PB_PRICE_S - LV_PRICE )
                                * GS_OUTTAB-EMENG.
            WHEN 'NI'.
              GS_OUTTAB-AMT_C = ( GV_NI_PRICE_S - LV_PRICE )
                                * GS_OUTTAB-EMENG.
          ENDCASE.
        ELSE.
          CASE GS_OUTTAB-NFKEY.
            WHEN 'CU'.
              GS_OUTTAB-AMT_C = ( LV_PRICE - GV_CU_PRICE_S )
                                * GS_OUTTAB-EMENG.
            WHEN 'AL'.
              GS_OUTTAB-AMT_C = ( LV_PRICE - GV_AL_PRICE_S )
                                * GS_OUTTAB-EMENG.
            WHEN 'PB'.
              GS_OUTTAB-AMT_C = ( LV_PRICE - GV_PB_PRICE_S )
                                * GS_OUTTAB-EMENG.
            WHEN 'NI'.
              GS_OUTTAB-AMT_C = ( LV_PRICE - GV_NI_PRICE_S )
                                * GS_OUTTAB-EMENG.
          ENDCASE.
        ENDIF.
*     선물평가손익 - 평가구분 : 회계기준
      ELSE.
*       ==============================================================
*       - 요청유형 : 수주선물 & 고객요청이면서 계약상태가 취소인
*                    경우는 시뮬레이션가격으로 선물평가손익을 계산한다
*       ==============================================================
        IF ( ( GS_OUTTAB-RQTYP EQ '1' OR GS_OUTTAB-RQTYP EQ '2') AND
               GS_OUTTAB-CSTAT NE 'C' ).
          IF GS_OUTTAB-BY_SL EQ 'B'.
            CASE GS_OUTTAB-NFKEY.
              WHEN 'CU'.
                GS_OUTTAB-AMT_C = ( GV_CU_PRICE_S - LV_PRICE )
                                  * GS_OUTTAB-EMENG.
              WHEN 'AL'.
                GS_OUTTAB-AMT_C = ( GV_AL_PRICE_S - LV_PRICE )
                                  * GS_OUTTAB-EMENG.
              WHEN 'PB'.
                GS_OUTTAB-AMT_C = ( GV_PB_PRICE_S - LV_PRICE )
                                  * GS_OUTTAB-EMENG.
              WHEN 'NI'.
                GS_OUTTAB-AMT_C = ( GV_NI_PRICE_S - LV_PRICE )
                                  * GS_OUTTAB-EMENG.
            ENDCASE.
          ELSE.
            CASE GS_OUTTAB-NFKEY.
              WHEN 'CU'.
                GS_OUTTAB-AMT_C = ( LV_PRICE - GV_CU_PRICE_S )
                                  * GS_OUTTAB-EMENG.
              WHEN 'AL'.
                GS_OUTTAB-AMT_C = ( LV_PRICE - GV_AL_PRICE_S )
                                  * GS_OUTTAB-EMENG.
              WHEN 'PB'.
                GS_OUTTAB-AMT_C = ( LV_PRICE - GV_PB_PRICE_S )
                                  * GS_OUTTAB-EMENG.
              WHEN 'NI'.
                GS_OUTTAB-AMT_C = ( LV_PRICE - GV_NI_PRICE_S )
                                  * GS_OUTTAB-EMENG.
            ENDCASE.
          ENDIF.
        ELSE.
          IF GS_OUTTAB-BY_SL EQ 'B'.
            CASE GS_OUTTAB-NFKEY.
              WHEN 'CU'.
                GS_OUTTAB-AMT_C = ( GV_CU_PRICE_O - LV_PRICE )
                                  * GS_OUTTAB-EMENG.
              WHEN 'AL'.
                GS_OUTTAB-AMT_C = ( GV_AL_PRICE_O - LV_PRICE )
                                  * GS_OUTTAB-EMENG.
              WHEN 'PB'.
                GS_OUTTAB-AMT_C = ( GV_PB_PRICE_O - LV_PRICE )
                                  * GS_OUTTAB-EMENG.
              WHEN 'NI'.
                GS_OUTTAB-AMT_C = ( GV_NI_PRICE_O - LV_PRICE )
                                  * GS_OUTTAB-EMENG.
            ENDCASE.
          ELSE.
            CASE GS_OUTTAB-NFKEY.
              WHEN 'CU'.
                GS_OUTTAB-AMT_C = ( LV_PRICE - GV_CU_PRICE_O )
                                  * GS_OUTTAB-EMENG.
              WHEN 'AL'.
                GS_OUTTAB-AMT_C = ( LV_PRICE - GV_AL_PRICE_O )
                                  * GS_OUTTAB-EMENG.
              WHEN 'PB'.
                GS_OUTTAB-AMT_C = ( LV_PRICE - GV_PB_PRICE_O )
                                  * GS_OUTTAB-EMENG.
              WHEN 'NI'.
                GS_OUTTAB-AMT_C = ( LV_PRICE - GV_NI_PRICE_O )
                                  * GS_OUTTAB-EMENG.
            ENDCASE.
          ENDIF.

        ENDIF.
      ENDIF.

      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.

*     집행유형 : Average 인 건중에 집행단가=0 인건은 제외
      IF GS_OUTTAB-MITYP EQ 'A' AND GS_OUTTAB-PRICE EQ 0.
        DELETE GT_OUTTAB INDEX LV_TABIX.
      ENDIF.

      CLEAR : LV_TABIX, LV_PRICE, GS_OUTTAB.

    ENDLOOP.

  ENDIF.

  IF GT_OUTTAB IS NOT INITIAL.
    SORT GT_OUTTAB BY BUKRS PRCTR RQTYP NFKEY CONNO.
  ENDIF.

*   검색결과
  IF GT_OUTTAB IS NOT INITIAL.
    GV_CNT = LINES( GT_OUTTAB ).
    MESSAGE S368(00) WITH GV_CNT '건이 조회되었습니다.'.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '해당 조건의 데이터가 존재하지 않습니다.'.
    EXIT.
  ENDIF.

ENDFORM.                    " DATA_SELECT
*&---------------------------------------------------------------------*
*&      Form  DATA_RELOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_RELOAD .

  GS_STBL-ROW = 'X'.
  GS_STBL-COL = 'X'.

  CALL METHOD GRF_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = ' '
      IS_STABLE      = GS_STBL.     "화면 라인 Refresh

ENDFORM.                    " DATA_RELOAD
*&---------------------------------------------------------------------*
*&      Form  SET_BURKS_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_BURKS_CODE .

  IF GV_BUKRS IS INITIAL.
    GV_BUKRS = '1000'.
  ENDIF.

ENDFORM.                    " SET_BURKS_CODE

*&---------------------------------------------------------------------*
*&      Form  CHECK_SIMULATION_CONDI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM CHECK_SIMULATION_CONDI  USING  PV_ERROR.

  CLEAR : PV_ERROR.

* 평가구분 : 고정비철가격인경우
* 시뮬레이션 가격정보는 필수 (CU,AL,PB,NI)
  IF GV_R01 EQ 'X'.
    IF GV_CU_PRICE_S IS INITIAL OR GV_AL_PRICE_S IS INITIAL OR
       GV_PB_PRICE_S IS INITIAL OR GV_NI_PRICE_S IS INITIAL .
      PV_ERROR = 'X'.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '고정비철가격의 경우 시뮬레이션정보는 필수입니다.'.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_SIMULATION_CONDI
*&---------------------------------------------------------------------*
*&      Form  GET_SIMULATION_PRICE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_OUTTAB_NFKEY  text
*      -->P_GS_OUTTAB_AMT_S  text
*----------------------------------------------------------------------*
FORM GET_SIMULATION_PRICE  USING    PV_NFKEY
                                    PV_AMT_S.

  DATA: LV_NFKEY    TYPE ZNFKEY,
        LV_MAX_DATE TYPE SY-DATUM.

  CLEAR: PV_AMT_S, LV_NFKEY.   " PV_NFKEY

  CONCATENATE PV_NFKEY '1' INTO LV_NFKEY.

  SELECT SINGLE O_CASH INTO PV_AMT_S
    FROM ZNFT0001
   WHERE INDAT EQ GV_DATE_1
     AND NFKEY EQ LV_NFKEY.

  IF SY-SUBRC NE 0.
    SELECT SINGLE MAX( INDAT ) INTO LV_MAX_DATE
      FROM ZNFT0001
     WHERE NFKEY  EQ LV_NFKEY
       AND O_CASH GT 0.

    IF SY-SUBRC EQ 0.
      SELECT SINGLE MAX( O_CASH ) INTO PV_AMT_S
        FROM ZNFT0001
       WHERE INDAT GE LV_MAX_DATE
         AND NFKEY EQ LV_NFKEY.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_SIMULATION_PRICE
*&---------------------------------------------------------------------*
*&      Form  GET_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATE .

  CLEAR: GV_DATE_1, GV_DATE_7.

* 하루전 날짜 계산
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      DATE      = SY-DATUM
      DAYS      = '01'
      MONTHS    = '00'
      SIGNUM    = '-'
      YEARS     = '00'
    IMPORTING
      CALC_DATE = GV_DATE_1.

*   일주일전 날짜 계산
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      DATE      = SY-DATUM
      DAYS      = '07'
      MONTHS    = '00'
      SIGNUM    = '-'
      YEARS     = '00'
    IMPORTING
      CALC_DATE = GV_DATE_7.


  IF GV_BUKRS IS INITIAL.
    GV_BUKRS = '1000'.
  ENDIF.

  CONCATENATE SY-DATLO+0(6) '01' INTO GV_FRDAT.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = SY-DATLO
    IMPORTING
      LAST_DAY_OF_MONTH = GV_TODAT.

  PERFORM SET_ENDAT_RANGES.

ENDFORM.                    " GET_DATE
*&---------------------------------------------------------------------*
*&      Form  GET_CURRENT_PRICE_BY_NFKEY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CURRENT_PRICE_BY_NFKEY .

* 평가구분 : 회계기준
  IF GV_R01 EQ 'X'.
    GV_CU_PRICE_O = 0.
    GV_AL_PRICE_O = 0.
    GV_PB_PRICE_O = 0.
    GV_NI_PRICE_O = 0.
  ELSE.
    PERFORM GET_SIMULATION_PRICE USING 'CU' GV_CU_PRICE_O.
    PERFORM GET_SIMULATION_PRICE USING 'AL' GV_AL_PRICE_O.
    PERFORM GET_SIMULATION_PRICE USING 'PB' GV_PB_PRICE_O.
    PERFORM GET_SIMULATION_PRICE USING 'NI' GV_NI_PRICE_O.
  ENDIF.

ENDFORM.                    " GET_CURRENT_PRICE_BY_NFKEY

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

  APPEND_PARAM : LT_RSPAR 'P_BUKRS' 'P' ' ' ' '  GV_BUKRS      ' ',
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
*&      Form  SET_ENDAT_RANGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_ENDAT_RANGES .

  CLEAR   : S_ENDAT.  REFRESH : S_ENDAT.

  IF GV_TODAT IS NOT INITIAL.
    APPEND_RANGES S_ENDAT 'I' 'BT' GV_FRDAT GV_TODAT.
  ELSEIF GV_FRDAT IS NOT INITIAL.
    APPEND_RANGES S_ENDAT 'I' 'EQ' GV_FRDAT GV_TODAT.
  ENDIF.

ENDFORM.                    " SET_ENDAT_RANGES
