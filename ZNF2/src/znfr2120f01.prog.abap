*&---------------------------------------------------------------------*
*&  Include           ZNFR2120F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_DEFAULT_PARAMETER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DEFAULT_PARAMETER .

ENDFORM.                    " SET_DEFAULT_PARAMETER
*&---------------------------------------------------------------------*
*&      Form  F4HELP_ENDMM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4HELP_ENDMM  USING    PV_ENDMM.

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      ACTUAL_MONTH   = SY-DATLO(6)
    IMPORTING
      SELECTED_MONTH = PV_ENDMM.

ENDFORM.                    " F4HELP_ENDMM
*&---------------------------------------------------------------------*
*&      Form  GET_FUTURES_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FUTURES_REQ_DATA .
  DATA: LV_ERROR.

  CLEAR   : GT_MAIN.
  REFRESH : GT_MAIN.

  SELECT A~BUKRS
         A~REQNO
         B~H_NO1
         B~NFKEY
         B~BY_SL
         B~ENDMM
         B~EMENG
         B~MEINS
         A~RQTYP
         B~CONNO
         B~ERNAM
         B~ERDAT
         A~RSTAT
         B~BIGO4
         B~YNFIN
         B~WHYDE
         C~EMENG
    INTO CORRESPONDING FIELDS OF TABLE GT_MAIN
    FROM ZNFT1010 AS A
   INNER JOIN ZNFT1011 AS B
      ON A~REQNO = B~REQNO
    JOIN ZNFT1001 AS C
      ON C~CONNO = B~CONNO
     AND C~NFKEY = B~NFKEY
   WHERE A~BUKRS =  P_BUKRS
     AND A~REQNO IN S_REQNO
     AND A~RQTYP IN GR_RQTYP
     AND A~ERDAT IN S_ERDAT
     AND A~RSTAT IN ('3', '4', '5', '6')
     AND B~CONNO IN S_CONNO
     AND B~NFKEY IN S_NFKEY
     AND B~ENDMM IN S_ENDMM
     AND B~YNFIN IN GR_YNFIN.

  LOOP AT GT_MAIN.
**___가격구분/비철수주가
*    PERFORM PRICE_CLASSIFICATION USING GT_MAIN-CONNO
*                                       GT_MAIN-NFKEY
*                                       GT_MAIN-PRIND
*                                       GT_MAIN-SUJUP
*                                       LV_ERROR.
*
*    IF ( P_CHK31 IS INITIAL AND GT_MAIN-PRIND = 'Fix Price' )      OR
*       ( P_CHK32 IS INITIAL AND GT_MAIN-PRIND = 'Average Price' )  OR
*       ( P_CHK33 IS INITIAL AND GT_MAIN-PRIND = 'Official Price' ) OR
**       ( P_CHK34 IS INITIAL AND GT_MAIN-PRIND = '시세' )           OR
*         GT_MAIN-PRIND IS INITIAL.
*      DELETE GT_MAIN.
*      CONTINUE.
*    ENDIF.

*___가격구분/비철수주가
    PERFORM PRICE_CLASSIFICATION1 USING GT_MAIN-CONNO
                                        GT_MAIN-NFKEY
                                        GT_MAIN-PRIND
                                        GT_MAIN-SUJUP
                                        GT_MAIN-EMENG1
                                        LV_ERROR.

    IF ( P_CHK31 IS INITIAL AND GT_MAIN-PRIND = 'Fix Price' )      OR
       ( P_CHK32 IS INITIAL AND GT_MAIN-PRIND = 'Average Price' )  OR
       ( P_CHK33 IS INITIAL AND GT_MAIN-PRIND = 'Official Price' ) OR
*       ( P_CHK34 IS INITIAL AND GT_MAIN-PRIND = '시세' )           OR
         GT_MAIN-PRIND IS INITIAL.
      DELETE GT_MAIN.
      CONTINUE.
    ENDIF.


*___선물집행여부
    PERFORM CHECK_CARRY_OUT USING GT_MAIN-REQNO
                                  GT_MAIN-H_NO1
                                  GT_MAIN-CARRY.

    IF ( P_CHK11 IS INITIAL AND GT_MAIN-CARRY = 'Y' ) OR
       ( P_CHK12 IS INITIAL AND GT_MAIN-CARRY = ' ' ).
      DELETE GT_MAIN.
      CONTINUE.
    ENDIF.

*___계약정보
    SELECT SINGLE COTYP   "계약유형
                  COTXT   "계약명
                  KUNNR   "고객코드
                  NCUST   "고객명
                  SALER   "영업담당자
                  NFCTR   "사업부
                  PRCTR   "손익센터
                  VKGRP   "영업그룹
      INTO (GT_MAIN-COTYP, GT_MAIN-COTXT,
            GT_MAIN-KUNNR, GT_MAIN-NCUST,
            GT_MAIN-SALER, GT_MAIN-NFCTR,
            GT_MAIN-PRCTR, GT_MAIN-VKGRP)
      FROM ZNFT1000
     WHERE CONNO = GT_MAIN-CONNO.

    IF GT_MAIN-NFCTR NOT IN S_NFCTR OR
       GT_MAIN-PRCTR NOT IN S_PRCTR OR
       GT_MAIN-VKGRP NOT IN S_VKGRP.
      DELETE GT_MAIN.
      CONTINUE.
    ENDIF.

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

*___Buy/Sell 내역
    PERFORM DOMAIN_VALUE_GET USING 'ZBY_SL'
                                   GT_MAIN-BY_SL
                                   GT_MAIN-BSTXT.

