*&---------------------------------------------------------------------*
*& Include          ZGTSDR2010F01
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

*-SET DEFAULT
  PERFORM SET_DEFAULT_INIT.

*-SET STATUS CODE
  PERFORM SET_STATUS_CODE.
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
    IF SCREEN-GROUP1 EQ 'ZM1'.
      SCREEN-INPUT = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DEFAULT_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DEFAULT_INIT .
  DATA: LV_DATE TYPE SY-DATUM.

  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_VKORG_6000 )
      TO S_VKORG.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_VTWEG_10 )
      TO S_VTWEG.
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_LFART_LF )
      TO S_LFART.

** 계획출고일
*  LV_DATE = SY-DATLO.
*  LV_DATE+6(2) = '01'.
*  APPEND VALUE #( SIGN = 'I' OPTION = 'BT'
*                  LOW  = LV_DATE HIGH = SY-DATLO )
*      TO S_WADAT.

* 실제출고일
  LV_DATE = SY-DATLO.
  LV_DATE+6(2) = '01'.
  APPEND VALUE #( SIGN = 'I' OPTION = 'BT'
                  LOW  = LV_DATE HIGH = SY-DATLO )
      TO S_WADATS.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EXCLUDING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EXCLUDING .
  CLEAR:GT_EXCLU[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_SPART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_SPART  USING    PV_FNAME.

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
*& Form F4_VKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VKGRP  USING    PV_FNAME.

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
*& Form INIT_OBJECTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_OBJECTS .
  CLEAR:
        GV_TITLE.

  REFRESH:
          GT_0100.
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

*-권한점검
  PERFORM CHECK_AUTHORITY.

*-계획출고일 또는 실제출고일 둘중 하나는 필수입력
  IF S_WADAT[] IS INITIAL AND
     S_WADATS[] IS INITIAL.
    MESSAGE S000 WITH TEXT-M01 DISPLAY LIKE GC_E.
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

*-TITLE
  GV_TITLE = TEXT-001.
  GV_TITLE2 = TEXT-002.
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
  DATA:LS_0100 LIKE GT_0100.
  DATA:LV_CHK1,LV_CHK2.
  DATA:LV_AMT_INI TYPE NETWR,
       LV_AMT_DW  TYPE NETWR,
       LV_AMT_JS  TYPE NETWR.
  DATA:LV_LENGTH_VRKME TYPE LFIMG.

*-----------------------------------------------------------
* 전체 PROCESS STEP 순서에 따라서 ZGTSDT91* 테이블에 데이터가 존재 또는 미존재
* ( LIKP/LIPS도 미존재 할수 있음)
* => 1. ZGTSDT91* 존재건과 2. LIKP/LIPS 존재 ZGTSDT91* 미존재건 으로 나누어 두번에 걸쳐 SELECT
*-----------------------------------------------------------
*-01. 선택조건의 데이터
  "STEP 01 : ZGTSDT9110 + ZGTSDT9120 기준 데이터
  SELECT A~VBELN AS VBELN_VL,
         A~VKORG,A~KUNAG AS KUNNR,A~KUNNR AS KUNWE,A~WADAT,A~WADAT_IST,
         A~LFART,A~WAERK,A~LIFSK,A~VSTEL,
         A~ZZJS_STATUS,A~ZZJS_ASN_STS_H,A~ZZJS_FINAL,A~LOEVM AS LOEVM_H,

         B~POSNR AS POSNR_VL,
         B~VTWEG,B~SPART,B~VKBUR,B~VKGRP,B~MATNR,B~CHARG,B~XCHAR,
         B~LFIMG,B~VRKME,B~VGBEL,B~VGPOS,B~WERKS,B~LGORT,B~UECHA,
         B~ZZJS_MVT,B~ZZJS_ASN_STS_I,B~MILLCA_FACTOR_M,B~MILLCA_FACTOR_JS,
         B~LOEVM AS LOEVM_I,

         D~VBELN AS VBELN_VA,
         D~AUART,D~BSTNK,
         C~POSNR AS POSNR_VA,
         C~NETPR,C~NETWR,C~MWSBP,

         E~LIFNR AS PERNR,
         F~TKNUM
    FROM ZGTSDT9110 AS A INNER JOIN ZGTSDT9120 AS B
                         ON A~VBELN = B~VBELN
                         INNER JOIN VBAP AS C
                         ON B~VGBEL = C~VBELN AND
                            B~VGPOS = C~POSNR
                         INNER JOIN VBAK AS D
                         ON C~VBELN = D~VBELN
                         INNER JOIN LIKP AS K
                         ON A~VBELN = K~VBELN
                         LEFT OUTER JOIN VBPA AS E
                         ON D~VBELN = E~VBELN  AND
                            E~POSNR = '000000' AND
                            E~PARVW = 'VE'           "영업사원
                         LEFT OUTER JOIN VTTP AS F
                         ON A~VBELN = F~VBELN

   WHERE A~VKORG     IN @S_VKORG
     AND A~WADAT     IN @S_WADAT
     AND A~WADAT_IST IN @S_WADATS
     AND A~LFART     IN @S_LFART
     AND A~KUNAG     IN @S_KUNNR
     AND A~KUNNR     IN @S_KUNWE
     AND A~VSTEL     IN @S_VSTEL
     AND A~LIFSK     IN @S_LIFSK
     AND A~LOEVM     EQ @SPACE        "삭제건 제외 => ORIGINAL DO 원복됨.
     AND B~VTWEG     IN @S_VTWEG
     AND B~SPART     IN @S_SPART
     AND B~VKBUR     IN @S_VKBUR
     AND B~VKGRP     IN @S_VKGRP
     AND B~MATNR     IN @S_MATNR
     AND B~LGORT     IN @S_LGORT
     AND D~BSTNK     IN @S_BSTNK
     AND D~VBELN     IN @S_VBELN
*     AND E~LIFNR     IN @S_PERNR
    INTO TABLE @DATA(LT_LIST01).


  "STEP02 : LIKP + LIPS 기준(ZGTSDT9110 에 미존재 건)
  SELECT A~VBELN AS VBELN_VL,
         A~KUNAG AS KUNNR,
         A~KUNNR AS KUNWE,A~WADAT,A~WADAT_IST,
         A~LFART,A~VKORG,A~WAERK,A~LIFSK,A~VSTEL,

         B~POSNR AS POSNR_VL,
         B~VTWEG,B~SPART,B~VKBUR,B~VKGRP,B~MATNR,B~CHARG,B~XCHAR,
         B~LFIMG,B~VRKME,B~VGBEL,B~VGPOS,B~WERKS,B~LGORT,B~UECHA,

         D~VBELN AS VBELN_VA,
         D~AUART,D~BSTNK,
         C~POSNR AS POSNR_VA,
         C~NETPR,C~NETWR,C~MWSBP,

         E~LIFNR AS PERNR,
         F~TKNUM
    FROM LIKP      AS A INNER JOIN LIPS AS B
                         ON A~VBELN = B~VBELN
                         INNER JOIN VBAP AS C
                         ON B~VGBEL = C~VBELN AND
                            B~VGPOS = C~POSNR
                         INNER JOIN VBAK AS D
                         ON C~VBELN = D~VBELN
                         LEFT OUTER JOIN VBPA AS E
                         ON D~VBELN = E~VBELN  AND
                            E~POSNR = '000000' AND
                            E~PARVW = 'VE'           "영업사원
                         LEFT OUTER JOIN VTTP AS F
                         ON A~VBELN = F~VBELN

   WHERE A~VKORG     IN @S_VKORG
     AND A~WADAT     IN @S_WADAT
     AND A~WADAT_IST IN @S_WADATS
     AND A~LFART     IN @S_LFART
     AND A~KUNAG     IN @S_KUNNR
     AND A~KUNNR     IN @S_KUNWE
     AND A~VSTEL     IN @S_VSTEL
     AND A~LIFSK     IN @S_LIFSK
     AND A~WBSTK     EQ @GC_WBSTK_C    "자재이동 완료
     AND A~FKSTK     EQ @GC_FKSTK_A    "청구 미완료
     AND B~VTWEG     IN @S_VTWEG
     AND B~SPART     IN @S_SPART
     AND B~VKBUR     IN @S_VKBUR
     AND B~VKGRP     IN @S_VKGRP
     AND B~MATNR     IN @S_MATNR
     AND B~LGORT     IN @S_LGORT
     AND D~BSTNK     IN @S_BSTNK
     AND D~VBELN     IN @S_VBELN
*     AND E~LIFNR     IN @S_PERNR
     AND NOT EXISTS ( SELECT X~VBELN
                        FROM ZGTSDT9110 AS X
                       WHERE X~VBELN EQ A~VBELN
                         AND X~LOEVM EQ @SPACE )

    APPENDING CORRESPONDING FIELDS OF TABLE @LT_LIST01.
  SORT LT_LIST01 BY VBELN_VL POSNR_VL.

  "선택조건 영업사원
  DELETE LT_LIST01 WHERE NOT PERNR IN S_PERNR.

  CHECK LT_LIST01 IS NOT INITIAL.

*-OUTPUT LIST 구성
  DATA(LT_MAIN) = LT_LIST01[].
  SORT LT_MAIN BY VBELN_VL.
  DELETE ADJACENT DUPLICATES FROM LT_MAIN COMPARING VBELN_VL.

  DATA(LT_ITEM) = LT_LIST01[].
  SORT LT_ITEM BY VBELN_VL POSNR_VL.
  DELETE LT_ITEM WHERE UECHA NE '000000'.
  DELETE ADJACENT DUPLICATES FROM LT_ITEM COMPARING VBELN_VL POSNR_VL.


  LOOP AT LT_MAIN INTO DATA(LS_TEMP).  "납품문서
    CLEAR:LS_0100.
    MOVE-CORRESPONDING LS_TEMP TO LS_0100.

    CLEAR:LV_AMT_INI,LV_AMT_DW,LV_AMT_JS.
    LOOP AT LT_ITEM INTO DATA(LS_ITEM) WHERE VBELN_VL = LS_TEMP-VBELN_VL. "납품문서 아이템
      CLEAR:LV_CHK1,LV_CHK2,LV_LENGTH_VRKME.

      "SO 아이템의 조장
      PERFORM GET_SAP_LENGTH_VRKME    USING LS_ITEM-VGBEL LS_ITEM-VGPOS
                                   CHANGING LV_LENGTH_VRKME.

      "배치 SPLIT 체크
      IF LINE_EXISTS( LT_LIST01[ VBELN_VL = LS_ITEM-VBELN_VL UECHA = LS_ITEM-POSNR_VL ] ).
        LV_CHK1 = GC_X.
      ENDIF.

      "BATCH SPLIT
      IF LV_CHK1 EQ GC_X.

        LOOP AT LT_LIST01 INTO DATA(LS_LINE) WHERE VBELN_VL = LS_ITEM-VBELN_VL
                                               AND UECHA    = LS_ITEM-POSNR_VL.
*         최초금액 SUM: DO 수량 * SO 단가
          LV_AMT_INI = LV_AMT_INI + ( LS_LINE-LFIMG * LS_LINE-NETPR ).
*         당월금액 SUM: 조장수 * 조장 * DO 수량
          LV_AMT_DW = LV_AMT_DW   +
                      ( LS_LINE-MILLCA_FACTOR_M * LV_LENGTH_VRKME * LS_LINE-NETPR ).
*         적송금액 SUM: 적송조장수 * 조장 * DO 수량
          LV_AMT_JS = LV_AMT_JS   +
                      ( LS_LINE-MILLCA_FACTOR_JS * LV_LENGTH_VRKME * LS_LINE-NETPR ).
        ENDLOOP.

      ELSE.

        LOOP AT LT_LIST01 INTO LS_LINE WHERE VBELN_VL = LS_ITEM-VBELN_VL
                                         AND POSNR_VL = LS_ITEM-POSNR_VL.
*         최초금액 SUM: DO 수량 * SO 단가
          LV_AMT_INI = LV_AMT_INI + ( LS_LINE-LFIMG * LS_LINE-NETPR ).
*         당월금액 SUM: 조장수 * 조장 * DO 수량
          LV_AMT_DW = LV_AMT_DW   +
                      ( LS_LINE-MILLCA_FACTOR_M * LV_LENGTH_VRKME * LS_LINE-NETPR ).
*         적송금액 SUM: 적송조장수 * 조장 * DO 수량
          LV_AMT_JS = LV_AMT_JS   +
                      ( LS_LINE-MILLCA_FACTOR_JS * LV_LENGTH_VRKME * LS_LINE-NETPR ).
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    LS_0100-NETWR_INI = LV_AMT_INI. "최초금액 SUM
    LS_0100-NETWR_DW  = LV_AMT_DW.  "당월금액 SUM
    LS_0100-NETWR_JS  = LV_AMT_JS.  "적송금액 SUM

    APPEND LS_0100 TO GT_0100.

  ENDLOOP.

  SORT GT_0100 BY VBELN_VL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SAP_LENGTH_VRKME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_ITEM_VGBEL
*&      --> LS_ITEM_VGPOS
*&      <-- LV_LENGTH_VRKME
*&---------------------------------------------------------------------*
FORM GET_SAP_LENGTH_VRKME  USING    P_VBELN
                                    P_POSNR
                           CHANGING P_LENGTH_VRKME.
  DATA: LT_CHAR LIKE TABLE OF CONF_OUT.

  CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC_TABLE'
    EXPORTING
      I_VBELN                      = P_VBELN
      I_POSNR                      = P_POSNR
    TABLES
      ET_CHAR                      = LT_CHAR
    EXCEPTIONS
      CHARACTERISTIC_NOT_FOUND     = 1
      INSTANCE_NOT_FOUND           = 2
      INSTANCE_IS_A_CLASSIFICATION = 3
      INVALID_DATA                 = 4
      OTHERS                       = 5.
  IF SY-SUBRC = 0.
    DATA(LV_ATWRT) = VALUE #( LT_CHAR[ ATNAM = GC_LENGTH_VRKME ]-ATWRT OPTIONAL ).
    P_LENGTH_VRKME = CONV LFIMG( LV_ATWRT ).
  ENDIF.


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
  IF GT_0100[] IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE S010.
  ENDIF.
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

  CHECK GT_0100[] IS NOT INITIAL.

*-01. TEXT
  "판매처/납품처
  DATA(LT_TEMP) = GT_0100[].
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
  LT_TEMP[] = GT_0100[].
  SORT LT_TEMP BY KUNWE.
  DELETE LT_TEMP WHERE KUNWE IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM LT_TEMP COMPARING KUNWE.
  IF LT_TEMP[] IS NOT INITIAL.
    SELECT A~KUNNR,B~NAME1
      FROM KNA1 AS A INNER JOIN ADRC AS B
                     ON A~ADRNR = B~ADDRNUMBER
      FOR ALL ENTRIES IN @LT_TEMP
     WHERE A~KUNNR     EQ @LT_TEMP-KUNWE
       AND B~DATE_FROM LE @SY-DATLO
       AND B~DATE_TO   GE @SY-DATLO
      APPENDING TABLE @LT_KNA1.

  ENDIF.
  SORT LT_KNA1 BY KUNNR.

  "출하지점
  CLEAR LT_TEMP[].
  LT_TEMP[] = GT_0100[].
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
  LT_TEMP[] = GT_0100[].
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
  LT_TEMP[] = GT_0100[].
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

*-02. LIST 구성
  LOOP AT GT_0100 ASSIGNING FIELD-SYMBOL(<FS_0100>).

    "판매처 명
    IF <FS_0100>-KUNNR IS NOT INITIAL.
      <FS_0100>-KUNNR_NM = VALUE #( LT_KNA1[ KUNNR = <FS_0100>-KUNNR ]-NAME1 OPTIONAL ).
    ENDIF.
    "납품처 명
    IF <FS_0100>-KUNWE IS NOT INITIAL.
      <FS_0100>-KUNWE_NM = VALUE #( LT_KNA1[ KUNNR = <FS_0100>-KUNWE ]-NAME1 OPTIONAL ).
    ENDIF.
    "출하지점
    IF <FS_0100>-VSTEL IS NOT INITIAL.
      <FS_0100>-VSTEL_NM = VALUE #( LT_TVSTT[ VSTEL = <FS_0100>-VSTEL ]-VTEXT OPTIONAL ).
    ENDIF.
    "영업팀
    IF <FS_0100>-VKBUR IS NOT INITIAL.
      <FS_0100>-VKBUR_NM = VALUE #( LT_TVKBT[ VKBUR = <FS_0100>-VKBUR ]-BEZEI OPTIONAL ).
    ENDIF.
    "영업그룹
    IF <FS_0100>-VKGRP IS NOT INITIAL.
      <FS_0100>-VKGRP_NM = VALUE #( LT_TVGRT[ VKGRP = <FS_0100>-VKGRP ]-BEZEI OPTIONAL ).
    ENDIF.

    <FS_0100>-BUTN = ICON_DETAIL.

    "SET STATUS LED
    PERFORM SET_LED CHANGING <FS_0100>.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_0100>
*&---------------------------------------------------------------------*
FORM SET_LED  CHANGING PS_0100 LIKE GT_0100.
  DATA:LV_TEXT(20).

  "적송완료
  IF PS_0100-ZZJS_FINAL EQ GC_X.
    PS_0100-ST_FINAL = ICON_LED_GREEN.
  ELSE.
    PS_0100-ST_FINAL = ICON_LED_YELLOW.
  ENDIF.

  "적송지정상태
  CASE PS_0100-ZZJS_ASN_STS_H.
    WHEN GC_C.
      PS_0100-ST_STSH = ICON_LED_GREEN.
    WHEN GC_B.
      PS_0100-ST_STSH = ICON_LED_YELLOW.
    WHEN SPACE.
      PS_0100-ST_STSH = ICON_LED_RED.
    WHEN OTHERS.
      CLEAR PS_0100-ST_STSH.
  ENDCASE.

  "상태
  SORT GT_CODE BY CODE DESCENDING.
  LOOP AT GT_CODE INTO DATA(LS_CODE).
    CLEAR LV_TEXT.
    LV_TEXT = |ST_{ LS_CODE-STATUS }|.
    ASSIGN COMPONENT LV_TEXT OF STRUCTURE PS_0100 TO FIELD-SYMBOL(<FS_VAL>).
    CHECK SY-SUBRC EQ 0.

    IF LS_CODE-CODE <= PS_0100-ZZJS_STATUS.
      <FS_VAL> = ICON_LED_GREEN.
    ELSE.
      <FS_VAL> = ICON_LED_YELLOW.
    ENDIF.
    UNASSIGN <FS_VAL>.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STATUS_CODE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_STATUS_CODE .
  DATA: LT_TAB TYPE TABLE OF DD07V.


  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      DOMNAME         = GC_DOMAIN_STATUS
*     TEXT            = 'X'
*     FILL_DD07L_TAB  = ' '
    TABLES
      VALUES_TAB      = LT_TAB
*     VALUES_DD07L    =
    EXCEPTIONS
      NO_VALUES_FOUND = 1
      OTHERS          = 2.

  CLEAR GT_CODE[].
  LOOP AT LT_TAB INTO DATA(LS_TAB) WHERE DOMVALUE_L NE SPACE.
    APPEND INITIAL LINE TO GT_CODE ASSIGNING FIELD-SYMBOL(<FS_ANY>).
    <FS_ANY>-CODE = LS_TAB-DOMVALUE_L.
    <FS_ANY>-TEXT = LS_TAB-DDTEXT.
    CASE <FS_ANY>-CODE.
      WHEN GC_A.
        <FS_ANY>-STATUS = 'DBS'.
      WHEN GC_B.
        <FS_ANY>-STATUS = 'GIC'.
      WHEN GC_C.
        <FS_ANY>-STATUS = 'HDB'.
      WHEN GC_D.
        <FS_ANY>-STATUS = 'BLD'.
      WHEN GC_E.
        <FS_ANY>-STATUS = 'QT0'.
      WHEN GC_F.
        <FS_ANY>-STATUS = 'WTU'.
      WHEN GC_G.
        <FS_ANY>-STATUS = 'SGI'.
      WHEN GC_H.
        <FS_ANY>-STATUS = 'SMV'.
      WHEN GC_I.
        <FS_ANY>-STATUS = 'NDC'.
      WHEN GC_J.
        <FS_ANY>-STATUS = 'BLC'.
      WHEN GC_K.
        <FS_ANY>-STATUS = 'FGI'.
      WHEN GC_L.
        <FS_ANY>-STATUS = 'FBL'.

    ENDCASE.

  ENDLOOP.
  APPEND VALUE #( CODE = ' ' STATUS = ' ' ) TO GT_CODE.
  SORT GT_CODE BY CODE DESCENDING.

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
  CLEAR GT_EXCLU2[].

  IF ZGTSDS0020-LOCK IS INITIAL.
    APPEND VALUE #( FCODE = 'ZF500' ) TO GT_EXCLU2.
    APPEND VALUE #( FCODE = 'ZF600' ) TO GT_EXCLU2.
    APPEND VALUE #( FCODE = 'ZF700' ) TO GT_EXCLU2.

  ELSE.
* 헤더기준 적송지정완료 => 적송지정 저장 버튼 비활성
    IF ZGTSDS0020-ZZJS_ASN_STS_H EQ GC_C. "적송지정 완료.
      APPEND VALUE #( FCODE = 'ZF500' ) TO GT_EXCLU2.
      LOOP AT GT_0200 WHERE FACTOR_M > 0.
        EXIT.
      ENDLOOP.
      IF SY-SUBRC NE 0.
        APPEND VALUE #( FCODE = 'ZF700' ) TO GT_EXCLU2.
      ENDIF.
    ELSE.
      APPEND VALUE #( FCODE = 'ZF700' ) TO GT_EXCLU2.
    ENDIF.



* 적송처리 상태가 출고취소(GIC) 포함 이후 진행상태인 경우 => 모든버튼 비활성
    IF ZGTSDS0020-ZZJS_STATUS >= GC_B.
      APPEND VALUE #( FCODE = 'ZF500' ) TO GT_EXCLU2.
      APPEND VALUE #( FCODE = 'ZF600' ) TO GT_EXCLU2.
      IF ZGTSDS0020-ZZJS_STATUS > GC_K.
        APPEND VALUE #( FCODE = 'ZF700' ) TO GT_EXCLU2.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HTEXT_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_HTEXT_FIELDS .
  "영업조직
  IF ZGTSDS0020-VKORG IS NOT INITIAL.
    ZGTSDS0020-VKORG_NM = ZGTSD_CL_COMMON2=>GET_VKORG_TEXT( IV_VKORG = ZGTSDS0020-VKORG
                                                            IV_SPRAS = SY-LANGU ).
  ENDIF.
  "유통경로
  IF ZGTSDS0020-VTWEG IS NOT INITIAL.
    ZGTSDS0020-VTWEG_NM = ZGTSD_CL_COMMON2=>GET_VTWEG_TEXT( IV_VTWEG = ZGTSDS0020-VTWEG
                                                            IV_SPRAS = SY-LANGU ).
  ENDIF.
  "제품군
  IF ZGTSDS0020-SPART IS NOT INITIAL.
    ZGTSDS0020-SPART_NM = ZGTSD_CL_COMMON2=>GET_SPART_TEXT( IV_SPART = ZGTSDS0020-SPART
                                                            IV_SPRAS = SY-LANGU ).
  ENDIF.
  "영업팀
  IF ZGTSDS0020-VKBUR IS NOT INITIAL.
    ZGTSDS0020-VKBUR_NM = ZGTSD_CL_COMMON2=>GET_VKBUR_TEXT( IV_VKBUR = ZGTSDS0020-VKBUR
                                                            IV_SPRAS = SY-LANGU ).
  ENDIF.
  "영업그룹
  IF ZGTSDS0020-VKGRP IS NOT INITIAL.
    ZGTSDS0020-VKGRP_NM = ZGTSD_CL_COMMON2=>GET_VKGRP_TEXT( IV_VKGRP = ZGTSDS0020-VKGRP
                                                            IV_SPRAS = SY-LANGU ).
  ENDIF.
  "출하지점
  IF ZGTSDS0020-VSTEL IS NOT INITIAL.
    ZGTSDS0020-VSTEL_NM = ZGTSD_CL_COMMON2=>GET_VSTEL_TEXT( IV_VSTEL = ZGTSDS0020-VSTEL
                                                            IV_SPRAS = SY-LANGU ).
  ENDIF.
  "납품유형
  IF ZGTSDS0020-LFART IS NOT INITIAL.
    ZGTSDS0020-LFART_NM = ZGTSD_CL_COMMON2=>GET_LFART_TEXT( IV_LFART = ZGTSDS0020-LFART
                                                            IV_SPRAS = SY-LANGU ).
  ENDIF.
  "주문유형
  IF ZGTSDS0020-AUART IS NOT INITIAL.
    ZGTSDS0020-AUART_NM = ZGTSD_CL_COMMON2=>GET_AUART_TEXT( IV_AUART = ZGTSDS0020-AUART
                                                            IV_SPRAS = SY-LANGU ).
  ENDIF.
  "판매처
  IF ZGTSDS0020-KUNNR IS NOT INITIAL.
    ZGTSDS0020-KUNNR_NM = ZGTSD_CL_COMMON2=>GET_KUNNR_TEXT( IV_KUNNR = ZGTSDS0020-KUNNR ).

  ENDIF.
  "납품처
  IF ZGTSDS0020-KUNWE IS NOT INITIAL.
    ZGTSDS0020-KUNWE_NM = ZGTSD_CL_COMMON2=>GET_KUNNR_TEXT( IV_KUNNR = ZGTSDS0020-KUNWE ).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DO_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_DO_INFO USING PS_ROW_NO TYPE LVC_S_ROID.
  DATA: LV_TYPE TYPE BAPI_MTYPE,
        LV_MSG  TYPE BAPI_MSG.

  CALL FUNCTION 'ZGTSD_JS_SAVE_DO_INFO'
    IMPORTING
      E_TYPE  = LV_TYPE
      E_MSG   = LV_MSG
    TABLES
      IT_LIKP = GT_LIKP
      IT_LIPS = GT_LIPS.
  READ TABLE GT_0100 ASSIGNING FIELD-SYMBOL(<FS_0100>) INDEX PS_ROW_NO-ROW_ID.
  IF LV_TYPE EQ GC_E.
    GV_ERROR = GC_X.
    <FS_0100>-STAT    = ICON_LED_RED.
    <FS_0100>-ST_DBS  = ICON_LED_RED.
    <FS_0100>-MESSAGE = LV_MSG.
  ELSE.
    <FS_0100>-ZZJS_STATUS = GC_A.
    <FS_0100>-ST_DBS      = ICON_LED_GREEN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_LINE_0210
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_0210
*&---------------------------------------------------------------------*
FORM SET_ATTRIBUTES_LINE_0210  CHANGING PS_0210 LIKE GS_0210.
  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  CLEAR PS_0210-CELLTAB[].

  LOOP AT GT_FIELDCAT2 INTO DATA(LS_FCAT).
    CLEAR:LS_CELLTAB.
    LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
    CASE LS_FCAT-FIELDNAME.
      WHEN 'FACTOR_JS'.

        "LOCK 체크: 다른 사용자가 처리중.
        IF ZGTSDS0020-LOCK IS INITIAL.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

        ELSE.
          IF PS_0210-ZZJS_ASN_STS_I EQ GC_C.
            LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          ELSE.
            LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
          ENDIF.

        ENDIF.

      WHEN OTHERS.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

    ENDCASE.
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  ENDLOOP.
  INSERT LINES OF LT_CELLTAB INTO TABLE PS_0210-CELLTAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITEM_DETAILS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_0200
*&---------------------------------------------------------------------*
FORM SET_ITEM_DETAILS  CHANGING PS_0200 LIKE GT_0200.

  DATA:LV_CHK1.

*-01. DO/항번 ITEM
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN EQ @PS_0200-VBELN
     AND ( POSNR EQ @PS_0200-POSNR OR
           UECHA EQ @PS_0200-POSNR    )
    INTO TABLE @DATA(LT_LIPS).

*-02. 배치 SPLIT 체크
  IF LINE_EXISTS( LT_LIPS[ VBELN = PS_0200-VBELN UECHA = PS_0200-POSNR ] ).
    LV_CHK1 = GC_X.
  ENDIF.

*-03. ITEM 상세라인
  "BATCH SPLIT
  IF LV_CHK1 EQ GC_X.
    LOOP AT LT_LIPS INTO DATA(LS_LIPS) WHERE VBELN = PS_0200-VBELN
                                         AND UECHA = PS_0200-POSNR.
      CLEAR GS_0210.
      GS_0210-POSNR            = PS_0200-POSNR.
      GS_0210-POSNR_B          = LS_LIPS-POSNR.
      GS_0210-MATNR            = LS_LIPS-MATNR.
      GS_0210-CHARG            = LS_LIPS-CHARG.
      GS_0210-VRKME            = LS_LIPS-VRKME.
      "최초수량
      GS_0210-LFIMG            = LS_LIPS-LFIMG.
      "단가
      GS_0210-NETPR            = GS_0200-NETPR.
      GS_0210-WAERK            = GS_0200-WAERK.

      GS_0210-ZZJS_MVT         = LS_LIPS-ZZJS_MVT.        "적송창고 이동 지시자
      GS_0210-ZZJS_ASN_STS_I   = LS_LIPS-ZZJS_ASN_STS_I.  "적송지정상태
      GS_0210-MILLCA_FACTOR_M  = LS_LIPS-MILLCA_FACTOR_M. "당월조장수
      GS_0210-MILLCA_FACTOR_JS = LS_LIPS-MILLCA_FACTOR_JS."적송조장수

      "조장
      GS_0210-LENGTH_JS = GS_0200-LENGTH_JS.

      "최초조장수 : 최초수량 / 조장
      IF GS_0210-LENGTH_JS NE 0.
        GS_0210-FACTOR_I = GS_0210-LFIMG / GS_0210-LENGTH_JS.
      ENDIF.

      "적송조장수 : 아이템 세부라인의 적송지정 상태가 'C' 인 경우 DB값 지정
      "          => 아닌경우 최초조장수 지정
      IF GS_0210-ZZJS_ASN_STS_I EQ GC_C.
        GS_0210-FACTOR_JS  = LS_LIPS-MILLCA_FACTOR_JS.
      ELSE.
        GS_0210-FACTOR_JS  = GS_0210-FACTOR_I.
      ENDIF.

      "당월조장수: 최초조장수 - 적송조장수
      GS_0210-FACTOR_M    = GS_0210-FACTOR_I - GS_0210-FACTOR_JS.

      "당월수량 : 당월조장수 * 조장
      GS_0210-LFIMG_M     = GS_0210-FACTOR_M * GS_0210-LENGTH_JS.

      "당월금액 : 당월수량 * 단가
      GS_0210-NETWR_DW    = GS_0210-LFIMG_M * GS_0210-NETPR.

      "적송수량 : 적송조장수 * 조장
      GS_0210-LFIMG_JS    = GS_0210-FACTOR_JS * GS_0210-LENGTH_JS.

      "적송금액 : 적송수량 * 단가
      GS_0210-NETWR_JS    = GS_0210-LFIMG_JS * GS_0210-NETPR.

      APPEND GS_0210 TO GT_0210_LIST.

      "ITEM 라인 의 최초수량    : ITEM 상세라인의 SUM
      PS_0200-LFIMG     = PS_0200-LFIMG + GS_0210-LFIMG.
      "ITEM 라인 의 초초조장수   : ITEM 상세라인의 SUM
      PS_0200-FACTOR_I  = PS_0200-FACTOR_I + GS_0210-FACTOR_I.
      "ITEM 라인의 당월조장수 : ITEM 상세라인의 SUM
      PS_0200-FACTOR_M  = PS_0200-FACTOR_M + GS_0210-FACTOR_M.
      "ITEM 라인의 적송조장수 : ITEM 상세라인의 SUM
      PS_0200-FACTOR_JS = PS_0200-FACTOR_JS + GS_0210-FACTOR_JS.
    ENDLOOP.

  ELSE.

    LOOP AT LT_LIPS INTO LS_LIPS WHERE VBELN = PS_0200-VBELN
                                   AND POSNR = PS_0200-POSNR.
      CLEAR GS_0210.
      GS_0210-POSNR            = PS_0200-POSNR.
*        GS_0210-POSNR_B          = LS_LIPS-POSNR.
      GS_0210-MATNR            = LS_LIPS-MATNR.
      GS_0210-CHARG            = LS_LIPS-CHARG.
      GS_0210-VRKME            = LS_LIPS-VRKME.
      "최초수량
      GS_0210-LFIMG            = LS_LIPS-LFIMG.
      "단가
      GS_0210-NETPR            = PS_0200-NETPR.
      GS_0210-WAERK            = PS_0200-WAERK.

      GS_0210-ZZJS_MVT         = LS_LIPS-ZZJS_MVT.        "적송창고 이동 지시자
      GS_0210-ZZJS_ASN_STS_I   = LS_LIPS-ZZJS_ASN_STS_I.  "적송지정상태
      GS_0210-MILLCA_FACTOR_M  = LS_LIPS-MILLCA_FACTOR_M. "당월조장수
      GS_0210-MILLCA_FACTOR_JS = LS_LIPS-MILLCA_FACTOR_JS."적송조장수

      "조장
      GS_0210-LENGTH_JS = PS_0200-LENGTH_JS.

      "최초조장수 : 최초수량 / 조장
      IF GS_0210-LENGTH_JS NE 0.
        GS_0210-FACTOR_I = GS_0210-LFIMG / GS_0210-LENGTH_JS.
      ENDIF.

      "적송조장수 : 아이템 세부라인의 적송지정 상태가 'C' 인 경우 DB값 지정
      "          => 아닌경우 최초조장수 지정
      IF GS_0210-ZZJS_ASN_STS_I EQ GC_C.
        GS_0210-FACTOR_JS  = LS_LIPS-MILLCA_FACTOR_JS.
      ELSE.
        GS_0210-FACTOR_JS  = GS_0210-FACTOR_I.
      ENDIF.

      "당월조장수: 최초조장수 - 적송조장수
      GS_0210-FACTOR_M   = GS_0210-FACTOR_I - GS_0210-FACTOR_JS.

      "당월수량 : 당월조장수 * 조장
      GS_0210-LFIMG_M     = GS_0210-FACTOR_M * GS_0210-LENGTH_JS.

      "당월금액 : 당월수량 * 단가
      GS_0210-NETWR_DW    = GS_0210-LFIMG_M * GS_0210-NETPR.

      "적송수량 : 적송조장수 * 조장
      GS_0210-LFIMG_JS    = GS_0210-FACTOR_JS * GS_0210-LENGTH_JS.

      "적송금액 : 적송수량 * 단가
      GS_0210-NETWR_JS    = GS_0210-LFIMG_JS * GS_0210-NETPR.

      APPEND GS_0210 TO GT_0210_LIST.

      "ITEM 라인 의 최초수량    : ITEM 상세라인의 SUM
      PS_0200-LFIMG     = PS_0200-LFIMG + GS_0210-LFIMG.
      "ITEM 라인 의 초초조장수   : ITEM 상세라인의 SUM
      PS_0200-FACTOR_I  = PS_0200-FACTOR_I  + GS_0210-FACTOR_I.
      "ITEM 라인의 당월조장수 : ITEM 상세라인의 SUM
      PS_0200-FACTOR_M  = PS_0200-FACTOR_M  + GS_0210-FACTOR_M.
      "ITEM 라인의 적송조장수 : ITEM 상세라인의 SUM
      PS_0200-FACTOR_JS = PS_0200-FACTOR_JS + GS_0210-FACTOR_JS.
    ENDLOOP.
  ENDIF.


  "당월수량 : 당월조장수 * 조장
  PS_0200-LFIMG_M   = PS_0200-FACTOR_M * PS_0200-LENGTH_JS.
  "적송수량 : 적송조장수 * 조장
  PS_0200-LFIMG_JS  = PS_0200-FACTOR_JS * PS_0200-LENGTH_JS.
  "최초금액 :최초수량 * 단가
  PS_0200-NETWR_INI = PS_0200-LFIMG * PS_0200-NETPR.
  "당월금액 : 당월수량 * 단가
  PS_0200-NETWR_DW  = PS_0200-LFIMG_M * PS_0200-NETPR.
  "적송금액 : 적송수량 * 단가
  PS_0200-NETWR_JS  = PS_0200-LFIMG_JS * PS_0200-NETPR.

  "저장위치
  PS_0200-LGORT = LS_LIPS-LGORT.
  PS_0200-LGOBE = ZGTSD_CL_COMMON2=>GET_LGORT_TEXT( IV_WERKS = LS_LIPS-WERKS
                                                    IV_LGORT = LS_LIPS-LGORT ).

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
    MESSAGE S000 WITH TEXT-M03 DISPLAY LIKE GC_E.
    LEAVE LIST-PROCESSING.
  ENDIF.

  LOOP AT LT_VKGRP INTO DATA(LS_VKGRP).
    CLEAR LV_SUBRC.
    PERFORM AUTHORIZATION_CHECK_EXEC    USING GC_7 LS_VKGRP-VKGRP
                                     CHANGING LV_SUBRC.
    IF LV_SUBRC NE 0.
      MESSAGE S203 WITH LS_VKGRP-VKGRP DISPLAY LIKE GC_E.
      LEAVE LIST-PROCESSING.
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
*& Form ASSIGN_JS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ASSIGN_JS_DATA .

  PERFORM CHECK_CHANGED_DATA USING GO_GRID1.
  PERFORM CHECK_CHANGED_DATA USING GO_GRID2.

*-01. CHECK
  CLEAR GV_ERROR.
  PERFORM CHECK_DATA_SAVE_0200.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P01 ) EQ GC_J.

