*&---------------------------------------------------------------------*
*&  Include           ZNFR2611F01
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

** 만기이동유형 추가 / 박우진 2026.09.17
    'MCTYP'    '만기이동'     '1'    'C'   ' '     ,
    'MCTYP_NM' '만기이동명'   '20'   'L'   ' '     ,
** 만기이동유형 추가 / 박우진 2026.09.17


    'RQTYX'         '이동유형'    '12'     'L'    ' '     ,
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
    'ZBELNR'           '정산회계전표'        '12'     'R'    ' '     ,
    'ZGJAHR'           '정산회계년도'        '12'     'R'    ' '     ,
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

  IF P_R01 EQ 'X'.

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

** 만기이동 추가 / 박우진 2026.09.17
         Z2~MCTYP
** 만기이동 추가 / 박우진 2026.09.17

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
           Z2~MCTYP
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
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~ENDAT IN S_ENDAT
       AND Z1~NFKEY IN S_NFKEY
       AND Z1~PRCTR IN S_PRCTR
       AND Z1~VKGRP IN S_VKGRP
       AND Z1~KUNNR IN S_KUNNR
       AND Z4~NFCTR IN S_NFCTR
       AND Z2~RUDAT IN S_RUDAT
*       AND Z2~MCTYP EQ 'M' "--> 유주수D 요청 주석
       AND Z1~FCM   IN S_FCM
       AND Z1~ZBELNR EQ SPACE.

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
           Z2~MCTYP
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
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~ENDAT IN S_ENDAT
       AND Z1~NFKEY IN S_NFKEY
       AND Z1~PRCTR IN S_PRCTR
       AND Z1~VKGRP IN S_VKGRP
       AND Z1~KUNNR IN S_KUNNR
       AND Z4~NFCTR IN S_NFCTR
       AND Z2~RUDAT IN S_RUDAT
*       AND Z2~MCTYP EQ 'M' "--> 유주수D 요청 주석
       AND Z1~FCM   IN S_FCM
       AND Z1~ZBELNR NE SPACE
       AND Z1~YBELNR EQ SPACE.

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
           Z2~MCTYP
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
     WHERE Z1~BUKRS EQ P_BUKRS
       AND Z1~ENDAT IN S_ENDAT
       AND Z1~NFKEY IN S_NFKEY
       AND Z1~PRCTR IN S_PRCTR
       AND Z1~VKGRP IN S_VKGRP
       AND Z1~KUNNR IN S_KUNNR
       AND Z4~NFCTR IN S_NFCTR
       AND Z2~RUDAT IN S_RUDAT
*       AND Z2~MCTYP EQ 'M' "--> 유주수D 요청 주석
       AND Z1~FCM   IN S_FCM
       AND Z1~YBELNR EQ SPACE..

  ENDIF.

  IF SY-SUBRC EQ 0.
    DATA: LV_TABIX TYPE SY-TABIX.
    CLEAR GS_OUTTAB.
    LOOP AT GT_OUTTAB INTO GS_OUTTAB.
      LV_TABIX = SY-TABIX.

      IF GS_OUTTAB-MCTYP EQ 'M'.
        GS_OUTTAB-RQTYX = 'MARKET CARRY'.
      ELSEIF GS_OUTTAB-MCTYP EQ 'H'.
        GS_OUTTAB-RQTYX = 'HPC'.
      ELSEIF GS_OUTTAB-MCTYP EQ 'N'.
        GS_OUTTAB-RQTYX = '일반유형'.
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

*    만기이동유형 내역
      PERFORM DOMAIN_VALUE_GET USING 'ZMCTYP'
                                     GS_OUTTAB-MCTYP
                                     GS_OUTTAB-MCTYP_NM.

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

    PERFORM DATA_SELECT.

  ELSE.
    MESSAGE S007.
  ENDIF.

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

    PERFORM SET_DATA.

