*&---------------------------------------------------------------------*
*& Include          ZGTPPR2270F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CHK_VALIDATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_VALIDATION .

  IF P_CHK01 = ABAP_TRUE AND P_SPMON IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업요청월은 필수필드입니다.'(E01).
    LEAVE LIST-PROCESSING.
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

  REFRESH GT_MAIN_DISP.
  REFRESH GT_2330.
  CLEAR GV_CHK_DISP_ENDITEM.

  PERFORM GET_MAIN_DATA.

ENDFORM.
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

    CASE ABAP_TRUE.
      WHEN P_CHK01.
        IF SCREEN-GROUP1 = 'A1'.
          SCREEN-REQUIRED = 2.
          SCREEN-ACTIVE = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP1 = 'A2'.
          SCREEN-REQUIRED = 0.
          SCREEN-ACTIVE = 1.
          MODIFY SCREEN.
        ENDIF.

      WHEN P_CHK02.
        IF SCREEN-GROUP1 = 'A1'.
          SCREEN-REQUIRED = 0.
          SCREEN-ACTIVE = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP1 = 'A2'.

          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP1 = 'M2'.
          SCREEN-REQUIRED = 0.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.

    ENDCASE.

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
*& Form GET_MAIN_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_MAIN_DATA .

  PERFORM SET_INIT_DATA.

  CASE ABAP_TRUE.
    WHEN P_CHK01.
      REFRESH GT_MAIN_DISP.
      IF S_AUFNR[] IS INITIAL.
        PERFORM GET_MAINDATA_SO.
      ENDIF.

      IF NOT ( S_VBELN[] IS NOT INITIAL OR P_KUNNR IS NOT INITIAL OR S_YUSCD[] IS NOT INITIAL ).
        PERFORM GET_MAINDATA_PO.
      ENDIF.

      PERFORM SET_DISP.

      PERFORM GET_SET_REGISTERED_DATA.

    WHEN P_CHK02.
      REFRESH : GT_MAIN_DISP_500, GT_MAIN_DISP_501.
      PERFORM GET_MAINDATA_SIPAN.


  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_INIT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_INIT_DATA .

  GV_DISPO = P_SPGCD && '%'. "

* 조회조건의 자재와 자내내역을 조합하여 추출 자재범위 세팅
  SELECT 'I' AS SIGN, 'EQ' AS OPTION, A~MATNR AS LOW
    FROM MARC AS A
    INNER JOIN MAKT AS B  ON B~MATNR = A~MATNR
    INNER JOIN MARA AS C ON C~MATNR = A~MATNR
    INNER JOIN T134 AS D ON D~MTART = C~MTART
   WHERE A~MATNR IN @S_MATNR
      AND A~WERKS = @P_WERKS
      AND A~DISPO LIKE @GV_DISPO
      AND B~MAKTX IN @S_MAKTX
      AND D~MTREF = 'FERT'
    INTO CORRESPONDING FIELDS OF TABLE @GT_RANGE_MATNR.

  SORT GT_RANGE_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM GT_RANGE_MATNR COMPARING LOW.

  IF GT_RANGE_MATNR[] IS INITIAL.
    MESSAGE S001 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

* 완제품 자재정보
  SELECT * FROM ZGTCVMSTVAL
    INTO TABLE GT_CVMVAL
   WHERE WERKS = P_WERKS
      AND MATNR IN GT_RANGE_MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MAINDATA_SO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_MAINDATA_SO .

  DATA : LV_STATUS TYPE CHAR10.
  RANGES : LT_KUNNR FOR KNA1-KUNNR.
  DATA : BEGIN OF LS_AUFNR_STATUS,
           AUFNR  TYPE AUFK-AUFNR,
           STATUS TYPE CHAR10,
         END OF LS_AUFNR_STATUS.
  DATA : LT_AUFNR_STATUS LIKE TABLE OF LS_AUFNR_STATUS.
  DATA : LV_TABIX TYPE I.
  DATA : BEGIN OF LS_CHK_2010,
           ORDNR TYPE ZGTPPT2010-ORDNR,
           POSNR TYPE  ZGTPPT2010-POSNR,
         END OF LS_CHK_2010.
  DATA : LT_CHK_2010 LIKE TABLE OF LS_CHK_2010.
  DATA : LT_ABGRU TYPE RANGE OF VBAP-ABGRU.

  DATA : BEGIN OF LS_COLLECT_STOCKVAL,
           VBELN TYPE ZGTCV_STOCKVAL-VBELN,
           POSNR TYPE ZGTCV_STOCKVAL-POSNR,
           MATNR TYPE ZGTCV_STOCKVAL-MATNR,
           MENGE TYPE MENGE_D,
         END OF LS_COLLECT_STOCKVAL.

  DATA : LT_COLLECT_STOCKVAL LIKE TABLE OF LS_COLLECT_STOCKVAL.

  IF P_KUNNR IS NOT INITIAL.
    APPEND INITIAL LINE TO LT_KUNNR ASSIGNING FIELD-SYMBOL(<LS_KUNNR>).
    <LS_KUNNR>-SIGN = 'I'.
    <LS_KUNNR>-OPTION = 'EQ'.
    <LS_KUNNR>-LOW = P_KUNNR.
  ENDIF.

* 주문 거부사유가 없는 대상이 조건이나 거부사야 G2는 대상에 포함
  APPEND INITIAL LINE TO LT_ABGRU ASSIGNING FIELD-SYMBOL(<LS_ABGRU>).
  <LS_ABGRU>-SIGN = 'I'.
  <LS_ABGRU>-OPTION = 'EQ'.
*  APPEND INITIAL LINE TO LT_ABGRU ASSIGNING <LS_ABGRU>.
*  <LS_ABGRU>-SIGN = 'I'.
*  <LS_ABGRU>-OPTION = 'EQ'.
*  <LS_ABGRU>-LOW = 'G2'.
  UNASSIGN <LS_ABGRU>.

* 판매오더 기준
  SELECT DISTINCT K~VBELN, P~POSNR, K~KUNNR, P~MATNR, P~VRKME, P~MEINS,
             P~KWMENG, "판매단위 수량
             P~KLMENG,  " 기준단위 수량
             C~DISPO, KNA1~NAME1, A~EDATU, P~CUOBJ, K~VBTYP,
             K~VKORG, K~VKGRP, B~KDKG4
    FROM VBEP AS A
    INNER JOIN  VBAK AS K
                           ON K~VBELN   = A~VBELN
    INNER JOIN VBKD AS B
                           ON B~VBELN = A~VBELN
    INNER JOIN VBAP AS P
                           ON P~VBELN = A~VBELN
                          AND P~POSNR = A~POSNR
    INNER JOIN MARC AS C
                           ON C~MATNR = P~MATNR
                          AND C~WERKS = P~WERKS
    INNER JOIN KNA1 AS KNA1
                           ON KNA1~KUNNR = K~KUNNR
 WHERE A~EDATU IN @S_DATE
      AND A~VBELN IN @S_VBELN
      AND K~VBTYP IN ( 'B', 'C', 'I' )
      AND CONCAT( CONCAT( A~VBELN, A~POSNR ), A~ETENR ) IN
                            ( SELECT CONCAT( CONCAT( VBELN, POSNR ), MAX( ETENR ) )
                                FROM VBEP
                              WHERE VBELN  = A~VBELN
                                 AND POSNR   = A~POSNR
*                                 AND LIFSP = ' '
                                 AND WMENG    NE 0
                        GROUP BY VBELN, POSNR )
      AND CONCAT( P~VBELN, P~POSNR ) NOT IN
       ( SELECT  CONCAT( VBELN, POSNR )
            FROM VBEP
          WHERE VBELN = A~VBELN
              AND POSNR   = A~POSNR
              AND  ETTYP EQ 'CN'
              AND EDATU  = ( SELECT MAX( EDATU ) AS EDATU
                                FROM VBEP
                            WHERE VBELN = A~VBELN
                                AND POSNR   = A~POSNR
                       GROUP BY VBELN, POSNR ) )
        AND P~ABGRU IN @LT_ABGRU
        AND P~FIXMG = ''
        AND P~MATNR IN @GT_RANGE_MATNR
        AND C~WERKS = @P_WERKS
        AND C~DISPO LIKE @GV_DISPO
        AND KNA1~KUNNR IN @LT_KUNNR
        INTO  TABLE @DATA(LT_MAIN).

  CHECK LT_MAIN IS NOT INITIAL.
*  추출한 주문 번호로 생산 계획 및 생산 오더 조회
  DATA(LT_CHK_ORDER) = LT_MAIN[].

  IF LT_CHK_ORDER IS NOT INITIAL.
    SELECT DISTINCT B~*
      FROM @LT_CHK_ORDER AS A
        INNER JOIN ZGTPPT2330 AS B ON B~DMORD = A~VBELN
                                              AND B~DMLINE = A~POSNR
                                              AND B~DMORDTY = 'SO'
                                              AND B~ZDISTRIB = '1'
      INTO TABLE @DATA(LT_2330).


    SELECT SINGLE FLD_02 AS WERKS,  FLD_03 AS EKORG,  FLD_04 AS EKGRP
      FROM ZGTPPT1010
     WHERE MODULE_KIND = 'PP'
       AND CODEGRP = '2090'
       AND FLD_01 = ' '
       AND FLD_02 = @P_WERKS
      INTO @DATA(LS_PR_INFOR).

* 범주 판매오더의 OEM 구매요청 확인
    SELECT A~BANFN, A~BNFPO, A~LFDAT, A~STATU, B~VBELN, B~VBELP, A~LIFNR, C~NAME1
      FROM EBAN AS A
      INNER JOIN EBKN AS B ON B~BANFN = A~BANFN
                                AND B~BNFPO = A~BNFPO
      LEFT JOIN LFA1 AS C ON C~LIFNR = A~LIFNR
      FOR ALL ENTRIES IN @LT_CHK_ORDER
     WHERE B~VBELN =  @LT_CHK_ORDER-VBELN
        AND B~VBELP =  @LT_CHK_ORDER-POSNR
        AND A~MATNR =  @LT_CHK_ORDER-MATNR
        AND A~WERKS =  @P_WERKS
        AND A~BSTYP = 'B'
        AND A~EKORG = @LS_PR_INFOR-EKORG
        AND A~EKGRP = @LS_PR_INFOR-EKGRP
        AND A~LOEKZ = ''
      INTO TABLE @DATA(LT_EBAN).

    SELECT B~LIFNR, A~EBELN, A~EBELP, A~BANFN, A~BNFPO, C~NAME1
      FROM EKPO AS A
      INNER JOIN EKKO AS B ON B~EBELN = A~EBELN
      INNER JOIN LFA1 AS C ON C~LIFNR = B~LIFNR
      INNER JOIN @LT_EBAN AS D ON D~BANFN = A~BANFN
                                         AND D~BNFPO = A~BNFPO
      INTO TABLE @DATA(LT_EKKO).

  ENDIF.

*  추출한 주문 번호로 생산 계획 및 생산 오더 조회
  SORT LT_CHK_ORDER BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_ORDER COMPARING VBELN POSNR.
  IF LT_CHK_ORDER[] IS NOT INITIAL.
    SELECT *
          FROM ZGTCV_STOCKVAL
           FOR ALL ENTRIES IN @LT_CHK_ORDER
          WHERE MATNR = @LT_CHK_ORDER-MATNR
            AND VBELN = @LT_CHK_ORDER-VBELN
            AND POSNR = @LT_CHK_ORDER-POSNR
          INTO TABLE @DATA(LT_STOCKVAL).

    LOOP AT LT_STOCKVAL INTO DATA(LS_STOCKVAL).
      CLEAR LS_COLLECT_STOCKVAL.
      LS_COLLECT_STOCKVAL-VBELN = LS_STOCKVAL-VBELN.
      LS_COLLECT_STOCKVAL-POSNR = LS_STOCKVAL-POSNR.
      LS_COLLECT_STOCKVAL-MATNR = LS_STOCKVAL-MATNR.
      LS_COLLECT_STOCKVAL-MENGE = LS_STOCKVAL-LABST + LS_STOCKVAL-INSME.
      COLLECT LS_COLLECT_STOCKVAL INTO LT_COLLECT_STOCKVAL.
    ENDLOOP.
  ENDIF.

  DATA : LV_VBELN_C(10).
  DATA : LV_POSNR_C(6).

  LOOP AT LT_MAIN INTO DATA(LS_MAIN).
    READ TABLE LT_COLLECT_STOCKVAL INTO LS_COLLECT_STOCKVAL WITH KEY VBELN = LS_MAIN-VBELN
                                                                                                  POSNR = LS_MAIN-POSNR.
    IF SY-SUBRC EQ 0 AND LS_COLLECT_STOCKVAL-MENGE >= LS_MAIN-KLMENG.
      CONTINUE.
    ENDIF.

    CLEAR GS_MAIN_DISP.
    MOVE-CORRESPONDING LS_MAIN TO GS_MAIN_DISP.

*조장(기본단위)
*조장수
* 조장(판매단위)
    ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
      EXPORTING
        IV_CUOBJ      = LS_MAIN-CUOBJ                 " 구성
      IMPORTING
        EV_ZGTEINDLEN = GS_MAIN_DISP-ZGTEINDLEN
        EV_ZGTEFACTOR = GS_MAIN_DISP-ZGTEFACTOR
        EV_SO_INDLEN = GS_MAIN_DISP-ZGTEINDLEN2
        EV_PACK_YN = GS_MAIN_DISP-PACK_YN  ).

* 완제품 자재가 권취 일시 박스 포장 보여준다.
    SELECT SINGLE * FROM ZGTCVMSTVAL
      INTO @DATA(LS_CVMSTVAL)
     WHERE WERKS = @P_WERKS
        AND MATNR = @GS_MAIN_DISP-MATNR.

    IF SY-SUBRC EQ 0 AND LS_CVMSTVAL-PDCAPROCCODE = 'REW'.
      GS_MAIN_DISP-CHAR2 = ICON_CHARACTERISTICS_ACT.
    ENDIF.

    IF GS_MAIN_DISP-PACK_YN = 'CM' OR GS_MAIN_DISP-PACK_YN = 'NA'.
      GS_MAIN_DISP-PACK_YN = '확정'.
    ENDIF.

    IF LS_MAIN-KLMENG = 0.
      GS_MAIN_DISP-KLMENG = GS_MAIN_DISP-ZGTEINDLEN * GS_MAIN_DISP-ZGTEFACTOR.
    ENDIF.

    GS_MAIN_DISP-GCATG = '판매오더'.

    LV_VBELN_C = LS_MAIN-VBELN.
    LV_POSNR_C = LS_MAIN-POSNR.
    __ALPHA_OUT : LV_VBELN_C, LV_POSNR_C.

*    소요량 요소 : 판매오더/품목번호/우선순위
    CONCATENATE LV_VBELN_C LV_POSNR_C
                  INTO GS_MAIN_DISP-REQ_FACTOR SEPARATED BY '/'.

*  영업소 확인
    CALL FUNCTION 'ZGTSD_GET_ZZYUSCD'
      EXPORTING
        I_VKORG   = LS_MAIN-VKORG
        I_VKGRP   = LS_MAIN-VKGRP
        I_KDKG4   = LS_MAIN-KDKG4
      IMPORTING
        E_ZZYUSCD = GS_MAIN_DISP-ZZYUSCD.
    APPEND GS_MAIN_DISP TO GT_MAIN_DISP.
  ENDLOOP.

  IF S_YUSCD[] IS NOT INITIAL.
    DELETE GT_MAIN_DISP WHERE ZZYUSCD NOT IN S_YUSCD.
  ENDIF.

  LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

* 제품내역
    <LS_MAIN>-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = <LS_MAIN>-MATNR ).

*   특성
    <LS_MAIN>-CHAR = ICON_CHARACTERISTICS_ACT.

*   특성
    <LS_MAIN>-SNOTE = ICON_DISPLAY_TEXT.

*  작업요청
    READ TABLE LT_2330 INTO DATA(LS_2330) WITH KEY DMORD = <LS_MAIN>-VBELN
                                                                    DMLINE = <LS_MAIN>-POSNR
                                                                    DMORDTY = 'SO'.
    IF SY-SUBRC EQ 0.
      IF LS_2330-RQMON = P_SPMON.
        <LS_MAIN>-CHK_PROC = ABAP_TRUE.
      ELSE.
        DELETE GT_MAIN_DISP.
        CONTINUE.
      ENDIF.
    ENDIF.

* OEM 구매요청 확인
    READ TABLE  LT_EBAN INTO DATA(LS_EBAN) WITH KEY VBELN = <LS_MAIN>-VBELN
                                                                 VBELP = <LS_MAIN>-POSNR
                                                                 BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      <LS_MAIN>-CHK_OEM = ABAP_TRUE.
      <LS_MAIN>-CHK_PROC = ABAP_TRUE.

      <LS_MAIN>-BANFN = LS_EBAN-BANFN.
      <LS_MAIN>-BNFPO = LS_EBAN-BNFPO.
      <LS_MAIN>-LFDAT = LS_EBAN-LFDAT.
      <LS_MAIN>-STATU = ZGTPP_CL_COMMON=>GET_DOMAIN_TEXT(
                                    IV_DOMNAME  = 'BANST'
                                    IV_DOMVALUE = CONV #( LS_EBAN-STATU ) ).

      <LS_MAIN>-PR_NAME1 = LS_EBAN-NAME1.

      READ TABLE LT_EKKO INTO DATA(LS_EKKO) WITH KEY BANFN = LS_EBAN-BANFN
                                                                        BNFPO = LS_EBAN-BNFPO.
      IF SY-SUBRC EQ 0.
        <LS_MAIN>-EBELN = LS_EKKO-EBELN.
        <LS_MAIN>-EBELP = LS_EKKO-EBELP.

        <LS_MAIN>-PR_NAME1 = LS_EKKO-NAME1.
      ENDIF.

    ENDIF.

*    IF P_ZERO IS NOT INITIAL AND <LS_MAIN>-CHK_PROC = ABAP_TRUE.
*      DELETE GT_MAIN_DISP.
*    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MAINDATA_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_MAINDATA_PO .

  SELECT * FROM ZGTPPT2001
    INTO TABLE @DATA(LT_MAIN)
   WHERE ORDNO IN @S_AUFNR
     AND WERKS = @P_WERKS
     AND SPGCD = @P_SPGCD
     AND GLTRP >= @S_DATE-LOW
     AND GSTRP <= @S_DATE-HIGH
     AND MATNR IN @S_MATNR
     AND ZDEL = ''.

  CHECK LT_MAIN IS NOT INITIAL.
*  추출한 주문 번호로 생산 계획 및 생산 오더 조회
  DATA(LT_CHK_ORDER) = LT_MAIN[].


* 조장생성이력 조회
  SELECT DISTINCT B~*
    FROM @LT_CHK_ORDER AS A
      INNER JOIN ZGTPPT2330 AS B ON B~DMORD = A~ORDNO
                                            AND B~DMLINE = A~POSNR
                                            AND B~DMORDTY = 'PRD'
                                            AND B~ZDISTRIB = '1'
    INTO TABLE @DATA(LT_2330).


  DATA : LV_VBELN_C(12).
  DATA : LV_POSNR_C(6).
  DATA : LV_LPRIO_C(3).

* 모수 기준으로 조회
  LOOP AT LT_MAIN INTO DATA(LS_2001).
    CLEAR GS_MAIN_DISP.

    GS_MAIN_DISP-GCATG = '생산오더'.

    LV_VBELN_C = LS_2001-ORDNO.
    LV_POSNR_C = LS_2001-POSNR.
    __ALPHA_OUT : LV_VBELN_C, LV_POSNR_C.

*    소요량 요소 : 판매오더/품목번호/우선순위
    CONCATENATE LV_VBELN_C LV_POSNR_C
                  INTO GS_MAIN_DISP-REQ_FACTOR SEPARATED BY '/'.

* 오더번호
    GS_MAIN_DISP-VBELN = LS_2001-ORDNO.

* 품목
    GS_MAIN_DISP-POSNR = LS_2001-POSNR + 0.

*조장(기본단위)
    GS_MAIN_DISP-ZGTEINDLEN = LS_2001-INLENGTH.
*조장수
    GS_MAIN_DISP-ZGTEFACTOR = LS_2001-INFACTOR.


    GS_MAIN_DISP-MATNR = LS_2001-MATNR.
* 제품내역
    GS_MAIN_DISP-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = GS_MAIN_DISP-MATNR ).

*   단위
    GS_MAIN_DISP-MEINS = LS_2001-MEINS.

* 오더 수량 총계
    GS_MAIN_DISP-KLMENG = LS_2001-GAMNG.

*   소요일
    GS_MAIN_DISP-EDATU = LS_2001-GLTRP.

*  SM 오더의 경우 영업소 코드 '생관'
    GS_MAIN_DISP-ZZYUSCD = '생관'.

*  작업요청
    READ TABLE LT_2330 INTO DATA(LS_2330) WITH KEY DMORD = GS_MAIN_DISP-VBELN
                                                                    DMLINE = GS_MAIN_DISP-POSNR
                                                                    DMORDTY = 'PRD'.
    IF SY-SUBRC EQ 0.
      IF LS_2330-RQMON = P_SPMON.
        GS_MAIN_DISP-CHK_PROC = ABAP_TRUE.
      ELSE.
        CONTINUE.
      ENDIF.
    ENDIF.

*    IF P_ZERO IS NOT INITIAL AND GS_MAIN_DISP-CHK_PROC = ABAP_TRUE.
*      CONTINUE.
*    ENDIF.
    APPEND GS_MAIN_DISP TO GT_MAIN_DISP.

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
      CONTAINER = GO_BOTTOM_CONTAINER.

*화면 분할
  CREATE OBJECT GO_SPLITTER2
    EXPORTING
      PARENT  = GO_BOTTOM_CONTAINER
      ROWS    = 1
      COLUMNS = 2.

  PERFORM SET_BOTTOM_SCREEN_WIDTH.


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
FORM EVENT_HANDLER_REGISTER  USING     PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
*// Event Handler ##
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE          FOR PO_GRID.
    WHEN GO_GRID_0101.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
    WHEN GO_GRID_0102.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
    WHEN GO_GRID_0500.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
    WHEN GO_GRID_0501.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
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
      I_INCLNAME             = 'ZGTPPR2270TOP'
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

  READ TABLE GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'REQ_FACTOR'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'REQ_FACTOR'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '소요량 요소'(F01).
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '50'.
    <LS_FCAT>-JUST = 'L'.
    <LS_FCAT>-KEY = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'COLOR'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'COLOR'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상'(F02).
    <LS_FCAT>-COL_POS = 7.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.

  ENDIF.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'CHK_PROC'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'CHK_PROC'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업요청'(F03).
    <LS_FCAT>-COL_POS = 12.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-OUTPUTLEN = '4'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.

  ENDIF.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'CHK_OEM'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'CHK_OEM'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'OEM 대응'(F04).
    <LS_FCAT>-COL_POS = 13.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-OUTPUTLEN = '4'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'PACK_YN'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'PACK_YN'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '포장재지정'(F87).
    <LS_FCAT>-COL_POS = 23.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '20'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    <LS_FCAT>-TABNAME = 'GT_MAIN_DISP'.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'REQ_FACTOR'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'GCATG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '범주'(F05).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZGTEINDLEN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장'(F06).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'ZGTEFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(F07).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'KLMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수량'(F08).
        <LS_FCAT>-EMPHASIZE = 'C110'.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'COLOR'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'EDATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품요청일'(F09).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품명'(F10).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'KWMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매수량'(F11).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'VRKME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매단위'(F12).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기본단위'(F13).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'CHAR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '특성'(F14).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = 'X'.
      WHEN 'CHAR2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'BOX포장'(F88).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = 'X'.
      WHEN 'ZZYUSCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '영업소'(F15).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매오더번호'(F16).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매오더품목'(F17).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품번호'(F18).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
      WHEN 'KUNNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품처'(F19).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품처내역'(F20).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'BANFN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매요청번호'(F21).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'BNFPO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매요청품목'(F22).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'LFDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매납품예정일'(F23).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'STATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매처리상태'(F24).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PR_NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공급업체명'(F25).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'SNOTE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '특기사항(헤더)'(F74).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'SNOTE2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '특기사항(품목)'(F75).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'ZSPECNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SPEC NO'(F67).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE = 'C110'.
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
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

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
*& Form SET_OBJECT_GO_TEXT_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GO_TEXT_300 .

  CREATE OBJECT GO_CONTAINER_300
    EXPORTING
      CONTAINER_NAME = 'CONTAINER_300'.

  CREATE OBJECT GO_TEXT_300
    EXPORTING
      WORDWRAP_MODE          = 2
      MAX_NUMBER_CHARS       = 255                         " maximum number of characters insertable into editor control
      PARENT                 = GO_CONTAINER_300                        " Parent Container
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
*& Form SET_GO_TEXT_300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GO_TEXT_300 .

  GO_TEXT_300->SET_TOOLBAR_MODE( EXPORTING TOOLBAR_MODE = 0 ).

  GO_TEXT_300->SET_STATUSBAR_MODE( EXPORTING STATUSBAR_MODE = 0 ).

  GO_TEXT_300->SET_READONLY_MODE( EXPORTING READONLY_MODE = 0 ).

  GO_TEXT_300->SET_TEXT_AS_R3TABLE( EXPORTING TABLE = GT_TEXT ).

  CALL METHOD CL_GUI_CFW=>FLUSH
    EXCEPTIONS
      OTHERS = 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_AND_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_AND_CREATE .

  DATA : LV_MESSAGE(100).
  DATA : LV_CHK_ERR.
  DATA : LV_STRING TYPE STRING.
*  필드 빈값 체크
  CLEAR LV_MESSAGE.
  PERFORM SCREEN_400_CHK_INIT CHANGING LV_MESSAGE.
  IF LV_MESSAGE IS NOT INITIAL.
    MESSAGE I003 WITH LV_MESSAGE.
    RETURN.
  ENDIF.

  PERFORM SCREEN_400_CHK_VALIDATION  CHANGING LV_MESSAGE.
  IF LV_MESSAGE IS NOT INITIAL.
    MESSAGE I003 WITH LV_MESSAGE.
    RETURN.
  ENDIF.

  CALL METHOD GO_TEXT_300->GET_TEXT_AS_R3TABLE( EXPORTING ONLY_WHEN_MODIFIED = ' ' IMPORTING TABLE = GT_TEXT ).
  LOOP AT GT_TEXT INTO DATA(LS_TEXT).
    LV_STRING = |{ LV_STRING }{ LS_TEXT }{  CL_ABAP_CHAR_UTILITIES=>NEWLINE }|.
  ENDLOOP.

  IF CHARLEN( LV_STRING ) > 255.
    MESSAGE I003 WITH '특기사항은 255자를 넘을수 없습니다.'.
    RETURN.
  ENDIF.

  PERFORM CREATE_ORDERS CHANGING LV_CHK_ERR.
  IF LV_CHK_ERR IS NOT INITIAL.
    GV_CHK_CREATE = 'E'. " 실패
  ELSE.
    GV_CHK_CREATE = 'S'. " 성공
  ENDIF.

  GO_CONTAINER_300->FREE( ).
  GO_TEXT_300->FREE( ).
  FREE : GO_CONTAINER_300, GO_TEXT_300.

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCREEN_400_CHK_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM SCREEN_400_CHK_INIT  CHANGING PV_MESSAGE.

  IF GS_MAKE_ORDER-MATNR IS INITIAL.
    PV_MESSAGE = TEXT-E41.
  ENDIF.

*  IF GS_MAKE_ORDER-GAMNG IS INITIAL OR GS_MAKE_ORDER-GAMNG = 0.
*    PV_MESSAGE = TEXT-E02.
*  ENDIF.


  IF GS_MAKE_ORDER-GSTRP IS INITIAL OR GS_MAKE_ORDER-GSTRP = '00000000'.
    PV_MESSAGE = TEXT-E42.
  ENDIF.

  IF GS_MAKE_ORDER-GLTRP IS INITIAL OR GS_MAKE_ORDER-GLTRP = '00000000'.
    PV_MESSAGE = TEXT-E43.
  ENDIF.


  IF GS_MAKE_ORDER-INLENGTH IS INITIAL OR GS_MAKE_ORDER-INLENGTH = 0.
    PV_MESSAGE = TEXT-E44.
  ENDIF.

  IF GS_MAKE_ORDER-INFACTOR IS INITIAL OR GS_MAKE_ORDER-INFACTOR = 0.
    PV_MESSAGE = TEXT-E45.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCREEN_400_CHK_VALIDATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM SCREEN_400_CHK_VALIDATION  CHANGING PV_MESSAGE.

* 생산자재
  SELECT * FROM ZGTCVMSTVAL
       INTO TABLE @DATA(LT_MATNR)
     WHERE WERKS = @P_WERKS
       AND MATNR = @GS_MAKE_ORDER-MATNR
       AND SPG = @P_SPGCD
       AND MTREF = 'FERT'
       AND LVORMC = ''
       AND LVORMP = ''
       AND MMSTA = ''
       AND ( BESKZ <> 'F'
        OR BESKZ = 'F' AND SOBSL = '30' ).

  IF SY-SUBRC NE 0.
    PV_MESSAGE = TEXT-E39.
    RETURN.
  ENDIF.

  GS_MAKE_ORDER-GAMNG = GS_MAKE_ORDER-INLENGTH * GS_MAKE_ORDER-INFACTOR.
  IF GS_MAKE_ORDER-GAMNG <= 0.
    PV_MESSAGE = TEXT-E18.
    RETURN.
  ENDIF.

  IF GS_MAKE_ORDER-GSTRP > GS_MAKE_ORDER-GLTRP.
    PV_MESSAGE = TEXT-E40.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ORDERS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CREATE_ORDERS  CHANGING PV_CHK_ERR.

  DATA : LS_SAVE_2001 TYPE ZGTPPT2001.
  DATA : LV_CHK_ERR.

* SM 생산오더는 ZGTPPT2001 테이블에 저장
  CLEAR LS_SAVE_2001.
  PERFORM GET_ORDNO CHANGING LS_SAVE_2001-ORDNO LV_CHK_ERR.
  IF LV_CHK_ERR IS NOT INITIAL.
    PV_CHK_ERR = 'E'.
    MESSAGE S006 WITH '생산오더(SM) 생성중 오류 발생하였습니다.'  INTO GV_MESSAGE_300.
    RETURN.
  ENDIF.

  LS_SAVE_2001-POSNR = 1.
  LS_SAVE_2001-WERKS = P_WERKS.
  LS_SAVE_2001-SPGCD = P_SPGCD.
  LS_SAVE_2001-GSTRP = GS_MAKE_ORDER-GSTRP.
  LS_SAVE_2001-GLTRP = GS_MAKE_ORDER-GLTRP.
  LS_SAVE_2001-MATNR = GS_MAKE_ORDER-MATNR.
  LS_SAVE_2001-INLENGTH = GS_MAKE_ORDER-INLENGTH.
  LS_SAVE_2001-INFACTOR = GS_MAKE_ORDER-INFACTOR.
  LS_SAVE_2001-GAMNG = GS_MAKE_ORDER-GAMNG.
  LS_SAVE_2001-MEINS = GS_MAKE_ORDER-GMEIN.
  LS_SAVE_2001-ZPMAT = GS_MAKE_ORDER-COV_MATNR.
  LS_SAVE_2001-ZZPRIORITY = GS_MAKE_ORDER-ZZPRIORITY.

  LOOP AT GT_TEXT INTO DATA(LS_TEXT).
    LS_SAVE_2001-SNOTE = |{ LS_SAVE_2001-SNOTE }{ LS_TEXT }{  CL_ABAP_CHAR_UTILITIES=>NEWLINE }|.
  ENDLOOP.