*-02. 적송지정 저장
  PERFORM ASSIGN_JS_DATA_SAVE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA_SAVE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_DATA_SAVE_0200 .
  DATA: LV_CHK(1),
        LV_CHK2(1).

*-01. ITEM LINE 선택
  IF NOT ( LINE_EXISTS( GT_0200[ SEL = GC_X ] ) ).
    GV_ERROR = GC_X.
    MESSAGE S000 WITH TEXT-M04 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  LOOP AT GT_0200 INTO DATA(LS_0200) WHERE SEL EQ GC_X.
*-02. 적송지정 완료
    SELECT SINGLE ZZJS_ASN_STS_I
      FROM ZGTSDT9120
     WHERE VBELN EQ @LS_0200-VBELN
       AND POSNR EQ @LS_0200-POSNR
      INTO @DATA(LV_STAT).
    IF LV_STAT NE GC_C.
      LV_CHK = GC_X.
      EXIT.
    ENDIF.
    CLEAR LV_STAT.
  ENDLOOP.
  IF LV_CHK IS INITIAL.
    GV_ERROR = GC_X.
    MESSAGE S000 WITH TEXT-M05 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

*-03. 당월조장수 존재시 당월매출일 필수
  LOOP AT GT_0200 INTO LS_0200 WHERE FACTOR_M > 0.
    LV_CHK2 = GC_X.
    EXIT.
  ENDLOOP.
  IF LV_CHK2 EQ GC_X AND ZGTSDS0020-FKDAT_M IS INITIAL.
    GV_ERROR = GC_X.
    MESSAGE S000 WITH TEXT-M52 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.


