*&---------------------------------------------------------------------*
*&  Include           ZNFR2020F01
*&---------------------------------------------------------------------*
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
      DYNAME     = 'ZNFR2020'
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
      DYNAME     = 'ZNFR2020'
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
    INTO CORRESPONDING FIELDS OF TABLE GT_PRCTR
    FROM ZNFT0004
   WHERE KOKRS   =  P_BUKRS   "관리회계영역
     AND NFCTR   IN LR_NFCTR  "사업부
     AND BDATU  >=  SY-DATLO  "효력만료일
     AND CFACTIV =  'X'.      "선물요청(활성)

  IF SY-SUBRC <> 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '손익센터가 없습니다.'.
    EXIT.
  ENDIF.

  LOOP AT GT_PRCTR.
    PERFORM GET_PRCTR_DESC USING P_BUKRS
                                 GT_PRCTR-PRCTR
                                 GT_PRCTR-PTEXT.

    MODIFY GT_PRCTR.
  ENDLOOP.

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
      DYNAME     = 'ZNFR2020'
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
    INTO CORRESPONDING FIELDS OF TABLE GT_VKGRP
    FROM ZNFT0003
   WHERE KOKRS =  P_BUKRS    "회사코드
     AND PRCTR IN LR_PRCTR.  "손익센터

  IF SY-SUBRC <> 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '영업그룹이 없습니다.'.
    EXIT.
  ENDIF.

  LOOP AT GT_VKGRP.
    PERFORM GET_VKGRP_DESC USING P_BUKRS
                                 GT_VKGRP-VKGRP
                                 GT_VKGRP-VTEXT.

    MODIFY GT_VKGRP.
  ENDLOOP.

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
*&      Form  GET_MATNR_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_MATNR_DESC  USING    PV_MATNR
                              PV_MAKTX.

  CLEAR : PV_MAKTX.

  CHECK PV_MATNR IS NOT INITIAL.

  SELECT SINGLE MAKTX
    INTO PV_MAKTX
    FROM MAKT
   WHERE MATNR = PV_MATNR
     AND SPRAS = SY-LANGU.

ENDFORM.                    " GET_MATNR_DESC
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_RESULT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_RESULT .

  PERFORM CREATE_FIELD_CATEGORY.

  PERFORM DISPLAY_ALV_LIST.

