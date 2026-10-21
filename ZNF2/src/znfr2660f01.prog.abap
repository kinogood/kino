*&---------------------------------------------------------------------*
*&  Include           ZNFR2660F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F4HELP_NFCTR
*&---------------------------------------------------------------------*
*       text
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
************************************************************************
* 2012/08/23   MMB04(HDY)     변경근거 : C20120823_69368               *
*----------------------------------------------------------------------*
* Comment : 만기월, 납기월 조건을 만기일, 납기일로 수정
************************************************************************
FORM F4HELP_NFCTR  USING    PV_NFCTR.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_NFCTR.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_NFCTR.

*___화면상의 회사코드를 읽는다.
  SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = 'ZNFR2660'
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
      DYNAME     = 'ZNFR2660'
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
*&      Form  F4HELP_VKGRP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_VKGRP  USING    PV_VKGRP.
  RANGES: LR_PRCTR  FOR  ZNFT1000-PRCTR.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_VKGRP,
            LR_PRCTR.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE, GT_VKGRP,
            LR_PRCTR.

  LR_PRCTR[] = S_PRCTR[].

*___화면상의 데이터를 읽는다.
  SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'S_PRCTR-LOW'.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'S_PRCTR-HIGH'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = 'ZNFR2660'
      DYNUMB     = '1000'
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  LOOP AT SCR_FIELDS.
    CASE SCR_FIELDS-FIELDNAME.
      WHEN 'P_BUKRS'.
        P_BUKRS       = SCR_FIELDS-FIELDVALUE.
      WHEN 'S_PRCTR-LOW'.
        LR_PRCTR-LOW  = SCR_FIELDS-FIELDVALUE.
        PERFORM CONVERSION_EXIT_ALPHA USING 'I' LR_PRCTR-LOW.
      WHEN 'S_PRCTR-HIGH'.
        LR_PRCTR-HIGH = SCR_FIELDS-FIELDVALUE.
        PERFORM CONVERSION_EXIT_ALPHA USING 'I' LR_PRCTR-HIGH.
    ENDCASE.
  ENDLOOP.

  READ TABLE LR_PRCTR INDEX 1 TRANSPORTING SIGN.
  IF SY-SUBRC = 0.
    IF LR_PRCTR-LOW  IS NOT INITIAL OR
       LR_PRCTR-HIGH IS NOT INITIAL.
      IF LR_PRCTR-HIGH IS NOT INITIAL.
        LR_PRCTR-OPTION = 'BT'.
      ELSE.
        LR_PRCTR-OPTION = 'EQ'.
      ENDIF.

      MODIFY LR_PRCTR INDEX 1.
    ELSE.
      DELETE LR_PRCTR INDEX 1.
    ENDIF.

  ELSE.
    IF LR_PRCTR-LOW  IS NOT INITIAL OR
       LR_PRCTR-HIGH IS NOT INITIAL.
      IF LR_PRCTR-HIGH IS NOT INITIAL.
        LR_PRCTR-SIGN   = 'I'.
        LR_PRCTR-OPTION = 'BT'.
        APPEND LR_PRCTR.
      ELSE.
        LR_PRCTR-SIGN   = 'I'.
        LR_PRCTR-OPTION = 'EQ'.
        APPEND LR_PRCTR.
      ENDIF.
    ENDIF.
  ENDIF.

  SELECT VKGRP
*         VTEXT
    INTO TABLE GT_VKGRP
    FROM ZNFT0003
   WHERE KOKRS =  P_BUKRS    "회사코드
     AND PRCTR IN LR_PRCTR.  "손익센터

  IF SY-SUBRC EQ 0.
    LOOP AT GT_VKGRP.
      PERFORM GET_VKGRP_DESC USING P_BUKRS
                                   GT_VKGRP-VKGRP
                                   GT_VKGRP-VTEXT.

      MODIFY GT_VKGRP.
    ENDLOOP.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '사업부가 없습니다.'.
    EXIT.
  ENDIF.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZNFT0003'.
  IT_FIELDS-FIELDNAME  = 'VKGRP'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT0003'.
  IT_FIELDS-FIELDNAME  = 'VTEXT'.
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
      FULL_TABLE                   = GT_VKGRP
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_VKGRP INDEX LD_TABIX.
  IF SY-SUBRC = 0.
    PV_VKGRP = GT_VKGRP-VKGRP.
  ENDIF.

ENDFORM.                    " F4HELP_VKGRP

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

