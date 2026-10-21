*&---------------------------------------------------------------------*
*& Include          ZGTSDR2020F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

*-선택조건 DEFAULT
  PERFORM SET_DEFAULT.

*-납품보류 LIST BOX
*  PERFORM SET_LIFSK_LISTBOX.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN .
*-권한점검
  PERFORM CHECK_AUTHORITY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .
  LOOP AT SCREEN.
    "영업조직/유통경로
    IF SCREEN-GROUP1 EQ 'ZM1'.
      SCREEN-INPUT = 0.
    ENDIF.
    "납품보류
*    IF SCREEN-GROUP1 EQ 'ZM2'.
*      SCREEN-INPUT = 0.
*    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EXCLUDING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EXCLUDING_0100 .
  CLEAR:GT_EXCLU1[].

  IF GV_DISP EQ GC_X.
    APPEND VALUE #( FCODE = 'ZF100' ) TO GT_EXCLU1.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DEFAULT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DEFAULT .
  DATA: LV_DATE TYPE SY-DATUM.

*-영업조직
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_VKORG_6000 )
      TO S_VKORG.
*-유통경로
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_VTWEG_10 )
      TO S_VTWEG.

*-납품생성일
  LV_DATE = SY-DATLO.
  APPEND VALUE #( SIGN = 'I' OPTION = 'BT'
                  LOW = LV_DATE - 365
                  HIGH = LV_DATE )
      TO S_ERDAT.

*-기주년월
  P_SPMON = LV_DATE(6).

*-납품유형
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_LFART_ZLF3 )
      TO S_LFART.

*-저장위치
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_LGORT_3499 )
      TO S_LGORT.

*-자재이동상태
*  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_A )
*      TO S_WBSTK.

*-청구
*  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_A )
*      TO S_FKSTK.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LIFSK_LISTBOX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LIFSK_LISTBOX .
  DATA: LV_NAME  TYPE VRM_ID,
        LT_LIST  TYPE VRM_VALUES,
        LS_VALUE LIKE LINE OF LT_LIST.

  LV_NAME = 'P_LIFSK'.

  SELECT A~LIFSP,B~VTEXT
    FROM TVLS AS A INNER JOIN TVLST AS B
                   ON A~LIFSP = B~LIFSP AND
                      B~SPRAS = @SY-LANGU
    INTO TABLE @DATA(LT_TVLS).

  LS_VALUE-KEY  = ''.
  LS_VALUE-TEXT = ''.
  APPEND LS_VALUE TO LT_LIST.

  LOOP AT LT_TVLS INTO DATA(LS_TVLS).
    CLEAR LS_VALUE.
    LS_VALUE-KEY  = LS_TVLS-LIFSP.
    LS_VALUE-TEXT = LS_TVLS-VTEXT.
    APPEND LS_VALUE TO LT_LIST.
  ENDLOOP.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = LV_NAME
      VALUES = LT_LIST.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_AUTHORITY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_AUTHORITY .
  DATA: LV_SUBRC TYPE SY-SUBRC.

*-영업그룹
  SELECT VKGRP
    FROM TVKGR
   WHERE VKGRP IN @S_VKGRP
    INTO TABLE @DATA(LT_VKGRP).
  IF SY-SUBRC NE 0.
    MESSAGE S000 WITH TEXT-M01 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.

  LOOP AT LT_VKGRP INTO DATA(LS_VKGRP).
    CLEAR LV_SUBRC.
    PERFORM AUTHORIZATION_CHECK_EXEC    USING GC_7 LS_VKGRP-VKGRP
                                     CHANGING LV_SUBRC.
    IF LV_SUBRC NE 0.
      MESSAGE E203 WITH LS_VKGRP-VKGRP.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORIZATION_CHECK_EXEC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_7
*&      --> LS_VKGRP_VKGRP
*&      <-- LV_SUBRC
*&---------------------------------------------------------------------*
FORM AUTHORIZATION_CHECK_EXEC  USING    PV_STEP
                                        PV_VALUE
                               CHANGING PV_SUBRC.
  DATA:LV_VKORG TYPE VKORG,
       LV_VTWEG TYPE VTWEG,
       LV_SPART TYPE SPART,
       LV_VKGRP TYPE VKGRP.
  DATA:LV_TYPE(1).

  LV_TYPE = PV_STEP.

  CASE LV_TYPE.
    WHEN GC_1."영업조직
      LV_VKORG = PV_VALUE.
      CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
        EXPORTING
          I_VKORG = LV_VKORG
          I_TYPE  = LV_TYPE
        IMPORTING
          E_SUBRC = PV_SUBRC.

    WHEN GC_2."유통채널
      LV_VTWEG = PV_VALUE.
      CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
        EXPORTING
          I_VTWEG = LV_VTWEG
          I_TYPE  = LV_TYPE
        IMPORTING
          E_SUBRC = PV_SUBRC.

    WHEN GC_3."제품군
      LV_SPART = PV_VALUE.
      CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
        EXPORTING
          I_SPART = LV_SPART
          I_TYPE  = LV_TYPE
        IMPORTING
          E_SUBRC = PV_SUBRC.

    WHEN GC_7."영업그룹
      LV_VKGRP = PV_VALUE.
      CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
        EXPORTING
          I_VKGRP = LV_VKGRP
          I_TYPE  = LV_TYPE
        IMPORTING
          E_SUBRC = PV_SUBRC.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAIN .
*-01. INIT OBJECTS
  PERFORM INIT_OBJECTS.

*-02. CHECK INPUT
  PERFORM CHECK_INPUT_VALUE.

*-03. SET VALUES
  PERFORM SET_VALUES.

*-04. GET DATA
  PERFORM GET_DATA.

*-05. MAKE LIST
  PERFORM MAKE_LIST.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_KUNNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> S_KUNNR_LOW
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_KUNNR  USING  PV_FVAL PV_FNAME.
  DATA: LV_MC_OBJ LIKE HELP_INFO-MCOBJ.
  DATA: LT_RETURN_VALUES LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.
  DATA: LV_DISPLAY TYPE C.
  DATA: LV_VKORG TYPE VBAK-VKORG.

*   Matchcodeobjekt aufrufen
  LV_MC_OBJ = 'SD_DEBI'.
  LV_VKORG  = VALUE #( S_VKORG[ 1 ]-LOW OPTIONAL ).
  SET PARAMETER ID 'VKO' FIELD LV_VKORG.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      TABNAME           = SPACE
      FIELDNAME         = SPACE
      SEARCHHELP        = LV_MC_OBJ
*     SHLPPARAM         = ' '
*     DYNPPROG          = ' '
*     DYNPNR            = ' '
      DYNPROFIELD       = 'X'
*     STEPL             = 0
      VALUE             = PV_FNAME
*     MULTIPLE_CHOICE   = ' '
      DISPLAY           = LV_DISPLAY
