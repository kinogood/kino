*&---------------------------------------------------------------------*
*&  Include           ZNFR2612F01
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
  GS_SORT-FIELDNAME = 'NFCTR'.
  GS_SORT-UP = 'X'.
  GS_SORT-COMP = 'X'.
  GS_SORT-SUBTOT = 'X'.
  APPEND GS_SORT TO GT_SORT.

  GS_SORT-SPOS = 2.
  GS_SORT-FIELDNAME = 'NFCTR_NM'.
  GS_SORT-UP = 'X'.
  GS_SORT-COMP = 'X'.
  GS_SORT-SUBTOT = 'X'.
  APPEND GS_SORT TO GT_SORT.

  GS_SORT-SPOS = 3.
  GS_SORT-FIELDNAME = 'PRCTR'.
  GS_SORT-UP = 'X'.
  GS_SORT-COMP = 'X'.
  GS_SORT-SUBTOT = 'X'.
  APPEND GS_SORT TO GT_SORT.

  GS_SORT-SPOS = 4.
  GS_SORT-FIELDNAME = 'PRCTR_NM'.
  GS_SORT-UP = 'X'.
  GS_SORT-COMP = 'X'.
  GS_SORT-SUBTOT = 'X'.
  APPEND GS_SORT TO GT_SORT.

  GS_SORT-SPOS = 5.
  GS_SORT-FIELDNAME = 'VKGRP'.
  GS_SORT-UP = 'X'.
  GS_SORT-COMP = 'X'.
  GS_SORT-SUBTOT = 'X'.
  APPEND GS_SORT TO GT_SORT.

  GS_SORT-SPOS = 6.
  GS_SORT-FIELDNAME = 'VKGRP_NM'.
  GS_SORT-UP = 'X'.
  GS_SORT-COMP = 'X'.
  GS_SORT-SUBTOT = 'X'.
  APPEND GS_SORT TO GT_SORT.


  GS_SORT-SPOS = 7.
  GS_SORT-FIELDNAME = 'ZGJAHR'.
  GS_SORT-UP = 'X'.
  GS_SORT-COMP = 'X'.
  GS_SORT-SUBTOT = 'X'.
  APPEND GS_SORT TO GT_SORT.

  GS_SORT-SPOS = 8.
  GS_SORT-FIELDNAME = 'ZBELNR'.
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
   'ICON'      ''        '4'     'C'    ' '     ,
    'BUKRS'           '회사코드'        '10'     'C'    ' '     ,
    'BUKRS_NM'        '회사명'          '10'     'L'    ' '     ,
    'NFCTR'           '사업부'          '10'     'C'    'ALPHA' ,
    'NFCTR_NM'        '사업부명'        '10'     'L'    ' '     ,
    'PRCTR'           '손익센터'        '10'     'C'    'ALPHA' ,
    'PRCTR_NM'        '손익센터명'      '10'     'L'    ' '     ,
    'VKGRP'           '영업그룹'        '10'     'C'    'ALPHA' ,
    'VKGRP_NM'        '영업그룹명'      '10'     'L'    ' '     ,
    'KUNNR'           '고  객'          '10'     'C'    'ALPHA' ,
    'NCUST'           '고객명'          '20'     'L'    ' '     ,
    'REQNO'           '요청번호'        '10'     'L'    ' '     ,
    'H_NO1'           '항번'            '10'     'C'    ' '     ,
*C20130911_02959 start
    'CONNO'           '계약번호'        '10'     'L'    ' '     ,
    'COTXT'           '계약명'          '20'     'L'    ' '     ,
*C20130911_02959 end
    'RQTYP'           '선물요청유형'    '10'     'C'    ' '     ,
    'RQTYP_NM'        '선물요청유형'    '10'     'C'    ' '     ,

* 최상위 집행번호 필드 추가 by 박우진 (2026.08.10).
    'SUPREME'         '최상위 집행번호' '12'     'L'    ' '     ,

    'B_NFUTN'         'Buy 집행번호'    '12'     'L'    ' '     ,
    'B_RUDAT'         'Buy 집행일'      '10'     'C'    ' '     ,
    'S_NFUTN'         'Sell 집행번호'   '12'     'L'    ' '     ,
    'S_RUDAT'         'Sell 집행일'     '10'     'C'    ' '     ,
    'FCM'             'FCM'             '5'      'C'    'ALPHA' ,
    'FCM_NM'          'FCM명'           '20'     'L'    ' '     ,
    'ENDAT'           '만기일'          '10'     'C'    ' '     ,
    'EMENG'           '집행량'          '10'     'R'    ' '     ,
    'MEINS'           '단위'            '10'     'C'    ' '     ,
    'NFKEY'           '비철구분'        '10'     'C'    ' '     ,
    'KPRLO'           '선물손익(원화)'  '15'     'R'    ' '     ,
    'KAERS'           '통화'            '5'      'C'    ' '     ,
    'UPRLO'           '선물손익(외화)'  '15'     'R'    ' '     ,
    'UAERS'           '통화'            '5'      'C'    ' '     ,
    'KURSF'           '적용환율'        '12'     'R'    ' '     ,
    'ZBELNR'           'MC회계전표'        '12'     'R'    ' '     ,
    'ZGJAHR'           'MC회계년도'        '12'     'R'    ' '     ,
    'YBELNR'           '귀속회계전표'        '12'     'R'    ' '     ,
    'YGJAHR'           '귀속회계년도'        '12'     'R'    ' '     ,
    'REMON'           '귀속년월'            '6'      'C'    ' '     ,
    'P_KPRLO'           '선물손익(원화)'  '15'     'R'    ' '     ,
    'KRATE '           '비율(%)'  '3'     'R'    ' '     ,
    'TKRATE'           '전체비율(%)'  '3'     'R'    ' ',
    'B_MISPD'         'Buy Spread'      '12'     'R'    ' '     ,
    'B_PRICE'         'Buy 단가'        '10'     'R'    ' '     ,
    'BUY_AMT'         'Buy 금액'        '12'     'R'    ' '     ,
    'B_FEE'           'Buy 수수료'      '10'     'R'    ' '     ,
    'S_MISPD'         'Sell Spread'     '12'     'R'    ' '     ,
    'S_PRICE'         'Sell 단가'       '10'     'R'    ' '     ,
    'SELL_AMT'        'Sell 금액'       '12'     'R'    ' '     ,
    'S_FEE'           'Sell 수수료'     '10'     'R'    ' '     ,
    'WAERS'           '통화'            '5'      'C'    ' '     ,
    'SALER'           '영업담당자'      '10'     'C'    ' '     .

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
    WHEN 'BUKRS' OR 'BUKRS_NM' OR 'RQTYP' OR 'SALER'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'NMISPD'  OR 'NPRICE'   OR 'N_FEE'  OR
         'CMISPD'  OR 'CPRICE'   OR 'C_FEE'  OR
         'B_MISPD' OR 'B_PRICE'  OR 'B__FEE' OR
         'S_MISPD' OR 'S_PRICE'  OR 'S__FEE' OR
         'BUY_AMT' OR 'SELL_AMT'.
      GS_FIELDCAT-CFIELDNAME = 'WAERS'.
    WHEN 'KPRLO'.
      GS_FIELDCAT-CFIELDNAME = 'KAERS'.
    WHEN 'P_KPRLO'.
      GS_FIELDCAT-CFIELDNAME = 'KAERS'.
    WHEN 'UPRLO'.
      GS_FIELDCAT-CFIELDNAME = 'UAERS'.
    WHEN 'EMENG'.
      GS_FIELDCAT-QFIELDNAME = 'MEINS'.
    WHEN 'KURSF'.
      GS_FIELDCAT-DECIMALS   = 2.
      GS_FIELDCAT-DECIMALS_O = 2.
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

  IF P_R01 EQ 'X' AND S_REMON IS NOT INITIAL.

    SELECT Z1~BUKRS
           Z4~NFCTR
           " ZNFT0005-NTEXT AS NFCTR_NM
           Z1~PRCTR
           " ZNFT0004-PTEXT AS PRCTR_NM
           Z1~VKGRP
           " ZNFT0003-VTEXT AS VKGRP_NM
           Z1~KUNNR
           Z4~NCUST
           Z1~REQNO
*C20130911_02959 start
          Z4~CONNO
          Z4~COTXT
*C20130911_02959 end
*-<< 기능개선 154373 - 영업담당자 추가
           Z4~SALER