*  LS_SAVE_2001-SNOTE = GS_MAKE_ORDER-SNOTE.
*LS_SAVE_2001-ZDEL
  LS_SAVE_2001-CRNAM  = SY-UNAME.

  MODIFY ZGTPPT2001 FROM LS_SAVE_2001.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    PV_CHK_ERR = 'E'.
    MESSAGE S006 WITH '생산오더(SM) 생성중 오류 발생하였습니다.'  INTO GV_MESSAGE_300.
    RETURN.
  ELSE.
    COMMIT WORK AND WAIT.
  ENDIF.

  MESSAGE S006 WITH '생산오더(SM) 생성되었습니다. -' LS_SAVE_2001-ORDNO  INTO GV_MESSAGE_300.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ORDNO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_SAVE_2001_ORDNO
*&---------------------------------------------------------------------*
FORM GET_ORDNO  CHANGING PV_ORDNO TYPE ZGTPPT2001-ORDNO
                                         PV_CHK_ERR.

  DATA : LV_NR     LIKE  INRI-NRRANGENR.

  LV_NR = '01'.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = LV_NR
      OBJECT                  = 'ZGTPP_GORD'
    IMPORTING
      NUMBER                  = PV_ORDNO
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.
  IF SY-SUBRC <> 0.
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DEL_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DEL_PO .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LT_ORDERS TYPE TABLE OF ZGTPPT2001.
  DATA : LS_RETURN TYPE BAPIRET2.
  DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.
  DATA : LV_STATUS TYPE CHAR10.
  DATA : LV_AUFNR TYPE AUFNR.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  LOOP AT LT_ROW INTO LS_ROW.
    READ TABLE GT_MAIN_DISP INTO GS_MAIN_DISP INDEX LS_ROW-INDEX.
    IF GS_MAIN_DISP-GCATG = '생산오더'.
* 유효성 확인
*      1)조장구성표 존재시 삭제불가
      SELECT SINGLE * FROM ZGTPPT2330
        WHERE DMORD = @GS_MAIN_DISP-VBELN
        INTO @DATA(LS_2330).
      IF SY-SUBRC EQ 0 OR LS_2330 IS NOT INITIAL.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '선택된 생산오더(SM)가 작업지시에 포함되어 있습니다. - '(M21)  GS_MAIN_DISP-VBELN.
        RETURN.
      ENDIF.

      APPEND INITIAL LINE TO LT_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDNO>).
      <LS_ORDNO>-ORDNO = GS_MAIN_DISP-VBELN.

    ENDIF.

  ENDLOOP.

  IF LT_ORDERS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 생산오더가 없습니다'(M20).
    GV_CHK_DEL = 'E'.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 오더가 삭제 됩니다. 계속 진행 하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LOOP AT LT_ORDERS INTO DATA(LS_ORDERS).
    UPDATE ZGTPPT2001 SET ZDEL = ABAP_TRUE
     WHERE ORDNO = LS_ORDERS-ORDNO.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      GV_CHK_DEL = 'E'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF GV_CHK_DEL NE 'E'.
    COMMIT WORK AND WAIT.
    GV_CHK_DEL = 'S'.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DISP .

  DATA : LV_CHK_EXIST.

  LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    READ TABLE GT_CVMVAL INTO DATA(LS_CVMVAL) WITH KEY MATNR = <LS_MAIN>-MATNR.
    IF SY-SUBRC EQ 0.
      IF LS_CVMVAL-COLORBASE IS NOT INITIAL.
        <LS_MAIN>-COLOR = LS_CVMVAL-COLORBASE.
      ENDIF.
*    스펙번호 추가
      <LS_MAIN>-ZSPECNO = LS_CVMVAL-PDCASPECNO.
    ENDIF.

    IF <LS_MAIN>-GCATG = '판매오더'.
* 특기사항 헤더
      CLEAR <LS_MAIN>-SNOTE.
      CLEAR LV_CHK_EXIST.
      PERFORM CHK_EXIST_SNOTE_FR_SO USING 'H' <LS_MAIN>-VBELN <LS_MAIN>-POSNR  CHANGING LV_CHK_EXIST.
      IF LV_CHK_EXIST = ABAP_TRUE.
        <LS_MAIN>-SNOTE = ICON_DISPLAY_TEXT.
      ENDIF.
* 특기사항 item
      CLEAR <LS_MAIN>-SNOTE2.
      CLEAR LV_CHK_EXIST.
      PERFORM CHK_EXIST_SNOTE_FR_SO USING 'I' <LS_MAIN>-VBELN <LS_MAIN>-POSNR  CHANGING LV_CHK_EXIST.
      IF LV_CHK_EXIST = ABAP_TRUE.
        <LS_MAIN>-SNOTE2 = ICON_DISPLAY_TEXT.
      ENDIF.

    ELSE.
      CLEAR <LS_MAIN>-SNOTE.
      CLEAR LV_CHK_EXIST.
      PERFORM CHK_EXIST_SNOTE_FR_PO USING <LS_MAIN>-VBELN <LS_MAIN>-POSNR  CHANGING LV_CHK_EXIST.
      IF LV_CHK_EXIST = ABAP_TRUE.
        <LS_MAIN>-SNOTE = ICON_DISPLAY_TEXT.
      ENDIF.
    ENDIF.

  ENDLOOP.

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
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.

* 선택월 작업지시 확인
  SELECT * FROM ZGTPPT2330
    INTO TABLE GT_2330
   WHERE WERKS = P_WERKS
     AND SPGCD = P_SPGCD
     AND RQMON = P_SPMON
     AND ZDISTRIB = '1'
     AND ZOEM = ' '.

* 해당 자재 구성을 위한 봄 구성
  PERFORM MAKE_MAINTAIN_BOM.

  SELECT * FROM ZGTPPT2340
    INTO TABLE GT_2340
   WHERE WERKS = P_WERKS
     AND SPGCD = P_SPGCD
     AND RQMON = P_SPMON.

  PERFORM SET_PO_RESB_NO.

  LOOP AT GT_2340 INTO DATA(LS_2340_ORDNR)   WHERE ORDTY = 'PRD'.
    APPEND INITIAL LINE TO LT_AUFNR ASSIGNING FIELD-SYMBOL(<LS_AUFNR>).
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

  PERFORM GET_CURRENT_MONTH_ORDER.

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

* 완제품 작업지시화면 구성
  REFRESH GT_BOTTOM_DISP.

  LOOP AT GT_2330 INTO DATA(LS_2330) WHERE GONG_SEQ EQ  '01'.

    CLEAR GS_BOTTOM_DISP.
    GS_BOTTOM_DISP-SEQNO = LS_2330-GONG_SEQ + 0.

    READ TABLE GT_2340 INTO DATA(LS_2340) WITH KEY ZWKREQ = LS_2330-ZWKREQ
                                                                       GONG_CD = LS_2330-GONG_CD
                                                                       GONG_SEQ = LS_2330-GONG_SEQ.
    IF SY-SUBRC EQ 0.
      PERFORM SET_LINE_2340 USING LS_2330 LS_2340 LS_2330-MEINS CHANGING GS_BOTTOM_DISP.
    ELSE.
      PERFORM SET_LINE_2330 USING LS_2330 CHANGING GS_BOTTOM_DISP.
    ENDIF.
    APPEND GS_BOTTOM_DISP TO GT_BOTTOM_DISP.

  ENDLOOP.

* 반제품 작업지시화면 구성
  REFRESH : GT_BOTTOM2, GT_BOTTOM_DISP2.

  SORT GT_BASE_GONG_SEQ BY GONG_SEQ.

  LOOP AT GT_BASE_GONG_SEQ INTO GS_BASE_GONG_SEQ.
* 반제품공정만
    CASE GS_BASE_GONG_SEQ-GONG_SEQ.
      WHEN '01'.
        CONTINUE.
    ENDCASE.

    LOOP AT GT_2330 INTO LS_2330 WHERE GONG_CD = GS_BASE_GONG_SEQ-GONG_CD.
      IF LS_2330-GONG_SEQ = '01'. "완제품 공정은 대상아님.
        CONTINUE.
      ENDIF.
      CLEAR GS_BOTTOM2.
      PERFORM SET_DISP_BOTTOM_USING_GONG USING LS_2330.
      APPEND GS_BOTTOM2 TO GT_BOTTOM2.
    ENDLOOP.

  ENDLOOP.

  IF GT_BOTTOM2 IS NOT INITIAL.
    MOVE-CORRESPONDING GT_BOTTOM2 TO GT_BOTTOM_DISP2.
  ENDIF.

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
                           USING : 'REQUEST' ICON_EXECUTE_OBJECT '작업요청' '작업요청' 0,
                                      'DEL_REQ' ICON_DELETE '작업요청해제' '작업요청해제' 0,
                                       '' '' '' '' 3,
                                      'CRT_OEM' ICON_FAST_ENTRY 'OEM구매요청' 'OEM구매요청' 0,
                                      'DEL_OEM' ICON_DELETE 'OEM삭제' 'OEM삭제' 0 .
    WHEN GO_GRID_0101.
      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                           USING : 'CRT_PRD' ICON_EXECUTE_OBJECT '생산오더생성' '생산오더생성' 0,
                                      'DEL_PRD' ICON_DELETE '생산오더삭제' '생산오더삭제' 0,
                                       '' '' '' '' 3,
                                      'CRT_PO' ICON_IMPORT_ALL_REQUESTS '임가공구매발주' '입가공구매발주' 0,
                                      'DEL_PO' ICON_DELETE '입가공구매발주취소' '입가공구매발주취소' 0 ,
                                      '' '' '' '' 3,
                                      'DISP_HALF' ICON_ARROW_RIGHT '반제품 작업요청' '반제품 작업요청' 0 .

    WHEN GO_GRID_0102.
      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                           USING : 'CRT_PO' ICON_IMPORT_ALL_REQUESTS '임가공구매발주' '입가공구매발주' 0,
*                                      'DEL_PO' ICON_DELETE '입가공구매발주취소' '입가공구매발주취소' 0 ,
                                      '' '' '' '' 3,
                                      'DISP_HALF' ICON_ARROW_LEFT '완제품 작업지시' '완제품 작업지시' 0 .

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
        WHEN 'CRT_OEM'. " OEM구매요청
          PERFORM PROC_CREATE_PR.
        WHEN 'DEL_OEM'. " OEM삭제
          PERFORM PROC_DELETE_PR.
        WHEN 'SET_FILTER'. " 요청완료포함
          PERFORM SET_SET_FILTER USING 'X'.
        WHEN 'DEL_FILTER'. " 요청완료제외
          PERFORM SET_SET_FILTER USING ''.
      ENDCASE.
    WHEN GO_GRID_0101.
      CASE PV_UCOMM.
        WHEN 'CRT_PRD'. " 생산오더생성
          PERFORM PROC_CRT_PRD.
        WHEN 'DEL_PRD'. " 생산오더삭제
          PERFORM PROC_DEL_PRD.
        WHEN 'CRT_PO'. " 입가공구매발주
          PERFORM PROC_CRT_PO.
        WHEN 'DEL_PO'. " 입가공구매발주취소
          PERFORM PROC_DEL_PO_PRODUCT.
        WHEN 'DISP_HALF'. " 반제품 작업요청
          GV_CHK_DISP_ENDITEM = ABAP_TRUE.
          PERFORM SET_BOTTOM_SCREEN_WIDTH.
      ENDCASE.

    WHEN GO_GRID_0102.
      CASE PV_UCOMM.
        WHEN 'CRT_PO'. " 입가공구매발주
          PERFORM PROC_CRT_PO2.
        WHEN 'DEL_PO'. " 입가공구매발주취소
        WHEN 'DISP_HALF'. " 반제품 작업요청
          CLEAR GV_CHK_DISP_ENDITEM.
          PERFORM SET_BOTTOM_SCREEN_WIDTH.
      ENDCASE.

  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CREATE_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CREATE_PR .

  CLEAR GV_CHK_CREATE.
  PERFORM CREATE_PR.

  IF GV_CHK_CREATE = 'S'.
    PERFORM GET_PROC.
    PERFORM REFRESH_GRID USING GO_GRID_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DELETE_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DELETE_PR .

  CLEAR GV_CHK_DEL.
  PERFORM DELETE_PR.

  IF GV_CHK_DEL = 'S'.
    PERFORM GET_PROC.
    PERFORM REFRESH_GRID USING GO_GRID_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_PR .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LT_MAIN LIKE TABLE OF GS_MAIN_DISP.
  DATA : BEGIN OF LS_CHK_2000,
           ORDNO TYPE ZGTPPT2000-ORDNO,
           POSNR TYPE  ZGTPPT2000-POSNR,
         END OF LS_CHK_2000.
  DATA : LT_2330 TYPE TABLE OF ZGTPPT2330.
  DATA : LS_2330 TYPE ZGTPPT2330.
  DATA : LV_VBELN TYPE VBELN.
  DATA : LV_CHK_ERR.
  DATA : BEGIN OF LS_CHK_MAX_ZWKREQ,
           ZWKREQ   TYPE ZGTPPT2330-ZWKREQ,
           SEQNO(6) TYPE C,
         END OF LS_CHK_MAX_ZWKREQ.
  DATA : LT_CHK_MAX_ZWKREQ LIKE TABLE OF LS_CHK_MAX_ZWKREQ.
  DATA : LV_MAX_SEQ(6) TYPE N.

  DATA : LT_LIFNR LIKE TABLE OF GS_LIFNR.

  REFRESH GT_LIFNR.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  SELECT SINGLE FLD_02 AS WERKS, FLD_03 AS EKORG, FLD_04 AS EKGRP
    FROM ZGTPPT1010
    INTO @GS_EKORG
   WHERE MODULE_KIND = 'PP'
     AND CODEGRP = '2090'
     AND FLD_01 = ' '
     AND FLD_02 = @P_WERKS.

  LOOP AT LT_ROW INTO LS_ROW.
    READ TABLE GT_MAIN_DISP INTO GS_MAIN_DISP INDEX LS_ROW-INDEX.

    IF GS_MAIN_DISP-GCATG NE '판매오더'.
      GV_CHK_CREATE = 'E'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '판매오더만 OEM 구매요청 진행 할 수 있습니다.'.
      RETURN.
    ENDIF.

    IF GS_MAIN_DISP-CHK_OEM IS NOT INITIAL.
      GV_CHK_CREATE = 'E'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH 'OEM 구매요청 진행 중인 판매오더 입니다.'.
      RETURN.
    ENDIF.

    IF GS_MAIN_DISP-CHK_PROC IS NOT INITIAL.
      GV_CHK_CREATE = 'E'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '작업요청 완료된 오더 입니다.'.
      RETURN.
    ENDIF.

    IF GS_MAIN_DISP-PACK_YN NE '확정'.
      GV_CHK_CREATE = 'E'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '포장재 확정이 진행되지 않은 S/O 입니다. 확인 후 재 작업 해주세요.'.
      RETURN.
    ENDIF.


    CLEAR LS_CHK_2000.
    LS_CHK_2000-ORDNO = GS_MAIN_DISP-VBELN.
    LS_CHK_2000-POSNR = GS_MAIN_DISP-POSNR.

* 조장생성이력 조회
    SELECT SINGLE * FROM ZGTPPT2000
      INTO @DATA(LS_2000)
     WHERE ORDNO = @LS_CHK_2000-ORDNO
        AND POSNR = @LS_CHK_2000-POSNR
        AND WERKS = @P_WERKS
        AND SPGCD = @P_SPGCD
        AND ZSTATUS NE 'D'.

    IF SY-SUBRC EQ 0.
      GV_CHK_CREATE = 'E'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '조장구성표 생성된 판매오더 입니다.'.
      RETURN.
    ENDIF.

    APPEND GS_MAIN_DISP TO LT_MAIN.

  ENDLOOP.

  IF LT_MAIN[] IS INITIAL.
    GV_CHK_CREATE = 'E'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 라인이 없습니다.'.
    RETURN.
  ENDIF.

* 작업 요청 순번 지정을 위해 작업요청 MaX 번호 가져온다
  SELECT  ZWKREQ, RIGHT( ZWKREQ, 6 ) AS SEQNO
    FROM ZGTPPT2330
    WHERE WERKS = @P_WERKS
      AND SPGCD = @P_SPGCD
      AND RQMON = @P_SPMON
    INTO CORRESPONDING FIELDS OF TABLE @LT_CHK_MAX_ZWKREQ.

  SORT LT_CHK_MAX_ZWKREQ BY SEQNO DESCENDING.
  READ TABLE LT_CHK_MAX_ZWKREQ INTO LS_CHK_MAX_ZWKREQ INDEX 1.

  LV_MAX_SEQ = LS_CHK_MAX_ZWKREQ-SEQNO.


  DATA : LV_TOT_CNT TYPE I.
  DATA : LV_TOT_CNT_C TYPE C LENGTH 11.
  DATA : LV_SUC_CNT TYPE I.
  DATA : LV_SUC_CNT_C TYPE C LENGTH 11.

  LOOP AT LT_MAIN INTO GS_MAIN_DISP.
    CLEAR LV_CHK_ERR.
    CLEAR GS_PR_INFOR.

    GS_PR_INFOR-ORGNO = GS_MAIN_DISP-VBELN. "오더번호
    GS_PR_INFOR-POSNR = GS_MAIN_DISP-POSNR. "품목
    GS_PR_INFOR-EKORG = GS_EKORG-EKORG. "구매조직
    GS_PR_INFOR-EKGRP = GS_EKORG-EKGRP. " 완제품 구매그룹
    GS_PR_INFOR-MATNR = GS_MAIN_DISP-MATNR.
    GS_PR_INFOR-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = GS_MAIN_DISP-MATNR ).
    GS_PR_INFOR-EEIND = GS_MAIN_DISP-EDATU - 1.

    ADD 1 TO LV_TOT_CNT.

    PERFORM CREATE_PR_EXECUTE CHANGING LV_CHK_ERR.
    IF LV_CHK_ERR NE ABAP_TRUE.
      ADD 1 TO LV_SUC_CNT.
    ELSE.
      CONTINUE.
    ENDIF.

    CLEAR LS_2330.

    LS_2330-WERKS = P_WERKS.
    LS_2330-SPGCD = P_SPGCD.
    LS_2330-RQMON = P_SPMON.
    ADD 1 TO LV_MAX_SEQ.
    LS_2330-ZWKREQ = SY-DATUM+2(6) && LV_MAX_SEQ.
    LS_2330-ZDISTRIB = '1'.
    LS_2330-GONG_CD = 'REW'.
    LS_2330-MATNR = GS_MAIN_DISP-MATNR.
    LS_2330-ZSPECNO = GS_MAIN_DISP-ZSPECNO.
    LV_VBELN = GS_MAIN_DISP-VBELN.
    __ALPHA_INPUT LV_VBELN.
    LS_2330-DMORD = LV_VBELN.
    LS_2330-DMORDTY = 'SO'.
    LS_2330-DMLINE = GS_MAIN_DISP-POSNR + 0.
* 작업요청월 + '01'
    LS_2330-PSTTR = P_SPMON && '01'.
* 작업요청월 + 말일
    LS_2330-PEDTR = LS_2330-PSTTR.
    PERFORM GET_LAST_DAY_OF_MONTH CHANGING LS_2330-PEDTR.

    LS_2330-MEINS = GS_MAIN_DISP-MEINS.
    LS_2330-INLENGTH = GS_MAIN_DISP-ZGTEINDLEN.
    LS_2330-INFACTOR = GS_MAIN_DISP-ZGTEFACTOR.
    LS_2330-BMENG = GS_MAIN_DISP-ZGTEINDLEN * GS_MAIN_DISP-ZGTEFACTOR.
    LS_2330-GSMNG = LS_2330-BMENG.
    LS_2330-GONG_SEQ = '01'.
    LS_2330-ZOEM = ABAP_TRUE.
    APPEND LS_2330 TO LT_2330.

  ENDLOOP.

  IF  LT_2330 IS NOT INITIAL.
    MODIFY ZGTPPT2330 FROM TABLE LT_2330.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
      PERFORM DELETE_PR_ORDER TABLES LT_2330.

      MESSAGE S006 DISPLAY LIKE 'E' WITH '선택된 주문의 작업 요청중 오류 발생하였습니다.'(E03).
      RETURN.
    ENDIF.
  ENDIF.

  DATA : LV_MESSAGE(100).
  LV_TOT_CNT_C = LV_TOT_CNT.
  LV_SUC_CNT_C = LV_SUC_CNT.
  CONDENSE : LV_TOT_CNT_C, LV_SUC_CNT_C.

  LV_MESSAGE = |선택 주문 : { LV_TOT_CNT_C }건 중 구매요청 { LV_SUC_CNT_C }건 생성되었습니다.|.
  MESSAGE S006 WITH LV_MESSAGE.

  GV_CHK_CREATE = 'S'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PR_EXECUTE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CREATE_PR_EXECUTE  CHANGING PV_CHK_ERR.

  DATA : LV_INLENGTH TYPE MENGE_D.
  DATA : LV_INLENGTH_C(20) TYPE C.
  DATA : LV_INFACTOR TYPE I.
  DATA : LV_INFACTOR_C(20) TYPE C.
  DATA : LS_PR_INFOR TYPE ZGTPPS0004.
  DATA : LT_CHART TYPE ZGTPPY0005.
  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LV_PSMNG_C(30) TYPE C.

  LV_INLENGTH = GS_MAIN_DISP-ZGTEINDLEN.
  LV_INLENGTH_C = LV_INLENGTH.
  CONDENSE LV_INLENGTH_C.

  APPEND INITIAL LINE TO LT_CHART ASSIGNING FIELD-SYMBOL(<LS_CHART>).
  <LS_CHART>-ATNAM = 'SAP_MILLCA_LENGTH'.
  <LS_CHART>-ATWRT = LV_INLENGTH_C.


  LV_INFACTOR = GS_MAIN_DISP-ZGTEFACTOR.
  LV_INFACTOR_C = LV_INFACTOR.
  CONDENSE LV_INFACTOR_C.

  APPEND INITIAL LINE TO LT_CHART ASSIGNING <LS_CHART>.
  <LS_CHART>-ATNAM = 'SAP_MILLCA_FACTOR'.
  <LS_CHART>-ATWRT = LV_INFACTOR_C.

  LV_PSMNG_C = GS_MAIN_DISP-KLMENG.
  CONDENSE : LV_PSMNG_C.


  CLEAR LS_PR_INFOR.
  LS_PR_INFOR-BSART = 'NB'.
  LS_PR_INFOR-KNTTP = 'M'.
*  LV_DATE = GS_MAIN_DISP-EDATU - 1.
  LS_PR_INFOR-EEIND = GS_PR_INFOR-EEIND.
  LS_PR_INFOR-LPEIN = 'T'.
  LS_PR_INFOR-WERKS = P_WERKS.
  LS_PR_INFOR-EKGRP = GS_EKORG-EKGRP.
  LS_PR_INFOR-AFNAM = SY-UNAME.
  LS_PR_INFOR-MATNR = GS_MAIN_DISP-MATNR.
  LS_PR_INFOR-EKORG = GS_EKORG-EKORG.
  LS_PR_INFOR-MENGE = LV_PSMNG_C.
  LS_PR_INFOR-KDAUF = GS_MAIN_DISP-VBELN.
  LS_PR_INFOR-KDPOS = GS_MAIN_DISP-POSNR.

  DATA : LV_RESULT TYPE CHAR01.

  CALL FUNCTION 'ZGTPP_CREATE_PR_BY_BDC'
    EXPORTING
      IS_PR_INFOR = LS_PR_INFOR
    IMPORTING
      EV_RESULT   = LV_RESULT
    TABLES
      IT_CHART    = LT_CHART.

  IF LV_RESULT NE 'S'.
    PV_CHK_ERR = ABAP_TRUE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELETE_PR .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LT_MAIN LIKE TABLE OF GS_MAIN_DISP.
  DATA : BEGIN OF LS_CHK_2000,
           ORDNO TYPE ZGTPPT2000-ORDNO,
           POSNR TYPE  ZGTPPT2000-POSNR,
         END OF LS_CHK_2000.
  DATA : LV_CHK_ERR.
  DATA : LT_2330 TYPE TABLE OF ZGTPPT2330.
  DATA : LS_2330 TYPE ZGTPPT2330.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  LOOP AT LT_ROW INTO LS_ROW.
    READ TABLE GT_MAIN_DISP INTO GS_MAIN_DISP INDEX LS_ROW-INDEX.

    IF GS_MAIN_DISP-GCATG NE '판매오더'.
      GV_CHK_DEL = 'E'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH 'OEM 구매요청되지 않은 라인이 있습니다.'.
      RETURN.
    ENDIF.

    IF GS_MAIN_DISP-CHK_OEM IS INITIAL.
      GV_CHK_DEL = 'E'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH 'OEM 구매요청되지 않은 라인이 있습니다.'.
      RETURN.
    ENDIF.

    IF GS_MAIN_DISP-EBELN IS NOT INITIAL.
      GV_CHK_DEL = 'E'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '구매 오더로 생성된 구매 요청으로 삭제 할 수 없습니다.'.
      RETURN.
    ENDIF.

    APPEND GS_MAIN_DISP TO LT_MAIN.

  ENDLOOP.

  IF LT_MAIN[] IS INITIAL.
    GV_CHK_DEL = 'E'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 라인이 없습니다.'.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 구매요청이 삭제 됩니다. 계속 진행 하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  DATA : LV_TOT_CNT TYPE I.
  DATA : LV_TOT_CNT_C TYPE C LENGTH 11.
  DATA : LV_SUC_CNT TYPE I.
  DATA : LV_SUC_CNT_C TYPE C LENGTH 11.

  LOOP AT LT_MAIN INTO GS_MAIN_DISP.
    CLEAR LV_CHK_ERR.
    ADD 1 TO LV_TOT_CNT.
    PERFORM DELETE_PR_EXECUTE CHANGING LV_CHK_ERR.
    IF LV_CHK_ERR NE ABAP_TRUE.
      ADD 1 TO LV_SUC_CNT.
    ENDIF.

    DELETE FROM ZGTPPT2330 WHERE DMORD = GS_MAIN_DISP-VBELN
                                     AND DMLINE = GS_MAIN_DISP-POSNR
                                     AND RQMON = P_SPMON.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDLOOP.



  DATA : LV_MESSAGE(100).
  LV_TOT_CNT_C = LV_TOT_CNT.
  LV_SUC_CNT_C = LV_SUC_CNT.
  CONDENSE : LV_TOT_CNT_C, LV_SUC_CNT_C.

  LV_MESSAGE = |선택 구매요청 : { LV_TOT_CNT_C }건 중 구매요청 { LV_SUC_CNT_C }건 삭제되었습니다.|.
  MESSAGE S006 WITH LV_MESSAGE.

  GV_CHK_DEL = 'S'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_PR_EXECUTE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM DELETE_PR_EXECUTE  CHANGING PV_CHK_ERR.

  DATA : LV_NUMBER TYPE BAPIMEREQHEADER-PREQ_NO.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LT_PRITEM TYPE TABLE OF BAPIMEREQITEMIMP.
  DATA : LT_PRITEMX TYPE TABLE OF BAPIMEREQITEMX.

  LV_NUMBER = GS_MAIN_DISP-BANFN.

* Item 정보 입력
  APPEND INITIAL LINE TO LT_PRITEM ASSIGNING FIELD-SYMBOL(<LS_PRITEM>).
  <LS_PRITEM>-PREQ_ITEM = '0010'.
  <LS_PRITEM>-DELETE_IND = 'X'.

* ItemX 정보 입력
  APPEND INITIAL LINE TO LT_PRITEMX ASSIGNING FIELD-SYMBOL(<LS_PRITEMX>).
  <LS_PRITEMX>-PREQ_ITEM = '0010'.
  <LS_PRITEMX>-DELETE_IND = 'X'.

  CALL FUNCTION 'BAPI_PR_CHANGE'
    EXPORTING
      NUMBER  = LV_NUMBER
    TABLES
      RETURN  = LT_RETURN
      PRITEM  = LT_PRITEM
      PRITEMX = LT_PRITEMX.

  IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
    PV_CHK_ERR = ABAP_TRUE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LINE_2340
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_2340
*&      <-- GS_BOTTOM_DISP
*&---------------------------------------------------------------------*
FORM SET_LINE_2340  USING    PS_2330 TYPE ZGTPPT2330
                                   PS_MAIN TYPE ZGTPPT2340
                                   PV_MEINS TYPE MEINS
                    CHANGING PS_OUT LIKE GS_BOTTOM_DISP.

  DATA : LV_GONG_NM TYPE ZEDT0011-GONG_NM.
  DATA : LS_ORDSYVAL TYPE ZGTCVORDSYVAL.
  DATA : LV_EBELN TYPE EBELN.
  DATA : LV_OBJNR TYPE JEST-OBJNR.
  DATA : LV_USER_LINE TYPE BSVX-STTXT.

* 오더번호
  PS_OUT-VBELN = PS_2330-DMORD.
  __ALPHA_OUT PS_OUT-VBELN.
* 품목
  PS_OUT-POSNR = PS_2330-DMLINE.
* 오더타입
  PS_OUT-ORDTY = PS_2330-DMORDTY.
* 공정
  PS_OUT-GONG_CD = PS_2330-GONG_CD.
* 공정명
  IF PS_OUT-GONG_CD = 'SHE'. " 쉬스공정만 이름을 바꿔서 설정
    PS_OUT-GONG_NM = '피복'.
  ELSE.
    CLEAR LV_GONG_NM.
    SELECT SINGLE GONG_NM FROM ZEDT0011
      INTO PS_OUT-GONG_NM
     WHERE GONG_CD = PS_OUT-GONG_CD.
  ENDIF.
* 공정연번
  PS_OUT-GONG_SEQ = PS_2330-GONG_SEQ.

* 제품번호
  PS_OUT-MATNR = PS_MAIN-MATNR.
*  제품내역
  PS_OUT-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = PS_OUT-MATNR ).

  PS_OUT-ZSPECNO = PS_2330-ZSPECNO.

* 색상
* 조달유형
  READ TABLE GT_CVMVAL INTO DATA(LS_CVMVAL) WITH KEY MATNR = PS_OUT-MATNR.
  IF SY-SUBRC EQ 0.
    IF LS_CVMVAL-COLORBASE IS NOT INITIAL.
      PS_OUT-COLOR = LS_CVMVAL-COLORBASE.
    ENDIF.

    PS_OUT-BESKZ = LS_CVMVAL-BESKZ.
    CASE PS_OUT-BESKZ.
      WHEN 'E' OR 'X'.
        PS_OUT-TEXT01 = '자작'.
      WHEN OTHERS.
        PS_OUT-TEXT01 = '외주'.
    ENDCASE.
  ENDIF.
*  수량
  PS_OUT-KLMENG = ( PS_MAIN-INLENGTH * PS_MAIN-INFACTOR ) +  PS_MAIN-CLENGTH.
* 조장
  PS_OUT-INLENGTH = PS_MAIN-INLENGTH.