*-04. 적송조장수 관련 에러건
  IF LINE_EXISTS( GT_0210[ RSLT = GC_E ] ).
    GV_ERROR = GC_X.
    MESSAGE S000 WITH TEXT-M06 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

*-----------------------------------------------------------------
*  READ TABLE GT_0200 INTO DATA(LS_0200) WITH KEY SEL = GC_X.
*
**-02. 적송지정 완료
*  SELECT SINGLE ZZJS_ASN_STS_I
*    FROM ZGTSDT9120
*   WHERE VBELN EQ @LS_0200-VBELN
*     AND POSNR EQ @LS_0200-POSNR
*    INTO @DATA(LV_STAT).
*  IF LV_STAT EQ GC_C.
*    GV_ERROR = GC_X.
*    MESSAGE S000 WITH TEXT-M05 DISPLAY LIKE GC_E.
*    EXIT.
*  ENDIF.
*
**-03. 적송조장수 관련 에러건
*  IF LINE_EXISTS( GT_0210[ RSLT = GC_E ] ).
*    GV_ERROR = GC_X.
*    MESSAGE S000 WITH TEXT-M06 DISPLAY LIKE GC_E.
*    EXIT.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ASSIGN_JS_DATA_SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ASSIGN_JS_DATA_SAVE .
  DATA: LV_H(1),
        LV_CHK1,
        LV_CHK2,
        LV_CHK_FKDAT(1),
        LV_MSG(100),
        LV_SUBRC    TYPE SY-SUBRC,
        LV_STSH     TYPE ZGTSDT9110-ZZJS_ASN_STS_H.

  DATA: LV_STAT     TYPE ZGTSDT9120-ZZJS_ASN_STS_I.
  DATA: LV_FKDAT_M TYPE ZGTSDS0020-FKDAT_M.

  DATA: LT_ITEM_SAVE TYPE TABLE OF ZGTSDT9120.

  DATA(LS_LINE) = VALUE #( GT_0200[ 1 ] OPTIONAL ).

