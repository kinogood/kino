*----------------------------------------------------------------------*
***INCLUDE ZNFR2110F01 .
*----------------------------------------------------------------------*
************************************************************************
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
************************************************************************
* 2012/08/23   MMB04(HDY)     변경근거 : C20120821_68215               *
*----------------------------------------------------------------------*
* Comment : 수주금액의 통화값 변경, 수주통화필드 추가
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  SET_DEFAULT_PARAMETER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DEFAULT_PARAMETER .

  CLEAR : GV_TRTYP, GV_TITLE.

*___T-Code별 Transaction 유형
  IF SY-TCODE = GC_TCODE2.
    GV_TITLE = '변경(요청부서용)'.
    GV_TRTYP = 'V'.      "변경

    CLEAR : P_CHK11, P_CHK22, P_CHK23,
            P_CHK24, P_CHK25, P_CHK26.
  ELSE.
    GV_TITLE = 'List 조회'.
    GV_TRTYP = 'A'.      "조회
  ENDIF.

  SET TITLEBAR '100' WITH GV_TITLE.

ENDFORM.                    " SET_DEFAULT_PARAMETER
*&---------------------------------------------------------------------*
*&      Form  GET_FUTURES_REQ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FUTURES_REQ_DATA .
  DATA: LT_1020     LIKE ZNFT1020 OCCURS 0 WITH HEADER LINE.

  DATA: LV_ERROR.

  CLEAR   : GT_MAIN, GT_1011.
  REFRESH : GT_MAIN, GT_1011.

  SELECT A~BUKRS    "회사코드
         A~REQNO    "요청번호
         B~H_NO1    "항번
         B~YNFIN    "마감여부
         B~NFKEY    "NF Key
         B~BY_SL    "BUY_SELL
         B~ENDMM    "만기월
         B~EMENG    "요청수량
         B~MEINS    "단위
         A~RQTYP    "요청유형
         B~CONNO    "계약번호
         A~ERNAM    "요청자
         A~ERDAT    "생성일
         A~RSTAT    "결재상태
         B~WHYDE    "변경사유(마감사유)
         B~BIGO4    "비고
    INTO TABLE GT_1011
    FROM ZNFT1010 AS A
   INNER JOIN ZNFT1011 AS B
      ON A~REQNO =  B~REQNO
   WHERE A~BUKRS =  P_BUKRS
     AND A~REQNO IN S_REQNO
     AND A~RQTYP IN GR_RQTYP
     AND A~RSTAT IN GR_RSTAT
     AND A~ERDAT IN S_ERDAT
     AND B~NFKEY IN S_NFKEY
     AND B~ENDMM IN S_ENDMM
     AND B~CONNO IN S_CONNO
     AND B~YNFIN IN GR_YNFIN.

  LOOP AT GT_1011.
    CLEAR : GT_MAIN.

    MOVE-CORRESPONDING GT_1011 TO GT_MAIN.

*___계약정보
    SELECT SINGLE COTYP   "계약유형
                  COTXT   "계약명
                  KUNNR   "고객코드
                  NCUST   "고객명
                  SALER   "영업담당자
                  NFCTR   "사업부
                  PRCTR   "손익센터
                  VKGRP   "영업그룹
                  SUJUD   "수주일
                  PRICE   "수주금액
                  PRATE   "영업이익률
                  ZPJNO   "Project NO
**** HDY 20120823 START [20120821_68215]
**** 수주금액 통화키를 맞추기 위한 SELECT
                  WAERS   "통화
**** HDY 20120823 END
      INTO (GT_MAIN-COTYP, GT_MAIN-COTXT,
            GT_MAIN-KUNNR, GT_MAIN-NCUST,
            GT_MAIN-SALER, GT_MAIN-NFCTR,
            GT_MAIN-PRCTR, GT_MAIN-VKGRP,
            GT_MAIN-SUJUD, GT_MAIN-PRICE1,
            GT_MAIN-PRATE,
**** HDY 20120823 START [20120821_68215]
**** 수주금액 통화키를 맞추기 위한 SELECT
            GT_MAIN-ZPJNO, GT_MAIN-WAERS1 )
