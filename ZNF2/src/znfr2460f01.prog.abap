*&---------------------------------------------------------------------*
*&  Include           ZNFR2460F01
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

  IF SY-DATLO+4(2) = '01'.
    P_ENDMM(4)   = SY-DATLO(4) - 1.
    P_ENDMM+4(2) = '12'.
  ELSE.
    P_ENDMM = SY-DATLO(6) - 1.
  ENDIF.

  IF SY-TCODE = GC_TCODE2.
    GV_TITLE = '내역 조회'.
  ENDIF.

  SET TITLEBAR '100' WITH GV_TITLE.

ENDFORM.                    " SET_DEFAULT_PARAMETER
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

  IF P_ENDMM IS NOT INITIAL AND
     ( P_ENDMM+4(2) < '01' OR P_ENDMM+4(2) > '12' ).
    MESSAGE E003 WITH '만기월을 점검하십시오.'.
  ENDIF.

ENDFORM.                    " CHECK_ENDMM
*&---------------------------------------------------------------------*
*&      Form  GET_SETTLEMENT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SETTLEMENT_DATA .

  CLEAR   : GT_MAIN.
  REFRESH : GT_MAIN.

*___선물손익 확정 데이터
  PERFORM GET_ZNFT1051_DATA.

*___선물손익 배부
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_MAIN
    FROM ZNFT1053
   WHERE ENDMM = P_ENDMM
     AND BUKRS = P_BUKRS.

  LOOP AT GT_MAIN.
*___집행수량/단위
    LOOP AT GT_1051 WHERE CONNO = GT_MAIN-CONNO
                      AND NFKEY = GT_MAIN-NFKEY.
      IF GT_MAIN-EMEIN IS INITIAL.
        GT_MAIN-EMEIN = GT_1051-MEINS.
      ENDIF.

      GT_MAIN-EMENG = GT_MAIN-EMENG + GT_1051-EMENG.
    ENDLOOP.

*___제품군/판매처/오더수량/단위
    SELECT SINGLE A~SPART
                  B~KUNNR
                  A~KWMENG
                  A~VRKME
      INTO (GT_MAIN-SPART,  GT_MAIN-KUNNR,
            GT_MAIN-KWMENG, GT_MAIN-VRKME)
      FROM VBAP AS A
     INNER JOIN VBAK AS B
        ON A~VBELN = B~VBELN
     WHERE A~VBELN = GT_MAIN-VBELN
       AND A~POSNR = GT_MAIN-POSNR.

*___기타정보 Select
    PERFORM GET_OTHER_DATA.

    MODIFY GT_MAIN.
  ENDLOOP.

  SORT GT_MAIN BY CONNO NFKEY VBELN POSNR.

ENDFORM.                    " GET_SETTLEMENT_DATA
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

      'ENDMM'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 7
      '정산월'         'ENDMM' 'ZNFT1011' ' ' ' '    'X' ' ' ' ' ' ',

      'EMENG'    ' '      'EMEIN' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'EMENG' 'ZNFT1051' ' ' ' '    ' ' ' ' ' ' ' ',

      'EMEIN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'MEINS' 'ZNFT1051' ' ' ' '    'X' ' ' ' ' ' ',

      'COTXT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '              'COTXT' 'ZNFT1000' ' ' ' '    'X' ' ' ' ' ' ',

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

      'VBELN'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'VBELN' 'ZNFT1053' ' ' ' '    'X' ' ' ' ' ' ',

      'POSNR'    ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 6
      ' '              'POSNR' 'ZNFT1053' ' ' ' '    'X' ' ' ' ' ' ',

      'SPART'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 2
      ' '              'SPART' 'VBAP'     ' ' ' '    'X' ' ' ' ' ' ',

      'MATNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 18
      ' '              'MATNR' 'ZNFT1053' ' ' ' '    'X' ' ' ' ' ' ',

      'MAKTX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '              'MAKTX' 'MAKT'     ' ' ' '    'X' ' ' ' ' ' ',

      'MAVGW'    ' '      'MABME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'MAVGW' 'ZNFT1053' ' ' ' '    ' ' ' ' ' ' ' ',

      'MABME'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'MABME' 'ZNFT1053' ' ' ' '    'X' ' ' ' ' ' ',

      'VGE'      ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'VGE'   'ZNFT1053' ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'MEINS' 'ZNFT1053' ' ' ' '    'X' ' ' ' ' ' ',

      'KUNNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      ' '              'KUNNR' 'VBAK'     ' ' ' '    'X' ' ' ' ' ' ',

      'NAMAG'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      '판매처명'       'NAME1' 'KNA1'     ' ' ' '    'X' ' ' ' ' ' ',

      'KUNWE'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 10
      '납품처'         'KUNNR' 'VBAK'     ' ' ' '    'X' ' ' ' ' ' ',

      'NAMWE'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      '납품처명'       'NAME1' 'KNA1'     ' ' ' '    'X' ' ' ' ' ' ',

      'VRKME'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'VRKME' 'VBAP'     ' ' ' '    'X' ' ' ' ' ' ',

      'KWMENG'   ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '             'KWMENG' 'VBAP'     ' ' ' '    ' ' ' ' ' ' ' ',

      'ORVGW'    ' '      'MABME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '오더비철수량'   'BLVGW' 'ZNFT1053' ' ' ' '    ' ' ' ' ' ' ' ',

      'FKIMG'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'FKIMG' 'ZNFT1053' ' ' ' '    ' ' ' ' ' ' ' ',

      'BLVGW'    ' '      'MABME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'BLVGW' 'ZNFT1053' ' ' ' '    ' ' ' ' ' ' ' ',

      'NBFKI'    ' '      'VRKME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'NBFKI' 'ZNFT1053' ' ' ' '    ' ' ' ' ' ' ' ',

      'NBVGW'    ' '      'MABME' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      ' '              'NBVGW' 'ZNFT1053' ' ' ' '    ' ' ' ' ' ' ' ',

      'MABME'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 3
      ' '              'MABME' 'ZNFT1053' ' ' ' '    'X' ' ' ' ' ' ',

      'UPRLO'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '청구선물손익(USD)' 'UPRLO' 'ZNFT1053' ' ' ' ' ' ' ' ' ' ' ' ',

      'UPLRM'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '잔량선물손익(USD)' 'UPLRM' 'ZNFT1053' ' ' ' ' ' ' ' ' ' ' ' ',

      'UPLSM'    'UAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '총선물손익(USD)' 'UPLRM' 'ZNFT1053' ' ' ' '   ' ' ' ' ' ' ' ',

      'UAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      ' '              'UAERS' 'ZNFT1053' ' ' ' '    'X' ' ' ' ' ' ',

      'KPRLO'    'KAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '청구선물손익(KRW)' 'KPRLO' 'ZNFT1053' ' ' ' ' ' ' ' ' ' ' ' ',

      'KPLRM'    'KAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '잔량선물손익(KRW)' 'KPLRM' 'ZNFT1053' ' ' ' ' ' ' ' ' ' ' ' ',

      'KPLSM'    'KAERS'  ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 12
      '총선물손익(KRW)' 'KPLRM' 'ZNFT1053' ' ' ' '   ' ' ' ' ' ' ' ',

      'KAERS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 5
      ' '              'KAERS' 'ZNFT1053' ' ' ' '    'X' ' ' ' ' ' '.

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

  IF SY-TCODE = GC_TCODE2.
    LS_EXTAB-FCODE = 'SAVE'.
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
    WHEN 'SAVE'.
      PERFORM SAVE_DISTRIBUTION_DATA.

    WHEN 'RFSH'.
      IF SY-TCODE = GC_TCODE2.
        PERFORM GET_SETTLEMENT_DATA.
      ELSE.
        PERFORM MAKE_SETTLEMENT_DATA.
      ENDIF.

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
*&      Form  GET_ZNFT1051_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ZNFT1051_DATA .

  CLEAR   : GT_1051.
  REFRESH : GT_1051.