ENDFORM.                    " DISPLAY_RESULT
*&---------------------------------------------------------------------*
*&      Form  CREATE_FIELD_CATEGORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_FIELD_CATEGORY .

  CLEAR   : GS_LAYOUT, GV_POS.

  GV_ITAB = 'GT_MAIN'.

  GS_LAYOUT-ZEBRA             = 'X'.
  GS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  GS_LAYOUT-BOX_FIELDNAME     = 'CHECK'.

  CLEAR   : GS_FIELDCAT.
  REFRESH : GT_FIELDCAT.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_FIELDCAT_DATA TABLES GT_FIELDCAT
                              USING :
      'CONNO'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '              'CONNO' 'ZNFT1053' ' ' ' '    'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 3
      ' '              'NFKEY' 'ZNFT1053' ' ' ' '    'X' ' ' ' ' ' ',

      'COTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '              'COTXT' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'CSTAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      ' '              'CSTAT' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'CSTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '계약상태'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'BUKRS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      ' '              'BUKRS' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'KUNNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'KUNNR' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'NCUST'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '              'NCUST' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'NFCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'NFCTR' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'NTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'NTEXT' 'ZNFT0005' ' ' ' '    'X' ' ' ' ' ' ',

      'PRCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'PRCTR' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'PTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'PTEXT' 'ZNFT0004' ' ' ' '    'X' ' ' ' ' ' ',

      'VKGRP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'VKGRP' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'VTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'VTEXT' 'ZNFT0003' ' ' ' '    'X' ' ' ' ' ' ',

      'SALER'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'SALER' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'WAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      ' '              'WAERS' 'ZNFT1001' ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'EMENG' 'ZNFT1001' ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'MEINS' 'ZNFT1001' ' ' ' '    'X' ' ' ' ' ' ',

      'ERDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'ERDAT' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'ERNAM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 12
      ' '              'ERNAM' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'VBELN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'VBELN' 'VBAP'     ' ' ' '    'X' ' ' ' ' ' ',

      'POSNR'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 6
      ' '              'POSNR' 'VBAP'     ' ' ' '    'X' ' ' ' ' ' ',

      'SPART'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 2
      ' '              'SPART' 'VBAP'     ' ' ' '    'X' ' ' ' ' ' ',

      'MATNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 18
      ' '              'MATNR' 'VBAP'     ' ' ' '    'X' ' ' ' ' ' ',

      'MAKTX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '              'MAKTX' 'MAKT'     ' ' ' '    'X' ' ' ' ' ' ',

      'KUNAG'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'KUNNR' 'VBAK'     ' ' ' '    'X' ' ' ' ' ' ',

      'NAMAG'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      '판매처명'       'NAME1' 'KNA1'     ' ' ' '    'X' ' ' ' ' ' ',

      'KUNWE'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '납품처'         'KUNNR' 'VBAK'     ' ' ' '    'X' ' ' ' ' ' ',

      'NAMWE'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      '납품처명'       'NAME1' 'KNA1'     ' ' ' '    'X' ' ' ' ' ' ',

      'EDATU'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'EDATU' 'VBEP'     ' ' ' '    'X' ' ' ' ' ' ',

      'VRKME'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'VRKME' 'VBAP'     ' ' ' '    'X' ' ' ' ' ' ',

      'KWMENG'   ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '             'KWMENG' 'VBAP'     ' ' ' '    ' ' ' ' ' ' ' ',

      'WAERK'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      ' '              'WAERK' 'VBAK'     ' ' ' '    'X' ' ' ' ' ' ',

      'NETWR'    'WAERK'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      ' '              'NETWR' 'VBAP'     ' ' ' '    ' ' ' ' ' ' ' ',

      'VGW'      ' '      'BME'   ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '오더비철수량'   'BLVGW' 'ZNFT1053' ' ' ' '    ' ' ' ' ' ' ' ',

      'BME'      ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'BME'  '/NFM/TNES' ' ' ' '    'X' ' ' ' ' ' '.

ENDFORM.                    " CREATE_FIELD_CATEGORY
*&---------------------------------------------------------------------*
*&      Form  MAKE_FIELDCAT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MAKE_FIELDCAT_DATA  TABLES PT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV
                          USING PV_FNAME
                                PV_CURK
                                PV_UNIT
                                PV_ICON
                                PV_CHECK
                                PV_JUST
                                PV_EMPHA
                                PV_FIX
                                PV_NOOUT
                                PV_NOZERO
                                PV_LENGTH
                                PV_TEXT
                                PV_REFF
                                PV_REFT
                                PV_TECH
                                PV_TYPE
                                PV_NOSUM
                                PV_DOSUM
                                PV_HOTSPOT
                                PV_EDIT.

  DATA : LS_FIELDCAT          TYPE SLIS_FIELDCAT_ALV.

  CLEAR : LS_FIELDCAT.

  GV_POS = GV_POS + 1.

  LS_FIELDCAT-COL_POS        = GV_POS.
  LS_FIELDCAT-FIELDNAME      = PV_FNAME.
  LS_FIELDCAT-CFIELDNAME     = PV_CURK.
  LS_FIELDCAT-QFIELDNAME     = PV_UNIT.
  LS_FIELDCAT-ICON           = PV_ICON.
  LS_FIELDCAT-CHECKBOX       = PV_CHECK.
  LS_FIELDCAT-JUST           = PV_JUST.
  LS_FIELDCAT-EMPHASIZE      = PV_EMPHA.
  LS_FIELDCAT-FIX_COLUMN     = PV_FIX.
  LS_FIELDCAT-KEY            = PV_FIX.
  LS_FIELDCAT-NO_OUT         = PV_NOOUT.
  LS_FIELDCAT-NO_ZERO        = PV_NOZERO.
  LS_FIELDCAT-OUTPUTLEN      = PV_LENGTH.
  LS_FIELDCAT-SELTEXT_S      = PV_TEXT.
  LS_FIELDCAT-SELTEXT_M      = PV_TEXT.
  LS_FIELDCAT-SELTEXT_L      = PV_TEXT.
  LS_FIELDCAT-REPTEXT_DDIC   = PV_TEXT.
  LS_FIELDCAT-REF_FIELDNAME  = PV_REFF.
  LS_FIELDCAT-REF_TABNAME    = PV_REFT.
  LS_FIELDCAT-TECH           = PV_TECH.
  LS_FIELDCAT-DATATYPE       = PV_TYPE.
  LS_FIELDCAT-NO_SUM         = PV_NOSUM.
  LS_FIELDCAT-DO_SUM         = PV_DOSUM.
  LS_FIELDCAT-HOTSPOT        = PV_HOTSPOT.
  LS_FIELDCAT-EDIT           = PV_EDIT.

  LS_FIELDCAT-TABNAME        = GV_ITAB.

  APPEND LS_FIELDCAT TO PT_FIELDCAT.