* 기본단위
  PS_OUT-MEINS = PV_MEINS.
* 조장수
  PS_OUT-INFACTOR = PS_MAIN-INFACTOR.
* 작업여장
  PS_OUT-ADLENGTH = PS_MAIN-CLENGTH.
* 드럼
* 드럼규격
* 생산오더
  CASE PS_MAIN-ORDTY.
    WHEN 'PRD'.
      PS_OUT-ORDNR = PS_MAIN-ORDNR.
* 상태

      CLEAR LS_ORDSYVAL.
      READ TABLE GT_ORDSYVAL INTO LS_ORDSYVAL WITH KEY AUFNR = PS_OUT-ORDNR.
*      SELECT SINGLE * FROM ZGTCVORDSYVAL
*        INTO LS_ORDSYVAL
*       WHERE AUFNR = PS_OUT-ORDNR.
      IF SY-SUBRC EQ 0.
        IF LS_ORDSYVAL-TERKZ = '7'.
          PS_OUT-CHK_PROC = ABAP_TRUE.
          PS_OUT-GSTRP = LS_ORDSYVAL-GSTRP.
          PS_OUT-GLTRP = LS_ORDSYVAL-GLTRP.
        ENDIF.

        IF LS_ORDSYVAL-DLFL = ABAP_TRUE OR
          LS_ORDSYVAL-LKD = ABAP_TRUE OR
          LS_ORDSYVAL-TECO = ABAP_TRUE OR
          LS_ORDSYVAL-CLSD = ABAP_TRUE.
          PS_OUT-ORD_STAT = '삭제'.
        ELSEIF LS_ORDSYVAL-PDLV = ABAP_TRUE OR
          LS_ORDSYVAL-DLV = ABAP_TRUE.
          PS_OUT-ORD_STAT = '입고'.
        ELSEIF LS_ORDSYVAL-PCNF = ABAP_TRUE OR
          LS_ORDSYVAL-CNF = ABAP_TRUE.
          PS_OUT-ORD_STAT = '진행중'.
        ELSEIF LS_ORDSYVAL-REL = ABAP_TRUE.
          PS_OUT-ORD_STAT = '릴리즈'.
        ELSE.
          PS_OUT-ORD_STAT = '생성'.
        ENDIF.

* 생성과 릴리즈 상태시 payoff 확인
        CASE PS_OUT-ORD_STAT.
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

            FIND ALL OCCURRENCES OF 'PAYO' IN LV_USER_LINE MATCH COUNT FINAL(LV_LINE).
            IF LV_LINE > 0. " Patoff 상태일지 작업중으로 변경
              PS_OUT-ORD_STAT = '진행중'.
            ENDIF.
        ENDCASE.
      ENDIF.

      PS_OUT-SNOTE = ICON_DISPLAY_TEXT.
    WHEN 'PO'.
      CLEAR LV_EBELN.
      LV_EBELN = PS_OUT-EBELN = PS_MAIN-ORDNR.
      __ALPHA_OUT PS_OUT-EBELN .
      PS_OUT-EBELP = PS_MAIN-POSNR + 0.

      SELECT SINGLE A~EBELN, A~EBELP, A~LOEKZ, B~EINDT, D~NAME1 AS PR_NAME1
        FROM EKPO AS A
        INNER JOIN EKET AS B ON B~EBELN = A~EBELN
                                     AND B~EBELP = A~EBELP
        INNER JOIN EKKO AS C ON C~EBELN = A~EBELN
        INNER JOIN LFA1 AS D ON D~LIFNR = C~LIFNR
       WHERE A~EBELN = @LV_EBELN
          AND A~EBELP = @PS_OUT-EBELP
         INTO @DATA(LS_EKPO).
      IF SY-SUBRC EQ 0.
        PS_OUT-CHK_PROC = ABAP_TRUE.
        PS_OUT-ORD_STAT = '발주'.
        PS_OUT-EINDT =  LS_EKPO-EINDT.
        PS_OUT-PR_NAME1 =  LS_EKPO-PR_NAME1.
      ENDIF.

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LINE_2330
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_2330
*&      <-- GS_BOTTOM_DISP
*&---------------------------------------------------------------------*
FORM SET_LINE_2330  USING    PS_MAIN TYPE ZGTPPT2330
                    CHANGING PS_OUT LIKE GS_BOTTOM_DISP.

  DATA : LV_GONG_NM TYPE ZEDT0011-GONG_NM.
  DATA : LS_ORDSYVAL TYPE ZGTCVORDSYVAL.
  DATA : LV_EBELN TYPE EBELN.
  DATA : LS_TOPMAT TYPE CSTMAT.
  DATA : LT_STB TYPE TABLE OF STPOX.
  DATA : LT_CSCMAT TYPE TABLE OF CSCMAT.

* 오더번호
  PS_OUT-VBELN = PS_MAIN-DMORD.
  __ALPHA_OUT PS_OUT-VBELN.
* 품목
  PS_OUT-POSNR = PS_MAIN-DMLINE.
* 오더타입
  PS_OUT-ORDTY = PS_MAIN-DMORDTY.
* 공정
  PS_OUT-GONG_CD = PS_MAIN-GONG_CD.
* 공정명
  IF PS_OUT-GONG_CD = 'SHE'. " 쉬스공정만 이름을 바꿔서 설정
    PS_OUT-GONG_NM = '피복'.
  ELSE.
    SELECT SINGLE GONG_NM FROM ZEDT0011
      INTO PS_OUT-GONG_NM
     WHERE GONG_CD = PS_OUT-GONG_CD.
  ENDIF.
* 공정연번
  PS_OUT-GONG_SEQ = PS_MAIN-GONG_SEQ.

* 제품번호
  PS_OUT-MATNR = PS_MAIN-MATNR.
*  제품내역
  PS_OUT-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = PS_OUT-MATNR ).

  PS_OUT-ZSPECNO = PS_MAIN-ZSPECNO.

* 색상
* 조달유형
  READ TABLE GT_CVMVAL INTO DATA(LS_CVMVAL) WITH KEY MATNR = PS_OUT-MATNR.
  IF SY-SUBRC EQ 0.
    IF LS_CVMVAL-COLORBASE IS NOT INITIAL.
      PS_OUT-COLOR = LS_CVMVAL-COLORBASE.
    ENDIF.

    PS_OUT-BESKZ = LS_CVMVAL-BESKZ.
    CASE PS_OUT-BESKZ.
      WHEN 'E' OR 'X'.
        PS_OUT-TEXT01 = '자작'.
      WHEN OTHERS.
        PS_OUT-TEXT01 = '외주'.
    ENDCASE.
  ENDIF.
*  수량
  PS_OUT-KLMENG = PS_MAIN-INLENGTH * PS_MAIN-INFACTOR.
* 조장
  PS_OUT-INLENGTH = PS_MAIN-INLENGTH.
* 기본단위
  PS_OUT-MEINS = PS_MAIN-MEINS.
* 조장수
  PS_OUT-INFACTOR = PS_MAIN-INFACTOR.
* 드럼
* 드럼규격
* 생산오더
* 하위 반제품 확인



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BOTTOM_SCREEN_WIDTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BOTTOM_SCREEN_WIDTH .

  IF GV_CHK_DISP_ENDITEM IS INITIAL.
    GO_SPLITTER2->SET_COLUMN_WIDTH(
      EXPORTING
        ID                = 1                 " Column ID
        WIDTH             = 100                 " NPlWidth
      EXCEPTIONS
        CNTL_ERROR        = 1                " See CL_GUI_CONTROL
        CNTL_SYSTEM_ERROR = 2                " See CL_GUI_CONTROL
        OTHERS            = 3
    ).
  ELSE.
    GO_SPLITTER2->SET_COLUMN_WIDTH(
      EXPORTING
        ID                = 1                 " Column ID
        WIDTH             = 0                 " NPlWidth
      EXCEPTIONS
        CNTL_ERROR        = 1                " See CL_GUI_CONTROL
        CNTL_SYSTEM_ERROR = 2                " See CL_GUI_CONTROL
        OTHERS            = 3
    ).
  ENDIF.
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
      I_INCLNAME             = 'ZGTPPR2270TOP'
      I_INTERNAL_TABNAME     = 'GS_BOTTOM_DISP'
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
      IT_DATA         = GT_BOTTOM_DISP
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
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0101 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'COLOR'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'COLOR'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상'(F02).
    <LS_FCAT>-COL_POS = 10.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.

  ENDIF.

  READ TABLE GT_FIELDCAT_0101 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'TEXT01'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'TEXT01'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조달유형'(F27).
    <LS_FCAT>-COL_POS = 12.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.


  READ TABLE GT_FIELDCAT_0101 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'DRUM'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'DRUM'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '드럼'(F28).
    <LS_FCAT>-COL_POS = 18.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.

  ENDIF.

  READ TABLE GT_FIELDCAT_0101 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'DRUM_SPEC'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'DRUM_SPEC'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '드럼규격'(F29).
    <LS_FCAT>-COL_POS = 19.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0101 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'ORD_STAT'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ORD_STAT'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '상태'(F30).
    <LS_FCAT>-COL_POS = 21.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0101 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'CHK_PROC'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'CHK_PROC'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '일정수립'(F31).
    <LS_FCAT>-COL_POS = 22.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0101 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'CHK_PROC'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'CHK_PROC'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 30.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  LOOP AT GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    <LS_FCAT>-TABNAME = 'GT_BOTTOM_DISP'.
    <LS_FCAT>-COL_OPT = ABAP_TRUE.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'SEQNO' OR 'CHK_PROC' OR 'BESKZ' OR 'ORDTY'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'(F32).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더품목'(F33).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GONG_CD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정'(F34).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GONG_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정명'(F35).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GONG_SEQ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정연번'(F36).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-CONVEXIT = 'ALPHA'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품번호'(F18).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품명'(F10).
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
      WHEN 'KLMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수량'(F08).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수량'(F06).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기본단위'(F13).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(F07).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'ADLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업여장'(F37).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'ORDNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더'(F38).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GSTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시작일'(F39).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GLTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '종료일'(F40).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'SNOTE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업특기사항'(F41).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'EBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매오더번호'(F42).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'EBELP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매오더품목'(F43).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'EINDT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품예정일'(F44).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PR_NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공급업체명'(F45).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZSPECNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SPEC NO'(F67).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
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


  LOOP AT GT_BOTTOM_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    REFRESH LT_CELLTAB.
    LOOP AT GT_FIELDCAT_0101 INTO DATA(LS_FCAT).
      CASE LS_FCAT-FIELDNAME.
        WHEN 'VBELN' OR 'POSNR' OR 'GONG_CD' OR 'GONG_NM' OR 'GONG_SEQ' OR 'MATNR' OR 'MAKTX' OR
          'COLOR' OR 'TEXT01' OR 'ZSPECNO'.
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
          LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_KEY.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
        WHEN 'ADLENGTH'.
          IF <LS_MAIN>-ORDNR IS INITIAL AND <LS_MAIN>-EBELN IS INITIAL. " 오더 미존재시만 입력가능
            CLEAR LS_CELLTAB.
            LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
            LS_CELLTAB-STYLE = ALV_STYLE_ENABLED.
            INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
          ENDIF.
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
      IT_OUTTAB            = GT_BOTTOM_DISP
      IT_SORT              = GT_SORT_0101
      IT_FIELDCATALOG      = GT_FIELDCAT_0101.

  GO_GRID_0101->SET_READY_FOR_INPUT( 1 ).

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0101->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0101->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

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
                            USING : 1 'SEQNO'  'X' '' '',
                                       2 'VBELN'  'X' '' '',
                                       3 'POSNR'  'X' '' ''.

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
*& Form SET_OBJECT_GRID_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0102 .

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
  GS_LAYOUT_0102-SEL_MODE   = 'D'.
  GS_LAYOUT_0102-STYLEFNAME = 'CELLTAB'.

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
      I_INCLNAME             = 'ZGTPPR2270TOP'
      I_INTERNAL_TABNAME     = 'GS_BOTTOM2'
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
      IT_DATA         = GT_BOTTOM_DISP2
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0102 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'COLOR'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0102 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'COLOR'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상'(F02).
    <LS_FCAT>-COL_POS = 6.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0102 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'TEXT01'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0102 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'TEXT01'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조달유형'(F27).
    <LS_FCAT>-COL_POS = 9.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0102 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'PRC_STAT'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0102 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'PRC_STAT'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '진행상태'(F46).
    <LS_FCAT>-COL_POS = 18.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  LOOP AT GT_FIELDCAT_0102 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    <LS_FCAT>-TABNAME = 'GT_BOTTOM_DISP2'.
    <LS_FCAT>-COL_OPT = ABAP_TRUE.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'GONG_SEQ' OR 'BESKZ' OR 'ZWKREQ' OR 'PRC_STAT'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'GONG_CD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정'(F34).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GONG_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정명'(F35).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재번호'(F47).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재명'(F48).
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
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '표준조장'(F49).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'BMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '이론소요량'(F50).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(F07).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'PSTTR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시작일(계획)'(F51).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'PEDTR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '종료일(계획)'(F52).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'PLNUM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획오더'(F53).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'GSMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획량'(F54).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획 B/N'(F55).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업지시량'(F56).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE03'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업지시 B/N'(F57).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE04'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고예정량'(F58).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE05'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '현 재고량'(F59).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'DISP_PO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매오더'(F60).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MENGE06'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '임가공 발주량'(F61).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE07'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '임가공입고예정량'(F62).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE08'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '반제품사급출고예정량'(F66).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'ZSPECNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SPEC NO'(F67).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'MENGE09'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수작업지시 B/N'(F72).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE10'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수작업지시량'(F73).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0102 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.


  LOOP AT GT_BOTTOM_DISP2 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    REFRESH LT_CELLTAB.

    LOOP AT GT_FIELDCAT_0102 INTO DATA(LS_FCAT).
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
        WHEN 'MENGE09' OR 'MENGE10'.
*        수작업지시B/N, 수작업지시량 파랑
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = LS_FCAT-FIELDNAME.
          LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_HEADING.
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
*& Form EXCLUDE_OF_TOOLBAR_GRID_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0102 .

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
*& Form SET_SORTTAB_GRID_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0102 .

  REFRESH GT_SORT_0102.
  PERFORM SET_SORT_TAB TABLES GT_SORT_0102
                            USING : 1 'GONG_SEQ'  'X' '' ''.

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
      IT_OUTTAB            = GT_BOTTOM_DISP2
      IT_SORT              = GT_SORT_0102
      IT_FIELDCATALOG      = GT_FIELDCAT_0102.

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

  LT_MATNR = VALUE #( FOR LW_MAIN IN GT_2330 WHERE ( MATNR IS NOT INITIAL
                                                                        AND  GONG_SEQ = '01'  )
                               ( SIGN = 'I' OPTION = 'EQ' LOW = LW_MAIN-MATNR ) ).

  IF LT_MATNR IS INITIAL.
    LT_MATNR = VALUE #( FOR LW_DISP_MAIN IN GT_MAIN_DISP WHERE ( MATNR IS NOT INITIAL )
                                 ( SIGN = 'I' OPTION = 'EQ' LOW = LW_DISP_MAIN-MATNR ) ).
  ENDIF.

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

  SORT GT_PRODUCT_BOM BY INDEX DESCENDING.

  READ TABLE GT_PRODUCT_BOM INTO DATA(LS_TEMP) INDEX 1.

  MOVE-CORRESPONDING LS_TEMP-T_BOM TO GT_BASE_GONG_SEQ.

  LOOP AT GT_PRODUCT_BOM INTO DATA(LS_CHK_DATA) WHERE MATNR NE LS_TEMP-MATNR.
    LOOP AT LS_CHK_DATA-T_BOM INTO DATA(LS_CHK_GONG).
      READ TABLE GT_BASE_GONG_SEQ ASSIGNING FIELD-SYMBOL(<LS_CHK_GONG>) WITH KEY GONG_CD = LS_CHK_GONG-GONG_CD .
      IF SY-SUBRC NE 0. " 공정 미존재시 공정 어팬드
        READ TABLE GT_BASE_GONG_SEQ INTO DATA(LS_CHK_IDX) WITH KEY GONG_SEQ = LS_CHK_GONG-GONG_SEQ.
        IF SY-SUBRC EQ 0.
          INSERT LS_CHK_GONG INTO GT_BASE_GONG_SEQ INDEX SY-TABIX.
        ELSE.
          INSERT LS_CHK_GONG INTO GT_BASE_GONG_SEQ INDEX 2.
        ENDIF.

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

  LV_GONG_SEQ = '02'.

  LOOP AT GT_BASE_GONG_SEQ ASSIGNING FIELD-SYMBOL(<LS_INPUT>).
    CASE <LS_INPUT>-GONG_CD.
      WHEN 'REW'.
        <LS_INPUT>-GONG_SEQ = '01'.
      WHEN 'SHE'.
        <LS_INPUT>-GONG_SEQ = '02'.
      WHEN OTHERS.
        ADD 1 TO LV_GONG_SEQ.
        <LS_INPUT>-GONG_SEQ = LV_GONG_SEQ.
    ENDCASE.
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

  DELETE LT_SEQ_ROUTING WHERE MATNR = PV_MATNR.

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

  LV_GONG_SEQ = '02'.

  LOOP AT LT_BASE_GONG_SEQ ASSIGNING <LS_INPUT>.
    CASE <LS_INPUT>-GONG_CD.
      WHEN 'REW'.
        <LS_INPUT>-GONG_SEQ = '01'.
      WHEN 'SHE'.
        <LS_INPUT>-GONG_SEQ = '02'.

      WHEN OTHERS.
        ADD 1 TO LV_GONG_SEQ.
        <LS_INPUT>-GONG_SEQ = LV_GONG_SEQ.
    ENDCASE.
  ENDLOOP.

  SORT LT_BASE_GONG_SEQ BY GONG_SEQ.

* 완제품 공정의 대상이 임가공 대상일때 임가공 반제품은 삭제, 자작 반제품 만날때까지
  READ TABLE LT_BASE_GONG_SEQ INTO DATA(LS_CHK_IMGAGONG) WITH KEY GONG_SEQ = '02'.
  IF SY-SUBRC NE 0. "피복공정 미존재시 권취 자재기준
    READ TABLE LT_BASE_GONG_SEQ INTO LS_CHK_IMGAGONG WITH KEY GONG_SEQ = '01'.
  ENDIF.
* 완제품 공정당 자재는 한건 이므로 리드로
  CLEAR LS_MATNR.
  READ TABLE LS_CHK_IMGAGONG-T_MATNR INTO LS_MATNR INDEX 1.
  IF ( LS_MATNR-BESKZ = 'F' AND LS_MATNR-SOBSL = '30' ) OR
    ( LS_MATNR-BESKZ = 'X' AND LS_MATNR-SOBSL = '30' ).
* 외주로 판단, 공정을 순차적으로 내리면서 해당 공정 반제품에 외주임가공이 아닌 반제품이 존재할시 중지
    LV_GONG_SEQ = '03'.
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
*& Form PROC_REQUEST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_REQUEST .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LT_MOSU LIKE GT_MAIN_DISP.
  DATA : LT_2330 TYPE TABLE OF ZGTPPT2330.
  DATA : LS_2330 TYPE ZGTPPT2330.
  DATA : LS_2330_SUB TYPE ZGTPPT2330.
  DATA : LV_VBELN TYPE VBELN.
  DATA : LV_MON(2) TYPE N.
  DATA : LV_SUB_MATNR TYPE MATNR.
  DATA : LV_SUB_MENGE TYPE MENGE_D.
  DATA : BEGIN OF LS_CHK_MAX_ZWKREQ,
           ZWKREQ   TYPE ZGTPPT2330-ZWKREQ,
           SEQNO(6) TYPE C,
         END OF LS_CHK_MAX_ZWKREQ.
  DATA : LT_CHK_MAX_ZWKREQ LIKE TABLE OF LS_CHK_MAX_ZWKREQ.
  DATA : LV_INLENGTH TYPE ZGTPPT2000-INLENGTH.
  DATA : LV_INFACTOR TYPE ZGTPPT2000-INFACTOR.

  DATA : LV_MAX_SEQ(6) TYPE N.


  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  IF LT_ROW[] IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT LT_ROW INTO LS_ROW.
    READ TABLE GT_MAIN_DISP INTO DATA(LS_MAIN) INDEX LS_ROW-INDEX.
    IF LS_MAIN-CHK_PROC = ABAP_TRUE OR LS_MAIN-CHK_OEM = ABAP_TRUE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '작업요청이 이미 되었거나 OEM 대응 처리된 내역이 선택 되었습니다.'(E04).
      RETURN.
    ENDIF.

* 작업 요청 시 주문 변경 확인
    IF LS_MAIN-GCATG = '판매오더'.
      CLEAR LV_VBELN.
      LV_VBELN = LS_MAIN-VBELN.
      __ALPHA_INPUT LV_VBELN.

      CLEAR : LV_INLENGTH, LV_INFACTOR.

      ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
        EXPORTING
          IV_VBELN   = LV_VBELN
          IV_POSNR   = LS_MAIN-POSNR
        IMPORTING
          EV_ZGTEINDLEN = LV_INLENGTH
          EV_ZGTEFACTOR = LV_INFACTOR ).

      IF NOT ( LV_INLENGTH = LS_MAIN-ZGTEINDLEN AND
               LV_INFACTOR = LS_MAIN-ZGTEFACTOR ).
* 변경사항입 있다면 오류 처리
        MESSAGE S006 DISPLAY LIKE 'E' WITH 'S/O' LS_MAIN-REQ_FACTOR '주문 정보가 변경되었습니다. 재 조회 후 진행해 주세요.'(e47).
        RETURN.
      ENDIF.


    ENDIF.

    APPEND LS_MAIN TO LT_MOSU.
  ENDLOOP.

  IF LT_MOSU IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '작업요청 할 수 있는 주문이 없습니다.'(E02).
    RETURN.
  ENDIF.

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

*
  LOOP AT LT_MOSU INTO DATA(LS_MOSU).
    CLEAR LS_2330.
    LS_2330-WERKS = P_WERKS.
    LS_2330-SPGCD = P_SPGCD.
    LS_2330-RQMON = P_SPMON.
    ADD 1 TO LV_MAX_SEQ.
    LS_2330-ZWKREQ = SY-DATUM+2(6) && LV_MAX_SEQ.
    LS_2330-ZDISTRIB = '1'.
    SELECT SINGLE * FROM ZGTCVMSTVAL
      INTO @DATA(LS_CHK_MSTVAL)
     WHERE WERKS = @P_WERKS
       AND MATNR = @LS_MOSU-MATNR.
    IF SY-SUBRC EQ 0.
      LS_2330-GONG_CD = LS_CHK_MSTVAL-PDCAPROCCODE.
    ELSE.
      LS_2330-GONG_CD = 'REW'.
    ENDIF.
    LS_2330-MATNR = LS_MOSU-MATNR.
    LS_2330-ZSPECNO = LS_MOSU-ZSPECNO.
    CASE LS_MOSU-GCATG.
      WHEN '판매오더'.
        LV_VBELN = LS_MOSU-VBELN.
        __ALPHA_INPUT LV_VBELN.
        LS_2330-DMORD = LV_VBELN.
        LS_2330-DMORDTY = 'SO'.
      WHEN OTHERS.
        LS_2330-DMORD = LS_MOSU-VBELN.
        LS_2330-DMORDTY = 'PRD'.
    ENDCASE.
    LS_2330-DMLINE = LS_MOSU-POSNR + 0.
* 작업요청월 + '01'
    LS_2330-PSTTR = P_SPMON && '01'.
* 작업요청월 + 말일
    LS_2330-PEDTR = LS_2330-PSTTR.
    PERFORM GET_LAST_DAY_OF_MONTH CHANGING LS_2330-PEDTR.

    LS_2330-MEINS = LS_MOSU-MEINS.
    LS_2330-INLENGTH = LS_MOSU-ZGTEINDLEN.
    LS_2330-INFACTOR = LS_MOSU-ZGTEFACTOR.
    LS_2330-BMENG = LS_MOSU-ZGTEINDLEN * LS_MOSU-ZGTEFACTOR.
    LS_2330-GSMNG = LS_2330-BMENG.
    LS_2330-GONG_SEQ = '01'.
* 완제품 봄조회
*  공정명이 'SHE' 피복이면서 조달 유형 'E' 또는 'X' 인 경우,
*  피복여부 SUB_GONG = 'X' 로 입력하고 피복 작업 요청 생성
*    PERFORM GET_SUB_GONG USING LS_MOSU-MATNR LS_2330-BMENG
*                             CHANGING LS_2330-SUB_GONG LV_SUB_MATNR LV_SUB_MENGE.

    APPEND LS_2330 TO LT_2330.


* 피복여부 'X'  일시 피복에 대한 작업요청 생성
*    IF LS_2330-SUB_GONG = ABAP_TRUE.
*      CLEAR LS_2330_SUB.
*      LS_2330_SUB-WERKS = P_WERKS.
*      LS_2330_SUB-SPGCD = P_SPGCD.
*      LS_2330_SUB-RQMON = P_SPMON.
*      ADD 1 TO LV_MAX_SEQ.
*      LS_2330_SUB-ZWKREQ = SY-DATUM+2(6) && LV_MAX_SEQ.
*      LS_2330_SUB-ZDISTRIB = '1'.
*      LS_2330_SUB-GONG_CD = 'SHE'.
*      LS_2330_SUB-MATNR = LV_SUB_MATNR.
*      LS_2330_SUB-DMORD = LS_2330-DMORD.
*      LS_2330_SUB-DMLINE = LS_2330-DMLINE.
*      LS_2330_SUB-DMORDTY = LS_2330-DMORDTY.
** 권취 소요량 범주 "판매오더"의 경우 납품요청일 -2, 소요량 범주 "생산오더"의 경우 오더 시작일
** 권취 소요량 범주 "판매오더"의 경우 납품요청일 -1, 소요량 범주 "생산오더"의 경우 오더 종료일
*      CASE LS_MOSU-GCATG.
*        WHEN '판매오더'.
*          LS_2330_SUB-PSTTR = LS_MOSU-EDATU - 2.
*          LS_2330_SUB-PEDTR = LS_MOSU-EDATU - 1.
*        WHEN OTHERS.
*
*          SELECT SINGLE * FROM ZGTPPT2001
*            WHERE ORDNO = @LS_2330-DMORD
*              AND POSNR = @LS_2330-DMLINE
*            INTO @DATA(LS_2001).
*
*          LS_2330_SUB-PSTTR = LS_2001-GSTRP.
*          LS_2330_SUB-PEDTR = LS_2001-GLTRP.
*      ENDCASE.
*
*      LS_2330_SUB-MEINS = LS_MOSU-MEINS.
*      LS_2330_SUB-GSMNG = LV_SUB_MENGE.
*      LS_2330_SUB-INLENGTH = LV_SUB_MENGE.
*      LS_2330_SUB-INFACTOR = 1.
*      LS_2330_SUB-BMENG = LV_SUB_MENGE.
*      LS_2330_SUB-GONG_SEQ = '02'.
*
*      APPEND LS_2330_SUB TO LT_2330.
*
*    ENDIF.

  ENDLOOP.

  IF  LT_2330 IS NOT INITIAL.
    MODIFY ZGTPPT2330 FROM TABLE LT_2330.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '선택된 주문의 작업 요청중 오류 발생하였습니다.'(E03).
      RETURN.
    ENDIF.
  ENDIF.

  LOOP AT LT_ROW INTO LS_ROW.
    READ TABLE GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_ROW-INDEX.
    <LS_MAIN>-CHK_PROC = ABAP_TRUE.
  ENDLOOP.

  PERFORM GET_SET_REGISTERED_DATA.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  PERFORM REFRESH_GRID USING GO_GRID_0101.
  PERFORM REFRESH_GRID USING GO_GRID_0102.

  MESSAGE S006 WITH '선택된 주문의 작업 요청되었습니다.'(E38).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SUB_GONG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MOSU_MATNR
*&      <-- LS_2330_SUB_GONG
*&---------------------------------------------------------------------*
FORM GET_SUB_GONG  USING    PV_MATNR TYPE MATNR
                                 PV_BMENG
                   CHANGING PV_SUB_GONG
                                 PV_MATNR_SUB TYPE MATNR
                                 PV_SUB_MENGE TYPE MENGE_D.

  DATA : LT_STB TYPE TABLE OF STPOX.
  DATA : LV_EMENG TYPE STKO-BMENG.
  DATA : LV_EMENG2 TYPE STKO-BMENG.
  LV_EMENG = PV_BMENG.

  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      CAPID                 = 'PP01'
      DATUV                 = SY-DATUM
      EMENG                 = LV_EMENG
      MTNRV                 = PV_MATNR " 자재
      WERKS                 = P_WERKS " 플랜트
      MMORY                 = '0'
    TABLES
      STB                   = LT_STB
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

  SELECT * FROM ZGTCVMSTVAL
   FOR ALL ENTRIES IN @LT_STB
  WHERE WERKS = @P_WERKS
  AND MATNR = @LT_STB-IDNRK
  INTO TABLE @DATA(LT_MATNR_DETAIL).

  READ TABLE LT_MATNR_DETAIL INTO DATA(LS_MATNR_DETAIL) WITH KEY PDCAPROCCODE = 'SHE'.
  IF SY-SUBRC EQ 0.
    IF LS_MATNR_DETAIL-BESKZ = 'E' OR LS_MATNR_DETAIL-BESKZ = 'X'.
      PV_SUB_GONG = ABAP_TRUE.
      PV_MATNR_SUB = LS_MATNR_DETAIL-MATNR.
      READ TABLE LT_STB INTO DATA(LS_STB) WITH KEY IDNRK = LS_MATNR_DETAIL-MATNR.

      CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
        EXPORTING
          I_RTYPE     = '+'
          I_RUNIT     = 1
          I_VALUE     = LS_STB-MNGLG
        IMPORTING
          E_VALUE_RND = LV_EMENG2.

      PV_SUB_MENGE = LV_EMENG2.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP_BOTTOM_USING_GONG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_2330
*&---------------------------------------------------------------------*
FORM SET_DISP_BOTTOM_USING_GONG  USING    PS_2330 TYPE ZGTPPT2330.

  DATA : LT_2340 TYPE TABLE OF ZGTPPT2340.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : BEGIN OF LS_CHK_EKPO,
           EBELN TYPE EBELN,
           EBELP TYPE EBELP,
         END OF LS_CHK_EKPO.
  DATA : LT_CHK_EKPO LIKE TABLE OF LS_CHK_EKPO.
  DATA : LT_ORDSYVAL_ETC TYPE TABLE OF ZGTCVORDSYVAL.

  DATA : LV_OBJNR TYPE JEST-OBJNR.
  DATA : LV_USER_LINE TYPE BSVX-STTXT.
  DATA : LV_STATUS(10).
  DATA : LV_MENGE TYPE MENGE_D.
  DATA : LV_MENGE2 TYPE MENGE_D.

  REFRESH LT_ORDSYVAL_ETC.
  LT_ORDSYVAL_ETC = VALUE #( FOR LW_ORDSYVAL IN GT_ORDSYVAL_ETC WHERE ( MATNR = PS_2330-MATNR )
                                           ( CORRESPONDING #( LW_ORDSYVAL ) ) ).

  GS_BOTTOM2-GONG_SEQ = PS_2330-GONG_SEQ.
  GS_BOTTOM2-GONG_CD = GS_BASE_GONG_SEQ-GONG_CD.
  GS_BOTTOM2-GONG_NM = GS_BASE_GONG_SEQ-GONG_NM.
  READ TABLE GS_BASE_GONG_SEQ-T_MATNR INTO DATA(LS_CHK_MATNR) WITH KEY MATNR = PS_2330-MATNR.

  GS_BOTTOM2-MATNR = PS_2330-MATNR.
  GS_BOTTOM2-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = PS_2330-MATNR ).

  READ TABLE GT_CVMVAL INTO DATA(LS_CVMVAL) WITH KEY MATNR = PS_2330-MATNR.
  IF SY-SUBRC EQ 0.
    IF LS_CVMVAL-COLORBASE IS NOT INITIAL.
      GS_BOTTOM2-COLOR = LS_CVMVAL-COLORBASE.
    ENDIF.

    GS_BOTTOM2-BESKZ = LS_CVMVAL-BESKZ.
    CASE GS_BOTTOM2-BESKZ.
      WHEN 'E' OR 'X'.
        GS_BOTTOM2-TEXT01 = '자작'.
      WHEN OTHERS.
        GS_BOTTOM2-TEXT01 = '외주'.
    ENDCASE.
  ENDIF.

