*&---------------------------------------------------------------------*
*& Include          ZGTPPR2300F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_SELECTION_PERIOD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SELECTION_PERIOD .

  IF S_DATE[] IS NOT INITIAL.
    READ TABLE S_DATE INDEX 1.
  ENDIF.

  REFRESH S_DATE[].
  S_DATE-SIGN = 'I'.
  S_DATE-OPTION = 'BT'.


  IF S_DATE-LOW IS INITIAL.
    CALL FUNCTION '/BEV4/PLPS__ADD_MONTH_TO_DATE'
      EXPORTING
        MONTHS  = '-6'
        OLDDATE = SY-DATUM
      IMPORTING
        NEWDATE = S_DATE-LOW.
  ENDIF.

  IF S_DATE-HIGH IS INITIAL.
    CALL FUNCTION '/BEV4/PLPS__ADD_MONTH_TO_DATE'
      EXPORTING
        MONTHS  = '6'
        OLDDATE = SY-DATUM
      IMPORTING
        NEWDATE = S_DATE-HIGH.
  ENDIF.
  APPEND S_DATE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PARAMETER_DESCRIPTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PARAMETER_DESCRIPTION .

* SPG
  IF NOT P_SPGCD IS INITIAL.
    CLEAR ZPPT0107.
    SELECT SINGLE DESCR INTO P_DESCR
             FROM ZPPT0107
            WHERE SPGCD EQ P_SPGCD.
  ELSE.
    CLEAR P_DESCR.
  ENDIF.

* 플랜트명
  IF NOT P_WERKS IS INITIAL.
    CLEAR T001W.
    SELECT SINGLE NAME1 INTO P_NAME1
             FROM T001W
            WHERE WERKS EQ P_WERKS.
  ELSE.
    CLEAR P_NAME1.
  ENDIF.

* 납품처
  IF NOT P_KUNNR IS INITIAL.
    CLEAR KNA1.
    SELECT SINGLE NAME1 INTO P_NAME2
             FROM KNA1
            WHERE KUNNR EQ P_KUNNR.
  ELSE.
    CLEAR P_NAME2.
  ENDIF.

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
    IF SCREEN-GROUP1 = 'M1'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.
    IF SCREEN-GROUP1 = 'M2'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_ORDNO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_ORDNO  USING    PV_DYNPROFLD TYPE HELP_INFO-DYNPROFLD .

  DATA : BEGIN OF LS_ORDNO,
           ORDNO TYPE ZGTPPT2001-ORDNO,
           POSNR TYPE ZGTPPT2001-POSNR,
           WERKS TYPE ZGTPPT2001-WERKS,
           SPGCD TYPE ZGTPPT2001-SPGCD,
         END OF LS_ORDNO.
  DATA : LT_ORDNO LIKE TABLE OF LS_ORDNO.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LV_OFFSET(6) TYPE N.
  DATA : LO_FLIEF TYPE REF TO DATA.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

  PERFORM GET_DYNP_VALUE USING 'P_WERKS'.
  PERFORM GET_DYNP_VALUE USING 'P_SPGCD'.

  CHECK P_WERKS IS NOT INITIAL AND P_SPGCD IS NOT INITIAL.

  REFRESH LT_ORDNO.
  SELECT ORDNO POSNR WERKS SPGCD
    FROM ZGTPPT2001
    INTO CORRESPONDING FIELDS OF TABLE LT_ORDNO
   WHERE WERKS = P_WERKS
      AND SPGCD = P_SPGCD.

  FREE LO_FLIEF.
  CREATE DATA LO_FLIEF LIKE LS_ORDNO.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).

    CASE <LS_FIELD_TAB>-FIELDNAME.
      WHEN 'ORDNO'.
        <LS_FIELD_TAB>-REPTEXT  = '오더번호'.
      WHEN 'POSNR'.
        <LS_FIELD_TAB>-REPTEXT  = '항목'.
      WHEN 'WERKS'.
        <LS_FIELD_TAB>-REPTEXT  = '플랜트'.
      WHEN 'SPGCD'.
        <LS_FIELD_TAB>-REPTEXT  = 'SPG 코드'.
    ENDCASE.

    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'ORDNO'
      DYNPROFIELD     = PV_DYNPROFLD           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = 'SM 오더 조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = LT_ORDNO
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    READ TABLE LT_ORDNO INTO LS_ORDNO WITH KEY  ORDNO = LS_RETURN_TAB-FIELDVAL.
    IF SY-SUBRC EQ 0.

      REFRESH LT_DYNPFIELDS.
      PERFORM GET_STEPL USING LV_LINE.
*      SM 오더번호
      APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
      <LS_DYNPFIELDS>-FIELDNAME = PV_DYNPROFLD.
      <LS_DYNPFIELDS>-STEPL = LV_LINE.
      <LS_DYNPFIELDS>-FIELDVALUE = LS_ORDNO-ORDNO.


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
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DYNP_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM GET_DYNP_VALUE  USING  PV_FIELDNAME TYPE DYNPREAD-FIELDNAME.

  ASSIGN (PV_FIELDNAME) TO FIELD-SYMBOL(<LV_VALUE>).

  CALL FUNCTION 'GET_DYNP_VALUE'
    EXPORTING
      I_FIELD = PV_FIELDNAME
      I_REPID = SY-CPROG
      I_DYNNR = SY-DYNNR
    CHANGING
      O_VALUE = <LV_VALUE>.

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
*& Form AUTHORITY_CHECKING_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECKING_PROC .

*& MRP관리자에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_SPGCD'
  ID 'WERKS'  FIELD P_WERKS
  ID 'SPGCD'  FIELD P_SPGCD.

  IF SY-SUBRC <> 0.
    MESSAGE E006 WITH 'SPG[' P_SPGCD
                      '] 작업권한을 확인하세요.'.
  ENDIF.

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

  PERFORM GET_MOSU.
  PERFORM SET_DISP_MAIN.
  PERFORM GET_SET_REGISTERED_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DISP .
  CALL SCREEN '0100'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MOSU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_MOSU .

  DATA : LT_2000 TYPE TABLE OF ZGTPPT2000.
  DATA : LT_GRPNR TYPE RANGE OF ZGTPPT2000-GRPNR.
  RANGES : LT_KUNNR FOR KNA1-KUNNR.
  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.

  IF P_KUNNR IS NOT INITIAL.
    APPEND INITIAL LINE TO LT_KUNNR ASSIGNING FIELD-SYMBOL(<LS_KUNNR>).
    IF P_KUNNR CO '*'.
      <LS_KUNNR> = VALUE #( SIGN = 'I' OPTION = 'CP' LOW = P_KUNNR ).
    ELSE.
      <LS_KUNNR> = VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = P_KUNNR ).
    ENDIF.
  ENDIF.

* 조장구성표 기준으로 모수 가져온다.
* 반제품 생산 요청된 테이블 조회
  SELECT * FROM ZGTPPT2000
    INTO TABLE GT_2000
    WHERE WERKS = P_WERKS
      AND SPGCD = P_SPGCD
      AND RQMON = P_SPMON
      AND ZSTATUS NE 'D'.

  REFRESH LT_2000.
* 요청대상 조회

  IF S_VBELN[] IS INITIAL AND S_AUFNR[] IS INITIAL.
    SELECT * FROM ZGTPPT2000
      WHERE WERKS = @P_WERKS
        AND SPGCD = @P_SPGCD
        AND RQMON IS INITIAL
        AND MATNR IN @S_MATNR
        AND MAKTX IN @S_MAKTX
        AND GRPNR IN @S_GRPNR
        AND EDATU IN @S_DATE
        AND KUNNR IN @LT_KUNNR
        AND ZSTATUS NE 'D'
       INTO TABLE @LT_2000.
  ELSE.
    IF S_VBELN[] IS NOT INITIAL.
      SELECT * FROM ZGTPPT2000
        WHERE WERKS = @P_WERKS
          AND SPGCD = @P_SPGCD
          AND RQMON IS INITIAL
          AND ORDNO IN @S_VBELN
          AND GCATG IN ( '판매오더', '견적' )
          AND MATNR IN @S_MATNR
          AND MAKTX IN @S_MAKTX
          AND GRPNR IN @S_GRPNR
          AND EDATU IN @S_DATE
          AND KUNNR IN @LT_KUNNR
          AND ZSTATUS NE 'D'
        INTO TABLE @LT_2000.
    ENDIF.

    IF S_AUFNR[] IS NOT INITIAL.
      SELECT * FROM ZGTPPT2000
        WHERE WERKS = @P_WERKS
          AND SPGCD = @P_SPGCD
          AND RQMON IS INITIAL
          AND ORDNO IN @S_AUFNR
          AND GCATG IN ( '생산오더' )
          AND MATNR IN @S_MATNR
          AND MAKTX IN @S_MAKTX
          AND GRPNR IN @S_GRPNR
          AND EDATU IN @S_DATE
          AND KUNNR IN @LT_KUNNR
          AND ZSTATUS NE 'D'
        APPENDING TABLE @LT_2000.
    ENDIF.
  ENDIF.

  REFRESH LT_GRPNR.
  LT_GRPNR = VALUE #( FOR LW_2000 IN LT_2000 WHERE ( GRPNR IS NOT INITIAL )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2000-GRPNR ) ).

  IF LT_GRPNR[] IS NOT INITIAL.
    SORT LT_GRPNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_GRPNR COMPARING LOW.

    SELECT * FROM ZGTPPT2000
      WHERE WERKS = @P_WERKS
        AND SPGCD = @P_SPGCD
        AND RQMON IS INITIAL
        AND GRPNR IN @LT_GRPNR
      APPENDING TABLE @GT_2000.
  ENDIF.

* 조장정보 기준으로 조장구성체인에서 제일 첫 공정의 오더를 찾아온다.
  REFRESH LT_GRPNR.
  LT_GRPNR = VALUE #( FOR LW_2000 IN GT_2000 WHERE ( GRPNR IS NOT INITIAL )
                            ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2000-GRPNR ) ).

  IF LT_GRPNR[] IS NOT INITIAL.
    SORT LT_GRPNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_GRPNR COMPARING LOW.

    SELECT DISTINCT GRPNR, MIN( GONG_SEQ ) AS GONG_SEQ
       FROM ZGTPPT2010
      WHERE GRPNR IN @LT_GRPNR
      GROUP BY GRPNR
         INTO TABLE @DATA(LT_CHK_JOJANG).

    SELECT DISTINCT B~*
      FROM @LT_CHK_JOJANG AS A
      INNER JOIN ZGTPPT2010 AS B ON B~GRPNR = A~GRPNR
                                            AND B~GONG_SEQ = A~GONG_SEQ
       WHERE B~ORDTY = 'PRD'
       INTO TABLE @GT_2010.

    SELECT DISTINCT C~*
      FROM @LT_CHK_JOJANG AS A
      INNER JOIN ZGTPPT2010 AS B ON B~GRPNR = A~GRPNR
                                            AND B~GONG_SEQ = A~GONG_SEQ
      INNER JOIN ZGTPPT2010 AS C ON C~GRPNR = A~GRPNR
                                            AND C~GONG_CD = B~GONG_CD
      WHERE B~GONG_SEQ < C~GONG_SEQ
         AND B~ORDTY = 'PRD'
       APPENDING TABLE @GT_2010.

    SELECT * FROM ZGTPPT2010
      INTO TABLE GT_2010_FUL
     WHERE GRPNR IN LT_GRPNR.

* 조장구성표의 최초 공정 구성부품 확인하여, 이후 연결된 반제품이 존재 하는지 확인.
*  - 반제품이 없다면 대상 아님
    LT_AUFNR = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( ORDNR IS NOT INITIAL
                                                                    AND   ORDTY = 'PRD' )
                                ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2010-ORDNR ) ).

    IF LT_AUFNR[] IS NOT INITIAL.
      SELECT DISTINCT A~AUFNR
        FROM AFKO AS A
        INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
        INNER JOIN MARA AS C ON C~MATNR = B~MATNR
        INNER JOIN MARC AS D ON D~MATNR = B~MATNR
       WHERE C~MTART = 'MCHF'
           AND D~WERKS = @P_WERKS
           AND ( D~BESKZ = 'E' OR
                 ( D~BESKZ = 'F' AND
                   D~SOBSL = 30 ) OR
                 ( D~BESKZ = 'F' AND
                   D~SOBSL LIKE '4%' ) OR
                   D~BESKZ = 'X'  )
           AND B~KZKUP = ' '
           AND A~AUFNR IN @LT_AUFNR
          INTO TABLE @DATA(LT_CHK_RESB).
    ENDIF.

    SORT LT_CHK_RESB BY AUFNR.

    LOOP AT GT_2010 INTO DATA(LS_2010_CHK).
      READ TABLE LT_CHK_RESB TRANSPORTING NO FIELDS WITH KEY AUFNR = LS_2010_CHK-ORDNR.
      IF SY-SUBRC NE 0.
        READ TABLE GT_2010_FUL TRANSPORTING NO FIELDS WITH KEY GRPNR = LS_2010_CHK-GRPNR.
        IF SY-SUBRC EQ 0.
          DELETE GT_2010_FUL WHERE GRPNR = LS_2010_CHK-GRPNR..
        ENDIF.

        DELETE TABLE GT_2010 FROM LS_2010_CHK.
      ENDIF.
    ENDLOOP.

  ENDIF.

* 작업 요청된 모수 추출
  SELECT * FROM ZGTPPT2330
    INTO TABLE GT_2330
   WHERE WERKS = P_WERKS
     AND SPGCD = P_SPGCD
     AND RQMON = P_SPMON
     AND ZDISTRIB = '1'
     AND ZOEM = ' '.

  SELECT * FROM ZGTPPT2340
    INTO TABLE GT_2340
   WHERE WERKS = P_WERKS
     AND SPGCD = P_SPGCD
     AND RQMON = P_SPMON.

* 자재특성정보 확인
  REFRESH LT_MATNR.
  LT_MATNR = VALUE #( FOR LW_2010 IN GT_2010_FUL WHERE ( MATNR IS NOT INITIAL )
                                 ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2010-MATNR ) ).

  IF LT_MATNR IS NOT INITIAL.
    SELECT * FROM ZGTCVMSTVAL
      APPENDING TABLE GT_CVMVAL
     WHERE WERKS = P_WERKS
        AND MATNR IN LT_MATNR.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP_MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DISP_MAIN .

  DATA : LS_ORDSYVAL TYPE ZGTCVORDSYVAL.
  DATA : LT_ORDSYVAL TYPE TABLE OF ZGTCVORDSYVAL.
  DATA : LV_ORDNO_C(12).
  DATA : LV_POSNR_C(6).
  DATA : LS_CHK_2000 TYPE ZGTPPT2000.
  DATA : LS_CHK_2010 TYPE ZGTPPT2010.
  DATA : LS_DM_2010 TYPE ZGTPPT2010.
  DATA : LT_CHK_2340 TYPE TABLE OF ZGTPPT2340.
  DATA : LV_OBJNR TYPE JEST-OBJNR.
  DATA : LV_USER_LINE TYPE BSVX-STTXT.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : LV_CHK_EXIST.

  REFRESH GT_MAIN_DISP.
  REFRESH GT_ORDSYVAL.

  LT_CHK_2340 = GT_2340.

  LOOP AT GT_2010 INTO DATA(LS_2010_ORDNR)  WHERE ORDTY = 'PRD'.
    APPEND INITIAL LINE TO LT_AUFNR ASSIGNING FIELD-SYMBOL(<LS_AUFNR>).
    <LS_AUFNR>-SIGN = 'I'.
    <LS_AUFNR>-OPTION = 'EQ'.
    <LS_AUFNR>-LOW = LS_2010_ORDNR-ORDNR.
  ENDLOOP.

  LOOP AT GT_2340 INTO DATA(LS_2340_ORDNR)   WHERE ORDTY = 'PRD'.
    APPEND INITIAL LINE TO LT_AUFNR ASSIGNING <LS_AUFNR>.
    <LS_AUFNR>-SIGN = 'I'.
    <LS_AUFNR>-OPTION = 'EQ'.
    <LS_AUFNR>-LOW = LS_2340_ORDNR-ORDNR.
  ENDLOOP.

  IF LT_AUFNR IS NOT INITIAL.
    SORT LT_AUFNR BY LOW .
    DELETE ADJACENT DUPLICATES FROM LT_AUFNR COMPARING LOW.
    SELECT DISTINCT *
      FROM ZGTCVORDSYVAL
      INTO TABLE GT_ORDSYVAL
    WHERE AUFNR IN LT_AUFNR
      AND WERKS = P_WERKS.
  ENDIF.


  LOOP AT GT_2010 INTO DATA(LS_2010).
    CLEAR GS_MAIN_DISP.
    GS_MAIN_DISP-SEQNO = 9.
    READ TABLE LT_CHK_2340 INTO DATA(LS_2340) WITH KEY ORDNR = LS_2010-ORDNR
                                                                     POSNR = LS_2010-POSNR
                                                                   ORDTY = 'PRD'.
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP-SEQNO = 1.
      GS_MAIN_DISP-CHK_PROC = ABAP_TRUE.
      DELETE TABLE LT_CHK_2340 FROM LS_2340.
    ENDIF.

* 작업지시
    CLEAR LS_ORDSYVAL.
    READ TABLE GT_ORDSYVAL INTO LS_ORDSYVAL WITH KEY AUFNR = LS_2010-ORDNR.
*    SELECT SINGLE * FROM ZGTCVORDSYVAL
*      INTO LS_ORDSYVAL
*     WHERE AUFNR = LS_2010-ORDNR.

    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP-PSMNG = LS_ORDSYVAL-PSMNG + LS_ORDSYVAL-PSAMG.
      IF  LS_ORDSYVAL-TERKZ = '7'.
        GS_MAIN_DISP-CHK_CONFIRM = ABAP_TRUE.
      ENDIF.

*오더상태
      IF LS_ORDSYVAL-DLV = ABAP_TRUE.
        GS_MAIN_DISP-ORD_STAT = '작업완료'.
      ELSEIF LS_ORDSYVAL-PDLV = ABAP_TRUE.
        GS_MAIN_DISP-ORD_STAT = '작업중'.
      ELSEIF LS_ORDSYVAL-REL = ABAP_TRUE.
        GS_MAIN_DISP-ORD_STAT = '릴리즈'.
      ELSE.
        GS_MAIN_DISP-ORD_STAT = '생성'.
      ENDIF.

* pay off상태 확인
      CASE GS_MAIN_DISP-ORD_STAT.
        WHEN '릴리즈' OR '생성'.
          LV_OBJNR = 'OR' && LS_ORDSYVAL-AUFNR.
          CALL FUNCTION 'STATUS_TEXT_EDIT'
            EXPORTING
              FLG_USER_STAT    = 'X'
              OBJNR            = LV_OBJNR
              ONLY_ACTIVE      = 'X'
              SPRAS            = SY-LANGU
              BYPASS_BUFFER    = 'X'
            IMPORTING
              USER_LINE        = LV_USER_LINE
            EXCEPTIONS
              OBJECT_NOT_FOUND = 1
              OTHERS           = 2.

          FIND ALL OCCURRENCES OF 'PAYO' IN LV_USER_LINE MATCH COUNT DATA(LV_LINE).
          IF LV_LINE > 0. " Patoff 상태일지 작업중으로 변경
            GS_MAIN_DISP-ORD_STAT = '작업중'.
          ENDIF.
      ENDCASE.

    ENDIF.

* 색상
* 조달유형
    READ TABLE GT_CVMVAL INTO DATA(LS_CVMVAL) WITH KEY MATNR = LS_2010-MATNR.
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP-MATNR = LS_2010-MATNR.
      GS_MAIN_DISP-GONG_CD = LS_CVMVAL-PDCAPROCCODE.
      GS_MAIN_DISP-GONG_NM = LS_CVMVAL-PDCAPROCNAME.
      GS_MAIN_DISP-MAKTX = LS_CVMVAL-MAKTX.
      .
      IF LS_CVMVAL-COLORBASE IS NOT INITIAL.
        GS_MAIN_DISP-COLOR = LS_CVMVAL-COLORBASE.
      ENDIF.
    ENDIF.

    GS_MAIN_DISP-GRPNR = LS_2010-GRPNR.
    GS_MAIN_DISP-AUFNR = LS_2010-ORDNR.
    __ALPHA_OUT GS_MAIN_DISP-AUFNR.
    GS_MAIN_DISP-POSNR = LS_2010-POSNR + 0.
    GS_MAIN_DISP-INLENGTH = LS_2010-INLENGTH.
    GS_MAIN_DISP-INFACTOR = LS_2010-INFACTOR.

    CLEAR LS_CHK_2010.
    LS_CHK_2010 = LS_2010.
* 상위 오더 정보
    DO.
      CASE LS_CHK_2010-DMORDTY.
        WHEN 'SO' OR 'SM'.
          EXIT.
        WHEN OTHERS.
          CLEAR LS_DM_2010.
          CLEAR LV_CHK_EXIST.
          LOOP AT GT_2010_FUL INTO LS_DM_2010 WHERE GRPNR = LS_CHK_2010-GRPNR
                                                                 AND GONG_SEQ > LS_CHK_2010-GONG_SEQ
                                                                 AND ORDNR = LS_CHK_2010-DMORD
                                                                 AND POSNR = LS_CHK_2010-DMLINE.

            CLEAR LS_CHK_2010.
            LS_CHK_2010 = LS_DM_2010.
            LV_CHK_EXIST = ABAP_TRUE.
            EXIT.

          ENDLOOP.

          IF LV_CHK_EXIST IS INITIAL.

            LOOP AT GT_2010_FUL INTO LS_DM_2010 WHERE GRPNR = LS_CHK_2010-GRPNR
                                                                             AND GONG_SEQ > LS_CHK_2010-GONG_SEQ
                                                                             AND REORD = LS_CHK_2010-ORDNR
                                                                             AND RELINE = LS_CHK_2010-POSNR.

              CLEAR LS_CHK_2010.
              LS_CHK_2010 = LS_DM_2010.
              LV_CHK_EXIST = ABAP_TRUE.
              EXIT.
            ENDLOOP.

          ENDIF.

          IF LV_CHK_EXIST IS INITIAL.
            EXIT.
          ENDIF.
      ENDCASE.
    ENDDO.

    CLEAR  LS_CHK_2000.
    READ TABLE GT_2000 INTO LS_CHK_2000 WITH KEY GRPNR = LS_CHK_2010-GRPNR
                                                                     ORDNO = LS_CHK_2010-DMORD
                                                                     POSNR = LS_CHK_2010-DMLINE.
    IF SY-SUBRC EQ 0.
      CASE LS_CHK_2010-DMORDTY.
        WHEN 'SO'.
          GS_MAIN_DISP-GCATG = '판매오더'.
          GS_MAIN_DISP-ZZYUSCD = LS_CHK_2000-ZZYUSCD.

          GS_MAIN_DISP-KUNNR = LS_CHK_2000-KUNNR.
          SELECT SINGLE NAME1 FROM KNA1
            INTO GS_MAIN_DISP-NAME1
           WHERE KUNNR = LS_CHK_2000-KUNNR.

          SELECT SINGLE VBELN, POSNR, KWMENG, VRKME, CUOBJ
            FROM VBAP
            INTO @DATA(LS_VBAP)
           WHERE VBELN = @LS_CHK_2000-ORDNO
             AND POSNR = @LS_CHK_2000-POSNR.
          IF SY-SUBRC EQ 0.
            GS_MAIN_DISP-SO_WMENG = LS_VBAP-KWMENG.
            GS_MAIN_DISP-SO_VRKME = LS_VBAP-VRKME.
*조장수
            ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
              EXPORTING
                IV_CUOBJ      = LS_VBAP-CUOBJ                 " 구성
              IMPORTING
                EV_SO_INDLEN = GS_MAIN_DISP-SO_INLENGTH ).

          ENDIF.
          GS_MAIN_DISP-CHAR = ICON_CHARACTERISTICS_ACT.
          GS_MAIN_DISP-SNOTE2 = ICON_DISPLAY_TEXT.

        WHEN 'SM'.
          GS_MAIN_DISP-GCATG = '생산오더'.
          GS_MAIN_DISP-ZZYUSCD = '생관'.
      ENDCASE.

      CLEAR : LV_ORDNO_C, LV_POSNR_C.
      LV_ORDNO_C = LS_CHK_2010-DMORD.
      LV_POSNR_C = LS_CHK_2010-DMLINE.
      __ALPHA_OUT : LV_ORDNO_C, LV_POSNR_C.
      GS_MAIN_DISP-REQ_FACTOR = LV_ORDNO_C && '/' && LV_POSNR_C.
      GS_MAIN_DISP-DMORD = LS_CHK_2010-DMORD.
      GS_MAIN_DISP-DMLINE = LS_CHK_2010-DMLINE.

      GS_MAIN_DISP-MEINS = LS_CHK_2000-MEINS.
      READ TABLE GT_CVMVAL INTO LS_CVMVAL WITH KEY MATNR = LS_CHK_2000-MATNR.
      IF SY-SUBRC EQ 0.
        GS_MAIN_DISP-ZSPECNO = LS_CVMVAL-PDCASPECNO.
      ENDIF.

      GS_MAIN_DISP-EDATU = LS_CHK_2000-EDATU.
      GS_MAIN_DISP-SNOTE = ICON_DISPLAY_TEXT.

      APPEND GS_MAIN_DISP TO GT_MAIN_DISP.
    ENDIF.
  ENDLOOP.


*&---------------------------------------------------------------------*
* pegging 처리된 오더정보 보여준다.
  IF LT_CHK_2340[] IS NOT INITIAL.
    LOOP AT LT_CHK_2340 INTO LS_2340.
      CLEAR GS_MAIN_DISP.
      GS_MAIN_DISP-SEQNO = 1.
      GS_MAIN_DISP-CHK_PROC = ABAP_TRUE.
      GS_MAIN_DISP-CHK_CONFIRM = ABAP_TRUE.
      GS_MAIN_DISP-CHK_PEGGING = ABAP_TRUE.

* 작업지시
      CLEAR LS_ORDSYVAL.
      READ TABLE GT_ORDSYVAL INTO LS_ORDSYVAL WITH KEY AUFNR = LS_2340-ORDNR.
*      SELECT SINGLE * FROM ZGTCVORDSYVAL
*        INTO LS_ORDSYVAL
*       WHERE AUFNR = LS_2340-ORDNR.

      IF SY-SUBRC EQ 0.
        GS_MAIN_DISP-PSMNG = LS_ORDSYVAL-PSMNG + LS_ORDSYVAL-PSAMG.
        IF  LS_ORDSYVAL-TERKZ = '7'.
          GS_MAIN_DISP-CHK_CONFIRM = ABAP_TRUE.
        ENDIF.

*오더상태
        IF LS_ORDSYVAL-DLV = ABAP_TRUE.
          GS_MAIN_DISP-ORD_STAT = '작업완료'.
        ELSEIF LS_ORDSYVAL-PDLV = ABAP_TRUE.
          GS_MAIN_DISP-ORD_STAT = '작업중'.
        ELSEIF LS_ORDSYVAL-REL = ABAP_TRUE.
          GS_MAIN_DISP-ORD_STAT = '릴리즈'.
        ELSE.
          GS_MAIN_DISP-ORD_STAT = '생성'.
        ENDIF.

* pay off상태 확인
        CASE GS_MAIN_DISP-ORD_STAT.
          WHEN '릴리즈' OR '생성'.
            LV_OBJNR = 'OR' && LS_ORDSYVAL-AUFNR.
            CALL FUNCTION 'STATUS_TEXT_EDIT'
              EXPORTING
                FLG_USER_STAT    = 'X'
                OBJNR            = LV_OBJNR
                ONLY_ACTIVE      = 'X'
                SPRAS            = SY-LANGU
                BYPASS_BUFFER    = 'X'
              IMPORTING
                USER_LINE        = LV_USER_LINE
              EXCEPTIONS
                OBJECT_NOT_FOUND = 1
                OTHERS           = 2.

            CLEAR LV_LINE.
            FIND ALL OCCURRENCES OF 'PAYO' IN LV_USER_LINE MATCH COUNT LV_LINE.
            IF LV_LINE > 0. " Patoff 상태일지 작업중으로 변경
              GS_MAIN_DISP-ORD_STAT = '작업중'.
            ENDIF.
        ENDCASE.

      ENDIF.

* 색상
* 조달유형
      READ TABLE GT_CVMVAL INTO LS_CVMVAL WITH KEY MATNR = LS_2340-MATNR.
      IF SY-SUBRC EQ 0.
        GS_MAIN_DISP-MATNR = LS_2340-MATNR.
        GS_MAIN_DISP-GONG_CD = LS_CVMVAL-PDCAPROCCODE.
        GS_MAIN_DISP-GONG_NM = LS_CVMVAL-PDCAPROCNAME.
        GS_MAIN_DISP-MAKTX = LS_CVMVAL-MAKTX.
        .
        IF LS_CVMVAL-COLORBASE IS NOT INITIAL.
          GS_MAIN_DISP-COLOR = LS_CVMVAL-COLORBASE.
        ENDIF.
      ENDIF.

      READ TABLE GT_2330 INTO DATA(LS_2330) WITH KEY ZWKREQ = LS_2340-ZWKREQ.

      GS_MAIN_DISP-GRPNR = LS_2330-GRPNR.
      GS_MAIN_DISP-AUFNR = LS_2340-ORDNR.
      __ALPHA_OUT GS_MAIN_DISP-AUFNR.
      GS_MAIN_DISP-POSNR = LS_2340-POSNR + 0.
      GS_MAIN_DISP-INLENGTH = LS_2340-INLENGTH.
      GS_MAIN_DISP-INFACTOR = LS_2340-INFACTOR.


      CLEAR  LS_CHK_2000.
      READ TABLE GT_2000 INTO LS_CHK_2000 WITH KEY GRPNR = LS_2330-GRPNR
                                                                       ORDNO = LS_2330-DMORD
                                                                       POSNR = LS_2330-DMLINE.
      IF SY-SUBRC EQ 0.
        CASE LS_CHK_2000-GCATG.
          WHEN '생산오더'.
            GS_MAIN_DISP-GCATG = '생산오더'.
            GS_MAIN_DISP-ZZYUSCD = '생관'.
          WHEN OTHERS.
            GS_MAIN_DISP-GCATG = '판매오더'.
            GS_MAIN_DISP-ZZYUSCD = LS_CHK_2000-ZZYUSCD.

            GS_MAIN_DISP-KUNNR = LS_CHK_2000-KUNNR.
            SELECT SINGLE NAME1 FROM KNA1
              INTO GS_MAIN_DISP-NAME1
             WHERE KUNNR = LS_CHK_2000-KUNNR.

            CLEAR LS_VBAP.
            SELECT SINGLE VBELN, POSNR, KWMENG, VRKME, CUOBJ
              FROM VBAP
              INTO @LS_VBAP
             WHERE VBELN = @LS_CHK_2000-ORDNO
               AND POSNR = @LS_CHK_2000-POSNR.
            IF SY-SUBRC EQ 0.
              GS_MAIN_DISP-SO_WMENG = LS_VBAP-KWMENG.
              GS_MAIN_DISP-SO_VRKME = LS_VBAP-VRKME.