*-01. 데이터 발췌
* HEADER
  SELECT SINGLE *
    FROM ZGTSDT9110
   WHERE VBELN EQ @LS_LINE-VBELN
     INTO @DATA(LS_HEAD).

* ITEM
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN EQ @LS_LINE-VBELN
*     AND ( POSNR EQ @LS_0200-POSNR OR
*           UECHA EQ @LS_0200-POSNR    )
    INTO TABLE @DATA(LT_ITEM).


  LOOP AT GT_0200 ASSIGNING FIELD-SYMBOL(<FS_0200>) WHERE SEL EQ GC_X.
*-01. 적송지정 상태
    CLEAR:LV_STAT.
    SELECT SINGLE ZZJS_ASN_STS_I
      FROM ZGTSDT9120
     WHERE VBELN EQ @<FS_0200>-VBELN
       AND POSNR EQ @<FS_0200>-POSNR
      INTO @LV_STAT.

    IF LV_STAT EQ GC_C. "적송지정 완료
      "당월조장수 => 당월매출일자 지정 결정(아이템중 당월조장수가 있는건은 당월매출일자 지정)
      IF <FS_0200>-FACTOR_M > 0.
        LV_CHK_FKDAT = GC_X.
      ENDIF.
      CONTINUE.
    ENDIF.