* 표준조장
  GS_BOTTOM2-INLENGTH = PS_2330-INLENGTH.
* 이론소요량
  GS_BOTTOM2-BMENG = PS_2330-BMENG.
* 조장수
  GS_BOTTOM2-INFACTOR = PS_2330-INFACTOR.
* 시작일(계획)
  GS_BOTTOM2-PSTTR = PS_2330-PSTTR.
* 종료일(계획)
  GS_BOTTOM2-PEDTR = PS_2330-PEDTR.
* 계획오더
  GS_BOTTOM2-PLNUM = PS_2330-PLNUM.
* 작업요청번호
  GS_BOTTOM2-ZWKREQ = PS_2330-ZWKREQ.
* 계획량
  GS_BOTTOM2-GSMNG = PS_2330-GSMNG.
* 계획 B/N(조장수)
  GS_BOTTOM2-MENGE01 = PS_2330-INFACTOR.

  LT_2340 = VALUE #( FOR LW_2340 IN GT_2340 WHERE ( ZWKREQ = PS_2330-ZWKREQ )
                            ( CORRESPONDING #( LW_2340 ) ) ).
  GS_BOTTOM2-PRC_STAT = '작업요청'.

* 반제품 사급 투입수량
  CLEAR  GS_RESB_PO.
  READ TABLE GT_RESB_PO INTO GS_RESB_PO WITH KEY MATNR = PS_2330-MATNR.
  IF SY-SUBRC EQ 0.
    GS_BOTTOM2-MENGE08 = GS_RESB_PO-BDMNG.
  ENDIF.

** 현재고량
  SELECT * FROM ZGTCV_STOCKVAL
    INTO TABLE @DATA(LT_STOCKVAL)
   WHERE WERKS = @P_WERKS
     AND MATNR = @PS_2330-MATNR.

  LOOP AT LT_STOCKVAL INTO DATA(LS_AUFNR_JEGO).
    GS_BOTTOM2-MENGE05 = GS_BOTTOM2-MENGE05 + LS_AUFNR_JEGO-LABST + LS_AUFNR_JEGO-INSME + LS_AUFNR_JEGO-SPEME.
  ENDLOOP.

* 스펙넘버
  IF PS_2330-GONG_CD = 'SHE'. " 쉬스공정에만 스펙넘버 추가
    GS_BOTTOM2-ZSPECNO = PS_2330-ZSPECNO.
  ENDIF.

  LOOP AT LT_ORDSYVAL_ETC INTO DATA(LS_ORDSYVAL_ETC).
    GS_BOTTOM2-MENGE09 = GS_BOTTOM2-MENGE09 + LS_ORDSYVAL_ETC-MILLCAFACTOR.
    GS_BOTTOM2-MENGE10 = GS_BOTTOM2-MENGE10 + ( LS_ORDSYVAL_ETC-PSAMG + LS_ORDSYVAL_ETC-PSMNG ).
  ENDLOOP.

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
    GS_BOTTOM2-PRC_STAT = '임가공발주'.
    GS_BOTTOM2-DISP_PO = ICON_LIST.
    SELECT SINGLE SUM( B~MENGE ) AS MENGE
      FROM @LT_CHK_EKPO AS A
      INNER JOIN EKPO AS B ON B~EBELN = A~EBELN
                                AND B~EBELP = A~EBELP
     WHERE B~LOEKZ = ' '
       INTO @GS_BOTTOM2-MENGE06.

    SELECT SINGLE SUM( CASE B~BWART WHEN '101' THEN B~MENGE
                                                    WHEN '102' THEN B~MENGE * -1
                                                    END ) AS BWART
      FROM @LT_CHK_EKPO AS A
      INNER JOIN MSEG AS B ON B~EBELN = A~EBELN
                                  AND B~EBELP = A~EBELP
     WHERE B~BWART IN ( '101', '102' )
       INTO @LV_MENGE.
*  임가공 입고예정량(임가공발주량  - 임가공 입고량
    GS_BOTTOM2-MENGE07 = GS_BOTTOM2-MENGE06 - LV_MENGE.

  ENDIF.

  CLEAR GS_BOTTOM2-MENGE02.
  CLEAR GS_BOTTOM2-MENGE04.

  LOOP AT LT_2340 INTO DATA(LS_2340) WHERE ORDTY = 'PRD'.
** 작업지시량
    GS_BOTTOM2-MENGE02 = GS_BOTTOM2-MENGE02 +
                                       ( ( LS_2340-INLENGTH * LS_2340-INFACTOR ) + LS_2340-CLENGTH ).
** 작업지시B/N
    ADD LS_2340-INFACTOR TO GS_BOTTOM2-MENGE03.

    READ TABLE GT_ORDSYVAL INTO DATA(LS_ORDSYVAL) WITH KEY AUFNR = LS_2340-ORDNR.
** 입고예정량( 작업지시량 - 입고량 )
    GS_BOTTOM2-MENGE04 = GS_BOTTOM2-MENGE04 + ( ( ( LS_2340-INLENGTH * LS_2340-INFACTOR ) + LS_2340-CLENGTH ) - LS_ORDSYVAL-WEMNG ).

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
          LS_ORDSYVAL-TERKZ = '7'.
          LV_STATUS = '작업지시'.
        ENDIF.
    ENDCASE.

    IF LV_STATUS = '생산진행'.
      GS_BOTTOM2-PRC_STAT = '생산진행'.
    ELSEIF LV_STATUS = '작업지시' AND GS_BOTTOM2-PRC_STAT NE '생산진행'.
      GS_BOTTOM2-PRC_STAT = '작업지시'.
    ENDIF.

  ENDLOOP.



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

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : BEGIN OF LS_DEL_ORDNO,
           DMORD  TYPE ZGTPPT2330-DMORD,
           DMLINE TYPE ZGTPPT2330-DMLINE,
         END OF LS_DEL_ORDNO.
  DATA : LT_DEL_ORDNO LIKE TABLE OF LS_DEL_ORDNO.

  CALL METHOD GO_GRID_0100->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  IF LT_ROW[] IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT LT_ROW INTO LS_ROW.
    READ TABLE GT_MAIN_DISP INTO DATA(LS_MAIN) INDEX LS_ROW-INDEX.
    IF LS_MAIN-CHK_PROC IS INITIAL.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '작업요청 되지 않은 내역이 선택 되었습니다.'(E06).
      RETURN.
    ENDIF.

    IF LS_MAIN-CHK_PROC = ABAP_TRUE AND LS_MAIN-CHK_OEM = ABAP_TRUE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH 'OEM 대응 처리된 내역이 선택 되었습니다.'(E07).
      RETURN.
    ENDIF.

    IF LS_MAIN-CHK_PROC = ABAP_TRUE.
      READ TABLE GT_BOTTOM_DISP INTO DATA(LS_CHK_MAIN) WITH KEY VBELN = LS_MAIN-VBELN
                                                                                           POSNR = LS_MAIN-POSNR.
      IF SY-SUBRC EQ 0 AND ( LS_CHK_MAIN-ORDNR IS NOT INITIAL OR LS_CHK_MAIN-EBELN IS NOT INITIAL ).
        MESSAGE S006 DISPLAY LIKE 'E' WITH '선택 작업 요청으로 진행된 작업 지시가 있습니다.'(E08)
                                                            '생산/임가공 오더 삭제를 먼저 진행해 주세요'(E09).
        RETURN.
      ENDIF.

    ENDIF.

    CLEAR LS_DEL_ORDNO.
    LS_DEL_ORDNO-DMORD = LS_MAIN-VBELN.
    LS_DEL_ORDNO-DMLINE = LS_MAIN-POSNR.

    APPEND LS_DEL_ORDNO TO LT_DEL_ORDNO.
  ENDLOOP.

  IF LT_DEL_ORDNO[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '작업요청 삭제할 대상이 없습니다.'(E10).
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '작업요청 삭제됩니다. 계속 진행 하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  SELECT * FROM ZGTPPT2330
    INTO TABLE @DATA(LT_2330_DEL)
     FOR ALL ENTRIES IN @LT_DEL_ORDNO
    WHERE WERKS = @P_WERKS
      AND SPGCD = @P_SPGCD
      AND RQMON = @P_SPMON
      AND DMORD = @LT_DEL_ORDNO-DMORD
      AND DMLINE = @LT_DEL_ORDNO-DMLINE.

  IF LT_2330_DEL[] IS NOT INITIAL.
    DELETE ZGTPPT2330 FROM TABLE LT_2330_DEL.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '선택된 주문의 작업요청 삭제중 오류 발생하였습니다.'(E11).
      RETURN.
    ENDIF.
  ENDIF.

  PERFORM GET_MAIN_DATA.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  PERFORM REFRESH_GRID USING GO_GRID_0101.
  PERFORM REFRESH_GRID USING GO_GRID_0102.

  MESSAGE S006 WITH '선택한 작업이 취소되었습니다.'(E12).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CRT_PRD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CRT_PRD .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LT_MOSU_MAIN LIKE GT_BOTTOM_DISP.
  DATA : LT_MOSU LIKE GT_2330.
  DATA : LT_MOSU_FUL LIKE GT_2330.
  DATA : LV_VBELN TYPE VBELN.
  DATA : LV_DMORD TYPE ZGTPPT2330-DMORD.
  DATA : LV_DMLINE TYPE ZGTPPT2330-DMLINE.
  DATA : LV_ORDNR TYPE ZGTPPT2340-ORDNR.
  DATA : LV_AUFNR TYPE AUFNR.
  DATA : LV_POSNR TYPE AFPO-POSNR.
  DATA : LV_TABIX TYPE I.

  DATA : LT_DEL_2340 TYPE TABLE OF ZGTPPT2340.
  DATA : LT_MODI_2330 TYPE TABLE OF ZGTPPT2330.
  DATA : LT_MODI_2340 TYPE TABLE OF ZGTPPT2340.
  DATA : LS_MODI_2340 TYPE ZGTPPT2340.
  DATA : LV_CHK_ERR.
  DATA : LV_MESSAGE(100).
  DATA : LV_MESSAGE2(100).

  CALL METHOD GO_GRID_0101->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  IF LT_ROW[] IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT LT_ROW INTO LS_ROW.
    READ TABLE GT_BOTTOM_DISP INTO DATA(LS_MAIN) INDEX LS_ROW-INDEX.
    IF LS_MAIN-TEXT01 = '외주' .
      MESSAGE S006 DISPLAY LIKE 'E' WITH '조달 외주 유형이 선택 되었습니다.'(E13).
      RETURN.
    ENDIF.

    IF LS_MAIN-ORDNR IS NOT INITIAL .
      IF LS_MAIN-ORD_STAT NE '삭제'.
      ENDIF.
    ENDIF.

    APPEND LS_MAIN TO LT_MOSU_MAIN.
  ENDLOOP.

* 선택된 라인정보로 오더 생성 테이블 구성
  LOOP AT LT_MOSU_MAIN INTO LS_MAIN.
    LV_DMLINE = LS_MAIN-POSNR.
    __ALPHA_INPUT LV_DMLINE.
    READ TABLE GT_2330 INTO DATA(LS_CHK_ORDTY) WITH KEY DMORD = LS_MAIN-VBELN
                                                                                     DMLINE = LV_DMLINE.
    IF SY-SUBRC NE 0.
      LV_VBELN = LS_MAIN-VBELN.
      __ALPHA_INPUT LV_VBELN.
      READ TABLE GT_2330 INTO LS_CHK_ORDTY WITH KEY DMORD = LV_VBELN
                                                                          DMLINE = LV_DMLINE.
    ENDIF.

    READ TABLE LT_MOSU_FUL TRANSPORTING NO FIELDS WITH KEY DMORD = LS_CHK_ORDTY-DMORD
                                                                                         DMLINE = LS_CHK_ORDTY-DMLINE.
    IF SY-SUBRC EQ 0. " 이미 적재되어 있으므로 건너 띄어준다.
      CONTINUE.
    ENDIF.

    REFRESH LT_MOSU.
    LT_MOSU = VALUE #( FOR LW_2330 IN GT_2330 WHERE ( DMORD = LS_CHK_ORDTY-DMORD
                                                                    AND   DMLINE = LS_CHK_ORDTY-DMLINE )
                                ( CORRESPONDING #( LW_2330 ) ) ).

    LOOP AT LT_MOSU ASSIGNING FIELD-SYMBOL(<LS_MOSU>).
      LV_TABIX = SY-TABIX.
      LV_ORDNR = <LS_MOSU>-DMORD.
      __ALPHA_OUT LV_ORDNR.

      READ TABLE GT_BOTTOM_DISP INTO LS_MAIN WITH KEY VBELN = LV_ORDNR
                                                                       POSNR = <LS_MOSU>-DMLINE
                                                                       GONG_CD = <LS_MOSU>-GONG_CD.
      IF SY-SUBRC EQ 0.
        IF LS_MAIN-ORDNR IS NOT INITIAL AND LS_MAIN-ORD_STAT EQ '삭제'.
          LV_AUFNR = LS_MAIN-ORDNR.
          __ALPHA_INPUT LV_AUFNR.
          READ TABLE GT_2340 INTO DATA(LS_2340) WITH KEY ORDNR = LV_AUFNR.
          IF SY-SUBRC EQ 0.
            APPEND LS_2340 TO LT_DEL_2340.
          ENDIF.
        ENDIF.
      ENDIF.


* 생산오더 생성을 위한 인터널테이블 구성.
      CLEAR LS_MODI_2340.
      LV_DMORD = <LS_MOSU>-DMORD.
      __ALPHA_OUT LV_DMORD.

      READ TABLE GT_BOTTOM_DISP INTO LS_MAIN WITH KEY VBELN = LV_DMORD
                                                                                POSNR = <LS_MOSU>-DMLINE
                                                                                GONG_SEQ = <LS_MOSU>-GONG_SEQ.
      IF SY-SUBRC EQ 0.
        PERFORM CRT_PRD_INFOR USING LS_MAIN <LS_MOSU> CHANGING LS_MODI_2340.
        APPEND LS_MODI_2340 TO LT_MODI_2340.
      ENDIF.
    ENDLOOP.

    IF LT_MOSU IS NOT INITIAL.
      APPEND LINES OF LT_MOSU TO LT_MOSU_FUL.
    ENDIF.

  ENDLOOP.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택한 사항으로 완제품 작업 지시 진행 하시겠습니까?'
    '작업확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  REFRESH GT_PRD_ORDERS.

  PERFORM SET_PROGRESS_INDICATOR USING '10' '완제품 생산오더 생성중..'.

  LOOP AT LT_MODI_2340 ASSIGNING FIELD-SYMBOL(<LS_MODI_2340>).

*      생성전 체크 " 생산버전 + 유효일자
    READ TABLE GT_2330 INTO DATA(LS_2330) WITH KEY ZWKREQ = <LS_MODI_2340>-ZWKREQ.

    PERFORM CRT_PRD_ORDER USING LS_2330 <LS_MODI_2340> CHANGING LV_CHK_ERR.

    IF LV_CHK_ERR = ABAP_TRUE.
      CLEAR LV_MESSAGE.
      LV_MESSAGE = LS_2330-DMORD && '/' && LS_2330-DMLINE.
      CONCATENATE '소요량' LV_MESSAGE '작업 요청에 대한 생산 오더 생성 중 오류가 발생 했습니다.'
                    INTO LV_MESSAGE SEPARATED BY SPACE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MESSAGE.
      RETURN.
    ENDIF.
*   포장재 지정 오류추가
    IF LV_CHK_ERR = 'P'.
      CLEAR LV_MESSAGE.
      LV_MESSAGE = LS_2330-DMORD && '/' && LS_2330-DMLINE.
      CONCATENATE 'S/O' LV_MESSAGE '에 대한 포장재 지정이 완료되지 않았습니다.'
                    INTO LV_MESSAGE SEPARATED BY SPACE.
      LV_MESSAGE2 = '영업 및 설계팀에 문의 바랍니다.'.
      MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MESSAGE LV_MESSAGE2.
      RETURN.
    ENDIF.

*   포장재 지정 오류추가
    IF LV_CHK_ERR = 'D'.
      CLEAR LV_MESSAGE.
      LV_MESSAGE = LS_2330-DMORD && '/' && LS_2330-DMLINE.
      CONCATENATE 'S/O' LV_MESSAGE '에 삭제된 포장재가 지정되었습니다.'
                    INTO LV_MESSAGE SEPARATED BY SPACE.
      LV_MESSAGE2 = '영업 및 설계팀에 문의 바랍니다.'.
      MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MESSAGE LV_MESSAGE2.
      RETURN.
    ENDIF.

    IF LS_2330-DMORDTY = 'SO'. "판매오더 일시 오더정보 연결
      CLEAR : LV_AUFNR, LV_POSNR.
      LV_AUFNR = <LS_MODI_2340>-ORDNR.
      LV_POSNR = <LS_MODI_2340>-POSNR + 0.
      UPDATE AUFK SET ZZKDAUF = LS_2330-DMORD
                          ZZKDPOS = LS_2330-DMLINE
        WHERE AUFNR = LV_AUFNR.
      COMMIT WORK AND WAIT.
    ENDIF.

    LS_2330-GSMNG = ( <LS_MODI_2340>-INLENGTH * <LS_MODI_2340>-INFACTOR ) + <LS_MODI_2340>-CLENGTH.
    LS_2330-BMENG = LS_2330-GSMNG.
    APPEND LS_2330 TO LT_MODI_2330.

  ENDLOOP.

  IF LT_DEL_2340 IS NOT INITIAL.
    DELETE ZGTPPT2340 FROM TABLE LT_DEL_2340.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      PERFORM ROLLBACK_ORDES.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더 생성에 대한 작업지시 저장 중 오류발생하였습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_MODI_2340 IS NOT INITIAL.
    MODIFY ZGTPPT2340 FROM TABLE LT_MODI_2340.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      PERFORM ROLLBACK_ORDES.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더 생성에 대한 작업지시 저장 중 오류발생하였습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_MODI_2330 IS NOT INITIAL.
    MODIFY ZGTPPT2330 FROM TABLE LT_MODI_2330.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
      PERFORM ROLLBACK_ORDES.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더 생성에 대한 작업지시 저장 중 오류발생하였습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  PERFORM SET_PROGRESS_INDICATOR USING '50' '완제품 작업지시 완료'.

  PERFORM SET_HALF_MATNR USING '1' CHANGING LV_CHK_ERR.
  IF LV_CHK_ERR = ABAP_TRUE.
    PERFORM ROLLBACK_ORDES.
    DELETE ZGTPPT2330 FROM TABLE LT_MODI_2330.
    DELETE ZGTPPT2340 FROM TABLE LT_MODI_2340.
    MODIFY ZGTPPT2340 FROM TABLE LT_DEL_2340.
    COMMIT WORK AND WAIT.
    RETURN.
  ENDIF.

  PERFORM SET_PROGRESS_INDICATOR USING '100' '완료'.

  PERFORM GET_MAIN_DATA.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  PERFORM REFRESH_GRID USING GO_GRID_0101.
  PERFORM REFRESH_GRID USING GO_GRID_0102.

  MESSAGE S006 WITH '선택 사항에 대한 완제품 작업지시 및 반제품 공정 계획 수립 되었습니다.'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CRT_PRD_INFOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN
*&      <-- LS_MODI_2340
*&---------------------------------------------------------------------*
FORM CRT_PRD_INFOR  USING    PS_MAIN LIKE GS_BOTTOM_DISP
                                  PS_2330 TYPE ZGTPPT2330
                    CHANGING PS_MODI_2340 TYPE ZGTPPT2340.

  PS_MODI_2340-WERKS = P_WERKS.
  PS_MODI_2340-SPGCD = P_SPGCD.
  PS_MODI_2340-RQMON = P_SPMON.
  PS_MODI_2340-GONG_CD = PS_2330-GONG_CD.
  PS_MODI_2340-ZWKREQ = PS_2330-ZWKREQ.
  PS_MODI_2340-MATNR = PS_2330-MATNR.
*  PS_MODI_2340-ORDNR
*  PS_MODI_2340-POSNR
  PS_MODI_2340-ORDTY = 'PRD'.
  PS_MODI_2340-INLENGTH = PS_2330-INLENGTH.
  PS_MODI_2340-INFACTOR = PS_2330-INFACTOR.
*  PS_MODI_2340-QLENGTH =
  PS_MODI_2340-CLENGTH = PS_MAIN-ADLENGTH.
*  PS_MODI_2340-ADLENGTH
*  PS_MODI_2340-ADTYPE
  PS_MODI_2340-GONG_SEQ = PS_2330-GONG_SEQ.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CRT_PRD_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_MODI_2340
*&---------------------------------------------------------------------*
FORM CRT_PRD_ORDER  CHANGING PS_2330 TYPE ZGTPPT2330
                                         PS_MODI_2340 TYPE ZGTPPT2340
                                         PV_CHK_ERR.

  DATA : LS_ORDER TYPE BAPI_PP_ORDER_CREATE.
  DATA : LS_RETURN TYPE BAPIRET2.
  DATA : LV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.
  DATA : LV_MM(2) TYPE N.
  DATA : LV_LASTDATE TYPE SY-DATUM.
  DATA : LV_CHK_ERR TYPE CHAR01.
  DATA : LV_PACK_YN(20).

*  오더 생성
  LS_ORDER-MATERIAL = PS_MODI_2340-MATNR.
  LS_ORDER-PLANT = P_WERKS.
  LS_ORDER-ORDER_TYPE = 'PP01'.
  LS_ORDER-BASIC_START_DATE = P_SPMON && '01'.

  LV_LASTDATE = LS_ORDER-BASIC_START_DATE.
  PERFORM GET_LAST_DAY_OF_MONTH CHANGING LV_LASTDATE.
  LS_ORDER-BASIC_END_DATE = LV_LASTDATE.
  LS_ORDER-QUANTITY = ( PS_MODI_2340-INLENGTH * PS_MODI_2340-INFACTOR ) + PS_MODI_2340-CLENGTH.
  LS_ORDER-BASIC_SCHEDULING_TYPE = '3'.

  IF PS_2330-DMORDTY = 'SO'.
    LS_ORDER-SALES_ORDER = PS_2330-DMORD.
    LS_ORDER-SALES_ORDER_ITEM = PS_2330-DMLINE.
    CLEAR LV_PACK_YN.
* 포장 유무 확인
    ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
      EXPORTING
        IV_VBELN      = LS_ORDER-SALES_ORDER                " 구성
        IV_POSNR      = LS_ORDER-SALES_ORDER_ITEM                 " 구성
      IMPORTING
        EV_PACK_YN = LV_PACK_YN  ).

    CASE LV_PACK_YN.
      WHEN 'CM' OR 'NA'.
      WHEN OTHERS.
        PV_CHK_ERR = 'P'.
        RETURN.
    ENDCASE.
  ENDIF.


  PERFORM CHK_MATNR_INFOR2 CHANGING LS_ORDER LV_CHK_ERR.
  IF LV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  CALL FUNCTION 'BAPI_PRODORD_CREATE'
    EXPORTING
      ORDERDATA    = LS_ORDER
    IMPORTING
      RETURN       = LS_RETURN
      ORDER_NUMBER = LV_ORDER_NUMBER.

  IF LS_RETURN-TYPE NE 'E'.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

*      커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
    DO .
      SELECT SINGLE AUFNR, POSNR
        FROM AFPO
       WHERE AUFNR = @LV_ORDER_NUMBER
        INTO @DATA(LS_AFPO).
      IF SY-SUBRC EQ 0.
        EXIT.
      ELSE.
        WAIT UP TO '0.1' SECONDS.
      ENDIF.
    ENDDO.

    IF PS_2330-DMORDTY NE 'SO'.
      PERFORM CHANG_BDC_JOJANG USING PS_MODI_2340 LV_ORDER_NUMBER PV_CHK_ERR.
      IF PV_CHK_ERR = ABAP_TRUE.
        PERFORM ROLLBACK_ORDES.
        RETURN.
      ENDIF.
    ENDIF.
  ELSE.
    PERFORM ROLLBACK_ORDES.
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  PS_MODI_2340-ORDNR = LV_ORDER_NUMBER.
  PS_MODI_2340-POSNR = 1.

  APPEND INITIAL LINE TO GT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDER>).
  <LS_ORDER>-ORDER_NUMBER =  LV_ORDER_NUMBER.

  WAIT UP TO '0.5' SECONDS.

* 포장재 RESB 구성부품 업데이트
  IF PS_2330-DMORDTY = 'SO' AND LV_PACK_YN = 'CM'.
    PERFORM CHANGE_RESB_POJANG USING PS_2330 LV_ORDER_NUMBER CHANGING PV_CHK_ERR.
  ENDIF.




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
*& Form ROLLBACK_ORDES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ROLLBACK_ORDES .

  DATA : LS_RETURN2 TYPE BAPIRET2.
  DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.

  CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
    IMPORTING
      RETURN        = LS_RETURN2
    TABLES
      ORDERS        = GT_PRD_ORDERS
      DETAIL_RETURN = LT_DETAIL_RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANG_BDC_JOJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_MODI_2340
*&      --> LV_ORDER_NUMBER
*&      --> PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHANG_BDC_JOJANG  USING    PS_MODI_2340 TYPE ZGTPPT2340
                                PV_ORDER_NUMBER TYPE AUFNR
                                PV_CHK_ERR.

  DATA : LV_INLENGTH TYPE I.
  DATA : LV_INLENGTH_C(10) TYPE C.
  DATA : LV_INFACTOR TYPE I.
  DATA : LV_INFACTOR_C(10) TYPE C.
  DATA : LV_TEST01 TYPE CABNT-ATBEZ.
  DATA : LV_TEST02 TYPE CABNT-ATBEZ.
  DATA : LV_TEST03 TYPE CABNT-ATBEZ.

  SELECT A~ATNAM, B~ATBEZ
    FROM CABN AS A
    INNER JOIN CABNT AS B ON B~ATINN = A~ATINN
  WHERE A~ATNAM IN ( 'SAP_MILLCA_LENGTH', 'SAP_MILLCA_FACTOR', 'PD_CA_PROC_NAME' )
    AND B~SPRAS = @SY-LANGU
   INTO TABLE @DATA(LT_CHAR_NAME).

  LOOP AT LT_CHAR_NAME INTO DATA(LS_CHAR_NAME).
    CASE LS_CHAR_NAME-ATNAM.
      WHEN 'SAP_MILLCA_LENGTH'.
        LV_TEST01 = LS_CHAR_NAME-ATBEZ.
      WHEN 'SAP_MILLCA_FACTOR'.
        LV_TEST02 = LS_CHAR_NAME-ATBEZ.
      WHEN 'PD_CA_PROC_NAME'.
        LV_TEST03 = LS_CHAR_NAME-ATBEZ.
    ENDCASE.
  ENDLOOP.

  REFRESH : GT_BDCDATA, GT_MESSTAB.

  LV_INLENGTH = PS_MODI_2340-INLENGTH.
  LV_INLENGTH_C = LV_INLENGTH.
  CONDENSE LV_INLENGTH_C.

  LV_INFACTOR = PS_MODI_2340-INFACTOR.
  LV_INFACTOR_C = LV_INFACTOR.
  CONDENSE LV_INFACTOR_C.

  __SETTING_BDC_PARAMS.

  __BDC_DYNPRO 'SAPLCOKO1' '0110'.
  __BDC_FIELD : 'CAUFVD-AUFNR' PV_ORDER_NUMBER,
                      'R62CLORD-FLG_OVIEW'  'X',
                      'BDC_OKCODE' '=ENTK'.

  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD : 'BDC_OKCODE' '=KOTA'. " 빠른입력화면으로 전환


  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_SEL_ALL'.

  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_CONFIG'.

  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_CONFIG'.

  __BDC_DYNPRO 'SAPLCEI0' '0109'.
  __BDC_FIELD : 'RCTMS-MNAME(01)' LV_TEST01,
                      'RCTMS-MNAME(02)' LV_TEST02,
                      'RCTMS-MNAME(03)' LV_TEST03,
                      'RCTMS-MWERT(01)' LV_INLENGTH_C,
                      'RCTMS-MWERT(02)' LV_INFACTOR_C,
                      'RCTMS-MWERT(03)' PS_MODI_2340-GONG_CD,
                      'BDC_OKCODE' '=BACK'.


  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD : 'BDC_OKCODE' '=BU'.

  __BDC_TRANSACTION 'CO02'.
  LOOP AT GT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'A'
                                                         OR MSGTYP = 'E'
                                                         OR MSGTYP = 'X'.
    PV_CHK_ERR = 'E'.
    RETURN.
  ENDLOOP.

  COMMIT WORK AND  WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HALF_MATNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_HALF_MATNR USING PV_ZDISTRIB TYPE ZGTPPT2330-ZDISTRIB
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

  LOOP AT GT_2330_FUL INTO DATA(LS_2330) WHERE GONG_SEQ = '01' AND ZDISTRIB = PV_ZDISTRIB.

    CASE PV_ZDISTRIB .
      WHEN '1'.
        CLEAR LS_PRODUCT.
        READ TABLE GT_2340_FUL INTO DATA(LS_2340) WITH KEY ZWKREQ = LS_2330-ZWKREQ.
        IF SY-SUBRC EQ 0.
          LS_PRODUCT-GONG_CD = LS_2330-GONG_CD.
          LS_PRODUCT-MATNR = LS_2330-MATNR.
          LS_PRODUCT-ZSPECNO = LS_2330-ZSPECNO.
          IF LS_2340-ORDTY = 'PO'.
            LS_PRODUCT-ZOEM = ABAP_TRUE.
          ENDIF.
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
    IF LS_PRODUCT-ZOEM = ABAP_TRUE.
      PERFORM GET_BOM_FR_PO USING LS_PRODUCT.
    ELSE.
      PERFORM GET_BOM_FR_PRD USING LS_PRODUCT.
    ENDIF.
  ENDLOOP.

* 전체 반제품 확인하여 임가공일시 수량 제외 로직
  PERFORM CONV_ROUND.

  DELETE GT_2330_FUL WHERE GONG_SEQ = '01'.

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

      LS_2330-INFACTOR = 0.

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
      LV_GSMNG = LV_GSMNG + ( ( LS_2340-INLENGTH * LS_2340-INFACTOR ) + LS_2340-CLENGTH ).
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

  LV_GONG_SEQ = '02'.

  LOOP AT LT_BASE_GONG_SEQ ASSIGNING <LS_INPUT>.
    CASE <LS_INPUT>-GONG_CD.
      WHEN 'REW'.
        <LS_INPUT>-GONG_SEQ = '01'.
      WHEN 'SHE'.
        <LS_INPUT>-GONG_SEQ = '02'.

      WHEN OTHERS.
        ADD 1 TO LV_GONG_SEQ.
        <LS_INPUT>-GONG_SEQ = LV_GONG_SEQ.
    ENDCASE.
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
    DELETE LT_BASE_GONG_SEQ WHERE GONG_SEQ >= LV_GONG_SEQ
                                             AND GONG_SEQ < LV_CHK_GONG_SEQ.
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
      LS_PRODUCT-MATNR = LS_MATNR-MATNR.
      IF LS_PRODUCT-GONG_CD = 'SHE'.
        LS_PRODUCT-ZSPECNO = PS_PRODUCT-ZSPECNO.
      ENDIF.
      LOOP AT  LT_STB INTO LS_STB WHERE IDNRK = LS_MATNR-MATNR.
        ADD LS_STB-MNGLG TO LS_PRODUCT-GAMNG.
      ENDLOOP.
      COLLECT LS_PRODUCT INTO GT_SET_MATNR.
    ENDLOOP.
  ENDLOOP.

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

  LV_GONG_SEQ = '02'.

  LOOP AT LT_BASE_GONG_SEQ ASSIGNING <LS_INPUT>.
    CASE <LS_INPUT>-GONG_CD.
      WHEN 'REW'.
        <LS_INPUT>-GONG_SEQ = '01'.
      WHEN 'SHE'.
        <LS_INPUT>-GONG_SEQ = '02'.

      WHEN OTHERS.
        ADD 1 TO LV_GONG_SEQ.
        <LS_INPUT>-GONG_SEQ = LV_GONG_SEQ.
    ENDCASE.
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
      LS_PRODUCT-MATNR = LS_MATNR-MATNR.
      IF LS_PRODUCT-GONG_CD = 'SHE'.
        LS_PRODUCT-ZSPECNO = PS_PRODUCT-ZSPECNO.
      ENDIF.
      LOOP AT  LT_STB INTO LS_STB WHERE IDNRK = LS_MATNR-MATNR.
        ADD LS_STB-MNGLG TO LS_PRODUCT-GAMNG.
      ENDLOOP.
      COLLECT LS_PRODUCT INTO GT_SET_MATNR.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MATNR_INFOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_PRODUCT_MATNR
*&      <-- LS_2330_MEINS
*&      <-- LS_2330_INLENGTH
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

* 외주공정의 경우 표준만권량이 존재하지 않으므로
*  이전 공정중 외주공정이 아닌 자재가 있을경우 그자재의 만권량으로 표현해준다.
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

  SORT LT_SEQ_ROUTING BY SEQNO.

  IF LT_SEQ_ROUTING[] IS NOT INITIAL.
    SELECT * FROM ZGTCVMSTVAL
       FOR ALL ENTRIES IN @LT_SEQ_ROUTING
      WHERE WERKS = @P_WERKS
      AND MATNR = @LT_SEQ_ROUTING-MATNR
      INTO TABLE @DATA(LT_MATNR_DETAIL).
  ENDIF.

  LOOP AT LT_SEQ_ROUTING INTO DATA(LS_SEQ_ROUTING).
    READ TABLE LT_MATNR_DETAIL INTO DATA(LS_MATNR_DETAIL) WITH KEY MATNR = LS_SEQ_ROUTING-MATNR.
    IF SY-SUBRC EQ 0.
      CASE LS_MATNR_DETAIL-BESKZ.
        WHEN 'E' OR 'X'.
          CLEAR LV_INLENGTH.
          SELECT SINGLE /SAPMP/MAX_FERTL FROM ZGTCVROUTING
             WHERE WERKS = @P_WERKS
               AND MATNR = @LS_SEQ_ROUTING-MATNR
               AND FLGAT = '0' "대표설비
            INTO @LV_INLENGTH.

          IF SY-SUBRC EQ 0 AND LV_INLENGTH NE 0.
            PV_INLENGTH = LV_INLENGTH.
            RETURN.
          ENDIF.

      ENDCASE.
    ENDIF.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_PLAN_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_CHG_2330>
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
*& Form PROC_DEL_PRD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DEL_PRD .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LT_MOSU_MAIN LIKE GT_BOTTOM_DISP.
  DATA : LT_MOSU LIKE GT_2330.
  DATA : LT_MOSU_FUL LIKE GT_2330.
  DATA : LV_VBELN TYPE VBELN.
  DATA : LV_DMORD TYPE ZGTPPT2330-DMORD.
  DATA : LV_DMLINE TYPE ZGTPPT2330-DMLINE.
  DATA : LV_ORDNR TYPE ZGTPPT2340-ORDNR.
  DATA : LV_AUFNR TYPE AUFNR.
  DATA : LV_TABIX TYPE I.
  DATA : LV_BMENG TYPE BMENG.
  DATA : LV_SUB_MENGE TYPE MENGE_D.
  DATA : LV_SUB_GONG_CD TYPE ZGTPPT2340-GONG_CD.
  DATA : LV_SUB_MATNR TYPE MATNR.
  DATA : LT_SYVAL TYPE TABLE OF ZGTCVORDSYVAL.

  DATA : LT_DEL_2340 TYPE TABLE OF ZGTPPT2340.
  DATA : LT_MODI_2330 TYPE TABLE OF ZGTPPT2330.
  DATA : LT_ORIGN_2330 TYPE TABLE OF ZGTPPT2330.
  DATA : LV_CHK_ERR.
  DATA : LV_MESSAGE(100).


  CALL METHOD GO_GRID_0101->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  IF LT_ROW[] IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT LT_ROW INTO LS_ROW.
    READ TABLE GT_BOTTOM_DISP INTO DATA(LS_MAIN) INDEX LS_ROW-INDEX.
    IF LS_MAIN-TEXT01 = '외주' .
      MESSAGE S006 DISPLAY LIKE 'E' WITH '조달 외주 유형이 선택 되었습니다.'(E13).
      RETURN.
    ENDIF.

    IF LS_MAIN-ORDNR IS INITIAL .
      MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더가 생성되지 않은  작업요청입니다.'(E15).
      RETURN.
    ENDIF.

    IF LS_MAIN-GONG_CD = 'REW'.
      REFRESH LT_SYVAL.
      SELECT * FROM ZGTCVORDSYVAL
        INTO TABLE LT_SYVAL
       WHERE ZZORIGIN = LS_MAIN-ORDNR
          AND DLFL = ''
          AND LKD = ''
          AND CLSD = ''
          AND TECO = ''.
      IF SY-SUBRC EQ 0 AND LT_SYVAL[] IS NOT  INITIAL.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더' LS_MAIN-ORDNR '는 분할오더 생성되어 삭제할 수 없습니다.'(E49).
        RETURN.
      ENDIF.

    ENDIF.

    CASE  LS_MAIN-ORD_STAT.
      WHEN '입고' OR '진행중'.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더' LS_MAIN-ORDNR '는 삭제 할 수 없는 상태입니다.'(E48).
        RETURN.
    ENDCASE.

    APPEND LS_MAIN TO LT_MOSU_MAIN.
  ENDLOOP.

  REFRESH GT_PRD_ORDERS.

* 선택된 라인정보로 오더 생성 테이블 구성
  LOOP AT LT_MOSU_MAIN INTO LS_MAIN.
    LV_DMLINE = LS_MAIN-POSNR.
    __ALPHA_INPUT LV_DMLINE.
    READ TABLE GT_2330 INTO DATA(LS_CHK_ORDTY) WITH KEY DMORD = LS_MAIN-VBELN
                                                                                     DMLINE = LV_DMLINE.
    IF SY-SUBRC NE 0.
      LV_VBELN = LS_MAIN-VBELN.
      __ALPHA_INPUT LV_VBELN.
      READ TABLE GT_2330 INTO LS_CHK_ORDTY WITH KEY DMORD = LV_VBELN
                                                                          DMLINE = LV_DMLINE.
    ENDIF.

    READ TABLE LT_MOSU_FUL TRANSPORTING NO FIELDS WITH KEY DMORD = LS_CHK_ORDTY-DMORD
                                                                                         DMLINE = LS_CHK_ORDTY-DMLINE.
    IF SY-SUBRC EQ 0. " 이미 적재되어 있으므로 건너 띄어준다.
      CONTINUE.
    ENDIF.

    REFRESH LT_MOSU.
    LT_MOSU = VALUE #( FOR LW_2330 IN GT_2330 WHERE ( DMORD = LS_CHK_ORDTY-DMORD
                                                                    AND   DMLINE = LS_CHK_ORDTY-DMLINE )
                                ( CORRESPONDING #( LW_2330 ) ) ).

    LOOP AT LT_MOSU ASSIGNING FIELD-SYMBOL(<LS_MOSU>).
      LV_TABIX = SY-TABIX.
      LV_ORDNR = <LS_MOSU>-DMORD.
      __ALPHA_OUT LV_ORDNR.

      READ TABLE GT_BOTTOM_DISP INTO LS_MAIN WITH KEY VBELN = LV_ORDNR
                                                                       POSNR = <LS_MOSU>-DMLINE
                                                                       GONG_CD = <LS_MOSU>-GONG_CD.
      IF SY-SUBRC EQ 0.
        IF LS_MAIN-ORDNR IS INITIAL.
          MESSAGE S006 DISPLAY LIKE 'E' WITH '연결공정' LS_MAIN-GONG_CD '는 오더가 없어 삭제 할 수 없는 상태입니다.'(E15).
          RETURN.
        ENDIF.

        LV_AUFNR = LS_MAIN-ORDNR.
        __ALPHA_INPUT LV_AUFNR.

        CASE  LS_MAIN-ORD_STAT.
          WHEN '입고' OR '진행중'.
            MESSAGE S006 DISPLAY LIKE 'E' WITH '연결공정' LS_MAIN-GONG_CD LS_MAIN-ORDNR '는 삭제 할 수 없는 상태입니다.'(E15).
            RETURN.
          WHEN '삭제'. " 오더 삭제 안하고 테이블 삭제 처리만 진행
          WHEN OTHERS. "오더 삭제 테이블 반영
            APPEND INITIAL LINE TO GT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_DEL_ORD>).
            <LS_DEL_ORD>-ORDER_NUMBER = LV_AUFNR.
        ENDCASE.

        READ TABLE GT_2340 INTO DATA(LS_2340) WITH KEY ORDNR = LV_AUFNR.
        IF SY-SUBRC EQ 0.
          APPEND LS_2340 TO LT_DEL_2340.

          READ TABLE GT_2330 INTO DATA(LS_2330) WITH KEY ZWKREQ = LS_2340-ZWKREQ.