*조장수
              ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
                EXPORTING
                  IV_CUOBJ      = LS_VBAP-CUOBJ                 " 구성
                IMPORTING
                  EV_SO_INDLEN = GS_MAIN_DISP-SO_INLENGTH ).

            ENDIF.
            GS_MAIN_DISP-CHAR = ICON_CHARACTERISTICS_ACT.
            GS_MAIN_DISP-SNOTE2 = ICON_DISPLAY_TEXT.
        ENDCASE.

        CLEAR : LV_ORDNO_C, LV_POSNR_C.
        LV_ORDNO_C = LS_CHK_2000-ORDNO.
        LV_POSNR_C = LS_CHK_2000-POSNR.
        __ALPHA_OUT : LV_ORDNO_C, LV_POSNR_C.
        GS_MAIN_DISP-REQ_FACTOR = LV_ORDNO_C && '/' && LV_POSNR_C.
        GS_MAIN_DISP-DMORD = LS_CHK_2000-ORDNO.
        GS_MAIN_DISP-DMLINE = LS_CHK_2000-POSNR.

        GS_MAIN_DISP-MEINS = LS_CHK_2000-MEINS.
        READ TABLE GT_CVMVAL INTO LS_CVMVAL WITH KEY MATNR = LS_CHK_2000-MATNR.
        IF SY-SUBRC EQ 0.
          GS_MAIN_DISP-ZSPECNO = LS_CVMVAL-PDCASPECNO.
        ELSE.
          SELECT SINGLE * FROM ZGTCVMSTVAL
             INTO LS_CVMVAL
            WHERE WERKS = P_WERKS
               AND MATNR =  LS_CHK_2000-MATNR.
          IF SY-SUBRC EQ 0.
            GS_MAIN_DISP-ZSPECNO = LS_CVMVAL-PDCASPECNO.
          ENDIF.
        ENDIF.

        GS_MAIN_DISP-EDATU = LS_CHK_2000-EDATU.
        GS_MAIN_DISP-SNOTE = ICON_DISPLAY_TEXT.

        APPEND GS_MAIN_DISP TO GT_MAIN_DISP.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SET_REGISTERED_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SET_REGISTERED_DATA .

  DATA : LT_MATNR TYPE RANGE OF MATNR.

* 해당 자재 구성을 위한 봄 구성
  PERFORM MAKE_MAINTAIN_BOM.
* 구매오더 생성시 구매오더 구성부품정보
  PERFORM SET_PO_RESB_NO.

  REFRESH LT_MATNR.
  LT_MATNR = VALUE #( FOR LW_2330 IN GT_2330 WHERE ( MATNR IS NOT INITIAL )
                                 ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2330-MATNR ) ).

  SORT LT_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

  IF LT_MATNR IS NOT INITIAL.
    SELECT * FROM ZGTCVMSTVAL
      APPENDING TABLE GT_CVMVAL
     WHERE WERKS = P_WERKS
        AND MATNR IN LT_MATNR.
  ENDIF.

* 반제품 작업지시화면 구성
  REFRESH GT_MAIN_DISP_101.

  SORT GT_BASE_GONG_SEQ BY GONG_SEQ.

  LOOP AT GT_BASE_GONG_SEQ INTO GS_BASE_GONG_SEQ.
* 반제품공정만
*    CASE GS_BASE_GONG_SEQ-GONG_SEQ.
*      WHEN '00' OR '01'. "현재 공정은 디스플레이 제외
*        CONTINUE.
*    ENDCASE.

    LOOP AT GT_2330 INTO DATA(LS_2330) WHERE GONG_CD = GS_BASE_GONG_SEQ-GONG_CD.
      IF LS_2330-DMORD IS INITIAL.
        CLEAR GS_MAIN_DISP_101.
        PERFORM SET_DISP_BOTTOM_USING_GONG USING LS_2330.
        APPEND GS_MAIN_DISP_101 TO GT_MAIN_DISP_101.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_MAINTAIN_BOM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_MAINTAIN_BOM .

  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LS_PRODUCT_BOM LIKE GS_PRODUCT_BOM.
  DATA : LV_GONG_SEQ TYPE ZGTPPT2340-GONG_SEQ.
  DATA : LV_CHECKED_GONG_CD TYPE ZGTPPT2330-GONG_CD.

  REFRESH : GT_BASE_GONG_SEQ.
  REFRESH : GT_PRODUCT_BOM.

  LT_MATNR = VALUE #( FOR LW_MAIN IN GT_2330 WHERE ( MATNR IS NOT INITIAL
                                                                        AND  GONG_SEQ = '01'  )
                               ( SIGN = 'I' OPTION = 'EQ' LOW = LW_MAIN-MATNR ) ).

  SORT LT_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

  LOOP AT LT_MATNR INTO DATA(LS_MATNR).
    CLEAR LS_PRODUCT_BOM.
    READ TABLE GT_PRODUCT_BOM INTO LS_PRODUCT_BOM WITH KEY MATNR = LS_MATNR-LOW BINARY SEARCH.
    IF SY-SUBRC EQ 0. " 기 생성된 봄은 재조회 안함.
      CONTINUE.
    ENDIF.

    CLEAR LS_PRODUCT_BOM.
    PERFORM MAKE_PRODUCT_BOM USING LS_MATNR-LOW CHANGING LS_PRODUCT_BOM.
    APPEND LS_PRODUCT_BOM TO GT_PRODUCT_BOM.
  ENDLOOP.


  LOOP AT GT_PRODUCT_BOM INTO DATA(LS_CHK_DATA).
    LOOP AT LS_CHK_DATA-T_BOM INTO DATA(LS_CHK_GONG).
      READ TABLE GT_BASE_GONG_SEQ ASSIGNING FIELD-SYMBOL(<LS_CHK_GONG>) WITH KEY GONG_CD = LS_CHK_GONG-GONG_CD BINARY SEARCH.
      IF SY-SUBRC NE 0. " 공정 미존재시 공정 어팬드
        INSERT LS_CHK_GONG INTO GT_BASE_GONG_SEQ INDEX SY-TABIX.
      ELSE. " 공정존재시는 자재코드 조회하여
        LOOP AT LS_CHK_GONG-T_MATNR INTO DATA(LS_MATNR_CHK).
          READ TABLE <LS_CHK_GONG>-T_MATNR ASSIGNING FIELD-SYMBOL(<LS_MATNR_CHK>) WITH KEY MATNR = LS_MATNR_CHK-MATNR.
          IF SY-SUBRC NE 0.
            APPEND LS_MATNR_CHK TO <LS_CHK_GONG>-T_MATNR.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  CLEAR LV_GONG_SEQ.

  LOOP AT GT_BASE_GONG_SEQ ASSIGNING FIELD-SYMBOL(<LS_INPUT>).
    ADD 1 TO LV_GONG_SEQ.
    <LS_INPUT>-GONG_SEQ = LV_GONG_SEQ.
  ENDLOOP.

  SORT GT_BASE_GONG_SEQ BY GONG_SEQ.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_PRODUCT_BOM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MATNR_LOW
*&      <-- LS_PRODUCT_BOM
*&---------------------------------------------------------------------*
FORM MAKE_PRODUCT_BOM  USING    PV_MATNR TYPE MATNR
                       CHANGING PS_PRODUCT_BOM LIKE GS_PRODUCT_BOM.

  DATA : LS_TOPMAT TYPE CSTMAT.
  DATA : LT_STB TYPE TABLE OF STPOX.
  DATA : LT_CSCMAT TYPE TABLE OF CSCMAT.
  DATA : LT_BASE_GONG_SEQ LIKE GT_BASE_GONG_SEQ.
  DATA : LS_BASE_GONG_SEQ LIKE GS_BASE_GONG_SEQ.
  DATA : LS_MATNR LIKE GS_MATNR.
  DATA : LT_MATNR LIKE GT_MATNR.
  DATA : LV_GONG_SEQ TYPE ZGTPPT2340-GONG_SEQ.
  DATA : LV_CHK_GONG_SEQ TYPE ZGTPPT2340-GONG_SEQ.

* BOM 하위전개
  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      AUMGB                 = ABAP_ON
      CAPID                 = 'PP01'
      DATUV                 = SY-DATUM
      EHNDL                 = '1'
      MKTLS                 = ABAP_ON
      MEHRS                 = ABAP_ON
      MMORY                 = '1'
      MTNRV                 = PV_MATNR
      WERKS                 = P_WERKS
    IMPORTING
      TOPMAT                = LS_TOPMAT
    TABLES
      STB                   = LT_STB
      MATCAT                = LT_CSCMAT
    EXCEPTIONS
      ALT_NOT_FOUND         = 1
      CALL_INVALID          = 2
      MATERIAL_NOT_FOUND    = 3
      MISSING_AUTHORIZATION = 4
      NO_BOM_FOUND          = 5
      NO_PLANT_DATA         = 6
      NO_SUITABLE_BOM_FOUND = 7
      CONVERSION_ERROR      = 8
      OTHERS                = 9.

  IF LT_CSCMAT[] IS NOT INITIAL.
    SELECT A~INDEX AS SEQNO, A~MATNR, B~MTART
      FROM @LT_CSCMAT AS A
      INNER JOIN MARA AS B
                            ON B~MATNR = A~MATNR
      INNER JOIN MARC AS C
                            ON C~MATNR = A~MATNR
                          AND C~WERKS = @P_WERKS
     WHERE B~MTART   IN ( 'MCFE', 'MCHF' )  " 완제품 반제품만 공정대상
       AND B~MATKL LIKE 'H%'
       AND ( A~INDEX EQ 1
        OR ( A~INDEX NE 1
       AND  A~VERID IS NOT INITIAL ) )
      INTO TABLE @DATA(LT_SEQ_ROUTING).
  ENDIF.

  IF LT_SEQ_ROUTING[] IS NOT INITIAL.
    SELECT * FROM ZGTCVMSTVAL
       FOR ALL ENTRIES IN @LT_SEQ_ROUTING
      WHERE WERKS = @P_WERKS
      AND MATNR = @LT_SEQ_ROUTING-MATNR
      INTO TABLE @DATA(LT_MATNR_DETAIL).
  ENDIF.

  SORT LT_SEQ_ROUTING BY SEQNO.
  LOOP AT LT_SEQ_ROUTING INTO DATA(LS_SEQ_ROUTING).
    CLEAR LS_BASE_GONG_SEQ.
    READ TABLE LT_MATNR_DETAIL INTO DATA(LS_MATNR_DETAIL) WITH KEY MATNR = LS_SEQ_ROUTING-MATNR.
    IF SY-SUBRC EQ 0.
      LS_BASE_GONG_SEQ-GONG_CD = LS_MATNR_DETAIL-PDCAPROCCODE.
      LS_BASE_GONG_SEQ-GONG_NM = LS_MATNR_DETAIL-PDCAPROCNAME.

      IF LS_MATNR_DETAIL-PDCAPROCCODE = 'BWD'.
        CONTINUE.
      ENDIF.

      IF LS_MATNR_DETAIL-BESKZ = 'F' AND LS_MATNR_DETAIL-SOBSL = ''. " 외주구매는 제외
        CONTINUE.
      ENDIF.

      IF LS_MATNR_DETAIL-PDCAPROCCODE IS INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE LT_BASE_GONG_SEQ ASSIGNING FIELD-SYMBOL(<LS_INPUT>) WITH KEY GONG_CD = LS_BASE_GONG_SEQ-GONG_CD.
      IF SY-SUBRC EQ 0.
        READ TABLE <LS_INPUT>-T_MATNR ASSIGNING FIELD-SYMBOL(<LS_MATNR>) WITH KEY MATNR = LS_SEQ_ROUTING-MATNR.
        IF SY-SUBRC EQ 0.
          ADD 1 TO <LS_MATNR>-SEQNO.
        ELSE.
          APPEND INITIAL LINE TO <LS_INPUT>-T_MATNR ASSIGNING <LS_MATNR>.
          <LS_MATNR>-MATNR = LS_MATNR_DETAIL-MATNR.
          <LS_MATNR>-BESKZ = LS_MATNR_DETAIL-BESKZ.
          <LS_MATNR>-SOBSL = LS_MATNR_DETAIL-SOBSL.
          <LS_MATNR>-SEQNO = 1.
        ENDIF.
      ELSE.
        APPEND INITIAL LINE TO LT_BASE_GONG_SEQ ASSIGNING <LS_INPUT>.
        CLEAR LS_MATNR.
        LS_MATNR-MATNR = LS_MATNR_DETAIL-MATNR.
        LS_MATNR-BESKZ = LS_MATNR_DETAIL-BESKZ.
        LS_MATNR-SOBSL = LS_MATNR_DETAIL-SOBSL.
        LS_MATNR-SEQNO = 1.
        APPEND LS_MATNR TO LS_BASE_GONG_SEQ-T_MATNR.
        MOVE-CORRESPONDING LS_BASE_GONG_SEQ TO <LS_INPUT>.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CLEAR LV_GONG_SEQ.

  LOOP AT LT_BASE_GONG_SEQ ASSIGNING <LS_INPUT>.
    ADD 1 TO LV_GONG_SEQ.
    <LS_INPUT>-GONG_SEQ = LV_GONG_SEQ.
  ENDLOOP.

  SORT LT_BASE_GONG_SEQ BY GONG_SEQ.

* 완제품 공정의 대상이 임가공 대상일때 임가공 반제품은 삭제, 자작 반제품 만날때까지
  READ TABLE LT_BASE_GONG_SEQ INTO DATA(LS_CHK_IMGAGONG) WITH KEY GONG_SEQ = '01'.
* 완제품 공정당 자재는 한건 이므로 리드로
  CLEAR LS_MATNR.
  READ TABLE LS_CHK_IMGAGONG-T_MATNR INTO LS_MATNR INDEX 1.
  IF ( LS_MATNR-BESKZ = 'F' AND LS_MATNR-SOBSL = '30' ) OR
    ( LS_MATNR-BESKZ = 'X' AND LS_MATNR-SOBSL = '30' ).
* 외주로 판단, 공정을 순차적으로 내리면서 해당 공정 반제품에 외주임가공이 아닌 반제품이 존재할시 중지
    LV_GONG_SEQ = '02'.
    CLEAR LV_CHK_GONG_SEQ.
    LOOP AT LT_BASE_GONG_SEQ INTO LS_CHK_IMGAGONG WHERE GONG_SEQ => LV_GONG_SEQ.
      LOOP AT LS_CHK_IMGAGONG-T_MATNR INTO DATA(LS_MATNR_CHK).
* 공정 순서대로 임가공 여부 확인
        IF ( LS_MATNR_CHK-BESKZ = 'F' AND LS_MATNR_CHK-SOBSL = '30' ) OR
             ( LS_MATNR_CHK-BESKZ = 'X' AND LS_MATNR_CHK-SOBSL = '30' ).
          CONTINUE.
        ELSE.
          LV_CHK_GONG_SEQ = LS_CHK_IMGAGONG-GONG_SEQ.
        ENDIF.

      ENDLOOP.
      IF LV_CHK_GONG_SEQ IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF LV_GONG_SEQ NE LV_CHK_GONG_SEQ AND LV_CHK_GONG_SEQ NE 0.
      DELETE LT_BASE_GONG_SEQ WHERE GONG_SEQ >= LV_GONG_SEQ
                                               AND GONG_SEQ < LV_CHK_GONG_SEQ.
    ENDIF.
  ENDIF.

  PS_PRODUCT_BOM-MATNR = PV_MATNR.
  PS_PRODUCT_BOM-INDEX = LINES( LT_BASE_GONG_SEQ ).
  PS_PRODUCT_BOM-T_BOM = LT_BASE_GONG_SEQ.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PO_RESB_NO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_PO_RESB_NO .

  DATA : BEGIN OF LS_CHK_EBELN,
           ORDNR TYPE ZGTPPT2340-ORDNR,
           POSNR TYPE ZGTPPT2340-POSNR,
           EBELN TYPE EBELN,
           EBELP TYPE EBELP,
         END OF LS_CHK_EBELN.
  DATA : LT_CHK_EBELN LIKE TABLE OF LS_CHK_EBELN.

  LT_CHK_EBELN = VALUE #( FOR LW_2340 IN GT_2340 WHERE ( ORDNR IS NOT INITIAL
                                                                        AND   ORDTY = 'PO' )
                                    ( ORDNR = LW_2340-ORDNR POSNR = LW_2340-POSNR ) ).

  CHECK LT_CHK_EBELN IS NOT INITIAL.
  LOOP AT LT_CHK_EBELN ASSIGNING FIELD-SYMBOL(<LS_CHK_EBELN>).
    <LS_CHK_EBELN>-EBELN = <LS_CHK_EBELN>-ORDNR.
    __ALPHA_INPUT <LS_CHK_EBELN>-EBELN.
    <LS_CHK_EBELN>-EBELP = <LS_CHK_EBELN>-POSNR + 0.
  ENDLOOP.

  SORT LT_CHK_EBELN BY EBELN EBELP.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_EBELN COMPARING EBELN EBELP.

  SELECT B~MATNR, SUM( B~BDMNG ) AS BDMNG
    FROM @LT_CHK_EBELN AS A
    INNER JOIN RESB AS B ON B~EBELN = A~EBELN
                             AND B~EBELP = A~EBELP
    GROUP BY B~MATNR
    INTO TABLE @GT_RESB_PO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP_BOTTOM_USING_GONG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_2330
*&---------------------------------------------------------------------*
FORM SET_DISP_BOTTOM_USING_GONG  USING   PS_2330 TYPE ZGTPPT2330.

  DATA : LT_2340 TYPE TABLE OF ZGTPPT2340.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : BEGIN OF LS_CHK_EKPO,
           EBELN TYPE EBELN,
           EBELP TYPE EBELP,
         END OF LS_CHK_EKPO.
  DATA : LT_CHK_EKPO LIKE TABLE OF LS_CHK_EKPO.

  DATA : LV_OBJNR TYPE JEST-OBJNR.
  DATA : LV_USER_LINE TYPE BSVX-STTXT.
  DATA : LV_STATUS(10).
  DATA : LV_MENGE TYPE MENGE_D.
  DATA : LV_MENGE2 TYPE MENGE_D.


  GS_MAIN_DISP_101-SEQNO = PS_2330-GONG_SEQ + 0.
  GS_MAIN_DISP_101-GONG_CD = GS_BASE_GONG_SEQ-GONG_CD.
  GS_MAIN_DISP_101-GONG_NM = GS_BASE_GONG_SEQ-GONG_NM.
  READ TABLE GS_BASE_GONG_SEQ-T_MATNR INTO DATA(LS_CHK_MATNR) WITH KEY MATNR = PS_2330-MATNR.

  GS_MAIN_DISP_101-MATNR = PS_2330-MATNR.
  GS_MAIN_DISP_101-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = PS_2330-MATNR ).

  READ TABLE GT_CVMVAL INTO DATA(LS_CVMVAL) WITH KEY MATNR = PS_2330-MATNR.
  IF SY-SUBRC EQ 0.
    IF LS_CVMVAL-COLORBASE IS NOT INITIAL.
      GS_MAIN_DISP_101-COLOR = LS_CVMVAL-COLORBASE.
    ENDIF.

    GS_MAIN_DISP_101-BESKZ = LS_CVMVAL-BESKZ.
    CASE GS_MAIN_DISP_101-BESKZ.
      WHEN 'E' OR 'X'.
        GS_MAIN_DISP_101-TEXT01 = '자작'.
      WHEN OTHERS.
        GS_MAIN_DISP_101-TEXT01 = '외주'.
    ENDCASE.
  ENDIF.

* 표준조장
  GS_MAIN_DISP_101-INLENGTH = PS_2330-INLENGTH.
* 이론소요량
  GS_MAIN_DISP_101-BMENG = PS_2330-BMENG.
* 조장수
  GS_MAIN_DISP_101-INFACTOR = PS_2330-INFACTOR.
* 시작일(계획)
  GS_MAIN_DISP_101-PSTTR = PS_2330-PSTTR.
* 종료일(계획)
  GS_MAIN_DISP_101-PEDTR = PS_2330-PEDTR.
* 계획오더
  GS_MAIN_DISP_101-PLNUM = PS_2330-PLNUM.
  GS_MAIN_DISP_101-ZWKREQ = PS_2330-ZWKREQ.
* 계획량
  GS_MAIN_DISP_101-GSMNG = PS_2330-GSMNG.
* 계획 B/N(조장수)
  GS_MAIN_DISP_101-MENGE01 = PS_2330-INFACTOR.

  LT_2340 = VALUE #( FOR LW_2340 IN GT_2340 WHERE ( ZWKREQ = PS_2330-ZWKREQ )
                            ( CORRESPONDING #( LW_2340 ) ) ).
  GS_MAIN_DISP_101-PRC_STAT = '작업요청'.

* 반제품 사급 투입수량
  CLEAR  GS_RESB_PO.
  READ TABLE GT_RESB_PO INTO GS_RESB_PO WITH KEY MATNR = PS_2330-MATNR.
  IF SY-SUBRC EQ 0.
    GS_MAIN_DISP_101-MENGE08 = GS_RESB_PO-BDMNG.
  ENDIF.

  SELECT SINGLE SUM( LABST ) AS LABST,
                          SUM( INSME ) AS INSME,
                          SUM( SPEME ) AS SPEME
      FROM ZGTCV_STOCKVAL
     WHERE WERKS = @P_WERKS
        AND MATNR = @PS_2330-MATNR
      GROUP BY WERKS, MATNR
      INTO @DATA(LS_AUFNR_JEGO).

** 현재고량
  GS_MAIN_DISP_101-MENGE05 = LS_AUFNR_JEGO-LABST + LS_AUFNR_JEGO-INSME + LS_AUFNR_JEGO-SPEME.

  IF LT_2340[] IS INITIAL.
*  진행상태
    RETURN.
  ENDIF.

** 생산오더 정보 가져오기
*  LT_AUFNR = VALUE #( FOR LW_2340 IN LT_2340 WHERE ( ORDTY = 'PRD' )
*                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2340-ORDNR ) ).
*  SORT LT_AUFNR BY LOW.
*  DELETE ADJACENT DUPLICATES FROM LT_AUFNR COMPARING LOW.
*
*  IF LT_AUFNR IS NOT INITIAL.
*    SELECT * FROM ZGTCVORDSYVAL
*      INTO TABLE @DATA(LT_ORDSYVAL)
*     WHERE AUFNR IN @LT_AUFNR.
*  ENDIF.

* 구매오더 정보 가져오기
  LT_CHK_EKPO = VALUE #( FOR LW_2340 IN LT_2340 WHERE ( ORDTY = 'PO' )
                                     ( EBELN = LW_2340-ORDNR EBELP = LW_2340-POSNR+1(5) ) ).

  SORT LT_CHK_EKPO BY EBELN EBELP.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_EKPO COMPARING EBELN EBELP.
  LOOP AT LT_CHK_EKPO ASSIGNING FIELD-SYMBOL(<LS_CHK_EKPO>).
    __ALPHA_INPUT <LS_CHK_EKPO>-EBELN.
    __ALPHA_INPUT <LS_CHK_EKPO>-EBELP.
  ENDLOOP.

  IF LT_CHK_EKPO[] IS NOT INITIAL.
    GS_MAIN_DISP_101-PRC_STAT = '임가공발주'.
    GS_MAIN_DISP_101-DISP_PO = ICON_LIST.
    SELECT SINGLE SUM( B~MENGE ) AS MENGE
      FROM @LT_CHK_EKPO AS A
      INNER JOIN EKPO AS B ON B~EBELN = A~EBELN
                                AND B~EBELP = A~EBELP
     WHERE B~LOEKZ = ' '
       INTO @GS_MAIN_DISP_101-MENGE06.

    SELECT SINGLE SUM( CASE B~BWART WHEN '101' THEN B~MENGE
                                                    WHEN '102' THEN B~MENGE * -1
                                                    END ) AS BWART
      FROM @LT_CHK_EKPO AS A
      INNER JOIN MSEG AS B ON B~EBELN = A~EBELN
                                  AND B~EBELP = A~EBELP
     WHERE B~BWART IN ( '101', '102' )
       INTO @LV_MENGE.
*  임가공 입고예정량(임가공발주량  - 임가공 입고량
    GS_MAIN_DISP_101-MENGE07 = GS_MAIN_DISP_101-MENGE06 - LV_MENGE.

  ENDIF.


  LOOP AT LT_2340 INTO DATA(LS_2340) WHERE ORDTY = 'PRD'.
** 작업지시량
    GS_MAIN_DISP_101-MENGE02 = GS_MAIN_DISP_101-MENGE02 +
                                       ( ( LS_2340-INLENGTH + LS_2340-CLENGTH + LS_2340-QLENGTH ) * LS_2340-INFACTOR ).
** 작업지시B/N
    ADD LS_2340-INFACTOR TO GS_MAIN_DISP_101-MENGE03.

    READ TABLE GT_ORDSYVAL INTO DATA(LS_ORDSYVAL) WITH KEY AUFNR = LS_2340-ORDNR.
** 입고예정량( 작업지시량 - 입고량 )
    GS_MAIN_DISP_101-MENGE04 = GS_MAIN_DISP_101-MENGE04 + ( ( ( LS_2340-INLENGTH + LS_2340-CLENGTH + LS_2340-QLENGTH ) * LS_2340-INFACTOR ) - LS_ORDSYVAL-WEMNG ).

    CLEAR LV_STATUS.
    IF LS_ORDSYVAL-DLV = ABAP_TRUE.
      LV_STATUS = '생산진행'.
    ELSEIF LS_ORDSYVAL-PDLV = ABAP_TRUE.
      LV_STATUS = '생산진행'.
    ELSEIF LS_ORDSYVAL-REL = ABAP_TRUE.
      LV_STATUS = '생성'.
    ELSE.
      LV_STATUS = '생성'.
    ENDIF.

* pay off상태 확인
    CASE LV_STATUS.
      WHEN '생성'.
        CLEAR LV_USER_LINE.
        LV_OBJNR = 'OR' && LS_ORDSYVAL-AUFNR.
        CALL FUNCTION 'STATUS_TEXT_EDIT'
          EXPORTING
            FLG_USER_STAT    = 'X'
            OBJNR            = LV_OBJNR
            ONLY_ACTIVE      = 'X'
            SPRAS            = SY-LANGU
            BYPASS_BUFFER    = 'X'
          IMPORTING
            USER_LINE        = LV_USER_LINE
          EXCEPTIONS
            OBJECT_NOT_FOUND = 1
            OTHERS           = 2.

        FIND ALL OCCURRENCES OF 'PAYO' IN LV_USER_LINE MATCH COUNT FINAL(LV_LINE).
        IF LV_LINE > 0. " Patoff 상태일지 작업중으로 변경
          LV_STATUS = '생산진행'.
        ELSE.
          IF  LS_ORDSYVAL-TERKZ = '7'.
            LV_STATUS = '작업지시'.
          ENDIF.
        ENDIF.
    ENDCASE.

    IF LV_STATUS = '생산진행'.
      GS_MAIN_DISP_101-PRC_STAT = '생산진행'.
    ELSEIF LV_STATUS = '작업지시' AND GS_MAIN_DISP_101-PRC_STAT NE '생산진행'.
      GS_MAIN_DISP_101-PRC_STAT = '작업지시'.
    ENDIF.

  ENDLOOP.

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
      EXTENSION                   = 10000
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
      ROWS    = 3
      COLUMNS = 1.

  GO_SPLITTER->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    9 ).             " Height

  GO_SPLITTER->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    2              " Row ID
      HEIGHT            =    33 ).             " Height

* top 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0100_TOP.
* middle 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0100.

* bottom 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 3
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0101.


  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
*// Event Handler ##
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_MENU_BUTTON               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED               FOR PO_GRID.
    WHEN GO_GRID_0101.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
  ENDCASE.

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
      I_INCLNAME             = 'ZGTPPR2300TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP'
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
      IT_DATA         = GT_MAIN_DISP
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'CHECK'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'CHECK'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '　'.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-EDIT = ABAP_TRUE.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'SEQNO'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'SEQNO'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 3.
    <LS_FCAT>-DATATYPE = 'INT4'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'REQ_FACTOR'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'REQ_FACTOR'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '소요량 요소'(f01).
    <LS_FCAT>-COL_POS = 5.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '50'.
    <LS_FCAT>-JUST = 'L'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'ORD_STAT'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ORD_STAT'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더상태'(f49).
    <LS_FCAT>-COL_POS = 14.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'CHK_PROC'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'CHK_PROC'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '반제품작업요청'(f02).
    <LS_FCAT>-COL_POS = 15.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-OUTPUTLEN = '4'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.

  ENDIF.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'CHK_CONFIRM'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'CHK_CONFIRM'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '일정계획'(f03).
    <LS_FCAT>-COL_POS = 16.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-OUTPUTLEN = '4'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'COLOR'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'COLOR'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상'(f04).
    <LS_FCAT>-COL_POS = 19.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'CHK_PEGGING'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'CHK_PEGGING'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Pegging 변경'(f46).
    <LS_FCAT>-COL_POS = 24.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.
  ENDIF.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    <LS_FCAT>-TABNAME = 'GT_MAIN_DISP'.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'REQ_FACTOR'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'GRPNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장구성표번호'(f05).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GCATG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '범주'(f06).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZZYUSCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '영업소'(f07).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GONG_CD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수요공정'(f08).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GONG_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정명'(f09).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더'(f10).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목번호'(f11).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재번호'(f12).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재명'(f13).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'ZSPECNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SPEC No'(f14).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PSMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수량'(f15).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장'(f16).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기본단위'(f17).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(f18).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'KUNNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품처'(f19).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품처내역'(f20).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'EDATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품요청일'(f21).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'SO_WMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매수량'(f22).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'SO_INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매조장'(f23).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'SO_VRKME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매단위'(f24).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'CHAR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '특성'(f25).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'SNOTE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '특기사항(헤더)'(f47).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'SNOTE2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '특기사항(품목)'(f48).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'DMORD' OR 'DMLINE' OR 'SEQNO'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
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
      IT_OUTTAB            = GT_MAIN_DISP
      IT_SORT              = GT_SORT_0100
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  IF GO_DD_DOCU_0100 IS BOUND.
    CALL METHOD GO_DD_DOCU_0100->INITIALIZE_DOCUMENT.
  ELSE.
    CREATE OBJECT GO_DD_DOCU_0100
      EXPORTING
        STYLE = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD GO_GRID_0100->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DD_DOCU_0100.


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
  GS_LAYOUT_0101-SEL_MODE   = 'D'.
  GS_LAYOUT_0101-STYLEFNAME = 'CELLTAB'.

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
      I_INCLNAME             = 'ZGTPPR2300TOP'
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

  READ TABLE GT_FIELDCAT_0101 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'SEQNO'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'SEQNO'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'INT4'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0101 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'COLOR'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'COLOR'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상'(f04).
    <LS_FCAT>-COL_POS = 6.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0101 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'TEXT01'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'TEXT01'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조달유형'(f27).
    <LS_FCAT>-COL_POS = 8.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0101 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'PRC_STAT'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'PRC_STAT'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '진행상태'(f28).
    <LS_FCAT>-COL_POS = 17.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  LOOP AT GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    <LS_FCAT>-TABNAME = 'GT_MAIN_DISP_101'.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'SEQNO' OR 'BESKZ' OR 'GONG_SEQ' OR 'ZWKREQ' OR 'PRC_STAT'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'GONG_CD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정'(f29).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GONG_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정명'(f30).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재번호'(f12).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재명'(f13).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'COLOR'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'TEXT01'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '표준조장'(f31).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'BMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '이론소요량'(f32).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(f18).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'PSTTR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시작일(계획)'(f33).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'PEDTR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '종료일(계획)'(f34).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'PLNUM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획오더'(f35).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'GSMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획량'(f36).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획 B/N'(f37).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업지시량'(f38).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE03'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업지시 B/N'(f39).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE04'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고예정량'(f40).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE05'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '현 재고량'(f41).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'DISP_PO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매오더'(f42).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MENGE06'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '임가공 발주량'(f43).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MENGE07'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '임가공입고예정량'(f44).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE08'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '반제품사급출고예정량'(f45).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0101 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.


  LOOP AT GT_MAIN_DISP_101 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    REFRESH LT_CELLTAB.

    LOOP AT GT_FIELDCAT_0101 INTO DATA(LS_FCAT).
      CASE LS_FCAT-FIELDNAME.
        WHEN 'MENGE02' OR 'MENGE03'.