*     CALLBACK_PROGRAM  = ' '
*     CALLBACK_FORM     = ' '
    TABLES
      RETURN_TAB        = LT_RETURN_VALUES
    EXCEPTIONS
      FIELD_NOT_FOUND   = 1
      NO_HELP_FOR_FIELD = 2
      INCONSISTENT_HELP = 3
      NO_VALUES_FOUND   = 4
      OTHERS            = 5.
  IF SY-SUBRC = 0.
    PV_FVAL = VALUE #( LT_RETURN_VALUES[ 1 ]-FIELDVAL OPTIONAL ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_SPART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_SPART  USING   PV_FNAME.

  SELECT VKORG,VTWEG,SPART
    FROM TVTA
   WHERE VKORG IN @S_VKORG
     AND VTWEG IN @S_VTWEG
    INTO TABLE @DATA(LT_VALUE).

  SORT LT_VALUE BY VKORG VTWEG SPART.

  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'SPART'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKBUR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VKBUR  USING    PV_FNAME.

  SELECT DISTINCT A~VKBUR,B~BEZEI
    FROM TVKBZ AS A INNER JOIN TVKBT AS B
                    ON A~VKBUR = B~VKBUR

   WHERE A~VKORG IN @S_VKORG
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY VKBUR.
  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VKBUR'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VKGRP  USING   PV_FNAME.

  SELECT DISTINCT A~VKBUR,B~BEZEI,A~VKGRP,C~BEZEI AS VKGRP_TXT
    FROM TVKBZ AS H INNER JOIN TVBVK AS A
                    ON H~VKBUR = A~VKBUR
                    INNER JOIN TVKBT AS B
                    ON A~VKBUR = B~VKBUR AND
                       B~SPRAS = @SY-LANGU
                    INNER JOIN TVGRT AS C
                    ON A~VKGRP = C~VKGRP AND
                       C~SPRAS = @SY-LANGU
   WHERE H~VKORG IN @S_VKORG
     AND H~VKBUR IN @S_VKBUR
    INTO TABLE @DATA(LT_VALUE).

  SORT LT_VALUE BY VKBUR.

  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VKGRP'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VSTEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VSTEL  USING   PV_FNAME.

  SELECT B~VSTEL,C~VTEXT
    FROM TVKWZ AS A INNER JOIN TVSWZ AS B
                    ON A~WERKS = B~WERKS
                    INNER JOIN TVSTT AS C
                    ON B~VSTEL = C~VSTEL AND
                       C~SPRAS = @SY-LANGU
   WHERE A~VKORG IN @S_VKORG
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY VSTEL.
  DELETE ADJACENT DUPLICATES FROM LT_VALUE COMPARING VSTEL.

  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VSTEL'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_LGORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_LGORT  USING   PV_FNAME.

  SELECT A~WERKS,C~NAME1,B~LGORT,B~LGOBE
    FROM TVKWZ AS A INNER JOIN T001L AS B
                    ON A~WERKS = B~WERKS
                    INNER JOIN T001W AS C
                    ON A~WERKS = C~WERKS
   WHERE A~VKORG IN @S_VKORG
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY WERKS LGORT.
  DELETE ADJACENT DUPLICATES FROM LT_VALUE COMPARING WERKS LGORT.

  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'LGORT'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_OBJECTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_OBJECTS .
  CLEAR:
         GV_TITLE,GV_TITLE2,GV_EDIT,GV_DISP,
         ZGTSDS1100.

  REFRESH: GT_LIST,GT_SPLIT,GR_FKDAT,
           GT_ITEM.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE .
*-날짜
  IF S_ERDAT[] IS INITIAL AND
     S_WADATS[] IS INITIAL.
    MESSAGE S000 WITH TEXT-M02 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VALUES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_VALUES .
  DATA: LV_TEXT(20).

  WRITE:P_SPMON TO LV_TEXT USING EDIT MASK '____.__'.
  CONDENSE LV_TEXT.


  GV_EDIT = GC_X.

*-청구일
  PERFORM SET_FKDAT.

  CASE SY-TCODE.
    WHEN 'ZGTSDR2023'.  "조회
      GV_DISP = GC_X.

      "TITLE
      GV_TITLE = GV_TITLE2 = |{ TEXT-007 }({ LV_TEXT })|.

    WHEN 'ZGTSDR2021'.  "적송매출처리
      CLEAR GV_DISP.

      "TITLE
      GV_TITLE = GV_TITLE2 = |{ TEXT-001 }({ LV_TEXT })|."TEXT-001.

    WHEN OTHERS.
      GV_DISP = GC_X.

      "TITLE
      GV_TITLE = GV_TITLE2 = |{ TEXT-007 }({ LV_TEXT })|.

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
  DATA:LV_CNT TYPE I.

  SELECT A~VBELN AS VBELN_VL,
         A~LFART,A~KUNAG,A~KUNNR,A~ERDAT,A~WADAT_IST,A~WAERK,
         A~VSTEL,A~VKORG,
         A~WBSTK,A~FKSTK,A~LIFSK,A~KOSTK,

         B~POSNR AS POSNR_VL,B~LFIMG,B~VRKME,
         B~VTWEG,B~VKBUR,B~VKGRP,B~CHARG,B~UECHA,

         C~VBELN AS VBELN_VA,
         C~AUART,C~BSTNK,C~SPART,

         E~NETPR

    FROM LIKP AS A INNER JOIN LIPS AS B
                   ON A~VBELN = B~VBELN
                   INNER JOIN VBAP AS E
                   ON B~VGBEL = E~VBELN AND
                      B~VGPOS = E~POSNR
                   INNER JOIN VBAK AS C
                   ON B~VGBEL = C~VBELN
                   INNER JOIN VBPA AS D
                   ON C~VBELN = D~VBELN  AND
                      D~POSNR = '000000' AND
                      D~PARVW = @GC_PARVW_VE

   WHERE A~VKORG IN @S_VKORG
     AND A~VBTYP EQ @IF_SD_DOC_CATEGORY=>DELIVERY
     AND A~LFART IN @S_LFART
     AND A~KUNAG IN @S_KUNAG
     AND A~KUNNR IN @S_KUNNR
     AND A~VSTEL IN @S_VSTEL
     AND A~LIFSK NE @GC_LIFSK_G4
     AND A~ERDAT IN @S_ERDAT
     AND A~WADAT_IST IN @S_WADATS
     AND B~VTWEG IN @S_VTWEG
     AND B~VKBUR IN @S_VKBUR
     AND B~VKGRP IN @S_VKGRP
     AND B~VGBEL IN @S_VBELN
     AND B~LGORT IN @S_LGORT
     AND B~MATNR IN @S_MATNR
     AND C~BSTNK IN @S_BSTNK
     AND C~SPART IN @S_SPART
     AND D~LIFNR IN @S_PERNR
    INTO TABLE @DATA(LT_BASE).


  CHECK LT_BASE[] IS NOT INITIAL.

  "청구문서
  DATA(LT_TEMP10) = LT_BASE[].
  SORT LT_TEMP10 BY VBELN_VL POSNR_VL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP10 COMPARING VBELN_VL POSNR_VL.
  IF LT_TEMP10[] IS NOT INITIAL.
    SELECT A~VGBEL,A~VGPOS,
           B~FKDAT,B~NETWR AS NETWR_VF,B~WAERK AS WAERK_VF
      FROM VBRP AS A INNER JOIN VBRK AS B
                     ON A~VBELN = B~VBELN AND
                        B~FKSTO = @SPACE  AND
                        B~SFAKN = @SPACE
       FOR ALL ENTRIES IN @LT_TEMP10
     WHERE A~VGBEL EQ @LT_TEMP10-VBELN_VL
       AND A~VGPOS EQ @LT_TEMP10-POSNR_VL
      INTO TABLE @DATA(LT_VBRK).
    SORT LT_VBRK BY VGBEL.

  ENDIF.

  SORT LT_BASE BY VBELN_VL UECHA POSNR_VL.

