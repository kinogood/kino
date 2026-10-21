*&---------------------------------------------------------------------*
*&  Include           ZNFR2630F01
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
        DYNAME     = 'ZNFR2630'
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
  GS_SORT-FIELDNAME = 'GUBUN'.
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
    'GUBUN'    '구분'             '10'   'C'   ' '     ,
    'NFUTN'    '선물집행번호'     '10'   'L'   ' '     ,
    'MCTYP'    '만기이동유형'     '1'    'C'   ' '     ,
    'MCTYP_NM' '만기이동유형명'   '20'   'L'   ' '     ,

    'FCM'      'FCM'              '5'    'C'   'ALPHA' ,
    'FCM_NM'   'FCM명'            '20'   'L'   ' '     ,
    'RUDAT'    '집행일'           '10'   'C'   ' '     ,
    'NFKEY'    '비철구분'         '10'   'C'   ' '     ,
    'BY_SL'    'Buy-Sell'         '10'   'C'   ' '     ,
    'BY_SL_NM' 'Buy-Sell'         '10'   'C'   ' '     ,
    'ENDAT'    '만기일'           '10'   'C'   ' '     ,
    'MITYP'    '집행유형'         '10'   'C'   ' '     ,
    'MITYP_NM' '집행유형'         '10'   'C'   ' '     ,
    'MIMON'    '매입기준월'       '8'    'C'   ' '     ,
    'MISPD'    'Spread'           '10'   'R'   ' '     ,
    'PRICE'    '집행단가'         '10'   'R'   ' '     ,
    'WAERS'    '통화'             '5'    'C'   ' '     ,
    'EMENG'    '집행수량'         '10'   'R'   ' '     ,
    'MEINS'    '단위'             '10'   'C'   ' '     ,
    'AMT'      '집행금액'         '10'   'R'   ' '     ,
    'PRCTR'    '손익센터'         '10'   'C'   'ALPHA' ,
    'PRCTR_NM' '손익센터명'       '10'   'L'   ' '     ,
    'RQTYP'    '요청유형'         '10'   'C'   ' '     ,
    'RQTYP_NM' '요청유형'         '10'   'C'   ' '     ,
    'CONNO'    '계약번호'         '10'   'L'   ' '     ,
    'COTXT'    '계약명'           '10'   'L'   ' '     ,
    'NFCTR'    '사업부'           '10'   'C'   'ALPHA' ,
    'NTEXT'    '사업부명'         '20'   'L'   ' '     ,
    'VKGRP'    '영업그룹'         '3'    'C'   ' '     ,
    'VTEXT'    '영업그룹명'       '20'   'L'   ' '     ,
    'COTYP'    '계약유형'         '1'    'C'   ' '     ,
    'COTPT'    '계약유형명'       '20'   'L'   ' '     ,
    'KUNNR'    '고객'             '10'   'C'   'ALPHA' ,
    'NCUST'    '고객명'           '35'   'L'   ' '     ,
    'SALER'    '영업담당자'       '10'   'C'   ' '     ,
    'PRIND'    '가격구분'         '10'   'C'   ' '     ,
    'SUJUP'    '비철수주가'       '10'   'R'   ' '     ,
    'ERNAM'    '요청자'           '10'   'L'   ' '     ,
    'MISUS'    '수수료'           '8'    'C'   ' '     ,
    'SHFCNT'   '만기이동차수'     '5'    'C'   ' '  ,"CHM2109-00256
    'MIMON'    '기준월'           '8'    'C'   ' '     ,"CHM2109-00256
    'CONFM'    '결재상태'         '8'    'C'   ' '     ,
    'CONFM_NM' '결재상태'         '10'   'L'   ' '     ,
    'BIGO4'    '비고'             '20'   'L'   ' '     .

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
    WHEN 'BUKRS' OR 'MITYP' OR 'RQTYP' OR 'BY_SL' OR 'CONFM'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'PRICE' OR 'AMT'.
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
*&      Form  DATA_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_SELECT .

  DATA: LS_OUTTAB1 LIKE GS_OUTTAB,
        LT_OUTTAB1 LIKE TABLE OF LS_OUTTAB1,
        LS_OUTTAB2 LIKE GS_OUTTAB,
        LT_OUTTAB2 LIKE TABLE OF LS_OUTTAB2.