*        작업지시량, 작업지시B/N 초록
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
          LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_POSITIVE.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
        WHEN 'DISP_PO' OR 'MENGE06'.
*        구매오더, 임가공발주량 주황
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
          LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_GROUP.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
        WHEN 'MENGE05' OR 'MENGE04' OR 'MENGE07' OR 'MENGE08'.
*        현재고량, 입고예정량 임가공입고예정량사급출고예정량 노랑
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
          LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_TOTAL.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
        WHEN 'PRC_STAT'.
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
          CASE <LS_MAIN>-PRC_STAT.
            WHEN '작업요청'.
              CONTINUE.
            WHEN '생산진행'.
              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_POSITIVE.
            WHEN '임가공발주' OR '작업지시'.
              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_GROUP.
          ENDCASE.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
      ENDCASE.
    ENDLOOP.
    IF LT_CELLTAB IS NOT INITIAL.
      MOVE-CORRESPONDING LT_CELLTAB TO <LS_MAIN>-CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0101 .

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
*& Form SET_SORTTAB_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0101 .

  REFRESH GT_SORT_0101.
  PERFORM SET_SORT_TAB TABLES GT_SORT_0101
                            USING : 1 'SEQNO'  'X' '' ''.

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
      PERFORM SET_CELL_ATTRIBUTE_GRID_0101.
      GO_GRID_0101->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0101 ).
  ENDCASE.


  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
*     I_SOFT_REFRESH = 'X'
      IS_STABLE = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM ALV_TOP_OF_PAGE  USING    PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                               PV_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      PERFORM SET_TITLE_0100 CHANGING PV_DYNDOC_ID.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PV_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM SET_TITLE_0100  CHANGING PV_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  DATA : LV_TEXT(255) TYPE C.
  DATA : LV_FRDATE_C(10).
  DATA : LV_TODATE_C(10).
  DATA : LV_WEEKEND_DT TYPE SY-DATUM.

* 플랜트
* SPG
  IF NOT P_SPGCD IS INITIAL.
    CLEAR ZPPT0107.
    SELECT SINGLE DESCR INTO P_DESCR
             FROM ZPPT0107
            WHERE SPGCD EQ P_SPGCD.
  ELSE.
    CLEAR P_DESCR.
  ENDIF.

* 플랜트명
  IF NOT P_WERKS IS INITIAL.
    CLEAR T001W.
    SELECT SINGLE NAME1 INTO P_NAME1
             FROM T001W
            WHERE WERKS EQ P_WERKS.
  ELSE.
    CLEAR P_NAME1.
  ENDIF.

  CONCATENATE  P_NAME1  '-'  P_DESCR INTO LV_TEXT SEPARATED BY SPACE.

  CONCATENATE '플랜트 :' LV_TEXT INTO LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.


* 납품요청일
  CLEAR LV_TEXT.
  LV_FRDATE_C = S_DATE-LOW+0(4) &&'.' && S_DATE-LOW+4(2) &&'.' && S_DATE-LOW+6(2).
  LV_TODATE_C = S_DATE-HIGH+0(4) &&'.' && S_DATE-HIGH+4(2) &&'.' && S_DATE-HIGH+6(2).

  CONCATENATE  LV_FRDATE_C  '~'  LV_TODATE_C INTO LV_TEXT SEPARATED BY SPACE.
  CONCATENATE '남품요철일 :' LV_TEXT INTO LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

* 작업요청월
  CLEAR LV_TEXT.
  LV_TEXT = P_SPMON+0(4) && '.' && P_SPMON+4(2).

  CONCATENATE '작업요청월 :' LV_TEXT INTO  LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

  "위쪽에 추가한 텍스트 출력
  CALL METHOD GO_DD_DOCU_0100->DISPLAY_DOCUMENT
    EXPORTING
      PARENT             = GO_CONTAIN_0100_TOP
      REUSE_CONTROL      = ABAP_TRUE
      REUSE_REGISTRATION = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form TOOLBAR_PROS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM TOOLBAR_PROS  USING    PO_SENDER
                          PO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                          R_INTERACTIVE.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      IF GV_SET_CONFIRM = ABAP_TRUE.
        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                             USING : 'SET_FILTER' ICON_VIEW_MAXIMIZE '요청완료포함' '요청완료포함' 0.
      ELSE.
        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                             USING : 'DEL_FILTER' ICON_VIEW_CLOSE '요청완료제외' '요청완료제외' 0.
      ENDIF.

      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                           USING : '' '' '' '' 3,
                                      'REQUEST' ICON_EXECUTE_OBJECT '반제품작업요청' '반제품작업요청' 0,
                                      'DEL_REQ' ICON_DELETE '반제품작업요청삭제' '반제품작업요청삭제' 0,
                                      '' '' '' '' 3,
                                      'UNPEGGING_FORCE' ICON_ERASE 'Pegging 강제삭제' 'Pegging 강제삭제' 2 .

    WHEN GO_GRID_0101.
      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                           USING : 'CRT_PO' ICON_IMPORT_ALL_REQUESTS '임가공구매발주' '입가공구매발주' 0.
*                                      'DEL_PO' ICON_DELETE '입가공구매발주취소' '입가공구매발주취소' 0 .

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> PO_OBJECT_>MT_TOOLBAR
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR  TABLES  PT_TOOLBAR STRUCTURE STB_BUTTON
               USING    PV_FUNCTION
                           PV_ICON
                           PV_TEXT
                           PV_QUICKINFO
                           PV_BUTN_TYPE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION  = PV_FUNCTION.
  LS_TOOLBAR-ICON      = PV_ICON.
  IF PV_TEXT IS NOT INITIAL.
    CONCATENATE ' '  PV_TEXT ' '  INTO LS_TOOLBAR-TEXT SEPARATED BY SPACE.
  ENDIF.
  LS_TOOLBAR-QUICKINFO = PV_QUICKINFO.
  LS_TOOLBAR-BUTN_TYPE = PV_BUTN_TYPE.
  APPEND LS_TOOLBAR TO PT_TOOLBAR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_PROS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM USER_COMMAND_PROS  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                 PV_UCOMM.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      CASE PV_UCOMM.
        WHEN 'REQUEST'. " 작업요청
          PERFORM PROC_REQUEST.
        WHEN 'DEL_REQ'. " 작업요청해제
          PERFORM PROC_DEL_REQUEST.
        WHEN 'SET_FILTER'. " 요청완료포함
          PERFORM SET_SET_FILTER USING 'X'.
        WHEN 'DEL_FILTER'. " 요청완료제외
          PERFORM SET_SET_FILTER USING ''.
        WHEN OTHERS.
          READ TABLE GT_DEL_PEGGING INTO GS_DEL_PEGGING WITH KEY AUFNR = PV_UCOMM.
          IF SY-SUBRC EQ 0.
            PERFORM PROC_UNPEGGING_FORCE.
          ENDIF.
      ENDCASE.
    WHEN GO_GRID_0101.
      CASE PV_UCOMM.
        WHEN 'CRT_PO'. " 입가공구매발주
          PERFORM PROC_CRT_PO.
*        WHEN 'DEL_PO'. " 입가공구매발주취소
*          PERFORM PROC_DEL_PO_PRODUCT.
      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SET_FILTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SET_FILTER  USING    PV_GUBUN.

  DATA : LT_FILTER TYPE LVC_T_FILT.

  CASE PV_GUBUN.
    WHEN ''.
      GV_SET_CONFIRM = ABAP_TRUE.

      APPEND INITIAL LINE TO LT_FILTER ASSIGNING FIELD-SYMBOL(<LS_FILTER>).
      <LS_FILTER>-FIELDNAME = 'CHK_PROC'.
      <LS_FILTER>-SIGN = 'I'.
      <LS_FILTER>-OPTION = 'EQ'.

    WHEN ABAP_TRUE.
      CLEAR GV_SET_CONFIRM.
  ENDCASE.

  GO_GRID_0100->SET_FILTER_CRITERIA(
  EXPORTING
    IT_FILTER                 = LT_FILTER                 " Filter Conditions
  EXCEPTIONS
    NO_FIELDCATALOG_AVAILABLE = 1                " Instance Variable of Field Catalog not yet Set
    OTHERS                    = 2
).
  IF SY-SUBRC <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> ER_DATA_CHANGED
*&      --> E_ONF4
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM DATA_CHANGED  USING    P_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                PO_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                PE_ONF4
                                PE_UCOMM.

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI.
  DATA : LV_CALL_FUNC.
  DATA : LV_CHK_ERR.

  DEFINE __SET_ERR_MSG.
    lv_chk_err = abap_true.
    po_data_changed->add_protocol_entry(
        i_msgid     = 'ZGTPP00'                 " Message ID
        i_msgty     = 'E'                 " Message Type
        i_msgno     =  '03'                " Message No.
        i_msgv1     =  &1                " Message Variable1
        i_fieldname =  &2                " Field Name
        i_row_id    =  ls_mod_cells-row_id ).                " RowID
  END-OF-DEFINITION.


  CASE P_SENDER.
    WHEN GO_GRID_0100.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'CHECK'.
            GV_CHK_LINE = LS_MOD_CELLS-ROW_ID.
            GV_CHK_VALUE = LS_MOD_CELLS-VALUE.
            LV_CALL_FUNC = ABAP_TRUE.
        ENDCASE.
      ENDLOOP.
  ENDCASE.

  IF LV_CHK_ERR IS NOT INITIAL.
    PO_DATA_CHANGED->DISPLAY_PROTOCOL( ).
  ENDIF.

  IF LV_CALL_FUNC IS NOT INITIAL.
    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'SETCHECK'              " Function code
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
        OTHERS                 = 2.
    IF SY-SUBRC <> 0.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHECK_BOX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CHECK_BOX .

  READ TABLE GT_MAIN_DISP INTO DATA(LS_MAIN_DISP) INDEX GV_CHK_LINE.
  LS_MAIN_DISP-CHECK = GV_CHK_VALUE.
  MODIFY GT_MAIN_DISP FROM LS_MAIN_DISP TRANSPORTING CHECK WHERE GRPNR = LS_MAIN_DISP-GRPNR .

  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_REQUEST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_REQUEST .

  DATA : LT_MOSU LIKE GT_MAIN_DISP.
  DATA : LT_2330 TYPE TABLE OF ZGTPPT2330.
  DATA : LT_2340 TYPE TABLE OF ZGTPPT2340.
  DATA : LS_2330 TYPE ZGTPPT2330.
  DATA : LS_2340 TYPE ZGTPPT2340.
  DATA : BEGIN OF LS_CHK_MAX_ZWKREQ,
           ZWKREQ   TYPE ZGTPPT2330-ZWKREQ,
           SEQNO(6) TYPE C,
         END OF LS_CHK_MAX_ZWKREQ.
  DATA : LT_CHK_MAX_ZWKREQ LIKE TABLE OF LS_CHK_MAX_ZWKREQ.
  DATA : LV_AUFNR TYPE AUFNR.
  DATA : LV_CHK_ERR.
  DATA : LT_GRPNR TYPE RANGE OF ZGTPPT2000-GRPNR.

  DATA : LV_MAX_SEQ(6) TYPE N.

  LOOP AT GT_MAIN_DISP INTO DATA(LS_MAIN_CHK) WHERE CHECK = ABAP_TRUE
                                                                        AND CHK_PEGGING = ' '..
    IF LS_MAIN_CHK-CHK_PROC = ABAP_TRUE .
      CONTINUE.
    ENDIF.

    APPEND LS_MAIN_CHK TO LT_MOSU.

  ENDLOOP.

  IF LT_MOSU IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '작업요청 할 수 있는 주문이 없습니다.'(e03).
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택한 사항으로 반제품 작업요청 진행 하시겠습니까?'
    '작업확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.
  PERFORM SET_PROGRESS_INDICATOR USING '10' '완제품 작업요청정보 저장중..'.

* 작업 요청 순번 지정을 위해 작업요청 MaX 번호 가져온다
  SELECT  ZWKREQ, RIGHT( ZWKREQ, 6 ) AS SEQNO
    FROM ZGTPPT2330
    WHERE WERKS = @P_WERKS
      AND SPGCD = @P_SPGCD
      AND RQMON = @P_SPMON
    INTO CORRESPONDING FIELDS OF TABLE @LT_CHK_MAX_ZWKREQ.

  SELECT  ZWKREQ, RIGHT( ZWKREQ, 6 ) AS SEQNO
    FROM ZGTPPT2340
    WHERE WERKS = @P_WERKS
      AND SPGCD = @P_SPGCD
      AND RQMON = @P_SPMON
    APPENDING CORRESPONDING FIELDS OF TABLE @LT_CHK_MAX_ZWKREQ.

  SORT LT_CHK_MAX_ZWKREQ BY SEQNO DESCENDING.
  READ TABLE LT_CHK_MAX_ZWKREQ INTO LS_CHK_MAX_ZWKREQ INDEX 1.

  LV_MAX_SEQ = LS_CHK_MAX_ZWKREQ-SEQNO.

* 작업요청처리
  LOOP AT LT_MOSU INTO DATA(LS_MOSU).
    CLEAR LS_2330.
    LS_2330-WERKS = P_WERKS.
    LS_2330-SPGCD = P_SPGCD.
    LS_2330-RQMON = P_SPMON.
    ADD 1 TO LV_MAX_SEQ.
    LS_2330-ZWKREQ = SY-DATUM+2(6) && LV_MAX_SEQ.
    LS_2330-ZDISTRIB = '1'.
    LS_2330-GONG_CD = LS_MOSU-GONG_CD.
    LS_2330-MATNR = LS_MOSU-MATNR.
    LS_2330-ZSPECNO = LS_MOSU-ZSPECNO.
    CASE LS_MOSU-GCATG.
      WHEN '판매오더'.
        LS_2330-DMORDTY = 'SO'.
      WHEN OTHERS.
        LS_2330-DMORDTY = 'PRD'.
    ENDCASE.

    LS_2330-DMORD = LS_MOSU-DMORD.
    LS_2330-DMLINE = LS_MOSU-DMLINE + 0.
* 작업요청월 + '01'
    LS_2330-PSTTR = P_SPMON && '01'.
* 작업요청월 + 말일
    LS_2330-PEDTR = LS_2330-PSTTR.
    PERFORM GET_LAST_DAY_OF_MONTH CHANGING LS_2330-PEDTR.

    LS_2330-MEINS = LS_MOSU-MEINS.
    LS_2330-INLENGTH = LS_MOSU-INLENGTH.
    LS_2330-INFACTOR = LS_MOSU-INFACTOR.
    LS_2330-BMENG = LS_MOSU-PSMNG.
    LS_2330-GSMNG = LS_MOSU-PSMNG.
    LS_2330-GRPNR = LS_MOSU-GRPNR.
    LS_2330-GONG_SEQ = '01'.

    APPEND LS_2330 TO LT_2330.


* 생산오더 처리( ZGTPPT2340 )
    CLEAR LS_2340.
    LS_2340-WERKS = P_WERKS.
    LS_2340-SPGCD = P_SPGCD.
    LS_2340-RQMON = P_SPMON.
    LS_2340-GONG_CD = LS_2330-GONG_CD.
    LS_2340-ZWKREQ = LS_2330-ZWKREQ.
    LS_2340-MATNR = LS_2330-MATNR.
    LV_AUFNR = LS_MOSU-AUFNR.
    __ALPHA_INPUT LV_AUFNR.
    READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = LV_AUFNR
                                                            POSNR = LS_MOSU-POSNR
                                                            ORDTY = 'PRD'.
    IF SY-SUBRC EQ 0.
      LS_2340-ORDNR = LS_2010-ORDNR.
      LS_2340-POSNR = LS_2010-POSNR.
      LS_2340-ORDTY = LS_2010-ORDTY.
      LS_2340-INLENGTH = LS_2010-INLENGTH.
      LS_2340-INFACTOR = LS_2010-INFACTOR.
      LS_2340-QLENGTH = LS_2010-QLENGTH.
      LS_2340-CLENGTH = LS_2010-CLENGTH.
      LS_2340-ADLENGTH = LS_2010-ADLENGTH.
      LS_2340-ADTYPE = LS_2010-ADTYPE.
      LS_2340-GONG_SEQ = LS_2330-GONG_SEQ.
    ELSE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '작업요청 중 오류발생하였습니다.'(e05).
      RETURN.
    ENDIF.

    APPEND LS_2340 TO LT_2340.

  ENDLOOP.

  LT_GRPNR = VALUE #( FOR LW_MOSU IN LT_MOSU WHERE ( GRPNR IS NOT INITIAL )
                               ( SIGN = 'I' OPTION = 'EQ' LOW = LW_MOSU-GRPNR ) ).

  IF LT_2340 IS NOT INITIAL.
    MODIFY ZGTPPT2340 FROM TABLE LT_2340.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더 작업요청 저장중 오류발생하였습니다.'(e06).
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_2330 IS NOT INITIAL.
    MODIFY ZGTPPT2330 FROM TABLE LT_2330.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더 작업요청 저장중 오류발생하였습니다.'(e06).
      RETURN.
    ENDIF.
  ENDIF.

  PERFORM SET_PROGRESS_INDICATOR USING '50' '완제품 작업요청정보 저장 완료'.

  PERFORM SET_HALF_MATNR USING '1' CHANGING LV_CHK_ERR.
  IF LV_CHK_ERR = ABAP_TRUE.
    DELETE ZGTPPT2330 FROM TABLE LT_2330.
    DELETE ZGTPPT2340 FROM TABLE LT_2340.
    COMMIT WORK AND WAIT.
    RETURN.
  ENDIF.

  IF LT_GRPNR[] IS NOT INITIAL.
    SORT LT_GRPNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_GRPNR COMPARING LOW.
    UPDATE ZGTPPT2000 SET RQMON = P_SPMON
      WHERE GRPNR IN LT_GRPNR
        AND ZSTATUS <> 'D'.
    COMMIT WORK AND WAIT.
  ENDIF.

  PERFORM SET_PROGRESS_INDICATOR USING '100' '완료'.

  PERFORM GET_PROC.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  PERFORM REFRESH_GRID USING GO_GRID_0101.


  MESSAGE S006 WITH '선택 사항에 대한 완제품 작업지시 및 반제품 공정 계획 수립 되었습니다.'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CRT_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CRT_PO .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LV_CHK_ERR.

  DATA : LT_MOSU_MAIN LIKE GT_MAIN_DISP_101.

  DATA : LV_MESSAGE(100).
  DATA : LV_EBELN TYPE EBELN.
  DATA : LV_EBELP TYPE EBELP.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LT_POITEM   TYPE TABLE OF BAPIMEPOITEM.
  DATA : LT_POITEMX   TYPE TABLE OF BAPIMEPOITEMX.

  CALL METHOD GO_GRID_0101->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  IF LT_ROW[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '임가공 구매 오더를 생성할 작업 요청을 선택해 주세요'(e17).
    RETURN.
  ENDIF.

  IF LINES( LT_ROW )  NE 1.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '임가공 구매오더는 작업 요청 하나만 선택 할 수 있습니다'(e16).
    RETURN.
  ENDIF.

  LOOP AT LT_ROW INTO LS_ROW.

    READ TABLE GT_MAIN_DISP_101 INTO DATA(LS_MAIN) INDEX LS_ROW-INDEX.

    SELECT SINGLE * FROM ZGTCVMSTVAL
      INTO @DATA(LS_CVMSTVAL)
     WHERE WERKS = @P_WERKS
       AND MATNR = @LS_MAIN-MATNR.

    IF ( LS_CVMSTVAL-BESKZ = 'F' AND LS_CVMSTVAL-SOBSL = '30' ) OR
       ( LS_CVMSTVAL-BESKZ = 'X' AND LS_CVMSTVAL-SOBSL = '30' ).
      APPEND LS_MAIN TO LT_MOSU_MAIN.
    ELSE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '조달 외주 유형이 아닌 작업요청이 선택 되었습니다.'(e19).
      RETURN.
    ENDIF.
  ENDLOOP.

* 구매오더 발주를 위한 구성 준비
  PERFORM READY_FOR_PURCHASE TABLES LT_MOSU_MAIN
                                                CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR NE 'S'.
    RETURN.
  ENDIF.

  CLEAR GV_CONTINUE_200.
  CALL SCREEN '0200' STARTING AT 5 5 ENDING AT 105 25.

  IF GV_CONTINUE_200 IS INITIAL.
    RETURN.
  ENDIF.

  PERFORM SET_PROGRESS_INDICATOR USING '10' '임가공 구매오더 생성중..'.

  PERFORM CREATE_PURCHASE_ORDER CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  IF GT_2340_CHG IS NOT INITIAL.
    MODIFY ZGTPPT2340 FROM TABLE GT_2340_CHG.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

  PERFORM SET_PROGRESS_INDICATOR USING '50' '임가공 구매오더 생성완료..'.

  PERFORM SET_HALF_MATNR USING '1' CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR = ABAP_TRUE.
    READ TABLE GT_2340_CHG INTO DATA(LS_2340_ROLLBACK) INDEX 1.
    LV_EBELN = LS_2340_ROLLBACK-ORDNR.
    LV_EBELP = LS_2340_ROLLBACK-POSNR + 0.

    APPEND INITIAL LINE TO LT_POITEM ASSIGNING FIELD-SYMBOL(<LS_POITEM>).
    <LS_POITEM>-PO_ITEM = LV_EBELP.
    <LS_POITEM>-DELETE_IND = ABAP_TRUE.

    APPEND INITIAL LINE TO LT_POITEMX ASSIGNING FIELD-SYMBOL(<LS_POITEMX>).
    <LS_POITEMX>-PO_ITEM = LV_EBELP.
    <LS_POITEMX>-PO_ITEMX = ABAP_TRUE.
    <LS_POITEMX>-DELETE_IND = ABAP_TRUE.

    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        PURCHASEORDER = LV_EBELN
      TABLES
        RETURN        = LT_RETURN
        POITEM        = LT_POITEM
        POITEMX       = LT_POITEMX.

    READ TABLE LT_RETURN TRANSPORTING NO FIELDS WITH KEY TYPE = 'E'.
    IF SY-SUBRC NE 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
    ENDIF.

    IF GT_2340_CHG IS NOT INITIAL.
      DELETE ZGTPPT2340 FROM TABLE GT_2340_CHG.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.

    RETURN.
  ENDIF.

  PERFORM SET_PROGRESS_INDICATOR USING '100' '완료'.

  PERFORM GET_PROC.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  PERFORM REFRESH_GRID USING GO_GRID_0101.

  MESSAGE S006 WITH '선택 사항에 대한 완제품 임가공 구매오더 생성 및 반제품 공정 계획 수립 되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_PROGRESS_INDICATOR  USING    PV_PERCENT
                                      PV_TEXT.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      PERCENTAGE = PV_PERCENT                 "indicator에 진행률(%)
      TEXT       = PV_TEXT.  "텍스트 표시

ENDFORM.
*&---------------------------------------------------------------------*
*& Form READY_FOR_PURCHASE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_MOSU_MAIN
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM READY_FOR_PURCHASE  TABLES   PT_MAIN STRUCTURE GS_MAIN_DISP_101
                         CHANGING PV_CHK_ERR.

  DATA : LT_INPUT_2330 TYPE TABLE OF ZGTPPT2330.
  DATA : LT_BASE_GONG_SEQ LIKE GT_BASE_GONG_SEQ.
  DATA : LT_CHK_GONG_SEQ LIKE GT_BASE_GONG_SEQ.
  DATA : LS_MAIN_2330 TYPE ZGTPPT2330.
  DATA : LS_BASE_GONG_SEQ LIKE GS_BASE_GONG_SEQ.

* 1) 선택된 라인의 공정
  READ TABLE PT_MAIN INDEX 1.

  CLEAR LS_BASE_GONG_SEQ.
  LS_BASE_GONG_SEQ-GONG_SEQ = PT_MAIN-GONG_SEQ.
  LS_BASE_GONG_SEQ-GONG_CD = PT_MAIN-GONG_CD.
  LS_BASE_GONG_SEQ-GONG_NM = PT_MAIN-GONG_NM.
  APPEND LS_BASE_GONG_SEQ TO LT_BASE_GONG_SEQ.

  READ TABLE GT_2330 INTO LS_MAIN_2330 WITH KEY MATNR = PT_MAIN-MATNR.

* 3) 선택된 라인의 작업지시 세팅
  PERFORM MAKE_2340 USING PT_MAIN LS_MAIN_2330.


* 봄조회후 구성공정 결정 및 표준공정 세팅
  PERFORM FIND_BOM_AND_GETDATA TABLES LT_CHK_GONG_SEQ LT_INPUT_2330
                                                USING PT_MAIN-MATNR PT_MAIN-GONG_SEQ.

  IF LT_CHK_GONG_SEQ[] IS NOT INITIAL.
    APPEND LINES OF LT_CHK_GONG_SEQ TO LT_BASE_GONG_SEQ.
  ENDIF.

  PERFORM SET_TABLE_DISP_200 TABLES LT_BASE_GONG_SEQ LT_INPUT_2330
                                            USING LS_MAIN_2330 '2'
                                       CHANGING PV_CHK_ERR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_2340
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_MAIN
*&      --> LS_MAIN_2330
*&---------------------------------------------------------------------*
FORM MAKE_2340  USING    PS_MAIN LIKE GS_MAIN_DISP_101
                              PS_2330 TYPE ZGTPPT2330.

  DATA : LS_2340_CHG TYPE ZGTPPT2340.

  LS_2340_CHG-WERKS = P_WERKS.
  LS_2340_CHG-SPGCD = P_SPGCD.
  LS_2340_CHG-RQMON = P_SPMON.
  LS_2340_CHG-GONG_CD = PS_2330-GONG_CD.
  LS_2340_CHG-ZWKREQ = PS_2330-ZWKREQ.
  LS_2340_CHG-MATNR = PS_2330-MATNR.
*  오더정보는 구매오더 생성후 적용
*  PS_MODI_2340-ORDNR
*  PS_MODI_2340-POSNR
  LS_2340_CHG-ORDTY = 'PO'.
  LS_2340_CHG-INLENGTH = PS_MAIN-INLENGTH.
  LS_2340_CHG-INFACTOR = PS_MAIN-INFACTOR.
  LS_2340_CHG-GONG_SEQ = PS_2330-GONG_SEQ.

  APPEND LS_2340_CHG TO GT_2340_CHG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TABLE_DISP_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_BASE_GONG_SEQ
*&      --> LT_INPUT_2330
*&      --> LS_MAIN_2330
*&      --> P_
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM SET_TABLE_DISP_200  TABLES   PT_BASE_GONG_SEQ STRUCTURE GS_BASE_GONG_SEQ
                                  PT_INPUT STRUCTURE ZGTPPT2330
                         USING    PS_MAIN TYPE ZGTPPT2330
                                     PV_GUBUN   " '1' 완제품임가공, '2' 반제품 임가공
                         CHANGING PV_CHK_ERR.

  DATA : LV_NUMBER(2) TYPE N.
  DATA : LV_COL_ID TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.

  CLEAR : GS_HEADER_200.
  REFRESH : GT_MAIN_200, GT_MAIN_201, GT_FIELDCAT_0200.

* 구매오더 생성을 위한 사전준비
  CLEAR GS_EKORG.
  SELECT SINGLE FLD_02 AS WERKS, FLD_03 AS EKORG, FLD_04 AS EKGRP
  FROM ZGTPPT1010
  INTO @GS_EKORG
 WHERE MODULE_KIND = 'PP'
   AND CODEGRP = '2090'
   AND FLD_01 = 'L'
   AND FLD_02 = @P_WERKS.

* 입고위치 추가
  SELECT SINGLE LGFSB
    FROM MARC
    INTO GS_HEADER_200-LGFSB
   WHERE WERKS = P_WERKS
     AND MATNR = PS_MAIN-MATNR.

  REFRESH GT_LIFNR.
* 공급업체 정보 추출
  SELECT A~MATNR, A~INFNR, A~LIFNR, C~NAME1
    FROM EINA AS A
    INNER JOIN EINE AS B ON B~INFNR = A~INFNR
    INNER JOIN LFA1 AS C ON C~LIFNR = A~LIFNR
  WHERE A~MATNR = @PS_MAIN-MATNR
     AND A~LOEKZ = ''
     AND B~EKORG = @GS_EKORG-EKORG
     AND B~EKGRP = @GS_EKORG-EKGRP
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIFNR.