ENDFORM.                    " MAKE_FIELDCAT_DATA
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_ALV_LIST.

  GS_VARIANT-REPORT  = SY-REPID.
  GS_VARIANT-HANDLE  = '0001'.

  GV_REPID = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_USER_COMMAND  = GV_USER_COMMAND
      I_CALLBACK_PF_STATUS_SET = GV_STATUS_SET
*      I_CALLBACK_TOP_OF_PAGE   = GV_TOP_OF_PAGE
      I_CALLBACK_PROGRAM       = GV_REPID
      I_GRID_SETTINGS          = GV_GRID_SETTINGS
      IS_LAYOUT                = GS_LAYOUT
      IT_FIELDCAT              = GT_FIELDCAT
      IT_SORT                  = GT_SORT
      I_SAVE                   = 'A'
      IS_VARIANT               = GS_VARIANT
      IT_EVENTS                = GT_EVENTS
      IT_EVENT_EXIT            = GT_EVENTS_EXIT
    TABLES
      T_OUTTAB                 = GT_MAIN
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

  IF SY-SUBRC <> 0.
    MESSAGE E003 WITH 'Grid Display Error!'.
  ENDIF.

ENDFORM.                    " DISPLAY_ALV_LIST
*&---------------------------------------------------------------------
*& Form PF_STATUS_SET
*&---------------------------------------------------------------------
FORM PF_STATUS_SET USING  EXTAB  TYPE  SLIS_T_EXTAB.
  DATA: LS_EXTAB  TYPE SLIS_EXTAB.

  SET PF-STATUS 'STANDARD' EXCLUDING  EXTAB .