*->> 기능개선 154373
           Z1~H_NO1
           Z3~RQTYP
           Z1~NFUTN
           Z1~CFUTN
           Z1~NBY_SL
           Z1~FCM
           Z2~RUDAT AS N_RUDAT
           Z5~RUDAT AS C_RUDAT
           Z1~ENDAT
           Z1~EMENG
           Z1~MEINS
           Z1~NFKEY
           Z1~KPRLO
           Z1~KAERS
           Z1~UPRLO
           Z1~UAERS
           Z1~KURSF
           Z1~NMISPD
           Z1~NPRICE
           Z1~N_FEE
           " 금액( BUY_AMT) : EMENG * (PRICE+SPREAD)
           Z1~CMISPD
           Z1~CPRICE
           Z1~C_FEE
           " 금액(SELL_AMT) : EMENG * (PRICE+SPREAD)
           Z1~WAERS
           Z1~ZBELNR
           Z1~ZGJAHR
           Z6~YBELNR
           Z6~YGJAHR
           Z6~KPRLO AS P_KPRLO
           Z6~BUDAT
           Z6~KRATE
           INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB
      FROM ZNFT1051 AS Z1
           INNER JOIN ZNFT1020 AS Z2
              ON Z2~BUKRS EQ Z1~BUKRS AND Z2~NFUTN EQ Z1~NFUTN
           INNER JOIN ZNFT1030 AS Z5
              ON Z5~BUKRS EQ Z1~BUKRS AND Z5~CFUTN EQ Z1~CFUTN
           INNER JOIN ZNFT1010 AS Z3
              ON Z3~REQNO EQ Z1~REQNO
           INNER JOIN ZNFT1000 AS Z4
              ON Z4~CONNO EQ Z1~CONNO
           INNER JOIN ZNFT1055 AS Z6
              ON Z6~BUKRS EQ Z1~BUKRS AND Z6~NFUTN EQ Z1~NFUTN
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~ENDAT IN S_ENDAT
       AND Z1~NFKEY IN S_NFKEY
       AND Z1~PRCTR IN S_PRCTR
       AND Z1~VKGRP IN S_VKGRP
       AND Z1~KUNNR IN S_KUNNR
       AND Z4~NFCTR IN S_NFCTR
       AND Z2~RUDAT IN S_RUDAT
       AND Z6~REMON IN S_REMON
*       AND Z2~MCTYP EQ 'M' "--> 유주수D 요청 주석
       AND Z1~FCM   IN S_FCM
       AND Z1~ZBELNR NE SPACE.
*       AND Z1~YBELNR EQ SPACE.
  ENDIF.

  IF P_R01 EQ 'X' AND S_REMON IS INITIAL..

    SELECT Z1~BUKRS
           Z4~NFCTR
           " ZNFT0005-NTEXT AS NFCTR_NM
           Z1~PRCTR
           " ZNFT0004-PTEXT AS PRCTR_NM
           Z1~VKGRP
           " ZNFT0003-VTEXT AS VKGRP_NM
           Z1~KUNNR
           Z4~NCUST
           Z1~REQNO
*C20130911_02959 start
          Z4~CONNO
          Z4~COTXT
*C20130911_02959 end
*-<< 기능개선 154373 - 영업담당자 추가
           Z4~SALER
*->> 기능개선 154373
           Z1~H_NO1
           Z3~RQTYP
           Z1~NFUTN
           Z1~CFUTN
           Z1~NBY_SL
           Z1~FCM
           Z2~RUDAT AS N_RUDAT
           Z5~RUDAT AS C_RUDAT
           Z1~ENDAT
           Z1~EMENG
           Z1~MEINS
           Z1~NFKEY
           Z1~KPRLO
           Z1~KAERS
           Z1~UPRLO
           Z1~UAERS
           Z1~KURSF
           Z1~NMISPD
           Z1~NPRICE
           Z1~N_FEE
           " 금액( BUY_AMT) : EMENG * (PRICE+SPREAD)
           Z1~CMISPD
           Z1~CPRICE
           Z1~C_FEE
           " 금액(SELL_AMT) : EMENG * (PRICE+SPREAD)
           Z1~WAERS
           Z1~ZBELNR
           Z1~ZGJAHR
           Z6~YBELNR
           Z6~YGJAHR
           Z6~KPRLO AS P_KPRLO
           Z6~BUDAT
           Z6~KRATE
           INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB
      FROM ZNFT1051 AS Z1
           INNER JOIN ZNFT1020 AS Z2
              ON Z2~BUKRS EQ Z1~BUKRS AND Z2~NFUTN EQ Z1~NFUTN
           INNER JOIN ZNFT1030 AS Z5
              ON Z5~BUKRS EQ Z1~BUKRS AND Z5~CFUTN EQ Z1~CFUTN
           INNER JOIN ZNFT1010 AS Z3
              ON Z3~REQNO EQ Z1~REQNO
           INNER JOIN ZNFT1000 AS Z4
              ON Z4~CONNO EQ Z1~CONNO
           LEFT OUTER JOIN ZNFT1055 AS Z6
              ON Z6~BUKRS EQ Z1~BUKRS AND Z6~NFUTN EQ Z1~NFUTN
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~ENDAT IN S_ENDAT
       AND Z1~NFKEY IN S_NFKEY
       AND Z1~PRCTR IN S_PRCTR
       AND Z1~VKGRP IN S_VKGRP
       AND Z1~KUNNR IN S_KUNNR
       AND Z4~NFCTR IN S_NFCTR
       AND Z2~RUDAT IN S_RUDAT
*       AND Z6~REMON IN S_REMON
*       AND Z2~MCTYP EQ 'M' "--> 유주수D 요청 주석
       AND Z1~FCM   IN S_FCM
       AND Z1~ZBELNR NE SPACE.
*       AND Z1~YBELNR EQ SPACE.

  ELSEIF P_R02 EQ 'X'.

    SELECT Z1~BUKRS
           Z4~NFCTR
           " ZNFT0005-NTEXT AS NFCTR_NM
           Z1~PRCTR
           " ZNFT0004-PTEXT AS PRCTR_NM
           Z1~VKGRP
           " ZNFT0003-VTEXT AS VKGRP_NM
           Z1~KUNNR
           Z4~NCUST
           Z1~REQNO
*C20130911_02959 start
          Z4~CONNO
          Z4~COTXT
*C20130911_02959 end
*-<< 기능개선 154373 - 영업담당자 추가
           Z4~SALER
*->> 기능개선 154373
           Z1~H_NO1
           Z3~RQTYP
           Z1~NFUTN
           Z1~CFUTN
           Z1~NBY_SL
           Z1~FCM
           Z2~RUDAT AS N_RUDAT
           Z5~RUDAT AS C_RUDAT
           Z1~ENDAT
           Z1~EMENG
           Z1~MEINS
           Z1~NFKEY
           Z1~KPRLO
           Z1~KAERS
           Z1~UPRLO
           Z1~UAERS
           Z1~KURSF
           Z1~NMISPD
           Z1~NPRICE
           Z1~N_FEE
           " 금액( BUY_AMT) : EMENG * (PRICE+SPREAD)
           Z1~CMISPD
           Z1~CPRICE
           Z1~C_FEE
           " 금액(SELL_AMT) : EMENG * (PRICE+SPREAD)
           Z1~WAERS
           Z1~ZBELNR
           Z1~ZGJAHR
           Z6~YBELNR
           Z6~YGJAHR
           Z6~BUDAT
           Z6~KPRLO AS P_KPRLO
           Z6~BUDAT
           Z6~KRATE
           INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB
      FROM ZNFT1051 AS Z1
           INNER JOIN ZNFT1020 AS Z2
              ON Z2~BUKRS EQ Z1~BUKRS AND Z2~NFUTN EQ Z1~NFUTN
           INNER JOIN ZNFT1030 AS Z5
              ON Z5~BUKRS EQ Z1~BUKRS AND Z5~CFUTN EQ Z1~CFUTN
           INNER JOIN ZNFT1010 AS Z3
              ON Z3~REQNO EQ Z1~REQNO
           INNER JOIN ZNFT1000 AS Z4
              ON Z4~CONNO EQ Z1~CONNO
           INNER JOIN ZNFT1055 AS Z6
              ON Z6~BUKRS EQ Z1~BUKRS AND Z6~NFUTN EQ Z1~NFUTN
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~ENDAT IN S_ENDAT
       AND Z1~NFKEY IN S_NFKEY
       AND Z1~PRCTR IN S_PRCTR
       AND Z1~VKGRP IN S_VKGRP
       AND Z1~KUNNR IN S_KUNNR
       AND Z4~NFCTR IN S_NFCTR
       AND Z2~RUDAT IN S_RUDAT
       AND Z6~REMON IN S_REMON