*    GV_BLDAT = SY-DATLO.
*    GV_BUDAT = SY-DATLO.

    CALL SCREEN 0300 STARTING AT 20 5.

    IF OK_SAVE = 'CONT' AND GV_ERROR IS INITIAL.
      PERFORM DATA_SELECT.

    ENDIF.
  ELSE.
    MESSAGE S007.
  ENDIF.


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

  IF OK_SAVE = 'CONT' AND GV_ERROR IS INITIAL.
    PERFORM DATA_SELECT.

    LEAVE TO SCREEN 0.
  ENDIF.
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

*___사업영역
  IF P_BUKRS = '1000'.
    LV_GSBER = '1200'.
  ELSEIF P_BUKRS = '2000'.
    LV_GSBER = '2900'.
  ENDIF.



  CLEAR : LV_FLAG.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE CHECK EQ 'X' .

    LV_TABIX = SY-TABIX.

    WRITE : GS_OUTTAB-UPRLO TO LV_UPRLO CURRENCY GS_OUTTAB-UAERS
                                      NO-GROUPING,
            GS_OUTTAB-KPRLO TO LV_KPRLO CURRENCY GS_OUTTAB-KAERS
                                      NO-GROUPING.


    IF GS_OUTTAB-KPRLO < 0.

      LV_UPRLO = ABS( LV_UPRLO ).
      LV_KPRLO = ABS( LV_KPRLO ).

      CONDENSE : LV_UPRLO, LV_KPRLO.


      CLEAR : LV_KUNNR,
              LV_PRCTR,
              LV_VKGRP,
              GV_BELNR,
              GT_RETMSG[],
              GT_BDCTAB[].


      LV_PRCTR = GS_OUTTAB-PRCTR.        "손익센터
      LV_VKGRP = GS_OUTTAB-VKGRP.        "영업그룹
      LV_KUNNR = GS_OUTTAB-KUNNR.        "고객

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
                    ' ' 'RF05A-NEWKO'        '5150901'.  "계정-고객

*___항목 1 / 송장(2)
      PERFORM DYNPRO USING :
                  'X' 'SAPMF05A'              '0300',
                   ' ' 'BDC_OKCODE'         '=ZK',            "Enter
                  ' ' 'BSEG-WRBTR'         LV_KPRLO,  "현지통화금액(KRW)
                  ' ' 'RF05A-NEWBS'        '40',      "전기키
                  ' ' 'RF05A-NEWKO'        '7480105'.  "계정

*___항목 1 /  사업영역(3)
      PERFORM DYNPRO USING :
                  'X' 'SAPLKACB'              '0002',
                   ' ' 'BDC_OKCODE'         '=COBL_XERGO',
                   ' ' 'COBL-GSBER'         LV_GSBER.  "사업영역

*___항목 1 /  수익성세크먼트(4)
      PERFORM DYNPRO USING :
                  'X' 'SAPLKEAK'              '0300',
                   ' ' 'BDC_OKCODE'         '=P+',
                   ' ' 'RKEAK-FIELD(01)'     LV_KUNNR ,  "고객
                   ' ' 'RKEAK-FIELD(13)'     LV_PRCTR .  "손익센터

*___항목 1 /  수익성세크먼트(5)
      PERFORM DYNPRO USING :
                  'X' 'SAPLKEAK'              '0300',
                   ' ' 'BDC_OKCODE'         '=WEIT',
                   ' ' 'RKEAK-FIELD(02)'     LV_VKGRP .  "영업그룹

*___항목 1(6)
      PERFORM DYNPRO USING :
*___수익성세그멘트
                'X' 'SAPLKACB'           '0002',
                    ' ' 'BDC_OKCODE'    '=ENTE',            "Enter
                   ' ' 'COBL-GSBER'     LV_GSBER,  "사업영역
                   ' ' 'COBL-PRCTR'     LV_PRCTR .  "손익센터

*___항목 2 / (7)
      PERFORM DYNPRO USING :
                'X' 'SAPMF05A'           '0330',
                ' ' 'BDC_OKCODE'       '/00',         "Enter
                ' ' 'RF05A-NEWBS'     '40',
                ' ' 'RF05A-NEWKO'     '7480105' . "계정

