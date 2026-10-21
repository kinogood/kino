*&---------------------------------------------------------------------*
*& Include          ZGTPPI2040F01
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


  IF GT_TARGET[] IS INITIAL.

    SELECT * FROM ZGTPPT1010
      INTO CORRESPONDING FIELDS OF TABLE GT_TARGET
     WHERE MODULE_KIND = 'PP'
        AND CODEGRP = '0010'.

  ENDIF.

  S_ERDAT-LOW = SY-DATUM.
  APPEND S_ERDAT.
  S_IFDAT-LOW = SY-DATUM.
  APPEND S_IFDAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_FIRST_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_FIRST_SCREEN .

  LOOP AT SCREEN.
    IF P_SEND = ABAP_TRUE.
      IF SCREEN-GROUP1 = 'S1'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSE.
      IF SCREEN-GROUP1 = 'S2'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_TARGET
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_TARGET  USING    PV_DYNPROFLD TYPE HELP_INFO-DYNPROFLD .

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LV_OFFSET(6) TYPE N.
  DATA : LO_FLIEF TYPE REF TO DATA.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

  FREE LO_FLIEF.
  CREATE DATA LO_FLIEF LIKE GS_TARGET.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).

    CASE <LS_FIELD_TAB>-FIELDNAME.
      WHEN 'FLD_01'.
        <LS_FIELD_TAB>-REPTEXT  = '시스템 ID'.
      WHEN 'FLD_02'.
        <LS_FIELD_TAB>-REPTEXT  = '시스템 내역'.
      WHEN 'FLD_03'.
        <LS_FIELD_TAB>-REPTEXT  = '플랜트'.
      WHEN 'FLD_04'.
        <LS_FIELD_TAB>-REPTEXT  = 'SPG(사업부)'.
    ENDCASE.

    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'FLD_01'
      DYNPROFIELD     = PV_DYNPROFLD           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '송신대상 시스템 조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = GT_TARGET                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.

    REFRESH LT_DYNPFIELDS.
    PERFORM GET_STEPL USING LV_LINE.

*      시뮬레이션 번호
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
    <LS_DYNPFIELDS>-FIELDNAME = PV_DYNPROFLD.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_RETURN_TAB-FIELDVAL.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME               = SY-CPROG
        DYNUMB               = SY-DYNNR
      TABLES
        DYNPFIELDS           = LT_DYNPFIELDS
      EXCEPTIONS
        INVALID_ABAPWORKAREA = 1
        INVALID_DYNPROFIELD  = 2
        INVALID_DYNPRONAME   = 3
        INVALID_DYNPRONUMMER = 4
        INVALID_REQUEST      = 5
        NO_FIELDDESCRIPTION  = 6
        UNDEFIND_ERROR       = 7
        OTHERS               = 8.
    IF SY-SUBRC <> 0.
    ENDIF.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STEPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_LINE
*&---------------------------------------------------------------------*
FORM GET_STEPL  USING    PV_LINE LIKE SY-STEPL.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = PV_LINE
    EXCEPTIONS
      STEPL_NOT_FOUND = 01.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PROC .

  IF P_SEND EQ ABAP_TRUE.
    PERFORM GET_TABLE_RECORD.
  ELSE.
    PERFORM GET_HISTORY_OF_SEND.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESSING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESSING .

  DATA : LV_LINES_C TYPE C LENGTH 10.

  IF P_SEND EQ ABAP_TRUE.
    IF P_BATCH EQ ABAP_TRUE. " 배치수행, 화면 출력없이 전송
      .
      PERFORM MAKE_SEND_DATA.
      PERFORM PROC_CALL_RFC.

      IF LINE_EXISTS( GT_MAIN_DISP_100[ ZSTAT = '00' ] ) OR
          LINE_EXISTS( GT_MAIN_DISP_100[ ZSTAT = '0' ] ). " 성공시
        DATA(LV_INDEX) = LINES( GT_SGRPNR ) .
        LV_LINES_C = LV_INDEX.
        CONDENSE LV_LINES_C.
        MESSAGE S000 WITH LV_LINES_C '건의 묶음오더 정보가 전송되었습니다.'.
      ELSE.
        MESSAGE S003 WITH '전송 데이터가 없습니다.' DISPLAY LIKE 'E'.
        "전송 데이터가 없습니다.
      ENDIF.

    ELSE. " 화면 구성 및 화면 출력

      CALL SCREEN 0100.
    ENDIF.

  ELSE. " 화면데이터 구성후 화면출력
    CALL SCREEN 0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TABLE_RECORD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_TABLE_RECORD .

  DATA : LV_DDTEXT TYPE DD07T-DDTEXT.
  DATA : LV_DDTEXT2 TYPE DD07T-DDTEXT.

  LV_DDTEXT = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
                IV_DOMNAME  = 'ZGTDTARGET'                  " 도메인이름
                IV_DOMVALUE = CONV #( P_TARGET )                 " 도메인에 대한 값: 단일값/상한
              ).

  REFRESH GT_SGRPNR.

  SELECT DISTINCT 'I' AS SIGN, 'EQ' AS OPTION,  A~SGRPNR AS LOW
    FROM ZGTPPT2011 AS A
    INNER JOIN ZGTPPT2012 AS B ON B~SGRPNR = A~SGRPNR
    INNER JOIN AUFK AS C ON C~AUFNR = B~ORDNR
                             AND C~ZZBUNDLE = A~ZZBUNDLE
    INTO TABLE @GT_SGRPNR
   WHERE A~ZZBUNDLE IN @S_BUNDL
     AND B~ORDNR IN @S_AUFNR
     AND C~ERDAT IN @S_ERDAT.

  IF GT_SGRPNR[] IS NOT INITIAL.
    SORT GT_SGRPNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM GT_SGRPNR COMPARING LOW.
  ENDIF.

  REFRESH : GT_2011, GT_2012, GT_2013, GT_2014.

  SELECT DISTINCT * FROM ZGTPPT2011
    INTO TABLE GT_2011
   WHERE SGRPNR IN GT_SGRPNR.

  SELECT DISTINCT * FROM ZGTPPT2012
    INTO TABLE GT_2012
   WHERE SGRPNR IN GT_SGRPNR
      AND ORDTY = 'PRD'.

  SELECT DISTINCT M~ORDNR, M~POSNR, A~PWERK AS WERKS, A~MATNR, LEFT( B~DISPO, 2 ) AS SPGCD
    FROM @GT_2012 AS M
    INNER JOIN AFPO AS A ON A~AUFNR = M~ORDNR
                              AND A~POSNR = RIGHT( M~POSNR, 4 )
    INNER JOIN MARC AS B ON B~WERKS = A~PWERK
                              AND B~MATNR = A~MATNR
    INTO TABLE @DATA(LT_MANTR).

  SELECT DISTINCT * FROM ZGTPPT2013
    INTO TABLE GT_2013
   WHERE SGRPNR IN GT_SGRPNR.

  SELECT DISTINCT B~*
    FROM @GT_2013 AS A
    INNER JOIN ZGTPPT2010 AS B ON B~GRPNR = A~GRPNR
                                      AND B~ORDNR = A~DMORD
                                      AND B~POSNR = A~DMLINE
    INTO TABLE @DATA(LT_2010).

  SELECT DISTINCT * FROM ZGTPPT2014
    INTO TABLE GT_2014
   WHERE SGRPNR IN GT_SGRPNR.

* 배치전송 파라미터가 비어있을시 화면구성
*  IF P_BATCH IS INITIAL.
  LOOP AT GT_SGRPNR INTO DATA(LS_SGRPNR).
    READ TABLE GT_2011 INTO DATA(LS_2011) WITH KEY SGRPNR = LS_SGRPNR-LOW.
    IF SY-SUBRC NE 0.
      CONTINUE.
    ENDIF.

*    작업구분
    CLEAR LV_DDTEXT2.
    LV_DDTEXT2 = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
                  IV_DOMNAME  = 'ZDJOBTY'                  " 도메인이름
                  IV_DOMVALUE = CONV #( LS_2011-JOBTY )                 " 도메인에 대한 값: 단일값/상한
                ).

* 신선작업지시
    LOOP AT GT_2012 INTO DATA(LS_2012) WHERE SGRPNR = LS_SGRPNR-LOW.
      READ TABLE LT_MANTR INTO DATA(LS_MATNR) WITH KEY ORDNR = LS_2012-ORDNR.
      CLEAR : GS_MAIN_DISP_100.