*___정산월 시작일/종료일
  CONCATENATE P_ENDMM '01' INTO GV_FRDAT.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = GV_FRDAT
    IMPORTING
      LAST_DAY_OF_MONTH = GV_TODAT
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.

*___선물손익 확정
  SELECT *
    INTO TABLE GT_1051
    FROM ZNFT1051
   WHERE BUKRS =  P_BUKRS
     AND ENDAT BETWEEN GV_FRDAT AND GV_TODAT.
*     AND BELNR <> ' '.

ENDFORM.                    " GET_ZNFT1051_DATA
*&---------------------------------------------------------------------*
*&      Form  MAKE_SETTLEMENT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_SETTLEMENT_DATA .
  DATA: LS_TVGW      LIKE GT_TVGW,
        LV_CREFI     LIKE ZNFT1050-CREFI,
        LV_TEXT(200).

  CLEAR   : GT_MAIN, GT_PRLO, GT_SOSUM, GR_CONNO.
  REFRESH : GT_MAIN, GT_PRLO, GT_SOSUM, GR_CONNO.

*___선물손익 확정 데이터
  PERFORM GET_ZNFT1051_DATA.

*___손익 정산 진행여부 점검
  SELECT SINGLE CREFI
    INTO LV_CREFI
    FROM ZNFT1050
   WHERE BUKRS = P_BUKRS
     AND ENDAT BETWEEN GV_FRDAT AND GV_TODAT.

  IF SY-SUBRC = 0.
    SELECT SINGLE CREFI
      INTO LV_CREFI
      FROM ZNFT1050
     WHERE BUKRS = P_BUKRS
       AND ENDAT BETWEEN GV_FRDAT AND GV_TODAT
       AND CREFI = ' '.

    IF SY-SUBRC = 0.
      LV_TEXT = '해당월의 손익정산이 완료되지 않았습니다. ' &
                '계속하시겠습니까?'.
    ENDIF.
  ELSE.
    LV_TEXT = '해당월의 손익정산이 완료되지 않았습니다. ' &
              '계속하시겠습니까?'.
  ENDIF.

  IF LV_TEXT IS NOT INITIAL.
    PERFORM POPUP_TO_CONFIRM USING '확인'
                                   LV_TEXT
                                   '1'
                                   GV_ANSWER.
  ELSE.
    GV_ANSWER = '1'.
  ENDIF.

  CHECK GV_ANSWER = '1'.

*___계약번호/비철구분별 선물손익 집계
  LOOP AT GT_1051.
    CLEAR : GT_PRLO, GR_CONNO.

    MOVE-CORRESPONDING GT_1051 TO GT_PRLO.

    COLLECT GT_PRLO.

    GR_CONNO-SIGN   = 'I'.
    GR_CONNO-OPTION = 'EQ'.
    GR_CONNO-LOW    = GT_1051-CONNO.
    COLLECT GR_CONNO.
  ENDLOOP.

*___계약과 연결된 판매오더 정보
  PERFORM GET_SALES_ORDER_DATA.

*___조회데이터 생성
  LOOP AT GT_PRLO.
    LOOP AT GT_VBAP WHERE CONNO = GT_PRLO-CONNO.
*___파트너 조건 포함 비철량 - 영업영역
      LOOP AT GT_TVGW WHERE PARNR = GT_VBAP-KUNNR
                        AND MATNR = GT_VBAP-MATNR
                        AND KAPPL = 'V'
                        AND ORG   = GT_VBAP-VKORG
                        AND VTWEG = GT_VBAP-VTWEG
                        AND NES   = GT_PRLO-NFKEY.

        PERFORM MOVE_SALES_ORDER_DATA.

      ENDLOOP.

      IF SY-SUBRC <> 0.
*___파트너 조건 제외 비철량 - 영업영역
        LOOP AT GT_TVGW WHERE MATNR = GT_VBAP-MATNR
                          AND KAPPL = 'V'
                          AND ORG   = GT_VBAP-VKORG
                          AND VTWEG = GT_VBAP-VTWEG
                          AND NES   = GT_PRLO-NFKEY.

          PERFORM MOVE_SALES_ORDER_DATA.

        ENDLOOP.

        IF SY-SUBRC <> 0.