*___항목 2 / 송장*(8)
      PERFORM DYNPRO USING :
                  'X' 'SAPMF05A'              '0300',
                   ' ' 'BDC_OKCODE'         '=ZK',            "Enter
                  ' ' 'BSEG-WRBTR'         LV_KPRLO,  "현지통화금액(KRW)
                  ' ' 'RF05A-NEWBS'        '40',      "전기키
                  ' ' 'RF05A-NEWKO'        '1240202'.  "계정
*
*___항목 2 / 송장*(09)
      PERFORM DYNPRO USING :
                  'X' 'SAPLKACB'              '0002',
                   ' ' 'BDC_OKCODE'         '=ENTE',            "Enter
                   ' ' 'COBL-GSBER'     LV_GSBER.  "사업영역

*___항목 2(10)
      PERFORM DYNPRO USING :
                'X' 'SAPMF05A'           '0330',
                ' ' 'BDC_OKCODE'       '/00',         "Enter
                ' ' 'RF05A-NEWBS'     '40',
                ' ' 'RF05A-NEWKO'     '1240202' . "계정

*___항목 3(11)
      PERFORM DYNPRO USING :
                  'X' 'SAPMF05A'              '0300',
                   ' ' 'BDC_OKCODE'         '=ZK',            "Enter
                  ' ' 'BSEG-WRBTR'         LV_KPRLO,  "현지통화금액(KRW)
                  ' ' 'RF05A-NEWBS'        '50',      "전기키
                  ' ' 'RF05A-NEWKO'        '7250202'.  "계정

*___항목 3 / 송장*(13)
      PERFORM DYNPRO USING :
*___수익성세그멘트
                'X' 'SAPLKACB'           '0002',
                    ' ' 'BDC_OKCODE'    '=ENTE',            "Enter
                   ' ' 'COBL-GSBER'     LV_GSBER.  "사업영역

*___항목 4 / 송장*(12)
      PERFORM DYNPRO USING :
                  'X' 'SAPMF05A'              '0330',
                   ' ' 'BDC_OKCODE'         '/00',            "Enter
                  ' ' 'RF05A-NEWBS'        '50',      "전기키
                  ' ' 'RF05A-NEWKO'        '7250202'.  "계정

*___항목 4 / 송장*(13)
      PERFORM DYNPRO USING :
                  'X' 'SAPMF05A'              '0300',
                   ' ' 'BDC_OKCODE'         '=ZK',            "Enter
                  ' ' 'BSEG-WRBTR'         LV_KPRLO.  "현지통화금액(KRW)


      PERFORM DYNPRO USING :
*___수익성세그멘트
                'X' 'SAPLKACB'           '0002',
                    ' ' 'BDC_OKCODE'    '=ENTE',            "Enter
                   ' ' 'COBL-GSBER'     LV_GSBER.  "사업영역

      PERFORM DYNPRO USING :
                'X' 'SAPMF05A'           '0330',
                ' ' 'BDC_OKCODE'       '=BU'.