*-02. 적송지정 데이터 지정
    "MAIN ITEM
    READ TABLE LT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>) WITH KEY POSNR = <FS_0200>-POSNR.
    IF SY-SUBRC EQ 0.
      "상태
      <FS_ITEM>-ZZJS_ASN_STS_I   = GC_C.
      "당월조장수
      <FS_ITEM>-MILLCA_FACTOR_M  = <FS_0200>-FACTOR_M.
      "적송조장수
      <FS_ITEM>-MILLCA_FACTOR_JS = <FS_0200>-FACTOR_JS.

      APPEND <FS_ITEM> TO LT_ITEM_SAVE.

      "당월조장수 => 당월매출일자 지정 결정(아이템중 당월조장수가 있는건은 당월매출일자 지정)
      IF <FS_0200>-FACTOR_M > 0.
        LV_CHK_FKDAT = GC_X.
      ENDIF.
    ENDIF.

    "SUB ITEM
    LOOP AT GT_0210 INTO DATA(LS_0210) WHERE POSNR EQ <FS_0200>-POSNR.
      LOOP AT LT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM10>) WHERE POSNR = LS_0210-POSNR_B
                                                            AND UECHA = LS_0210-POSNR.
        "상태
        <FS_ITEM10>-ZZJS_ASN_STS_I   = GC_C.
        "당월조장수
        <FS_ITEM10>-MILLCA_FACTOR_M  = LS_0210-FACTOR_M.
        "적송조장수
        <FS_ITEM10>-MILLCA_FACTOR_JS = LS_0210-FACTOR_JS.

        APPEND <FS_ITEM10> TO LT_ITEM_SAVE.
      ENDLOOP.
    ENDLOOP.


  ENDLOOP.

  SORT LT_ITEM_SAVE BY VBELN POSNR.

*-03. ITEM 라인의 상태 체크 => 모든라인이 'C' => 헤더 'C'
  LOOP AT LT_ITEM INTO DATA(LS_ITEM) WHERE UECHA = '000000'.
    CASE LS_ITEM-ZZJS_ASN_STS_I.
      WHEN GC_C.
        LV_CHK1 = GC_X.
      WHEN OTHERS.
        LV_CHK2 = GC_X.
    ENDCASE.
  ENDLOOP.

  IF LV_CHK1 IS INITIAL AND
     LV_CHK2 IS INITIAL.
    CLEAR LV_STSH.
  ELSE.
    IF LV_CHK1 IS NOT INITIAL AND
       LV_CHK2 IS INITIAL.
      LV_STSH = GC_C.   "지정완료
    ELSE.
      LV_STSH = GC_B.   "부분완료
    ENDIF.
  ENDIF.

  "당월매출일자 지정 결정(아이템중 당월조장수가 있는건은 당월매출일자 지정)
  IF LV_CHK_FKDAT = GC_X.
    LV_FKDAT_M = ZGTSDS0020-FKDAT_M.
  ELSE.
    CLEAR LV_FKDAT_M.
  ENDIF.

*-04. 저장
  LV_SUBRC = 0.

  "적송처리 DO 헤더
  IF LS_HEAD-ZZJS_ASN_STS_H NE LV_STSH OR
     LS_HEAD-FKDAT_M NE LV_FKDAT_M.
    UPDATE ZGTSDT9110 SET ZZJS_ASN_STS_H = LV_STSH
                          FKDAT_M        = LV_FKDAT_M "ZGTSDS0020-FKDAT_M
                    WHERE VBELN EQ LS_HEAD-VBELN.
    IF SY-SUBRC NE 0.
      LV_SUBRC = 4.
      LV_MSG = TEXT-003.
    ENDIF.
  ENDIF.

  "적송처리 DO 아이템
  IF LV_SUBRC EQ 0 AND LT_ITEM_SAVE[] IS NOT INITIAL.
    MODIFY ZGTSDT9120 FROM TABLE LT_ITEM_SAVE.
    IF SY-SUBRC NE 0.
      LV_SUBRC = 4.
      LV_MSG = TEXT-004.
    ENDIF.
  ENDIF.

  IF LV_SUBRC EQ 0.
    COMMIT WORK AND WAIT.

    "헤더 스크린 필드
    ZGTSDS0020-ZZJS_ASN_STS_H = LV_STSH.
    ZGTSDS0020-CH_FLAG        = GC_X.

    "ITEM/세부 라인 재구성
    CLEAR GT_0210[].
    LOOP AT GT_0200 ASSIGNING <FS_0200> WHERE SEL EQ GC_X.
      "상태
      <FS_0200>-ZZJS_ASN_STS_I  = GC_C.
      PERFORM SET_LED_ITEM CHANGING <FS_0200>.
      PERFORM SET_ITEM_SAVE_AFTER USING <FS_0200>.
    ENDLOOP.

    PERFORM REFRESH_ALV USING GO_GRID1.
    PERFORM REFRESH_ALV USING GO_GRID2.

    MESSAGE S011 DISPLAY LIKE GC_S.

  ELSE.
    ROLLBACK WORK.

    MESSAGE I000 WITH LV_MSG TEXT-M07 DISPLAY LIKE GC_E.
  ENDIF.



*-----------------------------------------------------------------------
*  READ TABLE GT_0200 ASSIGNING FIELD-SYMBOL(<FS_0200>) WITH KEY SEL = GC_X.
*
**-01. 데이터 발췌
**-HEADER
*  SELECT SINGLE *
*    FROM ZGTSDT9110
*   WHERE VBELN EQ @<FS_0200>-VBELN
*     INTO @DATA(LS_HEAD).
*
**-ITEM
*  SELECT *
*    FROM ZGTSDT9120
*   WHERE VBELN EQ @<FS_0200>-VBELN
**     AND ( POSNR EQ @LS_0200-POSNR OR
**           UECHA EQ @LS_0200-POSNR    )
*    INTO TABLE @DATA(LT_ITEM).
*
**-02. 적송지정 데이터 지정
*  READ TABLE LT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>) WITH KEY POSNR = <FS_0200>-POSNR.
*  "상태
*  <FS_ITEM>-ZZJS_ASN_STS_I  = GC_C.
*  "당월조장수
*  <FS_ITEM>-MILLCA_FACTOR_M = <FS_0200>-FACTOR_M.
*  "적송조장수
*  <FS_ITEM>-MILLCA_FACTOR_JS = <FS_0200>-FACTOR_JS.
*
*
*  LOOP AT GT_0210 INTO DATA(LS_0210).
*    LOOP AT LT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM10>) WHERE POSNR = LS_0210-POSNR_B
*                                                          AND UECHA = LS_0210-POSNR.
*      "상태
*      <FS_ITEM10>-ZZJS_ASN_STS_I  = GC_C.
*      "당월조장수
*      <FS_ITEM10>-MILLCA_FACTOR_M = LS_0210-FACTOR_M.
*      "적송조장수
*      <FS_ITEM10>-MILLCA_FACTOR_JS = LS_0210-FACTOR_JS.
*    ENDLOOP.
*  ENDLOOP.
*
**-03. ITEM 라인의 상태 체크 => 모든라인이 'C' => 헤더 'C'
*  LOOP AT LT_ITEM INTO DATA(LS_ITEM) WHERE UECHA = '000000'.
*    CASE LS_ITEM-ZZJS_ASN_STS_I.
*      WHEN GC_C.
*        LV_CHK1 = GC_X.
*      WHEN OTHERS.
*        LV_CHK2 = GC_X.
*    ENDCASE.
*  ENDLOOP.
*
*  IF LV_CHK1 IS INITIAL AND
*     LV_CHK2 IS INITIAL.
*    CLEAR LV_STSH.
*  ELSE.
*    IF LV_CHK1 IS NOT INITIAL AND
*       LV_CHK2 IS INITIAL.
*      LV_STSH = GC_C.   "지정완료
*    ELSE.
*      LV_STSH = GC_B.   "부분완료
*    ENDIF.
*  ENDIF.
*
*
*  "선택 아이템 외 항목 제거
*  DATA(LT_TEMP) = LT_ITEM[].
*  CLEAR LT_ITEM[].
*  LOOP AT LT_TEMP INTO DATA(LS_TEMP) WHERE POSNR = <FS_0200>-POSNR
*                                        OR UECHA = <FS_0200>-POSNR.
*    APPEND LS_TEMP TO LT_ITEM.
*  ENDLOOP.
*  SORT LT_ITEM BY VBELN POSNR.
*
**-04. 저장
*  LV_SUBRC = 0.
*
*  "적송처리 DO 헤더
*  IF LS_HEAD-ZZJS_ASN_STS_H NE LV_STSH.
*    UPDATE ZGTSDT9110 SET ZZJS_ASN_STS_H = LV_STSH
*                    WHERE VBELN EQ LS_HEAD-VBELN.
*    IF SY-SUBRC NE 0.
*      LV_SUBRC = 4.
*      LV_MSG = TEXT-003.
*    ENDIF.
*  ENDIF.
*
*  "적송처리 DO 아이템
*  IF LV_SUBRC EQ 0 AND LT_ITEM[] IS NOT INITIAL.
*    MODIFY ZGTSDT9120 FROM TABLE LT_ITEM.
*    IF SY-SUBRC NE 0.
*      LV_SUBRC = 4.
*      LV_MSG = TEXT-004.
*    ENDIF.
*  ENDIF.
*
*  IF LV_SUBRC EQ 0.
*    COMMIT WORK AND WAIT.
*
*    "헤더 스크린 필드
*    ZGTSDS0020-ZZJS_ASN_STS_H = LV_STSH.
*    ZGTSDS0020-CH_FLAG        = GC_X.
*
*    "ITEM/세부 라인 재구성
*    "상태
*    <FS_0200>-ZZJS_ASN_STS_I  = GC_C.
*    PERFORM SET_LED_ITEM CHANGING <FS_0200>.
*    PERFORM SET_ITEM_SAVE_AFTER USING <FS_0200>.
*
*    MESSAGE S011 DISPLAY LIKE GC_S.
*
*  ELSE.
*    ROLLBACK WORK.
*
*    MESSAGE I000 WITH LV_MSG TEXT-M07 DISPLAY LIKE GC_E.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_0200>
*&---------------------------------------------------------------------*
FORM SET_LED_ITEM  CHANGING PS_0200 LIKE GT_0200.
  CASE PS_0200-ZZJS_ASN_STS_I.
    WHEN GC_C.
      PS_0200-ST_STSI = ICON_LED_GREEN.
    WHEN OTHERS.
      PS_0200-ST_STSI = ICON_LED_YELLOW.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITEM_SAVE_AFTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_0200>
*&---------------------------------------------------------------------*
FORM SET_ITEM_SAVE_AFTER  USING    PS_0200 LIKE GT_0200.

*-ITEM 세부라인 구성
  CLEAR: GT_0210_LIST[].
  PERFORM CLEAR_ITEM_FIELDS CHANGING PS_0200.
  PERFORM SET_ITEM_DETAILS CHANGING PS_0200.

  APPEND LINES OF GT_0210_LIST TO GT_0210.
  SORT GT_0210 BY POSNR POSNR_B.

  LOOP AT GT_0210 ASSIGNING FIELD-SYMBOL(<FS_0210>).
    PERFORM SET_ATTRIBUTES_LINE_0210 CHANGING <FS_0210>.
  ENDLOOP.