* 팝업화면 구성
  GS_HEADER_200-MATNR = PS_MAIN-MATNR.
  GS_HEADER_200-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = PS_MAIN-MATNR ).
  READ TABLE GT_LIFNR INTO GS_LIFNR INDEX 1.
  GS_HEADER_200-LIFNR = GS_LIFNR-LIFNR.
  GS_HEADER_200-NAME1 = GS_LIFNR-NAME1.
  GS_HEADER_200-EEIND = PS_MAIN-PEDTR - 1.
  GS_HEADER_200-INLENGTH = PS_MAIN-INLENGTH.
  GS_HEADER_200-MEINS = PS_MAIN-MEINS.
  GS_HEADER_200-INFACTOR = PS_MAIN-INFACTOR.

* 임가공 공정 구성
  APPEND INITIAL LINE TO GT_MAIN_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN_200>).

  SORT PT_BASE_GONG_SEQ BY GONG_SEQ DESCENDING.
  LOOP AT PT_BASE_GONG_SEQ.
    ADD 1 TO LV_NUMBER.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = 'CHART' && LV_NUMBER.
    ADD 1 TO LV_COL_ID.
    APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    <LS_FCAT>-FIELDNAME = LV_FIELDNAME.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = PT_BASE_GONG_SEQ-GONG_NM.
    <LS_FCAT>-COL_POS = LV_COL_ID.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.

    ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_200> TO FIELD-SYMBOL(<LV_VALUE>).
    IF <LV_VALUE> IS ASSIGNED.
      <LV_VALUE> = '외주'.
    ENDIF.
  ENDLOOP.

  UNASSIGN <LS_MAIN_200>.

  LOOP AT PT_INPUT.
    APPEND INITIAL LINE TO GT_MAIN_201 ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>).
    <LS_MAIN_201>-GONG_CD = PT_INPUT-GONG_CD.
    <LS_MAIN_201>-MATNR = PT_INPUT-MATNR.
    <LS_MAIN_201>-INLENGTH = PT_INPUT-INLENGTH.
    <LS_MAIN_201>-INFACTOR = 1.
    <LS_MAIN_201>-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = PT_INPUT-MATNR ).
  ENDLOOP.

  CASE PV_GUBUN.
    WHEN '1'.
    WHEN '2'.
      GS_HEADER_200-CHK_HALF = ABAP_TRUE.
  ENDCASE.

  PV_CHK_ERR = 'S'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIND_BOM_AND_GETDATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_CHK_GONG_SEQ
*&      --> LT_INPUT_2330
*&      --> PT_MAIN_MATNR
*&      --> PT_MAIN_GONG_SEQ
*&---------------------------------------------------------------------*
FORM FIND_BOM_AND_GETDATA  TABLES   PT_CHK_GONG_SEQ STRUCTURE GS_BASE_GONG_SEQ
                                    PT_2330 STRUCTURE ZGTPPT2330
                           USING  PV_MATNR
                                    PV_GONG_SEQ.

  DATA : LT_STB TYPE TABLE OF STPOX.
  DATA : LT_CSCMAT TYPE TABLE OF CSCMAT.
  DATA : LT_BASE_GONG_SEQ LIKE GT_BASE_GONG_SEQ.
  DATA : LS_BASE_GONG_SEQ LIKE GS_BASE_GONG_SEQ.
  DATA : LV_GONG_SEQ TYPE ZGTPPT2340-GONG_SEQ.
  DATA : LV_CHK_GONG_SEQ TYPE ZGTPPT2340-GONG_SEQ.
  DATA : LS_MATNR LIKE GS_MATNR.

  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      CAPID                 = 'PP01'
      DATUV                 = SY-DATUM
      MTNRV                 = PV_MATNR " 자재
      WERKS                 = P_WERKS " 플랜트
      MEHRS                 = ABAP_TRUE " 멀티체크
      MMORY                 = '0'
    TABLES
      STB                   = LT_STB
      MATCAT                = LT_CSCMAT
    EXCEPTIONS
      ALT_NOT_FOUND         = 1
      CALL_INVALID          = 2
      MATERIAL_NOT_FOUND    = 3
      MISSING_AUTHORIZATION = 4
      NO_BOM_FOUND          = 5
      NO_PLANT_DATA         = 6
      NO_SUITABLE_BOM_FOUND = 7
      CONVERSION_ERROR      = 8
      OTHERS                = 9.

  IF LT_CSCMAT[] IS NOT INITIAL.
    SELECT A~INDEX AS SEQNO, A~MATNR, B~MTART
      FROM @LT_CSCMAT AS A
      INNER JOIN MARA AS B
                            ON B~MATNR = A~MATNR
      INNER JOIN MARC AS C
                            ON C~MATNR = A~MATNR
                          AND C~WERKS = @P_WERKS
     WHERE B~MTART   IN ( 'MCFE', 'MCHF' )  " 완제품 반제품만 공정대상
       AND B~MATKL LIKE 'H%'
       AND ( A~INDEX EQ 1
        OR ( A~INDEX NE 1
       AND  A~VERID IS NOT INITIAL ) )
      INTO TABLE @DATA(LT_SEQ_ROUTING).
  ENDIF.

  SELECT * FROM ZGTCVMSTVAL
    FOR ALL ENTRIES IN @LT_STB
   WHERE WERKS = @P_WERKS
     AND MATNR = @LT_STB-IDNRK
     AND MTREF = 'HALB'
    INTO TABLE @DATA(LT_MATNR_DETAIL).

* 외주공정여부 확인하여 외주공정이 이어져 있는 부분까지는 공정 어팬드
  SORT LT_SEQ_ROUTING BY SEQNO.
  LOOP AT LT_SEQ_ROUTING INTO DATA(LS_SEQ_ROUTING).
    CLEAR LS_BASE_GONG_SEQ.
    READ TABLE LT_MATNR_DETAIL INTO DATA(LS_MATNR_DETAIL) WITH KEY MATNR = LS_SEQ_ROUTING-MATNR.
    IF SY-SUBRC EQ 0.
      LS_BASE_GONG_SEQ-GONG_CD = LS_MATNR_DETAIL-PDCAPROCCODE.
      LS_BASE_GONG_SEQ-GONG_NM = LS_MATNR_DETAIL-PDCAPROCNAME.

      IF LS_MATNR_DETAIL-PDCAPROCCODE = 'BWD'.
        CONTINUE.
      ENDIF.

      IF LS_MATNR_DETAIL-BESKZ = 'F' AND LS_MATNR_DETAIL-SOBSL = ''. " 외주구매는 제외
        CONTINUE.
      ENDIF.

      READ TABLE LT_BASE_GONG_SEQ ASSIGNING FIELD-SYMBOL(<LS_INPUT>) WITH KEY GONG_CD = LS_BASE_GONG_SEQ-GONG_CD.
      IF SY-SUBRC EQ 0.
        READ TABLE <LS_INPUT>-T_MATNR ASSIGNING FIELD-SYMBOL(<LS_MATNR>) WITH KEY MATNR = LS_SEQ_ROUTING-MATNR.
        IF SY-SUBRC EQ 0.
          ADD 1 TO <LS_MATNR>-SEQNO.
        ELSE.
          APPEND INITIAL LINE TO <LS_INPUT>-T_MATNR ASSIGNING <LS_MATNR>.
          <LS_MATNR>-MATNR = LS_MATNR_DETAIL-MATNR.
          <LS_MATNR>-BESKZ = LS_MATNR_DETAIL-BESKZ.
          <LS_MATNR>-SOBSL = LS_MATNR_DETAIL-SOBSL.
          <LS_MATNR>-SEQNO = 1.
        ENDIF.
      ELSE.
        APPEND INITIAL LINE TO LT_BASE_GONG_SEQ ASSIGNING <LS_INPUT>.
        CLEAR LS_MATNR.
        LS_MATNR-MATNR = LS_MATNR_DETAIL-MATNR.
        LS_MATNR-BESKZ = LS_MATNR_DETAIL-BESKZ.
        LS_MATNR-SOBSL = LS_MATNR_DETAIL-SOBSL.
        LS_MATNR-SEQNO = 1.
        APPEND LS_MATNR TO LS_BASE_GONG_SEQ-T_MATNR.
        MOVE-CORRESPONDING LS_BASE_GONG_SEQ TO <LS_INPUT>.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LV_GONG_SEQ = PV_GONG_SEQ.

  LOOP AT LT_BASE_GONG_SEQ ASSIGNING <LS_INPUT>.
    ADD 1 TO LV_GONG_SEQ.
    <LS_INPUT>-GONG_SEQ = LV_GONG_SEQ.
  ENDLOOP.

  SORT LT_BASE_GONG_SEQ BY GONG_SEQ.
* 외주임가공 포함공정 첫번째 공정을 순차적으로 내리면서
* 해당 공정 반제품에 외주임가공이 아닌 반제품이 존재할시 중지
*&---------------------------------------------------------------------*
  LV_GONG_SEQ = PV_GONG_SEQ + 1.
  CLEAR LV_CHK_GONG_SEQ.
  LOOP AT LT_BASE_GONG_SEQ INTO DATA(LS_CHK_IMGAGONG) WHERE GONG_SEQ >= LV_GONG_SEQ.
    LOOP AT LS_CHK_IMGAGONG-T_MATNR INTO DATA(LS_MATNR_CHK).
* 공정 순서대로 임가공 여부 확인
      IF ( LS_MATNR_CHK-BESKZ = 'F' AND LS_MATNR_CHK-SOBSL = '30' ) OR
           ( LS_MATNR_CHK-BESKZ = 'X' AND LS_MATNR_CHK-SOBSL = '30' ).
        CONTINUE.
      ELSE.
        LV_CHK_GONG_SEQ = LS_CHK_IMGAGONG-GONG_SEQ.
      ENDIF.
      IF LV_CHK_GONG_SEQ IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF LV_CHK_GONG_SEQ IS NOT INITIAL.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF LV_GONG_SEQ NE LV_CHK_GONG_SEQ AND LV_CHK_GONG_SEQ NE 0.
    LOOP AT LT_BASE_GONG_SEQ INTO LS_BASE_GONG_SEQ WHERE GONG_SEQ >= LV_GONG_SEQ
                                                                               AND GONG_SEQ < LV_CHK_GONG_SEQ.
      APPEND LS_BASE_GONG_SEQ TO PT_CHK_GONG_SEQ[].
    ENDLOOP.
  ENDIF.
*&---------------------------------------------------------------------*

* 중지된 공정을 사급반제품으로 지정 수량 세팅
  READ TABLE LT_BASE_GONG_SEQ INTO LS_BASE_GONG_SEQ WITH KEY GONG_SEQ = LV_CHK_GONG_SEQ.
  LOOP AT LS_BASE_GONG_SEQ-T_MATNR INTO LS_MATNR.
    CLEAR PT_2330.
    PT_2330-GONG_CD = LS_BASE_GONG_SEQ-GONG_CD.
    PT_2330-MATNR = LS_MATNR-MATNR.
    PERFORM GET_MATNR_INFOR USING LS_MATNR-MATNR
                             CHANGING PT_2330-MEINS PT_2330-INLENGTH.
    PT_2330-INFACTOR = 1.
    APPEND PT_2330.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MATNR_INFOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MATNR_MATNR
*&      <-- PT_2330_MEINS
*&      <-- PT_2330_INLENGTH
*&---------------------------------------------------------------------*
FORM GET_MATNR_INFOR  USING    PV_MATNR TYPE MATNR
                      CHANGING PV_MEINS
                               PV_INLENGTH .

  DATA : LS_TOPMAT TYPE CSTMAT.
  DATA : LT_STB TYPE TABLE OF STPOX.
  DATA : LT_CSCMAT TYPE TABLE OF CSCMAT.

  SELECT SINGLE MEINS FROM MARA
    INTO PV_MEINS
   WHERE MATNR = PV_MATNR.

  SELECT SINGLE /SAPMP/MAX_FERTL FROM ZGTCVROUTING
     WHERE WERKS = @P_WERKS
       AND MATNR = @PV_MATNR
       AND FLGAT = '0' "대표설비
    INTO @DATA(LV_INLENGTH).

  IF SY-SUBRC EQ 0 AND LV_INLENGTH NE 0.
    PV_INLENGTH = LV_INLENGTH.
    RETURN.
  ENDIF.
**
*** 외주공정의 경우 표준만권량이 존재하지 않으므로
***  이전 공정중 외주공정이 아닌 자재가 있을경우 그자재의 만권량으로 표현해준다.
*** BOM 하위전개
**  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
**    EXPORTING
**      AUMGB                 = ABAP_ON
**      CAPID                 = 'PP01'
**      DATUV                 = SY-DATUM
**      EHNDL                 = '1'
**      MKTLS                 = ABAP_ON
**      MEHRS                 = ABAP_ON
**      MMORY                 = '1'
**      MTNRV                 = PV_MATNR
**      WERKS                 = P_WERKS
**    IMPORTING
**      TOPMAT                = LS_TOPMAT
**    TABLES
**      STB                   = LT_STB
**      MATCAT                = LT_CSCMAT
**    EXCEPTIONS
**      ALT_NOT_FOUND         = 1
**      CALL_INVALID          = 2
**      MATERIAL_NOT_FOUND    = 3
**      MISSING_AUTHORIZATION = 4
**      NO_BOM_FOUND          = 5
**      NO_PLANT_DATA         = 6
**      NO_SUITABLE_BOM_FOUND = 7
**      CONVERSION_ERROR      = 8
**      OTHERS                = 9.
**
**  IF LT_CSCMAT[] IS NOT INITIAL.
**    SELECT A~INDEX AS SEQNO, A~MATNR, B~MTART
**      FROM @LT_CSCMAT AS A
**      INNER JOIN MARA AS B
**                            ON B~MATNR = A~MATNR
**      INNER JOIN MARC AS C
**                            ON C~MATNR = A~MATNR
**                          AND C~WERKS = @P_WERKS
**     WHERE B~MTART   IN ( 'MCFE', 'MCHF' )  " 완제품 반제품만 공정대상
**       AND B~MATKL LIKE 'H%'
**       AND ( A~INDEX EQ 1
**        OR ( A~INDEX NE 1
**       AND  A~VERID IS NOT INITIAL ) )
**      INTO TABLE @DATA(LT_SEQ_ROUTING).
**  ENDIF.
**
**  SORT LT_SEQ_ROUTING BY SEQNO.
**
**  IF LT_SEQ_ROUTING[] IS NOT INITIAL.
**    SELECT * FROM ZGTCVMSTVAL
**       FOR ALL ENTRIES IN @LT_SEQ_ROUTING
**      WHERE WERKS = @P_WERKS
**      AND MATNR = @LT_SEQ_ROUTING-MATNR
**      INTO TABLE @DATA(LT_MATNR_DETAIL).
**  ENDIF.
**
**  LOOP AT LT_SEQ_ROUTING INTO DATA(LS_SEQ_ROUTING).
**    READ TABLE LT_MATNR_DETAIL INTO DATA(LS_MATNR_DETAIL) WITH KEY MATNR = LS_SEQ_ROUTING-MATNR.
**    IF SY-SUBRC EQ 0.
**      CASE LS_MATNR_DETAIL-BESKZ.
**        WHEN 'E' OR 'X'.
**          CLEAR LV_INLENGTH.
**          SELECT SINGLE /SAPMP/MAX_FERTL FROM ZGTCVROUTING
**             WHERE WERKS = @P_WERKS
**               AND MATNR = @LS_SEQ_ROUTING-MATNR
**               AND FLGAT = '0' "대표설비
**            INTO @LV_INLENGTH.
**
**          IF SY-SUBRC EQ 0 AND LV_INLENGTH NE 0.
**            PV_INLENGTH = LV_INLENGTH.
**            RETURN.
**          ENDIF.
**
**      ENDCASE.
**    ENDIF.
**  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0200 OUTPUT.
  IF GO_GRID_0200 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0200.
    PERFORM SET_LAYOUT_GRID_0200.
    PERFORM CALL_GRID_0200_DISPLAY.

    PERFORM SET_LAYOUT_GRID_0201.
    PERFORM SET_FIELDCAT_GRID_0201.
    PERFORM CALL_GRID_0201_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0200 .

  CREATE OBJECT GO_DOCKING_0200
    EXPORTING
      CONTAINER_NAME              = 'CONTAINER'                 " Name of the Screen CustCtrl Name to Link Container To
    EXCEPTIONS
      CNTL_ERROR                  = 1                " CNTL_ERROR
      CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
      CREATE_ERROR                = 3                " CREATE_ERROR
      LIFETIME_ERROR              = 4                " LIFETIME_ERROR
      LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.

*화면 분할
  CREATE OBJECT GO_SPLITTER_0200
    EXPORTING
      PARENT  = GO_DOCKING_0200
      ROWS    = 2
      COLUMNS = 1.

  GO_SPLITTER_0200->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    30 ).             " Height


* top 컨테이너(Title)
  CALL METHOD GO_SPLITTER_0200->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0200.
* top 컨테이너(Grid)
  CALL METHOD GO_SPLITTER_0200->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0201.


  CREATE OBJECT GO_GRID_0200
    EXPORTING
      I_PARENT      = GO_CONTAIN_0200
      I_APPL_EVENTS = ABAP_TRUE.

  CREATE OBJECT GO_GRID_0201
    EXPORTING
      I_PARENT      = GO_CONTAIN_0201
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0200 .

  CLEAR GS_LAYOUT_0200.
  GS_LAYOUT_0200-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0200-SEL_MODE = 'C'.
  GS_LAYOUT_0200-NO_TOOLBAR = ABAP_TRUE.
  GS_LAYOUT_0200-NO_ROWMARK = ABAP_TRUE.
  GS_LAYOUT_0200-SMALLTITLE = 'X'.
  GS_LAYOUT_0200-GRID_TITLE = '임가공공정'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0200_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0200_DISPLAY .

  CALL METHOD GO_GRID_0200->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT          = GS_LAYOUT_0200
      I_BYPASSING_BUFFER = ABAP_TRUE
    CHANGING
      IT_OUTTAB          = GT_MAIN_200
      IT_FIELDCATALOG    = GT_FIELDCAT_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0201 .

  CLEAR GS_LAYOUT_0201.
  GS_LAYOUT_0201-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0201-SEL_MODE = 'C'.
  GS_LAYOUT_0201-NO_TOOLBAR = ABAP_TRUE.
  GS_LAYOUT_0201-NO_ROWMARK = ABAP_TRUE.
  GS_LAYOUT_0201-SMALLTITLE = 'X'.
  GS_LAYOUT_0201-GRID_TITLE = '사급반제품'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0201 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2300TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_201'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0201.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0201[]
    TABLES
      IT_DATA         = GT_MAIN_201
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0201 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'GONG_CD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정'(f63).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재코드'(f64).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장'(f59).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(f18).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재내역'(f65).
        <LS_FCAT>-JUST = 'L'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0201_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0201_DISPLAY .

  CALL METHOD GO_GRID_0201->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT          = GS_LAYOUT_0201
      I_BYPASSING_BUFFER = ABAP_TRUE
    CHANGING
      IT_OUTTAB          = GT_MAIN_201
      IT_FIELDCATALOG    = GT_FIELDCAT_0201.

  GO_GRID_0201->SET_READY_FOR_INPUT( 1 ).

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0201->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0201->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_ANSWER
*&---------------------------------------------------------------------*
FORM CHECK_0200  CHANGING PV_ANSWER.

  IF GS_HEADER_200-LIFNR IS INITIAL.
    MESSAGE I006 WITH '공급업체가 지정되지 않았습니다.'(e36).
    PV_ANSWER = ABAP_TRUE.
    RETURN.
  ENDIF.

  IF GS_HEADER_200-EEIND IS INITIAL OR GS_HEADER_200-EEIND = '00000000'.
    MESSAGE I006 WITH '납품 예정일이 지정되지 않았습니다.'(e37).
    PV_ANSWER = ABAP_TRUE.
    RETURN.
  ENDIF.

  IF GS_HEADER_200-LGFSB IS INITIAL.
    MESSAGE I006 WITH '구매 입고 저장위치를 입력해 주세요.'(e38).
    PV_ANSWER = ABAP_TRUE.
    RETURN.
  ENDIF.

  IF GS_HEADER_200-CHK_HALF = ABAP_TRUE.
    IF GS_HEADER_200-INLENGTH = 0.
      MESSAGE I006 WITH '조장이 지정되지 않았습니다.'(e20).
      PV_ANSWER = ABAP_TRUE.
      RETURN.
    ENDIF.

    IF GS_HEADER_200-INFACTOR = 0.
      MESSAGE I006 WITH '조장수가 지정되지 않았습니다.'(e21).
      PV_ANSWER = ABAP_TRUE.
      RETURN.
    ENDIF.

  ENDIF.

  LOOP AT GT_MAIN_201 INTO DATA(LS_MAIN).
    IF LS_MAIN-INLENGTH = 0 OR
       LS_MAIN-INFACTOR = 0.
      MESSAGE I006 WITH '사급 반제품 조장 및 조장수를 확인해 주세요.'(e34).
      PV_ANSWER = ABAP_TRUE.
      RETURN.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4HELP_LIFNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4HELP_LIFNR .

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LV_OFFSET(6) TYPE N.
  DATA : LO_FLIEF TYPE REF TO DATA.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

  DATA : BEGIN OF LS_LIFNR,
           LIFNR TYPE EBAN-LIFNR,
           NAME1 TYPE LFA1-NAME1,
         END OF LS_LIFNR.
  DATA : LT_LIFNR LIKE TABLE OF LS_LIFNR.

  DATA : LV_LIFNR TYPE EBAN-LIFNR.

  MOVE-CORRESPONDING GT_LIFNR TO LT_LIFNR.

  FREE LO_FLIEF.
  CREATE DATA LO_FLIEF LIKE LS_LIFNR.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).

    CASE <LS_FIELD_TAB>-FIELDNAME.
      WHEN 'LIFNR'.
        <LS_FIELD_TAB>-REPTEXT  = '공급업체'.
      WHEN 'NAME1'.
        <LS_FIELD_TAB>-REPTEXT  = '내역'.
    ENDCASE.

    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'LIFNR'
      DYNPROFIELD     = 'GS_PR_INFOR-LIFNR'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '공급업체 조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = LT_LIFNR                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.

    REFRESH LT_DYNPFIELDS.
    PERFORM GET_STEPL USING LV_LINE.

*  구매처
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
    <LS_DYNPFIELDS>-FIELDNAME = 'GS_HEADER_200-LIFNR'.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_RETURN_TAB-FIELDVAL.

    CLEAR LV_LIFNR.
    LV_LIFNR = LS_RETURN_TAB-FIELDVAL..
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LV_LIFNR
      IMPORTING
        OUTPUT = LV_LIFNR.

    READ TABLE LT_LIFNR INTO LS_LIFNR WITH KEY LIFNR = LV_LIFNR.

*  구매처 내역
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING <LS_DYNPFIELDS>.
    <LS_DYNPFIELDS>-FIELDNAME = 'GS_HEADER_200-NAME1'.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_LIFNR-NAME1.

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
*& Form CREATE_PURCHASE_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CREATE_PURCHASE_ORDER  CHANGING PV_CHK_ERR.

  DATA : LV_INLENGTH TYPE I.
  DATA : LV_INLENGTH_C(10) TYPE C.
  DATA : LV_INFACTOR TYPE I.
  DATA : LV_INFACTOR_C(10) TYPE C.
  DATA : LV_FIELDNAME TYPE FNAM_____4.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_PSMNG_C(30) TYPE C.
  DATA : LV_PSMNG TYPE GAMNG.
  DATA : LV_POSNR2(4) TYPE N.
  DATA : LV_LINES TYPE I.
  DATA : LV_EBELN TYPE EBELN.

  REFRESH : GT_BDCDATA, GT_MESSTAB.

  __SETTING_BDC_PARAMS.

  __BDC_DYNPRO 'SAPMM06E' '0100'.
  __BDC_FIELD : 'BDC_OKCODE' '/00',
                      'EKKO-LIFNR' GS_HEADER_200-LIFNR,
                      'RM06E-BSART' 'NB',
                      'RM06E-BEDAT' GS_HEADER_200-EEIND,
                      'EKKO-EKORG' GS_EKORG-EKORG,
                      'EKKO-EKGRP' GS_EKORG-EKGRP,
                      'RM06E-EPSTP' 'L',
                      'RM06E-EEIND' GS_HEADER_200-EEIND,
                      'RM06E-LGORT' GS_HEADER_200-LGFSB,
                      'RM06E-LPEIN' 'T',
                      'RM06E-WERKS' P_WERKS.

  __BDC_DYNPRO 'SAPMM06E' '0101'.
  __BDC_FIELD : 'BDC_OKCODE' '=AB',
                      'EKKO-EKGRP' GS_EKORG-EKGRP,
                      'EKKO-PINCR' '10',
                      'EKKO-SPRAS' 'KO'.

  __BDC_DYNPRO 'SAPMM06E' '0120'.
  __BDC_FIELD : 'BDC_OKCODE' '/00'.

  CLEAR LV_NUM.

  ADD 1 TO LV_NUM.
*     자재코드
  CLEAR LV_FIELDNAME.
  LV_FIELDNAME = |EKPO-EMATN({ LV_NUM })|.
  __BDC_FIELD : LV_FIELDNAME GS_HEADER_200-MATNR.
*     단위
  CLEAR LV_FIELDNAME.
  LV_FIELDNAME = |EKPO-MEINS({ LV_NUM })|.
  __BDC_FIELD : LV_FIELDNAME GS_HEADER_200-MEINS.

  LV_PSMNG = GS_HEADER_200-INLENGTH * GS_HEADER_200-INFACTOR.
  LV_PSMNG_C = LV_PSMNG.
  CONDENSE LV_PSMNG_C.

* 임가공 사급자재 구성
  READ TABLE GT_FIELDCAT_0200 INTO DATA(LS_FCAT) WITH KEY FIELDNAME = 'CHART01'.

  PERFORM SET_RESB_PO USING GS_HEADER_200-MATNR LV_PSMNG LS_FCAT-REPTEXT.

*     수량
  CLEAR LV_FIELDNAME.
  LV_FIELDNAME = |EKPO-MENGE({ LV_NUM })|.
  __BDC_FIELD : LV_FIELDNAME LV_PSMNG_C.


  CLEAR LV_POSNR2.
  ADD 10 TO LV_POSNR2.

  __BDC_DYNPRO 'SAPMM06E' '0120'.
  __BDC_FIELD : 'BDC_OKCODE' '/00',
                      'RM06E-EBELP' LV_POSNR2.

  __BDC_DYNPRO 'SAPMM06E' '0120'.
  __BDC_FIELD : 'BDC_OKCODE' '=LB',
                      'RM06E-EBELP' LV_POSNR2.

  __BDC_DYNPRO 'SAPLM61Q' '0115'.
  __BDC_FIELD : 'BDC_OKCODE' '=MALL'.

  __BDC_DYNPRO 'SAPLM61Q' '0115'.
  __BDC_FIELD : 'BDC_OKCODE' '=DELE'.

  __BDC_DYNPRO 'SAPLM61Q' '0115'.
  __BDC_FIELD : 'BDC_OKCODE' '=POS1'.

  __BDC_DYNPRO 'SAPLM61Q' '0110'.
  __BDC_FIELD : 'BDC_OKCODE' '/00'.

  CLEAR : LV_POSNR2, LV_NUM.
  LOOP AT GT_IMGAGONG_RESB INTO GS_IMGAGONG_RESB.
    ADD 1 TO LV_NUM.
    ADD 10 TO LV_POSNR2.
*     자재코드
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = |MDPM-MATNR({ LV_NUM })|.
    __BDC_FIELD : LV_FIELDNAME GS_IMGAGONG_RESB-MATNR.
*     단위
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = |MDPM-ERFME({ LV_NUM })|.
    __BDC_FIELD : LV_FIELDNAME GS_IMGAGONG_RESB-ERFME.

*     플랜트
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = |MDPM-WERKS({ LV_NUM })|.
    __BDC_FIELD : LV_FIELDNAME P_WERKS.

*     구성부품 소요일
*     구성부품 소요일이 구매오더 입고일보다 클경우
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = |MDPM-BDTER({ LV_NUM })|.
    __BDC_FIELD : LV_FIELDNAME GS_HEADER_200-EEIND.

*     구성부품 품목
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = |MDPM-POSNR({ LV_NUM })|.
    __BDC_FIELD : LV_FIELDNAME LV_POSNR2.

*     수량
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = |MDPM-ERFMG({ LV_NUM })|.

    LV_PSMNG = GS_IMGAGONG_RESB-ERFMG.
    LV_PSMNG_C = LV_PSMNG.
    CONDENSE LV_PSMNG_C.
    __BDC_FIELD : LV_FIELDNAME LV_PSMNG_C.

  ENDLOOP.

  __BDC_DYNPRO 'SAPLM61Q' '0110'.
  __BDC_FIELD : 'BDC_OKCODE' '=BACK'.