ENDFORM.                " PF_STATUS_SET
*&---------------------------------------------------------------------
*& Form USER_COMMAND
*&---------------------------------------------------------------------
FORM USER_COMMAND USING PV_UCOMM
                        PS_SELFIELD TYPE SLIS_SELFIELD.
  CASE PV_UCOMM.
    WHEN 'RFSH'.

    WHEN '&IC1'.
      CASE PS_SELFIELD-FIELDNAME.
        WHEN 'CONNO'.
          IF PS_SELFIELD-VALUE IS NOT INITIAL.
            SET PARAMETER ID 'ZNFCON' FIELD PS_SELFIELD-VALUE.

            CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
          ENDIF.

        WHEN 'VBELN'.
          IF PS_SELFIELD-VALUE IS NOT INITIAL.
            SET PARAMETER ID 'AUN' FIELD PS_SELFIELD-VALUE.

            CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
          ENDIF.

      ENDCASE.
  ENDCASE.

  PS_SELFIELD-REFRESH    = 'X'.
  PS_SELFIELD-COL_STABLE = 'X'.
  PS_SELFIELD-ROW_STABLE = 'X'.

ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  CONVERT_MATERIAL_UNIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CONVERT_MATERIAL_UNIT  USING  PV_MATNR LIKE MARA-MATNR
                                   PV_MEINS LIKE MARA-MEINS
                                   PV_BMEIN LIKE MARA-MEINS
                                   PV_BRGEW.

  DATA : LV_BRGEW  LIKE MARA-BRGEW,
         LV_MENGE  LIKE EKPO-MENGE,
         LV_MENGE1 TYPE P DECIMALS 2,
         LV_MEINS  LIKE MARA-MEINS.

  CHECK PV_MEINS <> PV_BMEIN.

  CLEAR : LV_MENGE, LV_MEINS.

  SELECT SINGLE MEINS
    INTO LV_MEINS
    FROM MARA
   WHERE MATNR = PV_MATNR.

  CHECK SY-SUBRC = 0.

  CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
    EXPORTING
      MATNR                = PV_MATNR
      INPUT                = PV_BRGEW
      MEINH                = PV_MEINS
      KZMEINH              = 'X'
      MEINS                = LV_MEINS
    IMPORTING
      OUTPUT               = LV_MENGE
    EXCEPTIONS
      CONVERSION_NOT_FOUND = 01
      INPUT_INVALID        = 02
      MATERIAL_NOT_FOUND   = 03
      MEINH_NOT_FOUND      = 04
      MEINS_MISSING        = 05
      NO_MEINH             = 06
      OUTPUT_INVALID       = 07
      OVERFLOW             = 08.

  IF SY-SUBRC = 0.
    CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
      EXPORTING
        MATNR                = PV_MATNR
        INPUT                = LV_MENGE
        MEINH                = PV_BMEIN
        KZMEINH              = SPACE
        MEINS                = LV_MEINS
      IMPORTING
        OUTPUT               = LV_MENGE
      EXCEPTIONS
        CONVERSION_NOT_FOUND = 01
        INPUT_INVALID        = 02
        MATERIAL_NOT_FOUND   = 03
        MEINH_NOT_FOUND      = 04
        MEINS_MISSING        = 05
        NO_MEINH             = 06
        OUTPUT_INVALID       = 07
        OVERFLOW             = 08.
  ELSE.
    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        INPUT                = PV_BRGEW
        ROUND_SIGN           = 'X'
        UNIT_IN              = PV_MEINS
        UNIT_OUT             = PV_BMEIN
      IMPORTING
        OUTPUT               = LV_MENGE
      EXCEPTIONS
        CONVERSION_NOT_FOUND = 1
        DIVISION_BY_ZERO     = 2
        INPUT_INVALID        = 3
        OUTPUT_INVALID       = 4
        OVERFLOW             = 5
        TYPE_INVALID         = 6
        UNITS_MISSING        = 7
        UNIT_IN_NOT_FOUND    = 8
        UNIT_OUT_NOT_FOUND   = 9
        OTHERS               = 10.
  ENDIF.

  IF SY-SUBRC = 0.
    LV_MENGE1 = LV_MENGE.
    PV_BRGEW  = LV_MENGE1.
  ENDIF.

ENDFORM.                    " CONVERT_MATERIAL_UNIT
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_CHECKBOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_CHECKBOX  USING    PV_ERROR.

  CLEAR : PV_ERROR.

  IF S_SPART[] IS NOT INITIAL OR S_VBELN[] IS NOT INITIAL OR
     S_SERDT[] IS NOT INITIAL.
    CLEAR : P_CHK02.

    P_CHK01 = 'X'.
  ENDIF.

  IF P_CHK01 IS INITIAL AND P_CHK02 IS INITIAL.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH 'S/O 연결여부를 선택하시기 바랍니다.'.

    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_CHECKBOX