*  GS_SORT-SPOS = 2.
*  GS_SORT-FIELDNAME = 'NFCTR'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 3.
*  GS_SORT-FIELDNAME = 'NFCTR_NM'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 4.
*  GS_SORT-FIELDNAME = 'PRCTR'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 5.
*  GS_SORT-FIELDNAME = 'PRCTR_NM'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 6.
*  GS_SORT-FIELDNAME = 'VKGRP'.
*  GS_SORT-UP = 'X'.
*  GS_SORT-COMP = 'X'.
*  GS_SORT-SUBTOT = 'X'.
*  APPEND GS_SORT TO GT_SORT.
*
*  GS_SORT-SPOS = 7.
*  GS_SORT-FIELDNAME = 'VKGRP_NM'.
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

  PERFORM SET_FIELDCAT USING:
    'BUKRS'    '회사코드'         '10'   'C'   ' '     ,
    'NFCTR'    '사업부'           '10'   'C'   'ALPHA' ,
    'NFCTR_NM' '사업부명'         '10'   'L'   ' '     ,
    'PRCTR'    '손익센터'         '10'   'C'   'ALPHA' ,
    'PRCTR_NM' '손익센터명'       '10'   'L'   ' '     ,
    'VKGRP'    '영업그룹'         '10'   'C'   'ALPHA' ,
    'VKGRP_NM' '영업그룹명'       '10'   'L'   ' '     ,
    'NFUTN'    '선물집행번호'     '10'   'L'   ' '     ,
    'RUDAT'    '선물집행일'       '10'   'C'   ' '     ,
    'EMENG'    '집행수량'         '10'   'R'   ' '     ,
    'NFKEY'    '비철구분'         '10'   'C'   ' '     ,
    'MEINS'    '단위'             '10'   'C'   ' '     ,
**** HDY 20120823 START [C20120823_69368]
**** 만기월을 만기일로 변경, 필드이름 수정
*    'ENDMM'    '만기월'           '8'    'C'   ' '     ,
    'ENDAT'    '만기일'           '8'    'C'   ' '     ,
**** HDY 20120823 END
    'CONNO'    '계약번호'         '10'   'L'   ' '     ,
    'COTXT'    '계약명'           '10'   'L'   ' '     ,
    'KUNNR'    '고  객'           '10'   'C'   'ALPHA' ,
    'NCUST'    '고객명'           '20'   'L'   ' '     ,
    'VBELN'    '판매오더번호'     '10'   'C'   'ALPHA' ,
    'POSNR'    '순번'             '4'    'C'   ' '     ,
    'NF_QTY'   '비철량'           '10'   'R'   ' '     ,
    'NF_MEINS' '단위'             '10'   'C'   ' '     ,
**** HDY 20120823 START [C20120823_69368]
**** 납기월을 납기일로 변경, 필드이름 수정
    'DELI_MM'  '납기일'           '8'    'C'   ' '     ,
**** HDY 20120823 END
    'KWMENG'   '주문수량'         '10'   'R'   ' '     ,
    'VRKME'    '주문단위'         '10'   'C'   ' '     ,
    'FKLMG'    '납품수량'         '10'   'R'   ' '     ,
    'GBSTA'    '주문상태'         '10'   'C'   ' '     ,
    'GBSTA_NM' '주문상태'         '10'   'L'   ' '     ,
    'ABGRU'    '거부사유'         '10'   'C'   ' '     ,
    'ABGRU_NM' '거부사유'         '10'   'L'   ' '     ,
    'KUNNR2'    '판매처'          '10'   'C'   'ALPHA' ,
    'KUNNR2_NM' '판매처명'        '20'   'L'   ' '     ,
    'KUNNR3'    '납품처'          '10'   'C'   'ALPHA' ,
    'KUNNR3_NM' '납품처명'        '20'   'L'   ' '     .

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
    WHEN 'BUKRS' OR 'GBSTA' OR 'ABGRU' OR 'MATNR'.
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'PRICE'.
      GS_FIELDCAT-CFIELDNAME = 'WAERS'.
    WHEN 'EMENG'.
      GS_FIELDCAT-QFIELDNAME = 'MEINS'.
    WHEN 'NF_QTY'.
      GS_FIELDCAT-QFIELDNAME = 'NF_MEINS'.
    WHEN 'KWMENG' OR 'FKLMG'.
      GS_FIELDCAT-QFIELDNAME = 'VRKME'.
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

  DATA: LV_TABIX TYPE SY-TABIX.

  DATA: LV_VGW  TYPE /NFM/VGW,
        LV_VGE  TYPE /NFM/VGE,
        LV_DATE TYPE SY-DATUM.

  SELECT Z1~BUKRS
         Z4~NFCTR
         Z4~PRCTR
         Z4~VKGRP
         Z1~NFUTN
         Z1~RUDAT
         Z1~EMENG
         Z1~MEINS