* 특성입력
  CLEAR LV_POSNR2.

  ADD 10 TO LV_POSNR2.

  __BDC_DYNPRO 'SAPMM06E' '0120'.
  __BDC_FIELD : 'BDC_OKCODE' '/00',
                      'RM06E-EBELP' LV_POSNR2.

  __BDC_DYNPRO 'SAPMM06E' '0120'.
  __BDC_FIELD : 'BDC_OKCODE' '=KONF',
                      'RM06E-EBELP' LV_POSNR2.

  LV_INLENGTH = GS_HEADER_200-INLENGTH.
  LV_INLENGTH_C = LV_INLENGTH.
  CONDENSE LV_INLENGTH_C.

  LV_INFACTOR = GS_HEADER_200-INFACTOR.
  LV_INFACTOR_C = LV_INFACTOR.
  CONDENSE LV_INFACTOR_C.


  __BDC_DYNPRO 'SAPLCEI0' '0109'.
  __BDC_FIELD : 'BDC_OKCODE' '=BACK',
                      'RCTMS-MNAME(01)' 'SAP_MILLCA_LENGTH',
                      'RCTMS-MNAME(02)' 'SAP_MILLCA_FACTOR',
                      'RCTMS-MWERT(01)' LV_INLENGTH_C,
                      'RCTMS-MWERT(02)' LV_INFACTOR_C.



  __BDC_DYNPRO 'SAPMM06E' '0120'.
  __BDC_FIELD : 'BDC_OKCODE' '=BU'.

  __BDC_TRANSACTION 'ME21'.

  CLEAR LV_EBELN.
  LOOP AT GT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'S'
                                                         AND MSGID = '06'
                                                         AND MSGNR = '017'.

    LV_EBELN = LS_MESSTAB-MSGV2.
    __ALPHA_INPUT LV_EBELN.

    LOOP AT GT_2340_CHG ASSIGNING FIELD-SYMBOL(<LS_2340>).
      <LS_2340>-ORDNR = LV_EBELN.
      <LS_2340>-POSNR = 10.
      <LS_2340>-ORDTY = 'PO'.
    ENDLOOP.

  ENDLOOP.

  IF LV_EBELN IS INITIAL.
    PV_CHK_ERR = ABAP_TRUE.
    READ TABLE GT_MESSTAB INTO LS_MESSTAB WITH KEY MSGTYP = 'E'.
    MESSAGE ID LS_MESSTAB-MSGID TYPE 'S' NUMBER LS_MESSTAB-MSGNR
        WITH LS_MESSTAB-MSGV1 LS_MESSTAB-MSGV2 LS_MESSTAB-MSGV3 LS_MESSTAB-MSGV4
        DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HALF_MATNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM SET_HALF_MATNR  USING    PV_ZDISTRIB TYPE ZGTPPT2330-ZDISTRIB
                         CHANGING PV_CHK_ERR.

  DATA : LT_PRODUCT LIKE GT_SET_MATNR.
  DATA : LS_PRODUCT LIKE GS_SET_MATNR. " 완제품 수량 정보 테이블
  DATA : LT_CHG_2330 TYPE TABLE OF ZGTPPT2330.
  DATA : LT_DEL_2330 TYPE TABLE OF ZGTPPT2330.
  DATA : LV_INDEX TYPE I.
  DATA : BEGIN OF LS_CHK_MAX_ZWKREQ,
           ZWKREQ   TYPE ZGTPPT2330-ZWKREQ,
           SEQNO(6) TYPE C,
         END OF LS_CHK_MAX_ZWKREQ.
  DATA : LT_CHK_MAX_ZWKREQ LIKE TABLE OF LS_CHK_MAX_ZWKREQ.
  DATA : LV_GSMNG TYPE GSMNG.
  DATA : LV_GSMNG_TOT TYPE GSMNG.
  DATA : LT_PLAN_ORDERS TYPE MRPDS_PLONO. " 삭제용
  DATA : LT_PLAN_ORDERS_ROLLBACK TYPE MRPDS_PLONO." 오류시 삭제용
  DATA : LV_CHK_ERR.
  DATA : LV_MESSAGE(100).
  DATA : LV_INLENGTH TYPE ZGTPPT2330-INLENGTH.
  DATA : LV_ZUNDER TYPE ZGTPPT2340-ZUNDER.

  DATA : LV_MAX_SEQ(6) TYPE N.

  REFRESH : GT_SET_MATNR, GT_2330_FUL, GT_2340_FUL.

  SELECT * FROM ZGTPPT2330
    INTO TABLE GT_2330_FUL
   WHERE WERKS = P_WERKS
     AND SPGCD = P_SPGCD
     AND RQMON = P_SPMON.

  SELECT * FROM ZGTPPT2340
      INTO TABLE GT_2340_FUL
     WHERE WERKS = P_WERKS
       AND SPGCD = P_SPGCD
       AND RQMON = P_SPMON.

  LOOP AT GT_2330_FUL INTO DATA(LS_2330) WHERE GONG_SEQ = '01' AND ZDISTRIB = PV_ZDISTRIB AND DMORD IS NOT INITIAL.

    CASE PV_ZDISTRIB .
      WHEN '1'.
        CLEAR LS_PRODUCT.
        READ TABLE GT_2340_FUL INTO DATA(LS_2340) WITH KEY ZWKREQ = LS_2330-ZWKREQ.
        IF SY-SUBRC EQ 0.
          LS_PRODUCT-GONG_CD = LS_2330-GONG_CD.
          LS_PRODUCT-MATNR = LS_2330-MATNR.
          PERFORM CHK_PRE_GONG USING LS_2340 CHANGING LS_PRODUCT-RE_MATNR.
          LS_PRODUCT-ZSPECNO = LS_2330-ZSPECNO.
          LS_PRODUCT-GAMNG = LS_2330-BMENG.
          COLLECT LS_PRODUCT INTO LT_PRODUCT.
          CONTINUE.
        ENDIF.
      WHEN '2'.
        CLEAR LS_PRODUCT.
        LS_PRODUCT-GONG_CD = LS_2330-GONG_CD.
        LS_PRODUCT-MATNR = LS_2330-MATNR.
        LS_PRODUCT-ZSPECNO = LS_2330-ZSPECNO.
        LS_PRODUCT-GAMNG = LS_2330-BMENG.
        COLLECT LS_PRODUCT INTO LT_PRODUCT.
        CONTINUE.
    ENDCASE.
  ENDLOOP.

  PERFORM SET_PROGRESS_INDICATOR USING '60' '하위 반제품 생산계획 수량 재 계산중..'.
* 반제품 수량 확인
  LOOP AT LT_PRODUCT INTO LS_PRODUCT.
    PERFORM GET_BOM_FR_PRD USING LS_PRODUCT.
  ENDLOOP.

* 전체 반제품 확인하여 임가공일시 수량 제외 로직
  PERFORM CONV_ROUND.

  DELETE GT_2330_FUL WHERE GONG_SEQ = '01' AND DMORD IS NOT INITIAL.

* 작업 요청 순번 지정을 위해 작업요청 MaX 번호 가져온다
  SELECT  ZWKREQ, RIGHT( ZWKREQ, 6 ) AS SEQNO
    FROM ZGTPPT2330
    WHERE WERKS = @P_WERKS
      AND SPGCD = @P_SPGCD
      AND RQMON = @P_SPMON
    INTO CORRESPONDING FIELDS OF TABLE @LT_CHK_MAX_ZWKREQ.

  SELECT  ZWKREQ, RIGHT( ZWKREQ, 6 ) AS SEQNO
    FROM ZGTPPT2340
    WHERE WERKS = @P_WERKS
      AND SPGCD = @P_SPGCD
      AND RQMON = @P_SPMON
    APPENDING CORRESPONDING FIELDS OF TABLE @LT_CHK_MAX_ZWKREQ.

  SORT LT_CHK_MAX_ZWKREQ BY SEQNO DESCENDING.
  READ TABLE LT_CHK_MAX_ZWKREQ INTO LS_CHK_MAX_ZWKREQ INDEX 1.

  LV_MAX_SEQ = LS_CHK_MAX_ZWKREQ-SEQNO.

* 반제품 수량 변경하여 업데이트 테이블 적용
  LOOP AT GT_SET_MATNR INTO LS_PRODUCT.
    CLEAR LS_2330.
    READ TABLE GT_2330_FUL INTO LS_2330 WITH KEY GONG_CD = LS_PRODUCT-GONG_CD
                                                                     MATNR = LS_PRODUCT-MATNR
                                                                     ZSPECNO = LS_PRODUCT-ZSPECNO
                                                                     ZDISTRIB = PV_ZDISTRIB.
    IF SY-SUBRC EQ 0.
      LV_INDEX = SY-TABIX.
      DELETE GT_2330_FUL INDEX LV_INDEX.
      IF LS_2330-PLNUM IS NOT INITIAL.
        APPEND LS_2330-PLNUM TO LT_PLAN_ORDERS.
      ENDIF.
      LS_2330-BMENG = LS_PRODUCT-GAMNG.

      CLEAR LV_INLENGTH.
      PERFORM GET_MATNR_INFOR USING LS_PRODUCT-MATNR
                               CHANGING LS_2330-MEINS LV_INLENGTH.

      IF LV_INLENGTH = 0.
        LS_2330-INLENGTH = LS_PRODUCT-GAMNG.
      ENDIF.

* 반제품 작업에 필요한 작업여장, 검사여장
      IF LS_2330-QLENGTH = 0.
        LS_2330-QLENGTH = LS_PRODUCT-QLENGTH.
      ENDIF.
      IF LS_2330-CLENGTH = 0.
        LS_2330-CLENGTH = LS_PRODUCT-CLENGTH.
      ENDIF.

* 공정순번
      LOOP AT GT_BASE_GONG_SEQ INTO DATA(LS_GONG_SEQ) WHERE GONG_CD = LS_PRODUCT-GONG_CD.
        READ TABLE LS_GONG_SEQ-T_MATNR TRANSPORTING NO FIELDS WITH KEY MATNR = LS_PRODUCT-MATNR.
        IF SY-SUBRC EQ 0.
          LS_2330-GONG_SEQ = LS_GONG_SEQ-GONG_SEQ.
        ENDIF.
      ENDLOOP.
      IF LS_2330-GONG_SEQ = '00'.
        READ TABLE GT_BASE_GONG_SEQ INTO LS_GONG_SEQ WITH KEY GONG_CD = LS_PRODUCT-GONG_CD.
        LS_2330-GONG_SEQ = LS_GONG_SEQ-GONG_SEQ.
      ENDIF.

    ELSE.
      CLEAR LS_2330.
      LS_2330-WERKS = P_WERKS.
      LS_2330-SPGCD = P_SPGCD.
      LS_2330-RQMON = P_SPMON.

* 해당자재 자업지시가 있을경우 삭제되지 않는다.
      LOOP AT GT_2340_FUL INTO DATA(LS_CHK_2340) WHERE MATNR = LS_PRODUCT-MATNR.
        READ TABLE GT_2330_FUL INTO DATA(LS_CHK_2330) WITH KEY ZWKREQ = LS_CHK_2340-ZWKREQ.
        IF SY-SUBRC EQ 0 AND LS_CHK_2330-ZDISTRIB NE PV_ZDISTRIB. "
        ELSE.
          LS_2330-ZWKREQ = LS_CHK_2340-ZWKREQ.
          DELETE GT_2330_FUL WHERE ZWKREQ = LS_CHK_2340-ZWKREQ.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LS_2330-ZWKREQ IS INITIAL.
        ADD 1 TO LV_MAX_SEQ.
        LS_2330-ZWKREQ = SY-DATUM+2(6) && LV_MAX_SEQ.
      ENDIF.
      LS_2330-ZDISTRIB = PV_ZDISTRIB.
      LS_2330-GONG_CD = LS_PRODUCT-GONG_CD.
      LS_2330-MATNR = LS_PRODUCT-MATNR.
      LS_2330-ZSPECNO = LS_PRODUCT-ZSPECNO.
* 작업요청월 + '01'
      LS_2330-PSTTR = P_SPMON && '01'.
* 작업요청월 + 말일
      LS_2330-PEDTR = LS_2330-PSTTR.
      PERFORM GET_LAST_DAY_OF_MONTH CHANGING LS_2330-PEDTR.
      LS_2330-BMENG = LS_PRODUCT-GAMNG.
      PERFORM GET_MATNR_INFOR USING LS_PRODUCT-MATNR
                               CHANGING LS_2330-MEINS LS_2330-INLENGTH.

      IF LS_2330-INLENGTH = 0.
        LS_2330-INLENGTH = LS_PRODUCT-GAMNG.
      ENDIF.

      LS_2330-INFACTOR = 0.

* 반제품 작업에 필요한 작업여장, 검사여장
      LS_2330-QLENGTH = LS_PRODUCT-QLENGTH.
      LS_2330-CLENGTH = LS_PRODUCT-CLENGTH.

* 공정순번
      LOOP AT GT_BASE_GONG_SEQ INTO LS_GONG_SEQ WHERE GONG_CD = LS_PRODUCT-GONG_CD.
        READ TABLE LS_GONG_SEQ-T_MATNR TRANSPORTING NO FIELDS WITH KEY MATNR = LS_PRODUCT-MATNR.
        IF SY-SUBRC EQ 0.
          LS_2330-GONG_SEQ = LS_GONG_SEQ-GONG_SEQ.
        ENDIF.
      ENDLOOP.

      IF LS_2330-GONG_SEQ = '00'.
        READ TABLE GT_BASE_GONG_SEQ INTO LS_GONG_SEQ WITH KEY GONG_CD = LS_PRODUCT-GONG_CD.
        LS_2330-GONG_SEQ = LS_GONG_SEQ-GONG_SEQ.
      ENDIF.

    ENDIF.

    APPEND LS_2330 TO LT_CHG_2330.

  ENDLOOP.
* 봄수량 미계산대상은 대상이 아니므로 삭제
  IF GT_2330_FUL IS NOT INITIAL.
    LOOP AT GT_2330_FUL INTO LS_2330 WHERE ZDISTRIB = PV_ZDISTRIB.
      READ TABLE GT_2340_FUL INTO LS_CHK_2340 WITH KEY ZWKREQ = LS_2330-ZWKREQ.
      IF SY-SUBRC EQ 0.
        IF LS_2330-PLNUM IS NOT INITIAL.
          READ TABLE LT_CHG_2330 INTO DATA(LS_CHK_CHANGE) WITH KEY ZWKREQ = LS_2330-ZWKREQ.
          IF SY-SUBRC NE 0.
            CLEAR LS_2330-PLNUM.
            MODIFY ZGTPPT2330 FROM LS_2330.
            COMMIT WORK AND WAIT.
          ENDIF.

          APPEND LS_2330-PLNUM TO LT_PLAN_ORDERS.
        ENDIF.
      ELSE.
        APPEND LS_2330 TO LT_DEL_2330.
      ENDIF.
    ENDLOOP.
  ENDIF.

  PERFORM SET_PROGRESS_INDICATOR USING '80' '하위 반제품 생산계획 수량 재  생성중..'.
* 반제품별 수량 재계산
  LOOP AT LT_CHG_2330 ASSIGNING FIELD-SYMBOL(<LS_CHG_2330>).
    CLEAR LV_GSMNG.
    IF <LS_CHG_2330>-INLENGTH NE 0.
      LV_GSMNG = <LS_CHG_2330>-BMENG / <LS_CHG_2330>-INLENGTH.
      <LS_CHG_2330>-INFACTOR = ROUND( VAL = LV_GSMNG DEC = 0 MODE = 1 ).
    ELSE.
      <LS_CHG_2330>-INLENGTH = <LS_CHG_2330>-BMENG.
      <LS_CHG_2330>-INFACTOR = 1.
    ENDIF.

    <LS_CHG_2330>-GSMNG = <LS_CHG_2330>-INFACTOR * <LS_CHG_2330>-INLENGTH.
    CLEAR LV_GSMNG.
    CLEAR LV_ZUNDER.
    LOOP AT GT_2340_FUL INTO LS_2340 WHERE ZWKREQ = <LS_CHG_2330>-ZWKREQ.
      LV_GSMNG = LV_GSMNG + ( LS_2340-INLENGTH * LS_2340-INFACTOR ).
      IF LS_2340-ZUNDER = ABAP_TRUE.
        LV_ZUNDER = ABAP_TRUE.
      ENDIF.
    ENDLOOP.

    IF LV_ZUNDER = ABAP_TRUE.
      <LS_CHG_2330>-GSMNG = <LS_CHG_2330>-GSMNG + <LS_CHG_2330>-ZADDMNG.
    ENDIF.

    IF <LS_CHG_2330>-GSMNG =< LV_GSMNG. "작업 지시량이 작업 요청량보다 크다면 계획오더 생성 없음
      CLEAR <LS_CHG_2330>-PLNUM.
    ELSE.
      CLEAR LV_CHK_ERR.
      LV_GSMNG_TOT = <LS_CHG_2330>-GSMNG - LV_GSMNG.
*      생성전 체크 " 생산버전 + 유효일자
      PERFORM CHK_MATNR_INFOR CHANGING <LS_CHG_2330> LV_CHK_ERR.
      IF LV_CHK_ERR = ABAP_TRUE.
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.

      PERFORM MAKE_PLAN_ORDER CHANGING <LS_CHG_2330> LV_GSMNG_TOT LV_CHK_ERR.
      IF LV_CHK_ERR = ABAP_TRUE.
        PV_CHK_ERR = ABAP_TRUE.
        CLEAR LV_MESSAGE.
        CONCATENATE '공정코드' <LS_CHG_2330>-GONG_CD '의 반제품 자재' <LS_CHG_2330>-MATNR '계획오더 생성 중 오류가 발생했습니다.'
                    INTO LV_MESSAGE SEPARATED BY SPACE.

        PERFORM ROLLBACK_PLAN_ORDER USING LT_PLAN_ORDERS_ROLLBACK.
        MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MESSAGE.
        RETURN.
      ENDIF.
      APPEND <LS_CHG_2330>-PLNUM TO LT_PLAN_ORDERS_ROLLBACK.

    ENDIF.

  ENDLOOP.

  PERFORM SET_PROGRESS_INDICATOR USING '95' '하위 반제품 생산계획 저장중..'.

* 요청테이블 등록.
  IF LT_DEL_2330 IS NOT INITIAL.
    DELETE ZGTPPT2330 FROM TABLE LT_DEL_2330.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
      PERFORM ROLLBACK_PLAN_ORDER USING LT_PLAN_ORDERS_ROLLBACK.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '반제품 자재 생산계획 저장중 오류 발생하였습니다.'.
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
  ENDIF.

* 요청테이블 등록.
  IF LT_CHG_2330 IS NOT INITIAL.
    MODIFY ZGTPPT2330 FROM TABLE LT_CHG_2330.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
      PERFORM ROLLBACK_PLAN_ORDER USING LT_PLAN_ORDERS_ROLLBACK.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '반제품 자재 생산계획 저장중 오류 발생하였습니다.'.
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
  ENDIF.

* 기존 계획 오더 삭제
  PERFORM ROLLBACK_PLAN_ORDER USING LT_PLAN_ORDERS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LAST_DAY_OF_MONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_LASTDATE
*&---------------------------------------------------------------------*
FORM GET_LAST_DAY_OF_MONTH  CHANGING PV_DATE TYPE SY-DATUM.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = PV_DATE
    IMPORTING
      LAST_DAY_OF_MONTH = PV_DATE
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.
  .
  IF SY-SUBRC <> 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_BOM_FR_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_PRODUCT
*&---------------------------------------------------------------------*
FORM GET_BOM_FR_PO  USING    PS_PRODUCT LIKE GS_SET_MATNR.

  DATA : LT_STB TYPE TABLE OF STPOX.
  DATA : LT_CSCMAT TYPE TABLE OF CSCMAT.
  DATA : LV_EMENG TYPE STKO-BMENG.
  DATA : LV_EMENG2 TYPE STKO-BMENG.
  DATA : LV_CHK_GONG_CD TYPE ZGTPPT2330-GONG_CD.
  DATA : LS_PRODUCT LIKE GS_SET_MATNR. " 완제품 수량 정보 테이블
  DATA : LT_PRODUCT LIKE TABLE OF GS_SET_MATNR. " 완제품 수량 정보 테이블
  DATA : LT_BASE_GONG_SEQ LIKE GT_BASE_GONG_SEQ.
  DATA : LS_BASE_GONG_SEQ LIKE GS_BASE_GONG_SEQ.
  DATA : LS_MATNR LIKE GS_MATNR.
  DATA : LT_MATNR LIKE GT_MATNR.
  DATA : LV_GONG_SEQ TYPE ZGTPPT2340-GONG_SEQ.
  DATA : LV_CHK_GONG_SEQ TYPE ZGTPPT2340-GONG_SEQ.
  DATA : LT_EXIST_MATNR TYPE RANGE OF MATNR.
  DATA : LV_MNGKO TYPE STPOX-MNGKO.

  LV_EMENG = PS_PRODUCT-GAMNG.

  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      CAPID                 = 'PP01'
      DATUV                 = SY-DATUM
      EMENG                 = LV_EMENG
      MTNRV                 = PS_PRODUCT-MATNR " 자재
      WERKS                 = P_WERKS " 플랜트
      MEHRS                 = ABAP_TRUE " 멀티체크
      MMORY                 = '0'
    TABLES
      STB                   = LT_STB
      MATCAT                = LT_CSCMAT
    EXCEPTIONS
      ALT_NOT_FOUND         = 1
      CALL_INVALID          = 2
      MATERIAL_NOT_FOUND    = 3
      MISSING_AUTHORIZATION = 4
      NO_BOM_FOUND          = 5
      NO_PLANT_DATA         = 6
      NO_SUITABLE_BOM_FOUND = 7
      CONVERSION_ERROR      = 8
      OTHERS                = 9.

  IF LT_CSCMAT[] IS NOT INITIAL.
    SELECT A~INDEX AS SEQNO, A~MATNR, B~MTART
      FROM @LT_CSCMAT AS A
      INNER JOIN MARA AS B
                            ON B~MATNR = A~MATNR
      INNER JOIN MARC AS C
                            ON C~MATNR = A~MATNR
                          AND C~WERKS = @P_WERKS
     WHERE B~MTART   IN ( 'MCFE', 'MCHF' )  " 완제품 반제품만 공정대상
       AND B~MATKL LIKE 'H%'
       AND ( A~INDEX EQ 1
        OR ( A~INDEX NE 1
       AND  A~VERID IS NOT INITIAL ) )
      INTO TABLE @DATA(LT_SEQ_ROUTING).
  ENDIF.

  SELECT * FROM ZGTCVMSTVAL
    FOR ALL ENTRIES IN @LT_STB
   WHERE WERKS = @P_WERKS
     AND MATNR = @LT_STB-IDNRK
     AND MTREF = 'HALB'
    INTO TABLE @DATA(LT_MATNR_DETAIL).

* 외주공정여부 확인하여 외주공정이 이어져 있는 부분까지는 제외
  SORT LT_SEQ_ROUTING BY SEQNO.
  LOOP AT LT_SEQ_ROUTING INTO DATA(LS_SEQ_ROUTING).
    CLEAR LS_BASE_GONG_SEQ.
    READ TABLE LT_MATNR_DETAIL INTO DATA(LS_MATNR_DETAIL) WITH KEY MATNR = LS_SEQ_ROUTING-MATNR.
    IF SY-SUBRC EQ 0.
      LS_BASE_GONG_SEQ-GONG_CD = LS_MATNR_DETAIL-PDCAPROCCODE.
      LS_BASE_GONG_SEQ-GONG_NM = LS_MATNR_DETAIL-PDCAPROCNAME.

      IF LS_MATNR_DETAIL-PDCAPROCCODE = 'BWD'.
        CONTINUE.
      ENDIF.

      IF LS_MATNR_DETAIL-PDCAPROCCODE IS INITIAL.
        CONTINUE.
      ENDIF.

      IF LS_MATNR_DETAIL-BESKZ = 'F' AND LS_MATNR_DETAIL-SOBSL = ''. " 외주구매는 제외
        CONTINUE.
      ENDIF.

      READ TABLE LT_BASE_GONG_SEQ ASSIGNING FIELD-SYMBOL(<LS_INPUT>) WITH KEY GONG_CD = LS_BASE_GONG_SEQ-GONG_CD.
      IF SY-SUBRC EQ 0.
        READ TABLE <LS_INPUT>-T_MATNR ASSIGNING FIELD-SYMBOL(<LS_MATNR>) WITH KEY MATNR = LS_SEQ_ROUTING-MATNR.
        IF SY-SUBRC EQ 0.
          ADD 1 TO <LS_MATNR>-SEQNO.
        ELSE.
          APPEND INITIAL LINE TO <LS_INPUT>-T_MATNR ASSIGNING <LS_MATNR>.
          <LS_MATNR>-MATNR = LS_MATNR_DETAIL-MATNR.
          <LS_MATNR>-BESKZ = LS_MATNR_DETAIL-BESKZ.
          <LS_MATNR>-SOBSL = LS_MATNR_DETAIL-SOBSL.
          <LS_MATNR>-SEQNO = 1.
        ENDIF.
      ELSE.
        APPEND INITIAL LINE TO LT_BASE_GONG_SEQ ASSIGNING <LS_INPUT>.
        CLEAR LS_MATNR.
        LS_MATNR-MATNR = LS_MATNR_DETAIL-MATNR.
        LS_MATNR-BESKZ = LS_MATNR_DETAIL-BESKZ.
        LS_MATNR-SOBSL = LS_MATNR_DETAIL-SOBSL.
        LS_MATNR-SEQNO = 1.
        APPEND LS_MATNR TO LS_BASE_GONG_SEQ-T_MATNR.
        MOVE-CORRESPONDING LS_BASE_GONG_SEQ TO <LS_INPUT>.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LV_GONG_SEQ = '01'.

  LOOP AT LT_BASE_GONG_SEQ ASSIGNING <LS_INPUT>.
    IF PS_PRODUCT-GONG_CD = <LS_INPUT>-GONG_CD.
      <LS_INPUT>-GONG_SEQ = '01'.
    ELSE.
      ADD 1 TO LV_GONG_SEQ.
      <LS_INPUT>-GONG_SEQ = LV_GONG_SEQ.
    ENDIF.
  ENDLOOP.

  SORT LT_BASE_GONG_SEQ BY GONG_SEQ.
* 외주임가공 포함공정 첫번째 공정을 순차적으로 내리면서 해당 공정 반제품에 외주임가공이 아닌 반제품이 존재할시 중지
*&---------------------------------------------------------------------*
  LV_GONG_SEQ = '02'.
  CLEAR LV_CHK_GONG_SEQ.
  LOOP AT LT_BASE_GONG_SEQ INTO DATA(LS_CHK_IMGAGONG) WHERE GONG_SEQ >= LV_GONG_SEQ.
    LOOP AT LS_CHK_IMGAGONG-T_MATNR INTO DATA(LS_MATNR_CHK).
* 공정 순서대로 임가공 여부 확인
      IF ( LS_MATNR_CHK-BESKZ = 'F' AND LS_MATNR_CHK-SOBSL = '30' ) OR
           ( LS_MATNR_CHK-BESKZ = 'X' AND LS_MATNR_CHK-SOBSL = '30' ).
        CONTINUE.
      ELSE.
        LV_CHK_GONG_SEQ = LS_CHK_IMGAGONG-GONG_SEQ.
      ENDIF.
      IF LV_CHK_GONG_SEQ IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF LV_CHK_GONG_SEQ IS NOT INITIAL.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF LV_GONG_SEQ NE LV_CHK_GONG_SEQ AND LV_CHK_GONG_SEQ NE 0.
    DELETE LT_BASE_GONG_SEQ WHERE GONG_CD >= LV_GONG_SEQ
                                             AND GONG_CD < LV_CHK_GONG_SEQ.
  ENDIF.
*&---------------------------------------------------------------------*

  LOOP AT LT_BASE_GONG_SEQ INTO LS_BASE_GONG_SEQ.
    LOOP AT LS_BASE_GONG_SEQ-T_MATNR INTO LS_MATNR.
* 외주 임가공 대상 인지 확인하여 사급 반제품수량 제외로직
      IF ( LS_MATNR-BESKZ = 'F' AND LS_MATNR-SOBSL = '30' ) OR
        ( LS_MATNR-BESKZ = 'X' AND LS_MATNR-SOBSL = '30' ).
        IF LT_EXIST_MATNR[] IS NOT INITIAL.
          IF LS_MATNR IN LT_EXIST_MATNR. "
            CONTINUE.
          ENDIF.
        ENDIF.

        REFRESH LT_PRODUCT.
        LOOP AT  LT_STB INTO DATA(LS_STB) WHERE IDNRK = LS_MATNR-MATNR.
          ADD LS_STB-MNGLG TO LV_MNGKO.
        ENDLOOP.
        PERFORM GET_EXIST_IMGAGONG_MENGE TABLES LT_PRODUCT
                                                          USING LS_MATNR-MATNR LS_STB-MNGLG.

        IF LT_PRODUCT IS NOT INITIAL.
          LOOP AT LT_PRODUCT INTO DATA(LS_CHK_MNGKO).
            READ TABLE LT_STB ASSIGNING FIELD-SYMBOL(<LS_STB_MNGKO>) WITH KEY IDNRK = LS_CHK_MNGKO-MATNR.
            IF SY-SUBRC EQ 0.
              <LS_STB_MNGKO>-MNGLG = <LS_STB_MNGKO>-MNGLG - LS_CHK_MNGKO-GAMNG.
            ENDIF.

            APPEND INITIAL LINE TO LT_EXIST_MATNR ASSIGNING FIELD-SYMBOL(<LS_EXIST_MATNR>).
            <LS_EXIST_MATNR>-SIGN = 'I'.
            <LS_EXIST_MATNR>-OPTION = 'EQ'.
            <LS_EXIST_MATNR>-LOW = LS_CHK_MNGKO-MATNR.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  LOOP AT LT_BASE_GONG_SEQ INTO LS_BASE_GONG_SEQ.
    LOOP AT LS_BASE_GONG_SEQ-T_MATNR INTO LS_MATNR.
      CLEAR LS_PRODUCT.
      LS_PRODUCT-GONG_CD = LS_BASE_GONG_SEQ-GONG_CD.
      LS_PRODUCT-GONG_NM = LS_BASE_GONG_SEQ-GONG_NM.
      LS_PRODUCT-GONG_SEQ = LS_BASE_GONG_SEQ-GONG_SEQ.
      LS_PRODUCT-MATNR = LS_MATNR-MATNR.
      LOOP AT  LT_STB INTO LS_STB WHERE IDNRK = LS_MATNR-MATNR.
        ADD LS_STB-MNGLG TO LS_PRODUCT-GAMNG.
      ENDLOOP.
      COLLECT LS_PRODUCT INTO GT_SET_MATNR.
    ENDLOOP.
  ENDLOOP.

  DATA : LV_CHK_ERR.
  DATA : LV_CHK_EXIST.
* 하위 공정에 필요한 LC계산(작업여장, 검사여장포함)
  LOOP AT GT_SET_MATNR ASSIGNING FIELD-SYMBOL(<LS_CAL_LC>).
    CLEAR LV_GONG_SEQ.
    LV_GONG_SEQ = <LS_CAL_LC>-GONG_SEQ.
    DO.

      LV_CHK_EXIST = ABAP_TRUE.
      LV_GONG_SEQ = LV_GONG_SEQ - 1.
      LOOP AT GT_SET_MATNR INTO DATA(LS_DEV_GONG) WHERE GONG_SEQ = LV_GONG_SEQ.
        CLEAR LV_CHK_ERR.
        PERFORM FIND_LC_FOR_ROUTING USING LS_DEV_GONG-MATNR <LS_CAL_LC>-MATNR
                                        CHANGING <LS_CAL_LC>-QLENGTH <LS_CAL_LC>-CLENGTH LV_CHK_ERR.

        IF LV_CHK_ERR IS INITIAL.
          CLEAR LV_CHK_EXIST.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LV_CHK_EXIST = ABAP_TRUE.
        CLEAR LV_CHK_ERR.
        MOVE PS_PRODUCT TO LS_DEV_GONG.
        PERFORM FIND_LC_FOR_ROUTING USING LS_DEV_GONG-MATNR <LS_CAL_LC>-MATNR
                                     CHANGING <LS_CAL_LC>-QLENGTH <LS_CAL_LC>-CLENGTH LV_CHK_ERR.
      ENDIF.

      IF LV_CHK_ERR IS INITIAL.
        EXIT.
      ENDIF.

    ENDDO.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_EXIST_IMGAGONG_MENGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_PRODUCT