* 에러시 롤백처리를 위해 원본 테이블 가져오기
          APPEND LS_2330 TO LT_ORIGN_2330.

*          IF LS_2330-GONG_CD = 'REW'.
          LS_2330-BMENG = LS_2340-INLENGTH * LS_2340-INFACTOR.
          LS_2330-GSMNG = LS_2330-BMENG.
*          ELSE.
*            READ TABLE GT_2330 INTO DATA(LS_2330_REW) WITH KEY DMORD = LS_2330-DMORD
*                                                                              DMLINE = LS_2330-DMLINE
*                                                                              GONG_CD = 'REW'.
*            IF SY-SUBRC EQ 0.
*              READ TABLE GT_2340 INTO DATA(LS_2340_REW) WITH KEY ZWKREQ = LS_2330_REW-ZWKREQ.
*              IF SY-SUBRC EQ 0.
*                CLEAR LV_BMENG.
*                CLEAR LV_SUB_MENGE.
*                LV_BMENG = LS_2340_REW-INFACTOR * LS_2340_REW-INLENGTH.
*                PERFORM GET_SUB_GONG USING LS_2340_REW-MATNR LV_BMENG
*                           CHANGING LV_SUB_GONG_CD LV_SUB_MATNR LV_SUB_MENGE.
*
*                LS_2330-BMENG = LV_SUB_MENGE.
*                LS_2330-GSMNG = LS_2330-BMENG.
*              ENDIF.
*
*            ENDIF.
*          ENDIF.

          APPEND LS_2330 TO LT_MODI_2330.

        ENDIF.
      ENDIF.

    ENDLOOP.

    IF LT_MOSU IS NOT INITIAL.
      APPEND LINES OF LT_MOSU TO LT_MOSU_FUL.
    ENDIF.

  ENDLOOP.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택한 소요량요소에 완제품 작업 지시가 삭제 됩니다. 진행 하시겠습니까?'
    '작업확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  PERFORM SET_PROGRESS_INDICATOR USING '10' '완제품 생산오더 삭제중..'.

  IF LT_DEL_2340[] IS NOT INITIAL.
    DELETE ZGTPPT2340 FROM TABLE LT_DEL_2340.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더 삭제 저장 중 오류발생하였습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_MODI_2330[] IS NOT INITIAL.
    MODIFY ZGTPPT2330 FROM TABLE LT_MODI_2330.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더 삭제 저장 중 오류발생하였습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  PERFORM SET_HALF_MATNR USING '1' CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR = ABAP_TRUE.
    MODIFY ZGTPPT2330 FROM TABLE LT_ORIGN_2330.
    MODIFY ZGTPPT2340 FROM TABLE LT_DEL_2340.
    COMMIT WORK AND WAIT.
    RETURN.
  ENDIF.

  PERFORM ROLLBACK_ORDES.

  PERFORM SET_PROGRESS_INDICATOR USING '100' '완료'.

  PERFORM GET_MAIN_DATA.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  PERFORM REFRESH_GRID USING GO_GRID_0101.
  PERFORM REFRESH_GRID USING GO_GRID_0102.

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
  DATA : LT_MOSU_MAIN LIKE GT_BOTTOM_DISP.
  DATA : LT_MOSU_MAIN2 LIKE GT_BOTTOM_DISP2.

  DATA : LV_CHK_ERR.
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
    MESSAGE S006 DISPLAY LIKE 'E' WITH '임가공 구매 오더를 생성할 작업 요청을 선택해 주세요'(E17).
    RETURN.
  ENDIF.

  IF LINES( LT_ROW )  NE 1.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '임가공 구매오더는 작업 요청 하나만 선택 할 수 있습니다'(E16).
    RETURN.
  ENDIF.

  LOOP AT LT_ROW INTO LS_ROW.

    READ TABLE GT_BOTTOM_DISP INTO DATA(LS_MAIN) INDEX LS_ROW-INDEX.

    IF LS_MAIN-ORDNR IS NOT INITIAL OR
       LS_MAIN-EBELN IS NOT INITIAL.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '작업지시된 작업요청을 선택했습니다.'(E18).
      RETURN.
    ENDIF.

    SELECT SINGLE * FROM ZGTCVMSTVAL
      INTO @DATA(LS_CVMSTVAL)
     WHERE WERKS = @P_WERKS
       AND MATNR = @LS_MAIN-MATNR.

    IF ( LS_CVMSTVAL-BESKZ = 'F' AND LS_CVMSTVAL-SOBSL = '30' ) OR
       ( LS_CVMSTVAL-BESKZ = 'X' AND LS_CVMSTVAL-SOBSL = '30' ).
      APPEND LS_MAIN TO LT_MOSU_MAIN.
    ELSE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '조달 외주 유형이 아닌 작업요청이 선택 되었습니다.'(E19).
      RETURN.
    ENDIF.
  ENDLOOP.

* 구매오더 발주를 위한 구성 준비
  PERFORM READY_FOR_PURCHASE TABLES LT_MOSU_MAIN LT_MOSU_MAIN2 USING '1'
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

  PERFORM GET_MAIN_DATA.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  PERFORM REFRESH_GRID USING GO_GRID_0101.
  PERFORM REFRESH_GRID USING GO_GRID_0102.

  MESSAGE S006 WITH '선택 사항에 대한 완제품 임가공 구매오더 생성 및 반제품 공정 계획 수립 되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_EXIST_IMGAGONG_MENGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_PRODUCT
*&      --> LS_MATNR_MATNR
*&      --> LS_STB_MNGKO
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

  DELETE LT_SEQ_ROUTING WHERE MATNR = PV_MATNR.

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
*& Form conV_round
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SET_MATNR
*&---------------------------------------------------------------------*
FORM CONV_ROUND.

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
*& Form DELETE_PR_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2330
*&---------------------------------------------------------------------*
FORM DELETE_PR_ORDER  TABLES   PT_2330 STRUCTURE ZGTPPT2330.

  DATA : LT_2330 TYPE TABLE OF ZGTPPT2330.
  DATA : LV_NUMBER TYPE BAPIMEREQHEADER-PREQ_NO.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LT_PRITEM TYPE TABLE OF BAPIMEREQITEMIMP.
  DATA : LT_PRITEMX TYPE TABLE OF BAPIMEREQITEMX.

  LT_2330 = PT_2330[].

  SELECT SINGLE FLD_02 AS WERKS,  FLD_03 AS EKORG,  FLD_04 AS EKGRP
    FROM ZGTPPT1010
   WHERE MODULE_KIND = 'PP'
     AND CODEGRP = '2090'
     AND FLD_01 = ' '
     AND FLD_02 = @P_WERKS
    INTO @DATA(LS_PR_INFOR).

* 범주 판매오더의 OEM 구매요청 확인
  SELECT A~BANFN, A~BNFPO, A~LFDAT, A~STATU, B~VBELN, B~VBELP, A~LIFNR
    FROM @LT_2330 AS C
    INNER JOIN EBKN AS B ON B~VBELN = C~DMORD
                                AND B~VBELP = C~DMLINE
    INNER JOIN EBAN AS A ON A~BANFN = B~BANFN
                                AND A~BNFPO = B~BNFPO
                                AND A~MATNR = C~MATNR
   WHERE A~WERKS =  @P_WERKS
      AND A~BSTYP = 'B'
      AND A~EKORG = @LS_PR_INFOR-EKORG
      AND A~EKGRP = @LS_PR_INFOR-EKGRP
      AND A~LOEKZ = ''
    INTO TABLE @DATA(LT_EBAN).

  LOOP AT LT_EBAN INTO DATA(LS_EBAN).
    REFRESH : LT_PRITEM, LT_PRITEMX.
* ITEM 정보 입력
    APPEND INITIAL LINE TO LT_PRITEM ASSIGNING FIELD-SYMBOL(<LS_PRITEM>).
    <LS_PRITEM>-PREQ_ITEM = LS_EBAN-BNFPO.
    <LS_PRITEM>-DELETE_IND = 'X'.

* ItemX 정보 입력
    APPEND INITIAL LINE TO LT_PRITEMX ASSIGNING FIELD-SYMBOL(<LS_PRITEMX>).
    <LS_PRITEMX>-PREQ_ITEM = LS_EBAN-BNFPO.
    <LS_PRITEMX>-DELETE_IND = 'X'.

    CALL FUNCTION 'BAPI_PR_CHANGE'
      EXPORTING
        NUMBER  = LS_EBAN-BANFN
      TABLES
        RETURN  = LT_RETURN
        PRITEM  = LT_PRITEM
        PRITEMX = LT_PRITEMX.

    IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form READY_FOR_PURCHASE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_MOSU_MAIN
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM READY_FOR_PURCHASE  TABLES   PT_MOSU STRUCTURE GS_BOTTOM_DISP
                                                       PT_MOSU2 STRUCTURE GS_BOTTOM_DISP2
                            USING PV_GUBUN
                        CHANGING PV_CHK_ERR.

  DATA : LT_BASE_GONG_SEQ LIKE GT_BASE_GONG_SEQ.
  DATA : LT_CHK_GONG_SEQ LIKE GT_BASE_GONG_SEQ.
  DATA : LT_INPUT_2330 TYPE TABLE OF ZGTPPT2330.
  DATA : LS_MAIN_2330 TYPE ZGTPPT2330.
  DATA : LS_BASE_GONG_SEQ LIKE GS_BASE_GONG_SEQ.
  DATA : LV_VBELN TYPE VBELN.
  DATA : LV_ORDNR TYPE ZGTPPT2330-DMORD.
  DATA : LV_MATNR TYPE MATNR.
  DATA : LS_TEMP LIKE GS_BOTTOM_DISP.
  DATA : LV_MESSAGE(100).
  DATA : LV_MESSAGE2(100).
  DATA : LV_PACK_YN(20).

  REFRESH GT_2340_CHG.
  REFRESH GT_IMGAGONG_RESB.

  CASE PV_GUBUN.
    WHEN '1'.
* 1) 선택된 라인의 공정
      READ TABLE PT_MOSU INDEX 1.

      CLEAR LS_BASE_GONG_SEQ.
      LS_BASE_GONG_SEQ-GONG_SEQ = PT_MOSU-GONG_SEQ.
      LS_BASE_GONG_SEQ-GONG_CD = PT_MOSU-GONG_CD.
      LS_BASE_GONG_SEQ-GONG_NM = PT_MOSU-GONG_NM.
      APPEND LS_BASE_GONG_SEQ TO LT_BASE_GONG_SEQ.

* 2)선택된 라인의 정보
      IF PT_MOSU-ORDTY = 'SO'.
        LV_VBELN = PT_MOSU-VBELN.
        __ALPHA_INPUT LV_VBELN.
        LV_ORDNR = LV_VBELN.

        ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
          EXPORTING
            IV_VBELN      = LV_VBELN                " 구성
            IV_POSNR      = PT_MOSU-POSNR
         IMPORTING
            EV_PACK_YN = LV_PACK_YN  ).
        CASE LV_PACK_YN.
          WHEN 'CM' OR 'NA'.
          WHEN OTHERS.

            CLEAR LV_MESSAGE.
            LV_MESSAGE = LV_VBELN && '/' && PT_MOSU-POSNR.
            CONCATENATE 'S/O' LV_MESSAGE '에 대한 포장재 지정이 완료되지 않았습니다.'
                          INTO LV_MESSAGE SEPARATED BY SPACE.
            LV_MESSAGE2 = '영업 및 설계팀에 문의 바랍니다.'.
            MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MESSAGE LV_MESSAGE2.

            PV_CHK_ERR = 'P'.
            RETURN.
        ENDCASE.

      ELSE.
        LV_ORDNR = PT_MOSU-VBELN.
      ENDIF.

      READ TABLE GT_2330 INTO LS_MAIN_2330 WITH KEY DMORD = LV_ORDNR
                                                                      DMLINE = PT_MOSU-POSNR
                                                                      GONG_SEQ = PT_MOSU-GONG_SEQ.

* 3) 선택된 라인의 작업지시 세팅
      PERFORM MAKE_2340 USING PT_MOSU LS_MAIN_2330.

    WHEN OTHERS.
* 1) 선택된 라인의 공정
      READ TABLE PT_MOSU2 INDEX 1.

      CLEAR LS_BASE_GONG_SEQ.
      LS_BASE_GONG_SEQ-GONG_SEQ = PT_MOSU2-GONG_SEQ.
      LS_BASE_GONG_SEQ-GONG_CD = PT_MOSU2-GONG_CD.
      LS_BASE_GONG_SEQ-GONG_NM = PT_MOSU2-GONG_NM.
      APPEND LS_BASE_GONG_SEQ TO LT_BASE_GONG_SEQ.

      READ TABLE GT_2330 INTO LS_MAIN_2330 WITH KEY MATNR = PT_MOSU2-MATNR.

      CLEAR LS_TEMP.
      LS_TEMP-INLENGTH = PT_MOSU2-INLENGTH.
      LS_TEMP-INFACTOR = PT_MOSU2-INFACTOR.
* 3) 선택된 라인의 작업지시 세팅
      PERFORM MAKE_2340 USING LS_TEMP LS_MAIN_2330.

  ENDCASE.


  CASE PT_MOSU-GONG_SEQ.
    WHEN '01'.

* 봄조회후 구성공정 결정 및 표준공정 세팅
      PERFORM FIND_BOM_AND_GETDATA TABLES LT_CHK_GONG_SEQ LT_INPUT_2330
                                                    USING PT_MOSU-MATNR '01'.

      IF LT_CHK_GONG_SEQ[] IS NOT INITIAL.
        APPEND LINES OF LT_CHK_GONG_SEQ TO LT_BASE_GONG_SEQ.
      ENDIF.

      PERFORM SET_TABLE_DISP_200 TABLES LT_BASE_GONG_SEQ LT_INPUT_2330
                                                USING LS_MAIN_2330 '1'
                                           CHANGING PV_CHK_ERR.


    WHEN OTHERS.
* 봄조회후 구성공정 결정 및 표준공정 세팅
      PERFORM FIND_BOM_AND_GETDATA TABLES LT_CHK_GONG_SEQ LT_INPUT_2330
                                                    USING PT_MOSU2-MATNR PT_MOSU2-GONG_SEQ.

      IF LT_CHK_GONG_SEQ[] IS NOT INITIAL.
        APPEND LINES OF LT_CHK_GONG_SEQ TO LT_BASE_GONG_SEQ.
      ENDIF.

      PERFORM SET_TABLE_DISP_200 TABLES LT_BASE_GONG_SEQ LT_INPUT_2330
                                                USING LS_MAIN_2330 '2'
                                           CHANGING PV_CHK_ERR.

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TABLE_DISP_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_BASE_GONG_SEQ
*&      --> LT_INPUT_2330
*&      --> PT_MOSU
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
  IF PS_MAIN-GONG_SEQ = '01' AND PS_MAIN-DMORD IS NOT INITIAL.
    GS_HEADER_200-VBELN = PS_MAIN-DMORD.
    GS_HEADER_200-POSNR = PS_MAIN-DMLINE.
  ENDIF.

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
*& Form MAKE_2340
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_MOSU
*&      <-- LS_2330_CHG
*&---------------------------------------------------------------------*
FORM MAKE_2340  USING    PS_MAIN LIKE GS_BOTTOM_DISP
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
  LS_2340_CHG-CLENGTH = PS_MAIN-ADLENGTH.
  LS_2340_CHG-GONG_SEQ = PS_2330-GONG_SEQ.

  APPEND LS_2340_CHG TO GT_2340_CHG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIND_BOM_AND_GETDATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_CHK_GONG_SEQ
*&      --> LT_INPUT_2330
*&      --> LS_MAIN_MATNR
*&      --> LV_GAMNG
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

  DELETE LT_SEQ_ROUTING WHERE MATNR = PV_MATNR.

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

  LV_GONG_SEQ = PV_GONG_SEQ.

  LOOP AT LT_BASE_GONG_SEQ ASSIGNING <LS_INPUT>.
    CASE <LS_INPUT>-GONG_CD.
      WHEN 'REW'.
        <LS_INPUT>-GONG_SEQ = '01'.
      WHEN 'SHE'.
        <LS_INPUT>-GONG_SEQ = '02'.

      WHEN OTHERS.
        ADD 1 TO LV_GONG_SEQ.
        <LS_INPUT>-GONG_SEQ = LV_GONG_SEQ.
    ENDCASE.
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
*  해당 자재공정이 가상품목 세팅시 한단계 내려간 자재 가져온다.
    CLEAR PT_2330.
    READ TABLE LT_STB INTO DATA(LS_STB) WITH KEY IDNRK = LS_MATNR-MATNR.

    IF SY-SUBRC EQ 0 AND ( LS_STB-DUMPS = 'X' OR LS_STB-DUMPS = 'x' ).
      PERFORM GET_PRE_GONG TABLES PT_2330[] USING LS_MATNR-MATNR LS_STB-VERID  .

    ELSE.

      PT_2330-GONG_CD = LS_BASE_GONG_SEQ-GONG_CD.
      PT_2330-MATNR = LS_MATNR-MATNR.
      PERFORM GET_MATNR_INFOR USING LS_MATNR-MATNR
                               CHANGING PT_2330-MEINS PT_2330-INLENGTH.
      PT_2330-INFACTOR = 1.
      APPEND PT_2330.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS '0200'.
  SET TITLEBAR '0200'.
ENDMODULE.
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
      I_INCLNAME             = 'ZGTPPR2270TOP'
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
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정'(F63).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재코드'(F64).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장'(F06).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(F07).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재내역'(F65).
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
    MESSAGE I006 WITH '구매 입고 저장위치를 입력해 주세요.'(e46).
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
      MESSAGE I006 WITH '사급 반제품 조장 및 조장수를 확인해 주세요.'(e25).
      PV_ANSWER = ABAP_TRUE.
      RETURN.
    ENDIF.

  ENDLOOP.

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

  CLEAR PV_CHK_ERR.
  PERFORM SET_RESB_PO USING GS_HEADER_200-MATNR LV_PSMNG
                               CHANGING LS_FCAT-REPTEXT PV_CHK_ERR.

  IF PV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

*     수량
  CLEAR LV_FIELDNAME.
  LV_FIELDNAME = |EKPO-MENGE({ LV_NUM })|.
  __BDC_FIELD : LV_FIELDNAME LV_PSMNG_C.

*   판매오더 참조 완제품의 경우
  IF GS_HEADER_200-VBELN IS NOT INITIAL.