**** HDY 20120823 START [C20120823_69368]
**** 납기월을 납기일로 수정
*         Z2~ENDMM
         Z1~ENDAT
**** HDY 20120823 END
         Z4~CONNO
         Z4~COTXT
         Z4~KUNNR
         Z4~NCUST
         V1~VBELN
         V1~POSNR
         V1~KWMENG
         V1~VRKME
         V1~UMVKN   "(판매수량을 SKU로 환산하기 위한 분모)
         V1~UMVKZ   "(판매수량을 SKU로 환산하기 위한 분자)
         Z1~NFKEY
         " VBRP-FKLMG
         " VBUP-GBSTA
         V1~ABGRU
         V1~MATNR
         INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB
    FROM ZNFT1020 AS Z1
         INNER JOIN ZNFT1011 AS Z2
           ON Z2~REQNO EQ Z1~REQNO AND Z2~H_NO1 EQ Z1~H_NO1
         INNER JOIN ZNFT1010 AS Z3
           ON Z3~REQNO EQ Z1~REQNO
         INNER JOIN ZNFT1000 AS Z4
           ON Z4~CONNO EQ Z2~CONNO
         INNER JOIN VBAP AS V1
           ON V1~CONNO EQ Z4~CONNO
   WHERE Z1~BUKRS EQ P_BUKRS
     AND Z4~NFCTR IN S_NFCTR
     AND Z4~PRCTR IN S_PRCTR
     AND Z4~VKGRP IN S_VKGRP
     AND Z1~NFKEY IN S_NFKEY
     AND Z1~NFUTN IN S_NFUTN
     AND Z1~RUDAT IN S_RUDAT
**** HDY 20120823 START [C20120823_69368]
**** 납기월을 납기일로 수정
*     AND Z2~ENDMM IN S_ENDMM
     AND Z1~ENDAT IN S_ENDMM
**** HDY 20120823 END
     AND Z4~CONNO IN S_CONNO
     AND Z4~KUNNR IN S_KUNNR
     AND V1~VBELN IN S_VBELN
*....조건추가 - 만기이동에 의해 삭제된 건 조회되지 않도록 개선
*    (C20121211_32817 Req.by 구영헌 2012/12/18)
     AND ( Z1~YNCAN = ' ' OR ( Z1~CONFM <> '3' AND Z1~CONFM <> '7' ) ).
*    AND V2~EDATU IN S_EDATU.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    LV_TABIX = SY-TABIX.

*   - 사업부
    PERFORM GET_NFCTR_DESC USING GS_OUTTAB-BUKRS
                                 GS_OUTTAB-NFCTR
                                 GS_OUTTAB-NFCTR_NM.

*   - 손익센터
    PERFORM GET_PRCTR_DESC USING GS_OUTTAB-BUKRS
                                 GS_OUTTAB-PRCTR
                                 GS_OUTTAB-PRCTR_NM.

*   - 영업그룹
    PERFORM GET_VKGRP_DESC USING GS_OUTTAB-BUKRS
                                 GS_OUTTAB-VKGRP
                                 GS_OUTTAB-VKGRP_NM.

**   비철구분
*    PERFORM DOMAIN_VALUE_GET USING 'ZNFKEY_1'
*                                   GS_OUTTAB-NFKEY
*                                   GS_OUTTAB-NFKEY_NM.

*   - 납품수량
"-> CCM : 2023.04.20 ZITCS4HDEV06 - VBRP 확인
*-- [CCM-MM] DRAFT 지시자 추가 ZLSGMM4 2023.04.19
    SELECT SINGLE FKLMG INTO GS_OUTTAB-FKLMG
      FROM VBRP
     WHERE AUBEL EQ GS_OUTTAB-VBELN
       AND AUPOS EQ GS_OUTTAB-POSNR
       AND DRAFT = ' '.

*   - 주문상태
    "CCM : 2023.04.10  ZITCS4HDEV04 - VBUP -> VBAP 테이블로 변경
    SELECT SINGLE GBSTA INTO GS_OUTTAB-GBSTA
      FROM VBAP " VBUP
     WHERE VBELN EQ GS_OUTTAB-VBELN
       AND POSNR EQ GS_OUTTAB-POSNR.