*&      --> LS_MATNR_MATNR
*&      --> LS_STB_MNGLG
*&---------------------------------------------------------------------*
FORM GET_EXIST_IMGAGONG_MENGE  TABLES   PT_PRODUCT STRUCTURE GS_SET_MATNR
                               USING    PV_MATNR TYPE MATNR
                                        PV_MNGKO TYPE STPOX-MNGKO.

  DATA : LT_STB TYPE TABLE OF STPOX.
  DATA : LT_CSCMAT TYPE TABLE OF CSCMAT.
  DATA : LV_EMENG TYPE STKO-BMENG.
  DATA : LV_EMENG2 TYPE STKO-BMENG.
  DATA : LS_PRODUCT LIKE GS_SET_MATNR. " 완제품 수량 정보 테이블
  DATA : LT_PRODUCT LIKE TABLE OF GS_SET_MATNR. " 완제품 수량 정보 테이블
  DATA : LT_BASE_GONG_SEQ LIKE GT_BASE_GONG_SEQ.
  DATA : LS_BASE_GONG_SEQ LIKE GS_BASE_GONG_SEQ.
  DATA : LS_MATNR LIKE GS_MATNR.
  DATA : LT_MATNR LIKE GT_MATNR.
  DATA : LV_GONG_SEQ TYPE ZGTPPT2340-GONG_SEQ.
  DATA : LV_CHK_GONG_SEQ TYPE ZGTPPT2340-GONG_SEQ.

  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      CAPID                 = 'PP01'
      DATUV                 = SY-DATUM
      EMENG                 = LV_EMENG
      MTNRV                 = PV_MATNR " 자재
      WERKS                 = P_WERKS " 플랜트
      MEHRS                 = ABAP_TRUE " 멀티체크
      MMORY                 = '0'
    TABLES
      STB                   = LT_STB
      MATCAT                = LT_CSCMAT
    EXCEPTIONS
      ALT_NOT_FOUND         = 1
      CALL_INVALID          = 2
      MATERIAL_NOT_FOUND    = 3
      MISSING_AUTHORIZATION = 4
      NO_BOM_FOUND          = 5
      NO_PLANT_DATA         = 6
      NO_SUITABLE_BOM_FOUND = 7
      CONVERSION_ERROR      = 8
      OTHERS                = 9.

  IF LT_CSCMAT[] IS NOT INITIAL.
    SELECT A~INDEX AS SEQNO, A~MATNR, B~MTART
      FROM @LT_CSCMAT AS A
      INNER JOIN MARA AS B
                            ON B~MATNR = A~MATNR
      INNER JOIN MARC AS C
                            ON C~MATNR = A~MATNR
                          AND C~WERKS = @P_WERKS
     WHERE B~MTART   IN ( 'MCFE', 'MCHF' )  " 완제품 반제품만 공정대상
       AND B~MATKL LIKE 'H%'
       AND ( A~INDEX EQ 1
        OR ( A~INDEX NE 1
       AND  A~VERID IS NOT INITIAL ) )
      INTO TABLE @DATA(LT_SEQ_ROUTING).
  ENDIF.

  SELECT * FROM ZGTCVMSTVAL
    FOR ALL ENTRIES IN @LT_STB
   WHERE WERKS = @P_WERKS
     AND MATNR = @LT_STB-IDNRK
     AND MTREF = 'HALB'
    INTO TABLE @DATA(LT_MATNR_DETAIL).

* 외주공정여부 확인하여 외주공정이 이어져 있는 부분까지는 제외
  SORT LT_SEQ_ROUTING BY SEQNO.
  LOOP AT LT_SEQ_ROUTING INTO DATA(LS_SEQ_ROUTING).
    CLEAR LS_BASE_GONG_SEQ.
    READ TABLE LT_MATNR_DETAIL INTO DATA(LS_MATNR_DETAIL) WITH KEY MATNR = LS_SEQ_ROUTING-MATNR.
    IF SY-SUBRC EQ 0.
      LS_BASE_GONG_SEQ-GONG_CD = LS_MATNR_DETAIL-PDCAPROCCODE.
      LS_BASE_GONG_SEQ-GONG_NM = LS_MATNR_DETAIL-PDCAPROCNAME.

      IF LS_MATNR_DETAIL-PDCAPROCCODE = 'BWD'.
        CONTINUE.
      ENDIF.

      IF LS_MATNR_DETAIL-PDCAPROCCODE IS INITIAL.
        CONTINUE.
      ENDIF.

      IF LS_MATNR_DETAIL-BESKZ = 'F' AND LS_MATNR_DETAIL-SOBSL = ''. " 외주구매는 제외
        CONTINUE.
      ENDIF.

      READ TABLE LT_BASE_GONG_SEQ ASSIGNING FIELD-SYMBOL(<LS_INPUT>) WITH KEY GONG_CD = LS_BASE_GONG_SEQ-GONG_CD.
      IF SY-SUBRC EQ 0.
        READ TABLE <LS_INPUT>-T_MATNR ASSIGNING FIELD-SYMBOL(<LS_MATNR>) WITH KEY MATNR = LS_SEQ_ROUTING-MATNR.
        IF SY-SUBRC EQ 0.
          ADD 1 TO <LS_MATNR>-SEQNO.
        ELSE.
          APPEND INITIAL LINE TO <LS_INPUT>-T_MATNR ASSIGNING <LS_MATNR>.
          <LS_MATNR>-MATNR = LS_MATNR_DETAIL-MATNR.
          <LS_MATNR>-BESKZ = LS_MATNR_DETAIL-BESKZ.
          <LS_MATNR>-SOBSL = LS_MATNR_DETAIL-SOBSL.
          <LS_MATNR>-SEQNO = 1.
        ENDIF.
      ELSE.
        APPEND INITIAL LINE TO LT_BASE_GONG_SEQ ASSIGNING <LS_INPUT>.
        CLEAR LS_MATNR.
        LS_MATNR-MATNR = LS_MATNR_DETAIL-MATNR.
        LS_MATNR-BESKZ = LS_MATNR_DETAIL-BESKZ.
        LS_MATNR-SOBSL = LS_MATNR_DETAIL-SOBSL.
        LS_MATNR-SEQNO = 1.
        APPEND LS_MATNR TO LS_BASE_GONG_SEQ-T_MATNR.
        MOVE-CORRESPONDING LS_BASE_GONG_SEQ TO <LS_INPUT>.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CLEAR LV_GONG_SEQ.

  LOOP AT LT_BASE_GONG_SEQ ASSIGNING <LS_INPUT>.
    ADD 1 TO LV_GONG_SEQ.
    <LS_INPUT>-GONG_SEQ = LV_GONG_SEQ.
  ENDLOOP.

  LV_GONG_SEQ = '01'.
  CLEAR LV_CHK_GONG_SEQ.
  LOOP AT LT_BASE_GONG_SEQ INTO DATA(LS_CHK_IMGAGONG) WHERE GONG_SEQ >= LV_GONG_SEQ.
    LOOP AT LS_CHK_IMGAGONG-T_MATNR INTO DATA(LS_MATNR_CHK).
* 공정 순서대로 임가공 여부 확인
      IF ( LS_MATNR_CHK-BESKZ = 'F' AND LS_MATNR_CHK-SOBSL = '30' ) OR
           ( LS_MATNR_CHK-BESKZ = 'X' AND LS_MATNR_CHK-SOBSL = '30' ).
        CONTINUE.
      ELSE.
        LV_CHK_GONG_SEQ = LS_CHK_IMGAGONG-GONG_SEQ.
      ENDIF.
      IF LV_CHK_GONG_SEQ IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF LV_CHK_GONG_SEQ IS NOT INITIAL.
      EXIT.
    ENDIF.
  ENDLOOP.

* 임가공 오더에 포함되는 이전 공정이 존재한다면
  IF LV_GONG_SEQ NE LV_CHK_GONG_SEQ AND LV_CHK_GONG_SEQ NE 0.
    LOOP AT LT_BASE_GONG_SEQ INTO DATA(LS_GONG_SEQ) WHERE GONG_SEQ >= LV_GONG_SEQ
                                                                               AND GONG_SEQ < LV_CHK_GONG_SEQ.

      LOOP AT LS_BASE_GONG_SEQ-T_MATNR INTO LS_MATNR.
        CLEAR LS_PRODUCT.
        LS_PRODUCT-GONG_CD = LS_BASE_GONG_SEQ-GONG_CD.
        LS_PRODUCT-GONG_NM = LS_BASE_GONG_SEQ-GONG_NM.
        LS_PRODUCT-MATNR = LS_MATNR-MATNR.
        LOOP AT  LT_STB INTO DATA(LS_STB) WHERE IDNRK = LS_MATNR-MATNR.
          ADD LS_STB-MNGLG TO LS_PRODUCT-GAMNG.
        ENDLOOP.
        COLLECT LS_PRODUCT INTO LT_PRODUCT.
      ENDLOOP.
    ENDLOOP.

    IF LT_PRODUCT IS NOT INITIAL.
      APPEND LINES OF LT_PRODUCT TO PT_PRODUCT[].
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_BOM_FR_PRD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_PRODUCT
*&---------------------------------------------------------------------*
FORM GET_BOM_FR_PRD  USING    PS_PRODUCT LIKE GS_SET_MATNR.

  DATA : LT_STB TYPE TABLE OF STPOX.
  DATA : LT_CSCMAT TYPE TABLE OF CSCMAT.
  DATA : LV_EMENG TYPE STKO-BMENG.
  DATA : LV_EMENG2 TYPE STKO-BMENG.
  DATA : LS_PRODUCT LIKE GS_SET_MATNR. " 완제품 수량 정보 테이블
  DATA : LT_PRODUCT LIKE TABLE OF GS_SET_MATNR. " 완제품 수량 정보 테이블
  DATA : LT_BASE_GONG_SEQ LIKE GT_BASE_GONG_SEQ.
  DATA : LS_BASE_GONG_SEQ LIKE GS_BASE_GONG_SEQ.
  DATA : LS_MATNR LIKE GS_MATNR.
  DATA : LT_MATNR LIKE GT_MATNR.
  DATA : LV_GONG_SEQ TYPE ZGTPPT2340-GONG_SEQ.
  DATA : LV_CHK_GONG_SEQ TYPE ZGTPPT2340-GONG_SEQ.
  DATA : LT_EXIST_MATNR TYPE RANGE OF MATNR.
  DATA : LV_MNGKO TYPE STPOX-MNGKO.
  DATA : LS_PRE_PRODUCT LIKE GS_SET_MATNR.

  LV_EMENG = PS_PRODUCT-GAMNG.

  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      CAPID                 = 'PP01'
      DATUV                 = SY-DATUM
      EMENG                 = LV_EMENG
      MTNRV                 = PS_PRODUCT-MATNR " 자재
      WERKS                 = P_WERKS " 플랜트
      MEHRS                 = ABAP_TRUE " 멀티체크
      MMORY                 = '0'
    TABLES
      STB                   = LT_STB
      MATCAT                = LT_CSCMAT
    EXCEPTIONS
      ALT_NOT_FOUND         = 1
      CALL_INVALID          = 2
      MATERIAL_NOT_FOUND    = 3
      MISSING_AUTHORIZATION = 4
      NO_BOM_FOUND          = 5
      NO_PLANT_DATA         = 6
      NO_SUITABLE_BOM_FOUND = 7
      CONVERSION_ERROR      = 8
      OTHERS                = 9.

  IF LT_CSCMAT[] IS NOT INITIAL.
    SELECT A~INDEX AS SEQNO, A~MATNR, B~MTART
      FROM @LT_CSCMAT AS A
      INNER JOIN MARA AS B
                            ON B~MATNR = A~MATNR
      INNER JOIN MARC AS C
                            ON C~MATNR = A~MATNR
                          AND C~WERKS = @P_WERKS
     WHERE A~MATNR NOT IN @GT_JOJANG_MATNR
       AND B~MTART   IN ( 'MCFE', 'MCHF' )  " 완제품 반제품만 공정대상
       AND B~MATKL LIKE 'H%'
       AND ( A~INDEX EQ 1
        OR ( A~INDEX NE 1
       AND  A~VERID IS NOT INITIAL ) )
      INTO TABLE @DATA(LT_SEQ_ROUTING).
  ENDIF.

  DELETE LT_SEQ_ROUTING WHERE MATNR = PS_PRODUCT-MATNR.

  SELECT * FROM ZGTCVMSTVAL
    FOR ALL ENTRIES IN @LT_STB
   WHERE WERKS = @P_WERKS
     AND MATNR = @LT_STB-IDNRK
     AND MTREF = 'HALB'
    INTO TABLE @DATA(LT_MATNR_DETAIL).

* 외주공정여부 확인하여 외주공정이 이어져 있는 부분까지는 제외
  SORT LT_SEQ_ROUTING BY SEQNO.
  LOOP AT LT_SEQ_ROUTING INTO DATA(LS_SEQ_ROUTING).
    CLEAR LS_BASE_GONG_SEQ.
    READ TABLE LT_MATNR_DETAIL INTO DATA(LS_MATNR_DETAIL) WITH KEY MATNR = LS_SEQ_ROUTING-MATNR.
    IF SY-SUBRC EQ 0.
      LS_BASE_GONG_SEQ-GONG_CD = LS_MATNR_DETAIL-PDCAPROCCODE.
      LS_BASE_GONG_SEQ-GONG_NM = LS_MATNR_DETAIL-PDCAPROCNAME.

      IF LS_MATNR_DETAIL-PDCAPROCCODE = 'BWD'.
        CONTINUE.
      ENDIF.

      IF LS_MATNR_DETAIL-PDCAPROCCODE IS INITIAL.
        CONTINUE.
      ENDIF.

      IF LS_MATNR_DETAIL-BESKZ = 'F' AND LS_MATNR_DETAIL-SOBSL = ''. " 외주구매는 제외
        CONTINUE.
      ENDIF.

      READ TABLE LT_BASE_GONG_SEQ ASSIGNING FIELD-SYMBOL(<LS_INPUT>) WITH KEY GONG_CD = LS_BASE_GONG_SEQ-GONG_CD.
      IF SY-SUBRC EQ 0.
        READ TABLE <LS_INPUT>-T_MATNR ASSIGNING FIELD-SYMBOL(<LS_MATNR>) WITH KEY MATNR = LS_SEQ_ROUTING-MATNR.
        IF SY-SUBRC EQ 0.
          ADD 1 TO <LS_MATNR>-SEQNO.
        ELSE.
          APPEND INITIAL LINE TO <LS_INPUT>-T_MATNR ASSIGNING <LS_MATNR>.
          <LS_MATNR>-MATNR = LS_MATNR_DETAIL-MATNR.
          <LS_MATNR>-BESKZ = LS_MATNR_DETAIL-BESKZ.
          <LS_MATNR>-SOBSL = LS_MATNR_DETAIL-SOBSL.
          <LS_MATNR>-SEQNO = 1.
        ENDIF.
      ELSE.
        APPEND INITIAL LINE TO LT_BASE_GONG_SEQ ASSIGNING <LS_INPUT>.
        CLEAR LS_MATNR.
        LS_MATNR-MATNR = LS_MATNR_DETAIL-MATNR.
        LS_MATNR-BESKZ = LS_MATNR_DETAIL-BESKZ.
        LS_MATNR-SOBSL = LS_MATNR_DETAIL-SOBSL.
        LS_MATNR-SEQNO = 1.
        APPEND LS_MATNR TO LS_BASE_GONG_SEQ-T_MATNR.
        MOVE-CORRESPONDING LS_BASE_GONG_SEQ TO <LS_INPUT>.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LV_GONG_SEQ = '01'.

  LOOP AT LT_BASE_GONG_SEQ ASSIGNING <LS_INPUT>.
    IF PS_PRODUCT-GONG_CD = <LS_INPUT>-GONG_CD.
      <LS_INPUT>-GONG_SEQ = '01'.
    ELSE.
      ADD 1 TO LV_GONG_SEQ.
      <LS_INPUT>-GONG_SEQ = LV_GONG_SEQ.
    ENDIF.
  ENDLOOP.

  SORT LT_BASE_GONG_SEQ BY GONG_SEQ.

  LOOP AT LT_BASE_GONG_SEQ INTO LS_BASE_GONG_SEQ.
    LOOP AT LS_BASE_GONG_SEQ-T_MATNR INTO LS_MATNR.
* 외주 임가공 대상 인지 확인하여 사급 반제품수량 제외로직
      IF ( LS_MATNR-BESKZ = 'F' AND LS_MATNR-SOBSL = '30' ) OR
        ( LS_MATNR-BESKZ = 'X' AND LS_MATNR-SOBSL = '30' ).
        IF LT_EXIST_MATNR[] IS NOT INITIAL.
          IF LS_MATNR IN LT_EXIST_MATNR. "
            CONTINUE.
          ENDIF.
        ENDIF.

        REFRESH LT_PRODUCT.
        LOOP AT  LT_STB INTO DATA(LS_STB) WHERE IDNRK = LS_MATNR-MATNR.
          ADD LS_STB-MNGLG TO LV_MNGKO.
        ENDLOOP.
        PERFORM GET_EXIST_IMGAGONG_MENGE TABLES LT_PRODUCT
                                                          USING LS_MATNR-MATNR LS_STB-MNGLG.

        IF LT_PRODUCT IS NOT INITIAL.
          LOOP AT LT_PRODUCT INTO DATA(LS_CHK_MNGKO).
            READ TABLE LT_STB ASSIGNING FIELD-SYMBOL(<LS_STB_MNGKO>) WITH KEY IDNRK = LS_CHK_MNGKO-MATNR.
            IF SY-SUBRC EQ 0.
              <LS_STB_MNGKO>-MNGLG = <LS_STB_MNGKO>-MNGLG - LS_CHK_MNGKO-GAMNG.
            ENDIF.

            APPEND INITIAL LINE TO LT_EXIST_MATNR ASSIGNING FIELD-SYMBOL(<LS_EXIST_MATNR>).
            <LS_EXIST_MATNR>-SIGN = 'I'.
            <LS_EXIST_MATNR>-OPTION = 'EQ'.
            <LS_EXIST_MATNR>-LOW = LS_CHK_MNGKO-MATNR.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  CLEAR LS_PRE_PRODUCT.
  LOOP AT LT_BASE_GONG_SEQ INTO LS_BASE_GONG_SEQ.
    LOOP AT LS_BASE_GONG_SEQ-T_MATNR INTO LS_MATNR.

      READ TABLE GT_SET_MATNR INTO DATA(LS_CHK_EXIST) WITH KEY MATNR = LS_MATNR-MATNR.
      IF SY-SUBRC EQ 0.
        CLEAR LS_PRODUCT.
        MOVE-CORRESPONDING LS_CHK_EXIST TO LS_PRODUCT.
        CLEAR  LS_PRODUCT-GAMNG.
        LOOP AT  LT_STB INTO LS_STB WHERE IDNRK = LS_MATNR-MATNR.
          ADD LS_STB-MNGLG TO LS_PRODUCT-GAMNG.
        ENDLOOP.

      ELSE.
        CLEAR LS_PRODUCT.
        LS_PRODUCT-GONG_CD = LS_BASE_GONG_SEQ-GONG_CD.
        LS_PRODUCT-GONG_NM = LS_BASE_GONG_SEQ-GONG_NM.
        LS_PRODUCT-GONG_SEQ = LS_BASE_GONG_SEQ-GONG_SEQ.
        LS_PRODUCT-MATNR = LS_MATNR-MATNR.
        LOOP AT  LT_STB INTO LS_STB WHERE IDNRK = LS_MATNR-MATNR.
          ADD LS_STB-MNGLG TO LS_PRODUCT-GAMNG.
        ENDLOOP.
      ENDIF.
      IF PS_PRODUCT-RE_MATNR IS NOT INITIAL AND PS_PRODUCT-RE_MATNR = LS_MATNR-MATNR.
        MOVE-CORRESPONDING LS_PRODUCT TO LS_PRE_PRODUCT.
      ELSE.
        COLLECT LS_PRODUCT INTO GT_SET_MATNR.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  IF LS_PRE_PRODUCT IS NOT INITIAL.
    PERFORM CAL_PRE_BOM_MENGE USING LS_PRE_PRODUCT.

    LOOP AT LT_BASE_GONG_SEQ INTO LS_BASE_GONG_SEQ.
      LOOP AT LS_BASE_GONG_SEQ-T_MATNR INTO LS_MATNR.
        READ TABLE GT_PRE_SET_MATNR INTO DATA(LS_DEL_GSMNG) WITH KEY MATNR = LS_MATNR-MATNR.
        IF SY-SUBRC EQ 0.
          READ TABLE GT_SET_MATNR ASSIGNING FIELD-SYMBOL(<LS_CAL_MATNR>) WITH KEY MATNR = LS_MATNR-MATNR.
          <LS_CAL_MATNR>-GAMNG = <LS_CAL_MATNR>-GAMNG - LS_DEL_GSMNG-GAMNG.
          IF <LS_CAL_MATNR>-GAMNG = 0.
            DELETE TABLE GT_SET_MATNR FROM <LS_CAL_MATNR>.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

  DATA : LV_CHK_ERR.
  DATA : LV_CHK_EXIST.
* 하위 공정에 필요한 LC계산(작업여장, 검사여장포함)
  LOOP AT GT_SET_MATNR ASSIGNING FIELD-SYMBOL(<LS_CAL_LC>).
    CLEAR LV_GONG_SEQ.
    LV_GONG_SEQ = <LS_CAL_LC>-GONG_SEQ.
    DO.
      IF LV_GONG_SEQ = '01'.
        EXIT.
      ENDIF.

      LV_CHK_EXIST = ABAP_TRUE.
      LV_GONG_SEQ = LV_GONG_SEQ - 1.
      LOOP AT GT_SET_MATNR INTO DATA(LS_DEV_GONG) WHERE GONG_SEQ = LV_GONG_SEQ.
        CLEAR LV_CHK_ERR.
        PERFORM FIND_LC_FOR_ROUTING USING LS_DEV_GONG-MATNR <LS_CAL_LC>-MATNR
                                        CHANGING <LS_CAL_LC>-QLENGTH <LS_CAL_LC>-CLENGTH LV_CHK_ERR.

        IF LV_CHK_ERR IS INITIAL.
          CLEAR LV_CHK_EXIST.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LV_CHK_EXIST = ABAP_TRUE.
        CLEAR LV_CHK_ERR.
        MOVE PS_PRODUCT TO LS_DEV_GONG.
        PERFORM FIND_LC_FOR_ROUTING USING LS_DEV_GONG-MATNR <LS_CAL_LC>-MATNR
                                     CHANGING <LS_CAL_LC>-QLENGTH <LS_CAL_LC>-CLENGTH LV_CHK_ERR.
      ENDIF.

      IF LV_CHK_ERR IS INITIAL.
        EXIT.
      ENDIF.

    ENDDO.

  ENDLOOP.

* 위에서 찾아온 최대 여장 길이로 맞추는 작업
  DATA : LV_QLENGTH TYPE ZGTPPT2330-QLENGTH.
  DATA : LV_CLENGTH TYPE ZGTPPT2330-CLENGTH.

  LOOP AT LT_BASE_GONG_SEQ INTO LS_BASE_GONG_SEQ.
    CLEAR : LV_QLENGTH, LV_CLENGTH.
    LOOP AT LS_BASE_GONG_SEQ-T_MATNR INTO LS_MATNR.
      READ TABLE GT_SET_MATNR INTO DATA(LS_LC_CHK) WITH KEY MATNR = LS_MATNR-MATNR.
      IF SY-SUBRC EQ 0.
        IF LV_QLENGTH < LS_LC_CHK-QLENGTH.
          LV_QLENGTH = LS_LC_CHK-QLENGTH.
        ENDIF.
        IF LV_CLENGTH < LS_LC_CHK-CLENGTH.
          LV_CLENGTH = LS_LC_CHK-CLENGTH.
        ENDIF.
      ENDIF.
    ENDLOOP.

* 가장 긴 여장 길이에 맞추어 세팅
    LOOP AT LS_BASE_GONG_SEQ-T_MATNR INTO LS_MATNR.
      READ TABLE GT_SET_MATNR ASSIGNING FIELD-SYMBOL(<LS_SET_LCLENGTH>) WITH KEY MATNR = LS_MATNR-MATNR.
      IF SY-SUBRC EQ 0.
        <LS_SET_LCLENGTH>-QLENGTH = LV_QLENGTH.
        <LS_SET_LCLENGTH>-CLENGTH = LV_CLENGTH.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_MATNR_INFOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_CHG_2330>
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_MATNR_INFOR  CHANGING PS_2330 TYPE ZGTPPT2330
                                    PV_CHK_ERR.

  DATA : LV_MATNR_C(40).
  DATA : LV_CHK_DATE(8) TYPE N.
  DATA : LV_ORIGN_DATE(8) TYPE N.

  SELECT SINGLE * FROM MKAL
    INTO @DATA(LS_MKAL)
   WHERE WERKS = @P_WERKS
     AND MATNR = @PS_2330-MATNR
     AND VERID = '1000'.
  IF SY-SUBRC NE 0.
    LV_MATNR_C = PS_2330-MATNR.
    __ALPHA_OUT LV_MATNR_C.
    MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MATNR_C '생산버전을 찾을 수 없습니다.'.
    RETURN.
  ENDIF.

  LV_CHK_DATE = LS_MKAL-ADATU.
  LV_ORIGN_DATE = PS_2330-PSTTR.

  IF LV_CHK_DATE > LV_ORIGN_DATE.
    PS_2330-PSTTR = LS_MKAL-ADATU.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_PLAN_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_CHG_2330>
*&      <-- LV_GSMNG_TOT
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM MAKE_PLAN_ORDER  CHANGING PS_2330 TYPE ZGTPPT2330
                                            PV_GSMNG TYPE GSMNG
                                            PV_CHK_ERR.

  DATA : LS_HEADERDATA TYPE BAPIPLAF_I1.
  DATA : LV_PLANNEDORDER TYPE BAPI_PLDORD-PLDORD_NUM.
  DATA : LS_RETURN TYPE BAPIRETURN1.

  LS_HEADERDATA-PLDORD_PROFILE  = 'LA'.
  LS_HEADERDATA-ORDER_START_DATE = PS_2330-PSTTR.
  LS_HEADERDATA-ORDER_FIN_DATE = PS_2330-PEDTR.
  LS_HEADERDATA-MATERIAL = PS_2330-MATNR.
  LS_HEADERDATA-PLAN_PLANT = P_WERKS.
  LS_HEADERDATA-PROD_PLANT = P_WERKS.
  LS_HEADERDATA-FIRMING_IND = 'X'.
  LS_HEADERDATA-TOTAL_PLORD_QTY = PV_GSMNG.

  CLEAR : LV_PLANNEDORDER, LS_RETURN.
  CALL FUNCTION 'BAPI_PLANNEDORDER_CREATE'
    EXPORTING
      HEADERDATA   = LS_HEADERDATA
    IMPORTING
      RETURN       = LS_RETURN
      PLANNEDORDER = LV_PLANNEDORDER.

  IF LS_RETURN-TYPE NE 'S'. "성공건에 대해 후행 로직 진행
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    PS_2330-PLNUM = LV_PLANNEDORDER.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ROLLBACK_PLAN_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_PLAN_ORDERS_ROLLBACK
*&---------------------------------------------------------------------*
FORM ROLLBACK_PLAN_ORDER  USING    PT_PLAN_ORDERS TYPE MRPDS_PLONO.

  DATA : LS_RETURN TYPE BAPIRETURN1.

  LOOP AT PT_PLAN_ORDERS INTO DATA(LS_ORDERS).
    CALL FUNCTION 'BAPI_PLANNEDORDER_DELETE'
      EXPORTING
        PLANNEDORDER = LS_ORDERS
      IMPORTING
        RETURN       = LS_RETURN.
  ENDLOOP.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_ROUND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONV_ROUND .

  LOOP AT GT_SET_MATNR ASSIGNING FIELD-SYMBOL(<LS_SET_MATNR>).

    CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
      EXPORTING
        I_RTYPE     = '+'
        I_RUNIT     = 1
        I_VALUE     = <LS_SET_MATNR>-GAMNG
      IMPORTING
        E_VALUE_RND = <LS_SET_MATNR>-GAMNG.

  ENDLOOP.


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
*& Form PROC_DEL_REQUEST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DEL_REQUEST .

  DATA : LT_MOSU LIKE GT_MAIN_DISP.
  DATA : LT_2330 TYPE TABLE OF ZGTPPT2330.
  DATA : LT_2340 TYPE TABLE OF ZGTPPT2340.
  DATA : LS_2330 TYPE ZGTPPT2330.
  DATA : LS_2340 TYPE ZGTPPT2340.
  DATA : BEGIN OF LS_CHK_MAX_ZWKREQ,
           ZWKREQ   TYPE ZGTPPT2330-ZWKREQ,
           SEQNO(6) TYPE C,
         END OF LS_CHK_MAX_ZWKREQ.
  DATA : LT_CHK_MAX_ZWKREQ LIKE TABLE OF LS_CHK_MAX_ZWKREQ.
  DATA : LV_AUFNR TYPE AUFNR.
  DATA : LV_CHK_ERR.
  DATA : LS_ORDSYVAL TYPE ZGTCVORDSYVAL.
  DATA : LV_OBJNR TYPE JEST-OBJNR.
  DATA : LV_USER_LINE TYPE BSVX-STTXT.
  DATA : LT_GRPNR TYPE RANGE OF ZGTPPT2000-GRPNR.

  DATA : LV_MAX_SEQ(6) TYPE N.

  LOOP AT GT_MAIN_DISP INTO DATA(LS_MAIN_CHK) WHERE CHECK = ABAP_TRUE
                                                                      AND CHK_PEGGING = ' '..
*    IF LS_MAIN_CHK-CHK_PROC = ABAP_FALSE.
*      MESSAGE S006 DISPLAY LIKE 'E' WITH '반제품 작업 요청이 진행된 오더만 선택할 수 있습니다.'(e22).
*      RETURN.
*    ENDIF.

    APPEND LS_MAIN_CHK TO LT_MOSU.
  ENDLOOP.

  IF LT_MOSU IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '작업요청 해제할 수 있는 주문이 없습니다.'(e23).
    RETURN.
  ENDIF.

  LT_GRPNR = VALUE #( FOR LW_MOSU IN LT_MOSU WHERE ( GRPNR IS NOT INITIAL )
                               ( SIGN = 'I' OPTION = 'EQ' LOW = LW_MOSU-GRPNR ) ).