*___플랜트별 비철량 - MRP View
          LOOP AT GT_TVGW WHERE MATNR = GT_VBAP-MATNR
                            AND WERKS = GT_VBAP-WERKS
                            AND NES   = GT_PRLO-NFKEY.

            PERFORM MOVE_SALES_ORDER_DATA.

          ENDLOOP.

          IF SY-SUBRC <> 0.
*___비철량 - MRP View
            READ TABLE GT_TVGW INTO LS_TVGW
                               WITH KEY MATNR = GT_VBAP-MATNR.
            IF SY-SUBRC = 0.
              LOOP AT GT_TVGW WHERE MATNR = GT_VBAP-MATNR
                                AND WERKS = LS_TVGW-WERKS
                                AND NES   = GT_PRLO-NFKEY.

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

    IF SY-SUBRC <> 0.
      CLEAR : GT_VBAP, GT_TVGW.

      PERFORM MOVE_SALES_ORDER_DATA.
    ENDIF.
  ENDLOOP.

*___선물손익 배부
  LOOP AT GT_SOSUM.
    CLEAR : GT_PRLO.

    READ TABLE GT_PRLO WITH KEY CONNO = GT_SOSUM-CONNO
                                NFKEY = GT_SOSUM-NFKEY.
    CHECK SY-SUBRC IS INITIAL.

    PERFORM DISTRIBUTION_PROFIT_LOSS_3.

*    IF GT_SOSUM-BLVGW >= GT_PRLO-EMENG.
**___빌링비철수량이 집행수량(정산수량)보다 크거나 같은 경우
*      PERFORM DISTRIBUTION_PROFIT_LOSS_1.
*    ELSE.
**___빌링비철수량이 집행수량(정산수량)보다 작은 경우
*      PERFORM DISTRIBUTION_PROFIT_LOSS_2.
*    ENDIF.
  ENDLOOP.

  LOOP AT GT_MAIN.
*___계약에 연결된 판매오더가 존재하지 않는 경우
*   총손익에 값을 넣었기 때문에 금액합 계산에서 제외
    IF GT_MAIN-UPLSM IS INITIAL AND
       GT_MAIN-KPLSM IS INITIAL.
      GT_MAIN-UPLSM = GT_MAIN-UPRLO + GT_MAIN-UPLRM.
      GT_MAIN-KPLSM = GT_MAIN-KPRLO + GT_MAIN-KPLRM.
    ENDIF.

    GT_MAIN-ERDAT = SY-DATLO.
    GT_MAIN-ERZET = SY-TIMLO.
    GT_MAIN-ERNAM = SY-UNAME.

    MODIFY GT_MAIN.
  ENDLOOP.

  SORT GT_MAIN BY CONNO NFKEY VBELN POSNR.

ENDFORM.                    " MAKE_SETTLEMENT_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_SALES_ORDER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SALES_ORDER_DATA .
  DATA: LV_FLAG.

  CHECK GR_CONNO[] IS NOT INITIAL.

  CLEAR   : GT_VBAP.
  REFRESH : GT_VBAP.

*___해당 계약번호가 입력된 판매오더
  SELECT A~VBELN
         A~POSNR
         A~MATNR
         B~VKORG
         A~WERKS
         B~VTWEG
         A~SPART
         B~KUNNR
         A~KWMENG
         A~VRKME
         A~CONNO
    INTO CORRESPONDING FIELDS OF TABLE GT_VBAP
    FROM VBAP AS A
   INNER JOIN VBAK AS B
      ON A~VBELN = B~VBELN
   WHERE A~CONNO IN GR_CONNO.

  LOOP AT GT_VBAP.
*___해당자재의 비철량
    READ TABLE GT_TVGW WITH KEY MATNR = GT_VBAP-MATNR.
    IF SY-SUBRC <> 0.
      PERFORM GET_MATERIAL_NFQTY USING LV_FLAG.

      IF LV_FLAG IS NOT INITIAL.
        DELETE GT_VBAP WHERE MATNR = GT_VBAP-MATNR.

        CONTINUE.
      ENDIF.
    ENDIF.

"-> CCM : 2023.04.20 ZITCS4HDEV06 - VBRK 확인
*___대금청구수량 - 정산월
    SELECT SUM( A~FKIMG )
      INTO GT_VBAP-FKIMG
      FROM VBRP AS A
     INNER JOIN VBRK AS B
        ON A~VBELN = B~VBELN
     WHERE A~AUBEL = GT_VBAP-VBELN
       AND A~AUPOS = GT_VBAP-POSNR
       AND B~RFBSK = 'C'
       AND B~SFAKN = ' '
       AND B~FKSTO = ' '
*-- [CCM-MM] DRAFT 지시자 추가 ZLSGMM4 2023.04.19
       AND A~DRAFT = ' '
       AND B~DRAFT = ' '
       AND B~FKDAT BETWEEN GV_FRDAT AND GV_TODAT.

"-> CCM : 2023.04.20 ZITCS4HDEV06 - VBRP 확인
*___대금청구수량 - 이전월
    SELECT SUM( A~FKIMG )
      INTO GT_VBAP-FKPRE
      FROM VBRP AS A
     INNER JOIN VBRK AS B
        ON A~VBELN = B~VBELN
     WHERE A~AUBEL = GT_VBAP-VBELN
       AND A~AUPOS = GT_VBAP-POSNR
       AND B~RFBSK = 'C'
       AND B~SFAKN = ' '
       AND B~FKSTO = ' '
*-- [CCM-MM] DRAFT 지시자 추가 ZLSGMM4 2023.04.19
       AND A~DRAFT = ' '
       AND B~DRAFT = ' '
       AND B~FKDAT < GV_FRDAT.

    MODIFY GT_VBAP.
  ENDLOOP.

ENDFORM.                    " GET_SALES_ORDER_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_MATERIAL_NFQTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_MATERIAL_NFQTY USING PV_ERROR.

  CLEAR : PV_ERROR.

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

    IF SY-SUBRC <> 0.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_MATERIAL_NFQTY