**** HDY 20120823 END
      FROM ZNFT1000
     WHERE CONNO = GT_MAIN-CONNO.

    IF GT_MAIN-NFCTR NOT IN S_NFCTR OR
       GT_MAIN-PRCTR NOT IN S_PRCTR OR
       GT_MAIN-VKGRP NOT IN S_VKGRP OR
       GT_MAIN-ZPJNO NOT IN S_ZPJNO.
      DELETE GT_1011.
      CONTINUE.
    ENDIF.

*___승인자사번
    SELECT SINGLE PERNR
      INTO GT_MAIN-PERNR
      FROM ZNFT1091
     WHERE NFNUM = GT_MAIN-REQNO
       AND CONSQ = '1'.

*___승인자명
    PERFORM GET_PERNR_DESC USING GT_MAIN-PERNR
                                 GT_MAIN-ENAME.

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

*___가격구분/비철수주가
    PERFORM PRICE_CLASSIFICATION1 USING GT_MAIN-CONNO
                                        GT_MAIN-NFKEY
                                        GT_MAIN-PRIND
                                        GT_MAIN-SUJUP
                                        GT_MAIN-EMENG1
                                        LV_ERROR.

*___결재상태 내역
    PERFORM DOMAIN_VALUE_GET USING 'ZRSTAT'
                                   GT_MAIN-RSTAT
                                   GT_MAIN-RSTXT.

*___선물신규집행 정보
    CLEAR   : LT_1020.
    REFRESH : LT_1020.

    SELECT *
      INTO TABLE LT_1020
      FROM ZNFT1020
     WHERE REQNO = GT_MAIN-REQNO
       AND H_NO1 = GT_MAIN-H_NO1
       AND YNCAN = ' '.

    LOOP AT LT_1020.
      GT_MAIN-NFUTN  = LT_1020-NFUTN.    "신규집행번호
      GT_MAIN-RUDAT  = LT_1020-RUDAT.    "집행일
      GT_MAIN-FCM    = LT_1020-FCM.      "FCM(거래선)
      GT_MAIN-ENDAT  = LT_1020-ENDAT.    "만기일
      GT_MAIN-MITYP  = LT_1020-MITYP.    "집행유형
      GT_MAIN-WAERS  = LT_1020-WAERS.    "통화
      GT_MAIN-MISPD  = LT_1020-MISPD.    "Spread
      GT_MAIN-MIMON  = LT_1020-MIMON.    "기준월
      GT_MAIN-PRICE  = LT_1020-PRICE.    "집행단가
      GT_MAIN-EMENG2 = LT_1020-EMENG.    "집행수량

*___집행유형 내역
      PERFORM DOMAIN_VALUE_GET USING 'ZMITYP_1'
                                     GT_MAIN-MITYP
                                     GT_MAIN-MITPT.

*___청산상태
      PERFORM CHECK_SETTLE_STATUS.

      APPEND GT_MAIN.
    ENDLOOP.

    IF SY-SUBRC <> 0.
      APPEND GT_MAIN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_FUTURES_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_RANGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_RANGES .

  CLEAR   : GR_RSTAT, GR_RQTYP, GR_YNFIN.
  REFRESH : GR_RSTAT, GR_RQTYP, GR_YNFIN.

*___요청유형
  IF P_CHK01 = 'X'.
    APPEND_RANGES GR_RQTYP 'I' 'EQ' '1' ' '.
  ENDIF.

  IF P_CHK02 = 'X'.
    APPEND_RANGES GR_RQTYP 'I' 'EQ' '2' ' '.
  ENDIF.

  IF P_CHK03 = 'X'.
    APPEND_RANGES GR_RQTYP 'I' 'EQ' '3' ' '.
  ENDIF.

  IF P_CHK04 = 'X'.
    APPEND_RANGES GR_RQTYP 'I' 'EQ' '4' ' '.
  ENDIF.

  IF P_CHK05 = 'X'.
    APPEND_RANGES GR_RQTYP 'I' 'EQ' '5' ' '.
  ENDIF.

*___마감여부
  IF P_CHK11 = 'X'.
    APPEND_RANGES GR_YNFIN 'I' 'EQ' 'X' ' '.
  ENDIF.

  IF P_CHK12 = 'X'.
    APPEND_RANGES GR_YNFIN 'I' 'EQ' ' ' ' '.
  ENDIF.