*-리스트 구성=> 적송금액 계산(적송잔액)
  LOOP AT LT_BASE INTO DATA(LS_BASE) GROUP BY ( VBELN_VL = LS_BASE-VBELN_VL )
                                     ASCENDING ASSIGNING FIELD-SYMBOL(<FS_MAIN>).

    CLEAR GS_LIST.CLEAR:LV_CNT.
    LOOP AT GROUP <FS_MAIN> ASSIGNING FIELD-SYMBOL(<FS_LINE>).
      LV_CNT = LV_CNT + 1.
      IF LV_CNT = 1.
        MOVE-CORRESPONDING <FS_LINE> TO GS_LIST.

        "청구문서 정보 => 매출일/매출금액
        DATA(LS_VBRK) = VALUE #( LT_VBRK[ VGBEL = GS_LIST-VBELN_VL ] OPTIONAL ).
        IF LS_VBRK IS NOT INITIAL.
          GS_LIST-FKDAT    = LS_VBRK-FKDAT.
          GS_LIST-NETWR_VF = LS_VBRK-NETWR_VF.
          GS_LIST-WAERK_VF = LS_VBRK-WAERK_VF.
        ENDIF.
      ENDIF.

      "적송금액(적송잔액)
      GS_LIST-NETWR_JSJA = GS_LIST-NETWR_JSJA + ( <FS_LINE>-LFIMG * <FS_LINE>-NETPR ).

      CLEAR:LS_VBRK.
    ENDLOOP.
    APPEND GS_LIST TO GT_LIST.
  ENDLOOP.

*-원 DO 청구완료 상태면 => 적송잔액 = 0.
  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>) WHERE FKSTK EQ GC_C.
    <FS_LIST>-NETWR_JSJA = 0.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_LIST .

  CLEAR: GT_SPLIT_DO[].
  CHECK GT_LIST[] IS NOT INITIAL.

*-01.SPLIT DO
  DATA(LT_TEMP) = GT_LIST[].
  SORT LT_TEMP BY VBELN_VL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VBELN_VL.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT DISTINCT A~VBELN, A~VBELN_NEW
      FROM LEDSPD_FLOW AS A INNER JOIN LIKP AS B
                            ON A~VBELN_NEW = B~VBELN
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE A~VBELN EQ @LT_TEMP-VBELN_VL
       AND A~UPDKZ EQ @GC_I
       AND B~LIFSK EQ @GC_LIFSK_G4
      INTO CORRESPONDING FIELDS OF TABLE @GT_SPLIT_DO.
  ENDIF.

*-02. TEXT
  "판매처/납품처
  CLEAR LT_TEMP[].
  LT_TEMP[] = GT_LIST[].
  SORT LT_TEMP BY KUNNR.
  DELETE LT_TEMP WHERE KUNNR IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING KUNNR.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT A~KUNNR,B~NAME1
      FROM KNA1 AS A INNER JOIN ADRC AS B
                     ON A~ADRNR = B~ADDRNUMBER
      FOR ALL ENTRIES IN @LT_TEMP
     WHERE A~KUNNR     EQ @LT_TEMP-KUNNR
       AND B~DATE_FROM LE @SY-DATLO
       AND B~DATE_TO   GE @SY-DATLO
      INTO TABLE @DATA(LT_KNA1).
  ENDIF.
  CLEAR LT_TEMP[].
  LT_TEMP[] = GT_LIST[].
  SORT LT_TEMP BY KUNAG.
  DELETE LT_TEMP WHERE KUNAG IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING KUNAG.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT A~KUNNR,B~NAME1
      FROM KNA1 AS A INNER JOIN ADRC AS B
                     ON A~ADRNR = B~ADDRNUMBER
      FOR ALL ENTRIES IN @LT_TEMP
     WHERE A~KUNNR     EQ @LT_TEMP-KUNAG
       AND B~DATE_FROM LE @SY-DATLO
       AND B~DATE_TO   GE @SY-DATLO
      APPENDING TABLE @LT_KNA1.

  ENDIF.
  SORT LT_KNA1 BY KUNNR.

  "출하지점
  CLEAR LT_TEMP[].
  LT_TEMP[] = GT_LIST[].
  SORT LT_TEMP BY VSTEL.
  DELETE LT_TEMP WHERE VSTEL IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VSTEL.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT VSTEL,VTEXT
      FROM TVSTT
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE VSTEL EQ @LT_TEMP-VSTEL
       AND SPRAS EQ @SY-LANGU
      INTO TABLE @DATA(LT_TVSTT).
    SORT LT_TVSTT BY VSTEL.
  ENDIF.

  "영업팀
  CLEAR LT_TEMP[].
  LT_TEMP[] = GT_LIST[].
  SORT LT_TEMP BY VKBUR.
  DELETE LT_TEMP WHERE VKBUR IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VKBUR.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT VKBUR,BEZEI
      FROM TVKBT
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE VKBUR EQ @LT_TEMP-VKBUR
       AND SPRAS EQ @SY-LANGU
      INTO TABLE @DATA(LT_TVKBT).
    SORT LT_TVKBT BY VKBUR.
  ENDIF.

  "영업그룹
  CLEAR LT_TEMP[].
  LT_TEMP[] = GT_LIST[].
  SORT LT_TEMP BY VKGRP.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VKGRP.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT VKGRP,BEZEI
      FROM TVGRT
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE VKGRP EQ @LT_TEMP-VKGRP
       AND SPRAS EQ @SY-LANGU
      INTO TABLE @DATA(LT_TVGRT).
    SORT LT_TVGRT BY VKGRP.
  ENDIF.


*-03. LIST 구성
  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FS_LIST>).

    "DO SPLIT
    IF LINE_EXISTS( GT_SPLIT_DO[ VBELN = <FS_LIST>-VBELN_VL ] ).
      <FS_LIST>-SPLIT_DO = GC_X.

      <FS_LIST>-ZDOSPLIT = GC_Y.
    ENDIF.

    "기준월
    <FS_LIST>-SPMON = P_SPMON.

    "납품처 명
    IF <FS_LIST>-KUNNR IS NOT INITIAL.
      <FS_LIST>-KUNNR_TX = VALUE #( LT_KNA1[ KUNNR = <FS_LIST>-KUNNR ]-NAME1 OPTIONAL ).
    ENDIF.

    "판매처 명
    IF <FS_LIST>-KUNAG IS NOT INITIAL.
      <FS_LIST>-KUNAG_TX = VALUE #( LT_KNA1[ KUNNR = <FS_LIST>-KUNAG ]-NAME1 OPTIONAL ).
    ENDIF.
    "출하지점
    IF <FS_LIST>-VSTEL IS NOT INITIAL.
      <FS_LIST>-VSTEL_TX = VALUE #( LT_TVSTT[ VSTEL = <FS_LIST>-VSTEL ]-VTEXT OPTIONAL ).
    ENDIF.
    "영업팀
    IF <FS_LIST>-VKBUR IS NOT INITIAL.
      <FS_LIST>-VKBUR_TX = VALUE #( LT_TVKBT[ VKBUR = <FS_LIST>-VKBUR ]-BEZEI OPTIONAL ).
    ENDIF.
    "영업그룹
    IF <FS_LIST>-VKGRP IS NOT INITIAL.
      <FS_LIST>-VKGRP_TX = VALUE #( LT_TVGRT[ VKGRP = <FS_LIST>-VKGRP ]-BEZEI OPTIONAL ).
    ENDIF.

    "FI 마감체크
    PERFORM CHECK_FI_CLOSE CHANGING <FS_LIST>.


    "LED
    PERFORM SET_LED CHANGING <FS_LIST>.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_HEAD>