*&---------------------------------------------------------------------*
*&      Form  GET_OTHER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_OTHER_DATA .
  DATA: LV_KWMENG   LIKE VBAP-KWMENG.

*___선물손익합계
  GT_MAIN-UPLSM = GT_MAIN-UPRLO + GT_MAIN-UPLRM.
  GT_MAIN-KPLSM = GT_MAIN-KPRLO + GT_MAIN-KPLRM.

*___오더 비철수량
  LV_KWMENG = GT_MAIN-KWMENG.

  PERFORM CONVERT_MATERIAL_UNIT USING GT_MAIN-MATNR
                                      GT_MAIN-VRKME
                                      GT_MAIN-MEINS
                                      LV_KWMENG.

  IF GT_MAIN-VGE IS NOT INITIAL.
    GT_MAIN-ORVGW = LV_KWMENG * GT_MAIN-MAVGW / GT_MAIN-VGE.
  ENDIF.

*___계약정보
  SELECT SINGLE COTXT
                NFCTR
                PRCTR
                VKGRP
    INTO (GT_MAIN-COTXT, GT_MAIN-NFCTR,
          GT_MAIN-PRCTR, GT_MAIN-VKGRP)
    FROM ZNFT1000
   WHERE CONNO = GT_MAIN-CONNO.

*___납품처
  SELECT SINGLE KUNNR
    INTO GT_MAIN-KUNWE
    FROM VBPA
   WHERE VBELN = GT_MAIN-VBELN
     AND POSNR = '000000'
     AND PARVW = 'WE'.

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
  PERFORM GET_MATNR_DESC USING GT_MAIN-MATNR
                               GT_MAIN-MAKTX.

*___판매처/납품처명
  PERFORM GET_KUNNR_DESC USING : GT_MAIN-KUNNR
                                 GT_MAIN-NAMAG,

                                 GT_MAIN-KUNWE
                                 GT_MAIN-NAMWE.

ENDFORM.                    " GET_OTHER_DATA
*&---------------------------------------------------------------------*
*&      Form  MOVE_SALES_ORDER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MOVE_SALES_ORDER_DATA .
  DATA: LV_FKIMG    LIKE VBRP-FKIMG.

  CLEAR : GT_MAIN.

  GT_MAIN-CONNO  = GT_PRLO-CONNO.      "계약번호
  GT_MAIN-NFKEY  = GT_PRLO-NFKEY.      "비철구분
  GT_MAIN-ENDMM  = P_ENDMM.            "정산월
  GT_MAIN-EMENG  = GT_PRLO-EMENG.      "집행수량
  GT_MAIN-EMEIN  = GT_PRLO-MEINS.      "단위
  GT_MAIN-VBELN  = GT_VBAP-VBELN.      "판매오더
  GT_MAIN-POSNR  = GT_VBAP-POSNR.      "판매오더품목
  GT_MAIN-BUKRS  = P_BUKRS.            "회사코드
  GT_MAIN-SPART  = GT_VBAP-SPART.      "제품군
  GT_MAIN-MATNR  = GT_VBAP-MATNR.      "자재
  GT_MAIN-MAVGW  = GT_TVGW-VGW.        "자재비철량
  GT_MAIN-VGE    = GT_TVGW-VGE.        "기준수량
  GT_MAIN-KUNNR  = GT_VBAP-KUNNR.      "판매처

*___비철수량단위
  SELECT SINGLE BME
    INTO GT_MAIN-MABME
    FROM /NFM/TNES
   WHERE NES = GT_MAIN-NFKEY.

*___기준수량단위 - 자재마스터 기본단위
  IF GT_MAIN-MATNR IS NOT INITIAL.
    SELECT SINGLE MEINS
      INTO GT_MAIN-MEINS
      FROM MARA
     WHERE MATNR = GT_MAIN-MATNR.
  ENDIF.

  GT_MAIN-VRKME  = GT_VBAP-VRKME.      "오더단위
  GT_MAIN-KWMENG = GT_VBAP-KWMENG.     "오더수량
  GT_MAIN-FKIMG  = GT_VBAP-FKIMG.      "대금청구수량
  GT_MAIN-FKPRE  = GT_VBAP-FKPRE.      "이전월 대금청구수량

*___대금청구되지 않은 수량
  GT_MAIN-NBFKI  = GT_VBAP-KWMENG - GT_VBAP-FKIMG - GT_VBAP-FKPRE.

*___대금청구 비철수량
  LV_FKIMG = GT_MAIN-FKIMG.

  PERFORM CONVERT_MATERIAL_UNIT USING GT_MAIN-MATNR
                                      GT_MAIN-VRKME
                                      GT_MAIN-MEINS
                                      LV_FKIMG.

  IF GT_MAIN-VGE IS NOT INITIAL.
    GT_MAIN-BLVGW = LV_FKIMG * GT_MAIN-MAVGW / GT_MAIN-VGE.
  ENDIF.

*___대금청구되지 않은 비철수량
  LV_FKIMG = GT_MAIN-NBFKI.

  PERFORM CONVERT_MATERIAL_UNIT USING GT_MAIN-MATNR
                                      GT_MAIN-VRKME
                                      GT_MAIN-MEINS
                                      LV_FKIMG.

  IF GT_MAIN-VGE IS NOT INITIAL.
    GT_MAIN-NBVGW = LV_FKIMG * GT_MAIN-MAVGW / GT_MAIN-VGE.
  ENDIF.

*___기타정보 Select
  PERFORM GET_OTHER_DATA.

  APPEND GT_MAIN.

*___계약번호/비철구분별 Blling 비철수량 집계
  CLEAR : GT_SOSUM.

  GT_SOSUM-CONNO = GT_MAIN-CONNO.
  GT_SOSUM-NFKEY = GT_MAIN-NFKEY.
  GT_SOSUM-ORVGW = GT_MAIN-ORVGW.    "오더비철수량
  GT_SOSUM-BLVGW = GT_MAIN-BLVGW.    "정산월 대금청구비철수량
  GT_SOSUM-BLREM = GT_MAIN-NBVGW.    "대금청구되지 않은 비철수량

  COLLECT GT_SOSUM.