*___채권 -> 전표 입력 -> 송장 - 일반
      CALL TRANSACTION 'F-22' USING         GT_BDCTAB
                              OPTIONS  FROM CTU_PARAMS
                              MESSAGES INTO GT_RETMSG.

      READ TABLE GT_RETMSG  WITH KEY MSGTYP = 'S'
                                    MSGID  = 'F5'
                                    MSGNR  = '312'.

      IF SY-SUBRC = 0 ..
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
        GS_OUTTAB-ZBELNR = GV_BELNR.
        GS_OUTTAB-ZGJAHR = GV_BUDAT(4).
        GS_OUTTAB-AENAM   = SY-UNAME.
        GS_OUTTAB-AEDAT    = SY-DATLO.
        GS_OUTTAB-AEZET    = SY-TIMLO.
      ENDIF.

      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.


      UPDATE ZNFT1051 SET ZBELNR = GV_BELNR
                          ZGJAHR = GV_BUDAT(4)
                          AENAM = SY-UNAME
                          AEDAT = SY-DATLO
                          AEZET = SY-TIMLO
                    WHERE CFUTN = GS_OUTTAB-CFUTN
                         AND NFUTN = GS_OUTTAB-NFUTN.

      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.
    ELSE.

      LV_UPRLO = ABS( LV_UPRLO ).
      LV_KPRLO = ABS( LV_KPRLO ).

      CONDENSE : LV_UPRLO, LV_KPRLO.


      CLEAR : LV_KUNNR,
              LV_PRCTR,
              LV_VKGRP,
              GV_BELNR,
              GT_RETMSG[],
              GT_BDCTAB[].


      LV_PRCTR = GS_OUTTAB-PRCTR.        "손익센터
      LV_VKGRP = GS_OUTTAB-VKGRP.        "영업그룹
      LV_KUNNR = GS_OUTTAB-KUNNR.        "고객

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
                    ' ' 'RF05A-NEWKO'        '7240105'.  "계정-고객

*___항목 1 / 송장(2)
      PERFORM DYNPRO USING :
                  'X' 'SAPMF05A'              '0300',
                   ' ' 'BDC_OKCODE'         '/00',            "Enter
                  ' ' 'BSEG-WRBTR'         LV_KPRLO,  "현지통화금액(KRW)
                  ' ' 'RF05A-NEWBS'        '40',      "전기키
                  ' ' 'RF05A-NEWKO'        '5150901'.  "계정

*___항목 1 /  사업영역(3)
      PERFORM DYNPRO USING :
                  'X' 'SAPLKACB'              '0002',
                   ' ' 'BDC_OKCODE'         '=ENTE',
                   ' ' 'COBL-GSBER'         LV_GSBER.  "사업영역

*___항목 1 /  수익성세크먼트(4)
      PERFORM DYNPRO USING :
                  'X' 'SAPMF05A'              '0300',
                   ' ' 'BDC_OKCODE'         '/00',
                  ' ' 'BSEG-WRBTR'         LV_KPRLO,  "현지통화금액(KRW)
                  ' ' 'RF05A-NEWBS'        '40',      "전기키
                  ' ' 'RF05A-NEWKO'        '7490202'.  "계정

*___항목 1 /  사업영역(5)
      PERFORM DYNPRO USING :
                  'X' 'SAPLKACB'              '0002',
                   ' ' 'BDC_OKCODE'         '=COBL_XERGO',
                   ' ' 'COBL-GSBER'         LV_GSBER.  "사업영역

*___항목 1 /  수익성세크먼트(6)
      PERFORM DYNPRO USING :
                  'X' 'SAPLKEAK'              '0300',
                   ' ' 'BDC_OKCODE'         '=P+',
                   ' ' 'RKEAK-FIELD(01)'     LV_KUNNR ,  "고객
                   ' ' 'RKEAK-FIELD(13)'     LV_PRCTR .  "손익센터

*___항목 1 /  수익성세크먼트(7)
      PERFORM DYNPRO USING :
                  'X' 'SAPLKEAK'              '0300',
                   ' ' 'BDC_OKCODE'         '=WEIT',
                   ' ' 'RKEAK-FIELD(02)'     LV_VKGRP .  "영업그룹

*___항목 1(8)
      PERFORM DYNPRO USING :
*___수익성세그멘트
                'X' 'SAPLKACB'           '0002',
                    ' ' 'BDC_OKCODE'    '=ENTE',            "Enter
                   ' ' 'COBL-GSBER'     LV_GSBER,  "사업영역
                   ' ' 'COBL-PRCTR'     LV_PRCTR .  "손익센터

*___항목 3(9)
      PERFORM DYNPRO USING :
                  'X' 'SAPMF05A'              '0300',
                   ' ' 'BDC_OKCODE'         '/00',            "Enter
                  ' ' 'BSEG-WRBTR'         LV_KPRLO,  "현지통화금액(KRW)
                  ' ' 'RF05A-NEWBS'        '50',      "전기키
                  ' ' 'RF05A-NEWKO'        '2260202'.  "계정