*       AND Z2~MCTYP EQ 'M' "--> 유주수D 요청 주석
       AND Z1~FCM   IN S_FCM.

  ELSEIF P_R03 EQ 'X'.

    SELECT Z1~BUKRS
           Z4~NFCTR
           " ZNFT0005-NTEXT AS NFCTR_NM
           Z1~PRCTR
           " ZNFT0004-PTEXT AS PRCTR_NM
           Z1~VKGRP
           " ZNFT0003-VTEXT AS VKGRP_NM
           Z1~KUNNR
           Z4~NCUST
           Z1~REQNO
*C20130911_02959 start
          Z4~CONNO
          Z4~COTXT
*C20130911_02959 end
*-<< 기능개선 154373 - 영업담당자 추가
           Z4~SALER
*->> 기능개선 154373
           Z1~H_NO1
           Z3~RQTYP
           Z1~NFUTN
           Z1~CFUTN
           Z1~NBY_SL
           Z1~FCM
           Z2~RUDAT AS N_RUDAT
           Z5~RUDAT AS C_RUDAT
           Z1~ENDAT
           Z1~EMENG
           Z1~MEINS
           Z1~NFKEY
           Z1~KPRLO
           Z1~KAERS
           Z1~UPRLO
           Z1~UAERS
           Z1~KURSF
           Z1~NMISPD
           Z1~NPRICE
           Z1~N_FEE
           " 금액( BUY_AMT) : EMENG * (PRICE+SPREAD)
           Z1~CMISPD
           Z1~CPRICE
           Z1~C_FEE
           " 금액(SELL_AMT) : EMENG * (PRICE+SPREAD)
           Z1~WAERS
           Z1~ZBELNR
           Z1~ZGJAHR
           Z6~YBELNR
           Z6~YGJAHR
           Z6~KPRLO AS P_KPRLO
           Z6~BUDAT
           Z6~KRATE
           INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB
      FROM ZNFT1051 AS Z1
           INNER JOIN ZNFT1020 AS Z2
              ON Z2~BUKRS EQ Z1~BUKRS AND Z2~NFUTN EQ Z1~NFUTN
           INNER JOIN ZNFT1030 AS Z5
              ON Z5~BUKRS EQ Z1~BUKRS AND Z5~CFUTN EQ Z1~CFUTN
           INNER JOIN ZNFT1010 AS Z3
              ON Z3~REQNO EQ Z1~REQNO
           INNER JOIN ZNFT1000 AS Z4
              ON Z4~CONNO EQ Z1~CONNO
           INNER JOIN ZNFT1055 AS Z6
              ON Z6~BUKRS EQ Z1~BUKRS AND Z6~NFUTN EQ Z1~NFUTN
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~ENDAT IN S_ENDAT
       AND Z1~NFKEY IN S_NFKEY
       AND Z1~PRCTR IN S_PRCTR
       AND Z1~VKGRP IN S_VKGRP
       AND Z1~KUNNR IN S_KUNNR
       AND Z4~NFCTR IN S_NFCTR
       AND Z2~RUDAT IN S_RUDAT
       AND Z6~REMON IN S_REMON
*       AND Z2~MCTYP EQ 'M' "--> 유주수D 요청 주석
       AND Z1~FCM   IN S_FCM
       AND Z1~ZBELNR NE SPACE.

  ENDIF.

  IF SY-SUBRC EQ 0.
    DATA: LV_TABIX TYPE SY-TABIX.
    CLEAR: GS_OUTTAB, GT_NFUTN[].
    LOOP AT GT_OUTTAB INTO GS_OUTTAB.
      LV_TABIX = SY-TABIX.

      DATA: LV_KPRLO  LIKE  ZNFT1055-KPRLO.

      IF P_R02 EQ 'X' AND GS_OUTTAB-YBELNR IS INITIAL.
        DELETE GT_OUTTAB INDEX  LV_TABIX.
        CONTINUE.
      ENDIF.

      CLEAR: LV_KPRLO.
      SELECT SUM( KPRLO )
        INTO LV_KPRLO
        FROM ZNFT1055
       WHERE  ZGJAHR  = GS_OUTTAB-ZGJAHR "귀속회계전표
            AND  ZBELNR = GS_OUTTAB-ZBELNR. "귀속회계년도

      SELECT SUM( KRATE )
        INTO GS_OUTTAB-TKRATE
        FROM ZNFT1055
       WHERE  ZGJAHR  = GS_OUTTAB-ZGJAHR "귀속회계전표
            AND  ZBELNR = GS_OUTTAB-ZBELNR. "귀속회계년도

      IF GS_OUTTAB-BUDAT IS NOT INITIAL.
        GS_OUTTAB-REMON = GS_OUTTAB-BUDAT+0(6).
      ENDIF.

    "단수차이 계산 / 박우진 2026.10.06.

    DATA: LV_DIFF TYPE ZKPRLO.
    DATA: LV_TOL  TYPE ZKPRLO VALUE '0.1'.

    LV_DIFF = ABS( LV_KPRLO - GS_OUTTAB-KPRLO ).

      IF LV_KPRLO =   GS_OUTTAB-KPRLO OR
         LV_DIFF < LV_TOL.    "단수차이 10 까지 허용 / 박우진 2026.10.06.

        GS_OUTTAB-ICON = '@5B@'.   "ICON_LED_GREEN
      ELSEIF LV_KPRLO NE  GS_OUTTAB-KPRLO.
        GS_OUTTAB-ICON = '@5C@'.   "ICON_LED_RED
      ENDIF.

      IF P_R01 EQ 'X' AND GS_OUTTAB-ICON = '@5B@'.
        DELETE GT_OUTTAB INDEX  LV_TABIX.
        CONTINUE.
      ENDIF.

      IF P_R01 EQ 'X' AND GS_OUTTAB-TKRATE > 100.
        DELETE GT_OUTTAB INDEX  LV_TABIX.
        CONTINUE.
      ENDIF.

*     사업부
      PERFORM GET_NFCTR_DESC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-NFCTR
                                   GS_OUTTAB-NFCTR_NM.

*     손익센터
      PERFORM GET_PRCTR_DESC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-PRCTR
                                   GS_OUTTAB-PRCTR_NM.

*     영업그룹
      PERFORM GET_VKGRP_DESC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-VKGRP
                                   GS_OUTTAB-VKGRP_NM.

*     고객
      PERFORM GET_KUNNR_DESC USING GS_OUTTAB-KUNNR
                                   GS_OUTTAB-NCUST.

*     FCM
      PERFORM GET_LIFNR_DESC USING GS_OUTTAB-FCM
                                   GS_OUTTAB-FCM_NM.

*     요청유형 내역
      PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                     GS_OUTTAB-RQTYP
                                     GS_OUTTAB-RQTYP_NM.

      CASE GS_OUTTAB-NBY_SL.
        WHEN 'B'.
*         ### BUY ###
          GS_OUTTAB-B_NFUTN = GS_OUTTAB-NFUTN.      " Buy  집행번호
          GS_OUTTAB-B_RUDAT = GS_OUTTAB-N_RUDAT.    " Buy  집행일
          GS_OUTTAB-B_MISPD  = GS_OUTTAB-NMISPD.
          GS_OUTTAB-B_PRICE  = GS_OUTTAB-NPRICE.
          GS_OUTTAB-BUY_AMT  = GS_OUTTAB-EMENG *
                             ( GS_OUTTAB-NPRICE + GS_OUTTAB-NMISPD ).
          GS_OUTTAB-B_FEE    = GS_OUTTAB-N_FEE.

*         ### SELL ###
          GS_OUTTAB-S_NFUTN = GS_OUTTAB-CFUTN.      " Sell 집행번호
          GS_OUTTAB-S_RUDAT = GS_OUTTAB-C_RUDAT.    " Sell 집행일
          GS_OUTTAB-S_MISPD  = GS_OUTTAB-CMISPD.
          GS_OUTTAB-S_PRICE  = GS_OUTTAB-CPRICE.
          GS_OUTTAB-SELL_AMT = GS_OUTTAB-EMENG *
                             ( GS_OUTTAB-CPRICE + GS_OUTTAB-CMISPD ).
          GS_OUTTAB-S_FEE    = GS_OUTTAB-C_FEE.
        WHEN 'S'.