*___결재상태
  IF P_CHK21 = 'X'.
    APPEND_RANGES GR_RSTAT 'I' 'EQ' '1' ' '.
  ENDIF.

  IF P_CHK22 = 'X'.
    APPEND_RANGES GR_RSTAT 'I' 'EQ' '2' ' '.
  ENDIF.

  IF P_CHK23 = 'X'.
    APPEND_RANGES GR_RSTAT 'I' 'EQ' '3' ' '.
  ENDIF.

  IF P_CHK24 = 'X'.
    APPEND_RANGES GR_RSTAT 'I' 'EQ' '4' ' '.
  ENDIF.

  IF P_CHK25 = 'X'.
    APPEND_RANGES GR_RSTAT 'I' 'EQ' '5' ' '.
  ENDIF.

  IF P_CHK26 = 'X'.
    APPEND_RANGES GR_RSTAT 'I' 'EQ' '6' ' '.
  ENDIF.

  IF P_CHK27 = 'X'.
    APPEND_RANGES GR_RSTAT 'I' 'EQ' '7' ' '.
  ENDIF.

ENDFORM.                    " SET_RANGES
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
      'BUKRS'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 4
      ' '              'BUKRS' 'ZNFT1010' ' ' ' '    'X' ' ' ' ' ' ',

      'REQNO'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      ' '              'REQNO' 'ZNFT1010' ' ' ' '    'X' ' ' ' ' ' ',

      'H_NO1'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 3
      ' '              'H_NO1' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' ',

      'YNFIN'    ' '      ' '     ' ' 'X' ' ' ' '    ' ' 'X' ' ' 1
      ' '              'YNFIN' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' ',

      'NFKEY'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      '비철구분'       'NFKEY' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' ',

      'BY_SL'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' 'X' ' ' 1
      ' '              'BY_SL' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' ',

      'BSTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      'Buy/Sell'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ENDMM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '              'ENDMM' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG'    ' '    'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '요청수량'       'EMENG' 'ZNFT1011' ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'MEINS' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' ',

      'RQTYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '              'RQTYP' 'ZNFT1010' ' ' ' '    'X' ' ' ' ' ' ',

      'RQTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '요청유형내역'   ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'CONNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'CONNO' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' ',

      'COTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '              'COTXT' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'COTYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '              'COTYP' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'CTPTX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '계약유형내역'   ' '     ' '        ' ' ' '    'X' ' ' ' ' ' ',

      'KUNNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'KUNNR' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'NCUST'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '              'NCUST' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'SUJUD'    ' '    ' '  ' '  ' '  ' '  ' '    ' '  ' '  ' ' 12
      '수주일'         'SUJUD' 'ZNFT1000' ' ' ' '    ' ' ' ' ' ' ' ',

      'SALER'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'SALER' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG1'    ' '    'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '수주량'       'EMENG' 'ZNFT1001' ' ' ' '    ' ' ' ' ' ' ' ',
**** HDY 20120823 START [20120821_68215]
**** 수주금액 통화키를 원화일때와 구분, 수주금액 통화키 조회
*      'PRICE1'   'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
*      '수주금액'       'PRICE' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',
      'PRICE1'   'WAERS1'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '수주금액'       'PRICE' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'WAERS1'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      '수주통화'              'WAERS' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',
**** HDY 20120823 END
      'PRIND'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '가격구분'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'SUJUP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '비철수주가'     ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ERNAM'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 12
      '요청자'         'ERNAM' 'ZNFT1010' ' ' ' '    'X' ' ' ' ' ' ',

      'ERDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '요청일'         'ERDAT' 'ZNFT1010' ' ' ' '    'X' ' ' ' ' ' ',

      'RSTAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '              'RSTAT' 'ZNFT1010' ' ' ' '    'X' ' ' ' ' ' ',

      'RSTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '결재상태내역'   ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'PERNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 8
      '승인자사번'     'PERNR' 'ZNFT1091' ' ' ' '    'X' ' ' ' ' ' ',

      'ENAME'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