*  PERFORM REFRESH_ALV USING GO_GRID1.
*  PERFORM REFRESH_ALV USING GO_GRID2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR_ITEM_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_0200
*&---------------------------------------------------------------------*
FORM CLEAR_ITEM_FIELDS  CHANGING PS_0200 LIKE GT_0200.
  CLEAR:PS_0200-LFIMG,      "DO 수량
        PS_0200-FACTOR_I,   "최초 조장수
        PS_0200-FACTOR_M,   "당월 조장수
        PS_0200-FACTOR_JS.  "적송 조장수
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOUBLE_CLICK_FIELD_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK_FIELD_0200 .
  DATA: LV_FIELD(30),
        LV_LINE TYPE I.

  GET CURSOR FIELD LV_FIELD LINE LV_LINE.

  CASE LV_FIELD.
    WHEN 'ZGTSDS0020-VBELN'."납품번호
      IF ZGTSDS0020-VBELN IS NOT INITIAL.
        SET PARAMETER ID 'VL' FIELD ZGTSDS0020-VBELN.
        CALL TRANSACTION 'VL03N' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      ENDIF.
    WHEN OTHERS.


  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UNASSIGN_JS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM UNASSIGN_JS_DATA .

  PERFORM CHECK_CHANGED_DATA USING GO_GRID1.

*-01.CHECK
  CLEAR GV_ERROR.
  PERFORM CHECK_DATA_CNACEL_0200.
  IF GV_ERROR IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-P02 ) EQ GC_J.

*-02. 적송지정 저장
  PERFORM UNASSIGN_JS_DATA_SAVE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA_CNACEL_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_DATA_CNACEL_0200 .
  DATA: LV_CHK_FINAL(1),
        LV_CHK_STAT(1),
        LV_CHK_STAT_I(1).

*-01. ITEM LINE 선택
  IF NOT ( LINE_EXISTS( GT_0200[ SEL = GC_X ] ) ).
    GV_ERROR = GC_X.
    MESSAGE S000 WITH TEXT-M08 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  LOOP AT GT_0200 INTO DATA(LS_0200) WHERE SEL EQ GC_X.
*-02. 적송처리 완료
    SELECT SINGLE ZZJS_FINAL,ZZJS_STATUS
      FROM ZGTSDT9110
     WHERE VBELN EQ @LS_0200-VBELN
      INTO ( @DATA(LV_FINAL),@DATA(LV_STATUS) ).
    IF LV_FINAL EQ GC_X.
      LV_CHK_FINAL = GC_X.
      EXIT.
    ENDIF.

    IF LV_STATUS >= GC_B.
      LV_CHK_STAT = GC_X.
      EXIT.
    ENDIF.

*-03. 적송지정 완료
    SELECT SINGLE ZZJS_ASN_STS_I
      FROM ZGTSDT9120
     WHERE VBELN EQ @LS_0200-VBELN
       AND POSNR EQ @LS_0200-POSNR
      INTO @DATA(LV_STAT).
    IF LV_STAT EQ GC_C.
      LV_CHK_STAT_I = GC_X.
      EXIT.
    ENDIF.
  ENDLOOP.

  "적송처리 완료
  IF LV_CHK_FINAL = GC_X.
    GV_ERROR = GC_X.
    MESSAGE S000 WITH TEXT-M10 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  "적송진행중
  IF LV_CHK_STAT = GC_X.
    GV_ERROR = GC_X.
    MESSAGE S000 WITH TEXT-M11 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

  "적송지정건 없음
  IF LV_CHK_STAT_I NE GC_X.
    GV_ERROR = GC_X.
    MESSAGE S000 WITH TEXT-M09 DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.

*---------------------------------------------------------------
*  READ TABLE GT_0200 INTO DATA(LS_0200) WITH KEY SEL = GC_X.
*
**-02. 적송처리 완료
*  SELECT SINGLE ZZJS_FINAL,ZZJS_STATUS
*    FROM ZGTSDT9110
*   WHERE VBELN EQ @LS_0200-VBELN
*    INTO ( @DATA(LV_FINAL),@DATA(LV_STATUS) ).
*  IF LV_FINAL EQ GC_X.
*    GV_ERROR = GC_X.
*    MESSAGE S000 WITH TEXT-M10 DISPLAY LIKE GC_E.
*    EXIT.
*  ENDIF.
*
*  IF LV_STATUS >= GC_B.
*    GV_ERROR = GC_X.
*    MESSAGE S000 WITH TEXT-M11 DISPLAY LIKE GC_E.
*    EXIT.
*  ENDIF.
*
**-03. 적송지정 완료
*  SELECT SINGLE ZZJS_ASN_STS_I
*    FROM ZGTSDT9120
*   WHERE VBELN EQ @LS_0200-VBELN
*     AND POSNR EQ @LS_0200-POSNR
*    INTO @DATA(LV_STAT).
*  IF LV_STAT NE GC_C.
*    GV_ERROR = GC_X.
*    MESSAGE S000 WITH TEXT-M09 DISPLAY LIKE GC_E.
*    EXIT.
*  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form UNASSIGN_JS_DATA_SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM UNASSIGN_JS_DATA_SAVE .
  DATA: LV_H(1),
        LV_CHK1,
        LV_CHK2,
        LV_MSG(100),
        LV_SUBRC    TYPE SY-SUBRC,
        LV_STSH     TYPE ZGTSDT9110-ZZJS_ASN_STS_H.

  DATA: LV_STAT     TYPE ZGTSDT9120-ZZJS_ASN_STS_I.

  DATA: LV_FKDAT_M TYPE ZGTSDS0020-FKDAT_M.

  DATA: LT_ITEM_SAVE TYPE TABLE OF ZGTSDT9120.

  DATA(LS_LINE) = VALUE #( GT_0200[ 1 ] OPTIONAL ).

*-01. 데이터 발췌
*   HEADER
  SELECT SINGLE *
    FROM ZGTSDT9110
   WHERE VBELN EQ @LS_LINE-VBELN
     INTO @DATA(LS_HEAD).
  LV_FKDAT_M = LS_HEAD-FKDAT_M.

*   ITEM
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN EQ @LS_LINE-VBELN
*     AND ( POSNR EQ @LS_0200-POSNR OR
*           UECHA EQ @LS_0200-POSNR    )
    INTO TABLE @DATA(LT_ITEM).


  LOOP AT GT_0200 ASSIGNING FIELD-SYMBOL(<FS_0200>) WHERE SEL EQ GC_X.
*-01. 적송지정 상태
    CLEAR:LV_STAT.
    SELECT SINGLE ZZJS_ASN_STS_I
      FROM ZGTSDT9120
     WHERE VBELN EQ @<FS_0200>-VBELN
       AND POSNR EQ @<FS_0200>-POSNR
      INTO @LV_STAT.

    IF LV_STAT NE GC_C. "적송지정 완료
      CONTINUE.
    ENDIF.

*-02. 적송지정 해제
    "MAIN ITEM
    READ TABLE LT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>) WITH KEY POSNR = <FS_0200>-POSNR.
    "상태
    CLEAR <FS_ITEM>-ZZJS_ASN_STS_I.
    "당월조장수
    CLEAR <FS_ITEM>-MILLCA_FACTOR_M.
    "적송조장수
    CLEAR <FS_ITEM>-MILLCA_FACTOR_JS.

    APPEND <FS_ITEM> TO LT_ITEM_SAVE.

    "SUB ITEM
    LOOP AT GT_0210 INTO DATA(LS_0210) WHERE POSNR EQ <FS_0200>-POSNR.
      LOOP AT LT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM10>) WHERE POSNR = LS_0210-POSNR_B
                                                            AND UECHA = LS_0210-POSNR.
        "상태
        CLEAR <FS_ITEM10>-ZZJS_ASN_STS_I.
        "당월조장수
        CLEAR <FS_ITEM10>-MILLCA_FACTOR_M.
        "적송조장수
        CLEAR <FS_ITEM10>-MILLCA_FACTOR_JS.

        APPEND <FS_ITEM10> TO LT_ITEM_SAVE.
      ENDLOOP.
    ENDLOOP.

  ENDLOOP.

  SORT LT_ITEM_SAVE BY VBELN POSNR.

*-03. ITEM 라인의 상태 체크 => 모든라인이 'C' => 헤더 'C'
  LOOP AT LT_ITEM INTO DATA(LS_ITEM) WHERE UECHA = '000000'.
    CASE LS_ITEM-ZZJS_ASN_STS_I.
      WHEN GC_C.
        LV_CHK1 = GC_X.
      WHEN OTHERS.
        LV_CHK2 = GC_X.
    ENDCASE.
  ENDLOOP.

  CASE LV_CHK1.
    WHEN GC_X.
      CASE LV_CHK2.
        WHEN GC_X.
          LV_STSH = GC_B.   "부분완료
        WHEN OTHERS.
          LV_STSH = GC_C.   "지정완료
      ENDCASE.

    WHEN OTHERS.
      CASE LV_CHK2.
        WHEN GC_X.
          CLEAR LV_STSH.
        WHEN OTHERS.
          CLEAR LV_STSH.
      ENDCASE.
  ENDCASE.

  "당월매출일
  IF LV_STSH IS INITIAL.
    CLEAR LV_FKDAT_M.
  ENDIF.

*-04. 저장
  LV_SUBRC = 0.

  "적송처리 DO 헤더
  IF LS_HEAD-ZZJS_ASN_STS_H NE LV_STSH.
    UPDATE ZGTSDT9110 SET ZZJS_ASN_STS_H = LV_STSH
                          FKDAT_M        = LV_FKDAT_M
                    WHERE VBELN EQ LS_HEAD-VBELN.
    IF SY-SUBRC NE 0.
      LV_SUBRC = 4.
      LV_MSG = TEXT-003.
    ENDIF.
  ENDIF.

  "적송처리 DO 아이템
  IF LV_SUBRC EQ 0 AND LT_ITEM_SAVE[] IS NOT INITIAL.
    MODIFY ZGTSDT9120 FROM TABLE LT_ITEM_SAVE.
    IF SY-SUBRC NE 0.
      LV_SUBRC = 4.
      LV_MSG = TEXT-004.
    ENDIF.
  ENDIF.

  IF LV_SUBRC EQ 0.
    COMMIT WORK AND WAIT.

    "헤더 스크린 필드
    ZGTSDS0020-ZZJS_ASN_STS_H = LV_STSH.
    ZGTSDS0020-CH_FLAG        = GC_X.

    "당월매출일 일자 지정
    PERFORM SET_FKDAT_M2.

    "ITEM/세부 라인 재구성
    CLEAR GT_0210[].
    LOOP AT GT_0200 ASSIGNING <FS_0200> WHERE SEL EQ GC_X.
      "상태
      CLEAR <FS_0200>-ZZJS_ASN_STS_I.
      PERFORM SET_LED_ITEM        CHANGING <FS_0200>.
      PERFORM SET_ITEM_SAVE_AFTER USING <FS_0200>.
    ENDLOOP.

    PERFORM REFRESH_ALV USING GO_GRID1.
    PERFORM REFRESH_ALV USING GO_GRID2.

    MESSAGE S011 DISPLAY LIKE GC_S.

  ELSE.
    ROLLBACK WORK.

    MESSAGE I000 WITH LV_MSG TEXT-M07 DISPLAY LIKE GC_E.
  ENDIF.