*___항목 10)
      PERFORM DYNPRO USING :
                  'X' 'SAPLKACB'              '0002',
                   ' ' 'BDC_OKCODE'         '=ENTE',            "Enter
                   ' ' 'COBL-GSBER'     LV_GSBER.  "사업영역

*___항목 3(11)
      PERFORM DYNPRO USING :
                  'X' 'SAPMF05A'              '0300',
                   ' ' 'BDC_OKCODE'         '/00',            "Enter
                  ' ' 'BSEG-WRBTR'         LV_KPRLO.  "현지통화금액(KRW)

*___항목 3(12)
      PERFORM DYNPRO USING :
                  'X' 'SAPLKACB'              '0002',
                   ' ' 'BDC_OKCODE'         '=ENTE',            "Enter
                   ' ' 'COBL-GSBER'     LV_GSBER.  "사업영역


*___항목 4(13)
      PERFORM DYNPRO USING :
                  'X' 'SAPMF05A'              '0300',
                   ' ' 'BDC_OKCODE'         '=BU',            "Enter
                  ' ' 'BSEG-WRBTR'         LV_KPRLO.  "현지통화금액(KRW)

*___항목 4(14)
      PERFORM DYNPRO USING :
*___수익성세그멘트
                'X' 'SAPLKACB'           '0002',
                    ' ' 'BDC_OKCODE'    '=ENTE',            "Enter
                   ' ' 'COBL-GSBER'     LV_GSBER.  "사업영역

      PERFORM DYNPRO USING :
                'X' 'SAPMF05A'           '0330',
                ' ' 'BDC_OKCODE'       '=BU'.

*___채권 -> 전표 입력 -> 송장 - 일반
      CALL TRANSACTION 'F-22' USING         GT_BDCTAB
                              OPTIONS  FROM CTU_PARAMS
                              MESSAGES INTO GT_RETMSG.

      READ TABLE GT_RETMSG  WITH KEY MSGTYP = 'S'
                                    MSGID  = 'F5'
                                    MSGNR  = '312'.

      IF SY-SUBRC = 0 ..
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
        GS_OUTTAB-ZBELNR = GV_BELNR.
        GS_OUTTAB-ZGJAHR = GV_BUDAT(4).
        GS_OUTTAB-AENAM   = SY-UNAME.
        GS_OUTTAB-AEDAT    = SY-DATLO.
        GS_OUTTAB-AEZET    = SY-TIMLO.
      ENDIF.

      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.


      UPDATE ZNFT1051 SET ZBELNR = GV_BELNR
                          ZGJAHR = GV_BUDAT(4)
                          AENAM = SY-UNAME
                          AEDAT = SY-DATLO
                          AEZET = SY-TIMLO
                    WHERE CFUTN = GS_OUTTAB-CFUTN
                         AND NFUTN = GS_OUTTAB-NFUTN.

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

  DATA: LT_COTA031 TYPE SORTED TABLE OF ZCOTA031  "박우진 추가 20260415
        WITH UNIQUE KEY GJAHR KOKRS VKGRP PRCTR.

  DATA:
*        LV_GSBER     LIKE BSEG-GSBER,      "사업영역
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

*___사업영역

* [S] CHM2604-00280 : 사업영역 맵핑테이블 참조/ 박우진 2026.04.14
**  "수정 전 (하드코딩)
**  IF P_BUKRS = '1000'.
**    LV_GSBER = '1200'.
**  ELSEIF P_BUKRS = '2000'.
**    LV_GSBER = '2900'.
**  ENDIF.



  "Mapping Table 추가 / 박우진.
  "만기일 연도 기준으로 MJAHR 추출.
  SELECT *
   FROM ZCOTA031
   INTO CORRESPONDING FIELDS OF TABLE @LT_COTA031
   WHERE KOKRS EQ @P_BUKRS
     AND GJAHR EQ @S_ENDAT-LOW+0(4).