*&---------------------------------------------------------------------*
FORM SET_LED  CHANGING PS_LIST LIKE GS_LIST.

  "PICKING :
  IF PS_LIST-KOSTK EQ GC_C.
    PS_LIST-ST_PICK = ICON_LED_GREEN.
  ELSE.
    PS_LIST-ST_PICK = ICON_LED_YELLOW.
  ENDIF.

  "출고 :
  IF PS_LIST-WBSTK EQ GC_C.
    PS_LIST-ST_PGI = ICON_LED_GREEN.
  ELSE.
    PS_LIST-ST_PGI = ICON_LED_YELLOW.
  ENDIF.

  "매출 :
  IF PS_LIST-FKSTK EQ GC_C.
    PS_LIST-ST_BILL = ICON_LED_GREEN.
    PS_LIST-ST_FINSH = ICON_LED_GREEN.
  ELSE.
    PS_LIST-ST_BILL = ICON_LED_YELLOW.
    PS_LIST-ST_FINSH = ICON_LED_YELLOW.
  ENDIF.

  "전체상태 : 적송잔액<= 0 => GREEN
*  IF PS_HEAD-NETWR_JSJA <= 0.
*    PS_HEAD-ST_ALL = ICON_LED_GREEN.
*  ELSE.
*    PS_HEAD-ST_ALL = ICON_LED_YELLOW.
*  ENDIF.
*
*  "완료 : 전체상태 GREEN => GREEN
*  IF PS_HEAD-ST_ALL = ICON_LED_GREEN.
*    PS_HEAD-ST_FINSH = ICON_LED_GREEN.
*  ELSE.
*    PS_HEAD-ST_FINSH = ICON_LED_YELLOW.
*  ENDIF.
*
*  "납품분할 : 전체상태 GREEN & DO SPLIT => GREEN
*  IF PS_HEAD-ST_ALL = ICON_LED_GREEN AND
*     PS_HEAD-SPLIT_DO EQ GC_X.
*    PS_HEAD-ST_SPLIT = ICON_LED_GREEN.
*  ELSE.
*    PS_HEAD-ST_SPLIT = ICON_LED_YELLOW.
*  ENDIF.
*
*  "PICKING : 전체상태 GREEN => GREEN
*  IF PS_HEAD-ST_ALL = ICON_LED_GREEN.
*    PS_HEAD-ST_PICK = ICON_LED_GREEN.
*  ELSE.
*    PS_HEAD-ST_PICK = ICON_LED_YELLOW.
*  ENDIF.
*
*  "출고 : 전체상태 GREEN => GREEN
*  IF PS_HEAD-ST_ALL = ICON_LED_GREEN.
*    PS_HEAD-ST_PGI = ICON_LED_GREEN.
*  ELSE.
*    PS_HEAD-ST_PGI = ICON_LED_YELLOW.
*  ENDIF.
*
*  "매출 : 전체상태 GREEN => GREEN
*  IF PS_HEAD-ST_ALL = ICON_LED_GREEN.
*    PS_HEAD-ST_BILL = ICON_LED_GREEN.
*  ELSE.
*    PS_HEAD-ST_BILL = ICON_LED_YELLOW.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY .
  IF GT_LIST[] IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE S010.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITEM_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_LIST
*&---------------------------------------------------------------------*
FORM SET_ITEM_LIST  USING    PS_LIST LIKE GS_LIST.

*-ITEM 헤더
  ZGTSDS1100-VBELN_VL    = PS_LIST-VBELN_VL.
  ZGTSDS1100-VBELN_VA    = PS_LIST-VBELN_VA.
*  ZGTSDS1100-VBELN_VLSP  = PS_LIST-VBELN_VLSP.
  ZGTSDS1100-WAERK       = PS_LIST-WAERK.
  "선택조건 기준월의 마지막 일자
  ZGTSDS1100-FKDAT       = VALUE DATUM( GR_FKDAT[ 1 ]-HIGH OPTIONAL ).

*  ZGTSDS1100-NETWR_BL_H
  ZGTSDS1100-SPMON       = PS_LIST-SPMON.

  ZGTSDS1100-ZNEW        = GC_X.

  "상태
  PERFORM SET_STATUS_ITEM USING SPACE.
  PERFORM SET_STATUS_ITEM_LED.

*-DO
  SELECT A~VBELN AS VBELN_VL,A~POSNR AS POSNR_VL,A~UECHA,
         A~MATNR,A~CHARG,A~LFIMG,A~VRKME,
         A~VGBEL,A~VGPOS,
         B~WAERK,
         C~NETPR
    FROM LIPS AS A INNER JOIN LIKP AS B
                   ON A~VBELN = B~VBELN
                   INNER JOIN VBAP AS C
                   ON A~VGBEL = C~VBELN AND
                      A~VGPOS = C~POSNR
   WHERE A~VBELN EQ @PS_LIST-VBELN_VL
     AND A~VGBEL EQ @PS_LIST-VBELN_VA
     AND A~MATNR IN @S_MATNR
     AND A~LGORT IN @S_LGORT
    INTO TABLE @DATA(LT_LIPS).

  CHECK LT_LIPS[] IS NOT INITIAL.
  SORT LT_LIPS BY POSNR_VL.
  DATA(LT_TEMP) = LT_LIPS[].
  DELETE LT_TEMP WHERE UECHA NE '000000'.

*-ITEM 리스트 구성.
  LOOP AT LT_TEMP INTO DATA(LS_TEMP).
    CLEAR GS_ITEM.
    LOOP AT LT_LIPS INTO DATA(LS_LIPS) WHERE VBELN_VL = LS_TEMP-VBELN_VL
                                         AND UECHA    = LS_TEMP-POSNR_VL.
      CLEAR GS_ITEM.
      GS_ITEM-VBELN_VL = LS_LIPS-VBELN_VL.
      GS_ITEM-UECHA    = LS_LIPS-UECHA.
      GS_ITEM-POSNR_VL = LS_LIPS-POSNR_VL.
      GS_ITEM-MATNR    = LS_LIPS-MATNR.
      GS_ITEM-CHARG    = LS_LIPS-CHARG.
      GS_ITEM-VRKME    = LS_LIPS-VRKME.
      GS_ITEM-LFIMG    = LS_LIPS-LFIMG.
      GS_ITEM-NETPR    = LS_LIPS-NETPR.
      GS_ITEM-VGBEL    = LS_LIPS-VGBEL.
      GS_ITEM-VGPOS    = LS_LIPS-VGPOS.
      GS_ITEM-WAERK    = LS_LIPS-WAERK.

      "조장
      IF GS_ITEM-VGBEL IS NOT INITIAL AND
         GS_ITEM-VGPOS IS NOT INITIAL.
        PERFORM SET_CHARACTERISTIC_VALUES    USING GS_ITEM-VGBEL GS_ITEM-VGPOS
                                                   'SAP_LENGTH_VKRME'
                                          CHANGING GS_ITEM-LENGTH_JS.
      ENDIF.

      "조장수/수량/금액
      PERFORM SET_QTY_AMT_VALUES      USING GC_X
                                   CHANGING GS_ITEM.