*      '승인자명'       'ENAME' 'PA0001'   ' ' ' '    'X' ' ' ' ' ' ',
      '승인자명'       'ENAME' 'ZZPA0001' ' ' ' '    'X' ' ' ' ' ' ',

      'NFCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'NFCTR' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'NTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'NTEXT' 'ZNFT0005' ' ' ' '    'X' ' ' ' ' ' ',

      'PRCTR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'PRCTR' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'ZPJNO'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'ZPJNO' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'PTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '손익센터 명'              'PTEXT' 'ZNFT0004' ' ' ' '    'X' ' ' ' ' ' ',

      'VKGRP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'VKGRP' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'VTEXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      ' '              'VTEXT' 'ZNFT0003' ' ' ' '    'X' ' ' ' ' ' ',

      'WHYDE'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '변경사유'       'WHYDE' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' ',

      'NFUTN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'NFUTN' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'RUDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'RUDAT' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'FCM'      ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'FCM'   'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'ENDAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'ENDAT' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'MITYP'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 1
      ' '              'MITYP' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'MITPT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 20
      '집행유형 내역'  ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'WAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      ' '              'WAERS' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'MISPD'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'MISPD' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'MIMON'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 7
      ' '              'MIMON' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'PRICE'    'WAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '       'PRICE' 'ZNFT1020' ' ' ' '    'X' ' ' ' ' ' ',

      'PRATE'    ' '  ' '     ' '  ' '  'R'  ' '    ' '  ' '  ' ' 12
      '영업이익률(%)'  'PRATE' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG2'   ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'EMENG' 'ZNFT1020' ' ' ' '    ' ' ' ' ' ' ' ',

      'CSTAT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '청산상태'       ' '     ' '        ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'BIGO4'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '              'BIGO4' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' '.

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
*     I_CALLBACK_TOP_OF_PAGE   = GV_TOP_OF_PAGE
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

  IF GV_TRTYP = 'A'.
    LS_EXTAB-FCODE = 'CHNG'.
    APPEND LS_EXTAB TO EXTAB.
  ENDIF.

  SET PF-STATUS 'STANDARD' EXCLUDING  EXTAB .
  SET TITLEBAR  '100'      WITH GV_TITLE.

ENDFORM.                " PF_STATUS_SET
*&---------------------------------------------------------------------
*& Form USER_COMMAND
*&---------------------------------------------------------------------
FORM USER_COMMAND USING PV_UCOMM
                        PS_SELFIELD TYPE SLIS_SELFIELD.
  CASE PV_UCOMM.
    WHEN 'CHNG'.
      PERFORM CHECK_SELECTED_ROWS.
      IF GV_ERROR IS INITIAL AND GT_MAIN-REQNO IS NOT INITIAL.
        SET PARAMETER ID 'ZNFREQ' FIELD GT_MAIN-REQNO.

        CALL TRANSACTION 'ZNF2M2102' AND SKIP FIRST SCREEN.

        PERFORM GET_FUTURES_REQ_DATA.
      ENDIF.

    WHEN 'RFSH'.
      PERFORM GET_FUTURES_REQ_DATA.

    WHEN '&IC1'.
      CASE PS_SELFIELD-FIELDNAME.
        WHEN 'CONNO'.
          IF PS_SELFIELD-VALUE IS NOT INITIAL.
            SET PARAMETER ID 'ZNFCON' FIELD PS_SELFIELD-VALUE.

            CALL TRANSACTION 'ZNF2M2003' AND SKIP FIRST SCREEN.
          ENDIF.

        WHEN 'REQNO'.
          IF PS_SELFIELD-VALUE IS NOT INITIAL.
            SET PARAMETER ID 'ZNFREQ' FIELD PS_SELFIELD-VALUE.

            CALL TRANSACTION 'ZNF2M2103' AND SKIP FIRST SCREEN.
          ENDIF.

        WHEN 'NFUTN'.
          IF PS_SELFIELD-VALUE IS NOT INITIAL.
            PERFORM DISPLAY_FUTRUES_HISTORY USING PS_SELFIELD-VALUE.
          ENDIF.

      ENDCASE.
  ENDCASE.

  PS_SELFIELD-REFRESH    = 'X'.
  PS_SELFIELD-COL_STABLE = 'X'.
  PS_SELFIELD-ROW_STABLE = 'X'.