*  DATA: LV_DOMAIN TYPE DOMNAME.
*  LV_DOMAIN = 'ZMCTYP'.

** Domain Text 추가 / 박우진 2026.09.17
*  PERFORM GET_DOMAIN CHANGING LV_DOMAIN.

  IF P_CHK11 EQ 'X'.
    SELECT Z1~BUKRS
           Z1~NFUTN
           Z1~MCTYP
           Z1~FCM
           Z1~RUDAT
           Z1~NFKEY
           Z1~BY_SL
           Z1~ENDAT
           Z1~MITYP
           Z1~MIMON
           Z1~MISPD
           Z1~PRICE
           Z1~WAERS
           Z1~EMENG
           Z1~MEINS
           Z4~PRCTR
           Z2~RQTYP
           Z4~CONNO
           Z4~COTXT
           Z4~NFCTR
           Z4~VKGRP
           Z4~COTYP
           Z4~KUNNR
           Z4~NCUST
           Z4~SALER
           Z4~ERNAM
           Z1~MISUS
           Z1~CONFM
           Z1~BIGO4
           INTO CORRESPONDING FIELDS OF TABLE LT_OUTTAB1
      FROM ZNFT1020 AS Z1
           INNER JOIN ZNFT1011 AS Z3
              ON Z3~REQNO EQ Z1~REQNO AND Z3~H_NO1 EQ Z1~H_NO1
           INNER JOIN ZNFT1010 AS Z2
              ON Z2~REQNO EQ Z3~REQNO
           INNER JOIN ZNFT1000 AS Z4
              ON Z4~CONNO EQ Z3~CONNO
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~FCM   IN S_FCM
       AND Z1~RUDAT IN S_RUDAT
       AND Z1~ENDAT IN S_ENDAT
       AND Z1~NFKEY IN S_NFKEY
       AND Z4~PRCTR IN S_PRCTR
       AND Z4~NFCTR IN S_NFCTR
       AND Z4~VKGRP IN S_VKGRP
       AND Z1~NFUTN IN S_NFUTN
       AND Z1~YNCAN EQ SPACE
       AND Z1~BY_SL IN R_BY_SL
       AND Z2~RQTYP IN R_RQTYP
       AND Z1~YNNET IN R_YNNET
       AND Z4~CONNO IN S_CONNO. "--> 계약번호 조회옵션 추가


    IF LT_OUTTAB1 IS NOT INITIAL.
      SORT LT_OUTTAB1 BY BUKRS NFUTN.
      LS_OUTTAB1-GUBUN = '신규'.
      LS_OUTTAB1-NE_CO = 'N'.
      MODIFY LT_OUTTAB1 FROM LS_OUTTAB1 TRANSPORTING GUBUN NE_CO
                       WHERE NFUTN NE SPACE.
      APPEND LINES OF LT_OUTTAB1 TO GT_OUTTAB.
    ENDIF.
  ENDIF.

  IF P_CHK12 EQ 'X'.
    SELECT Z1~BUKRS
           Z1~CFUTN AS NFUTN
           Z1~FCM
           Z1~RUDAT
           Z1~NFKEY
           Z1~BY_SL
           Z1~ENDAT
           Z1~MITYP
           Z1~MIMON
           Z1~MISPD
           Z1~PRICE
           Z1~WAERS
           Z1~EMENG
           Z1~MEINS
           Z5~PRCTR
           Z3~RQTYP
           Z5~CONNO
           Z5~COTXT
           Z5~NFCTR
           Z5~VKGRP
           Z5~COTYP
           Z5~KUNNR
           Z5~NCUST
           Z5~SALER
           Z5~ERNAM
           Z1~MISUS
           Z1~CONFM
           Z1~BIGO4
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
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~FCM   IN S_FCM
       AND Z1~RUDAT IN S_RUDAT
       AND Z1~ENDAT IN S_ENDAT
       AND Z1~NFKEY IN S_NFKEY
       AND Z5~PRCTR IN S_PRCTR
       AND Z5~NFCTR IN S_NFCTR
       AND Z5~VKGRP IN S_VKGRP
       AND Z1~CFUTN IN S_CFUTN
       AND Z1~BY_SL IN R_BY_SL
       AND Z1~YNCAN EQ SPACE
       AND Z1~BY_SL IN R_BY_SL
       AND Z3~RQTYP IN R_RQTYP
       AND Z1~YNNET IN R_YNNET
       AND Z5~CONNO IN S_CONNO. "--> 계약번호 조회옵션 추가

    IF LT_OUTTAB2 IS NOT INITIAL.
      SORT LT_OUTTAB2 BY BUKRS NFUTN.
      LS_OUTTAB2-GUBUN = '청산'.
      LS_OUTTAB2-NE_CO = 'C'.
      MODIFY LT_OUTTAB2 FROM LS_OUTTAB2 TRANSPORTING GUBUN NE_CO
                       WHERE NFUTN NE SPACE.
      APPEND LINES OF LT_OUTTAB2 TO GT_OUTTAB.
    ENDIF.
  ENDIF.

  IF GT_OUTTAB IS NOT INITIAL.
    DATA: LV_TABIX TYPE SY-TABIX.
    CLEAR GS_OUTTAB.
    LOOP AT GT_OUTTAB INTO GS_OUTTAB.
      LV_TABIX = SY-TABIX.