*      PERFORM SET_ATTRIBUTES_LINE_ITEM CHANGING GS_ITEM.
      APPEND GS_ITEM TO GT_ITEM.
    ENDLOOP.
    IF SY-SUBRC NE 0.
      CLEAR GS_ITEM.
      GS_ITEM-VBELN_VL = LS_LIPS-VBELN_VL.
      GS_ITEM-UECHA    = LS_LIPS-UECHA.
      GS_ITEM-POSNR_VL = LS_LIPS-POSNR_VL.
      GS_ITEM-MATNR    = LS_LIPS-MATNR.
      GS_ITEM-CHARG    = LS_LIPS-CHARG.
      GS_ITEM-VRKME    = LS_LIPS-VRKME.
      GS_ITEM-LFIMG    = LS_LIPS-LFIMG.
      GS_ITEM-NETPR    = LS_LIPS-NETPR.
      GS_ITEM-VGBEL    = LS_LIPS-VGBEL.
      GS_ITEM-VGPOS    = LS_LIPS-VGPOS.
      GS_ITEM-WAERK    = LS_LIPS-WAERK.

      "조장
      IF GS_ITEM-VGBEL IS NOT INITIAL AND
         GS_ITEM-VGPOS IS NOT INITIAL.
        PERFORM SET_CHARACTERISTIC_VALUES    USING GS_ITEM-VGBEL GS_ITEM-VGPOS
                                                   'SAP_LENGTH_VKRME'
                                          CHANGING GS_ITEM-LENGTH_JS.
      ENDIF.

      "조장수/수량/금액
      PERFORM SET_QTY_AMT_VALUES    USING GC_X
                                 CHANGING GS_ITEM.

*      PERFORM SET_ATTRIBUTES_LINE_ITEM CHANGING GS_ITEM.
      APPEND GS_ITEM TO GT_ITEM.
    ENDIF.
  ENDLOOP.

*-최초수량 = 0 인건 제외
  DELETE GT_ITEM WHERE LFIMG <= 0.

*-실매출 금액 : 매출금액 SUM - 유보금액
  PERFORM SET_REAL_NETWR USING PS_LIST-VBELN_VL.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHARACTERISTIC_VALUES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_ITEM_VGBEL