*&---------------------------------------------------------------------*
*&      Form  GET_CONTRACT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CONTRACT_DATA .
  DATA: LS_TVGW     LIKE GT_TVGW.

  CLEAR   : GT_MAIN, GT_1001, GT_VBAP, GR_CONNO.
  REFRESH : GT_MAIN, GT_1001, GT_VBAP, GR_CONNO.

*___계약정보
  PERFORM GET_ZNFT1000_DATA.

  CHECK GR_CONNO[] IS NOT INITIAL.

*___계약에 해당하는 판매오더 정보
  PERFORM GET_VBAP_DATA.

*___자재 비철량
  PERFORM GET_MATERIAL_NFQTY.

  LOOP AT GT_1001.
    LOOP AT GT_VBAP WHERE CONNO = GT_1001-CONNO.
*___연결건을 선택하지 않은 경우 Skip
      IF P_CHK01 IS INITIAL.
        EXIT.
      ENDIF.

*___파트너 조건 포함 비철량 - 영업영역
      LOOP AT GT_TVGW WHERE PARNR = GT_VBAP-KUNNR
                        AND MATNR = GT_VBAP-MATNR
                        AND KAPPL = 'V'
                        AND ORG   = GT_VBAP-VKORG
                        AND VTWEG = GT_VBAP-VTWEG
                        AND NES   = GT_1001-NFKEY.

        PERFORM MOVE_SALES_ORDER_DATA.

      ENDLOOP.

      IF SY-SUBRC <> 0.
*___파트너 조건 제외 비철량 - 영업영역
        LOOP AT GT_TVGW WHERE MATNR = GT_VBAP-MATNR
                          AND KAPPL = 'V'
                          AND ORG   = GT_VBAP-VKORG
                          AND VTWEG = GT_VBAP-VTWEG
                          AND NES   = GT_1001-NFKEY.

          PERFORM MOVE_SALES_ORDER_DATA.

        ENDLOOP.

        IF SY-SUBRC <> 0.
*___플랜트별 비철량 - MRP View
          LOOP AT GT_TVGW WHERE MATNR = GT_VBAP-MATNR
                            AND WERKS = GT_VBAP-WERKS
                            AND NES   = GT_1001-NFKEY.

            PERFORM MOVE_SALES_ORDER_DATA.

          ENDLOOP.

          IF SY-SUBRC <> 0.
*___비철량 - MRP View
            READ TABLE GT_TVGW INTO LS_TVGW
                               WITH KEY MATNR = GT_VBAP-MATNR.
            IF SY-SUBRC = 0.
              LOOP AT GT_TVGW WHERE MATNR = GT_VBAP-MATNR
                                AND WERKS = LS_TVGW-WERKS
                                AND NES   = GT_1001-NFKEY.

                PERFORM MOVE_SALES_ORDER_DATA.

              ENDLOOP.

              IF SY-SUBRC <> 0.
                CLEAR : GT_TVGW.

                PERFORM MOVE_SALES_ORDER_DATA.
              ENDIF.
            ELSE.
              CLEAR : GT_TVGW.

              PERFORM MOVE_SALES_ORDER_DATA.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF SY-SUBRC <> 0 AND P_CHK02 = 'X'.    "미연결건
      CLEAR : GT_VBAP, GT_TVGW.

      PERFORM MOVE_SALES_ORDER_DATA.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_CONTRACT_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_ZNFT1000_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ZNFT1000_DATA .

  CLEAR   : GT_1001, GR_CONNO.
  REFRESH : GT_1001, GR_CONNO.