*___요청유형 내역
    PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                   GT_MAIN-RQTYP
                                   GT_MAIN-RQTXT.

*___계약유형 내역
    PERFORM DOMAIN_VALUE_GET USING 'ZCOTYP'
                                   GT_MAIN-COTYP
                                   GT_MAIN-CTPTX.

*___결재상태 내역
    PERFORM DOMAIN_VALUE_GET USING 'ZRSTAT'
                                   GT_MAIN-RSTAT
                                   GT_MAIN-RSTXT.

*___선물청산여부
    IF GT_MAIN-CARRY = 'Y'.
      PERFORM CHECK_SETTLEMENT USING GT_MAIN-REQNO
                                     GT_MAIN-H_NO1
                                     GT_MAIN-STTLE.
    ENDIF.

*___변경전 계약번호/마감여부
    GT_MAIN-CONNO_O = GT_MAIN-CONNO.
    GT_MAIN-YNFIN_O = GT_MAIN-YNFIN.
    GT_MAIN-WHYDE_O = GT_MAIN-WHYDE.

    MODIFY GT_MAIN.
  ENDLOOP.

ENDFORM.                    " GET_FUTURES_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_RANGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_RANGES .

  CLEAR   : GR_YNFIN, GR_RQTYP.
  REFRESH : GR_YNFIN, GR_RQTYP.

*___선물요청 마감여부
  IF P_CHK01 = 'X'.
    APPEND_RANGES GR_YNFIN 'I' 'EQ' 'X' ' '.
  ENDIF.

  IF P_CHK02 = 'X'.
    APPEND_RANGES GR_YNFIN 'I' 'EQ' ' ' ' '.
  ENDIF.

*___요청유형
  IF P_CHK21 = 'X'.
    APPEND_RANGES GR_RQTYP 'I' 'EQ' '1' ' '.
  ENDIF.

  IF P_CHK22 = 'X'.
    APPEND_RANGES GR_RQTYP 'I' 'EQ' '2' ' '.
  ENDIF.

  IF P_CHK23 = 'X'.
    APPEND_RANGES GR_RQTYP 'I' 'EQ' '3' ' '.
  ENDIF.

  IF P_CHK24 = 'X'.
    APPEND_RANGES GR_RQTYP 'I' 'EQ' '4' ' '.
  ENDIF.

  IF P_CHK25 = 'X'.
    APPEND_RANGES GR_RQTYP 'I' 'EQ' '5' ' '.
  ENDIF.

ENDFORM.                    " SET_RANGES
*&---------------------------------------------------------------------*
*&      Form  CHECK_CARRY_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_CARRY_OUT  USING    PV_REQNO
                               PV_H_NO1
                               PV_CARRY.
  DATA LV_YNCAN     LIKE ZNFT1020-YNCAN.

  CLEAR : PV_CARRY, LV_YNCAN.

  CHECK PV_REQNO IS NOT INITIAL AND
        PV_H_NO1 IS NOT INITIAL.

  SELECT SINGLE YNCAN
    INTO LV_YNCAN
    FROM ZNFT1020
   WHERE REQNO = PV_REQNO
     AND H_NO1 = PV_H_NO1
     AND YNCAN = ' '.

  IF SY-SUBRC = 0.
    PV_CARRY = 'Y'.
  ENDIF.

ENDFORM.                    " CHECK_CARRY_OUT
*&---------------------------------------------------------------------*
*&      Form  CHECK_SETTLEMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SETTLEMENT  USING    PV_REQNO
                                PV_H_NO1
                                PV_STTLE.
  DATA: BEGIN OF LT_1020 OCCURS 0,
          NFUTN     LIKE ZNFT1020-NFUTN,
        END   OF LT_1020.

  DATA: LV_CFUTN    LIKE ZNFT1030-CFUTN.

  CLEAR   : LT_1020, PV_STTLE.
  REFRESH : LT_1020.

  CHECK PV_REQNO IS NOT INITIAL AND
        PV_H_NO1 IS NOT INITIAL.

  SELECT NFUTN
    INTO TABLE LT_1020
    FROM ZNFT1020
   WHERE REQNO = PV_REQNO
     AND H_NO1 = PV_H_NO1
     AND YNCAN = ' '.

  LOOP AT LT_1020.
    SELECT SINGLE CFUTN
      INTO LV_CFUTN
      FROM ZNFT1030
     WHERE NFUTN = LT_1020-NFUTN
       AND YNCAN = ' '.

    IF SY-SUBRC = 0.
      PV_STTLE = 'Y'.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " CHECK_SETTLEMENT
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_LAYO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_LAYO .

*  gs_layout-grid_title = '~'.
*  gs_layout-smalltitle = 'X'.
*  gs_layout-NO_HEADERS = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
*  GS_LAYOUT-EDIT       = 'X'.
  GS_LAYOUT-ZEBRA      = 'X'.
  GS_LAYOUT-SMALLTITLE = 'X'.
  GS_LAYOUT-SEL_MODE   = ' '.              "select multiple lines
  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT-CTAB_FNAME = 'F_COL'.