*&      --> GS_ITEM_VGPOS
*&      --> P_
*&      <-- GS_ITEM_LENGTH_JS
*&---------------------------------------------------------------------*
FORM SET_CHARACTERISTIC_VALUES  USING    PV_VGBEL
                                         PV_VGPOS
                                         PV_ATNAM
                                CHANGING PV_LENGTH.

  DATA: LT_CHAR  LIKE CONF_OUT OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC_TABLE2'
    EXPORTING
      I_VBELN                      = PV_VGBEL
      I_POSNR                      = PV_VGPOS
    TABLES
      ET_CHAR                      = LT_CHAR
    EXCEPTIONS
      CHARACTERISTIC_NOT_FOUND     = 1
      INSTANCE_NOT_FOUND           = 2
      INSTANCE_IS_A_CLASSIFICATION = 3
      INVALID_DATA                 = 4
      OTHERS                       = 5.

  CHECK LT_CHAR[] IS NOT INITIAL.

  PV_LENGTH = CONV LFIMG( VALUE #( LT_CHAR[ ATNAM = PV_ATNAM ]-ATWRT OPTIONAL ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_QTY_AMT_VALUES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_ITEM
*&---------------------------------------------------------------------*
FORM SET_QTY_AMT_VALUES      USING PV_STEP
                          CHANGING PS_ITEM LIKE GT_ITEM.

*-최초 조장수 : 최초수량 / 조장
  IF PS_ITEM-LENGTH_JS NE 0.
    PS_ITEM-FACTOR_I = PS_ITEM-LFIMG / PS_ITEM-LENGTH_JS.
  ENDIF.

*-매출조장수
  IF PV_STEP EQ GC_X. "최초 수행(DEFAULT 지정)
    PS_ITEM-FACTOR_B = PS_ITEM-FACTOR_I.
  ENDIF.

*-매출수량 : 매출조장수 * 조장
  PS_ITEM-LFIMG_B = PS_ITEM-FACTOR_B * PS_ITEM-LENGTH_JS.

*-매출금액 : 매출수량 * 단가
  PS_ITEM-NETWR_BL_I = PS_ITEM-LFIMG_B * PS_ITEM-NETPR.

*-적송조장수 : 최초조장수 - 매출조장수
  PS_ITEM-FACTOR_JS = PS_ITEM-FACTOR_I - PS_ITEM-FACTOR_B.

*-적송잔량 : 적송조장수 * 조장
  PS_ITEM-LFIMG_JS = PS_ITEM-FACTOR_JS * PS_ITEM-LENGTH_JS.

*-잔량금액 : 적송잔량 * 단가
  PS_ITEM-NETWR_JS_I = PS_ITEM-LFIMG_JS * PS_ITEM-NETPR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_REAL_NETWR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_REAL_NETWR USING PV_VBELN_VL.
  DATA: LV_NETWR_BLH_SUM TYPE NETWR,
        LV_NETWR_BLH_UBO TYPE NETWR.

  "매출금액 SUM
  ZGTSDS1100-NETWR_BL_H = REDUCE NETWR( INIT LV_AMT TYPE NETWR
                                         FOR LS_LINE IN GT_ITEM
                                          WHERE ( VBELN_VL = PV_VBELN_VL )
                                        NEXT LV_AMT = LV_AMT + LS_LINE-NETWR_BL_I ).

  "매출금액 SUM - 유보금액
  ZGTSDS1100-NETWR_BL_H = ZGTSDS1100-NETWR_BL_H - ZGTSDS1100-NETWR_UBO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_DOUBLE_CLICK_0100_H
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_E_ROW
*&      --> PS_E_COLUMN
*&---------------------------------------------------------------------*
FORM ALV_DOUBLE_CLICK_0100_H  USING PS_E_ROW  TYPE LVC_S_ROW
                                    PS_E_COLUMN TYPE LVC_S_COL.

  READ TABLE GT_LIST INTO DATA(LS_LIST) INDEX PS_E_ROW-INDEX.
  CHECK SY-SUBRC EQ 0.

  CASE PS_E_COLUMN-FIELDNAME.
    WHEN 'VBELN_VA'.
      IF LS_LIST-VBELN_VA IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD LS_LIST-VBELN_VA.
        CALL TRANSACTION 'VA03' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'VBELN_VL'.
      IF LS_LIST-VBELN_VL IS NOT INITIAL.
        SET PARAMETER ID 'VL' FIELD LS_LIST-VBELN_VL.
        CALL TRANSACTION 'VL03N' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      ENDIF.

*    WHEN 'VBELN_VLSP'.
*      IF LS_LIST-VBELN_VLSP IS NOT INITIAL.
*        SET PARAMETER ID 'VL' FIELD LS_LIST-VBELN_VLSP.
*        CALL TRANSACTION 'VL03N' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
*      ENDIF.

    WHEN 'ST_PICK' OR
         'ST_PGI' OR
         'ST_BILL'.
      PERFORM DISPLAY_MESSAGE_0100_H USING PS_E_COLUMN-FIELDNAME
                                           LS_LIST.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_HOTSPOT_CLICK_0100_H
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_E_ROW
*&      --> PS_E_COLUMN
*&---------------------------------------------------------------------*
FORM ALV_HOTSPOT_CLICK_0100_H  USING  PS_E_ROW  TYPE LVC_S_ROW
                                      PS_E_COLUMN TYPE LVC_S_COL.

  READ TABLE GT_LIST INTO DATA(LS_HEAD) INDEX PS_E_ROW-INDEX.
  CHECK SY-SUBRC EQ 0.

  CASE PS_E_COLUMN-FIELDNAME.


*    WHEN 'VBELN_VLSP'.
*      IF LS_HEAD-VBELN_VLSP IS NOT INITIAL.
*        SET PARAMETER ID 'VL' FIELD LS_HEAD-VBELN_VLSP.
*        CALL TRANSACTION 'VL03N' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
*      ENDIF.

    WHEN OTHERS.

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_SPMON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_BFMON
*&---------------------------------------------------------------------*
FORM F4_SPMON  USING  P_FVAL.
  DATA:LV_SUBRC TYPE SY-SUBRC.

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      ACTUAL_MONTH               = SY-DATLO(6)
    IMPORTING
      SELECTED_MONTH             = P_FVAL
      RETURN_CODE                = LV_SUBRC
    EXCEPTIONS
      FACTORY_CALENDAR_NOT_FOUND = 1
      HOLIDAY_CALENDAR_NOT_FOUND = 2
      MONTH_NOT_FOUND            = 3
      OTHERS                     = 4.
  IF SY-SUBRC <> 0.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BILLING_FOR_JS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BILLING_FOR_JS .

  PERFORM CHECK_CHANGED_DATA USING GO_GRID1.

*-01. 선택라인
  IF NOT ( LINE_EXISTS( GT_LIST[ SEL = GC_X ] ) ).
    MESSAGE I004 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

*-02. CHECK
  CLEAR GV_ERROR.
  PERFORM CHECK_DATA_0100_TOP.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

*-03. CALL SCREEN 0200
  PERFORM CALL_SCREEN_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA_0100_TOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_DATA_0100_TOP .

  DATA(LS_LIST) = VALUE #( GT_LIST[ SEL = GC_X ] OPTIONAL ).
  IF LS_LIST IS NOT INITIAL.
    "상태 체크
    CLEAR GS_BAPIRET2.
    PERFORM CHECK_STATUS    USING LS_LIST
                                  GC_A
                         CHANGING GS_BAPIRET2.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_SCREEN_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_SCREEN_0200 .

  CLEAR:ZGTSDS1100,GT_ITEM[].
  CLEAR:GS_LIST.

  GS_LIST = VALUE #( GT_LIST[ SEL = GC_X ] OPTIONAL ).
  CHECK GS_LIST IS NOT INITIAL.

  "ITEM 리스트 구성
  PERFORM SET_ITEM_LIST USING GS_LIST.

*-LOCK OBJECT
  PERFORM SET_LOCK_OBJECT USING GC_O.

  CALL SCREEN 0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LIST
*&      --> GC_A
*&      <-- GS_BAPIRET2
*&---------------------------------------------------------------------*
FORM CHECK_STATUS  USING    PS_LIST LIKE GS_LIST
                            P_STEP
                   CHANGING PS_BAPIRET2 TYPE BAPIRET2.

  DATA:LV_MSG(100).

  SELECT SINGLE *
    FROM LIKP
   WHERE VBELN EQ @PS_LIST-VBELN_VL
    INTO @DATA(LS_LIKP).
  IF SY-SUBRC NE 0.
    GV_ERROR = GC_X.
    MESSAGE I000 WITH TEXT-M33 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  CASE P_STEP.
    WHEN GC_A.  "매출지정시 체크
      IF LS_LIKP-KOSTK EQ GC_C OR
         LS_LIKP-WBSTK EQ GC_C OR
         LS_LIKP-FKSTK EQ GC_C .

        GV_ERROR = GC_X.

        PERFORM GET_STATUS_TEXT    USING LS_LIKP-KOSTK
                                         LS_LIKP-WBSTK
                                         LS_LIKP-FKSTK
                                CHANGING LV_MSG.

        MESSAGE I111 WITH PS_LIST-VBELN_VL LV_MSG DISPLAY LIKE GC_E.
        EXIT.

      ENDIF.


    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STATUS_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LIKP_KOSTK
*&      --> LS_LIKP_WBSTK
*&      --> LS_LIKP_FKSTK
*&      <-- LV_MSG
*&---------------------------------------------------------------------*
FORM GET_STATUS_TEXT  USING    PA_KOSTK
                               PA_WBSTK
                               PA_FKSTK
                      CHANGING PA_MSG.

  IF PA_FKSTK EQ GC_C.
    PA_MSG = TEXT-002.
    EXIT.
  ENDIF.

  IF PA_WBSTK EQ GC_C.
    PA_MSG = TEXT-003.
    EXIT.
  ENDIF.

  IF PA_KOSTK EQ GC_C.
    PA_MSG = TEXT-004.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SPLIT_DO_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LIST
*&---------------------------------------------------------------------*
FORM GET_SPLIT_DO_LIST  USING    PS_LIST LIKE GS_LIST.
  DATA:LV_CNT TYPE I.

  CLEAR: GT_SPLIT[].

  SELECT Z~VBELN AS VBELN_VL,
         A~VBELN AS VBELN_VLSP,
         A~LFART,A~KUNAG,A~KUNNR,  A~ERDAT, "A~WADAT_IST,A~WAERK,
         A~VSTEL,A~VKORG,
         A~WBSTK,A~FKSTK,A~LIFSK,A~KOSTK,

         B~POSNR AS POSNR_VLSP,B~LFIMG,B~VRKME,
         B~VTWEG,B~VKBUR,B~VKGRP,B~CHARG,B~UECHA,

         C~VBELN AS VBELN_VA,
         C~AUART,C~BSTNK,C~SPART
    FROM LEDSPD_FLOW AS Z INNER JOIN LIKP AS A
                          ON Z~VBELN_NEW = A~VBELN
                          INNER JOIN LIPS AS B
                          ON A~VBELN = B~VBELN
                          INNER JOIN VBAP AS D
                          ON B~VGBEL = D~VBELN AND
                             B~VGPOS = D~POSNR
                          INNER JOIN VBAK AS C
                          ON B~VGBEL = C~VBELN
                          INNER JOIN ZGTSDT9130 AS E
                          ON A~VBELN = E~VBELN

   WHERE Z~VBELN EQ @PS_LIST-VBELN_VL
     AND Z~UPDKZ EQ @GC_I
     AND E~SPMON EQ @PS_LIST-SPMON
    INTO TABLE @DATA(LT_BASE).

  CHECK LT_BASE[] IS NOT INITIAL.

  "BILLING DOC
  DATA(LT_TEMP10) = LT_BASE[].
  SORT LT_TEMP10 BY VBELN_VLSP POSNR_VLSP.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP10 COMPARING VBELN_VLSP POSNR_VLSP.
  IF LT_TEMP10[] IS NOT INITIAL.
    SELECT A~VGBEL,
           B~FKDAT,B~NETWR AS NETWR_VF, B~WAERK AS WAERK_VF
      FROM VBRP AS A INNER JOIN VBRK AS B
                     ON A~VBELN = B~VBELN AND
                        B~FKSTO = @SPACE  AND
                        B~SFAKN = @SPACE
      FOR ALL ENTRIES IN @LT_TEMP10
     WHERE A~VGBEL EQ @LT_TEMP10-VBELN_VLSP
       AND A~VGPOS EQ @LT_TEMP10-POSNR_VLSP
      INTO TABLE @DATA(LT_VBRK).
    SORT LT_VBRK BY VGBEL.
  ENDIF.

  "원DO 상태
  CLEAR LT_TEMP10[].
  LT_TEMP10[] = LT_BASE[].
  SORT LT_TEMP10 BY VBELN_VL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP10 COMPARING VBELN_VL.
  IF LT_TEMP10[] IS NOT INITIAL.
    SELECT VBELN AS VBELN_VL,
           WBSTK,FKSTK,KOSTK
      FROM LIKP
       FOR ALL ENTRIES IN @LT_TEMP10
     WHERE VBELN EQ @LT_TEMP10-VBELN_VL
      INTO TABLE @DATA(LT_LIKP_VL).

  ENDIF.


  SORT LT_BASE BY VBELN_VL VBELN_VLSP VBELN_VA.
  DELETE ADJACENT DUPLICATES FROM LT_BASE COMPARING VBELN_VL VBELN_VLSP VBELN_VA.

  "납품처
  DATA(LT_TEMP) = LT_BASE[].
  SORT LT_TEMP BY KUNNR.
  DELETE LT_TEMP WHERE KUNNR IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING KUNNR.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT A~KUNNR,B~NAME1
      FROM KNA1 AS A INNER JOIN ADRC AS B
                     ON A~ADRNR = B~ADDRNUMBER
      FOR ALL ENTRIES IN @LT_TEMP
     WHERE A~KUNNR     EQ @LT_TEMP-KUNNR
       AND B~DATE_FROM LE @SY-DATLO
       AND B~DATE_TO   GE @SY-DATLO
      INTO TABLE @DATA(LT_KNA1).
  ENDIF.
  "판매처
  CLEAR LT_TEMP[].
  LT_TEMP[] = LT_BASE[].
  SORT LT_TEMP BY KUNAG.
  DELETE LT_TEMP WHERE KUNAG IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING KUNAG.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT A~KUNNR,B~NAME1
      FROM KNA1 AS A INNER JOIN ADRC AS B
                     ON A~ADRNR = B~ADDRNUMBER
      FOR ALL ENTRIES IN @LT_TEMP
     WHERE A~KUNNR     EQ @LT_TEMP-KUNAG
       AND B~DATE_FROM LE @SY-DATLO
       AND B~DATE_TO   GE @SY-DATLO
      APPENDING TABLE @LT_KNA1.
  ENDIF.
  SORT LT_KNA1 BY KUNNR.

  "출하지점
  CLEAR LT_TEMP[].
  LT_TEMP[] = LT_BASE[].
  SORT LT_TEMP BY VSTEL.
  DELETE LT_TEMP WHERE VSTEL IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VSTEL.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT VSTEL,VTEXT
      FROM TVSTT
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE VSTEL EQ @LT_TEMP-VSTEL
       AND SPRAS EQ @SY-LANGU
      INTO TABLE @DATA(LT_TVSTT).
    SORT LT_TVSTT BY VSTEL.
  ENDIF.

  "영업팀
  CLEAR LT_TEMP[].
  LT_TEMP[] = LT_BASE[].
  SORT LT_TEMP BY VKBUR.
  DELETE LT_TEMP WHERE VKBUR IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VKBUR.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT VKBUR,BEZEI
      FROM TVKBT
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE VKBUR EQ @LT_TEMP-VKBUR
       AND SPRAS EQ @SY-LANGU
      INTO TABLE @DATA(LT_TVKBT).
    SORT LT_TVKBT BY VKBUR.
  ENDIF.

  "영업그룹
  CLEAR LT_TEMP[].
  LT_TEMP[] = LT_BASE[].
  SORT LT_TEMP BY VKGRP.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING VKGRP.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT VKGRP,BEZEI
      FROM TVGRT
       FOR ALL ENTRIES IN @LT_TEMP
     WHERE VKGRP EQ @LT_TEMP-VKGRP
       AND SPRAS EQ @SY-LANGU
      INTO TABLE @DATA(LT_TVGRT).
    SORT LT_TVGRT BY VKGRP.
  ENDIF.

*-리스트 구성
  LOOP AT LT_BASE INTO DATA(LS_BASE).
    CLEAR: GS_SPLIT.
    MOVE-CORRESPONDING LS_BASE TO GS_SPLIT.

    "매출일/매출금액
    DATA(LS_VBRK) = VALUE #( LT_VBRK[ VGBEL = GS_SPLIT-VBELN_VLSP ] OPTIONAL ).
    IF LS_VBRK IS NOT INITIAL.
      GS_SPLIT-FKDAT    = LS_VBRK-FKDAT.
      GS_SPLIT-NETWR_VF = LS_VBRK-NETWR_VF.
      GS_SPLIT-WAERK_VF = LS_VBRK-WAERK_VF.
    ENDIF.

    "납품처 명
    IF GS_SPLIT-KUNNR IS NOT INITIAL.
      GS_SPLIT-KUNNR_TX = VALUE #( LT_KNA1[ KUNNR = GS_SPLIT-KUNNR ]-NAME1 OPTIONAL ).
    ENDIF.

    "판매처 명
    IF GS_SPLIT-KUNAG IS NOT INITIAL.
      GS_SPLIT-KUNAG_TX = VALUE #( LT_KNA1[ KUNNR = GS_SPLIT-KUNAG ]-NAME1 OPTIONAL ).
    ENDIF.
    "출하지점
    IF GS_SPLIT-VSTEL IS NOT INITIAL.
      GS_SPLIT-VSTEL_TX = VALUE #( LT_TVSTT[ VSTEL = GS_SPLIT-VSTEL ]-VTEXT OPTIONAL ).
    ENDIF.
    "영업팀
    IF GS_SPLIT-VKBUR IS NOT INITIAL.
      GS_SPLIT-VKBUR_TX = VALUE #( LT_TVKBT[ VKBUR = GS_SPLIT-VKBUR ]-BEZEI OPTIONAL ).
    ENDIF.
    "영업그룹
    IF GS_SPLIT-VKGRP IS NOT INITIAL.
      GS_SPLIT-VKGRP_TX = VALUE #( LT_TVGRT[ VKGRP = GS_SPLIT-VKGRP ]-BEZEI OPTIONAL ).
    ENDIF.

*    "원DO 상태 => PICKING이상 진행 중이면 선택 체크박스 선택 못하도록 함.
*    DATA(LS_LIKP) = VALUE #( LT_LIKP_VL[ VBELN_VL = GS_SPLIT-VBELN_VL ] OPTIONAL ).
*    IF LS_LIKP IS NOT INITIAL.
*      IF LS_LIKP-KOSTK EQ GC_C OR
*         LS_LIKP-WBSTK EQ GC_C OR
*         LS_LIKP-FKSTK EQ GC_C.
*        GS_SPLIT-NO_CANC = GC_X.
*      ENDIF.
*    ENDIF.

    PERFORM SET_LED_S2 CHANGING GS_SPLIT.

    PERFORM SET_ATTRIBUTES_LINE_BOT CHANGING GS_SPLIT.

    APPEND GS_SPLIT TO GT_SPLIT.

    CLEAR:LS_VBRK. "LS_LIKP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED_S2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_SPLIT
*&---------------------------------------------------------------------*
FORM SET_LED_S2  CHANGING PS_SPLIT LIKE GS_SPLIT.
  "PICKING :
  IF PS_SPLIT-KOSTK EQ GC_C.
    PS_SPLIT-ST_PICK = ICON_LED_GREEN.
  ELSE.
    PS_SPLIT-ST_PICK = ICON_LED_YELLOW.
  ENDIF.

  "출고 :
  IF PS_SPLIT-WBSTK EQ GC_C.
    PS_SPLIT-ST_PGI = ICON_LED_GREEN.
  ELSE.
    PS_SPLIT-ST_PGI = ICON_LED_YELLOW.
  ENDIF.

  "매출 :
  IF PS_SPLIT-FKSTK EQ GC_C.
    PS_SPLIT-ST_BILL = ICON_LED_GREEN.
    PS_SPLIT-ST_FINSH = ICON_LED_GREEN.
  ELSE.
    PS_SPLIT-ST_BILL = ICON_LED_YELLOW.
    PS_SPLIT-ST_FINSH = ICON_LED_YELLOW.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STATUS_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SPACE
*&---------------------------------------------------------------------*
FORM SET_STATUS_ITEM  USING  PA_STEP.

  ZGTSDS1100-SPLIT = GC_A. "납품분할
  ZGTSDS1100-KOSTK = GC_A. "PICKING
  ZGTSDS1100-WBSTK = GC_A. "출고
  ZGTSDS1100-FKSTK = GC_A. "청구
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STATUS_ITEM_LED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_STATUS_ITEM_LED .

  "납품분할
  IF ZGTSDS1100-SPLIT EQ GC_C.
    ZGTSDS1100-SPLT = ICON_LED_GREEN.
  ELSE.
    ZGTSDS1100-SPLT = ICON_LED_YELLOW.
  ENDIF.

  "PICKING
  IF ZGTSDS1100-KOSTK EQ GC_C.
    ZGTSDS1100-PICK = ICON_LED_GREEN.
  ELSE.
    ZGTSDS1100-PICK = ICON_LED_YELLOW.
  ENDIF.

  "출고
  IF ZGTSDS1100-WBSTK EQ GC_C.
    ZGTSDS1100-PGIS = ICON_LED_GREEN.
  ELSE.
    ZGTSDS1100-PGIS = ICON_LED_YELLOW.
  ENDIF.

  "청구
  IF ZGTSDS1100-FKSTK EQ GC_C.
    ZGTSDS1100-BILL = ICON_LED_GREEN.
  ELSE.
    ZGTSDS1100-BILL = ICON_LED_YELLOW.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_ALL_0100_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_ALL_0100_BOT .
  CLEAR GS_SPLIT.
  GS_SPLIT-SEL = GC_X.

  MODIFY GT_SPLIT FROM GS_SPLIT TRANSPORTING SEL WHERE SEL     NE GC_X
                                                   AND NO_CANC NE GC_X.

  PERFORM REFRESH_ALV USING GO_GRID2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DESELECT_ALL_0100_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DESELECT_ALL_0100_BOT .
  CLEAR GS_SPLIT.

  MODIFY GT_SPLIT FROM GS_SPLIT TRANSPORTING SEL WHERE SEL EQ GC_X.

  PERFORM REFRESH_ALV USING GO_GRID2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FKDAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FKDAT .
  DATA: LV_DATE TYPE SY-DATUM.

  LV_DATE(6) = P_SPMON.
  LV_DATE+6(2) = '01'.
  APPEND VALUE #( SIGN = 'I' OPTION = 'BT'
                  LOW  = LV_DATE
                  HIGH = ZGTSD_CL_COMMON2=>GET_LAST_DAY_MONTH(
                                              IV_DATE = LV_DATE )
                 )
     TO GR_FKDAT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EXCLUDING_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EXCLUDING_0200 .
  CLEAR:GT_EXCLU2[].

  IF ZGTSDS1100-FKSTK EQ GC_C.
    APPEND VALUE #( FCODE = 'ZCRT' ) TO GT_EXCLU2.
  ENDIF.

  IF ZGTSDS1100-LOCK IS INITIAL.
    APPEND VALUE #( FCODE = 'ZCRT' ) TO GT_EXCLU2.
    APPEND VALUE #( FCODE = 'ZCANC' ) TO GT_EXCLU2.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_DOUBLE_CLICK_0100_I
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_E_ROW
*&      --> PS_E_COLUMN
*&---------------------------------------------------------------------*
FORM ALV_DOUBLE_CLICK_0100_I  USING    PS_E_ROW  TYPE LVC_S_ROW
                                    PS_E_COLUMN TYPE LVC_S_COL.

  READ TABLE GT_SPLIT INTO DATA(LS_SPLIT) INDEX PS_E_ROW-INDEX.
  CHECK SY-SUBRC EQ 0.

  CASE PS_E_COLUMN-FIELDNAME.
    WHEN 'VBELN_VA'.
      IF LS_SPLIT-VBELN_VA IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD LS_SPLIT-VBELN_VA.
        CALL TRANSACTION 'VA03' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'VBELN_VL'.
      IF LS_SPLIT-VBELN_VL IS NOT INITIAL.
        SET PARAMETER ID 'VL' FIELD LS_SPLIT-VBELN_VL.
        CALL TRANSACTION 'VL03N' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'VBELN_VLSP'.
      IF LS_SPLIT-VBELN_VLSP IS NOT INITIAL.
        SET PARAMETER ID 'VL' FIELD LS_SPLIT-VBELN_VLSP.
        CALL TRANSACTION 'VL03N' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'ST_PICK' OR
         'ST_PGI' OR
         'ST_BILL'.
      PERFORM DISPLAY_MESSAGE_0100_I USING PS_E_COLUMN-FIELDNAME
                                           LS_SPLIT.
    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_MESSAGE_0100_I
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_E_COLUMN_FIELDNAM
*&      --> LS_SPLIT
*&---------------------------------------------------------------------*
FORM DISPLAY_MESSAGE_0100_I  USING    PV_FIELDNAM
                                      PS_SPLIT LIKE GT_SPLIT.
  IF ( PS_SPLIT-ST_PICK EQ ICON_LED_RED OR
       PS_SPLIT-ST_PGI EQ ICON_LED_RED OR
       PS_SPLIT-ST_BILL EQ ICON_LED_RED    ) AND
      PS_SPLIT-RSLT EQ GC_E.
    MESSAGE I000 WITH PS_SPLIT-MESSAGE(50)
                       PS_SPLIT-MESSAGE+50(50)
                       PS_SPLIT-MESSAGE+100(50)
                       PS_SPLIT-MESSAGE+150(50)
     DISPLAY LIKE GC_E.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_CHANGE_FINISHED_0100_BOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM ALV_CHANGE_FINISHED_0100_BOT  USING   PT_GOOD_CELLS TYPE LVC_T_MODI.
  DATA: LT_MODI TYPE LVC_T_MODI.
  DATA: LS_MODI TYPE LVC_S_MODI.


  LT_MODI[] = PT_GOOD_CELLS[].
  SORT LT_MODI BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_MODI COMPARING ROW_ID.
  LS_MODI = VALUE #( LT_MODI[ 1 ] OPTIONAL ).
  CHECK LS_MODI IS NOT INITIAL.


  PERFORM REFRESH_ALV USING: GO_GRID2.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_FI_CLOSE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM CHECK_FI_CLOSE  CHANGING PS_LIST LIKE GT_LIST.
  DATA: LV_DATE TYPE SY-DATUM.

  CHECK PS_LIST-WBSTK EQ GC_C OR PS_LIST-FKSTK EQ GC_C.

  IF PS_LIST-FKSTK EQ GC_C.
    LV_DATE = PS_LIST-FKDAT.
  ELSE.
    LV_DATE = PS_LIST-WADAT_IST.
  ENDIF.

  SELECT SINGLE BUKRS
    FROM T001B
   WHERE RRCTY =  '0'
     AND BUKRS = @PS_LIST-VKORG
     AND MKOAR =  '+'
     AND (   FRYE1 < @LV_DATE(4) OR
           ( FRYE1 = @LV_DATE(4) AND FRPE1 <= @LV_DATE+4(2) ) )
     AND ( ( TOYE1 = @LV_DATE(4) AND TOPE1 >= @LV_DATE+4(2) ) OR
             TOYE1 > @LV_DATE(4) )
    INTO @DATA(LV_BUKRS).
  IF SY-SUBRC NE 0.
    PS_LIST-FI_CLOSE = GC_X.
  ENDIF.


ENDFORM.