*___계약정보
  SELECT A~CONNO
         A~COTXT
         A~CSTAT
         A~BUKRS
         A~KUNNR
         A~NCUST
         A~NFCTR
         A~PRCTR
         A~VKGRP
         A~SALER
         A~ERDAT
         A~ERNAM
         B~NFKEY
         B~WAERS
         B~EMENG
         B~MEINS
    INTO CORRESPONDING FIELDS OF TABLE GT_1001
    FROM ZNFT1000 AS A
   INNER JOIN ZNFT1001 AS B
      ON A~CONNO = B~CONNO
   WHERE A~BUKRS =  P_BUKRS
     AND A~CONNO IN S_CONNO
     AND A~NFCTR IN S_NFCTR
     AND A~PRCTR IN S_PRCTR
     AND A~VKGRP IN S_VKGRP
     AND A~ERDAT IN S_ERDAT
     AND A~ERNAM IN S_ERNAM
     AND A~CSTAT <> 'D'
     AND B~NFKEY IN S_NFKEY.

*___계약번호/비철구분별 선물손익 집계
  LOOP AT GT_1001.
    CLEAR : GR_CONNO.

    GR_CONNO-SIGN   = 'I'.
    GR_CONNO-OPTION = 'EQ'.
    GR_CONNO-LOW    = GT_1001-CONNO.

    COLLECT GR_CONNO.
  ENDLOOP.

ENDFORM.                    " GET_ZNFT1000_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_VBAP_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_VBAP_DATA .

  CLEAR   : GT_VBAP.
  REFRESH : GT_VBAP.

*___판매오더정보
  SELECT A~VBELN
         A~POSNR
         B~VKORG
         B~KUNNR
         A~MATNR
         A~ARKTX
         A~WERKS
         B~VTWEG
         A~SPART
         A~NETWR
         B~WAERK
         A~KWMENG
         A~VRKME
         A~CONNO
    INTO TABLE GT_VBAP
    FROM VBAP AS A
   INNER JOIN VBAK AS B
      ON A~VBELN =  B~VBELN
   WHERE A~CONNO IN GR_CONNO
     AND A~VBELN IN S_VBELN
     AND A~SPART IN S_SPART
     AND B~ERDAT IN S_SERDT.

ENDFORM.                    " GET_VBAP_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_MATERIAL_NFQTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_MATERIAL_NFQTY .

  CLEAR   : GT_TVGW.
  REFRESH : GT_TVGW.

  LOOP AT GT_VBAP.
    READ TABLE GT_TVGW WITH KEY MATNR = GT_VBAP-MATNR.
    IF SY-SUBRC <> 0.
      SELECT *
        APPENDING CORRESPONDING FIELDS OF TABLE GT_TVGW
        FROM /NFM/TVGW
       WHERE MATNR = GT_VBAP-MATNR
         AND KAPPL = 'V'
         AND ORG   = GT_VBAP-VKORG.

      IF SY-SUBRC <> 0.
*___위에서 못찾은 경우 MRP View 데이터 검색
        SELECT MATNR
               WERKS
               NES
               KGW AS VGW
               KGU AS VGE
          APPENDING CORRESPONDING FIELDS OF TABLE GT_TVGW
          FROM /NFM/TKGW
         WHERE MATNR = GT_VBAP-MATNR.
      ENDIF.
    ENDIF.
  ENDLOOP.

*___단위
  LOOP AT GT_TVGW.
    SELECT SINGLE BME
      INTO GT_TVGW-BME
      FROM /NFM/TNES
     WHERE NES = GT_TVGW-NES.

    MODIFY GT_TVGW.
  ENDLOOP.