ENDFORM.                    " SET_GRID_LAYO
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_GRID_FCAT .

  CLEAR   : GS_FIELDCAT, GV_POS.
  REFRESH : GT_FIELDCAT.

  GV_ITAB = 'GT_MAIN'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM MAKE_LVC_FIELDCAT_DATA TABLES GT_FIELDCAT
                                  USING :

      'CHECK'    ' '      ' '     ' ' 'X' ' ' ' '    'X' ' ' ' ' 4
      '선택'         ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' 'X',

      'BUKRS'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      ' '            'BUKRS'  'ZNFT1010'  ' ' ' '    'X' ' ' ' ' ' ',

      'REQNO'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '            'REQNO'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'H_NO1'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      ' '            'H_NO1'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'CONNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'CONNO'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' 'X',

      'YNFIN'    ' '      ' '     ' ' 'X' ' ' ' '    ' ' ' ' ' ' 4
      ' '            'YNFIN'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' 'X',

      'WHYDE'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      '변경사유'     'WHYDE'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' 'X',

      'NFCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'NFCTR'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'PRCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'PRCTR'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'VKGRP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      ' '            'VKGRP'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      ' '            'NFKEY'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'BY_SL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 6
      ' '            'BY_SL'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'BSTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      'Buy/Sell'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ENDMM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '            'ENDMM'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '            'EMENG'  'ZNFT1011'  ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '            'MEINS'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' ',

      'RQTYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'RQTYP'  'ZNFT1010'  ' ' ' '    'X' ' ' ' ' ' ',

      'RQTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '요청유형내역' ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'COTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '            'COTXT'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'KUNNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'KUNNR'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'NCUST'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '            'NCUST'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'SALER'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'SALER'  'ZNFT1000'  ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG1'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '수주량'       'EMENG'  'ZNFT1001'  ' ' ' '    ' ' ' ' ' ' ' ',

      'PRIND'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 15
      '가격구분'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'SUJUP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 12
      '비철수주가'   ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ERNAM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 12
      '요청자'       'ERNAM'  'ZNFT1010'  ' ' ' '    'X' ' ' ' ' ' ',

      'ERDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '            'ERDAT'  'ZNFT1010'  ' ' ' '    'X' ' ' ' ' ' ',

      'RSTAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '            'RSTAT'  'ZNFT1010'  ' ' ' '    'X' ' ' ' ' ' ',

      'RSTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '결재상태내역' ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'CARRY'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '선물집행여부' ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'STTLE'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      '선물청산여부' ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'BIGO4'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      ' '            'BIGO4'  'ZNFT1011'  ' ' ' '    'X' ' ' ' ' ' '.

ENDFORM.                    " SET_GRID_FCAT
*&---------------------------------------------------------------------*
*&      Form  MAKE_LVC_FIELDCAT_DATA
*&---------------------------------------------------------------------*
* 필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
* TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
*----------------------------------------------------------------------*
FORM MAKE_LVC_FIELDCAT_DATA TABLES PT_FIELDCAT TYPE LVC_T_FCAT
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

  CLEAR : GS_FIELDCAT.

  GV_POS = GV_POS + 1.

  GS_FIELDCAT-COL_POS        = GV_POS.
  GS_FIELDCAT-FIELDNAME      = PV_FNAME.
  GS_FIELDCAT-CFIELDNAME     = PV_CURK.
  GS_FIELDCAT-QFIELDNAME     = PV_UNIT.
  GS_FIELDCAT-ICON           = PV_ICON.
  GS_FIELDCAT-CHECKBOX       = PV_CHECK.
  GS_FIELDCAT-JUST           = PV_JUST.
  GS_FIELDCAT-EMPHASIZE      = PV_EMPHA.
  GS_FIELDCAT-FIX_COLUMN     = PV_FIX.
  GS_FIELDCAT-KEY            = PV_FIX.
  GS_FIELDCAT-NO_OUT         = PV_NOOUT.
  GS_FIELDCAT-NO_ZERO        = PV_NOZERO.
  GS_FIELDCAT-OUTPUTLEN      = PV_LENGTH.
  GS_FIELDCAT-COLTEXT        = PV_TEXT.
  GS_FIELDCAT-SCRTEXT_S      = PV_TEXT.
  GS_FIELDCAT-SCRTEXT_M      = PV_TEXT.
  GS_FIELDCAT-SCRTEXT_L      = PV_TEXT.
  GS_FIELDCAT-REPTEXT        = PV_TEXT.
  GS_FIELDCAT-REF_FIELD      = PV_REFF.
  GS_FIELDCAT-REF_TABLE      = PV_REFT.
  GS_FIELDCAT-TECH           = PV_TECH.
  GS_FIELDCAT-DATATYPE       = PV_TYPE.
  GS_FIELDCAT-NO_SUM         = PV_NOSUM.
  GS_FIELDCAT-DO_SUM         = PV_DOSUM.
  GS_FIELDCAT-HOTSPOT        = PV_HOTSPOT.
  GS_FIELDCAT-EDIT           = PV_EDIT.

  IF PV_FNAME = 'CONNO'.
    GS_FIELDCAT-F4AVAILABL   = 'X'.
  ENDIF.

  GS_FIELDCAT-TABNAME        = GV_ITAB.

  APPEND GS_FIELDCAT TO PT_FIELDCAT.

ENDFORM.                    " MAKE_LVC_FIELDCAT_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE .
  DATA: LT_CELLTAB TYPE LVC_T_STYL,
        LT_COLOR   TYPE LVC_T_SCOL.

*___각 Cell의 특성 제어
  LOOP AT GT_MAIN.
    CLEAR   : LT_CELLTAB, LT_COLOR.
    REFRESH : LT_CELLTAB, LT_COLOR.

    PERFORM FILL_CELLTAB_C CHANGING LT_CELLTAB.
    PERFORM FILL_COLOR     CHANGING LT_COLOR.

    REFRESH : GT_MAIN-CELLTAB, GT_MAIN-F_COL.

    INSERT LINES OF LT_CELLTAB INTO TABLE GT_MAIN-CELLTAB.
    INSERT LINES OF LT_COLOR   INTO TABLE GT_MAIN-F_COL.

    MODIFY GT_MAIN.
  ENDLOOP.