*         ### BUY ###
          GS_OUTTAB-B_NFUTN = GS_OUTTAB-CFUTN.      " Buy  집행번호
          GS_OUTTAB-B_RUDAT = GS_OUTTAB-C_RUDAT.    " Buy  집행일
          GS_OUTTAB-B_MISPD  = GS_OUTTAB-CMISPD.
          GS_OUTTAB-B_PRICE  = GS_OUTTAB-CPRICE.
          GS_OUTTAB-BUY_AMT  = GS_OUTTAB-EMENG *
                             ( GS_OUTTAB-CPRICE + GS_OUTTAB-CMISPD ).
          GS_OUTTAB-B_FEE    = GS_OUTTAB-C_FEE.
*         ### SELL ###
          GS_OUTTAB-S_NFUTN = GS_OUTTAB-NFUTN.      " Sell 집행번호
          GS_OUTTAB-S_RUDAT = GS_OUTTAB-N_RUDAT.    " Sell 집행일
          GS_OUTTAB-S_MISPD  = GS_OUTTAB-NMISPD.
          GS_OUTTAB-S_PRICE  = GS_OUTTAB-NPRICE.
          GS_OUTTAB-SELL_AMT = GS_OUTTAB-EMENG *
                             ( GS_OUTTAB-NPRICE + GS_OUTTAB-NMISPD ).
          GS_OUTTAB-S_FEE    = GS_OUTTAB-N_FEE.
      ENDCASE.

*[S] 최상위 집행번호 추가 by 박우진 (2026.08.10).
      CLEAR : GT_NFUTN.
      PERFORM GET_PREVIOUS_FUTURES_NO USING GS_OUTTAB-NFUTN
                                            GT_NFUTN-NFUTN.
      IF  GT_NFUTN-NFUTN IS NOT INITIAL.
        GS_OUTTAB-SUPREME = GT_NFUTN-NFUTN.
      ENDIF.
*[E] 최상위 집행번호 추가 by 박우진 (2026.08.10).


      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.
      CLEAR : LV_TABIX, GS_OUTTAB.
    ENDLOOP.
  ENDIF.

  CHECK SY-SUBRC EQ 0.

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
      WHEN 'REQNO'.
        IF NOT GS_OUTTAB-REQNO IS INITIAL.
          SET PARAMETER: ID 'ZNFREQ' FIELD GS_OUTTAB-REQNO.
          CALL TRANSACTION 'ZNF2M2103' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE '요청번호가 존재하지 않습니다.'
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
*&      Form  CALL_SCREEN_0200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_SCREEN_0200.

  CHECK GV_ERROR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '확인'
                                 '선물 전표를 취소하시겠습니까?'
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
    CLEAR : CTU_PARAMS.

    CTU_PARAMS-DISMODE  =  'E'.
    CTU_PARAMS-UPDMODE  =  'S'.
*    CTU_PARAMS-DEFSIZE  =  'X'.
    CTU_PARAMS-RACOMMIT =  'X'.

    GV_BLDAT = SY-DATLO.
    GV_BUDAT = SY-DATLO.

    CALL SCREEN 0200 STARTING AT 20 5.
  ENDIF.

*    IF OK_SAVE = 'CONT' AND GV_ERROR IS INITIAL.
*      PERFORM GET_SETTLEMENT_DATA.
*
*      LEAVE TO SCREEN 0.
*    ENDIF.
*  ELSE.
*    MESSAGE S007.
*  ENDIF.

ENDFORM.                    " CALL_SCREEN_0300
*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN_0300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_SCREEN_0300.

  CHECK GV_ERROR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '확인'
                                 '선물 전표를 생성하시겠습니까?'
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
    CLEAR : CTU_PARAMS.

    CTU_PARAMS-DISMODE  =  'E'.
    CTU_PARAMS-UPDMODE  =  'S'.
*    CTU_PARAMS-DEFSIZE  =  'X'.
    CTU_PARAMS-RACOMMIT =  'X'.

    GV_BLDAT = SY-DATLO.
    GV_BUDAT = SY-DATLO.

    CALL SCREEN 0300 STARTING AT 20 5.
  ENDIF.

*    IF OK_SAVE = 'CONT' AND GV_ERROR IS INITIAL.
*      PERFORM GET_SETTLEMENT_DATA.
*
*      LEAVE TO SCREEN 0.
*    ENDIF.
*  ELSE.
*    MESSAGE S007.
*  ENDIF.

ENDFORM.                    " CALL_SCREEN_0300
*&---------------------------------------------------------------------*
*&      Form  CREATE_FI_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_FI_DOC .

*<<< FI 기표 BDC -> 펑션으로 수정 / ZITCS4HDEV10  2023.07.18
  PERFORM MAKE_BDC_DATA_NEW.
**  PERFORM MAKE_BDC_DATA.
*>>>

  PERFORM DATA_SELECT.
  LEAVE TO SCREEN 0.
  MESSAGE S007.

ENDFORM.                    " CREATE_FI_DOC
*&---------------------------------------------------------------------*
*&      Form  MAKE_BDC_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_BDC_DATA .
  DATA: LV_GSBER     LIKE BSEG-GSBER,
        LV_KUNNR     LIKE ZNFT0021-KUNNR,
        LV_PRCTR     LIKE ZNFT1052-PRCTR,  "손익센터
        LV_VKGRP     LIKE ZNFT1052-VKGRP,  "영업그룹
        LV_KURSF(12),
        LV_UPRLO(20),
        LV_KPRLO(20),
        LV_FLAG,
        LV_TABIX     LIKE SY-TABIX.

  CLEAR   : GT_BDCTAB, GT_RETMSG.
  CLEAR   : GV_ERROR, GV_BELNR.
  REFRESH : GT_BDCTAB, GT_RETMSG.


*___선물손익
  WRITE : GV_UPRLO TO LV_UPRLO CURRENCY GV_UAERS NO-GROUPING,
          GV_KPRLO TO LV_KPRLO CURRENCY GV_KAERS NO-GROUPING.

  LV_UPRLO = ABS( LV_UPRLO ).
  LV_KPRLO = ABS( LV_KPRLO ).

  CONDENSE : LV_UPRLO, LV_KPRLO.

**___사업영역
*  IF P_BUKRS = '1000'.
*    LV_GSBER = '1200'.
*  ELSEIF P_BUKRS = '2000'.
*    LV_GSBER = '2900'.
*  ENDIF.

  CLEAR : LV_FLAG.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE CHECK EQ 'X' .

    DATA: LV_H_NO1  LIKE  ZNFT1041-H_NO1,
          LV_PKPRLO LIKE  ZNFT1055-KPRLO,
          LV_TKPRLO LIKE  ZNFT1055-KPRLO.

    LV_TABIX = SY-TABIX.

    CLEAR : LV_TKPRLO, LV_PKPRLO .

*__전체금액
    LV_TKPRLO = GS_OUTTAB-KPRLO.
    LV_TKPRLO = LV_TKPRLO * 100.

    GS_OUTTAB-KPRLO = GS_OUTTAB-KPRLO * ( GV_RATIO / 100 ).


    WRITE : GS_OUTTAB-UPRLO TO LV_UPRLO CURRENCY GS_OUTTAB-UAERS
                                      NO-GROUPING,
            GS_OUTTAB-KPRLO TO LV_KPRLO CURRENCY GS_OUTTAB-KAERS
                                      NO-GROUPING.

    LV_UPRLO = ABS( LV_UPRLO ).
    LV_KPRLO = ABS( LV_KPRLO ).

    CONDENSE : LV_UPRLO, LV_KPRLO.


    SELECT SUM( KPRLO )
      INTO LV_PKPRLO
      FROM ZNFT1055
     WHERE  YGJAHR = GS_OUTTAB-YGJAHR
          AND  YBELNR = GS_OUTTAB-YBELNR.

    IF LV_PKPRLO  IS NOT INITIAL.
      LV_PKPRLO = LV_PKPRLO * 100.
    ENDIF.

*    LV_PKPRLO = LV_PKPRLO + LV_KPRLO.

*__전체금액보다 크면 에러 (마이너스 전표)
*__100% 전표가 생성될 때 잔여 금액반영
    IF GS_OUTTAB-KPRLO <  0.

*__전체금액 = 전체금액 + 손익회계전표 금액
      LV_PKPRLO = LV_PKPRLO - LV_KPRLO.
      IF  LV_PKPRLO < LV_TKPRLO.
        MESSAGE E003 DISPLAY LIKE 'E'
         WITH '금액을 초과했습니다.'.
        EXIT.
      ENDIF.

*__전체금액보다 크면 에러 (플러스 전표)
    ELSEIF GS_OUTTAB-KPRLO >  0.