*-------------------------------------------------------------------------------
*  READ TABLE GT_0200 ASSIGNING FIELD-SYMBOL(<FS_0200>) WITH KEY SEL = GC_X.
*
**-01. 데이터 발췌
**-HEADER
*  SELECT SINGLE *
*    FROM ZGTSDT9110
*   WHERE VBELN EQ @<FS_0200>-VBELN
*     INTO @DATA(LS_HEAD).
*
**-ITEM
*  SELECT *
*    FROM ZGTSDT9120
*   WHERE VBELN EQ @<FS_0200>-VBELN
**     AND ( POSNR EQ @LS_0200-POSNR OR
**           UECHA EQ @LS_0200-POSNR    )
*    INTO TABLE @DATA(LT_ITEM).
*
**-02. 적송지정 데이터 지정
*  READ TABLE LT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>) WITH KEY POSNR = <FS_0200>-POSNR.
*  "상태
*  CLEAR <FS_ITEM>-ZZJS_ASN_STS_I.
*  "당월조장수
*  CLEAR <FS_ITEM>-MILLCA_FACTOR_M.
*  "적송조장수
*  CLEAR <FS_ITEM>-MILLCA_FACTOR_JS.
*
*
*  LOOP AT GT_0210 INTO DATA(LS_0210).
*    LOOP AT LT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM10>) WHERE POSNR = LS_0210-POSNR_B
*                                                          AND UECHA = LS_0210-POSNR.
*      "상태
*      CLEAR <FS_ITEM10>-ZZJS_ASN_STS_I.
*      "당월조장수
*      CLEAR <FS_ITEM10>-MILLCA_FACTOR_M.
*      "적송조장수
*      CLEAR <FS_ITEM10>-MILLCA_FACTOR_JS.
*    ENDLOOP.
*  ENDLOOP.
*
**-03. ITEM 라인의 상태 체크 => 모든라인이 'C' => 헤더 'C'
*  LOOP AT LT_ITEM INTO DATA(LS_ITEM) WHERE UECHA = '000000'.
*    CASE LS_ITEM-ZZJS_ASN_STS_I.
*      WHEN GC_C.
*        LV_CHK1 = GC_X.
*      WHEN OTHERS.
*        LV_CHK2 = GC_X.
*    ENDCASE.
*  ENDLOOP.
*
*  IF LV_CHK1 IS INITIAL AND
*     LV_CHK2 IS INITIAL.
*    CLEAR LV_STSH.
*  ELSE.
*    IF LV_CHK1 IS NOT INITIAL AND
*       LV_CHK2 IS INITIAL.
*      LV_STSH = GC_C.   "지정완료
*    ELSE.
*      LV_STSH = GC_B.   "부분완료
*    ENDIF.
*  ENDIF.
*
*
*  "선택 아이템 외 항목 제거
*  DATA(LT_TEMP) = LT_ITEM[].
*  CLEAR LT_ITEM[].
*  LOOP AT LT_TEMP INTO DATA(LS_TEMP) WHERE POSNR = <FS_0200>-POSNR
*                                        OR UECHA = <FS_0200>-POSNR.
*    APPEND LS_TEMP TO LT_ITEM.
*  ENDLOOP.
*  SORT LT_ITEM BY VBELN POSNR.
*
**-04. 저장
*  LV_SUBRC = 0.
*
*  "적송처리 DO 헤더
*  IF LS_HEAD-ZZJS_ASN_STS_H NE LV_STSH.
*    UPDATE ZGTSDT9110 SET ZZJS_ASN_STS_H = LV_STSH
*                    WHERE VBELN EQ LS_HEAD-VBELN.
*    IF SY-SUBRC NE 0.
*      LV_SUBRC = 4.
*      LV_MSG = TEXT-003.
*    ENDIF.
*  ENDIF.
*
*  "적송처리 DO 아이템
*  IF LV_SUBRC EQ 0 AND LT_ITEM[] IS NOT INITIAL.
*    MODIFY ZGTSDT9120 FROM TABLE LT_ITEM.
*    IF SY-SUBRC NE 0.
*      LV_SUBRC = 4.
*      LV_MSG = TEXT-004.
*    ENDIF.
*  ENDIF.
*
*  IF LV_SUBRC EQ 0.
*    COMMIT WORK AND WAIT.
*
*    "헤더 스크린 필드
*    ZGTSDS0020-ZZJS_ASN_STS_H = LV_STSH.
*    ZGTSDS0020-CH_FLAG        = GC_X.
*
*    "ITEM/세부 라인 재구성
*    "상태
*    CLEAR <FS_0200>-ZZJS_ASN_STS_I.
*    PERFORM SET_LED_ITEM CHANGING <FS_0200>.
*    PERFORM SET_ITEM_SAVE_AFTER USING <FS_0200>.
*
*    MESSAGE S011 DISPLAY LIKE GC_S.
*
*  ELSE.
*    ROLLBACK WORK.
*
*    MESSAGE I000 WITH LV_MSG TEXT-M07 DISPLAY LIKE GC_E.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REBUILD_LIST_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REBUILD_LIST_0100 .

  CLEAR:GT_0100[].
*-01. GET DATA
  PERFORM GET_DATA.

*-02. MAKE LIST
  PERFORM MAKE_LIST.

  PERFORM REFRESH_ALV USING GO_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATED_DO_LIST_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_0100
*&---------------------------------------------------------------------*
FORM CREATED_DO_LIST_DISPLAY  USING    PS_0100 LIKE GT_0100.

  DATA: LS_0900 LIKE GT_0900.

  CLEAR: GT_0900[].

  CHECK PS_0100-ZZJS_STATUS >= GC_I. "신규 DO 생성

*-ZGTSDT9120
  SELECT *
    FROM ZGTSDT9120
   WHERE VBELN EQ @PS_0100-VBELN_VL
    INTO TABLE @DATA(LT_ZGTSDT9120).
  SORT LT_ZGTSDT9120 BY VBELN POSNR VGBEL VGPOS.
  DELETE ADJACENT DUPLICATES FROM LT_ZGTSDT9120
                        COMPARING VBELN POSNR VGBEL VGPOS.

  CHECK LT_ZGTSDT9120[] IS NOT INITIAL.

*-ZLF,ZLF3
  SELECT A~VBELN,A~POSNR,A~UECHA,A~MATNR,A~WERKS,A~LGORT,
         A~LFIMG,A~VRKME,A~VGBEL,A~VGPOS,

         B~LFART,
         B~KUNAG AS KUNNR, "판매처
         B~KUNNR AS KUNWE, "납품처
         B~WAERK,B~WADAT_IST,

         C~NETPR

    FROM LIPS AS A INNER JOIN LIKP AS B
                   ON A~VBELN = B~VBELN
                   INNER JOIN VBAP AS C
                   ON A~VGBEL = C~VBELN AND
                      A~VGPOS = C~POSNR

     FOR ALL ENTRIES IN @LT_ZGTSDT9120
   WHERE A~ZZVBELN_JS EQ @LT_ZGTSDT9120-VBELN
     AND A~ZZPOSNR_JS EQ @LT_ZGTSDT9120-POSNR
     AND A~VGBEL      EQ @LT_ZGTSDT9120-VGBEL
     AND A~VGPOS      EQ @LT_ZGTSDT9120-VGPOS
     AND B~LFART      IN ( @GC_LFART_ZLF, @GC_LFART_ZLF3 )
    INTO TABLE @DATA(LT_LIST).

  CHECK LT_LIST[] IS NOT INITIAL.

  DATA(LT_HEAD) = LT_LIST[].
  SORT LT_HEAD BY VBELN VGBEL.
  DELETE ADJACENT DUPLICATES FROM LT_HEAD COMPARING VBELN VGBEL.

*-LIST 구성
  LOOP AT LT_HEAD INTO DATA(LS_HEAD).
    CLEAR LS_0900.

    LS_0900-VBELN_VL  = LS_HEAD-VBELN.
    LS_0900-VBELN_VA  = LS_HEAD-VGBEL.
    LS_0900-LFART     = LS_HEAD-LFART.
    LS_0900-KUNNR     = LS_HEAD-KUNNR.
    LS_0900-WAERK     = LS_HEAD-WAERK.
    LS_0900-KUNWE     = LS_HEAD-KUNWE.
    LS_0900-WADAT_IST = LS_HEAD-WADAT_IST.

    "납품유형
    IF LS_0900-LFART IS NOT INITIAL.
      LS_0900-LFART_NM = ZGTSD_CL_COMMON2=>GET_LFART_TEXT( IV_LFART = LS_0900-LFART
                                                           IV_SPRAS = SY-LANGU      ).
    ENDIF.
    "판매처
    IF LS_0900-KUNNR IS NOT INITIAL.
      LS_0900-KUNNR_NM = ZGTSD_CL_COMMON2=>GET_KUNNR_TEXT( IV_KUNNR = LS_0900-KUNNR ).
    ENDIF.
    "납품처
    IF LS_0900-KUNWE IS NOT INITIAL.
      LS_0900-KUNWE_NM = ZGTSD_CL_COMMON2=>GET_KUNNR_TEXT( IV_KUNNR = LS_0900-KUNWE ).
    ENDIF.

    "금액
    LOOP AT LT_LIST INTO DATA(LS_LIST) WHERE VBELN = LS_HEAD-VBELN
                                         AND VGBEL = LS_HEAD-VGBEL.
      LS_0900-NETWR = LS_0900-NETWR +
                      ( LS_LIST-LFIMG * LS_LIST-NETPR ).
    ENDLOOP.

    APPEND LS_0900 TO GT_0900.
  ENDLOOP.

  SORT GT_0900 BY LFART VBELN_VL.

  CALL SCREEN 0900 STARTING AT 10  10
                   ENDING AT   150 15.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_ALL_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_ALL_0100 .
  CLEAR GS_0100.
  GS_0100-SEL = GC_X.
  MODIFY GT_0100 FROM GS_0100 TRANSPORTING SEL WHERE SEL EQ SPACE.

  PERFORM REFRESH_ALV USING GO_GRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DESELECT_ALL_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DESELECT_ALL_0100 .
  CLEAR GS_0100.

  MODIFY GT_0100 FROM GS_0100 TRANSPORTING SEL WHERE SEL EQ GC_X.

  PERFORM REFRESH_ALV USING GO_GRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED_JS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PS_0100