ENDFORM.                    " SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*&      Form  FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_CELLTAB_C  CHANGING PT_CELLTAB TYPE LVC_T_STYL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         L_MODE     TYPE RAW4.

  DATA : L_FIELDCAT TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT INTO L_FIELDCAT.
    LS_CELLTAB-FIELDNAME = L_FIELDCAT-FIELDNAME.

*___필드 활성화 여부
    IF L_FIELDCAT-EDIT = 'X'.
      IF GT_MAIN-CHECK IS INITIAL.
        IF LS_CELLTAB-FIELDNAME = 'CHECK'.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*                           + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                           + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        ENDIF.
      ELSE.
        IF LS_CELLTAB-FIELDNAME = 'YNFIN' AND GT_MAIN-RSTAT <> '6'.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                           + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
*                           + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        ENDIF.
      ENDIF.
    ELSE.
      LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
*                       + CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
    ENDIF.

    INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
  ENDLOOP.

ENDFORM.                    " FILL_CELLTAB_C
*&---------------------------------------------------------------------*
*&      Form  FILL_COLOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_COLOR  text
*----------------------------------------------------------------------*
FORM FILL_COLOR  CHANGING PT_COLOR TYPE LVC_T_SCOL.
  DATA: LS_CELLTAB TYPE LVC_S_STYL,
        LS_COLOR   TYPE LVC_S_SCOL,
        L_MODE     TYPE RAW4.

  DATA: L_FIELDCAT TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT INTO L_FIELDCAT.
    LS_COLOR-FNAME = L_FIELDCAT-FIELDNAME.

    IF  L_FIELDCAT-KEY = 'X'.
      IF LS_COLOR-FNAME <> 'CHECK'.
        LS_COLOR-COLOR-COL = 4.
        LS_COLOR-COLOR-INT = 1.

        INSERT LS_COLOR INTO TABLE PT_COLOR.
      ENDIF.
    ELSE.
      IF GT_MAIN-CHECK = 'X'.
        IF L_FIELDCAT-EDIT IS INITIAL.
          LS_COLOR-COLOR-COL = 7.
          LS_COLOR-COLOR-INT = 1.

          INSERT LS_COLOR INTO TABLE PT_COLOR.
        ENDIF.
      ELSE.
        LS_COLOR-COLOR-COL = 2.
        LS_COLOR-COLOR-INT = 0.

        INSERT LS_COLOR INTO TABLE PT_COLOR.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " FILL_COLOR
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
*&      Form  EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER .

  CALL METHOD GC_ALV_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

*___Event Handler 등록
  CREATE OBJECT GC_EVENT_HANDLER.

  SET HANDLER GC_EVENT_HANDLER->HANDLE_TOOLBAR       FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_DOUBLE_CLICK  FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_DATA_CHANGED  FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_DATA_CHANGED_FINISHED
          FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_USER_COMMAND  FOR GC_ALV_GRID.
  SET HANDLER GC_EVENT_HANDLER->HANDLE_ONF4          FOR GC_ALV_GRID.

ENDFORM.                    " EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*&      Form  SET_F4HELP_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_F4HELP_FIELD .

  CLEAR   : GS_F4.
  REFRESH : GT_F4.

*___F4 FIELD 등록 - 필드명을 ABC순으로 기술하여야 함
  GS_F4-FIELDNAME = 'CONNO'.  "계약번호
  GS_F4-REGISTER  = 'X'.
  APPEND GS_F4 TO GT_F4.

  CALL METHOD GC_ALV_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = GT_F4.

ENDFORM.                    " SET_F4HELP_FIELD
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

  CALL METHOD GC_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = GS_VARIANT
      IS_LAYOUT            = GS_LAYOUT
      I_SAVE               = 'A'
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
    CHANGING
      IT_FIELDCATALOG      = GT_FIELDCAT[]
      IT_SORT              = GT_SORT[]
      IT_OUTTAB            = GT_MAIN[].

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SELECTED_ROWS .

  CALL METHOD GC_ALV_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROWS.

  CALL METHOD GC_ALV_GRID->GET_SELECTED_COLUMNS
    IMPORTING
      ET_INDEX_COLUMNS = GT_COLS.

ENDFORM.                    " GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  SET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SELECTED_ROWS .

  IF GT_ROWS[] IS NOT INITIAL.
    CALL METHOD GC_ALV_GRID->SET_SELECTED_ROWS
      EXPORTING
        IT_INDEX_ROWS = GT_ROWS.
  ENDIF.

  IF GT_COLS[] IS NOT INITIAL.
    CALL METHOD GC_ALV_GRID->SET_SELECTED_COLUMNS
      EXPORTING
        IT_COL_TABLE = GT_COLS.
  ENDIF.

ENDFORM.                    " SET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED  USING    E_MODIFIED
                                     ET_GOOD_CELLS TYPE LVC_T_MODI.
  DATA: LS_GOOD_CELLS TYPE LVC_S_MODI.

  LOOP AT ET_GOOD_CELLS INTO LS_GOOD_CELLS.
    CASE LS_GOOD_CELLS-FIELDNAME.
      WHEN 'CHECK'.
        READ TABLE GT_MAIN INDEX LS_GOOD_CELLS-ROW_ID.
        IF SY-SUBRC = 0.
          PERFORM ENQUEUE_DEQUEUE_ZNFT1010.

          MODIFY GT_MAIN INDEX LS_GOOD_CELLS-ROW_ID
                         TRANSPORTING CHECK.
        ENDIF.

      WHEN 'CONNO'.
        READ TABLE GT_MAIN INDEX LS_GOOD_CELLS-ROW_ID.
        IF SY-SUBRC = 0.
          PERFORM GET_CONTRACT_DETAIL.

          MODIFY GT_MAIN INDEX LS_GOOD_CELLS-ROW_ID.
        ENDIF.

    ENDCASE.
  ENDLOOP.