* [E] CHM2604-00280 : 사업영역 맵핑테이블 참조/ 박우진 2026.04.14

  CLEAR : LV_FLAG.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE CHECK EQ 'X' .
    CLEAR: LT_BBKPF[], LT_BBKPF, LT_BBSEG[], LT_BBSEG, GV_BELNR.

    LV_TABIX = SY-TABIX.

    WRITE : GS_OUTTAB-UPRLO TO LV_UPRLO CURRENCY GS_OUTTAB-UAERS
                                      NO-GROUPING,
            GS_OUTTAB-KPRLO TO LV_KPRLO CURRENCY GS_OUTTAB-KAERS
                                      NO-GROUPING.

*  [S] CHM2604-00280 : 사업영역 맵핑테이블 참조/ 박우진 2026.04.14
    DATA(LS_COTA031) = VALUE #( LT_COTA031[
                                            KOKRS = GS_OUTTAB-BUKRS
                                            VKGRP = GS_OUTTAB-VKGRP
                                            PRCTR = GS_OUTTAB-PRCTR
                                             ] OPTIONAL ).


    "Only Applicable to Company Code 1000.
    IF LS_COTA031 IS INITIAL AND P_BUKRS EQ '1000'.

      MESSAGE S003 WITH TEXT-M01 'ZCOTA031 를 확인하세요'
                                 DISPLAY LIKE 'E'.
      EXIT.

    ENDIF.


*  Company 1000: 맵핑 참조 / Company 2000 : 2900 고정.
    DATA(LV_GSBER) = COND GSBER( WHEN P_BUKRS EQ '1000'
                                 THEN LS_COTA031-GSBER

                                 WHEN P_BUKRS EQ '2000'
                                 THEN  '2900' ).
*  [E] CHM2604-00280 : 사업영역 맵핑테이블 참조/ 박우진 2026.04.14


    IF GS_OUTTAB-KPRLO < 0.

      LV_UPRLO = ABS( LV_UPRLO ).
      LV_KPRLO = ABS( LV_KPRLO ).

      CONDENSE : LV_UPRLO, LV_KPRLO.


      CLEAR : LV_KUNNR,
              LV_PRCTR,
              LV_VKGRP,
              GV_BELNR,
              GT_RETMSG[],
              GT_BDCTAB[].


      LV_PRCTR = GS_OUTTAB-PRCTR.        "손익센터
      LV_VKGRP = GS_OUTTAB-VKGRP.        "영업그룹
      LV_KUNNR = GS_OUTTAB-KUNNR.        "고객

*_____고객송장 입력: 헤더데이타 (1)
      LT_BBKPF-TCODE = 'FB01'.
      LT_BBKPF-BLDAT = GV_BLDAT       .  "증빙일
      LT_BBKPF-BLART = 'SA'           .  "전표유형
      LT_BBKPF-BUKRS = GS_OUTTAB-BUKRS.  "회사코드
      LT_BBKPF-BUDAT = GV_BUDAT       .  "전기일
      LT_BBKPF-MONAT = GV_BUDAT+4(2)  .  "전기기간
      LT_BBKPF-WAERS = 'KRW'          .  "통화
      APPEND LT_BBKPF.


      LT_BBSEG-NEWBS = '50'.          "전기키-수금
      LT_BBSEG-NEWKO = '0005150901'.  "계정-동선물정산손익
      LT_BBSEG-WRBTR = LV_KPRLO.      "현지통화금액(KRW)
      LT_BBSEG-GSBER = LV_GSBER.      "사업영역