*__전체금액 = 전체금액 + 손익회계전표 금액
      LV_PKPRLO = LV_PKPRLO + LV_KPRLO.
      IF  LV_PKPRLO > LV_TKPRLO.
        MESSAGE E003 DISPLAY LIKE 'E'
         WITH '금액을 초과했습니다.'.
        EXIT.
      ENDIF.
    ENDIF.


    CLEAR : LV_KUNNR,
            LV_PRCTR,
            LV_VKGRP,
            LV_GSBER,
            GT_RETMSG.

    LV_PRCTR = GS_OUTTAB-PRCTR.        "손익센터
    LV_VKGRP = GS_OUTTAB-VKGRP.        "영업그룹
    LV_KUNNR = GS_OUTTAB-KUNNR.        "고객


    SELECT SINGLE GSBER
      INTO LV_GSBER
      FROM CSKS
      WHERE PRCTR EQ LV_PRCTR
           AND BUKRS EQ '1000'.

*    IF LV_KPRLO > 0.
    IF GS_OUTTAB-KPRLO > 0.

*___고객송장 입력: 헤더데이타 (1)
      PERFORM DYNPRO USING :
                    'X' 'SAPMF05A'           '0100',
                    ' ' 'BDC_OKCODE'         '/00',            "Enter
                    ' ' 'BKPF-BLDAT'         GV_BLDAT,         "증빙일
                    ' ' 'BKPF-BLART'         'SA',             "전표유형
                  ' ' 'BKPF-BUKRS'         GS_OUTTAB-BUKRS,    "회사코드
                    ' ' 'BKPF-BUDAT'         GV_BUDAT,         "전기일
                    ' ' 'BKPF-MONAT'         GV_BUDAT+4(2),    "전기기간
                    ' ' 'BKPF-WAERS'         'KRW',         "통화
                    ' ' 'RF05A-NEWBS'        '50',      "전기키-수금
                    ' ' 'RF05A-NEWKO'        '4140403'.  "계정-고객

*___항목 1 / 송장(2)
      PERFORM DYNPRO USING :
                  'X' 'SAPMF05A'              '0300',
                   ' ' 'BDC_OKCODE'         '=ZK',            "Enter
                  ' ' 'BSEG-WRBTR'         LV_KPRLO,  "현지통화금액(KRW)
                  ' ' 'RF05A-NEWBS'        '40',      "전기키
                  ' ' 'RF05A-NEWKO'        '2260202'.  "계정

*___항목 1 /  사업영역(3)
      PERFORM DYNPRO USING :
                  'X' 'SAPLKACB'              '0002',
                   ' ' 'BDC_OKCODE'         '=COBL_XERGO',
                   ' ' 'COBL-GSBER'         LV_GSBER,  "사업영역
                   ' ' 'COBL-PRCTR'         LV_PRCTR.  "손익센터

*___항목 1 /  수익성세크먼트(4) 고객
      PERFORM DYNPRO USING :
                  'X' 'SAPLKEAK'              '0300',
                   ' ' 'BDC_OKCODE'         '=P+',
                  ' ' 'RKEAK-FIELD(01)'      LV_KUNNR.  "고객

*___항목 1 /  수익성세크먼트(5) 영업그룹
      PERFORM DYNPRO USING :
                  'X' 'SAPLKEAK'              '0300',
                   ' ' 'BDC_OKCODE'         '=WEIT',
                   ' ' 'RKEAK-FIELD(02)'     LV_VKGRP.  "영업그룹

*___항목 1 /  수익성세크먼트(6) 사업영역, 손익센터
      PERFORM DYNPRO USING :
                  'X' 'SAPLKACB'              '0002',
                   ' ' 'BDC_OKCODE'         '=ENTE',
                   ' ' 'COBL-GSBER'         LV_GSBER,  "사업영역
                   ' ' 'COBL-PRCTR'         LV_PRCTR.  "손익센터

*___항목 2 / (7)
      PERFORM DYNPRO USING :
                'X' 'SAPMF05A'           '0330',
                ' ' 'BDC_OKCODE'       '/00',         "Enter
                ' ' 'RF05A-NEWBS'     '40',
                ' ' 'RF05A-NEWKO'     '2260202' . "계정

*___항목 2 / 금액(8)
      PERFORM DYNPRO USING :
                  'X' 'SAPMF05A'              '0300',
                   ' ' 'BDC_OKCODE'         '=ZK',            "Enter
                  ' ' 'BSEG-WRBTR'         LV_KPRLO.  "현지통화금액(KRW)


*___항목 2 / 사업영역(9)
      PERFORM DYNPRO USING :
                  'X' 'SAPLKACB'              '0002',
                   ' ' 'BDC_OKCODE'         '=ENTE',
                   ' ' 'COBL-GSBER'         LV_GSBER.  "사업영역

      PERFORM DYNPRO USING :
                'X' 'SAPMF05A'           '0330',
                ' ' 'BDC_OKCODE'       '=BU'.

*      ELSEIF LV_KPRLO < 0.
    ELSEIF  GS_OUTTAB-KPRLO < 0.

*___고객송장 입력: 헤더데이타 (1)
      PERFORM DYNPRO USING :
                    'X' 'SAPMF05A'           '0100',
                    ' ' 'BDC_OKCODE'         '/00',            "Enter
                    ' ' 'BKPF-BLDAT'         GV_BLDAT,         "증빙일
                    ' ' 'BKPF-BLART'         'SA',             "전표유형
                  ' ' 'BKPF-BUKRS'         GS_OUTTAB-BUKRS,    "회사코드
                    ' ' 'BKPF-BUDAT'         GV_BUDAT,         "전기일
                    ' ' 'BKPF-MONAT'         GV_BUDAT+4(2),    "전기기간
                    ' ' 'BKPF-WAERS'         'KRW',         "통화
                    ' ' 'RF05A-NEWBS'        '50',      "전기키-수금
                    ' ' 'RF05A-NEWKO'        '1240202'.  "계정-고객

*___항목 1 / 송장(2)
      PERFORM DYNPRO USING :
                  'X' 'SAPMF05A'              '0300',
                   ' ' 'BDC_OKCODE'         '=ZK',            "Enter
                  ' ' 'BSEG-WRBTR'         LV_KPRLO,  "현지통화금액(KRW)
                  ' ' 'RF05A-NEWBS'        '40',      "전기키
                  ' ' 'RF05A-NEWKO'        '4140403'.  "계정

*___항목 1 /  사업영역(3)
      PERFORM DYNPRO USING :
                  'X' 'SAPLKACB'              '0002',
                   ' ' 'BDC_OKCODE'         '=ENTE',
                   ' ' 'COBL-GSBER'         LV_GSBER.  "사업영역

*___항목 2 /  차변(4)
      PERFORM DYNPRO USING :
                  'X' 'SAPMF05A'              '0330',
                   ' ' 'BDC_OKCODE'         '/00',            "Enter
                  ' ' 'RF05A-NEWBS'        '40',      "전기키
                  ' ' 'RF05A-NEWKO'        '4140403'.  "계정

*___항목 2 /  금액(5)
      PERFORM DYNPRO USING :
                  'X' 'SAPMF05A'              '0300',
                   ' ' 'BDC_OKCODE'         '=ZK',            "Enter
                  ' ' 'BSEG-WRBTR'         LV_KPRLO.  "현지통화금액(KRW)

*___항목 2 /  사업영역, 손익센터(6)
      PERFORM DYNPRO USING :
                  'X' 'SAPLKACB'              '0002',
                   ' ' 'BDC_OKCODE'         '=COBL_XERGO',
                   ' ' 'COBL-GSBER'         LV_GSBER,  "사업영역
                   ' ' 'COBL-PRCTR'         LV_PRCTR.  "손익센터

*___항목 2 /  수익성세크먼트(7) 고객
      PERFORM DYNPRO USING :
                  'X' 'SAPLKEAK'              '0300',
                   ' ' 'BDC_OKCODE'         '=P+',
                  ' ' 'RKEAK-FIELD(01)'      LV_KUNNR.  "고객

*___항목 2 /  수익성세크먼트(8) 영업그룹
      PERFORM DYNPRO USING :
                  'X' 'SAPLKEAK'              '0300',
                   ' ' 'BDC_OKCODE'         '=WEIT',
                   ' ' 'RKEAK-FIELD(02)'     LV_VKGRP.  "영업그룹

*___항목 2 /  수익성세크먼트(9) 사업영역, 손익센터
      PERFORM DYNPRO USING :
                  'X' 'SAPLKACB'              '0002',
                   ' ' 'BDC_OKCODE'         '=ENTE',
                   ' ' 'COBL-GSBER'         LV_GSBER,  "사업영역
                   ' ' 'COBL-PRCTR'         LV_PRCTR.  "손익센터

      PERFORM DYNPRO USING :
                'X' 'SAPMF05A'           '0330',
                ' ' 'BDC_OKCODE'       '=BU'.

    ENDIF.