ENDFORM.                    "USER_COMMAND
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
      DYNAME     = 'ZNFR2110'
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
*&      Form  CHECK_SETTLE_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_SETTLE_STATUS .
  DATA: LV_EMENG    LIKE ZNFT1030-EMENG.

  CHECK GT_MAIN-NFUTN IS NOT INITIAL.

  CLEAR : LV_EMENG.

  SELECT SUM( EMENG )
    INTO LV_EMENG
    FROM ZNFT1030
   WHERE NFUTN = GT_MAIN-NFUTN
     AND YNCAN = ' '
     AND YNNET = ' '.

  IF LV_EMENG IS INITIAL.
    GT_MAIN-CSTAT = '미청산'.
  ELSEIF LV_EMENG >= GT_MAIN-EMENG2.
    GT_MAIN-CSTAT = '청산완료'.
  ELSE.
    GT_MAIN-CSTAT = '부분청산'.
  ENDIF.

ENDFORM.                    " CHECK_SETTLE_STATUS
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_ROWS .
  DATA: LV_CNT      TYPE I.

  CLEAR : LV_CNT, GV_ERROR.

  LOOP AT GT_MAIN WHERE CHECK = 'X'.
    LV_CNT = LV_CNT + 1.
  ENDLOOP.

  IF LV_CNT > 1.
    GV_ERROR = 'X'.

    MESSAGE S001 DISPLAY LIKE 'E'
       WITH '한 라인만 선택하시기 바랍니다.'.
  ELSEIF LV_CNT < 1.
    GV_ERROR = 'X'.

    MESSAGE S001 DISPLAY LIKE 'E'
       WITH '선택된 라인이 없습니다.'.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTED_CHECKBOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTED_CHECKBOX  USING    PV_ERROR.

  CLEAR : PV_ERROR.

  IF P_CHK01 IS INITIAL AND P_CHK02 IS INITIAL AND
     P_CHK03 IS INITIAL AND P_CHK04 IS INITIAL AND
     P_CHK05 IS INITIAL.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '요청유형을 선택하시기 바랍니다.'.

    EXIT.
  ENDIF.

  IF P_CHK11 IS INITIAL AND P_CHK12 IS INITIAL.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '마감여부를 선택하시기 바랍니다.'.

    EXIT.
  ENDIF.

  IF P_CHK21 IS INITIAL AND P_CHK22 IS INITIAL AND
     P_CHK23 IS INITIAL AND P_CHK24 IS INITIAL AND
     P_CHK25 IS INITIAL AND P_CHK26 IS INITIAL AND
     P_CHK27 IS INITIAL.
    PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '결재상태를 선택하시기 바랍니다.'.

    EXIT.
  ENDIF.

ENDFORM.                    " CHECK_SELECTED_CHECKBOX
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
      DYNAME     = 'ZNFR2110'
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
      DYNAME     = 'ZNFR2110'
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

  APPEND_PARAM : LT_RSPAR 'P_BUKRS' 'P' ' ' ' '  P_BUKRS  ' ',
                 LT_RSPAR 'S_NFUTN' 'S' 'I' 'EQ' PV_NFUTN ' ',
                 LT_RSPAR 'P_CHK11' 'P' ' ' ' '  'X'      ' ',
                 LT_RSPAR 'P_CHK12' 'P' ' ' ' '  ' '      ' ',
                 LT_RSPAR 'P_R01'   'P' ' ' ' '  ' '      ' ',
                 LT_RSPAR 'P_R02'   'P' ' ' ' '  ' '      ' ',
                 LT_RSPAR 'P_R03'   'P' ' ' ' '  'X'      ' ',
                 LT_RSPAR 'P_R11'   'P' ' ' ' '  ' '      ' ',
                 LT_RSPAR 'P_R12'   'P' ' ' ' '  ' '      ' ',
                 LT_RSPAR 'P_R13'   'P' ' ' ' '  'X'      ' ',
                 LT_RSPAR 'P_R21'   'P' ' ' ' '  ' '      ' ',
                 LT_RSPAR 'P_R22'   'P' ' ' ' '  ' '      ' ',
                 LT_RSPAR 'P_R23'   'P' ' ' ' '  'X'      ' '.

  SUBMIT ZNFR2600 WITH SELECTION-TABLE LT_RSPAR
                   AND RETURN.

ENDFORM.                    " DISPLAY_FUTRUES_HISTORY