*___수익성세그멘트
      LT_BBSEG-RKE_BUKRS      = GS_OUTTAB-BUKRS.
      LT_BBSEG-RKE_KNDNR      = LV_KUNNR .      "고객
      LT_BBSEG-RKE_PRCTR      = LV_PRCTR .      "손익센터
      LT_BBSEG-RKE_KMVKGR     = LV_VKGRP .      "영업그룹
      APPEND LT_BBSEG. CLEAR LT_BBSEG.

      LT_BBSEG-NEWBS = '40'.          "전기키
      LT_BBSEG-NEWKO = '0007480105'.  "계정-파생상품 거래손실:동선물
      LT_BBSEG-WRBTR = LV_KPRLO.      "현지통화금액(KRW)
      LT_BBSEG-GSBER = LV_GSBER.      "사업영역
      APPEND LT_BBSEG. CLEAR LT_BBSEG.

      LT_BBSEG-NEWBS = '40'.          "전기키
      LT_BBSEG-NEWKO = '0001240202'.  "계정-확정계약차:비철선물
      LT_BBSEG-WRBTR = LV_KPRLO.      "현지통화금액(KRW)
      LT_BBSEG-GSBER = LV_GSBER.      "사업영역
      APPEND LT_BBSEG. CLEAR LT_BBSEG.

      LT_BBSEG-NEWBS = '50'.          "전기키
      LT_BBSEG-NEWKO = '0007250202'.  "계정-확정계약 평가이익:비철
      LT_BBSEG-WRBTR = LV_KPRLO.      "현지통화금액(KRW)
      LT_BBSEG-GSBER = LV_GSBER.      "사업영역
      APPEND LT_BBSEG. CLEAR LT_BBSEG.

*     전표생성 펑션 Call
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
        GS_OUTTAB-ZBELNR = GV_BELNR.
        GS_OUTTAB-ZGJAHR = GV_BUDAT(4).
        GS_OUTTAB-AENAM  = SY-UNAME.
        GS_OUTTAB-AEDAT  = SY-DATLO.
        GS_OUTTAB-AEZET  = SY-TIMLO.
      ENDIF.

      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.


      "UPDATE CBO TABLE 선물손익확정.
      UPDATE ZNFT1051 SET ZBELNR = GV_BELNR
                          ZGJAHR = GV_BUDAT(4)
                          AENAM = SY-UNAME
                          AEDAT = SY-DATLO
                          AEZET = SY-TIMLO
                    WHERE CFUTN = GS_OUTTAB-CFUTN
                         AND NFUTN = GS_OUTTAB-NFUTN.

      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.
    ELSE.

      LV_UPRLO = ABS( LV_UPRLO ).
      LV_KPRLO = ABS( LV_KPRLO ).

      CONDENSE : LV_UPRLO, LV_KPRLO.


      CLEAR : LV_KUNNR,
              LV_PRCTR,
              LV_VKGRP,
              GV_BELNR,
              GT_RETMSG[],
              GT_BDCTAB[].


      LV_PRCTR = GS_OUTTAB-PRCTR.        "손익센터
      LV_VKGRP = GS_OUTTAB-VKGRP.        "영업그룹
      LV_KUNNR = GS_OUTTAB-KUNNR.        "고객

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
      LT_BBSEG-NEWKO = '0007240105'.  "계정-파생상품 거래이익:동선물
      LT_BBSEG-WRBTR = LV_KPRLO.      "현지통화금액(KRW)
      LT_BBSEG-GSBER = LV_GSBER.      "사업영역
      APPEND LT_BBSEG. CLEAR LT_BBSEG.

      LT_BBSEG-NEWBS = '40'.          "전기키
      LT_BBSEG-NEWKO = '0005150901'.  "계정-동선물정산손익
      LT_BBSEG-WRBTR = LV_KPRLO.      "현지통화금액(KRW)
      LT_BBSEG-GSBER = LV_GSBER.      "사업영역
      LT_BBSEG-PRCTR = LV_PRCTR.      "손익센터