ENDFORM.                    " MOVE_SALES_ORDER_DATA
*&---------------------------------------------------------------------*
*&      Form  DISTRIBUTION_PROFIT_LOSS_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISTRIBUTION_PROFIT_LOSS_1.
  DATA: LV_UPRLO LIKE ZNFT1053-UPRLO,
        LV_KPRLO LIKE ZNFT1053-KPRLO.

  CLEAR : LV_UPRLO, LV_KPRLO.

  SORT GT_MAIN BY CONNO NFKEY VBELN POSNR.

  LOOP AT GT_MAIN WHERE CONNO = GT_SOSUM-CONNO
                    AND NFKEY = GT_SOSUM-NFKEY
                    AND BLVGW IS NOT INITIAL.
    GT_MAIN-UAERS = GT_PRLO-UAERS.
    GT_MAIN-KAERS = GT_PRLO-KAERS.

*___정산금액 배부
    IF GT_SOSUM-BLVGW IS NOT INITIAL.
      GT_MAIN-UPRLO = GT_PRLO-UPRLO * GT_MAIN-BLVGW / GT_SOSUM-BLVGW.
      GT_MAIN-KPRLO = GT_PRLO-KPRLO * GT_MAIN-BLVGW / GT_SOSUM-BLVGW.

      LV_UPRLO = LV_UPRLO + GT_MAIN-UPRLO.
      LV_KPRLO = LV_KPRLO + GT_MAIN-KPRLO.
    ENDIF.

    MODIFY GT_MAIN.
  ENDLOOP.

*___배부되지 않은 손익
  LV_UPRLO = GT_PRLO-UPRLO - LV_UPRLO.
  LV_KPRLO = GT_PRLO-KPRLO - LV_KPRLO.

  IF LV_UPRLO IS NOT INITIAL OR
     LV_KPRLO IS NOT INITIAL.
*___잔액배부
    SORT GT_MAIN BY CONNO NFKEY UPRLO DESCENDING.

    LOOP AT GT_MAIN WHERE CONNO = GT_SOSUM-CONNO
                      AND NFKEY = GT_SOSUM-NFKEY
                      AND BLVGW IS NOT INITIAL.
      IF LV_UPRLO IS NOT INITIAL.
        IF LV_UPRLO > 0.
          GT_MAIN-UPRLO = GT_MAIN-UPRLO + '0.01'.
          LV_UPRLO = LV_UPRLO - '0.01'.
        ELSE.
          GT_MAIN-UPRLO = GT_MAIN-UPRLO - '0.01'.
          LV_UPRLO = LV_UPRLO + '0.01'.
        ENDIF.
      ENDIF.

      IF LV_KPRLO IS NOT INITIAL.
        IF LV_KPRLO > 0.
          GT_MAIN-KPRLO = GT_MAIN-KPRLO + '0.01'.
          LV_KPRLO = LV_KPRLO - '0.01'.
        ELSE.
          GT_MAIN-KPRLO = GT_MAIN-KPRLO - '0.01'.
          LV_KPRLO = LV_KPRLO + '0.01'.
        ENDIF.
      ENDIF.

      MODIFY GT_MAIN.

      IF LV_UPRLO IS INITIAL AND LV_KPRLO IS INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " DISTRIBUTION_PROFIT_LOSS_1
*&---------------------------------------------------------------------*
*&      Form  DISTRIBUTION_PROFIT_LOSS_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISTRIBUTION_PROFIT_LOSS_2 .
  DATA: LV_UPRLO LIKE ZNFT1053-UPRLO,
        LV_KPRLO LIKE ZNFT1053-KPRLO,
        LV_URMPL LIKE ZNFT1053-UPRLO,
        LV_KRMPL LIKE ZNFT1053-KPRLO,
        LV_EMENG LIKE ZNFT1051-EMENG,
        LV_UPLAM LIKE ZNFT1053-UPRLO,
        LV_KPLAM LIKE ZNFT1053-KPRLO,
        LV_MENGE LIKE ZNFT1051-EMENG.

  CLEAR : LV_UPRLO, LV_KPRLO.

  SORT GT_MAIN BY CONNO NFKEY VBELN POSNR.

*___1. 빌링 비철수량으로 배부
  LOOP AT GT_MAIN WHERE CONNO = GT_SOSUM-CONNO
                    AND NFKEY = GT_SOSUM-NFKEY
                    AND BLVGW IS NOT INITIAL.
    GT_MAIN-UAERS = GT_PRLO-UAERS.
    GT_MAIN-KAERS = GT_PRLO-KAERS.

*___집행수량을 비철기본단위로 환산
    PERFORM CONVERT_NF_UNIT USING GT_MAIN-EMEIN
                                  GT_MAIN-MABME
                                  GT_PRLO-EMENG
                                  LV_MENGE.

*___정산금액 배부
    IF GT_SOSUM-BLVGW IS NOT INITIAL.
      GT_MAIN-UPRLO = GT_PRLO-UPRLO * GT_MAIN-BLVGW / LV_MENGE.
      GT_MAIN-KPRLO = GT_PRLO-KPRLO * GT_MAIN-BLVGW / LV_MENGE.

      LV_UPRLO = LV_UPRLO + GT_MAIN-UPRLO.
      LV_KPRLO = LV_KPRLO + GT_MAIN-KPRLO.
    ENDIF.

    MODIFY GT_MAIN.
  ENDLOOP.

  IF SY-SUBRC <> 0.
*___집행수량을 비철기본단위로 환산
    PERFORM CONVERT_NF_UNIT USING 'TON'
                                  'KG'
                                  GT_PRLO-EMENG
                                  LV_MENGE.
  ENDIF.