*   신규/청산
      PERFORM DOMAIN_VALUE_GET USING 'ZNE_CO'
                                     GS_OUTTAB-NE_CO
                                     GS_OUTTAB-NC_NM.

*     사업부
      PERFORM GET_NFCTR_DESC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-NFCTR
                                   GS_OUTTAB-NTEXT.

*     손익센터
      PERFORM GET_PRCTR_DESC USING GV_KOKRS
                                   GS_OUTTAB-PRCTR
                                   GS_OUTTAB-PRCTR_NM.

*     영업그룹
      PERFORM GET_VKGRP_DESC USING GV_KOKRS
                                   GS_OUTTAB-VKGRP
                                   GS_OUTTAB-VTEXT.

*     고객명
      IF GS_OUTTAB-KUNNR IS NOT INITIAL.
        PERFORM GET_KUNNR_DESC USING GS_OUTTAB-KUNNR
                                     GS_OUTTAB-NCUST.
      ENDIF.

*     계약유형명
      PERFORM DOMAIN_VALUE_GET USING 'ZCOTYP'
                                     GS_OUTTAB-COTYP
                                     GS_OUTTAB-COTPT.

*     FCM
      PERFORM GET_LIFNR_DESC USING GS_OUTTAB-FCM
                                   GS_OUTTAB-FCM_NM.

*     Buy / Sell
      PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                     GS_OUTTAB-BY_SL
                                     GS_OUTTAB-BY_SL_NM.

*     요청유형
      PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                     GS_OUTTAB-RQTYP
                                     GS_OUTTAB-RQTYP_NM.

*     집행유형
      PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                     GS_OUTTAB-MITYP
                                     GS_OUTTAB-MITYP_NM.

*     결재상태
      PERFORM DOMAIN_VALUE_GET USING 'ZCONFM3'
                                     GS_OUTTAB-CONFM
                                     GS_OUTTAB-CONFM_NM.

*    만기이동유형 내역
      PERFORM DOMAIN_VALUE_GET USING 'ZMCTYP'
                                     GS_OUTTAB-MCTYP
                                     GS_OUTTAB-MCTYP_NM.