*   - 처리상태
    IF GS_OUTTAB-GBSTA IS NOT INITIAL.
      PERFORM DOMAIN_VALUE_GET USING 'STATV'
                                     GS_OUTTAB-GBSTA
                                     GS_OUTTAB-GBSTA_NM.
    ENDIF.

*   - 거절사유
    IF GS_OUTTAB-ABGRU IS NOT INITIAL.
      SELECT SINGLE BEZEI INTO GS_OUTTAB-ABGRU_NM
        FROM TVAGT
       WHERE SPRAS EQ SY-LANGU
         AND ABGRU EQ GS_OUTTAB-ABGRU.
    ENDIF.

*   - 비철량 / 단위
    IF GS_OUTTAB-MATNR IS NOT INITIAL.
      SELECT SINGLE VGW VGE INTO (LV_VGW, LV_VGE)
        FROM /NFM/TVGW
       WHERE MATNR EQ GS_OUTTAB-MATNR
         AND KAPPL EQ 'V'
         AND ORG   EQ P_BUKRS
         AND NES   EQ GS_OUTTAB-NFKEY.

*.....S/O의 주문단위와 기본단위가 다른 CASE에 대한 로직 추가
*     (C20120927_91822 Req. by 이지현 2012/10/16)
      IF LV_VGW NE 0 AND GS_OUTTAB-UMVKN NE 0.
        GS_OUTTAB-NF_QTY =
                     ( ( LV_VGW * GS_OUTTAB-KWMENG * GS_OUTTAB-UMVKZ )
                     / GS_OUTTAB-UMVKN / LV_VGE ) / 1000.
      ELSE.
        GS_OUTTAB-NF_QTY = 0.
      ENDIF.
      GS_OUTTAB-NF_MEINS = GS_OUTTAB-MEINS.
    ENDIF.

*   - 납기월
    SELECT SINGLE EDATU INTO LV_DATE
      FROM VBEP
     WHERE VBELN EQ GS_OUTTAB-VBELN
       AND POSNR EQ GS_OUTTAB-POSNR
       AND ETENR EQ 1
       AND EDATU IN S_EDATU.

    IF SY-SUBRC EQ 0.
**** HDY 20120823 START [C20120823_69368]
**** 납기월을 납기일로 수정하면서 필드에 넣는값 변경
*      GS_OUTTAB-DELI_MM = LV_DATE+0(6).
      GS_OUTTAB-DELI_MM = LV_DATE.
**** HDY 20120823 END
    ELSE.
      DELETE GT_OUTTAB INDEX LV_TABIX.
      CONTINUE.
    ENDIF.

*...S/O의 판매처 및 납품처 정보 추가
*   (C20121105_11681 Req. by 구영헌 2012/11/20)
*...판매처
    SELECT SINGLE KUNNR INTO GS_OUTTAB-KUNNR2
      FROM VBAK
     WHERE VBELN EQ GS_OUTTAB-VBELN.

*...납품처
    SELECT SINGLE KUNNR INTO GS_OUTTAB-KUNNR3
      FROM VBPA
     WHERE VBELN = GS_OUTTAB-VBELN
       AND POSNR = '000000'
       AND PARVW = 'WE'.

*...판매처명/납품처명
    PERFORM GET_KUNNR_DESC USING : GS_OUTTAB-KUNNR2
                                   GS_OUTTAB-KUNNR2_NM,

                                   GS_OUTTAB-KUNNR3
                                   GS_OUTTAB-KUNNR3_NM.

    MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.
    CLEAR : LV_TABIX, GS_OUTTAB.
  ENDLOOP.

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
      WHEN 'VBELN'.
        IF NOT GS_OUTTAB-VBELN IS INITIAL.
          SET PARAMETER ID 'AUN' FIELD GS_OUTTAB-VBELN.
          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE '판매오더가 존재하지 않습니다.'
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
    MESSAGE E003 WITH '만기월을 점검하십시오.'.
  ENDIF.

ENDFORM.                    " CHECK_ENDMM

*&---------------------------------------------------------------------*
*&      Form  CHECK_EDATU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_EDATU .

**** HDY 20120823 START [C20120823_69368]
**** 만기월만 입력조회시 오류메시지 출력되는 부분 수정
*  IF S_ENDMM-LOW IS NOT INITIAL AND
  IF S_EDATU-LOW IS NOT INITIAL AND
**** HDY 20120823 END
     ( S_EDATU-LOW+4(2) < '01' OR S_EDATU-LOW+4(2) > '12' ).
    MESSAGE E003 WITH '납기월을 점검하십시오.'.
  ENDIF.

ENDFORM.                    " CHECK_EDATU