*        GS_MAIN_DISP_100-ZIFKEY =
*        GS_MAIN_DISP_100-ZSTAT =
*        GS_MAIN_DISP_100-STATUS =
*        GS_MAIN_DISP_100-ZMESSAGE =
      GS_MAIN_DISP_100-ZSYSTEM_ID = P_TARGET.
      GS_MAIN_DISP_100-DDTEXT = LV_DDTEXT.
      GS_MAIN_DISP_100-WERKS = LS_MATNR-WERKS.
      GS_MAIN_DISP_100-SPGCD = LS_MATNR-SPGCD.
      GS_MAIN_DISP_100-ZZBUNDLE = LS_2011-ZZBUNDLE.
      GS_MAIN_DISP_100-GONG_CD = LS_2012-GONG_CD.
      GS_MAIN_DISP_100-AUFNR = LS_2012-ORDNR.
      GS_MAIN_DISP_100-POSNR = LS_2012-POSNR.
      GS_MAIN_DISP_100-JOBTY = LS_2012-JOBTY.
      GS_MAIN_DISP_100-DDTEXT2 = LV_DDTEXT2.
      GS_MAIN_DISP_100-ZCAGE = LS_2012-ZCAGE.
      GS_MAIN_DISP_100-ZWSEQ = LS_2012-ZWSEQ.
      GS_MAIN_DISP_100-MATNR = LS_MATNR-MATNR.
      GS_MAIN_DISP_100-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_MATNR-MATNR ).
      APPEND GS_MAIN_DISP_100 TO GT_MAIN_DISP_100.

    ENDLOOP.
* 후속공정
    LOOP AT GT_2013 INTO DATA(LS_2013) WHERE SGRPNR = LS_SGRPNR-LOW.
      READ TABLE LT_2010 INTO DATA(LS_2010) WITH KEY GRPNR = LS_2013-GRPNR
                                                     ORDNR = LS_2013-DMORD
                                                     POSNR = LS_2013-DMLINE.

      CLEAR : GS_MAIN_DISP_101.
*        GS_MAIN_DISP_101-ZIFKEY = .
      GS_MAIN_DISP_101-ZSYSTEM_ID = P_TARGET.
      GS_MAIN_DISP_101-DDTEXT = LV_DDTEXT.
      GS_MAIN_DISP_101-ZZBUNDLE = LS_2011-ZZBUNDLE.
      GS_MAIN_DISP_101-GONG_CD = 'BWD'.
      GS_MAIN_DISP_101-JOBTY = LS_2011-JOBTY.
*      GS_MAIN_DISP_101-DDTEXT2 = LV_DDTEXT2.
      GS_MAIN_DISP_101-ORDTY = LS_2010-ORDTY.
      IF GS_MAIN_DISP_101-ORDTY IS INITIAL.
        GS_MAIN_DISP_101-ORDTY = 'PRD'.
      ENDIF.
*      GS_MAIN_DISP_101-DDTEXT3 = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
*                  IV_DOMNAME  = 'ZGTDORDTY'                  " 도메인이름
*                  IV_DOMVALUE = CONV #( LS_2010-ORDTY )                 " 도메인에 대한 값: 단일값/상한
*                ).
      GS_MAIN_DISP_101-ORDNR = LS_2013-DMORD.
      GS_MAIN_DISP_101-POSNR = LS_2013-DMLINE + 0.
      GS_MAIN_DISP_101-GRPNR = LS_2013-GRPNR.
      APPEND GS_MAIN_DISP_101 TO GT_MAIN_DISP_101.
    ENDLOOP.
* 소선정보
    LOOP AT GT_2014 INTO DATA(LS_2014) WHERE SGRPNR = LS_SGRPNR-LOW.
      CLEAR GS_MAIN_DISP_102.
*        GS_MAIN_DISP_102-ZIFKEY =
      GS_MAIN_DISP_102-ZSYSTEM_ID = P_TARGET.
      GS_MAIN_DISP_102-DDTEXT = LV_DDTEXT.
      GS_MAIN_DISP_102-ZZBUNDLE = LS_2011-ZZBUNDLE.
      GS_MAIN_DISP_102-GONG_CD = 'BWD'.
      GS_MAIN_DISP_102-JOBTY = LS_2011-JOBTY.
      GS_MAIN_DISP_102-ZCAGE = LS_2014-ZCAGE.
      GS_MAIN_DISP_102-JAEJIL = LS_2014-JAEJIL.
      GS_MAIN_DISP_102-SOSUN_DIA = LS_2014-SOSUN_DIA.
      GS_MAIN_DISP_102-YCOEF = LS_2014-YCOEF.
      GS_MAIN_DISP_102-ADLENGTH = LS_2014-ADLENGTH.
      GS_MAIN_DISP_102-BSMENGE = LS_2014-BSMENGE.
      GS_MAIN_DISP_102-BSLENGTH = LS_2014-BSLENGTH.
      GS_MAIN_DISP_102-INFACTOR = LS_2014-INFACTOR.
      GS_MAIN_DISP_102-INLENGTH = LS_2014-INLENGTH.
      GS_MAIN_DISP_102-MEINS = LS_2014-MEINS.
      APPEND GS_MAIN_DISP_102 TO GT_MAIN_DISP_102.

    ENDLOOP.
  ENDLOOP.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_HISTORY_OF_SEND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_HISTORY_OF_SEND .

  DATA : LV_DDTEXT TYPE DD07T-DDTEXT.
  DATA : LV_DDTEXT2 TYPE DD07T-DDTEXT.
  DATA : LT_SORT_ITAB TYPE TABLE OF ZGTPPT2440.

  LV_DDTEXT = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
                IV_DOMNAME  = 'ZGTDTARGET'                  " 도메인이름
                IV_DOMVALUE = CONV #( P_TARGET )                 " 도메인에 대한 값: 단일값/상한
              ).

  SELECT * FROM ZGTPPT2440
    INTO TABLE GT_2440
   WHERE ZSYSTEM_ID = P_TARGET
     AND ZZBUNDLE IN S_BUNDL
     AND AUFNR IN S_AUFNR
     AND IFDAT IN S_IFDAT.

  LT_SORT_ITAB = GT_2440.
  IF LT_SORT_ITAB IS NOT INITIAL.
    SORT LT_SORT_ITAB BY ZIFKEY ZSYSTEM_ID ZZBUNDLE.
    DELETE ADJACENT DUPLICATES FROM LT_SORT_ITAB COMPARING ZIFKEY ZSYSTEM_ID ZZBUNDLE.

    SELECT DISTINCT B~*
      FROM @LT_SORT_ITAB AS A
      INNER JOIN ZGTPPT2441 AS B ON B~ZIFKEY = A~ZIFKEY
                                AND B~ZSYSTEM_ID = A~ZSYSTEM_ID
                                AND B~ZZBUNDLE = A~ZZBUNDLE
      INTO TABLE @GT_2441.

    SELECT DISTINCT M~ORDNR, M~POSNR, A~PWERK AS WERKS, A~MATNR, LEFT( B~DISPO, 2 ) AS SPGCD
      FROM @GT_2441 AS M
      INNER JOIN AFPO AS A ON A~AUFNR = M~ORDNR
                                AND A~POSNR = RIGHT( M~POSNR, 4 )
      INNER JOIN MARC AS B ON B~WERKS = A~PWERK
                                AND B~MATNR = A~MATNR
      INTO TABLE @DATA(LT_MANTR).

    SELECT DISTINCT B~*
      FROM @GT_2441 AS A
      INNER JOIN ZGTPPT2010 AS B ON B~GRPNR = A~GRPNR
                                        AND B~ORDNR = A~ORDNR
                                        AND B~POSNR = A~POSNR
      INTO TABLE @DATA(LT_2010).

    SELECT DISTINCT B~*
      FROM @LT_SORT_ITAB AS A
      INNER JOIN ZGTPPT2442 AS B ON B~ZIFKEY = A~ZIFKEY
                                AND B~ZSYSTEM_ID = A~ZSYSTEM_ID
                                AND B~ZZBUNDLE = A~ZZBUNDLE
      INTO TABLE @GT_2442.

  ENDIF.


* 배치전송 파라미터가 비어있을시 화면구성
  LOOP AT LT_SORT_ITAB INTO DATA(LS_SORT_ITAB).
*    작업구분
    CLEAR LV_DDTEXT2.
    LV_DDTEXT2 = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
                  IV_DOMNAME  = 'ZDJOBTY'                  " 도메인이름
                  IV_DOMVALUE = CONV #( LS_SORT_ITAB-JOBTY )                 " 도메인에 대한 값: 단일값/상한
                ).