*___채권 -> 전표 입력 -> 송장 - 일반
    CALL TRANSACTION 'F-22' USING         GT_BDCTAB
                            OPTIONS  FROM CTU_PARAMS
                            MESSAGES INTO GT_RETMSG.

    READ TABLE GT_RETMSG WITH KEY MSGTYP = 'S'
                                  MSGID  = 'F5'
                                  MSGNR  = '312'.
    IF SY-SUBRC = 0.
      GV_BELNR = GT_RETMSG-MSGV1.
    ELSE.
      GV_ERROR = 'X'.

      READ TABLE GT_RETMSG WITH KEY MSGTYP = 'A'.
      IF SY-SUBRC <> 0.
        READ TABLE GT_RETMSG WITH KEY MSGTYP = 'E'.
        IF SY-SUBRC <> 0.
          READ TABLE GT_RETMSG WITH KEY MSGTYP = 'W'.
          IF SY-SUBRC <> 0.
            READ TABLE GT_RETMSG WITH KEY MSGTYP = 'I'.
            IF SY-SUBRC <> 0.
              READ TABLE GT_RETMSG INDEX 1.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF SY-SUBRC = 0.
        MESSAGE ID     GT_RETMSG-MSGID
                TYPE   'S'
                NUMBER GT_RETMSG-MSGNR
                WITH   GT_RETMSG-MSGV1
                       GT_RETMSG-MSGV2
                       GT_RETMSG-MSGV3
                       GT_RETMSG-MSGV4
               DISPLAY LIKE GT_RETMSG-MSGTYP.
      ENDIF.
    ENDIF.

    IF GV_BELNR IS NOT INITIAL.
      GS_OUTTAB-YBELNR = GV_BELNR.
      GS_OUTTAB-YGJAHR = GV_BUDAT(4).
      GS_OUTTAB-REMON = GV_BUDAT(6).
      GS_OUTTAB-AENAM   = SY-UNAME.
      GS_OUTTAB-AEDAT    = SY-DATLO.
      GS_OUTTAB-AEZET    = SY-TIMLO.


      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.


*    UPDATE ZNFT1051 SET YBELNR = GV_BELNR
*                        YGJAHR = GV_BUDAT(4)
*                        AENAM = SY-UNAME
*                        AEDAT = SY-DATLO
*                        AEZET = SY-TIMLO
*                  WHERE CFUTN = GS_OUTTAB-CFUTN
*                       AND NFUTN = GS_OUTTAB-NFUTN.

      CLEAR : LV_H_NO1.
*> 회계전표 라인 추가
      SELECT SINGLE MAX( H_NO1 )
        INTO    LV_H_NO1
        FROM  ZNFT1055
       WHERE NFUTN EQ GS_OUTTAB-NFUTN.

      LV_H_NO1 = LV_H_NO1 + 1.

      ZNFT1055-NFUTN   =  GS_OUTTAB-NFUTN.
      ZNFT1055-CFUTN   =  GS_OUTTAB-CFUTN.
      ZNFT1055-H_NO1   =  LV_H_NO1.
      ZNFT1055-BUKRS   =  GS_OUTTAB-BUKRS.
      ZNFT1055-REQNO  =  GS_OUTTAB-REQNO.
      ZNFT1055-CONNO  =  GS_OUTTAB-CONNO.
      ZNFT1055-KPRLO   =  GS_OUTTAB-KPRLO.
      ZNFT1055-KRATE  =  GV_RATIO.
      ZNFT1055-ZBELNR  =  GS_OUTTAB-ZBELNR.
      ZNFT1055-ZGJAHR  =  GS_OUTTAB-ZGJAHR.
      ZNFT1055-YBELNR  =  GV_BELNR.
      ZNFT1055-YGJAHR  =  GV_BUDAT(4).
      ZNFT1055-REMON  =  GV_BUDAT(6).
      ZNFT1055-BUDAT   =  GV_BUDAT.
      ZNFT1055-ERNAM  =  SY-UNAME.
      ZNFT1055-ERDAT   =  SY-DATLO.
      ZNFT1055-ERZET   =  SY-TIMLO.

      INSERT ZNFT1055 FROM ZNFT1055.

      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.
    ENDIF.


  ENDLOOP.

ENDFORM.                    " MAKE_BDC_DATA
*&---------------------------------------------------------------------*
*&      Form  MAKE_BDC_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_BDC_DATA_NEW .
* 전표 BDC 전기를 위한 변수
  DATA: LT_BBKPF LIKE STANDARD TABLE OF BBKPF WITH HEADER LINE,
        LT_BBSEG LIKE STANDARD TABLE OF BBSEG WITH HEADER LINE.
  DATA: LV_MSG(100),
        LV_BELNR    TYPE  BELNR_D,
        LV_MODE     TYPE CTU_PARAMS-DISMODE.

  DATA: LV_GSBER     LIKE BSEG-GSBER,
        LV_KUNNR     LIKE ZNFT0021-KUNNR,
        LV_PRCTR     LIKE ZNFT1052-PRCTR,  "손익센터
        LV_VKGRP     LIKE ZNFT1052-VKGRP,  "영업그룹
        LV_KURSF(12),
        LV_UPRLO(20),
        LV_KPRLO(20),
        LV_FLAG,
        LV_TABIX     LIKE SY-TABIX.

  CLEAR   : GT_BDCTAB, GT_RETMSG.
  CLEAR   : GV_ERROR, GV_BELNR.
  REFRESH : GT_BDCTAB, GT_RETMSG.


*___선물손익
  WRITE : GV_UPRLO TO LV_UPRLO CURRENCY GV_UAERS NO-GROUPING,
          GV_KPRLO TO LV_KPRLO CURRENCY GV_KAERS NO-GROUPING.

  LV_UPRLO = ABS( LV_UPRLO ).
  LV_KPRLO = ABS( LV_KPRLO ).

  CONDENSE : LV_UPRLO, LV_KPRLO.

**___사업영역
*  IF P_BUKRS = '1000'.
*    LV_GSBER = '1200'.
*  ELSEIF P_BUKRS = '2000'.
*    LV_GSBER = '2900'.
*  ENDIF.

  CLEAR : LV_FLAG.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE CHECK EQ 'X' .

    DATA: LV_H_NO1  LIKE  ZNFT1041-H_NO1,
          LV_PKPRLO LIKE  ZNFT1055-KPRLO,
          LV_TKPRLO LIKE  ZNFT1055-KPRLO.

    LV_TABIX = SY-TABIX.

    CLEAR : LV_TKPRLO, LV_PKPRLO .

*__전체금액
    LV_TKPRLO = GS_OUTTAB-KPRLO.
    LV_TKPRLO = LV_TKPRLO * 100.

    GS_OUTTAB-KPRLO = GS_OUTTAB-KPRLO * ( GV_RATIO / 100 ).


    WRITE : GS_OUTTAB-UPRLO TO LV_UPRLO CURRENCY GS_OUTTAB-UAERS
                                      NO-GROUPING,
            GS_OUTTAB-KPRLO TO LV_KPRLO CURRENCY GS_OUTTAB-KAERS
                                      NO-GROUPING.

    LV_UPRLO = ABS( LV_UPRLO ).
    LV_KPRLO = ABS( LV_KPRLO ).

    CONDENSE : LV_UPRLO, LV_KPRLO.

    IF GS_OUTTAB-YBELNR IS NOT INITIAL.
      SELECT SUM( KPRLO )
        INTO LV_PKPRLO
        FROM ZNFT1055
       WHERE  YGJAHR = GS_OUTTAB-YGJAHR
         AND  YBELNR = GS_OUTTAB-YBELNR.

      IF LV_PKPRLO  IS NOT INITIAL.
        LV_PKPRLO = LV_PKPRLO * 100.
      ENDIF.
    ENDIF.



*__전체금액보다 크면 에러 (마이너스 전표)
*__100% 전표가 생성될 때 잔여 금액반영
    IF GS_OUTTAB-KPRLO <  0.

*__전체금액 = 전체금액 + 손익회계전표 금액
      LV_PKPRLO = LV_PKPRLO - LV_KPRLO.
      "단수차이 1에 대한 Waiver 적용 / 박우진 2026.10.02
      DATA(LV_DIFF) = ABS( LV_PKPRLO - LV_TKPRLO ).

      IF  LV_PKPRLO < LV_TKPRLO AND
          LV_DIFF > 1.    "비율 처리 시 단수 1 차이 방지오류 / 박우진 추가 (2026.10.06)
        MESSAGE E003  WITH '금액을 초과했습니다.' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