*___배부되지 않은 손익
  LV_EMENG = LV_MENGE - GT_SOSUM-BLVGW.
  LV_URMPL = GT_PRLO-UPRLO - LV_UPRLO.
  LV_KRMPL = GT_PRLO-KPRLO - LV_KPRLO.

  CHECK LV_URMPL IS NOT INITIAL OR
        LV_KRMPL IS NOT INITIAL.

  IF LV_EMENG <= GT_SOSUM-BLREM.
*___2. 배부되지 않은 손익을 S/O별 Billing 되지 않은 잔량으로 배부
*      (B/L 잔량기준)
    LOOP AT GT_MAIN WHERE CONNO = GT_SOSUM-CONNO
                      AND NFKEY = GT_SOSUM-NFKEY.
      GT_MAIN-UAERS = GT_PRLO-UAERS.
      GT_MAIN-KAERS = GT_PRLO-KAERS.

*___정산금액 배부
      IF GT_SOSUM-BLREM IS NOT INITIAL.
        GT_MAIN-UPRLO = GT_MAIN-UPRLO
                      + ( LV_URMPL * GT_MAIN-NBVGW / GT_SOSUM-BLREM ).
        GT_MAIN-KPRLO = GT_MAIN-KPRLO
                      + ( LV_KRMPL * GT_MAIN-NBVGW / GT_SOSUM-BLREM ).

        LV_UPRLO = LV_UPRLO
                 + ( LV_URMPL * GT_MAIN-NBVGW / GT_SOSUM-BLREM ).
        LV_KPRLO = LV_KPRLO
                 + ( LV_KRMPL * GT_MAIN-NBVGW / GT_SOSUM-BLREM ).
      ENDIF.

      MODIFY GT_MAIN.
    ENDLOOP.
  ELSE.
*___3. 배부되지 않은 손익을 S/O별 Billing 되지 않은 잔량으로 배부
*      (정산수량기준)
    LOOP AT GT_MAIN WHERE CONNO = GT_SOSUM-CONNO
                      AND NFKEY = GT_SOSUM-NFKEY.
      GT_MAIN-UAERS = GT_PRLO-UAERS.
      GT_MAIN-KAERS = GT_PRLO-KAERS.

*___집행수량을 비철기본단위로 환산
      PERFORM CONVERT_NF_UNIT USING GT_MAIN-EMEIN
                                    GT_MAIN-MABME
                                    GT_PRLO-EMENG
                                    LV_MENGE.

*___정산금액 배부
      IF GT_SOSUM-BLREM IS NOT INITIAL.
        GT_MAIN-UPRLO = GT_MAIN-UPRLO + ( GT_PRLO-UPRLO
                      * GT_MAIN-NBVGW / LV_MENGE ).
        GT_MAIN-KPRLO = GT_MAIN-KPRLO + ( GT_PRLO-KPRLO
                      * GT_MAIN-NBVGW / LV_MENGE ).

        LV_UPRLO = LV_UPRLO + ( GT_PRLO-UPRLO
                 * GT_MAIN-NBVGW / LV_MENGE ).
        LV_KPRLO = LV_KPRLO + ( GT_PRLO-KPRLO
                 * GT_MAIN-NBVGW / LV_MENGE ).
      ENDIF.

      MODIFY GT_MAIN.
    ENDLOOP.
  ENDIF.

*___배부되지 않은 손익
  LV_UPRLO = GT_PRLO-UPRLO - LV_UPRLO.
  LV_KPRLO = GT_PRLO-KPRLO - LV_KPRLO.

  CHECK LV_UPRLO IS NOT INITIAL OR
        LV_KPRLO IS NOT INITIAL.

  IF LV_EMENG <= GT_SOSUM-BLREM.
*___잔액배부
    SORT GT_MAIN BY CONNO NFKEY UPRLO DESCENDING.

    LOOP AT GT_MAIN WHERE CONNO = GT_SOSUM-CONNO
                      AND NFKEY = GT_SOSUM-NFKEY
                      AND UPRLO IS NOT INITIAL.
      IF LV_UPRLO IS NOT INITIAL.
        IF LV_UPRLO > 0.
          GT_MAIN-UPRLO = GT_MAIN-UPRLO + '0.01'.
          LV_UPRLO = LV_UPRLO - '0.01'.
        ELSE.
          GT_MAIN-UPRLO = GT_MAIN-UPRLO - '0.01'.
          LV_UPRLO = LV_UPRLO + '0.01'.
        ENDIF.
      ENDIF.

      IF LV_KPRLO IS NOT INITIAL.
        IF LV_KPRLO > 0.
          GT_MAIN-KPRLO = GT_MAIN-KPRLO + '0.01'.
          LV_KPRLO = LV_KPRLO - '0.01'.
        ELSE.
          GT_MAIN-KPRLO = GT_MAIN-KPRLO - '0.01'.
          LV_KPRLO = LV_KPRLO + '0.01'.
        ENDIF.
      ENDIF.

      MODIFY GT_MAIN.

      IF LV_UPRLO IS INITIAL AND LV_KPRLO IS INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.
  ELSE.
*___잔액을 별도의 데이터로 생성
    READ TABLE GT_MAIN WITH KEY CONNO = GT_SOSUM-CONNO
                                NFKEY = GT_SOSUM-NFKEY.
    IF SY-SUBRC = 0.
      GT_MAIN-UAERS = GT_PRLO-UAERS.
      GT_MAIN-KAERS = GT_PRLO-KAERS.

*___잔액
      GT_MAIN-UPRLO = LV_UPRLO.
      GT_MAIN-KPRLO = LV_KPRLO.

      IF GT_MAIN-VBELN IS INITIAL.
        MODIFY GT_MAIN INDEX SY-TABIX.
      ELSE.
        CLEAR : GT_MAIN-VBELN,  GT_MAIN-POSNR, GT_MAIN-MATNR,
                GT_MAIN-MEINS,  GT_MAIN-MABME, GT_MAIN-MAVGW,
                GT_MAIN-VGE,    GT_MAIN-VRKME, GT_MAIN-FKIMG,
                GT_MAIN-BLVGW,  GT_MAIN-NBFKI, GT_MAIN-NBVGW,
                GT_MAIN-SPART,  GT_MAIN-MAKTX, GT_MAIN-KUNNR,
                GT_MAIN-NAMAG,  GT_MAIN-KUNWE, GT_MAIN-NAMWE,
                GT_MAIN-KWMENG, GT_MAIN-ORVGW, GT_MAIN-FKPRE.

        APPEND GT_MAIN.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " DISTRIBUTION_PROFIT_LOSS_2