* 신선작업지시
    LOOP AT GT_2440 INTO DATA(LS_2440) WHERE ZIFKEY = LS_SORT_ITAB-ZIFKEY
                                         AND ZSYSTEM_ID = LS_SORT_ITAB-ZSYSTEM_ID
                                         AND ZZBUNDLE = LS_SORT_ITAB-ZZBUNDLE.
      READ TABLE LT_MANTR INTO DATA(LS_MATNR) WITH KEY ORDNR = LS_2440-AUFNR.
      CLEAR : GS_MAIN_DISP_100.
      GS_MAIN_DISP_100-ZIFKEY = LS_2440-ZIFKEY.
      GS_MAIN_DISP_100-ZSTAT = LS_2440-ZSTAT.
      CASE LS_2440-ZSTAT.
        WHEN '00'.
          GS_MAIN_DISP_100-STATUS = ICON_LED_GREEN.
        WHEN '01'.
          GS_MAIN_DISP_100-STATUS = ICON_LED_RED.
      ENDCASE.
      GS_MAIN_DISP_100-ZMESSAGE = LS_2440-ZMESSAGE.
      GS_MAIN_DISP_100-ZSYSTEM_ID = LS_2440-ZSYSTEM_ID.
      GS_MAIN_DISP_100-DDTEXT = LV_DDTEXT.
      GS_MAIN_DISP_100-WERKS = LS_MATNR-WERKS.
      GS_MAIN_DISP_100-SPGCD = LS_MATNR-SPGCD.
      GS_MAIN_DISP_100-ZZBUNDLE = LS_2440-ZZBUNDLE.
      GS_MAIN_DISP_100-GONG_CD = LS_2440-GONG_CD.
      GS_MAIN_DISP_100-AUFNR = LS_2440-AUFNR.
      GS_MAIN_DISP_100-POSNR = LS_2440-POSNR.
      GS_MAIN_DISP_100-JOBTY = LS_SORT_ITAB-JOBTY.
      GS_MAIN_DISP_100-DDTEXT2 = LV_DDTEXT2.
      GS_MAIN_DISP_100-ZCAGE = LS_2440-ZCAGE.
      GS_MAIN_DISP_100-ZWSEQ = LS_2440-ZWSEQ.
      GS_MAIN_DISP_100-MATNR = LS_MATNR-MATNR.
      GS_MAIN_DISP_100-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_MATNR-MATNR ).
      APPEND GS_MAIN_DISP_100 TO GT_MAIN_DISP_100.

    ENDLOOP.
* 후속공정
    LOOP AT GT_2441 INTO DATA(LS_2441) WHERE ZIFKEY = LS_SORT_ITAB-ZIFKEY
                                         AND ZSYSTEM_ID = LS_SORT_ITAB-ZSYSTEM_ID
                                         AND ZZBUNDLE = LS_SORT_ITAB-ZZBUNDLE.
      READ TABLE LT_2010 INTO DATA(LS_2010) WITH KEY GRPNR = LS_2441-GRPNR
                                                     ORDNR = LS_2441-ORDNR
                                                     POSNR = LS_2441-POSNR.

      CLEAR : GS_MAIN_DISP_101.
      GS_MAIN_DISP_101-ZIFKEY = LS_2441-ZIFKEY.
      GS_MAIN_DISP_101-ZSYSTEM_ID = LS_2441-ZSYSTEM_ID.
      GS_MAIN_DISP_101-DDTEXT = LV_DDTEXT.
      GS_MAIN_DISP_101-ZZBUNDLE = LS_2441-ZZBUNDLE.
      GS_MAIN_DISP_101-GONG_CD = LS_2010-GONG_CD.
      GS_MAIN_DISP_101-JOBTY = LS_SORT_ITAB-JOBTY.
*      GS_MAIN_DISP_101-DDTEXT2 = LV_DDTEXT2.
      GS_MAIN_DISP_101-ORDTY = LS_2010-ORDTY.
*      GS_MAIN_DISP_101-DDTEXT3 = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
*                  IV_DOMNAME  = 'ZGTDORDTY'                  " 도메인이름
*                  IV_DOMVALUE = CONV #( LS_2010-ORDTY )                 " 도메인에 대한 값: 단일값/상한
*                ).
      GS_MAIN_DISP_101-ORDNR = LS_2010-ORDNR.
      GS_MAIN_DISP_101-POSNR = LS_2010-POSNR.
      GS_MAIN_DISP_101-GRPNR = LS_2010-GRPNR.
      APPEND GS_MAIN_DISP_101 TO GT_MAIN_DISP_101.
    ENDLOOP.
* 소선정보
    LOOP AT GT_2442 INTO DATA(LS_2442) WHERE ZIFKEY = LS_SORT_ITAB-ZIFKEY
                                         AND ZSYSTEM_ID = LS_SORT_ITAB-ZSYSTEM_ID
                                         AND ZZBUNDLE = LS_SORT_ITAB-ZZBUNDLE.
      CLEAR GS_MAIN_DISP_102.
      GS_MAIN_DISP_102-ZIFKEY = LS_2442-ZIFKEY.
      GS_MAIN_DISP_102-ZSYSTEM_ID = LS_2442-ZSYSTEM_ID.
      GS_MAIN_DISP_102-DDTEXT = LV_DDTEXT.
      GS_MAIN_DISP_102-ZZBUNDLE = LS_2442-ZZBUNDLE.
      READ TABLE GT_2440 INTO LS_2440 WITH KEY ZZBUNDLE = LS_2442-ZZBUNDLE
                                                      ZCAGE = LS_2442-ZCAGE.
      IF SY-SUBRC EQ 0.
        GS_MAIN_DISP_102-GONG_CD = LS_2440-GONG_CD.
      ELSE.
        GS_MAIN_DISP_102-GONG_CD = 'BWD'.
      ENDIF.
      GS_MAIN_DISP_102-JOBTY = LS_SORT_ITAB-JOBTY.
      GS_MAIN_DISP_102-ZCAGE = LS_2442-ZCAGE.
      GS_MAIN_DISP_102-JAEJIL = LS_2442-JAEJIL.
      GS_MAIN_DISP_102-SOSUN_DIA = LS_2442-SOSUN_DIA.
      GS_MAIN_DISP_102-YCOEF = LS_2442-YCOEF.
      GS_MAIN_DISP_102-ADLENGTH = LS_2442-ADLENGTH.
      GS_MAIN_DISP_102-BSMENGE = LS_2442-BSMENGE.
      GS_MAIN_DISP_102-BSLENGTH = LS_2442-BSLENGTH.
      GS_MAIN_DISP_102-INFACTOR = LS_2442-INFACTOR.
      GS_MAIN_DISP_102-INLENGTH = LS_2442-INLENGTH.
      GS_MAIN_DISP_102-MEINS = LS_2442-MEINS.
      APPEND GS_MAIN_DISP_102 TO GT_MAIN_DISP_102.

    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_SEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_SEND_DATA .

  REFRESH : GT_BUNDLE_IF, GT_FOLLOW_IF, GT_SOSUN_IF.
  REFRESH GT_ZZBUNDLE.

  LOOP AT GT_SGRPNR INTO DATA(LS_SGRPNR).
    READ TABLE GT_2011 INTO DATA(LS_2011) WITH KEY SGRPNR = LS_SGRPNR-LOW.
    APPEND INITIAL LINE TO GT_ZZBUNDLE ASSIGNING FIELD-SYMBOL(<LS_ZZBUNDLE>).
    <LS_ZZBUNDLE>-SIGN = 'I'.
    <LS_ZZBUNDLE>-OPTION = 'EQ'.
    <LS_ZZBUNDLE>-LOW = LS_2011-ZZBUNDLE.

    PERFORM MAKE_DATA_BUNDLE USING '1' LS_2011 LS_2011-ZZBUNDLE.

    PERFORM MAKE_DATA_FOLLOW USING '1' LS_2011 LS_2011-ZZBUNDLE.

    PERFORM MAKE_DATA_SOSUN USING '1' LS_2011 LS_2011-ZZBUNDLE.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DATA_BUNDLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_TARGET