ENDFORM.                    " DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_DEQUEUE_ZNFT1010
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ENQUEUE_DEQUEUE_ZNFT1010 .
  DATA: LV_MSGV1    LIKE SY-MSGV1.

  IF GT_MAIN-CHECK IS INITIAL.
    CALL FUNCTION 'DEQUEUE_EZ_ZNFT1010'
      EXPORTING
        REQNO = GT_MAIN-REQNO.
  ELSE.
    CALL FUNCTION 'ENQUEUE_EZ_ZNFT1010'
      EXPORTING
        REQNO          = GT_MAIN-REQNO
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.

    IF SY-SUBRC <> 0.
      CLEAR : GT_MAIN-CHECK.
      LV_MSGV1 = SY-MSGV1.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '선물요청 번호' GT_MAIN-REQNO
              '이(가) 현재 처리중입니다. 사용자:' LV_MSGV1.
    ENDIF.
  ENDIF.

ENDFORM.                    " ENQUEUE_DEQUEUE_ZNFT1010
*&---------------------------------------------------------------------*
*&      Form  ON_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ON_F4  USING SENDER         TYPE REF TO CL_GUI_ALV_GRID
                  E_FIELDNAME    TYPE LVC_FNAME
                  E_FIELDVALUE   TYPE LVC_VALUE
                  ES_ROW_NO      TYPE LVC_S_ROID
                  ER_EVENT_DATA  TYPE REF TO CL_ALV_EVENT_DATA
                  ET_BAD_CELLS   TYPE LVC_T_MODI
                  E_DISPLAY      TYPE CHAR01.

  IF GC_ALV_GRID->IS_READY_FOR_INPUT( ) = 0.  "조회모드
    EXIT.
  ENDIF.

  READ TABLE GT_MAIN INDEX ES_ROW_NO-ROW_ID.
  IF GT_MAIN-CHECK IS INITIAL.
    EXIT.
  ENDIF.

  CASE E_FIELDNAME.
    WHEN 'CONNO'.  "계약번호
      READ TABLE GT_MAIN INDEX ES_ROW_NO-ROW_ID.
      IF SY-SUBRC = 0.
        PERFORM F4HELP_CONNO.

        IF GV_CHANGE = 'X'.
          PERFORM GET_CONTRACT_DETAIL.

          MODIFY GT_MAIN INDEX ES_ROW_NO-ROW_ID.
        ENDIF.
      ENDIF.

  ENDCASE.

** To avoid standard f4-help.
  ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.

ENDFORM.                                                    " ON_F4
*&---------------------------------------------------------------------*
*&      Form  F4HELP_CONNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F4HELP_CONNO .

  CLEAR : GV_CHANGE.

  PERFORM GET_CONTRACT_INFO.

  CHECK GT_CONNO[] IS NOT INITIAL.

  CLEAR   : SELECTFIELD, SELECT_VALUE, LD_TABIX,
            IT_FIELDS, SCR_FIELDS, FELD_TABLE.
  REFRESH : IT_FIELDS, SCR_FIELDS, FELD_TABLE.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'COTYP'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'NFCTR'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'PRCTR'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'VKGRP'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'CONNO'.
  IT_FIELDS-SELECTFLAG = 'X'.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'ERDAT'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'COTXT'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'KUNNR'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'NCUST'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'SUJUD'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1000'.
  IT_FIELDS-FIELDNAME  = 'SALER'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFT1001'.
  IT_FIELDS-FIELDNAME  = 'NFKEY'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFS1001'.
  IT_FIELDS-FIELDNAME  = 'PRIND'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFS1001'.
  IT_FIELDS-FIELDNAME  = 'SUJUP'.
  IT_FIELDS-SELECTFLAG = ' '.
  APPEND IT_FIELDS.

  IT_FIELDS-TABNAME    = 'ZNFS1001'.
  IT_FIELDS-FIELDNAME  = 'SUJUQ'.
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
      FULL_TABLE                   = GT_CONNO
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LD_TABIX IS INITIAL.
  READ TABLE GT_CONNO INDEX LD_TABIX.
  IF SY-SUBRC = 0.
    GT_MAIN-CONNO = GT_CONNO-CONNO.

    GV_CHANGE = 'X'.
  ENDIF.