*&---------------------------------------------------------------------*
*&      Form  DISTRIBUTION_PROFIT_LOSS_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISTRIBUTION_PROFIT_LOSS_3 .
  DATA: LV_UPRLO LIKE ZNFT1053-UPRLO,
        LV_KPRLO LIKE ZNFT1053-KPRLO,
        LV_URMPL LIKE ZNFT1053-UPRLO,
        LV_KRMPL LIKE ZNFT1053-KPRLO,
        LV_MENGE LIKE ZNFT1051-EMENG,
        LV_FLAG1,
        LV_FLAG2.

  CLEAR : LV_UPRLO, LV_KPRLO,
          LV_FLAG1, LV_FLAG2.

  SORT GT_MAIN BY CONNO NFKEY VBELN POSNR.

*___1. 빌링 비철수량으로 배부
  LOOP AT GT_MAIN WHERE CONNO = GT_SOSUM-CONNO
                    AND NFKEY = GT_SOSUM-NFKEY
                    AND BLVGW IS NOT INITIAL.
    GT_MAIN-UAERS = GT_PRLO-UAERS.
    GT_MAIN-KAERS = GT_PRLO-KAERS.

*___집행수량을 비철기본단위로 환산
    PERFORM CONVERT_NF_UNIT USING GT_MAIN-EMEIN
                                  GT_MAIN-MABME
                                  GT_PRLO-EMENG
                                  LV_MENGE.

*___빌링비철수량합이 집행수량보다 큰 경우
*   빌링비철수량을 기준으로 금액배부를 위해...
    IF LV_MENGE < GT_SOSUM-BLVGW.
      LV_MENGE = GT_SOSUM-BLVGW.
    ENDIF.

*___정산금액 배부
    IF LV_MENGE IS NOT INITIAL.
      GT_MAIN-UPRLO = GT_PRLO-UPRLO  * GT_MAIN-BLVGW / LV_MENGE.
      GT_MAIN-KPRLO = GT_PRLO-KPRLO  * GT_MAIN-BLVGW / LV_MENGE.

      LV_UPRLO = LV_UPRLO + GT_MAIN-UPRLO.
      LV_KPRLO = LV_KPRLO + GT_MAIN-KPRLO.
    ENDIF.

    MODIFY GT_MAIN.
  ENDLOOP.

  IF SY-SUBRC <> 0.
    LV_FLAG1 = 'X'.
  ENDIF.

*___2. 배부잔액을 BL 잔량 기준으로 배부
  LV_URMPL = GT_PRLO-UPRLO - LV_UPRLO.
  LV_KRMPL = GT_PRLO-KPRLO - LV_KPRLO.

  CHECK LV_URMPL IS NOT INITIAL OR
        LV_KRMPL IS NOT INITIAL.

  LOOP AT GT_MAIN WHERE CONNO = GT_SOSUM-CONNO
                    AND NFKEY = GT_SOSUM-NFKEY
                    AND NBVGW IS NOT INITIAL.
    GT_MAIN-UAERS = GT_PRLO-UAERS.
    GT_MAIN-KAERS = GT_PRLO-KAERS.

*___정산금액 배부
    IF GT_SOSUM-BLREM IS NOT INITIAL.
      GT_MAIN-UPLRM = LV_URMPL * GT_MAIN-NBVGW / GT_SOSUM-BLREM.
      GT_MAIN-KPLRM = LV_KRMPL * GT_MAIN-NBVGW / GT_SOSUM-BLREM.

      LV_UPRLO = LV_UPRLO + GT_MAIN-UPLRM.
      LV_KPRLO = LV_KPRLO + GT_MAIN-KPLRM.
    ENDIF.

    MODIFY GT_MAIN.
  ENDLOOP.

  IF SY-SUBRC <> 0.
    LV_FLAG2 = 'X'.
  ENDIF.

*___배부되지 않은 손익
  LV_UPRLO = GT_PRLO-UPRLO - LV_UPRLO.
  LV_KPRLO = GT_PRLO-KPRLO - LV_KPRLO.

  CHECK LV_UPRLO IS NOT INITIAL OR
        LV_KPRLO IS NOT INITIAL.

*___잔액배부
  SORT GT_MAIN BY CONNO NFKEY UPRLO DESCENDING.

  IF LV_FLAG1 = 'X' AND LV_FLAG2 = 'X'.
*___3. 계약과 연결된 판매오더가 존재하지 않는 경우
    READ TABLE GT_MAIN WITH KEY CONNO = GT_SOSUM-CONNO
                                NFKEY = GT_SOSUM-NFKEY.
    IF SY-SUBRC = 0.
      GT_MAIN-UAERS = GT_PRLO-UAERS.
      GT_MAIN-KAERS = GT_PRLO-KAERS.
      GT_MAIN-UPLSM = LV_UPRLO.
      GT_MAIN-KPLSM = LV_KPRLO.

      MODIFY GT_MAIN INDEX SY-TABIX.
    ENDIF.
  ELSE.
    IF LV_FLAG2 = 'X'.