ENDFORM.                    " GET_MATERIAL_NFQTY
*&---------------------------------------------------------------------*
*&      Form  MOVE_SALES_ORDER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MOVE_SALES_ORDER_DATA .
  DATA: LV_KWMENG    LIKE VBAP-KWMENG,
        LV_ERROR.

  CLEAR : GT_MAIN.

  MOVE-CORRESPONDING GT_1001 TO GT_MAIN.

  GT_MAIN-VBELN  = GT_VBAP-VBELN.        "판매오더
  GT_MAIN-POSNR  = GT_VBAP-POSNR.        "판매오더품목
  GT_MAIN-SPART  = GT_VBAP-SPART.        "제품군
  GT_MAIN-MATNR  = GT_VBAP-MATNR.        "자재코드
  GT_MAIN-MAKTX  = GT_VBAP-ARKTX.        "자재내역
  GT_MAIN-KUNAG  = GT_VBAP-KUNNR.        "판매처
  GT_MAIN-VRKME  = GT_VBAP-VRKME.        "오더단위
  GT_MAIN-KWMENG = GT_VBAP-KWMENG.       "오더수량
  GT_MAIN-WAERK  = GT_VBAP-WAERK.        "오더통화
  GT_MAIN-NETWR  = GT_VBAP-NETWR.        "오더금액
  GT_MAIN-MAVGW  = GT_TVGW-VGW.          "자재비철량
  GT_MAIN-BME    = GT_TVGW-BME.          "비철단위
  GT_MAIN-VGE    = GT_TVGW-VGE.          "기준수량

*___기준수량단위 - 자재마스터 기본단위
  SELECT SINGLE MEINS
    INTO GT_MAIN-BMEIN
    FROM MARA
   WHERE MATNR = GT_MAIN-MATNR.

*___오더 비철수량
  LV_KWMENG = GT_MAIN-KWMENG.

  PERFORM CONVERT_MATERIAL_UNIT USING GT_MAIN-MATNR
                                      GT_MAIN-VRKME
                                      GT_MAIN-BMEIN
                                      LV_KWMENG.

  IF GT_MAIN-VGE IS NOT INITIAL.
    GT_MAIN-VGW = LV_KWMENG * GT_MAIN-MAVGW / GT_MAIN-VGE.
  ENDIF.

*___납품처
  SELECT SINGLE KUNNR
    INTO GT_MAIN-KUNWE
    FROM VBPA
   WHERE VBELN = GT_MAIN-VBELN
     AND POSNR = '000000'
     AND PARVW = 'WE'.

*___납품일자
  SELECT SINGLE EDATU
    INTO GT_MAIN-EDATU
    FROM VBEP
   WHERE VBELN = GT_MAIN-VBELN
     AND POSNR = GT_MAIN-POSNR
     AND ETENR = '0001'.

*___계약상태내역
  PERFORM DOMAIN_VALUE_GET USING 'ZCSTAT'
                                 GT_MAIN-CSTAT
                                 GT_MAIN-CSTXT.

*___고객명
  IF GT_MAIN-KUNNR IS NOT INITIAL.
    PERFORM GET_KUNNR_DESC USING GT_MAIN-KUNNR
                                 GT_MAIN-NCUST.
  ENDIF.

*___사업부명
  PERFORM GET_NFCTR_DESC USING P_BUKRS
                               GT_MAIN-NFCTR
                               GT_MAIN-NTEXT.

*___손익센터명
  PERFORM GET_PRCTR_DESC USING GV_KOKRS
                               GT_MAIN-PRCTR
                               GT_MAIN-PTEXT.

*___영업그룹명
  PERFORM GET_VKGRP_DESC USING GV_KOKRS
                               GT_MAIN-VKGRP
                               GT_MAIN-VTEXT.

*___자재명
*  PERFORM GET_MATNR_DESC USING GT_MAIN-MATNR
*                               GT_MAIN-MAKTX.

*___판매처명/납품처명
  PERFORM GET_KUNNR_DESC USING : GT_MAIN-KUNAG
                                 GT_MAIN-NAMAG,

                                 GT_MAIN-KUNWE
                                 GT_MAIN-NAMWE.

*___가격구분/비철수주가
  PERFORM PRICE_CLASSIFICATION USING GT_MAIN-CONNO
                                     GT_MAIN-NFKEY
                                     GT_MAIN-PRIND
                                     GT_MAIN-SUJUP
                                     LV_ERROR.

  APPEND GT_MAIN.

ENDFORM.                    " MOVE_SALES_ORDER_DATA