*&      --> LS_2011_ZZBUNDLE
*&---------------------------------------------------------------------*
FORM MAKE_DATA_BUNDLE  USING PV_GUBUN
                                PS_2011 TYPE ZGTPPT2011
                                PV_ZZBUNDLE TYPE ZGTPPT2440-ZZBUNDLE.

  DATA : LV_ZCAGE_C TYPE C LENGTH 10.
  DATA : LV_ZWSEQ_C TYPE C LENGTH 10.

  CASE PV_GUBUN.
    WHEN '1'. "전송정보
      LOOP AT GT_MAIN_DISP_100 INTO GS_MAIN_DISP_100 WHERE ZZBUNDLE = PV_ZZBUNDLE.
        APPEND INITIAL LINE TO GT_BUNDLE_IF ASSIGNING FIELD-SYMBOL(<LS_BUNDLE_IF>).
        <LS_BUNDLE_IF>-ZZBUNDLE = GS_MAIN_DISP_100-ZZBUNDLE.
        <LS_BUNDLE_IF>-GONG_CD = GS_MAIN_DISP_100-GONG_CD.
        <LS_BUNDLE_IF>-JOBTY = GS_MAIN_DISP_100-JOBTY.
        <LS_BUNDLE_IF>-AUFNR = GS_MAIN_DISP_100-AUFNR.
        <LS_BUNDLE_IF>-POSNR = GS_MAIN_DISP_100-POSNR + 0.
        LV_ZCAGE_C = GS_MAIN_DISP_100-ZCAGE.
        CONDENSE LV_ZCAGE_C.
        <LS_BUNDLE_IF>-ZCAGE = LV_ZCAGE_C.
        LV_ZWSEQ_C = GS_MAIN_DISP_100-ZWSEQ.
        CONDENSE LV_ZWSEQ_C.
        <LS_BUNDLE_IF>-ZWSEQ = LV_ZWSEQ_C.
      ENDLOOP.
    WHEN '2'. " 재전송정보.
      SELECT * FROM ZGTPPT2012
        INTO TABLE @DATA(LT_2012)
       WHERE SGRPNR = @PS_2011-SGRPNR
         AND ORDTY = 'PRD'.

      LOOP AT LT_2012 INTO DATA(LS_2012).
        APPEND INITIAL LINE TO GT_BUNDLE_IF ASSIGNING <LS_BUNDLE_IF>.
        <LS_BUNDLE_IF>-ZZBUNDLE = PS_2011-ZZBUNDLE.
        <LS_BUNDLE_IF>-GONG_CD = LS_2012-GONG_CD.
        <LS_BUNDLE_IF>-JOBTY = PS_2011-JOBTY.
        <LS_BUNDLE_IF>-AUFNR = LS_2012-ORDNR.
        <LS_BUNDLE_IF>-POSNR = LS_2012-POSNR + 0.
        LV_ZCAGE_C = LS_2012-ZCAGE.
        CONDENSE LV_ZCAGE_C.
        <LS_BUNDLE_IF>-ZCAGE = LV_ZCAGE_C.
        LV_ZWSEQ_C = LS_2012-ZWSEQ.
        CONDENSE LV_ZWSEQ_C.
        <LS_BUNDLE_IF>-ZWSEQ = LV_ZWSEQ_C.
      ENDLOOP.

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_RFC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_RFC TABLES PT_BUNDLE STRUCTURE ZGTPPSIF0069
                           PT_FOLLOW STRUCTURE ZGTPPSIF0070
                           PT_SOSUN STRUCTURE ZGTPPSIF0071
                     USING PV_ZZBUNDLE TYPE ZGTPPT2011-ZZBUNDLE
                     CHANGING PV_RESULT  TYPE ZO_RESULT
                       PV_MESSAGE TYPE ZO_MESSAGE.

  DATA : LT_BUNDLE_IF  TYPE TABLE OF ZGTPPSIF0069. "신선오더정보
  DATA : LT_FOLLOW_IF  TYPE TABLE OF ZGTPPSIF0070. "후공정오더 정보
  DATA : LT_SOSUN_IF  TYPE TABLE OF ZGTPPSIF0071. "소선정보

  DATA : LV_DEST TYPE ZIFDEST-DEST.
  DATA : LV_ZSYSTEM_ID   TYPE ZGTPPT1050-ZSYSTEM_ID.
  DATA : LV_MESSAGE TYPE STRING.

  DATA : LV_ZZBUNDLE TYPE CHAR12.
  DATA : LV_GONG_CD TYPE CHAR03.
  DATA : LV_JOBTY TYPE CHAR01.

  SELECT SINGLE A~ZZBUNDLE, A~JOBTY, B~GONG_CD
    FROM ZGTPPT2011 AS A
    INNER JOIN ZGTPPT2012 AS B ON B~SGRPNR = A~SGRPNR
    WHERE A~ZZBUNDLE = @PV_ZZBUNDLE
    INTO ( @LV_ZZBUNDLE, @LV_JOBTY, @LV_GONG_CD ).

  LT_BUNDLE_IF = PT_BUNDLE[].
  LOOP AT LT_BUNDLE_IF ASSIGNING FIELD-SYMBOL(<LS_BUNDLE_IF>).
    __ALPHA_OUT : <LS_BUNDLE_IF>-AUFNR, <LS_BUNDLE_IF>-POSNR.
  ENDLOOP.
  LT_FOLLOW_IF = PT_FOLLOW[].
  LOOP AT LT_FOLLOW_IF ASSIGNING FIELD-SYMBOL(<LS_FOLLOW_IF>).
    __ALPHA_OUT : <LS_FOLLOW_IF>-ORDNR, <LS_FOLLOW_IF>-POSNR.
  ENDLOOP.
  LT_SOSUN_IF = PT_SOSUN[].

*- Destination 가져오기
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      GUBUN                 = 'P1'    "Destination 점검
    IMPORTING
      DEST_NAME             = LV_DEST
    EXCEPTIONS
      DESTINATION_NOT_FOUND = 1
      OTHERS                = 2.

  LV_ZSYSTEM_ID = P_TARGET.

*- RFC 전송
  TRY.
      CALL FUNCTION 'ZGTPP_IF_O_BWD_WKDOC_SEND' DESTINATION LV_DEST
        EXPORTING
          I_SYSTEM_ID = LV_ZSYSTEM_ID
          I_ZZBUNDLE  = LV_ZZBUNDLE
          I_GONG_CD   = LV_GONG_CD
          I_JOBTY     = LV_JOBTY
        IMPORTING
          ZO_RESULT   = PV_RESULT
          ZO_MESSAGE  = PV_MESSAGE
        TABLES
          ET_BUNDLE   = LT_BUNDLE_IF
          ET_FOLLOW   = LT_FOLLOW_IF
          ET_SOSUN    = LT_SOSUN_IF.

    CATCH CX_ROOT INTO DATA(LO_ROOT).
      LV_MESSAGE = LO_ROOT->GET_LONGTEXT( ).
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DATA_FOLLOW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ZIFKEY
*&      --> P_TARGET
*&      --> LS_2011_ZZBUNDLE
*&---------------------------------------------------------------------*
FORM MAKE_DATA_FOLLOW  USING    PV_GUBUN
                                PS_2011 TYPE ZGTPPT2011
                                PV_ZZBUNDLE TYPE ZGTPPT2440-ZZBUNDLE.

  CASE PV_GUBUN.
    WHEN '1'. "전송정보

      LOOP AT GT_MAIN_DISP_101 INTO GS_MAIN_DISP_101 WHERE ZZBUNDLE = PV_ZZBUNDLE.
        APPEND INITIAL LINE TO GT_FOLLOW_IF ASSIGNING FIELD-SYMBOL(<LS_FOLLOW_IF>).
        <LS_FOLLOW_IF>-ZZBUNDLE = GS_MAIN_DISP_101-ZZBUNDLE.
        <LS_FOLLOW_IF>-GONG_CD = 'BWD'.
        <LS_FOLLOW_IF>-JOBTY = GS_MAIN_DISP_101-JOBTY.
        <LS_FOLLOW_IF>-ORDTY = GS_MAIN_DISP_101-ORDTY.
        <LS_FOLLOW_IF>-ORDNR = GS_MAIN_DISP_101-ORDNR.
        <LS_FOLLOW_IF>-POSNR = GS_MAIN_DISP_101-POSNR + 0.
        <LS_FOLLOW_IF>-GRPNR = GS_MAIN_DISP_101-GRPNR.

      ENDLOOP.
    WHEN '2'. " 재전송정보
      SELECT * FROM ZGTPPT2013
        INTO TABLE @DATA(LT_2013)
       WHERE SGRPNR = @PS_2011-SGRPNR.

      SELECT DISTINCT B~*
        FROM @LT_2013 AS A
        INNER JOIN ZGTPPT2010 AS B ON B~GRPNR = A~GRPNR
                                          AND B~ORDNR = A~DMORD
                                          AND B~POSNR = A~DMLINE
        INTO TABLE @DATA(LT_2010).

      LOOP AT LT_2013 INTO DATA(LS_2013).

        APPEND INITIAL LINE TO GT_FOLLOW_IF ASSIGNING <LS_FOLLOW_IF>.
        <LS_FOLLOW_IF>-ZZBUNDLE = PS_2011-ZZBUNDLE.
        <LS_FOLLOW_IF>-GONG_CD = 'BWD'.
        <LS_FOLLOW_IF>-JOBTY = PS_2011-JOBTY.


        READ TABLE LT_2010 INTO DATA(LS_2010) WITH KEY GRPNR = LS_2013-GRPNR
                                                             ORDNR = LS_2013-DMORD
                                                             POSNR = LS_2013-DMLINE.
        IF SY-SUBRC EQ 0.
          <LS_FOLLOW_IF>-ORDTY = LS_2010-ORDTY.
          <LS_FOLLOW_IF>-ORDNR = LS_2010-ORDNR.
          <LS_FOLLOW_IF>-POSNR = LS_2010-POSNR + 0.
          <LS_FOLLOW_IF>-GRPNR = LS_2010-GRPNR.
        ELSE.
          <LS_FOLLOW_IF>-ORDTY = 'PRD'.
          <LS_FOLLOW_IF>-ORDNR = LS_2013-DMORD.
          <LS_FOLLOW_IF>-POSNR = LS_2013-DMLINE + 0.
          <LS_FOLLOW_IF>-GRPNR = LS_2013-GRPNR.
        ENDIF.

      ENDLOOP.


  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DATA_SOSUN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ZIFKEY