*&---------------------------------------------------------------------*
FORM SET_LED_JS     USING PV_STATUS
                 CHANGING PS_0100 LIKE GT_0100.
  DATA:LV_TEXT(20).
  DATA:LV_FINAL(1).

  DATA(LS_CODE) = VALUE #( GT_CODE[ CODE = PV_STATUS ] OPTIONAL ).

  LV_TEXT = |ST_{ LS_CODE-STATUS }|.
  ASSIGN COMPONENT LV_TEXT OF STRUCTURE PS_0100 TO FIELD-SYMBOL(<FS_VAL>).
  CHECK SY-SUBRC EQ 0.

  IF PS_0100-RSLT_PROC EQ GC_E.
    PS_0100-STAT = ICON_LED_RED.
    <FS_VAL> = ICON_LED_RED.
  ELSE.
    CLEAR PS_0100-STAT.
    <FS_VAL> = ICON_LED_GREEN.

    "DB UPDATE

    "당월출고분(ZLF)가 없는경우 신규 DO에 배치지정이 완료되면 최종완료 처리.
    IF GV_ZLF3_ONLY EQ GC_X.
      IF PV_STATUS EQ GC_J.
        LV_FINAL = GC_X.
      ELSE.
        CLEAR LV_FINAL.
      ENDIF.
    ELSE.
      IF PV_STATUS EQ GC_L.
        LV_FINAL = GC_X.
      ELSE.
        CLEAR LV_FINAL.
      ENDIF.
    ENDIF.

    UPDATE ZGTSDT9110 SET ZZJS_STATUS = PV_STATUS
                          ZZJS_FINAL  = LV_FINAL
                    WHERE VBELN EQ PS_0100-VBELN_VL.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STATUS_CODE_NEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_STAT
*&---------------------------------------------------------------------*
FORM GET_STATUS_CODE_NEXT  CHANGING PV_STAT.

  SORT GT_CODE BY CODE ASCENDING.
  LOOP AT GT_CODE INTO DATA(LS_CODE) WHERE CODE > PV_STAT.
    PV_STAT = LS_CODE-CODE.
    EXIT.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_KUNNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_KUNNR  USING    PV_FVAL PV_FNAME.
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
*& Form CHECK_CHANGED_STATUS_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_CHANGED_STATUS_0200 .
  DATA:LV_CHG(1).

  DATA(LS_LINE) = VALUE #( GT_0100[ VBELN_VL = ZGTSDS0020-VBELN ] OPTIONAL ).

  SELECT SINGLE *
    FROM ZGTSDT9110
   WHERE VBELN EQ @ZGTSDS0020-VBELN
     AND LOEVM EQ @SPACE
    INTO @DATA(LS_ZGTSDT9110).
  IF NOT ( LS_ZGTSDT9110-ZZJS_STATUS    EQ LS_LINE-ZZJS_STATUS    AND
           LS_ZGTSDT9110-ZZJS_ASN_STS_H EQ LS_LINE-ZZJS_ASN_STS_H     ).
    LV_CHG = GC_X.
  ENDIF.

  IF ZGTSDS0020-CH_FLAG EQ GC_X OR
     LV_CHG             EQ GC_X.
    PERFORM REBUILD_LIST_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITEM_LINE_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_0200>
*&---------------------------------------------------------------------*
FORM SET_ITEM_LINE_VALUE  CHANGING PS_0200 LIKE GS_0200.

  "ITEM LINE FIELD VALUE 계산
  CLEAR:PS_0200-FACTOR_M,PS_0200-FACTOR_JS.
  LOOP AT GT_0210 INTO GS_0210 WHERE POSNR EQ PS_0200-POSNR.
    "ITEM 라인의 당월조장수 : ITEM 상세라인의 SUM
    PS_0200-FACTOR_M  = PS_0200-FACTOR_M + GS_0210-FACTOR_M.
    "ITEM 라인의 적송조장수 : ITEM 상세라인의 SUM
    PS_0200-FACTOR_JS = PS_0200-FACTOR_JS + GS_0210-FACTOR_JS.
  ENDLOOP.

  "당월수량 : 당월조장수 * 조장
  PS_0200-LFIMG_M   = PS_0200-FACTOR_M * PS_0200-LENGTH_JS.
  "적송수량 : 적송조장수 * 조장
  PS_0200-LFIMG_JS  = PS_0200-FACTOR_JS * PS_0200-LENGTH_JS.
  "최초금액 :최초수량 * 단가
  PS_0200-NETWR_INI = PS_0200-LFIMG * PS_0200-NETPR.
  "당월금액 : 당월수량 * 단가
  PS_0200-NETWR_DW  = PS_0200-LFIMG_M * PS_0200-NETPR.
  "적송금액 : 적송수량 * 단가
  PS_0200-NETWR_JS  = PS_0200-LFIMG_JS * PS_0200-NETPR.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_ALL_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_ALL_0200 .
  DATA: LS_0200_BF LIKE GT_0200.

  CLEAR: GT_0210_LIST[].
  LOOP AT GT_0200 ASSIGNING FIELD-SYMBOL(<FS_0200>) WHERE SEL NE GC_X.
    <FS_0200>-SEL = GC_X.

    PERFORM CLEAR_ITEM_FIELDS CHANGING <FS_0200>.
    PERFORM SET_ITEM_DETAILS  CHANGING <FS_0200>.

  ENDLOOP.

  APPEND LINES OF GT_0210_LIST TO GT_0210.
  SORT GT_0210 BY POSNR POSNR_B.

* ITEM 세부라인 입력필드 제어
  LOOP AT GT_0210 ASSIGNING FIELD-SYMBOL(<FS_0210>).
    PERFORM SET_ATTRIBUTES_LINE_0210 CHANGING <FS_0210>.
  ENDLOOP.

  PERFORM REFRESH_ALV USING GO_GRID1. "ITEM 라인(TOP)
  PERFORM REFRESH_ALV USING GO_GRID2. "ITEM 세부라인(BOTTOM)

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DESELECT_ALL_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DESELECT_ALL_0200 .

  CLEAR: GT_0210_LIST[].
  LOOP AT GT_0200 ASSIGNING FIELD-SYMBOL(<FS_0200>) WHERE SEL EQ GC_X.
    CLEAR <FS_0200>-SEL.

    PERFORM CLEAR_ITEM_FIELDS CHANGING <FS_0200>.
    PERFORM SET_ITEM_DETAILS  CHANGING <FS_0200>.

  ENDLOOP.

  "ITEM 상세 삭제
  LOOP AT GT_0200 INTO GS_0200.
    DELETE GT_0210 WHERE POSNR = GS_0200-POSNR.
  ENDLOOP.

  PERFORM REFRESH_ALV USING GO_GRID1. "ITEM 라인(TOP)
  PERFORM REFRESH_ALV USING GO_GRID2. "ITEM 세부라인(BOTTOM)

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LOCK_OBJECT20
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_0100_VBELN_VL
*&      <-- ZGTSDS0020_LOCK
*&---------------------------------------------------------------------*
FORM SET_LOCK_OBJECT20  USING    PV_VBELN_VL
                        CHANGING PV_LOCK.

  CALL FUNCTION 'ENQUEUE_EZGT_ZGTSDT9110'
    EXPORTING
      VBELN          = PV_VBELN_VL
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.
  IF SY-SUBRC <> 0.
    CLEAR PV_LOCK.
    MESSAGE ID SY-MSGID TYPE GC_I NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
       DISPLAY LIKE GC_E.
    EXIT.
  ENDIF.
  PV_LOCK = GC_X.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_INPUT_FLAG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_INPUT_FLAG .
  IF ZGTSDS0020-LOCK IS INITIAL.
    CLEAR GV_FLAG_FKDAT.
  ELSE.
    IF ZGTSDS0020-ZZJS_ASN_STS_H EQ GC_C.
      CLEAR GV_FLAG_FKDAT.
    ELSE.
      LOOP AT GT_0200 WHERE FACTOR_M > 0.
        EXIT.
      ENDLOOP.
      IF SY-SUBRC EQ 0.
        GV_FLAG_FKDAT = GC_X.
      ELSE.
        CLEAR GV_FLAG_FKDAT.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FKDAT_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FKDAT_M .
  IF ZGTSDS0020-ZZJS_ASN_STS_H EQ GC_C. "적송지정완료

  ELSE.
    IF ZGTSDS0020-FKDAT_M IS INITIAL.
      ZGTSDS0020-FKDAT_M =
           ZGTSD_CL_COMMON2=>GET_LAST_DAY_MONTH(
                                IV_DATE = ZGTSDS0020-WADAT_IST ).
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FKDAT_M2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FKDAT_M2 .
  ZGTSDS0020-FKDAT_M =
           ZGTSD_CL_COMMON2=>GET_LAST_DAY_MONTH(
                                IV_DATE = ZGTSDS0020-WADAT_IST ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FKDAT_M_DATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FKDAT_M_DATE .
  DATA:   REACTION(1) TYPE C.
  DATA:   BEGIN OF FIELDS OCCURS 1.      "POPUP für Stornodatum
            INCLUDE STRUCTURE SVAL.
  DATA:   END OF FIELDS.
  DATA: LV_FKDAT_M TYPE ZGTSDS0020-FKDAT_M.

  CLEAR FIELDS.

  FIELDS-TABNAME     =    'SYST'.
  FIELDS-FIELDNAME   =    'DATLO'.
  FIELDS-VALUE       =    ZGTSDS0020-FKDAT_M.
  FIELDS-FIELD_ATTR  =    ' '.
  APPEND FIELDS.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      POPUP_TITLE     = TEXT-006
      START_COLUMN    = '8'
      START_ROW       = '8'
    IMPORTING
      RETURNCODE      = REACTION
    TABLES
      FIELDS          = FIELDS
    EXCEPTIONS
      ERROR_IN_FIELDS = 1
      OTHERS          = 2.
  IF REACTION NE GC_A.
    LV_FKDAT_M = VALUE #( FIELDS[ FIELDNAME = 'DATLO' ]-VALUE OPTIONAL ).
    IF LV_FKDAT_M IS NOT INITIAL AND LV_FKDAT_M NE ZGTSDS0020-FKDAT_M.
      UPDATE ZGTSDT9110 SET FKDAT_M = LV_FKDAT_M
                      WHERE VBELN EQ ZGTSDS0020-VBELN.
      COMMIT WORK AND WAIT.

      ZGTSDS0020-FKDAT_M = LV_FKDAT_M.

      MESSAGE S000 WITH TEXT-M53.
    ENDIF.
  ENDIF.

ENDFORM.