ENDFORM.                    " F4HELP_CONNO
*&---------------------------------------------------------------------*
*&      Form  GET_CONTRACT_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CONTRACT_INFO .
  DATA: WHERE_CLAUSE(200).

  RANGES: LR_COTYP  FOR ZNFT1000-COTYP.

  CLEAR   : GT_CONNO, LR_COTYP, WHERE_CLAUSE.
  REFRESH : GT_CONNO, LR_COTYP.

  LR_COTYP-SIGN   = 'I'.
  LR_COTYP-OPTION = 'EQ'.

  CASE GT_MAIN-RQTYP.
    WHEN '1' OR '2'.      "Firm Price/고객요청
      LR_COTYP-LOW = '1'.  APPEND LR_COTYP.
      LR_COTYP-LOW = '2'.  APPEND LR_COTYP.

    WHEN '3'.      "경상선물
      LR_COTYP-LOW = '1'.  APPEND LR_COTYP.
      LR_COTYP-LOW = '2'.  APPEND LR_COTYP.
      LR_COTYP-LOW = '3'.  APPEND LR_COTYP.

    WHEN '4'.      "내부선물
      LR_COTYP-LOW = '4'.  APPEND LR_COTYP.

    WHEN '5'.      "재고헷지
      LR_COTYP-LOW = '5'.  APPEND LR_COTYP.

  ENDCASE.

  IF GT_MAIN-NFCTR IS NOT INITIAL.
    CONCATENATE WHERE_CLAUSE 'AND A~NFCTR = ''' GT_MAIN-NFCTR ''''
           INTO WHERE_CLAUSE.
  ENDIF.

  IF GT_MAIN-PRCTR IS NOT INITIAL.
    CONCATENATE WHERE_CLAUSE 'AND A~PRCTR = ''' GT_MAIN-PRCTR ''''
           INTO WHERE_CLAUSE.
  ENDIF.

  IF GT_MAIN-VKGRP IS NOT INITIAL.
    CONCATENATE WHERE_CLAUSE 'AND A~VKGRP = ''' GT_MAIN-VKGRP ''''
           INTO WHERE_CLAUSE.
  ENDIF.

  IF WHERE_CLAUSE IS NOT INITIAL.
    REPLACE 'AND' IN WHERE_CLAUSE WITH ' '.
  ENDIF.

  SELECT A~COTYP  "계약유형
         A~NFCTR  "사업부
         A~PRCTR  "손익센터
         A~VKGRP  "영업그룹
         A~CONNO  "계약번호
         A~ERDAT  "생성일
         A~COTXT  "계약명(PJT명)
         A~KUNNR  "고객코드
         A~NCUST  "고객명
         A~SUJUD  "수주일
         A~SALER  "영업담당자
         B~NFKEY  "비철구분
         B~EMENG  "수주량
         B~MEINS  "단위
    INTO CORRESPONDING FIELDS OF TABLE GT_CONNO
    FROM ZNFT1000 AS A
   INNER JOIN ZNFT1001 AS B
      ON A~CONNO = B~CONNO
   WHERE A~CSTAT = 'L'
     AND A~COTYP IN LR_COTYP
     AND B~NFKEY = GT_MAIN-NFKEY
     AND (WHERE_CLAUSE).

  IF SY-SUBRC <> 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '조건에 해당하는 계약이 존재하지 않습니다.'.
  ENDIF.

  LOOP AT GT_CONNO.
*___가격구분/비철수주가격
    PERFORM PRICE_CLASSIFICATION USING GT_CONNO-CONNO
                                       GT_CONNO-NFKEY
                                       GT_CONNO-PRIND
                                       GT_CONNO-SUJUP
                                       GV_ERROR.

*___수주량
    WRITE : GT_CONNO-EMENG TO GT_CONNO-SUJUQ UNIT GT_CONNO-MEINS.

    MODIFY GT_CONNO.
  ENDLOOP.

ENDFORM.                    " GET_CONTRACT_INFO
*&---------------------------------------------------------------------*
*&      Form  GET_CONTRACT_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CONTRACT_DETAIL .
  DATA: LV_CSTAT    LIKE ZNFT1000-CSTAT,
        LV_COTYP    LIKE ZNFT1000-COTYP,
        LV_ERROR.

  CLEAR : GT_MAIN-COTXT, GT_MAIN-NFCTR, GT_MAIN-PRCTR,
          GT_MAIN-VKGRP, GT_MAIN-KUNNR, GT_MAIN-NCUST,
          GT_MAIN-SALER, GT_MAIN-PRIND, GT_MAIN-SUJUP,
          LV_CSTAT,      LV_COTYP,      LV_ERROR.

  CHECK GT_MAIN-CONNO IS NOT INITIAL.

  SELECT SINGLE COTXT
                NFCTR
                PRCTR
                VKGRP
                KUNNR
                NCUST
                SALER
                CSTAT
                COTYP
    INTO (GT_MAIN-COTXT, GT_MAIN-NFCTR,
          GT_MAIN-PRCTR, GT_MAIN-VKGRP,
          GT_MAIN-KUNNR, GT_MAIN-NCUST,
          GT_MAIN-SALER, LV_CSTAT,
          LV_COTYP)
    FROM ZNFT1000
   WHERE CONNO = GT_MAIN-CONNO.

  IF SY-SUBRC <> 0.
    LV_ERROR = 'X'.
  ELSEIF LV_CSTAT <> 'L'.
    LV_ERROR = '1'.
  ELSE.
    CASE GT_MAIN-RQTYP.
      WHEN '1' OR '2'.
        IF LV_COTYP <> '1' AND LV_COTYP <> '2'.
          LV_ERROR = '2'.
        ENDIF.

      WHEN '3'.
        IF LV_COTYP <> '1' AND LV_COTYP <> '2' AND
           LV_COTYP <> '3'.
          LV_ERROR = '2'.
        ENDIF.

      WHEN '4'.
        IF LV_COTYP <> '4'.
          LV_ERROR = '2'.
        ENDIF.

      WHEN '5'.
        IF LV_COTYP <> '4'.
          LV_ERROR = '5'.
        ENDIF.

    ENDCASE.
  ENDIF.

  IF LV_ERROR IS NOT INITIAL.
    IF LV_ERROR = 'X'.
      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '계약번호' GT_MAIN-CONNO
              '은(는) 존재하지 않습니다.'.
    ELSEIF LV_ERROR = '1'.
      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '계약번호' GT_MAIN-CONNO
              '은(는) 취소되거나 마감된'
              '계약번호입니다.'.
    ELSE.
      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '선물요청유형과 계약유형을'
              '확인하시기 바랍니다.'.
    ENDIF.

    CLEAR : GT_MAIN-CONNO, GT_MAIN-COTXT, GT_MAIN-NFCTR,
            GT_MAIN-PRCTR, GT_MAIN-VKGRP, GT_MAIN-KUNNR,
            GT_MAIN-NCUST, GT_MAIN-SALER, GT_MAIN-PRIND,
            GT_MAIN-SUJUP.

    EXIT.
  ENDIF.

  IF GT_MAIN-NFKEY IS NOT INITIAL.
*___가격구분/비철수주가
    PERFORM PRICE_CLASSIFICATION USING GT_MAIN-CONNO
                                       GT_MAIN-NFKEY
                                       GT_MAIN-PRIND
                                       GT_MAIN-SUJUP
                                       GV_ERROR.

    IF GV_ERROR IS NOT INITIAL.
      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '계약의 비철구분을 확인하시기 바랍니다.'.

      CLEAR : GT_MAIN-CONNO, GT_MAIN-COTXT, GT_MAIN-NFCTR,
              GT_MAIN-PRCTR, GT_MAIN-VKGRP, GT_MAIN-KUNNR,
              GT_MAIN-NCUST, GT_MAIN-SALER, GT_MAIN-PRIND,
              GT_MAIN-SUJUP.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_CONTRACT_DETAIL
*&---------------------------------------------------------------------*
*&      Form  SAVE_FUTURES_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_FUTURES_REQ_DATA .
  DATA: LV_CNT      TYPE I,
        LV_MSGV1(50).

  CALL METHOD GC_ALV_GRID->CHECK_CHANGED_DATA.

  READ TABLE GT_MAIN WITH KEY CHECK = 'X'.
  IF SY-SUBRC <> 0.
    MESSAGE I003 DISPLAY LIKE 'E'
       WITH '선택된 라인이 없습니다.'.
    EXIT.
  ENDIF.

  CLEAR : GV_ERROR.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    CONCATENATE '선물요청-항번:' GT_MAIN-REQNO '-' GT_MAIN-H_NO1
           INTO LV_MSGV1 SEPARATED BY SPACE.

    IF GT_MAIN-CONNO IS INITIAL.
      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '계약번호가 입력되지 않았습니다.' LV_MSGV1.

      GV_ERROR = 'X'.
      EXIT.
    ENDIF.

    IF GT_MAIN-WHYDE IS INITIAL.
      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '변경사유가 입력되지 않았습니다.' LV_MSGV1.

      GV_ERROR = 'X'.
      EXIT.
    ELSE.
*      IF GT_MAIN-CONNO =  GT_MAIN-CONNO_O AND
*         GT_MAIN-YNFIN =  GT_MAIN-YNFIN_O AND
*         GT_MAIN-WHYDE <> GT_MAIN-WHYDE_O.
*        MESSAGE I003 DISPLAY LIKE 'E'
*           WITH '계약번호나 마감여부가 변경된 경우'
*                '변경사유를 입력할 수 있습니다.'
*                LV_MSGV1.
*
*        GV_ERROR = 'X'.
*        EXIT.
*      ENDIF.
    ENDIF.

  ENDLOOP.

  CHECK GV_ERROR IS INITIAL.

  PERFORM POPUP_TO_CONFIRM USING '저장'
                                 '선택한 라인을 저장하시겠습니까?'
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
    CLEAR : LV_CNT.

*___변경이력 저장
    PERFORM SAVE_CHANGE_DOC.

    LOOP AT GT_MAIN WHERE CHECK = 'X'.
      UPDATE ZNFT1011 SET CONNO = GT_MAIN-CONNO
                          YNFIN = GT_MAIN-YNFIN
                          WHYDE = GT_MAIN-WHYDE
                          AEDAT = SY-DATLO
                          AEZET = SY-TIMLO
                          AENAM = SY-UNAME
                    WHERE REQNO = GT_MAIN-REQNO
                      AND H_NO1 = GT_MAIN-H_NO1.
      IF SY-SUBRC = 0.
        LV_CNT = LV_CNT + 1.
      ELSE.
        GV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF GV_ERROR IS INITIAL.
      COMMIT WORK.

      MESSAGE I003 DISPLAY LIKE 'S'
         WITH '선물요청번호' LV_CNT
              '건이 변경되었습니다.'.

      LOOP AT GT_MAIN WHERE CHECK = 'X'.
        CLEAR : GT_MAIN-CHECK.

        PERFORM ENQUEUE_DEQUEUE_ZNFT1010.
      ENDLOOP.

      PERFORM GET_FUTURES_REQ_DATA.
    ELSE.
      ROLLBACK WORK.

      MESSAGE I003 DISPLAY LIKE 'E'
         WITH '선물요청번호' GT_MAIN-REQNO
              '저장 시 에러가 발생하였습니다.'.
    ENDIF.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " SAVE_FUTURES_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_CHANGE_DOC .
  DATA: LV_REQNO    LIKE ZNFT1010-REQNO.

  SORT GT_MAIN BY REQNO H_NO1.

  CLEAR : LV_REQNO.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    IF LV_REQNO <> GT_MAIN-REQNO.
      IF LV_REQNO IS NOT INITIAL.
        PERFORM EXEC_CHDOC_FUNCTION.
      ENDIF.

      CLEAR   : XGT_1011, YGT_1011, ZNFT1010, YZNFT1010.
      REFRESH : XGT_1011, YGT_1011.

*___기존 데이터
      SELECT SINGLE *
        FROM ZNFT1010
       WHERE REQNO = GT_MAIN-REQNO.

      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE YGT_1011
        FROM ZNFT1011
       WHERE REQNO = GT_MAIN-REQNO.

      YZNFT1010 = ZNFT1010.

      LOOP AT YGT_1011.
        CLEAR : XGT_1011.

        MOVE-CORRESPONDING YGT_1011 TO XGT_1011.

        APPEND XGT_1011.
      ENDLOOP.

      LV_REQNO = GT_MAIN-REQNO.
    ENDIF.

    READ TABLE XGT_1011 WITH KEY REQNO = GT_MAIN-REQNO
                                 H_NO1 = GT_MAIN-H_NO1.
    IF SY-SUBRC = 0.
      XGT_1011-CONNO = GT_MAIN-CONNO.
      XGT_1011-YNFIN = GT_MAIN-YNFIN.
      XGT_1011-WHYDE = GT_MAIN-WHYDE.
      XGT_1011-AEDAT = SY-DATLO.
      XGT_1011-AEZET = SY-TIMLO.
      XGT_1011-AENAM = SY-UNAME.
      XGT_1011-KZ    = 'U'.

      MODIFY XGT_1011 INDEX SY-TABIX.
    ENDIF.
  ENDLOOP.

  IF SY-SUBRC = 0.
    PERFORM EXEC_CHDOC_FUNCTION.
  ENDIF.

ENDFORM.                    " SAVE_CHANGE_DOC
*&---------------------------------------------------------------------*
*&      Form  EXEC_CHDOC_FUNCTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXEC_CHDOC_FUNCTION .
  DATA: LV_OBJECTID             TYPE CDHDR-OBJECTID,
        LV_TCODE                TYPE CDHDR-TCODE.

  CHECK XGT_1011[] IS NOT INITIAL.

  LV_OBJECTID = ZNFT1010-REQNO.
  LV_TCODE    = SY-TCODE.

  CALL FUNCTION 'ZNFT1010CHDOC_WRITE_DOCUMENT'
    EXPORTING
      OBJECTID                      = LV_OBJECTID
      TCODE                         = LV_TCODE
      UTIME                         = SY-TIMLO
      UDATE                         = SY-DATLO
      USERNAME                      = SY-UNAME
*     PLANNED_CHANGE_NUMBER         = ' '
*     OBJECT_CHANGE_INDICATOR       = 'U'
*     PLANNED_OR_REAL_CHANGES       = ' '
*     NO_CHANGE_POINTERS            = ' '
      N_ZNFT1010                    = ZNFT1010
      O_ZNFT1010                    = YZNFT1010
      UPD_ZNFT1010                  = 'U'
      UPD_ZNFT1011                  = 'U'
    TABLES
      XZNFT1011                     = XGT_1011
      YZNFT1011                     = YGT_1011.

ENDFORM.                    " EXEC_CHDOC_FUNCTION
*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_ALL .

  LOOP AT GT_MAIN.
    IF OK_SAVE = 'ASEL'.
      GT_MAIN-CHECK = 'X'.
    ELSE.
      CLEAR : GT_MAIN-CHECK.
    ENDIF.

    PERFORM ENQUEUE_DEQUEUE_ZNFT1010.

    MODIFY GT_MAIN.
  ENDLOOP.

ENDFORM.                    " SELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING  E_ROW    TYPE LVC_S_ROW
                          E_COLUMN TYPE LVC_S_COL.

  CASE E_COLUMN-FIELDNAME.
    WHEN 'CONNO'.
      READ TABLE GT_MAIN INDEX E_ROW-INDEX.
      IF SY-SUBRC = 0 AND GT_MAIN-CONNO IS NOT INITIAL.
        SET PARAMETER ID 'ZNFCON' FIELD GT_MAIN-CONNO.

        CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'REQNO'.
      READ TABLE GT_MAIN INDEX E_ROW-INDEX.
      IF SY-SUBRC = 0 AND GT_MAIN-REQNO IS NOT INITIAL.
        SET PARAMETER ID 'ZNFREQ' FIELD GT_MAIN-REQNO.

        CALL TRANSACTION 'ZNF2M2103' AND SKIP FIRST SCREEN.
      ENDIF.

  ENDCASE.

ENDFORM.                    " DOUBLE_CLICK
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
       WITH '선물요청 마감여부를 선택하시기 바랍니다.'.

    EXIT.
  ENDIF.

  IF P_CHK11 IS INITIAL AND P_CHK12 IS INITIAL.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선물집행 여부를 선택하시기 바랍니다.'.

    EXIT.
  ENDIF.

  IF P_CHK21 IS INITIAL AND P_CHK22 IS INITIAL AND
     P_CHK23 IS INITIAL AND P_CHK24 IS INITIAL AND
     P_CHK25 IS INITIAL.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '요청유형을 선택하시기 바랍니다.'.

    EXIT.
  ENDIF.

  IF P_CHK31 IS INITIAL AND P_CHK32 IS INITIAL AND
     P_CHK33 IS INITIAL." AND P_CHK34 IS INITIAL.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '가격구분을 선택하시기 바랍니다.'.

    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_CHECKBOX
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
      DYNAME     = 'ZNFR2120'
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
      DYNAME     = 'ZNFR2120'
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
      DYNAME     = 'ZNFR2120'
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
       WITH '사업부가 없습니다.'.
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