*&      --> P_TARGET
*&      --> LS_2011_ZZBUNDLE
*&---------------------------------------------------------------------*
FORM MAKE_DATA_SOSUN  USING    PV_GUBUN
                                PS_2011 TYPE ZGTPPT2011
                                PV_ZZBUNDLE TYPE ZGTPPT2440-ZZBUNDLE.

  DATA : LV_ZCAGE_C TYPE C LENGTH 10.
  DATA : LV_SOSUN_DIA_C TYPE C LENGTH 10.
  DATA : LV_YCOEF_C TYPE C LENGTH 10.
  DATA : LV_ADLENGTH_C TYPE C LENGTH 20.
  DATA : LV_BSMENGE_C TYPE C LENGTH 20.
  DATA : LV_BSLENGTH_C TYPE C LENGTH 20.
  DATA : LV_INFACTOR_C TYPE C LENGTH 20.
  DATA : LV_INLENGTH_C TYPE C LENGTH 20.

  CASE PV_GUBUN.
    WHEN '1'. "전송정보

      LOOP AT GT_MAIN_DISP_102 INTO GS_MAIN_DISP_102 WHERE ZZBUNDLE = PV_ZZBUNDLE.
        APPEND INITIAL LINE TO GT_SOSUN_IF ASSIGNING FIELD-SYMBOL(<LS_SOSUN_IF>).
        <LS_SOSUN_IF>-ZZBUNDLE = GS_MAIN_DISP_102-ZZBUNDLE.
        <LS_SOSUN_IF>-GONG_CD = 'BWD'.
        <LS_SOSUN_IF>-JOBTY = GS_MAIN_DISP_102-JOBTY.

        CLEAR LV_ZCAGE_C.
        LV_ZCAGE_C = GS_MAIN_DISP_102-ZCAGE.
        CONDENSE LV_ZCAGE_C.
        <LS_SOSUN_IF>-ZCAGE = LV_ZCAGE_C.

        <LS_SOSUN_IF>-JAEJIL = GS_MAIN_DISP_102-JAEJIL.

        CLEAR LV_SOSUN_DIA_C.
        LV_SOSUN_DIA_C = GS_MAIN_DISP_102-SOSUN_DIA.
        CONDENSE LV_SOSUN_DIA_C.
        <LS_SOSUN_IF>-SOSUN_DIA = LV_SOSUN_DIA_C.

        CLEAR LV_YCOEF_C.
        LV_YCOEF_C = GS_MAIN_DISP_102-YCOEF.
        CONDENSE LV_YCOEF_C.
        <LS_SOSUN_IF>-YCOEF = LV_YCOEF_C.

        CLEAR LV_ADLENGTH_C.
        LV_ADLENGTH_C = GS_MAIN_DISP_102-ADLENGTH.
        CONDENSE LV_ADLENGTH_C.
        <LS_SOSUN_IF>-ADLENGTH = LV_ADLENGTH_C.

        CLEAR LV_BSMENGE_C.
        LV_BSMENGE_C = GS_MAIN_DISP_102-BSMENGE.
        CONDENSE LV_BSMENGE_C.
        <LS_SOSUN_IF>-BSMENGE = LV_BSMENGE_C.

        CLEAR LV_BSLENGTH_C.
        LV_BSLENGTH_C = GS_MAIN_DISP_102-BSLENGTH.
        CONDENSE LV_BSLENGTH_C.
        <LS_SOSUN_IF>-BSLENGTH = LV_BSLENGTH_C.

        CLEAR LV_INFACTOR_C.
        LV_INFACTOR_C = GS_MAIN_DISP_102-INFACTOR.
        CONDENSE LV_INFACTOR_C.
        <LS_SOSUN_IF>-INFACTOR = LV_INFACTOR_C.

        CLEAR LV_INLENGTH_C.
        LV_INLENGTH_C = GS_MAIN_DISP_102-INLENGTH.
        CONDENSE LV_INLENGTH_C.
        <LS_SOSUN_IF>-INLENGTH = LV_INLENGTH_C.

        <LS_SOSUN_IF>-MEINS = GS_MAIN_DISP_102-MEINS.
      ENDLOOP.

    WHEN '2'.
      SELECT * FROM ZGTPPT2014
        INTO TABLE @DATA(LT_2014)
       WHERE SGRPNR = @PS_2011-SGRPNR.

      LOOP AT LT_2014 INTO DATA(LS_2014).

        APPEND INITIAL LINE TO GT_SOSUN_IF ASSIGNING <LS_SOSUN_IF>.
        <LS_SOSUN_IF>-ZZBUNDLE = PS_2011-ZZBUNDLE.
        <LS_SOSUN_IF>-GONG_CD = 'BWD'.
        <LS_SOSUN_IF>-JOBTY = PS_2011-JOBTY.

        CLEAR LV_ZCAGE_C.
        LV_ZCAGE_C = LS_2014-ZCAGE.
        CONDENSE LV_ZCAGE_C.
        <LS_SOSUN_IF>-ZCAGE = LV_ZCAGE_C.

        <LS_SOSUN_IF>-JAEJIL = LS_2014-JAEJIL.

        CLEAR LV_SOSUN_DIA_C.
        LV_SOSUN_DIA_C = LS_2014-SOSUN_DIA.
        CONDENSE LV_SOSUN_DIA_C.
        <LS_SOSUN_IF>-SOSUN_DIA = LV_SOSUN_DIA_C.

        CLEAR LV_YCOEF_C.
        LV_YCOEF_C = LS_2014-YCOEF.
        CONDENSE LV_YCOEF_C.
        <LS_SOSUN_IF>-YCOEF = LV_YCOEF_C.

        CLEAR LV_ADLENGTH_C.
        LV_ADLENGTH_C = LS_2014-ADLENGTH.
        CONDENSE LV_ADLENGTH_C.
        <LS_SOSUN_IF>-ADLENGTH = LV_ADLENGTH_C.

        CLEAR LV_BSMENGE_C.
        LV_BSMENGE_C = LS_2014-BSMENGE.
        CONDENSE LV_BSMENGE_C.
        <LS_SOSUN_IF>-BSMENGE = LV_BSMENGE_C.

        CLEAR LV_BSLENGTH_C.
        LV_BSLENGTH_C = LS_2014-BSLENGTH.
        CONDENSE LV_BSLENGTH_C.
        <LS_SOSUN_IF>-BSLENGTH = LV_BSLENGTH_C.

        CLEAR LV_INFACTOR_C.
        LV_INFACTOR_C = LS_2014-INFACTOR.
        CONDENSE LV_INFACTOR_C.
        <LS_SOSUN_IF>-INFACTOR = LV_INFACTOR_C.

        CLEAR LV_INLENGTH_C.
        LV_INLENGTH_C = LS_2014-INLENGTH.
        CONDENSE LV_INLENGTH_C.
        <LS_SOSUN_IF>-INLENGTH = LV_INLENGTH_C.

        <LS_SOSUN_IF>-MEINS = LS_2014-MEINS.

      ENDLOOP.


  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      GO_GRID_0100->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0100 ).
    WHEN GO_GRID_0101.
      GO_GRID_0101->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0101 ).
    WHEN GO_GRID_0102.
      GO_GRID_0101->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0102 ).
  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