*   - 가격구분 & 비철 수주가
      IF GS_OUTTAB-NFKEY IS NOT INITIAL.
        PERFORM PRICE_CLASSIFICATION USING GS_OUTTAB-CONNO
                                           GS_OUTTAB-NFKEY
                                           GS_OUTTAB-PRIND
                                           GS_OUTTAB-SUJUP
                                           GV_ERROR.
        "--> 예외처리 - 유주수D
        "*** 금액정보 없어도 레포트 조회되도록 함
        CLEAR : GV_ERROR.
        "<-- 예외처리 - 유주수D
      ENDIF.


*-{기능개선 107383 - 만기이동 차수 조회 / 청산선물집행은 0
      IF GS_OUTTAB-NE_CO EQ 'N'.
        PERFORM GET_SHIFT_COUNT(ZNFR2310) USING GS_OUTTAB-NFUTN
                                                GS_OUTTAB-SHFCNT.
        "이동후 집행번호 기준으로 가져왔기 때문에  -1 해줌
        GS_OUTTAB-SHFCNT = GS_OUTTAB-SHFCNT - 1.
      ENDIF.
*-}기능개선 107383

*     집행금액 : ( 집행단가 + SPREAD ) * 수량
      GS_OUTTAB-AMT = GS_OUTTAB-EMENG *
                      ( GS_OUTTAB-PRICE + GS_OUTTAB-MISPD ).

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

  CLEAR   : LT_RSPAR.  REFRESH : LT_RSPAR.

  APPEND_PARAM : LT_RSPAR 'P_BUKRS' 'P' ' ' ' '  P_BUKRS       ' '.

  IF GS_OUTTAB-GUBUN = '신규'.
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
*&      Form  CHECK_SELECT_CHKBOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_SELECT_CHKBOX .

  CLEAR R_BY_SL. REFRESH R_BY_SL.

  IF P_CHK01 EQ 'X'.
    R_BY_SL-LOW    = 'B'.
    R_BY_SL-HIGH   = SPACE.
    R_BY_SL-SIGN   = 'I'.
    R_BY_SL-OPTION = 'EQ'.
    APPEND R_BY_SL.
  ENDIF.

  IF P_CHK02 EQ 'X'.
    R_BY_SL-LOW    = 'S'.
    R_BY_SL-HIGH   = SPACE.
    R_BY_SL-SIGN   = 'I'.
    R_BY_SL-OPTION = 'EQ'.
    APPEND R_BY_SL.
  ENDIF.

ENDFORM.                    " CHECK_SELECT_CHKBOX

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

  IF S_NFUTN[] IS NOT INITIAL AND S_CFUTN[] IS INITIAL.
    CLEAR : P_CHK12.
    P_CHK01 = 'X'.
  ENDIF.

  IF S_CFUTN[] IS NOT INITIAL AND S_NFUTN[] IS INITIAL.
    CLEAR : P_CHK11.
    P_CHK02 = 'X'.
  ENDIF.

  IF S_NFUTN[] IS NOT INITIAL AND S_CFUTN[] IS NOT INITIAL.
    P_CHK01 = 'X'.
    P_CHK02 = 'X'.
  ENDIF.

  IF P_CHK11 IS INITIAL AND P_CHK12 IS INITIAL.
    PV_ERROR = 'X'.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '신규/청산 구분을 선택하시기 바랍니다.'.
    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_CHECKBOX

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
*&---------------------------------------------------------------------*
*& Form GET_DOMAIN
*&---------------------------------------------------------------------*
FORM GET_DOMAIN  CHANGING PV_DOMAIN.

  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      DOMNAME        = PV_DOMAIN     " 도메인명
      TEXT           = 'X'          " 내역(Text) 포함 여부
      LANGU          = SY-LANGU     " 로그인 언어
    TABLES
      DD07V_TAB      = GT_DOMAIN
    EXCEPTIONS
      WRONG_TEXTFLAG = 1
      OTHERS         = 2.

*  IF SY-SUBRC = 0.
*    " lt_values-domvalue_l : Fix.v 값 (예: 'H', 'M', 'N')
*    " lt_values-ddtext     : 내역 (예: 'HPC', 'Market Carry')
*  ENDIF.





ENDFORM.