*__전체금액보다 크면 에러 (플러스 전표)
    ELSEIF GS_OUTTAB-KPRLO >  0.

*__전체금액 = 전체금액 + 손익회계전표 금액
      LV_PKPRLO = LV_PKPRLO + LV_KPRLO.

      "단수차이 1에 대한 Waiver 적용 / 박우진 2026.10.02
      LV_DIFF = ABS( LV_PKPRLO - LV_TKPRLO ).

      IF  LV_PKPRLO > LV_TKPRLO AND
          LV_DIFF > 1.     "비율 처리 시 단수 1 차이 방지오류 / 박우진 추가 (2026.10.06)
        MESSAGE E003 WITH '금액을 초과했습니다.' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
    ENDIF.


    CLEAR : LV_KUNNR,
            LV_PRCTR,
            LV_VKGRP,
            LV_GSBER,
            GT_RETMSG.

    LV_PRCTR = GS_OUTTAB-PRCTR.        "손익센터
    LV_VKGRP = GS_OUTTAB-VKGRP.        "영업그룹
    LV_KUNNR = GS_OUTTAB-KUNNR.        "고객


    SELECT SINGLE GSBER
      INTO LV_GSBER
      FROM CSKS
      WHERE PRCTR EQ LV_PRCTR
           AND BUKRS EQ '1000'.

    CLEAR: LT_BBKPF[], LT_BBKPF, LT_BBSEG[], LT_BBSEG, GV_BELNR.

*    IF LV_KPRLO > 0.
    IF GS_OUTTAB-KPRLO > 0.

*___고객송장 입력: 헤더데이타 (1)
      LT_BBKPF-TCODE = 'FB01'.
      LT_BBKPF-BLDAT = GV_BLDAT       .  "증빙일
      LT_BBKPF-BLART = 'SA'           .  "전표유형
      LT_BBKPF-BUKRS = GS_OUTTAB-BUKRS.  "회사코드
      LT_BBKPF-BUDAT = GV_BUDAT       .  "전기일
      LT_BBKPF-MONAT = GV_BUDAT+4(2)  .  "전기기간
      LT_BBKPF-WAERS = 'KRW'          .  "통화
      APPEND LT_BBKPF.

      LT_BBSEG-NEWBS = '50'.          "전기키-수금
      LT_BBSEG-NEWKO = '0004140403'.  "계정-기타매출:PJT파생조정
      LT_BBSEG-WRBTR = LV_KPRLO.      "현지통화금액(KRW)
      LT_BBSEG-GSBER = LV_GSBER.      "사업영역
      LT_BBSEG-PRCTR = LV_PRCTR.      "손익센터
*___수익성세그멘트
      LT_BBSEG-RKE_BUKRS      = GS_OUTTAB-BUKRS.
      LT_BBSEG-RKE_KNDNR      = LV_KUNNR .      "고객
      LT_BBSEG-RKE_KMVKGR     = LV_VKGRP .      "영업그룹
      APPEND LT_BBSEG. CLEAR LT_BBSEG.

      LT_BBSEG-NEWBS = '40'.          "전기키
      LT_BBSEG-NEWKO = '0002260202'.  "계정-확정계약대:비철선물
      LT_BBSEG-WRBTR = LV_KPRLO.      "현지통화금액(KRW)
      LT_BBSEG-GSBER = LV_GSBER.      "사업영역
      APPEND LT_BBSEG. CLEAR LT_BBSEG.

    ELSEIF  GS_OUTTAB-KPRLO < 0.

*___고객송장 입력: 헤더데이타 (1)
      LT_BBKPF-TCODE = 'FB01'.
      LT_BBKPF-BLDAT = GV_BLDAT       .  "증빙일
      LT_BBKPF-BLART = 'SA'           .  "전표유형
      LT_BBKPF-BUKRS = GS_OUTTAB-BUKRS.  "회사코드
      LT_BBKPF-BUDAT = GV_BUDAT       .  "전기일
      LT_BBKPF-MONAT = GV_BUDAT+4(2)  .  "전기기간
      LT_BBKPF-WAERS = 'KRW'          .  "통화
      APPEND LT_BBKPF.

      LT_BBSEG-NEWBS = '50'.          "전기키-수금
      LT_BBSEG-NEWKO = '0001240202'.  "계정-확정계약차:비철선물
      LT_BBSEG-WRBTR = LV_KPRLO.      "현지통화금액(KRW)
      LT_BBSEG-GSBER = LV_GSBER.      "사업영역
      APPEND LT_BBSEG. CLEAR LT_BBSEG.

      LT_BBSEG-NEWBS = '40'.          "전기키
      LT_BBSEG-NEWKO = '0004140403'.  "계정-기타매출:PJT파생조정
      LT_BBSEG-WRBTR = LV_KPRLO.      "현지통화금액(KRW)
      LT_BBSEG-GSBER = LV_GSBER.      "사업영역
      LT_BBSEG-GSBER = LV_PRCTR.      "손익센터
*___수익성세그멘트
      LT_BBSEG-RKE_BUKRS      = GS_OUTTAB-BUKRS.
      LT_BBSEG-RKE_KNDNR      = LV_KUNNR .      "고객
      LT_BBSEG-RKE_PRCTR      = LV_PRCTR .      "손익센터
      LT_BBSEG-RKE_KMVKGR     = LV_VKGRP .      "영업그룹
      APPEND LT_BBSEG. CLEAR LT_BBSEG.

    ENDIF.

*   전표생성 펑션 Call
    CLEAR: LV_BELNR, LV_MSG.
    LV_MODE = CTU_PARAMS-DISMODE.
    CALL FUNCTION 'ZFI_DOCUMENT_POSTING'
      EXPORTING
        I_BDC_MODE  = LV_MODE
        I_MESSAGE   = ''
      IMPORTING
        E_BELNR     = LV_BELNR
        E_RESULTMSG = LV_MSG
      TABLES
        T_BBKPF     = LT_BBKPF
        T_BBSEG     = LT_BBSEG.

    IF NOT LV_BELNR IS INITIAL.
      GV_BELNR = LV_BELNR.
    ELSE.
      GV_ERROR = 'X'.
      MESSAGE S000 WITH LV_MSG.
    ENDIF.

    IF GV_BELNR IS NOT INITIAL.
      GS_OUTTAB-YBELNR = GV_BELNR.
      GS_OUTTAB-YGJAHR = GV_BUDAT(4).
      GS_OUTTAB-REMON = GV_BUDAT(6).
      GS_OUTTAB-AENAM   = SY-UNAME.
      GS_OUTTAB-AEDAT    = SY-DATLO.
      GS_OUTTAB-AEZET    = SY-TIMLO.


      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.


*    UPDATE ZNFT1051 SET YBELNR = GV_BELNR
*                        YGJAHR = GV_BUDAT(4)
*                        AENAM = SY-UNAME
*                        AEDAT = SY-DATLO
*                        AEZET = SY-TIMLO
*                  WHERE CFUTN = GS_OUTTAB-CFUTN
*                       AND NFUTN = GS_OUTTAB-NFUTN.

      CLEAR : LV_H_NO1.
*> 회계전표 라인 추가
      SELECT SINGLE MAX( H_NO1 )
        INTO    LV_H_NO1
        FROM  ZNFT1055
       WHERE NFUTN EQ GS_OUTTAB-NFUTN.

      LV_H_NO1 = LV_H_NO1 + 1.

      ZNFT1055-NFUTN   =  GS_OUTTAB-NFUTN.
      ZNFT1055-CFUTN   =  GS_OUTTAB-CFUTN.
      ZNFT1055-H_NO1   =  LV_H_NO1.
      ZNFT1055-BUKRS   =  GS_OUTTAB-BUKRS.
      ZNFT1055-REQNO  =  GS_OUTTAB-REQNO.
      ZNFT1055-CONNO  =  GS_OUTTAB-CONNO.
      ZNFT1055-KPRLO   =  GS_OUTTAB-KPRLO.
      ZNFT1055-KRATE  =  GV_RATIO.
      ZNFT1055-ZBELNR  =  GS_OUTTAB-ZBELNR.
      ZNFT1055-ZGJAHR  =  GS_OUTTAB-ZGJAHR.
      ZNFT1055-YBELNR  =  GV_BELNR.
      ZNFT1055-YGJAHR  =  GV_BUDAT(4).
      ZNFT1055-REMON  =  GV_BUDAT(6).
      ZNFT1055-BUDAT   =  GV_BUDAT.
      ZNFT1055-ERNAM  =  SY-UNAME.
      ZNFT1055-ERDAT   =  SY-DATLO.
      ZNFT1055-ERZET   =  SY-TIMLO.

      INSERT ZNFT1055 FROM ZNFT1055.

      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " MAKE_BDC_DATA_new