*     I_SOFT_REFRESH = 'X'
      IS_STABLE = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0100 .

  CREATE OBJECT GO_DOCKING_CONTAINER
    EXPORTING
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 3000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.
*화면 분할
  CREATE OBJECT GO_SPLITTER
    EXPORTING
      PARENT  = GO_DOCKING_CONTAINER
      ROWS    = 2
      COLUMNS = 1.

  GO_SPLITTER->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    40 ).             " Height

  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0100.

  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_SPLIT_CONTAINER.


  CREATE OBJECT GO_SPLITTER2
    EXPORTING
      PARENT  = GO_SPLIT_CONTAINER
      ROWS    = 1
      COLUMNS = 2.


  GO_SPLITTER2->SET_COLUMN_WIDTH(
    EXPORTING
      ID                =  1                " Column ID
      WIDTH          = 50 ).                " NPlWidth

  CALL METHOD GO_SPLITTER2->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0101.

  CALL METHOD GO_SPLITTER2->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 2
    RECEIVING
      CONTAINER = GO_CONTAIN_0102.


* 그리드 적용
  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .

  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPI2040TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_100'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0100.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_100
    EXCEPTIONS
      OTHERS          = 1.


  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'ZIFKEY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '인터페이스키'(f01).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-NO_ZERO = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ZSTAT'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'STATUS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '전송상태'(f02).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ZMESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '결과메시지'(f03).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ZSYSTEM_ID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수신시스템'(f04).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'DDTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시스템내역'(f05).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'(f06).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'SPGCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SPG'(f07).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ZZBUNDLE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '묶음오더'(f08).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'GONG_CD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정코드'(f09).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더'(f10).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더품목'(f11).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'JOBTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업구분'(f12).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'DDTEXT2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구분명'(f13).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZCAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Cage'(f14).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZWSEQ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '차수'(f15).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산자재'(f16).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재내역'(f17).
        <LS_FCAT>-JUST = 'L'.

    ENDCASE.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0100 .

  REFRESH GT_EXCLUDE_0100.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0100
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*-----------------------------------------------------------------------
**
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.
  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.
ENDFORM.                    " add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0100_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .

  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
      I_BYPASSING_BUFFER   = ABAP_TRUE
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_100
      IT_SORT              = GT_SORT_0100
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0101 .

* 그리드 적용
  CREATE OBJECT GO_GRID_0101
    EXPORTING
      I_PARENT      = GO_CONTAIN_0101
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0101 .

  CLEAR GS_LAYOUT_0101.
  GS_LAYOUT_0101-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0101-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0101-NO_ROWMARK = ABAP_TRUE.
  GS_LAYOUT_0101-SEL_MODE   = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0101 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPI2040TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_101'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0101.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0101[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_101
    EXCEPTIONS
      OTHERS          = 1.


  LOOP AT GT_FIELDCAT_0101 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'ZIFKEY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '인터페이스키'(f01).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-NO_ZERO = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ZSYSTEM_ID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수신시스템'(f04).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'DDTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시스템내역'(f05).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ZZBUNDLE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '묶음오더'(f08).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'GONG_CD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정코드'(f09).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'JOBTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업구분'(f12).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ORDTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더유형'(f18).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ORDNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'(f19).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더품목번호'(f20).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'GRPNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장구성표번호'(f21).
        <LS_FCAT>-JUST = 'C'.

    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_0101 .

  REFRESH GT_EXCLUDE_0101.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0101
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0101_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0101_DISPLAY .

  CALL METHOD GO_GRID_0101->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0101
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0101
      I_BYPASSING_BUFFER   = ABAP_TRUE
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_101
      IT_SORT              = GT_SORT_0101
      IT_FIELDCATALOG      = GT_FIELDCAT_0101.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0102 .

* 그리드 적용
  CREATE OBJECT GO_GRID_0102
    EXPORTING
      I_PARENT      = GO_CONTAIN_0102
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0102 .

  CLEAR GS_LAYOUT_0102.
  GS_LAYOUT_0102-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0102-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0102-NO_ROWMARK = ABAP_TRUE.
  GS_LAYOUT_0102-SEL_MODE   = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0102 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPI2040TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_102'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0102.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0102[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_102
    EXCEPTIONS
      OTHERS          = 1.


  LOOP AT GT_FIELDCAT_0102 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'ZIFKEY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '인터페이스키'(f01).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-NO_ZERO = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ZSYSTEM_ID'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수신시스템'(f04).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'DDTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시스템내역'(f05).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ZZBUNDLE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '묶음오더'(f08).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'GONG_CD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정코드'(f09).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'JOBTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업구분'(f12).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ZCAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Cage'(f14).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'JAEJIL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '도체재질'(f22).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'SOSUN_DIA'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '소선경'(f23).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'YCOEF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연입률'(f24).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'ADLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업여장'(f25).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'BSMENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업량'(f26).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'BSLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기준권취량'(f27).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '권취개수'(f28).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '실권취량'(f29).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(f30).
        <LS_FCAT>-JUST = 'C'.

    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_0102 .

  REFRESH GT_EXCLUDE_0102.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0102
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0102_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0102_DISPLAY .

  CALL METHOD GO_GRID_0102->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0102
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0102
      I_BYPASSING_BUFFER   = ABAP_TRUE
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_102
      IT_SORT              = GT_SORT_0102
      IT_FIELDCATALOG      = GT_FIELDCAT_0102.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0100 .

  REFRESH GT_SORT_0100.
  IF P_SEND = ABAP_TRUE.
    PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                              USING : 1 'ZZBUNDLE' 'X' '' '',
                                         2 'ZWSEQ'  'X' '' '',
                                         3 'ZCAGE'  'X' '' ''.
  ELSE.
    PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                              USING : 1 'ZIFKEY' 'X' '' '',
                                         2 'ZZBUNDLE' 'X' '' '',
                                         3 'ZWSEQ'  'X' '' '',
                                         4 'ZCAGE'  'X' '' ''.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_TAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SORT_0100