*     수량
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = |EKPO-KNTTP({ LV_NUM })|.
    __BDC_FIELD : LV_FIELDNAME 'M'.

    __BDC_DYNPRO 'SAPMM06E' '0511'.
    __BDC_FIELD : 'BDC_OKCODE' '=UMOD'.

    __BDC_DYNPRO 'SAPLKACB' '0002'.
    __BDC_FIELD : 'BDC_OKCODE' '=ENTE',
                        'COBL-KDAUF' GS_HEADER_200-VBELN,
                        'COBL-KDPOS' GS_HEADER_200-POSNR.

    __BDC_DYNPRO 'SAPMM06E' '0113'.
    __BDC_FIELD : 'BDC_OKCODE' '=BACK'.

  ENDIF.


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
*& Form PROC_DEL_PO_PRODUCT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DEL_PO_PRODUCT .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LV_EBELN TYPE EBELN.
  DATA : LV_EBELP TYPE EBELP.
  DATA : BEGIN OF LS_MOSU ,
           EBELN TYPE EBELN,
           EBELP TYPE EBELP,
           ELIKZ TYPE ELIKZ,
           LOEKZ TYPE LOEKZ,
         END OF LS_MOSU.
  DATA : LT_MOSU LIKE TABLE OF LS_MOSU.
  DATA : LT_DEL_2340 TYPE TABLE OF ZGTPPT2340.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LT_POITEM   TYPE TABLE OF BAPIMEPOITEM.
  DATA : LT_POITEMX   TYPE TABLE OF BAPIMEPOITEMX.
  DATA : LV_CHK_ERR.

  CALL METHOD GO_GRID_0101->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  IF LT_ROW[] IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT LT_ROW INTO LS_ROW.
    READ TABLE GT_BOTTOM_DISP INTO DATA(LS_MAIN) INDEX LS_ROW-INDEX.
    IF LS_MAIN-EBELN IS INITIAL .
      MESSAGE S006 DISPLAY LIKE 'E' WITH '임가공 구매오더가 생성되지 않은  작업요청입니다.'(E22).
      RETURN.
    ENDIF.

    LV_EBELN = LS_MAIN-EBELN.
    LV_EBELP = LS_MAIN-EBELP + 0.

    SELECT SINGLE EBELN, EBELP, ELIKZ, LOEKZ FROM EKPO
          INTO @LS_MOSU
          WHERE EBELN = @LV_EBELN
            AND EBELP = @LV_EBELP.
    IF SY-SUBRC EQ 0 .
      IF  LS_MOSU-ELIKZ IS NOT INITIAL.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '납품 완료된 임가공 구매오더는 삭제할 수 없습니다.'(E23).
        RETURN.
      ENDIF.

      APPEND LS_MOSU TO LT_MOSU.
    ENDIF.
  ENDLOOP.

  IF LT_MOSU[] IS INITIAL.
    RETURN.
  ENDIF.

  SORT LT_MOSU BY EBELN EBELP.
  DELETE ADJACENT DUPLICATES FROM LT_MOSU COMPARING EBELN EBELP.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택한 임가공 작업지시가 삭제 됩니다. 진행 하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  REFRESH LT_DEL_2340.
  LOOP AT GT_2340 INTO DATA(LS_2340) WHERE ORDTY = 'PO'.
    READ TABLE LT_MOSU INTO LS_MOSU WITH KEY EBELN = LS_2340-ORDNR
                                                              EBELP = LS_2340-POSNR+1(5).
    IF SY-SUBRC EQ 0.
      APPEND LS_2340 TO LT_DEL_2340.
    ENDIF.

  ENDLOOP.

  IF LT_DEL_2340 IS NOT INITIAL.
    DELETE ZGTPPT2340 FROM TABLE LT_DEL_2340.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '임가공구매오더 삭제 중 오류발생하였습니다.'(e24).
      RETURN.
    ENDIF.
  ENDIF.

  PERFORM SET_HALF_MATNR USING '1' CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR = ABAP_TRUE.
    MODIFY ZGTPPT2340 FROM TABLE LT_DEL_2340.
    COMMIT WORK AND WAIT.
    RETURN.
  ENDIF.

  LOOP AT LT_MOSU INTO LS_MOSU.
    REFRESH : LT_POITEM, LT_POITEMX, LT_RETURN.

    APPEND INITIAL LINE TO LT_POITEM ASSIGNING FIELD-SYMBOL(<LS_POITEM>).
    <LS_POITEM>-PO_ITEM = LS_MOSU-EBELP.
    <LS_POITEM>-DELETE_IND = ABAP_TRUE.

    APPEND INITIAL LINE TO LT_POITEMX ASSIGNING FIELD-SYMBOL(<LS_POITEMX>).
    <LS_POITEMX>-PO_ITEM = LS_MOSU-EBELP.
    <LS_POITEMX>-PO_ITEMX = ABAP_TRUE.
    <LS_POITEMX>-DELETE_IND = ABAP_TRUE.

    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        PURCHASEORDER = LS_MOSU-EBELN
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
  ENDLOOP.

  PERFORM SET_PROGRESS_INDICATOR USING '100' '완료'.

  PERFORM GET_MAIN_DATA.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  PERFORM REFRESH_GRID USING GO_GRID_0101.
  PERFORM REFRESH_GRID USING GO_GRID_0102.

  MESSAGE S006 WITH '선택한 임가공 구매오더 삭제 되었습니다.'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CRT_PO2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CRT_PO2 .

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LT_MOSU_MAIN LIKE GT_BOTTOM_DISP.
  DATA : LT_MOSU_MAIN2 LIKE GT_BOTTOM_DISP2.

  DATA : LV_CHK_ERR.
  DATA : LV_MESSAGE(100).
  DATA : LV_EBELN TYPE EBELN.
  DATA : LV_EBELP TYPE EBELP.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LT_POITEM   TYPE TABLE OF BAPIMEPOITEM.
  DATA : LT_POITEMX   TYPE TABLE OF BAPIMEPOITEMX.


  CALL METHOD GO_GRID_0102->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

  DELETE LT_ROW WHERE INDEX = 0. " 서브토탈 제외

  IF LT_ROW[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '임가공 구매 오더를 생성할 작업 요청을 선택해 주세요'(E17).
    RETURN.
  ENDIF.

  IF LINES( LT_ROW )  NE 1.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '임가공 구매오더는 작업 요청 하나만 선택 할 수 있습니다'(E16).
    RETURN.
  ENDIF.

  LOOP AT LT_ROW INTO LS_ROW.

    READ TABLE GT_BOTTOM_DISP2 INTO DATA(LS_MAIN) INDEX LS_ROW-INDEX.

    SELECT SINGLE * FROM ZGTCVMSTVAL
      INTO @DATA(LS_CVMSTVAL)
     WHERE WERKS = @P_WERKS
       AND MATNR = @LS_MAIN-MATNR.

    IF ( LS_CVMSTVAL-BESKZ = 'F' AND LS_CVMSTVAL-SOBSL = '30' ) OR
       ( LS_CVMSTVAL-BESKZ = 'X' AND LS_CVMSTVAL-SOBSL = '30' ).
      APPEND LS_MAIN TO LT_MOSU_MAIN2.
    ELSE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '조달 외주 유형이 아닌 작업요청이 선택 되었습니다.'(E19).
      RETURN.
    ENDIF.
  ENDLOOP.

* 구매오더 발주를 위한 구성 준비
  PERFORM READY_FOR_PURCHASE TABLES LT_MOSU_MAIN LT_MOSU_MAIN2 USING '2'
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

    RETURN.
  ENDIF.

  IF GT_2340_CHG IS NOT INITIAL.
    MODIFY ZGTPPT2340 FROM TABLE GT_2340_CHG.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

  PERFORM SET_PROGRESS_INDICATOR USING '100' '완료'.

  PERFORM GET_MAIN_DATA.

  PERFORM REFRESH_GRID USING GO_GRID_0100.
  PERFORM REFRESH_GRID USING GO_GRID_0101.
  PERFORM REFRESH_GRID USING GO_GRID_0102.

  MESSAGE S006 WITH '선택 사항에 대한 완제품 임가공 구매오더 생성 및 반제품 공정 계획 수립 되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                            P_ROW TYPE LVC_S_ROW
                            P_COLUMN TYPE LVC_S_COL.

  IF P_ROW-INDEX = 0.
    RETURN.
  ENDIF.


  CASE P_SENDER.
    WHEN GO_GRID_0100.
      READ TABLE GT_MAIN_DISP INTO DATA(LS_MAIN_100) INDEX P_ROW-INDEX.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'REQ_FACTOR' OR 'VBELN' OR 'POSNR'.
          CASE LS_MAIN_100-GCATG.
            WHEN '판매오더'.
              SET PARAMETER ID 'AUN' FIELD LS_MAIN_100-VBELN.
              CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
              SET PARAMETER ID 'AUN' FIELD ''.
            WHEN OTHERS.
              PERFORM DISP_POPUP_SMORDER USING LS_MAIN_100-VBELN LS_MAIN_100-POSNR.
          ENDCASE.
        WHEN 'MATNR'.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'K'.
          SET PARAMETER ID 'MAT' FIELD LS_MAIN_100-MATNR.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'WRK' FIELD ''.
          SET PARAMETER ID 'MAT' FIELD ''.
        WHEN 'BANFN' OR 'BNFPO'.
          SET PARAMETER ID 'BAN' FIELD LS_MAIN_100-BANFN.
          CALL TRANSACTION 'ME53N'.
          SET PARAMETER ID 'BAN' FIELD ''.
        WHEN 'EBELN' OR 'EBELP'.
          SET PARAMETER ID 'BES' FIELD LS_MAIN_100-EBELN.
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'BES' FIELD ''.
        WHEN 'SNOTE'.
          IF LS_MAIN_100-SNOTE IS NOT INITIAL.
            PERFORM SET_AND_DISP_TEXT USING LS_MAIN_100.
          ENDIF.
        WHEN 'SNOTE2'.
          IF LS_MAIN_100-SNOTE2 IS NOT INITIAL.
            PERFORM SET_AND_DISP_TEXT2 USING LS_MAIN_100.
          ENDIF.
        WHEN 'CHAR'.
          IF LS_MAIN_100-CHAR IS NOT INITIAL.
            PERFORM DISPLAY_POPUP_CHARACTICS USING LS_MAIN_100.
          ENDIF.
        WHEN 'CHAR2'.
          IF LS_MAIN_100-CHAR2 IS NOT INITIAL.
            PERFORM DISPLAY_POPUP_CHAR_BAX USING LS_MAIN_100.
          ENDIF.

      ENDCASE.
    WHEN GO_GRID_0101.
      READ TABLE GT_BOTTOM_DISP INTO DATA(LS_MAIN_101) INDEX P_ROW-INDEX.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'VBELN' OR 'POSNR'.
          CASE LS_MAIN_101-ORDTY.
            WHEN 'SO'.
              SET PARAMETER ID 'AUN' FIELD LS_MAIN_101-VBELN.
              CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
              SET PARAMETER ID 'AUN' FIELD ''.
            WHEN OTHERS.
              PERFORM DISP_POPUP_SMORDER USING LS_MAIN_101-VBELN LS_MAIN_101-POSNR.
          ENDCASE.
        WHEN 'MATNR'.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'K'.
          SET PARAMETER ID 'MAT' FIELD LS_MAIN_101-MATNR.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'WRK' FIELD ''.
          SET PARAMETER ID 'MAT' FIELD ''.
        WHEN 'ORDNR'.
          SET PARAMETER ID 'ANR' FIELD LS_MAIN_101-ORDNR.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
        WHEN 'EBELN' OR 'EBELP'.
          SET PARAMETER ID 'BES' FIELD LS_MAIN_101-EBELN.
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'BES' FIELD ''.
        WHEN 'SNOTE'.
          IF LS_MAIN_101-SNOTE IS NOT INITIAL.
            PERFORM SET_AND_EDIT_TEXT USING LS_MAIN_101-ORDNR.
          ENDIF.
      ENDCASE.

    WHEN GO_GRID_0102.
      READ TABLE GT_BOTTOM_DISP2 INTO DATA(LS_MAIN_102) INDEX P_ROW-INDEX.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'PLNUM'.
          SET PARAMETER ID 'PAF' FIELD LS_MAIN_102-PLNUM.
          CALL TRANSACTION 'MD13' AND SKIP FIRST SCREEN.

        WHEN 'MATNR'.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'K'.
          SET PARAMETER ID 'MAT' FIELD LS_MAIN_102-MATNR.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'WRK' FIELD ''.
          SET PARAMETER ID 'MAT' FIELD ''.
        WHEN 'DISP_PO'.
          PERFORM DISPLSY_PO_INFOR USING LS_MAIN_102.
        WHEN 'MENGE02' OR 'MENGE03'.
          IF LS_MAIN_102-MENGE02 NE 0.
            PERFORM DISP_POPUP_ORDERS USING LS_MAIN_102.
          ENDIF.
      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_POPUP_SMORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_100_VBELN
*&      --> LS_MAIN_100_POSNR
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
*& Form SET_AND_DISP_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_100
*&---------------------------------------------------------------------*
FORM SET_AND_DISP_TEXT  USING PS_MAIN_100 LIKE GS_MAIN_DISP.

  DATA : LT_TEXT TYPE TABLE OF CHAR255.
  DATA : LT_LINE TYPE TABLE OF TLINE.
  DATA : LV_NAME TYPE THEAD-TDNAME.
  DATA : LV_VBELN TYPE VBELN.

  CASE PS_MAIN_100-GCATG.
    WHEN '판매오더'.
      LV_VBELN = PS_MAIN_100-VBELN.
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
       WHERE ORDNO = @PS_MAIN_100-VBELN
         AND POSNR = @PS_MAIN_100-POSNR
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
*& Form SET_AND_EDIT_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_101_ORDNR
*&---------------------------------------------------------------------*
FORM SET_AND_EDIT_TEXT  USING    PV_ORDNR.

  DATA : LV_AUFNR TYPE AUFNR.
  DATA : LS_THEAD LIKE THEAD.
  DATA : LT_TLINE LIKE TLINE OCCURS 0 WITH HEADER LINE .
  DATA : LT_TEXT TYPE TABLE OF CHAR255.

  LV_AUFNR = PV_ORDNR.
  __ALPHA_INPUT LV_AUFNR.

  SELECT SINGLE LTEXT FROM AUFK
    INTO @DATA(LV_LTEXT)
    WHERE AUFNR = @LV_AUFNR.

  IF LV_LTEXT IS NOT INITIAL.
* 생산오더
    LS_THEAD-TDID     = 'KOPF'.
    LS_THEAD-TDSPRAS  = SY-LANGU.
    CONCATENATE SY-MANDT LV_AUFNR INTO LS_THEAD-TDNAME.
    LS_THEAD-TDOBJECT = 'AUFK' .

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        CLIENT                  = SY-MANDT
        ID                      = LS_THEAD-TDID
        LANGUAGE                = LS_THEAD-TDSPRAS
        NAME                    = LS_THEAD-TDNAME
        OBJECT                  = LS_THEAD-TDOBJECT
      TABLES
        LINES                   = LT_TLINE
      EXCEPTIONS
        ID                      = 1
        LANGUAGE                = 2
        NAME                    = 3
        NOT_FOUND               = 4
        OBJECT                  = 5
        REFERENCE_CHECK         = 6
        WRONG_ACCESS_TO_ARCHIVE = 7.

    LOOP AT LT_TLINE INTO DATA(LS_TLINE).
      APPEND INITIAL LINE TO LT_TEXT ASSIGNING FIELD-SYMBOL(<LS_TEXT>).
      <LS_TEXT> = LS_TLINE-TDLINE.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION 'ZGTPP_UTILL_TEXTEDIT'
    EXPORTING
      IV_MODE  = '2'
      IV_TITLE = '특기사항'
    CHANGING
      CT_TEXT  = LT_TEXT.

  IF LT_TEXT IS NOT INITIAL.
    REFRESH LT_TLINE.
    LOOP AT LT_TEXT INTO DATA(LS_TEXT).
      APPEND INITIAL LINE TO LT_TLINE ASSIGNING FIELD-SYMBOL(<LS_TLINE>).
      <LS_TLINE>-TDLINE = LS_TEXT.
    ENDLOOP.
  ENDIF.

  IF LV_LTEXT IS INITIAL.
    UPDATE AUFK SET LTEXT = SY-LANGU
     WHERE AUFNR = LV_AUFNR.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      HEADER          = LS_THEAD
      SAVEMODE_DIRECT = 'X'
    TABLES
      LINES           = LT_TLINE
    EXCEPTIONS
      ID              = 1
      LANGUAGE        = 2
      NAME            = 3
      OBIECT          = 4
      OTHERS          = 5.

  COMMIT WORK AND WAIT.

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
  LV_VBELN = PS_MAIN_100-VBELN.
  __ALPHA_INPUT LV_VBELN.
  SELECT SINGLE CUOBJ FROM VBAP
    INTO @DATA(LV_CUOBJ)
    WHERE VBELN = @LV_VBELN
      AND POSNR = @PS_MAIN_100-POSNR.

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
*& Form DISPLSY_PO_INFOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_102
*&---------------------------------------------------------------------*
FORM DISPLSY_PO_INFOR  USING    PS_MAIN_102 LIKE GS_BOTTOM_DISP2.

  DATA : LV_PLNUM TYPE PLNUM.
  DATA : LT_EBELN TYPE RANGE OF EBELN.
  DATA : LV_BUKRS  TYPE BUKRS.

  LV_PLNUM = PS_MAIN_102-PLNUM.
  __ALPHA_INPUT LV_PLNUM.

  READ TABLE GT_2330 INTO DATA(LS_2330) WITH KEY PLNUM = LV_PLNUM.
  IF SY-SUBRC EQ 0.
    LOOP AT GT_2340 INTO DATA(LS_2340) WHERE ZWKREQ = LS_2330-ZWKREQ.
      APPEND INITIAL LINE TO LT_EBELN ASSIGNING FIELD-SYMBOL(<LS_EBELN>).
      <LS_EBELN>-SIGN = 'I'.
      <LS_EBELN>-OPTION = 'EQ'.
      <LS_EBELN>-LOW = LS_2340-ORDNR.
    ENDLOOP.
  ENDIF.

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
*& Form GET_MAINDATA_SIPAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_MAINDATA_SIPAN .

  DATA : LV_PRE_SPMON TYPE SPMON.
  DATA : LV_DATE TYPE SY-DATUM.
  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LV_GSMNG TYPE GSMNG.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : LT_ORDSYVAL TYPE TABLE OF ZGTCVORDSYVAL.
  DATA : LV_DISPO TYPE MARC-DISPO.

  CLEAR GV_CHK_CURRENT_MON.
  CLEAR GV_CHK_DO_PREMONTH.
  CLEAR GV_CHK_DO_CURRENT_MON.

  IF P_SPMON = SY-DATUM+(6). " 현재월
    GV_CHK_CURRENT_MON = ABAP_TRUE.
  ENDIF.

  LV_DATE = SY-DATUM+0(6) && '01'.
  LV_DATE = LV_DATE - 1.
  LV_PRE_SPMON = LV_DATE+0(6).

  PERFORM CHK_DO_PRE_MONTH USING LV_PRE_SPMON.

  SELECT * FROM ZGTPPT2350
    INTO TABLE GT_2350
   WHERE WERKS = P_WERKS.

  LT_MATNR = VALUE #( FOR LW_2350 IN GT_2350 WHERE ( MATNR IS NOT INITIAL )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2350-MATNR ) ).

  REFRESH GT_2330.

  SELECT * FROM ZGTPPT2330
    INTO TABLE GT_2330
   WHERE WERKS = P_WERKS
     AND SPGCD = P_SPGCD
     AND RQMON = P_SPMON
     AND ZDISTRIB = '2'.

  REFRESH GT_2340.

  SELECT * FROM ZGTPPT2340
    INTO TABLE GT_2340
   WHERE WERKS = P_WERKS
     AND SPGCD = P_SPGCD
     AND RQMON = P_SPMON.

  LT_AUFNR = VALUE #( FOR LW_2340 IN GT_2340 WHERE ( ORDNR IS NOT INITIAL
                                                                  AND   ORDTY = 'PRD' )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2340-ORDNR ) ).

  IF LT_AUFNR IS NOT INITIAL.
    SORT LT_AUFNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_AUFNR COMPARING LOW.
* SPG 테이블 조회용 필드로 변경
    LV_DISPO = P_SPGCD && '%'. "

    SELECT * FROM ZGTCVORDSYVAL
      INTO TABLE LT_ORDSYVAL
     WHERE WERKS = P_WERKS
        AND DISPO LIKE LV_DISPO
         AND AUFNR IN LT_AUFNR
        AND DLFL = ''
        AND LKD = ''
        AND CLSD = ''
        AND TECO = ''.
  ENDIF.

  IF GT_2330 IS NOT INITIAL.
    GV_CHK_DO_CURRENT_MON = ABAP_TRUE.
    LT_MATNR = VALUE #( FOR LW_2330 IN GT_2330 WHERE ( MATNR IS NOT INITIAL )
                                  ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2330-MATNR ) ).
  ENDIF.

  SORT LT_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

  IF LT_MATNR IS NOT INITIAL.
    SELECT * FROM ZGTCVMSTVAL
      APPENDING TABLE GT_CVMVAL
     WHERE WERKS = P_WERKS
        AND MATNR IN LT_MATNR.
  ENDIF.

  LOOP AT GT_2330 INTO DATA(LS_2330) WHERE GONG_CD = 'REW'.
    CLEAR GS_MAIN_DISP_500.
    GS_MAIN_DISP_500-GONG_SEQ = LS_2330-GONG_SEQ.
    GS_MAIN_DISP_500-GONG_CD = LS_2330-GONG_CD.
    READ TABLE GT_CVMVAL INTO DATA(LS_CVMVAL) WITH KEY MATNR = LS_2330-MATNR.
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP_500-GONG_NM = LS_CVMVAL-PDCAPROCNAME.
      GS_MAIN_DISP_500-MATNR = LS_2330-MATNR.
      GS_MAIN_DISP_500-ZSPECNO = LS_CVMVAL-PDCASPECNO.
      GS_MAIN_DISP_500-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_2330-MATNR ).
      IF LS_CVMVAL-COLORBASE IS NOT INITIAL.
        GS_MAIN_DISP_500-COLOR = LS_CVMVAL-COLORBASE.
      ENDIF.

    ENDIF.

    GS_MAIN_DISP_500-GSMNG = LS_2330-GSMNG.
    GS_MAIN_DISP_500-INLENGTH = LS_2330-INLENGTH.
    GS_MAIN_DISP_500-INFACTOR = LS_2330-INFACTOR.
* 차후 적용 예정
*    GS_MAIN_DISP_500-DRUM
*    GS_MAIN_DISP_500-DRUM_SPEC
    GS_MAIN_DISP_500-PSTTR = LS_2330-PSTTR.
    GS_MAIN_DISP_500-PEDTR = LS_2330-PEDTR.
    GS_MAIN_DISP_500-PLNUM = LS_2330-PLNUM.
    APPEND GS_MAIN_DISP_500 TO GT_MAIN_DISP_500.
  ENDLOOP.

  LOOP AT GT_2330 INTO LS_2330 WHERE GONG_CD NE 'REW'.
    CLEAR GS_MAIN_DISP_501.
    GS_MAIN_DISP_501-GONG_SEQ = LS_2330-GONG_SEQ.
    GS_MAIN_DISP_501-GONG_CD = LS_2330-GONG_CD.
    READ TABLE GT_CVMVAL INTO LS_CVMVAL WITH KEY MATNR = LS_2330-MATNR.
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP_501-GONG_NM = LS_CVMVAL-PDCAPROCNAME.
      GS_MAIN_DISP_501-MATNR = LS_2330-MATNR.
      GS_MAIN_DISP_501-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_2330-MATNR ).
      IF LS_CVMVAL-COLORBASE IS NOT INITIAL.
        GS_MAIN_DISP_501-COLOR = LS_CVMVAL-COLORBASE.
      ENDIF.

      GS_MAIN_DISP_501-ZSPECNO = LS_2330-ZSPECNO.
    ENDIF.

    GS_MAIN_DISP_501-GSMNG = LS_2330-GSMNG.
    GS_MAIN_DISP_501-BMENG = LS_2330-BMENG.
    GS_MAIN_DISP_501-INLENGTH = LS_2330-INLENGTH.
    GS_MAIN_DISP_501-INFACTOR = LS_2330-INFACTOR.

    LOOP AT GT_2340 INTO DATA(LS_2340) WHERE ZWKREQ = LS_2330-ZWKREQ.
      LOOP AT LT_ORDSYVAL INTO DATA(LS_ORDSYVAL) WHERE AUFNR = LS_2340-ORDNR.
        GS_MAIN_DISP_501-MENGE01 = GS_MAIN_DISP_501-MENGE01 + ( LS_ORDSYVAL-PSAMG + LS_ORDSYVAL-PSMNG ).
        GS_MAIN_DISP_501-MENGE02 = GS_MAIN_DISP_501-MENGE02 + LS_ORDSYVAL-WEMNG.
      ENDLOOP.
    ENDLOOP.

* 차후 적용 예정
*    GS_MAIN_DISP_500-DRUM
*    GS_MAIN_DISP_500-DRUM_SPEC
    GS_MAIN_DISP_501-PSTTR = LS_2330-PSTTR.
    GS_MAIN_DISP_501-PEDTR = LS_2330-PEDTR.
    GS_MAIN_DISP_501-PLNUM = LS_2330-PLNUM.
    APPEND GS_MAIN_DISP_501 TO GT_MAIN_DISP_501.
  ENDLOOP.



  IF GT_MAIN_DISP_500[] IS INITIAL.
    LOOP AT GT_2350 INTO DATA(LS_2350).
      CLEAR GS_MAIN_DISP_500.
      READ TABLE GT_CVMVAL INTO LS_CVMVAL WITH KEY MATNR = LS_2350-MATNR.
      IF SY-SUBRC EQ 0 AND LS_CVMVAL-PDCAPROCCODE = 'REW'.
        GS_MAIN_DISP_500-GONG_SEQ = '01'.
        GS_MAIN_DISP_500-MATNR = LS_2350-MATNR.
        GS_MAIN_DISP_500-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_2350-MATNR ).
        GS_MAIN_DISP_500-GONG_CD = LS_CVMVAL-PDCAPROCCODE.
        GS_MAIN_DISP_500-GONG_NM = LS_CVMVAL-PDCAPROCNAME.
        IF LS_CVMVAL-COLORBASE IS NOT INITIAL.
          GS_MAIN_DISP_500-COLOR = LS_CVMVAL-COLORBASE.
        ENDIF.
        GS_MAIN_DISP_500-ZSPECNO = LS_CVMVAL-PDCASPECNO.
        GS_MAIN_DISP_500-GSMNG = LS_2350-INLENGTH * LS_2350-INFACTOR.
        GS_MAIN_DISP_500-INLENGTH = LS_2350-INLENGTH.
        GS_MAIN_DISP_500-INFACTOR = LS_2350-INFACTOR.
* 차후 적용 예정
*    GS_MAIN_DISP_500-DRUM
*    GS_MAIN_DISP_500-DRUM_SPEC
        GS_MAIN_DISP_500-PSTTR = P_SPMON && '01'.
        GS_MAIN_DISP_500-PEDTR = GS_MAIN_DISP_500-PSTTR.
        PERFORM GET_LAST_DAY_OF_MONTH CHANGING GS_MAIN_DISP_500-PEDTR.

        APPEND GS_MAIN_DISP_500 TO GT_MAIN_DISP_500.
      ENDIF.
    ENDLOOP.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_DO_PRE_MONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_PRE_SPMON
*&---------------------------------------------------------------------*
FORM CHK_DO_PRE_MONTH  USING    PV_PRE_SPMON TYPE SPMON.

  DATA : LT_2330 TYPE TABLE OF ZGTPPT2330.

  SELECT * FROM ZGTPPT2330
   WHERE WERKS = @P_WERKS
     AND SPGCD = @P_SPGCD
     AND RQMON = @PV_PRE_SPMON
     AND ZDISTRIB = '2'
     AND PLNUM IS NOT INITIAL
    INTO TABLE @LT_2330.

  SELECT B~*
    FROM @LT_2330 AS A
    INNER JOIN PLAF AS B ON B~PLNUM = A~PLNUM
    INTO TABLE @DATA(LT_PLAF).

  IF LT_PLAF[] IS NOT INITIAL. " 이전달 작업지시 존재
    GV_CHK_DO_PREMONTH = ABAP_TRUE.
  ENDIF.

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

  CASE ABAP_TRUE.
    WHEN P_CHK01.
      CALL SCREEN 0100.
    WHEN P_CHK02.
      CALL SCREEN 0500.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BUTTON .

  CLEAR GV_DYNTXT.
  GV_DYNTXT-ICON_ID = ICON_TABLE_SETTINGS.
  GV_DYNTXT-TEXT = '통신 시판 자재 관리'.
  GV_DYNTXT-QUICKINFO = '통신 시판 자재 관리'.
  SSCRFIELDS-FUNCTXT_01 = GV_DYNTXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_MAINTAIN_VIEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_MAINTAIN_VIEW .

  DATA : LV_TABNAME TYPE DD02V-TABNAME.
  DATA : LV_TITLE TYPE SY-TITLE.
  LV_TABNAME = 'ZGTPPT2350'.
  LV_TITLE = '통신 시판 자재 관리'.


  CALL FUNCTION 'ZGTPP_UTILL_VIEW'
    DESTINATION 'NONE'
    EXPORTING
      IV_TABNAME = LV_TABNAME
      IV_TITLE   = LV_TITLE.


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

  CREATE OBJECT GO_DOCKING_0500
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
  CREATE OBJECT GO_SPLITTER_0500
    EXPORTING
      PARENT  = GO_DOCKING_0500
      ROWS    = 2
      COLUMNS = 1.

  GO_SPLITTER_0500->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    30 ).             " Height


* top 컨테이너(Title)
  CALL METHOD GO_SPLITTER_0500->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0500.