*___4. 잔액을 배부할 빌링잔량 데이터가 없는 경우
*      별도의 라인 추가
      READ TABLE GT_MAIN WITH KEY CONNO = GT_SOSUM-CONNO
                                  NFKEY = GT_SOSUM-NFKEY.
      IF SY-SUBRC = 0.
        GT_MAIN-UAERS = GT_PRLO-UAERS.
        GT_MAIN-KAERS = GT_PRLO-KAERS.
        GT_MAIN-UPLSM = LV_UPRLO.
        GT_MAIN-KPLSM = LV_KPRLO.

        CLEAR : GT_MAIN-VBELN,  GT_MAIN-POSNR, GT_MAIN-MATNR,
                GT_MAIN-MEINS,  GT_MAIN-MABME, GT_MAIN-MAVGW,
                GT_MAIN-VGE,    GT_MAIN-VRKME, GT_MAIN-FKIMG,
                GT_MAIN-BLVGW,  GT_MAIN-NBFKI, GT_MAIN-NBVGW,
                GT_MAIN-SPART,  GT_MAIN-MAKTX, GT_MAIN-KUNNR,
                GT_MAIN-NAMAG,  GT_MAIN-KUNWE, GT_MAIN-NAMWE,
                GT_MAIN-KWMENG, GT_MAIN-ORVGW, GT_MAIN-FKPRE.

        APPEND GT_MAIN.
      ENDIF.
    ELSE.
*___5. 당월 빌링수량이 존재하는 데이터에 잔액 배부
      LOOP AT GT_MAIN WHERE CONNO = GT_SOSUM-CONNO
                        AND NFKEY = GT_SOSUM-NFKEY
                        AND BLVGW IS NOT INITIAL.
        IF LV_UPRLO IS NOT INITIAL.
          IF LV_UPRLO > 0.
            GT_MAIN-UPRLO = GT_MAIN-UPRLO + '0.01'.
            LV_UPRLO = LV_UPRLO - '0.01'.
          ELSE.
            GT_MAIN-UPRLO = GT_MAIN-UPRLO - '0.01'.
            LV_UPRLO = LV_UPRLO + '0.01'.
          ENDIF.
        ENDIF.

        IF LV_KPRLO IS NOT INITIAL.
          IF LV_KPRLO > 0.
            GT_MAIN-KPRLO = GT_MAIN-KPRLO + '0.01'.
            LV_KPRLO = LV_KPRLO - '0.01'.
          ELSE.
            GT_MAIN-KPRLO = GT_MAIN-KPRLO - '0.01'.
            LV_KPRLO = LV_KPRLO + '0.01'.
          ENDIF.
        ENDIF.

        MODIFY GT_MAIN.

        IF LV_UPRLO IS INITIAL AND LV_KPRLO IS INITIAL.
          EXIT.
        ENDIF.
      ENDLOOP.

      CHECK LV_UPRLO IS NOT INITIAL OR
            LV_KPRLO IS NOT INITIAL.

      SORT GT_MAIN BY CONNO NFKEY UPLRM DESCENDING.

*___6. 당월 빌링잔량이 존재하는 데이터에 잔액 배부
      LOOP AT GT_MAIN WHERE CONNO = GT_SOSUM-CONNO
                        AND NFKEY = GT_SOSUM-NFKEY
                        AND NBVGW IS NOT INITIAL.
        IF LV_UPRLO IS NOT INITIAL.
          IF LV_UPRLO > 0.
            GT_MAIN-UPLRM = GT_MAIN-UPLRM + '0.01'.
            LV_UPRLO = LV_UPRLO - '0.01'.
          ELSE.
            GT_MAIN-UPLRM = GT_MAIN-UPLRM - '0.01'.
            LV_UPRLO = LV_UPRLO + '0.01'.
          ENDIF.
        ENDIF.

        IF LV_KPRLO IS NOT INITIAL.
          IF LV_KPRLO > 0.
            GT_MAIN-KPLRM = GT_MAIN-KPLRM + '0.01'.
            LV_KPRLO = LV_KPRLO - '0.01'.
          ELSE.
            GT_MAIN-KPLRM = GT_MAIN-KPLRM - '0.01'.
            LV_KPRLO = LV_KPRLO + '0.01'.
          ENDIF.
        ENDIF.

        MODIFY GT_MAIN.

        IF LV_UPRLO IS INITIAL AND LV_KPRLO IS INITIAL.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " DISTRIBUTION_PROFIT_LOSS_3
*&---------------------------------------------------------------------*
*&      Form  SAVE_DISTRIBUTION_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_DISTRIBUTION_DATA .
  DATA: LV_CONNO     LIKE ZNFT1053-CONNO,
        LV_TEXT(200).

*___기 생성된 손익배부 데이터 존재여부 점검
  SELECT SINGLE CONNO
    INTO LV_CONNO
    FROM ZNFT1053
   WHERE ENDMM = P_ENDMM.

  IF SY-SUBRC = 0.
    LV_TEXT = '기 생성된 손익배부 데이터가 존재합니다.'.
  ENDIF.

  CONCATENATE LV_TEXT '손익배부 데이터를 저장하시겠습니까?'
         INTO LV_TEXT SEPARATED BY SPACE.

  PERFORM POPUP_TO_CONFIRM USING '저장'
                                 LV_TEXT
                                 '1'
                                 GV_ANSWER.
  IF GV_ANSWER = '1'.
*___기 생성된 데이터 삭제
    DELETE FROM ZNFT1053 WHERE ENDMM = P_ENDMM.

    MODIFY ZNFT1053 FROM TABLE GT_MAIN.
    IF SY-SUBRC = 0.
      COMMIT WORK.

      MESSAGE S003 WITH '손익배부 데이터가 저장되었습니다.'.
    ELSE.
      ROLLBACK WORK.

      MESSAGE S003 WITH '손익배부 데이터 저장 시 에러발생!'.
    ENDIF.
  ELSE.
    MESSAGE S003 WITH '작업이 취소되었습니다.'.
  ENDIF.

ENDFORM.                    " SAVE_DISTRIBUTION_DATA
*&---------------------------------------------------------------------*
*&      Form  CONVERT_NF_UNIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CONVERT_NF_UNIT  USING    PV_VRKME
                               PV_MEINS
                               PV_EMENG
                               PV_MENGE.

  CLEAR : PV_MENGE.

  CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
    EXPORTING
      INPUT                = PV_EMENG
      ROUND_SIGN           = 'X'
      UNIT_IN              = PV_VRKME
      UNIT_OUT             = PV_MEINS
    IMPORTING
      OUTPUT               = PV_MENGE
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

ENDFORM.                    " CONVERT_NF_UNIT