* 페깅처리된 오더는 삭제대상이 아니므로 삭제 대상에서 제외
  LOOP AT LT_MOSU INTO DATA(LS_MOSU) WHERE CHK_PEGGING = ' '.
    LV_AUFNR = LS_MOSU-AUFNR.
    __ALPHA_INPUT LV_AUFNR.
* 작업지시 확인
    CLEAR LS_ORDSYVAL.
    SELECT SINGLE * FROM ZGTCVORDSYVAL
      INTO LS_ORDSYVAL
     WHERE AUFNR = LV_AUFNR.
    IF SY-SUBRC EQ 0.
      IF LS_ORDSYVAL-DLV = ABAP_TRUE.
* 작업 완료시 삭제 되면 안됨 삭제대상에서 빠짐
        CONTINUE.
      ELSEIF LS_ORDSYVAL-PDLV = ABAP_TRUE.
* 작업중일시 삭제 되면 안됨 삭제대상에서 빠짐
        CONTINUE.
      ELSEIF LS_ORDSYVAL-REL = ABAP_TRUE.
      ELSE.
      ENDIF.

* pay off상태 확인
      LV_OBJNR = 'OR' && LV_AUFNR.
      CALL FUNCTION 'STATUS_TEXT_EDIT'
        EXPORTING
          FLG_USER_STAT    = 'X'
          OBJNR            = LV_OBJNR
          ONLY_ACTIVE      = 'X'
          SPRAS            = SY-LANGU
          BYPASS_BUFFER    = 'X'
        IMPORTING
          USER_LINE        = LV_USER_LINE
        EXCEPTIONS
          OBJECT_NOT_FOUND = 1
          OTHERS           = 2.

      FIND ALL OCCURRENCES OF 'PAYO' IN LV_USER_LINE MATCH COUNT FINAL(LV_LINE).
      IF LV_LINE > 0. " Patoff 상태일지 삭제할수 없음 삭제대상에서 빠짐

        CONTINUE.
      ENDIF.
    ELSE.
*    오더정보 미조회시 오더 정보 확인후 진행가능
      MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더' LS_MOSU-AUFNR '정보를 확인 할 수 없습니다.'(e24).
      RETURN.
    ENDIF.

    READ TABLE GT_2340 INTO LS_2340 WITH KEY ORDNR = LV_AUFNR
                                                                POSNR = LS_MOSU-POSNR
                                                                ORDTY = 'PRD'.
    IF SY-SUBRC EQ 0.
      APPEND LS_2340 TO LT_2340.
      READ TABLE GT_2330 INTO LS_2330 WITH KEY ZWKREQ = LS_2340-ZWKREQ.
      IF SY-SUBRC EQ 0.
        APPEND LS_2330 TO LT_2330.
      ELSE.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더' LS_MOSU-AUFNR '정보를 확인 할 수 없습니다.'(e24).
        RETURN.
      ENDIF.
    ELSE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더' LS_MOSU-AUFNR '정보를 확인 할 수 없습니다.'(e24).
      RETURN.
    ENDIF.

  ENDLOOP.

*  IF LT_2330[] IS INITIAL.
*    MESSAGE S006 DISPLAY LIKE 'E' WITH '생산이 시작되여 작업요청 삭제할수 없습니다.'(e25).
*    RETURN.
*  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택한 사항으로 반제품 작업요청 해제 하시겠습니까?'
    '취소확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  PERFORM SET_PROGRESS_INDICATOR USING '10' '요청 삭제중...'.

  IF LT_2340 IS NOT INITIAL.
    DELETE ZGTPPT2340 FROM TABLE LT_2340.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더 작업요청 저장중 오류발생하였습니다.'(e06).
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_2330 IS NOT INITIAL.
    DELETE ZGTPPT2330 FROM TABLE LT_2330.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더 작업요청 저장중 오류발생하였습니다.'(e06).
      RETURN.
    ENDIF.
  ENDIF.

  PERFORM SET_PROGRESS_INDICATOR USING '50' '작업요청정보 삭제 완료'.

  PERFORM SET_HALF_MATNR USING '1' CHANGING LV_CHK_ERR.
  IF LV_CHK_ERR = ABAP_TRUE.
    MODIFY ZGTPPT2330 FROM TABLE LT_2330.
    MODIFY ZGTPPT2340 FROM TABLE LT_2340.
    COMMIT WORK AND WAIT.
    RETURN.
  ENDIF.

  IF LT_GRPNR[] IS NOT INITIAL.
    SORT LT_GRPNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_GRPNR COMPARING LOW.
    UPDATE ZGTPPT2000 SET RQMON = '000000'
      WHERE GRPNR IN LT_GRPNR
        AND ZSTATUS <> 'D'.
    COMMIT WORK AND WAIT.
  ENDIF.

  PERFORM SET_PROGRESS_INDICATOR USING '100' '완료'.

  PERFORM GET_PROC.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  PERFORM REFRESH_GRID USING GO_GRID_0101.


  MESSAGE S006 WITH '선택한 작업이 취소되었습니다.'(e12).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING     P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                            P_ROW TYPE LVC_S_ROW
                            P_COLUMN TYPE LVC_S_COL.

  IF P_ROW-INDEX = 0.
    RETURN.
  ENDIF.


  CASE P_SENDER.
    WHEN GO_GRID_0100.
      READ TABLE GT_MAIN_DISP INTO DATA(LS_MAIN_100) INDEX P_ROW-INDEX.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'REQ_FACTOR'.
          CASE LS_MAIN_100-GCATG.
            WHEN '판매오더'.
              SET PARAMETER ID 'AUN' FIELD LS_MAIN_100-DMORD.
              CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
              SET PARAMETER ID 'AUN' FIELD ''.
            WHEN OTHERS.
              PERFORM DISP_POPUP_SMORDER USING LS_MAIN_100-DMORD LS_MAIN_100-DMLINE.
          ENDCASE.
        WHEN 'MATNR'.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'K'.
          SET PARAMETER ID 'MAT' FIELD LS_MAIN_100-MATNR.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'WRK' FIELD ''.
          SET PARAMETER ID 'MAT' FIELD ''.
        WHEN 'AUFNR' OR 'POSNR'.
          SET PARAMETER ID 'ANR' FIELD LS_MAIN_100-AUFNR.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
        WHEN 'SNOTE'.
          IF LS_MAIN_100-SNOTE IS NOT INITIAL.
            PERFORM SET_AND_DISP_TEXT USING LS_MAIN_100.
          ENDIF.
        WHEN 'SNOTE2'.
          IF LS_MAIN_100-SNOTE IS NOT INITIAL.
            PERFORM SET_AND_DISP_TEXT2 USING LS_MAIN_100.
          ENDIF.
        WHEN 'CHAR'.
          IF LS_MAIN_100-CHAR IS NOT INITIAL.
            PERFORM DISPLAY_POPUP_CHARACTICS USING LS_MAIN_100.
          ENDIF.

      ENDCASE.
    WHEN GO_GRID_0101.
      READ TABLE GT_MAIN_DISP_101 INTO DATA(LS_MAIN_101) INDEX P_ROW-INDEX.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'PLNUM'.
          SET PARAMETER ID 'PAF' FIELD LS_MAIN_101-PLNUM.
          CALL TRANSACTION 'MD13' AND SKIP FIRST SCREEN.

        WHEN 'MATNR'.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'K'.
          SET PARAMETER ID 'MAT' FIELD LS_MAIN_101-MATNR.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'WRK' FIELD ''.
          SET PARAMETER ID 'MAT' FIELD ''.
        WHEN 'DISP_PO'.
          PERFORM DISPLSY_PO_INFOR USING LS_MAIN_101.
        WHEN 'MENGE02' OR 'MENGE03'.
          IF LS_MAIN_101-MENGE02 NE 0.
            PERFORM DISP_POPUP_ORDERS USING LS_MAIN_101.
          ENDIF.
      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_POPUP_SMORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_100_DMORD
*&      --> LS_MAIN_100_DMLINE
*&---------------------------------------------------------------------*
FORM DISP_POPUP_SMORDER  USING    PV_ORDNO TYPE ZGTPPT2001-ORDNO
                                  PV_POSNR TYPE ZGTPPT2001-POSNR.

  CLEAR GS_MAKE_ORDER2.
  SELECT SINGLE ORDNO, POSNR, MATNR, GAMNG, MEINS AS GMEIN, GSTRP, GLTRP,
               INLENGTH, INFACTOR, ZPMAT AS COV_MATNR, ZZPRIORITY, SNOTE
    INTO CORRESPONDING FIELDS OF @GS_MAKE_ORDER2
    FROM ZGTPPT2001
   WHERE ORDNO = @PV_ORDNO
      AND POSNR = @PV_POSNR.

  IF SY-SUBRC NE 0.
    RETURN.
  ENDIF.

  REFRESH GT_TEXT.
  SPLIT GS_MAKE_ORDER2-SNOTE AT CL_ABAP_CHAR_UTILITIES=>NEWLINE INTO TABLE GT_TEXT.

  CALL SCREEN '0400' STARTING AT 5 5 ENDING AT 83 19.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GO_TEXT_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GO_TEXT_400 .

  CREATE OBJECT GO_CONTAINER_400
    EXPORTING
      CONTAINER_NAME = 'CONTAINER_300'.

  CREATE OBJECT GO_TEXT_400
    EXPORTING
      WORDWRAP_MODE          = 2
      MAX_NUMBER_CHARS       = 255                         " maximum number of characters insertable into editor control
      PARENT                 = GO_CONTAINER_400                        " Parent Container
    EXCEPTIONS
      ERROR_CNTL_CREATE      = 1                        " Error while performing creation of TextEdit control!
      ERROR_CNTL_INIT        = 2                        " Error while initializing TextEdit control!
      ERROR_CNTL_LINK        = 3                        " Error while linking TextEdit control!
      ERROR_DP_CREATE        = 4                        " Error while creating DataProvider control!
      GUI_TYPE_NOT_SUPPORTED = 5                        " This type of GUI is not supported!
      OTHERS                 = 6.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GO_TEXT_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GO_TEXT_400 .

  GO_TEXT_400->SET_TOOLBAR_MODE( EXPORTING TOOLBAR_MODE = 0 ).

  GO_TEXT_400->SET_STATUSBAR_MODE( EXPORTING STATUSBAR_MODE = 0 ).

  GO_TEXT_400->SET_READONLY_MODE( EXPORTING READONLY_MODE = 1 ).

  GO_TEXT_400->SET_TEXT_AS_R3TABLE( EXPORTING TABLE = GT_TEXT ).

  CALL METHOD CL_GUI_CFW=>FLUSH
    EXCEPTIONS
      OTHERS = 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_POPUP_CHARACTICS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_100
*&---------------------------------------------------------------------*
FORM DISPLAY_POPUP_CHARACTICS  USING    PS_MAIN_100 LIKE GS_MAIN_DISP.

  DATA : LS_INCL_BILD TYPE INCL_BILD.
  DATA : LV_VBELN TYPE VBELN.
  LV_VBELN = PS_MAIN_100-DMORD.
  __ALPHA_INPUT LV_VBELN.
  SELECT SINGLE CUOBJ FROM VBAP
    INTO @DATA(LV_CUOBJ)
    WHERE VBELN = @LV_VBELN
      AND POSNR = @PS_MAIN_100-DMLINE.

  CHECK LV_CUOBJ IS NOT INITIAL.
* 초기화
  CALL FUNCTION 'CUD0_CONFIGURATION_INITIALIZER'.

  CALL FUNCTION 'VC_I_DISPLAY_CONFIGURATION'
    EXPORTING
      INSTANCE           = LV_CUOBJ
      INCLUDE_SCREEN     = LS_INCL_BILD
*     APPLICATION        = ' '
*     MATNR_APPL         =
*     WERKS_APPL         =
*     BESKZ_APPL         =
*     SOBSL_APPL         =
*     NO_STRUC           = 'X'
*     NO_RESULT          = 'X'
*     NO_MASTERD         = 'X'
*     NO_PRICE           = 'X'
*     NO_TYPEM           = 'X'
*     IV_INVALID_POSSIBLE       = ' '
      IV_NO_VALUE_CHECK  = ' X'
*     EFFECTIVITY        = ' '
    EXCEPTIONS
      INSTANCE_NOT_FOUND = 1
      INTERNAL_ERROR     = 2
      OTHERS             = 3.
  IF SY-SUBRC <> 0.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_AND_DISP_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_100
*&---------------------------------------------------------------------*
FORM SET_AND_DISP_TEXT2  USING    PS_MAIN_100 LIKE GS_MAIN_DISP.

  DATA : LT_TEXT TYPE TABLE OF CHAR255.
  DATA : LT_LINE TYPE TABLE OF TLINE.
  DATA : LV_NAME TYPE THEAD-TDNAME.
  DATA : LV_VBELN TYPE VBELN.
  DATA : LV_POSNR TYPE POSNR.
  LV_VBELN = GS_MAIN_DISP-DMORD.
  __ALPHA_INPUT LV_VBELN.
  LV_POSNR = GS_MAIN_DISP-DMLINE + 0.

  CASE PS_MAIN_100-GCATG.
    WHEN '판매오더'.
      LV_NAME = LV_VBELN && LV_POSNR.

      LV_NAME = LV_VBELN.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          ID                      = '0001'
          LANGUAGE                = SY-LANGU
          NAME                    = LV_NAME
          OBJECT                  = 'VBBP'
        TABLES
          LINES                   = LT_LINE
        EXCEPTIONS
          ID                      = 1
          LANGUAGE                = 2
          NAME                    = 3
          NOT_FOUND               = 4
          OBJECT                  = 5
          REFERENCE_CHECK         = 6
          WRONG_ACCESS_TO_ARCHIVE = 7
          OTHERS                  = 8.
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

      IF LT_LINE[] IS NOT INITIAL.
        LOOP AT LT_LINE INTO DATA(LS_LINE).
          APPEND INITIAL LINE TO LT_TEXT ASSIGNING FIELD-SYMBOL(<LS_TEXT>).
          <LS_TEXT> = LS_LINE-TDLINE.
        ENDLOOP.
      ENDIF.
    WHEN OTHERS.
      RETURN.
  ENDCASE.

  CALL FUNCTION 'ZGTPP_UTILL_TEXTEDIT'
    EXPORTING
      IV_MODE  = '1'
      IV_TITLE = '특기사항'
    CHANGING
      CT_TEXT  = LT_TEXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_AND_DISP_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_100
*&---------------------------------------------------------------------*
FORM SET_AND_DISP_TEXT  USING    PS_MAIN_100 LIKE GS_MAIN_DISP.

  DATA : LT_TEXT TYPE TABLE OF CHAR255.
  DATA : LT_LINE TYPE TABLE OF TLINE.
  DATA : LV_NAME TYPE THEAD-TDNAME.
  DATA : LV_VBELN TYPE VBELN.

  CASE PS_MAIN_100-GCATG.
    WHEN '판매오더'.
      LV_VBELN = PS_MAIN_100-DMORD.
      __ALPHA_INPUT LV_VBELN.

      LV_NAME = LV_VBELN.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          ID                      = '0001'
          LANGUAGE                = SY-LANGU
          NAME                    = LV_NAME
          OBJECT                  = 'VBBK'
        TABLES
          LINES                   = LT_LINE
        EXCEPTIONS
          ID                      = 1
          LANGUAGE                = 2
          NAME                    = 3
          NOT_FOUND               = 4
          OBJECT                  = 5
          REFERENCE_CHECK         = 6
          WRONG_ACCESS_TO_ARCHIVE = 7
          OTHERS                  = 8.
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

      IF LT_LINE[] IS NOT INITIAL.
        LOOP AT LT_LINE INTO DATA(LS_LINE).
          APPEND INITIAL LINE TO LT_TEXT ASSIGNING FIELD-SYMBOL(<LS_TEXT>).
          <LS_TEXT> = LS_LINE-TDLINE.
        ENDLOOP.
      ENDIF.
    WHEN OTHERS.
      SELECT SINGLE * FROM ZGTPPT2001
       WHERE ORDNO = @PS_MAIN_100-DMORD
         AND POSNR = @PS_MAIN_100-DMLINE
        INTO @DATA(LS_2001).

      SPLIT LS_2001-SNOTE AT CL_ABAP_CHAR_UTILITIES=>NEWLINE INTO TABLE LT_TEXT.
  ENDCASE.

  CALL FUNCTION 'ZGTPP_UTILL_TEXTEDIT'
    EXPORTING
      IV_MODE  = '1'
      IV_TITLE = '특기사항'
    CHANGING
      CT_TEXT  = LT_TEXT.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLSY_PO_INFOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_101
*&---------------------------------------------------------------------*
FORM DISPLSY_PO_INFOR  USING    PS_MAIN_101 LIKE GS_MAIN_DISP_101.

  DATA : LV_PLNUM TYPE PLNUM.
  DATA : LT_EBELN TYPE RANGE OF EBELN.
  DATA : LV_BUKRS  TYPE BUKRS.

  LV_PLNUM = PS_MAIN_101-PLNUM.
  __ALPHA_INPUT LV_PLNUM.

  LOOP AT GT_2340 INTO DATA(LS_2340) WHERE ZWKREQ = PS_MAIN_101-ZWKREQ AND ORDTY = 'PO'.
    APPEND INITIAL LINE TO LT_EBELN ASSIGNING FIELD-SYMBOL(<LS_EBELN>).
    <LS_EBELN>-SIGN = 'I'.
    <LS_EBELN>-OPTION = 'EQ'.
    <LS_EBELN>-LOW = LS_2340-ORDNR.
  ENDLOOP.

  IF LT_EBELN[] IS INITIAL.
    RETURN.
  ENDIF.

  SELECT SINGLE BUKRS FROM T001K
    INTO LV_BUKRS
    WHERE BWKEY = P_WERKS.

  CLEAR GS_EKORG.
  SELECT SINGLE FLD_02 AS WERKS, FLD_03 AS EKORG, FLD_04 AS EKGRP
  FROM ZGTPPT1010
  INTO @GS_EKORG
 WHERE MODULE_KIND = 'PP'
   AND CODEGRP = '2090'
   AND FLD_01 = 'L'
   AND FLD_02 = @P_WERKS.

  SORT LT_EBELN BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_EBELN COMPARING LOW.

  SUBMIT ZGTMMR3010 WITH  P_BUKRS = LV_BUKRS
                               WITH P_EKORG = GS_EKORG-EKORG
                               WITH S_EBELN IN LT_EBELN
                               AND RETURN.

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
  PERFORM SET_SORT_TAB TABLES GT_SORT_0100
                            USING : 1 'GRPNR'  'X' '' '',
                                      2 'DMORD'  'X' '' '',
                                      3 'DMLINE'  'X' '' '',
                                      4 'REQ_FACTOR'  'X' '' '',
                                      5 'AUFNR'  'X' '' '',
                                      6 'POSNR'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIND_LC_FOR_ROUTING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_DEV_GONG_MATNR
*&      --> <LS_CAL_LC>_MATNR
*&      <-- <LS_CAL_LC>_QLENGTH
*&      <-- <LS_CAL_LC>_CLENGTH
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM FIND_LC_FOR_ROUTING  USING    PV_DEV_MATNR TYPE MATNR
                                   PV_CURRENT_MATNR TYPE MATNR
                          CHANGING PV_QLENGTH TYPE ZGTPPT2330-QLENGTH
                                   PV_CLENGTH TYPE ZGTPPT2330-CLENGTH
                                   PV_CHK_ERR.

* 공정정보 조회
  SELECT  A~MATNR,
   C~IDNRK,
   C~/SAPMP/MET_LRCH,  " 길이 계산 방법
   C~/SAPMP/MAX_FERTL,  " 최대생산 길이
   C~/SAPMP/FIX_AS_J,       " 각길이
   C~/SAPMP/FIX_AS_E,       " 첫번째 길이
   C~/SAPMP/FIX_AS_L,        "최종길이
   C~/SAPMP/RUND_FAKT      " 반올림 값
     FROM MAST AS A
     INNER JOIN STKO AS B
                          ON B~STLNR = A~STLNR
                         AND B~STLAL = A~STLAL
     INNER JOIN STPO AS C
                          ON C~STLNR = B~STLNR
                         AND C~STLTY = B~STLTY
    WHERE A~MATNR = @PV_DEV_MATNR
        AND A~WERKS  = @P_WERKS
        AND A~STLAN = '1'
        AND A~STLAL  = '01'
        AND B~STLTY  = 'M'
        AND B~LKENZ NE 'X'
        AND C~LKENZ NE 'X'
        AND C~IDNRK      = @PV_CURRENT_MATNR
     INTO TABLE @DATA(LT_CALCULTAB).

  IF SY-SUBRC NE 0.
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  SELECT SINGLE A~MATNR, A~MTART, C~/SAPMP/FIX_AS_J
    FROM MARA AS A
    INNER JOIN MAPL AS B
                         ON B~MATNR = A~MATNR
    INNER JOIN PLPO AS C
                         ON C~PLNNR = B~PLNNR
   WHERE A~MATNR = @PV_CURRENT_MATNR
      AND B~WERKS = @P_WERKS
      AND B~PLNTY = 'N'
      AND C~PLNTY = 'N'
      AND C~PLNKN = '00000001'
      INTO @DATA(LS_INFOR_MATNR).

  PV_QLENGTH = LS_INFOR_MATNR-/SAPMP/FIX_AS_J.

  READ TABLE LT_CALCULTAB INTO DATA(LS_CALCULTAB) INDEX 1.
  PV_CLENGTH = LS_CALCULTAB-/SAPMP/FIX_AS_J.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_UNPEGGING_FORCE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_UNPEGGING_FORCE .

  DATA : LT_MOSU LIKE GT_MAIN_DISP.
  DATA : LT_2330 TYPE TABLE OF ZGTPPT2330.
  DATA : LT_2340 TYPE TABLE OF ZGTPPT2340.
  DATA : LS_2330 TYPE ZGTPPT2330.
  DATA : LS_2340 TYPE ZGTPPT2340.
  DATA : BEGIN OF LS_CHK_MAX_ZWKREQ,
           ZWKREQ   TYPE ZGTPPT2330-ZWKREQ,
           SEQNO(6) TYPE C,
         END OF LS_CHK_MAX_ZWKREQ.
  DATA : LT_CHK_MAX_ZWKREQ LIKE TABLE OF LS_CHK_MAX_ZWKREQ.
  DATA : LV_AUFNR TYPE AUFNR.
  DATA : LV_CHK_ERR.
  DATA : LS_ORDSYVAL TYPE ZGTCVORDSYVAL.
  DATA : LV_OBJNR TYPE JEST-OBJNR.
  DATA : LV_USER_LINE TYPE BSVX-STTXT.
  DATA : LT_GRPNR TYPE RANGE OF ZGTPPT2000-GRPNR.

  DATA : LV_MAX_SEQ(6) TYPE N.

  __ALPHA_OUT GS_DEL_PEGGING-AUFNR.
  READ TABLE GT_MAIN_DISP INTO DATA(LS_MAIN_CHK) WITH KEY AUFNR = GS_DEL_PEGGING-AUFNR.
  IF SY-SUBRC EQ 0.
    APPEND LS_MAIN_CHK TO LT_MOSU.
  ENDIF.

  IF LT_MOSU IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH 'Pegging 강제 삭제 할 수 있는 주문이 없습니다.'(e27).
    RETURN.
  ENDIF.

* 페깅처리된 오더는 삭제대상이 아니므로 삭제 대상에서 제외
  LOOP AT LT_MOSU INTO DATA(LS_MOSU).
    LV_AUFNR = LS_MOSU-AUFNR.
    __ALPHA_INPUT LV_AUFNR.
* 작업지시 확인
    CLEAR LS_ORDSYVAL.
    SELECT SINGLE * FROM ZGTCVORDSYVAL
      INTO LS_ORDSYVAL
     WHERE AUFNR = LV_AUFNR.
    IF SY-SUBRC NE 0.
*    오더정보 미조회시 오더 정보 확인후 진행가능
      MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더' LS_MOSU-AUFNR '정보를 확인 할 수 없습니다.'(e24).
      RETURN.
    ENDIF.

    READ TABLE GT_2340 INTO LS_2340 WITH KEY ORDNR = LV_AUFNR
                                                                POSNR = LS_MOSU-POSNR
                                                                ORDTY = 'PRD'.
    IF SY-SUBRC EQ 0.
      APPEND LS_2340 TO LT_2340.
      READ TABLE GT_2330 INTO LS_2330 WITH KEY ZWKREQ = LS_2340-ZWKREQ.
      IF SY-SUBRC EQ 0.
        APPEND LS_2330 TO LT_2330.
      ELSE.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더' LS_MOSU-AUFNR '정보를 확인 할 수 없습니다.'(e24).
        RETURN.
      ENDIF.
    ELSE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더' LS_MOSU-AUFNR '정보를 확인 할 수 없습니다.'(e24).
      RETURN.
    ENDIF.

  ENDLOOP.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    'Pegging 강제 삭제되면 복구할 수 없습니다. 계속 진행 하시겠습니까?'
    '작업확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  PERFORM SET_PROGRESS_INDICATOR USING '10' 'Pegging 강제 삭제중...'.

  IF LT_2340 IS NOT INITIAL.
    DELETE ZGTPPT2340 FROM TABLE LT_2340.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더 작업요청 저장중 오류발생하였습니다.'(e06).
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_2330 IS NOT INITIAL.
    DELETE ZGTPPT2330 FROM TABLE LT_2330.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더 작업요청 저장중 오류발생하였습니다.'(e06).
      RETURN.
    ENDIF.
  ENDIF.

  PERFORM SET_PROGRESS_INDICATOR USING '50' 'Pegging 강제 삭제 완료'.

  PERFORM SET_HALF_MATNR USING '1' CHANGING LV_CHK_ERR.
  IF LV_CHK_ERR = ABAP_TRUE.
    MODIFY ZGTPPT2330 FROM TABLE LT_2330.
    MODIFY ZGTPPT2340 FROM TABLE LT_2340.
    COMMIT WORK AND WAIT.
    RETURN.
  ENDIF.

  IF LT_GRPNR[] IS NOT INITIAL.
    SORT LT_GRPNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_GRPNR COMPARING LOW.
    UPDATE ZGTPPT2000 SET RQMON = '000000'
      WHERE GRPNR IN LT_GRPNR
        AND ZSTATUS <> 'D'.
    COMMIT WORK AND WAIT.
  ENDIF.

  PERFORM SET_PROGRESS_INDICATOR USING '100' '완료'.

  PERFORM GET_PROC.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  PERFORM REFRESH_GRID USING GO_GRID_0101.


  MESSAGE S006 WITH 'Pegging 강제 삭제 완료 되었습니다.'(e26).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_MENU_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM HANDLE_MENU_BUTTON  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                  P_OBJECT TYPE REF TO CL_CTMENU
                                  P_UCOMM TYPE SY-UCOMM.

  DEFINE __ADD_MANU.
    P_OBJECT->ADD_FUNCTION(
      FCODE             = conv #( &1 )                 " Function code
      TEXT              = conv #( &2 ) ).                 " Function text

  END-OF-DEFINITION.



  REFRESH GT_DEL_PEGGING.

  LOOP AT GT_MAIN_DISP INTO GS_MAIN_DISP WHERE CHK_PEGGING = ABAP_TRUE.
    CLEAR   GS_DEL_PEGGING.
    GS_DEL_PEGGING-AUFNR = GS_MAIN_DISP-AUFNR.
    __ALPHA_INPUT GS_DEL_PEGGING-AUFNR.
    COLLECT GS_DEL_PEGGING INTO GT_DEL_PEGGING.
  ENDLOOP.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      CASE P_UCOMM.
        WHEN 'UNPEGGING_FORCE'.
          LOOP AT GT_DEL_PEGGING INTO GS_DEL_PEGGING.
            __ADD_MANU : GS_DEL_PEGGING-AUFNR GS_DEL_PEGGING-AUFNR.
          ENDLOOP.
      ENDCASE.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_POPUP_ORDERS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_101
*&---------------------------------------------------------------------*
FORM DISP_POPUP_ORDERS  USING    PS_MAIN_101 LIKE GS_MAIN_DISP_101.

  DATA : LS_2330 TYPE ZGTPPT2330.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : LT_ORDSYVAL TYPE TABLE OF ZGTCVORDSYVAL.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_OBJNR TYPE JEST-OBJNR.
  DATA : LV_USER_LINE TYPE BSVX-STTXT.

  CLEAR LS_2330.
  READ TABLE GT_2330 INTO LS_2330 WITH KEY ZWKREQ = PS_MAIN_101-ZWKREQ.

  IF SY-SUBRC EQ 0.
    LT_AUFNR = VALUE #( FOR LW_2340 IN GT_2340 WHERE ( ZWKREQ = LS_2330-ZWKREQ
                                                                     AND  ORDTY = 'PRD' )
                                ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2340-ORDNR ) ).

    SELECT DISTINCT * FROM ZGTCVORDSYVAL
      INTO TABLE LT_ORDSYVAL
      WHERE WERKS = P_WERKS
        AND AUFNR IN LT_AUFNR.
  ELSE.
    RETURN.
  ENDIF.

  IF LT_ORDSYVAL IS INITIAL.
    RETURN.
  ENDIF.

  REFRESH GT_POP_ORDERS.
  SORT LT_ORDSYVAL BY GSTRP GSUZP.

  CLEAR LV_SEQNO.
  LOOP AT LT_ORDSYVAL INTO DATA(LS_MAIN).
    CLEAR GS_POP_ORDERS.

    ADD 1 TO LV_SEQNO.
    GS_POP_ORDERS-SEQNO = LV_SEQNO.
*생산오더
    GS_POP_ORDERS-AUFNR = LS_MAIN-AUFNR.
    __ALPHA_OUT : GS_POP_ORDERS-AUFNR.
*오더품목
    GS_POP_ORDERS-POSNR = LS_MAIN-POSNR.
*오더상태
    IF LS_MAIN-DLV = ABAP_TRUE.
      GS_POP_ORDERS-ORD_STAT = '작업완료'.
    ELSEIF LS_MAIN-PDLV = ABAP_TRUE.
      GS_POP_ORDERS-ORD_STAT = '작업중'.
    ELSEIF LS_MAIN-REL = ABAP_TRUE.
      GS_POP_ORDERS-ORD_STAT = '릴리즈'.
    ELSE.
      GS_POP_ORDERS-ORD_STAT = '생성'.
    ENDIF.