* top 컨테이너(Grid)
  CALL METHOD GO_SPLITTER_0500->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0501.


  CREATE OBJECT GO_GRID_0500
    EXPORTING
      I_PARENT      = GO_CONTAIN_0500
      I_APPL_EVENTS = ABAP_TRUE.

  CREATE OBJECT GO_GRID_0501
    EXPORTING
      I_PARENT      = GO_CONTAIN_0501
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
  GS_LAYOUT_0500-SEL_MODE   = 'D'.
  GS_LAYOUT_0500-SMALLTITLE = 'X'.
  GS_LAYOUT_0500-GRID_TITLE = '시판 작업 요청 대상'.

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
      I_INCLNAME             = 'ZGTPPR2270TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_500'
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
      IT_DATA         = GT_MAIN_DISP_500
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0500 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'COLOR'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0500 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'COLOR'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상'(F02).
    <LS_FCAT>-COL_POS = 7.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0500 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'DRUM_SPEC'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0500 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'DRUM_SPEC'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '드럽규격'(F29).
    <LS_FCAT>-COL_POS = 12.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
    <LS_FCAT>-OUTPUTLEN = '30'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  LOOP AT GT_FIELDCAT_0500 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    <LS_FCAT>-TABNAME = 'GT_MAIN_DISP_500'.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'GONG_SEQ'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'GONG_CD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정'(F34).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'GONG_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정명'(F35).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품번호'(F18).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품명'(F10).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'GSMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수량'(F08).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장'(F06).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(F07).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'DRUM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '드럼'(F28).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'DRUM_SPEC'.
      WHEN 'PSTTR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시작일(계획)'(F51).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PEDTR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '종료일(계획)'(F52).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PLNUM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획오더'(F53).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZSPECNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SPEC NO'(F67).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

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
                            USING : 1 'GONG_SEQ'  'X' '' '',
                                       2 'GONG_CD'  'X' '' '',
                                       3 'GONG_NM'  'X' '' '',
                                       4 'MATNR'  'X' '' ''.

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
      I_BYPASSING_BUFFER   = ABAP_TRUE
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_500
      IT_SORT              = GT_SORT_0500
      IT_FIELDCATALOG      = GT_FIELDCAT_0500.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0501
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0501 .

  CLEAR GS_LAYOUT_0501.
  GS_LAYOUT_0501-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0501-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0501-SEL_MODE   = 'D'.
  GS_LAYOUT_0501-SMALLTITLE = 'X'.
  GS_LAYOUT_0501-GRID_TITLE = '시판 작업지시'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0501
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0501 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2270TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_501'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0501.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0501[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_501
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0501 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'COLOR'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0501 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'COLOR'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상'(F02).
    <LS_FCAT>-COL_POS = 6.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  LOOP AT GT_FIELDCAT_0501 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    <LS_FCAT>-TABNAME = 'GT_MAIN_DISP_501'.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'GONG_SEQ'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'GONG_CD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정'(F34).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'GONG_NM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정명'(F35).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품번호'(F18).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품명'(F10).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'BMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기준수량'(F68).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'GSMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획수량'(F69).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '표준조장'(F49).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(F07).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'MENGE01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '지시수량'(F70).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고량'(F71).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'PSTTR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시작일(계획)'(F51).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PEDTR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '종료일(계획)'(F52).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PLNUM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '계획오더'(F53).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZSPECNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'SPEC NO'(F67).
        <LS_FCAT>-JUST = 'C'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0501
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0501 .

  REFRESH GT_EXCLUDE_0501.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0501
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
*& Form SET_SORTTAB_GRID_0501
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0501 .

  REFRESH GT_SORT_0501.
  PERFORM SET_SORT_TAB TABLES GT_SORT_0501
                            USING : 1 'GONG_SEQ'  'X' '' '',
                                       2 'GONG_CD'  'X' '' '',
                                       3 'GONG_NM'  'X' '' '',
                                       4 'MATNR'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0501_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0501_DISPLAY .

  CALL METHOD GO_GRID_0501->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0501
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0501
      I_BYPASSING_BUFFER   = ABAP_TRUE
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_501
      IT_SORT              = GT_SORT_0501
      IT_FIELDCATALOG      = GT_FIELDCAT_0501.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_REQUEST_SIPAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_REQUEST_SIPAN .

  DATA : LV_CURRENT_SPMON(7).
  DATA : LV_MESSAGE(100).
  DATA : LT_2330 TYPE TABLE OF ZGTPPT2330.
  DATA : LS_2330 TYPE ZGTPPT2330.
  DATA : BEGIN OF LS_CHK_MAX_ZWKREQ,
           ZWKREQ   TYPE ZGTPPT2330-ZWKREQ,
           SEQNO(6) TYPE C,
         END OF LS_CHK_MAX_ZWKREQ.
  DATA : LT_CHK_MAX_ZWKREQ LIKE TABLE OF LS_CHK_MAX_ZWKREQ.
  DATA : LV_MAX_SEQ(6) TYPE N.
  DATA : LV_CHK_ERR.
  DATA : LT_PLAN_ORDERS_ROLLBACK TYPE MRPDS_PLONO." 오류시 삭제용


  LV_CURRENT_SPMON = SY-DATUM+0(4) &&'.' && SY-DATUM+4(2).
  LV_MESSAGE = LV_CURRENT_SPMON && '월 시판 작업 요청을 진행하시겠습니까?'.

  IF GV_CHK_CURRENT_MON NE ABAP_TRUE.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '현재월도' LV_CURRENT_SPMON '만 작업지시 가능합니다.'.
    RETURN.
  ENDIF.

  IF GV_CHK_DO_PREMONTH IS NOT INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '전월 시판 작업 요청이 종료되지 않았습니다.'.
    RETURN.
  ENDIF.

  IF GV_CHK_DO_CURRENT_MON IS NOT INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '당월 시판 작업 요청이 이미 생성되었습니다. 계획 오더를 확인해 주세요.'.
    RETURN.
  ENDIF.

  IF GT_MAIN_DISP_500[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '시판 자재관리 등록된 내역이 없습니다. 테이블을 확인해주세요.'.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    LV_MESSAGE
    '작업확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  PERFORM SET_PROGRESS_INDICATOR USING '10' '시판작업요청 생성중..'.

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

* 모두 테이블 저장된 대로 작업요청 생성
  LOOP AT GT_MAIN_DISP_500 INTO GS_MAIN_DISP_500.
    CLEAR LS_2330.
    LS_2330-WERKS = P_WERKS.
    LS_2330-SPGCD = P_SPGCD.
    LS_2330-RQMON = P_SPMON.
    ADD 1 TO LV_MAX_SEQ.
    LS_2330-ZWKREQ = SY-DATUM+2(6) && LV_MAX_SEQ.
    LS_2330-ZDISTRIB = '2'.
    LS_2330-GONG_CD = 'REW'.
    LS_2330-MATNR = GS_MAIN_DISP_500-MATNR.
    LS_2330-ZSPECNO = GS_MAIN_DISP_500-ZSPECNO.
* 작업요청월 + '01'
    LS_2330-PSTTR = P_SPMON && '01'.
* 작업요청월 + 말일
    LS_2330-PEDTR = LS_2330-PSTTR.
    PERFORM GET_LAST_DAY_OF_MONTH CHANGING LS_2330-PEDTR.

    SELECT SINGLE MEINS FROM MARA INTO LS_2330-MEINS WHERE MATNR = LS_2330-MATNR.
    LS_2330-INLENGTH = GS_MAIN_DISP_500-INLENGTH.
    LS_2330-INFACTOR = GS_MAIN_DISP_500-INFACTOR.
    LS_2330-BMENG = GS_MAIN_DISP_500-GSMNG.
    LS_2330-GSMNG = GS_MAIN_DISP_500-GSMNG.
    LS_2330-GONG_SEQ = '01'.

    PERFORM MAKE_PLAN_ORDER CHANGING LS_2330 LS_2330-GSMNG LV_CHK_ERR.
    IF LV_CHK_ERR = ABAP_TRUE.
      CLEAR LV_MESSAGE.
      CONCATENATE LS_2330-MATNR '자재번호 권취 작업 요청 등록 실패'
                  INTO LV_MESSAGE SEPARATED BY SPACE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MESSAGE.
      PERFORM ROLLBACK_PLAN_ORDER USING LT_PLAN_ORDERS_ROLLBACK.
      RETURN.
    ENDIF.

    APPEND LS_2330-PLNUM TO LT_PLAN_ORDERS_ROLLBACK.
    APPEND LS_2330 TO LT_2330.
  ENDLOOP.

  IF LT_2330 IS NOT INITIAL.
    MODIFY ZGTPPT2330 FROM TABLE LT_2330.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
      PERFORM ROLLBACK_PLAN_ORDER USING LT_PLAN_ORDERS_ROLLBACK.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '시판작업요청 권치작업 저장중 오류발생하였습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  PERFORM SET_HALF_MATNR USING '2' CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR = ABAP_TRUE.
    PERFORM ROLLBACK_ORDES.
    DELETE ZGTPPT2330 FROM TABLE LT_2330.
    COMMIT WORK AND WAIT.
    RETURN.
  ENDIF.

  PERFORM SET_PROGRESS_INDICATOR USING '100' '완료'.

  PERFORM GET_PROC.

  PERFORM REFRESH_GRID USING GO_GRID_0500.
  PERFORM REFRESH_GRID USING GO_GRID_0501.

  MESSAGE S006 WITH '선택 사항에 대한 시판 작업 요청 완료 되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DEL_REQ_SIPAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DEL_REQ_SIPAN .

  DATA : LV_CURRENT_SPMON(7).
  DATA : LV_MESSAGE(100).
  DATA : LT_2330 TYPE TABLE OF ZGTPPT2330.
  DATA : LS_2330 TYPE ZGTPPT2330.
  DATA : LV_CHK_ERR.
  DATA : LT_PLAN_ORDERS_ROLLBACK TYPE MRPDS_PLONO." 오류시 삭제용


  LV_CURRENT_SPMON = P_SPMON+0(4) &&'.' && P_SPMON+4(2).

  IF GT_2330[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH LV_CURRENT_SPMON '월의 시판작업 요청이 지시되지 않았습니다.'..
    RETURN.
  ENDIF.

  IF GV_CHK_CURRENT_MON = ABAP_TRUE.
    LV_MESSAGE = '현재월의 시판 작업 요청이 삭제 됩니다. 계속 진행하시겠습니까?'.
  ELSE.
    LV_MESSAGE = LV_CURRENT_SPMON && '월의 시판 작업 요청이 종료 됩니다. 계속 진행하시겠습니까?'.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    LV_MESSAGE
    '작업확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LOOP AT GT_2330 ASSIGNING FIELD-SYMBOL(<LS_2330>).
    APPEND <LS_2330>-PLNUM TO LT_PLAN_ORDERS_ROLLBACK.
    IF GV_CHK_CURRENT_MON = ABAP_TRUE.
    ELSE.
      CLEAR <LS_2330>-PLNUM.
    ENDIF.
  ENDLOOP.

  IF GV_CHK_CURRENT_MON = ABAP_TRUE.
    DELETE ZGTPPT2330 FROM TABLE GT_2330.
  ELSE.
    MODIFY ZGTPPT2330 FROM TABLE GT_2330.
  ENDIF.

  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '시판작업요청 종료중 오류발생하였습니다.'.
    RETURN.
  ENDIF.

  PERFORM ROLLBACK_PLAN_ORDER USING LT_PLAN_ORDERS_ROLLBACK.

  PERFORM SET_PROGRESS_INDICATOR USING '100' '완료'.

  PERFORM GET_PROC.

  PERFORM REFRESH_GRID USING GO_GRID_0500.
  PERFORM REFRESH_GRID USING GO_GRID_0501.

  MESSAGE S006 WITH LV_CURRENT_SPMON '월 시판 작업 요청 종료 되었습니다.'.

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
*& Form GET_CURRENT_MONTH_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ORDSYVAL
*&---------------------------------------------------------------------*
FORM GET_CURRENT_MONTH_ORDER.

  DATA : LT_GSTRP TYPE RANGE OF SY-DATUM.
  DATA : LV_BGNDT TYPE SY-DATUM.
  DATA : LV_ENDDT TYPE SY-DATUM.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.

  LV_BGNDT = P_SPMON && '01'.
  LV_ENDDT = LV_BGNDT.
  PERFORM GET_LAST_DAY_OF_MONTH CHANGING LV_ENDDT.

  APPEND INITIAL LINE TO LT_GSTRP ASSIGNING FIELD-SYMBOL(<LS_GSTRP>).
  <LS_GSTRP>-SIGN = 'I'.
  <LS_GSTRP>-OPTION = 'BT'.
  <LS_GSTRP>-LOW = LV_BGNDT.
  <LS_GSTRP>-HIGH = LV_ENDDT.

  REFRESH GT_ORDSYVAL_ETC.

  SELECT DISTINCT 'I' AS SIGN, 'EQ' AS OPTION, A~AUFNR AS LOW
    FROM AFKO AS A
    INNER JOIN AFPO AS B ON B~AUFNR = A~AUFNR
   WHERE B~DWERK = @P_WERKS
     AND A~TERKZ = '7'
     AND ( A~GSTRP IN @LT_GSTRP
      OR   A~GLTRP IN @LT_GSTRP )
    INTO CORRESPONDING FIELDS OF TABLE @LT_AUFNR.

  IF LT_AUFNR[] IS NOT INITIAL.
    SELECT * FROM ZGTCVORDSYVAL
      INTO TABLE GT_ORDSYVAL_ETC
     WHERE AUFNR IN LT_AUFNR
       AND WERKS = P_WERKS.
  ENDIF.

  DELETE GT_ORDSYVAL_ETC WHERE DLFL = ABAP_TRUE.
  DELETE GT_ORDSYVAL_ETC WHERE LKD = ABAP_TRUE.
  DELETE GT_ORDSYVAL_ETC WHERE CLSD = ABAP_TRUE.
  DELETE GT_ORDSYVAL_ETC WHERE TECO = ABAP_TRUE.


  SORT GT_ORDSYVAL_ETC BY AUFNR.

  LOOP AT GT_2340 INTO DATA(LS_2340).
    READ TABLE GT_ORDSYVAL_ETC INTO DATA(LS_ORDSYVAL) WITH KEY AUFNR = LS_2340-ORDNR.
    IF SY-SUBRC EQ 0.
      DELETE GT_ORDSYVAL_ETC WHERE AUFNR = LS_2340-ORDNR.
    ENDIF.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_MATNR_INFOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_CHG_2330>
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
*& Form CHK_MATNR_INFOR2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_ORDER
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_MATNR_INFOR2  CHANGING PS_ORDER TYPE BAPI_PP_ORDER_CREATE
                                PV_CHK_ERR.

  DATA : LV_MATNR_C(40).
  DATA : LV_CHK_DATE(8) TYPE N.
  DATA : LV_ORIGN_DATE(8) TYPE N.


  SELECT SINGLE * FROM MKAL
    INTO @DATA(LS_MKAL)
   WHERE WERKS = @P_WERKS
     AND MATNR = @PS_ORDER-MATERIAL
     AND VERID = '1000'.
  IF SY-SUBRC NE 0.
    LV_MATNR_C = PS_ORDER-MATERIAL.
    __ALPHA_OUT LV_MATNR_C.
    PV_CHK_ERR = ABAP_TRUE.
    MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MATNR_C '생산버전을 찾을 수 없습니다.'.
    RETURN.
  ENDIF.

  LV_CHK_DATE = LS_MKAL-ADATU.
  LV_ORIGN_DATE = PS_ORDER-BASIC_START_DATE.

  IF LV_CHK_DATE > LV_ORIGN_DATE.
    PS_ORDER-BASIC_START_DATE = LS_MKAL-ADATU.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_AND_DISP_TEXT2
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
  LV_VBELN = GS_MAIN_DISP-VBELN.
  __ALPHA_INPUT LV_VBELN.
  LV_POSNR = GS_MAIN_DISP-POSNR + 0.

  CASE PS_MAIN_100-GCATG.
    WHEN '판매오더'.
      LV_NAME = LV_VBELN && LV_POSNR.

*      LV_NAME = LV_VBELN.
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
*& Form DISP_POPUP_ORDERS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_102
*&---------------------------------------------------------------------*
FORM DISP_POPUP_ORDERS  USING PS_MAIN_101 LIKE GS_BOTTOM_DISP2.

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

  CALL SCREEN '0700' STARTING AT 5 5 ENDING AT 140 10.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0700
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0700 .

  CREATE OBJECT GO_CONTAIN_0700
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
  CREATE OBJECT GO_GRID_0700
    EXPORTING
      I_PARENT      = GO_CONTAIN_0700
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0700
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0700 .

  CLEAR GS_LAYOUT_0700.
  GS_LAYOUT_0700-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0700-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0700-NO_ROWMARK = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0700
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0700 .

  REFRESH GT_EXCLUDE_0700.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0700
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
*& Form SET_FIELDCAT_GRID_0700
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0700 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2270TOP'
      I_INTERNAL_TABNAME     = 'GS_POP_ORDERS'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0700.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0700[]
    TABLES
      IT_DATA         = GT_POP_ORDERS
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0700 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'SEQNO'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0700 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'SEQNO'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0700 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'ORD_STAT'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0700 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ORD_STAT'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더상태'(f76).
    <LS_FCAT>-COL_POS = 4.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-KEY = ABAP_TRUE.
    <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
  ENDIF.

  LOOP AT GT_FIELDCAT_0700 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'SEQNO' OR 'GSUZP' OR 'GLUZP'.
        <LS_FCAT>-NO_OUT = 'X'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더'(f77).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더품목'(f78).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ORD_STAT'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재코드'(f79).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'COLOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '색상'(f02).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재내역'(f80).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'GSTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시작일(계획)'(f81).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GLTRP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '종료일(계획)'(f82).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ZZPRIORITY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '우선순위'(f83).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(f84).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '표준조장'(f85).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업지시 B/N'(f57).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = 0.
      WHEN 'PSMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업지시량'(f56).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고량'(f86).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0700
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0700 .

  REFRESH GT_SORT_0700.

  PERFORM SET_SORT_TAB TABLES GT_SORT_0700
                            USING : 1 'SEQNO' '' 'X' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0700_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0700_DISPLAY .

  CALL METHOD GO_GRID_0700->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0700
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0700
    CHANGING
      IT_OUTTAB            = GT_POP_ORDERS
      IT_SORT              = GT_SORT_0700
      IT_FIELDCATALOG      = GT_FIELDCAT_0700.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_EXIST_SNOTE_FR_SO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> <LS_MAIN>_VBELN
*&      --> <LS_MAIN>_POSNR
*&      <-- LV_CHK_EXIST
*&---------------------------------------------------------------------*
FORM CHK_EXIST_SNOTE_FR_SO  USING    PV_GUBUN
                                     PV_VBELN
                                     PV_POSNR
                            CHANGING PV_CHK_EXIST.

  DATA : LV_VBELN TYPE VBELN.
  DATA : LV_POSNR TYPE POSNR.
  DATA : LT_LINE TYPE TABLE OF TLINE.
  DATA : LV_NAME TYPE THEAD-TDNAME.
  DATA : LV_OBJECT TYPE THEAD-TDOBJECT.

  LV_VBELN = PV_VBELN.
  __ALPHA_INPUT LV_VBELN.
  LV_POSNR = PV_POSNR + 0.

  CLEAR LV_NAME.
  CASE PV_GUBUN.
    WHEN 'H'. " 특기사항 헤더
      LV_NAME = LV_VBELN.
      LV_OBJECT = 'VBBK'.
    WHEN 'I'. " 특기사항 아이템
      LV_NAME = LV_VBELN && LV_POSNR.
      LV_OBJECT = 'VBBP'.
  ENDCASE.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID                      = '0001'
      LANGUAGE                = SY-LANGU
      NAME                    = LV_NAME
      OBJECT                  = LV_OBJECT
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

  IF LT_LINE IS NOT INITIAL.
    PV_CHK_EXIST = ABAP_TRUE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_EXIST_SNOTE_FR_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAIN>_VBELN
*&      --> <LS_MAIN>_POSNR
*&      <-- LV_CHK_EXIST
*&---------------------------------------------------------------------*
FORM CHK_EXIST_SNOTE_FR_PO  USING    PV_VBELN
                                     PV_POSNR
                            CHANGING PV_CHK_EXIST.

  SELECT SINGLE * FROM ZGTPPT2001
    WHERE ORDNO = @PV_VBELN
      AND POSNR = @PV_POSNR
     INTO @DATA(LS_2001).

  IF LS_2001-SNOTE IS NOT INITIAL.
    PV_CHK_EXIST = ABAP_TRUE.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RESB_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_2330[]
*&      --> LT_BASE_GONG_SEQ
*&      --> PV_MATNR
*&      --> ENDFORM
*&---------------------------------------------------------------------*
FORM SET_RESB_PO  USING    PV_MATNR TYPE MATNR
                                  PV_PSMNG TYPE CO_PSMNG
                              CHANGING PV_REPTEXT TYPE REPTEXT
                                PV_CHK_ERR.

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

* 공정명 피복은 쉬스에 대응
  IF PV_REPTEXT = '피복'.
    PV_REPTEXT = '시스'.
  ENDIF.

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
          AUMGB                 = ABAP_ON
          CAPID                 = 'PP01'
          DATUV                 = SY-DATUM
          EHNDL                 = '1'
          EMENG                 = LS_HALF_MATNR-EMENG
          MTNRV                 = LS_HALF_MATNR-MATNR " 자재
          WERKS                 = P_WERKS " 플랜트
          MKTLS                 = ABAP_ON
          VERID                 = LV_VERID
          MMORY                 = '1'
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

      SELECT SINGLE * FROM ZGTCVMSTVAL
            INTO @DATA(MSTVAL)
           WHERE WERKS = @P_WERKS
             AND MATNR = @LS_HALF_MATNR-MATNR
             AND PDCAPROCNAME = @PV_REPTEXT.


      SELECT A~IDNRK AS MATNR, B~MTART
        FROM @LT_STB AS A
        INNER JOIN MARA AS B
                              ON B~MATNR = A~IDNRK
        INNER JOIN MARC AS C
                              ON C~MATNR = A~IDNRK
                            AND C~WERKS = @P_WERKS
       WHERE B~MTART   IN ( 'MCFE', 'MCHF' )  " 완제품 반제품만 공정대상
         AND B~MATKL LIKE 'H%'
        INTO TABLE @DATA(LT_SEQ_ROUTING).

      IF LT_SEQ_ROUTING[] IS NOT INITIAL.
        SELECT * FROM ZGTCVMSTVAL
           FOR ALL ENTRIES IN @LT_SEQ_ROUTING
          WHERE WERKS = @P_WERKS
          AND MATNR = @LT_SEQ_ROUTING-MATNR
          INTO TABLE @DATA(LT_MATNR_DETAIL).

        IF LV_CHK_LAST IS INITIAL.
          "최초 공정과 임가공 선택된 자재의 공정이 동일할 경우 현재 정보만 가지고 정료
          SELECT SINGLE * FROM ZGTCVMSTVAL
            INTO @DATA(LS_MSTVAL)
           WHERE WERKS = @P_WERKS
             AND MATNR = @LS_HALF_MATNR-MATNR
             AND PDCAPROCNAME = @PV_REPTEXT.

*          READ TABLE LT_MATNR_DETAIL INTO DATA(LS_MATNR_DETAIL) WITH KEY MATNR = LS_HALF_MATNR-MATNR
*                                                                                                   PDCAPROCNAME = PV_REPTEXT.
          IF SY-SUBRC EQ 0.
            LV_CHK_LAST = ABAP_TRUE.
          ENDIF.

        ENDIF.
      ENDIF.

      DELETE LT_STB WHERE IDNRK = LS_HALF_MATNR-MATNR.
      DELETE LT_MATNR_DETAIL WHERE MATNR = LS_HALF_MATNR-MATNR.

      LOOP AT LT_STB INTO DATA(LS_STB).
        READ TABLE LT_MATNR_DETAIL INTO DATA(LS_MATNR_DETAIL) WITH KEY MATNR = LS_STB-IDNRK.
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
          READ TABLE LT_STB INTO LS_STB WITH KEY IDNRK = LS_HALF_MATNR2-MATNR.
          IF SY-SUBRC EQ 0 AND ( LS_STB-DUMPS = 'X' OR LS_STB-DUMPS = 'x' ).
            LOOP AT GT_MAIN_201 INTO GS_MAIN_201.

              CLEAR GS_IMGAGONG_RESB.
              GS_IMGAGONG_RESB-MATNR = GS_MAIN_201-MATNR.
              GS_IMGAGONG_RESB-WERKS = P_WERKS.
              READ TABLE LT_STB INTO LS_STB WITH KEY IDNRK = GS_MAIN_201-MATNR.
              IF SY-SUBRC EQ 0.
                GS_IMGAGONG_RESB-ERFME = LS_STB-MMEIN.
              ELSE.
                GS_IMGAGONG_RESB-ERFME = 'M'.
              ENDIF.
              GS_IMGAGONG_RESB-ERFMG = GS_MAIN_201-INLENGTH * GS_MAIN_201-INFACTOR.
              COLLECT GS_IMGAGONG_RESB INTO GT_IMGAGONG_RESB.
            ENDLOOP.
          ELSE.
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
          ENDIF.
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

* 포장재 대상일시 포장 재 포함
  READ TABLE GT_2340_CHG INTO DATA(LS_2340_CHK) INDEX 1.
  IF SY-SUBRC EQ 0.
    READ TABLE GT_2330 INTO DATA(LS_2330) WITH KEY MATNR = LS_2340_CHK-MATNR
                                                               ZWKREQ = LS_2340_CHK-ZWKREQ.
    IF SY-SUBRC EQ 0 AND LS_2330-DMORD IS NOT INITIAL AND LS_2330-DMORDTY = 'SO'.
      PERFORM SET_IMGAGONG_RESB_POJANG USING LS_2330 CHANGING PV_CHK_ERR.

    ENDIF.
  ENDIF.


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
      DYNPPROG          = 'ZGTPPR2270'
      DYNPNR            = SY-DYNNR
*     VALUE             = 'P_WERKS'
*     MULTIPLE_CHOICE   = ' '
*     DISPLAY           = ' '
*     SUPPRESS_RECORDLIST       = ' '
      CALLBACK_PROGRAM  = 'ZGTPPR2270'
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
*& Form DISPLAY_POPUP_CHAR_BAX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_100
*&---------------------------------------------------------------------*
FORM DISPLAY_POPUP_CHAR_BAX  USING    PS_MAIN_100 LIKE GS_MAIN_DISP.

  DATA : LV_VBELN TYPE VBAP-VBELN.
  DATA : LV_POSNR TYPE VBAP-POSNR.
  DATA : LV_COUBJ TYPE CUOBJ_VA.
  DATA : LV_ATINN TYPE ATINN.
  DATA : LV_VALUE TYPE CHAR30.
  DATA : LV_BCOS_TSTMP TYPE BCOS_TSTMP.
  DATA : LV_INPUT_NAME TYPE ATWRT.
  DATA : LV_IDX TYPE I.


  GET TIME STAMP FIELD LV_BCOS_TSTMP.

  REFRESH GT_POP_BOX.

  LV_VBELN = PS_MAIN_100-VBELN.
  __ALPHA_INPUT LV_VBELN.
  LV_POSNR = PS_MAIN_100-POSNR.

  SELECT SINGLE CUOBJ
   INTO LV_COUBJ
   FROM VBAP
 WHERE VBELN = LV_VBELN
    AND POSNR = LV_POSNR.

  CHECK LV_COUBJ IS NOT INITIAL.
* 판매오더로 특성정보 가져오기
  REFRESH GT_CHART.
  SELECT B~*
    INTO  TABLE @GT_CHART
    FROM IBIN AS A
    INNER JOIN V_IBIN_SYVAL AS B ON B~IN_RECNO = A~IN_RECNO
   WHERE A~INSTANCE = @LV_COUBJ
     AND A~VALFR <= @LV_BCOS_TSTMP
     AND A~VALTO > @LV_BCOS_TSTMP .

  DO 4 TIMES.
    ADD 1 TO LV_IDX.
    CLEAR GS_POP_BOX.
    GS_POP_BOX-SEQNO = LV_IDX.
    CASE LV_IDX.
      WHEN 1.
        GS_POP_BOX-GOBUN = '1ST'.
      WHEN 2.
        GS_POP_BOX-GOBUN = '2ND'.
      WHEN 3.
        GS_POP_BOX-GOBUN = '3RD'.
      WHEN 4.
        GS_POP_BOX-GOBUN = '4TH'.
    ENDCASE.

    PERFORM GET_CHART_VALUE_BOX CHANGING GS_POP_BOX.
    APPEND GS_POP_BOX TO GT_POP_BOX.
  ENDDO.

  SORT GT_POP_BOX BY SEQNO.

  CALL SCREEN '0800' STARTING AT 5 5 ENDING AT 80 10.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CHART_VALUE_BOX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_POP_BOX
*&---------------------------------------------------------------------*
FORM GET_CHART_VALUE_BOX  CHANGING PS_POP_BOX LIKE GS_POP_BOX.

  DATA : LV_ATNAM(30).
  CONSTANTS : LC_BX(30)        VALUE 'PD_GL_PACKING_BX_',
              LC_PA(30)        VALUE 'PD_GL_PACKING_PA_',
              LC_PA_CNT(30)    VALUE 'PD_GL_PACKING_PA_CNT_',
              LC_BX_PER_PA(30) VALUE 'PD_GL_PACKING_BX_PER_PA_',
              LC_CONTENTS(30)  VALUE 'PD_GL_PACKING_CONTENTS_'.

* BOX 포장재 속성
  CLEAR LV_ATNAM.
  LV_ATNAM = LC_BX && PS_POP_BOX-GOBUN.
  PERFORM GET_CHAR_VALUE USING LV_ATNAM 'C' CHANGING PS_POP_BOX-MATNR_B.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT        = PS_POP_BOX-MATNR_B
    IMPORTING
      OUTPUT       = PS_POP_BOX-MATNR_B
    EXCEPTIONS
      LENGTH_ERROR = 1
      OTHERS       = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

* BOX명
  PS_POP_BOX-MAKTX_B = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = PS_POP_BOX-MATNR_B ).

* Pallet 속성
  LV_ATNAM = LC_PA && PS_POP_BOX-GOBUN.
  PERFORM GET_CHAR_VALUE USING LV_ATNAM 'C' CHANGING PS_POP_BOX-MATNR_P.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT        = PS_POP_BOX-MATNR_P
    IMPORTING
      OUTPUT       = PS_POP_BOX-MATNR_P
    EXCEPTIONS
      LENGTH_ERROR = 1
      OTHERS       = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

* Pallet명
  PS_POP_BOX-MAKTX_P = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = PS_POP_BOX-MATNR_P ).

* Pallet 수량
  CLEAR LV_ATNAM.
  LV_ATNAM = LC_PA_CNT && PS_POP_BOX-GOBUN.
  PERFORM GET_CHAR_VALUE USING LV_ATNAM 'P' CHANGING PS_POP_BOX-MENGE01.

* Pallet당 Box 수량
  CLEAR LV_ATNAM.
  LV_ATNAM = LC_BX_PER_PA && PS_POP_BOX-GOBUN.
  PERFORM GET_CHAR_VALUE USING LV_ATNAM 'P' CHANGING PS_POP_BOX-MENGE02.

* 포장재 비고
  CLEAR LV_ATNAM.
  LV_ATNAM = LC_CONTENTS && PS_POP_BOX-GOBUN.
  PERFORM GET_CHAR_VALUE USING LV_ATNAM 'C' CHANGING PS_POP_BOX-BIGO.

  TRANSLATE PS_POP_BOX-GOBUN TO LOWER CASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CHAR_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ATNAM
*&      --> P_
*&      <-- PS_POP_BOX_MAKTX_B
*&---------------------------------------------------------------------*
FORM GET_CHAR_VALUE  USING    PV_ATNAM
                              PV_BUBUN
                     CHANGING PV_VALUE.

  DATA : LV_ATINN TYPE ATINN.
  DATA : LV_VALUE TYPE CHAR20.

  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      INPUT  = PV_ATNAM
    IMPORTING
      OUTPUT = LV_ATINN.

  CHECK LV_ATINN IS NOT INITIAL.

  READ TABLE GT_CHART INTO DATA(LS_CHAR) WITH KEY ATINN = LV_ATINN.
  IF SY-SUBRC EQ 0.
    CASE PV_BUBUN.
      WHEN 'C'.
        PV_VALUE = LS_CHAR-ATWRT.
      WHEN OTHERS.
        CLEAR LV_VALUE.
        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
          EXPORTING
            DECIM = 3
            INPUT = LS_CHAR-ATFLV
          IMPORTING
            FLSTR = LV_VALUE.
        PV_VALUE = LV_VALUE + 0.
    ENDCASE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0800
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0800 .

  CREATE OBJECT GO_CONTAIN_0800
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

  CREATE OBJECT GO_GRID_0800
    EXPORTING
      I_PARENT      = GO_CONTAIN_0800
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0800
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0800 .

  CLEAR GS_LAYOUT_0800.
  GS_LAYOUT_0800-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0800-NO_TOOLBAR = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0800
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0800 .

  REFRESH GT_FIELDCAT_0800.

  READ TABLE GT_FIELDCAT_0800 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'SEQNO'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0800 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'SEQNO'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0800 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'GOBUN'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0800 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'GOBUN'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구분'(p01).
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-KEY = ABAP_TRUE.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0800 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'MATNR_B'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0800 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'MATNR_B'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Box 포장재'(p02).
    <LS_FCAT>-COL_POS = 3.
    <LS_FCAT>-REF_TABLE = 'MARA'.
    <LS_FCAT>-REF_FIELD = 'MATNR'.
    <LS_FCAT>-KEY = ABAP_TRUE.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0800 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'MAKTX_B'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0800 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'MAKTX_B'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Box 포장재명'(p03).
    <LS_FCAT>-COL_POS = 4.
    <LS_FCAT>-REF_TABLE = 'MAKT'.
    <LS_FCAT>-REF_FIELD = 'MAKTX'.
    <LS_FCAT>-KEY = ABAP_TRUE.
    <LS_FCAT>-JUST = 'L'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0800 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'MATNR_P'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0800 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'MATNR_P'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Pallet 포장재'(p04).
    <LS_FCAT>-COL_POS = 5.
    <LS_FCAT>-REF_TABLE = 'MARA'.
    <LS_FCAT>-REF_FIELD = 'MATNR'.
    <LS_FCAT>-KEY = ABAP_TRUE.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0800 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'MAKTX_B'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0800 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'MAKTX_P'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Pallet 포장재명'(p05).
    <LS_FCAT>-COL_POS = 6.
    <LS_FCAT>-REF_TABLE = 'MAKT'.
    <LS_FCAT>-REF_FIELD = 'MAKTX'.
    <LS_FCAT>-KEY = ABAP_TRUE.
    <LS_FCAT>-JUST = 'L'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0800 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'MENGE01'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0800 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'MENGE01'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Pallet 수'(p06).
    <LS_FCAT>-COL_POS = 7.
    <LS_FCAT>-DATATYPE = 'NUMC'.
    <LS_FCAT>-DD_OUTLEN = '2'.
    <LS_FCAT>-JUST = 'R'.
    <LS_FCAT>-NO_ZERO = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0800 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'MENGE02'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0800 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'MENGE02'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Box수(Pallet당)'(p07).
    <LS_FCAT>-COL_POS = 7.
    <LS_FCAT>-DATATYPE = 'NUMC'.
    <LS_FCAT>-DD_OUTLEN = '2'.
    <LS_FCAT>-JUST = 'R'.
    <LS_FCAT>-NO_ZERO = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0800 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'BIGO'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0800 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'BIGO'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '포장비고'(p08).
    <LS_FCAT>-COL_POS = 8.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
    <LS_FCAT>-JUST = 'L'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0800_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0800_DISPLAY .

  CALL METHOD GO_GRID_0800->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT          = GS_LAYOUT_0800
      I_BYPASSING_BUFFER = ABAP_TRUE
    CHANGING
      IT_OUTTAB          = GT_POP_BOX
      IT_FIELDCATALOG    = GT_FIELDCAT_0800.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_RESB_POJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_2330