*___수익성세그멘트
      LT_BBSEG-RKE_BUKRS      = GS_OUTTAB-BUKRS.
      LT_BBSEG-RKE_KNDNR      = LV_KUNNR .      "고객
      LT_BBSEG-RKE_PRCTR      = LV_PRCTR .      "손익센터
      LT_BBSEG-RKE_KMVKGR     = LV_VKGRP .      "영업그룹
      APPEND LT_BBSEG. CLEAR LT_BBSEG.

      LT_BBSEG-NEWBS = '40'.          "전기키
      LT_BBSEG-NEWKO = '0007490202'.  "계정-확정계약 평가손실:비철
      LT_BBSEG-WRBTR = LV_KPRLO.      "현지통화금액(KRW)
      LT_BBSEG-GSBER = LV_GSBER.      "사업영역
      APPEND LT_BBSEG. CLEAR LT_BBSEG.

      LT_BBSEG-NEWBS = '50'.          "전기키
      LT_BBSEG-NEWKO = '0002260202'.  "계정-확정계약대:비철선물
      LT_BBSEG-WRBTR = LV_KPRLO.      "현지통화금액(KRW)
      LT_BBSEG-GSBER = LV_GSBER.      "사업영역
      APPEND LT_BBSEG. CLEAR LT_BBSEG.


*     전표생성 펑션 Call
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
        GS_OUTTAB-ZBELNR = GV_BELNR.
        GS_OUTTAB-ZGJAHR = GV_BUDAT(4).
        GS_OUTTAB-AENAM  = SY-UNAME.
        GS_OUTTAB-AEDAT  = SY-DATLO.
        GS_OUTTAB-AEZET  = SY-TIMLO.
      ENDIF.

      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.

      UPDATE ZNFT1051 SET ZBELNR = GV_BELNR
                          ZGJAHR = GV_BUDAT(4)
                          AENAM = SY-UNAME
                          AEDAT = SY-DATLO
                          AEZET = SY-TIMLO
                    WHERE CFUTN = GS_OUTTAB-CFUTN
                      AND NFUTN = GS_OUTTAB-NFUTN.

      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " MAKE_BDC_DATA_NEW
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
*&      Form  UPDATE_RESULT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_RESULT .
  DATA: LV_FLAG.

*___ZLST1051 Update
  LOOP AT GT_1051.
    GT_1051-ZBELNR = GV_BELNR.
    GT_1051-ZGJAHR = GV_BUDAT(4).
    GT_1051-AENAM = SY-UNAME.
    GT_1051-AEDAT = SY-DATLO.
    GT_1051-AEZET = SY-TIMLO.

    MODIFY GT_1051.
  ENDLOOP.

  MODIFY ZNFT1051 FROM TABLE GT_1051.


ENDFORM.                    " UPDATE_RESULT
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
  IF OK_SAVE = 'REVS' AND GV_ERROR IS INITIAL.
    PERFORM DATA_SELECT.

    LEAVE TO SCREEN 0.
  ENDIF.
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
                   ' ' 'RF05A-BELNS'       GS_OUTTAB-ZBELNR,
                   ' ' 'BKPF-BUKRS'        GS_OUTTAB-BUKRS,
                   ' ' 'RF05A-GJAHS'       GS_OUTTAB-ZGJAHR,
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

    UPDATE ZNFT1051 SET ZBELNR = ''
                        ZGJAHR = ''
                        AENAM = SY-UNAME
                        AEDAT = SY-DATLO
                        AEZET = SY-TIMLO
                  WHERE CFUTN = GS_OUTTAB-CFUTN
                       AND NFUTN = GS_OUTTAB-NFUTN.

    IF SY-SUBRC = 0.
      COMMIT WORK.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " CANCEL_FI_DOC

*&---------------------------------------------------------------------*
*&      Form  SET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DATA.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      DATE      = SY-DATLO
      DAYS      = '00'
      MONTHS    = '01'
      SIGNUM    = '-'
      YEARS     = '00'
    IMPORTING
      CALC_DATE = GV_DATE.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = GV_DATE
    IMPORTING
      LAST_DAY_OF_MONTH = GV_BUDAT.

  GV_BLDAT = GV_BUDAT.


ENDFORM.                    " SET_DATA