* pay off상태 확인
    CASE GS_POP_ORDERS-ORD_STAT.
      WHEN '릴리즈' OR '생성'.
        LV_OBJNR = 'OR' && LS_MAIN-AUFNR.
        CALL FUNCTION 'STATUS_TEXT_EDIT'
          EXPORTING
            FLG_USER_STAT    = 'X'
            OBJNR            = LV_OBJNR
            ONLY_ACTIVE      = 'X'
            SPRAS            = SY-LANGU
            BYPASS_BUFFER    = 'X'
          IMPORTING
            USER_LINE        = LV_USER_LINE
          EXCEPTIONS
            OBJECT_NOT_FOUND = 1
            OTHERS           = 2.

        FIND ALL OCCURRENCES OF 'PAYO' IN LV_USER_LINE MATCH COUNT FINAL(LV_LINE).
        IF LV_LINE > 0. " Patoff 상태일지 작업중으로 변경
          GS_POP_ORDERS-ORD_STAT = '작업중'.
        ENDIF.
    ENDCASE.

*자재코드
    GS_POP_ORDERS-MATNR = LS_MAIN-MATNR.
*색상
    READ TABLE GT_CVMVAL INTO DATA(LS_CVMVAL) WITH KEY MATNR = LS_MAIN-MATNR.
    IF SY-SUBRC EQ 0.
      IF LS_CVMVAL-COLORBASE IS NOT INITIAL.
        GS_POP_ORDERS-COLOR = LS_CVMVAL-COLORBASE.
      ENDIF.
    ENDIF.

*자재내역
    GS_POP_ORDERS-MAKTX = LS_MAIN-MAKTX.

*시작일(계획)
    GS_POP_ORDERS-GSTRP = LS_MAIN-GSTRP.
    GS_POP_ORDERS-GSUZP = LS_MAIN-GSUZP.
*종료일(계획)
    GS_POP_ORDERS-GLTRP = LS_MAIN-GLTRP.
    GS_POP_ORDERS-GLUZP = LS_MAIN-GLUZP.
*우선순위
    GS_POP_ORDERS-ZZPRIORITY = LS_MAIN-ZZPRIORITY.
* 표준조장
    GS_POP_ORDERS-INLENGTH = LS_MAIN-MILLCALENGTH.
* 작업지시B/N
    GS_POP_ORDERS-INFACTOR = LS_MAIN-MILLCAFACTOR.
*지시수량
    GS_POP_ORDERS-PSMNG = LS_MAIN-PSAMG + LS_MAIN-PSMNG.
*단위
    GS_POP_ORDERS-MEINS = LS_MAIN-GMEIN.
    GS_POP_ORDERS-MENGE01 = LS_MAIN-WEMNG.

    APPEND GS_POP_ORDERS TO GT_POP_ORDERS.

  ENDLOOP.

  CALL SCREEN '0500' STARTING AT 5 5 ENDING AT 140 10.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0500 .

  CREATE OBJECT GO_CONTAIN_0500
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

* 그리드 적용
  CREATE OBJECT GO_GRID_0500
    EXPORTING
      I_PARENT      = GO_CONTAIN_0500
      I_APPL_EVENTS = ABAP_TRUE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0500 .

  CLEAR GS_LAYOUT_0500.
  GS_LAYOUT_0500-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0500-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0500-NO_ROWMARK = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0500 .

  REFRESH GT_EXCLUDE_0500.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0500
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
*& Form SET_FIELDCAT_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0500 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2300TOP'
      I_INTERNAL_TABNAME     = 'GS_POP_ORDERS'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0500.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0500[]
    TABLES
      IT_DATA         = GT_POP_ORDERS
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0500 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'SEQNO'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0500 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'SEQNO'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0500 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'ORD_STAT'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0500 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ORD_STAT'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더상태'(f50).
    <LS_FCAT>-COL_POS = 4.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-KEY = ABAP_TRUE.
    <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
  ENDIF.

  LOOP AT GT_FIELDCAT_0500 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'SEQNO' OR 'GSUZP' OR 'GLUZP'.
        <LS_FCAT>-NO_OUT = 'X'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더'(f51).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더품목'(f52).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ORD_STAT'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재코드'(f53).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'COLOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상'(f04).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재내역'(f54).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'GSTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시작일(계획)'(f55).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GLTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '종료일(계획)'(f56).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZZPRIORITY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '우선순위'(f57).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(f58).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장'(f59).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업지시 B/N'(f39).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'PSMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업지시량'(f38).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고량'(f60).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0500 .

  REFRESH GT_SORT_0500.

  PERFORM SET_SORT_TAB TABLES GT_SORT_0500
                            USING : 1 'SEQNO' '' 'X' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0500_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0500_DISPLAY .

  CALL METHOD GO_GRID_0500->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0500
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0500
    CHANGING
      IT_OUTTAB            = GT_POP_ORDERS
      IT_SORT              = GT_SORT_0500
      IT_FIELDCATALOG      = GT_FIELDCAT_0500.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_pre_gong
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_2340
*&      <-- LS_PRODUCT_MATNR_RE
*&---------------------------------------------------------------------*
FORM CHK_PRE_GONG  USING    PS_2340 TYPE ZGTPPT2340
                   CHANGING PV_MATNR TYPE MATNR.

  READ TABLE GT_2010_FUL INTO DATA(LS_CHK) WITH KEY GONG_CD = PS_2340-GONG_CD
                                                                      ORDNR = PS_2340-ORDNR
                                                                      POSNR = PS_2340-POSNR.
  IF SY-SUBRC EQ 0.

    LOOP AT GT_2010_FUL INTO DATA(LS_2010) WHERE GRPNR = LS_CHK-GRPNR
                                                          AND GONG_CD = LS_CHK-GONG_CD
                                                          AND GONG_SEQ < LS_CHK-GONG_SEQ.
      PV_MATNR = LS_2010-MATNR.
      EXIT.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CAL_PRE_BOM_MENGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_PRE_PRODUCT
*&---------------------------------------------------------------------*
FORM CAL_PRE_BOM_MENGE  USING   PS_PRODUCT LIKE GS_SET_MATNR.

  DATA : LT_STB TYPE TABLE OF STPOX.
  DATA : LT_CSCMAT TYPE TABLE OF CSCMAT.
  DATA : LV_EMENG TYPE STKO-BMENG.
  DATA : LV_EMENG2 TYPE STKO-BMENG.
  DATA : LS_PRODUCT LIKE GS_SET_MATNR. " 완제품 수량 정보 테이블
  DATA : LT_PRODUCT LIKE TABLE OF GS_SET_MATNR. " 완제품 수량 정보 테이블
  DATA : LT_BASE_GONG_SEQ LIKE GT_BASE_GONG_SEQ.
  DATA : LS_BASE_GONG_SEQ LIKE GS_BASE_GONG_SEQ.
  DATA : LS_MATNR LIKE GS_MATNR.
  DATA : LT_MATNR LIKE GT_MATNR.
  DATA : LV_GONG_SEQ TYPE ZGTPPT2340-GONG_SEQ.
  DATA : LV_CHK_GONG_SEQ TYPE ZGTPPT2340-GONG_SEQ.
  DATA : LT_EXIST_MATNR TYPE RANGE OF MATNR.
  DATA : LV_MNGKO TYPE STPOX-MNGKO.

  REFRESH GT_PRE_SET_MATNR.

  LV_EMENG = PS_PRODUCT-GAMNG.

  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      CAPID                 = 'PP01'
      DATUV                 = SY-DATUM
      EMENG                 = LV_EMENG
      MTNRV                 = PS_PRODUCT-MATNR " 자재
      WERKS                 = P_WERKS " 플랜트
      MEHRS                 = ABAP_TRUE " 멀티체크
      MMORY                 = '0'
    TABLES
      STB                   = LT_STB
      MATCAT                = LT_CSCMAT
    EXCEPTIONS
      ALT_NOT_FOUND         = 1
      CALL_INVALID          = 2
      MATERIAL_NOT_FOUND    = 3
      MISSING_AUTHORIZATION = 4
      NO_BOM_FOUND          = 5
      NO_PLANT_DATA         = 6
      NO_SUITABLE_BOM_FOUND = 7
      CONVERSION_ERROR      = 8
      OTHERS                = 9.

  IF LT_CSCMAT[] IS NOT INITIAL.
    SELECT A~INDEX AS SEQNO, A~MATNR, B~MTART
      FROM @LT_CSCMAT AS A
      INNER JOIN MARA AS B
                            ON B~MATNR = A~MATNR
      INNER JOIN MARC AS C
                            ON C~MATNR = A~MATNR
                          AND C~WERKS = @P_WERKS
     WHERE B~MTART   IN ( 'MCFE', 'MCHF' )  " 완제품 반제품만 공정대상
       AND B~MATKL LIKE 'H%'
       AND ( A~INDEX EQ 1
        OR ( A~INDEX NE 1
       AND  A~VERID IS NOT INITIAL ) )
      INTO TABLE @DATA(LT_SEQ_ROUTING).
  ENDIF.

  SELECT * FROM ZGTCVMSTVAL
    FOR ALL ENTRIES IN @LT_STB
   WHERE WERKS = @P_WERKS
     AND MATNR = @LT_STB-IDNRK
     AND MTREF = 'HALB'
    INTO TABLE @DATA(LT_MATNR_DETAIL).

* 외주공정여부 확인하여 외주공정이 이어져 있는 부분까지는 제외
  SORT LT_SEQ_ROUTING BY SEQNO.
  LOOP AT LT_SEQ_ROUTING INTO DATA(LS_SEQ_ROUTING).
    CLEAR LS_BASE_GONG_SEQ.
    READ TABLE LT_MATNR_DETAIL INTO DATA(LS_MATNR_DETAIL) WITH KEY MATNR = LS_SEQ_ROUTING-MATNR.
    IF SY-SUBRC EQ 0.
      LS_BASE_GONG_SEQ-GONG_CD = LS_MATNR_DETAIL-PDCAPROCCODE.
      LS_BASE_GONG_SEQ-GONG_NM = LS_MATNR_DETAIL-PDCAPROCNAME.

      IF LS_MATNR_DETAIL-PDCAPROCCODE = 'BWD'.
        CONTINUE.
      ENDIF.

      IF LS_MATNR_DETAIL-PDCAPROCCODE IS INITIAL.
        CONTINUE.
      ENDIF.

      IF LS_MATNR_DETAIL-BESKZ = 'F' AND LS_MATNR_DETAIL-SOBSL = ''. " 외주구매는 제외
        CONTINUE.
      ENDIF.

      READ TABLE LT_BASE_GONG_SEQ ASSIGNING FIELD-SYMBOL(<LS_INPUT>) WITH KEY GONG_CD = LS_BASE_GONG_SEQ-GONG_CD.
      IF SY-SUBRC EQ 0.
        READ TABLE <LS_INPUT>-T_MATNR ASSIGNING FIELD-SYMBOL(<LS_MATNR>) WITH KEY MATNR = LS_SEQ_ROUTING-MATNR.
        IF SY-SUBRC EQ 0.
          ADD 1 TO <LS_MATNR>-SEQNO.
        ELSE.
          APPEND INITIAL LINE TO <LS_INPUT>-T_MATNR ASSIGNING <LS_MATNR>.
          <LS_MATNR>-MATNR = LS_MATNR_DETAIL-MATNR.
          <LS_MATNR>-BESKZ = LS_MATNR_DETAIL-BESKZ.
          <LS_MATNR>-SOBSL = LS_MATNR_DETAIL-SOBSL.
          <LS_MATNR>-SEQNO = 1.
        ENDIF.
      ELSE.
        APPEND INITIAL LINE TO LT_BASE_GONG_SEQ ASSIGNING <LS_INPUT>.
        CLEAR LS_MATNR.
        LS_MATNR-MATNR = LS_MATNR_DETAIL-MATNR.
        LS_MATNR-BESKZ = LS_MATNR_DETAIL-BESKZ.
        LS_MATNR-SOBSL = LS_MATNR_DETAIL-SOBSL.
        LS_MATNR-SEQNO = 1.
        APPEND LS_MATNR TO LS_BASE_GONG_SEQ-T_MATNR.
        MOVE-CORRESPONDING LS_BASE_GONG_SEQ TO <LS_INPUT>.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LV_GONG_SEQ = '01'.

  LOOP AT LT_BASE_GONG_SEQ ASSIGNING <LS_INPUT>.
    IF PS_PRODUCT-GONG_CD = <LS_INPUT>-GONG_CD.
      <LS_INPUT>-GONG_SEQ = '01'.
    ELSE.
      ADD 1 TO LV_GONG_SEQ.
      <LS_INPUT>-GONG_SEQ = LV_GONG_SEQ.
    ENDIF.
  ENDLOOP.

  SORT LT_BASE_GONG_SEQ BY GONG_SEQ.

  LOOP AT LT_BASE_GONG_SEQ INTO LS_BASE_GONG_SEQ.
    LOOP AT LS_BASE_GONG_SEQ-T_MATNR INTO LS_MATNR.
* 외주 임가공 대상 인지 확인하여 사급 반제품수량 제외로직
      IF ( LS_MATNR-BESKZ = 'F' AND LS_MATNR-SOBSL = '30' ) OR
        ( LS_MATNR-BESKZ = 'X' AND LS_MATNR-SOBSL = '30' ).
        IF LT_EXIST_MATNR[] IS NOT INITIAL.
          IF LS_MATNR IN LT_EXIST_MATNR. "
            CONTINUE.
          ENDIF.
        ENDIF.

        REFRESH LT_PRODUCT.
        LOOP AT  LT_STB INTO DATA(LS_STB) WHERE IDNRK = LS_MATNR-MATNR.
          ADD LS_STB-MNGLG TO LV_MNGKO.
        ENDLOOP.
        PERFORM GET_EXIST_IMGAGONG_MENGE TABLES LT_PRODUCT
                                                          USING LS_MATNR-MATNR LS_STB-MNGLG.

        IF LT_PRODUCT IS NOT INITIAL.
          LOOP AT LT_PRODUCT INTO DATA(LS_CHK_MNGKO).
            READ TABLE LT_STB ASSIGNING FIELD-SYMBOL(<LS_STB_MNGKO>) WITH KEY IDNRK = LS_CHK_MNGKO-MATNR.
            IF SY-SUBRC EQ 0.
              <LS_STB_MNGKO>-MNGLG = <LS_STB_MNGKO>-MNGLG - LS_CHK_MNGKO-GAMNG.
            ENDIF.

            APPEND INITIAL LINE TO LT_EXIST_MATNR ASSIGNING FIELD-SYMBOL(<LS_EXIST_MATNR>).
            <LS_EXIST_MATNR>-SIGN = 'I'.
            <LS_EXIST_MATNR>-OPTION = 'EQ'.
            <LS_EXIST_MATNR>-LOW = LS_CHK_MNGKO-MATNR.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  LOOP AT LT_BASE_GONG_SEQ INTO LS_BASE_GONG_SEQ.
    LOOP AT LS_BASE_GONG_SEQ-T_MATNR INTO LS_MATNR.
      CLEAR LS_PRODUCT.
      LS_PRODUCT-GONG_CD = LS_BASE_GONG_SEQ-GONG_CD.
      LS_PRODUCT-GONG_NM = LS_BASE_GONG_SEQ-GONG_NM.
      LS_PRODUCT-GONG_SEQ = LS_BASE_GONG_SEQ-GONG_SEQ.
      LS_PRODUCT-MATNR = LS_MATNR-MATNR.
      LOOP AT  LT_STB INTO LS_STB WHERE IDNRK = LS_MATNR-MATNR.
        ADD LS_STB-MNGLG TO LS_PRODUCT-GAMNG.
      ENDLOOP.
      COLLECT LS_PRODUCT INTO GT_PRE_SET_MATNR.
    ENDLOOP.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RESB_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_HEADER_200_MATNR
*&      --> LV_PSMNG
*&      --> LS_FCAT_REPTEXT
*&---------------------------------------------------------------------*
FORM SET_RESB_PO  USING    PV_MATNR TYPE MATNR
                                  PV_PSMNG TYPE CO_PSMNG
                                  PV_REPTEXT TYPE REPTEXT.

  DATA : LT_STB TYPE TABLE OF STPOX.
  DATA : LT_CSCMAT TYPE TABLE OF CSCMAT.
  DATA : LV_VERID TYPE MKAL-VERID.
  DATA : LT_IMGAGONG_RESB LIKE TABLE OF GS_IMGAGONG_RESB.
  DATA : BEGIN OF LS_HALF_MATNR,
           MATNR TYPE MATNR,
           EMENG TYPE STKO-BMENG,
         END OF LS_HALF_MATNR.
  DATA : LT_HALF_MATNR LIKE TABLE OF LS_HALF_MATNR.
  DATA : LT_HALF_MATNR2 LIKE TABLE OF LS_HALF_MATNR.
  DATA : LS_HALF_MATNR2 LIKE LS_HALF_MATNR.
  DATA : LV_CHK_LAST.

  REFRESH GT_IMGAGONG_RESB.

  CLEAR LS_HALF_MATNR.
  LS_HALF_MATNR-MATNR = PV_MATNR.
  LS_HALF_MATNR-EMENG = PV_PSMNG.
  APPEND LS_HALF_MATNR TO LT_HALF_MATNR.

* 임가공 구성 부품 구성
* 1) 최초 공정부터 단일봄 수량 조회하여 반제품 제외 원재료로 구성
* 2) 최종 반제품은 구성테이블에 포함
  DO.
    LOOP AT LT_HALF_MATNR INTO LS_HALF_MATNR.

* 봄 구성시 생산버전 조회하여  봄 조회
* 공정정보 조회
*1) 생산버전 SC10 부터 조회후 없으면 1000번 조회
      SELECT DISTINCT A~MATNR,
                              B~VERID
        FROM MAST AS A
        INNER JOIN MKAL AS B ON B~WERKS = A~WERKS
                                  AND B~MATNR = A~MATNR
                                  AND B~STLAN = A~STLAN
                                  AND B~STLAL = A~STLAL
        INNER JOIN STKO AS C
                           ON C~STLNR = A~STLNR
                          AND C~STLAL = A~STLAL
       WHERE A~MATNR = @LS_HALF_MATNR-MATNR
         AND A~WERKS  = @P_WERKS
         AND B~VERID IN ( '1000', 'SC10' )
         AND B~BDATU >= @SY-DATUM
         AND B~ADATU <= @SY-DATUM
         AND C~STLTY  = 'M'
         AND C~LKENZ NE 'X'
        INTO TABLE @DATA(LT_VERID).

      IF SY-SUBRC EQ 0.
        CLEAR LV_VERID.
        READ TABLE LT_VERID INTO DATA(LS_VERID) WITH KEY VERID = 'SC10'.
        IF SY-SUBRC EQ 0.
          LV_VERID = 'SC10'.
        ELSE.
          LV_VERID = '1000'.
        ENDIF.
      ELSE.
        CONTINUE.
      ENDIF.

      CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
        EXPORTING
          CAPID                 = 'PP01'
          DATUV                 = SY-DATUM
          EMENG                 = LS_HALF_MATNR-EMENG
          MTNRV                 = LS_HALF_MATNR-MATNR " 자재
          WERKS                 = P_WERKS " 플랜트
          VERID                 = LV_VERID
          MMORY                 = '0'
        TABLES
          STB                   = LT_STB
          MATCAT                = LT_CSCMAT
        EXCEPTIONS
          ALT_NOT_FOUND         = 1
          CALL_INVALID          = 2
          MATERIAL_NOT_FOUND    = 3
          MISSING_AUTHORIZATION = 4
          NO_BOM_FOUND          = 5
          NO_PLANT_DATA         = 6
          NO_SUITABLE_BOM_FOUND = 7
          CONVERSION_ERROR      = 8
          OTHERS                = 9.

      SELECT A~INDEX AS SEQNO, A~MATNR, B~MTART
        FROM @LT_CSCMAT AS A
        INNER JOIN MARA AS B
                              ON B~MATNR = A~MATNR
        INNER JOIN MARC AS C
                              ON C~MATNR = A~MATNR
                            AND C~WERKS = @P_WERKS
       WHERE B~MTART   IN ( 'MCFE', 'MCHF' )  " 완제품 반제품만 공정대상
         AND B~MATKL LIKE 'H%'
         AND ( A~INDEX EQ 1
          OR ( A~INDEX NE 1
         AND  A~VERID IS NOT INITIAL ) )
        INTO TABLE @DATA(LT_SEQ_ROUTING).

      IF LT_SEQ_ROUTING[] IS NOT INITIAL.
        SELECT * FROM ZGTCVMSTVAL
           FOR ALL ENTRIES IN @LT_SEQ_ROUTING
          WHERE WERKS = @P_WERKS
          AND MATNR = @LT_SEQ_ROUTING-MATNR
          INTO TABLE @DATA(LT_MATNR_DETAIL).

        IF LV_CHK_LAST IS INITIAL.
          "최초 공정과 임가공 선택된 자재의 공정이 동일할 경우 현재 정보만 가지고 정료
          READ TABLE LT_MATNR_DETAIL INTO DATA(LS_MATNR_DETAIL) WITH KEY MATNR = LS_HALF_MATNR-MATNR
                                                                                                   PDCAPROCNAME = PV_REPTEXT.
          IF SY-SUBRC EQ 0.
            LV_CHK_LAST = ABAP_TRUE.
          ENDIF.

        ENDIF.
      ENDIF.

      DELETE LT_STB WHERE IDNRK = LS_HALF_MATNR-MATNR.
      DELETE LT_MATNR_DETAIL WHERE MATNR = LS_HALF_MATNR-MATNR.

      LOOP AT LT_STB INTO DATA(LS_STB).
        READ TABLE LT_MATNR_DETAIL INTO LS_MATNR_DETAIL WITH KEY MATNR = LS_STB-IDNRK.
        IF SY-SUBRC EQ 0.
          CLEAR LS_HALF_MATNR2.
          LS_HALF_MATNR2-MATNR = LS_STB-IDNRK.
          LS_HALF_MATNR2-EMENG = LS_STB-MNGLG.
          COLLECT LS_HALF_MATNR2 INTO LT_HALF_MATNR2.
        ELSE.
          IF NOT ( LS_STB-BEIKZ = 'V' OR LS_STB-BEIKZ =  'X' ).
            CLEAR GS_IMGAGONG_RESB.
            GS_IMGAGONG_RESB-MATNR = LS_STB-IDNRK.
            GS_IMGAGONG_RESB-WERKS = P_WERKS.
            GS_IMGAGONG_RESB-ERFME = LS_STB-MMEIN.
            GS_IMGAGONG_RESB-ERFMG = LS_STB-MNGLG.
            COLLECT GS_IMGAGONG_RESB INTO GT_IMGAGONG_RESB.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    IF LV_CHK_LAST = ABAP_TRUE.
      IF LT_HALF_MATNR2 IS NOT INITIAL.
        LOOP AT LT_HALF_MATNR2 INTO LS_HALF_MATNR2.
          CLEAR GS_IMGAGONG_RESB.
          GS_IMGAGONG_RESB-MATNR = LS_HALF_MATNR2-MATNR.
          GS_IMGAGONG_RESB-WERKS = P_WERKS.
          READ TABLE LT_STB INTO LS_STB WITH KEY IDNRK = LS_HALF_MATNR2-MATNR.
          IF SY-SUBRC EQ 0.
            GS_IMGAGONG_RESB-ERFME = LS_STB-MMEIN.
          ELSE.
            GS_IMGAGONG_RESB-ERFME = 'M'.
          ENDIF.
          GS_IMGAGONG_RESB-ERFMG = LS_HALF_MATNR2-EMENG.
          COLLECT GS_IMGAGONG_RESB INTO GT_IMGAGONG_RESB.
        ENDLOOP.
      ENDIF.
      EXIT.
    ENDIF.

    REFRESH LT_HALF_MATNR.
    MOVE-CORRESPONDING LT_HALF_MATNR2 TO LT_HALF_MATNR.
    REFRESH LT_HALF_MATNR2.

  ENDDO.

  DATA : LV_PSMNG TYPE CO_PSMNG.

  LOOP AT GT_MAIN_201 INTO GS_MAIN_201.
    READ TABLE GT_IMGAGONG_RESB ASSIGNING FIELD-SYMBOL(<LS_CHANGE>) WITH KEY MATNR = GS_MAIN_201-MATNR.
    IF SY-SUBRC EQ 0.
      <LS_CHANGE>-ERFMG = GS_MAIN_201-INLENGTH * GS_MAIN_201-INFACTOR.
      IF <LS_CHANGE>-ERFMG <= 0.
        DELETE TABLE GT_IMGAGONG_RESB FROM <LS_CHANGE>.
      ENDIF.
    ENDIF.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4HELP_LGORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4HELP_LGORT .

  DATA : LV_VALUE TYPE HELP_INFO-FLDVALUE.
  DATA : LT_RETURN LIKE TABLE OF DDSHRETVAL.

  LV_VALUE = P_WERKS.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      TABNAME           = 'GS_HEADER_200'
      FIELDNAME         = 'LGFSB'
      SEARCHHELP        = 'H_T001L'
      SHLPPARAM         = 'LGORT'
      DYNPPROG          = 'ZGTPPR2300'
      DYNPNR            = SY-DYNNR
*     VALUE             = 'P_WERKS'
*     MULTIPLE_CHOICE   = ' '
*     DISPLAY           = ' '
*     SUPPRESS_RECORDLIST       = ' '
      CALLBACK_PROGRAM  = 'ZGTPPR2300'
      CALLBACK_FORM     = 'F4_LGORT_EDITION'
*     CALLBACK_METHOD   =
*     SELECTION_SCREEN  = ' '
*   IMPORTING
*     USER_RESET        =
    TABLES
      RETURN_TAB        = LT_RETURN
    EXCEPTIONS
      FIELD_NOT_FOUND   = 1
      NO_HELP_FOR_FIELD = 2
      INCONSISTENT_HELP = 3
      NO_VALUES_FOUND   = 4
      OTHERS            = 5.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  IF SY-SUBRC EQ 0.
    READ TABLE LT_RETURN INTO DATA(LS_RETURN) INDEX 1.
    GS_HEADER_200-LGFSB = LS_RETURN-FIELDVAL.
  ENDIF.

ENDFORM.
FORM F4_LGORT_EDITION TABLES RECORD_TAB
                     CHANGING SHLP_TOP TYPE SHLP_DESCR
                       CALLCONTROL TYPE DDSHF4CTRL.

  DATA : LS_SELCRIT TYPE DDSHSELOPT.

* 입력값에 플랜트 세팅
  LS_SELCRIT-SHLPFIELD = 'WERKS'.
  LS_SELCRIT-SIGN = 'I'.
  LS_SELCRIT-OPTION = 'EQ'.
  LS_SELCRIT-LOW = P_WERKS.
  APPEND LS_SELCRIT TO SHLP_TOP-SELOPT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_INIT .


*  조장 반제품과 반제품 작업 지시대상을 구분하기 위해 조장대상 반제품을 모아둔다.
  REFRESH GT_JOJANG_MATNR.

  SELECT * FROM ZGTCVMSTVAL
  INTO TABLE @DATA(LT_MSTVAL)
 WHERE WERKS = @P_WERKS
   AND SPG = @P_SPGCD
   AND MTREF = 'FERT'.

  SELECT 'I' AS SIGN, 'EQ' AS OPTION,  FLD_02 AS LOW
    FROM ZGTPPT1010
    INTO CORRESPONDING FIELDS OF TABLE @GT_EXCEPT_GONG_CD
   WHERE MODULE_KIND = 'PP'
      AND CODEGRP = '2020'
      AND FLD_01 = @P_WERKS.

  LOOP AT LT_MSTVAL INTO DATA(LS_MSTVAL).
    PERFORM GET_GONG_JOJANG USING LS_MSTVAL-MATNR.
  ENDLOOP.

  SORT GT_JOJANG_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM GT_JOJANG_MATNR COMPARING LOW.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_GONG_JOJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MSTVAL_MATNR
*&---------------------------------------------------------------------*
FORM GET_GONG_JOJANG  USING    PV_MATNR TYPE MATNR.

  DATA : LV_GONG_SEQ TYPE ZEDT1010-GONG_SEQ.

  SELECT DISTINCT B~GONG_SEQ, B~GONG_CD, B~AFT_GONG_SEQ, B~BESKZ, C~HALB_YN, E~MATNR_N
    FROM ZGTCVMSTVAL AS A
    INNER JOIN ZEDT1010 AS B ON B~SUL_NO = A~PDCADESIGNNO
                                      AND B~REV_SEQ = A~PDCADESIGNREVNO
    INNER JOIN ZEDT1050 AS E ON E~SUL_NO = B~SUL_NO
                                      AND E~REV_SEQ = B~REV_SEQ
                                      AND E~GONG_SEQ = B~GONG_SEQ
    LEFT JOIN ZEDT0140 AS C ON C~WERKS = A~WERKS
                                     AND C~GONG_CD = B~GONG_CD
    LEFT JOIN ZPPT0107 AS D ON D~WERKS = A~WERKS
                                     AND D~SPART = C~SPART
   WHERE A~MATNR = @PV_MATNR
     AND A~WERKS = @P_WERKS
    INTO TABLE @DATA(LT_GONG_MANAGE).

  SORT LT_GONG_MANAGE BY GONG_SEQ.
  READ TABLE LT_GONG_MANAGE INTO DATA(LS_CHK_GONG) INDEX 1.
  LV_GONG_SEQ = LS_CHK_GONG-GONG_SEQ.

  DO.
    READ TABLE LT_GONG_MANAGE INTO LS_CHK_GONG WITH KEY GONG_SEQ = LV_GONG_SEQ.
    IF SY-SUBRC EQ 0.
      IF LS_CHK_GONG-GONG_CD IN GT_EXCEPT_GONG_CD.
      ELSE.
        IF LS_CHK_GONG-AFT_GONG_SEQ = 0 OR
            ( LS_CHK_GONG-AFT_GONG_SEQ NE 0 AND
              LS_CHK_GONG-HALB_YN = ABAP_TRUE ).

          APPEND INITIAL LINE TO GT_JOJANG_MATNR ASSIGNING FIELD-SYMBOL(<LS_JOJANG_MATNR>).
          <LS_JOJANG_MATNR>-SIGN = 'I'.
          <LS_JOJANG_MATNR>-OPTION = 'EQ'.
          <LS_JOJANG_MATNR>-LOW = LS_CHK_GONG-MATNR_N.
        ENDIF.
      ENDIF.

      LV_GONG_SEQ = LS_CHK_GONG-AFT_GONG_SEQ.
      IF LV_GONG_SEQ = '00'.
        EXIT.
      ENDIF.

    ELSE.
      EXIT.
    ENDIF.
  ENDDO.

ENDFORM.