*&---------------------------------------------------------------------*
FORM CHANGE_RESB_POJANG  USING    PS_2330 TYPE ZGTPPT2330
                                            PV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER
                              CHANGING PV_CHK_ERR.

  DATA :LV_VBELN TYPE VBAK-VBELN.
  DATA :LV_POSNR TYPE VBAP-POSNR.
  DATA : LV_PACK_YN TYPE CHAR10.
  DATA : LV_PACK_NO TYPE MATNR.
  DATA : LV_PACK_TYPE TYPE CHAR10.
  DATA : LV_AUFNR TYPE AUFNR.
  DATA : LV_DISPO TYPE MARC-DISPO.
  DATA : LS_REQU_QUAN TYPE COXT_S_QUANTITY.
  DATA : LV_STORAGE_LOCATION TYPE COXT_S_STORAGE_LOCATION.
  DATA : LV_STORAGE_LOCATIONX TYPE COXT_S_STORAGE_LOCATIONX.
  DATA : LV_POSNO TYPE CIF_R3RES-POSITIONNO.
  DATA : LS_RETURN TYPE COXT_BAPIRETURN.
  DATA : LT_STB TYPE TABLE OF STPOX.
  DATA : LV_ERROR.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = PS_2330-DMORD
    IMPORTING
      OUTPUT = LV_VBELN.
  LV_POSNR = PS_2330-DMLINE.

  CASE PS_2330-GONG_CD.
    WHEN 'REW'. " 권취는 박스저장
      RETURN.
***      임시주석처리
      PERFORM GET_BOX_CHART USING PS_2330.
      CHECK GT_POP_BOX IS NOT INITIAL.

* 기존 저장된 포장재 박스 컴포넌트 삭제
      LV_AUFNR = PV_ORDER_NUMBER.
      PERFORM CO_COMPONENTS_DELETE USING LV_AUFNR.
      WAIT UP TO '0.3' SECONDS.

* 박스 포장재 추가
      SELECT SINGLE B~APLZL, B~PLNFL
        INTO ( @DATA(LV_OPERATION), @DATA(LV_SEQUENCE) )
        FROM AFKO AS A
       INNER JOIN AFVC AS B ON B~AUFPL EQ A~AUFPL
       WHERE A~AUFNR EQ @LV_AUFNR
          AND B~APLFL = '000000'
          AND B~RUECK NE ''.

      LOOP AT GT_POP_BOX INTO DATA(LS_POP_BOX) WHERE MATNR_B IS NOT INITIAL.
        SELECT SINGLE A~MEINS
          FROM MARA AS A
          INNER JOIN MARC AS B ON B~MATNR = A~MATNR
          INTO @DATA(LV_MEINS)
         WHERE A~MATNR = @LS_POP_BOX-MATNR_B
            AND A~LVORM = ''
            AND B~WERKS = @P_WERKS
            AND B~LVORM = ''.

        IF LV_MEINS IS INITIAL.
          PV_CHK_ERR = 'D'.
          RETURN.
        ENDIF.

        REFRESH LT_STB.
* 박스 포장재는 가상품목으로 존재 하므로 해당 자재BOM 조회후 구성하기
        PERFORM GET_BOX_BOM TABLES LT_STB USING LS_POP_BOX.

        LOOP AT LT_STB INTO DATA(LS_STB).
          CLEAR LS_REQU_QUAN.
          LS_REQU_QUAN-QUANTITY = LS_STB-MNGKO.
          LS_REQU_QUAN-UOM = LS_STB-MEINS.

          CLEAR LV_STORAGE_LOCATION.
          LV_STORAGE_LOCATION-WERKS = P_WERKS.
          LV_STORAGE_LOCATIONX-WERKS = ABAP_TRUE.

          SELECT SINGLE MAX( B~POSNR ) AS POSNR
            FROM AFKO AS A
            INNER JOIN RESB AS B
                                   ON B~RSNUM = A~RSNUM
           WHERE A~AUFNR = @LV_AUFNR
             GROUP BY B~RSNUM
             INTO @DATA(LV_RESBPOSNR).

          LV_RESBPOSNR = LV_RESBPOSNR + 10.

          CALL FUNCTION 'CONVERSION_EXIT_NUMCV_INPUT'
            EXPORTING
              INPUT  = LV_RESBPOSNR
            IMPORTING
              OUTPUT = LV_RESBPOSNR.
          LV_POSNO = LV_RESBPOSNR.

          CALL FUNCTION 'CO_XT_COMPONENT_ADD'
            EXPORTING
              IS_ORDER_KEY         = LV_AUFNR
              I_MATERIAL           = LS_STB-IDNRK
              IS_REQU_QUAN         = LS_REQU_QUAN
              I_OPERATION          = LV_OPERATION
              I_SEQUENCE           = LV_SEQUENCE
              IS_STORAGE_LOCATION  = LV_STORAGE_LOCATION
              IS_STORAGE_LOCATIONX = LV_STORAGE_LOCATIONX
              I_POSTP              = 'L'
              I_POSNO              = LV_POSNO
            IMPORTING
              ES_BAPIRETURN        = LS_RETURN
              E_ERROR_OCCURRED     = LV_ERROR.
          IF LV_ERROR = SPACE.

            ASSIGN ('(SAPLCOBC)RESB_BT[]') TO FIELD-SYMBOL(<FT_RESB_BT>).
            LOOP AT <FT_RESB_BT> ASSIGNING FIELD-SYMBOL(<FS_RESB_BT>).

              ASSIGN COMPONENT 'MATNR' OF STRUCTURE <FS_RESB_BT> TO FIELD-SYMBOL(<LV_MATNR>).
              IF <LV_MATNR> = LS_STB-IDNRK.

                ASSIGN COMPONENT 'POSNR' OF STRUCTURE <FS_RESB_BT> TO FIELD-SYMBOL(<LV_POSNR>).
                <LV_POSNR> = LV_POSNO.
                ASSIGN COMPONENT 'RGEKZ' OF STRUCTURE <FS_RESB_BT> TO FIELD-SYMBOL(<LV_RGEKZ>).
                <LV_RGEKZ> = ABAP_TRUE.
              ENDIF.
            ENDLOOP.


            CALL FUNCTION 'CO_XT_ORDER_PREPARE_COMMIT'
              IMPORTING
                ES_BAPIRETURN    = LS_RETURN
                E_ERROR_OCCURRED = LV_ERROR.
            IF ( LS_RETURN-TYPE = 'S' OR
                 LS_RETURN-TYPE = 'W' OR
                 LS_RETURN-TYPE = 'I' ) OR
                 LS_RETURN IS INITIAL.
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
              WAIT UP TO '0.5' SECONDS.
              CALL FUNCTION 'CO_XT_ORDER_INITIALIZE'.
            ELSE.
              CLEAR: LV_ERROR,
                     LS_RETURN.
              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
              PV_CHK_ERR = ABAP_TRUE.
              RETURN.

            ENDIF.
          ELSE.
            CLEAR LV_ERROR.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
            PV_CHK_ERR = ABAP_TRUE.
            RETURN.
          ENDIF.

        ENDLOOP.

      ENDLOOP.


    WHEN 'SHE'.  " 피복은 드럼 저장

      ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
        EXPORTING
          IV_VBELN      =  LV_VBELN                " 판매 관리 문서 번호
          IV_POSNR      = LV_POSNR                 " SD 문서의 품목 번호
        IMPORTING
          EV_PACK_YN    = LV_PACK_YN
          EV_PACK_NO    = LV_PACK_NO
          EV_PACK_TYPE  = LV_PACK_TYPE ).

      IF LV_PACK_YN = 'CM'. " 포장재 지정상태와 드럼유형만 대상

        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            INPUT        = LV_AUFNR
          IMPORTING
            OUTPUT       = LV_AUFNR
          EXCEPTIONS
            LENGTH_ERROR = 1
            OTHERS       = 2.

        LV_AUFNR = PV_ORDER_NUMBER.

        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            INPUT        = LV_PACK_NO
          IMPORTING
            OUTPUT       = LV_PACK_NO
          EXCEPTIONS
            LENGTH_ERROR = 1
            OTHERS       = 2.

        SELECT B~*
          FROM AFKO AS A
          INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
         WHERE A~AUFNR = @LV_AUFNR
            AND B~MATNR = @LV_PACK_NO
           INTO TABLE @DATA(LT_RESB).
        IF SY-SUBRC EQ 0.
          LOOP AT LT_RESB INTO DATA(LS_RESB).

            LS_RESB-BDMNG = 1.
            LS_RESB-ERFMG = 1.
            UPDATE RESB SET BDMNG = LS_RESB-BDMNG
                                      ERFMG = LS_RESB-ERFMG
            WHERE  RSNUM = LS_RESB-RSNUM
               AND  RSPOS = LS_RESB-RSPOS.

            IF SY-SUBRC EQ 0.
              COMMIT WORK AND WAIT.
            ELSE.
              ROLLBACK WORK.
              EXIT.
            ENDIF.
          ENDLOOP.
        ELSE."생산 오더 BOM에 없는 경우 오더 BOM 추가
          SELECT SINGLE DISPO FROM MARC
            INTO LV_DISPO
           WHERE MATNR = LV_PACK_NO
             AND WERKS = P_WERKS.

          SELECT B~*
                  FROM AFKO AS A
                  INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
                 INNER JOIN MARA AS C ON C~MATNR = B~MATNR
                 INNER JOIN MARC AS D ON D~MATNR = B~MATNR
                                               AND D~WERKS = @P_WERKS
                 WHERE A~AUFNR = @LV_AUFNR
                   AND C~MTART LIKE 'MRM%'
                   AND D~DISPO = @LV_DISPO
                   INTO TABLE @LT_RESB.
          IF SY-SUBRC EQ 0.
            LOOP AT LT_RESB INTO LS_RESB.
              LS_RESB-MATNR = LV_PACK_NO.
              LS_RESB-BDMNG = 1.
              LS_RESB-ERFMG = 1.
              UPDATE RESB SET MATNR = LS_RESB-MATNR
                                        BDMNG = LS_RESB-BDMNG
                                        ERFMG = LS_RESB-ERFMG
              WHERE  RSNUM = LS_RESB-RSNUM
                 AND  RSPOS = LS_RESB-RSPOS.
              IF SY-SUBRC EQ 0.
                COMMIT WORK AND WAIT.
              ELSE.
                ROLLBACK WORK.
                EXIT.
              ENDIF.
            ENDLOOP.
          ELSE.

            SELECT SINGLE B~APLZL, B~PLNFL
              INTO ( @LV_OPERATION, @LV_SEQUENCE )
              FROM AFKO AS A
             INNER JOIN AFVC AS B ON B~AUFPL EQ A~AUFPL
             WHERE A~AUFNR EQ @LV_AUFNR
                AND B~APLFL = '000000'
                AND B~RUECK NE ''.

            SELECT SINGLE MEINS FROM MARA
              INTO @LV_MEINS
             WHERE MATNR = @LV_PACK_NO.


            LS_REQU_QUAN-QUANTITY = 1.
            LS_REQU_QUAN-UOM = LV_MEINS.

            LV_STORAGE_LOCATION-WERKS = P_WERKS.
            LV_STORAGE_LOCATIONX-WERKS = ABAP_TRUE.

            SELECT SINGLE MAX( B~POSNR ) AS POSNR
              FROM AFKO AS A
              INNER JOIN RESB AS B
                                     ON B~RSNUM = A~RSNUM
             WHERE A~AUFNR = @LV_AUFNR
               GROUP BY B~RSNUM
               INTO @LV_RESBPOSNR.

            LV_RESBPOSNR = LV_RESBPOSNR + 10.

            CALL FUNCTION 'CONVERSION_EXIT_NUMCV_INPUT'
              EXPORTING
                INPUT  = LV_RESBPOSNR
              IMPORTING
                OUTPUT = LV_RESBPOSNR.
            LV_POSNO = LV_RESBPOSNR.

            CALL FUNCTION 'CO_XT_COMPONENT_ADD'
              EXPORTING
                IS_ORDER_KEY         = LV_AUFNR
                I_MATERIAL           = LV_PACK_NO
                IS_REQU_QUAN         = LS_REQU_QUAN
                I_OPERATION          = LV_OPERATION
                I_SEQUENCE           = LV_SEQUENCE
                IS_STORAGE_LOCATION  = LV_STORAGE_LOCATION
                IS_STORAGE_LOCATIONX = LV_STORAGE_LOCATIONX
                I_POSTP              = 'L'
                I_POSNO              = LV_POSNO
              IMPORTING
                ES_BAPIRETURN        = LS_RETURN
                E_ERROR_OCCURRED     = LV_ERROR.
            IF LV_ERROR = SPACE.

              ASSIGN ('(SAPLCOBC)RESB_BT[]') TO <FT_RESB_BT>.
              LOOP AT <FT_RESB_BT> ASSIGNING <FS_RESB_BT>.

                ASSIGN COMPONENT 'MATNR' OF STRUCTURE <FS_RESB_BT> TO <LV_MATNR>.
                IF <LV_MATNR> = LV_PACK_NO.

                  ASSIGN COMPONENT 'POSNR' OF STRUCTURE <FS_RESB_BT> TO <LV_POSNR>.
                  <LV_POSNR> = LV_POSNO.
                  ASSIGN COMPONENT 'RGEKZ' OF STRUCTURE <FS_RESB_BT> TO <LV_RGEKZ>.
                  <LV_RGEKZ> = ABAP_TRUE.
                ENDIF.
              ENDLOOP.


              CALL FUNCTION 'CO_XT_ORDER_PREPARE_COMMIT'
                IMPORTING
                  ES_BAPIRETURN    = LS_RETURN
                  E_ERROR_OCCURRED = LV_ERROR.
              IF ( LS_RETURN-TYPE = 'S' OR
                   LS_RETURN-TYPE = 'W' OR
                   LS_RETURN-TYPE = 'I' ) OR
                   LS_RETURN IS INITIAL.
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
                WAIT UP TO '0.5' SECONDS.
                CALL FUNCTION 'CO_XT_ORDER_INITIALIZE'.
              ELSE.
                CLEAR: LV_ERROR,
                       LS_RETURN.
                CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
              ENDIF.
            ELSE.
              CLEAR LV_ERROR.
              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_BOX_CHART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_2330
*&---------------------------------------------------------------------*
FORM GET_BOX_CHART  USING    PS_2330 TYPE ZGTPPT2330.

  DATA : LV_VBELN TYPE VBAP-VBELN.
  DATA : LV_POSNR TYPE VBAP-POSNR.
  DATA : LV_COUBJ TYPE CUOBJ_VA.
  DATA : LV_ATINN TYPE ATINN.
  DATA : LV_VALUE TYPE CHAR30.
  DATA : LV_BCOS_TSTMP TYPE BCOS_TSTMP.
  DATA : LV_INPUT_NAME TYPE ATWRT.
  DATA : LV_IDX TYPE I.

  GET TIME STAMP FIELD LV_BCOS_TSTMP.

  REFRESH GT_POP_BOX.

  LV_VBELN = PS_2330-DMORD.
  __ALPHA_INPUT LV_VBELN.
  LV_POSNR = PS_2330-DMLINE.

  SELECT SINGLE CUOBJ
   INTO LV_COUBJ
   FROM VBAP
 WHERE VBELN = LV_VBELN
    AND POSNR = LV_POSNR.

  CHECK LV_COUBJ IS NOT INITIAL.
* 판매오더로 특성정보 가져오기
  REFRESH GT_CHART.
  SELECT B~*
    INTO  TABLE @GT_CHART
    FROM IBIN AS A
    INNER JOIN V_IBIN_SYVAL AS B ON B~IN_RECNO = A~IN_RECNO
   WHERE A~INSTANCE = @LV_COUBJ
     AND A~VALFR <= @LV_BCOS_TSTMP
     AND A~VALTO > @LV_BCOS_TSTMP .

  DO 4 TIMES.
    ADD 1 TO LV_IDX.
    CLEAR GS_POP_BOX.
    GS_POP_BOX-SEQNO = LV_IDX.
    CASE LV_IDX.
      WHEN 1.
        GS_POP_BOX-GOBUN = '1ST'.
      WHEN 2.
        GS_POP_BOX-GOBUN = '2ND'.
      WHEN 3.
        GS_POP_BOX-GOBUN = '3RD'.
      WHEN 4.
        GS_POP_BOX-GOBUN = '4TH'.
    ENDCASE.

    PERFORM GET_CHART_VALUE_BOX CHANGING GS_POP_BOX.
    APPEND GS_POP_BOX TO GT_POP_BOX.
  ENDDO.

  SORT GT_POP_BOX BY SEQNO.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CO_COMPONENTS_DELETE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_AUFNR
*&---------------------------------------------------------------------*
FORM CO_COMPONENTS_DELETE  USING    PV_AUFNR TYPE AUFNR.

  DATA : LS_RETURN TYPE COXT_BAPIRETURN.
  DATA : LT_RESBKEYS TYPE COXT_T_RESBDEL,
         LT_RETURN   TYPE STANDARD TABLE OF BAPIRET2,
         LV_ERROR    TYPE FLAG,
         LV_RSNUM    TYPE RESB-RSNUM.

  SELECT B~RSNUM, B~RSPOS
    FROM AFKO AS A
    INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
    INNER JOIN MARA AS C ON C~MATNR = B~MATNR
   WHERE A~AUFNR = @PV_AUFNR
     AND B~MATKL = 'RW600407'
    INTO TABLE @DATA(LT_RESB_BOX).

  IF LT_RESB_BOX[] IS NOT INITIAL.

    IF SY-SUBRC EQ 0.
      LT_RESBKEYS = CORRESPONDING #( LT_RESB_BOX ).
    ENDIF.

* BAPI to delete the components of Production Order
    CALL FUNCTION 'CO_XT_COMPONENTS_DELETE'
      EXPORTING
        IT_RESBKEYS_TO_DELETE = LT_RESBKEYS
      IMPORTING
        E_ERROR_OCCURRED      = LV_ERROR
      TABLES
        CT_BAPIRETURN         = LT_RETURN
      EXCEPTIONS
        DELETE_FAILED         = 1
        OTHERS                = 2.

    CALL FUNCTION 'CO_IT_SET_FLG_ITAB_NEW'.
    IF LV_ERROR = SPACE.
      CALL FUNCTION 'CO_XT_ORDER_PREPARE_COMMIT'
        IMPORTING
          ES_BAPIRETURN    = LS_RETURN
          E_ERROR_OCCURRED = LV_ERROR.
      IF ( LS_RETURN-TYPE = 'S' OR
           LS_RETURN-TYPE = 'W' OR
           LS_RETURN-TYPE = 'I' ) OR
           LS_RETURN IS INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        WAIT UP TO '0.5' SECONDS.
        CALL FUNCTION 'CO_XT_ORDER_INITIALIZE'.
      ELSE.
        CLEAR: LV_ERROR,
               LS_RETURN.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDIF.
    ELSE.
      CLEAR LV_ERROR.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ENDIF.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_IMGAGONG_RESB_POJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_2330
*&---------------------------------------------------------------------*
FORM SET_IMGAGONG_RESB_POJANG  USING    PS_2330 TYPE ZGTPPT2330
                                                   CHANGING PV_CHK_ERR.

  DATA :LV_VBELN TYPE VBAK-VBELN.
  DATA :LV_POSNR TYPE VBAP-POSNR.
  DATA : LV_PACK_YN TYPE CHAR10.
  DATA : LV_PACK_NO TYPE MATNR.
  DATA : LV_PACK_DM TYPE MATNR.
  DATA : LV_PACK_TYPE TYPE CHAR10.
  DATA : LV_MESSAGE(100).
  DATA : LV_MESSAGE2(100).
  DATA : LT_STB TYPE TABLE OF STPOX.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = PS_2330-DMORD
    IMPORTING
      OUTPUT = LV_VBELN.
  LV_POSNR = PS_2330-DMLINE.

  CASE PS_2330-GONG_CD.
    WHEN 'REW'. " 권취는 박스저장

* 포장 유무 확인
      ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
        EXPORTING
          IV_VBELN      = LV_VBELN                " 구성
          IV_POSNR      = LV_POSNR                " 구성
        IMPORTING
          EV_PACK_YN = LV_PACK_YN  ).

      CASE LV_PACK_YN.
        WHEN 'CM'.
        WHEN 'NA'. " 대상 아님 종료처리
          RETURN.
        WHEN OTHERS.

          PV_CHK_ERR = ABAP_TRUE.
          CLEAR LV_MESSAGE.
          LV_MESSAGE = PS_2330-DMORD && '/' && PS_2330-DMLINE.
          CONCATENATE 'S/O' LV_MESSAGE '에 대한 포장재 지정이 완료되지 않았습니다.'
                        INTO LV_MESSAGE SEPARATED BY SPACE.
          LV_MESSAGE2 = '영업 및 설계팀에 문의 바랍니다.'.
          MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MESSAGE LV_MESSAGE2.
          RETURN.
      ENDCASE.

      PERFORM GET_BOX_CHART USING PS_2330.
      CHECK GT_POP_BOX IS NOT INITIAL.

* 기존 저장된 포장재 박스 컴포넌트 삭제
      SELECT A~MATNR
        FROM @GT_IMGAGONG_RESB AS A
        INNER JOIN MARA AS B ON B~MATNR = A~MATNR
       WHERE B~MATKL = 'R0020301'
        INTO @DATA(LV_MATNR).

        DELETE GT_IMGAGONG_RESB WHERE MATNR = LV_MATNR.

      ENDSELECT.

      LOOP AT GT_POP_BOX INTO DATA(LS_POP_BOX) WHERE MATNR_B IS NOT INITIAL.
        SELECT SINGLE A~MEINS
          FROM MARA AS A
          INNER JOIN MARC AS B ON B~MATNR = A~MATNR
          INTO @DATA(LV_MEINS)
         WHERE A~MATNR = @LS_POP_BOX-MATNR_B
            AND A~LVORM = ''
            AND B~WERKS = @P_WERKS
            AND B~LVORM = ''.

        IF LV_MEINS IS INITIAL.
          PV_CHK_ERR = ABAP_TRUE.
          CLEAR LV_MESSAGE.
          LV_MESSAGE = PS_2330-DMORD && '/' && PS_2330-DMLINE.
          CONCATENATE 'S/O' LV_MESSAGE '에 대한 포장재 지정이 완료되지 않았습니다.'
                        INTO LV_MESSAGE SEPARATED BY SPACE.
          LV_MESSAGE2 = '영업 및 설계팀에 문의 바랍니다.'.
          MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MESSAGE LV_MESSAGE2.
          RETURN.
        ENDIF.

        REFRESH LT_STB.
* 박스 포장재는 가상품목으로 존재 하므로 해당 자재BOM 조회후 구성하기
        PERFORM GET_BOX_BOM TABLES LT_STB USING LS_POP_BOX.

        LOOP AT LT_STB INTO DATA(LS_STB).

          APPEND INITIAL LINE TO GT_IMGAGONG_RESB ASSIGNING FIELD-SYMBOL(<LS_IMGAGONG_RESB>).
          <LS_IMGAGONG_RESB>-MATNR = LS_STB-IDNRK.
          <LS_IMGAGONG_RESB>-WERKS = P_WERKS.
          <LS_IMGAGONG_RESB>-ERFME = LS_STB-MEINS.
          <LS_IMGAGONG_RESB>-ERFMG = LS_STB-MNGKO.

*          APPEND INITIAL LINE TO GT_IMGAGONG_RESB ASSIGNING FIELD-SYMBOL(<LS_IMGAGONG_RESB>).
*          <LS_IMGAGONG_RESB>-MATNR = LS_POP_BOX-MATNR_B.
*          <LS_IMGAGONG_RESB>-WERKS = P_WERKS.
*          <LS_IMGAGONG_RESB>-ERFME = 'EA'.
*          <LS_IMGAGONG_RESB>-ERFMG = LS_POP_BOX-MENGE01 * LS_POP_BOX-MENGE02.
        ENDLOOP.
      ENDLOOP.


    WHEN 'SHE'.  " 피복은 드럼 저장

      ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
        EXPORTING
          IV_VBELN      =  LV_VBELN                " 판매 관리 문서 번호
          IV_POSNR      = LV_POSNR                 " SD 문서의 품목 번호
        IMPORTING
          EV_PACK_YN    = LV_PACK_YN
          EV_PACK_NO    = LV_PACK_NO
          EV_PACK_TYPE  = LV_PACK_TYPE
          EV_PACK_DM = LV_PACK_DM ).

      IF LV_PACK_YN = 'CM' AND LV_PACK_DM IS NOT INITIAL.
*        IF  LV_PACK_TYPE = 'DM'. " 포장재 지정상태와 드럼유형만 대상
        LV_PACK_NO = LV_PACK_DM.

        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            INPUT        = LV_PACK_NO
          IMPORTING
            OUTPUT       = LV_PACK_NO
          EXCEPTIONS
            LENGTH_ERROR = 1
            OTHERS       = 2.
        IF SY-SUBRC <> 0.
        ENDIF.


* 기존 저장된 드럼 포장자재 삭제
        SELECT A~MATNR
          FROM @GT_IMGAGONG_RESB AS A
          INNER JOIN MARA AS B ON B~MATNR = A~MATNR
         WHERE B~MATKL = 'RW600401'
          INTO @LV_MATNR.

          DELETE GT_IMGAGONG_RESB WHERE MATNR = LV_MATNR.

        ENDSELECT.

        APPEND INITIAL LINE TO GT_IMGAGONG_RESB ASSIGNING <LS_IMGAGONG_RESB>.
        <LS_IMGAGONG_RESB>-MATNR = LV_PACK_NO.
        <LS_IMGAGONG_RESB>-WERKS = P_WERKS.
        <LS_IMGAGONG_RESB>-ERFME = 'EA'.
        <LS_IMGAGONG_RESB>-ERFMG = 1.
*        ENDIF.
      ELSE.
        IF LV_PACK_YN = 'NA'.
          RETURN.
        ENDIF.

        PV_CHK_ERR = ABAP_TRUE.
        CLEAR LV_MESSAGE.
        LV_MESSAGE = PS_2330-DMORD && '/' && PS_2330-DMLINE.
        CONCATENATE 'S/O' LV_MESSAGE '에 대한 포장재 지정이 완료되지 않았습니다.'
                      INTO LV_MESSAGE SEPARATED BY SPACE.
        LV_MESSAGE2 = '영업 및 설계팀에 문의 바랍니다.'.
        MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MESSAGE LV_MESSAGE2.
        RETURN.

      ENDIF.

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PRE_GONG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MATNR_MATNR
*&      --> LS_STB_VERID
*&      <-- PT_2330
*&---------------------------------------------------------------------*
FORM GET_PRE_GONG  TABLES PT_2330 STRUCTURE ZGTPPT2330
                           USING    PV_MATNR TYPE MATNR
                            PV_VERID TYPE MKAL-VERID.

  DATA : LT_STB TYPE TABLE OF STPOX.
  DATA : LT_CSCMAT TYPE TABLE OF CSCMAT.

  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      AUMGB                 = ABAP_ON
      CAPID                 = 'PP01'
      DATUV                 = SY-DATUM
      EHNDL                 = '1'
      MTNRV                 = PV_MATNR " 자재
      WERKS                 = P_WERKS " 플랜트
      MKTLS                 = ABAP_ON
      VERID                 = PV_VERID
      MMORY                 = '1'
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

  SELECT A~IDNRK AS MATNR, B~MTART
    FROM @LT_STB AS A
    INNER JOIN MARA AS B
                          ON B~MATNR = A~IDNRK
    INNER JOIN MARC AS C
                          ON C~MATNR = A~IDNRK
                        AND C~WERKS = @P_WERKS
   WHERE B~MTART   IN ( 'MCFE', 'MCHF' )  " 완제품 반제품만 공정대상
     AND B~MATKL LIKE 'H%'
    INTO TABLE @DATA(LT_SEQ_ROUTING).

  IF LT_SEQ_ROUTING[] IS NOT INITIAL.
    SELECT * FROM ZGTCVMSTVAL
       FOR ALL ENTRIES IN @LT_SEQ_ROUTING
      WHERE WERKS = @P_WERKS
      AND MATNR = @LT_SEQ_ROUTING-MATNR
      INTO TABLE @DATA(LT_MATNR_DETAIL).

    IF SY-SUBRC EQ 0.

      LOOP AT LT_MATNR_DETAIL INTO DATA(LS_MATNR_DETAIL).
        CLEAR PT_2330.
        PT_2330-GONG_CD = LS_MATNR_DETAIL-PDCAPROCCODE.
        PT_2330-MATNR = LS_MATNR_DETAIL-MATNR.
        PERFORM GET_MATNR_INFOR USING LS_MATNR_DETAIL-MATNR
                                 CHANGING PT_2330-MEINS PT_2330-INLENGTH.
        PT_2330-INFACTOR = 1.
        APPEND PT_2330.
      ENDLOOP.
    ENDIF.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_BOX_BOM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_STB
*&      --> LS_POP_BOX
*&---------------------------------------------------------------------*
FORM GET_BOX_BOM  TABLES   PT_STB STRUCTURE STPOX
                  USING    PS_POP_BOX LIKE GS_POP_BOX.

  DATA : LV_EMENG TYPE STKO-BMENG.
  DATA : LT_STB TYPE TABLE OF STPOX.
  DATA : LT_CSCMAT TYPE TABLE OF CSCMAT.

  LV_EMENG = PS_POP_BOX-MENGE01 * PS_POP_BOX-MENGE02.

  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      CAPID                 = 'PP01'
      DATUV                 = SY-DATUM
      EMENG                 = LV_EMENG
      MTNRV                 = PS_POP_BOX-MATNR_B " 자재
      WERKS                 = P_WERKS " 플랜트
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

  APPEND LINES OF LT_STB TO PT_STB[].

ENDFORM.