*&      --> P_1
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SORT_TAB  TABLES   PT_SORTTAB STRUCTURE LVC_S_SORT
                   USING    PV_POS
                               PV_FIELDNAME
                               PV_UP
                               PV_DOWN
                               PV_SUBTOT.

  DATA : LS_SORT TYPE LVC_S_SORT.
  LS_SORT-SPOS = PV_POS.
  LS_SORT-FIELDNAME = PV_FIELDNAME.
  LS_SORT-UP = PV_UP.
  LS_SORT-DOWN = PV_DOWN.
  LS_SORT-SUBTOT =  PV_SUBTOT.
  APPEND LS_SORT TO PT_SORTTAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0101 .

  REFRESH GT_SORT_0101.
  IF P_SEND = ABAP_TRUE.
    PERFORM SET_SORT_TAB TABLES GT_SORT_0101
                              USING : 1 'ZZBUNDLE' 'X' '' '',
                                         2 'ORDTY'  'X' '' '',
                                         3 'ORDNR'  'X' '' '',
                                         4 'POSNR'  'X' '' ''.
  ELSE.
    PERFORM SET_SORT_TAB TABLES GT_SORT_0101
                              USING : 1 'ZIFKEY' 'X' '' '',
                                         2 'ZZBUNDLE' 'X' '' '',
                                         3 'ORDTY'  'X' '' '',
                                         4 'ORDNR'  'X' '' '',
                                         5 'POSNR'  'X' '' ''.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0102 .

  REFRESH GT_SORT_0102.
  IF P_SEND = ABAP_TRUE.
    PERFORM SET_SORT_TAB TABLES GT_SORT_0102
                              USING : 1 'ZZBUNDLE' 'X' '' '',
                                         2 'JAEJIL'  'X' '' '',
                                         3 'ZCAGE'  'X' '' ''.
  ELSE.
    PERFORM SET_SORT_TAB TABLES GT_SORT_0102
                              USING : 1 'ZIFKEY' 'X' '' '',
                                         2 'ZZBUNDLE' 'X' '' '',
                                         3 'JAEJIL'  'X' '' '',
                                         4 'ZCAGE'  'X' '' ''.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_CALL_RFC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CALL_RFC .

  DATA : LT_BUNDLE_IF  TYPE TABLE OF ZGTPPSIF0069. "신선오더정보
  DATA : LT_FOLLOW_IF  TYPE TABLE OF ZGTPPSIF0070. "후공정오더 정보
  DATA : LT_SOSUN_IF  TYPE TABLE OF ZGTPPSIF0071. "소선정보
  DATA : LV_RESULT  TYPE ZO_RESULT,
         LV_MESSAGE TYPE ZO_MESSAGE.

  DATA : LT_2440 TYPE TABLE OF ZGTPPT2440.
  DATA : LT_2441 TYPE TABLE OF ZGTPPT2441.
  DATA : LT_2442 TYPE TABLE OF ZGTPPT2442.
  DATA : LV_TIMESTAMP TYPE TIMESTAMPL.

  LOOP AT GT_ZZBUNDLE INTO DATA(LS_ZZBUNDLE).
    REFRESH LT_BUNDLE_IF.
    LT_BUNDLE_IF = VALUE #( FOR LW_BUNDLE IN GT_BUNDLE_IF WHERE ( ZZBUNDLE = LS_ZZBUNDLE-LOW )
                                     ( CORRESPONDING #(  LW_BUNDLE ) ) ).
    REFRESH LT_FOLLOW_IF.
    LT_FOLLOW_IF = VALUE #( FOR LW_FOLLOW IN GT_FOLLOW_IF WHERE ( ZZBUNDLE = LS_ZZBUNDLE-LOW )
                                     ( CORRESPONDING #(  LW_FOLLOW ) ) ).

    REFRESH LT_SOSUN_IF.
    LT_SOSUN_IF = VALUE #( FOR LS_SOSUN IN GT_SOSUN_IF WHERE ( ZZBUNDLE = LS_ZZBUNDLE-LOW )
                                     ( CORRESPONDING #(  LS_SOSUN ) ) ).


    PERFORM CALL_RFC TABLES LT_BUNDLE_IF LT_FOLLOW_IF LT_SOSUN_IF
                     USING LS_ZZBUNDLE-LOW
                   CHANGING LV_RESULT LV_MESSAGE.

*- History_Table에 저장
    IF LV_RESULT = '00' OR LV_RESULT = '0'.
      IF LV_MESSAGE IS INITIAL.
        LV_MESSAGE    = |전송성공|.
      ENDIF.
    ELSE.
      IF LV_MESSAGE IS INITIAL.
        LV_MESSAGE = |전송실패|.
      ENDIF.
    ENDIF.

    CLEAR LV_TIMESTAMP.
    GET TIME STAMP FIELD LV_TIMESTAMP.

    LOOP AT GT_MAIN_DISP_100 ASSIGNING FIELD-SYMBOL(<LS_MAIN_100>) WHERE ZZBUNDLE = LS_ZZBUNDLE-LOW.
      <LS_MAIN_100>-ZIFKEY = LV_TIMESTAMP.
      <LS_MAIN_100>-ZSYSTEM_ID = P_TARGET.
      CASE LV_RESULT.
        WHEN '00' OR '0'.
          <LS_MAIN_100>-ZSTAT = '00'.
          <LS_MAIN_100>-STATUS = ICON_LED_GREEN.
        WHEN OTHERS.
          <LS_MAIN_100>-ZSTAT = '02'.
          <LS_MAIN_100>-STATUS = ICON_LED_RED.
      ENDCASE.
      <LS_MAIN_100>-ZMESSAGE = LV_MESSAGE.
      APPEND INITIAL LINE TO LT_2440 ASSIGNING FIELD-SYMBOL(<LS_2440>).
      MOVE-CORRESPONDING <LS_MAIN_100> TO <LS_2440>.
      <LS_2440>-ZIFKEY = LV_TIMESTAMP.
      <LS_2440>-ZSYSTEM_ID = P_TARGET.
      <LS_2440>-IFDAT = SY-DATUM.
      <LS_2440>-IFTIM = SY-UZEIT.
      <LS_2440>-IFNAM = SY-UNAME.
    ENDLOOP.


    LOOP AT GT_MAIN_DISP_101 ASSIGNING FIELD-SYMBOL(<LS_MAIN_101>) WHERE ZZBUNDLE = LS_ZZBUNDLE-LOW.
      <LS_MAIN_101>-ZIFKEY = LV_TIMESTAMP.
      <LS_MAIN_101>-ZSYSTEM_ID = P_TARGET.
      APPEND INITIAL LINE TO LT_2441 ASSIGNING FIELD-SYMBOL(<LS_2441>).
      MOVE-CORRESPONDING <LS_MAIN_101> TO <LS_2441>.
      <LS_2441>-ZIFKEY = LV_TIMESTAMP.
      <LS_2441>-ZSYSTEM_ID = P_TARGET.
    ENDLOOP.

    LOOP AT GT_MAIN_DISP_102 ASSIGNING FIELD-SYMBOL(<LS_MAIN_102>) WHERE ZZBUNDLE = LS_ZZBUNDLE-LOW.
      <LS_MAIN_102>-ZIFKEY = LV_TIMESTAMP.
      <LS_MAIN_102>-ZSYSTEM_ID = P_TARGET.
      APPEND INITIAL LINE TO LT_2442 ASSIGNING FIELD-SYMBOL(<LS_2442>).
      MOVE-CORRESPONDING <LS_MAIN_102> TO <LS_2442>.
      <LS_2442>-ZIFKEY = LV_TIMESTAMP.
      <LS_2442>-ZSYSTEM_ID = P_TARGET.
    ENDLOOP.

  ENDLOOP.


  IF LT_2440[] IS NOT INITIAL.
    MODIFY ZGTPPT2440 FROM TABLE LT_2440.
  ENDIF.

  IF LT_2441[] IS NOT INITIAL.
    MODIFY ZGTPPT2441 FROM TABLE LT_2441.
  ENDIF.

  IF LT_2442[] IS NOT INITIAL.
    MODIFY ZGTPPT2442 FROM TABLE LT_2442.
  ENDIF.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_ONLINE_SEND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_ONLINE_SEND .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  IF LT_ROW[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '전송할 묶음오더 정보가 선택되지 않았습니다.'(m01).
  ELSE.

    CLEAR GV_ANSWER.
    PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
      ' '
      '선택된 묶음오더 정보 전송됩니다. 계속 진행 하시겠습니까?'
      '전송확인'.
    IF GV_ANSWER NE 'J'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
      RETURN.
    ENDIF.

  ENDIF.

  REFRESH GT_SGRPNR.

  LOOP AT   LT_ROW INTO LS_ROW.
    READ TABLE GT_MAIN_DISP_100 INTO DATA(LS_MAIN) INDEX LS_ROW-INDEX.

    APPEND INITIAL LINE TO GT_SGRPNR ASSIGNING FIELD-SYMBOL(<LS_SGRPNR>).
    <LS_SGRPNR>-SIGN = 'I'.
    <LS_SGRPNR>-OPTION = 'EQ'.
    SELECT SINGLE SGRPNR FROM ZGTPPT2011 INTO <LS_SGRPNR>-LOW
     WHERE ZZBUNDLE = LS_MAIN-ZZBUNDLE.

  ENDLOOP.

  SORT GT_SGRPNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM GT_SGRPNR COMPARING LOW.

  PERFORM MAKE_SEND_DATA.
  PERFORM PROC_CALL_RFC.


  PERFORM REFRESH_GRID USING GO_GRID_0100.
  PERFORM REFRESH_GRID USING GO_GRID_0101.
  PERFORM REFRESH_GRID USING GO_GRID_0102.

  MESSAGE S003 WITH '선택된 묶음오더 정보 전송되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm_step
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_STEP  USING LP_OPT
                                  LP_TEXT1
                                  LP_TEXT2
                                  LP_TITLE.
  CLEAR GV_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      DEFAULTOPTION  = LP_OPT
      TEXTLINE1      = LP_TEXT1
      TEXTLINE2      = LP_TEXT2
      TITEL          = LP_TITLE
      CANCEL_DISPLAY = ''
    IMPORTING
      ANSWER         = GV_ANSWER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_ONLINE_RESEND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_ONLINE_RESEND .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LT_MAIN_MOSU LIKE GT_MAIN_DISP_100.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  IF LT_ROW[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '재전송할 묶음오더 정보가 선택되지 않았습니다.'(m01).
  ELSE.

    CLEAR GV_ANSWER.
    PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
      ' '
      '선택된 묶음오더 정보 전송됩니다. 계속 진행 하시겠습니까?'
      '재전송확인'.
    IF GV_ANSWER NE 'J'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
      RETURN.
    ENDIF.

  ENDIF.

  REFRESH GT_ZZBUNDLE.

  LOOP AT   LT_ROW INTO LS_ROW.
    READ TABLE GT_MAIN_DISP_100 INTO DATA(LS_MAIN) INDEX LS_ROW-INDEX.
    APPEND LS_MAIN TO LT_MAIN_MOSU.

    APPEND INITIAL LINE TO GT_ZZBUNDLE ASSIGNING FIELD-SYMBOL(<LS_ZZBUNDLE>).
    <LS_ZZBUNDLE>-SIGN = 'I'.
    <LS_ZZBUNDLE>-OPTION = 'EQ'.
    <LS_ZZBUNDLE>-LOW = LS_MAIN-ZZBUNDLE.

  ENDLOOP.

  SORT LT_MAIN_MOSU BY ZIFKEY ZZBUNDLE.
  DELETE ADJACENT DUPLICATES FROM LT_MAIN_MOSU COMPARING  ZIFKEY ZZBUNDLE.

  SORT GT_ZZBUNDLE BY LOW.
  DELETE ADJACENT DUPLICATES FROM GT_ZZBUNDLE COMPARING LOW.

  PERFORM MAKE_RESEND_DATA TABLES LT_MAIN_MOSU.



  PERFORM REFRESH_GRID USING GO_GRID_0100.
  PERFORM REFRESH_GRID USING GO_GRID_0101.
  PERFORM REFRESH_GRID USING GO_GRID_0102.

  MESSAGE S003 WITH '선택된 묶음오더 정보 전송되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_RESEND_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_RESEND_DATA TABLES PT_MAIN STRUCTURE GS_MAIN_DISP_100.

  DATA : LT_BUNDLE_IF  TYPE TABLE OF ZGTPPSIF0069. "신선오더정보
  DATA : LT_FOLLOW_IF  TYPE TABLE OF ZGTPPSIF0070. "후공정오더 정보
  DATA : LT_SOSUN_IF  TYPE TABLE OF ZGTPPSIF0071. "소선정보
  DATA : LV_RESULT  TYPE ZO_RESULT,
         LV_MESSAGE TYPE ZO_MESSAGE.

  DATA : LT_2440 TYPE TABLE OF ZGTPPT2440.
  DATA : LT_2441 TYPE TABLE OF ZGTPPT2441.
  DATA : LT_2442 TYPE TABLE OF ZGTPPT2442.
  DATA : LV_TIMESTAMP TYPE TIMESTAMPL.

  REFRESH : GT_BUNDLE_IF, GT_FOLLOW_IF, GT_SOSUN_IF.

  LOOP AT GT_ZZBUNDLE INTO DATA(LS_ZZBUNDLE).
    SELECT SINGLE * FROM ZGTPPT2011
      INTO @DATA(LS_2011)
     WHERE ZZBUNDLE = @LS_ZZBUNDLE-LOW.

    PERFORM MAKE_DATA_BUNDLE USING '2' LS_2011 LS_2011-ZZBUNDLE.

    PERFORM MAKE_DATA_FOLLOW USING '2' LS_2011 LS_2011-ZZBUNDLE.

    PERFORM MAKE_DATA_SOSUN USING '2' LS_2011 LS_2011-ZZBUNDLE.

  ENDLOOP.

  LOOP AT GT_ZZBUNDLE INTO LS_ZZBUNDLE.

    REFRESH LT_BUNDLE_IF.
    LT_BUNDLE_IF = VALUE #( FOR LW_BUNDLE IN GT_BUNDLE_IF WHERE ( ZZBUNDLE = LS_ZZBUNDLE-LOW )
                                     ( CORRESPONDING #(  LW_BUNDLE ) ) ).
    REFRESH LT_FOLLOW_IF.
    LT_FOLLOW_IF = VALUE #( FOR LW_FOLLOW IN GT_FOLLOW_IF WHERE ( ZZBUNDLE = LS_ZZBUNDLE-LOW )
                                     ( CORRESPONDING #(  LW_FOLLOW ) ) ).

    REFRESH LT_SOSUN_IF.
    LT_SOSUN_IF = VALUE #( FOR LS_SOSUN IN GT_SOSUN_IF WHERE ( ZZBUNDLE = LS_ZZBUNDLE-LOW )
                                     ( CORRESPONDING #(  LS_SOSUN ) ) ).


    PERFORM CALL_RFC TABLES LT_BUNDLE_IF LT_FOLLOW_IF LT_SOSUN_IF
                     USING LS_ZZBUNDLE-LOW
                   CHANGING LV_RESULT LV_MESSAGE.

*- History_Table에 저장
    IF LV_RESULT = '00' OR LV_RESULT = '0'.
      IF LV_MESSAGE IS INITIAL.
        LV_MESSAGE    = |전송성공|.
      ENDIF.
    ELSE.
      IF LV_MESSAGE IS INITIAL.
        LV_MESSAGE = |전송실패|.
      ENDIF.
    ENDIF.

    CLEAR LV_TIMESTAMP.
    GET TIME STAMP FIELD LV_TIMESTAMP.
    LOOP AT LT_BUNDLE_IF INTO DATA(LS_BUNDLE_IF).
      APPEND INITIAL LINE TO LT_2440 ASSIGNING FIELD-SYMBOL(<LS_2440>).
      MOVE-CORRESPONDING LS_BUNDLE_IF TO <LS_2440>.
      <LS_2440>-ZIFKEY = LV_TIMESTAMP.
      <LS_2440>-ZSYSTEM_ID = P_TARGET.
      CASE LV_RESULT.
        WHEN '00' OR '0'.
          <LS_2440>-ZSTAT = '00'.
        WHEN OTHERS.
          <LS_2440>-ZSTAT = '02'.
      ENDCASE.
      <LS_2440>-ZMESSAGE = LV_MESSAGE.
      <LS_2440>-IFDAT = SY-DATUM.
      <LS_2440>-IFTIM = SY-UZEIT.
      <LS_2440>-IFNAM = SY-UNAME.
    ENDLOOP.

    LOOP AT LT_FOLLOW_IF INTO DATA(LS_FOLLOW_IF).
      APPEND INITIAL LINE TO LT_2441 ASSIGNING FIELD-SYMBOL(<LS_2441>).
      MOVE-CORRESPONDING LS_FOLLOW_IF TO <LS_2441>.
      <LS_2441>-ZIFKEY = LV_TIMESTAMP.
      <LS_2441>-ZSYSTEM_ID = P_TARGET.
    ENDLOOP.

    LOOP AT LT_SOSUN_IF INTO DATA(LS_SOSUN_IF).
      APPEND INITIAL LINE TO LT_2442 ASSIGNING FIELD-SYMBOL(<LS_2442>).
      MOVE-CORRESPONDING LS_SOSUN_IF TO <LS_2442>.
      <LS_2441>-ZIFKEY = LV_TIMESTAMP.
      <LS_2441>-ZSYSTEM_ID = P_TARGET.
    ENDLOOP.

    LOOP AT GT_MAIN_DISP_100 ASSIGNING FIELD-SYMBOL(<LS_MAIN_100>) WHERE ZZBUNDLE = LS_ZZBUNDLE-LOW.
      CASE LV_RESULT.
        WHEN '00' OR '0'.
          <LS_MAIN_100>-ZSTAT = '00'.
          <LS_MAIN_100>-STATUS = ICON_LED_GREEN.
          <LS_MAIN_100>-ZMESSAGE = '재전송 성공'.
        WHEN OTHERS.
          <LS_MAIN_100>-ZSTAT = '02'.
          <LS_MAIN_100>-STATUS = ICON_LED_RED.
          <LS_MAIN_100>-ZMESSAGE = '재전송 실패'.
      ENDCASE.

    ENDLOOP.
  ENDLOOP.

  IF LT_2440[] IS NOT INITIAL.
    MODIFY ZGTPPT2440 FROM TABLE LT_2440.
  ENDIF.

  IF LT_2441[] IS NOT INITIAL.
    MODIFY ZGTPPT2441 FROM TABLE LT_2441.
  ENDIF.

  IF LT_2442[] IS NOT INITIAL.
    MODIFY ZGTPPT2442 FROM TABLE LT_2442.
  ENDIF.

  COMMIT WORK AND WAIT.

ENDFORM.