*&---------------------------------------------------------------------*
*&      Form  BDC_EXECUTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BDC_EXECUTION .

  CLEAR : GV_ERROR, GV_BELNR.

*___채권 -> 전표 입력 -> 송장 - 일반
  CALL TRANSACTION 'F-22' USING         GT_BDCTAB
                          OPTIONS  FROM CTU_PARAMS
                          MESSAGES INTO GT_RETMSG.

  READ TABLE GT_RETMSG WITH KEY MSGTYP = 'S'
                                MSGID  = 'F5'
                                MSGNR  = '312'.
  IF SY-SUBRC = 0.
    GV_BELNR = GT_RETMSG-MSGV1.
  ELSE.
    GV_ERROR = 'X'.

    READ TABLE GT_RETMSG WITH KEY MSGTYP = 'A'.
    IF SY-SUBRC <> 0.
      READ TABLE GT_RETMSG WITH KEY MSGTYP = 'E'.
      IF SY-SUBRC <> 0.
        READ TABLE GT_RETMSG WITH KEY MSGTYP = 'W'.
        IF SY-SUBRC <> 0.
          READ TABLE GT_RETMSG WITH KEY MSGTYP = 'I'.
          IF SY-SUBRC <> 0.
            READ TABLE GT_RETMSG INDEX 1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF SY-SUBRC = 0.
      MESSAGE ID     GT_RETMSG-MSGID
              TYPE   'S'
              NUMBER GT_RETMSG-MSGNR
              WITH   GT_RETMSG-MSGV1
                     GT_RETMSG-MSGV2
                     GT_RETMSG-MSGV3
                     GT_RETMSG-MSGV4
             DISPLAY LIKE GT_RETMSG-MSGTYP.
    ENDIF.
  ENDIF.

ENDFORM.                    " BDC_EXECUTION
*&---------------------------------------------------------------------*
*&      Form  DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DYNPRO  USING  PV_DYNBEGIN
                    PV_FNAM
                    PV_FVAL.

  CLEAR : GT_BDCTAB.

  IF  PV_DYNBEGIN =  'X'.
    GT_BDCTAB-DYNBEGIN  =  'X'.
    GT_BDCTAB-PROGRAM   =  PV_FNAM.
    GT_BDCTAB-DYNPRO    =  PV_FVAL.
    APPEND GT_BDCTAB.
  ELSE.
    GT_BDCTAB-FNAM      =  PV_FNAM.
    GT_BDCTAB-FVAL      =  PV_FVAL.
    APPEND GT_BDCTAB.
  ENDIF.

ENDFORM.                    " DYNPRO
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SELECTED_ROWS.

  CALL METHOD GRF_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROWS.

  CALL METHOD GRF_GRID->GET_SELECTED_COLUMNS
    IMPORTING
      ET_INDEX_COLUMNS = GT_COLS.

  IF GT_ROWS[] IS INITIAL.
    MESSAGE E003 DISPLAY LIKE 'E'
       WITH '선택된 라인이 없습니다.'.
    EXIT.
  ENDIF.

  CLEAR : GS_OUTTAB-CHECK.

  MODIFY GT_OUTTAB FROM GS_OUTTAB TRANSPORTING CHECK
                 WHERE BUKRS IS NOT INITIAL.

  LOOP AT GT_ROWS INTO GS_ROWS.
    READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX  GS_ROWS-INDEX.
    IF SY-SUBRC = 0.
      GS_OUTTAB-CHECK = 'X'.
      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX GS_ROWS-INDEX.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_SELECTED_ROWS_1
*&---------------------------------------------------------------------*
*&      Form  REVERSE_FI_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REVERSE_FI_DOC.
  DATA: LV_TEXT(100).

  PERFORM CANCEL_FI_DOC.

*  CHECK GV_ERROR IS INITIAL.
  PERFORM DATA_SELECT.
  LEAVE TO SCREEN 0.
  MESSAGE S007.

ENDFORM.                    " REVERSE_FI_DOC
*&---------------------------------------------------------------------*
*&      Form  CANCEL_FI_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANCEL_FI_DOC .

  CLEAR   : GT_BDCTAB, GT_RETMSG, GV_BELNR, GV_ERROR.
  REFRESH : GT_BDCTAB, GT_RETMSG.

  DATA :     LV_TABIX  LIKE SY-TABIX.


  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE CHECK EQ 'X' .

    LV_TABIX = SY-TABIX.

    PERFORM DYNPRO USING :
                   'X' 'SAPMF05A'          '0105',
                   ' ' 'BDC_OKCODE'        '=BU',
                   ' ' 'RF05A-BELNS'       GS_OUTTAB-YBELNR,
                   ' ' 'BKPF-BUKRS'        GS_OUTTAB-BUKRS,
                   ' ' 'RF05A-GJAHS'       GS_OUTTAB-YGJAHR,
                   ' ' 'BSIS-BUDAT'         GV_BUDAT,
                   ' ' 'BSIS-MONAT'         GV_BUDAT+4(2),
                   ' ' 'UF05A-STGRD'       '01'.

    CLEAR : CTU_PARAMS.

    CTU_PARAMS-DISMODE  =  'N'.
    CTU_PARAMS-UPDMODE  =  'S'.
    CTU_PARAMS-RACOMMIT =  'X'.

    CALL TRANSACTION 'FB08' USING         GT_BDCTAB
                            OPTIONS  FROM CTU_PARAMS
                            MESSAGES INTO GT_RETMSG.

    READ TABLE GT_RETMSG WITH KEY MSGTYP = 'S'
                                  MSGID  = 'F5'
                                  MSGNR  = '312'.
    IF SY-SUBRC = 0.
      GV_BELNR = GT_RETMSG-MSGV1.
    ELSE.
      GV_ERROR = 'X'.

      READ TABLE GT_RETMSG WITH KEY MSGTYP = 'A'.
      IF SY-SUBRC <> 0.
        READ TABLE GT_RETMSG WITH KEY MSGTYP = 'E'.
        IF SY-SUBRC <> 0.
          READ TABLE GT_RETMSG WITH KEY MSGTYP = 'W'.
          IF SY-SUBRC <> 0.
            READ TABLE GT_RETMSG WITH KEY MSGTYP = 'I'.
            IF SY-SUBRC <> 0.
              READ TABLE GT_RETMSG INDEX 1.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF SY-SUBRC = 0.
        MESSAGE ID     GT_RETMSG-MSGID
                TYPE   'S'
                NUMBER GT_RETMSG-MSGNR
                WITH   GT_RETMSG-MSGV1
                       GT_RETMSG-MSGV2
                       GT_RETMSG-MSGV3
                       GT_RETMSG-MSGV4
                DISPLAY LIKE GT_RETMSG-MSGTYP.
      ENDIF.
    ENDIF.

    UPDATE ZNFT1055 SET YBELNR = ''
                        YGJAHR = ''
                        KPRLO  = ''
                        KONWA = ''
                        ERNAM = SY-UNAME
                        ERDAT = SY-DATLO
                        ERZET = SY-TIMLO
                  WHERE CFUTN = GS_OUTTAB-CFUTN
                       AND NFUTN = GS_OUTTAB-NFUTN
                       AND H_NO1 = GS_OUTTAB-H_NO1.

    IF SY-SUBRC = 0.
      COMMIT WORK.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " CANCEL_FI_DOC
*&---------------------------------------------------------------------*
*& Form GET_ASSIGN_HISTORY_NEW
*&---------------------------------------------------------------------*
FORM GET_ASSIGN_HISTORY_NEW .



ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PREVIOUS_FUTURES_NO
*&---------------------------------------------------------------------*
FORM GET_PREVIOUS_FUTURES_NO  USING    PV_NFUTN
                                       PV_OLDFT.
  DATA: LV_NFUTN LIKE ZNFT1020-NFUTN.

  CLEAR : PV_OLDFT, LV_NFUTN.

  SELECT SINGLE OLDFT
    INTO LV_NFUTN
    FROM ZNFT1020
   WHERE NFUTN = PV_NFUTN.

  IF LV_NFUTN IS NOT INITIAL.
    PERFORM GET_PREVIOUS_FUTURES_NO USING LV_NFUTN
                                          PV_OLDFT.
  ELSE.
    PV_OLDFT = PV_NFUTN.
  ENDIF.

ENDFORM.                    " GET_PREVIOUS_FUTURES_NO
