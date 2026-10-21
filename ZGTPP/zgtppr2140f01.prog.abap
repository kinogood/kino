*&---------------------------------------------------------------------*
*& Include          ZGTPPR2140F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_INIT_TITLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_INIT_TITLE .

  IF SY-TCODE = 'ZGTPPR2050'.
    SET TITLEBAR '[GT] 조장 구성표 조회 GAON'(t01).
    SY-TITLE = '[GT] 조장 구성표 조회 GAON'(t01).
  ENDIF.

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
            WHERE WERKS EQ P_KUNNR.
  ELSE.
    CLEAR P_NAME2.
  ENDIF.

* 납품처
  IF NOT P_KUNN2 IS INITIAL.
    CLEAR KNA1.
    SELECT SINGLE NAME1 INTO P_NAME
             FROM KNA1
            WHERE WERKS EQ P_KUNN2.
  ELSE.
    CLEAR P_NAME.
  ENDIF.

  IF SY-TCODE = 'ZGTPPR2050'.
    P_CHEC2 = ABAP_TRUE.
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

    CASE SCREEN-NAME.
      WHEN 'P_NAME' OR 'P_NAME2'.
        SCREEN-INPUT = 0.
        SCREEN-INTENSIFIED = 1.
        MODIFY SCREEN.
    ENDCASE.

    IF SCREEN-GROUP1 = 'M2'.
      SCREEN-INPUT = 0.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDIF.

    CASE SY-TCODE.
      WHEN 'ZGTPPR2050'.
        IF SCREEN-GROUP1 = 'BB'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.

      WHEN OTHERS.
        IF SCREEN-GROUP1 = 'AA'.
          SCREEN-ACTIVE = 0.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.

  ENDLOOP.

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

  CHECK SY-TCODE NE 'ZGTPPR2350'.
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

  DATA : LT_MAIN_DISP_PO LIKE TABLE OF GS_MAIN_DISP.
  DATA : LT_GRPNR TYPE RANGE OF ZGTPPT2000-GRPNR.
  DATA : LT_GRPNR_CHK TYPE RANGE OF ZGTPPT2000-GRPNR.
  DATA : LT_GRPNR_CHK2 TYPE RANGE OF ZGTPPT2000-GRPNR.
  RANGES : LT_KUNNR FOR KNA1-KUNNR.
  DATA : LT_ZSTATUS TYPE RANGE OF ZGTPPT2000-ZSTATUS.

  CLEAR GV_CHK_SUBPOOL_DIR_FULL.

  IF P_KUNNR IS NOT INITIAL.
    APPEND INITIAL LINE TO LT_KUNNR ASSIGNING FIELD-SYMBOL(<LS_KUNNR>).
    IF P_KUNNR CO '*'.
      <LS_KUNNR> = VALUE #( SIGN = 'I' OPTION = 'CP' LOW = P_KUNNR ).
    ELSE.
      <LS_KUNNR> = VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = P_KUNNR ).
    ENDIF.
  ENDIF.

  IF P_KUNN2 IS NOT INITIAL AND SY-TCODE EQ 'ZGTPPR2050'.
    REFRESH LT_KUNNR.
    APPEND INITIAL LINE TO LT_KUNNR ASSIGNING <LS_KUNNR>.
    IF P_KUNN2 CO '*'.
      <LS_KUNNR> = VALUE #( SIGN = 'I' OPTION = 'CP' LOW = P_KUNN2 ).
    ELSE.
      <LS_KUNNR> = VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = P_KUNN2 ).
    ENDIF.
  ENDIF.

  IF P_CHECK IS NOT INITIAL.
    APPEND INITIAL LINE TO LT_ZSTATUS ASSIGNING FIELD-SYMBOL(<LS_ZSTATUS>).
    <LS_ZSTATUS>-SIGN = 'I'.
    <LS_ZSTATUS>-OPTION = 'NE'.
    <LS_ZSTATUS>-LOW = 'D'.
  ENDIF.

  REFRESH GT_MAIN_DISP .

  IF SY-TCODE EQ 'ZGTPPR2050'.
    REFRESH LT_GRPNR.
    IF S_AUFNR[] IS NOT INITIAL.

      LOOP AT S_AUFNR ASSIGNING FIELD-SYMBOL(<LS_AUFNR>).
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = <LS_AUFNR>-LOW
          IMPORTING
            OUTPUT = <LS_AUFNR>-LOW.
      ENDLOOP.

      SELECT * FROM ZGTPPT2010
        WHERE GRPNR IN @S_GRPNR
           AND ORDNR IN @S_AUFNR
          INTO TABLE @DATA(LT_2010_CHK).

      SORT LT_2010_CHK BY GRPNR.
      DELETE ADJACENT DUPLICATES FROM LT_2010_CHK COMPARING GRPNR.

      LOOP AT LT_2010_CHK INTO DATA(LS_2010_CHK).
        APPEND INITIAL LINE TO LT_GRPNR ASSIGNING FIELD-SYMBOL(<LS_GRPNR>).
        <LS_GRPNR>-SIGN = 'I'.
        <LS_GRPNR>-OPTION = 'EQ'.
        <LS_GRPNR>-LOW = LS_2010_CHK-GRPNR.
      ENDLOOP.

    ELSE.

      MOVE-CORRESPONDING S_GRPNR[] TO LT_GRPNR.
    ENDIF.

    SELECT 'I' AS SIGN, 'EQ' AS OPTION, GRPNR AS LOW FROM ZGTPPT2000
      INTO CORRESPONDING FIELDS OF TABLE @LT_GRPNR_CHK
      WHERE SPGCD = @P_SPGCD
      AND WERKS = @P_WERKS
      AND MATNR IN @S_MATNR
      AND MAKTX IN @S_MAKTX
      AND GRPNR IN @LT_GRPNR
      AND ERDAT IN @S_DATE
      AND ORDNO IN @S_ORDN2
      AND KUNNR IN @LT_KUNNR[]
      AND EDATU IN @S_EDAT2
      AND ZSTATUS NE 'D'
      AND GCATG IN ( '판매오더', '견적', '생산오더' ).

    SORT LT_GRPNR_CHK BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_GRPNR_CHK COMPARING LOW.

    IF LT_GRPNR_CHK[] IS NOT INITIAL.
      SELECT * FROM ZGTPPT2000
      INTO CORRESPONDING FIELDS OF TABLE GT_MAIN_DISP
      WHERE SPGCD = P_SPGCD
        AND WERKS = P_WERKS
        AND GRPNR IN LT_GRPNR_CHK.
    ENDIF.

  ELSE.

    IF S_AUFN2[] IS NOT INITIAL.
      SELECT 'I' AS SIGN, 'EQ' AS OPTION, GRPNR AS LOW FROM ZGTPPT2000
        APPENDING CORRESPONDING FIELDS OF TABLE @LT_GRPNR_CHK2
        WHERE SPGCD = @P_SPGCD
        AND WERKS = @P_WERKS
        AND MATNR IN @S_MATNR
        AND MAKTX IN @S_MAKTX
        AND GRPNR IN @S_GRPNR
        AND ERDAT IN @S_DATE
        AND ORDNO IN @S_AUFN2
        AND EDATU IN @S_EDATU
        AND ZZYUSCD IN @S_YUSCD
        AND ZSTATUS IN @LT_ZSTATUS
        AND GCATG EQ '생산오더' .

      SORT LT_GRPNR_CHK2 BY LOW.
      DELETE ADJACENT DUPLICATES FROM LT_GRPNR_CHK2 COMPARING LOW.

      IF LT_GRPNR_CHK2 IS NOT INITIAL AND
        NOT ( S_ORDNO[] IS INITIAL AND LT_KUNNR[] IS INITIAL ).
        SELECT 'I' AS SIGN, 'EQ' AS OPTION, GRPNR AS LOW FROM ZGTPPT2000
          INTO CORRESPONDING FIELDS OF TABLE @LT_GRPNR_CHK
          WHERE SPGCD = @P_SPGCD
            AND WERKS = @P_WERKS
            AND GRPNR IN @LT_GRPNR_CHK2
            AND ORDNO IN @S_ORDNO
            AND KUNNR IN @LT_KUNNR[]
            AND ZZYUSCD IN @S_YUSCD
            AND ZSTATUS IN @LT_ZSTATUS
            AND GCATG IN ( '판매오더', '견적' ).
      ELSE.
        MOVE-CORRESPONDING LT_GRPNR_CHK2 TO LT_GRPNR_CHK.
      ENDIF.

    ELSE.

      IF S_ORDNO[] IS INITIAL AND LT_KUNNR[] IS INITIAL.
        SELECT 'I' AS SIGN, 'EQ' AS OPTION, GRPNR AS LOW FROM ZGTPPT2000
          INTO CORRESPONDING FIELDS OF TABLE @LT_GRPNR_CHK
          WHERE SPGCD = @P_SPGCD
            AND WERKS = @P_WERKS
            AND MATNR IN @S_MATNR
            AND MAKTX IN @S_MAKTX
            AND GRPNR IN @S_GRPNR
            AND ERDAT IN @S_DATE
            AND EDATU IN @S_EDATU
            AND ZZYUSCD IN @S_YUSCD
            AND ZSTATUS IN @LT_ZSTATUS
            AND GCATG IN ( '판매오더', '견적', '생산오더' ).
      ELSE.

        SELECT 'I' AS SIGN, 'EQ' AS OPTION, GRPNR AS LOW FROM ZGTPPT2000
          INTO CORRESPONDING FIELDS OF TABLE @LT_GRPNR_CHK
          WHERE SPGCD = @P_SPGCD
            AND WERKS = @P_WERKS
            AND MATNR IN @S_MATNR
            AND MAKTX IN @S_MAKTX
            AND GRPNR IN @S_GRPNR
            AND ERDAT IN @S_DATE
            AND ORDNO IN @S_ORDNO
            AND KUNNR IN @LT_KUNNR[]
            AND EDATU IN @S_EDATU
            AND ZZYUSCD IN @S_YUSCD
            AND ZSTATUS IN @LT_ZSTATUS
            AND GCATG IN ( '판매오더', '견적' ).
      ENDIF.

    ENDIF.

    SORT LT_GRPNR_CHK BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_GRPNR_CHK COMPARING LOW.

    IF LT_GRPNR_CHK[] IS NOT INITIAL.
      SELECT * FROM ZGTPPT2000
      INTO CORRESPONDING FIELDS OF TABLE GT_MAIN_DISP
      WHERE SPGCD = P_SPGCD
        AND WERKS = P_WERKS
        AND GRPNR IN LT_GRPNR_CHK.
    ENDIF.

  ENDIF.

* 생산오더로 조장구성표 적용되었을 경우 차후에 인터널테이블 구성
  REFRESH LT_MAIN_DISP_PO.
  LT_MAIN_DISP_PO = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP WHERE ( GCATG = '생산오더' )
                                        ( CORRESPONDING #( LW_MAIN ) ) ).

  DELETE GT_MAIN_DISP WHERE GCATG = '생산오더'.

  PERFORM PROC_SET_SO.

  IF LT_MAIN_DISP_PO[] IS NOT INITIAL.
    PERFORM PROC_SET_PO TABLES LT_MAIN_DISP_PO.
  ENDIF.


* 완료처리는 해당 조장 구성표 전체가 완료여야 삭제처리
  LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN_DISP>) WHERE STATUS NE ''.
    CASE ABAP_TRUE.
      WHEN P_CHECK OR P_CHEC2.
      WHEN OTHERS.
        IF <LS_MAIN_DISP>-STATUS = '완료'.
          READ TABLE GT_MAIN_DISP TRANSPORTING NO FIELDS WITH KEY GRPNR = <LS_MAIN_DISP>-GRPNR
                                                                                              STATUS = ' '.
          IF SY-SUBRC NE 0.
            READ TABLE GT_MAIN_DISP TRANSPORTING NO FIELDS WITH KEY GRPNR = <LS_MAIN_DISP>-GRPNR
                                                                                              STATUS = '재고'.
            IF SY-SUBRC NE 0.
              DELETE GT_MAIN_DISP WHERE GRPNR = <LS_MAIN_DISP>-GRPNR.
            ENDIF.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  SORT GT_MAIN_DISP BY GRPNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_SET_SO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_SET_SO .

  TYPES : BEGIN OF TS_CHK_ORDER,
            VBELN TYPE VBAP-VBELN,
            POSNR TYPE VBAP-POSNR,
            MATNR TYPE MATNR,
          END OF TS_CHK_ORDER.
  DATA : LT_CHK_ORDER TYPE TABLE OF TS_CHK_ORDER.
  DATA : LT_CHK_CONFIRM TYPE TABLE OF ZGTCVORDSYVAL.
  DATA : LS_CHK_CONFIRM TYPE ZGTCVORDSYVAL.
  DATA : LV_LINE_C(4).
  DATA : BEGIN OF LS_STOCK_COLLECT,
           VBELN TYPE ZGTCV_STOCKVAL-VBELN,
           POSNR TYPE ZGTCV_STOCKVAL-POSNR,
           LABST TYPE ZGTCV_STOCKVAL-LABST,
           INSME TYPE ZGTCV_STOCKVAL-INSME,
           SPEME TYPE ZGTCV_STOCKVAL-SPEME,
         END OF LS_STOCK_COLLECT.
  DATA : LT_STOCK_COLLECT LIKE TABLE OF LS_STOCK_COLLECT.
  DATA : LV_INLENGTH TYPE ZGTPPT2000-INLENGTH.
  DATA : LV_SO_LENGTH TYPE ZGTPPT2000-INLENGTH.
  DATA : LV_INFACTOR TYPE ZGTPPT2000-INFACTOR.
  DATA : LV_VBELN TYPE VBAP-VBELN,
         LV_POSNR TYPE VBAP-POSNR.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.

  DATA : LV_VBELN_C(12).
  DATA : LV_POSNR_C(6).

  LT_CHK_ORDER =  VALUE  #( FOR LS_MAIN_DISP IN GT_MAIN_DISP WHERE ( ZSTATUS NE 'D' )
                                        ( VBELN = LS_MAIN_DISP-ORDNO POSNR = LS_MAIN_DISP-POSNR MATNR = LS_MAIN_DISP-MATNR ) ).

  SORT LT_CHK_ORDER BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_ORDER COMPARING VBELN POSNR.
  IF LT_CHK_ORDER[] IS NOT INITIAL.

    SELECT DISTINCT AUFNR AS LOW
      FROM AFPO
      INTO CORRESPONDING FIELDS OF TABLE @LT_AUFNR
      FOR ALL ENTRIES IN @LT_CHK_ORDER
    WHERE KDAUF   = @LT_CHK_ORDER-VBELN
        AND KDPOS  = @LT_CHK_ORDER-POSNR.

    IF LT_AUFNR[] IS NOT INITIAL.
      LOOP AT LT_AUFNR ASSIGNING FIELD-SYMBOL(<LS_AUFNR>).
        <LS_AUFNR>-SIGN = 'I'.
        <LS_AUFNR>-OPTION = 'EQ'.
      ENDLOOP.

      SELECT * FROM ZGTCVORDSYVAL
        INTO CORRESPONDING FIELDS OF TABLE LT_CHK_CONFIRM
      WHERE WERKS = P_WERKS
         AND AUFNR IN LT_AUFNR.
    ENDIF.

    SELECT VBELN, POSNR, LGORT, CHARG, LABST, INSME, SPEME
      FROM ZGTCV_STOCKVAL
      FOR ALL ENTRIES IN @LT_CHK_ORDER
      WHERE WERKS = @P_WERKS
          AND MATNR = @LT_CHK_ORDER-MATNR
          AND VBELN = @LT_CHK_ORDER-VBELN
          AND POSNR = @LT_CHK_ORDER-POSNR
         INTO TABLE @DATA(LT_STOCKVAL).

    SELECT VBELN, POSNR, KWMENG, VRKME
      FROM VBAP
      FOR ALL ENTRIES IN @LT_CHK_ORDER
     WHERE VBELN = @LT_CHK_ORDER-VBELN
       AND POSNR = @LT_CHK_ORDER-POSNR
      INTO TABLE @DATA(LT_VBAP).

  ENDIF.

  LOOP AT LT_STOCKVAL INTO DATA(LS_STOCKVAL).
    MOVE-CORRESPONDING LS_STOCKVAL TO LS_STOCK_COLLECT.
    COLLECT LS_STOCK_COLLECT INTO LT_STOCK_COLLECT.
  ENDLOOP.

  SORT LT_CHK_CONFIRM BY GRPNR KDAUF KDPOS .

  DATA : LV_WMENG TYPE ZGTPPT2000-WMENG. " 완료여부 계산 수량

  LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN_DISP>).
    CASE <LS_MAIN_DISP>-ZSTATUS.
      WHEN 'D'.
        <LS_MAIN_DISP>-STATUS = '삭제'.
      WHEN OTHERS. " 완료 여부 확인.

        CLEAR LS_CHK_CONFIRM.

        LOOP AT LT_CHK_CONFIRM INTO LS_CHK_CONFIRM WHERE GRPNR = <LS_MAIN_DISP>-GRPNR
                                                                                  AND KDAUF = <LS_MAIN_DISP>-ORDNO
                                                                                  AND KDPOS = <LS_MAIN_DISP>-POSNR.
          IF LS_CHK_CONFIRM-ELIKZ = ' '.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF LS_CHK_CONFIRM-ELIKZ = 'X'.
          <LS_MAIN_DISP>-STATUS = '완료'.

          READ TABLE LT_STOCK_COLLECT INTO LS_STOCK_COLLECT WITH KEY VBELN = <LS_MAIN_DISP>-ORDNO
                                                                                                     POSNR = <LS_MAIN_DISP>-POSNR.
          IF SY-SUBRC EQ 0.
            DATA(LV_STOCK) = LS_STOCK_COLLECT-LABST + LS_STOCK_COLLECT-INSME + LS_STOCK_COLLECT-SPEME.
            IF LV_STOCK > 0.
              <LS_MAIN_DISP>-STATUS = '재고'.
            ENDIF.

          ENDIF.

        ENDIF.

    ENDCASE.

    CLEAR LV_LINE_C.
    LV_LINE_C = <LS_MAIN_DISP>-LINNO.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LV_LINE_C
      IMPORTING
        OUTPUT = LV_LINE_C.

    LV_VBELN_C = <LS_MAIN_DISP>-ORDNO.
    LV_POSNR_C = <LS_MAIN_DISP>-POSNR.
    __ALPHA_OUT : LV_VBELN_C, LV_POSNR_C.

    <LS_MAIN_DISP>-ORDNO_C = LV_VBELN_C && '/' && LV_POSNR_C. " && '/' && LV_LINE_C.
    <LS_MAIN_DISP>-NAME1 = ZGTPP_CL_COMMON=>GET_BP_NAME( IV_KUNNR = <LS_MAIN_DISP>-KUNNR  ).
* 오더의 수량은 판매오더 특성정보의 조장 * 조장수
*조장(기본단위)
*조장수
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = <LS_MAIN_DISP>-ORDNO
      IMPORTING
        OUTPUT = LV_VBELN.
    LV_POSNR = <LS_MAIN_DISP>-POSNR + 0.

    CLEAR : LV_INLENGTH, LV_INFACTOR, LV_SO_LENGTH.

    ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
      EXPORTING
        IV_VBELN = LV_VBELN
        IV_POSNR = LV_POSNR
      IMPORTING
        EV_ZGTEINDLEN = LV_INLENGTH
        EV_ZGTEFACTOR = LV_INFACTOR
        EV_SO_INDLEN = LV_SO_LENGTH  ).

    <LS_MAIN_DISP>-WMENG = LV_INLENGTH * LV_INFACTOR.
    <LS_MAIN_DISP>-WMENG2 = -1 * <LS_MAIN_DISP>-WMENG. " 디스플레이용 금액 -처리

* 판매오더 정보 추출
    <LS_MAIN_DISP>-SO_INLENGTH =   LV_SO_LENGTH.
    READ TABLE LT_VBAP INTO DATA(LS_VBAP) WITH KEY VBELN = <LS_MAIN_DISP>-ORDNO
                                                                POSNR = <LS_MAIN_DISP>-POSNR.
    IF SY-SUBRC EQ 0.
      <LS_MAIN_DISP>-SO_WMENG = LS_VBAP-KWMENG.
      <LS_MAIN_DISP>-SO_VRKME = LS_VBAP-VRKME.
    ENDIF.

    IF P_CHECK NE ABAP_TRUE.
      IF <LS_MAIN_DISP>-STATUS = '삭제'.
        DELETE GT_MAIN_DISP.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_SET_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_MAIN_DISP_PO
*&---------------------------------------------------------------------*
FORM PROC_SET_PO  TABLES   PT_PO STRUCTURE GS_MAIN_DISP.

  TYPES : BEGIN OF TS_CHK_ORDER,
            AUFNR    TYPE AFPO-AUFNR,
            POSNR    TYPE ZGTPPT2000-POSNR,
            POSNR_PO TYPE AFPO-POSNR,
            MATNR    TYPE MATNR,
            STATAT   TYPE CHAR10,
          END OF TS_CHK_ORDER.
  DATA : LT_CHK_ORDER TYPE TABLE OF TS_CHK_ORDER.
  DATA : LS_CHK_ORDER TYPE TS_CHK_ORDER.

  DATA : LT_2010 TYPE TABLE OF ZGTPPT2010.

  DATA : BEGIN OF LS_SUM_MSEG,
           AUFNR LIKE MSEG-AUFNR,
           AUFPS LIKE MSEG-AUFPS,
           MENGE LIKE MSEG-MENGE,
         END OF LS_SUM_MSEG.
  DATA : LT_SUM_MSEG LIKE TABLE OF LS_SUM_MSEG.

  DATA : LV_INLENGTH TYPE ZGTPPT2000-INLENGTH.
  DATA : LV_INFACTOR TYPE ZGTPPT2000-INFACTOR.
  DATA : LT_GRPNR TYPE RANGE OF ZGTPPT2000-GRPNR.
  DATA : LT_MAIN LIKE TABLE OF GS_MAIN_DISP.
  DATA : LS_MAIN LIKE GS_MAIN_DISP.
  DATA : LV_STATUS LIKE GS_MAIN_DISP-STATUS.
  DATA : LV_CHK_JEGO.

  DATA : LV_VBELN_C(12).
  DATA : LV_POSNR_C(6).

  REFRESH LT_GRPNR.
  LOOP AT PT_PO INTO DATA(LS_TEMP_MAIN).
    APPEND INITIAL LINE TO LT_GRPNR ASSIGNING FIELD-SYMBOL(<LS_GRPNR>).
    <LS_GRPNR>-SIGN = 'I'.
    <LS_GRPNR>-OPTION = 'EQ'.
    <LS_GRPNR>-LOW = LS_TEMP_MAIN-GRPNR.
  ENDLOOP.

  SORT LT_GRPNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_GRPNR COMPARING LOW.

  SELECT * FROM ZGTPPT2010
    INTO TABLE LT_2010
   WHERE GRPNR IN LT_GRPNR
      AND DMORDTY = 'SM' " SM생산오더와 연결된 생산오더만 추출해서 완료여부 검증
      AND ORDTY = 'PRD'. " 생산오더만 완료여부 검증 가능

  SORT LT_2010 BY GRPNR ORDNR POSNR.

  LOOP AT LT_2010 INTO DATA(LS_2010).
    CLEAR LS_CHK_ORDER.
    LS_CHK_ORDER-AUFNR = LS_2010-ORDNR.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LS_CHK_ORDER-AUFNR
      IMPORTING
        OUTPUT = LS_CHK_ORDER-AUFNR.

    LS_CHK_ORDER-POSNR_PO = LS_2010-POSNR + 0.
    IF LS_2010-REAL_MATNR IS NOT INITIAL.
      LS_CHK_ORDER-MATNR = LS_2010-REAL_MATNR.
    ELSE.
      LS_CHK_ORDER-MATNR = LS_2010-MATNR.
    ENDIF.
    COLLECT LS_CHK_ORDER INTO LT_CHK_ORDER.
  ENDLOOP.

  SORT LT_CHK_ORDER BY AUFNR POSNR_PO.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_ORDER COMPARING AUFNR POSNR.
  IF LT_CHK_ORDER[] IS NOT INITIAL.

    SELECT AUFNR, AUFPS, BWART, CHARG, MENGE
       FROM MSEG
         FOR ALL ENTRIES IN @LT_CHK_ORDER
      WHERE MATNR = @LT_CHK_ORDER-MATNR
          AND BWART IN ('101', '102')
          AND AUFNR = @LT_CHK_ORDER-AUFNR
          AND AUFPS = @LT_CHK_ORDER-POSNR_PO
          AND CHARG NE 'GR_ZERO1'
         INTO TABLE @DATA(LT_MSEG).

    SELECT AUFNR, POSNR, CUOBJ FROM AFPO
      FOR ALL ENTRIES IN @LT_CHK_ORDER
      WHERE AUFNR = @LT_CHK_ORDER-AUFNR
          AND POSNR = @LT_CHK_ORDER-POSNR_PO
        INTO TABLE @DATA(LT_AFPO).

  ENDIF.

  LOOP AT LT_MSEG INTO DATA(LS_MSEG).
    CLEAR LS_SUM_MSEG.
    LS_SUM_MSEG-AUFNR = LS_MSEG-AUFNR.
    LS_SUM_MSEG-AUFPS = LS_MSEG-AUFPS.
    CASE LS_MSEG-BWART.
      WHEN '101'.
        LS_SUM_MSEG-MENGE = LS_MSEG-MENGE .
      WHEN '102'.
        LS_SUM_MSEG-MENGE = LS_MSEG-MENGE * -1.
    ENDCASE.
    COLLECT LS_SUM_MSEG INTO LT_SUM_MSEG.
  ENDLOOP.


  DATA : LV_WMENG TYPE ZGTPPT2000-WMENG. " 완료여부 계산 수량


  LOOP AT PT_PO INTO LS_TEMP_MAIN.
    CLEAR LS_MAIN.
    MOVE-CORRESPONDING LS_TEMP_MAIN TO LS_MAIN.

    LV_VBELN_C = LS_MAIN-ORDNO.
    LV_POSNR_C = LS_MAIN-POSNR.
    __ALPHA_OUT : LV_VBELN_C, LV_POSNR_C.
    LS_MAIN-ORDNO_C = LV_VBELN_C && '/' && LV_POSNR_C.

    LS_MAIN-WMENG = LS_MAIN-INLENGTH * LS_MAIN-INFACTOR.
    LS_MAIN-WMENG2 = -1 * LS_MAIN-WMENG. " 디스플레이용 금액 -처리

    IF LS_MAIN-ZSTATUS = 'D'.
      LS_MAIN-STATUS = '삭제'.
    ELSE.

      CLEAR LV_STATUS.
      CLEAR LV_CHK_JEGO.
      LOOP AT LT_2010 INTO LS_2010 WHERE GRPNR = LS_TEMP_MAIN-GRPNR.
        CLEAR LV_STATUS.
        PERFORM CHECK_STATUS USING LS_2010-ORDNR CHANGING LV_STATUS.
        IF LV_STATUS IS INITIAL.
          READ TABLE LT_SUM_MSEG INTO LS_SUM_MSEG WITH KEY AUFNR = LS_2010-ORDNR
                                                                                          AUFPS = LS_2010-POSNR+2(4).
          IF SY-SUBRC EQ 0 AND LS_SUM_MSEG-MENGE > 0.
            LV_CHK_JEGO = ABAP_TRUE.
          ENDIF.
        ENDIF.

        IF LV_STATUS IS INITIAL.
          EXIT.
        ENDIF.

      ENDLOOP.

      IF LV_STATUS IS INITIAL.
      ELSE.
        IF LV_CHK_JEGO = ABAP_TRUE.
          LS_MAIN-STATUS = '재고'.
        ELSE.
          LS_MAIN-STATUS = LV_STATUS.
        ENDIF.

      ENDIF.

    ENDIF.

    IF P_CHECK NE ABAP_TRUE.
      IF LS_MAIN-STATUS = '삭제'.
        CONTINUE.
      ENDIF.
    ENDIF.

    APPEND LS_MAIN TO GT_MAIN_DISP.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_MAIN_ZSTATUS
*&---------------------------------------------------------------------*
FORM CHECK_STATUS  USING PV_AUFNR
                         CHANGING PV_ZSTATUS.

  DATA : LV_AUFNR TYPE AUFNR.

  LV_AUFNR = PV_AUFNR.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = LV_AUFNR
    IMPORTING
      OUTPUT = LV_AUFNR.

  SELECT SINGLE OBJNR
    INTO @DATA(LV_OBJNR)
    FROM AUFK
   WHERE AUFNR  = @LV_AUFNR.

  SELECT C~ISTAT,    C~SPRAS,    C~TXT04,    C~TXT30,
         A~INACT
    INTO TABLE @DATA(LT_JESTX)
    FROM JEST AS A  INNER JOIN TJ02 AS B
                            ON A~STAT  = B~ISTAT
                    INNER JOIN TJ02T AS C
                            ON A~STAT  = C~ISTAT
   WHERE A~OBJNR  = @LV_OBJNR
     AND A~INACT  = @SPACE
     AND B~NODIS  = @SPACE
     AND C~SPRAS  = @SY-LANGU.

  IF LINE_EXISTS( LT_JESTX[ TXT04 = 'DLV' ] ).
    PV_ZSTATUS = '완료'.
  ENDIF.


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

  CREATE OBJECT GO_CONTAIN_0100
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
  GS_LAYOUT_0100-NO_ROWMARK   = 'X'.
  GS_LAYOUT_0100-SEL_MODE   = 'C'.
  GS_LAYOUT_0100-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT_0100-CTAB_FNAME   = 'CELLCOL'.

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
      I_INCLNAME             = 'ZGTPPR2140TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

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

  APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
  <LS_FCAT>-FIELDNAME = 'STATUS'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '상태'.
  <LS_FCAT>-COL_POS = 1.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '10'.
  <LS_FCAT>-JUST = 'C'.
  <LS_FCAT>-KEY = ABAP_TRUE.

  APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'ORDNO_C'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'.
  <LS_FCAT>-COL_POS = 7.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '30'.
  <LS_FCAT>-JUST = 'C'.
  <LS_FCAT>-KEY = ABAP_TRUE.



  LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'ZSTATUS'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'CHECK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '선택'(f01).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'GRPNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장구성표번호'(f02).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'ERDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작성일'(f03).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'GCATG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '범주'(f04).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품'(f05).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'ORDNO'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'POSNR'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'LINNO'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품내역'(f06).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'KUNNR'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품처'(f07).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'EDATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품요청일'(f08).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'WMENG'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'WMENG2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '총수량'(f09).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장'(f10).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(f11).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(f12).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = '0'.
      WHEN 'SO_WMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매수량'(f14).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = '0'.
      WHEN 'SO_INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매조장'(f15).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = '0'.
      WHEN 'SO_VRKME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매단위'(f16).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ERNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생성자'(f13).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'RQMON'.
        IF P_WERKS = '6600' AND P_SPGCD = 'GO'.
        ELSE.
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDIF.

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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0100 .
* 셀 컬러부여
  DATA : LT_COLTAB TYPE LVC_T_SCOL.
  DATA : LS_COLTAB TYPE LVC_S_SCOL.

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  DATA : BEGIN OF LS_CHK_GRPNR,
           GRPNR TYPE ZGTPPT2010-GRPNR,
           SEQNO TYPE I,
         END OF LS_CHK_GRPNR.
  DATA : LT_CHK_GRPNR LIKE TABLE OF LS_CHK_GRPNR.
  DATA : LV_SEQNO TYPE I.

  DATA(LT_CHK_MAIN) = GT_MAIN_DISP.
  SORT LT_CHK_MAIN BY GRPNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_MAIN COMPARING GRPNR.
  LOOP AT LT_CHK_MAIN INTO DATA(LS_CHK_MAIN).
    CLEAR LS_CHK_GRPNR.
    LS_CHK_GRPNR-GRPNR = LS_CHK_MAIN-GRPNR.
    IF LV_SEQNO = 1.
      LS_CHK_GRPNR-SEQNO = LV_SEQNO.
      LV_SEQNO = 0.
    ELSE.
      LS_CHK_GRPNR-SEQNO = LV_SEQNO.
      LV_SEQNO = 1.
    ENDIF.
    APPEND LS_CHK_GRPNR TO LT_CHK_GRPNR.
  ENDLOOP.

  LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN_DISP>).
    REFRESH LT_COLTAB.
    REFRESH LT_CELLTAB.

    LOOP AT GT_FIELDCAT_0100 INTO DATA(LS_FIELDCAT).
      CASE LS_FIELDCAT-FIELDNAME.
        WHEN 'STATUS'.
          CASE <LS_MAIN_DISP>-STATUS.
            WHEN '삭제'.
*        바탕 빨강
              CLEAR LS_CELLTAB.
              LS_CELLTAB-FIELDNAME = 'STATUS'.
              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_NEGATIVE.
*              LS_CELLTAB-STYLE2 = ALV_STYLE_COLOR_INV_BACKGROUND.
              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
*            체크박스 수정금지
              CLEAR LS_CELLTAB.
              LS_CELLTAB-FIELDNAME = 'CHECK'.
              LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
            WHEN '재고'.
              CLEAR LS_CELLTAB.
              LS_CELLTAB-FIELDNAME = 'STATUS'.
              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_GROUP.
              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
            WHEN '완료'.
            WHEN OTHERS.
              CLEAR LS_COLTAB.
              LS_CELLTAB-FIELDNAME = LS_FIELDCAT-FIELDNAME.
              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_KEY + CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
              INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
          ENDCASE.
        WHEN 'GRPNR' OR 'ERDAT' OR 'ORDNO_C' OR 'GCATG' OR 'MATNR' OR 'MAKTX' OR
                 'KUNNR' OR  'NAME1' OR 'EDATU' OR 'WMENG2' OR 'INLENGTH' OR 'INFACTOR' OR 'ERNAM' OR 'MEINS' OR
                 'SO_WMENG' OR 'SO_INLENGTH' OR 'SO_VRKME' OR 'RQMON'.
*       key 색깔지정
          CLEAR LS_COLTAB.
          LS_CELLTAB-FIELDNAME = LS_FIELDCAT-FIELDNAME.
          READ TABLE LT_CHK_GRPNR INTO LS_CHK_GRPNR WITH KEY GRPNR = <LS_MAIN_DISP>-GRPNR.
          IF SY-SUBRC EQ 0.
            IF LS_CHK_GRPNR-SEQNO = 1.
              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_KEY.
            ELSE.
              LS_CELLTAB-STYLE = ALV_STYLE_COLOR_TOTAL.
            ENDIF.
          ENDIF.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
      ENDCASE.
    ENDLOOP.
    <LS_MAIN_DISP>-CELLCOL = LT_COLTAB.
    <LS_MAIN_DISP>-CELLTAB = LT_CELLTAB.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER  USING  PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
*// Event Handler ##
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED               FOR PO_GRID.
    WHEN GO_GRID_0200.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
    WHEN GO_GRID_0201.
      IF NOT SY-TCODE EQ 'ZGTPPR2350' .
        SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
        SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
        SET HANDLER GO_EVENT_HANDLER->HANDLE_MENU_BUTTON          FOR PO_GRID.
      ENDIF.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_CONTEXT_MENU          FOR PO_GRID.
    WHEN GO_GRID_0220.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
    WHEN GO_GRID_0230.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
    WHEN GO_GRID_0240.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
    WHEN GO_GRID_0300.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOP_OF_PAGE          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED               FOR PO_GRID.
    WHEN GO_GRID_0400.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED               FOR PO_GRID.

  ENDCASE.


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
                            USING : 1 'GRPNR'  'X' '' ''.

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
                                PO_DATA_CHANGED TYPE REF TO
                                          CL_ALV_CHANGED_DATA_PROTOCOL
                                PE_ONF4
                                PE_UCOMM.

  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA: LS_MOD_CELLS TYPE LVC_S_MODI.
  DATA : LV_CALL_FUNC.
  DATA : LV_CHK_ERR.
  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.
  FIELD-SYMBOLS <LV_VALUE> TYPE ANY.

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
    WHEN GO_GRID_0100 OR GO_GRID_0230.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'CHECK'.
            GV_CHK_LINE = LS_MOD_CELLS-ROW_ID.
            GV_CHK_VALUE = LS_MOD_CELLS-VALUE.
            LV_CALL_FUNC = ABAP_TRUE.
        ENDCASE.
      ENDLOOP.
    WHEN GO_GRID_0201.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        SPLIT LS_MOD_CELLS-FIELDNAME AT '_' INTO TABLE DATA(LT_STRING).
        READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 1.
        LV_SEQNO = LS_STRING + 0.
        READ TABLE LT_STRING INTO LS_STRING INDEX 2.
        LV_CHART = LS_STRING.

        READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY CHART = LV_CHART
                                                                                              SEQNO = LV_SEQNO.

        READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_MOD_CELLS-ROW_ID.
        IF SY-SUBRC EQ 0.
          IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
          ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.
          IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
          ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO <LV_LINE>.
          CLEAR LV_NUM.
          CLEAR LV_FIELDNAME.
          LV_NUM =  LS_ROUTING-SEQNO + 0.
          LV_FIELDNAME = LV_NUM && '_SEQNO'.

          IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
          ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.

          READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
          READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
          READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.

* 중복 필드라면 대상이 아님
          IF LS_CHAIN-CHK_DUP EQ ABAP_TRUE.
            CONTINUE.
          ENDIF.

          IF LS_CHAIN-ORDNR IS INITIAL.
            CONTINUE.
          ENDIF.

          IF LS_CHAIN-ORDTY NE 'PRD'.
            CONTINUE.
          ENDIF.

          READ TABLE GT_2010 ASSIGNING FIELD-SYMBOL(<LS_2010>) WITH KEY ORDNR = LS_CHAIN-ORDNR
                                                                          POSNR = LS_CHAIN-POSNR
                                                                           ORDTY = LS_CHAIN-ORDTY.
          IF SY-SUBRC EQ 0.
            IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
            ASSIGN COMPONENT 'CHK_CHAR' OF STRUCTURE <LS_2010> TO <LV_VALUE>.
            IF <LV_VALUE> IS ASSIGNED.
              <LV_VALUE> = LS_MOD_CELLS-VALUE.
            ENDIF.
          ENDIF.

        ENDIF.
      ENDLOOP.
    WHEN GO_GRID_0300.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'INFACTOR'.
            READ TABLE GT_MAIN_DISP_300 INTO GS_MAIN_DISP_300 INDEX  LS_MOD_CELLS-ROW_ID.
            CLEAR LV_CHK_ERR.
            IF LS_MOD_CELLS-VALUE > 0 AND LS_MOD_CELLS-VALUE > GS_MAIN_DISP_300-ZGTEFACTOR.
              LV_CHK_ERR = ABAP_TRUE.
              __SET_ERR_MSG '선택조장수는 잔여 조장수 보다 클 수 없습니다.' LS_MOD_CELLS-FIELDNAME .
              EXIT.
            ENDIF.

            IF LS_MOD_CELLS-VALUE < 0.
              LV_CHK_ERR = ABAP_TRUE.
              __SET_ERR_MSG '선택조장수는 -수량이 될 수 없습니다.' LS_MOD_CELLS-FIELDNAME .
            ENDIF.
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
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING   PO_GRID TYPE REF TO CL_GUI_ALV_GRID..

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
*     I_SOFT_REFRESH = 'X'
      IS_STABLE = LS_SCROLL.

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

  LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP_201>).
    CLEAR <LS_DISP_201>-CHECK.
  ENDLOOP.

  READ TABLE GT_MAIN_DISP INTO DATA(LS_MAIN_DISP) INDEX GV_CHK_LINE.
  LS_MAIN_DISP-CHECK = GV_CHK_VALUE.
  MODIFY GT_MAIN_DISP FROM LS_MAIN_DISP TRANSPORTING CHECK WHERE GRPNR = LS_MAIN_DISP-GRPNR .

  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_BOM_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_BOM_PROC .

  DATA : BEGIN OF LS_CHK_GRPNR,
           GRPNR TYPE ZGTPPT2000-GRPNR,
         END OF LS_CHK_GRPNR.
  DATA : LT_CHK_GRPNR LIKE TABLE OF LS_CHK_GRPNR.
  DATA : BEGIN OF LS_CHK_MATNR,
           MATNR TYPE MATNR,
         END OF LS_CHK_MATNR.
  DATA : LT_CHK_MATNR LIKE TABLE OF LS_CHK_MATNR.
  DATA : LV_CHECK.

  REFRESH GT_MAINTAIN_INLENGTH.
  REFRESH GT_GUIDE_TEXT.

  PERFORM SET_INDICATOR USING '1' '처리중..'.

* 선택된 조장번호로 조장구성표 출력
  LT_CHK_GRPNR = VALUE #( FOR WA_MAIN_DISP IN GT_MAIN_DISP WHERE ( CHECK = ABAP_TRUE ) ( GRPNR = WA_MAIN_DISP-GRPNR ) ).

* 선택된 라인의 완제품 자재정보
  LT_CHK_MATNR = VALUE #( FOR WA_MAIN_DISP IN GT_MAIN_DISP WHERE ( CHECK = ABAP_TRUE ) ( MATNR = WA_MAIN_DISP-MATNR ) ).

  SORT LT_CHK_GRPNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_GRPNR.

  SORT LT_CHK_MATNR BY MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_MATNR COMPARING MATNR.

  IF LINES( LT_CHK_GRPNR ) = 0.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 조장구성표 번호가 없습니다.'.
    RETURN.
  ENDIF.

  IF LINES( LT_CHK_GRPNR ) > 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 조장구성표 번호만 선택 가능합니다.'.
    RETURN.
  ENDIF.

*특성 코드값 밸류 찾아오기
  DATA : LS_CHARDETAIL TYPE BAPICHARACTDETAIL.
  DATA : LT_CHARTVAL TYPE TABLE OF BAPICHARACTVALUESDESCR.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.

  CALL FUNCTION 'BAPI_CHARACT_GETDETAIL'
    EXPORTING
      CHARACTNAME        = 'PD_CA_PROC_NAME'
      KEYDATE            = SY-DATUM
      LANGUAGE           = SY-LANGU
    IMPORTING
      CHARACTDETAIL      = LS_CHARDETAIL
    TABLES
      CHARACTVALUESDESCR = LT_CHARTVAL
      RETURN             = LT_RETURN.

  CLEAR : GS_MAIN_SEQ_ROUTING.
  CLEAR GV_CHK_CONFIRM_6600_GO.

  READ TABLE GT_MAIN_DISP INTO DATA(LS_MAIN_DISP) WITH KEY CHECK = ABAP_TRUE.
  GV_GRPNR = LS_MAIN_DISP-GRPNR. " 공정 구성표 번호
  IF P_WERKS = '6600' AND P_SPGCD = 'GO' AND
    ( LS_MAIN_DISP-RQMON IS NOT INITIAL OR
     LS_MAIN_DISP-RQMON NE '000000' ).
    GV_CHK_CONFIRM_6600_GO = ABAP_TRUE.
  ENDIF.


*** 조장구성표 관리시는 lock 설정 --- 테스트중 임시 주석
  IF SY-TCODE NE 'ZGTPPR2350'.
*    CLEAR GV_DISP_200.
*    SELECT SINGLE * FROM ZGTPPT2013
*      WHERE GRPNR = @GV_GRPNR
*      INTO  @DATA(LS_2013).
*    IF SY-SUBRC EQ 0 AND LS_2013 IS NOT INITIAL.
*      GV_DISP_200 = ABAP_TRUE.
*    ELSE.

    CLEAR LV_CHECK.
    CLEAR GV_CHECK_LOCK.
    PERFORM CHECK_AND_LOCK CHANGING LV_CHECK.
    IF LV_CHECK IS NOT INITIAL.
      GV_CHECK_LOCK = ABAP_TRUE.
      RETURN.
    ENDIF.
*    ENDIF.
  ENDIF.

  REFRESH GT_SEQ_ROUTING_SUB.

  DATA : LV_SUB_TABIX TYPE I.

  LOOP AT LT_CHK_MATNR INTO LS_CHK_MATNR.
    IF SY-TABIX = 1.
      PERFORM SET_ROUTING_HEADER TABLES LT_CHARTVAL USING LS_CHK_MATNR-MATNR.
    ENDIF.

* 완제품 자재가 틀릴 경우에만 어팬드
    READ TABLE GT_SEQ_ROUTING_SUB INTO DATA(LS_SUB) WITH KEY MATNR = LS_CHK_MATNR-MATNR
                                                                                BINARY SEARCH.

    IF SY-SUBRC NE 0.
      LV_SUB_TABIX = SY-TABIX.
      CLEAR GS_SEQ_ROUTING_SUB.
      GS_SEQ_ROUTING_SUB-MATNR = LS_CHK_MATNR-MATNR.
      SELECT SINGLE MTART FROM MARA
        INTO GS_SEQ_ROUTING_SUB-MTART
       WHERE MATNR = LS_CHK_MATNR-MATNR.


      PERFORM SET_ROUTING_SUB.

      INSERT GS_SEQ_ROUTING_SUB INTO GT_SEQ_ROUTING_SUB INDEX LV_SUB_TABIX.
    ENDIF.

  ENDLOOP.

* 공정표 품목 구성을 위해 동적테이블 구성
  PERFORM SET_FIELDCAT_GRID_0201.

  IF GV_CHK_SUBPOOL_DIR_FULL IS NOT INITIAL.
    RETURN.
  ENDIF.

* 상세데이터 구성(Header)
  PERFORM MAKE_DATA_200.   " 위쪽 화면구성, 조장생성 변경시 변경대상

  PERFORM SET_INDICATOR USING '10' '처리중'.

* 상세데이터 구성(Item)
  PERFORM MAKE_DATA_201.

  PERFORM SET_GUIDE_BEFORE_JOJANG.

* 플랜트 6500(군포공장) 의 경우 신선작업 지시 여부 확인
  CLEAR GV_CHK_EXIST_BWD.
  IF P_WERKS = '6500'.
    PERFORM CHK_SET_ORDERD_BWD.
  ENDIF.

  PERFORM SET_INDICATOR USING '100' '완료'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_AND_LOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM CHECK_AND_LOCK  CHANGING PV_CHECK.

  DATA : LT_ENQ TYPE TABLE OF SEQG3.

  CALL FUNCTION 'ENQUEUE_EZGT_ZGTPPR2010'
    EXPORTING
      GRPNR          = GV_GRPNR
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.
  IF SY-SUBRC <> 0.
    PV_CHECK = ABAP_TRUE.

    CALL FUNCTION 'ENQUEUE_READ'
      EXPORTING
        GUNAME                = '*'
      TABLES
        ENQ                   = LT_ENQ
      EXCEPTIONS
        COMMUNICATION_FAILURE = 1
        SYSTEM_FAILURE        = 2
        OTHERS                = 3.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    LOOP AT LT_ENQ INTO DATA(LS_ENQ) WHERE GNAME = 'ZGTPPT2010'.
      FIND ALL OCCURRENCES OF GV_GRPNR IN LS_ENQ-GARG MATCH COUNT FINAL(LV_MCNT).
      IF LV_MCNT > 0.
        MESSAGE S000 DISPLAY LIKE 'E' WITH LS_ENQ-GUNAME '가 조장구성표 번호 ' GV_GRPNR '작성 중 입니다'.
      ENDIF.
      EXIT.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CHART_PD_CA_PROC_NAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_SEQ_ROUTING>_MATNR
*&      <-- <LS_SEQ_ROUTING>_CHART
*&---------------------------------------------------------------------*
FORM GET_CHART_PD_CA_PROC_NAME  USING   PV_MATNR TYPE MATNR
                                CHANGING PV_CHART.

  SELECT SINGLE A~ATWRT
    INTO PV_CHART
    FROM AUSP AS A
    INNER JOIN CABN AS B
                          ON B~ATINN = A~ATINN
    WHERE A~OBJEK = PV_MATNR
       AND B~ATNAM = 'PD_CA_PROC_NAME'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ROUTING_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_CHK_MATNR_MATNR
*&---------------------------------------------------------------------*
FORM SET_ROUTING_HEADER  TABLES PT_CHART STRUCTURE BAPICHARACTVALUESDESCR
                          USING    PV_MATNR TYPE MATNR.

  DATA : LT_GONG_MANAGE LIKE TABLE OF GS_GONG_MANAGE.
  DATA : LV_TABIX TYPE I.

  REFRESH GT_SEQ_ROUTING_HEADER.
  PERFORM GET_GONG_MANAGE TABLES LT_GONG_MANAGE USING PV_MATNR.

  SORT LT_GONG_MANAGE BY GONG_SEQ.

  LOOP AT LT_GONG_MANAGE INTO DATA(LS_GONG).
    ADD 1 TO LV_TABIX.
    APPEND INITIAL LINE TO GT_SEQ_ROUTING_HEADER ASSIGNING FIELD-SYMBOL(<LS_ROUTING>).
    <LS_ROUTING>-SEQNO = LV_TABIX.
    <LS_ROUTING>-GONG_SEQ = LS_GONG-GONG_SEQ.
    <LS_ROUTING>-CHART = LS_GONG-GONG_CD.
    READ TABLE PT_CHART INTO DATA(LS_CHART) WITH KEY VALUE_CHAR = <LS_ROUTING>-CHART.
    IF SY-SUBRC EQ 0.
      <LS_ROUTING>-CHART_VAL = LS_CHART-DESCRIPTION.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_GONG_MANAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_GONG_MANAGE
*&      --> PV_MATNR
*&---------------------------------------------------------------------*
FORM GET_GONG_MANAGE  TABLES   PT_GONG_MANAGE STRUCTURE GS_GONG_MANAGE
                      USING    PV_MATNR TYPE MATNR..

  DATA : LV_GONG_SEQ TYPE ZEDT1010-GONG_SEQ.
  DATA : LT_EXCEPT_GONG_CD TYPE RANGE OF ZEDT1010-GONG_CD.

  SELECT 'I' AS SIGN, 'EQ' AS OPTION,  FLD_02 AS LOW
    FROM ZGTPPT1010
    INTO CORRESPONDING FIELDS OF TABLE @LT_EXCEPT_GONG_CD
   WHERE MODULE_KIND = 'PP'
      AND CODEGRP = '2020'
      AND FLD_01 = @P_WERKS.

  REFRESH PT_GONG_MANAGE[].

  SELECT DISTINCT B~GONG_SEQ, B~GONG_CD, B~AFT_GONG_SEQ, B~BESKZ, C~HALB_YN
    FROM ZGTCVMSTVAL AS A
    INNER JOIN ZEDT1010 AS B ON B~SUL_NO = A~PDCADESIGNNO
                                      AND B~REV_SEQ = A~PDCADESIGNREVNO
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
      IF LS_CHK_GONG-GONG_CD IN LT_EXCEPT_GONG_CD.
      ELSE.
        IF LS_CHK_GONG-AFT_GONG_SEQ = 0 OR
            ( LS_CHK_GONG-AFT_GONG_SEQ NE 0 AND
              LS_CHK_GONG-HALB_YN = ABAP_TRUE ).

          MOVE-CORRESPONDING LS_CHK_GONG TO PT_GONG_MANAGE.
          APPEND PT_GONG_MANAGE.
        ENDIF.
      ENDIF.
*      CASE LS_CHK_GONG-GONG_CD.
*        WHEN 'BWD' OR 'CNF'.
*
*        WHEN OTHERS.
*          IF LS_CHK_GONG-AFT_GONG_SEQ = 0 OR
*            ( LS_CHK_GONG-AFT_GONG_SEQ NE 0 AND
*              LS_CHK_GONG-HALB_YN = ABAP_TRUE ).
*
*            MOVE-CORRESPONDING LS_CHK_GONG TO PT_GONG_MANAGE.
*            APPEND PT_GONG_MANAGE.
*          ENDIF.
*      ENDCASE.
      LV_GONG_SEQ = LS_CHK_GONG-AFT_GONG_SEQ.
      IF LV_GONG_SEQ = '00'.
        EXIT.
      ENDIF.

    ELSE.
      EXIT.
    ENDIF.
  ENDDO.


  SORT PT_GONG_MANAGE BY GONG_SEQ.
  DELETE ADJACENT DUPLICATES FROM PT_GONG_MANAGE COMPARING GONG_SEQ.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ROUTING_SUB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ROUTING_SUB .

  DATA : LT_GONG_MANAGE LIKE TABLE OF GS_GONG_MANAGE.
  DATA : LV_PRE_GONG_SEQNO TYPE I.
  DATA : LT_PRE_ROUTING LIKE TABLE OF GS_PRE_ROUTING.
  DATA : LS_PRE_INFOR LIKE GS_ROUTING_CHAIN.
  DATA : LV_TABIX TYPE I.
  DATA : LV_MAX_SEQNO TYPE I.

  REFRESH GT_SEQ_ROUTING.
  PERFORM GET_GONG_MANAGE TABLES LT_GONG_MANAGE USING GS_SEQ_ROUTING_SUB-MATNR.

  SORT LT_GONG_MANAGE BY GONG_SEQ.

  LOOP AT LT_GONG_MANAGE INTO DATA(LS_GONG).
    ADD 1 TO LV_TABIX.
    APPEND INITIAL LINE TO GT_SEQ_ROUTING ASSIGNING FIELD-SYMBOL(<LS_ROUTING>).
    <LS_ROUTING>-SEQNO = LV_TABIX.
    <LS_ROUTING>-GONG_SEQ = LS_GONG-GONG_SEQ.
    <LS_ROUTING>-CHART = LS_GONG-GONG_CD.
    <LS_ROUTING>-BESKZ = LS_GONG-BESKZ.
  ENDLOOP.

* 공정별 자재, 봄구성
  SORT GT_SEQ_ROUTING BY SEQNO DESCENDING.
  LOOP AT GT_SEQ_ROUTING ASSIGNING FIELD-SYMBOL(<LS_SEQ_ROUTING>).
* 1번 공정 이전건은 존재하지 않으므로 종료처리
    IF <LS_SEQ_ROUTING>-SEQNO = 1 AND LINES( GT_SEQ_ROUTING ) NE 1.
      EXIT.
    ENDIF.

    IF SY-TABIX = 1. " 최초 등록시 완제품 코드 등록
      CLEAR GS_ROUTING_CHAIN.
      GS_ROUTING_CHAIN-SEQNO = 1.
      GS_ROUTING_CHAIN-MATNR = GS_SEQ_ROUTING_SUB-MATNR.
      SELECT SINGLE MTART FROM MARA
          INTO GS_ROUTING_CHAIN-MTART
         WHERE MATNR = GS_ROUTING_CHAIN-MATNR.
      APPEND GS_ROUTING_CHAIN TO <LS_SEQ_ROUTING>-T_BOM.
    ENDIF.

    CLEAR LV_MAX_SEQNO.

    LOOP AT <LS_SEQ_ROUTING>-T_BOM INTO DATA(LS_BOM).

      REFRESH LT_PRE_ROUTING.
*  해당 공정의 이전 공정 등록
      PERFORM GET_PRE_ROUTING TABLES LT_PRE_ROUTING USING LS_BOM-MATNR.
      <LS_SEQ_ROUTING>-NR_NEXT = LINES( LT_PRE_ROUTING ).
      CLEAR LV_TABIX.
      LOOP AT LT_PRE_ROUTING INTO DATA(LS_PRE_ROUTING).
        CLEAR LS_PRE_INFOR.

        LS_PRE_INFOR-UP_CHART_SEQ = <LS_SEQ_ROUTING>-SEQNO.
        LS_PRE_INFOR-UP_SEQNO = LS_BOM-SEQNO.
        LS_PRE_INFOR-UP_MATNR = LS_BOM-MATNR.
        LS_PRE_INFOR-MATNR = LS_PRE_ROUTING-IDNRK.
        LS_PRE_INFOR-MTART = LS_PRE_ROUTING-MTART.

        LOOP AT GT_SEQ_ROUTING ASSIGNING FIELD-SYMBOL(<LS_UPDATE>) WHERE CHART = LS_PRE_ROUTING-CHART
                                                                                                        AND GONG_SEQ < <LS_SEQ_ROUTING>-GONG_SEQ.
*        READ TABLE GT_SEQ_ROUTING ASSIGNING FIELD-SYMBOL(<LS_UPDATE>) WITH KEY chart = LS_PRE_ROUTING-CHART.
*        IF SY-SUBRC EQ 0.
          LS_PRE_INFOR-SEQNO = LINES( <LS_UPDATE>-T_BOM ) + 1 .
          APPEND INITIAL LINE TO <LS_UPDATE>-T_BOM ASSIGNING FIELD-SYMBOL(<LS_UPDATE_BOM>).
          MOVE-CORRESPONDING LS_PRE_INFOR TO <LS_UPDATE_BOM>.
          EXIT.
*        ENDIF.
        ENDLOOP.

      ENDLOOP.

    ENDLOOP.

  ENDLOOP.

* 해당 공정들 이후공정의 순번에 맞추어 정렬후 seqno채번
  LOOP AT GT_SEQ_ROUTING ASSIGNING <LS_SEQ_ROUTING>.
    SORT <LS_SEQ_ROUTING>-T_BOM BY MATCH_SEQNO UP_SEQNO SEQNO.
    CLEAR LV_TABIX.
    LOOP AT <LS_SEQ_ROUTING>-T_BOM ASSIGNING FIELD-SYMBOL(<LS_BOM>).
      ADD 1 TO LV_TABIX.
      <LS_BOM>-SEQNO = LV_TABIX.
    ENDLOOP.
  ENDLOOP.

  MOVE-CORRESPONDING GT_SEQ_ROUTING TO GS_SEQ_ROUTING_SUB-T_ROUTING.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PRE_ROUTING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_PRE_ROUTING
*&      --> LS_BOM_MATNR
*&---------------------------------------------------------------------*
FORM GET_PRE_ROUTING  TABLES   PT_ROUTING STRUCTURE GS_PRE_ROUTING
                      USING    PV_MATNR TYPE MATNR.

* 공정정보 조회
  SELECT  A~MATNR,
              C~STPOZ,
              C~IDNRK,
              E~VERID AS VERID_O,
              G~VERID
    FROM MAST AS A
    INNER JOIN MKAL AS E ON E~WERKS = A~WERKS
                                 AND E~MATNR = A~MATNR
                                 AND E~STLAN = A~STLAN
                                 AND E~STLAL = A~STLAL
    INNER JOIN STKO AS B ON B~STLNR = A~STLNR
                                 AND B~STLAL = A~STLAL
    INNER JOIN STPO AS C ON C~STLNR = B~STLNR
                                 AND C~STLTY = B~STLTY
    INNER JOIN STAS AS D ON D~STLAL = A~STLAL
                                 AND D~STLNR = C~STLNR
                                 AND D~STLTY = C~STLTY
                                 AND D~STLKN = C~STLKN
    INNER JOIN MAST AS F ON F~WERKS = A~WERKS
                                 AND F~MATNR = C~IDNRK
    INNER JOIN MKAL AS G ON G~WERKS = F~WERKS
                                 AND G~MATNR = F~MATNR
                                 AND G~STLAN = F~STLAN
                                 AND G~STLAL = F~STLAL
   WHERE A~MATNR = @PV_MATNR
     AND A~WERKS  = @P_WERKS
     AND E~VERID IN ( '1000', 'SC10' )
     AND B~STLTY  = 'M'
     AND B~LKENZ NE 'X'
     AND C~LKENZ NE 'X'
     AND G~VERID IN ( '1000', 'SC10' )
    INTO TABLE @DATA(LT_IDNRK).

  SELECT A~STPOZ, A~MATNR, A~IDNRK, A~VERID_O, A~VERID
    FROM @LT_IDNRK AS A
    INNER JOIN MARA AS B
                          ON B~MATNR = A~IDNRK
    INNER JOIN MARC AS C
                          ON C~MATNR = A~IDNRK
                        AND C~WERKS = @P_WERKS
   WHERE B~MTART   IN ( 'MCFE', 'MCHF' )  " 완제품 반제품만 공정대상
     AND C~DISMM IN ( 'X0', 'PD' )
     AND ( C~BESKZ = 'E' OR
          ( C~BESKZ = 'F' AND
            C~SOBSL = 30 ) OR
          ( C~BESKZ = 'F' AND
            C~SOBSL LIKE '4%' ) OR
          ( C~BESKZ = 'F' AND
            C~SOBSL = '50' ) OR
            C~BESKZ = 'X'  OR
           ( C~BESKZ = 'F' AND
             C~SOBSL = '' ) )
     AND C~MAABC NE 'C'
     AND C~DPCBT EQ 'C'
    INTO TABLE @DATA(LT_ROUTING).

  SORT LT_ROUTING BY STPOZ MATNR IDNRK VERID_O VERID.
  DELETE ADJACENT DUPLICATES FROM LT_ROUTING COMPARING STPOZ MATNR MATNR.

  IF LT_ROUTING[] IS NOT INITIAL.
    MOVE-CORRESPONDING LT_ROUTING TO PT_ROUTING[].
  ENDIF.
  LOOP AT PT_ROUTING ASSIGNING FIELD-SYMBOL(<LS_CHK_ROUTION>).

    PERFORM GET_CHART_PD_CA_PROC_NAME USING <LS_CHK_ROUTION>-IDNRK
                                                       CHANGING <LS_CHK_ROUTION>-CHART.

    SELECT SINGLE MTART FROM MARA
      INTO <LS_CHK_ROUTION>-MTART
     WHERE MATNR = <LS_CHK_ROUTION>-IDNRK.

  ENDLOOP.

  SORT PT_ROUTING BY STPOZ.

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

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_COLPOS TYPE I.
  SORT GT_SEQ_ROUTING BY SEQNO DESCENDING.

  DATA : LV_FIELDVAL(50) .

  REFRESH GT_FIELDCAT_0201.

* 순번
  APPEND INITIAL LINE TO GT_FIELDCAT_0201 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
  <LS_FCAT>-FIELDNAME = 'DISP_SEQNO'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '순번'.
  <LS_FCAT>-COL_POS = 1.
  <LS_FCAT>-DATATYPE = 'NUMC'.
  <LS_FCAT>-DD_OUTLEN = '6'.
  <LS_FCAT>-OUTPUTLEN = '2'.
  <LS_FCAT>-JUST = 'C'.

* 순번
  APPEND INITIAL LINE TO GT_FIELDCAT_0201 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'SEQNO'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '순번'.
  <LS_FCAT>-COL_POS = 2.
  <LS_FCAT>-DATATYPE = 'NUMC'.
  <LS_FCAT>-DD_OUTLEN = '6'.
  <LS_FCAT>-OUTPUTLEN = '2'.
  <LS_FCAT>-JUST = 'C'.
  <LS_FCAT>-NO_OUT = ABAP_TRUE.

* 순번(내부 인덱스 조절용)
  APPEND INITIAL LINE TO GT_FIELDCAT_0201 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'LINE'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '순번'.
  <LS_FCAT>-COL_POS = 3.
  <LS_FCAT>-DATATYPE = 'NUMC'.
  <LS_FCAT>-DD_OUTLEN = '6'.
  <LS_FCAT>-JUST = 'C'.
  <LS_FCAT>-NO_OUT = ABAP_TRUE.

* 순번(내부 인덱스 조절용)
  APPEND INITIAL LINE TO GT_FIELDCAT_0201 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'LINE_SEQ'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '순번'.
  <LS_FCAT>-COL_POS = 4.
  <LS_FCAT>-DATATYPE = 'NUMC'.
  <LS_FCAT>-DD_OUTLEN = '6'.
  <LS_FCAT>-JUST = 'C'.
  <LS_FCAT>-NO_OUT = ABAP_TRUE.


  CLEAR LV_COLPOS.
  LOOP AT GT_SEQ_ROUTING_HEADER ASSIGNING FIELD-SYMBOL(<LS_ROUTING>).
    APPEND INITIAL LINE TO GT_FIELDCAT_0201 ASSIGNING <LS_FCAT>.
    CLEAR LV_NUM.
    LV_NUM = <LS_ROUTING>-SEQNO + 0.
    <LS_FCAT>-FIELDNAME = LV_NUM && '_' && <LS_ROUTING>-CHART && '_CHK'.
    LV_COLPOS = LV_COLPOS + 10.
    <LS_FCAT>-COL_POS = LV_COLPOS.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '2'.
    <LS_FCAT>-OUTPUTLEN = '2'.
    <LS_FCAT>-JUST = 'L'.
    IF SY-TCODE EQ 'ZGTPPR2050'.
      <LS_FCAT>-NO_OUT = 'X'.
    ENDIF.

    APPEND INITIAL LINE TO GT_FIELDCAT_0201 ASSIGNING <LS_FCAT>.
    CLEAR LV_NUM.
    LV_NUM = <LS_ROUTING>-SEQNO + 0.
    <LS_FCAT>-FIELDNAME = LV_NUM && '_' && <LS_ROUTING>-CHART.

    LV_FIELDVAL = LV_NUM && '_' && <LS_ROUTING>-CHART_VAL.

    IF <LS_ROUTING>-SEQNO = LINES( GT_SEQ_ROUTING_HEADER ) .
      <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_FIELDVAL && '(END)'.
    ELSE.
      <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_FIELDVAL.
    ENDIF.
    LV_COLPOS = LV_COLPOS + 10.
    <LS_FCAT>-COL_POS = LV_COLPOS.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '50'.
    <LS_FCAT>-OUTPUTLEN = '23'.
    <LS_FCAT>-JUST = 'L'.
*    <LS_FCAT>-ICON = ABAP_TRUE.

* 해당 오더 순번 관리
    APPEND INITIAL LINE TO GT_FIELDCAT_0201 ASSIGNING <LS_FCAT>.
    CLEAR LV_NUM.
    LV_NUM = <LS_ROUTING>-SEQNO + 0.
    <LS_FCAT>-FIELDNAME = LV_NUM && '_' && 'END_SEQNO'.
    LV_COLPOS = LV_COLPOS + 10.
    <LS_FCAT>-COL_POS = LV_COLPOS.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-OUTPUTLEN = '10'.
    <LS_FCAT>-JUST = 'R'.
    <LS_FCAT>-NO_OUT = 'X'.

* 해당 오더 순번 관리
    APPEND INITIAL LINE TO GT_FIELDCAT_0201 ASSIGNING <LS_FCAT>.
    CLEAR LV_NUM.
    LV_NUM = <LS_ROUTING>-SEQNO + 0.
    <LS_FCAT>-FIELDNAME = LV_NUM && '_' && 'SEQNO'.
    LV_COLPOS = LV_COLPOS + 10.
    <LS_FCAT>-COL_POS = LV_COLPOS.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-OUTPUTLEN = '10'.
    <LS_FCAT>-JUST = 'R'.
    <LS_FCAT>-NO_OUT = 'X'.

  ENDLOOP.

* 오더번호
  APPEND INITIAL LINE TO GT_FIELDCAT_0201 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'ORDNO_C'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'.
  <LS_FCAT>-COL_POS = 300.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '30'.
  <LS_FCAT>-OUTPUTLEN = '23'.
  <LS_FCAT>-JUST = 'L'.

  FREE GT_MAIN_201.

  DATA : LT_ABAPLIST TYPE TABLE OF ABAPLIST.

  CALL FUNCTION 'LIST_FROM_MEMORY'
    TABLES
      LISTOBJECT = LT_ABAPLIST
    EXCEPTIONS
      NOT_FOUND  = 1
      OTHERS     = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE(
    EXPORTING
      I_STYLE_TABLE       = ABAP_TRUE
      IT_FIELDCATALOG           = GT_FIELDCAT_0201                " Field Catalog
    IMPORTING
      EP_TABLE                  = GT_MAIN_201                 " Pointer to Dynamic Data Table
    EXCEPTIONS
      GENERATE_SUBPOOL_DIR_FULL = 1                " At Most 36 Subroutine Pools Can Be Generated Temporarily
      OTHERS                    = 2
  ).
  IF SY-SUBRC <> 0.
    MESSAGE S005 DISPLAY LIKE 'E' WITH 'At Most 36 Subroutine Pools' 'Can Be Generated Temporarily'.
    GV_CHK_SUBPOOL_DIR_FULL = ABAP_TRUE.
    RETURN.
  ENDIF.

  ASSIGN GT_MAIN_201->* TO <GT_MAIN_201>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DATA_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_DATA_200 .

  REFRESH GT_MAIN_200.
  DATA : LV_MATNR TYPE MATNR.
  DATA : LV_CHK_EXIST.
  CLEAR GV_CHK_ZQ.

  GT_MAIN_200 = VALUE #( FOR WA_MAIN_DISP2 IN GT_MAIN_DISP WHERE ( CHECK = ABAP_TRUE ) ( CORRESPONDING #( WA_MAIN_DISP2 ) ) ).
  SORT GT_MAIN_200 BY GCATG DESCENDING ORDNO POSNR.

  LOOP AT GT_MAIN_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN_200>).

    IF <LS_MAIN_200>-GCATG NE '생산오더'.

      ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
        EXPORTING
          IV_VBELN      =  CONV #( <LS_MAIN_200>-ORDNO )                " 판매 관리 문서 번호
          IV_POSNR      = <LS_MAIN_200>-POSNR                 " SD 문서의 품목 번호
        IMPORTING
          EV_PACK_YN    = <LS_MAIN_200>-PACK_YN
          EV_PACK_NO    = <LS_MAIN_200>-PACK_NO
          EV_PACK_TYPE    = <LS_MAIN_200>-PACK_TYPE
          EV_PACK_DM    = <LS_MAIN_200>-PACK_DM
          EV_PACK_PA    = <LS_MAIN_200>-PACK_PA
          EV_PACK_SK    = <LS_MAIN_200>-PACK_SK
          EV_PACK_PW    = <LS_MAIN_200>-PACK_PW
          EV_PACK_FACTOR    = <LS_MAIN_200>-PACK_FACTOR
          EV_INSPECTION    = <LS_MAIN_200>-INSPE_YN
          EV_INSP_QLENG    = <LS_MAIN_200>-INSPE_QLENGTH
          EV_INSP_SPLENG    = <LS_MAIN_200>-INSPE_SPENGTH
      ).

      CLEAR LV_MATNR.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          INPUT        = <LS_MAIN_200>-PACK_DM
        IMPORTING
          OUTPUT       = LV_MATNR
        EXCEPTIONS
          LENGTH_ERROR = 1
          OTHERS       = 2.
      IF SY-SUBRC <> 0.
      ENDIF.

      <LS_MAIN_200>-MAKTX_DM = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LV_MATNR ).
      SELECT SINGLE MMSTA FROM MARC
        INTO @DATA(LV_MMSTA)
        WHERE MATNR = @LV_MATNR
          AND WERKS = @P_WERKS.

      CASE <LS_MAIN_200>-PACK_YN.
        WHEN 'CM' OR 'NA'.
          <LS_MAIN_200>-PACK_YN_CHK = <LS_MAIN_200>-PACK_YN.
          <LS_MAIN_200>-PACK_YN = '확정'.
          IF LV_MMSTA IS NOT INITIAL.
            <LS_MAIN_200>-PACK_YN = <LS_MAIN_200>-PACK_YN && '(' && LV_MMSTA && ')'.
            IF LV_MMSTA = 'ZQ'.
              APPEND INITIAL LINE TO GT_GUIDE_TEXT ASSIGNING FIELD-SYMBOL(<LV_TEXT>).
              <LV_TEXT> = |판매오더({ <LS_MAIN_200>-ORDNO }) 품목({ <LS_MAIN_200>-POSNR }) 포장재 상태 ZQ 입니다.|.
            ENDIF.
          ENDIF.

        WHEN OTHERS.
      ENDCASE.


* 특기사항 헤더
      CLEAR LV_CHK_EXIST.
      PERFORM CHK_EXIST_SNOTE_FR_SO USING 'H' <LS_MAIN_200>-ORDNO <LS_MAIN_200>-POSNR  CHANGING LV_CHK_EXIST.
      IF LV_CHK_EXIST = ABAP_TRUE.
        <LS_MAIN_200>-SNOTE = ICON_DISPLAY_TEXT.
      ENDIF.

* 특기사항 item
      CLEAR LV_CHK_EXIST.
      PERFORM CHK_EXIST_SNOTE_FR_SO USING 'I' <LS_MAIN_200>-ORDNO <LS_MAIN_200>-POSNR  CHANGING LV_CHK_EXIST.
      IF LV_CHK_EXIST = ABAP_TRUE.
        <LS_MAIN_200>-SNOTE2 = ICON_DISPLAY_TEXT.
      ENDIF.

    ELSE.

*    SM 오더 특기사항
      CLEAR LV_CHK_EXIST.
      PERFORM CHK_EXIST_SNOTE_FR_PO USING <LS_MAIN_200>-ORDNO <LS_MAIN_200>-POSNR  CHANGING LV_CHK_EXIST.
      IF LV_CHK_EXIST = ABAP_TRUE.
        <LS_MAIN_200>-SNOTE = ICON_DISPLAY_TEXT.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DATA_201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_DATA_201 .

* 데이타 체인구성
  PERFORM MAKE_CHAIN_DATA.
* 201 화면 구성
  PERFORM SET_DISPLAY_201.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_CHAIN_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_CHAIN_DATA .

  DATA : LV_TABIX TYPE I.
  DATA : LV_INDEX TYPE I.
  DATA : LT_MAIN LIKE GT_MAIN_200.

* 조장구성표 체인으로 출력을 위한 테이블 세팅
  REFRESH GT_MAKE_DISPLAY.

  LT_MAIN = GT_MAIN_200.
  SORT LT_MAIN BY INLENGTH.

  LOOP AT LT_MAIN INTO GS_MAIN_200.
    CLEAR GS_MAKE_DISPLAY.
    GS_MAKE_DISPLAY-END_ORDNR = GS_MAIN_200-ORDNO.
    GS_MAKE_DISPLAY-END_POSNR = GS_MAIN_200-POSNR.
    GS_MAKE_DISPLAY-GCATG = GS_MAIN_200-GCATG.

    CASE GS_MAIN_200-GCATG.
      WHEN '생산오더'.
        GS_MAKE_DISPLAY-END_ORDTY = 'SM'.
      WHEN '견적오더' OR '판매오더'.
        GS_MAKE_DISPLAY-END_ORDTY = 'SO'.
    ENDCASE.

*    GS_MAKE_DISPLAY-END_SEQNO = LV_TABIX.
    GS_MAKE_DISPLAY-MATNR = GS_MAIN_200-MATNR.

    READ TABLE GT_SEQ_ROUTING_SUB INTO GS_SEQ_ROUTING_SUB WITH KEY MATNR = GS_MAIN_200-MATNR.
    REFRESH GT_SEQ_ROUTING.
    GT_SEQ_ROUTING = GS_SEQ_ROUTING_SUB-T_ROUTING.

    PERFORM SET_CHAIN.


    CLEAR LV_INDEX.
    LV_INDEX = GS_MAIN_200-INFACTOR + 0. " 공정수 만큼 테이블 구성하여
    DO LV_INDEX TIMES.
      ADD 1 TO LV_TABIX.
      GS_MAKE_DISPLAY-END_SEQNO = LV_TABIX.
      APPEND GS_MAKE_DISPLAY TO GT_MAKE_DISPLAY.
    ENDDO.
  ENDLOOP.

  PERFORM SET_INDICATOR USING '20' '처리중..'.

  PERFORM GET_CHAIN_JOJANG.

  PERFORM SET_INDICATOR USING '30' '처리중..'.

  PERFORM SET_CHAIN_DATA.

  PERFORM SET_INDICATOR USING '40' '처리중..'.

  PERFORM SET_DISPLAY_SEQNO_AND_SAVE.

  MOVE-CORRESPONDING GT_MAKE_DISPLAY TO GT_MAKE_DISPLAY_ORIGN.

*  IF GV_JOJANG_SORT IS NOT INITIAL.
*    PERFORM SET_CHAIN_DATA_JOJANG_LENGTH.
*  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CHAIN_JOJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_CHAIN_JOJANG .

  DATA : LS_2010 TYPE ZGTPPT2010.
  DATA : LT_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : LV_TABIX TYPE I.
  REFRESH GT_2010.


  SELECT *
    FROM ZGTPPT2010
    INTO CORRESPONDING FIELDS OF TABLE GT_2010
  WHERE GRPNR = GV_GRPNR.

  PERFORM CHK_POJANG.

** 조장 구성이 비어있을 경우 sm 생산오더는 완제품 공정 추가로 어팬드 해준다.
*  IF GT_2010 IS INITIAL.
*
*    LOOP AT GT_MAIN_200 INTO GS_MAIN_200.
*      ADD 1 TO LV_TABIX.
*      IF GS_MAIN_200-GCATG = '생산오더'.
*        READ TABLE GT_SEQ_ROUTING_SUB INTO DATA(LS_ROUTING) WITH KEY MATNR = GS_MAIN_200-MATNR.
*
*        READ TABLE LS_ROUTING-T_ROUTING INTO DATA(LS_CHART) INDEX 1.
*        CLEAR LS_2010.
*        LS_2010-GRPNR = GS_MAIN_200-GRPNR.
*        LS_2010-GONG_CD = LS_CHART-CHART.
*        LS_2010-ORDNR = GS_MAIN_200-ORDNO.
*        LS_2010-POSNR = GS_MAIN_200-POSNR.
*        LS_2010-ORDTY = 'PRD'.
*        LS_2010-DMORD = GS_MAIN_200-ORDNO.
*        LS_2010-DMLINE = GS_MAIN_200-POSNR.
*        LS_2010-DMORDTY = 'PRD'.
*        LS_2010-INLENGTH = GS_MAIN_200-INLENGTH.
*        LS_2010-INFACTOR = GS_MAIN_200-INFACTOR.
*
*        READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_HEADER) WITH KEY CHART = LS_CHART-CHART
*                                                                                                  SEQNO = LS_CHART-SEQNO.
*        LS_2010-GONG_SEQ = LS_HEADER-GONG_SEQ.
*        LS_2010-MATNR = GS_MAIN_200-MATNR.
*        LS_2010-MATNR_SEQ = 1.
*
*        LS_2010-ETC_SEQ = LV_TABIX.
*        APPEND LS_2010 TO LT_2010.
*      ENDIF.
*    ENDLOOP.
*
*    IF LT_2010 IS NOT INITIAL.
*      MODIFY ZGTPPT2010 FROM TABLE LT_2010.
*      IF SY-SUBRC EQ 0.
*        COMMIT WORK AND WAIT.
*      ENDIF.
*
*      MOVE-CORRESPONDING LT_2010 TO GT_2010.
*    ENDIF.
*
*  ENDIF.

* 화면 표현방식 변경을 위해 세팅( 최종공정의 inleng + 그외 나머지 여장
  SORT GT_2010 BY GONG_SEQ DESCENDING.

  LOOP AT   GT_2010 INTO GS_2010.
    PERFORM SET_ORD_INLENGTH USING GS_2010.
  ENDLOOP.

  SORT GT_2010 BY GONG_SEQ MATNR ETC_SEQ.
  SORT GT_MAINTAIN_INLENGTH BY ORDNR POSNR ORDTY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAKE_DISPLAY_T_GONG
*&---------------------------------------------------------------------*
FORM SET_CHAIN .

  REFRESH GT_GONG_2010[].

  DATA : LV_ORDNR TYPE ZGTPPT2010-ORDNR.
  DATA : LV_POSNR TYPE ZGTPPT2010-POSNR.
  DATA : LV_TABIX TYPE I.
  DATA : LV_PRE_SEQNO TYPE I.
  DATA : LV_CHK_BOM LIKE TABLE OF GS_ROUTING_CHAIN.
  DATA : LV_CHK_CHAIN_2010 LIKE TABLE OF GS_CHAIN_2010.


  LOOP AT GT_SEQ_ROUTING INTO GS_SEQ_ROUTING.
    CLEAR GS_GONG_2010.
    GS_GONG_2010-SEQNO = GS_SEQ_ROUTING-SEQNO.
    GS_GONG_2010-GONG_SEQ = GS_SEQ_ROUTING-GONG_SEQ.
    GS_GONG_2010-CHART = GS_SEQ_ROUTING-CHART.
    APPEND GS_GONG_2010 TO GT_GONG_2010.
  ENDLOOP.

  SORT GT_GONG_2010 BY SEQNO DESCENDING.
  MOVE-CORRESPONDING GT_GONG_2010 TO GS_MAKE_DISPLAY-T_GONG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHAIN_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CHAIN_DATA .

  DATA : LV_TABIX TYPE I.
  DATA : LT_BOM LIKE TABLE OF GS_ROUTING_CHAIN.
  DATA : LS_CHAIN LIKE GS_CHAIN_2010.
  DATA : LT_CHK_CHAIN LIKE TABLE OF GS_CHAIN_2010.
  DATA : LS_PRE_CHAIN LIKE GS_CHAIN_2010.
  DATA : LS_DM_2010 LIKE GS_2010.
  DATA : LT_CHK_MULTY LIKE TABLE OF GS_2010.
  DATA : LS_PRE_2010 LIKE GS_2010.
  DATA : LV_ROUTING_SEQ TYPE I.
  DATA : LV_MAX_LINE TYPE I.  "  중복 체크된 라인은 제외한 총 라인수
  DATA : LV_USED_LINES TYPE I.
  DATA : LT_PO_PRE_2010 LIKE TABLE OF GS_2010. " 공정을 건너뛰는 po 확인을 위한 로직
  DATA : LV_CHK_STATUS.


* 오더 기준으로 라우팅 기준에 따라 세팅해준다.
  LOOP AT GT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAKE_DISPLAY>).
    READ TABLE GT_SEQ_ROUTING_SUB INTO GS_SEQ_ROUTING_SUB WITH KEY MATNR = <LS_MAKE_DISPLAY>-MATNR.
    REFRESH GT_SEQ_ROUTING.
    GT_SEQ_ROUTING = GS_SEQ_ROUTING_SUB-T_ROUTING.

* 해당 자재의 봄 기준으로 순차세팅..
* 1)  이후공정 기준으로 이전 공정 찾아오기 이후 공정자재의  부품자재의 수량을 기준으로 각각 찾아 세팅해준다.
    SORT GT_SEQ_ROUTING BY SEQNO DESCENDING.
    CLEAR LV_TABIX.
    LOOP AT GT_SEQ_ROUTING INTO GS_SEQ_ROUTING.
      ADD 1 TO LV_TABIX.
      LT_BOM = GS_SEQ_ROUTING-T_BOM.
* 해당공정의 오더 찾기.
      IF LV_TABIX = 1. " 최초 공정은 바로 세팅

        READ TABLE LT_BOM INTO DATA(LS_BOM) INDEX 1. " 완제품 공정은 1개의 라우팅만 존재한다.
        READ TABLE <LS_MAKE_DISPLAY>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>) WITH KEY GONG_SEQ = GS_SEQ_ROUTING-GONG_SEQ.
        IF SY-SUBRC EQ 0.
          READ TABLE GT_2010 ASSIGNING FIELD-SYMBOL(<LS_2010>) WITH KEY MATNR = GS_SEQ_ROUTING_SUB-MATNR
                                                                                                         GONG_SEQ = GS_SEQ_ROUTING-GONG_SEQ
                                                                                                         DMORD = <LS_MAKE_DISPLAY>-END_ORDNR
                                                                                                         DMLINE = <LS_MAKE_DISPLAY>-END_POSNR
                                                                                                         DMORDTY = <LS_MAKE_DISPLAY>-END_ORDTY
*                                                                                                         MATNR_SEQ = <LS_MAKE_DISPLAY>-END_SEQNO
                                                                                                         USE_CHK = ' '.
          IF SY-SUBRC EQ 0.
            <LS_2010>-USE_CHK = ABAP_TRUE.
            CLEAR LS_CHAIN.
            LS_CHAIN-DMORD = <LS_2010>-DMORD.
            LS_CHAIN-DMLINE = <LS_2010>-DMLINE.
            LS_CHAIN-DMORDTY = <LS_2010>-DMORDTY.
            LS_CHAIN-DM_SEQNO = <LS_MAKE_DISPLAY>-END_SEQNO.
            LS_CHAIN-IN_SEQNO = LS_BOM-SEQNO.
            LS_CHAIN-ORDNR = <LS_2010>-ORDNR.
            LS_CHAIN-POSNR = <LS_2010>-POSNR.
            LS_CHAIN-ORDTY = <LS_2010>-ORDTY.
            LS_CHAIN-SEQ_MATNR = <LS_2010>-MATNR.
            LS_CHAIN-ETC_SEQ = <LS_2010>-ETC_SEQ.
            IF <LS_2010>-ORDTY = 'REF'.
              LS_CHAIN-CHK_DUP = ABAP_TRUE.
            ENDIF.

          ELSE.
            CLEAR LS_CHAIN.
            LS_CHAIN-DMORD = <LS_MAKE_DISPLAY>-END_ORDNR.
            LS_CHAIN-DMLINE = <LS_MAKE_DISPLAY>-END_POSNR.
            LS_CHAIN-DMORDTY = <LS_MAKE_DISPLAY>-END_ORDTY.
            LS_CHAIN-DM_SEQNO = <LS_MAKE_DISPLAY>-END_SEQNO.
            LS_CHAIN-IN_SEQNO = LS_BOM-SEQNO.
            LS_CHAIN-SEQ_MATNR = <LS_MAKE_DISPLAY>-MATNR.
            LS_CHAIN-ETC_SEQ = <LS_MAKE_DISPLAY>-END_SEQNO.
          ENDIF.

          APPEND LS_CHAIN TO <LS_GONG>-T_CHAIN.
          SORT <LS_GONG>-T_CHAIN BY IN_SEQNO.

        ENDIF.
      ELSE.
* 최초공정 이후의 오더는 해당 공정에 있는 라우팅 순서대로 조회 및 정렬하여 세팅
        READ TABLE <LS_MAKE_DISPLAY>-T_GONG ASSIGNING <LS_GONG> WITH KEY GONG_SEQ = GS_SEQ_ROUTING-GONG_SEQ.
        IF SY-SUBRC EQ 0.
          LOOP AT LT_BOM INTO LS_BOM.
* 상위 오더 조회
            READ TABLE <LS_MAKE_DISPLAY>-T_GONG INTO DATA(LS_NEXT_GONG) WITH KEY SEQNO = LS_BOM-UP_CHART_SEQ.
            IF SY-SUBRC EQ 0.

              READ TABLE LS_NEXT_GONG-T_CHAIN INTO LS_PRE_CHAIN WITH KEY IN_SEQNO = LS_BOM-UP_SEQNO.
              IF SY-SUBRC EQ 0.
* 이후 공정의 하위 오더로 이전 공정 찾기.
                IF LS_PRE_CHAIN-ORDNR IS NOT INITIAL.

                  IF LS_PRE_CHAIN-ORDTY = 'PO' OR LS_PRE_CHAIN-ORDTY = 'UPR'.
                    REFRESH LT_PO_PRE_2010.
                    READ TABLE GT_2010 INTO DATA(LS_DEV_2010) WITH KEY GONG_SEQ = LS_NEXT_GONG-GONG_SEQ
                                                                                           ORDNR = LS_PRE_CHAIN-ORDNR
                                                                                           POSNR = LS_PRE_CHAIN-POSNR
                                                                                           ORDTY = LS_PRE_CHAIN-ORDTY.
                    PERFORM GET_PRE_CHAIN TABLES LT_PO_PRE_2010 USING LS_DEV_2010.
                    CLEAR LV_CHK_STATUS.
                    PERFORM CHECK_MATCH_PRE_CHAIN TABLES LT_PO_PRE_2010 CHANGING LV_CHK_STATUS.

                    IF LV_CHK_STATUS = 'D'.

                      LS_CHAIN-DMORD = LS_PRE_CHAIN-ORDNR.
                      LS_CHAIN-DMLINE = LS_PRE_CHAIN-POSNR.
                      LS_CHAIN-DMORDTY = LS_PRE_CHAIN-ORDTY.
                      LS_CHAIN-DM_SEQNO = LS_PRE_CHAIN-IN_SEQNO.
                      LS_CHAIN-IN_SEQNO = LS_BOM-SEQNO.
                      LS_CHAIN-ORDNR = LS_PRE_CHAIN-ORDNR.
                      LS_CHAIN-POSNR = LS_PRE_CHAIN-POSNR.
                      LS_CHAIN-ORDTY = LS_PRE_CHAIN-ORDTY.
                      LS_CHAIN-SEQ_MATNR = LS_BOM-MATNR.
                      LS_CHAIN-ETC_SEQ = LS_BOM-SEQNO.
                      LS_CHAIN-CHK_DUP = ABAP_TRUE.

                      APPEND LS_CHAIN TO <LS_GONG>-T_CHAIN.

                      CONTINUE.
                    ENDIF.
                  ENDIF.

                  CLEAR LS_DM_2010.
                  READ TABLE GT_2010 INTO LS_DM_2010 WITH KEY GONG_SEQ = LS_NEXT_GONG-GONG_SEQ
                                                                                    ORDNR = LS_PRE_CHAIN-ORDNR
                                                                                    POSNR = LS_PRE_CHAIN-POSNR
                                                                                    ORDTY = LS_PRE_CHAIN-ORDTY.

                  IF SY-SUBRC EQ 0.
                    IF LS_DM_2010-REORDTY = 'PO' OR LS_DM_2010-REORDTY = 'UPR'.
                      READ TABLE GT_2010 ASSIGNING <LS_2010> WITH KEY GONG_SEQ = <LS_GONG>-GONG_SEQ
                                                                                                 ORDNR = LS_DM_2010-REORD
                                                                                                 POSNR = LS_DM_2010-RELINE
                                                                                                 ORDTY = LS_DM_2010-REORDTY
                                                                                                 USE_CHK = ' '.

                    ELSE.
                      READ TABLE GT_2010 ASSIGNING <LS_2010> WITH KEY ORDNR = LS_DM_2010-REORD
                                                                                      POSNR = LS_DM_2010-RELINE
                                                                                      ORDTY = LS_DM_2010-REORDTY
                                                                                      USE_CHK = ' '.
                    ENDIF.
                    IF SY-SUBRC EQ 0.
                      CLEAR LS_CHAIN.
                      LS_CHAIN-DMORD = <LS_2010>-DMORD.
                      LS_CHAIN-DMLINE = <LS_2010>-DMLINE.
                      LS_CHAIN-DMORDTY = <LS_2010>-DMORDTY.
                      LS_CHAIN-DM_SEQNO = <LS_MAKE_DISPLAY>-END_SEQNO.
                      LS_CHAIN-IN_SEQNO = LS_BOM-SEQNO.
                      LS_CHAIN-ORDNR = <LS_2010>-ORDNR.
                      LS_CHAIN-POSNR = <LS_2010>-POSNR.
                      LS_CHAIN-ORDTY = <LS_2010>-ORDTY.
                      LS_CHAIN-SEQ_MATNR = <LS_2010>-MATNR.
                      LS_CHAIN-ETC_SEQ = <LS_2010>-ETC_SEQ.

                      IF <LS_2010>-USE_CHK = ABAP_TRUE.
                        LS_CHAIN-CHK_DUP = ABAP_TRUE.
                      ELSE.
                        <LS_2010>-USE_CHK = ABAP_TRUE.
                      ENDIF.

* 탐뎀 체크자재의 경우 디스플레이 제외
                      IF <LS_2010>-REF_TANDEM = ABAP_TRUE.
                        LS_CHAIN-CHK_DUP = ABAP_TRUE.
                      ENDIF.

                      APPEND LS_CHAIN TO <LS_GONG>-T_CHAIN.

                    ELSE.
                      CLEAR LS_CHAIN.
                      LOOP AT GT_2010 ASSIGNING <LS_2010> WHERE GONG_SEQ = GS_SEQ_ROUTING-GONG_SEQ
                                                                                AND MATNR_SEQ = LS_BOM-SEQNO.
*                                                                                AND USE_CHK = ' '.
                        IF LS_DM_2010-ORDNR = <LS_2010>-DMORD AND
                             LS_DM_2010-POSNR = <LS_2010>-DMLINE AND
                             LS_DM_2010-ORDTY = <LS_2010>-DMORDTY.

                          LS_CHAIN-DMORD = <LS_2010>-DMORD.
                          LS_CHAIN-DMLINE = <LS_2010>-DMLINE.
                          LS_CHAIN-DMORDTY = <LS_2010>-DMORDTY.
                          LS_CHAIN-DM_SEQNO = <LS_MAKE_DISPLAY>-END_SEQNO.
                          LS_CHAIN-IN_SEQNO = LS_BOM-SEQNO.
                          LS_CHAIN-ORDNR = <LS_2010>-ORDNR.
                          LS_CHAIN-POSNR = <LS_2010>-POSNR.
                          LS_CHAIN-ORDTY = <LS_2010>-ORDTY.
                          LS_CHAIN-SEQ_MATNR = <LS_2010>-MATNR.
                          LS_CHAIN-ETC_SEQ = <LS_2010>-ETC_SEQ.

                          IF <LS_2010>-USE_CHK = ABAP_TRUE.
                            LS_CHAIN-CHK_DUP = ABAP_TRUE.
                          ELSE.
                            <LS_2010>-USE_CHK = ABAP_TRUE.
                          ENDIF.

* 탐뎀 체크자재의 경우 디스플레이 제외
                          IF <LS_2010>-REF_TANDEM = ABAP_TRUE.
                            LS_CHAIN-CHK_DUP = ABAP_TRUE.
                          ENDIF.

                          APPEND LS_CHAIN TO <LS_GONG>-T_CHAIN.

                          EXIT.

                        ENDIF.

                      ENDLOOP.

                      IF LS_CHAIN IS INITIAL.

                        LS_CHAIN-DMORD = LS_DM_2010-ORDNR.
                        LS_CHAIN-DMLINE = LS_DM_2010-POSNR.
                        LS_CHAIN-DMORDTY = LS_DM_2010-ORDTY.
                        LS_CHAIN-DM_SEQNO = LS_DM_2010-MATNR_SEQ.
                        LS_CHAIN-IN_SEQNO = LS_BOM-SEQNO.
                        LS_CHAIN-SEQ_MATNR = LS_BOM-MATNR.
                        LS_CHAIN-ETC_SEQ = LS_BOM-SEQNO.

                        REFRESH LT_CHK_MULTY.
                        LT_CHK_MULTY = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( GONG_SEQ = LS_DM_2010-GONG_SEQ
                                                                                               AND   ORDNR = LS_DM_2010-ORDNR
                                                                                               AND   ORDTY = LS_DM_2010-ORDTY )
                                                           ( CORRESPONDING #( LW_2010 ) ) ).
                        IF LINES( LT_CHK_MULTY ) > 1.

                          READ TABLE GT_2010 INTO DATA(LS_2010_REF) WITH KEY ORDNR = LS_DM_2010-REORD
                                                                                                POSNR = LS_DM_2010-RELINE
                                                                                                ORDTY = LS_DM_2010-REORDTY
                                                                                                USE_CHK = ABAP_TRUE.
                          IF SY-SUBRC EQ 0. " 복조장 연결의 경우 하위 오더로 상위참조오더 찾아 현재처럼 구성
                            LS_CHAIN-CHK_DUP = ABAP_TRUE.
                          ENDIF.
                        ENDIF.
* 연선복조장의 경우는 연선오더는 하나이나 이후 공정의 오더가 복조장으로 체크되지 않음 이후공정의 이전공정 오더를 찾아 표시 완료된건에 대해 중복으로 적용
                        REFRESH LT_CHK_MULTY.
                        LT_CHK_MULTY = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( GONG_SEQ = LS_DM_2010-GONG_SEQ
                                                                                               AND   REORD = LS_DM_2010-REORD
                                                                                               AND   RELINE = LS_DM_2010-RELINE
                                                                                               AND   REORDTY = LS_DM_2010-REORDTY )
                                                           ( CORRESPONDING #( LW_2010 ) ) ).
                        IF LINES( LT_CHK_MULTY ) > 1.

                          READ TABLE GT_2010 INTO LS_2010_REF WITH KEY ORDNR = LS_DM_2010-REORD
                                                                                          POSNR = LS_DM_2010-RELINE
                                                                                          ORDTY = LS_DM_2010-REORDTY
                                                                                          USE_CHK = ABAP_TRUE.
                          IF SY-SUBRC EQ 0. " 복조장 연결의 경우 하위 오더로 상위참조오더 찾아 현재처럼 구성
                            LS_CHAIN-CHK_DUP = ABAP_TRUE.
                          ENDIF.
                        ENDIF.

* 공정내 동일한 정보가 존재한다면 중복체크
                        READ TABLE <LS_GONG>-T_CHAIN TRANSPORTING NO FIELDS WITH KEY ORDNR = LS_CHAIN-ORDNR
                                                                                                                         CHK_DUP = ''.
                        IF SY-SUBRC EQ 0.
                          LS_CHAIN-CHK_DUP = ABAP_TRUE.
                        ENDIF.


                        APPEND LS_CHAIN TO <LS_GONG>-T_CHAIN.
                      ENDIF.
                    ENDIF.
                  ELSE.

                    CLEAR LS_CHAIN.
                    LS_CHAIN-IN_SEQNO = LS_BOM-SEQNO.
                    LS_CHAIN-SEQ_MATNR = LS_BOM-MATNR.
                    LS_CHAIN-ETC_SEQ = LS_BOM-SEQNO.
                    READ TABLE <LS_GONG>-T_CHAIN TRANSPORTING NO FIELDS WITH KEY ORDNR = LS_CHAIN-ORDNR
                                                                                                                      CHK_DUP = ''.
                    IF SY-SUBRC EQ 0.
                      LS_CHAIN-CHK_DUP = ABAP_TRUE.
                    ENDIF.
                    APPEND LS_CHAIN TO <LS_GONG>-T_CHAIN.

                  ENDIF.

                ELSE.
                  " 이전 공정의 오더가 비어 있다면 빈값으로 세팅 빈값 하위 오더 저장시
* 추가로 빈값이 들어오면 중복 체크로 디스플레이시 빈값이 하나만 보이도록 조치
                  CLEAR LS_CHAIN.
                  LS_CHAIN-IN_SEQNO = LS_BOM-SEQNO.
                  LS_CHAIN-SEQ_MATNR = LS_BOM-MATNR.
                  LS_CHAIN-ETC_SEQ = LS_BOM-SEQNO.
                  IF LS_PRE_CHAIN-CHK_DUP = ABAP_TRUE.
                    LS_CHAIN-CHK_DUP = ABAP_TRUE.
                  ELSE.
                    READ TABLE <LS_GONG>-T_CHAIN TRANSPORTING NO FIELDS WITH KEY ORDNR = LS_CHAIN-ORDNR
                                                                                                                      CHK_DUP = ''.
                    IF SY-SUBRC EQ 0.
                      LS_CHAIN-CHK_DUP = ABAP_TRUE.
                    ENDIF.
                  ENDIF.
                  APPEND LS_CHAIN TO <LS_GONG>-T_CHAIN.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CLEAR LV_MAX_LINE.
*  내부 구성 순번으로 정렬
    LOOP AT GT_SEQ_ROUTING INTO GS_SEQ_ROUTING.
      READ TABLE <LS_MAKE_DISPLAY>-T_GONG ASSIGNING <LS_GONG> WITH KEY GONG_SEQ = GS_SEQ_ROUTING-GONG_SEQ.
      SORT <LS_GONG>-T_CHAIN BY IN_SEQNO.

      REFRESH LT_CHK_CHAIN.
      LT_CHK_CHAIN = <LS_GONG>-T_CHAIN.

      CLEAR LV_USED_LINES.
      LOOP AT <LS_GONG>-T_CHAIN INTO DATA(LS_CHK_LINE) WHERE CHK_DUP = ' '.
        ADD 1 TO LV_USED_LINES.
      ENDLOOP.

      IF LV_MAX_LINE < LV_USED_LINES.
        LV_MAX_LINE = LV_USED_LINES.
      ENDIF.

    ENDLOOP.
    IF LV_MAX_LINE = 0.
      LV_MAX_LINE = 1.
    ENDIF.

    <LS_MAKE_DISPLAY>-MAX_LINES = LV_MAX_LINE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISPLAY_SEQNO_AND_SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DISPLAY_SEQNO_AND_SAVE .

  DATA : LV_GONG_IDX TYPE I.
  DATA : LV_CURR_SEQNO TYPE I.
  DATA : LV_REAL_SEQNO TYPE I.
  DATA : LT_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : LS_2010 TYPE ZGTPPT2010.
  DATA : BEGIN OF LS_CHK_ORDNR,
           GONG_SEQ TYPE ZGTPPT2010-GONG_SEQ,
           ORDNR    TYPE ZGTPPT2010-ORDNR,
           POSNR    TYPE ZGTPPT2010-POSNR,
           ORDTY    TYPE ZGTPPT2010-ORDTY,
         END OF LS_CHK_ORDNR.
  DATA : LT_CHK_ORDNR LIKE TABLE OF LS_CHK_ORDNR.


*  공정별로 2010 테이블 돌면서 etc_seq 필드 순번 적용.
*  비어있는 라인은 제외시킨다.
  LOOP AT GT_SEQ_ROUTING_HEADER INTO GS_SEQ_ROUTING_HEADER.
    CLEAR : LV_CURR_SEQNO, LV_GONG_IDX.
    CLEAR LV_REAL_SEQNO.
    REFRESH LT_CHK_ORDNR.

    LOOP AT GT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAKE_DISPLAY>).
      CLEAR LV_GONG_IDX.
      READ TABLE <LS_MAKE_DISPLAY>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>) WITH KEY GONG_SEQ = GS_SEQ_ROUTING_HEADER-GONG_SEQ.
      IF SY-SUBRC EQ 0.
        LV_GONG_IDX = LINES( <LS_GONG>-T_CHAIN ).
        LOOP AT <LS_GONG>-T_CHAIN ASSIGNING FIELD-SYMBOL(<LS_CHAIN_2010>).
          ADD 1 TO LV_CURR_SEQNO.
          <LS_CHAIN_2010>-ETC_SEQ = LV_CURR_SEQNO.
          IF <LS_CHAIN_2010>-CHK_DUP IS NOT INITIAL.

            IF <LS_CHAIN_2010>-ORDNR IS INITIAL.
              CONTINUE.
            ELSE.
              READ TABLE GT_2010 ASSIGNING FIELD-SYMBOL(<LS_CHK>) WITH KEY  GONG_SEQ = GS_SEQ_ROUTING_HEADER-GONG_SEQ
                                                                                                      ORDNR = <LS_CHAIN_2010>-ORDNR
                                                                                                      POSNR = <LS_CHAIN_2010>-POSNR
                                                                                                      ORDTY = <LS_CHAIN_2010>-ORDTY.

              READ TABLE LT_CHK_ORDNR INTO LS_CHK_ORDNR WITH KEY GONG_SEQ = <LS_CHK>-GONG_SEQ
                                                                                         ORDNR = <LS_CHK>-ORDNR
                                                                                         POSNR = <LS_CHK>-POSNR
                                                                                         ORDTY = <LS_CHK>-ORDTY.
              IF SY-SUBRC EQ 0.
                CONTINUE.
              ELSE.
                MOVE-CORRESPONDING <LS_CHK> TO LS_CHK_ORDNR.
                APPEND LS_CHK_ORDNR TO LT_CHK_ORDNR.
              ENDIF.
            ENDIF.
          ENDIF.

          ADD 1 TO LV_REAL_SEQNO.

          IF <LS_CHAIN_2010>-ORDNR IS NOT INITIAL.
            READ TABLE GT_2010 ASSIGNING FIELD-SYMBOL(<LS_2010>) WITH KEY GONG_SEQ = GS_SEQ_ROUTING_HEADER-GONG_SEQ
                                                                                                    ORDNR = <LS_CHAIN_2010>-ORDNR
                                                                                                    POSNR = <LS_CHAIN_2010>-POSNR
                                                                                                    ORDTY = <LS_CHAIN_2010>-ORDTY.
            IF SY-SUBRC EQ 0.
              <LS_2010>-MATNR_SEQ = <LS_CHAIN_2010>-IN_SEQNO.
              <LS_2010>-ETC_SEQ = LV_REAL_SEQNO.
              CLEAR LS_2010.
              MOVE-CORRESPONDING <LS_2010> TO LS_2010.
              APPEND LS_2010 TO LT_2010.
            ENDIF.

          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  IF LT_2010[] IS NOT INITIAL.
    MODIFY ZGTPPT2010 FROM TABLE LT_2010.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISPLAY_201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DISPLAY_201 .

  DATA : LS_201_01 TYPE REF TO DATA. " 아이템 2줄로 추가를 위해 아이템 필드 2개 구성
  DATA : LS_201_02 TYPE REF TO DATA. " 아이템 2줄로 추가를 위해 아이템 필드 2개 구성
  DATA : LT_201 TYPE REF TO DATA.
  DATA : LV_TOTAL_IDX TYPE I.
  DATA : LT_MAKE_DISPLAY LIKE TABLE OF GS_MAKE_DISPLAY.
  DATA : LV_TABIX TYPE I.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_FIRSTROW_INDEX TYPE I.
  DATA : LV_SECOND_INDEX TYPE I.
  DATA : LV_VALUE(30).
  DATA : LV_IN_SEQNO TYPE I.
  DATA : LV_CHK_WRITE_ORDNO_C.
  DATA : LV_SEQNO_N(6) TYPE N.


  FIELD-SYMBOLS : <LS_LINE01> TYPE ANY,
                  <LS_LINE02> TYPE ANY.
  FIELD-SYMBOLS : <LT_201> TYPE TABLE.

  FIELD-SYMBOLS : <LV_VALUE01> TYPE ANY,
                  <LV_VALUE02> TYPE ANY,
                  <LV_VALUE03> TYPE ANY.

  DEFINE __SET_FIELD_OF_LINE.
    IF <lv_value01> IS ASSIGNED. UNASSIGN <lv_value01>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <ls_line01> TO <lv_value01>.
    IF <lv_value02> IS ASSIGNED. UNASSIGN <lv_value02>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <ls_line02> TO <lv_value02>.
  END-OF-DEFINITION.

  DEFINE __GET_LINE_OF_TABLE.
    CLEAR : lv_firstrow_index, lv_second_index.
    lv_firstrow_index = ( lv_tabix * 2 ) + 1.
    READ TABLE <lt_201> ASSIGNING <ls_line01> INDEX lv_firstrow_index.
    lv_second_index = lv_firstrow_index + 1.
    READ TABLE <lt_201> ASSIGNING <ls_line02> INDEX lv_second_index.

    __set_field_of_line 'LINE'.
    IF <lv_value01> IS INITIAL.
      <lv_value01> = 1.
      <lv_value02> = 2.
    ENDIF.

  __set_field_of_line 'SEQNO'.
    IF <lv_value01> IS INITIAL.
      <lv_value01> = gs_make_display-end_seqno.
      <lv_value02> = gs_make_display-end_seqno.
    ENDIF.

  END-OF-DEFINITION.

  PERFORM SET_INDICATOR USING '50' '처리중..'.

  CREATE DATA LS_201_01 LIKE LINE OF <GT_MAIN_201>.
  CREATE DATA LS_201_02 LIKE LINE OF <GT_MAIN_201>.
  ASSIGN LS_201_01->* TO <LS_LINE01>.
  ASSIGN LS_201_02->* TO <LS_LINE02>.

  CREATE DATA LT_201 LIKE <GT_MAIN_201>.
  ASSIGN LT_201->* TO <LT_201>.

* 정렬
  LT_MAKE_DISPLAY = GT_MAKE_DISPLAY.

  IF GV_JOJANG_SORT IS INITIAL.
    IF GV_MAIN_SORT = 'D'.
      SORT LT_MAKE_DISPLAY BY END_SEQNO DESCENDING.
      LOOP AT LT_MAKE_DISPLAY ASSIGNING FIELD-SYMBOL(<LS_MAKE_DISPLAY>).
        LOOP AT <LS_MAKE_DISPLAY>-T_GONG ASSIGNING FIELD-SYMBOL(<LS_GONG>).
          SORT <LS_GONG>-T_CHAIN BY IN_SEQNO DESCENDING.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDIF.

* 츨력테이블 구성
  REFRESH <GT_MAIN_201>.

  LOOP AT LT_MAKE_DISPLAY INTO GS_MAKE_DISPLAY.

    CLEAR LV_SEQNO_N.
    LV_SEQNO_N = GS_MAKE_DISPLAY-END_SEQNO * 10.

    REFRESH <LT_201>.
* 해당 화면은 오더별 2줄로 구성되기 때문에 구조의 맥스 lines * 2 처리
    CLEAR LV_TOTAL_IDX.
    LV_TOTAL_IDX = GS_MAKE_DISPLAY-MAX_LINES * 2.
    DO LV_TOTAL_IDX TIMES.
      APPEND INITIAL LINE TO <LT_201>.
    ENDDO.

    CLEAR LV_TABIX.
    IF LV_TABIX = 0.
      __GET_LINE_OF_TABLE.
      __SET_FIELD_OF_LINE 'DISP_SEQNO'.
      <LV_VALUE01> = LV_SEQNO_N.

      __SET_FIELD_OF_LINE 'ORDNO_C'.
* 해당 오더 조장
      READ TABLE GT_MAIN_DISP INTO DATA(LS_MAIN) WITH KEY ORDNO = GS_MAKE_DISPLAY-END_ORDNR
                                                                      POSNR = GS_MAKE_DISPLAY-END_POSNR.
      IF SY-SUBRC EQ 0.
        CASE LS_MAIN-GCATG.
          WHEN '생산오더'.
            <LV_VALUE02> = |{ LS_MAIN-INLENGTH } (M)  |.
          WHEN '판매오더'.
            SELECT SINGLE VRKME FROM VBAP
              INTO @DATA(LV_VRKME)
              WHERE VBELN = @GS_MAKE_DISPLAY-END_ORDNR
                AND POSNR = @GS_MAKE_DISPLAY-END_POSNR.

            <LV_VALUE02> = |{ LS_MAIN-SO_INLENGTH } ({ LV_VRKME })  |.
        ENDCASE.
      ENDIF.

*    주문번호
      CLEAR LV_VALUE.
      CONCATENATE GS_MAKE_DISPLAY-END_ORDNR GS_MAKE_DISPLAY-END_POSNR
          INTO LV_VALUE SEPARATED BY '/'.
      CONCATENATE GS_MAKE_DISPLAY-GCATG LV_VALUE
          INTO LV_VALUE SEPARATED BY SPACE.
      <LV_VALUE01> = LV_VALUE.

      LV_CHK_WRITE_ORDNO_C = ABAP_TRUE.
    ENDIF.

    LOOP AT GT_SEQ_ROUTING_HEADER INTO GS_SEQ_ROUTING_HEADER.

      LV_NUM = GS_SEQ_ROUTING_HEADER-SEQNO + 0.

      LOOP AT GS_MAKE_DISPLAY-T_GONG INTO DATA(LS_GONG) WHERE SEQNO = GS_SEQ_ROUTING_HEADER-SEQNO.
        CLEAR LV_TABIX.
        LOOP AT LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WHERE CHK_DUP = ' '.
          __GET_LINE_OF_TABLE.
          ADD 1 TO LV_TABIX.

* 순번(내부 인덱스 조절용)(인덱스)
          __SET_FIELD_OF_LINE 'LINE_SEQ'.
          <LV_VALUE01> = LV_TABIX.
          <LV_VALUE02> = LV_TABIX.

* 현재 공정의 최종 오더(생산오더,판매오더) 순번
          CLEAR LV_FIELDNAME.
          LV_FIELDNAME = LV_NUM && '_' && 'END_SEQNO'.
          __SET_FIELD_OF_LINE LV_FIELDNAME.
          <LV_VALUE01> = <LV_VALUE02> = GS_MAKE_DISPLAY-END_SEQNO.
* 현재 공정의 조장구성단위 오더 순번
          CLEAR LV_FIELDNAME.
          LV_FIELDNAME = LV_NUM && '_' && 'SEQNO'.
          __SET_FIELD_OF_LINE LV_FIELDNAME.
          <LV_VALUE01> = <LV_VALUE02> = LS_CHAIN-IN_SEQNO.

* 해당 공정이 오더가 빈값이 아니고, 중복된 값이 아닐경우 디스플레이
          IF LS_CHAIN-ORDNR IS NOT INITIAL.
            CLEAR LV_FIELDNAME.
            LV_FIELDNAME = LV_NUM && '_' && LS_GONG-CHART.
            __SET_FIELD_OF_LINE LV_FIELDNAME.
            PERFORM MAKE_ROUTING_COMMENT USING LS_CHAIN GS_SEQ_ROUTING_HEADER-GONG_SEQ
                                                          CHANGING <LV_VALUE01> <LV_VALUE02>.
          ENDIF.

        ENDLOOP.

      ENDLOOP.

    ENDLOOP.

    APPEND LINES OF <LT_201> TO <GT_MAIN_201>.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_INDICATOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_20
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_INDICATOR  USING  PV_PERCENT
                             PV_TEXT.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      PERCENTAGE = PV_PERCENT                 "indicator에 진행률(%)
      TEXT       = PV_TEXT.  "텍스트 표시

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_ROUTING_COMMENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_CHAIN
*&      <-- <LV_VALUE01>
*&      <-- <LV_VALUE02>
*&---------------------------------------------------------------------*
FORM MAKE_ROUTING_COMMENT  USING    PS_CHAIN LIKE GS_CHAIN_2010
                                         PV_GONG_SEQ TYPE ZEGONG_SEQ
                           CHANGING PV_VALUE01
                                    PV_VALUE02.

  DATA : LV_STRING TYPE STRING.
  DATA : LV_VALUE TYPE C LENGTH 30.
  DATA : LV_VALUE2 TYPE P LENGTH 13 DECIMALS 2.
  DATA : LV_VALUE3 TYPE I.
  DATA : LV_PLNUM TYPE PLAF-PLNUM.
  DATA : LV_AUFNR TYPE AUFK-AUFNR.
  DATA : LT_TJ02T LIKE TJ02T OCCURS 0 WITH HEADER LINE.
  DATA : LV_STCD TYPE ZORDSTCD.
  DATA : LV_OBJNR TYPE JEST-OBJNR.
  DATA : LV_USER_LINE TYPE BSVX-STTXT.
  DATA : LT_CHARG TYPE RANGE OF MSEG-CHARG .
  DATA : LV_SEQNO_C(10).
  DATA : LV_ORDNR TYPE ZGTPPT2010-ORDNR.
  DATA : LV_EBELN TYPE EBELN.
  DATA : LV_EBELP TYPE EBELP.
  DATA : LV_MENGE TYPE MENGE_D.
  DATA : LV_CAL_MENGE TYPE MENGE_D.
  DATA : LT_CHK_2010 LIKE GT_2010.
  DATA : LV_TABIX TYPE I.

  READ TABLE GT_2010 ASSIGNING FIELD-SYMBOL(<LS_2010>) WITH KEY GONG_SEQ = PV_GONG_SEQ
                                                                                                  ORDNR = PS_CHAIN-ORDNR
                                                                                                  POSNR = PS_CHAIN-POSNR
                                                                                                  ORDTY = PS_CHAIN-ORDTY.

  IF SY-SUBRC EQ 0.

    CASE     <LS_2010>-ORDTY.
      WHEN 'PLN'. "계획오더
*      1번 라인
        CLEAR LV_PLNUM.
        LV_PLNUM = <LS_2010>-ORDNR.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = LV_PLNUM
          IMPORTING
            OUTPUT = LV_PLNUM.
        SELECT SINGLE AUFFX FROM PLAF INTO @DATA(LV_AUFFX) WHERE PLNUM = @LV_PLNUM.

        PV_VALUE01 = '계획오더'.
        IF LV_AUFFX = 'X'.
          PV_VALUE01 = PV_VALUE01 && '(F)'.
        ELSE.
          PV_VALUE01 = PV_VALUE01 && '()'.
        ENDIF.
        CLEAR LV_STRING.
        LV_ORDNR = <LS_2010>-ORDNR.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = LV_ORDNR
          IMPORTING
            OUTPUT = LV_ORDNR.
        LV_STRING = LV_ORDNR.
        CONCATENATE PV_VALUE01 LV_STRING INTO PV_VALUE01 SEPARATED BY SPACE.

      WHEN 'PR' OR 'UPR'. "판매요청
        PV_VALUE01 = '구매요청'.

        CLEAR LV_STRING.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = <LS_2010>-POSNR
          IMPORTING
            OUTPUT = LV_STRING.

        LV_ORDNR = <LS_2010>-ORDNR.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = LV_ORDNR
          IMPORTING
            OUTPUT = LV_ORDNR.

        LV_STRING = LV_ORDNR && '/' && LV_STRING.
        CONCATENATE PV_VALUE01 LV_STRING INTO PV_VALUE01 SEPARATED BY SPACE.

        SELECT SINGLE EBELN, EBELP, ELIKZ FROM EKPO
             INTO @DATA(LS_CHK_EKKO)
             WHERE BANFN = @<LS_2010>-ORDNR
               AND BNFPO = @<LS_2010>-POSNR+1(5).
        IF SY-SUBRC EQ 0.
          <LS_2010>-CHK_PRD = ABAP_TRUE.
          IF LS_CHK_EKKO-ELIKZ IS NOT INITIAL.
            <LS_2010>-CHECK_JEGO = ABAP_TRUE.
          ENDIF.
        ENDIF.

      WHEN 'PRD'. " 생산오더
*    Prd(생산오더): 오더 상태 조회 "CRTD" 상태 "(C)", "REL" 상태 "(R)", user status "PAYO" Payoff 장착 상태 "(P/O)"
        PV_VALUE01 = '생산오더'.

        LV_AUFNR = <LS_2010>-ORDNR.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = LV_AUFNR
          IMPORTING
            OUTPUT = LV_AUFNR.

*    상태값 조회
        CALL FUNCTION 'Z_PP_RETURN_ORDER_STATUS'
          EXPORTING
            IM_AUFNR        = LV_AUFNR
          IMPORTING
            EX_OSTCD        = LV_STCD
          TABLES
            ET_STTXT        = LT_TJ02T
          EXCEPTIONS
            NO_SELECTION    = 1
            NOT_FOUND_OBJNR = 2
            OTHERS          = 3.

        <LS_2010>-STATUS = LV_STCD.

        CASE LV_STCD.
          WHEN 'Z'.
            PV_VALUE01 = PV_VALUE01 && '(E)'.
            <LS_2010>-STATUS = 'E'.
          WHEN 'E'.
            PV_VALUE01 = PV_VALUE01 && '(D)'.
            <LS_2010>-STATUS = 'D'.
          WHEN 'A'.
            PV_VALUE01 = PV_VALUE01 && '(C)'.
            <LS_2010>-STATUS = 'C'.
          WHEN OTHERS.
            PV_VALUE01 = PV_VALUE01 && '(R)'.
            <LS_2010>-STATUS = 'R'.

*           오더가 작업 완료 상태일때 재고조회
            CASE LV_STCD.
              WHEN 'D' OR 'G' OR 'F' OR 'C'.
                <LS_2010>-CHK_PRD = ABAP_TRUE.
            ENDCASE.

            DATA : BEGIN OF LS_SUM_MSEG,
                     AUFNR LIKE MSEG-AUFNR,
                     AUFPS LIKE MSEG-AUFPS,
                     MENGE LIKE MSEG-MENGE,
                   END OF LS_SUM_MSEG.
            DATA : LT_SUM_MSEG LIKE TABLE OF LS_SUM_MSEG.

            DATA : LV_MATNR TYPE MATNR.

            IF <LS_2010>-REAL_MATNR IS NOT INITIAL.
              LV_MATNR = <LS_2010>-REAL_MATNR.
            ELSE.
              LV_MATNR = <LS_2010>-MATNR.
            ENDIF.

            SELECT AUFNR, AUFPS, BWART, CHARG, MENGE
               FROM MSEG
              WHERE MATNR = @LV_MATNR
                  AND BWART IN ('101', '102')
                  AND AUFNR = @LV_AUFNR
                  AND AUFPS = @<LS_2010>-POSNR+2(4)
                  AND CHARG NE 'GR_ZERO1'
                 INTO TABLE @DATA(LT_MSEG).

            IF SY-SUBRC EQ 0.

              LOOP AT LT_MSEG INTO DATA(LS_MSEG).
                CLEAR LS_SUM_MSEG.
                LS_SUM_MSEG-AUFNR = LS_MSEG-AUFNR.
                LS_SUM_MSEG-AUFPS = LS_MSEG-AUFPS.
                CASE LS_MSEG-BWART.
                  WHEN '101'.
                    APPEND INITIAL LINE TO LT_CHARG ASSIGNING FIELD-SYMBOL(<LS_CHARG>).
                    <LS_CHARG>-SIGN = 'I'.
                    <LS_CHARG>-OPTION = 'EQ'.
                    <LS_CHARG>-LOW = LS_MSEG-CHARG.

                    LS_SUM_MSEG-MENGE = LS_MSEG-MENGE .
                  WHEN '102'.
                    LS_SUM_MSEG-MENGE = LS_MSEG-MENGE * -1.
                ENDCASE.
                COLLECT LS_SUM_MSEG INTO LT_SUM_MSEG.
              ENDLOOP.

              SORT LT_CHARG BY LOW.
              DELETE ADJACENT DUPLICATES FROM LT_CHARG COMPARING LOW.

              SELECT SINGLE AUFNR, POSNR, PSMNG, PSAMG, KDAUF, KDPOS, LGORT
                FROM  AFPO
               WHERE AUFNR = @LV_AUFNR
                  AND POSNR = @<LS_2010>-POSNR+2(4)
                  AND CHARG NE 'GR_ZERO1'
                 INTO @DATA(LS_AFPO).
* 오더의 자재입고 완료 여부
              READ TABLE LT_SUM_MSEG INTO LS_SUM_MSEG INDEX 1. " 한건만 존재
              LS_AFPO-PSMNG  = LS_AFPO-PSMNG  + LS_AFPO-PSAMG.
              "입고된 자재수량과 생산오더의 총수량이 같으면 재고 완료 처리.
              IF LS_SUM_MSEG-MENGE > 0.
                <LS_2010>-CHECK_JEGO = ABAP_TRUE.
              ENDIF.
* 자재가 이후공정으로 옮겨갔는지 확인.
              IF LS_AFPO-KDAUF IS NOT INITIAL. " 완제품 수량
                SELECT SINGLE SUM( KALAB ) AS KALAB, SUM( KAINS ) AS KAINS, SUM( KASPE ) AS KASPE
                  FROM MSKA
                  WHERE MATNR = @LV_MATNR
                     AND WERKS = @P_WERKS
*                     AND LGORT = @LS_AFPO-LGORT
                     AND CHARG IN @LT_CHARG
                     AND VBELN = @LS_AFPO-KDAUF
                     AND POSNR = @LS_AFPO-KDPOS
                  GROUP BY MATNR, WERKS
                   INTO (@DATA(LV_KALAB), @DATA(LV_KAINS), @DATA(LV_KASPE)).
                IF LV_KALAB = 0 AND LV_KAINS = 0 AND LV_KASPE = 0.
                  <LS_2010>-CHECK_ZERO = ABAP_TRUE.
                ENDIF.

              ELSE. " 반제품 수량체크
                SELECT SINGLE SUM( CLABS ) AS CLABS, SUM( CINSM ) AS CINSM, SUM( CSPEM ) AS CSPEM
                  FROM MCHB
                  WHERE MATNR = @LV_MATNR
                     AND WERKS = @P_WERKS
                     AND LGORT = @LS_AFPO-LGORT
                     AND CHARG IN @LT_CHARG
                   GROUP BY MATNR, WERKS
                   INTO (@DATA(LV_CLABS),@DATA(LV_CINSM), @DATA(LV_CSPEM)).
                IF LV_CLABS = 0 AND LV_CINSM = 0 AND LV_CSPEM = 0.
                  <LS_2010>-CHECK_ZERO = ABAP_TRUE.
                ENDIF.

              ENDIF.

            ENDIF.
        ENDCASE.

*        ENDCASE.
*    유저스테이터스 조회
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = LV_AUFNR
          IMPORTING
            OUTPUT = LV_AUFNR.

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
        IF LV_LINE > 0.
          IF <LS_2010>-CHECK_JEGO IS INITIAL AND <LS_2010>-CHECK_ZERO IS INITIAL.
            PV_VALUE01 = PV_VALUE01 && '(P/O)'.
          ENDIF.
          <LS_2010>-CHK_PRD = ABAP_TRUE.
        ENDIF.

        CLEAR LV_STRING.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = <LS_2010>-POSNR
          IMPORTING
            OUTPUT = LV_STRING.

        LV_ORDNR = <LS_2010>-ORDNR.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = LV_ORDNR
          IMPORTING
            OUTPUT = LV_ORDNR.

        LV_STRING = LV_ORDNR && '/' && LV_STRING.
        CONCATENATE PV_VALUE01 LV_STRING INTO PV_VALUE01 SEPARATED BY SPACE.
      WHEN 'PO'.
        PV_VALUE01 = '구매오더'.

        CLEAR LV_STRING.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = <LS_2010>-POSNR
          IMPORTING
            OUTPUT = LV_STRING.

        LV_ORDNR = <LS_2010>-ORDNR.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = LV_ORDNR
          IMPORTING
            OUTPUT = LV_ORDNR.

        LV_STRING = LV_ORDNR && '/' && LV_STRING.
        CONCATENATE PV_VALUE01 LV_STRING INTO PV_VALUE01 SEPARATED BY SPACE.

* 상태확인
        LV_EBELN = <LS_2010>-ORDNR.
        LV_EBELP = <LS_2010>-POSNR + 0.

        SELECT EBELN, EBELP, BWART, SHKZG, MENGE FROM MSEG
          INTO TABLE @DATA(LT_EKKO_MSEG)
         WHERE EBELN = @LV_EBELN
          AND EBELP = @LV_EBELP
          AND MATNR = @<LS_2010>-MATNR.

        CLEAR LV_MENGE.
        LOOP AT LT_EKKO_MSEG INTO DATA(LS_EKKO_MSEG).
          CASE LS_EKKO_MSEG-SHKZG.
            WHEN 'H'.
              LV_MENGE = LV_MENGE + ( -1 * LS_EKKO_MSEG-MENGE ).

            WHEN OTHERS.
              LV_MENGE = LV_MENGE + LS_EKKO_MSEG-MENGE.
          ENDCASE.
        ENDLOOP.


        SELECT SINGLE EBELN, EBELP, ELIKZ FROM EKPO
          INTO @DATA(LS_EKKO)
          WHERE EBELN = @LV_EBELN
            AND EBELP = @LV_EBELP.
        IF LS_EKKO-ELIKZ IS NOT INITIAL.
          <LS_2010>-CHECK_JEGO = ABAP_TRUE.
          <LS_2010>-CHK_PRD = ABAP_TRUE.
        ELSE.

          IF LV_MENGE > 0.
            <LS_2010>-CHK_PRD = ABAP_TRUE.
          ENDIF.

        ENDIF.

    ENDCASE.

* 색상
    IF <LS_2010>-REAL_MATNR IS NOT INITIAL.
      LV_MATNR = <LS_2010>-REAL_MATNR.
    ELSE.
      LV_MATNR = <LS_2010>-MATNR.
    ENDIF.

    SELECT SINGLE * FROM ZGTCVMSTVAL
      INTO @DATA(LS_CVMSTVAL)
     WHERE WERKS = @P_WERKS
        AND MATNR = @LV_MATNR.
    IF SY-SUBRC EQ 0.
      IF LS_CVMSTVAL-COLORBASE IS NOT INITIAL.
        PV_VALUE01 = PV_VALUE01 && '(' && LS_CVMSTVAL-COLORBASE && ')'.
      ENDIF.
    ENDIF.

* 1번라인 순번적용.( 자신의 순번 )
    CLEAR LV_SEQNO_C.
    LV_SEQNO_C = <LS_2010>-ETC_SEQ.
    CONDENSE LV_SEQNO_C.
    CONCATENATE LV_SEQNO_C PV_VALUE01 INTO PV_VALUE01 SEPARATED BY SPACE.


*    2번 라인
    IF <LS_2010>-CHECK_JEGO IS INITIAL.
      CLEAR LV_VALUE.

* 여장 디스플레이 방식 변경
      CLEAR GS_MAINTAIN_INLENGTH.
      READ TABLE GT_MAINTAIN_INLENGTH INTO GS_MAINTAIN_INLENGTH WITH KEY GONG_SEQ = <LS_2010>-GONG_SEQ
                                                                                                       ORDNR = <LS_2010>-ORDNR
                                                                                                       POSNR = <LS_2010>-POSNR
                                                                                                       ORDTY = <LS_2010>-ORDTY.
      IF SY-SUBRC EQ 0.
* 조장은 최종공정의 inlength
        LV_VALUE = GS_MAINTAIN_INLENGTH-INLENGTH.
        CONDENSE LV_VALUE.
        SPLIT LV_VALUE AT '.' INTO DATA(LV_NUM) DATA(LV_DOT).
        IF LV_DOT > 0.
          LV_VALUE = GS_MAINTAIN_INLENGTH-INLENGTH.
        ELSE.
          LV_VALUE3 = GS_MAINTAIN_INLENGTH-INLENGTH.
          LV_VALUE = LV_VALUE3.
        ENDIF.

        CONDENSE LV_VALUE.
        CONCATENATE '(' LV_VALUE INTO PV_VALUE02.
*여장 추가
        LV_CAL_MENGE = ( <LS_2010>-INLENGTH + <LS_2010>-QLENGTH + <LS_2010>-CLENGTH +
                                  <LS_2010>-SLENGTH + <LS_2010>-ELENGTH + <LS_2010>-ADLENGTH ) *
                                  <LS_2010>-INFACTOR.

        LV_CAL_MENGE = LV_CAL_MENGE - GS_MAINTAIN_INLENGTH-INLENGTH.
        IF LV_CAL_MENGE > 0.
          LV_VALUE = LV_CAL_MENGE.
          CONDENSE LV_VALUE.
          CLEAR : LV_NUM, LV_DOT.
          SPLIT LV_VALUE AT '.' INTO LV_NUM LV_DOT.
          IF LV_DOT > 0.
            LV_VALUE = LV_CAL_MENGE.
          ELSE.
            LV_VALUE3 = LV_CAL_MENGE.
            LV_VALUE = LV_VALUE3.
          ENDIF.

          CONDENSE LV_VALUE.
          CONCATENATE PV_VALUE02 '+' LV_VALUE  INTO PV_VALUE02.
        ELSE.

        ENDIF.

      ELSE.


        IF <LS_2010>-DMORDTY = 'SO' OR <LS_2010>-DMORDTY = 'SM'.
          LV_VALUE = <LS_2010>-INLENGTH.
          CONDENSE LV_VALUE.
          CLEAR : LV_NUM, LV_DOT.
          SPLIT LV_VALUE AT '.' INTO LV_NUM LV_DOT.
          IF LV_DOT > 0.
            LV_VALUE = <LS_2010>-INLENGTH.
          ELSE.
            LV_VALUE3 = <LS_2010>-INLENGTH.
            LV_VALUE = LV_VALUE3.
          ENDIF.
        ELSE.
          LV_VALUE3 = <LS_2010>-INLENGTH.
          LV_VALUE = LV_VALUE3.
        ENDIF.

        CONDENSE LV_VALUE.
        CONCATENATE '(' LV_VALUE INTO PV_VALUE02.
        IF <LS_2010>-QLENGTH = 0 AND <LS_2010>-CLENGTH = 0 AND <LS_2010>-ADLENGTH = 0.
        ELSE.
* 검사여장,
          LV_VALUE3 = <LS_2010>-QLENGTH.
          LV_VALUE = LV_VALUE3.
          CONDENSE LV_VALUE.
          CONCATENATE PV_VALUE02 '+' LV_VALUE '+' INTO PV_VALUE02.
* 연결여장
          LV_VALUE3 = <LS_2010>-CLENGTH.
          LV_VALUE = LV_VALUE3.
          CONDENSE LV_VALUE.
          CONCATENATE PV_VALUE02  LV_VALUE '+' INTO PV_VALUE02.
* 추가여장
          LV_VALUE3 = <LS_2010>-ADLENGTH.
          LV_VALUE = LV_VALUE3.
          CONDENSE LV_VALUE.
          CONCATENATE PV_VALUE02  LV_VALUE  INTO PV_VALUE02.
        ENDIF.

      ENDIF.
* 조장수
      LV_VALUE3 = <LS_2010>-INFACTOR.
      LV_VALUE = LV_VALUE3.
      CONDENSE LV_VALUE.

* 완제품 Factor Batch 복조장은 해당 오더의 라인수로 조장수 산정
      IF <LS_2010>-MULTY_REF = ABAP_TRUE.
        REFRESH LT_CHK_2010.
        LT_CHK_2010 = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( GRPNR = <LS_2010>-GRPNR
                                                                           AND   ORDNR = <LS_2010>-ORDNR
                                                                           AND   GONG_SEQ = <LS_2010>-GONG_SEQ )
                                         ( CORRESPONDING #( LW_2010 ) ) ).

        LV_VALUE3 = LINES( LT_CHK_2010 ).
        LV_VALUE = LV_VALUE3.
        CONDENSE LV_VALUE.
      ENDIF.

      CONCATENATE PV_VALUE02 ')X' LV_VALUE INTO PV_VALUE02.

    ELSE.
      <LS_2010>-CHECK_JEGO = ABAP_TRUE.
      IF <LS_2010>-CHECK_ZERO = ABAP_TRUE.
        LV_VALUE2 = 0.
      ELSE.
        IF <LS_2010>-ORDTY = 'PO'.
          IF LV_MENGE > 0.
            <LS_2010>-CHECK_JEGO = 'Q'.
            LV_VALUE2 = LV_MENGE.
          ELSE.
            LV_VALUE2 = 0.
          ENDIF.
        ELSE.
          IF LS_AFPO-KDAUF IS NOT INITIAL. " 완제품 수량
            IF LV_KAINS > 0.
              <LS_2010>-CHECK_JEGO = 'Q'.
              LV_VALUE2 = LV_KAINS.
            ELSEIF LV_KASPE > 0.
              <LS_2010>-CHECK_JEGO = 'B'.
              LV_VALUE2 = LV_KASPE.
            ELSE.
              LV_VALUE2 = LV_KALAB.
            ENDIF.
          ELSE.
            IF LV_CINSM > 0.
              <LS_2010>-CHECK_JEGO = 'Q'.
              LV_VALUE2 = LV_CINSM.
            ELSEIF LV_CSPEM > 0.
              <LS_2010>-CHECK_JEGO = 'B'.
              LV_VALUE2 = LV_CSPEM.
            ELSE.
              LV_VALUE2 = LV_CLABS.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      LV_VALUE = LV_VALUE2.
      CONDENSE LV_VALUE.
*  재고수량,
      IF <LS_2010>-CHECK_JEGO = 'Q'.
        CONCATENATE '( QI Stock' LV_VALUE ')' INTO PV_VALUE02 SEPARATED BY SPACE.
      ELSEIF <LS_2010>-CHECK_JEGO = 'B'.
        CONCATENATE '( Block Stock' LV_VALUE ')' INTO PV_VALUE02 SEPARATED BY SPACE.
      ELSE.
        CONCATENATE '( Stock' LV_VALUE ')' INTO PV_VALUE02 SEPARATED BY SPACE.
      ENDIF.
    ENDIF.



*  2번 라인 순번 적용 (이후 공정의 라인 모두 적용)
    DATA : LV_SEQNO TYPE I.
    DATA : LV_ETC_SEQ_C(10).
    DATA : LS_2010_CHK TYPE ZGTPPT2010.
    DATA : LS_2010_CHK_TANDEM TYPE ZGTPPT2010.
    DATA : LT_2010_CHK TYPE TABLE OF ZGTPPT2010.
    DATA : LT_2010_CHK_TANDEM TYPE TABLE OF ZGTPPT2010.
    DATA : LV_DR_MATNR TYPE MATNR.
    DATA : LV_VBELN TYPE VBAP-VBELN.
    DATA : LV_POSNR TYPE VBAP-POSNR.
    DATA : LV_PACK_YN TYPE CHAR10.
    DATA : LV_PACK_DM TYPE MATNR.
    DATA : LV_ZZCUT_REQ TYPE AUFK-ZZCUT_REQ.

*  판매오더 완제품의 경우 해당 판매오더의 경우 일치하는 포장재가 있다면 포장재 보여준다.
    CASE <LS_2010>-DMORDTY.
      WHEN 'SO' OR 'SM'.
        READ TABLE GT_MATCH_POJANG TRANSPORTING NO FIELDS WITH KEY ORDNR = <LS_2010>-ORDNR
                                                                                               POSNR = <LS_2010>-POSNR.

        IF SY-SUBRC EQ 0.
          PV_VALUE02 = |{ PV_VALUE02 }　◎|.
        ENDIF.

        CLEAR LV_ZZCUT_REQ.
        SELECT SINGLE ZZCUT_REQ FROM AUFK
          INTO LV_ZZCUT_REQ
         WHERE AUFNR = <LS_2010>-ORDNR.
        IF LV_ZZCUT_REQ IS NOT INITIAL.
          PV_VALUE02 = |{ PV_VALUE02 }　cut|.
        ENDIF.
    ENDCASE.



*  공정순서로 바로 이어지는 이후 공정의 경우 공정 순번 제외
    READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_NOW_GONG) WITH KEY GONG_SEQ = <LS_2010>-GONG_SEQ.
    LV_SEQNO = LS_NOW_GONG-SEQNO + 1.

    READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_NEXT) WITH KEY SEQNO = LV_SEQNO.
    IF SY-SUBRC EQ 0.
      CLEAR LV_STRING.
      LOOP AT GT_2010 INTO GS_2010 WHERE GONG_SEQ >= LS_NEXT-GONG_SEQ
                                               AND REORD = <LS_2010>-ORDNR
                                               AND RELINE = <LS_2010>-POSNR
                                               AND REORDTY = <LS_2010>-ORDTY.

        MOVE-CORRESPONDING GS_2010 TO LS_2010_CHK.
        APPEND LS_2010_CHK TO LT_2010_CHK.

      ENDLOOP.

      IF LT_2010_CHK[] IS INITIAL.
        CASE <LS_2010>-DMORDTY.
          WHEN 'PO' OR 'UPR'.
            LOOP AT GT_2010 INTO GS_2010 WHERE GONG_SEQ = LS_NEXT-GONG_SEQ
                                         AND ORDNR = <LS_2010>-DMORD
                                         AND POSNR = <LS_2010>-DMLINE
                                         AND ORDTY = <LS_2010>-DMORDTY.

              LOOP AT GT_2010 INTO DATA(LS_2010_TEMP) WHERE REORD = GS_2010-REORD
                                                       AND RELINE = GS_2010-RELINE
                                                       AND REORDTY = GS_2010-REORDTY.
                MOVE-CORRESPONDING LS_2010_TEMP TO LS_2010_CHK.
                APPEND LS_2010_CHK TO LT_2010_CHK.
              ENDLOOP.
            ENDLOOP.
          WHEN OTHERS.
            LOOP AT GT_2010 INTO GS_2010 WHERE ORDNR = <LS_2010>-DMORD
                                         AND POSNR = <LS_2010>-DMLINE
                                         AND ORDTY = <LS_2010>-DMORDTY.
              IF GS_2010-REORD IS INITIAL.
                MOVE-CORRESPONDING GS_2010 TO LS_2010_CHK.
                APPEND LS_2010_CHK TO LT_2010_CHK.
              ELSE.
                LOOP AT GT_2010 INTO LS_2010_TEMP WHERE GONG_SEQ = GS_2010-GONG_SEQ
                                                          AND REORD = GS_2010-REORD
                                                         AND RELINE = GS_2010-RELINE
                                                         AND REORDTY = GS_2010-REORDTY.
                  MOVE-CORRESPONDING LS_2010_TEMP TO LS_2010_CHK.
                  APPEND LS_2010_CHK TO LT_2010_CHK.
                ENDLOOP.
              ENDIF.
            ENDLOOP.
        ENDCASE.
      ENDIF.

      SORT LT_2010_CHK BY GONG_SEQ ORDNR POSNR ORDTY.
      DELETE ADJACENT DUPLICATES FROM LT_2010_CHK COMPARING GONG_SEQ ORDNR POSNR ORDTY.

      LOOP AT LT_2010_CHK INTO LS_2010_CHK.
        IF LS_2010_CHK-REF_TANDEM = ABAP_TRUE.
          LV_TABIX = SY-TABIX.
          LOOP AT GT_2010 INTO GS_2010 WHERE GONG_SEQ > LS_2010_CHK-GONG_SEQ
                                               AND REORD = LS_2010_CHK-ORDNR
                                               AND RELINE = LS_2010_CHK-POSNR
                                               AND REORDTY = LS_2010_CHK-ORDTY.

            CLEAR LS_2010_CHK_TANDEM.
            MOVE-CORRESPONDING GS_2010 TO LS_2010_CHK_TANDEM.
            APPEND LS_2010_CHK_TANDEM TO LT_2010_CHK_TANDEM.

          ENDLOOP.
          DELETE LT_2010_CHK INDEX LV_TABIX.
        ENDIF.

      ENDLOOP.

      IF LT_2010_CHK_TANDEM[] IS NOT INITIAL.
        SORT LT_2010_CHK_TANDEM BY GONG_SEQ ORDNR POSNR ORDTY.
        DELETE ADJACENT DUPLICATES FROM LT_2010_CHK_TANDEM COMPARING GONG_SEQ ORDNR POSNR ORDTY.
        SORT LT_2010_CHK_TANDEM BY ETC_SEQ.

        APPEND LINES OF LT_2010_CHK_TANDEM TO LT_2010_CHK.

      ENDIF.

      CLEAR LV_STRING.
      LOOP AT LT_2010_CHK INTO LS_2010_CHK.
        CLEAR : LV_SEQNO_C, LV_ETC_SEQ_C.
        READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_TEMP) WITH KEY GONG_SEQ = LS_2010_CHK-GONG_SEQ.
        IF SY-SUBRC EQ 0.
          LV_SEQNO_C = LS_TEMP-SEQNO.
          CONDENSE LV_SEQNO_C.
        ENDIF.
        LV_ETC_SEQ_C = LS_2010_CHK-ETC_SEQ.
        CONDENSE LV_ETC_SEQ_C.

        IF LV_STRING IS INITIAL.
          LV_STRING = '('.
        ELSE.
          LV_STRING = LV_STRING && ','.
        ENDIF.

        IF LS_NEXT-SEQNO = LS_TEMP-SEQNO.
          CONCATENATE LV_STRING LV_ETC_SEQ_C INTO LV_STRING.
        ELSE.
          CONCATENATE LV_STRING LV_SEQNO_C '-' LV_ETC_SEQ_C INTO LV_STRING.
        ENDIF.
      ENDLOOP.
      LV_STRING = LV_STRING && ')'.

      PV_VALUE02 = PV_VALUE02 && LV_STRING.

    ELSE. " 이후 공정 존재하지 않는다면 완제품 공정이므로 이후공정 순번적용 없음
    ENDIF.



  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_SCREEN_201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_SCREEN_201 .

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  PERFORM MAKE_DATA_201.
  IF GV_CHK_SUBPOOL_DIR_FULL IS NOT INITIAL.
    IF GV_CHK_SUBPOOL_DIR_FULL IS NOT INITIAL.
*     종료
      CALL FUNCTION 'DEQUEUE_EZGT_ZGTPPR2010'
        EXPORTING
          GRPNR = GV_GRPNR.

      CALL METHOD GO_DOCKING_CONTAINER->FREE.
      FREE : GO_DOCKING_CONTAINER, GO_GRID_0200, GO_GRID_0201.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    ENDIF.

  ENDIF.

  PERFORM SET_CELL_ATTRIBUTE_GRID_0201.
  PERFORM SET_SORTTAB_GRID_0201.

  GO_GRID_0201->SET_SORT_CRITERIA(
    EXPORTING
      IT_SORT                   = GT_SORT_0201                 " Sort Criteria
  ).

  CALL METHOD GO_GRID_0201->SET_FRONTEND_FIELDCATALOG
    EXPORTING
      IT_FIELDCATALOG = GT_FIELDCAT_0201.                 " Field Catalog
  CALL METHOD GO_GRID_0201->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CREATE_ROUTING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CREATE_ROUTING .

  DATA : LO_JOJANG TYPE REF TO ZGTPP_CL_ROUTING_GAON.
  DATA : LV_RESULT TYPE CHAR01.
  DATA : LS_MESSAGE TYPE BAPIRETURN1.
  DATA : LV_MENGE TYPE MENGE_D.
  DATA : BEGIN OF LS_INSP_QLENGTH,
           ORDNO   TYPE ZGTPPT2000-ORDNO,
           POSNR   TYPE ZGTPPT2000-POSNR,
           QLENGTH TYPE ZGTPPT2010-QLENGTH,
         END OF LS_INSP_QLENGTH.
  DATA : LT_INSP_QLENGTH LIKE TABLE OF LS_INSP_QLENGTH.

* 입회검사 대상일시 입회검사여장 입력여부 확인 없으면 종료
  LOOP AT GT_MAIN_200 INTO DATA(LS_MAIN) WHERE INSPE_YN = '유'.
* 장납품 자재 청구 관련해서 조장번호 생성시 판매오더 상태값 체크 제외(포장재, 입회검사여장)
**    CLEAR LV_MENGE.
**    LV_MENGE = LS_MAIN-INSPE_QLENGTH.
**
**    IF LV_MENGE = 0.
**      MESSAGE S006 DISPLAY LIKE 'E' WITH '입회 검사 여장이 등록되지 않았습니다. QA에 문의 바랍니다.'(e81).
**      RETURN.
**    ENDIF.

    CLEAR LS_INSP_QLENGTH.
    LS_INSP_QLENGTH-ORDNO = LS_MAIN-ORDNO.
    LS_INSP_QLENGTH-POSNR = LS_MAIN-POSNR.
    LS_INSP_QLENGTH-QLENGTH = LS_MAIN-INSPE_QLENGTH.
    APPEND LS_INSP_QLENGTH TO LT_INSP_QLENGTH.

  ENDLOOP.


  CREATE OBJECT LO_JOJANG
    EXPORTING
      IV_WERKS              = P_WERKS                 " 플랜트
      IV_GRPNR              = GV_GRPNR                 " 조장 구성표 번호
      IT_MAIN               = GT_MAKE_DISPLAY
      IT_SEQ_ROUTING_HEADER = GT_SEQ_ROUTING_HEADER
      IT_SEQ_ROUTING_SUB    = GT_SEQ_ROUTING_SUB
      IT_MAKED_2010         = GT_2010
      IT_INSP_QLENGTH       = LT_INSP_QLENGTH.

  LO_JOJANG->PROC_MAKE_PLAN_ORDER(
    IMPORTING
      EV_RETURN  = LV_RESULT                 " 길이 1의 문자 필드
      ES_MESSAGE = LS_MESSAGE                 " 문자 100
  ).

  IF LV_RESULT EQ 'E'.
    MESSAGE S003 WITH LS_MESSAGE-MESSAGE DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

*  변경정보 MES전송
  ZGTPP_CL_ROUTING=>SEND_CHG_MES(
    IV_WERKS = P_WERKS           " 플랜트
    IV_SPGCD = P_SPGCD          " SPG 코드
    IV_GRPNR = GV_GRPNR ).    " 조장 구성표 번호

  PERFORM REFRESH_SCREEN_201.
  MESSAGE S003 WITH LS_MESSAGE-MESSAGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOWNLOAD_EXCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DOWNLOAD_EXCEL .

  TYPES: BEGIN OF TY_HEAD_STYLE,
           NAME  TYPE STRING,
           WIDTH TYPE CHAR3,
         END OF  TY_HEAD_STYLE.

  TYPES: BEGIN OF TY_BODY_STYLE,
           INDEX TYPE SY-TABIX,
           TYPE  TYPE CHAR1,
         END OF  TY_BODY_STYLE.

  DATA: LT_HEAD_STYLE TYPE TABLE OF TY_HEAD_STYLE,
        LS_HEAD_STYLE TYPE TY_HEAD_STYLE,
        LT_BODY_STYLE TYPE TABLE OF TY_BODY_STYLE,
        LS_BODY_STYLE TYPE TY_BODY_STYLE,
        LT_BINTAB     TYPE SOLIX_TAB.
  DATA : LV_INDEX TYPE I.

  DATA: LV_WORKSHEET TYPE STRING.

  DATA : LT_FCAT_LVC TYPE LVC_T_FCAT.
  DATA : LO_TABLE TYPE REF TO DATA.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME(30).
  DATA : LT_SEQ_ROUTING_HEADER LIKE TABLE OF GS_SEQ_ROUTING_HEADER.
  FIELD-SYMBOLS : <LT_DATA> TYPE TABLE.
  FIELD-SYMBOLS : <LV_VALUE> TYPE ANY.

  LT_SEQ_ROUTING_HEADER = GT_SEQ_ROUTING_HEADER.
  SORT LT_SEQ_ROUTING_HEADER BY SEQNO.
  "엑셀 파일명.

  LV_WORKSHEET  = '조장구성표(' && GV_GRPNR && ')_' && SY-DATUM.

  SORT GT_FIELDCAT_0201 BY COL_POS.

  LOOP AT GT_FIELDCAT_0201 INTO DATA(LS_FCAT).
    IF LS_FCAT-FIELDNAME = 'DISP_SEQNO'.
      CLEAR LS_HEAD_STYLE.
      LS_HEAD_STYLE-NAME = LS_FCAT-REPTEXT.
      LS_HEAD_STYLE-WIDTH = '50'.
      APPEND LS_HEAD_STYLE TO LT_HEAD_STYLE.

      CLEAR LS_BODY_STYLE.
      ADD 1 TO LV_INDEX.
      LS_BODY_STYLE-INDEX = LV_INDEX.
      LS_BODY_STYLE-TYPE = 'C'.
      APPEND LS_BODY_STYLE TO LT_BODY_STYLE.

    ENDIF.

    LOOP AT LT_SEQ_ROUTING_HEADER INTO DATA(LS_TEMP).
      CLEAR LV_NUM.
      LV_NUM = LS_TEMP-SEQNO + 0.
      CLEAR LV_FIELDNAME.
      LV_FIELDNAME = LV_NUM && '_' && LS_TEMP-CHART.
      IF LS_FCAT-FIELDNAME = LV_FIELDNAME.
        CLEAR LS_HEAD_STYLE.
        LS_HEAD_STYLE-NAME = LS_FCAT-REPTEXT.
        LS_HEAD_STYLE-WIDTH = '180'.
        APPEND LS_HEAD_STYLE TO LT_HEAD_STYLE.

        CLEAR LS_BODY_STYLE.
        ADD 1 TO LV_INDEX.
        LS_BODY_STYLE-INDEX = LV_INDEX.
        LS_BODY_STYLE-TYPE = LS_FCAT-DD_OUTLEN.
        APPEND LS_BODY_STYLE TO LT_BODY_STYLE.
      ENDIF.
    ENDLOOP.

    IF LS_FCAT-FIELDNAME = 'ORDNO_C'.
      CLEAR LS_HEAD_STYLE.
      LS_HEAD_STYLE-NAME = LS_FCAT-REPTEXT.
      LS_HEAD_STYLE-WIDTH = '150'.
      APPEND LS_HEAD_STYLE TO LT_HEAD_STYLE.

      CLEAR LS_BODY_STYLE.
      ADD 1 TO LV_INDEX.
      LS_BODY_STYLE-INDEX = LV_INDEX.
      LS_BODY_STYLE-TYPE = 'T'.
      APPEND LS_BODY_STYLE TO LT_BODY_STYLE.
    ENDIF.

  ENDLOOP.

  LOOP AT GT_FIELDCAT_0201 INTO LS_FCAT.
    IF LS_FCAT-FIELDNAME = 'DISP_SEQNO'.
      LS_FCAT-DATATYPE = 'CAHR'.
      APPEND LS_FCAT TO LT_FCAT_LVC.

    ENDIF.

    LOOP AT LT_SEQ_ROUTING_HEADER INTO LS_TEMP.
      CLEAR LV_NUM.
      LV_NUM = LS_TEMP-SEQNO + 0.
      CLEAR LV_FIELDNAME.
      LV_FIELDNAME = LV_NUM && '_' && LS_TEMP-CHART.
      IF LS_FCAT-FIELDNAME = LV_FIELDNAME.
        APPEND LS_FCAT TO LT_FCAT_LVC.
      ENDIF.
    ENDLOOP.

    IF LS_FCAT-FIELDNAME = 'ORDNO_C'.
      APPEND LS_FCAT TO LT_FCAT_LVC.
    ENDIF.

  ENDLOOP.


  CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE(
    EXPORTING
*      I_STYLE_TABLE       = ABAP_TRUE
      IT_FIELDCATALOG           = LT_FCAT_LVC                " Field Catalog
    IMPORTING
      EP_TABLE                  = LO_TABLE                 " Pointer to Dynamic Data Table
    EXCEPTIONS
      GENERATE_SUBPOOL_DIR_FULL = 1                " At Most 36 Subroutine Pools Can Be Generated Temporarily
      OTHERS                    = 2
  ).
  IF SY-SUBRC <> 0.
  ENDIF.

  ASSIGN LO_TABLE->* TO <LT_DATA>.

  MOVE-CORRESPONDING <GT_MAIN_201> TO <LT_DATA>.

  LOOP AT <LT_DATA> ASSIGNING FIELD-SYMBOL(<LS_DATA>).
    IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
    ASSIGN COMPONENT 'DISP_SEQNO' OF STRUCTURE <LS_DATA> TO <LV_VALUE>.
    IF <LV_VALUE> IS ASSIGNED AND <LV_VALUE> = '000000'.
      CLEAR <LV_VALUE>.
    ENDIF.
  ENDLOOP.

  "Excel Object 생성.
  DATA(LO_EXCEL) = NEW ZGTCO_CL_EXCEL_SERVICE( ).

  LO_EXCEL->CREATE_DOCUMENT( ).
  LO_EXCEL->CREATE_STYLE( ).
  LO_EXCEL->ADD_WORKSHEET( LV_WORKSHEET ).
  LO_EXCEL->ADD_TABLE( ).

  LO_EXCEL->SET_HEAD_VALUE( IT_HEAD_STYLE = LT_HEAD_STYLE ).

  DATA(LV_SUCCESS) = LO_EXCEL->SET_BODY_VALUE( IT_BODY_STYLE = LT_BODY_STYLE
                                               IT_BODY_DATA = <LT_DATA> ).

  IF LV_SUCCESS EQ ABAP_TRUE.
    LO_EXCEL->GET_BINARY_DATA( IMPORTING ET_EXCEL_BODY = DATA(LT_BIN_EXCEL) EV_EXCEL_SIZE = DATA(LV_BIN_SIZE) ).

    "Local data declarations.
    DATA : LV_PATH     TYPE STRING,
           LV_FILENAME TYPE STRING,
           LV_FULLPATH TYPE STRING.

    LV_FILENAME = |export_{ SY-DATUM }_{ GV_GRPNR }.xls|.
    "Call method to fetch the path.
    CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG(
       EXPORTING
         DEFAULT_FILE_NAME          = LV_FILENAME
         DEFAULT_EXTENSION         = 'xls'
         FILE_FILTER    = '*.xls'
       CHANGING
         FILENAME                  = LV_FILENAME
         PATH                      = LV_PATH
         FULLPATH                  = LV_FULLPATH
       EXCEPTIONS
         CNTL_ERROR                = 1
         ERROR_NO_GUI              = 2
         INVALID_DEFAULT_FILE_NAME = 3
         NOT_SUPPORTED_BY_GUI      = 4
         OTHERS                    = 5
     ).

    "Call method to download excel file.
    CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD(
      EXPORTING
        BIN_FILESIZE              = CONV #( LV_BIN_SIZE ) " File length for binary files
        FILENAME                  = LV_FULLPATH             " Name of file
        FILETYPE                  = 'BIN'                   " File type (ASCII, binary ...)
      CHANGING
        DATA_TAB                  = LT_BIN_EXCEL           " Transfer table
      EXCEPTIONS
        FILE_WRITE_ERROR          = 1                       " Cannot write to file
        NO_BATCH                  = 2                       " Cannot execute front-end function in background
        GUI_REFUSE_FILETRANSFER   = 3                       " Incorrect Front End
        INVALID_TYPE              = 4                       " Invalid value for parameter FILETYPE
        NO_AUTHORITY              = 5                       " No Download Authorization
        UNKNOWN_ERROR             = 6                       " Unknown error
        HEADER_NOT_ALLOWED        = 7                       " Invalid header
        SEPARATOR_NOT_ALLOWED     = 8                       " Invalid separator
        FILESIZE_NOT_ALLOWED      = 9                       " Invalid file size
        HEADER_TOO_LONG           = 10                      " Header information currently restricted to 1023 bytes
        DP_ERROR_CREATE           = 11                      " Cannot create DataProvider
        DP_ERROR_SEND             = 12                      " Error Sending Data with DataProvider
        DP_ERROR_WRITE            = 13                      " Error Writing Data with DataProvider
        UNKNOWN_DP_ERROR          = 14                      " Error when calling data provider
        ACCESS_DENIED             = 15                      " Access to file denied.
        DP_OUT_OF_MEMORY          = 16                      " Not enough memory in data provider
        DISK_FULL                 = 17                      " Storage medium is full.
        DP_TIMEOUT                = 18                      " Data provider timeout
        FILE_NOT_FOUND            = 19                      " Could not find file
        DATAPROVIDER_EXCEPTION    = 20                      " General Exception Error in DataProvider
        CONTROL_FLUSH_ERROR       = 21                      " Error in Control Framework
        NOT_SUPPORTED_BY_GUI      = 22                      " GUI does not support this
        ERROR_NO_GUI              = 23                      " GUI not available
        OTHERS                    = 24
    ).

    "If file download not successful display error.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.




*  DATA : LO_EXCEL TYPE REF TO ZGTPP_CL_EXCEL_SERVICE.
*  DATA : LT_FCAT_LVC TYPE LVC_T_FCAT.
*  DATA : LO_TABLE TYPE REF TO DATA.
*  DATA : LV_NUM(2) TYPE N.
*  DATA : LV_FIELDNAME(30).
*  DATA : LV_FILENAME TYPE STRING.
*  DATA : LT_SEQ_ROUTING_HEADER LIKE TABLE OF GS_SEQ_ROUTING_HEADER.
*  FIELD-SYMBOLS : <LT_DATA> TYPE TABLE.
*  FIELD-SYMBOLS : <LV_VALUE> TYPE ANY.
*
*  LV_FILENAME = '조장구성표(' && GV_GRPNR && ')_' && SY-DATUM.
*
*  LT_SEQ_ROUTING_HEADER = GT_SEQ_ROUTING_HEADER.
*  SORT LT_SEQ_ROUTING_HEADER BY SEQNO.
*
*  LOOP AT GT_FIELDCAT_0201 INTO DATA(LS_FCAT).
*    IF LS_FCAT-FIELDNAME = 'DISP_SEQNO'.
*      LS_FCAT-DATATYPE = 'CAHR'.
*      APPEND LS_FCAT TO LT_FCAT_LVC.
*
*    ENDIF.
*
*    LOOP AT LT_SEQ_ROUTING_HEADER INTO DATA(LS_TEMP).
*      CLEAR LV_NUM.
*      LV_NUM = LS_TEMP-SEQNO + 0.
*      CLEAR LV_FIELDNAME.
*      LV_FIELDNAME = LV_NUM && '_' && LS_TEMP-CHART.
*      IF LS_FCAT-FIELDNAME = LV_FIELDNAME.
*        APPEND LS_FCAT TO LT_FCAT_LVC.
*      ENDIF.
*    ENDLOOP.
*
*    IF LS_FCAT-FIELDNAME = 'ORDNO_C'.
*      APPEND LS_FCAT TO LT_FCAT_LVC.
*    ENDIF.
*
*  ENDLOOP.
*
*  CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE(
*    EXPORTING
**      I_STYLE_TABLE       = ABAP_TRUE
*      IT_FIELDCATALOG           = LT_FCAT_LVC                " Field Catalog
*    IMPORTING
*      EP_TABLE                  = LO_TABLE                 " Pointer to Dynamic Data Table
*    EXCEPTIONS
*      GENERATE_SUBPOOL_DIR_FULL = 1                " At Most 36 Subroutine Pools Can Be Generated Temporarily
*      OTHERS                    = 2
*  ).
*  IF SY-SUBRC <> 0.
*  ENDIF.
*
*  ASSIGN LO_TABLE->* TO <LT_DATA>.
*
*  MOVE-CORRESPONDING <GT_MAIN_201> TO <LT_DATA>.
*
*  LOOP AT <LT_DATA> ASSIGNING FIELD-SYMBOL(<LS_DATA>).
*    IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
*    ASSIGN COMPONENT 'DISP_SEQNO' OF STRUCTURE <LS_DATA> TO <LV_VALUE>.
*    IF <LV_VALUE> IS ASSIGNED AND <LV_VALUE> = '000000'.
*      CLEAR <LV_VALUE>.
*    ENDIF.
*  ENDLOOP.
*
*  TRY.
*      LO_EXCEL ?= ZGTPP_CL_EXCEL_SERVICE=>GET_INSTANCE(
*        EXPORTING
*          IV_MODE    = 'D' ).
*
*      CHECK LO_EXCEL IS BOUND.
*
*      LO_EXCEL->DOWNLOAD_SPREADSHEET(
*        IT_DATA       = <LT_DATA>
*        IT_FCAT       = LT_FCAT_LVC                 " 리스트뷰어 제어에 대한 필드 카타로그
**        IV_TOP        = 1
*      ).
*    CATCH CX_BCS INTO DATA(LO_ERR). " BCS: General Exceptions
*  ENDTRY.
*
*  LO_EXCEL->DESTROY_DOCUMENT( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_SUL_NO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISP_SUL_NO .

  DATA : LT_CELLS TYPE LVC_T_CENO.

  GO_GRID_0200->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  DELETE LT_CELLS WHERE ROW_ID = 0.
  SORT LT_CELLS BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CELLS COMPARING ROW_ID.
  IF LINES( LT_CELLS ) = 1.
    READ TABLE LT_CELLS INTO DATA(LS_CELLS) INDEX 1.
    READ TABLE GT_MAIN_200 INTO DATA(LS_MAIN) INDEX LS_CELLS-ROW_ID.
  ELSE.
    READ TABLE GT_MAIN_200 INTO LS_MAIN INDEX 1.
  ENDIF.

  SELECT *
    INTO TABLE @DATA(LT_ZEDT100)
    FROM ZEDT1000
   WHERE WERKS = @P_WERKS
      AND NEW_MATNR = @LS_MAIN-MATNR.

  IF SY-SUBRC EQ 0.
    SORT LT_ZEDT100 BY SUL_NO DESCENDING
                               REV_SEQ DESCENDING.

    READ TABLE LT_ZEDT100 INTO DATA(LS_ZEDT100) INDEX 1.

    SET PARAMETER ID 'ZED_SUL_NO'   FIELD LS_ZEDT100-SUL_NO.
    SET PARAMETER ID 'ZED_REV_SEQ' FIELD LS_ZEDT100-REV_SEQ.

    CALL TRANSACTION 'ZED1M2030'
                       AND SKIP FIRST SCREEN.

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
      HEIGHT            =    5 ).             " Height

  GO_SPLITTER->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    2              " Row ID
      HEIGHT            =    25 ).             " Height

* top 컨테이너(Title)
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_TOP_0200.
* top 컨테이너(Grid)
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0200.
* bottom 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 3
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0201.


  CREATE OBJECT GO_GRID_0200
    EXPORTING
      I_PARENT      = GO_CONTAIN_0200
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
  GS_LAYOUT_0200-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0200-SEL_MODE   = 'C'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0200 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2140TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_200'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0200.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0200[]
    TABLES
      IT_DATA         = GT_MAIN_200
    EXCEPTIONS
      OTHERS          = 1.

  APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
  <LS_FCAT>-FIELDNAME = 'ORDNO_C'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'(f17).
  <LS_FCAT>-COL_POS = 4.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '30'.
  <LS_FCAT>-JUST = 'C'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'PACK_YN'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '포장재지정'(f18).
  <LS_FCAT>-COL_POS = 50.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.
  <LS_FCAT>-JUST = 'C'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'INSPE_YN'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입회검사'(f60).
  <LS_FCAT>-COL_POS = 60.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.
  <LS_FCAT>-JUST = 'C'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'PACK_TYPE'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '포장재유형'(f52).
  <LS_FCAT>-COL_POS = 70.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.
  <LS_FCAT>-JUST = 'C'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'PACK_NO'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '포장재코드'(f19).
  <LS_FCAT>-COL_POS = 80.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '30'.
  <LS_FCAT>-JUST = 'C'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'PACK_DM'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '포장재(드럼)'(f53).
  <LS_FCAT>-COL_POS = 90.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.
  <LS_FCAT>-JUST = 'C'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'PACK_PA'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '포장재(PALLET)'(f55).
  <LS_FCAT>-COL_POS = 100.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.
  <LS_FCAT>-JUST = 'C'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'PACK_SK'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '포장재(SKID)'(f56).
  <LS_FCAT>-COL_POS = 110.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.
  <LS_FCAT>-JUST = 'C'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'PACK_PW'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '포장재(포장목)'(f57).
  <LS_FCAT>-COL_POS = 120.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.
  <LS_FCAT>-JUST = 'C'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'PACK_FACTOR'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '포장목 개수'(f58).
  <LS_FCAT>-COL_POS = 130.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.
  <LS_FCAT>-JUST = 'C'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'INSPE_QLENGTH'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입회검사여장'(f61).
  <LS_FCAT>-COL_POS = 140.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.
  <LS_FCAT>-JUST = 'R'.

  APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
  <LS_FCAT>-FIELDNAME = 'INSPE_SPENGTH'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '특별검사여장'(f62).
  <LS_FCAT>-COL_POS = 150.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '20'.
  <LS_FCAT>-JUST = 'R'.

  LOOP AT GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'GRPNR'.
        <LS_FCAT>-NO_OUT = 'X'.
      WHEN 'ERDAT'.
        <LS_FCAT>-NO_OUT = 'X'.
      WHEN 'GCATG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '범주'(f20).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품'(f21).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ORDNO'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'POSNR'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'LINNO'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품내역'(f22).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'KUNNR'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품처'(f23).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'EDATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품요청일'(f24).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'WMENG'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'WMENG2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '총수량'(f25).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장'(f26).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(f27).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(f28).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = '0'.
      WHEN 'SNOTE'.
        CLEAR <LS_FCAT>-KEY.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '특기사항(헤더)'(f50).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'SNOTE2'.
        CLEAR <LS_FCAT>-KEY.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '특기사항(품목)'(f51).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'MAKTX_DM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '포장재(드럼) 내역'(m10).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-COL_POS = 91.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0200 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0200
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
      IS_LAYOUT            = GS_LAYOUT_0200
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0200
    CHANGING
      IT_OUTTAB            = GT_MAIN_200
*     IT_SORT              = GT_SORT_0200
      IT_FIELDCATALOG      = GT_FIELDCAT_0200.

  IF GO_DD_DOCU_0200 IS BOUND.
    CALL METHOD GO_DD_DOCU_0200->INITIALIZE_DOCUMENT.
  ELSE.
    CREATE OBJECT GO_DD_DOCU_0200
      EXPORTING
        STYLE = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD GO_GRID_0200->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DD_DOCU_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0201 .

  CREATE OBJECT GO_GRID_0201
    EXPORTING
      I_PARENT      = GO_CONTAIN_0201
      I_APPL_EVENTS = ABAP_TRUE.

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
  GS_LAYOUT_0201-SEL_MODE = 'D'.
  GS_LAYOUT_0201-STYLEFNAME = 'XYZSTYLEZYX'.
*  GS_LAYOUT_0200-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0201-SMALLTITLE = 'X'.
  GS_LAYOUT_0201-GRID_TITLE = '조장구성표'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0201 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0201
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0201 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_INDEX TYPE I.

  DATA : LV_FNAME01 TYPE FIELDNAME. " 공정필드네임
  DATA : LV_FNAME02 TYPE FIELDNAME. " 공정체크필드명
  DATA : LV_FNAME03 TYPE FIELDNAME. " 공정내 오더 순번

  DATA : LV_CHART_NAME TYPE FIELDNAME. " 공정명

  CONSTANTS : LC_STYLE01 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_INT_HEADING, " 계획오더(파랑)
              LC_STYLE02 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_INT_POSITIVE, "생산오더(초록)
              LC_STYLE03 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_POSITIVE, "판매오더(연초록)
              LC_STYLE04 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_INT_GROUP, "재고(주황)
              LC_STYLE05 TYPE LVC_STYLE VALUE CL_GUI_ALV_GRID=>MC_STYLE_ENABLED, "열 수정가능
              LC_STYLE06 TYPE LVC_STYLE VALUE ALV_STYLE_FONT_ITALIC, "이탤릭체
              LC_STYLE07 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_INV_GROUP. "생산완료 자재출고

  FIELD-SYMBOLS <LV_FIELD> TYPE ANY.
  FIELD-SYMBOLS <LV_CHECK> TYPE ANY.
  FIELD-SYMBOLS <LV_LINE_SEQ> TYPE ANY.
  FIELD-SYMBOLS <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

* Macro
  DEFINE __SET_CELL_ATTRIBUTE.
    CLEAR ls_celltab.
    ls_celltab-fieldname = &1.
    ls_celltab-style = &2.
    INSERT ls_celltab INTO TABLE lt_celltab.
  END-OF-DEFINITION.

  DEFINE __SET_FIELD_NAME.
    CLEAR : lv_fname01, lv_fname02, lv_fname03.
    lv_fname01 = &1 && '_' && gs_gong_2010-chart.
    lv_fname02 = lv_fname01 && '_CHK'.
    lv_fname03 = &1 && '_SEQNO'.
  END-OF-DEFINITION.

  DEFINE __ASSIGN_FIELD.
    IF <lv_check> IS ASSIGNED. UNASSIGN <lv_check>. ENDIF.
    ASSIGN COMPONENT lv_fname02 OF STRUCTURE <ls_main> TO <lv_check>.
    IF <lv_line_seq> IS ASSIGNED. UNASSIGN <lv_line_seq>. ENDIF.
    ASSIGN COMPONENT lv_fname03 OF STRUCTURE <ls_main> TO <lv_line_seq>.
  END-OF-DEFINITION.

  LOOP AT <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

    CLEAR LS_CELLTAB.
    REFRESH LT_CELLTAB.
    __SET_CELL_ATTRIBUTE 'ORDNO_C' LC_STYLE03.

    IF <LV_LINE_SEQ> IS ASSIGNED. UNASSIGN <LV_LINE_SEQ>. ENDIF.
    ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN> TO <LV_LINE_SEQ>.
    IF <LV_LINE_SEQ> IS ASSIGNED.
      CLEAR LV_INDEX.
      LV_INDEX = <LV_LINE_SEQ> + 0.
      READ TABLE GT_MAKE_DISPLAY INTO GS_MAKE_DISPLAY WITH KEY END_SEQNO = LV_INDEX.
      IF SY-SUBRC NE 0.
        CONTINUE.
      ENDIF.
    ENDIF.

    LOOP AT GS_MAKE_DISPLAY-T_GONG INTO GS_GONG_2010.
      LV_NUM = GS_GONG_2010-SEQNO + 0.

      __SET_FIELD_NAME LV_NUM.

*    각 첫번째열 체크필드 오픈
      IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
      ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN> TO <LV_LINE>.
      IF <LV_LINE> IS ASSIGNED.
        IF <LV_LINE> = 1.
          __SET_CELL_ATTRIBUTE LV_FNAME02 LC_STYLE05.
        ENDIF.
      ENDIF.

      __ASSIGN_FIELD.

      READ TABLE GS_GONG_2010-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_LINE_SEQ>.
      IF SY-SUBRC EQ 0.
        IF LS_CHAIN-ORDNR IS NOT INITIAL AND LS_CHAIN-CHK_DUP IS INITIAL.
          READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = LS_CHAIN-ORDNR
                                                                            POSNR = LS_CHAIN-POSNR.

          IF SY-SUBRC EQ 0.
            CASE LS_2010-ORDTY.
              WHEN 'SO'.

              WHEN 'PLN'.
                __SET_CELL_ATTRIBUTE LV_FNAME01 LC_STYLE01.
              WHEN 'PRD'.
                IF LS_2010-CHECK_JEGO IS NOT INITIAL AND LS_2010-CHECK_ZERO = ABAP_TRUE. " 생산완료, 자재 출고
                  CLEAR LS_CELLTAB.
                  LS_CELLTAB-FIELDNAME = LV_FNAME01.
                  LS_CELLTAB-STYLE = LC_STYLE07 + LC_STYLE06.
                  INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
                ELSEIF  LS_2010-CHECK_JEGO IS NOT INITIAL AND LS_2010-CHECK_ZERO = ABAP_FALSE. "생산완료,재고상태
                  IF LS_2010-CHECK_JEGO = 'Q'.
                    __SET_CELL_ATTRIBUTE LV_FNAME01 ALV_STYLE_COLOR_POSITIVE.
                  ELSE.
                    __SET_CELL_ATTRIBUTE LV_FNAME01 LC_STYLE04.
                  ENDIF.
                ELSE.
                  __SET_CELL_ATTRIBUTE LV_FNAME01 LC_STYLE02.
                ENDIF.
              WHEN 'PO' OR 'PR' OR 'UPR'. "차후적용
                IF LS_2010-CHECK_JEGO IS NOT INITIAL.
                  CLEAR LS_CELLTAB.
                  LS_CELLTAB-FIELDNAME = LV_FNAME01.
                  LS_CELLTAB-STYLE = LC_STYLE07 + LC_STYLE06.
                  INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
                ELSE.
                  __SET_CELL_ATTRIBUTE LV_FNAME01 LC_STYLE04.
                ENDIF.
*              WHEN 'PR'.  " 차후적용

            ENDCASE.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.

    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'XYZSTYLEZYX' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0201 .

  REFRESH GT_SORT_0201.

  IF GV_MAIN_SORT = 'D'.
    PERFORM SET_SORT_TAB TABLES GT_SORT_0201
                              USING : 1 'SEQNO' '' 'X' '',
                                         2 'LINE_SEQ'  'X' '' '',
                                         3 'LINE'  'X' '' ''.
  ELSE.
    PERFORM SET_SORT_TAB TABLES GT_SORT_0201
                              USING : 1 'SEQNO' 'X' '' '',
                                         2 'LINE_SEQ'  'X' '' '',
                                         3 'LINE'  'X' '' ''.
  ENDIF.


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
      IS_LAYOUT            = GS_LAYOUT_0201
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0201
    CHANGING
      IT_OUTTAB            = <GT_MAIN_201>
      IT_SORT              = GT_SORT_0201
      IT_FIELDCATALOG      = GT_FIELDCAT_0201.

  GO_GRID_0201->SET_READY_FOR_INPUT( 1 ).

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0201->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0201->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

*  IF GV_DISP_200 = ABAP_TRUE.
*    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
*      EXPORTING
*        FUNCTIONCODE           = 'SETMESSAGE'              " Function code
*      EXCEPTIONS
*        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
*        OTHERS                 = 2.
*    IF SY-SUBRC <> 0.
*    ENDIF.

*  ENDIF.

  IF GV_CHK_EXIST_BWD = ABAP_TRUE.

    IF GT_GUIDE_TEXT[] IS NOT INITIAL.
      APPEND INITIAL LINE TO GT_GUIDE_TEXT ASSIGNING FIELD-SYMBOL(<LV_GUIDE_TEXT>).
      UNASSIGN <LV_GUIDE_TEXT>.
      APPEND INITIAL LINE TO GT_GUIDE_TEXT ASSIGNING <LV_GUIDE_TEXT>.
      <LV_GUIDE_TEXT> = '신선재 작업 지시되어 있습니다. 조장변경시 유의하세요.'.
    ELSE.
      CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
        EXPORTING
          FUNCTIONCODE           = 'SETMESSAGE3'              " Function code
        EXCEPTIONS
          FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
          OTHERS                 = 2.
      IF SY-SUBRC <> 0.
      ENDIF.
    ENDIF.

  ENDIF.

  IF GV_CHK_CONFIRM_6600_GO = ABAP_TRUE.
    IF GT_GUIDE_TEXT[] IS NOT INITIAL.
      APPEND INITIAL LINE TO GT_GUIDE_TEXT ASSIGNING <LV_GUIDE_TEXT>.
      UNASSIGN <LV_GUIDE_TEXT>.
      APPEND INITIAL LINE TO GT_GUIDE_TEXT ASSIGNING <LV_GUIDE_TEXT>.
      <LV_GUIDE_TEXT> = '조장 구성으로 반제품 생산 계획이 수립되어 있습니다. 반제품 생산 계획을 확인하세요.'.

    ELSE.
      CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
        EXPORTING
          FUNCTIONCODE           = 'SETMESSAGE2'              " Function code
        EXCEPTIONS
          FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
          OTHERS                 = 2.
      IF SY-SUBRC <> 0.
      ENDIF.
    ENDIF.
  ENDIF.

  IF GT_GUIDE_TEXT[] IS NOT INITIAL.
    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'DISP_MESSAGE'              " Function code
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
        OTHERS                 = 2.
    IF SY-SUBRC <> 0.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESIZING_FIELDCAT_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RESIZING_FIELDCAT_GRID_0201 .

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
    WHEN GO_GRID_0200.
      PERFORM SET_TITLE_0200 CHANGING PV_DYNDOC_ID.
    WHEN GO_GRID_0300.
      PERFORM SET_TITLE_0300 CHANGING PV_DYNDOC_ID.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PV_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM SET_TITLE_0200  CHANGING PV_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  DATA : LV_TEXT(255) TYPE C.

* 프로젝트명
  CONCATENATE '조장구성표번호' GV_GRPNR INTO LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

  "위쪽에 추가한 텍스트 출력
  CALL METHOD GO_DD_DOCU_0200->DISPLAY_DOCUMENT
    EXPORTING
      PARENT = GO_CONTAIN_TOP_0200.

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
FORM DOUBLE_CLICK  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                            P_ROW TYPE LVC_S_ROW
                            P_COLUMN TYPE LVC_S_COL.

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_CHK_USEFIELD.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_FIELDNAME02 TYPE FIELDNAME.
  DATA : LV_SEQNO TYPE I.

  CHECK P_ROW-INDEX > 0.

  CASE P_SENDER.
    WHEN GO_GRID_0200.
      IF P_COLUMN-FIELDNAME = 'ORDNO_C'.
        READ TABLE GT_MAIN_200 INTO GS_MAIN_200 INDEX P_ROW-INDEX.
        CASE GS_MAIN_200-GCATG.
          WHEN '생산오더'.
            PERFORM DISP_POPUP_SMORDER USING GS_MAIN_200-ORDNO GS_MAIN_200-POSNR.
          WHEN OTHERS.
            SET PARAMETER ID 'AUN' FIELD GS_MAIN_200-ORDNO.
            CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
            SET PARAMETER ID 'AUN' FIELD ''.
        ENDCASE.
        RETURN.
      ENDIF.

      IF P_COLUMN-FIELDNAME = 'SNOTE'.
        READ TABLE GT_MAIN_200 INTO GS_MAIN_200 INDEX P_ROW-INDEX.
        PERFORM SET_AND_DISP_TEXT.
      ENDIF.

      IF P_COLUMN-FIELDNAME = 'SNOTE2'.
        READ TABLE GT_MAIN_200 INTO GS_MAIN_200 INDEX P_ROW-INDEX.
        PERFORM SET_AND_DISP_TEXT2.
      ENDIF.

    WHEN GO_GRID_0201.

      READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX P_ROW-INDEX.
      ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO FIELD-SYMBOL(<LV_SEQNO>).

      READ TABLE GT_MAIN_200 INTO GS_MAIN_200 INDEX <LV_SEQNO>.

      IF P_COLUMN-FIELDNAME = 'ORDNO_C'.
        CASE GS_MAIN_200-GCATG.
          WHEN '생산오더'.
            PERFORM DISP_POPUP_SMORDER USING GS_MAIN_200-ORDNO GS_MAIN_200-POSNR.
          WHEN OTHERS.
            SET PARAMETER ID 'AUN' FIELD GS_MAIN_200-ORDNO.
            CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
            SET PARAMETER ID 'AUN' FIELD ''.
        ENDCASE.
        RETURN.
      ENDIF.

      LOOP AT GT_SEQ_ROUTING_HEADER INTO DATA(LS_TEMP).
        CLEAR LV_NUM.
        CLEAR LV_FIELDNAME.
        LV_NUM =  LS_TEMP-SEQNO + 0.
        LV_FIELDNAME = LV_NUM && '_' && LS_TEMP-CHART.
        IF LV_FIELDNAME = P_COLUMN-FIELDNAME.
          LV_CHK_USEFIELD = ABAP_TRUE.
          LV_FIELDNAME02 = LV_NUM && '_SEQNO'.
          LV_SEQNO = LS_TEMP-SEQNO.
          EXIT.
        ENDIF.

      ENDLOOP.

      CHECK LV_CHK_USEFIELD = ABAP_TRUE.

      ASSIGN COMPONENT LV_FIELDNAME02 OF STRUCTURE <LS_MAIN_201> TO FIELD-SYMBOL(<LV_GONGSEQ>).
      IF <LV_GONGSEQ> IS NOT ASSIGNED.
        RETURN.
      ELSE.
        IF <LV_GONGSEQ> = 0.
          RETURN.
        ENDIF.
      ENDIF.


      ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO FIELD-SYMBOL(<LV_LINE>).


      READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
      READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
      READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.
      IF LS_CHAIN-ORDNR IS INITIAL.
        RETURN.
      ENDIF.
      READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = LS_CHAIN-ORDNR
                                                                                     POSNR = LS_CHAIN-POSNR
                                                                                     ORDTY = LS_CHAIN-ORDTY.
      IF SY-SUBRC NE 0.
        RETURN.
      ENDIF.

      IF <LV_LINE> = 1. " 첫번째 열은 오더정보
        CASE LS_2010-ORDTY.
          WHEN 'PLN'.
            SET PARAMETER ID 'PAF' FIELD LS_2010-ORDNR.
            CALL TRANSACTION 'MD13' AND SKIP FIRST SCREEN.

          WHEN 'PRD'.
            SET PARAMETER ID 'ANR' FIELD LS_2010-ORDNR.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
          WHEN 'PO'.
            SET PARAMETER ID 'BES' FIELD LS_2010-ORDNR.
            CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
          WHEN 'PR' OR 'UPR'.
            SET PARAMETER ID 'BAN' FIELD LS_2010-ORDNR.
            CALL TRANSACTION 'ME53N'.
            SET PARAMETER ID 'BAN' FIELD ''.
        ENDCASE.
        EXIT.
      ELSE. " 두번째 열은 자재정보
        SET PARAMETER ID 'WRK' FIELD P_WERKS.
        SET PARAMETER ID 'BERID' FIELD P_WERKS.
        IF LS_2010-REAL_MATNR IS NOT INITIAL.
          SET PARAMETER ID 'MAT' FIELD LS_2010-REAL_MATNR.
        ELSE.
          SET PARAMETER ID 'MAT' FIELD LS_2010-MATNR.
        ENDIF.
        IF LS_2010-CHECK_JEGO IS INITIAL.
          CALL TRANSACTION 'MD04' AND SKIP FIRST SCREEN.
        ELSE.
          CALL TRANSACTION 'MMBE' AND SKIP FIRST SCREEN.
        ENDIF.

      ENDIF.

    WHEN GO_GRID_0220.
      READ TABLE GT_DEL_DISP INTO GS_DEL_DISP INDEX P_ROW-INDEX.
      CASE GS_DEL_DISP-ORDTY.
        WHEN 'PLN'.
          SET PARAMETER ID 'PAF' FIELD GS_DEL_DISP-ORDNR.
          CALL TRANSACTION 'MD13' AND SKIP FIRST SCREEN.
        WHEN 'PRD'.
          SET PARAMETER ID 'ANR' FIELD GS_DEL_DISP-ORDNR.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
      ENDCASE.

  ENDCASE.

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
    WHEN GO_GRID_0201.
      IF GV_CHK_CONFIRM_6600_GO EQ ABAP_TRUE.

* 드럼 재지정 추가.
        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                 USING : 'REPLACE_DRUM' ICON_MASS_CHANGE_DONE '드럼 재지정' '드럼 재지정' 0.

      ELSE.


*      IF GT_ITEM_DISP[] IS INITIAL.
        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                             USING : 'ALLSEL' ICON_SELECT_ALL '전체선택' '전체선택' 0,
                                        'DESEL' ICON_DESELECT_ALL '선택해제' '선택해제' 0,
                                         '' '' '' '' 3,
*                                      'DELE_GROUP' ICON_DELETE '삭제' '오더' 2,
                                        'DELE' ICON_DELETE '오더삭제' '오더삭제' 0,
                                        '' '' '' '' 3,    " " 재생산 오더 전환은 추후 재이관 예정
                                        'CHG_GROUP' ICON_SET_STATE '전환' '오더' 2 ,
*                                      'CHG_PRD' ICON_SET_STATE '오더전환' '오더전환' 0 ,
*                                      'CHG_PRD2' ICON_SET_STATE '재생산오더전환' '재생산오더전환' 0 ,  " 재생산 오더 전환은 추후 재이관 예정
                                        '' '' '' '' 3,
*                                      'RELEASE' ICON_RELEASE '생산오더릴리즈' '생산오더릴리즈' 0 ,
*                                      '' '' '' '' 3,
                                        'SET_NUM_GROUP' ICON_UNLINK '여장' '여장' 2 ,
*                                       'SET_NUM' ICON_SYSTEM_CUT '표준여장편집' '표준여장편집' 0 ,
*                                       'EDIT_NUM' ICON_UNLINK '여장편집' '여장편집' 0 ,
*                                      'CHG_BATCH' ICON_TOOLS '설비변경' '설비변경' 0 ,
                                        '' '' '' '' 3,
                                        'SET_TANDEM_GROUP' ICON_TOOLS '탄뎀지정' '탄뎀지정' 2 ,
                                        '' '' '' '' 3,
                                        'PEGGING_GROUP' ICON_PS_RELATIONSHIP 'Pegging' 'Pegging' 2 ,
*                                      'CHG_PEGGING' ICON_PS_RELATIONSHIP 'Pegging변경' 'Pegging변경' 0 ,
*                                      'UNPEGGING' ICON_WF_UNLINK '재고 Pegging삭제' '재고 Pegging삭제' 0 ,
*                                      'UNPEGGING_FORCE' ICON_ERASE 'Pegging 강제삭제' 'Pegging 강제삭제' 0 ,
                                         '' '' '' '' 3.
*      IF GV_DISP_200 IS INITIAL.
        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                 USING : 'MULTY_GROUP' ICON_INTERVAL_INCLUDE_GREEN '복조장' '복조장' 2 ,
*                                      'SET_MULTY' ICON_INTERVAL_INCLUDE_GREEN '복조장구성' '복조장구성' 0 ,
*                                      'SEPERATE' ICON_INTERVAL_EXCLUDE '개별오더전환' '개별오더전환' 0 ,
                                            '' '' '' '' 3,
                                        'MASTER_GROUP' ICON_FAST_ENTRY '주문변경' '주문변경' 2,
                                            '' '' '' '' 3.
*      ENDIF.

* 드럼 재지정 추가.
        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                 USING : 'REPLACE_DRUM' ICON_MASS_CHANGE_DONE '드럼 재지정' '드럼 재지정' 0,
                                            '' '' '' '' 3.

        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                   USING :
*                                      'LC_EXISTS' ICON_SYSTEM_MODUS_DELETE 'LC 공정제외' 'LC 공정제외' 0 ,
                                              'SORT_UP' ICON_SORT_UP '' '조장정렬' 0 ,
                                              'SORT_DN' ICON_SORT_DOWN '' '조장정렬' 0 .

        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                 USING : '' '' '' '' 3,
                                            'SET_CUT' ICON_SYSTEM_LOCAL_CUT '특별사유절단' '특별사유절단' 0.

*      IF LINES( GT_MAIN_200 ) > 1.
*        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
*                                   USING : '' '' '' '' 3,
*                                              'SORT_UP_JOJANG' ICON_SORT_UP '조장크기' '조장정렬' 0 ,
*                                              'SORT_DN_JOJANG' ICON_SORT_DOWN '조장크기' '조장정렬' 0 .
*      ENDIF.

      ENDIF.
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
    WHEN GO_GRID_0201.
      CASE PV_UCOMM.
        WHEN 'DELE'. " 오더삭제
          PERFORM DELETE_ORDER.
        WHEN 'DELE2'." 임가공 오더 삭제
          PERFORM CONV_PURCHASE_ORDER_TO_ORIGN..
        WHEN 'CHG_PRD' OR 'CHG_PRD2'.  " 오더전환
          PERFORM CONVERSION_PROD_ORDER USING PV_UCOMM.

        WHEN 'CHG_PO'. " 임가공 전환
          PERFORM CONVERSION_PURCHASE_ORDER.

        WHEN 'CHG_PR'. " 구매요청 전환
          PERFORM CONVERSION_PURCHASE_REQUEST.

        WHEN 'EDIT_NUM'.  " 여장편집
          PERFORM EDIT_ADLENGTH.

        WHEN 'RELEASE'.   " 생산오더 릴리즈
          PERFORM RELEASE_PRD_ORDER.

        WHEN 'CHG_BATCH'.  " 설비변경
          PERFORM CHANGE_BATCH.

        WHEN 'CHG_PEGGING'. " Pegging변경
          PERFORM PROCESS_PEGGING.

        WHEN 'UNPEGGING'. "재고 Pegging삭제
          PERFORM PROCESS_UNPEGGING.

        WHEN 'SET_MULTY'. " 복조장 구성
          PERFORM SET_MULTY_POSNR.

        WHEN 'SEPERATE'. " 개별생산오더전환
          PERFORM PROCESS_SEPERATE.

        WHEN 'SEPERATE_PR'. " 개별PR전환
          PERFORM PROCESS_SEPERATE_PR.

        WHEN 'ALLSEL'.
          PERFORM PROCESS_ALLSELECT.

        WHEN 'DESEL'.
          PERFORM PROCESS_DESELECT.

        WHEN 'SET_NUM'.
          PERFORM SET_STANDARD_ADLENGTH.

        WHEN 'LC_EXISTS'.
*          PERFORM EXCLUDE_BOM_COMPONENTS.

        WHEN 'SUL_NO'.
*          PERFORM DISP_SUL_NO.

        WHEN 'CHG_MASTER'.
          PERFORM PROCESS_MASTER_ORDER_CHG.

        WHEN 'UNPEGGING_FORCE'.
          PERFORM PROCESS_UNPEGGING_FORCE.

        WHEN 'SORT_UP'.
          PERFORM PROCESS_SORT_LENG USING 'U'.

        WHEN 'SORT_DN'.
          PERFORM PROCESS_SORT_LENG USING 'D'.

        WHEN 'SET_TANDEM'. " 탄뎀설정
          PERFORM PROCESS_SET_TANDEM.

        WHEN 'DEL_TANDEM'. "탄뎀취소
          PERFORM PROCESS_DEL_TANDEM..

        WHEN 'REPLACE_DRUM'. "드럼재지정
          PERFORM PROCESS_REPLACE_DRUM.

        WHEN 'SORT_UP_JOJANG'.
          PERFORM PROCESS_SORT_JOJANG USING 'U'.

        WHEN 'SORT_DN_JOJANG'.
          PERFORM PROCESS_SORT_JOJANG USING 'D'.
        WHEN 'SET_CUT'. " 특별절단 작업지시
          PERFORM PROCESS_SET_CUT.
        WHEN 'SET_MERGE'.
          PERFORM PROCESS_SET_MERGE.
        WHEN 'DEL_MASTER'. "주문삭제
          PERFORM PROCESS_MASTER_ORDER_DEL.
      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_SORT_LENG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM PROCESS_SORT_LENG  USING  PV_GUBUN.

  CLEAR GV_MAIN_SORT.
  CLEAR GV_JOJANG_SORT.

  IF PV_GUBUN = 'D'.
    GV_MAIN_SORT = 'D'.
  ENDIF.
  PERFORM REFRESH_SCREEN_201.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ALLSELECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_ALLSELECT .

  DATA : LT_COL_TABLE TYPE LVC_T_COL.
  DATA : LV_NUM(2) TYPE N.
  DATA : LT_CELL TYPE LVC_T_CELL.
  DATA : LV_COL_ID TYPE I.
  DATA : LS_ROW_ID TYPE LVC_S_ROW.
  DATA : LS_COLUMN_ID TYPE LVC_S_COL.

  LV_COL_ID = LINES( GT_FIELDCAT_0201 ) .
  LV_COL_ID = LV_COL_ID - 3.
  LS_ROW_ID-INDEX = 1.
  READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LV_COL_ID.
  LS_COLUMN_ID-FIELDNAME = LS_FCAT-FIELDNAME.

  GO_GRID_0201->SET_CURRENT_CELL_VIA_ID(
    IS_ROW_ID    =   LS_ROW_ID               " Row
    IS_COLUMN_ID =  LS_COLUMN_ID ).                " Column

  LOOP AT GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING).

    APPEND INITIAL LINE TO LT_COL_TABLE ASSIGNING FIELD-SYMBOL(<LS_COL_TABLE>).
    LV_NUM = LS_ROUTING-SEQNO + 0.
    <LS_COL_TABLE>-FIELDNAME = LV_NUM && '_' && LS_ROUTING-CHART.

  ENDLOOP.

  GO_GRID_0201->SET_SELECTED_COLUMNS(
    IT_COL_TABLE             =  LT_COL_TABLE                " Selected Columns
  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DESELECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_DESELECT .

  DATA : LT_COL_TABLE TYPE LVC_T_COL.

  GO_GRID_0201->SET_SELECTED_COLUMNS(
    IT_COL_TABLE             =  LT_COL_TABLE                " Selected Columns
  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELETE_ORDER .

  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LV_CHK_ERR.
  DATA : LO_JOJANG TYPE REF TO ZGTPP_CL_ROUTING_GAON.
  DATA : LV_RESULT TYPE CHAR01.
  DATA : LS_MESSAGE TYPE BAPIRETURN1.

  PERFORM CHK_BEFORE_EDIT_DELETE_ORDER  TABLES LT_2010
                                                 CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF LT_2010[] IS INITIAL.
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

  CREATE OBJECT LO_JOJANG
    EXPORTING
      IV_WERKS              = P_WERKS                 " 플랜트
      IV_GRPNR              = GV_GRPNR                 " 조장 구성표 번호
      IT_MAIN               = GT_MAKE_DISPLAY
      IT_SEQ_ROUTING_HEADER = GT_SEQ_ROUTING_HEADER
      IT_SEQ_ROUTING_SUB    = GT_SEQ_ROUTING_SUB
      IT_MAKED_2010         = GT_2010.

  LO_JOJANG->DELETE_ORDER(
    EXPORTING
      IT_2010 = LT_2010
    IMPORTING
      EV_RETURN  = LV_RESULT                 " 길이 1의 문자 필드
      ES_MESSAGE = LS_MESSAGE                 " 문자 100
  ).

  IF LV_RESULT EQ 'E'.
    MESSAGE S003 WITH LS_MESSAGE-MESSAGE DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.


*  변경정보 MES전송
  ZGTPP_CL_ROUTING=>SEND_CHG_MES(
    IV_WERKS = P_WERKS           " 플랜트
    IV_SPGCD = P_SPGCD          " SPG 코드
    IV_GRPNR = GV_GRPNR ).    " 조장 구성표 번호


  PERFORM REFRESH_SCREEN_201.
  MESSAGE S003 WITH LS_MESSAGE-MESSAGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_BEFORE_EDIT_DELETE_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_BEFORE_EDIT_DELETE_ORDER  TABLES   PT_2010 LIKE GT_2010
                                              CHANGING PV_CHK_ERR.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_NUM(2) TYPE N.
  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_2010_CHK LIKE TABLE OF GS_2010.
  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.

  CLEAR : PV_CHK_ERR.
  REFRESH PT_2010[].

  GO_GRID_0201->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  GO_GRID_0201->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL AND LT_CELLS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'(e01).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
    READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 2.
    LV_CHART = LS_STRING.

    IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
      MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 컬럼이 선택되었습니다.'(e02).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
* 선택된 컬럼의 공정 유형 전부 추출
    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY CHART = LV_CHART
                                                                                        SEQNO = LV_SEQNO.

    LT_2010 = VALUE #( FOR WA_2010 IN GT_2010 WHERE ( GONG_CD = LV_CHART
                                                                      AND   GONG_SEQ = LS_ROUTING-GONG_SEQ
                                                                      AND    REF_TANDEM NE 'X' )
                                                   ( CORRESPONDING #( WA_2010 ) ) ).

    LOOP AT LT_2010 ASSIGNING FIELD-SYMBOL(<LS_TEMP>).
      IF ( <LS_TEMP>-ORDTY = 'PO' OR <LS_TEMP>-ORDTY = 'UPR' ) AND
         <LS_TEMP>-DMORD = <LS_TEMP>-ORDNR AND
         <LS_TEMP>-DMLINE = <LS_TEMP>-POSNR.
        DELETE LT_2010.
      ENDIF.
    ENDLOOP.

    APPEND LINES OF LT_2010 TO PT_2010.
  ENDLOOP.


  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.

      SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE LT_STRING.
      READ TABLE LT_STRING INTO LS_STRING INDEX 2.
      LV_CHART = LS_STRING.

      IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
        MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'(e02).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY CHART = LV_CHART
                                                                                          SEQNO = LV_SEQNO.

*  선택된 필드의 오더정보 찾기
    READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
      ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.
      IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
      ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO <LV_LINE>.

      CLEAR LV_NUM.
      CLEAR LV_FIELDNAME.
      LV_NUM =  LS_ROUTING-SEQNO + 0.
      LV_FIELDNAME = LV_NUM && '_SEQNO'.

      IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.
      IF <LV_GONGSEQ> IS NOT ASSIGNED. " 공정을 못찾으면 종료
        RETURN.
      ELSE.
        IF <LV_GONGSEQ> = 0. " 해당 공정 순번이 비어있다면 오더가 없다는 의미 다음순번
          CONTINUE.
        ENDIF.
      ENDIF.

      READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
      READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
      READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.

* 중복 필드라면 대상이 아님
      IF LS_CHAIN-CHK_DUP EQ ABAP_TRUE.
        CONTINUE.
      ENDIF.

      IF LS_CHAIN-ORDNR IS INITIAL.
        CONTINUE.
      ENDIF.
      READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY GONG_SEQ = LS_GONG-GONG_SEQ
                                                                      ORDNR = LS_CHAIN-ORDNR
                                                                      POSNR = LS_CHAIN-POSNR
                                                                      ORDTY = LS_CHAIN-ORDTY.
      IF SY-SUBRC EQ 0 AND LS_2010-REF_TANDEM NE 'X'.
        APPEND LS_2010 TO PT_2010.
      ENDIF.
    ENDIF.
  ENDLOOP.

  REFRESH LT_2010.

  SORT PT_2010 BY GONG_CD ORDNR POSNR ORDTY.
  DELETE ADJACENT DUPLICATES FROM PT_2010 COMPARING GONG_CD ORDNR POSNR ORDTY.

* 선택된 오더가 생산오더(SM)의 경우는 삭제 불가 에러처리.
*  선택된 오더의 이후 공정확인하여 복조장 일시 복조장 해재후 진행가능
  LOOP AT PT_2010 INTO DATA(LS_2010_DM).
    IF LS_2010_DM-ORDNR = LS_2010_DM-DMORD AND
      LS_2010_DM-POSNR = LS_2010_DM-DMLINE AND
      LS_2010_DM-ORDTY = LS_2010_DM-DMORDTY AND
      LS_2010_DM-ORDTY = 'PRD'.

      MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더'(e04) LS_2010_DM-ORDNR '은(는) SM 오더로 조장구성에서 삭제 불가능합니다.'(e03).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.

    ENDIF.

    IF LS_2010_DM-ORDTY = 'PO'.

      IF LS_2010_DM-CHK_PRD = ABAP_TRUE.
        MESSAGE S006 DISPLAY LIKE 'E' WITH  '구매오더'(e43) LS_2010_DM-ORDNR '는 임가공 처리중인 오더입니다.'(e45).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.

*    해당 구매오더가 멀티오더일시 전체 품목 다 담아준다.
      LOOP AT GT_2010 INTO DATA(LS_CHK_CURRENT) WHERE GONG_SEQ = LS_2010_DM-GONG_SEQ
                                                                AND ORDNR = LS_2010_DM-ORDNR
                                                               AND POSNR NE LS_2010_DM-POSNR
                                                               AND ORDTY = LS_2010_DM-ORDTY.
        READ TABLE PT_2010 TRANSPORTING NO FIELDS WITH KEY GONG_SEQ = LS_CHK_CURRENT-GONG_SEQ
                                                                              ORDNR = LS_CHK_CURRENT-ORDNR
                                                                              POSNR = LS_CHK_CURRENT-POSNR
                                                                             ORDTY = LS_CHK_CURRENT-ORDTY.
        IF SY-SUBRC NE 0.
          APPEND LS_CHK_CURRENT TO PT_2010.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF LS_2010_DM-ORDTY = 'PR' OR LS_2010_DM-ORDTY = 'UPR'.
      IF LS_2010_DM-CHK_PRD = ABAP_TRUE.
        MESSAGE S006 DISPLAY LIKE 'E' WITH  '구매요청'(e60) LS_2010_DM-ORDNR '는 구매오더 발행된 오더입니다.'(e61).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.


    IF LS_2010_DM-DMORDTY = 'PRD'.
      READ TABLE GT_2010 INTO DATA(LS_DM_CHK_2010) WITH KEY ORDNR = LS_2010_DM-DMORD
                                                                               POSNR = LS_2010_DM-DMLINE
                                                                               ORDTY = LS_2010_DM-DMORDTY.
      IF SY-SUBRC EQ 0.
        IF LS_DM_CHK_2010-ORDNR = LS_DM_CHK_2010-DMORD AND
           LS_DM_CHK_2010-POSNR = LS_DM_CHK_2010-DMLINE AND
           LS_DM_CHK_2010-ORDTY = LS_DM_CHK_2010-DMORDTY.
          CONTINUE.
        ENDIF.

        SELECT AUFNR, POSNR FROM AFPO
        WHERE AUFNR = @LS_2010_DM-DMORD
          INTO TABLE @DATA(LT_DUP_AUFNR).
        SORT LT_DUP_AUFNR BY AUFNR POSNR.
        DELETE ADJACENT DUPLICATES FROM LT_DUP_AUFNR COMPARING AUFNR POSNR.
        IF LINES( LT_DUP_AUFNR ) > 1.
          MESSAGE S006 DISPLAY LIKE 'E' WITH  '이후공정'(e05) LS_2010_DM-DMORD '오더는 복조장입니다. 구성 해제 후 삭제 가능합니다.'(e06).
          PV_CHK_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.

    IF LS_2010_DM-ORDTY = 'PRD'.
* 해당 오더가 복조장 오더 - 자재가 틀린경우 차후 추가 예정
      LOOP AT GT_2010 INTO LS_CHK_CURRENT WHERE ORDNR = LS_2010_DM-ORDNR
                                                               AND POSNR NE LS_2010_DM-POSNR
                                                               AND ORDTY = LS_2010_DM-ORDTY.
        READ TABLE PT_2010 TRANSPORTING NO FIELDS WITH KEY ORDNR = LS_CHK_CURRENT-ORDNR
                                                                              POSNR = LS_CHK_CURRENT-POSNR
                                                                             ORDTY = LS_CHK_CURRENT-ORDTY.
        IF SY-SUBRC NE 0.
          APPEND LS_CHK_CURRENT TO PT_2010.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.


* 선택된 오더의 이전 공정 전부 추출후 정합성 체크
  DATA : LV_CHK_INDEX TYPE I.
  LOOP AT  PT_2010 INTO DATA(LS_2010_WQ).
    REFRESH LT_2010_CHK.
    APPEND LS_2010_WQ TO LT_2010_CHK.
* 해당 오더가 복조장 오더일시 복조장 메인 조회 - 차후 추가예정


    READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = LS_2010_WQ-GONG_SEQ.
    LV_SEQNO = LS_ROUTING-SEQNO.
    DO.
      LV_SEQNO = LV_SEQNO - 1.
      IF LV_SEQNO = 0.
        EXIT.
      ENDIF.
      READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY SEQNO = LV_SEQNO.

      LOOP AT GT_2010 INTO DATA(LS_2010_PRE) WHERE GONG_SEQ = LS_ROUTING-GONG_SEQ.
        READ TABLE LT_2010_CHK TRANSPORTING NO FIELDS WITH KEY ORDNR = LS_2010_PRE-DMORD
                                                                                    POSNR = LS_2010_PRE-DMLINE
                                                                                    ORDTY = LS_2010_PRE-DMORDTY.
        IF SY-SUBRC EQ 0.
          APPEND LS_2010_PRE TO LT_2010_CHK.
        ENDIF.
      ENDLOOP.
    ENDDO.

    IF LT_2010_CHK IS NOT INITIAL.
      APPEND LINES OF LT_2010_CHK TO LT_2010.
    ENDIF.

  ENDLOOP.

  SORT LT_2010 BY GONG_CD ORDNR ORDTY POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_2010 COMPARING GONG_CD ORDNR ORDTY POSNR.

* 생산 오더 상태 확인 "PAYO", "PCNF", "CNF"의 경우, 오류 메시지: 오더 + "오더는 생산 진행 중으로 삭제 할 수 없습니다."
* 이전 공정 오더 상태 확인(ZGTPPT2010-REORD), 이전 공정 오더가 생산 오더("PRD") 이면서 오더 상태 "PAYO", "PCNF", "CNF"의 경우
* 오류 메시지: "이전 공정" 오더 + "오더는 생산 진행 중으로 삭제 할 수 없습니다."
  LOOP AT LT_2010 INTO LS_2010_WQ.
    IF LS_2010_WQ-CHK_PRD = ABAP_TRUE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH  '공정'(e07) LS_2010_WQ-ORDNR '오더는 생산 진행 중으로 삭제 할 수 없습니다.'(e08).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_PROD_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_UCOMM
*&---------------------------------------------------------------------*
FORM CONVERSION_PROD_ORDER  USING    PV_UCOMM.

  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LV_CHK_ERR.
  DATA : LO_JOJANG TYPE REF TO ZGTPP_CL_ROUTING_GAON.
  DATA : LV_RESULT TYPE CHAR01.
  DATA : LS_MESSAGE TYPE BAPIRETURN1.
  DATA : LV_AUART TYPE AUFART.
  DATA : LV_TEXT TYPE CHAR100.

  PERFORM CHK_BEFORE_CONV CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  PERFORM CHK_LINE_FOR_CONVERSION TABLES LT_2010
                                                   CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  CASE PV_UCOMM.
    WHEN 'CHG_PRD2'.
      LV_AUART = 'RP01'.
      LV_TEXT = '선택된 계획오더를 재생산 오더로 전환하시겠습니까?'.
    WHEN 'CHG_PRD'.
      LV_AUART = 'PP01'.
      LV_TEXT = '선택된 계획오더를 생산 오더로 전환하시겠습니까?'.
  ENDCASE.


**  PERFORM CHECK_POJANG TABLES LT_2010 CHANGING LV_CHK_POJANG.
**
**  IF LV_CHK_POJANG IS INITIAL.
**
  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    LV_TEXT
    '작업확인'.
**  ELSE.
**    PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
**      ' '
**      '포장재가 확정되지 않았습니다. 진행하시겠습니까?'
**      '작업확인'.
**
**  ENDIF.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CREATE OBJECT LO_JOJANG
    EXPORTING
      IV_WERKS              = P_WERKS                 " 플랜트
      IV_GRPNR              = GV_GRPNR                 " 조장 구성표 번호
      IT_MAIN               = GT_MAKE_DISPLAY
      IT_SEQ_ROUTING_HEADER = GT_SEQ_ROUTING_HEADER
      IT_SEQ_ROUTING_SUB    = GT_SEQ_ROUTING_SUB
      IT_MAKED_2010         = GT_2010.

  LO_JOJANG->CONVERSION_PRD_ORDER(
    EXPORTING
      IT_2010    = LT_2010
      IV_AUART   = LV_AUART                 " 오더 유형
    IMPORTING
      EV_RETURN  = LV_RESULT                 " 길이 1의 문자 필드
      ES_MESSAGE = LS_MESSAGE                 " 리턴 매개변수
  ).

  IF LV_RESULT EQ 'E'.
    CLEAR LV_CHK_ERR.
    LOOP AT LO_JOJANG->MT_MESSTAB INTO DATA(LS_RESULT).
      APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING FIELD-SYMBOL(<LS_DEL_DISP>).
      <LS_DEL_DISP>-MESSAGE = LS_RESULT-MSGV1.
      <LS_DEL_DISP>-STATUS = ICON_LED_RED.

    ENDLOOP.

    GV_DISP_SET = 'A'.
    CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
    CLEAR GV_DISP_SET.
    RETURN.
  ENDIF.

  IF GV_CHK_EXIST_BWD = ABAP_TRUE AND LO_JOJANG->MT_MESSAGE_BWD[] IS NOT INITIAL.
    CALL FUNCTION 'ZGTPP_UTILL_TEXTEDIT'
      EXPORTING
        IV_MODE  = '1'
        IV_TITLE = '신선작업지시 초과수량'
      CHANGING
        CT_TEXT  = LO_JOJANG->MT_MESSAGE_BWD.
  ENDIF.

* 안내사항 관리 추가 장납품 관련 조장생성 프로세스 변경으로 전환시 체크 사항들이 존재함
  PERFORM SET_GUIDE_END_CONV CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'DISP_MESSAGE'              " Function code
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
        OTHERS                 = 2.
    IF SY-SUBRC <> 0.
    ENDIF.
  ENDIF.

*  변경정보 MES전송
  ZGTPP_CL_ROUTING=>SEND_CHG_MES(
    IV_WERKS = P_WERKS           " 플랜트
    IV_SPGCD = P_SPGCD          " SPG 코드
    IV_GRPNR = GV_GRPNR ).    " 조장 구성표 번호

  PERFORM REFRESH_SCREEN_201.
  MESSAGE S003 WITH LS_MESSAGE-MESSAGE.

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
*& Form CHK_LINE_FOR_CONVERSION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_LINE_FOR_CONVERSION  TABLES   PT_2010 LIKE GT_2010
                                              CHANGING PV_CHK_ERR.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_NUM(2) TYPE N.
  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LV_MESSAGE(100).
  DATA : LV_MATNR_C(40).

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.

  CLEAR : PV_CHK_ERR.
  REFRESH PT_2010[].

  GO_GRID_0201->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  GO_GRID_0201->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL AND LT_CELLS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'(e01).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
    READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 2.
    LV_CHART = LS_STRING.

    IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
      MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 컬럼이 선택되었습니다.'(e02).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
* 선택된 컬럼의 공정 유형 전부 추출
    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY CHART = LV_CHART
                                                                                        SEQNO = LV_SEQNO.

    LT_2010 = VALUE #( FOR WA_2010 IN GT_2010 WHERE ( GONG_CD = LV_CHART
                                                                       AND   GONG_SEQ = LS_ROUTING-GONG_SEQ
                                                                       AND    REF_TANDEM NE 'X'
                                                                       AND   ORDTY = 'PLN' )
                                                   ( CORRESPONDING #( WA_2010 ) ) ).

    APPEND LINES OF LT_2010 TO PT_2010.
  ENDLOOP.


  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.

      SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE LT_STRING.
      READ TABLE LT_STRING INTO LS_STRING INDEX 2.
      LV_CHART = LS_STRING.

      IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
        MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'(e02).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY CHART = LV_CHART
                                                                                          SEQNO = LV_SEQNO.

*  선택된 필드의 오더정보 찾기
    READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
      ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.
      IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
      ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO <LV_LINE>.

      CLEAR LV_NUM.
      CLEAR LV_FIELDNAME.
      LV_NUM =  LS_ROUTING-SEQNO + 0.
      LV_FIELDNAME = LV_NUM && '_SEQNO'.

      IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.
      IF <LV_GONGSEQ> IS NOT ASSIGNED. " 공정을 못찾으면 종료
        RETURN.
      ELSE.
        IF <LV_GONGSEQ> = 0. " 해당 공정 순번이 비어있다면 오더가 없다는 의미 다음순번
          CONTINUE.
        ENDIF.
      ENDIF.

      READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
      READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
      READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.

* 중복 필드라면 대상이 아님
      IF LS_CHAIN-CHK_DUP EQ ABAP_TRUE.
        CONTINUE.
      ENDIF.

      IF LS_CHAIN-ORDNR IS INITIAL.
        CONTINUE.
      ENDIF.

      IF LS_CHAIN-ORDTY NE 'PLN'.
        CONTINUE.
      ENDIF.

      READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = LS_CHAIN-ORDNR
                                                                      POSNR = LS_CHAIN-POSNR
                                                                       ORDTY = LS_CHAIN-ORDTY.
      IF SY-SUBRC EQ 0.
        APPEND LS_2010 TO PT_2010.
      ENDIF.
    ENDIF.
  ENDLOOP.

  REFRESH LT_2010.

  SORT PT_2010 BY GONG_CD ORDNR POSNR ORDTY.
  DELETE ADJACENT DUPLICATES FROM PT_2010 COMPARING GONG_CD ORDNR POSNR ORDTY.

  LT_MATNR = VALUE #( FOR LW_2010 IN PT_2010 WHERE ( MATNR IS NOT INITIAL )
                          ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2010-MATNR ) ).
  IF LT_MATNR IS NOT INITIAL.
    SORT LT_MATNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

    SELECT * FROM ZGTCVMSTVAL
      INTO TABLE @DATA(LT_CVMSTVAL)
     WHERE WERKS = @P_WERKS
       AND MATNR IN @LT_MATNR
       AND BESKZ NOT IN ( 'E', 'X' ).
    IF SY-SUBRC EQ 0 AND  LT_CVMSTVAL IS NOT INITIAL.
      READ TABLE LT_CVMSTVAL INTO DATA(LS_CVMSTVAL) INDEX 1.
      READ TABLE PT_2010 INTO DATA(LS_CHK_MATNR) WITH KEY MATNR = LS_CVMSTVAL-MATNR.
      READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY CHART = LS_CHK_MATNR-GONG_CD
                                                                                          GONG_SEQ = LS_CHK_MATNR-GONG_SEQ.

      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          INPUT  = LS_CVMSTVAL-MATNR
        IMPORTING
          OUTPUT = LV_MATNR_C.

      LV_MESSAGE = '공정(' && LS_ROUTING-CHART_VAL && ') 자재 (' && LV_MATNR_C && ')는'.
      MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MESSAGE '외주 조달유형입니다. 임가공이나 구매요청으로 진행하세요.'(e80).
      PV_CHK_ERR = ABAP_TRUE.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RELEASE_PRD_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RELEASE_PRD_ORDER .

  DATA : LV_CHK_ERR.
  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_ERR_ORDER TYPE BAPI_ORDER_RETURN_TT.

  PERFORM CHK_LINE_FOR_RELEASE TABLES LT_2010
                                                 CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF LT_2010[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '릴리즈 할 생산 오더를 선택해 주세요'(e09).
    RETURN.
  ENDIF.

*  PERFORM CHECK_POJANG TABLES LT_2010 CHANGING LV_CHK_POJANG.
*
*  IF LV_CHK_POJANG IS INITIAL.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 오더가 릴리즈 됩니다. 계속 진행 하시겠습니까?'
    '작업확인'.
*  ELSE.
*    CLEAR GV_ANSWER.
*    PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
*      ' '
*      '포장재가 확정되지 않았습니다. 진행하시겠습니까?'
*      '작업확인'.
*
*  ENDIF.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  DATA : LT_ORDERS TYPE TABLE OF BAPI_ORDER_KEY.
  DATA : LV_SUM_NUM TYPE I.

  LOOP AT LT_2010 INTO DATA(LS_2010).
*   판매오더에 연결된 생산오더 - 포장재 확인후 속성값 세팅
    IF LS_2010-DMORDTY = 'SO'.
*      CHECK_PACK_SET_MENGE( IS_2010 = LS_2010 ).
    ENDIF.

    APPEND INITIAL LINE TO LT_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDERS>).
    <LS_ORDERS>-ORDER_NUMBER = LS_2010-ORDNR.
  ENDLOOP.

  CALL FUNCTION 'BAPI_PRODORD_RELEASE'
    TABLES
      ORDERS        = LT_ORDERS
      DETAIL_RETURN = LT_ERR_ORDER.

  IF LT_ERR_ORDER[] IS NOT INITIAL.
    REFRESH GT_DEL_DISP.
    LOOP AT LT_ERR_ORDER INTO DATA(LS_ERR_ORDER).
      APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING FIELD-SYMBOL(<LS_DEL_DISP>).
      CASE LS_ERR_ORDER-TYPE.
        WHEN 'E'.
          <LS_DEL_DISP>-STATUS = ICON_LED_RED.
        WHEN 'S'.
          <LS_DEL_DISP>-STATUS = ICON_LED_GREEN.
        WHEN OTHERS.
          <LS_DEL_DISP>-STATUS = ICON_LED_YELLOW.
      ENDCASE.

      <LS_DEL_DISP>-ORDNR = LS_ERR_ORDER-ORDER_NUMBER.
      <LS_DEL_DISP>-ORDTY = 'PRD'.
      <LS_DEL_DISP>-MESSAGE = LS_ERR_ORDER-MESSAGE.
    ENDLOOP.
    CLEAR GV_DISP_SET.
    GV_DISP_SET = 'B'.
    CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
    CLEAR GV_DISP_SET.
    PERFORM REFRESH_SCREEN_201.

  ELSE.

    DATA : LV_LINES TYPE I.
    DATA : LV_LINES_C TYPE C LENGTH 10..

    PERFORM REFRESH_SCREEN_201.
    LV_LINES = LINES( LT_2010 ) .
    LV_LINES_C = LV_LINES_C.
    CONDENSE LV_LINES_C.
    MESSAGE S006 WITH '총' LV_LINES_C '건 릴리즈 완료하였습니다.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_LINE_FOR_RELEASE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_LINE_FOR_RELEASE  TABLES   PT_2010 LIKE GT_2010
                                              CHANGING PV_CHK_ERR.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_NUM(2) TYPE N.
  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.

  CLEAR : PV_CHK_ERR.
  REFRESH PT_2010[].

  GO_GRID_0201->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  GO_GRID_0201->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL AND LT_CELLS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'(e01).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
    READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 2.
    LV_CHART = LS_STRING.

    IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
      MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 컬럼이 선택되었습니다.'(e02).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
* 선택된 컬럼의 공정 유형 전부 추출
    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY CHART = LV_CHART
                                                                                        SEQNO = LV_SEQNO.

    LT_2010 = VALUE #( FOR WA_2010 IN GT_2010 WHERE ( GONG_CD = LV_CHART
                                                                       AND   GONG_SEQ = LS_ROUTING-GONG_SEQ
                                                                       AND   ORDTY = 'PRD'
                                                                       AND   STATUS = 'C' )
                                                   ( CORRESPONDING #( WA_2010 ) ) ).

    APPEND LINES OF LT_2010 TO PT_2010.
  ENDLOOP.


  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.

      SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE LT_STRING.
      READ TABLE LT_STRING INTO LS_STRING INDEX 2.
      LV_CHART = LS_STRING.

      IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
        MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'(e02).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY CHART = LV_CHART
                                                                                          SEQNO = LV_SEQNO.

*  선택된 필드의 오더정보 찾기
    READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
      ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.
      IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
      ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO <LV_LINE>.

      CLEAR LV_NUM.
      CLEAR LV_FIELDNAME.
      LV_NUM =  LS_ROUTING-SEQNO + 0.
      LV_FIELDNAME = LV_NUM && '_SEQNO'.

      IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.
      IF <LV_GONGSEQ> IS NOT ASSIGNED. " 공정을 못찾으면 종료
        RETURN.
      ELSE.
        IF <LV_GONGSEQ> = 0. " 해당 공정 순번이 비어있다면 오더가 없다는 의미 다음순번
          CONTINUE.
        ENDIF.
      ENDIF.

      READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
      READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
      READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.

* 중복 필드라면 대상이 아님
      IF LS_CHAIN-CHK_DUP EQ ABAP_TRUE.
        CONTINUE.
      ENDIF.

      IF LS_CHAIN-ORDNR IS INITIAL.
        CONTINUE.
      ENDIF.

      IF LS_CHAIN-ORDTY NE 'PRD'.
        CONTINUE.
      ENDIF.

      READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = LS_CHAIN-ORDNR
                                                                      POSNR = LS_CHAIN-POSNR
                                                                       ORDTY = LS_CHAIN-ORDTY
                                                                      STATUS = 'C'.
      IF SY-SUBRC EQ 0.
        APPEND LS_2010 TO PT_2010.
      ENDIF.
    ENDIF.
  ENDLOOP.

  REFRESH LT_2010.

  SORT PT_2010 BY GONG_CD ORDNR POSNR ORDTY.
  DELETE ADJACENT DUPLICATES FROM PT_2010 COMPARING GONG_CD ORDNR POSNR ORDTY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0220
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0220 .

  CREATE OBJECT GO_CONTAIN_0220
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

  CREATE OBJECT GO_GRID_0220
    EXPORTING
      I_PARENT      = GO_CONTAIN_0220
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0220
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0220 .

  DATA : LV_LINES(11).
  CLEAR GS_LAYOUT_0220.
  GS_LAYOUT_0220-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0220-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0220-NO_ROWMARK   = 'X'.
  GS_LAYOUT_0220-SEL_MODE   = 'C'.
  GS_LAYOUT_0220-SMALLTITLE = ABAP_TRUE.

  LV_LINES = LINES( GT_DEL_DISP ).
  CONDENSE LV_LINES.
  IF  GV_DISP_SET IS NOT INITIAL.
    CONCATENATE '건수 :' LV_LINES '건' INTO GS_LAYOUT_0220-GRID_TITLE SEPARATED BY SPACE.
  ELSE.
    CONCATENATE '에러 건수 :' LV_LINES '건' INTO GS_LAYOUT_0220-GRID_TITLE SEPARATED BY SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0220
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0220 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2010TOP'
      I_INTERNAL_TABNAME     = 'GS_DEL_DISP'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0220[]
    TABLES
      IT_DATA         = GT_DEL_DISP
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0220 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '상태'.
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
        IF GV_DISP_SET IS INITIAL.
          <LS_FCAT>-NO_OUT = 'X'.
        ENDIF.
      WHEN 'ORDNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
        IF GV_DISP_SET IS NOT INITIAL.
          <LS_FCAT>-NO_OUT = 'X'.
        ENDIF.
      WHEN 'ORDTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더 타입'.
        <LS_FCAT>-JUST = 'C'.
        IF GV_DISP_SET IS NOT INITIAL.
          <LS_FCAT>-NO_OUT = 'X'.
        ENDIF.
      WHEN 'MESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '결과 메세지'.
        <LS_FCAT>-JUST = 'L'.
    ENDCASE.
    IF GV_DISP_SET = 'B'.
      CLEAR <LS_FCAT>-NO_OUT.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0220
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0220 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0220
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0220_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0220_DISPLAY .

  CALL METHOD GO_GRID_0220->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0220
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0220
    CHANGING
      IT_OUTTAB            = GT_DEL_DISP
      IT_FIELDCATALOG      = GT_FIELDCAT_0220.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_MULTY_POSNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MULTY_POSNR .

  DATA : LT_2010 LIKE GT_2010.
  DATA : LV_CHK_ERR.
  DATA : LO_JOJANG TYPE REF TO ZGTPP_CL_ROUTING_GAON.
  DATA : LT_RESULT TYPE BAPI_ORDER_RETURN_TT.

  GO_GRID_0201->CHECK_CHANGED_DATA( ).

  PERFORM CHK_SET_MULTY_POSNR TABLES LT_2010
                                          CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '복조장 구성 진행합니다. 계속 진행 하시겠습니까?'
    '구성확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CREATE OBJECT LO_JOJANG
    EXPORTING
      IV_WERKS              = P_WERKS                 " 플랜트
      IV_GRPNR              = GV_GRPNR                 " 조장 구성표 번호
      IT_MAIN               = GT_MAKE_DISPLAY
      IT_SEQ_ROUTING_HEADER = GT_SEQ_ROUTING_HEADER
      IT_SEQ_ROUTING_SUB    = GT_SEQ_ROUTING_SUB
      IT_MAKED_2010         = GT_2010.

  LT_RESULT = LO_JOJANG->PROC_MULTY_ORDER( ).

  REFRESH GT_DEL_DISP.

  CLEAR LV_CHK_ERR.
  LOOP AT LT_RESULT INTO DATA(LS_RESULT).
    APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING FIELD-SYMBOL(<LS_DEL_DISP>).
    <LS_DEL_DISP>-MESSAGE = LS_RESULT-MESSAGE.
    CASE LS_RESULT-TYPE.
      WHEN 'E'.
        LV_CHK_ERR = ABAP_TRUE.
        <LS_DEL_DISP>-STATUS = ICON_LED_RED.
      WHEN 'W'.
        <LS_DEL_DISP>-STATUS = ICON_LED_RED.
      WHEN 'S'.
        <LS_DEL_DISP>-STATUS = ICON_LED_GREEN.
    ENDCASE.
  ENDLOOP.

  GV_DISP_SET = 'A'.
  CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
  CLEAR GV_DISP_SET.

  IF LV_CHK_ERR IS INITIAL.

*  변경정보 MES전송
    ZGTPP_CL_ROUTING=>SEND_CHG_MES(
      IV_WERKS = P_WERKS           " 플랜트
      IV_SPGCD = P_SPGCD          " SPG 코드
      IV_GRPNR = GV_GRPNR ).    " 조장 구성표 번호


    PERFORM REFRESH_SCREEN_201.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_SET_MULTY_POSNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_SET_MULTY_POSNR  TABLES   PT_2010 STRUCTURE GS_2010
                                          CHANGING PV_CHK_ERR.

  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_2010_COLLECT LIKE TABLE OF GS_2010.
  DATA : LT_2010_CHK LIKE TABLE OF GS_2010. "입력된 숫자나 문자 기준으로 소트된 테이블
  DATA : LT_2010_CHK2 LIKE TABLE OF GS_2010. " 각종 체크 대상들
  DATA : LT_2010_CHK3 LIKE TABLE OF GS_2010. " 각종 체크 대상들
  DATA : LO_ROUTING TYPE REF TO ZGTPP_CL_ROUTING.
  DATA : LV_SEQNO TYPE I.


* 조장구성표 상세내역에서 입력된 숫자나 문자가 있을경우 복조장 구성이 가능한지 체크
  LT_2010 = VALUE #( FOR WA_2010 IN GT_2010 WHERE ( CHK_CHAR IS NOT INITIAL ) ( CORRESPONDING #( WA_2010 ) ) ).

  LT_2010_CHK = LT_2010[].
  SORT LT_2010_CHK BY CHK_CHAR.
  DELETE ADJACENT DUPLICATES FROM LT_2010_CHK COMPARING CHK_CHAR..

  LOOP AT LT_2010_CHK INTO DATA(LS_2010_CHK).
    REFRESH LT_2010_CHK2.
    LT_2010_CHK2 = VALUE #( FOR WA_2010 IN GT_2010 WHERE ( CHK_CHAR = LS_2010_CHK-CHK_CHAR ) ( CORRESPONDING #( WA_2010 ) ) ).

*  복조장에 구성문자 입력시 복조장은 전부 같은 구성문자로 포함 되어야 한다.
    LOOP AT LT_2010_CHK2 INTO DATA(LS_2010_CHK2).
      LOOP AT LT_2010 INTO DATA(LS_2010) WHERE ORDNR = LS_2010_CHK2-ORDNR
                                                               AND CHK_CHAR NE LS_2010_CHK-CHK_CHAR.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '복조장 구성이 잘못되었습니다. 구성 표시 값을 확인해 주세요.'(e16).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDLOOP.

      IF LS_2010_CHK2-ORDTY NE 'PRD'.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 유형만 복조장 구성할 수 있습니다.'(e15).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.

      IF LS_2010_CHK2-REF_TANDEM = ABAP_TRUE.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '복조장 구성이 잘못되었습니다. 구성 표시 값을 확인해 주세요.'(e16).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.

      IF LS_2010_CHK2-REF_TANDEM = 'T'. "탄뎀 복조장 구성시 탄뎀 설정된 오더끼리만 구성가능
        REFRESH LT_2010_CHK3.
        LT_2010_CHK3 = VALUE #( FOR WA_2010 IN LT_2010_CHK2 WHERE ( REF_TANDEM NE 'T' ) ( CORRESPONDING #( WA_2010 ) ) ).

        IF LT_2010_CHK3[] IS NOT INITIAL.
          MESSAGE S003 DISPLAY LIKE 'E' WITH '복조장 구성이 잘못되었습니다. 구성 표시 값을 확인해 주세요.- 탄뎀'(e95).
          PV_CHK_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.
      ENDIF.

    ENDLOOP.

* 같은 문자가 없이 개별로 지정된 오더가 있으면 에러
    IF LINES( LT_2010_CHK2 ) = 1. "단독으로 존재한다면 복조장 구성을 할수 없음
      MESSAGE S003 DISPLAY LIKE 'E' WITH '복조장 구성이 잘못되었습니다. 구성 표시 값을 확인해 주세요.- 단독존재'(e14).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

*   같은 구분자로 정해진 복조장 구성 요소가 같은 공정에 있는지 확인
    DATA(LT_CHK_GONG) = LT_2010_CHK2.
    SORT LT_CHK_GONG BY GONG_CD GONG_SEQ.
    DELETE ADJACENT DUPLICATES FROM LT_CHK_GONG COMPARING GONG_CD GONG_SEQ.
    IF LINES( LT_CHK_GONG ) > 1. "공정코드가 다른값이 존재하면 에러
      MESSAGE S003 DISPLAY LIKE 'E' WITH '복조장 구성이 잘못되었습니다. 구성 표시 값을 확인해 주세요.-공정차이'(e12).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

*   같은 구분자로 정해진 복조장 구성 요소가 같은 공정에 있는지 확인
    DATA(LT_CHK_MATNR) = LT_2010_CHK2.
    SORT LT_CHK_MATNR BY GONG_CD MATNR GONG_SEQ.
    DELETE ADJACENT DUPLICATES FROM LT_CHK_MATNR COMPARING GONG_CD MATNR GONG_SEQ.
    IF LINES( LT_CHK_MATNR ) > 1. "공정코드가 다른값이 존재하면 에러
      MESSAGE S003 DISPLAY LIKE 'E' WITH '복조장 구성이 잘못되었습니다. 구성 표시 값을 확인해 주세요.-자재가 다름'(e13).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

* 완제품 Factor Batch 확인 -
*  1) 같은 판매오더끼리 구성가능
    SELECT SINGLE * FROM ZGTCVMSTVAL
       INTO @DATA(LS_CVMSTVAL)
    WHERE WERKS = @P_WERKS
      AND MATNR = @LS_2010_CHK-MATNR.
    IF SY-SUBRC EQ 0 AND LS_CVMSTVAL-MTREF = 'FERT' AND LS_CVMSTVAL-DPCBT = 'A'.
      DATA(LV_CHK_FACTOR_BATCH) = ABAP_TRUE.
      DATA(LT_CHK_VBELN) = LT_2010_CHK2.
      SORT LT_CHK_VBELN BY GONG_SEQ DMORD DMLINE.
      DELETE ADJACENT DUPLICATES FROM LT_CHK_VBELN COMPARING GONG_SEQ DMORD DMLINE.
      IF LINES( LT_CHK_VBELN ) > 1. "공정코드가 다른값이 존재하면 에러
        MESSAGE S003 DISPLAY LIKE 'E' WITH '복조장 구성이 잘못되었습니다. 구성 표시 값을 확인해 주세요.-판매오더, 품목 다름'(e70).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.
*  2) 같은 판매오더끼리 구성가능
    IF LV_CHK_FACTOR_BATCH = ABAP_TRUE.
      READ TABLE LT_2010_CHK2 TRANSPORTING NO FIELDS WITH KEY MULTY_REF = ABAP_TRUE.
      IF SY-SUBRC EQ 0.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '복조장 구성이 잘못되었습니다. 구성 표시 값을 확인해 주세요.-선택항목 복조장존재'(e71).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.

  ENDLOOP.

  DATA : LT_2010_ORIGN TYPE TABLE OF ZGTPPT2010.
  DATA : LT_2010_PRE TYPE TABLE OF ZGTPPT2010.
  DATA : LV_STRING TYPE STRING.

  LOOP AT LT_2010 INTO LS_2010.
    IF NOT ( LS_2010-CHK_PRD IS INITIAL AND LS_2010-CHECK_JEGO IS INITIAL ).
      READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY GONG_SEQ = LS_2010-GONG_SEQ.
      CLEAR LV_STRING.
      LV_STRING = '(' && LS_ROUTING-CHART_VAL && ')'.

      MESSAGE S006 DISPLAY LIKE 'E' WITH LV_STRING LS_2010-ORDNR '오더는 생산 진행중으로 복조장 구성할 수 없습니다.'(e10).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

    APPEND INITIAL LINE TO LT_2010_ORIGN ASSIGNING FIELD-SYMBOL(<LS_2010_ORIGN>).
    MOVE-CORRESPONDING LS_2010 TO <LS_2010_ORIGN>.
  ENDLOOP.

  PT_2010[] = LT_2010[].

* 선택된 공정의 이전 공정들에 대해 조회 - 생산 진행 중일시 복조장 구성 불가
  LOOP AT PT_2010 INTO DATA(LS_2010_WQ).
    REFRESH LT_2010_CHK.
    APPEND LS_2010_WQ TO LT_2010_CHK.
* 해당 오더가 복조장 오더일시 복조장 메인 조회 - 차후 추가예정

    READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = LS_2010_WQ-GONG_SEQ.
    LV_SEQNO = LS_ROUTING-SEQNO.
    DO.
      LV_SEQNO = LV_SEQNO - 1.
      IF LV_SEQNO = 0.
        EXIT.
      ENDIF.
      READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY SEQNO = LV_SEQNO.

      LOOP AT GT_2010 INTO DATA(LS_2010_PRE) WHERE GONG_SEQ = LS_ROUTING-GONG_SEQ.
        READ TABLE LT_2010_CHK TRANSPORTING NO FIELDS WITH KEY ORDNR = LS_2010_PRE-DMORD
                                                                                    POSNR = LS_2010_PRE-DMLINE
                                                                                    ORDTY = LS_2010_PRE-DMORDTY.
        IF SY-SUBRC EQ 0.
          IF LS_2010_PRE-CHK_PRD = ABAP_TRUE.
            READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = LS_2010_WQ-GONG_SEQ.
            CLEAR LV_STRING.
            LV_STRING = '(' && LS_ROUTING-CHART_VAL && ')'.
            MESSAGE S006 DISPLAY LIKE 'E' WITH LV_STRING LS_2010_WQ-ORDNR '오더는 생산 진행중으로 복조장 구성할 수 없습니다.'(e09).
            PV_CHK_ERR = ABAP_TRUE.
            RETURN.
          ENDIF.

          IF LS_2010_PRE-REF_TANDEM = 'T'.
            READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = LS_2010_WQ-GONG_SEQ.
            CLEAR LV_STRING.
            LV_STRING = '(' && LS_ROUTING-CHART_VAL && ')'.
            MESSAGE S006 DISPLAY LIKE 'E' WITH LV_STRING LS_2010_WQ-ORDNR '오더는 이전 공정에 탄뎀 설정되어 있어 복조장 구성할 수 없습니다.'(e94).
            PV_CHK_ERR = ABAP_TRUE.
            RETURN.
          ENDIF.

        ENDIF.
      ENDLOOP.
    ENDDO.

  ENDLOOP.

  DATA : LV_AUART TYPE AUFART.
  DATA : LT_AUART TYPE TABLE OF AUFART.

* 해당 선택된 오더들의 오더타입 확인,
  SELECT A~CHK_CHAR, B~AUFNR, B~AUART
    FROM @LT_2010 AS A
    INNER JOIN AUFK AS B ON B~AUFNR = A~ORDNR
    INTO TABLE @DATA(LT_AUART_TMP).

  DATA(LT_CHK_AUART)  = LT_AUART_TMP.
  SORT LT_CHK_AUART BY CHK_CHAR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_AUART COMPARING CHK_CHAR.

  LOOP AT LT_CHK_AUART INTO DATA(LS_CHK_AUART).
    REFRESH LT_AUART.
    LOOP AT LT_AUART_TMP INTO DATA(LS_AUART) WHERE CHK_CHAR = LS_CHK_AUART-CHK_CHAR.
      LV_AUART = LS_AUART-AUART.
      COLLECT LV_AUART INTO LT_AUART.
    ENDLOOP.

    IF LINES( LT_AUART ) NE 1.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '동일한 생산오더 유형으로만 복조장 구성할 수 있습니다.'(e17).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_SEPERATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_SEPERATE .

  DATA : LT_2010 LIKE GT_2010.
  DATA : LV_CHK_ERR.
  DATA : LO_JOJANG TYPE REF TO ZGTPP_CL_ROUTING_GAON.
  DATA : LT_RESULT TYPE BAPI_ORDER_RETURN_TT.

  PERFORM CHK_PROCESS_SEPERATE TABLES LT_2010
                                                 CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '개별 생산오더전환 진행합니다. 계속 진행 하시겠습니까?'
    '작업확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CREATE OBJECT LO_JOJANG
    EXPORTING
      IV_WERKS              = P_WERKS                 " 플랜트
      IV_GRPNR              = GV_GRPNR                 " 조장 구성표 번호
      IT_MAIN               = GT_MAKE_DISPLAY
      IT_SEQ_ROUTING_HEADER = GT_SEQ_ROUTING_HEADER
      IT_SEQ_ROUTING_SUB    = GT_SEQ_ROUTING_SUB
      IT_MAKED_2010         = GT_2010.

  LT_RESULT = LO_JOJANG->PROCESS_SEPERATE( IT_2010 = LT_2010 ).

  IF LINE_EXISTS( LT_RESULT[ TYPE = 'E' ] ).
    READ TABLE LT_RESULT INTO DATA(LS_RESULT) WITH KEY TYPE = 'E'.
    MESSAGE S006 DISPLAY LIKE 'E' WITH LS_RESULT-MESSAGE.
    RETURN.
  ENDIF.

  IF GV_CHK_EXIST_BWD = ABAP_TRUE AND LO_JOJANG->MT_MESSAGE_BWD[] IS NOT INITIAL.
    CALL FUNCTION 'ZGTPP_UTILL_TEXTEDIT'
      EXPORTING
        IV_MODE  = '1'
        IV_TITLE = '신선작업지시 초과수량'
      CHANGING
        CT_TEXT  = LO_JOJANG->MT_MESSAGE_BWD.
  ENDIF.

*  변경정보 MES전송
  ZGTPP_CL_ROUTING=>SEND_CHG_MES(
    IV_WERKS = P_WERKS           " 플랜트
    IV_SPGCD = P_SPGCD          " SPG 코드
    IV_GRPNR = GV_GRPNR ).    " 조장 구성표 번호

  PERFORM REFRESH_SCREEN_201.
  READ TABLE LT_RESULT INTO LS_RESULT WITH KEY TYPE = 'S'.
  MESSAGE S006 WITH LS_RESULT-MESSAGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_PROCESS_SEPERATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_PROCESS_SEPERATE  TABLES   PT_2010 LIKE GT_2010
                                              CHANGING PV_CHK_ERR.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_2010_CHK LIKE TABLE OF GS_2010.
  DATA : LT_2010_DEV LIKE TABLE OF GS_2010.
  DATA : LT_2010_PRE LIKE TABLE OF GS_2010.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_STRING     TYPE  STRING.
  DATA : LV_TABIX TYPE I.

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.

  GO_GRID_0201->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  IF LT_COLUMN[] IS NOT INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '컬럼을 선택할 수 없습니다.'(e18).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  GO_GRID_0201->GET_SELECTED_CELLS_ID(
    IMPORTING
     ET_CELLS = LT_CELLS ).                " Cell IDs

  IF 1 > LINES( LT_CELLS ).
    MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 셀만 선택해야 합니다.'(e19).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.

      SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
      READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 2.
      LV_CHART = LS_STRING.

      IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
        MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'(e02).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY CHART = LV_CHART
                                                                                          SEQNO = LV_SEQNO.

*  선택된 필드의 오더정보 찾기
    READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
      ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.
      IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
      ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO <LV_LINE>.

      CLEAR LV_NUM.
      CLEAR LV_FIELDNAME.
      LV_NUM =  LS_ROUTING-SEQNO + 0.
      LV_FIELDNAME = LV_NUM && '_SEQNO'.

      IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.
      IF <LV_GONGSEQ> IS NOT ASSIGNED. " 공정을 못찾으면 종료
        RETURN.
      ELSE.
        IF <LV_GONGSEQ> = 0. " 해당 공정 순번이 비어있다면 오더가 없다는 의미 다음순번
          CONTINUE.
        ENDIF.
      ENDIF.

      READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
      READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
      READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.

* 중복 필드라면 대상이 아님
      IF LS_CHAIN-CHK_DUP EQ ABAP_TRUE.
        CONTINUE.
      ENDIF.

* 오더가 존재해야함
      IF LS_CHAIN-ORDNR IS INITIAL.
        CONTINUE.
      ENDIF.

* 생산 오더만 복조장 가능 하므로 생산오더인지 확인
      IF LS_CHAIN-ORDTY NE 'PRD'.
        CONTINUE.
      ENDIF.

      READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = LS_CHAIN-ORDNR
                                                                      POSNR = LS_CHAIN-POSNR
                                                                       ORDTY = LS_CHAIN-ORDTY.
      .
      IF SY-SUBRC EQ 0.
        APPEND LS_2010 TO PT_2010.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF PT_2010[] IS INITIAL.
    PV_CHK_ERR = ABAP_TRUE.
  ENDIF.

* 정합성 검사
* 1. 해당 오더가 복조장 구성인지 확인

  READ TABLE PT_2010 INDEX 1.
  SELECT B~AUFNR, B~POSNR
     FROM AUFK AS A
     INNER JOIN AFPO AS B
                            ON B~AUFNR = A~AUFNR
       INTO TABLE @DATA(LT_AFPO)
    WHERE A~AUFNR = @PT_2010-ORDNR
        AND A~FLG_MLTPS = 'X'. " 복수품목

  IF LINES( LT_AFPO ) > 1. "선택된 오더의 품목이 여러개일시 복조장,
  ELSE.

* 완제품 Factor Batch 복조장의 경우 오더 한건만 존재 (MULTY_REF 확인)
    IF PT_2010-MULTY_REF NE ABAP_TRUE.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '복조장 구성 오더가 아닙니다.'(e20).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
  ENDIF.

* 2. 해당 생산 오더나 이전 공정 생산 오더들 가동중인지 확인.
  IF PT_2010-CHK_PRD IS NOT INITIAL.
    CLEAR LV_STRING.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = PT_2010-GONG_SEQ.
    CLEAR LV_NUM.
    LV_NUM = LS_ROUTING-SEQNO + 0.
    LV_STRING = '(' && LV_NUM && '_' && LS_ROUTING-CHART_VAL && ')'.

    MESSAGE S006 DISPLAY LIKE 'E' WITH LV_STRING PT_2010-ORDNR '오더는 생산 진행중으로 개별오더전환을 할 수 없습니다.'.
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

* 이전 공정 생산 오더체인정보 추출
  REFRESH LT_2010_DEV.
  LT_2010_DEV = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( ORDNR = PT_2010-ORDNR )
                                   ( CORRESPONDING #( LW_2010 ) ) ).

  REFRESH PT_2010[].
  MOVE-CORRESPONDING LT_2010_DEV TO PT_2010[]. " 분리될 오더정보 담아준다.



  DO.

    REFRESH LT_2010_PRE.

    LOOP AT LT_2010_DEV INTO DATA(LS_DEV).
      REFRESH LT_2010_CHK.
      LT_2010_CHK = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( DMORD = LS_DEV-ORDNR
                                                                         AND   DMLINE = LS_DEV-POSNR
                                                                         AND   DMORDTY = LS_DEV-ORDTY )
                                       ( CORRESPONDING #( LW_2010 ) ) ).

      IF LT_2010_CHK IS NOT INITIAL.
        LOOP AT LT_2010_CHK INTO DATA(LS_CHK_2010).
          READ TABLE LT_2010_PRE INTO DATA(LS_2010_PRE) WITH KEY ORDNR = LS_CHK_2010-ORDNR
                                                                                     POSNR = LS_CHK_2010-POSNR
                                                                                     ORDTY = LS_CHK_2010-ORDTY
                                                                                     BINARY SEARCH.
          IF SY-SUBRC NE 0.
            CLEAR LV_TABIX.
            LV_TABIX = SY-TABIX.
            IF LS_2010_PRE-CHK_PRD IS NOT INITIAL.
              CLEAR LV_STRING.
              READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = LS_2010_PRE-GONG_SEQ.
              CLEAR LV_NUM.
              LV_NUM = LS_ROUTING-SEQNO + 0.
              LV_STRING = '(' && LV_NUM && '_' && LS_ROUTING-CHART_VAL && ')'.

              MESSAGE S006 DISPLAY LIKE 'E' WITH LV_STRING LS_2010_PRE-ORDNR '오더는 생산 진행중으로 개별오더전환을 할 수 없습니다.'.
              PV_CHK_ERR = ABAP_TRUE.
              RETURN.
            ENDIF.

* 3. 이전 공성 생산 오더에 복조장 존재시 에러처리
            REFRESH LT_AFPO.
            SELECT B~AUFNR, B~POSNR
               FROM AUFK AS A
               INNER JOIN AFPO AS B
                                      ON B~AUFNR = A~AUFNR
                 INTO TABLE @LT_AFPO
              WHERE A~AUFNR = @LS_2010_PRE-ORDNR
                  AND A~FLG_MLTPS = 'X'. " 복수품목

            IF LINES( LT_AFPO ) > 1. "선택된 오더의 품목이 여러개일시 복조장,
              CLEAR LV_STRING.
              READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = LS_2010_PRE-GONG_SEQ.
              CLEAR LV_NUM.
              LV_NUM = LS_ROUTING-SEQNO + 0.
              LV_STRING = '(' && LV_NUM && '_' && LS_ROUTING-CHART_VAL && ')'.

              MESSAGE S006 DISPLAY LIKE 'E' WITH LV_STRING LS_2010_PRE-ORDNR '오더는 복조장 구성중으로 개별오더전환을 할 수 없습니다.'(e21).
              PV_CHK_ERR = ABAP_TRUE.
              RETURN.
            ENDIF.

            INSERT LS_2010_PRE INTO LT_2010_PRE INDEX LV_TABIX.
          ENDIF.

        ENDLOOP.
      ENDIF.

    ENDLOOP.

    IF LT_2010_PRE IS INITIAL.
      EXIT.
    ENDIF.

    REFRESH LT_2010_DEV.
    APPEND LINES OF LT_2010_PRE TO LT_2010_DEV.

  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_MASTER_ORDER_CHG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_MASTER_ORDER_CHG .

  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_DEL_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : LT_CHG_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : LT_2010_TEMP TYPE TABLE OF ZGTPPT2010.
  DATA : LT_2010_COUNT TYPE TABLE OF ZGTPPT2010.
  DATA : LS_DEL_2010 TYPE ZGTPPT2010.
  DATA : LS_2000 TYPE ZGTPPT2000.
  DATA : LT_2000_TMP TYPE TABLE OF ZGTPPT2000.
  DATA : LT_2000_CHG TYPE TABLE OF ZGTPPT2000.
  DATA :  LV_IDX TYPE I.
  DATA : LV_CHK_ERR.
  DATA : LV_TABIX TYPE I.
  DATA : LV_CHK_COUNTING.


  PERFORM CHK_BEFORE_MASTER_ORDER_CHG  TABLES LT_2010
                                                 CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF GT_CHG_RESULT[] IS INITIAL.
    RETURN.
  ENDIF.

  SELECT SINGLE * FROM ZGTPPT2000
    INTO LS_2000
   WHERE GRPNR = GV_GRPNR
     AND ORDNO = GS_HEADER_300-ORDNR
     AND POSNR = GS_HEADER_300-POSNR.

  LOOP AT GT_CHG_RESULT INTO DATA(LS_RESULT).
    REFRESH : LT_2000_TMP, LT_2010_TEMP.
    DO LS_RESULT-INFACTOR TIMES.
      ADD 1 TO LV_IDX.

      IF  LS_RESULT-INFACTOR2 NE 0.
        " 조장 구성이 안되어 있는 조장단위  현재수량만 '-1' 처리
        ADD -1 TO LS_RESULT-INFACTOR2.
      ELSE. " 조장 구성되어 있으나 완제품 생산오더가 없는 오더단위
        CLEAR LV_CHK_COUNTING.
        IF LT_2000_TMP[] IS INITIAL.
          SELECT * FROM ZGTPPT2010
            INTO TABLE @LT_2010_TEMP
           WHERE DMORD = @LS_RESULT-ORDNO
             AND DMLINE = @LS_RESULT-POSNR
             AND DMORDTY = 'SO'.

          SELECT * FROM ZGTPPT2000
            INTO TABLE @LT_2000_TMP
           WHERE WERKS = @P_WERKS
             AND MATNR = @GS_HEADER_300-MATNR
             AND ORDNO = @LS_RESULT-ORDNO
             AND POSNR = @LS_RESULT-POSNR
             AND ZSTATUS <> 'D'.
        ENDIF.


*      계산시 우선 변경으로 저장된 조장부터 건수 확인
        READ TABLE LT_2000_TMP INTO DATA(LS_2000_TEMP) WITH KEY  ORDNO = LS_RESULT-ORDNO
                                                                                    POSNR = LS_RESULT-POSNR.
        IF SY-SUBRC NE 0.

          LOOP AT LT_2000_CHG ASSIGNING FIELD-SYMBOL(<LS_2000_TMP>) WHERE ORDNO = LS_RESULT-ORDNO
                                                                                                        AND POSNR = LS_RESULT-POSNR
                                                                                                        AND INFACTOR > 0.
            REFRESH LT_2010_COUNT.
            LT_2010_COUNT = VALUE #( FOR LW_2010 IN LT_2010_TEMP WHERE ( DMORD = LS_RESULT-ORDNO
                                                                                             AND   DMLINE = LS_RESULT-POSNR )
                                                 ( CORRESPONDING #( LW_2010 ) ) ).

            IF LINES( LT_2010_COUNT ) < <LS_2000_TMP>-INFACTOR.
              ADD -1 TO <LS_2000_TMP>-INFACTOR.
              IF <LS_2000_TMP>-INFACTOR = 0.
                <LS_2000_TMP>-ZSTATUS = 'D'.
              ENDIF.
              EXIT.
            ELSE.
              CONTINUE.
            ENDIF.
          ENDLOOP.
        ELSE.
          LOOP AT LT_2000_TMP INTO LS_2000_TEMP WHERE ORDNO = LS_RESULT-ORDNO
                                                                    AND POSNR = LS_RESULT-POSNR.
            LV_TABIX = SY-TABIX.
            REFRESH LT_2010_COUNT.
            LT_2010_COUNT = VALUE #( FOR LW_2010 IN LT_2010_TEMP WHERE ( DMORD = LS_RESULT-ORDNO
                                                                                             AND   DMLINE = LS_RESULT-POSNR )
                                                 ( CORRESPONDING #( LW_2010 ) ) ).

            IF LINES( LT_2010_COUNT ) < LS_2000_TEMP-INFACTOR.
*            대상이므로 삭제후 변경테이블 적용
              ADD -1 TO LS_2000_TEMP-INFACTOR.
              IF LS_2000_TEMP-INFACTOR = 0.
                LS_2000_TEMP-ZSTATUS = 'D'.
              ENDIF.
              APPEND LS_2000_TEMP TO LT_2000_TMP.
              EXIT.

            ELSE. " 대상이 아니므로 삭제
              DELETE LT_2000_TMP INDEX LV_TABIX.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDIF.

      READ TABLE GT_CHK_IDX INTO GS_CHK_IDX INDEX LV_IDX.
      READ TABLE LT_2010 ASSIGNING FIELD-SYMBOL(<LS_CHG_2010>) WITH KEY ORDNR = GS_CHK_IDX-REORDNR
                                                                                                     POSNR = GS_CHK_IDX-RELINE
                                                                                                     ORDTY = GS_CHK_IDX-REORDTY.
      IF SY-SUBRC EQ 0.
        CLEAR LS_DEL_2010.
        MOVE-CORRESPONDING <LS_CHG_2010> TO LS_DEL_2010.
        APPEND LS_DEL_2010 TO LT_DEL_2010.

*       오더정보 변경
        LS_DEL_2010-DMORD = LS_RESULT-ORDNO.
        LS_DEL_2010-DMLINE = LS_RESULT-POSNR + 0.
        CASE LS_RESULT-GCATG.
          WHEN '판매오더'.
            LS_DEL_2010-DMORDTY = 'SO'.
            PERFORM CHK_AND_SET_DRUM TABLES LT_CHG_2010 CHANGING LS_DEL_2010.
          WHEN '생산오더'.
            LS_DEL_2010-DMORDTY = 'SM'.
        ENDCASE.

        APPEND LS_DEL_2010 TO LT_CHG_2010.
      ENDIF.

      READ TABLE LT_2000_CHG ASSIGNING FIELD-SYMBOL(<LS_2000_CHG>) WITH KEY GRPNR = GV_GRPNR
                                                                                    ORDNO = LS_RESULT-ORDNO
                                                                                    POSNR = LS_RESULT-POSNR.
      IF SY-SUBRC EQ 0.
        ADD 1 TO <LS_2000_CHG>-INFACTOR.
      ELSE.
        APPEND INITIAL LINE TO LT_2000_CHG ASSIGNING <LS_2000_CHG>.

* 현재 조장에 찾아오는 오더가 존재한다면 현재오더 정보에 수량 추가
        SELECT SINGLE * FROM ZGTPPT2000
          INTO @DATA(LS_2000_TMP)
         WHERE GRPNR = @GV_GRPNR
           AND ORDNO = @LS_RESULT-ORDNO
           AND POSNR = @LS_RESULT-POSNR.
        IF SY-SUBRC EQ 0.
          MOVE-CORRESPONDING LS_2000_TMP TO <LS_2000_CHG>.
          IF LS_2000_TMP-INFACTOR = 0 AND LS_2000_TMP-ZSTATUS = 'D'.
            CLEAR <LS_2000_CHG>-ZSTATUS.
            <LS_2000_CHG>-INFACTOR = 1.
          ELSE.
            ADD 1 TO <LS_2000_CHG>-INFACTOR.
          ENDIF.
        ELSE.
          MOVE-CORRESPONDING LS_2000 TO <LS_2000_CHG>.
*       오더정보 변경
          <LS_2000_CHG>-KUNNR = LS_RESULT-KUNNR.
          IF LS_RESULT-GCATG NE '생산오더'.
            PERFORM GET_ZZYUSCD USING LS_RESULT-ORDNO CHANGING <LS_2000_CHG>-ZZYUSCD.
          ELSE.
            <LS_2000_CHG>-ZZYUSCD = '생관'.
          ENDIF.

          <LS_2000_CHG>-ORDNO = LS_RESULT-ORDNO.
          <LS_2000_CHG>-POSNR = LS_RESULT-POSNR + 0.
          <LS_2000_CHG>-GCATG = LS_RESULT-GCATG.
          <LS_2000_CHG>-INFACTOR = 1.
        ENDIF.
      ENDIF.

      ADD -1 TO LS_2000-INFACTOR.
      IF LS_2000-INFACTOR = 0.
        LS_2000-ZSTATUS = 'D'.
      ENDIF.

    ENDDO.
  ENDLOOP.

  APPEND LS_2000 TO LT_2000_CHG.

  IF LT_DEL_2010 IS NOT INITIAL.
    DELETE ZGTPPT2010 FROM TABLE LT_DEL_2010.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '주문 변경사항 저장중 에러 발생하였습니다.'(e27).
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_CHG_2010 IS NOT INITIAL.
    MODIFY ZGTPPT2010 FROM TABLE LT_CHG_2010.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '주문 변경사항 저장중 에러 발생하였습니다.'(e27).
      RETURN.
    ENDIF.
  ENDIF.

  PERFORM SET_TABLE TABLES LT_CHG_2010.

  IF LT_2000_CHG[] IS NOT INITIAL.
    MODIFY ZGTPPT2000 FROM TABLE LT_2000_CHG.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '주문 변경사항 저장중 에러 발생하였습니다.'(e27).
      RETURN.
    ENDIF.
  ENDIF.

  COMMIT WORK AND WAIT.

  DATA : LO_JOJANG TYPE REF TO ZGTPP_CL_ROUTING_GAON.

  CREATE OBJECT LO_JOJANG
    EXPORTING
      IV_WERKS = P_WERKS                 " 플랜트
      IV_GRPNR = GV_GRPNR.                 " 조장 구성표 번호

  SELECT * FROM ZGTPPT2010
    INTO TABLE LO_JOJANG->MT_NEW_2010
   WHERE GRPNR = GV_GRPNR.

  LO_JOJANG->CONFIRM( ).

*  변경정보 MES전송
  ZGTPP_CL_ROUTING=>SEND_CHG_MES(
    IV_WERKS = P_WERKS           " 플랜트
    IV_SPGCD = P_SPGCD          " SPG 코드
    IV_GRPNR = GV_GRPNR ).    " 조장 구성표 번호


  MESSAGE S003 WITH '선택된 조장의 주문이 변경되었습니다. 첫화면으로 돌아갑니다.'(m02).

*     종료
  IF SY-TCODE NE 'ZGTPPR2050'.
    CALL FUNCTION 'DEQUEUE_EZGT_ZGTPPR2010'
      EXPORTING
        GRPNR = GV_GRPNR.
  ENDIF.

  CALL METHOD GO_DOCKING_CONTAINER->FREE.
  FREE : GO_DOCKING_CONTAINER, GO_GRID_0200, GO_GRID_0201.
  CALL METHOD CL_GUI_CFW=>FLUSH.

  UNASSIGN <GT_MAIN_201>.

  PERFORM GET_PROC.
  PERFORM REFRESH_GRID USING GO_GRID_0100.

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_BEFORE_MASTER_ORDER_CHG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_BEFORE_MASTER_ORDER_CHG  TABLES   PT_2010 LIKE GT_2010
                                              CHANGING PV_CHK_ERR.

  DATA : LT_CHK_DUP LIKE TABLE OF GS_CHK_IDX.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LV_INDEX TYPE I.

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.

  CLEAR : PV_CHK_ERR.
  REFRESH PT_2010[].

  GO_GRID_0201->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  REFRESH GT_CHK_IDX.

* 필드선택시 전체 대상 확인
  IF LT_COLUMN[] IS INITIAL.
    GO_GRID_0201->GET_SELECTED_CELLS_ID(
        IMPORTING
         ET_CELLS = LT_CELLS ).                " Cell IDs
* 셀 선택시 선택 라인 대상으로 확인
    SORT LT_CELLS BY ROW_ID.
    DELETE ADJACENT DUPLICATES FROM LT_CELLS COMPARING ROW_ID.

    LOOP AT LT_CELLS INTO DATA(LS_CELLS).
      READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
      IF SY-SUBRC EQ 0.
        IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
        ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.

        READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
* 완제품 공정의 순번이 마지막 이므로 소트후 조회
        SORT LS_ITAB-T_GONG BY SEQNO DESCENDING.
        READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) INDEX 1.
* 마스터 오더에 연결된 완제품 공정은 하나이므로 리드테이블로 데이터 구성
        CLEAR GS_CHK_IDX.
        GS_CHK_IDX-TABIX = LS_ITAB-END_SEQNO.
        GS_CHK_IDX-MATNR = LS_ITAB-MATNR .
        GS_CHK_IDX-GCATG = LS_ITAB-GCATG.
        GS_CHK_IDX-ORDNO = LS_ITAB-END_ORDNR.
        GS_CHK_IDX-POSNR = LS_ITAB-END_POSNR.
        READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) INDEX 1.
        IF SY-SUBRC EQ 0 AND LS_CHAIN-ORDNR IS NOT INITIAL.
          GS_CHK_IDX-REORDNR = LS_CHAIN-ORDNR.
          GS_CHK_IDX-RELINE = LS_CHAIN-POSNR.
          GS_CHK_IDX-REORDTY = LS_CHAIN-ORDTY.
        ENDIF.
        APPEND GS_CHK_IDX TO GT_CHK_IDX.
      ENDIF.
    ENDLOOP.

    SORT GT_CHK_IDX BY TABIX.
    DELETE ADJACENT DUPLICATES FROM GT_CHK_IDX COMPARING TABIX.

  ELSE.

    LOOP AT GT_MAKE_DISPLAY INTO LS_ITAB.
* 완제품 공정의 순번이 마지막 이므로 소트후 조회
      SORT LS_ITAB-T_GONG BY SEQNO DESCENDING.
      READ TABLE LS_ITAB-T_GONG INTO LS_GONG INDEX 1.
* 마스터 오더에 연결된 완제품 공정은 하나이므로 리드테이블로 데이터 구성
      CLEAR GS_CHK_IDX.
      GS_CHK_IDX-TABIX = LS_ITAB-END_SEQNO.
      GS_CHK_IDX-MATNR = LS_ITAB-MATNR .
      GS_CHK_IDX-GCATG = LS_ITAB-GCATG.
      GS_CHK_IDX-ORDNO = LS_ITAB-END_ORDNR.
      GS_CHK_IDX-POSNR = LS_ITAB-END_POSNR.
      READ TABLE LS_GONG-T_CHAIN INTO LS_CHAIN INDEX 1.
      IF SY-SUBRC EQ 0 AND LS_CHAIN-ORDNR IS NOT INITIAL.
        GS_CHK_IDX-REORDNR = LS_CHAIN-ORDNR.
        GS_CHK_IDX-RELINE = LS_CHAIN-POSNR.
        GS_CHK_IDX-REORDTY = LS_CHAIN-ORDTY.
      ENDIF.
      APPEND GS_CHK_IDX TO GT_CHK_IDX.
    ENDLOOP.

  ENDIF.

* - 다른 오더를 선택한 경우 오류 메시지 처리
  REFRESH LT_CHK_DUP.
  LT_CHK_DUP = GT_CHK_IDX.
  SORT LT_CHK_DUP BY ORDNO POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_DUP COMPARING ORDNO POSNR.
  IF LINES( LT_CHK_DUP ) > 1.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '동일한 오더 번호를 선택할 수 있습니다.'(e22).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  CLEAR GS_HEADER_300.
  CLEAR LV_INDEX.
* - 완제품 조장이 생산 진행 중(Payoff) 되었으면 선택 불가
  LOOP AT GT_CHK_IDX INTO GS_CHK_IDX.
    ADD 1 TO LV_INDEX.
    READ TABLE GT_2010 INTO DATA(LS_CHK_2010) WITH KEY ORDNR = GS_CHK_IDX-REORDNR
                                                                        POSNR = GS_CHK_IDX-RELINE
                                                                        ORDTY = GS_CHK_IDX-REORDTY.
    IF SY-SUBRC EQ 0.
      IF LS_CHK_2010-ORDTY = 'PRD' AND LS_CHK_2010-CHK_PRD = ABAP_TRUE.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '완제품 공정 생산이 진행되어 주문을 변경 할 수 없습니다.'(e23).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.

      APPEND LS_CHK_2010 TO PT_2010.
    ENDIF.

    IF LV_INDEX = 1.
      GS_HEADER_300-GCATG = GS_CHK_IDX-GCATG.
      GS_HEADER_300-MATNR = GS_CHK_IDX-MATNR.
      GS_HEADER_300-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = GS_HEADER_300-MATNR ).
      GS_HEADER_300-ORDNR = GS_CHK_IDX-ORDNO.
      GS_HEADER_300-POSNR = GS_CHK_IDX-POSNR.
      SELECT SINGLE * FROM ZGTPPT2000
        INTO @DATA(LS_2000)
       WHERE GRPNR = @GV_GRPNR
          AND ORDNO = @GS_CHK_IDX-ORDNO
          AND POSNR = @GS_CHK_IDX-POSNR.
      GS_HEADER_300-INLENGTH = LS_2000-INLENGTH.

    ENDIF.
    ADD 1 TO GS_HEADER_300-INFACTOR.

  ENDLOOP.

* 선택된 대상의 자재와 조장을 기준으로 판매오더 SM 생산오더 조회
  PERFORM GET_MASTER_ORDER USING GS_HEADER_300.

  IF GT_MAIN_DISP_300[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '변경가능한 주문이 없습니다.'(e24).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  REFRESH GT_CHG_RESULT.

  CALL SCREEN 0300 STARTING AT 5 5 ENDING AT 120 20.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MASTER_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_HEADER_300
*&---------------------------------------------------------------------*
FORM GET_MASTER_ORDER  USING    PS_HEADER_300 LIKE GS_HEADER_300.

  REFRESH GT_MAIN_DISP_300.
* 해당 자재로 판매오더 정보 추출
  PERFORM GET_SO_INFOR USING PS_HEADER_300.
* 해당 자재로 SM 생산오더 정보 추출
  PERFORM GET_SM_INFOR USING PS_HEADER_300.

  PERFORM DEL_CURRENT_JOJANG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_so_infor
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_HEADER_300
*&---------------------------------------------------------------------*
FORM GET_SO_INFOR  USING    PS_HEADER_300 LIKE GS_HEADER_300.

  DATA : BEGIN OF LS_CHK_2010,
           ORDNR TYPE ZGTPPT2010-ORDNR,
           POSNR TYPE  ZGTPPT2010-POSNR,
         END OF LS_CHK_2010.
  DATA : LT_CHK_2010 LIKE TABLE OF LS_CHK_2010.
  DATA : LV_CAL_INFACTOR TYPE ZGTPPT2010-INFACTOR.


  SELECT A~VBELN, A~POSNR, K~KUNNR, A~MATNR, A~VRKME, A~MEINS,
             A~KWMENG AS KWMENG2, "판매단위 수량
             A~KLMENG AS KWMENG,  " 기준단위 수량
             KNA1~NAME1, P~EDATU, A~CUOBJ
    FROM VBAP AS A
    INNER JOIN VBEP AS P
                           ON P~VBELN = A~VBELN
                          AND P~POSNR = A~POSNR
    INNER JOIN VBAK AS K
                           ON K~VBELN = A~VBELN
    INNER JOIN KNA1 AS KNA1
                           ON KNA1~KUNNR = K~KUNNR
*    INNER JOIN ZLET0401 AS D
*                               ON D~VBELN = A~VBELN
*                              AND D~POSNR = A~POSNR
 WHERE A~MATNR = @PS_HEADER_300-MATNR
      AND CONCAT( CONCAT( P~VBELN, P~POSNR ), P~ETENR ) IN
                            ( SELECT CONCAT( CONCAT( VBELN, POSNR ), MAX( ETENR ) )
                                FROM VBEP
                              WHERE VBELN  = A~VBELN
                                 AND POSNR   = A~POSNR
                                 AND WMENG    NE 0
                                 AND LIFSP = ' '
                        GROUP BY VBELN, POSNR )
      AND CONCAT( P~VBELN, P~POSNR ) NOT IN
         ( SELECT  CONCAT( VBELN, VBELP )
              FROM EBKN
            WHERE VBELN = P~VBELN
                AND VBELP = P~POSNR
                AND LOEKZ = ' ' )
      AND A~ABGRU = ''
      AND A~FIXMG = ''
      AND A~WERKS = @P_WERKS
*      AND D~LECFM <> ''
      INTO  TABLE @DATA(LT_MAIN).

  SORT LT_MAIN BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_MAIN COMPARING VBELN POSNR.

  IF LT_MAIN[] IS NOT INITIAL.

    SELECT KDAUF, KDPOS, PLNUM, GSMNG, AVMNG
      FROM PLAF
      INTO TABLE @DATA(LT_PLAF)
      FOR ALL ENTRIES IN @LT_MAIN
    WHERE KDAUF   = @LT_MAIN-VBELN
        AND KDPOS  = @LT_MAIN-POSNR
        AND AUFFX      = 'X'.

*  생산오더 상태값 조회를 위해 마스터테이블 조회
* 생산 오더 상태 삭제(DLFL/TECO/CLSD) 제외
    SELECT KDAUF, KDPOS, AUFNR, POSNR, PSMNG, WEMNG, PSAMG
      FROM AFPO
      INTO TABLE @DATA(LT_AFPO)
      FOR ALL ENTRIES IN @LT_MAIN
    WHERE KDAUF   = @LT_MAIN-VBELN
        AND KDPOS  = @LT_MAIN-POSNR.

* 수량 계산을 위해 기존 생성된 조장구성표 오더 조회
    LOOP AT LT_MAIN INTO DATA(LS_CHK_ORDER).
      APPEND INITIAL LINE TO LT_CHK_2010 ASSIGNING FIELD-SYMBOL(<LS_CHK_2010>).
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = LS_CHK_ORDER-VBELN
        IMPORTING
          OUTPUT = LS_CHK_ORDER-VBELN.
      <LS_CHK_2010>-ORDNR = LS_CHK_ORDER-VBELN.
      <LS_CHK_2010>-POSNR = LS_CHK_ORDER-POSNR.
    ENDLOOP.

    SELECT * FROM ZGTPPT2010
      INTO TABLE @DATA(LT_2010)
     FOR ALL ENTRIES IN @LT_CHK_2010
     WHERE DMORD = @LT_CHK_2010-ORDNR
       AND DMLINE = @LT_CHK_2010-POSNR
       AND DMORDTY = 'SO'.

    SELECT * FROM ZGTPPT2000
      INTO TABLE @DATA(LT_2000)
      FOR ALL ENTRIES IN @LT_CHK_2010
     WHERE WERKS = @P_WERKS
       AND GRPNR NE @GV_GRPNR
       AND MATNR = @PS_HEADER_300-MATNR
       AND ORDNO = @LT_CHK_2010-ORDNR
       AND POSNR = @LT_CHK_2010-POSNR
       AND ZSTATUS <> 'D'.

  ENDIF.

  DATA : LV_VBELN_C(10).
  DATA : LV_POSNR_C(6).

  LOOP  AT LT_MAIN INTO DATA(LS_MAIN).
    CLEAR GS_MAIN_DISP_300.
    IF GS_HEADER_300-ORDNR = LS_MAIN-VBELN AND
      GS_HEADER_300-POSNR = LS_MAIN-POSNR.
      CONTINUE.
    ENDIF.

*  범주
    GS_MAIN_DISP_300-GCATG = '판매오더'.
*  오더번호
    LV_VBELN_C = GS_MAIN_DISP_300-ORDNO = LS_MAIN-VBELN.
    LV_POSNR_C = GS_MAIN_DISP_300-POSNR = LS_MAIN-POSNR.
    __ALPHA_OUT : LV_VBELN_C, LV_POSNR_C.
    CONCATENATE LV_VBELN_C LV_POSNR_C
                  INTO GS_MAIN_DISP_300-REQ_FACTOR SEPARATED BY '/'.
* 목적지
    GS_MAIN_DISP_300-KUNNR = LS_MAIN-KUNNR.
    GS_MAIN_DISP_300-NAME1 = LS_MAIN-NAME1.
* 납품요청일
    GS_MAIN_DISP_300-EDATU = LS_MAIN-EDATU.
* 판매수량(판매단위 기준)
    GS_MAIN_DISP_300-KWMENG = LS_MAIN-KWMENG."기준수량
    GS_MAIN_DISP_300-KWMENG2 = LS_MAIN-KWMENG2." 판매단위 수량
* 판매단위
    GS_MAIN_DISP_300-VRKME = LS_MAIN-VRKME.
* 잔여수량
** 조장, 조장수, 판매조장
    ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
      EXPORTING
        IV_CUOBJ      = LS_MAIN-CUOBJ                 " 구성
      IMPORTING
        EV_ZGTEINDLEN = GS_MAIN_DISP_300-ZGTEINDLEN
        EV_ZGTEFACTOR = GS_MAIN_DISP_300-ZGTEFACTOR
        EV_SO_INDLEN = GS_MAIN_DISP_300-INLENGTH ).
* 잔여조장수

* 잔여수량
    GS_MAIN_DISP_300-SHORT_ORDER  = GS_MAIN_DISP_300-ZGTEINDLEN * GS_MAIN_DISP_300-ZGTEFACTOR.
* 생상오더 미생성 조장수
*    INLENGTH2
* 조장구성, 조장표미생성조장수
*    INLENGTH3
    LOOP AT LT_2000 INTO DATA(LS_2000) WHERE ORDNO = GS_MAIN_DISP_300-ORDNO
                                                    AND POSNR = GS_MAIN_DISP_300-POSNR.

      LOOP AT LT_2010 INTO DATA(LS_2010) WHERE GRPNR = LS_2000-GRPNR
                                                       AND DMORD = GS_MAIN_DISP_300-ORDNO
                                                       AND DMLINE = GS_MAIN_DISP_300-POSNR.

        ADD -1 TO LS_2000-INFACTOR.
      ENDLOOP.
      ADD LS_2000-INFACTOR TO GS_MAIN_DISP_300-INFACTOR3.

    ENDLOOP.

    LOOP AT LT_PLAF INTO DATA(LS_PLAF) WHERE KDAUF = LS_MAIN-VBELN AND KDPOS = LS_MAIN-POSNR.
      READ TABLE LT_2010 INTO LS_2010 WITH KEY DMORD = GS_MAIN_DISP_300-ORDNO
                                               DMLINE = GS_MAIN_DISP_300-POSNR
                                               ORDNR = LS_PLAF-PLNUM
                                               ORDTY = 'PLN'.
      IF SY-SUBRC EQ 0.
        CONTINUE.
      ENDIF.

      CLEAR LV_CAL_INFACTOR.
      LV_CAL_INFACTOR = TRUNC( LS_PLAF-GSMNG / GS_MAIN_DISP_300-ZGTEINDLEN ).

      GS_MAIN_DISP_300-ZGTEFACTOR = GS_MAIN_DISP_300-ZGTEFACTOR - LV_CAL_INFACTOR.
    ENDLOOP.


    LOOP AT LT_AFPO INTO DATA(LS_AFPO) WHERE KDAUF = LS_MAIN-VBELN AND KDPOS = LS_MAIN-POSNR.
      READ TABLE LT_2010 INTO LS_2010 WITH KEY DMORD = GS_MAIN_DISP_300-ORDNO
                                         DMLINE = GS_MAIN_DISP_300-POSNR
                                         ORDNR = LS_AFPO-AUFNR
                                         POSNR+2(4) = LS_AFPO-POSNR
                                         ORDTY = 'PRD'.
      IF SY-SUBRC EQ 0.
        CONTINUE.
      ENDIF.

      SELECT SINGLE * FROM ZGTCVORDSYVAL
         INTO @DATA(LS_ORDSYVAL)
        WHERE AUFNR = @LS_AFPO-AUFNR
          AND DLFL = ''
          AND LKD = ''
          AND CLSD = ''
          AND TECO = ''.
      IF SY-SUBRC EQ 0.
        CLEAR LV_CAL_INFACTOR.
        LV_CAL_INFACTOR = TRUNC( LS_AFPO-PSMNG / GS_MAIN_DISP_300-ZGTEINDLEN ).

        GS_MAIN_DISP_300-ZGTEFACTOR = GS_MAIN_DISP_300-ZGTEFACTOR - LV_CAL_INFACTOR.
      ENDIF.

    ENDLOOP.

    GS_MAIN_DISP_300-INFACTOR2 = GS_MAIN_DISP_300-ZGTEFACTOR - GS_MAIN_DISP_300-INFACTOR3.

    GS_MAIN_DISP_300-SHORT_ORDER = GS_MAIN_DISP_300-ZGTEINDLEN *
                                                     ( GS_MAIN_DISP_300-INFACTOR2 +
                                                       GS_MAIN_DISP_300-INFACTOR3 ).

    IF GS_MAIN_DISP_300-SHORT_ORDER > 0.
      APPEND GS_MAIN_DISP_300 TO GT_MAIN_DISP_300.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SM_INFOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_HEADER_300
*&---------------------------------------------------------------------*
FORM GET_SM_INFOR  USING    PS_HEADER_300 LIKE GS_HEADER_300.

  DATA : BEGIN OF LS_CHK_2010,
           ORDNR TYPE ZGTPPT2010-ORDNR,
           POSNR TYPE  ZGTPPT2010-POSNR,
         END OF LS_CHK_2010.
  DATA : LT_CHK_2010 LIKE TABLE OF LS_CHK_2010.


  SELECT ORDNO, POSNR, GLTRP,  INLENGTH, INFACTOR, GAMNG, MEINS
    FROM ZGTPPT2001
     INTO TABLE @DATA(LT_MAIN)
    WHERE WERKS = @P_WERKS
      AND MATNR = @GS_HEADER_300-MATNR
      AND ZDEL = ' '.

  IF LT_MAIN[] IS NOT INITIAL.
* 수량 계산을 위해 기존 생성된 조장구성표 오더 조회
    LOOP AT LT_MAIN INTO DATA(LS_CHK_ORDER).
      APPEND INITIAL LINE TO LT_CHK_2010 ASSIGNING FIELD-SYMBOL(<LS_CHK_2010>).
      <LS_CHK_2010>-ORDNR = LS_CHK_ORDER-ORDNO.
      <LS_CHK_2010>-POSNR = LS_CHK_ORDER-POSNR.
    ENDLOOP.

    SELECT * FROM ZGTPPT2010
      INTO TABLE @DATA(LT_2010)
     FOR ALL ENTRIES IN @LT_CHK_2010
     WHERE DMORD = @LT_CHK_2010-ORDNR
       AND DMLINE = @LT_CHK_2010-POSNR
       AND DMORDTY = 'SO'.

    SELECT * FROM ZGTPPT2000
      INTO TABLE @DATA(LT_2000)
      FOR ALL ENTRIES IN @LT_CHK_2010
     WHERE WERKS = @P_WERKS
       AND MATNR = @PS_HEADER_300-MATNR
       AND ORDNO = @LT_CHK_2010-ORDNR
       AND POSNR = @LT_CHK_2010-POSNR
       AND ZSTATUS <> 'D'.

  ENDIF.

  DATA : LV_ORDNO_C(12).
  DATA : LV_POSNR_C(6).

  LOOP  AT LT_MAIN INTO DATA(LS_MAIN).
    CLEAR GS_MAIN_DISP_300.
    IF GS_HEADER_300-ORDNR = LS_MAIN-ORDNO AND
      GS_HEADER_300-POSNR = LS_MAIN-POSNR.
      CONTINUE.
    ENDIF.
*  범주
    GS_MAIN_DISP_300-GCATG = '생산오더'.
*  오더번호
    LV_ORDNO_C = GS_MAIN_DISP_300-ORDNO = LS_MAIN-ORDNO.
    LV_POSNR_C = GS_MAIN_DISP_300-POSNR = LS_MAIN-POSNR.
    __ALPHA_OUT : LV_ORDNO_C, LV_POSNR_C.
    CONCATENATE LV_ORDNO_C LV_POSNR_C
                  INTO GS_MAIN_DISP_300-REQ_FACTOR SEPARATED BY '/'.

* 납품요청일
    GS_MAIN_DISP_300-EDATU = LS_MAIN-GLTRP.
* 판매수량(기준)
    GS_MAIN_DISP_300-KWMENG = LS_MAIN-GAMNG."기준수량
* 판매단위
    GS_MAIN_DISP_300-VRKME = LS_MAIN-MEINS.
* 잔여수량
** 조장, 조장수, 판매조장
    GS_MAIN_DISP_300-ZGTEINDLEN = LS_MAIN-INLENGTH.
    GS_MAIN_DISP_300-ZGTEFACTOR = LS_MAIN-INFACTOR.


* 잔여수량

* 생상오더 미생성 조장수
*    INLENGTH2
* 조장구성, 조장표미생성조장수
*    INLENGTH3
    GS_MAIN_DISP_300-INFACTOR2 = GS_MAIN_DISP_300-ZGTEFACTOR.
    LOOP AT LT_2000 INTO DATA(LS_2000) WHERE ORDNO = GS_MAIN_DISP_300-ORDNO
                                                    AND POSNR = GS_MAIN_DISP_300-POSNR.

      LOOP AT LT_2010 INTO DATA(LS_2010) WHERE GRPNR = LS_2000-GRPNR
                                                       AND DMORD = GS_MAIN_DISP_300-ORDNO
                                                       AND DMLINE = GS_MAIN_DISP_300-POSNR.

        ADD -1 TO LS_2000-INFACTOR.
        ADD -1 TO GS_MAIN_DISP_300-INFACTOR2.
      ENDLOOP.
      ADD LS_2000-INFACTOR TO GS_MAIN_DISP_300-INFACTOR3.

    ENDLOOP.

    GS_MAIN_DISP_300-INFACTOR2 = GS_MAIN_DISP_300-INFACTOR2 - GS_MAIN_DISP_300-INFACTOR3.

    GS_MAIN_DISP_300-SHORT_ORDER = GS_MAIN_DISP_300-ZGTEINDLEN *
                                                     ( GS_MAIN_DISP_300-INFACTOR2 +
                                                       GS_MAIN_DISP_300-INFACTOR3 ).

    IF GS_MAIN_DISP_300-SHORT_ORDER > 0.
      APPEND GS_MAIN_DISP_300 TO GT_MAIN_DISP_300.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0300 .

  CREATE OBJECT GO_DOCKING_0300
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
  CREATE OBJECT GO_SPLITTER_300
    EXPORTING
      PARENT  = GO_DOCKING_0300
      ROWS    = 2
      COLUMNS = 1.

  GO_SPLITTER_300->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    20 ).             " Height

* top 컨테이너
  CALL METHOD GO_SPLITTER_300->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_TOP_0300.
* bottom 컨테이너
  CALL METHOD GO_SPLITTER_300->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0300.


  CREATE OBJECT GO_GRID_0300
    EXPORTING
      I_PARENT      = GO_CONTAIN_0300
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0300 .

  CLEAR GS_LAYOUT_0300.
  GS_LAYOUT_0300-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0300-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0300-NO_ROWMARK   = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0300 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2140TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_300'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0300.
*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0300[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_300
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0300 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'CHECK'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0300 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'CHECK'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '　　'.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-EDIT = ABAP_TRUE.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0300 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'REQ_FACTOR'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0300 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'REQ_FACTOR'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'(f17).
    <LS_FCAT>-COL_POS = 3.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '50'.
    <LS_FCAT>-JUST = 'L'.
    <LS_FCAT>-KEY = ABAP_TRUE.
  ENDIF.

  LOOP AT GT_FIELDCAT_0300 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'GCATG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '범주'(f20).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'KUNNR'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '목적지'(f29).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'ZGTEINDLEN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장'(f26).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'ZGTEFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '잔여조장수'(f30).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'SHORT_ORDER'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '잔여수량'(f31).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'EDATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품요청일'(f24).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'KWMENG'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'KWMENG2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매수량'(f14).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'VRKME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매단위'(f16).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(f27).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매조장'(f33).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '선택조장수'(f32).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-NO_ZERO = ABAP_TRUE.
        <LS_FCAT>-DECIMALS_O = 0.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'ORDNO'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'POSNR'.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        CLEAR <LS_FCAT>-KEY.
      WHEN 'DISPO' OR 'CUOBJ' OR 'VBTYP' OR 'SHORT_ORDER2' OR 'INFACTOR2' OR 'INFACTOR3'.
        <LS_FCAT>-TECH = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0300 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0300
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
*& Form CALL_GRID_0300_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0300_DISPLAY .

  CALL METHOD GO_GRID_0300->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0300
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0300
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_300
      IT_FIELDCATALOG      = GT_FIELDCAT_0300.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0300->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0300->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  IF GO_DD_DOCU_0300 IS BOUND.
    CALL METHOD GO_DD_DOCU_0300->INITIALIZE_DOCUMENT.
  ELSE.
    CREATE OBJECT GO_DD_DOCU_0300
      EXPORTING
        STYLE = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD GO_GRID_0300->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DD_DOCU_0300.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PV_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM SET_TITLE_0300  CHANGING PV_DYNDOC_ID  TYPE REF TO  CL_DD_DOCUMENT.

  DATA : LV_TEXT(255) TYPE C.
  DATA : LV_ORDNO_C(12).
  DATA : LV_POSNR_C(6).
  DATA : LV_MATNR_C(40).
  DATA : LV_MAKTX TYPE MAKTX.
  DATA : LV_STRING TYPE STRING.
  DATA : LV_PAMNG TYPE I.
  DATA : LV_PAMNG_C(20).
  DATA : LV_INLENGTH_I TYPE I.
  DATA : LV_INLENGTH_C(11).
  DATA : LV_INFACTOR_I TYPE I.
  DATA : LV_INFACTOR_C(11).

* 기존오더
  LV_ORDNO_C = GS_HEADER_300-ORDNR.
  LV_POSNR_C = GS_HEADER_300-POSNR.
  __ALPHA_OUT : LV_ORDNO_C, LV_POSNR_C.
  CONCATENATE LV_ORDNO_C LV_POSNR_C INTO LV_TEXT SEPARATED BY '/'.
  CONCATENATE '기존오더 :' LV_TEXT INTO LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

* 기존수량
  CLEAR LV_TEXT.
  LV_PAMNG = GS_HEADER_300-INLENGTH * GS_HEADER_300-INFACTOR.
  WRITE LV_PAMNG TO LV_PAMNG_C.

  LV_INLENGTH_I = GS_HEADER_300-INLENGTH.
  LV_INLENGTH_C = LV_INLENGTH_I.

  LV_INFACTOR_I = GS_HEADER_300-INFACTOR.
  LV_INFACTOR_C = LV_INFACTOR_I.
  CONDENSE : LV_PAMNG_C, LV_INLENGTH_C, LV_INFACTOR_C.
  LV_STRING = '(' && LV_INLENGTH_C && 'X' && LV_INFACTOR_C && ')'.

  CONCATENATE '기존수량 :' LV_PAMNG_C 'M' LV_STRING INTO LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.

* 제품
  CLEAR LV_TEXT.
  LV_MATNR_C = GS_HEADER_300-MATNR.
  LV_MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = GS_HEADER_300-MATNR ).
  __ALPHA_OUT : LV_MATNR_C.
  CONCATENATE LV_MATNR_C LV_MAKTX INTO LV_TEXT SEPARATED BY '/'.
  CONCATENATE '제품 :' LV_TEXT INTO LV_TEXT SEPARATED BY SPACE.

  "텍스트 추가
  CALL METHOD PV_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_FONTSIZE = '20'.

  CALL METHOD PV_DYNDOC_ID->NEW_LINE.



  "위쪽에 추가한 텍스트 출력
  CALL METHOD GO_DD_DOCU_0300->DISPLAY_DOCUMENT
    EXPORTING
      PARENT = GO_CONTAIN_TOP_0300.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_AND_CHANGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_AND_CHANGE .

  DATA : LV_MESSAGE(100).
  DATA : LV_CHK_ERR.
*  필드 빈값 체크
  CLEAR LV_MESSAGE.

  PERFORM SCREEN_0300_CHK CHANGING LV_MESSAGE.

  IF LV_MESSAGE IS NOT INITIAL.
    MESSAGE I003 WITH LV_MESSAGE.
    RETURN.
  ENDIF.

  PERFORM PROC_CHG_MASTERORDER.

  CALL METHOD GO_DOCKING_0300->FREE.
  CLEAR : GO_DOCKING_0300, GO_CONTAIN_TOP_0300, GO_CONTAIN_0300.
  CLEAR : GO_DD_DOCU_0300, GO_GRID_0300.
  CALL METHOD CL_GUI_CFW=>FLUSH.
  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCREEN_0300_CHK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM SCREEN_0300_CHK  CHANGING PV_MESSAGE.

  DATA : LV_CNT_JOJANG TYPE I.

  LOOP AT GT_MAIN_DISP_300 INTO GS_MAIN_DISP_300 WHERE CHECK = ABAP_TRUE.
    IF GS_MAIN_DISP_300-ZGTEINDLEN NE GS_HEADER_300-INLENGTH.
      PV_MESSAGE = '기존 오더 조장과 다른 조장을 선택 할 수 없습니다.'(e25).
      RETURN.
    ENDIF.

    IF GS_MAIN_DISP_300-INFACTOR = 0.
      ADD 1 TO LV_CNT_JOJANG.
    ELSE.
      ADD GS_MAIN_DISP_300-INFACTOR TO LV_CNT_JOJANG..
    ENDIF.

  ENDLOOP.

  IF LV_CNT_JOJANG NE GS_HEADER_300-INFACTOR.
    PV_MESSAGE = '변경할 조장 수는 같아야 합니다.'(e26).
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CHG_MASTERORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CHG_MASTERORDER .

  REFRESH GT_CHG_RESULT.

  LOOP AT GT_MAIN_DISP_300 INTO GS_MAIN_DISP_300 WHERE CHECK = ABAP_TRUE.
    APPEND INITIAL LINE TO GT_CHG_RESULT ASSIGNING FIELD-SYMBOL(<LS_RESULT>).
    MOVE-CORRESPONDING GS_MAIN_DISP_300 TO <LS_RESULT>.
    IF GS_MAIN_DISP_300-INFACTOR = 0.
      <LS_RESULT>-INFACTOR = 1.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_GRPNO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DEL_GRPNO .

  DATA : BEGIN OF LS_CHK_GRPNR,
           GRPNR TYPE ZGTPPT2000-GRPNR,
         END OF LS_CHK_GRPNR.
  DATA : LT_CHK_GRPNR LIKE TABLE OF LS_CHK_GRPNR.

  DATA : LV_RESULT  TYPE CHAR01,
         LV_MESSAGE TYPE CHAR100,
         LV_CHK_CON TYPE CHAR01.

* 선택된 조장번호 삭제
  LT_CHK_GRPNR = VALUE #( FOR WA_MAIN_DISP IN GT_MAIN_DISP WHERE ( CHECK = ABAP_TRUE ) ( GRPNR = WA_MAIN_DISP-GRPNR ) ).

  SORT LT_CHK_GRPNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_GRPNR.

  IF LINES( LT_CHK_GRPNR ) = 0.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 조장구성표 번호가 없습니다.'.
    RETURN.
  ENDIF.

  IF LINES( LT_CHK_GRPNR ) > 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 조장구성표 번호만 선택 가능합니다.'.
    RETURN.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 조장구성표 번호를 삭제하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  SELECT COUNT(*)
    FROM ZGTPPT2010
    FOR ALL ENTRIES IN LT_CHK_GRPNR
   WHERE GRPNR = LT_CHK_GRPNR-GRPNR.
  IF SY-SUBRC = 0.
    MESSAGE S003 DISPLAY LIKE 'E'
                 WITH '조장 구성되어 오더 생성된 조장표는 삭제 할 수 없습니다.'.
    RETURN.
  ENDIF.

  LOOP AT LT_CHK_GRPNR INTO DATA(LS_GRPNR).
    UPDATE ZGTPPT2000
       SET ZSTATUS = 'D'
     WHERE GRPNR = LS_GRPNR.
    IF SY-SUBRC = 0.
      COMMIT WORK AND WAIT.
    ELSE.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF SY-SUBRC = 0.
    PERFORM GET_PROC.
    PERFORM REFRESH_GRID USING GO_GRID_0100.

    MESSAGE S003 DISPLAY LIKE 'S'
                 WITH '조장구성표 삭제되었습니다.'.
  ELSE.
    PERFORM GET_PROC.
    PERFORM REFRESH_GRID USING GO_GRID_0100.

    MESSAGE S003 DISPLAY LIKE 'E'
                 WITH '조장구성표 삭제 중 오류가 발생했습니다.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_CHG_2010
*&---------------------------------------------------------------------*
FORM SET_TABLE  TABLES   PT_CHG_2010 STRUCTURE ZGTPPT2010.

  DATA : LV_AUFNR TYPE AUFNR.
  DATA : LV_POSNR TYPE AFPO-POSNR.
  DATA : LV_PLNUM TYPE PLNUM.
  DATA : LV_KDAUF TYPE VBAP-VBELN.
  DATA : LV_KDPOS TYPE VBAP-POSNR.
  DATA : LV_SOBKZ TYPE AFPO-SOBKZ.
  DATA : LV_KZBWS TYPE AFPO-KZBWS.

  LOOP AT PT_CHG_2010.

    CLEAR : LV_KDAUF, LV_KDPOS, LV_SOBKZ, LV_KZBWS.
    CASE PT_CHG_2010-DMORDTY.
      WHEN 'SO'.
        LV_KDAUF = PT_CHG_2010-DMORD.
        LV_KDPOS = PT_CHG_2010-DMLINE.
        LV_SOBKZ = 'E'.
        LV_KZBWS = 'A'.

      WHEN 'SM'.
    ENDCASE.

    CASE PT_CHG_2010-ORDTY.
      WHEN 'PLN'.
        LV_PLNUM = PT_CHG_2010-ORDNR.
        UPDATE PLAF SET KDAUF = LV_KDAUF
                             KDPOS = LV_KDPOS
                             SOBKZ = LV_SOBKZ
                             KZBWS = LV_KZBWS
          WHERE PLNUM = LV_PLNUM.
        IF SY-SUBRC EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.

      WHEN 'PRD'.
        LV_AUFNR = PT_CHG_2010-ORDNR.
        LV_POSNR = PT_CHG_2010-POSNR + 0.

        UPDATE AFPO SET KDAUF = LV_KDAUF
                             KDPOS = LV_KDPOS
                             SOBKZ = LV_SOBKZ
                             KZBWS = LV_KZBWS
          WHERE AUFNR = LV_AUFNR
             AND POSNR = LV_POSNR.
        IF SY-SUBRC EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.

    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EDIT_ADLENGTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EDIT_ADLENGTH .

  DATA : LT_2010 LIKE GT_2010.
  DATA : LV_CHK_ERR.
  DATA : LO_JOJANG TYPE REF TO ZGTPP_CL_ROUTING_GAON.
  DATA : LV_MESSAGE TYPE CHAR100.

  PERFORM CHK_EDIT_ADLENGTH TABLES LT_2010
                                       CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF LT_2010[] IS INITIAL.
    RETURN.
  ENDIF.

  CLEAR : GV_ADLENGTH, GV_ADTYPE.

  LOOP AT LT_2010 ASSIGNING FIELD-SYMBOL(<LS_2010>).
    IF SY-TABIX = 1.
      GV_ADLENGTH = <LS_2010>-ADLENGTH.
      GV_ADTYPE = <LS_2010>-ADTYPE.
    ELSE.
      IF GV_ADLENGTH NE <LS_2010>-ADLENGTH.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '여장정보가 다른 오더가 있습니다.'(e34).
        RETURN.
      ENDIF.
      IF GV_ADTYPE NE <LS_2010>-ADTYPE.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '여장정보가 다른 오더가 있습니다.'(e34).
        RETURN.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CLEAR GV_CHK_EXIT.
  CALL SCREEN '0210' STARTING AT 10 5 ENDING AT 90 9.

  CHECK GV_CHK_EXIT IS INITIAL.

  CREATE OBJECT LO_JOJANG
    EXPORTING
      IV_WERKS              = P_WERKS                 " 플랜트
      IV_GRPNR              = GV_GRPNR                 " 조장 구성표 번호
      IT_MAIN               = GT_MAKE_DISPLAY
      IT_SEQ_ROUTING_HEADER = GT_SEQ_ROUTING_HEADER
      IT_SEQ_ROUTING_SUB    = GT_SEQ_ROUTING_SUB
      IT_MAKED_2010         = GT_2010.

* 완제품 여장의 경우 시료여장으로 전부 대체
  IF LINE_EXISTS( LT_2010[ DMORDTY = 'SO' ] ) OR LINE_EXISTS( LT_2010[ DMORDTY = 'SM' ] ).
    GV_ADTYPE = 'A'.
  ENDIF.

  LV_MESSAGE = LO_JOJANG->EDIT_ADLENGTH(
    EXPORTING
      IV_ADTYPE   = GV_ADTYPE                 " 추가여장 유형
      IV_ADLENGTH = GV_ADLENGTH                 " 추가여장
      IT_2010     =  LT_2010   ).

  IF GV_CHK_EXIST_BWD = ABAP_TRUE AND LO_JOJANG->MT_MESSAGE_BWD[] IS NOT INITIAL.
    CALL FUNCTION 'ZGTPP_UTILL_TEXTEDIT'
      EXPORTING
        IV_MODE  = '1'
        IV_TITLE = '신선작업지시 초과수량'
      CHANGING
        CT_TEXT  = LO_JOJANG->MT_MESSAGE_BWD.
  ENDIF.

  IF LV_MESSAGE IS NOT INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MESSAGE.
  ELSE.

*  변경정보 MES전송
    ZGTPP_CL_ROUTING=>SEND_CHG_MES(
      IV_WERKS = P_WERKS           " 플랜트
      IV_SPGCD = P_SPGCD          " SPG 코드
      IV_GRPNR = GV_GRPNR ).    " 조장 구성표 번호


    LV_MESSAGE = '여장 추가 완료 되었습니다.'.
    MESSAGE S006 WITH LV_MESSAGE.
    PERFORM REFRESH_SCREEN_201.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_CURRENT_JOJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DEL_CURRENT_JOJANG .

  DATA : LV_TABIX TYPE I.

  SELECT * FROM ZGTPPT2000
    INTO TABLE @DATA(LT_2000)
    WHERE GRPNR = @GV_GRPNR
      AND ZSTATUS <> 'D'.

  LOOP AT GT_MAIN_DISP_300 INTO DATA(LS_DSP_300).
    LV_TABIX = SY-TABIX.

    READ TABLE GT_CHK_IDX TRANSPORTING NO FIELDS WITH KEY ORDNO = LS_DSP_300-ORDNO
                                                                                 POSNR = LS_DSP_300-POSNR.
    IF SY-SUBRC EQ 0.
      DELETE GT_MAIN_DISP_300 INDEX LV_TABIX.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_STANDARD_ADLENGTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_STANDARD_ADLENGTH .

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_CHK_CHAR TYPE ATWRT.
  DATA : LV_FIELDNAME TYPE FIELDNAME.

  DATA : BEGIN OF LS_ORDNO,
           ORDNO TYPE ZGTPPT2070-ORDNO,
           POSNR TYPE ZGTPPT2070-POSNR,
         END OF LS_ORDNO.
  DATA : LT_ORDNO LIKE TABLE OF LS_ORDNO.

  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_NUM(2) TYPE N.

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.

  CLEAR GS_STANDARD_ADLENGTH.
  CLEAR GV_CHK_ALL.

  GO_GRID_0201->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  IF LT_COLUMN[] IS NOT INITIAL.
    GV_CHK_ALL = ABAP_TRUE.
    IF LINES( LT_COLUMN ) > 1.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 공정만 선택 가능합니다.'.
      RETURN.
    ENDIF.
    LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).

      SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
      READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 2.
      LV_CHART = LS_STRING.

      IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
        MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 컬럼이 선택되었습니다.'.
        RETURN.
      ENDIF.

      READ TABLE LT_STRING INTO LS_STRING INDEX 1.
      LV_SEQNO = LS_STRING + 0.

      LOOP AT GT_SEQ_ROUTING_SUB INTO GS_SEQ_ROUTING_SUB.
        READ TABLE GS_SEQ_ROUTING_SUB-T_ROUTING INTO DATA(LS_ROUTING) WITH KEY SEQNO = LV_SEQNO.
        LOOP AT LS_ROUTING-T_BOM INTO DATA(LS_BOM).
          IF GS_STANDARD_ADLENGTH-MATNR IS INITIAL.
            GS_STANDARD_ADLENGTH-MATNR = LS_BOM-MATNR.
          ELSE.
            IF GS_STANDARD_ADLENGTH-MATNR NE LS_BOM-MATNR.
              MESSAGE S003 DISPLAY LIKE 'E' WITH '동일한 자재만 표준여장 지정가능합니다.'.
              RETURN.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

*     기존 저장된 표준여장이 있으면 기존 여장 보여준다.
      SELECT SINGLE * FROM ZGTPPT2070
       WHERE GRPNR = @GV_GRPNR
         AND ORDNO = ' '
         AND ( POSNR IS INITIAL
          OR    POSNR = '000000' )
         AND MATNR = @GS_STANDARD_ADLENGTH-MATNR
        INTO @DATA(LS_ZGTPPT2070).
      IF SY-SUBRC EQ 0.
        GS_STANDARD_ADLENGTH-QLENGTH = LS_ZGTPPT2070-QLENGTH.
        GS_STANDARD_ADLENGTH-CLENGTH = LS_ZGTPPT2070-CLENGTH.
      ENDIF.
    ENDLOOP.
  ELSE.
    GO_GRID_0201->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

    LOOP AT LT_CELLS INTO DATA(LS_CELLS).
      READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
      IF SY-SUBRC EQ 0.

        SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE LT_STRING.
        READ TABLE LT_STRING INTO LS_STRING INDEX 2.
        LV_CHART = LS_STRING.

        IF NOT LINE_EXISTS( GT_SEQ_ROUTING[ CHART = LV_CHART ] ).
          MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'.
          RETURN.
        ENDIF.
      ENDIF.

      READ TABLE LT_STRING INTO LS_STRING INDEX 1.
      LV_SEQNO = LS_STRING + 0.

*  선택된 필드의 오더정보 찾기
      READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
      IF SY-SUBRC EQ 0.
        IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
        ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.

        READ TABLE  GT_SEQ_ROUTING INTO LS_ROUTING WITH KEY SEQNO = LV_SEQNO.

        CLEAR LV_NUM.
        CLEAR LV_FIELDNAME.
        LV_NUM =  LS_ROUTING-SEQNO + 0.
        LV_FIELDNAME = LV_NUM && '_SEQNO'.

        IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
        ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.
        IF <LV_GONGSEQ> IS NOT ASSIGNED. " 공정을 못찾으면 종료
          RETURN.
        ELSE.
          IF <LV_GONGSEQ> = 0. " 해당 공정 순번이 비어있다면 오더가 없다는 의미 다음순번
            CONTINUE.
          ENDIF.
        ENDIF.

        READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
        READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
        READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.
        IF GS_STANDARD_ADLENGTH-MATNR IS INITIAL.
          GS_STANDARD_ADLENGTH-MATNR = LS_CHAIN-SEQ_MATNR.
        ELSE.
          IF GS_STANDARD_ADLENGTH-MATNR NE LS_CHAIN-SEQ_MATNR.
            MESSAGE S003 DISPLAY LIKE 'E' WITH '동일한 자재만 표준여장 지정가능합니다.'.
            RETURN.
          ENDIF.
        ENDIF.

        IF LV_CHK_CHAR IS INITIAL.
          LV_CHK_CHAR = LS_GONG-CHART.
        ELSE.
          IF LS_GONG-CHART NE LS_GONG-CHART.
            MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 공정만 선택 가능합니다.'.
            RETURN.
          ENDIF.
        ENDIF.

        APPEND INITIAL LINE TO LT_ORDNO ASSIGNING FIELD-SYMBOL(<LS_ORDNO>) .
        <LS_ORDNO>-ORDNO = LS_ITAB-END_ORDNR.
        <LS_ORDNO>-POSNR = LS_ITAB-END_POSNR.

      ENDIF.

    ENDLOOP.

    SORT LT_ORDNO BY ORDNO POSNR.
    DELETE ADJACENT DUPLICATES FROM LT_ORDNO COMPARING ORDNO POSNR.
    IF LINES( LT_ORDNO ) > 1.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '동일한 판매오더, 품목만 선택할 수 있습니다.'.
      RETURN.
    ENDIF.

*     기존 저장된 표준여장이 있으면 기존 여장 보여준다.
    READ TABLE LT_ORDNO INTO LS_ORDNO INDEX 1.

    GS_STANDARD_ADLENGTH-VBELN = LS_ORDNO-ORDNO.
    GS_STANDARD_ADLENGTH-POSNR = LS_ORDNO-POSNR.
    READ TABLE GT_MAIN_DISP INTO DATA(LS_TEMP_DATA) WITH KEY GRPNR = GV_GRPNR
                                                                                  ORDNO = LS_ORDNO-ORDNO
                                                                                  POSNR = LS_ORDNO-POSNR.
    IF SY-SUBRC EQ 0.
      GS_STANDARD_ADLENGTH-INLENGTH = LS_TEMP_DATA-INLENGTH.
    ENDIF.


    SELECT SINGLE * FROM ZGTPPT2070
      INTO LS_ZGTPPT2070
     WHERE GRPNR = GV_GRPNR
         AND ORDNO = LS_ORDNO-ORDNO
         AND POSNR = LS_ORDNO-POSNR
         AND MATNR = GS_STANDARD_ADLENGTH-MATNR.
    IF SY-SUBRC EQ 0.
      GS_STANDARD_ADLENGTH-QLENGTH = LS_ZGTPPT2070-QLENGTH.
      GS_STANDARD_ADLENGTH-CLENGTH = LS_ZGTPPT2070-CLENGTH.
    ELSE.
*     기존 저장된 표준여장이 있으면 기존 여장 보여준다.
      SELECT SINGLE * FROM ZGTPPT2070
       WHERE GRPNR = @GV_GRPNR
         AND ORDNO = ' '
         AND ( POSNR IS INITIAL
          OR    POSNR = '000000' )
         AND MATNR = @GS_STANDARD_ADLENGTH-MATNR
        INTO @LS_ZGTPPT2070.
      IF SY-SUBRC EQ 0.
        GS_STANDARD_ADLENGTH-QLENGTH = LS_ZGTPPT2070-QLENGTH.
        GS_STANDARD_ADLENGTH-CLENGTH = LS_ZGTPPT2070-CLENGTH.
      ENDIF.
    ENDIF.
  ENDIF.

  IF GV_CHK_ALL IS INITIAL.
    CALL SCREEN '0250' STARTING AT 5 5 ENDING AT 76 12.
  ELSE.
    CALL SCREEN '0250' STARTING AT 5 5 ENDING AT 76 10.
  ENDIF.
  IF GS_STANDARD_ADLENGTH IS INITIAL.
    RETURN.
  ENDIF.

  CLEAR LS_ZGTPPT2070.
  LS_ZGTPPT2070-GRPNR = GV_GRPNR.
  LS_ZGTPPT2070-ORDNO = GS_STANDARD_ADLENGTH-VBELN.
  LS_ZGTPPT2070-POSNR = GS_STANDARD_ADLENGTH-POSNR.
  LS_ZGTPPT2070-MATNR = GS_STANDARD_ADLENGTH-MATNR.
  LS_ZGTPPT2070-QLENGTH = GS_STANDARD_ADLENGTH-QLENGTH.
  LS_ZGTPPT2070-CLENGTH = GS_STANDARD_ADLENGTH-CLENGTH.

  MODIFY ZGTPPT2070 FROM LS_ZGTPPT2070.
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ENDIF.

  MESSAGE S003 WITH '표준여장이 변경되었습니다. 조장 구성표를 다시 작성하세요.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_EDIT_ADLENGTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_EDIT_ADLENGTH  TABLES   PT_2010 LIKE GT_2010
                                              CHANGING PV_CHK_ERR.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_NUM(2) TYPE N.
  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_2010_CHK LIKE TABLE OF GS_2010.
  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LT_2010_DEV LIKE TABLE OF GS_2010.
  DATA : LT_2010_PRE LIKE TABLE OF GS_2010.
  DATA : LV_STRING     TYPE  STRING.
  DATA : LV_TABIX TYPE I.

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.

  CLEAR : PV_CHK_ERR.
  REFRESH PT_2010[].

  GO_GRID_0201->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  GO_GRID_0201->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL AND LT_CELLS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'(e01).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  IF LINES( LT_COLUMN ) > 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 공정만 선택 가능합니다.'(e28).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
    READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 2.
    LV_CHART = LS_STRING.

    IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
      MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 컬럼이 선택되었습니다.'(e02).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
* 선택된 컬럼의 공정 유형 전부 추출
    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY CHART = LV_CHART
                                                                                        SEQNO = LV_SEQNO.

    LT_2010 = VALUE #( FOR WA_2010 IN GT_2010 WHERE ( GONG_CD = LV_CHART AND GONG_SEQ = LS_ROUTING-GONG_SEQ )
                                                   ( CORRESPONDING #( WA_2010 ) ) ).

    APPEND LINES OF LT_2010 TO PT_2010.
  ENDLOOP.


  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.

      SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE LT_STRING.
      READ TABLE LT_STRING INTO LS_STRING INDEX 2.
      LV_CHART = LS_STRING.

      IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
        MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'(e02).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY CHART = LV_CHART
                                                                                          SEQNO = LV_SEQNO.

*  선택된 필드의 오더정보 찾기
    READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
      ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.
      IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
      ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO <LV_LINE>.

      CLEAR LV_NUM.
      CLEAR LV_FIELDNAME.
      LV_NUM =  LS_ROUTING-SEQNO + 0.
      LV_FIELDNAME = LV_NUM && '_SEQNO'.

      IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.
      IF <LV_GONGSEQ> IS NOT ASSIGNED. " 공정을 못찾으면 종료
        RETURN.
      ELSE.
        IF <LV_GONGSEQ> = 0. " 해당 공정 순번이 비어있다면 오더가 없다는 의미 다음순번
          CONTINUE.
        ENDIF.
      ENDIF.

      READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
      READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
      READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.

* 중복 필드라면 대상이 아님
      IF LS_CHAIN-CHK_DUP EQ ABAP_TRUE.
        CONTINUE.
      ENDIF.

      IF LS_CHAIN-ORDNR IS INITIAL.
        CONTINUE.
      ENDIF.
      READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = LS_CHAIN-ORDNR
                                                                      POSNR = LS_CHAIN-POSNR
                                                                       ORDTY = LS_CHAIN-ORDTY.
      IF SY-SUBRC EQ 0.
        APPEND LS_2010 TO PT_2010.
      ENDIF.
    ENDIF.
  ENDLOOP.



  SORT PT_2010 BY GONG_CD ORDNR POSNR ORDTY.
  DELETE ADJACENT DUPLICATES FROM PT_2010 COMPARING GONG_CD ORDNR POSNR ORDTY.


  REFRESH LT_2010_CHK.
  LT_2010_CHK = PT_2010[].
  SORT LT_2010_CHK BY GONG_CD.
  DELETE ADJACENT DUPLICATES FROM LT_2010_CHK COMPARING GONG_CD.

  IF LINES( LT_2010_CHK ) > 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 공정만 선택 가능합니다.'(e28).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT PT_2010.
* 1. 생산오더 유형만 가능
    IF PT_2010-ORDTY NE 'PRD'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '생산 오더 유형만 여장을 추가 할 수 있습니다.'(e30).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

* 2. 해당 생산 오더나 이전 공정 생산 오더들 가동중인지 확인.
    IF PT_2010-CHK_PRD IS NOT INITIAL.
      CLEAR LV_STRING.
      CLEAR GS_SEQ_ROUTING_HEADER.
      READ TABLE GT_SEQ_ROUTING_HEADER INTO GS_SEQ_ROUTING_HEADER WITH KEY GONG_SEQ = PT_2010-GONG_SEQ.
      CLEAR LV_NUM.
      LV_NUM = LS_ROUTING-SEQNO + 0.
      LV_STRING = '(' && LV_NUM && '_' && LS_ROUTING-CHART_VAL && ')'.

      MESSAGE S006 DISPLAY LIKE 'E' WITH LV_STRING PT_2010-ORDNR '오더는 생산 진행중으로 여장을 추가 할 수 없습니다.'(e31).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

* 이전 공정 생산 오더체인정보 추출
    REFRESH LT_2010_DEV.
    LT_2010_DEV = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( ORDNR = PT_2010-ORDNR )
                                     ( CORRESPONDING #( LW_2010 ) ) ).


    DO.

      REFRESH LT_2010_PRE.

      LOOP AT LT_2010_DEV INTO DATA(LS_DEV).
        READ TABLE GT_2010 INTO DATA(LS_PRE_TEMP) WITH KEY DMORD = LS_DEV-ORDNR
                                                                       DMLINE = LS_DEV-POSNR
                                                                       DMORDTY = LS_DEV-ORDTY.
        IF SY-SUBRC EQ 0.

          REFRESH LT_2010_CHK.
          LT_2010_CHK = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( DMORD = LS_PRE_TEMP-DMORD
                                                                             AND   DMLINE = LS_PRE_TEMP-DMLINE
                                                                             AND   DMORDTY = LS_PRE_TEMP-DMORDTY )
                                           ( CORRESPONDING #( LW_2010 ) ) ).

          IF LT_2010_CHK IS NOT INITIAL.
            LOOP AT LT_2010_CHK INTO DATA(LS_CHK_2010).

              IF LS_CHK_2010-ORDTY ='PO'.
                MESSAGE S006 DISPLAY LIKE 'E' WITH '이전 공정 중 임가공 오더가 있어 여장을 추가 할 수 없습니다.'(e62).
                PV_CHK_ERR = ABAP_TRUE.
                RETURN.
              ENDIF.

              IF LS_CHK_2010-ORDTY ='UPR'.
                MESSAGE S006 DISPLAY LIKE 'E' WITH '이전 공정 중 구매요청이 있어 여장을 추가 할 수 없습니다.'(e63).
                PV_CHK_ERR = ABAP_TRUE.
                RETURN.
              ENDIF.

              READ TABLE LT_2010_PRE INTO DATA(LS_2010_PRE) WITH KEY ORDNR = LS_CHK_2010-ORDNR
                                                                                         POSNR = LS_CHK_2010-POSNR
                                                                                         ORDTY = LS_CHK_2010-ORDTY
                                                                                         BINARY SEARCH.
              IF SY-SUBRC NE 0.
                LV_TABIX = SY-TABIX.
                IF LS_CHK_2010-CHK_PRD IS NOT INITIAL.
                  MESSAGE S006 DISPLAY LIKE 'E' WITH '이전 공정 중 생산 중인 오더가 있어 여장을 추가 할 수 없습니다.'(e32).
                  PV_CHK_ERR = ABAP_TRUE.
                  RETURN.
                ENDIF.

                INSERT LS_CHK_2010 INTO LT_2010_PRE INDEX LV_TABIX.
              ENDIF.

            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDLOOP.
      IF LT_2010_PRE IS INITIAL.
        EXIT.
      ENDIF.

      REFRESH LT_2010_DEV.
      APPEND LINES OF LT_2010_PRE TO LT_2010_DEV.

    ENDDO.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_BATCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_BATCH .

  DATA : LT_2010 LIKE GT_2010.
  DATA : LV_CHK_ERR.
  DATA : LO_JOJANG TYPE REF TO ZGTPP_CL_ROUTING_GAON.
  DATA : LT_ERR_ORDER TYPE BAPI_ORDER_RETURN_TT.
  DATA : LV_LINES(11).

  PERFORM CHK_LINE_FOR_CHANGE_BATCH TABLES LT_2010
                                                       CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  SORT LT_2010 BY ORDNR.
  DELETE ADJACENT DUPLICATES FROM LT_2010 COMPARING ORDNR.

  PERFORM GET_ROUTING_INFOR TABLES LT_2010.

  CHECK LINES( GT_DISP_ARBPL ) IS NOT INITIAL.

* 변경설비 선택화면
  CALL SCREEN '0230' STARTING AT 10 5 ENDING AT 90 15.

  IF GS_DISP_ARBPL IS INITIAL.
    RETURN.
  ENDIF.

  CREATE OBJECT LO_JOJANG.
  LT_ERR_ORDER = LO_JOJANG->CHANGE_BATCH(
                   IT_2010  = LT_2010
                   IV_PLNFL = GS_DISP_ARBPL-PLNFL ).                 " 순서

  IF LT_ERR_ORDER IS NOT INITIAL.
    REFRESH GT_DEL_DISP.
    LOOP AT LT_ERR_ORDER INTO DATA(LS_ERR_ORDER).
      APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING FIELD-SYMBOL(<LS_DEL_DISP>).
      <LS_DEL_DISP>-ORDNR = LS_ERR_ORDER-ORDER_NUMBER.
      <LS_DEL_DISP>-ORDTY = 'PRD'.
      <LS_DEL_DISP>-MESSAGE = LS_ERR_ORDER-MESSAGE.
    ENDLOOP.

    IF LO_JOJANG->MT_TOT_MESSTAB[] IS NOT INITIAL.
      CALL FUNCTION 'Z_SD_DISPLAY_BDC_MESSAGE'
        TABLES
          IT_RETMSG = LO_JOJANG->MT_TOT_MESSTAB.
    ELSE.
      CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
    ENDIF.
  ELSE.

    LV_LINES = LINES( LT_2010 ) .
    CONDENSE LV_LINES.
    MESSAGE S006 WITH '총' LV_LINES '건 설비 변경 처리되었습니다.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_LINE_FOR_CHANGE_BATCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_LINE_FOR_CHANGE_BATCH  TABLES   PT_2010 LIKE GT_2010
                                              CHANGING PV_CHK_ERR.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_NUM(2) TYPE N.
  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_2010_CHK LIKE TABLE OF GS_2010.
  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LT_2010_DEV LIKE TABLE OF GS_2010.
  DATA : LT_2010_PRE LIKE TABLE OF GS_2010.
  DATA : LV_STRING     TYPE  STRING.
  DATA : LV_TABIX TYPE I.

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.

  CLEAR : PV_CHK_ERR.
  REFRESH PT_2010[].

  GO_GRID_0201->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  GO_GRID_0201->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL AND LT_CELLS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'(e01).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  IF LINES( LT_COLUMN ) > 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 공정만 선택 가능합니다.'(e28).
    RETURN.
  ENDIF.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
    READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 2.
    LV_CHART = LS_STRING.

    IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
      MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 컬럼이 선택되었습니다.'(e02).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
* 선택된 컬럼의 공정 유형 전부 추출
    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY CHART = LV_CHART
                                                                                        SEQNO = LV_SEQNO.

    LT_2010 = VALUE #( FOR WA_2010 IN GT_2010 WHERE ( GONG_CD = LV_CHART AND GONG_SEQ = LS_ROUTING-GONG_SEQ )
                                                   ( CORRESPONDING #( WA_2010 ) ) ).

    APPEND LINES OF LT_2010 TO PT_2010.
  ENDLOOP.


  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.

      SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE LT_STRING.
      READ TABLE LT_STRING INTO LS_STRING INDEX 2.
      LV_CHART = LS_STRING.

      IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
        MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'(e02).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY CHART = LV_CHART
                                                                                          SEQNO = LV_SEQNO.

*  선택된 필드의 오더정보 찾기
    READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
      ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.
      IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
      ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO <LV_LINE>.

      CLEAR LV_NUM.
      CLEAR LV_FIELDNAME.
      LV_NUM =  LS_ROUTING-SEQNO + 0.
      LV_FIELDNAME = LV_NUM && '_SEQNO'.

      IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.
      IF <LV_GONGSEQ> IS NOT ASSIGNED. " 공정을 못찾으면 종료
        RETURN.
      ELSE.
        IF <LV_GONGSEQ> = 0. " 해당 공정 순번이 비어있다면 오더가 없다는 의미 다음순번
          CONTINUE.
        ENDIF.
      ENDIF.

      READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
      READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
      READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.

* 중복 필드라면 대상이 아님
      IF LS_CHAIN-CHK_DUP EQ ABAP_TRUE.
        CONTINUE.
      ENDIF.

      IF LS_CHAIN-ORDNR IS INITIAL.
        CONTINUE.
      ENDIF.
      READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = LS_CHAIN-ORDNR
                                                                      POSNR = LS_CHAIN-POSNR
                                                                       ORDTY = LS_CHAIN-ORDTY.
      IF SY-SUBRC EQ 0.
        APPEND LS_2010 TO PT_2010.
      ENDIF.
    ENDIF.
  ENDLOOP.

  SORT PT_2010 BY GONG_CD ORDNR POSNR ORDTY.
  DELETE ADJACENT DUPLICATES FROM PT_2010 COMPARING GONG_CD ORDNR POSNR ORDTY.

  REFRESH LT_2010_CHK.
  LT_2010_CHK = PT_2010[].
  SORT LT_2010_CHK BY GONG_CD.
  DELETE ADJACENT DUPLICATES FROM LT_2010_CHK COMPARING GONG_CD.

  IF LINES( LT_2010_CHK ) > 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 공정만 선택 가능합니다.'(e28).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT PT_2010.
* 1. 생산오더 유형만 가능
    IF PT_2010-ORDTY NE 'PRD'.
      DELETE PT_2010.
      CONTINUE.
    ENDIF.

*  2.  CRTD상태만 대상
    IF PT_2010-STATUS NE 'C'.
      DELETE PT_2010.
      CONTINUE.
    ENDIF.

*  3. 작업중이 아닌공정만 변경 가능
    IF PT_2010-CHK_PRD EQ ABAP_TRUE.
      DELETE PT_2010.
      CONTINUE.
    ENDIF.

  ENDLOOP.

  IF PT_2010[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업 진행할수 있는 오더가 없습니다.'(e35).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ROUTING_INFOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&---------------------------------------------------------------------*
FORM GET_ROUTING_INFOR  TABLES   PT_2010 STRUCTURE ZGTPPT2010.

  DATA : LV_AUFNR TYPE AUFNR.
  READ TABLE PT_2010 INDEX 1.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = PT_2010-ORDNR
    IMPORTING
      OUTPUT = LV_AUFNR.

  SELECT
   F~KTEXT, E~ARBPL, B~APLFL AS PLNFL
   FROM AFKO         AS A
   INNER JOIN AFVC   AS B
                           ON B~AUFPL = A~AUFPL
   INNER JOIN CRHD  AS E
                           ON E~OBJID = B~ARBID
   INNER JOIN CRTX   AS F
                           ON F~OBJID = E~OBJID
                          AND F~OBJTY = E~OBJTY
   WHERE A~AUFNR = @LV_AUFNR
    AND  F~SPRAS = @SY-LANGU
   INTO CORRESPONDING FIELDS OF TABLE @GT_DISP_ARBPL.

  LOOP AT GT_DISP_ARBPL ASSIGNING FIELD-SYMBOL(<LS_ARBPL>).
    IF <LS_ARBPL>-PLNFL = '000000'.
      <LS_ARBPL>-CHECK = ABAP_TRUE.
    ENDIF.
  ENDLOOP.

  SORT GT_DISP_ARBPL BY PLNFL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHECKBOX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CHECKBOX .

  LOOP AT GT_DISP_ARBPL ASSIGNING FIELD-SYMBOL(<LS_DISP_ARBPL>).
    CLEAR <LS_DISP_ARBPL>-CHECK.
  ENDLOOP.

  READ TABLE GT_DISP_ARBPL ASSIGNING <LS_DISP_ARBPL> INDEX GV_CHK_LINE.
  <LS_DISP_ARBPL>-CHECK = GV_CHK_VALUE.

  PERFORM REFRESH_GRID USING GO_GRID_0230.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0230
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0230 .

  CREATE OBJECT GO_CONTAIN_0230
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

  CREATE OBJECT GO_GRID_0230
    EXPORTING
      I_PARENT      = GO_CONTAIN_0230
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0230
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0230 .

  GS_LAYOUT_0230-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0230-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0230-NO_ROWMARK   = 'X'.
  GS_LAYOUT_0230-SEL_MODE   = 'C'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0230
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0230 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2010TOP'
      I_INTERNAL_TABNAME     = 'GS_DISP_ARBPL'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0230[]
    TABLES
      IT_DATA         = GT_DISP_ARBPL
    EXCEPTIONS
      OTHERS          = 1.

  IF NOT LINE_EXISTS( GT_FIELDCAT_0230[ FIELDNAME = 'CHECK'] ).
    APPEND INITIAL LINE TO GT_FIELDCAT_0230 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    <LS_FCAT>-FIELDNAME = 'CHECK'.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-OUTPUTLEN = '1'.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.
  ENDIF.

  LOOP AT GT_FIELDCAT_0230 ASSIGNING <LS_FCAT>.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'CHECK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '선택'(f34).
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_POS = 1.
      WHEN 'KTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업장명'(f35).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-COL_POS = 2.
      WHEN 'ARBPL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업장'(f36).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-COL_POS = 3.
      WHEN 'PLNFL'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
        <LS_FCAT>-COL_POS = 4.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0230
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0230 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0230
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0230_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0230_DISPLAY .

  CALL METHOD GO_GRID_0230->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0230
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0230
    CHANGING
      IT_OUTTAB            = GT_DISP_ARBPL
      IT_FIELDCATALOG      = GT_FIELDCAT_0230.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0230->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0230->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_UNPEGGING_FORCE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_UNPEGGING_FORCE .

  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LV_CHK_ERR.
  DATA : LO_JOJANG TYPE REF TO ZGTPP_CL_ROUTING_GAON.
  DATA : LV_RESULT TYPE CHAR01.


  PERFORM CHK_PROCESS_UNPEGGING_FORCE  TABLES LT_2010
                                                 CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF LT_2010[] IS INITIAL.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    'Pegging 강제 삭제되면 복구할 수 없습니다. 계속 진행 하시겠습니까?'
    '작업확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CREATE OBJECT LO_JOJANG
    EXPORTING
      IV_WERKS              = P_WERKS                 " 플랜트
      IV_GRPNR              = GV_GRPNR                 " 조장 구성표 번호
      IT_MAIN               = GT_MAKE_DISPLAY
      IT_SEQ_ROUTING_HEADER = GT_SEQ_ROUTING_HEADER
      IT_SEQ_ROUTING_SUB    = GT_SEQ_ROUTING_SUB
      IT_MAKED_2010         = GT_2010.


  READ TABLE LT_2010 INTO DATA(LS_2010) INDEX 1.
  LV_RESULT = LO_JOJANG->PROCESS_UNPEGGING_FORCE( IS_2010 = LS_2010 ).


  IF LV_RESULT EQ 'E'.
    MESSAGE S003 WITH '강제 Pegging 진행중 오류 발생했습니다.'(e52) DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

*  변경정보 MES전송
  ZGTPP_CL_ROUTING=>SEND_CHG_MES(
    IV_WERKS = P_WERKS           " 플랜트
    IV_SPGCD = P_SPGCD          " SPG 코드
    IV_GRPNR = GV_GRPNR ).    " 조장 구성표 번호


  PERFORM REFRESH_SCREEN_201.

  MESSAGE S003 WITH 'Pegging 강제삭제 완료하였습니다.'(e53).


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
    p_object->add_function(
      fcode             = CONV #( &1 )                 " Function code
      text              = CONV #( &2 ) ).                 " Function text

  END-OF-DEFINITION.

  CASE PO_SENDER.
    WHEN GO_GRID_0201.
      CASE P_UCOMM.
        WHEN 'DELE_GROUP'.
          __ADD_MANU : 'DELE' '오더삭제',
                              'DELE2' '임가공 오더삭제'.
        WHEN 'CHG_GROUP'.
          IF GV_DISP_200 IS INITIAL.
            __ADD_MANU : 'CHG_PRD' '생산오더전환',
                                'CHG_PO' '임가공전환',
                                'CHG_PR' '구매요청전환',
                                'CHG_PRD2' '재생산오더전환'.
          ELSE.
            __ADD_MANU : 'CHG_PRD2' '재생산오더전환'.
          ENDIF.

        WHEN 'SET_TANDEM_GROUP'.
          __ADD_MANU : 'SET_TANDEM' '탄뎀설정',
                              'DEL_TANDEM' '탄뎀취소'.
        WHEN 'SET_NUM_GROUP'.
          __ADD_MANU : 'EDIT_NUM' '여장편집',
                              'SET_NUM' '표준여장편집'.
        WHEN 'PEGGING_GROUP'.
          __ADD_MANU : 'CHG_PEGGING' 'Pegging변경',
*                              'UNPEGGING' '재고 Pegging삭제',
                              'UNPEGGING_FORCE' 'Pegging 강제삭제'.
        WHEN 'MULTY_GROUP'.
          __ADD_MANU : 'SET_MULTY' '복조장구성',
                              'SEPERATE' '개별 생산오더전환',
                              'SEPERATE_PR' '개별 PR전환',
                              'SET_MERGE' '병합 오더전환'.
        WHEN 'MASTER_GROUP'.
          __ADD_MANU : 'CHG_MASTER' '주문변경',
                              'DEL_MASTER' '주문삭제'.
      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PRE_CHAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_PO_PRE_2010
*&---------------------------------------------------------------------*
FORM GET_PRE_CHAIN  TABLES   PT_PO_PRE_2010 STRUCTURE GS_2010
                                 USING PS_CHAIN LIKE GS_2010.

  DATA : LV_SEQNO TYPE I.

  READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_TEMP_ROUTING) WITH KEY GONG_SEQ = PS_CHAIN-GONG_SEQ.

  LV_SEQNO =  LS_TEMP_ROUTING-SEQNO.
  LV_SEQNO = LV_SEQNO - 1.

  READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_PRE_ROUTING) WITH KEY SEQNO = LV_SEQNO.


  READ TABLE GT_2010 INTO DATA(LS_CHAIN) WITH KEY GONG_SEQ = LS_PRE_ROUTING-GONG_SEQ
                                                                    ORDNR = PS_CHAIN-REORD
                                                                    POSNR = PS_CHAIN-RELINE
                                                                    ORDTY = PS_CHAIN-REORDTY.
* 찾아온 이전 공정 오더가 자신과 동일한 po 일시 한건만 존재
  IF LS_CHAIN-ORDNR = PS_CHAIN-ORDNR AND
    LS_CHAIN-POSNR = PS_CHAIN-POSNR AND
    LS_CHAIN-ORDTY = PS_CHAIN-ORDTY.
    APPEND LS_CHAIN TO PT_PO_PRE_2010.
    RETURN.
  ENDIF.

  LOOP AT GT_2010 INTO DATA(LS_PRE_2010) WHERE DMORD = LS_CHAIN-DMORD
                                                       AND DMLINE = LS_CHAIN-DMLINE
                                                       AND DMORDTY = LS_CHAIN-DMORDTY.

    READ TABLE PT_PO_PRE_2010 TRANSPORTING NO FIELDS WITH KEY ORDNR = LS_PRE_2010-ORDNR
                                                                    POSNR = LS_PRE_2010-POSNR
                                                                    ORDTY = LS_PRE_2010-ORDTY.
    IF SY-SUBRC NE 0.
      APPEND LS_PRE_2010 TO PT_PO_PRE_2010.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MATCH_PRE_CHAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_PO_PRE_2010
*&      <-- LV_CHK_STATUS
*&---------------------------------------------------------------------*
FORM CHECK_MATCH_PRE_CHAIN  TABLES   PT_PO_PRE_2010 STRUCTURE GS_2010
                            CHANGING PV_CHK_STATUS.

  PV_CHK_STATUS = 'S'.

  IF  LINES( PT_PO_PRE_2010[] ) = 1.
    READ TABLE PT_PO_PRE_2010 INDEX 1.
    IF PT_PO_PRE_2010-ORDTY = 'PO' OR PT_PO_PRE_2010-ORDTY = 'UPR'.
      IF PT_PO_PRE_2010-ORDNR = PT_PO_PRE_2010-DMORD AND
        PT_PO_PRE_2010-POSNR = PT_PO_PRE_2010-DMLINE.
* 이후공저의PO와 동일한 번호로 매핑되어 있을 경우 이전공정과 연결된 po이므로 중복 처리
        PV_CHK_STATUS = 'D'. " 중복
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_PURCHASE_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONVERSION_PURCHASE_ORDER .

  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_2010_TMP LIKE TABLE OF GS_2010.
  DATA : LT_2010_CONFIRM LIKE TABLE OF GS_2010.
  DATA : LT_SORT_MATNR LIKE TABLE OF GS_2010.
  DATA : LV_CHK_ERR.
  DATA : LO_JOJANG TYPE REF TO ZGTPP_CL_ROUTING_GAON.
  DATA : LV_RESULT TYPE CHAR01.
  DATA : LV_MATNR_C(40).
  DATA : LV_VALUE TYPE C LENGTH 30.
  DATA : LV_VALUE2 TYPE P LENGTH 13 DECIMALS 2.
  DATA : LV_VALUE3 TYPE I.
  DATA : LV_PLNUM TYPE PLNUM.
  DATA : BEGIN OF LS_INFNR_INFOR,
           MATNR    TYPE MATNR,
           INFNR    TYPE INFNR,
           LIFNR    TYPE LIFNR,
           EEIND    TYPE SY-DATUM,
           LGFSB    TYPE MARC-LGFSB,
           GONG_SEQ TYPE ZEGONG_SEQ,
         END OF LS_INFNR_INFOR.
  DATA : LT_INFNR_INFOR LIKE TABLE OF LS_INFNR_INFOR.

  PERFORM CHK_BEFORE_CONV CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  PERFORM CHK_LINE_FOR_CONV_PO TABLES LT_2010
                                                 CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF LT_2010[] IS INITIAL.
    RETURN.
  ENDIF.

  REFRESH GT_DEL_DISP.

  LT_SORT_MATNR = LT_2010.
  SORT LT_SORT_MATNR BY MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_SORT_MATNR COMPARING MATNR.

  LOOP AT LT_SORT_MATNR INTO DATA(LS_SORT_MATNR).
    CLEAR GS_HEADER_0400.
    REFRESH : GT_MAIN_DISP_400_CHECK, GT_MAIN_DISP_400.
    CLEAR LV_CHK_ERR.
    PERFORM PREPARE_DATA_PO USING LS_SORT_MATNR CHANGING LV_CHK_ERR.

    REFRESH LT_2010_TMP.
    LOOP AT LT_2010 INTO DATA(LS_2010) WHERE MATNR = LS_SORT_MATNR-MATNR.

      IF LV_CHK_ERR = ABAP_TRUE.
        APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING FIELD-SYMBOL(<LS_DEL_DISP>).
        <LS_DEL_DISP>-STATUS = ICON_LED_RED.
        CLEAR LV_MATNR_C.
        LV_MATNR_C = LS_SORT_MATNR-MATNR.
        __ALPHA_OUT LV_MATNR_C.
        <LS_DEL_DISP>-MESSAGE = | 계획오더({ LS_2010-ORDNR }) 자재({ LV_MATNR_C }) 에 대한 구매정보 레코드를 찾을 수 없습니다.|.
        CONTINUE.
      ENDIF.

      CLEAR GS_MAIN_DISP_400.
      GS_MAIN_DISP_400-ORDNR = LS_2010-ORDNR.
*    조장
      IF LS_2010-DMORDTY = 'SO' OR LS_2010-DMORDTY = 'SM'.
        LV_VALUE = LS_2010-INLENGTH.
        CONDENSE LV_VALUE.
        SPLIT LV_VALUE AT '.' INTO DATA(LV_NUM) DATA(LV_DOT).
        IF LV_DOT > 0.
          LV_VALUE = LS_2010-INLENGTH.
        ELSE.
          LV_VALUE3 = LS_2010-INLENGTH.
          LV_VALUE = LV_VALUE3.
        ENDIF.
      ELSE.
        LV_VALUE3 = LS_2010-INLENGTH.
        LV_VALUE = LV_VALUE3.
      ENDIF.
      CONDENSE LV_VALUE.
      CONCATENATE '(' LV_VALUE INTO GS_MAIN_DISP_400-CHART_INFOR.
      IF LS_2010-QLENGTH = 0 AND LS_2010-CLENGTH = 0 AND LS_2010-ADLENGTH = 0.
      ELSE.
* 검사여장,
        LV_VALUE3 = LS_2010-QLENGTH.
        LV_VALUE = LV_VALUE3.
        CONDENSE LV_VALUE.
        CONCATENATE GS_MAIN_DISP_400-CHART_INFOR '+' LV_VALUE '+' INTO GS_MAIN_DISP_400-CHART_INFOR.
* 연결여장
        LV_VALUE3 = LS_2010-CLENGTH.
        LV_VALUE = LV_VALUE3.
        CONDENSE LV_VALUE.
        CONCATENATE GS_MAIN_DISP_400-CHART_INFOR  LV_VALUE '+' INTO GS_MAIN_DISP_400-CHART_INFOR.
* 추가여장
        LV_VALUE3 = LS_2010-ADLENGTH.
        LV_VALUE = LV_VALUE3.
        CONDENSE LV_VALUE.
        CONCATENATE GS_MAIN_DISP_400-CHART_INFOR  LV_VALUE  INTO GS_MAIN_DISP_400-CHART_INFOR.
      ENDIF.
* 조장수
      LV_VALUE3 = LS_2010-INFACTOR.
      LV_VALUE = LV_VALUE3.
      CONDENSE LV_VALUE.

      CONCATENATE GS_MAIN_DISP_400-CHART_INFOR ')X' LV_VALUE INTO GS_MAIN_DISP_400-CHART_INFOR.

      CASE LS_2010-ORDTY.
        WHEN 'PLN'.
          LV_PLNUM = LS_2010-ORDNR.
*      __ALPHA_OUT LV_PLNUM.
          SELECT SINGLE GSMNG FROM PLAF
            INTO @DATA(LV_GSMNG)
            WHERE PLNUM = @LV_PLNUM.
          GS_MAIN_DISP_400-WMENG = LV_GSMNG.
        WHEN 'PRD'.
          SELECT SINGLE GAMNG FROM AFKO
            INTO @DATA(LV_GAMNG)
            WHERE AUFNR = @LS_2010-ORDNR.
          GS_MAIN_DISP_400-WMENG = LV_GAMNG.
      ENDCASE.

      APPEND GS_MAIN_DISP_400 TO GT_MAIN_DISP_400.
      APPEND LS_2010 TO LT_2010_TMP.

    ENDLOOP.

    IF LV_CHK_ERR IS INITIAL.

      CLEAR GV_CONTINUE_400.
*  POPUP 화면 호출

      CALL SCREEN '0400' STARTING AT 5 5 ENDING AT 87 29.

      IF GV_CONTINUE_400 = ABAP_TRUE. " 컨펌 완료시 해당자재 구매오더생성
        APPEND LINES OF LT_2010_TMP TO LT_2010_CONFIRM.
        CLEAR LS_INFNR_INFOR.
        LS_INFNR_INFOR-LIFNR = GS_HEADER_0400-LIFNR.
        LS_INFNR_INFOR-MATNR = GS_HEADER_0400-MATNR.
        LS_INFNR_INFOR-EEIND = GS_HEADER_0400-EEIND.
        LS_INFNR_INFOR-LGFSB = GS_HEADER_0400-LGFSB.
        LS_INFNR_INFOR-GONG_SEQ = GS_HEADER_0400-GONG_SEQ.
        READ TABLE GT_LIFNR INTO GS_LIFNR WITH KEY LIFNR = GS_HEADER_0400-LIFNR.
        LS_INFNR_INFOR-INFNR = GS_LIFNR-INFNR.
        APPEND LS_INFNR_INFOR TO LT_INFNR_INFOR.
      ENDIF.

    ENDIF.

  ENDLOOP.

  IF LT_2010_CONFIRM[] IS INITIAL.
    IF GT_DEL_DISP[] IS NOT INITIAL.
      GV_DISP_SET = 'A'.
      CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
      CLEAR GV_DISP_SET.
    ENDIF.

    RETURN.
  ENDIF.

  CREATE OBJECT LO_JOJANG
    EXPORTING
      IV_WERKS              = P_WERKS                 " 플랜트
      IV_GRPNR              = GV_GRPNR                 " 조장 구성표 번호
      IT_MAIN               = GT_MAKE_DISPLAY
      IT_SEQ_ROUTING_HEADER = GT_SEQ_ROUTING_HEADER
      IT_SEQ_ROUTING_SUB    = GT_SEQ_ROUTING_SUB
      IT_MAKED_2010         = GT_2010
      IT_INFNR_INFOR        = LT_INFNR_INFOR.

  LV_RESULT = LO_JOJANG->CREATE_PURCHASE_ORDER(
                      EXPORTING
                        IT_2010     = LT_2010_CONFIRM ).              " 공정SEQ

  IF LV_RESULT = 'E'.

    REFRESH GT_DEL_DISP.
    APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING <LS_DEL_DISP>.
    <LS_DEL_DISP>-STATUS = ICON_LED_RED.
    <LS_DEL_DISP>-MESSAGE = '임가공 오더 생성중 오류 발생하였습니다'.

    LOOP AT LO_JOJANG->MT_TOT_MESSTAB INTO DATA(LS_MESSAGE) WHERE MSGTYP = 'E'.
      APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING <LS_DEL_DISP>.
      <LS_DEL_DISP>-STATUS = ICON_LED_RED.
      <LS_DEL_DISP>-MESSAGE = LS_MESSAGE-MSGV1 && LS_MESSAGE-MSGV2.
    ENDLOOP.

    IF GT_DEL_DISP[] IS NOT INITIAL.
      GV_DISP_SET = 'A'.
      CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
      CLEAR GV_DISP_SET.
    ENDIF.

    RETURN.

  ENDIF.

  REFRESH GT_DEL_DISP.
  APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING <LS_DEL_DISP>.
  <LS_DEL_DISP>-STATUS = ICON_LED_GREEN.
  <LS_DEL_DISP>-MESSAGE = '임가공 오더 생성 완료하였습니다.'.
  LOOP AT LO_JOJANG->MT_TOT_MESSTAB INTO LS_MESSAGE WHERE MSGTYP = 'E'.
    APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING <LS_DEL_DISP>.
    <LS_DEL_DISP>-STATUS = ICON_LED_YELLOW.
    <LS_DEL_DISP>-MESSAGE = LS_MESSAGE-MSGV1 && LS_MESSAGE-MSGV2.
  ENDLOOP.

  IF GT_DEL_DISP[] IS NOT INITIAL.
    GV_DISP_SET = 'A'.
    CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
    CLEAR GV_DISP_SET.
  ENDIF.

* 안내사항 관리 추가 장납품 관련 조장생성 프로세스 변경으로 전환시 체크 사항들이 존재함
  PERFORM SET_GUIDE_END_CONV CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'DISP_MESSAGE'              " Function code
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
        OTHERS                 = 2.
    IF SY-SUBRC <> 0.
    ENDIF.
  ENDIF.

*  변경정보 MES전송
  ZGTPP_CL_ROUTING=>SEND_CHG_MES(
    IV_WERKS = P_WERKS           " 플랜트
    IV_SPGCD = P_SPGCD          " SPG 코드
    IV_GRPNR = GV_GRPNR ).    " 조장 구성표 번호

  PERFORM REFRESH_SCREEN_201.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_LINE_FOR_CONV_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_LINE_FOR_CONV_PO  TABLES   PT_2010 LIKE GT_2010
                                              CHANGING PV_CHK_ERR.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_NUM(2) TYPE N.
  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.


  CLEAR : PV_CHK_ERR.
  REFRESH PT_2010[].

  GO_GRID_0201->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  GO_GRID_0201->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL AND LT_CELLS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'(e01).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
    READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 2.
    LV_CHART = LS_STRING.

    IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
      MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 컬럼이 선택되었습니다.'(e02).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
* 선택된 컬럼의 공정 유형 전부 추출
    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY CHART = LV_CHART
                                                                                        SEQNO = LV_SEQNO.

    LT_2010 = VALUE #( FOR WA_2010 IN GT_2010 WHERE ( GONG_CD = LV_CHART
                                                                       AND   GONG_SEQ = LS_ROUTING-GONG_SEQ )
                                                   ( CORRESPONDING #( WA_2010 ) ) ).

    APPEND LINES OF LT_2010 TO PT_2010.
  ENDLOOP.


  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.

      SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE LT_STRING.
      READ TABLE LT_STRING INTO LS_STRING INDEX 2.
      LV_CHART = LS_STRING.

      IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
        MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'(e02).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY CHART = LV_CHART
                                                                                          SEQNO = LV_SEQNO.

*  선택된 필드의 오더정보 찾기
    READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
      ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.
      IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
      ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO <LV_LINE>.

      CLEAR LV_NUM.
      CLEAR LV_FIELDNAME.
      LV_NUM =  LS_ROUTING-SEQNO + 0.
      LV_FIELDNAME = LV_NUM && '_SEQNO'.

      IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.
      IF <LV_GONGSEQ> IS NOT ASSIGNED. " 공정을 못찾으면 종료
        RETURN.
      ELSE.
        IF <LV_GONGSEQ> = 0. " 해당 공정 순번이 비어있다면 오더가 없다는 의미 다음순번
          CONTINUE.
        ENDIF.
      ENDIF.

      READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
      READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
      READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.

* 중복 필드라면 대상이 아님
      IF LS_CHAIN-CHK_DUP EQ ABAP_TRUE.
        CONTINUE.
      ENDIF.

      IF LS_CHAIN-ORDNR IS INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = LS_CHAIN-ORDNR
                                                                      POSNR = LS_CHAIN-POSNR
                                                                       ORDTY = LS_CHAIN-ORDTY.
      IF SY-SUBRC EQ 0.
        APPEND LS_2010 TO PT_2010.
      ENDIF.
    ENDIF.
  ENDLOOP.

  SORT PT_2010 BY GONG_CD ORDNR ORDTY.
  DELETE ADJACENT DUPLICATES FROM PT_2010 COMPARING GONG_CD ORDNR ORDTY.

* 공정 유효성 체크
  LT_2010 = PT_2010[].
  SORT LT_2010 BY GONG_CD GONG_SEQ.
  DELETE ADJACENT DUPLICATES FROM LT_2010 COMPARING GONG_CD GONG_SEQ.
  IF LINES( LT_2010 ) > 1.
    PV_CHK_ERR = ABAP_TRUE.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 공정만 선택 가능합니다.'(e28).
    RETURN.
  ENDIF.



  LOOP AT PT_2010.
    CASE PT_2010-ORDTY.
      WHEN 'PRD'.
        IF PT_2010-CHK_PRD = ABAP_TRUE.
          MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더'(e04) PT_2010-ORDNR '는 생산 진행 중으로 전환할 수 없습니다.'(e39).
          RETURN.
        ENDIF.

      WHEN 'PO'.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '구매오더'(e43) PT_2010-ORDNR '는 전환할 수 없습니다.'(e44).
        RETURN.

      WHEN 'PR' OR 'UPR'.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '구매요청'(e60) PT_2010-ORDNR '는 전환할 수 없습니다.'(e44).
        RETURN.
    ENDCASE.

    LOOP AT GT_2010 INTO DATA(LS_CHK_DEV_PRD) WHERE ORDNR = PT_2010-DMORD
                                                AND POSNR = PT_2010-DMLINE
                                                AND ORDTY = PT_2010-DMORDTY.
      IF LS_CHK_DEV_PRD-CHK_PRD = ABAP_TRUE.
        CASE PT_2010-ORDTY.
          WHEN 'PRD'.
            MESSAGE S006 DISPLAY LIKE 'E' WITH '생산오더'(e04) PT_2010-ORDNR '의 이후공정이 생산진행중 입니다.'(e96).
          WHEN 'PLN'.
            MESSAGE S006 DISPLAY LIKE 'E' WITH '계획오더'(e97) PT_2010-ORDNR '의 이후공정이 생산진행중 입니다.'(e96).
        ENDCASE.
        RETURN.
      ENDIF.

    ENDLOOP.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PREPARE_DATA_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_CHART
*&---------------------------------------------------------------------*
FORM PREPARE_DATA_PO  USING    PS_CHART LIKE GS_2010   CHANGING PV_CHK_ERR.

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_COLPOS TYPE I.
  DATA : LV_FIELDVAL(50) .

  CLEAR GS_EKORG.
  SELECT SINGLE FLD_02 AS WERKS, FLD_03 AS EKORG, FLD_04 AS EKGRP
  FROM ZGTPPT1010
  INTO @GS_EKORG
 WHERE MODULE_KIND = 'PP'
   AND CODEGRP = '2090'
   AND FLD_01 = 'L'
   AND FLD_02 = @P_WERKS.

  GS_HEADER_0400-WERKS = P_WERKS.

* 입고위치 추가
  SELECT SINGLE LGFSB
    FROM MARC
    INTO GS_HEADER_0400-LGFSB
   WHERE WERKS = P_WERKS
     AND MATNR = PS_CHART-MATNR.

  REFRESH GT_LIFNR.
* 공급업체 정보 추출
  SELECT DISTINCT A~MATNR, A~INFNR, A~LIFNR, C~NAME1
    FROM EINA AS A
    INNER JOIN EINE AS B ON B~INFNR = A~INFNR
    INNER JOIN LFA1 AS C ON C~LIFNR = A~LIFNR
  WHERE A~MATNR = @PS_CHART-MATNR
     AND A~LOEKZ = ''
     AND B~EKORG = @GS_EKORG-EKORG
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIFNR.

  GS_HEADER_0400-MATNR = PS_CHART-MATNR.
  GS_HEADER_0400-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = PS_CHART-MATNR ).
  READ TABLE GT_LIFNR INTO GS_LIFNR INDEX 1.
  IF SY-SUBRC EQ 0.
    GS_HEADER_0400-LIFNR = GS_LIFNR-LIFNR.
    GS_HEADER_0400-NAME1 = GS_LIFNR-NAME1.
  ELSE.
    PV_CHK_ERR = ABAP_TRUE.
  ENDIF.

  CLEAR GS_MAIN_DISP_400_CHECK.
  REFRESH GT_FIELDCAT_0400.
  LOOP AT GT_SEQ_ROUTING_HEADER INTO GS_SEQ_ROUTING_HEADER WHERE GONG_SEQ <= PS_CHART-GONG_SEQ.
    APPEND INITIAL LINE TO GT_FIELDCAT_0400 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CLEAR LV_FIELDNAME.
    LV_NUM = GS_SEQ_ROUTING_HEADER-SEQNO + 0.
    LV_FIELDNAME = 'CHECK_' && LV_NUM.
    LV_FIELDVAL = LV_NUM && '_' && GS_SEQ_ROUTING_HEADER-CHART_VAL.
    <LS_FCAT>-FIELDNAME = LV_FIELDNAME.

    IF GS_SEQ_ROUTING_HEADER-SEQNO = LINES( GT_SEQ_ROUTING_HEADER ) .
      <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_FIELDVAL && '(END)'.
    ELSE.
      <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_FIELDVAL.
    ENDIF.
    ADD 10 TO LV_COLPOS.
    <LS_FCAT>-COL_POS = LV_COLPOS.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-OUTPUTLEN = '1'.
    <LS_FCAT>-JUST = 'L'.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.
    <LS_FCAT>-EDIT = ABAP_TRUE.

    IF GS_SEQ_ROUTING_HEADER-GONG_SEQ = PS_CHART-GONG_SEQ.
      GS_MAIN_DISP_400_CHECK-(LV_FIELDNAME) = ABAP_TRUE.
      GS_HEADER_0400-FIELDNAME = LV_FIELDNAME.
    ENDIF.

  ENDLOOP.

  APPEND GS_MAIN_DISP_400_CHECK TO GT_MAIN_DISP_400_CHECK.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0400 .

  CREATE OBJECT GO_DOCKING_0400
    EXPORTING
      CONTAINER_NAME              = 'GV_CONTAINER400'                 " Name of the Screen CustCtrl Name to Link Container To
    EXCEPTIONS
      CNTL_ERROR                  = 1                " CNTL_ERROR
      CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
      CREATE_ERROR                = 3                " CREATE_ERROR
      LIFETIME_ERROR              = 4                " LIFETIME_ERROR
      LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.

*화면 분할
  CREATE OBJECT GO_SPLITTER_400
    EXPORTING
      PARENT  = GO_DOCKING_0400
      ROWS    = 2
      COLUMNS = 1.

  GO_SPLITTER_400->SET_ROW_HEIGHT(
    EXPORTING
      ID                =    1              " Row ID
      HEIGHT            =    20 ).             " Height


* top 컨테이너(Title)
  CALL METHOD GO_SPLITTER_400->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0400.
* top 컨테이너(Grid)
  CALL METHOD GO_SPLITTER_400->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0401.


  CREATE OBJECT GO_GRID_0400
    EXPORTING
      I_PARENT      = GO_CONTAIN_0400
      I_APPL_EVENTS = ABAP_TRUE.

  CREATE OBJECT GO_GRID_0401
    EXPORTING
      I_PARENT      = GO_CONTAIN_0401
      I_APPL_EVENTS = ABAP_TRUE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0400 .

  CLEAR GS_LAYOUT_0400.
  GS_LAYOUT_0400-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0400-SEL_MODE = 'C'.
  GS_LAYOUT_0400-NO_ROWMARK = ABAP_TRUE.
  GS_LAYOUT_0400-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT_0400-SMALLTITLE = 'X'.
  GS_LAYOUT_0400-GRID_TITLE = '공정선택'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0400 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0400
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0400_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0400_DISPLAY .

  CALL METHOD GO_GRID_0400->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0400
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0400
      I_BYPASSING_BUFFER   = ABAP_TRUE
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_400_CHECK
      IT_FIELDCATALOG      = GT_FIELDCAT_0400.

  GO_GRID_0400->SET_READY_FOR_INPUT( 1 ).

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0400->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0400->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0401
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0401 .

  CLEAR GS_LAYOUT_0401.
  GS_LAYOUT_0401-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0401-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0401-SEL_MODE   = 'C'.
  GS_LAYOUT_0401-SMALLTITLE = 'X'.
  GS_LAYOUT_0401-GRID_TITLE = '선택정보'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0401
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0401 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0401
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0401_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0401_DISPLAY .

  CALL METHOD GO_GRID_0401->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0401
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0401
      I_BYPASSING_BUFFER   = ABAP_TRUE
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_400
      IT_SORT              = GT_SORT_0401
      IT_FIELDCATALOG      = GT_FIELDCAT_0401.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0400 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

  LOOP AT GT_MAIN_DISP_400_CHECK ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    LOOP AT GT_FIELDCAT_0400 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
      IF <LS_FCAT>-FIELDNAME = GS_HEADER_0400-FIELDNAME.
        CLEAR LS_CELLTAB.
        LS_CELLTAB-FIELDNAME = GS_HEADER_0400-FIELDNAME.
        LS_CELLTAB-STYLE = ALV_STYLE_DISABLED.
        INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
      ENDIF.
    ENDLOOP.

    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0401
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0401 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2140TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_400'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0401.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0401[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_400
    EXCEPTIONS
      OTHERS          = 1.

  APPEND INITIAL LINE TO GT_FIELDCAT_0401 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
  <LS_FCAT>-FIELDNAME = 'CHART_INFOR'.
  <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '개별조장'(f37).
  <LS_FCAT>-COL_POS = 4.
  <LS_FCAT>-DATATYPE = 'CHAR'.
  <LS_FCAT>-DD_OUTLEN = '50'.
  <LS_FCAT>-JUST = 'C'.

  LOOP AT GT_FIELDCAT_0401 ASSIGNING <LS_FCAT>.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재'(f59).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        IF SY-DYNNR = '0400'.
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDIF.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재내역'(f46).
        <LS_FCAT>-JUST = 'L'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        IF SY-DYNNR = '0400'.
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDIF.
      WHEN 'ORDNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더'(f38).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'POSNR'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'WMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더수량'(f39).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'M'.
      WHEN 'CHART_INFOR'.

    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_LIFNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_LIFNR INPUT.

  PERFORM F4HELP_LIFNR.

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
  SORT LT_LIFNR BY LIFNR.
  DELETE ADJACENT DUPLICATES FROM LT_LIFNR COMPARING LIFNR.

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
    <LS_DYNPFIELDS>-FIELDNAME = 'GS_HEADER_0400-LIFNR'.
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
    <LS_DYNPFIELDS>-FIELDNAME = 'GS_HEADER_0400-NAME1'.
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
*& Form CHECK_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_ANSWER
*&---------------------------------------------------------------------*
FORM CHECK_0400  CHANGING PV_ANSWER.

  DATA : LV_CHECK(10).
  DATA : LV_CHECK2(10).
  DATA : LV_CHK_NUM(2) TYPE N.
  DATA : LV_CHK_NUM2(2) TYPE N.
  DATA : LV_CAL_NUM(2) TYPE N.
  DATA : LV_CAL_NUM2(2) TYPE N.
  DATA : LV_LOW_NUM(2) TYPE N.
  DATA : LV_CHK_FIELDNAME TYPE FIELDNAME.
  DATA : LV_SEQNO TYPE I.
  DATA : LT_DEV_2010 LIKE TABLE OF GS_2010.
  DATA : LT_CURRENT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_CHK_MULTY_2010 LIKE TABLE OF GS_2010.
  DATA : LV_CHK_EXIT.

  IF GS_HEADER_0400-LIFNR IS INITIAL.
    MESSAGE I006 WITH '공급업체가 지정되지 않았습니다.'(e36).
    PV_ANSWER = ABAP_TRUE.
    RETURN.
  ENDIF.

  IF GS_HEADER_0400-EEIND IS INITIAL OR GS_HEADER_0400-EEIND = '00000000'.
    MESSAGE I006 WITH '납품 예정일이 지정되지 않았습니다.'(e37).
    PV_ANSWER = ABAP_TRUE.
    RETURN.
  ENDIF.

  IF GS_HEADER_0400-LGFSB IS INITIAL.
    MESSAGE I006 WITH '구매 입고 저장위치를 입력해 주세요.'(e82).
    PV_ANSWER = ABAP_TRUE.
    RETURN.
  ENDIF.

  READ TABLE GT_MAIN_DISP_400_CHECK INTO DATA(LS_CHK) INDEX 1.
  SPLIT GS_HEADER_0400-FIELDNAME AT '_' INTO LV_CHECK LV_CHK_NUM.

  LOOP AT GT_FIELDCAT_0400 INTO DATA(LS_FCAT).
    IF  LS_CHK-(LS_FCAT-FIELDNAME) = ABAP_TRUE.
      IF LV_CAL_NUM = LV_CHK_NUM.
        EXIT.
      ENDIF.

      SPLIT LS_FCAT-FIELDNAME AT '_' INTO LV_CHECK2 LV_CHK_NUM2.
      IF LV_LOW_NUM IS INITIAL.
        LV_LOW_NUM = LV_CHK_NUM2.
      ELSEIF LV_LOW_NUM > LV_CHK_NUM2.
        LV_LOW_NUM = LV_CHK_NUM2.
      ENDIF.

      IF LV_CAL_NUM IS INITIAL.
        LV_CAL_NUM = LV_CHK_NUM2.
        ADD 1 TO LV_CAL_NUM.
      ELSE.
        IF LV_CHK_NUM2 = LV_CAL_NUM.
          ADD 1 TO LV_CAL_NUM .
          CONTINUE.
        ELSE.
          LV_CAL_NUM2 = LV_CHK_NUM2 + 1.
          LV_CHK_FIELDNAME = 'CHECK_' && LV_CAL_NUM2.
          IF LS_CHK-(LV_CHK_FIELDNAME) NE ABAP_TRUE.
            MESSAGE I006 WITH '공정 추가 선택은 연속된 공정이여야 합니다. 선택된 공정을 확인해 주세요.'(e38).
            PV_ANSWER = ABAP_TRUE.
            RETURN.
          ENDIF.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.

* 오더별 연결정보 확인
* 추가로 선택된 공정의 오더 상태 확인
*  - PRD일시 생산 중인게 있다면 오류
*  - 구매오더 존재시 오류
  LV_SEQNO = LV_LOW_NUM + 0.

  READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_LOW_GONG) WITH KEY SEQNO = LV_SEQNO.

  GS_HEADER_0400-GONG_SEQ = LS_LOW_GONG-GONG_SEQ.

  DATA(LT_CHK_MAIN) = GT_MAIN_DISP_400.
  SORT LT_CHK_MAIN BY ORDNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_MAIN COMPARING ORDNR.

  LOOP AT GT_MAIN_DISP_400 INTO GS_MAIN_DISP_400.
    REFRESH LT_DEV_2010.
    LOOP AT  GT_2010 INTO GS_2010 WHERE  ORDNR = GS_MAIN_DISP_400-ORDNR.
      APPEND GS_2010 TO LT_DEV_2010.
    ENDLOOP.

    DO.

      REFRESH LT_CURRENT_2010.
      LOOP AT LT_DEV_2010 INTO DATA(LS_DEV_2010).
        READ TABLE GT_2010 INTO GS_2010 WITH KEY  ORDNR = LS_DEV_2010-REORD
                                                                     POSNR = LS_DEV_2010-RELINE
                                                                     ORDTY = LS_DEV_2010-REORDTY.
        IF SY-SUBRC EQ 0.
          IF LS_LOW_GONG-GONG_SEQ > GS_2010-GONG_SEQ.
            CONTINUE.
          ENDIF.

          " 이후공정의 체인에서 이전 오더를 찾았을때 이전오더의 이후공정 체인이 동일할시
* 찾아온 이전 공정이 복조장 인지 확인
          REFRESH LT_CHK_MULTY_2010.
          LOOP AT GT_2010 INTO DATA(LS_TEMP) WHERE ORDNR = GS_2010-ORDNR.
            APPEND LS_TEMP TO LT_CHK_MULTY_2010.
          ENDLOOP.
          SORT LT_CHK_MULTY_2010 BY ORDNR POSNR.
          DELETE ADJACENT DUPLICATES FROM LT_CHK_MULTY_2010 COMPARING ORDNR POSNR.
          IF LINES( LT_CHK_MULTY_2010 ) = 1. " 1:1 매핑구조일시 정상
            APPEND LINES OF LT_CHK_MULTY_2010 TO LT_CURRENT_2010.
          ELSE.
* 선택되지 않은 다른 오더에 연결되어 있을 경우 에러
            LOOP AT LT_CHK_MULTY_2010 INTO LS_TEMP.
              READ TABLE LT_DEV_2010 TRANSPORTING NO FIELDS WITH KEY ORDNR = LS_TEMP-DMORD
                                                                                                       POSNR = LS_TEMP-DMLINE
                                                                                                       ORDTY = LS_TEMP-DMORDTY.
              IF SY-SUBRC NE 0.
                MESSAGE I006 WITH  '추가 선택된 공정중 다른오더와 연결된 복조장 오더가 있습니다. 선택된 공정을 확인해 주세요.'(e40).
                PV_ANSWER = ABAP_TRUE.
                RETURN.
              ELSE.
                APPEND LS_TEMP TO LT_CURRENT_2010.
              ENDIF.
            ENDLOOP.

          ENDIF.

        ENDIF.
      ENDLOOP.

      IF LT_CURRENT_2010[] IS INITIAL.
        EXIT.
      ENDIF.

      SORT LT_CURRENT_2010 BY ORDNR POSNR.
      DELETE ADJACENT DUPLICATES FROM LT_CURRENT_2010 COMPARING ORDNR POSNR.
      LOOP AT LT_CURRENT_2010 INTO DATA(LS_CURRENT_2010).
        CASE LS_CURRENT_2010-ORDTY.
          WHEN 'PRD'.
            IF LS_CURRENT_2010-CHK_PRD = ABAP_TRUE.
              MESSAGE I006 WITH  '추가 선택된 공정중 생산중인 오더가 있습니다. 선택된 공정을 확인해 주세요.'(e41).
              PV_ANSWER = ABAP_TRUE.
              RETURN.
            ENDIF.
          WHEN 'PO'.
            MESSAGE I006 WITH  '추가 선택된 공정중 임가공 구매 오더가 있습니다. 선택된 공정을 확인해 주세요.'(e42).
            PV_ANSWER = ABAP_TRUE.
            RETURN.
          WHEN 'PR' OR 'UPR'.
            MESSAGE I006 WITH  '추가 선택된 공정중 구매 요청이 있습니다. 선택된 공정을 확인해 주세요.'(e64).
            PV_ANSWER = ABAP_TRUE.
            RETURN.

        ENDCASE.

      ENDLOOP.

      REFRESH LT_DEV_2010.
      LT_DEV_2010 = LT_CURRENT_2010.

    ENDDO.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_PURCHASE_ORDER_TO_ORIGN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONV_PURCHASE_ORDER_TO_ORIGN .

  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LV_CHK_ERR.
  DATA : LO_JOJANG TYPE REF TO ZGTPP_CL_ROUTING_GAON.
  DATA : LV_RESULT TYPE CHAR01.
  DATA : LS_MESSAGE TYPE BAPIRETURN1.

  PERFORM CHK_CONV_TO_ORIGN  TABLES LT_2010
                                            CHANGING LV_CHK_ERR.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_CONV_TO_ORIGN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_CONV_TO_ORIGN  TABLES   PT_2010 LIKE GT_2010
                                              CHANGING PV_CHK_ERR.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_NUM(2) TYPE N.
  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_2010_CHK LIKE TABLE OF GS_2010.
  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.

  CLEAR : PV_CHK_ERR.
  REFRESH PT_2010[].

  GO_GRID_0201->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  GO_GRID_0201->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL AND LT_CELLS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'(e01).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
    READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 2.
    LV_CHART = LS_STRING.

    IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
      MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 컬럼이 선택되었습니다.'(e02).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
* 선택된 컬럼의 공정 유형 전부 추출
    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY CHART = LV_CHART
                                                                                        SEQNO = LV_SEQNO.

    LT_2010 = VALUE #( FOR WA_2010 IN GT_2010 WHERE ( GONG_CD = LV_CHART
                                                                       AND   GONG_SEQ = LS_ROUTING-GONG_SEQ
                                                                       AND   ORDTY = 'PO' )
                                                   ( CORRESPONDING #( WA_2010 ) ) ).

    LOOP AT LT_2010 ASSIGNING FIELD-SYMBOL(<LS_TEMP>).
      IF <LS_TEMP>-ORDTY = 'PO' AND
         <LS_TEMP>-DMORD = <LS_TEMP>-ORDNR AND
         <LS_TEMP>-DMLINE = <LS_TEMP>-POSNR.
        DELETE LT_2010.
      ENDIF.
    ENDLOOP.

    APPEND LINES OF LT_2010 TO PT_2010.
  ENDLOOP.


  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.

      SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE LT_STRING.
      READ TABLE LT_STRING INTO LS_STRING INDEX 2.
      LV_CHART = LS_STRING.

      IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
        MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'(e02).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY CHART = LV_CHART
                                                                                          SEQNO = LV_SEQNO.

*  선택된 필드의 오더정보 찾기
    READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
      ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.
      IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
      ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO <LV_LINE>.

      CLEAR LV_NUM.
      CLEAR LV_FIELDNAME.
      LV_NUM =  LS_ROUTING-SEQNO + 0.
      LV_FIELDNAME = LV_NUM && '_SEQNO'.

      IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.
      IF <LV_GONGSEQ> IS NOT ASSIGNED. " 공정을 못찾으면 종료
        RETURN.
      ELSE.
        IF <LV_GONGSEQ> = 0. " 해당 공정 순번이 비어있다면 오더가 없다는 의미 다음순번
          CONTINUE.
        ENDIF.
      ENDIF.

      READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
      READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
      READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.

* 중복 필드라면 대상이 아님
      IF LS_CHAIN-CHK_DUP EQ ABAP_TRUE.
        CONTINUE.
      ENDIF.

      IF LS_CHAIN-ORDNR IS INITIAL.
        CONTINUE.
      ENDIF.

      IF LS_CHAIN-ORDTY NE 'PO'.
        CONTINUE.
      ENDIF.

      READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY GONG_SEQ = LS_GONG-GONG_SEQ
                                                                      ORDNR = LS_CHAIN-ORDNR
                                                                      POSNR = LS_CHAIN-POSNR
                                                                       ORDTY = LS_CHAIN-ORDTY.
      IF SY-SUBRC EQ 0.
        APPEND LS_2010 TO PT_2010.
      ENDIF.
    ENDIF.
  ENDLOOP.

  REFRESH LT_2010.

  SORT PT_2010 BY GONG_CD ORDNR POSNR ORDTY.
  DELETE ADJACENT DUPLICATES FROM PT_2010 COMPARING GONG_CD ORDNR POSNR ORDTY.

  LOOP AT PT_2010.
    IF PT_2010-CHK_PRD = ABAP_TRUE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH  '구매오더'(e43) PT_2010-ORDNR '는 임가공 처리중인 오더입니다.'(e45).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_PROCESS_UNPEGGING_FORCE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_PROCESS_UNPEGGING_FORCE  TABLES   PT_2010 LIKE GT_2010
                                              CHANGING PV_CHK_ERR.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_NUM(2) TYPE N.
  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_2010_CHK LIKE TABLE OF GS_2010.
  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_MENGE TYPE MSEG-MENGE.

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.

  CLEAR : PV_CHK_ERR.
  REFRESH PT_2010[].

  GO_GRID_0201->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  GO_GRID_0201->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_COLUMN[] IS NOT INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '컬럼을 선택할 수 없습니다.'(e18).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  IF 1 > LINES( LT_CELLS ).
    MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 셀만 선택해야 합니다.'(e19).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.

      SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
      READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 2.
      LV_CHART = LS_STRING.

      IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
        MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'(e02).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY CHART = LV_CHART
                                                                                                SEQNO = LV_SEQNO.

*  선택된 필드의 오더정보 찾기
    READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
      ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.
      IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
      ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO <LV_LINE>.

      CLEAR LV_NUM.
      CLEAR LV_FIELDNAME.
      LV_NUM =  LS_ROUTING-SEQNO + 0.
      LV_FIELDNAME = LV_NUM && '_SEQNO'.

      IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.
      IF <LV_GONGSEQ> IS NOT ASSIGNED. " 공정을 못찾으면 종료
        RETURN.
      ELSE.
        IF <LV_GONGSEQ> = 0. " 해당 공정 순번이 비어있다면 오더가 없다는 의미 다음순번
          CONTINUE.
        ENDIF.
      ENDIF.

      READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
      READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
      READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.

* 중복 필드라면 대상이 아님
      IF LS_CHAIN-CHK_DUP EQ ABAP_TRUE.
        CONTINUE.
      ENDIF.

      IF LS_CHAIN-ORDNR IS INITIAL.
        CONTINUE.
      ENDIF.

*      IF LS_CHAIN-ORDTY NE 'PRD'.
*        CONTINUE.
*      ENDIF.

      READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY GONG_SEQ = LS_GONG-GONG_SEQ
                                                                      ORDNR = LS_CHAIN-ORDNR
                                                                      POSNR = LS_CHAIN-POSNR
                                                                       ORDTY = LS_CHAIN-ORDTY.
      IF SY-SUBRC EQ 0.
        APPEND LS_2010 TO PT_2010.
      ENDIF.
    ENDIF.
  ENDLOOP.

  REFRESH LT_2010.

  SORT PT_2010 BY GONG_CD ORDNR POSNR ORDTY.
  DELETE ADJACENT DUPLICATES FROM PT_2010 COMPARING GONG_CD ORDNR POSNR ORDTY.

* 복조장만 강제Pegging 가능,
  READ TABLE PT_2010 INDEX 1.

* 판매오더 참조 완제품 오더 Pegging 삭제 시 Validation 추가
  IF PT_2010-DMORDTY = 'SO'.
* 1) 생산 오더 입고 자재 / 배치 확인 (입고 Lot 복수 존재)
    SELECT MATNR, CHARG  FROM MSEG
      INTO TABLE @DATA(LT_MSEG)
     WHERE BWART = '101'
       AND AUFNR = @PT_2010-ORDNR
       AND AUFPS = @PT_2010-POSNR+2(4)
       AND SMBLN = ' '.
    IF SY-SUBRC EQ 0 AND LT_MSEG IS NOT INITIAL.
* 2) 자재, 배치의 판매오더 재고 확인
      SELECT *
        FROM ZGTCV_STOCKVAL
        FOR ALL ENTRIES IN @LT_MSEG
        WHERE WERKS = @P_WERKS
          AND MATNR = @LT_MSEG-MATNR
          AND CHARG = @LT_MSEG-CHARG
          AND VBELN = @PT_2010-DMORD
          AND POSNR = @PT_2010-DMLINE
         INTO TABLE @DATA(LT_STOCKVAL).
      IF SY-SUBRC EQ 0.
        CLEAR LV_MENGE.
        LOOP AT LT_STOCKVAL INTO DATA(LS_STOCKVAL).
          LV_MENGE = LV_MENGE + LS_STOCKVAL-LABST + LS_STOCKVAL-INSME + LS_STOCKVAL-SPEME.
        ENDLOOP.

        IF LV_MENGE > 0.
          MESSAGE S006 DISPLAY LIKE 'E' WITH '판매오더 재고가 있습니다.' '이전 전기 후 Pegging 강제 삭제 할 수 있습니다.'.
          PV_CHK_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

*  SELECT AUFNR, POSNR FROM AFPO
*   WHERE AUFNR = @PT_2010-ORDNR
*     INTO TABLE @DATA(LT_DUP_AUFNR).
*  SORT LT_DUP_AUFNR BY AUFNR POSNR.
*  DELETE ADJACENT DUPLICATES FROM LT_DUP_AUFNR COMPARING AUFNR POSNR.
*  IF LINES( LT_DUP_AUFNR ) = 1. " 복조장 아닌 오더도 처리대상
*
*
*  ELSEIF LINES( LT_DUP_AUFNR ) > 1.
*
*    LOOP AT GT_2010 INTO DATA(LS_CHK_CURRENT) WHERE ORDNR = PT_2010-ORDNR
**                                                                   AND POSNR NE PT_2010-POSNR
*                                                                   AND ORDTY = PT_2010-ORDTY.
*      APPEND LS_CHK_CURRENT TO LT_2010_CHK.
*    ENDLOOP.
*
** 현재 조장표에 복조장이 한건만 남아있다면 삭제불가
**    IF LINES( LT_2010_CHK ) = 1.
**      MESSAGE S003 DISPLAY LIKE 'E' WITH 'Pegging 강제삭제 처리 불가능한 오더입니다.'(e47).
**      PV_CHK_ERR = ABAP_TRUE.
**      RETURN.
**    ENDIF.
*
*  ENDIF.

* 이후공정 상태 확인 작업 진행중이면 삭제 불가
  READ TABLE GT_2010 INTO DATA(LS_2010_DEV) WITH KEY ORDNR = PT_2010-DMORD
                                                                              POSNR = PT_2010-DMLINE
                                                                              ORDTY = PT_2010-DMORDTY.
  IF SY-SUBRC EQ 0.
    LOOP AT GT_2010 INTO DATA(LS_2010_DEV_CHK) WHERE GONG_SEQ = LS_2010_DEV-GONG_SEQ
                                                                        AND REORD = LS_2010_DEV-REORD
                                                                        AND RELINE = LS_2010_DEV-RELINE
                                                                        AND REORDTY = LS_2010_DEV-REORDTY.
      IF LS_2010_DEV_CHK-CHK_PRD = ABAP_TRUE.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '이후 공정 작업 진행중으로 삭제 불가능합니다.'.
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.

    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_UNPEGGING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_UNPEGGING .

  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LV_CHK_ERR.
  DATA : LO_JOJANG TYPE REF TO ZGTPP_CL_ROUTING_GAON.
  DATA : LV_RESULT TYPE CHAR01.

  PERFORM CHK_PROCESS_UNPEGGING  TABLES LT_2010
                                               CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF LT_2010[] IS INITIAL.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '재고 Pegging 삭제 진행합니다. 계속 진행 하시겠습니까?'
    '작업확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CREATE OBJECT LO_JOJANG
    EXPORTING
      IV_WERKS              = P_WERKS                 " 플랜트
      IV_GRPNR              = GV_GRPNR                 " 조장 구성표 번호
      IT_MAIN               = GT_MAKE_DISPLAY
      IT_SEQ_ROUTING_HEADER = GT_SEQ_ROUTING_HEADER
      IT_SEQ_ROUTING_SUB    = GT_SEQ_ROUTING_SUB
      IT_MAKED_2010         = GT_2010.

  LV_RESULT = LO_JOJANG->PROCESS_UNPEGGING( IT_2010 = LT_2010 ).

  IF LV_RESULT EQ 'E'.
    MESSAGE S003 WITH '재고 Pegging 삭제 진행중 오류 발생했습니다.'(e50) DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

*  변경정보 MES전송
  ZGTPP_CL_ROUTING=>SEND_CHG_MES(
    IV_WERKS = P_WERKS           " 플랜트
    IV_SPGCD = P_SPGCD          " SPG 코드
    IV_GRPNR = GV_GRPNR ).    " 조장 구성표 번호

  PERFORM REFRESH_SCREEN_201.

  MESSAGE S003 WITH '재고 Pegging 삭제 완료하였습니다.'(e51).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_PROCESS_UNPEGGING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_PROCESS_UNPEGGING  TABLES   PT_2010 LIKE GT_2010
                                              CHANGING PV_CHK_ERR.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_NUM(2) TYPE N.
  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_2010_CHK LIKE TABLE OF GS_2010.
  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.

  CLEAR : PV_CHK_ERR.
  REFRESH PT_2010[].

  GO_GRID_0201->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  GO_GRID_0201->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_COLUMN[] IS NOT INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '컬럼을 선택할 수 없습니다.'(e18).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  IF 1 > LINES( LT_CELLS ).
    MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 셀만 선택해야 합니다.'(e19).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.

      SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
      READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 2.
      LV_CHART = LS_STRING.

      IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
        MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'(e02).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY CHART = LV_CHART
                                                                                                SEQNO = LV_SEQNO.

*  선택된 필드의 오더정보 찾기
    READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
      ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.
      IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
      ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO <LV_LINE>.

      CLEAR LV_NUM.
      CLEAR LV_FIELDNAME.
      LV_NUM =  LS_ROUTING-SEQNO + 0.
      LV_FIELDNAME = LV_NUM && '_SEQNO'.

      IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.
      IF <LV_GONGSEQ> IS NOT ASSIGNED. " 공정을 못찾으면 종료
        RETURN.
      ELSE.
        IF <LV_GONGSEQ> = 0. " 해당 공정 순번이 비어있다면 오더가 없다는 의미 다음순번
          CONTINUE.
        ENDIF.
      ENDIF.

      READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
      READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
      READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.

* 중복 필드라면 대상이 아님
      IF LS_CHAIN-CHK_DUP EQ ABAP_TRUE.
        CONTINUE.
      ENDIF.

      IF LS_CHAIN-ORDNR IS INITIAL.
        CONTINUE.
      ENDIF.

      IF LS_CHAIN-ORDTY NE 'PRD'.
        CONTINUE.
      ENDIF.

      READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY GONG_SEQ = LS_GONG-GONG_SEQ
                                                                      ORDNR = LS_CHAIN-ORDNR
                                                                      POSNR = LS_CHAIN-POSNR
                                                                       ORDTY = LS_CHAIN-ORDTY.
      IF SY-SUBRC EQ 0.
        APPEND LS_2010 TO PT_2010.
      ENDIF.
    ENDIF.
  ENDLOOP.

  REFRESH LT_2010.

  SORT PT_2010 BY GONG_CD ORDNR POSNR ORDTY.
  DELETE ADJACENT DUPLICATES FROM PT_2010 COMPARING GONG_CD ORDNR POSNR ORDTY.

  READ TABLE PT_2010 INDEX 1.

  SELECT AUFNR, POSNR FROM AFPO
   WHERE AUFNR = @PT_2010-ORDNR
     INTO TABLE @DATA(LT_DUP_AUFNR).
  SORT LT_DUP_AUFNR BY AUFNR POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_DUP_AUFNR COMPARING AUFNR POSNR.
  IF LINES( LT_DUP_AUFNR ) = 1. " 복조장 아닌 오더도 처리대상


  ELSEIF LINES( LT_DUP_AUFNR ) > 1.

    LOOP AT GT_2010 INTO DATA(LS_CHK_CURRENT) WHERE ORDNR = PT_2010-ORDNR
                                                                   AND POSNR NE PT_2010-POSNR
                                                                   AND ORDTY = PT_2010-ORDTY.
      APPEND LS_CHK_CURRENT TO LT_2010_CHK.
    ENDLOOP.

    REFRESH PT_2010[].
    MOVE-CORRESPONDING LT_2010_CHK TO PT_2010[].

  ENDIF.

  LOOP AT PT_2010.
    IF PT_2010-CHECK_JEGO IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '재고 상태인 오더만 삭제 가능합니다.'(e48).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

* 이후공정 상태 확인 작업 진행중이면 삭제 불가
    READ TABLE GT_2010 INTO DATA(LS_2010_DEV) WITH KEY ORDNR = PT_2010-DMORD
                                                                                POSNR = PT_2010-DMLINE
                                                                                ORDTY = PT_2010-DMORDTY.
    IF SY-SUBRC EQ 0.
      LOOP AT GT_2010 INTO DATA(LS_2010_DEV_CHK) WHERE REORD = LS_2010_DEV-REORD
                                                                          AND RELINE = LS_2010_DEV-RELINE
                                                                          AND REORDTY = LS_2010_DEV-REORDTY.
        IF LS_2010_DEV_CHK-CHK_PRD = ABAP_TRUE.
          MESSAGE S003 DISPLAY LIKE 'E' WITH '이후 공정 작업 진행중으로 삭제 불가능합니다.'(e49).
          PV_CHK_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.

      ENDLOOP.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_PEGGING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_PEGGING .

  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LV_CHK_ERR.
  DATA : LO_JOJANG TYPE REF TO ZGTPP_CL_ROUTING_GAON.
  DATA : LV_MESSAGE TYPE CHAR100.
  DATA : LV_PEGGING_ORDNR TYPE ZGTPPT2010-ORDNR.
  DATA : LV_PEGGING_POSNR TYPE ZGTPPT2010-POSNR.
  DATA : LV_PEGGING_ORDTY TYPE ZGTPPT2010-ORDTY.
  DATA : LT_PEGGING LIKE TABLE OF GS_PEGGING.

  PERFORM CHK_PROCESS_PEGGING  TABLES LT_2010
                                                 CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF LT_2010[] IS INITIAL.
    RETURN.
  ENDIF.

  GT_ORIGN_2010 = LT_2010.

  REFRESH GT_PEGGING_2010.
  MOVE-CORRESPONDING LT_2010 TO GT_PEGGING_2010.

  READ TABLE LT_2010 INTO DATA(LS_2010) INDEX 1.
  GS_PEGGING_DISP-MATNR = LS_2010-MATNR.
  PERFORM SELECT_DATA_FROM_MATNR USING LS_2010-MATNR.

*  페깅 변경항 오더 선택화면
  CALL SCREEN '0240' STARTING AT 10 5 ENDING AT 145 20.

  READ TABLE GT_PEGGING INTO DATA(LS_PEGGING) WITH KEY CHECK = ABAP_TRUE.

  LV_PEGGING_ORDNR = LS_PEGGING-ORDNR.
  CASE LS_PEGGING-GCATG.
    WHEN '생산오더'.
      LV_PEGGING_ORDTY = 'PRD'.
    WHEN '구매오더'.
      LV_PEGGING_ORDTY = 'PO'.
  ENDCASE.

  LT_PEGGING =   VALUE #( FOR LW_PEGGING IN GT_PEGGING WHERE ( CHECK = ABAP_TRUE )
                                                                                ( CORRESPONDING #( LW_PEGGING ) ) ).

  IF LINES( LT_PEGGING ) = 1.
    LV_PEGGING_POSNR = LS_PEGGING-POSNR.
  ENDIF.

  CHECK LV_PEGGING_ORDNR IS NOT INITIAL.

  CREATE OBJECT LO_JOJANG
    EXPORTING
      IV_WERKS              = P_WERKS                 " 플랜트
      IV_GRPNR              = GV_GRPNR                 " 조장 구성표 번호
      IT_MAIN               = GT_MAKE_DISPLAY
      IT_SEQ_ROUTING_HEADER = GT_SEQ_ROUTING_HEADER
      IT_SEQ_ROUTING_SUB    = GT_SEQ_ROUTING_SUB
      IT_MAKED_2010         = GT_2010.


  LV_MESSAGE = LO_JOJANG->PROC_PEGGING(
                 IT_PEGGING_DATA = LT_2010
                 IV_TARGET_ORDER = LV_PEGGING_ORDNR " 오더번호
                 IV_TARGET_POSNR = LV_PEGGING_POSNR  " 판매 문서 항목
                 IV_TATGET_ORDTY = LV_PEGGING_ORDTY ). " 오더유형

  IF LV_MESSAGE IS NOT INITIAL.
    MESSAGE S003 WITH LV_MESSAGE DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

*  변경정보 MES전송
  ZGTPP_CL_ROUTING=>SEND_CHG_MES(
    IV_WERKS = P_WERKS           " 플랜트
    IV_SPGCD = P_SPGCD          " SPG 코드
    IV_GRPNR = GV_GRPNR ).    " 조장 구성표 번호

  PERFORM REFRESH_SCREEN_201.
  MESSAGE S003 WITH 'Pegging 변경되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_PROCESS_PEGGING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_PROCESS_PEGGING  TABLES   PT_2010 LIKE GT_2010
                                              CHANGING PV_CHK_ERR.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_NUM(2) TYPE N.
  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_2010_CHK LIKE TABLE OF GS_2010.
  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.

  CLEAR : PV_CHK_ERR.
  REFRESH PT_2010[].

  GO_GRID_0201->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  GO_GRID_0201->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_COLUMN[] IS NOT INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '컬럼을 선택할 수 없습니다.'(e18).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  IF 1 > LINES( LT_CELLS ).
    MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 셀만 선택해야 합니다.'(e19).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.

      SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
      READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 2.
      LV_CHART = LS_STRING.

      IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
        MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'(e02).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY CHART = LV_CHART
                                                                                                SEQNO = LV_SEQNO.

*  선택된 필드의 오더정보 찾기
    READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
      ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.
      IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
      ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO <LV_LINE>.

      CLEAR LV_NUM.
      CLEAR LV_FIELDNAME.
      LV_NUM =  LS_ROUTING-SEQNO + 0.
      LV_FIELDNAME = LV_NUM && '_SEQNO'.

      IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.
      IF <LV_GONGSEQ> IS NOT ASSIGNED. " 공정을 못찾으면 종료
        RETURN.
      ELSE.
        IF <LV_GONGSEQ> = 0. " 해당 공정 순번이 비어있다면 오더가 없다는 의미 다음순번
          CONTINUE.
        ENDIF.
      ENDIF.

      READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
      READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
      READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.

* 중복 필드라면 대상이 아님
      IF LS_CHAIN-CHK_DUP EQ ABAP_TRUE.
        CONTINUE.
      ENDIF.

      IF LS_CHAIN-ORDNR IS INITIAL.
        CONTINUE.
      ENDIF.

      IF LS_CHAIN-ORDTY NE 'PRD'.
        CONTINUE.
      ENDIF.

      READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY GONG_SEQ = LS_GONG-GONG_SEQ
                                                                      ORDNR = LS_CHAIN-ORDNR
                                                                      POSNR = LS_CHAIN-POSNR
                                                                       ORDTY = LS_CHAIN-ORDTY.
      IF SY-SUBRC EQ 0.
        SELECT SINGLE MTART FROM MARA
          INTO @DATA(LV_MTART)
         WHERE MATNR = @LS_2010-MATNR.
        IF LV_MTART = 'MCFE'.
          MESSAGE S003 DISPLAY LIKE 'E' WITH '제품 Pegging은 변경 할 수 없습니다.'(e56).
          PV_CHK_ERR = ABAP_TRUE.
          EXIT.
        ENDIF.

        APPEND LS_2010 TO PT_2010.
      ENDIF.
    ENDIF.
  ENDLOOP.

  REFRESH LT_2010.

  SORT PT_2010 BY GONG_CD ORDNR POSNR ORDTY.
  DELETE ADJACENT DUPLICATES FROM PT_2010 COMPARING GONG_CD ORDNR POSNR ORDTY.

  READ TABLE PT_2010 INDEX 1.

  SELECT AUFNR, POSNR FROM AFPO
   WHERE AUFNR = @PT_2010-ORDNR
     INTO TABLE @DATA(LT_DUP_AUFNR).
  SORT LT_DUP_AUFNR BY AUFNR POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_DUP_AUFNR COMPARING AUFNR POSNR.
  IF LINES( LT_DUP_AUFNR ) = 1. " 복조장 아닌 오더도 처리대상


  ELSEIF LINES( LT_DUP_AUFNR ) > 1.

    LOOP AT GT_2010 INTO DATA(LS_CHK_CURRENT) WHERE ORDNR = PT_2010-ORDNR
                                                                   AND POSNR NE PT_2010-POSNR
                                                                   AND ORDTY = PT_2010-ORDTY.
      APPEND LS_CHK_CURRENT TO LT_2010_CHK.
    ENDLOOP.

    REFRESH PT_2010[].
    MOVE-CORRESPONDING LT_2010_CHK TO PT_2010[].

  ENDIF.

  REFRESH : LT_2010_CHK, LT_2010.

  LOOP AT PT_2010.

* 이전공정들 확인을 위해 이전공정들 담아준다.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = PT_2010-GONG_SEQ.
    LV_SEQNO = LS_ROUTING-SEQNO.
    DO.
      LV_SEQNO = LV_SEQNO - 1.
      IF LV_SEQNO = 0.
        EXIT.
      ENDIF.
      READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY SEQNO = LV_SEQNO.

      LOOP AT GT_2010 INTO DATA(LS_2010_PRE) WHERE GONG_SEQ = LS_ROUTING-GONG_SEQ.
        READ TABLE LT_2010_CHK TRANSPORTING NO FIELDS WITH KEY ORDNR = LS_2010_PRE-DMORD
                                                                                    POSNR = LS_2010_PRE-DMLINE
                                                                                    ORDTY = LS_2010_PRE-DMORDTY.
        IF SY-SUBRC EQ 0.
          APPEND LS_2010_PRE TO LT_2010_CHK.
        ENDIF.
      ENDLOOP.
    ENDDO.

    IF LT_2010_CHK IS NOT INITIAL.
      APPEND LINES OF LT_2010_CHK TO LT_2010.
    ENDIF.

  ENDLOOP.

  SORT LT_2010 BY GONG_CD ORDNR ORDTY POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_2010 COMPARING GONG_CD ORDNR ORDTY POSNR.

* 생산 오더 상태 확인 "PAYO", "PCNF", "CNF"의 경우, 오류 메시지: 오더 + "오더는 생산 진행 중으로 삭제 할 수 없습니다."
* 이전 공정 오더 상태 확인(ZGTPPT2010-REORD), 이전 공정 오더가 생산 오더("PRD") 이면서 오더 상태 "PAYO", "PCNF", "CNF"의 경우
* 오류 메시지: "이전 공정" 오더 + "오더는 생산 진행 중으로 삭제 할 수 없습니다."
  LOOP AT LT_2010 INTO DATA(LS_2010_WQ).
    IF LS_2010_WQ-CHK_PRD = ABAP_TRUE.
      MESSAGE S006 DISPLAY LIKE 'E' WITH  '이전공정'(e55) LS_2010_WQ-ORDNR '오더는 생산 진행 중으로 Pegging 진행할 수 없습니다..'(e54).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_DATA_FROM_MATNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_2010_MATNR
*&---------------------------------------------------------------------*
FORM SELECT_DATA_FROM_MATNR  USING PV_MATNR TYPE MATNR.

  DATA : BEGIN OF LS_SUM_MSEG,
           AUFNR LIKE MSEG-AUFNR,
           AUFPS LIKE MSEG-AUFPS,
           MENGE LIKE MSEG-MENGE,
         END OF LS_SUM_MSEG.
  DATA : LT_SUM_MSEG LIKE TABLE OF LS_SUM_MSEG.
  DATA : BEGIN OF LS_SUM_MSEG2,
           EBELN LIKE MSEG-EBELN,
           EBELP LIKE MSEG-EBELP,
           MENGE LIKE MSEG-MENGE,
         END OF LS_SUM_MSEG2.
  DATA : LT_SUM_MSEG2 LIKE TABLE OF LS_SUM_MSEG2.

  DATA : BEGIN OF LS_AFPO,
           AUFNR LIKE AFPO-AUFNR,
           POSNR LIKE AFPO-POSNR,
           PSMNG LIKE AFPO-PSMNG,
           WEMNG LIKE AFPO-WEMNG,
           PSAMG LIKE AFPO-PSAMG,
           MEINS LIKE AFPO-MEINS,
         END OF LS_AFPO.
  DATA : LT_AFPO LIKE TABLE OF LS_AFPO.
  DATA : LT_AFPO_IDX LIKE TABLE OF LS_AFPO.
  DATA : LT_AFPO_ORIGN LIKE TABLE OF LS_AFPO.
  DATA : LT_AFPO_SUM LIKE TABLE OF LS_AFPO.
  DATA : LT_AFPO_ORIGN_SUM LIKE TABLE OF LS_AFPO.
  DATA : LT_AFPO_CHK LIKE TABLE OF LS_AFPO.
  DATA : LT_AFPO_CHK2 LIKE TABLE OF LS_AFPO.

  DATA : BEGIN OF LS_EKPO,
           EBELN LIKE EKPO-EBELN,
           EBELP LIKE EKPO-EBELP,
           MENGE LIKE EKPO-MENGE,
           MEINS LIKE EKPO-MEINS,
         END OF LS_EKPO.
  DATA : LT_EKPO LIKE TABLE OF LS_EKPO.
  DATA : LT_EKPO_IDX LIKE TABLE OF LS_EKPO.
  DATA : LT_EKPO_SUM LIKE TABLE OF LS_EKPO.
  DATA : LT_EKPO_CHK LIKE TABLE OF LS_EKPO.
  DATA : LT_EKPO_CHK2 LIKE TABLE OF LS_EKPO.

* - 선택한 오더의 자재, 소요량 및 조장과 동일한 재고 조회(복조장의 경우 조장 여러 개)
*    동일한 자재와 수량의 재고를 찾고 최종 입고에 사용한 생산 오더 확인
  READ TABLE GT_PEGGING_2010 INTO DATA(LS_2010) INDEX 1.
  SELECT AUFNR, POSNR, PSMNG, WEMNG, PSAMG, MEINS
    FROM  AFPO
   WHERE AUFNR = @LS_2010-ORDNR
     INTO CORRESPONDING FIELDS OF TABLE @LT_AFPO_ORIGN.

  REFRESH LT_AFPO_ORIGN_SUM.
  LOOP AT LT_AFPO_ORIGN INTO LS_AFPO.
    CLEAR LS_AFPO-POSNR.
    COLLECT LS_AFPO INTO LT_AFPO_ORIGN_SUM.
  ENDLOOP.

  GV_PAGGING_GONG_CD = LS_2010-GONG_CD.

  SELECT LGORT, CHARG, LABST, INSME, SPEME
    FROM ZGTCV_STOCKVAL
    WHERE WERKS = @P_WERKS
        AND MATNR = @PV_MATNR
        AND PROCCODE = @GV_PAGGING_GONG_CD
       INTO TABLE @DATA(LT_STOCKVAL).

  SORT LT_STOCKVAL BY LGORT CHARG.
  DELETE ADJACENT DUPLICATES FROM LT_STOCKVAL COMPARING LGORT CHARG.

  IF LT_STOCKVAL[] IS NOT INITIAL.
    SELECT B~MBLNR, B~MJAHR, B~ZEILE, B~AUFNR, B~AUFPS, B~BWART, B~MENGE, B~LGORT, B~CHARG
        FROM @LT_STOCKVAL AS A
        INNER JOIN MSEG AS B
                              ON B~LGORT = A~LGORT
                             AND B~CHARG = A~CHARG
      WHERE B~MATNR = @PV_MATNR
          AND B~WERKS = @P_WERKS
          AND B~AUFNR IS NOT INITIAL
          AND B~BWART IN ( '101', '102' )
      INTO TABLE @DATA(LT_MSEG_CO).


    SELECT B~MBLNR, B~MJAHR, B~ZEILE, B~EBELN, B~EBELP, B~BWART, B~MENGE, B~LGORT, B~CHARG
        FROM @LT_STOCKVAL AS A
        INNER JOIN MSEG AS B
                              ON B~LGORT = A~LGORT
                             AND B~CHARG = A~CHARG
      WHERE B~MATNR = @PV_MATNR
          AND B~WERKS = @P_WERKS
          AND B~EBELN IS NOT INITIAL
          AND B~BWART IN ( '101', '102' )
      INTO TABLE @DATA(LT_MSEG_PO).

  ENDIF.

  SORT LT_MSEG_CO BY MBLNR MJAHR ZEILE.
  DELETE ADJACENT DUPLICATES FROM LT_MSEG_CO COMPARING MBLNR MJAHR ZEILE.

  SORT LT_MSEG_PO BY MBLNR MJAHR ZEILE.
  DELETE ADJACENT DUPLICATES FROM LT_MSEG_PO COMPARING MBLNR MJAHR ZEILE.

  LOOP AT LT_MSEG_CO INTO DATA(LS_MSEG_CO).
    CLEAR LS_SUM_MSEG.
    LS_SUM_MSEG-AUFNR = LS_MSEG_CO-AUFNR.
    LS_SUM_MSEG-AUFPS = LS_MSEG_CO-AUFPS.
    CASE LS_MSEG_CO-BWART.
      WHEN '101'.
        LS_SUM_MSEG-MENGE = LS_MSEG_CO-MENGE .
      WHEN '102'.
        LS_SUM_MSEG-MENGE = LS_MSEG_CO-MENGE * -1.
    ENDCASE.
    COLLECT LS_SUM_MSEG INTO LT_SUM_MSEG.
  ENDLOOP.

  LOOP AT LT_MSEG_PO INTO DATA(LS_MSEG_PO).
    CLEAR LS_SUM_MSEG2.
    LS_SUM_MSEG2-EBELN = LS_MSEG_PO-EBELN.
    LS_SUM_MSEG2-EBELP = LS_MSEG_PO-EBELP.
    CASE LS_MSEG_PO-BWART.
      WHEN '101'.
        LS_SUM_MSEG2-MENGE = LS_MSEG_PO-MENGE .
      WHEN '102'.
        LS_SUM_MSEG2-MENGE = LS_MSEG_PO-MENGE * -1.
    ENDCASE.
    COLLECT LS_SUM_MSEG2 INTO LT_SUM_MSEG2.
  ENDLOOP.

  READ TABLE LT_AFPO_ORIGN_SUM INTO DATA(LS_AFPO_ORIGN_SUM) INDEX 1.
  CLEAR GV_CHK_PSMNG.
  GV_CHK_PSMNG = LS_AFPO_ORIGN_SUM-PSMNG.
  LOOP AT LT_SUM_MSEG ASSIGNING FIELD-SYMBOL(<LS_SUM_MSEG>).
*  생산오더별 오더별배치자재 입고 수량 합이 오더의 오더 계획된 총 수량 합보다 크거나 같을경우 비교대상
    IF <LS_SUM_MSEG>-MENGE >= LS_AFPO_ORIGN_SUM-PSMNG.
    ELSE. " 작은 경우는 삭제
      DELETE LT_SUM_MSEG.
    ENDIF.
  ENDLOOP.

  LOOP AT LT_SUM_MSEG2 ASSIGNING FIELD-SYMBOL(<LS_SUM_MSEG2>).
*  생산오더별 오더별배치자재 입고 수량 합이 오더의 오더 계획된 총 수량 합보다 크거나 같을경우 비교대상
    IF <LS_SUM_MSEG2>-MENGE >= LS_AFPO_ORIGN_SUM-PSMNG.
    ELSE. " 작은 경우는 삭제
      DELETE LT_SUM_MSEG2.
    ENDIF.
  ENDLOOP.

* 생산오더 정보.
  SORT LT_SUM_MSEG BY AUFNR.

  IF LT_SUM_MSEG[] IS NOT INITIAL.
    SELECT B~AUFNR, B~POSNR, B~PSMNG, B~WEMNG, B~PSAMG, B~MEINS
      FROM @LT_SUM_MSEG  AS A
      INNER JOIN AFPO    AS B
                               ON B~AUFNR = A~AUFNR
                              AND B~POSNR = A~AUFPS
      INTO CORRESPONDING FIELDS OF TABLE @LT_AFPO.
  ENDIF.

  DELETE LT_AFPO WHERE AUFNR = LS_2010-ORDNR.

  DATA(LT_CHK_AFPO_MULTY) = LT_AFPO.

  SORT LT_CHK_AFPO_MULTY BY AUFNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_AFPO_MULTY COMPARING AUFNR.

  LOOP AT LT_CHK_AFPO_MULTY ASSIGNING FIELD-SYMBOL(<LS_CHK_AFPO_MULTY>).
*   해당 오더가 복조장인지 확인
    SELECT AUFNR, POSNR FROM AFPO
      INTO TABLE @DATA(LT_CHK_LINES)
      WHERE AUFNR = @<LS_CHK_AFPO_MULTY>-AUFNR.
    IF SY-SUBRC EQ 0 AND 1 < LINES( LT_CHK_LINES ).
* 복조장 일시 해당 오더가 조장구성표에 존재하는지 확인
      SELECT ORDNR, POSNR FROM ZGTPPT2010
        INTO TABLE @DATA(LT_CHK_2010_LINES)
        WHERE ORDNR = @<LS_CHK_AFPO_MULTY>-AUFNR.
* 해당 오더가 조장구성표에 존재 할때 모든 품목이 자재상태가 아니라면 페깅 대상 아님
      IF SY-SUBRC EQ 0.
        REFRESH LT_AFPO_IDX.
        LT_AFPO_IDX = VALUE #( FOR LW_AFPO IN LT_AFPO WHERE ( AUFNR = <LS_CHK_AFPO_MULTY>-AUFNR )
                                                                        ( CORRESPONDING  #( LW_AFPO ) ) ).
        IF LINES( LT_AFPO_IDX ) NE LINES( LT_CHK_2010_LINES ).
          DELETE LT_AFPO WHERE AUFNR = <LS_CHK_AFPO_MULTY>-AUFNR.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDLOOP.

  REFRESH LT_AFPO_SUM.
  LOOP AT LT_AFPO INTO LS_AFPO.
    CLEAR LS_AFPO-POSNR.
    COLLECT LS_AFPO INTO LT_AFPO_SUM.
  ENDLOOP.

  SORT LT_AFPO_ORIGN BY PSMNG DESCENDING.

  REFRESH GT_PEGGING.

  READ TABLE LT_AFPO_ORIGN_SUM INTO LS_AFPO_ORIGN_SUM INDEX 1.
  LOOP AT LT_AFPO_SUM INTO DATA(LS_AFPO_SUM).
    IF LS_AFPO_SUM-PSMNG => LS_AFPO_ORIGN_SUM-PSMNG."총 소요량이 같으면 비교 시작
*- 변경 대상 오더의 조장구성(복조장)을 고려하여 선택,
*   복조장 선택 시 품목 순서는 바뀔 수 있지만 전체 구성은 같아야 함
      IF LINES( LT_AFPO_ORIGN ) > 1. "복조장 구성시

        REFRESH : LT_AFPO_CHK, LT_AFPO_CHK2.
        LT_AFPO_CHK = VALUE #( FOR WA_AFPO IN LT_AFPO WHERE ( AUFNR = LS_AFPO_SUM-AUFNR ) ( CORRESPONDING #( WA_AFPO ) ) ).
        IF LINES( LT_AFPO_CHK ) = 1.
          IF LS_AFPO_SUM-PSMNG >= LS_AFPO_ORIGN_SUM-PSMNG.
            READ TABLE LT_AFPO_CHK INTO DATA(LS_AFPO_CHK2) INDEX 1.
            APPEND LS_AFPO_CHK2 TO LT_AFPO_CHK2.
            REFRESH LT_AFPO_CHK.
          ENDIF.

        ELSEIF LINES( LT_AFPO_CHK ) = LINES( LT_AFPO_ORIGN ).

          SORT LT_AFPO_CHK BY PSMNG DESCENDING.
          LOOP AT LT_AFPO_ORIGN INTO DATA(LS_AFPO_ORIGN).

            LOOP AT  LT_AFPO_CHK INTO DATA(LS_AFPO_CHK).
              IF LS_AFPO_ORIGN-PSMNG =< LS_AFPO_CHK-PSMNG.
                APPEND LS_AFPO_CHK TO LT_AFPO_CHK2.
                DELETE TABLE LT_AFPO_CHK FROM LS_AFPO_CHK.
              ENDIF.
            ENDLOOP.
          ENDLOOP.
        ENDIF.
      ELSE.

        REFRESH : LT_AFPO_CHK, LT_AFPO_CHK2.
        LT_AFPO_CHK = VALUE #( FOR WA_AFPO IN LT_AFPO WHERE ( AUFNR = LS_AFPO_SUM-AUFNR ) ( CORRESPONDING #( WA_AFPO ) ) ).

        IF LINES( LT_AFPO_CHK ) = 1.
          READ TABLE LT_AFPO_CHK INTO LS_AFPO_CHK2 INDEX 1.
          APPEND LS_AFPO_CHK2 TO LT_AFPO_CHK2.
          REFRESH LT_AFPO_CHK.
        ELSEIF LINES( LT_AFPO_CHK ) > 1.
          CONTINUE.

        ENDIF.
      ENDIF.

      IF LT_AFPO_CHK[] IS INITIAL. " 처리결과 값이 비어있다면, 모든데이터 정합성이 맞는다는 의미, 화면 디스플레이 추가
        LOOP AT LT_AFPO_CHK2 INTO DATA(LS_DATA).
          APPEND INITIAL LINE TO GT_PEGGING ASSIGNING FIELD-SYMBOL(<LS_PEGGING>).
*           유형
          <LS_PEGGING>-TYPES = 'Stock'.
          <LS_PEGGING>-MATNR = PV_MATNR.
          <LS_PEGGING>-ORDNR = LS_DATA-AUFNR.
          <LS_PEGGING>-POSNR = LS_DATA-POSNR + 0.
          <LS_PEGGING>-GCATG = '생산오더'.
          <LS_PEGGING>-PSMNG = LS_DATA-PSMNG.
          <LS_PEGGING>-MEINS = LS_DATA-MEINS.
          <LS_PEGGING>-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = PV_MATNR ).
          READ TABLE LT_MSEG_CO INTO LS_MSEG_CO WITH KEY AUFNR = LS_DATA-AUFNR
                                                                           AUFPS = LS_DATA-POSNR
                                                                           BWART = '101'.
          <LS_PEGGING>-CHARG = LS_MSEG_CO-CHARG.
          <LS_PEGGING>-LGORT = LS_MSEG_CO-LGORT.

          READ TABLE LT_STOCKVAL INTO DATA(LS_STOCKVAL) WITH KEY CHARG = LS_MSEG_CO-CHARG
                                                                                                 LGORT = LS_MSEG_CO-LGORT.

          <LS_PEGGING>-LABST = LS_STOCKVAL-LABST.
          <LS_PEGGING>-INSME = LS_STOCKVAL-INSME.
          <LS_PEGGING>-SPEME = LS_STOCKVAL-SPEME.

          PERFORM GET_JOJANGNO USING <LS_PEGGING>-ORDNR <LS_PEGGING>-POSNR CHANGING <LS_PEGGING>-GRPNR.

        ENDLOOP.
      ENDIF.

    ENDIF.
  ENDLOOP.


* 구매오더 정보
  SORT LT_SUM_MSEG2 BY EBELN.

  IF LT_SUM_MSEG2[] IS NOT INITIAL.
    SELECT B~EBELN, B~EBELP, B~MENGE, B~MEINS
      FROM @LT_SUM_MSEG2  AS A
      INNER JOIN EKPO    AS B
                               ON B~EBELN = A~EBELN
                              AND B~EBELP = A~EBELP
                              AND B~LOEKZ = ' '
      INTO CORRESPONDING FIELDS OF TABLE @LT_EKPO.
  ENDIF.

  DATA(LT_CHK_EKPO_MULTY) = LT_EKPO.

  SORT LT_CHK_EKPO_MULTY BY EBELN.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_EKPO_MULTY COMPARING EBELN.

  LOOP AT LT_CHK_EKPO_MULTY ASSIGNING FIELD-SYMBOL(<LS_CHK_EKPO_MULTY>).
*   해당 오더가 복조장인지 확인
    SELECT EBELN, EBELP FROM EKPO
      INTO TABLE @DATA(LT_CHK_LINES_EFPO)
      WHERE EBELN = @<LS_CHK_EKPO_MULTY>-EBELN
        AND LOEKZ = ' '.
    IF SY-SUBRC EQ 0 AND 1 < LINES( LT_CHK_LINES_EFPO ).
* 복조장 일시 해당 오더가 조장구성표에 존재하는지 확인
      SELECT ORDNR, POSNR FROM ZGTPPT2010
        INTO TABLE @LT_CHK_2010_LINES
        WHERE ORDNR = @<LS_CHK_EKPO_MULTY>-EBELN
          AND GONG_CD = @GV_PAGGING_GONG_CD.
* 해당 오더가 조장구성표에 존재 할때 모든 품목이 자재상태가 아니라면 페깅 대상 아님
      IF SY-SUBRC EQ 0.
        SORT LT_CHK_2010_LINES BY ORDNR POSNR.
        DELETE ADJACENT DUPLICATES FROM LT_CHK_2010_LINES COMPARING ORDNR POSNR.

        REFRESH LT_EKPO_IDX.
        LT_EKPO_IDX = VALUE #( FOR LW_EKPO IN LT_EKPO WHERE ( EBELN = <LS_CHK_EKPO_MULTY>-EBELN )
                                                                        ( CORRESPONDING  #( LW_EKPO ) ) ).
        IF LINES( LT_EKPO_IDX ) NE LINES( LT_CHK_LINES_EFPO ).
          DELETE LT_EKPO WHERE EBELN = <LS_CHK_EKPO_MULTY>-EBELN.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDLOOP.


  REFRESH LT_EKPO_SUM.
  LOOP AT LT_EKPO INTO LS_EKPO.
    CLEAR LS_EKPO-EBELP.
    COLLECT LS_EKPO INTO LT_EKPO_SUM.
  ENDLOOP.

  SORT LT_AFPO_ORIGN BY PSMNG DESCENDING.

  READ TABLE LT_AFPO_ORIGN_SUM INTO LS_AFPO_ORIGN_SUM INDEX 1.
  LOOP AT LT_EKPO_SUM INTO DATA(LS_EKPO_SUM).
    IF LS_EKPO_SUM-MENGE => LS_AFPO_ORIGN_SUM-PSMNG."총 소요량이 같으면 비교 시작
*- 변경 대상 오더의 조장구성(복조장)을 고려하여 선택,
*   복조장 선택 시 품목 순서는 바뀔 수 있지만 전체 구성은 같아야 함
      IF LINES( LT_AFPO_ORIGN ) > 1. "복조장 구성시

        REFRESH : LT_EKPO_CHK, LT_EKPO_CHK2.
        LT_EKPO_CHK = VALUE #( FOR WA_EKPO IN LT_EKPO WHERE ( EBELN = LS_EKPO_SUM-EBELN ) ( CORRESPONDING #( WA_EKPO ) ) ).
        IF LINES( LT_EKPO_CHK ) = 1.
          CONTINUE.

        ELSEIF LINES( LT_EKPO_CHK ) = LINES( LT_AFPO_ORIGN ).

          SORT LT_EKPO_CHK BY MENGE DESCENDING.
          LOOP AT LT_AFPO_ORIGN INTO LS_AFPO_ORIGN.

            LOOP AT  LT_EKPO_CHK INTO DATA(LS_EKPO_CHK).
              IF LS_AFPO_ORIGN-PSMNG =< LS_EKPO_CHK-MENGE.
                APPEND LS_EKPO_CHK TO LT_EKPO_CHK2.
                DELETE TABLE LT_EKPO_CHK FROM LS_EKPO_CHK.
              ENDIF.
            ENDLOOP.
          ENDLOOP.
        ENDIF.
      ELSE.

        REFRESH : LT_EKPO_CHK, LT_EKPO_CHK2.
        LT_EKPO_CHK = VALUE #( FOR WA_EKPO IN LT_EKPO WHERE ( EBELN = LS_EKPO_SUM-EBELN ) ( CORRESPONDING #( WA_EKPO ) ) ).
        IF LINES( LT_EKPO_CHK ) = 1.
          READ TABLE LT_EKPO_CHK INTO DATA(LS_EKPO_CHK2) INDEX 1.
          APPEND LS_EKPO_CHK2 TO LT_EKPO_CHK2.
          REFRESH LT_EKPO_CHK.
        ELSEIF LINES( LT_EKPO_CHK ) > 1.
          CONTINUE.

        ENDIF.
      ENDIF.

      IF LT_EKPO_CHK[] IS INITIAL. " 처리결과 값이 비어있다면, 모든데이터 정합성이 맞는다는 의미, 화면 디스플레이 추가
        LOOP AT LT_EKPO_CHK2 INTO DATA(LS_DATA_EKPO).
          APPEND INITIAL LINE TO GT_PEGGING ASSIGNING <LS_PEGGING>.
*           유형
          <LS_PEGGING>-TYPES = 'Stock'.
          <LS_PEGGING>-MATNR = PV_MATNR.
          <LS_PEGGING>-ORDNR = LS_DATA_EKPO-EBELN.
          <LS_PEGGING>-POSNR = LS_DATA_EKPO-EBELP + 0.
          <LS_PEGGING>-GCATG = '구매오더'.
          <LS_PEGGING>-PSMNG = LS_DATA_EKPO-MENGE.
          <LS_PEGGING>-MEINS = LS_DATA_EKPO-MEINS.
          <LS_PEGGING>-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = PV_MATNR ).
          READ TABLE LT_MSEG_PO INTO LS_MSEG_PO WITH KEY EBELN = LS_DATA_EKPO-EBELN
                                                                                   EBELP = LS_DATA_EKPO-EBELP
                                                                                   BWART = '101'.
          <LS_PEGGING>-CHARG = LS_MSEG_PO-CHARG.
          <LS_PEGGING>-LGORT = LS_MSEG_PO-LGORT.

          READ TABLE LT_STOCKVAL INTO LS_STOCKVAL WITH KEY CHARG = LS_MSEG_PO-CHARG
                                                                                  LGORT = LS_MSEG_PO-LGORT.

          <LS_PEGGING>-LABST = LS_STOCKVAL-LABST.
          <LS_PEGGING>-INSME = LS_STOCKVAL-INSME.
          <LS_PEGGING>-SPEME = LS_STOCKVAL-SPEME.

          PERFORM GET_JOJANGNO USING <LS_PEGGING>-ORDNR <LS_PEGGING>-POSNR CHANGING <LS_PEGGING>-GRPNR.

        ENDLOOP.
      ENDIF.

    ENDIF.
  ENDLOOP.

* 출력 필드 세팅
  DATA : LV_INLENGTH TYPE I.
  DATA : LV_INLENGTH_C(11) TYPE C.

  READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_SEQ_ROUTING) WITH KEY GONG_SEQ = LS_2010-GONG_SEQ.
  GS_PEGGING_DISP-GONG_TEXT = LS_SEQ_ROUTING-CHART_VAL && '(' && LS_SEQ_ROUTING-CHART && ')'.
  LV_INLENGTH = LS_AFPO_ORIGN_SUM-PSMNG.
  LV_INLENGTH_C = LV_INLENGTH.
  CONDENSE LV_INLENGTH_C.
  GS_PEGGING_DISP-INLENGTH = LV_INLENGTH_C &&  LS_AFPO_ORIGN_SUM-MEINS.
  GS_PEGGING_DISP-MATNR_RE = PV_MATNR.
  GS_PEGGING_DISP-MAKTX_RE = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = PV_MATNR ).



ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_JOJANGNO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_PEGGING>_AUFNR
*&      --> <LS_PEGGING>_POSNR
*&      <-- <LS_PEGGING>_GRPNR
*&---------------------------------------------------------------------*
FORM GET_JOJANGNO  USING    PV_ORDNR TYPE ZGTPPT2010-ORDNR
                                            PV_POSNR
                           CHANGING    PV_GRPNR TYPE ZGTEGRPNR.

  DATA : LV_POSNR(6) TYPE N.

  LV_POSNR = PV_POSNR + 0.

  SELECT SINGLE GRPNR
    FROM ZGTPPT2010
    INTO PV_GRPNR
   WHERE GONG_CD = GV_PAGGING_GONG_CD
     AND ORDNR = PV_ORDNR
     AND POSNR = LV_POSNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0240
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0240 .

  CREATE OBJECT GO_CONTAIN_0240
    EXPORTING
      CONTAINER_NAME              = 'GV_CONTAIN_0240'                " Name of the Screen CustCtrl Name to Link Container To
    EXCEPTIONS
      CNTL_ERROR                  = 1                " CNTL_ERROR
      CNTL_SYSTEM_ERROR           = 2                " CNTL_SYSTEM_ERROR
      CREATE_ERROR                = 3                " CREATE_ERROR
      LIFETIME_ERROR              = 4                " LIFETIME_ERROR
      LIFETIME_DYNPRO_DYNPRO_LINK = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.


  CREATE OBJECT GO_GRID_0240
    EXPORTING
      I_PARENT      = GO_CONTAIN_0240
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0240
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0240 .

  CLEAR GS_LAYOUT_0240.
  GS_LAYOUT_0240-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0240-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0240-NO_ROWMARK   = 'X'.
  GS_LAYOUT_0240-SEL_MODE   = 'C'.
  GS_LAYOUT_0240-STYLEFNAME = 'CELLTAB'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0240
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0240 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2140TOP'
      I_INTERNAL_TABNAME     = 'GS_PEGGING'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0240[]
    TABLES
      IT_DATA         = GT_PEGGING
    EXCEPTIONS
      OTHERS          = 1.


  IF NOT LINE_EXISTS( GT_FIELDCAT_0240[ FIELDNAME = 'CHECK' ] ).
    APPEND INITIAL LINE TO GT_FIELDCAT_0240 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    <LS_FCAT>-FIELDNAME = 'CHECK'.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
  ENDIF.

  IF NOT LINE_EXISTS( GT_FIELDCAT_0240[ FIELDNAME = 'TYPES' ] ).
    APPEND INITIAL LINE TO GT_FIELDCAT_0240 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'TYPES'.
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
  ENDIF.



  LOOP AT GT_FIELDCAT_0240 ASSIGNING <LS_FCAT>.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'CHECK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '선택'(f01).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'TYPES'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '유형'(f40).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'PSMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '수량'(f41).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'LABST'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '가용'(f42).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'INSME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품질'(f43).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'SPEME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '보류'(f44).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(f27).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'CHARG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '배치번호'(f45).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재내역'(f46).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'ORDNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'(f47).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'GCATG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '범주'(f20).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목번호'(f48).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '저장위치'(f49).
        <LS_FCAT>-JUST = 'C'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0240
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0240 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  LOOP AT GT_PEGGING ASSIGNING FIELD-SYMBOL(<LS_PEGGING>).
    REFRESH LT_CELLTAB.
    CLEAR LS_CELLTAB.
    LS_CELLTAB-FIELDNAME = 'TYPES'.
    LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_GROUP.
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.

    <LS_PEGGING>-CELLTAB = LT_CELLTAB.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0240
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0240 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0240
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0240_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0240_DISPLAY .

  CALL METHOD GO_GRID_0240->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0240
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0240
      I_BYPASSING_BUFFER   = ABAP_TRUE
    CHANGING
      IT_OUTTAB            = GT_PEGGING
      IT_FIELDCATALOG      = GT_FIELDCAT_0240.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0240->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0240->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  CHECK_MATNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_MATNR INPUT.

  CLEAR GS_PEGGING_DISP-MAKTX_RE.

  SELECT SINGLE MAKTX
     FROM ZGTCVMSTVAL
       INTO GS_PEGGING_DISP-MAKTX_RE
     WHERE WERKS = P_WERKS
       AND MATNR = GS_PEGGING_DISP-MATNR_RE
       AND PDCAPROCCODE = GV_PAGGING_GONG_CD
       AND MMSTA = SPACE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_MATNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_MATNR INPUT.

  DATA : BEGIN OF LS_MATNR,
           MATNR TYPE MATNR,
           MAKTX TYPE MAKTX,
         END OF LS_MATNR.
  DATA : LT_MATNR LIKE TABLE OF LS_MATNR.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  SELECT MATNR MAKTX
     FROM ZGTCVMSTVAL
       INTO CORRESPONDING FIELDS OF TABLE LT_MATNR
     WHERE WERKS = P_WERKS
       AND PDCAPROCCODE = GV_PAGGING_GONG_CD
       AND MMSTA = SPACE.

  SORT LT_MATNR BY MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING MATNR.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'MATNR'
*     DYNPPROG        = SY-CPROG                 "현재 프로그램명->ZTER0010
*     DYNPNR          = SY-DYNNR                 "현재 화면번호->0100
      DYNPROFIELD     = 'GS_MAKE_ORDER-MATNR'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '자재코드 조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      VALUE_TAB       = LT_MATNR                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT        = LS_RETURN_TAB-FIELDVAL
      IMPORTING
        OUTPUT       = GS_PEGGING_DISP-MATNR_RE
      EXCEPTIONS
        LENGTH_ERROR = 1
        OTHERS       = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE LT_MATNR INTO LS_MATNR WITH KEY MATNR = GS_PEGGING_DISP-MATNR_RE.
    GS_PEGGING_DISP-MAKTX_RE = LS_MATNR-MAKTX.

    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'ENTE'              " Function code
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
        OTHERS                 = 2.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_CHECKBOX_0240
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CHECKBOX_0240 .

  LOOP AT GT_PEGGING ASSIGNING FIELD-SYMBOL(<LS_PEGGING>).
    CLEAR <LS_PEGGING>-CHECK.
  ENDLOOP.

  READ TABLE GT_PEGGING INTO DATA(LS_PEGGING) INDEX GV_CHK_LINE.
  LOOP AT GT_PEGGING ASSIGNING <LS_PEGGING> WHERE ORDNR = LS_PEGGING-ORDNR.
    <LS_PEGGING>-CHECK = GV_CHK_VALUE.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0240.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ZZYUSCD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_RESULT_ORDNO
*&      <-- <LS_2000_CHG>_ZZYUSCD
*&---------------------------------------------------------------------*
FORM GET_ZZYUSCD  USING    PV_ORDNO
                  CHANGING PV_ZZYUSCD TYPE ZGTEYUSCD.

  SELECT SINGLE    K~VKORG, K~VKGRP, B~KDKG4
    FROM  VBAK AS K
  INNER JOIN VBKD AS B
                         ON B~VBELN = K~VBELN
  WHERE K~VBELN = @PV_ORDNO
    INTO @DATA(LS_VBAK).

*  업업소 확인
  CALL FUNCTION 'ZGTSD_GET_ZZYUSCD'
    EXPORTING
      I_VKORG   = LS_VBAK-VKORG
      I_VKGRP   = LS_VBAK-VKGRP
      I_KDKG4   = LS_VBAK-KDKG4
    IMPORTING
      E_ZZYUSCD = PV_ZZYUSCD.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_AND_DISP_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_AND_DISP_TEXT .

  DATA : LT_TEXT TYPE TABLE OF CHAR255.
  DATA : LT_LINE TYPE TABLE OF TLINE.
  DATA : LV_NAME TYPE THEAD-TDNAME.

  CASE GS_MAIN_200-GCATG.
    WHEN '생산오더'.
      SELECT SINGLE * FROM ZGTPPT2001
        WHERE ORDNO = @GS_MAIN_200-ORDNO
          AND POSNR = @GS_MAIN_200-POSNR
         INTO @DATA(LS_2001).

      SPLIT LS_2001-SNOTE AT CL_ABAP_CHAR_UTILITIES=>NEWLINE INTO TABLE LT_TEXT.
    WHEN OTHERS.
      LV_NAME = GS_MAIN_200-ORDNO.
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
  ENDCASE.

  CALL FUNCTION 'ZGTPP_UTILL_TEXTEDIT'
    EXPORTING
      IV_MODE  = '1'
      IV_TITLE = '특기사항'
    CHANGING
      CT_TEXT  = LT_TEXT.

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
  GV_DYNTXT-TEXT = '공정보빈동경배수관리'.
  GV_DYNTXT-QUICKINFO = '공정보빈동경배수관리'.
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
  CASE SY-UCOMM.
    WHEN 'FC01'.
      LV_TABNAME = 'ZGTPPT2002'.
      LV_TITLE = '공정보빈동경배수관리'.

  ENDCASE.


  TRY.

      CALL FUNCTION 'ZGTPP_UTILL_VIEW'
        EXPORTING
          IV_TABNAME = LV_TABNAME
          IV_TITLE   = LV_TITLE.

    CATCH CX_ROOT INTO DATA(LO_ROOT).

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_SEPERATE_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_SEPERATE_PR .

  DATA : LT_2010 LIKE GT_2010.
  DATA : LV_CHK_ERR.
  DATA : LO_JOJANG TYPE REF TO ZGTPP_CL_ROUTING_GAON.
  DATA : LT_RESULT TYPE BAPI_ORDER_RETURN_TT.

  PERFORM CHK_PROCESS_SEPERATE_PR TABLES LT_2010
                                                 CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '개별 PR전환 진행합니다. 계속 진행 하시겠습니까?'
    '작업확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CREATE OBJECT LO_JOJANG
    EXPORTING
      IV_WERKS              = P_WERKS                 " 플랜트
      IV_GRPNR              = GV_GRPNR                 " 조장 구성표 번호
      IT_MAIN               = GT_MAKE_DISPLAY
      IT_SEQ_ROUTING_HEADER = GT_SEQ_ROUTING_HEADER
      IT_SEQ_ROUTING_SUB    = GT_SEQ_ROUTING_SUB
      IT_MAKED_2010         = GT_2010.

  LT_RESULT = LO_JOJANG->PROCESS_SEPERATE_PR( IT_2010 = LT_2010 ).

  IF LINE_EXISTS( LT_RESULT[ TYPE = 'E' ] ).
    READ TABLE LT_RESULT INTO DATA(LS_RESULT) WITH KEY TYPE = 'E'.
    MESSAGE S006 DISPLAY LIKE 'E' WITH LS_RESULT-MESSAGE.
    RETURN.
  ENDIF.

*  변경정보 MES전송
  ZGTPP_CL_ROUTING=>SEND_CHG_MES(
    IV_WERKS = P_WERKS           " 플랜트
    IV_SPGCD = P_SPGCD          " SPG 코드
    IV_GRPNR = GV_GRPNR ).    " 조장 구성표 번호

  PERFORM REFRESH_SCREEN_201.
  READ TABLE LT_RESULT INTO LS_RESULT WITH KEY TYPE = 'S'.
  MESSAGE S006 WITH LS_RESULT-MESSAGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_PROCESS_SEPERATE_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_PROCESS_SEPERATE_PR  TABLES   PT_2010 LIKE GT_2010
                                              CHANGING PV_CHK_ERR.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_STRING     TYPE  STRING.
  DATA : LV_TABIX TYPE I.

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.

  GO_GRID_0201->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  IF LT_COLUMN[] IS NOT INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '컬럼을 선택할 수 없습니다.'(e18).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  GO_GRID_0201->GET_SELECTED_CELLS_ID(
    IMPORTING
     ET_CELLS = LT_CELLS ).                " Cell IDs

  IF 1 > LINES( LT_CELLS ).
    MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 셀만 선택해야 합니다.'(e19).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.

      SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
      READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 2.
      LV_CHART = LS_STRING.

      IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
        MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'(e02).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY CHART = LV_CHART
                                                                                          SEQNO = LV_SEQNO.

*  선택된 필드의 오더정보 찾기
    READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
      ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.
      IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
      ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO <LV_LINE>.

      CLEAR LV_NUM.
      CLEAR LV_FIELDNAME.
      LV_NUM =  LS_ROUTING-SEQNO + 0.
      LV_FIELDNAME = LV_NUM && '_SEQNO'.

      IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.
      IF <LV_GONGSEQ> IS NOT ASSIGNED. " 공정을 못찾으면 종료
        RETURN.
      ELSE.
        IF <LV_GONGSEQ> = 0. " 해당 공정 순번이 비어있다면 오더가 없다는 의미 다음순번
          CONTINUE.
        ENDIF.
      ENDIF.

      READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
      READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
      READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.

* 중복 필드라면 대상이 아님
      IF LS_CHAIN-CHK_DUP EQ ABAP_TRUE.
        CONTINUE.
      ENDIF.

* 오더가 존재해야함
      IF LS_CHAIN-ORDNR IS INITIAL.
        CONTINUE.
      ENDIF.

* 생산 오더만 복조장 가능 하므로 생산오더인지 확인
      IF LS_CHAIN-ORDTY NE 'PR'.
        CONTINUE.
      ENDIF.

      READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = LS_CHAIN-ORDNR
                                                                      POSNR = LS_CHAIN-POSNR
                                                                       ORDTY = LS_CHAIN-ORDTY.
      .
      IF SY-SUBRC EQ 0.
        APPEND LS_2010 TO PT_2010.
      ENDIF.
    ENDIF.
  ENDLOOP.

* 정합성 검사
* 1. 해당 오더가 복조장 구성인지 확인

  READ TABLE PT_2010 INDEX 1.

  LT_2010 = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( ORDNR = PT_2010-ORDNR
                                                               AND  ORDTY = 'PR' )
                             ( CORRESPONDING #( LW_2010 ) ) ).

  IF LINES( LT_2010 ) <= 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '복조장 구성 오더가 아닙니다.'(e20).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  REFRESH PT_2010[].
  MOVE-CORRESPONDING LT_2010 TO PT_2010[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_AND_DISP_TEXT2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_AND_DISP_TEXT2 .

  DATA : LT_TEXT TYPE TABLE OF CHAR255.
  DATA : LT_LINE TYPE TABLE OF TLINE.
  DATA : LV_NAME TYPE THEAD-TDNAME.
  DATA : LV_VBELN TYPE VBELN.
  DATA : LV_POSNR TYPE POSNR.
  LV_VBELN = GS_MAIN_200-ORDNO.
  __ALPHA_INPUT LV_VBELN.
  LV_POSNR = GS_MAIN_200-POSNR + 0.

  CASE GS_MAIN_200-GCATG.
    WHEN '생산오더'.
      RETURN.
    WHEN OTHERS.
      LV_NAME = LV_VBELN && LV_POSNR.
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
  ENDCASE.

  CALL FUNCTION 'ZGTPP_UTILL_TEXTEDIT'
    EXPORTING
      IV_MODE  = '1'
      IV_TITLE = '특기사항'
    CHANGING
      CT_TEXT  = LT_TEXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONTEXT_MENU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&---------------------------------------------------------------------*
FORM CONTEXT_MENU  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                         P_OBJECT TYPE REF TO CL_CTMENU.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA: LT_STD_FCODES TYPE UI_FUNCTIONS,
        LT_OWN_FCODES TYPE UI_FUNCTIONS.
  DATA : LV_TEXT TYPE GUI_TEXT.
  DATA : LV_CHK_EXIST.
  DATA : LV_NUM(2) TYPE N.
  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_2010_CHK LIKE TABLE OF GS_2010.
  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : BEGIN OF LS_DUP_MATNR,
           MATNR TYPE MATNR,
           MENGE TYPE MENGE_D,
         END OF LS_DUP_MATNR.
  DATA : LT_DUP_MATNR LIKE TABLE OF LS_DUP_MATNR.
  DATA : LV_CODE TYPE UI_FUNC.
  DATA : LV_MENGE TYPE MENGE_D.


  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.

  CASE P_SENDER.
    WHEN GO_GRID_0201.

      GO_GRID_0201->GET_SELECTED_COLUMNS(
        IMPORTING
          ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

      GO_GRID_0201->GET_SELECTED_CELLS_ID(
          IMPORTING
           ET_CELLS = LT_CELLS ).                " Cell IDs

      P_OBJECT->CLEAR( ).

      IF LT_COLUMN[] IS INITIAL AND LT_CELLS[] IS INITIAL.
        RETURN.
      ENDIF.

      IF LT_COLUMN[] IS NOT INITIAL.
        IF LINES( LT_COLUMN ) > 1.
          RETURN.
        ENDIF.

        LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
          SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
          READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 2.
          LV_CHART = LS_STRING.

          IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
            RETURN.
          ENDIF.
* 선택된 컬럼의 공정 유형 전부 추출
          READ TABLE LT_STRING INTO LS_STRING INDEX 1.
          LV_SEQNO = LS_STRING + 0.
          READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY CHART = LV_CHART
                                                                                              SEQNO = LV_SEQNO.

          LT_2010 = VALUE #( FOR WA_2010 IN GT_2010 WHERE ( GONG_CD = LV_CHART AND GONG_SEQ = LS_ROUTING-GONG_SEQ )
                                                         ( CORRESPONDING #( WA_2010 ) ) ).
        ENDLOOP.


      ELSE.

        DATA(LT_CELLS_SORT) = LT_CELLS.
        SORT LT_CELLS_SORT BY COL_ID.
        DELETE ADJACENT DUPLICATES FROM LT_CELLS_SORT COMPARING COL_ID.

        IF LINES( LT_CELLS_SORT ) > 1.
          RETURN.
        ENDIF.

        LOOP AT LT_CELLS INTO DATA(LS_CELLS).
          READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
          IF SY-SUBRC EQ 0.
            SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE LT_STRING.
            READ TABLE LT_STRING INTO LS_STRING INDEX 2.
            LV_CHART = LS_STRING.

            IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
              RETURN.
            ENDIF.
          ENDIF.

          READ TABLE LT_STRING INTO LS_STRING INDEX 1.
          LV_SEQNO = LS_STRING + 0.
          READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY CHART = LV_CHART
                                                                                                SEQNO = LV_SEQNO.

*  선택된 필드의 오더정보 찾기
          READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
          IF SY-SUBRC EQ 0.
            IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
            ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.
            IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
            ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO <LV_LINE>.

            CLEAR LV_NUM.
            CLEAR LV_FIELDNAME.
            LV_NUM =  LS_ROUTING-SEQNO + 0.
            LV_FIELDNAME = LV_NUM && '_SEQNO'.

            IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
            ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.
            IF <LV_GONGSEQ> IS NOT ASSIGNED. " 공정을 못찾으면 종료
              RETURN.
            ELSE.
              IF <LV_GONGSEQ> = 0. " 해당 공정 순번이 비어있다면 오더가 없다는 의미 다음순번
                CONTINUE.
              ENDIF.
            ENDIF.

            READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
            READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
            READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.

* 중복 필드라면 대상이 아님
            IF LS_CHAIN-CHK_DUP EQ ABAP_TRUE.
              CONTINUE.
            ENDIF.

            IF LS_CHAIN-ORDNR IS INITIAL.
              CONTINUE.
            ENDIF.
            READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY GONG_SEQ = LS_GONG-GONG_SEQ
                                                                        ORDNR = LS_CHAIN-ORDNR
                                                                        POSNR = LS_CHAIN-POSNR
                                                                        ORDTY = LS_CHAIN-ORDTY.
            IF SY-SUBRC EQ 0.
              APPEND LS_2010 TO LT_2010.
            ENDIF.
          ENDIF.
        ENDLOOP.

      ENDIF.

      IF LT_2010 IS INITIAL.
        RETURN.
      ENDIF.

      IF LINES( LT_2010 ) = 1.
        READ TABLE LT_2010 INTO LS_2010 INDEX 1.

        IF LS_2010-ORDTY EQ 'PRD'.
          SELECT SINGLE
           F~KTEXT
           FROM AFKO         AS A
           INNER JOIN AFVC   AS B
                                   ON B~AUFPL = A~AUFPL
           INNER JOIN CRTX   AS F
                                   ON F~OBJID = B~ARBID
           WHERE A~AUFNR = @LS_2010-ORDNR
            AND B~APLFL = '000000'
            AND B~RUECK <> '0000000000'
            AND F~SPRAS = @SY-LANGU
            AND F~OBJTY = 'A'
            INTO @DATA(LV_KTEXT).

          IF LV_KTEXT IS NOT INITIAL.
* 1라인 설비명
            LV_TEXT = LV_KTEXT.
            CALL METHOD P_OBJECT->ADD_FUNCTION
              EXPORTING
                FCODE = 'A1'
                TEXT  = LV_TEXT.
          ENDIF.
        ENDIF.
* 2라인 자재명
        CLEAR LV_TEXT.
        IF LS_2010-REAL_MATNR IS NOT INITIAL AND LS_2010-MATNR NE LS_2010-REAL_MATNR.
          LV_TEXT = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_2010-REAL_MATNR ).
        ELSE.
          LV_TEXT = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_2010-MATNR ).
        ENDIF.

        CALL METHOD P_OBJECT->ADD_FUNCTION
          EXPORTING
            FCODE = 'A2'
            TEXT  = LV_TEXT.

* 3라인 수량
        CLEAR : LV_MENGE, LV_TEXT.
        LV_MENGE = ( LS_2010-INLENGTH + LS_2010-QLENGTH + LS_2010-CLENGTH +
                            LS_2010-SLENGTH + LS_2010-ADLENGTH ) * LS_2010-INFACTOR.

        WRITE LV_MENGE UNIT 'EA' TO LV_TEXT .
        CONDENSE LV_TEXT.

        CALL METHOD P_OBJECT->ADD_FUNCTION
          EXPORTING
            FCODE = 'A3'
            TEXT  = LV_TEXT.

        CALL METHOD P_OBJECT->SHOW_FUNCTIONS
          EXPORTING
            FCODES = LT_OWN_FCODES.

        CALL METHOD CL_GUI_CFW=>FLUSH.

      ELSE.
        SORT LT_2010 BY ORDNR POSNR ORDTY.
        DELETE ADJACENT DUPLICATES FROM LT_2010 COMPARING ORDNR POSNR ORDTY.

        LOOP AT LT_2010 INTO LS_2010.
          CLEAR LS_DUP_MATNR.
          IF LS_2010-REAL_MATNR IS NOT INITIAL AND LS_2010-MATNR NE LS_2010-REAL_MATNR.
            LS_DUP_MATNR-MATNR = LS_2010-REAL_MATNR.
          ELSE.
            LS_DUP_MATNR-MATNR = LS_2010-MATNR.
          ENDIF.

          LS_DUP_MATNR-MENGE = ( LS_2010-INLENGTH + LS_2010-QLENGTH + LS_2010-CLENGTH +
                                               LS_2010-SLENGTH + LS_2010-ADLENGTH ) * LS_2010-INFACTOR.

          COLLECT LS_DUP_MATNR INTO LT_DUP_MATNR.
        ENDLOOP.

        CLEAR LV_NUM.
        LOOP AT LT_DUP_MATNR INTO LS_DUP_MATNR.
          IF LV_NUM NE 0.
* 분리자
            P_OBJECT->ADD_SEPARATOR( ).
          ENDIF.

* 1라인 자재명
          CLEAR : LV_CODE, LV_TEXT.
          ADD 1 TO LV_NUM.
          LV_CODE = 'A' && LV_NUM.
          LV_TEXT = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_DUP_MATNR-MATNR ).
          CALL METHOD P_OBJECT->ADD_FUNCTION
            EXPORTING
              FCODE = LV_CODE
              TEXT  = LV_TEXT.

* 2라인 수량
          CLEAR : LV_CODE, LV_TEXT.
          ADD 1 TO LV_NUM.
          LV_CODE = 'A' && LV_NUM.
          WRITE LS_DUP_MATNR-MENGE UNIT 'EA' TO LV_TEXT .
          CONDENSE LV_TEXT.

          CALL METHOD P_OBJECT->ADD_FUNCTION
            EXPORTING
              FCODE = LV_CODE
              TEXT  = LV_TEXT.
        ENDLOOP.

        CALL METHOD P_OBJECT->SHOW_FUNCTIONS
          EXPORTING
            FCODES = LT_OWN_FCODES.

        CALL METHOD CL_GUI_CFW=>FLUSH.

      ENDIF.


    WHEN OTHERS.
      RETURN.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_PURCHASE_REQUEST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONVERSION_PURCHASE_REQUEST .

  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_2010_TMP LIKE TABLE OF GS_2010.
  DATA : LT_2010_CONFIRM LIKE TABLE OF GS_2010.
  DATA : LT_SORT_MATNR LIKE TABLE OF GS_2010.
  DATA : LV_CHK_ERR.
  DATA : LO_JOJANG TYPE REF TO ZGTPP_CL_ROUTING_GAON.
  DATA : LV_RESULT TYPE CHAR01.
  DATA : LV_MATNR_C(40).
  DATA : LV_VALUE TYPE C LENGTH 30.
  DATA : LV_VALUE2 TYPE P LENGTH 13 DECIMALS 2.
  DATA : LV_VALUE3 TYPE I.
  DATA : LV_PLNUM TYPE PLNUM.
  DATA : BEGIN OF LS_INFNR_INFOR,
           MATNR    TYPE MATNR,
           INFNR    TYPE INFNR,
           LIFNR    TYPE LIFNR,
           EEIND    TYPE SY-DATUM,
           LGFSB    TYPE MARC-LGFSB,
           GONG_SEQ TYPE ZEGONG_SEQ,
         END OF LS_INFNR_INFOR.
  DATA : LT_INFNR_INFOR LIKE TABLE OF LS_INFNR_INFOR.

  PERFORM CHK_BEFORE_CONV CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  PERFORM CHK_LINE_FOR_CONV_PO TABLES LT_2010
                                                 CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF LT_2010[] IS INITIAL.
    RETURN.
  ENDIF.

  REFRESH GT_DEL_DISP.

  LT_SORT_MATNR = LT_2010.
  SORT LT_SORT_MATNR BY MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_SORT_MATNR COMPARING MATNR.

  REFRESH GT_MAIN_DISP_400.

  LOOP AT LT_SORT_MATNR INTO DATA(LS_SORT_MATNR).
    CLEAR GS_HEADER_0400.
    REFRESH : GT_MAIN_DISP_400_CHECK.
    CLEAR LV_CHK_ERR.
    PERFORM PREPARE_DATA_PO USING LS_SORT_MATNR CHANGING LV_CHK_ERR.

    REFRESH LT_2010_TMP.
    LOOP AT LT_2010 INTO DATA(LS_2010) WHERE MATNR = LS_SORT_MATNR-MATNR.

      IF LV_CHK_ERR = ABAP_TRUE.
        APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING FIELD-SYMBOL(<LS_DEL_DISP>).
        <LS_DEL_DISP>-STATUS = ICON_LED_RED.
        CLEAR LV_MATNR_C.
        LV_MATNR_C = LS_SORT_MATNR-MATNR.
        __ALPHA_OUT LV_MATNR_C.
        <LS_DEL_DISP>-MESSAGE = | 오더({ LS_2010-ORDNR }) 자재({ LV_MATNR_C }) 에 대한 구매정보 레코드를 찾을 수 없습니다.|.
        CONTINUE.
      ENDIF.

      CLEAR GS_MAIN_DISP_400.

      GS_MAIN_DISP_400-MATNR = LS_SORT_MATNR-MATNR.
      GS_MAIN_DISP_400-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_SORT_MATNR-MATNR ).
      GS_MAIN_DISP_400-ORDNR = LS_2010-ORDNR.
*    조장
      IF LS_2010-DMORDTY = 'SO' OR LS_2010-DMORDTY = 'SM'.
        LV_VALUE = LS_2010-INLENGTH.
        CONDENSE LV_VALUE.
        SPLIT LV_VALUE AT '.' INTO DATA(LV_NUM) DATA(LV_DOT).
        IF LV_DOT > 0.
          LV_VALUE = LS_2010-INLENGTH.
        ELSE.
          LV_VALUE3 = LS_2010-INLENGTH.
          LV_VALUE = LV_VALUE3.
        ENDIF.
      ELSE.
        LV_VALUE3 = LS_2010-INLENGTH.
        LV_VALUE = LV_VALUE3.
      ENDIF.
      CONDENSE LV_VALUE.
      CONCATENATE '(' LV_VALUE INTO GS_MAIN_DISP_400-CHART_INFOR.
      IF LS_2010-QLENGTH = 0 AND LS_2010-CLENGTH = 0 AND LS_2010-ADLENGTH = 0.
      ELSE.
* 검사여장,
        LV_VALUE3 = LS_2010-QLENGTH.
        LV_VALUE = LV_VALUE3.
        CONDENSE LV_VALUE.
        CONCATENATE GS_MAIN_DISP_400-CHART_INFOR '+' LV_VALUE '+' INTO GS_MAIN_DISP_400-CHART_INFOR.
* 연결여장
        LV_VALUE3 = LS_2010-CLENGTH.
        LV_VALUE = LV_VALUE3.
        CONDENSE LV_VALUE.
        CONCATENATE GS_MAIN_DISP_400-CHART_INFOR  LV_VALUE '+' INTO GS_MAIN_DISP_400-CHART_INFOR.
* 추가여장
        LV_VALUE3 = LS_2010-ADLENGTH.
        LV_VALUE = LV_VALUE3.
        CONDENSE LV_VALUE.
        CONCATENATE GS_MAIN_DISP_400-CHART_INFOR  LV_VALUE  INTO GS_MAIN_DISP_400-CHART_INFOR.
      ENDIF.
* 조장수
      LV_VALUE3 = LS_2010-INFACTOR.
      LV_VALUE = LV_VALUE3.
      CONDENSE LV_VALUE.

      CONCATENATE GS_MAIN_DISP_400-CHART_INFOR ')X' LV_VALUE INTO GS_MAIN_DISP_400-CHART_INFOR.

      CASE LS_2010-ORDTY.
        WHEN 'PLN'.
          LV_PLNUM = LS_2010-ORDNR.
*      __ALPHA_OUT LV_PLNUM.
          SELECT SINGLE GSMNG FROM PLAF
            INTO @DATA(LV_GSMNG)
            WHERE PLNUM = @LV_PLNUM.
          GS_MAIN_DISP_400-WMENG = LV_GSMNG.
        WHEN 'PRD'.
          SELECT SINGLE GAMNG FROM AFKO
            INTO @DATA(LV_GAMNG)
            WHERE AUFNR = @LS_2010-ORDNR.
          GS_MAIN_DISP_400-WMENG = LV_GAMNG.
      ENDCASE.

      APPEND GS_MAIN_DISP_400 TO GT_MAIN_DISP_400.
      APPEND LS_2010 TO LT_2010_TMP.

    ENDLOOP.

  ENDLOOP.

  CLEAR GV_CONTINUE_400.
*  POPUP 화면 호출
  CALL SCREEN '0500' STARTING AT 5 5 ENDING AT 87 29.

  IF GV_CONTINUE_400 = ABAP_TRUE. " 컨펌 완료시 해당자재 구매오더생성
    APPEND LINES OF LT_2010_TMP TO LT_2010_CONFIRM.
    LOOP AT LT_SORT_MATNR INTO LS_SORT_MATNR.
      CLEAR LS_INFNR_INFOR.
      LS_INFNR_INFOR-MATNR = LS_SORT_MATNR-MATNR.
      LS_INFNR_INFOR-GONG_SEQ = GS_HEADER_0400-GONG_SEQ.
      APPEND LS_INFNR_INFOR TO LT_INFNR_INFOR.
    ENDLOOP.
  ENDIF.

  IF LT_2010_CONFIRM[] IS INITIAL.
    IF GT_DEL_DISP[] IS NOT INITIAL.
      GV_DISP_SET = 'A'.
      CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
      CLEAR GV_DISP_SET.
    ENDIF.

    RETURN.
  ENDIF.

  CREATE OBJECT LO_JOJANG
    EXPORTING
      IV_WERKS              = P_WERKS                 " 플랜트
      IV_GRPNR              = GV_GRPNR                 " 조장 구성표 번호
      IT_MAIN               = GT_MAKE_DISPLAY
      IT_SEQ_ROUTING_HEADER = GT_SEQ_ROUTING_HEADER
      IT_SEQ_ROUTING_SUB    = GT_SEQ_ROUTING_SUB
      IT_MAKED_2010         = GT_2010
      IT_INFNR_INFOR        = LT_INFNR_INFOR.

  LV_RESULT = LO_JOJANG->CREATE_PURCHASE_REQUEST(
                      EXPORTING
                        IT_2010     = LT_2010_CONFIRM ).              " 공정SEQ

  IF LV_RESULT = 'E'.

    REFRESH GT_DEL_DISP.
    APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING <LS_DEL_DISP>.
    <LS_DEL_DISP>-STATUS = ICON_LED_RED.
    <LS_DEL_DISP>-MESSAGE = '구매요청 생성중 오류 발생하였습니다'.

    LOOP AT LO_JOJANG->MT_TOT_MESSTAB INTO DATA(LS_MESSAGE) WHERE MSGTYP = 'E'.
      APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING <LS_DEL_DISP>.
      <LS_DEL_DISP>-STATUS = ICON_LED_RED.
      <LS_DEL_DISP>-MESSAGE = LS_MESSAGE-MSGV1 && LS_MESSAGE-MSGV2.
    ENDLOOP.

    IF GT_DEL_DISP[] IS NOT INITIAL.
      GV_DISP_SET = 'A'.
      CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
      CLEAR GV_DISP_SET.
    ENDIF.

    RETURN.

  ENDIF.

  REFRESH GT_DEL_DISP.
  APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING <LS_DEL_DISP>.
  <LS_DEL_DISP>-STATUS = ICON_LED_GREEN.
  <LS_DEL_DISP>-MESSAGE = '구매요청 생성 완료하였습니다.'.
  LOOP AT LO_JOJANG->MT_TOT_MESSTAB INTO LS_MESSAGE WHERE MSGTYP = 'E'.
    APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING <LS_DEL_DISP>.
    <LS_DEL_DISP>-STATUS = ICON_LED_YELLOW.
    <LS_DEL_DISP>-MESSAGE = LS_MESSAGE-MSGV1 && LS_MESSAGE-MSGV2.
  ENDLOOP.

  IF GT_DEL_DISP[] IS NOT INITIAL.
    GV_DISP_SET = 'A'.
    CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
    CLEAR GV_DISP_SET.
  ENDIF.

* 안내사항 관리 추가 장납품 관련 조장생성 프로세스 변경으로 전환시 체크 사항들이 존재함
  PERFORM SET_GUIDE_END_CONV CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'DISP_MESSAGE'              " Function code
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
        OTHERS                 = 2.
    IF SY-SUBRC <> 0.
    ENDIF.
  ENDIF.

*  변경정보 MES전송
  ZGTPP_CL_ROUTING=>SEND_CHG_MES(
    IV_WERKS = P_WERKS           " 플랜트
    IV_SPGCD = P_SPGCD          " SPG 코드
    IV_GRPNR = GV_GRPNR ).    " 조장 구성표 번호

  PERFORM REFRESH_SCREEN_201.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_ANSWER
*&---------------------------------------------------------------------*
FORM CHECK_0500  CHANGING PV_ANSWER.

  DATA : LV_CHECK(10).
  DATA : LV_CHECK2(10).
  DATA : LV_CHK_NUM(2) TYPE N.
  DATA : LV_CHK_NUM2(2) TYPE N.
  DATA : LV_CAL_NUM(2) TYPE N.
  DATA : LV_CAL_NUM2(2) TYPE N.
  DATA : LV_LOW_NUM(2) TYPE N.
  DATA : LV_CHK_FIELDNAME TYPE FIELDNAME.
  DATA : LV_SEQNO TYPE I.
  DATA : LT_DEV_2010 LIKE TABLE OF GS_2010.
  DATA : LT_CURRENT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_CHK_MULTY_2010 LIKE TABLE OF GS_2010.
  DATA : LV_CHK_EXIT.

  READ TABLE GT_MAIN_DISP_400_CHECK INTO DATA(LS_CHK) INDEX 1.
  SPLIT GS_HEADER_0400-FIELDNAME AT '_' INTO LV_CHECK LV_CHK_NUM.

  LOOP AT GT_FIELDCAT_0400 INTO DATA(LS_FCAT).
    IF  LS_CHK-(LS_FCAT-FIELDNAME) = ABAP_TRUE.
      IF LV_CAL_NUM = LV_CHK_NUM.
        EXIT.
      ENDIF.

      SPLIT LS_FCAT-FIELDNAME AT '_' INTO LV_CHECK2 LV_CHK_NUM2.
      IF LV_LOW_NUM IS INITIAL.
        LV_LOW_NUM = LV_CHK_NUM2.
      ELSEIF LV_LOW_NUM > LV_CHK_NUM2.
        LV_LOW_NUM = LV_CHK_NUM2.
      ENDIF.

      IF LV_CAL_NUM IS INITIAL.
        LV_CAL_NUM = LV_CHK_NUM2.
        ADD 1 TO LV_CAL_NUM.
      ELSE.
        IF LV_CHK_NUM2 = LV_CAL_NUM.
          ADD 1 TO LV_CAL_NUM .
          CONTINUE.
        ELSE.
          LV_CAL_NUM2 = LV_CHK_NUM2 + 1.
          LV_CHK_FIELDNAME = 'CHECK_' && LV_CAL_NUM2.
          IF LS_CHK-(LV_CHK_FIELDNAME) NE ABAP_TRUE.
            MESSAGE I006 WITH '공정 추가 선택은 연속된 공정이여야 합니다. 선택된 공정을 확인해 주세요.'(e38).
            PV_ANSWER = ABAP_TRUE.
            RETURN.
          ENDIF.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.

* 오더별 연결정보 확인
* 추가로 선택된 공정의 오더 상태 확인
*  - PRD일시 생산 중인게 있다면 오류
*  - 구매오더 존재시 오류
  LV_SEQNO = LV_LOW_NUM + 0.

  READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_LOW_GONG) WITH KEY SEQNO = LV_SEQNO.

  GS_HEADER_0400-GONG_SEQ = LS_LOW_GONG-GONG_SEQ.

  DATA(LT_CHK_MAIN) = GT_MAIN_DISP_400.
  SORT LT_CHK_MAIN BY ORDNR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_MAIN COMPARING ORDNR.

  LOOP AT GT_MAIN_DISP_400 INTO GS_MAIN_DISP_400.
    REFRESH LT_DEV_2010.
    LOOP AT  GT_2010 INTO GS_2010 WHERE  ORDNR = GS_MAIN_DISP_400-ORDNR.
      APPEND GS_2010 TO LT_DEV_2010.
    ENDLOOP.

    DO.

      REFRESH LT_CURRENT_2010.
      LOOP AT LT_DEV_2010 INTO DATA(LS_DEV_2010).
        READ TABLE GT_2010 INTO GS_2010 WITH KEY  ORDNR = LS_DEV_2010-REORD
                                                                     POSNR = LS_DEV_2010-RELINE
                                                                     ORDTY = LS_DEV_2010-REORDTY.
        IF SY-SUBRC EQ 0.
          IF LS_LOW_GONG-GONG_SEQ > GS_2010-GONG_SEQ.
            CONTINUE.
          ENDIF.

          " 이후공정의 체인에서 이전 오더를 찾았을때 이전오더의 이후공정 체인이 동일할시
* 찾아온 이전 공정이 복조장 인지 확인
          REFRESH LT_CHK_MULTY_2010.
          LOOP AT GT_2010 INTO DATA(LS_TEMP) WHERE ORDNR = GS_2010-ORDNR.
            APPEND LS_TEMP TO LT_CHK_MULTY_2010.
          ENDLOOP.
          SORT LT_CHK_MULTY_2010 BY ORDNR POSNR.
          DELETE ADJACENT DUPLICATES FROM LT_CHK_MULTY_2010 COMPARING ORDNR POSNR.
          IF LINES( LT_CHK_MULTY_2010 ) = 1. " 1:1 매핑구조일시 정상
            APPEND LINES OF LT_CHK_MULTY_2010 TO LT_CURRENT_2010.
          ELSE.
* 선택되지 않은 다른 오더에 연결되어 있을 경우 에러
            LOOP AT LT_CHK_MULTY_2010 INTO LS_TEMP.
              READ TABLE LT_DEV_2010 TRANSPORTING NO FIELDS WITH KEY ORDNR = LS_TEMP-DMORD
                                                                                                       POSNR = LS_TEMP-DMLINE
                                                                                                       ORDTY = LS_TEMP-DMORDTY.
              IF SY-SUBRC NE 0.
                MESSAGE I006 WITH  '추가 선택된 공정중 다른오더와 연결된 복조장 오더가 있습니다. 선택된 공정을 확인해 주세요.'(e40).
                PV_ANSWER = ABAP_TRUE.
                RETURN.
              ELSE.
                APPEND LS_TEMP TO LT_CURRENT_2010.
              ENDIF.
            ENDLOOP.

          ENDIF.

        ENDIF.
      ENDLOOP.

      IF LT_CURRENT_2010[] IS INITIAL.
        EXIT.
      ENDIF.

      SORT LT_CURRENT_2010 BY ORDNR POSNR.
      DELETE ADJACENT DUPLICATES FROM LT_CURRENT_2010 COMPARING ORDNR POSNR.
      LOOP AT LT_CURRENT_2010 INTO DATA(LS_CURRENT_2010).
        CASE LS_CURRENT_2010-ORDTY.
          WHEN 'PRD'.
            IF LS_CURRENT_2010-CHK_PRD = ABAP_TRUE.
              MESSAGE I006 WITH  '추가 선택된 공정중 생산중인 오더가 있습니다. 선택된 공정을 확인해 주세요.'(e41).
              PV_ANSWER = ABAP_TRUE.
              RETURN.
            ENDIF.
          WHEN 'PO'.
            MESSAGE I006 WITH  '추가 선택된 공정중 임가공 구매 오더가 있습니다. 선택된 공정을 확인해 주세요.'(e42).
            PV_ANSWER = ABAP_TRUE.
            RETURN.
          WHEN 'PR' OR 'UPR'.
            MESSAGE I006 WITH  '추가 선택된 공정중 구매 요청이 있습니다. 선택된 공정을 확인해 주세요.'(e64).
            PV_ANSWER = ABAP_TRUE.
            RETURN.

        ENDCASE.

      ENDLOOP.

      REFRESH LT_DEV_2010.
      LT_DEV_2010 = LT_CURRENT_2010.

    ENDDO.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0401
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0401 .

  REFRESH GT_SORT_0401.
  CHECK SY-DYNNR = '0500'.

  PERFORM SET_SORT_TAB TABLES GT_SORT_0401
                            USING : 1 'MATNR'  'X' '' '',
                                       2 'MAKTX'  'X' '' ''.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_SET_ORDERD_BWD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_SET_ORDERD_BWD .

  SELECT SINGLE * FROM ZGTPPT2013
    INTO @DATA(LS_2013)
   WHERE GRPNR = @GV_GRPNR.
  IF SY-SUBRC EQ 0 AND LS_2013 IS NOT INITIAL.
    GV_CHK_EXIST_BWD = ABAP_TRUE.
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
      TABNAME           = 'GS_HEADER_0400'
      FIELDNAME         = 'LGFSB'
      SEARCHHELP        = 'H_T001L'
      SHLPPARAM         = 'LGORT'
      DYNPPROG          = 'ZGTPPR2140'
      DYNPNR            = SY-DYNNR
*     VALUE             = 'P_WERKS'
*     MULTIPLE_CHOICE   = ' '
*     DISPLAY           = ' '
*     SUPPRESS_RECORDLIST       = ' '
      CALLBACK_PROGRAM  = 'ZGTPPR2140'
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
    GS_HEADER_0400-LGFSB = LS_RETURN-FIELDVAL.
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
*& Form SET_ORD_INLENGTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_2010
*&---------------------------------------------------------------------*
FORM SET_ORD_INLENGTH  USING    PS_2010 LIKE GS_2010.

  DATA : LT_CHK_DEV LIKE TABLE OF GS_2010.
  DATA : LT_CHK_2010 LIKE TABLE OF GS_2010.
  DATA : LV_TABIX TYPE I.

  CLEAR : GS_MAINTAIN_INLENGTH.
  GS_MAINTAIN_INLENGTH-GONG_SEQ = GS_2010-GONG_SEQ.
  GS_MAINTAIN_INLENGTH-ORDNR = GS_2010-ORDNR.
  GS_MAINTAIN_INLENGTH-POSNR = GS_2010-POSNR.
  GS_MAINTAIN_INLENGTH-ORDTY = GS_2010-ORDTY.

  APPEND PS_2010 TO LT_CHK_DEV.
  LOOP AT LT_CHK_DEV INTO DATA(LS_CHK_DEV).
    CLEAR LV_TABIX.
    LV_TABIX = SY-TABIX.
    CASE LS_CHK_DEV-DMORDTY.
      WHEN 'SM' OR 'SO'.
        ADD LS_CHK_DEV-INLENGTH TO GS_MAINTAIN_INLENGTH-INLENGTH.
        DELETE LT_CHK_DEV INDEX LV_TABIX.

        APPEND GS_MAINTAIN_INLENGTH TO GT_MAINTAIN_INLENGTH.
        RETURN.
    ENDCASE.
  ENDLOOP.



  LOOP AT LT_CHK_DEV INTO LS_CHK_DEV.
    LOOP AT GT_2010 INTO DATA(LS_CHK_2010) WHERE GONG_SEQ > LS_CHK_DEV-GONG_SEQ
                                                        AND REORD = LS_CHK_DEV-ORDNR
                                                        AND RELINE = LS_CHK_DEV-POSNR
                                                        AND REORDTY = LS_CHK_DEV-ORDTY.

      READ TABLE LT_CHK_2010 INTO DATA(LS_CHK_DUP) WITH KEY ORDNR = LS_CHK_2010-ORDNR
                                                                         POSNR = LS_CHK_2010-POSNR
                                                                         ORDTY = LS_CHK_2010-ORDTY.
      IF SY-SUBRC EQ 0 AND LS_CHK_DUP-GONG_SEQ > LS_CHK_2010-GONG_SEQ.
        MODIFY LT_CHK_2010 FROM LS_CHK_2010 TRANSPORTING GONG_SEQ WHERE ORDNR = LS_CHK_2010-ORDNR
                                                               AND POSNR = LS_CHK_2010-POSNR
                                                               AND ORDTY = LS_CHK_2010-ORDTY.
      ELSEIF SY-SUBRC EQ 0 AND LS_CHK_DUP-GONG_SEQ < LS_CHK_2010-GONG_SEQ.
        CONTINUE.
      ELSE.
        APPEND LS_CHK_2010 TO LT_CHK_2010.
      ENDIF.
    ENDLOOP.

    LOOP AT GT_2010 INTO DATA(LS_CHK_2010_REL) WHERE GONG_SEQ > LS_CHK_DEV-GONG_SEQ
                                                                    AND ORDNR = LS_CHK_DEV-DMORD
                                                                    AND POSNR = LS_CHK_DEV-DMLINE
                                                                    AND ORDTY = LS_CHK_DEV-DMORDTY.

      LOOP AT GT_2010 INTO LS_CHK_2010 WHERE GONG_SEQ > LS_CHK_DEV-GONG_SEQ
                                                        AND REORD = LS_CHK_2010_REL-REORD
                                                        AND RELINE = LS_CHK_2010_REL-RELINE
                                                        AND REORDTY = LS_CHK_2010_REL-REORDTY.

        READ TABLE LT_CHK_2010 INTO LS_CHK_DUP WITH KEY ORDNR = LS_CHK_2010-ORDNR
                                                                           POSNR = LS_CHK_2010-POSNR
                                                                           ORDTY = LS_CHK_2010-ORDTY.
        IF SY-SUBRC EQ 0 AND LS_CHK_DUP-GONG_SEQ > LS_CHK_2010-GONG_SEQ.
          MODIFY LT_CHK_2010 FROM LS_CHK_2010 TRANSPORTING GONG_SEQ  WHERE ORDNR = LS_CHK_2010-ORDNR
                                                                 AND POSNR = LS_CHK_2010-POSNR
                                                                 AND ORDTY = LS_CHK_2010-ORDTY.
        ELSEIF SY-SUBRC EQ 0 AND LS_CHK_DUP-GONG_SEQ < LS_CHK_2010-GONG_SEQ.
          CONTINUE.
        ELSE.
          APPEND LS_CHK_2010 TO LT_CHK_2010.
        ENDIF.
      ENDLOOP.
      EXIT.
    ENDLOOP.

  ENDLOOP.

  SORT LT_CHK_2010 BY ORDNR POSNR ORDTY.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_2010 COMPARING ORDNR POSNR ORDTY.

  LOOP AT LT_CHK_2010 INTO LS_CHK_2010.
    READ TABLE GT_MAINTAIN_INLENGTH INTO DATA(LS_TMP) WITH KEY GONG_SEQ = LS_CHK_2010-GONG_SEQ
                                                                                    ORDNR = LS_CHK_2010-ORDNR
                                                                                    POSNR = LS_CHK_2010-POSNR
                                                                                    ORDTY = LS_CHK_2010-ORDTY.
    IF SY-SUBRC EQ 0.
      ADD LS_TMP-INLENGTH TO GS_MAINTAIN_INLENGTH-INLENGTH.
    ENDIF.
  ENDLOOP.


  APPEND GS_MAINTAIN_INLENGTH TO GT_MAINTAIN_INLENGTH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_SET_TANDEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_SET_TANDEM .

  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LV_CHK_ERR.
  DATA : LO_JOJANG TYPE REF TO ZGTPP_CL_ROUTING_GAON.
  DATA : LT_RESULT TYPE BAPI_ORDER_RETURN_TT.
  DATA : LV_MESSAGE TYPE CHAR100.

  PERFORM CHK_BEFORE_SET_TANDEM  TABLES LT_2010
                                                 CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.


  READ TABLE LT_2010 INTO DATA(LS_CHK_REL) WITH KEY STATUS = 'R'.
  IF SY-SUBRC EQ 0.
    LV_MESSAGE = '수립된 작업 일정이 취소 됩니다. 계속 진행 하시겠습니까?'(m03).
  ELSE.
    LV_MESSAGE = '선택 오더를 탄뎀 설비로 변경합니다. 진행 하시겠습니까?'(m04).
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    LV_MESSAGE
    '탄뎀설정 확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CREATE OBJECT LO_JOJANG
    EXPORTING
      IV_WERKS              = P_WERKS                 " 플랜트
      IV_GRPNR              = GV_GRPNR                 " 조장 구성표 번호
      IT_MAIN               = GT_MAKE_DISPLAY
      IT_SEQ_ROUTING_HEADER = GT_SEQ_ROUTING_HEADER
      IT_SEQ_ROUTING_SUB    = GT_SEQ_ROUTING_SUB
      IT_MAKED_2010         = GT_2010.

  CLEAR LV_CHK_ERR.

  LV_CHK_ERR = LO_JOJANG->PROC_TANDEM_CREATE( IT_2010 = LT_2010 ).

  IF LV_CHK_ERR IS NOT INITIAL.
    REFRESH GT_DEL_DISP.
    IF LO_JOJANG->MT_MESSTAB[] IS NOT INITIAL.
      LOOP AT LO_JOJANG->MT_MESSTAB INTO DATA(LS_RESULT).
        APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING FIELD-SYMBOL(<LS_DEL_DISP>).
        <LS_DEL_DISP>-MESSAGE = LS_RESULT-MSGV1.
        <LS_DEL_DISP>-STATUS = ICON_LED_RED.
      ENDLOOP.
    ENDIF.

    IF GT_DEL_DISP[] IS NOT INITIAL.
      GV_DISP_SET = 'A'.
      CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
      CLEAR GV_DISP_SET.
    ENDIF.

    MESSAGE S003 DISPLAY LIKE 'E' WITH LO_JOJANG->MV_MESSAGE.

    RETURN.
  ENDIF.

*  변경정보 MES전송
  ZGTPP_CL_ROUTING=>SEND_CHG_MES(
    IV_WERKS = P_WERKS           " 플랜트
    IV_SPGCD = P_SPGCD          " SPG 코드
    IV_GRPNR = GV_GRPNR ).    " 조장 구성표 번호

  PERFORM REFRESH_SCREEN_201.
  MESSAGE S003 WITH '탄뎀 설정되었습니다.'.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DEL_TANDEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_DEL_TANDEM .

  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LV_CHK_ERR.
  DATA : LO_JOJANG TYPE REF TO ZGTPP_CL_ROUTING_GAON.


  PERFORM CHK_BEFORE_DEL_TANDEM  TABLES LT_2010
                                                 CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '설정된 탄뎀 취소 합니다. 계속 진행하시겠습니까?'
    '탄뎀취소 확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CREATE OBJECT LO_JOJANG
    EXPORTING
      IV_WERKS              = P_WERKS                 " 플랜트
      IV_GRPNR              = GV_GRPNR                 " 조장 구성표 번호
      IT_MAIN               = GT_MAKE_DISPLAY
      IT_SEQ_ROUTING_HEADER = GT_SEQ_ROUTING_HEADER
      IT_SEQ_ROUTING_SUB    = GT_SEQ_ROUTING_SUB
      IT_MAKED_2010         = GT_2010.

  CLEAR LV_CHK_ERR.

  LV_CHK_ERR = LO_JOJANG->PROC_TANDEM_CANCEL( IT_2010 = LT_2010 ).

  IF LV_CHK_ERR IS NOT INITIAL.
    IF LO_JOJANG->MT_MESSTAB[] IS NOT INITIAL.
      REFRESH GT_DEL_DISP.
      LOOP AT LO_JOJANG->MT_MESSTAB INTO DATA(LS_RESULT).
        APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING FIELD-SYMBOL(<LS_DEL_DISP>).
        <LS_DEL_DISP>-MESSAGE = LS_RESULT-MSGV1.
        <LS_DEL_DISP>-STATUS = ICON_LED_RED.
      ENDLOOP.
    ENDIF.

    GV_DISP_SET = 'A'.
    CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
    CLEAR GV_DISP_SET.

    MESSAGE S003 DISPLAY LIKE 'E' WITH LO_JOJANG->MV_MESSAGE.

    RETURN.
  ENDIF.

*  변경정보 MES전송
  ZGTPP_CL_ROUTING=>SEND_CHG_MES(
    IV_WERKS = P_WERKS           " 플랜트
    IV_SPGCD = P_SPGCD          " SPG 코드
    IV_GRPNR = GV_GRPNR ).    " 조장 구성표 번호

  PERFORM REFRESH_SCREEN_201.
  MESSAGE S003 WITH '탄뎀 취소되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_BEFORE_SET_TANDEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_BEFORE_SET_TANDEM  TABLES   PT_2010 LIKE GT_2010
                                              CHANGING PV_CHK_ERR.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_NUM(2) TYPE N.
  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_2010_PRE LIKE TABLE OF GS_2010.
  DATA : LT_2010_CHK2 LIKE TABLE OF GS_2010.
  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LT_1010 TYPE TABLE OF ZGTPPT1010.
  DATA : LT_ARBPL TYPE RANGE OF CRHD-ARBPL.
  DATA : LV_IDX TYPE I.
  DATA : LV_CHK_ERR.
  DATA : LV_TERKZ TYPE AFKO-TERKZ.
  DATA : LV_CHK_SINGLE.
  DATA : LV_PRD_MATNR TYPE MATNR.

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.

* 탐뎀 구성을 위한 기준정보 추출
  SELECT * FROM ZGTPPT1010
    INTO TABLE LT_1010
   WHERE MODULE_KIND = 'PP'
     AND CODEGRP = '1060'
     AND FLD_02 = P_WERKS
     AND FLD_07 = 'Y'.

  IF LT_1010[] IS NOT INITIAL.
    LT_ARBPL = VALUE #( FOR LW_1010 IN LT_1010 WHERE ( FLD_04 IS NOT INITIAL )
                                ( SIGN = 'I' OPTION = 'EQ' LOW = LW_1010-FLD_04 ) ).

    IF LT_ARBPL[] IS INITIAL. " 탄뎀 지정 설비가 없다면 종료
      MESSAGE S006 DISPLAY LIKE 'E' WITH '해당 플랜트' P_WERKS '에 탄뎀지정 가능한 설비가 없습니다.'.
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ELSE.
      SORT LT_ARBPL BY LOW.
      DELETE ADJACENT DUPLICATES FROM LT_ARBPL COMPARING LOW.
    ENDIF.

  ENDIF.

  GO_GRID_0201->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  GO_GRID_0201->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL AND LT_CELLS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'(e01).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  IF LT_COLUMN[] IS NOT INITIAL.
    LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
      SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
      READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 2.
      LV_CHART = LS_STRING.

      IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
        MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 컬럼이 선택되었습니다.'(e02).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
* 선택된 컬럼의 공정 유형 전부 추출
      READ TABLE LT_STRING INTO LS_STRING INDEX 1.
      LV_SEQNO = LS_STRING + 0.
      READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY CHART = LV_CHART
                                                                                          SEQNO = LV_SEQNO.

      LT_2010 = VALUE #( FOR WA_2010 IN GT_2010 WHERE ( GONG_CD = LV_CHART AND GONG_SEQ = LS_ROUTING-GONG_SEQ )
                                                     ( CORRESPONDING #( WA_2010 ) ) ).

      LOOP AT LT_2010 ASSIGNING FIELD-SYMBOL(<LS_TEMP>).
        IF <LS_TEMP>-ORDTY = 'PRD' . "생산오더만 탄뎀변경 가능
* 생산진행중인 오더는 탄뎀 변경 불가능
          IF <LS_TEMP>-CHK_PRD = ABAP_TRUE.
            DELETE TABLE LT_2010 FROM <LS_TEMP>.
            CONTINUE.
          ENDIF.
* 이미 탄뎀 설정된 오더는 탄뎀 변경 불가능
          IF <LS_TEMP>-REF_TANDEM = 'T'.
            DELETE TABLE LT_2010 FROM <LS_TEMP>.
            CONTINUE.
          ENDIF.

* 탄뎀 설비 지정가능한 자재인지 확인
          SELECT * FROM ZGTCVROUTING
            INTO TABLE @DATA(LT_ROUTING)
           WHERE MATNR = @<LS_TEMP>-MATNR
              AND WERKS = @P_WERKS
              AND ARBPL IN @LT_ARBPL.
          IF SY-SUBRC NE 0.
            DELETE TABLE LT_2010 FROM <LS_TEMP>.
            CONTINUE.
          ENDIF.

          CLEAR LV_TERKZ.
          SELECT SINGLE TERKZ FROM AFKO
            INTO LV_TERKZ
           WHERE AUFNR = <LS_TEMP>-ORDNR.
          IF LV_TERKZ = '7'. "작업 지시 되어있다는 의미
            DELETE TABLE LT_2010 FROM <LS_TEMP>.
            CONTINUE.
          ENDIF.


        ELSE.
          DELETE TABLE LT_2010 FROM <LS_TEMP>.
        ENDIF.
      ENDLOOP.

      IF LT_2010[] IS NOT INITIAL.
        APPEND LINES OF LT_2010 TO PT_2010.
      ENDIF.
    ENDLOOP.

    IF PT_2010[] IS INITIAL.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '탄뎀 지정 가능한 공정이 선택되지 않았습니다.'(e83).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

  ELSE.

* 셀 선택하여 작업지시시 에러 처리
    LV_CHK_SINGLE = ABAP_TRUE.

    LOOP AT LT_CELLS INTO DATA(LS_CELLS).
      READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
      IF SY-SUBRC EQ 0.

        SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE LT_STRING.
        READ TABLE LT_STRING INTO LS_STRING INDEX 2.
        LV_CHART = LS_STRING.

        IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
          MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'(e02).
          PV_CHK_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.
      ENDIF.

      READ TABLE LT_STRING INTO LS_STRING INDEX 1.
      LV_SEQNO = LS_STRING + 0.
      READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY CHART = LV_CHART
                                                                                            SEQNO = LV_SEQNO.

*  선택된 필드의 오더정보 찾기
      READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
      IF SY-SUBRC EQ 0.
        IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
        ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.
        IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
        ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO <LV_LINE>.

        CLEAR LV_NUM.
        CLEAR LV_FIELDNAME.
        LV_NUM =  LS_ROUTING-SEQNO + 0.
        LV_FIELDNAME = LV_NUM && '_SEQNO'.

        IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
        ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.
        IF <LV_GONGSEQ> IS NOT ASSIGNED. " 공정을 못찾으면 종료
          RETURN.
        ELSE.
          IF <LV_GONGSEQ> = 0. " 해당 공정 순번이 비어있다면 오더가 없다는 의미 다음순번
            CONTINUE.
          ENDIF.
        ENDIF.

        READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
        READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
        READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.

* 중복 필드라면 대상이 아님
        IF LS_CHAIN-CHK_DUP EQ ABAP_TRUE.
          CONTINUE.
        ENDIF.

        IF LS_CHAIN-ORDNR IS INITIAL.
          CONTINUE.
        ENDIF.
        READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY GONG_SEQ = LS_GONG-GONG_SEQ
                                                                        ORDNR = LS_CHAIN-ORDNR
                                                                        POSNR = LS_CHAIN-POSNR
                                                                        ORDTY = LS_CHAIN-ORDTY.
        IF SY-SUBRC EQ 0.
          IF LS_2010-ORDTY = 'PRD' . "생산오더만 탄뎀변경 가능
* 생산진행중인 오더는 탄뎀 변경 불가능
            IF LS_2010-CHK_PRD = ABAP_TRUE.
              MESSAGE S003 DISPLAY LIKE 'E' WITH '생산중인 오더는 탄뎀설정 할 수 없습니다.'(e84).
              PV_CHK_ERR = ABAP_TRUE.
              RETURN.
            ENDIF.
* 이미 탄뎀 설정된 오더는 탄뎀 변경 불가능
            IF LS_2010-REF_TANDEM = 'T'.
              MESSAGE S003 DISPLAY LIKE 'E' WITH '이미 탄뎀 설정된 오더는 탄뎀설정 할 수 없습니다.'(e85).
              PV_CHK_ERR = ABAP_TRUE.
              RETURN.
            ENDIF.

* 탄뎀 설비 지정가능한 자재인지 확인
            SELECT * FROM ZGTCVROUTING
              INTO TABLE @LT_ROUTING
             WHERE MATNR = @LS_2010-MATNR
                AND WERKS = @P_WERKS
                AND ARBPL IN @LT_ARBPL.
            IF SY-SUBRC NE 0.
              MESSAGE S003 DISPLAY LIKE 'E' WITH '탄뎀설정 가능한 자재가 아닙니다.'(e86).
              PV_CHK_ERR = ABAP_TRUE.
              RETURN.
            ENDIF.

            CLEAR LV_TERKZ.
            SELECT SINGLE TERKZ FROM AFKO
              INTO LV_TERKZ
             WHERE AUFNR = LS_2010-ORDNR.
            IF LV_TERKZ = '7'. "작업 지시 되어있다는 의미
              MESSAGE S003 DISPLAY LIKE 'E' WITH '작업일정 수립된 오더는 탄뎀 설정할 수 없습니다.'(e87).
              PV_CHK_ERR = ABAP_TRUE.
              RETURN.
            ENDIF.

          ELSE.
            MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더만 탄뎀설정 가능합니다.'(e83).
            PV_CHK_ERR = ABAP_TRUE.
            RETURN.
          ENDIF.

* 탄뎀 선택 공정의 오더가 복조장일시 실제 복조장 이어야지만 가능
          CLEAR LV_CHK_ERR.
          REFRESH LT_2010.
          LT_2010 = VALUE #( FOR WA_2010 IN GT_2010 WHERE ( GONG_SEQ = LS_2010-GONG_SEQ
                                                                             AND   ORDNR = LS_2010-ORDNR )
                                                             ( CORRESPONDING #( WA_2010 ) ) ).
          IF LINES( LT_2010 ) > 1.
            LOOP AT LT_2010 INTO DATA(LS_CHK_MULTY).
              IF LS_CHK_MULTY-ORDTY NE 'PRD'. " REF타입 오더가 존재함.
                LV_CHK_ERR = ABAP_TRUE.
                EXIT.
              ENDIF.
            ENDLOOP.

            IF LV_CHK_ERR = ABAP_TRUE.
              CONTINUE.
            ENDIF.

          ENDIF.

          APPEND LS_2010 TO PT_2010.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.

  REFRESH LT_2010.
  LT_2010 = PT_2010[].
  SORT LT_2010 BY GONG_SEQ ORDNR.
  DELETE ADJACENT DUPLICATES FROM LT_2010 COMPARING GONG_SEQ ORDNR..


* 이전 공정 유효성 확인 - 생산오더, PLN만 가능, 작업여부 확인, 복조장 여부 확인, 업을시 에러
  LOOP AT LT_2010 INTO DATA(LS_2010_WQ).
    CLEAR LV_CHK_ERR.

    READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = LS_2010_WQ-GONG_SEQ.

* 현재 공정의 최종 오더정보를 찾아오기 위해
    CLEAR LV_PRD_MATNR.
    LOOP AT GT_MAKE_DISPLAY INTO DATA(LS_DISPLAY).
      LOOP AT LS_DISPLAY-T_GONG INTO LS_GONG WHERE SEQNO = LS_ROUTING-SEQNO.
        READ TABLE LS_GONG-T_CHAIN INTO LS_CHAIN WITH KEY ORDNR = LS_2010_WQ-ORDNR
                                                                                  POSNR = '000001'
                                                                                  ORDTY = LS_2010_WQ-ORDTY.
        IF SY-SUBRC EQ 0.
          LV_PRD_MATNR = LS_DISPLAY-MATNR.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LV_PRD_MATNR IS NOT INITIAL.
        LOOP AT LS_DISPLAY-T_GONG INTO LS_GONG WHERE SEQNO < LS_ROUTING-SEQNO.
          LOOP AT LS_GONG-T_CHAIN INTO LS_CHAIN WHERE DMORD = LS_2010_WQ-ORDNR
                                                                      AND  DMLINE = '000001'
                                                                      AND  DMORDTY = LS_2010_WQ-ORDTY.

            IF LS_CHAIN-ORDNR IS INITIAL.
              IF LV_CHK_SINGLE = ABAP_TRUE.
                MESSAGE S003 DISPLAY LIKE 'E' WITH '선택한 공정의 이전공정이 존재하지 않아 탐뎀 설정할 수 없습니다.'(e91).
                PV_CHK_ERR = ABAP_TRUE.
                RETURN.
              ENDIF.

              DELETE PT_2010[] WHERE GONG_SEQ = LS_2010_WQ-GONG_SEQ
                                           AND ORDNR = LS_2010_WQ-ORDNR.
              LV_CHK_ERR = ABAP_TRUE.
              EXIT.
            ELSE.
              READ TABLE GT_2010 INTO DATA(LS_2010_PRE) WITH KEY GONG_SEQ = LS_GONG-GONG_SEQ
                                                                               ORDNR = LS_CHAIN-ORDNR
                                                                               POSNR = LS_CHAIN-POSNR.
* 생산여부
              IF  LS_2010_PRE-CHK_PRD = ABAP_TRUE.

                IF LV_CHK_SINGLE = ABAP_TRUE.
                  MESSAGE S003 DISPLAY LIKE 'E' WITH '이전 공정의 오더가 생산중으로 탄뎀 설정할 수 없습니다.'(e89).
                  PV_CHK_ERR = ABAP_TRUE.
                  RETURN.
                ENDIF.

                DELETE PT_2010[] WHERE GONG_SEQ = LS_2010_WQ-GONG_SEQ
                                             AND ORDNR = LS_2010_WQ-ORDNR.
                LV_CHK_ERR = ABAP_TRUE.
                EXIT.
              ENDIF.
* 생산오더 확인
              IF  NOT ( LS_2010_PRE-ORDTY = 'PRD' OR LS_2010_PRE-ORDTY = 'PLN' ).

                IF LV_CHK_SINGLE = ABAP_TRUE.
                  MESSAGE S003 DISPLAY LIKE 'E' WITH '이전 공정의 오더가 생산오더나 계획오더가 아니어 탐뎀 설정할 수 없습니다.'(e90).
                  PV_CHK_ERR = ABAP_TRUE.
                  RETURN.
                ENDIF.

                DELETE PT_2010[] WHERE GONG_SEQ = LS_2010_WQ-GONG_SEQ
                                             AND ORDNR = LS_2010_WQ-ORDNR.
                LV_CHK_ERR = ABAP_TRUE.
                EXIT.
              ENDIF.


* 이전공정 생산지시 수립시 탄뎀설정 불가
              IF LS_2010_PRE-ORDTY = 'PRD'.
                CLEAR LV_TERKZ.
                SELECT SINGLE TERKZ FROM AFKO
                  INTO LV_TERKZ
                 WHERE AUFNR = LS_2010_PRE-ORDNR.
                IF LV_TERKZ = '7'. "작업 지시 되어있다는 의미
                  IF LV_CHK_SINGLE = ABAP_TRUE.
                    MESSAGE S003 DISPLAY LIKE 'E' WITH '이전 공정의 오더가 작업일정 수립되어 탄뎀 설정할 수 없습니다.'(e92).
                    PV_CHK_ERR = ABAP_TRUE.
                    RETURN.
                  ENDIF.

                  DELETE PT_2010[] WHERE GONG_SEQ = LS_2010_WQ-GONG_SEQ
                                               AND ORDNR = LS_2010_WQ-ORDNR.
                  LV_CHK_ERR = ABAP_TRUE.
                  EXIT.
                ENDIF.
              ENDIF.

* 복조장 오더 여부 확인 이전공정이 복조장 이라면 생성 예외
              REFRESH LT_2010_CHK2.
              LT_2010_CHK2 = VALUE #( FOR _LW_2010_PRE IN GT_2010 WHERE ( ORDNR = LS_2010_PRE-ORDNR
                                                                                           AND   ORDTY = LS_2010_PRE-ORDTY )
                                                ( CORRESPONDING #( _LW_2010_PRE ) ) ).
              IF LINES( LT_2010_CHK2 ) > 1.
                IF LV_CHK_SINGLE = ABAP_TRUE.
                  MESSAGE S003 DISPLAY LIKE 'E' WITH '이전 공정의 오더가 복조장 구성되어 탄뎀 설정할 수 없습니다.'(e88).
                  PV_CHK_ERR = ABAP_TRUE.
                  RETURN.
                ENDIF.

                DELETE PT_2010[] WHERE GONG_SEQ = LS_2010_WQ-GONG_SEQ
                                             AND ORDNR = LS_2010_WQ-ORDNR.
                LV_CHK_ERR = ABAP_TRUE.
                EXIT.
              ENDIF.

            ENDIF.

          ENDLOOP.

          IF LV_CHK_ERR = ABAP_TRUE.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.


    ENDLOOP.
  ENDLOOP.



  IF PT_2010[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '탄뎀 지정 가능한 공정이 선택되지 않았습니다.'(e83).
    PV_CHK_ERR = ABAP_TRUE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_BEFORE_DEL_TANDEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_BEFORE_DEL_TANDEM  TABLES   PT_2010 LIKE GT_2010
                                              CHANGING PV_CHK_ERR.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_NUM(2) TYPE N.
  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_2010_PRE LIKE TABLE OF GS_2010.
  DATA : LT_2010_CHK2 LIKE TABLE OF GS_2010.
  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_IDX TYPE I.
  DATA : LV_CHK_ERR.

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.


  GO_GRID_0201->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  GO_GRID_0201->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL AND LT_CELLS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'(e01).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  IF LT_COLUMN[] IS NOT INITIAL.
    LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
      SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
      READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 2.
      LV_CHART = LS_STRING.

      IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
        MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 컬럼이 선택되었습니다.'(e02).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
* 선택된 컬럼의 공정 유형 전부 추출
      READ TABLE LT_STRING INTO LS_STRING INDEX 1.
      LV_SEQNO = LS_STRING + 0.
      READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY CHART = LV_CHART
                                                                                          SEQNO = LV_SEQNO.

      LT_2010 = VALUE #( FOR WA_2010 IN GT_2010 WHERE ( GONG_CD = LV_CHART AND GONG_SEQ = LS_ROUTING-GONG_SEQ )
                                                     ( CORRESPONDING #( WA_2010 ) ) ).

      LOOP AT LT_2010 ASSIGNING FIELD-SYMBOL(<LS_TEMP>).
        IF <LS_TEMP>-REF_TANDEM = 'T' . "탄뎀 설정된 오더만 탐뎀 취소 가능
* 생산진행중인 오더는 탄뎀 변경 불가능
          IF <LS_TEMP>-CHK_PRD = ABAP_TRUE.
            DELETE TABLE LT_2010 FROM <LS_TEMP>.
            CONTINUE.
          ENDIF.

        ELSE.
          DELETE TABLE LT_2010 FROM <LS_TEMP>.
        ENDIF.
      ENDLOOP.

      IF LT_2010[] IS NOT INITIAL.
        APPEND LINES OF LT_2010 TO PT_2010.
      ENDIF.
    ENDLOOP.

    IF PT_2010[] IS INITIAL.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '탄뎀 지정 가능한 공정이 선택되지 않았습니다.'(e83).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

  ELSE.

    LOOP AT LT_CELLS INTO DATA(LS_CELLS).
      READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
      IF SY-SUBRC EQ 0.

        SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE LT_STRING.
        READ TABLE LT_STRING INTO LS_STRING INDEX 2.
        LV_CHART = LS_STRING.

        IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
          MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'(e02).
          PV_CHK_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.
      ENDIF.

      READ TABLE LT_STRING INTO LS_STRING INDEX 1.
      LV_SEQNO = LS_STRING + 0.
      READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY CHART = LV_CHART
                                                                                            SEQNO = LV_SEQNO.

*  선택된 필드의 오더정보 찾기
      READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
      IF SY-SUBRC EQ 0.
        IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
        ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.
        IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
        ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO <LV_LINE>.

        CLEAR LV_NUM.
        CLEAR LV_FIELDNAME.
        LV_NUM =  LS_ROUTING-SEQNO + 0.
        LV_FIELDNAME = LV_NUM && '_SEQNO'.

        IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
        ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.
        IF <LV_GONGSEQ> IS NOT ASSIGNED. " 공정을 못찾으면 종료
          RETURN.
        ELSE.
          IF <LV_GONGSEQ> = 0. " 해당 공정 순번이 비어있다면 오더가 없다는 의미 다음순번
            CONTINUE.
          ENDIF.
        ENDIF.

        READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
        READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
        READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.

* 중복 필드라면 대상이 아님
        IF LS_CHAIN-CHK_DUP EQ ABAP_TRUE.
          CONTINUE.
        ENDIF.

        IF LS_CHAIN-ORDNR IS INITIAL.
          CONTINUE.
        ENDIF.
        READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY GONG_SEQ = LS_GONG-GONG_SEQ
                                                                        ORDNR = LS_CHAIN-ORDNR
                                                                        POSNR = LS_CHAIN-POSNR
                                                                        ORDTY = LS_CHAIN-ORDTY.
        IF SY-SUBRC EQ 0.
          IF LS_2010-REF_TANDEM NE 'T' . "탄뎀 설정된 오더만 탐뎀 취소 가능
            MESSAGE S003 DISPLAY LIKE 'E' WITH '탄뎀 설정된 공정이 아닙니다.'(e93).
            PV_CHK_ERR = ABAP_TRUE.
            RETURN.
          ENDIF.
        ENDIF.

        APPEND LS_2010 TO PT_2010.
      ENDIF.

    ENDLOOP.

  ENDIF.

  SORT PT_2010 BY GONG_SEQ ORDNR.
  DELETE ADJACENT DUPLICATES FROM PT_2010 COMPARING GONG_SEQ ORDNR..

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_EXIST_SNOTE_FR_SO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> <LS_MAIN_200>_VBELN
*&      --> <LS_MAIN_200>_POSNR
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
*&      --> <LS_MAIN_200>_VBELN
*&      --> <LS_MAIN_200>_POSNR
*&      <-- LV_CHK_EXIST
*&---------------------------------------------------------------------*
FORM CHK_EXIST_SNOTE_FR_PO  USING   PV_VBELN
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
*& Form PROCESS_REPLACE_DRUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_REPLACE_DRUM .

  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LV_CHK_ERR.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : LV_AUTO TYPE CHAR01.
  DATA : LV_DRUM TYPE CHAR6.


  PERFORM CHK_BEFORE_REPLACE_DRUM  TABLES LT_2010
                                                 CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF LT_2010[] IS INITIAL.
    RETURN.
  ENDIF.

  LT_AUFNR = VALUE #( FOR LW_2010 IN LT_2010 WHERE ( ORDNR IS NOT INITIAL )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2010-ORDNR ) ).

  SORT LT_AUFNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_AUFNR COMPARING LOW.

  IF LINE_EXISTS( LT_2010[ DMORDTY = 'SM' ] ).
    LV_AUTO = ABAP_TRUE.
    CASE P_WERKS.
      WHEN '6500'.
        LV_DRUM = 'H'.
      WHEN '6600'.
    ENDCASE.

  ENDIF.

  SUBMIT ZGTPPR2330 VIA SELECTION-SCREEN
                   WITH P_SLSORD = ' '
                   WITH P_PRDORD = 'X'
                   WITH S_AUFNR IN LT_AUFNR
                   WITH P_DRUM = LV_DRUM
                   WITH P_AUTO = LV_AUTO
                   AND RETURN.


*  변경정보 MES전송
  ZGTPP_CL_ROUTING=>SEND_CHG_MES(
    IV_WERKS = P_WERKS           " 플랜트
    IV_SPGCD = P_SPGCD          " SPG 코드
    IV_GRPNR = GV_GRPNR ).    " 조장 구성표 번호


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_BEFORE_REPLACE_DRUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_BEFORE_REPLACE_DRUM  TABLES   PT_2010 LIKE GT_2010
                                              CHANGING PV_CHK_ERR.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_NUM(2) TYPE N.
  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_2010_CHK LIKE TABLE OF GS_2010.
  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LT_MATNR_PRD TYPE RANGE OF MATNR.

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.


  CLEAR : PV_CHK_ERR.
  REFRESH PT_2010[].

  GO_GRID_0201->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  GO_GRID_0201->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL AND LT_CELLS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'(e01).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
    READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 2.
    LV_CHART = LS_STRING.

    IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
      MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 컬럼이 선택되었습니다.'(e02).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.
* 선택된 컬럼의 공정 유형 전부 추출
    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY CHART = LV_CHART
                                                                                        SEQNO = LV_SEQNO.

    LT_2010 = VALUE #( FOR WA_2010 IN GT_2010 WHERE ( GONG_CD = LV_CHART
                                                                      AND   GONG_SEQ = LS_ROUTING-GONG_SEQ
                                                                      AND    REF_TANDEM NE 'X' )
                                                   ( CORRESPONDING #( WA_2010 ) ) ).

    LOOP AT LT_2010 ASSIGNING FIELD-SYMBOL(<LS_TEMP>).
      IF NOT <LS_TEMP>-ORDTY = 'PRD'.
        DELETE LT_2010.
      ENDIF.
    ENDLOOP.

    IF LT_2010[] IS NOT INITIAL.
      APPEND LINES OF LT_2010 TO LT_2010_CHK.
    ENDIF.

  ENDLOOP.


  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.

      SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE LT_STRING.
      READ TABLE LT_STRING INTO LS_STRING INDEX 2.
      LV_CHART = LS_STRING.

      IF NOT LINE_EXISTS( GT_SEQ_ROUTING_HEADER[ CHART = LV_CHART ] ).
        MESSAGE S003 DISPLAY LIKE 'E' WITH '공정이 아닌 필드가 선택되었습니다.'(e02).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 1.
    LV_SEQNO = LS_STRING + 0.
    READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY CHART = LV_CHART
                                                                                          SEQNO = LV_SEQNO.

*  선택된 필드의 오더정보 찾기
    READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
      ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.
      IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
      ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO <LV_LINE>.

      CLEAR LV_NUM.
      CLEAR LV_FIELDNAME.
      LV_NUM =  LS_ROUTING-SEQNO + 0.
      LV_FIELDNAME = LV_NUM && '_SEQNO'.

      IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.
      IF <LV_GONGSEQ> IS NOT ASSIGNED. " 공정을 못찾으면 종료
        RETURN.
      ELSE.
        IF <LV_GONGSEQ> = 0. " 해당 공정 순번이 비어있다면 오더가 없다는 의미 다음순번
          CONTINUE.
        ENDIF.
      ENDIF.

      READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
      READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LV_SEQNO.
      READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.

* 중복 필드라면 대상이 아님
      IF LS_CHAIN-CHK_DUP EQ ABAP_TRUE.
        CONTINUE.
      ENDIF.

      IF LS_CHAIN-ORDNR IS INITIAL.
        CONTINUE.
      ENDIF.
      READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY GONG_SEQ = LS_GONG-GONG_SEQ
                                                                      ORDNR = LS_CHAIN-ORDNR
                                                                      POSNR = LS_CHAIN-POSNR
                                                                      ORDTY = LS_CHAIN-ORDTY.
      IF SY-SUBRC EQ 0 AND LS_2010-ORDTY EQ 'PRD'.
        APPEND LS_2010 TO LT_2010_CHK.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF LT_2010_CHK[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더만 드럼재지정 가능합니다.'(m05).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

* 현재 작업 진행중인 건은 제외
  DELETE LT_2010_CHK WHERE CHK_PRD = ABAP_TRUE.
  IF LT_2010_CHK[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산중인 오더는 드럼재지정 할 수 없습니다.'(m06).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LT_MATNR = VALUE #( FOR LW_2010 IN LT_2010_CHK WHERE ( MATNR IS NOT INITIAL )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2010-MATNR ) ).

  IF LT_MATNR IS NOT INITIAL.
    SELECT DISTINCT 'I' AS SIGN, 'EQ' AS OPTION, A~MATNR AS LOW
      FROM MARA AS A
      INNER JOIN T134 AS B ON B~MTART = A~MTART
      INTO CORRESPONDING FIELDS OF TABLE @LT_MATNR_PRD
     WHERE A~MATNR IN @LT_MATNR
       AND A~LVORM = ' '
       AND B~MTREF = 'FERT'.

    IF LT_MATNR_PRD IS NOT INITIAL. " 완제품 대상이 없다면 종료
      DELETE LT_2010_CHK WHERE MATNR NOT IN LT_MATNR_PRD.
    ELSE.
      REFRESH LT_2010_CHK.
    ENDIF.

    IF LT_2010_CHK[] IS NOT INITIAL.
      APPEND LINES OF LT_2010_CHK TO PT_2010[].
    ELSE.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '제품 생산오더만 드럼재지정 가능합니다.'(m07).
      PV_CHK_ERR = ABAP_TRUE.
    ENDIF.

  ELSE.
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GUIDE_BEFORE_JOJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GUIDE_BEFORE_JOJANG .

  DATA : LV_CHK_FIRST_P.
  DATA : LV_CHK_FIRST_I.
  DATA : LT_POJANG_TEXT TYPE TCHAR255.
  DATA : LT_INSPECTION_TEXT TYPE TCHAR255.
  DATA : LV_VBELN TYPE VBAP-VBELN.
  DATA : LV_POSNR TYPE VBAP-POSNR.
  DATA : LV_MATNR TYPE MATNR.
  DATA : LV_STRING TYPE STRING.
  DATA : LV_QLENGTH TYPE ZGTPPT2010-QLENGTH.
  DATA : BEGIN OF LS_CHK_DUP,
           ORDNR TYPE ZGTPPT2010-ORDNR,
           ORDTY TYPE ZGTPPT2010-ORDTY,
         END OF LS_CHK_DUP.
  DATA : LT_CHK_DUP LIKE TABLE OF LS_CHK_DUP.
  DATA : LT_CHK_DUP2 LIKE TABLE OF LS_CHK_DUP.
  DATA : LV_TABIX TYPE I.
  DATA : LV_MENGE TYPE MENGE_D.


  REFRESH LT_CHK_DUP.
  REFRESH LT_CHK_DUP2.

* 포장재 정보 마이그 적용을 위한 로직

* 조장구성표로 들어가기전 안내사항에 대한 팝업 세팅
*  1) 판매오더문서일때
*     - 포장재 확정 상탱일때 오더의 포장재가 틀릴때
*     - 입회 검사 = '유' 일때 입회검사여장 합이 조장의 검사 여장 길이 보다 클때
  CLEAR : LV_CHK_FIRST_P, LV_CHK_FIRST_I.
  LOOP AT GT_MAIN_200 INTO DATA(LS_MAIN_200) WHERE GCATG NE '생산오더'.

    CLEAR LV_MATNR.
    LV_MATNR = LS_MAIN_200-PACK_NO.
    IF LV_MATNR IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          INPUT        = LV_MATNR
        IMPORTING
          OUTPUT       = LV_MATNR
        EXCEPTIONS
          LENGTH_ERROR = 1
          OTHERS       = 2.
      IF SY-SUBRC <> 0.
      ENDIF.

    ENDIF.

    CLEAR LV_VBELN.
    LV_VBELN = LS_MAIN_200-ORDNO.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LV_VBELN
      IMPORTING
        OUTPUT = LV_VBELN.

    CLEAR LV_POSNR.
    LV_POSNR = LS_MAIN_200-POSNR.

    LOOP AT GT_2010 INTO DATA(LS_2010) WHERE DMORD = LV_VBELN
                                    AND DMLINE = LV_POSNR.

      IF LS_MAIN_200-PACK_YN_CHK = 'CM' AND LS_MAIN_200-PACK_DM IS NOT INITIAL.

* 포장재 지시 대상은 생산오더와 임가공 오더
        CASE LS_2010-ORDTY.
          WHEN 'PRD' OR 'PO'.
            CASE LS_2010-ORDTY.
              WHEN 'PO'.
                CLEAR LV_STRING.
                LV_STRING = | EBELN = '{ LS_2010-ORDNR }' AND EBELP = '{ LS_2010-POSNR+1(5) }'  |.


              WHEN 'PRD'.
                CLEAR LV_STRING.
                LV_STRING = | AUFNR = '{ LS_2010-ORDNR }'|.

            ENDCASE.

            TRY.
                SELECT DISTINCT A~*
                  FROM RESB AS A
                  INTO TABLE @DATA(LT_RESB)
                  WHERE (LV_STRING) .
              CATCH CX_SY_DYNAMIC_OSQL_ERROR INTO DATA(LO_REF).

            ENDTRY.

            IF SY-SUBRC EQ 0 AND LT_RESB[] IS NOT  INITIAL.
              READ TABLE LT_RESB INTO DATA(LS_RESB) WITH KEY MATNR = LV_MATNR.
              IF SY-SUBRC NE 0. " 포장재가 세팅되지 않았다면
                IF LV_CHK_FIRST_P IS NOT INITIAL.
                ELSE.
                  LV_CHK_FIRST_P = ABAP_TRUE.
                  APPEND INITIAL LINE TO LT_POJANG_TEXT ASSIGNING FIELD-SYMBOL(<LV_POJANG_TEXT>).
                  <LV_POJANG_TEXT> = '확정된 드럼 포장재 자재가 적용되지 않았습니다. 아래 오더들 확인바랍니다.'.
                ENDIF.

                READ TABLE LT_CHK_DUP INTO LS_CHK_DUP WITH KEY ORDNR = LS_2010-ORDNR
                                                               ORDTY = LS_2010-ORDTY
                                                               BINARY SEARCH.
                IF SY-SUBRC NE 0.
                  CLEAR LV_TABIX.
                  LV_TABIX = SY-TABIX.

                  APPEND INITIAL LINE TO LT_POJANG_TEXT ASSIGNING <LV_POJANG_TEXT>.
                  CASE LS_2010-ORDTY.
                    WHEN 'PO'.
                      <LV_POJANG_TEXT> = |　- Po  { LS_2010-ORDNR }|.
                    WHEN 'PRD'.
                      <LV_POJANG_TEXT> = |　- Prd { LS_2010-ORDNR }|.
                  ENDCASE.

                  CLEAR LS_CHK_DUP.
                  LS_CHK_DUP-ORDNR = LS_2010-ORDNR.
                  LS_CHK_DUP-ORDTY = LS_2010-ORDTY.
                  INSERT LS_CHK_DUP INTO LT_CHK_DUP INDEX LV_TABIX.

                ENDIF.
              ENDIF.

            ENDIF.

        ENDCASE.
      ENDIF.


      IF LS_MAIN_200-INSPE_YN = '유'.

        CLEAR LV_MENGE.
        LV_MENGE = LS_2010-QLENGTH + LS_2010-CLENGTH + LS_2010-SLENGTH +
                   LS_2010-ELENGTH + LS_2010-ADLENGTH.

        CLEAR LV_QLENGTH.
* 완제품 자재의 검사여장 확인
        SELECT SINGLE A~MATNR, A~MTART, C~/SAPMP/FIX_AS_J
          FROM MARA AS A
          INNER JOIN MAPL AS B
                               ON B~MATNR = A~MATNR
          INNER JOIN PLPO AS C
                               ON C~PLNNR = B~PLNNR
         WHERE A~MATNR = @LS_MAIN_200-MATNR
            AND B~WERKS = @P_WERKS
            AND B~PLNTY = 'N'
            AND B~LOEKZ = ' '
            AND C~PLNTY = 'N'
            AND C~LOEKZ = ' '
            AND C~PLNKN = '00000001'
            INTO @DATA(LS_INFOR_MATNR).

* 해당 조장내 적용 되어야할 검사여장 정보 세팅
* 완제품 자재의 표준여장 추가되어있는지 확인
        SELECT SINGLE * FROM ZGTPPT2070
         WHERE GRPNR = @GV_GRPNR
            AND MATNR = @LS_MAIN_200-MATNR
            AND ORDNO IS INITIAL
          INTO @DATA(LS_2070).
        IF SY-SUBRC EQ 0.
          LV_QLENGTH = LS_2070-QLENGTH + LS_2070-CLENGTH + LS_MAIN_200-INSPE_QLENGTH.
        ELSE.
          LV_QLENGTH = LS_INFOR_MATNR-/SAPMP/FIX_AS_J + LS_MAIN_200-INSPE_QLENGTH.
        ENDIF.

        IF LV_QLENGTH NE 0.
          IF LV_QLENGTH > LV_MENGE.

            IF LV_CHK_FIRST_I IS NOT INITIAL.
            ELSE.
              LV_CHK_FIRST_I = ABAP_TRUE.
              APPEND INITIAL LINE TO LT_INSPECTION_TEXT ASSIGNING FIELD-SYMBOL(<LV_INSPECTION_TEXT>).
              <LV_INSPECTION_TEXT> = '판매오더에 입회 검사여장이 포함되어 있습니다. 아래 오더들 확인바랍니다.'.
            ENDIF.

            READ TABLE LT_CHK_DUP2 INTO LS_CHK_DUP WITH KEY ORDNR = LS_2010-ORDNR
                                                           ORDTY = LS_2010-ORDTY
                                                           BINARY SEARCH.
            IF SY-SUBRC NE 0.
              CLEAR LV_TABIX.
              LV_TABIX = SY-TABIX.

              APPEND INITIAL LINE TO LT_INSPECTION_TEXT ASSIGNING <LV_INSPECTION_TEXT>.
              CASE LS_2010-ORDTY.
                WHEN 'PO'.
                  <LV_INSPECTION_TEXT> = |　- Po  { LS_2010-ORDNR }|.
                WHEN 'PRD'.
                  <LV_INSPECTION_TEXT> = |　- Prd { LS_2010-ORDNR }|.
                WHEN 'PR' OR 'UPR'.
                  <LV_INSPECTION_TEXT> = |　- Pr  { LS_2010-ORDNR }|.
                WHEN 'PLN'.
                  <LV_INSPECTION_TEXT> = |　- Pln { LS_2010-ORDNR }|.
              ENDCASE.
              CLEAR LS_CHK_DUP.
              LS_CHK_DUP-ORDNR = LS_2010-ORDNR.
              LS_CHK_DUP-ORDTY = LS_2010-ORDTY.
              INSERT LS_CHK_DUP INTO LT_CHK_DUP2 INDEX LV_TABIX.

            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  IF LT_POJANG_TEXT IS NOT INITIAL.
    APPEND LINES OF LT_POJANG_TEXT TO GT_GUIDE_TEXT.
  ENDIF.

  IF LT_INSPECTION_TEXT IS NOT INITIAL.
    IF GT_GUIDE_TEXT IS NOT INITIAL.
      APPEND INITIAL LINE TO GT_GUIDE_TEXT ASSIGNING FIELD-SYMBOL(<LV_GUIDE_TEXT>).
      UNASSIGN <LV_GUIDE_TEXT>.
    ENDIF.

    APPEND LINES OF LT_INSPECTION_TEXT TO GT_GUIDE_TEXT.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_POPUP_SMORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAIN_200_ORDNO
*&      --> GS_MAIN_200_POSNR
*&---------------------------------------------------------------------*
FORM DISP_POPUP_SMORDER  USING   PV_ORDNO TYPE ZGTPPT2001-ORDNO
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

  CALL SCREEN '0600' STARTING AT 5 5 ENDING AT 83 19.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GO_TEXT_600
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GO_TEXT_600 .

  CREATE OBJECT GO_CONTAINER_600
    EXPORTING
      CONTAINER_NAME = 'CONTAINER_300'.

  CREATE OBJECT GO_TEXT_600
    EXPORTING
      WORDWRAP_MODE          = 2
      MAX_NUMBER_CHARS       = 255                         " maximum number of characters insertable into editor control
      PARENT                 = GO_CONTAINER_600                        " Parent Container
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
*& Form SET_GO_TEXT_600
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GO_TEXT_600 .

  GO_TEXT_600->SET_TOOLBAR_MODE( EXPORTING TOOLBAR_MODE = 0 ).

  GO_TEXT_600->SET_STATUSBAR_MODE( EXPORTING STATUSBAR_MODE = 0 ).

  GO_TEXT_600->SET_READONLY_MODE( EXPORTING READONLY_MODE = 1 ).

  GO_TEXT_600->SET_TEXT_AS_R3TABLE( EXPORTING TABLE = GT_TEXT ).

  CALL METHOD CL_GUI_CFW=>FLUSH
    EXCEPTIONS
      OTHERS = 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_SORT_JOJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM PROCESS_SORT_JOJANG  USING  PV_GUBUN.

  GV_JOJANG_SORT = PV_GUBUN.

  PERFORM REFRESH_SCREEN_201.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHAIN_DATA_JOJANG_LENGTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CHAIN_DATA_JOJANG_LENGTH .

  DATA : LT_MAIN LIKE GT_MAIN_200.
  DATA : LV_INDEX TYPE I.
  DATA : LV_TABIX TYPE I.

* 조장구성표 체인으로 출력을 위한 테이블 세팅
  REFRESH GT_MAKE_DISPLAY.

  LT_MAIN = GT_MAIN_200.
  CASE GV_JOJANG_SORT.
    WHEN 'U'.
      SORT LT_MAIN BY INLENGTH.
    WHEN 'D'.
      SORT LT_MAIN BY INLENGTH DESCENDING.
  ENDCASE..

  LOOP AT LT_MAIN INTO GS_MAIN_200.
    CLEAR GS_MAKE_DISPLAY.
    GS_MAKE_DISPLAY-END_ORDNR = GS_MAIN_200-ORDNO.
    GS_MAKE_DISPLAY-END_POSNR = GS_MAIN_200-POSNR.
    GS_MAKE_DISPLAY-GCATG = GS_MAIN_200-GCATG.

    CASE GS_MAIN_200-GCATG.
      WHEN '생산오더'.
        GS_MAKE_DISPLAY-END_ORDTY = 'SM'.
      WHEN '견적오더' OR '판매오더'.
        GS_MAKE_DISPLAY-END_ORDTY = 'SO'.
    ENDCASE.

*    GS_MAKE_DISPLAY-END_SEQNO = LV_TABIX.
    GS_MAKE_DISPLAY-MATNR = GS_MAIN_200-MATNR.

    READ TABLE GT_SEQ_ROUTING_SUB INTO GS_SEQ_ROUTING_SUB WITH KEY MATNR = GS_MAIN_200-MATNR.
    REFRESH GT_SEQ_ROUTING.
    GT_SEQ_ROUTING = GS_SEQ_ROUTING_SUB-T_ROUTING.

    PERFORM SET_CHAIN.

    CLEAR LV_INDEX.
    LV_INDEX = GS_MAIN_200-INFACTOR + 0. " 공정수 만큼 테이블 구성하여
    DO LV_INDEX TIMES.
      ADD 1 TO LV_TABIX.
      GS_MAKE_DISPLAY-END_SEQNO = LV_TABIX.
      APPEND GS_MAKE_DISPLAY TO GT_MAKE_DISPLAY.
    ENDDO.
  ENDLOOP.

  PERFORM GET_CHAIN_JOJANG.

  PERFORM SET_CHAIN_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_AND_SET_DRUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_DEL_2010
*&---------------------------------------------------------------------*
FORM CHK_AND_SET_DRUM  TABLES PT_CHG_2010 STRUCTURE ZGTPPT2010
                               CHANGING PS_2010 TYPE ZGTPPT2010.

  CHECK PS_2010-ORDTY = 'PRD'.

  DATA : LV_CHK_EXIST_DEL.
  DATA : LT_CHK_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : LT_RESB TYPE TABLE OF RESB.

  DATA : LV_VBELN TYPE VBAP-VBELN.
  DATA : LV_POSNR TYPE VBAP-POSNR.
  DATA : LV_AUFNR TYPE AFKO-AUFNR.
  DATA : LV_PACK_YN TYPE CHAR10.
  DATA : LV_PACK_DM TYPE MATNR.

* 바피 object
  DATA : LS_RETURN TYPE COXT_BAPIRETURN.
  DATA : LT_RESBKEYS TYPE COXT_T_RESBDEL,
         LT_RETURN   TYPE STANDARD TABLE OF BAPIRET2,
         LV_ERROR    TYPE FLAG.

  DATA : LS_REQU_QUAN TYPE COXT_S_QUANTITY.
  DATA : LV_STORAGE_LOCATION TYPE COXT_S_STORAGE_LOCATION.
  DATA : LV_STORAGE_LOCATIONX TYPE COXT_S_STORAGE_LOCATIONX.
  DATA : LV_POSNO TYPE CIF_R3RES-POSITIONNO.

  SELECT * FROM ZGTPPT2010
    INTO TABLE LT_CHK_2010
   WHERE GRPNR = PS_2010-GRPNR
     AND GONG_SEQ = PS_2010-GONG_SEQ
     AND ORDNR = PS_2010-ORDNR.

  IF LINE_EXISTS( LT_CHK_2010[ MATNR_DM =  '' ] ).
  ELSE.
    LV_CHK_EXIST_DEL = ABAP_TRUE.
  ENDIF.

  IF LV_CHK_EXIST_DEL IS INITIAL.
    READ TABLE PT_CHG_2010 INTO DATA(LS_CHG_2010) WITH KEY ORDNR = PS_2010-ORDNR
                                                                        ORDTY = 'PRD'.
    IF SY-SUBRC EQ 0 AND LS_CHG_2010-MATNR_DM IS NOT INITIAL.
      LV_CHK_EXIST_DEL = ABAP_TRUE.
    ENDIF.
  ENDIF.

* 포장재 지정 대상 확인
  LV_VBELN = PS_2010-DMORD.
  LV_POSNR = PS_2010-DMLINE.
  LV_AUFNR = PS_2010-ORDNR.

  ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
    EXPORTING
      IV_VBELN      =  LV_VBELN                " 판매 관리 문서 번호
      IV_POSNR      = LV_POSNR                 " SD 문서의 품목 번호
    IMPORTING
      EV_PACK_YN    = LV_PACK_YN
      EV_PACK_DM  = LV_PACK_DM ).

  IF LV_PACK_YN = 'CM'. " 포장재 지정상태와 드럼유형만 대상
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT        = LV_PACK_DM
      IMPORTING
        OUTPUT       = LV_PACK_DM
      EXCEPTIONS
        LENGTH_ERROR = 1
        OTHERS       = 2.
  ELSE. " 대상 아님 종료
    RETURN.
  ENDIF.

  IF LV_CHK_EXIST_DEL IS INITIAL.
* 기존 등록된 포장재 수량 확인.
    SELECT B~RSNUM, B~RSPOS
      FROM AFKO AS A
      INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
     INNER JOIN MARA AS C ON C~MATNR = B~MATNR
     WHERE A~AUFNR = @LV_AUFNR
       AND C~MTART LIKE 'MRM%'
       INTO CORRESPONDING FIELDS OF TABLE @LT_RESB.

    IF SY-SUBRC EQ 0.

      REFRESH : LT_RESBKEYS, LT_RETURN.
      CLEAR : LV_ERROR, LS_RETURN.

      IF SY-SUBRC EQ 0.
        LT_RESBKEYS = CORRESPONDING #( LT_RESB ).
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

          COMMIT WORK AND WAIT.
          WAIT UP TO '0.3' SECONDS.

* 삭제 되었는지 확인
          DO.
            SELECT B~RSNUM, B~RSPOS
              FROM AFKO AS A
              INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
             INNER JOIN MARA AS C ON C~MATNR = B~MATNR
             WHERE A~AUFNR = @LV_AUFNR
               AND C~MTART LIKE 'MRM%'
               INTO CORRESPONDING FIELDS OF TABLE @LT_RESB.
            IF SY-SUBRC EQ 0.
              WAIT UP TO '0.1' SECONDS.
            ELSE.
              EXIT.
            ENDIF.
          ENDDO.

          CALL FUNCTION 'CO_XT_ORDER_INITIALIZE'.
        ELSE.
          CLEAR: LV_ERROR,
                 LS_RETURN.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          RETURN.
        ENDIF.
      ELSE.
        CLEAR LV_ERROR.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        RETURN.
      ENDIF.
    ENDIF.

  ELSE.
* 기존 등록된 포장재 수량 확인.
    SELECT SINGLE B~*
      FROM AFKO AS A
      INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
     INNER JOIN MARA AS C ON C~MATNR = B~MATNR
     WHERE A~AUFNR = @LV_AUFNR
       AND B~MATNR = @LV_PACK_DM
       AND C~MTART LIKE 'MRM%'
       INTO  @DATA(LS_RESB).
    IF SY-SUBRC EQ 0. " 지정된 포장재와 같은 자재가 존재할 경우 테이블 직접 업데이트 후 종료

      ADD 1 TO LS_RESB-BDMNG.
      ADD 1 TO LS_RESB-ERFMG.

      UPDATE RESB SET BDMNG = LS_RESB-BDMNG
                                ERFMG = LS_RESB-ERFMG
       WHERE RSNUM = LS_RESB-RSNUM
         AND  RSPOS = LS_RESB-RSPOS
         AND  RSART = LS_RESB-RSART.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
        PS_2010-MATNR_DM = LV_PACK_DM.
      ELSE.
        ROLLBACK WORK.
      ENDIF.

      RETURN.

    ENDIF.
  ENDIF.

* 지정된 포장재에 대해 1건의 컴포넌트 생성
  SELECT SINGLE B~APLZL, B~PLNFL
    INTO ( @DATA(LV_OPERATION), @DATA(LV_SEQUENCE) )
    FROM AFKO AS A
   INNER JOIN AFVC AS B ON B~AUFPL EQ A~AUFPL
   WHERE A~AUFNR EQ @LV_AUFNR
      AND B~APLFL = '000000'
      AND B~RUECK NE ''.

  CLEAR : LS_REQU_QUAN, LV_STORAGE_LOCATION, LV_STORAGE_LOCATIONX, LV_POSNO, LS_RETURN, LV_ERROR.

  SELECT SINGLE MEINS FROM MARA
    INTO @DATA(LV_MEINS)
   WHERE MATNR = @LV_PACK_DM.


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
      I_MATERIAL           = LV_PACK_DM
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
      IF <LV_MATNR> = LV_PACK_DM.

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
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

      WAIT UP TO '0.3' SECONDS.
      CALL FUNCTION 'CO_XT_ORDER_INITIALIZE'.
      PS_2010-MATNR_DM = LV_PACK_DM.

    ELSE.
      CLEAR: LV_ERROR,
             LS_RETURN.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ENDIF.
  ELSE.
    CLEAR LV_ERROR.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_SET_CUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_SET_CUT .

  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LV_CHK_ERR.
  DATA : LV_ZZCUT_REQ TYPE AUFK-ZZCUT_REQ.

  PERFORM CHK_BEFORE_SET_CUT  TABLES LT_2010
                            CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF LT_2010[] IS INITIAL.
    RETURN.
  ENDIF.

  REFRESH GT_DEL_DISP.

  CLEAR LV_CHK_ERR.
  LOOP AT LT_2010 INTO DATA(LS_2010).
    APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING FIELD-SYMBOL(<LS_DEL_DISP>).

    CLEAR LV_ZZCUT_REQ.
    SELECT SINGLE ZZCUT_REQ FROM AUFK
      INTO LV_ZZCUT_REQ
     WHERE AUFNR = LS_2010-ORDNR.
    IF LV_ZZCUT_REQ IS INITIAL.
      LV_ZZCUT_REQ = ABAP_TRUE.
      <LS_DEL_DISP>-MESSAGE = |생산오더 { LS_2010-ORDNR ALPHA = OUT }특별사유절단 요청 되었습니다.|.
    ELSE.
      CLEAR LV_ZZCUT_REQ.
      <LS_DEL_DISP>-MESSAGE = |생산오더 { LS_2010-ORDNR ALPHA = OUT }특별사유절단 요청 취소되었습니다.|.
    ENDIF.

    UPDATE AUFK SET ZZCUT_REQ = LV_ZZCUT_REQ
     WHERE AUFNR = LS_2010-ORDNR.
    COMMIT WORK AND WAIT.

    <LS_DEL_DISP>-STATUS = ICON_LED_GREEN.

  ENDLOOP.

  GV_DISP_SET = 'A'.
  CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
  CLEAR GV_DISP_SET.

  PERFORM REFRESH_SCREEN_201.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_BEFORE_SET_CUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_BEFORE_SET_CUT  TABLES   PT_2010 LIKE GT_2010
                                              CHANGING PV_CHK_ERR.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_NUM(2) TYPE N.
  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_2010_CHK LIKE TABLE OF GS_2010.
  DATA : LV_CHART TYPE ATWRT.
  DATA : LV_SEQNO TYPE I.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_CHK_FIELDNAME TYPE CHAR30.
  DATA : LT_SEQ LIKE GT_SEQ_ROUTING_HEADER.

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_GONGSEQ> TYPE ANY.

  CLEAR : PV_CHK_ERR.
  REFRESH PT_2010[].

  GO_GRID_0201->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  GO_GRID_0201->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL AND LT_CELLS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'(e01).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

* 완제품 오더정보텝만 선택이 가능하므로 완제품 오더필드 구성
  CLEAR LV_CHK_FIELDNAME.
  LT_SEQ = GT_SEQ_ROUTING_HEADER.
  SORT LT_SEQ BY SEQNO DESCENDING.
  READ TABLE LT_SEQ INTO DATA(LS_SEQ) INDEX 1.
  LV_NUM = LS_SEQ-SEQNO + 0.
  LV_CHK_FIELDNAME = LV_NUM && '_' && LS_SEQ-CHART.
  LV_FIELDNAME = LV_NUM && '_SEQNO'.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    IF LS_COLUMN-FIELDNAME NE LV_CHK_FIELDNAME.
      CONTINUE.
    ENDIF.

* 완제품 생산오더만 가능
    LT_2010 = VALUE #( FOR WA_2010 IN GT_2010 WHERE ( GONG_CD = LS_SEQ-CHART
                                                                      AND   GONG_SEQ = LS_SEQ-GONG_SEQ
                                                                      AND    ORDTY = 'PRD' )
                                                   ( CORRESPONDING #( WA_2010 ) ) ).

  ENDLOOP.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_FIELDCAT_0201 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.
      IF LS_FCAT-FIELDNAME NE LV_CHK_FIELDNAME.
        CONTINUE.
      ENDIF.
    ENDIF.

*  선택된 필드의 오더정보 찾기
    READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
      ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.
      IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
      ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN_201> TO <LV_LINE>.

      IF <LV_GONGSEQ> IS ASSIGNED. UNASSIGN <LV_GONGSEQ>. ENDIF.
      ASSIGN COMPONENT LV_FIELDNAME OF STRUCTURE <LS_MAIN_201> TO <LV_GONGSEQ>.
      IF <LV_GONGSEQ> IS NOT ASSIGNED. " 공정을 못찾으면 종료
        RETURN.
      ELSE.
        IF <LV_GONGSEQ> = 0. " 해당 공정 순번이 비어있다면 오더가 없다는 의미 다음순번
          CONTINUE.
        ENDIF.
      ENDIF.

      READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
      READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) WITH KEY SEQNO = LS_SEQ-SEQNO.
      READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) WITH KEY IN_SEQNO = <LV_GONGSEQ>.

* 중복 필드라면 대상이 아님
      IF LS_CHAIN-CHK_DUP EQ ABAP_TRUE.
        CONTINUE.
      ENDIF.

      IF LS_CHAIN-ORDNR IS INITIAL.
        CONTINUE.
      ENDIF.

      IF LS_CHAIN-ORDTY NE 'PRD'.
        CONTINUE.
      ENDIF.

      READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY GONG_SEQ = LS_GONG-GONG_SEQ
                                                                      ORDNR = LS_CHAIN-ORDNR
                                                                      POSNR = LS_CHAIN-POSNR
                                                                      ORDTY = LS_CHAIN-ORDTY.
      IF SY-SUBRC EQ 0.
        APPEND LS_2010 TO LT_2010.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF LT_2010[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '완제품 공정만 선택이 가능합니다.'(m08).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LT_2010_CHK = LT_2010.
  SORT LT_2010_CHK BY ORDNR POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_2010_CHK COMPARING ORDNR.

  REFRESH LT_2010.

  SELECT A~*
    FROM @LT_2010_CHK AS A
    INNER JOIN AUFK AS B ON B~AUFNR = A~ORDNR
   WHERE B~FLG_MLTPS = 'X'
    INTO TABLE @LT_2010. " 복수품목

  IF LT_2010[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '복조장 구성 오더만 특별 절단지시 가능합니다.'(m09).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  PT_2010[] = LT_2010.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_POJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_POJANG .

  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_2010_CURRNT LIKE TABLE OF GS_2010.
  DATA : LT_2010_SORT_ORD LIKE TABLE OF GS_2010.
  DATA : BEGIN OF LS_POJANG_SET,
           MATNR TYPE MATNR,
           MENGE TYPE MENGE_D,
         END OF LS_POJANG_SET.
  DATA : LT_POJANG_SET LIKE TABLE OF LS_POJANG_SET.
  DATA : LV_PACK_YN TYPE CHAR10.
  DATA : LV_PACK_DM TYPE MATNR.
  DATA : LT_RESB TYPE TABLE OF RESB.
  DATA : LV_TABIX TYPE I.
  DATA : LT_MATCH_POJANG LIKE GT_MATCH_POJANG.
  DATA : LS_MATCH_POJANG LIKE GS_MATCH_POJANG.

  REFRESH GT_MATCH_POJANG.

  LT_2010 = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( ( DMORDTY = 'SM'
                                                   OR     DMORDTY = 'SO' )
                                                  AND   ORDTY = 'PRD' )
                            ( CORRESPONDING #( LW_2010 ) ) ).

  LT_2010_SORT_ORD = LT_2010.
  SORT LT_2010_SORT_ORD BY ORDNR.
  DELETE ADJACENT DUPLICATES FROM LT_2010_SORT_ORD COMPARING ORDNR.

  LOOP AT LT_2010_SORT_ORD INTO DATA(LS_SORT).
    REFRESH LT_MATCH_POJANG.
    REFRESH LT_POJANG_SET.

    LT_2010_CURRNT = VALUE #( FOR LW_2010 IN LT_2010 WHERE ( GONG_SEQ = LS_SORT-GONG_SEQ
                                             AND   ORDNR = LS_SORT-ORDNR )
                                             ( CORRESPONDING #( LW_2010 ) ) ).

*   - 포장재 재지정상태 확인.
    SELECT B~*
      FROM AFKO AS A
      INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
     INNER JOIN MARA AS C ON C~MATNR = B~MATNR
     WHERE A~AUFNR = @LS_SORT-ORDNR
       AND B~SORTF = '1'
       AND C~MTART LIKE 'MRM%'
       INTO TABLE @LT_RESB.
    IF SY-SUBRC EQ 0. " 해당 생산오더 판매오더가 재 지정되었다는 의미이므로 해당 오더 전체 품목건 포장재 OK

      LOOP AT LT_2010_CURRNT INTO DATA(LS_CURRENT).
        APPEND INITIAL LINE TO GT_MATCH_POJANG ASSIGNING FIELD-SYMBOL(<LS_MATCH_POJANG>).
        <LS_MATCH_POJANG> = VALUE #( ORDNR = LS_CURRENT-ORDNR POSNR = LS_CURRENT-POSNR ).
      ENDLOOP.

      CONTINUE.
    ENDIF.

    IF LS_SORT-MULTY_REF = ABAP_TRUE. " 팩터배치건 복조장일시 포장재 한건에 수량만 오더수만큼 적용.
      IF LS_SORT-DMORDTY = 'SO'.

        PERFORM CHK_POJANG_CHART USING LS_SORT CHANGING LV_PACK_YN LV_PACK_DM.

        IF LV_PACK_YN = 'CM' AND LV_PACK_DM IS NOT INITIAL.
          CLEAR LS_POJANG_SET.
          LS_POJANG_SET-MATNR = LV_PACK_DM.
          LS_POJANG_SET-MENGE = LINES( LT_2010_CURRNT ).
          APPEND LS_POJANG_SET TO LT_POJANG_SET.

          APPEND INITIAL LINE TO LT_MATCH_POJANG ASSIGNING <LS_MATCH_POJANG>.
          <LS_MATCH_POJANG> = VALUE #( ORDNR = LS_SORT-ORDNR POSNR = LS_SORT-POSNR ).

        ELSE.
          CONTINUE.
        ENDIF.

      ELSE.
        CONTINUE.
      ENDIF.

    ELSE.
      IF LINES( LT_2010_CURRNT ) > 1. " 복조장
        LOOP AT LT_2010_CURRNT ASSIGNING FIELD-SYMBOL(<LS_2010_CURRNT>).

          IF <LS_2010_CURRNT>-DMORDTY = 'SO'.
            PERFORM CHK_POJANG_CHART USING <LS_2010_CURRNT> CHANGING LV_PACK_YN LV_PACK_DM.
            IF LV_PACK_YN = 'CM' AND LV_PACK_DM IS NOT INITIAL. " 포장재 지정상태와 드럼유형만 대상
              CLEAR LS_POJANG_SET.
              LS_POJANG_SET-MATNR = LV_PACK_DM.
              LS_POJANG_SET-MENGE = 1.
              COLLECT LS_POJANG_SET INTO LT_POJANG_SET.

              APPEND INITIAL LINE TO LT_MATCH_POJANG ASSIGNING <LS_MATCH_POJANG>.
              <LS_MATCH_POJANG> = VALUE #( ORDNR = <LS_2010_CURRNT>-ORDNR POSNR = <LS_2010_CURRNT>-POSNR ).

            ELSE.
              CONTINUE.
            ENDIF.

          ENDIF.
        ENDLOOP.

      ELSE.
        IF LS_SORT-DMORDTY = 'SO'.
          PERFORM CHK_POJANG_CHART USING LS_SORT CHANGING LV_PACK_YN LV_PACK_DM.

          IF LV_PACK_YN = 'CM' AND LV_PACK_DM IS NOT INITIAL. " 포장재 지정상태와 드럼유형만 대상
            CLEAR LS_POJANG_SET.
            LS_POJANG_SET-MATNR = LV_PACK_DM.
            LS_POJANG_SET-MENGE = 1.
            APPEND LS_POJANG_SET TO LT_POJANG_SET.

            APPEND INITIAL LINE TO LT_MATCH_POJANG ASSIGNING <LS_MATCH_POJANG>.
            <LS_MATCH_POJANG> = VALUE #( ORDNR = LS_SORT-ORDNR POSNR = LS_SORT-POSNR ).

          ELSE.
            CONTINUE.
          ENDIF.

        ENDIF.

      ENDIF.
    ENDIF.

    IF LT_POJANG_SET[] IS INITIAL.
      CONTINUE.
    ENDIF.

    REFRESH LT_RESB.
* 기존 등록된 포장재 수량 확인.
    SELECT B~*
       FROM AFKO AS A
       INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
      INNER JOIN MARA AS C ON C~MATNR = B~MATNR
      WHERE A~AUFNR = @LS_SORT-ORDNR
        AND C~MTART LIKE 'MRM%'
        INTO TABLE @LT_RESB.

    DATA(LT_RESB_CHK) = LT_RESB.

    LOOP AT LT_POJANG_SET INTO LS_POJANG_SET.
      READ TABLE LT_RESB_CHK INTO DATA(LS_RESB_CHK) WITH KEY MATNR = LS_POJANG_SET-MATNR.
      IF SY-SUBRC EQ 0.
        LV_TABIX = SY-TABIX.
        IF LS_RESB_CHK-BDMNG = LS_POJANG_SET-MENGE.
          DELETE LT_RESB_CHK INDEX LV_TABIX.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF LT_RESB IS NOT INITIAL AND LT_RESB_CHK IS INITIAL. " 정상 반영 확인
      IF LT_MATCH_POJANG[] IS NOT INITIAL.
        APPEND LINES OF LT_MATCH_POJANG TO GT_MATCH_POJANG.
      ENDIF.

      CONTINUE.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_POJANG_CHART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SORT
*&      <-- LV_PACK_YN
*&      <-- LV_PACK_DM
*&---------------------------------------------------------------------*
FORM CHK_POJANG_CHART  USING    PS_2010 LIKE GS_2010
                       CHANGING PV_PACK_YN TYPE CHAR10
                                PV_PACK_DM TYPE MATNR.

  DATA : LV_VBELN TYPE VBAP-VBELN.
  DATA : LV_POSNR TYPE VBAP-POSNR.

  LV_VBELN = PS_2010-DMORD.
  LV_POSNR = PS_2010-DMLINE.

  CLEAR : PV_PACK_YN, PV_PACK_DM.

  ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
    EXPORTING
      IV_VBELN      =  LV_VBELN                " 판매 관리 문서 번호
      IV_POSNR      = LV_POSNR                 " SD 문서의 품목 번호
    IMPORTING
      EV_PACK_YN    = PV_PACK_YN
      EV_PACK_DM  = PV_PACK_DM ).

  IF PV_PACK_DM IS NOT INITIAL. " 포장재 지정상태와 드럼유형만 대상
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT        = PV_PACK_DM
      IMPORTING
        OUTPUT       = PV_PACK_DM
      EXCEPTIONS
        LENGTH_ERROR = 1
        OTHERS       = 2.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_SET_MERGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_SET_MERGE .

  DATA : LT_2010 LIKE GT_2010.
  DATA : LV_CHK_ERR.
  DATA : LV_ORDTY TYPE ZGTPPT2010-ORDTY.
  DATA : LO_JOJANG TYPE REF TO ZGTPP_CL_ROUTING_GAON.
  DATA : LT_RESULT TYPE BAPI_ORDER_RETURN_TT.
  DATA : LV_TEXT TYPE CHAR100.

  GO_GRID_0201->CHECK_CHANGED_DATA( ).

  PERFORM CHK_BEFORE_SET_MERGE TABLES LT_2010
                             CHANGING LV_CHK_ERR LV_ORDTY.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF LV_ORDTY IS INITIAL.
    LV_TEXT = '병합 구성 진행합니다. 계속 진행 하시겠습니까?'.
  ELSE.
    LV_TEXT = '병합오더 전환후 여장계산이 불가능 합니다. 계속 진행하시겠습니까?'.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    LV_TEXT
    '구성확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CREATE OBJECT LO_JOJANG
    EXPORTING
      IV_WERKS              = P_WERKS                 " 플랜트
      IV_GRPNR              = GV_GRPNR                 " 조장 구성표 번호
      IT_MAIN               = GT_MAKE_DISPLAY
      IT_SEQ_ROUTING_HEADER = GT_SEQ_ROUTING_HEADER
      IT_SEQ_ROUTING_SUB    = GT_SEQ_ROUTING_SUB
      IT_MAKED_2010         = GT_2010.

  LT_RESULT = LO_JOJANG->PROC_MERGE_ORDER( ).

  REFRESH GT_DEL_DISP.

  CLEAR LV_CHK_ERR.
  LOOP AT LT_RESULT INTO DATA(LS_RESULT).
    APPEND INITIAL LINE TO GT_DEL_DISP ASSIGNING FIELD-SYMBOL(<LS_DEL_DISP>).
    <LS_DEL_DISP>-MESSAGE = LS_RESULT-MESSAGE.
    CASE LS_RESULT-TYPE.
      WHEN 'E'.
        LV_CHK_ERR = ABAP_TRUE.
        <LS_DEL_DISP>-STATUS = ICON_LED_RED.
      WHEN 'W'.
        <LS_DEL_DISP>-STATUS = ICON_LED_RED.
      WHEN 'S'.
        <LS_DEL_DISP>-STATUS = ICON_LED_GREEN.
    ENDCASE.
  ENDLOOP.

  GV_DISP_SET = 'A'.
  CALL SCREEN '0220' STARTING AT 10 5 ENDING AT 90 9.
  CLEAR GV_DISP_SET.

  IF LV_CHK_ERR IS INITIAL.

*  변경정보 MES전송
    ZGTPP_CL_ROUTING=>SEND_CHG_MES(
      IV_WERKS = P_WERKS           " 플랜트
      IV_SPGCD = P_SPGCD          " SPG 코드
      IV_GRPNR = GV_GRPNR ).    " 조장 구성표 번호

    PERFORM REFRESH_SCREEN_201.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_BEFORE_SET_MERGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_BEFORE_SET_MERGE  TABLES   PT_2010 STRUCTURE GS_2010
                                          CHANGING PV_CHK_ERR PV_ORDTY.

  DATA : LT_2010 LIKE TABLE OF GS_2010.
  DATA : LT_2010_COLLECT LIKE TABLE OF GS_2010.
  DATA : LT_2010_CHK LIKE TABLE OF GS_2010. "입력된 숫자나 문자 기준으로 소트된 테이블
  DATA : LT_2010_CHK2 LIKE TABLE OF GS_2010. " 각종 체크 대상들
  DATA : LT_2010_CHK3 LIKE TABLE OF GS_2010. " 각종 체크 대상들
  DATA : LO_ROUTING TYPE REF TO ZGTPP_CL_ROUTING.
  DATA : LV_SEQNO TYPE I.

* 조장구성표 상세내역에서 입력된 숫자나 문자가 있을경우 복조장 구성이 가능한지 체크
  LT_2010 = VALUE #( FOR WA_2010 IN GT_2010 WHERE ( CHK_CHAR IS NOT INITIAL ) ( CORRESPONDING #( WA_2010 ) ) ).

  LT_2010_CHK = LT_2010[].
  SORT LT_2010_CHK BY CHK_CHAR.
  DELETE ADJACENT DUPLICATES FROM LT_2010_CHK COMPARING CHK_CHAR..

  LOOP AT LT_2010_CHK INTO DATA(LS_2010_CHK).
    REFRESH LT_2010_CHK2.
    LT_2010_CHK2 = VALUE #( FOR WA_2010 IN GT_2010 WHERE ( CHK_CHAR = LS_2010_CHK-CHK_CHAR ) ( CORRESPONDING #( WA_2010 ) ) ).

*  복조장에 구성문자 입력시 복조장은 전부 같은 구성문자로 포함 되어야 한다.
    LOOP AT LT_2010_CHK2 INTO DATA(LS_2010_CHK2).
      LOOP AT LT_2010 INTO DATA(LS_2010) WHERE ORDNR = LS_2010_CHK2-ORDNR
                                                               AND CHK_CHAR NE LS_2010_CHK-CHK_CHAR.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '병합 구성이 잘못되었습니다. 구성 표시 값을 확인해 주세요.'(m11).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDLOOP.

      IF LS_2010_CHK2-ORDTY NE 'PRD'.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 유형만 병합 오더전환할 수 있습니다.'(m12).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.

* 병합오더의 생성기준 변경 기존 이후공정 PO에서 전체로 확장
      CASE LS_2010_CHK2-DMORDTY.
        WHEN 'PO'.
        WHEN OTHERS.
          PV_ORDTY = LS_2010_CHK2-DMORDTY.
      ENDCASE.
*      IF LS_2010_CHK2-DMORDTY NE 'PO'.
*        MESSAGE S003 DISPLAY LIKE 'E' WITH '이후 공정이 구매오더 유형만 병합 오더전환할 수 있습니다.'(m17).
*        PV_CHK_ERR = ABAP_TRUE.
*        RETURN.
*      ENDIF.


      IF LS_2010_CHK2-REF_TANDEM = ABAP_TRUE.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '병합 구성이 잘못되었습니다. 구성 표시 값을 확인해 주세요.'(m11).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.

      IF LS_2010_CHK2-REF_TANDEM = 'T'. "탄뎀 복조장 구성시 탄뎀 설정된 오더끼리만 구성가능
        REFRESH LT_2010_CHK3.
        LT_2010_CHK3 = VALUE #( FOR WA_2010 IN LT_2010_CHK2 WHERE ( REF_TANDEM NE 'T' ) ( CORRESPONDING #( WA_2010 ) ) ).

        IF LT_2010_CHK3[] IS NOT INITIAL.
          MESSAGE S003 DISPLAY LIKE 'E' WITH ' 병합 구성이 잘못되었습니다. 구성 표시 값을 확인해 주세요.- 탄뎀'(m13).
          PV_CHK_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.
      ENDIF.

    ENDLOOP.

* 같은 문자가 없이 개별로 지정된 오더가 있으면 에러
    IF LINES( LT_2010_CHK2 ) = 1. "단독으로 존재한다면 복조장 구성을 할수 없음
      MESSAGE S003 DISPLAY LIKE 'E' WITH '병합 구성이 잘못되었습니다. 구성 표시 값을 확인해 주세요.- 단독존재'(m14).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

*   같은 구분자로 정해진 복조장 구성 요소가 같은 공정에 있는지 확인
    DATA(LT_CHK_GONG) = LT_2010_CHK2.
    SORT LT_CHK_GONG BY GONG_CD GONG_SEQ.
    DELETE ADJACENT DUPLICATES FROM LT_CHK_GONG COMPARING GONG_CD GONG_SEQ.
    IF LINES( LT_CHK_GONG ) > 1. "공정코드가 다른값이 존재하면 에러
      MESSAGE S003 DISPLAY LIKE 'E' WITH '병합 구성이 잘못되었습니다. 구성 표시 값을 확인해 주세요.-공정차이'(m15).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

*   같은 구분자로 정해진 복조장 구성 요소가 같은 공정에 있는지 확인
    DATA(LT_CHK_MATNR) = LT_2010_CHK2.
    SORT LT_CHK_MATNR BY GONG_CD MATNR GONG_SEQ.
    DELETE ADJACENT DUPLICATES FROM LT_CHK_MATNR COMPARING GONG_CD MATNR GONG_SEQ.
    IF LINES( LT_CHK_MATNR ) > 1. "공정코드가 다른값이 존재하면 에러
      MESSAGE S003 DISPLAY LIKE 'E' WITH '병합 구성이 잘못되었습니다. 구성 표시 값을 확인해 주세요.-자재가 다름'(m16).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

  ENDLOOP.

  DATA : LT_2010_ORIGN TYPE TABLE OF ZGTPPT2010.
  DATA : LT_2010_PRE TYPE TABLE OF ZGTPPT2010.
  DATA : LV_STRING TYPE STRING.

  LOOP AT LT_2010 INTO LS_2010.
    IF NOT ( LS_2010-CHK_PRD IS INITIAL AND LS_2010-CHECK_JEGO IS INITIAL ).
      READ TABLE GT_SEQ_ROUTING_HEADER INTO DATA(LS_ROUTING) WITH KEY GONG_SEQ = LS_2010-GONG_SEQ.
      CLEAR LV_STRING.
      LV_STRING = '(' && LS_ROUTING-CHART_VAL && ')'.

      MESSAGE S006 DISPLAY LIKE 'E' WITH LV_STRING LS_2010-ORDNR '오더는 생산 진행중으로 병합 구성할 수 없습니다.'(m18).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

    APPEND INITIAL LINE TO LT_2010_ORIGN ASSIGNING FIELD-SYMBOL(<LS_2010_ORIGN>).
    MOVE-CORRESPONDING LS_2010 TO <LS_2010_ORIGN>.
  ENDLOOP.

  PT_2010[] = LT_2010[].

* 선택된 공정의 이전 공정들에 대해 조회 - 생산 진행 중일시 복조장 구성 불가
  LOOP AT PT_2010 INTO DATA(LS_2010_WQ).
    REFRESH LT_2010_CHK.
    APPEND LS_2010_WQ TO LT_2010_CHK.
* 해당 오더가 복조장 오더일시 복조장 메인 조회 - 차후 추가예정

    READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = LS_2010_WQ-GONG_SEQ.
    LV_SEQNO = LS_ROUTING-SEQNO.
    DO.
      LV_SEQNO = LV_SEQNO - 1.
      IF LV_SEQNO = 0.
        EXIT.
      ENDIF.
      READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY SEQNO = LV_SEQNO.

      LOOP AT GT_2010 INTO DATA(LS_2010_PRE) WHERE GONG_SEQ = LS_ROUTING-GONG_SEQ.
        READ TABLE LT_2010_CHK TRANSPORTING NO FIELDS WITH KEY ORDNR = LS_2010_PRE-DMORD
                                                                                    POSNR = LS_2010_PRE-DMLINE
                                                                                    ORDTY = LS_2010_PRE-DMORDTY.
        IF SY-SUBRC EQ 0.
          IF LS_2010_PRE-CHK_PRD = ABAP_TRUE.
            READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = LS_2010_WQ-GONG_SEQ.
            CLEAR LV_STRING.
            LV_STRING = '(' && LS_ROUTING-CHART_VAL && ')'.
            MESSAGE S006 DISPLAY LIKE 'E' WITH LV_STRING LS_2010_WQ-ORDNR '오더는 생산 진행중으로 병합 구성할 수 없습니다.'(m18).
            PV_CHK_ERR = ABAP_TRUE.
            RETURN.
          ENDIF.

          IF LS_2010_PRE-REF_TANDEM = 'T'.
            READ TABLE GT_SEQ_ROUTING_HEADER INTO LS_ROUTING WITH KEY GONG_SEQ = LS_2010_WQ-GONG_SEQ.
            CLEAR LV_STRING.
            LV_STRING = '(' && LS_ROUTING-CHART_VAL && ')'.
            MESSAGE S006 DISPLAY LIKE 'E' WITH LV_STRING LS_2010_WQ-ORDNR '오더는 이전 공정에 탄뎀 설정되어 있어 병합 구성할 수 없습니다.'(m19).
            PV_CHK_ERR = ABAP_TRUE.
            RETURN.
          ENDIF.

        ENDIF.
      ENDLOOP.
    ENDDO.

  ENDLOOP.

  DATA : LV_AUART TYPE AUFART.
  DATA : LT_AUART TYPE TABLE OF AUFART.

* 해당 선택된 오더들의 오더타입 확인,
  SELECT A~CHK_CHAR, B~AUFNR, B~AUART
    FROM @LT_2010 AS A
    INNER JOIN AUFK AS B ON B~AUFNR = A~ORDNR
    INTO TABLE @DATA(LT_AUART_TMP).

  DATA(LT_CHK_AUART)  = LT_AUART_TMP.
  SORT LT_CHK_AUART BY CHK_CHAR.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_AUART COMPARING CHK_CHAR.

  LOOP AT LT_CHK_AUART INTO DATA(LS_CHK_AUART).
    REFRESH LT_AUART.
    LOOP AT LT_AUART_TMP INTO DATA(LS_AUART) WHERE CHK_CHAR = LS_CHK_AUART-CHK_CHAR.
      LV_AUART = LS_AUART-AUART.
      COLLECT LV_AUART INTO LT_AUART.
    ENDLOOP.

    IF LINES( LT_AUART ) NE 1.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '동일한 생산오더 유형으로만 병합 구성할 수 있습니다.'(m20).
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_BEFORE_CONV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_BEFORE_CONV  CHANGING PV_CHK_ERR.

  DATA : LV_MESSAGE(100).
  DATA : LV_MENGE TYPE MENGE_D.

* 판매오더의 포장재 확정유무, 입회검사 대상의 검사여장 확인하여 진행이 안되도록 .
  LOOP AT GT_MAIN_200 INTO DATA(LS_MAIN) WHERE GCATG = '판매오더'.
    IF LS_MAIN-PACK_YN NE '확정'.
      PV_CHK_ERR = ABAP_TRUE.
      LV_MESSAGE = |판매오더({ LS_MAIN-ORDNO }) 품목({ LS_MAIN-POSNR }) 포장재 확정되지 않았습니다.|.
      MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MESSAGE.
      RETURN.
    ENDIF.

    IF LS_MAIN-INSPE_YN = '유'.
      CLEAR LV_MENGE.
      LV_MENGE = LS_MAIN-INSPE_QLENGTH + LS_MAIN-INSPE_SPENGTH + 0.

      IF LV_MENGE = 0.
        LV_MESSAGE = |판매오더({ LS_MAIN-ORDNO }) 품목({ LS_MAIN-POSNR }) 입회 검사 여장이 등록되지 않았습니다.|.
        MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MESSAGE.
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GUIDE_END_CONV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM SET_GUIDE_END_CONV  CHANGING PV_CHK_ERR.

  DATA : LV_MENGE TYPE MENGE_D.
  DATA : LV_MENGE2 TYPE MENGE_D.
  DATA : LT_QLENGTH_TEXT TYPE TCHAR255.
  DATA : LT_SPENGTH_TEXT TYPE TCHAR255.

  CLEAR PV_CHK_ERR.

* 성공된 조장체인정보를 확인한다.
  SELECT * FROM ZGTPPT2010
    INTO TABLE @DATA(LT_TEMP_2010)
   WHERE GRPNR = @GV_GRPNR
     AND DMORDTY = 'SO'.

  REFRESH GT_GUIDE_TEXT.

* 조장의 계획오더생성 이후 입회검사 여장의 입력이 이루어 질수 있으므로
* - 입회 검사 여장의 길이와 완제품 검사 여장의 길이 확인하여 안내팜업으로 띄어준다.
  LOOP AT GT_MAIN_200 INTO DATA(LS_MAIN) WHERE GCATG = '판매오더'
                                           AND INSPE_YN = '유'.                               .

    CLEAR LV_MENGE.
* 완제품 자재의 검사여장 확인
    SELECT SINGLE A~MATNR, A~MTART, C~/SAPMP/FIX_AS_J
      FROM MARA AS A
      INNER JOIN MAPL AS B
                           ON B~MATNR = A~MATNR
      INNER JOIN PLPO AS C
                           ON C~PLNNR = B~PLNNR
     WHERE A~MATNR = @LS_MAIN-MATNR
        AND B~WERKS = @P_WERKS
        AND B~PLNTY = 'N'
        AND B~LOEKZ = ' '
        AND C~PLNTY = 'N'
        AND C~LOEKZ = ' '
        AND C~PLNKN = '00000001'
        INTO @DATA(LS_INFOR_MATNR).

* 해당 조장내 적용 되어야할 검사여장 정보 세팅
* 완제품 자재의 표준여장 추가되어있는지 확인
    SELECT SINGLE * FROM ZGTPPT2070
     WHERE GRPNR = @GV_GRPNR
        AND MATNR = @LS_MAIN-MATNR
        AND ORDNO IS INITIAL
      INTO @DATA(LS_2070).
    IF SY-SUBRC EQ 0.
      LV_MENGE = LS_2070-QLENGTH + LS_2070-CLENGTH + LS_MAIN-INSPE_QLENGTH.
    ELSE.
      LV_MENGE = LS_INFOR_MATNR-/SAPMP/FIX_AS_J + LS_MAIN-INSPE_QLENGTH.
    ENDIF.


    IF LS_MAIN-INSPE_QLENGTH > 0.

      CLEAR : LS_INFOR_MATNR, LS_2070.

      LOOP AT LT_TEMP_2010 INTO DATA(LS_TEMP_2010) WHERE DMORD = LS_MAIN-ORDNO
                                                     AND DMLINE = LS_MAIN-POSNR.

        CLEAR LV_MENGE2.
        LV_MENGE2 = LS_TEMP_2010-QLENGTH + LS_TEMP_2010-CLENGTH + LS_TEMP_2010-SLENGTH +
                    LS_TEMP_2010-ELENGTH + LS_TEMP_2010-ADLENGTH.

        IF LV_MENGE2 < LV_MENGE.
          APPEND INITIAL LINE TO LT_QLENGTH_TEXT ASSIGNING FIELD-SYMBOL(<LS_QLENGTH_TEXT>).
          CASE LS_TEMP_2010-ORDTY.
            WHEN 'PO'.
              <LS_QLENGTH_TEXT> = |　- Po  { LS_TEMP_2010-ORDNR }|.
            WHEN 'PRD'.
              <LS_QLENGTH_TEXT> = |　- Prd { LS_TEMP_2010-ORDNR }|.
            WHEN 'PR' OR 'UPR'.
              <LS_QLENGTH_TEXT> = |　- Pr  { LS_TEMP_2010-ORDNR }|.
            WHEN 'PLN'.
              <LS_QLENGTH_TEXT> = |　- Pln { LS_TEMP_2010-ORDNR }|.
          ENDCASE.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF LS_MAIN-INSPE_SPENGTH > 0.
      CLEAR LV_MENGE.
      SELECT * FROM ZGTPPT2010
        INTO TABLE @DATA(LT_SPENGTH)
       WHERE DMORD = @LS_MAIN-ORDNO
         AND DMLINE = @LS_MAIN-POSNR
         AND DMORDTY = 'SO'.

      CLEAR LV_MENGE2.
      LOOP AT LT_SPENGTH INTO DATA(LS_SPENGTH).
        LV_MENGE2 = LV_MENGE2 + LS_TEMP_2010-QLENGTH + LS_TEMP_2010-CLENGTH + LS_TEMP_2010-SLENGTH +
                    LS_TEMP_2010-ELENGTH + LS_TEMP_2010-ADLENGTH - LV_MENGE.
      ENDLOOP.
      IF LV_MENGE2 < LS_MAIN-INSPE_SPENGTH.
        APPEND INITIAL LINE TO LT_SPENGTH_TEXT ASSIGNING FIELD-SYMBOL(<LS_SPENGTH_TEXT>).
        <LS_SPENGTH_TEXT> = |　- SO  { LS_MAIN-ORDNO }/{ LS_MAIN-POSNR }.|.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF LT_QLENGTH_TEXT[] IS NOT INITIAL.
    PV_CHK_ERR = ABAP_TRUE.
    APPEND INITIAL LINE TO GT_GUIDE_TEXT ASSIGNING FIELD-SYMBOL(<LV_GUIDE_TEXT>).
    <LV_GUIDE_TEXT> = '판매오더에 입회 검사여장이 포함되어 있습니다. 아래 오더들 확인바랍니다.'.

    APPEND LINES OF LT_QLENGTH_TEXT TO GT_GUIDE_TEXT.
  ENDIF.

  IF LT_SPENGTH_TEXT[] IS NOT INITIAL.
    PV_CHK_ERR = ABAP_TRUE.
    APPEND INITIAL LINE TO GT_GUIDE_TEXT ASSIGNING <LV_GUIDE_TEXT>.
    <LV_GUIDE_TEXT> = '판매오더 입회 특별 여장 조장 반영 확인하세요.'.
    APPEND LINES OF LT_SPENGTH_TEXT TO GT_GUIDE_TEXT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_MASTER_ORDER_DEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_MASTER_ORDER_DEL .

  DATA : LT_2000 TYPE TABLE OF ZGTPPT2000.
  DATA : LV_CHK_ERR.

  PERFORM CHK_BEFORE_MASTER_ORDER_DEL  CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 오더번호가 삭제되어 조장구성 할 수 없습니다. 계속 진행 하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.


  READ TABLE GT_CHK_IDX INTO GS_CHK_IDX INDEX 1 .

  SELECT * FROM ZGTPPT2000
    INTO TABLE LT_2000
   WHERE GRPNR = GV_GRPNR.

  READ TABLE LT_2000 ASSIGNING FIELD-SYMBOL(<LS_2000>) WITH KEY ORDNO = GS_CHK_IDX-ORDNO
                                                                POSNR = GS_CHK_IDX-POSNR.
  IF SY-SUBRC EQ 0.
    <LS_2000>-INFACTOR = <LS_2000>-INFACTOR - 1.
    IF <LS_2000>-INFACTOR = 0.
      <LS_2000>-ZSTATUS = 'D'.
    ENDIF.
    <LS_2000>-AEDAT = SY-DATUM.
    <LS_2000>-AENAM = SY-UNAME.
  ENDIF.

  MODIFY ZGTPPT2000 FROM TABLE LT_2000.
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '주문 변경사항 저장중 에러 발생하였습니다.'(e27).
    RETURN.
  ENDIF.

  MESSAGE S003 WITH '선택된 조장의 주문이 변경되었습니다. 첫화면으로 돌아갑니다.'(m02).

*     종료
  IF SY-TCODE NE 'ZGTPPR2050'.
    CALL FUNCTION 'DEQUEUE_EZGT_ZGTPPR2010'
      EXPORTING
        GRPNR = GV_GRPNR.
  ENDIF.

  CALL METHOD GO_DOCKING_CONTAINER->FREE.
  FREE : GO_DOCKING_CONTAINER, GO_GRID_0200, GO_GRID_0201.
  CALL METHOD CL_GUI_CFW=>FLUSH.

  UNASSIGN <GT_MAIN_201>.

  PERFORM GET_PROC.
  PERFORM REFRESH_GRID USING GO_GRID_0100.

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_BEFORE_MASTER_ORDER_DEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_BEFORE_MASTER_ORDER_DEL  CHANGING PV_CHK_ERR.

  DATA : LT_CELLS TYPE LVC_T_CENO.

  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.

  REFRESH GT_CHK_IDX.

  GO_GRID_0201->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_CELLS[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '선택된 오더번호가 없습니다.'(m21).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.

  ENDIF.

* 셀 선택시 선택 라인 대상으로 확인
  SORT LT_CELLS BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CELLS COMPARING ROW_ID.

  IF LINES( LT_CELLS ) NE 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '하나의 셀만 선택해야 합니다.'(e19).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE <GT_MAIN_201> ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0.
      IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
      ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN_201> TO <LV_SEQNO>.

      READ TABLE GT_MAKE_DISPLAY INTO DATA(LS_ITAB) WITH KEY END_SEQNO = <LV_SEQNO>.
* 완제품 공정의 순번이 마지막 이므로 소트후 조회
      SORT LS_ITAB-T_GONG BY SEQNO DESCENDING.
      READ TABLE LS_ITAB-T_GONG INTO DATA(LS_GONG) INDEX 1.
* 마스터 오더에 연결된 완제품 공정은 하나이므로 리드테이블로 데이터 구성
      CLEAR GS_CHK_IDX.
      GS_CHK_IDX-TABIX = LS_ITAB-END_SEQNO.
      GS_CHK_IDX-MATNR = LS_ITAB-MATNR .
      GS_CHK_IDX-GCATG = LS_ITAB-GCATG.
      GS_CHK_IDX-ORDNO = LS_ITAB-END_ORDNR.
      GS_CHK_IDX-POSNR = LS_ITAB-END_POSNR.
      READ TABLE LS_GONG-T_CHAIN INTO DATA(LS_CHAIN) INDEX 1.
      IF SY-SUBRC EQ 0 AND LS_CHAIN-ORDNR IS NOT INITIAL.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '조장 구성된 오더번호가 선택되었습니다.'(m22).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
      APPEND GS_CHK_IDX TO GT_CHK_IDX.
    ENDIF.
  ENDLOOP.

ENDFORM.
